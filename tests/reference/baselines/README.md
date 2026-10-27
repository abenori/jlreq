# p/u/l 回帰バックエンドのベースライン（実装前記録）

このディレクトリは **実装作業の前に** 記録した
参照エンジン出力の基準値である。`tests/run-pdftex-tests.sh` の T7 セクション
が同じ条件で再生成した出力とバイト比較を行い、pdfTeX バックエンド実装が
platex/uplatex/lualatex の既存動作を壊していないことを機械保証する。
ベースラインは回帰判定のオラクル（oracle）であり、出力を機械的に再記録
してよいものではない（下記「再記録」参照）。

## 収録内容

| engine | 出力 | 固定条件 |
|---|---|---|
| platex | `<fixture>.dvi` | DVI（タイムスタンプ正規化済み） |
| uplatex | `<fixture>.dvi` | DVI（タイムスタンプ正規化済み） |
| lualatex | `<fixture>.pdf` | 直接PDF（日付/ID/FullBanner/XRefストリーム正規化済み） |

fixtures: `tests/fixtures/basic-mixed.tex`, `math-japanese.tex`,
`tate-vertical.tex`（3×3＝9組）。

## 記録条件（T7 は常にこの条件で再実行する）

- リポジトリ直下を cwd とする（kpsewhich が `./` を解決するため）。
- コンパイル: `<engine> -interaction=nonstopmode -halt-on-error
  -output-directory=<per-run outdir> tests/fixtures/<fixture>.tex`
- 環境変数 `SOURCE_DATE_EPOCH=1735689600`（2025-01-01T00:00:00Z）固定。
- `SOURCE_DATE_EPOCH` は PDF の /CreationDate・/ModDate・/ID に反映される。
  pdfTeX系エンジンの `\year/\month/\day` には反映されないため、日付内容
  を問題にするフィクスチャは fixture 内で `\year` 等を明示固定する
  （tests/fixtures/pdflatex-coexist/today-wareki.tex 参照）。
- 正規化（tests/normalize-output.py、docs/pdftex-tests.md と同一契約）:
  - DVI: comment の `YYYY.MM.DD:MMSS` タイムスタンプ → `DATE`
  - PDF: `D:YYYYMMDDHHmmSS...` → `(DATE)`、`/ID [...]` → `/ID XXX`
- 比較: 正規化後のバイト完全一致（`cmp`）。差分は全件 FAIL。


## 正規化契約の拡張（エンジン再記録ではない、2026-10-25）

GNU make 4.4+ / 配布環境差（`/FullBanner` のディストリビューション名、
XRef ストリーム）への対応として `tests/normalize-output.py` が拡張され、
コミット済み lualatex PDF 3 件は**同じ元ビルド**に新しい正規化
（FullBanner → TEXDIST、XRef ストリーム → 定数、startxref → OFF）
を適用し直した。これはエンジン出力の再記録ではなく、同一出力に対する
比較契約の拡張である（nix 環境と texlive/texlive:TL2025-historic
コンテナの双方でバイト一致を検証済み）。

## 再記録について

ベースラインは参照エンジンの「今の動作」を固定した回帰オラクルである。
再記録は **jIreq クラス自体の意図した仕様変更** を除いて禁止で、実装する。

再記録が必要になった場合は必ず明示的な承認（レビューで意図を確認）を
経て、次のコマンドで全 9 組を同一条件で作り直し、差分の理由をコミット
メッセージに記録すること:

```sh
rm -rf /tmp/p1-base && mkdir -p /tmp/p1-base
for f in basic-mixed math-japanese tate-vertical; do
  for e in platex uplatex lualatex; do
    mkdir -p /tmp/p1-base/$e/$f
    ext=pdf; [ $e = lualatex ] || ext=dvi
    SOURCE_DATE_EPOCH=1735689600 $e -interaction=nonstopmode -halt-on-error \
      -output-directory=/tmp/p1-base/$e/$f tests/fixtures/$f.tex
    python3 tests/normalize-output.py $ext \
      /tmp/p1-base/$e/$f/$f.$ext > tests/reference/baselines/$e/$f.$ext
  done
done
```

pdfTeX バックエンドの実装・修正で参照エンジン出力が変わることは
ないはずであり、変わった時点でバグである（最初に疑うこと）。
