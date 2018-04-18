# jlreq-trimmarks

## What is this?
This package outputs trim marks. It works with [LuaTeX-ja](https://osdn.jp/projects/luatex-ja/wiki/FrontPage), pLaTeX or upLaTeX. It provides the following.

* Output trim marks
* Set CropBox, TrimBox, ArtBox and BleedBox in PDF file.
* Set the size of paper..

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

### `dvipdfmx`, `dvips`
Set the dvi driver. If it is not specified, then

* the package outputs PDF file via LuaLaTeX when the engine is `lualatex`.
* the driver is `dvipdmx` if the engine is `platex` or `uplatex`

### `trimmarks_paper`
Set the size of the paper including trim marks. There are two ways to specify it.

* `trimmarks_paper=<paper type>`: for the paper type, you can use `a0--a10`, `b0--b10` and `c2--c8`. Note that `b0--b10` is `JIS B' (Japanese B-series variant).
* `trimmarks_paper={<width>,height>}`

### `show`
Specify the types of trim marks which the package outputs. It is specified with the comma separated list like `show={trimmarks,banner,digital}`.

* `trimmarks`: outputs the trim marks itself.
* `banner`: date etc.
* `digital`：CropBox etc.

## `\jlreqtrimmarkssetup`
Set the additional settings with the keyval style.

### `banner`
The things which the package outputs when `show=banner` is specified in the class option.

### `bleed_margin`
Set the bleed margin.

### `trimmarks_width`
Set the width of trim marks.

### ` color`
Set the color of the trim marks. You have to load `xcolor` package before loading this package to use this function. Here are some examples of specifying the color.

* `color=c` -> `\color[cmyk]{1,0,0,0}`
* `color=cyk` -> `\color[cmyk]{1,0,1,1}`
* `black` -> `\color{black}`
* `[cmyk]0.5,0.5,0.5,0` -> `\color[cmyk]{0.5,0.5,0.5,0}`


## History


--------------
Noriyuki Abe
https://github.com/abenori/jlreq

