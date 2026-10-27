#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""date-boundaries.tex の和暦境界日検証。

判定: pdftotext 抽出（空白正規化）が5境界日+切替の期待値を含むこと。

Usage: check-date-boundaries.py <pdflatex.pdf>
exit 0 = PASS / exit 1 = FAIL
"""
import re
import subprocess
import sys


def main():
    if len(sys.argv) != 2:
        print("DATEBD-FAIL: usage: check-date-boundaries.py <pdf>")
        return 1
    text = subprocess.run(["pdftotext", sys.argv[1], "-"], capture_output=True,
                         text=True).stdout
    norm = re.sub(r"\s+", "", text)
    expected = [
        "A:昭和64年1月7日",
        "B:平成元年1月8日",
        "C:平成31年4月30日",
        "D:令和元年5月1日",
        "E:昭和元年12月24日",
        "F:2019年5月1日",       # \西暦true 切替後
        "G:令和元年5月1日",     # \和暦 復帰後
    ]
    fails = [e for e in expected if e not in norm]
    if fails:
        for f in fails:
            print("DATEBD-FAIL: missing %r" % f)
        return 1
    print("DATEBD-PASS: 5 era boundaries + gan-nen + style toggling correct")
    return 0


if __name__ == "__main__":
    sys.exit(main())
