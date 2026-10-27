# pdfTeXバックエンドのテスト方法（pdftex-tests）

## テスト構成

| 層 | 内容 | 実装 | 実行方法 |
|---|---|---|---|
| T0 プリフライト | 必須資源の存在（欠損=FAIL） | tests/run-pdftex-tests.sh T0 | スイート冒頭（JFM .def×12+manifest・backend .sty×4・trimmarks .def・aux縦font資源×3 fontset・haranoaji 横組TTF×4・ipxm/ipxg・cmtt9） |
| T1 静的 | JFM生成データの同等性 | `check_jfm_pdftex.lua` + `make check-pdftex-jfm` | `texlua check_jfm_pdftex.lua`（rc=0で全項目合格） |
| T2 マクロ | エンジン検出・寸法・フォント選択 | tests/fixtures/ + 3エンジン回帰 | 下記「回帰テスト」 |
| T3 文字組版 | ペアグルー・禁則・和欧文間隔 | tests/fixtures/pdflatex-rules/pairs.tex, kinsoku.tex | `pdflatex ... pairs.tex` → ログの PASS/FAIL |
| T3b parity | 行末追込みの4エンジン一致 | endadjust-lineend.tex + tests/check-endadjust-parity.py | 1行目 xMax を参照と0.1ptで比較 |
| T4 段落 | 行末調整 | tests/fixtures/pdflatex-rules/endadjust.tex | Overfull件数で判定 |
| T5 文書 | 混植文書の全体動作・バナー幾何 | tests/fixtures/pdflatex-mixed.tex, trimmarks-banner.tex | pdftotext 抽出・tests/check-banner-slots.py |
| T5b 日付・label | wareki \today・日本語label + パッケージ行列・境界日・綴り | today-wareki.tex, label-japanese.tex, label-packages.tex, date-boundaries.tex, space-dispatcher.tex | lualatex 参照抽出比較 + check-{today-wareki,label-japanese,label-packages,date-boundaries,space-dispatcher}.py |
| T11 厳密段落 | jlreqparagraph 環境: snapshot・入力モデル行列・禁止構成エラー・統合（rightskip/parskip/parshape/接続）・縦組み | tests/fixtures/pdflatex-paragraph/{strict-basic,strict-inputmodel,strict-errors,strict-integration,strict-tate}.tex | ログ内 STRICT/INM/INTEG/TATE-PASS 判定 + エラー文言 grep + Overfull/Underfull 0 件（T11 ブロック） |
| T7 回帰 | p/u/l の既存動作（ベースライン照合） | tests/fixtures/{basic-mixed,math-japanese,tate-vertical}.tex | tests/reference/baselines/ とのバイト比較 |
| T8 縦組み | tate shipout 回転・縦中横・局所方向 | tests/fixtures/pdflatex-tate-*.tex, pdflatex-tate/{tcy-*,dir-*}.tex | ログ判定 + tests/check-tatechuyoko.py（縦中横は通常ゲート）。**haranoaji ゲート**: `haranoaji-yoko`/`haranoaji-tate`（tests/fixtures/pdflatex-haranoaji/）は `pdftex_fontset=haranoaji` の実レンダリングを検査——横組は4面（Mincho/Gothic × Regular/**Bold**）の実埋込、縦組は補助縦フォント `JLreqVertharanoaji` 埋込＋縦字形対象文字（ーっ‥）の抽出codepoint照合。抽出照合は pdftotext がグリフ間に挿入する空白も除去して行う（`tr -d '\n '`; fontset により単語区切りが変わるため。全パイプ共通）。T12 には `staged-smoke-haranoaji`（staged TDS だけから -no-shell-escape、aux 縦フォントの実埋込まで判定） |
| T9 ruby | ruby.sty provider 適合 | tests/fixtures/pdflatex-tate/ruby-{basic,tate}.tex + ruby-adapter-noop | ログ内自己表明（17+10件）+ lualatex+ruby.sty 同一ソース対照（yoko ベースライン完全一致）+ noop ゲート |

## 実行方法（リポジトリ直下から）

```sh
# T1: JFMデータ検証（差分ゼロ + 全ペア照合）
make check-pdftex-jfm
texlua check_jfm_pdftex.lua

# T3: 組版規則の実測（ログに PASS/FAIL が出る）
mkdir -p /tmp/m4t
pdflatex -interaction=nonstopmode -halt-on-error \
  -output-directory=/tmp/m4t tests/fixtures/pdflatex-rules/pairs.tex
grep -E 'PASS|FAIL' /tmp/m4t/pairs.log   # 全PASSが合格

# T4: 行末調整
pdflatex -interaction=nonstopmode -halt-on-error \
  -output-directory=/tmp/m4t tests/fixtures/pdflatex-rules/endadjust.tex
grep -c Overfull /tmp/m4t/endadjust.log  # 0が合格

# T5: 混植文書
pdflatex -interaction=nonstopmode -halt-on-error \
  -output-directory=/tmp/m4t tests/fixtures/pdflatex-mixed.tex
pdftotext /tmp/m4t/pdflatex-mixed.pdf -   # 文字列抽出の目視照合
pdffonts /tmp/m4t/pdflatex-mixed.pdf      # IMFCTT1/IGFCTT1埋込確認

# T7: 3エンジン回帰（差分ゼロ確認）
for f in basic-mixed math-japanese tate-vertical; do
  for e in platex uplatex; do
    $e -interaction=nonstopmode -halt-on-error \
      -output-directory=/tmp/reg tests/fixtures/$f.tex
  done
  lualatex -interaction=nonstopmode -halt-on-error \
    -output-directory=/tmp/reg tests/fixtures/$f.tex
done
# 比較はDVIはタイムスタンプ正規化後バイト同一，lualatexのPDFは
# 日付/ID正規化後バイト同一（スイート内蔵の正規化器:
# python3 tests/normalize-output.py <dvi|pdf> <file> — sed は DVI/PDF の
# 非UTF-8バイト列で不正エンコードエラーを起こす環境があるため
# バイト列処理をPythonで行う）:
python3 tests/normalize-output.py dvi a.dvi > a.n.dvi
python3 tests/normalize-output.py pdf a.pdf > a.n.pdf
```

## 基準点（変更前後で同じコマンド・同じ正規化を用いること）

DVI/PDFは埋込タイムスタンプを持つため，**正規化してからバイト比較**する。
両側を同一パイプライン（同じdvipdfmx等）で処理すること。
lualatexは直接PDF出力のため、日付/ID に加え /FullBanner のディストリビューション名（nix版は "TeX Live 2025/nixos.org"、公式イメージは "TeX Live 2025"）・XRefストリーム（オフセットシフトで圧縮内容が変わる）・startxref オフセットを正規化する（tests/normalize-output.py が双方の環境で一致を保証）。
スイートの T7 セクションはこの比較を**コミット済みベースライン**
（tests/reference/baselines/、実装前の2026-10-24に固定条件
`SOURCE_DATE_EPOCH=1735689600` で記録した3フィクスチャ×p/u DVI・
l PDF の正規化バイト）に対して自動で行う。ベースラインは回帰判定の
オラクルであり、出力都合で機械的に再記録してはならない。再記録手順
と承認要件は tests/reference/baselines/README.md に記載している。

## 判定基準

- T0: 必須資源（JFM .def 12種+manifest・バックエンド .sty×4・aux縦font・trimmarks .def・
  ipxm/ipxg フォント・cmtt9）が全て存在すること。欠損は **SKIPではなく
  FAIL**（欠損ファイル名を明示）。
- T1: `ALL CHECKS PASSED`（差分0・全ペア照合）
- T3: pairs.tex 7/7 PASS，禁則は `tests/check-kinsoku.py`（実PDF bbox機械
  検証，閉じ約物の行頭0件）で確認 — スイート内 `kinsoku-bbox-line-head-scan`。
  行末追込みは `endadjust-lineend.tex` を4エンジンでコンパイルし
  `tests/check-endadjust-parity.py` が pdflatex の1行目 xMax を参照最大値と
  0.1pt以内で検査（f665eba 修正後の parity を固定検査する通常ゲート。
  経緯は tests/reference/kinsoku-lines.md 訂正節参照）。
- T4: 対象フィクスチャでOverfull 0件
- T5: trimmarks-banner は `tests/check-banner-slots.py`（pymupdf）が
  6スロットの実bbox・書き込み方向を固定ジオメトリ窓で機械検証
  （旧 BANNER-PD-PASS typeout grep は2026-10-24廃止）。
  追加: `trimmarks-twoside-pageattr` は `tests/check-trimmarks-pageattr.py`
  が3ページ分のページ辞書（TrimBox/BleedBox の奇偶分岐・キー重複なし）
  を検査し、ログに "Missing number"（旧 \@outputpage tl_put パッチの
  未解決 \ifodd 残滓）と "Non-PDF special ignored!"（d ドライバからの
  papersize special）が無いことを条件にする。
  追加: `trimmarks-tate-banner-geometry` は `tests/check-banner-tate.py`
  が縦組文書の回転バナー全スロット族（tate/in-tate 上下左右 + in-center、
  2ページ×10スロット=20箇所）の実bbox を uplatex ground truth
  （同一フィクスチャを uplatex+jlreq-trimmarks+dvipdfmx で組んだ実測値、
  0.5pt窓）と照合する。矯正係数はクロス幅=回転箱の wd・ラン長=同 dp の
  スロット族別公式で、別の bleed 構成（gutter=6/fore=0）と 2〜11文字の
  ラン長でも 0.01pt 一致を確認済み（単一ケースへの同調ではない）。
- T7: 3フィクスチャ×3エンジン，正規化後バイト同一（ベースライン照合），
  バックエンド非読込。
- T8: tate JFM .def 欠損は FAIL（旧SKIP成功 path は廃止）。

## 既知不良ゲート（XFAIL/XPASS）と昇格

現時点で出力不良が既知の検査はランナー先頭の
`KNOWN_DEFECTS`（単一の真実源）に列挙する:

- **失敗 → XFAIL**: `XFAIL: <name>` と出力し、全体 rc には影響しない。
  **スイートは「XFAIL 残りのみの green」を常態とする。** XFAIL は
  「実装済み」を意味しない。各 XFAIL は対応する実装が着地した時点で
  解消する。
- **成功 → XPASS**: 実装が不良を解消した兆候。`XPASS: <name>` と昇格手順
  （KNOWN_DEFECTS から削除し通常セクションへ移動、docs を更新）を出力し、
  **全体 rc は非0**。昇格が完了するまでスイートは green にならない。
- `KNOWN_DEFECT_EXPECT=<name>` 環境変数で特定ゲートの期待値を反転できる
  （「そのゲートは今は成功するはず」として検証する昇格前確認・
  メカニズムの動作確認用）。

現在の既知不良（2026-10-24 時点）: **なし**（KNOWN_DEFECTS 空）。

**昇格記録（2026-10-24）**: `today-wareki` と `label-japanese` を
KNOWN_DEFECTS から削除し通常ゲートへ移した。
`today-wareki`: d-engine 分岐の `\today` が `\ifjlreq@seireki` を反映
（wareki→`\jlreq@wareki` の元号表、tate→`\jlreq@pdf@kansuji`、
yoko→`\number`）。lualatex 参照との抽出比較が一致。
`label-japanese`: label key の対称正規化
（`\jlreqpdf@labelkey`: `\protected@edef` でマクロ展開+UTF8 byte凍結 →
`\detokenize` で catcode 12 化）を write（`\label`）・read（aux の
`\newlabel`、begindocument/before フック）・query（`\ref`/`\pageref`）と
パッケージ面（nameref `\NR@setref`、hyperref `\label@hyperref`/
`\HyRef@autoref`、refcount `\refused`/`\rc@set`/`\getrefnumber`、
cleveref `\@cref` 入口 + `\cref@getref`/`\cpageref@getref`）に接続。
ASCII ラベルの aux は byte 不変（HEAD との cmp 一致を確認済み）。
追加ゲート: `label-packages-3pass`（3パス収束）・
`label-packages-matrix`（ref/pageref*/eqref/autoref/nameref/cref/
hyperref/refcount の全面解決 + getrefnumber の edef 内展開）・
`date-boundaries`（和暦5境界日+元年+`\西暦true`/`\和暦` 切替）・
`space-dispatcher`（`\　` 命令/literal U+3000/`\jaspace` の共存）も
T5 の通常検査として登録。

