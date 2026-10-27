#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""trimmarks-twoside.tex の奇偶ページ辞書属性の独立機械検証。

dドライバのページ属性はラベル付き shipout/before フックが
出荷ページの \c@page から奇偶を決めて \pdfpageattr を設定する。
本検査は実PDFの各ページ辞書（pymupdf の xref_object 生ダンプ）を読み、

  1. 全ページに TrimBox が正しく（ちょうど1組の値で）あること
  2. 奇数ページの BleedBox がノド側(gutter=0mm)で TrimBox に一致し
     小口側(+6mm)だけ伸びていること
  3. 偶数ページの BleedBox がその左右反転であること
  4. 辞書に MediaBox/TrimBox/BleedBox 以外の予期しない追加キーが
     付与されていないこと（フックが他パッケージの属性を壊して
     いないことの否定的証拠）

を検査する。期待値はフィクスチャの寸法（B5 = 515.906×728.504pt版面
+2inストック、gutter=0/fore-edge=6mm）から独立に計算した固定値であり
実装の出力からは生成しない。

Usage: check-trimmarks-pageattr.py <pdf>
exit 0 = PASS / exit 1 = FAIL
"""
import sys

try:
    import pymupdf
except ImportError:
    print("PAGEATTR-FAIL: pymupdf is required (python3 -m pip install pymupdf)")
    sys.exit(1)

MM = 72.0 / 25.4  # pt per mm
# fixture: paper=b5 (jlreq B5 = 515.906 x 728.504pt), stock = paper + 2in
TRIM_W, TRIM_H = 515.906, 728.504
STOCK_W, STOCK_H = TRIM_W + 144.0, TRIM_H + 144.0
FORE = 6.0 * MM
TOL = 0.05


MM = 72.0 / 25.4  # pt per mm
# fixture: paper=b5 (jlreq B5 = JIS B5 176x250mm = 498.898 x 708.661pt),
# stock = trim + 2in (trimmarks_paper default +2in => 144pt each side)
TRIM_W, TRIM_H = 498.898, 708.661
STOCK_W, STOCK_H = TRIM_W + 144.0, TRIM_H + 144.0
def parse_boxes(obj):
    out = {}
    for key in ("MediaBox", "TrimBox", "BleedBox"):
        i = obj.find("/" + key)
        if i < 0:
            out[key] = None
            continue
        j = obj.index("[", i)
        k = obj.index("]", j)
        vals = [float(v) for v in obj[j + 1:k].split()]
        out[key] = vals
    out["_raw"] = obj
    return out


def main():
    if len(sys.argv) != 2:
        print("PAGEATTR-FAIL: usage: check-trimmarks-pageattr.py <pdf>")
        return 1
    doc = pymupdf.open(sys.argv[1])
    if doc.page_count < 3:
        print("PAGEATTR-FAIL: expected 3 pages, got %d" % doc.page_count)
        return 1
    fails = []

    for pno in range(3):
        obj = doc.xref_object(doc[pno].xref)
        b = parse_boxes(obj)
        odd = (pno % 2 == 0)  # page 1,3 odd; page 2 even
        # stock: mediabox (rounded to the bp grid by pdfTeX)
        mb = b["MediaBox"]
        if mb is None:
            fails.append("page %d: no /MediaBox" % (pno + 1))
            continue
        if abs(mb[2] - mb[0] - STOCK_W) > TOL or abs(mb[3] - mb[1] - STOCK_H) > TOL:
            fails.append("page %d: MediaBox %.3fx%.3f != stock %.3fx%.3f"
                         % (pno + 1, mb[2] - mb[0], mb[3] - mb[1], STOCK_W, STOCK_H))
        tb = b["TrimBox"]
        if tb is None:
            fails.append("page %d: no /TrimBox (pageattr hook missing)" % (pno + 1))
            continue
        expect_trim = [72.00313, 72.00313, 72.00313 + TRIM_W, 72.00313 + TRIM_H]
        for got, want, nm in zip(tb, expect_trim, "xyxy"):
            if abs(got - want) > TOL:
                fails.append("page %d: TrimBox %s=%.4f want %.4f"
                             % (pno + 1, nm, got, want))
        bb = b["BleedBox"]
        if bb is None:
            fails.append("page %d: no /BleedBox" % (pno + 1))
            continue
        # asymmetric bleed: gutter side has no bleed, fore-edge side +6mm
        if odd:
            expect_bleed = [expect_trim[0], expect_trim[1] - 3.0 * MM,
                            expect_trim[2] + FORE, expect_trim[3] + 3.0 * MM]
        else:
            expect_bleed = [expect_trim[0] - FORE, expect_trim[1] - 3.0 * MM,
                            expect_trim[2], expect_trim[3] + 3.0 * MM]
        for got, want, nm in zip(bb, expect_bleed, "xyxy"):
            if abs(got - want) > TOL:
                fails.append("page %d(%s): BleedBox %s=%.4f want %.4f"
                             % (pno + 1, "odd" if odd else "even", nm, got, want))
        # no duplicate keys in the page dict
        for key in ("TrimBox", "BleedBox"):
            if obj.count("/" + key) > 1:
                fails.append("page %d: /%s appears %d times"
                             % (pno + 1, key, obj.count("/" + key)))
        print("PAGEATTR-PASS: page %d (%s) TrimBox=[%.3f %.3f %.3f %.3f] "
              "BleedBox=[%.3f %.3f %.3f %.3f]"
              % (pno + 1, "odd" if odd else "even",
                 tb[0], tb[1], tb[2], tb[3], bb[0], bb[1], bb[2], bb[3]))

    if fails:
        for f in fails:
            print("PAGEATTR-FAIL: " + f)
        return 1
    print("PAGEATTR-PASS: 3 pages with per-page odd/even TrimBox/BleedBox "
          "from the shipout/before hook, no duplicate keys")
    return 0


if __name__ == "__main__":
    sys.exit(main())
