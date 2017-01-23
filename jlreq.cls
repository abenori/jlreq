% JLREQ 20120403 https://www.w3.org/TR/2012/NOTE-jlreq-20120403/ja/ に基づく

%#main jlreqtest.tex
%%#T2D uplatex
%%#! $(C:TeXToDVI) ; $(C:DVIToPDF)
%%#! lualatex
%%#! lualatex -synctex=-1 jlreqtest.tex ; pdftk jlreqtest.pdf multistamp onlya.pdf output out.pdf
%#! uplatex -synctex=-1 jlreqtest.tex ; dvipdfmx jlreqtest.dvi ; pdftk jlreqtest.pdf multistamp onlya.pdf output out.pdf
%#PDF out.pdf
% memo
% 欧文文字の向きについて (2.3.2.b.1)
% 割注
% タブ処理
% 振分け処理
% 表
\showboxdepth=100
\showboxbreadth=1000
%\tracingonline=1

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jlreq}[2016/01/01 jlreq]
\RequirePackage{xkeyval,everyhook,filehook,etoolbox,ifthen}

%. helper1
\newdimen\jlreq@tempdima
\newdimen\jlreq@tempdimb
\newdimen\jlreq@tempdimc
\newskip\jlreq@tempskipa
\newskip\jlreq@tempskipb
\newskip\jlreq@tempskipc
\newif\ifjlreq@tempa
\newif\ifjlreq@tempb
\newif\ifjlreq@tempc
\newbox\jlreq@tempboxa
\newbox\jlreq@tempboxb
\newbox\jlreq@tempboxc
% 計算結果を返すための変数
\newdimen\jlreq@resultdimen
\newbox\jlreq@resultbox

\def\jlreq@uniqtoken{\jlreq@uniqtoken}
\def\jlreq@endmark{\jlreq@endmark}

