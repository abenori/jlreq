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



