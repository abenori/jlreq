#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""tcy-basic.tex の縦中横（\tatechuyoko）検証（昇格済み通常ゲート）。

契約（uplatex 同一ソース showbox・PDF bbox 実測で確立）: 縦組み (tate)
で \tatechuyoko{12} は中身を1回だけ yoko frame で組み、
  advance = 1zw、cross extent = 体幅の半分ずつ（中央配置）、
  digit baseline = 進行起点
に正規化した直立（upright）2桁として組む。star 形
\tatechuyoko*{AB} は縦組みでも同一構造、横組みでは透過。
本検査は:

  1. PDF が存在しテキスト '12' 'AB' を含むこと（コンパイル成立の証拠）
  2. '12' が直立2桁として置かれていること（bbox 幅 > 高さ; 縦組み本文の
     横倒しグリフは高さ > 幅になるため、この不等号は向きの直接証拠）

幾何の寸法値検査（1zw 追従・中央割り・baseline 位置）は
tcy-digits.tex のログ内 TATE-PASS 判定が担う（本検査は向きと存在）。

失敗時は理由を出力して exit 1（ランナーはコンパイル失敗と同じ扱い）。

Usage: check-tatechuyoko.py <pdf>
exit 0 = PASS / exit 1 = FAIL
"""
import sys

try:
    import pymupdf
except ImportError:
    print("TCY-FAIL: pymupdf is required")
    sys.exit(1)


def main():
    if len(sys.argv) != 2:
        print("TCY-FAIL: usage: check-tatechuyoko.py <pdf>")
        return 1
    try:
        page = pymupdf.open(sys.argv[1])[0]
    except Exception as exc:
        print("TCY-FAIL: cannot open PDF %s (%s)" % (sys.argv[1], exc))
        return 1
    words = page.get_text("words")  # (x0, y0, x1, y1, text, ...)
    t12 = [w for w in words if w[4] == "12"]
    tab = [w for w in words if w[4] == "AB"]
    fails = []
    if not t12:
        fails.append("text '12' not found (non-star tatechuyoko)")
    else:
        x0, y0, x1, y1 = t12[0][:4]
        w, h = x1 - x0, y1 - y0
        if w > h:
            print("TCY-PASS: '12' upright (bbox %.1fx%.1f, w>h)" % (w, h))
        else:
            fails.append("'12' bbox %.1fx%.1f not upright (w<=h)" % (w, h))
    if not tab:
        fails.append("text 'AB' not found (star tatechuyoko)")
    else:
        x0, y0, x1, y1 = tab[0][:4]
        w, h = x1 - x0, y1 - y0
        if w > h:
            print("TCY-PASS: 'AB' present and horizontal (bbox %.1fx%.1f)"
                  % (w, h))
        else:
            fails.append("'AB' bbox %.1fx%.1f not horizontal (w<=h)" % (w, h))
    if fails:
        for f in fails:
            print("TCY-FAIL: " + f)
        return 1
    print("TCY-PASS: tatechuyoko star/non-star typeset upright in tate")
    return 0


if __name__ == "__main__":
    sys.exit(main())