**昇格記録（2026-10-24）**: `tatechuyoko-basic` は KNOWN_DEFECTS から
削除し通常ゲートへ移した（局所方向エンジン + 箱工場で `\jlreq@iftdir` が
live 化し、縦中横が正規化組版される。追加ゲート:
`dir-roundtrip`・`dir-callers`・`dir-index-yoko`・`tcy-digits`・
`tcy-fontchange`・`tcy-star-error` も T8 の通常検査として登録）。

**追加ゲート（2026-10-24）**: T8 に T8c ブロックを追加した（出力
ルーチン薄層化・目次リーダー・savepos・家具オプションの受け入れ）。
- `out-hook-probe` / `out-hook-probe-yoko`: build/page/before・after・
  shipout/before が 1ページにちょうど1回だけ発火（d-tate と d-yoko
  両方）。
- `toc-twopass`: tate + `\tableofcontents` 2パスで Leaders エラーゼロ
  （frame-pop `\aftergroup` + リーダー群括りの2要因を解消）。
- `outputpage-copy-gone`: backend ソースから kernel `\@outputpage` 本体
  丸写しの grep 証拠（`\shipout `/`\@begindvi`/`\stepcounter{page}` 0件）。
- `savepos-warichu`: 割注の savepos 論理行方向測定（current=60.0pt/
  rest=140.0001pt、uplatex ビット一致、aux frame-id 往復は pass 2 判定で証明）。
