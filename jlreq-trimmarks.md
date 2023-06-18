# jlreq-trimmarks

## What is this?
This package outputs trim (register) marks. It works with [LuaTeX-ja](https://osdn.jp/projects/luatex-ja/wiki/FrontPage) / pLaTeX / upLaTeX / dvipdfmx / Dvips / dviout and any document class (not only with jlreq class). It provides the following.

* Output trim marks
* Set TrimBox and BleedBox if possible.
* Set the size of paper.

Note that this package is independent from [Requirements for Japanese Text Layout](https://www.w3.org/TR/jlreq/) (JLReq). JLReq says nothing about trim marks.

## Installation
Move jlreq-trimmarks.sty and jlre-helpers.sty to $TEXMF/tex/latex/jlreq.

## How to use
Load it by `\usepackage` with specifying the TeX engine and the DVI driver. 

````
\usepackage[dvipdfmx,platex]{jlreq-trimmarks}
````

Do not use `tombow` option in the document class.

## Note
jlreq-trimmarks sets the size of the paper. However, it may not work due to a conflict with other packages. In this case, please use more powerful package, e.g., [bxpapersize](https://github.com/zr-tex8r/BXpapersize).

## Options
The following package options (keyval style) are available.

### `platex`, `uplatex`, `lulatex`
Set the engine. If it is not specified, then the engine is

* the one used in the jlreq class if the jlreq class is loaded.
* guessed one if the jlreq class is not loaded.

### `dvipdfmx`, `dvips`, `dviout`
Set the dvi driver. You do not have to specify it when using the engine `lualatex`. If it is not specified (with `platex` or `uplatex`), then `dvipdfmx` is used.

### `trimmarks_paper`
Set the size of the paper including trim marks.

* `trimmarks_paper=<paper type>`: specify via the paper type. for the paper type, you can use `a0--a10`, `b0--b10` and `c2--c8`. Note that `b0--b10` is `JIS B' (Japanese B-series variant).
* `trimmarks_paper={<width>,height>}`: specify via the width and height.
* `trimmarks_paper=<paper size>+{<width>,<height>}` (e.g. `trimmarks_paper=a4+{1cm,2cm}`): `<width>` (resp. `<height>`) is added to the width (resp. height) of the paper size specified by `<paper size>`  For `<paper size>`, one can use `<paper type>` or `{<width>,<height>}` as in the above.
* `trimmarks_paper=a4+2cm` is equivalent to `trimmarks_paper=a4+{2cm,2cm}`.
* If `<paper size>` is empty (e.g. `trimmarks_paper=+2cm`), the current paper size (which is specified usually by the option for the document class) is used.

### `landscape`
Swap the width and the height. This swaps only the width and height which is specified with the option `trimmarks_paper`. For example, `landscape,trimmarks_paper=+{1cm,2cm}`, adds 1cm to the height and 2cm to the width. But the current paper size is not swapped.

### `show`
Specify the types of trim marks which the package outputs. It is specified with the comma separated list like `show={trimmarks,banner,digital}`. If no argument is given, everything will be showed.

* `trimmarks`: outputs the trim marks.
* `banner`: date etc.
* `digital`：TrimBox and BleedBox.
* `no`: nothing will be showed

### `bleed_margin`
Set the bleed margin.
You can also specify as follows.
```latex
\usepackage[bleed_margin={top=3mm,bottom=5mm,gutter=0mm,fore-edge=2mm}]{jlreq-trimmarks}
```

## `\jlreqtrimmarkssetup`
Set the additional settings with the keyval style.

### `banner`
The things which the package outputs when `show=banner` is specified in the package option.
Normally it is showed in the left of the top. You can also put them in many places with
```latex
\jlreqtrimmarkssetup{
  banner={
    <Position (top/bottom, left/right, center)>={
      <more precise position>={
        <odd/even>={
          <content>
        }
      }
    }
  }
}
```
Here is an example.
```latex
\jlreqtrimmarkssetup{
  banner={
    top-right={
      vertical={
        odd={In the right of the top, only in odd pages, vertical mode.},
        even={In the right of the top, only in even pages, vertical mode.},
      },
      horizontal={In the right of the top, horizontal mode.}, % does not depend on the parity of the page number
      corner={In the corner of the right of the top, horizontal mode.},
      in-horizontal={In the right of the top, horizontal mode, in the trim area.},
      in-vertical={In the right of the top, vertical mode, in the trim area.},
    },
    bottom-center={
      left={In the left in the center of the bottom}, % odd=, even= is also available
      right={In the right in the center of the bottom},
      in={In the trim area in the center of the bottom.},
    }
  }
}
```
A possible combination of `top/bottom/center` and `left/right/center/gutter/fore-edge` can be used for the position.
You can use `\thepage` to output the number of the page.

The keys can be ommited. For example:
```latex
\jlreqtrimmarkssetup{
  banner={
    vertical={Vertical mode, in the top of the left},
    odd={In the top of the left, only in odd pages.}, % regarded as `horizontal`
    top-right={
      odd={In the top of the right, only in odd pages, horizontal mode.}
    }
  }
}
```

### `trimmarks_width`
Set the width of trim marks.

### ` color`
Set the color of the trim marks. You have to load a package which defines `\color` (`color' package or its variant) before loading this package to use this function. Here are some examples of specifying the color.

* `color=c` -> `\color[cmyk]{1,0,0,0}`
* `color=cyk` -> `\color[cmyk]{1,0,1,1}`
* `black` -> `\color{black}`
* `[cmyk]0.5,0.5,0.5,0` -> `\color[cmyk]{0.5,0.5,0.5,0}`

### `trimmarks_pattern`
Set the shape of the trim marks by the code. You can change the shapes of trim marks at the centers of top, bottom, left and right by the following code. Here, the specified code is the code for the top-center trim marks and rotated ones are put at the other places. Here, `graphicx` code should be loaded.
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
You can specify shapes for top, bottom, left and right independently. For example, you can change the shape at the top-center by `top-center=<code>`. Similarly one can use `bottom-center`，`left-center`，`right-center`. `graphix` package is not needed for these keys.


## LICENSE
This package is distributed under the BSD 2-Clause License. See [LICENSE](LICENSE).

## CHANGELOG
* 2018-05-19
    - First release.
* 2018-06-17
    - Fixed a bug.
* 2018-08-08
    - Extended `trimmarks_paper`.
    - Added a package option `landscape`.
* 2018-09-01
    - Moved `bleed_margin` from `\jlreqtrimmarkssetup` to a package option.
    - jlreq-trimmarks works with unusugal`\mag`.
    - Fixed bugs.
* 2018-12-10
    - Extended `banner` in `\jlreqtrimmarkssetup`.
* 2019-04-01
    - Extended `banner` in `\jlreqtrimmarkssetup`.
    - Extended `bleed_margin`．
* 2020-05-01
    - `jlreq-trimmarks` outputs the contents in `\@bannertoken` when `banner` in `\jlreqtrimmarkssetup` is not used.
    - `\@bannertoken` is ignored when `banner` in `\jlreqtrimmarkssetup` is used.
    - `\@bannerfont` is ignored when `banner_font` in `\jlreqtrimmarkssetup` is used.
* 2021-07-22
    - It has more compatibility with expl3.
* 2021-08-12
    - Removed dependence on `etoolbox` package.
* 2022-07-13
    - Fixed a bug: an error occurred when loading.
* 2022-11-28
    - Added `trimmarks_pattern` to `\jlreqtrimmarkssetup`.
* 2023-06-19
    - Fixed a bug: an error occurred when the package is loaded with tate mode.

--------------
Noriyuki Abe
https://github.com/abenori/jlreq

