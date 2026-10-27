# Upstream Issue draft: pdfLaTeX backend for jlreq

This is a **draft** for the upstream issue to abenori/jlreq. It reflects the
current implementation state of the `pdflatex` branch: **horizontal and
vertical (`tate`) typesetting are both complete and verified** (two
quantified residuals registered).

---

## Title (proposal)

Add a pdfLaTeX backend to jlreq — full Japanese typesetting incl. vertical writing

## Body (proposal)

### 目的 / Goal

`\documentclass{jlreq}` を**標準の pdfLaTeX（pdfTeX）**で使えるようにする。
横組みに加えて**縦組み（`tate` オプション）も含めて**、jlreq の公開 API
（クラスオプション・`\jlreqsetup`・命令・環境）と日本語組版規則
（JFM ペアグルー・禁則・和欧文間空き・行末調整・ぶら下げ）を維持する。
pLaTeX / upLaTeX / LuaLaTeX の既存動作は変更しない（回帰は生成済み
ベースラインとのバイト比較で保証）。改造エンジン・コンパイル時の
Lua/Python・shell-escape は不要。実験的（experimental）サポートとして
の提供を想定する。

### 対応範囲 / What works now

横組み: `pdflatex` クラスオプション（または自動判定）で、JFM に基づく
文字間グルー（9フィールド全評価、kanjiskip 付随成分・未定義ペアは現行
skip 値へフォールバック）、禁則（行頭禁則は実 PDF bbox 機械走査で
違反 0 件）、和欧文間空き、約物の JFM クラス幅組版（インク形状は
platex 参照と一致）が動作する。

縦組み（`tate`）: **shipout rotation 構成**で実現（内枠は通常の横組み
galley、和文グリフを +90° 予備回転、`\@outputpage` で出力箱を −90° 回転）。
カーネルの `\@outputpage` 丸写しは使わず、begindocument で保存した元実装を
回転付きの薄いラッパから呼ぶ（build/page フックと hook 付き shipout は
素通りを機械検証済み）。検証済みの範囲と対照数値:

* 読み方向（上→下）・段方向（右→左）・禁則・約物配置 — 生成した補助縦
  フォントによる**本物の縦字形**（vert/vrt2 置換グリフは直立のまま、
  それ以外は回転、進行幅は JFM クラス幅×現在 zw）。
* ページ家具: head_space/foot_space/gutter/fore_edge 非対称＋両面＋
  二段組＋遅延脚注＋傍注（marginpar）が upLaTeX 同一ソースと
  **ビット一致**。
* 縦中横 `\tatechuyoko`: 進行 1zw で upLaTeX と一致（star 形は横組みで
  透過、非 star は他エンジンと同じ ClassError）。
* 行内・別行数式: pLaTeX `adjustbaseline` と同一式の δ 基準線シフトで
  upLaTeX と **sp 一致**（10pt: δ=3.44438pt = upLaTeX `\tbaselineshift`）。
  数式内テキスト箱（`\text`/`\mbox`/`\makebox`）は pTeX の方向一致則に
  従いスタイル別に counter-shift。行内数式トップレベルの明示的な raw
  `\hbox`/`\vbox`/`\vcenter` は `\mbox`/`\text` 置換を示す ClassError
  （pdfTeX に任意 primitive 箱の方向を後から取得する API がないための
  入力契約）。
* 脚注・後注・傍注・浮動体: 単一脚注の罫線位置・本文列頭等が upLaTeX と
  worst 0.011pt（10pt）。割注・savepos 系合印の論理行方向測定は upLaTeX と
  ビット一致（`\mag=1200` でも同一値）。
* jlreq-trimmarks: トンボ・TrimBox/BleedBox・奇偶ページ属性、**縦バナー
  全スロット族が upLaTeX ground truth と 0.01pt 一致**（2ページ×10スロット
  =20箇所の実 bbox 照合）。
