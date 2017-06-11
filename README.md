# jlreq

## What is this?
This package provides the class file and JFM (Japanese font metric) files for LuaTeX-ja / pLaTeX / upLaTeX. This aims to implement [Requirements for Japanese Text Layout](https://www.w3.org/TR/jlreq/).

## Installation
Run `make`, then JFM files are created. Move the files as follows:

* *.tfm -> $TEXMF/fonts/tfm/public/jlreq
* *.vf -> $TEXMF/fonts/vf/public/jlreq
* jfm-jlreq.lua jfm-jlreqv.lua -> $TEXMF/tex/luatex/jlreq
* jlreq.cls -> $TEXMF/tex/latex/jlreq

`make install` will do this where $TEXMF=$TEXMFHOME

## Usage
See [README-ja.md](README-ja.md) (in Japanese).

## LICENSE
This package is distributed under the BSD 2-Clause License. See [LICENSE](LICENSE).

## CHANGELOG
* 2017-02-08
    - First release.
* 2017-02-17
    - Fix bugs.
    - Implement `abstract` environment.
    - Change/Add some keys to class option/`\jlreqsetup`
    - Stop to load `pxrubirica`, `luatexja-ruby` and `nidanfloat`.
* 2017-03-14
    - Fix bugs.
    - `\sffamily` etc. also change the Japanese font family.
    - Add many options to `\DeclareBlockHeading`.
    - Some options related to `quote` environment etc.
* 2017-03-20
    - Fix bugs.
    - Insert some spaces around `\footnote / \sidenote / \endnote`.
* 2017-04-04
    - Fix a bug.
    - Add options `tate` and `font` to `\DeclarePageStyle`.
* 2017-04-29
    - Fix bugs.
    - Add `jafontsize` and `jafontscale` options and `\jafontsize`.
    - Add `\tatechuyoko`.
    - `jlreq_warnings` -> `jlreq_notes` (class option).
    - Move some class options to `\jlreqsetup`.
    - Add some options to `\jlreqsetup`.
    - `paper={<height>,<width>}` -> `paper={<width>,<height>}`.


--------------
Noriyuki Abe
https://github.com/abenori/jlreq
