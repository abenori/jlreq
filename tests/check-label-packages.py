#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""label-packages.tex のパッケージ横断ラベル解決検証。

判定: pdftotext 抽出がすべての参照値を正しく含むこと、および
ログ内 LABELPKG-EDEF-OK（\getrefnumber の edef 内完全展開）があること。

Usage: check-label-packages.py <pdflatex.pdf> <pdflatex.log>
exit 0 = PASS / exit 1 = FAIL
"""
import re
import subprocess
import sys


def main():
    if len(sys.argv) != 3:
        print("LABELPKG-FAIL: usage: check-label-packages.py <pdf> <log>")
        return 1
    pdf, log = sys.argv[1], sys.argv[2]
    text = subprocess.run(["pdftotext", pdf, "-"], capture_output=True,
                          text=True).stdout
    logtext = open(log, encoding="utf-8", errors="replace").read()
    fails = []
    # 参照値の完全一致（空白正規化後）
    norm = re.sub(r"\s+", "", text)
    for needle, label in [
        ("REF:1—1—1—1", "ref/pageref star両形"),
        ("EQREF:(1)", "eqref"),
        ("AUTOREF:section1", "autoref"),
        ("NAMEREF:日本語ラベルの検証", "nameref"),
        ("CREF:section1—page1", "cref/cpageref"),
        ("HYPER:リンク", "hyperref link"),
        ("COUNTERREF:1", "setcounterref"),
        ("GETREF:1", "getrefnumber"),
        ("ASCII:1—section1", "ascii label"),
    ]:
        if needle not in norm:
            fails.append("%s: expected %r" % (label, needle))
    if "LABELPKG-EDEF-OK" in logtext:
        print("LABELPKG-EDEF-PASS: getrefnumber expandable in edef")
    else:
        fails.append("getrefnumber not expandable in edef (LABELPKG-EDEF-OK "
                     "missing from log)")
    if fails:
        for f in fails:
            print("LABELPKG-FAIL: " + f)
        return 1
    print("LABELPKG-PASS: all package surfaces resolve the Japanese label")
    return 0


if __name__ == "__main__":
    sys.exit(main())
