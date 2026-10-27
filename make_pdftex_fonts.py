#!/usr/bin/env python3
"""make_pdftex_fonts.py -- build the pdfTeX backend auxiliary vertical fonts.

Reads the mincho/gothic TTFs with
fontTools (cmap, GSUB vert/vrt2, hmtx/vmtx, VORG, exact outline ink bboxes),
selects the vertical glyph set, and emits into --outdir:

  jlreqv-<fam>-<shard>.ttf   auxiliary TTF: slot 0 = .notdef, slot i = the
                            vert/placement glyph whose source codepoint is
                            the i-th entry of the sorted selection, named
                            jlreqvXXXX (XXXX = source codepoint hex).  Fixed
                            internal dates, deterministic glyph order.
  jlreqv-<fam>-<shard>.enc   explicit 256-element encoding (PostScript
                            /encname [ ... ] def form ttf2tfm consumes).
  jlreqv-<fam>-<shard>.tfm   built with ttf2tfm (see TTF2TFM_CMD below; the
                            flags were verified empirically on TL2025:
                            `ttf2tfm <ttf> -N -u -p <enc> <outbase>`).
  <profile>.def             profile data tables consumed by the backend
                            (jlreq-pdftex.sty): per family the aux TFM
                            names, map lines, per-slot ToUnicode hex, and
                            per-codepoint em-unit metrics
                            {advance, vorigin, inkbox, source} for BOTH the
                            substituted (aux) and normal (rotated) glyphs.
  LICENSE-aux-<fam>.txt      license/source attribution reproduced from the
                            source font's name table.

All emitted data are deterministic: fixed head.created/modified, sorted
glyph order, sorted output text, %.6f fixed decimals, no timestamps.

Build-time tool only: normal documents never run this script;
they consume the committed profile .def + font files.

Usage:
  make_pdftex_fonts.py --fontset ipaex|ipa|haranoaji [--outdir DIR]
      [--profile FILE]
  make_pdftex_fonts.py --fontset custom --mincho TTF --gothic TTF \
      [--outdir DIR] [--profile FILE] [--shard-size N]
  make_pdftex_fonts.py --print-manifest
"""

import argparse
import hashlib
import io
import json
import os
import subprocess
import sys

try:
    from fontTools.ttLib import TTFont, newTable
    from fontTools.fontBuilder import FontBuilder
    from fontTools.pens.cu2quPen import Cu2QuPen
    from fontTools.pens.ttGlyphPen import TTGlyphPen
    from fontTools.pens.boundsPen import BoundsPen
    from fontTools.ttLib.tables._c_m_a_p import CmapSubtable
except ImportError:
    sys.stderr.write("make_pdftex_fonts.py: fontTools is required "
                     "(python3 -m pip install fonttools)\n")
    raise SystemExit(1)

GEN_VERSION = "1.0"

# ttf2tfm flags (empirically verified, TeX Live 2025 ttf2tfm 2.0):
#   -N  use only PS names and no cmap (our aux glyphs carry no cmap)
#   -u  output only characters from the encoding (no extra slots)
#   -p ENCFILE  explicit 256-element input encoding
# The option ORDER matters on this build: options must come AFTER the font
# file argument, or the parser counts the option values as non-option
# arguments ("Need at most two non-option arguments").  The output TFM base
# name must be given so the TFM is written as <base>.tfm.
TTF2TFM_CMD = ["ttf2tfm", "<ttf>", "-N", "-u", "-p", "<enc>", "<base>"]

# Fixed internal date (determinism): 2000-01-01 00:00:00 UTC.
FIXED_DATE = 946684800

# Cu2QuPen max approximation error (font units) for CFF->TrueType outline
# conversion.  fontTools recommends upem/1000 (HaranoAji upem=1000 -> 1.0);
# we use 0.5 (upem/2000): measured worst symmetric outline deviation over
# the vert/placement glyphs is then < 0.9 units = 0.09% em (see
# tests/check-pdftex-fonts.py's raster comparison gate).
CFF_TO_QUADRATIC_MAX_ERR = 0.5

# --------------------------------------------------------------- fontsets

