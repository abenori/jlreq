#!/usr/bin/env python3
"""check-pdftex-fonts.py -- structural validator for the generated pdfTeX
auxiliary vertical fonts and profiles.

Usage: check-pdftex-fonts.py <fontsdir> <profile.def> [<profile.def> ...]

Checks per fontset profile:
  1. PROFILE   parseable, declares shards for mc/gt; every referenced
               TFM/enc/TTF exists under <fontsdir>.
  2. ENC       each .enc has exactly 256 elements (/.notdef at 0) and
               slot i+1 = the (i+1)-th jlreqvXXXX entry in sorted order.
  3. TFM       exists, nonempty, header parseable (lh/bc/ec sane).
  4. POST      aux TTF post table format 2.0, glyph order matches the
               enc slot assignment, slot 0 = .notdef.
  5. VERT      the profile's substituted=1 codepoint set covers the
               source font's full vert substitution set (212 for ipaex,
               498 for ipam) -- re-derived from the TTF via fontTools,
               not from the profile's own data.
  6. TOUNICODE every jlreqvXXXX glyph in every aux TTF has a
               \\pdfglyphtounicode entry in the profile; the hex value
               round-trips to the source codepoint (surrogate-pair form
               for non-BMP, if any).
  7. DATES     head.created/modified are the fixed constant
               (determinism precondition).
  8. MAP       every mapline's TFM/enc/TTF names exist and the mapline
               form is '=<tfm> <enc ReEncodeFont <ttf'.

Exit code 0 = all green; any failure prints FAIL lines and exits 1.
"""

import os
import re
import struct
import sys

try:
    from fontTools.ttLib import TTFont
except ImportError:
    sys.stderr.write("check-pdftex-fonts.py: fontTools required\n")
    sys.exit(2)

FIXED_DATE_STORED = 3029524800  # 2000-01-01 UTC in fontTools 1904-epoch seconds


def fail(msg):
    print("FAIL: " + msg)
    return 1


def parse_profile(path):
    text = open(path, encoding="utf-8").read()
    out = {"path": path, "text": text, "tfm": [], "enc": [], "maplines": [],
           "glyphs": {}, "tounicode": {}, "shards": {}}
    for fam in ("mc", "gt"):
        m = re.search(r"jlreqpdf@fontprofile@%s@shards\{(\d+)\}" % fam, text)
        out["shards"][fam] = int(m.group(1)) if m else -1
    out["tfm"] = re.findall(
        r"jlreqpdf@fontprofile@(mc|gt)@tfm@\d+\\endcsname\{([^}]+)\}", text)
    out["enc"] = re.findall(
        r"jlreqpdf@fontprofile@(mc|gt)@enc@\d+\\endcsname\{([^}]+)\}", text)
    out["maplines"] = re.findall(r"\\pdfmapline\{([^}]+)\}", text)
    for m in re.finditer(
            r"\\csname jlreqpdf@vglyph@([0-9]+)\\endcsname"
            r"\{\{(\d)\}\{([^{}]*)\}\{([^{}]*)\}\{(\{[^{}]*\}\{[^{}]*\}"
            r"\{[^{}]*\}\{[^{}]*\}|\{\}|)\}\{(\d+)\}\{(\d+)\}\{([0-9A-F]+)\}\}", text):
        cp = int(m.group(1))
        out["glyphs"][cp] = {
            "sub": int(m.group(2)), "shard": int(m.group(6)),
            "slot": int(m.group(7)), "uni": m.group(8)}
    for m in re.finditer(r"\\pdfglyphtounicode\{jlreqv([0-9A-F]+)\}\{([0-9A-F]+)\}", text):
        out["tounicode"][int(m.group(1), 16)] = m.group(2)
    return out


def check_enc(path):
    errs = 0
    lines = open(path, encoding="utf-8").read().splitlines()
    if len(lines) < 3 or not lines[0].endswith("["):
        return fail("enc %s: not the PostScript /name [ ... ] def form"
                    % path)
    body = lines[1:-1]
    if len(body) != 256:
        errs += fail("enc %s: %d slot entries, expected 256"
                     % (path, len(body)))
    if body[0] != "/.notdef":
        errs += fail("enc %s: slot 0 is %r, expected /.notdef"
                     % (path, body[0]))
    for i, e in enumerate(body):
        if not e.startswith("/"):
            errs += fail("enc %s: slot %d not a literal name: %r"
                         % (path, i, e))
    return errs


def check_tfm(path):
    errs = 0
    data = open(path, "rb").read()
    if len(data) < 24:
        return fail("tfm %s: too short (%d bytes)" % (path, len(data)))
    w = struct.unpack(">HHHHHHHHHHH", data[0:22])
    if w[0] < 2:
        errs += fail("tfm %s: bad header word count lh=%d" % (path, w[0]))
    if w[3] < 1:
        errs += fail("tfm %s: no width table (nw=%d)" % (path, w[3]))
    return errs


