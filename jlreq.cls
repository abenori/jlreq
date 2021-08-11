%% Japanese document class based on requirements for Japanese text layout
%% 
%% The package is distributed under the BSD 2-Clause License
%%
%%
% (based on JLReq 20200811 https://www.w3.org/TR/2020/NOTE-jlreq-20200811/)
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jlreq}[2021/08/12 jlreq]
\RequirePackage{l3keys2e}
\RequirePackage{ifthen}
\RequirePackage{jlreq-helpers}

\ExplSyntaxOn
\tl_new:N \l_jlreq_tmpa_tl
\cs_new:Nn \l_jlreq_do: {}
\str_new:N \l_jlreq_tmpa_str
\str_new:N \l_jlreq_tmpb_str
\str_new:N \l_jlreq_tmpc_str
\bool_new:N \l_jlreq_tmpa_bool
\clist_new:N \l_jlreq_tmpa_clist
\seq_new:N \l_jlreq_tmpa_seq
\dim_new:N \l_jlreq_tmpa_dim
\skip_new:N \l_jlreq_tmpa_skip
\box_new:N \l_jlreq_tmpa_box
\box_new:N \l_jlreq_tmpb_box
\box_new:N \l_jlreq_tmpc_box

\cs_set:Nn \__jlreq_undeferr:n {\ClassError{jlreq}{Trying~to~delete~\string#1~even~though~it~is~not~defined,~may~be~a~bug}{\@ehc}}
% クラスファイル内でしか使わないマクロをクラスファイル終了時に未定義にする
\seq_new:N \g__jlreq_aftercls_deletecs_seq
\seq_new:N \g__jlreq_aftercls_deleteif_seq
\cs_set:Nn \__jlreq_aftercls_addtodeletecs:N {
  \seq_gput_right:Nn \g__jlreq_aftercls_deletecs_seq {#1}
}
\__jlreq_aftercls_addtodeletecs:N \__jlreq_aftercls_addtodeletecs:N
\cs_set:Nn \__jlreq_aftercls_addtodeleteif:N {
  \seq_gput_right:Nn \g__jlreq_aftercls_deleteif_seq {#1}
}
\__jlreq_aftercls_addtodeletecs:N \__jlreq_aftercls_addtodeleteif:N
\AtEndOfClass{%
  \seq_map_inline:Nn \g__jlreq_aftercls_deletecs_seq {
    \jlreq@helper@undefcs{#1}{\__jlreq_undeferr:n}
  }
  \seq_map_inline:Nn \g__jlreq_aftercls_deleteif_seq {
    \jlreq@helper@undefif{#1}{\__jlreq_undeferr:n}
  }
  \cs_undefine:N \g__jlreq_aftercls_deletecs_seq
  \cs_undefine:N \g__jlreq_aftercls_deleteif_seq
  \cs_undefine:N \__jlreq_undeferr:n
}

% preambleにいるかのスイッチ
\newif\ifjlreq@preamble
\jlreq@preambletrue
\AtBeginDocument{\jlreq@preamblefalse}

\def\jlreq@saveoriginalcs#1{%
  \@ifundefined{#1}{
    \ClassError{jlreq}{Trying~to~save~#1~but~it's~not~defined,~may~be~a~bug}{\@ehc}%
  }{}
  \@ifundefined{jlreq@original@#1}{}{
    \ClassError{jlreq}{Trying~to~save~#1~twice,~may~be~a~bug}{\@ehc}%
  }
  \begingroup
    \edef\jlreq@do{\noexpand\let\exp_not:c {jlreq@original@#1}=\exp_not:c {#1}}
  \expandafter\endgroup
  \jlreq@do
}
\def\jlreq@useoriginalcs#1{%
  \jlreq@if{\ifcsname jlreq@original@#1\endcsname\fi}%
    {\csname jlreq@original@#1\endcsname}%
    {#1}%
}
\def\jlreq@restoreoriginalcs#1{%
  \jlreq@if{\ifcsname jlreq@original@\expandafter\@gobble\string#1\endcsname\fi}%
    {\expandafter\let\expandafter#1\csname jlreq@original@\expandafter\@gobble\string#1\endcsname}{}%
}

%. オプションの定義
% オプション処理の際にしか使わない変数（後でそれを元に別の変数を調整する）
% ものは\jlreq@option@<key>に格納する．
% _とかは@に変換する．
% エンジン類
\keys_define:nn { jlreq } { uplatex .code:n = { \let\jlreq@engine=u }, uplatex .value_forbidden:n = true }
\keys_define:nn { jlreq } { platex .code:n = { \let\jlreq@engine=p }, platex .value_forbidden:n = true }
\keys_define:nn { jlreq } { lualatex .code:n = { \let\jlreq@engine=l }, lualatex .value_forbidden:n = true }

% 文書のタイプ
\keys_define:nn { jlreq } { article_type .choices:nn = {article,report,book}{\def\jlreq@article@type{#1}} }
\keys_define:nn { jlreq } { article .code:n = { \def\jlreq@article@type{article} }, article .value_forbidden:n = true }
\keys_define:nn { jlreq } { report .code:n = { \def\jlreq@article@type{report} }, report .value_forbidden:n = true }
\keys_define:nn { jlreq } { book .code:n = { \def\jlreq@article@type{book} }, book .value_forbidden:n = true }

%.. 基本版面．まずは紙サイズ．
\tl_new:N \g__jlreq_papersizelist_tl
\cs_set:Nn \__jlreq_addpapersize:nnn {
  \exp_args:Nnnv \__jlreq_addpapersize_aux:nnn {#1}{#2}{jlreq@helper@papersizelist@#3}
}
\cs_set:Nn \__jlreq_addpapersize_aux:nnn {
  \__jlreq_addpapersize_auxi:nnnn {#1}{#2}#3
}
\cs_set:Nn \__jlreq_addpapersize_auxi:nnnn {
  \clist_map_inline:nn {#1} {
    \tl_gput_right:Nn \g__jlreq_papersizelist_tl { { ##1 } { \setlength{\paperwidth}{#3} \setlength{\paperheight}{#4} } }
  }
  \clist_map_inline:nn {#2} {
    \keys_define:nn { jlreq } { ##1 .code:n = { \setlength{\paperwidth}{#3} \setlength{\paperheight}{#4} } }
  }
}
\keys_define:nn { jlreq } {
  paper .code:n = {
    \str_case:nVF {#1} \g__jlreq_papersizelist_tl
    {
      \jlreq@helper@dividebycomma{#1}%
      \legacy_if:nTF { jlreq@result } {
        \setlength{\paperwidth}{\dimexpr\jlreq@resulta\relax}
        \setlength{\paperheight}{\dimexpr\jlreq@resultb\relax}
      } {
        \ClassError { jlreq } { The~paper~#1~is~unknown } {\@ehc}
      }
    }
  }
}

\__jlreq_aftercls_addtodeletecs:N \__jlreq_addpapersize:nnn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_addpapersize_aux:nnn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_addpapersize_auxi:nnnn
\__jlreq_aftercls_addtodeletecs:N \g__jlreq_papersizelist_tl

% 紙サイズ一覧．b*はJIS B．
\__jlreq_addpapersize:nnn{a0,A0}{}{a0}
\__jlreq_addpapersize:nnn{a1,A1}{}{a1}
\__jlreq_addpapersize:nnn{a2,A2}{}{a2}
\__jlreq_addpapersize:nnn{a3,A3}{a3paper}{a3}
\__jlreq_addpapersize:nnn{a4,A4}{a4paper}{a4}
\__jlreq_addpapersize:nnn{a5,A5}{a5paper}{a5}
\__jlreq_addpapersize:nnn{a6,A6}{a6paper}{a6}
\__jlreq_addpapersize:nnn{a7,A7}{}{a7}
\__jlreq_addpapersize:nnn{a8,A8}{}{a8}
\__jlreq_addpapersize:nnn{a9,A9}{}{a9}
\__jlreq_addpapersize:nnn{a10,A10}{}{a10}

\__jlreq_addpapersize:nnn{b0,B0}{}{b0}
\__jlreq_addpapersize:nnn{b1,B1}{}{b1}
\__jlreq_addpapersize:nnn{b2,B2}{}{b2}
\__jlreq_addpapersize:nnn{b3,B3}{}{b3}
\__jlreq_addpapersize:nnn{b4,B4}{b4paper}{b4}
\__jlreq_addpapersize:nnn{b5,B5}{b5paper}{b5}
\__jlreq_addpapersize:nnn{b6,B6}{b6paper}{b6}
\__jlreq_addpapersize:nnn{b7,B7}{}{b7}
\__jlreq_addpapersize:nnn{b8,B8}{}{b8}
\__jlreq_addpapersize:nnn{b9,B9}{}{b9}
\__jlreq_addpapersize:nnn{b10,B10}{}{b10}

\__jlreq_addpapersize:nnn{c2,C2}{}{c2}
\__jlreq_addpapersize:nnn{c3,C3}{}{c3}
\__jlreq_addpapersize:nnn{c4,C4}{}{c4}
\__jlreq_addpapersize:nnn{c5,C5}{}{c5}
\__jlreq_addpapersize:nnn{c6,C6}{}{c6}
\__jlreq_addpapersize:nnn{c7,C7}{}{c7}
\__jlreq_addpapersize:nnn{c8,C8}{}{c8}

\__jlreq_addpapersize:nnn{a4var}{}{a4var}
\__jlreq_addpapersize:nnn{b5var}{}{b5var}

\__jlreq_addpapersize:nnn{letter}{letterpaper}{letter}
\__jlreq_addpapersize:nnn{legal}{legalpaper}{legal}
\__jlreq_addpapersize:nnn{executive}{executivepaper}{executive}
\__jlreq_addpapersize:nnn{hagaki}{}{hagaki}


%.. フォントサイズ，行長，1ページあたりの行数で基本版面のサイズを決める（2.4.1.a）
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@fontsize
\keys_define:nn { jlreq } { fontsize .tl_set:N = \jlreq@option@fontsize }
\keys_define:nn { jlreq } {
  10pt .code:n = {\def\jlreq@option@fontsize{10pt}}, 10pt .value_forbidden:n = true,
  11pt .code:n = {\def\jlreq@option@fontsize{11pt}}, 11pt .value_forbidden:n = true,
  12pt .code:n = {\def\jlreq@option@fontsize{12pt}}, 12pt .value_forbidden:n = true,
}
\keys_define:nn { jlreq } { jafontsize .tl_set:N = \jlreq@option@jafontsize }
\keys_define:nn { jlreq } { jafontscale .tl_set:N = \jlreq@option@jafontscale }
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@jafontsize
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@jafontscale
%.. 行の長さ
\keys_define:nn { jlreq } { line_length .tl_set:N = \jlreq@option@line@length }
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@line@length
%.. 1ページあたりの行数
\keys_define:nn { jlreq } { number_of_lines .tl_set:N = \jlreq@option@number@of@lines }
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@number@of@lines

% 地の空き量，のどの空き量で配置位置を決める（2.4.1.b）省略されたら中央配置．
%.. 天
\keys_define:nn { jlreq } { head_space .tl_set:N = \jlreq@option@head@space }
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@head@space
%.. 地
\keys_define:nn { jlreq } { foot_space .tl_set:N = \jlreq@option@foot@space }
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@foot@space
%.. のど
\keys_define:nn { jlreq } { gutter .tl_set:N = \jlreq@option@gutter }
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@gutter
%.. 小口
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@fore@edge
\keys_define:nn { jlreq } {
  fore_edge .tl_set:N = \jlreq@option@fore@edge,
  fore-edge .tl_set:N = \jlreq@option@fore@edge
}

%.. 柱とノンブル
% 本文とヘッダ/フッタの間の空き
\keys_define:nn { jlreq } { headfoot_verticalposition .tl_set:N = \jlreq@option@headfoot@verticalpos}
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@headfoot@verticalpos
% 柱やノンブルの左右の空き
\keys_define:nn { jlreq } { headfoot_sidemargin .tl_set:N = \jlreq@headfoot@sidemargin}

%.. 段間
\keys_define:nn { jlreq } { column_gap .tl_set:N = \jlreq@option@column@gap}
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@column@gap

%.. 行送り，指定無しの場合は文字サイズの1.7倍とする．（1.5から2倍が好ましい：2.4.2.d 注3）
\keys_define:nn { jlreq } {
  baselineskip .tl_set:N = \jlreq@option@baselineskip,
  linegap .code:n = { \def\jlreq@option@baselineskip{1zw + #1} }
}
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@baselineskip

%.. 組み方系
% 行頭に括弧が来たときの配置：3.1.5
% 段落頭指定_折り返し行頭指定 で与える．
\keys_define:nn { jlreq } { open_bracket_pos .choices:nn = {zenkaku_tentsuki,zenkakunibu_nibu,nibu_tentsuki}{\def\jlreq@open@bracket@pos{#1}} }
% ぶら下げ組みをするか：3.8.2 注1
\newif\ifjlreq@burasage\jlreq@burasagefalse
\keys_define:nn { jlreq } { hanging_punctuation .code:n = {\jlreq@burasagetrue}, hanging_punctuation .value_forbidden:n = true}
% jsarticleと同じkanjiskipを使う
\newif\ifjlreq@narrow@kanjiskip\jlreq@narrow@kanjiskipfalse
\keys_define:nn { jlreq } { narrow_kanjiskip .code:n = {\jlreq@narrow@kanjiskiptrue}, narrow_kanjiskip .value_forbidden:n = true}
\__jlreq_aftercls_addtodeleteif:N \ifjlreq@narrow@kanjiskip

%.. 注
% 傍注のタイプ
\keys_define:nn { jlreq } { sidenote_length .tl_set:N = \jlreq@option@sidenote@length }
\__jlreq_aftercls_addtodeletecs:N \jlreq@option@sidenote@length

%.. 逆ノンブル
\newif\ifjlreq@option@use@reverse@pagination
\__jlreq_aftercls_addtodeleteif:N \ifjlreq@option@use@reverse@pagination
\jlreq@option@use@reverse@paginationfalse
\keys_define:nn { jlreq } { use_reverse_pagination .code:n = {\jlreq@option@use@reverse@paginationtrue}, use_reverse_pagination .value_forbidden:n = true }

%.. もろもろ
\newif\if@restonecol\@restonecolfalse
\newif\if@titlepage\@titlepagefalse
\newif\if@landscape\@landscapefalse
\newif\if@tate \@tatefalse
\newif\ifjlreq@option@titlepage \jlreq@option@titlepagefalse % titlepageかnotitlepageかが指定された
\__jlreq_aftercls_addtodeleteif:N \ifjlreq@option@titlepage
\keys_define:nn { jlreq } { landscape .code:n = {\@landscapetrue}, landscape .value_forbidden:n = true }
\keys_define:nn { jlreq } { tombo .code:n = {\ClassWarningNoLine{jlreq}{The~option~`tombo'~is~not~supported~by~jlreq~class.~Please~use~the~jlreq-trimmarks~package}} }
\keys_define:nn { jlreq } { tombow .code:n = {\ClassWarningNoLine{jlreq}{The~option~`tombow'~is~not~supported~by~jlreq~class.~Please~use~the~jlreq-trimmarks~package}} }
\keys_define:nn { jlreq } { mentuke .code:n = {\ClassWarningNoLine{jlreq}{The~option~`mentuke'~is~not~supported~by~jlreq~class.~Please~use~the~jlreq-trimmarks~package}} }
\keys_define:nn { jlreq } { tate .code:n = { \@tatetrue }, tate .value_forbidden:n = true}

\newif\ifjlreq@option@twoside\jlreq@option@twosidefalse % onesideかtwosideが指定された
\__jlreq_aftercls_addtodeleteif:N \ifjlreq@option@twoside
\keys_define:nn { jlreq } { oneside .code:n = { \@twosidefalse\@mparswitchfalse\jlreq@option@twosidetrue }, oneside .value_forbidden:n = true }
\keys_define:nn { jlreq } { twoside .code:n = { \@twosidetrue\@mparswitchtrue\jlreq@option@twosidetrue }, twoside .value_forbidden:n = true }
\keys_define:nn { jlreq } { onecolumn .code:n = { \@twocolumnfalse }, onecolumn .value_forbidden:n = true }
\keys_define:nn { jlreq } { twocolumn .code:n = { \@twocolumntrue }, twocolumn .value_forbidden:n = true }
\keys_define:nn { jlreq } { titlepage .code:n = { \jlreq@option@titlepagetrue\@titlepagetrue }, titlepage .value_forbidden:n = true }
\keys_define:nn { jlreq } { notitlepage .code:n = { \jlreq@option@titlepagetrue\@titlepagefalse }, notitlepage .value_forbidden:n = true }
\keys_define:nn { jlreq } { draft .code:n = { \setlength\overfullrule{5pt} }, draft .value_forbidden:n = true }
\keys_define:nn { jlreq } { final .code:n = { \setlength\overfullrule{0pt} }, final .value_forbidden:n = true }
\newif\if@openright
\newif\ifjlreq@option@open \jlreq@option@openfalse % openrightかopenanyが指定された
\__jlreq_aftercls_addtodeleteif:N \ifjlreq@option@open
\keys_define:nn { jlreq } { openright .code:n = { \@openrighttrue\jlreq@option@opentrue }, openright .value_forbidden:n = true}
\keys_define:nn { jlreq } { openany .code:n = { \@openrightfalse\jlreq@option@opentrue }, openany .value_forbidden:n = true}
\keys_define:nn { jlreq } { leqno .code:n = { \input{leqno.clo } }, leqno .value_forbidden:n = true}
\keys_define:nn { jlreq } { fleqn .code:n = { \input{fleqn.clo } }, fleqn .value_forbidden:n = true}
\newif\ifjlreq@option@enablejfam \jlreq@option@enablejfamtrue
\__jlreq_aftercls_addtodeleteif:N \ifjlreq@option@enablejfam
\keys_define:nn { jlreq } { disablejfam .code:n = { \jlreq@option@enablejfamfalse }, disablejfam .value_forbidden:n = true}

\def\jlreq@note#1{}
\keys_define:nn { jlreq } { jlreq_notes .code:n = { \def\jlreq@note##1{\message{^^JJLReq note: ##1^^J}}}, jlreq_notes .value_forbidden:n = true}

\keys_set:nn { jlreq } {
  article_type=article,paper=a4,
  number_of_lines={},line_length = {},
  head_space={},foot_space={},gutter={},fore_edge={},
  jafontsize={},jafontscale={1},baselineskip={17zw/10},
  sidenote_length=0pt,column_gap={2zw},
  headfoot_verticalposition = {},headfoot_sidemargin={0pt},
  open_bracket_pos=zenkaku_tentsuki,
  onecolumn,final}
\ProcessKeysOptions { jlreq }

\legacy_if:nF { jlreq@option@titlepage } {
  \str_if_eq:VnTF \jlreq@article@type { article } { \@titlepagefalse } { \@titlepagetrue }
}
\legacy_if:nF { jlreq@option@open } {
  \str_if_eq:VnTF \jlreq@article@type { book } { \@openrighttrue } { \@openrightfalse }
}
% articleではopenrightは効かない．
\str_if_eq:VnT \jlreq@article@type { article } {
  \legacy_if:nT { @openright } {
    \ClassWarningNoLine { jlreq } { The~option~`openright'~is~ignored~in~article }
    \@openrightfalse
  }
}
\legacy_if:nF { jlreq@option@twoside } {
  \str_if_eq:VnTF \jlreq@article@type { book } { \@twosidetrue } { \@twosidefalse }
}

\tl_new:N \g__jlreq_jlreqsetup_finally_tl
\NewDocumentCommand{\jlreqsetup} { +m } {
  \keys_set:nn { jlreqsetup } {#1}
  \tl_use:N \g__jlreq_jlreqsetup_finally_tl
}
% \jlreqsetupの最後に必ず実行される処理を入れる．
\cs_set:Nn \__jlreq_jlreqsetup_addtofinally:n { \tl_gput_right:Nx \g__jlreq_jlreqsetup_finally_tl { \exp_not:n {#1} } }
\__jlreq_aftercls_addtodeletecs:N \__jlreq_jlreqsetup_addtofinally:n
\@onlypreamble\jlreqsetup

% エンジンの設定
\ifx\jlreq@engine\@undefined
  \jlreq@helper@guessengine
  \let\jlreq@engine=\jlreq@result
  \message{jlreq~guessed~engine:~
    \ifx l\jlreq@engine lualatex\fi
    \ifx p\jlreq@engine platex\fi
    \ifx u\jlreq@engine uplatex\fi
  }%
\fi

%.. JFMとluatexjaのロード
\ifx l\jlreq@engine
  \def\ltj@stdyokojfm{jlreq}
  \def\ltj@stdtatejfm{jlreqv}
  \directlua{jlreq = {}}
  % この値は後でjfm-jlreq内で読む
  \directlua{jlreq.open_bracket_pos = [[\jlreq@open@bracket@pos]]}
  \ifjlreq@burasage\directlua{jlreq.burasage = true}\else\directlua{jlreq.burasage = false}\fi
  % luatexjaのロード
  \ifjlreq@option@enablejfam
    \RequirePackage{luatexja}
  \else
    \RequirePackage[disablejfam]{luatexja}
  \fi
  \RequirePackage{luatexja-adjust}
  \ltjenableadjust[lineend=extended,priority=true]
  \ltjsetparameter{stretch_priority={kanjiskip=0,xkanjiskip=10}}
  \ltjsetparameter{shrink_priority={kanjiskip=0,xkanjiskip=-30}}
\else
  \RequirePackage{everyhook}
  \def\jlreq@jfmname@prefix{}
  \__jlreq_aftercls_addtodeletecs:N \jlreq@jfmname@prefix
  \ifjlreq@burasage\edef\jlreq@jfmname@prefix{b\jlreq@jfmname@prefix}\fi
  \str_if_eq:VnT \jlreq@open@bracket@pos { zenkakunibu_nibu } {
    \edef\jlreq@jfmname@prefix { \jlreq@jfmname@prefix z }
  }
  \ifx u\jlreq@engine\edef\jlreq@jfmname@prefix{u\jlreq@jfmname@prefix}\fi
  \edef\jlreq@jfmname{\jlreq@jfmname@prefix jlreq} % JFMの名前
  \edef\jlreq@jfmnameg{\jlreq@jfmname@prefix jlreqg} % ゴシックなJFMの名前
  \__jlreq_aftercls_addtodeletecs:N \jlreq@jfmname
  \__jlreq_aftercls_addtodeletecs:N \jlreq@jfmnameg
\fi

% (u)pLaTeXの場合ここで初めて\epTeXinputencodingが発行されるので，
% これ以前には和文は使えない．
\ifx l\jlreq@engine\else
  \epTeXinputencoding utf8
  \def\zw{zw}\def\zh{zh}
  % http://oku.edu.mie-u.ac.jp/tex/mod/forum/discuss.php?d=1508&parent=8435
  \if@tate\AtEndPreamble{\par}\fi
\fi
\let\jlreq@zw=\zw
\let\jlreq@zh=\zh
\if@tate
  \AtBeginDocument{\tate\message{《縦組モード》}\adjustbaseline}
\fi

% \jlreq@gol(Gyo Okuri Length), \jlreq@mol (Moji Okuri Length)を定義
\let\jlreq@gol=\zh
\let\jlreq@mol=\zw

%. helper2（エンジン依存系：和文文字を含むものもこれ以降）
% #1のboxを今の真ん中に配置する．
\def\jlreq@box@putcenter#1{%
  \begingroup
    \jlreq@tempdima=\dimexpr(\ht#1 - \dp#1)/2\relax
    \setbox\jlreq@tempboxa=\hbox{阿}%
    \edef\jlreq@do{%
      \noexpand\lower\the\dimexpr(\jlreq@tempdima - (\ht\jlreq@tempboxa - \dp\jlreq@tempboxa)/2)\relax\unexpanded{\box#1}%
    }%
  \expandafter\endgroup
  \jlreq@do
}

% #1の先頭が文字か
\long\def\jlreq@ifletter#1{%
  \jlreq@iffirsttoken{#1}{ }{\@secondoftwo}{%
    \expandafter\expandafter\expandafter\jlreq@helper@ifletter\jlreq@getfirsttoken#1\jlreq@uniqtoken{}\jlreq@endmark@
  }%
}

\long\def\jlreq@helper@ifletter#1{%
  \jlreq@if{%
    \ifnum
      0%
      \ifcat 阿\noexpand #11\fi
      \ifcat あ\noexpand #11\fi
      \ifcat （\noexpand #11\fi
      \ifcat A\noexpand #11\fi
      \ifcat 1\noexpand #11\fi
    >0~
  \fi}%
}


% 組方向を判定
% \jlreq@if(y|t)(dir|box)を定義する．
\jlreq@if{\ifx l\jlreq@engine\fi}{
  \def\jlreq@ifydir { \int_compare:nTF { \ltjgetparameter{direction} == 4 } }
  \def\jlreq@iftdir { \int_compare:nTF { (\ltjgetparameter{direction}-(\ltjgetparameter{direction}/8)*8) == 3 } }
  \def\jlreq@ifybox#1{ \int_compare:nTF { \ltjgetparameter{boxdir}{#1} == 4 } }
  \def\jlreq@iftbox#1{ \int_compare:nTF { (\ltjgetparameter{boxdir}{#1}-(\ltjgetparameter{boxdir}{#1}/8)*8) == 3 } }
}{
  \def\jlreq@ifydir{\jlreq@if{\ifydir\fi}}
  \def\jlreq@iftdir{\jlreq@if{\iftdir\fi}}
  \def\jlreq@ifybox#1{\jlreq@if{\ifybox#1\fi}}
  \def\jlreq@iftbox#1{\jlreq@if{\iftbox#1\fi}}
}

% 左ページであるか
% #1 : odd or even or ページ数
\def\jlreq@ifleftpage#1{%
  \bool_if:nTF { ( \legacy_if_p:n { @tate }  &&
    \bool_lazy_or_p:nn { \str_if_eq_p:ee {#1} { odd  } }
      { \bool_lazy_and_p:nn { ! \str_if_eq_p:ee {#1} { even } } {   \int_if_odd_p:n {#1} } }
  ) || ( ! \legacy_if_p:n { @tate } &&
    \bool_lazy_or_p:nn { \str_if_eq_p:ee {#1} { even } }
      { \bool_lazy_and_p:nn { ! \str_if_eq_p:ee {#1} { odd  } } { ! \int_if_odd_p:n {#1} } }
  ) }
}

\ifx l\jlreq@engine
  \def\jlreq@getpostbreakpenalty#1{\ltjgetparameter{postbreakpenalty}{#1}}
\else
  \def\jlreq@getpostbreakpenalty#1{\postbreakpenalty#1}
\fi

% 現在行の残りを得る．
\ifx l\jlreq@engine
  % 以下のコードはLuaTeX-jaのバグ？に依存している
  % https://ja.osdn.net/projects/luatex-ja/ticket/36489
  \def\jlreq@calc@current@linewidth@onecolumn{%
    \dimexpr
       \jlreq@reference@ref{jlreq@rest@width.pos.X.\the\jlreq@reference@count}{0} sp - \@totalleftmargin -
      \ifodd\jlreq@currentpage
        \oddsidemargin
      \else
        \evensidemargin
      \fi
      \iftombow -1in \fi
      - \pdfvariable horigin - \hoffset
    \relax
  }
\else
  % トンボ出力時にはjlreq-trimmarksであることを仮定する．
  % 新しいpLaTeXに対しては，jlreq-trimmarksは内部の1inを1trueinに書き換える
  \@ifundefined{@tombowreset@@paper}{
    \def\jlreq@tombow@adjust{\iftombow -1in \fi}
  }{
    \def\jlreq@tombow@adjust{\iftombow -1truein \fi}
  }
  \def\jlreq@calc@current@linewidth@onecolumn{%
    \dimexpr
      \jlreq@ifydir{%
        \jlreq@reference@ref{jlreq@rest@width.pos.X.\the\jlreq@reference@count}{0} sp - \hoffset
        \ifodd\jlreq@currentpage
          - \oddsidemargin
        \else
          - \evensidemargin
        \fi
      }{%
        \ifdim\pdfpagewidth=0pt
          \paperheight
        \else
          \pdfpageheight
        \fi
        - \topmargin - \headheight - \headsep - \voffset
        - \jlreq@reference@ref{jlreq@rest@width.pos.Y.\the\jlreq@reference@count}{0} sp
      }%
      \jlreq@tombow@adjust
      - \@totalleftmargin - 1in
    \relax
  }
\fi
\def\jlreq@calc@current@linewidth{%
  \dimexpr\jlreq@calc@current@linewidth@onecolumn
    \if@twocolumn
      \ifdim\jlreq@calc@current@linewidth@onecolumn<\dimexpr\linewidth+\columnsep\relax\else
        - \linewidth - \columnsep
      \fi
   \fi
 \relax
}

\newdimen\jlreq@current@linewidth
\newdimen\jlreq@rest@linewidth
% この命令以降，次にこの命令を実行する前まで\jlreq@current@linewidth/\jlreq@rest@linewidthで
% この行の行頭からの長さ/残りの長さが取得できる
\jlreq@ifprimitive{\pdfsavepos}{\jlreq@tempatrue}{\jlreq@tempafalse}
\edef\jlreq@savepos@for@rest@linewidth{\unexpanded{%
  \jlreq@setcurrentpage
  \global\advance\jlreq@reference@count by 1
  }%
  \ifjlreq@tempa
    \unexpanded{%
    \pdfsavepos
    \jlreq@reference@label{jlreq@rest@width.pos.X.\the\jlreq@reference@count}{\noexpand\the\noexpand\pdflastxpos}%
    \jlreq@reference@label{jlreq@rest@width.pos.Y.\the\jlreq@reference@count}{\noexpand\the\noexpand\pdflastypos}%
    }%
  \else
    \unexpanded{%
    \savepos
    \jlreq@reference@label{jlreq@rest@width.pos.X.\the\jlreq@reference@count}{\noexpand\the\noexpand\lastxpos}%
    \jlreq@reference@label{jlreq@rest@width.pos.Y.\the\jlreq@reference@count}{\noexpand\the\noexpand\lastypos}%
    }%
  \fi
  \unexpanded{%
  \global\jlreq@current@linewidth=\jlreq@calc@current@linewidth
  \global\jlreq@rest@linewidth=\dimexpr\linewidth - \jlreq@current@linewidth\relax
  \edef\jlreq@savepos@iflabelundefined{\jlreq@reference@ifexist{jlreq@rest@width.pos.X.\the\jlreq@reference@count}{\noexpand\@secondoftwo}{\noexpand\@firstoftwo}}%
  }%
}

\ifx l\jlreq@engine
  \newcommand*{\lastnodechar}{\directlua{luatexja.pltx_composite_last_node_char()}}% undocumentedな機能を使っている
\fi

% #1と#2の間に入るjmglue（(x)kanjiskipも）を\jlreq@resultskipに入れる
\ifx l\jlreq@engine
  \def\jlreq@calc@jfmglue#1#2{%
    \begingroup
      \setbox\jlreq@tempboxa=\hbox{\inhibitglue #1\inhibitglue\hbox{}\inhibitglue#2\inhibitglue}%
      \setbox\jlreq@tempboxb=\hbox{\inhibitglue #1#2\inhibitglue}%
      \edef\jlreq@do{\noexpand\jlreq@resultskip=\the\dimexpr\wd\jlreq@tempboxb - \wd\jlreq@tempboxa\relax\noexpand\relax}%
      \jlreq@do
      \directlua{
        local~width = 0~
        local~stretch = 0~
        local~shrink = 0~
        local~n = tex.box["jlreq@tempboxb"].head~
        while~n~do~
          % すべてのglueの和を計算する．
          if~n.id == node.id("glue")~then~
            width = width + n.width~
            stretch = stretch + n.stretch~
            shrink = shrink + n.shrink~
          end~
          n = n.next~
        end~
        tex.setglue("jlreq@tempskipa",width,stretch,shrink)
      }%
      % TeXで計測した物と一致していなければTeXでの方を信じる
      \ifdim\jlreq@resultskip=\jlreq@tempskipa
        \edef\jlreq@do{\noexpand\jlreq@resultskip=\the\jlreq@tempskipa\relax}%
      \fi
    \expandafter\endgroup
    \jlreq@do
  }
\else
  \def\jlreq@calc@jfmglue#1#2{%
    \begingroup
      \setbox\jlreq@tempboxa=\hbox{\inhibitglue #1\inhibitglue\hbox{}\inhibitglue#2\inhibitglue}%
      \setbox\jlreq@tempboxb=\hbox{\inhibitglue #1#2\inhibitglue}%
      \edef\jlreq@do{\noexpand\jlreq@resultskip=\the\dimexpr\wd\jlreq@tempboxb - \wd\jlreq@tempboxa\relax\noexpand\relax}%
    \expandafter\endgroup
    \jlreq@do
  }
\fi

\newcount\jlreq@lastnodechar
% \jlreq@fixjfm<次の文字>の形で使う．
% jlreq@lastnodecharに入っている値と次のトークン（\futureletで得る）の間に入るJFMグルー等を挿入する
\def\jlreq@fixjfm{%
  \begingroup
    \ifnum\jlreq@lastnodechar>-1
      \def\jlreq@do{\futurelet\jlreq@nextchar\jlreq@insertjfm}%
    \else\def\jlreq@do{}\fi
  \expandafter\endgroup
  \jlreq@do
}
% \jlreq@nextcharと\jlreq@lastnodecharの間のJFMグルーを挿入
\def\jlreq@insertjfm{%
  \ifnum\jlreq@getpostbreakpenalty{\jlreq@lastnodechar}=0\else\penalty\jlreq@getpostbreakpenalty{\jlreq@lastnodechar}\fi
  \begingroup
    \def\jlreq@do{}%
    \jlreq@getfirsttoken@expandmacros{\jlreq@nextchar}{\jlreq@tempa}%
    \expandafter\jlreq@ifletter\expandafter{\jlreq@tempa}{%
      \jlreq@calc@jfmglue{\char\jlreq@lastnodechar}{\jlreq@tempa}%
%      \message{fixjfm,~before~lastnodechar~=~\the\jlreq@lastnodechar,~after~=~\meaning\jlreq@nextchar,~Insert:~\the\jlreq@resultskip}
      \edef\jlreq@do{%
        \noexpand\hskip\the\jlreq@resultskip\space
        \noexpand\inhibitglue
      }%
    }{}%
  \expandafter\endgroup
  \jlreq@do
}

\ifx l\jlreq@engine
  \def\jlreq@divide#1#2{%
    \jlreq@resultdimen=\directlua{tex.print(tostring(\strip@pt\dimexpr #1\relax/\strip@pt\dimexpr #2\relax) .. "pt~")}%
  }
\else
  \let\jlreq@divide=\jlreq@helper@divide
\fi

%. 文字関連設定
% ダミー
\def\@ptsize{0}
%.. (x)kanjiskip
\ifjlreq@narrow@kanjiskip
  \providecommand*{\jlreqkanjiskip}{0pt~plus~.1\jlreq@zw ~minus~.01\jlreq@zw}
\else
  \providecommand*{\jlreqkanjiskip}{0pt~plus~0.25\jlreq@zw ~minus~0pt}
\fi
\providecommand*{\jlreqxkanjiskip}{0.25\jlreq@zw ~plus~0.25\jlreq@zw ~minus~0.125\jlreq@zw}
\jlreq@if{\ifx l\jlreq@engine\fi}{
  \AtBeginDocument{%
    \ltjsetparameter{kanjiskip=\jlreqkanjiskip}%
    \ltjsetparameter{xkanjiskip=\jlreqxkanjiskip}%
  }
}{
  \AtBeginDocument{%
    \kanjiskip=\jlreqkanjiskip
    \xkanjiskip=\jlreqxkanjiskip
  }
}

% フォントサイズを設定
\newdimen\jlreq@fontsize
\newdimen\jlreq@jafontsize
\ifx l\jlreq@engine
  % Q,zw,zhが正しく扱われるようになる．\dimexprつきに展開される．
  \def\jlreq@expand@optionfontsize#1{%
    \dimexpr\directlua{
      local~act = string.char(92)~
      local~s = [[#1]]~
      s = s:gsub("[QH]",act .. "dimexpr 0.25mm" .. act .. "relax")~
      tex.print(s)~
    }\relax
  }%
\else
  \def\jlreq@expand@optionfontsize#1{\dimexpr#1\relax}
\fi
\__jlreq_aftercls_addtodeletecs:N \jlreq@expand@optionfontsize
\ifx\jlreq@option@fontsize\@empty
  \ifx\jlreq@option@jafontsize\@empty
    \jlreq@fontsize=10pt
    \jlreq@jafontsize=\jlreq@option@jafontscale\jlreq@fontsize
  \else
    \setlength{\jlreq@jafontsize}{\jlreq@expand@optionfontsize{\jlreq@option@jafontsize}}
    \jlreq@divide{\jlreq@jafontsize}{\jlreq@option@jafontscale pt}
    \jlreq@fontsize=\jlreq@resultdimen
  \fi
\else
  \setlength{\jlreq@fontsize}{\jlreq@expand@optionfontsize{\jlreq@option@fontsize}}
  \ifx\jlreq@option@jafontsize\@empty
    \jlreq@jafontsize=\jlreq@option@jafontscale\jlreq@fontsize
  \else
    \setlength{\jlreq@jafontsize}{\jlreq@expand@optionfontsize{\jlreq@option@jafontsize}}
  \fi
\fi


% 行頭の括弧は \jlreq@open@bracket@before@space \inhibitglue 「みたいにする．
\str_if_eq:VnTF \jlreq@open@bracket@pos { zenkakunibu_nibu } {
  \def\jlreq@open@bracket@before@space{\hskip\glueexpr-.5\jlreq@zw\relax}
}{
  \def\jlreq@open@bracket@before@space{}
}

\ifx p\jlreq@engine
  \def\jlreq@yokokanjiencoding{JY1}
  \def\jlreq@tatekanjiencoding{JT1}
\fi
\ifx u\jlreq@engine
  \def\jlreq@yokokanjiencoding{JY2}
  \def\jlreq@tatekanjiencoding{JT2}
\fi
\ifx l\jlreq@engine
  \def\jlreq@yokokanjiencoding{JY3}
  \def\jlreq@tatekanjiencoding{JT3}
\fi
\jlreq@divide{\jlreq@jafontsize}{\jlreq@fontsize}
\edef\jlreq@jafontscale{\strip@pt\jlreq@resultdimen}
\__jlreq_aftercls_addtodeletecs:N \jlreq@jafontscale
\ifx l\jlreq@engine
  \jlreq@saveoriginalcs{DeclareFontShape}
    \def\DeclareFontShape#1#2#3#4#5#6{
    \group_begin:
      \bool_if:nT { \str_if_eq_p:nn {#1} {JY3} || \str_if_eq_p:nn {#1} {JT3} } {
        \tl_set:Nx \l_jlreq_tmpa_tl {#5}
        \tl_if_in:NnTF \l_jlreq_tmpa_tl { jfm=jlreq} {
          \tl_if_in:NnTF \l_jlreq_tmpa_tl { jfm=jlreqv }{
            \tl_replace_all:Nnn \l_jlreq_tmpa_tl { jfm=jlreqv } { jfm=jlreqv-jidori }
          }{
            \tl_replace_all:Nnn \l_jlreq_tmpa_tl { jfm=jlreq  } { jfm=jlreq-jidori  }
          }
          \cs_set:Nx \l_jlreq_do: {
            \exp_not:n{ \jlreq@useoriginalcs{DeclareFontShape} {#1} {#2} {#3} { #4-jidori } }
            { \tl_use:N \l_jlreq_tmpa_tl } {#6}
          }
        }{
          \tl_if_in:NnT \l_jlreq_tmpa_tl {<->ssub} {
            \cs_set:Nn \l_jlreq_do: {\jlreq@useoriginalcs{DeclareFontShape} {#1} {#2} {#3} { #4-jidori } {#5} {#6} }
          }
        }
      }
    \exp_after:wN \group_end: \l_jlreq_do:
    \jlreq@useoriginalcs{DeclareFontShape} {#1} {#2} {#3} {#4} {#5} {#6}
  }
  \DeclareFontShape{JY3}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdmcfont :jfm=jlreq;script=latn;-kern}{}
  \DeclareFontShape{JY3}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdgtfont :jfm=jlreq;script=latn;-kern}{}
  \DeclareFontShape{JT3}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdmcfont :jfm=jlreqv;script=latn;-kern}{}
  \DeclareFontShape{JT3}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdgtfont :jfm=jlreqv;script=latn;-kern}{}
\else
  \DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmname}{}
  \DeclareFontShape{\jlreq@yokokanjiencoding}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmnameg}{}
  \DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmname-v}{}
  \DeclareFontShape{\jlreq@tatekanjiencoding}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmnameg-v}{}
  \edef\jlreq@tempa{\ifx u\jlreq@engine u\fi}
  \DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{m}{n-jidori}{<->s*[\jlreq@jafontscale]\jlreq@tempa jlreq-jidori}{}
  \DeclareFontShape{\jlreq@yokokanjiencoding}{gt}{m}{n-jidori}{<->s*[\jlreq@jafontscale]\jlreq@tempa jlreqg-jidori}{}
  \DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{m}{n-jidori}{<->s*[\jlreq@jafontscale]\jlreq@tempa jlreq-v-jidori}{}
  \DeclareFontShape{\jlreq@tatekanjiencoding}{gt}{m}{n-jidori}{<->s*[\jlreq@jafontscale]\jlreq@tempa jlreqg-v-jidori}{}
\fi

\exp_args:Nx \clist_map_inline:nn {\jlreq@yokokanjiencoding,\jlreq@tatekanjiencoding} {% #1 = encoding
  \clist_map_inline:nn { n,it,sl,sc } {% ##1 = shape
    \clist_map_inline:nn { m,b,bx,sb,c } {% ####1 = series
      \bool_if:nF { \str_if_eq_p:nn {##1} {n} && \str_if_eq_p:nn {####1} {m} } {
        \DeclareFontShape{#1}{gt}{####1}{##1}{<->ssub*gt/m/n}{}
      }
    }
    \clist_map_inline:nn { bx,b,sb } {% ####1 = series
      \DeclareFontShape{#1}{mc}{####1}{##1}{<->ssub*gt/m/n}{}
    }
    \clist_map_inline:nn { m,c } {% ####1 = series
      \bool_if:nF { \str_if_eq_p:nn {##1} {n} && \str_if_eq_p:nn {####1} {m} } {
        \DeclareFontShape{#1}{mc}{####1}{##1}{<->ssub*mc/m/n}{}
      }
    }
  }
}

%.. 文字クラスのリスト
% 開き括弧（文字クラス1）
\edef\jlreq@charlist@openingbrackets{（〔［｛〈《「『【‘“\ifx p\jlreq@engine\else ｟〘〖«〝\fi}
% 閉じ括弧（文字クラス2）
\edef\jlreq@charlist@closingbrackets{）〕］｝〉》」』】’”\ifx p\jlreq@engine\else ｠〙〗»〟\fi}
% ハイフン（文字クラス3）
\edef\jlreq@charlist@hyphens{‐〜\ifx p\jlreq@engine\else ゠–\fi}
% 区切り約物（文字クラス4）
\edef\jlreq@charlist@dividingpunctuationmarks{！？\ifx p\jlreq@engine\else ‼⁇⁈⁉\fi}
% 中点類（文字クラス5）
\edef\jlreq@charlist@middlenodes{・：；}
% 句点類（文字クラス6）
\edef\jlreq@charlist@fullstops{。．}
% 読点類（文字クラス7）
\edef\jlreq@charlist@commas{、，}
% 分離禁止文字（文字クラス8）
\edef\jlreq@charlist@inseparablecharacters{—…‥\ifx p\jlreq@engine\else 〳〴〵\fi}
% 繰返し記号（文字クラス9）
\edef\jlreq@charlist@iterationmarks{ヽヾゝゞ々\ifx p\jlreq@engine\else 〻\fi}
% 長音記号（文字クラス10）
\edef\jlreq@charlist@prolongedsoundmark{ー}
% 小書きの仮名（文字クラス11）
\edef\jlreq@charlist@smallkana{ぁぃぅぇぉァィゥェォっゃゅょゎッャュョヮヵヶ\ifx p\jlreq@engine\else ゕゖㇰㇱㇲㇳㇴㇵㇶㇷㇸㇹㇺㇻㇼㇽㇾㇿ\fi}%ㇷ゚
% 前置省略記号（文字クラス12）
\edef\jlreq@charlist@prefixedabbreviations{￥＄￡＃\ifx p\jlreq@engine\else €№\fi}
% 平仮名（文字クラス15）
\edef\jlreq@charlist@hiragana{あいうえおかがきぎくぐけげこごさざしじすずせぜそぞただちぢつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもやゆよらりるれろわゐゑをん\ifx p\jlreq@engine\else ゔ\fi}% か゚き゚く゚け゚こ゚
% 片仮名（文字クラス16）
\edef\jlreq@charlist@katakana{アイウエオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモヤユヨラリルレロワヰヱヲンヴ\ifx p\jlreq@engine\else ヷヸヹヺ\fi}% カ゚キ゚ク゚ケ゚コ゚セ゚ツ゚ト゚

%.. 行頭括弧調整
\jlreq@saveoriginalcs{item}
\ifx l\jlreq@engine
  % \itemの直後は折り返し行頭と同じにする．
  \cs_set:Nn \__jlreq_hook_everypar: {}
  \renewcommand*{\item}{%
    \cs_set:Nn \__jlreq_hook_everypar: { \cs_set:Nn \__jlreq_hook_everypar: {} \inhibitglue }
    \expandafter\everypar\expandafter{\the\everypar\__jlreq_hook_everypar:}
    \jlreq@useoriginalcs{item}%
  }
\else
  \AtBeginDocument{\PushPostHook{par}{\jlreq@hook@everypar}}
  \def\jlreq@hook@everypar{}
  % 非LuaTeXの場合はJFMの入れ替えと\everyparでの処理で対処．
  % 行頭括弧に対して\inhibitglueを入れたりする命令を作る
  % \jlreq@charlist@openingbracketsの各括弧に対して，\ifx\jlreq@nextchar 「1\fiみたいなのが並んだのを作る
  \def\jlreq@tempa{}
  \def\jlreq@do#1{\jlreq@ifendmark{#1}{}{\tl_put_right:Nn \jlreq@tempa{\ifx\jlreq@nextchar#11\fi}\jlreq@do}}
  \expandafter\jlreq@do\jlreq@charlist@openingbrackets\jlreq@endmark
  % JFM glueの伸び縮みで行頭括弧が揃わないのを防ぐために常に\inhibitglueを入れる．
  \str_if_eq:VnTF \jlreq@open@bracket@pos { nibu_tentsuki } {
    \edef\jlreq@openbracket@hook@ii{\noexpand\ifnum0\exp_not:o {\jlreq@tempa}>0~\unexpanded{\hskip -.5\jlreq@zw\inhibitglue}\noexpand\fi}
  }{% zenkakunibu_nibu,zenkaku_tentsuki
    \edef\jlreq@openbracket@hook@ii{\noexpand\ifnum0\exp_not:o {\jlreq@tempa}>0~\unexpanded{\inhibitglue}\noexpand\fi}
  }
  % source special対策
  \def\jlreq@openbracket@hook@i{\ifx\jlreq@nextchar\special\expandafter\jlreq@openbracket@hook@iii\else\expandafter\jlreq@openbracket@hook@ii\fi}
  \def\jlreq@openbracket@hook@iii#1#2{#1{#2}\futurelet\jlreq@nextchar\jlreq@openbracket@hook@i}
  \def\jlreq@openbracket@hook{\futurelet\jlreq@nextchar\jlreq@openbracket@hook@i}
  \let\jlreq@hook@everypar=\jlreq@openbracket@hook
  \renewcommand*{\item}{%
    \def\jlreq@hook@everypar{%
      \let\jlreq@hook@everypar=\jlreq@openbracket@hook
      \inhibitglue
    }%
    \jlreq@useoriginalcs{item}%
  }
\fi

%.. 禁則処理
\ifx l\jlreq@engine
  \cs_set:Nn \__jlreq_setpostbreakpenalty_aux:nn {\ltjsetparameter{postbreakpenalty={`#1,#2}}}
  \cs_set:Nn \__jlreq_setprebreakpenalty_aux:nn {\ltjsetparameter{prebreakpenalty={`#1,#2}}}
  \cs_set:Nn \__jlreq_addjaxspmode_aux:nn {%
    \jlreq@tempcnta=\ltjgetparameter{jaxspmode}{`#1}%
    \str_case:nn {#2} {
      { pre } {%
        \ifnum\jlreq@tempcnta=2
          \ltjsetparameter{jaxspmode={`#1,allow}}%
        \else\ifnum\jlreq@tempcnta=0
          \ltjsetparameter{jaxspmode={`#1,preonly}}%
        \fi\fi
      }
      { post } {%
        \ifnum\jlreq@tempcnta=1
          \ltjsetparameter{jaxspmode={`#1,allow}}%
        \else\ifnum\jlreq@tempcnta=0
          \ltjsetparameter{jaxspmode={`#1,postonly}}%
        \fi\fi
      }
    }%
  }
  \cs_set:Nn \__jlreq_deljaxspmode_aux:nn {
    \jlreq@tempcnta=\ltjgetparameter{jaxspmode}{`#1}%
    \str_case:nn {#2} {
      { pre } {%
        \ifnum\jlreq@tempcnta=2
          \ltjsetparameter{jaxspmode={`#1,postonly}}%
        \else\ifnum\jlreq@tempcnta=1
          \ltjsetparameter{jaxspmode={`#1,inhibit}}%
        \fi\fi
      }
      { post } {%
        \ifnum\jlreq@tempcnta=3
          \ltjsetparameter{jaxspmode={`#1,preonly}}%
        \else\ifnum\jlreq@tempcnta=2
          \ltjsetparameter{jaxspmode={`#1,inhibit}}%
        \fi\fi
      }
    }%
  }
\else
  \cs_set:Nn \__jlreq_setpostbreakpenalty_aux:nn {\postbreakpenalty`#1=#2}
  \cs_set:Nn \__jlreq_setprebreakpenalty_aux:nn {\prebreakpenalty`#1=#2}
  \cs_set:Nn \__jlreq_addjaxspmode_aux:nn {
    \jlreq@tempcnta=\inhibitxspcode`#1
    \str_case:nn {#2} {
      { pre }{%
        \ifnum\jlreq@tempcnta=1
          \inhibitxspcode`#1=3
        \else\ifnum\jlreq@tempcnta=0
          \inhibitxspcode`#1=2
        \fi\fi
      }
      { post }{%
        \ifnum\jlreq@tempcnta=2
          \inhibitxspcode`#1=3
        \else\ifnum\jlreq@tempcnta=0
          \inhibitxspcode`#1=1
        \fi\fi
      }
    }%
  }
  \cs_set:Nn \__jlreq_deljaxspmode_aux:nn {
    \jlreq@tempcnta=\inhibitxspcode`#1
    \str_case;nn {#2} {
      { pre } {%
        \ifnum\jlreq@tempcnta=3
          \inhibitxspcode`#1=1
        \else\ifnum\jlreq@tempcnta=2
          \inhibitxspcode`#1=0
        \fi\fi
      }
      { post } {%
        \ifnum\jlreq@tempcnta=3
          \inhibitxspcode`#1=2
        \else\ifnum\jlreq@tempcnta=1
          \inhibitxspcode`#1=0
        \fi\fi
      }
    }%
  }
\fi
% #1{...}{#3}を...が#2のリストに対して適用．
\cs_set:Nn \__jlreq_iterateapply:Nnn {
  \tl_map_inline:nn {#2} {
    #1{##1}{#3}
  }
}
\cs_set:Nn \__jlreq_setpostbreakpenalty:nn { \__jlreq_iterateapply:Nnn \__jlreq_setpostbreakpenalty_aux:nn {#1} {#2}}
\cs_generate_variant:Nn \__jlreq_setpostbreakpenalty:nn { Vn }
\cs_set:Nn \__jlreq_setprebreakpenalty:nn { \__jlreq_iterateapply:Nnn \__jlreq_setprebreakpenalty_aux:nn {#1} {#2} }
\cs_generate_variant:Nn \__jlreq_setprebreakpenalty:nn { Vn }
\cs_set:Nn \__jlreq_addjaxspmode:nn {\__jlreq_iterateapply:Nnn \__jlreq_addjaxspmode_aux:nn {#1} {#2} }
\cs_generate_variant:Nn \__jlreq_addjaxspmode:nn { Vn }
\cs_set:Nn \__jlreq_deljaxspmode:nn { \__jlreq_iterateapply:Nnn \__jlreq_deljaxspmode_aux:nn {#1} {#2} }
\cs_generate_variant:Nn \__jlreq_deljaxspmode:nn { Vn }

\__jlreq_aftercls_addtodeletecs:N \__jlreq_iterateapply:Nnn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_setpostbreakpenalty:nn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_setpostbreakpenalty:Vn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_setpostbreakpenalty_aux:nn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_setprebreakpenalty:nn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_setprebreakpenalty:Vn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_setprebreakpenalty_aux:nn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_addjaxspmode:nn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_addjaxspmode:Vn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_addjaxspmode_aux:nn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_deljaxspmode:nn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_deljaxspmode:Vn
\__jlreq_aftercls_addtodeletecs:N \__jlreq_deljaxspmode_aux:nn

% 行末禁則
\__jlreq_setpostbreakpenalty:Vn \jlreq@charlist@openingbrackets {10000}
\__jlreq_setpostbreakpenalty:Vn \jlreq@charlist@prefixedabbreviations {10000}

% 行頭禁則
\__jlreq_setprebreakpenalty:Vn \jlreq@charlist@closingbrackets {10000}
\__jlreq_setprebreakpenalty:Vn \jlreq@charlist@hyphens {10000}
\__jlreq_setprebreakpenalty:Vn \jlreq@charlist@dividingpunctuationmarks {10000}
\__jlreq_setprebreakpenalty:Vn \jlreq@charlist@middlenodes {10000}
\__jlreq_setprebreakpenalty:Vn \jlreq@charlist@fullstops {10000}
\__jlreq_setprebreakpenalty:Vn \jlreq@charlist@commas {10000}
\__jlreq_setprebreakpenalty:Vn \jlreq@charlist@iterationmarks {10000}
\__jlreq_setprebreakpenalty:Vn \jlreq@charlist@prolongedsoundmark {10000}
\__jlreq_setprebreakpenalty:Vn \jlreq@charlist@smallkana {10000}

% xkanjiskip
\__jlreq_addjaxspmode:Vn \jlreq@charlist@iterationmarks {pre}
\__jlreq_addjaxspmode:Vn \jlreq@charlist@iterationmarks {post}
\__jlreq_addjaxspmode:Vn \jlreq@charlist@prolongedsoundmark {pre}
\__jlreq_addjaxspmode:Vn \jlreq@charlist@prolongedsoundmark {post}
\__jlreq_addjaxspmode:Vn \jlreq@charlist@smallkana {pre}
\__jlreq_addjaxspmode:Vn \jlreq@charlist@smallkana {post}
\__jlreq_addjaxspmode:Vn \jlreq@charlist@hiragana {pre}
\__jlreq_addjaxspmode:Vn \jlreq@charlist@hiragana {post}
\__jlreq_addjaxspmode:Vn \jlreq@charlist@katakana {pre}
\__jlreq_addjaxspmode:Vn \jlreq@charlist@katakana {post}
\__jlreq_addjaxspmode:Vn \jlreq@charlist@dividingpunctuationmarks {post}

% 分割禁止（分離禁止文字は特定の並びで分割禁止だが，とりあえず一括で禁止しておく．）
\__jlreq_setprebreakpenalty:Vn \jlreq@charlist@inseparablecharacters {10000}
% ￥100とか70％とか……

%.. 文字範囲
\ifx u\jlreq@engine
  % \kcatcodeの設定
  \cs_set:Nn \__jlreq_setkcatcode:nn {
    \clist_map_inline:nn {#1} { \kcatcode"##1=#2\relax }
  }
  \__jlreq_aftercls_addtodeletecs:N \__jlreq_setkcatcode:nn
  % LuaTeX-jaのデフォルトのままに近い設定をする
  % 範囲1＆8
  \__jlreq_setkcatcode:nn {80} {15} % Latin-1 Supplement，どうしよう……
  \__jlreq_setkcatcode:nn {100,180,250,2B0,300,1E00} {15}
  % 範囲2
  \__jlreq_setkcatcode:nn {370,400,1F00} {18}
  % 範囲3
  \__jlreq_setkcatcode:nn {2000,2070,20A0,20D0,2100,2150,2190,2200,2300,2400,2500,2580,25A0,2600,2700,2900,2980,2B00} {18}
  % 範囲4
  \__jlreq_setkcatcode:nn {500,530,590,600,700,750,780,7C0,800,840,8A0,900,980,A00,A80,B00,B80,C00,C80,D00,D80,E00,E80,F00,1000,10A0,1200,1380,13A0,1400,1680,16A0,1700,1720,1740,1760,1780,1800,18B0,1900,1950,1980,19E0,1A00,1A20,1AB0,1B00,1B80,1BC0,1C00,1C50,1C80,1CC0,1CD0,1D00,1D80,1DC0,2400,2440,27C0,27F0,2800,2A00,2C00,4DC0,A4D0,A500,A640,A6A0,A700,A720,A800,A840,A880,A8E0,A900,A930,A960,A980,A9E0,AA00,AA60,AA80,AAE0,AB00,AB30,AB70,ABC0,FB00,FB50,FE00,FE20,FE70,10000,10080,10100,10140,10190,101D0,10280,102A0,102E0,10300,10330,10350,10380,103A0,10400,10450,10480,104B0,10500,10530,10600,10800,10840,10860,10880,108E0,10900,10920,10980,109A0,10A00,10A60,10A80,10AC0,10B00,10B40,10B60,10B80,10C00,10C80,10E60,11000,11080,110D0,11100,11150,11180,111E0,11200,11280,112B0,11300,11400,11480,11580,11600,11660,11680,11700,118A0,11AC0,11C00,11C70,12000,12400,12480,13000,14400,16800,16A40,16AD0,16B00,16F00,16FE0,17000,18800,1B000,1BC00,1BCA0,1D000,1D100,1D200,1D300,1D360,1D400,1D800,1E000,1E800,1E900,1EE00,1F000,1F030,1F0A0,1F100,1F200,1F300,1F600,1F650,1F680,1F700,1F780,1F800,1F900,E000} {15}
  % 範囲5（Variation Selectors SupplementはLuaTeX-jaではE01F0--E01EFまで範囲5，他は範囲6）
  \__jlreq_setkcatcode:nn {D800,DB80,DC00,E0000,F0000,100000} {15}
  % 範囲6
  \__jlreq_setkcatcode:nn {3040,30A0,31F0} {17} % Hiragana,Katakana,Katakana Phonetic Extensions
  \__jlreq_setkcatcode:nn {2460,3000,3200,3300,FE10,FE30,FE50,E0100} {18} % Enclosed Alphanumerics,CJK Symbols and Punctuation,Enclosed CJK Letters and Months,CJK Compatibility,Vertical Forms,CJK Compatibility Forms,Small Form Variants,Variation Selectors Supplement
  \__jlreq_setkcatcode:nn {2E80,3190,3400,4E00,F900,20000} {16}
  % 範囲7
  \__jlreq_setkcatcode:nn {A000,A490} {18} % Yi Syllables,Yi Radicals
  \__jlreq_setkcatcode:nn {1100,3130,AC00,D7B0} {19} % Hangul Jamo,Hangul Compatibility Jamo,Hangul Syllables,Hangul Jamo Extended-B
  \__jlreq_setkcatcode:nn {2F00,2FF0,3100,31A0,31C0,A830} {16}
\fi

%.. フォント
\RequirePackage{lmodern}

%.. 古いフォントコマンド
\DeclareOldFontCommand{\jlreq@oldfontcommand@mc}{\normalfont\mcfamily}{\mathmc}
\DeclareOldFontCommand{\jlreq@oldfontcommand@gt}{\normalfont\gtfamily}{\mathgt}
\DeclareOldFontCommand{\jlreq@oldfontcommand@rm}{\normalfont\rmfamily}{\mathrm}
\DeclareOldFontCommand{\jlreq@oldfontcommand@sf}{\normalfont\sffamily}{\mathsf}
\DeclareOldFontCommand{\jlreq@oldfontcommand@tt}{\normalfont\ttfamily}{\mathtt}
\DeclareOldFontCommand{\jlreq@oldfontcommand@bf}{\normalfont\bfseries}{\mathbf}
\DeclareOldFontCommand{\jlreq@oldfontcommand@it}{\normalfont\itshape}{\mathit}
\DeclareOldFontCommand{\jlreq@oldfontcommand@sl}{\normalfont\slshape}{\@nomath\sl}
\DeclareOldFontCommand{\jlreq@oldfontcommand@sc}{\normalfont\scshape}{\@nomath\sc}
\def\jlreq@oldfontcommand@enable{%
  \let\mc=\jlreq@oldfontcommand@mc
  \let\gt=\jlreq@oldfontcommand@gt
  \let\rm=\jlreq@oldfontcommand@rm
  \let\sf=\jlreq@oldfontcommand@sf
  \let\tt=\jlreq@oldfontcommand@tt
  \let\bf=\jlreq@oldfontcommand@bf
  \let\it=\jlreq@oldfontcommand@it
  \let\sl=\jlreq@oldfontcommand@sl
  \let\sc=\jlreq@oldfontcommand@sc
}
\def\jlreq@oldfontcommand@disable{%
  \let\mc=\@undefined
  \let\gt=\@undefined
  \let\rm=\@undefined
  \let\sf=\@undefined
  \let\tt=\@undefined
  \let\bf=\@undefined
  \let\it=\@undefined
  \let\sl=\@undefined
  \let\sc=\@undefined
}

\DeclareRobustCommand*{\cal}{\@fontswitch\relax\mathcal}
\DeclareRobustCommand*{\mit}{\@fontswitch\relax\mathnormal}

% 和文ファミリと欧文ファミリの連動
\AddToHook{rmfamily}{\prepare@family@series@update@kanji{mc}\mcdefault}
\AddToHook{sffamily}{\prepare@family@series@update@kanji{gt}\gtdefault}
\AddToHook{ttfamily}{\prepare@family@series@update@kanji{gt}\gtdefault}

% 数式フォント設定
\ifjlreq@option@enablejfam
  \ifx l\jlreq@engine\else
    \DeclareSymbolFont{mincho}{\jlreq@yokokanjiencoding}{mc}{m}{n}
    \DeclareSymbolFontAlphabet{\mathmc}{mincho}
    \SetSymbolFont{mincho}{bold}{\jlreq@yokokanjiencoding}{gt}{m}{n}
    \jfam\symmincho
    \DeclareMathAlphabet{\mathgt}{\jlreq@yokokanjiencoding}{gt}{m}{n}
  \fi
  \AtBeginDocument{%
    \reDeclareMathAlphabet{\mathrm}{\mathrm}{\mathmc}%
    \reDeclareMathAlphabet{\mathbf}{\mathbf}{\mathgt}%
  }
\fi

% 和文間隔
\DeclareRobustCommand*\　{\futurelet\jlreq@nextchar\jlreq@zenkakuspace@ignorespaces}
% 後続の空白を無視する処理
\edef\jlreq@zenkakuspace@ignorespaces{%
  \noexpand\ifx\exp_not:o {\space}\unexpanded{\jlreq@nextchar\expandafter\jlreq@zenkakuspace@ignorespaces@\else\expandafter\jlreq@zenkakuspace@main\fi}%
}
\expandafter\def\expandafter\jlreq@zenkakuspace@ignorespaces@\space{\　}
\def\jlreq@tempa{}
\def\jlreq@do#1{\jlreq@ifendmark{#1}{}{\tl_put_right:Nn \jlreq@tempa{\ifnum\lastnodechar=`#1~1\fi}\jlreq@do}}
\expandafter\jlreq@do\jlreq@charlist@dividingpunctuationmarks\jlreq@endmark
\edef\@tempa{\noexpand\ifnum0\exp_not:o {\jlreq@tempa}>0~}
\expandafter\DeclareRobustCommand\expandafter*\expandafter\jlreq@zenkakuspace@main\expandafter{\@tempa
    \hskip 1\jlreq@zw\hbox{}%
    \jlreq@lastnodechar=`　
    \expandafter\jlreq@fixjfm
  \else\expandafter　\fi
}
\ifx l\jlreq@engine
  {
    \catcode`　=\active
    \global\let　=\jlreq@zenkakuspace@main
  }
  \AtBeginDocument{\catcode`　=\active}
\fi

% \jaspace
\NewDocumentCommand{\jaspace}{ m } {
  \ifcsname jlreq@jaspace@#1\endcsname\csname jlreq@jaspace@#1\endcsname
  \else\ClassError{jlreq}{unknown~jaspace:~#1}{\@ehc}\fi
}
\def\jlreq@jaspace@zenkaku{\hskip\glueexpr 1\jlreq@zw\relax}
\def\jlreq@jaspace@nibu{\hskip\glueexpr .5\jlreq@zw\relax}
\def\jlreq@jaspace@shibu{\hskip\glueexpr .25\jlreq@zw\relax}

% 区切り約物．\？ みたいな命令を作る．直後の空きが自動で入る．
% \？*とすると文中の？として扱われる．
\def\jlreq@tempa{}
\def\jlreq@do#1{\jlreq@ifendmark{#1}{}{\tl_put_right:Nn \jlreq@tempa{\ifx\jlreq@nextchar #11\fi}\jlreq@do}}
\expandafter\jlreq@do\jlreq@charlist@closingbrackets\jlreq@endmark
\edef\jlreq@dividingpunctuationmarkscommand{%
  \noexpand\ifnum 0\exp_not:o {\jlreq@tempa}>0~\unexpanded{\expandafter\ignorespaces\else\expandafter\　\fi}%
}
\def\jlreq@do#1{%
  \jlreq@ifendmark{#1}{}{
    \expandafter\DeclareRobustCommand\expandafter*\csname #1\endcsname{%
      \jlreq@ifstar
        {\hskip .25\jlreq@zw #1\hskip .25\jlreq@zw\ignorespaces}%
        {#1\futurelet\jlreq@nextchar\jlreq@dividingpunctuationmarkscommand}%
    }
    \jlreq@do
  }
}
\expandafter\jlreq@do\jlreq@charlist@dividingpunctuationmarks\jlreq@endmark


%.. 文字サイズ変更命令の定義
% \baselineskipの計算
% いったん文字サイズを変更（(u)platexの際にzh/zwをきちんとするため）
\@setfontsize\normalsize{\jlreq@fontsize}{\jlreq@fontsize}%
\newdimen\jlreq@baselineskip
\ifx l\jlreq@engine
  \setlength{\jlreq@baselineskip}{%
    \dimexpr\directlua{
      local~act = string.char(92)~
      local~s = [[\jlreq@option@baselineskip]]~
      s = s:gsub("[QH]",act .. "dimexpr 0.25mm" .. act .. "relax"):gsub("zh",act .. "zh"):gsub("zw",act .. "zw")~
      tex.print(s)~
    }\relax
  }%
\else
  \setlength{\jlreq@baselineskip}{\dimexpr\jlreq@option@baselineskip\relax}
\fi
\ifdim\jlreq@fontsize>\jlreq@baselineskip
  \ClassError{jlreq}{The~baselineskip~is~less~than~fontsize}{\@ehc}%
\fi
\bool_if:nT { \dim_compare_p:n { \jlreq@baselineskip < 1.5\zw } || \dim_compare_p:n { \jlreq@baselineskip > 2\zw } } {
  \jlreq@note { 行間は二分以上全角以下が望ましい (2.4.2.d~注3)．}
}

\emergencystretch 3\jlreq@gol
\setlength{\parindent}{1\zw}
\hook_gput_code:nnn { cmd/set@fontsize/after } {.} {
  \expandafter\def\expandafter\size@update\expandafter{\size@update\g__jlreq_setfontsizehook}
}
\tl_new:N \g__jlreq_setfontsizehook
\tl_set:Nn \g__jlreq_setfontsizehook { \dim_compare:nT { \parindent>0pt } { \setlength{\parindent}{1\jlreq@zw} } }
\ifx l\jlreq@engine
  \@tempskipa=\ltjgetparameter{kanjiskip}
  \ifdim\@tempskipa=\maxdimen\else
    \tl_put_right:Nn \g__jlreq_setfontsizehook {%
      \ltj@setpar@global
      \ltjsetkanjiskip\jlreqkanjiskip
      \@tempskipa=\ltjgetparameter{xkanjiskip}%
      \ifdim\@tempskipa>0pt
        \ltjsetxkanjiskip\jlreqxkanjiskip
      \fi
    }
  \fi
\else
  \tl_put_right:Nn \g__jlreq_setfontsizehook {%
    \kanjiskip=\jlreqkanjiskip
    \ifdim\xkanjiskip>0pt
      \xkanjiskip=\jlreqxkanjiskip
    \fi
  }
\fi

% \jafontsize
\ifdim\jlreq@fontsize=\jlreq@jafontsize
  \let\jafontsize=\fontsize
\else
  \def\@tempa#1{
    \NewDocumentCommand{\jafontsize}{ m m }{%
      \begingroup
        \jlreq@iffloat{##1}{%
          \edef\jlreq@do{\noexpand\fontsize{\strip@pt\dimexpr#1\dimexpr##1pt\relax\relax}}%
        }{%
          \edef\jlreq@do{\noexpand\fontsize{\the\dimexpr#1\dimexpr##1\relax\relax}}%
        }%
      \expandafter\endgroup
      \jlreq@do{##2}%
    }
  }
  \jlreq@divide{\jlreq@fontsize}{\jlreq@jafontsize}
  \edef\jlreq@do{\noexpand\@tempa{\strip@pt\jlreq@resultdimen}}
  \jlreq@do
\fi

\renewcommand{\normalsize}{%
  \@setfontsize\normalsize{\jlreq@fontsize}{\jlreq@baselineskip}%
  \abovedisplayskip 1.1\jlreq@fontsize \@plus .3\jlreq@fontsize \@minus .4\jlreq@fontsize
  \abovedisplayshortskip \z@ \@plus .3\jlreq@fontsize
  \belowdisplayskip .9\jlreq@fontsize \@plus.3\jlreq@fontsize \@minus.4\jlreq@fontsize
  \belowdisplayshortskip \belowdisplayskip
  \let\@listi\@listI}

\if@tate\tate\fi % ここで発行しておく
\mcfamily\selectfont\normalsize
\setbox\jlreq@tempboxa\hbox{阿}
\setlength\Cht{\ht\jlreq@tempboxa}
\setlength\Cdp{\dp\jlreq@tempboxa}
\setlength\Cwd{\wd\jlreq@tempboxa}
\setlength\Cvs{\baselineskip}
\setlength\Chs{\wd\jlreq@tempboxa}

% 4.1.3.a
% 2.5.2 \baselineskipは一定の方がよい？
% \@listiは再定義しないようにした．（\normalsizeと共用でJLReq通りだと思う．）
\newcommand{\footnotesize}{%
  \@setfontsize\footnotesize{.8\jlreq@fontsize}{\dimexpr 115\jlreq@baselineskip/170\relax}% 脚注文字サイズの二分より少し小さい値を行間に: 4.2.5.e
  \abovedisplayskip .6\jlreq@fontsize \@plus.2\jlreq@fontsize \@minus.4\jlreq@fontsize
  \abovedisplayshortskip \z@ \@plus.1\jlreq@fontsize
  \belowdisplayshortskip .3\jlreq@fontsize \@plus.1\jlreq@fontsize \@minus.2\jlreq@fontsize
  \belowdisplayskip \abovedisplayskip}
% tsize10.cloの引数を，そのまま\jlreq@fontsize/\jlreq@baselineskipでスケーリングしているだけ．
\newcommand{\small}{%
  % jsarticleのもの
  \@setfontsize\small{.9\jlreq@fontsize}{\dimexpr 13\jlreq@baselineskip/17\relax}%
  \abovedisplayskip .9\jlreq@fontsize \@plus.3\jlreq@fontsize \@minus.4\jlreq@fontsize
  \abovedisplayshortskip \z@ \@plus.3\jlreq@fontsize
  \belowdisplayshortskip \abovedisplayshortskip
  \belowdisplayskip \abovedisplayskip}
\newcommand{\scriptsize}{\@setfontsize\scriptsize{\dimexpr 7\jlreq@fontsize/10\relax}{\dimexpr 8\jlreq@baselineskip/17\relax}}
\newcommand{\tiny}{\@setfontsize\tiny{\dimexpr 5\jlreq@fontsize/10\relax}{\dimexpr 6\jlreq@baselineskip/17\relax}}
\newcommand{\large}{\@setfontsize\large{\dimexpr12\jlreq@fontsize/10\relax}{\jlreq@baselineskip}}
\newcommand{\Large}{\@setfontsize\Large{\dimexpr14\jlreq@fontsize/10\relax}{\dimexpr 21\jlreq@baselineskip/17\relax}}
\newcommand{\LARGE}{\@setfontsize\LARGE{\dimexpr17\jlreq@fontsize/10\relax}{\dimexpr 25\jlreq@baselineskip/17\relax}}
\newcommand{\huge}{\@setfontsize\huge{2\jlreq@fontsize}{\dimexpr 28\jlreq@baselineskip/17\relax}}
\newcommand{\Huge}{\@setfontsize\Huge{\dimexpr 25\jlreq@fontsize/10\relax}{\dimexpr 33\jlreq@baselineskip/17\relax}}

%. plextから拝借
\def\jlreq@Kanji#1{\expandafter\kansuji\csname c@#1\endcsname}

% このあたりはtarticleと同じ
\setlength\lineskip{.1\zh}
\setlength\normallineskip{.1\zh}
\renewcommand{\baselinestretch}{}
% 行間の伸びは許容しない．
\setlength{\parskip}{0pt}
% https://github.com/texjporg/jsclasses/issues/14
\renewcommand*{\flushbottom}{%
  \def\@textbottom{\vskip 0pt~plus~0.1pt}%
  \let\@texttop\relax
}
\@lowpenalty   51
\@medpenalty  151
\@highpenalty 301

% 変数定義（他にも散らばっているけど）
% 罫線の太さ（4.4.3.c 注1）
\newdimen\jlreq@omotekeiwidth
\jlreq@omotekeiwidth=0.12mm
\newdimen\jlreq@chuubusokeiwidth
\jlreq@chuubusokeiwidth=0.25mm
\newdimen\jlreq@urakeiwidth
\jlreq@urakeiwidth=0.4mm
% 脚注のインデント
\newdimen\jlreq@footnoteindent

%\RequirePackage{jlreq-debug}

%. ページレイアウト
% landscapeの場合縦横をひっくり返す
\if@landscape
  \jlreq@helper@swap@register{\paperwidth}{\paperheight}
\fi

% \pdfpagewidthとか設定
\ifx l\jlreq@engine
  \setlength{\pagewidth}{\paperwidth}
  \setlength{\pageheight}{\paperheight}
\else
  \setlength{\pdfpagewidth}{\paperwidth}
  \setlength{\pdfpageheight}{\paperheight}
\fi

\ifx l\jlreq@engine
  \def\jlreq@expand@speciallength#1{%
    % zhやzwを\zhや\zwにする．
    \directlua{
      local~act = string.char(92)~
      local~s = [[#1]]~
      s = s:gsub("zw",act .. "zw"):gsub("zh",act .. "zh")~
      tex.print(s)~
    }%
  }
\else
  \def\jlreq@expand@speciallength#1{#1}
\fi
\def\jlreq@speciallength#1{\dimexpr\jlreq@expand@speciallength{#1}\relax}

%.. 二段組み用パラメータ
\setlength{\columnsep}{\jlreq@speciallength{\jlreq@option@column@gap}}
\setlength{\columnseprule}{0pt}

%.. 傍注（4.2.7）
\newdimen\jlreq@sidenote@length
\newdimen\jlreq@sidenote@sep
\begingroup
  \footnotesize
  \setlength{\jlreq@tempdima}{\jlreq@speciallength{\jlreq@option@sidenote@length}}
  \jlreq@tempdimb=1\zw
  \divide\jlreq@tempdima\jlreq@tempdimb
  \multiply\jlreq@tempdima\jlreq@tempdimb
  \ifdim\jlreq@tempdima>0pt
    \ifnum 0\ifdim\jlreq@tempdima>25\zw 1\fi\ifdim\jlreq@tempdima<15\zw 1\fi>0
      \jlreq@note{並列注の字詰め方向の長さ（行長）は，15字から20字くらいである．ケースによっては25字程度にする場合もある (4.2.7)．}
    \fi
  \fi
  \edef\jlreq@do{
    \noexpand\setlength{\noexpand\jlreq@sidenote@length}{\the\jlreq@tempdima}
    \noexpand\setlength{\noexpand\marginparpush}{\the\dimexpr 0.5\zw\relax} % 同上：4.2.7.g
  }
  \expandafter\endgroup
\jlreq@do
\ifdim\jlreq@sidenote@length>0pt
  \setlength{\marginparwidth}{\jlreq@sidenote@length}
  \setlength{\marginparsep}{2\zw} % フォントサイズ×2（4.2.7：特に問題に～e）
  \setlength{\jlreq@sidenote@sep}{2\zw}
\else
  \setlength{\marginparwidth}{0pt}
  \setlength{\marginparsep}{0pt}
  \setlength{\jlreq@sidenote@sep}{0pt}
\fi

% 縦書きの時は脚注に固定
% (TODO: 頭注）
\@mparswitchfalse
\if@tate\else\if@twoside\@mparswitchtrue\fi\fi


\setlength{\topskip}{1\zw} % フォントサイズと一致させる
\ifx\jlreq@option@headfoot@verticalpos\@empty
  \if@tate\def\jlreq@option@headfoot@verticalpos{1zw}
  \else\def\jlreq@option@headfoot@verticalpos{2zw}\fi
\fi
\setlength{\headsep}{\jlreq@speciallength{\jlreq@option@headfoot@verticalpos}}
\if@tate\ifdim\headsep<1\zw\relax\jlreq@note{基本版面との上下方向の最低の空き量を，基本版面の文字サイズの全角アキとする (26.1.a)．}\fi\fi
\if@tate
  \if@twocolumn
    \addtolength{\headsep}{\dimexpr\marginparwidth + \marginparsep\relax}
  \fi
\else
  \addtolength{\headsep}{-\dimexpr\topskip - \Cht\relax}
\fi
\setlength{\headheight}{1\zw}

% \textwidthと\textheightのデフォルト値は縦横ともに0.75倍（調整が入る）．
%.. \textwidth：文字送り方向の行長
% 二段の場合は最初の段の頭から次の段の後まで
% 一度\textwidthに一行の長さの文字数を入れる（段組の場合でも）
\newif\ifjlreq@determine@kihonhanmen@warning@first
\jlreq@determine@kihonhanmen@warning@firsttrue
\def\jlreq@determine@kihonhanmen@warning{
  \ifjlreq@determine@kihonhanmen@warning@first
    \jlreq@note{基本版面は，a. サイズの決定 b. 仕上りサイズに対する基本版面の配置位置の決定 という手順で行う (2.4.1)．}
    \jlreq@determine@kihonhanmen@warning@firstfalse
  \fi
}
\__jlreq_aftercls_addtodeletecs:N \jlreq@determine@kihonhanmen@warning
\__jlreq_aftercls_addtodeleteif:N \ifjlreq@determine@kihonhanmen@warning@first
\@tempdima=1\zw
\ifx\jlreq@option@line@length\@empty
  \if@tate
    \ifnum 0\ifx\jlreq@option@head@space\@empty 1\fi\ifx\jlreq@option@foot@space\@empty 1\fi>0
      \setlength{\textwidth}{0.75\paperheight}
      \divide\textwidth\@tempdima\multiply\textwidth\@tempdima
    \else
      \jlreq@determine@kihonhanmen@warning
      \setlength{\textwidth}{\dimexpr\paperheight - \jlreq@option@head@space - \jlreq@option@foot@space \relax}
    \fi
  \else
    \ifnum 0\ifx\jlreq@option@gutter\@empty 1\fi\ifx\jlreq@option@fore@edge\@empty 1\fi>0
      \setlength{\textwidth}{0.75\paperwidth}
      \divide\textwidth\@tempdima\multiply\textwidth\@tempdima
    \else
      \jlreq@determine@kihonhanmen@warning
      \setlength{\textwidth}{\dimexpr\paperwidth - \jlreq@option@gutter - \jlreq@option@fore@edge\relax}
    \fi
  \fi
  \if@twocolumn
    \addtolength{\textwidth}{\dimexpr-2\marginparwidth - 2\marginparsep\relax}
    \setlength{\textwidth}{\dimexpr(\textwidth - \columnsep)/2\relax}
  \else
    \addtolength{\textwidth}{\dimexpr-\marginparwidth - \marginparsep\relax}
  \fi
\else
  \setlength{\textwidth}{\jlreq@speciallength{\jlreq@option@line@length}}
  \divide\textwidth\@tempdima
  \if@tate
    \ifnum\number\textwidth>52
      \jlreq@note{一行の長さは52文字以下が望ましい (2.4.2.c 注2)．}
    \fi
  \else
    \ifnum\number\textwidth>40
      \jlreq@note{一行の長さは40文字以下が望ましい (2.4.2.c 注2)．}
    \fi
  \fi
  \multiply\textwidth\@tempdima
\fi
\if@twocolumn
  \setlength{\textwidth}{\dimexpr2\textwidth + \columnsep\relax}
\fi
\addtolength{\textwidth}{0.0001pt}


%.. \textheight：行送り方向の長さ
% 一番上（直後に\topskip由来が入る）から最終行のベースラインまでの長さ．
% \topskipが十分ある時は先頭行のベースラインから最終行のベースライン＋\topskip
\def\jlreq@adjusttextheight{
  \addtolength{\textheight}{-\topskip}
  \divide\textheight\baselineskip \multiply\textheight\baselineskip
  \addtolength{\textheight}{\topskip}
}
\__jlreq_aftercls_addtodeletecs:N \jlreq@adjusttextheight
\ifx\jlreq@option@number@of@lines\@empty
  \if@tate
    \ifnum 0\ifx\jlreq@option@gutter\@empty 1\fi\ifx\jlreq@option@fore@edge\@empty 1\fi>0
      \setlength{\textheight}{0.75\paperwidth}
      \jlreq@adjusttextheight
    \else
      \jlreq@determine@kihonhanmen@warning
      \setlength{\textheight}{\dimexpr\paperwidth - \jlreq@option@gutter - \jlreq@option@fore@edge + \topskip - 1\zw\relax}
    \fi
  \else
    \ifnum 0\ifx\jlreq@option@head@space\@empty 1\fi\ifx\jlreq@option@foot@space\@empty 1\fi>0
      \setlength{\textheight}{0.75\paperheight}
      \jlreq@adjusttextheight
    \else
      \jlreq@determine@kihonhanmen@warning
      \setlength{\textheight}{\dimexpr\paperheight  + 2\topskip - 1\zh -  \Cht - \jlreq@option@head@space - \jlreq@option@foot@space\relax}
    \fi
  \fi
\else
  \setlength{\textheight}{\dimexpr\numexpr\jlreq@option@number@of@lines\relax\baselineskip - \baselineskip + \topskip\relax}
\fi
\addtolength{\textheight}{0.0001pt}

%.. 横
\def\jlreq@setsidemargin@by@gutter#1{
  \if@tate
    \setlength{\evensidemargin}{#1}
    \setlength{\oddsidemargin}{\dimexpr\paperwidth - \textheight - \evensidemargin + \topskip - \Cht\relax}
    \addtolength{\evensidemargin}{\Cdp}
  \else
    \setlength{\oddsidemargin}{#1}
    \if@twocolumn
      \addtolength{\oddsidemargin}{\dimexpr\marginparsep + \marginparwidth\relax}
    \fi
    \setlength{\evensidemargin}{\dimexpr\paperwidth - \textwidth - \oddsidemargin\relax}
  \fi
}
\def\jlreq@setsidemargin@by@fore@edge#1{
  \jlreq@setsidemargin@by@gutter{#1}
  \jlreq@helper@swap@register{\oddsidemargin}{\evensidemargin}
  \ifjlreq@determine@kihonhanmen@warning@first
    \jlreq@note{基本版面の配置はのどの空き量を指定する (2.4.1.b)．}
  \fi
}
\__jlreq_aftercls_addtodeletecs:N \jlreq@setsidemargin@by@gutter
\__jlreq_aftercls_addtodeletecs:N \jlreq@setsidemargin@by@fore@edge

\ifx\jlreq@option@gutter\@empty
  \ifx\jlreq@option@fore@edge\@empty
    % 中央配置
    \if@tate
      \setlength{\oddsidemargin}{\dimexpr\paperwidth - \textheight + \topskip\relax}
    \else
      \if@twocolumn
        \setlength{\oddsidemargin}{\dimexpr\paperwidth - \textwidth\relax}
      \else
        \setlength{\oddsidemargin}{\dimexpr\paperwidth - \textwidth - \marginparsep - \marginparwidth\relax}
      \fi
    \fi
    \setlength{\oddsidemargin}{.5\oddsidemargin}
    \ifnum0\if@twocolumn1\fi\if@tate1\fi>0
      \setlength{\evensidemargin}{\oddsidemargin}
    \else
      \setlength{\evensidemargin}{\dimexpr\oddsidemargin + \marginparsep + \marginparwidth\relax}
    \fi
  \else
    \jlreq@setsidemargin@by@fore@edge{\jlreq@speciallength{\jlreq@option@fore@edge}}
  \fi
\else
  \jlreq@setsidemargin@by@gutter{\jlreq@speciallength{\jlreq@option@gutter}}
  \ifx\jlreq@option@fore@edge\@empty\else
    \ifjlreq@determine@kihonhanmen@warning@first
      \ClassWarningNoLine{jlreq}{fore-edge~is~ignored}
    \fi
  \fi
\fi
\ifx l\jlreq@engine
  \addtolength{\oddsidemargin}{-1in}
  \addtolength{\evensidemargin}{-1in}
\else
  \addtolength{\oddsidemargin}{-1truein}
  \addtolength{\evensidemargin}{-1truein}
\fi

%.. 縦
% \topmarginに全体の頭からテキストの頭までの長さを入れる
% 天の値からtopmarginを設定する
\def\jlreq@settopmarginbyhead#1{
  \if@tate
    \setlength{\topmargin}{\dimexpr #1 - \headsep - \headheight\relax}
    \if@twocolumn
      \addtolength{\topmargin}{\dimexpr\marginparwidth + \marginparsep\relax}
    \fi
    \jlreq@note{縦組の場合は地の空き量を指定する (2.4.1.b)．}
  \else
    \setlength{\topmargin}{\dimexpr #1 - \headsep - \headheight - \topskip + \Cht\relax}
  \fi
}
\__jlreq_aftercls_addtodeletecs:N \jlreq@settopmarginbyhead
% 地の値から
\def\jlreq@settopmarginbyfoot#1{
  \if@tate
    \setlength{\topmargin}{\dimexpr\paperheight - \textwidth - \headsep - \headheight - #1 - \marginparsep - \marginparwidth\relax}
  \else
    \jlreq@note{横組の場合は天の空き量を指定する (2.4.1.b)．}
    \setlength{\topmargin}{\dimexpr\paperheight - \textheight + \topskip - 1\zh - \headsep - \headheight - #1\relax}
  \fi
}
\__jlreq_aftercls_addtodeletecs:N \jlreq@settopmarginbyfoot
\ifx\jlreq@option@head@space\@empty
  \ifx\jlreq@option@foot@space\@empty
    \if@tate
      \if@twocolumn
        \jlreq@settopmarginbyfoot{\dimexpr(\paperheight - \textwidth - 2\marginparwidth - 2\marginparsep)/2\relax}
      \else
        \jlreq@settopmarginbyfoot{\dimexpr(\paperheight - \textwidth - \marginparwidth - \marginparsep)/2\relax}
      \fi
    \else
      \jlreq@settopmarginbyhead{\dimexpr(\paperheight - (\textheight - \topskip + 1\zh))/2\relax}
    \fi
  \else
    \jlreq@settopmarginbyfoot{\jlreq@speciallength{\jlreq@option@foot@space}}
  \fi
\else
  \ifx\jlreq@option@foot@space\@empty
    \jlreq@settopmarginbyhead{\jlreq@speciallength{\jlreq@option@head@space}}
  \else
    % 両方指定されていたら，縦書きは地を，横書きは天を使う
    \if@tate
      \jlreq@settopmarginbyfoot{\jlreq@speciallength{\jlreq@option@foot@space}}
      \ifx\jlreq@option@line@length\@empty\else
        \ClassWarningNoLine{jlreq}{head_space~is~ignored}
      \fi
    \else
      \jlreq@settopmarginbyhead{\jlreq@speciallength{\jlreq@option@head@space}}
      \ifx\jlreq@option@number@of@lines\@empty\else
        \ClassWarningNoLine{jlreq}{foot_space~is~ignored}
      \fi
    \fi
  \fi
\fi
\ifx l\jlreq@engine
  \addtolength{\topmargin}{-1in}
\else
  \addtolength{\topmargin}{-1truein}
\fi
%.. 下
\setlength{\footskip}{\dimexpr\headsep + \if@tate\marginparwidth + \marginparsep\else\topskip - \Cht\fi + \headheight\relax}
% \maxdepth + \topskip = フォントサイズ×1.5（だってさ）
\setlength{\maxdepth}{\dimexpr1.5\zw - \topskip\relax}

%. システム設定
%.. 逆ノンブル
\ifjlreq@option@use@reverse@pagination
  \AtEndDocument{\clearpage\jlreq@reference@immediate@write{lastpage}{\noexpand\arabic{page}}}%
  \def\c@jlreqreversepage{\numexpr\jlreq@reference@ref{lastpage}{0} - \c@page + 1\relax}
  \def\thejlreqreversepage{\arabic{jlreqreversepage}}
\fi

%. 見出し関係 (4.1)
% \clear***page
\NewDocumentCommand{\cleartooddpage}{ O{} }{
  \clearpage
  \ifodd\c@page\else
    \jlreq@ifempty{#1}{}{\thispagestyle{#1}}%
    \hbox{}%
    \newpage
    \if@twocolumn\hbox{}\newpage\fi
  \fi
}
\NewDocumentCommand{\cleartoevenpage}{ O{} }{
  \clearpage
  \ifodd\c@page
    \jlreq@ifempty{#1}{}{\thispagestyle{#1}}%
    \hbox{}%
    \newpage
    \if@twocolumn\hbox{}\newpage\fi
  \fi
}

% 扉見出しと別行見出しについては，\<csname> -> \jlreq@headingcs@csname -> 本体と
% 二段構えで展開されるようにする．一度の展開で\parが出るのを防ぐため．
% 一度展開を\longなしマクロに渡されると破綻するので．（そういうパッケージが存在する．）

% jlreq@heading@maketoc@<命令名>が\tableofcontents用の出力をするために呼び出される．
% #1=*または空（見出し命令に*がついていたかで分岐），#2=ラベル，#3=running head
% デフォルトでは\<命令名>markと\addcontentslineが必要ならば呼ばれる．

% 見出しの直前に実行される
\NewHook{./heading/before}
% 見出し名一覧を格納する
\seq_new:N \l__jlreq_heading_allheadings_seq
% 目次を出力する命令\l@<命令名>を作る命令を作る．{1 = 命令名}{2 = レベル}{3 = ラベルのフォーマット}
% 結果は\jlreq@resultに入る．
\def\jlreq@heading@make@l@#1#2#3{%
  \@ifundefined{l@#1}{%
   % 長さは適当に計測する
    \begingroup
      % ちょっと大きめで計測しておく
      \csname c@#1\endcsname=9
      \setbox\jlreq@tempboxa=\hbox{#3}%
      \jlreq@tempdima=\wd\jlreq@tempboxa
      \csname c@#1\endcsname=26
      \setbox\jlreq@tempboxa=\hbox{#3}%
      \ifdim\jlreq@tempdima<\wd\jlreq@tempboxa
        \jlreq@tempdima=\wd\jlreq@tempboxa
      \fi
      % \numexprは四捨五入
      \jlreq@tempdimb=\dimexpr\the\numexpr\jlreq@tempdima/\dimexpr 1\jlreq@zw\relax + 2\relax\jlreq@zw\relax
      \edef\jlreq@do{%
        \unexpanded{\def\jlreq@result}{%
          \noexpand\def\exp_not:c {l@#1}{%
            \unexpanded{\@dottedtocline{#2}{0pt}}{\the\jlreq@tempdimb}%
          }%
        }%
      }%
    \expandafter\endgroup
    \jlreq@do
  }{\def\jlreq@result{}}%
}

% \jlreq@heading@make@maketoc{セクション名}{レベル}
\def\jlreq@heading@make@maketoc#1#2{%
  % 目次への出力をするマクロ．外部に切り出しておく．
  \@ifundefined{jlreq@heading@maketoc@#1}{%
    % {1 = */-}{2 = ラベル}{3 = running head}
    % 1はcounter=falseならば-，星付き命令ならば*，それ以外は空．
    % 1が*または-の時は見出しにはラベルが現れないが，2には常にラベルが入るので，必要ならばここで無視する．
    \expandafter\def\csname jlreq@heading@maketoc@#1\endcsname##1##2##3{%
      \jlreq@iffirsttoken{##1}{*}{}{%
        \csname #1mark\endcsname{##3}%
        \ifnum0\jlreq@iffirsttoken{##1}{-}{1}{}\ifnum #2>\c@secnumdepth 1\fi>0
          \addcontentsline{toc}{#1}{##3}%
        \else
          \addcontentsline{toc}{#1}{\jlreq@ifempty{##2}{}{\protect\numberline{##2}}##3}%
        \fi
      }{}%
    }%
  }{}%
}

%.. 中/半扉見出し
% addcontentslineに渡すやつ：番号出すのと出さないの
\NewDocumentCommand{\DeclareTobiraHeading}{ m m +m } {
  \ProvideHook{jlreq/heading/before/#1}
  \seq_put_right:Nn \l__jlreq_heading_allheadings_seq {#1}
  \seq_remove_duplicates:N \l__jlreq_heading_allheadings_seq
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\edef\csname jlreq@heading@setting@#1\endcsname{\unexpanded{#3}}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewTobiraHeading}%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \jlreq@heading@make@maketoc{#1}{#2}%
  \begingroup
    \let\jlreq@contents@label@format=\@undefined
    \let\jlreq@format=\@undefined
    \edef\jlreq@label@format{\exp_not:c {the#1}}%
    \newif\ifjlreq@number
    \keys_define:nn { DeclareTobiraHeading:#1 } {
      label_format .tl_set:N = \jlreq@label@format,
      format .code:n = {\def\jlreq@format####1####2{##1}},
      pagestyle .tl_set:N = \jlreq@pagestyle,
      type .choice:,
      type / han .code:n = { \def\jlreq@heading@clearpage{\clearpage} },
      type / naka .code:n = { \def\jlreq@heading@clearpage{\clearpage\hbox{}\thispagestyle{empty}\clearpage} },
      number .choices:nn = {true,false} { \csname jlreq@number ##1 \endcsname }
    }
    \keys_set:nn { DeclareTobiraHeading:#1 } { type = naka, pagestyle = empty, number = true}
    \keys_set:nn { DeclareTobiraHeading:#1 } {#3}
    \def\jlreq@do{}%
    \ifx\jlreq@format\@undefined
      \def\jlreq@format##1##2{##1##2}%
    \fi
    \edef\jlreq@formatwlabel{\noexpand\jlreq@format{\exp_not:o {\jlreq@label@format}}}%
    \jlreq@heading@make@l@{#1}{#2}{\jlreq@label@format}%
    \tl_put_right:Nx \jlreq@do {\exp_not:o {\jlreq@result}}%
    \edef\jlreq@do{%
      \exp_not:o {\jlreq@do}%
      \noexpand\def\exp_not:c {jlreq@TobiraHeading@start@#1}[####1]####2{%
        \ifjlreq@number
          \unexpanded{\ifnum#2>\c@secnumdepth\else}%
            \unexpanded{\refstepcounter{#1}}%
          \noexpand\fi
        \fi
        \unexpanded{\jlreq@ifempty{##2}%
          {\long\gdef\jlreqHeadingText####1{}}%
          {\long\gdef\jlreqHeadingText####1{####1}}%
        }%
        \ifjlreq@number
          \unexpanded{\jlreq@if{\ifnum#2>\c@secnumdepth\relax\fi}}{%
            \unexpanded{\long\gdef\jlreqHeadingLabel####1{}}%
            \exp_not:o {\jlreq@format{}{##1}}%
          }{%
            \unexpanded{\long\gdef\jlreqHeadingLabel####1{####1}}%
            \expandafter\exp_not:o \expandafter{\jlreq@formatwlabel{##2}}%
          }%
        \else
          \unexpanded{\long\gdef\jlreqHeadingLabel####1{}}%
          \exp_not:o {\jlreq@format{}{##1}}%
        \fi
        \exp_not:c {jlreq@heading@maketoc@#1}{\ifjlreq@number\else -\fi}{\exp_not:o {\jlreq@label@format}}{####1}%
        \noexpand\@afterheading
        \exp_not:o {\jlreq@heading@clearpage}%
        \unexpanded{\if@restonecol\twocolumn\fi}%
      }%
      \noexpand\def\exp_not:c {jlreq@TobiraHeading@start@s@#1}####1{%
        \unexpanded{\long\gdef\jlreqHeadingLabel####1{}}%
        \unexpanded{\jlreq@ifempty{##1}%
          {\long\gdef\jlreqHeadingText####1{}}%
          {\long\gdef\jlreqHeadingText####1{####1}}%
        }%
        \exp_not:o {\jlreq@format{}{##1}}
        \exp_not:c {jlreq@heading@maketoc@#1}{*}{\exp_not:o {\jlreq@label@format}}{####1}%
        \noexpand\@afterheading
        \exp_not:o {\jlreq@heading@clearpage}%
        \unexpanded{\if@restonecol\twocolumn\fi}%
      }%
      \noexpand\def\exp_not:c {jlreq@headingcs@#1}{%
        % 改丁．これでよいのかな．
        \unexpanded{\if@twocolumn\onecolumn\@restonecoltrue\else\@restonecolfalse\fi\cleartooddpage[empty]}%
        \ifx\jlreq@pagestyle\@empty\else\noexpand\thispagestyle{\exp_not:o {\jlreq@pagestyle}}\fi
        \noexpand\secdef{\exp_not:c {jlreq@TobiraHeading@start@#1}}{\exp_not:c {jlreq@TobiraHeading@start@s@#1}}}%
      \noexpand\def\exp_not:c {#1}{%
        \noexpand\UseHook{jlreq/heading/before}%
        \noexpand\UseHook{jlreq/heading/before/#1}%
        \exp_not:c {jlreq@headingcs@#1}%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\NewDocumentCommand{\NewTobiraHeading}{ m m +m }{%
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareTobiraHeading{#1}{#2}{#3}}%
}
\NewDocumentCommand{\RenewTobiraHeading}{ m m +m }{%
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareTobiraHeading{#1}{#2}{#3}}%
}
\NewDocumentCommand{\ProvideTobiraHeading}{ m m +m }{%
  \@ifundefined{#1}{\DeclareTobiraHeading{#1}{#2}{#3}}{}%
}

%.. 別行見出し
% \jlreq@BlockHeading@start：別行見出しを出力する命令．
% \jlreq@BlockHeading@start{1 = 命令名}{2 = レベル}{3 = スペース関連}{4 = カウンタ関連}{5 =  フォーマット関連}{6 = 全体フォーマット}*{見出し}[副題]
% カウンタ関連=-,*,無し：-はカウンタ関連を処理しない．*はさらに目次に追加しない（星付き命令と同様）．星付きで呼び出された時は常に*同等．
% スペース関連={配置:lcr（左中央右）}{字下げ（寸法）}{字上げ（寸法）}{前空き}{後空き}{行取りの行数}{空か*か，偶数ページでも改ページを許可するならば空}
% 前/後空きはprefixにa:/s:/r:が入る．r:は空きがその値そのものになる．a:/s:は行取りに加えて入る．a:で指定された空きはページ行頭では入らない
% 後空きの時はs:は指定できない．
% フォーマット関連：
% フォーマット関連={{ラベルのみのフォーマット}{ラベルフォーマット}{見出し文字列フォーマット}{見出し文字列フォーマット（ラベル無し）}{副題フォーマット}{副題フォーマット（ラベル無し）}}{{前フォーマットラベルあり}{前フォーマットラベルなし}{見出し全体のフォーマット}{後ろフォーマットラベルあり}{後ろフォーマットラベルなし}}
% 見出しそのものは「全体フォーマット」に従い出力される．パラメータトークン#1を含み，#1=見出し本体：スペース関連と上の「見出し全体のフォーマット」に基づいて整形される．
% 見出し全体のフォーマット内では#1=ラベル，#2=見出し文字列，#3=副題，それぞれ各々のフォーマットに基づき整形される．
% ラベルフォーマットでは#1=カウンタ名，見出し文字列フォーマットでは#1=見出し文字列，副題フォーマットでは#1=副題
% ラベルのみのフォーマットは目次に使われる．
\long\def\jlreq@BlockHeading@start#1#2#3#4#5#6{%
  \if@noskipsec\leavevmode\fi
  % #5と#6は\parを含むかもしれないので引数渡しはしない（後の\@ifstarで詰まる）
  \edef\jlreq@BlockHeading@start@eachformat{\exp_not:o {\@firstoftwo#5}}%
  \edef\jlreq@BlockHeading@start@format{\exp_not:o {\@secondoftwo#5}}%
  \edef\jlreq@BlockHeading@start@totalformat{\unexpanded{#6}}%
  \jlreq@BlockHeading@start@{#1}{#2}{#3}{#4}%
}
% {1 = 命令}{2 = レベル}{3 = スペース関連}
\long\def\jlreq@BlockHeading@start@#1#2#3#4{%
  \@ifstar{\@dblarg{\jlreq@BlockHeading@start@@{#1}{#2}{#3}{*}}}{\@dblarg{\jlreq@BlockHeading@start@@{#1}{#2}{#3}{#4}}}%
}
% {1 = 命令}{2 = レベル}{3 = スペース関連}{4 = *}[5 = running head]{6 = 見出し}
\long\def\jlreq@BlockHeading@start@@#1#2#3#4[#5]#6{%
  \@ifnextchar[{\jlreq@BlockHeading@start@@@{#1}{#2}{#3}{#4}{#5}{#6}}{\jlreq@BlockHeading@start@@@{#1}{#2}{#3}{#4}{#5}{#6}[]}%
}

% {1 = 命令}{2 = レベル}{3 = スペース関連}{4 = *}{5 = running head}{6 = 見出し}[7 = 副題]
\long\def\jlreq@BlockHeading@start@@@#1#2#3#4#5#6[#7]{%
  \edef\jlreq@do{\unexpanded{\jlreq@BlockHeading@start@@@@{#1}{#2}{#3}}{\exp_not:o {\jlreq@BlockHeading@start@totalformat}}}%
  \jlreq@do{#4}{#5}{#6}{#7}%
}

% {1 = 命令}{2 = レベル}{3 = スペース関連}{4 = 全フォーマット}{5 = *}{6 = running head}{7 = 見出し}{8 = 副題}
\long\def\jlreq@BlockHeading@start@@@@#1#2#3#4#5#6#7#8{%
  \edef\jlreq@tempa##1##2##3##4##5##6##7{%
    \unexpanded{\jlreq@BlockHeading@start@makeoutput{#1}{#2}}{{##1}{##2}{##3}}{\exp_not:o {\jlreq@BlockHeading@start@eachformat}}{\exp_not:o {\jlreq@BlockHeading@start@format}}\unexpanded{{#5}{#6}{#7}{#8}}%
    \unexpanded{\def\jlreq@tempb}{{##4}{##5}{##6}}% 縦方向空き
    \noexpand\jlreq@ifempty{##7}{\noexpand\jlreq@tempatrue}{\noexpand\jlreq@tempafalse}% 偶数ページのみで改ページするならば\jlreq@tempatrue
  }%
  \jlreq@tempa#3%
  \global\advance\jlreq@BlockHeading@spaces@current@count by 1
  \tl_gput_right:Nn \jlreq@BlockHeading@spaces@current@sequence {_#1}%
  % 連続する見出しの間の処理をするために，即時では出力せず，いったんマクロに格納する．
  % \jlreq@BlockHeading@spaces@current@before@<n>
  % \jlreq@BlockHeading@start@gyodori\jlreq@BlockHeading@spaces@current@space@<n>{jlreq@BlockHeading@spaces@current@output@<n>}
  % ↑\jlreq@BlockHeading@spaces@current@format@<n>で整形される．
  % \jlreq@BlockHeading@spaces@current@after@<n>
  % として後に呼び出される．（spaceは書き換えられる可能性がある．）
  \expandafter\xdef\csname jlreq@BlockHeading@spaces@current@output@\the\jlreq@BlockHeading@spaces@current@count\endcsname{%
    \exp_not:o {\jlreq@resultb}%
  }%
  \expandafter\xdef\csname jlreq@BlockHeading@spaces@current@space@\the\jlreq@BlockHeading@spaces@current@count\endcsname{%
    \exp_not:o {\jlreq@tempb}%
  }%
  \def\@tempa##1##2##3{##1}%
  \expandafter\xdef\csname jlreq@BlockHeading@spaces@current@before@\the\jlreq@BlockHeading@spaces@current@count\endcsname{%
    \noexpand\allowbreak
    \exp_not:o {\@tempa#4}%
    \exp_not:o {\jlreq@resulta}%
    \ifjlreq@tempa\unexpanded{%
      \jlreq@setcurrentpage
      \edef\jlreq@BlockHeading@currentpage{\the\jlreq@currentpage}%
    }\fi
  }%
  \def\@tempa##1##2##3{##2}%
  \expandafter\xdef\csname jlreq@BlockHeading@spaces@current@format@\the\jlreq@BlockHeading@spaces@current@count\endcsname{%
    \exp_not:o {\@tempa#4}%
  }%
  \def\@tempa##1##2##3{##3}%
  \expandafter\xdef\csname jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count\endcsname{%
    \exp_not:o {\jlreq@resultc}%
    \ifjlreq@tempa\unexpanded{%
      \ifx\jlreq@BlockHeading@currentpage\@empty\nobreak\else
        \ifodd\jlreq@BlockHeading@currentpage\nobreak\else\allowbreak\fi
      \fi
    }\else\noexpand\nobreak\fi
    \exp_not:o {\@tempa#4}%
  }%
  \ifx\jlreq@BlockHeading@spaces@headingslist\@empty
    \expandafter\jlreq@BlockHeading@spaces@outputwospace
    \expandafter\ignorespaces
  \else
    \expandafter\jlreq@BlockHeading@start@afterheading
  \fi
}

\def\jlreq@BlockHeading@start@afterheading{\futurelet\jlreq@nextchar\jlreq@BlockHeading@start@afterheading@i}
\edef\jlreq@BlockHeading@start@afterheading@i{%
  \noexpand\ifx\exp_not:o {\space}\unexpanded{\jlreq@nextchar\expandafter\jlreq@BlockHeading@start@afterheading@skipspaces}%
  \unexpanded{\else\expandafter\jlreq@BlockHeading@start@afterheading@ii\fi}%
}
% スペースを読み飛ばす
\expandafter\def\expandafter\jlreq@BlockHeading@start@afterheading@skipspaces\space{\jlreq@BlockHeading@start@afterheading}
\def\jlreq@BlockHeading@start@afterheading@ii{%
  \def\jlreq@do{\jlreq@BlockHeading@spaces@output}%
  \seq_map_inline:Nn \l__jlreq_BlockHeading_allheadings_seq {
    \expandafter\ifx\csname##1\endcsname\jlreq@nextchar\def\jlreq@do{}\fi
  }%
  % \jlreq@BlockHeading@HeadingSpaces@ignoretokens(@noargument)内のものは特別扱いする
  \tl_map_inline:Nn \jlreq@BlockHeading@HeadingSpaces@ignoretokens@noargument {
    \ifx##1\jlreq@nextchar
      \def\jlreq@do{\jlreq@BlockHeading@start@afterheading@saveafter@cs@noargument}%
    \fi
  }%
  \tl_map_inline:Nn \jlreq@BlockHeading@HeadingSpaces@ignoretokens {
    \ifx##1\jlreq@nextchar
      \def\jlreq@do{\jlreq@BlockHeading@start@afterheading@saveafter@cs}%
    \fi
  }%
  \jlreq@do
}

% コントロールシークエンスを保存
\long\def\jlreq@BlockHeading@start@afterheading@saveafter@cs@noargument#1{%
  \tl_put_right:cn {jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count} {#1}
  \jlreq@BlockHeading@start@afterheading
}
\long\def\jlreq@BlockHeading@start@afterheading@saveafter@cs#1{%
  \tl_put_right:cn {jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count} {#1}
  \jlreq@BlockHeading@start@afterheading@saveafter@option
}
% オプションがあれば保存
\def\jlreq@BlockHeading@start@afterheading@saveafter@option{%
  \@ifnextchar[{\jlreq@BlockHeading@start@afterheading@saveafter@option@}{\jlreq@BlockHeading@start@afterheading@saveafter@arguments}%
}
\long\def\jlreq@BlockHeading@start@afterheading@saveafter@option@[#1]{%
  \tl_put_right:cx {jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count} {\exp_not:n {[#1]}}
  \jlreq@BlockHeading@start@afterheading@saveafter@arguments
}
% 引数を保存し続けるループ
\def\jlreq@BlockHeading@start@afterheading@saveafter@arguments{%
  \futurelet\jlreq@nextchar\jlreq@BlockHeading@start@afterheading@saveafter@arguments@
}
\edef\jlreq@BlockHeading@start@afterheading@saveafter@arguments@{%
  \noexpand\ifx\space\unexpanded{\jlreq@nextchar\expandafter\jlreq@BlockHeading@start@afterheading@saveafter@arguments@@\else\expandafter\jlreq@BlockHeading@start@afterheading@saveafter@arguments@@@\fi}%
}
\expandafter\def\expandafter\jlreq@BlockHeading@start@afterheading@saveafter@arguments@@\space{%
  \tl_put_right:cn {jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count} { }
  \jlreq@BlockHeading@start@afterheading@saveafter@arguments
}
\def\jlreq@BlockHeading@start@afterheading@saveafter@arguments@@@{%
  \jlreq@ifnextchar\bgroup{\jlreq@BlockHeading@start@afterheading@saveafter@arguments@@@@}{\jlreq@BlockHeading@start@afterheading}%
}
\long\def\jlreq@BlockHeading@start@afterheading@saveafter@arguments@@@@#1{%
  \tl_put_right:cx {jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count} {\exp_not:n {{#1}}}
  \jlreq@BlockHeading@start@afterheading@saveafter@arguments
}

% 特別扱いしたいマクロを並べる
\def\jlreq@BlockHeading@HeadingSpaces@ignoretokens{\label}
\def\jlreq@BlockHeading@HeadingSpaces@ignoretokens@noargument{\par}

% \jlreq@resulta -> before, \jlreq@resultb -> 本体，\jlreq@resultc -> after
% {1 = 命令}{2 = レベル}{3 = スペース関連（横方向のみ）}{4 = フォーマット群}{5 = まとめたフォーマット群}{6 = *}{7 = running head}{8 = 見出し}{9 = 副題}
\long\def\jlreq@BlockHeading@start@makeoutput#1#2#3#4#5#6#7#8#9{%
  \begingroup
    % ラベルがありか否か．\jlreq@tempc = \@emptyならばラベルあり
    \ifnum #2>\c@secnumdepth
      \def\jlreq@tempc{*}%
    \else
      \def\jlreq@tempc{#6}%
    \fi
    \edef\jlreq@tempa{\expandafter\jlreq@BlockHeading@start@geteachformat\expandafter{\jlreq@tempc}#4}% {ラベルフォーマット}{本文フォーマット}{副題フォーマット}
    \edef\jlreq@tempb{\expandafter\jlreq@BlockHeading@start@getformat\expandafter{\jlreq@tempc}#5}% {まとめるフォーマット}
    \edef\jlreq@do{\noexpand\jlreq@BlockHeading@start@makeoutput@@\exp_not:o {\jlreq@tempa}\exp_not:o {\jlreq@tempb}\unexpanded{{#8}{#9}}}%
    \jlreq@do
    \edef\jlreq@do{\noexpand\jlreq@BlockHeading@start@makeoutput@\unexpanded{#3}{\exp_not:o {\jlreq@result}}}%
    \jlreq@do
    % \jlreq@tempa -> 素のラベルフォーマット
    \edef\jlreq@tempa{\jlreq@BlockHeading@start@getonlylabelformat#4}%
    \edef\jlreq@do{%
      \unexpanded{\def\jlreq@resulta}{%
        \ifx\jlreq@tempc\@empty
          \unexpanded{\long\gdef\jlreqHeadingLabel####1{####1}}%
          \unexpanded{\refstepcounter{#1}}%
        \else
          \unexpanded{\long\gdef\jlreqHeadingLabel####1{}}%
        \fi
        \jlreq@ifempty{#8}%
          {\unexpanded{\long\gdef\jlreqHeadingText####1{}}}%
          {\unexpanded{\long\gdef\jlreqHeadingText####1{####1}}}%
        \jlreq@ifempty{#9}%
          {\unexpanded{\long\gdef\jlreqHeadingSubtitle####1{}}}%
          {\unexpanded{\long\gdef\jlreqHeadingSubtitle####1{####1}}}%
      }%
      \unexpanded{\def\jlreq@resultb}{%
        \exp_not:o {\jlreq@result}%
      }%
      \unexpanded{\def\jlreq@resultc}{%
        \exp_not:c {jlreq@heading@maketoc@#1}{\unexpanded{#6}}{\exp_not:o {\jlreq@tempa}}{\unexpanded{#7}}%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}

% {ラベルフォーマット}{本文フォーマット}{副題フォーマット}に展開される．
% {1 = 空ならばラベルあり}{2 = ラベルのみのフォーマット}{3 = ラベルフォーマット}{4 = 見出し文字列フォーマット}{5 = 見出し文字列フォーマット（ラベル無し）}{6 = 副題フォーマット}{7 = 副題フォーマット（ラベル無し）}
\long\def\jlreq@BlockHeading@start@geteachformat#1#2#3#4#5#6#7{%
  \jlreq@ifempty{#1}{\unexpanded{{#3}{#4}{#6}}}{\unexpanded{{}{#5}{#7}}}%
}
% {全体フォーマット}に展開される．
% {1 = 空ならばラベルあり}{2 = 前フォーマットラベルあり}{3 = 前フォーマットラベルなし}{4 = 見出し全体のフォーマット}{5 = 後ろフォーマットラベルあり}{6 = 後ろフォーマットラベルなし}
\long\def\jlreq@BlockHeading@start@getformat#1#2#3#4#5#6{%
  \jlreq@ifempty{#1}{{\unexpanded{#2#4#6}}}{{\unexpanded{#3#4#6}}}%
}
\long\def\jlreq@BlockHeading@start@getonlylabelformat#1#2#3#4#5#6{\unexpanded{#1}}%

% 横方向の空き調整を入れて，\jlreq@resultに返す．
% {1 = 配置(clr)}{2 = 字下げ}{3 = 字上げ}{4 = 出力}
\long\def\jlreq@BlockHeading@start@makeoutput@#1#2#3#4{%
  \edef\jlreq@result{%
    \noexpand\noindent
    \jlreq@ifempty{#2}{}{\unexpanded{\hskip #2}}%
    \noexpand\vbox{%
      \noexpand\noindent
      \ifx#1c\noexpand\centering\fi
      \ifx#1r\noexpand\raggedleft\fi
      \jlreq@ifempty{#2}{}{\unexpanded{\hsize=\dimexpr\hsize - #2\relax}}%
      \jlreq@ifempty{#3}{}{\unexpanded{\hsize=\dimexpr\hsize - #3\relax}}%
      \unexpanded{#4}%
    }%
  }%
}

% {1 = ラベルフォーマット}{2 = 見出し文字列フォーマット}{3 = 副題フォーマット}{4 = 全体フォーマット}{5 = 見出し}{6 = 副題}
% \jlreq@resultに出力対象を入れる
\long\def\jlreq@BlockHeading@start@makeoutput@@#1#2#3#4#5#6{%
  \begingroup
    \long\def\jlreq@tempa##1{#2}% 見出し文字列
    \expandafter\def\expandafter\jlreq@tempa\expandafter{\jlreq@tempa{#5}}%
    \jlreq@ifempty{#6}{%
      \def\jlreq@tempb{}%
    }{%
      \long\def\jlreq@tempb##1{#3}% 副題
      \expandafter\def\expandafter\jlreq@tempb\expandafter{\jlreq@tempb{#6}}%
    }%
    \long\def\jlreq@tempc##1##2##3{#4}% 全体のフォーマット
    % 二度展開すると欲しいものが得られる
    \edef\jlreq@tempa{\noexpand\jlreq@tempc{\unexpanded{#1}}{\exp_not:o {\jlreq@tempa}}{\exp_not:o {\jlreq@tempb}}}%
    \edef\jlreq@do{%
      \unexpanded{\def\jlreq@result}{\expandafter\exp_not:o \expandafter{\jlreq@tempa}}%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\def\jlreq@BlockHeading@start@removecolumn#1:{#1}

% 空き指定を解釈する．a:10pt -> \jlreq@resulta=a，\jlreq@resultb=10pt
\cs_set:Nn \__jlreq_BlockHeading_start_analyzespace:n{%
  \__jlreq_BlockHeading_start_analyzespace_aux#1:\jlreq@endmark
}
\cs_generate_variant:Nn \__jlreq_BlockHeading_start_analyzespace:n {V}
\def\__jlreq_BlockHeading_start_analyzespace_aux#1:#2\jlreq@endmark{
  \jlreq@ifempty{#1}{%
    \def\jlreq@resulta{}%
    \def\jlreq@resultb{}%
  }{%
    \let\jlreq@resulta=#1
    \edef\jlreq@resultb{\exp_not:o {\jlreq@BlockHeading@start@removecolumn#2}}%
  }%
}

% 行取り処理．#3が空の時は行取りの処理はしない．（空白挿入は行う．）
% {1 = 前空き}{2 = 後ろ空き}{3 = トータル行数}{4 = 出力}
% 最後には\nobreak（と\vskip）が入っている
\long\def\jlreq@BlockHeading@start@gyodori#1#2#3#4{\par{%
  \setbox\jlreq@tempboxa=\vbox{#4}%
  % \jlreq@tempskip(a/b)に前/後ろに入れるべき値を入れる
  % #1がa:ならばその値は\jlreq@tempskipaには足さず\jlreq@tempskipcに入れておく
  \jlreq@tempskipa=0pt
  \jlreq@tempskipb=0pt
  \jlreq@tempskipc=0pt
  \tl_set_rescan:Nnn \l_jlreq_tmpa_tl {\ExplSyntaxOn}{#1}
%  \message{[[[\expandafter\getcatcode\l_jlreq_tmpa_tl]]]}
  \__jlreq_BlockHeading_start_analyzespace:V \l_jlreq_tmpa_tl
  \let\jlreq@maeakitype=\jlreq@resulta
  \let\jlreq@maeaki=\jlreq@resultb
  \tl_set_rescan:Nnn \l_jlreq_tmpa_tl {\ExplSyntaxOn}{#2}
  \__jlreq_BlockHeading_start_analyzespace:V \l_jlreq_tmpa_tl
  \let\jlreq@ushiroakitype=\jlreq@resulta
  \let\jlreq@ushiroaki=\jlreq@resultb
  \def\jlreq@lines{#3}%
  % 両方強制指定の場合は行数を無視する．
  \ifx r\jlreq@maeakitype\ifx r\jlreq@ushiroakitype\def\jlreq@lines{}\fi\fi
  \setbox\jlreq@tempboxb=\hbox{阿}%
  \ifx\jlreq@lines\@empty
    \ifx\jlreq@maeaki\@empty\else
      \ifx a\jlreq@maeakitype
        \jlreq@tempskipc=\glueexpr\jlreq@maeaki\relax
      \else
        \jlreq@tempskipa=\glueexpr\jlreq@maeaki\relax
      \fi
    \fi
    \ifx\jlreq@ushiroaki\@empty\else
      \jlreq@tempskipb=\glueexpr\jlreq@ushiroaki\relax
    \fi
  \else
    % 行取り時の前後の空きを足した値を\jlreq@tempdimaに入れる
    \jlreq@tempdima=\glueexpr(#3\baselineskip - \baselineskip - \ht\jlreq@tempboxa - \dp\jlreq@tempboxa)\relax
    \ifx\jlreq@maeakitype\@empty
      \jlreq@tempskipa=\glueexpr(\jlreq@tempdima + \dp\jlreq@tempboxb - \ht\jlreq@tempboxb)/2\relax
    \else
      \ifx a\jlreq@maeakitype
        \jlreq@tempskipa=\glueexpr(\jlreq@tempdima + \dp\jlreq@tempboxb - \ht\jlreq@tempboxb)/2\relax
        \jlreq@tempskipc=\glueexpr\jlreq@maeaki\relax
      \fi
      \ifx s\jlreq@maeakitype
        \jlreq@tempskipa=\glueexpr(\jlreq@tempdima + \dp\jlreq@tempboxb - \ht\jlreq@tempboxb)/2 + \jlreq@maeaki\relax
        \jlreq@tempdima=\dimexpr\jlreq@tempdima + \jlreq@maeaki\relax
      \fi
      \ifx r\jlreq@maeakitype
        \jlreq@tempskipa=\glueexpr\jlreq@maeaki\relax
        \jlreq@tempdima=\dimexpr\jlreq@tempdima + \baselineskip - \dp\jlreq@tempboxb\relax
      \fi
    \fi
    \ifx\jlreq@ushiroakitype\@empty
      \jlreq@tempskipb=\glueexpr\jlreq@tempdima - \jlreq@tempskipa\relax
    \else
      \ifx a\jlreq@ushiroakitype
        \jlreq@tempskipb=\glueexpr\jlreq@tempdima - \jlreq@tempskipa + \jlreq@ushiroaki\relax
      \fi
      \ifx r\jlreq@ushiroakitype
        \jlreq@tempskipb=\glueexpr\jlreq@ushiroaki\relax
        \jlreq@tempskipa=\glueexpr\jlreq@tempdima - \jlreq@tempskipb + \baselineskip - \ht\jlreq@tempboxb\relax
      \fi
    \fi
    % \jlreq@tempdimaの利用ここまで
  \fi
  \jlreq@ifgluezero\jlreq@tempskipc{}{\vskip\jlreq@tempskipc\relax}%
  \ifx r\jlreq@maeakitype\prevdepth=-1000pt\fi
  % \jlreq@tempdimb, \jlreq@tempdimcに出力対称の高さを深さを代入
  \jlreq@tempdimb=\ht\jlreq@tempboxa
  \jlreq@tempdimc=\dp\jlreq@tempboxa
  \setbox\jlreq@tempboxa=\vbox{%
    \jlreq@ifgluezero\jlreq@tempskipa{}{\vskip\jlreq@tempskipa}%
    \unvbox\jlreq@tempboxa
  }%
  \ifx\jlreq@lines\@empty
    \dp\jlreq@tempboxa=\dimexpr\dp\jlreq@tempboxa + \ht\jlreq@tempboxa - \jlreq@tempdimb\relax
    \ht\jlreq@tempboxa=\jlreq@tempdimb
    \box\jlreq@tempboxa
    \ifx r\jlreq@ushiroakitype\prevdepth=-1000pt\relax\else\prevdepth=\jlreq@tempdimc\fi
    % \jlreq@tempdimb, \jlreq@tempdimcの利用ここまで
  \else
    \dp\jlreq@tempboxa=\dimexpr\dp\jlreq@tempboxa + \ht\jlreq@tempboxa\relax
    \ht\jlreq@tempboxa=0pt
    \box\jlreq@tempboxa
    \ifx r\jlreq@ushiroakitype\prevdepth=-1000pt\relax\else\prevdepth=0pt\relax\fi
  \fi
  \nobreak
  \jlreq@ifgluezero\jlreq@tempskipb{}{\vskip\jlreq@tempskipb}%
  \edef\jlreq@do{%
    \dim_compare:nF { \parskip=0pt } {
      \noexpand\AddToHookNext{para/before}{\noexpand\parskip=\the\parskip\noexpand\relax}%
      \noexpand\parskip=0pt
    }
  }%
  \expandafter}\jlreq@do
}

% 行取り情報をゲットだぜ
% \jlreq@resultに{1 = 前空き}{2 = 後ろ空き}{3 = トータル行数}を入れる
% #2#3#4はそれぞれ前空き，後ろ開き，トータル行数のデフォルト値
% *つきは\setkeys*を使う．[]はkeyvalのファミリー．
\def\jlreq@BlockHeading@gyodori@parsekeyval{%
  \@ifstar{\jlreq@BlockHeading@gyodori@parsekeyval@{*}}{\jlreq@BlockHeading@gyodori@parsekeyval@{}}%
}
\def\jlreq@BlockHeading@gyodori@parsekeyval@#1{%
  \@ifnextchar[{\jlreq@BlockHeading@gyodori@parsekeyval@@{#1}}{\jlreq@BlockHeading@gyodori@parsekeyval@@{#1}[jlreq@key]}%
}
\long\def\jlreq@BlockHeading@gyodori@parsekeyval@@#1[#2]#3#4#5#6{%
  \group_begin:
    \keys_define:nn {#2} {
      lines .tl_set:N = \l__jlreq_lines_tl,
      before_space .tl_set:N = \l__jlreq_before_space_tl,
      after_space .tl_set:N = \l__jlreq_after_space_tl,
      before_lines .code:n = {
        \tl_if_empty:nTF {##1}{
          \tl_set:Nn \l__jlreq_before_lines_tl {}
        }{
          \str_if_eq:eeTF { \str_head:n {##1} } {*}
            {\tl_set:Nx \l__jlreq_before_lines_tl {s:\exp_not:o {\use_none:n ##1}}}
            {\tl_set:Nx \l__jlreq_before_lines_tl {a:##1}}
        }
      },
      after_lines .tl_set:N = \l__jlreq_after_lines_tl
    }
    \tl_if_empty:nF {#1} { \keys_define:nn {#2} { unknown .code:n = {} } }
    \keys_set:nn {#2} {lines = {#6}, before_space = {}, before_lines = {}, after_space = {}, after_lines = {} }
    \keys_set:nn {#2} {#3} 
    % before/after_lines優先
    \tl_if_empty:NF \l__jlreq_before_space_tl { \tl_put_left:Nn \l__jlreq_before_space_tl {r:} }
    \tl_if_empty:NF \l__jlreq_before_lines_tl { \tl_set:Nx \l__jlreq_before_space_tl {\exp_not:o {\l__jlreq_before_lines_tl} \baselineskip } }
    \tl_if_empty:NT \l__jlreq_before_space_tl { \tl_set:Nn \l__jlreq_before_space_tl {#4} }
    \tl_if_empty:NF \l__jlreq_after_space_tl { \tl_put_left:Nn \l__jlreq_after_space_tl {r:} }
    \tl_if_empty:NF \l__jlreq_after_lines_tl { \tl_set:Nx \l__jlreq_after_space_tl { a:\exp_not:o {\l__jlreq_after_lines_tl} \baselineskip } }
    \tl_if_empty:NT \l__jlreq_after_space_tl { \tl_set:Nn \l__jlreq_after_space_tl {#5} }
    \cs_set:Nx \l__jlreq_do: {
      \exp_not:n {\def\jlreq@result}{
        {\exp_not:o {\l__jlreq_before_space_tl } }
        {\exp_not:o {\l__jlreq_after_space_tl } }
        {\exp_not:o {\l__jlreq_lines_tl } }
      }
    }%
  \exp_after:wN \group_end:
  \l__jlreq_do:
}

\newbox\jlreq@BlockHeading@start@label@box
% \DeclareBlockHeading{命令名}{レベル}{設定}
\seq_new:N \l__jlreq_BlockHeading_allheadings_seq
\NewDocumentCommand {\DeclareBlockHeading} { m m +m } {
  \ProvideHook{jlreq/heading/before/#1}
  \def\jlreq@do{\@removeelement{#1}}%
  \seq_put_right:Nn \l__jlreq_heading_allheadings_seq {#1}
  \seq_remove_duplicates:N \l__jlreq_heading_allheadings_seq
  \seq_put_right:Nn \l__jlreq_BlockHeading_allheadings_seq {#1}
  \seq_remove_duplicates:N \l__jlreq_BlockHeading_allheadings_seq
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\edef\csname jlreq@heading@setting@#1\endcsname{\unexpanded{#3}}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewBlockHeading}%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \jlreq@heading@make@maketoc{#1}{#2}%
  \begingroup
    \edef\jlreq@heading@text@format{\unexpanded{##1}}%
    \newif\ifjlreq@second@text@indent@withlabel
    \newif\ifjlreq@subtitleindent@withlabel
    \newif\ifjlreq@subtitle@break
    \newif\ifjlreq@column@spanning@possible
    \newif\ifjlreq@number
    % a,bみたいなのをaとbにわける．カンマがなければbは空．引数を{a}{b}として##2を呼び出す．
    \def\jlreq@parsecomma##1##2{%
      \jlreq@helper@dividebycomma{##1}%
      \jlreq@if{\ifjlreq@result\fi}{%
        \edef\jlreq@do{\noexpand\jlreq@tempa{\exp_not:o {\jlreq@resulta}}{\exp_not:o {\jlreq@resultb}}}%
      }{%
        \edef\jlreq@do{\noexpand\jlreq@tempa{##1}{}}%
      }%
      \def\jlreq@tempa####1####2{##2}%
      \jlreq@do
    }%
    \keys_define:nn { BlockHeading:#1 } {
      lines .code:n = {},
      before_space .code:n = {},
      after_space .code:n = {},
      before_lines .code:n = {},
      after_lines .code:n = {},
      font .tl_set:N = \jlreq@font,
      subtitle_font .tl_set:N = \jlreq@subtitle@font,
      indent .tl_set:N = \jlreq@indent,
      end_indent .tl_set:N = \jlreq@end@indent,
      align .choice:,
      align / left .code:n = { \def\jlreq@align{l} },
      align / center .code:n = { \def\jlreq@align{c} },
      align / right .code:n = { \def\jlreq@align{r} },
      format .code:n = {\edef\jlreq@format{\unexpanded{##1}}},
      after_label_space .tl_set:N = \jlreq@after@label@space,
      heading_text_second_indent .code:n = {
        \ClassError { jlreq } { `heading_text_second_indent`~was~removed,~use~`second_heading_text_indent`~instead~(in~BlockHeading:~#1) }{\@ehc}
      },
%      {second_heading_text_indent,heading_text_second_indent}{%
      second_heading_text_indent .code:n = {
        \jlreq@parsecomma{##1}{%
          \jlreq@iffirsttoken{####1}{*}{%
            \jlreq@second@text@indent@withlabelfalse
            \edef\jlreq@second@heading@text@indent@wlabel{\exp_not:o {\@gobble ####1}}%
          }{%
            \jlreq@second@text@indent@withlabeltrue
            \def\jlreq@second@heading@text@indent@wlabel{####1}%
          }%
          \jlreq@ifempty{####2}{%
            \let\jlreq@second@heading@text@indent@wolabel=\jlreq@second@heading@text@indent@wlabel
          }{%
            \def\jlreq@second@heading@text@indent@wolabel{####2}%
          }%
        }%
      },
      label_format .code:n = {\edef\jlreq@label@format{\unexpanded{##1}}},
      subtitle_format .code:n = {\edef\jlreq@subtitle@format{\unexpanded{##1}}},
      subtitle_indent .code:n = {%
        \jlreq@iffirsttoken{##1}{*}{%
          \jlreq@subtitleindent@withlabelfalse
          \edef\jlreq@subtitle@indent{\exp_not:o {\@gobble ##1}}%
        }{%
          \jlreq@subtitleindent@withlabeltrue
          \def\jlreq@subtitle@indent{##1}%
        }%
      },
      subtitle_break .choices:nn = {true,false}{\csname jlreq@subtitle@break##1\endcsname},
      afterindent .choices:nn = {true,false}{\edef\jlreq@afterindent{\exp_not:c {@afterindent##1}}},
      allowbreak_if_evenpage .choices:nn = {true,false}{%
        \str_if_eq:nnTF {##1} {true}
          {\def\jlreq@allowbreak@evenpage{}}
          {\def\jlreq@allowbreak@evenpage{*}}
      },
      pagebreak .choice:,
      pagebreak / clearpage            .code:n = {\def\jlreq@pagebreak{\clearpage}\jlreq@column@spanning@possibletrue},
      pagebreak / cleardoublepage      .code:n = {\def\jlreq@pagebreak{\cleardoublepage}\jlreq@column@spanning@possibletrue},
      pagebreak / clearcolumn          .code:n = {\if@twocolumn\def\jlreq@pagebreak{\newpage}\else\def\jlreq@pagebreak{}\fi\jlreq@column@spanning@possiblefalse},
      pagebreak / begin_with_even_page .code:n = {\def\jlreq@pagebreak{\cleartoevenpage[empty]}\jlreq@column@spanning@possibletrue},
      pagebreak / begin_with_odd_page  .code:n = {\def\jlreq@pagebreak{\cleartooddpage[empty]}\jlreq@column@spanning@possibletrue},
      pagebreak / nariyuki             .code:n = {\def\jlreq@pagebreak{}\jlreq@column@spanning@possiblefalse},
      pagestyle .tl_set:N = \l__jlreq_pagestyle_tl,
      % 後々数字を受け付けるようになったりするかもしれないので……
      column_spanning .code:n = {%
        \jlreq@tempatrue % validな入力に対してfalse
        \jlreq@ifempty{##1}{}{%
          \jlreq@ifnumber{##1}{% 数字の時はtrueに回す
            \jlreq@tempafalse
            \def\jlreq@column@spanning{true}%
          }{%
            \str_case_e:nn {##1} {
              {true}{\jlreq@tempafalse\def\jlreq@column@spanning{true}}
              {false}{\jlreq@tempafalse\def\jlreq@column@spanning{false}}
            }%
          }%
        }%
        \ifjlreq@tempa\ClassWarningNoLine{jlreq}{Invalid~input~`##1'~for~column_spanning~in~BlockHeading~#1}\fi
      },
      number .choices:nn = {true,false}{\csname jlreq@number\l_keys_choice_tl\endcsname},
    }%
    \keys_set:nn { BlockHeading:#1 } {
      font = {}, subtitle_font = {},
      indent = {0pt}, end_indent = {0pt}, align = {left}, subtitle_indent = {1\jlreq@zw}, afterindent = {true},
      second_heading_text_indent = {0pt}, after_label_space = {1\jlreq@zw}, 
      pagebreak = {nariyuki}, allowbreak_if_evenpage = {false}, subtitle_break = {true}, column_spanning = {false}, 
      format = {##1##2##3}, label_format = {\@seccntformat{#1}}, subtitle_format = {---##1---}, number = {true},
      pagestyle = {}
    }
    \keys_set:nn { BlockHeading:#1 } {#3}
    \def\jlreq@do{}% 初期化．これに最終処理を入れていく．
    % 入力チェック
    \str_if_eq:VnT \jlreq@column@spanning { true } {
      \jlreq@if{\unless\ifjlreq@column@spanning@possible\fi}{
        \ClassWarningNoLine{jlreq}{column_spanning~can~be~used~only~with~`pagebreak=nariyuki'~or~`pagebreak=clearcolumn'~(in~BlockHeading~#1)}%
        \def\jlreq@column@spanning{false}%
      }{}%
    }%
    % ラベルありフォーマット：前
    \edef\jlreq@pre@format@wlabel{%
      \noexpand\noindent
      \exp_not:o {\jlreq@font}%
      \ifnum 0\ifjlreq@second@text@indent@withlabel 1\fi\ifjlreq@subtitleindent@withlabel 1\fi>0
        \unexpanded{\setbox\jlreq@BlockHeading@start@label@box=\hbox}{\exp_not:o {\jlreq@label@format}}%
        \unexpanded{\xdef\jlreq@BlockHeading@start@labellength{\the\wd\jlreq@BlockHeading@start@label@box}}%
        \unexpanded{\def\jlreq@BlockHeading@start@outputlabel{\box\jlreq@BlockHeading@start@label@box}}%
      \else
        \unexpanded{\xdef\jlreq@BlockHeading@start@labellength{0pt}}%
        \unexpanded{\def\jlreq@BlockHeading@start@outputlabel}{\exp_not:o {\jlreq@label@format}}%
      \fi
    }%
    % ラベルなしフォーマット：前
    \edef\jlreq@pre@format@wolabel{%
      \noexpand\noindent
      \exp_not:o {\jlreq@font}%
      \unexpanded{\xdef\jlreq@BlockHeading@start@labellength{0pt}}%
      \unexpanded{\def\jlreq@BlockHeading@start@outputlabel}{}%
    }%
    % 空き量などの調整を含んだラベル
    \edef\jlreq@label@format@modified{%
      \noexpand\jlreq@BlockHeading@start@outputlabel
      \unexpanded{\inhibitglue\hbox{}}%
      \ifdim\dimexpr\jlreq@after@label@space\relax=\dimexpr 0pt\relax\else
        \noexpand\hspace*{\noexpand\dimexpr\exp_not:o {\jlreq@after@label@space}\noexpand\relax}%
      \fi
    }%
    \edef\jlreq@heading@text@format@wlabel{%
      \ifnum 0\ifdim\jlreq@second@heading@text@indent@wlabel=\dimexpr 0pt\relax\else 1\fi\ifjlreq@second@text@indent@withlabel 1\fi>0
        \unexpanded{\hangindent=\glueexpr}(\exp_not:o {\jlreq@second@heading@text@indent@wlabel})%
          \ifjlreq@second@text@indent@withlabel + (\exp_not:o {\jlreq@after@label@space}) + \unexpanded{\jlreq@BlockHeading@start@labellength}\fi
          \noexpand\relax
      \fi
      \exp_not:o {\jlreq@heading@text@format}%
    }%
    \edef\jlreq@heading@text@format@wolabel{%
      \ifdim\dimexpr\jlreq@second@heading@text@indent@wolabel\relax=\dimexpr 0pt\relax\else
        \unexpanded{\hangindent=\dimexpr}\exp_not:o {\jlreq@second@heading@text@indent@wolabel}\noexpand\relax
      \fi
      \exp_not:o {\jlreq@heading@text@format}%
    }%
    % 副題：ラベルありかなしかはhangindentの扱いだけなので，他はまとめる
    \def\jlreq@make@subtitle@format##1##2{%
      \edef##1{%
        \ifjlreq@subtitle@break
          \noexpand\par
          ##2%
          \unexpanded{\nobreak\noindent}%
        \else
          \ifdim\jlreq@subtitle@indent=\dimexpr 0pt\relax\else
            \noexpand\hspace*{\exp_not:o {\jlreq@subtitle@indent}}%
          \fi
        \fi
        {\exp_not:o {\jlreq@subtitle@font}\exp_not:o {\jlreq@subtitle@format}}%
      }%
    }%
    \jlreq@make@subtitle@format\jlreq@subtitle@format@wlabel{%
      \ifjlreq@subtitleindent@withlabel
        \noexpand\hangafter=0
        \unexpanded{\hangindent=\dimexpr}\noexpand\jlreq@BlockHeading@start@labellength + (\exp_not:o {\jlreq@after@label@space}) + (\exp_not:o {\jlreq@subtitle@indent})\noexpand\relax
      \else
        \ifdim\jlreq@subtitle@indent=\dimexpr 0pt\relax\else
          \noexpand\hangafter=0
          \unexpanded{\hangindent=\dimexpr}\exp_not:o {\jlreq@subtitle@indent}\noexpand\relax
        \fi
      \fi
    }%
    \jlreq@make@subtitle@format\jlreq@subtitle@format@wolabel{%
      \ifdim\jlreq@subtitle@indent=\dimexpr 0pt\relax\else
        \noexpand\hangafter=0
        \unexpanded{\hangindent=\dimexpr}\exp_not:o {\jlreq@subtitle@indent}\noexpand\relax
      \fi
    }%
    \jlreq@heading@make@l@{#1}{#2}{\jlreq@label@format}%
    \tl_put_right:Nx \jlreq@do {\exp_not:o {\jlreq@result}}%
    \jlreq@BlockHeading@gyodori@parsekeyval*[BlockHeading:#1]{#3}{}{}{1}%
    \let\jlreq@spaceset=\jlreq@result
    \edef\jlreq@totalformat{\unexpanded{##1}}%
    \edef\jlreq@totalformat@after{\exp_not:o {\jlreq@afterindent}\noexpand\@afterheading}%
    \if@twocolumn
      \str_if_eq:VnT \jlreq@column@spanning { true }{%
        \def\@tempa##1##2##3{%
          % 前開きが常に入ってしまうので，a:の時は除去する
          \jlreq@iffirsttoken{##1}{a}{\def\jlreq@spaceset{{}{##2}{##3}}}{}%
          \edef\jlreq@totalformat{%
            \unexpanded{\jlreq@if{\if@twocolumn\fi}}{%
              \noexpand\twocolumn[{%
                % 普段自動で入る\topskipと\baselineskipを手動で入れる
                \jlreq@iffirsttoken{##1}{r}{}{\unexpanded{\vskip\topskip\relax}}%
                \unexpanded{####1}%
                \jlreq@iffirsttoken{##2}{r}{}{\unexpanded{\vskip\glueexpr\baselineskip - \topskip\relax}}%
              }]%
            }{%
              \exp_not:o {\jlreq@totalformat}
            }%
          }%
        }%
        \expandafter\@tempa\jlreq@spaceset
        \def\jlreq@totalformat@after{}%
      }%
    \fi
    \edef\jlreq@do{%
      \exp_not:o {\jlreq@do}%
      \noexpand\edef\exp_not:c {jlreq@headingcs@#1}{\noexpand\unexpanded{%
        \noexpand\UseHook{jlreq/heading/before}%
        \noexpand\UseHook{jlreq/heading/before/#1}%
        \exp_not:o {\jlreq@pagebreak}%
        \tl_if_empty:NF \l__jlreq_pagestyle_tl { \exp_not:N \thispagestyle {\exp_not:o { \l__jlreq_pagestyle_tl } } }
        \unexpanded{\jlreq@BlockHeading@start{#1}{#2}}%
        {{\exp_not:o {\jlreq@align}}{\exp_not:o {\jlreq@indent}}{\exp_not:o {\jlreq@end@indent}}\exp_not:o {\jlreq@spaceset}{\exp_not:o {\jlreq@allowbreak@evenpage}}}%
        {\ifjlreq@number\else -\fi}%
        {%
          {%
            {\exp_not:o {\jlreq@label@format}}{\exp_not:o {\jlreq@label@format@modified}}%
            {\exp_not:o {\jlreq@heading@text@format@wlabel}}{\exp_not:o {\jlreq@heading@text@format@wolabel}}%
            {\exp_not:o {\jlreq@subtitle@format@wlabel}}{\exp_not:o {\jlreq@subtitle@format@wolabel}}%
          }%
          {%
            {\exp_not:o {\jlreq@pre@format@wlabel}}{\exp_not:o {\jlreq@pre@format@wolabel}}%
            {\exp_not:o {\jlreq@format}}%
            {}{}%
          }%
        }%
        {{}{\exp_not:o {\jlreq@totalformat}}{\exp_not:o {\jlreq@totalformat@after}}}%
      }}%
      \noexpand\def\exp_not:c {#1}{\exp_not:c {jlreq@headingcs@#1}}%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\NewDocumentCommand{\NewBlockHeading}{ m m +m }{%
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareBlockHeading{#1}{#2}{#3}}%
}
\NewDocumentCommand{\RenewBlockHeading}{ m m +m }{%
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareBlockHeading{#1}{#2}{#3}}%
}
\NewDocumentCommand{\ProvideBlockHeading}{ m m +m }{%
  \@ifundefined{#1}{\DeclareBlockHeading{#1}{#2}{#3}}{}%
}

%.. 別行見出しが連続した場合の処理
% 設定値保存に次のマクロを使う
% \jlreq@BlockHeading@spaces@headingslist
%   : スペースを考慮しないとならない見出しのリスト．,_chapter_section_subsection,_section_subsection,...みたいな感じ
% \jlreq@BlockHeading@spaces@setlist@<見出し名リスト>
%   : 見出し名リストが続いたときの空き関連設定．<見出し名リスト>は_chapter_section_subsectionみたいなやつ．
%     {***}{***}...というリスト．各々の***は次のどれか．
%     最初：全体への指定．{前空き}{後ろ空き}{行数}
%     _{前空き}{後ろ空き}{行数}：見出しに対する指定．先頭が_*の場合は，デフォルト設定をロードしてからということ．
%     それ以外：空き量
%       最初や最後に空き量指定がある場合は，全体への指定に組み込むことにする．
%
% 現在状況保存に以下のマクロを使う
% \jlreq@BlockHeading@spaces@current@sequence
%   : 現在どのような見出しが続いているかリスト．
% \jlreq@BlockHeading@spaces@current@space@<n>
%   : 現在処理中のn番目の見出しに対する空き情報．{前空き}{後ろ空き}{トータル行数}{偶数ページbreak情報}．n=1から始まる．
% \jlreq@BlockHeading@spaces@current@output@<n>
%   : 現在処理中のn番目の見出しの中身．
% \jlreq@BlockHeading@spaces@current@format@<n>
%   : 現在処理中のn番目の見出しのフォーマット．行取りマクロを包み込むようにする．
% \jlreq@BlockHeading@spaces@current@before@<n>
%   : n番目の見出しの前に出すもの
% \jlreq@BlockHeading@spaces@current@after@<n>
%   : n番目の見出しの後ろに出すもの
% \jlreq@BlockHeading@spaces@current@count
%   : 現在いくつ目の連続する見出しを処理しているかのカウンター
\newcount\jlreq@BlockHeading@spaces@current@count
\jlreq@BlockHeading@spaces@current@count=0
\def\jlreq@BlockHeading@spaces@current@sequence{}
\def\jlreq@BlockHeading@spaces@headingslist{}

\NewDocumentCommand{\SetBlockHeadingSpaces} { m } {
  \begingroup
    % 現段階の情報をクリアする
    \def\jlreq@tempa{}% 見出しリスト
    \def\jlreq@tempb{}% 設定リスト \def\jlreq@BlockHeading@spaces@***{{**}{**}...}ってのを入れる
    \jlreq@SetBlockHeadingSpaces#1\jlreq@endmark
    \edef\jlreq@do{%
      \unexpanded{%
        \clist_map_inline:Nn \jlreq@BlockHeading@spaces@headingslist {
          \expandafter\let\csname jlreq@BlockHeading@spaces@setlist@####1\endcsname=\@undefined
        }%
      }%
      \unexpanded{\def\jlreq@BlockHeading@spaces@headingslist}{\exp_not:o {\jlreq@tempa}}%
      \exp_not:o {\jlreq@tempb}%
    }%
  \expandafter\endgroup
  \jlreq@do
}
\def\jlreq@SetBlockHeadingSpaces{% カンマを無視する処理
  \@ifnextchar,{\expandafter\jlreq@SetBlockHeadingSpaces@i\@gobble}{\jlreq@SetBlockHeadingSpaces@i}%
}
\def\jlreq@SetBlockHeadingSpaces@i{%
  \@ifnextchar[{\jlreq@SetBlockHeadingSpaces@ii}{\jlreq@SetBlockHeadingSpaces@ii[]}%
}
\def\jlreq@SetBlockHeadingSpaces@ii[#1]#2{%
  \jlreq@ifendmark{#2}{}{%
    \def\jlreq@headings{}% 見出し名リスト
    \jlreq@BlockHeading@gyodori@parsekeyval[BlockHeadingSpaces]{#1}{}{}{}%
    \let\jlreq@totalset=\jlreq@result% 上の#1に対応する設定
    \def\jlreq@set{}% 個々の設定
    \def\jlreq@lastdimen{}% 最後の寸法
    \def\jlreq@do##1##2##3{%
      \jlreq@ifempty{##1}{\jlreq@tempatrue}{\jlreq@tempafalse}% 前開きが空ならば\jlreq@tempatrue
      \jlreq@ifempty{##2}{\jlreq@tempbtrue}{\jlreq@tempbfalse}% 後ろ開きが空ならば\jlreq@tempbtrue
    }%
    \expandafter\jlreq@do\jlreq@totalset
    \jlreq@SetBlockHeadingSpaces@iii{#2}%
    \tl_put_right:Nx \jlreq@tempa {,\exp_not:o{\jlreq@headings}}% \jlreq@tempaに\jlreq@headingsを追加
    \ifjlreq@tempb
      \ifx\jlreq@lastdimen\@empty\else % 最後が寸法だったので\jlreq@SetBlockHeadingSpaces@totalsetを改変
        \def\jlreq@do##1##2##3{%
          \edef\jlreq@totalset{{\unexpanded{##1}}{r:\exp_not:o {\jlreq@lastdimen}}{\unexpanded{##3}}}%
        }%
        \expandafter\jlreq@do\jlreq@totalset
      \fi
    \else
      \tl_put_right:Nx \jlreq@set{{\exp_not:o {\jlreq@lastdimen}}}
    \fi
    \tl_put_right:Nx \jlreq@tempb {%
      \noexpand\@ifundefined{jlreq@BlockHeading@spaces@setlist@\jlreq@headings}{}{%
        \noexpand\ClassError{jlreq}{The~spaces~for~\jlreq@headings\space is~defined~more~than~once~(in~SetBlockHeadingSpaces)}{\noexpand\@ehc}%
      }%
      \noexpand\def\exp_not:c {jlreq@BlockHeading@spaces@setlist@\jlreq@headings}{{\exp_not:o {\jlreq@totalset}}\exp_not:o {\jlreq@set}}%
    }%
    \jlreq@SetBlockHeadingSpaces
  }%
}

% {}があるのに最初が_で始まっていない場合は蹴る．
\def\jlreq@SetBlockHeadingSpaces@checkdimension#1{%
  \jlreq@SetBlockHeadingSpaces@checkdimension@i#1{\jlreq@uniqtoken}\jlreq@endmark
}
\def\jlreq@SetBlockHeadingSpaces@checkdimension@i#1#{\jlreq@SetBlockHeadingSpaces@checkdimension@ii{#1}}
\def\jlreq@SetBlockHeadingSpaces@checkdimension@ii#1#2#3\jlreq@endmark{%
  \begingroup
    \def\jlreq@tempa{#2}%
    \def\jlreq@tempb{\jlreq@uniqtoken}%
    \ifx\jlreq@tempa\jlreq@tempb\def\jlreq@do{}%
    \else\def\jlreq@do{%
      \ClassError{jlreq}{Invalid~setting~``\unexpanded{#1{#2}}''~is~found,~you~forgot~`_'?~(in~SetBlockHeadingSpaces)}{\@ehc}%
    }\fi
  \expandafter\endgroup
  \jlreq@do
}

\def\jlreq@SetBlockHeadingSpaces@iii#1{%
  \clist_map_variable:nNn {#1} \@tempa {
    \expandafter\jlreq@helper@trim\expandafter{\@tempa}{\@tempa}%
    \str_if_eq:eeTF {\str_head:N \@tempa} {_} {
      \ifx\jlreq@lastdimen\@empty\else\tl_put_right:Nx \jlreq@set {{\exp_not:o {\jlreq@lastdimen}}}\fi%
      \def\jlreq@lastdimen{}%
      \expandafter\jlreq@SetBlockHeadingSpaces@iv\@tempa{\jlreq@endmark}\jlreq@endmark
    }{%
      \expandafter\jlreq@SetBlockHeadingSpaces@checkdimension\expandafter{\@tempa}%
      \ifjlreq@tempa
        % 最初が寸法なので，全体の設定（\jlreq@totalset）に組み込む．
        \def\jlreq@do##1##2##3{%
          \edef\jlreq@totalset{{r:\exp_not:o {\@tempa}}{\unexpanded{##2}}{\unexpanded{##3}}}%
        }%
        \expandafter\jlreq@do\jlreq@totalset
      \else
        \ifx\jlreq@lastdimen\@empty\else\tl_put_right:Nx \jlreq@set {{\exp_not:o {\jlreq@lastdimen}}}\fi
        \let\jlreq@lastdimen=\@tempa
      \fi
    }%
    \jlreq@tempafalse
  }%
}

\def\jlreq@SetBlockHeadingSpaces@iv#1#{%
  \str_set:Nx \l__jlreq_tmpa_str {\@gobble #1}
  \str_if_in:NnT \l__jlreq_tmpa_str {_} {
    \ClassWarning{jlreq}{Unusual~heading~name~`\@gobble #1'~is~found.~You~forgot~a~comma?~(in~SetBlockHeadingSpaces)}%
  }%
  \jlreq@ifendswith{#1}{*}{{%
    \def\@tempa_##1*{\def\@tempa{##1}}%
    \@tempa#1%
    \ClassWarning{jlreq}{The~heading~name~`\@gobble #1'~ends~with~`*'.~Do~you^mean~`_\@tempa{*}'?~(in~SetBlockHeadingSpaces)}%
  }}{}%
  \tl_put_right:Nn \jlreq@headings {#1}%
  \jlreq@SetBlockHeadingSpaces@v
}
\def\jlreq@SetBlockHeadingSpaces@v#1{%
  % 空っぽの場合は{_{r:0pt}{r:0pt}{}}
  \jlreq@ifendmark{#1}{%
    \tl_put_right:Nn \jlreq@set {{_{r:0pt}{r:0pt}{}}}
    \@gobble
  }{%
    \jlreq@iffirsttoken{#1}{*}{% *始まりの場合は{_*{}{}{}}
      \expandafter\jlreq@BlockHeading@gyodori@parsekeyval\expandafter{\@gobble #1}{}{}{}%
      \tl_put_right:Nx \jlreq@set{{_*\exp_not:o {\jlreq@result}}}%
    }{% それ以外の場合は{_{}{}{}}
      \jlreq@BlockHeading@gyodori@parsekeyval{#1}{}{}{}%
      \tl_put_right:Nx \jlreq@set{{_\exp_not:o {\jlreq@result}}}%
    }%
    \jlreq@SetBlockHeadingSpaces@vi
  }%
}
% _節名{設定}の後に何かないかチェック……
\def\jlreq@SetBlockHeadingSpaces@vi#1\jlreq@endmark{%
  \jlreq@ifendmark{#1}{}{{%
    \@temptokena{}%
    \def\@tempb##1##{\@temptokena\expandafter{\the\@temptokena##1}\@tempc}%
    \def\@tempc##1{\jlreq@ifendmark{##1}{}{\@temptokena\expandafter{\the\@temptokena{##1}}\@tempb}}%
    \@tempb#1%
    \ClassWarningNoLine{jlreq}{Extra~setting~`\the\@temptokena'~is~found~in~SetBlockHeadingSpaces,~omitted}
  }}%
}

% 現在の情報に基づき出力
\def\jlreq@BlockHeading@spaces@output{%
  \@ifundefined{jlreq@BlockHeading@spaces@setlist@\jlreq@BlockHeading@spaces@current@sequence}{%
    \jlreq@BlockHeading@spaces@outputwospace
  }{%
    \expandafter\expandafter\expandafter\jlreq@BlockHeading@spaces@output@\csname jlreq@BlockHeading@spaces@setlist@\jlreq@BlockHeading@spaces@current@sequence\endcsname\jlreq@endmark
  }%
}

% 連続スペース情報とか無視して各々の見出しを出力する
\def\jlreq@BlockHeading@spaces@outputwospace{%
  \begingroup
    \jlreq@tempcnta=0
    \def\jlreq@do{}%
    \jlreq@BlockHeading@spaces@outputwospace@
    \jlreq@BlockHeading@spaces@clear
  \expandafter\endgroup
  \jlreq@do
}
\def\jlreq@BlockHeading@spaces@outputwospace@{%
  \ifnum\jlreq@tempcnta<\jlreq@BlockHeading@spaces@current@count
    \advance\jlreq@tempcnta by 1
    \tl_put_right:Nx \jlreq@do {\exp_args:Nc \exp_not:o {jlreq@BlockHeading@spaces@current@before@\the\jlreq@tempcnta}}%
    \edef\jlreq@tempa{%
      \unexpanded{\long\def\jlreq@tempa##1}{\exp_args:Nc \exp_not:o {jlreq@BlockHeading@spaces@current@format@\the\jlreq@tempcnta}}%
    }%
    \jlreq@tempa
    \edef\jlreq@tempb{%
      \noexpand\exp_not:o {\noexpand\jlreq@tempa{%
        \noexpand\jlreq@BlockHeading@start@gyodori
          \exp_args:Nc \exp_not:o {jlreq@BlockHeading@spaces@current@space@\the\jlreq@tempcnta}%
          {\exp_args:Nc \exp_not:o {jlreq@BlockHeading@spaces@current@output@\the\jlreq@tempcnta}}%
      }}%
    }%
    \tl_put_right:Nx \jlreq@do {\jlreq@tempb\exp_args:Nc \exp_not:o {jlreq@BlockHeading@spaces@current@after@\the\jlreq@tempcnta}}%
    \expandafter\jlreq@BlockHeading@spaces@outputwospace@
  \fi
}

\def\jlreq@BlockHeading@spaces@output@#1#2\jlreq@endmark{%
  \def\jlreq@result{}%
  \jlreq@tempcnta=0
  \jlreq@BlockHeading@spaces@output@@#2\jlreq@endmark
  \jlreq@tempatrue % 周りの行取り処理が必要か
  \tl_if_empty:nT {#1} {\jlreq@tempafalse}%
  \tl_if_eq:nnT {#1} {{}{}{}} { \jlreq@tempafalse }
  \edef\jlreq@do{%
    \ifjlreq@tempa
      \unexpanded{\jlreq@BlockHeading@start@gyodori#1}{%
        \exp_not:o {\jlreq@result}%
      }%
    \else
      \exp_not:o {\jlreq@result}%
    \fi
  }%
  \jlreq@BlockHeading@spaces@clear
  \jlreq@do
}
% jlreq@resultに出力すべきものを入れていく
\def\jlreq@BlockHeading@spaces@output@@#1{%
  \jlreq@ifendmark{#1}{}{%
    \str_if_eq:eeTF {\str_head:n {#1}} {_} {
      \advance\jlreq@tempcnta by 1
      \expandafter\jlreq@BlockHeading@spaces@output@@@\expandafter{\@gobble #1}%
    }{%
      \tl_put_right:Nn \jlreq@result {\vskip\glueexpr #1\relax}%
    }%
    \jlreq@BlockHeading@spaces@output@@
  }%
}
\def\jlreq@BlockHeading@spaces@output@@@#1{%
  \edef\jlreq@do{%
    \noexpand\jlreq@BlockHeading@spaces@output@@@@
    \jlreq@iffirsttoken@ignorespaces{#1}{*}{{*}\exp_not:o {\@gobble #1}}{\unexpanded{{}#1}}%
      \exp_args:Nc \exp_not:o {jlreq@BlockHeading@spaces@current@space@\the\jlreq@tempcnta}%
      {\exp_args:Nc \exp_not:o {jlreq@BlockHeading@spaces@current@output@\the\jlreq@tempcnta}}%
  }%
  \jlreq@do
}
% #1: デフォルト値を使うならば*，#2#3#4が設定された値，#5#6#7がデフォルト値，#8は偶数ページの，#9が出力
\def\jlreq@BlockHeading@spaces@output@@@@#1#2#3#4#5#6#7#8{%
  \edef\jlreq@tempa{%
    \unexpanded{\long\def\jlreq@tempa##1}{\exp_args:Nc \exp_not:o {jlreq@BlockHeading@spaces@current@format@\the\jlreq@tempcnta}}%
  }%
  \jlreq@tempa
  \edef\jlreq@tempb{%
    \noexpand\exp_not:o {\noexpand\jlreq@tempa{%
      \noexpand\jlreq@BlockHeading@start@gyodori
      \jlreq@ifempty{#1}{\unexpanded{{#2}{#3}{#4}}}{%
        {\jlreq@ifempty{#2}{\unexpanded{#5}}{\unexpanded{#2}}}%
        {\jlreq@ifempty{#3}{\unexpanded{#6}}{\unexpanded{#3}}}%
        {\jlreq@ifempty{#4}{\unexpanded{#7}}{\unexpanded{#4}}}%
      }\unexpanded{{#8}}%
    }}%
  }%
  \tl_put_right:Nx \jlreq@result {%
    \exp_args:Nc \exp_not:o {jlreq@BlockHeading@spaces@current@before@\the\jlreq@tempcnta}%
    \jlreq@tempb
    \exp_args:Nc \exp_not:o {jlreq@BlockHeading@spaces@current@after@\the\jlreq@tempcnta}%
  }%
}

% 連続見出しスペース調整用のデータをすべてクリアする
\def\jlreq@BlockHeading@spaces@clear{%
  \begingroup
    \jlreq@tempcnta=0
    \@whilenum\jlreq@tempcnta<\jlreq@BlockHeading@spaces@current@count\do{%
      \advance\jlreq@tempcnta by 1
      \expandafter\global\expandafter\let\csname jlreq@BlockHeading@spaces@current@space@\the\jlreq@tempcnta\endcsname=\@undefined
      \expandafter\global\expandafter\let\csname jlreq@BlockHeading@spaces@current@output@\the\jlreq@tempcnta\endcsname=\@undefined
      \expandafter\global\expandafter\let\csname jlreq@BlockHeading@spaces@current@before@\the\jlreq@tempcnta\endcsname=\@undefined
      \expandafter\global\expandafter\let\csname jlreq@BlockHeading@spaces@current@after@\the\jlreq@tempcnta\endcsname=\@undefined
    }%
    \gdef\jlreq@BlockHeading@spaces@current@sequence{}%
    \global\jlreq@BlockHeading@spaces@current@count=0
  \endgroup
}

%.. 同行見出し
% {1 = 命令名}{2 = レベル}{3 = */-}{4 = ラベルフォーマット}{5 = ラベルありフォーマット}{6 = ラベルなしフォーマット}
% 4,5は見出し文字列が#1になる．
\long\def\jlreq@RuninHeading@start#1#2#3#4#5#6{%
  \edef\jlreq@RuninHeading@start@format@label{\unexpanded{#4}}%
  \edef\jlreq@RuninHeading@start@format@wlabel{\unexpanded{#5}}%
  \edef\jlreq@RuninHeading@start@format@wolabel{\unexpanded{#6}}%
  \@ifstar{\@dblarg{\jlreq@RuninHeading@start@{#1}{#2}{*}}}{\@dblarg{\jlreq@RuninHeading@start@{#1}{#2}{#3}}}%
}
% {1 = 命令名}{2 = レベル}{3 = */-}{4 = running head}{5 = 見出し}
\long\def\jlreq@RuninHeading@start@#1#2#3[#4]#5{%
  \edef\jlreq@do{\unexpanded{\jlreq@RuninHeading@start@@{#1}{#2}{#3}{#4}{#5}}{\exp_not:o {\jlreq@RuninHeading@start@format@label}}{\exp_not:o {\jlreq@RuninHeading@start@format@wlabel}}{\exp_not:o {\jlreq@RuninHeading@start@format@wolabel}}}%
  \jlreq@do
}
% {1 = 命令名}{2 = レベル}{3 = *}{4 = running head}{5 = 見出し}{6 = ラベルフォーマット}{7 = ラベルありフォーマット}{8 = ラベルなしフォーマット}
\edef\jlreq@tempa{%
  \unexpanded{\long\def\jlreq@RuninHeading@start@@#1#2#3#4#5#6#7#8}{%
    \unexpanded{%
    \if@noskipsec\leavevmode\fi
    \begingroup
      \def\jlreq@do{\global\@noskipsectrue}%
      \ifnum0\jlreq@ifempty{#3}{}{1}\ifnum #2>\c@secnumdepth 1\fi>0
        \def\jlreq@tempa##1{#8}%
      \else
        \tl_put_right:Nn \jlreq@do {\refstepcounter{#1}}%
        \def\jlreq@tempa##1{#7}%
      \fi
      \par}%
      \unexpanded{\tl_put_right:Nx \jlreq@do}{%
        \unexpanded{\noexpand\everypar}{%
          \unexpanded{%
          \noexpand\if@noskipsec
            \unexpanded{\global\@noskipsecfalse}%
            \unexpanded{{\setbox\jlreq@tempboxa\lastbox}}%
            \noexpand\begingroup
              \exp_not:o {\jlreq@tempa{#5}}%
              \exp_not:c {jlreq@heading@maketoc@#1}\unexpanded{{#3}{#6}{#4}}%
            \noexpand\endgroup
            \noexpand\inhibitglue
          \noexpand\else
            \unexpanded{\everypar{}}%
          }%
            \ifx l\jlreq@engine\else
              \unexpanded{\unexpanded{\let\jlreq@hook@everypar\jlreq@openbracket@hook}}%
            \fi
         \unexpanded{\noexpand\fi}%
        }%
      }%
    \unexpanded{\expandafter\endgroup
    \jlreq@do
    \ignorespaces}%
  }
}
\jlreq@tempa

% \DeclareRuninHeading{命令名}{レベル}{設定}
\NewDocumentCommand { \DeclareRuninHeading } { m m +m } {
  \__jlreq_declare_runin_heading:nnn {#1} {#2} {#3}
}
\cs_set:Nn \__jlreq_declare_runin_heading:nnn {
  \hook_provide:n { jlreq/heading/before/#1 }
  \def\jlreq@do{\@removeelement{#1}}%
  \seq_put_right:Nn \l__jlreq_heading_allheadings_seq {#1}
  \seq_remove_duplicates:N \l__jlreq_heading_allheadings_seq
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\edef\csname jlreq@heading@setting@#1\endcsname{\unexpanded{#3}}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewRuninHeading}%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \@ifundefined{l@#1}{\expandafter\def\csname l@#1\endcsname{\@dottedtocline{#2}{0\jlreq@zw}{2\jlreq@zw}}}{}%
  \jlreq@heading@make@maketoc{#1}{#2}%
  \group_begin:
    \def\jlreq@label@font{}%
    \keys_define:nn { RuninHeading:#1 } {
      font .tl_set:N = \l__jlreq_font_tl,
      indent .tl_set:N = \l__jlreq_indent_tl,
      label_format .tl_set:N = \l__jlreq_label_format_tl,
      after_label_space .tl_set:N = \l__jlreq_after_label_space_tl,
      after_space .tl_set:N = \l__jlreq_after_space_tl,
      number .bool_set:N = \l__jlreq_number_bool,
    }
    \keys_set:nn { RuninHeading:#1 } {
      font = {\normalfont\normalsize},
      indent = {0pt},
      label_format = {\@seccntformat{#1}},
      after_label_space = {1\jlreq@zw},
      after_space = {1\jlreq@zw},
      number = true
    }
    \keys_set:nn { RuninHeading:#1 } {#3}
    \dim_compare:nT { \l__jlreq_after_space_tl < 0pt } {
      \ClassWarning{jlreq}{after_space~in~Runin~Heading~#1~should~be~not~negative}
    }
    \dim_compare:nT { \l__jlreq_after_label_space_tl < 0pt } {
      \ClassWarning{jlreq}{after_label_space~in~Runin~Heading~#1~should~be~not~negative}
    }
    \bool_set:Nn \l__jlreq_indent_zero_bool { \skip_if_eq_p:nn { \l__jlreq_indent_tl } { 0pt } }
    \bool_set:Nn \l__jlreq_after_space_zero_bool { \skip_if_eq_p:nn { \l__jlreq_after_space_tl } { 0pt } }
    \bool_set:Nn \l__jlreq_after_label_space_zero_bool { \skip_if_eq_p:nn { \l__jlreq_after_label_space_tl } { 0pt } }
    \tl_set:Nx \l__jlreq_format_wlabel_tl {{
      \bool_if:NF \l__jlreq_indent_zero_bool { \exp_not:N \skip_horizontal:n { \exp_not:o {\l__jlreq_indent_tl} } }
      \exp_not:o { \l__jlreq_font_tl }
      \exp_not:o { \l__jlreq_label_format_tl }
      \bool_if:NF \l__jlreq_after_space_zero_bool { \exp_not:N \skip_horizontal:n { \exp_not:o {\l__jlreq_after_label_space_tl} } }
      ####1%
      \bool_if:NF \l__jlreq_after_space_zero_bool { \exp_not:N \skip_horizontal:n { \exp_not:o {\l__jlreq_after_space_tl} } }
    }}%
    \tl_set:Nx \l__jlreq_format_wolabel_tl {{
      \bool_if:NF \l__jlreq_indent_zero_bool { \exp_not:N \skip_horizontal:n { \exp_not:o {\l__jlreq_indent_tl} } }
      \exp_not:o { \l__jlreq_font_tl }
      ####1%
      \bool_if:NF \l__jlreq_after_space_zero_bool { \exp_not:N \skip_horizontal:n {\exp_not:o {\l__jlreq_after_space_tl} } }
    }}%
    \jlreq@heading@make@l@{#1}{#2}{\l__jlreq_label_format_tl}%
    \cs_set:Nx \l__jlreq_do: {
      \exp_not:o { \jlreq@result }
      % パラメータトークンを含むので，\edefして\unexpandedで包む
      \noexpand\edef\exp_not:c {#1}{%
        \noexpand\unexpanded{%
          \exp_not:N \UseHook{jlreq/heading/before}%
          \exp_not:N \UseHook{jlreq/heading/before/#1}
          \exp_not:n {\jlreq@RuninHeading@start{#1}{#2}}
            {\bool_if:NF \l__jlreq_number_bool {-}}
            {\exp_not:o {\l__jlreq_label_format_tl}}
            {\exp_not:o {\l__jlreq_format_wlabel_tl}}
            {\exp_not:o {\l__jlreq_format_wolabel_tl}}
        }%
      }%
    }%
  \exp_after:wN \group_end:
  \l__jlreq_do:
}

\NewDocumentCommand{\NewRuninHeading}{ m m +m }{
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareRuninHeading{#1}{#2}{#3}}%
}
\NewDocumentCommand{\RenewRuninHeading}{ m m +m }{%
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareRuninHeading{#1}{#2}{#3}}%
}
\NewDocumentCommand{\ProvideRuninHeading}{ m m +m }{%
  \@ifundefined{#1}{\DeclareRuninHeading{#1}{#2}{#3}}{}%
}

%.. 窓見出し
\cs_set:Nn \__jlreq_CutinHeading_start:nnnnnnn {
  \if@noskipsec\leavevmode\fi
  \par
  \int_compare:nTF { \hangafter=1 } {
    \__jlreq_CutinHeading_start_aux:nnnnnn{#2}{#3}{#4}{#5}{#6}{#7}%
  }{%
    \ClassError{jlreq}{Can~not~use~\expandafter\string\csname#1\endcsname\space here}{\@ehc}%
  }%
}
% 1 = 書式指定，2 = インデント, 3 = 見出しと本文の間, 4 = これを越えたら二行以上，5 = これを越えたら三行以上，6 = テキスト
\cs_set:Nn \__jlreq_CutinHeading_start_aux:nnnnnn{%
  % 一行で処理したときの見出し長さを計測
  \group_begin:
    \hbox_set:Nn \l_jlreq_tmpa_box {#1#6}
    \dim_set:Nn \l_jlreq_tmpa_dim { \box_wd:N \l_jlreq_tmpa_box}
    % 何行必要かを\l__jlreq_cutinheading_linecount_tlに入れる
    \dim_compare:nTF { \l_jlreq_tmpa_dim > #5} {
      \tl_set:Nn \l__jlreq_cutinheading_linecount_tl {3}
    }{
      \dim_compare:nTF { \l_jlreq_tmpa_dim > #4 }{
        \tl_set:Nn \l__jlreq_cutinheading_linecount_tl {2}
      } { \tl_set:Nn \l__jlreq_cutinheading_linecount_tl {1} } }
    % \l_jlreq_tmpa_dimが実際の一行の長さに近い
    \dim_set:Nn \l_jlreq_tmpa_dim { \l_jlreq_tmpa_dim / \l__jlreq_cutinheading_linecount_tl }
    % \l_jlreq_tmpb_boxに見出し部分を，\l__jlreq_cutinheading_linecount_tlに見出し自身に何行使うかを入れる
    \int_compare:nTF { \l__jlreq_cutinheading_linecount_tl = 1 }{
      \vbox_set:Nn \l_jlreq_tmpb_box {\parindent=0pt\rightskip=0pt\leftskip=0pt\hbox_unpack_drop:N \l_jlreq_tmpa_box}
      \tl_set:Nn \l__jlreq_cutinheading_linecount_tl {2}
    }{
      \jlreq@inlinenote@determinelength{#6}{#1}{}{\l__jlreq_cutinheading_linecount_tl}{\l__jlreq_cutinheading_linecount_tl}{\l_jlreq_tmpa_dim}{\linewidth}%
      \box_set_eq:NN \l_jlreq_tmpb_box \jlreq@resultbox
      \tl_set:Nn \l__jlreq_cutinheading_linecount_tl {3}
    }
    % 普通の一行の高さ/深さに合わせて見出しのボックスを作る
    \setbox\l_jlreq_tmpa_box =\vtop to \dimexpr\numexpr\l__jlreq_cutinheading_linecount_tl - 1\relax\baselineskip + 1\jlreq@zh\relax{\skip_vertical:n {0pt~plus~1fill~minus~1fill} \box_use_drop:N \l_jlreq_tmpb_box \skip_vertical:n {0pt~plus~1fill~minus~1fill}}%
    % 高さを通常の一行のそれにする
    \hbox_set:Nn \l_jlreq_tmpc_box {阿}
    \box_set_dp:Nn \l_jlreq_tmpa_box { \box_ht:N \l_jlreq_tmpa_box + \box_dp:N \l_jlreq_tmpa_box - \box_ht:N \l_jlreq_tmpc_box }
    \box_set_ht:Nn \l_jlreq_tmpa_box { \box_ht:N \l_jlreq_tmpc_box }
    \noindent
    \hspace*{#2}%
    \box_use:N \l_jlreq_tmpa_box
    \hspace*{#3}%
    % でかい見出しボックスの分をキャンセルする空きを入れる
    % \baselineskip - box_ht:N \l_jlreq_tmpc_boxはTeXが挿入するスキップの分
    \cs_set:Nx \l__jlreq_do:{
      \exp_not:N \par
      \exp_not:N \skip_vertical:n {\dim_eval:n {-\box_ht:N \l_jlreq_tmpa_box - \box_dp:N \l_jlreq_tmpa_box - \baselineskip + \box_ht:N \l_jlreq_tmpc_box}}
      \exp_not:N\hangindent= \dim_eval:n {#2 + \box_wd:N \l_jlreq_tmpa_box + #3} \exp_not:N \relax
      \exp_not:N\hangafter=-\l__jlreq_cutinheading_linecount_tl\relax
    }%
  \exp_after:wN \group_end:
  \l__jlreq_do:
  \prevdepth=0pt\relax
  % 改段落が起こっても\hang****をキープするように\parを書き換えておく（終わったら元に戻す）．
  \def\par{%
    \ifvmode\jlreq@tempatrue\else\jlreq@tempafalse\fi
    \jlreq@tempcnta=\hangafter\relax
    \jlreq@tempdima=\hangindent\relax
    \@@par
    \ifjlreq@tempa\else\advance\jlreq@tempcnta by \prevgraf\relax\fi
    \ifnum\jlreq@tempcnta<0
      \hangafter=\jlreq@tempcnta\relax
      \hangindent=\jlreq@tempdima\relax
    \else
      \@restorepar
    \fi
  }%
  \@afterindentfalse
  \@afterheading
  \ignorespaces
}

\NewDocumentCommand{\DeclareCutinHeading}{ m m +m }{
  \hook_provide:n { jlreq/heading/before/#1 }
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}
  \expandafter\def\csname jlreq@heading@setting@#1\endcsname{#3}
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewCutinHeading}
  \group_begin:
    \keys_define:nn { CutinHeading:#1 } {
      font .tl_set:N = \l__jlreq_fontcommand_tl,
      onelinemax .tl_set:N = \l__jlreq_onelinemax_tl,
      twolinemax .tl_set:N = \l__jlreq_twolinemax_tl,
      indent .tl_set:N = \l__jlreq_indent_tl,% 0pt
      after_space .tl_set:N = \l__jlreq_after_space_tl,
    }
    \keys_set:nn { CutinHeading:#1 } {
      font = { \sffamily\gtfamily\bfseries },
      onelinemax = { 6\jlreq@zw },
      twolinemax = { 20\jlreq@zw } ,
      indent = { 0pt },
      after_space = { 1\jlreq@zw }
    }
    \keys_set:nn { CutinHeading:#1 } {#3}
    \bool_if:nT { \dim_compare_p:n {\l__jlreq_after_space_tl < 0.99\jlreq@zw} || \dim_compare_p:n { \l__jlreq_after_space_tl > 2.01\jlreq@zw } }{
      \jlreq@note{窓見出しと本文との空き量は，基本版面の文字サイズの全角以上，2倍未満とする~(4.1.10.c)．}%
    }{}%
    \cs_set:Nx \l__jlreq_do: {
      \exp_not:N \DeclareDocumentCommand \exp_not:c {#1} {m} {
        \exp_not:N \UseHook{jlreq/heading/before}%
        \exp_not:N \UseHook{jlreq/heading/before/#1}%
        \exp_not:N \__jlreq_CutinHeading_start:nnnnnnn{#1}{\exp_not:o \l__jlreq_fontcommand_tl}{\exp_not:o \l__jlreq_indent_tl}{\exp_not:o \l__jlreq_after_space_tl}{\exp_not:o \l__jlreq_onelinemax_tl}{\exp_not:o \l__jlreq_twolinemax_tl}{####1}
      }
    }
  \exp_after:wN \group_end:
  \l__jlreq_do:
}
\NewDocumentCommand{\NewCutinHeading} { m m +m } {%
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareCutinHeading{#1}{#2}{#3}}%
}
\NewDocumentCommand{\RenewCutinHeading} { m m +m } {%
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareCutinHeading{#1}{#2}{#3}}%
}
\NewDocumentCommand{\ProvideCutinHeading} { m m +m } {%
  \@ifundefined{#1}{\DeclareCutinHeading{#1}{#2}{#3}}{}%
}

\NewDocumentCommand{\ModifyHeading}{m +m}{
  \@ifundefined { jlreq@heading@setting@#1 } { \ClassError{jlreq}{Unknown~heading:~#1}{\@ehc} } {}
  \group_begin:
    \tl_set:Nn \l_jlreq_tmpa_tl {#2}
    \str_set:Nn \l_jlreq_tmpa_str {#2}
    \str_case_e:nn { \jlreq@HeadingType {#1} } {
      { BlockHeading } {
        \bool_set_false:N \l_jlreq_tmpa_bool
        \str_if_in:NnT \l_jlreq_tmpa_str { before_space=  } { \bool_set_true:N \l_jlreq_tmpa_bool }
        \str_if_in:NnT \l_jlreq_tmpa_str { before_space~= } { \bool_set_true:N \l_jlreq_tmpa_bool }
        \bool_if:NT \l_jlreq_tmpa_bool {\tl_put_left:Nn \l_jlreq_tmpa_tl {before_lines={},} }
        \bool_set_false:N \l_jlreq_tmpa_bool
        \str_if_in:NnT \l_jlreq_tmpa_str { after_space=  } { \bool_set_true:N \l_jlreq_tmpa_bool }
        \str_if_in:NnT \l_jlreq_tmpa_str { after_space~= } { \bool_set_true:N \l_jlreq_tmpa_bool }
        \bool_if:NT \l_jlreq_tmpa_bool {\tl_put_left:Nn \l_jlreq_tmpa_tl {after_lines={},}}
      }
    }
    \cs_set:Nx \l_jlreq_do: {
      \exp_args:Nc \exp_not:o { jlreq@heading@type@#1 }
      { \exp_not:n { #1 } }
      { \exp_args:Nc \exp_not:o { jlreq@heading@level@#1 } }
      { \exp_args:Nc \exp_not:o { jlreq@heading@setting@#1 },\exp_not:V \l_jlreq_tmpa_tl }
    }
  \exp_after:wN \group_end:
  \l_jlreq_do:
}
% 見出し#1をマクロ#2に保存する
\NewDocumentCommand{\SaveHeading}{ m m }{%
  \@ifundefined{jlreq@heading@setting@#1}{\ClassError{jlreq}{Unknown~heading:~#1}{\@ehc}}{}%
  \edef#2{%
    \exp_args:Nc \exp_not:o {jlreq@heading@type@#1}{\unexpanded{#1}}{\exp_args:Nc \exp_not:o {jlreq@heading@level@#1}}{\exp_args:Nc \exp_not:o {jlreq@heading@setting@#1}}%
  }%
}

\def\jlreq@keepbaselineskip#1{%
  \begingroup
    \edef\jlreq@do{\unexpanded{#1}\noexpand\baselineskip=\the\baselineskip}%
  \expandafter\endgroup
  \jlreq@do
}

\def\jlreq@HeadingType#1{%
  \ifcsname jlreq@heading@type@#1\endcsname
    \jlreq@HeadingType@{#1}{\RenewTobiraHeading}{TobiraHeading}{%
    \jlreq@HeadingType@{#1}{\RenewBlockHeading}{BlockHeading}{%
    \jlreq@HeadingType@{#1}{\RenewRuninHeading}{RuninHeading}{%
    \jlreq@HeadingType@{#1}{\RenewCutinHeading}{CutinHeading}{%
    UnknownHeading}}}}%
  \else
    UndefinedHeading%
  \fi
}
\def\jlreq@HeadingType@#1#2{%
  \jlreq@if{\expandafter\expandafter\expandafter\ifx\csname jlreq@heading@type@#1\endcsname#2\fi}%
}

% 全ての見出しにマクロ#1を適用する．
\def\jlreq@heading@execmacro@toallheadings#1{%
  \seq_map_inline:Nn \l__jlreq_heading_allheadings_seq { #1{##1} }
}

\def\jlreq@clearheadingmarks#1{%
  \@ifundefined{#1mark}{}{%
    \expandafter\let\csname#1mark\endcsname=\@gobble
  }%
}

%.. カウンターの定義（見出し本体はこのファイルの末尾で）
\setcounter{secnumdepth}{3}
\newcounter{part}
\str_if_eq:VnTF \jlreq@article@type { article } 
  { \newcounter{section} }
  { \newcounter{chapter}\newcounter{section}[chapter] }
\newcounter{subsection}[section]
\newcounter{subsubsection}[subsection]
\newcounter{paragraph}[subsubsection]
\newcounter{subparagraph}[paragraph]
\renewcommand*{\@seccntformat}[1]{\csname the#1\endcsname}


%. 注
% 文字サイズは6ポイントくらい（4.2.3.a）とりあえす\scriptsize
%.. 合印（4.2.3）
\newcommand*{\jlreq@referencemark@format}[1]{#1}
\newif\ifjlreqadjustreferencemark
\jlreqadjustreferencemarktrue
\keys_define:nn { jlreqsetup } {
  reference_mark .choice:,
  reference_mark / inline .code:n = {
    \def\jlreq@referencemark{#1}
    \def\jlreq@notemark##1{%
      \jlreq@ifydir{%
        \hbox{}\hbox{\@textsuperscript{\normalfont\jlreq@referencemark@format{##1}}}\hbox{}%
      }{%
        \setbox\@tempboxa=\hbox{\scriptsize\jlreq@referencemark@format{##1}}%
        \raise\dimexpr.5\jlreq@gol - \ht\@tempboxa\relax\box\@tempboxa
      }%
    }
    \def\jlreq@hook@prenote{\inhibitglue}
    % 後ろ側に始め括弧類（cl-01）が配置される場合を除いて，ベタ組（4.2.3，二つ目のc，三つ目のb）．
    \def\jlreq@hook@postnote{\futurelet\jlreq@nextchar\jlreq@postnote@checkopenbracket}%
    \def\@tempa{}
    \def\jlreq@do##1{\jlreq@ifendmark{##1}{}{\tl_put_right:Nn \@tempa {\ifx\jlreq@tempb##11\fi}\jlreq@do}}
    \expandafter\jlreq@do\jlreq@charlist@openingbrackets\jlreq@endmark
    \edef\jlreq@postnote@checkopenbracket{%
      \unexpanded{%
        \jlreq@getfirsttoken@expandmacros{\jlreq@nextchar}{\jlreq@tempa}%
        \expandafter\let\expandafter\jlreq@tempb\jlreq@tempa
      }%
      \noexpand\jlreq@if{\noexpand\ifnum 0\exp_not:o {\@tempa}>0~\noexpand\fi}{}{\noexpand\inhibitglue}%
    }
  },
  reference_mark / interlinear .code:n = {
    \def\jlreq@referencemark{#1}
    \def\jlreq@notemark##1{{%
      \setbox\@tempboxa=\hbox{\scriptsize\jlreq@referencemark@format{##1}}%
      \@tempdima=\wd\@tempboxa
      % 行頭に来たときに頭を天にそろえる処理．
      \ifjlreqadjustreferencemark
        \jlreq@savepos@for@rest@linewidth
        \ifdim\jlreq@current@linewidth<\wd\@tempboxa
          \@tempdima=\jlreq@current@linewidth
        \fi
      \fi
      \setbox\jlreq@tempboxb=\hbox{阿}%
      \setbox\jlreq@tempboxa=\hbox to\z@{\hskip-\@tempdima\raise\dimexpr\ht\jlreq@tempboxb + \dp\@tempboxa\relax\box\@tempboxa\hss}%
      \dp\jlreq@tempboxa=0pt\ht\jlreq@tempboxa=0pt\box\jlreq@tempboxa%
    }}%
    \ifx l\jlreq@engine
      \def\jlreq@hook@prenote{%
        \jlreq@lastnodechar=\lastnodechar\relax
        \ifnum\jlreq@lastnodechar>-1~\inhibitglue\fi
      }
    \else
      % (u)platexの時は代入すると\inhibitglueが効かなくなる
      \def\jlreq@hook@prenote{%
        \ifnum\lastnodechar>-1~\inhibitglue\fi
        \jlreq@lastnodechar=\lastnodechar\relax
      }
    \fi
    \def\jlreq@hook@postnote{\jlreq@fixjfm}
  }
}
% \@footnotemarkをシンプルなものにする
\def\jlreq@setdefaultnotemark#1#2{%
  \def#1{%
    \leavevmode
    \ifhmode\edef\@x@sf{\the\spacefactor}\nobreak\fi
    #2%
    \ifhmode\spacefactor\@x@sf\fi
    \relax}%
}
\jlreq@setdefaultnotemark\@footnotemark\@makefnmark

%.. 脚注（4.2.5）
% （縦書きの時は傍注，4.2.6）
% 罫線の前は行間分，最大＋文字サイズ分伸びる（4.2.5.g）
\setlength{\skip\footins}{\dimexpr\baselineskip - 1\jlreq@gol \relax plus 1\jlreq@gol}
% 罫線の長さは，基本版面で設定した行長にもよるが，行長の1/3くらいにする．
\def\jlreq@footnote@rulewidth{.333\textwidth}
\begingroup
  \footnotesize
  \edef\jlreq@do{
    \unexpanded{\setlength{\footnotesep}}{\the\dimexpr .7\baselineskip\relax}% 何でかわからん……
    \unexpanded{\def\footnoterule}{%
      % この罫線は，表罫（おもてけい）とする．
      \unexpanded{\hrule width \jlreq@footnote@rulewidth height \jlreq@omotekeiwidth}%
      % 脚注の行間よりやや広くする（4.2.5.f）
      \noexpand\kern\the\dimexpr 1.5\dimexpr\baselineskip - 1\jlreq@zh\relax\relax
    }
  }
\expandafter\endgroup
\jlreq@do

% インデントの計算：脚注の長さが文字の整数倍になるように字下げする（4.2.5.b）
\keys_define:nn { jlreqsetup } {
  footnote_indent .code:n = {
    \bool_if:nT { \legacy_if_p:n { @tate } && \dim_compare_p:n { #1 = 0pt } } {
      \jlreq@note{脚注は，一般にその前に区切りのための罫線を挿入するので，字下げは行わなくてよい（4.2.5.b）．}
    }
    \begingroup
      \footnotesize
      \jlreq@footnoteindent=\dimexpr#1\relax
      \@tempdima=\dimexpr\textwidth - \jlreq@footnoteindent\relax
      \@tempdimb=1\jlreq@zw
      \divide\@tempdima\@tempdimb \multiply\@tempdima\@tempdimb
      \edef\jlreq@do{\noexpand\jlreq@footnoteindent=\the\dimexpr\textwidth - \@tempdima\relax}%
    \expandafter\endgroup
    \jlreq@do
  }
}

\newcommand{\@makefntext}[1]{\jlreq@makefntext{#1}}
\keys_define:nn { jlreqsetup } {
  footnote_second_indent .code:n = {
    \legacy_if:nF { @tate }{
      \bool_if:nF {
        ( \dim_compare_p:n {  0.99\jlreq@zw < #1 } && \dim_compare_p:n { #1 < 1.01\jlreq@zw  } ) ||
        ( \dim_compare_p:n { -1.01\jlreq@zw < #1 } && \dim_compare_p:n { #1 < -0.99\jlreq@zw } )
      }{\jlreq@note{脚注が2行以上となった場合，脚注の2行目以下の字下げを1行目より，脚注の文字サイズの全角アキとするか，逆に，1行目の字下げを2行目より，脚注の文字サイズの全角アキとする~(4.2.5.d)．}}
    }
    \dim_compare:nTF { #1 < 0pt } {
      \def\jlreq@makefntext{}
    }{
      \def\jlreq@makefntext{\addtolength{\leftskip}{\glueexpr #1\relax}}
    }
    \long\edef\jlreq@makefntext##1{\exp_not:o {\jlreq@makefntext}%
      \unexpanded{%
        \addtolength{\leftskip}{\jlreq@footnoteindent}%
        \parindent=1\jlreq@zw
        \noindent
        \hskip-\glueexpr #1\relax
        \jlreq@referencemark@format{\@thefnmark}%
        \hskip\glueexpr 1\jlreq@zw\relax
      }##1%
    }
  }
}

\keys_define:nn { jlreqsetup } { footnotetext_indent .code:n = {\ClassWarningNoLine{jlreq}{footnotetext_indent~was~removed} } }

\ifx l\jlreq@engine
  \fnfixbottomtrue
\fi

% \footnoteと\footnotemarkの前後に\jlreq@hook@prenote/\jlreq@hook@postnoteを入れる
\jlreq@saveoriginalcs{footnote}
\jlreq@saveoriginalcs{footnotemark}
\long\def\jlreq@footnotetext@for@footnote[#1]#2{%
  \def\jlreq@result{\footnotetext[#1]{#2}}%
}
\def\footnote{%
  \jlreq@footnote{\footnote}{\footnotemark}{\jlreq@footnotetext@for@footnote}%
}
\def\jlreq@footnote#1#2#3{%
  \jlreq@hook@prenote
  \@ifnextchar[{\jlreq@footnote@impl@woption{#1}{#2}{#3}}{\jlreq@footnote@impl@wooption{#1}{#2}{#3}}%
}
\def\footnotemark{%
  \jlreq@hook@prenote
  \@ifnextchar[{\jlreq@footnotemark@impl@woption}{\jlreq@footnotemark@impl@wooption}%
}
\long\def\jlreq@footnotemark@impl@woption[#1]{%
  \jlreq@useoriginalcs{footnotemark}[#1]%
  \jlreq@hook@postnote
}
\long\def\jlreq@footnotemark@impl@wooption{%
  \jlreq@useoriginalcs{footnotemark}%
  \jlreq@hook@postnote
}
\def\jlreq@restore@original@footnotes{%
  \let\jlreq@temporary@saved@footnote=\footnote
  \let\jlreq@temporary@saved@footnotemark=\footnotemark
  \let\jlreq@temporary@saved@footnotetext=\footnotetext
  \jlreq@restoreoriginalcs{\footnote}%
  \jlreq@restoreoriginalcs{\footnotemark}%
  \jlreq@restoreoriginalcs{\footnotetext}%
}
\def\jlreq@restore@jlreq@footnotes{%
  \let\footnote=\jlreq@temporary@saved@footnote
  \let\footnotemark=\jlreq@temporary@saved@footnotemark
  \let\footnotetext=\jlreq@temporary@saved@footnotetext
}

\bool_if:nTF { \legacy_if_p:n { @tate } && (\legacy_if_p:n { @twoside } || \legacy_if_p:n { @twocolumn }) }{
  % 縦組の傍注は，その見開き内に付いている合印に対応する注を，奇数ページの左端にそろえて配置する．多段組では最下段の左端にそろえて配置する．（4.2.6.a）
  % 必要ならば\footnoteを\footnotemarkと\footnotetextにわけ，\footnotetextをアウトプット時まで遅延することで実現する．
  \def\jlreq@footnote@delayfootnoteslist{}
  \def\jlreq@hook@@opcol{%
    \expandafter\gdef\expandafter\jlreq@footnote@delayfootnoteslist\expandafter{\expandafter}%
    \jlreq@footnote@delayfootnoteslist
  }
  \tl_put_left:Nn \@opcol{\jlreq@hook@@opcol}
  % \jlreq@footnote@delayfootnote@delay#1#2：#1ページ目に#2を出す
  % \jlreq@footnote@delayfootnote@page：何ページ目に\footnotetextを入れるかを\jlreq@resultcntに入れる．その場での場合は-1．
  \if@twocolumn
    \if@twoside
      \def\jlreq@footnote@delayfootnote@page{%
        \jlreq@setcurrentpage
        \jlreq@resultcnt=\numexpr\jlreq@currentpage\ifodd\jlreq@currentpage\else + 1\fi\relax
        % このページに表示＆上の段処理済みだと\output内では間に合わない
        \ifnum\jlreq@resultcnt=\value{page}\if@firstcolumn\else\jlreq@resultcnt=-1~\fi\fi
      }
    \else
      \def\jlreq@footnote@delayfootnote@page{%
        \jlreq@setcurrentpage
        \jlreq@resultcnt=\numexpr\jlreq@currentpage\relax
        \ifnum\jlreq@resultcnt=\value{page}\if@firstcolumn\else\jlreq@resultcnt=-1~\fi\fi
      }
    \fi
    \long\def\jlreq@footnote@delayfootnote@delay#1#2{%
      % 二段組みの場合は上段を組んだ直後に\footnotetextを挿入（そのページの下段に入る）
      \jlreq@if{\ifnum 0\if@firstcolumn\else 1\fi\ifnum#1>\value{page}1\fi>0~\fi}{%
        \tl_gput_right:Nx \jlreq@footnote@delayfootnoteslist {\exp_not:n { \jlreq@footnote@delayfootnote{#1}{#2} } }
      }{#2}%
    }
  \else
    \def\jlreq@footnote@delayfootnote@page{%
      \jlreq@setcurrentpage
      \jlreq@if{\ifodd\jlreq@currentpage\relax\fi}{%
        \jlreq@resultcnt=-1
      }{%
        \jlreq@resultcnt=\numexpr\jlreq@currentpage+1\relax
      }%
    }
    \long\def\jlreq@footnote@delayfootnote@delay#1#2{%
      % 一段組の場合はその前のページを組んだ直後に\footnotetextを挿入．
      \jlreq@if{\ifnum\numexpr#1 - 1\relax>\value{page}~\fi}{%
        \tl_gput_right:Nx \jlreq@footnote@delayfootnoteslist { \exp_not:n {\jlreq@footnote@delayfootnote{#1}{#2} } }
      }{#2}%
    }
  \fi
  \long\def\jlreq@footnote@delayfootnote@immediate#1#2{%
    \jlreq@if{\ifnum #1<\jlreq@currentpage\relax\fi}{%
      \tl_gput_right:Nx \jlreq@footnote@delayfootnoteslist{ \exp_not:n { \jlreq@footnote@delayfootnote{#1}{#2} } }
    }{#2}%
  }
  \let\jlreq@footnote@delayfootnote=\jlreq@footnote@delayfootnote@delay
  \def\jlreq@footnote@flushdelayfootnoteslist{%
    \jlreq@if{\ifx\jlreq@footnote@delayfootnoteslist\@empty\fi}{}{%
      \let\jlreq@footnote@delayfootnote=\jlreq@footnote@delayfootnote@immediate
      \jlreq@setcurrentpage
      \expandafter\gdef\expandafter\jlreq@footnote@delayfootnoteslist\expandafter{\expandafter}%
      \jlreq@footnote@delayfootnoteslist
      \let\jlreq@footnote@delayfootnote=\jlreq@footnote@delayfootnote@delay
    }%
  }
  \AtEndDocument{\jlreq@footnote@flushdelayfootnoteslist}
  \tl_put_left:Nn \newpage {\jlreq@footnote@flushdelayfootnoteslist}
  \long\def\jlreq@footnote@impl@woption#1#2#3[#4]#5{%
    \jlreq@footnote@delayfootnote@page
    \begingroup
      \edef\jlreq@do{\unexpanded{%
        \jlreq@restore@original@footnotes
        \def\jlreq@result{}#2[#4]\jlreq@result
        \def\jlreq@result{}#3[#4]{#5}%
        \jlreq@restore@jlreq@footnotes}%
        \int_compare:nTF { \jlreq@resultcnt=-1 }{\noexpand\jlreq@result}{\unexpanded{%
          \tl_gput_right:Nx \jlreq@footnote@delayfootnoteslist {%
            \noexpand\jlreq@footnote@delayfootnote{\the\jlreq@resultcnt}{%
              \noexpand\jlreq@restore@original@footnotes
              \exp_not:o {\jlreq@result}%
              \noexpand\jlreq@restore@jlreq@footnotes
            }%
          }%
        }}%
      }%
    \expandafter\endgroup\jlreq@do
    \jlreq@hook@postnote
  }
  \long\def\jlreq@footnote@impl@wooption#1#2#3#4{%
    \jlreq@footnote@delayfootnote@page
    \begingroup
      \stepcounter{footnote}%
      \edef\jlreq@do{%
        \unexpanded{\def\jlreq@result{}#2}[\the\value{footnote}]\noexpand\jlreq@result
        \unexpanded{\def\jlreq@result{}#3}[\the\value{footnote}]\unexpanded{{#4}}%
        \jlreq@if{\ifnum\jlreq@resultcnt=-1~\fi}{\noexpand\jlreq@result}{\unexpanded{%
          \tl_gput_right:Nx \jlreq@footnote@delayfootnoteslist {%
            \noexpand\jlreq@footnote@delayfootnote{\the\jlreq@resultcnt}{%
              \noexpand\jlreq@restore@original@footnotes
              \exp_not:o {\jlreq@result}%
              \noexpand\jlreq@restore@jlreq@footnotes
            }%
          }%
        }}%
      }%
    \expandafter\endgroup\jlreq@do
    \jlreq@hook@postnote
  }
}{
  \long\def\jlreq@footnote@impl@woption#1#2#3[#4]#5{%
    \jlreq@restore@original@footnotes
    #1[#4]{#5}%
    \jlreq@restore@jlreq@footnotes
    \jlreq@hook@postnote
  }
  \long\def\jlreq@footnote@impl@wooption#1#2#3#4{%
    \jlreq@restore@original@footnotes
    #1{#4}%
    \jlreq@restore@jlreq@footnotes
    \jlreq@hook@postnote
  }
}

% 合印
\renewcommand*{\@makefnmark}{%
  \jlreq@ifydir{\jlreq@notemark{\@thefnmark}}{\hbox{\jlreq@notemark{\@thefnmark}}}%
}
% 4.2.2注3
\legacy_if:nTF { @tate } {
  \renewcommand*{\thefootnote}{\jlreq@open@bracket@before@space\inhibitglue（\tatechuyoko*{\@arabic\c@footnote}）\inhibitglue}
}{
  \renewcommand*{\thefootnote}{\arabic{footnote}\hbox{}）\inhibitglue}
}
\str_if_eq:VnF \jlreq@article@type { article } { \@addtoreset{footnote}{chapter} }


%.. 後注（4.2.4）
\def\jlreq@endnotemarkname{@thefnmark}% 合印用番号を一時的に入れるマクロ名
\def\jlreq@endnotecounter{footnote}% 後注用のカウンタ名
% 文字サイズは\footnotesizeを使う
\newdimen\jlreq@endnote@prepostspace
% 前の分との間は行間分空ける（4.2.4.f）
\jlreq@endnote@prepostspace=\dimexpr\baselineskip - 1\jlreq@gol\relax
\newdimen\jlreq@endnote@indent
% 現在の後注一覧を，\jlreq@endnote@textsに{{合印1}{後注1}}{{合印2}{後注2}}...の形で保持する
\def\jlreq@endnote@texts{}
\long\def\jlreq@endnote@addtext#1#2{\tl_gput_right:Nx \jlreq@endnote@texts { \exp_not:n {{{#1}{#2}}} } }
% \endnote自身は後で定義する
\NewHook{cmd/endnote/before}
\NewHook{cmd/endnote/after}
\NewHook{cmd/endnotemark/before}
\NewHook{cmd/endnotemark/after}
\NewDocumentCommand { \endnotemark }{ O{} } {
  \jlreq@hook@prenote
  \UseHook{cmd/endnote/before}
  \jlreq@endnotemark{#1}
  \UseHook{cmd/endnote/after}
  \jlreq@hook@postnote
}
\NewDocumentCommand { \endnotetext } { O{} +m } { \jlreq@endnotetext{#1}{#2} }
\long\def\jlreq@endnote#1#2{
  \jlreq@hook@prenote
  \UseHook{ cmd/endnote/before }
  \jlreq@endnotemark{#1}\@endnotetext{#2}
  \UseHook{ cmd/endnote/after }
  \jlreq@hook@postnote
}
\def\jlreq@endnotemark#1{%
  \jlreq@ifempty{#1}{%
    \stepcounter{\jlreq@endnotecounter}%
    \expandafter\protected@xdef\csname\jlreq@endnotemarkname\endcsname{\csname the\jlreq@endnotecounter\endcsname}%
  }{%
    \begingroup
      \csname c@\jlreq@endnotecounter\endcsname #1\relax
      \expandafter\unrestored@protected@xdef\csname\jlreq@endnotemarkname\endcsname{\csname the\jlreq@endnotecounter\endcsname}%
    \endgroup
  }%
  \@endnotemark
}
\jlreq@setdefaultnotemark\@endnotemark\@makeendmark
\long\def\jlreq@endnotetext#1#2{%
  \jlreq@ifempty{#1}{%
    \expandafter\protected@xdef\csname\jlreq@endnotemarkname\endcsname{\csname the\jlreq@endnotecounter\endcsname}%
  }{%
    \begingroup
      \csname c@\jlreq@endnotecounter\endcsname #1\relax
      \expandafter\unrestored@protected@xdef\csname\jlreq@endnotemarkname\endcsname{\csname the\jlreq@endnotecounter\endcsname}%
    \endgroup
  }%
  \@endnotetext{#2}%
}
\long\def\@endnotetext#1{%
  \expandafter\let\expandafter\jlreq@tempa\expandafter=\csname\jlreq@endnotemarkname\endcsname
  \expandafter\jlreq@endnote@addtext\expandafter{\jlreq@tempa}{#1}%
}
\long\def\jlreq@theendnotes#1{%
  \jlreq@ifendmark{#1}{}{%
    \jlreq@output@endnotes#1
    \jlreq@theendnotes
  }%
}
\long\def\jlreq@output@endnotes#1#2{%
  \expandafter\def\csname\jlreq@endnotemarkname\endcsname{#1}%
  \item\@makeendtext{#2}%
}

\newcommand*{\theendnotes}{%
  \ifx\jlreq@endnote@texts\@empty\else
    \let\jlreq@tempa=\jlreq@endnote@texts
    \gdef\jlreq@endnote@texts{}%
    \edef\jlreq@endnote@beforeafterspace{\the\dimexpr\baselineskip - 1\jlreq@gol\relax plus \the\dimexpr 1\jlreq@gol\relax}%
    \begingroup
      \par
      \footnotesize
      % 後注の長さを文字サイズの整数倍にする（4.2.4.b）
      \jlreq@tempdima=\dimexpr\linewidth - \jlreq@endnote@indent - \leftskip\relax
      \@tempdimb=1\jlreq@mol
      \divide\jlreq@tempdima\@tempdimb\multiply\jlreq@tempdima\@tempdimb
      \begin{list}{}{%
        \itemsep=0pt\relax
        \parsep=0pt\relax
        \partopsep=0pt\relax
        \topsep=0pt\relax
        \leftmargin=\dimexpr\linewidth - \jlreq@tempdima + \jlreq@endnote@second@indent\relax
        \itemindent=-\glueexpr\jlreq@endnote@second@indent\relax
        \topsep=\jlreq@endnote@beforeafterspace\relax
        \listparindent=1\jlreq@zw
      }%
      \expandafter\jlreq@theendnotes\jlreq@tempa\jlreq@endmark
      \end{list}%
    \endgroup
    \par
  \fi
}
% 4.2.4.b
\jlreq@endnote@indent=2\jlreq@mol
\keys_define:nn { jlreqsetup } { 
  endnote_second_indent .code:n = {
    \def\jlreq@endnote@second@indent{#1}
    \bool_if:nTF {
      ( \dim_compare_p:n { 0.99\jlreq@zw < #1 } && \dim_compare_p:n { #1 < 1.01\jlreq@zw } ) ||
      ( \dim_compare_p:n { 1.99\jlreq@zw < #1 } && \dim_compare_p:n { #1 < 2.01\jlreq@zw } )
    } {} {
      \jlreq@note{後注が2行以上となった場合，後注の2行目以下の字下げは，1行目より，後注の文字サイズの2倍又は全角とする (4.2.4.d)．}
    }
  }
}
\newcommand{\@makeendtext}[1]{%
  \csname\jlreq@endnotemarkname\endcsname
  \hskip\glueexpr1\jlreq@zw\relax% 見出し出力と一文字分の空き（4.2.4.c）
  #1%
}
\let\@makeendmark=\@makefnmark

% \theendnoteの出力を仕込む
\keys_define:nn { jlreqsetup } {endnote_position .code:n = {
    \AddToHook{jlreq/heading/before}[jlreq/endnote]{}
    \RemoveFromHook{jlreq/heading/before}[jlreq/endnote]
    \jlreq@tempafalse % headingsが指定された
    \jlreq@tempbfalse % paragraphが指定された
    % \jlreq@tempcにセクション名たちを入れていく
    \seq_clear:N \l_jlreq_tmpa_seq
    \clist_map_variable:nNn {#1} \jlreq@tempa {
      \tl_set:Nx \@tempa { \tl_trim_spaces:o \@tempa }
      \str_case_e:nnF {\jlreq@tempa} {
        {headings}{\jlreq@tempatrue}
        {paragraph}{
          \jlreq@tempatrue% _paragraphの時は_headingsも有効にする
          \jlreq@tempbtrue
        }
      }{
        \str_if_eq:eeTF { \str_head:N \jlreq@tempa } {_} {
          \seq_put_left:Nx \l_jlreq_tmpa_seq { \tl_tail:N \jlreq@tempa }
        }{
         \ClassError{jlreq}{Invalid~value~\jlreq@tempa\space in~endnote_position}{\@ehc}
        }
      }
    }
    
    \ifjlreq@tempb
      \DeclareDocumentCommand { \endnote } { O{} +m } {
        \AddToHookNext { para/after } { \theendnotes }
        \jlreq@endnote{##1}{##2}
      }
    \else
      \DeclareDocumentCommand { \endnote } { O{} +m } {
        \jlreq@endnote{##1}{##2}
      }
    \fi

    \ifjlreq@tempa
      \AddToHook{jlreq/heading/before}[jlreq/endnote]{\theendnotes}
    \else
      \seq_map_variable:NNn \l_jlreq_tmpa_seq \@tempa {
        \tl_if_empty:VF \@tempa {
          \AddToHook{jlreq/heading/before/\@tempa}[jlreq/endnote]{}
          \RemoveFromHook{jlreq/heading/before/\@tempa}[jlreq/endnote]
          \AddToHook{jlreq/heading/before/\@tempa}[jlreq/endnote]{\theendnotes}
        }
      }
    \fi
  }
}
\AtEndDocument{\theendnotes}


% (1) \footnoteとかと同じ形式 sidenote_type=number
% (2) 文中にマークを入れて，傍注には見出しが入る sidenote_type=symbol
% (3) 文中は強調文字列，傍注には見出しが入る sidenote_type=symbol
% (4) 文中は何も無し，傍注には見出しが入る sidenote_type=symbol

% (1) では\sidenote[]{}を定義
% (2) では\sidenote{見出し}{注中身}を定義
% sidenote_length>0ptの時のみ定義する
\dim_compare:nT { \jlreq@sidenote@length > 0pt } {
  \ProvideHook{ cmd/sidenote/before }
  \ProvideHook{ cmd/sidenote/after }
  \ProvideHook{ cmd/sidenotemark/before }
  \ProvideHook{ cmd/sidenotemark/after }
  \def\jlreq@sidenotemarkname{@thefnmark}% 合印用番号を一時的に入れるマクロ名
  \long\def\@sidenotetext#1{%
    \marginpar{\reset@font\footnotesize
      \color@begingroup\normalcolor
      \@makesidetext{#1}%
      \color@endgroup
    }%
  }
  \jlreq@setdefaultnotemark\@sidenotemark\@makesidemark
  \def\jlreq@sidenotecounter{footnote}% 傍注用のカウンタ名
  \keys_define:nn { jlreqsetup } {
    sidenote_type .choices:nn = { number, symbol } { \def\jlreq@sidenote@type{#1} }
  }
  \def\jlreq@sidenote@type{number}
  \__jlreq_jlreqsetup_addtofinally:n {
    \str_if_eq:VnT \jlreq@sidenote@type { number } {
      \DeclareDocumentCommand { \sidenote } { O{} +m } {
        \jlreq@hook@prenote\UseHook{cmd/sidenote/before}
        \jlreq@sidenote{#1}{#2}
        \UseHook{cmd/sidenote/after}\jlreq@hook@postnote
      }
      \DeclareDocumentCommand { \sidenotemark } { O{}   } {
        \jlreq@hook@prenote\UseHook{cmd/sidenotemark/before}
        \jlreq@sidenotemark{#1}
        \UseHook{cmd/sidenotemark/after}\jlreq@hook@postnote
      }
      \DeclareDocumentCommand { \sidenotetext } { O{} +m } { \jlreq@sidenotetext{#1}{#2} }
      \long\def\jlreq@sidenote#1#2{\jlreq@sidenotemark{#1}\@sidenotetext{#2}}
      \def\jlreq@sidenotemark#1{%
        \tl_if_empty:nTF{#1}{%
          \stepcounter{\jlreq@sidenotecounter}%
          \expandafter\protected@xdef\csname\jlreq@sidenotemarkname\endcsname{\csname the\jlreq@sidenotecounter\endcsname}%
        }{%
          \begingroup
            \csname c@\jlreq@sidenotecounter\endcsname #1\relax
            \expandafter\unrestored@protected@xdef\csname\jlreq@sidenotemarkname\endcsname{\csname the\jlreq@sidenotecounter\endcsname}%
          \endgroup
        }%
        \@sidenotemark
      }
      \long\def\jlreq@sidenotetext#1#2{%
        \tl_if_empty:nTF{#1}{%
          \expandafter\protected@xdef\csname\jlreq@sidenotemarkname\endcsname{\csname the\jlreq@sidenotecounter\endcsname}%
        }{%
         \begingroup
           \csname c@\jlreq@sidenotecounter\endcsname#1\relax
           \expandafter\unrestored@protected@xdef\csname\jlreq@sidenotemarkname\endcsname{\csname the\jlreq@sidenotecounter\endcsname}%
         \endgroup
        }%
        \@sidenotetext{#2}%
      }
      % \hspace{0.5\jlreq@mol}の部分は二分空きにする例もある（4.2.7.g）
      \ifx l\jlreq@engine
        \long\def\@makesidetext#1{\csname\jlreq@sidenotemarkname\endcsname\hspace{0.5\jlreq@mol}#1}
      \else
        % thefootnote = \inhibitglue （...だと\inhibitglueが効かないので空白を挟む
        \long\def\@makesidetext#1{　\kern-1\jlreq@zw\csname\jlreq@sidenotemarkname\endcsname\hspace{0.5\jlreq@mol}#1}
      \fi
      \let\@makesidemark=\@makefnmark
    }
    \str_if_eq:VnT \jlreq@sidenote@type { symbol } {% sidenote_type = symbol
      \DeclareDocumentCommand { \sidenote     } { m +m } { \UseHook{cmd/sidenote/before}\jlreq@sidenote{#1}{#2}\UseHook{cmd/sidenote/after} }
      \DeclareDocumentCommand { \sidenotemark } { m   } { \UseHook{cmd/sidenotemark/before}\jlreq@sidenotemark{#1}\UseHook{cmd/sidenote/after} }
      \DeclareDocumentCommand { \sidenotetext } { m +m } { \jlreq@sidenotetext{#1}{#2} }
      \long\def\jlreq@sidenote#1#2{\jlreq@sidenotemark{#1}\jlreq@sidenotetext{#1}{#2}}
      \edef\jlreq@sidenotemark#1{%
        {\unexpanded{\reset@font\jlreq@sidenote@keywordfont}#1}%
        \noexpand\jlreq@hook@prenote
        \ifx\jlreq@sidenote@defaultmark\@empty\else
          \expandafter\edef\exp_not:c {\jlreq@sidenotemarkname}{\exp_not:o {\jlreq@sidenote@defaultmark}}%
          \noexpand\@sidenotemark
        \fi
      }
      % カスタマイズできるべき？
      \long\def\jlreq@sidenotetext#1#2{%
        \expandafter\def\csname\jlreq@sidenotemarkname\endcsname{\inhibitglue\null{\reset@font\sffamily\gtfamily\bfseries\inhibitglue #1}}%
        \@sidenotetext{#2}%
      }
      \long\def\@makesidetext#1{{\sffamily\gtfamily\bfseries\csname\jlreq@sidenotemarkname\endcsname}\hspace*{1\jlreq@mol}#1}
      \let\@makesidemark=\@makefnmark
    }
  }
  \keys_define:nn { jlreqsetup } { sidenote_symbol .tl_set:N = \jlreq@sidenote@defaultmark }
  \keys_define:nn { jlreqsetup } { sidenote_keyword_font .tl_set:N = \jlreq@sidenote@keywordfont }
}

%.. 割注（3.4）
\def\inlinenotesize{.6\jlreq@jafontsize} % 割注の文字サイズ
\let\jlreq@inlinenote@autolinebreak=\\% 計測時は\linebreakより\\の方が安定する．悩ましい……．

\def\jlreq@inlinenote@kakkofontsize{%
  \fontsize{\dimexpr\inlinenotesize * 2\relax}{\dimexpr \inlinenotesize * 2\relax}%
  \selectfont
}

\def\jlreq@inlinenote@fontsize{%
  \fontsize{\inlinenotesize}{\inlinenotesize}%
  \selectfont
}

% 割注を入れるための命令．\inlinenote{割注}で使う．
% 改行位置は自動で計算されるが，常に正しいとは限らない．
% \inlinenote*は自動で改行されない．\\で改行位置を指定する．
\newif\ifjlreq@in@inlinenote
\jlreq@in@inlinenotefalse
\NewDocumentCommand{\inlinenote}{ s m } {
  \ifjlreq@in@inlinenote\ClassError{jlreq}{\string\inlinenote\space can't~be~nested}{\@ehc}\fi
  \jlreq@in@inlinenotetrue
  \ifvmode\leavevmode\fi
  \IfBooleanTF {#1} { \jlreq@inlinenote@noauto {#2} } { \jlreq@inlinenote@auto {#2} }
}
\NewDocumentCommand{\warichu}{ s m } {
  \ifjlreq@in@inlinenote\ClassError{jlreq}{\string\warichu\space can't~be~nested}{\@ehc}\fi
  \jlreq@in@inlinenotetrue
  \ifvmode\leavevmode\fi
  \IfBooleanTF {#1} { \jlreq@inlinenote@noauto {#2} } { \jlreq@inlinenote@auto {#2} }
}

\def\jlreq@inlinenote@auto#1{%
  % 割注初め括弧の前の場所を保存
  \jlreq@savepos@for@rest@linewidth
  % \jlreq@tempdimbに，現在行の残り長さを入れる
  \jlreq@tempdimb=\jlreq@rest@linewidth
  % 括弧の分を引いたものが，割注の使える長さ
  \setbox\@tempboxa=\hbox{\jlreq@inlinenote@kakkofontsize\inhibitglue\jlreq@open@bracket@before@space（\inhibitglue}%
  \addtolength{\jlreq@tempdimb}{-\wd\@tempboxa}%
  \ifdim\jlreq@tempdimb<0pt\jlreq@tempdimb=\linewidth\fi
  {%
    \setbox\jlreq@tempboxa=\hbox{\jlreq@inlinenote@kakkofontsize\inhibitglue \jlreq@open@bracket@before@space（}%
    \jlreq@box@putcenter\jlreq@tempboxa
  }%
  % 「初回」時はここに強制改行を入れる．これにより現在位置の取得がより正しくなる……といいなぁ
  \jlreq@savepos@iflabelundefined{\\}{}%
  % 割注内の\baselineskipを保存（後で使う）．
  {\jlreq@inlinenote@fontsize\xdef\jlreq@inlinenote@baselineskip{\the\baselineskip}}%
  % 普通に並べた長さを計測し，その半分から始める
  \setbox\@tempboxa=\hbox{\jlreq@inlinenote@fontsize #1}%
  \jlreq@tempdimc=\wd\@tempboxa
  \divide\jlreq@tempdimc by 2\relax
  % \@tempcntbに，この長さで計測した場合の行数を入れる
  \ifdim\jlreq@tempdimc<\jlreq@tempdimb\@tempcntb=2\relax
  \else
    \jlreq@tempdima=\dimexpr\jlreq@tempdimc - \jlreq@tempdimb\relax
    \divide\jlreq@tempdima\linewidth
    \@tempcntb=\numexpr 2*\number\jlreq@tempdima + 4\relax
  \fi
  % \jlreq@parshapeargに\parshapeに指定する書式の最後以外を入れる．
  \ifnum\@tempcntb>2\relax
    \edef\jlreq@parshapearg{0pt~\the\jlreq@tempdimb\space 0pt~\the\jlreq@tempdimb}%
    \@tempcnta=4\relax
    \@whilenum\@tempcnta<\@tempcntb\do{%
      \edef\jlreq@parshapearg{\jlreq@parshapearg\space 0pt~\the\linewidth\space 0pt~\the\linewidth}%
      \advance\@tempcnta by 2\relax
    }%
    \setlength{\jlreq@tempdimc}{\dimexpr\jlreq@tempdimc - \jlreq@tempdimb - \linewidth * \numexpr(\@tempcntb - 4)/2\relax\relax}%
  \else
    \def\jlreq@parshapearg{}%
  \fi
  % 行数を伸ばしつつ良いところを探していく
  \@whilenum\@tempcntb<1001\do{%
    \ifnum\@tempcntb>2\jlreq@tempdimb=\linewidth\fi
    \edef\@tempb{\the\@tempcntb}%
    \jlreq@inlinenote@determinelength{#1}{\jlreq@inlinenote@fontsize}{\jlreq@parshapearg}{2}{\@tempb}{\jlreq@tempdimc}{\jlreq@tempdimb}%
    \@tempcntb=\@tempb
    \ifnum\@tempcntb>999\relax% ループが長すぎる
      \global\setbox\jlreq@resultbox=\voidb@x%
      \@tempcntb=1001\relax
    \fi
    \ifvoid\jlreq@resultbox\else% 成功
      \edef\jlreq@inlinenote@lines{\the\@tempcntb}% 行数を保存
      \@tempcntb=1001\relax
    \fi
    \advance\@tempcntb by 2\relax
    \edef\jlreq@parshapearg{\jlreq@parshapearg~0pt~\the\jlreq@tempdimb~0pt~\the\jlreq@tempdimb}%
  }%
  \ifvoid\jlreq@resultbox
    \ClassWarning{jlreq}{\string\warichu\space failed,~may~be~a~bug}%
  \else
    \@tempcnta=0
    \splittopskip=0pt\relax
    \splitmaxdepth=\maxdimen
    % 現在行の残り長さを思い出す
    \jlreq@tempdimb=\jlreq@rest@linewidth
    \setbox\@tempboxa=\hbox{\jlreq@inlinenote@kakkofontsize\inhibitglue\jlreq@open@bracket@before@space（\inhibitglue}%
    \addtolength{\jlreq@tempdimb}{-\wd\@tempboxa}%
    \setbox\@tempboxa=\box\jlreq@resultbox
    \@whilenum\@tempcnta<\jlreq@inlinenote@lines\do{%
      \int_compare:nT { \@tempcnta > 0 } { \jlreq@inlinenote@autolinebreak }
      % \jlreq@tempdimaに今の行の長さを入れる
      \ifnum\@tempcnta<\numexpr\jlreq@inlinenote@lines - 2\relax
        \ifnum\@tempcnta=0\jlreq@tempdima=\jlreq@tempdimb
        \else\jlreq@tempdima=\linewidth\fi
      \else
        % 最終行は自然長に任せる
        \jlreq@tempdima=-1pt\relax
      \fi
      {%
        \edef\@tempa{\the\vbadness}%
        \vbadness=10000
        \setbox\jlreq@tempboxa=\vsplit\@tempboxa to \dimexpr\jlreq@inlinenote@baselineskip*2\relax
        \vbadness=\@tempa\relax
        \jlreq@getlastbox{\jlreq@tempboxa}%
        \setbox\jlreq@tempboxb=\box\jlreq@resultbox
        \jlreq@getlastbox{\jlreq@tempboxa}%
        \setbox\jlreq@tempboxa=\box\jlreq@resultbox
        \ifdim\jlreq@tempdima>0pt\relax
          \setbox\jlreq@tempboxa=\vbox{\jlreq@inlinenote@fontsize
            \hbox to \jlreq@tempdima{\unhbox\jlreq@tempboxa}%
            \hbox to \jlreq@tempdima{\unhbox\jlreq@tempboxb}}%
        \else
          \setbox\jlreq@tempboxa=\vbox{\jlreq@inlinenote@fontsize
            \hbox{\unhbox\jlreq@tempboxa}%
            \hbox{\unhbox\jlreq@tempboxb}}%
        \fi
        \jlreq@box@putcenter\jlreq@tempboxa
      }%
      \advance\@tempcnta by 2\relax
    }%
  \fi
  \jlreq@inlinenote@endnote
}

\def\jlreq@inlinenote@noauto#1{%
  \setbox\jlreq@tempboxa=\hbox{\jlreq@inlinenote@kakkofontsize\inhibitglue\jlreq@open@bracket@before@space（}%
  \inhibitglue\jlreq@box@putcenter\jlreq@tempboxa
  \jlreq@inlinenote@noauto@#1\\\jlreq@endmark\jlreq@endmark
  \jlreq@inlinenote@endnote
}

\def\jlreq@inlinenote@noauto@#1\\#2#3\jlreq@endmark{%
  \jlreq@inlinenote@noauto@@#1&\jlreq@endmark\jlreq@endmark
  \jlreq@ifendmark{#2}{}{\linebreak\jlreq@inlinenote@noauto@#2#3\jlreq@endmark}%
}

\def\jlreq@inlinenote@noauto@@#1&#2#3\jlreq@endmark{%
  \jlreq@ifendmark{#2}{%
    \setbox\@tempboxa=\hbox{\jlreq@inlinenote@fontsize #1}%
    \jlreq@tempdimc=\wd\@tempboxa
    \divide\jlreq@tempdimc by 2\relax
    \jlreq@inlinenote@determinelength{#1}{\jlreq@inlinenote@fontsize}{}{2}{2}{\jlreq@tempdimc}{\maxdimen}%
    \ifvoid\jlreq@resultbox\else
      {%
        \setbox\jlreq@tempboxa=\hbox{\jlreq@inlinenote@fontsize\box\jlreq@resultbox}%
        \jlreq@box@putcenter\jlreq@tempboxa
      }%
    \fi
    \def\jlreq@next{}%
  }{%
    \def\jlreq@next{\jlreq@inlinenote@noauto@@@{#1}#2#3}%
  }%
  \jlreq@next
}

\def\jlreq@inlinenote@noauto@@@#1#2&\jlreq@endmark{%
  \setbox\@tempboxa=\hbox{\jlreq@inlinenote@fontsize\vbox{\hbox{#1}\hbox{#2}}}%
  \jlreq@box@putcenter\@tempboxa
}

\def\jlreq@inlinenote@endnote{%
  \jlreq@in@inlinenotefalse
  {%
    \setbox\jlreq@tempboxa=\hbox{\jlreq@inlinenote@kakkofontsize）}%
    \jlreq@box@putcenter\jlreq@tempboxa
    \inhibitglue
  }%
}

% \jlreq@inlinenote@determinelength{テキスト(1)}{フォントとか指定(2)}{\parshape指定(3)}{調整に使う行数(4)}{成功行数(5)}{最小長さ(6)}{最大長さ(7)}
% 次を満たす長さXの最小値を求める（ただし#6 <= X <= #7）
% #1を
% * #5 - #4行目までは#3の指定に従う
% * それ以降はX
% として整形した際に，#5行以内に収まる．
% \jlreq@resultboxに整形結果を返す（垂直ボックス）．見つからなかったらvoid．\globalに設定する．
\def\jlreq@inlinenote@determinelength#1#2#3#4#5#6#7{%
  \begingroup
  %  \message{#1 の試行開始，行数 = #5, \the\dimexpr#6\relax から \the\dimexpr#7\relaxまで}%
    \@tempcnta=1\relax
    \def\@tempa{}%
    % 調整に使う行の\parshape指定を\@tempaに入れる．長さは\jlreq@tempdima．
    \@whilenum\@tempcnta<#4\do{%
      \expandafter\def\expandafter\@tempa\expandafter{\@tempa 0pt~\the\jlreq@tempdima}%
      \advance\@tempcnta by 1\relax
    }%
    \@tempcnta=0
    \jlreq@tempdima=#6\relax
    % \jlreq@tempdimaを少しずつ伸ばしていく
    \@whilenum\@tempcnta<1000\do{%
      \ifnum\@tempcnta>999\relax% ループが長すぎる
        \global\setbox\jlreq@resultbox=\voidb@x%
        \@tempcnta=1001\relax
      \else
        \setbox\@tempboxa=\vbox{#2%
          \vbadness=10000\hbadness=10000\vfuzz=\maxdimen\hfuzz=\maxdimen
          \parindent=0pt\leftskip=0pt\rightskip=0pt
          \parshape #5~#3~\@tempa 0pt~\the\maxdimen
          #1\par\global\@tempcntb=\prevgraf}%
  %      \message{\string\jlreq@tempdima = \the\jlreq@tempdima で試行，行数は\the\@tempcntb , 書式 #5 #3 \@tempa 0pt \the\maxdimen}%
      \fi
      \jlreq@getlastbox{\@tempboxa}%
      \setbox\jlreq@tempboxa=\box\jlreq@resultbox
      \ifnum\@tempcntb<#5\relax% 行数が達していないならOK
  %      \message{行数 = \the\@tempcntb により確定}
        % #5行になるまで空の水平ボックスを加えていく．
        \global\setbox\jlreq@resultbox=\vbox{#2%
          \unvbox\@tempboxa\hbox{\unhbox\jlreq@tempboxa\unskip\unskip\unpenalty}%
          \@whilenum\@tempcntb<#5\do{\hbox{}\advance\@tempcntb by 1}}%
        \@tempcnta=1001\relax
      \else
        % そうでない場合は最後の二行の長さを比較する
        \jlreq@getlastbox{\@tempboxa}%
        \setbox\jlreq@tempboxb=\box\jlreq@resultbox
  %      \message{最終行の長さ \the\wd\jlreq@tempboxa, その前の長さ \the\wd\jlreq@tempboxb}%
        \ifdim\wd\jlreq@tempboxa>\wd\jlreq@tempboxb
          \advance\jlreq@tempdima by 0.3pt\relax% 0.3ptに意味はない
        \else
          % 後ろが短いのでOK
          \global\setbox\jlreq@resultbox=\vbox{#2\unvbox\@tempboxa\box\jlreq@tempboxb\box\jlreq@tempboxa}%
          \jlreq@resultdimen=\jlreq@tempdima
          \@tempcnta=1001\relax
        \fi
      \fi
      \ifdim\jlreq@tempdima>#7\relax
        \global\setbox\jlreq@resultbox=\box\voidb@x
        \@tempcnta=1001\relax
      \fi
      \advance\@tempcnta by 1\relax
    }%
  \endgroup
}

%. ページスタイル．
% メモ：
% 2.6.1.cの後半が前半と整合的でないように見える……
% 柱：両柱と片柱（2.6.3）
\@tempdima=\jlreq@speciallength{\jlreq@headfoot@sidemargin}
\bool_if:nTF {
  \dim_compare_p:n { \@tempdima = 0pt } ||
  ( \dim_compare_p:n { 0.99\jlreq@zw < \@tempdima } && \dim_compare_p:n { \@tempdima < 1.01\jlreq@zw} )
} {} {
  \jlreq@note{ノンブルまたは柱は，基本版面の左右にそろえるか，全角アキだけ寄せた位置に配置する (2.6.1.b)．}
}

%.. 場所指定解析
% bottom-leftみたいなのを解釈する．入力の順番はどっちでも良いが，出力は<top/bottom><left/right>の順番
% #1 = bottom-leftみたいなのを{bottom}{left}に変換し，#2に代入，#3はデフォルト値，出力形式で入れる
\def\jlreq@pagestyle@parse@position#1#2#3{%
  \jlreq@ifempty{#1}{\def#2{#3}}%
  {%
    \begingroup
      \jlreq@pagestyle@parse@position@#1-\jlreq@endmark
      \str_if_eq:VnTF \jlreq@tempa { fore } {
        \expandafter\jlreq@pagestyle@parse@position@\jlreq@tempb-\jlreq@endmark
        \str_if_eq:VnTF \jlreq@tempa { edge } {
          \def\jlreq@tempa{fore-edge}%
        }{%
          \ClassError{jlreq}{Invalid~position:~fore-\jlreq@tempa}{\@ehc}%
        }%
      }{}%
      % \jlreq@tempcに縦方向を，\jlreq@tempdに横方向を入れる
      \def\jlreq@tempc{}\def\jlreq@tempd{}%
      \jlreq@pagestyle@parse@position@@{\jlreq@tempa}%
      \jlreq@pagestyle@parse@position@@{\jlreq@tempb}%
      \ifx\jlreq@tempc\@empty\edef\jlreq@tempc{\expandafter\@firstoftwo#3}\fi
      \ifx\jlreq@tempd\@empty\edef\jlreq@tempd{\expandafter\@secondoftwo#3}\fi
      \edef\jlreq@do{\unexpanded{\def#2}{{\jlreq@tempc}{\jlreq@tempd}}}%
    \expandafter\endgroup
    \jlreq@do
  }%
}

\def\jlreq@pagestyle@parse@position@#1-#2\jlreq@endmark{%
  \def\jlreq@tempa{#1}\def\jlreq@tempb{#2}%
  \jlreq@ifempty{#2}{%
    \ifx\jlreq@tempb\@empty\ClassError{jlreq}{Invalid~position:~#1}{\@ehc}\fi
  }{%
    \def\@tempa##1-\jlreq@endmark{\def\jlreq@tempb{##1}}%
    \@tempa#2\jlreq@endmark\relax
  }%
}

\def\jlreq@pagestyle@parse@position@@#1{%
  \str_case_e:nnF { #1 } {
    {top}{\def\jlreq@tempc{#1}}
    {bottom}{\def\jlreq@tempc{#1}}
    {left}{\def\jlreq@tempd{#1}}
    {right}{\def\jlreq@tempd{#1}}
    {center}{\def\jlreq@tempd{#1}}
    {gutter}{\if@tate\def\jlreq@tempd{right}\else\def\jlreq@tempd{left}\fi}
    {fore_edge}{\if@tate\def\jlreq@tempd{left}\else\def\jlreq@tempd{right}\fi}
    {fore-edge}{\if@tate\def\jlreq@tempd{left}\else\def\jlreq@tempd{right}\fi}
  }{\ClassError{jlreq}{Invalid~position:~#1}{\@ehc}}
}

% レベル#1より低いレベルの見出しの**markを\markboth{}{}にする
\def\jlreq@pagestyle@setclearmark#1{%
  \seq_map_inline:Nn \l__jlreq_heading_allheadings_seq {
    \@ifundefined{##1}{}{%
      \@ifundefined{jlreq@heading@level@##1}{}{%
        \ifnum\csname jlreq@heading@level@##1\endcsname<#1\relax\expandafter\def\csname##1 mark\endcsname####1{\markboth{}{}}\fi
      }%
    }%
  }%
}

% #1のleftとrightを入れ替えて#1に代入
\def\jlreq@reverse@leftright#1{%
  \str_case_e:nn {#1} {
    { left  }{ \def#1{right} }
    { right }{ \def#1{left}  }
  }%
}

%.. マークの拡張
\def\jlreq@markregistername#1{jlreq@extramark@register@#1}
\def\jlreq@extraleftmark#1{\jlreq@extramark@{#1}{\expandafter\@firstoftwo\botmarks}}
\def\jlreq@extrarightmark#1{\jlreq@extramark@{#1}{\expandafter\@secondoftwo\firstmarks}}
\def\jlreq@extramark@#1#2{\jlreq@if{\ifcsname\jlreq@markregistername{#1}\endcsname\fi}%
  {\expandafter\jlreq@extramark@@\expandafter{\csname \jlreq@markregistername{#1}\endcsname}{#2}}%
  {}%
}
\def\jlreq@extramark@@#1#2{#2#1\@empty\@empty}

\def\jlreq@setextraleftmark@#1#2{{#2}{\expandafter\@secondoftwo#1}}
\def\jlreq@setextrarightmark@#1#2{{\expandafter\@firstoftwo#1}{#2}}
\def\jlreq@setextraleftmark#1#2{\jlreq@setextramark{#1}{#2}{\jlreq@setextraleftmark@}}
\def\jlreq@setextrarightmark#1#2{\jlreq@setextramark{#1}{#2}{\jlreq@setextrarightmark@}}
\def\jlreq@setextramark#1#2#3{%
  \jlreq@if{\ifcsname\jlreq@markregistername{#1}\endcsname\fi}{}{%
    \expandafter\newmarks\csname\jlreq@markregistername{#1}\endcsname
    \expandafter\def\csname\jlreq@markregistername{#1}@themark\endcsname{{}{}}%
  }%
  \begingroup
    \let\label\relax
    \let\index\relax
    \let\glossary\relax
    \def\jlreq@@themark@csname{\jlreq@markregistername{#1}@themark}%
    \expandafter\unrestored@protected@xdef\csname\jlreq@@themark@csname\endcsname{%
      \expandafter#3\expandafter{\csname\jlreq@@themark@csname\endcsname}{#2}%
    }%
    \expandafter\expandafter\expandafter\@temptokena\expandafter\expandafter\expandafter{\csname\jlreq@@themark@csname\endcsname}%
    \expandafter\marks\csname\jlreq@markregistername{#1}\endcsname{\the\@temptokena}%
  \endgroup
  \if@nobreak\ifvmode\nobreak\fi\fi
}
\let\jlreq@markboth=\markboth
\let\jlreq@markright=\markright

%.. \DeclarePageStyle内で使うもの
% mark情報の取得を行う．
% #1の中身をみて，#2 = 何段目見出しか，#3 = odd/even，\csname #4@<見出し命令名>\endcsnameに必要情報を追加し，#5の見出し命令名リストに追加
% #1@heading@levelにレベルを入れる
\def\jlreq@pagestyle@setmark#1#2#3#4#5{%
  \begingroup
    \str_if_eq:eeTF {\str_head:N #1} {_} {
      \str_if_eq:nnTF {#3} { odd } { \let\jlreq@leftright=r } { \let\jlreq@leftright=l }
      \edef\jlreq@do{%
        \unexpanded{\def#1}{%
          \ifx l\jlreq@leftright
            \int_compare:nTF { #2 = 0 } { \exp_not:N \leftmark } { \exp_not:n {\jlreq@extraleftmark{#2}} }
          \else
            \int_compare:nTF { #2 = 0 } { \exp_not:N \rightmark } { \exp_not:n {\jlreq@extrarightmark{#2}} }
          \fi
        }%
      }%
      \edef\jlreq@headingname{\expandafter\@gobble#1}% 見出し命令名
      \edef\jlreq@tempa{\noexpand\@removeelement{\exp_not:o {\jlreq@headingname}}}%
      \expandafter\jlreq@tempa\expandafter{#5}{#5}%
      \@ifundefined{#4@\jlreq@headingname}{\expandafter\def\csname #4@\jlreq@headingname\endcsname{}}{}%
      \tl_put_right:Nx \jlreq@do {%
        \exp_not:N \@ifundefined {#4@\jlreq@headingname} { \exp_not:N \@namedef {#4@\jlreq@headingname} {} } {}
        \noexpand\let\exp_not:c {\expandafter\@gobble\string #1@heading@level}=\exp_not:c {jlreq@heading@level@\jlreq@headingname}%
        \exp_not:n {\def#5}{\exp_not:o {#5},\exp_not:o {\jlreq@headingname}}%
        \exp_not:N \tl_put_right:Nn \exp_not:c {#4@\jlreq@headingname} {{{\int_compare:nT {#2=0} {#3}}{#2}{\ifx r\jlreq@leftright r\else l\fi}}}%
      }%
    }{\def\jlreq@do{}}%
  \expandafter\endgroup
  \jlreq@do
}

% \def\<見出し>mark#1{...}というのを\jlreq@resultに入れる，
% #1：*ならばextramarkを使う
% #2: 見出し命令名，#3: mark_format
% #4: {{mark_formatからさらに調べるやつ (odd|even)}{マークの何番目か．extraでない場合は0}{l or r(leftかrightか)}}の並び
\def\jlreq@pagestyle@make@headingmark#1#2#3#4{%
  \begingroup
    \clist_map_variable:nNn {0,1,2} \jlreq@i {
      \expandafter\def\csname jlreq@leftmark@\jlreq@i\endcsname{}%
      \expandafter\def\csname jlreq@rightmark@\jlreq@i\endcsname{}%
    }%
    \jlreq@pagestyle@make@headingmark@{#2}{#3}#4\jlreq@endmark
    \def\jlreq@do{}% とりあえず#1markの中身を入れていく
    % leftを設定する時は対応するrightを空にする．
    \expandafter\ifx\csname jlreq@leftmark@0\endcsname\@empty
      \expandafter\ifx\csname jlreq@rightmark@0\endcsname\@empty\else
        \tl_put_right:Nx \jlreq@do {
          \jlreq@ifempty{#1}{\noexpand\markright}{\noexpand\jlreq@markright}{\exp_args:Nc \exp_not:o {jlreq@rightmark@0}}
        }%
      \fi
    \else
      \tl_put_right:Nx \jlreq@do {
        \jlreq@ifempty{#1}{\noexpand\markboth}{\noexpand\jlreq@markboth}{\exp_args:Nc \exp_not:o {jlreq@leftmark@0}}{\exp_args:Nc \exp_not:o {jlreq@rightmark@0}}
      }%
    \fi
    \clist_map_variable:nNn {1,2} \jlreq@i {
      \expandafter\ifx\csname jlreq@leftmark@\jlreq@i\endcsname\@empty
        \expandafter\ifx\csname jlreq@rightmark@\jlreq@i\endcsname\@empty\else
          \tl_put_right:Nx \jlreq@do {\noexpand\jlreq@setextrarightmark{\jlreq@i}{\exp_args:Nc \exp_not:o {jlreq@rightmark@\jlreq@i}}}%
        \fi
      \else
        \tl_put_right:Nx \jlreq@do{%
          \noexpand\jlreq@setextraleftmark{\jlreq@i}{\exp_args:Nc \exp_not:o {jlreq@leftmark@\jlreq@i}}%
          \noexpand\jlreq@setextrarightmark{\jlreq@i}{\exp_args:Nc \exp_not:o {jlreq@rightmark@\jlreq@i}}%
        }%
      \fi
    }%
    \ifx\jlreq@do\@empty\else
      \edef\jlreq@do{%
        \unexpanded{\edef\jlreq@result}{\noexpand\unexpanded{%
          \noexpand\def\exp_not:c {#2mark}\unexpanded{##1}{%
            \exp_not:o {\jlreq@do}%
          }}%
        }%
      }%
    \fi
  \expandafter\endgroup
  \jlreq@do
}%
\def\jlreq@pagestyle@make@headingmark@#1#2#3{%
  \jlreq@ifendmark{#3}{}{\jlreq@pagestyle@make@headingmark@@{#1}{#2}#3}%
}

\def\jlreq@pagestyle@make@headingmark@@#1#2#3#4#5{%
  % \jlreq@tempbに\***markの定義を入れる
  \edef\jlreq@tempb{%
    \exp_not:c {the#1}%
    \noexpand\ifx\exp_not:c {the#1}\unexpanded{\@empty\else\protect\quad\fi}%
    \unexpanded{##1}%
  }%
  \jlreq@parsekeyval@nokey{%
    \tl_if_empty:nF {##1} {\str_if_eq:nnT {##1} {#3} {\edef\jlreq@tempb{\unexpanded{##2}}}}
    \str_if_eq:nnT {##1} {_#1} {\edef\jlreq@tempb{\unexpanded{##2}}}%
  }{#2}%
  \ifx l#5%
    \expandafter\edef\csname jlreq@leftmark@#4\endcsname{\exp_not:o {\jlreq@tempb}}%
  \else
    \expandafter\edef\csname jlreq@rightmark@#4\endcsname{\exp_not:o {\jlreq@tempb}}%
  \fi
  \jlreq@pagestyle@make@headingmark@{#1}{#2}%
}

% #2 #3 #4と並んだヘッダを作り#1に入れる．#1，#2，#3はコンロトールシークエンスの名前とする．
\def\jlreq@pagestyle@setheadfoot#1#2#3#4{%
  \begingroup
    \edef\jlreq@do{\noexpand\jlreq@pagestyle@setheadfoot@{\unexpanded{#1}}{\exp_args:Nc \exp_not:o {#2}}{\exp_args:Nc \exp_not:o {#3}}{\exp_args:Nc \exp_not:o {#4}}}%
  \expandafter\endgroup
  \jlreq@do
}

% \edef内だと，#1 != 0ptならば\hskip \dimexpr#1\relaxになる
\def\jlreq@pagestyle@hskip#1{%
  \dim_compare:nF { #1 = 0pt }{\noexpand\hskip\noexpand\dimexpr#1\noexpand\relax}%
}
\def\jlreq@pagestyle@setheadfoot@#1#2#3#4{%
  \begingroup
    % - \Cdpは端にそろえるための補正
    \jlreq@ifempty{#2}{\def\jlreq@left{}}{\edef\jlreq@left{\jlreq@pagestyle@hskip{\jlreq@expand@speciallength{\jlreq@headfoot@sidemargin}\if@tate - \Cdp\fi}\unexpanded{#2}}}%
    % +\topskip - \Chtは\jlreq@headfoot@sidemargin = 0ptの時に本文の右に一致させるための補正．
    \jlreq@ifempty{#4}{\def\jlreq@right{}}{\edef\jlreq@right{\unexpanded{#4}\jlreq@pagestyle@hskip{\jlreq@expand@speciallength{\jlreq@headfoot@sidemargin}\if@tate + \topskip - \Cht\fi}}}%
    \jlreq@ifempty{#3}{%
      \edef\jlreq@do{\unexpanded{\def#1}{\exp_not:o {\jlreq@left}\hfil\exp_not:o {\jlreq@right}}}%
      \jlreq@ifempty{#2}{\jlreq@ifempty{#4}{\def\jlreq@do{\def#1{}}}{}}{}%
    }{% #3を完全に真ん中に配置するために左右の幅を0にしておく
      \ifx\jlreq@left\@empty\else\edef\jlreq@left{\noexpand\hbox to 0pt{\exp_not:o {\jlreq@left}\noexpand\hss}}\fi
      \ifx\jlreq@right\@empty\else\edef\jlreq@right{\noexpand\hbox to 0pt{\noexpand\hss\exp_not:o {\jlreq@right}}}\fi
      \edef\jlreq@do{%
        \unexpanded{\def#1}{\exp_not:o {\jlreq@left}\hfil\unexpanded{#3}\hfil\exp_not:o {\jlreq@right}}%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}%

% #1の左右に傍注調整用の空白を入れて#1に代入する
\def\jlreq@pagestyle@addsidenotemargin@left#1{%
  \jlreq@pagestyle@addsidenotemargin@{#1}{\jlreq@sidenote@length + \jlreq@sidenote@sep}{}%
}
\def\jlreq@pagestyle@addsidenotemargin@right#1{%
  \jlreq@pagestyle@addsidenotemargin@{#1}{}{\jlreq@sidenote@length + \jlreq@sidenote@sep}%
}
\def\jlreq@pagestyle@addsidenotemargin@bothside#1{%
  \jlreq@pagestyle@addsidenotemargin@{#1}{\jlreq@sidenote@length + \jlreq@sidenote@sep}{\jlreq@sidenote@length + \jlreq@sidenote@sep}%
}
% #2: 左，#3：右，#4：#2 + #3
\def\jlreq@pagestyle@addsidenotemargin@#1#2#3{%
  \ifx#1\@empty\else
    \edef#1{%
      \jlreq@ifempty{#2}{}{\unexpanded{\hskip-\dimexpr #2\relax}}%
      \exp_not:o {#1}%
      \jlreq@ifempty{#3}{}{\unexpanded{\hskip-\dimexpr #3\relax}}%
    }%
  \fi
}

% #1が空かつ#4が空でないならば#2に#3と#4の中身を追加し，#4を空にする．引数は全てコントロールシークエンス
\def\jlreq@pagestyle@addifempty#1#2#3#4{%
  \ifx#1\@empty\ifx#4\@empty\else\tl_put_right:Nx #2{ \exp_not:o {#3}\exp_not:o {#4} }\def#4{}\fi\fi
}

\newif\ifjlreq@PageStyle@first
% #1に入っている{柱1}{柱2}...{柱n}という並びから，実際に出力する柱を構築する．n>=1を仮定する．
% 間に空白を入れる．
% #1: ターゲットなコントロールシークエンスの名前，#2：*ならばreverseする，#3：空き
\def\jlreq@pagestyle@make@runninghead#1#2#3{%
  \jlreq@if{\expandafter\ifx\csname #1\endcsname\@empty\fi}{}{%
    \edef\jlreq@do{%
      \noexpand\jlreq@tempatrue % 最初の処理かフラグ
      \unexpanded{\jlreq@pagestyle@make@runninghead@{#1}{#2}{#3}}\exp_args:Nc \exp_not:o {#1}\noexpand\jlreq@endmark
    }%
    \expandafter\def\csname #1\endcsname{}%
    \jlreq@do
    % 項目が二つ以上あった．
    \ifjlreq@tempa\else\tl_put_left:cn {#1} {\jlreq@PageStyle@firsttrue} \fi
  }%
}
\def\jlreq@pagestyle@make@runninghead@#1#2#3#4#5{%
  \jlreq@if{\ifnum\numexpr\jlreq@ifendmark{#5}{1}{0}*\ifjlreq@tempa 1\else 0\fi\relax=1~\fi}{%
    % 項目が一つしか無い
    \jlreq@ifempty{#2}{\tl_put_right:cn}{\tl_put_left:cn}{#1}{#4}%
  }{%
    % 最初の空でない柱に出会うまでは柱の間の空白を入れない．
    % 空でない柱に出会ってないならば\ifjlreq@PageStyle@firstはtrue．
    % 一番最初の\jlreq@PageStyle@firsttrueは後で入れる．
    \jlreq@ifempty{#2}{\tl_put_right:cn}{\tl_put_left:cn}{#1}{%
      \protected@edef\jlreq@tempa{#4}%
      \ifx\jlreq@tempa\@empty\else
        \ifjlreq@PageStyle@first\else\hskip\glueexpr#3\relax\fi
        \jlreq@tempa
        \jlreq@PageStyle@firstfalse
      \fi
    }%
    \jlreq@tempafalse
    \jlreq@ifendmark{#5}{}{\jlreq@pagestyle@make@runninghead@{#1}{#2}{#3}{#5}}%
  }%
}

% #1= cs，#2 = フォーマットの入ったcs，#3 = デフォルトフォーマットの入ったcs
\def\jlreq@pagestyle@applyformat#1#2#3{%
  % デフォルト時に限り，\hbox to ***{空トークン}を避ける
  \ifnum 0\ifx#1\@empty\else 1\fi\ifx#2\relax\else 1\fi>0
    \edef\jlreq@do{\unexpanded{\def\jlreq@tempa##1}{\ifx#2\relax\exp_not:o {#3}\else\exp_not:o {#2}\fi}}\jlreq@do
    \edef#1{\expandafter\exp_not:o \expandafter{\expandafter\jlreq@tempa\expandafter{#1}}}%
  \fi
}

% フォント情報を追加する．#1：制御綴り名，#2：フォント命令の入っている制御綴名，#1に返す
\def\jlreq@pagestyle@addfont@tocs#1#2{%
  \expandafter\ifx\csname #1\endcsname\@empty\else
    \expandafter\ifx\csname #2\endcsname\@empty\else
      \expandafter\edef\csname #1\endcsname{{\exp_args:Nc \exp_not:o {#2}\exp_args:Nc \exp_not:o {#1}}}%
    \fi
  \fi
}
% こちらは#1にトークン列を与える．\edefで展開される．制御綴名#3に代入．
\def\jlreq@pagestyle@addfont@totokens#1#2#3{%
  \begingroup
    \edef\jlreq@do{\noexpand\edef\exp_not:c {#3}{\unexpanded{#1}}}%
    \expandafter\ifx\csname #2\endcsname\@empty\else
      \edef\jlreq@tempa{#1}%
      \ifx\jlreq@tempa\@empty\else
        \edef\jlreq@do{%
          \noexpand\edef\exp_not:c {#3}{\noexpand\unexpanded{%
            {\exp_args:Nc \exp_not:o {#2}\exp_not:o {\jlreq@tempa}}%
          }}%
        }%
      \fi
    \fi
  \expandafter\endgroup
  \jlreq@do
}

%.. \DeclarePageStyle
\newbox\jlreq@PageStyle@box
\NewDocumentCommand{\DeclarePageStyle} { m +m } {%
  \expandafter\edef\csname jlreq@pagestyle@setting@#1\endcsname{\unexpanded{#2}}%
  \begingroup
    % フォーマットを空という可能性もあるかもしれないので，デフォルト値は\relaxで表す．
    \let\jlreq@oddheadformat\relax
    \let\jlreq@evenheadformat\relax
    \let\jlreq@oddfootformat\relax
    \let\jlreq@evenfootformat\relax
    % 柱とノンブルの間
    \newif\ifjlreq@clearmarkcommand
    \newif\ifjlreq@pstate % PageStyleTATE
    \keys_define:nn { PageStyle:#1 } {
      tate .code:n = {\jlreq@pstatetrue},
      yoko .code:n = {\jlreq@pstatefalse},
      nombre .tl_set:N = \jlreq@nombre@i,
      nombre_position .tl_set:N = \jlreq@nombre@i@position,
      running_head_position .tl_set:N = \jlreq@running@head@i@position,
      odd_running_head .tl_set:N = \jlreq@odd@running@head@i,
      even_running_head .tl_set:N = \jlreq@even@running@head@i,
      font .code:n = {
        \def\jlreq@nombre@font{##1}%
        \def\jlreq@running@head@font{##1}%
      },
      nombre_font .tl_set:N = \jlreq@nombre@font,
      running_head_font .tl_set:N = \jlreq@running@head@font,
      mark_format .code:n = {\edef\jlreq@mark@format{\unexpanded{##1}}},
      command .code:n = {\edef\jlreq@command{\unexpanded{##1}}},
      gap .tl_set:N = \jlreq@gap,
      nombre_gap .tl_set:N = \jlreq@nombre@gap,
      running_head_gap .tl_set:N = \jlreq@running@head@gap,
      % trueにすると，\ps@***実行時にまず\***markを全て\@gobbleにする．
      clear_markcommand .choices:nn = {true,false}{\csname jlreq@clearmarkcommand##1\endcsname},
      odd_head_format .code:n = {\edef\jlreq@oddheadformat{\unexpanded{##1}}},
      even_head_format .code:n = {\edef\jlreq@evenheadformat{\unexpanded{##1}}},
      odd_foot_format .code:n = {\edef\jlreq@oddfootformat{\unexpanded{##1}}},
      even_foot_format .code:n = {\edef\jlreq@evenfootformat{\unexpanded{##1}}},
      % 二つ目
      nombre_ii .tl_set:N = \jlreq@nombre@ii,
      nombre_ii_position .tl_set:N = \jlreq@nombre@ii@position,
      running_head_ii_position .tl_set:N = \jlreq@running@head@ii@position,
      odd_running_head_ii .tl_set:N = \jlreq@odd@running@head@ii,
      even_running_head_ii .tl_set:N = \jlreq@even@running@head@ii,
      nombre_ii_font .tl_set:N = \jlreq@nombre@ii@font,
      running_head_ii_font .tl_set:N = \jlreq@running@head@ii@font,
      % 三つ目
      nombre_iii .tl_set:N = \jlreq@nombre@iii,
      nombre_iii_position .tl_set:N = \jlreq@nombre@iii@position,
      running_head_iii_position .tl_set:N = \jlreq@running@head@iii@position,
      odd_running_head_iii .tl_set:N = \jlreq@odd@running@head@iii,
      even_running_head_iii .tl_set:N = \jlreq@even@running@head@iii,
      nombre_iii_font .tl_set:N = \jlreq@nombre@iii@font,
      running_head_iii_font .tl_set:N = \jlreq@running@head@iii@font
    }
    \keys_set:nn { PageStyle:#1 } {
      yoko,
      nombre_font = {}, nombre_position = {}, nombre = {\thepage},
      nombre_ii_font = {}, nombre_ii_position = {}, nombre_ii = {},
      nombre_iii_font = {}, nombre_iii_position = {}, nombre_iii = {},
      running_head_font = {}, running_head_position = {}, odd_running_head = {}, even_running_head = {}, 
      running_head_ii_font = {}, running_head_ii_position = {}, odd_running_head_ii = {}, even_running_head_ii = {}, 
      running_head_iii_font = {}, running_head_iii_position = {}, odd_running_head_iii = {}, even_running_head_iii = {}, 
      command = {}, mark_format = {}, gap = {1.5\jlreq@zw}, nombre_gap = {}, running_head_gap = {},
      clear_markcommand = {true}, 
    }
    \keys_set:nn { PageStyle:#1 } {#2}
    % ノンブル同士の間や柱同士の間のデフォルトはノンブルと柱の間の空き量
    \ifx\jlreq@nombre@gap\@empty\let\jlreq@nombre@gap=\jlreq@gap\fi
    \ifx\jlreq@running@head@gap\@empty\let\jlreq@running@head@gap=\jlreq@gap\fi
    % _iiが存在するか調べて\ifjlreq@headii@existに入れる
    \newif\ifjlreq@headii@exist
    \jlreq@headii@existfalse
    \clist_map_inline:nn { \jlreq@odd@running@head@ii, \jlreq@odd@running@head@ii } {
      \tl_if_empty:VF ##1 { \jlreq@headii@existtrue }
    }%
    % markの処理
    % (odd|even)_running_head(_ii)が_<見出し命令>で与えられている場合，次のようにする．
    % * \jlreq@(odd|even)@running@head(@ii)をマーク出力命令（\(left|right)mark or \jlreq@extra(left|right)mark{<num>}）に書き換える
    %   - evenの場合はleft，oddの場合はright．
    %   - @iiがなければ\(left|right)mark，@iiがあれば\jlreq@extra(left|right)mark{1}
    % * 例えば_<見出し命令>が_sectionならば，\jlreq@markdata@sectionに{{<I1>}{<I2>}{<I3>}}を追加する．ここで<I1>，<I2>，<I3>は
    %   - I1: @iiが無いときにodd or even
    %   - I2: @iiが無ければ0，あれば1．
    %   - I3: マーク出力命令がleftかrightに応じて l or r．（上述のようにoddかevenかで判定される．）
    % * 他にも_sectionが指定されている柱があれば，\jlreq@markdata@sectionにさらに追加で加えていく．
    % * \jlreq@(odd|even)@running@head(@ii)@heading@levelに<見出し命令>のレベルを入れる．レベルが不明な時は\relaxになる．
    % また，\jlreq@headingmarklistに<見出し命令>の一覧を入れる．
    \def\jlreq@headingmarklist{}%
    \clist_map_variable:nNn { odd, even } \jlreq@parity {
      \clist_map_variable:nNn { 0, 1, 2 } \jlreq@i {
        % \jlreq@pagestyle@setmarkが上の処理を行う．
        \edef\jlreq@next{\noexpand\jlreq@pagestyle@setmark{\exp_not:c {jlreq@\jlreq@parity @running@head@\@roman\numexpr\jlreq@i + 1\relax}}{\exp_not:o {\jlreq@i}}{\exp_not:o {\jlreq@parity}}{jlreq@markdata}{\noexpand\jlreq@headingmarklist}}%
        \jlreq@next
      }%
    }%
    % \jlreq@minimumlevelに見出しの最低（数値が小さいという意味）レベルを入れる．
    \let\jlreq@minimumlevel=\@undefined
    \def\jlreq@markdefinecommand{}%
    \exp_args:No \clist_map_variable:nNn \jlreq@headingmarklist \jlreq@heading {
      \ifx\jlreq@heading\@empty\else
        \expandafter\let\expandafter\jlreq@level\csname jlreq@heading@level@\jlreq@heading\endcsname
        \ifx\jlreq@level\relax\else
          \ifx\jlreq@minimumlevel\@undefined\let\jlreq@minimumlevel=\jlreq@level
          \else\ifnum\jlreq@minimumlevel>\jlreq@level\space\let\jlreq@minimumlevel=\jlreq@level\fi\fi
        \fi
        % \jlreq@markdata@<見出し命令>にある情報とmark_formatをもとに，\<見出し命令>markを定義するマクロを作成，\jlreq@markdefinecommandに入れる．
        \edef\jlreq@do{\noexpand\jlreq@pagestyle@make@headingmark{\ifjlreq@headii@exist *\fi}{\exp_not:o {\jlreq@heading}}{\exp_not:o {\jlreq@mark@format}}{\exp_args:Nc \exp_not:o {jlreq@markdata@\jlreq@heading}}}%
        \jlreq@do
        \tl_put_right:Nx \jlreq@markdefinecommand { \exp_not:o {\jlreq@result} }%
      \fi
    }%
    \ifx\jlreq@minimumlevel\@undefined\else
      \tl_put_right:Nx \jlreq@markdefinecommand { \exp_not:N \jlreq@pagestyle@setclearmark { \exp_not:o {\jlreq@minimumlevel} } }
    \fi
    % 見出しを出す場合：evenに章などの高いレベルの見出しを出す（2.6.3.a）
    \@ifundefined{jlreq@odd@running@head@i@heading@level}{}{\@ifundefined{jlreq@even@running@head@i@heading@level}{}{%
      \ifnum\jlreq@odd@running@head@i@heading@level<\jlreq@even@running@head@i@heading@level
        \jlreq@note{偶数ページには奇数ページよりアウトラインレベルの高い見出しを入れる (ページスタイル #1 内，2.6.3.a)．}%
      \fi
    }}%
    % 二番目以降にフォント設定を追加
    \clist_map_variable:nNn { ii, iii } \jlreq@i {
      \clist_map_variable:nNn { odd, even } \jlreq@parity {
        \jlreq@pagestyle@addfont@tocs{jlreq@\jlreq@parity @running@head@\jlreq@i}{jlreq@running@head@\jlreq@i @font}%
      }%
      \jlreq@pagestyle@addfont@tocs{jlreq@nombre@\jlreq@i}{jlreq@nombre@\jlreq@i @font}%
    }%
    % \jlreq@oddhead,\jlreq@oddfoot,\jlreq@evenhead,\jlreq@evenfootに必要なものを入れる．
    \jlreq@if{\ifjlreq@pstate\fi}{% tate
      % headの方に処理を入れる．footは空．
      \def\jlreq@oddfoot{}\def\jlreq@evenfoot{}%
      \ifx\jlreq@nombre@i@position\@empty\def\jlreq@nombre@i@position{5\jlreq@zw}\fi
      \ifx\jlreq@running@head@i@position\@empty\def\jlreq@running@head@i@position{4\jlreq@zw}\fi
      \edef\jlreq@gapcs{\noexpand\hskip\noexpand\glueexpr\exp_not:o {\jlreq@nombre@gap}\noexpand\relax}%
      \jlreq@pagestyle@addifempty{\jlreq@nombre@iii@position}{\jlreq@nombre@ii}{\jlreq@gapcs}{\jlreq@nombre@iii}%
      \jlreq@pagestyle@addifempty{\jlreq@nombre@ii@position}{\jlreq@nombre@i}{\jlreq@gapcs}{\jlreq@nombre@ii}%
      \edef\jlreq@gapcs{\noexpand\hskip\noexpand\glueexpr\exp_not:o {\jlreq@running@head@gap}\noexpand\relax}%
      \jlreq@pagestyle@addifempty{\jlreq@running@head@iii@position}{\jlreq@odd@running@head@ii}{\jlreq@gapcs}{\jlreq@odd@running@head@iii}%
      \jlreq@pagestyle@addifempty{\jlreq@running@head@ii@position}{\jlreq@odd@running@head@i}{\jlreq@gapcs}{\jlreq@odd@running@head@ii}%
      \jlreq@pagestyle@addifempty{\jlreq@running@head@iii@position}{\jlreq@even@running@head@ii}{\jlreq@gapcs}{\jlreq@even@running@head@iii}%
      \jlreq@pagestyle@addifempty{\jlreq@running@head@ii@position}{\jlreq@even@running@head@i}{\jlreq@gapcs}{\jlreq@even@running@head@ii}%
      \def\jlreq@nombre@contents{}% ノンブルを入れる（下の方に出力）
      \clist_map_variable:nNn { i, ii, iii } \jlreq@i {
        \expandafter\let\expandafter\jlreq@position\csname jlreq@nombre@\jlreq@i @position\endcsname
        \expandafter\ifx\csname jlreq@nombre@\jlreq@i\endcsname\@empty\else
          \jlreq@ifgluezero{\glueexpr\jlreq@position\relax}{\def\jlreq@position{}}{}%
          \expandafter\let\expandafter\jlreq@tempa\expandafter=\csname jlreq@nombre@\jlreq@i\endcsname
          \jlreq@pagestyle@addfont@tocs{jlreq@tempa}{jlreq@nombre@font}%
          \tl_put_right:Nx \jlreq@nombre@contents {%
            \exp_not:N \hbox to 0pt{\exp_not:N \hss
              \exp_not:o {\jlreq@tempa}%
              \ifx\jlreq@position\@empty\else\exp_not:n {\hskip \glueexpr}\exp_not:o {\jlreq@position}\exp_not:N \relax\fi
            }%
          }%
        \fi
      }%
      % \jlreq@(odd|even)@contentsに柱を入れる（上の方に出力）
      \clist_map_variable:nNn { odd, even } \jlreq@parity {
        \expandafter\def\csname jlreq@\jlreq@parity @contents\endcsname{}%
        \clist_map_variable:nNn { i, ii, iii } \jlreq@i {
          \expandafter\let\expandafter\jlreq@position\csname jlreq@running@head@\jlreq@i @position\endcsname
          \expandafter\ifx\csname jlreq@\jlreq@parity @running@head@\jlreq@i\endcsname\@empty\else
            \jlreq@ifgluezero{\glueexpr\jlreq@position\relax}{\def\jlreq@position{}}{}%
            \expandafter\let\expandafter\jlreq@tempa\expandafter=\csname jlreq@\jlreq@parity @running@head@\jlreq@i\endcsname
            \jlreq@pagestyle@addfont@tocs{jlreq@tempa}{jlreq@running@head@font}%
            \tl_put_right:cx {jlreq@\jlreq@parity @contents} {%
              \exp_not:N \hbox to 0pt{\exp_not:n {\hskip\glueexpr\headsep + \headheight}%
                \if@tate\else\exp_not:n {+ \topskip - \Cht}\fi
                \ifx\jlreq@position\@empty\else + \exp_not:o {\jlreq@position}\fi\exp_not:N \relax
                \exp_not:o {\jlreq@tempa}%
                \exp_not:N \hss
              }%
            }%
          \fi
        }%
        % \jlreq@(odd|even)headの構築
        % 空き指定には基本版面の文字サイズを使う（2.6.1.c）
        \@ifundefined{jlreq@\jlreq@parity headformat}
          {\def\jlreq@format{####1}}%
          {\expandafter\let\expandafter\jlreq@format\csname jlreq@\jlreq@parity headformat\endcsname}%
        \edef\jlreq@do{\unexpanded{\def\jlreq@tempa##1}{\exp_not:o {\jlreq@format}}}\jlreq@do
        \edef\jlreq@tempb{%
          \exp_args:Nc \exp_not:o {jlreq@\jlreq@parity @contents}%
          \noexpand\hfil
          \exp_not:o {\jlreq@nombre@contents}%
        }%
        \expandafter\edef\csname jlreq@\jlreq@parity head\endcsname{%
          \unexpanded{\setbox\jlreq@tempboxa=\hbox to \dimexpr\headsep + \headheight + \textheight}\if@tate\else\unexpanded{- \topskip + 1\jlreq@zh}\fi\noexpand\relax
          {%
            \unexpanded{\tate\adjustbaseline}%
            \expandafter\exp_not:o \expandafter{\expandafter\jlreq@tempa\expandafter{\jlreq@tempb}}%
          }%
          % Underful対策
          \ifx l\jlreq@engine
            \unexpanded{\wd\jlreq@tempboxa=\headheight}%
          \else
            \unexpanded{\ht\jlreq@tempboxa=\headheight\dp\jlreq@tempboxa=0pt}%
          \fi
        }%
      }%
      % \jlreq@tempboxaを正しく配置する
      \edef\jlreq@lefthead@adjustbox{%
        \noexpand\hskip\noexpand\dimexpr\if@tate\unexpanded{- \Cdp}\fi \unexpanded{- \headsep - 1\jlreq@zw\relax}%
        \unexpanded{\box\jlreq@tempboxa\hfil}%
      }%
      \edef\jlreq@righthead@adjustbox{%
        \noexpand\hskip\unexpanded{\dimexpr\textwidth}\if@tate\unexpanded{- \topskip + \Cht}\fi\unexpanded{ + \headsep\relax}%
        \unexpanded{\box\jlreq@tempboxa\hss}%
      }%
      \if@tate
        \tl_put_right:Nx \jlreq@oddhead{\exp_not:o {\jlreq@lefthead@adjustbox}}%
        \tl_put_right:Nx \jlreq@evenhead{\exp_not:o {\jlreq@righthead@adjustbox}}%
      \else
        \tl_put_right:Nx \jlreq@oddhead{\exp_not:o {\jlreq@righthead@adjustbox}}%
        \tl_put_right:Nx \jlreq@evenhead{\exp_not:o {\jlreq@lefthead@adjustbox}}%
      \fi
    }{% yoko
      % 場所を正規化する．
      \def\jlreq@nombre@i@position@default{{bottom}{center}}%
      \def\jlreq@running@head@i@position@default{{top}{center}}%
      % ii以降の位置は指定されていない場合はiのそれに合わせる
      \clist_map_variable:nNn { jlreq@nombre, jlreq@running@head } \jlreq@tempa {
        \clist_map_variable:nNn { ii, iii } \jlreq@i {
          \expandafter\ifx\csname\jlreq@tempa @\jlreq@i @position\endcsname\@empty
            \expandafter\let\csname\jlreq@tempa @\jlreq@i @position\expandafter\endcsname\csname\jlreq@tempa @i@position\endcsname
          \fi
          \expandafter\edef\csname\jlreq@tempa @\jlreq@i @position@default\endcsname{\csname\jlreq@tempa @i@position@default\endcsname}%
        }%
      }%
      \clist_map_variable:nNn {
        jlreq@nombre@i@position, jlreq@nombre@ii@position, jlreq@nombre@iii@position, jlreq@running@head@i@position, jlreq@running@head@ii@position, jlreq@running@head@iii@position
      } \jlreq@tempa {
        \edef\jlreq@next{\noexpand\jlreq@pagestyle@parse@position{\exp_args:Nc \exp_not:o {\jlreq@tempa}}{\exp_not:c {\jlreq@tempa}}{\exp_args:Nc \exp_not:o {\jlreq@tempa @default}}}%
        \jlreq@next
      }%
      \bool_if:nT { (
        \legacy_if_p:n { @tate } && (
          \str_if_eq_p:ee { \expandafter\@secondoftwo\jlreq@nombre@i@position } { right } ||
          \str_if_eq_p:ee { \expandafter\@secondoftwo\jlreq@running@head@i@position }{ right }
          ))}{
      )) || (
        (! \legacy_if_p:n { @tate } ) && (
          \str_if_eq_p:ee { \expandafter\@secondoftwo\jlreq@nombre@i@position }{ left } ||
          \str_if_eq_p:ee { \expandafter\@secondoftwo\jlreq@running@head@i@position }{ left }
        )
      )}{
        \if@twoside
          \jlreq@note{柱やノンブルは，左ページでは，基本版面の左端の延長線にノンブル又は柱の先頭をそろえて配置するか，基本版面の左端の延長線から基本版面の文字サイズの全角アキだけ右に寄せた位置に配置する (ページスタイル #1 内，2.6.1.b)．}%
        \fi
      }%
      % フォント変更命令に文字出力命令が入っているとエラーになるのを回避するために\setboxでごまかす．
      \setbox\jlreq@tempboxa=\hbox{\jlreq@running@head@font
        \bool_if:nT {
          \dim_compare_p:n { \jlreq@gap < 1.49\jlreq@zw } ||
          ( \dim_compare_p:n { \jlreq@gap > 1.51\jlreq@zw } && \dim_compare_p:n { \jlreq@gap < 1.99\jlreq@zw } ) ||
          \dim_compare_p:n { \jlreq@gap > 2.01\jlreq@zw }
        }{
          \jlreq@note{ノンブルと柱との空き量は柱に使用する文字サイズの2倍又は1.5倍とする (ページスタイル #1 内，2.6.1.c)．}
        }
      }%
      % 初期化
      \clist_map_variable:nNn { odd, even } \jlreq@parity {
        \clist_map_variable:nNn { top, bottom } \jlreq@vert {
          \clist_map_variable:nNn { left, center, right } \jlreq@hor {
            \clist_map_variable:nNn { nombre, running@head } \jlreq@type {
              \expandafter\def\csname jlreq@\jlreq@type @\jlreq@parity @\jlreq@vert @\jlreq@hor\endcsname{}%
            }%
          }%
        }%
        % ページが左か右か
        \jlreq@ifleftpage{\jlreq@parity}{\def\jlreq@pagehor{left}}{\def\jlreq@pagehor{right}}%
        % \jlreq@(running@head|nombre)@(odd|even)@(top|bottom)@(left|center|right)に入れていく
        % 左ページではノンブルが左（2.6.1.c），i,ii,...はiが左になるようにする．
        \clist_map_variable:nNn { i, ii, iii } \jlreq@i {
          % nombre
          \expandafter\ifx\csname jlreq@nombre@\jlreq@i\endcsname\@empty\else
            \edef\jlreq@position{\csname jlreq@nombre@\jlreq@i @position\endcsname}%
            \edef\jlreq@vert{\expandafter\@firstoftwo\jlreq@position}%
            \edef\jlreq@hor{\expandafter\@secondoftwo\jlreq@position}%
            \str_if_eq:VnT \jlreq@parity { even } {\jlreq@reverse@leftright{\jlreq@hor}}
            \jlreq@ifleftpage{\jlreq@parity}{\let\jlreq@addtocs=\tl_put_right:cx}{\let\jlreq@addtocs\tl_put_left:cx}%
            \edef\jlreq@csname{jlreq@nombre@\jlreq@parity @\jlreq@vert @\jlreq@hor}%
            \expandafter\ifx\csname\jlreq@csname\endcsname\@empty\else\jlreq@addtocs{\jlreq@csname}{\unexpanded{\hskip\glueexpr}\exp_not:o {\jlreq@nombre@gap}\noexpand\relax}\fi
            \jlreq@addtocs{\jlreq@csname}{\exp_args:Nc \exp_not:o {jlreq@nombre@\jlreq@i}}%
          \fi
          % running@head
          % 一度「紙面の外から」の順番で{A}{B}{C}と入れる
          \expandafter\ifx\csname jlreq@\jlreq@parity @running@head@\jlreq@i \endcsname\@empty\else
            \edef\jlreq@position{\csname jlreq@running@head@\jlreq@i @position\endcsname}%
            \edef\jlreq@vert{\expandafter\@firstoftwo\jlreq@position}%
            \edef\jlreq@hor{\expandafter\@secondoftwo\jlreq@position}%
            \str_if_eq:VnT \jlreq@parity { even } {\jlreq@reverse@leftright{\jlreq@hor}}
            \str_if_eq:VVTF \jlreq@hor \jlreq@pagehor {\let\jlreq@addtocs=\tl_put_right:cx}{\let\jlreq@addtocs=\tl_put_left:cx}%
            \edef\jlreq@csname{jlreq@running@head@\jlreq@parity @\jlreq@vert @\jlreq@hor}%
            \jlreq@addtocs{\jlreq@csname}{{\exp_args:Nc \exp_not:o {jlreq@\jlreq@parity @running@head@\jlreq@i}}}%
          \fi
        }%
        % {A}{B}{C}の順だった柱を結合する．本体は\jlreq@pagestyle@make@runninghead．
        \clist_map_variable:nNn { top, bottom } \jlreq@vert {
          \clist_map_variable:nNn { left, center, right } \jlreq@hor {
            \str_if_eq:VnTF \jlreq@hor { right } { \def\jlreq@tempa{*} } { \def\jlreq@tempa{} }
            \edef\jlreq@do{\noexpand\jlreq@pagestyle@make@runninghead{jlreq@running@head@\jlreq@parity @\jlreq@vert @\jlreq@hor}{\exp_not:o {\jlreq@tempa}}{\exp_not:o {\jlreq@running@head@gap}}}%
            \jlreq@do
          }%
        }%
        % ノンブルと柱を結合し，必要ならばフォント設定をする．
        \clist_map_variable:nNn { top, bottom } \jlreq@vert {%
          \clist_map_variable:nNn { left, center, right } \jlreq@hor {%
            \edef\jlreq@csname{jlreq@\jlreq@parity @\jlreq@vert @\jlreq@hor}%
            \edef\jlreq@runheadcsname{jlreq@running@head@\jlreq@parity @\jlreq@vert @\jlreq@hor}%
            \edef\jlreq@nombrecsname{jlreq@nombre@\jlreq@parity @\jlreq@vert @\jlreq@hor}%
            % nombreにフォント設定を追加．
            \expandafter\ifx\csname\jlreq@nombrecsname\endcsname\@empty\else
              \ifx\jlreq@nombre@font\@empty\else
                \expandafter\edef\csname\jlreq@nombrecsname\endcsname{{\exp_not:o {\jlreq@nombre@font}\exp_args:Nc \exp_not:o {\jlreq@nombrecsname}}}%
              \fi
            \fi
            \jlreq@if{\expandafter\ifx\csname\jlreq@runheadcsname\endcsname\@empty\fi}{%
              % 柱が空：ノンブルのみでよい
              \expandafter\let\csname\jlreq@csname\expandafter\endcsname\csname\jlreq@nombrecsname\endcsname
            }{%
              \jlreq@if{\expandafter\ifx\csname\jlreq@nombrecsname\endcsname\@empty\fi}{%
%                % ノンブルが空．柱のみでよい．
                \jlreq@pagestyle@addfont@tocs{\jlreq@runheadcsname}{jlreq@running@head@font}%
                \expandafter\let\csname\jlreq@csname\expandafter\endcsname\csname\jlreq@runheadcsname\endcsname
              }{%
%                % 両方ある場合：左ページではノンブルが左，右ページではノンブルが右．
                \jlreq@ifleftpage{\jlreq@parity}{%
                  \str_if_eq:VnTF \jlreq@hor { right } {
                    % <ノンブル><空き><柱>，右寄せ
                    % 柱が空出ないときに限り<空き>を入れる．
                    \jlreq@pagestyle@addfont@totokens{\exp_not:N \dim_compare:nF { \exp_not:n { \wd\jlreq@PageStyle@box=0pt } } { \exp_not:N \hskip\exp_not:o {\jlreq@gap}\exp_not:N \relax } }{jlreq@running@head@font}{jlreq@tempa}%
                    \expandafter\edef\csname\jlreq@csname\endcsname{%
                      \unexpanded{\setbox\jlreq@PageStyle@box=\hbox}{\exp_not:o {\jlreq@running@head@font}\exp_args:Nc \exp_not:o {\jlreq@runheadcsname}}%
                      \exp_args:Nc \exp_not:o {\jlreq@nombrecsname}\exp_not:o {\jlreq@tempa}\unexpanded{\box\jlreq@PageStyle@box}%
                    }%
                  }{%
                    % <ノンブル><空き><柱>，左寄せ
                    % ノンブルは常に空ではないと仮定する．
                    \jlreq@pagestyle@addfont@totokens{\unexpanded{\hskip\glueexpr}\exp_not:o {\jlreq@gap}\noexpand\relax\exp_args:Nc \exp_not:o {\jlreq@runheadcsname}}{jlreq@running@head@font}{jlreq@tempa}%
                    \expandafter\edef\csname\jlreq@csname\endcsname{\exp_args:Nc \exp_not:o {\jlreq@nombrecsname}\exp_not:o {\jlreq@tempa}}%
                  }%
                }{%
                  \str_if_eq:VnTF \jlreq@hor { left } {
                    % <柱><空き><ノンブル>，左寄せ
                    \jlreq@pagestyle@addfont@totokens{%
                      \unexpanded{\setbox\jlreq@PageStyle@box=\hbox}{\exp_args:Nc \exp_not:o {\jlreq@runheadcsname}}%
                      \unexpanded{\copy\jlreq@PageStyle@box}
                      \exp_not:N \dim_compare:nF { \exp_not:n { \wd\jlreq@PageStyle@box=0pt } } {
                        \exp_not:n { \hskip\glueexpr } \exp_not:o {\jlreq@gap} \exp_not:N \relax
                      }
                    }{jlreq@running@head@font}{jlreq@tempa}%
                    \expandafter\edef\csname\jlreq@csname\endcsname{\exp_not:o {\jlreq@tempa}\exp_args:Nc \exp_not:o {\jlreq@nombrecsname}}%
                  }{%
                    % <柱><空き><ノンブル>，右寄せ
                    \jlreq@pagestyle@addfont@totokens{\exp_args:Nc \exp_not:o {\jlreq@runheadcsname}\unexpanded{\hskip\glueexpr}\exp_not:o {\jlreq@gap}\noexpand\relax}{jlreq@running@head@font}{jlreq@tempa}%
                    \expandafter\edef\csname\jlreq@csname\endcsname{\exp_not:o {\jlreq@tempa}\exp_args:Nc \exp_not:o {\jlreq@nombrecsname}}%
                  }%
                }%
              }%
            }%
          }%
        }%
      }%
      % 四カ所構築
      \jlreq@pagestyle@setheadfoot{\jlreq@oddhead}{jlreq@odd@top@left}{jlreq@odd@top@center}{jlreq@odd@top@right}%
      \jlreq@pagestyle@setheadfoot{\jlreq@oddfoot}{jlreq@odd@bottom@left}{jlreq@odd@bottom@center}{jlreq@odd@bottom@right}%
      \jlreq@pagestyle@setheadfoot{\jlreq@evenhead}{jlreq@even@top@left}{jlreq@even@top@center}{jlreq@even@top@right}%
      \jlreq@pagestyle@setheadfoot{\jlreq@evenfoot}{jlreq@even@bottom@left}{jlreq@even@bottom@center}{jlreq@even@bottom@right}%
      \bool_if:nTF { \dim_compare_p:n { \jlreq@sidenote@length > 0pt } && (! \legacy_if_p:n { @tate } ) }{
        \def\jlreq@defaultformat{\hss\hbox to \jlreqyokoheadlength{####1}\hss}%
      }{%
        \def\jlreq@defaultformat{####1}%
      }%
      \jlreq@pagestyle@applyformat{\jlreq@oddhead}{\jlreq@oddheadformat}{\jlreq@defaultformat}%
      \jlreq@pagestyle@applyformat{\jlreq@evenhead}{\jlreq@evenheadformat}{\jlreq@defaultformat}%
      \jlreq@pagestyle@applyformat{\jlreq@oddfoot}{\jlreq@oddfootformat}{\jlreq@defaultformat}%
      \jlreq@pagestyle@applyformat{\jlreq@evenfoot}{\jlreq@evenfootformat}{\jlreq@defaultformat}%
      % 傍注用調整
      \ifdim\jlreq@sidenote@length>0pt
        \if@tate\else
          \if@twocolumn
            \jlreq@pagestyle@addsidenotemargin@bothside{\jlreq@oddhead}%
            \jlreq@pagestyle@addsidenotemargin@bothside{\jlreq@oddfoot}%
            \jlreq@pagestyle@addsidenotemargin@bothside{\jlreq@evenhead}%
            \jlreq@pagestyle@addsidenotemargin@bothside{\jlreq@evenfoot}%
          \else
            \jlreq@pagestyle@addsidenotemargin@right{\jlreq@oddhead}%
            \jlreq@pagestyle@addsidenotemargin@right{\jlreq@oddfoot}%
            \jlreq@pagestyle@addsidenotemargin@left{\jlreq@evenhead}%
            \jlreq@pagestyle@addsidenotemargin@left{\jlreq@evenfoot}%
          \fi
        \fi
      \fi
    }%
    \edef\jlreq@do{%
      \noexpand\edef\exp_not:c {ps@#1}{%
        \noexpand\unexpanded{%
          \unexpanded{\def\jlreq@current@pagestyle{#1}}%
          \ifjlreq@clearmarkcommand\unexpanded{\jlreq@heading@execmacro@toallheadings\jlreq@clearheadingmarks}\fi
          \ifjlreq@headii@exist
            \unexpanded{\let\@mkboth=\jlreq@markboth}%
          \else
            \unexpanded{\let\@mkboth=\markboth}%
          \fi
          \unexpanded{\def\@oddhead}{\exp_not:o {\jlreq@oddhead}}%
          \unexpanded{\def\@oddfoot}{\exp_not:o {\jlreq@oddfoot}}%
          \unexpanded{\def\@evenhead}{\exp_not:o {\jlreq@evenhead}}%
          \unexpanded{\def\@evenfoot}{\exp_not:o {\jlreq@evenfoot}}%
          \exp_not:o {\jlreq@markdefinecommand}%
          \exp_not:o {\jlreq@command}%
        }%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\if@tate
  \def\jlreqyokoheadlength{\textheight}
\else
  \ifdim\jlreq@sidenote@length>0pt
    \if@twocolumn
      \def\jlreqyokoheadlength{\dimexpr\textwidth + 2\jlreq@sidenote@length + 2\jlreq@sidenote@sep\relax}
    \else
      \def\jlreqyokoheadlength{\dimexpr\textwidth + \jlreq@sidenote@length + \jlreq@sidenote@sep\relax}
    \fi
  \else
    \def\jlreqyokoheadlength{\dimexpr\textwidth\relax}
  \fi
\fi
\edef\jlreqtateheadlength{\unexpanded{\dimexpr\headsep + \headheight + \textheight}\if@tate\else\unexpanded{- \topskip + 1\jlreq@zh}\fi\noexpand\relax}

\NewDocumentCommand{\NewPageStyle} { m +m } {%
  \expandafter\@ifdefinable\csname ps@#1\endcsname{\DeclarePageStyle{#1}{#2}}%
}
\NewDocumentCommand{\RenewPageStyle} { m +m } {%
  \@ifundefined{ps@#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclarePageStyle{#1}{#2}}%
}
\NewDocumentCommand{\ProvidePageStyle} { m +m } {%
  \@ifundefined{ps@#1}{\DeclarePageStyle{#1}{#2}}{}%
}
\NewDocumentCommand{\ModifyPageStyle} { m +m } {%
  \begingroup
    \@ifundefined{jlreq@pagestyle@setting@#1}{\ClassError{jlreq}{Unknown~pagestyle:~#1}{\@ehc}}{}%
    \expandafter\let\expandafter\setting\expandafter=\csname jlreq@pagestyle@setting@#1\endcsname
    \edef\jlreq@do{\noexpand\RenewPageStyle{#1}{\exp_not:o {\setting},\unexpanded{#2}}}%
  \expandafter\endgroup
  \jlreq@do
}

%. フロート関連
% 4.3.3.dの例，縦組みの時だけど横にも適用……
\setlength{\floatsep}{1\jlreq@gol plus 1\jlreq@gol}
\setlength{\textfloatsep}{1\jlreq@gol plus \baselineskip}
\intextsep=\textfloatsep
\dblfloatsep=\floatsep
\dbltextfloatsep=\textfloatsep
% 残りはデフォルトにしておく．

%. 環境も引数にとる可能性のある\jlreqsetup用マクロ．
% #3={<設定1>,<環境名>=<設定2>}のようなものを受け付ける．
% #2に<設定1>が，#2@<環境名>に<設定2>が入る．#1には#2@<環境名>が定義されている<環境名>をカンマ区切りで入れる．
% \jlreqsetup{X,env=B}の後に\jlreqsetup{Y}を指定すると，env環境に対する設定はYになるようにする．
% ただし\jlreqsetup{env=C,Y}とした場合はenv環境に対してはC．
\long\def\jlreq@jlreqsetup@withenv#1#2#3{%
  \@ifundefined{#1}{\expandafter\def\csname #1\endcsname{}}{}%
  \begingroup
    \def\jlreq@do{}%
    \jlreq@parsekeyval@nokey{%
      \ifjlreq@parsekeyval@nokey@novalue{%
        \tl_put_left:Nx \jlreq@do {%
          \noexpand\edef\exp_not:c {#2}{\unexpanded{\unexpanded{##1}}}
          \noexpand\def\exp_not:c {#1}{}%
        }%
        \clist_map_variable:cNn {#1} \jlreq@tempa {
          \tl_put_left:Nx \jlreq@do {\noexpand\let\exp_not:c {#2@\jlreq@tempa}\noexpand\@undefined}%
        }%
      }{%
        \tl_put_right:Nx \jlreq@do {%
          \noexpand\edef\exp_not:c {#2@##1}{\unexpanded{\unexpanded{##2}}}%
          \unexpanded{\def\jlreq@tempa{\jlreq@helper@removeelement{##1}}}%
          \unexpanded{\expandafter\jlreq@tempa\expandafter}{\exp_not:c {#1}}{\exp_not:c {#1}}%
          \unexpanded{\tl_put_right:cn {#1}{,##1}}%
        }%
      }%
    }{#3}%
  \expandafter\endgroup
  \jlreq@do
}

% #1@#2が定義されていれば\#1@#2の中身に，そうでなければ\#1の中身に展開される．
% 展開は\unexpandedで抑制される．
\def\jlreq@jlreqsetup@withenv@nameuse#1#2{%
  \jlreq@if{\expandafter\ifx\csname #1@#2\endcsname\relax\fi}{\exp_args:Nc \exp_not:o {#1}}{\exp_args:Nc \exp_not:o {#1@#2}}%
}
% 4.3.1 注4
\newlength\abovecaptionskip
\newlength\belowcaptionskip

%. 図表
\newcommand{\@makecaption}[2]{{%
  % \jlreq@tempbに現在の環境を入れる．
  \@ifundefined{@currenvir}{%
    \@ifundefined{@captype}%
      {\def\jlreq@tempb{}}%
      {\let\jlreq@tempb=\@captype}%
  }{\let\jlreq@tempb=\@currenvir}%
  \reset@font\small
  \vskip\abovecaptionskip
  \edef\jlreq@do{\unexpanded{\def\jlreq@tempa##1}{\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@label@format@setting}{\jlreq@tempb}}}%
  \jlreq@do
  \setbox\jlreq@tempboxa=\hbox{\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@label@font@setting}{\jlreq@tempb}#1}%
  \ifdim\wd\jlreq@tempboxa=0pt
    \edef\jlreq@tempa{{\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@font@setting}{\jlreq@tempb}\unexpanded{#2}}}%
  \else
    \edef\jlreq@tempa{%
      {\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@label@font@setting}{\jlreq@tempb}\exp_not:o {\jlreq@tempa{#1}}}%
      \unexpanded{\hskip\glueexpr}\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@after@label@space@setting}{\jlreq@tempb}\noexpand\relax
      {\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@font@setting}{\jlreq@tempb}\unexpanded{#2}}%
    }%
  \fi
  \setbox\@tempboxa=\hbox{\jlreq@tempa}%
  \ifdim\wd\@tempboxa>\hsize\relax
    \edef\jlreq@tempc{\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@align@setting@large}{\jlreq@tempb}}%
  \else
    \global\@minipagefalse
    \edef\jlreq@tempc{\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@align@setting@small}{\jlreq@tempb}}%
  \fi
  \expandafter\let\expandafter\jlreq@align\jlreq@tempc
  \ifx c\jlreq@align\centering\fi
  \ifx r\jlreq@align\raggedleft\fi
  \unhbox\@tempboxa
  \par
  \vskip\belowcaptionskip
}}

\keys_define:nn { jlreqsetup } {caption_font .code:n = {\jlreq@jlreqsetup@withenv{jlreq@@makecaption@font@envlist}{jlreq@@makecaption@font@setting}{#1}}}
\keys_define:nn { jlreqsetup } {caption_label_font .code:n = {\jlreq@jlreqsetup@withenv{jlreq@@makecaption@label@font@envlist}{jlreq@@makecaption@label@font@setting}{#1}}}
\keys_define:nn { jlreqsetup } {caption_label_format .code:n = {\jlreq@jlreqsetup@withenv{jlreq@@makecaption@label@format@envlist}{jlreq@@makecaption@label@format@setting}{#1}}}
\keys_define:nn { jlreqsetup } {caption_after_label_space .code:n = {\jlreq@jlreqsetup@withenv{jlreq@@makecaption@after@label@space@envlist}{jlreq@@makecaption@after@label@space@setting}{#1}}}

%% 
%% \jlreq@@makecaption@align@setting@small(@env)に小さい時のalign，jlreq@@makecaption@align@setting@large(@env)に大きいときのalignを入れる．
%% \l_jlreq_tmpb_tlに各環境の設定クリア
%% \l_jlreq_tmpc_tlにsmall/largeどちらのも設定
%% \l_jlreq_tmpd_tlにlarge設定
%% #1=env，#2=値
\clist_new:N \g__jlreq_@makecaption_align_envlist_clist
\cs_set:Nn \__jlreq_@makecaption_align_set:nn {
  \str_case:nnF {#2} {
    { center }  { \__jlreq_@makecaption_align_set_aux:nnn {#1} { } {c} }
    { left }    { \__jlreq_@makecaption_align_set_aux:nnn {#1} { } {l} }
    { right }   { \__jlreq_@makecaption_align_set_aux:nnn {#1} { } {r} }
    { top }     { \__jlreq_@makecaption_align_set_aux:nnn {#1} { } {l} }
    { bottom }  { \__jlreq_@makecaption_align_set_aux:nnn {#1} { } {r} }
    { *center } { \__jlreq_@makecaption_align_set_aux:nnn {#1} {*} {c} }
    { *left }   { \__jlreq_@makecaption_align_set_aux:nnn {#1} {*} {l} }
    { *right }  { \__jlreq_@makecaption_align_set_aux:nnn {#1} {*} {r} }
    { *top }    { \__jlreq_@makecaption_align_set_aux:nnn {#1} {*} {l} }
    { *bottom } { \__jlreq_@makecaption_align_set_aux:nnn {#1} {*} {r} }
  }{
    \ClassWarning { jlreq } { Unknown~position~`#2`~in~caption_align,~ignored }
  }
}
\cs_generate_variant:Nn \__jlreq_@makecaption_align_set:nn { VV }
\cs_set:Nn \__jlreq_@makecaption_align_set_aux:nnn {
  \tl_if_empty:nTF {#1} {
    \clist_map_inline:Nn \g__jlreq_@makecaption_align_envlist_clist {
      \tl_put_right:Nx \l_jlreq_tmpb_tl {
        \exp_not:N \let \exp_not:c {jlreq@@makecaption@align@setting@large##1}=\exp_not:N \@undefined
      }
      \tl_if_empty:nT {#2} {
        \tl_put_right:Nx \l_jlreq_tmpb_tl {
          \exp_not:N \let \exp_not:c {jlreq@@makecaption@align@setting@small##1}=\exp_not:N \@undefined
        }
      }
    }
  }{
    \tl_put_right:Nn \l_jlreq_tmpb_tl {
      \clist_gput_right:Nn \g__jlreq_@makecaption_align_envlist_clist {#1}
    }
  }
  \tl_if_empty:nTF {#2} {
    \tl_put_right:Nn \l_jlreq_tmpc_tl {
      \expandafter\let\csname jlreq@@makecaption@align@setting@small#1\endcsname=#3
      \expandafter\let\csname jlreq@@makecaption@align@setting@large#1\endcsname=#3
    }
  }{
    \tl_put_right:Nn \l_jlreq_tmpd_tl {
      \expandafter\let\csname jlreq@@makecaption@align@setting@large#1\endcsname=#3
    }
  }
}
\cs_set:Nn \__jlreq_@makecaption_align_set_with_check_value:nn {
  \tl_if_empty:nTF {#2}
    { \__jlreq_@makecaption_align_set:nn {}    {#1} }
    { \__jlreq_@makecaption_align_set:nn {@#1} {#2} }
}
\cs_generate_variant:Nn \__jlreq_@makecaption_align_set_with_check_value:nn {Vn}

\keys_define:nn { __jlreqsetup_caption_align } {
  center .code:n =  { \__jlreq_@makecaption_align_set_with_check_value:Vn \l_keys_key_str {#1} },
  left .code:n =    { \__jlreq_@makecaption_align_set_with_check_value:Vn \l_keys_key_str {#1} },
  right .code:n =   { \__jlreq_@makecaption_align_set_with_check_value:Vn \l_keys_key_str {#1} },
  top .code:n =     { \__jlreq_@makecaption_align_set_with_check_value:Vn \l_keys_key_str {#1} },
  bottom .code:n =  { \__jlreq_@makecaption_align_set_with_check_value:Vn \l_keys_key_str {#1} },
  *center .code:n = { \__jlreq_@makecaption_align_set_with_check_value:Vn \l_keys_key_str {#1} },
  *left .code:n =   { \__jlreq_@makecaption_align_set_with_check_value:Vn \l_keys_key_str {#1} },
  *right .code:n =  { \__jlreq_@makecaption_align_set_with_check_value:Vn \l_keys_key_str {#1} },
  *top .code:n =    { \__jlreq_@makecaption_align_set_with_check_value:Vn \l_keys_key_str {#1} },
  *bottom .code:n = { \__jlreq_@makecaption_align_set_with_check_value:Vn \l_keys_key_str {#1} },
  unknown .code:n = {
    \clist_map_variable:nNn {#1} \l_jlreq_tmpa_tl {
      \tl_trim_spaces:N \l_jlreq_tmpa_tl
      \str_set_eq:NN \l_jlreq_tmpa_str \l_keys_key_str
      \str_put_left:Nn \l_jlreq_tmpa_str {@}
      \__jlreq_@makecaption_align_set:VV \l_jlreq_tmpa_str \l_jlreq_tmpa_tl
    }
  }
}

\keys_define:nn { jlreqsetup } {
  caption_align .code:n = {
    \group_begin:
      \tl_clear:N \l_jlreq_tmpb_tl
      \tl_clear:N \l_jlreq_tmpc_tl
      \tl_clear:N \l_jlreq_tmpd_tl
      \keys_set:nn { __jlreqsetup_caption_align } {#1}
      \cs_set:Nx \l_jlreq_do:{
        \exp_not:o \l_jlreq_tmpb_tl
        \exp_not:o \l_jlreq_tmpc_tl
        \exp_not:o \l_jlreq_tmpd_tl
      }
    \exp_after:wN \group_end:
    \l_jlreq_do:
  }
}

% 特に根拠のない値
\setlength\abovecaptionskip{.5\jlreq@gol}
\setlength\belowcaptionskip{0pt}

%.. figure環境
\newcounter{figure}
\str_if_eq:VnTF \jlreq@article@type { article } {
  \renewcommand{\thefigure}{\@arabic\c@figure}
}{%
  \@addtoreset{figure}{chapter}
  \renewcommand{\thefigure}{\ifnum\c@chapter>\z@\thechapter.\fi \@arabic\c@figure}
}
\newcommand*{\fps@figure}{h}
\newcommand*{\ftype@figure}{1}
\newcommand*{\ext@figure}{lof}
\newcommand*{\fnum@figure}{\figurename\thefigure}
\newenvironment{figure}{\@float{figure}}{\end@float}
\newenvironment{figure*}{\@dblfloat{figure}}{\end@dblfloat}

%.. table環境
\newcounter{table}
\str_if_eq:VnTF \jlreq@article@type { article } {
  \renewcommand{\thetable}{\@arabic\c@table}
}{%
  \@addtoreset{table}{chapter}
  \renewcommand{\thetable}{\ifnum\c@chapter>\z@\thechapter.\fi \@arabic\c@table}
}
\newcommand*{\fps@table}{h}
\newcommand*{\ftype@table}{2}
\newcommand*{\ext@table}{lot}
\newcommand*{\fnum@table}{\tablename\thetable}
\newenvironment{table}{\@float{table}}{\end@float}
\newenvironment{table*}{\@dblfloat{table}}{\end@dblfloat}

%. タイトル周り
\newenvironment{titlepage}{%
  \if@twocolumn
    \@restonecoltrue\onecolumn
  \else
    \@restonecolfalse\newpage
  \fi
  \thispagestyle{empty}%
  \setcounter{page}{1}%
}{%
  \if@restonecol\twocolumn\else\newpage\fi
  \if@twoside\else
    \setcounter{page}{1}%
  \fi
}

\if@titlepage
  \newcommand{\maketitle}{%
    % jarticleとかからあまり変更していない
    \begin{titlepage}%
    \let\footnotesize\small
    \let\footnoterule\relax
    \let\footnote\thanks
    \null\vfil
    \vskip 4\baselineskip
    \begin{center}%
      {\LARGE \@title \par}%
      \vskip\baselineskip%
      {\Large
      \lineskip .75em%
      % 縦書き時には表組み内でも縦書きにするようにする
      \if@tate
        \let\jlreq@temporary@original@ialign=\ialign
        \tl_put_left:Nn \ialign {\unexpanded{\tate\let\ialign=\jlreq@temporary@original@ialign}}{}{}%
      \fi
      \begin{tabular}[t]{c}%
        \@author
      \end{tabular}\par}%
      \vskip\baselineskip
      {\large\@date\par}%
    \end{center}\par
    \@thanks
    \vfil\null
    \end{titlepage}%
  \jlreq@endofmaketitle
  }
\else
  \newcommand{\maketitle}{%
    \par
    \begingroup
      \renewcommand{\thefootnote}{\fnsymbol{footnote}}%
      \renewcommand{\@makefnmark}{\hbox{%
        \jlreq@iftdir{\yoko}{}%
        \rlap{\@textsuperscript{\normalfont\@thefnmark}}%
      }}%
      \renewcommand{\jlreq@referencemark@format}[1]{\@makefnmark}% うーん
      \if@twocolumn
        \ifnum\col@number=\@ne
          \@maketitle
        \else
          \twocolumn[\@maketitle]%
        \fi
      \else
        \newpage
        \global\@topnum\z@
        \@maketitle
      \fi
      % \pagestyle{empty}の時はそのまま．
      \bool_if:nT {!(
        \tl_if_empty_p:o \@oddhead &&
        \tl_if_empty_p:o \@evenhead &&
        \tl_if_empty_p:o \@oddfoot &&
        \tl_if_empty_p:o \@evenfoot
      )} { \thispagestyle{plain} }
      \@thanks
    \endgroup
    \jlreq@endofmaketitle
  }
\fi
% いろいろクリアする．
\def\jlreq@endofmaketitle{%
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\p@thanks\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}%
% \vskipを\baselineskipにしてみた．
\def\@maketitle{%
  \newpage\null
  \vskip 2\baselineskip%
  \begin{center}%
  {\jlreq@keepbaselineskip{\LARGE}\@title\par}%
  \vskip\baselineskip
  {\jlreq@keepbaselineskip{\large}%
    \lineskip .5\jlreq@zh
    % 縦書き時には表組み内でも縦書きにするようにする
    \if@tate
      \let\jlreq@temporary@original@ialign=\ialign
      \tl_put_left:Nn \ialign {\unexpanded{\tate\let\ialign=\jlreq@temporary@original@ialign}}{}{}%
    \fi
    \begin{tabular}[t]{c}%
      \@author
    \end{tabular}%
    \par
  }%
  \ifx\@date\@empty\else
    \vskip\baselineskip
    {\jlreq@keepbaselineskip{\large}\@date}%
  \fi
  \end{center}%
  \par
  \vskip\baselineskip
  \ifvoid\jlreq@abstractbox\else\unvbox\jlreq@abstractbox\fi
}

%.. abstract
\def\jlreq@parhook@abstract{}
\str_if_eq:VnF \jlreq@article@type { book } {
  \newbox\jlreq@abstractbox
  \newcommand*{\abstractname}{概要}
  \if@titlepage
    % articleとかjarticleとかと同じ
    \newenvironment{abstract}{%
      \titlepage
      \null\vfil
      \@beginparpenalty\@lowpenalty
      \begin{center}%
        {\sffamily\gtfamily\bfseries\abstractname}%
        \@endparpenalty\@M
      \end{center}%
      \par
    }{%
      \par\vfil\null\endtitlepage
    }
  \else
    \newenvironment{abstract}{%
      \ifnum0\if@twocolumn\else1\fi\ifjlreq@preamble1\fi>0
        \ifjlreq@preamble
          \ifx l\jlreq@engine\else
            \def\jlreq@parhook@abstract{\futurelet\jlreq@nextchar\jlreq@openbracket@hook}%
            \PushPostHook{par}{\jlreq@parhook@abstract}%
          \fi
        \fi
        % とりあえず全部ボックスに入れる．
        \global\setbox\jlreq@abstractbox=\vtop\bgroup
        \ifjlreq@preamble
          % preamble後っぽく振る舞う
          \@noskipsecfalse
          % \@nodocumentが入っているので一時的に無効化
          \everypar{}%
        \fi
        \if@twocolumn
          \parindent=0pt
          \hsize=\textwidth
          % 後で\@maketitleとともに呼び出されるときは\twcolumn[***]で呼び出される．
          \begin{minipage}[b]{\textwidth}%
        \fi
        \bgroup
        \small
        \parindent=1\jlreq@zw
        \begin{center}%
          {\sffamily\gtfamily\bfseries\abstractname}%
        \end{center}%
        \list{}{%
          \listparindent\parindent
          \itemindent\listparindent
          \labelwidth\z@
          \labelsep\z@
          \leftmargin=2\jlreq@zw
          \rightmargin\leftmargin
          \@tempdima=1\jlreq@zw
          \@tempdimb=\dimexpr\linewidth - \@totalleftmargin - \leftmargin - \rightmargin\relax
          \@tempdimc=\@tempdimb
          \divide\@tempdimb by \@tempdima\multiply\@tempdimb by \@tempdima
          \ifdim\@tempdimb=\@tempdimc\else\@tempdimb=\dimexpr\@tempdimb - 1\jlreq@zw\relax\fi
          \leftmargin=\dimexpr\leftmargin + (\@tempdimc - \@tempdimb)/2\relax
          \rightmargin=\dimexpr\rightmargin + (\@tempdimc - \@tempdimb)/2\relax
          \parsep\z@ \@plus.1\jlreq@zh
        }%
        \item\relax
      \else
        \section*{\abstractname}%
      \fi
    }{%
      \ifnum0\if@twocolumn\else1\fi\ifjlreq@preamble1\fi>0
        \endlist
        \egroup
        \vspace{\baselineskip}%
        \if@twocolumn
          \end{minipage}
        \fi
        \egroup
      \fi
      \ifjlreq@preamble
        \ifx l\jlreq@engine\else
          \def\jlreq@parhook@abstract{}%
        \fi
      \else
        \unvbox\jlreq@abstractbox
      \fi
    }
  \fi
}
%. 箇条書き． cf. JISX4051 8.4
% 用語定義型
\newenvironment{description}{\list{}{%
  \setlength{\labelsep}{1\jlreq@zw}%
  \setlength{\labelwidth}{\dimexpr\leftmargin - \labelsep\relax}%
  \let\makelabel=\descriptionlabel
% 同行じゃない場合はこんな感じ？
%  \let\jlreq@original@@item=\@item
%  \def\@item[##1]{\jlreq@original@@item[##1]\mbox{}\par
  }}{\endlist}
\newcommand{\descriptionlabel}[1]{\normalfont\sffamily\gtfamily\bfseries #1}

%.. 箇条書き
% #3={<設定1>,i=<設定2>,<環境名>={<設定3>,ii=<設定4>}}のような設定を解釈する．
% <設定2>は#2@iに，<設定4>は#2@ii@<環境名>に格納される．
% <設定1>の指定はi=<設定1>,..,vi=<設定1>と等価．<設定3>も同様．
% #1には現在何か値が定義されている環境名をカンマ区切りで入れる．
\long\def\jlreq@jlreqsetup@itemization#1#2#3{
  \@ifundefined{#1}{\expandafter\def\csname #1\endcsname{}}{}%
  \begingroup
    \def\jlreq@generalset{}%
    \def\jlreq@levelset{}%
    \def\jlreq@envset{}%
    \jlreq@parsekeyval@nokey{%
      \ifjlreq@parsekeyval@nokey@novalue{%
        % 生の値．環境に対するものをクリアし，全ての<i-iv>に同じ値を設定
        % 環境一覧リストもクリア．
        \clist_map_variable:nNn {i,ii,iii,iv,v,vi} \jlreq@tempa{
          \clist_map_variable:cNn {#1} \jlreq@tempb {
            \ifx\jlreq@tempb\@empty\else
              \tl_put_right:Nx \jlreq@generalset {
                \noexpand\let\exp_not:c{#2@\jlreq@tempa @\jlreq@tempb}\noexpand\@undefined
              }
            \fi
          }%
          \tl_put_right:Nx \jlreq@generalset {%
            \exp_not:N \edef\exp_not:c {#2@\jlreq@tempa}{\exp_not:n {\exp_not:n {##1}}}%
          }%
        }%
        \tl_put_right:Nn \jlreq@generalset { \expandafter\def\csname #1\endcsname{} }%
      }{%
        \bool_if:nTF{ \str_if_eq_p:nn {##1} {i} || \str_if_eq_p:nn {##1} {ii} || \str_if_eq_p:nn {##1} {iii} || \str_if_eq_p:nn {##1} {iv} || \str_if_eq_p:nn {##1} {v} || \str_if_eq_p:nn {##1} {vi} }{
          % i=とかの時，環境に対応するものをクリアし，\#2@##1に値を入れる
          \clist_map_variable:cNn {#1} \jlreq@tempa {
            \ifx\jlreq@tempa\@empty\else
              \tl_put_left:Nx \jlreq@envset{\noexpand\let\exp_not:c {#2@##1@\jlreq@tempa}\noexpand\@undefined}%
            \fi
          }%
          \tl_put_right:Nx \jlreq@envset{\exp_not:N \edef\exp_not:c{#2@##1}{\exp_not:n {\exp_not:n{##2}}}}%
        }{%
          % そうでないとき，環境．##1 = 環境名
          \jlreq@parsekeyval@nokey{%
            \ifjlreq@parsekeyval@nokey@novalue{%
              % i - viまでに全てセットする．
              \clist_map_variable:nNn {i,ii,iii,iv,v,vi} \jlreq@tempa{
                \tl_put_left:Nx \jlreq@envset{\noexpand\edef\exp_not:c {#2@\jlreq@tempa @##1}{\unexpanded{\unexpanded{####1}}}}%
              }%
            }{%
              % ピンポイント代入
              \tl_put_right:Nx \jlreq@envset {
                \exp_not:N \edef\exp_not:c {#2@####1@##1}{\exp_not:n {\exp_not:n {####2}}}
              }%
            }%
          }{##2}%
          \tl_put_right:Nx \jlreq@envset{%
            \exp_not:n {\def\jlreq@tempa{\jlreq@helper@removeelement{##1}}}%
            \exp_not:n {\expandafter\jlreq@tempa\expandafter}{\exp_not:c{#1}}{\exp_not:c {#1}}%
            \exp_not:N \tl_put_right:Nn \exp_not:c {#1}{\exp_not:n {,##1}}%
          }%
        }%
      }%
    }{#3}%
    \edef\jlreq@do{\exp_not:o {\jlreq@generalset}\exp_not:o {\jlreq@levelset}\exp_not:o {\jlreq@envset}}%
  \expandafter\endgroup
  \jlreq@do
}


\def\jlreq@itemization@beforeafter@space@envlist{}
\keys_define:nn { jlreqsetup } {itemization_beforeafter_space .code:n = {\jlreq@jlreqsetup@itemization{jlreq@itemization@beforeafter@space@envlist}{jlreq@itemization@beforeafter@space@setting}{#1}}}
\keys_define:nn { jlreqsetup } {itemization_itemsep .code:n = {\jlreq@jlreqsetup@withenv{jlreq@itemization@itemsep@envlist}{jlreq@itemization@itemsep@setting}{#1}}}
\keys_define:nn { jlreqsetup } {itemization_labelsep .code:n = {\jlreq@jlreqsetup@withenv{jlreq@itemization@labelsep@envlist}{jlreq@itemization@labelsep@setting}{#1}}}
\keys_define:nn { jlreqsetup } {itemization_label_length .code:n = {\jlreq@jlreqsetup@itemization{jlreq@itemization@label@length@envlist}{jlreq@itemization@label@length@setting}{#1}}}
% enumerate, itemize用初期化，#1 = i,ii,...
\def\jlreq@init@list#1{%
  \setlength{\partopsep}{0pt}%
  \setlength{\itemsep}{\dimexpr\jlreq@jlreqsetup@withenv@nameuse{jlreq@itemization@itemsep@setting}{\@currenvir}\relax}%
  \setlength{\parsep}{0pt}%
  \setlength{\listparindent}{\parindent}%
  \setlength{\labelsep}{\dimexpr\jlreq@jlreqsetup@withenv@nameuse{jlreq@itemization@labelsep@setting}{\@currenvir}\relax}%
  \setlength{\labelwidth}{\dimexpr\jlreq@jlreqsetup@withenv@nameuse{jlreq@itemization@label@length@setting@#1}{\@currenvir}\relax}%
  \setlength{\topsep}{\dimexpr\jlreq@jlreqsetup@withenv@nameuse{jlreq@itemization@beforeafter@space@setting@#1}{\@currenvir}\relax}%
  \setlength{\leftmargin}{\dimexpr\csname leftmargin#1\endcsname}%
  \setlength{\itemindent}{\dimexpr\jlreq@jlreqsetup@withenv@nameuse{jlreq@itemization@label@length@setting@#1}{\@currenvir} + \labelsep - \leftmargin\relax}%
}

\def\@listi{\jlreq@init@list{i}}%
\let\@listI\@listi
\def\@listii{\jlreq@init@list{ii}}
\def\@listiii{\jlreq@init@list{iii}}
\def\@listiv{\jlreq@init@list{iv}}
\def\@listv{\jlreq@init@list{v}}
\def\@listvi{\jlreq@init@list{vi}}

% 引用系．3.5.2の例．
\keys_define:nn { jlreqsetup } { quote_indent .tl_set:N = \jlreq@quote@indent }
\keys_define:nn { jlreqsetup } { quote_end_indent .tl_set:N = \jlreq@quote@end@indent }
\keys_define:nn { jlreqsetup }{
  quote_fontsize .choices:nn = {normalsize,small,footnotesize,scriptsize,tiny,{}}{
    \jlreq@ifempty{#1}{\def\jlreq@quote@fontsize{}}{\edef\jlreq@quote@fontsize{\exp_not:c {#1}}}
  }
}
\keys_define:nn { jlreqsetup } { quote_beforeafter_space .tl_set:N = \jlreq@quote@beforeafter@space }

\newenvironment{verse}
  {\let\\\@centercr
  \list{}{\itemsep\z@ \itemindent -2\jlreq@zw
    \listparindent\itemindent
    \labelwidth\z@
    \labelsep\z@
    \leftmargin=\dimexpr\jlreq@quote@indent\relax
    \addtolength{\leftmargin}{2\jlreq@zw}%
    \rightmargin=\dimexpr\jlreq@quote@end@indent\relax
    \begingroup
      \jlreq@quote@fontsize
      \edef\jlreq@do{\noexpand\@tempdima=\the\dimexpr1\jlreq@zw\relax\relax}%
    \expandafter\endgroup
    \jlreq@do
    \@tempdimb=\dimexpr\linewidth - \@totalleftmargin - \leftmargin - \rightmargin\relax
    \@tempdimc=\@tempdimb
    \divide\@tempdimb by \@tempdima\multiply\@tempdimb by \@tempdima
    \topsep=\dimexpr\jlreq@quote@beforeafter@space\relax
    \leftmargin=\dimexpr\leftmargin + \@tempdimc - \@tempdimb\relax}%
    \item\relax\jlreq@quote@fontsize}{\endlist}
\newenvironment{quotation}
  {\list{}{%
    \leftmargin=\dimexpr\jlreq@quote@indent\relax
    \rightmargin=\dimexpr\jlreq@quote@end@indent\relax
    \begingroup
      \jlreq@quote@fontsize
      \edef\jlreq@do{\noexpand\@tempdima=\the\dimexpr1\jlreq@zw\relax\relax}%
    \expandafter\endgroup
    \jlreq@do
    \@tempdimb=\dimexpr\linewidth - \@totalleftmargin - \leftmargin - \rightmargin\relax
    \@tempdimc=\@tempdimb
    \divide\@tempdimb by \@tempdima\multiply\@tempdimb by \@tempdima
    \leftmargin=\dimexpr\leftmargin + \@tempdimc - \@tempdimb\relax
    \listparindent\parindent
    \itemindent\listparindent
    \labelwidth\z@
    \labelsep\z@
    \topsep=\dimexpr\jlreq@quote@beforeafter@space\relax
    \parsep\z@ \@plus.1\jlreq@gol}%
    \item\relax\jlreq@quote@fontsize}{\endlist}
\newenvironment{quote}
  {\list{}{%
    \leftmargin=\dimexpr\jlreq@quote@indent\relax
    \rightmargin=\dimexpr\jlreq@quote@end@indent\relax
    \begingroup
      \jlreq@quote@fontsize
      \edef\jlreq@do{\noexpand\@tempdima=\the\dimexpr 1\jlreq@zw\relax\relax}%
    \expandafter\endgroup
    \jlreq@do
    \@tempdimb=\dimexpr\linewidth - \@totalleftmargin - \leftmargin - \rightmargin\relax
    \@tempdimc=\@tempdimb
    \divide\@tempdimb by \@tempdima\multiply\@tempdimb by \@tempdima
    \leftmargin=\dimexpr\leftmargin + \@tempdimc - \@tempdimb\relax
    \labelwidth\z@
    \itemindent\z@
    \topsep=\jlreq@speciallength{\jlreq@quote@beforeafter@space}%
    \listparindent\z@}%
    \item\relax\jlreq@quote@fontsize}{\endlist}

%. 表関係 4.4
% 表内の行間を0にする（4.4.3.f）
\jlreq@saveoriginalcs{tabular}
\jlreq@saveoriginalcs{endtabular}
\tl_put_left:Nn \tabular {\begingroup\tl_put_right:Nn \@arrayparboxrestore{\baselineskip=0pt\lineskip=0pt}}
\tl_put_right:Nn \endtabular{\endgroup}
% 4.4.3.e
\setlength\tabcolsep{.5\zh}
\setlength\arraycolsep{.5\zw}
% 4.4.3.j
\setlength\arrayrulewidth{\jlreq@omotekeiwidth} % 4.4.3.c
\setlength\doublerulesep{2pt}
\setlength\tabbingsep{\labelsep}
\skip\@mpfootins=\skip\footins
\setlength\fboxsep{.3\zw}
\setlength\fboxrule{\jlreq@omotekeiwidth} % 根拠はない
% 後で
\str_if_eq:VnTF \jlreq@article@type { article } {
  \renewcommand{\theequation}{\@arabic\c@equation}
}{%
  \@addtoreset{equation}{chapter}
  \renewcommand{\theequation}{\ifnum\c@chapter>\z@\thechapter.\fi \@arabic\c@equation}
}

%. 目次
\setcounter{tocdepth}{3}
\newcommand{\@pnumwidth}{2\jlreq@mol}
\newcommand{\@tocrmarg}{2.55em}
\newcommand{\@dotsep}{2} % 狭くしてみた
\newskip\toclineskip
\setlength\toclineskip{0\jlreq@gol plus .02\jlreq@gol}
% tarticleから
\newdimen\@lnumwidth
\def\numberline#1{\hbox to\@lnumwidth{#1\hfil}}

% from latex.ltx
\legacy_if:nT { @tate } {
  \def\addcontentsline#1#2#3{%
    \addtocontents{#1}{\protect\contentsline{#2}{#3}{\tatechuyoko*{\thepage}}{}%
                       \protected@file@percent}}
}

\newcount\jlreq@top@contents % トップ見出しを入れる．レベルと同じ値．
\jlreq@top@contents=-100
\def\jlreq@set@top@contents#1{%
  \ifnum\jlreq@top@contents=-100
    \jlreq@top@contents=#1\relax
  \fi
}
\str_if_eq:VnTF \jlreq@article@type { article } {
  \newcommand{\tableofcontents}{%
    \jlreq@top@contents=-100\relax
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \section*{\contentsname}%
    \@mkboth{\contentsname}{\contentsname}%
    \@starttoc{toc}%
    \if@restonecol\twocolumn\fi
  }
}{% book, report
  \newcommand{\tableofcontents}{%
    \jlreq@top@contents=-100\relax
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \chapter*{\contentsname}%
    \@mkboth{\contentsname}{\contentsname}%
    \@starttoc{toc}%
    \if@restonecol\twocolumn\fi
  }
}

% JIS X 4051自身の目次に近づけようかと……なりきれてないけど．
% 文字の大きさは全て同じ（\normalsize）にする．
% 見出しのレベルがあがると1文字分ずつ字下げしていく．
% 第三引数は，上からの幅に加え更にトップの見出しからの差による補正（プラス）が入る．
% 補正には\jlreq@top@contentsを使う．
% 「トップ」というか，一番最初に現れた見出しを入れる．
% リーダーは.から・に変更しました．
\def\@dottedtocline#1#2#3#4#5{%
  \jlreq@set@top@contents{#1}%
  \ifnum #1>\c@tocdepth \else
    \vskip\toclineskip
    {\leftskip #2\relax \rightskip \@tocrmarg \parfillskip -\rightskip
    \parindent #2\relax\@afterindenttrue
    \interlinepenalty\@M
    \leavevmode
    \@lnumwidth #3\relax
    \@tempcnta=#1\relax
    \advance\@tempcnta by -\jlreq@top@contents
    \@tempdima=1\jlreq@mol
    \multiply \@tempdima by \@tempcnta
    \advance\leftskip \@lnumwidth \hbox{}\hskip -\leftskip
    \advance\leftskip\@tempdima
    {#4}\nobreak
    \leaders\hbox{$\m@th\mkern \@dotsep mu$\null\inhibitglue ・\inhibitglue\null$\m@th\mkern \@dotsep mu$}%
    \hfill\nobreak
    \hb@xt@\@pnumwidth{\hss\normalfont\normalcolor #5}%
    \par}%
  \fi}

% listoffigures
\newcommand{\listoffigures}{%
  \jlreq@top@contents=-100
  \section*{\listfigurename}%
  \@mkboth{\listfigurename}{\listfigurename}%
  \@starttoc{lof}%
}
\newcommand*{\l@figure}{\@dottedtocline{1}{0\jlreq@gol}{2\jlreq@gol}}
\newcommand{\listoftables}{%
  \jlreq@top@contents=-100
  \section*{\listtablename}%
  \@mkboth{\listtablename}{\listtablename}%
  \@starttoc{lot}%
}
\let\l@table\l@figure

%. 文献，そのまま
\newdimen\bibindent
\setlength\bibindent{2\jlreq@mol}
\newcommand{\newblock}{\hskip .11em\@plus.33em\@minus.07em}
\newenvironment{thebibliography}[1]{%
  \jlreq@oldfontcommand@enable
  \section*{\refname}%
  \@mkboth{\refname}{\refname}%
  \list{\@biblabel{\@arabic\c@enumiv}}%
      {\settowidth\labelwidth{\@biblabel{#1}}%
      \labelsep=1\jlreq@zw
      \leftmargin\labelwidth
      \advance\leftmargin\labelsep
      \itemindent=0pt
      \@openbib@code
      \usecounter{enumiv}%
      \let\p@enumiv\@empty
      \renewcommand\theenumiv{\@arabic\c@enumiv}}%
  \sloppy
  \clubpenalty4000
  \@clubpenalty\clubpenalty
  \widowpenalty4000%
  \sfcode`\.\@m
}{%
  \def\@noitemerr{\@latex@warning{Empty `thebibliography' environment}}%
  \endlist
  \jlreq@oldfontcommand@disable
}
\let\@openbib@code\@empty

%. 索引
\newif\ifjlreq@resttate
\newenvironment{theindex}{%
  \jlreq@oldfontcommand@enable
  \jlreq@iftdir{\clearpage\yoko\jlreq@resttatetrue}{\jlreq@resttatefalse}% 常に横書きにする
  \if@twocolumn\@restonecolfalse\else\@restonecoltrue\fi
  \columnseprule\z@ \columnsep 2\jlreq@mol
  \twocolumn[\section*{\indexname}]%
  \@mkboth{\indexname}{\indexname}%
  \jlreq@theindex@pagestyle
  \parindent\z@
  \parskip\z@ \@plus .03\jlreq@gol\relax
  \let\item\@idxitem
}{%
  \ifx\jlreq@theindex@savedpagestyle\@undefined\else\expandafter\pagestyle\expandafter{\jlreq@theindex@savedpagestyle}\fi
  \let\jlreq@theindex@savedpagestyle\@undefined
  \if@restonecol\onecolumn\else\clearpage\fi
  \ifjlreq@resttate\tate\fi
  \jlreq@oldfontcommand@disable
}
\newcommand{\@idxitem}{\par\hangindent 4\jlreq@mol}
\newcommand{\subitem}{\@idxitem \hspace*{2\jlreq@mol}}
\newcommand{\subsubitem}{\@idxitem \hspace*{3\jlreq@mol}}
\newcommand{\indexspace}{\par \vskip 1\jlreq@gol \@plus .5\jlreq@gol \@minus .3\jlreq@gol\relax}
\def\jlreq@theindex@pagestyle{}
\keys_define:nn { jlreqsetup } {theindex_pagestyle .code:n = {
    \def\jlreq@tempa{}% ページスタイル名
    \def\jlreq@theindex@pagestyle{}%
    \jlreq@tempafalse % restore
    \jlreq@parsekeyval@nokey{%
      \ifjlreq@parsekeyval@nokey@novalue{\def\jlreq@tempa{##1}}{%
        \str_if_eq:nnT {##1} { restore } {
          {restore}{\csname jlreq@tempa##2\endcsname}%
        }%
      }%
    }{#1}%
    \tl_put_right:Nx \jlreq@theindex@pagestyle {
      \exp_not:n {\let\jlreq@theindex@savedpagestyle}\ifjlreq@tempa\exp_not:N \jlreq@current@pagestyle\else\exp_not:N \@undefined\fi
    }%
    \ifx\jlreq@tempa\@empty\else
      \tl_put_right:Nx \jlreq@theindex@pagestyle{\exp_not:N \pagestyle{\exp_not:o \jlreq@tempa}}%
    \fi
  }
}

%. 前付，後付，付録
% \jlreq@matter@heading[restoreする見出し一覧を入れる制御綴]{#2@<見出し命令名>に今の見出しの中身を入れる}{生成する制御綴の名前}{設定}
\def\jlreq@matter@heading{\@ifnextchar[{\jlreq@matter@heading@}{\jlreq@matter@heading@[]{}}}
\def\jlreq@matter@heading@[#1]#2#3#4{%
  \begingroup
    \def\jlreq@restoreheadings{}% 復帰させる見出し名（カンマ区切り）
    \def\jlreq@headingscmds{}% \ModiryHeadings**，\RenewHeadings**の塊
    \jlreq@parsekeyval@nokey{%
      % ##1 = 見出し命令名, ##2 = 設定
      \def\jlreq@headingsettings{}% Modifyする中身
      \def\jlreq@declaretype{Modify}%
      \def\jlreq@level{}%
      \jlreq@tempatrue % restore
      \jlreq@parsekeyval@nokey{%
        % 各見出し命令に対する設定を解析
        \ifjlreq@parsekeyval@nokey@novalue{%
          \tl_put_right:Nx \jlreq@headingsettings {\exp_not:n {####1}}%
        }{%
          \str_case_e:nnF {####1} {%
            {heading_type}{%
              \lowercase{\def\jlreq@tempa{####2}}%
              \str_case_e:nnF { \jlreq@tempa } {
                {tobira}{\def\jlreq@declaretype{RenewTobira}}
                {block}{\def\jlreq@declaretype{RenewBlock}}
                {runin}{\def\jlreq@declaretype{RenewRunin}}
                {cutin}{\def\jlreq@declaretype{RenewCutin}}
                {modify}{\def\jlreq@declaretype{Modify}}
              }{\ClassError{jlreq}{Unknown~heading~type~`####2'}{\@ehc}}
            }
            {heading_level}{\def\jlreq@level{####2}}
          }{%
            \tl_if_empty:nTF {#1} { \@firstofone }{%
              \str_if_eq:nnTF {####1} { restore } {
                \csname jlreq@tempa####2\endcsname\@gobble
              }{\@firstofone}%
            }%
            {\tl_put_right:Nx \jlreq@headingsettings{\ifx\jlreq@headingsettings\@empty\else ,\fi\unexpanded{####1={####2}}}}%
          }%
        }%
      }{##2}%
      \jlreq@ifempty{#1}{}{%
        \ifjlreq@tempa
          \tl_put_right:Nx \jlreq@headingscmds {\exp_not:N \SaveHeading{\exp_not:n {##1}}{\exp_not:c {#2@##1}}}%
          \tl_put_right:Nx \jlreq@restoreheadings {\ifx\jlreq@restoreheadings\@empty\else ,\fi\exp_not:n {##1}}%
        \fi
      }%
      % \jlreq@declareに\ModifyHeadingか\Renew***Headingを入れる
      \edef\jlreq@declare{\exp_not:c {\jlreq@declaretype Heading}{##1}}%
      \str_if_eq:VnF \jlreq@declaretype { Modify } {
        \ifx\jlreq@level\@empty
          % \frontmatter時でのレベルを引用する．
          \edef\jlreq@declare{%
            \unexpanded{\edef\jlreq@tempa}{\noexpand\unexpanded{\exp_not:o {\jlreq@declare}}{\noexpand\exp_not:o {\exp_not:c {jlreq@heading@level@##1}}}}%
            \noexpand\jlreq@tempa
          }%
        \else
          \tl_put_right:Nx \jlreq@declare {{\exp_not:o {\jlreq@level}}}%
        \fi
      }{}%
      \tl_put_right:Nx \jlreq@headingscmds {\exp_not:o {\jlreq@declare}{\exp_not:o {\jlreq@headingsettings}}}%
    }{#4}%
    \edef\jlreq@do{%
      \unexpanded{\def#3}{%
        \exp_not:o {\jlreq@headingscmds}%
        \jlreq@ifempty{#1}{}{\unexpanded{\def#1}{\exp_not:o {\jlreq@restoreheadings}}}%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\def\jlreq@matter@counter@norestore#1#2{%
  \def#1{}%
  \jlreq@parsekeyval@nokey{%
    \keys_define:nn { __jlreq_keyval_matter_counter_norestore } {
      value .code:n = { \tl_put_right:Nn #1 { \setcounter{##1}{####1} } },
      the .code:n = { \tl_put_right:Nx #1 { \exp_not:N \def\exp_not:c {the##1}{\exp_not:n {####1}} } }
    }
    \keys_set:nn { __jlreq_keyval_matter_counter_norestore } {##2}
  }{#2}%
}

\str_if_eq:VnT \jlreq@article@type { book } {
  \newif\if@mainmatter
  \@mainmattertrue
  \keys_define:nn { jlreqsetup } {frontmatter_pagebreak .code:n = {%
    \edef\jlreq@frontmatter@pagebreak{\jlreq@ifempty{#1}{}{\exp_not:c {#1}}}%
  }}
  \keys_define:nn { jlreqsetup } {frontmatter_counter .code:n = {%
      \def\jlreq@frontmatter@counter{}%
      \tl_set:Nn \jlreq@frontmatter@counter { \seq_gclear:N \g__jlreq_frontmatter_resetcounter_seq }
      \jlreq@parsekeyval@nokey{%
        \def\jlreq@tempb{}% 中身
        \jlreq@tempatrue % restore
        \keys_define:nn { frontmatter_counter } {
          value .code:n = { \tl_put_right:Nn \jlreq@tempb{\setcounter{##1}{####1}} },
          restore .code:n = { \csname jlreq@tempa####1\endcsname },
          the .code:n = { \tl_put_right:Nx \jlreq@tempb { \exp_not:N \def\exp_not:c {the##1}{\exp_not:n {####1}} } }
        }
        \keys_set:nn { frontmatter_counter } {##2}
        \ifjlreq@tempa
          \tl_put_left:Nx \jlreq@tempb {%
            \noexpand\let\exp_not:c {jlreq@frontmatter@savedcounter@the@##1}\exp_not:c {the##1}%
            \noexpand\edef\exp_not:c {jlreq@frontmatter@savedcounter@value@##1}{\unexpanded{\the\value{##1}}}%
          }%
          \tl_put_right:Nn \jlreq@frontmatter@counter { \seq_gput_right:Nn \g__jlreq_frontmatter_resetcounter_seq { ##1 } }
        \fi
        \tl_put_right:NV \jlreq@frontmatter@counter \jlreq@tempb
      }{#1}%
    }
  }
  \keys_define:nn { jlreqsetup } {frontmatter_heading .code:n = {\jlreq@matter@heading[\jlreq@frontmatter@restoreheadings]{jlreq@frontmatter@savedheading}{\jlreq@frontmatter@heading}{#1}}}
  \keys_define:nn { jlreqsetup } {frontmatter_pagestyle .code:n = {%
      \def\jlreq@tempa{}% ページスタイル名
      \def\jlreq@frontmatter@pagestyle{}%
      \jlreq@tempatrue % restore
      \jlreq@parsekeyval@nokey{%
        \ifjlreq@parsekeyval@nokey@novalue{\def\jlreq@tempa{##1}}{%
          \str_if_eq:nnT { ##1 } { restore } { \csname jlreq@tempa##2\endcsname }
        }%
      }{#1}%
      \ifjlreq@tempa
        \tl_put_right:Nn \jlreq@frontmatter@pagestyle{\let\jlreq@frontmatter@savedpagestyle\jlreq@current@pagestyle}%
      \fi
      \ifx\jlreq@tempa\@empty\else
        \tl_put_right:Nx \jlreq@frontmatter@pagestyle { \exp_not:N \pagestyle{\exp_not:o {\jlreq@tempa}} }%
      \fi
    }
  }
  \keys_define:nn { jlreqsetup } {frontmatter_precode .code:n = {\edef\jlreq@frontmatter@precode{\unexpanded{#1}}}}
  \keys_define:nn { jlreqsetup } {frontmatter_postcode .code:n = {\edef\jlreq@frontmatter@postcode{\unexpanded{#1}}}}
  \keys_define:nn { jlreqsetup } {frontmatter_pagination .code:n = {%
      \def\jlreq@pagination@frontmatterstyle{arabic}%
      \let\jlreq@pagination@mainmatterpagecommand=\pagenumbering
      \clist_map_variable:nNn {#1} \jlreq@tempa {
        \tl_set:Nx \jlreq@tempa { \tl_trim_spaces:o \jlreq@tempa }
        \str_case_e:nnF {\jlreq@tempa}{
          {continuous}{%
            \def\jlreq@pagination@mainmatterpagecommand##1{\gdef\thepage{\csname @##1\endcsname\c@page}}%
          }
          {independent}{\let\jlreq@pagination@mainmatterpagecommand=\pagenumbering}
        }{\edef\jlreq@pagination@frontmatterstyle{\jlreq@tempa}}
      }%
    }
  }
  \NewDocumentCommand{\frontmatter}{}{%
    \jlreq@frontmatter@precode
    \jlreq@frontmatter@pagebreak
    \@mainmatterfalse
    \let\jlreq@frontmatter@savedpagestyle\@undefined
    \jlreq@frontmatter@pagestyle
    \jlreq@frontmatter@counter
    \jlreq@frontmatter@heading
    \expandafter\gdef\expandafter\thepage\expandafter{\csname @\jlreq@pagination@frontmatterstyle\endcsname\c@page}%
    \jlreq@frontmatter@postcode
  }
  \seq_new:N \g__jlreq_frontmatter_resetcounter_seq
  \def\jlreq@frontmatter@restoreheadings{}
  \def\jlreq@frontmatter@restorecommands{}
  \keys_define:nn { jlreqsetup } {mainmatter_pagebreak .code:n = {%
    \edef\jlreq@mainmatter@pagebreak{\jlreq@ifempty{#1}{}{\exp_not:c {#1}}}%
  }}
  \keys_define:nn { jlreqsetup } {mainmatter_pagestyle .code:n = {%
    \edef\jlreq@mainmatter@pagestyle{\jlreq@ifempty{#1}{}{\unexpanded{\pagestyle{#1}}}}%
  }}
  \keys_define:nn { jlreqsetup } {mainmatter_counter .code:n = {\jlreq@matter@counter@norestore{\jlreq@mainmatter@counter}{#1}}}
  \keys_define:nn { jlreqsetup } {mainmatter_heading .code:n = {\jlreq@matter@heading{\jlreq@mainmatter@heading}{#1}}}
  \keys_define:nn { jlreqsetup } {mainmatter_precode .code:n = {\edef\jlreq@mainmatter@precode{\unexpanded{#1}}}}
  \keys_define:nn { jlreqsetup } {mainmatter_postcode .code:n = {\edef\jlreq@mainmatter@postcode{\unexpanded{#1}}}}
  \keys_define:nn { jlreqsetup } {mainmatter_pagination .tl_set:N = \jlreq@pagination@mainmatterstyle}
  \NewDocumentCommand{\mainmatter}{}{%
    \jlreq@mainmatter@precode
    \jlreq@mainmatter@pagebreak
    \@mainmattertrue
    \@ifundefined{jlreq@frontmatter@savedpagestyle}{%
      \jlreq@mainmatter@pagestyle
    }{%
      \expandafter\pagestyle\expandafter{\jlreq@frontmatter@savedpagestyle}%
    }%
    \seq_map_variable:NNn \g__jlreq_frontmatter_resetcounter_seq \jlreq@tempa {
      \setcounter{\jlreq@tempa}{\csname jlreq@frontmatter@savedcounter@value@\jlreq@tempa\endcsname}%
      \expandafter\let\csname the\jlreq@tempa\expandafter\endcsname\csname jlreq@frontmatter@savedcounter@the@\jlreq@tempa\endcsname
    }%
    \jlreq@mainmatter@counter
    \clist_map_variable:NNn \jlreq@frontmatter@restoreheadings \jlreq@tempa { \csname jlreq@frontmatter@savedheading@\jlreq@tempa\endcsname }
    \jlreq@mainmatter@heading
    \clist_map_variable:NNn \jlreq@frontmatter@restorecommands \jlreq@tempa {
      \expandafter\let\csname \jlreq@tempa\expandafter\endcsname\csname jlreq@frontmatter@savedcommand@\jlreq@tempa\endcsname
    }%
    \expandafter\jlreq@pagination@mainmatterpagecommand\expandafter{\jlreq@pagination@mainmatterstyle}%
    \jlreq@mainmatter@postcode
  }
  \keys_define:nn { jlreqsetup } {backmatter_pagebreak .code:n = {%
    \edef\jlreq@backmatter@pagebreak{\jlreq@ifempty{#1}{}{\exp_not:c {#1}}}%
  }}
  \keys_define:nn { jlreqsetup } {backmatter_pagestyle .code:n = {%
    \edef\jlreq@backmatter@pagestyle{\jlreq@ifempty{#1}{}{\unexpanded{\pagestyle{#1}}}}%
  }}
  \keys_define:nn { jlreqsetup } {backmatter_counter .code:n = {\jlreq@matter@counter@norestore{\jlreq@backmatter@counter}{#1}}}
  \keys_define:nn { jlreqsetup } {backmatter_heading .code:n = {\jlreq@matter@heading{\jlreq@backmatter@heading}{#1}}}
  \keys_define:nn { jlreqsetup } {backmatter_precode .code:n = {\edef\jlreq@backmatter@precode{\unexpanded{#1}}}}
  \keys_define:nn { jlreqsetup } {backmatter_postcode .code:n = {\edef\jlreq@backmatter@postcode{\unexpanded{#1}}}}
  \keys_define:nn { jlreqsetup } {backmatter_pagination .code:n = {
      \let\jlreq@pagination@backmatterpagecommand=\pagenumbering
      \def\jlreq@pagination@backmatterstyle{arabic}%
      \clist_map_variable:nNn {#1} \jlreq@tempa {
        \tl_set:Nx \jlreq@tempa { \tl_trim_spaces:o \jlreq@tempa }
        \str_case_e:nnF {\jlreq@tempa} {
          {continuous}{%
            \def\jlreq@pagination@backmatterpagecommand##1{\gdef\thepage{\csname @##1\endcsname\c@page}}%
          }
          {independent}{\let\jlreq@pagination@backmatterpagecommand=\pagenumbering}
        } {\edef\jlreq@pagination@backmatterstyle{\jlreq@tempa}}
      }%
    }
  }
  \NewDocumentCommand{\backmatter}{}{%
    \jlreq@backmatter@precode
    \jlreq@backmatter@pagebreak
    \jlreq@backmatter@pagestyle
    \@mainmatterfalse
    \jlreq@backmatter@counter
    \jlreq@backmatter@heading
    \expandafter\jlreq@pagination@backmatterpagecommand\expandafter{\jlreq@pagination@backmatterstyle}%
    \jlreq@backmatter@postcode
  }
}

\keys_define:nn { jlreqsetup } {appendix_counter .code:n = {\jlreq@matter@counter@norestore{\jlreq@appendix@counter}{#1}}}
\keys_define:nn { jlreqsetup } {appendix_heading .code:n = {\jlreq@matter@heading{\jlreq@appendix@heading}{#1}}}
\keys_define:nn { jlreqsetup } {appendix_precode .code:n = {\edef\jlreq@appendix@precode{\unexpanded{#1}}}}
\keys_define:nn { jlreqsetup } {appendix_postcode .code:n = {\edef\jlreq@appendix@postcode{\unexpanded{#1}}}}
\NewDocumentCommand{\appendix}{}{%
  \par
  \jlreq@appendix@precode
  \jlreq@appendix@counter
  \jlreq@appendix@heading
  \jlreq@appendix@postcode
}

%. その他諸々
%.. 縦中横
\NewDocumentCommand { \tatechuyoko } { s m } {
  \IfBooleanTF{#1}{
    \jlreq@iftdir{\jlreq@tatechuyoko@i{#2}}{#2}
  }{
    \jlreq@iftdir{}{\ClassError{jlreq}{\string\tatechuyoko\space is~not~allowed~in~yoko~mode}{\@ehc}}%
    \jlreq@tatechuyoko@i{#2}
  }
}

\edef\@tempa{%
  \unexpanded{\ifvmode\leavevmode\fi}%
  \ifx l\jlreq@engine\unexpanded{%
    \jlreq@lastnodechar=\lastnodechar\relax
    \int_compare:nT { \jlreq@lastnodechar>-1 } { \inhibitglue }
  }\else\unexpanded{%
    \int_compare:nT { \jlreq@lastnodechar>-1 } { \inhibitglue }
    \jlreq@lastnodechar=\lastnodechar\relax
  }\fi
}

\expandafter\def\expandafter\jlreq@tatechuyoko@i\expandafter#\expandafter1\expandafter{%
  \@tempa
  % 前のJFM glue
  \ifnum\jlreq@lastnodechar>-1
    \jlreq@calc@jfmglue{\char\jlreq@lastnodechar}{阿}%
    \jlreq@ifgluezero\jlreq@resultskip{}{\hskip\jlreq@resultskip}%
  \fi
  \hbox{\yoko
    \begingroup
      \setbox\jlreq@tempboxa=\hbox{阿}%
      \vrule width~0pt~height~\ht\jlreq@tempboxa depth~\dp\jlreq@tempboxa
    \endgroup
    #1}%
  \futurelet\jlreq@nextchar\jlreq@tatechuyoko@ii
}
\def\jlreq@tatechuyoko@ii{%
  \begingroup
    \def\jlreq@do{}%
    \jlreq@getfirsttoken@expandmacros{\jlreq@nextchar}{\jlreq@tempa}%
    \expandafter\jlreq@ifletter\expandafter{\jlreq@tempa}{%
      \jlreq@calc@jfmglue{阿}{\jlreq@tempa}%
      \edef\jlreq@do{%
        \noexpand\hskip\the\jlreq@resultskip\space
        \noexpand\inhibitglue
      }%
    }{}%
  \expandafter\endgroup
  \jlreq@do
}

\jlreq@saveoriginalcs{kanjishape}
\ifx l\jlreq@engine
  \cs_new:Nn \__jlreq_setkanjiskip:nn {
    \group_begin:
      \ltj@setpar@global
      \cs_set:Nn \l_jlreq_do: {}
      \tl_if_empty:nF {#1} {
        \skip_set:Nn \l_jlreq_tmpa_skip { #1 }
        \cs_set:Nx \l_jlreq_do: { \exp_not:o \l_jlreq_do:
          \exp_not:N \cs_set:Npn \exp_not:N \jlreqkanjiskip { \skip_use:N \l_jlreq_tmpa_skip }
          \exp_not:N \ltjsetkanjiskip \skip_use:N \l_jlreq_tmpa_skip
        }
      }
      \tl_if_empty:nF {#2} {
        \skip_set:Nn \l_jlreq_tmpa_skip { #2 }
        \cs_set:Nx \l_jlreq_do: { \exp_not:o \l_jlreq_do:
          \exp_not:N \cs_set:Npn \exp_not:N \jlreqxkanjiskip { \skip_use:N \l_jlreq_tmpa_skip }
          \exp_not:N \ltjsetxkanjiskip \skip_use:N \l_jlreq_tmpa_skip
        }
      }
    \exp_after:wN \group_end:
    \l_jlreq_do:
  }
\else
  \cs_new:Nn \__jlreq_setkanjiskip:nn {
    \group_begin:
      \cs_set:Nn \l_jlreq_do: {}
      \tl_if_empty:nF {#1} {
        \skip_set:Nn \l_jlreq_tmpa_skip { #1 }
        \cs_set:Nx \l_jlreq_do: { \exp_not:o \l_jlreq_do:
          \exp_not:N \cs_set:Npx \exp_not:N \jlreqkanjiskip { \skip_use:N \l_jlreq_tmpa_skip }
          \exp_not:N \skip_set:Nn \exp_not:N \kanjiskip { \skip_use:N \l_jlreq_tmpa_skip }
        }
      }
      \tl_if_empty:nF {#2} {
        \skip_set:Nn \l_jlreq_tmpa_skip { #2 }
        \cs_set:Nx \l_jlreq_do: { \exp_not:o \l_jlreq_do:
          \exp_not:N \cs_set:Npx \exp_not:N \jlreqxkanjiskip { \skip_use:N \l_jlreq_tmpa_skip }
          \exp_not:N \skip_set:Nn \exp_not:N \xkanjiskip { \skip_use:N \l_jlreq_tmpa_skip }
        }
      }
    \exp_after:wN \group_end:
    \l_jlreq_do:
  }
\fi
\ifx l\jlreq@engine
  \cs_set:Nn \l_jlreq_tmpa:n {
    \NewDocumentCommand { \jidori } { m m } {
      \mode_if_vertical:TF { \leavevmode } {}
      \group_begin:
        \__jlreq_setkanjiskip:nn { 0pt~plus~1fil~minus~0pt } { 0pt~plus~1fil~minus~0pt }
        \hbox_to_wd:nn {##1} {
          \def#1 {　}
          \kanjishape{n-jidori}\selectfont
          \def\kanjishape####1{\jlreq@useoriginalcs{kanjishape}{####1-jidori}}
          ##2
          \hskip\glueexpr 0pt~minus~1fil\relax
        }
      \group_end:
    }
  }
  \catcode`　=\active
  \l_jlreq_tmpa:n{　}
  \catcode`　=12
\else
  \NewDocumentCommand { \jidori } { m m } {
    \mode_if_vertical:TF { \leavevmode } {}
    \group_begin:
      \__jlreq_setkanjiskip:nn { 0pt~plus~15zw~minus~0pt } { 0pt~plus~15zw~minus~0pt }
      \hbox_to_wd:nn {#1} {
        \kanjishape{n-jidori}\selectfont
        \inhibitglue #2
        \hskip\glueexpr 0pt~minus~1fil\relax
      }
    \group_end:
  }
\fi
\NewDocumentCommand { \akigumi } { m m } {
  \mode_if_vertical:TF { \leavevmode } {}
  \group_begin:
    \__jlreq_setkanjiskip:nn { \jlreqkanjiskip + #1 } { }
    \hbox:n {#2}
  \group_end:
}

% 日にち
\newif\if西暦
\def\西暦{\西暦true}
\def\和暦{\西暦false}
% #1年#2月#3日 #4は\numberとか\kansujiとか
\def\jlreq@wareki#1#2#3#4{%
  \__jlreq_warekiyear:nnnn{#1}{#2}{#3}{#4}%
  #4#2月#4#3日%
}
\cs_set:Nn \__jlreq_warekiyear:nnnn {
  % 昭和：1989年1月7日まで
  \bool_if:nTF { \int_compare_p:n { #1 < 1989 } || 
    ( \int_compare_p:n { #1 == 1989 } && \int_compare_p:n { #2 == 1 } && \int_compare_p:n { #3 < 8 } ) }{
    昭和\__jlreq_warekiyear_aux:nnn{#1}{1926}{#4}%
  }{
    % 平成：2019年4月末日まで
    \bool_if:nTF { \int_compare_p:n { #1 < 2019 } || ( \int_compare_p:n { #1 == 2019 } && \int_compare_p:n { #2 < 5 } ) } {
      平成\__jlreq_warekiyear_aux:nnn{#1}{1989}{#4}%
    }{
      令和\__jlreq_warekiyear_aux:nnn{#1}{2019}{#4}%
    }
  }
}
\cs_set:Nn \__jlreq_warekiyear_aux:nnn {
  \int_compare:nTF { #1 = #2 } {元年} { #3\int_eval:n { #1 - #2 + 1 } 年 }
}
\def\today{%
  \if西暦
    \jlreq@iftdir{%
      \kansuji\year 年%
      \kansuji\month 月%
      \kansuji\day 日%
    }{%
      \number\year 年%
      \number\month 月%
      \number\day 日%
    }%
  \else
    \jlreq@iftdir{%
      \jlreq@wareki{\year}{\month}{\day}{\kansuji}%
    }{%
      \jlreq@wareki{\year}{\month}{\day}{\number}%
    }%
  \fi
}

\keys_define:nn { jlreqsetup } {
  year_style .choice:,
  year_style / seireki .code:n = {\西暦true},
  year_style / wareki .code:n = {\西暦false}
}

% 時刻
\hour=\time \divide\hour by 60
\minute=\numexpr\time - 60*\hour\relax

%.. 定理環境
\jlreq@saveoriginalcs{@begintheorem}
\jlreq@saveoriginalcs{@opargbegintheorem}
\def\@begintheorem#1#2{\topsep=\dimexpr\jlreq@theorem@beforeafter@space\relax
  \trivlist\labelsep=1\jlreq@zw
  \itemindent=\dimexpr\jlreq@theorem@indent\relax
  \jlreq@theorem@font
   \item[\hskip \labelsep{\reset@font\jlreq@theorem@label@font #1\ #2}]}
\def\@opargbegintheorem#1#2#3{\topsep=\dimexpr\jlreq@theorem@beforeafter@space\relax
  \trivlist\labelsep=1\jlreq@zw
  \itemindent=\dimexpr\jlreq@theorem@indent\relax
  \jlreq@theorem@font
  \item[\hskip \labelsep{\reset@font\jlreq@theorem@label@font #1\ #2（#3）}]}
\AddToHook{package/after/amsthm}{
  \jlreq@saveoriginalcs{proof}%
  \jlreq@saveoriginalcs{endproof}%
  \edef\jlreq@do{
    \unexpanded{\def\jlreq@proof[#1]}{%
      \unexpanded{\labelsep=1\jlreq@zw}%
      \exp_not:o {\proof[{\reset@font\jlreq@proof@label@font #1\inhibitglue}\nopunct]}%
    }
  }
  \jlreq@do
  \def\proof{\@ifnextchar[{\jlreq@proof}{\jlreq@proof[\proofname]}}
  \renewcommand{\proofname}{証明}
  \jlreq@setupamsthm
  \theoremstyle{jlreq}
}
\def\jlreq@setupamsthm{
  \newtheoremstyle{jlreq}{\dimexpr\jlreq@theorem@beforeafter@space\relax}{\dimexpr\jlreq@theorem@beforeafter@space\relax}{\jlreq@theorem@font}{\dimexpr\jlreq@theorem@indent\relax}{\jlreq@theorem@label@font}{}{1\jlreq@zw}{\thmname{##1}\thmnumber{\ ##2}\thmnote{（##3）}}
}
\keys_define:nn { jlreqsetup } {theorem_beforeafter_space .code:n = {
    \def\jlreq@theorem@beforeafter@space{#1}
    \begingroup\jlreq@tempdima=\dimexpr\jlreq@theorem@beforeafter@space\relax\endgroup
    \@ifpackageloaded{amsthm}{\jlreq@setupamsthm}{}
  }
}
\keys_define:nn { jlreqsetup } {theorem_indent .code:n = {
    \def\jlreq@theorem@indent{#1}
    \begingroup\jlreq@tempdima=\dimexpr\jlreq@theorem@indent\relax\endgroup
    \@ifpackageloaded{amsthm}{\jlreq@setupamsthm}{}
  }
}
\keys_define:nn { jlreqsetup } {theorem_font .code:n = {
    \def\jlreq@theorem@font{#1}
    \@ifpackageloaded{amsthm}{\jlreq@setupamsthm}{}
  }
}
\keys_define:nn { jlreqsetup } {theorem_label_font .code:n = {
    \def\jlreq@theorem@label@font{#1}
    \@ifpackageloaded{amsthm}{\jlreq@setupamsthm}{}
  }
}
\keys_define:nn { jlreqsetup } {proof_label_font .tl_set:N = \jlreq@proof@label@font}

%. デフォルト設定
%.. 見出し
\if@tate
  \renewcommand{\thepart}{\jlreq@Kanji{part}}
  \str_if_eq:VnF \jlreq@article@type { article }{\renewcommand{\thechapter}{\jlreq@Kanji{chapter}}}
  \renewcommand{\thesection}{\tatechuyoko*{\@arabic\c@section}}
  \renewcommand{\thesubsection}{\tatechuyoko*{\@alph\c@subsection}}
  \renewcommand{\thesubsubsection}{\tatechuyoko*{\@arabic\c@subsubsection}}
  \renewcommand{\theparagraph}{(\tatechuyoko*{\@arabic\c@paragraph})}
  \renewcommand{\thesubparagraph}{(\tatechuyoko*{\@arabic\c@subparagraph})}

  \str_if_eq:VnTF \jlreq@article@type { article } {
    \NewBlockHeading{part}{0}{font={\jlreq@keepbaselineskip{\LARGE}},indent=4\jlreq@zw,lines=4,after_label_space=1\jlreq@zw,second_heading_text_indent={-1\jlreq@zw,1\jlreq@zw},subtitle_font={\jlreq@keepbaselineskip{\large}}}
    \if@twoside\ModifyHeading{part}{allowbreak_if_evenpage=true}\fi
  }
  {% book, report
    \NewTobiraHeading{part}{-1}{label_format={第\thepart 部\hspace*{1\jlreq@zw}},format={\null\vfill {\Huge\hspace*{2\jlreq@zw}#1#2}\vspace*{2\jlreq@gol}}}
    \NewBlockHeading{chapter}{0}{indent=2\jlreq@zw,lines=6,label_format={第\thechapter 章},font={\huge},after_label_space=1\jlreq@zw,second_heading_text_indent={-1\jlreq@zw,1\jlreq@zw},subtitle_font={\jlreq@keepbaselineskip{\Large}}}
    \if@twoside\ModifyHeading{chapter}{allowbreak_if_evenpage=true}\fi
    \renewcommand{\thechapter}{\jlreq@Kanji{chapter}}
  }
  \NewBlockHeading{section}{1}{font={\jlreq@keepbaselineskip{\Large}},indent=6\jlreq@zw,lines=3,after_label_space=1\jlreq@zw,second_heading_text_indent={-1\jlreq@zw,1\jlreq@zw},subtitle_font={\jlreq@keepbaselineskip{\normalsize}}}
  \if@twoside\ModifyHeading{section}{allowbreak_if_evenpage=true}\fi
  \NewBlockHeading{subsection}{2}{font={\jlreq@keepbaselineskip{\large}},indent=8\jlreq@zw,lines=2,after_label_space=1\jlreq@zw,second_heading_text_indent={-1\jlreq@zw,1\jlreq@zw},subtitle_font={\jlreq@keepbaselineskip{\small}}}
  \if@twoside\ModifyHeading{subsection}{allowbreak_if_evenpage=true}\fi
  \NewBlockHeading{subsubsection}{3}{font={\jlreq@keepbaselineskip{\normalsize}},indent=10\jlreq@zw,lines=1,before_lines=1,subtitle_break=false,after_label_space=1\jlreq@zw,second_heading_text_indent={-1\jlreq@zw,1\jlreq@zw},,subtitle_font={\jlreq@keepbaselineskip{\scriptsize}}}
  \if@twoside\ModifyHeading{subsubsection}{allowbreak_if_evenpage=true}\fi
  \NewRuninHeading{paragraph}{4}{font={\jlreq@keepbaselineskip{\normalsize}\sffamily\gtfamily\bfseries}}
  \NewRuninHeading{subparagraph}{5}{font={\jlreq@keepbaselineskip{\normalsize}\sffamily\gtfamily\bfseries},indent=1\jlreq@zw}
\else% yoko
  \renewcommand{\thepart}{\Roman{part}}
  \renewcommand{\thesubsection}{\thesection .\arabic{subsection}}
  \renewcommand{\thesubsubsection}{\thesubsection .\arabic{subsubsection}}
  \renewcommand{\theparagraph}{\thesubsubsection .\arabic{paragraph}}
  \renewcommand{\thesubparagraph}{\theparagraph .\arabic{subparagraph}}
  \str_if_eq:VnTF \jlreq@article@type { article } {
\def\X{}
    \NewBlockHeading{part}{0}{font={\jlreq@keepbaselineskip{\LARGE\sffamily\gtfamily\bfseries}},label_format={第\thepart 部},lines=4,after_label_space=1\jlreq@zw,second_heading_text_indent={-1\jlreq@zw,1\jlreq@zw},subtitle_font={\jlreq@keepbaselineskip{\large}}}
    \renewcommand{\thesection}{\arabic{section}}
  }{% book, report
    \NewTobiraHeading{part}{-1}{label_format={第\thepart 部\hspace*{1\jlreq@gol}},format={\null\vfil {\Huge\sffamily\gtfamily\bfseries #1#2}\vfil}}
    \NewBlockHeading{chapter}{0}{%
      font={\jlreq@keepbaselineskip{\huge\sffamily\gtfamily\bfseries}},
      label_format={第\thechapter 章},
      lines=5,after_label_space=1\jlreq@zw,second_heading_text_indent={-1\jlreq@zw,1\jlreq@zw},
      subtitle_font={\jlreq@keepbaselineskip{\Large}}}
    \renewcommand{\thechapter}{\arabic{chapter}}
    \renewcommand{\thesection}{\thechapter.\arabic{section}}
  }
  \NewBlockHeading{section}{1}{font={\jlreq@keepbaselineskip{\Large\sffamily\gtfamily\bfseries}},lines=3,after_label_space=1\jlreq@zw,second_heading_text_indent={-1\jlreq@zw,1\jlreq@zw},subtitle_font={\jlreq@keepbaselineskip{\normalsize}}}
  \NewBlockHeading{subsection}{2}{font={\jlreq@keepbaselineskip{\large\sffamily\gtfamily\bfseries}},lines=2,after_label_space=1\jlreq@zw,second_heading_text_indent={-1\jlreq@zw,1\jlreq@zw},subtitle_font={\jlreq@keepbaselineskip{\small}}}
  \NewBlockHeading{subsubsection}{3}{font={\jlreq@keepbaselineskip{\normalsize\sffamily\gtfamily\bfseries}},lines=1,before_lines=1,subtitle_break=false,after_label_space=1\jlreq@zw,second_heading_text_indent={-1\jlreq@zw,1\jlreq@zw},subtitle_font={\jlreq@keepbaselineskip{\scriptsize}}}
  \NewRuninHeading{paragraph}{4}{font={\jlreq@keepbaselineskip{\normalsize\sffamily\gtfamily\bfseries}},indent=1\jlreq@zw}
  \NewRuninHeading{subparagraph}{5}{font={\jlreq@keepbaselineskip{\normalsize\sffamily\gtfamily\bfseries}},indent=2\jlreq@zw}
\fi

\str_if_eq:VnF \jlreq@article@type { article } {
  \legacy_if:nTF { @openright } {
    \ModifyHeading{part}{type=naka}
    \legacy_if:nTF { @tate } {
      \ModifyHeading{chapter}{pagebreak=begin_with_even_page}
    }{
      \ModifyHeading{chapter}{pagebreak=begin_with_odd_page}
    }
  }{
    \ModifyHeading{part}{type=han}
    \ModifyHeading{chapter}{pagebreak=clearpage}
  }
}

%.. ページスタイル
\RenewPageStyle{empty}{nombre={},odd_running_head={},even_running_head={}}
\str_if_eq:VnTF \jlreq@article@type { article } {
  \legacy_if:nTF { @twoside } {
    \NewPageStyle{headings}{odd_running_head={_subsection},even_running_head={_section}}
  }{
    \NewPageStyle{headings}{odd_running_head={_section},even_running_head={}}
  }
}{% book, article
  \legacy_if:nTF { @twoside } {
    \NewPageStyle{headings}{odd_running_head={_section},even_running_head={_chapter}}
  }{
    \NewPageStyle{headings}{odd_running_head={_chapter},even_running_head={}}
  }
  \ModifyPageStyle{headings}{mark_format={_chapter={第\thechapter 章\quad #1}}}
}
\legacy_if:nTF { @tate } {
  \RenewPageStyle{plain}{nombre=\thepage,odd_running_head={},even_running_head={},clear_markcommand=false}
  \NewPageStyle{myheadings}{nombre=\thepage,odd_running_head=\rightmark,even_running_head=\leftmark,clear_markcommand=false}
  \legacy_if:nTF { @twoside } {
    \ModifyPageStyle{plain}{nombre_position={top-left}}
    \ModifyPageStyle{headings}{nombre=\thepage,nombre_position=bottom-left,running_head_position=top-left}
    \ModifyPageStyle{myheadings}{nombre_position=bottom-left,running_head_position=top-left}
  }{
    \ModifyPageStyle{plain}{nombre_position={top-center}}
    \ModifyPageStyle{headings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center}
    \ModifyPageStyle{myheadings}{nombre_position=bottom-center,running_head_position=top-center}
  }
}{% yoko
  \RenewPageStyle{plain}{nombre=\thepage,odd_running_head={},even_running_head={},nombre_position={bottom-center},clear_markcommand=false}
  \ModifyPageStyle{headings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center}
  \NewPageStyle{myheadings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center,odd_running_head=\rightmark,even_running_head=\leftmark,clear_markcommand=false}
}
\ModifyPageStyle{plain}{font=\small}
\ModifyPageStyle{headings}{font=\small}
\ModifyPageStyle{myheadings}{font=\small}

%.. 注
\jlreqsetup{reference_mark=inline}
\legacy_if:nTF { @tate } {
  \jlreqsetup{footnote_indent=1\jlreq@zw}% 根拠なし
}{
  \jlreqsetup{footnote_indent=0pt}% （4.2.5.b）
}
\jlreqsetup{footnote_second_indent=1\jlreq@zw}
\jlreqsetup{endnote_second_indent=2\jlreq@zw}
\jlreqsetup{endnote_position=headings}
\dim_compare:nT { \jlreq@sidenote@length>0pt } {
  \jlreqsetup{sidenote_type=number}
  \jlreqsetup{sidenote_symbol=＊,sidenote_keyword_font={}}
}

%.. キャプション
\jlreqsetup{
  caption_font={\sffamily\gtfamily\bfseries},
  caption_label_font={\sffamily\gtfamily\bfseries},
  caption_after_label_space=1\jlreq@zw,
  caption_label_format={#1},
  caption_align={center,*left}
}

%.. 箇条書き
\legacy_if:nTF { @tate } {
  \renewcommand{\theenumi}{\jlreq@Kanji{enumi}}
  \renewcommand{\theenumii}{\tatechuyoko*{\@arabic\c@enumii}}
  \renewcommand{\theenumiii}{\tatechuyoko*{\@arabic\c@enumiii}}
  \renewcommand{\theenumiv}{\tatechuyoko*{\@arabic\c@enumiv}}
  \newcommand{\labelenumi}{\theenumi}
  \newcommand{\labelenumii}{\theenumii}
  \newcommand{\labelenumiii}{\theenumiii}
  \newcommand{\labelenumiv}{\theenumiv}
}{
  \renewcommand{\theenumi}{\@arabic\c@enumi}
  \renewcommand{\theenumii}{\@alph\c@enumii}
  \renewcommand{\theenumiii}{\@roman\c@enumiii}
  \renewcommand{\theenumiv}{\@Alph\c@enumiv}
  \newcommand{\labelenumi}{\theenumi.\hspace{.5\jlreq@zw}}
  \newcommand{\labelenumii}{(\theenumii)\hspace{.5\jlreq@zw}}
  \newcommand{\labelenumiii}{\theenumiii.\hspace{.5\jlreq@zw}}
  \newcommand{\labelenumiv}{\theenumiv.\hspace{.5\jlreq@zw}}
}
\renewcommand{\p@enumii}{\theenumi}
\renewcommand{\p@enumiii}{\theenumi(\theenumii)}
\renewcommand{\p@enumiv}{\p@enumiii\theenumiii}

%\newcommand{\labelitemi}{•}
\legacy_if:nTF { @tate } {
  \newcommand{\labelitemi}{\hbox to 1\jlreq@zw{\hss\tatechuyoko{\textbullet}\hss}}
  \newcommand{\labelitemii}{○}
  \newcommand{\labelitemiii}{＊}
}{
  \newcommand{\labelitemi}{\hbox to 1\jlreq@zw{\hss\textbullet\hss}}
  \newcommand{\labelitemii}{\hbox to 1\jlreq@zw{\hss\textendash\hss}}
  \newcommand{\labelitemiii}{\hbox to 1\jlreq@zw{\hss\textasteriskcentered\hss}}
}
\newcommand{\labelitemiv}{\hbox to 1\jlreq@zw{\hss ・\hss}}

% 見出しが一つ上のレベルからどのくらいずれているかを入れる．
\setlength\leftmargini{2\zw}
\setlength\leftmarginii{2\zw}
\setlength\leftmarginiii{1\zw}
\setlength\leftmarginiv{1\zw}
\setlength\leftmarginv{1\zw}
\setlength\leftmarginvi{1\zw}
\jlreqsetup{
  itemization_beforeafter_space={0pt,i=.5\baselineskip},
  itemization_itemsep=0pt,
  itemization_labelsep={0pt},
  itemization_label_length={%
    i=\leftmargini,ii=\leftmarginii,iii=\leftmarginiii,
    iv=\leftmarginiv,v=\leftmarginv,vi=\leftmarginvi
  }
}

%.. 引用
\jlreqsetup{
  quote_indent=2\jlreq@zw,
  quote_end_indent=0pt,
  quote_fontsize=,
  quote_beforeafter_space=0pt
}

%.. その他
\str_if_eq:VnT \jlreq@article@type { book } {
  \jlreqsetup{
    frontmatter_pagebreak = cleardoublepage,
    frontmatter_pagestyle = {plain,restore = true},
    frontmatter_heading = {chapter={number=false, restore = true}},
    frontmatter_counter = {
      figure = {the = \arabic{figure},restore = true},
      table = {the = \arabic{table},restore = true},
    },
    frontmatter_precode = {},
    frontmatter_postcode = {},
  }
  \jlreqsetup{
    mainmatter_pagebreak = cleardoublepage,
    mainmatter_counter = {
      chapter = {value = 0},
    },
    mainmatter_pagestyle = {},
    mainmatter_heading = {},
    mainmatter_precode = {},
    mainmatter_postcode = {},
  }
  \legacy_if:nTF { @openright } {
    \jlreqsetup{backmatter_pagebreak=cleardoublepage}
  }{
    \jlreqsetup{backmatter_pagebreak=clearpage}
  }
  \jlreqsetup{
    backmatter_pagestyle = plain,
    backmatter_counter = {
      chapter={value = 0, the = {}},
      figure = {value = 0, the = {\arabic{figure}}},
      table = {value = 0, the = {\arabic{table}}}
    },
    backmatter_heading = {chapter = {number = false}},
    backmatter_precode = {},
    backmatter_postcode = {}
  }
  \jlreqsetup{
    frontmatter_pagination = {independent,roman},
    mainmatter_pagination = {arabic},
    backmatter_pagination = {continuous,arabic},
  }
}
\str_if_eq:VnTF \jlreq@article@type { article } {
  \legacy_if:nTF { @tate } {
    \jlreqsetup{
      appendix_counter = {
        section = {value = 0, the = {\tatechuyoko*{\Alph{section}}}},
        subsection = {value = 0},
      }
    }
  }{
    \jlreqsetup{
      appendix_counter = {
        section = {value = 0, the = {\Alph{section}}},
        subsection = {value = 0},
      }
    }
  }
 \jlreqsetup{appendix_heading = {},appendix_precode = {},appendix_postcode = {}}
}{%book, report
  \legacy_if:nTF { @tate } {
    \jlreqsetup{
      appendix_counter = {
        chapter = {value = 0, the = {\tatechuyoko*{\Alph{chapter}}}},
      }
    }
  }{
    \jlreqsetup{
      appendix_counter = {
        chapter = {value = 0, the = {\Alph{chapter}}},
      }
    }
  }
  \jlreqsetup{
    appendix_heading = {
      chapter = {label_format = {付録\thechapter}}
    },
    appendix_postcode = {%
      \str_if_eq:VnT \jlreq@current@pagestyle { headings } {
        \def\chaptermark#1{\markboth{付録\thechapter\quad #1}{}}%
        \ModifyPageStyle{headings}{mark_format={_chapter={付録\thechapter\quad #1}}}%
      }{}%
    },
    appendix_precode = {}
  }
}
\jlreqsetup{theindex_pagestyle=plain}
\jlreqsetup{year_style=seireki}
\jlreqsetup{
  theorem_beforeafter_space=1\baselineskip,
  theorem_indent=0pt,
  theorem_label_font = {\bfseries\gtfamily\sffamily},
  theorem_font = {\normalfont},
  proof_label_font = {\bfseries\gtfamily\sffamily},
}


\newcommand{\contentsname}{目次}
\newcommand{\refname}{参考文献}
\newcommand{\indexname}{索引}
\newcommand{\listfigurename}{図目次}
\newcommand{\figurename}{図}
\newcommand{\listtablename}{表目次}
\newcommand{\tablename}{表}
\pagestyle{plain}
\pagenumbering{arabic}

%. 最終処理
\if@twocolumn
  \twocolumn
  \sloppy
  \flushbottom
\else
  \onecolumn
  \raggedbottom
\fi

\ExplSyntaxOff
\endinput