# haranoaji: the OTF sources are CFF; the same files are converted to
# full quadratic TTFs (see convert_to_ttf) for the HORIZONTAL chain.
FONTSETS = {
    "ipaex": {"mincho": "ipaexm.ttf", "gothic": "ipaexg.ttf"},
    "ipa": {"mincho": "ipam.ttf", "gothic": "ipag.ttf"},
    "haranoaji": {"mincho": "HaranoAjiMincho-Regular.otf",
                  "gothic": "HaranoAjiGothic-Regular.otf"},
}

# haranoaji horizontal-chain output names (see convert_to_ttf): the full
# quadratic TTF conversions consumed by bxcjkjatype's \setminchofont etc.
# "mc"=mincho regular, "mcb"=mincho bold, "gt"=gothic, "gtb"=gothic bold.
HORIZONTAL_TTFS = {
    "mc": "haranoaji-mincho-ttf.ttf",
    "mcb": "haranoaji-mincho-bold-ttf.ttf",
    "gt": "haranoaji-gothic-ttf.ttf",
    "gtb": "haranoaji-gothic-bold-ttf.ttf",
}

# tate JFM classes whose members need per-glyph placement data (advance is
# still the JFM class width at runtime; the profile supplies the per-glyph
# ink/vorigin corrections).  Derived from the loaded JFM class tables: the
# punctuation/small-kana/halfwidth/prolonged-sound/leader/hyphen classes.
PLACEMENT_CLASSES = (1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 161,
                     300, 301, 302)

# --------------------------------------------------------------- utilities


def kpsewhich(name):
    r = subprocess.run(["kpsewhich", name], capture_output=True, text=True)
    if r.returncode != 0:
        raise SystemExit("make_pdftex_fonts.py: cannot find %s via kpsewhich"
                         % name)
    return r.stdout.strip()


def utf16_hex(cp):
    """Source codepoint -> ToUnicode UTF-16BE hex (surrogate pair non-BMP)."""
    if cp < 0x10000:
        return "%04X" % cp
    cp -= 0x10000
    return "%04X%04X" % (0xD800 + (cp >> 10), 0xDC00 + (cp & 0x3FF))


def num(v):
    return "%.6f" % v


# --------------------------------------------------------- font analysis


class GlyphData(object):
    """Per-codepoint vertical metrics in EM units (all /unitsPerEm)."""

    def __init__(self):
        self.name = None          # jlreqvXXXX
        self.codepoint = None     # source unicode
        self.substituted = False  # vert/vrt2 target used (aux glyph)
        self.target_glyph = None  # source-font glyph object name (or None)
        self.advance = 1.0        # vmtx advance / upem
        self.vorigin = None       # vertical origin (em, from baseline)
        self.ink = None           # (x0, y0, x1, y1) em units of the drawn glyph
        self.hmtx = None          # (advance, lsb) of the drawn glyph


def read_font(path):
    return TTFont(path)


def gsub_single_subst(font, tag):
    """All SingleSubst mappings of feature `tag` (per-lookup union)."""
    if "GSUB" not in font:
        return {}
    gsub = font["GSUB"].table
    out = {}
    for fr in gsub.FeatureList.FeatureRecord:
        if fr.FeatureTag != tag:
            continue
        for li in fr.Feature.LookupListIndex:
            lookup = gsub.LookupList.Lookup[li]
            for st in lookup.SubTable:
                # SingleSubst format 1 (delta) has no .mapping
                if getattr(st, "mapping", None):
                    out.update(st.mapping)
                elif hasattr(st, "coverage") and st.coverage is not None:
                    delta = getattr(st, "deltaGlyphID", None)
                    if delta is not None:
                        for g in st.coverage.glyphs:
                            tgt = font.getGlyphID(g) + delta
                            out[g] = font.getGlyphOrder()[tgt]
    return out


def vert_substitutions(font):
    """vrt2 first (higher priority), vert as fallback; merged per source."""
    m = gsub_single_subst(font, "vert")
    m2 = gsub_single_subst(font, "vrt2")
    merged = dict(m)
    merged.update(m2)  # vrt2 wins on conflicts
    return merged


