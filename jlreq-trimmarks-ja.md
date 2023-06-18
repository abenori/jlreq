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
仕上がりと裁ち落としの間（ドブ）の長さを指定します．次のようにすると，上下左右を独立に変更できます．
```latex
\usepackage[bleed_margin={top=3mm,bottom=5mm,gutter=0mm,fore-edge=2mm}]{jlreq-trimmarks}
```

## `\jlreqtrimmarkssetup`
パッケージオプションで指定できない設定を行えます．keyval形式です．

### `banner`
`show=banner`時に出力される文字列．通常は左上に出力されますが，四つ角および上下左右の中心に出力することもできます．指定は
```latex
\jlreqtrimmarkssetup{
  banner={
    <場所（上下，左右中央）>={
      <細かな位置>={
        <ページ数の偶奇に応じて>={
          <表示項目>
        }
      }
    }
  }
}
```
のようになります．キー名は省略することもできます．例えば次のように指定します．

```latex
\jlreqtrimmarkssetup{
  banner={
    top-right={
      tate={
        odd={奇数ページの右上に縦書きで表示},
        even={偶数ページの右上に縦書きで表示},
      },
      yoko={右上に横書きで表示}, % ページの偶奇によらず共通
      corner={右上角に横書きで表示},
      in-yoko={右上版面内に横書きで表示},
      in-tate={右上版面内に縦書きで表示},
    },
    bottom-center={
      left={中央下の左に表示}, % odd=, even=も使用可能
      right={中央下の右に表示},
      in={中央下の版面内に表示},
    },
    center-gutter={
      above={ノド側中央の上側に表示},
      below={ノド側中央の下側に表示},
    },
  }
}
```
場所は`top/bottom/center`と`left/right/center/gutter/fore-edge`の可能な組み合わせが指定可能です．各項目に`\thepage`を指定するとページ数を出力できます．

次のような指定も可能です．
```latex
\jlreqtrimmarkssetup{
  banner={
    tate={左上に縦書き}, % 場所が省略されるとtop-leftと見なされる．
    odd={左上奇数ページ}, % 省略されたのでyokoと見なされる．
    top-right={
      odd={右上奇数ページ} % ここもyokoが省略されている．
    }
  }
}
```


### `trimmarks_width`
トンボ自身の太さを指定します．

### ` color`
トンボの色．この機能を利用するには，あらかじめ`\color`を定義するパッケージ（`color`パッケージまたはその派生）を読み込んでおく必要があります．ここでの指定は次のようにして`\color`命令に変換されます．

* `cy`や`myk`のように`cmyk`という文字列の一部の場合は，`cmyk`で指定された色のみの色になります．例えば`color=cy`は`\color[cmyk]{1,0,1,0}`となります．
* そうでない場合は`\color`の引数に回されます．`[***]`という形が先行する場合は，`\color`のオプションとして扱われます．例えば以下のようになります．

    - `black` -> `\color{black}`
    - `[cmyk]0.5,0.5,0.5,0` -> `\color[cmyk]{0.5,0.5,0.5,0}`

### `trimmarks_pattern`
トンボの形．直接の描画コードを指定します．次のように`centers`に指定すると，上下左右の真ん中のトンボの形が変わります．指定するのは上の真ん中のトンボの描画コードであり，そのほかの場所にはそれを回転したものが描画されます．なお，指定前に`graphicx`パッケージを読み込んでおく必要があります．また`\jlreqtrimmarkswidth`には
```latex
\jlreqtrimmarkssetup{
  trimmarks_pattern = {
    centers = {
      \raisebox{3mm}{
        \vrule width10mm height\jlreqtrimmarkswidth depth 0pt
        \vrule height10mm width\jlreqtrimmarkswidth depth 3mm
        \vrule width10mm height\jlreqtrimmarkswidth depth 0pt
      }
    }
  }
}
```
上下左右の形を個別に指定することもできます．例えば上の真ん中のみ変更するには`top-center=<描画コード>`を指定します．同様に`bottom-center`，`left-center`，`right-center`が指定できます．個別指定には`graphicx`パッケージは不要です．


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
* 2018-12-10
    - `\jlreqtrimmarkssetup`内の`banner`を拡張．
* 2019-04-01
    - `\jlreqtrimmarkssetup`内の`banner`を更に拡張．
    - `bleed_margin`を拡張．
* 2020-05-01
    - `\jlreqtrimmarkssetup`の`banner`を使わない場合，`\@bannertoken`の中身を偶奇ページ両方に出力するようにした．
    - `\jlreqtrimmarkssetup`の`banner`を使う場合，`\@bannertoken`の中身を無視するようにした．
    - `\jlreqtrimmarkssetup`の`banner_font`が指定された場合，`\@bannerfont`を無視するようにした．
* 2021-07-22
    - expl3コードとの親和性を高めた．
* 2021-08-12
    - `etoolbox`に依存しないようにした．
* 2022-07-13
    - 読み込み時にエラーが出るバグ修正．
* 2022-11-28
    - `trimmarks_pattern`を`\jlreqtrimmarkssetup`に追加．
* 2023-06-19
    - 縦書きで読み込み時にエラーが出るバグ修正．

--------------
Noriyuki Abe
https://github.com/abenori/jlreq

