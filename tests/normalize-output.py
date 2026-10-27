#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""DVI/PDF baseline normalizer (tests/reference/baselines 用).

出力ファイルから実行環境由来の可変成分のみを取り除き、バイト比較可能な
正規化コピーを stdout へ書く。docs/pdftex-tests.md の正規化契約と同一:

  DVI (platex/uplatex): comment フィールドの "YYYY.MM.DD:MMDD" タイム
    スタンプを DATE に置換。
  PDF (lualatex): /CreationDate /ModDate の "D:YYYYMMDDHHmmSS..." を
    DATE に、/ID [\...] を /ID XXX に、/FullBanner のディストリビューション
    名を TEXDIST に置換し、XRef ストリームと startxref オフセットも固定する。

sed は DVI/PDF の非 UTF-8 バイト列で不正エンコードとして空出力を返す
環境があるため、バイト列処理は本スクリプトで行う。
Usage: normalize-output.py <dvi|pdf> <file>
"""
import re
import sys

DVI_TS = re.compile(rb"[0-9]{4}\.[0-9]{2}\.[0-9]{2}:[0-9]{4}")
PDF_DATE = re.compile(rb"(D:[0-9]{14}[+\-Zz0-9'\"/]*)")
PDF_ID = re.compile(rb"/ID \[[^]]*\]")
# /FullBanner: LuaHBTeX が "(TeX Live 2025/nixos.org)" のように
# ビルド元のディストリビューション名を埋める。バイト再現性のために
# 括弧内全体を正規化する。
PDF_BANNER = re.compile(rb"(FullBanner \(This is LuaHBTeX, Version [0-9.]+ \()[^)]*(\)\))")
# LuaHBTeX は /ID を Flate 圧縮された XMP/ID パッケージ (最終オブジェクト、
# "/Type /XMP /Filter /FlateDecode" を含む小ストリーム) に格納する。平文の
# /ID 正規化では届かないため、このオブジェクトを丸ごと固定値に置換する。
# (内容はメタデータのみで組版には影響しない)
# LuaHBTeX は XRef をストリーム化する (/Type /XRef)。/FullBanner の
# ディストリビューション名の長さ差がバイトオフセットをずらし、
# 圧縮された XRef ストリームの内容を完全に変える。XRef は文書内容の
# メタデータであるため、正規化では丸ごと固定値に置換する。
PDF_XREFSTREAM = re.compile(
    rb"\d+ 0 obj\n<<[^>]*XRef[^>]*>>\s*stream\n.*?endstream\s*endobj",
    re.DOTALL)
PDF_STARTXREF = re.compile(rb"startxref\n[0-9]+")


def main():
    if len(sys.argv) != 3:
        sys.stderr.write("usage: normalize-output.py <dvi|pdf> <file>\n")
        return 2
    kind, path = sys.argv[1], sys.argv[2]
    data = open(path, "rb").read()
    if kind == "dvi":
        out = DVI_TS.sub(b"DATE", data)
    elif kind == "pdf":
        out = PDF_DATE.sub(b"(DATE)", data)
        out = PDF_ID.sub(b"/ID XXX", out)
        out = PDF_BANNER.sub(rb"\1TEXDIST\2", out)
        out = PDF_XREFSTREAM.sub(b"XREFSTREAM", out)
        out = PDF_STARTXREF.sub(b"startxref\nOFF", out)
    else:
        sys.stderr.write("normalize-output.py: unknown kind %r\n" % kind)
        return 2
    sys.stdout.buffer.write(out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
