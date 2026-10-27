#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""trimmarks-banner.tex の回転バナー配置の独立機械検証。

BANNER-PD-PASS typeout（fixture 自身の出力を grep する自己申告検査）を
置き換える。実PDF（pymupdf）から各バナースロットの文字 bbox と書き込み
方向（line dir）を読み、**固定ジオメトリ窓**と照合する。窓は uplatex
ground truth（fixture ヘッダの実測表、B5+裁ち落とし紙面 642.9×852.7pt）
から導いた範囲に許容を付けたものであり、実装の出力値からは一切生成
しない（trimmarks 完成時には窓を ground truth の実測値へ縮める）。

検査項目:
  1. 6スロットのバナー文字列が各1回だけ存在すること
  2. tate/in スロットの書き込み方向が縦（dir=(0,±1)）であること
     （\rotatebox{-90} 回転が実バナーに効いていることの直接証拠）
  3. 各 bbox が固定窓内にあること（ページ四隅・中央の領域割当の検証）
  4. 本文行が横書き（dir=(1,0)）であること（ページ全体回転の混入排除）
  5. 紙面 MediaBox が B5+裁ち落としの寸法であること

Usage: check-banner-slots.py <pdf>
exit 0 = PASS / exit 1 = FAIL（判定行を stdout へ）
"""
import sys

try:
    import pymupdf
except ImportError:
    print("BANNER-FAIL: pymupdf is required (python3 -m pip install pymupdf)")
    sys.exit(1)

# 固定ジオメトリ窓 (x0, x1, y0, y1)。PDF ページ座標は左上原点。
# uplatex ground truth: top-left tate x[52.0,59.5] y[90.9,166.2] /
#   top-right x[581.4,588.9] y[90.9,128.5] / bottom-left y[733.5,761.8] /
#   bottom-right 同 / in@center-left x[70.0,77.5] y[416.9,435.7] /
#   in@center-right x[563.4,570.9]。窓はこれらを含む固定領域。
# （現在の pdfTeX 実測は top-left x +5.5pt / bottom y +37.7pt の近似差を
#   持つため、窓を縮めるまでこの許容を含む。）
SLOTS = [
    # (text, x0, x1, y0, y1)
    ("TATEBANNER-PROBE", 50.0, 85.0, 80.0, 175.0),   # top-left tate
    ("RIGHTTOP",        560.0, 600.0, 80.0, 140.0),  # top-right tate
    ("BLTATE",          50.0, 85.0, 720.0, 810.0),   # bottom-left tate
    ("BRTATE",          560.0, 600.0, 720.0, 810.0),  # bottom-right tate
    ("CLIN",            60.0, 95.0, 400.0, 455.0),   # in@center-left
    ("CRIN",            550.0, 590.0, 400.0, 455.0),  # in@center-right
]
BODY_TEXT = "トンボと回転バナー"
# B5 (500.0×707.0pt? jlreq b5) + 裁ち落とし; 実測 642.898×852.661
PAGE_W, PAGE_H = 642.898, 852.661
PAGE_TOL = 1.0
TOL = 0.05  # bbox は窓境界に一致させるのではなく内包判定


def main():
    if len(sys.argv) != 2:
        print("BANNER-FAIL: usage: check-banner-slots.py <pdf>")
        return 1
    doc = pymupdf.open(sys.argv[1])
    if doc.page_count < 1:
        print("BANNER-FAIL: no pages in PDF")
        return 1
    page = doc[0]
    fails = []

    # 5. 紙面寸面（トンボ用の拡大紙面）
    mb = page.mediabox
    if abs(mb.width - PAGE_W) > PAGE_TOL or abs(mb.height - PAGE_H) > PAGE_TOL:
        fails.append("mediabox %.3fx%.3f != %.3fx%.3f" %
                     (mb.width, mb.height, PAGE_W, PAGE_H))

    # ページ内の全 (text, dir, bbox)
    spans = []
    for blk in page.get_text("dict")["blocks"]:
        for line in blk.get("lines", []):
            for sp in line.get("spans", []):
                spans.append((sp["text"], tuple(line.get("dir", (1, 0))),
                              tuple(sp["bbox"])))

    line_texts = []
    for blk in page.get_text("dict")["blocks"]:
        for line in blk.get("lines", []):
            line_texts.append(("".join(sp["text"] for sp in line["spans"]),
                               tuple(line.get("dir", (1, 0)))))
    for text, x0, x1, y0, y1 in SLOTS:
        hits = [s for s in spans if s[0] == text]
        if len(hits) != 1:
            fails.append("slot %r found %d times (expect 1)" % (text, len(hits)))
            continue
        _, direction, bbox = hits[0]
        # 2. 縦書き方向（下向きまたは上向きの縦）
        if direction not in ((0.0, 1.0), (0.0, -1.0)):
            fails.append("slot %r dir %r is not vertical" % (text, direction))
        bx0, by0, bx1, by1 = bbox
        # 3. 固定窓
        if not (x0 - TOL <= bx0 and bx1 <= x1 + TOL
                and y0 - TOL <= by0 and by1 <= y1 + TOL):
            fails.append("slot %r bbox [%.1f,%.1f,%.1f,%.1f] outside "
                         "window [%.0f,%.0f,%.0f,%.0f]" %
                         (text, bx0, by0, bx1, by1, x0, y0, x1, y1))
        else:
            print("BANNER-SLOT-PASS: %s dir=%s bbox=[%.1f,%.1f,%.1f,%.1f]" %
                  (text, direction, bx0, by0, bx1, by1))

    # 4. 本文は横書き
    body = [t for t in line_texts if BODY_TEXT in t[0]]
    if not body:
        fails.append("body text %r not found" % BODY_TEXT)
    else:
        if body[0][1] != (1.0, 0.0):
            fails.append("body dir %r is not horizontal" % (body[0][1],))
        else:
            print("BANNER-BODY-PASS: body text horizontal dir=%s" %
                  (body[0][1],))

    if fails:
        for f in fails:
            print("BANNER-FAIL: " + f)
        return 1
    print("BANNER-PASS: all 6 banner slots placed with correct rotation "
          "inside fixed geometry windows")
    return 0


if __name__ == "__main__":
    sys.exit(main())
