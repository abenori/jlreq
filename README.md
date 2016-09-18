# jlreq

## これは何？
[日本語組版処理の要件](https://www.w3.org/TR/jlreq/ja/)の実装を試みる[LuaTeX-ja](https://osdn.jp/projects/luatex-ja/wiki/FrontPage) / pLaTeX / upLaTeX用のクラスファイルと，それに必要なJFMの組み合わせです．

## 提供されるもの
クラスファイルjlreq.clsと，横書きLuaTeX-ja用のJFMであるlua-jlreq.luaが用意されています．また，縦書きのJFMやpLaTeX / upLaTeX 用のJFMを生成するいくつかのスクリプトがあります．

## 基本版面の設計
クラスファイルへのオプション（keyval形式）として

* `tate`：縦書き．
* `line_length` : 一行の長さ（デフォルトは紙の縦幅の0.768倍）実際の値は一文字の長さの整数倍になるように補正されます．
* `number_of_lines` : 一ページにおける行数（デフォルトは紙の横幅の0.727倍になるような値）．
* `gutter` : 奇数ページにおける右余白，偶数ページにおける左余白（デフォルトは中央寄せになるような値）
* `head_space` : 天の空き量（デフォルトは中央寄せになるような値）
* `foot_space` : 地の空き量（デフォルトは中央寄せになるような値）
* `fontsize` : フォントサイズ（デフォルトは9pt）
* `baselineskip` : 行送り（デフォルトはfontsizeの1.7倍）
* `linegap` : 行間
* `headfoot_sidemargin`：柱やノンブルの左右の空き．

が指定できます．値には`\dimexpr`が解釈できる式が指定できる他，以下の寸法が利用可能です．

* `line_length`，`head_space`，`foot_space`，`gutter` : 全角幅として解釈される`zh`と`zw`．
* `fontsize` : 0.25mmとして解釈される`Q`．
* `baselineskip`, `linegap` : `Q`,`zh`,`zw`．

## 見出し
* 別行見出しは`\DeclareBlockHeading`で
* 同行見出しは`\DeclareRuninHeading`で
* 窓見出しは`\DeclareCutinHeading`で

定義ができます．書式はいずれも

```
\Declare****Heading{<命令名>}{<レベル>}{<設定>}
```

です．`\DeclareBlockHeading`と`\DeclareRuninHeading`は`\<命令名>`と`\<命令名>*`を，`\DeclareCutinHeading`は`\<命令名>`を定義します．窓見出しは常にラベル名や番号を出力しません．`\DeclareBlockHeading`で定義された命令は，最後にオプションで副題を指定できます．
以下の設定を受け付けます．

* `font=<命令>` 文字設定を行う命令を設定します．
* `indent=<数字>` 字下げ量を全角文字数で指定します．
* `subtitle_font=<命令>` （別行見出しのみ）副題のフォントを指定します．
* `lines`，`before_lines`，`after_lines`，`before_space`，`after_space`（別行見出しのみ）行取りの指定を行います．次節を参照．
* `onelinemax=<寸法>`, `twolinemax=<寸法>` （窓見出しのみ）引数の長さが`onelinemax`以下ならば一行で，`twolinemax`以下ならば二行で窓見出しを出力します．それ以上の場合は三行です．デフォルトはそれぞれ6文字，20文字の長さ．

同様の書式で`\NewBlockHeading`，`\RenewBlockHeading`，`\ProvideBlockHeading`等々という命令も用意されています．それぞれ，`\newcommand`，`\renewcommand`，`\providecommand`に対応した動きをします．


### 別行見出しの行取り
別行見出しは行取りの設定ができます．設定方法は以下の三通りです．

* 行数を指定し，その中央に配置します．行数は`lines=<数字>`により設定できます．更に`before_lines=<数字>`や`after_lines=<数字>`により，前後に追加する行数を指定することができます．
* 全体の行数と，その前後の空きの片方を指定します．行数は同様に`lines=<数字>`により指定します．前後の空きは`before_space=<寸法>`または`after_space=<寸法>`で指定します．
* 前後の空きを指定します．`before_space=<寸法>`と`after_space=<寸法>`の両者を指定します．


## ページスタイル

``\DeclarePageStyle{<ページスタイル名>}{<設定>}``

によりページスタイルを定義することができます．設定はkeyval形式で行われ，次が指定可能です．

* `nombre-position`，`running_head_position`: ノンブルと柱の位置を指定します．`top-left`のように指定できます．`center/left/right/top/bottom`が使えます．
* `nombre`: 出力するノンブルを指定します．デフォルトは`\thepage`．
* `odd_running_head`，`even_running_head`：それぞれ奇数ページ，偶数ページの柱を指定します．`_section`のように`_`から始まる名前を指定すると，対応する見出しを出力します．（`_section`だと現在の`\section`を出力する．）


## 後注
後注は`\endnote`で指定します．`\footnote`と同様の書式です．後注自身の出力はドキュメントクラスへの`endnote_position`オプションにより制御されます．

* `endnote_position=_headings`：（デフォルト）見出しの直前に出力する．
* `endnote_position=_paragraph`：改段落時に出力する．
* `endnote_position=<見出し名>`：`\<見出し名>`の直前に出力します．カンマ区切りにより複数の指定が可能です．

``\theendnotes``により明示的に出力を行うこともできます．

## 割注
`\warichu`により割注を指定します．行分割位置などは自動で計算されます．`\warichu*`ではこれらの位置を手動で指定できます．書式は

``\warichu*{(一行目前) & (一行目後)\\ (二行目前) & (二行目後)...}``

です．`&`が省略されている場合は自動で調整されます．

## その他

* クラスファイルにオプション`open_bracket_pos`を渡すことで，行頭における初め括弧の配置方法を指定できます．設定できる値はzenkaku_tentsuki,zenkakunibu_nibu,nibu_tentsukiのいずれかで，それぞれ段落開始全角折り返し行頭天付き（デフォルト），段落開始全角二分折り返し行頭二分，段落開始二分折り返し行頭天付きを意味します．
* クラスファイルにオプション`hanging_punctuation`を渡すことで，ぶら下げ組みを行います．
* クラスファイルにオプション`jlreq_warnings`を渡すと，日本語組版処理の要件に反する設定が行われた場合に警告がされます．