* ルビ: CJK パッケージの `ruby.sty` を provider として適合
  （`jlreq-pdftex-ruby.sty`、provider の overlap 計算を保存。
  jlreq 独自の `\ruby` は定義しない）。横組みは上付き・縦組みは読み枠右側で、
  lualatex+ruby.sty 同一ソース対照と yoko ベースラインオフセット完全一致・
  tate 中央合わせ 0.20/0.32pt。
* 日本語ラベル（`\label{日本語}`/`\ref`/`\pageref`、nameref/hyperref/
  refcount/cleveref 適合）・和暦 `\today`（元号境界日・縦組み漢数字）・
  `\西暦`/`\和暦`/`\　` 綴り（展開可能な正規化。ASCII ラベルの aux は
  バイト互換）。
* ぶら下げ組み（`hanging_punctuation`、`-b` 系 JFM 変種）: 行末限定の
  kern/penalty 候補列の**負 end_adjust 候補**として表現（行中は正味 0）、
  突出し量は upLaTeX と一致。
* 行末調整: p/u/l/d の 4 エンジンで **0.000pt parity**
  （`endadjust-lineend` ゲート、参照と 0.1pt 許容で固定検査）。
* **厳密段落環境 `jlreqparagraph`**: 段落パラメータを全件 snapshot し、
  native 改行器で一度だけ改行した行を行単位で回復して、JFM ペアグルーの
  優先順位付き伸縮を厳密に配分する（入力モデルは明示: CJK 連続・欧文
  word・空白・`\inhibitglue`・`\hspace`/`\kern`/`\penalty`/`\allowbreak`・
  行内数式・`\mbox`/`\makebox`・label/hyperlink。環境内の別行数式・脚注・
  傍注は具体的エラー）。通常段落は意図的に native 一括伸縮のまま
  （優先順位 spri/shpri は境界ごとに記録して同環境が消費する、
  承認済みの二層設計）。

フォント: 既定 `ipaex-type1`（Type 1 サブフォント）、`pdftex_fontset=haranoaji`
（**HaranoAji** = 現在の TeX Live 標準日本語フォント。pLaTeX/upLaTeX は
rml/gbm TFM 名が TL2025 で HaranoAji にマップされ、LuaLaTeX も
luatexja 既定が HaranoAjiMincho であるため、本 fontset は pdfTeX を
**3エンジン共通の実フォントに揃える**。CFF→TrueType 変換(実測 worst
0.862/1000em)による横組用フル TTF 4面と実 Bold 面を含む）、
`pdftex_fontset=ipa`（zhmetrics TrueType チェーン）、
`pdftex_fontset=custom` +
`pdftex_fontprofile=<file>`（`make_pdftex_fonts.py` が生成）。
フォント派生物（補助縦 TTF/TFM/enc、HaranoAji 横組変換 TTF）は
**リポジトリに含めず**、TeX Live 収録フォントを `make pdftex-fonts`
がビルド時に直接読んで生成する（リポジトリはプロファイル .def と
ライセンス文のみ）。文字抽出はプロファイル読込時に
`\pdfglyphtounicode` を登録して `\pdfgentounicode=1` で保証（全フィクスチャ
PDF で U+FFFD 0 件・未埋込フォント 0 件を実測）。

JFM データ: pTeX/upTeX/LuaTeX-ja と**同一ソース**（`jfm-jlreq.lua` /
`jfm-jlreqv.lua`）から、横/縦 × 括弧位置 3 種 × ぶら下げ on/off の
**12 変種**（`jlreq-pdftex-jfm*.def`）と manifest
（`pdftex-jfm-manifest.lua`）を決定的生成。負優先度 stretch も保持
（旧 PL 変換の落とし込みは解消済み）。

### 登録済み残差 / Registered limitations

**数値つき残差（2 件）** — いずれも `docs/pdftex-internals.md` に登録済みで、
単一脚注の通常利用の範囲外で発生する:

1. **複数脚注段落時の先頭段列頭**: 1 ページに複数の脚注段落があるとき、
   **先頭**脚注段落の列頭が **+4.95pt**（10pt）行末側にずれる
   （2 段落目以降の列頭・列間隔、および単一脚注は完全一致）。
2. **行内合印オープナーの先頭列残差**: 1 本文行に複数脚注があるときの
   （＊）オープナー（合印チェーン）が **(+3.49, −1.42)pt**
   （複数脚注の fn2 列目以降は 0.00pt 完全一致）。

**既知の欠陥（1 件、未解決・上流チケットとして追跡）**:

3. **見出し後の本文への和文ファミリ漏れ**: CJK のファミリ状態代入が
   常時 global（クラス読込時の日本語リテラルを {...} グループ内で
   評価するために必要）であるため、見出し内の `\gtfamily` が見出し後の
   本文に漏れ、本文がゴシックで組まれる（全 fontset で同一。実測:
   見出し後の「後」U+5F8C が IMFCTT1=ipxg に埋め込まれる）。
   `\CJK@global` は TeX 代入の接頭辞（`\global\edef\x{...}` 形式）として
   使われるためマクロ化による条件分岐は不可能で、`\CJKfamily` 呼び出しの
   包括的な group 復元（`\aftergroup` ベース）も robust 命令の再ラップ
   に形式上の制約があり、本 PR のスコープ外として追跡する。
   `docs/pdftex-compatibility.md` の該当行にも注記済み。

### 検証方法 / Verification

* 一括実行入口 `tests/run-pdftex-tests.sh`: **163 ゲート**（2026-10-25
  実行時点で 0 skip・0 FAIL・0 XFAIL）。必須資源（JFM .def 12 種 +
  manifest、バックエンド .sty、補助縦フォント資源等）の欠損は SKIP ではなく
  **FAIL**。自己申告型検査（banner PASS typeout 等）は廃止済みで、幾何は
  実 PDF の bbox/座標を pymupdf/pdftotext で機械検査する。
* p/u/l 回帰: 実装前の固定条件（`SOURCE_DATE_EPOCH` 固定・同じフォント・
  同じ driver）で記録した**コミット済みベースライン**
  （`tests/reference/baselines/`）と、DVI はタイムスタンプ正規化後・PDF は
  日付/ID 正規化後に**バイト同一**であることをスイートが自動照合。
* 行末調整は `endadjust-lineend.tex` を 4 エンジンでコンパイルし
  `tests/check-endadjust-parity.py` が pdflatex の 1 行目 xMax を参照と
  0.1pt 以内で検査（実測は全エンジン 148.20pt、掃引でも ≤0.01pt）。
* 数値は JFM 元定義から独立に計算した sp 寸法、組版は upLaTeX/LuaLaTeX の
  同一ソース出力を oracle にする（参照値を新実装の出力から生成していない）。
* 配布検証: `make install` を一時 TEXMF に行い、リポジトリ外 cwd から
  `-no-shell-escape` で横組・縦組両文書をコンパイルする staged install
  smoke（shell-out 証跡 0 件・文字抽出照合つき）。
* CI: `.github/workflows/pdftex.yml`（push/pull_request の単一 job で
  4 エンジン suite + 生成物チェック + staged smoke を TeX Live 2025 で
  実行、失敗時に log/PDF/差分を artifact 保存）。

### ビルド・配布 / Build & distribution

* **JFM データ（12 変種 `.def` + manifest）はコミットして配布**
  （利用者が texlua を持たない場合でも動作する。再生成差分 0 を
  `make check-pdftex-jfm` が保証）。
* **フォント派生物はコミットしない**: 補助縦 TTF/TFM/enc と
  HaranoAji 横組変換 TTF は、TeX Live 収録の
  HaranoAji/IPAex/IPA フォントを `make pdftex-fonts`
  （fontTools + ttf2tfm）がビルド時に直接読んで生成する
  （リポジトリにフォントバイナリを含めない。`make install` が
  この生成に依存し、生成は一回きり）。