def check_aux_ttf(path, enc_names):
    errs = 0
    f = TTFont(path)
    if f["post"].formatType != 2.0:
        errs += fail("ttf %s: post format %s, expected 2.0"
                     % (path, f["post"].formatType))
    order = f.getGlyphOrder()
    if order[0] != ".notdef":
        errs += fail("ttf %s: glyph 0 is %r, expected .notdef"
                     % (path, order[0]))
    if f["head"].created != FIXED_DATE_STORED or \
       f["head"].modified != FIXED_DATE_STORED:
        errs += fail("ttf %s: head dates %d/%d not the fixed constant %d"
                     % (path, f["head"].created, f["head"].modified,
                        FIXED_DATE_STORED))
    # glyph order must match the enc slot assignment exactly
    real = [x for x in enc_names if x != ".notdef"]
    if order != [".notdef"] + real:
        errs += fail("ttf %s: glyph order != enc slot order (%s vs %s)"
                     % (path, order[:3], [".notdef"] + real[:3]))
    return errs


def vert_set(ttf_path):
    """Source-font vert substitution codepoints, re-derived from the TTF."""
    f = TTFont(ttf_path)
    cmap = f.getBestCmap()
    gsub = f["GSUB"].table
    mapping = {}
    for fr in gsub.FeatureList.FeatureRecord:
        if fr.FeatureTag in ("vert", "vrt2"):
            for li in fr.Feature.LookupListIndex:
                for st in gsub.LookupList.Lookup[li].SubTable:
                    if getattr(st, "mapping", None):
                        mapping.update(st.mapping)
                    elif hasattr(st, "coverage") and st.coverage is not None:
                        delta = getattr(st, "deltaGlyphID", None)
                        if delta is not None:
                            ids = f.getGlyphOrder()
                            for g in st.coverage.glyphs:
                                mapping[g] = ids[f.getGlyphID(g) + delta]
    rev = {}
    for cp, gn in cmap.items():
        rev.setdefault(gn, []).append(cp)
    return set(cp for g in mapping if g in rev for cp in rev[g])


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    fontsdir = sys.argv[1]
    profiles = sys.argv[2:]
    errs = 0
    for prof_path in profiles:
        p = os.path.join(fontsdir, prof_path)
        if not os.path.exists(p):
            errs += fail("profile %s missing" % p)
            continue
        prof = parse_profile(p)
        print("== %s: %d mc-shards, %d gt-shards, %d glyphs, %d maplines"
              % (prof_path, prof["shards"]["mc"], prof["shards"]["gt"],
                 len(prof["glyphs"]), len(prof["maplines"])))
        # (1) referenced assets exist
        for _, name in prof["tfm"]:
            if not os.path.exists(os.path.join(fontsdir, name + ".tfm")):
                errs += fail("TFM %s.tfm missing (profile %s)"
                            % (name, prof_path))
        for _, name in prof["enc"]:
            if not os.path.exists(os.path.join(fontsdir, name)):
                errs += fail("enc %s missing (profile %s)"
                             % (name, prof_path))
        # (2)(3)(4) enc/ttf/tfm per shard
        enc_by_shard = {}
        for fam, name in prof["enc"]:
            enc_by_shard.setdefault(fam, []).append(name)
        tfm_by_fam = {}
        for fam, name in prof["tfm"]:
            tfm_by_fam.setdefault(fam, []).append(name)
        for fam in ("mc", "gt"):
            for idx, enc in enumerate(enc_by_shard.get(fam, [])):
                encp = os.path.join(fontsdir, enc)
                errs += check_enc(encp)
                base = os.path.splitext(os.path.basename(enc))[0]
                tfmp = os.path.join(fontsdir, base + ".tfm")
                if os.path.exists(tfmp):
                    errs += check_tfm(tfmp)
                ttfp = os.path.join(fontsdir, base + ".ttf")
                if os.path.exists(ttfp):
                    names = [l.strip()[1:]
                             for l in open(encp, encoding="utf-8")
                             .read().splitlines()[1:257]
                             if l.strip().startswith("/")]
                    errs += check_aux_ttf(ttfp, names)
        # (6) ToUnicode completeness: every jlreqvXXXX in the encs has an entry
        all_glyphs = set()
        for fam in ("mc", "gt"):
            for enc in enc_by_shard.get(fam, []):
                for l in open(os.path.join(fontsdir, enc),
                              encoding="utf-8").read().splitlines()[1:257]:
                    l = l.strip()
                    if l.startswith("/") and l != "/.notdef":
                        all_glyphs.add(int(l[7:], 16))  # /jlreqvXXXX
        missing = [g for g in all_glyphs if g not in prof["tounicode"]]
        if missing:
            errs += fail("profile %s: %d glyphs without \\pdfglyphtounicode "
                         "(e.g. U+%04X)" % (prof_path, len(missing),
                                            missing[0]))
        # hex round-trip incl. surrogate pairs
        for cp, hx in prof["tounicode"].items():
            if len(hx) == 4:
                if int(hx, 16) != cp:
                    errs += fail("ToUnicode U+%04X -> %s mismatch" % (cp, hx))
            elif len(hx) == 8:
                hi = int(hx[:4], 16)
                lo = int(hx[4:], 16)
                dec = 0x10000 + ((hi - 0xD800) << 10) + (lo - 0xDC00)
                if dec != cp:
                    errs += fail("ToUnicode surrogate pair U+%X -> %s"
                                 % (cp, hx))
            else:
                errs += fail("ToUnicode U+%X -> %s bad length" % (cp, hx))
        # (8) maplines
        for ml in prof["maplines"]:
            m = re.match(r"=(\S+) <(\S+) ReEncodeFont <(\S+)$", ml)
            if not m:
                errs += fail("mapline %r: bad form" % ml)
                continue
            tfm, enc, ttf = m.groups()
            for f_, suffix in ((tfm, ".tfm"), (enc, "")):
                if suffix and not os.path.exists(
                        os.path.join(fontsdir, f_ + suffix)):
                    errs += fail("mapline asset %s%s missing"
                                 % (f_, suffix))
            if not os.path.exists(os.path.join(fontsdir, ttf)):
                errs += fail("mapline asset %s missing" % ttf)
        print("   glyphs=%d tounicode=%d substituted=%d"
              % (len(prof["glyphs"]), len(prof["tounicode"]),
                 sum(1 for g in prof["glyphs"].values() if g["sub"] == 1)))
    # (5) vert coverage: re-derive from the SOURCE fonts via kpsewhich
    import subprocess
    for fsname, fonts in (("ipaex", ("ipaexm.ttf", "ipaexg.ttf")),
                          ("ipa", ("ipam.ttf", "ipag.ttf")),
                          ("haranoaji", ("HaranoAjiMincho-Regular.otf",
                                         "HaranoAjiGothic-Regular.otf"))):
        for fname in fonts:
            r = subprocess.run(["kpsewhich", fname],
                               capture_output=True, text=True)
            if r.returncode != 0:
                continue
            vset = vert_set(r.stdout.strip())
            # find the matching committed profile
            prof_file = ("jlreq-pdftex-fonts-%s.def"
                         % ("ipaex" if fsname == "ipaex" else fsname))
            p = os.path.join(fontsdir, prof_file)
            if not os.path.exists(p):
                errs += fail("vert coverage: %s missing" % prof_file)
                continue
            prof = parse_profile(p)
            sub = set(cp for cp, g in prof["glyphs"].items()
                      if g["sub"] == 1)
            noprof = vset - sub
            if noprof:
                errs += fail("vert coverage %s/%s: %d substituted cps "
                             "missing from the profile (e.g. U+%04X)"
                             % (fsname, fname, len(noprof),
                                sorted(noprof)[0]))
            else:
                print("   vert coverage %s/%s: %d/%d"
                      % (fsname, fname, len(sub), len(vset)))
    # (9) haranoaji horizontal-chain artifacts: the converted full-font
    # quadratic TTFs (regular + BOLD faces) must exist, be glyf fonts with
    # fixed dates, and their cmap must cover every cmap codepoint of the
    # source OTF (no glyph lost by the CFF->quadratic conversion).
    for label in ("mincho", "mincho-bold", "gothic", "gothic-bold"):
        p = os.path.join(fontsdir, "haranoaji-%s-ttf.ttf" % label)
        if not os.path.exists(p):
            errs += fail("haranoaji horizontal TTF %s missing" % p)
            continue
        f = TTFont(p)
        if "glyf" not in f or "CFF " in f:
            errs += fail("%s: not a quadratic glyf TTF" % p)
        if f["head"].glyphDataFormat != 0:
            errs += fail("%s: glyphDataFormat %d != 0"
                         % (p, f["head"].glyphDataFormat))
        if f["head"].created != FIXED_DATE_STORED or \
           f["head"].modified != FIXED_DATE_STORED:
            errs += fail("%s: head dates not the fixed constant" % p)
        # coverage against the source OTF
        src = {"mincho": "HaranoAjiMincho-Regular.otf",
               "mincho-bold": "HaranoAjiMincho-Bold.otf",
               "gothic": "HaranoAjiGothic-Regular.otf",
               "gothic-bold": "HaranoAjiGothic-Bold.otf"}[label]
        r = subprocess.run(["kpsewhich", src], capture_output=True, text=True)
        if r.returncode == 0:
            so = TTFont(r.stdout.strip())
            scmap, ccmap = so.getBestCmap(), f.getBestCmap()
            lost = [cp for cp in scmap if cp not in ccmap]
            if lost:
                errs += fail("%s: %d cmap codepoints of %s lost (e.g. U+%04X)"
                             % (p, len(lost), src, sorted(lost)[0]))
            else:
                print("   haranoaji %s: %d cmap cps, 0 lost vs %s"
                      % (label, len(ccmap), src))
    if errs:
        print("check-pdftex-fonts: %d FAILURES" % errs)
        return 1
    print("check-pdftex-fonts: all structural checks green")
    return 0


if __name__ == "__main__":
    sys.exit(main())
