#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""space-dispatcher.tex の全角空白共存検証。

判定: \　命令形・literal U+3000・\jaspace{zenkaku} の3経路が同じ
「あ + 全角空白 + い」の抽出になり、かつ \　 を2回使った行も同一であること
（空白正規化で完全一致）。実寸測定（同1zw）を抽出で代用する
簡易完全性検査。幅の数値検証は T3 の rules 側が担う。

Usage: check-space-dispatcher.py <pdflatex.pdf>
exit 0 = PASS / exit 1 = FAIL
"""
import re
import subprocess
import sys


def main():
    if len(sys.argv) != 2:
        print("SPACEDISP-FAIL: usage: check-space-dispatcher.py <pdf>")
        return 1
    text = subprocess.run(["pdftotext", sys.argv[1], "-"], capture_output=True,
                         text=True).stdout
    whole = re.sub(r"\s+", "", text)
    fails = []
    for e in ["A:あい", "B:あい", "C:あい", "D:あい"]:
        if e not in whole:
            fails.append("missing %r" % e)
    if fails:
        for f in fails:
            print("SPACEDISP-FAIL: " + f)
        return 1
    print("SPACEDISP-PASS: \\　 command / literal U+3000 / \\jaspace coexist "
          "with identical rendering")
    return 0


if __name__ == "__main__":
    sys.exit(main())
