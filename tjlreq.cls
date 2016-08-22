%#main jlreqtest.tex
%%#! lualatex
%%#! lualatex jlreqtest.tex ; pdftk jlreqtest.pdf multistamp onlya.pdf output out.pdf
%%#PDF out.pdf
% memo
% 欧文文字の向きについて (2.3.2.b.1)
% 割注
% タブ処理
% 振分け処理
% 表
\showboxdepth=100
\showboxbreadth=100
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tjlreq}[2016/01/01 tjlreq]
\RequirePackage{luatexja}
\RequirePackage{xkeyval}
\directlua{jlreq = {}}

%. helper
\def\jlreq@once@expand#1{\expandafter\unexpanded\expandafter{#1}}
\newdimen\jlreq@tempdima
\newdimen\jlreq@tempdimb
\newdimen\jlreq@tempdimc
% 計算結果を返すための変数
\newdimen\jlreq@resultdimen
\newbox\jlreq@resultbox

% 現在行の残りを得る．
\RequirePackage[savepos]{zref}
\newcount\jlreq@rest@linewidth@count
\jlreq@rest@linewidth@count=0

% 以下のコードはおかしい．
\newcommand*{\jlreq@current@linewidth}{%
  \dimexpr\zposx{jlreq@rest@width.pos.\the\jlreq@rest@linewidth@count} sp - \@totalleftmargin -
  \ifodd\zref@extractdefault{jlreq@rest@width.page.\the\jlreq@rest@linewidth@count}{page}{\c@page}%
    \oddsidemargin
  \else
    \evensidemargin
  \fi
  - 1in - \hoffset\relax
}
\newcommand*{\jlreq@rest@linewidth}{\dimexpr\linewidth - \jlreq@current@linewidth\relax}

% この命令以降，次にこの命令を実行する前まで\jlreq@rest@linewidthで
% この場所における残り長さが取得できる．
\newcommand*{\jlreq@savepos@for@rest@linewidth}{%
  \advance\jlreq@rest@linewidth@count by 1\relax
  \zsavepos{jlreq@rest@width.pos.\the\jlreq@rest@linewidth@count}%
  \zref@labelbyprops{jlreq@rest@width.page.\the\jlreq@rest@linewidth@count}{page}%
}

% vbox #1の最後を\jlreq@resultboxに入れる
% #1の最後の行は消える
\newcommand{\jlreq@getlastbox}[1]{%
  \setbox#1=\vbox{\unvbox#1\relax
    \unskip\unskip\unpenalty\global\setbox\jlreq@resultbox=\lastbox}%
  \ifhbox\jlreq@resultbox
    \global\setbox\jlreq@resultbox=\hbox{%
      \unhbox\jlreq@resultbox\unskip\unskip\unpenalty}%
  \else
    \global\setbox\jlreq@resultbox=\box\voidb@x
  \fi
}

%. 基本設定
% 和文文字，欧文文字の設定（とりあえずLuaTeX-jaのデフォルトのまま）
\ltjsetparameter{jacharrange={-1, +2, +3, -4, -5, +6, +7, -8}}

