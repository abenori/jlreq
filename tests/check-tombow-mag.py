#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""tests/fixtures/pdflatex-coexist/mag-tombow.tex (\mag=1200) の PDF を検査する。

pdfTeX は shipout ボックスの cm 座標を出荷時に \mag 倍するため、トンボ描画が
uplatex+dvipdfmx 経路（ストック左上から全描画が単純 \mag 倍拡大）と一致する
必要十分条件は、描画の stored 座標が \mag=1000 と一致することである。
jlreq-trimmarks-pdftex.def の \put 原点補正前は先頭罫線 cm が
(35.05, 922.444) ではなく (47.05, 910.443) になり (\hoffset/\voffset
分の混入)、ink-bbox が uplatex の 42 42 846 1141 に対し 56 27 860 1127 に
ずれていた（実測値）。

検査項目 (先頭ページのコンテントストリーム):
  1. ページ CTM が 1.2 倍 (\mag=1200 が実際に効いていることの確認、
     退化防止)
  2. トンボ罫線先頭 cm が (35.05, 922.444) ± 0.05
exit 0 = PASS / exit 1 = FAIL (標準出力に判定行)
"""
import re
import sys
import zlib

EXPECT_X, EXPECT_Y, TOL = 35.05, 922.444, 0.05


def inflate_streams(path):
    data = open(path, "rb").read()
    for m in re.finditer(rb"stream\r?\n(.*?)endstream", data, re.S):
        try:
            yield zlib.decompress(m.group(1).rstrip(b"\r\n")).decode("latin-1")
        except zlib.error:
            continue


def main():
    if len(sys.argv) != 2:
        print("TOMBOW-MAG-FAIL: usage: check-tombow-mag.py <pdf>")
        return 1
    for s in inflate_streams(sys.argv[1]):
        if "0.1 w" not in s:
            continue
        mm = re.search(
            r"1 0 0 1 ([\d.]+) ([\d.]+) cm\s*\[\]0 d 0 J 0\.1 w", s
        )
        if mm is None:
            continue
        x, y = float(mm.group(1)), float(mm.group(2))
        ok = abs(x - EXPECT_X) <= TOL and abs(y - EXPECT_Y) <= TOL
        verdict = "TOMBOW-MAG-PASS" if ok else "TOMBOW-MAG-FAIL"
        print(
            "%s: first tombow rule cm = (%.3f, %.3f), expect (%.3f, %.3f) +/- %.2f"
            % (verdict, x, y, EXPECT_X, EXPECT_Y, TOL)
        )
        if not ok:
            return 1
        if "1.2 0 0 1.2 0 0 cm" not in s:
            print("TOMBOW-MAG-FAIL: page CTM is not x1.2 (mag not in effect?)")
            return 1
        print("TOMBOW-MAG-PASS: page CTM is x1.2 (mag=1200 in effect)")
        return 0
    print("TOMBOW-MAG-FAIL: no 0.1pt tombow rule found in content streams")
    return 1


if __name__ == "__main__":
    sys.exit(main())
