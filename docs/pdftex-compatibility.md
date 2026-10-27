# pdfTeX 対応状況・公開 API 互換マトリクス（pdftex-compatibility）

- **対象リポジトリ**： [abenori/jlreq](https://github.com/abenori/jlreq)（基準コミット `ac06fd0`、2025-07-17 版 + エンジン検出パッチ適用後の作業ツリー）
- **作成日**： 2026-10-23
- **位置づけ**： 公開機能・オプションごとの pdfTeX 対応状況を `implemented / pending / blocked` で追跡する監査成果物。
- **現時点の状態（2026-10-24、横組/縦組とも実装完了・検証済み）**： pdfTeX で
  `\documentclass{jlreq}` は横組・縦組（`tate`）いずれの文書としても動作する。バックエンドは
  `jlreq-pdftex.sty`（フォント/単位/メトリック/数式キャプチャ/`\kansuji`/出力ラッパ）＋
  `jlreq-pdftex-rules.sty`（JFMペアグルー・禁則・行末候補列・状態機構・縦グリフ）＋
  `jlreq-pdftex-ruby.sty`（ruby.sty provider 適合）＋ `jlreq-pdftex-paragraph.sty`
  （`jlreqparagraph` 厳密段落環境）＋ 生成済みJFMデータ **12変種**（`jlreq-pdftex-jfm*.def`
  + manifest: 横/縦 × ぶら下げ/開き括弧位置の全組合せ）＋ フォントプロファイル
  （`jlreq-pdftex-fonts-{ipaex,ipa,haranoaji}.def` + 補助縦TTF/TFM/enc）。行末調整は4エンジン
  0.000pt parity、縦組みは縦中横・局所方向・全家具・trimmarks縦バナー・ルビまで
  uplatex/lualatex ground truth と数値対照済み。日本語label・和暦`\today`・`\　`綴りも
  実装済み。検証は `sh tests/run-pdftex-tests.sh`（163 ゲート、0 skip・0 XFAIL）が
  管理。歴史的実験（bxcjkvert 経由の縦組み判定など）は現在の構成と区別して
  扱う（作業記録は pdflatex-worklog ブランチ）。

## 1. ステータス定義

| ステータス | 意味 |
|---|---|
| **implemented** | pdfTeX で動作することをテスト（回帰スイート `tests/run-pdftex-tests.sh`）で示した機能 |
| **pending** | バックエンド実装で対応予定。機能は公開 API として維持される |
| **limitation agreed** | 実測の結果、pdfTeXの機構上再現不能と確定した制限。代替手段・理由を備考に記録 |
| **blocked** | pdfTeX の原理的制約により、対応の見込みが立たない、または特別な合意を要する機能 |

完全性レベル L1（API互換）／L2（規則互換）／L3（出力互換）は本書 §5 の定義に従う。

## 2. クラスオプション（`\documentclass[…]{jlreq}`）

`jlreq.cls` 内の全 `\DeclareKeys [jlreq]` ブロック（104–117, 135–147, 290–297, 301–345, 347–405 行）から抽出した全オプション。

### 2.1 エンジン・文書タイプ
| オプション | 定義行 | 役割 | pdfTeX ステータス | 備考 |
|---|---|---|---|---|
| `uplatex` / `platex` / `lualatex` | jlreq.cls:106–108 | エンジン明示指定 | **implemented**（既存） | pdfTeX で指定すると実エンジンとの不一致エラー（jlreq.cls:458–477） |
| `pdflatex` | jlreq.cls:109 | pdfTeX 明示指定 | **implemented** | 指定・自動判定ともに pdfTeX 経路で完走（全フィクスチャ rc=0） |
| `article` / `report` / `book` / `article_type=…` | jlreq.cls:110–113 | 文書タイプ | **implemented** | `book`（\chapterが「第1章」出力）・`report` 実測 rc=0 |
| `pdftex_fontset=`（`ipaex-type1`/`ipa`/`haranoaji`/`custom`） | jlreq.cls:114–115 | pdfTeXバックエンドのフォント設定 | **implemented** | 既定 `ipaex-type1`（従来どおりType1平面 ipxm/ipxg＋補助縦TTFプロファイル `jlreq-pdftex-fonts-ipaex.def`）。`ipa` は bxcjkjatype の `ipa` プリセット（zhmetrics TFMチェーン）＋`jlreq-pdftex-fonts-ipa.def`（実測: 縦組 doc が IPAMincho TrueType 埋込＋縦字形抽出で完走）。`haranoaji` は TeX Live 標準の原の味（HaranoAji, OTF配布）: HaranoAji には .sty/.tfm 支持ファイルが無いため、**横組**は zhmetrics 動的TFMチェーン（unisong@Unicode@ 等）をそのまま再利用し pdfmapline の埋込先だけをビルド時に生成した CFF→二次曲線変換フルTTF（`haranoaji-{mincho,gothic}[-bold]-ttf.ttf`, cu2qu max_err 0.5/1000upem）へ切替、**縦組**は `jlreq-pdftex-fonts-haranoaji.def`（補助縦TTF `jlreqv-haranoaji-*` は vert/vrt2 置換650コードポイントをカバー）。**太字は実Bold面**（bxcjkjatype multiweight: mnb→unili@Unicode@, gtb→uniyou@Unicode@; pdffonts 実測で HaranoAjiMincho-Bold/HaranoAjiGothic-Bold 埋込、embolden 2 Tr ではない）。実測: 横組4面・縦組（補助縦+縦中横+脚注）抽出照合、600dpi ラスタで OTF 原字形と ink bbox 同寸・fill 比 0.3–1.4% 一致（`haranoaji-yoko`/`haranoaji-tate` ゲート、staged smoke で kpathsea 解決を実証）。`custom` は `pdftex_fontprofile=<file>` 必須（未指定・ファイル不在は生成手順つきの明示エラー; 横組みのみの文書は縦データ不要で通る） |
| `pdftex_fontprofile=<file>` | jlreq.cls:116–117 | custom プロファイル指定 | **implemented** | `make_pdftex_fonts.py --fontset custom --mincho <TTF> --gothic <TTF> --profile <file>` が生成。tate で縦グリフ表の無いプロファイルは生成方法つきエラー（回転への黙ったフォールバックはしない） |


### 2.2 紙・版面

| オプション | 定義行 | 役割 | pdfTeX ステータス | 備考 |
|---|---|---|---|
| `paper=…`（a0–a10, b0–b10, b0j–b10j, c2–c8, a4var, b5var, letter, legal, executive, ansia–ansie, hagaki, または `幅,高さ`） | jlreq.cls:135–147, 194–276 | 用紙サイズ | **implemented** | `paper=b5` 実測（options-sweep.tex）。`\pdfpagewidth`/`\pdfpageheight` は pdfTeX 互換で流用 |
| `a0paper`–`a10paper` 等（サイズ名キー一式） | jlreq.cls:206–276 | 用紙サイズショートカット | **implemented** | `a4paper` 実測。上に同じ |
| `fontsize=…` / `10pt` / `11pt` / `12pt` | jlreq.cls:290–294 | 欧文フォントサイズ | **implemented** | `fontsize=12pt` 検証済み（options-sweep.tex）。Q/H単位も**implemented**（桁対応の書き換えで 1Q=1H=0.25mm に変換）: `fontsize=13Q` 実測 9.24695pt（options-qh-units.tex）。`fontsize=1.2zw` のような zw/zh 指定は自己参照になるため jlreq.cls:611–626 のガードが明示 ClassError を発する（以前は暗黙に 0pt 化していた） |
| `jafontsize=…` | jlreq.cls:295 | 和文フォントサイズ | **implemented** | `jafontsize=13pt` 実測: JAFS=13pt/FS=13pt/SCALE=1。`jafontsize=13Q` も実測（options-qh-units.tex、Q/H単位対応済み） |
| `jafontscale=…` | jlreq.cls:296 | 和文/欧文サイズ比 | **implemented** | `jafontscale=1.2` 実測: SCALE=1.2/JAFS=11.99997pt 正常 |
| `line_length=…` | jlreq.cls:301 | 行長 | **implemented** | `line_length=40zw` 検証済み（options-sweep.tex） |
| `number_of_lines=…` | jlreq.cls:304 | 1 ページ行数 | **implemented** | `number_of_lines=10` 検証済み（options-sweep.tex） |
| `head_space=…` / `foot_space=…` / `gutter=…` / `fore_edge=…` / `fore-edge=…` | jlreq.cls:309–321 | 天・地・のど・小口 | **implemented** | options-sweep.tex で検証（pt指定）。tate 併用の幾何対照は `furniture-options` ゲートで固定（twoside 非対称 gutter + twocolumn + 遅延注 + marginpar; oddsidemargin 12.7299pt / evensidemargin 82.73001pt が uplatex 同一ソースとビット一致——旧「数ミリのオフセット」は縦組み `\Cht/\Cdp` を縦JFM class 0 で測り直して解消） |
| `baselineskip=…` / `linegap=…` | jlreq.cls:336–339 | 行送り | **implemented** | `baselineskip=20pt` 検証済み（options-sweep.tex）。zw/zhリテラルはクラスロード時書き換えパスで処理 |
| `column_gap=…` | jlreq.cls:332 | 段間 | **implemented** | `column_gap=2zw` 検証済み（options-sweep.tex + microtype-twocolumn.tex で二段組実測） |
| `sidenote_length=…` | jlreq.cls:355 | 傍注の長さ | **implemented** | `sidenote_length=5zw` 実測 rc=0（zwリテラル書き換え対象リストに追加済み） |
| `headfoot_verticalposition=…` / `headfoot_sidemargin=…` | jlreq.cls:326–329 | 柱・ノンブル位置 | **implemented** | `3zw`/`2zw` 指定実測 rc=0（zwリテラル書き換え対象）。縦組文書では柱行は縦出力ラッパで版面高巾に組まれる（家具行幅の論理/物理区別は jlreq-pdftex.sty の一箇所に集約） |

### 2.3 組み方
| オプション | 定義行 | 役割 | pdfTeX ステータス | 備考 |
|---|---|---|---|---|
| `open_bracket_pos=`（`zenkaku_tentsuki`/`zenkakunibu_nibu`/`nibu_tentsuki`） | jlreq.cls:344 | 行頭括弧配置（3.1.5） | **implemented**（データ選択） | `zenkakunibu_nibu` 指定でJFM variant `z`（クラス1幅1.0+全クラス→1グルー−0.5）を選択、`nibu_tentsuki` は既定にフォールバック（pLaTeXと同一挙動）。行頭括弧フック自体は段落開始リセットのみで、空き規則はJFMデータが担う |
| `hanging_punctuation` | jlreq.cls:347 | ぶら下げ組み（3.8.2） | **implemented**（`-b` 系全 6 変種: yoko -b/-bz/-bn、tate -tate-b/-tate-bz/-tate-bn） | **現行機構**: ぶら下げは -b 変種 JFM のクラス6/7 end_adjust 負候補（{-0.5, 0, 0.5}zw）として**行末限定の kern/penalty 候補列**で表現（`\jlreqpdf@emitboundary`/`\jlreqpdf@easeries`、jlreq-pdftex-rules.sty:536–554）。行中は正味 0、行末 break だけが選択候補を行に残し、突出し量は upLaTeX と一致。通常段落末尾は para/end フックが最終和文字の負最小候補を parfillskip 前の tail kern として挿入（ltj insert_lineend_kern_tail 相当）。実測: 行末候補列カーン ±5pt・2 行組・混在長文（hanging-punct.tex、HANG-PASS）。**歴史（2026-10-24 に機構置換）**: かつて `\pdfprotrudechars=2`＋`\rpcode` で実装していたが、マージンカーンの二重計上（名目 0.5zw が実測約 1zw）により置換。裸字形分岐・負 hangkern とともに撤去済みで、本バックエンドは `\rpcode` を一切設定しない（microtype 欧文 protrusion と二重調整しない） |
| `narrow_kanjiskip` | jlreq.cls:350 | jsarticle 互換の詰め字間 | **implemented** | 実測: `\jlreqkanjiskip` = `0pt plus .1zw minus .01zw` に変化。未定義ペアのフォールバックグルーとして実行時に適用 |
| `use_reverse_pagination` | jlreq.cls:362 | 逆ノンブル | **implemented** | 実測 rc=0（auxラベル機構はエンジン非依存） |
| `disablejfam` | jlreq.cls:402 | 数式内和文の無効化 | **implemented** | jfam 相当は enablejfam（既定）で実装済み: `\mathmc`/`\mathgt` は `\mathchoice` ボックス経由で和文を供給。4分岐の組版回数を 4→3 に削減（display/text 同一サイズ分岐は box+copy 共有）し、縦組みでは方向一致部品の counter-shift（δ×1000/700/500÷1000）を適用（uplatex GT10 実測と一致: 部品静止位置 = plain−δ_yoko）。数式中の直接和文入力・行列セル内和文も動作（math-jfm.tex、math-matrix.tex）。disablejfam 指定時は `\mathmc`/`\mathgt` 未定義のまま（(u)pTeX と同一パリティ、math-jfm-disablejfam.tex） |
| `tate` | jlreq.cls:376 | 縦組み | **implemented**（横組・縦組とも全面検証済み） | shipout rotation 構成で実現（内枠横組 galley＋和文グリフ+90°回転＋**縦出力ラッパ** — kernel `\@outputpage` 本体丸写しは撤去、begindocument 保存の元実実装を回転＋`textwidth↔textheight` の一点だけの寸法差し替えで呼ぶ; build/page フックと hook 付き shipout は素通りを機械検証）。縦データ `jlreq-pdftex-jfm-tate*.def` 6変種は **jfm-jlreqv.lua**（オプションフック付き・負優先度stretch保持）から自動生成（旧 `jfm-jlreqv-pl.lua` のPL落ち込みは解消）、縦字形はフォントプロファイル（`jlreq-pdftex-fonts-*.def`＋補助縦TTF/TFM/enc）で供給: vert/vrt2 置換グリフは直立のまま補助縦フォントから出力し、それ以外は回転、進行幅はJFMクラス幅×現在zw（旧 `off@` 固定pt表は廃止）。実測: 上→下・右→左・禁則ゼロ違反、見出し・目次・ページ家具（柱・ノンブル）は uplatex と bbox/cm 行列で一致。**縦中横**（`\tatechuyoko`: 1zw進行・uplatex showbox/PDF一致、star透過・yoko非starはClassError）、**局所方向**（`ifydir/iftdir` 実方向・箱工場・theindex横組ページ復帰）、**縦バナー**（全スロット族 uplatex GT と 0.01pt 一致）、**ルビ**（ruby.sty provider 適合・読み枠右）、**割注・保存位置**（savepos 論理行方向ビット一致・mag≠1000 同一値）、**`\today`縦組み漢数字**まで検証済み。数式は δ=plcore adjustbaseline 同一式。**対象外は空**（旧 ClassWarning の対象外列挙は全件解消、警告は ClassInfo に縮小）。bxcjkvert 自体は提供範囲外 |
| `landscape` | jlreq.cls:372 | 横置き | **implemented** | `landscape,a4paper` 実測: 841.89×595.28pt（縦横交換） |
| `tombo` / `tombow` / `mentuke` | jlreq.cls:373–375 | トンボ（jlreq-trimmarks.sty へ案内） | **implemented** | jlreq-trimmarks は pdfTeX でトンボ描画・TrimBox/BleedBox・回転バナー（`\rotatebox{-90}` 代替）に対応（trimmarks.tex、trimmarks-banner.tex）。クラスオプション経由の案内は従来どおり警告で trimmarks.sty へ |
| `oneside` / `twoside` / `onecolumn` / `twocolumn` / `titlepage` / `notitlepage` | jlreq.cls:382–387 | ページ構成 | **implemented** | `twoside`+`titlepage`（book）実測 rc=0、`twocolumn` 実測（microtype-twocolumn）、`notitlepage`+`onecolumn`+`oneside`（report）実測 rc=0 |
| `draft` / `final` | jlreq.cls:388–389 | 下書きモード | **implemented** | `draft` 実測 rc=0 |
| `openright` / `openany` / `leqno` / `fleqn` | jlreq.cls:395–398 | 書籍構成・数式番号 | **implemented** | `openright`+`leqno`+`fleqn` 実測 rc=0 |
| `jlreq_notes` | jlreq.cls:405 | JLREQ 注記の表示 | **implemented** | `\message` のみでエンジン非依存。ただし注記の「行長は52文字以下…」（jlreq.cls:1631 等）は版面計算成立後に意味を持つ |

## 3. `\jlreqsetup` キー

`jlreq.cls` 内の全 `\keys_define:nn { jlreqsetup }` ブロック（3393, 3481, 3490, 3524, 3735, 3828, 3852, 3922, 3995, 4032, 5343, 5430, 5638, 5816, 5844, 5980, 6175, 6248, 6283, 6320, 6516 行）から抽出した全キー。pdfTeX 経路でも `\jlreqsetup` はそのまま動作し、長さ値のリテラル `zw`/`zh`/`Q`/`H` 書き換え（jlreqsetup 用の latin-zw/Q/H 書き換えパス）にも対応済み（jlreqsetup-zw.tex）。

| キー（代表例） | 定義行（代表） | 役割 | pdfTeX ステータス | 備考 |
|---|---|---|---|---|
| `reference_mark=`（`inline`/`interlinear`） | jlreq.cls:3393–3427 | 合印（4.2.3） | **implemented**（inline / interlinear 両方） | `inline` 実測 rc=0。`interlinear` も implemented（fixjfm シムのスナップショット/リストアで状態機構との整合を確保）: 合印を跨ぐ JA ペアグルーが直接配置と一致（30.0pt==30.0pt、reference-mark-interlinear.tex、INTER-PASS 3アサーション） |
| `footnote_indent=…` / `footnote_second_indent=…` | jlreq.cls:3481, 3490 | 脚注の字下げ（4.2.5） | **implemented** | `2\zw`/`1\zw` 形式に加えリテラル `2zw` も対応（jlreqsetup の latin-zw 書き換え）: `footnote_indent=2zw` 実測 JSETUP-FNI=20.0pt（jlreqsetup-zw.tex） |
| `endnote_counter=…` / `endnote_second_indent=…` / `endnote_position=…` | jlreq.cls:3735, 3829, 3852 | 後注（4.2.4） | **implemented**（キー設定） | `endnote_second_indent=2\zw`+`endnote_position=headings` 実測 rc=0 |
| `sidenote_type=` / `sidenote_counter=…` / `sidenote_symbol=…` / `sidenote_keyword_font=…` | jlreq.cls:3922, 3995 | 傍注（4.2.7） | **implemented** | `\sidenote` 命令が両型で動作（下表4.1参照）: number 型（sidenote.tex）、symbol 型（sidenote-symbol.tex）とも rc=0 |
| `warichu_opening=…` / `warichu_closing=…` | jlreq.cls:4032–4045 | 割注（3.4）の括弧 | **implemented** | options-sweep.tex で検証、\warichu 自動2行折返し実測（footnotes-warichu.tex、3パスで安定） |
| `caption_font=…` / `caption_label_font=…` / `caption_label_format=…` / `caption_after_label_space=…` / `caption_align=…` | jlreq.cls:5343, 5430 | キャプション | **implemented** | caption_font/label_format 検証済み（options-sweep.tex）、caption を含む表・図は table-tabular/graphicx-xcolor で実測 |
| `abstract_with_maketitle=` | jlreq.cls:5638 | abstract の配置 | **implemented** | `abstract_with_maketitle=true`+\maketitle 実測 rc=0 |
| `itemization_beforeafter_space=…` / `itemization_itemsep=…` / `itemization_labelsep=…` / `itemization_label_length=…` | jlreq.cls:5816 | 箇条書き | **implemented** | itemization_* 検証済み（options-sweep.tex）、リスト実測（lists.tex） |
| `quote_indent=…` / `quote_end_indent=…` / `quote_fontsize=…` / `quote_beforeafter_space=…` | jlreq.cls:5844 | 引用 | **implemented** | quote_indent=2\zw 実測 rc=0。リテラル形式も対応: `quote_indent=2zw` 実測 JSETUP-QI=20.0pt、`quote_end_indent=0.5zw` 実測 JSETUP-QEI=5.0pt（jlreqsetup-zw.tex） |
| `tableofcontents_heading=…` / `tableofcontents_twocolumn=` | jlreq.cls:5980 | 目次 | **implemented** | `tableofcontents_heading` 実測 rc=0（2パス）。リーダーの\inhibitglueは実装済み（1境界抑止）。headings-toc-aux.tex で目次・\ref 往復実測。tate 2パス目の "Leaders not followed by proper glue" 不良（frame-pop `\aftergroup` + 内部数式ゲートの群括りの重畳）を解消、`toc-twopass` ゲートで固定（docs/pdftex-internals.md「出力ルーチンと semantic frames」節） |
| `frontmatter_*` / `mainmatter_*` / `backmatter_*`（pagebreak/pagestyle/counter/heading/precode/postcode/pagination 計 21 キー） | jlreq.cls:6176, 6249, 6284 | 前付・本体・後付 | **implemented**（既定動作） | \frontmatter/\mainmatter/\backmatter 実測 rc=0（book、ローマ数字→アラビア数字切替）。個別キー上書きは未網羅 |
| `appendix_counter=…` / `appendix_heading=…` / `appendix_precode=…` / `appendix_postcode=…` | jlreq.cls:6321 | 付録 | **implemented**（横組既定） | \appendix+\chapter 実測 rc=0（横組）。縦組時の `\tatechuyoko*` は未検証 |
| `year_style=`（`seireki`/`wareki`） | jlreq.cls:6516–6519 | 西暦/和暦 | **implemented**（横組） | `wareki` 実測 rc=0。\todayは横組固定。`\kansuji` は展開可能マクロとして実装済み（4.1の行を参照） |
## 4. 公開命令・環境

### 4.1 基本組版（横組み）

| 命令/環境 | 定義行 | 役割 | pdfTeX ステータス | 備考 |
|---|---|---|---|
| `\zw` / `\zh` / `\Cht` / `\Cdp` / `\Cwd` / `\Cvs` / `\Chs` | jlreq.cls:1333–1338（C* 系）、524–527（zw/zh） | 全角単位・文字寸法 | **implemented** | 実測済み: Cwd=10.0/Cht=8.8/Cdp=1.2/Cvs=17/Chs=10pt @10pt、\zw/\zh=dimenレジスタマクロ（サイズ追従）。pairs.tex 7計測で精度確認 |
| `\jafontsize` | jlreq.cls:1295 | 和文サイズ指定付きフォントサイズ変更 | **implemented** | jafontsize=13pt/jafontscale=1.2 実測（表2.2参照） |
| `\mcfamily` / `\gtfamily` / `\bfseries` 等の和文ファミリ連動 | jlreq.cls:1156–1162 | 欧文 NFSS と和文ファミリの連動 | **implemented** | bxcjkjatypeフック（C70/ipxm・ipxg）＋selectfontフックのseries追跡（カーネル判定 b始まり=太字）。\gtfamily見出し実測（mixed）、CJKbold 2 Tr 実測（italic-substitution.tex）。**既知の欠陥（未解決）**: CJK のファミリ状態代入が常に global（クラス読込時の日本語リテラル評価のため必要）であるため、見出し内の `\gtfamily`（`\sffamily` の CJKfamily 付加経由を含む）が見出し後の本文に漏れ、本文がゴシックで組まれる（全 fontset で同一。実測: 見出し後の「後」U+5F8C が IMFCTT1=ipxg に埋め込まれる）。`\CJK@global` は TeX 代入の接頭辞として使われるため単純なマクロ化では修正不能 — 上流チケットとして追跡 |
| `\jaspace=`（`zenkaku`/`nibu`/`shibu`） | jlreq.cls:1180, 1205 | 和文間隔 | **implemented** | `\jaspace{zenkaku}`/`{nibu}` 実測 rc=0（全角・二分の\hskip）。`\　`綴は**blocked**: pdfTeXではU+3000がletterでなく制御綴化できない（`\ifcat A　`=FALSE実測）。U+3000リテラル文字はCJK文字として正常出力 |
| 区切り約物（`！？`）直後の空き | jlreq.cls:1223–1230 | 区切り約物（4.2.8）直後の空き | **implemented**（JFMデータ） | jlreq APIは文字入力ベースで、直後の空きはJFMクラスペアグルー（クラス5の pair 5→c グルー）で処理。`\！`なる単独命令はjlreq APIではなくpTeXカーネル由来（pdfTeXでは未定義=非API） |
| `\jidori` | jlreq.cls:6433, 6450 | 字取り（2.2.2） | **implemented** | 自前グルー規則のjidorimode=2（文字間 0pt+1fil、\hbox to Lで均等分散）。実測: \jidori{60pt}{字取} で文字間13.2ptに分散 |
| `\akigumi` | jlreq.cls:6462 | 空き組み | **implemented** | jidorimode=1（文字間に固定空き）。実測: \akigumi{3pt}{空き組} で文字間13.0pt（10pt字面+3pt空き） |
| `\tatechuyoko` | jlreq.cls:6336 | 縦中横 | **implemented**（縦組） | 局所方向エンジン（方向 `\jlreqpdf@dir`）+ 箱工場 `\jlreqpdf@yokobox@strut` で正規化埋込み。uplatex 同一ソース showbox・PDF bbox 実測契約: advance=1zw（1〜4桁で固定、はみ出し対称）・cross=体幅半分ずつ・digit baseline=進行起点・star 形は tate で同一構造/yoko で透過・yoko 非 star 形は ClassError。ゲート: tcy-basic（PDF 幾何）+ tcy-digits/tcy-fontchange/tcy-star-error（tests/fixtures/pdflatex-tate/） |
| `\warichu` / `\inlinenote` | jlreq.cls:4020, 4026 | 割注（3.4） | **implemented** | \warichu 自動位置計算2行折返し実測（footnotes-warichu.tex、3パス安定）。括弧測定はJFMデータ、\inhibitglueはno-opシム |
| `\footnote` / `\footnotemark` / `\footnotext` | jlreq.cls:3532–3555（フック適用） | 脚注（4.2.5） | **implemented** | footnotes-rules.tex で3種すべて実測 rc=0（脚注内の禁則・ペアグルーもbbox走査で確認）。注記フックの`\lastnodechar`依存は-1固定で無害化 |
| `\endnote` / `\endnotemark` / `\endnotext` / `\theendnotes` | jlreq.cls:3746, 3751, 3798 | 後注（4.2.4） | **implemented** | キー実測（表3.1）＋脚注と同一の注記経路 |
| `\sidenote` / `\sidenotemark` / `\sidenotetext` | jlreq.cls:3929–3931, 3974–3976 | 傍注（4.2.7） | **implemented** | 両型とも動作（sidenote.tex、sidenote-symbol.tex、rc=0）。旧障害の根因は2件とも修正済み: (1) `\marginpar` ボックス調整の `\jlreq@jareg` 桁連結（`Dimension too large`、jlreq.cls:1468–1477 修正）、(2) 既定＊マークの素 `\edef` がアクティブ CJK 文字を潰す問題（`\protected@edef` 化、jlreq.cls:4204–4217）。縦組時の傍注は未検証 |
| `\西暦` / `\和暦` / `\today` / `\kansuji` | jlreq.cls:6918–6960, 1485–1620 | 日付表記・漢数字 | **implemented** | `\today` は `\ifjlreq@seireki` を反映（wareki→`\jlreq@wareki` 元号表、tate→`\jlreq@pdf@kansuji`、yoko→`\number`）。和暦5境界日（1989-01-07 昭和64年/1989-01-08 平成元年/2019-04-30 平成31年/2019-05-01 令和元年/1926-12-24 昭和元年）を date-boundaries.tex で実測。`\西暦true`/`\西暦false`/`\和暦` は漢字綴りディスパッチャ（control symbol `\<先頭byte>` + 残りbyte列の完全一致消費 → protected ASCII 命令）で利用可能。lualatex 参照との抽出比較一致（today-wareki ゲート）。`\kansuji` は pTeX 同一仕様の桁置換展開可能マクロ `\jlreq@pdf@kansuji`（kanji-numbers.tex、KANSUJI-PASS 13） |
| `\　`（`U+3000`）命令形 | jlreq.cls:1485–1620（d分岐ディスパッチャ + zenkaku main） | 全角空白の後の空白処理 | **implemented** | `\　` 綴は漢字綴りディスパッチャで成立する: control symbol `\<e3>` + 残りbyte列（80 80）の完全一致消費 → `\jlreq@pdf@zenkakuspace`（1zw skip + 後続ASCII空白の無視 + 区切り約物直後の JFM 追い込みは live `\jlreq@lastnodechar`/`\jlreq@fixjfm` で判定）。literal U+3000 と `\jaspace{zenkaku}` は従来どおり別経路で動作（space-dispatcher.tex で3経路の同一描画を実測） |

### 4.2 見出し

| 命令/環境 | 定義行 | 役割 | pdfTeX ステータス | 備考 |
|---|---|---|---|---|
| `\DeclareBlockHeading` / `\NewBlockHeading` / `\RenewBlockHeading` / `\ProvideBlockHeading` | jlreq.cls:2402, 2690–2696 | 別行見出しの宣言 | **implemented** | `font={size=14pt}` で宣言+使用を実測 rc=0。行取り計算の`\hbox{阿}`は上記の実証済みメトリックで動作 |
| `\DeclareTobiraHeading` / `\NewTobiraHeading` / `\RenewTobiraHeading` / `\ProvideTobiraHeading` | jlreq.cls:1869, 1967–1973 | 扉見出しの宣言 | **implemented** | `number=true`で宣言+使用を実測 rc=0 |
| `\DeclareRuninHeading` / `\NewRuninHeading` / `\RenewRuninHeading` / `\ProvideRuninHeading` | jlreq.cls:3085, 3170–3176 | 同行見出しの宣言 | **implemented** | `font={size=12pt}`で宣言+使用を実測 rc=0 |
| `\DeclareCutinHeading` / `\NewCutinHeading` / `\RenewCutinHeading` / `\ProvideCutinHeading` | jlreq.cls:3264, 3306–3312 | 柱見出し（cut-in）の宣言 | **implemented** | `font={size=12pt}`で宣言+使用を実測 rc=0 |
| `\ModifyHeading` / `\SaveHeading` | jlreq.cls:3316, 3343 | 見出しの変更・保存 | **implemented** | `ModifyHeading{section}{number=false}`+`SaveHeading{section}{\savedsec}` 実測 rc=0 |
| `\SetBlockHeadingSpaces` | jlreq.cls:2740 | 別行見出しの空き設定 | **implemented** | `{_section {lines=2}}` 構文で実測 rc=0（uplatex/lualatexでも同一入力動作で回帰なし） |
| `chapter` / `section` / `subsection` 等の標準見出し | jlreq.cls:6548–6584（横組縦組両定義） | 標準見出し | **implemented**（横組）／**blocked**（縦組定義） | book/article双方で \chapter(第1章)/\section/\subsection 実測（headings-toc-aux.tex）。縦組用定義は未対応 |
| `\maketitle` / `abstract` 環境 | jlreq.cls:5527, 5557, 5641 | 表題・概要 | **implemented** | 実測: 表題/著者/日付/概要出力（headings-toc-aux.tex、tests/fixtures/pdflatex-mixed.tex）。abstractはarticle/reportのみ（bookでは非定義=上流仕様どおり） |

### 4.3 ページスタイル・ページ構成

| 命令/環境 | 定義行 | 役割 | pdfTeX ステータス | 備考 |
|---|---|---|---|
| `\DeclarePageStyle` / `\NewPageStyle` / `\ModifyPageStyle` | jlreq.cls:4964, 5238, 5247 | ページスタイルの宣言 | **implemented** | NewPageStyle+ModifyPageStyle 実測 rc=0。縦組柱・ノンブルは薄い出力ラッパで本数値対照済み（`furniture-options` ゲート: 家具行幅=版面高、uplatex 対照ビット一致） |
| `headings` / `myheadings` 等の既定ページスタイル | jlreq.cls:6599–6626 | 標準ページスタイル | **implemented** | `\pagestyle{headings}` 実測 rc=0。plain/headings/myheadings全て横組定義（縦組文書では柱は縦出力ラッパ経由で版面高巾に組まれる） |
| `\frontmatter` / `\mainmatter` / `\backmatter` | jlreq.cls:6234, 6261, 6308 | 前付・本体・後付 | **implemented** | book実測: ローマ数字ノンブル(iii/iv)→アラビア数字(1)切替、\appendix で付録A出力（headings-toc-aux.tex） |
| `\appendix` | jlreq.cls:6326 | 付録 | **implemented** | 実測: 付録A出力（headings-toc-aux.tex） |
| `\tableofcontents` / `theindex` / `thebibliography` | jlreq.cls:5955, 6066, 6038 | 目次・索引・参考文献 | **implemented** | 目次リーダー実測（headings-toc-aux.tex）。tate + TOC の2パス目不良は解消済み（`toc-twopass` ゲート）。`theindex` は横組文書で`\yoko`がno-opのため実質利用可（縦組文書ではページ方向フラグで本当の横組みページ） |
| `figure` / `table` / `caption` | jlreq.cls:5476, 5504（環境）、5306–5340（キャプション機構） | 図表 | **implemented** | figure/table+caption、tabular 実測 rc=0（table-tabular.tex、graphicx-xcolor.tex） |
| `enumerate` / `itemize`（`\@listi`–`\@listvi` 再定義） / `quote` / `quotation` / `verse` / `description` | jlreq.cls:5835–5842（リスト初期化）、5873, 5893（quote 系）、5739（description） | 箇条書き・引用 | **implemented** | 6環境すべて実測 rc=0（lists.tex） |

### 4.4 関連パッケージの公開 API

| パッケージ | 対象 | pdfTeX ステータス | 備考 |
|---|---|---|---|---|
| `jlreq-helpers.sty` | エンジン検出・共通マクロ | **implemented**（検出部分） | `\jlreq@helper@guessengine`（jlreq-helpers.sty:377–394）が `\pdftexversion` で `d` を返す。その他のマクロはエンジン非依存 |
| `jlreq-complements.sty` | thebibliography/theindex/定理環境のカスタマイズ | **implemented**（横組） | `pdflatex` オプション追加（jlreq-complements.sty:21–22）．pdfTeX 分岐: `\__jlreq_complements_iftdir:` 常に偽（横組のみ），`\inhibitglue` 無害化，`\jlreq@zw` はバックエンドの `\jlreq@jareg` にフォールバック．検証: amsthm定理・thebibliography・theindex入り文書がrc=0（tests/fixtures/pdflatex-coexist/） |
| `jlreq-trimmarks.sty` | トンボ・裁ち落とし | **implemented** | `pdflatex` エンジンオプション追加。plcore相当の最小実装を分離ファイル `jlreq-trimmarks-pdftex.def` で提供（`\iftombow`/`\@tombowwidth`/`\@@paper*`/`\@tombowreset@@paper` + `build/page/reset`・`shipout/background` フック，lltjcoreと同一設計）。**分離の理由**: d分岐の中身にpTeXで実在する条件名（`\iftombow`等）が含まれるため，`\ifx`偽の条件スキップが対応を壊す（実証済み）。PDF属性（TrimBox/BleedBox）は専用ドライバ `d`。**奇偶ページ属性（2026-10-24）**: `\@outputpage` の `\tl_put_left/right:Nx` 前後付けパッチを廃止し、ラベル付き `shipout/before` フック（label `jlreq-trimmarks`）が出荷ページの `\c@page` から奇偶を決めて `\pdfpageattr` を設定する（対称bleed時は従来どおり単一の全体設定）。旧パッチは奇数ページにしか属性が乗らず、非対称gutterの両面文書で全ページ "Missing number" を出していた（実証済み、修正で解消）。あわせて d ドライバへの DVI papersize special（"Non-PDF special ignored!" の原因）を f/s/o 専用にゲートした。検証: 4エンジンでrc=0，トンボ描画・拡大紙面（642.9×852.7pt）・抽出正常（tests/fixtures/pdflatex-coexist/trimmarks.tex）、奇偶BleedBoxの3ページ辞書検証（trimmarks-twoside.tex + tests/check-trimmarks-pageattr.py）。回転バナーも implemented: `\rotatebox{-90}` 代替。**縦組バナー幾何（2026-10-24）**: pTeX の tate 箱の ht/dp 読みは回転箱に 1:1 で移らない（回転インクは常に基準点の右・下に伸びるが pTeX 箱のインクオフセットはスロット族ごとに異なる）ため、スロット族別の在庫補正を jlreq-trimmarks.sty の d 分岐に追加した: tate@top@left と intate@top@right は錨をクロス幅だけ左へ、tate@bottom@right と intate@bottom@left は右へ、下段族全てはランを自身の長さだけラッパ内で上へ事前シフト（スロット零化でトンボ行幾何は不変）。クロス幅=回転箱 wd、ラン長=同 dp という箱自身の寸法の公式であり、uplatex ground truth（2つの bleed 構成・両偶奇ページ・2〜11文字）から導出し両構成で 0.01pt 一致を再検証した（trimmarks-banner.tex の横組窓も実測値に一致）。検証: trimmarks-tate-banner.tex + tests/check-banner-tate.py（20スロット、0.5pt窓）。ページ方向（`\jlreqpdf@pagedir`）: バナー描画は shipout/background で物理ストック枠に対して行われ、補正係数はバナー箱自身の寸法（cross/runlen）のみの関数でページ方向に依存しないため、pagedir=0（theindex_yoko 等で横組み出荷されるページ）でも同一のストック端バナーになる（構成上の性質; shipout/before フックがページ毎に発火し \c@page を正しく読むことはログプローブで実証: pagedir プローブで c@page=1,2）。 |
| `\jlreqtrimmarkssetup`（trimmarks の設定命令） | `trimmarks_paper=…` / `show=…` / `bleed_margin=…` / `trimmarks_width=…` / `color=…` / `trimmarks_pattern=…` / `banner=…` | **implemented** | pdfTeX経路でも動作。`banner=…` も implemented（回転は `\rotatebox{-90}` 代替、`tate` プリミティブ不要）。検証: trimmarks-banner.tex（バナー文字列回転表示・トンボ画素一致） |
| `\jlreqcomplementssetup`（complements 単独使用時の設定命令） | thebibliography_*/theindex_*/theorem_* 系キー | **implemented** | pdflatexオプション経由で動作（jlreq-complements.sty:11–22, 74–91, 123–150, 197–217） |
| `jlreqparagraph` 環境（厳密段落・優先順位付き伸縮） | `\begin{jlreqparagraph}...\end{jlreqparagraph}`（引数なし・一環境一段落） | **implemented**（配分エンジン全段階・aw_step1_last 最終行再選択まで実装・実測; 2-tier 差・同一ソース oracle 比較は tests に記録） | `jlreq-pdftex-paragraph.sty`（`jlreq-pdftex.sty` が自動読込）。環境入口で段落パラメータ全件を snapshot、native breaker で影 paragraph を一度だけ改行（独自 DP なし）、net-0 kern マーカーで逆走して行範囲を回復、測定行 box をそのまま出力（interline penalty/glue は walk から再生）。入力モデルは明示: CJK/欧文word/空白/`\inhibitglue`/`\hspace`/`\kern`/`\penalty`/`\allowbreak`/inline math/`\mbox`/`\makebox`/label・hyperlink。`\footnote`/`\marginpar`/`\[` は具体的エラー、未知マクロは TeX 自身のエラー。優先度 tier 配分（JFM×10/kanjiskip 0/xkanjiskip 10,-30/glue 50）の行 box への再適用と最終行 parfillskip 候補選択まで実装・実測済み。検証: `strict-basic`/`strict-inputmodel`/`strict-errors`/`strict-integration`/`strict-tate`（T11 ゲート） |
| `ruby.sty`（CJKパッケージのルビ provider） | `\ruby{base}{ruby}`、overlap/nooverlap、`\rubysize`/`\rubysep` | **implemented** | 適合アダプタ `jlreq-pdftex-ruby.sty`（`package/ruby/after-load` フック + `\AtBeginDocument` フォールバック: provider のロード前後どちらでも有効）。jlreq 独自の `\ruby` は定義しない（README の API 方針を維持）。base/annotation は provider 自身の `\sbox` で各1回だけ組成し、base 端クラスを記録、annotation は隔離、本文側の境界グルーは共有 evaluator で1回だけ発行（provider の overlap 計算は net-0 復元した kern sentinel で保存）。横=上付き・縦=読み枠右側。検証: `ruby-basic`/`ruby-tate`（連続/overlap/nooverlap・本文より長いルビ・句読点隣接・書体/サイズ変更・hyperref・状態隔離; lualatex+ruby.sty 同一ソース対照で yoko ベースラインオフセット完全一致）、`ruby-adapter-noop-without-provider`（provider 無しでは何も定義しない）。GPL コードのコピーなし |

## 5. 完全性レベルと到達目標

| レベル | 内容 | 現状 |
|---|---|---|
| **L1 API互換** | 公開オプション・命令・環境 | 横組みスコープの全項目を本表で追跡・検証済み（非対応項目は limitation agreed / blocked として明示） |
| **L2 規則互換** | JFM・禁則・約物・和欧文間空き | 実装・検証済み |
| **L3 出力互換** | 改行・座標・ページ分割の等価性 | 望遠目標。pdfTeX と参照エンジンで字体・TFM が異なる限り、バイト一致ではなく「正規化した比較」を採用 |

## 6. 既知の制約（現時点で確定しているもの）
1. **~~縦組み（`tate` オプション）~~ → コア実装済み、縦家具・目次・保存位置は数値対照済み**： 「`\tate`/`\yoko` プリミティブが無い＝縦組み不可能」との初回判定は、shipout rotation 構成（内枠横組 galley＋和文グリフ+90°回転＋出荷時 −90°回転）によって覆された。出力ルーチンは薄いラッパに再構成（kernel `\@outputpage` 本体丸写しを撤去; build/page フックと hook 付き shipout は素通りを機械検証）、縦家具オプション（head_space/foot_space/gutter/fore_edge 非対称 + twoside + 段組 + 遅延注 + marginpar）の幾何を uplatex 同一ソースと**ビット一致**で対照（`furniture-options` ゲート）、tate TOC 2パス不良を解消（`toc-twopass` ゲート）、savepos の論理行方向測定（割注）も uplatex とビット一致（`savepos-warichu` ゲート）。~~縦組み見出し・柱等のページ家具~~・~~tate 連動 jlreqsetup キー~~ は本対照で解消。**残件**: 縦組み `\kansuji`/`\today` 縦組表示の個別対照。回転バナーは従来の `\rotatebox{-90}` 版（4.4参照）。
2. **~~`mag` オプション相当（`\mag` 可変運用）~~ → 解決（2026-10-23）**： jlreq.cls:1677–1690 の d 分岐で `\pdfhorigin`=`\pdfvorigin`=`1truein` を再代入し `\pdfpagewidth`/`\pdfpageheight` を 1000/`\mag` 倍に再スケールする相殺を実装。実測: `\mag=1200` の版面寸法が uplatex 参照とビット等価（94.152bp）、`\mag=1000` では出力が導入前後でバイト一致。**トンボ描画も `\mag=1200` で一致**： jlreq-trimmarks-pdftex.def:58–77 の `\put` 原点補正（`\mag≠1000` 時に描画 stored 座標へ混入する `\hoffset`/`\voffset` 成分を相殺； uplatex は stored 座標が mag 不変＝全描画がストック隅から単純 mag 倍であることの実測・コンテントストリーム照合に基づく）により、描画 HiRes ink-bbox が uplatex と完全一致（`42.048 42.174 845.082 1140.894`）。`\mag=1000` では描画ストリームが導入前後で一致（HiRes `35.041 35.136 704.234 950.742`）。検証 fixture: `tests/fixtures/pdflatex-coexist/mag-tombow.tex` ＋ `tests/check-tombow-mag.py`（トンボ罫線の stored 座標が mag 不変で (35.05, 922.444) かつページ CTM が ×1.2 であることを機械判定、runner 登録済み）。テキストブロックの +1truein 再センタリングは jlreq-trimmarks-pdftex.def:79–89 で実装済み（uplatex 比較で y 誤差 ≤0.065bp、x ビット一致）。
3. **~~`hanging_punctuation`（ぶら下げ）の完全再現~~ → 実装済み（2026-10-23、2026-10-24 に機構置換）**： 先行の「pdfTeX は行末突出し機構を持たない」は誤りと判明。**現行機構**は LuaTeX-ja の `ltjenableadjust[lineend=extended]` 相当そのもの——ぶら下げは行末限定の kern/penalty 候補列（end_adjust は行中 0・行末 break のみ有効）の**負 end_adjust 候補**として表現し、突出し量は upLaTeX と一致（2.3 表参照）。**歴史**: 初出の実装は `\pdfprotrudechars=2`＋`\rpcode` による突出しだったが、マージンカーン二重計上（名目 0.5zw が実測約 1zw）のため同じ候補列機構に置換され、`\pdfprotrudechars`/`\rpcode`/裸字形分岐/負 hangkern は撤去。**優先順位付き伸縮**も同じく解決済み: ペアグルーの spri/shpri は 9 フィールド全評価の上で境界ごとに `\jlreqpdf@pairspri/@pairshpri` へ記録され（jlreq-pdftex-rules.sty:173–175, 465–466）、`jlreqparagraph` 厳密段落環境（4.4 表参照）がこのデータを消費して優先順位を厳密に配分する。旧「shrink 畳み込み近似」は撤去。通常段落の伸縮は意図的に native TeX 改行器の一括伸縮のまま（承認済みの二層設計: 厳密保証は `jlreqparagraph` で得る） |
4. **~~和文 `\label` 名~~ → 実装済み（2026-10-24）**： label key の対称正規化 `\jlreqpdf@labelkey`（`\protected@edef` で通常マクロ展開・UTF8 byte は CJK byte マクロの保護分岐で凍結 → `\detokenize` で catcode 12 化、byte 不変）を write（`\label`）・read（aux の `\newlabel`、begindocument/before フック）・query（`\ref`/`\pageref` star 両形）に接続。パッケージ面も対応: nameref（`\NR@setref`）、hyperref（`\label@hyperref`/`\HyRef@autoref`/`\hyperref[..]`）、refcount（`\refused`/`\rc@set`/`\getrefnumber` — edef 内完全展開を維持）、cleveref（`\@cref` 入口の key 事前正規化 + `\cref@getref`/`\cpageref@getref`）。ASCII ラベルの aux は byte 不変（HEAD tree との cmp 一致を実測）。eqref-hyperref.tex の「日本語label不可」コメントは解消済み（label-packages.tex が全面行列を実測）。
## 7. 依存関係・ライセンス・動作環境

### フォントプロファイルと文字抽出契約

- 補助縦フォントはソースフォント（IPAexMincho/IPAexGothic; IPA Font License
  v1.0）の vert/vrt2 グリフを再パッケージした派生物。`fonts/pdftex/LICENSE-aux-*.txt`
  に出典・ライセンス文を複製し、プロファイル .def のヘッダにも同じ出典を記録する。
- 縦字形の文字抽出: プロファイル読込時に各補助グリフ名 `jlreqvXXXX` の
  `\pdfglyphtounicode{jlreqvXXXX}{<UTF-16BE hex>}` を登録し
  `\pdfgentounicode=1` を設定する（非BMPはサロゲートペア）。
  文書が `\pdfgentounicode` を 0 に戻した場合、\AtEndDocument で
  「文字抽出保証を満たさない設定」として明示エラーにする。
- `…`（U+2026）の抽出が `. . .`（002E×3）になるのは横組の ipaex-type1
  既定経路でも同一の挙動（配布 ipaex-type1 の ToUnicode 由来）であり、
  縦経路の退化ではない。

`docs/pdftex-dependencies.md` を参照（ライセンス境界の記録＝GPL依存と
コード流用の区別，TeX Live 2025検証実績，最低版は上流協議事項）。

microtype・二段組（`twocolumn`）との共存は
`tests/fixtures/pdflatex-coexist/microtype-twocolumn.tex` で検証済み
（rc=0，二段組レイアウト実測，microtypeの欧文プロトラクション有効化で
和文グルーとの衝突なし）。

### 既知の制限詳細（禁則エンジンの改修 2026-10-23追記）

**修正された重大バグ**: 禁則クラス表（`\jlreqpdf@kin@pre@<n>`等）が
`\def\jlreqpdf@kin@pre@2{10000}` 形式で定義されていたため、数字が制御綴名に
使えず「`\jlreqpdf@kin@pre`＋引数区切り`2`のマクロ」化し、**全禁則ペナルティが
一つも出力されていなかった**（`\ifcsname`検索で常に未定義）。
全表を `\expandafter\def\csname …\endcsname` 形式に修正。
ペアグルーの出力順も改修: 行頭禁則文字の直前のglue（自然長0を含む）は
改行候補点を作るため出力を抑制（`\relax`）し、行末禁則文字の直後の
境界glueも同様に抑制する `\jlreqpdf@kernmode` 機構を追加。

**残る既知の違反（1種）** → **修正済み（2026-10-23 追記2）**: 欧文の直後に
閉じ括弧が来る配置（例: `（x）` の x が行末に達する狭い行）で、まれに
`）` が次行頭に落ちる場合があった。原因はCJKデコーダ由来の
「`\CJKglue` シグネチャを持つ自然長0の外部グルー」が prebreak クラスの
前に残り、そこが改行候補点になっていたこと。該当グルーを検出して
`\unskip` する処理を追加し解消（preclose-latin.tex で検証、
kinsoku-bbox-line-head-scan で 0 違反を継続監視）。
（以下は修正前の調査記録）pdfTeXのCJK出力経路（UTF8デコーダ→`\CJKsymbol`）の
内部に出力ノードが介在し、`\penalty10000` をグリフ直前に置いても
別の改行候補点から回避されていた。手動 `\penalty10000` 挿入では
解消するが、旧バックエンドのフック位置では到達できなかった。