- `savepos-warichu-mag`: `\mag=1200` でも同一値（`−1truein` 修正の回帰ガート）。
- `savepos-marginpar`: marginpar 列/側 + 遅延脚注の行方向相対距離が
  pd/up 同一（160.0007pt）。
- `anchor-parity`: 本文グリフ走りの PDF インク対照（pymupdf、
  worst 0.0010pt）。up 変換は dvipdfmx -p "182mm,257mm"（JIS B5）。
- `furniture-options`: 非対称 gutter/fore_edge/head_space/foot_space +
  twoside + 段組 + 遅延注 + marginpar の幾何対照（oddsidemargin
  12.7299pt 等が uplatex とビット一致——縦組み `\Cht/\Cdp` を縦JFM
  class 0 で測り直した修正の回帰ガート）。

`tests/fixtures/pdflatex-rules/endadjust-lineend.tex` はこのリストには
**入っていない**: 記録されていた行末追込み不良（kinsoku-lines.md の
pdflatex 143.2pt）は f665eba の `\jlreqpdf@addendadj` 修正で解消済みで、
2026-10-24 の再実測では4エンジン parity が成立するため、通常の回帰
ゲートとして 0.1pt 許容で固定検査している。

### T11 厳密段落（2026-10-25 追加）

- `strict-basic`: 環境入口の hsize snapshot が保存値と一致すること
  （hsize=333pt 下で `\jlreqpar@hsize` を照合）、多行・括弧・約物・
  欧文混在の厳密段落が Overfull/Underfull 0 で組めること、
  連続環境（2環境）の行間接続。