* 生成器はビルド時のみ実行: `make pdftex-jfm` / `make pdftex-fonts`、
  検査は `make check-pdftex-jfm` / `make check-pdftex-fonts`
  （`texlua check_jfm_pdftex.lua` は 12 変種を元 JFM 全項目と照合）。
* **通常の文書コンパイルは Lua/Python を一切起動しない**
  （インストール済み環境では texlua/Python/fontTools/ttf2tfm 不要）。

### 上流統合に必要な変更 / What integration touches

* **既存ファイルへの変更（最小差分）**:
  * `jlreq.cls` — `pdflatex` クラスオプション、`pdftex_fontset=` /
    `pdftex_fontprofile=` キー、d エンジン分岐（`\mag` 補償、縦組み
    `\Cht/\Cdp` の縦 JFM 値での測り直し、`\today` 和暦・縦組み漢数字、
    数式キャプチャ入口、縦出力ラッパ呼び出し等）。
  * `jlreq-helpers.sty` — エンジン検出（`\pdftexversion` プリミティブで
    pdfTeX を判定）。
  * `jlreq-complements.sty` — `pdflatex` オプション。
  * `jlreq-trimmarks.sty` — d ドライバ（PDF 属性）と shipout/before フック
    による奇偶ページ属性、分離実装 `jlreq-trimmarks-pdftex.def`。
  * `Makefile` — 生成/検査 target と `install`/`tds` への収録。
  * `README.md` / `README-ja.md` — pdfLaTeX 節。
* **新規バックエンドモジュール**: `jlreq-pdftex.sty`（フォント/単位/
  メトリック/数式キャプチャ/出力ラッパ）、`jlreq-pdftex-rules.sty`
  （JFM ペアグルー・禁則・行末候補列・状態機構・縦グリフ）、
  `jlreq-pdftex-ruby.sty`（ruby.sty provider 適合）、
  `jlreq-pdftex-paragraph.sty`（`jlreqparagraph` 厳密段落環境）、
  生成器 `make_pdftex_jfm.lua` / `make_pdftex_fonts.py`、検査器
  `check_jfm_pdftex.lua` / `tests/check-pdftex-fonts.py`、生成データ
  （12 `.def` + manifest + `fonts/pdftex/`）。
* **テスト一式**: `tests/run-pdftex-tests.sh`、fixtures、幾何検査
  `tests/check-*.py`、参照ベースライン `tests/reference/baselines/`、
  CI workflow。
* **ドキュメント**: `docs/pdftex-compatibility.md`（公開 API 互換表）、
  `docs/pdftex-internals.md`（機構と実測表）、`docs/pdftex-tests.md`
  （検証方法）、`docs/pdftex-jfm-generation.md`、
  `docs/pdftex-dependencies.md`（ライセンス境界: GPL 依存とコード流用の
  区別）。
* 依存: bxcjkjatype（CJKutf8 + IPAex Type 1）を内部で読み込む
  （TeX Live 収録済み）。`ipa` プリセットは zhmetrics、ルビは ruby.sty。

### 質問 / Questions for the maintainer

1. 既定フォント設定は `ipaex-type1` でよいか（`ipa` / `custom` プロファイル
   も実装済み）。
2. PR の分割単位の希望（engine 検出 → バックエンド本体 → 生成器とデータ →
   テスト/CI/ドキュメント、の順で分割可能。すべてのゲートは単一の
   `tests/run-pdftex-tests.sh` で実行できる）。

### エビデンス / Evidence pointers

* `README.md`「pdfLaTeX (experimental)」節 — 対応範囲の一次サマリ。
* `docs/pdftex-compatibility.md` — 公開オプション・命令・環境ごとの
  対応状況マトリクス。
* `docs/pdftex-internals.md` — 縦組みの機構と、対照数値（家具ビット一致・δ sp 一致・バナー 0.01pt・残差 2 件）の測定表。（作業記録は pdflatex-worklog ブランチ）
* `docs/pdftex-tests.md` — 検証方法とゲート一覧。
