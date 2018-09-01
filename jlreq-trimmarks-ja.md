# jlreq-trimmarks

## これは何？
トンボ（トリムマーク）を出力するためのパッケージです．[LuaTeX-ja](https://osdn.jp/projects/luatex-ja/wiki/FrontPage) / pLaTeX / upLaTeX / dvipdfmx / Dvips / dviout上で動きます．jlreqクラスファイルのみでなく，汎用的に動くように設計されています．以下の機能を提供します．

* トンボの出力
* 可能な場合には，TrimBox / BleedBoxを設定
* 紙サイズの設定

なお，本パッケージは[日本語組版処理の要件](https://www.w3.org/TR/jlreq/ja/) (JLReq)とは無縁です．JLReqにはトンボに関する記述はありません．

## インストール
$TEXMF/tex/latex/jlreq内にjlreq-trimmarks.styとjlreq-helpers.styを配置してください．


## 使い方
ドライバおよびエンジンを指定して`\usepackage`で読み込みます．エンジンは省略が可能です．

````
\usepackage[dvipdfmx,platex]{jlreq-trimmarks}
````

なお，クラスファイルの`tombow`オプションは使わないでください．

## ノート
jlreq-trimmarksは紙サイズを設定しますが，その他のパッケージとの兼ね合いで正しく機能しないことがあります．その際は[bxpapersize](https://github.com/zr-tex8r/BXpapersize)のようなより強力なパッケージを試してみてください．

## オプション
以下のパッケージオプションを受け付けます．keyval形式です．

### `platex`, `uplatex`, `lulatex`
エンジンの指定です．省略時は，

* `jlreq`クラスファイルを読み込んでいる場合はそれと連動する
* そうでなければ自動推定

です．

### `dvipdfmx`，`dvips`，`dviout`
dviドライバの指定です．エンジンに`lualatex`を利用する場合は指定する必要はありません．省略時は`dvipdfmx`が使われます．

### `trimmarks_paper`
トンボ付きの紙サイズを指定します．
* `trimmarks_paper=a4`のように，`a0--a10`, `b0--b10`, `c2--c8`（BはJIS B列）を指定できる他，`trimmarks_paper={<width>,<height>}`と直接寸法を指定することができます．
* `a4+{1cm,2cm}`や`{10cm,20cm}+{1cm,2cm}`のように`<紙サイズ>+{<寸法横>,<寸法縦>}`とした場合は，指定された紙サイズから指定された寸法だけ増やした紙サイズを設定します．
* `a4+2cm`は`a4+{2cm,2cm}`と等価です．
* `+2cm`と紙サイズの部分を省略すると，現在の紙サイズを利用します．
* デフォルトは`+2in`です．

### `landscape`
紙のサイズの縦と横とを入れ替えます．ただし入れ替えるのは`trimmarks_paper`で明示的に指定された値に限ります．例えば`landscape,trimmarks_paper=+{1cm,2cm}`とすると，もともとの紙サイズ（これは入れ替わらない）の横幅が2cm増え，縦幅が1cm増えた紙サイズとなります．

### `show`
出力する対象を指定します．`show={trimmarks,banner,digital}`のようにカンマ区切りのリストを与えます．引数を与えない場合は全て表示します．

* `trimmarks`：トンボ自身を出力します．
* `banner`：日付などを出力します．
* `digital`：TrimBoxとBleedBoxの設定を行います（デジタルトンボ）．
* `no`：何も表示しません．

### `bleed_margin`
仕上がりと裁ち落としの間（ドブ）の長さを指定します．

## `\jlreqtrimmarkssetup`
パッケージオプションで指定できない設定を行えます．keyval形式です．

### `banner`
`show=banner`時に出力される文字列．

### `trimmarks_width`
トンボ自身の太さを指定します．

### ` color`
トンボの色．この機能を利用するには，あらかじめ`\color`を定義するパッケージ（`color`パッケージまたはその派生）を読み込んでおく必要があります．ここでの指定は次のようにして`\color`命令に変換されます．

* `cy`や`myk`のように`cmyk`という文字列の一部の場合は，`cmyk`で指定された色のみの色になります．例えば`color=cy`は`\color[cmyk]{1,0,1,0}`となります．
* そうでない場合は`\color`の引数に回されます．`[***]`という形が先行する場合は，`\color`のオプションとして扱われます．例えば以下のようになります．

    - `black` -> `\color{black}`
    - `[cmyk]0.5,0.5,0.5,0` -> `\color[cmyk]{0.5,0.5,0.5,0}`

## ライセンス
このパッケージは二条項BSDライセンスの元で配布されています．詳しくは[LICENSE](LICENSE)をご覧ください．

## 履歴
* 2018-05-19
    - 最初のバージョン
* 2018-06-17
    - バグ修正．
* 2018-08-08
    - `trimmarks_paper`を拡張．
    - パッケージオプション`landscape`を追加．
* 2018-09-01
    - `bleed_margin`を`\jlreqtrimmarkssetup`からパッケージオプションに移した．
    - `\mag`が`1000`でない場合も動くようにした（つもり）
    - バグ修正


--------------
Noriyuki Abe
https://github.com/abenori/jlreq