- `strict-inputmodel`: 許可構成要素すべて（CJK 連続・欧文 word・空白・
  `\inhibitglue`・`\hspace`・`\kern`・`\penalty`・`\allowbreak`・
  inline math・`\mbox`・`\makebox[c]`・hyperref リンク・label）が
  エラー 0 で itemize されること（INM-PASS）。
- `strict-errors`: 未知マクロ（TeX 自身の Undefined control sequence）、
  環境内 `\footnote`（`footnote~is~not~allowed~inside~jlreqparagraph`）、
  環境内 `\[`（`display~math~is~not~allowed~inside~jlreqparagraph`）の
  具体的エラー文言（-halt-on-error なしで実行し grep）。
- `strict-integration`: 非ゼロ rightskip/parskip 下、looseness・
  emergencystretch、parshape（3行形状）、通常段落との前後接続
  （ページ跨ぎを含む長文）で INTEG-PASS + Overfull 0。
- `strict-tierdiff`: 2-tier 差の実証——tier-50 明示グルーが stretch
  需要を全量受け下位 tier（kanjiskip 0/JFM −10）は 0（TIERTOP
  ログ判定 ×3: 明示 share 非零・下位全 0・RBWD 1sp 以内）+ Overfull 0。
- `strict-finalsel`: aw_step1_last 最終行候補再選択——native e=0 に
  対し parfillskip 条件が e=5pt を選ぶ（FINS ログ判定）+ Overfull 0。

