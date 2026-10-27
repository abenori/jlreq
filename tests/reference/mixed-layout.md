# 参照エンジン定量検証結果: 混植文書

生成: 2026-10-23。tests/fixtures/pdflatex-mixed.tex（pdflatex指定を外した
同一文章）を3参照エンジンで組版した際の抽出テキスト。行位置の比較用参照。

## 抽出テキスト（pdftotext、レイアウト保持なし、正規化: 空白統一）

3参照エンジンとも以下に一致（同一のJFM・禁則のため）:

```
はじめての pdfLaTeX
本稿では，pdfTeX 上での日本語組版を検証する。English text with TEX is mixed here. 和文と欧
文の混植，および明朝とゴシックの切替を確認する。脚注1）と数式 eiπ + 1 = 0 も含む。
```

実測（2026-10-23、`cmp`による機械比較）: platex/uplatex/lualatex の
抽出テキスト（空白正規化後）は3者バイト同一。

pdfTeXバックエンドの抽出も同一内容（"TEX"も参照と同じく"E"を含む。
pdftotextの行分割・空白挿入の启发は異なるが、文字内容に差はない。
文字座標の差は字体差（IPAex Type1 vs OTF）に由来し比較対象外。

## 検証の要点

- 参照エンジン間（p/u/l）で抽出テキスト一致 → バックエンド比較の
  安定したベースライン。
- pdfTeXバックエンドの抽出は同内容を返す（mojibake 0件、文字化けなし:
  docs/pdftex-tests.md DoDサマリ参照）。
- 改行位置はJFMの行末追込み差により pdfTeX側で異なり得る
  （kinsoku-lines.md に実測）。
