%% Japanese document class based on requirements for Japanese text layout
%% 
%% The package is distributed under the BSD 2-Clause License
%%
%%
% (based on JLReq 20120403 https://www.w3.org/TR/2012/NOTE-jlreq-20120403/ja/)
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jlreq}[2017/04/29 jlreq]
\RequirePackage{xkeyval,everyhook,filehook,etoolbox,ifthen}

%. helper1
\newcount\jlreq@tempcnta
\newcount\jlreq@tempcntb
\newcount\jlreq@tempcntc
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
\newskip\jlreq@resultskip
\newbox\jlreq@resultbox
\newif\ifjlreq@result

\newcommand*{\jlreq@undefcs}[1]{%
  \expandafter\ifx\csname\expandafter\@gobble\string #1\endcsname\relax\expandafter\@firstofone\else\expandafter\@gobble\fi
    {\ClassError{jlreq}{Trying to delete \string#1\space even though it is not defined, maybe a bug}{\@ehc}}%
  \let#1=\@undefined
}

% クラスファイル内でしか使わないマクロをクラスファイル終了時に未定義にする
\newcommand*{\jlreq@aftercls@addtodeletecs}[1]{%
  \appto\jlreq@aftercls@deletecslist{\jlreq@undefcs{#1}}%
}
\jlreq@aftercls@addtodeletecs{\jlreq@aftercls@addtodeletecs}
\newcommand*{\jlreq@aftercls@addtodeleteif}[1]{%
  \edef\@tempa{\expandafter\@gobble\string#1}%
  \edef\@tempa{\expandafter\@gobbletwo\@tempa}%
  \eappto\jlreq@aftercls@deletecslist{%
    \unexpanded{\jlreq@undefcs{#1}}%
    \noexpand\jlreq@undefcs{\expandonce{\csname\@tempa true\endcsname}}%
    \noexpand\jlreq@undefcs{\expandonce{\csname\@tempa false\endcsname}}%
  }%
}
\jlreq@aftercls@addtodeletecs{\jlreq@aftercls@addtodeleteif}
\AtEndOfClass{%
  \jlreq@aftercls@deletecslist
  \jlreq@undefcs{\jlreq@aftercls@deletecslist}%
  \let\jlreq@undefcs=\@undefined
}

\def\jlreq@uniqtoken{\jlreq@uniqtoken}
\def\jlreq@endmark{\jlreq@endmark}
\long\def\jlreq@deleteuntileendmark#1\jlreq@endmark{}

% \jlreq@getfirsttoken#1\jlreq@uniqtoken{}\jlreq@endmarkの形で使う
% 二回展開すると，#1の先頭を取り出す．ただし空の場合は\jlreq@uniqtoken，先頭が{の場合は\bgroupとなる
\long\def\jlreq@getfirsttoken#1#{\jlreq@getfirsttoken@#1\bgroup\jlreq@endmark}
\long\def\jlreq@getfirsttoken@#1#2\jlreq@endmark#3\jlreq@endmark{#1}
% 与えられたトークン列が空か（展開はしないでチェック）
\long\def\jlreq@ifempty#1{\expandafter\ifx\expandafter\relax\detokenize{#1}\relax\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi}
% #1の先頭トークンが#2か
\long\def\jlreq@iffirsttoken#1#2{%
  \expandafter\expandafter\expandafter\ifx\jlreq@getfirsttoken#1\jlreq@uniqtoken{}\jlreq@endmark #2\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi
}
% #1が\jlreq@endmarkか
\long\def\jlreq@ifendmark#1{\jlreq@iffirsttoken{#1}{\jlreq@endmark}}

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
  \jlreq@ifendmark{#2}{%
    % 全体の解釈が終わった
    \ifx\jlreq@tempa\jlreq@tempb\else
      \ifx#1\@empty\edef#1{\expandonce{\jlreq@tempb}}%
      \else\edef#1{\expandonce{#1},\expandonce{\jlreq@tempb}}\fi
    \fi
  }{%
    \edef\jlreq@tempb{\expandonce{\jlreq@tempb}{#2}}%
    \def\jlreq@next{\jlreq@helper@removeelement@{#1}}%
    \expandafter\jlreq@next
  }%
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

% 簡易なkeyvalのパース．
% \jlreq@parsekeyval*[family=jlreq@key]{ % *ありは\setkeys*を使う
%  {key}{\def\val{#1}}
%  *{key}{\def\val{#1}} % デフォルト値を空文字列にする
%  {key}[choice1,choice2]{\def\valchoice{#1}}
%}{parse対象}
\def\jlreq@parsekeyval{%
  \@ifstar{\jlreq@helper@parsekeyval@{*}}{\jlreq@helper@parsekeyval@{}}%
}
\def\jlreq@helper@parsekeyval@#1{%
  \@ifnextchar[{\jlreq@helper@parsekeyval@@{#1}}{\jlreq@helper@parsekeyval@@{#1}[jlreq@key]}%
}
\long\def\jlreq@helper@parsekeyval@@#1[#2]#3#4{%
  \begingroup
    \def\jlreq@do{}%
    \jlreq@helper@parsekeyval@@@{#2}#3{\jlreq@endmark}%
    \setkeys#1{#2}{#4}%
  \expandafter\endgroup
  \jlreq@do
}
\def\jlreq@helper@parsekeyval@@@#1#2#{\jlreq@helper@parsekeyval@@@@{#1}#2\jlreq@endmark}%
\def\jlreq@helper@parsekeyval@@@@#1#2{%
  \jlreq@ifendmark{#2}{%
    \def\@tempa{\jlreq@helper@parsekeyval@@@@@{#1}}%
  }{%
    \def\@tempa{\expandafter\@tempb\jlreq@deleteuntileendmark}%
    \ifx *#2%
      \def\@tempb{\jlreq@helper@parsekeyval@@@definekeywithdefault{#1}}%
    \else
      \def\@tempb{\jlreq@helper@parsekeyval@@@@@{#1}}%
    \fi
  }%
  \@tempa
}

\long\def\jlreq@helper@parsekeyval@@@@@#1#2{%
  \jlreq@ifendmark{#2}{%
    \def\@tempa{}%
  }{%
    \def\@tempa{%
      \@ifnextchar[{\jlreq@helper@parsekeyval@@@choicekey{#1}{#2}}{\jlreq@helper@parsekeyval@@@definekey{#1}{#2}}%
    }%
  }%
  \@tempa
}
\long\def\jlreq@helper@parsekeyval@@@choicekey#1#2[#3]#4{%
  \define@choicekey{#1}{#2}{#3}{\eappto\jlreq@do{\unexpanded{#4}}}%
  \jlreq@helper@parsekeyval@@@{#1}%
}
\long\def\jlreq@helper@parsekeyval@@@definekeywithdefault#1#2#3{%
  \define@key{#1}{#2}[]{\eappto\jlreq@do{\unexpanded{#3}}}%
  \jlreq@helper@parsekeyval@@@{#1}%
}
\long\def\jlreq@helper@parsekeyval@@@definekey#1#2#3{%
  \define@key{#1}{#2}{\eappto\jlreq@do{\unexpanded{#3}}}%
  \jlreq@helper@parsekeyval@@@{#1}%
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

% \jlreq@switch{str}{
%   {str}{abcd}
%   {str1}{xyz}
%}[default: input = #1] -> abcd
%または
%
% \jlreq@switch{str}{
%   {str}{abcd}
%   {str1}{xyz}
%   {default} % ここは#1を受け付けない（パラメータトークンを受け付けたい場合のため）．
%} -> abcd
% 文字列比較→\edefして比較する
\long\def\jlreq@helper@switch@executeoption#1[#2]{%
  \begingroup
    \def\jlreq@do##1{#2}%
  \expandafter\endgroup
  \jlreq@do{#1}%
}
\long\def\jlreq@helper@removeoption[#1]{}
\long\def\jlreq@switch#1#2{%
  \begingroup
    \let\jlreq@do\@undefined
    \edef\jlreq@tempa{#1}%
    \expandafter\jlreq@helper@switch@\expandafter{\jlreq@tempa}#2\jlreq@endmark
    \ifx\jlreq@do\@undefined
      \def\jlreq@do{\@ifnextchar[{\jlreq@helper@switch@executeoption{#1}}{}}%
    \else
      \edef\jlreq@do{\expandonce{\jlreq@do}\unexpanded{\@ifnextchar[{\jlreq@helper@removeoption}{}}}%
    \fi
  \expandafter\endgroup
  \jlreq@do
}
\long\def\jlreq@helper@switch@#1#2{%
  \jlreq@ifendmark{#2}{%
    \def\jlreq@next{}%
  }{%
    \edef\jlreq@next{\unexpanded{\jlreq@helper@switch@@{#1}{#2}}}%
  }%
  \jlreq@next
}
\long\def\jlreq@helper@switch@@#1#2#3{%
  \jlreq@ifendmark{#3}{%
    \edef\jlreq@do{\unexpanded{#2}}%
    \def\jlreq@next{}%
  }{%
    \def\jlreq@tempa{#1}% 最初に\edefで展開済み
    \edef\jlreq@tempb{#2}%
    \ifx\jlreq@tempa\jlreq@tempb\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi
    {%
      \edef\jlreq@do{\unexpanded{#3}}%
      \def\jlreq@next{\jlreq@deleteuntileendmark}%
    }{%
      \def\jlreq@next{\jlreq@helper@switch@{#1}}%
    }%
  }%
  \jlreq@next
}

% preambleにいるかのスイッチ
\newif\ifjlreq@preamble
\jlreq@preambletrue
\AtBeginDocument{\jlreq@preamblefalse}

\RequirePackage[savepos]{zref}
\zref@newprop*{jlreq@page}[0]{\number\c@page}
\zref@addprop{main}{jlreq@page}
% 現在のページを得る
\newcount\jlreq@zref@reference@count
\jlreq@zref@reference@count=0
\newcount\jlreq@currentpage
\newcommand*{\jlreq@setcurrentpage}{%
  \global\advance\jlreq@zref@reference@count by 1
  \zref@labelbyprops{jlreq@rest@width.page.\the\jlreq@zref@reference@count}{jlreq@page}%
  \global\jlreq@currentpage=\zref@extractdefault{jlreq@rest@width.page.\the\jlreq@zref@reference@count}{jlreq@page}{\c@page}%
}

\def\jlreq@saveoriginalcs#1{%
  \@ifundefined{jlreq@original@#1}{}{%
    \ClassError{jlreq}{Trying to save \expandafter\string\csname #1\endcsname\space twice, maybe a bug}{\@ehc}%
  }%
  \expandafter\expandafter\expandafter\let\expandafter\expandafter\csname jlreq@original@#1\endcsname\csname #1\endcsname
}

% #1の先頭が文字か
\def\jlreq@isletter#1{%
  \expandafter\expandafter\expandafter\jlreq@helper@isletter\jlreq@getfirsttoken#1\jlreq@uniqtoken{}\jlreq@endmark
}
\def\jlreq@helper@isletter#1{%
  \ifnum
    0\ifcat 阿\noexpand #11\fi
    \ifcat あ\noexpand #11\fi
    \ifcat （\noexpand #11\fi
    \ifcat A\noexpand #11\fi
    \ifcat 1\noexpand #11\fi
  >0
    \expandafter\@firstoftwo\else\expandafter\@secondoftwo
  \fi
}

% #1が[0-9\.]*に当てはまるか．
\def\jlreq@iffloat#1{\jlreq@helper@iffloat#1\jlreq@endmark}
\def\jlreq@helper@chknumlist#1{\ifx#101\fi\ifx#111\fi\ifx#121\fi\ifx#131\fi\ifx#141\fi\ifx#151\fi\ifx#161\fi\ifx#171\fi\ifx#181\fi\ifx#191\fi}
\def\jlreq@helper@chkfloatlist#1{\jlreq@helper@chknumlist{#1}\ifx#1.1\fi}
\def\jlreq@helper@iffloat#1{%
  \jlreq@ifendmark{#1}{\@firstoftwo}%
  {%
    \ifnum0\jlreq@helper@chkfloatlist{#1}>0 \expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi
      {\jlreq@helper@iffloat}%
      {\expandafter\@secondoftwo\jlreq@deleteuntileendmark}%
  }%
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
\newcommand*{\jlreq@addpapersize}[4]{%
  \@for\@tempa:=#1\do{%
    \eappto\jlreq@switchpapersize{{\expandonce{\@tempa}}{\unexpanded{\setlength{\paperwidth}{#3}\setlength{\paperheight}{#4}}}}%
  }%
  \@for\@tempa:=#2\do{%
    \expandafter\jlreq@DeclareOption\expandafter{\@tempa}{\setlength{\paperwidth}{#3}\setlength{\paperheight}{#4}}%
  }%
}
\jlreq@aftercls@addtodeletecs{\jlreq@addpapersize}
\DeclareOptionX{paper}{
  \edef\jlreq@do{%
    \unexpanded{\jlreq@switch{#1}}{\expandonce{\jlreq@switchpapersize}}%
    [\unexpanded{%
      \jlreq@helper@dividebycomma{#1}%
      \ifjlreq@tempa
        \setlength{\paperwidth}{\dimexpr\jlreq@tempc\relax}%
        \setlength{\paperheight}{\dimexpr\jlreq@tempd\relax}%
      \else
        \ClassError{jlreq}{The paper #1 is unknown}{\@ehc}%
      \fi
    }]%
  }%
  \jlreq@do
}
% 紙サイズ一覧．b*はJIS B．
\jlreq@addpapersize{a0,A0}{}{841mm}{1189mm}
\jlreq@addpapersize{a1,A1}{}{594mm}{841mm}
\jlreq@addpapersize{a2,A2}{}{420mm}{594mm}
\jlreq@addpapersize{a3,A3}{a3paper}{297mm}{420mm}
\jlreq@addpapersize{a4,A4}{a4paper}{210mm}{297mm}
\jlreq@addpapersize{a5,A5}{a5paper}{148mm}{210mm}
\jlreq@addpapersize{a6,A6}{a6paper}{105mm}{148mm}
\jlreq@addpapersize{a7,A7}{}{74mm}{105mm}
\jlreq@addpapersize{a8,A8}{}{52mm}{74mm}
\jlreq@addpapersize{a9,A9}{}{37mm}{52mm}
\jlreq@addpapersize{a10,A10}{}{26mm}{37mm}

\jlreq@addpapersize{b0,B0}{}{1030mm}{1456mm}
\jlreq@addpapersize{b1,B1}{}{728mm}{1030mm}
\jlreq@addpapersize{b2,B2}{}{515mm}{728mm}
\jlreq@addpapersize{b3,B3}{}{364mm}{515mm}
\jlreq@addpapersize{b4,B4}{b4paper}{257mm}{364mm}
\jlreq@addpapersize{b5,B5}{b5paper}{182mm}{257mm}
\jlreq@addpapersize{b6,B6}{b6paper}{128mm}{182mm}
\jlreq@addpapersize{b7,B7}{}{91mm}{128mm}
\jlreq@addpapersize{b8,B8}{}{64mm}{91mm}
\jlreq@addpapersize{b9,B9}{}{45mm}{64mm}
\jlreq@addpapersize{b10,B10}{}{32mm}{45mm}

\jlreq@addpapersize{c2,C2}{}{458mm}{648mm}
\jlreq@addpapersize{c3,C3}{}{324mm}{458mm}
\jlreq@addpapersize{c4C,C4}{}{229mm}{354mm}
\jlreq@addpapersize{c5,C5}{}{162mm}{229mm}
\jlreq@addpapersize{c6,C6}{}{114mm}{162mm}
\jlreq@addpapersize{c7,C7}{}{81mm}{114mm}
\jlreq@addpapersize{c8,C8}{}{57mm}{81mm}

\jlreq@addpapersize{a4var}{}{210mm}{283mm}
\jlreq@addpapersize{b5var}{}{182mm}{230mm}

\jlreq@addpapersize{letter}{letterpaper}{8.5in}{11in}
\jlreq@addpapersize{legal}{legalpaper}{8.5in}{14in}
\jlreq@addpapersize{executive}{executivepaper}{7.25in}{10.5in}


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

%.. 柱とノンブル
\newcommand*{\jlreq@option@headfoot@verticalpos}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@headfoot@verticalpos}
\DeclareOptionX{headfoot_verticalposition}{\renewcommand*{\jlreq@option@headfoot@verticalpos}{#1}}
\newcommand*{\jlreq@headfoot@sidemargin}{0pt}
\DeclareOptionX{headfoot_sidemargin}{\renewcommand*{\jlreq@headfoot@sidemargin}{#1}}

%.. 段間
\newcommand*{\jlreq@option@column@gap}{2zw}
\jlreq@aftercls@addtodeletecs{\jlreq@option@column@gap}
\DeclareOptionX{column_gap}{\renewcommand*{\jlreq@option@column@gap{#1}}}

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
\newcommand*{\jlreq@option@sidenote@width}{}
\jlreq@aftercls@addtodeletecs{\jlreq@option@sidenote@width}
\DeclareOptionX{sidenote_width}{\renewcommand*{\jlreq@option@sidenote@width}{#1}}

%.. もろもろ
\newif\if@restonecol \@restonecolfalse
\newif\if@titlepage \@titlepagefalse
\newif\ifjlreq@option@titlepage \jlreq@option@titlepagefalse % titlepageかnotitlepageかが指定された
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

\newcommand*{\jlreq@note}[1]{}
\jlreq@DeclareOption{jlreq_notes}{\renewcommand*{\jlreq@note}[1]{\message{^^JJLReq note: ##1^^J}}}

\ExecuteOptionsX{article_type=article,paper=a4,open_bracket_pos=zenkaku_tentsuki,onecolumn,final}
% \@removeelementを一旦置き換えてから\ProcessOptionsXを実行する
\let\jlreq@original@@removeelement=\@removeelement
\let\@removeelement=\jlreq@helper@removeelement
\ProcessOptionsX\relax
\let\@removeelement=\jlreq@original@@removeelement

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
  \ifx\directlua\@undefined
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
\if@tate
  \AtBeginDocument{\tate\message{《縦組モード》}\adjustbaseline}
\fi

% \jlreq@gol(Gyo Okuri Length), \jlreq@mol (Moji Okuri Length)を定義
\ifx l\jlreq@engine
  \def\jlreq@gol{\zh}\def\jlreq@mol{\zw}
\else
  \def\jlreq@gol{zh}\def\jlreq@mol{zw}
\fi

%. helper2（エンジン依存系）
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

\ifx l\jlreq@engine
  \newcommand*{\jlreq@getpostbreakpenalty}[1]{\ltjgetparameter{postbreakpenalty}{#1}}
\else
  \newcommand*{\jlreq@getpostbreakpenalty}[1]{\postbreakpenalty#1}
\fi

% 現在行の残りを得る．
\ifx l\jlreq@engine
  % 以下のコードはおかしい．
  \newcommand*{\jlreq@calc@current@linewidth@onecolumn}{%
    \dimexpr\zposx{jlreq@rest@width.pos.\the\jlreq@zref@reference@count} sp - \@totalleftmargin -
    \ifodd\jlreq@currentpage
      \oddsidemargin
    \else
      \evensidemargin
    \fi
    - 1in - \hoffset\relax
  }
\else
  \newcommand*{\jlreq@calc@current@linewidth@onecolumn}{%
    \dimexpr
      \jlreq@ifydir{%
        \zposx{jlreq@rest@width.pos.\the\jlreq@zref@reference@count} sp - \hoffset
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
        - \zposy{jlreq@rest@width.pos.\the\jlreq@zref@reference@count} sp
      }%
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
% この場所における残り長さが取得できる．
\newcommand*{\jlreq@savepos@for@rest@linewidth}{%
  \jlreq@setcurrentpage
  \global\advance\jlreq@zref@reference@count by 1\relax
  \zsavepos{jlreq@rest@width.pos.\the\jlreq@zref@reference@count}%
  \global\jlreq@current@linewidth=\jlreq@calc@current@linewidth
  \global\jlreq@rest@linewidth=\dimexpr\linewidth - \jlreq@current@linewidth\relax
  \edef\jlreq@savepos@iflabelundefined{\noexpand\zref@ifrefundefined{jlreq@rest@width.pos.\the\jlreq@zref@reference@count}}%
}

\ifx l\jlreq@engine
  \newcommand*{\lastnodechar}{\directlua{luatexja.pltx_composite_last_node_char()}}
\fi

% #1と#2の間に入るjmglue（(x)kanjiskipも）を\jlreq@resultskipに入れる
\newcommand*{\jlreq@calc@jfmglue}[2]{%
  \begingroup
    \setbox\jlreq@tempboxa=\hbox{\inhibitglue #1\inhibitglue\hbox{}\inhibitglue#2\inhibitglue}%
    \setbox\jlreq@tempboxb=\hbox{\inhibitglue #1#2\inhibitglue}%
    \edef\jlreq@do{\noexpand\jlreq@resultskip=\the\dimexpr\wd\jlreq@tempboxb - \wd\jlreq@tempboxa\relax\noexpand\relax}%
  \expandafter\endgroup
  \jlreq@do
}

\newcount\jlreq@lastnodechar
% jlreq@lastnodecharに入っている値と次のトークン（\futureletで得る）の間に入るJFMグルー等を挿入する
\newcommand*{\jlreq@fixjfm}{%
  \ifnum\jlreq@lastnodechar>-1
    \def\jlreq@do{%
      \ifnum\jlreq@getpostbreakpenalty{\jlreq@lastnodechar}=0\else\penalty\jlreq@getpostbreakpenalty{\jlreq@lastnodechar}\fi
      \jlreq@isletter{\jlreq@nextchar}{%
        \jlreq@calc@jfmglue{\char\jlreq@lastnodechar}{\jlreq@nextchar}%
%        \message{fixjfm Insert: \the\jlreq@resultskip}%
        \hskip\jlreq@resultskip
        \inhibitglue
      }{}%
    }%
    \def\@tempa{%
      \futurelet\jlreq@nextchar\jlreq@do
    }%
  \else\def\@tempa{}\fi
  \@tempa
}

% #1÷#2を\jlreq@resultdimenに入れる．（#1,#2は寸法を与える．）
\ifx l\jlreq@engine
  \newcommand*{\jlreq@divide}[2]{%
    \jlreq@resultdimen=\directlua{tex.print(tostring(\strip@pt\dimexpr #1\relax/\strip@pt\dimexpr #2\relax) .. "pt ")}%
  }
\else
  \newcommand*{\jlreq@divide}[2]{%
    \begingroup
      \@tempdima=#1\relax\@tempdimb=#2\relax
      % 分母を正にする
      \ifdim\@tempdimb<0pt \@tempdima=-\@tempdima\@tempdimb=-\@tempdimb\fi
      % \jlreq@tempdima*\@tempdimb <= \@tempdima < (\jlreq@tempdima + 1)*\@tempdimb
      % となる整数\jlreq@tempdimaを捜し，\jlreq@tempdimb=\jlreq@tempdima + 1とする
      \jlreq@tempdima=0pt
      \ifdim\@tempdima<0pt
        \loop\ifdim\strip@pt\jlreq@tempdima\@tempdimb>\@tempdima\advance\jlreq@tempdima by -1pt\repeat
      \else
        \loop\ifdim\strip@pt\jlreq@tempdima\@tempdimb<\@tempdima\advance\jlreq@tempdima by 1pt\repeat
        \ifdim\strip@pt\jlreq@tempdima\@tempdimb=\@tempdima\else\advance\jlreq@tempdima by -1pt\fi
      \fi
      \jlreq@tempdimb=\dimexpr\jlreq@tempdima + 1pt\relax
      % \jlreq@tempdimaと\jlreq@tempdimbで挟んでいく二分法
      \jlreq@tempcnta=0 % 無限ループを避けるためのカウンタ
      \loop\ifnum\numexpr\ifdim\dimexpr\jlreq@tempdimb - \jlreq@tempdima\relax>1sp 1\else0\fi*\ifnum\jlreq@tempcnta<100 1\else 0\fi\relax=1
        \jlreq@tempdimc=\dimexpr(\jlreq@tempdima+\jlreq@tempdimb)/2\relax
        \ifdim\strip@pt\jlreq@tempdimc\@tempdimb>\@tempdima\jlreq@tempdimb=\jlreq@tempdimc
        \else\jlreq@tempdima=\jlreq@tempdimc\fi
        \advance\jlreq@tempcnta by 1
      \repeat
      \edef\jlreq@do{\noexpand\jlreq@resultdimen=\the\jlreq@tempdima\noexpand\relax}%
    \expandafter\endgroup
    \jlreq@do
  }
\fi

%. 基本設定
\def\jlreq@kanjiskip{0pt plus 0.25zw minus 0pt}
\def\jlreq@xkanjiskip{0.25zw plus 0.25zw minus 0.125zw}
\ifx l\jlreq@engine
  % 和文文字，欧文文字の設定（とりあえずLuaTeX-jaのデフォルトのまま）
  \ltjsetparameter{jacharrange={-1, +2, +3, -4, -5, +6, +7, -8}}
  % kanjiskip, xkanjiskipはjfmのものを使う
  \ltjsetparameter{kanjiskip=\maxdimen}
  \ltjsetparameter{xkanjiskip=\maxdimen}
\else
  \kanjiskip=\jlreq@kanjiskip
  \xkanjiskip=\jlreq@xkanjiskip
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
\jlreq@aftercls@addtodeletecs{\jlreq@setpostbreakpenalty}
\jlreq@aftercls@addtodeletecs{\jlreq@setprebreakpenalty}
\jlreq@aftercls@addtodeletecs{\jlreq@setjaxspmode}

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

% フォントサイズを設定
\newdimen\jlreq@fontsize
\newdimen\jlreq@jafontsize
\ifx l\jlreq@engine
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
% 行頭括弧に対して\inhibitglueを入れたりする命令を作る
\def\jlreq@openbreackets@list{（〔［｛〈《「『【‘“}
\ifx p\jlreq@engine\else\edef\jlreq@openbreackets@list{\jlreq@openbreackets@list ｟〘〖«〝}\fi
\jlreq@aftercls@addtodeletecs{\jlreq@openbreackets@list}
% \jlreq@openbreackets@listの各括弧に対して，\ifx\jlreq@nextchar 「1\fiみたいなのが並んだのを作る
\def\jlreq@tempa{}
\def\jlreq@do#1{\jlreq@ifendmark{#1}{}{\appto\jlreq@tempa{\ifx\jlreq@nextchar#11\fi}\jlreq@do}}
\expandafter\jlreq@do\jlreq@openbreackets@list\jlreq@endmark
% JFM glueの伸び縮みで行頭括弧が揃わないのを防ぐために常に\inhibitglueを入れる．
\ifthenelse{\equal{\jlreq@open@bracket@pos}{nibu_tentsuki}}{
  \edef\jlreq@openbracket@hook{\noexpand\ifnum0\expandonce{\jlreq@tempa}>0 \unexpanded{\hskip -.5\jlreq@mol\inhibitglue}\noexpand\fi}
}{% zenkakunibu_nibu,zenkaku_tentsuki
  \edef\jlreq@openbracket@hook{\noexpand\ifnum0\expandonce{\jlreq@tempa}>0 \unexpanded{\inhibitglue}\noexpand\fi}
}
% JFMに関連する設定
\ifx l\jlreq@engine
  % この値は後でjfm-jlreq内で読む
  \directlua{jlreq.open_bracket_pos = [[\jlreq@open@bracket@pos]]}
  \ifjlreq@burasage\directlua{jlreq.burasage = true}\else\directlua{jlreq.burasage = false}\fi
  % 行頭括弧はJFMで対応できるが，\item後だけはどうしようもない．
  \jlreq@saveoriginalcs{list}
  \jlreq@saveoriginalcs{endlist}
  \def\list{\jlreq@pushhook@postpar{\futurelet\jlreq@nextchar\jlreq@openbracket@hook}\jlreq@original@list}
  \def\endlist{\jlreq@pophook@postpar\jlreq@original@endlist}
\else
  % 非LuaTeXの場合はJFMの入れ替えと\everyparでの処理で対処．
  % \jlreq@jfmnameにJFMの名前を入れる
  \def\jlreq@jfmname@prefix{}
  \jlreq@aftercls@addtodeletecs{\jlreq@jfmname@prefix}
  \ifjlreq@burasage\edef\jlreq@jfmname@prefix{b\jlreq@jfmname@prefix}\fi
  \ifthenelse{\equal{\jlreq@open@bracket@pos}{zenkakunibu_nibu}}{\edef\jlreq@jfmname@prefix{\jlreq@jfmname@prefix z}}{}
  \ifx u\jlreq@engine\edef\jlreq@jfmname@prefix{u\jlreq@jfmname@prefix}\fi
  \edef\jlreq@jfmname{\jlreq@jfmname@prefix jlreq}
  \edef\jlreq@jfmnameg{\jlreq@jfmname@prefix jlreqg}
  \AtBeginDocument{\PushPostHook{par}{\futurelet\jlreq@nextchar\jlreq@openbracket@hook}}
\fi
\newcount\jlreq@count@listnest
\jlreq@count@listnest=0
\def\jlreq@pushhook@postpar#1{%
  \advance\jlreq@count@listnest by 1
  \def\@tempa{\SavePostHook{par}}%
  \expandafter\@tempa\csname jlreq@save@posthook@par \the\jlreq@count@listnest\endcsname
  \PushPostHook{par}{#1}%
}
\def\jlreq@pophook@postpar{%
  \def\@tempa{\RestorePostHook{par}}%
  \expandafter\@tempa\csname jlreq@save@posthook@par \the\jlreq@count@listnest\endcsname
  \expandafter\let\csname jlreq@save@posthook@par \the\jlreq@count@listnest\endcsname=\@undefined
  \advance\jlreq@count@listnest by -1
}

% 開き括弧の幅が全角の場合は，ベタ組にするために補正が必要
\ifthenelse{\equal{\jlreq@open@bracket@pos}{zenkakunibu_nibu}}{
  \def\jlreq@open@bracket@before@space{\hskip -.5\jlreq@mol}
}{
  \def\jlreq@open@bracket@before@space{}
}

\ifx l\jlreq@engine
  \RequirePackage{luatexja-adjust}
  \ltjenableadjust[lineend=extended,priority=true]
  \ltjsetparameter{stretch_priority={kanjiskip=10,xkanjiskip=-30}}
  \ltjsetparameter{shrink_priority={kanjiskip=0,xkanjiskip=0}}
\fi

\ifx p\jlreq@engine
  \def\jlreq@yokokanjiencoding{JY1}
  \def\jlreq@tatekanjiencoding{JT1}
\fi
\ifx u\jlreq@engine
  \def\jlreq@yokokanjiencoding{JY2}
  \def\jlreq@tatekanjiencoding{JT2}
\fi
\jlreq@divide{\jlreq@jafontsize}{\jlreq@fontsize}
\edef\jlreq@jafontscale{\strip@pt\jlreq@resultdimen}
\jlreq@aftercls@addtodeletecs{\jlreq@jafontscale}
\ifx l\jlreq@engine
  \def\jlreq@yokokanjiencoding{JY3}
  \def\jlreq@tatekanjiencoding{JT3}
  \expandafter\let\csname JY3/mc/m/n/10\endcsname\relax
  \expandafter\let\csname JT3/mc/m/n/10\endcsname\relax
  \DeclareFontShape{JY3}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdmcfont:jfm=jlreq;script=latn;-kern}{}
  \DeclareFontShape{JY3}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdgtfont:jfm=jlreq;script=latn;-kern}{}
  \DeclareFontShape{JT3}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdmcfont:jfm=jlreqv;script=latn;-kern}{}
  \DeclareFontShape{JT3}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\ltj@stdgtfont:jfm=jlreqv;script=latn;-kern}{}
\else
  \expandafter\let\csname \jlreq@yokokanjiencoding/mc/m/n/10\endcsname\relax
  \expandafter\let\csname \jlreq@tatekanjiencoding/mc/m/n/10\endcsname\relax
  \DeclareFontShape{\jlreq@yokokanjiencoding}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmname}{}
  \DeclareFontShape{\jlreq@yokokanjiencoding}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmnameg}{}
  \DeclareFontShape{\jlreq@tatekanjiencoding}{mc}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmname-v}{}
  \DeclareFontShape{\jlreq@tatekanjiencoding}{gt}{m}{n}{<->s*[\jlreq@jafontscale]\jlreq@jfmnameg-v}{}
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
% 文字サイズを基準としているような寸法に対しては，
% \set@fontsizeが実行されるたびに追随して値を変える
% その処理は\jlreq@setfontsizehookに入れる
\jlreq@saveoriginalcs{set@fontsize}
\renewcommand*{\set@fontsize}[3]{%
  \jlreq@original@set@fontsize{#1}{#2}{#3}%
  \jlreq@setfontsizehook
}
\def\jlreq@setfontsizehook{}
\appto\jlreq@setfontsizehook{\ifdim\parindent>0pt\setlength{\parindent}{1\jlreq@mol}\fi}
\ifx l\jlreq@engine\else
  \appto\jlreq@setfontsizehook{%
    \kanjiskip=\jlreq@kanjiskip
    \ifdim\xkanjiskip>0pt
      \xkanjiskip=\jlreq@xkanjiskip
    \fi
  }
\fi
\jlreq@divide{\jlreq@fontsize}{\jlreq@jafontsize}
\edef\jlreq@jafontinvscale{\strip@pt\jlreq@resultdimen}
\newcommand*{\jafontsize}[2]{%
  \begingroup
    \jlreq@iffloat{#1}{%
      \jlreq@tempdima=\jlreq@jafontinvscale\dimexpr #1pt\relax
      \edef\jlreq@do{\noexpand\fontsize{\strip@pt\jlreq@tempdima}{\unexpanded{#2}}}%
    }{%
      \jlreq@tempdima=\jlreq@jafontinvscale\dimexpr#1\relax
      \edef\jlreq@do{\noexpand\fontsize{\expandonce{\the\jlreq@tempdima}}{\unexpanded{#2}}}%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\renewcommand{\normalsize}{%
  \@setfontsize\normalsize{\jlreq@fontsize}{\jlreq@baselineskip}%
  \abovedisplayskip 1.1\jlreq@fontsize \@plus .3\jlreq@fontsize \@minus .4\jlreq@fontsize
  \abovedisplayshortskip \z@ \@plus .3\jlreq@fontsize
  \belowdisplayskip .9\jlreq@fontsize \@plus.3\jlreq@fontsize \@minus.4\jlreq@fontsize
  \belowdisplayshortskip \belowdisplayskip
  \let\@listi\@listI}

\if@tate\tate\fi % ここで発行しておく
\mcfamily\selectfont\normalsize
\setbox0\hbox{阿}
\setlength\Cht{\ht0}
\setlength\Cdp{\dp0}
\setlength\Cwd{\wd0}
\setlength\Cvs{\baselineskip}
\setlength\Chs{\wd0}

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
  \@setfontsize\small{.9\jlreq@fontsize}{\dimexpr 11\jlreq@baselineskip/17\relax}%
  \abovedisplayskip .85\jlreq@fontsize \@plus.3\jlreq@fontsize \@minus.4\jlreq@fontsize
  \abovedisplayshortskip \z@ \@plus.2\jlreq@fontsize
  \belowdisplayshortskip .4\jlreq@fontsize \@plus.2\jlreq@fontsize \@minus.2\jlreq@fontsize
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
  \rensujiskip=0\jlreq@mol plus 0.25\jlreq@mol minus 0\jlreq@mol
\fi

% このあたりはtarticleと同じ
\setlength\lineskip{.1\jlreq@gol}
\setlength\normallineskip{.1\jlreq@gol}
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
% landscapeの場合縦横をひっくり返す
\if@landscape
  \setlength\@tempdima  {\paperheight}
  \setlength\paperheight{\paperwidth}
  \setlength\paperwidth {\@tempdima}
\fi

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

% \textwidthと\textheightのデフォルト値は縦横ともに0.75倍（調整が入る）．
%.. \textwidth：文字送り方向の行長
% 二段の場合は最初の段の頭から次の段の後まで
% 一度\textwidthに一行の長さの文字数を入れる（段組の場合でも）
\@tempdima=1\zw
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
      \jlreq@note{一行の長さは52文字以下が望ましい (2.4.2.c 注2)．}
    \fi
  \else
    \ifnum\number\textwidth>40
      \jlreq@note{一行の長さは40文字以下が望ましい (2.4.2.c 注2)．}
    \fi
  \fi
\fi
\multiply\textwidth\@tempdima
\if@twocolumn
  \setlength{\textwidth}{\dimexpr2\textwidth + \columnsep\relax}
\fi

\setlength{\topskip}{1\zw} % フォントサイズと一致させる

%.. \textheight：行送り方向の長さ
% 一番上（直後に\topskip由来が入る）から最終行のベースラインまでの長さ．
% \topskipが十分ある時は先頭行のベースラインから最終行のベースライン＋\topskip
\ifx\jlreq@option@number@of@lines\@empty
  \if@tate
    \setlength{\textheight}{0.75\paperwidth}
  \else
    \setlength{\textheight}{0.75\paperheight}
  \fi
  \addtolength{\textheight}{-\topskip}
  \divide\textheight\baselineskip \multiply\textheight\baselineskip
  \addtolength{\textheight}{\topskip}
\else
  \setlength{\textheight}{\dimexpr\jlreq@option@number@of@lines\baselineskip - \baselineskip + \topskip\relax}
\fi

\ifx\jlreq@option@headfoot@verticalpos\@empty
  \if@tate\def\jlreq@option@headfoot@verticalpos{1zw}
  \else\def\jlreq@option@headfoot@verticalpos{2zh}\fi
\fi
\setlength{\headsep}{\jlreq@speciallength{\jlreq@option@headfoot@verticalpos}}
\ifdim\headsep<1\zw\relax\jlreq@note{基本版面との上下方向の最低の空き量を，基本版面の文字サイズの全角アキとする (26.1.a)．}\fi
\setlength{\headheight}{1\zw}
%.. 横
\ifx\jlreq@option@gutter\@empty
  % 中央配置
  \if@tate
    \setlength{\oddsidemargin}{\dimexpr\paperwidth - \textheight + \topskip\relax}
  \else
    \setlength{\oddsidemargin}{\dimexpr\paperwidth - \textwidth\relax}
  \fi
  \setlength{\oddsidemargin}{.5\oddsidemargin}
  \addtolength{\oddsidemargin}{-1in}
  \setlength{\evensidemargin}{\oddsidemargin}
\else
  \if@tate
    \setlength{\evensidemargin}{\jlreq@speciallength{\jlreq@option@gutter}}
    \setlength{\oddsidemargin}{\dimexpr\paperwidth - \textheight - \evensidemargin + \topskip - \Cht\relax}
    \addtolength{\evensidemargin}{\Cdp}
  \else
    \setlength{\oddsidemargin}{\jlreq@speciallength{\jlreq@option@gutter}}
    \setlength{\evensidemargin}{\dimexpr\paperwidth - \textwidth - \oddsidemargin\relax}
  \fi
  \addtolength{\oddsidemargin}{-1in}
  \addtolength{\evensidemargin}{-1in}
\fi

%.. 縦
% \topmarginに全体の頭からテキストの頭までの長さを入れる
% 天の値からtopmarginを設定する
\def\jlreq@settopmarginbyhead#1{
  \if@tate
    \setlength{\topmargin}{\dimexpr #1 - \headsep - \headheight - 1in\relax}
    \jlreq@note{縦組の場合は地の空き量を指定する (2.4.1.b)．}
  \else
    \setlength{\topmargin}{\dimexpr #1 - \headsep - \headheight - 1in - \topskip + \Cht\relax}
  \fi
}
\jlreq@aftercls@addtodeletecs{\jlreq@settopmarginbyhead}
% 地の値から
\def\jlreq@settopmarginbyfoot#1{
  \if@tate
    \setlength{\topmargin}{\dimexpr\paperheight - \textwidth - \headsep - \headheight - 1in - #1\relax}
  \else
    \jlreq@note{横組の場合は天の空き量を指定する (2.4.1.b)．}
    \setlength{\topmargin}{\dimexpr\paperheight - \textheight + \topskip - 1\zh - \headsep - \headheight - 1in - #1\relax}
  \fi
}
\jlreq@aftercls@addtodeletecs{\jlreq@settopmarginbyfoot}
\ifx\jlreq@option@head@space\@empty
  \ifx\jlreq@option@foot@space\@empty
    \if@tate
      \jlreq@settopmarginbyfoot{\dimexpr(\paperheight - \textwidth)/2\relax}
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
      \ClassWarningNoLine{jlreq}{head_space is ignored}
    \else
      \jlreq@settopmarginbyhead{\jlreq@speciallength{\jlreq@option@head@space}}
      \ClassWarningNoLine{jlreq}{foot_space is ignored}
    \fi
  \fi
\fi

%.. 下
\setlength{\footskip}{\dimexpr\headsep + 1\zw\relax}
% \maxdepth + \topskip = フォントサイズ×1.5（だってさ）
\setlength{\maxdepth}{\dimexpr1.5\zw - \topskip\relax}

%. 見出し関係 (4.1)
% 見出しの直前に実行される
\newcommand*{\jlreq@hook@beforeheadings}[1]{}
\def\jlreq@heading@allheadings{}
%.. 中/半扉見出し
% addcontentslineに渡すやつ：番号出すのと出さないの
\newcommand{\DeclareTobiraHeading}[3]{%
  \appto{\jlreq@heading@allheadings}{,#1}%
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\edef\csname jlreq@heading@setting@#1\endcsname{\unexpanded{#3}}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewTobiraHeading}%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \@ifundefined{jlreq@heading@maketoc@#1}{%
    % {1 = *}{2 = ラベル}{3 = running head}
    \expandafter\def\csname jlreq@heading@maketoc@#1\endcsname##1##2##3{%
      \ifnum0\jlreq@ifempty{##1}{}{1}\ifnum #2>\c@secnumdepth 1\fi>0\else
        \csname #1mark\endcsname{##3}%
        \addcontentsline{toc}{#1}{\protect\numberline{##2}##3}%
      \fi
    }%
  }{}%
  \begingroup
    \let\jlreq@contents@label@format=\@undefined
    \let\jlreq@format=\@undefined
    \edef\jlreq@label@format{\expandonce{\csname the#1\endcsname}}%
    \def\jlreq@heading@clearpage{\cleardoublepage}%
    \def\jlreq@pagestyle{empty}%
    \jlreq@parsekeyval[DeclareTobiraHeading:#1]{
      {label_format}{\def\jlreq@label@format{##1}}
      {format}{\def\jlreq@format####1####2{##1}}
      {pagestyle}{\def\jlreq@pagestyle{##1}}
      {type}[han,naka]{%
        \jlreq@switch{##1}{
          {han}{\def\jlreq@heading@clearpage{\clearpage}}
          {naka}{\def\jlreq@heading@clearpage{\cleardoublepage}}
        }%
      }
    }{#3}%
    \ifx\jlreq@format\@undefined
      \def\jlreq@format##1##2{##1##2}%
    \fi
    \edef\jlreq@formatwlabel{\noexpand\jlreq@format{\expandonce{\jlreq@label@format}}}%
    \def\jlreq@addtodo{}%
    \@ifundefined{l@#1}{%
      \edef\jlreq@do{\unexpanded{\setbox\jlreq@tempboxa=\hbox}{\expandonce{\jlreq@label@format}}}%
      \jlreq@do
      \jlreq@tempdima=\wd\jlreq@tempboxa
      \jlreq@tempdimb=1\jlreq@mol
      \divide\jlreq@tempdima by \jlreq@tempdimb
      \eappto\jlreq@addtodo{%
        \noexpand\def\expandonce{\csname l@#1\endcsname}{\unexpanded{\@dottedtocline{#2}{0\jlreq@mol}}{\the\numexpr\jlreq@tempdima + 1\relax\noexpand\jlreq@mol}}%
      }%
    }{}%
    \edef\jlreq@do{%
      \expandonce{\jlreq@addtodo}%
      \noexpand\def\expandonce{\csname jlreq@TobiraHeading@start@#1\endcsname}[####1]####2{%
        \unexpanded{\ifnum#2>\c@secnumdepth\else}%
          \unexpanded{\refstepcounter{#1}}%
        \noexpand\fi
        \expandonce{\csname jlreq@heading@maketoc@#1\endcsname}{}{\expandonce{\jlreq@label@format}}{####1}%
        \unexpanded{\ifnum#2>\c@secnumdepth\relax}%
          \expandonce{\jlreq@format{}{##1}}%
        \noexpand\else
          \expandafter\expandonce\expandafter{\jlreq@formatwlabel{##2}}%
        \noexpand\fi
        \noexpand\@afterheading
        \expandonce{\jlreq@heading@clearpage}%
        \unexpanded{\if@restonecol\twocolumn\fi}%
      }%
      \noexpand\def\expandonce{\csname jlreq@TobiraHeading@start@s@#1\endcsname}####1{%
        \expandonce{\jlreq@format{}{##1}}%
        \expandonce{\csname jlreq@heading@maketoc@#1\endcsname}{*}{\expandonce{\jlreq@label@format}}{####1}%
        \noexpand\@afterheading
        \expandonce{\jlreq@heading@clearpage}%
        \unexpanded{\if@restonecol\twocolumn\fi}%
      }%
      \noexpand\def\expandonce{\csname #1\endcsname}{%
        \unexpanded{\if@twocolumn\onecolumn\@restonecoltrue\else\@restonecolfalse\fi\cleardoublepage}%
        \ifx\jlreq@pagestyle\@empty\else\noexpand\thispagestyle{\expandonce{\jlreq@pagestyle}}\fi
        \noexpand\secdef{\expandonce{\csname jlreq@TobiraHeading@start@#1\endcsname}}{\expandonce{\csname jlreq@TobiraHeading@start@s@#1\endcsname}}}%
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
% \jlreq@startBlockHeading{1 = 命令名}{2 = レベル}{3 = スペース関連}{4 =  フォーマット関連}*{見出し}[副題]
% 字下げはa:**だと追加する値（ページ行頭には入らない），s:**も追加だがページ行頭でも入る，
% r:**だとその値に強制する．
\newcommand{\jlreq@startBlockHeading}[4]{%
  \edef\jlreq@startBlockHeading@format{\unexpanded{#4}}%
  \jlreq@startBlockHeading@{#1}{#2}{#3}%
}
% {1 = 命令}{2 = レベル}{3 = スペース関連}
\newcommand{\jlreq@startBlockHeading@}[3]{%
  \@ifstar{\@dblarg{\jlreq@startBlockHeading@@{#1}{#2}{#3}{*}}}{\@dblarg{\jlreq@startBlockHeading@@{#1}{#2}{#3}{}}}%
}
% {1 = 命令}{2 = レベル}{3 = スペース関連}{4 = *}[5 = running head]{6 = 見出し}
\long\def\jlreq@startBlockHeading@@#1#2#3#4[#5]#6{%
  \@ifnextchar[{\jlreq@startBlockHeading@@@{#1}{#2}{#3}{#4}{#5}{#6}}{\jlreq@startBlockHeading@@@{#1}{#2}{#3}{#4}{#5}{#6}[]}%
}

% {1 = ラベルフォーマット}{2 = 見出し文字列フォーマット}{3 = 見出し文字列フォーマット（ラベル無し）}{4 = 副題フォーマット}{5 = 副題フォーマット（ラベル無し）}{6 = 全体フォーマット}{7 = *}{8 = 見出し}{9 = 副題}
\long\def\jlreq@startBlockHeading@setformat#1#2#3#4#5#6#7#8#9{%
  % \jlreq@tempaに{ラベル}{見出し}{副題}という形のものを入れる
  \jlreq@ifempty{#7}{%
    % ラベルあり
    \def\jlreq@tempa{#1}%
    \long\def\jlreq@tempb##1{#2}%
    \jlreq@ifempty{#9}{\def\jlreq@tempc##1{}}{\long\def\jlreq@tempc##1{#4}}%
  }{%
    \def\jlreq@tempa{}%
    \long\def\jlreq@tempb##1{#3}%
    \jlreq@ifempty{#9}{\def\jlreq@tempc##1{}}{\long\def\jlreq@tempc##1{#5}}%
  }%
  \edef\jlreq@tempa{{\expandonce{\jlreq@tempa}}{\expandonce{\jlreq@tempb{#8}}}{\expandonce{\jlreq@tempc{#9}}}}%
  \long\def\jlreq@tempb##1##2##3{#6}%
  \edef\jlreq@tempa{\unexpanded{\expandafter\def\expandafter\jlreq@result\expandafter}{\noexpand\jlreq@tempb\expandonce{\jlreq@tempa}}}%
  \jlreq@tempa
}
% {1 = 命令}{2 = レベル}{3 = スペース関連}{4 = *}{5 = running head}{6 = 見出し}[7 = 副題]
\def\jlreq@startBlockHeading@@@#1#2#3#4#5#6[#7]{%
  \ifnum0\jlreq@ifempty{#4}{}{1}\ifnum #2>\c@secnumdepth 1\fi>0
    \def\jlreq@tempb{*}%
  \else
    \refstepcounter{#1}%
    \def\jlreq@tempb{}%
  \fi
  % 後で呼び出す\jlreq@startBlockHeading@addtocontentslineを定義する
  \long\def\jlreq@tempa##1##2##3##4##5##6##7{%
    \def\jlreq@tempa{##1}% 素のラベルのフォーマットを取り出す
    \edef\jlreq@tempb{\unexpanded{{##2}{##3}{##4}{##5}{##6}{##7}}{\expandonce{\jlreq@tempb}}}% 残り
  }%
  \expandafter\jlreq@tempa\jlreq@startBlockHeading@format
  \edef\jlreq@startBlockHeading@addtocontentsline{%
    \expandonce{\csname jlreq@heading@maketoc@#1\endcsname}{\unexpanded{#4}}{\expandonce{\jlreq@tempa}}{\unexpanded{#5}}%
  }%
  \expandafter\jlreq@startBlockHeading@setformat\jlreq@tempb{#6}{#7}%
  \def\jlreq@do{\jlreq@startBlockHeading@@@@#3}%
  \expandafter\jlreq@do\expandafter{\jlreq@result}%
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

% {1 = 字下げ}{2 = 字上げ}{3 = 前空き}{4 = 後ろ空き}{5 = トータル行数}{6 = afterindent}{7 = 偶数ページ改ページ}{8 = 出力}
\long\def\jlreq@startBlockHeading@@@@#1#2#3#4#5#6#7#8{%
  \if@noskipsec\leavevmode\fi
  \par
  \jlreq@ifempty{#7}{}{\jlreq@setcurrentpage}%
  \setbox\jlreq@tempboxa=\vbox{\noindent
    \jlreq@tempafalse % 中央寄せするか
    \ifthenelse{\equal{#1}{center}}{\jlreq@tempatrue}{%
      \jlreq@ifempty{#1}{}{\hsize=\dimexpr\hsize - #1\relax}%
    }%
    \ifthenelse{\equal{#2}{center}}{\jlreq@tempatrue}{%
      \jlreq@ifempty{#2}{}{\hsize=\dimexpr\hsize - #2\relax}%
    }%
    \ifjlreq@tempa\hfil\fi
    #8}%
  % \jlreq@tempskip(a/b)に前/後ろに入れるべき値を入れる
  % #3がa:ならばその値は\jlreq@tempskipaには足さず\jlreq@tempskipcに入れておく
  \jlreq@tempskipc=0pt
  \jlreq@startBlockHeading@analyzespace#3:\jlreq@endmark
  \setbox\jlreq@tempboxb=\vbox{　}%
  \jlreq@ifempty{#5}{%
    \ifx\jlreq@startBlockHeading@space\@empty\else
      \jlreq@tempskipa=\glueexpr\jlreq@startBlockHeading@space\relax
    \fi
    \jlreq@tempskipb=0pt\relax
  }{%
    \jlreq@tempskipb=\glueexpr(\baselineskip*(#5 + 1) - \ht\jlreq@tempboxb - \dp\jlreq@tempboxb - \ht\jlreq@tempboxa - \dp\jlreq@tempboxa)/2\relax
    \ifx\jlreq@startBlockHeading@space\@empty
      \jlreq@tempskipa=\jlreq@tempskipb
    \else
      \ifx a\jlreq@startBlockHeading@spacetype
        \jlreq@tempskipa=\jlreq@tempskipb
        \jlreq@tempskipc=\glueexpr\jlreq@startBlockHeading@space\relax
      \fi
      \ifx s\jlreq@startBlockHeading@spacetype
        \jlreq@tempskipa=\glueexpr\jlreq@tempskipb + \jlreq@startBlockHeading@space\relax
      \fi
      \ifx r\jlreq@startBlockHeading@spacetype
        \jlreq@tempskipa=\glueexpr\jlreq@startBlockHeading@space\relax%
        \jlreq@tempskipb=\glueexpr(\baselineskip*(#5 + 1) - \ht\jlreq@tempboxb - \dp\jlreq@tempboxb - \ht\jlreq@tempboxa - \dp\jlreq@tempboxa) - \jlreq@startBlockHeading@space\relax
      \fi
    \fi
  }%
  \ifdim\jlreq@tempskipc=0pt\else\vspace{\jlreq@tempskipc}\fi
  % \baselineskipから来るglueを引いておく
  \jlreq@tempskipa=\glueexpr\jlreq@tempskipa - \baselineskip + \dp\jlreq@tempboxb\relax
  \jlreq@startBlockHeading@addtocontentsline
  \setbox\jlreq@tempboxa=\vbox{%
    \ifdim\jlreq@tempskipa=0pt\else\vskip\jlreq@tempskipa\fi
    \noindent
    \ifthenelse{\equal{#1}{center}}{}{\jlreq@ifempty{#1}{}{\hskip #1}}%
    \box\jlreq@tempboxa}%
  \dp\jlreq@tempboxa=\dimexpr\dp\jlreq@tempboxa + \ht\jlreq@tempboxa\relax
  \ht\jlreq@tempboxa=0pt
%  \showbox\jlreq@tempboxa
  \box\jlreq@tempboxa
  \par
  \jlreq@ifempty{#7}{\ifodd\jlreq@currentpage\nobreak\fi}{\nobreak}%
  \prevdepth=0pt
  \jlreq@startBlockHeading@analyzespace#4:\jlreq@endmark
  \jlreq@tempskipb=\glueexpr\jlreq@tempskipb + \ht\jlreq@tempboxb - \baselineskip\relax
  \ifx\jlreq@startBlockHeading@space\@empty\else
    \ifx a\jlreq@startBlockHeading@spacetype
      \jlreq@tempskipb = \glueexpr\jlreq@tempskipb + \jlreq@startBlockHeading@space\relax
    \else
      \jlreq@tempskipb=\glueexpr\jlreq@startBlockHeading@space + \ht\jlreq@tempboxb - \baselineskip\relax
    \fi
  \fi
  \ifdim\jlreq@tempskipb=0pt\else\vspace{\jlreq@tempskipb}\fi
  #6%
  \@afterheading
}

% \DeclareBlockHeading{命令名}{レベル}{設定}
\newcommand{\DeclareBlockHeading}[3]{%
  \appto{\jlreq@heading@allheadings}{,#1}%
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\edef\csname jlreq@heading@setting@#1\endcsname{\unexpanded{#3}}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewBlockHeading}%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  % 目次への出力をするマクロ．外部に切り出しておく．
  \@ifundefined{jlreq@heading@maketoc@#1}{%
    % {1 = *}{2 = ラベル}{3 = running head}
    \expandafter\def\csname jlreq@heading@maketoc@#1\endcsname##1##2##3{%
      \ifnum0\jlreq@ifempty{##1}{}{1}\ifnum #2>\c@secnumdepth 1\fi>0\else
        \csname #1mark\endcsname{##3}%
        \addcontentsline{toc}{#1}{\protect\numberline{##2}##3}%
      \fi
    }%
  }{}%
  \begingroup
    \def\jlreq@lines{1}%
    \def\jlreq@before@space{}%
    \def\jlreq@after@space{}%
    \def\jlreq@before@lines{}%
    \def\jlreq@after@lines{}%
    \def\jlreq@font{}%
    \def\jlreq@subtitle@font{}%
    \def\jlreq@indent{0\jlreq@mol}%
    \def\jlreq@end@indent{0\jlreq@mol}%
    \edef\jlreq@format{\unexpanded{##1##2##3}}%
    \edef\jlreq@heading@text@format{\unexpanded{##1}}%
    \def\jlreq@pagebreak{}%
    \def\jlreq@label@format{\@seccntformat{#1}}%
    \newif\ifjlreq@hang\jlreq@hangtrue
    \def\jlreq@after@label@space{1\jlreq@mol}%
    \def\jlreq@second@heading@text@indent@wlabel{0pt}%
    \def\jlreq@second@heading@text@indent@wolabel{0pt}%
    \edef\jlreq@subtitle@format{\unexpanded{---##1---}}%
    \def\jlreq@subtitle@indent{1\jlreq@mol}%
    \def\jlreq@afterindent{\@afterindenttrue}%
    \def\jlreq@allowbreak@evenpage{*}% 偶数ページでも改ページを許可するならば空，そうでないなら*
    \newif\ifjlreq@subtitle@break\jlreq@subtitle@breaktrue
    \def\jlreq@subtitle@indent{1\jlreq@mol}%
    % 先頭が*なら\jlreq@resultをtrueにする．*を除いた部分を\jlreq@resultに入れる．
    \def\jlreq@ifstar##1{%
      \jlreq@iffirsttoken{##1}{*}{%
        \jlreq@resulttrue
        \expandafter\def\expandafter\jlreq@result\expandafter{\@gobble##1}%
      }{%
        \jlreq@resultfalse
        \def\jlreq@result{##1}%
      }%
    }%
    % a,bみたいなのをaとbにわける．カンマがなければbは空．引数を{a}{b}として##2を呼び出す．
    \def\jlreq@parsecomma##1##2{%
      \def\jlreq@tempa####1####2{##2}%
      \def\@tempa####1,####2\jlreq@endmark{%
        \jlreq@ifempty{####2}{%
          \def\@tempa{}%
        }{%
          \def\@tempa########1,\jlreq@endmark{\def\@tempa{########1}}%
          \@tempa####2\jlreq@endmark
        }%
        \edef\@tempa{\unexpanded{\jlreq@tempa{####1}}{\expandonce{\@tempa}}}%
        \edef\jlreq@do{\expandafter\expandafter\expandafter\unexpanded\expandafter\expandafter\expandafter{\@tempa}}%
      }%
      \@tempa##1,\jlreq@endmark
      \jlreq@do
    }%
    \jlreq@parsekeyval[BlockHeading:#1]{
      {lines}{\def\jlreq@lines{##1}}
      {before_space}{\def\jlreq@before@space{##1}}
      {after_space}{\def\jlreq@after@space{##1}}
      {before_lines}{%
        \jlreq@ifstar{##1}%
        \edef\jlreq@before@lines{%
          \ifjlreq@result s:\else a:\fi
          \expandonce{\jlreq@result}%
        }%
      }
      {after_lines}{\def\jlreq@after@lines{##1}}
      {font}{\def\jlreq@font{##1}}
      {subtitle_font}{\def\jlreq@subtitle@font{##1}}
      {indent}{\def\jlreq@indent{##1}}
      {end_indent}{\def\jlreq@end@indent{##1}}
      {format}{\edef\jlreq@format{\unexpanded{##1}}}
      {after_label_space}{\def\jlreq@after@label@space{##1}}
      {second_heading_text_indent}{%
        \jlreq@parsecomma{##1}{%
          \jlreq@ifstar{####1}%
          \ifjlreq@result\jlreq@hangfalse\else\jlreq@hangtrue\fi
          \let\jlreq@second@heading@text@indent@wlabel=\jlreq@result
          \jlreq@ifempty{####2}{%
            \let\jlreq@second@heading@text@indent@wolabel=\jlreq@second@heading@text@indent@wlabel
          }{%
            \def\jlreq@second@heading@text@indent@wolabel{####2}%
          }%
        }%
      }
      {label_format}{\edef\jlreq@label@format{\unexpanded{##1}}}
      {subtitle_format}{\edef\jlreq@subtitle@format{\unexpanded{##1}}}
      {subtitle_indent}{\def\jlreq@subtitle@indent{##1}}
      {subtitle_break}[true,false]{\csname jlreq@subtitle@break##1\endcsname}
      {afterindent}[true,false]{\edef\jlreq@afterindent{\expandonce{\csname @afterindent##1\endcsname}}}
      {allowbreak_if_evenpage}[true,false]{%
        \jlreq@switch{##1}{
          {true}{\def\jlreq@allowbreak@evenpage{}}
          {false}{\def\jlreq@allowbreak@evenpage{*}}
        }%
      }
      {pagebreak}[clearpage,cleardoublepage,clearcolumn,nariyuki]{%
        \jlreq@switch{##1}{
          {clearpage}{\def\jlreq@pagebreak{\clearpage}}
          {cleardoublepage}{\def\jlreq@pagebreak{\cleardoublepage}}
          {clearcolumn}{\if@twocolumn\def\jlreq@pagebreak{\newpage}\else\def\jlreq@pagebreak{}\fi}
          {nariyuki}{\def\jlreq@pagebreak{}}
        }%
      }
    }{#3}%
    \ifx\jlreq@font\@empty\else
      \edef\jlreq@format{%
        \expandonce{\jlreq@font}\expandonce{\jlreq@format}%
      }%
    \fi
    \edef\jlreq@label@format@modified{%
      \noexpand\noindent
      \unexpanded{\setbox\jlreq@tempboxa=\hbox}{\expandonce{\jlreq@label@format}}%
      \unexpanded{\hangindent=}%
      \ifjlreq@hang
        \wd\jlreq@tempboxa
      \else
        0pt
        \unexpanded{\edef\jlreq@startBlockHeading@labellength{\the\wd\jlreq@tempboxa}}%
      \fi
      \unexpanded{\hangindent=\dimexpr\hangindent + }(\expandonce{\jlreq@after@label@space}) + (\expandonce{\jlreq@second@heading@text@indent@wlabel})\noexpand\relax
      \box\jlreq@tempboxa
      \hskip0pt\relax
    }%
    \edef\jlreq@heading@text@format@wlabel{%
      \ifdim\jlreq@after@label@space=0pt\else
        \noexpand\hspace*{\noexpand\dimexpr\expandonce{\jlreq@after@label@space}\noexpand\relax}%
      \fi
      \expandonce{\jlreq@heading@text@format}%
    }%
    \edef\jlreq@heading@text@format@wolabel{%
      \ifdim\dimexpr\jlreq@second@heading@text@indent@wolabel\relax=0pt\else
        \noexpand\hangindent=\noexpand\dimexpr\expandonce{\jlreq@second@heading@text@indent@wolabel}\noexpand\relax
      \fi
      \expandonce{\jlreq@heading@text@format}%
    }%
    \def\jlreq@make@subtitle@format##1##2{%
      \edef##1{%
        \ifjlreq@subtitle@break\unexpanded{{\par}\nobreak\noindent\global\hangafter=0}\fi
        \unexpanded{\global\hangindent=\dimexpr\hangindent + }(\expandonce{\jlreq@subtitle@indent}) ##2\noexpand\relax
        \ifdim\jlreq@subtitle@indent=0pt\else
          \ifjlreq@subtitle@break\else\unexpanded{\hspace*}{\expandonce{\jlreq@subtitle@indent}}\fi
        \fi
        {\ifx\jlreq@subtitle@font\@empty\else\expandonce{\jlreq@subtitle@font}\fi\expandonce{\jlreq@subtitle@format}}%
      }%
    }%
    \jlreq@make@subtitle@format\jlreq@subtitle@format@wlabel{%
      - (\expandonce{\jlreq@second@heading@text@indent@wlabel})%
      \ifjlreq@hang\else + (\noexpand\jlreq@startBlockHeading@labellength)\fi
    }%
    \jlreq@make@subtitle@format\jlreq@subtitle@format@wolabel{- (\expandonce{\jlreq@second@heading@text@indent@wolabel})}%
    \def\jlreq@addtodo{}%
    \@ifundefined{l@#1}{%
      % 長さは適当に計測する
      \begingroup
        % ちょっと大きめで計測しておく
        \csname c@#1\endcsname=9
        \setbox\jlreq@tempboxa=\hbox{\jlreq@label@format}%
        \edef\jlreq@do{\noexpand\jlreq@tempdima=\the\dimexpr\wd\jlreq@tempboxa\relax}%
      \expandafter\endgroup
      \jlreq@do
      \jlreq@tempdimb=1\jlreq@mol
      \divide\jlreq@tempdima by \jlreq@tempdimb
      \eappto\jlreq@addtodo{%
        \noexpand\def\expandonce{\csname l@#1\endcsname}{\unexpanded{\@dottedtocline{#2}{0\jlreq@mol}}{\the\numexpr\jlreq@tempdima + 1\relax\noexpand\jlreq@mol}}%
      }%
    }{}%
    % before/after_lines優先
    \ifx\jlreq@before@space\@empty\else\edef\jlreq@before@space{r:\expandonce{\jlreq@before@space}}\fi
    \ifx\jlreq@before@lines\@empty\else\edef\jlreq@before@space{\expandonce{\jlreq@before@lines}\baselineskip}\fi
    \ifx\jlreq@after@space\@empty\else\edef\jlreq@after@space{r:\expandonce{\jlreq@after@space}}\fi
    \ifx\jlreq@after@lines\@empty\else\edef\jlreq@after@space{a:\expandonce{\jlreq@after@lines}\baselineskip}\fi
    \edef\jlreq@do{%
      \expandonce{\jlreq@addtodo}%
      \noexpand\edef\expandonce{\csname #1\endcsname}{\noexpand\unexpanded{%
        \noexpand\jlreq@hook@beforeheadings{#1}%
        \expandonce{\jlreq@pagebreak}%
        \unexpanded{\jlreq@startBlockHeading{#1}{#2}}%
        {{\expandonce{\jlreq@indent}}{\expandonce{\jlreq@end@indent}}{\expandonce{\jlreq@before@space}}{\expandonce{\jlreq@after@space}}{\expandonce{\jlreq@lines}}{\expandonce{\jlreq@afterindent}}{\expandonce{\jlreq@allowbreak@evenpage}}}%
        {%
          {\expandonce{\jlreq@label@format}}{\expandonce{\jlreq@label@format@modified}}%
          {\expandonce{\jlreq@heading@text@format@wlabel}}{\expandonce{\jlreq@heading@text@format@wolabel}}%
          {\expandonce{\jlreq@subtitle@format@wlabel}}{\expandonce{\jlreq@subtitle@format@wolabel}}%
          {\expandonce{\jlreq@format}}%
        }%
      }}%
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
  \@ifundefined{#1}{\DeclareBlockHeading{#1}{#2}{#3}}{}%s
}

%.. 同行見出し
% \DeclareRuninHeading{命令名}{レベル}{設定}
\newcommand*{\DeclareRuninHeading}[3]{%
  \appto{\jlreq@heading@allheadings}{,#1}%
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\edef\csname jlreq@heading@setting@#1\endcsname{\unexpanded{#3}}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewRuninHeading}%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \@ifundefined{l@#1}{\expandafter\def\csname l@#1\endcsname{\@dottedtocline{#2}{0\jlreq@mol}{2\jlreq@gol}}}{}%
  \begingroup
    \def\jlreq@font{\normalfont\normalsize}%
    \def\jlreq@indent{0\jlreq@mol}%
    \def\jlreq@mark{}%
    \def\jlreq@label@font{}%
    \def\jlreq@after@space{1\jlreq@mol}%
    \jlreq@parsekeyval[RuninHeading:#1]{%
      {font}{\def\jlreq@font{##1}}
      {indent}{\def\jlreq@indent{##1}}
      {mark}{\def\jlreq@mark{##1}}
      {after_space}{%
        \ifdim##1<0pt\ClassWarning{jlreq}{after_space in Runin Heading #1 should be positive}\fi
        \def\jlreq@after@space{##1}%
      }
    }{#3}%
    % \@startsection{#1}{#2}{indent}{0pt}{-after_space}{font}
    \edef\jlreq@do{%
      \noexpand\def\expandonce{\csname #1\endcsname}{%
        \unexpanded{\jlreq@hook@beforeheadings{#1}}%
        \expandafter\jlreq@ifempty\expandafter{\jlreq@mark}{%
          \noexpand\@startsection{\unexpanded{#1}}{\unexpanded{#2}}{\expandonce{\jlreq@indent}}{0pt}{-\expandonce{\jlreq@after@space}}{\expandonce{\jlreq@font}}%
        }{%
          \noexpand\@startsection{\unexpanded{#1}}{\unexpanded{#2}}{\expandonce{\jlreq@indent}}{0pt}{-\expandonce{\jlreq@after@space}}{\noexpand\kern\expandonce{\jlreq@indent}\expandonce{\jlreq@mark}\noexpand\kern-\expandonce{\jlreq@indent}\expandonce{\jlreq@font}}%
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
\newcount\jlreq@wraplinecount
\newdimen\jlreq@hangindent
\def\jlreq@CutinHeading@start#1#2#3#4#5#6#7{%
  \ifnum0\ifnum\jlreq@wraplinecount<-1 1\fi\ifnum\jlreq@wraplinecount>1 1\fi>0
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
  % \jlreq@resultboxに見出し部分を，\jlreq@CutinHeading@linecountに見出し自身に何行使うかを入れる
  \ifnum\jlreq@CutinHeading@linecount=1\relax
    \setbox\jlreq@resultbox=\vbox{\parindent=0pt\rightskip=0pt\leftskip=0pt\hbox{#1#6}}%
    \def\jlreq@CutinHeading@linecount{2}%
  \else
    \jlreq@inlinenote@determinelength{#6}{#1}{}{\jlreq@CutinHeading@linecount}{\jlreq@CutinHeading@linecount}{\@tempdima}{\linewidth}%
    \def\jlreq@CutinHeading@linecount{3}%
  \fi
  % 普通の一行の高さ/深さに合わせて見出しのボックスを出力
  \setbox\@tempboxa=\vtop to \dimexpr\numexpr\jlreq@CutinHeading@linecount - 1\relax\baselineskip + 1\jlreq@gol\relax{\vskip 0pt plus 1fill minus 1fill \box\jlreq@resultbox\vskip 0pt plus 1fill minus 1fill}%
  \setbox\jlreq@tempboxa=\hbox{あ}%
  \ht\@tempboxa=\ht\jlreq@tempboxa
  \dp\@tempboxa=\dp\jlreq@tempboxa
  \@tempdima=\wd\@tempboxa
  % \hang****を設定
  \hangindent=\dimexpr#2 + \@tempdima + #3\relax\hangafter=-\jlreq@CutinHeading@linecount
  \jlreq@hangindent=\hangindent\jlreq@wraplinecount=\hangafter
  \hspace*{#2}%
  \kern-\dimexpr\hangindent + \parindent\relax
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
  \expandafter\def\csname jlreq@heading@level@#1\endcsname{#2}%
  \expandafter\def\csname jlreq@heading@setting@#1\endcsname{#3}%
  \expandafter\def\csname jlreq@heading@type@#1\endcsname{\RenewCutinHeading}%
  \begingroup
    \def\jlreq@fontcommand{\sffamily\bfseries}%
    \def\jlreq@onelinemax{6\zw}%
    \def\jlreq@twolinemax{20\zw}%
    \def\jlreq@indent{0\jlreq@mol}%
    \def\jlreq@after@space{1\jlreq@mol}%
    \jlreq@parsekeyval[CutinHeading:#1]{
      {font}{\def\jlreq@fontcommand{##1}}
      {onelinemax}{\def\jlreq@onelinemax{##1}}
      {twolinemax}{\def\jlreq@twolinemax{##1}}
      {indent}{\def\jlreq@indent{##1}}
      {after_space}{\def\jlreq@after@space{##1}}
    }{#3}%
    \ifthenelse{\lengthtest{\jlreq@after@space < 0.99\jlreq@mol} \OR \lengthtest{\jlreq@after@space > 2.01\jlreq@mol}}{%
      \jlreq@note{窓見出しと本文との空き量は，基本版面の文字サイズの全角以上，2倍未満とする (4.1.10.c)．}%&
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
  \begingroup
    \@ifundefined{jlreq@heading@setting@#1}{\ClassError{jlreq}{Unknown heading: #1}{\@ehc}}%
    \expandafter\let\expandafter\level\expandafter=\csname jlreq@heading@level@#1\endcsname
    \expandafter\let\expandafter\setting\expandafter=\csname jlreq@heading@setting@#1\endcsname
    \expandafter\let\expandafter\macroname\expandafter=\csname jlreq@heading@type@#1\endcsname
    \edef\jlreq@do{\expandonce{\macroname}{#1}{\expandonce{\level}}{\expandonce{\setting},\unexpanded{#2}}}%
  \expandafter\endgroup
  \jlreq@do
}
% 見出し#1をマクロ#2に保存する
\newcommand{\SaveHeading}[2]{%
  \@ifundefined{jlreq@heading@setting@#1}{\ClassError{jlreq}{Unknown heading: #1}{\@ehc}}{}%
  \begingroup
    \edef\jlreq@do{%
      \unexpanded{\edef#2}{%
        \noexpand\expandonce{\expandonce{\csname jlreq@heading@type@#1\endcsname}}%
        \noexpand\unexpanded{\unexpanded{{#1}}}%
        {\noexpand\expandonce{\expandonce{\csname jlreq@heading@level@#1\endcsname}}}%
        {\noexpand\expandonce{\expandonce{\csname jlreq@heading@setting@#1\endcsname}}}%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
}

\newcommand*{\jlreq@keepbaselineskip}[1]{%
  \begingroup
    \edef\jlreq@do{\unexpanded{#1}\noexpand\baselineskip=\the\baselineskip}%
  \expandafter\endgroup
  \jlreq@do
}

\newcommand*\jlreq@HeadingType[1]{%
  \expandafter\ifx\csname jlreq@heading@type@#1\endcsname\relax UndefinedHeading
  \else
    \jlreq@HeadingType@{#1}{\RenewTobiraHeading}{TobiraHeading}{%
    \jlreq@HeadingType@{#1}{\RenewBlockHeading}{BlockHeading}{%
    \jlreq@HeadingType@{#1}{\RenewRuninHeading}{RuninHeading}{%
    \jlreq@HeadingType@{#1}{\RenewCutinHeading}{CutinHeading}{%
    UnknownHeading}}}}%
  \fi
}
\newcommand*\jlreq@HeadingType@[2]{%
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

%.. 各種定義
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

\if@tate
  \renewcommand{\thepart}{\Kanji{part}}
  \ifthenelse{\equal{\jlreq@article@type}{article}}{}{\renewcommand{\thechapter}{\Kanji{chapter}}}
  \renewcommand{\thesection}{\rensuji{\@arabic\c@section}}
  \renewcommand{\thesubsection}{\rensuji{\@alph\c@subsection}}
  \renewcommand{\thesubsubsection}{\rensuji{\@arabic\c@subsubsection}}
  \renewcommand{\theparagraph}{(\rensuji{\@arabic\c@paragraph})}
  \renewcommand{\thesubparagraph}{(\rensuji{\@arabic\c@subparagraph})}

  \ifthenelse{\equal{\jlreq@article@type}{article}}{
    \NewBlockHeading{part}{0}{font={\jlreq@keepbaselineskip{\LARGE}},indent=4\jlreq@mol,lines=4,after_label_space=1\jlreq@mol,second_heading_text_indent={-1\jlreq@mol,1\jlreq@mol},subtitle_font={\jlreq@keepbaselineskip{\large}}}
    \if@twoside\ModifyHeading{part}{allowbreak_if_evenpage=true}\fi
  }
  {% book, report
    \NewTobiraHeading{part}{-1}{label_format={第\thepart 部\hspace*{1\jlreq@mol}},format={\null\vfill {\Huge\hspace*{2\jlreq@mol}#1#2}\vspace*{2\jlreq@gol}}}
    \NewBlockHeading{chapter}{0}{indent=2\jlreq@mol,lines=6,label_format={第\thechapter 章},font={\huge},after_label_space=1\jlreq@mol,second_heading_text_indent={-1\jlreq@mol,1\jlreq@mol},subtitle_font={\jlreq@keepbaselineskip{\Large}}}
    \if@twoside\ModifyHeading{chapter}{allowbreak_if_evenpage=true}\fi
    \renewcommand{\thechapter}{\Kanji{chapter}}
  }
  \NewBlockHeading{section}{1}{font={\jlreq@keepbaselineskip{\Large}},indent=6\jlreq@mol,lines=3,after_label_space=1\jlreq@mol,second_heading_text_indent={-1\jlreq@mol,1\jlreq@mol},subtitle_font={\jlreq@keepbaselineskip{\normalsize}}}
  \if@twoside\ModifyHeading{section}{allowbreak_if_evenpage=true}\fi
  \NewBlockHeading{subsection}{2}{font={\jlreq@keepbaselineskip{\large}},indent=8\jlreq@mol,lines=2,after_label_space=1\jlreq@mol,second_heading_text_indent={-1\jlreq@mol,1\jlreq@mol},subtitle_font={\jlreq@keepbaselineskip{\small}}}
  \if@twoside\ModifyHeading{subsection}{allowbreak_if_evenpage=true}\fi
  \NewBlockHeading{subsubsection}{3}{font={\jlreq@keepbaselineskip{\normalsize}},indent=10\jlreq@mol,lines=1,before_lines=1,subtitle_break=false,after_label_space=1\jlreq@mol,second_heading_text_indent={-1\jlreq@mol,1\jlreq@mol},,subtitle_font={\jlreq@keepbaselineskip{\scriptsize}}}
  \if@twoside\ModifyHeading{subsubsection}{allowbreak_if_evenpage=true}\fi
  \NewRuninHeading{paragraph}{4}{font={\jlreq@keepbaselineskip{\normalsize}}}
  \NewRuninHeading{subparagraph}{5}{font={\jlreq@keepbaselineskip{\normalsize}},indent=1\jlreq@mol}
\else% yoko
  \renewcommand{\thepart}{\Roman{part}}
  \renewcommand{\thesubsection}{\thesection .\arabic{subsection}}
  \renewcommand{\thesubsubsection}{\thesubsection .\arabic{subsubsection}}
  \renewcommand{\theparagraph}{\thesubsubsection .\arabic{paragraph}}
  \renewcommand{\thesubparagraph}{\theparagraph .\arabic{subparagraph}}
  \ifthenelse{\equal{\jlreq@article@type}{article}}{
    \NewBlockHeading{part}{0}{font={\jlreq@keepbaselineskip{\LARGE\sffamily\bfseries}},label_format={第\thepart 部},lines=4,after_label_space=1\jlreq@mol,second_heading_text_indent={-1\jlreq@mol,1\jlreq@mol},subtitle_font={\jlreq@keepbaselineskip{\large}}}
    \renewcommand{\thesection}{\arabic{section}}
  }
  {% book, report
    \NewTobiraHeading{part}{-1}{label_format={第\thepart 部\hspace*{1\jlreq@gol}},format={\null\vfil {\Huge\sffamily\bfseries #1#2}\vfil}}
    \NewBlockHeading{chapter}{0}{%
      font={\jlreq@keepbaselineskip{\huge\sffamily\bfseries}},
      label_format={第\thechapter 章},
      lines=5,after_label_space=1\jlreq@mol,second_heading_text_indent={-1\jlreq@mol,1\jlreq@mol},
      subtitle_font={\jlreq@keepbaselineskip{\Large}}}
    \renewcommand{\thechapter}{\arabic{chapter}}
    \renewcommand{\thesection}{\thechapter.\arabic{section}}
    \ifthenelse{\equal{\jlreq@article@type}{book}}{
      \ModifyHeading{chapter}{pagebreak=cleardoublepage}
    }{
      \ModifyHeading{chapter}{pagebreak=clearpage}
    }
  }
  \NewBlockHeading{section}{1}{font={\jlreq@keepbaselineskip{\Large\sffamily\bfseries}},lines=3,after_label_space=1\jlreq@mol,second_heading_text_indent={-1\jlreq@mol,1\jlreq@mol},subtitle_font={\jlreq@keepbaselineskip{\normalsize}}}
  \NewBlockHeading{subsection}{2}{font={\jlreq@keepbaselineskip{\large\sffamily\bfseries}},lines=2,after_label_space=1\jlreq@mol,second_heading_text_indent={-1\jlreq@mol,1\jlreq@mol},subtitle_font={\jlreq@keepbaselineskip{\small}}}
  \NewBlockHeading{subsubsection}{3}{font={\jlreq@keepbaselineskip{\normalsize\sffamily\bfseries}},lines=1,before_lines=1,subtitle_break=false,after_label_space=1\jlreq@mol,second_heading_text_indent={-1\jlreq@mol,1\jlreq@mol},subtitle_font={\jlreq@keepbaselineskip{\scriptsize}}}
  \NewRuninHeading{paragraph}{4}{font={\jlreq@keepbaselineskip{\normalsize\sffamily\bfseries}},indent=1\jlreq@mol}
  \NewRuninHeading{subparagraph}{5}{font={\jlreq@keepbaselineskip{\normalsize\sffamily\bfseries}},indent=2\jlreq@mol}
\fi

\ifthenelse{\equal{\jlreq@article@type}{article}}{}{% book, report
  \if@openright
    \ModifyHeading{part}{type=naka}
    \ModifyHeading{chapter}{pagebreak=cleardoublepage}
  \else
    \ModifyHeading{part}{type=han}
    \ModifyHeading{chapter}{pagebreak=clearpage}
  \fi
}
\jlreq@switch{\jlreq@article@type}{
  {book}{%
    \renewcommand{\jlreq@heading@maketoc@chapter}[3]{%
      \jlreq@ifempty{#1}{%
        \chaptermark{#3}%
        \ifnum0\if@mainmatter\else1\fi\ifnum\jlreq@heading@level@chapter>\c@secnumdepth 1\fi>0
          \addcontentsline{toc}{chapter}{#3}%
        \else
          \addcontentsline{toc}{chapter}{\protect\numberline{#2}#3}%
        \fi
      }{}%
    }
  }
  {report}{
    \renewcommand{\jlreq@heading@maketoc@chapter}[3]{%
      \jlreq@ifempty{#1}{%
        \chaptermark{#3}%
        \ifnum0\ifnum\jlreq@heading@level@chapter>\c@secnumdepth 1\fi>0
          \addcontentsline{toc}{chapter}{#3}%
        \else
          \addcontentsline{toc}{chapter}{\protect\numberline{#2}#3}%
        \fi
      }{}%
    }
  }
}


%. 注
% 合印：4.2.3
% 文字サイズは6ポイントくらい（4.2.3.a）とりあえす\scriptsize

% \footnoteと\footnotemarkの前後に\jlreq@hook@prenote/\jlreq@hook@postnoteを入れる
\jlreq@saveoriginalcs{footnote}%
\def\footnote{%
  \jlreq@hook@prenote
  \@ifnextchar[{\jlreq@fixjfm@footnote@}{\jlreq@fixjfm@footnote@@}%
}
\long\def\jlreq@fixjfm@footnote@[#1]#2{%
  \jlreq@original@footnote[#1]{#2}%
  \jlreq@hook@postnote
}
\long\def\jlreq@fixjfm@footnote@@#1{%
  \jlreq@original@footnote{#1}%
  \jlreq@hook@postnote
}
\jlreq@saveoriginalcs{footnotemark}%
\def\footnotemark{%
  \jlreq@hook@prenote
  \@ifnextchar[{\jlreq@fixjfm@footnotemark@}{\jlreq@fixjfm@footnotemark@@}%
}
\def\jlreq@fixjfm@footnotemark@[#1]{%
  \jlreq@original@footnotemark[#1]%
  \jlreq@hook@postnote
}
\def\jlreq@fixjfm@footnotemark@@{%
  \jlreq@original@footnotemark
  \jlreq@hook@postnote
}

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
      \setbox\jlreq@tempboxa=\hbox to\z@{\hskip-\@tempdima\raise\dimexpr.5\zw + (\ht\@tempboxa + \dp\@tempboxa)/2\relax\box\@tempboxa\hss}%
      \dp\jlreq@tempboxa=0pt\ht\jlreq@tempboxa=0pt\box\jlreq@tempboxa}%
    }%
    \ifx l\jlreq@engine
      \def\jlreq@hook@prenote{%
        \jlreq@lastnodechar=\lastnodechar
        \ifnum\lastnodechar>-1\inhibitglue\fi
      }
    \else
      % (u)platexの時は代入すると\inhibitglueが効かなくなる
      \def\jlreq@hook@prenote{%
        \ifnum\lastnodechar>-1\inhibitglue\fi
        \jlreq@lastnodechar=\lastnodechar
      }
    \fi
    \def\jlreq@hook@postnote{\jlreq@fixjfm}
  }
}
\jlreqsetup{reference_mark=inline}
% \@footnotemarkをシンプルなものにする
\def\jlreq@setdefaultnotemark#1#2{%
  \def#1{%
    \leavevmode
    \ifhmode\edef\@x@sf{\the\spacefactor}\nobreak\fi
    #2%
    \ifhmode\spacefactor\@x@sf\fi
    \relax}
}
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
  \@tempdimb=1\jlreq@mol
  \divide\@tempdima\@tempdimb \multiply\@tempdima\@tempdimb
  \global\jlreq@footnoteindent=\dimexpr\textwidth - \@tempdima\relax
}
% 4.2.5.d
\newcommand{\@makefntext}[1]{\jlreq@makefntext{#1}}
\jlreq@jlreqsetup@add{footnotetext_indent}{
  \ifthenelse{\equal{#1}{one}}{
    \long\def\jlreq@makefntext##1{\parindent 1\jlreq@mol
      \addtolength{\leftskip}{\dimexpr\jlreq@footnoteindent + 1\jlreq@mol\relax}% 全体をインデント+1文字分下げる
      \noindent\hskip -1\jlreq@mol\jlreq@referencemark@format{\@thefnmark}\hskip 1\jlreq@mol##1}% 見出し出力と一文字分の空き
  }{
    \long\def\jlreq@makefntext##1{\parindent 1\jlreq@mol
      \addtolength{\leftskip}{\jlreq@footnoteindent}% 全体をインデント
      \noindent\hskip 1\jlreq@mol\jlreq@referencemark@format{\@thefnmark}\hskip 1\jlreq@mol##1}% 見出し出力と一文字分の空き
  }
}
\jlreqsetup{footnotetext_indent=one}
% 合印
\renewcommand*{\@makefnmark}{%
  \jlreq@ifydir{\jlreq@notemark{\@thefnmark}}{\hbox{\jlreq@notemark{\@thefnmark}}}%
}
% 4.2.2注3
\if@tate
  \renewcommand*{\thefootnote}{\jlreq@open@bracket@before@space\inhibitglue（\rensuji{\@arabic\c@footnote}）\inhibitglue}
\else
  \renewcommand*{\thefootnote}{\arabic{footnote}\hbox{}）\inhibitglue}
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
\long\def\jlreq@endnote@addtext#1#2{%
  \expandafter\gdef\expandafter\jlreq@endnote@texts\expandafter{\jlreq@endnote@texts{{#1}{#2}}}}
\def\endnote{\jlreq@hook@prenote\@ifnextchar[{\jlreq@endnote}{\jlreq@endnote[]}}  
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
      \expandafter\unrestored@protected@xdef\csname\jlreq@endnotemarkname\endcsname{\csname \jlreq@endnotecounter\endcsname}%
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
      \expandafter\unrestored@protected@xdef\csname\jlreq@endnotemarkname\endcsname{\csname \jlreq@endnotecounter\endcsname}%
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
\PushPostHook{par}{\jlreq@endnote@parhook}
\edef\jlreq@do{
  \unexpanded{\def\jlreq@hook@beforeheadings#1}{\expandonce{\jlreq@hook@beforeheadings{#1}}\unexpanded{\jlreq@endnote@hook@beforeheadings{#1}}}
}
\jlreq@do

\jlreq@jlreqsetup@add{endnote_position}{
  \def\jlreq@endnote@parhook{}
  \def\jlreq@endnote@hook@beforeheadings##1{}
  \jlreq@tempafalse % headingsが指定された
  % \jlreq@tempcにセクション名たちを入れていく
  \def\jlreq@tempc{}
  \@for\jlreq@tempa:=#1\do{
    \jlreq@switch{\jlreq@tempa}{
      {headings}{\jlreq@tempatrue}
      {paragraph}{
        \jlreq@tempatrue% _paragraphの時は_headingsも有効にする
        \def\jlreq@endnote@parhook{%
          \ifx\jlreq@endnote@texts\@empty\else
            \vskip\dimexpr-\baselineskip\relax
            \vskip\dimexpr0pt\relax
            \theendnotes
          \fi
        }
      }
      {
        \def\@tempa##1##2\jlreq@endmark{##1}
        \edef\@tempa{\expandafter\@tempa\jlreq@tempa\jlreq@endmark}
        \expandafter\ifx\@tempa _
          \def\@tempa##1##2\jlreq@endmark{\def\jlreq@result{##2}}
          \expandafter\@tempa\jlreq@tempa\jlreq@endmark
          \edef\jlreq@tempc{\jlreq@tempc,\jlreq@result}
        \else
          \ClassError{jlreq}{Invalid value \jlreq@tempa\space in endnote_position}{\@ehc}
        \fi
      }
    }
  }

  \ifjlreq@tempa
    \edef\jlreq@do{%
      \unexpanded{\def\jlreq@endnote@hook@beforeheadings##1}{\expandonce{\jlreq@endnote@hook@beforeheadings{##1}}%
        \noexpand\theendnotes
      }
    }
    \jlreq@do
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
\jlreqsetup{endnote_position=headings}
\AtEndDocument{\theendnotes}

%.. 傍注（4.2.7）
\setlength{\marginparsep}{2\jlreq@mol} % フォントサイズ×2（4.2.7：特に問題に～e）
{%
  \footnotesize
  % \jlreq@tempdimaにマージン最小値を入れる
  \if@tate
    \setlength{\jlreq@tempdima}{\dimexpr\paperheight - \topmargin - \headheight - \headsep - \voffset - 1in - \textwidth\relax}
    \if@twocolumn
      \ifdim\jlreq@tempdima>\dimexpr\paperheight - \jlreq@tempdima - \textwidth\relax
        \setlength{\jlreq@tempdima}{\dimexpr\paperheight - \jlreq@tempdima - \textwidth\relax}
      \fi
    \fi
  \else
    \setlength{\jlreq@tempdima}{\dimexpr \paperwidth - \textwidth - 1in - \oddsidemargin - \marginparsep\relax}
    \if@twocolumn
      \ifdim\jlreq@tempdima>\dimexpr\oddsidemargin + 1in - \marginparsep\relax
        \setlength{\jlreq@tempdima}{\dimexpr\oddsidemargin + 1in - \marginparsep\relax}
      \fi
    \fi
  \fi
  \ifx\jlreq@option@sidenote@width\@empty
    \setlength{\marginparwidth}{\dimexpr\jlreq@tempdima - 2\zw - \marginparsep\relax}
    % 4.7.2.b: 並列中の行長は15文から20字程度
    \ifdim\marginparwidth>20\jlreq@mol
      \global\marginparwidth=20\jlreq@mol
    \fi
  \else
    \setlength{\marginparwidth}{\jlreq@speciallength{\jlreq@option@sidenote@width}}
    \ifnum\marginparwidth>\jlreq@tempdima
      \ClassWarningNoLine{jlreq}{sidenote_width is greater than the width of the margin}
    \fi
  \fi
  \@tempdima=1\jlreq@mol
  \global\divide\marginparwidth\@tempdima
  \global\multiply\marginparwidth\@tempdima
  \global\setlength{\marginparpush}{.5\@tempdima} % 同上：g
}

\ifdim\marginparwidth>25\zw\relax
  \jlreq@note{並列注の字詰め方向の長さ（行長）は，15字から20字くらいである．ケースによっては25字程度にする場合もある (4.2.7)．}
\fi

\def\jlreq@sidenotemarkname{@thefnmark}% 合印用番号を一時的に入れるマクロ名

% (1) \footnoteとかと同じ形式 sidenote_type=number
% (2) 文中にマークを入れて，傍注には見出しが入る sidenote_type=symbol
% (3) 文中は強調文字列，傍注には見出しが入る sidenote_type=symbol
% (4) 文中は何も無し，傍注には見出しが入る sidenote_type=symbol

% (1) では\sidenote[]{}を定義
% (2) では\sidenote{見出し}{注中身}を定義
\long\def\@sidenotetext#1{%
  \marginpar{\reset@font\footnotesize
    \color@begingroup
    \@makesidetext{#1}%
    \color@endgroup
  }%
}
\jlreq@setdefaultnotemark\@sidenotemark\@makesidemark
\def\jlreq@sidenotecounter{footnote}% 傍注用のカウンタ名
\jlreq@jlreqsetup@add{sidenote_type}[number,symbol]{\def\jlreq@sidenote@type{#1}}
\jlreqsetup{sidenote_type=number}
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
    \def\@makesidemark{\@makefnmark}
  }{% sidenote_type = symbol
    \def\sidenote{\jlreq@sidenote}
    \def\sidenotemark{\jlreq@sidenotemark}
    \def\sidenotetext{\jlreq@sidenotetext}
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
    \def\@makesidemark{\@makefnmark}

    \edef\jlreq@do{
      % \jlreq@lastnodecharの仕込みはすんでいる
      \unexpanded{\long\def\sidenote#1#2}{%
        \expandonce{\sidenote{#1}{#2}}%
        \noexpand\jlreq@hook@postnote
      }
      \unexpanded{\long\def\sidenotemark#1}{%
        \expandonce{\sidenotemark{#1}}%
        \noexpand\jlreq@hook@postnote
      }
    }
    \jlreq@do
  }
}
\jlreq@jlreqsetup@add{sidenote_symbol}{\def\jlreq@sidenote@defaultmark{#1}}
\jlreq@jlreqsetup@add{sidenote_keyword_font}{\def\jlreq@sidenote@keywordfont{#1}}
\jlreqsetup{sidenote_symbol=＊,sidenote_keyword_font={}}

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
    \ClassWarning{jlreq}{\string\warichu\space failed, maybe a bug}%
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
% \jlreq@resultboxに整形結果を返す（垂直ボックス）．見つからなかったらvoid
\newcommand{\jlreq@inlinenote@determinelength}[7]{%
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
}


%. ページスタイル．
% とりあえず脇に縦書きで配置するのは無視する．
% メモ：
% 2.6.1.cの後半が前半と整合的でないように見える……
% 柱：両柱と片柱（2.6.3）
\@tempdima=\jlreq@speciallength{\jlreq@headfoot@sidemargin}
\ifthenelse{\lengthtest{\@tempdima=0pt} \OR \(\lengthtest{0.99\zw < \@tempdima} \AND \lengthtest{\@tempdima < 1.01\zw}\)}{}{
  \jlreq@note{ノンブルまたは柱は，基本版面の左右にそろえるか，全角アキだけ寄せた位置に配置する (2.6.1.b)．}
}

% bottom-leftみたいなのを解釈する．入力の順番はどっちでも良いが，出力は<top/bottom><left/right>の順番
% #1 = bottom-leftみたいなのを{bottom}{left}に変換し，#2に代入，#3はデフォルト値，出力形式で入れる
\newcommand*{\jlreq@pagestyle@parse@position}[3]{%
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
    {\ClassError{jlreq}{Invalid position: #1}{\@ehc}}
  }%
}


% odd_running_head=_sectionのように下線から始まる場合，その値の見出し命令を柱に出すようにする．
% 要するに\ps@***に\sectionmarkを定義するように仕込む．
% 常にodd=rightmark，even=leftmarkになる．
% 場所指定は奇数ページの方．偶数ページは反対になる．
% mark_format={_chapter={第\thechapter 章\quad #1}}のような形．odd=とかeven=とかも仕込めるようにしたけど
% あまり意味がない気がしてきた．oddやevenが優先される．
\newcommand*{\DeclarePageStyle}[2]{%
  \expandafter\edef\csname jlreq@pagestyle@setting@#1\endcsname{\unexpanded{#2}}%
  \begingroup
    \def\jlreq@nombre@position{}%
    \def\jlreq@running@head@position{}%
    \def\jlreq@nombre{\thepage}%
    \def\jlreq@odd@running@head{}%
    \def\jlreq@even@running@head{}%
    \def\jlreq@command{}%
    \def\jlreq@mark@format{}%
    \def\jlreq@font{}%
    % 柱とノンブルの間
    \def\jlreq@gap{1.5\zw}%
    \newif\ifjlreq@clearmark\jlreq@clearmarktrue
    \newif\ifjlreq@pstate\jlreq@pstatefalse
    \jlreq@parsekeyval[PageStyle:#1]{
      *{tate}{\jlreq@pstatetrue}
      *{yoko}{\jlreq@pstatefalse}
      {nombre_position}{\def\jlreq@nombre@position{##1}}
      {running_head_position}{\def\jlreq@running@head@position{##1}}
      {nombre}{\def\jlreq@nombre{##1}}
      {odd_running_head}{\def\jlreq@odd@running@head{##1}}
      {even_running_head}{\def\jlreq@even@running@head{##1}}
      {font}{\def\jlreq@font{##1}}
      {mark_format}{\edef\jlreq@mark@format{\unexpanded{##1}}}
      {command}{\edef\jlreq@command{\unexpanded{##1}}}
      {gap}{\def\jlreq@gap{##1}}
      {clear_mark}[true,false]{\csname jlreq@clearmark##1\endcsname}
    }{#2}%
    % 見出しを出す場合：evenに章などの高いレベルの見出しを出す（2.6.3.a）
    \def\jlreq@markdefinition{}%
    \def\jlreq@even@running@head@level{}%
    \def\jlreq@markdefinition{}%
    % _***な指定な時に，
    % * \jlreq@[even/odd]@running@headを\leftmarkや\rightmarkに書き換える
    % * \jlreq@markdefinitionに\***markを定義するマクロを入れる．
    % また\jlreq@[even/odd]@running@head@levelに見出しのレベルを入れる．
    % \jlreq@makemark{odd/even}running_headの中身\jlreq@endmark
    \def\jlreq@makemark##1##2##3\jlreq@endmark{%
      \ifx_##2%
        \ifthenelse{\equal{##1}{even}}{%
          \def\jlreq@even@running@head{\leftmark}%
        }{%
          \def\jlreq@odd@running@head{\rightmark}%
        }%
        \@ifundefined{jlreq@heading@setting@##3}{}{%
          \expandafter\edef\csname jlreq@##1@running@head@level\endcsname{\csname jlreq@heading@level@##3\endcsname}%
        }%
        % mark_formatを調べる
        \def\jlreq@tempa####1{%
          \jlreq@tempafalse
          \let\jlreq@result=\@undefined
          \jlreq@parsekeyval*{
            {##1}{\edef\jlreq@result{\unexpanded{########1}}\jlreq@tempatrue}
            {##2##3}{\ifjlreq@tempa\else\edef\jlreq@result{\unexpanded{########1}}\fi}
          }{####1}%
        }%
        \expandafter\jlreq@tempa\expandafter{\jlreq@mark@format}%
        \ifx\jlreq@result\@undefined
          \edef\jlreq@result{\expandonce{\csname the##3\endcsname}\noexpand\quad\unexpanded{####1}}%
        \fi
        % どっちを\markbothにしてどっちを\markrightにするかは縦組か横組かに依る
        \ifthenelse{\equal{##1}{\if@tate odd\else even\fi}}{%
          \def\jlreq@markcommand{\markboth}%
          \def\jlreq@markcommandafter{{}}%
        }{%
          \def\jlreq@markcommand{\markright}%
          \def\jlreq@markcommandafter{}%
        }%
        \edef\jlreq@markdefinition{%
          \expandonce{\jlreq@markdefinition}%
          \noexpand\def\expandonce{\csname ##3mark\endcsname}\unexpanded{####1}{\expandonce{\jlreq@markcommand}%
            {\expandonce{\jlreq@result}}\expandonce{\jlreq@markcommandafter}}%
        }%
      \fi
      \jlreq@ifendmark{##2}{}{\@gobble}%
    }%
    \def\@tempb{\jlreq@makemark{even}}%
    \expandafter\@tempb\jlreq@even@running@head\jlreq@endmark\jlreq@endmark
    \def\jlreq@odd@running@head@level{}%
    \def\@tempb{\jlreq@makemark{odd}}%
    \expandafter\@tempb\jlreq@odd@running@head\jlreq@endmark\jlreq@endmark
    \ifx\jlreq@odd@running@head@level\@empty\else\ifx\jlreq@even@running@head@level\@empty\else
      \ifnum\jlreq@odd@running@head@level<\jlreq@even@running@head@level
        \jlreq@note{偶数ページには奇数ページよりアウトラインレベルの高い見出しを入れる (ページスタイル #1内，2.6.3.a)．}%
      \fi
    \fi\fi
    % \jlreq@[even/odd][head/foot]に入れていく．tateか否かで場合分け．
    \ifjlreq@pstate\expandafter\@firstoftwo\else\expandafter\@secondoftwo\fi{%
      \ifx\jlreq@nombre@position\@empty\def\jlreq@nombre@position{0pt}\fi
      \ifx\jlreq@running@head@position\@empty\def\jlreq@running@head@position{0pt}\fi
      \if@tate\else
        \jlreq@note{ノンブルおよび柱を縦組にして配置するのは縦組の場合のみである (ページスタイル #1 内，2.6.1)．}%
      \fi
      % 柱とノンブルを入れる箱を作る（\jlreq@resultを展開すると\setboxするマクロがでる）
      \def\jlreq@make@tatebox##1{%
        \edef\jlreq@result{%
          \unexpanded{\setbox\jlreq@tempboxa=\hbox to }%
          \unexpanded{\dimexpr\headsep + \headheight + \textheight}\if@tate\else\unexpanded{ - \topskip + 1\zh}\fi\noexpand\relax
          {\unexpanded{\tate\adjustbaseline}%
            \ifx##1\@empty\else
              \noexpand\hspace{\unexpanded{\dimexpr\headsep + \headheight + }%
              \if@tate\else\unexpanded{\topskip - \Cht + }\fi
              \expandonce{\jlreq@running@head@position}\noexpand\relax}%
              \expandonce{##1}%
            \fi
            \ifx\jlreq@nombre\@empty\else
              \noexpand\hfill
              \expandonce{\jlreq@nombre}%
              \ifdim\dimexpr\jlreq@nombre@position\relax=0pt\else
                \unexpanded{\hspace{\dimexpr\jlreq@nombre@position\relax}}%
              \fi
            \fi
          }%
          % Overfull防止
          \ifx l\jlreq@engine
            \unexpanded{\wd\jlreq@tempboxa=\headheight}%
          \else
            \unexpanded{\ht\jlreq@tempboxa=\headheight\dp\jlreq@tempboxa=0pt}%
          \fi
        }%
      }%
      % 左に配置するヘッダ．#1は柱の中身．（一回展開で正しくでてくる．）
      \def\jlreq@make@lefthead##1{%
        \jlreq@make@tatebox{##1}%
        \edef\jlreq@lefthead{%
          \expandonce{\jlreq@result}%
          \noexpand\hspace{\noexpand\dimexpr
            \if@tate\unexpanded{-\Cdp}\fi - \unexpanded{\headsep - 1\zw}%
          \noexpand\relax}%
          \unexpanded{\box\jlreq@tempboxa\hfil}%
        }%
      }%
      % 右に配置するヘッダ．
      \def\jlreq@make@righthead##1{%
        \jlreq@make@tatebox{##1}%
        \edef\jlreq@righthead{%
          \expandonce{\jlreq@result}%
          \noexpand\hspace{\unexpanded{\dimexpr\textwidth}
            \if@tate\unexpanded{- \topskip + \Cht}\fi
            \unexpanded{ + \headsep}%
          \noexpand\relax}%
          \unexpanded{\box\jlreq@tempboxa\hss}%
        }%
      }%
      \if@tate
        \jlreq@make@lefthead{\jlreq@odd@running@head}%
        \let\jlreq@oddhead=\jlreq@lefthead
        \jlreq@make@righthead{\jlreq@even@running@head}%
        \let\jlreq@evenhead=\jlreq@righthead
      \else
        \jlreq@make@righthead{\jlreq@odd@running@head}%
        \let\jlreq@oddhead=\jlreq@righthead
        \jlreq@make@lefthead{\jlreq@even@running@head}%
        \let\jlreq@evenhead=\jlreq@lefthead
      \fi
      \let\jlreq@oddfoot=\@empty
      \let\jlreq@evenfoot=\@empty
    }{% yoko
      \ifx\jlreq@nombre@position\@empty\def\jlreq@nombre@position{bottom-center}\fi
      \expandafter\jlreq@pagestyle@parse@position\expandafter{\jlreq@nombre@position}{\jlreq@nombre@position}{{bottom}{center}}%
      \ifx\jlreq@running@head@position\@empty\def\jlreq@running@head@position{top-center}\fi
      \expandafter\jlreq@pagestyle@parse@position\expandafter{\jlreq@running@head@position}{\jlreq@running@head@position}{{top}{center}}%
      \ifx\jlreq@running@head@position\@empty\def\jlreq@running@head@position{{top}{center}}\fi
      \ifthenelse{\(
        \boolean{@tate} \AND \(
          \equal{\expandafter\@secondoftwo\jlreq@nombre@position}{right} \OR
          \equal{\expandafter\@secondoftwo\jlreq@running@head@position}{right}
      \)\) \OR \(
        \(\NOT \boolean{@tate}\) \AND \(
          \equal{\expandafter\@secondoftwo\jlreq@nombre@position}{left} \OR
          \equal{\expandafter\@secondoftwo\jlreq@running@head@position}{left}
        \)
      \)}{%
        \if@twoside
          \jlreq@note{柱やノンブルは，左ページでは，基本版面の左端の延長線にノンブル又は柱の先頭をそろえて配置するか，基本版面の左端の延長線から基本版面の文字サイズの全角アキだけ右に寄せた位置に配置する (ページスタイル #1 内，2.6.1.b)．}%
        \fi
      }{}%
      {\jlreq@font
        \ifthenelse{\lengthtest{\jlreq@gap < 1.49\zw} \OR \( \lengthtest{\jlreq@gap > 1.51\zw} \AND \lengthtest{\jlreq@gap < 1.99\zw} \) \OR \lengthtest{\jlreq@gap > 2.01\zw}}{\jlreq@note{ノンブルと柱との空き量は文字サイズの2倍又は1.5倍とする (ページスタイル #1 内，2.6.1.c)．}}{}%
      }%
      % ##2を##1 = left/center/rightの場所，##4を##3の場所に置く．被った場合は##2を外側にする．
      % 戻り値は\jlreq@result
      \def\jlreq@setheadfoot##1##2##3##4{%
        % 左，真ん中，右に置くもの（対応するものがなければ空）をそれぞれ格納する．
        \def\jlreq@left{}\def\jlreq@center{}\def\jlreq@right{}%
        % \ifjlreq@tempa = if(##1 == ##3 && ##2 != "" && ##4 != "")
        \jlreq@tempatrue
        \jlreq@ifempty{##2}{\jlreq@tempafalse}{}%
        \jlreq@ifempty{##4}{\jlreq@tempafalse}{}%
        \ifthenelse{\equal{##1}{##3}}{}{\jlreq@tempafalse}%
        \ifjlreq@tempa
          \ifthenelse{\equal{##1}{right}}{%
            \edef\jlreq@right{\unexpanded{##4}\noexpand\hspace{\expandonce{\jlreq@gap}}\unexpanded{##2}}%
          }{%
            \expandafter\edef\csname jlreq@##1\endcsname{\unexpanded{##2}\noexpand\hspace{\expandonce{\jlreq@gap}}\unexpanded{##4}}%
          }%
        \else
          \jlreq@ifempty{##2}{}{\expandafter\def\csname jlreq@##1\endcsname{##2}}%
          \jlreq@ifempty{##4}{}{\expandafter\def\csname jlreq@##3\endcsname{##4}}%
        \fi
        % フォント命令を挿入
        \ifx\jlreq@font\@empty\else
          \ifx\jlreq@left\@empty\else\edef\jlreq@left{{\expandonce{\jlreq@font}\expandonce{\jlreq@left}}}\fi
          \ifx\jlreq@center\@empty\else\edef\jlreq@center{{\expandonce{\jlreq@font}\expandonce{\jlreq@center}}}\fi
          \ifx\jlreq@right\@empty\else\edef\jlreq@right{{\expandonce{\jlreq@font}\expandonce{\jlreq@right}}}\fi
        \fi
        % \jlreq@setheadfoot@に回して処理
        \edef\jlreq@do{\noexpand\jlreq@setheadfoot@{\expandonce{\jlreq@left}}{\expandonce{\jlreq@center}}{\expandonce{\jlreq@right}}}%
        \jlreq@do
      }%
      % ##1 ##2 ##3と並んだヘッダを作る，戻り値は\jlreq@result
      \def\jlreq@setheadfoot@##1##2##3{%
        % - \Cdpは端にそろえるための補正
        \jlreq@ifempty{##1}{\def\jlreq@left{}}{\edef\jlreq@left{\noexpand\hspace{\dimexpr\jlreq@expand@speciallength{\jlreq@headfoot@sidemargin}\if@tate - \Cdp\fi\relax}\unexpanded{##1}}}%
        % +\topskip - \Chtは\jlreq@headfoot@sidemargin = 0ptの時に本文の右に一致させるための補正．
        \jlreq@ifempty{##3}{\def\jlreq@right{}}{\edef\jlreq@right{\unexpanded{##3}\noexpand\hspace{\dimexpr\jlreq@expand@speciallength{\jlreq@headfoot@sidemargin}\if@tate + \topskip - \Cht\fi\relax}}}%
        \jlreq@ifempty{##2}{%
          \edef\jlreq@result{\expandonce{\jlreq@left}\hfil\expandonce{\jlreq@right}}%
          \jlreq@ifempty{##1}{\jlreq@ifempty{##3}{\def\jlreq@result{}}{}}{}%
        }{%
          \ifx\jlreq@left\@empty\else\edef\jlreq@left{\noexpand\hbox to 0pt{\expandonce{\jlreq@left}\hss}}\fi
          \ifx\jlreq@right\@empty\else\edef\jlreq@right{\noexpand\hbox to 0pt{\hss\expandonce{\jlreq@right}}}\fi
          \edef\jlreq@result{\expandonce{\jlreq@left}\hfil\unexpanded{##2}\hfil\expandonce{\jlreq@right}}%
        }%
      }%
      % \nombre@<top/bottom>を定義
      \def\jlreq@nombre@top{}\def\jlreq@nombre@bottom{}%
      \expandafter\edef\csname jlreq@nombre@\expandafter\@firstoftwo\jlreq@nombre@position\endcsname{\expandonce{\jlreq@nombre}}%
      % \odd@running@head@<top/bottom>を定義
      \def\jlreq@odd@running@head@top{}\def\jlreq@odd@running@head@bottom{}%
      \expandafter\edef\csname jlreq@odd@running@head@\expandafter\@firstoftwo\jlreq@running@head@position\endcsname{\expandonce{\jlreq@odd@running@head}}%
      % \@oddheadを定義
      \edef\jlreq@do{\unexpanded{\jlreq@setheadfoot{\expandafter\@secondoftwo\jlreq@nombre@position}}{\expandonce{\jlreq@nombre@top}}\unexpanded{{\expandafter\@secondoftwo\jlreq@running@head@position}}{\expandonce{\jlreq@odd@running@head@top}}}%
      \jlreq@do\let\jlreq@oddhead=\jlreq@result
      % \@oddfootを定義
      \edef\jlreq@do{\unexpanded{\jlreq@setheadfoot{\expandafter\@secondoftwo\jlreq@nombre@position}}{\expandonce{\jlreq@nombre@bottom}}\unexpanded{{\expandafter\@secondoftwo\jlreq@running@head@position}}{\expandonce{\jlreq@odd@running@head@bottom}}}%
      \jlreq@do\let\jlreq@oddfoot=\jlreq@result
      % ##1 = {}{}の後ろを逆にする
      \def\getoppositeposition##1{%
        \jlreq@switch{\expandafter\@secondoftwo##1}{
          {center}{\def\jlreq@tempe{center}}
          {right}{\def\jlreq@tempe{left}}
          {left}{\def\jlreq@tempe{right}}
        }%
        \edef##1{{\expandafter\@firstoftwo##1}{\jlreq@tempe}}%
      }%
      \getoppositeposition\jlreq@nombre@position
      \getoppositeposition\jlreq@running@head@position
      % 上と同じことをする
      % \nombre@<top/bottom>を定義
      \def\jlreq@nombre@top{}\def\jlreq@nombre@bottom{}%
      \expandafter\edef\csname jlreq@nombre@\expandafter\@firstoftwo\jlreq@nombre@position\endcsname{\expandonce{\jlreq@nombre}}%
      % \even@running@head@<top/bottom>を定義
      \def\jlreq@even@running@head@top{}\def\jlreq@even@running@head@bottom{}%
      \expandafter\edef\csname jlreq@even@running@head@\expandafter\@firstoftwo\jlreq@running@head@position\endcsname{\expandonce{\jlreq@even@running@head}}%
      % \@evenheadを定義
      \edef\jlreq@do{\unexpanded{\jlreq@setheadfoot{\expandafter\@secondoftwo\jlreq@nombre@position}}{\expandonce{\jlreq@nombre@top}}\unexpanded{{\expandafter\@secondoftwo\jlreq@running@head@position}}{\expandonce{\jlreq@even@running@head@top}}}%
      \jlreq@do\let\jlreq@evenhead=\jlreq@result
      % \@evenfootを定義
      \edef\jlreq@do{\unexpanded{\jlreq@setheadfoot{\expandafter\@secondoftwo\jlreq@nombre@position}}{\expandonce{\jlreq@nombre@bottom}}\unexpanded{{\expandafter\@secondoftwo\jlreq@running@head@position}}{\expandonce{\jlreq@even@running@head@bottom}}}%
      \jlreq@do\let\jlreq@evenfoot=\jlreq@result
    }%
    \edef\jlreq@do{%
      \noexpand\def\expandonce{\csname ps@#1\endcsname}{%
        \unexpanded{\def\jlreq@current@pagestyle{#1}}%
        \ifjlreq@clearmark\noexpand\jlreq@heading@execmacro@toallheadings\noexpand\jlreq@clearheadingmarks\fi
        \unexpanded{\let\@mkboth=\markboth}%
        \unexpanded{\def\@oddhead}{\expandonce{\jlreq@oddhead}}%
        \unexpanded{\def\@oddfoot}{\expandonce{\jlreq@oddfoot}}%
        \unexpanded{\def\@evenhead}{\expandonce{\jlreq@evenhead}}%
        \unexpanded{\def\@evenfoot}{\expandonce{\jlreq@evenfoot}}%
      }%
      % \jlreq@markdefinition/\jlreq@commandは引数トークンを持つ可能性がある
      \noexpand\edef\expandonce{\csname ps@#1\endcsname}{%
        \noexpand\expandonce{\expandonce{\csname ps@#1\endcsname}}%
        \noexpand\unexpanded{\expandonce{\jlreq@markdefinition}}%
        \noexpand\unexpanded{\expandonce{\jlreq@command}}%
      }%
    }%
  \expandafter\endgroup
  \jlreq@do
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
    \@ifundefined{jlreq@pagestyle@setting@#1}{\ClassError{jlreq}{Unknown pagestyle: #1}{\@ehc}}{}%
    \expandafter\let\expandafter\setting\expandafter=\csname jlreq@pagestyle@setting@#1\endcsname
    \edef\jlreq@do{\noexpand\RenewPageStyle{#1}{\expandonce{\setting},\unexpanded{#2}}}%
  \expandafter\endgroup
  \jlreq@do
}

%.. 各種定義
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
  \RenewPageStyle{plain}{nombre=\thepage,odd_running_head={},even_running_head={},clear_mark=false}
  \NewPageStyle{myheadings}{nombre=\thepage,odd_running_head=\rightmark,even_running_head=\leftmark,clear_mark=false}
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
  \RenewPageStyle{plain}{nombre=\thepage,odd_running_head={},even_running_head={},nombre_position={bottom-center},clear_mark=false}
  \ModifyPageStyle{headings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center}
  \NewPageStyle{myheadings}{nombre=\thepage,nombre_position=bottom-center,running_head_position=top-center,odd_running_head=\rightmark,even_running_head=\leftmark,clear_mark=false}
\fi
\ModifyPageStyle{plain}{font=\small}
\ModifyPageStyle{headings}{font=\small}
\ModifyPageStyle{myheadings}{font=\small}

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
  \reset@font\small
  \vskip\abovecaptionskip
  \sbox\@tempboxa{{\jlreq@@makecaption@label@font #1}\hskip 1\jlreq@mol{\jlreq@@makecaption@font #2}}%
  \ifdim \wd\@tempboxa >\hsize
    {\jlreq@@makecaption@label@font #1}\hskip1\jlreq@mol{\jlreq@@makecaption@font #2}\relax\par
  \else
    \global\@minipagefalse
    \hbox to\hsize{\hfil\box\@tempboxa\hfil}%
  \fi
  \vskip\belowcaptionskip}}
\jlreq@jlreqsetup@add{caption_font}{\def\jlreq@@makecaption@font{#1}}
\jlreq@jlreqsetup@add{caption_label_font}{\def\jlreq@@makecaption@label@font{#1}}
\jlreqsetup{caption_font={\sffamily\bfseries},caption_label_font={\sffamily\bfseries}}
% 特に根拠のない値
\setlength\abovecaptionskip{.5\jlreq@gol}
\setlength\belowcaptionskip{0pt}


% \begin{figure}***\caption{???}\end{figure}を
% \begin{figure}\layoutfloat{***}\pcaption{???}\end{figure}にする．
% 
%\long\def\jlreq@replace@layoutfloat#1\caption{\layoutfloat{#1}\jlreq@caption}
%\long\def\jlreq@caption#1{\jlreq@ifendmark{#1}{}{\pcaption{#1}\csname\jlreq@replace@layoutfloat@#1\endcsname}}
%\def\jlreq@modify@float#1{%
%  \jlreq@saveoriginalcs{#1}
%  \@namedef{#1}{\@ifnextchar[{\@nameuse{jlreq@float@#1}}{\@nameuse{jlreq@float@@#1}}}
%  \expandafter\long\expandafter\gdef\csname jlreq@float@#1\endcsname[##1]{%
%    \csname jlreq@original@#1\endcsname[##1]%
%    \csname jlreq@process@insertlayoutfloat@#1\endcsname{}%
%  }
%  \expandafter\long\expandafter\gdef\csname jlreq@float@@#1\endcsname{%
%    \csname jlreq@original@#1\endcsname
%    \csname jlreq@process@insertlayoutfloat@#1\endcsname{}%
%  }
%  \expandafter\long\expandafter\gdef\csname jlreq@process@insertlayoutfloat@#1\endcsname ##1##2\end{%
%    \csname jlreq@checkenvname@#1\endcsname{##1##2}\end
%  }
%  \expandafter\long\expandafter\gdef\csname jlreq@checkenvname@#1\endcsname ##1\end##2{%
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
%\jlreq@aftercls@addtodeletecs{\jlreq@modify@float}

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
    \lineskip .5\jlreq@gol
    \begin{tabular}[t]{c}%
      \@author
    \end{tabular}%
    \par
  }%
  \vskip\baselineskip
  {\jlreq@keepbaselineskip{\large}\@date}%
  \end{center}%
  \par
  \vskip\baselineskip
  \ifvoid\jlreq@abstractbox\else\unvbox\jlreq@abstractbox\fi
}

%.. abstract
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
            \jlreq@pushhook@postpar{\futurelet\jlreq@nextchar\jlreq@openbracket@hook}%
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
        \parindent=1\jlreq@mol
        \begin{center}%
          {\sffamily\bfseries\abstractname}%
        \end{center}%
        \list{}{%
          \listparindent\parindent
          \itemindent\listparindent
          \labelwidth\z@
          \labelsep\z@
          \leftmargin=2\jlreq@mol
          \rightmargin\leftmargin
          \@tempdima=1\zw
          \@tempdimb=\dimexpr\linewidth - \@totalleftmargin - \leftmargin - \rightmargin\relax
          \@tempdimc=\@tempdimb
          \divide\@tempdimb by \@tempdima\multiply\@tempdimb by \@tempdima
          \ifdim\@tempdimb=\@tempdimc\else\@tempdimb=\dimexpr\@tempdimb - 1\jlreq@mol\relax\fi
          \leftmargin=\dimexpr\leftmargin + (\@tempdimc - \@tempdimb)/2\relax
          \rightmargin=\dimexpr\rightmargin + (\@tempdimc - \@tempdimb)/2\relax
          \parsep\z@ \@plus.1\jlreq@gol
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
          \jlreq@pophook@postpar
        \fi
      \else
        \unvbox\jlreq@abstractbox
      \fi
    }
  \fi
}
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
\newcommand{\descriptionlabel}[1]{\normalfont\sffamily\bfseries #1}

% enumerateとitemize
% 見出しが一つ上のレベルからどのくらいずれているかを入れる．
% （見出しは2\zhの箱に右/下詰めで入る．）
\setlength\leftmargini{2\jlreq@mol}
\setlength\leftmarginii{1\jlreq@mol}
\setlength\leftmarginiii{1\jlreq@mol}
\setlength\leftmarginiv{1\jlreq@mol}
\setlength\leftmarginv{1\jlreq@mol}
\setlength\leftmarginvi{1\jlreq@mol}

%.. 箇条書き
\jlreq@jlreqsetup@add{itemization_beforeafter_space}{\def\jlreq@itemization@beforeafter@space{#1}}
\jlreq@jlreqsetup@add{itemization_itemsep}{\def\jlreq@itemization@itemsep{#1}}
\jlreqsetup{itemization_beforeafter_space=0pt,itemization_itemsep=0pt}
% enumerate, itemize用初期化
\def\jlreq@init@list{%
  \setlength{\labelwidth}{2\jlreq@mol}%
  \setlength{\topsep}{\dimexpr\jlreq@itemization@beforeafter@space\relax}%
  \setlength{\partopsep}{0pt}%
  \setlength{\itemsep}{\dimexpr\jlreq@itemization@itemsep\relax}%
  \setlength{\parsep}{0pt}%
  \setlength{\listparindent}{\parindent}%
% itemizeは直後ベタ，enumerateは直後全角空き．
  \ifthenelse{\equal{\@currenvir}{itemize}}{%
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
  \renewcommand{\theenumiv}{\rensuji{\@arabic\c@enumiv}}
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
\if@tate
  \newcommand{\labelitemii}{○}
  \newcommand{\labelitemiii}{＊}
\else
  \newcommand{\labelitemii}{\hbox to 1\jlreq@mol{\hss\textendash\hss}}
  \newcommand{\labelitemiii}{\hbox to 1\jlreq@mol{\hss\textasteriskcentered\hss}}
\fi
\newcommand{\labelitemiv}{\hbox to 1\jlreq@mol{\hss ・\hss}}

% 引用系．3.5.2の例．
\jlreq@jlreqsetup@add{quote_indent}{\def\jlreq@quote@indent{#1}}
\jlreq@jlreqsetup@add{quote_end_indent}{\def\jlreq@quote@end@indent{#1}}
\jlreq@jlreqsetup@add{quote_fontsize}[normalsize,small,footnotesize,scriptsize,tiny,]{\jlreq@ifempty{#1}{\def\jlreq@quote@fontsize{}}{\edef\jlreq@quote@fontsize{\expandonce{\csname #1\endcsname}}}}
\jlreq@jlreqsetup@add{quote_beforeafter_space}{\def\jlreq@quote@beforeafter@space{#1}}
\jlreqsetup{quote_indent=2\zw,quote_end_indent=0pt,quote_fontsize=,quote_beforeafter_space=0pt}

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
\jlreq@saveoriginalcs{tabular}
\jlreq@saveoriginalcs{endtabular}
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
% 後で
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
\ifthenelse{\equal{\jlreq@article@type}{article}}{
  \newcommand{\tableofcontents}{%
    \jlreq@top@contents=-1\relax
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
}{% book, article
  \newcommand{\tableofcontents}{%
    \jlreq@top@contents=-1\relax
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
  \jlreq@top@contents=0
  \section*{\listfigurename}%
  \@mkboth{\listfigurename}{\listfigurename}%
  \@starttoc{lof}%
}
\newcommand*{\l@figure}{\@dottedtocline{1}{0\jlreq@gol}{2\jlreq@gol}}
\newcommand{\listoftables}{%
  \jlreq@top@contents=0
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


%. 前付，後付，付録
\ifthenelse{\equal{\jlreq@article@type}{book}}{
  \newif\if@mainmatter
  \@mainmattertrue
  \newcommand*{\frontmatter}{%
    \if@openright
      \cleardoublepage
    \else
      \clearpage
    \fi
    \@mainmatterfalse
    \let\jlreq@pagestyle@atmain\jlreq@current@pagestyle
    \SaveHeading{chapter}{\jlreq@heading@chapter@atmain}%
    \ModifyHeading{chapter}{label_format={}}%
    \pagestyle{plain}%
    \pagenumbering{roman}}
  \newcommand*{\mainmatter}{%
    \cleardoublepage
    \@mainmattertrue
    \@ifundefined{jlreq@pagestyle@atmain}{}{%
      \expandafter\pagestyle\expandafter{\jlreq@pagestyle@atmain}%
    }%
    \@ifundefined{jlreq@heading@chapter@atmain}{}{\jlreq@heading@chapter@atmain}%
    \setcounter{chapter}{0}%
    \pagenumbering{arabic}}
  \newcommand*{\backmatter}{%
    \if@openright
      \cleardoublepage
    \else
      \clearpage
    \fi
    \ifthenelse{\equal{\jlreq@article@type}{article}}{}{%book, report
      \SaveHeading{chapter}{\jlreq@heading@chapter@atmain}%
      \ModifyHeading{chapter}{label_format={}}%
    }%
    \pagestyle{plain}%
    \@mainmatterfalse
    \setcounter{chapter}{0}}
}{}
\newcommand*{\appendix}{\par
  \setcounter{section}{0}%
}

\ifthenelse{\equal{\jlreq@article@type}{article}}{
  \appto\appendix{%
    \setcounter{subsection}{0}%
    \gdef\thesection{\@Alph\c@section}%
    \if@tate
      \def\thesection{\rensuji{\Alph{section}}}%
    \else
      \def\thesection{\Alph{section}}%
    \fi
  }
}{%book, report
  \appto\appendix{%
    \setcounter{chapter}{0}%
    \if@tate
      \def\thechapter{\rensuji{\Alph{chapter}}}%
    \else
      \def\thechapter{\Alph{chapter}}%
    \fi
    \ModifyHeading{chapter}{label_format={付録\thechapter}}%
    \ifx\jlreq@current@pagestyle\@undefined\else
      \ifthenelse{\equal{\jlreq@current@pagestyle}{headings}}{%
        \def\chaptermark#1{\markboth{付録\thechapter\quad #1}{}}%
        \ModifyPageStyle{headings}{mark_format={_chapter={付録\thechapter\quad #1}}}%
      }{}%
    \fi
  }
}

%. その他諸々
%.. 縦中横
\DeclareRobustCommand*{\tatechuyoko}[1]{%
  \jlreq@ifydir{\ClassError{jlreq}{\string\tatechuyoko\space is not allowed in yoko mode}{\@ehc}}{}%
  \jlreq@lastnodechar=\lastnodechar
  \ifvmode\leavevmode\fi
  \ifnum\jlreq@lastnodechar=-1\else
    \inhibitglue
    \jlreq@calc@jfmglue{\char\jlreq@lastnodechar}{阿}%
    \ifdim\jlreq@resultskip=0pt\else\hskip\jlreq@resultskip\fi
  \fi
  \hbox{\yoko \vrule width 0pt height 0.88\zw depth 0.12\zw #1}%
  \def\jlreq@do{%
    \jlreq@isletter{\jlreq@nextchar}{%
      \jlreq@calc@jfmglue{\jlreq@nextchar}{阿}%
      \ifdim\jlreq@resultskip=0pt\else\hskip\jlreq@resultskip\fi
      \inhibitglue
    }{}%
  }%
  \futurelet\jlreq@nextchar\jlreq@do
}

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

%.. 定理環境
\jlreq@saveoriginalcs{@begintheorem}
\jlreq@saveoriginalcs{@opargbegintheorem}
\def\@begintheorem#1#2{\topsep=\dimexpr\jlreq@theorem@beforeafter@space\relax
  \trivlist\labelsep=1\jlreq@mol
  \itemindent=\dimexpr\jlreq@theorem@indent\relax
   \item[\hskip \labelsep{\sffamily\bfseries #1\ #2}]}
\def\@opargbegintheorem#1#2#3{\topsep=\dimexpr\jlreq@theorem@beforeafter@space\relax
  \trivlist\labelsep=1\jlreq@mol
  \itemindent=\dimexpr\jlreq@theorem@indent\relax
  \item[\hskip \labelsep{\sffamily\bfseries #1\ #2（#3）}]}
\AtEndOfPackageFile*{amsthm}{%
  \jlreq@saveoriginalcs{proof}%
  \jlreq@saveoriginalcs{endproof}%
  \def\proof{\@ifnextchar[{\jlreq@proof}{\jlreq@proof[\proofname]}}
  \def\jlreq@proof[#1]{\labelsep=1\jlreq@mol\jlreq@original@proof[{\normalfont\sffamily\bfseries #1\inhibitglue}\nopunct]}
  \renewcommand{\proofname}{証明}
  \jlreq@setupamsthm
  \theoremstyle{jlreq}
}
\def\jlreq@setupamsthm{
  \newtheoremstyle{jlreq}{\dimexpr\jlreq@theorem@beforeafter@space\relax}{\dimexpr\jlreq@theorem@beforeafter@space\relax}{\normalfont}{\dimexpr\jlreq@theorem@indent\relax}{\sffamily\bfseries}{}{1\jlreq@mol}{\thmname{##1}\thmnumber{\ ##2}\thmnote{ (##3)}}
}
\jlreq@jlreqsetup@add{theorem_beforeafter_space}{
  \def\jlreq@theorem@beforeafter@space{#1}
  \@ifpackageloaded{amsthm}{\jlreq@setupamsthm}{}
}
\jlreq@jlreqsetup@add{theorem_indent}{
  \def\jlreq@theorem@indent{#1}
  \@ifpackageloaded{amsthm}{\jlreq@setupamsthm}{}
}
\jlreqsetup{theorem_beforeafter_space=1\baselineskip,theorem_indent=0pt}


% デフォルト設定
\newcommand{\contentsname}{目 次}
\newcommand{\refname}{参考文献}
\newcommand{\indexname}{索 引}
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
\endinput


