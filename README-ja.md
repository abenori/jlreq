# jlreq

## これは何？
[日本語組版処理の要件](https://www.w3.org/TR/jlreq/ja/)の実装を試みる[LuaTeX-ja](https://osdn.jp/projects/luatex-ja/wiki/FrontPage) / pLaTeX / upLaTeX用のクラスファイルと，それに必要なJFMの組み合わせです．

## 提供されるもの
クラスファイルjlreq.clsと，横書きLuaTeX-ja用のJFMであるjfm-jlreq.luaが用意されています．また，縦書きのJFMやpLaTeX / upLaTeX 用のJFMを生成するいくつかのスクリプトがあります．

## インストール
`make`で必要なJFMを生成してください．その後，

* *.tfm -> $TEXMF/fonts/tfm/public/jlreq
* *.vf -> $TEXMF/fonts/vf/public/jlreq
* jfm-jlreq.lua jfm-jlreqv.lua -> $TEXMF/tex/luatex/jlreq
* jlreq.cls -> $TEXMF/tex/latex/jlreq

と配置します．`make install`とすると，$TEXMF=$TEXMFHOMEとしてこのコピーを行います．

## 使い方
通常通り
````
\documentclass{jlreq}
````
とします．これで横書きのarticle相当の文書クラスとなります．エンジンは自動判定されますが，指定する場合はクラスオプションに`platex/uplatex/lualatex`のいずれかを渡してください．縦書きにするには`tate`オプションを渡します．また，reportやbook相当の文書クラスとするには，それぞれ`report`や`book`オプションを渡します．たとえば，縦書きの本を作成するには
````
\documentclass[tate,book]{jlreq}
````
とします．

その他，`oneside / twoside / onecolumn / twocolumn / titlepage / notitlepage / draft / final / openright / openany / leqno / fleqn`というよくあるオプションを受け付けます．

標準的な文書クラスと同じように中身を書くことができますが，次のような命令が追加 / 拡張されています．

### `\section`
`\section*[running head]{見出し文字列}[副題]`というように，通常の書式に加えて副題を受け付けられるように拡張されています．その他，`\part`（articleのみ），`\chapter`（book/reportのみ），`\subsection`も副題を受け付けます．（`\subsubsection`も受け付けますが，汚い見た目になります．）

### `\sidenote`
傍注（縦組みの場合は脚注）を出力します．デフォルトでは`\footnote`と同様の書式となりますが，クラスオプションに`sidenote_type=mark`が指定されている場合，その書式は`\sidenote{該当項目}{注}`となります．たとえば
````
刊行できる\sidenote{該当項目}{原稿とは，印刷などの方法により……}を入手する仕事である．
````
とします．後の説明も参照してください．

デフォルトの基本反面では余白が少なく，実用にはならないかと思います．後の基本反面の設定を参考にしてください．

### `\endnote`
後注を指定します．`\footnote`と同様の書式です．デフォルトでは，注自身の出力は見出し直前に行われます．この動作はクラスオプションにより制御できます．また`\theendnotes`を実行するとその場に出力をします．

### `\warichu`
割注を出力します．行分割位置などは自動で計算されます．（複数回のコンパイルが必要．）`\warichu*`ではこれらの位置を手動で指定できます．書式は

``\warichu*{(一行目前) & (一行目後)\\ (二行目前) & (二行目後)...}``

です．`&`が省略されている場合は自動で調整されます．

### `\jlreqsetup`
設定用命令です．プリアンブルでしか使えません．文書に対する殆どの設定はクラスオプションにより行いますが，一部の設定はこの命令を通じて行います．


## 各種設計
設計はクラスオプションまたは`\jlreqsetup`によりkeyval形式で行います．以下では次の用法を使います．

* `[A/B]`: AまたはBです．`[A/B/C]`等も同様．
* `<寸法>`: TeXが認識する寸法です．簡単な式（10pt+10ptのような）を使うこともできます．また，場合によっては次のような特殊な値を使うこともできます．
	* `Q`: 0.25mmと解釈されます．
	* `zh`, `zw`: 全角幅として解釈されます．

たとえば`Q`が利用可能な場合は`<寸法;Q>`のように記述します．


### 基本版面
すべてクラスファイルへのオプションです．

* `paper=[<紙サイズ名>/{<寸法>,<寸法>}]`：紙サイズです．紙サイズ名はa0からa10，b0からb10，c2からc8を指定できます．B列はJIS B列です．また，`{<縦>,<横>}`と直接寸法を指定することもできます．
* `fontsize=<寸法;Q>` : フォントサイズ．デフォルトは10pt．
* `line_length=<寸法;zw,zh>` : 一行の長さ．デフォルトは紙の縦幅の0.75倍．実際の値は一文字の長さの整数倍になるように補正されます．
* `number_of_lines=<整数値>` : 一ページの行数．デフォルトは紙の横幅の0.75倍になるような値．
* `gutter=<寸法;zh,zw>` : のどの余白の大きさ．（`tate`や`twoside`が指定されているかに応じて少し効果が変わる．）
* `head_space=<寸法;zh,zw>` : 天の空き量．デフォルトは中央寄せになるような値．
* `foot_space=<寸法;zh,zw>` : 地の空き量．デフォルトは中央寄せになるような値．
* `baselineskip=<寸法;Q,zh,zw>` : 行送り．デフォルトはfontsizeの1.7倍．
* `linegap=<寸法;Q,zh,zw>` : 行間．
* `headfoot_sidemargin=<寸法;zw,zh>`：柱やノンブルの左右の空き．
* `column_gap=<寸法;zw,zh>`: 段間（twocolumn指定時のみ）．

### 組み方
* `open_bracket_pos=[zenkaku_tentsuki/zenkakunibu_nibu/nibu_tentsuki]`: 始め括弧が行頭に来た際の配置方法を指定します．それぞれ段落開始全角折り返し行頭天付き（デフォルト），段落開始全角二分折り返し行頭二分，段落開始二分折り返し行頭天付きを意味します．
* `hanging_punctuation`: ぶら下げ組をします．

### 注関係
* `reference_mark=[inline/interlinear]`: 合印の配置方法を指定します．`inline`にすると該当項目の後ろの行中に配置します．`interlinear`を指定すると該当項目の上（横組）または右（縦組）に配置します．
* `sidenote_type=[number/mark]`: 傍注と本文との対応の方法を指定します．`mark`は注のついている該当項目により指定します．`mark`が指定されている場合は，さらに該当項目の装飾方法を指定できます．これは`\jlreqsetup`に
````
sidenote_mark={
  mark=<文字列>,
  headingfont=<命令>
}
````
を渡すことで行います．`mark`により指定された文字列が該当項目につき，また`headingfont`で指定された命令で装飾されます．デフォルトは
````
sidenote_mark={
  mark={＊},
  headingfont={\gtfamily\bfseries}
}
````
です．
* `sidenote_width=<寸法;zh,zw>`: 傍注の幅を指定します．基本版面の設定に合わせて設定してください．
* `endnote_position=[_headings/_paragraph/{<見出し名1>,<見出し名2>,...}]`：後注の出力場所を指定します．`_headings`は各見出しの直前（デフォルト），`_paragraph`は改段落の際に出力します．また，`endnote_position={chapter,section}`とすると，`\chapter`と`\section`の直前に出力します．

## 見出し
見出しの設定は，`\Declare***Heading`という命令で行います（***には見出しの種類に応じた文字列が入る）．書式はすべて

```
\Declare****Heading{<命令名>}{<レベル>}{<設定>}
```

となっています．また，`\New***Heading`，`\Renew***Heading`，`\Provide***Heading`も同時に用意されます．それぞれ`\newcommand`，`\renewcommand`，`\providecommand`に対応した動きをします．

### 扉見出し
`\DeclareTobiraHeading`で作成します．通常のクラスファイルにおける`\section`等と同じ書式の命令ができます．設定は以下の通り．

* `type=[han/naka]`: `han`だと半扉見出しを，`naka`だと中扉見出しを作ります．
* `pagestyle=<ページスタイル>`: 見出し箇所のページスタイルを指定します．
* `label_format=<書式>`: ラベルを出力する命令を指定します．たとえば`label_format={第\thechapter 章}`のように指定します．
* `format=<書式>`: 実際に出力する書式を指定します．`format={\null\vfill {\Huge\bfseries #1#2}}`のようにします．`#1`はラベルに，`#2`は見出し文字列に置き換えられます．

### 別行見出し
`\DeclareBlockHeading`で作成します．`\<命令名>*[running head]{見出し文字列}[副題]`という書式の命令を作成します．設定は以下の通り．

* `font=<命令>`: 見出しのフォントを指定します．
* `indent=<整数値>` 見出し全体の字下げ量を全角文字数で指定します．
* `subtitle_font=<命令>`: 副題のフォントを指定します．
* `pagebreak=[clearpage/cleardoublepage/clearcolumn/nariyuki]`: 見出し直前の改ページを指定します．それぞれ，改ページ，改丁，改段，なりゆきです．

また，行取りの指定を行うことができます．次のいずれかの方法で行います．

* 行数を指定し，その中央に配置する．`lines=<整数値>`により行数を指定します．`before_lines=<整数値>`や`after_lines=<整数値>`により，さらに前後に追加する行数を指定します．たとえば`lines=3,after_lines=1`とすれば，四行の中に配置され，前の空きよりも後ろの空きの方が一行分大きくなります．
* 行数と，前後いずれかの空きを指定します．`lines=<整数値>`により行数を，`before_space=<寸法>`または`after_space=<寸法>`のいずれかの指定によりそれぞれ前またら後ろの空きを指定します．
* 前後の空きを指定します．`before_space=<寸法>`および`after_space=<寸法>`を指定します．

### 同行見出し
`\DeclareRuninHeading`で作成します．`\section`と同様の書式の命令が作成されます．設定は以下の通り．

* `font=<命令>`: 見出しのフォントを指定します．
* `indent=<整数値>` 見出し文字列全体の字下げ量を全角文字数で指定します．

### 窓見出し
`\DeclareCutinHeading`で作成します．`\<命令名>{見出し文字列}`という書式の命令を作成します．設定は以下の通り．

* `font=<命令>`: 見出しのフォントを指定します．
* `indent=<整数値>`: 見出し全体の字下げ量を全角文字数で指定します．
* `onelinemax=<寸法>`, `twolinemax=<寸法>`: 見出し文字列の長さが`onelinemax`以下ならば一行で，`twolinemax`以下ならば二行で窓見出しを出力します．それ以上の場合は三行です．デフォルトはそれぞれ6文字，20文字の長さ．

### `\ModifyHeading`
既に（上のどれかを使い）定義された見出し命令の設定を変更します．たとえば

```
\ModifyHeading{section}{lines=10}
````

とすると，`\section`のフォントなどの設定はそのままに，行取りのみが10行に変更されます．見出しの種類を変更することはできません．

## ページスタイル

``\DeclarePageStyle{<ページスタイル名>}{<設定>}``

によりページスタイルを定義することができます．設定は以下の通り．

* `nombre_position`，`running_head_position`: ノンブルと柱の位置を指定します．`top-left`のように指定できます．`center/left/right/top/bottom`が使えます．
* `nombre=<書式>`: 出力するノンブルを指定します．デフォルトは`\thepage`．
* `odd_running_head=<書式>`，`even_running_head=<書式>`：それぞれ奇数ページ，偶数ページの柱を指定します．`_section`のように`_`から始まる名前を指定すると，対応する見出しを出力します．（`_section`だと現在の`\section`を出力する．）

`\ModifyPageStyle`により既存のページスタイルを改変することが可能です．

## その他
* クラスオプション`jlreq_warnings`を渡されると，日本語組版処理の要件に反する設定が行われた場合に警告がされます．

## ライセンス
このパッケージは二条項BSDライセンスの元で配布されています．詳しくは[LICENSE](LICENSE)をご覧ください．

## 履歴
## CHANGELOG
* 2017-02-08
    - 最初のバージョン．

