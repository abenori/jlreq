# pdfTeXバックエンド 依存関係・ライセンス・動作環境

## ライセンス構成（GPLコードをBSD-2ソースへ流用しない方針の記録）

| 成分 | ライセンス | 本プロジェクトでの扱い |
|---|---|---|
| jlreq 本体（jlreq.cls 他） | 2-clause BSD | 変更対象。バックエンドコードはこれに従う |
| jlreq-pdftex.sty / jlreq-pdftex-rules.sty（新規） | 2-clause BSD（jlreq本体と同一） | 独自実装。依存パッケージのコードは含まない |
| make_pdftex_jfm.lua / check_jfm_pdftex.lua（新規） | 2-clause BSD | 既存luajfm2pl.luaのロード方式（kpse+dofile）のみ参照し，コード流用なし |
| bxcjkjatype | MIT | **依存**（`\RequirePackage` のみ。コード流用なし） |
| CJK / CJKutf8 / CJKspace | GPL-2.0 | **依存**（実行時にロードされるだけ。jlreq成果物へのGPL伝播は「依存関係」として区別し，コード流用は一切ない） |
| expl3 / LaTeX2e カーネル | LPPL | 依存 |
| IPAex Type 1 フォント（ipaex-type1） | IPA Font License | 依存（フォント資産） |

方针: BSD-2のjlreq本体に，GPLパッケージ（CJK系）を「依存」として使う
（他のTeXパッケージがGPLパッケージを依存に持つのと同じ形）。バックエンド
実装はCJKの内部マクロを参照するが（`\CJKsymbol` 内部・`\CJK@ignorespaces`
へのフック），それらは実行時のインターフェース利用でありコード複製ではない。
上流レビューでこの境界を明示する。

## 動作環境（検証実績）

| 項目 | 値 |
|---|---|
| TeX Live | 2025（nixpkgs環境, pdfTeX 3.141592653-2.6-1.40.27, kpathsea 6.4.1） |
| エンジン | pdflatex / platex / uplatex / lualatex（同一環境で回帰検証） |
| 必須パッケージ | bxcjkjatype >= 2023/07/23 v0.5，CJK（CJKutf8），lmodern（jlreq既存依存） |
| フォント | ipaex-type1（TeX Live標準収録） |
| ビルドツール | texlua（JFM生成のみ。実行時は不要） |

**最低TeX Live版**: 上流との協議事項。
技術要件は `\DeclareKeys`/`\ProcessKeyOptions`（LaTeX2e 2020-10以降），
`\AddToHook{...}`（2020-06以降），`expl3`の`\sys_if_engine_pdftex:TF`。
検証実績は TeX Live 2025 のみ。**実装はフック・鍵処理をこの世代に固定する**。

## バージョン確認コマンド

```sh
kpsewhich -var-value=version        # kpathsea
pdflatex --version | head -1        # pdfTeX
kpsewhich bxcjkjatype.sty           # 依存の所在確認
kpsewhich ipxm-r-u30.pfb            # フォント資産確認
```

## フォント（縦字形・フォントプロファイル）

縦組みの実際の縦字形（vert/vrt2 GSUB）は補助縦フォントで実現する。
補助縦シャード（jlreqv-*.ttf/.tfm/.enc）と HaranoAji 変換横組 TTF は
**リポジトリには含めないビルド成果物**で、`make pdftex-fonts` が
TeX Live 収録の haranoaji/ipaex/ipa フォントからユーザー環境上で
生成する（リポジトリが持つのはプロファイル .def とライセンス文のみ。
`make install` / `make tds` がこの生成に依存する）。
実行時とビルド時の依存は分離：

### 実行時（文書コンパイル; python/fontTools/ttf2tfm 不要）
- `fonts/pdftex/jlreq-pdftex-fonts-ipaex.def` / `-ipa.def` /
  `-haranoaji.def`（フォントプロファイル。インストール先は `tex/latex/jlreq`）
- `fonts/pdftex/jlreqv-<fontset>-<mc|gt>-<NN>.ttf` / `.tfm` / `.enc`
  （補助縦フォント。**ビルド成果物**: `make pdftex-fonts` が
  TeX Live のフォントから生成する。インストール先は
  `fonts/truetype/jlreq-pdftex`, `fonts/tfm/jlreq-pdftex`,
  `fonts/enc/jlreq-pdftex`）