**実装状況の注記（2026-10-25 最終）**: 配分エンジン全段階
実装・検証済み（distphase=4: 境界表記録 → 行内 node 逆走 →
tier 分類 → sp 充填 → 行 box 再構成）。実測: 再構成幅は測定幅と
delta=0.0pt（1sp 以内、`\jlreqpar@verifywd` でログ検証可能）、
hsize=211pt の有限伸長行で tier-50 glue 群に +0.06667pt の
配分が発生。ltj 準拠の fil 除外（parfill 行は配分スキップ）も
実装。BD 表照合は位置非依存 first-match に修正済み（約物 pair
は安定して JFM tier に入る）、未定義 pair の fallback グルーも
記録（漢字-漢字境界は kanjiskip tier 0）。aw_step1_last 最終行
候補再選択も実装・実測済み（`strict-finalsel` gate:
native e=0 に対し parfill 条件が e=5pt を選ぶ）。

**2-tier 差の実証（native 一括伸縮との差が出る例）**:
`strict-tierdiff` fixture（runner gate 4 件）。hsize=158pt で
stretch 需要 8pt の行: native 一括比例なら明示 `\hspace{0pt
plus 30pt}` は 4.36pt・各漢字間 0.36pt のところ、tier engine は
tier-50 明示グルーに全量 8.00002pt・下位 tier 0 を配分
（`TIERTOP` ログ、RBWD 1sp 以内、overfull 0）。

**同一ソース oracle 比較**: 同一和文テキストを
(1) lualatex+ltj（jlreq.cls が lineend=extended/priority=true 指定）、
(2) pdflatex native、(3) pdflatex strict で組んだ実測——行 break は
3 者同一（6/14/11 字の同一分割、各行の先頭/末尾 x 座標も一致:
88.4..138.2 / 88.4..225.9 / 78.5..178.1）、行間隔も環境内で
同一。差異は strict 環境が 1 環境=1 段落のため環境間の
interline のみ。byte 完全一致ではなく実測座標比較
（差分の原因も特定済み）。

## 一括テスト実行

```sh
sh tests/run-pdftex-tests.sh
```

ランナーは冒頭で `make pdftex-fonts` を実行し、TeX Live 収録フォントから
補助縦フォントと HaranoAji 横組変換 TTF を生成する（リポジトリにフォント
バイナリは無い。生成は manifest 駆動なので fresh clone でも動作する。
生成失敗は FAIL）。
実行ごとに `mktemp -d` で隔離された作業ディレクトリ（先頭行にパス表示）
を作り、各セクション・フィクスチャ・エンジン・パスに個別サブディレクトリ
を割り当てる（T0/T1/T3/T3b/T5/T5b/T7/T8/T8b の順）。全コンパイルは
`-output-directory=<そのdir>` で実行し、ログ・PDF は全てそこに残る。
失敗行は必ず該当ログのパスを示す。最終サマリは FAILED/XFAIL/XPASS 件数
と XFAIL/XPASS 名の一覧を出力する: XFAIL のみ残っている場合は rc=0
（green-with-xfails）、FAIL または XPASS がある場合は rc≠0。

作業ディレクトリは実行ごとに新規作成のため蓄積に注意
（`/tmp/jlreq-tests.*` を適宜削除）。

## 性能測定（T8）

### ストレスベンチマーク（tests/fixtures/pdflatex-bench/long.tex: 約物・
### 混植・脚注・数式・長段落を含む2ページ，内容は全エンジン同一）

比較構成（同一マシン，ウォームアップ後3回の中央値，2026-10-23）:

| 構成 | 実行時間 | PDFサイズ | 備考 |
|---|---|---|---|
| (B) pdfLaTeX＋本バックエンド | **0.375s** | 654,251 B | ipaex-type1 Type1サブセット埋込 |
| (C) LuaLaTeX＋既存jlreq | 0.961s | 109,436 B | OTF直接埋込（サイズ差は字体方式由来） |
| (D) upLaTeX＋既存jlreq | 0.191s | （DVI経由） | 最速基準 |

- (B)は(C)より約2.6×高速，(D)より約2×遅い。増分の主因は
  bxcjkjatype/CJKパッケージのロードと文字毎の状態機構展開。
- JFMデータは静的`.def`のため，実行時のオーバーヘッドはペア表引き
  （`\csname`一件）とグルー出力のみ。0.4秒/2ページという値は
  短文〜中規模文書で十分実用的。