def vorigin_of(font, glyph_name, upem, bounds):
    """Vertical origin in em units (y of the horizontal baseline plane where
    the vertical advance starts, measured UP from the glyph's baseline).

    VORG (OpenType) first; else vmtx: origin = bbox_yMax + tsb (top side
    bearing) as OpenType/ltj do (ltj-lotf_aux.lua: tsb + boundingbox[4])."""
    vorg = font.get("VORG")
    if vorg is not None:
        try:
            y = vorg.vertOriginY.get(glyph_name, vorg.defaultVertOriginY)
            return y / float(upem)
        except AttributeError:
            pass
    if "vmtx" in font:
        adv, tsb = font["vmtx"].metrics.get(glyph_name, (upem, 0))
        if bounds is not None:
            return (bounds[3] + tsb) / float(upem)
        return tsb / float(upem)
    # last resort: hhea ascender (the ltj default 0.88 heuristic)
    asc = font["hhea"].ascent if "hhea" in font else int(0.88 * upem)
    return asc / float(upem)


def analyze_font(path):
    """Return (font, cmap, vert, per-cp GlyphData dict)."""
    font = read_font(path)
    upem = font["head"].unitsPerEm
    cmap = font.getBestCmap()
    vert = vert_substitutions(font)
    gs = font.getGlyphSet()

    # selection: every cmap codepoint that has a vert/vrt2 substitution
    # (the "212" set for ipaex, 498 for ipam) UNION the tate-JFM
    # placement-class characters (needs ink/vorigin even when not
    # substituted -- they are rendered rotated and need per-glyph data;
    # a representative glyph's bbox is never reused for a whole class).
    cps = set()
    rev = {}
    for cp, gname in cmap.items():
        rev.setdefault(gname, []).append(cp)
    for gname in vert:
        for cp in rev.get(gname, []):
            cps.add(cp)
    for cp in jfm_placement_codepoints():
        if cp in cmap:
            cps.add(cp)

    data = {}
    for cp in sorted(cps):
        g = GlyphData()
        g.codepoint = cp
        g.name = "jlreqv%04X" % cp if cp <= 0xFFFF else "jlreqv%05X" % cp
        src_glyph = cmap[cp]
        tgt = vert.get(src_glyph)
        drawn = tgt if tgt is not None else src_glyph
        g.substituted = tgt is not None
        g.target_glyph = drawn
        bp = BoundsPen(gs)
        gs[drawn].draw(bp)
        g.ink = None if bp.bounds is None else tuple(
            v / float(upem) for v in bp.bounds)
        g.advance = None
        if "vmtx" in font:
            adv, tsb = font["vmtx"].metrics.get(drawn, (upem, 0))
            g.advance = adv / float(upem)
            g.vorigin = vorigin_of(font, drawn, upem, bp.bounds)
        else:
            ha = font["hmtx"].metrics.get(drawn, (upem, 0))
            g.advance = ha[0] / float(upem)
            g.vorigin = None
        ha, lsb = font["hmtx"].metrics.get(drawn, (upem, 0))
        g.hmtx = (ha, lsb)
        data[cp] = g
    return font, cmap, vert, data, upem


_JFM_PLACEMENT_CPS = None


def jfm_placement_codepoints():
    """Tate-JFM placement-class chars, decoded from jfm-jlreqv.lua.

    Parsed with a texlua-free UTF-8 scanner over the `chars` lists of
    PLACEMENT_CLASSES (the same source the runtime .def files carry)."""
    global _JFM_PLACEMENT_CPS
    if _JFM_PLACEMENT_CPS is None:
        here = os.path.dirname(os.path.abspath(__file__))
        path = os.path.join(here, "jfm-jlreqv.lua")
        cps = set()
        text = open(path, encoding="utf-8").read()
        import re
        for m in re.finditer(r'\["chars"\]=\{([^}]*)\}', text):
            body = m.group(1)
            for sm in re.finditer(r'"((?:[^"\\]|\\.)*)"', body):
                s = sm.group(1)
                if re.match(r'^(?:[A-Za-z][A-Za-z0-9-]*-?\d*|AJ1-\d+)$', s):
                    # pseudo class names (alchar/parbdd/boxbdd) and
                    # AJ1 glyph names are not literal codepoints
                    continue
                cps.update(_utf8_codepoints(s))
        _JFM_PLACEMENT_CPS = cps
    return _JFM_PLACEMENT_CPS


