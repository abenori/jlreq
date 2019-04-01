# jlreq

## What is this?
This package provides the class file and JFM (Japanese font metric) files for LuaTeX-ja / pLaTeX / upLaTeX. This aims to implement [Requirements for Japanese Text Layout](https://www.w3.org/TR/jlreq/).

## Installation
Run `make` to generate JFM files. Move the files as follows:

* *.tfm -> $TEXMF/fonts/tfm/public/jlreq
* *.vf -> $TEXMF/fonts/vf/public/jlreq
* jfm-jlreq.lua, jfm-jlreqv.lua -> $TEXMF/tex/luatex/jlreq
* jlreq.cls, jlreq-helpers.sty  -> $TEXMF/tex/latex/jlreq

The other way to install is just to run `make install`. It will install all files in `$TEXMFHOME`.

## Usage
See [README-ja.md](README-ja.md) (in Japanese).

## LICENSE
This package is distributed under the BSD 2-Clause License. See [LICENSE](LICENSE).

## CHANGELOG
* 2017-02-08
    - First release.
* 2017-02-17
    - Fixed bugs.
    - Implement `abstract` environment.
    - Changed/Added some keys to class option/`\jlreqsetup`
    - Stopped to load `pxrubirica`, `luatexja-ruby` and `nidanfloat`.
* 2017-03-14
    - Fixed bugs.
    - `\sffamily` etc. also change the Japanese font family.
    - Added many options to `\DeclareBlockHeading`.
    - Some options related to `quote` environment etc.
* 2017-03-20
    - Fixed bugs.
    - Insert some spaces around `\footnote / \sidenote / \endnote`.
* 2017-04-04
    - Fixed a bug.
    - Added options `tate` and `font` to `\DeclarePageStyle`.
* 2017-04-29
    - Fixed bugs.
    - Added `jafontsize` and `jafontscale` options and `\jafontsize`.
    - Added `\tatechuyoko`.
    - `jlreq_warnings` -> `jlreq_notes` (class option).
    - Moved some class options to `\jlreqsetup`.
    - Added some options to `\jlreqsetup`.
    - `paper={<height>,<width>}` -> `paper={<width>,<height>}`.
* 2017-06-11
    - Stopped to load `plext` and `lltjext`.
    - Added `align` to `\DeclareBlockHeading` and delete `indent=center`, `end_indent=center`.
    - Changed `\kcatcode` for some characters (upLaTeX).
* 2017-08-13
    - Added `column_spanning` to `\DeclareBlockHeading`.
    - Sidenotes are a part of the main text now.
    - Changed the default length of sidenotes to 0.
    - jlreq does not define `\sidenote` if the length for sidenotes is zero.
    - Added a command for the full-width ideographic space.
* 2017-08-29
    - Fixed a bug.
* 2017-11-23
    - Fixed bugs.
    - Added `\SetBlockHeadingSpaces`.
    - Removed a space from `\contentsname` and `\indexname`.
* 2017-12-02
    - Fixed bugs.
* 2017-12-22
    - Improved JFM.
    - Change the way to detect `\label` between block headings.
    - Added chapter number to `\theequation`，`\thefigure`，`\thetable`.
* 2018-02-01
    - Sidenotes appears only odd pages in `tate` mode.
    - Added `\fnfixbottomtrue` for LuaLaTeX.
    - Added some options related to captions.
    - Extended `itemization_beforeafter_space`.
    - Fixed bugs.
* 2018-04-11
    - Sidenotes (`\footnote`) appears in the second column in `tate` mode.
    - Added options `begin_widh_(odd|even)_page` to `\DeclareBlockHeading`.
    - Changed `\labelenumi`  as in `jarticle` etc.
    - Fix a bug on `column_gap` class option.
    - Added `mark_format` to `\DeclarePageStyle`.
* 2018-05-19
    - Made the width of the label in the table of contents longer.
    - Moved some macros to jlreq-helpers.sty
    - Fixed bugs.
* 2018-06-17
    - Gothic font is attached to font shape 'b'.
    - Fixed bugs.
* 2018-08-08
    - Added `nombre_ii` etc. to `\DeclarePageStyle`.
    - Fixed bugs.
    - Added `footnote_second_indent` and `endnote_second_indent` to `\jlreqsetup`.
* 2018-08-15
    - Fixed bugs.
* 2018-09-01
    - jlreq works with unusual `\mag`.
    - Fixed bugs.
* 2018-12-10
    - Added `number=[true/false]` to `\New***Heading`.
    - Added options for `\frontmatter` etc in `\jlreqsetup`.
    - Made `\jlreqHeadingLabel` etc available in `format` in `\NewTobiraHeading` and `\NewBlockHeading`.
    - Fixed bugs.
* 2019-01-15
    - Added `nombre_font` etc to `\NewPageStyle`. `font` is deprecated.
    - `format` without `#1` is allowed in `\NewBlockHeading`.
    - Extended `caption_label_format` etc. in `\jlreqsetup`.
    - Fixed bugs.
* 2019-04-01
    - Added `use_reverse_pagination` to the class option.
    - Stopped to use `zref` package.
    - New regnal year.
    - Fixed bugs.


--------------
Noriyuki Abe
https://github.com/abenori/jlreq
