# jlreq

## これは何？
[日本語組版処理の要件](https://www.w3.org/TR/jlreq/ja/)の実装を試みる[LuaTeX-ja](https://osdn.jp/projects/luatex-ja/wiki/FrontPage)用のクラスファイルと，それに必要なJFMの組み合わせです．

## 提供されるもの
現在は以下が提供されています．

* tjlreq.cls: 縦書き用のクラスファイル．LaTeX2eにおけるarticle.clsと同じ立ち位置．
* jfm-jlreqv.lua: 縦書き用のJFM．

## 基本版面の設計
クラスファイルへのオプション（keyval形式）として

* `line_length` : 一行の長さ（デフォルトは紙の縦幅の0.768倍）
* `number_of_lines` : 一ページにおける行数（デフォルトは紙の横幅の0.727倍になるような値）
* `fontsize` : フォントサイズ（デフォルトは10pt）
* `baselineskip` : 行送り（デフォルトはfontsizeの1.7倍）
* `linegap` : 行間

が指定できる．値には`\dimexpr`が解釈できる式が指定できる他，以下の寸法が利用可能．

* `line_length` : 全角幅として解釈される`zh`と`zw`．
* `fontsize` : 0.25mmとして解釈される`Q`．
* `baselineskip`, `linegap` : `Q`,`zh`,`zw`．

## 見出し
見出しは
* 別行見出しは`\DeclareBlockHeading`で
* 同行見出しは`\DeclareRuninHeading`で
* 窓見出しは`\DeclareCutinHeading`で

定義ができる．書式はいずれも

```
\DeclareBlockHeading{<命令名>}{<レベル>}{<設定>}
```

である．`\DeclareBlockHeading`と`\DeclareRuninHeading`は`\<命令名>`と`\<命令名>*`を，`\DeclareCutinHeading`は`\<命令名>`を定義する．窓見出しは常にラベル名や番号を出力しない．
設定はkeyval形式で行われ，
* `font=<命令>` 文字設定を行う命令を設定する．
* `indent=<数字>` 字下げ量を全角文字数で指定する
* `before_space=<寸法>`，`after_space=<寸法>` （別行見出しのみ）それぞれ見出し前後のスペースの量を指定する．両方設定されていなければ見出しが中央に来るように配置される．
* `lines=<数字>` （別行見出しのみ）見出しが何行とるかを指定する．デフォルトは一行．`before_space`と`after_space`の両方が設定されていればこの設定は無視される．
* `onelinemax=<寸法>`, `twolinemax=<寸法>` （窓見出しのみ）引数の長さが`onelinemax`以下ならば一行で，`twolinemax`以下ならば二行で窓見出しを出力する．それ以上の場合は三行である．デフォルトはそれぞれ6文字，20文字の長さ．

を受け付ける．

同様の書式で`\NewBlockHeading`，`\RenewBlockHeading`，`\ProvideBlockHeading`等々という命令も用意されている．それぞれ，`\newcommand`，`\renewcommand`，`\providecommand`に対応した動きをする．


