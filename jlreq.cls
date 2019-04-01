%% Japanese document class based on requirements for Japanese text layout
%% 
%% The package is distributed under the BSD 2-Clause License
%%
%%
% (based on JLReq 20120403 https://www.w3.org/TR/2012/NOTE-jlreq-20120403/ja/)
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jlreq}[2019/04/01 jlreq]
\RequirePackage{xkeyval,everyhook,filehook,etoolbox,ifthen}
\RequirePackage{jlreq-helpers}

\newcommand*{\jlreq@undeferr}[1]{\ClassError{jlreq}{Trying to delete \string#1 even though it is not defined, may be a bug}{\@ehc}}
% クラスファイル内でしか使わないマクロをクラスファイル終了時に未定義にする
\newcommand*{\jlreq@aftercls@addtodeletecs}[1]{%
  \appto\jlreq@aftercls@deletecslist{\jlreq@helper@undefcs{#1}{\jlreq@undeferr}}%
}
\newcommand*{\jlreq@aftercls@addtodeleteif}[1]{%
  \appto\jlreq@aftercls@deletecslist{\jlreq@helper@undefif{#1}{\jlreq@undeferr}}%
}
\jlreq@aftercls@addtodeletecs{\jlreq@aftercls@addtodeletecs}
\jlreq@aftercls@addtodeletecs{\jlreq@aftercls@addtodeleteif}
\AtEndOfClass{%
  \jlreq@aftercls@deletecslist
  \jlreq@helper@undefcs{\jlreq@aftercls@deletecslist}{\jlreq@undeferr}%
  \undef{\jlreq@undeferr}%
}

% preambleにいるかのスイッチ
\newif\ifjlreq@preamble
\jlreq@preambletrue
\AtBeginDocument{\jlreq@preamblefalse}

\def\jlreq@saveoriginalcs#1{%
  \ifx#1\relax
    \ClassError{jlreq}{Trying to save \string#1 but it's not defined, may be a bug}{\@ehc}%
  \fi
  \expandafter\ifx\csname jlreq@original@\expandafter\@gobble\string#1\endcsname\relax\else
    \ClassError{jlreq}{Trying to save \string#1 twice, may be a bug}{\@ehc}%
  \fi
  \expandafter\let\csname jlreq@original@\expandafter\@gobble\string#1\endcsname=#1
}
\def\jlreq@useoriginalcs#1{%
  \ifcsname jlreq@original@\expandafter\@gobble\string#1\endcsname\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi
    {\csname jlreq@original@\expandafter\@gobble\string#1\endcsname}%
    {#1}%
}

%. オプションの定義
% オプション処理の際にしか使わない変数（後でそれを元に別の変数を調整する）
% ものは\jlreq@option@<key>に格納する．
% _とかは@に変換する．
% 引数無しの\DeclareOptionX
\newcommand*{\jlreq@DeclareOption}[2]{%
  \DeclareOptionX{#1}{%
    \jlreq@ifempty{##1}{}{\ClassError{jlreq}{The option #1 should have no value}{\@ehc}}%
    #2%
  }
}
\jlreq@aftercls@addtodeletecs{\jlreq@DeclareOption}
% エンジン類
\jlreq@DeclareOption{uplatex}{\let\jlreq@engine=u}
\jlreq@DeclareOption{platex}{\let\jlreq@engine=p}
\jlreq@DeclareOption{lualatex}{\let\jlreq@engine=l}

% 文書のタイプ
\newcommand*\jlreq@article@type{article}
\define@choicekey{jlreq.cls}{article_type}{article,report,book}{\renewcommand*{\jlreq@article@type}{#1}}
\jlreq@DeclareOption{article}{\renewcommand*{\jlreq@article@type}{article}}
\jlreq@DeclareOption{report}{\renewcommand*{\jlreq@article@type}{report}}
\jlreq@DeclareOption{book}{\renewcommand*{\jlreq@article@type}{book}}

%.. 基本版面．まずは紙サイズ．
\def\jlreq@switchpapersize{}
\jlreq@aftercls@addtodeletecs{\jlreq@switchpapersize}
% \jlreq@addpapersize{paper=に指定するもの}{単独オプション名}{横}{縦}

\def\jlreq@addpapersize#1#2{%
  \@ifnextchar[{\jlreq@addpapersize@{#1}{#2}}{\jlreq@addpapersize@@{#1}{#2}}%
}
\def\jlreq@addpapersize@#1#2[#3]{%
  \edef\@tempa{\unexpanded{\jlreq@addpapersize@@{#1}{#2}}\csexpandonce{jlreq@helper@papersizelist@#3}}%
  \@tempa
}
\newcommand*{\jlreq@addpapersize@@}[4]{%
  \@for\@tempa:=#1\do{%
    \eappto\jlreq@switchpapersize{{\expandonce{\@tempa}}{\unexpanded{\setlength{\paperwidth}{#3}\setlength{\paperheight}{#4}}}}%
  }%
  \@for\@tempa:=#2\do{%
    \expandafter\jlreq@DeclareOption\expandafter{\@tempa}{\setlength{\paperwidth}{#3}\setlength{\paperheight}{#4}}%
  }%
}
\jlreq@aftercls@addtodeletecs{\jlreq@addpapersize}
\jlreq@aftercls@addtodeletecs{\jlreq@addpapersize@}
\jlreq@aftercls@addtodeletecs{\jlreq@addpapersize@@}
\DeclareOptionX{paper}{
  \edef\jlreq@do{%
    \unexpanded{\jlreq@switch{#1}}{\expandonce{\jlreq@switchpapersize}}%
    [\unexpanded{%
      \jlreq@helper@dividebycomma{#1}%
      \ifjlreq@result
        \setlength{\paperwidth}{\dimexpr\jlreq@resulta\relax}%
        \setlength{\paperheight}{\dimexpr\jlreq@resultb\relax}%
      \else
        \ClassError{jlreq}{The paper #1 is unknown}{\@ehc}%
      \fi
    }]%
  }%
  \jlreq@do
}
% 紙サイズ一覧．b*はJIS B．
\jlreq@addpapersize{a0,A0}{}[a0]
\jlreq@addpapersize{a1,A1}{}[a1]
\jlreq@addpapersize{a2,A2}{}[a2]
\jlreq@addpapersize{a3,A3}{a3paper}[a3]
\jlreq@addpapersize{a4,A4}{a4paper}[a4]
\jlreq@addpapersize{a5,A5}{a5paper}[a5]
\jlreq@addpapersize{a6,A6}{a6paper}[a6]
\jlreq@addpapersize{a7,A7}{}[a7]
\jlreq@addpapersize{a8,A8}{}[a8]
\jlreq@addpapersize{a9,A9}{}[a9]
\jlreq@addpapersize{a10,A10}{}[a10]

\jlreq@addpapersize{b0,B0}{}[b0]
\jlreq@addpapersize{b1,B1}{}[b1]
\jlreq@addpapersize{b2,B2}{}[b2]
\jlreq@addpapersize{b3,B3}{}[b3]
\jlreq@addpapersize{b4,B4}{b4paper}[b4]
\jlreq@addpapersize{b5,B5}{b5paper}[b5]
\jlreq@addpapersize{b6,B6}{b6paper}[b6]
\jlreq@addpapersize{b7,B7}{}[b7]
\jlreq@addpapersize{b8,B8}{}[b8]
\jlreq@addpapersize{b9,B9}{}[b9]
\jlreq@addpapersize{b10,B10}{}[b10]

\jlreq@addpapersize{c2,C2}{}[c2]
\jlreq@addpapersize{c3,C3}{}[c3]
\jlreq@addpapersize{c4,C4}{}[c4]
\jlreq@addpapersize{c5,C5}{}[c5]
\jlreq@addpapersize{c6,C6}{}[c6]
\jlreq@addpapersize{c7,C7}{}[c7]
\jlreq@addpapersize{c8,C8}{}[c8]

\jlreq@addpapersize{a4var}{}[a4var]
\jlreq@addpapersize{b5var}{}[b5var]

\jlreq@addpapersize{letter}{letterpaper}[letter]
\jlreq@addpapersize{legal}{legalpaper}[legal]
\jlreq@addpapersize{executive}{executivepaper}[executive]
\jlreq@addpapersize{hagaki}{}[hagaki]


%.. フォントサイズ，行長，1ページあたりの行数で基本版面のサイズを決める（2.4.1.a）
\newcommand*{\jlreq@option@fontsize}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@fontsize}
\DeclareOptionX{fontsize}{\renewcommand*{\jlreq@option@fontsize}{#1}}
\jlreq@DeclareOption{10pt}{\renewcommand*{\jlreq@option@fontsize}{10pt}}
\jlreq@DeclareOption{11pt}{\renewcommand*{\jlreq@option@fontsize}{11pt}}
\jlreq@DeclareOption{12pt}{\renewcommand*{\jlreq@option@fontsize}{12pt}}
\newcommand*{\jlreq@option@jafontsize}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@jafontsize}
\DeclareOptionX{jafontsize}{\renewcommand*{\jlreq@option@jafontsize}{#1}}
\newcommand*{\jlreq@option@jafontscale}{1}
\DeclareOptionX{jafontscale}{\renewcommand*{\jlreq@option@jafontscale}{#1}}
\jlreq@aftercls@addtodeletecs{\jlreq@option@jafontscale}
%.. 行の長さ
\newcommand*{\jlreq@option@line@length}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@line@length}
\DeclareOptionX{line_length}{\renewcommand*{\jlreq@option@line@length}{#1}}
%.. 1ページあたりの行数
\newcommand*{\jlreq@option@number@of@lines}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@number@of@lines}
\DeclareOptionX{number_of_lines}{\renewcommand*{\jlreq@option@number@of@lines}{#1}}

% 地の空き量，のどの空き量で配置位置を決める（2.4.1.b）省略されたら中央配置．
%.. 天
\newcommand*{\jlreq@option@head@space}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@head@space}
\DeclareOptionX{head_space}{\renewcommand*{\jlreq@option@head@space}{#1}}

%.. 地
\newcommand*{\jlreq@option@foot@space}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@foot@space}
\DeclareOptionX{foot_space}{\renewcommand*{\jlreq@option@foot@space}{#1}}
%.. のど
\newcommand*{\jlreq@option@gutter}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@gutter}
\DeclareOptionX{gutter}{\renewcommand*{\jlreq@option@gutter}{#1}}
%.. 小口
\newcommand*{\jlreq@option@fore@edge}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@fore@edge}
\DeclareOptionX{fore_edge}{\renewcommand*{\jlreq@option@fore@edge}{#1}}% 昔にこっちにしていたので残している
\DeclareOptionX{fore-edge}{\renewcommand*{\jlreq@option@fore@edge}{#1}}

%.. 柱とノンブル
\newcommand*{\jlreq@option@headfoot@verticalpos}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@headfoot@verticalpos}
% 本文とヘッダ/フッタの間の空き
\DeclareOptionX{headfoot_verticalposition}{\renewcommand*{\jlreq@option@headfoot@verticalpos}{#1}}
% 柱やノンブルの左右の空き
\newcommand*{\jlreq@headfoot@sidemargin}{0pt}
\DeclareOptionX{headfoot_sidemargin}{\renewcommand*{\jlreq@headfoot@sidemargin}{#1}}

%.. 段間
\newcommand*{\jlreq@option@column@gap}{2zw}
\jlreq@aftercls@addtodeletecs{\jlreq@option@column@gap}
\DeclareOptionX{column_gap}{\renewcommand*{\jlreq@option@column@gap}{#1}}

%.. 行送り，指定無しの場合は文字サイズの1.7倍とする．（1.5から2倍が好ましい：2.4.2.d 注3）
\newcommand*{\jlreq@option@baselineskip}{17zw/10}
\jlreq@aftercls@addtodeletecs{\jlreq@option@baselineskip}
\DeclareOptionX{baselineskip}{\def\jlreq@option@baselineskip{#1}}
\DeclareOptionX{linegap}{\def\jlreq@option@baselineskip{1zw + #1}}

%.. 組み方系
% 行頭に括弧が来たときの配置：3.1.5
% 段落頭指定_折り返し行頭指定 で与える．
\newcommand*{\jlreq@open@bracket@pos}{zenkaku_tentsuki}
\define@choicekey{jlreq.cls}{open_bracket_pos}{zenkaku_tentsuki,zenkakunibu_nibu,nibu_tentsuki}{\renewcommand*{\jlreq@open@bracket@pos}{#1}}
% ぶら下げ組みをするか：3.8.2 注1
\newif\ifjlreq@burasage\jlreq@burasagefalse
\jlreq@DeclareOption{hanging_punctuation}{\jlreq@burasagetrue}

%.. 注
% 傍注のタイプ
\newcommand*{\jlreq@option@sidenote@length}{0pt}
\jlreq@aftercls@addtodeletecs{\jlreq@option@sidenote@length}
\DeclareOptionX{sidenote_length}{\renewcommand*{\jlreq@option@sidenote@length}{#1}}

%.. 逆ノンブル
\newif\ifjlreq@option@use@reverse@pagination
\jlreq@aftercls@addtodeleteif{\ifjlreq@option@use@reverse@pagination}
\jlreq@option@use@reverse@paginationfalse
\jlreq@DeclareOption{use_reverse_pagination}{\jlreq@option@use@reverse@paginationtrue}

%.. もろもろ
\newif\if@restonecol\@restonecolfalse
\newif\if@titlepage\@titlepagefalse
\newif\if@landscape\@landscapefalse
\newif\if@tate \@tatefalse
\newif\ifjlreq@option@titlepage \jlreq@option@titlepagefalse % titlepageかnotitlepageかが指定された
\jlreq@aftercls@addtodeleteif{\ifjlreq@option@titlepage}
\jlreq@DeclareOption{landscape}{\@landscapetrue}
\jlreq@DeclareOption{tombo}{\ClassWarningNoLine{jlreq}{The option `tombo' is not supported by jlreq class. Please use the jlreq-trimmarks package}}
\jlreq@DeclareOption{tombow}{\ClassWarningNoLine{jlreq}{The option `tombow' is not supported by jlreq class. Please use the jlreq-trimmarks package}}
\jlreq@DeclareOption{mentuke}{\ClassWarningNoLine{jlreq}{The option `mentuke' is not supported by jlreq class. Please use the jlreq-trimmarks package}}
\jlreq@DeclareOption{tate}{\@tatetrue}

\newif\ifjlreq@option@twoside\jlreq@option@twosidefalse % onesideかtwosideが指定された
\jlreq@aftercls@addtodeleteif{\ifjlreq@option@twoside}
\jlreq@DeclareOption{oneside}{\@twosidefalse\@mparswitchfalse\jlreq@option@twosidetrue}
\jlreq@DeclareOption{twoside}{\@twosidetrue\@mparswitchtrue\jlreq@option@twosidetrue}
\jlreq@DeclareOption{onecolumn}{\@twocolumnfalse}
\jlreq@DeclareOption{twocolumn}{\@twocolumntrue}
\jlreq@DeclareOption{titlepage}{\jlreq@option@titlepagetrue\@titlepagetrue}
\jlreq@DeclareOption{notitlepage}{\jlreq@option@titlepagetrue\@titlepagefalse}
\jlreq@DeclareOption{draft}{\setlength\overfullrule{5pt}}
\jlreq@DeclareOption{final}{\setlength\overfullrule{0pt}}
\newif\if@openright
\newif\ifjlreq@option@open \jlreq@option@openfalse % openrightかopenanyが指定された
\jlreq@aftercls@addtodeleteif{\ifjlreq@option@open}
\jlreq@DeclareOption{openright}{\@openrighttrue\jlreq@option@opentrue}
\jlreq@DeclareOption{openany}{\@openrightfalse\jlreq@option@opentrue}
\jlreq@DeclareOption{leqno}{\input{leqno.clo}}
\jlreq@DeclareOption{fleqn}{\input{fleqn.clo}}
\newif\ifjlreq@option@enablejfam \jlreq@option@enablejfamtrue
\jlreq@aftercls@addtodeleteif{\ifjlreq@option@enablejfam}
\jlreq@DeclareOption{disablejfam}{\jlreq@option@enablejfamfalse}

\newcommand*{\jlreq@note}[1]{}
\jlreq@DeclareOption{jlreq_notes}{\renewcommand*{\jlreq@note}[1]{\message{^^JJLReq note: ##1^^J}}}

\ExecuteOptionsX{article_type=article,paper=a4,open_bracket_pos=zenkaku_tentsuki,onecolumn,final}
% \@removeelementを一旦置き換えてから\ProcessOptionsXを実行する
\let\jlreq@temporary@original@@removeelement=\@removeelement
\let\@removeelement=\jlreq@helper@removeelement
\ProcessOptionsX\relax
\let\@removeelement=\jlreq@temporary@original@@removeelement
\let\jlreq@temporary@original@@removeelement=\@undefined

\ifjlreq@option@titlepage\else
  \ifthenelse{\equal{\jlreq@article@type}{article}}{\@titlepagefalse}{\@titlepagetrue}
\fi
\ifjlreq@option@open\else
  \ifthenelse{\equal{\jlreq@article@type}{book}}{\@openrighttrue}{\@openrightfalse}
\fi
% articleではopenrightは効かない．
\ifthenelse{\equal{\jlreq@article@type}{article}}{%
  \if@openright
    \ClassWarningNoLine{jlreq}{The option `openright' is ignored in article}
    \@openrightfalse
  \fi
}{}
\ifjlreq@option@twoside\else
  \ifthenelse{\equal{\jlreq@article@type}{book}}{\@twosidetrue}{\@twosidefalse}
\fi

\def\jlreq@jlreqsetup@keyvallist{}
\def\jlreq@jlreqsetup@finally{}
\newcommand{\jlreqsetup}[1]{%
  \begingroup
    \edef\jlreq@do{\unexpanded{\jlreq@parsekeyval[jlreqsetup]}{\expandonce{\jlreq@jlreqsetup@keyvallist}}}%
  \expandafter\endgroup
  \jlreq@do{#1}%
  \jlreq@jlreqsetup@finally
}
% \jlreqsetupの項目に加えるマクロ．\jlreq@jlreqsetup@add{key}{action}とするとkeyに対して定義できる．
% action内ではvalが#1として取得できる．（従ってaction内でマクロを定義する際には##1を使う必要がある．）
\newcommand{\jlreq@jlreqsetup@add}[1]{%
  \@ifnextchar[{\jlreq@jlreqsetup@add@{#1}}{\jlreq@jlreqsetup@add@@{#1}}%
}
\long\def\jlreq@jlreqsetup@add@#1[#2]#3{%
  \eappto\jlreq@jlreqsetup@keyvallist{\unexpanded{{#1}[#2]{#3}}}%
}
\long\def\jlreq@jlreqsetup@add@@#1#2{%
  \eappto\jlreq@jlreqsetup@keyvallist{\unexpanded{{#1}{#2}}}%
}
% \jlreqsetupの最後に必ず実行される処理を入れる．
\newcommand\jlreq@jlreqsetup@addtofinally[1]{\eappto\jlreq@jlreqsetup@finally{\unexpanded{#1}}}
\jlreq@aftercls@addtodeletecs{\jlreq@jlreqsetup@add}
\jlreq@aftercls@addtodeletecs{\jlreq@jlreqsetup@add@}
\jlreq@aftercls@addtodeletecs{\jlreq@jlreqsetup@add@@}
\jlreq@aftercls@addtodeletecs{\jlreq@jlreqsetup@addtofinally}
\@onlypreamble\jlreqsetup

% エンジンの設定
\ifx\jlreq@engine\@undefined
  \jlreq@helper@guessengine
  \let\jlreq@engine=\jlreq@result
\fi


% 必要パッケージのロード
\ifx l\jlreq@engine
  \ifjlreq@option@enablejfam
    \RequirePackage{luatexja}
  \else
    \RequirePackage[disablejfam]{luatexja}
  \fi
  \directlua{jlreq = {}}
\fi

% (u)pLaTeXの場合ここで初めて\epTeXinputencodingが発行されるので，
% これ以前には和文は使えない．
\ifx l\jlreq@engine\else
  \epTeXinputencoding utf8
  \def\zw{zw}\def\zh{zh}
  % http://oku.edu.mie-u.ac.jp/tex/mod/forum/discuss.php?d=1508&parent=8435
  \if@tate\AtEndPreamble{\par}\fi
\fi
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
  \ifnum
    0%
    \ifcat 阿\noexpand #11\fi
    \ifcat あ\noexpand #11\fi
    \ifcat （\noexpand #11\fi
    \ifcat A\noexpand #11\fi
    \ifcat 1\noexpand #11\fi
  >0
    \expandafter\@firstoftwo\else\expandafter\@secondoftwo
  \fi
}


% 組方向を判定
% \jlreq@if(y|t)(dir|box)を定義する．
\ifx l\jlreq@engine\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi{
  \def\jlreq@ifydir{\ifnum\ltjgetparameter{direction}=4 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@iftdir{\ifnum\numexpr\ltjgetparameter{direction}-(\ltjgetparameter{direction}/8)*8\relax=3 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@ifybox#1{\ifnum\ltjgetparameter{boxdir}{#1}=4 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@iftbox#1{\ifnum\numexpr\ltjgetparameter{boxdir}{#1}-(\ltjgetparameter{boxdir}{#1}/8)*8\relax=3 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
}{
  \def\jlreq@ifydir{\ifydir\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@iftdir{\iftdir\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@ifybox#1{\ifybox#1\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@iftbox#1{\iftbox#1\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
}

% 左ページであるか
% #1 : odd or even or ページ数
\def\jlreq@ifleftpage#1{%
  \ifthenelse{\(\boolean{@tate} \AND
    \(\equal{#1}{odd} \OR \(\(\NOT \equal{#1}{even}\) \AND \isodd{#1}\)\)
  \) \OR \(\(\NOT \boolean{@tate}\) \AND
    \(\equal{#1}{even} \OR \(\(\NOT \equal{#1}{odd}\) \AND \(\NOT \isodd{#1}\)\)\)
  \)}%
}

\ifx l\jlreq@engine
  \newcommand*{\jlreq@getpostbreakpenalty}[1]{\ltjgetparameter{postbreakpenalty}{#1}}
\else
  \newcommand*{\jlreq@getpostbreakpenalty}[1]{\postbreakpenalty#1}
\fi

% 現在行の残りを得る．
\ifx l\jlreq@engine
  % 以下のコードはLuaTeX-jaのバグ？に依存している
  % https://ja.osdn.net/projects/luatex-ja/ticket/36489
  \newcommand*{\jlreq@calc@current@linewidth@onecolumn}{%
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
  \newcommand*{\jlreq@calc@current@linewidth@onecolumn}{%
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
\newcommand*{\jlreq@calc@current@linewidth}{%
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
  \newcommand*{\jlreq@calc@jfmglue}[2]{%
    \begingroup
      \setbox\jlreq@tempboxa=\hbox{\inhibitglue #1\inhibitglue\hbox{}\inhibitglue#2\inhibitglue}%
      \setbox\jlreq@tempboxb=\hbox{\inhibitglue #1#2\inhibitglue}%
      \edef\jlreq@do{\noexpand\jlreq@resultskip=\the\dimexpr\wd\jlreq@tempboxb - \wd\jlreq@tempboxa\relax\noexpand\relax}%
      \jlreq@do
      \directlua{
        local width = 0
        local stretch = 0
        local shrink = 0
        local n = tex.box["jlreq@tempboxb"].head
        while n do
          % すべてのglueの和を計算する．
          if n.id == node.id("glue") then
            width = width + n.width
            stretch = stretch + n.stretch
            shrink = shrink + n.shrink
          end
          n = n.next
        end
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
  \newcommand*{\jlreq@calc@jfmglue}[2]{%
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
\newcommand*{\jlreq@fixjfm}{%
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
%      \message{fixjfm Insert: \the\jlreq@resultskip}%
      \edef\jlreq@do{%
        \noexpand\hskip\the\jlreq@resultskip\space
        \noexpand\inhibitglue
      }%
    }{}%
  \expandafter\endgroup
  \jlreq@do
}

\ifx l\jlreq@engine
  \newcommand*{\jlreq@divide}[2]{%
    \jlreq@resultdimen=\directlua{tex.print(tostring(\strip@pt\dimexpr #1\relax/\strip@pt\dimexpr #2\relax) .. "pt ")}%
  }
\else
  \let\jlreq@divide=\jlreq@helper@divide
\fi

%. 基本設定
\providecommand*{\jlreqkanjiskip}{0pt plus 0.25\zw minus 0pt}
\providecommand*{\jlreqxkanjiskip}{0.25\zw plus 0.25\zw minus 0.125\zw}
\ifx l\jlreq@engine
  \ltjsetparameter{kanjiskip=\jlreqkanjiskip}
  \ltjsetparameter{xkanjiskip=\jlreqxkanjiskip}
\else
  \kanjiskip=\jlreqkanjiskip
  \xkanjiskip=\jlreqxkanjiskip
\fi

% 文字クラスのリスト（必要なものだけ）
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

\ifx l\jlreq@engine
  \newcommand*{\jlreq@setpostbreakpenalty@}[2]{\ltjsetparameter{postbreakpenalty={`#1,#2}}}
  \newcommand*{\jlreq@setprebreakpenalty@}[2]{\ltjsetparameter{prebreakpenalty={`#1,#2}}}
  \newcommand*{\jlreq@addjaxspmode@}[2]{%
    \jlreq@tempcnta=\ltjgetparameter{jaxspmode}{`#1}%
    \jlreq@switch{#2}{
      {pre}{%
        \ifnum\jlreq@tempcnta=2
          \ltjsetparameter{jaxspmode={`#1,allow}}%
        \else\ifnum\jlreq@tempcnta=0
          \ltjsetparameter{jaxspmode={`#1,preonly}}%
        \fi\fi
      }
      {post}{%
        \ifnum\jlreq@tempcnta=1
          \ltjsetparameter{jaxspmode={`#1,allow}}%
        \else\ifnum\jlreq@tempcnta=0
          \ltjsetparameter{jaxspmode={`#1,postonly}}%
        \fi\fi
      }
    }%
  }
  \newcommand*{\jlreq@deljaxspmode@}[2]{%
    \jlreq@tempcnta=\ltjgetparameter{jaxspmode}{`#1}%
    \jlreq@switch{#2}{
      {pre}{%
        \ifnum\jlreq@tempcnta=2
          \ltjsetparameter{jaxspmode={`#1,postonly}}%
        \else\ifnum\jlreq@tempcnta=1
          \ltjsetparameter{jaxspmode={`#1,inhibit}}%
        \fi\fi
      }
      {post}{%
        \ifnum\jlreq@tempcnta=3
          \ltjsetparameter{jaxspmode={`#1,preonly}}%
        \else\ifnum\jlreq@tempcnta=2
          \ltjsetparameter{jaxspmode={`#1,inhibit}}%
        \fi\fi
      }
    }%
  }
\else
  \newcommand*{\jlreq@setpostbreakpenalty@}[2]{\postbreakpenalty`#1=#2}
  \newcommand*{\jlreq@setprebreakpenalty@}[2]{\prebreakpenalty`#1=#2}
  \newcommand*{\jlreq@addjaxspmode@}[2]{%
    \jlreq@tempcnta=\inhibitxspcode`#1
    \jlreq@switch{#2}{
      {pre}{%
        \ifnum\jlreq@tempcnta=1
          \inhibitxspcode`#1=3
        \else\ifnum\jlreq@tempcnta=0
          \inhibitxspcode`#1=2
        \fi\fi
      }
      {post}{%
        \ifnum\jlreq@tempcnta=2
          \inhibitxspcode`#1=3
        \else\ifnum\jlreq@tempcnta=0
          \inhibitxspcode`#1=1
        \fi\fi
      }
    }%
  }
  \newcommand*{\jlreq@deljaxspmode@}[2]{%
    \jlreq@tempcnta=\inhibitxspcode`#1
    \jlreq@switch{#2}{
      {pre}{%
        \ifnum\jlreq@tempcnta=3
          \inhibitxspcode`#1=1
        \else\ifnum\jlreq@tempcnta=2
          \inhibitxspcode`#1=0
        \fi\fi
      }
      {post}{%
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
\newcommand*\jlreq@iterateapply[3]{%
  \edef\jlreq@tempa{#2}%
  \expandafter\@tfor\expandafter\@tempa\expandafter:\expandafter=\jlreq@tempa\do{%
    \expandafter#1\expandafter{\@tempa}{#3}%
  }%
}
\def\jlreq@setpostbreakpenalty{\jlreq@iterateapply{\jlreq@setpostbreakpenalty@}}
\def\jlreq@setprebreakpenalty{\jlreq@iterateapply{\jlreq@setprebreakpenalty@}}
\def\jlreq@addjaxspmode{\jlreq@iterateapply{\jlreq@addjaxspmode@}}
\def\jlreq@deljaxspmode{\jlreq@iterateapply{\jlreq@deljaxspmode@}}

\jlreq@aftercls@addtodeletecs{\jlreq@iterateapply}
\jlreq@aftercls@addtodeletecs{\jlreq@setpostbreakpenalty}
\jlreq@aftercls@addtodeletecs{\jlreq@setpostbreakpenalty@}
\jlreq@aftercls@addtodeletecs{\jlreq@setprebreakpenalty}
\jlreq@aftercls@addtodeletecs{\jlreq@setprebreakpenalty@}
\jlreq@aftercls@addtodeletecs{\jlreq@addjaxspmode}
\jlreq@aftercls@addtodeletecs{\jlreq@addjaxspmode@}
\jlreq@aftercls@addtodeletecs{\jlreq@deljaxspmode}
\jlreq@aftercls@addtodeletecs{\jlreq@deljaxspmode@}

% 行末禁則
\jlreq@setpostbreakpenalty{\jlreq@charlist@openingbrackets}{10000}
\jlreq@setpostbreakpenalty{\jlreq@charlist@prefixedabbreviations}{10000}

% 行頭禁則
\jlreq@setprebreakpenalty{\jlreq@charlist@closingbrackets}{10000}
\jlreq@setprebreakpenalty{\jlreq@charlist@hyphens}{10000}
\jlreq@setprebreakpenalty{\jlreq@charlist@dividingpunctuationmarks}{10000}
\jlreq@setprebreakpenalty{\jlreq@charlist@middlenodes}{10000}
\jlreq@setprebreakpenalty{\jlreq@charlist@fullstops}{10000}
\jlreq@setprebreakpenalty{\jlreq@charlist@commas}{10000}
\jlreq@setprebreakpenalty{\jlreq@charlist@iterationmarks}{10000}
\jlreq@setprebreakpenalty{\jlreq@charlist@prolongedsoundmark}{10000}
\jlreq@setprebreakpenalty{\jlreq@charlist@smallkana}{10000}

% xkanjiskip
\jlreq@addjaxspmode{\jlreq@charlist@iterationmarks}{pre}
\jlreq@addjaxspmode{\jlreq@charlist@iterationmarks}{post}
\jlreq@addjaxspmode{\jlreq@charlist@prolongedsoundmark}{pre}
\jlreq@addjaxspmode{\jlreq@charlist@prolongedsoundmark}{post}
\jlreq@addjaxspmode{\jlreq@charlist@smallkana}{pre}
\jlreq@addjaxspmode{\jlreq@charlist@smallkana}{post}
\jlreq@addjaxspmode{\jlreq@charlist@hiragana}{pre}
\jlreq@addjaxspmode{\jlreq@charlist@hiragana}{post}
\jlreq@addjaxspmode{\jlreq@charlist@katakana}{pre}
\jlreq@addjaxspmode{\jlreq@charlist@katakana}{post}
\jlreq@addjaxspmode{\jlreq@charlist@dividingpunctuationmarks}{post}

% 分割禁止（分離禁止文字は特定の並びで分割禁止だが，とりあえず一括で禁止しておく．）
\jlreq@setprebreakpenalty{\jlreq@charlist@inseparablecharacters}{10000}
% ￥100とか70％とか……

%.. 文字範囲
\ifx u\jlreq@engine
  % \kcatcodeの設定
  \def\jlreq@setkcatcode#1#2{\@for\@tempa:=#1\do{\kcatcode"\@tempa=#2\relax}}
  \jlreq@aftercls@addtodeletecs{\jlreq@setkcatcode}
  % LuaTeX-jaのデフォルトのままに近い設定をする
  % 範囲1＆8
  \jlreq@setkcatcode{80}{15} % Latin-1 Supplement，どうしよう……
  \jlreq@setkcatcode{100,180,250,2B0,300,1E00}{15}
  % 範囲2
  \jlreq@setkcatcode{370,400,1F00}{18}
  % 範囲3
  \jlreq@setkcatcode{2000,2070,20A0,20D0,2100,2150,2190,2200,2300,2400,2500,2580,25A0,2600,2700,2900,2980,2B00}{18}
  % 範囲4
  \jlreq@setkcatcode{500,530,590,600,700,750,780,7C0,800,840,8A0,900,980,A00,A80,B00,B80,C00,C80,D00,D80,E00,E80,F00,1000,10A0,1200,1380,13A0,1400,1680,16A0,1700,1720,1740,1760,1780,1800,18B0,1900,1950,1980,19E0,1A00,1A20,1AB0,1B00,1B80,1BC0,1C00,1C50,1C80,1CC0,1CD0,1D00,1D80,1DC0,2400,2440,27C0,27F0,2800,2A00,2C00,4DC0,A4D0,A500,A640,A6A0,A700,A720,A800,A840,A880,A8E0,A900,A930,A960,A980,A9E0,AA00,AA60,AA80,AAE0,AB00,AB30,AB70,ABC0,FB00,FB50,FE00,FE20,FE70,10000,10080,10100,10140,10190,101D0,10280,102A0,102E0,10300,10330,10350,10380,103A0,10400,10450,10480,104B0,10500,10530,10600,10800,10840,10860,10880,108E0,10900,10920,10980,109A0,10A00,10A60,10A80,10AC0,10B00,10B40,10B60,10B80,10C00,10C80,10E60,11000,11080,110D0,11100,11150,11180,111E0,11200,11280,112B0,11300,11400,11480,11580,11600,11660,11680,11700,118A0,11AC0,11C00,11C70,12000,12400,12480,13000,14400,16800,16A40,16AD0,16B00,16F00,16FE0,17000,18800,1B000,1BC00,1BCA0,1D000,1D100,1D200,1D300,1D360,1D400,1D800,1E000,1E800,1E900,1EE00,1F000,1F030,1F0A0,1F100,1F200,1F300,1F600,1F650,1F680,1F700,1F780,1F800,1F900,E000}{15}
  % 範囲5（Variation Selectors SupplementはLuaTeX-jaではE01F0--E01EFまで範囲5，他は範囲6）
  \jlreq@setkcatcode{D800,DB80,DC00,E0000,F0000,100000}{15}
  % 範囲6
  \jlreq@setkcatcode{3040,30A0,31F0}{17} % Hiragana,Katakana,Katakana Phonetic Extensions
  \jlreq@setkcatcode{2460,3000,3200,3300,FE10,FE30,FE50,E0100}{18} % Enclosed Alphanumerics,CJK Symbols and Punctuation,Enclosed CJK Letters and Months,CJK Compatibility,Vertical Forms,CJK Compatibility Forms,Small Form Variants,Variation Selectors Supplement
  \jlreq@setkcatcode{2E80,3190,3400,4E00,F900,20000}{16}
  % 範囲7
  \jlreq@setkcatcode{A000,A490}{18} % Yi Syllables,Yi Radicals
  \jlreq@setkcatcode{1100,3130,AC00,D7B0}{19} % Hangul Jamo,Hangul Compatibility Jamo,Hangul Syllables,Hangul Jamo Extended-B
  \jlreq@setkcatcode{2F00,2FF0,3100,31A0,31C0,A830}{16}
\fi

% フォントサイズを設定
\newdimen\jlreq@fontsize
\newdimen\jlreq@jafontsize
\ifx l\jlreq@engine
  % Q,zw,zhが正しく扱われるようになる．\dimexprつきに展開される．
  \def\jlreq@expand@optionfontsize#1{%
    \dimexpr\directlua{
      local act = string.char(92)
      local s = [[#1]]
      s = s:gsub("Q",act .. "dimexpr 0.25mm" .. act .. "relax")
      tex.print(s)
    }\relax
  }%
\else
  \def\jlreq@expand@optionfontsize#1{\dimexpr#1\relax}
\fi
\jlreq@aftercls@addtodeletecs{\jlreq@expand@optionfontsize}
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
%. フォント
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
\newcommand*{\jlreq@oldfontcommand@enable}{%
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
\newcommand*{\jlreq@oldfontcommand@disable}{%
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

%.. 和文
% ダミー
\def\@ptsize{0}
% JFMに関連する設定
\ifx l\jlreq@engine
  \def\ltj@stdyokojfm{jlreq}
  \def\ltj@stdtatejfm{jlreqv}
  % この値は後でjfm-jlreq内で読む
  \directlua{jlreq.open_bracket_pos = [[\jlreq@open@bracket@pos]]}
  \ifjlreq@burasage\directlua{jlreq.burasage = true}\else\directlua{jlreq.burasage = false}\fi
  % \item後の行頭括弧のために仕込み．
  \jlreq@saveoriginalcs{\list}
  \jlreq@saveoriginalcs{\endlist}
  \PushPostHook{par}{\jlreq@parhook@atbeginlist}
  \pretocmd{\list}{\def\jlreq@parhook@atbeginlist{\ltjfakeparbegin}}{}{}
  \apptocmd{\endlist}{\def\jlreq@parhook@atbeginlist{}}{}{}
  \def\jlreq@parhook@atbeginlist{}
\else
  % 非LuaTeXの場合はJFMの入れ替えと\everyparでの処理で対処．
  % 行頭括弧に対して\inhibitglueを入れたりする命令を作る
  % \jlreq@charlist@openingbracketsの各括弧に対して，\ifx\jlreq@nextchar 「1\fiみたいなのが並んだのを作る
  \def\jlreq@tempa{}
  \def\jlreq@do#1{\jlreq@ifendmark{#1}{}{\appto\jlreq@tempa{\ifx\jlreq@nextchar#11\fi}\jlreq@do}}
  \expandafter\jlreq@do\jlreq@charlist@openingbrackets\jlreq@endmark
  % JFM glueの伸び縮みで行頭括弧が揃わないのを防ぐために常に\inhibitglueを入れる．
  \ifthenelse{\equal{\jlreq@open@bracket@pos}{nibu_tentsuki}}{
    \edef\jlreq@openbracket@hook@{\noexpand\ifnum0\expandonce{\jlreq@tempa}>0 \unexpanded{\hskip -.5\zw\inhibitglue}\noexpand\fi}
  }{% zenkakunibu_nibu,zenkaku_tentsuki
    \edef\jlreq@openbracket@hook@{\noexpand\ifnum0\expandonce{\jlreq@tempa}>0 \unexpanded{\inhibitglue}\noexpand\fi}
  }
  % source special対策
  \def\jlreq@openbracket@hook{\ifx\jlreq@nextchar\special\expandafter\jlreq@openbracket@hook@@\else\expandafter\jlreq@openbracket@hook@\fi}
  \def\jlreq@openbracket@hook@@#1#2{#1{#2}\futurelet\jlreq@nextchar\jlreq@openbracket@hook}
  \def\jlreq@jfmname@prefix{}
  \jlreq@aftercls@addtodeletecs{\jlreq@jfmname@prefix}
  \ifjlreq@burasage\edef\jlreq@jfmname@prefix{b\jlreq@jfmname@prefix}\fi
  \ifthenelse{\equal{\jlreq@open@bracket@pos}{zenkakunibu_nibu}}{\edef\jlreq@jfmname@prefix{\jlreq@jfmname@prefix z}}{}
  \ifx u\jlreq@engine\edef\jlreq@jfmname@prefix{u\jlreq@jfmname@prefix}\fi
  \edef\jlreq@jfmname{\jlreq@jfmname@prefix jlreq} % JFMの名前
  \edef\jlreq@jfmnameg{\jlreq@jfmname@prefix jlreqg} % ゴシックなJFMの名前
  \AtBeginDocument{\PushPostHook{par}{\futurelet\jlreq@nextchar\jlreq@openbracket@hook}}
\fi

% 行頭の括弧は \jlreq@open@bracket@before@space \inhibitglue 「みたいにする．
\ifthenelse{\equal{\jlreq@open@bracket@pos}{zenkakunibu_nibu}}{
  \def\jlreq@open@bracket@before@space{\hskip\glueexpr-.5\zw\relax}
}{
  \def\jlreq@open@bracket@before@space{}
}

\ifx l\jlreq@engine
  \RequirePackage{luatexja-adjust}
  \ltjenableadjust[lineend=extended,priority=true]
  \ltjsetparameter{stretch_priority={kanjiskip=0,xkanjiskip=10}}
  \ltjsetparameter{shrink_priority={kanjiskip=0,xkanjiskip=-30}}
\fi

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
\jlreq@aftercls@addtodeletecs{\jlreq@jafontscale}
\ifx l\jlreq@engine
  \DeclareFontShape{JY3}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdmcfont:jfm=jlreq;script=latn;-kern}{}
  \DeclareFontShape{JY3}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdgtfont:jfm=jlreq;script=latn;-kern}{}
  \DeclareFontShape{JT3}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdmcfont:jfm=jlreqv;script=latn;-kern}{}
  \DeclareFontShape{JT3}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdgtfont:jfm=jlreqv;script=latn;-kern}{}
\else
  \DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmname}{}
  \DeclareFontShape{\jlreq@yokokanjiencoding}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmnameg}{}
  \DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmname-v}{}
  \DeclareFontShape{\jlreq@tatekanjiencoding}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmnameg-v}{}
\fi
\@for\jlreq@encoding:=\jlreq@yokokanjiencoding,\jlreq@tatekanjiencoding\do{
  \@for\jlreq@shape:=n,it,sl,sc\do{
    \@for\jlreq@series:=m,b,bx,sb,c\do{
      \ifthenelse{\equal{\jlreq@shape}{n} \AND \equal{\jlreq@series}{m}}{}{
        \DeclareFontShape{\jlreq@encoding}{gt}{\jlreq@series}{\jlreq@shape}{<->ssub*gt/m/n}{}
      }
    }
    \@for\jlreq@series:=bx,b,sb\do{
      \DeclareFontShape{\jlreq@encoding}{mc}{\jlreq@series}{\jlreq@shape}{<->ssub*gt/m/n}{}
    }
    \@for\jlreq@series:=m,c\do{
      \ifthenelse{\equal{\jlreq@shape}{n} \AND \equal{\jlreq@series}{m}}{}{
        \DeclareFontShape{\jlreq@encoding}{mc}{\jlreq@series}{\jlreq@shape}{<->ssub*mc/m/n}{}
      }
    }
  }
}

% 和文ファミリと欧文ファミリの連動
\DeclareRobustCommand\rmfamily{%
  \not@math@alphabet\rmfamily\mathrm
  \romanfamily\rmdefault\kanjifamily\mcdefault\selectfont}
\DeclareRobustCommand\sffamily{%
  \not@math@alphabet\sffamily\mathsf
  \romanfamily\sfdefault\kanjifamily\gtdefault\selectfont}
\DeclareRobustCommand\ttfamily{%
  \not@math@alphabet\ttfamily\mathtt
  \romanfamily\ttdefault\kanjifamily\gtdefault\selectfont}

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
  \noexpand\ifx\expandonce{\space}\unexpanded{\jlreq@nextchar\expandafter\jlreq@zenkakuspace@ignorespaces@\else\expandafter\jlreq@zenkakuspace@main\fi}%
}
\expandafter\def\expandafter\jlreq@zenkakuspace@ignorespaces@\space{\　}
\def\jlreq@tempa{}
\def\jlreq@do#1{\jlreq@ifendmark{#1}{}{\appto\jlreq@tempa{\ifnum\lastnodechar=`#1 1\fi}\jlreq@do}}
\expandafter\jlreq@do\jlreq@charlist@dividingpunctuationmarks\jlreq@endmark
\edef\@tempa{\noexpand\ifnum0\expandonce{\jlreq@tempa}>0 }
\expandafter\DeclareRobustCommand\expandafter*\expandafter\jlreq@zenkakuspace@main\expandafter{\@tempa
    \hskip 1\zw\hbox{}%
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
\DeclareRobustCommand*{\jaspace}[1]{%
  \ifcsname jlreq@jaspace@#1\endcsname\csname jlreq@jaspace@#1\endcsname
  \else\ClassError{jlreq}{unknown jaspace: #1}{\@ehc}\fi
}
\def\jlreq@jaspace@zenkaku{\hskip\glueexpr 1\zw\relax}
\def\jlreq@jaspace@nibu{\hskip\glueexpr .5\zw\relax}
\def\jlreq@jaspace@shibu{\hskip\glueexpr .25\zw\relax}

% 区切り約物．\？ みたいな命令を作る．直後の空きが自動で入る．
% \？*とすると文中の？として扱われる．
\def\jlreq@tempa{}
\def\jlreq@do#1{\jlreq@ifendmark{#1}{}{\appto\jlreq@tempa{\ifx\jlreq@nextchar #11\fi}\jlreq@do}}
\expandafter\jlreq@do\jlreq@charlist@closingbrackets\jlreq@endmark
\edef\jlreq@dividingpunctuationmarkscommand{%
  \noexpand\ifnum 0\expandonce{\jlreq@tempa}>0 \unexpanded{\expandafter\ignorespaces\else\expandafter\　\fi}%
}
\def\jlreq@do#1{%
  \jlreq@ifendmark{#1}{}{
    \expandafter\DeclareRobustCommand\expandafter*\csname #1\endcsname{%
      \jlreq@ifstar
        {\hskip .25\zw #1\hskip .25\zw\ignorespaces}%
        {#1\futurelet\jlreq@nextchar\jlreq@dividingpunctuationmarkscommand}%
    }
    \jlreq@do
  }
}
\expandafter\jlreq@do\jlreq@charlist@dividingpunctuationmarks\jlreq@endmark

% \baselineskipの計算
% いったん文字サイズを変更（(u)platexの際にzh/zwをきちんとするため）
\@setfontsize\normalsize{\jlreq@fontsize}{\jlreq@fontsize}%
\newdimen\jlreq@baselineskip
\ifx l\jlreq@engine
  \setlength{\jlreq@baselineskip}{%
    \dimexpr\directlua{
      local act = string.char(92)
      local s = [[\jlreq@option@baselineskip]]
      s = s:gsub("Q",act .. "dimexpr 0.25mm" .. act .. "relax"):gsub("zh",act .. "zh"):gsub("zw",act .. "zw")
      tex.print(s)
    }\relax
  }%
\else
  \setlength{\jlreq@baselineskip}{\dimexpr\jlreq@option@baselineskip\relax}
\fi
\ifdim\jlreq@fontsize>\jlreq@baselineskip
  \ClassError{jlreq}{The baselineskip is less than fontsize}{\@ehc}%
\fi
\ifthenelse{\lengthtest{\jlreq@baselineskip<1.5\zw} \OR \lengthtest{\jlreq@baselineskip>2\zw}}{
  \jlreq@note{行間は二分以上全角以下が望ましい (2.4.2.d 注3)．}
}{}

\emergencystretch 3\jlreq@gol

%.. 文字サイズ変更
\def\jlreq@setfontsizehook{}
\jlreq@saveoriginalcs{\set@fontsize}
\apptocmd{\set@fontsize}{\expandafter\def\expandafter\size@update\expandafter{\size@update\jlreq@setfontsizehook}}{}{}
\appto\jlreq@setfontsizehook{\ifdim\parindent>0pt \setlength{\parindent}{1\zw}\fi}
\ifx l\jlreq@engine
  \@tempskipa=\ltjgetparameter{kanjiskip}
  \ifdim\@tempskipa=\maxdimen\else
    \appto\jlreq@setfontsizehook{%
      \ltj@setpar@global
      \ltjsetkanjiskip\jlreqkanjiskip
      \@tempskipa=\ltjgetparameter{xkanjiskip}%
      \ifdim\@tempskipa>0pt
        \ltjsetxkanjiskip\jlreqxkanjiskip
      \fi
    }
  \fi
\else
  \appto\jlreq@setfontsizehook{%
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
    \DeclareRobustCommand*{\jafontsize}[2]{%
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

%. plextから一部拝借
% オプションも*もない\rensuji（コピペ）
\DeclareRobustCommand{\jlreq@rensuji}[1]{%
  \ifvmode\leavevmode\fi
  \jlreq@ifydir{\hbox{#1}}{%
    \hskip 0pt plus 0.25\zw minus 0pt % \rensujiskipは固定値
    \setbox\jlreq@tempboxa=\hbox{\yoko#1}%
    \@tempdima=\dimexpr\ht\jlreq@tempboxa+\dp\jlreq@tempboxa\relax
    \vrule\@width\z@ \@height.5\@tempdima \@depth.5\@tempdima
    \hbox to 1\zw{\yoko\hss#1\hss}%
    \hskip 0pt plus 0.25\zw minus 0pt
}}
\def\jlreq@Kanji#1{\expandafter\kansuji\csname c@#1\endcsname}

% このあたりはtarticleと同じ
\setlength\lineskip{.1\zh}
\setlength\normallineskip{.1\zh}
\renewcommand{\baselinestretch}{}
\setlength\parskip{0\p@ \@plus \p@}
\setlength\parindent{1\zw}
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
      local act = string.char(92)
      local s = [[#1]]
      s = s:gsub("zw",act .. "zw"):gsub("zh",act .. "zh")
      tex.print(s)
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
    \noexpand\setlength{\noexpand\marginparwidth}{\the\jlreq@tempdima}
    \noexpand\setlength{\noexpand\marginparpush}{\the\dimexpr 0.5\zw\relax} % 同上：4.2.7.g
  }
  \expandafter\endgroup
\jlreq@do
\ifdim\marginparwidth>0pt
  \setlength{\marginparsep}{2\zw} % フォントサイズ×2（4.2.7：特に問題に～e）
\else
  \setlength{\marginparsep}{0pt}
\fi

% 縦書きの時は脚注に固定
% (TODO: 頭注）
\if@tate\@mparswitchfalse\fi

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
\jlreq@aftercls@addtodeletecs{\jlreq@determine@kihonhanmen@warning}
\jlreq@aftercls@addtodeleteif{\ifjlreq@determine@kihonhanmen@warning@first}
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


%.. \textheight：行送り方向の長さ
% 一番上（直後に\topskip由来が入る）から最終行のベースラインまでの長さ．
% \topskipが十分ある時は先頭行のベースラインから最終行のベースライン＋\topskip
\def\jlreq@adjusttextheight{
  \addtolength{\textheight}{-\topskip}
  \divide\textheight\baselineskip \multiply\textheight\baselineskip
  \addtolength{\textheight}{\topskip}
}
\jlreq@aftercls@addtodeletecs{\jlreq@adjusttextheight}
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
\jlreq@aftercls@addtodeletecs{\jlreq@setsidemargin@by@gutter}
\jlreq@aftercls@addtodeletecs{\jlreq@setsidemargin@by@fore@edge}

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
      \ClassWarningNoLine{jlreq}{fore-edge is ignored}
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
\jlreq@aftercls@addtodeletecs{\jlreq@settopmarginbyhead}
% 地の値から
\def\jlreq@settopmarginbyfoot#1{
  \if@tate
    \setlength{\topmargin}{\dimexpr\paperheight - \textwidth - \headsep - \headheight - #1 - \marginparsep - \marginparwidth\relax}
  \else
    \jlreq@note{横組の場合は天の空き量を指定する (2.4.1.b)．}
    \setlength{\topmargin}{\dimexpr\paperheight - \textheight + \topskip - 1\zh - \headsep - \headheight - #1\relax}
  \fi
}
\jlreq@aftercls@addtodeletecs{\jlreq@settopmarginbyfoot}
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
        \ClassWarningNoLine{jlreq}{head_space is ignored}
      \fi
    \else
      \jlreq@settopmarginbyhead{\jlreq@speciallength{\jlreq@option@head@space}}
      \ifx\jlreq@option@number@of@lines\@empty\else
        \ClassWarningNoLine{jlreq}{foot_space is ignored}
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
\newcommand*{\cleartooddpage}[1][]{%
  \clearpage
  \ifodd\c@page\else
    \jlreq@ifempty{#1}{}{\thispagestyle{#1}}%
    \hbox{}%
    \newpage
    \if@twocolumn\hbox{}\newpage\fi
  \fi
}
\newcommand*{\cleartoevenpage}[1][]{%
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
\newcommand*{\jlreq@hook@beforeheadings}[1]{}
% 見出し名一覧を格納する
\def\jlreq@heading@allheadings{}

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
      \jlreq@tempdimb=\dimexpr\the\numexpr\jlreq@tempdima/\dimexpr 1\zw\relax + 2\relax\zw\relax
      \edef\jlreq@do{%
        \unexpanded{\def\jlreq@result}{%
          \noexpand\def\expandonce{\csname l@#1\endcsname}{%
            \unexpanded{\@dottedtocline{#2}{0\zw}}{\the\jlreq@tempdimb}%
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
\newcommand{\DeclareTobiraHeading}[3]{%
  \def\jlreq@do{\@removeelement{#1}}%
  \expandafter\jlreq@do\expandafter{\jlreq@heading@allheadings}{\jlreq@heading@allheadings}%
  \appto{\jlreq@heading@allheadings}{,#1}%
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\edef\csname jlreq@heading@setting@#1\endcsname{\unexpanded{#3}}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewTobiraHeading}%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \jlreq@heading@make@maketoc{#1}{#2}%
  \begingroup
    \let\jlreq@contents@label@format=\@undefined
    \let\jlreq@format=\@undefined
    \edef\jlreq@label@format{\expandonce{\csname the#1\endcsname}}%
    \def\jlreq@heading@clearpage{\clearpage\hbox{}\clearpage}%
    \def\jlreq@pagestyle{empty}%
    \newif\ifjlreq@number \jlreq@numbertrue
    \jlreq@parsekeyval[DeclareTobiraHeading:#1]{
      {label_format}{\def\jlreq@label@format{##1}}
      {format}{\def\jlreq@format####1####2{##1}}
      {pagestyle}{\def\jlreq@pagestyle{##1}}
      {type}[han,naka]{%
        \jlreq@switch{##1}{
          {han}{\def\jlreq@heading@clearpage{\clearpage}}
          {naka}{\def\jlreq@heading@clearpage{\clearpage\hbox{}\clearpage}}
        }%
      }
      {number}[true,false]{\csname jlreq@number##1\endcsname}
    }{#3}%
    \def\jlreq@do{}%
    \ifx\jlreq@format\@undefined
      \def\jlreq@format##1##2{##1##2}%
    \fi
    \edef\jlreq@formatwlabel{\noexpand\jlreq@format{\expandonce{\jlreq@label@format}}}%
    \jlreq@heading@make@l@{#1}{#2}{\jlreq@label@format}%
    \eappto\jlreq@do{\expandonce{\jlreq@result}}%
    \edef\jlreq@do{%
      \expandonce{\jlreq@do}%
      \noexpand\def\expandonce{\csname jlreq@TobiraHeading@start@#1\endcsname}[####1]####2{%
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
          \unexpanded{\ifnum#2>\c@secnumdepth\relax\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}{%
            \unexpanded{\long\gdef\jlreqHeadingLabel####1{}}%
            \expandonce{\jlreq@format{}{##1}}%
          }{%
            \unexpanded{\long\gdef\jlreqHeadingLabel####1{####1}}%
            \expandafter\expandonce\expandafter{\jlreq@formatwlabel{##2}}%
          }%
        \else
          \unexpanded{\long\gdef\jlreqHeadingLabel####1{}}%
          \expandonce{\jlreq@format{}{##1}}%
        \fi
        \expandonce{\csname jlreq@heading@maketoc@#1\endcsname}{\ifjlreq@number\else -\fi}{\expandonce{\jlreq@label@format}}{####1}%
        \noexpand\@afterheading
        \expandonce{\jlreq@heading@clearpage}%
        \unexpanded{\if@restonecol\twocolumn\fi}%
      }%
      \noexpand\def\expandonce{\csname jlreq@TobiraHeading@start@s@#1\endcsname}####1{%
        \unexpanded{\long\gdef\jlreqHeadingLabel####1{}}%
        \unexpanded{\jlreq@ifempty{##1}%
          {\long\gdef\jlreqHeadingText####1{}}%
          {\long\gdef\jlreqHeadingText####1{####1}}%
        }%
        \expandonce{\jlreq@format{}{##1}}
        \expandonce{\csname jlreq@heading@maketoc@#1\endcsname}{*}{\expandonce{\jlreq@label@format}}{####1}%
        \noexpand\@afterheading
        \expandonce{\jlreq@heading@clearpage}%
        \unexpanded{\if@restonecol\twocolumn\fi}%
      }%
      \noexpand\def\expandonce{\csname jlreq@headingcs@#1\endcsname}{%
        % 改丁．これでよいのかな．
        \unexpanded{\if@twocolumn\onecolumn\@restonecoltrue\else\@restonecolfalse\fi\cleartooddpage[empty]}%
        \ifx\jlreq@pagestyle\@empty\else\noexpand\thispagestyle{\expandonce{\jlreq@pagestyle}}\fi
        \noexpand\secdef{\expandonce{\csname jlreq@TobiraHeading@start@#1\endcsname}}{\expandonce{\csname jlreq@TobiraHeading@start@s@#1\endcsname}}}%
      \noexpand\def\expandonce{\csname #1\endcsname}{\expandonce{\csname jlreq@headingcs@#1\endcsname}}%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\newcommand{\NewTobiraHeading}[3]{%
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareTobiraHeading{#1}{#2}{#3}}%
}
\newcommand{\RenewTobiraHeading}[3]{%
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareTobiraHeading{#1}{#2}{#3}}%
}
\newcommand{\ProvideTobiraHeading}[3]{%
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
\newcommand{\jlreq@BlockHeading@start}[6]{%
  \if@noskipsec\leavevmode\fi
  % #5と#6は\parを含むかもしれないので引数渡しはしない（後の\@ifstarで詰まる）
  \edef\jlreq@BlockHeading@start@eachformat{\expandonce{\@firstoftwo#5}}%
  \edef\jlreq@BlockHeading@start@format{\expandonce{\@secondoftwo#5}}
  \edef\jlreq@BlockHeading@start@totalformat{\unexpanded{#6}}%
  \jlreq@BlockHeading@start@{#1}{#2}{#3}{#4}%
}
% {1 = 命令}{2 = レベル}{3 = スペース関連}
\newcommand{\jlreq@BlockHeading@start@}[4]{%
  \@ifstar{\@dblarg{\jlreq@BlockHeading@start@@{#1}{#2}{#3}{*}}}{\@dblarg{\jlreq@BlockHeading@start@@{#1}{#2}{#3}{#4}}}%
}
% {1 = 命令}{2 = レベル}{3 = スペース関連}{4 = *}[5 = running head]{6 = 見出し}
\long\def\jlreq@BlockHeading@start@@#1#2#3#4[#5]#6{%
  \@ifnextchar[{\jlreq@BlockHeading@start@@@{#1}{#2}{#3}{#4}{#5}{#6}}{\jlreq@BlockHeading@start@@@{#1}{#2}{#3}{#4}{#5}{#6}[]}%
}

% {1 = 命令}{2 = レベル}{3 = スペース関連}{4 = *}{5 = running head}{6 = 見出し}[7 = 副題]
\long\def\jlreq@BlockHeading@start@@@#1#2#3#4#5#6[#7]{%
  \edef\jlreq@do{\unexpanded{\jlreq@BlockHeading@start@@@@{#1}{#2}{#3}}{\expandonce{\jlreq@BlockHeading@start@totalformat}}}%
  \jlreq@do{#4}{#5}{#6}{#7}%
}

% {1 = 命令}{2 = レベル}{3 = スペース関連}{4 = 全フォーマット}{5 = *}{6 = running head}{7 = 見出し}{8 = 副題}
\long\def\jlreq@BlockHeading@start@@@@#1#2#3#4#5#6#7#8{%
  \edef\jlreq@tempa##1##2##3##4##5##6##7{%
    \unexpanded{\jlreq@BlockHeading@start@makeoutput{#1}{#2}}{{##1}{##2}{##3}}{\expandonce{\jlreq@BlockHeading@start@eachformat}}{\expandonce{\jlreq@BlockHeading@start@format}}\unexpanded{{#5}{#6}{#7}{#8}}%
    \unexpanded{\def\jlreq@tempb}{{##4}{##5}{##6}{##7}}% 縦方向空き
  }%
  \jlreq@tempa#3%
  \global\advance\jlreq@BlockHeading@spaces@current@count by 1
  \gappto\jlreq@BlockHeading@spaces@current@sequence{_#1}%
  \expandafter\xdef\csname jlreq@BlockHeading@spaces@current@output@\the\jlreq@BlockHeading@spaces@current@count\endcsname{%
    \expandonce{\jlreq@resultb}%
  }%
  \expandafter\xdef\csname jlreq@BlockHeading@spaces@current@space@\the\jlreq@BlockHeading@spaces@current@count\endcsname{%
    \expandonce{\jlreq@tempb}%
  }%
  \def\@tempa##1##2##3{##1}%
  \expandafter\xdef\csname jlreq@BlockHeading@spaces@current@before@\the\jlreq@BlockHeading@spaces@current@count\endcsname{%
    \expandonce{\@tempa#4}%
    \expandonce{\jlreq@resulta}%
  }%
  \def\@tempa##1##2##3{##2}%
  \expandafter\xdef\csname jlreq@BlockHeading@spaces@current@format@\the\jlreq@BlockHeading@spaces@current@count\endcsname{%
    \expandonce{\@tempa#4}%
  }%
  \def\@tempa##1##2##3{##3}%
  \expandafter\xdef\csname jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count\endcsname{%
    \expandonce{\jlreq@resultc}%
    \expandonce{\@tempa#4}%
  }%
  \ifx\jlreq@BlockHeading@spaces@headingslist\@empty
    \expandafter\jlreq@BlockHeading@spaces@outputwospace
    \expandafter\ignorespaces
  \else
    \expandafter\jlreq@BlockHeading@start@afterheading
  \fi
}

\def\jlreq@BlockHeading@start@afterheading{\futurelet\jlreq@nextchar\jlreq@BlockHeading@start@afterheading@}
\edef\jlreq@BlockHeading@start@afterheading@{%
  \noexpand\ifx\expandonce{\space}\unexpanded{\jlreq@nextchar\expandafter\jlreq@BlockHeading@start@afterheading@@}%
  \unexpanded{\else\expandafter\jlreq@BlockHeading@start@afterheading@@@\fi}%
}
% スペースを読み飛ばす
\expandafter\def\expandafter\jlreq@BlockHeading@start@afterheading@@\space{\jlreq@BlockHeading@start@afterheading}
\def\jlreq@BlockHeading@start@afterheading@@@{%
  \def\jlreq@do{\jlreq@BlockHeading@spaces@output}%
  \@for\@tempa:=\jlreq@BlockHeading@allheadings\do{%
    \expandafter\ifx\csname\@tempa\endcsname\jlreq@nextchar\def\jlreq@do{}\fi
  }%
  % \jlreq@BlockHeading@HeadingSpaces@ignoretokens内のものは特別扱いする
  \expandafter\@tfor\expandafter\@tempa\expandafter:\expandafter=\jlreq@BlockHeading@HeadingSpaces@ignoretokens\do{%
    \expandafter\ifx\@tempa\jlreq@nextchar
      \def\jlreq@do{\jlreq@BlockHeading@start@afterheading@saveafter@cs}%
    \fi
  }%
  \jlreq@do
}

% コントロールシークエンスを保存
\long\def\jlreq@BlockHeading@start@afterheading@saveafter@cs#1{%
  \csgappto{jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count}{#1}%
  \jlreq@BlockHeading@start@afterheading@saveafter@option
}
% オプションがあれば保存
\def\jlreq@BlockHeading@start@afterheading@saveafter@option{%
  \@ifnextchar[{\jlreq@BlockHeading@start@afterheading@saveafter@option@}{\jlreq@BlockHeading@start@afterheading@saveafter@arguments}%
}
\long\def\jlreq@BlockHeading@start@afterheading@saveafter@option@[#1]{%
  \csxappto{jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count}{\unexpanded{[#1]}}%
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
  \csgappto{jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count}{ }%
  \jlreq@BlockHeading@start@afterheading@saveafter@arguments
}
\def\jlreq@BlockHeading@start@afterheading@saveafter@arguments@@@{%
  \jlreq@ifnextchar\bgroup{\jlreq@BlockHeading@start@afterheading@saveafter@arguments@@@@}{\jlreq@BlockHeading@start@afterheading}%
}
\long\def\jlreq@BlockHeading@start@afterheading@saveafter@arguments@@@@#1{%
  \csxappto{jlreq@BlockHeading@spaces@current@after@\the\jlreq@BlockHeading@spaces@current@count}{\unexpanded{{#1}}}%
  \jlreq@BlockHeading@start@afterheading@saveafter@arguments
}

% 特別扱いしたいマクロを並べる
\def\jlreq@BlockHeading@HeadingSpaces@ignoretokens{\label}

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
    \edef\jlreq@do{\noexpand\jlreq@BlockHeading@start@makeoutput@@\expandonce{\jlreq@tempa}\expandonce{\jlreq@tempb}\unexpanded{{#8}{#9}}}%
    \jlreq@do
    \edef\jlreq@do{\noexpand\jlreq@BlockHeading@start@makeoutput@\unexpanded{#3}{\expandonce{\jlreq@result}}}%
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
        \expandonce{\jlreq@result}%
      }%
      \unexpanded{\def\jlreq@resultc}{%
        \expandonce{\csname jlreq@heading@maketoc@#1\endcsname}{\unexpanded{#6}}{\expandonce{\jlreq@tempa}}{\unexpanded{#7}}%
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
    \edef\jlreq@tempa{\noexpand\jlreq@tempc{\unexpanded{#1}}{\expandonce{\jlreq@tempa}}{\expandonce{\jlreq@tempb}}}%
    \edef\jlreq@do{%
      \unexpanded{\def\jlreq@result}{\expandafter\expandonce\expandafter{\jlreq@tempa}}%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\def\jlreq@BlockHeading@start@removecolumn#1:{#1}

% 空き指定を解釈する．a:10pt -> \jlreq@resulta=a，\jlreq@resultb=10pt
\def\jlreq@BlockHeading@start@analyzespace#1:#2\jlreq@endmark{%
  \jlreq@ifempty{#1}{%
    \def\jlreq@resulta{}%
    \def\jlreq@resultb{}%
  }{%
    \let\jlreq@resulta=#1%
    \edef\jlreq@resultb{\expandonce{\jlreq@BlockHeading@start@removecolumn#2}}%
  }%
}

% 行取り処理．#3が空の時は行取りの処理はしない．（空白挿入は行う．）
% {1 = 前空き}{2 = 後ろ空き}{3 = トータル行数}{4 = 偶数ページ改ページするなら空}{5 = 出力}
\long\def\jlreq@BlockHeading@start@gyodori#1#2#3#4#5{\par{%
  \jlreq@ifempty{#4}{\jlreq@setcurrentpage}{}%
  \setbox\jlreq@tempboxa=\vbox{#5}%
  % \jlreq@tempskip(a/b)に前/後ろに入れるべき値を入れる
  % #1がa:ならばその値は\jlreq@tempskipaには足さず\jlreq@tempskipcに入れておく
  \jlreq@tempskipa=0pt
  \jlreq@tempskipb=0pt
  \jlreq@tempskipc=0pt
  \jlreq@BlockHeading@start@analyzespace#1:\jlreq@endmark
  \let\jlreq@maeakitype=\jlreq@resulta
  \let\jlreq@maeaki=\jlreq@resultb
  \jlreq@BlockHeading@start@analyzespace#2:\jlreq@endmark
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
    \ifx r\jlreq@ushiroakitype\prevdepth=-1000pt \else\prevdepth=\jlreq@tempdimc\fi
    % \jlreq@tempdimb, \jlreq@tempdimcの利用ここまで
  \else
    \dp\jlreq@tempboxa=\dimexpr\dp\jlreq@tempboxa + \ht\jlreq@tempboxa\relax
    \ht\jlreq@tempboxa=0pt
    \box\jlreq@tempboxa
    \ifx r\jlreq@ushiroakitype\prevdepth=-1000pt \else\prevdepth=0pt \fi
  \fi
  \jlreq@ifempty{#4}{\ifodd\jlreq@currentpage\nobreak\fi}{\nobreak}%
  \jlreq@ifgluezero\jlreq@tempskipb{}{\vskip\jlreq@tempskipb}%
  \edef\jlreq@do{%
    \ifdim\parskip=0pt \else
      \unexpanded{\def\jlreq@parhook@gyodori}{%
        \noexpand\parskip=\the\parskip
        \unexpanded{\def\jlreq@parhook@gyodori{}}%
      }%
      \unexpanded{\parskip=0pt plus 1pt}%
    \fi
  }%
  \expandafter}\jlreq@do
}
\PushPostHook{par}{\jlreq@parhook@gyodori}
\def\jlreq@parhook@gyodori{}

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
  \begingroup
    \def\jlreq@lines{#6}%
    \def\jlreq@before@space{}%
    \def\jlreq@before@lines{}%
    \def\jlreq@after@space{}%
    \def\jlreq@after@lines{}%
    \jlreq@parsekeyval#1[#2]{
      {lines}{\def\jlreq@lines{##1}}
      {before_space}{\def\jlreq@before@space{##1}}
      {after_space}{\def\jlreq@after@space{##1}}
      {before_lines}{%
        \jlreq@ifempty{##1}{\def\jlreq@before@lines{}}{%
          \jlreq@iffirsttoken@ignorespaces{##1}{*}%
            {\edef\jlreq@before@lines{s:\expandonce{\@gobble ##1}}}%
            {\def\jlreq@before@lines{a:##1}}%
        }%
      }
      {after_lines}{\def\jlreq@after@lines{##1}}
    }{#3}%
    % before/after_lines優先
    \ifx\jlreq@before@space\@empty\else\edef\jlreq@before@space{r:\expandonce{\jlreq@before@space}}\fi
    \ifx\jlreq@before@lines\@empty\else\edef\jlreq@before@space{\expandonce{\jlreq@before@lines}\baselineskip}\fi
    \ifx\jlreq@before@space\@empty\def\jlreq@before@space{#4}\fi
    \ifx\jlreq@after@space\@empty\else\edef\jlreq@after@space{r:\expandonce{\jlreq@after@space}}\fi
    \ifx\jlreq@after@lines\@empty\else\edef\jlreq@after@space{a:\expandonce{\jlreq@after@lines}\baselineskip}\fi
    \ifx\jlreq@after@space\@empty\def\jlreq@after@space{#5}\fi
    \edef\jlreq@do{%
      \unexpanded{\def\jlreq@result}{{\expandonce{\jlreq@before@space}}{\expandonce{\jlreq@after@space}}{\expandonce{\jlreq@lines}}}%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\newbox\jlreq@BlockHeading@start@label@box
% \DeclareBlockHeading{命令名}{レベル}{設定}
\def\jlreq@BlockHeading@allheadings{}% 別行見出し一覧
\newcommand{\DeclareBlockHeading}[3]{%
  \def\jlreq@do{\@removeelement{#1}}%
  \expandafter\jlreq@do\expandafter{\jlreq@heading@allheadings}{\jlreq@heading@allheadings}%
  \appto\jlreq@heading@allheadings{,#1}%
  \expandafter\jlreq@do\expandafter{\jlreq@BlockHeading@allheadings}{\jlreq@BlockHeading@allheadings}%
  \appto\jlreq@BlockHeading@allheadings{,#1}%
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\edef\csname jlreq@heading@setting@#1\endcsname{\unexpanded{#3}}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewBlockHeading}%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \jlreq@heading@make@maketoc{#1}{#2}%
  \begingroup
    \def\jlreq@font{}%
    \def\jlreq@subtitle@font{}%
    \def\jlreq@indent{0\zw}%
    \def\jlreq@end@indent{0\zw}%
    \def\jlreq@align{l}%
    \edef\jlreq@format{\unexpanded{##1##2##3}}%
    \edef\jlreq@heading@text@format{\unexpanded{##1}}%
    \def\jlreq@pagebreak{}%
    \def\jlreq@label@format{\@seccntformat{#1}}%
    \newif\ifjlreq@second@text@indent@withlabel\jlreq@second@text@indent@withlabeltrue
    \def\jlreq@after@label@space{1\zw}%
    \def\jlreq@second@heading@text@indent@wlabel{0pt}%
    \def\jlreq@second@heading@text@indent@wolabel{0pt}%
    \edef\jlreq@subtitle@format{\unexpanded{---##1---}}%
    \newif\ifjlreq@subtitleindent@withlabel\jlreq@subtitleindent@withlabeltrue
    \def\jlreq@subtitle@indent{1\zw}%
    \def\jlreq@afterindent{\@afterindenttrue}%
    \def\jlreq@allowbreak@evenpage{*}% 偶数ページでも改ページを許可するならば空，そうでないなら*
    \newif\ifjlreq@subtitle@break\jlreq@subtitle@breaktrue
    \def\jlreq@subtitle@indent{1\zw}%
    \def\jlreq@column@spanning{false}%
    \newif\ifjlreq@column@spanning@possible\jlreq@column@spanning@possiblefalse
    \newif\ifjlreq@number \jlreq@numbertrue
    % a,bみたいなのをaとbにわける．カンマがなければbは空．引数を{a}{b}として##2を呼び出す．
    \def\jlreq@parsecomma##1##2{%
      \jlreq@helper@dividebycomma{##1}%
      \ifjlreq@result\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi{%
        \edef\jlreq@do{\noexpand\jlreq@tempa{\expandonce{\jlreq@resulta}}{\expandonce{\jlreq@resultb}}}%
      }{%
        \edef\jlreq@do{\noexpand\jlreq@tempa{##1}{}}%
      }%
      \def\jlreq@tempa####1####2{##2}%
      \jlreq@do
    }%
    \jlreq@parsekeyval[BlockHeading:#1]{
      {lines}{}
      {before_space}{}
      {after_space}{}
      {before_lines}{}
      {after_lines}{}
      {font}{\def\jlreq@font{##1}}
      {subtitle_font}{\def\jlreq@subtitle@font{##1}}
      {indent}{\def\jlreq@indent{##1}}
      {end_indent}{\def\jlreq@end@indent{##1}}
      {align}[left,center,right]{%
        \jlreq@switch{##1}{
          {left}{\def\jlreq@align{l}}
          {center}{\def\jlreq@align{c}}
          {right}{\def\jlreq@align{r}}
        }%
      }
      {format}{\edef\jlreq@format{\unexpanded{##1}}}
      {after_label_space}{\def\jlreq@after@label@space{##1}}
      {second_heading_text_indent,heading_text_second_indent}{%
        \jlreq@parsecomma{##1}{%
          \jlreq@iffirsttoken{####1}{*}{%
            \jlreq@second@text@indent@withlabelfalse
            \edef\jlreq@second@heading@text@indent@wlabel{\expandonce{\@gobble ####1}}%
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
      }
      {label_format}{\edef\jlreq@label@format{\unexpanded{##1}}}
      {subtitle_format}{\edef\jlreq@subtitle@format{\unexpanded{##1}}}
      {subtitle_indent}{%
        \jlreq@iffirsttoken{##1}{*}{%
          \jlreq@subtitleindent@withlabelfalse
          \edef\jlreq@subtitle@indent{\expandonce{\@gobble ##1}}%
        }{%
          \jlreq@subtitleindent@withlabeltrue
          \def\jlreq@subtitle@indent{##1}%
        }%
      }
      {subtitle_break}[true,false]{\csname jlreq@subtitle@break##1\endcsname}
      {afterindent}[true,false]{\edef\jlreq@afterindent{\expandonce{\csname @afterindent##1\endcsname}}}
      {allowbreak_if_evenpage}[true,false]{%
        \jlreq@switch{##1}{
          {true}{\def\jlreq@allowbreak@evenpage{}}
          {false}{\def\jlreq@allowbreak@evenpage{*}}
        }%
      }
      {pagebreak}[clearpage,cleardoublepage,clearcolumn,nariyuki,begin_with_odd_page,begin_with_even_page]{%
        \jlreq@switch{##1}{
          {clearpage}{\def\jlreq@pagebreak{\clearpage}\jlreq@column@spanning@possibletrue}
          {cleardoublepage}{\def\jlreq@pagebreak{\cleardoublepage}\jlreq@column@spanning@possibletrue}
          {clearcolumn}{\if@twocolumn\def\jlreq@pagebreak{\newpage}\else\def\jlreq@pagebreak{}\fi\jlreq@column@spanning@possiblefalse}
          {begin_with_even_page}{\def\jlreq@pagebreak{\cleartoevenpage[empty]}\jlreq@column@spanning@possibletrue}
          {begin_with_odd_page}{\def\jlreq@pagebreak{\cleartooddpage[empty]}\jlreq@column@spanning@possibletrue}
          {nariyuki}{\def\jlreq@pagebreak{}\jlreq@column@spanning@possiblefalse}
        }%
      }
      % 後々数字を受け付けるようになったりするかもしれないので……
      {column_spanning}{%
        \jlreq@tempatrue % validな入力に対してfalse
        \jlreq@ifempty{##1}{}{%
          \jlreq@ifnumber{##1}{% 数字の時はtrueに回す
            \jlreq@tempafalse
            \def\jlreq@column@spanning{true}%
          }{%
            \jlreq@switch{##1}{%
              {true}{\jlreq@tempafalse\def\jlreq@column@spanning{true}}
              {false}{\jlreq@tempafalse\def\jlreq@column@spanning{false}}
            }%
          }%
        }%
        \ifjlreq@tempa\ClassWarningNoLine{jlreq}{Invalid input `##1' for column_spanning in BlockHeading #1}\fi
      }
      {number}[true,false]{\csname jlreq@number##1\endcsname}
    }{#3}%
    \def\jlreq@do{}% 初期化．これに最終処理を入れていく．
    % 入力チェック
    \ifthenelse{\equal{\jlreq@column@spanning}{true}}{%
      \ifjlreq@column@spanning@possible\else
        \ClassWarningNoLine{jlreq}{column_spanning can be used only with `pagebreak=nariyuki' or `pagebreak=clearcolumn' (in BlockHeading #1)}%
        \def\jlreq@column@spanning{false}%
      \fi
    }{}%
    % ラベルありフォーマット：前
    \edef\jlreq@pre@format@wlabel{%
      \noexpand\noindent
      \expandonce{\jlreq@font}%
      \ifnum 0\ifjlreq@second@text@indent@withlabel 1\fi\ifjlreq@subtitleindent@withlabel 1\fi>0
        \unexpanded{\setbox\jlreq@BlockHeading@start@label@box=\hbox}{\expandonce{\jlreq@label@format}}%
        \unexpanded{\xdef\jlreq@BlockHeading@start@labellength{\the\wd\jlreq@BlockHeading@start@label@box}}%
        \unexpanded{\def\jlreq@BlockHeading@start@outputlabel{\box\jlreq@BlockHeading@start@label@box}}%
      \else
        \unexpanded{\xdef\jlreq@BlockHeading@start@labellength{0pt}}%
        \unexpanded{\def\jlreq@BlockHeading@start@outputlabel}{\expandonce{\jlreq@label@format}}%
      \fi
    }%
    % ラベルなしフォーマット：前
    \edef\jlreq@pre@format@wolabel{%
      \noexpand\noindent
      \expandonce{\jlreq@font}%
      \unexpanded{\xdef\jlreq@BlockHeading@start@labellength{0pt}}%
      \unexpanded{\def\jlreq@BlockHeading@start@outputlabel}{}%
    }%
    % 空き量などの調整を含んだラベル
    \edef\jlreq@label@format@modified{%
      \noexpand\jlreq@BlockHeading@start@outputlabel
      \unexpanded{\inhibitglue\hbox{}}%
      \ifdim\dimexpr\jlreq@after@label@space\relax=0pt \else
        \noexpand\hspace*{\noexpand\dimexpr\expandonce{\jlreq@after@label@space}\noexpand\relax}%
      \fi
    }%
    \edef\jlreq@heading@text@format@wlabel{%
      \ifnum 0\ifdim\jlreq@second@heading@text@indent@wlabel=0pt \else 1\fi\ifjlreq@second@text@indent@withlabel 1\fi>0
        \unexpanded{\hangindent=\glueexpr}(\expandonce{\jlreq@second@heading@text@indent@wlabel})%
          \ifjlreq@second@text@indent@withlabel + (\expandonce{\jlreq@after@label@space}) + \unexpanded{\jlreq@BlockHeading@start@labellength}\fi
          \noexpand\relax
      \fi
      \expandonce{\jlreq@heading@text@format}%
    }%
    \edef\jlreq@heading@text@format@wolabel{%
      \ifdim\dimexpr\jlreq@second@heading@text@indent@wolabel\relax=0pt \else
        \unexpanded{\hangindent=\dimexpr}\expandonce{\jlreq@second@heading@text@indent@wolabel}\noexpand\relax
      \fi
      \expandonce{\jlreq@heading@text@format}%
    }%
    % 副題：ラベルありかなしかはhangindentの扱いだけなので，他はまとめる
    \def\jlreq@make@subtitle@format##1##2{%
      \edef##1{%
        \ifjlreq@subtitle@break
          \noexpand\par
          ##2%
          \unexpanded{\nobreak\noindent}%
        \else
          \ifdim\jlreq@subtitle@indent=0pt \else
            \noexpand\hspace*{\expandonce{\jlreq@subtitle@indent}}%
          \fi
        \fi
        {\expandonce{\jlreq@subtitle@font}\expandonce{\jlreq@subtitle@format}}%
      }%
    }%
    \jlreq@make@subtitle@format\jlreq@subtitle@format@wlabel{%
      \ifjlreq@subtitleindent@withlabel
        \noexpand\hangafter=0
        \unexpanded{\hangindent=\dimexpr}\noexpand\jlreq@BlockHeading@start@labellength + (\expandonce{\jlreq@after@label@space}) + (\expandonce{\jlreq@subtitle@indent})\noexpand\relax
      \else
        \ifdim\jlreq@subtitle@indent=0pt \else
          \noexpand\hangafter=0
          \unexpanded{\hangindent=\dimexpr}\expandonce{\jlreq@subtitle@indent}\noexpand\relax
        \fi
      \fi
    }%
    \jlreq@make@subtitle@format\jlreq@subtitle@format@wolabel{%
      \ifdim\jlreq@subtitle@indent=0pt \else
        \noexpand\hangafter=0
        \unexpanded{\hangindent=\dimexpr}\expandonce{\jlreq@subtitle@indent}\noexpand\relax
      \fi
    }%
    \jlreq@heading@make@l@{#1}{#2}{\jlreq@label@format}%
    \eappto\jlreq@do{\expandonce{\jlreq@result}}%
    \jlreq@BlockHeading@gyodori@parsekeyval*[BlockHeading:#1]{#3}{}{}{1}%
    \let\jlreq@spaceset=\jlreq@result
    \edef\jlreq@totalformat{\unexpanded{##1}}%
    \edef\jlreq@totalformat@after{\expandonce{\jlreq@afterindent}\noexpand\@afterheading}%
    \if@twocolumn
      \ifthenelse{\equal{\jlreq@column@spanning}{true}}{%
        \def\@tempa##1##2##3{%
          % 前開きが常に入ってしまうので，a:の時は除去する
          \jlreq@iffirsttoken{##1}{a}{\def\jlreq@spaceset{{}{##2}{##3}}}{}%
          \edef\jlreq@totalformat{%
            \unexpanded{\if@twocolumn\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}{%
              \noexpand\twocolumn[{%
                % 普段自動で入る\topskipと\baselineskipを手動で入れる
                \jlreq@iffirsttoken{##1}{r}{}{\unexpanded{\vskip\topskip\relax}}%
                \unexpanded{####1}%
                \jlreq@iffirsttoken{##2}{r}{}{\unexpanded{\vskip\glueexpr\baselineskip - \topskip\relax}}%
              }]%
            }{%
              \expandonce{\jlreq@totalformat}
            }%
          }%
        }%
        \expandafter\@tempa\jlreq@spaceset
        \def\jlreq@totalformat@after{}%
      }{%
      }%
    \fi
    \edef\jlreq@do{%
      \expandonce{\jlreq@do}%
      \noexpand\edef\expandonce{\csname jlreq@headingcs@#1\endcsname}{\noexpand\unexpanded{%
        \noexpand\jlreq@hook@beforeheadings{#1}%
        \expandonce{\jlreq@pagebreak}%
        \unexpanded{\jlreq@BlockHeading@start{#1}{#2}}%
        {{\expandonce{\jlreq@align}}{\expandonce{\jlreq@indent}}{\expandonce{\jlreq@end@indent}}\expandonce{\jlreq@spaceset}{\expandonce{\jlreq@allowbreak@evenpage}}}%
        {\ifjlreq@number\else -\fi}%
        {%
          {%
            {\expandonce{\jlreq@label@format}}{\expandonce{\jlreq@label@format@modified}}%
            {\expandonce{\jlreq@heading@text@format@wlabel}}{\expandonce{\jlreq@heading@text@format@wolabel}}%
            {\expandonce{\jlreq@subtitle@format@wlabel}}{\expandonce{\jlreq@subtitle@format@wolabel}}%
          }%
          {%
            {\expandonce{\jlreq@pre@format@wlabel}}{\expandonce{\jlreq@pre@format@wolabel}}%
            {\expandonce{\jlreq@format}}%
            {}{}%
          }%
        }%
        {{}{\expandonce{\jlreq@totalformat}}{\expandonce{\jlreq@totalformat@after}}}%
      }}%
      \noexpand\def\expandonce{\csname #1\endcsname}{\expandonce{\csname jlreq@headingcs@#1\endcsname}}%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\newcommand{\NewBlockHeading}[3]{%
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareBlockHeading{#1}{#2}{#3}}%
}
\newcommand{\RenewBlockHeading}[3]{%
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareBlockHeading{#1}{#2}{#3}}%
}
\newcommand{\ProvideBlockHeading}[3]{%
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

\newcommand{\SetBlockHeadingSpaces}[1]{%
  \begingroup
    % 現段階の情報をクリアする
    \def\jlreq@tempa{}% 見出しリスト
    \def\jlreq@tempb{}% 設定リスト \def\jlreq@BlockHeading@spaces@***{{**}{**}...}ってのを入れる
    \jlreq@SetBlockHeadingSpaces#1\jlreq@endmark
    \edef\jlreq@do{%
      \unexpanded{%
        \@for\@tempa:=\jlreq@BlockHeading@spaces@headingslist\do{%
          \expandafter\let\csname jlreq@BlockHeading@spaces@setlist@\@tempa\endcsname=\@undefined
        }%
      }%
      \unexpanded{\def\jlreq@BlockHeading@spaces@headingslist}{\expandonce{\jlreq@tempa}}%
      \expandonce{\jlreq@tempb}%
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
    \eappto\jlreq@tempa{,\expandonce{\jlreq@headings}}% \jlreq@tempaに\jlreq@headingsを追加
    \ifjlreq@tempb
      \ifx\jlreq@lastdimen\@empty\else % 最後が寸法だったので\jlreq@SetBlockHeadingSpaces@totalsetを改変
        \def\jlreq@do##1##2##3{%
          \edef\jlreq@totalset{{\unexpanded{##1}}{r:\expandonce{\jlreq@lastdimen}}{\unexpanded{##3}}}%
        }%
        \expandafter\jlreq@do\jlreq@totalset
      \fi
    \else
      \eappto\jlreq@set{{\expandonce{\jlreq@lastdimen}}}%
    \fi
    \eappto\jlreq@tempb{%
      \noexpand\@ifundefined{jlreq@BlockHeading@spaces@setlist@\jlreq@headings}{}{%
        \noexpand\ClassError{jlreq}{The spaces for \jlreq@headings\space is defined more than once (in SetBlockHeadingSpaces)}{\noexpand\@ehc}%
      }%
      \noexpand\def\expandonce{\csname jlreq@BlockHeading@spaces@setlist@\jlreq@headings\endcsname}{{\expandonce{\jlreq@totalset}}\expandonce{\jlreq@set}}%
    }%
    \jlreq@SetBlockHeadingSpaces
  }%
}
\def\jlreq@SetBlockHeadingSpaces@iii#1{%
  \@for\@tempa:=#1\do{%
    \expandafter\jlreq@helper@trim\expandafter{\@tempa}{\@tempa}%
    \expandafter\jlreq@iffirsttoken@ignorespaces\expandafter{\@tempa}{_}{%
      \ifx\jlreq@lastdimen\@empty\else\eappto\jlreq@set{{\expandonce{\jlreq@lastdimen}}}\fi%
      \def\jlreq@lastdimen{}%
      \expandafter\jlreq@SetBlockHeadingSpaces@iv\@tempa{\jlreq@endmark}%
    }{%
      \ifjlreq@tempa
        % 最初が寸法なので，全体の設定（\jlreq@totalset）に組み込む．
        \def\jlreq@do##1##2##3{%
          \edef\jlreq@totalset{{r:\expandonce{\@tempa}}{\unexpanded{##2}}{\unexpanded{##3}}}%
        }%
        \expandafter\jlreq@do\jlreq@totalset
      \else
        \ifx\jlreq@lastdimen\@empty\else\eappto\jlreq@set{{\expandonce{\jlreq@lastdimen}}}\fi
        \let\jlreq@lastdimen=\@tempa
      \fi
    }%
    \jlreq@tempafalse
  }%
}
\def\jlreq@SetBlockHeadingSpaces@iv#1#{%
  \expandafter\jlreq@ifcontains\expandafter{\@gobble #1}{_}{%
    \ClassWarning{jlreq}{Unusual heading name `\@gobble #1' is found. You forgot a comma? (in SetBlockHeadingSpaces)}%
  }{}%
  \jlreq@ifendswith{#1}{*}{{%
    \def\@tempa_##1*{\def\@tempa{##1}}%
    \@tempa#1%
    \ClassWarning{jlreq}{The heading name `\@gobble #1' ends with `*'. Do you mean `_\@tempa{*}'? (in SetBlockHeadingSpaces)}%
  }}{}%
  \appto\jlreq@headings{#1}%
  \jlreq@SetBlockHeadingSpaces@v
}
\def\jlreq@SetBlockHeadingSpaces@v#1{%
  % 空っぽの場合は{_{r:0pt}{r:0pt}{}}
  \jlreq@ifendmark{#1}{\appto\jlreq@set{{_{r:0pt}{r:0pt}{}}}}{%
    \jlreq@iffirsttoken{#1}{*}{% *始まりの場合は{_*{}{}{}}
      \expandafter\jlreq@BlockHeading@gyodori@parsekeyval\expandafter{\@gobble #1}{}{}{}%
      \eappto\jlreq@set{{_*\expandonce{\jlreq@result}}}%
    }{% それ以外の場合は{_{}{}{}}
      \jlreq@BlockHeading@gyodori@parsekeyval{#1}{}{}{}%
      \eappto\jlreq@set{{_\expandonce{\jlreq@result}}}%
    }%
    \@gobble % \jlreq@endmarkを食う
  }%
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
    \eappto\jlreq@do{\csexpandonce{jlreq@BlockHeading@spaces@current@before@\the\jlreq@tempcnta}}%
    \edef\jlreq@tempa{%
      \unexpanded{\long\def\jlreq@tempa##1}{\csexpandonce{jlreq@BlockHeading@spaces@current@format@\the\jlreq@tempcnta}}%
    }%
    \jlreq@tempa
    \edef\jlreq@tempb{%
      \noexpand\expandonce{\noexpand\jlreq@tempa{%
        \noexpand\jlreq@BlockHeading@start@gyodori
          \csexpandonce{jlreq@BlockHeading@spaces@current@space@\the\jlreq@tempcnta}%
          {\csexpandonce{jlreq@BlockHeading@spaces@current@output@\the\jlreq@tempcnta}}%
      }}%
    }%
    \eappto\jlreq@do{\jlreq@tempb\csexpandonce{jlreq@BlockHeading@spaces@current@after@\the\jlreq@tempcnta}}%
    \expandafter\jlreq@BlockHeading@spaces@outputwospace@
  \fi
}

\def\jlreq@BlockHeading@spaces@output@#1#2\jlreq@endmark{%
  \def\jlreq@result{}%
  \jlreq@tempcnta=0
  \jlreq@BlockHeading@spaces@output@@#2\jlreq@endmark
  \jlreq@tempatrue % 周りの行取り処理が必要か
  \jlreq@ifempty{#1}{\jlreq@tempafalse}{}%
  \ifthenelse{\equal{#1}{{}{}{}}}{\jlreq@tempafalse}{}%
  \edef\jlreq@do{%
    \ifjlreq@tempa
      \unexpanded{\jlreq@BlockHeading@start@gyodori#1}{*}{%
        \expandonce{\jlreq@result}%
      }%
    \else
      \expandonce{\jlreq@result}%
    \fi
  }%
  \jlreq@BlockHeading@spaces@clear
  \jlreq@do
}
% jlreq@resultに出力すべきものを入れていく
\def\jlreq@BlockHeading@spaces@output@@#1{%
  \jlreq@ifendmark{#1}{}{%
    \jlreq@iffirsttoken@ignorespaces{#1}{_}{%
      \advance\jlreq@tempcnta by 1
      \expandafter\jlreq@BlockHeading@spaces@output@@@\expandafter{\@gobble #1}%
    }{%
      \appto\jlreq@result{\vskip\glueexpr #1\relax}%
    }%
    \jlreq@BlockHeading@spaces@output@@
  }%
}
\def\jlreq@BlockHeading@spaces@output@@@#1{%
  \edef\jlreq@do{%
    \noexpand\jlreq@BlockHeading@spaces@output@@@@
    \jlreq@iffirsttoken@ignorespaces{#1}{*}{{*}\expandonce{\@gobble #1}}{\unexpanded{{}#1}}%
      \csexpandonce{jlreq@BlockHeading@spaces@current@space@\the\jlreq@tempcnta}%
      {\csexpandonce{jlreq@BlockHeading@spaces@current@output@\the\jlreq@tempcnta}}%
  }%
  \jlreq@do
}
% #1: デフォルト値を使うならば*，#2#3#4が設定された値，#5#6#7がデフォルト値，#8は偶数ページの，#9が出力
\def\jlreq@BlockHeading@spaces@output@@@@#1#2#3#4#5#6#7#8#9{%
  \edef\jlreq@tempa{%
    \unexpanded{\long\def\jlreq@tempa##1}{\csexpandonce{jlreq@BlockHeading@spaces@current@format@\the\jlreq@tempcnta}}%
  }%
  \jlreq@tempa
  \edef\jlreq@tempb{%
    \noexpand\expandonce{\noexpand\jlreq@tempa{%
      \noexpand\jlreq@BlockHeading@start@gyodori
      \jlreq@ifempty{#1}{\unexpanded{{#2}{#3}{#4}}}{%
        {\jlreq@ifempty{#2}{\unexpanded{#5}}{\unexpanded{#2}}}%
        {\jlreq@ifempty{#3}{\unexpanded{#6}}{\unexpanded{#3}}}%
        {\jlreq@ifempty{#4}{\unexpanded{#7}}{\unexpanded{#4}}}%
      }\unexpanded{{#8}{#9}}%
    }}%
  }%
  \eappto\jlreq@result{%
    \csexpandonce{jlreq@BlockHeading@spaces@current@before@\the\jlreq@tempcnta}%
    \jlreq@tempb
    \csexpandonce{jlreq@BlockHeading@spaces@current@after@\the\jlreq@tempcnta}%
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
  \edef\jlreq@do{\unexpanded{\jlreq@RuninHeading@start@@{#1}{#2}{#3}{#4}{#5}}{\expandonce{\jlreq@RuninHeading@start@format@label}}{\expandonce{\jlreq@RuninHeading@start@format@wlabel}}{\expandonce{\jlreq@RuninHeading@start@format@wolabel}}}%
  \jlreq@do
}
% {1 = 命令名}{2 = レベル}{3 = *}{4 = running head}{5 = 見出し}{6 = ラベルフォーマット}{7 = ラベルありフォーマット}{8 = ラベルなしフォーマット}
\long\def\jlreq@RuninHeading@start@@#1#2#3#4#5#6#7#8{%
  \if@noskipsec\leavevmode\fi
  \begingroup
    \def\jlreq@do{\global\@noskipsectrue}%
    \ifnum0\jlreq@ifempty{#3}{}{1}\ifnum #2>\c@secnumdepth 1\fi>0
      \def\jlreq@tempa##1{#8}%
    \else
      \appto\jlreq@do{\refstepcounter{#1}}%
      \def\jlreq@tempa##1{#7}%
    \fi
    \par
    \eappto\jlreq@do{%
      \noexpand\everypar{%
        \noexpand\if@noskipsec
          \unexpanded{\global\@noskipsecfalse}%
          \unexpanded{{\setbox\jlreq@tempboxa\lastbox}}%
          \noexpand\begingroup
            \expandonce{\jlreq@tempa{#5}}%
            \expandonce{\csname jlreq@heading@maketoc@#1\endcsname}{#3}{#6}{#4}%
          \noexpand\endgroup
        \noexpand\else
          \unexpanded{\everypar{}}%
        \noexpand\fi
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
  \ignorespaces
}

% \DeclareRuninHeading{命令名}{レベル}{設定}
\newcommand*{\DeclareRuninHeading}[3]{%
  \def\jlreq@do{\@removeelement{#1}}%
  \expandafter\jlreq@do\expandafter{\jlreq@heading@allheadings}{\jlreq@heading@allheadings}%
  \appto\jlreq@heading@allheadings{,#1}%
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\edef\csname jlreq@heading@setting@#1\endcsname{\unexpanded{#3}}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewRuninHeading}%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \@ifundefined{l@#1}{\expandafter\def\csname l@#1\endcsname{\@dottedtocline{#2}{0\zw}{2\zw}}}{}%
  \jlreq@heading@make@maketoc{#1}{#2}%
  \begingroup
    \def\jlreq@font{\normalfont\normalsize}%
    \def\jlreq@indent{0\zw}%
    \def\jlreq@after@label@space{1\zw}%
    \def\jlreq@label@font{}%
    \def\jlreq@label@format{\@seccntformat{#1}}%
    \def\jlreq@after@space{1\zw}%
    \newif\ifjlreq@number \jlreq@numbertrue
    \jlreq@parsekeyval[RuninHeading:#1]{%
      {font}{\def\jlreq@font{##1}}
      {indent}{\def\jlreq@indent{##1}}
      {label_format}{\def\jlreq@label@format{##1}}
      {after_label_space}{%
        \ifdim\dimexpr##1\relax<0pt \ClassWarning{jlreq}{after_label_space in Runin Heading #1 should be not negative}\fi
        \def\jlreq@after@label@space{##1}%
      }
      {after_space}{%
        \ifdim\dimexpr##1\relax<0pt \ClassWarning{jlreq}{after_space in Runin Heading #1 should be not negative}\fi
        \def\jlreq@after@space{##1}%
      }
      {number}{\csname jlreq@number##1\endcsname}
    }{#3}%
    \newif\ifjlreq@indent@zero
    \jlreq@ifgluezero{\glueexpr\jlreq@indent\relax}{\jlreq@indent@zerotrue}{\jlreq@indent@zerofalse}%
    \newif\ifjlreq@after@space@zero
    \jlreq@ifgluezero{\glueexpr\jlreq@after@space\relax}{\jlreq@after@space@zerotrue}{\jlreq@after@space@zerofalse}%
    \newif\ifjlreq@after@label@space@zero
    \jlreq@ifgluezero{\glueexpr\jlreq@after@label@space\relax}{\jlreq@after@label@spacefalse}%
    \edef\jlreq@format@wlabel{{%
      \ifjlreq@indent@zero\else\unexpanded{\hskip\glueexpr}\expandonce{\jlreq@indent}\noexpand\relax\fi
      \expandonce{\jlreq@font}%
      \expandonce{\jlreq@label@format}%
      \ifjlreq@after@label@space@zero\else\unexpanded{\hskip\glueexpr}\expandonce{\jlreq@after@label@space}\noexpand\relax\fi
      ####1%
      \ifjlreq@after@space@zero\else\unexpanded{\hskip\glueexpr}\expandonce{\jlreq@after@space}\noexpand\relax\fi
    }}%
    \edef\jlreq@format@wolabel{{%
      \ifjlreq@indent@zero\else\unexpanded{\hskip\glueexpr}\expandonce{\jlreq@indent}\noexpand\relax\fi
      \expandonce{\jlreq@font}%
      ####1%
      \ifjlreq@after@space@zero\else\unexpanded{\hskip\glueexpr}\expandonce{\jlreq@after@space}\noexpand\relax\fi
    }}%
    \jlreq@heading@make@l@{#1}{#2}{\jlreq@label@format}%
    \edef\jlreq@do{%
      \expandonce{\jlreq@result}%
      % パラメータトークンを含むので，\edefして\unexpandedで包む
      \noexpand\edef\expandonce{\csname #1\endcsname}{%
        \noexpand\unexpanded{%
          \unexpanded{\jlreq@hook@beforeheadings{#1}}%
          \unexpanded{\jlreq@RuninHeading@start{#1}{#2}}{\ifjlreq@number\else -\fi}{\expandonce{\jlreq@label@format}}{\expandonce{\jlreq@format@wlabel}}{\expandonce{\jlreq@format@wolabel}}%
        }%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}
\newcommand*{\NewRuninHeading}[3]{%
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareRuninHeading{#1}{#2}{#3}}%
}
\newcommand*{\RenewRuninHeading}[3]{%
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareRuninHeading{#1}{#2}{#3}}%
}
\newcommand*{\ProvideRuninHeading}[3]{%
  \@ifundefined{#1}{\DeclareRuninHeading{#1}{#2}{#3}}{}%
}

%.. 窓見出し
\def\jlreq@CutinHeading@start#1#2#3#4#5#6#7{%
  \if@noskipsec\leavevmode\fi
  \par
  \ifnum\hangafter=1 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi{%
    \jlreq@CutinHeading@start@{#2}{#3}{#4}{#5}{#6}{#7}%
  }{%
    \ClassError{jlreq}{Can not use \expandafter\string\csname#1\endcsname\space here}{\@ehc}%
  }%
}
% 1 = 書式指定，2 = インデント, 3 = 見出しと本文の間, 4 = これを越えたら二行以上，5 = これを越えたら三行以上，6 = テキスト
\def\jlreq@CutinHeading@start@#1#2#3#4#5#6{%
  % 一行で処理したときの見出し長さを計測
  \begingroup
    \setbox\@tempboxa=\hbox{#1#6}%
    \@tempdima=\wd\@tempboxa
    % 何行必要かを\jlreq@CutinHeading@linecountに入れる
    \ifdim\@tempdima>#5\def\jlreq@CutinHeading@linecount{3}%
    \else\ifdim\@tempdima>#4\def\jlreq@CutinHeading@linecount{2}%
    \else\def\jlreq@CutinHeading@linecount{1}\fi\fi
    % \@tempdimaが実際の一行の長さに近い
    \divide\@tempdima by \jlreq@CutinHeading@linecount
    % \jlreq@resultboxに見出し部分を，\jlreq@CutinHeading@linecountに見出し自身に何行使うかを入れる
    \ifnum\jlreq@CutinHeading@linecount=1\relax
      \setbox\jlreq@resultbox=\vbox{\parindent=0pt\rightskip=0pt\leftskip=0pt\hbox{#1#6}}%
      \def\jlreq@CutinHeading@linecount{2}%
    \else
      \jlreq@inlinenote@determinelength{#6}{#1}{}{\jlreq@CutinHeading@linecount}{\jlreq@CutinHeading@linecount}{\@tempdima}{\linewidth}%
      \def\jlreq@CutinHeading@linecount{3}%
    \fi
    % 普通の一行の高さ/深さに合わせて見出しのボックスを作る
    \setbox\@tempboxa=\vtop to \dimexpr\numexpr\jlreq@CutinHeading@linecount - 1\relax\baselineskip + 1\zh\relax{\vskip 0pt plus 1fill minus 1fill \box\jlreq@resultbox\vskip 0pt plus 1fill minus 1fill}%
    % 高さを通常の一行のそれにする
    \setbox\jlreq@tempboxa=\hbox{阿}%
    \dp\@tempboxa=\dimexpr\ht\@tempboxa + \dp\@tempboxa - \ht\jlreq@tempboxa\relax
    \ht\@tempboxa=\ht\jlreq@tempboxa
    \noindent
    \hspace*{#2}%
    \copy\@tempboxa
    \hspace*{#3}%
    % でかい見出しボックスの分をキャンセルする空きを入れる
    % \baselineskip - \ht\jlreq@tempboxaはTeXが挿入するスキップの分
    \edef\jlreq@do{%
      \noexpand\par
      \noexpand\vskip -\the\dimexpr\ht\@tempboxa + \dp\@tempboxa + \baselineskip - \ht\jlreq@tempboxa\relax\relax
      \noexpand\hangindent=\the\dimexpr#2 + \wd\@tempboxa + #3\relax\relax
      \noexpand\hangafter=-\jlreq@CutinHeading@linecount\relax
    }%
  \expandafter\endgroup
  \jlreq@do
  \prevdepth=0pt
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

\newcommand*{\DeclareCutinHeading}[3]{%
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\def\csname jlreq@heading@setting@#1\endcsname{#3}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewCutinHeading}%
  \begingroup
    \def\jlreq@fontcommand{\sffamily\bfseries}%
    \def\jlreq@onelinemax{6\zw}%
    \def\jlreq@twolinemax{20\zw}%
    \def\jlreq@indent{0\zw}%
    \def\jlreq@after@space{1\zw}%
    \jlreq@parsekeyval[CutinHeading:#1]{
      {font}{\def\jlreq@fontcommand{##1}}
      {onelinemax}{\def\jlreq@onelinemax{##1}}
      {twolinemax}{\def\jlreq@twolinemax{##1}}
      {indent}{\def\jlreq@indent{##1}}
      {after_space}{\def\jlreq@after@space{##1}}
    }{#3}%
    \ifthenelse{\lengthtest{\jlreq@after@space < 0.99\zw} \OR \lengthtest{\jlreq@after@space > 2.01\zw}}{%
      \jlreq@note{窓見出しと本文との空き量は，基本版面の文字サイズの全角以上，2倍未満とする (4.1.10.c)．}%
    }{}%
    \edef\jlreq@do{%
      \noexpand\def\expandonce{\csname #1\endcsname}{%
        \noexpand\jlreq@CutinHeading@start{#1}{\expandonce{\jlreq@fontcommand}}{\expandonce{\jlreq@indent}}{\expandonce{\jlreq@after@space}}{\expandonce{\jlreq@onelinemax}}{\expandonce{\jlreq@twolinemax}}%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}
\newcommand*{\NewCutinHeading}[3]{%
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareCutinHeading{#1}{#2}{#3}}%
}
\newcommand*{\RenewCutinHeading}[3]{%
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareCutinHeading{#1}{#2}{#3}}%
}
\newcommand*{\ProvideCutinHeading}[3]{%
  \@ifundefined{#1}{\DeclareCutinHeading{#1}{#2}{#3}}{}%
}

\newcommand{\ModifyHeading}[2]{%
  \@ifundefined{jlreq@heading@setting@#1}{\ClassError{jlreq}{Unknown heading: #1}{\@ehc}}{}%
  \edef\jlreq@do{\csexpandonce{jlreq@heading@type@#1}{#1}{\csexpandonce{jlreq@heading@level@#1}}{\csexpandonce{jlreq@heading@setting@#1},\unexpanded{#2}}}%
  \jlreq@do
}
% 見出し#1をマクロ#2に保存する
\newcommand{\SaveHeading}[2]{%
  \@ifundefined{jlreq@heading@setting@#1}{\ClassError{jlreq}{Unknown heading: #1}{\@ehc}}{}%
  \edef#2{%
    \csexpandonce{jlreq@heading@type@#1}{\unexpanded{#1}}{\csexpandonce{jlreq@heading@level@#1}}{\csexpandonce{jlreq@heading@setting@#1}}%
  }%
}

\newcommand*{\jlreq@keepbaselineskip}[1]{%
  \begingroup
    \edef\jlreq@do{\unexpanded{#1}\noexpand\baselineskip=\the\baselineskip}%
  \expandafter\endgroup
  \jlreq@do
}

\newcommand*{\jlreq@HeadingType}[1]{%
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
\newcommand*{\jlreq@HeadingType@}[2]{%
  \expandafter\expandafter\expandafter\ifx\csname jlreq@heading@type@#1\endcsname#2\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi
}

% 全ての見出しにマクロ#1を適用する．
\def\jlreq@heading@execmacro@toallheadings#1{%
  \begingroup
    \def\jlreq@do{}%
    \ifx\jlreq@heading@allheadings\@undefined
      \jlreq@heading@execmacro@toallheadings@{#1}{chapter,part,section,subsection,subsubsection,paragraph,subparagraph}%
    \else
      \def\@tempa{\jlreq@heading@execmacro@toallheadings@{#1}}%
      \expandafter\@tempa\expandafter{\jlreq@heading@allheadings}%
    \fi
  \expandafter\endgroup
  \jlreq@do
}

\def\jlreq@heading@execmacro@toallheadings@#1#2{
  \@for\jlreq@tempa:=#2\do{%
    \@ifundefined{\jlreq@tempa}{}{%
      \eappto\jlreq@do{\noexpand#1{\expandonce{\jlreq@tempa}}}%
    }%
  }%
}
\def\jlreq@clearheadingmarks#1{%
  \@ifundefined{#1mark}{}{%
    \expandafter\let\csname#1mark\endcsname=\@gobble
  }%
}

%.. カウンターの定義（見出し本体はこのファイルの末尾で）
\setcounter{secnumdepth}{3}
\newcounter{part}
\jlreq@switch{\jlreq@article@type}{
  {article}{\newcounter{section}}
  {\newcounter{chapter}\newcounter{section}[chapter]}% book, report
}
\newcounter{subsection}[section]
\newcounter{subsubsection}[subsection]
\newcounter{paragraph}[subsubsection]
\newcounter{subparagraph}[paragraph]
\renewcommand*{\@seccntformat}[1]{\csname the#1\endcsname}


%. 注
% 文字サイズは6ポイントくらい（4.2.3.a）とりあえす\scriptsize
%.. 合印（4.2.3）
\newcommand*\jlreq@referencemark@format[1]{#1}
\newif\ifjlreqadjustreferencemark
\jlreqadjustreferencemarktrue
\jlreq@jlreqsetup@add{reference_mark}[inline,interlinear]{
  \def\jlreq@referencemark{#1}
  \ifthenelse{\equal{\jlreq@referencemark}{inline}}{
    \def\jlreq@notemark##1{%
      \jlreq@ifydir{%
        \hbox{}\hbox{\@textsuperscript{\normalfont\jlreq@referencemark@format{##1}}}\hbox{}%
      }{%
        \setbox\@tempboxa=\hbox{\scriptsize\jlreq@referencemark@format{##1}}%
        \raise\dimexpr.5\jlreq@gol - \ht\@tempboxa\relax\box\@tempboxa
      }%
    }
    \def\jlreq@hook@prenote{\inhibitglue}
    \def\jlreq@hook@postnote{\inhibitglue}
  }{% reference_mark=interlinear
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
        \ifnum\jlreq@lastnodechar>-1 \inhibitglue\fi
      }
    \else
      % (u)platexの時は代入すると\inhibitglueが効かなくなる
      \def\jlreq@hook@prenote{%
        \ifnum\lastnodechar>-1 \inhibitglue\fi
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
      \noexpand\kern\the\dimexpr 1.5\dimexpr\baselineskip - 1\zh\relax\relax
    }
  }
\expandafter\endgroup
\jlreq@do

% インデントの計算：脚注の長さが文字の整数倍になるように字下げする（4.2.5.b）
\jlreq@jlreqsetup@add{footnote_indent}{%
  \if@tate\else
    \ifdim\dimexpr#1\relax=0pt \else\jlreq@note{脚注は，一般にその前に区切りのための罫線を挿入するので，字下げは行わなくてよい（4.2.5.b）．}\fi
  \fi
  \begingroup
    \footnotesize
    \jlreq@footnoteindent=\dimexpr#1\relax
    \@tempdima=\dimexpr\textwidth - \jlreq@footnoteindent\relax
    \@tempdimb=1\zw
    \divide\@tempdima\@tempdimb \multiply\@tempdima\@tempdimb
    \edef\jlreq@do{\noexpand\jlreq@footnoteindent=\the\dimexpr\textwidth - \@tempdima\relax}%
  \expandafter\endgroup
  \jlreq@do
}

\newcommand{\@makefntext}[1]{\jlreq@makefntext{#1}}
\jlreq@jlreqsetup@add{footnote_second_indent}{%
  \if@tate\else
    \ifthenelse{
      \( \lengthtest{0.99\zw < \dimexpr #1\relax} \AND \lengthtest{\dimexpr #1\relax < 1.01\zw} \) \OR 
      \( \lengthtest{-1.01\zw < \dimexpr #1\relax} \AND \lengthtest{\dimexpr #1\relax < -0.99\zw} \)
    }{}{\jlreq@note{脚注が2行以上となった場合，脚注の2行目以下の字下げを1行目より，脚注の文字サイズの全角アキとするか，逆に，1行目の字下げを2行目より，脚注の文字サイズの全角アキとする (4.2.5.d)．}}
  \fi
  \ifdim\dimexpr #1\relax<0pt
    \def\jlreq@makefntext{}
  \else
    \def\jlreq@makefntext{\addtolength{\leftskip}{\glueexpr #1\relax}}
  \fi
  \long\edef\jlreq@makefntext##1{\expandonce{\jlreq@makefntext}%
    \unexpanded{%
      \addtolength{\leftskip}{\jlreq@footnoteindent}%
      \parindent=1\zw
      \noindent
      \hskip-\glueexpr #1\relax
      \jlreq@referencemark@format{\@thefnmark}%
      \hskip\glueexpr 1\zw\relax
    }##1%
  }
}

\jlreq@jlreqsetup@add{footnotetext_indent}{
  \ClassWarningNoLine{jlreq}{footnotetext_indent was removed}
}

\ifx l\jlreq@engine
  \fnfixbottomtrue
\fi

% \footnoteと\footnotemarkの前後に\jlreq@hook@prenote/\jlreq@hook@postnoteを入れる
\jlreq@saveoriginalcs{\footnote}
\jlreq@saveoriginalcs{\footnotemark}
\def\footnote{%
  \jlreq@hook@prenote
  \@ifnextchar[{\jlreq@footnote@impl@woption}{\jlreq@footnote@impl@wooption}%
}
\def\footnotemark{%
  \jlreq@hook@prenote
  \@ifnextchar[{\jlreq@footnotemark@impl@woption}{\jlreq@footnotemark@impl@wooption}%
}
\ifthenelse{\boolean{@tate} \AND \(\boolean{@twoside} \OR \boolean{@twocolumn}\)}{
  % 縦組の傍注は，その見開き内に付いている合印に対応する注を，奇数ページの左端にそろえて配置する．多段組では最下段の左端にそろえて配置する．（4.2.6.a）
  % 必要ならば\footnoteを\footnotemarkと\footnotetextにわけ，\footnotetextをアウトプット時まで遅延することで実現する．
  \def\jlreq@footnote@delayfootnoteslist{}
  \def\jlreq@hook@@opcol{%
    \expandafter\gdef\expandafter\jlreq@footnote@delayfootnoteslist\expandafter{\expandafter}%
    \jlreq@footnote@delayfootnoteslist
  }
  \preto\@opcol{\jlreq@hook@@opcol}
  % \jlreq@footnote@delayfootnote@delay#1#2#3：#1ページ目に\footnotetext[#2]{#3}を出す
  % \jlreq@footnote@delayfootnote@page：何ページ目に\footnotetextを入れるかを\jlreq@resultcntに入れる．その場での場合は-1．
  \if@twocolumn
    \if@twoside
      \def\jlreq@footnote@delayfootnote@page{%
        \jlreq@setcurrentpage
        \jlreq@resultcnt=\numexpr\jlreq@currentpage\ifodd\jlreq@currentpage\else + 1\fi\relax
        % このページに表示＆上の段処理済みだと\output内では間に合わない
        \ifnum\jlreq@resultcnt=\value{page}\if@firstcolumn\else\jlreq@resultcnt=-1 \fi\fi
      }
    \else
      \def\jlreq@footnote@delayfootnote@page{%
        \jlreq@setcurrentpage
        \jlreq@resultcnt=\numexpr\jlreq@currentpage\relax
        \ifnum\jlreq@resultcnt=\value{page}\if@firstcolumn\else\jlreq@resultcnt=-1 \fi\fi
      }
    \fi
    \long\def\jlreq@footnote@delayfootnote@delay#1#2#3{%
      % 二段組みの場合は上段を組んだ直後に\footnotetextを挿入（そのページの下段に入る）
      \ifnum 0\if@firstcolumn\else 1\fi\ifnum#1>\value{page}1\fi>0
        \xappto\jlreq@footnote@delayfootnoteslist{\unexpanded{\jlreq@footnote@delayfootnote{#1}{#2}{#3}}}%
      \else
        \footnotetext[#2]{#3}%
      \fi
    }
  \else
    \def\jlreq@footnote@delayfootnote@page{%
      \jlreq@setcurrentpage
      \ifodd\jlreq@currentpage
        \jlreq@resultcnt=-1
      \else
        \jlreq@resultcnt=\numexpr\jlreq@currentpage+1\relax
      \fi
    }
    \long\def\jlreq@footnote@delayfootnote@delay#1#2#3{%
      % 一段組の場合はその前のページを組んだ直後に\footnotetextを挿入．
      \ifnum\numexpr#1 - 1\relax>\value{page}%
        \xappto\jlreq@footnote@delayfootnoteslist{\unexpanded{\jlreq@footnote@delayfootnote{#1}{#2}{#3}}}%
      \else
        \footnotetext[#2]{#3}%
      \fi
    }
  \fi
  \def\jlreq@footnote@delayfootnote@immediate#1#2#3{%
    \ifnum #1<\jlreq@currentpage
      \xappto\jlreq@footnote@delayfootnoteslist{\unexpanded{\jlreq@footnote@delayfootnote{#1}{#2}{#3}}}%
    \else
      \footnotetext[#2]{#3}%
    \fi
  }
  \let\jlreq@footnote@delayfootnote=\jlreq@footnote@delayfootnote@delay
  \def\jlreq@footnote@flushdelayfootnoteslist{%
    \ifx\jlreq@footnote@delayfootnoteslist\@empty\else
      \let\jlreq@footnote@delayfootnote=\jlreq@footnote@delayfootnote@immediate
      \jlreq@setcurrentpage
      \expandafter\gdef\expandafter\jlreq@footnote@delayfootnoteslist\expandafter{\expandafter}%
      \jlreq@footnote@delayfootnoteslist
      \let\jlreq@footnote@delayfootnote=\jlreq@footnote@delayfootnote@delay
    \fi
  }
  \AtEndDocument{\jlreq@footnote@flushdelayfootnoteslist}
  \preto\newpage{\jlreq@footnote@flushdelayfootnoteslist}
  \long\def\jlreq@footnote@impl@woption[#1]#2{%
    \jlreq@footnote@delayfootnote@page
    \ifnum\jlreq@resultcnt=-1
      \jlreq@useoriginalcs{\footnote}[#1]{#2}%
    \else
      \jlreq@useoriginalcs{\footnotemark}[#1]%
      \xappto\jlreq@footnote@delayfootnoteslist{\noexpand\jlreq@footnote@delayfootnote{\the\jlreq@resultcnt}{\unexpanded{#1}}{\unexpanded{#2}}}%
    \fi
    \jlreq@hook@postnote
  }
  \long\def\jlreq@footnote@impl@wooption#1{%
    \jlreq@footnote@delayfootnote@page
    \ifnum\jlreq@resultcnt=-1
      \jlreq@useoriginalcs{\footnote}{#1}%
    \else
      \jlreq@useoriginalcs{\footnotemark}%
      \xappto\jlreq@footnote@delayfootnoteslist{\noexpand\jlreq@footnote@delayfootnote{\the\jlreq@resultcnt}{\the\value{footnote}}{\unexpanded{#1}}}%
    \fi
    \jlreq@hook@postnote
  }
}{
  \long\def\jlreq@footnote@impl@woption[#1]#2{%
    \jlreq@useoriginalcs{\footnote}[#1]{#2}%
    \jlreq@hook@postnote
  }
  \long\def\jlreq@footnote@impl@wooption#1{%
    \jlreq@useoriginalcs{\footnote}{#1}%
    \jlreq@hook@postnote
  }
}
\long\def\jlreq@footnotemark@impl@woption[#1]{%
  \jlreq@useoriginalcs{\footnotemark}[#1]%
  \jlreq@hook@postnote
}
\long\def\jlreq@footnotemark@impl@wooption{%
  \jlreq@useoriginalcs{\footnotemark}%
  \jlreq@hook@postnote
}

% 合印
\renewcommand*{\@makefnmark}{%
  \jlreq@ifydir{\jlreq@notemark{\@thefnmark}}{\hbox{\jlreq@notemark{\@thefnmark}}}%
}
% 4.2.2注3
\if@tate
  \renewcommand*{\thefootnote}{\jlreq@open@bracket@before@space\inhibitglue（\jlreq@rensuji{\@arabic\c@footnote}）\inhibitglue}
\else
  \renewcommand*{\thefootnote}{\arabic{footnote}\hbox{}）\inhibitglue}
\fi
\ifthenelse{\equal{\jlreq@article@type}{article}}{}{\@addtoreset{footnote}{chapter}}


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
\long\def\jlreq@endnote@addtext#1#2{\xappto\jlreq@endnote@texts{\unexpanded{{{#1}{#2}}}}}
% \endnote自身は後で定義する
\def\jlreq@endnote@impl{\jlreq@hook@prenote\@ifnextchar[{\jlreq@endnote}{\jlreq@endnote[]}}  
\def\endnotemark{\jlreq@hook@prenote\@ifnextchar[{\jlreq@endnotemark}{\jlreq@endnotemark[]}}
\def\endnotetext{\@ifnextchar[{\jlreq@endnotetext}{\jlreq@endnotetext[]}}
\long\def\jlreq@endnote[#1]#2{\jlreq@endnotemark[#1]\@endnotetext{#2}\jlreq@hook@postnote}
\def\jlreq@endnotemark[#1]{%
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
  \jlreq@hook@postnote
}
\jlreq@setdefaultnotemark\@endnotemark\@makeendmark
\long\def\jlreq@endnotetext[#1]#2{%
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
        \listparindent=1\zw
      }%
      \expandafter\jlreq@theendnotes\jlreq@tempa\jlreq@endmark
      \end{list}%
    \endgroup
    \par
  \fi
}
% 4.2.4.b
\jlreq@endnote@indent=2\jlreq@mol
\jlreq@jlreqsetup@add{endnote_second_indent}{
  \def\jlreq@endnote@second@indent{#1}
  \ifthenelse{
    \( \lengthtest{0.99\zw < #1} \AND \lengthtest{#1 < 1.01\zw} \) \OR 
    \( \lengthtest{1.99\zw < #1} \AND \lengthtest{#1 < 2.01\zw} \)
  }{}{\jlreq@note{後注が2行以上となった場合，後注の2行目以下の字下げは，1行目より，後注の文字サイズの2倍又は全角とする (4.2.4.d)．}}
}
\newcommand{\@makeendtext}[1]{%
  \csname\jlreq@endnotemarkname\endcsname
  \hskip\glueexpr1\zw\relax% 見出し出力と一文字分の空き（4.2.4.c）
  #1%
}
\let\@makeendmark=\@makefnmark

% \theendnoteの出力を仕込む
\apptocmd{\jlreq@hook@beforeheadings}{\jlreq@endnote@hook@beforeheadings{#1}}{}{}

\jlreq@jlreqsetup@add{endnote_position}{
  \def\jlreq@endnote@hook@beforeheadings##1{}
  \jlreq@tempafalse % headingsが指定された
  \jlreq@tempbfalse % paragraphが指定された
  % \jlreq@tempcにセクション名たちを入れていく
  \def\jlreq@tempc{}
  \@for\jlreq@tempa:=#1\do{
    \expandafter\jlreq@helper@trim\expandafter{\jlreq@tempa}{\jlreq@tempa}%
    \jlreq@switch{\jlreq@tempa}{
      {headings}{\jlreq@tempatrue}
      {paragraph}{
        \jlreq@tempatrue% _paragraphの時は_headingsも有効にする
        \jlreq@tempbtrue
      }
      {
        \expandafter\jlreq@iffirsttoken@ignorespaces\expandafter{\jlreq@tempa}{_}{
          \edef\jlreq@tempc{\jlreq@tempc,\expandafter\@gobble\jlreq@tempa}
        }{
          \ClassError{jlreq}{Invalid value \jlreq@tempa\space in endnote_position}{\@ehc}
        }
      }
    }
  }
  
  \ifjlreq@tempb
    \edef\endnote{\unexpanded{\def\par{\@restorepar\theendnotes\par}}\expandonce{\jlreq@endnote@impl}}
  \else
    \let\endnote=\jlreq@endnote@impl
  \fi

  \ifjlreq@tempa
    \apptocmd{\jlreq@endnote@hook@beforeheadings}{\theendnotes}{}{}
  \else
    \@for\@tempa:=\jlreq@tempc\do{
      \ifx\@tempa\@empty\else
        \edef\jlreq@do{%
          \unexpanded{\def\jlreq@endnote@hook@beforeheadings##1}{\expandonce{\jlreq@endnote@hook@beforeheadings{##1}}%
            \unexpanded{\def\@tempa}{\@tempa}\unexpanded{\def\@tempb{##1}}%
            \unexpanded{\ifx\@tempa\@tempb\theendnotes\fi}%
          }
        }
        \jlreq@do
      \fi
    }
  \fi
}
\AtEndDocument{\theendnotes}


% (1) \footnoteとかと同じ形式 sidenote_type=number
% (2) 文中にマークを入れて，傍注には見出しが入る sidenote_type=symbol
% (3) 文中は強調文字列，傍注には見出しが入る sidenote_type=symbol
% (4) 文中は何も無し，傍注には見出しが入る sidenote_type=symbol

% (1) では\sidenote[]{}を定義
% (2) では\sidenote{見出し}{注中身}を定義
% \marginparwidth>0ptの時のみ定義する
\ifdim\marginparwidth>0pt \expandafter\@firstofone\else\expandafter\@gobble\fi
{
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
  \jlreq@jlreqsetup@add{sidenote_type}[number,symbol]{\def\jlreq@sidenote@type{#1}}
  \def\jlreq@sidenote@type{number}
  \jlreq@jlreqsetup@addtofinally{
    \ifthenelse{\equal{\jlreq@sidenote@type}{number}}{
      \def\sidenote{\jlreq@hook@prenote\@ifnextchar[{\jlreq@sidenote}{\jlreq@sidenote[]}}
      \def\sidenotemark{\jlreq@hook@prenote\@ifnextchar[{\jlreq@sidenotemark}{\jlreq@sidenotemark[]}}
      \def\sidenotetext{\@ifnextchar[{\jlreq@sidenotetext}{\jlreq@sidenotetext[]}}
      \long\def\jlreq@sidenote[#1]#2{\jlreq@sidenotemark[#1]\@sidenotetext{#2}\jlreq@hook@postnote}
      \def\jlreq@sidenotemark[#1]{%
        \jlreq@ifempty{#1}{%
          \stepcounter{\jlreq@sidenotecounter}%
          \expandafter\protected@xdef\csname\jlreq@sidenotemarkname\endcsname{\csname the\jlreq@sidenotecounter\endcsname}%
        }{%
          \begingroup
            \csname c@\jlreq@sidenotecounter\endcsname #1\relax
            \expandafter\unrestored@protected@xdef\csname\jlreq@sidenotemarkname\endcsname{\csname the\jlreq@sidenotecounter\endcsname}%
          \endgroup
        }%
        \@sidenotemark
        \jlreq@hook@postnote
      }
      \long\def\jlreq@sidenotetext[#1]#2{%
        \jlreq@ifempty{#1}{%
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
        \long\def\@makesidetext#1{　\kern-1\zw\csname\jlreq@sidenotemarkname\endcsname\hspace{0.5\jlreq@mol}#1}
      \fi
      \let\@makesidemark=\@makefnmark
    }{% sidenote_type = symbol
      \long\def\sidenote#1#2{\jlreq@sidenote{#1}{#2}}
      \def\sidenotemark#1{\jlreq@sidenotemark{#1}}
      \long\def\sidenotetext#1#2{\jlreq@sidenotetext{#1}{#2}}
      \long\def\jlreq@sidenote#1#2{\jlreq@sidenotemark{#1}\jlreq@sidenotetext{#1}{#2}}
      \edef\jlreq@sidenotemark#1{%
        {\unexpanded{\reset@font\jlreq@sidenote@keywordfont}#1}%
        \noexpand\jlreq@hook@prenote
        \ifx\jlreq@sidenote@defaultmark\@empty\else
          \expandafter\edef\expandonce{\csname\jlreq@sidenotemarkname\endcsname}{\expandonce{\jlreq@sidenote@defaultmark}}%
          \noexpand\@sidenotemark
        \fi
      }
      % カスタマイズできるべき？
      \long\def\jlreq@sidenotetext#1#2{%
        \expandafter\def\csname\jlreq@sidenotemarkname\endcsname{\inhibitglue\null{\reset@font\sffamily\bfseries\inhibitglue #1}}%
        \@sidenotetext{#2}%
      }
      \long\def\@makesidetext#1{{\sffamily\bfseries\csname\jlreq@sidenotemarkname\endcsname}\hspace*{1\jlreq@mol}#1}
      \let\@makesidemark=\@makefnmark

      \apptocmd{\sidenote}{\jlreq@hook@postnote}{}{}
      \apptocmd{\sidenotemark}{\jlreq@hook@postnote}{}{}
    }
  }
  \jlreq@jlreqsetup@add{sidenote_symbol}{\def\jlreq@sidenote@defaultmark{#1}}
  \jlreq@jlreqsetup@add{sidenote_keyword_font}{\def\jlreq@sidenote@keywordfont{#1}}
}

%.. 割注（3.4）
\def\inlinenotesize{.6\jlreq@jafontsize} % 割注の文字サイズ
\let\jlreq@inlinenote@autolinebreak=\\% 計測時は\linebreakより\\の方が安定する．悩ましい……．

\newcommand{\jlreq@inlinenote@kakkofontsize}{%
  \fontsize{\dimexpr\inlinenotesize * 2\relax}{\dimexpr \inlinenotesize * 2\relax}%
  \selectfont
}

\newcommand{\jlreq@inlinenote@fontsize}{%
  \fontsize{\inlinenotesize}{\inlinenotesize}%
  \selectfont
}

% 割注を入れるための命令．\inlinenote{割注}で使う．
% 改行位置は自動で計算されるが，常に正しいとは限らない．
% \inlinenote*は自動で改行されない．\\で改行位置を指定する．
\newif\ifjlreq@in@inlinenote
\jlreq@in@inlinenotefalse
\newcommand*{\jlreq@inlinenote@}[1]{%
  \ifjlreq@in@inlinenote\ClassError{jlreq}{\string#1\space can't be nested}{\@ehc}\fi
  \jlreq@in@inlinenotetrue
  \ifvmode\leavevmode\fi
  \@ifstar\jlreq@inlinenote@noauto\jlreq@inlinenote@auto
}
\DeclareRobustCommand*{\inlinenote}{\jlreq@inlinenote@{\inlinenote}}
\DeclareRobustCommand*{\warichu}{\jlreq@inlinenote@{\warichu}}

\newcommand*{\jlreq@inlinenote@auto}[1]{%
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
    \edef\jlreq@parshapearg{0pt \the\jlreq@tempdimb\space 0pt \the\jlreq@tempdimb}%
    \@tempcnta=4\relax
    \@whilenum\@tempcnta<\@tempcntb\do{%
      \edef\jlreq@parshapearg{\jlreq@parshapearg\space 0pt \the\linewidth\space 0pt \the\linewidth}%
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
    \edef\jlreq@parshapearg{\jlreq@parshapearg 0pt \the\jlreq@tempdimb 0pt \the\jlreq@tempdimb}%
  }%
  \ifvoid\jlreq@resultbox
    \ClassWarning{jlreq}{\string\warichu\space failed, may be a bug}%
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
      \ifnum\@tempcnta>0 \jlreq@inlinenote@autolinebreak\fi
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

\newcommand*{\jlreq@inlinenote@noauto}[1]{%
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

\newcommand{\jlreq@inlinenote@endnote}{%
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
\newcommand{\jlreq@inlinenote@determinelength}[7]{%
  \begingroup
  %  \message{#1 の試行開始，行数 = #5, \the\dimexpr#6\relax から \the\dimexpr#7\relaxまで}%
    \@tempcnta=1\relax
    \def\@tempa{}%
    % 調整に使う行の\parshape指定を\@tempaに入れる．長さは\jlreq@tempdima．
    \@whilenum\@tempcnta<#4\do{%
      \expandafter\def\expandafter\@tempa\expandafter{\@tempa 0pt \the\jlreq@tempdima}%
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
          \parshape #5 #3 \@tempa 0pt \the\maxdimen
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
\ifthenelse{\lengthtest{\@tempdima=0pt} \OR \(\lengthtest{0.99\zw < \@tempdima} \AND \lengthtest{\@tempdima < 1.01\zw}\)}{}{
  \jlreq@note{ノンブルまたは柱は，基本版面の左右にそろえるか，全角アキだけ寄せた位置に配置する (2.6.1.b)．}
}

%.. 場所指定解析
% bottom-leftみたいなのを解釈する．入力の順番はどっちでも良いが，出力は<top/bottom><left/right>の順番
% #1 = bottom-leftみたいなのを{bottom}{left}に変換し，#2に代入，#3はデフォルト値，出力形式で入れる
\newcommand*{\jlreq@pagestyle@parse@position}[3]{%
  \jlreq@ifempty{#1}{\def#2{#3}}%
  {%
    \begingroup
      \jlreq@pagestyle@parse@position@#1-\jlreq@endmark
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
    \ifx\jlreq@tempb\@empty\ClassError{jlreq}{Invalid position: #1}{\@ehc}\fi
  }{%
    \def\@tempa##1-{\def\jlreq@tempb{##1}}%
    \@tempa#2\relax
  }%
}

\newcommand*\jlreq@pagestyle@parse@position@@[1]{%
  \jlreq@switch{#1}{
    {top}{\def\jlreq@tempc{#1}}
    {bottom}{\def\jlreq@tempc{#1}}
    {left}{\def\jlreq@tempd{#1}}
    {right}{\def\jlreq@tempd{#1}}
    {center}{\def\jlreq@tempd{#1}}
    {gutter}{\if@tate\def\jlreq@tempd{right}\else\def\jlreq@tempd{left}\fi}
    {fore_edge}{\if@tate\def\jlreq@tempd{left}\else\def\jlreq@tempd{right}\fi}
    {fore-edge}{\if@tate\def\jlreq@tempd{left}\else\def\jlreq@tempd{right}\fi}
    {\ClassError{jlreq}{Invalid position: #1}{\@ehc}}
  }%
}

% レベル#1より低いレベルの見出しの**markを\markboth{}{}にする
\def\jlreq@pagestyle@setclearmark#1{%
  \@for\@tempa:=\jlreq@heading@allheadings\do{%
    \@ifundefined{\@tempa}{}{%
      \@ifundefined{jlreq@heading@level@\@tempa}{}{%
        \ifnum\csname jlreq@heading@level@\@tempa\endcsname<#1\relax\expandafter\def\csname\@tempa mark\endcsname##1{\markboth{}{}}\fi
      }%
    }%
  }%
}

% #1のleftとrightを入れ替えて#1に代入
\def\jlreq@reverse@leftright#1{%
  \jlreq@switch{#1}{
    {left}{\def#1{right}}
    {right}{\def#1{left}}
  }%
}

%.. マークの拡張
% 三つ以上のマークを保持するために，markを次のようにする
% <マーク1>\jlreq@extramark{{<マーク2>}{<マーク3>}...}
\def\jlreq@extramark#1{}

% #1番目の\leftmarkや\rightmarkを取得する．\leftmark/\rightmarkの実装に強く依存している．
\def\jlreq@extraleftmark#1{\jlreq@getextramark{#1}{\leftmark}}%
\def\jlreq@extrarightmark#1{\jlreq@getextramark{#1}{\rightmark}}%
\def\jlreq@getextramark#1#2{\expandafter\expandafter\expandafter\expandafter\expandafter\expandafter\expandafter\jlreq@getextramark@#2\jlreq@extramark\jlreq@endmark{#1}}
\def\jlreq@getextramark@#1\jlreq@extramark#2\jlreq@endmark#3{%
  \jlreq@ifempty{#2}{}{\jlreq@getextramark@@{#3}#2}%
}
\def\jlreq@getextramark@@#1#2#3\jlreq@extramark{\jlreq@getextramark@@@{#1}#2\jlreq@endmark}
\def\jlreq@getextramark@@@#1#2{%
  \jlreq@ifendmark{#2}{}{%
    \ifnum#1=1 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi
      {\jlreq@getextramark@@@@{#2}}{\expandafter\jlreq@getextramark@@@\expandafter{\the\numexpr #1-1\relax}}%
  }%
}
\def\jlreq@getextramark@@@@#1#2\jlreq@endmark{#1}

% トークン列#1に必要ならば\jlre@extramarkを加え，#2に代入
\def\jlreq@addextramarkcommand#1#2{%
  \jlreq@ifcontains{#1}{\jlreq@extramark}{\edef#2{\unexpanded{#1}}}{\edef#2{\unexpanded{#1\jlreq@extramark{}}}}%
}
\def\jlreq@addextramarkcommand@tothemark{%
  \begingroup
    \expandafter\expandafter\expandafter\jlreq@addextramarkcommand\expandafter\expandafter\expandafter{\expandafter\@firstoftwo\@themark}{\jlreq@tempa}%
    \expandafter\expandafter\expandafter\jlreq@addextramarkcommand\expandafter\expandafter\expandafter{\expandafter\@secondoftwo\@themark}{\jlreq@tempb}%
    \edef\jlreq@do{\unexpanded{\def\@themark}{{\expandonce{\jlreq@tempa}}{\expandonce{\jlreq@tempb}}}}%
  \expandafter\endgroup
  \jlreq@do
}

% #1番目を#2に置き換える
\def\jlreq@setextraleftmark#1#2{%
  \let\jlreq@extramark@=\jlreq@extramark
  \begingroup
    \jlreq@addextramarkcommand@tothemark
    \def\jlreq@extramark##1{\noexpand\jlreq@extramark{\jlreq@changeargument{##1}{#1}{#2}}}%
    \protected@edef\jlreq@tempa{\expandafter\@firstoftwo\@themark}%
    \def\jlreq@extramark{\noexpand\jlreq@extramark}%
    \protected@edef\jlreq@tempb{\expandafter\@secondoftwo\@themark}%
    \edef\@themark{{\expandonce{\jlreq@tempa}}{\expandonce{\jlreq@tempb}}}%
    \edef\jlreq@do{%
      \unexpanded{\def\jlreq@extramark{\noexpand\jlreq@extramark}}%
      \noexpand\markboth\expandonce{\@themark}%
    }%
  \expandafter\endgroup
  \jlreq@do
  \let\jlreq@extramark=\jlreq@extramark@
}
\def\jlreq@setextrarightmark#1#2{%
  \let\jlreq@extramark@=\jlreq@extramark
  \begingroup
    \jlreq@addextramarkcommand@tothemark
    \def\jlreq@extramark{\noexpand\jlreq@extramark}%
    \protected@edef\jlreq@tempa{\expandafter\@firstoftwo\@themark}%
    \def\jlreq@extramark##1{\noexpand\jlreq@extramark{\jlreq@changeargument{##1}{#1}{#2}}}%
    \protected@edef\jlreq@tempb{\expandafter\@secondoftwo\@themark}%
    \edef\@themark{{\expandonce{\jlreq@tempa}}{\expandonce{\jlreq@tempb}}}%
    \edef\jlreq@do{%
      \unexpanded{\def\jlreq@extramark{\noexpand\jlreq@extramark}}%
      \noexpand\markright{\expandonce{\jlreq@tempb}}%
    }%
  \expandafter\endgroup
  \jlreq@do
  \let\jlreq@extramark=\jlreq@extramark@
}

% #1内の#2番目を#3に取り替える．\jlreq@changeargument{{arg1}{arg2}...{argk}}{n}{arg}
% k < nならば{}を加えた後{arg}を最後につける
\def\jlreq@changeargument#1#2#3{%
  \jlreq@changeargument@{#2}{#3}#1\jlreq@endmark
}
\def\jlreq@changeargument@#1#2#3{%
  \jlreq@ifendmark{#3}{%
    \ifnum#1>0 \expandafter\@firstofone\else\expandafter\@gobble\fi
      {\jlreq@changeargument@@{#1}{#2}}%
  }{%
    \ifnum#1=1 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi
      {{#2}}{{#3}}%
    \expandafter\jlreq@changeargument@\expandafter{\the\numexpr #1 - 1\relax}{#2}%
  }%
}
\def\jlreq@changeargument@@#1#2{%
  \ifnum#1<2 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi{{#2}}{%
    {}\expandafter\jlreq@changeargument@@\expandafter{\the\numexpr #1 -1 \relax}{#2}%
  }%
}

% \jlreq@cleararguments{k}{{arg1}...{argn}}を{arg1}...{argk}{}...{}にする
\def\jlreq@cleararguments#1#2{\jlreq@cleararguments@{#1}#2\jlreq@endmark}
\def\jlreq@cleararguments@#1#2{\jlreq@ifendmark{#2}{}{%
  \ifnum#1<1 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi
    {{}}{{#2}}%
    \expandafter\jlreq@cleararguments@\expandafter{\the\numexpr #1 - 1\relax}%
  }%
}
% ...\jlreq@extramark{...}を\jlreq@extramark{...}のみにする．
\def\jlreq@getextramarkpart#1{\jlreq@getextramarkpart@#1\jlreq@extramark\jlreq@endmark}
\def\jlreq@getextramarkpart@#1\jlreq@extramark#2\jlreq@endmark{\jlreq@ifempty{#2}{}{\jlreq@getextramarkpart@@#2}}
\def\jlreq@getextramarkpart@@#1\jlreq@extramark{\jlreq@extramark{#1}}

% #1番目以降を空にする
\def\jlreq@clearleftextramarks#1{%
  \let\jlreq@extramark@=\jlreq@extramark
  \begingroup
    \def\jlreq@extramark##1{\noexpand\jlreq@extramark{\jlreq@cleararguments{#1}{##1}}}%
    \protected@edef\jlreq@tempa{\expandafter\@firstoftwo\@themark}%
    \edef\jlreq@tempb{\expandafter\expandafter\expandafter\expandonce\expandafter\expandafter\expandafter{\expandafter\@secondoftwo\@themark}}%
    \edef\jlreq@do{%
      \unexpanded{\def\jlreq@extramark{\noexpand\jlreq@extramark}}%
      \noexpand\markboth{\expandonce{\jlreq@tempa}}{\expandonce{\jlreq@tempb}}%
    }%
  \expandafter\endgroup
  \jlreq@do
  \let\jlreq@extramark=\jlreq@extramark@
}
\def\jlreq@clearrightextramarks#1{%
  \let\jlreq@extramark@=\jlreq@extramark
  \begingroup
    \edef\jlreq@tempa{\expandafter\expandafter\expandafter\expandonce\expandafter\expandafter\expandafter{\expandafter\@firstoftwo\@themark}}%
    \def\jlreq@extramark##1{\noexpand\jlreq@extramark{\jlreq@cleararguments{#1}{##1}}}%
    \protected@edef\jlreq@tempb{\expandafter\@secondoftwo\@themark}%
    \edef\jlreq@do{%
      \unexpanded{\def\jlreq@extramark{\noexpand\jlreq@extramark}}%
      \noexpand\markboth{\expandonce{\jlreq@tempa}}{\expandonce{\jlreq@tempb}}%
    }%
  \expandafter\endgroup
  \jlreq@do
  \let\jlreq@extramark=\jlreq@extramark@
}

\def\jlreq@markboth#1#2{%
  \let\jlreq@extramark@=\jlreq@extramark
  \def\jlreq@extramark{\noexpand\jlreq@extramark}%
  \begingroup
    \protected@edef\jlreq@tempa{\expandafter\@firstoftwo\@themark}%
    \protected@edef\jlreq@tempa{\unexpanded{#1}\expandafter\jlreq@getextramarkpart\expandafter{\jlreq@tempa}}%
    \protected@edef\jlreq@tempb{\expandafter\@secondoftwo\@themark}%
    \protected@edef\jlreq@tempb{\unexpanded{#2}\expandafter\jlreq@getextramarkpart\expandafter{\jlreq@tempb}}%
    \edef\jlreq@do{%
      \noexpand\markboth{\expandonce{\jlreq@tempa}}{\expandonce{\jlreq@tempb}}%
    }%
  \expandafter\endgroup
  \jlreq@do
  \let\jlreq@extramark=\jlreq@extramark@
}
\def\jlreq@markright#1{%
  \let\jlreq@extramark@=\jlreq@extramark
  \def\jlreq@extramark{\noexpand\jlreq@extramark}%
  \begingroup
    \protected@edef\jlreq@tempb{\expandafter\@secondoftwo\@themark}%
    \protected@edef\jlreq@tempb{\unexpanded{#1}\expandafter\jlreq@getextramarkpart\expandafter{\jlreq@tempb}}%
    \edef\jlreq@do{%
      \noexpand\markright{\expandonce{\jlreq@tempb}}%
    }%
  \expandafter\endgroup
  \jlreq@do
  \let\jlreq@extramark=\jlreq@extramark@
}

%.. \DeclarePageStyle内で使うもの
% mark情報の取得を行う．
% #1の中身をみて，#2 = 何段目見出しか，#3 = odd/even，\csname #4@<見出し命令名>\endcsnameに必要情報を追加し，#5の見出し命令名リストに追加
% #1@heading@levelにレベルを入れる
\def\jlreq@pagestyle@setmark#1#2#3#4#5{%
  \begingroup
    \expandafter\jlreq@iffirsttoken\expandafter{#1}{_}{%
      \ifthenelse{\equal{#3}{odd}}{\let\jlreq@leftright=r}{\let\jlreq@leftright=l}%
      \edef\jlreq@do{%
        \unexpanded{\def#1}{%
          \ifx l\jlreq@leftright
            \ifnum#2=0 \noexpand\leftmark\else\unexpanded{\jlreq@extraleftmark{#2}}\fi
          \else
            \ifnum#2=0 \noexpand\rightmark\else\unexpanded{\jlreq@extrarightmark{#2}}\fi
          \fi
        }%
      }%
      \edef\jlreq@headingname{\expandafter\@gobble#1}% 見出し命令名
      \edef\jlreq@tempa{\noexpand\@removeelement{\expandonce{\jlreq@headingname}}}%
      \expandafter\jlreq@tempa\expandafter{#5}{#5}%
      \@ifundefined{#4@\jlreq@headingname}{\expandafter\def\csname #4@\jlreq@headingname\endcsname{}}{}%
      \eappto\jlreq@do{%
        \noexpand\let\expandonce{\csname\expandafter\@gobble\string #1@heading@level\endcsname}=\expandonce{\csname jlreq@heading@level@\jlreq@headingname\endcsname}%
        \unexpanded{\def#5}{\expandonce{#5},\expandonce{\jlreq@headingname}}%
        \noexpand\appto\expandonce{\csname #4@\jlreq@headingname\endcsname}{{{\ifnum#2=0 #3\fi}{#2}{\ifx r\jlreq@leftright r\else l\fi}}}%
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
    \@for\jlreq@i:=0,1,2\do{%
      \expandafter\def\csname jlreq@leftmark@\jlreq@i\endcsname{}%
      \expandafter\def\csname jlreq@rightmark@\jlreq@i\endcsname{}%
    }%
    \jlreq@pagestyle@make@headingmark@{#2}{#3}#4\jlreq@endmark
    \def\jlreq@do{}% とりあえず#1markの中身を入れていく
    % leftを設定する時は対応するrightを空にする．
    \expandafter\ifx\csname jlreq@leftmark@0\endcsname\@empty
      \expandafter\ifx\csname jlreq@rightmark@0\endcsname\@empty\else
        \eappto\jlreq@do{\jlreq@ifempty{#1}{\noexpand\markright}{\noexpand\jlreq@markright}{\csexpandonce{jlreq@rightmark@0}}}%
      \fi
    \else
      \eappto\jlreq@do{\jlreq@ifempty{#1}{\noexpand\markboth}{\noexpand\jlreq@markboth}{\csexpandonce{jlreq@leftmark@0}}{\csexpandonce{jlreq@rightmark@0}}}%
    \fi
    \@for\jlreq@i:=1,2\do{%
      \expandafter\ifx\csname jlreq@leftmark@\jlreq@i\endcsname\@empty
        \expandafter\ifx\csname jlreq@rightmark@\jlreq@i\endcsname\@empty\else
          \eappto\jlreq@do{\noexpand\jlreq@setextrarightmark{\jlreq@i}{\csexpandonce{jlreq@rightmark@\jlreq@i}}}%
        \fi
      \else
        \eappto\jlreq@do{%
          \noexpand\jlreq@setextraleftmark{\jlreq@i}{\csexpandonce{jlreq@leftmark@\jlreq@i}}%
          \noexpand\jlreq@setextrarightmark{\jlreq@i}{\csexpandonce{jlreq@rightmark@\jlreq@i}}%
        }%
      \fi
    }%
    \ifx\jlreq@do\@empty\else
      \edef\jlreq@do{%
        \unexpanded{\edef\jlreq@result}{\noexpand\unexpanded{%
          \noexpand\def\expandonce{\csname #2mark\endcsname}\unexpanded{##1}{%
            \expandonce{\jlreq@do}%
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
    \expandonce{\csname the#1\endcsname}%
    \noexpand\ifx\expandonce{\csname the#1\endcsname}\unexpanded{\@empty\else\quad\fi}%
    \unexpanded{##1}%
  }%
  \jlreq@parsekeyval@nokey{%
    \jlreq@ifempty{##1}{}{\ifthenelse{\equal{##1}{#3}}{\edef\jlreq@tempb{\unexpanded{##2}}}{}}%
    \ifthenelse{\equal{##1}{_#1}}{\edef\jlreq@tempb{\unexpanded{##2}}}{}%
  }{#2}%
  \ifx l#5%
    \expandafter\edef\csname jlreq@leftmark@#4\endcsname{\expandonce{\jlreq@tempb}}%
  \else
    \expandafter\edef\csname jlreq@rightmark@#4\endcsname{\expandonce{\jlreq@tempb}}%
  \fi
  \jlreq@pagestyle@make@headingmark@{#1}{#2}%
}

% #2 #3 #4と並んだヘッダを作り#1に入れる．#1，#2，#3はコンロトールシークエンスの名前とする．
\def\jlreq@pagestyle@setheadfoot#1#2#3#4{%
  \begingroup
    \edef\jlreq@do{\noexpand\jlreq@pagestyle@setheadfoot@{\unexpanded{#1}}{\csexpandonce{#2}}{\csexpandonce{#3}}{\csexpandonce{#4}}}%
  \expandafter\endgroup
  \jlreq@do
}

% \edef内だと，#1 != 0ptならば\hskip \dimexpr#1\relaxになる
\def\jlreq@pagestyle@hskip#1{%
  \ifdim\dimexpr#1\relax=0pt \expandafter\@gobble\else\expandafter\@firstofone\fi
    {\noexpand\hskip\noexpand\dimexpr#1\noexpand\relax}%
}
\def\jlreq@pagestyle@setheadfoot@#1#2#3#4{%
  \begingroup
    % - \Cdpは端にそろえるための補正
    \jlreq@ifempty{#2}{\def\jlreq@left{}}{\edef\jlreq@left{\jlreq@pagestyle@hskip{\jlreq@expand@speciallength{\jlreq@headfoot@sidemargin}\if@tate - \Cdp\fi}\unexpanded{#2}}}%
    % +\topskip - \Chtは\jlreq@headfoot@sidemargin = 0ptの時に本文の右に一致させるための補正．
    \jlreq@ifempty{#4}{\def\jlreq@right{}}{\edef\jlreq@right{\unexpanded{#4}\jlreq@pagestyle@hskip{\jlreq@expand@speciallength{\jlreq@headfoot@sidemargin}\if@tate + \topskip - \Cht\fi}}}%
    \jlreq@ifempty{#3}{%
      \edef\jlreq@do{\unexpanded{\def#1}{\expandonce{\jlreq@left}\hfil\expandonce{\jlreq@right}}}%
      \jlreq@ifempty{#2}{\jlreq@ifempty{#4}{\def\jlreq@do{\def#1{}}}{}}{}%
    }{% #3を完全に真ん中に配置するために左右の幅を0にしておく
      \ifx\jlreq@left\@empty\else\edef\jlreq@left{\noexpand\hbox to 0pt{\expandonce{\jlreq@left}\noexpand\hss}}\fi
      \ifx\jlreq@right\@empty\else\edef\jlreq@right{\noexpand\hbox to 0pt{\noexpand\hss\expandonce{\jlreq@right}}}\fi
      \edef\jlreq@do{%
        \unexpanded{\def#1}{\expandonce{\jlreq@left}\hfil\unexpanded{#3}\hfil\expandonce{\jlreq@right}}%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}%

% #1の左右に傍注調整用の空白を入れて#1に代入する
\def\jlreq@pagestyle@addsidenotemargin@left#1{%
  \jlreq@pagestyle@addsidenotemargin@{#1}{\marginparwidth+\marginparsep}{}%
}
\def\jlreq@pagestyle@addsidenotemargin@right#1{%
  \jlreq@pagestyle@addsidenotemargin@{#1}{}{\marginparwidth+\marginparsep}%
}
\def\jlreq@pagestyle@addsidenotemargin@bothside#1{%
  \jlreq@pagestyle@addsidenotemargin@{#1}{\marginparwidth+\marginparsep}{\marginparwidth+\marginparsep}%
}
% #2: 左，#3：右，#4：#2 + #3
\def\jlreq@pagestyle@addsidenotemargin@#1#2#3{%
  \ifx#1\@empty\else
    \edef#1{%
      \jlreq@ifempty{#2}{}{\unexpanded{\hskip-\dimexpr #2\relax}}%
      \expandonce{#1}%
      \jlreq@ifempty{#3}{}{\unexpanded{\hskip-\dimexpr #3\relax}}%
    }%
  \fi
}

% #1が空かつ#4が空でないならば#2に#3と#4の中身を追加し，#4を空にする．引数は全てコントロールシークエンス
\def\jlreq@pagestyle@addifempty#1#2#3#4{%
  \ifx#1\@empty\ifx#4\@empty\else\eappto#2{\expandonce{#3}\expandonce{#4}}\def#4{}\fi\fi
}

\newif\ifjlreq@PageStyle@first
% #1に入っている{柱1}{柱2}...{柱n}という並びから，実際に出力する柱を構築する．n>=1を仮定する．
% 間に空白を入れる．
% #1: ターゲットなコントロールシークエンスの名前，#2：*ならばreverseする，#3：空き
\def\jlreq@pagestyle@make@runninghead#1#2#3{%
  \expandafter\ifx\csname #1\endcsname\@empty\expandafter\@gobble\else\expandafter\@firstofone\fi{%
    \edef\jlreq@do{%
      \noexpand\jlreq@tempatrue % 最初の処理かフラグ
      \unexpanded{\jlreq@pagestyle@make@runninghead@{#1}{#2}{#3}}\csexpandonce{#1}\noexpand\jlreq@endmark
    }%
    \expandafter\def\csname #1\endcsname{}%
    \jlreq@do
    % 項目が二つ以上あった．
    \ifjlreq@tempa\else\cspreto{#1}{\jlreq@PageStyle@firsttrue}\fi
  }%
}
\def\jlreq@pagestyle@make@runninghead@#1#2#3#4#5{%
  \ifnum\numexpr\jlreq@ifendmark{#5}{1}{0}*\ifjlreq@tempa 1\else 0\fi\relax=1 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi{%
    % 項目が一つしか無い
    \jlreq@ifempty{#2}{\csappto}{\cspreto}{#1}{#4}%
  }{%
    % 最初の空でない柱に出会うまでは柱の間の空白を入れない．
    % 空でない柱に出会ってないならば\ifjlreq@PageStyle@firstはtrue．
    % 一番最初の\jlreq@PageStyle@firsttrueは後で入れる．
    \jlreq@ifempty{#2}{\csappto}{\cspreto}{#1}{%
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
    \edef\jlreq@do{\unexpanded{\def\jlreq@tempa##1}{\ifx#2\relax\expandonce{#3}\else\expandonce{#2}\fi}}\jlreq@do
    \edef#1{\expandafter\expandonce\expandafter{\expandafter\jlreq@tempa\expandafter{#1}}}%
  \fi
}

% フォント情報を追加する．#1：制御綴り名，#2：フォント命令の入っている制御綴名，#1に返す
\def\jlreq@pagestyle@addfont@tocs#1#2{%
  \expandafter\ifx\csname #1\endcsname\@empty\else
    \expandafter\ifx\csname #2\endcsname\@empty\else
      \expandafter\edef\csname #1\endcsname{{\csexpandonce{#2}\csexpandonce{#1}}}%
    \fi
  \fi
}
% こちらは#1にトークン列を与える．\edefで展開される．制御綴名#3に代入．
\def\jlreq@pagestyle@addfont@totokens#1#2#3{%
  \begingroup
    \edef\jlreq@do{\noexpand\edef\expandonce{\csname#3\endcsname}{\unexpanded{#1}}}%
    \expandafter\ifx\csname #2\endcsname\@empty\else
      \edef\jlreq@tempa{#1}%
      \ifx\jlreq@tempa\@empty\else
        \edef\jlreq@do{%
          \noexpand\edef\expandonce{\csname #3\endcsname}{\noexpand\unexpanded{%
            {\csexpandonce{#2}\expandonce{\jlreq@tempa}}%
          }}%
        }%
      \fi
    \fi
  \expandafter\endgroup
  \jlreq@do
}

%.. \DeclarePageStyle
\newbox\jlreq@PageStyle@box
\newcommand{\DeclarePageStyle}[2]{%
  \expandafter\edef\csname jlreq@pagestyle@setting@#1\endcsname{\unexpanded{#2}}%
  \begingroup
    \def\jlreq@nombre@i@position{}%
    \def\jlreq@nombre@i{\thepage}%
    \def\jlreq@running@head@i@position{}%
    \def\jlreq@odd@running@head@i{}%
    \def\jlreq@even@running@head@i{}%
    \def\jlreq@command{}%
    \def\jlreq@mark@format{}%
    \def\jlreq@font{}%
    \def\jlreq@nombre@font{}%
    \def\jlreq@running@head@font{}%
    % フォーマットを空という可能性もあるかもしれないので，デフォルト値は\relaxで表す．
    \let\jlreq@oddheadformat\relax
    \let\jlreq@evenheadformat\relax
    \let\jlreq@oddfootformat\relax
    \let\jlreq@evenfootformat\relax
    % 柱とノンブルの間
    \def\jlreq@gap{1.5\zw}%
    \def\jlreq@nombre@gap{}%
    \def\jlreq@running@head@gap{}%
    \newif\ifjlreq@clearmarkcommand\jlreq@clearmarkcommandtrue
    \newif\ifjlreq@pstate\jlreq@pstatefalse % PageStyleTATE
    \@for\jlreq@i:=ii,iii\do{%
      \expandafter\def\csname jlreq@nombre@\jlreq@i @position\endcsname{}%
      \expandafter\def\csname jlreq@running@head@\jlreq@i @position\endcsname{}%
      \expandafter\def\csname jlreq@nombre@\jlreq@i\endcsname{}%
      \expandafter\def\csname jlreq@odd@running@head@\jlreq@i\endcsname{}%
      \expandafter\def\csname jlreq@even@running@head@\jlreq@i\endcsname{}%
      \expandafter\def\csname jlreq@nombre@\jlreq@i @font\endcsname{}%
      \expandafter\def\csname jlreq@running@head@\jlreq@i @font\endcsname{}%
    }%
    \jlreq@parsekeyval[PageStyle:#1]{
      *{tate}{\jlreq@pstatetrue}
      *{yoko}{\jlreq@pstatefalse}
      {nombre}{\def\jlreq@nombre@i{##1}}
      {nombre_position}{\def\jlreq@nombre@i@position{##1}}
      {running_head_position}{\def\jlreq@running@head@i@position{##1}}
      {odd_running_head}{\def\jlreq@odd@running@head@i{##1}}
      {even_running_head}{\def\jlreq@even@running@head@i{##1}}
      {font}{%
        \def\jlreq@nombre@font{##1}%
        \def\jlreq@running@head@font{##1}%
      }
      {nombre_font}{\def\jlreq@nombre@font{##1}}
      {running_head_font}{\def\jlreq@running@head@font{##1}}
      {mark_format}{\edef\jlreq@mark@format{\unexpanded{##1}}}
      {command}{\edef\jlreq@command{\unexpanded{##1}}}
      {gap}{\def\jlreq@gap{##1}}
      {nombre_gap}{\def\jlreq@nombre@gap{##1}}
      {running_head_gap}{\def\jlreq@running@head@gap{##1}}
      % trueにすると，\ps@***実行時にまず\***markを全て\@gobbleにする．
      {clear_markcommand}[true,false]{\csname jlreq@clearmarkcommand##1\endcsname}
      {odd_head_format}{\edef\jlreq@oddheadformat{\unexpanded{##1}}}
      {even_head_format}{\edef\jlreq@evenheadformat{\unexpanded{##1}}}
      {odd_foot_format}{\edef\jlreq@oddfootformat{\unexpanded{##1}}}
      {even_foot_format}{\edef\jlreq@evenfootformat{\unexpanded{##1}}}
      % 二つ目
      {nombre_ii}{\def\jlreq@nombre@ii{##1}}
      {nombre_ii_position}{\def\jlreq@nombre@ii@position{##1}}
      {running_head_ii_position}{\def\jlreq@running@head@ii@position{##1}}
      {odd_running_head_ii}{\def\jlreq@odd@running@head@ii{##1}}
      {even_running_head_ii}{\def\jlreq@even@running@head@ii{##1}}
      {nombre_ii_font}{\def\jlreq@nombre@ii@font{##1}}
      {running_head_ii_font}{\def\jlreq@running@head@ii@font{##1}}
      % 三つ目
      {nombre_iii}{\def\jlreq@nombre@iii{##1}}
      {nombre_iii_position}{\def\jlreq@nombre@iii@position{##1}}
      {running_head_iii_position}{\def\jlreq@running@head@iii@position{##1}}
      {odd_running_head_iii}{\def\jlreq@odd@running@head@iii{##1}}
      {even_running_head_iii}{\def\jlreq@even@running@head@iii{##1}}
      {nombre_iii_font}{\def\jlreq@nombre@iii@font{##1}}
      {running_head_iii_font}{\def\jlreq@running@head@iii@font{##1}}
    }{#2}%
    % ノンブル同士の間や柱同士の間のデフォルトはノンブルと柱の間の空き量
    \ifx\jlreq@nombre@gap\@empty\let\jlreq@nombre@gap=\jlreq@gap\fi
    \ifx\jlreq@running@head@gap\@empty\let\jlreq@running@head@gap=\jlreq@gap\fi
    % _iiが存在するか調べて\ifjlreq@headii@existに入れる
    \newif\ifjlreq@headii@exist
    \jlreq@headii@existfalse
    \jlreq@for@noexpand\jlreq@tempa:=\jlreq@odd@running@head@ii,\jlreq@odd@running@head@ii\do{%
      \expandafter\ifx\jlreq@tempa\@empty\else\jlreq@headii@existtrue\fi
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
    \@for\jlreq@parity:=odd,even\do{%
      \@for\jlreq@i:=0,1,2\do{%
        % \jlreq@pagestyle@setmarkが上の処理を行う．
        \edef\jlreq@next{\noexpand\jlreq@pagestyle@setmark{\expandonce{\csname jlreq@\jlreq@parity @running@head@\@roman\numexpr\jlreq@i + 1\relax\endcsname}}{\expandonce{\jlreq@i}}{\expandonce{\jlreq@parity}}{jlreq@markdata}{\noexpand\jlreq@headingmarklist}}%
        \jlreq@next
      }%
    }%
    % \jlreq@minimumlevelに見出しの最低（数値が小さいという意味）レベルを入れる．
    \let\jlreq@minimumlevel=\@undefined
    \def\jlreq@markdefinecommand{}%
    \@for\jlreq@heading:=\jlreq@headingmarklist\do{%
      \ifx\jlreq@heading\@empty\else
        \expandafter\let\expandafter\jlreq@level\csname jlreq@heading@level@\jlreq@heading\endcsname
        \ifx\jlreq@level\relax\else
          \ifx\jlreq@minimumlevel\@undefined\let\jlreq@minimumlevel=\jlreq@level
          \else\ifnum\jlreq@minimumlevel>\jlreq@level\space\let\jlreq@minimumlevel=\jlreq@level\fi\fi
        \fi
        % \jlreq@markdata@<見出し命令>にある情報とmark_formatをもとに，\<見出し命令>markを定義するマクロを作成，\jlreq@markdefinecommandに入れる．
        \edef\jlreq@do{\noexpand\jlreq@pagestyle@make@headingmark{\ifjlreq@headii@exist *\fi}{\expandonce{\jlreq@heading}}{\expandonce{\jlreq@mark@format}}{\csexpandonce{jlreq@markdata@\jlreq@heading}}}%
        \jlreq@do
        \eappto\jlreq@markdefinecommand{\expandonce{\jlreq@result}}%
      \fi
    }%
    \ifx\jlreq@minimumlevel\@undefined\else
      \eappto\jlreq@markdefinecommand{\noexpand\jlreq@pagestyle@setclearmark{\expandonce{\jlreq@minimumlevel}}}%
    \fi
    % 見出しを出す場合：evenに章などの高いレベルの見出しを出す（2.6.3.a）
    \@ifundefined{jlreq@odd@running@head@i@heading@level}{}{\@ifundefined{jlreq@even@running@head@i@heading@level}{}{%
      \ifnum\jlreq@odd@running@head@i@heading@level<\jlreq@even@running@head@i@heading@level
        \jlreq@note{偶数ページには奇数ページよりアウトラインレベルの高い見出しを入れる (ページスタイル #1 内，2.6.3.a)．}%
      \fi
    }}%
    % 二番目以降にフォント設定を追加
    \@for\jlreq@i:=ii,iii\do{%
      \@for\jlreq@parity:=odd,even\do{%
        \jlreq@pagestyle@addfont@tocs{jlreq@\jlreq@parity @running@head@\jlreq@i}{jlreq@running@head@\jlreq@i @font}%
      }%
      \jlreq@pagestyle@addfont@tocs{jlreq@nombre@\jlreq@i}{jlreq@nombre@\jlreq@i @font}%
    }%
    % \jlreq@oddhead,\jlreq@oddfoot,\jlreq@evenhead,\jlreq@evenfootに必要なものを入れる．
    \ifjlreq@pstate\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi{% tate
      % headの方に処理を入れる．footは空．
      \def\jlreq@oddfoot{}\def\jlreq@evenfoot{}%
      \jlreq@for@noexpand\jlreq@position:=\jlreq@nombre@i@position,\jlreq@running@head@i@position\do{%
        \expandafter\ifx\jlreq@position\@empty\expandafter\def\jlreq@position{0pt}\fi
      }%
      \edef\jlreq@gapcs{\noexpand\hskip\noexpand\glueexpr\expandonce{\jlreq@nombre@gap}\noexpand\relax}%
      \jlreq@pagestyle@addifempty{\jlreq@nombre@iii@position}{\jlreq@nombre@ii}{\jlreq@gapcs}{\jlreq@nombre@iii}%
      \jlreq@pagestyle@addifempty{\jlreq@nombre@ii@position}{\jlreq@nombre@i}{\jlreq@gapcs}{\jlreq@nombre@ii}%
      \edef\jlreq@gapcs{\noexpand\hskip\noexpand\glueexpr\expandonce{\jlreq@running@head@gap}\noexpand\relax}%
      \jlreq@pagestyle@addifempty{\jlreq@running@head@iii@position}{\jlreq@odd@running@head@ii}{\jlreq@gapcs}{\jlreq@odd@running@head@iii}%
      \jlreq@pagestyle@addifempty{\jlreq@running@head@ii@position}{\jlreq@odd@running@head@i}{\jlreq@gapcs}{\jlreq@odd@running@head@ii}%
      \jlreq@pagestyle@addifempty{\jlreq@running@head@iii@position}{\jlreq@even@running@head@ii}{\jlreq@gapcs}{\jlreq@even@running@head@iii}%
      \jlreq@pagestyle@addifempty{\jlreq@running@head@ii@position}{\jlreq@even@running@head@i}{\jlreq@gapcs}{\jlreq@even@running@head@ii}%
      \def\jlreq@nombre@contents{}% ノンブルを入れる（下の方に出力）
      \@for\jlreq@i:=i,ii,iii\do{%
        \expandafter\let\expandafter\jlreq@position\csname jlreq@nombre@\jlreq@i @position\endcsname
        \expandafter\ifx\csname jlreq@nombre@\jlreq@i\endcsname\@empty\else
          \jlreq@ifgluezero{\glueexpr\jlreq@position\relax}{\def\jlreq@position{}}{}%
          \eappto\jlreq@nombre@contents{%
            \noexpand\hbox to 0pt{\noexpand\hss
              \ifx\jlreq@position\@empty\else\unexpanded{\hskip \glueexpr}\expandonce{\jlreq@position}\noexpand\relax\fi
              \csexpandonce{jlreq@nombre@\jlreq@i}%
            }%
          }%
        \fi
      }%
      \jlreq@pagestyle@addfont@tocs{jlreq@nombre@contents}{jlreq@nombre@font}%
      % \jlreq@(odd|even)@contentsに柱を入れる（上の方に出力）
      \@for\jlreq@parity:=odd,even\do{%
        \expandafter\def\csname jlreq@\jlreq@parity @contents\endcsname{}%
        \@for\jlreq@i:=i,ii,iii\do{%
          \expandafter\let\expandafter\jlreq@position\csname jlreq@running@head@\jlreq@i @position\endcsname
          \expandafter\ifx\csname jlreq@\jlreq@parity @running@head@\jlreq@i\endcsname\@empty\else
            \jlreq@ifgluezero{\glueexpr\jlreq@position\relax}{\def\jlreq@position{}}{}%
            \expandafter\eappto\csname jlreq@\jlreq@parity @contents\endcsname{%
              \noexpand\hbox to 0pt{\unexpanded{\hskip\glueexpr\headsep + \headheight}%
                \if@tate\else\unexpanded{+ \topskip - \Cht}\fi
                \ifx\jlreq@position\@empty\else + \expandonce{\jlreq@position}\fi\noexpand\relax
                \csexpandonce{jlreq@\jlreq@parity @running@head@\jlreq@i}%
                \noexpand\hss
              }%
            }%
          \fi
        }%
        \jlreq@pagestyle@addfont@tocs{jlreq@\jlreq@parity @contents}{jlreq@running@head@font}%
        % \jlreq@(odd|even)headの構築
        % 空き指定には基本版面の文字サイズを使う（2.6.1.c）
        \@ifundefined{jlreq@\jlreq@parity headformat}
          {\def\jlreq@format{####1}}%
          {\expandafter\let\expandafter\jlreq@format\csname jlreq@\jlreq@parity headformat\endcsname}%
        \edef\jlreq@do{\unexpanded{\def\jlreq@tempa##1}{\expandonce{\jlreq@format}}}\jlreq@do
        \edef\jlreq@tempb{%
          \csexpandonce{jlreq@\jlreq@parity @contents}%
          \noexpand\hfil
          \expandonce{\jlreq@nombre@contents}%
        }%
        \expandafter\edef\csname jlreq@\jlreq@parity head\endcsname{%
          \unexpanded{\setbox\jlreq@tempboxa=\hbox to \dimexpr\headsep + \headheight + \textheight}\if@tate\else\unexpanded{- \topskip + 1\zh}\fi\noexpand\relax
          {%
            \unexpanded{\tate\adjustbaseline}%
            \expandafter\expandonce\expandafter{\expandafter\jlreq@tempa\expandafter{\jlreq@tempb}}%
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
        \noexpand\hskip\noexpand\dimexpr\if@tate\unexpanded{- \Cdp}\fi \unexpanded{- \headsep - 1\zw\relax}%
        \unexpanded{\box\jlreq@tempboxa\hfil}%
      }%
      \edef\jlreq@righthead@adjustbox{%
        \noexpand\hskip\unexpanded{\dimexpr\textwidth}\if@tate\unexpanded{- \topskip + \Cht}\fi\unexpanded{ + \headsep\relax}%
        \unexpanded{\box\jlreq@tempboxa\hss}%
      }%
      \if@tate
        \eappto\jlreq@oddhead{\expandonce{\jlreq@lefthead@adjustbox}}%
        \eappto\jlreq@evenhead{\expandonce{\jlreq@righthead@adjustbox}}%
      \else
        \eappto\jlreq@oddhead{\expandonce{\jlreq@righthead@adjustbox}}%
        \eappto\jlreq@evenhead{\expandonce{\jlreq@lefthead@adjustbox}}%
      \fi
    }{% yoko
      % 場所を正規化する．
      \def\jlreq@nombre@i@position@default{{bottom}{center}}%
      \def\jlreq@running@head@i@position@default{{top}{center}}%
      % ii以降の位置は指定されていない場合はiのそれに合わせる
      \@for\jlreq@tempa:=jlreq@nombre,jlreq@running@head\do{%
        \@for\jlreq@i:=ii,iii\do{%
          \expandafter\ifx\csname\jlreq@tempa @\jlreq@i @position\endcsname\@empty
            \expandafter\let\csname\jlreq@tempa @\jlreq@i @position\expandafter\endcsname\csname\jlreq@tempa @i@position\endcsname
          \fi
          \expandafter\edef\csname\jlreq@tempa @\jlreq@i @position@default\endcsname{\csname\jlreq@tempa @i@position@default\endcsname}%
        }%
      }%
      \@for\jlreq@tempa:=jlreq@nombre@i@position,jlreq@nombre@ii@position,jlreq@nombre@iii@position,jlreq@running@head@i@position,jlreq@running@head@ii@position,jlreq@running@head@iii@position\do{%
        \edef\jlreq@next{\noexpand\jlreq@pagestyle@parse@position{\csexpandonce{\jlreq@tempa}}{\expandonce{\csname\jlreq@tempa\endcsname}}{\csexpandonce{\jlreq@tempa @default}}}%
        \jlreq@next
      }%
      \ifthenelse{\(
        \boolean{@tate} \AND \(
          \equal{\expandafter\@secondoftwo\jlreq@nombre@i@position}{right} \OR
          \equal{\expandafter\@secondoftwo\jlreq@running@head@i@position}{right}
      \)\) \OR \(
        \(\NOT \boolean{@tate}\) \AND \(
          \equal{\expandafter\@secondoftwo\jlreq@nombre@i@position}{left} \OR
          \equal{\expandafter\@secondoftwo\jlreq@running@head@i@position}{left}
        \)
      \)}{%
        \if@twoside
          \jlreq@note{柱やノンブルは，左ページでは，基本版面の左端の延長線にノンブル又は柱の先頭をそろえて配置するか，基本版面の左端の延長線から基本版面の文字サイズの全角アキだけ右に寄せた位置に配置する (ページスタイル #1 内，2.6.1.b)．}%
        \fi
      }{}%
      % フォント変更命令に文字出力命令が入っているとエラーになるのを回避するために\setboxでごまかす．
      \setbox\jlreq@tempboxa=\hbox{\jlreq@running@head@font
        \ifthenelse{\lengthtest{\jlreq@gap < 1.49\zw} \OR \( \lengthtest{\jlreq@gap > 1.51\zw} \AND \lengthtest{\jlreq@gap < 1.99\zw} \) \OR \lengthtest{\jlreq@gap > 2.01\zw}}{\jlreq@note{ノンブルと柱との空き量は柱に使用する文字サイズの2倍又は1.5倍とする (ページスタイル #1 内，2.6.1.c)．}}{}%
      }%
      % 初期化
      \@for\jlreq@parity:=odd,even\do{%
        \@for\jlreq@vert:=top,bottom\do{%
          \@for\jlreq@hor:=left,center,right\do{%
            \@for\jlreq@type:=nombre,running@head\do{%
              \expandafter\def\csname jlreq@\jlreq@type @\jlreq@parity @\jlreq@vert @\jlreq@hor\endcsname{}%
            }%
          }%
        }%
        % ページが左か右か
        \jlreq@ifleftpage{\jlreq@parity}{\def\jlreq@pagehor{left}}{\def\jlreq@pagehor{right}}%
        % \jlreq@(running@head|nombre)@(odd|even)@(top|bottom)@(left|center|right)に入れていく
        % 左ページではノンブルが左（2.6.1.c），i,ii,...はiが左になるようにする．
        \@for\jlreq@i:=i,ii,iii\do{%
          % nombre
          \expandafter\ifx\csname jlreq@nombre@\jlreq@i\endcsname\@empty\else
            \edef\jlreq@position{\csname jlreq@nombre@\jlreq@i @position\endcsname}%
            \edef\jlreq@vert{\expandafter\@firstoftwo\jlreq@position}%
            \edef\jlreq@hor{\expandafter\@secondoftwo\jlreq@position}%
            \ifthenelse{\equal{\jlreq@parity}{even}}{\jlreq@reverse@leftright{\jlreq@hor}}{}%
            \jlreq@ifleftpage{\jlreq@parity}{\let\jlreq@addtocs=\cseappto}{\let\jlreq@addtocs\csepreto}%
            \edef\jlreq@csname{jlreq@nombre@\jlreq@parity @\jlreq@vert @\jlreq@hor}%
            \expandafter\ifx\csname\jlreq@csname\endcsname\@empty\else\jlreq@addtocs{\jlreq@csname}{\unexpanded{\hskip\glueexpr}\expandonce{\jlreq@nombre@gap}\noexpand\relax}\fi
            \jlreq@addtocs{\jlreq@csname}{\csexpandonce{jlreq@nombre@\jlreq@i}}%
          \fi
          % running@head
          % 一度「紙面の外から」の順番で{A}{B}{C}と入れる
          \expandafter\ifx\csname jlreq@\jlreq@parity @running@head@\jlreq@i \endcsname\@empty\else
            \edef\jlreq@position{\csname jlreq@running@head@\jlreq@i @position\endcsname}%
            \edef\jlreq@vert{\expandafter\@firstoftwo\jlreq@position}%
            \edef\jlreq@hor{\expandafter\@secondoftwo\jlreq@position}%
            \ifthenelse{\equal{\jlreq@parity}{even}}{\jlreq@reverse@leftright{\jlreq@hor}}{}%
            \ifthenelse{\equal{\jlreq@hor}{\jlreq@pagehor}}{\let\jlreq@addtocs=\cseappto}{\let\jlreq@addtocs=\csepreto}%
            \edef\jlreq@csname{jlreq@running@head@\jlreq@parity @\jlreq@vert @\jlreq@hor}%
            \jlreq@addtocs{\jlreq@csname}{{\csexpandonce{jlreq@\jlreq@parity @running@head@\jlreq@i}}}%
          \fi
        }%
        % {A}{B}{C}の順だった柱を結合する．本体は\jlreq@pagestyle@make@runninghead．
        \@for\jlreq@vert:=top,bottom\do{%
          \@for\jlreq@hor:=left,center,right\do{%
            \ifthenelse{\equal{\jlreq@hor}{right}}{\def\jlreq@tempa{*}}{\def\jlreq@tempa{}}%
            \edef\jlreq@do{\noexpand\jlreq@pagestyle@make@runninghead{jlreq@running@head@\jlreq@parity @\jlreq@vert @\jlreq@hor}{\expandonce{\jlreq@tempa}}{\expandonce{\jlreq@running@head@gap}}}%
            \jlreq@do
          }%
        }%
        % ノンブルと柱を結合し，必要ならばフォント設定をする．
        \@for\jlreq@vert:=top,bottom\do{%
          \@for\jlreq@hor:=left,center,right\do{%
            \edef\jlreq@csname{jlreq@\jlreq@parity @\jlreq@vert @\jlreq@hor}%
            \edef\jlreq@runheadcsname{jlreq@running@head@\jlreq@parity @\jlreq@vert @\jlreq@hor}%
            \edef\jlreq@nombrecsname{jlreq@nombre@\jlreq@parity @\jlreq@vert @\jlreq@hor}%
            % nombreにフォント設定を追加．
            \expandafter\ifx\csname\jlreq@nombrecsname\endcsname\@empty\else
              \ifx\jlreq@nombre@font\@empty\else
                \expandafter\edef\csname\jlreq@nombrecsname\endcsname{{\expandonce{\jlreq@nombre@font}\csexpandonce{\jlreq@nombrecsname}}}%
              \fi
            \fi
            \expandafter\ifx\csname\jlreq@runheadcsname\endcsname\@empty\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi{%
              % 柱が空：ノンブルのみでよい
              \expandafter\let\csname\jlreq@csname\expandafter\endcsname\csname\jlreq@nombrecsname\endcsname
            }{%
              \expandafter\ifx\csname\jlreq@nombrecsname\endcsname\@empty\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi{%
%                % ノンブルが空．柱のみでよい．
                \jlreq@pagestyle@addfont@tocs{\jlreq@runheadcsname}{jlreq@running@head@font}%
                \expandafter\let\csname\jlreq@csname\expandafter\endcsname\csname\jlreq@runheadcsname\endcsname
              }{%
%                % 両方ある場合：左ページではノンブルが左，右ページではノンブルが右．
                \jlreq@ifleftpage{\jlreq@parity}{%
                  \ifthenelse{\equal{\jlreq@hor}{right}}{%
                    % <ノンブル><空き><柱>，右寄せ
                    % 柱が空出ないときに限り<空き>を入れる．
                    \jlreq@pagestyle@addfont@totokens{\unexpanded{\ifdim\wd\jlreq@PageStyle@box=0pt \else\hskip}\expandonce{\jlreq@gap}\unexpanded{\relax\fi}}{jlreq@running@head@font}{jlreq@tempa}%
                    \expandafter\edef\csname\jlreq@csname\endcsname{%
                      \unexpanded{\setbox\jlreq@PageStyle@box=\hbox}{\expandonce{\jlreq@running@head@font}\csexpandonce{\jlreq@runheadcsname}}%
                      \csexpandonce{\jlreq@nombrecsname}\expandonce{\jlreq@tempa}\unexpanded{\box\jlreq@PageStyle@box}%
                    }%
                  }{%
                    % <ノンブル><空き><柱>，左寄せ
                    % ノンブルは常に空ではないと仮定する．
                    \jlreq@pagestyle@addfont@totokens{\unexpanded{\hskip\glueexpr}\expandonce{\jlreq@gap}\noexpand\relax\csexpandonce{\jlreq@runheadcsname}}{jlreq@running@head@font}{jlreq@tempa}%
                    \expandafter\edef\csname\jlreq@csname\endcsname{\csexpandonce{\jlreq@nombrecsname}\expandonce{\jlreq@tempa}}%
                  }%
                }{%
                  \ifthenelse{\equal{\jlreq@hor}{left}}{%
                    % <柱><空き><ノンブル>，左寄せ
                    \jlreq@pagestyle@addfont@totokens{%
                      \unexpanded{\setbox\jlreq@PageStyle@box=\hbox}{\csexpandonce{\jlreq@runheadcsname}}%
                      \unexpanded{\copy\jlreq@PageStyle@box\ifdim\wd\jlreq@PageStyle@box=0pt \else\hskip\glueexpr}\expandonce{\jlreq@gap}\unexpanded{\relax\fi}%
                    }{jlreq@running@head@font}{jlreq@tempa}%
                    \expandafter\edef\csname\jlreq@csname\endcsname{\expandonce{\jlreq@tempa}\csexpandonce{\jlreq@nombrecsname}}%
                  }{%
                    % <柱><空き><ノンブル>，右寄せ
                    \jlreq@pagestyle@addfont@totokens{\csexpandonce{\jlreq@runheadcsname}\unexpanded{\hskip\glueexpr}\expandonce{\jlreq@gap}\noexpand\relax}{jlreq@running@head@font}{jlreq@tempa}%
                    \expandafter\edef\csname\jlreq@csname\endcsname{\expandonce{\jlreq@tempa}\csexpandonce{\jlreq@nombrecsname}}%
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
      \ifthenelse{\lengthtest{\marginparwidth>0pt} \AND \(\NOT\boolean{@tate}\)}{%
        \def\jlreq@defaultformat{\hss\hbox to \jlreqyokoheadlength{####1}\hss}%
      }{%
        \def\jlreq@defaultformat{####1}%
      }%
      \jlreq@pagestyle@applyformat{\jlreq@oddhead}{\jlreq@oddheadformat}{\jlreq@defaultformat}%
      \jlreq@pagestyle@applyformat{\jlreq@evenhead}{\jlreq@evenheadformat}{\jlreq@defaultformat}%
      \jlreq@pagestyle@applyformat{\jlreq@oddfoot}{\jlreq@oddfootformat}{\jlreq@defaultformat}%
      \jlreq@pagestyle@applyformat{\jlreq@evenfoot}{\jlreq@evenfootformat}{\jlreq@defaultformat}%
      % 傍注用調整
      \ifdim\marginparwidth>0pt
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
      \noexpand\edef\expandonce{\csname ps@#1\endcsname}{%
        \noexpand\unexpanded{%
          \unexpanded{\def\jlreq@current@pagestyle{#1}}%
          \ifjlreq@clearmarkcommand\unexpanded{\jlreq@heading@execmacro@toallheadings\jlreq@clearheadingmarks}\fi
          \ifjlreq@headii@exist
            \unexpanded{\let\@mkboth=\jlreq@markboth}%
          \else
            \unexpanded{\let\@mkboth=\markboth}%
          \fi
          \unexpanded{\def\@oddhead}{\expandonce{\jlreq@oddhead}}%
          \unexpanded{\def\@oddfoot}{\expandonce{\jlreq@oddfoot}}%
          \unexpanded{\def\@evenhead}{\expandonce{\jlreq@evenhead}}%
          \unexpanded{\def\@evenfoot}{\expandonce{\jlreq@evenfoot}}%
          \expandonce{\jlreq@markdefinecommand}%
          \expandonce{\jlreq@command}%
        }%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\if@tate
  \def\jlreqyokoheadlength{\textheight}
\else
  \ifdim\marginparwidth>0pt
    \if@twocolumn
      \def\jlreqyokoheadlength{\dimexpr\textwidth + 2\marginparwidth + 2\marginparsep\relax}
    \else
      \def\jlreqyokoheadlength{\dimexpr\textwidth + \marginparwidth + \marginparsep\relax}
    \fi
  \else
    \def\jlreqyokoheadlength{\textwidth}
  \fi
\fi
\edef\jlreqtateheadlength{\unexpanded{\dimexpr\headsep + \headheight + \textheight}\if@tate\else\unexpanded{- \topskip + 1\zh}\fi\noexpand\relax}

\newcommand*{\NewPageStyle}[2]{%
  \expandafter\@ifdefinable\csname ps@#1\endcsname{\DeclarePageStyle{#1}{#2}}%
}
\newcommand*{\RenewPageStyle}[2]{%
  \@ifundefined{ps@#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclarePageStyle{#1}{#2}}%
}
\newcommand*{\ProvidePageStyle}[2]{%
  \@ifundefined{ps@#1}{\DeclarePageStyle{#1}{#2}}{}%
}
\newcommand*{\ModifyPageStyle}[2]{%
  \begingroup
    \@ifundefined{jlreq@pagestyle@setting@#1}{\ClassError{jlreq}{Unknown pagestyle: #1}{\@ehc}}{}%
    \expandafter\let\expandafter\setting\expandafter=\csname jlreq@pagestyle@setting@#1\endcsname
    \edef\jlreq@do{\noexpand\RenewPageStyle{#1}{\expandonce{\setting},\unexpanded{#2}}}%
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
        \epreto\jlreq@do{%
          \noexpand\edef\expandonce{\csname #2\endcsname}{\unexpanded{\unexpanded{##1}}}
          \noexpand\def\expandonce{\csname #1\endcsname}{}%
        }%
        \expandafter\@for\expandafter\jlreq@tempa\expandafter:\expandafter=\csname #1\endcsname\do{%
          \epreto\jlreq@do{\noexpand\let\expandonce{\csname #2@\jlreq@tempa\endcsname}\noexpand\@undefined}%
        }%
      }{%
        \eappto\jlreq@do{%
          \noexpand\edef\expandonce{\csname #2@##1\endcsname}{\unexpanded{\unexpanded{##2}}}%
          \unexpanded{\def\jlreq@tempa{\jlreq@helper@removeelement{##1}}}%
          \unexpanded{\expandafter\jlreq@tempa\expandafter}{\expandonce{\csname #1\endcsname}}{\expandonce{\csname #1\endcsname}}%
          \unexpanded{\csappto{#1}{,##1}}%
        }%
      }%
    }{#3}%
  \expandafter\endgroup
  \jlreq@do
}

% #1@#2が定義されていれば\#1@#2の中身に，そうでなければ\#1の中身に展開される．
% 展開は\unexpandedで抑制される．
\def\jlreq@jlreqsetup@withenv@nameuse#1#2{%
  \expandafter\ifx\csname #1@#2\endcsname\relax\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi{\csexpandonce{#1}}{\csexpandonce{#1@#2}}%
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
      {\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@label@font@setting}{\jlreq@tempb}\expandonce{\jlreq@tempa{#1}}}%
      \unexpanded{\hskip\glueexpr}\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@after@label@space@setting}{\jlreq@tempb}\noexpand\relax
      {\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@font@setting}{\jlreq@tempb}\unexpanded{#2}}%
    }%
  \fi
  \setbox\@tempboxa=\hbox{\jlreq@tempa}%
  \edef\jlreq@tempc{\jlreq@jlreqsetup@withenv@nameuse{jlreq@@makecaption@align@setting}{\jlreq@tempb}}%
  \expandafter\let\expandafter\jlreq@align\jlreq@tempc
  \ifdim\wd\@tempboxa>\hsize\relax
    {%
      \ifx c\jlreq@align\centering\fi
      \ifx r\jlreq@align\raggedleft\fi
      \unhbox\@tempboxa\par
    }%
  \else
    \global\@minipagefalse
    \hbox to\hsize{%
      \ifnum0\ifx c\jlreq@align 1\fi\ifx r\jlreq@align 1\fi>0 \hfil\fi
      \unhbox\@tempboxa
      \ifnum0\ifx c\jlreq@align 1\fi\ifx l\jlreq@align 1\fi>0 \hfil\fi
    }%
  \fi
  \vskip\belowcaptionskip}}

\jlreq@jlreqsetup@add{caption_font}{\jlreq@jlreqsetup@withenv{jlreq@@makecaption@font@envlist}{jlreq@@makecaption@font@setting}{#1}}
\jlreq@jlreqsetup@add{caption_label_font}{\jlreq@jlreqsetup@withenv{jlreq@@makecaption@label@font@envlist}{jlreq@@makecaption@label@font@setting}{#1}}
\jlreq@jlreqsetup@add{caption_label_format}{\jlreq@jlreqsetup@withenv{jlreq@@makecaption@label@format@envlist}{jlreq@@makecaption@label@format@setting}{#1}}
\jlreq@jlreqsetup@add{caption_after_label_space}{\jlreq@jlreqsetup@withenv{jlreq@@makecaption@after@label@space@envlist}{jlreq@@makecaption@after@label@space@setting}{#1}}

\def\jlreq@@makecaption@align@clearandsetalign#1{%
  \@for\jlreq@tempa:=\jlreq@@makecaption@align@envlist\do{%
    \ifx\jlreq@tempa\@empty\else
      \eappto\jlreq@generalset{\noexpand\let\expandonce{\csname jlreq@@makecaption@align@setting@\jlreq@tempa\endcsname}=\noexpand\@undefined}%
    \fi
  }%
  \appto\jlreq@generalset{%
    \def\jlreq@@makecaption@align@envlist{}%
    \let\jlreq@@makecaption@align@setting=#1%
  }%
}
\jlreq@jlreqsetup@add{caption_align}{%
  \@ifundefined{jlreq@@makecaption@align@envlist}{\def\jlreq@@makecaption@align@envlist{}}{}%
  \begingroup
    \def\jlreq@generalset{}\def\jlreq@envset{}%
    \jlreq@parsekeyval@nokey{%
      \jlreq@ifempty{##1}{}{%
        \jlreq@switch{##1}{%
          {center}{\jlreq@@makecaption@align@clearandsetalign{c}}
          {left}{\jlreq@@makecaption@align@clearandsetalign{l}}
          {right}{\jlreq@@makecaption@align@clearandsetalign{r}}
          {top}{\jlreq@@makecaption@align@clearandsetalign{l}}
          {bottom}{\jlreq@@makecaption@align@clearandsetalign{r}}
          {%
            \jlreq@switch{##2}{%
              {center}{\eappto\jlreq@envset{\noexpand\let\expandonce{\csname jlreq@@makecaption@align@setting@##1\endcsname}=c}}%
              {left}{\eappto\jlreq@envset{\noexpand\let\expandonce{\csname jlreq@@makecaption@align@setting@##1\endcsname}=l}}%
              {right}{\eappto\jlreq@envset{\noexpand\let\expandonce{\csname jlreq@@makecaption@align@setting@##1\endcsname}=r}}%
              {top}{\eappto\jlreq@envset{\noexpand\let\expandonce{\csname jlreq@@makecaption@align@setting@##1\endcsname}=l}}%
              {bottom}{\eappto\jlreq@envset{\noexpand\let\expandonce{\csname jlreq@@makecaption@align@setting@##1\endcsname}=r}}%
            }%
            \appto\jlreq@envset{%
              \def\jlreq@tempa{\jlreq@helper@removeelement{##1}}%
              \expandafter\jlreq@tempa\expandafter{\jlreq@@makecaption@align@envlist}{\jlreq@@makecaption@align@envlist}%
              \appto\jlreq@@makecaption@align@envlist{,##1}%
            }%
          }%
        }%
      }%
    }{#1}%
    \edef\jlreq@do{\expandonce{\jlreq@generalset}\expandonce{\jlreq@envset}}%
  \expandafter\endgroup
  \jlreq@do
}
% 特に根拠のない値
\setlength\abovecaptionskip{.5\jlreq@gol}
\setlength\belowcaptionskip{0pt}

%.. figure環境
\newcounter{figure}
\ifthenelse{\equal{\jlreq@article@type}{article}}{%
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
\ifthenelse{\equal{\jlreq@article@type}{article}}{%
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
        \pretocmd{\ialign}{\unexpanded{\tate\let\ialign=\jlreq@temporary@original@ialign}}{}{}%
      \fi
      \begin{tabular}[t]{c}%
        \@author
      \end{tabular}\par}%
      \vskip\baselineskip
      {\large\@date\par}%
    \end{center}\par
    \vfil{\centering\@thanks}\vfil\null
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
      \ifnum0\ifx\@oddhead\@empty\else1\fi\ifx\@evenhead\@empty\else1\fi>0
        \thispagestyle{plain}%
      \fi
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
    \lineskip .5\zh
    % 縦書き時には表組み内でも縦書きにするようにする
    \if@tate
      \let\jlreq@temporary@original@ialign=\ialign
      \pretocmd{\ialign}{\unexpanded{\tate\let\ialign=\jlreq@temporary@original@ialign}}{}{}%
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
\ifthenelse{\equal{\jlreq@article@type}{book}}{}{% article,report
  \newbox\jlreq@abstractbox
  \newcommand*{\abstractname}{概要}
  \if@titlepage
    % articleとかjarticleとかと同じ
    \newenvironment{abstract}{%
      \titlepage
      \null\vfil
      \@beginparpenalty\@lowpenalty
      \begin{center}%
        {\sffamily\bfseries\abstractname}%
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
        \parindent=1\zw
        \begin{center}%
          {\sffamily\bfseries\abstractname}%
        \end{center}%
        \list{}{%
          \listparindent\parindent
          \itemindent\listparindent
          \labelwidth\z@
          \labelsep\z@
          \leftmargin=2\zw
          \rightmargin\leftmargin
          \@tempdima=1\zw
          \@tempdimb=\dimexpr\linewidth - \@totalleftmargin - \leftmargin - \rightmargin\relax
          \@tempdimc=\@tempdimb
          \divide\@tempdimb by \@tempdima\multiply\@tempdimb by \@tempdima
          \ifdim\@tempdimb=\@tempdimc\else\@tempdimb=\dimexpr\@tempdimb - 1\zw\relax\fi
          \leftmargin=\dimexpr\leftmargin + (\@tempdimc - \@tempdimb)/2\relax
          \rightmargin=\dimexpr\rightmargin + (\@tempdimc - \@tempdimb)/2\relax
          \parsep\z@ \@plus.1\zh
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
  \setlength{\leftmargin}{0\zw}% 下げない
  \setlength{\labelwidth}{0\zw}%
  \setlength{\labelsep}{1\zw}
%  \addtolength{\leftmargin}{\leftskip}% たぶんこの二行いらない……
%  \addtolength{\leftmargin}{\labelsep}%
  \let\makelabel=\descriptionlabel
% 同行じゃない場合はこんな感じ？
%  \let\jlreq@original@@item=\@item
%  \def\@item[##1]{\jlreq@original@@item[##1]\mbox{}\par
  }}{\endlist}
\newcommand{\descriptionlabel}[1]{\normalfont\sffamily\bfseries #1}

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
        \@for\jlreq@tempa:=i,ii,iii,iv,v,vi\do{%
          \expandafter\@for\expandafter\jlreq@tempb\expandafter:\expandafter=\csname #1\endcsname\do{%
            \ifx\jlreq@tempb\@empty\else
              \eappto\jlreq@generalset{\noexpand\let\expandonce{\csname #2@\jlreq@tempa @\jlreq@tempb\endcsname}\noexpand\@undefined}%
            \fi
          }%
          \eappto\jlreq@generalset{%
            \noexpand\edef\expandonce{\csname #2@\jlreq@tempa\endcsname}{\unexpanded{\unexpanded{##1}}}%
          }%
        }%
        \appto\jlreq@generalset{\expandafter\def\csname #1\endcsname{}}%
      }{%
        \ifthenelse{\equal{##1}{i} \OR \equal{##1}{ii} \OR \equal{##1}{iii} \OR \equal{##1}{iv} \OR \equal{##1}{v} \OR \equal{##1}{vi}}{%
          % i=とかの時，環境に対応するものをクリアし，\#2@##1に値を入れる
          \expandafter\@for\expandafter\jlreq@tempa\expandafter:\expandafter=\csname #1\endcsname\do{
            \ifx\jlreq@tempa\@empty\else
              \epreto\jlreq@envset{\noexpand\let\expandonce{\csname #2@##1@\jlreq@tempa\endcsname}\noexpand\@undefined}%
            \fi
          }%
          \eappto\jlreq@envset{\noexpand\edef\expandonce{\csname #2@##1\endcsname}{\unexpanded{\unexpanded{##2}}}}%
        }{%
          % そうでないとき，環境．##1 = 環境名
          \jlreq@parsekeyval@nokey{%
            \ifjlreq@parsekeyval@nokey@novalue{%
              % i - viまでに全てセットする．
              \@for\jlreq@tempa:=i,ii,iii,iv,v,vi\do{%
                \epreto\jlreq@envset{\noexpand\edef\expandonce{\csname #2@\jlreq@tempa @##1\endcsname}{\unexpanded{\unexpanded{####1}}}}%
              }%
            }{%
              % ピンポイント代入
              \eappto\jlreq@envset{\noexpand\edef\expandonce{\csname #2@####1@##1\endcsname}{\unexpanded{\unexpanded{####2}}}}%
            }%
          }{##2}%
          \eappto\jlreq@envset{%
            \unexpanded{\def\jlreq@tempa{\jlreq@helper@removeelement{##1}}}%
            \unexpanded{\expandafter\jlreq@tempa\expandafter}{\expandonce{\csname #1\endcsname}}{\expandonce{\csname #1\endcsname}}%
            \noexpand\appto\expandonce{\csname #1\endcsname}{\unexpanded{,##1}}%
          }%
        }%
      }%
    }{#3}%
    \edef\jlreq@do{\expandonce{\jlreq@generalset}\expandonce{\jlreq@levelset}\expandonce{\jlreq@envset}}%
  \expandafter\endgroup
  \jlreq@do
}

\def\jlreq@itemization@beforeafter@space@envlist{}
\jlreq@jlreqsetup@add{itemization_beforeafter_space}{\jlreq@jlreqsetup@itemization{jlreq@itemization@beforeafter@space@envlist}{jlreq@itemization@beforeafter@space@setting}{#1}}
\jlreq@jlreqsetup@add{itemization_itemsep}{\jlreq@jlreqsetup@withenv{jlreq@itemization@itemsep@envlist}{jlreq@itemization@itemsep@setting}{#1}}
\jlreq@jlreqsetup@add{itemization_labelsep}{\jlreq@jlreqsetup@withenv{jlreq@itemization@labelsep@envlist}{jlreq@itemization@labelsep@setting}{#1}}
\jlreq@jlreqsetup@add{itemization_label_length}{\jlreq@jlreqsetup@itemization{jlreq@itemization@label@length@envlist}{jlreq@itemization@label@length@setting}{#1}}
% enumerate, itemize用初期化，#1 = i,ii,...
\def\jlreq@init@list#1{%
  \setlength{\partopsep}{0pt}%
  \setlength{\itemsep}{\dimexpr\jlreq@jlreqsetup@withenv@nameuse{jlreq@itemization@itemsep@setting}{\@currenvir}}%
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
\jlreq@jlreqsetup@add{quote_indent}{\def\jlreq@quote@indent{#1}}
\jlreq@jlreqsetup@add{quote_end_indent}{\def\jlreq@quote@end@indent{#1}}
\jlreq@jlreqsetup@add{quote_fontsize}[normalsize,small,footnotesize,scriptsize,tiny,]{\jlreq@ifempty{#1}{\def\jlreq@quote@fontsize{}}{\edef\jlreq@quote@fontsize{\expandonce{\csname #1\endcsname}}}}
\jlreq@jlreqsetup@add{quote_beforeafter_space}{\def\jlreq@quote@beforeafter@space{#1}}

\newenvironment{verse}
  {\let\\\@centercr
  \list{}{\itemsep\z@ \itemindent -2\jlreq@mol
    \listparindent\itemindent
    \labelwidth\z@
    \labelsep\z@
    \leftmargin=\dimexpr\jlreq@quote@indent\relax
    \addtolength{\leftmargin}{2\jlreq@mol}%
    \rightmargin=\dimexpr\jlreq@quote@end@indent\relax
    \jlreq@quote@fontsize
    \@tempdima=1\zw
    \@tempdimb=\dimexpr\linewidth - \@totalleftmargin - \leftmargin - \rightmargin\relax
    \@tempdimc=\@tempdimb
    \divide\@tempdimb by \@tempdima\multiply\@tempdimb by \@tempdima
    \topsep=\dimexpr\jlreq@quote@beforeafter@space\relax
    \leftmargin=\dimexpr\leftmargin + \@tempdimc - \@tempdimb\relax}%
    \item\relax}{\endlist}
\newenvironment{quotation}
  {\list{}{%
    \leftmargin=\dimexpr\jlreq@quote@indent\relax
    \rightmargin=\dimexpr\jlreq@quote@end@indent\relax
    \jlreq@quote@fontsize
    \@tempdima=1\zw
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
    \item\relax}{\endlist}
\newenvironment{quote}
  {\list{}{%
    \leftmargin=\dimexpr\jlreq@quote@indent\relax
    \rightmargin=\dimexpr\jlreq@quote@end@indent\relax
    \jlreq@quote@fontsize
    \@tempdima=1\zw
    \@tempdimb=\dimexpr\linewidth - \@totalleftmargin - \leftmargin - \rightmargin\relax
    \@tempdimc=\@tempdimb
    \divide\@tempdimb by \@tempdima\multiply\@tempdimb by \@tempdima
    \leftmargin=\dimexpr\leftmargin + \@tempdimc - \@tempdimb\relax
    \labelwidth\z@
    \itemindent\z@
    \topsep=\jlreq@speciallength{\jlreq@quote@beforeafter@space}%
    \listparindent\z@}%
    \item\relax}{\endlist}

%. 表関係 4.4
% 表内の行間を0にする（4.4.3.f）
\jlreq@saveoriginalcs{\tabular}
\jlreq@saveoriginalcs{\endtabular}
\preto\tabular{\begingroup\appto\@arrayparboxrestore{\baselineskip=0pt\lineskip=0pt}}
\appto\endtabular{\endgroup}
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
\ifthenelse{\equal{\jlreq@article@type}{article}}{%
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
\def\addcontentsline#1#2#3{%
  \protected@write\@auxout{%
    \let\label\@gobble\let\index\@gobble\let\glossary\@gobble
    \if@tate
      \@temptokena{\jlreq@rensuji{\thepage}}%
    \else
      \@temptokena{\thepage}%
    \fi
  }{\string\@writefile{#1}{\protect\contentsline{#2}{#3}{\the\@temptokena}}}%
}

\newcount\jlreq@top@contents % トップ見出しを入れる．レベルと同じ値．
\jlreq@top@contents=-100
\newcommand*{\jlreq@set@top@contents}[1]{%
  \ifnum\jlreq@top@contents=-100
    \jlreq@top@contents=#1\relax
  \fi
}
\ifthenelse{\equal{\jlreq@article@type}{article}}{
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
      \labelsep=1\zw
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
\if@tate
  \def\@cite#1#2{\jlreq@rensuji{[{#1\if@tempswa , #2\fi}]}}
  \def\@biblabel#1{\jlreq@rensuji{[#1]}}
\fi

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
\jlreq@jlreqsetup@add{theindex_pagestyle}{
  \def\jlreq@tempa{}% ページスタイル名
  \def\jlreq@theindex@pagestyle{}%
  \jlreq@tempafalse % restore
  \jlreq@parsekeyval@nokey{%
    \ifjlreq@parsekeyval@nokey@novalue{\def\jlreq@tempa{##1}}{%
      \jlreq@switch{##1}{%
        {restore}{\csname jlreq@tempa##2\endcsname}%
      }%
    }%
  }{#1}%
  \eappto\jlreq@theindex@pagestyle{\unexpanded{\let\jlreq@theindex@savedpagestyle}\ifjlreq@tempa\noexpand\jlreq@current@pagestyle\else\noexpand\@undefined\fi}%
  \ifx\jlreq@tempa\@empty\else
    \eappto\jlreq@theindex@pagestyle{\noexpand\pagestyle{\expandonce{\jlreq@tempa}}}%
  \fi
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
          \eappto\jlreq@headingsettings{\unexpanded{####1}}%
        }{%
          \jlreq@switch{####1}{%
            {heading_type}{%
              \lowercase{\def\jlreq@tempa{####2}}%
              \jlreq@switch{\jlreq@tempa}{
                {tobira}{\def\jlreq@declaretype{RenewTobira}}
                {block}{\def\jlreq@declaretype{RenewBlock}}
                {runin}{\def\jlreq@declaretype{RenewRunin}}
                {cutin}{\def\jlreq@declaretype{RenewCutin}}
                {modify}{\def\jlreq@declaretype{Modify}}
                {\ClassError{jlreq}{Unknown heading type `####2'}{\@ehc}}
              }%
            }
            {heading_level}{\def\jlreq@level{####2}}
            {%
              \jlreq@ifempty{#1}{\@firstofone}{%
                \ifthenelse{\equal{####1}{restore}}{%
                  \csname jlreq@tempa####2\endcsname\@gobble
                }{\@firstofone}%
              }%
              {\eappto\jlreq@headingsettings{\ifx\jlreq@headingsettings\@empty\else ,\fi\unexpanded{####1={####2}}}}%
            }%
          }%
        }%
      }{##2}%
      \jlreq@ifempty{#1}{}{%
        \ifjlreq@tempa
          \eappto\jlreq@headingscmds{\noexpand\SaveHeading{\unexpanded{##1}}{\expandonce{\csname #2@##1\endcsname}}}%
          \eappto\jlreq@restoreheadings{\ifx\jlreq@restoreheadings\@empty\else ,\fi\unexpanded{##1}}%
        \fi
      }%
      % \jlreq@declareに\ModifyHeadingか\Renew***Headingを入れる
      \edef\jlreq@declare{\expandonce{\csname\jlreq@declaretype Heading\endcsname}{##1}}%
      \ifthenelse{\NOT \equal{\jlreq@declaretype}{Modify}}{%
        \ifx\jlreq@level\@empty
          % \frontmatter時でのレベルを引用する．
          \edef\jlreq@declare{%
            \unexpanded{\edef\jlreq@tempa}{\noexpand\unexpanded{\expandonce{\jlreq@declare}}{\noexpand\expandonce{\expandonce{\csname jlreq@heading@level@##1\endcsname}}}}%
            \noexpand\jlreq@tempa
          }%
        \else
          \eappto\jlreq@declare{{\expandonce{\jlreq@level}}}%
        \fi
      }{}%
      \eappto\jlreq@headingscmds{\expandonce{\jlreq@declare}{\expandonce{\jlreq@headingsettings}}}%
    }{#4}%
    \edef\jlreq@do{%
      \unexpanded{\def#3}{%
        \expandonce{\jlreq@headingscmds}%
        \jlreq@ifempty{#1}{}{\unexpanded{\def#1}{\expandonce{\jlreq@restoreheadings}}}%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\def\jlreq@matter@counter@norestore#1#2{%
  \def#1{}%
  \jlreq@parsekeyval@nokey{%
    \jlreq@parsekeyval*{
      {value}{\appto#1{\setcounter{##1}{####1}}}
      {the}{\eappto#1{\noexpand\def\expandonce{\csname the##1\endcsname}{\unexpanded{####1}}}}
    }{##2}%
  }{#2}%
}

\ifthenelse{\equal{\jlreq@article@type}{book}}{
  \newif\if@mainmatter
  \@mainmattertrue
  \jlreq@jlreqsetup@add{frontmatter_pagebreak}{%
    \edef\jlreq@frontmatter@pagebreak{\jlreq@ifempty{#1}{}{\expandonce{\csname #1\endcsname}}}%
  }
  \jlreq@jlreqsetup@add{frontmatter_counter}{%
    \def\jlreq@frontmatter@counter{}%
    \def\jlreq@tempa{}% 復帰させるカウンタ名リスト
    \jlreq@parsekeyval@nokey{%
      \def\jlreq@tempb{}% 中身
      \jlreq@tempatrue % restore
      \jlreq@parsekeyval{
        {value}{\appto\jlreq@tempb{\setcounter{##1}{####1}}}
        {restore}{\csname jlreq@tempa####1\endcsname}
        {the}{\eappto\jlreq@tempb{\noexpand\def\expandonce{\csname the##1\endcsname}{\unexpanded{####1}}}}
      }{##2}%
      \ifjlreq@tempa
        \epreto\jlreq@tempb{%
          \noexpand\let\expandonce{\csname jlreq@frontmatter@savedcounter@the@##1\endcsname}\expandonce{\csname the##1\endcsname}%
          \noexpand\edef\expandonce{\csname jlreq@frontmatter@savedcounter@value@##1\endcsname}{\unexpanded{\the\value{##1}}}%
        }%
        \eappto\jlreq@tempa{\ifx\jlreq@tempa\@empty\else ,\fi\unexpanded{##1}}%
      \fi
      \eappto\jlreq@frontmatter@counter{\expandonce{\jlreq@tempb}}%
    }{#1}%
    \eappto\jlreq@frontmatter@counter{\unexpanded{\def\jlreq@frontmatter@restorecounters}{\expandonce{\jlreq@tempa}}}%
  }
  \jlreq@jlreqsetup@add{frontmatter_heading}{\jlreq@matter@heading[\jlreq@frontmatter@restoreheadings]{jlreq@frontmatter@savedheading}{\jlreq@frontmatter@heading}{#1}}
  \jlreq@jlreqsetup@add{frontmatter_pagestyle}{%
    \def\jlreq@tempa{}% ページスタイル名
    \def\jlreq@frontmatter@pagestyle{}%
    \jlreq@tempatrue % restore
    \jlreq@parsekeyval@nokey{%
      \ifjlreq@parsekeyval@nokey@novalue{\def\jlreq@tempa{##1}}{%
        \jlreq@switch{##1}{%
          {restore}{\csname jlreq@tempa##2\endcsname}%
        }%
      }%
    }{#1}%
    \ifjlreq@tempa
      \appto\jlreq@frontmatter@pagestyle{\let\jlreq@frontmatter@savedpagestyle\jlreq@current@pagestyle}%
    \fi
    \ifx\jlreq@tempa\@empty\else
      \eappto\jlreq@frontmatter@pagestyle{\noexpand\pagestyle{\expandonce{\jlreq@tempa}}}%
    \fi
  }
  \jlreq@jlreqsetup@add{frontmatter_precode}{\edef\jlreq@frontmatter@precode{\unexpanded{#1}}}
  \jlreq@jlreqsetup@add{frontmatter_postcode}{\edef\jlreq@frontmatter@postcode{\unexpanded{#1}}}
  \jlreq@jlreqsetup@add{frontmatter_pagination}{%
    \def\jlreq@pagination@frontmatterstyle{arabic}%
    \let\jlreq@pagination@mainmatterpagecommand=\pagenumbering
    \@for\jlreq@tempa:=#1\do{%
      \expandafter\jlreq@helper@trim\expandafter{\jlreq@tempa}{\jlreq@tempa}%
      \jlreq@switch{\jlreq@tempa}{
        {continuous}{%
          \def\jlreq@pagination@mainmatterpagecommand##1{\gdef\thepage{\csname @##1\endcsname\c@page}}%
        }
        {independent}{\let\jlreq@pagination@mainmatterpagecommand=\pagenumbering}
        {\edef\jlreq@pagination@frontmatterstyle{\jlreq@tempa}}
      }%
    }%
  }
  \newcommand*{\frontmatter}{%
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
  \def\jlreq@frontmatter@restorecounters{}
  \def\jlreq@frontmatter@restoreheadings{}
  \def\jlreq@frontmatter@restorecommands{}
  \jlreq@jlreqsetup@add{mainmatter_pagebreak}{%
    \edef\jlreq@mainmatter@pagebreak{\jlreq@ifempty{#1}{}{\expandonce{\csname #1\endcsname}}}%
  }
  \jlreq@jlreqsetup@add{mainmatter_pagestyle}{%
    \edef\jlreq@mainmatter@pagestyle{\jlreq@ifempty{#1}{}{\unexpanded{\pagestyle{#1}}}}%
  }
  \jlreq@jlreqsetup@add{mainmatter_counter}{\jlreq@matter@counter@norestore{\jlreq@mainmatter@counter}{#1}}%
  \jlreq@jlreqsetup@add{mainmatter_heading}{\jlreq@matter@heading{\jlreq@mainmatter@heading}{#1}}%
  \jlreq@jlreqsetup@add{mainmatter_precode}{\edef\jlreq@mainmatter@precode{\unexpanded{#1}}}%
  \jlreq@jlreqsetup@add{mainmatter_postcode}{\edef\jlreq@mainmatter@postcode{\unexpanded{#1}}}%
  \jlreq@jlreqsetup@add{mainmatter_pagination}{%
    \def\jlreq@pagination@mainmatterstyle{#1}%
  }
  \newcommand*{\mainmatter}{%
    \jlreq@mainmatter@precode
    \jlreq@mainmatter@pagebreak
    \@mainmattertrue
    \@ifundefined{jlreq@frontmatter@savedpagestyle}{%
      \jlreq@mainmatter@pagestyle
    }{%
      \expandafter\pagestyle\expandafter{\jlreq@frontmatter@savedpagestyle}%
    }%
    \@for\jlreq@tempa:=\jlreq@frontmatter@restorecounters\do{%
      \setcounter{\jlreq@tempa}{\csname jlreq@frontmatter@savedcounter@value@\jlreq@tempa\endcsname}%
      \expandafter\let\csname the\jlreq@tempa\expandafter\endcsname\csname jlreq@frontmatter@savedcounter@the@\jlreq@tempa\endcsname
    }%
    \jlreq@mainmatter@counter
    \@for\jlreq@tempa:=\jlreq@frontmatter@restoreheadings\do{\csname jlreq@frontmatter@savedheading@\jlreq@tempa\endcsname}
    \jlreq@mainmatter@heading
    \@for\jlreq@tempa:=\jlreq@frontmatter@restorecommands\do{%
      \expandafter\let\csname \jlreq@tempa\expandafter\endcsname\csname jlreq@frontmatter@savedcommand@\jlreq@tempa\endcsname
    }%
    \expandafter\jlreq@pagination@mainmatterpagecommand\expandafter{\jlreq@pagination@mainmatterstyle}%
    \jlreq@mainmatter@postcode
  }
  \jlreq@jlreqsetup@add{backmatter_pagebreak}{%
    \edef\jlreq@backmatter@pagebreak{\jlreq@ifempty{#1}{}{\expandonce{\csname #1\endcsname}}}%
  }
  \jlreq@jlreqsetup@add{backmatter_pagestyle}{%
    \edef\jlreq@backmatter@pagestyle{\jlreq@ifempty{#1}{}{\unexpanded{\pagestyle{#1}}}}%
  }
  \jlreq@jlreqsetup@add{backmatter_counter}{\jlreq@matter@counter@norestore{\jlreq@backmatter@counter}{#1}}%
  \jlreq@jlreqsetup@add{backmatter_heading}{\jlreq@matter@heading{\jlreq@backmatter@heading}{#1}}
  \jlreq@jlreqsetup@add{backmatter_precode}{\edef\jlreq@backmatter@precode{\unexpanded{#1}}}
  \jlreq@jlreqsetup@add{backmatter_postcode}{\edef\jlreq@backmatter@postcode{\unexpanded{#1}}}
  \jlreq@jlreqsetup@add{backmatter_pagination}{
    \let\jlreq@pagination@backmatterpagecommand=\pagenumbering
    \def\jlreq@pagination@backmatterstyle{arabic}%
    \@for\jlreq@tempa:=#1\do{%
      \expandafter\jlreq@helper@trim\expandafter{\jlreq@tempa}{\jlreq@tempa}%
      \jlreq@switch{\jlreq@tempa}{
        {continuous}{%
          \def\jlreq@pagination@backmatterpagecommand##1{\gdef\thepage{\csname @##1\endcsname\c@page}}%
        }
        {independent}{\let\jlreq@pagination@backmatterpagecommand=\pagenumbering}
        {\edef\jlreq@pagination@backmatterstyle{\jlreq@tempa}}
      }%
    }%
  }
  \newcommand*{\backmatter}{%
    \jlreq@backmatter@precode
    \jlreq@backmatter@pagebreak
    \jlreq@backmatter@pagestyle
    \@mainmatterfalse
    \jlreq@backmatter@counter
    \jlreq@backmatter@heading
    \expandafter\jlreq@pagination@backmatterpagecommand\expandafter{\jlreq@pagination@backmatterstyle}%
    \jlreq@backmatter@postcode
  }
}{}

\jlreq@jlreqsetup@add{appendix_counter}{\jlreq@matter@counter@norestore{\jlreq@appendix@counter}{#1}}
\jlreq@jlreqsetup@add{appendix_heading}{\jlreq@matter@heading{\jlreq@appendix@heading}{#1}}
\jlreq@jlreqsetup@add{appendix_precode}{\edef\jlreq@appendix@precode{\unexpanded{#1}}}
\jlreq@jlreqsetup@add{appendix_postcode}{\edef\jlreq@appendix@postcode{\unexpanded{#1}}}
\newcommand*{\appendix}{%
  \par
  \jlreq@appendix@precode
  \jlreq@appendix@counter
  \jlreq@appendix@heading
  \jlreq@appendix@postcode
}

%. その他諸々
%.. 縦中横
\edef\@tempa{%
  \unexpanded{%
    \jlreq@ifydir{\ClassError{jlreq}{\string\tatechuyoko\space is not allowed in yoko mode}{\@ehc}}{}%
    \ifvmode\leavevmode\fi
  }%
  \ifx l\jlreq@engine\unexpanded{%
    \jlreq@lastnodechar=\lastnodechar\relax
    \ifnum\jlreq@lastnodechar>-1 \inhibitglue\fi
  }\else\unexpanded{%
    \ifnum\lastnodechar>-1 \inhibitglue\fi
    \jlreq@lastnodechar=\lastnodechar\relax
  }\fi
}

\expandafter\protected\expandafter\def\expandafter\tatechuyoko\expandafter#\expandafter1\expandafter{%
  \@tempa
  % 前のJFM glue
  \ifnum\jlreq@lastnodechar>-1
    \jlreq@calc@jfmglue{\char\jlreq@lastnodechar}{阿}%
    \jlreq@ifgluezero\jlreq@resultskip{}{\hskip\jlreq@resultskip}%
  \fi
  \hbox{\yoko 
    \setbox\jlreq@tempboxa=\hbox{阿}%
    \vrule width 0pt height \ht\jlreq@tempboxa depth \dp\jlreq@tempboxa #1}%
  \futurelet\jlreq@nextchar\jlreq@tatechuyoko@
}
\def\jlreq@tatechuyoko@{%
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

% 日にち
\newif\if西暦
\def\西暦{\西暦true}
\def\和暦{\西暦false}
% #1年#2月#3日 #4は\numberとか\kansujiとか
\def\jlreq@wareki#1#2#3#4{%
  \jlreq@warekiyear{#1}{#2}{#3}{#4}%
  #4#2月#4#3日%
}
\def\jlreq@warekiyear#1#2#3#4{%
  % 昭和：1989年1月7日まで
  \ifnum0\ifnum#1<1989 1\fi\ifnum#1=1989 \ifnum#2=1 \ifnum#3<8 1\fi\fi\fi>0
    昭和\jlreq@warekiyear@{#1}{1926}{#4}%
  % 平成：2019年4月末日まで
  \else\ifnum0\ifnum#1<2019 1\fi\ifnum#1=2019 \ifnum#2<5 1\fi\fi>0
    平成\jlreq@warekiyear@{#1}{1989}{#4}%
  \else
    令和\jlreq@warekiyear@{#1}{2019}{#4}%
  \fi\fi
}
\def\jlreq@warekiyear@#1#2#3{\ifnum#1=#2 元年\else #3\numexpr#1-#2+1\relax 年\fi}
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
\jlreq@jlreqsetup@add{year_style}[seireki,wareki]{%
  \jlreq@switch{#1}{%
    {seireki}{\西暦true}
    {wareki}{\西暦false}
  }
}

% 時刻
\hour=\time \divide\hour by 60
\minute=\numexpr\time - 60*\hour\relax

%.. 定理環境
\jlreq@saveoriginalcs{\@begintheorem}
\jlreq@saveoriginalcs{\@opargbegintheorem}
\def\@begintheorem#1#2{\topsep=\dimexpr\jlreq@theorem@beforeafter@space\relax
  \trivlist\labelsep=1\zw
  \itemindent=\dimexpr\jlreq@theorem@indent\relax
   \item[\hskip \labelsep{\sffamily\bfseries #1\ #2}]}
\def\@opargbegintheorem#1#2#3{\topsep=\dimexpr\jlreq@theorem@beforeafter@space\relax
  \trivlist\labelsep=1\zw
  \itemindent=\dimexpr\jlreq@theorem@indent\relax
  \item[\hskip \labelsep{\sffamily\bfseries #1\ #2（#3）}]}
\AtEndOfPackageFile*{amsthm}{%
  \jlreq@saveoriginalcs{\proof}%
  \jlreq@saveoriginalcs{\endproof}%
  \edef\jlreq@do{
    \unexpanded{\def\jlreq@proof[#1]}{%
      \unexpanded{\labelsep=1\zw}%
      \expandonce{\proof[{\reset@font\sffamily\bfseries #1\inhibitglue}\nopunct]}%
    }
  }
  \jlreq@do
  \def\proof{\@ifnextchar[{\jlreq@proof}{\jlreq@proof[\proofname]}}
  \renewcommand{\proofname}{証明}
  \jlreq@setupamsthm
  \theoremstyle{jlreq}
}
\def\jlreq@setupamsthm{
  \newtheoremstyle{jlreq}{\dimexpr\jlreq@theorem@beforeafter@space\relax}{\dimexpr\jlreq@theorem@beforeafter@space\relax}{\normalfont}{\dimexpr\jlreq@theorem@indent\relax}{\sffamily\bfseries}{}{1\zw}{\thmname{##1}\thmnumber{\ ##2}\thmnote{（##3）}}
}
\jlreq@jlreqsetup@add{theorem_beforeafter_space}{
  \def\jlreq@theorem@beforeafter@space{#1}
  \@ifpackageloaded{amsthm}{\jlreq@setupamsthm}{}
}
\jlreq@jlreqsetup@add{theorem_indent}{
  \def\jlreq@theorem@indent{#1}
  \@ifpackageloaded{amsthm}{\jlreq@setupamsthm}{}
}


%. デフォルト設定
%.. 見出し
\if@tate
  \renewcommand{\thepart}{\jlreq@Kanji{part}}
  \ifthenelse{\equal{\jlreq@article@type}{article}}{}{\renewcommand{\thechapter}{\jlreq@Kanji{chapter}}}
  \renewcommand{\thesection}{\jlreq@rensuji{\@arabic\c@section}}
  \renewcommand{\thesubsection}{\jlreq@rensuji{\@alph\c@subsection}}
  \renewcommand{\thesubsubsection}{\jlreq@rensuji{\@arabic\c@subsubsection}}
  \renewcommand{\theparagraph}{(\jlreq@rensuji{\@arabic\c@paragraph})}
  \renewcommand{\thesubparagraph}{(\jlreq@rensuji{\@arabic\c@subparagraph})}

  \ifthenelse{\equal{\jlreq@article@type}{article}}{
    \NewBlockHeading{part}{0}{font={\jlreq@keepbaselineskip{\LARGE}},indent=4\zw,lines=4,after_label_space=1\zw,second_heading_text_indent={-1\zw,1\zw},subtitle_font={\jlreq@keepbaselineskip{\large}}}
    \if@twoside\ModifyHeading{part}{allowbreak_if_evenpage=true}\fi
  }
  {% book, report
    \NewTobiraHeading{part}{-1}{label_format={第\thepart 部\hspace*{1\zw}},format={\null\vfill {\Huge\hspace*{2\zw}#1#2}\vspace*{2\jlreq@gol}}}
    \NewBlockHeading{chapter}{0}{indent=2\zw,lines=6,label_format={第\thechapter 章},font={\huge},after_label_space=1\zw,second_heading_text_indent={-1\zw,1\zw},subtitle_font={\jlreq@keepbaselineskip{\Large}}}
    \if@twoside\ModifyHeading{chapter}{allowbreak_if_evenpage=true}\fi
    \renewcommand{\thechapter}{\jlreq@Kanji{chapter}}
  }
  \NewBlockHeading{section}{1}{font={\jlreq@keepbaselineskip{\Large}},indent=6\zw,lines=3,after_label_space=1\zw,second_heading_text_indent={-1\zw,1\zw},subtitle_font={\jlreq@keepbaselineskip{\normalsize}}}
  \if@twoside\ModifyHeading{section}{allowbreak_if_evenpage=true}\fi
  \NewBlockHeading{subsection}{2}{font={\jlreq@keepbaselineskip{\large}},indent=8\zw,lines=2,after_label_space=1\zw,second_heading_text_indent={-1\zw,1\zw},subtitle_font={\jlreq@keepbaselineskip{\small}}}
  \if@twoside\ModifyHeading{subsection}{allowbreak_if_evenpage=true}\fi
  \NewBlockHeading{subsubsection}{3}{font={\jlreq@keepbaselineskip{\normalsize}},indent=10\zw,lines=1,before_lines=1,subtitle_break=false,after_label_space=1\zw,second_heading_text_indent={-1\zw,1\zw},,subtitle_font={\jlreq@keepbaselineskip{\scriptsize}}}
  \if@twoside\ModifyHeading{subsubsection}{allowbreak_if_evenpage=true}\fi
  \NewRuninHeading{paragraph}{4}{font={\jlreq@keepbaselineskip{\normalsize}}}
  \NewRuninHeading{subparagraph}{5}{font={\jlreq@keepbaselineskip{\normalsize}},indent=1\zw}
\else% yoko
  \renewcommand{\thepart}{\Roman{part}}
  \renewcommand{\thesubsection}{\thesection .\arabic{subsection}}
  \renewcommand{\thesubsubsection}{\thesubsection .\arabic{subsubsection}}
  \renewcommand{\theparagraph}{\thesubsubsection .\arabic{paragraph}}
  \renewcommand{\thesubparagraph}{\theparagraph .\arabic{subparagraph}}
  \ifthenelse{\equal{\jlreq@article@type}{article}}{
    \NewBlockHeading{part}{0}{font={\jlreq@keepbaselineskip{\LARGE\sffamily\bfseries}},label_format={第\thepart 部},lines=4,after_label_space=1\zw,second_heading_text_indent={-1\zw,1\zw},subtitle_font={\jlreq@keepbaselineskip{\large}}}
    \renewcommand{\thesection}{\arabic{section}}
  }
  {% book, report
    \NewTobiraHeading{part}{-1}{label_format={第\thepart 部\hspace*{1\jlreq@gol}},format={\null\vfil {\Huge\sffamily\bfseries #1#2}\vfil}}
    \NewBlockHeading{chapter}{0}{%
      font={\jlreq@keepbaselineskip{\huge\sffamily\bfseries}},
      label_format={第\thechapter 章},
      lines=5,after_label_space=1\zw,second_heading_text_indent={-1\zw,1\zw},
      subtitle_font={\jlreq@keepbaselineskip{\Large}}}
    \renewcommand{\thechapter}{\arabic{chapter}}
    \renewcommand{\thesection}{\thechapter.\arabic{section}}
  }
  \NewBlockHeading{section}{1}{font={\jlreq@keepbaselineskip{\Large\sffamily\bfseries}},lines=3,after_label_space=1\zw,second_heading_text_indent={-1\zw,1\zw},subtitle_font={\jlreq@keepbaselineskip{\normalsize}}}
  \NewBlockHeading{subsection}{2}{font={\jlreq@keepbaselineskip{\large\sffamily\bfseries}},lines=2,after_label_space=1\zw,second_heading_text_indent={-1\zw,1\zw},subtitle_font={\jlreq@keepbaselineskip{\small}}}
  \NewBlockHeading{subsubsection}{3}{font={\jlreq@keepbaselineskip{\normalsize\sffamily\bfseries}},lines=1,before_lines=1,subtitle_break=false,after_label_space=1\zw,second_heading_text_indent={-1\zw,1\zw},subtitle_font={\jlreq@keepbaselineskip{\scriptsize}}}
  \NewRuninHeading{paragraph}{4}{font={\jlreq@keepbaselineskip{\normalsize\sffamily\bfseries}},indent=1\zw}
  \NewRuninHeading{subparagraph}{5}{font={\jlreq@keepbaselineskip{\normalsize\sffamily\bfseries}},indent=2\zw}
\fi

\ifthenelse{\equal{\jlreq@article@type}{article}}{}{% book, report
  \if@openright
    \ModifyHeading{part}{type=naka}
    \if@tate
      \ModifyHeading{chapter}{pagebreak=begin_with_even_page}
    \else
      \ModifyHeading{chapter}{pagebreak=begin_with_odd_page}
    \fi
  \else
    \ModifyHeading{part}{type=han}
    \ModifyHeading{chapter}{pagebreak=clearpage}
  \fi
}

%.. ページスタイル
\RenewPageStyle{empty}{nombre={},odd_running_head={},even_running_head={}}
\ifthenelse{\equal{\jlreq@article@type}{article}}{
  \if@twoside
    \NewPageStyle{headings}{odd_running_head={_subsection},even_running_head={_section}}
  \else
    \NewPageStyle{headings}{odd_running_head={_section},even_running_head={}}
  \fi
}{% book, article
  \if@twoside
    \NewPageStyle{headings}{odd_running_head={_section},even_running_head={_chapter}}
  \else
    \NewPageStyle{headings}{odd_running_head={_chapter},even_running_head={}}
  \fi
  \ModifyPageStyle{headings}{mark_format={_chapter={第\thechapter 章\quad #1}}}
}
\if@tate
  \RenewPageStyle{plain}{nombre=\thepage,odd_running_head={},even_running_head={},clear_markcommand=false}
  \NewPageStyle{myheadings}{nombre=\thepage,odd_running_head=\rightmark,even_running_head=\leftmark,clear_markcommand=false}
  \if@twoside
    \ModifyPageStyle{plain}{nombre_position={top-left}}
    \ModifyPageStyle{headings}{nombre=\thepage,nombre_position=bottom-left,running_head_position=top-left}
    \ModifyPageStyle{myheadings}{nombre_position=bottom-left,running_head_position=top-left}
  \else
    \ModifyPageStyle{plain}{nombre_position={top-center}}
    \ModifyPageStyle{headings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center}
    \ModifyPageStyle{myheadings}{nombre_position=bottom-center,running_head_position=top-center}
  \fi
\else% yoko
  \RenewPageStyle{plain}{nombre=\thepage,odd_running_head={},even_running_head={},nombre_position={bottom-center},clear_markcommand=false}
  \ModifyPageStyle{headings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center}
  \NewPageStyle{myheadings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center,odd_running_head=\rightmark,even_running_head=\leftmark,clear_markcommand=false}
\fi
\ModifyPageStyle{plain}{font=\small}
\ModifyPageStyle{headings}{font=\small}
\ModifyPageStyle{myheadings}{font=\small}

%.. 注
\jlreqsetup{reference_mark=inline}
\if@tate
  \jlreqsetup{footnote_indent=1\zw}% 根拠なし
\else
  \jlreqsetup{footnote_indent=0pt}% （4.2.5.b）
\fi
\jlreqsetup{footnote_second_indent=1\zw}
\jlreqsetup{endnote_second_indent=2\zw}
\jlreqsetup{endnote_position=headings}
\ifdim\marginparwidth>0pt
  \jlreqsetup{sidenote_type=number}
  \jlreqsetup{sidenote_symbol=＊,sidenote_keyword_font={}}
\fi

%.. キャプション
\jlreqsetup{
  caption_font={\sffamily\bfseries},
  caption_label_font={\sffamily\bfseries},
  caption_after_label_space=1\zw,
  caption_label_format={#1},
  caption_align=center
}

%.. 箇条書き
\if@tate
  \renewcommand{\theenumi}{\jlreq@Kanji{enumi}}
  \renewcommand{\theenumii}{\jlreq@rensuji{\@arabic\c@enumii}}
  \renewcommand{\theenumiii}{\jlreq@rensuji{\@arabic\c@enumiii}}
  \renewcommand{\theenumiv}{\jlreq@rensuji{\@arabic\c@enumiv}}
  \newcommand{\labelenumi}{\theenumi}
  \newcommand{\labelenumii}{\theenumii}
  \newcommand{\labelenumiii}{\theenumiii}
  \newcommand{\labelenumiv}{\theenumiv}
\else
  \renewcommand{\theenumi}{\@arabic\c@enumi}
  \renewcommand{\theenumii}{\@alph\c@enumii}
  \renewcommand{\theenumiii}{\@roman\c@enumiii}
  \renewcommand{\theenumiv}{\@Alph\c@enumiv}
  \newcommand{\labelenumi}{\theenumi.\hspace{.5\zw}}
  \newcommand{\labelenumii}{(\theenumii)\hspace{.5\zw}}
  \newcommand{\labelenumiii}{\theenumiii.\hspace{.5\zw}}
  \newcommand{\labelenumiv}{\theenumiv.\hspace{.5\zw}}
\fi
\renewcommand{\p@enumii}{\theenumi}
\renewcommand{\p@enumiii}{\theenumi(\theenumii)}
\renewcommand{\p@enumiv}{\p@enumiii\theenumiii}

\newcommand{\labelitemi}{\hbox to 1\zw{\hss\textbullet\hss}}
%\newcommand{\labelitemi}{•}
\if@tate
  \newcommand{\labelitemii}{○}
  \newcommand{\labelitemiii}{＊}
\else
  \newcommand{\labelitemii}{\hbox to 1\zw{\hss\textendash\hss}}
  \newcommand{\labelitemiii}{\hbox to 1\zw{\hss\textasteriskcentered\hss}}
\fi
\newcommand{\labelitemiv}{\hbox to 1\zw{\hss ・\hss}}

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
  itemization_label_length={1\zw,i=2\zw,ii=2\zw}
}

%.. 引用
\jlreqsetup{
  quote_indent=2\zw,
  quote_end_indent=0pt,
  quote_fontsize=,
  quote_beforeafter_space=0pt
}

%.. その他
\ifthenelse{\equal{\jlreq@article@type}{book}}{
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
  \if@openright
    \jlreqsetup{backmatter_pagebreak=cleardoublepage}
  \else
    \jlreqsetup{backmatter_pagebreak=clearpage}
  \fi
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
}{}
\ifthenelse{\equal{\jlreq@article@type}{article}}{
  \if@tate
    \jlreqsetup{
      appendix_counter = {
        section = {value = 0, the = {\jlreq@rensuji{\Alph{section}}}},
        subsection = {value = 0},
      }
    }
  \else
    \jlreqsetup{
      appendix_counter = {
        section = {value = 0, the = {\Alph{chapter}}},
        subsection = {value = 0},
      }
    }
  \fi
 \jlreqsetup{appendix_heading = {},appendix_precode = {},appendix_postcode = {}}
}{%book, report
  \if@tate
    \jlreqsetup{
      appendix_counter = {
        chapter = {value = 0, the = {\jlreq@rensuji{\Alph{chapter}}}},
      }
    }
 \else
    \jlreqsetup{
      appendix_counter = {
        chapter = {value = 0, the = {\Alph{chapter}}},
      }
    }
 \fi
 \jlreqsetup{
   appendix_heading = {
     chapter = {label_format = {付録\thechapter}}
   },
   appendix_postcode = {%
     \ifthenelse{\equal{\jlreq@current@pagestyle}{headings}}{%
       \def\chaptermark#1{\markboth{付録\thechapter\quad #1}{}}%
       \ModifyPageStyle{headings}{mark_format={_chapter={付録\thechapter\quad #1}}}%
     }{}%
   },
   appendix_precode = {}
 }
}
\jlreqsetup{theindex_pagestyle=plain}
\jlreqsetup{year_style=seireki}
\jlreqsetup{theorem_beforeafter_space=1\baselineskip,theorem_indent=0pt}


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
\endinput