- クラスオプション `pdftex_fontset=ipa|custom` 利用時の横書きTTF経路:
  **zhmetrics** の動的TFM（`unisong@Unicode@` 等）と **`Unicode.sfd`**
  （`kpsewhich Unicode.sfd`）。欠損時は当該リソース名を添えて停止する。
- `pdftex_fontset=haranoaji` 利用時の追加資源: **変換済み横組フルTTF**
  `fonts/pdftex/haranoaji-mincho-ttf.ttf` /
  `haranoaji-mincho-bold-ttf.ttf` / `haranoaji-gothic-ttf.ttf` /
  `haranoaji-gothic-bold-ttf.ttf`（いずれも**ビルド成果物**:
  `make pdftex-fonts` が HaranoAji OTF を CFF→quadratic 変換して
  生成する。インストール先は
  `fonts/truetype/jlreq-pdftex`）。横書きTFM経路は ipa と同一の
  zhmetrics 動的TFMチェーン（unisong/unili/unihei/uniyou@Unicode@）で、
  pdfmapline の埋込先だけがこれらの変換TTFに向く。pdfTeX は
  mapline の `<file` を kpathsea（TEXFONTS）で出荷時に解決するため、
  TDS インストール後はリポジトリ外の cwd からも動作
  （staged install smoke `staged-smoke-haranoaji.tex` で実証済み）。
  **ライセンス**: HaranoAji は Copyright (C) 2019-2025 Masamichi Hosoda
  （Reserved Font Name 'Harano Aji'; Adobe / FontWorks 由来の SIL OFL
  系）。変換TTF・補助縦フォントとも派生物であり、リポジトリには
  含めずユーザー環境上で生成する（派生物をこちらから再配布しない）。
  出典・ライセンス文は
  `fonts/pdftex/LICENSE-aux-haranoaji-*.txt` とプロファイル .def ヘッダに
  記録する。

### ビルド時（`make pdftex-fonts` / custom 生成; 通常の文書では実行しない）
- **python3 + fontTools**（cmap/GSUB vert・vrt2/hmtx/vmtx/VORG/輪郭bbox読取）
- **ttf2tfm**（TL2025検証済みの起動形式:
  `ttf2tfm <ttf> -N -u -p <enc> <outbase>`。この版のパーサは
  オプションを位置引数の後ろに置かないと「Need at most two non-option
  arguments」で失敗する——生成器のヘッダに実測値を文書化済み）
- ソースTTF: ipaex の `ipaexm.ttf`/`ipaexg.ttf`（既定）、
  ipa の `ipam.ttf`/`ipag.ttf`、custom は `--mincho/--gothic` のTTF
- ソースOTF（haranoaji）: **haranoaji パッケージ**の
  `HaranoAjiMincho-{Regular,Bold}.otf` / `HaranoAjiGothic-{Regular,Bold}.otf`
  （`kpsewhich HaranoAjiMincho-Regular.otf`。CFF 輪郭のため
  生成器は Cu2QuPen（max_err 0.5/1000upem, reverse_direction）で二次曲線化
  する——TTGlyphPen に素通しさせると fontTools が
  `glyphDataFormat=0 requires quadratics` で拒否する（実測）。
  変換誤差は対称距離で <0.9/1000 em、600dpi ラスタで OTF 原字形と
  ink bbox 同寸・fill 比 0.3–1.4% 一致（実測））。

### 依存確認コマンド

```sh
kpsewhich ipaexm.ttf                    # ipaex-type1 の縦字形ソース
kpsewhich ipam.ttf                      # ipa プリセットTTF
kpsewhich HaranoAjiMincho-Regular.otf   # haranoaji ソースOTF（縦字形・横組変換の両方）
kpsewhich Unicode.sfd                   # zhmetrics SFD（ipa・haranoaji 横書き）
kpsewhich unisong30.tfm                 # zhmetrics 動的TFM確認
ls fonts/pdftex/jlreq-pdftex-fonts-haranoaji.def   # haranoaji プロファイル（repo）
ls fonts/pdftex/haranoaji-mincho-ttf.ttf           # 変換済み横組TTF（make pdftex-fonts の生成物）
ttf2tfm --version                       # 補助TFM生成器（ビルド時のみ）
python3 -c "import fontTools"           # ビルド時のみ
```