% #1内の#2を#3に変換し#4に入れる
\def\jlreq@replace#1#2#3#4{%
  \begingroup
    \def\jlreq@do##1#2##2\jlreq@endmark{%
      \ifx\jlreq@endmark##2\jlreq@endmark##1\else##1#3\jlreq@do##2\jlreq@endmark\fi
    }%
    \edef\jlreq@do{\unexpanded{\def#4}{\jlreq@do#1#2\jlreq@endmark}}%
  \expandafter\endgroup
  \jlreq@do
}

% @removeelementの括弧があっても動くかもしれない版
% 次の変数を使う：\jlreq@tempa：消したいやつ，\jlreq@tempb：今処理している部分．
\def\jlreq@helper@removeelement#1#2#3{%
  \begingroup
    \def\jlreq@tempb{}%
    \def\jlreq@tempa{#1}%
    \def#3{}%
    \jlreq@helper@removeelement@#3#2{\jlreq@endmark}%
    \edef\jlreq@do{\unexpanded{\def#3}{\expandonce{#3}}}%
  \expandafter\endgroup
  \jlreq@do
}
% 最初のグルーピングの前までを取得し，@@に回す．グルーピング以降は@@@で処理する
\def\jlreq@helper@removeelement@#1#2#{%
  \jlreq@helper@removeelement@@{#1}{#2}%
  \jlreq@helper@removeelement@@@{#1}%
}
% #1をカンマで区切り，既に得ていた\jlreq@tempbと併せて一つの部分を作る．
\def\jlreq@helper@removeelement@@#1#2{%
  \jlreq@helper@dividebycomma{#2}%
  \edef\jlreq@tempb{\expandonce{\jlreq@tempb}\expandonce{\jlreq@tempc}}%
  \ifjlreq@tempa
    \ifx\jlreq@tempa\jlreq@tempb\else
      \ifx#1\@empty\edef#1{\expandonce{\jlreq@tempb}}%
      \else\edef#1{\expandonce{#1},\expandonce{\jlreq@tempb}}\fi
    \fi
    \def\jlreq@tempb{}%
    \expandafter\jlreq@helper@removeelement@@\expandafter#1\expandafter{\jlreq@tempd}%
  \fi
}
% グルーピング部分を\jlreq@tempbに加え，@に戻る
\def\jlreq@helper@removeelement@@@#1#2{%
  \ifx\jlreq@endmark#2%
    % 全体の解釈が終わった
    \ifx\jlreq@tempa\jlreq@tempb\else
      \ifx#1\@empty\edef#1{\expandonce{\jlreq@tempb}}%
      \else\edef#1{\expandonce{#1},\expandonce{\jlreq@tempb}}\fi
    \fi
  \else
    \edef\jlreq@tempb{\expandonce{\jlreq@tempb}{#2}}%
    \def\jlreq@next{\jlreq@helper@removeelement@{#1}}%
    \expandafter\jlreq@next
  \fi
}
% カンマで区切って，その前と後ろを\jlreq@tempc,\jlreq@tempdに入れる
% もしカンマがない場合は\ifjlreq@tempaがfalseになる．
\def\jlreq@helper@dividebycomma#1{\jlreq@helper@dividebycomma@#1,\jlreq@endmark}
\def\jlreq@helper@dividebycomma@#1,#2\jlreq@endmark{%
  \def\jlreq@tempc{#1}%
  \def\jlreq@tempd{#2}%
  \ifx\jlreq@tempd\@empty\jlreq@tempafalse\else\jlreq@tempatrue\expandafter\def\expandafter\jlreq@tempd\expandafter{\jlreq@helper@removelastcomma#2\jlreq@endmark}\fi
}
\def\jlreq@helper@removelastcomma#1,\jlreq@endmark{#1}

\def\jlreq@deleteuntileendmark#1\jlreq@endmark{}

% #1が#2のリスト（{list1}{list2}...{listn}の形）に入っていれば#3を，入っていなければ#4を実行する
% #2は\edefで展開されてから評価される
\def\jlreq@ifinlist#1#2#3#4{%
  \begingroup
    \edef\@tempa{#2}%
    \jlreq@tempafalse
    \expandafter\jlreq@helper@ifinlist@\expandafter{\@tempa}{#1}%
    \ifjlreq@tempa\def\jlreq@do{#3}\else\def\jlreq@do{#4}\fi
  \expandafter\endgroup
  \jlreq@do
}
\def\jlreq@helper@ifinlist@#1#2{%
  \jlreq@helper@ifinlist@@{#2}#1\jlreq@endmark
}
\def\jlreq@helper@ifinlist@@#1#2{%
  \ifx\jlreq@endmark#2\def\jlreq@next{}%
  \else
    \def\jlreq@helper@ifinlist@tempa{#1}%
    \def\jlreq@helper@ifinlist@tempb{#2}%
    \ifx\\jlreq@helper@ifinlist@tempa\jlreq@helper@ifinlist@tempa
      \jlreq@tempatrue\def\jlreq@next{\jlreq@deleteuntileendmark}%
    \else
      \def\jlreq@next{\jlreq@helper@ifinlist@@{#1}}%
    \fi
  \fi
  \jlreq@next
}

% 与えられたトークン列が空か（展開はしないでチェック）
\long\def\jlreq@ifempty#1{\ifx\jlreq@uniqtoken#1\jlreq@uniqtoken\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
\let\IfEmpty=\jlreq@ifempty

% vbox #1の最後を\jlreq@resultboxに入れる
% #1の最後の行は消える
\newcommand*{\jlreq@getlastbox}[1]{%
  \setbox#1=\vbox{\unvbox#1\relax
    \unskip\unskip\unpenalty\global\setbox\jlreq@resultbox=\lastbox}%
  \ifhbox\jlreq@resultbox
    \global\setbox\jlreq@resultbox=\hbox{%
      \unhbox\jlreq@resultbox\unskip\unskip\unpenalty}%
  \else
    \global\setbox\jlreq@resultbox=\copy\voidb@x
  \fi
}

% vbox #1の最初を\jlreq@resultboxに入れる
% #1は消える
\newcommand*{\jlreq@getfirstbox}[1]{%
  \loop\ifdim\dimexpr\dp#1+\ht#1=0pt\relax\else\jlreq@getlastbox{#1}\repeat
}

\newcommand*{\jlreq@debug@output}[1]{\message{\detokenize{#1}}}

% 簡易なkeyvalのパース．
% \jlreq@parsekeyval[family]{
%  {key}{\def\val{#1}}
%  {key}[choice1,choice2]{\def\valchoice{#1}}
%}{parse対象}
\long\def\jlreq@parsekeyval{%
  \@ifnextchar[{\jlreq@helper@parsekeyval}{\jlreq@helper@parsekeyval[jlreq@key]}%
}
\long\def\jlreq@helper@parsekeyval[#1]#2#3{%
  \begingroup
    \def\jlreq@do{}%
    \jlreq@helper@parsekeyval@{#1}#2\jlreq@endmark
    \setkeys{#1}{#3}%
  \expandafter\endgroup
  \jlreq@do
}
\long\def\jlreq@helper@parsekeyval@#1#2{%
  \ifx\jlreq@endmark#2%
    \def\@tempa{}%
  \else
    \def\@tempa{%
      \@ifnextchar[{\jlreq@helper@parsekeyval@@choicekey{#1}{#2}}{\jlreq@helper@parsekeyval@@definekey{#1}{#2}}%
    }%
  \fi
  \@tempa
}
\long\def\jlreq@helper@parsekeyval@@choicekey#1#2[#3]#4{%
  \define@choicekey{#1}{#2}{#3}{\appto\jlreq@do{#4}}%
  \jlreq@helper@parsekeyval@{#1}%
}
\long\def\jlreq@helper@parsekeyval@@definekey#1#2#3{%
  \define@key{#1}{#2}[]{\appto\jlreq@do{#3}}%
  \jlreq@helper@parsekeyval@{#1}%
}

% #1のboxを今の真ん中に配置する．
\def\jlreq@box@putcenter#1{%
  \begingroup
    \jlreq@tempdima=\dimexpr(\ht#1 - \dp#1)/2\relax
    \setbox\jlreq@tempboxa=\hbox{あ}%
    \edef\jlreq@do{%
      \noexpand\lower\the\dimexpr(\jlreq@tempdima - (\ht\jlreq@tempboxa - \dp\jlreq@tempboxa)/2)\relax\unexpanded{\box#1}%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\def\jlreq@currentline#1{\message{#1: at line \the\inputlineno}}

% \jlreq@switch{str}{
%   {str}{abcd}
%   {str1}{xyz}
%}[default: input = #1] -> abcd
%または
%
% \jlreq@switch{str}{
%   {str}{abcd}
%   {str1}{xyz}
%   {default: input = #1}
%} -> abcd
\def\jlreq@switch#1#2{%
  \@ifnextchar[{\jlreq@helper@switch{#1}{#2}}{\jlreq@helper@switch{#1}{#2}[]}%
}
\def\jlreq@helper@switch#1#2[#3]{%
  \begingroup
    \def\jlreq@do##1{#3}%
    \jlreq@helper@switch@{#1}#2\jlreq@endmark
  \expandafter\endgroup
  \jlreq@do{#1}%
}
\def\jlreq@helper@switch@#1#2{%
  \ifx\jlreq@endmark#2%
    \def\jlreq@next{}%
  \else
    \def\jlreq@next{\jlreq@helper@switch@@{#1}{#2}}%
  \fi
  \jlreq@next
}
\def\jlreq@helper@switch@@#1#2#3{%
  \ifx\jlreq@endmark#3%
    \def\jlreq@do##1{#2}%
    \def\jlreq@next{}%
  \else
    \def\jlreq@tempa{#1}%
    \def\jlreq@tempb{#2}%
    \ifx\jlreq@tempa\jlreq@tempb
      \def\jlreq@do##1{#3}%
      \def\jlreq@next{\jlreq@deleteuntileendmark}%
    \else
      \def\jlreq@next{\jlreq@helper@switch@{#1}}%
    \fi
  \fi
  \jlreq@next
}


%. オプションの定義
% オプション処理の際にしか使わない変数（後でそれを元に別の変数を調整する）
% ものは\jlreq@option@<key>に格納する．
% _とかは@に変換する．
\newcommand*{\jlreq@checkempty}[2]{
  \jlreq@ifempty{#2}{}{\ClassError{jlreq}{The option #1 should have no value}{\@ehc}}%
}
% 引数無しの\DeclareOptionX
\newcommand*{\jlreq@DeclareOption}[2]{%
  \DeclareOptionX{#1}{\jlreq@checkempty{#1}{##1}#2}
}
% エンジン類
\jlreq@DeclareOption{uplatex}{\let\jlreq@engine=u}
\jlreq@DeclareOption{platex}{\let\jlreq@engine=p}
\jlreq@DeclareOption{lualatex}{\let\jlreq@engine=l}

%.. 基本版面．まずは紙サイズ．
\def\jlreq@switchpapersize{}
\newcommand*\jlreq@addpapersize[4][]{%
  \jlreq@ifempty{#2}{}{
    \jlreq@DeclareOption{#2}{\setlength\paperheight{#3}\setlength\paperwidth{#4}}
    \appto\jlreq@switchpapersize{{#2}{\setlength\paperheight{#3}\setlength\paperwidth{#4}}}
  }
  \jlreq@ifempty{#1}{}{
    \appto\jlreq@switchpapersize{{#1}{\setlength\paperheight{#3}\setlength\paperwidth{#4}}}
  }
}
\DeclareOptionX{paper}{
  \edef\jlreq@do{%
    \unexpanded{\jlreq@switch{#1}}{\expandonce{\jlreq@switchpapersize}}%
    [\unexpanded{%
      \jlreq@helper@dividebycomma{#1}%
      \ifjlreq@tempa
        \setlength{\paperheight}{\dimexpr\jlreq@tempc\relax}%
        \setlength{\paperwidth}{\dimexpr\jlreq@tempd\relax}%
      \else
        \ClassError{jlreq}{The paper #1 is unknown}{\@ehc}%
      \fi
    }]%
  }%
  \jlreq@do
}
% 紙サイズ一覧．b*はJIS B．
% [paper=で指定できるようにするもの]{オプション名}{縦}{横}
\jlreq@addpapersize[a3]{a3paper}{420mm}{297mm}
\jlreq@addpapersize[a4]{a4paper}{297mm}{210mm}
\jlreq@addpapersize[a5]{a5paper}{210mm}{148mm}
\jlreq@addpapersize[a6]{a6paper}{148mm}{105mm}
\jlreq@addpapersize[b4]{b4paper}{364mm}{257mm}
\jlreq@addpapersize[b5]{b5paper}{257mm}{182mm}
\jlreq@addpapersize[b6]{b6paper}{182mm}{128mm}
\jlreq@addpapersize{a4j}{297mm}{210mm}
\jlreq@addpapersize{a5j}{210mm}{148mm}
\jlreq@addpapersize{b4j}{364mm}{257mm}
\jlreq@addpapersize{b5j}{257mm}{182mm}
\jlreq@addpapersize{a4var}{283mm}{210mm}
\jlreq@addpapersize{b5var}{230mm}{182mm}
\jlreq@addpapersize[letter]{letterpaper}{11in}{8.5in}
\jlreq@addpapersize[legal]{legalpaper}{14in}{8.5in}
\jlreq@addpapersize[executive]{executivepaper}{10.5in}{7.25in}
% 追加
\jlreq@addpapersize[a0]{}{1189mm}{841mm}
\jlreq@addpapersize[a1]{}{841mm}{594mm}
\jlreq@addpapersize[a2]{}{420mm}{594mm}
\jlreq@addpapersize[a7]{}{74mm}{105mm}
\jlreq@addpapersize[a8]{}{52mm}{74mm}
\jlreq@addpapersize[a9]{}{37mm}{52mm}
\jlreq@addpapersize[a10]{}{26mm}{37mm}

\jlreq@addpapersize[b0]{}{1030mm}{1456mm}
\jlreq@addpapersize[b1]{}{728mm}{1030mm}
\jlreq@addpapersize[b2]{}{515mm}{728mm}
\jlreq@addpapersize[b3]{}{364mm}{515mm}
\jlreq@addpapersize[b7]{}{91mm}{128mm}
\jlreq@addpapersize[b8]{}{64mm}{91mm}
\jlreq@addpapersize[b9]{}{45mm}{64mm}
\jlreq@addpapersize[b10]{}{32mm}{45mm}

\jlreq@addpapersize[c2]{}{458mm}{648mm}
\jlreq@addpapersize[c3]{}{324mm}{458mm}
\jlreq@addpapersize[c4]{}{229mm}{354mm}
\jlreq@addpapersize[c5]{}{162mm}{229mm}
\jlreq@addpapersize[c6]{}{114mm}{162mm}
\jlreq@addpapersize[c7]{}{81mm}{114mm}
\jlreq@addpapersize[c8]{}{57mm}{81mm}

\newcommand*\jlreq@article@type{article}
\define@choicekey{jlreq.cls}{article_type}{article,report,book}{\renewcommand*{\jlreq@article@type}{#1}}
\jlreq@DeclareOption{article}{\renewcommand*{\jlreq@article@type}{article}}
\jlreq@DeclareOption{report}{\renewcommand*{\jlreq@article@type}{report}}
\jlreq@DeclareOption{book}{\renewcommand*{\jlreq@article@type}{book}}

%.. フォントサイズ，行長，1ページあたりの行数で基本版面のサイズを決める（2.4.1.a）
\newcommand*{\jlreq@option@fontsize}{}
\DeclareOptionX{fontsize}{\renewcommand*{\jlreq@option@fontsize}{#1}}
\jlreq@DeclareOption{10pt}{\renewcommand*{\jlreq@option@fontsize}{10pt}}
\jlreq@DeclareOption{11pt}{\renewcommand*{\jlreq@option@fontsize}{11pt}}
\jlreq@DeclareOption{12pt}{\renewcommand*{\jlreq@option@fontsize}{12pt}}

%.. 行の長さ
\newcommand*{\jlreq@option@line@length}{}
\DeclareOptionX{line_length}{\renewcommand*{\jlreq@option@line@length}{#1}}
%.. 1ページあたりの行数
\newcommand*{\jlreq@option@number@of@lines}{}
\DeclareOptionX{number_of_lines}{\renewcommand*{\jlreq@option@number@of@lines}{#1}}

% 地の空き量，のどの空き量で配置位置を決める（2.4.1.b）省略されたら中央配置．
%.. 天
\newcommand*{\jlreq@option@head@space}{}
\DeclareOptionX{head_space}{\renewcommand*{\jlreq@option@head@space}{#1}}

%.. 地
\newcommand*{\jlreq@option@foot@space}{}
\DeclareOptionX{foot_space}{\renewcommand*{\jlreq@option@foot@space}{#1}}
%.. のど
\newcommand*{\jlreq@option@gutter}{}
\DeclareOptionX{gutter}{\renewcommand*{\jlreq@option@gutter}{#1}}

%.. 柱とノンブル
\newcommand*{\jlreq@option@headfoot@verticalpos}{1zw}
\DeclareOptionX{headfoot_verticalposition}{\renewcommand*{\jlreq@option@headfoot@verticalpos}{#1}}
\newcommand*{\jlreq@headfoot@sidemargin}{0pt}
\DeclareOptionX{headfoot_sidemargin}{\renewcommand*{\jlreq@headfoot@sidemargin}{#1}}

%.. 段間
\newcommand*{\jlreq@option@column@gap}{2zw}
\DeclareOptionX{column_gap}{\renewcommand*{\jlreq@option@column@gap{#1}}}

%.. 行送り，指定無しの場合は文字サイズの1.7倍とする．（1.5から2倍が好ましい：2.4.2.d 注3）
\newcommand*{\jlreq@option@baselineskip}{}
\DeclareOptionX{baselineskip}{\def\jlreq@option@baselineskip{#1}}
\DeclareOptionX{linegap}{\def\jlreq@option@baselineskip{1zh + #1}}

%.. 組み方系
% 行頭に括弧が来たときの配置：3.1.5
% 段落頭指定_折り返し行頭指定 で与える．
\newcommand*{\jlreq@open@bracket@pos}{zenkaku_tentsuki}
\define@choicekey{jlreq.cls}{open_bracket_pos}{zenkaku_tentsuki,zenkakunibu_nibu,nibu_tentsuki}{\renewcommand*{\jlreq@open@bracket@pos}{#1}}
% ぶら下げ組みをするか：3.8.2 注1
\newif\ifjlreq@burasage\jlreq@burasagefalse
\jlreq@DeclareOption{hanging_punctuation}{\jlreq@burasagetrue}

%.. 注
% 合印の場所（4.2.3）行間に入れるか否か
\newcommand*{\jlreq@referencemark}{inline}
\define@choicekey{jlreq.cls}{reference_mark}{inline,interlinear}{\renewcommand*{\jlreq@referencemark}{#1}}
% 脚注の字下げ，一行目を下げるならばone，二行目以降ならばtwo．ちょっと酷いので後で考える．
\newcommand*{\jlreq@footnotetext@indent}{one}
\define@choicekey{jlreq.cls}{footnotetext_indent}{one,two}{\renewcommand*{\jlreq@footnotetext@indent}{#1}}
% 後注をどこに配置するか．_headings（全ての見出し）,_paragraph（段落後）,_で始まらないやつ（その名前の見出し）．カンマ区切り
\newcommand*{\jlreq@endnote@position}{_headings}
\DeclareOptionX{endnote_position}{\renewcommand*{\jlreq@endnote@position}{#1}}
% 傍注のタイプ
\newcommand*{\jlreq@sidenote@type}{number}
\define@choicekey{jlreq.cls}{sidenote_type}{number,mark}{\renewcommand*{\jlreq@sidenote@type}{#1}}
\newcommand*{\jlreq@option@sidenote@width}{}
\DeclareOptionX{sidenote_width}{\renewcommand*{\jlreq@option@sidenote@width}{#1}}

\newif\if@restonecol \@restonecolfalse
\newif\if@titlepage \@titlepagefalse
\newif\if@landscape \@landscapefalse
\newif\if@tate \@tatefalse
\jlreq@DeclareOption{landscape}{\@landscapetrue}
\jlreq@DeclareOption{tombo}{%
  \tombowtrue \tombowdatefalse
  \setlength{\@tombowwidth}{.1\p@}%
  \maketombowbox}
\jlreq@DeclareOption{mentuke}{%
  \tombowtrue \tombowdatefalse
  \setlength{\@tombowwidth}{\z@}%
  \maketombowbox}
\jlreq@DeclareOption{tate}{\@tatetrue
  \AtBeginDocument{\tate\message{\jlreq@tategumi@message}\adjustbaseline}%
}
\jlreq@DeclareOption{oneside}{\@twosidefalse\@mparswitchfalse}
\jlreq@DeclareOption{twoside}{\@twosidetrue\@mparswitchtrue}
\jlreq@DeclareOption{vartwoside}{\@twosidetrue\@mparswitchfalse}
\jlreq@DeclareOption{onecolumn}{\@twocolumnfalse}
\jlreq@DeclareOption{twocolumn}{\@twocolumntrue}
\jlreq@DeclareOption{titlepage}{\@titlepagetrue}
\jlreq@DeclareOption{notitlepage}{\@titlepagefalse}
\jlreq@DeclareOption{draft}{\setlength\overfullrule{5pt}}
\jlreq@DeclareOption{final}{\setlength\overfullrule{0pt}}

\newcommand*{\jlreq@warning}[1]{}
\jlreq@DeclareOption{jlreq_warnings}{\renewcommand*{\jlreq@warning}[1]{\ClassWarningNoLine{jlreq}{(JLREQ warning) ##1}}}

\ExecuteOptionsX{article_type=article,paper=a4,fontsize=10pt,open_bracket_pos=zenkaku_tentsuki,reference_mark=inline,footnotetext_indent=one,endnote_position=_headings,onecolumn,final}
% \@removeelementを一旦置き換えてから\ProcessOptionsXを実行する
\let\jlreq@original@@removeelement=\@removeelement
\let\@removeelement=\jlreq@helper@removeelement
\ProcessOptionsX*\relax
\let\@removeelement=\jlreq@original@@removeelement

\newcommand{\jlreqsetup}[1]{%
  \jlreq@parsekeyval[jlreqsetup]{%
    {sidenote_mark}{%
      \jlreq@parsekeyval[sidenote_mark]{%
        {mark}{\def\jlreq@sidenote@defaultmark{####1}}%
        {headingfont}{\def\jlreq@sidenote@keywordfont{####1}}%
      }{##1}%
    }%
  }{#1}%
}
\@onlypreamble\jlreqsetup

% エンジンの設定
\ifx\jlreq@engine\@undefined
  \ifx\luatexversion\@undefined
    \ifx\ucs\@undefined
      \let\jlreq@engine=p
    \else
      \let\jlreq@engine=u
    \fi
  \else
    \let\jlreq@engine=l
  \fi
\fi

\ifx l\jlreq@engine
  \RequirePackage{luatexja}
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
\def\jlreq@tategumi@message{《縦組モード》}

% \jlreq@gol(Gyo Okuri Length), \jlreq@mol (Moji Okuri Length)を定義
\if@tate
  \ifx l\jlreq@engine
    \def\jlreq@gol{\zw}\def\jlreq@mol{\zh}
  \else
    \def\jlreq@gol{zw}\def\jlreq@mol{zh}  
  \fi
\else
  \ifx l\jlreq@engine
    \def\jlreq@gol{\zh}\def\jlreq@mol{\zw}
  \else
    \def\jlreq@gol{zh}\def\jlreq@mol{zw}
  \fi
\fi

%. helper2（エンジン依存系）
% 組方向を判定
% \jlreq@if(y|t)(dir|box)を定義する．
\def\jlreq@do{%
  \def\jlreq@ifydir{\ifydir\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@iftdir{\iftdir\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@ifybox##1{\ifybox##1\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@iftbox##1{\iftbox##1\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
}
\ifx l\jlreq@engine
  \def\jlreq@ifydir{\ifnum\ltjgetparameter{direction}=4\relax\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@iftdir{\ifnum\numexpr\ltjgetparameter{direction}-(\ltjgetparameter{direction}/8)*8=3\relax\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@ifybox#1{\ifnum\ltjgetparameter{boxdir}{#1}=4\relax\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
  \def\jlreq@iftbox#1{\ifnum\numexpr\ltjgetparameter{boxdir}{#1}-(\ltjgetparameter{boxdir}{#1}/8)*8=3\relax\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
\else
  \jlreq@do
\fi

% 現在行の残りを得る．
\RequirePackage[savepos]{zref}
\newcount\jlreq@rest@linewidth@count
\jlreq@rest@linewidth@count=0

\ifx l\jlreq@engine
  % 以下のコードはおかしい．
  \newcommand*{\jlreq@calc@current@linewidth}{%
    \dimexpr\zposx{jlreq@rest@width.pos.\the\jlreq@rest@linewidth@count} sp - \@totalleftmargin -
    \ifodd\zref@extractdefault{jlreq@rest@width.page.\the\jlreq@rest@linewidth@count}{page}{\c@page}%
      \oddsidemargin
    \else
      \evensidemargin
    \fi
    - 1in - \hoffset\relax
  }
\else
  \newcommand*{\jlreq@calc@current@linewidth}{%
    \dimexpr
      \jlreq@ifydir{%
        \zposx{jlreq@rest@width.pos.\the\jlreq@rest@linewidth@count} sp - \hoffset
        \ifodd\zref@extractdefault{jlreq@rest@width.page.\the\jlreq@rest@linewidth@count}{page}{\c@page}%
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
        - \zposy{jlreq@rest@width.pos.\the\jlreq@rest@linewidth@count} sp
      }%
      - \@totalleftmargin - 1in
    \relax
  }
\fi

\newdimen\jlreq@current@linewidth
\newdimen\jlreq@rest@linewidth
% この命令以降，次にこの命令を実行する前まで\jlreq@rest@linewidth/\jlreq@rest@linewidthで
% この場所における残り長さが取得できる．
\newcommand*{\jlreq@savepos@for@rest@linewidth}{%
  \global\advance\jlreq@rest@linewidth@count by 1\relax
  \zsavepos{jlreq@rest@width.pos.\the\jlreq@rest@linewidth@count}%
  \zref@labelbyprops{jlreq@rest@width.page.\the\jlreq@rest@linewidth@count}{page}%
  \jlreq@current@linewidth=\jlreq@calc@current@linewidth
  \jlreq@rest@linewidth=\dimexpr\linewidth - \jlreq@current@linewidth\relax
}
\def\jlreq@savepos@iflabelundefined{\@ifundefined{\ZREF@RefPrefix @jlreq@rest@width.pos.\the\jlreq@rest@linewidth@count}}

%. 基本設定
% 和文文字，欧文文字の設定（とりあえずLuaTeX-jaのデフォルトのまま）
\ifx l\jlreq@engine
  \ltjsetparameter{jacharrange={-1, +2, +3, -4, -5, +6, +7, -8}}
  % kanjiskip, xkanjiskipはjfmのものを使う
  \ltjsetparameter{kanjiskip=\maxdimen}
  \ltjsetparameter{xkanjiskip=\maxdimen}
\else
  \kanjiskip=0pt plus 0.25zw minus 0pt
  \xkanjiskip=0.25zw plus 0.25zw minus 0.125zw
\fi

% 禁則処理，表1,2に従う
% 行末
% 初め括弧類
\ifx l\jlreq@engine
  \newcommand*{\jlreq@setpostbreakpenalty}[2]{\ltjsetparameter{postbreakpenalty={`#1,#2}}}
  \newcommand*{\jlreq@setprebreakpenalty}[2]{\ltjsetparameter{prebreakpenalty={`#1,#2}}}
  \newcommand*{\jlreq@setjaxspmode}[2]{\ltjsetparameter{jaxspmode={`#1,#2}}}
\else
  \newcommand*{\jlreq@setpostbreakpenalty}[2]{\postbreakpenalty`#1=#2}
  \newcommand*{\jlreq@setprebreakpenalty}[2]{\prebreakpenalty`#1=#2}
  \newcommand*{\jlreq@setjaxspmode}[2]{%
    \jlreq@switch{#2}{
      {inhibit}{\inhibitxspcode`#1=0}
      {preonly}{\inhibitxspcode`#1=1}
      {postonly}{\inhibitxspcode`#1=2}
      {allow}{\inhibitxspcode`#1=3}
      {\inhibitxspcode`#1=#2}
    }
  }
\fi

\jlreq@setpostbreakpenalty{（}{10000}
\jlreq@setpostbreakpenalty{〔}{10000}
\jlreq@setpostbreakpenalty{［}{10000}
\jlreq@setpostbreakpenalty{｛}{10000}
\jlreq@setpostbreakpenalty{〈}{10000}
\jlreq@setpostbreakpenalty{《}{10000}
\jlreq@setpostbreakpenalty{「}{10000}
\jlreq@setpostbreakpenalty{『}{10000}
\jlreq@setpostbreakpenalty{【}{10000}
\ifx p\jlreq@engine\else
\jlreq@setpostbreakpenalty{｟}{10000}
\jlreq@setpostbreakpenalty{〘}{10000}
\jlreq@setpostbreakpenalty{〖}{10000}
\jlreq@setpostbreakpenalty{«}{10000}
\jlreq@setpostbreakpenalty{〝}{10000}
\fi
\jlreq@setpostbreakpenalty{‘}{10000}
\jlreq@setpostbreakpenalty{“}{10000}
% 前置省略記号
\jlreq@setpostbreakpenalty{￥}{10000}
\jlreq@setpostbreakpenalty{＄}{10000}
\jlreq@setpostbreakpenalty{￡}{10000}
\jlreq@setpostbreakpenalty{＃}{10000}
\ifx p\jlreq@engine\else
\jlreq@setpostbreakpenalty{€}{10000}
\jlreq@setpostbreakpenalty{№}{10000}
\fi
% 行頭
% 終わり括弧類
\jlreq@setprebreakpenalty{）}{10000}
\jlreq@setprebreakpenalty{〕}{10000}
\jlreq@setprebreakpenalty{］}{10000}
\jlreq@setprebreakpenalty{｝}{10000}
\jlreq@setprebreakpenalty{〉}{10000}
\jlreq@setprebreakpenalty{》}{10000}
\jlreq@setprebreakpenalty{」}{10000}
\jlreq@setprebreakpenalty{』}{10000}
\jlreq@setprebreakpenalty{】}{10000}
\ifx p\jlreq@engine\else
\jlreq@setprebreakpenalty{｠}{10000}
\jlreq@setprebreakpenalty{〙}{10000}
\jlreq@setprebreakpenalty{〗}{10000}
\jlreq@setprebreakpenalty{»}{10000}
\jlreq@setprebreakpenalty{〟}{10000}
\fi
\jlreq@setprebreakpenalty{’}{10000}
\jlreq@setprebreakpenalty{”}{10000}
% ハイフン類
\jlreq@setprebreakpenalty{‐}{10000}
\ifx p\jlreq@engine\else
\jlreq@setprebreakpenalty{゠}{10000}
\jlreq@setprebreakpenalty{–}{10000}
\jlreq@setprebreakpenalty{〜}{10000}
\fi
% 区切り約物
\jlreq@setprebreakpenalty{！}{10000}
\jlreq@setprebreakpenalty{？}{10000}
\ifx p\jlreq@engine\else
\jlreq@setprebreakpenalty{‼}{10000}
\jlreq@setprebreakpenalty{⁇}{10000}
\jlreq@setprebreakpenalty{⁈}{10000}
\jlreq@setprebreakpenalty{⁉}{10000}
\fi
% 中点類
\jlreq@setprebreakpenalty{・}{10000}
\jlreq@setprebreakpenalty{：}{10000}
\jlreq@setprebreakpenalty{；}{10000}
% 句点類
\jlreq@setprebreakpenalty{。}{10000}
\jlreq@setprebreakpenalty{．}{10000}
% 読点類
\jlreq@setprebreakpenalty{、}{10000}
\jlreq@setprebreakpenalty{，}{10000}
% 繰返し記号
\jlreq@setprebreakpenalty{ヽ}{10000}
\jlreq@setprebreakpenalty{ヾ}{10000}
\jlreq@setprebreakpenalty{ゝ}{10000}
\jlreq@setprebreakpenalty{ゞ}{10000}
\jlreq@setprebreakpenalty{々}{10000}
\ifx p\jlreq@engine\else
\jlreq@setprebreakpenalty{〻}{10000}
\fi
% 長音記号
\jlreq@setprebreakpenalty{ー}{10000}
% 小書きの仮名
\jlreq@setprebreakpenalty{ぁ}{10000}
\jlreq@setprebreakpenalty{ぃ}{10000}
\jlreq@setprebreakpenalty{ぅ}{10000}
\jlreq@setprebreakpenalty{ぇ}{10000}
\jlreq@setprebreakpenalty{ぉ}{10000}
\jlreq@setprebreakpenalty{ァ}{10000}
\jlreq@setprebreakpenalty{ィ}{10000}
\jlreq@setprebreakpenalty{ゥ}{10000}
\jlreq@setprebreakpenalty{ェ}{10000}
\jlreq@setprebreakpenalty{ォ}{10000}
\jlreq@setprebreakpenalty{っ}{10000}
\jlreq@setprebreakpenalty{ゃ}{10000}
\jlreq@setprebreakpenalty{ゅ}{10000}
\jlreq@setprebreakpenalty{ょ}{10000}
\jlreq@setprebreakpenalty{ゎ}{10000}
\ifx p\jlreq@engine\else
\jlreq@setprebreakpenalty{ゕ}{10000}
\jlreq@setprebreakpenalty{ゖ}{10000}
\fi
\jlreq@setprebreakpenalty{ッ}{10000}
\jlreq@setprebreakpenalty{ャ}{10000}
\jlreq@setprebreakpenalty{ュ}{10000}
\jlreq@setprebreakpenalty{ョ}{10000}
\jlreq@setprebreakpenalty{ヮ}{10000}
\jlreq@setprebreakpenalty{ヵ}{10000}
\jlreq@setprebreakpenalty{ヶ}{10000}
\ifx p\jlreq@engine\else
\jlreq@setprebreakpenalty{ㇰ}{10000}
\jlreq@setprebreakpenalty{ㇱ}{10000}
\jlreq@setprebreakpenalty{ㇲ}{10000}
\jlreq@setprebreakpenalty{ㇳ}{10000}
\jlreq@setprebreakpenalty{ㇴ}{10000}
\jlreq@setprebreakpenalty{ㇵ}{10000}
\jlreq@setprebreakpenalty{ㇶ}{10000}
\jlreq@setprebreakpenalty{ㇷ}{10000}
\jlreq@setprebreakpenalty{ㇸ}{10000}
\jlreq@setprebreakpenalty{ㇹ}{10000}
\jlreq@setprebreakpenalty{ㇺ}{10000}
\jlreq@setprebreakpenalty{ㇻ}{10000}
\jlreq@setprebreakpenalty{ㇼ}{10000}
\jlreq@setprebreakpenalty{ㇽ}{10000}
\jlreq@setprebreakpenalty{ㇾ}{10000}
\jlreq@setprebreakpenalty{ㇿ}{10000}
\fi

% xkanjiskip
% 初め括弧類（二分）
\jlreq@setjaxspmode{（}{preonly}
\jlreq@setjaxspmode{〔}{preonly}
\jlreq@setjaxspmode{［}{preonly}
\jlreq@setjaxspmode{｛}{preonly}
\jlreq@setjaxspmode{〈}{preonly}
\jlreq@setjaxspmode{《}{preonly}
\jlreq@setjaxspmode{「}{preonly}
\jlreq@setjaxspmode{『}{preonly}
\jlreq@setjaxspmode{【}{preonly}
\ifx p\jlreq@engine\else
\jlreq@setjaxspmode{｟}{preonly}
\jlreq@setjaxspmode{〘}{preonly}
\jlreq@setjaxspmode{〖}{preonly}
\jlreq@setjaxspmode{«}{preonly}
\jlreq@setjaxspmode{〝}{preonly}
\fi
\jlreq@setjaxspmode{‘}{preonly}
\jlreq@setjaxspmode{“}{preonly}
% 終わり括弧類（二分）
\jlreq@setjaxspmode{）}{postonly}
\jlreq@setjaxspmode{〕}{postonly}
\jlreq@setjaxspmode{］}{postonly}
\jlreq@setjaxspmode{｝}{postonly}
\jlreq@setjaxspmode{〉}{postonly}
\jlreq@setjaxspmode{》}{postonly}
\jlreq@setjaxspmode{」}{postonly}
\jlreq@setjaxspmode{』}{postonly}
\jlreq@setjaxspmode{】}{postonly}
\ifx p\jlreq@engine\else
\jlreq@setjaxspmode{｠}{postonly}
\jlreq@setjaxspmode{〙}{postonly}
\jlreq@setjaxspmode{〗}{postonly}
\jlreq@setjaxspmode{»}{postonly}
\jlreq@setjaxspmode{〟}{postonly}
\fi
\jlreq@setjaxspmode{’}{postonly}
\jlreq@setjaxspmode{”}{postonly}
% ハイフン類（二分）
\jlreq@setjaxspmode{‐}{inhibit}
\ifx p\jlreq@engine\else
\jlreq@setjaxspmode{゠}{inhibit}
\jlreq@setjaxspmode{–}{inhibit}
\jlreq@setjaxspmode{〜}{inhibit}
\fi
% 区切り約物
\jlreq@setjaxspmode{！}{postonly}
\jlreq@setjaxspmode{？}{postonly}
\ifx p\jlreq@engine\else
\jlreq@setjaxspmode{‼}{postonly}
\jlreq@setjaxspmode{⁇}{postonly}
\jlreq@setjaxspmode{⁈}{postonly}
\jlreq@setjaxspmode{⁉}{postonly}
\fi
% 中点類
\jlreq@setjaxspmode{・}{postonly}
\jlreq@setjaxspmode{：}{postonly}
\jlreq@setjaxspmode{；}{postonly}
% 句点類（二分）
\jlreq@setjaxspmode{。}{postonly}
\jlreq@setjaxspmode{．}{postonly}
% 読点類（二分）
\jlreq@setjaxspmode{、}{postonly}
\jlreq@setjaxspmode{，}{postonly}
% 分離禁止文字
\jlreq@setjaxspmode{—}{inhibit}
\jlreq@setjaxspmode{…}{inhibit}
\jlreq@setjaxspmode{‥}{inhibit}
\ifx p\jlreq@engine\else
\jlreq@setjaxspmode{〳}{inhibit}
\jlreq@setjaxspmode{〴}{inhibit}
\jlreq@setjaxspmode{〵}{inhibit}
\fi
% 前置省略記号
\jlreq@setjaxspmode{￥}{inhibit}
\jlreq@setjaxspmode{＄}{inhibit}
\jlreq@setjaxspmode{￡}{inhibit}
\jlreq@setjaxspmode{＃}{inhibit}
\ifx p\jlreq@engine\else
\jlreq@setjaxspmode{€}{inhibit}
\jlreq@setjaxspmode{№}{inhibit}
\fi
% 後置省略記号
\jlreq@setjaxspmode{°}{inhibit}
\jlreq@setjaxspmode{′}{inhibit}
\jlreq@setjaxspmode{″}{inhibit}
\jlreq@setjaxspmode{℃}{inhibit}
\jlreq@setjaxspmode{￠}{inhibit}
\jlreq@setjaxspmode{％}{inhibit}
\jlreq@setjaxspmode{‰}{inhibit}
\ifx p\jlreq@engine\else
\jlreq@setjaxspmode{㏋}{inhibit}
\jlreq@setjaxspmode{ℓ}{inhibit}
\jlreq@setjaxspmode{㌃}{inhibit}
\jlreq@setjaxspmode{㌍}{inhibit}
\jlreq@setjaxspmode{㌔}{inhibit}
\jlreq@setjaxspmode{㌘}{inhibit}
\jlreq@setjaxspmode{㌢}{inhibit}
\jlreq@setjaxspmode{㌣}{inhibit}
\jlreq@setjaxspmode{㌦}{inhibit}
\jlreq@setjaxspmode{㌧}{inhibit}
\jlreq@setjaxspmode{㌫}{inhibit}
\jlreq@setjaxspmode{㌶}{inhibit}
\jlreq@setjaxspmode{㌻}{inhibit}
\jlreq@setjaxspmode{㍉}{inhibit}
\jlreq@setjaxspmode{㍊}{inhibit}
\jlreq@setjaxspmode{㍍}{inhibit}
\jlreq@setjaxspmode{㍑}{inhibit}
\jlreq@setjaxspmode{㍗}{inhibit}
\jlreq@setjaxspmode{㎎}{inhibit}
\jlreq@setjaxspmode{㎏}{inhibit}
\jlreq@setjaxspmode{㎜}{inhibit}
\jlreq@setjaxspmode{㎝}{inhibit}
\jlreq@setjaxspmode{㎞}{inhibit}
\jlreq@setjaxspmode{㎡}{inhibit}
\jlreq@setjaxspmode{㏄}{inhibit}
\fi
% 分割禁止（分離禁止文字は特定の並びで分割禁止だが，とりあえず一括で禁止しておく．）
\jlreq@setprebreakpenalty{—}{10000}
\jlreq@setprebreakpenalty{…}{10000}
\jlreq@setprebreakpenalty{‥}{10000}
% ￥100とか70％とか……


%. オプション処理
\newdimen\jlreq@fontsize
\ifx l\jlreq@engine
  \setlength{\jlreq@fontsize}{%
    \dimexpr\directlua{
      local s = [[\jlreq@option@fontsize]]
      s = s:gsub("Q"," * 2.5mm")
      tex.print(s)
    }\relax
  }%
\else
  \expandafter\jlreq@replace\expandafter{\jlreq@option@fontsize}{Q}{*2.5m}{\@tempa}
  \setlength{\jlreq@fontsize}{\dimexpr\@tempa\relax}
\fi

% JFMに関連する設定
\ifx l\jlreq@engine
  % この値は後でjfm-jlreq内で読む
  \directlua{jlreq.open_bracket_pos = [[\jlreq@open@bracket@pos]]}
  \ifjlreq@burasage\directlua{jlreq.burasage = true}
  \else\directlua{jlreq.burasage = false}\fi
\else
  % 非LuaTeXの場合はJFMの入れ替えと\everyparでの処理で対処．
  \def\jlreq@jfmname@prefix{}
  \def\jlreq@openbreackets@list{{（} {〔} {［} {｛} {〈} {《} {「} {『} {【}}
  \ifx u\jlreq@engine\edef\jlreq@openbreackets@list{\jlreq@openbreackets@list {｟} {〘} {〖} {«} {〝}{‘} {“}}\fi
  % \jlreq@jfmnameにJFMの名前を入れる
  \ifjlreq@burasage\edef\jlreq@jfmname@prefix{b\jlreq@jfmname@prefix}\fi
  \ifthenelse{\equal{\jlreq@open@bracket@pos}{zenkakunibu_nibu}}{\edef\jlreq@jfmname@prefix{\jlreq@jfmname@prefix z}}{}
  \ifx u\jlreq@engine\edef\jlreq@jfmname@prefix{u\jlreq@jfmname@prefix}\fi
  \edef\jlreq@jfmname{\jlreq@jfmname@prefix jlreq}
  \edef\jlreq@jfmnameg{\jlreq@jfmname@prefix jlreqg}
  \ifthenelse{\equal{\jlreq@open@bracket@pos}{zenkaku_tentsuki}}{
    \def\jlreq@openbracket@hook{\jlreq@ifinlist{\jlreq@nextchar}{\jlreq@openbreackets@list}{\inhibitglue}{}}
    \AtBeginDocument{\PushPostHook{par}{\futurelet\jlreq@nextchar\jlreq@openbracket@hook}}
  }{}
  \ifthenelse{\equal{\jlreq@open@bracket@pos}{nibu_tentsuki}}{
    \def\jlreq@openbracket@hook{\jlreq@ifinlist{\jlreq@nextchar}{\jlreq@openbreackets@list}{\hskip -1\jlreq@mol}{}}
    \AtBeginDocument{\PushPostHook{par}{\futurelet\jlreq@nextchar\jlreq@openbracket@hook}}
  }{}
\fi
% 開き括弧の幅が全角の場合は，ベタ組にするために補正が必要
\ifthenelse{\equal{\jlreq@open@bracket@pos}{zenkakunibu_nibu}}{
  \def\jlreq@open@bracket@before@space{\hskip -.5\jlreq@mol}
}{
  \def\jlreq@open@bracket@before@space{}
}

% landscapeの場合縦横をひっくり返す
\if@landscape
  \setlength\@tempdima  {\paperheight}
  \setlength\paperheight{\paperwidth}
  \setlength\paperwidth {\@tempdima}
\fi

% \baselineskipの計算
\newdimen\jlreq@baselineskip
\ifx\jlreq@option@baselineskip\@empty
  \setlength{\jlreq@baselineskip}{\dimexpr 17\jlreq@fontsize/10\relax}%
\else
  \ifx l\jlreq@engine
    \setlength{\jlreq@baselineskip}{%
      \dimexpr\directlua{
        local act = string.char(92)
        local s = [[\jlreq@option@baselineskip]]
        s = s:gsub("Q"," * 2.5mm"):gsub("z[hw]",act .. "jlreq@fontsize")
        tex.print(s)
      }\relax
    }%
  \else
    \expandafter\jlreq@replace\expandafter{\jlreq@option@baselineskip}{Q}{*2.5mm}{\@tempa}
    \setlength{\jlreq@baselineskip}{\dimexpr\@tempa\relax}
  \fi
\fi
\ifdim\jlreq@fontsize>\jlreq@baselineskip
  \ClassError{jlreq}{The baselineskip is less than fontsize}{\@ehc}%
\fi
\ifthenelse{\lengthtest{\jlreq@baselineskip<1.5\jlreq@fontsize} \OR \lengthtest{\jlreq@baselineskip>2\jlreq@fontsize}}{
  \jlreq@warning{行間は二分以上全角以下が望ましい (2.4.2.d 注3)}
}{}

% \pdfpagewidthとか設定
\ifx l\jlreq@engine
  \let\jlreq@pagewidth=\pagewidth
  \let\jlreq@pageheight=\pageheight
\else
  \let\jlreq@pagewidth=\pdfpagewidth
  \let\jlreq@pageheight=\pdfpageheight
\fi
\setlength{\jlreq@pagewidth}{\paperwidth}
\setlength{\jlreq@pageheight}{\paperheight}
\iftombow
  \addtolength{\jlreq@pagewidth}{2in}
  \addtolength{\jlreq@pageheight}{2in}
\fi

%. フォント
\RequirePackage{lmodern}

% 数式フォント設定
\ifx l\jlreq@engine
  \DeclareSymbolFont{mincho}{JY3}{mc}{m}{n}
  \DeclareSymbolFontAlphabet{\mathmc}{mincho}
  \SetSymbolFont{mincho}{bold}{JY3}{gt}{m}{n}
  \jfam\symmincho
  \DeclareMathAlphabet{\mathgt}{JY3}{gt}{m}{n}
\else
\fi

% 古いフォントコマンド
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
\ifx l\jlreq@engine
  \RequirePackage{luatexja-adjust}
  \ltjenableadjust[lineend=extended,priority=true]
  \ltjsetparameter{stretch_priority={kanjiskip=10,xkanjiskip=-30}}
  \ltjsetparameter{shrink_priority={kanjiskip=0,xkanjiskip=0}}
\fi

\ifx u\jlreq@engine
  \def\jlreq@yokokanjiencoding{JY2}
  \def\jlreq@tatekanjiencoding{JT2}
\fi
\ifx p\jlreq@engine
  \def\jlreq@yokokanjiencoding{JY1}
  \def\jlreq@tatekanjiencoding{JT1}
\fi
\ifx l\jlreq@engine
  \def\jlreq@yokokanjiencoding{JY3}
  \def\jlreq@tatekanjiencoding{JT3}
  \expandafter\let\csname JY3/mc/m/n/10\endcsname\relax
  \expandafter\let\csname JT3/mc/m/n/10\endcsname\relax
  \DeclareFontShape{JY3}{mc}{m}{n}{<->\ltj@stdmcfont:jfm=jlreq;script=latn;-kern}{}
  \DeclareFontShape{JY3}{gt}{m}{n}{<->\ltj@stdgtfont:jfm=jlreq;script=latn;-kern}{}
  \DeclareFontShape{JT3}{mc}{m}{n}{<->\ltj@stdmcfont:jfm=jlreqv;script=latn;-kern}{}
  \DeclareFontShape{JT3}{gt}{m}{n}{<->\ltj@stdgtfont:jfm=jlreqv;script=latn;-kern}{}
\else
  \expandafter\let\csname \jlreq@yokokanjiencoding/mc/m/n/10\endcsname\relax
  \expandafter\let\csname \jlreq@tatekanjiencoding/mc/m/n/10\endcsname\relax
  \DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{m}{n}{<-> \jlreq@jfmname}{}
  \DeclareFontShape{\jlreq@yokokanjiencoding}{gt}{m}{n}{<-> \jlreq@jfmnameg}{}
  \DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{m}{n}{<-> \jlreq@jfmname-v}{}
  \DeclareFontShape{\jlreq@tatekanjiencoding}{gt}{m}{n}{<-> \jlreq@jfmnameg-v}{}
\fi
\DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@yokokanjiencoding}{gt}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{m}{it}{<->ssub*mc/m/n}{}
\DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{m}{sl}{<->ssub*mc/m/n}{}
\DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{m}{sc}{<->ssub*mc/m/n}{}
\DeclareFontShape{\jlreq@yokokanjiencoding}{gt}{m}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@yokokanjiencoding}{gt}{m}{sl}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{bx}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{bx}{sl}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@tatekanjiencoding}{gt}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{m}{it}{<->ssub*mc/m/n}{}
\DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{m}{sl}{<->ssub*mc/m/n}{}
\DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{m}{sc}{<->ssub*mc/m/n}{}
\DeclareFontShape{\jlreq@tatekanjiencoding}{gt}{m}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@tatekanjiencoding}{gt}{m}{sl}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{bx}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{bx}{sl}{<->ssub*gt/m/n}{}

\emergencystretch 3\jlreq@mol

\renewcommand{\normalsize}{%
  \@setfontsize\normalsize{\jlreq@fontsize}{\jlreq@baselineskip}%
  \abovedisplayskip 1.1\jlreq@fontsize \@plus .3\jlreq@fontsize \@minus .4\jlreq@fontsize
  \abovedisplayshortskip \z@ \@plus .3\jlreq@fontsize
  \belowdisplayskip .9\jlreq@fontsize \@plus.3\jlreq@fontsize \@minus.4\jlreq@fontsize
  \belowdisplayshortskip \belowdisplayskip
  \let\@listi\@listI}

\if@tate\tate\fi % ここで発行しておく
\mcfamily\selectfont\normalsize
\setbox0\hbox{　} % 全角スペース
\setlength\Cht{\ht0}
\setlength\Cdp{\dp0}
\setlength\Cwd{\wd0}
\setlength\Cvs{\baselineskip}
\setlength\Chs{\wd0}

% 4.1.3.a
% 文字サイズを基準としているような寸法に対しては，
% \@setfontsizeが実行されるたびに追随して値を変える
% その処理は\jlreq@setfontsizehookに入れる
\let\jlreq@original@@setfontsize=\@setfontsize
\renewcommand*{\@setfontsize}[3]{%
  \jlreq@original@@setfontsize{#1}{#2}{#3}%
  \jlreq@setfontsizehook
}
\def\jlreq@setfontsizehook{}
\appto\jlreq@setfontsizehook{\ifdim\parindent>0pt\setlength{\parindent}{1\jlreq@mol}\fi}

% 2.5.2 \baselineskipは一定の方がよい？
\newcommand{\footnotesize}{%
  \@setfontsize\footnotesize{.8\jlreq@fontsize}{\dimexpr 115\jlreq@baselineskip/170\relax}% 脚注文字サイズの二分より少し小さい値を行間に: 4.2.5.e
  \abovedisplayskip .6\jlreq@gol \@plus.2\jlreq@gol \@minus.4\jlreq@gol
  \abovedisplayshortskip \z@ \@plus.1\jlreq@gol
  \belowdisplayshortskip .3\jlreq@gol \@plus.1\jlreq@gol \@minus.2\jlreq@gol
  \def\@listi{\leftmargin\leftmargini
    \topsep .3\jlreq@gol \@plus.1\jlreq@gol \@minus.1\jlreq@gol
    \parsep .2\jlreq@gol \@plus.1\jlreq@gol \@minus.1\jlreq@gol
    \itemsep \parsep}%
  \belowdisplayskip \abovedisplayskip}
% tsize10.cloの引数を，そのまま\jlreq@fontsize/\jlreq@baselineskipでスケーリングしているだけ．
\newcommand{\small}{%
  \@setfontsize\small{.9\jlreq@fontsize}{\dimexpr 11\jlreq@baselineskip/17\relax}%
  \abovedisplayskip .85\jlreq@gol \@plus.3\jlreq@gol \@minus.4\jlreq@gol
  \abovedisplayshortskip \z@ \@plus.2\jlreq@gol
  \belowdisplayshortskip .4\jlreq@gol \@plus.2\jlreq@gol \@minus.2\jlreq@gol
  \def\@listi{\leftmargin\leftmargini
    \topsep .4\jlreq@gol \@plus.2\jlreq@gol \@minus.2\jlreq@gol
    \parsep .2\jlreq@gol \@plus.1\jlreq@gol \@minus.1\jlreq@gol
    \itemsep \parsep}%
  \belowdisplayskip \abovedisplayskip}
\newcommand{\scriptsize}{\@setfontsize\scriptsize{\dimexpr 7\jlreq@fontsize/10\relax}{\dimexpr 8\jlreq@baselineskip/17\relax}}
\newcommand{\tiny}{\@setfontsize\tiny{\dimexpr 5\jlreq@fontsize/10\relax}{\dimexpr 6\jlreq@baselineskip/17\relax}}
\newcommand{\large}{\@setfontsize\large{\dimexpr12\jlreq@fontsize/10\relax}{\jlreq@baselineskip}}
\newcommand{\Large}{\@setfontsize\Large{\dimexpr14\jlreq@fontsize/10\relax}{\dimexpr 21\jlreq@baselineskip/17\relax}}
\newcommand{\LARGE}{\@setfontsize\LARGE{\dimexpr17\jlreq@fontsize/10\relax}{\dimexpr 25\jlreq@baselineskip/17\relax}}
\newcommand{\huge}{\@setfontsize\huge{2\jlreq@fontsize}{\dimexpr 28\jlreq@baselineskip/17\relax}}
\newcommand{\Huge}{\@setfontsize\Huge{\dimexpr 25\jlreq@fontsize/10\relax}{\dimexpr 33\jlreq@baselineskip/17\relax}}

\if@tate
  \ifx l\jlreq@engine
    \RequirePackage{lltjext}
  \else
    \RequirePackage{plext}
  \fi
  \renewcommand*{\@Kanji}[1]{\expandafter\kansuji\number #1\relax} % \relax追加
  \rensujiskip=0\zh plus 0.25\zh minus 0\zh
\fi

% このあたりはtarticleと同じ
\setlength\lineskip{.1\jlreq@gol}
\setlength\normallineskip{.1\jlreq@gol}
%\setlength\lineskiplimit{1pt}% jsarticleではこう
%\setlength\normallineskiplimit{1pt}% jsarticleではこう
\renewcommand{\baselinestretch}{}
\setlength\parskip{0\p@ \@plus \p@}
\setlength\parindent{1\jlreq@mol}
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

% 二段組み用パラメータ
\setlength{\columnsep}{\jlreq@speciallength{\jlreq@option@column@gap}}
\setlength{\columnseprule}{0pt}

% デフォルト値は縦横ともにが0.5倍．
%.. \textwidth：縦書きは縦，横書きは横
% 一度\textwidthに一行の長さの文字数を入れる（段組の場合でも）
\@tempdima=1\jlreq@fontsize
\ifx\jlreq@option@line@length\@empty
  \if@tate
    \setlength{\textwidth}{0.75\paperheight}
  \else
    \setlength{\textwidth}{0.75\paperwidth}
  \fi
  \if@twocolumn
    \setlength{\textwidth}{\dimexpr(\textwidth - \columnsep)/2\relax}
  \fi
  \divide\textwidth\@tempdima
\else
  \setlength{\textwidth}{\jlreq@speciallength{\jlreq@option@line@length}}
  \divide\textwidth\@tempdima
  \if@tate
    \ifnum\number\textwidth>52
      \jlreq@warning{一行の長さは52文字以下が望ましい (2.4.2.c 注2)}
    \fi
  \else
    \ifnum\number\textwidth>40
      \jlreq@warning{一行の長さは40文字以下が望ましい (2.4.2.c 注2)}
    \fi
  \fi
\fi
\multiply\textwidth\@tempdima
\if@twocolumn
  \setlength{\textwidth}{\dimexpr2\textwidth + \columnsep\relax}
\fi

%.. \textheight：縦書きは横，横書きは縦
\ifx\jlreq@option@number@of@lines\@empty
  \if@tate
    \setlength{\textheight}{0.75\paperwidth}
  \else
    \setlength{\textheight}{0.75\paperheight}
  \fi
\else
  \setlength{\textheight}{\jlreq@speciallength{\jlreq@option@number@of@lines\baselineskip}}
\fi
\divide\textheight\baselineskip \multiply\textheight\baselineskip

\setlength{\topskip}{1\zw} % フォントサイズと一致させる
\setlength{\headsep}{\jlreq@speciallength{\jlreq@option@headfoot@verticalpos}}
\ifdim\headsep<1\zw\jlreq@warning{基本版面との上下方向の最低の空き量を，基本版面の文字サイズの全角アキとする (26.1.a)}\fi
\setlength{\headheight}{1\zh}
%.. 横
\ifx\jlreq@option@gutter\@empty
  % 中央配置
  \setlength{\oddsidemargin}{\paperwidth}
  \if@tate
    \addtolength{\oddsidemargin}{-\textheight}
  \else
    \addtolength{\oddsidemargin}{-\textwidth}
  \fi
  \setlength{\oddsidemargin}{.5\oddsidemargin}
  \addtolength{\oddsidemargin}{-1in}
  \setlength{\evensidemargin}{\oddsidemargin}
\else
  \setlength{\oddsidemargin}{\jlreq@speciallength{\jlreq@option@gutter}}
  \setlength{\evensidemargin}{\dimexpr\paperwidth - \textheight - \oddsidemargin\relax}
  \addtolength{\oddsidemargin}{-1in}
  \addtolength{\evensidemargin}{-1in}
\fi
%.. 縦
\ifx\jlreq@option@head@space\@empty
  \setlength{\topmargin}{\paperheight}
  \if@tate
    \addtolength{\topmargin}{-\textwidth}
  \else
    \addtolength{\topmargin}{-\textheight}
  \fi
  \ifx\jlreq@option@foot@space\@empty
    % 中央配置
    \setlength{\topmargin}{0.5\topmargin}
  \else
    \addtolength{\topmargin}{-\jlreq@speciallength{\jlreq@option@foot@space}}
  \fi
\else
  \ifx\jlreq@option@foot@space\@empty
    \setlength{\topmargin}{\jlreq@speciallength{\jlreq@option@head@space}}
  \else
    % 両方指定されていたら，縦書きは地を，横書きは天を使う
    \if@tate
      \setlength{\topmargin}{\paperheight}
      \addtolength{\topmargin}{-\textwidth}
      \addtolength{\topmargin}{-\jlreq@speciallength{\jlreq@option@foot@space}}
    \else
      \setlength{\topmargin}{\jlreq@speciallength{\jlreq@option@head@space}}
    \fi
  \fi
\fi


\addtolength{\topmargin}{-\headsep}
\addtolength{\topmargin}{-\headheight}
\addtolength{\topmargin}{-1in}
%.. 下
% 本文から一文字分離すつもり
\setlength{\footskip}{2\zh}
% \maxdepth + \topskip = フォントサイズ×1.5
\setlength{\maxdepth}{1.5\jlreq@fontsize}
\addtolength{\maxdepth}{-\topskip}

%. 見出し関係 (4.1)
% 見出しの直前に実行される
\newcommand*{\jlreq@hook@beforeheadings}[1]{}
\def\jlreq@heading@allheadings{}
%.. 中/半扉見出し
% addcontentslineに渡すやつ：番号出すのと出さないの
\newcommand{\jlreq@DeclareTobiraHeading}[5]{
  \appto{\jlreq@heading@allheadings}{,#1}
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}
  \expandafter\def\csname jlreq@heading@setting@#1\endcsname{#3}
  \expandafter\edef\csname jlreq@heading@format@#1\endcsname{\unexpanded{#4}}
  \@ifundefined{c@#1}{\newcounter{#1}}{}
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}
  \@ifundefined{l@#1}{\expandafter\def\csname l@#1\endcsname{\jlreq@set@top@contents{#2}\@dottedtocline{#2}{0\jlreq@mol}{2\jlreq@gol}}}{}
  \begingroup
    \def\jlreq@contents@format##1{##1}
    \edef\jlreq@contents@label@format{\expandonce{\csname the#1\endcsname}}
    \jlreq@parsekeyval[DeclareTobiraHeading]{
      {contentsline_format}{\def\jlreq@contents@format####1{##1}}
      {contentsline_label_format}{\def\jlreq@contents@label@format{##1}}
    }{#3}
    \edef\jlreq@do{
      \noexpand\def\expandonce{\csname jlreq@TobiraHeading@#1\endcsname}[####1]####2{%
        \unexpanded{\ifnum#2>\c@secnumdepth}%
          \unexpanded{\refstepcounter{#1}}%
          \unexpanded{\addcontentsline{toc}{#1}}{\expandonce{\jlreq@contents@label@format}\expandonce{\jlreq@contents@format{##1}}}%
        \noexpand\else
          \expandonce{\csname #1mark\endcsname}{####1}%
          \unexpanded{\addcontentsline{toc}{#1}}{\expandonce{\jlreq@contents@format{##1}}}%
        \noexpand\fi
        \unexpanded{#4}%
        \noexpand\@afterheading
        \unexpanded{#5}%
        \unexpanded{\if@restonecol\twocolumn\fi}%
      }
      \noexpand\def\expandonce{\csname jlreq@TobiraHeading@s@#1\endcsname}####1{%
        \unexpanded{#4}%
        \noexpand\@afterheading
        \unexpanded{#5}%
        \unexpanded{\if@restonecol\twocolumn\fi}%
      }
      \noexpand\def\expandonce{\csname #1\endcsname}{%
        \unexpanded{\if@twocolumn\onecolumn\@restonecoltrue\else\@restonecolfalse\fi\clearpage}%
        \noexpand\secdef{\expandonce{\csname jlreq@TobiraHeading@#1\endcsname}}{\expandonce{\csname jlreq@TobiraHeading@s@#1\endcsname}}}
    }
  \expandafter\endgroup
  \jlreq@do
}

\newcommand{\DeclareHanTobiraHeading}[4]{
  \jlreq@DeclareTobiraHeading{#1}{#2}{#3}{#4}{\clearpage}
}
\newcommand{\NewHanTobiraHeading}[4]{
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareHanTobiraHeading{#1}{#2}{#3}{#4}}
}
\newcommand{\RenewHanTobiraHeading}[4]{
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareHanTobiraHeading{#1}{#2}{#3}{#4}}%
}
\newcommand{\ProvideHanTobiraHeading}[4]{
  \@ifundefined{#1}{\DeclareHanTobiraHeading{#1}{#2}{#3}{#4}}{}
}
\@onlypreamble\DeclareHanTobiraHeading
\@onlypreamble\NewHanTobiraHeading
\@onlypreamble\RenewHanTobiraHeading
\@onlypreamble\ProvideHanTobiraHeading

\newcommand{\DeclareNakaTobiraHeading}[4]{
  \jlreq@DeclareTobiraHeading{#1}{#2}{#3}{#4}{\cleardoublepage}
}
\newcommand{\NewNakaTobiraHeading}[4]{
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareNakaTobiraHeading{#1}{#2}{#3}{#4}}
}
\newcommand{\RenewNakaTobiraHeading}[4]{
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareNakaTobiraHeading{#1}{#2}{#3}{#4}}%
}
\newcommand{\ProvideNakaTobiraHeading}[4]{
  \@ifundefined{#1}{\DeclareNakaTobiraHeading{#1}{#2}{#3}{#4}}{}
}
\@onlypreamble\DeclareNakaTobiraHeading
\@onlypreamble\NewNakaTobiraHeading
\@onlypreamble\RenewNakaTobiraHeading
\@onlypreamble\ProvideNakaTobiraHeading

%.. 別行見出し
% \jlreq@startBlockHeading{1 = 命令名}{2 = レベル}{3 = 字下げ}{4 = 前空き}{5 = 後ろ空き}{6 = トータル行数}{7 =  フォーマット}*{見出し}[副題]
% 字下げはa:**だと追加する値，r:**だとその値に強制する．
\newcommand{\jlreq@startBlockHeading}[7]{%
  \edef\jlreq@startBlockHeading@format{\unexpanded{#7}}%
  \jlreq@startBlockHeading@{#1}{#2}{{#3}{#4}{#5}{#6}}%
}
% {1 = 命令}{2 = レベル}{3 = スペース関連}
\newcommand{\jlreq@startBlockHeading@}[3]{%
  \@ifstar{\jlreq@startBlockHeading@@{#1}{#2}{#3}{*}[]}{\@dblarg{\jlreq@startBlockHeading@@{#1}{#2}{#3}{}}}%
}
% {1 = 命令}{2 = レベル}{3 = スペース関連}{4 = *}[5 = running head]{6 = 見出し}
\long\def\jlreq@startBlockHeading@@#1#2#3#4[#5]#6{%
  \@ifnextchar[{\jlreq@startBlockHeading@@@{#1}{#2}{#3}{#4}{#5}{#6}}{\jlreq@startBlockHeading@@@{#1}{#2}{#3}{#4}{#5}{#6}[]}%
}

% {1 = 命令}{2 = レベル}{3 = スペース関連}{4 = *}{5 = running head}{6 = 見出し}[7 = 副題]
\def\jlreq@startBlockHeading@@@#1#2#3#4#5#6[#7]{%
  \edef\jlreq@do{%
    \unexpanded{\def\jlreq@tempa##1##2##3}{\expandonce{\jlreq@startBlockHeading@format}}%
  }%
  \jlreq@do
  % 後で呼び出す\jlreq@startBlockHeading@addtocontentslineを定義する
  \ifnum0\jlreq@ifempty{#4}{}{1}\ifnum #2>\c@secnumdepth1\fi>0
    \expandafter\def\expandafter\jlreq@tempa\expandafter{\jlreq@tempa{}{#6}{#7}}%
    \def\jlreq@startBlockHeading@addtocontentsline{}%
  \else
    \refstepcounter{#1}%
    \protected@edef\jlreq@svsec{\@seccntformat{#1}\relax}%
    \expandafter\def\expandafter\jlreq@tempa\expandafter{\jlreq@tempa{\jlreq@svsec}{#6}{#7}}%
    \def\jlreq@startBlockHeading@addtocontentsline{%
      \csname #1mark\endcsname{#5}%
      \addcontentsline{toc}{#1}{%
        \protect\numberline{\csname the#1\endcsname}%
        #5}%
    }%
  \fi
  \def\jlreq@do{\jlreq@startBlockHeading@@@@#3}%
  \expandafter\jlreq@do\expandafter{\jlreq@tempa}%
}
\def\jlreq@startBlockHeading@removecolumn#1:{#1}

\def\jlreq@startBlockHeading@analyzespace#1:#2\jlreq@endmark{%
  \jlreq@ifempty{#1}{%
    \def\jlreq@startBlockHeading@spacetype{}%
    \def\jlreq@startBlockHeading@space{}%
  }{%
    \let\jlreq@startBlockHeading@spacetype=#1%
    \expandafter\def\expandafter\jlreq@startBlockHeading@space\expandafter{\jlreq@startBlockHeading@removecolumn#2}%
  }%
}

% {1 = 字下げ}{2 = 前空き}{3 = 後ろ空き}{4 = トータル行数}{5 = 出力}
\long\def\jlreq@startBlockHeading@@@@#1#2#3#4#5{%
  \if@noskipsec\leavevmode\fi
  \setbox\jlreq@tempboxa=\vbox{%
    \jlreq@ifempty{#1}{}{\hsize=\dimexpr\hsize - #1\relax}%
    \noindent #5}%
  \par
  \@afterindenttrue
  % \jlreq@tempskip(a/b)に前/後ろに入れるべき値を入れる
  \jlreq@startBlockHeading@analyzespace#2:\jlreq@endmark
  \setbox\jlreq@tempboxb=\vbox{　}%
  \jlreq@ifempty{#4}{%
    \ifx\jlreq@startBlockHeading@space\@empty\else
      \jlreq@tempskipa=\glueexpr\jlreq@startBlockHeading@space\relax
    \fi
    \jlreq@tempskipb=0pt\relax
  }{%
    \jlreq@tempskipb=\glueexpr(\baselineskip*(#4 + 1) - \ht\jlreq@tempboxb - \dp\jlreq@tempboxb - \ht\jlreq@tempboxa - \dp\jlreq@tempboxa)/2\relax
    \ifx\jlreq@startBlockHeading@space\@empty
      \jlreq@tempskipa=\jlreq@tempskipb
    \else
      \ifx a\jlreq@startBlockHeading@spacetype
        \jlreq@tempskipa=\glueexpr\jlreq@tempskipb + \jlreq@startBlockHeading@space\relax
      \else
        \jlreq@tempskipa=\glueexpr\jlreq@startBlockHeading@space\relax%
        \jlreq@tempskipb=\glueexpr(\baselineskip*(#4 + 1) - \ht\jlreq@tempboxb - \dp\jlreq@tempboxb - \ht\jlreq@tempboxa - \dp\jlreq@tempboxa) - \jlreq@startBlockHeading@space\relax
      \fi
    \fi
  }%
  % \baselineskip分の補正
  \jlreq@tempskipa=\glueexpr\jlreq@tempskipa - \baselineskip + \dp\jlreq@tempboxb\relax
  \jlreq@startBlockHeading@addtocontentsline
  \setbox\jlreq@tempboxa=\vbox{%
    \ifdim\jlreq@tempskipa=0pt\else\vskip\jlreq@tempskipa\fi
    \noindent
    \jlreq@ifempty{#1}{}{\hskip #1}%
    \box\jlreq@tempboxa\nopagebreak}%
  \dp\jlreq@tempboxa=\dimexpr\dp\jlreq@tempboxa + \ht\jlreq@tempboxa\relax
  \ht\jlreq@tempboxa=0pt
  \box\jlreq@tempboxa
  \par\nopagebreak
  \prevdepth=0pt
  \jlreq@startBlockHeading@analyzespace#3:\jlreq@endmark
  \jlreq@tempskipb=\glueexpr\jlreq@tempskipb + \ht\jlreq@tempboxb - \baselineskip\relax
  \ifx\jlreq@startBlockHeading@space\@empty\else
    \ifx a\jlreq@startBlockHeading@spacetype
      \jlreq@tempskipb = \glueexpr\jlreq@tempskipb + \jlreq@startBlockHeading@space\relax
    \else
      \jlreq@tempskipb=\glueexpr\jlreq@startBlockHeading@space + \ht\jlreq@tempboxb - \baselineskip\relax
    \fi
  \fi
  \ifdim\jlreq@tempskipb=0pt\else\vskip\jlreq@tempskipb\fi
}

% \DeclareBlockHeading{命令名}{レベル}{設定}
% 行取り（4.1.6）
% a: lines=<何行取りか>
% b,d: before_lines, after_lines
% c: before_space, after_space
% f: beforeやafterを省略する
% font=<見出しフォント>, labelfont=<ラベルフォント>, subtitle_font=<副題フォント>
% indent=<全体のインデント>
% pagebreak=\clearpage/\cleardoublepage/\newpage/（無し）
% なお，これ以外に見出しの前後に記号を付ける，あるいは罫線を見出しの前後に配置する，罫線で見出しを囲むなどといったことも行われている．
% 縦組の偶数ページの場合は，ページ末に見出しを配置する．
\newcommand{\DeclareBlockHeading}[3]{
  \appto{\jlreq@heading@allheadings}{,#1}
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}
  \expandafter\def\csname jlreq@heading@setting@#1\endcsname{#3}
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewBlockHeading}
  \@ifundefined{c@#1}{\newcounter{#1}}{}
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}
  \@ifundefined{l@#1}{\expandafter\def\csname l@#1\endcsname{\jlreq@set@top@contents{#2}\@dottedtocline{#2}{0\jlreq@mol}{2\jlreq@gol}}}{}
  \begingroup
    \def\jlreq@lines{1}
    \def\jlreq@before@space{}
    \def\jlreq@after@space{}
    \def\jlreq@before@lines{}
    \def\jlreq@after@lines{}
    \def\jlreq@font{\normalsize}
    \def\jlreq@subtitle@font{\normalsize}
    \def\jlreq@indent{0}
    \def\jlreq@format{}
    \def\jlreq@pagebreak{}
    \jlreq@parsekeyval[BlockHeading]{
      {lines}{\def\jlreq@lines{##1}}
      {before_space}{\def\jlreq@before@space{##1}}
      {after_space}{\def\jlreq@after@space{##1}}
      {before_lines}{\def\jlreq@before@lines{##1}}
      {after_lines}{\def\jlreq@after@lines{##1}}
      {font}{\def\jlreq@font{##1}}
      {subtitle_font}{\def\jlreq@subtitle@font{##1}}
      {indent}{\def\jlreq@indent{##1}}
      {format}{\edef\jlreq@format{\unexpanded{##1}}}
      {pagebreak}[clearpage,cleardoublepage,clearcolumn,nariyuki]{
        \jlreq@switch{##1}{
          {clearpage}{\def\jlreq@pagebreak{\clearpage}}
          {cleardoublepage}{\def\jlreq@pagebreak{\cleardoublepage}}
          {clearcolumn}{\if@twocolumn\def\jlreq@pagebreak{\newpage}\else\def\jlreq@pagebreak{}\fi}
          {nariyuki}{\def\jlreq@pagebreak{}}
        }
      }
    }{#3}
    % before/after_lines優先
    \ifx\jlreq@before@space\@empty\else\edef\jlreq@before@space{r:\expandonce{\jlreq@before@space}}\fi
    \ifx\jlreq@before@lines\@empty\else\edef\jlreq@before@space{a:\expandonce{\jlreq@before@lines}\baselineskip}\fi
    \ifx\jlreq@after@space\@empty\else\edef\jlreq@after@space{r:\expandonce{\jlreq@after@space}}\fi
    \ifx\jlreq@after@lines\@empty\else\edef\jlreq@after@space{a:\expandonce{\jlreq@after@lines}\baselineskip}\fi
    \ifx\jlreq@indent\@empty\else\edef\jlreq@indent{\expandonce{\jlreq@indent}\jlreq@mol}\fi
    \ifx\jlreq@format\@empty
      \edef\jlreq@format{%
        \expandonce{\jlreq@font} \unexpanded{##1} \unexpanded{##2}%
        \unexpanded{\jlreq@ifempty{##3}{}}{\noexpand\nobreak\noexpand\par\expandonce{\jlreq@subtitle@font}\unexpanded{##3}}%
      }
    \fi
    \global\edef\jlreq@tempa{%
      \expandonce{\jlreq@pagebreak}%
      \unexpanded{\jlreq@startBlockHeading{#1}{#2}}{\expandonce{\jlreq@indent}}{\expandonce{\jlreq@before@space}}{\expandonce{\jlreq@after@space}}{\expandonce{\jlreq@lines}}{\expandonce{\jlreq@format}}%
    }
  \endgroup
  \expandafter\edef\csname #1\endcsname{\noexpand\jlreq@hook@beforeheadings{#1}\expandonce{\jlreq@tempa}}
}

\newcommand{\NewBlockHeading}[3]{
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareBlockHeading{#1}{#2}{#3}}
}
\newcommand{\RenewBlockHeading}[3]{
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareBlockHeading{#1}{#2}{#3}}%
}
\newcommand{\ProvideBlockHeading}[3]{
  \@ifundefined{#1}{\DeclareBlockHeading{#1}{#2}{#3}}{}
}
\@onlypreamble\DeclareBlockHeading
\@onlypreamble\NewBlockHeading
\@onlypreamble\RenewBlockHeading
\@onlypreamble\ProvideBlockHeading

%.. 同行見出し
% \DeclareRuninHeading{命令名}{レベル}{設定}
\newcommand*{\DeclareRuninHeading}[3]{%
  \appto{\jlreq@heading@allheadings}{,#1}
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\def\csname jlreq@heading@setting@#1\endcsname{#3}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewRuninHeading}
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \@ifundefined{l@#1}{\expandafter\def\csname l@#1\endcsname{\jlreq@set@top@contents{#2}\@dottedtocline{#2}{0\jlreq@mol}{2\jlreq@gol}}}{}
  \begingroup
    \def\jlreq@font{\normalfont\normalsize}%
    \def\jlreq@indent{1}%
    \def\jlreq@mark{}%
    \jlreq@parsekeyval[RuninHeading]{
      {font}{\def\jlreq@font{##1}}
      {indent}{\def\jlreq@indent{##1}}
      {mark}{\def\jlreq@mark{##1}}
    }{#3}%
    % \@startsection{#1}{#2}{<indent>*fontsize}{0pt}{-fontsize}{font}
    \global\edef\@tempa{{\unexpanded{#1}}{\unexpanded{#2}}{\expandonce{\jlreq@indent}\jlreq@mol}{0pt}{-1\jlreq@fontsize}{\expandonce{\jlreq@font}\expandonce{\jlreq@mark}}}%
  \endgroup
  \expandafter\edef\csname #1\endcsname{\noexpand\jlreq@hook@beforeheadings{#1}%
    \noexpand\@startsection\expandonce{\@tempa}}%
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

\@onlypreamble\DeclareRuninHeading
\@onlypreamble\NewRuninHeading
\@onlypreamble\RenewRuninHeading
\@onlypreamble\ProvideRuninHeading

%.. 窓見出し
\newcount\jlreq@wraplinecount
\newdimen\jlreq@hangindent
\def\jlreq@CutinHeading@start#1#2#3#4#5#6#7{%
  \ifnum0\ifnum\jlreq@wraplinecount<-1 1\fi\ifnum\jlreq@wraplinecount>1 1\fi>0\relax
    \ClassError{jlreq}{Can not use \expandafter\string\csname#1\endcsname\space here}{\@ehc}%
  \else
    \jlreq@CutinHeading@@start{#2}{#3}{#4}{#5}{#6}{#7}%
  \fi
}
% 1 = 書式指定，2 = インデント, 3 = 見出しと本文の間, 4 = これを越えたら二行以上，5 = これを越えたら三行以上，6 = テキスト
\def\jlreq@CutinHeading@@start#1#2#3#4#5#6{%
  \par\leavevmode
  % 一行で処理したときの見出し長さを計測
  \setbox\@tempboxa=\hbox{#1#6}%
  \@tempdima=\wd\@tempboxa
  % 何行必要かを\jlreq@CutinHeading@linecountに入れる
  \ifdim\@tempdima>#5\def\jlreq@CutinHeading@linecount{3}%
  \else\ifdim\@tempdima>#4\def\jlreq@CutinHeading@linecount{2}%
  \else\def\jlreq@CutinHeading@linecount{1}\fi\fi
  % \@tempdimaが実際の一行の長さに近い
  \divide\@tempdima by \jlreq@CutinHeading@linecount
  % \jlreq@resultboxに見出し部分を，\jlreq@CutinHeading@linecountに何行使うかを入れる
  \ifnum\jlreq@CutinHeading@linecount=1\relax
    \setbox\jlreq@resultbox=\vbox{\parindent=0pt\rightskip=0pt\leftskip=0pt\hbox{#1#6}}%
    \def\jlreq@CutinHeading@linecount{2}%
  \else
    \jlreq@inlinenote@determinelength{#6}{#1}{}{\jlreq@CutinHeading@linecount}{\jlreq@CutinHeading@linecount}{\@tempdima}{\linewidth}%
    \def\jlreq@CutinHeading@linecount{3}%
  \fi
  % 普通の一行の高さ/深さに合わせて見出しのボックスを出力
  \setbox\@tempboxa=\vtop to \dimexpr\jlreq@CutinHeading@linecount\baselineskip\relax{\vskip 0pt plus 1fill minus 1fill \box\jlreq@resultbox\vskip 0pt plus 1fill minus 1fill}%
  \setbox\jlreq@tempboxa=\hbox{あ}%
  \ht\@tempboxa=\ht\jlreq@tempboxa
  \dp\@tempboxa=\dp\jlreq@tempboxa
  \@tempdima=\wd\@tempboxa
  % \hang****を設定
  \hangindent=\dimexpr#2\jlreq@mol + \@tempdima + #3\relax\hangafter=-\jlreq@CutinHeading@linecount
  \jlreq@hangindent=\hangindent\jlreq@wraplinecount=\hangafter
  \hspace*{#2\jlreq@mol}%
  \kern-\dimexpr\@tempdima + #3 + \parindent\relax
  \box\@tempboxa
  \hspace*{#3}%
  % 改段落が起こっても\hang****をキープするように\parを書き換えておく（終わったら元に戻す）．
  % \jlreq@hangindent/\jlreq@wraplinecountにそれぞれ\hangindent/\hangafterに対応する値を入れて
  % \parのたびにそこから代入する．
  \def\par{%
    \@@par
    \ifnum\jlreq@wraplinecount<-1\relax
      \ifnum\jlreq@wraplinecount<-\prevgraf
        \advance\jlreq@wraplinecount by \prevgraf\hangindent=\jlreq@hangindent\hangafter=\jlreq@wraplinecount
      \else
        \jlreq@wraplinecount=1\jlreq@hangindent=0pt\relax
        \@restorepar
      \fi
    \else
      \jlreq@wraplinecount=1\jlreq@hangindent=0pt\relax
      \@restorepar
    \fi
  }%
  \ignorespaces
}

\newcommand*{\DeclareCutinHeading}[3]{%
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}
  \expandafter\def\csname jlreq@heading@setting@#1\endcsname{#3}
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewCutinHeading}
  \begingroup
    \def\jlreq@fontcommand{\headfont}%
    \def\jlreq@onelinemax{6\jlreq@fontsize}%
    \def\jlreq@twolinemax{20\jlreq@fontsize}%
    \def\jlreq@indent{0}%
    \def\jlreq@afterindent{1\zh}%
    \jlreq@parsekeyval[CutinHeading]{
      {font}{\def\jlreq@fontcommand{##1}}%
      {onelinemax}{\def\jlreq@onelinemax{##1}}%
      {twolinemax}{\def\jlreq@twolinemax{##1}}%
      {indent}{\def\jlreq@indent{##1}}%
      {afterindent}{\def\jlreq@afterindent{##1}}%
    }{#3}%
    \global\edef\@tempa{{#1}{\expandonce{\jlreq@fontcommand}}{\expandonce{\jlreq@indent}}{\expandonce{\jlreq@afterindent}}{\expandonce{\jlreq@onelinemax}}{\expandonce{\jlreq@twolinemax}}}
  \endgroup
  \expandafter\edef\csname #1\endcsname{\noexpand\jlreq@hook@beforeheadings{#1}%
    \noexpand\jlreq@CutinHeading@start\expandonce{\@tempa}}
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
\@onlypreamble\DeclareCutinHeading
\@onlypreamble\NewCutinHeading
\@onlypreamble\RenewCutinHeading
\@onlypreamble\ProvideCutinHeading

\newcommand*{\ModifyHeading}[2]{
  \begingroup
    \expandafter\let\expandafter\level\expandafter=\csname jlreq@heading@level@#1\endcsname
    \expandafter\let\expandafter\setting\expandafter=\csname jlreq@heading@setting@#1\endcsname
    \expandafter\let\expandafter\macroname\expandafter=\csname jlreq@heading@type@#1\endcsname
    \edef\jlreq@do{\expandonce{\macroname}{#1}{\expandonce{\level}}{\expandonce{\setting},\unexpanded{#2}}}
  \expandafter\endgroup
  \jlreq@do
}
\@onlypreamble\ModifyHeading

\newcommand*{\jlreq@keepbaselineskip}[1]{%
  \begingroup
    \jlreq@tempdima=\baselineskip
    \edef\jlreq@do{\unexpanded{#1}\noexpand\baselineskip=\the\jlreq@tempdima}%
  \expandafter\endgroup
  \jlreq@do
}

\setcounter{secnumdepth}{3}
\newcounter{part}
\newcounter{section}
\newcounter{subsection}[section]
\newcounter{subsubsection}[subsection]
\newcounter{paragraph}[subsubsection]
\newcounter{subparagraph}[paragraph]
\renewcommand*{\@seccntformat}[1]{\csname the#1\endcsname\hspace{1\jlreq@mol}}
\newcommand*{\headfont}{\gtfamily\sffamily}

%.. 各種定義
\if@tate
  \NewBlockHeading{part}{0}{font={\jlreq@keepbaselineskip{\LARGE\headfont}},indent=4,lines=4}
  \NewBlockHeading{section}{1}{font={\jlreq@keepbaselineskip{\Large\headfont}},indent=6,lines=3}
  \NewBlockHeading{subsection}{2}{font={\jlreq@keepbaselineskip{\large\headfont}},indent=8,lines=2}
  \NewBlockHeading{subsubsection}{3}{font={\jlreq@keepbaselineskip{\normalsize\headfont}},indent=10,lines=1,before_lines=1}
  \NewRuninHeading{paragraph}{4}{font={\jlreq@keepbaselineskip{\normalsize\headfont}}}
  \NewRuninHeading{subparagraph}{5}{font={\jlreq@keepbaselineskip{\normalsize\headfont}}}
  \renewcommand{\thepart}{\Kanji{part}}
  \renewcommand{\thesection}{\rensuji{\@arabic\c@section}}
  \renewcommand{\thesubsection}{\rensuji{\@alph\c@subsection}}
  \renewcommand{\thesubsubsection}{%
    \rensuji{\@arabic\c@subsubsection}}
  \renewcommand{\theparagraph}{%
    (\rensuji{\@arabic\c@paragraph})}
  \renewcommand{\thesubparagraph}{%
    (\rensuji{\@arabic\c@subparagraph})}
  \newcommand{\appendix}{\par
    \setcounter{section}{0}%
    \setcounter{subsection}{0}%
    \renewcommand{\thesection}{\rensuji{\@Alph\c@section}}}
\else
  \NewBlockHeading{part}{0}{font={\jlreq@keepbaselineskip{\LARGE\headfont}},lines=4}
  \NewBlockHeading{section}{1}{font={\jlreq@keepbaselineskip{\Large\headfont}},lines=3}
  \NewBlockHeading{subsection}{2}{font={\jlreq@keepbaselineskip{\large\headfont}},lines=2}
  \NewBlockHeading{subsubsection}{3}{font={\jlreq@keepbaselineskip{\normalsize\headfont}},lines=1,before_lines=1}
  \NewRuninHeading{paragraph}{4}{font={\jlreq@keepbaselineskip{\normalsize\headfont}}}
  \NewRuninHeading{subparagraph}{5}{font={\jlreq@keepbaselineskip{\normalsize\headfont}}}
  \renewcommand{\thepart}{\Roman{part}}
  \renewcommand{\thesection}{\arabic{section}}
  \renewcommand{\thesubsection}{\thesection .\arabic{subsection}}
  \renewcommand{\thesubsubsection}{\thesubsection .\arabic{subsubsection}}
  \renewcommand{\theparagraph}{\thesubsubsection .\arabic{paragraph}}
  \renewcommand{\thesubparagraph}{\theparagraph .\arabic{subparagraph}}
  \newcommand{\appendix}{\par
    \setcounter{section}{0}%
    \setcounter{subsection}{0}%
    \renewcommand{\thesection}{\@Alph\c@section}}
\fi

%. 注
% 合印：4.2.3
% 文字サイズは6ポイントくらい（4.2.3.a）とりあえす\scriptsize
\newcommand*\jlreq@referencemark@format[1]{#1}
\ifthenelse{\equal{\jlreq@referencemark}{inline}}{
  \newcommand*{\jlreq@notemark}[1]{%
    \jlreq@ifydir{%
      \hbox{}\hbox{\@textsuperscript{\normalfont\jlreq@referencemark@format{#1}}}\hbox{}%
    }{%
      \setbox\@tempboxa=\hbox{\scriptsize\jlreq@referencemark@format{#1}}%
      \raise\dimexpr.5\jlreq@gol - (\ht\@tempboxa + \dp\@tempboxa)/2\relax\box\@tempboxa
    }%
  }
}{
  \newcommand*{\jlreq@notemark}[1]{{%
    \setbox\@tempboxa=\hbox{\scriptsize\jlreq@referencemark@format{#1}}%
    % 行頭に来たときに頭を天にそろえる処理．
    \jlreq@savepos@for@rest@linewidth
    \ifdim\jlreq@current@linewidth<\wd\@tempboxa
      \@tempdima=\jlreq@current@linewidth
    \else
      \@tempdima=\wd\@tempboxa
    \fi
    \setbox\jlreq@tempboxa=\hbox to\z@{\hskip-\@tempdima\raise\dimexpr.5\zw + (\ht\@tempboxa + \dp\@tempboxa)/2\relax\box\@tempboxa\hss}%
    \dp\jlreq@tempboxa=0pt\ht\jlreq@tempboxa=0pt\box\jlreq@tempboxa}}%
}
% \@footnotemarkをシンプルなものにする
\def\jlreq@setdefaultnotemark#1#2{%
  \def#1{%
    \leavevmode
    \ifhmode\edef\@x@sf{\the\spacefactor}\nobreak\fi
    #2%
    \ifhmode\spacefactor\@x@sf\fi
    \relax}
}
\let\jlreq@original@@footnotemark=\@footnotemark
\jlreq@setdefaultnotemark\@footnotemark\@makefnmark
%.. 脚注  （縦書きの時は傍注，4.2.5）
{%
  \footnotesize\global\setlength{\footnotesep}{.7\baselineskip} % 何でかわからん……
  % \jlreq@tempdimaに罫線と脚注との間の長さを入れる
  % 脚注の行間よりやや広くする（4.2.5.f）
  \global\jlreq@tempdima=1.5\dimexpr\baselineskip - 1\jlreq@gol\relax
}
% 罫線の前は行間分，最大＋文字サイズ分伸びる（4.2.5.g）
\setlength{\skip\footins}{\dimexpr\baselineskip - 1\jlreq@gol \relax plus 1\jlreq@gol}
%\setlength{\skip\footins}{0pt}
% 脚注の前の罫線は表罫で，長さは行長の1/3位（4.2.5.f）
\edef\jlreq@do{
  \unexpanded{\renewcommand{\footnoterule}}{%
    \unexpanded{\hrule width .333\textwidth height \jlreq@omotekeiwidth}%
    \noexpand\kern\the\jlreq@tempdima
  }
}
\jlreq@do

% インデントの計算：脚注の長さが文字の整数倍になるように字下げする（4.2.5.b）
{
  \footnotesize
  \jlreq@footnoteindent=1\jlreq@mol
  \@tempdima=\dimexpr\textwidth - \jlreq@footnoteindent\relax
  \@tempdimb=1\zw
  \divide\@tempdima\@tempdimb \multiply\@tempdima\@tempdimb
  \global\jlreq@footnoteindent=\dimexpr\textwidth - \@tempdima\relax
}
% 4.2.5.d
\ifthenelse{\equal{\jlreq@footnotetext@indent}{one}}{
  \newcommand\@makefntext[1]{\parindent 1\jlreq@mol
    \addtolength{\leftskip}{\dimexpr\jlreq@footnoteindent + 1\jlreq@mol\relax}% 全体をインデント+1文字分下げる
    \noindent\hskip -1\jlreq@mol\jlreq@referencemark@format{\@thefnmark}\hskip 1\jlreq@mol#1}% 見出し出力と一文字分の空き
}{
  \newcommand\@makefntext[1]{\parindent 1\jlreq@mol
    \addtolength{\leftskip}{\jlreq@footnoteindent}% 全体をインデント
    \noindent\hskip 1\jlreq@mol\jlreq@referencemark@format{\@thefnmark}\hskip 1\jlreq@mol#1}% 見出し出力と一文字分の空き
}
% 合印
\renewcommand*{\@makefnmark}{%
  \jlreq@ifydir{\jlreq@notemark{\@thefnmark}}{\hbox{\jlreq@notemark{\@thefnmark}}}%
}
% 図4.61のようにする
\if@tate
  \renewcommand*{\thefootnote}{\jlreq@open@bracket@before@space\inhibitglue（\rensuji{\@arabic\c@footnote}）\inhibitglue}
\else
  \renewcommand*{\thefootnote}{\jlreq@open@bracket@before@space\inhibitglue（\arabic{footnote}）\inhibitglue}
\fi

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
\def\jlreq@endnote@addtext#1#2{%
  \expandafter\gdef\expandafter\jlreq@endnote@texts\expandafter{\jlreq@endnote@texts{{#1}{#2}}}}
\def\endnote{\@ifnextchar[{\jlreq@endnote}{\jlreq@endnote[]}}
\def\endnotemark{\@ifnextchar[{\jlreq@endnotemark}{\jlreq@endnotemark[]}}
\def\endnotetext{\@ifnextchar[{\jlreq@endnotetext}{\jlreq@endnotetext[]}}
\long\def\jlreq@endnote[#1]#2{\jlreq@endnotemark[#1]\@endnotetext{#2}}
\def\jlreq@endnotemark[#1]{%
  \jlreq@ifempty{#1}{%
    \stepcounter{\jlreq@endnotecounter}%
    \expandafter\protected@xdef\csname\jlreq@endnotemarkname\endcsname{\csname the\jlreq@endnotecounter\endcsname}%
  }{%
    \begingroup
      \csname c@\jlreq@endnotecounter\endcsname #1\relax
      \expandafter\unrestored@protected@xdef\csname\jlreq@endnotemarkname\endcsname{\csname \jlreq@endnotecounter\endcsname}%
    \endgroup
  }%
  \@endnotemark
}
\jlreq@setdefaultnotemark\@endnotemark\@makeendmark
\long\def\jlreq@endnotetext[#1]#2{%
  \jlreq@ifempty{#1}{%
    \expandafter\protected@xdef\csname\jlreq@endnotemarkname\endcsname{\csname the\jlreq@endnotecounter\endcsname}%
  }{%
    \begingroup
      \csname c@\jlreq@endnotecounter\endcsname #1\relax
      \expandafter\unrestored@protected@xdef\csname\jlreq@endnotemarkname\endcsname{\csname \jlreq@endnotecounter\endcsname}%
    \endgroup
  }%
  \@endnotetext{#2}%
}
\def\@endnotetext#1{%
  \expandafter\let\expandafter\jlreq@tempa\expandafter=\csname\jlreq@endnotemarkname\endcsname
  \expandafter\jlreq@endnote@addtext\expandafter{\jlreq@tempa}{#1}%
}
\def\jlreq@theendnotes#1{%
  \ifx\jlreq@endmark#1\else
    \jlreq@output@endnotes#1
    \expandafter\jlreq@theendnotes
  \fi
}
\def\jlreq@output@endnotes#1#2{%
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
        \leftmargin=\dimexpr\linewidth - \jlreq@tempdima\relax
        \itemindent=0pt\relax
        \topsep=\jlreq@endnote@beforeafterspace
      }%
      \expandafter\jlreq@theendnotes\jlreq@tempa\jlreq@endmark
      \end{list}
    \endgroup
    \par
  \fi
}

\jlreq@endnote@indent=2\jlreq@mol
% 二行目以降を全角分下げる
\newcommand{\@makeendtext}[1]{\parindent 1\jlreq@mol
    \hskip-1\jlreq@mol\csname\jlreq@endnotemarkname\endcsname\hskip 1\jlreq@mol#1}% 見出し出力と一文字分の空き
\def\@makeendmark{\@makefnmark}

% \theendnoteの出力を仕込む
\jlreq@tempafalse
% \jlreq@tempcにセクション名たちを入れていく
\def\jlreq@tempc{}
\@for\jlreq@tempa:=\jlreq@endnote@position\do{
  \jlreq@switch{\jlreq@tempa}{
    {_headings}{\jlreq@tempatrue}
    {_paragraph}{
      \jlreq@tempatrue% _paragraphの時は_headingsも有効にする
      \PushPostHook{par}{%
        \ifx\jlreq@endnote@texts\@empty\else
          \vskip\dimexpr-\baselineskip\relax
          \vskip\dimexpr0pt\relax
          \theendnotes
        \fi
      }
    }
    {\edef\jlreq@tempc{\jlreq@tempc,\jlreq@tempa}}
  }
}

\ifjlreq@tempa
  \edef\jlreq@do{%
    \unexpanded{\def\jlreq@hook@beforeheadings#1}{\expandonce{\jlreq@hook@beforeheadings{#1}}%
      \noexpand\theendnotes
    }
  }
  \jlreq@do
\else
  \@for\@tempa:=\jlreq@tempc\do{
    \ifx\@tempa\@empty\else
      \edef\jlreq@do{%
        \unexpanded{\def\jlreq@hook@beforeheadings#1}{\expandonce{\jlreq@hook@beforeheadings{#1}}%
          \unexpanded{\def\@tempa}{\@tempa}\unexpanded{\def\@tempb{#1}}%
          \unexpanded{\ifx\@tempa\@tempb\theendnotes\fi}%
        }
      }
      \jlreq@do
    \fi
  }
\fi
\AtEndDocument{\theendnotes}

%.. 傍注（4.2.7）
\setlength{\marginparsep}{2\jlreq@mol} % フォントサイズ×2（4.2.7：特に問題に～e）
{%
  \footnotesize
  \setlength{\jlreq@tempdima}{\dimexpr \paperwidth - \textwidth - 1in - \oddsidemargin - \marginparsep\relax}
  \ifx\jlreq@option@sidenote@width\@empty
    \setlength{\marginparwidth}{\dimexpr\jlreq@tempdima-2\jlreq@fontsize\relax}
  \else
    \setlength{\marginparwidth}{\jlreq@speciallength{\jlreq@option@sidenote@width}}
    \ifnum\marginparwidth>\jlreq@tempdima
      \ClassWarningNoLine{jlreq}{sidenote_width is greater than the width of the margin}
    \fi
  \fi
  \ifdim\marginparwidth>18\jlreq@mol
    \global\marginparwidth=18\jlreq@mol
  \else
    \@tempdima=1\zw% 1\jlreq@mol
    \global\divide\marginparwidth\@tempdima
    \global\multiply\marginparwidth\@tempdima
  \fi
  \global\setlength{\marginparpush}{.5\@tempdima} % 同上：g
}

\def\jlreq@sidenotemarkname{@thefnmark}% 合印用番号を一時的に入れるマクロ名

% (1) \footnoteとかと同じ形式 sidenote_type=number
% (2) 文中にマークを入れて，傍注には見出しが入る sidenote_type=mark
% (3) 文中は強調文字列，傍注には見出しが入る sidenote_type=font
% (4) 文中は何も無し，傍注には見出しが入る sidenote_type=none

% (1) では\sidenote[]{}を定義
% (2) では\sidenote{見出し}{注中身}を定義
\def\@sidenotetext#1{%
  \marginpar{\reset@font\footnotesize
    \color@begingroup
    \@makesidetext{#1}%
    \color@endgroup
  }%
}
\jlreq@setdefaultnotemark\@sidenotemark\@makesidemark
\ifthenelse{\equal{\jlreq@sidenote@type}{number}}{
  \def\jlreq@sidenotecounter{footnote}% 傍注用のカウンタ名
  \def\sidenote{\@ifnextchar[{\jlreq@sidenote}{\jlreq@sidenote[]}}
  \def\sidenotemark{\@ifnextchar[{\jlreq@sidenotemark}{\jlreq@sidenotemark[]}}
  \def\sidenotetext{\@ifnextchar[{\jlrqe@sidenotetext}{\jlreq@sidenotetext[]}}
  \long\def\jlreq@sidenote[#1]#2{\jlreq@sidenotemark[#1]\@sidenotetext{#2}}
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
  \def\@sidenotemark{\@makesidemark}
  \ifx l\jlreq@engine
    \def\@makesidetext#1{\csname\jlreq@sidenotemarkname\endcsname\hspace{0.5\jlreq@mol}#1}
  \else
    % thefootnote = \inhibitglue （...だと\inhibitglueが効かない
    \def\@makesidetext#1{　\kern-1\zw\csname\jlreq@sidenotemarkname\endcsname\hspace{0.5\jlreq@mol}#1}
  \fi
  \def\@makesidemark{\@makefnmark}
}{
  \def\jlreq@sidenote@keywordfont{\headfont}
  \def\jlreq@sidenote@defaultmark{＊}
  \def\sidenote{\jlreq@sidenote}
  \def\sidenotemark{\jlreq@sidenotemark}
  \def\sidenotetext{\jlreq@sidenotetext}
  \def\jlreq@sidenote#1#2{\jlreq@sidenotemark{#1}\jlreq@sidenotetext{#1}{#2}}
  \def\jlreq@sidenotemark#1{%
    {\reset@font\jlreq@sidenote@keywordfont #1}%
    \ifx\jlreq@sidenote@defaultmark\@empty\else
      \expandafter\edef\csname\jlreq@sidenotemarkname\endcsname{\jlreq@sidenote@defaultmark}%
      \@sidenotemark
    \fi
  }
  \def\@sidenotemark{\@makesidemark}
  \def\jlreq@sidenotetext#1#2{%
    \expandafter\def\csname\jlreq@sidenotemarkname\endcsname{\jlreq@sidenote@defaultmark\inhibitglue\null{\reset@font\jlreq@sidenote@keywordfont\inhibitglue #1}}%
    \@sidenotetext{#2}%
  }
  \def\@makesidetext#1{{\headfont\csname\jlreq@sidenotemarkname\endcsname}\hspace*{1\jlreq@mol}#1}
  \def\@makesidemark{\@makefnmark}
}

%.. 割注（3.4）
\def\inlinenotesize{.6\jlreq@fontsize} % 割注の文字サイズ
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
\newcommand*{\inlinenote}{%
  \ifjlreq@in@inlinenote\ClassError{jlreq}{\string\inlinenote\space can't be nested}{\@ehc}\fi
  \jlreq@in@inlinenotetrue
  \ifvmode\leavevmode\fi
  \@ifstar\jlreq@inlinenote@noauto\jlreq@inlinenote@auto}
\let\warichu=\inlinenote

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
  % 「初回」時はここに強制改行を入れる．これにより現在位置の取得がより正しくなる
  \jlreq@savepos@iflabelundefined{\message{linebreak inserted}\\}{}%
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
    \@tempcntb=\number\jlreq@tempdima
    \multiply\@tempcntb by 2\relax
    \advance\@tempcntb by 4\relax
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
    \ClassWarning{jlreq}{\string\inlinenote\space failed, maybe a bug}%
  \else
    \@tempcnta=0\relax
    \splittopskip=0pt\relax
    \splitmaxdepth=\maxdimen
    % 現在行の残り長さを思い出す
    \jlreq@tempdimb=\jlreq@rest@linewidth
    \setbox\@tempboxa=\hbox{\jlreq@inlinenote@kakkofontsize\inhibitglue\jlreq@open@bracket@before@space（\inhibitglue}%
    \addtolength{\jlreq@tempdimb}{-\wd\@tempboxa}%
    \setbox\@tempboxa=\box\jlreq@resultbox
    \@whilenum\@tempcnta<\jlreq@inlinenote@lines\do{%
      \ifnum\@tempcnta>0\relax\jlreq@inlinenote@autolinebreak\fi
      % \jlreq@tempdimaに今の行の長さを入れる
      \ifnum\@tempcnta<\numexpr\jlreq@inlinenote@lines - 2\relax
        \ifnum\@tempcnta=0\jlreq@tempdima=\jlreq@tempdimb
        \else\jlreq@tempdima=\linewidth\fi
      \else
        \jlreq@tempdima=-1pt\relax
      \fi
      {%
        \edef\@tempa{\the\vbadness}%
        \vbadness=10000\relax
        \setbox\jlreq@tempboxa=\vsplit\@tempboxa to \dimexpr\jlreq@inlinenote@baselineskip*2\relax
        \vbadness=\@tempa\relax
        % \jlreq@inlinenote@autolinebreak=\\の場合には，割注の長さを計測した物に長さに強制する
        \jlreq@getlastbox{\jlreq@tempboxa}%
        \setbox\jlreq@tempboxb=\box\jlreq@resultbox
        \jlreq@getlastbox{\jlreq@tempboxa}%
        \setbox\jlreq@tempboxa=\box\jlreq@resultbox
        \ifx\jlreq@inlinenote@autolinebreak\\\relax
          \ifdim\jlreq@tempdima>0pt\relax
            \setbox\jlreq@tempboxa=\vbox{\jlreq@inlinenote@fontsize%
              \hbox to \jlreq@tempdima{\unhbox\jlreq@tempboxa}%
              \hbox to \jlreq@tempdima{\unhbox\jlreq@tempboxb}}%
          \else
            \setbox\jlreq@tempboxa=\vbox{\jlreq@inlinenote@fontsize%
              \hbox{\unhbox\jlreq@tempboxa}%
              \hbox{\unhbox\jlreq@tempboxb}}%
          \fi
        \else
          \setbox\jlreq@tempboxa=\vbox{\jlreq@inlinenote@fontsize%
            \hbox to \jlreq@tempdima{\unhbox\jlreq@tempboxa}%
            \hbox to \jlreq@tempdima{\unhbox\jlreq@tempboxb}}%
        \fi
        \jlreq@box@putcenter\jlreq@tempboxa
      }%
      \advance\@tempcnta by 2\relax
    }%
  \fi
  \jlreq@inlinenote@endnote
}

\newcommand*{\jlreq@inlinenote@noauto}[1]{%
  \setbox\jlreq@tempboxa=\hbox{\jlreq@inlinenote@kakkofontsize\jlreq@open@bracket@before@space（}%
  \inhibitglue\jlreq@box@putcenter\jlreq@tempboxa
  \jlreq@inlinenote@noauto@#1\\\jlreq@endmark\jlreq@endmark
  \jlreq@inlinenote@endnote
}

\def\jlreq@inlinenote@noauto@#1\\#2#3\jlreq@endmark{%
  \jlreq@inlinenote@noauto@@#1&\jlreq@endmark\jlreq@endmark
  \ifx#2\jlreq@endmark\def\jlreq@next{}\else\linebreak\def\jlreq@next{\jlreq@inlinenote@noauto@#2#3\jlreq@endmark}\fi
  \jlreq@next
}

\def\jlreq@inlinenote@noauto@@#1&#2#3\jlreq@endmark{%
  \ifx#2\jlreq@endmark
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
  \else
    \def\jlreq@next{\jlreq@inlinenote@noauto@@@{#1}#2#3}%
  \fi
  \jlreq@next
}

\def\jlreq@inlinenote@noauto@@@#1#2&\jlreq@endmark{%
  {%
    \setbox\@tempboxa=\hbox{\jlreq@inlinenote@fontsize\vbox{\hbox{#1}\hbox{#2}}}%
    \jlreq@box@putcenter\@tempboxa
  }%
}

\newcommand{\jlreq@inlinenote@endnote}{%
  \jlreq@in@inlinenotefalse
  {%
%    \jlreq@inlinenote@kakkofontsize
%    \hbox{）}\inhibitglue
    \setbox\jlreq@tempboxa=\hbox{\jlreq@inlinenote@kakkofontsize）}%
    \jlreq@box@putcenter\jlreq@tempboxa
    \inhibitglue
  }%
}

% \jlreq@inlinenote@determinelength{テキスト(1)}{書式指定(2)}{\parshape指定(3)}{調整に使う行数(4)}{成功行数(5)}{最小長さ(6)}{最大長さ(7)}
% \jlreq@resultboxに整形結果を返す．見つからなかったらvoid
\newcommand{\jlreq@inlinenote@determinelength}[7]{%
%  \message{#1 の試行開始，行数 = #5, \the#6 から \the#7まで}%
  \@tempcnta=1\relax
  \def\@tempa{}%
  \@whilenum\@tempcnta<#4\do{%
    \expandafter\def\expandafter\@tempa\expandafter{\@tempa 0pt \the\jlreq@tempdima}%
    \advance\@tempcnta by 1\relax
  }%
  \@tempcnta=0\relax
  \jlreq@tempdima=#6\relax
  % 最後の行を少しずつ伸ばしていく
  \@whilenum\@tempcnta<1000\do{%
    \ifnum\@tempcnta>999\relax% ループが長すぎる
      \global\setbox\jlreq@resultbox=\voidb@x%
      \@tempcnta=1001\relax
    \else
      \setbox\@tempboxa=\vbox{#2%
        \vbadness=10000\hbadness=10000\vfuzz=\maxdimen\hfuzz=\maxdimen
        \parindent=0pt\leftskip=0pt\rightskip=0pt\relax
        \parshape #5 #3 \@tempa 0pt \the\maxdimen
        #1\par\global\@tempcntb=\prevgraf}%
%      \message{\string\jlreq@tempdima = \the\jlreq@tempdima で試行，行数は\the\@tempcntb , 書式 #5 #3 \@tempa 0pt \the\maxdimen}%
    \fi
    \jlreq@getlastbox{\@tempboxa}%
    \setbox\jlreq@tempboxa=\box\jlreq@resultbox
    \ifnum\@tempcntb<#5\relax% 行数が達していないならOK
%      \message{行数 = \the\@tempcntb により確定}
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
        \advance\jlreq@tempdima by 0.3pt\relax
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
}


%. ページスタイル．
% とりあえず脇に縦書きで配置するのは無視する．
% メモ：
% 2.6.1.cの後半が前半と整合的でないように見える……
% 柱：両柱と片柱（2.6.3）
\@tempdima=\jlreq@speciallength{\jlreq@headfoot@sidemargin}
\ifthenelse{\lengthtest{\@tempdima=0pt} \OR \(\lengthtest{0.99\zw < \@tempdima} \AND \lengthtest{\@tempdima < 1.01\zw}\)}{}{
  \jlreq@warning{ノンブルまたは柱は，基本版面の左右にそろえるか，全角アキだけ寄せた位置に配置する (2.6.1.b)}
}

% bottom-leftみたいなのを解釈する．入力の順番はどっちでも良いが，出力は<top/bottom><left/right>の順番
% #1にセットする．
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
  \ifthenelse{\equal{#1}{top} \OR \equal{#1}{bottom}}{\def\jlreq@tempc{#1}}{
    \ifthenelse{\equal{#1}{left} \OR \equal{#1}{right} \OR \equal{#1}{center}}{\def\jlreq@tempd{#1}}{
      \ClassError{jlreq}{Invalid position: #1}{\@ehc}
    }
  }
}
\newcommand*{\jlreq@pagestyle@parse@position}[2]{
  \begingroup
    \jlreq@pagestyle@parse@position@#2-\jlreq@endmark
    % \jlreq@tempcに縦方向を，\jlreq@tempdに横方向を入れる
    \def\jlreq@tempc{}\def\jlreq@tempd{}
    \expandafter\jlreq@pagestyle@parse@position@@\expandafter{\jlreq@tempa}
    \expandafter\jlreq@pagestyle@parse@position@@\expandafter{\jlreq@tempb}
    \ifx\jlreq@tempc\@empty\edef\jlreq@tempc{\expandafter\@firstoftwo#1}\fi
    \ifx\jlreq@tempd\@empty\edef\jlreq@tempd{\expandafter\@secondoftwo#1}\fi
    \edef\jlreq@do{\unexpanded{\def#1}{{\jlreq@tempc}{\jlreq@tempd}}}
  \expandafter\endgroup
  \jlreq@do
}

% odd_running_head=_sectionのように下線から始まる場合，その値の見出し命令を柱に出すようにする．
% 要するに\ps@***に\sectionmarkを定義するように仕込む．
% 場所指定は奇数ページの方．偶数ページは反対になる．
\newcommand*{\DeclarePageStyle}[2]{
  \expandafter\def\csname jlreq@pagestyle@setting@#1\endcsname{#2}
  \begingroup
    \def\jlreq@nombre@position{{bottom}{left}}
    \def\jlreq@running@head@position{{top}{left}}
    \def\jlreq@nombre{\thepage}
    \def\jlreq@odd@running@head{}
    \def\jlreq@even@running@head{}
    \def\jlreq@command{}
    % 柱とノンブルの間
    \def\jlreq@gap{1.5\zw}
    \newif\ifjlreq@clearmark\jlreq@clearmarktrue
    \jlreq@parsekeyval[PageStyle]{
      {nombre_position}{\jlreq@pagestyle@parse@position{\jlreq@nombre@position}{##1}}
      {running_head_position}{\jlreq@pagestyle@parse@position{\jlreq@running@head@position}{##1}}
      {nombre}{\def\jlreq@nombre{##1}}
      {odd_running_head}{\def\jlreq@odd@running@head{##1}}
      {even_running_head}{\def\jlreq@even@running@head{##1}}
      {command}{\def\jlreq@command{##1}}
      {gap}{\def\jlreq@gap{##1}}
      {no_clear_mark}{\jlreq@clearmarkfalse}
    }{#2}
    \ifthenelse{\lengthtest{\jlreq@gap < 1.49\zw} \OR \( \lengthtest{\jlreq@gap > 1.51\zw} \AND \lengthtest{\jlreq@gap < 1.99\zw} \) \OR \lengthtest{\jlreq@gap > 2.01\zw}}{\jlreq@warning{ノンブルと柱との空き量は文字サイズの2倍又は1.5倍とする（ページスタイル #1 内，2.6.1.c）}}{}
    
    % 見出しを出す場合：evenに章などの高いレベルの見出しを出す（2.6.3.a）
    \def\@tempa##1##2\jlreq@endmark{%
      \ifx_##1%
        \def\jlreq@even@running@head{\leftmark}%
        \edef\jlreq@command{\expandonce{\jlreq@command}%
          % これで\commandの中身は\def\**mark##1{...}みたいになるはず
          \noexpand\def\expandonce{\csname ##2mark\endcsname}\unexpanded{########1}{%
            \noexpand\markboth{\expandonce{\csname the##2\endcsname}\quad\unexpanded{########1}}{}%
          }}%
      \fi
      \ifx\jlreq@endmark##1\else\expandafter\@gobble\fi
    }
    \expandafter\@tempa\jlreq@even@running@head\jlreq@endmark\jlreq@endmark
    \def\@tempa##1##2\jlreq@endmark{%
      \ifx_##1%
        \def\jlreq@odd@running@head{\rightmark}%
        \edef\jlreq@command{\expandonce{\jlreq@command}%
          \noexpand\def\expandonce{\csname ##2mark\endcsname}\unexpanded{########1}{
            \noexpand\markright{\expandonce{\csname the##2\endcsname}\quad\unexpanded{########1}}%
          }}
      \fi
      \ifx\jlreq@endmark##1\else\expandafter\@gobble\fi
    }
    \expandafter\@tempa\jlreq@odd@running@head\jlreq@endmark\jlreq@endmark
    
    % ##1 ##2 ##3と並んだヘッダを作る，戻り値は\jlreq@result
    \def\jlreq@setheadfoot@##1##2##3{%
      \jlreq@ifempty{##1}{\def\jlreq@left{}}{\edef\jlreq@left{\noexpand\hspace*{\jlreq@expand@speciallength{\jlreq@headfoot@sidemargin}}\unexpanded{##1}}}
      % +\topskip - .5\zwは\jlreq@headfoot@sidemargin = 0ptの時に本文の右に一致させるための補正．
      \jlreq@ifempty{##3}{\def\jlreq@right{}}{\edef\jlreq@right{\unexpanded{##3}\noexpand\hspace*{\dimexpr\jlreq@expand@speciallength{\jlreq@headfoot@sidemargin} + \topskip - .5\zw\relax}}}
      \jlreq@ifempty{##2}{
        \edef\jlreq@result{\expandonce{\jlreq@left}\hfil\expandonce{\jlreq@right}}
        \jlreq@ifempty{##1}{\jlreq@ifempty{##3}{\def\jlreq@result{}}{}}{}
      }{
        \ifx\jlreq@left\@empty\else\edef\jlreq@left{\noexpand\hbox to 0pt{\expandonce{\jlreq@left}\hss}}\fi
        \ifx\jlreq@right\@empty\else\edef\jlreq@right{\noexpand\hbox to 0pt{\hss\expandonce{\jlreq@right}}}\fi
        \edef\jlreq@result{\expandonce{\jlreq@left}\hfil\unexpanded{##2}\hfil\expandonce{\jlreq@right}}
      }
    }
    % ##2を##1 = left/center/rightの場所，##4を##3の場所に置く．被った場合は##2を外側にする．
    % 戻り値は\jlreq@result
    \def\jlreq@setheadfoot##1##2##3##4{%
      \def\jlreq@left{}\def\jlreq@center{}\def\jlreq@right{}
      % \ifjlreq@tempa = if(##1 == ##3 && ##2 != "" && ##4 != "")
      \jlreq@tempatrue
      \jlreq@ifempty{##2}{\jlreq@tempafalse}{}
      \jlreq@ifempty{##4}{\jlreq@tempafalse}{}
      \ifthenelse{\equal{##1}{##3}}{}{\jlreq@tempafalse}
      \ifjlreq@tempa
        \ifthenelse{\equal{##1}{right}}{
          \edef\jlreq@right{\unexpanded{##4}\noexpand\hspace{\gap}\unexpanded{##2}}
        }{
          \expandafter\edef\csname jlreq@##1\endcsname{\unexpanded{##2}\noexpand\hspace{\gap}\unexpanded{##4}}
        }
      \else
        \jlreq@ifempty{##2}{}{\expandafter\def\csname jlreq@##1\endcsname{##2}}
        \jlreq@ifempty{##4}{}{\expandafter\def\csname jlreq@##3\endcsname{##4}}
      \fi
      \edef\jlreq@do{\noexpand\jlreq@setheadfoot@{\expandonce{\jlreq@left}}{\expandonce{\jlreq@center}}{\expandonce{\jlreq@right}}}
      \jlreq@do
    }
    % \nombre@<top/bottom>を定義
    \def\jlreq@nombre@top{}\def\jlreq@nombre@bottom{}
    \expandafter\edef\csname jlreq@nombre@\expandafter\@firstoftwo\jlreq@nombre@position\endcsname{\expandonce{\jlreq@nombre}}
    % \odd@running@head@<top/bottom>を定義
    \def\jlreq@odd@running@head@top{}\def\jlreq@odd@running@head@bottom{}
    \expandafter\edef\csname jlreq@odd@running@head@\expandafter\@firstoftwo\jlreq@running@head@position\endcsname{\expandonce{\jlreq@odd@running@head}}
    % \@oddheadを定義
    \edef\jlreq@do{\unexpanded{\jlreq@setheadfoot{\expandafter\@secondoftwo\jlreq@nombre@position}}{\expandonce{\jlreq@nombre@top}}\unexpanded{{\expandafter\@secondoftwo\jlreq@running@head@position}}{\expandonce{\jlreq@odd@running@head@top}}}
    \jlreq@do\let\jlreq@oddhead=\jlreq@result
    % \@oddfootを定義
    \edef\jlreq@do{\unexpanded{\jlreq@setheadfoot{\expandafter\@secondoftwo\jlreq@nombre@position}}{\expandonce{\jlreq@nombre@bottom}}\unexpanded{{\expandafter\@secondoftwo\jlreq@running@head@position}}{\expandonce{\jlreq@odd@running@head@bottom}}}
    \jlreq@do\let\jlreq@oddfoot=\jlreq@result
    % ##1 = {}{}の後ろを逆にする
    \def\getoppositeposition##1{
      \ifthenelse{\equal{\expandafter\@secondoftwo##1}{center}}{\def\jlreq@tempe{center}}{
        \ifthenelse{\equal{\expandafter\@secondoftwo##1}{right}}{\def\jlreq@tempe{left}}{
          \ifthenelse{\equal{\expandafter\@secondoftwo##1}{left}}{\def\jlreq@tempe{right}}{}}}
      \edef##1{{\expandafter\@firstoftwo##1}{\jlreq@tempe}}
    }
    \getoppositeposition\jlreq@nombre@position
    \getoppositeposition\jlreq@running@head@position
    % 上と同じことをする
    % \nombre@<top/bottom>を定義
    \def\jlreq@nombre@top{}\def\jlreq@nombre@bottom{}
    \expandafter\edef\csname jlreq@nombre@\expandafter\@firstoftwo\jlreq@nombre@position\endcsname{\expandonce{\jlreq@nombre}}
    % \even@running@head@<top/bottom>を定義
    \def\jlreq@even@running@head@top{}\def\jlreq@even@running@head@bottom{}
    \expandafter\edef\csname jlreq@even@running@head@\expandafter\@firstoftwo\jlreq@running@head@position\endcsname{\expandonce{\jlreq@even@running@head}}
    % \@evenheadを定義
    \edef\jlreq@do{\unexpanded{\jlreq@setheadfoot{\expandafter\@secondoftwo\jlreq@nombre@position}}{\expandonce{\jlreq@nombre@top}}\unexpanded{{\expandafter\@secondoftwo\jlreq@running@head@position}}{\expandonce{\jlreq@even@running@head@top}}}
    \jlreq@do\let\jlreq@evenhead=\jlreq@result
    % \@evenfootを定義
    \edef\jlreq@do{\unexpanded{\jlreq@setheadfoot{\expandafter\@secondoftwo\jlreq@nombre@position}}{\expandonce{\jlreq@nombre@bottom}}\unexpanded{{\expandafter\@secondoftwo\jlreq@running@head@position}}{\expandonce{\jlreq@even@running@head@bottom}}}
    \jlreq@do\let\jlreq@evenfoot=\jlreq@result
    \edef\jlreq@do{%
      \noexpand\def\expandonce{\csname ps@#1\endcsname}{%
        \ifjlreq@clearmark\noexpand\jlreq@clearallheadingmarks\fi
        \unexpanded{\let\@mkboth=\markboth}%
        \unexpanded{\def\@oddhead}{\expandonce{\jlreq@oddhead}}%
        \unexpanded{\def\@oddfoot}{\expandonce{\jlreq@oddfoot}}%
        \unexpanded{\def\@evenhead}{\expandonce{\jlreq@evenhead}}%
        \unexpanded{\def\@evenfoot}{\expandonce{\jlreq@evenfoot}}%
        \expandonce{\jlreq@command}%
      }%
    }
  \expandafter\endgroup
  \jlreq@do
}
\def\jlreq@clearallheadingmarks{%
  \ifx\jlreq@heading@allheadings\@undefined
    \jlreq@clearmarks{chapter,part,section,subsection,subsubsection,paragraph,subparagraph,subsubparagraph}%
  \else
    \expandafter\jlreq@clearheadingmarks\expandafter{\jlreq@heading@allheadings}%
  \fi
}
\def\jlreq@clearheadingmarks#1{%
  \@for\jlreq@tempa:=#1\do{%
    \expandafter\let\csname\jlreq@tempa mark\endcsname=\@gobble
  }%
}
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
    \expandafter\let\expandafter\setting\expandafter=\csname jlreq@pagestyle@setting@#1\endcsname
    \edef\jlreq@do{\noexpand\RenewPageStyle{#1}{\expandonce{\setting},\unexpanded{#2}}}
  \expandafter\endgroup
  \jlreq@do
}
\@onlypreamble\DeclarePageStyle
\@onlypreamble\NewPageStyle
\@onlypreamble\RenewPageStyle
\@onlypreamble\ProvidePageStyle
\@onlypreamble\ModifyPageStyle

\RenewPageStyle{empty}{nombre={},odd_running_head={},even_running_head={}}
\if@tate
  \RenewPageStyle{plain}{nombre=\thepage,odd_running_head={},even_running_head={},nombre_position={top-left}}
  \if@twoside
    \NewPageStyle{headings}{nombre=\thepage,nombre_position=top-left,running_head_position=top-right,odd_running_head={_subsection},even_running_head={_section}}
  \else
    \NewPageStyle{headings}{nombre=\thepage,nombre_position=top-left,running_head_position=top-right,odd_running_head={_section},even_running_head={}}
  \fi
  \NewPageStyle{myheadings}{nombre=\thepage,nombre_position=top-left,running_head_position=top-right,odd_running_head=\rightmark,even_running_head=\leftmark,no_clear_mark}
\else
  \RenewPageStyle{plain}{nombre=\thepage,odd_running_head={},even_running_head={},nombre_position={bottom-center}}
  \if@twoside
    \NewPageStyle{headings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center,odd_running_head={_subsection},even_running_head={_section}}
  \else
    \NewPageStyle{headings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center,odd_running_head={_section},even_running_head={}}
  \fi
  \NewPageStyle{myheadings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center,odd_running_head=\rightmark,even_running_head=\leftmark,no_clear_mark}
\fi

%. フロート関連
% 4.3.3.dの例，縦組みの時だけど横にも適用……
\setlength{\floatsep}{1\jlreq@gol plus 1\jlreq@gol}
\setlength{\textfloatsep}{1\jlreq@gol plus \baselineskip}
\intextsep=\textfloatsep
\dblfloatsep=\floatsep
\dbltextfloatsep=\textfloatsep
% 残りはデフォルトにしておく．

% 4.3.1 注4
\newlength\abovecaptionskip
\newlength\belowcaptionskip
\newcommand{\@makecaption}[2]{{%
  \reset@font\small\headfont
  \vskip\abovecaptionskip
  \sbox\@tempboxa{#1\hskip 1\jlreq@mol#2}%
  \ifdim \wd\@tempboxa >\hsize
    #1\hskip1\jlreq@mol#2\relax\par
  \else
    \global\@minipagefalse
    \hbox to\hsize{\hfil\box\@tempboxa\hfil}%
  \fi
  \vskip\belowcaptionskip}}
% 特に根拠のない値
\setlength\abovecaptionskip{.5\jlreq@gol}
\setlength\belowcaptionskip{0pt}


% \begin{figure}***\caption{???}\end{figure}を
% \begin{figure}\layoutfloat{***}\pcaption{???}\end{figure}にする．
% 
%\def\jlreq@saveoriginalcs#1{
%  \expandafter\expandafter\expandafter\let\expandafter\expandafter\csname jlreq@original@#1\endcsname\csname #1\endcsname
%}
%\long\def\jlreq@replace@layoutfloat#1\caption{\layoutfloat{#1}\jlreq@caption}
%\long\def\jlreq@caption#1{\ifx#1\jlreq@endmark\else\pcaption{#1}\expandafter\jlreq@replace@layoutfloat\fi}
%\def\jlreq@modify@float#1{%
%  \def\lgdef{\long\gdef}
%  \jlreq@saveoriginalcs{#1}
%  \@namedef{#1}{\@ifnextchar[{\@nameuse{jlreq@float@#1}}{\@nameuse{jlreq@float@@#1}}}
%  \expandafter\lgdef\csname jlreq@float@#1\endcsname[##1]{%
%    \expandafter\csname jlreq@original@#1\endcsname[##1]
%    \csname jlreq@process@insertlayoutfloat@#1\endcsname{}
%  }
%  \expandafter\lgdef\csname jlreq@float@@#1\endcsname{%
%    \expandafter\csname jlreq@original@#1\endcsname
%    \csname \jlreq@process@insertlayoutfloat@#1\endcsname{}
%  }
%  \expandafter\lgdef\csname jlreq@process@insertlayoutfloat@#1\endcsname ##1##2\end{%
%    \csname jlreq@checkenvname@#1\endcsname{##1##2}\end
%  }
%  \expandafter\lgdef\csname jlreq@checkenvname@#1\endcsname ##1\end##2{%
%    \def\@tempa{##2}%
%    \def\@tempb{#1}%
%    \ifx\@tempa\@tempb
%      \def\jlreq@next{\jlreq@replace@layoutfloat##1\caption{\jlreq@endmark}\end{##2}}%
%    \else
%      \def\jlreq@next{\csname jlreq@process@insertlayoutfloat@#1\endcsname{##1\end{##2}}}%
%    \fi
%    \jlreq@next
%  }
%}

%.. figure環境
\newcounter{figure}
\renewcommand*{\thefigure}{\arabic{figure}}
\newcommand*{\fps@figure}{h}
\newcommand*{\ftype@figure}{1}
\newcommand*{\ext@figure}{lof}
\newcommand*{\fnum@figure}{\figurename\thefigure}
\newenvironment{figure}{\@float{figure}}{\end@float}
\newenvironment{figure*}{\@dblfloat{figure}}{\end@dblfloat}
\newcommand*{\listfigurename}{図目次}
\newcommand{\figurename}{図}
\if@tate
  \DeclareLayoutCaption{figure}<y>(\floatwidth)[cr]
\fi
%\jlreq@modify@float{figure}
%\jlreq@modify@float{figure*}

%.. table環境
\newcounter{table}
\renewcommand*{\thetable}{\arabic{table}}
\newcommand*{\fps@table}{h}
\newcommand*{\ftype@table}{2}
\newcommand*{\ext@table}{lot}
\newcommand*{\fnum@table}{\tablename\thetable}
\newenvironment{table}{\@float{table}}{\end@float}
\newenvironment{table*}{\@dblfloat{table}}{\end@dblfloat}
\newcommand{\listtablename}{表目次}
\newcommand{\tablename}{表}
\if@tate
  \DeclareLayoutCaption{table}<y>(\floatwidth)[cr]
\fi
%\jlreq@modify@float{table}
%\jlreq@modify@float{table*}

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
    \ifvoid\jlreq@abstractbox\else
      \centerline{\box\jlreq@abstractbox}
    \fi
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
    \lineskip .5\jlreq@gol
    \begin{tabular}[t]{c}%
      \@author
    \end{tabular}%
    \par
  }%
  \vskip\baselineskip
  {\jlreq@keepbaselineskip{\large}\@date}%
  \end{center}%
  \par\vskip\baselineskip}

%.. abstract
\newbox\jlreq@abstractbox
\newcommand*{\abstractname}{概要}
\if@titlepage
  % articleとかjarticleとかと同じ
  \newenvironment{abstract}{%
    \titlepage
    \null\vfil
    \@beginparpenalty\@lowpenalty
    \begin{center}%
      {\bfseries\gtfamily\abstractname}%
      \@endparpenalty\@M
    \end{center}%
  }{%
    \par\vfil\null\endtitlepage
  }
\else
  \newenvironment{abstract}{%
    \if@twocolumn
      \ifx\maketitle\relax
        \section*{\abstractname}%
      \else
      \fi
    \else
      \global\setbox\jlreq@abstractbox=\vtop\bgroup\bgroup
        \small
        \begin{center}%
          {\bfseries\abstractname}%
        \end{center}%
        \quotation
    \fi
    }{\if@twocolumn\else\endquotation\egroup\vspace{2\baselineskip}\egroup\fi}
\fi

%. 箇条書き．cf. JISX4051 8.4
% 用語定義型
\newenvironment{description}{\list{}{%
  \setlength{\leftmargin}{0\jlreq@mol}% 下げない
  \setlength{\labelwidth}{0\jlreq@mol}%
  \addtolength{\leftmargin}{\leftskip}%
  \addtolength{\leftmargin}{\labelsep}%
  \let\makelabel=\descriptionlabel
% 同行じゃない場合はこんな感じ？
%  \let\jlreq@original@@item=\@item
%  \def\@item[##1]{\jlreq@original@@item[##1]\mbox{}\par
  }}{\endlist}
\newcommand{\descriptionlabel}[1]{\normalfont\headfont #1}

% enumerateとitemize
% 見出しが一つ上のレベルからどのくらいずれているかを入れる．
% （見出しは2\zhの箱に右/下詰めで入る．）
\setlength\leftmargini{2\jlreq@mol}
\setlength\leftmarginii{1\jlreq@mol}
\setlength\leftmarginiii{1\jlreq@mol}
\setlength\leftmarginiv{1\jlreq@mol}
\setlength\leftmarginv{1\jlreq@mol}
\setlength\leftmarginvi{1\jlreq@mol}

% enumerate, itemize用初期化
\def\jlreq@init@list{%
  \setlength{\labelwidth}{2\jlreq@mol}%
  \setlength{\topsep}{0pt}%
  \setlength{\partopsep}{0pt}%
  \setlength{\itemsep}{0pt}%
  \setlength{\parsep}{0pt}%
  \setlength{\listparindent}{\parindent}%
% itemizeは直後ベタ，enumerateは直後全角空き．
  \ifthenelse{\equal{\@currenvir}{itemize}}{
    \setlength{\labelsep}{0\jlreq@mol}%
  }{%
    \setlength{\labelsep}{1\jlreq@mol}%
  }%
  % \labelsepだけあけるのは一つ目（ラベルの直後）のみ
  \setlength{\itemindent}{\labelsep}%
}

\def\@listi{%
  \jlreq@init@list
  \setlength{\leftmargin}{\leftmargini}%
}
\let\@listI\@listi
\def\@listii{%
  \jlreq@init@list
  \setlength{\leftmargin}{\leftmarginii}%
}
\def\@listiii{%
  \jlreq@init@list
  \setlength{\leftmargin}{\leftmarginiii}%
}
\def\@listiv{%
  \jlreq@init@list
  \setlength{\leftmargin}{\leftmarginiv}%
}
\def\@listv{%
  \jlreq@init@list
  \setlength{\leftmargin}{\leftmarginv}%
}

\if@tate
  \renewcommand{\theenumi}{\Kanji{enumi}}
  \renewcommand{\theenumii}{\rensuji{\@arabic\c@enumii}}
  \renewcommand{\theenumiii}{\rensuji{\@arabic\c@enumiii}}
  \renewcommand{\theenumiv}{\rensuji{\@arabc\c@enumiv}}
\fi
\newcommand{\labelenumi}{\theenumi}
\newcommand{\labelenumii}{\theenumii}
\newcommand{\labelenumiii}{\theenumiii}
\newcommand{\labelenumiv}{\theenumiv}
\renewcommand{\p@enumii}{\theenumi}
\renewcommand{\p@enumiii}{\theenumi(\theenumii)}
\renewcommand{\p@enumiv}{\p@enumiii\theenumiii}

\newcommand{\labelitemi}{\hbox to 1\jlreq@mol{\hss\textbullet\hss}}
%\newcommand{\labelitemi}{•}
\newcommand{\labelitemii}{○}
\newcommand{\labelitemiii}{＊}
\newcommand{\labelitemiv}{\hbox to 1\jlreq@mol{\hss ・\hss}}

% 引用系．1.5em→1\zh，字下げを二文字にした．3.5.2の例．
\newenvironment{verse}
  {\let\\\@centercr
  \list{}{\itemsep\z@ \itemindent -2\jlreq@mol%
    \listparindent\itemindent
    \labelwidth\z@
    \labelsep\z@
    \leftmargin=2\jlreq@mol
    \rightmargin\leftmargin \advance\leftmargin 2\jlreq@mol}%
    \item\relax}{\endlist}
\newenvironment{quotation}
  {\list{}{\listparindent\parindent
    \itemindent\listparindent
    \labelwidth\z@
    \labelsep\z@
    \leftmargin=2\jlreq@mol
    \rightmargin\leftmargin
    \parsep\z@ \@plus.1\jlreq@gol}%
    \item\relax}{\endlist}
\newenvironment{quote}
  {\list{}{%
    \rightmargin\leftmargin
    \labelwidth\z@
    \leftmargin=2\jlreq@mol
    \listparindent\z@}%
    \item\relax}{\endlist}

%. 表関係 4.4
% 表内の行間を0にする（4.4.3.f）
\let\jlreq@original@tabular=\tabular
\let\jlreq@original@endtabular=\endtabular
\preto\tabular{\begingroup\appto\@arrayparboxrestore{\baselineskip=0pt\lineskip=0pt}}
\appto\endtabular{\endgroup}
% 4.4.3.e
\setlength\tabcolsep{.5\jlreq@gol}
\setlength\arraycolsep{.5\jlreq@mol}
% 4.4.3.j
%\RequirePackage{tabls} % plextと整合的でない
%\setlength\extrarulesep{.25\jlreq@gol}
%\setlength\tablinesep{.25\jlreq@gol}
%\renewcommand{\arraystretch}{0}
\setlength\arrayrulewidth{\jlreq@omotekeiwidth} % 4.4.3.c
\setlength\doublerulesep{2pt}
\setlength\tabbingsep{\labelsep}
\skip\@mpfootins=\skip\footins
\setlength\fboxsep{.3\jlreq@mol}
\setlength\fboxrule{\jlreq@omotekeiwidth} % 根拠はない
\renewcommand{\theequation}{\@arabic\c@equation}

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
  \protected@write\@auxout
    {\let\label\@gobble \let\index\@gobble \let\glossary\@gobble
      \if@tate
        \@temptokena{\rensuji{\thepage}}%
      \else
        \@temptokena{\thepage}%
      \fi
    }%
    {\string\@writefile{#1}%
      {\protect\contentsline{#2}{#3}{\the\@temptokena}}}%
}

\newcount\jlreq@top@contents % トップ見出しを入れる．レベルと同じ値．
\jlreq@top@contents=-1
\newcommand*{\jlreq@set@top@contents}[1]{%
  \ifnum\jlreq@top@contents=-1
    \jlreq@top@contents=#1\relax
  \fi
}
\newcommand{\tableofcontents}{%
  \jlreq@top@contents=-1\relax
  \section*{\contentsname
    \@mkboth{\contentsname}{\contentsname}%
  }\@starttoc{toc}%
}

% JIS X 4051自身の目次に近づけようかと……なりきれてないけど．
% 文字の大きさは全て同じ（\normalsize）にする．
% 見出しのレベルがあがると1文字分ずつ字下げしていく．
% 第三引数は，上からの幅に加え更にトップの見出しからの差による補正（プラス）が入る．
% 補正には\jlreq@top@contentsを使う．
% 「トップ」というか，一番最初に現れた見出しを入れる．
% リーダーは.から・に変更しました．更に直後から出るように．
\def\@dottedtocline#1#2#3#4#5{%
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
    \leaders\hbox{$\hbox{・}\mkern \@dotsep mu \m@th \mkern \@dotsep mu$}%
    \hfill\nobreak
    \hb@xt@\@pnumwidth{\hss\normalfont\normalcolor #5}%
    \par}%
  \fi}
\renewcommand*{\l@part}[2]{%
  \jlreq@set@top@contents{0}%
  \ifnum \c@tocdepth >-2\relax
    \addpenalty{\@secpenalty}%
    \begingroup
    \parindent\z@\rightskip\@pnumwidth
    \parfillskip-\@pnumwidth
    {\leavevmode\bfseries\gtfamily
    \setlength\@lnumwidth{2\jlreq@gol}%
    #1\hfil\nobreak
    \hbox to\@pnumwidth{\hss#2}}\par
    \nobreak
    \endgroup
  \fi}

% listoffigures
\newcommand{\listoffigures}{%
  \jlreq@top@contents=0\relax
  \section*{\listfigurename
  \@mkboth{\listfigurename}{\listfigurename}}%
  \@starttoc{lof}%
}
\newcommand*{\l@figure}{\@dottedtocline{1}{0\jlreq@gol}{2\jlreq@gol}}
\newcommand{\listoftables}{%
  \jlreq@top@contents=0\relax
  \section*{\listtablename
  \@mkboth{\listtablename}{\listtablename}}%
  \@starttoc{lot}%
}
\let\l@table\l@figure

%. 文献，そのまま
\newdimen\bibindent
\setlength\bibindent{2\jlreq@mol}
\newcommand{\newblock}{\hskip .11em\@plus.33em\@minus.07em}
\newenvironment{thebibliography}[1]{%
  \jlreq@oldfontcommand@enable
  \section*{\refname\@mkboth{\refname}{\refname}}%
  \list{\@biblabel{\@arabic\c@enumiv}}%
      {\settowidth\labelwidth{\@biblabel{#1}}%
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
  \def\@noitemerr
    {\@latex@warning{Empty `thebibliography' environment}}%
  \endlist
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
  \thispagestyle{plain}%
  \parindent\z@
  \parskip\z@ \@plus .03\jlreq@gol\relax
  \let\item\@idxitem
}{%
  \if@restonecol\onecolumn\else\clearpage\fi
  \ifjlreq@resttate\tate\fi
}
\newcommand{\@idxitem}{\par\hangindent 4\jlreq@mol}
\newcommand{\subitem}{\@idxitem \hspace*{2\jlreq@mol}}
\newcommand{\subsubitem}{\@idxitem \hspace*{3\jlreq@mol}}
\newcommand{\indexspace}{\par \vskip 1\jlreq@gol \@plus .5\jlreq@gol \@minus .3\jlreq@gol\relax}

% 日にち
\newif\if西暦 \西暦true
\def\西暦{\西暦true}
\def\和暦{\西暦false}
\newcount\heisei \heisei\year \advance\heisei-1988\relax

\def\today{{%
  \jlreq@iftdir{%
    \if西暦
      \kansuji\year 年
      \kansuji\month 月
      \kansuji\day 日
    \else
      平成\ifnum\heisei=1 元年\else\kansuji\heisei 年\fi
      \kansuji\month 月
      \kansuji\day 日
    \fi
  }{%
    \if西暦
      \number\year~年
      \number\month~月
      \number\day~日
    \else
      平成\ifnum\heisei=1 元年\else\number\heisei~年\fi
      \number\month~月
      \number\day~日
    \fi
  }}}

%. ルビ
\ifx l\jlreq@engine
  \RequirePackage{luatexja-ruby}
\else
  \RequirePackage{pxrubrica}
\fi

%. 定理環境
\def\jlreq@theorem@abovebelowspace{1\baselineskip}%とりあえず前後に一行分のアキ
\def\@begintheorem#1#2{\topsep=\jlreq@theorem@abovebelowspace
  \trivlist\labelsep=1\jlreq@mol
   \item[\hskip \labelsep{\headfont #1\ #2}]}
\def\@opargbegintheorem#1#2#3{\topsep=\jlreq@theorem@abovebelowspace
  \trivlist\labelsep=1\jlreq@mol
  \item[\hskip \labelsep{\headfont #1\ #2（#3）}]}

\AtEndOfPackageFile*{amsthm}{
  \newtheoremstyle{jlreq}{\jlreq@theorem@abovebelowspace}{\jlreq@theorem@abovebelowspace}{\normalfont}{}{\headfont}{}{1\jlreq@mol}{\thmname{#1}\thmnumber{\ #2}\thmnote{ (#3)}}
  \theoremstyle{jlreq}
  \let\jlreq@original@proof=\proof
  \let\jlreq@original@endproof=\endproof
  \def\proof{\@ifnextchar[{\jlreq@proof}{\jlreq@proof[\proofname]}}
  \def\jlreq@proof[#1]{\labelsep=1\jlreq@mol\jlreq@original@proof[{\headfont #1\inhibitglue}\nopunct]}
  \renewcommand{\proofname}{証明}
}


% デフォルト設定
\newcommand{\prepartname}{第}
\newcommand{\postpartname}{部}
\newcommand{\contentsname}{目 次}
\newcommand{\refname}{参考文献}
\newcommand{\indexname}{索 引}
\newcommand{\appendixname}{付 録}
\pagestyle{plain}
\pagenumbering{arabic}
\if@twocolumn
  \twocolumn
  \sloppy
  \flushbottom
\else
  \onecolumn
  \raggedbottom
\fi
\normalmarginpar
\@mparswitchfalse
\endinput


