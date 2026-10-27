# pdfTeX バックエンド用 JFM データの生成

`jfm-jlreq.lua`（横組み）と `jfm-jlreqv.lua`（縦組み）から、pdfTeX
バックエンド（`jlreq-pdftex.sty`）が実行時に直接読み込む JFM データ
を生成する。

## 成果物

| ファイル | 役割 |
|---|---|
| `make_pdftex_jfm.lua` | 生成器（ビルド時のみ、texlua で実行） |
| `jlreq-pdftex-jfm*.def` 12種 | 生成データ（コミット済み・実行時に必要） |
| `pdftex-jfm-manifest.lua` | 生成 manifest（バリアント一覧の唯一のソース） |
| `check_jfm_pdftex.lua` | 静的検証器（全ペア・全クラス・全文字を検査） |

## バリアントとファイル名（12組）

方向（yoko/tate）× `open_bracket_pos` 3種 × ぶら下げ true/false の
12組。横組みの接尾辞は `jlreq.cls` の JFM 名接頭辞システム
（`jlreq.cls:570-573`: `b`=ぶら下げ、`z`=`zenkakunibu_nibu`）に合わせ、
pdfTeX 専用の `n`（`nibu_tentsuki`）を加える。縦組みは `-tate` 接頭
辞に同じ b/z/n 文字を続ける（`-tate` 単独 = 接尾辞なし）。

| ファイル | dir | open_bracket_pos | burasage |
|---|---|---|---|
| `jlreq-pdftex-jfm.def` | yoko | `zenkaku_tentsuki` | false |
| `jlreq-pdftex-jfm-b.def` | yoko | `zenkaku_tentsuki` | true |
| `jlreq-pdftex-jfm-z.def` | yoko | `zenkakunibu_nibu` | false |
| `jlreq-pdftex-jfm-bz.def` | yoko | `zenkakunibu_nibu` | true |
| `jlreq-pdftex-jfm-n.def` | yoko | `nibu_tentsuki` | false |
| `jlreq-pdftex-jfm-bn.def` | yoko | `nibu_tentsuki` | true |
| `jlreq-pdftex-jfm-tate.def` | tate | `zenkaku_tentsuki` | false |
| `jlreq-pdftex-jfm-tate-b.def` | tate | `zenkaku_tentsuki` | true |
| `jlreq-pdftex-jfm-tate-z.def` | tate | `zenkakunibu_nibu` | false |
| `jlreq-pdftex-jfm-tate-bz.def` | tate | `zenkakunibu_nibu` | true |
| `jlreq-pdftex-jfm-tate-n.def` | tate | `nibu_tentsuki` | false |
| `jlreq-pdftex-jfm-tate-bn.def` | tate | `nibu_tentsuki` | true |

### manifest（一覧の唯一のソース）

`pdftex-jfm-manifest.lua` は生成器が `--all-variants` 時に書き出す
バリアント一覧（ファイル名・suffix・dir・オプション）。検証器
（`check_jfm_pdftex.lua` の既定 12 ファイル検証）と Makefile
（`PDFTEX_JFM_DEFS`、`--print-manifest` 経由）、インストール
（`cls-install`/`tds`）はすべてこの manifest から一覧を取る。
バリアントの増減は `make_pdftex_jfm.lua` の `VARIANTS` 表だけを
編集し、`make pdftex-jfm` で一括再生成する。

### 縦組みの入力を jfm-jlreqv.lua にした理由

縦組みの生成元は旧来の `jfm-jlreqv-pl.lua` ではなく
**`jfm-jlreqv.lua`**（LuaTeX-ja 実行時に読まれる完全版）である。

- `jfm-jlreqv.lua` は `dir='tate'`、全クラス height=depth=0.5 の
  メトリックに加え、`jfm-jlreq.lua:1141-1172` と同じ
  `jlreq.open_bracket_pos` / `jlreq.burasage` オプションフックを
  持つ（`jfm-jlreqv.lua:2958-2998`）。よって b/z/n の意味論を
  生成器で二重実装せずソース自身に委ねられる。
- PL 版（`make_variant_jfm.lua` の `to_pl()`）は pTeX 用に
  (a) `priority[1] < 0` のペアの stretch を 0 にする、
  (b) `jfm[4].glue[0]`（alchar 補正ペア）を削除する、の 2つの変換を
  焼き込んでいた。pdfTeX バックエンドは 9 フィールド契約
  （`pairfields{nat}{str}{shr}{ratio}{spri}{shpri}{knat}{kstr}{kshr}`）
  で全フィールドを評価するため、この脱落は許容できない。
  実行時テーブルを直接使うことで両方が復元される
  （例: 0→1 stretch 0.25 priority{-1,-2}、4→0 ペアの存在）。

### バリアントの意味（`jfm-jlreq.lua:1141-1172`、オプションは
`<段落>_<折り返し>` に分解される）

- `zenkakunibu_nibu`（`z`）: 折り返し=nibu → クラス 1（開き括弧）
  の幅 +0.5、全クラス→1 グルー −0.5（ratio は `add_space` が再配合）、
  段落=zenkakunibu → 90→1 +0.5 で相殺し `{0,0,0}` ratio 1.5。
- `nibu_tentsuki`（`n`）: **段落=nibu + 折り返し=tentsuki** なので
  段落行頭の下げのみが発火する: 90→1 は `add_space(90,1,"glue",-0.5,1)`
  で `{−0.5,0,0}` ratio −0.5（ratio 算出: (0×0.5 + (−0.5)×1)/(0+1)）。
  クラス 1 幅は 0.5 のまま、他の k→1 ペアは既定変種とバイト同一
  （生成データで実測確認済み）。