def _utf8_codepoints(s):
    out = []
    b = s.encode("utf-8")
    i = 0
    while i < len(b):
        c = b[i]
        if c < 0x80:
            out.append(c)
            i += 1
        elif c < 0xE0:
            out.append(((c & 0x1F) << 6) | (b[i + 1] & 0x3F))
            i += 2
        elif c < 0xF0:
            out.append(((c & 0x0F) << 12) | ((b[i + 1] & 0x3F) << 6)
                       | (b[i + 2] & 0x3F))
            i += 3
        else:
            out.append(((c & 0x07) << 18) | ((b[i + 1] & 0x3F) << 12)
                       | ((b[i + 2] & 0x3F) << 6) | (b[i + 3] & 0x3F))
            i += 4
    return out


# ------------------------------------------------------------ aux TTF


def build_aux_font(src_font, gs, sel, out_ttf, upem, family_label, license_text):
    """sel: list of (cp, GlyphData) sorted by cp.  Slots: 0=.notdef,
    i=sel[i-1].  Returns the glyph order used."""
    # CFF (OTF) sources draw CUBIC Beziers through TTGlyphPen, but a
    # TrueType glyf table with glyphDataFormat=0 requires QUADRATIC
    # outlines (fontTools refuses to compile cubic glyf otherwise:
    # "Glyph ... has cubic Bezier outlines, but glyphDataFormat=0").
    # Convert every collected outline through Cu2QuPen (max_err in
    # font units, <= upem/1000 keeps the outline deviation under
    # 1/1000 em as recommended by fontTools).  reverse_direction=True
    # because CFF and TrueType use opposite winding conventions (the
    # fontTools cu2qu CLI/ufo converters default to reversing).
    # TrueType sources are already quadratic; Cu2QuPen passes lines
    # and quadratics through unchanged, so this is a no-op for TTFs.
    order = [".notdef"]
    glyphs = {".notdef": TTGlyphPen(gs).glyph()}
    hmtx = {".notdef": (upem, 0)}
    vmtx = {".notdef": (upem, 0)}
    for cp, g in sel:
        pen = TTGlyphPen(gs)
        gs[g.target_glyph].draw(Cu2QuPen(
            pen, max_err=CFF_TO_QUADRATIC_MAX_ERR,
            reverse_direction=True))
        glyphs[g.name] = pen.glyph()
        order.append(g.name)
        adv, lsb = g.hmtx
        hmtx[g.name] = (adv, lsb)
        # vmtx: advance from the glyph's vmtx; tsb = vorigin - yMax (ink)
        vadv = int(round(g.advance * upem)) if g.advance else upem
        if g.ink is not None and g.vorigin is not None:
            tsb = int(round((g.vorigin - g.ink[3]) * upem))
        else:
            tsb = 0
        vmtx[g.name] = (vadv, tsb)

    fb = FontBuilder(upem, isTTF=True)
    fb.setupGlyphOrder(order)
    fb.setupGlyf(glyphs)
    fb.setupHorizontalMetrics(hmtx)
    fb.setupHorizontalHeader(asce=882, des=-162, lineGap=0)
    fb.setupCharacterMap({})
    fb.setupNameTable({
        "familyName": "JLreqVert" + family_label,
        "styleName": "Regular",
        "fullName": "JLreqVert" + family_label,
        "psName": "JLreqVert" + family_label,
    })
    fb.setupOS2(sTypoAscender=882, sTypoDescender=-162,
                usWinAscent=882, usWinDescent=162)
    fb.setupVerticalMetrics(vmtx)
    fb.setupVerticalHeader(asce=1802, des=246, lineGap=0)
    fb.setupPost()
    font = fb.font
    font["head"].created = FIXED_DATE
    font["head"].modified = FIXED_DATE
    # deterministic name table: fixed ID 5 version string
    font["name"].setName("Version 001.000 (jlreq-pdftex aux vertical)", 5, 3, 1, 0x409)
    font.save(out_ttf)
    return order


