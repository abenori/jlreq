%#main jlreqtest.tex
%%#! lualatex
%#! lualatex jlreqtest.tex ; pdftk jlreqtest.pdf multistamp onlya.pdf output out.pdf
%#PDF out.pdf
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

%. 基本設定
% 和文文字，欧文文字の設定
\ltjsetparameter{jacharrange={-1, +2, +3, -4, -5, +6, +7, -8}}

% kanjiskip, xkanjiskipはjfmのものを使う
\ltjsetparameter{kanjiskip=\maxdimen}
\ltjsetparameter{xkanjiskip=\maxdimen}
% 禁則処理
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

%. オプションの処理
% サイズ
\newcommand{\jlreq@checkempty}[2]{\ifx#2\relax\relax\else\ClassError{jlreq}{The option #1 should have no value.}\fi}
% 引数無しの\DeclareOptionX
\newcommand{\jlreq@DeclareOption}[2]{%
  \DeclareOptionX{#1}{\jlreq@checkempty{#1}{##1}#2}
}
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

\newcommand{\jlreq@scale}{1}
% jsarticleから
\jlreq@DeclareOption{8pt} {\renewcommand{\jlreq@scale}{0.833}}% 1.2^(-1)
\jlreq@DeclareOption{9pt} {\renewcommand{\jlreq@scale}{0.913}}% 1.2^(-0.5}
\jlreq@DeclareOption{10pt}{\renewcommand{\jlreq@scale}{1}}
\jlreq@DeclareOption{11pt}{\renewcommand{\jlreq@scale}{1.095}}% 1.2^0.5
\jlreq@DeclareOption{12pt}{\renewcommand{\jlreq@scale}{1.200}}
\jlreq@DeclareOption{14pt}{\renewcommand{\jlreq@scale}{1.440}}
\jlreq@DeclareOption{17pt}{\renewcommand{\jlreq@scale}{1.728}}
\jlreq@DeclareOption{20pt}{\renewcommand{\jlreq@scale}{2}}
\jlreq@DeclareOption{21pt}{\renewcommand{\jlreq@scale}{2.074}}
\jlreq@DeclareOption{25pt}{\renewcommand{\jlreq@scale}{2.488}}
\jlreq@DeclareOption{30pt}{\renewcommand{\jlreq@scale}{2.986}}
\jlreq@DeclareOption{36pt}{\renewcommand{\jlreq@scale}{3.583}}
\jlreq@DeclareOption{43pt}{\renewcommand{\jlreq@scale}{4.300}}
\jlreq@DeclareOption{12Q} {\renewcommand{\jlreq@scale}{0.923}}% 1pt*12Q/13Q
\jlreq@DeclareOption{14Q} {\renewcommand{\jlreq@scale}{1.077}}% 1pt*14Q/13Q
\jlreq@DeclareOption{10ptj}{\renewcommand{\jlreq@scale}{1.085}}% 1pt*10bp/13Q
\jlreq@DeclareOption{10.5ptj}{\renewcommand{\jlreq@scale}{1.139}}
\jlreq@DeclareOption{11ptj}{\renewcommand{\jlreq@scale}{1.194}}
\jlreq@DeclareOption{12ptj}{\renewcommand{\jlreq@scale}{1.302}}

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
% 行の長さ
\newcommand{\jlreq@line@length}{}
\DeclareOptionX{line_length}{\renewcommand{\jlreq@line@length}{#1}}
% 1ページあたりの行数
\newcommand{\jlreq@number@of@lines}{}
\DeclareOptionX{number_of_lines}{\renewcommand{\jlreq@number@of@lines}{#1}}
% 行頭に括弧が来たときにどうするか．
% 段落頭指定_折り返し行頭指定 で与える．
\newcommand{\jlreq@open@bracket@pos}{zenkaku_tentsuki}
\define@choicekey{tjlreq.cls}{open_bracket_pos}{zenkaku_tentsuki,zenkakunibu_nibu,nibu_tentsuki}{\renewcommand{\jlreq@open@bracket@pos}{#1}}
\newif\ifjlreq@burasage
\jlreq@DeclareOption{hanging_punctuation}{\jlreq@burasagetrue}

\ExecuteOptionsX{a4paper,10pt,twoside,onecolumn,final,tate}
\ProcessOptionsX\relax

% この値は後でjfm-jlreq内で読む
\directlua{jlreq.open_bracket_pos = [[\jlreq@open@bracket@pos]]}
\ifjlreq@burasage\directlua{jlreq.burasage = true}
\else\directlua{jlreq.burasage = false}\fi

\if@landscape
  \setlength\@tempdima  {\paperheight}
  \setlength\paperheight{\paperwidth}
  \setlength\paperwidth {\@tempdima}
\fi
% 行送り
\newcommand{\n@baseline}{16}

% スケーリング用
\newdimen\jlreq@mpt
\jlreq@mpt=\jlreq@scale\p@


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

\RequirePackage{luatexja-adjust}
\ltjenableadjust

% 和文フォント
\expandafter\let\csname JT3/mc/m/n/10\endcsname\relax
\DeclareFontShape{JT3}{mc}{m}{n}{<-> s * [0.924715] \ltj@stdmcfont:jfm=jlreqv;script=latn;-kern}{}
\DeclareFontShape{JT3}{gt}{m}{n}{<-> s * [0.924715] \ltj@stdgtfont:jfm=jlreqv;script=latn;-kern}{}
\DeclareFontShape{JT3}{mc}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{JT3}{gt}{bx}{n}{<->ssub*gt/m/n}{}
\DeclareFontShape{JT3}{mc}{m}{it}{<->ssub*mc/m/n}{}
\DeclareFontShape{JT3}{mc}{m}{sl}{<->ssub*mc/m/n}{}
\DeclareFontShape{JT3}{mc}{m}{sc}{<->ssub*mc/m/n}{}
\DeclareFontShape{JT3}{gt}{m}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{JT3}{gt}{m}{sl}{<->ssub*gt/m/n}{}
\DeclareFontShape{JT3}{mc}{bx}{it}{<->ssub*gt/m/n}{}
\DeclareFontShape{JT3}{mc}{bx}{sl}{<->ssub*gt/m/n}{}

\newcommand{\jlreq@setfontsize}[3]{%
  \@setfontsize#1{#2\jlreq@mpt}{#3\jlreq@mpt}}
\emergencystretch 3\zw

\renewcommand{\normalsize}{%
\jlreq@setfontsize\normalsize\@xpt{\n@baseline}%
\abovedisplayskip 11\jlreq@mpt \@plus3\jlreq@mpt \@minus4\jlreq@mpt
\abovedisplayshortskip \z@ \@plus3\jlreq@mpt
\belowdisplayskip 9\jlreq@mpt \@plus3\jlreq@mpt \@minus4\jlreq@mpt
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

% とりあえずtarticleからほぼそのまま
\newcommand{\small}{%
  \@setfontsize\small\@ixpt{11}%
  \abovedisplayskip 8.5\jlreq@mpt \@plus3\jlreq@mpt \@minus4\jlreq@mpt
  \abovedisplayshortskip \z@ \@plus2\jlreq@mpt
  \belowdisplayshortskip 4\jlreq@mpt \@plus2\jlreq@mpt \@minus2\jlreq@mpt
  \def\@listi{\leftmargin\leftmargini
    \topsep 4\jlreq@mpt \@plus2\jlreq@mpt \@minus2\jlreq@mpt
    \parsep 2\jlreq@mpt \@plus\jlreq@mpt \@minus\jlreq@mpt
    \itemsep \parsep}%
  \belowdisplayskip \abovedisplayskip}
\newcommand{\footnotesize}{%
  \jlreq@setfontsize\footnotesize\@viiipt{11}% 脚注文字サイズの二分より少し小さい値を行間に: 4.2.5.e
  \abovedisplayskip 6\jlreq@mpt \@plus2\jlreq@mpt \@minus4\jlreq@mpt
  \abovedisplayshortskip \z@ \@plus\jlreq@mpt
  \belowdisplayshortskip 3\jlreq@mpt \@plus\jlreq@mpt \@minus2\jlreq@mpt
  \def\@listi{\leftmargin\leftmargini
    \topsep 3\jlreq@mpt \@plus\jlreq@mpt \@minus\jlreq@mpt
    \parsep 2\jlreq@mpt \@plus\jlreq@mpt \@minus\jlreq@mpt
    \itemsep \parsep}%
  \belowdisplayskip \abovedisplayskip}
\newcommand{\scriptsize}{\jlreq@setfontsize\scriptsize\@viipt\@viiipt}
\newcommand{\tiny}{\jlreq@setfontsize\tiny\@vpt\@vipt}
\newcommand{\large}{\jlreq@setfontsize\large\@xiipt{17}}
\newcommand{\Large}{\jlreq@setfontsize\Large\@xivpt{21}}
\newcommand{\LARGE}{\jlreq@setfontsize\LARGE\@xviipt{25}}
\newcommand{\huge}{\jlreq@setfontsize\huge\@xxpt{28}}
\newcommand{\Huge}{\jlreq@setfontsize\Huge\@xxvpt{33}}

\RequirePackage{lltjext}
\def\@Kanji#1{\expandafter\kansuji\number #1\relax} % \relax追加
\rensujiskip=0.25\zh plus 0.25\zh minus 0.125\zh

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
% ページレイアウト
% \jlreq@setlength[単位]{セットする値}{値の入っているマクロ}{デフォルト}
\newcommand\jlreq@setlength[4][]{%
  \expandafter\ifx #3\relax\relax\setlength{#2}{#4}
  \else\setlength{#2}{\dimexpr\jlreq@expand@speciallength{#3 #1}\relax}\fi
}
\def\jlreq@expand@speciallength#1{%
  % zhやzwを\zhや\zwにする．
  \directlua{
    local yen = string.char(92)
    local s = [[#1]]
    s = s:gsub("zw",yen .. "zw"):gsub("zh",yen .. "zh")
    tex.print(s)
  }%
}

% デフォルト値は縦が0.768倍，横が0.727倍．
% JISX4051のA5の例から換算
% 縦 (\textwidth)
\jlreq@setlength{\textwidth}{\jlreq@line@length}{0.768\paperheight}
\@tempdima=1\zh
\divide\textwidth\zh \multiply\textwidth\zh
% 横 (\textheight)
\jlreq@setlength[\baselineskip]{\textheight}{\jlreq@number@of@lines}{0.727\paperwidth}
\divide\textheight\baselineskip \multiply\textheight\baselineskip
\setlength{\topskip}{1\zw} % フォントサイズと一致させる
% ヘッダ：本文から1文字分離す．ヘッダの高さはjsarticleに習ってその二倍
\setlength{\headsep}{1\zh}
\setlength{\headheight}{2\zh}
% 中央配置のための計算
% 横
\setlength{\oddsidemargin}{\paperwidth}
\addtolength{\oddsidemargin}{-\textheight}
\setlength{\oddsidemargin}{.5\oddsidemargin}
\addtolength{\oddsidemargin}{-1in}
\setlength{\evensidemargin}{\oddsidemargin}
% 縦
\setlength{\topmargin}{\paperheight}
\addtolength{\topmargin}{-\textwidth}
\setlength{\topmargin}{0.5\topmargin}
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
% 脚注関連
% 線までが本文行間分（4.2.6.g），その後が脚注内の行間のつもり
{\footnotesize\global\setlength{\footnotesep}{.7\baselineskip}} % 何でかわからん……
\setlength{\@tempdima}{\baselineskip}
\addtolength{\@tempdima}{-.5\zw}
\setlength{\skip\footins}{\@tempdima plus 1\zw}
\renewcommand{\footnoterule}{\hrule width .333\textwidth} % 4.2.6.f
% 4.5.2.d
\newcommand\@makefntext[1]{\parindent 1\zh
  \addtolength{\leftskip}{2\zh}%
  \noindent\llap{\@makefnmark}\hskip 1\zh#1}
% 4.2.3.b
\renewcommand{\@footnotemark}{%
  \leavevmode
  \ifhmode\edef\@x@sf{\the\spacefactor}\nobreak\fi
  \setbox\@tempboxa=\hbox{\@makefnmark}%
  \hbox to\z@{\hskip-\wd\@tempboxa\raise.9\zh\box\@tempboxa\hss}%
  \ifhmode\spacefactor\@x@sf\fi
  \relax}
% 図4.61のようにする
\renewcommand{\@makefnmark}{\hbox{\yoko\rensujiskip=0pt\@textsuperscript{\tate\normalfont（\@thefnmark）\kern-1\zw}}}
\renewcommand{\thefootnote}{\rensuji{\@arabic\c@footnote}}

% ページスタイル．
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

% セクションとか
% 今の1\zh/1\zwのサイズを保存
\newdimen\jlreq@normalsize@zenkaku@height
\jlreq@normalsize@zenkaku@height=1\zh
\newdimen\jlreq@normalsize@zenkaku@width
\jlreq@normalsize@zenkaku@width=1\zw

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
% 4.1.3.cにある例のようにする．
% 4行取り中央にする
% \part{***}\section{***}とかの場合（4.1.6.e）はどうしよう．
% 窓見出し，段抜きの見出しとかはない．
\newcommand{\part}{\par\addvspace{1.5\baselineskip}%
  \@afterindenttrue
  \secdef\@part\@spart}
\def\@part[#1]#2{%
  \ifnum \c@secnumdepth >\m@ne
    \refstepcounter{part}%
    \addcontentsline{toc}{part}{%
      \prepartname\thepart\postpartname\hspace{1\zw}#1}%
  \else
    \addcontentsline{toc}{part}{#1}%
  \fi
  \markboth{}{}%
  {\parindent\z@\raggedright
  \interlinepenalty\@M\reset@font
  \hskip 4\zh
  \@tempdima=\baselineskip
  \LARGE
  \baselineskip=\@tempdima
  \ifnum \c@secnumdepth >\m@ne
    \headfont\prepartname\thepart\postpartname
  \fi
  \hskip 1\zh
  \headfont#2\par}%
  \nobreak\vskip 1.5\baselineskip\@afterheading}
\newcommand{\@spart}[1]{{%
  \parindent\z@\raggedright
  \interlinepenalty\@M\reset@font
  \hskip4\zh\LARGE\headfont#1\par}%
  \nobreak\vskip1.5\baselineskip\@afterheading}

% 3行取り
\newcommand{\section}{\@startsection{section}{1}{6\jlreq@normalsize@zenkaku@height}%
   {\baselineskip}%
   {\baselineskip}%
   {\reset@font\@tempdima=\baselineskip\Large\baselineskip=\@tempdima\headfont}}

% 2行取り
\newcommand{\subsection}{\@startsection{subsection}{2}{8\jlreq@normalsize@zenkaku@height}%
   {.5\baselineskip}%
   {.5\baselineskip}%
   {\reset@font\@tempdima=\baselineskip\large\baselineskip=\@tempdima\headfont}}

% 1行あけ
\newcommand{\subsubsection}{\@startsection{subsubsection}{3}{10\jlreq@normalsize@zenkaku@height}%
   {\baselineskip}%
   {0.00001pt}%
   {\reset@font\normalsize\headfont}}

% 同行見出し
\newcommand{\paragraph}{\@startsection{paragraph}{4}{1\zh}%
  {0pt}%
  {-1\zh}%
  {\reset@font\normalsize\bfseries}}
\newcommand{\subparagraph}{\@startsection{subparagraph}{5}{1\zh}%
  {0pt}%
  {-1\zh}%
  {\reset@font\normalsize\headfont}}

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
\RequirePackage[savepos]{zref}
\newcount\jlreq@rest@linewidth@count
\jlreq@rest@linewidth@count=0
% 計算結果を返すための変数
\newdimen\jlreq@resultdimen
\newbox\jlreq@resultbox

\newdimen\jlreq@tempdima
\newdimen\jlreq@tempdimb
\newdimen\jlreq@tempdimc
% 現在行の残りを得る．
% 以下のコードはおかしい．
\newcommand{\jlreq@rest@linewidth}{%
  \dimexpr
  \linewidth + \@totalleftmargin + 
  \ifodd\zref@extractdefault{jlreq@rest@width.page.\the\jlreq@rest@linewidth@count}{page}{\c@page}%
    \oddsidemargin
  \else
    \evensidemargin
  \fi
  + 1in + \hoffset - \zposx{jlreq@rest@width.pos.\the\jlreq@rest@linewidth@count} sp\relax
}

% この命令以降，次にこの命令を実行する前まで\jlreq@rest@linewidthで
% この場所における残り長さが取得できる．
\newcommand{\jlreq@savepos@for@rest@linewidth}{%
  \advance\jlreq@rest@linewidth@count by 1\relax
  \zsavepos{jlreq@rest@width.pos.\the\jlreq@rest@linewidth@count}%
  \zref@labelbyprops{jlreq@rest@width.page.\the\jlreq@rest@linewidth@count}{page}%
}

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
\newcommand{\warichu}{%
  \ifjlreq@inwarichu\ClassError{tjlreq}{\string\warichu\space can't be nested!}\fi
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
    \jlreq@warichu@determinelength{#1}{\jlreq@parshapearg}{\@tempb}{\jlreq@tempdimc}{\jlreq@tempdimb}%
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
            \raise-.5\zw\hbox to \jlreq@tempdima{\vbox{%
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
x}

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
    \jlreq@warichu@determinelength{#1}{}{2}{\jlreq@tempdimc}{\maxdimen}%
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
  {\jlreq@warichu@kakkofontsize\hbox to .5\zh{）}}%
}

\newbox\jlreq@tempboxa
\newbox\jlreq@tempboxb
% \jlreq@warichu@determinelength{テキスト}{\parshape指定}{成功行数}{最小長さ}{最大長さ}
% \jlreq@resultboxに整形結果を返す．見つからなかったらvoid
\newcommand{\jlreq@warichu@determinelength}[5]{%
%  \message{#1 の試行開始，行数 = #3, \the#4 から \the#5まで}%
  \@tempcnta=0\relax
  \jlreq@tempdima=#4\relax
  % 最後の行を少しずつ伸ばしていく
  \@whilenum\@tempcnta<1000\do{%
    \ifnum\@tempcnta>999\relax% ループが長すぎる
      \global\setbox\jlreq@resultbox=\voidb@x%
      \@tempcnta=1001\relax
    \else
      \setbox\@tempboxa=\vbox{%
        \jlreq@warichu@fontsize
        \vbadness=10000\hbadness=10000\vfuzz=\maxdimen\hfuzz=\maxdimen
        \parindent=0pt\leftskip=0pt\rightskip=0pt\relax
        \parshape #3 #2 0pt \the\jlreq@tempdima 0pt \the\maxdimen
        #1\par\global\@tempcntb=\prevgraf}%
%      \message{\string\jlreq@tempdima = \the\jlreq@tempdima で試行，行数は\the\@tempcntb , 書式 #3 #2 0pt \the\jlreq@tempdima 0pt \the\maxdimen}%
    \fi
    \jlreq@getlastbox{\@tempboxa}%
    \setbox\jlreq@tempboxa=\box\jlreq@resultbox
    \ifnum\@tempcntb<#3\relax% 行数が達していないならOK
%      \message{行数 = \the\@tempcntb により確定}
      \global\setbox\jlreq@resultbox=\vbox{\jlreq@warichu@fontsize
        \unvbox\@tempboxa\hbox{\unhbox\jlreq@tempboxa\unskip\unskip\unpenalty}%
        \@whilenum\@tempcntb<#3\do{\hbox{}\advance\@tempcntb by 1}}%
      \@tempcnta=1001\relax
    \else
      % そうでない場合は最後の二行の長さを比較する
      \jlreq@getlastbox{\@tempboxa}%
      \setbox\jlreq@tempboxb=\box\jlreq@resultbox
%      \message{最終行の長さ \the\wd\jlreq@tempboxa, その前の長さ \the\wd\jlreq@tempboxb]]}%
      \ifdim\wd\jlreq@tempboxa>\wd\jlreq@tempboxb
        \advance\jlreq@tempdima by 0.3pt\relax
      \else
        % 後ろが短いのでOK
        \global\setbox\jlreq@resultbox=\vbox{\jlreq@warichu@fontsize
          \unvbox\@tempboxa\box\jlreq@tempboxb\box\jlreq@tempboxa}%
        \jlreq@resultdimen=\jlreq@tempdima
        \@tempcnta=1001\relax
      \fi
    \fi
    \ifdim\jlreq@tempdima>#5\relax
      \global\setbox\jlreq@resultbox=\box\voidb@x%
      \@tempcnta=1001\relax
    \fi
    \advance\@tempcnta by 1\relax
  }%
}

% vbox #1の最後を\jlreq@resultboxに入れる
% #1の最後の行は消える
\newcommand{\jlreq@getlastbox}[1]{%
  \setbox#1=\vbox{\jlreq@warichu@fontsize\unvbox#1\relax
    \unskip\unskip\unpenalty\global\setbox\jlreq@resultbox=\lastbox}%
  \ifhbox\jlreq@resultbox
    \global\setbox\jlreq@resultbox=\hbox{%
      \jlreq@warichu@fontsize
      \unhbox\jlreq@resultbox\unskip\unskip\unpenalty}%
  \else
    \global\setbox\jlreq@resultbox=\box\voidb@x
  \fi
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


