#!/usr/bin/env python3
"""check-anchor-parity.py -- PDF-level anchor comparison (tate).

Compares pdfTeX and upLaTeX same-source PDFs at the INK level with
pymupdf, after aligning the あ (first body glyph) origins. Both pages
are already in the reading frame (the pdfTeX rotation architecture
ships the inner galley rotated -90 inside the portrait page, so the
final page IS the reading-frame tate page).

Gate (load-bearing): the BODY glyph run (あ..こ, the first line)
must agree within 0.1pt per glyph -- this is the PDF-level proof of
the savepos/logical-frame contract (the logical frame maps 1:1 onto
ink in both engines).

Reported (not gated): the footnote-area anchors (◆ = footnote-2 text
glyph, ☆ = footnote-1 text glyph) and the inline interlinear mark
openers, whose pd-vs-up residuals are the known footnote/reference-mark
micro-layout differences (the earlier "furniture-derived offset", now quantified:
mark site d≈(+1.49,+7.61)pt, footnote text d≈2.3-5.5pt along the line,
inter-note column spacing 11.458 vs 13.748pt). yoko parity of the same
machinery is 0.006/0.53pt (measured), so these are tate-mark-chain
residuals, tracked in docs/pdftex-internals.md, not savepos defects.

Usage: check-anchor-parity.py <pdflatex.pdf> <uplatex-dvipdfmx.pdf>
Exit 0 iff the body run is within TOL_BODY.
"""
import sys
import pymupdf

TOL_BODY = 0.1   # pt, per body glyph (load-bearing gate)
BODY_RUN = "あいうえおかきくけこ"
ANCHORS = {"◆": "footnote-2 text", "☆": "footnote-1 text"}


def glyph_positions(pdf_path):
    doc = pymupdf.open(pdf_path)
    page = doc[0]
    out = []
    for block in page.get_text("rawdict")["blocks"]:
        for line in block.get("lines", []):
            for span in line.get("spans", []):
                for ch in span.get("chars", []):
                    x0, y0, x1, y1 = ch["bbox"]
                    out.append((ch["c"], (x0 + x1) / 2.0, (y0 + y1) / 2.0))
    doc.close()
    return out


def main():
    pd_pdf, up_pdf = sys.argv[1], sys.argv[2]
    pd = glyph_positions(pd_pdf)
    up = glyph_positions(up_pdf)

    def first_run(glyphs, chars):
        seen = {}
        for c, x, y in glyphs:
            if c in chars and c not in seen:
                seen[c] = (x, y)
        return seen

    pd_body = first_run(pd, BODY_RUN)
    up_body = first_run(up, BODY_RUN)
    missing = [c for c in BODY_RUN if c not in pd_body or c not in up_body]
    if missing:
        raise SystemExit(f"missing body glyphs: {missing}")
    pa, ua = pd_body["あ"], up_body["あ"]

    worst = 0.0
    report = []
    for c in BODY_RUN:
        dx = (pd_body[c][0] - pa[0]) - (up_body[c][0] - ua[0])
        dy = (pd_body[c][1] - pa[1]) - (up_body[c][1] - ua[1])
        dist = (dx * dx + dy * dy) ** 0.5
        worst = max(worst, dist)
        report.append(f"{c}:d={dist:.4f}pt")
    print("BODY-RUN: worst per-glyph |d| = %.4fpt (tol %.1fpt)" % (worst, TOL_BODY))
    print("  " + " ".join(report))

    pd_a = first_run(pd, set(ANCHORS))
    up_a = first_run(up, set(ANCHORS))
    for c, name in ANCHORS.items():
        if c in pd_a and c in up_a:
            dx = (pd_a[c][0] - pa[0]) - (up_a[c][0] - ua[0])
            dy = (pd_a[c][1] - pa[1]) - (up_a[c][1] - ua[1])
            print(f"ANCHOR {name}({c}): pd_rel=({pd_a[c][0]-pa[0]:.3f},"
                  f"{pd_a[c][1]-pa[1]:.3f}) up_rel=({up_a[c][0]-ua[0]:.3f},"
                  f"{up_a[c][1]-ua[1]:.3f}) d=({dx:+.3f},{dy:+.3f}) "
                  f"[reported: tate footnote micro-layout residual]")

    if worst > TOL_BODY:
        print(f"ANCHOR-FAIL: body run exceeds {TOL_BODY}pt")
        return 1
    print(f"ANCHOR-PASS: body run within {TOL_BODY}pt")
    return 0


if __name__ == "__main__":
    sys.exit(main())
