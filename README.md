# jlreq

## これは何？
[日本語組版処理の要件](https://www.w3.org/TR/jlreq/ja/)の実装を試みる[LuaTeX-ja](https://osdn.jp/projects/luatex-ja/wiki/FrontPage) / pLaTeX / upLaTeX用のクラスファイルと，それに必要なJFMの組み合わせです．

## 提供されるもの
現在は以下が提供されています．

* tjlreq.cls: 縦書き用のクラスファイル．LaTeX2eにおけるarticle.clsと同じ立ち位置．
* jfm-jlreqv.lua: 縦書き用のJFM．

## 基本版面の設計
クラスファイルへのオプション（keyval形式）として

* `line_length` : 一行の長さ（デフォルトは紙の縦幅の0.768倍）実際の値は一文字の長さの整数倍になるように補正されます．
* `number_of_lines` : 一ページにおける行数（デフォルトは紙の横幅の0.727倍になるような値）．
* `gutter` : 奇数ページにおける右余白，偶数ページにおける左余白（デフォルトは中央寄せになるような値）
* `foot_space` : 地の空き量（デフォルトは中央寄せになるような値）
* `fontsize` : フォントサイズ（デフォルトは9pt）
* `baselineskip` : 行送り（デフォルトはfontsizeの1.7倍）
* `linegap` : 行間

が指定できます．値には`\dimexpr`が解釈できる式が指定できる他，以下の寸法が利用可能です．

* `line_length` : 全角幅として解釈される`zh`と`zw`．
* `fontsize` : 0.25mmとして解釈される`Q`．
* `baselineskip`, `linegap` : `Q`,`zh`,`zw`．

## 見出し
見出しは
* 別行見出しは`\DeclareBlockHeading`で
* 同行見出しは`\DeclareRuninHeading`で
* 窓見出しは`\DeclareCutinHeading`で

定義ができます．書式はいずれも

```
\DeclareBlockHeading{<命令名>}{<レベル>}{<設定>}
```

です．`\DeclareBlockHeading`と`\DeclareRuninHeading`は`\<命令名>`と`\<命令名>*`を，`\DeclareCutinHeading`は`\<命令名>`を定義します．窓見出しは常にラベル名や番号を出力しません．
設定はkeyval形式で行われ，

* `font=<命令>` 文字設定を行う命令を設定します．
* `indent=<数字>` 字下げ量を全角文字数で指定します．
* `before_space=<寸法>`，`after_space=<寸法>` （別行見出しのみ）それぞれ見出し前後のスペースの量を指定します．両方設定されていなければ見出しが中央に来るように配置されます．
* `lines=<数字>` （別行見出しのみ）見出しが何行とるかを指定します．デフォルトは一行です．`before_space`と`after_space`の両方が設定されていればこの設定は無視されます．
* `onelinemax=<寸法>`, `twolinemax=<寸法>` （窓見出しのみ）引数の長さが`onelinemax`以下ならば一行で，`twolinemax`以下ならば二行で窓見出しを出力します．それ以上の場合は三行です．デフォルトはそれぞれ6文字，20文字の長さ．

を受け付けます．

同様の書式で`\NewBlockHeading`，`\RenewBlockHeading`，`\ProvideBlockHeading`等々という命令も用意されている．それぞれ，`\newcommand`，`\renewcommand`，`\providecommand`に対応した動きをします．

## その他

* クラスファイルにオプション`open_bracket_pos`を渡すことで，行頭における初め括弧の配置方法を指定できます．設定できる値はzenkaku_tentsuki,zenkakunibu_nibu,nibu_tentsukiのいずれかで，それぞれ段落開始全角折り返し行頭天付き（デフォルト），段落開始全角二分折り返し行頭二分，段落開始二分折り返し行頭天付きを意味します．
* クラスファイルにオプション`hanging_punctuation`を渡すことで，ぶら下げ組みを行います．
