#!/usr/bin/env python3
"""check-footnote-parity.py -- footnote-block parity gate (tate).

Compares the pdfTeX and upLaTeX same-source PDFs at the INK level with
pymupdf, after aligning the あ (first body glyph) origins (the same
alignment contract as check-anchor-parity.py; both pages are already
in the reading frame).

Anchors (the fixture footnote-parity.tex):
  あ = the first body glyph (the shared logical origin)
  ☆ = the first glyph of the footnote text (fn text column head)
  （ = TWO occurrences per page: the in-body footnote mark （１）
       (reported) and the footnote-area opener （１） prefix of the
       fn text (gated). The fn-area one is the occurrence with the
       SMALLER cross position (the fn block sits proximal of the
       body column in tate).
  rule = the thin vertical drawing (the footnote rule)

Gated (all <= TOL = 0.5pt, cross positions are page-x of the ink left
edge relative to the あ origin; the rule->text gap is rule_x - text_x):
  - fn text column head (☆)
  - fn opener （ cross position
  - fn rule cross position
  - rule length
  - rule -> text column gap
Reported (not gated): the reading-direction position of the fn text
head and the in-body mark （ cross position.

Usage: check-footnote-parity.py <pdflatex.pdf> <uplatex-dvipdfmx.pdf>
Exit 0 iff every gated comparison is within TOL.
"""
import sys
import pymupdf

TOL = 0.5  # pt


def glyph_boxes(pdf_path):
    doc = pymupdf.open(pdf_path)
    out = []
    for block in doc[0].get_text("rawdict")["blocks"]:
        for line in block.get("lines", []):
            for span in line.get("spans", []):
                for ch in span.get("chars", []):
                    out.append((ch["c"], ch["bbox"]))
    doc.close()
    return out


def first(glyphs, c):
    for cc, bb in glyphs:
        if cc == c:
            return bb
    return None


def occurrences(glyphs, c):
    return [bb for cc, bb in glyphs if cc == c]


def fn_area_bracket(glyphs):
    """The fn-area （: the occurrence with the smaller cross position
    (the fn block is proximal of the body column in tate)."""
    occ = occurrences(glyphs, "（")
    if not occ:
        return None
    return min(occ, key=lambda bb: bb[0])


def body_mark_bracket(glyphs):
    occ = occurrences(glyphs, "（")
    if not occ:
        return None
    return max(occ, key=lambda bb: bb[0])


def fn_rule(pdf_path):
    """The footnote rule: the thin vertical drawing near the fn area."""
    doc = pymupdf.open(pdf_path)
    best = None
    for dr in doc[0].get_drawings():
        r = dr["rect"]
        if r.x1 - r.x0 < 1.0 and 50 < r.y1 - r.y0 < 300:
            if best is None or (r.y1 - r.y0) > (best.y1 - best.y0):
                best = r
    doc.close()
    return best


def main():
    pd_pdf, up_pdf = sys.argv[1], sys.argv[2]
    pd = glyph_boxes(pd_pdf)
    up = glyph_boxes(up_pdf)
    pd_a, up_a = first(pd, "あ"), first(up, "あ")
    pd_star, up_star = first(pd, "☆"), first(up, "☆")
    pd_op, up_op = fn_area_bracket(pd), fn_area_bracket(up)
    pd_bm, up_bm = body_mark_bracket(pd), body_mark_bracket(up)
    missing = []
    for name, box in [("あ", pd_a), ("あ(up)", up_a), ("☆", pd_star),
                      ("☆(up)", up_star), ("fn（", pd_op),
                      ("fn（(up)", up_op), ("body（", pd_bm),
                      ("body（(up)", up_bm)]:
        if box is None:
            missing.append(name)
    if missing:
        raise SystemExit(f"missing anchors: {missing}")

    pd_rule, up_rule = fn_rule(pd_pdf), fn_rule(up_pdf)
    if pd_rule is None or up_rule is None:
        raise SystemExit("missing footnote rule drawing")

    # cross positions relative to the body anchor (あ ink left edge)
    def rel(bb, a):
        return (bb[0] - a[0], bb[1] - a[1])

    pd_s, up_s = rel(pd_star, pd_a), rel(up_star, up_a)
    pd_o, up_o = rel(pd_op, pd_a), rel(up_op, up_a)
    pd_bmr, up_bmr = rel(pd_bm, pd_a), rel(up_bm, up_a)
    pd_r = pd_rule.x0 - pd_a[0]
    up_r = up_rule.x0 - up_a[0]
    pd_len = pd_rule.y1 - pd_rule.y0
    up_len = up_rule.y1 - up_rule.y0

    checks = [
        ("fn-text-head (☆) cross", pd_s[0], up_s[0]),
        ("fn-opener （ cross", pd_o[0], up_o[0]),
        ("fn-rule cross", pd_r, up_r),
        ("fn-rule length", pd_len, up_len),
        ("rule->text gap", pd_r - pd_s[0], up_r - up_s[0]),
    ]
    worst = 0.0
    fail = False
    print("FOOTNOTE-PARITY (rel to あ):")
    for name, pv, uv in checks:
        d = pv - uv
        worst = max(worst, abs(d))
        ok = abs(d) <= TOL
        fail = fail or not ok
        print(f"  {name}: pd={pv:.3f} up={uv:.3f} d={d:+.3f} "
              f"{'OK' if ok else 'FAIL'} (tol {TOL})")
    print(f"  [reported] fn-text reading pos: pd={pd_s[1]:.3f} "
          f"up={up_s[1]:.3f} d={pd_s[1]-up_s[1]:+.3f}")
    print(f"  [reported] in-body mark （ cross: pd={pd_bmr[0]:.3f} "
          f"up={up_bmr[0]:.3f} d={pd_bmr[0]-up_bmr[0]:+.3f}")
    if fail:
        print(f"FOOTNOTE-PARITY-FAIL: worst |d| = {worst:.3f}pt")
        return 1
    print(f"FOOTNOTE-PARITY-PASS: worst |d| = {worst:.3f}pt")
    return 0


if __name__ == "__main__":
    sys.exit(main())
