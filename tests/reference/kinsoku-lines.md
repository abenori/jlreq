# 参照エンジン定量検証結果

生成: 2026-10-23。`\hsize=65pt` の行に「漢漢漢漢漢漢」+閉じ括弧を置いた
禁則ストレス入力での行末挙動。PDFはコミットしない（方針どおり）、
座標値のみを記録する。オラクル: `pdftotext -bbox` の xMin/xMax。

## 入力（tests/fixtures/pdflatex-rules/kinsoku.tex と同一文章）

```latex
\hsize=65pt \parindent=0pt
漢漢漢漢漢漢」漢漢漢漢漢漢漢
漢漢漢漢漢「漢漢漢漢漢漢漢
```

## 行末結果（1行目: 行がどこまで伸びるか）

| エンジン | 1行目右端 xMax (pt) | 1行目の終わり | 備考 |
|---|---|---|---|
| platex (jlreq) | 148.2 | 漢漢漢漢漢漢」 | 行末追込み（end_adjust）で65ptを超えて」まで置く |
| uplatex (jlreq) | 同上 | 同上 | platexと同一 |
| lualatex (jlreq) | 同上 | 同上 | ltjのlineend=extended調整 |
| **pdflatex (本バックエンド)** | 143.2 | 漢漢漢漢漢（」は次行2文字目） | 禁則自体は遵守（」は行頭でない）。差分行末追込み。**[2026-10-24 追記] この行は歴史的記録である（下記訂正参照）** |

## 解釈

- 3参照エンジンは同一レイアウト。いずれも行末約物の追込みにより
  hsizeを最大0.5zw超えて」を行末に残す（jfm-jlreq.luaのクラス2
  end_adjust {0,0.5} の作用）。
- pdfTeXバックエンドは禁則（」を行頭にしない）を守るが、
  end_adjustはshrink畳み込み近似（docs/pdftex-internals.md 参照）で
  あるため、参照エンジンほど行を伸ばせず、」が次行へ落ちる。
  「行頭禁則違反」ではなく「行末追込みの近似差」であり、
  docs/pdftex-compatibility.md の既知の制限（既知違反）の実測値である。

## 訂正（2026-10-24、基準化作業での再実測）

上記の pdflatex 143.2pt という計測は **旧実装**
による歴史的記録である。現行の `\jlreqpdf@addendadj` は、旧2引数
版が `\fi` を引数に食って end_adjust データと無関係に常に 1zw を
shrink に畳み込んでいたバグを修正したものである。修正後の現行 HEAD では
同一入力の再実測で全エンジン parity が成立する:

| エンジン | 1行目右端 xMax (pt) | 1行目の終わり |
|---|---|---|
| platex / uplatex | 148.20 | 漢漢漢漢漢漢」 |
| lualatex | 148.20 | 同上 |
| pdflatex (現行) | 148.20 | 同上 |

hsize 60–80pt の掃引（」の後に漢/あを置く複数ケース、短い最終行、
複数段落を含む）でも pdflatex と参照3エンジンの1行目 xMax 差は
≤0.01pt であり、「」が次行へ落ちる」状況は再現しない。
この回帰を固定検査するための 4 エンジン parity ゲートとして
`tests/fixtures/pdflatex-rules/endadjust-lineend.tex` +
`tests/check-endadjust-parity.py`（許容 0.1pt）を
tests/run-pdftex-tests.sh T3 に配置した。本ファイルの旧記述を
「実測不良の継続」として引用しないこと。
