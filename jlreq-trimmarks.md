# jlreq-trimmarks

## What is this?
This package outputs trim marks. It works with [LuaTeX-ja](https://osdn.jp/projects/luatex-ja/wiki/FrontPage) / pLaTeX / upLaTeX / dvipdfmx / Dvips / dviout. It provides the following.

* Output trim marks
* Set TrimBox and BleedBox if possible.
* Set the size of paper..

## Installation
Move jlreq-trimmarks.sty and jlre-helpers.sty to $TEXMF/tex/latex/jlreq.

## How to use
Load it by `\usepackage` with specifying the TeX engine and the DVI driver. 

````
\usepackage[dvipdfmx,platex]{jlreq-trimmarks}
````

## Options
The following class options (keyval style) are available.

### `platex`, `uplatex`, `lulatex`
Set the engine. If it is not specified, then the engine is

* the one used in the jlreq class if the jlreq class is loaded.
* guessed one if the jlreq class is not loaded.

### `dvipdfmx`, `dvips`, `dviout`
Set the dvi driver. If it is not specified, then

* the package outputs PDF file via LuaLaTeX when the engine is `lualatex`.
* the driver is `dvipdmx` if the engine is `platex` or `uplatex`

### `trimmarks_paper`
Set the size of the paper including trim marks. There are two ways to specify it.

* `trimmarks_paper=<paper type>`: for the paper type, you can use `a0--a10`, `b0--b10` and `c2--c8`. Note that `b0--b10` is `JIS B' (Japanese B-series variant).
* `trimmarks_paper={<width>,height>}`

### `show`
Specify the types of trim marks which the package outputs. It is specified with the comma separated list like `show={trimmarks,banner,digital}`. If no argument is given, everything will be showed.

* `trimmarks`: outputs the trim marks.
* `banner`: date etc.
* `digital`：TrimBox and BleedBox.
* `no`: nothing will be showed

## `\jlreqtrimmarkssetup`
Set the additional settings with the keyval style.

### `banner`
The things which the package outputs when `show=banner` is specified in the class option.

### `bleed_margin`
Set the bleed margin.

### `trimmarks_width`
Set the width of trim marks.

### ` color`
Set the color of the trim marks. You have to load a package which defines `\color` (`color' package or its variant) before loading this package to use this function. Here are some examples of specifying the color.

* `color=c` -> `\color[cmyk]{1,0,0,0}`
* `color=cyk` -> `\color[cmyk]{1,0,1,1}`
* `black` -> `\color{black}`
* `[cmyk]0.5,0.5,0.5,0` -> `\color[cmyk]{0.5,0.5,0.5,0}`

## LICENSE
This package is distributed under the BSD 2-Clause License. See [LICENSE](LICENSE).

## CHANGELOG
* 2018-05-19
    - First release.


--------------
Noriyuki Abe
https://github.com/abenori/jlreq

