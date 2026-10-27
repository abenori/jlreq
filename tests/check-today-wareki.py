#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""today-wareki.tex の \today 和暦 parity 検証（昇格済みの通常ゲート）。

契約: \jlreqsetup{year_style=wareki} 時の \today は upLaTeX/LuaLaTeX と
同じ「令和N年M月D日」形式（元年処理含む）を出力する。pdfTeX バック
エンドは \ifjlreq@seireki を反映し（year_style キーが設定）、
縦組みでは漢数字・横組みでは欧文数字で出力する。本検査は昇格済みの
通常ゲートとして GREEN を要求する。

判定: pdflatex と lualatex で同一ソースをコンパイルした PDF の
pdftotext 抽出から日付行（"日付:" 以降）を取り、両者が一致することを
要求する。日付の数字は fixture 内で \year/\month/\day=2019/5/1 に固定
（令和元年ケース）。

Usage: check-today-wareki.py <pdflatex.pdf> <lualatex.pdf>
exit 0 = PASS / exit 1 = FAIL
"""
import re
import subprocess
import sys

MARK = "日付"


def date_line(pdf):
    """抽出テキストの「日付」以降1行を返す（空白正規化済み）。
    pdflatex は xkanjiskip 由来の空白挿入位置が異なるため、マーカは
    「日付」のみとし、コロン前後の空白は正規化で吸収する。"""
    out = subprocess.run(["pdftotext", pdf, "-"], capture_output=True,
                         text=True).stdout
    m = re.search(re.escape(MARK) + r"\s*[:：]?\s*(.+)", out)
    if not m:
        raise SystemExit("TODAY-WAREKI-FAIL: marker %r not found in %s"
                         % (MARK, pdf))
    return re.sub(r"\s+", "", m.group(1))


def main():
    if len(sys.argv) != 3:
        print("TODAY-WAREKI-FAIL: usage: check-today-wareki.py "
              "<pdflatex.pdf> <lualatex.pdf>")
        return 1
    d = date_line(sys.argv[1])
    l = date_line(sys.argv[2])
    print("TODAY-WAREKI pdflatex date: %r" % d)
    print("TODAY-WAREKI lualatex date: %r" % l)
    if d == l:
        print("TODAY-WAREKI-PASS: wareki \\today output matches lualatex")
        return 0
    print("TODAY-WAREKI-FAIL: pdflatex \\today %r != lualatex reference %r "
          "(wareki setting ignored by the pdfTeX branch?)"
          % (d, l))
    return 1


if __name__ == "__main__":
    sys.exit(main())
