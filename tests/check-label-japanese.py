#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""label-japanese.tex の日本語ラベル \ref 解決検証（昇格済みの通常ゲート）。

契約: \label{日本語ラベル} / \ref{日本語ラベル} / \pageref{日本語ラベル}
が upLaTeX/LuaLaTeX と同様に解決する（aux への書込と読込が対称に
正規化される — \jlreqpdf@labelkey）。GREEN ゲート。

判定:
  1. 2パスコンパイル後の aux に当該ラベルの \newlabel 行が存在する。
  2. PDF 抽出テキストが "??" を含まない。
  3. lualatex 同一ソース（2パス）の抽出と同じ節番号 "1" を含む。

Usage: check-label-japanese.py <pdflatex.pdf> <pdflatex.aux> <lualatex.pdf>
exit 0 = PASS / exit 1 = FAIL
"""
import re
import subprocess
import sys

LABEL = "日本語ラベル"


def text(pdf):
    return subprocess.run(["pdftotext", pdf, "-"], capture_output=True,
                          text=True).stdout


def main():
    if len(sys.argv) != 4:
        print("LABEL-JP-FAIL: usage: check-label-japanese.py "
              "<pdflatex.pdf> <pdflatex.aux> <lualatex.pdf>")
        return 1
    d_pdf, d_aux, l_pdf = sys.argv[1], sys.argv[2], sys.argv[3]
    fails = []

    aux = open(d_aux, encoding="utf-8", errors="replace").read()
    # 1. aux のラベル行（key は正規化されていればそのまま見える）
    if re.search(r"\\newlabel\{" + re.escape(LABEL) + r"\}", aux):
        print("LABEL-JP-AUX-PASS: \\newlabel{%s} present in aux" % LABEL)
    else:
        fails.append("aux has no \\newlabel{%s} line (asymmetric key "
                     "normalization); aux=\n%s" % (LABEL, aux.strip()))

    dt = text(d_pdf)
    # 2. 未解決参照
    if "?? " in dt or dt.strip().endswith("??"):
        fails.append("pdflatex PDF contains unresolved ?? reference")
    # 3. lualatex 参照との比較
    lt = text(l_pdf)
    m = re.search(r"節番号は\s*(\S+)\s*である", lt)
    if not m:
        fails.append("lualatex reference PDF lacks the ref-site sentence")
        ref = None
    else:
        ref = m.group(1)
        md = re.search(r"節番号は\s*(\S+)\s*である", dt)
        if md and md.group(1) == ref:
            print("LABEL-JP-REF-PASS: ref site renders %r (== lualatex)"
                  % ref)
        else:
            fails.append("pdflatex ref site renders %r, lualatex %r"
                         % (md.group(1) if md else None, ref))

    if fails:
        for f in fails:
            print("LABEL-JP-FAIL: " + f)
        return 1
    print("LABEL-JP-PASS: Japanese label resolved (aux + ref site parity "
          "with lualatex)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
