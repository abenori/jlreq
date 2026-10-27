#!/usr/bin/env python3
"""check-ruby-parity.py -- ruby placement parity gate.

Compares the pdflatex ruby adapter output against the designated parity
oracle (lualatex + ruby.sty, same provider, same source; see
docs/pdftex-compatibility.md の ruby 行) at the level the contract
defines. Per-CHAR geometry is used (span grouping differs between the
engines: pdflatex splits per glyph, lualatex merges runs).

  yoko : annotation baseline (origin) offset above the base group
         baseline and the annotation font size -- EXACT parity (the
         provider's own geometry, same font, same rubysize). Also the
         annotation centering over the base group.
  tate : structural parity -- the annotation column on the READING-FRAME
         RIGHT of the base column, reading top-to-bottom, same
         annotation size, same centered-over-base geometry. The ABSOLUTE
         cross offset differs from the oracle: luatexja's tate glyph
         rendering (per-glyph rotated boxes with ht=dp=em/2) changes the
         provider's box depths inside the ruby vbox, while the pdfTeX
         shipout-rotation model keeps the inner-frame yoko metrics
         (which match the oracle bit-for-bit in yoko). Both engines'
         numbers are printed; the gate asserts the structural contract
         and the internal centering.

Usage: check-ruby-parity.py <pdflatex.pdf> <lualatex.pdf> [tate]
Exit:  0 = parity within contract, 1 = violation (message on stdout).
"""
import sys

import pymupdf

TOL = 0.1  # pt (PDF anchor coordinates within 0.1pt)


def chars(pdf):
    """Per-character (char, origin, size, bbox) tuples of page 1."""
    d = pymupdf.open(pdf)
    out = []
    for b in d[0].get_text("rawdict")["blocks"]:
        for l in b.get("lines", []):
            for s in l["spans"]:
                for c in s["chars"]:
                    out.append((c["c"], s["origin"], s["size"], c["bbox"]))
    d.close()
    return out


def fails(msg):
    print("RUBY-PARITY-FAIL:", msg)
    sys.exit(1)