- 両エンジンの抽出テキストは同一内容（4,399 vs 4,288字はpdftotextの
  スペース挿入規則差であり内容欠落ではない）。

### T8 書籍規模ベンチマーク（tests/fixtures/pdflatex-bench/book100.tex、2026-10-23）

書籍規模ベンチマーク（章・脚注・目次・図表を含む100ページ以上）:
10章×10節×3段落+脚注300+表10+hyperrefしおり、**124ページ**。
ウォームアップ後3回の中央値:

| 構成 | 実行時間 | ピークメモリ | 出力 |
|---|---|---|---|
| (B) pdfLaTeX＋本バックエンド | **3.77s** | **60.4MB** | PDF 479KB、抽出5007行、フォント37個全埋込 |
| (C) LuaLaTeX＋既存jlreq | 3.16s | 481MB | 124ページ同一、抽出4609行 |
| (D) upLaTeX＋既存jlreq | 0.70s | 45.8MB | DVI経由 |

- (B)は(C)の約1.2倍、(D)の約5.4倍。約物ペアグルーの状態機構展開が
  主因だが、100ページ超文書で4秒弱は実用範囲。
- ピークメモリは(B)が最小クラス: (C)のLuaTeXランタイム(約481MB)の
  1/8、(D)より15MB多い程度。抽出5007 vs 4609行の差はpdftotextの
  スペース結合規則差（内容欠落ではない、両者同一文章）。
- 抽出テキストのU+FFFD 0件、フォント未埋込0件（規模ベンチでも同一品質）。

### T8 追加計測: (A) 生bxcjkjatype ベースライン（2026-10-23）

同一内容（long.texベンチ）での比較:

| 構成 | 実行時間（3回合計） | PDFサイズ | 抽出文字数 |
|---|---|---|---|
| (A) pdfLaTeX＋bxcjkjatype単体 | 0.762s | 440,400 B | 4,291 |
| (B) pdfLaTeX＋本バックエンド | 1.123s | 654,251 B | 4,399 |

- (B)は(A)の約1.5倍。増分＝状態機構の展開＋JFMグルー/禁則ペナルティ出力
  （機能を実装した上で1.5倍は妥当）。
- PDFサイズ差の要因: (B)はペアグルー由来の改行位置差でサブセットフォントの
  グリフ構成が変わる（内容欠落ではない，抽出は本文同一）。

## Definition of Done 実測サマリ（2026-10-23 最終確認）

各完了条件に対する機械的確認結果:

| DoD項目 | 確認方法 | 結果 |
|---|---|---|
| 自動検出+明示指定 | `\documentclass{jlreq}` / `[pdflatex]` 両方 rc=0 | PASS |
| JFM単一ソース+差分ゼロ | `make check-pdftex-jfm` | PASS（全12変種） |
| 禁則・字間の重大な規則違反 | `tests/check-kinsoku.py`（実PDF bbox走査）+ pairs.tex 7計測 | 0件 |
| p/u/l 非意図的回帰 | DVI（タイムスタンプ正規化）とPDF（日付/ID正規化）の、コミット済みベースライン（tests/reference/baselines/、2026-10-24実装前に固定条件で記録）とのバイト比較＋`\jidori`/`\akigumi` 4エンジン回帰ガード（suite内 reg-* baseline / reg-jidori-*） | 全同一 |
| 文字抽出 | 全21 PDF（20フィクスチャ+エラーケース1） `pdftotext` → 置換文字(U+FFFD) 0件 | PASS |
| 文字化け | 同上 | 0件 |
| フォント埋め込み | 全21 PDF `pdffonts` → 未埋込 0件（IPAex Type1, LM, CM すべて subset埋込） | PASS |
| しおり | hyperref-bookmarks 3パス → PDF ObjStm 内 UTF-16BE タイトル3件（`はじめてのしおり`等）を解凍確認 | PASS |
| インストール・配布 | Makefile `install`/`tds` にバックエンド・def・生成器・ドキュメント収録 | 済み |
| 依存関係・ライセンス・最低版 | `docs/pdftex-dependencies.md` | 記録済み |
| 上流レビュー・マージ | `docs/upstream-issue-draft.md`（PR 1–7 分割案つき） | 外部待ち |