def build_enc(order_sel, shard, enc_name, out_enc):
    """256-element PostScript encoding; slot i = sel[i-1] (i>=1)."""
    lines = ["/%s [" % enc_name]
    lines.append("/.notdef")
    for cp, g in order_sel:
        lines.append("/" + g.name)
    while len(lines) < 257:
        lines.append("/.notdef")
    lines.append("] def")
    with open(out_enc, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")


def build_tfm(ttf, enc, base, outdir):
    outbase = os.path.join(outdir, base)
    cmd = ["ttf2tfm", os.path.join(outdir, ttf), "-N", "-u",
           "-p", os.path.join(outdir, enc), outbase]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0 or not os.path.exists(outbase + ".tfm"):
        sys.stderr.write("make_pdftex_fonts.py: ttf2tfm failed (%s):\n%s\n"
                         % (" ".join(cmd), r.stdout + r.stderr))
        raise SystemExit(1)
    return outbase + ".tfm"


# --------------------------------------------------------------- profile


def build_profile(families, profile_path, outdir, license_note):
    """families: {'mc': [...], 'gt': [...]} entry lists.
    Emits a LaTeX-readable .def (backend contract, see jlreq-pdftex.sty)."""
    out = []
    a = out.append
    a("%% jlreq-pdftex font profile (generated by make_pdftex_fonts.py %s)"
      % GEN_VERSION)
    a("%% DO NOT EDIT; regenerate with `make pdftex-fonts`.")
    a("%% Source license/attribution:")
    for line in license_note.splitlines():
        a("%%   " + line)
    a("\\def\\jlreqpdf@fontprofile@version{%s}" % GEN_VERSION)
    total = {}
    for fam, entries in sorted(families.items()):
        a("")
        a("%% ---- family %s" % fam)
        maplines = []
        tfms = []
        encs = []
        for e in entries:
            tfms.append(e["tfm"])
            encs.append(e["enc"])
            maplines.append(e["mapline"])
        a("\\def\\jlreqpdf@fontprofile@%s@shards{%d}" % (fam, len(tfms)))
        for i, t in enumerate(tfms):
            a("\\expandafter\\def\\csname jlreqpdf@fontprofile@%s@tfm@%d\\endcsname{%s}"
              % (fam, i, t))
        for i, e in enumerate(encs):
            a("\\expandafter\\def\\csname jlreqpdf@fontprofile@%s@enc@%d\\endcsname{%s}"
              % (fam, i, e))
        for ml in maplines:
            a("\\pdfmapline{%s}" % ml)
        # per-glyph data: \jlreqpdf@vglyph@<HEX>{...}
        for e in entries:
            for cp, g in e["sel"]:
                sub = "1" if g.substituted else "0"
                ink = "{%s}{%s}{%s}{%s}" % (
                    num(g.ink[0]), num(g.ink[1]),
                    num(g.ink[2]), num(g.ink[3])) if g.ink else "{}"
                vo = num(g.vorigin) if g.vorigin is not None else "{}"
                adv = num(g.advance) if g.advance is not None else "{}"
                shard = str(e["shard"])
                slot = str(g.slot)
                uni = utf16_hex(cp)
                a("\\expandafter\\def\\csname jlreqpdf@vglyph@%d\\endcsname"
                  "{{%s}{%s}{%s}{%s}{%s}{%s}{%s}}"
                  % (cp, sub, adv, vo, ink, shard, slot, uni))
                # ToUnicode registration for the aux slot glyph
                a("\\pdfglyphtounicode{%s}{%s}" % (g.name, uni))
        total[fam] = len(tfms)
    a("")
    a("\\pdfgentounicode=1\\relax")
    text = "\n".join(out) + "\n"
    with open(profile_path, "w", encoding="utf-8") as fh:
        fh.write(text)
    return text


# --------------------------------------------------------------- driver


def build_family(label, fslabel, src_path, outdir, shard_size):
    font, cmap, vert, data, upem = analyze_font(src_path)
    gs = font.getGlyphSet()
    selpairs = sorted(data.items())          # (cp, GlyphData)
    shards = []
    for si in range(0, len(selpairs), shard_size):
        chunk = selpairs[si:si + shard_size]
        shard = len(shards)
        ttf = "jlreqv-%s-%s-%02d.ttf" % (fslabel, label, shard)
        enc = "jlreqv-%s-%s-%02d.enc" % (fslabel, label, shard)
        tfm = "jlreqv-%s-%s-%02d" % (fslabel, label, shard)
        order_sel = [(cp, g) for cp, g in chunk]
        for i, (cp, g) in enumerate(order_sel):
            g.slot = i + 1
            g.shard = shard
        build_aux_font(font, gs, order_sel,
                        os.path.join(outdir, ttf), upem, fslabel,
                        license_text_from(font))
        build_enc(order_sel, shard, "JLreqVert%s%s%02d" % (fslabel, label, shard),
                  os.path.join(outdir, enc))
        build_tfm(ttf, enc, tfm, outdir)
        shards.append({
            "shard": shard, "ttf": ttf, "enc": enc, "tfm": tfm,
            "sel": order_sel,
            "mapline": "=%s <%s ReEncodeFont <%s" % (tfm, enc, ttf),
        })
    return shards, font


def convert_to_ttf(src_path, out_ttf):
    """Full-font CFF (OTF) -> quadratic TrueType conversion for the
    HORIZONTAL chain (pdfTeX/TrueType machinery reads glyf outlines;
    ttf2tfm-era tools do not read CFF).

    pdfTeX's horizontal CJK text runs on the installed zhmetrics dynamic
    TFM chain (unisong@Unicode@ etc.), which is font-agnostic: the TFM
    names stay fixed and only the \\pdfmapline target file changes.  So a
    fontset without its own TTF set (HaranoAji is OTF-only in TeX Live,
    no .sty/.tfm support files) needs exactly one artifact per face: a
    full-coverage quadratic TTF.

    Deterministic: fixed head.created/modified.  cmap/hmtx/vmtx/name/OS2
    are carried over from the source (names do not matter to pdfTeX map
    embedding; the glyph-index alignment is preserved because the glyph
    ORDER is copied verbatim)."""
    font = read_font(src_path)
    if "CFF " not in font:
        raise SystemExit("make_pdftex_fonts.py: convert_to_ttf: %s has no "
                         "CFF table (it is not an OTF)" % src_path)
    order = font.getGlyphOrder()
    gs = font.getGlyphSet()
    glyphs = {}
    for name in order:
        pen = TTGlyphPen(gs)
        gs[name].draw(Cu2QuPen(
            pen, max_err=CFF_TO_QUADRATIC_MAX_ERR,
            reverse_direction=True))
        glyphs[name] = pen.glyph()
    glyf = newTable("glyf")
    glyf.glyphs = glyphs
    glyf.glyphOrder = order
    loca = newTable("loca")
    loca.locations = [0] * (len(order) + 1)
    del font["CFF "]
    # VORG documents vertical origins for CFF rasterizers; with a glyf
    # table pdfTeX uses vmtx only.  Drop it (it is CFF-specific metadata).
    if "VORG" in font:
        del font["VORG"]
    font["glyf"] = glyf
    font["loca"] = loca
    font["maxp"].numGlyphs = len(order)
    font["maxp"].version = 1.0
    font["head"].glyphDataFormat = 0
    font["head"].created = FIXED_DATE
    font["head"].modified = FIXED_DATE
    # fontTools overwrites head.modified with the wall clock at save time
    # unless recalcTimestamp is turned off (this fontTools version takes
    # it as a constructor/saveFile flag, not a save() kwarg); otherwise the
    # output would not be byte-reproducible.
    font.recalcTimestamp = False
    font.save(out_ttf)
    return out_ttf

def license_text_from(font):
    lines = []
    for nid, what in ((0, "copyright"), (13, "license")):
        v = font["name"].getDebugName(nid)
        if v:
            lines.append("%s: %s" % (what, v))
    if not lines:
        lines.append("license: (source font name table has no "
                     "copyright/license entries)")
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fontset",
                    choices=["ipaex", "ipa", "haranoaji", "custom"],
                    default="ipaex")
    ap.add_argument("--mincho", help="mincho TTF (custom fontset)")
    ap.add_argument("--gothic", help="gothic TTF (custom fontset)")
    ap.add_argument("--outdir", default="fonts/pdftex")
    ap.add_argument("--profile", default=None)
    ap.add_argument("--shard-size", type=int, default=255)
    ap.add_argument("--print-manifest", action="store_true")
    args = ap.parse_args()

    if args.print_manifest:
        # The Makefile asks for the full output list of the default
        # fontsets (profiles + every aux vertical shard + the HaranoAji
        # horizontal conversions), so its grouped target depends on real
        # file names instead of a wildcard over existing files (a wildcard
        # is empty on a fresh checkout and would skip the build entirely).
        names = set()
        for fslabel in ("ipaex", "ipa", "haranoaji"):
            names.add("jlreq-pdftex-fonts-%s.def" % fslabel)
            if fslabel == "haranoaji":
                for f in ("mincho", "mincho-bold", "gothic", "gothic-bold"):
                    names.add("haranoaji-%s-ttf.ttf" % f)
            for fam in ("mc", "gt"):
                for shard in range(4):
                    base = "jlreqv-%s-%s-%02d" % (fslabel, fam, shard)
                    names.add(base + ".ttf")
                    names.add(base + ".enc")
                    names.add(base + ".tfm")
        for n in sorted(names):
            print(n)
        return 0

    if args.fontset == "custom":
        if not args.mincho or not args.gothic:
            raise SystemExit("make_pdftex_fonts.py: --fontset custom "
                             "requires --mincho and --gothic")
        mincho, gothic = args.mincho, args.gothic
    else:
        mincho = kpsewhich(FONTSETS[args.fontset]["mincho"])
        gothic = kpsewhich(FONTSETS[args.fontset]["gothic"])

    os.makedirs(args.outdir, exist_ok=True)
    profile = args.profile
    if profile is None:
        profile = ("jlreq-pdftex-fonts-%s.def"
                   % ("ipaex" if args.fontset == "ipaex" else args.fontset))
    profile_path = os.path.join(args.outdir, profile)

    fslabel = {"ipaex": "ipaex", "ipa": "ipa",
               "haranoaji": "haranoaji"}.get(args.fontset, "custom")
    families = {}
    license_notes = []
    horizontal = []
    for fam, label, src in (("mc", "mc", mincho), ("gt", "gt", gothic)):
        shards, font = build_family(label, fslabel, src, args.outdir,
                                    args.shard_size)
        families[fam] = shards
        license_notes.append("== %s (%s) ==" % (label, os.path.basename(src)))
        license_notes.append(license_text_from(font))
        licpath = os.path.join(args.outdir, "LICENSE-aux-%s-%s.txt"
                               % (fslabel, label))
        with open(licpath, "w", encoding="utf-8") as fh:
            fh.write("Auxiliary vertical font for the jlreq pdfTeX backend.\n")
            fh.write("Derived from %s; the glyph outlines are the source "
                     "font's vertical (vert/vrt2) forms.\n" % src)
            fh.write(license_text_from(font) + "\n")
        # haranoaji: the OTF sources are CFF; pdfTeX's horizontal chain
        # (zhmetrics unisong@Unicode@ dynamic TFMs + pdfmapline) embeds a
        # TrueType file, and ttf2tfm cannot read CFF.  Emit the full-font
        # quadratic conversions alongside the aux shards.  The bold faces
        # (multiweight mnb/gtb chains) are converted the same way.
        if args.fontset == "haranoaji":
            base = os.path.basename(src)
            out = os.path.join(args.outdir, HORIZONTAL_TTFS[label])
            convert_to_ttf(src, out)
            horizontal.append(out)
            bold_src = os.path.join(
                os.path.dirname(src),
                base.replace("-Regular.otf", "-Bold.otf"))
            if not os.path.exists(bold_src):
                raise SystemExit(
                    "make_pdftex_fonts.py: haranoaji needs %s (via the "
                    "haranoaji package); not found next to %s"
                    % (os.path.basename(bold_src), base))
            convert_to_ttf(bold_src, os.path.join(
                args.outdir, HORIZONTAL_TTFS[label + "b"]))
            horizontal.append(os.path.join(
                args.outdir, HORIZONTAL_TTFS[label + "b"]))

    # The profile entries want per-shard dicts of the build_family output
    prof_fams = {}
    for fam, shards in families.items():
        prof_fams[fam] = shards
    text = build_profile(prof_fams, profile_path, args.outdir,
                         "\n".join(license_notes))
    sys.stderr.write("make_pdftex_fonts.py %s: wrote %s (%d bytes, "
                     "mc %d shards, gt %d shards"
                     % (GEN_VERSION, profile_path, len(text),
                        len(families["mc"]), len(families["gt"])))
    if horizontal:
        sys.stderr.write("; horizontal TTFs: %s"
                         % ", ".join(os.path.basename(p)
                                     for p in horizontal))
    sys.stderr.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