- ぶら下げ（`b`）: クラス 6, 7（句読点）の `end_adjust` に −0.5 を
  追加しソート（`{-0.5, 0, 0.5}`）。

### nibu_tentsuki の pdfTeX/pTeX 手法の相違（設計文書化）

pTeX/upTeX では `nibu_tentsuki` は JFM ファイルを持たない。
`jlreq.cls:1218-1224` は素の JFM のまま `\everypar` の
openbracket フックで行頭の開き括弧の直前に
`\hskip -.5\jlreq@zw \inhibitglue` を実行時挿入することで同じ形状を
得る。pdfTeX バックエンドには段落ごとの実行時フック経路がないため、
**同じ形状を生成 .def 内のグルーデータ（90→1 ペア）に焼き込む**設計を
取った。これが横組みに `n`/`bn`、縦組みに `-tate-n`/`-tate-bn` の
pdfTeX 専用変種が存在する理由である。

## ビルドと検証

```sh
make pdftex-jfm            # 12 ファイル + manifest 生成（決定的）
make check-pdftex-jfm       # 再生成してコミット済みファイルと cmp ×12、
                            # check_jfm_pdftex.lua で全検証
texlua check_jfm_pdftex.lua [file.def ...]   # 静的検証のみ
                            # （引数なし = manifest の12ファイル全検証）
```

- 決定性: ソート済みキー、`%.6f` 固定小数、タイムスタンプなし。
  2 回の実行はバイト一致（`make check-pdftex-jfm` が検査）。
- `.def` をコミットする理由: pdfTeX 実行時に必要で、利用者は texlua
  を持つとは限らないため、生成済みデータを配布物に同梱する。既存の
  `.tfm`/`.vf` はインストール時ビルドのためコミットしない。
- 各 `.def` ヘッダにソース（横 `jfm-jlreq.lua` / 縦 `jfm-jlreqv.lua`）
  の SHA256 と生成器バージョン（GEN_VERSION 2.0）、dir と
  バリアントオプションを記録し、追跡可能性を確保する。
- 生成形式のバージョンは GEN_VERSION 2.0 に上がった（12 変種 +
  manifest + classlist）。旧 5 ファイル形式（v1、縦 1 組のみ・PL 由来
  の stretch 落ち）との互換 shim は置かない。

## 直列化形式

- 定義はすべて `\expandafter\def\csname jlreqpdf@jfm@…\endcsname{…}`。
  理由: 数字を含むマクロ名（`class@0`、`cls@AB` 等）は素の
  `\def\foo@0{…}` では `0` がパラメタテキストの区切りになるため。
- 本体は 1 グループ、複数フィールドは内部グループ `{a}{b}…`。
- マクロファミリ: `dir/zw/zh/version/variant/kanjiskip/xkanjiskip`、
  `classlist`（ソート済みクラス番号のカンマ列 — ランタイムの
  25class 固定一覧を生成データから構築するため）、
  `class@<n>{{w}{h}{d}{align}{left}}`、`endadj@<n>`、`chars@<n>`、
  `cls@<hex>`（単一代理点）、`combo@<n>`、`ajone@<n>`、
  `pseudo@<name>`、`pair@<f>@<t>{{nat}{str}{shr}{ratio}{spri}{shpri}{knat}{kstr}{kshr}}`。

### 縦グリフの位置補正（旧 off@ 表の撤去）

縦組みではかつて `off@<n>{raise}{shift}`（pt、IPAex 明朝代表字の Type1
charstring ink bbox 由来の固定pt表。`wd=1zw` 正規化・代表字流用の既知
限界つき）を生成 .def に持たせていた。現在はフォントプロファイル
（`jlreq-pdftex-fonts-*.def`＋補助縦TTF/TFM/enc）が縦字形の選択と位置
補正を担い、進行幅は JFM クラス幅×現在zw で算出するため、生成 .def に
`off@` 表は存在しない（jlreq-pdftex-rules.sty の縦グリフ経路参照）。

## 実行時読込契約（バックエンド向け）

1. `\makeatletter`（catcode `@` = 11）を `\input` の前に発行。
   ファイルは catcode を復元しない。
2. 標準 catcode のみで成立（expl3 でも素の TeX でも読込可）。
3. 数字を含む名前の値参照は `\csname` + `\edef` で展開して取得する
   （LaTeX2e の `\typeout` は `\csname` 参照を展開しない——実証済み）。
4. 変種の選択は `jlreq-pdftex-rules.sty` のローダが行う:
   現在のクラスオプション（`hanging_punctuation` → `b`、
   `open_bracket_pos` → `z`/`n`、`tate` → `-tate` 接頭辞）から
   接尾辞を組み立て、`jlreq-pdftex-jfm[-tate][-bz|-b|-z|-n|-bn].def`
   を読み込む。ファイル不在は「どのファイルが不足か」を明示する
   エラーになり、黙って別変種へフォールバックしない。

## データ規模（2026-10-24 版 `jfm-jlreq.lua` / `jfm-jlreqv.lua`）

- クラス 25 個（0,1,2,4–16,27,90,161,191,192,193,300,301,302）—
  `classlist` マクロとしても照会可能
- ペア規則 402 条（全定義ペア。未定義セルは不発行）
- 文字 403 エントリ = 356 単一代理点 + 14 コンボ + 30 AJ1 グリフ
  + 3 疑似（`alchar`, `parbdd`, `boxbdd`）
- `end_adjust` はクラス 2, 5, 6, 7 にのみ存在
- 縦組み: 全クラス height=depth=0.5