% kanjiskip, xkanjiskipはjfmのものを使う
\ltjsetparameter{kanjiskip=\maxdimen}
\ltjsetparameter{xkanjiskip=\maxdimen}
% 禁則処理，表1,2に従う
% 行末
% 初め括弧類
\ltjsetparameter{postbreakpenalty={`（,10000}}
\ltjsetparameter{postbreakpenalty={`〔,10000}}
\ltjsetparameter{postbreakpenalty={`［,10000}}
\ltjsetparameter{postbreakpenalty={`｛,10000}}
\ltjsetparameter{postbreakpenalty={`〈,10000}}
\ltjsetparameter{postbreakpenalty={`《,10000}}
\ltjsetparameter{postbreakpenalty={`「,10000}}
\ltjsetparameter{postbreakpenalty={`『,10000}}
\ltjsetparameter{postbreakpenalty={`【,10000}}
\ltjsetparameter{postbreakpenalty={`｟,10000}}
\ltjsetparameter{postbreakpenalty={`〘,10000}}
\ltjsetparameter{postbreakpenalty={`〖,10000}}
\ltjsetparameter{postbreakpenalty={`«,10000}}
\ltjsetparameter{postbreakpenalty={`〝,10000}}
\ltjsetparameter{postbreakpenalty={`‘,10000}}
\ltjsetparameter{postbreakpenalty={`“,10000}}
% 前置省略記号
\ltjsetparameter{postbreakpenalty={`￥,10000}}
\ltjsetparameter{postbreakpenalty={`＄,10000}}
\ltjsetparameter{postbreakpenalty={`￡,10000}}
\ltjsetparameter{postbreakpenalty={`＃,10000}}
\ltjsetparameter{postbreakpenalty={`€,10000}}
\ltjsetparameter{postbreakpenalty={`№,10000}}
% 行頭
% 終わり括弧類
\ltjsetparameter{prebreakpenalty={`）,10000}}
\ltjsetparameter{prebreakpenalty={`〕,10000}}
\ltjsetparameter{prebreakpenalty={`］,10000}}
\ltjsetparameter{prebreakpenalty={`｝,10000}}
\ltjsetparameter{prebreakpenalty={`〉,10000}}
\ltjsetparameter{prebreakpenalty={`》,10000}}
\ltjsetparameter{prebreakpenalty={`」,10000}}
\ltjsetparameter{prebreakpenalty={`』,10000}}
\ltjsetparameter{prebreakpenalty={`】,10000}}
\ltjsetparameter{prebreakpenalty={`｠,10000}}
\ltjsetparameter{prebreakpenalty={`〙,10000}}
\ltjsetparameter{prebreakpenalty={`〗,10000}}
\ltjsetparameter{prebreakpenalty={`»,10000}}
\ltjsetparameter{prebreakpenalty={`〟,10000}}
\ltjsetparameter{prebreakpenalty={`’,10000}}
\ltjsetparameter{prebreakpenalty={`”,10000}}
% ハイフン類
\ltjsetparameter{prebreakpenalty={`‐,10000}}
\ltjsetparameter{prebreakpenalty={`゠,10000}}
\ltjsetparameter{prebreakpenalty={`–,10000}}
\ltjsetparameter{prebreakpenalty={`〜,10000}}
% 区切り約物
\ltjsetparameter{prebreakpenalty={`！,10000}}
\ltjsetparameter{prebreakpenalty={`？,10000}}
\ltjsetparameter{prebreakpenalty={`‼,10000}}
\ltjsetparameter{prebreakpenalty={`⁇,10000}}
\ltjsetparameter{prebreakpenalty={`⁈,10000}}
\ltjsetparameter{prebreakpenalty={`⁉,10000}}
% 中点類
\ltjsetparameter{prebreakpenalty={`・,10000}}
\ltjsetparameter{prebreakpenalty={`：,10000}}
\ltjsetparameter{prebreakpenalty={`；,10000}}
% 句点類
\ltjsetparameter{prebreakpenalty={`。,10000}}
\ltjsetparameter{prebreakpenalty={`．,10000}}
% 読点類
\ltjsetparameter{prebreakpenalty={`、,10000}}
\ltjsetparameter{prebreakpenalty={`，,10000}}
% 繰返し記号
\ltjsetparameter{prebreakpenalty={`ヽ,10000}}
\ltjsetparameter{prebreakpenalty={`ヾ,10000}}
\ltjsetparameter{prebreakpenalty={`ゝ,10000}}
\ltjsetparameter{prebreakpenalty={`ゞ,10000}}
\ltjsetparameter{prebreakpenalty={`々,10000}}
\ltjsetparameter{prebreakpenalty={`〻,10000}}
% 長音記号
\ltjsetparameter{prebreakpenalty={`ー,10000}}
% 小書きの仮名
\ltjsetparameter{prebreakpenalty={`ぁ,10000}}
\ltjsetparameter{prebreakpenalty={`ぃ,10000}}
\ltjsetparameter{prebreakpenalty={`ぅ,10000}}
\ltjsetparameter{prebreakpenalty={`ぇ,10000}}
\ltjsetparameter{prebreakpenalty={`ぉ,10000}}
\ltjsetparameter{prebreakpenalty={`ァ,10000}}
\ltjsetparameter{prebreakpenalty={`ィ,10000}}
\ltjsetparameter{prebreakpenalty={`ゥ,10000}}
\ltjsetparameter{prebreakpenalty={`ェ,10000}}
\ltjsetparameter{prebreakpenalty={`ォ,10000}}
\ltjsetparameter{prebreakpenalty={`っ,10000}}
\ltjsetparameter{prebreakpenalty={`ゃ,10000}}
\ltjsetparameter{prebreakpenalty={`ゅ,10000}}
\ltjsetparameter{prebreakpenalty={`ょ,10000}}
\ltjsetparameter{prebreakpenalty={`ゎ,10000}}
\ltjsetparameter{prebreakpenalty={`ゕ,10000}}
\ltjsetparameter{prebreakpenalty={`ゖ,10000}}
\ltjsetparameter{prebreakpenalty={`ッ,10000}}
\ltjsetparameter{prebreakpenalty={`ャ,10000}}
\ltjsetparameter{prebreakpenalty={`ュ,10000}}
\ltjsetparameter{prebreakpenalty={`ョ,10000}}
\ltjsetparameter{prebreakpenalty={`ヮ,10000}}
\ltjsetparameter{prebreakpenalty={`ヵ,10000}}
\ltjsetparameter{prebreakpenalty={`ヶ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇰ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇱ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇲ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇳ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇴ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇵ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇶ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇷ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇸ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇹ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇺ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇻ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇼ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇽ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇾ,10000}}
\ltjsetparameter{prebreakpenalty={`ㇿ,10000}}

% xkanjiskip
% 初め括弧類（二分）
\ltjsetparameter{jaxspmode={`（,preonly}}
\ltjsetparameter{jaxspmode={`〔,preonly}}
\ltjsetparameter{jaxspmode={`［,preonly}}
\ltjsetparameter{jaxspmode={`｛,preonly}}
\ltjsetparameter{jaxspmode={`〈,preonly}}
\ltjsetparameter{jaxspmode={`《,preonly}}
\ltjsetparameter{jaxspmode={`「,preonly}}
\ltjsetparameter{jaxspmode={`『,preonly}}
\ltjsetparameter{jaxspmode={`【,preonly}}
\ltjsetparameter{jaxspmode={`｟,preonly}}
\ltjsetparameter{jaxspmode={`〘,preonly}}
\ltjsetparameter{jaxspmode={`〖,preonly}}
\ltjsetparameter{jaxspmode={`«,preonly}}
\ltjsetparameter{jaxspmode={`〝,preonly}}
\ltjsetparameter{jaxspmode={`‘,preonly}}
\ltjsetparameter{jaxspmode={`“,preonly}}
% 終わり括弧類（二分）
\ltjsetparameter{jaxspmode={`）,postonly}}
\ltjsetparameter{jaxspmode={`〕,postonly}}
\ltjsetparameter{jaxspmode={`］,postonly}}
\ltjsetparameter{jaxspmode={`｝,postonly}}
\ltjsetparameter{jaxspmode={`〉,postonly}}
\ltjsetparameter{jaxspmode={`》,postonly}}
\ltjsetparameter{jaxspmode={`」,postonly}}
\ltjsetparameter{jaxspmode={`』,postonly}}
\ltjsetparameter{jaxspmode={`】,postonly}}
\ltjsetparameter{jaxspmode={`｠,postonly}}
\ltjsetparameter{jaxspmode={`〙,postonly}}
\ltjsetparameter{jaxspmode={`〗,postonly}}
\ltjsetparameter{jaxspmode={`»,postonly}}
\ltjsetparameter{jaxspmode={`〟,postonly}}
\ltjsetparameter{jaxspmode={`’,postonly}}
\ltjsetparameter{jaxspmode={`”,postonly}}
% ハイフン類（二分）
\ltjsetparameter{jaxspmode={`‐,inhibit}}
\ltjsetparameter{jaxspmode={`゠,inhibit}}
\ltjsetparameter{jaxspmode={`–,inhibit}}
\ltjsetparameter{jaxspmode={`〜,inhibit}}
% 区切り約物
\ltjsetparameter{jaxspmode={`！,postonly}}
\ltjsetparameter{jaxspmode={`？,postonly}}
\ltjsetparameter{jaxspmode={`‼,postonly}}
\ltjsetparameter{jaxspmode={`⁇,postonly}}
\ltjsetparameter{jaxspmode={`⁈,postonly}}
\ltjsetparameter{jaxspmode={`⁉,postonly}}
% 中点類
\ltjsetparameter{jaxspmode={`・,postonly}}
\ltjsetparameter{jaxspmode={`：,postonly}}
\ltjsetparameter{jaxspmode={`；,postonly}}
% 句点類（二分）
\ltjsetparameter{jaxspmode={`。,postonly}}
\ltjsetparameter{jaxspmode={`．,postonly}}
% 読点類（二分）
\ltjsetparameter{jaxspmode={`、,postonly}}
\ltjsetparameter{jaxspmode={`，,postonly}}
% 分離禁止文字
\ltjsetparameter{jaxspmode={`—,inhibit}}
\ltjsetparameter{jaxspmode={`…,inhibit}}
\ltjsetparameter{jaxspmode={`‥,inhibit}}
\ltjsetparameter{jaxspmode={`〳,inhibit}}
\ltjsetparameter{jaxspmode={`〴,inhibit}}
\ltjsetparameter{jaxspmode={`〵,inhibit}}
% 前置省略記号
\ltjsetparameter{jaxspmode={`￥,inhibit}}
\ltjsetparameter{jaxspmode={`＄,inhibit}}
\ltjsetparameter{jaxspmode={`￡,inhibit}}
\ltjsetparameter{jaxspmode={`＃,inhibit}}
\ltjsetparameter{jaxspmode={`€,inhibit}}
\ltjsetparameter{jaxspmode={`№,inhibit}}
% 後置省略記号
\ltjsetparameter{jaxspmode={`°,inhibit}}
\ltjsetparameter{jaxspmode={`′,inhibit}}
\ltjsetparameter{jaxspmode={`″,inhibit}}
\ltjsetparameter{jaxspmode={`℃,inhibit}}
\ltjsetparameter{jaxspmode={`￠,inhibit}}
\ltjsetparameter{jaxspmode={`％,inhibit}}
\ltjsetparameter{jaxspmode={`‰,inhibit}}
\ltjsetparameter{jaxspmode={`㏋,inhibit}}
\ltjsetparameter{jaxspmode={`ℓ,inhibit}}
\ltjsetparameter{jaxspmode={`㌃,inhibit}}
\ltjsetparameter{jaxspmode={`㌍,inhibit}}
\ltjsetparameter{jaxspmode={`㌔,inhibit}}
\ltjsetparameter{jaxspmode={`㌘,inhibit}}
\ltjsetparameter{jaxspmode={`㌢,inhibit}}
\ltjsetparameter{jaxspmode={`㌣,inhibit}}
\ltjsetparameter{jaxspmode={`㌦,inhibit}}
\ltjsetparameter{jaxspmode={`㌧,inhibit}}
\ltjsetparameter{jaxspmode={`㌫,inhibit}}
\ltjsetparameter{jaxspmode={`㌶,inhibit}}
\ltjsetparameter{jaxspmode={`㌻,inhibit}}
\ltjsetparameter{jaxspmode={`㍉,inhibit}}
\ltjsetparameter{jaxspmode={`㍊,inhibit}}
\ltjsetparameter{jaxspmode={`㍍,inhibit}}
\ltjsetparameter{jaxspmode={`㍑,inhibit}}
\ltjsetparameter{jaxspmode={`㍗,inhibit}}
\ltjsetparameter{jaxspmode={`㎎,inhibit}}
\ltjsetparameter{jaxspmode={`㎏,inhibit}}
\ltjsetparameter{jaxspmode={`㎜,inhibit}}
\ltjsetparameter{jaxspmode={`㎝,inhibit}}
\ltjsetparameter{jaxspmode={`㎞,inhibit}}
\ltjsetparameter{jaxspmode={`㎡,inhibit}}
\ltjsetparameter{jaxspmode={`㏄,inhibit}}
% 分割禁止（分離禁止文字は特定の並びで分割禁止だが，とりあえず一括で禁止しておく．）
\ltjsetparameter{prebreakpenalty={`—,10000}}
\ltjsetparameter{prebreakpenalty={`…,10000}}
\ltjsetparameter{prebreakpenalty={`‥,10000}}
% ￥100とか70％とか……

%. オプションの定義
\newcommand*{\jlreq@checkempty}[2]{\ifx#2\relax\relax\else\ClassError{jlreq}{The option #1 should have no value}{\@ehc}\fi}
% 引数無しの\DeclareOptionX
\newcommand*{\jlreq@DeclareOption}[2]{%
  \DeclareOptionX{#1}{\jlreq@checkempty{#1}{##1}#2}
}
%.. 基本版面．まずは紙サイズ．
\jlreq@DeclareOption{a3paper}{%
  \setlength\paperheight {420mm}%
  \setlength\paperwidth  {297mm}}
\jlreq@DeclareOption{a4paper}{%
  \setlength\paperheight {297mm}%
  \setlength\paperwidth  {210mm}}
\jlreq@DeclareOption{a5paper}{%
  \setlength\paperheight {210mm}%
  \setlength\paperwidth  {148mm}}
\jlreq@DeclareOption{a6paper}{%
  \setlength\paperheight {148mm}%
  \setlength\paperwidth  {105mm}}
\jlreq@DeclareOption{b4paper}{%
  \setlength\paperheight {364mm}%
  \setlength\paperwidth  {257mm}}
\jlreq@DeclareOption{b5paper}{%
  \setlength\paperheight {257mm}%
  \setlength\paperwidth  {182mm}}
\jlreq@DeclareOption{b6paper}{%
  \setlength\paperheight {182mm}%
  \setlength\paperwidth  {128mm}}
\jlreq@DeclareOption{a4j}{%
  \setlength\paperheight {297mm}%
  \setlength\paperwidth  {210mm}}
\jlreq@DeclareOption{a5j}{%
  \setlength\paperheight {210mm}%
  \setlength\paperwidth  {148mm}}
\jlreq@DeclareOption{b4j}{%
  \setlength\paperheight {364mm}%
  \setlength\paperwidth  {257mm}}
\jlreq@DeclareOption{b5j}{%
  \setlength\paperheight {257mm}%
  \setlength\paperwidth  {182mm}}
\jlreq@DeclareOption{a4var}{%
  \setlength\paperheight {283mm}%
  \setlength\paperwidth  {210mm}}
\jlreq@DeclareOption{b5var}{%
  \setlength\paperheight {230mm}%
  \setlength\paperwidth  {182mm}}
\jlreq@DeclareOption{letterpaper}{%
  \setlength\paperheight {11in}%
  \setlength\paperwidth  {8.5in}}
\jlreq@DeclareOption{legalpaper}{%
  \setlength\paperheight {14in}%
  \setlength\paperwidth  {8.5in}}
\jlreq@DeclareOption{executivepaper}{%
  \setlength\paperheight {10.5in}%
  \setlength\paperwidth  {7.25in}}

% フォントサイズ，行長，1ページあたりの行数で基本版面のサイズを決める（2.4.1.a）
\newdimen\jlreq@fontsize
\jlreq@fontsize=10pt
\DeclareOptionX{fontsize}{%
  \@tempdima=2.5mm\relax
  \setlength{\jlreq@fontsize}{%
    \dimexpr\directlua{
      local yen = string.char(92)
      local s = [[#1]]
      s = s:gsub("Q"," * 2.5mm")
      tex.print(s)
    }\relax
  }%
}

% 行の長さ
\newcommand*{\jlreq@line@length}{}
\DeclareOptionX{line_length}{\renewcommand*{\jlreq@line@length}{#1}}
% 1ページあたりの行数
\newcommand*{\jlreq@number@of@lines}{}
\DeclareOptionX{number_of_lines}{\renewcommand*{\jlreq@number@of@lines}{#1}}

% 地の空き量，のどの空き量で配置位置を決める（2.4.1.b）省略されたら中央配置．
% 地
\newcommand*{\jlreq@foot@space}{}
\define@key{tjlreq.cls}{foot_space}{\renewcommand*{\jlreq@foot@space}{#1}}
% のど
\newcommand*{\jlreq@nodo}{}
\define@key{tjlreq.cls}{gutter}{\renewcommand*{\jlreq@nodo}{#1}}

% 行送り，指定無しの場合は文字サイズの1.7倍とする．（1.5から2倍が好ましい：2.4.2.d 注3）
\newdimen\jlreq@baselineskip
\newcommand*{\jlreq@option@baselineskip}{}
\DeclareOptionX{baselineskip}{\def\jlreq@option@baselineskip{#1}}
\DeclareOptionX{linegap}{\def\jlreq@option@baselineskip{1zh + #1}}

%.. 組み方系
% 行頭に括弧が来たときの配置：3.1.5
% 段落頭指定_折り返し行頭指定 で与える．
\newcommand*{\jlreq@open@bracket@pos}{zenkaku_tentsuki}
\define@choicekey{tjlreq.cls}{open_bracket_pos}{zenkaku_tentsuki,zenkakunibu_nibu,nibu_tentsuki}{\renewcommand{\jlreq@open@bracket@pos}{#1}}
% ぶら下げ組みをするか：3.8.2 注1
\newif\ifjlreq@burasage
\jlreq@DeclareOption{hanging_punctuation}{\jlreq@burasagetrue}

%.. 脚注
% 合印の場所（4.2.3）行間に入れるか否か
\newcommand*{\jlreq@referencemark}{inline}
\define@choicekey{tjlreq.cls}{reference_mark}{inline,interlinear}{\renewcommand*{\jlreq@referencemark}{#1}}
% 脚注の字下げ，一行目を下げるならばone，二行目以降ならばtwo．ちょっと酷いので後で考える．
\newcommand*{\jlreq@footnotetext@indent}{one}
\define@choicekey{tjlreq.cls}{footnotetext_indent}{one,two}{\renewcommand*{\jlreq@footnotetext@indent}{#1}}

\newif\if@restonecol \@restonecolfalse
\newif\if@titlepage \@titlepagefalse
\newif\if@landscape \@landscapefalse
\jlreq@DeclareOption{landscape}{\@landscapetrue}
\jlreq@DeclareOption{tombo}{%
  \tombowtrue \tombowdatefalse
  \setlength{\@tombowwidth}{.1\p@}%
  \maketombowbox}
\jlreq@DeclareOption{mentuke}{%
  \tombowtrue \tombowdatefalse
  \setlength{\@tombowwidth}{\z@}%
  \maketombowbox}
\jlreq@DeclareOption{tate}{%
  \AtBeginDocument{\tate\message{《縦組モード》}\adjustbaseline}%
}
\jlreq@DeclareOption{oneside}{\@twosidefalse \@mparswitchfalse}
\jlreq@DeclareOption{twoside}{\@twosidetrue \@mparswitchtrue}
\jlreq@DeclareOption{vartwoside}{\@twosidetrue \@mparswitchfalse}
\jlreq@DeclareOption{onecolumn}{\@twocolumnfalse}
\jlreq@DeclareOption{twocolumn}{\@twocolumntrue}
\jlreq@DeclareOption{titlepage}{\@titlepagetrue}
\jlreq@DeclareOption{notitlepage}{\@titlepagefalse}
\jlreq@DeclareOption{draft}{\setlength\overfullrule{5pt}}
\jlreq@DeclareOption{final}{\setlength\overfullrule{0pt}}

\ExecuteOptionsX{a4paper,fontsize=9pt,twoside,onecolumn,final,tate}
\ProcessOptionsX\relax

%. オプション処理
% この値は後でjfm-jlreq内で読む
\directlua{jlreq.open_bracket_pos = [[\jlreq@open@bracket@pos]]}
\ifjlreq@burasage\directlua{jlreq.burasage = true}
\else\directlua{jlreq.burasage = false}\fi

% landscapeの場合縦横をひっくり返す
\if@landscape
  \setlength\@tempdima  {\paperheight}
  \setlength\paperheight{\paperwidth}
  \setlength\paperwidth {\@tempdima}
\fi

% スケーリング用
\newdimen\jlreq@mpt
\jlreq@mpt=\dimexpr\jlreq@fontsize/10\relax
% \baselineskipの計算
\ifx\jlreq@option@baselineskip\@empty
  \setlength{\jlreq@baselineskip}{\dimexpr 17\jlreq@fontsize/10\relax}%
\else
  \setlength{\jlreq@baselineskip}{%
    \dimexpr\directlua{
      local yen = string.char(92)
      local s = [[\jlreq@option@baselineskip]]
      s = s:gsub("Q"," * 2.5mm"):gsub("z[hw]",yen .. "jlreq@fontsize")
      tex.print(s)
    }\relax
  }%
\fi
\ifdim\jlreq@fontsize>\jlreq@baselineskip
  \ClassError{tjlreq}{The baselineskip is less than fontsize}{\@ehc}%
\fi

% \pdfpagewidthとか設定
\newlength{\stockwidth}
\newlength{\stockheight}
\setlength{\stockwidth}{\paperwidth}
\setlength{\stockheight}{\paperheight}
\iftombow
  \advance \stockwidth 2in
  \advance \stockheight 2in
\fi
\setlength{\pagewidth}{\stockwidth}
\setlength{\pageheight}{\stockheight}


%. 和文フォント
\RequirePackage{luatexja-adjust}
\ltjenableadjust[lineend=extended,priority=true]
\directlua{
  luatexja.adjust.make_priority_table(1,0,-1,5)
  luatexja.adjust.make_priority_table(2,0,-1,5)
}

\expandafter\let\csname JT3/mc/m/n/10\endcsname\relax
\DeclareFontShape{JT3}{mc}{m}{n}{<->\ltj@stdmcfont:jfm=jlreqv;script=latn;-kern}{}
\DeclareFontShape{JT3}{gt}{m}{n}{<->\ltj@stdgtfont:jfm=jlreqv;script=latn;-kern}{}
\DeclareFontShape{JT3}{mc}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{JT3}{gt}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{JT3}{mc}{m}{it}{<->ssub*mc/m/n}{}
\DeclareFontShape{JT3}{mc}{m}{sl}{<->ssub*mc/m/n}{}
\DeclareFontShape{JT3}{mc}{m}{sc}{<->ssub*mc/m/n}{}
\DeclareFontShape{JT3}{gt}{m}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{JT3}{gt}{m}{sl}{<->ssub*gt/m/n}{}
\DeclareFontShape{JT3}{mc}{bx}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{JT3}{mc}{bx}{sl}{<->ssub*gt/m/n}{}

\emergencystretch 3\zw

\renewcommand{\normalsize}{%
  \@setfontsize\normalsize{\jlreq@fontsize}{\jlreq@baselineskip}%
  \abovedisplayskip 1.1\jlreq@fontsize \@plus .3\jlreq@fontsize \@minus .4\jlreq@fontsize
  \abovedisplayshortskip \z@ \@plus .3\jlreq@fontsize
  \belowdisplayskip .9\jlreq@fontsize \@plus.3\jlreq@fontsize \@minus.4\jlreq@fontsize
  \belowdisplayshortskip \belowdisplayskip
  \let\@listi\@listI}

\kanjiencoding{JT3}
\mcfamily\selectfont\normalsize
\setbox0\hbox{　} % 全角スペース
\setlength\Cht{\ht0}
\setlength\Cdp{\dp0}
\setlength\Cwd{\wd0}
\setlength\Cvs{\baselineskip}
\setlength\Chs{\wd0}
\tate % ここで発行しておく

% 4.1.3.a
% 2.5.2 \baselineskipは一定の方がよい？
\newcommand{\footnotesize}{%
  \@setfontsize\footnotesize{.8\jlreq@fontsize}{\dimexpr 95\jlreq@baselineskip/170\relax}% 脚注文字サイズの二分より少し小さい値を行間に: 4.2.5.e
  \abovedisplayskip 6\jlreq@mpt \@plus2\jlreq@mpt \@minus4\jlreq@mpt
  \abovedisplayshortskip \z@ \@plus\jlreq@mpt
  \belowdisplayshortskip 3\jlreq@mpt \@plus\jlreq@mpt \@minus2\jlreq@mpt
  \def\@listi{\leftmargin\leftmargini
    \topsep 3\jlreq@mpt \@plus\jlreq@mpt \@minus\jlreq@mpt
    \parsep 2\jlreq@mpt \@plus\jlreq@mpt \@minus\jlreq@mpt
    \itemsep \parsep}%
  \belowdisplayskip \abovedisplayskip}
% tsize10.cloの引数を，そのまま\jlreq@fontsize/\jlreq@baselineskipでスケーリングしているだけ．
\newcommand{\small}{%
  \@setfontsize\small{.9\jlreq@fontsize}{\dimexpr 11\jlreq@baselineskip/17\relax}%
  \abovedisplayskip 8.5\jlreq@mpt \@plus3\jlreq@mpt \@minus4\jlreq@mpt
  \abovedisplayshortskip \z@ \@plus2\jlreq@mpt
  \belowdisplayshortskip 4\jlreq@mpt \@plus2\jlreq@mpt \@minus2\jlreq@mpt
  \def\@listi{\leftmargin\leftmargini
    \topsep 4\jlreq@mpt \@plus2\jlreq@mpt \@minus2\jlreq@mpt
    \parsep 2\jlreq@mpt \@plus\jlreq@mpt \@minus\jlreq@mpt
    \itemsep \parsep}%
  \belowdisplayskip \abovedisplayskip}
\newcommand{\scriptsize}{\@setfontsize\scriptsize{\dimexpr 7\jlreq@fontsize/10\relax}{\dimexpr 8\jlreq@baselineskip/17\relax}}
\newcommand{\tiny}{\@setfontsize\tiny{\dimexpr 5\jlreq@fontsize/10\relax}{\dimexpr 6\jlreq@baselineskip/17\relax}}
\newcommand{\large}{\@setfontsize\large{\dimexpr12\jlreq@fontsize/10\relax}{\jlreq@baselineskip}}
\newcommand{\Large}{\@setfontsize\Large{\dimexpr14\jlreq@fontsize/10\relax}{\dimexpr 21\jlreq@baselineskip/17\relax}}
\newcommand{\LARGE}{\@setfontsize\LARGE{\dimexpr17\jlreq@fontsize/10\relax}{\dimexpr 25\jlreq@baselineskip/17\relax}}
\newcommand{\huge}{\@setfontsize\huge{2\jlreq@fontsize}{\dimexpr 28\jlreq@baselineskip/17\relax}}
\newcommand{\Huge}{\@setfontsize\Huge{\dimexpr 25\jlreq@fontsize/10\relax}{\dimexpr 33\jlreq@baselineskip/17\relax}}

\RequirePackage{lltjext}
\renewcommand*{\@Kanji}[1]{\expandafter\kansuji\number #1\relax} % \relax追加
\rensujiskip=0\zh plus 0.25\zh minus 0\zh

% このあたりはtarticleと同じ
\setlength\lineskip{1\jlreq@mpt}
\setlength\normallineskip{1\jlreq@mpt}
%\setlength\lineskiplimit{1\jlreq@mpt}% jsarticleではこう
%\setlength\normallineskiplimit{1\jlreq@mpt}% jsarticleではこう
\renewcommand{\baselinestretch}{}
\setlength\parskip{0\p@ \@plus \p@}
\setlength\parindent{1\zh}
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

%. ページレイアウト
\def\jlreq@expand@speciallength#1{%
  % zhやzwを\zhや\zwにする．
  \dimexpr\directlua{
    local yen = string.char(92)
    local s = [[#1]]
    s = s:gsub("zw",yen .. "zw"):gsub("zh",yen .. "zh")
    tex.print(s)
  }\relax
}

% デフォルト値は縦が0.768倍，横が0.727倍（JISX4051のA5の例から換算……）．
% 縦 (\textwidth)
\ifx\jlreq@line@length\@empty
  \setlength{\textwidth}{0.768\paperheight}
  \divide\textwidth\zh
\else
  \setlength{\textwidth}{\jlreq@expand@speciallength{\jlreq@line@length}}
  \divide\textwidth\zh
  % 縦ならば一行52文字以下，横ならば40文字以下が望ましい．2.4.2.c 注2
%  \ifnum\number\textwidth>52
%    \ClassWarningNoLine{tjlreq}{JLREQ recommends that the length of the line is less than or equal to that of the 50 characters. The given length is greater than that}
%  \fi
\fi
\multiply\textwidth\zh

% 横 (\textheight)
\ifx\jlreq@number@of@lines\@empty
  \setlength{\textheight}{0.727\paperwidth}
\else
  \setlength{\textwidth}{\jlreq@expand@speciallength{\jlreq@number@of@lines\baselineskip}}
\fi
\divide\textheight\baselineskip \multiply\textheight\baselineskip

\setlength{\topskip}{1\zw} % フォントサイズと一致させる
% ヘッダ：本文から1文字分離す．ヘッダの高さはjsarticleに習ってその二倍
\setlength{\headsep}{1\zh}
\setlength{\headheight}{2\zh}
% 横
\ifx\jlreq@nodo\@empty
  % 中央配置
  \setlength{\oddsidemargin}{\paperwidth}
  \addtolength{\oddsidemargin}{-\textheight}
  \setlength{\oddsidemargin}{.5\oddsidemargin}
  \addtolength{\oddsidemargin}{-1in}
  \setlength{\evensidemargin}{\oddsidemargin}
\else
  \setlength{\oddsidemargin}{\jlreq@expand@speciallength{\jlreq@nodo}}
  \setlength{\evensidemargin}{\dimexpr\paperwidth - \textheight - \oddsidemargin\relax}
  \addtolength{\oddsidemargin}{-1in}
  \addtolength{\evensidemargin}{-1in}
\fi
% 縦
\setlength{\topmargin}{\paperheight}
\addtolength{\topmargin}{-\textwidth}
\ifx\jlreq@foot@space\@empty
  % 中央配置
  \setlength{\topmargin}{0.5\topmargin}
\else
  \addtolength{\topmargin}{-\jlreq@expand@speciallength{\jlreq@foot@space}}
\fi
\addtolength{\topmargin}{-\headsep}
\addtolength{\topmargin}{-\headheight}
\addtolength{\topmargin}{-1in}
% 下：本文から一文字分離すつもり
\setlength{\footskip}{2\zh}
% \maxdepth + \topskip = フォントサイズ×1.5
\setlength{\maxdepth}{15\jlreq@mpt}
\addtolength{\maxdepth}{-\topskip}
% columnsep/columnseprule 二段組み用
\setlength{\columnsep}{2\zh} % フォントサイズ×2
\setlength{\columnseprule}{0\jlreq@mpt}
% 傍注はこれではうまく行かないはず．
\setlength{\marginparwidth}{0.333\textwidth} % 根拠無しの1/3：15--20文字らしい
\setlength{\marginparsep}{20\jlreq@mpt} % フォントサイズ×2（4.2.7：特に問題に～e）
{%
  \footnotesize\@tempdima=1\zw
  \global\divide\marginparwidth\@tempdima \global\multiply\marginparwidth\@tempdima
  \global\setlength{\marginparpush}{.5\@tempdima} % 同上：c
}
% 脚注関連（縦書きの時は傍注，4.2.5）
{\footnotesize\global\setlength{\footnotesep}{.7\baselineskip}} % 何でかわからん……
% 罫線の前は行間分，最大＋文字サイズ分伸びる（4.2.5.g）
\setlength{\skip\footins}{\dimexpr\baselineskip - 1\zw\relax plus 1\zw}
% 脚注の前の罫線は表罫で，長さは行長の1/3位（4.2.6.f）
\renewcommand{\footnoterule}{\hrule width .333\textwidth height \jlreq@omotekeiwidth}
% インデントの計算：脚注の長さが文字の整数倍になるように字下げする（4.2.5.b）
{
  \@tempdima=\textwidth
  \footnotesize
  \divide\@tempdima\zh \multiply\@tempdima\zh
  \global\jlreq@footnoteindent=\dimexpr\textwidth - \@tempdima\relax
}
% 二行目以降の字下げを全角空きにする方にしておく．（オプションで制御できるべき）：4.2.5.d
\def\@tempa{one}
\ifx\jlreq@footnotetext@indent\@tempa
  \newcommand\@makefntext[1]{\parindent 1\zh
    \addtolength{\leftskip}{\dimexpr \jlreq@footnoteindent + 1\zh\relax} %全体をインデント+1文字分下げる
    \noindent\llap{\@makefnmark}\hskip 1\zh#1}% 見出し出力と一文字分の空き
\else
  \newcommand\@makefntext[1]{\parindent 1\zh
    \addtolength{\leftskip}{\jlreq@footnoteindent} %全体をインデント
    \leavevmode\@makefnmark\hskip 1\zh#1}% 見出し出力と一文字分の空き
\fi
% 合印：4.2.3
% 文字サイズは6ポイントくらい（4.2.3.a）
\def\@tempa{inline}
\ifx\jlreq@referencemark\@tempa
  \renewcommand{\@footnotemark}{%
    \leavevmode
    \ifhmode\edef\@x@sf{\the\spacefactor}\nobreak\fi
    \ifnum\ltjgetparameter{direction}=3\relax
      \hbox{\@textsuperscript{\normalfont\@thefnmark}}%
    \else
      \setbox\@tempboxa=\hbox{\scriptsize\@makefnmark}%
      \inhibitglue\raise\dimexpr.5\zw - (\ht\@tempboxa + \dp\@tempboxa)/2\relax\box\@tempboxa\inhibitglue
    \fi
    \ifhmode\spacefactor\@x@sf\fi
    \relax}
\else
  \renewcommand{\@footnotemark}{%
    \leavevmode
    \ifhmode\edef\@x@sf{\the\spacefactor}\nobreak\fi
    \setbox\@tempboxa=\hbox{\scriptsize\@makefnmark}%
    % 行頭に来たときに頭を天にそろえる処理．
    \jlreq@savepos@for@rest@linewidth
    \ifdim\jlreq@current@linewidth<\wd\@tempboxa
      \@tempdima=\jlreq@current@linewidth
    \else
      \@tempdima=\wd\@tempboxa
    \fi
    \hbox to\z@{\hskip-\@tempdima\raise\dimexpr.5\zw + (\ht\@tempboxa + \dp\@tempboxa)/2\relax\box\@tempboxa}%
    \ifhmode\spacefactor\@x@sf\fi
    \relax}
\fi
% 図4.61のようにする
% 文字サイズは要検討（cf. 4.2.3.a）
\renewcommand{\@makefnmark}{\hbox{（\@thefnmark）}}
\renewcommand{\thefootnote}{\rensuji{\@arabic\c@footnote}}

%. ページスタイル．
% ページ番号は下の端．左右が本文と揃わない……
% 他のも要調整
\def\ps@plain{\let\@mkboth\@gobbletwo
  \let\ps@jpl@in\ps@plain
  \let\@oddhead\@empty
  \let\@evenhead\@empty
  \def\@oddfoot{\kern 1\zw\thepage\hfil}%
  \def\@evenfoot{\hfil\thepage\kern 1\zw}}
% ページ番号は上の端．
\def\ps@headings{\let\ps@jpl@in\ps@headnombre
  \let\@oddfoot\@empty
  \def\@oddhead{\thepage\quad\rightmark}%
  \def\@evenhead{\hfil\rightmark\quad\thepage}%
  \let\@mkboth\markboth
\def\sectionmark##1{\markright{%
  \ifnum \c@secnumdepth >\m@ne \thesection.\hskip1\zw\fi
  ##1}}%
}
\def\ps@myheadings{\let\ps@jpl@in\ps@plain%
  \let\@oddfoot\@empty\let\@evenfoot\@empty
  \def\@evenhead{\thepage\quad{\leftmark}\hfil}%
  \def\@oddhead{\hfil\thepage\quad\rightmark}%
  \let\@mkboth\@gobbletwo
  \let\sectionmark\@gobble
  \let\subsectionmark\@gobble
}

%. 見出し関係 (4.1)
\newcommand{\headfont}{\gtfamily\sffamily}
\setcounter{secnumdepth}{3}
\newcounter{part}
\newcounter{section}
\newcounter{subsection}[section]
\newcounter{subsubsection}[subsection]
\newcounter{paragraph}[subsubsection]
\newcounter{subparagraph}[paragraph]
\renewcommand{\thepart}{\Kanji{part}}
\renewcommand{\thesection}{\rensuji{\@arabic\c@section}}
\renewcommand{\thesubsection}{\rensuji{\@alph\c@subsection}}
\renewcommand{\thesubsubsection}{%
  \rensuji{\@arabic\c@subsubsection}}
\renewcommand{\theparagraph}{%
  (\rensuji{\@arabic\c@paragraph})}
\renewcommand{\thesubparagraph}{%
  (\rensuji{\@arabic\c@subparagraph})}

\renewcommand*{\@seccntformat}[1]{\csname the#1\endcsname\hspace{1\jlreq@fontsize}}
\newcommand*{\jlreq@absdimenmodoki}[1]{\ifdim#1=0pt 0.001pt\else\ifnum#1<0pt -#1\else#1\fi\fi}
% 別行見出し
% \DeclareBlockHeading{命令名}{レベル}{lines=何行取りか,before_space=前のスペース,after_space=後ろのスペース,indent=インデント,font=書式変更命令}
% before/after_spaceが両方定義されていた場合はlinesは無視される．
% TODO: 改ページするかなど，4.1.4
\newcommand*{\DeclareBlockHeading}[3]{%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \begingroup
    \def\jlreq@lines{1}%
    \define@key{jlreq@key}{lines}{\def\jlreq@lines{##1}}%
    \def\jlreq@before@space{}%
    \define@key{jlreq@key}{before_space}{\def\jlreq@before@space{##1}}%
    \def\jlreq@after@space{}%
    \define@key{jlreq@key}{after_space}{\def\jlreq@after@space{##1}}%
    \def\jlreq@fontcommand{\normalsize}%
    \define@key{jlreq@key}{font}{\def\jlreq@fontcommand{##1}}%
    \def\jlreq@indent{0}%
    \define@key{jlreq@key}{indent}{\def\jlreq@indent{##1}}%
    \setkeys{jlreq@key}{#3}%
    % \jlreq@linesを長さに直す
    \edef\jlreq@lines{\jlreq@once@expand{\jlreq@lines}\baselineskip}%
    % after@spaceとbefore@spaceが空ならセットする．
    \ifx\jlreq@after@space\@empty
      \ifx\jlreq@before@space\@empty
        \edef\jlreq@before@space{(\jlreq@once@expand{\jlreq@lines} - \baselineskip)/2}%
      \fi
      \edef\jlreq@after@space{\jlreq@once@expand{\jlreq@lines} - \jlreq@once@expand{\jlreq@before@space} - \baselineskip}%
    \else
      \ifx\jlreq@before@space\@empty
        \edef\jlreq@before@space{\jlreq@once@expand{\jlreq@lines} - \jlreq@once@expand{\jlreq@after@space} - \baselineskip}%
      \fi
    \fi
    \global\edef\@tempa{{\unexpanded{#1}}{\unexpanded{#2}}{\jlreq@once@expand{\jlreq@indent}\jlreq@fontsize}{\dimexpr\jlreq@once@expand{\jlreq@before@space}\relax}{\noexpand\jlreq@absdimenmodoki{\dimexpr\jlreq@once@expand{\jlreq@after@space}\relax}}{\jlreq@tempdima=\baselineskip\noexpand\reset@font\jlreq@once@expand{\jlreq@fontcommand}\baselineskip=\jlreq@tempdima}}
  \endgroup
  \expandafter\edef\csname #1\endcsname{\noexpand\@startsection\jlreq@once@expand{\@tempa}}%
}
\newcommand*{\NewBlockHeading}[3]{%
  \expandafter\@ifdefinable\csname #1\endcsname{\DeclareBlockHeading{#1}{#2}{#3}}%
}
\newcommand*{\RenewBlockHeading}[3]{%
  \@ifundefined{#1}{\@latex@error{\expandafter\string\csname#1\endcsname\space undefined}\@ehc}{\DeclareBlockHeading{#1}{#2}{#3}}%
}
\newcommand*{\ProvideBlockHeading}[3]{%
  \@ifundefined{#1}{\DeclareBlockHeading{#1}{#2}{#3}}{}%
}

% 同行見出し
% \DeclareRuninHeading{命令名}{レベル}{書体変更命令}
\newcommand*{\DeclareRuninHeading}[3]{%
  \@ifundefined{c@#1}{\newcounter{#1}}{}%
  \@ifundefined{#1mark}{\expandafter\let\csname #1mark\endcsname\@gobble}{}%
  \begingroup
    \def\jlreq@fontcommand{\normalfont\normalsize}%
    \define@key{jlreq@key}{font}{\def\jlreq@fontcommand{##1}}%
    \def\jlreq@indent{1}%
    \define@key{jlreq@key}{indent}{\def\jlreq@indent{##1}}%
    \setkeys{jlreq@key}{#3}%
    \global\edef\@tempa{{\unexpanded{#1}}{\unexpanded{#2}}{\jlreq@once@expand{\jlreq@indent}\jlreq@fontsize}{0pt}{-1\jlreq@fontsize}{\jlreq@tempdima=\baselineskip\noexpand\reset@font\jlreq@once@expand{\jlreq@fontcommand}\baselineskip=\jlreq@tempdima}}%
  \endgroup
  \expandafter\edef\csname #1\endcsname{\noexpand\@startsection\jlreq@once@expand{\@tempa}}%
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

% 窓見出し
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
  \setbox\@tempboxa=\hbox{#1#6}%
  \@tempdima=\wd\@tempboxa
  \ifdim\@tempdima>#5\def\jlreq@CutinHeading@linecount{3}%
  \else\ifdim\@tempdima>#4\def\jlreq@CutinHeading@linecount{2}%
  \else\def\jlreq@CutinHeading@linecount{1}\fi\fi
  \divide\@tempdima by \jlreq@CutinHeading@linecount
  \ifnum\jlreq@CutinHeading@linecount=1\relax
    \setbox\jlreq@resultbox=\vbox{\parindent=0pt\rightskip=0pt\leftskip=0pt\hbox{#1#6}}%
    \def\jlreq@CutinHeading@linecount{2}%
  \else
    \jlreq@warichu@determinelength{#6}{#1}{}{\jlreq@CutinHeading@linecount}{\jlreq@CutinHeading@linecount}{\@tempdima}{\linewidth}%
    \def\jlreq@CutinHeading@linecount{3}%
  \fi
  \setbox\@tempboxa=\vtop to \dimexpr\jlreq@CutinHeading@linecount\baselineskip\relax{\vskip 0pt plus 1fill minus 1fill \box\jlreq@resultbox\vskip 0pt plus 1fill minus 1fill}%
  \ht\@tempboxa=\Cht
  \dp\@tempboxa=\Cdp
  \@tempdima=\wd\@tempboxa
  \hangindent=\dimexpr#2\zh + \@tempdima + #3\relax\hangafter=-\jlreq@CutinHeading@linecount
  \jlreq@hangindent=\hangindent\jlreq@wraplinecount=\hangafter
  \hspace*{#2\zh}%
  \kern-\dimexpr\@tempdima + #3 + \parindent\relax
  \box\@tempboxa
  \hspace*{#3}%
  \let\jlreq@original@par=\par
  \def\par{%
    \jlreq@original@par
    \ifnum\jlreq@wraplinecount>1\relax
      \hangindent=\jlreq@hangindent\hangafter=\jlreq@wraplinecount\advance\jlreq@wraplinecount by -1\relax
    \else\ifnum\jlreq@wraplinecount<-1\relax
      \hangindent=\jlreq@hangindent\hangafter=\jlreq@wraplinecount\advance\jlreq@wraplinecount by 1\relax
    \else
      \jlreq@wraplinecount=1\jlreq@hangindent=0pt\relax
      \let\par=\jlreq@original@par
    \fi\fi
  }%
}

\newcommand*{\DeclareCutinHeading}[3]{%
  \begingroup
    \def\jlreq@fontcommand{\bfseries\gtfamily}%
    \define@key{jlreq@key}{font}{\def\jlreq@fontcommand{##1}}%
    \def\jlreq@onelinemax{6\jlreq@fontsize}%
    \define@key{jlreq@key}{onelinemax}{\def\jlreq@onelinemax{##1}}%
    \def\jlreq@twolinemax{20\jlreq@fontsize}%
    \define@key{jlreq@key}{twolinemax}{\def\jlreq@twolinemax{##1}}%
    \def\jlreq@indent{0}%
    \define@key{jlreq@key}{indent}{\def\jlreq@indent{##1}}%
    \def\jlreq@afterindent{1\zh}%
    \define@key{jlreq@key}{afterindent}{\def\jlreq@afterindent{##1}}%
    \setkeys*{jlreq@key}{#3}%
    \global\edef\@tempa{{#1}{\jlreq@once@expand{\jlreq@fontcommand}}{\jlreq@once@expand{\jlreq@indent}}{\jlreq@once@expand{\jlreq@afterindent}}{\jlreq@once@expand{\jlreq@onelinemax}}{\jlreq@once@expand{\jlreq@twolinemax}}}
  \endgroup
  \expandafter\edef\csname #1\endcsname{\noexpand\jlreq@CutinHeading@start\jlreq@once@expand{\@tempa}}
}

\NewBlockHeading{part}{0}{font={\LARGE\headfont},indent=4,lines=4}
\NewBlockHeading{section}{1}{font={\Large\headfont},indent=6,lines=3}
\NewBlockHeading{subsection}{2}{font={\large\headfont},indent=8,lines=2}
\NewBlockHeading{subsubsection}{3}{font={\normalsize\headfont},indent=10,lines=2,before_space=\baselineskip}
\NewRuninHeading{paragraph}{4}{font={\normalsize\bfseries}}
\NewRuninHeading{subparagraph}{5}{font={\normalsize\headfont}}

\newcommand{\appendix}{\par
  \setcounter{section}{0}%
  \setcounter{subsection}{0}%
  \renewcommand{\thesection}{\rensuji{\@Alph\c@section}}}

% フロート関連
% 4.3.3.d
\setlength{\floatsep}{1\zh plus 1\zh}
\setlength{\textfloatsep}{1\zw plus \baselineskip}
\setlength{\intextsep}{\floatsep}
\setlength{\dblfloatsep}{\floatsep}
\setlength{\dbltextfloatsep}{\textfloatsep}
% 残りはデフォルトにしておく．

% 4.3.1 注4
\newcommand{\@makecaption}[2]{{%
  \reset@font\small\headfont
  \vskip\abovecaptionskip
  \ifnum\ltjgetparameter{direction}=3 \sbox\@tempboxa{#1\hskip1\zw#2}%
    \else\sbox\@tempboxa{#1: #2}%
  \fi
  \ifdim \wd\@tempboxa >\hsize
    \ifnum\ltjgetparameter{direction}=3  #1\hskip1\zw#2\relax\par
    \else #1: #2\relax\par\fi
  \else
    \global \@minipagefalse
    \hbox to\hsize{\hfil\box\@tempboxa\hfil}%
  \fi
  \vskip\belowcaptionskip}}
% この値はjsclassesから
\newlength\abovecaptionskip
\newlength\belowcaptionskip
\setlength\abovecaptionskip{5\jlreq@mpt}
\setlength\belowcaptionskip{5\jlreq@mpt}


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

% figure環境
\newcounter{figure}
\renewcommand{\thefigure}{\rensuji{\@arabic\c@figure}}
\newcommand{\fps@figure}{tbp}
\newcommand{\ftype@figure}{1}
\newcommand{\ext@figure}{lof}
\newcommand{\fnum@figure}{\figurename\thefigure}
\newenvironment{figure}
  {\@float{figure}}
  {\end@float}
\newenvironment{figure*}
  {\@dblfloat{figure}}
  {\end@dblfloat}
\DeclareLayoutCaption{figure}<y>(\floatwidth)[cr]
%\jlreq@modify@float{figure}
%\jlreq@modify@float{figure*}
% table環境
\newcounter{table}
\renewcommand{\thetable}{\rensuji{\@arabic\c@table}}
\newcommand{\fps@table}{tbp}
\newcommand{\ftype@table}{2}
\newcommand{\ext@table}{lot}
\newcommand{\fnum@table}{\tablename\thetable}
\newenvironment{table}
  {\@float{table}}
  {\end@float}
\newenvironment{table*}
  {\@dblfloat{table}}
  {\end@dblfloat}
\DeclareLayoutCaption{table}<y>(\floatwidth)[cr]
%\jlreq@modify@float{table}
%\jlreq@modify@float{table*}


% \maketitleとかabstractとか．tarticleから．
\if@titlepage
  \newcommand{\maketitle}{\begin{titlepage}%
  \let\footnotesize\small
  \let\footnoterule\relax
  \let\thanks\p@thanks
  \let\footnote\thanks
  \vbox to\textheight\bgroup\tate\hsize\textwidth
  \null\vfil
  \vskip 60\jlreq@mpt
  \begin{center}%
    {\LARGE \@title \par}%
    \vskip 3em%
    {\Large
     \lineskip .75em%
      \begin{tabular}[t]{c}%
        \@author
      \end{tabular}\par}%
      \vskip 1.5em%
    {\large \@date \par}%       % Set date in \large size.
  \end{center}\par
  \vfil{\centering\@thanks}\vfil\null
  \egroup
  \end{titlepage}%
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
\else
  \newcommand{\maketitle}{\par
  \begingroup
    \renewcommand{\thefootnote}{\fnsymbol{footnote}}%
    \def\@makefnmark{\hbox{\unless\ifnum\ltjgetparameter{direction}=3 $\m@th^{\@thefnmark}$
      \else\hbox{\yoko$\m@th^{\@thefnmark}$}\fi}}%
    \long\def\@makefntext##1{\parindent 1\zw\noindent
      \hbox to 2\zw{\hss\@makefnmark}##1}%
    \if@twocolumn
      \ifnum \col@number=\@ne \@maketitle
      \else \twocolumn[\@maketitle]%
      \fi
    \else
      \newpage
      \global\@topnum\z@   % Prevents figures from going at top of page.
      \@maketitle
    \fi
    \thispagestyle{jpl@in}\@thanks
  \endgroup
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
  }
  % いい加減……一応行送りを整数倍に．
  \def\@maketitle{%
  \newpage\null
  \vskip 2\baselineskip%
  \begin{center}%
  \let\footnote\p@thanks
    {\@tempdima=\baselineskip\LARGE\baselineskip=\@tempdima \@title \par}%
    \vskip \baselineskip
    {\@tempdima=\baselineskip\large\baselineskip=\@tempdima
      \lineskip .5\zw%
      \begin{tabular}[t]{c}%
        \@author
      \end{tabular}\par}%
    \vskip \baselineskip
    {\@tempdima=\baselineskip\large\baselineskip=\@tempdima \@date}%
  \end{center}%
  \par\vskip \baselineskip}
\fi
\if@titlepage
  \newenvironment{abstract}{%
      \titlepage
      \null\vfil
      \@beginparpenalty\@lowpenalty
      \begin{center}%
        {\bfseries\abstractname}%
        \@endparpenalty\@M
      \end{center}}%
      {\par\vfil\null\endtitlepage}
\else
  \newenvironment{abstract}{%
    \if@twocolumn
      \section*{\abstractname}%
    \else
      \@tempdima=\baselineskip\small\baselineskip=\@tempdima
      \begin{center}%
        {\bfseries\abstractname\vspace{-.5\zw}\vspace{\z@}}%
      \end{center}%
      \quotation
    \fi}{\if@twocolumn\else\endquotation\fi}
\fi

% 箇条書き．cf. JISX4051 8.4
% 用語定義型
\newenvironment{description}{\list{}{%
  \setlength{\leftmargin}{0\zh}% 下げない
  \setlength{\labelwidth}{0\zh}%
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
% （見出しは2\zhの箱に下詰めで入る．）
\setlength\leftmargini{0\zh}
\setlength\leftmarginii{1\zh}
\setlength\leftmarginiii{1\zh}
\setlength\leftmarginiv{1\zh}
\setlength\leftmarginv{1\zh}
\setlength\leftmarginvi{1\zh}

% enumerate, itemize用初期化
\def\jlreq@init@list{%
  \setlength{\labelwidth}{2\zh}%
  \setlength{\topsep}{0pt}%
  \setlength{\partopsep}{0pt}%
  \setlength{\itemsep}{0pt}%
  \setlength{\parsep}{0pt}%
  \setlength{\listparindent}{1\zh}%
% itemizeは直後ベタ，enumerateは直後全角空き．
  \ifx\@currenvir\jlreq@itemizename
    \setlength{\labelsep}{0\zh}%
  \else
    \setlength{\labelsep}{1\zh}%
  \fi
  % \labelsepだけあけるのは一つ目（ラベルの直後）のみ
  \setlength{\itemindent}{\labelsep}%
}
\def\jlreq@itemizename{itemize}

\def\@listi{%
  \jlreq@init@list
  \setlength{\leftmargin}{\leftmargini}%
  % 最初だけ\leftmarginを調整する
  \addtolength{\leftmargin}{\leftskip}%
  \addtolength{\leftmargin}{\labelsep}%
  \addtolength{\leftmargin}{\labelwidth}%
  \addtolength{\leftmargin}{-\itemindent}%
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
% レベル1だけはJISX 4051から．後はそのまま．
\renewcommand{\theenumi}{\Kanji{enumi}}
\renewcommand{\theenumii}{\rensuji{\@arabic\c@enumii}}
\renewcommand{\theenumiii}{\rensuji{\@arabic\c@enumiii}}
\renewcommand{\theenumiv}{\rensuji{\@arabc\c@enumiv}}
\newcommand{\labelenumi}{\theenumi}
\newcommand{\labelenumii}{\theenumii}
\newcommand{\labelenumiii}{\theenumiii}
\newcommand{\labelenumiv}{\theenumiv}
\renewcommand{\p@enumii}{\theenumi}
\renewcommand{\p@enumiii}{\theenumi(\theenumii)}
\renewcommand{\p@enumiv}{\p@enumiii\theenumiii}

\newcommand{\labelitemi}{•}
\newcommand{\labelitemii}{\textcircled{~}}
\newcommand{\labelitemiii}{\textasteriskcentered}
\newcommand{\labelitemiv}{\textperiodcentered}

% 引用系．1.5em→1\zh，字下げを二文字にした．3.5.2の例．
\newenvironment{verse}
  {\let\\\@centercr
  \list{}{\itemsep\z@ \itemindent -2\zh%
    \listparindent\itemindent
    \labelwidth\z@
    \labelsep\z@
    \leftmargin=2\zh
    \rightmargin\leftmargin \advance\leftmargin 2\zh}%
    \item\relax}{\endlist}
\newenvironment{quotation}
  {\list{}{\listparindent\parindent
    \itemindent\listparindent
    \labelwidth\z@
    \labelsep\z@
    \leftmargin=2\zh
    \rightmargin\leftmargin
    \parsep\z@ \@plus\jlreq@mpt}%
    \item\relax}{\endlist}
\newenvironment{quote}
  {\list{}{\rightmargin\leftmargin\labelwidth\z@\leftmargin=2\zh\listparindent\z@}%
    \item\relax}{\endlist}

% tarticleから変えていない．
\setlength\arraycolsep{5\jlreq@mpt}
\setlength\tabcolsep{6\jlreq@mpt}
\setlength\arrayrulewidth{.4\jlreq@mpt}
\setlength\doublerulesep{2\jlreq@mpt}
\setlength\tabbingsep{\labelsep}
\skip\@mpfootins = \skip\footins
\setlength\fboxsep{3\jlreq@mpt}
\setlength\fboxrule{.4\jlreq@mpt}
\renewcommand{\theequation}{\@arabic\c@equation}

% 数式フォント設定
\DeclareSymbolFont{mincho}{JY3}{mc}{m}{n}
\DeclareSymbolFontAlphabet{\mathmc}{mincho}
\SetSymbolFont{mincho}{bold}{JY3}{gt}{m}{n}
\jfam\symmincho
\DeclareMathAlphabet{\mathgt}{JY3}{gt}{m}{n}

% あれば読み込む．
\IfFileExists{bxoldfontcmd.sty}{\RequirePackage[praised]{bxoldfontcmd}}{}
%\DeclareOldFontCommand{\mc}{\normalfont\mcfamily}{\mathmc}
%\DeclareOldFontCommand{\gt}{\normalfont\gtfamily}{\mathgt}
%\DeclareOldFontCommand{\rm}{\normalfont\rmfamily}{\mathrm}
%\DeclareOldFontCommand{\sf}{\normalfont\sffamily}{\mathsf}
%\DeclareOldFontCommand{\tt}{\normalfont\ttfamily}{\mathtt}
%\DeclareOldFontCommand{\bf}{\normalfont\bfseries}{\mathbf}
%\DeclareOldFontCommand{\it}{\normalfont\itshape}{\mathit}
%\DeclareOldFontCommand{\sl}{\normalfont\slshape}{\@nomath\sl}
%\DeclareOldFontCommand{\sc}{\normalfont\scshape}{\@nomath\sc}
%\DeclareRobustCommand*{\cal}{\@fontswitch\relax\mathcal}
%\DeclareRobustCommand*{\mit}{\@fontswitch\relax\mathnormal}


% 目次
\setcounter{tocdepth}{3}
\newcommand{\@pnumwidth}{2\zh}
\newcommand{\@tocrmarg}{2.55em}
\newcommand{\@dotsep}{2} % 狭くしてみた
\newdimen\toclineskip
\setlength\toclineskip{0\jlreq@mpt}
\newdimen\@lnumwidth
\def\numberline#1{\hbox to\@lnumwidth{#1\hfil}}
\def\addcontentsline#1#2#3{%
  \protected@write\@auxout
    {\let\label\@gobble \let\index\@gobble \let\glossary\@gobble
\@temptokena{\rensuji{\thepage}}}%
    {\string\@writefile{#1}%
      {\protect\contentsline{#2}{#3}{\the\@temptokena}}}%
}

\newcount\jlreq@top@contents % トップ見出しを入れる．\partから1,2,...
\newcommand*{\jlreq@set@top@contents}[1]{%
  \ifnum\jlreq@top@contents=0\relax
    \jlreq@top@contents=#1\relax
  \fi
}
\newcommand{\tableofcontents}{%
  \jlreq@top@contents=0\relax
  \section*{\contentsname
    \@mkboth{\contentsname}{\contentsname}%
  }\@starttoc{toc}%
}

% JIS X 4051自身の目次に近づけようかと……なりきれてないけど．
% 文字の大きさは全て同じ（\normalsize）にする．
% 見出しのレベルがあがると1\zhずつ字下げしていく．
% 第三引数は，上からの幅に加え更にトップの見出しからの差による補正（プラス）が入る．
% リーダーは.から・に変更しました．更に直後から出るように．
\def\@dottedtocline#1#2#3#4#5{%
  \ifnum #1>\c@tocdepth \else
    \vskip\toclineskip \@plus.2\jlreq@mpt
    {\leftskip #2\relax \rightskip \@tocrmarg \parfillskip -\rightskip
    \parindent #2\relax\@afterindenttrue
    \interlinepenalty\@M
    \leavevmode
    \@lnumwidth #3\relax
      \@tempcnta=#1\relax
      \advance\@tempcnta by 1\relax
      \advance\@tempcnta by -\jlreq@top@contents\relax
      \@tempdima=1\zh
      \multiply \@tempdima by \@tempcnta
    \advance\leftskip \@lnumwidth \hbox{}\hskip -\leftskip
      \advance\leftskip\@tempdima
    {#4}\nobreak
    \leaders\hbox{$・\mkern \@dotsep mu \m@th \mkern \@dotsep mu$}%
    \hfill\nobreak
    \hb@xt@\@pnumwidth{\hss\normalfont \normalcolor #5}%
    \par}%
  \fi}
\newcommand*{\l@part}[2]{%
  \jlreq@set@top@contents{1}%
  \ifnum \c@tocdepth >-2\relax
    \addpenalty{\@secpenalty}%
    \begingroup
    \parindent\z@\rightskip\@pnumwidth
    \parfillskip-\@pnumwidth
    {\leavevmode\bfseries
    \setlength\@lnumwidth{2\zw}%
    #1\hfil\nobreak
    \hbox to\@pnumwidth{\hss#2}}\par
    \nobreak
    \endgroup
  \fi}

\newcommand*{\l@section}[2]{%
  \jlreq@set@top@contents{2}%
  \ifnum \c@tocdepth >\z@
    \addpenalty{\@secpenalty}%
    \begingroup
      \setlength\@lnumwidth{2\zh}%
      \@tempcnta=2\relax
      \advance \@tempcnta by -\jlreq@top@contents\relax
      \@tempdima=1\zh
      \multiply \@tempdima by \@tempcnta
      \parindent\z@ \rightskip\@pnumwidth
      \parfillskip-\rightskip
      \leavevmode\bfseries
      \advance\leftskip\@lnumwidth
      \hskip-\leftskip
      \advance\leftskip\@tempdima
      #1\nobreak\hfil\nobreak\hbox to\@pnumwidth{\hss#2}\par
    \endgroup
  \fi}
\newcommand*{\l@subsection}   {\jlreq@set@top@contents{3}\@dottedtocline{2}{0\zh}{2\zw}}
\newcommand*{\l@subsubsection}{\jlreq@set@top@contents{4}\@dottedtocline{3}{0\zh}{2\zw}}
\newcommand*{\l@paragraph}    {\jlreq@set@top@contents{5}\@dottedtocline{4}{0\zh}{2\zw}}
\newcommand*{\l@subparagraph} {\jlreq@set@top@contents{6}\@dottedtocline{5}{0\zh}{2\zw}}

% listoffigures
\newcommand{\listoffigures}{%
    \jlreq@top@contents=1\relax
    \section*{\listfigurename
  \@mkboth{\listfigurename}{\listfigurename}}%
  \@starttoc{lof}%
}
\newcommand*{\l@figure}{\@dottedtocline{1}{0\zw}{2\zw}}
\newcommand{\listoftables}{%
    \jlreq@top@contents=1\relax
    \section*{\listtablename
  \@mkboth{\listtablename}{\listtablename}}%
  \@starttoc{lot}%
}
\let\l@table\l@figure

% 文献
\newdimen\bibindent
\setlength\bibindent{1.5em}
\newcommand{\newblock}{\hskip .11em\@plus.33em\@minus.07em}
\newenvironment{thebibliography}[1]
{\section*{\refname\@mkboth{\refname}{\refname}}%
  \list{\@biblabel{\@arabic\c@enumiv}}%
      {\settowidth\labelwidth{\@biblabel{#1}}%
      \leftmargin\labelwidth
      \advance\leftmargin\labelsep
      \@openbib@code
      \usecounter{enumiv}%
      \let\p@enumiv\@empty
      \renewcommand\theenumiv{\@arabic\c@enumiv}}%
  \sloppy
  \clubpenalty4000
  \@clubpenalty\clubpenalty
  \widowpenalty4000%
  \sfcode`\.\@m}
  {\def\@noitemerr
    {\@latex@warning{Empty `thebibliography' environment}}%
  \endlist}
\let\@openbib@code\@empty

% 索引
\newenvironment{theindex}
  {\if@twocolumn\@restonecolfalse\else\@restonecoltrue\fi
   \columnseprule\z@ \columnsep 35\jlreq@mpt
   \twocolumn[\section*{\indexname}]%
   \@mkboth{\indexname}{\indexname}%
   \thispagestyle{jpl@in}\parindent\z@
   \parskip\z@ \@plus .3\jlreq@mpt\relax
   \let\item\@idxitem}
  {\if@restonecol\onecolumn\else\clearpage\fi}
\newcommand{\@idxitem}{\par\hangindent 40\jlreq@mpt}
\newcommand{\subitem}{\@idxitem \hspace*{20\jlreq@mpt}}
\newcommand{\subsubitem}{\@idxitem \hspace*{30\jlreq@mpt}}
\newcommand{\indexspace}{\par \vskip 10\jlreq@mpt \@plus5\jlreq@mpt \@minus3\jlreq@mpt\relax}

% なんかいろいろ
\newif\if西暦 \西暦false
\def\西暦{\西暦true}
\def\和暦{\西暦false}
\newcount\heisei \heisei\year \advance\heisei-1988\relax
\def\today{{%
  \ifnum\ltjgetparameter{direction}=3
    \if西暦
      \kansuji\year 年
      \kansuji\month 月
      \kansuji\day 日
    \else
      平成\ifnum\heisei=1 元年\else\kansuji\heisei 年\fi
      \kansuji\month 月
      \kansuji\day 日
    \fi
  \else
    \if西暦
      \number\year~年
      \number\month~月
      \number\day~日
    \else
      平成\ifnum\heisei=1 元年\else\number\heisei~年\fi
      \number\month~月
      \number\day~日
    \fi
  \fi}}

% ルビ
\RequirePackage{luatexja-ruby}

% 割注: 3.4
\newcommand{\jlreq@warichu@kakkofontsize}{%
  \fontsize{\numexpr \warichusize * 2\relax\jlreq@mpt}{\numexpr \warichusize * 2\relax\jlreq@mpt}%
  \selectfont
}

\newcommand{\jlreq@warichu@fontsize}{%
  \fontsize{\warichusize\jlreq@mpt}{\warichusize\jlreq@mpt}%
  \selectfont
}

\newcommand{\warichusize}{6} % 割注の文字サイズ
\let\jlreq@warichu@autolinebreak=\\% 計測時は\linebreakより\\の方が安定する．悩ましい……．

% 割注を入れるための命令．\warichu{割注}で使う．
% 改行位置は自動で計算されるが，常に正しいとは限らない．
% \warichu*は自動で改行されない．\\で改行位置を指定する．
\newif\ifjlreq@inwarichu
\jlreq@inwarichufalse
\newcommand*{\warichu}{%
  \ifjlreq@inwarichu\ClassError{tjlreq}{\string\warichu\space can't be nested}{\@ehc}\fi
  \jlreq@inwarichutrue
  \@ifstar\jlreq@warichu@noauto\jlreq@warichu@auto}

\newcommand*{\jlreq@warichu@auto}[1]{%
  % 割注初め括弧の前の場所を保存
  \jlreq@savepos@for@rest@linewidth
  % \jlreq@tempdimbに，現在行の残り長さを入れる
  \jlreq@tempdimb=\jlreq@rest@linewidth
  % 括弧の分を引いたものが，割注の使える長さ
  \setbox\@tempboxa=\hbox{\jlreq@warichu@kakkofontsize\inhibitglue（\inhibitglue}%
  \addtolength{\jlreq@tempdimb}{-\wd\@tempboxa}%
  {\jlreq@warichu@kakkofontsize\inhibitglue （}%
  % 普通に並べた長さを計測し，その半分から始める
  \setbox\@tempboxa=\hbox{\jlreq@warichu@fontsize #1}%
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
    \jlreq@warichu@determinelength{#1}{\jlreq@warichu@fontsize}{\jlreq@parshapearg}{2}{\@tempb}{\jlreq@tempdimc}{\jlreq@tempdimb}%
    \@tempcntb=\@tempb
    \ifnum\@tempcntb>999\relax% ループが長すぎる
      \global\setbox\jlreq@resultbox=\voidb@x%
      \@tempcntb=1001\relax
    \fi
    \ifvoid\jlreq@resultbox\else% 成功
      \edef\jlreq@warichu@lines{\the\@tempcntb}% 行数を保存
      \@tempcntb=1001\relax
    \fi
    \advance\@tempcntb by 2\relax
    \edef\jlreq@parshapearg{\jlreq@parshapearg 0pt \the\jlreq@tempdimb 0pt \the\jlreq@tempdimb}%
  }%
  \ifvoid\jlreq@resultbox
    \ClassWarning{tjlreq}{\string\warichu\space failed, may be a bug}%
  \else
    \@tempcnta=0\relax
    \splittopskip=0pt\relax
    \splitmaxdepth=\maxdimen
    % 現在行の残り長さを思い出す
    \jlreq@tempdimb=\jlreq@rest@linewidth
    \setbox\@tempboxa=\hbox{\jlreq@warichu@kakkofontsize\inhibitglue（\inhibitglue}%
    \addtolength{\jlreq@tempdimb}{-\wd\@tempboxa}%
    \setbox\@tempboxa=\box\jlreq@resultbox
    \@whilenum\@tempcnta<\jlreq@warichu@lines\do{%
      \ifnum\@tempcnta>0\relax\jlreq@warichu@autolinebreak\fi
      % \jlreq@tempdimaに今の行の長さを入れる
      \ifnum\@tempcnta<\numexpr\jlreq@warichu@lines - 2\relax
        \ifnum\@tempcnta=0\jlreq@tempdima=\jlreq@tempdimb
        \else\jlreq@tempdima=\linewidth\fi
      \else
        \jlreq@tempdima=-1pt\relax
      \fi
      {%
        \jlreq@warichu@fontsize
        \setbox\jlreq@tempboxa=\vsplit\@tempboxa to \dimexpr 2\baselineskip - 0.001pt\relax
        % 改行を\\でしている場合には，割注の長さを計測した物に長さに強制する
        \jlreq@getlastbox{\jlreq@tempboxa}%
        \setbox\jlreq@tempboxb=\box\jlreq@resultbox
        \jlreq@getlastbox{\jlreq@tempboxa}%
        \setbox\jlreq@tempboxa=\box\jlreq@resultbox
        \ifx\jlreq@warichu@autolinebreak\\\relax
          \ifdim\jlreq@tempdima>0pt\relax
            \raise-.5\zw\hbox to \jlreq@tempdima{\vbox{%
              \hbox to \jlreq@tempdima{\unhbox\jlreq@tempboxa}%
              \hbox to \jlreq@tempdima{\unhbox\jlreq@tempboxb}}}%
          \else
            \raise-.5\zw\hbox{\vbox{%
              \hbox{\unhbox\jlreq@tempboxa}%
              \hbox{\unhbox\jlreq@tempboxb}}}%
          \fi
        \else
          \raise-.5\zw\hbox to \jlreq@tempdima{\vbox{%
            \hbox{\unhbox\jlreq@tempboxa}%
            \hbox{\unhbox\jlreq@tempboxb}}}%
        \fi
      }%
      \advance\@tempcnta by 2\relax
    }%
  \fi
  \jlreq@warichu@endwarichu
}

\newcommand*{\jlreq@warichu@noauto}[1]{%
  {\jlreq@warichu@kakkofontsize
  \inhibitglue （}%
  \tracingmacros=1\relax
  \jlreq@warichu@noauto@#1\\\jlreq@endmark\jlreq@endmark
  \tracingmacros=0\relax
  \jlreq@warichu@endwarichu
}

\def\jlreq@warichu@noauto@#1\\#2#3\jlreq@endmark{%
  \jlreq@warichu@noauto@@#1&\jlreq@endmark\jlreq@endmark
  \ifx#2\jlreq@endmark\def\jlreq@next{}\else\linebreak\def\jlreq@next{\jlreq@warichu@noauto@#2#3\jlreq@endmark}\fi
  \jlreq@next
}

\def\jlreq@warichu@noauto@@#1&#2#3\jlreq@endmark{%
  \ifx#2\jlreq@endmark
    \setbox\@tempboxa=\hbox{\jlreq@warichu@fontsize #1}%
    \jlreq@tempdimc=\wd\@tempboxa
    \divide\jlreq@tempdimc by 2\relax
    \jlreq@warichu@determinelength{#1}{\jlreq@warichu@fontsize}{}{2}{2}{\jlreq@tempdimc}{\maxdimen}%
    \ifvoid\jlreq@resultbox\else
      {%
        \jlreq@warichu@fontsize\raise-.5\zw\hbox{\box\jlreq@resultbox}%
      }%
    \fi
    \def\jlreq@next{}%
  \else
    \def\jlreq@next{\jlreq@warichu@noauto@@@{#1}#2#3}%
  \fi
  \jlreq@next
}

\def\jlreq@warichu@noauto@@@#1#2&\jlreq@endmark{%
  {\jlreq@warichu@fontsize\raise-.5\zw\hbox{\vbox{\hbox{#1}\hbox{#2}}}}%
}

\newcommand{\jlreq@warichu@endwarichu}{%
  \jlreq@inwarichufalse
  {\jlreq@warichu@kakkofontsize\hbox to .5\zh{）}\inhibitglue}%
}

\newbox\jlreq@tempboxa
\newbox\jlreq@tempboxb
% \jlreq@warichu@determinelength{テキスト(1)}{書式指定(2)}{\parshape指定(3)}{調整に使う行数(4)}{成功行数(5)}{最小長さ(6)}{最大長さ(7)}
% \jlreq@resultboxに整形結果を返す．見つからなかったらvoid
\newcommand{\jlreq@warichu@determinelength}[7]{%
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

% デフォルト設定
\newcommand{\prepartname}{第}
\newcommand{\postpartname}{部}
\newcommand{\contentsname}{目 次}
\newcommand{\listfigurename}{図 目 次}
\newcommand{\listtablename}{表 目 次}
\newcommand{\refname}{参考文献}
\newcommand{\indexname}{索 引}
\newcommand{\figurename}{図}
\newcommand{\tablename}{表}
\newcommand{\appendixname}{付 録}
\newcommand{\abstractname}{概 要}
\pagestyle{plain}
\pagenumbering{arabic}
\raggedbottom
\onecolumn
\normalmarginpar
\@mparswitchfalse
\endinput


