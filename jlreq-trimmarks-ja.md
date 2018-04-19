# jlreq-trimmarks

## これは何？
トンボ（トリムマーク）を出力するためのパッケージです．[LuaTeX-ja](https://osdn.jp/projects/luatex-ja/wiki/FrontPage) / pLaTeX / upLaTeX 上で動きます．以下の機能を提供します．

* トンボの出力
* PDF出力時には，CropBox / TrimBox / ArtBox / BleedBoxを設定
* 紙サイズの設定

## 使い方
ドライバおよびエンジンを指定して`\usepackage`で読み込みます．エンジンは省略が可能です．

````
\usepackage[dvipdfmx,platex]{jlreq-trimmarks}
````

## オプション
以下のクラスオプションを受け付けます．keyval形式です．

### `platex`, `uplatex`, `lulatex`
エンジンの指定です．省略時は，

* `jlreq`クラスファイルを読み込んでいる場合はそれと連動する
* そうでなければ自動推定

です．

### `dvipdfmx`，`dvips`
dviドライバの指定です．省略時は

* `lualatex`利用時は指定されている場合はLuaLaTeXによりPDF出力が行われると見なされる．
* `platex`または`uplatex`利用時は`dvipdfmx`．

### `trimmarks_paper`
トンボ付きの紙サイズを指定します．`trimmarks_paper=a4`のように，`a0--a10`, `b0--b10`, `c2--c8`（BはJIS B列）を指定できる他，`trimmarks_paper={<width>,<height>}`と直接寸法を指定することも可能です．指定されなかった場合は，現在の紙サイズから縦横2インチ増えた値を採用します．

### `show`
何を出力するか指定します．`show={trimmarks,banner,digital}`のようにカンマ区切りのリストを与えます．

* `trimmarks`：トンボ自身を出力します．
* `banner`：日付などを出力します．
* `digital`：CropBox等の設定を行います（デジタルトンボ）．

## `\jlreqtrimmarkssetup`
クラスオプションで指定できない設定を行えます．keyval形式です．

### `banner`
`show=banner`時に出力される文字列．

### `bleed_margin`
仕上がりと裁ち落としの間（ドブ）の長さを指定します．

### `trimmarks_width`
トンボ自身の太さを指定します．

### ` color`
トンボの色．この機能を利用するには，あらかじめ`xcolor`パッケージを読み込んでおく必要があります．色は次のように指定します．

* `cy`や`myk`のように`cmyk`という文字列の一部の場合は，`cmyk`で指定された色のみの色になります．例えば`color=cy`は`\color[cmyk]{1,0,1,0}`で出力される色になります．
* そうでない場合は`\color`の引数に回されます．`[***]`という形が先行する場合は，`\color`のオプションとして扱われます．例えば以下のようになります．

    - `black` -> `\color{black}`
    - `[cmyk]0.5,0.5,0.5,0` -> `\color[cmyk]{0.5,0.5,0.5,0}`


## 履歴


--------------
Noriyuki Abe
https://github.com/abenori/jlreq