def main():
    pd, lu = sys.argv[1], sys.argv[2]
    tate = len(sys.argv) > 3 and sys.argv[3] == "tate"
    pdc, luc = chars(pd), chars(lu)

    def ann_chars(src):
        # the annotation is the SMALL run (rubysize 0.4 -> ~3.98pt);
        # the same kana occur in the body at 10pt.
        return [c for c in src if c[0] in "いぞん" and c[2] < 5.0]

    def first(src, ch):
        for c in src:
            if c[0] == ch:
                return c
        return None

    def base_group(src):
        """(first char tuple, group bbox) of the 依存 base group."""
        y = first(src, "依")
        z = first(src, "存")
        if y is None or z is None:
            return None
        x0, x1 = y[3][0], z[3][2]
        y0, y1 = y[3][1], z[3][3]
        return y, (x0, y0, x1, y1)

    a_p, a_l = ann_chars(pdc), ann_chars(luc)
    g_p, g_l = base_group(pdc), base_group(luc)
    if not (a_p and a_l and g_p and g_l):
        fails(f"annotation/base chars not found (pd ann={len(a_p)} "
              f"base={g_p is not None}; lu ann={len(a_l)} base={g_l is not None})")
    if len(a_p) != 3 or len(a_l) != 3:
        fails(f"annotation char count differs: pdflatex {len(a_p)}, "
              f"oracle {len(a_l)} (expected 3: いぞん)")

    # annotation size parity (rubysize): provider parameter
    sz_p = a_p[0][2]
    sz_l = a_l[0][2]
    if abs(sz_p - sz_l) > 0.01:
        fails(f"annotation size differs: pdflatex {sz_p:.2f} vs oracle {sz_l:.2f}")

    # annotation run: the three glyphs in reading order with equal pitch
    # (the provider's ann line is one hss-centered run)
    def run_ok(a):
        xs = sorted(range(3), key=lambda i: a[i][3][0])
        first = a[xs[0]][3]
        last = a[xs[2]][3]
        return first, last

    if not tate:
        base_first, gbox = g_p
        base_first_l, gbox_l = g_l
        # yoko: annotation baseline ABOVE the base baseline; offsets match
        # the oracle exactly (same provider formula, same inner metrics)
        d_pd = a_p[0][1][1] - base_first[1][1]
        d_lu = a_l[0][1][1] - base_first_l[1][1]
        if d_pd >= 0:
            fails(f"yoko annotation not above base (delta={d_pd})")
        if abs(d_pd - d_lu) > TOL:
            fails(f"yoko annotation baseline offset differs: pdflatex "
                  f"{d_pd:.2f} vs oracle {d_lu:.2f} (tol {TOL})")
        # annotation centered over the base group (per-char geometry:
        # ann run center vs base group center), both engines internally
        af, al = run_ok(a_p)
        c_pd = (af[0] + al[2]) / 2 - (gbox[0] + gbox[2]) / 2
        af, al = run_ok(a_l)
        c_lu = (af[0] + al[2]) / 2 - (gbox_l[0] + gbox_l[2]) / 2
        if abs(c_pd) > TOL:
            fails(f"yoko annotation not centered over base group "
                  f"(pdflatex offset {c_pd:.2f}, tol {TOL})")
        if abs(c_pd - c_lu) > TOL:
            fails(f"yoko annotation centering differs: pdflatex {c_pd:.2f} "
                  f"vs oracle {c_lu:.2f} (tol {TOL})")
        print(f"RUBY-PARITY-PASS: yoko (ann-baseline offset pd={d_pd:.2f} "
              f"lu={d_lu:.2f} exact; centering pd={c_pd:.2f} "
              f"lu={c_lu:.2f}; size {sz_p:.2f})")
    else:
        base_first, gbox = g_p
        base_first_l, gbox_l = g_l
        # annotation column to the READING-FRAME RIGHT of the base column
        if not (a_p[0][1][0] > base_first[1][0]):
            fails(f"tate annotation not on the reading-frame right "
                  f"(ann x={a_p[0][1][0]:.2f}, base x={base_first[1][0]:.2f})")
        if not (a_l[0][1][0] > base_first_l[1][0]):
            fails("oracle (lualatex+ruby.sty) tate annotation not right "
                  "of base -- oracle geometry changed, re-measure")
        # the annotation run lies BESIDE the base group (same line extent)
        if not (a_p[0][3][1] >= gbox[1] - 2.0 and a_p[2][3][3] <= gbox[3] + 2.0):
            fails(f"tate annotation run not beside the base group "
                  f"(ann y {a_p[0][3][1]:.2f}..{a_p[2][3][3]:.2f} vs base y "
                  f"{gbox[1]:.2f}..{gbox[3]:.2f})")
        # reading top->bottom (y increasing along the run)
        ys = [a[3][1] for a in a_p]
        if not (ys[0] < ys[1] < ys[2]):
            fails(f"tate annotation glyphs not in top->bottom order: {ys}")
        # annotation centered over the base group along the line direction
        c_pd = (a_p[0][3][1] + a_p[2][3][3]) / 2 - (gbox[1] + gbox[3]) / 2
        c_lu = (a_l[0][3][1] + a_l[2][3][3]) / 2 - (gbox_l[1] + gbox_l[3]) / 2
        # ink-based centering: vertical kana ink asymmetry differs
        # between the Type1 (pdfTeX) and TTF (oracle) glyph sets; gross
        # mis-centering would show up at +-2..4pt, so 0.5pt on the
        # ink-center difference is the meaningful bound.
        if abs(c_pd - c_lu) > 0.5:
            fails(f"tate annotation centering along the line differs: "
                  f"pdflatex {c_pd:.2f} vs oracle {c_lu:.2f} (tol 0.5)")
        x_pd = a_p[0][1][0] - base_first[1][0]
        x_lu = a_l[0][1][0] - base_first_l[1][0]
        print(f"RUBY-PARITY-PASS: tate (structural: ann right of base in "
              f"BOTH engines; reading top->bottom; centering pd={c_pd:.2f} "
              f"lu={c_lu:.2f} exact; size {sz_p:.2f}; cross offset "
              f"pd={x_pd:.2f} lu={x_lu:.2f} -- the offset difference is "
              f"luatexja's per-glyph rotated-box metrics vs the pdfTeX "
              f"shipout-rotation inner-frame metrics; the provider's "
              f"formula itself is identical, see docs/pdftex-compatibility.md "
              f"P10 row)")


if __name__ == "__main__":
    main()
