#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""endadjust-lineend.tex の行末追込み（end_adjust）4エンジンparity検証。

検証の歴史: 本ゲートは tests/reference/kinsoku-lines.md に記録された
「pdfTeXバックエンドは 」 を次行へ落とす (xMax≈143.22pt)」既知不良
を検出するために作られたが、\jlreqpdf@addendadj の
修正により既に現行HEADでparityが成立している
(実測: hsize 60–80pt の全ケースで pdflatex と p/u/l の
1行目 xMax 差は ≤0.01pt)。よって本ゲートは通常の回帰ゲートとして
扱い、行末候補列(kern/penalty)再構成が参照から静かに離れない
よう 0.1pt で固定検査する。

判定: pdflatex の1行目 xMax が参照3エンジンの最大値と TOL (0.1pt)
以内で一致することを要求する。

Usage: check-endadjust-parity.py <pdflatex.pdf> <platex.pdf> <uplatex.pdf> <lualatex.pdf>
       （p/u の .pdf は DVI を dvipdfmx で変換したもの。順序固定）
exit 0 = PASS / exit 1 = FAIL
"""
import subprocess
import sys

ENGINES = ("pdflatex", "platex", "uplatex", "lualatex")

TOL = 0.1   # pt; 参照との許容差（実測: hsize 60–80pt 全ケース
            # で pdflatex と p/u/l の差は ≤0.01pt。
            # 行末候補列再構成が参照から静かに離れないよう検査）

def line1_xmax(pdf):
    """pdftotext -bbox の word 出力から最上位行（yMin 最小）の xMax を得る。"""
    out = subprocess.run(["pdftotext", "-bbox", pdf, "-"],
                         capture_output=True, text=True).stdout
    words = []
    for m in __import__("re").finditer(
            r'xMin="([0-9.]+)" yMin="([0-9.]+)" xMax="([0-9.]+)"', out):
        words.append((float(m.group(2)), float(m.group(1)),
                      float(m.group(3))))
    if not words:
        raise SystemExit("ENDADJUST-PARITY-FAIL: no words extracted from %s" % pdf)
    top_y = min(w[0] for w in words)
    row = [w for w in words if abs(w[0] - top_y) < 3.0]
    row.sort(key=lambda w: w[1])
    return row[-1][2], row[-1][1]


def main():
    if len(sys.argv) != 5:
        print("ENDADJUST-PARITY-FAIL: usage: check-endadjust-parity.py "
              "<pdflatex.pdf> <platex.pdf> <uplatex.pdf> <lualatex.pdf>")
        return 1
    xmax = {}
    xmin = {}
    for eng, pdf in zip(ENGINES, sys.argv[1:]):
        xmax[eng], xmin[eng] = line1_xmax(pdf)
    ref = max(xmax[e] for e in ENGINES[1:])
    print("ENDADJUST-PARITY line1 xMax: pdflatex=%.3f  platex=%.3f  "
          "uplatex=%.3f  lualatex=%.3f  (reference max=%.3f, tol=%.2f)"
          % (xmax["pdflatex"], xmax["platex"], xmax["uplatex"],
             xmax["lualatex"], ref, TOL))
    delta = abs(xmax["pdflatex"] - ref)
    if delta <= TOL:
        print("ENDADJUST-PARITY-PASS: pdflatex line-1 end matches reference "
              "within %.2fpt (delta=%.3f)" % (TOL, delta))
        return 0
    print("ENDADJUST-PARITY-FAIL: pdflatex line-1 xMax %.3fpt deviates from "
          "reference %.3fpt by %.3fpt (> %.2fpt) -- end_adjust line-end "
          "squeeze is missing (」 falls to next line)"
          % (xmax["pdflatex"], ref, delta, TOL))
    return 1


if __name__ == "__main__":
    sys.exit(main())
