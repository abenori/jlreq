#!/bin/sh
# jlreq pdfTeXバックエンド テスト一括実行（docs/pdftex-tests.md の手順を自動化）。
#
# 使い方: sh tests/run-pdftex-tests.sh
#
# 実行設計（基準と失敗判定）:
#   - 実行ごとに mktemp -d で隔離されたベースディレクトリを作り、
#     各 (section, fixture, engine, pass) に個別サブディレクトリを与える。
#     各コンパイルは -output-directory=<そのdir> で実行する。ログ・PDFは
#     すべてそこに残り、失敗行は該当ログのパスを必ず示す。
#   - 冒頭で make pdftex-fonts を実行し、TeX Live のフォントから
#     補助縦フォント・HaranoAji 横組変換 TTF を生成する
#     （リポジトリにフォントバイナリは無い。生成失敗は FAIL）。
#   - T0 プリフライト: 必須資源（JFM .def 12種+manifest、バックエンド
#     .sty（rules/ruby/paragraph）、trimmarks .def、フォントプロファイル
#     .def×3、補助縦シャード、HaranoAji 横組TTF×4、zhmetrics 動的TFM、
#     ipxm/ipxg、cmtt9）を検査し、欠損は SKIP ではなく FAIL
#     （欠損ファイル名を明示）。
#   - T7 はコンパイル成立 + バックエンド非読込に加えて、コミット済み
#     ベースライン（tests/reference/baselines/、実装前に固定条件で
#     記録した p/u DVI・l PDF の正規化バイト）とのバイト比較を行う。
#     差分は全件 FAIL。再記録には明示的な承認が必要（README.md 参照）。
#   - 既知不良ゲート（XFAIL）: KNOWN_DEFECTS に列挙した検査は
#     「今日失敗するべきもの」。失敗は XFAIL と数え、デフォルトでは
#     全体 rc に影響しない（実装キャンペーン中は green-with-xfails）。
#     成功した場合は XPASS とし、非0で終了して昇格手順を指示する。
#     KNOWN_DEFECT_EXPECT=<name> を渡すと期待値反転検証に使える。
#   - 自己申告型検査は廃止済み: trimmarks-banner は実PDFの幾何検査
#     （tests/check-banner-slots.py）、pdflatex-tate-pairs はsmokeのみ
#     （T1 の JFM .def 等価性検査が実値検証を担うため、循環ログ判定は
#     成功基準から外した）。
#   - T12 staged install smoke: make install を一時 TEXMF へ行い、
#     リポジトリ外 cwd から -no-shell-escape で yoko/tate 両文書を
#     staged TDS だけからコンパイル。shell-out 証跡 0 件・抽出照合。
#
# 出力: 各検査の PASS/FAIL/XFAIL/XPASS と最終サマリ。作業ディレクトリは
# 実行ごとの mktemp -d（先頭行にパスを表示）。

cd "$(dirname "$0")/.." || exit 1

# 補助縦フォント（aux TTF/TFM/enc）とフォントプロファイルは
# fonts/pdftex/ に配置される。pdfTeX の mapline 資源解決は kpathsea
# （TEXFONTS/TEXENCS）で行うため、repo root からの実行で見えるように
# 先頭で一度だけ設定する（POSIX sh; 上書きではなく追記）。
PDFTEX_AUX_FONT_DIR="$(pwd)/fonts/pdftex"
if [ -d "$PDFTEX_AUX_FONT_DIR" ]; then
  TEXFONTS="${TEXFONTS:+$TEXFONTS}${PDFTEX_AUX_FONT_DIR}:"
  TEXENCS="${TEXENCS:+$TEXENCS}${PDFTEX_AUX_FONT_DIR}:"
  export TEXFONTS TEXENCS
fi

# ---------------------------------------------------------------------------
# 集計変数
# ---------------------------------------------------------------------------
FAILED=0
XFAILED=0
XPASSED=0
XFAIL_NAMES=""
XPASS_NAMES=""

# 既知不良リスト（単一の真実源）。ここに名前を足した検査は「今日は失敗が
# 期待される」: 失敗 → XFAIL（rc 影響なし）、成功 → XPASS（非0+昇格指示）。
# 実装が不良を直したら、そのフェーズでここから削除し通常検査へ移すこと。
KNOWN_DEFECTS=""

# 既知不良検査の期待値反転用: KNOWN_DEFECT_EXPECT=<name> を設定すると、
# その検査だけ「成功が期待値」となり、失敗時に非0を返す（検査そのものの
# 動作確認・将来のXFAIL戻し入れ時に使う）。
expect_xfail() {
  case " $KNOWN_DEFECT_EXPECT " in
    *" $1 "*) return 0;;
    *) return 1;;
  esac
}

is_known_defect() {
  case " $KNOWN_DEFECTS " in
    *" $1 "*) return 0;;
    *) return 1;;
  esac
}

# ---------------------------------------------------------------------------
# 隔離された実行ディレクトリ
# ---------------------------------------------------------------------------
OUT=$(mktemp -d "${TMPDIR:-/tmp}/jlreq-tests.XXXXXXXX") || {
  echo "FAIL: cannot create temp dir"; exit 1; }
echo "workdir: $OUT"

# outdir_for <group> <name> [<pass>]: (engine,)fixture,pass 別のサブディレ
# クトリ。グループ名は衝突しない短名（t3-rules など）。
outdir_for() {
  _d="$OUT/$1/$2"
  [ $# -ge 3 ] && _d="$_d/$3"
  mkdir -p "$_d" || exit 1
  printf '%s' "$_d"
}

# fail <name> <logpath>: 失敗を数え、ログのパスを明示
fail() {
  echo "FAIL: $1 (see $2)"
  FAILED=$((FAILED+1))
}

# pass <name>
pass() {
  echo "PASS: $1"
}

# verdict <name> <logpath> <rc 0|1>: 検査結果を既知不良管理に従って分類
#   rc=0 かつ既知不良 → XPASS（非0+昇格指示）
#   rc!=0 かつ既知不良 → XFAIL（rc 影響なし）
#   それ以外は通常 PASS/FAIL
verdict() {
  _name=$1; _log=$2; _rc=$3
  if is_known_defect "$_name"; then
    if [ "$_rc" -eq 0 ]; then
      echo "XPASS: $_name (known defect appears FIXED — promotion required)"
      echo "  PROMOTE: remove '$_name' from KNOWN_DEFECTS in tests/run-pdftex-tests.sh,"
      echo "  move its check into the corresponding normal section, and update"
      echo "  docs/pdftex-tests.md. Until then the suite exits non-zero."
      XPASSED=$((XPASSED+1))
      XPASS_NAMES="$XPASS_NAMES $_name"
    else
      echo "XFAIL: $_name (known defect still present, see $_log)"
      XFAILED=$((XFAILED+1))
      XFAIL_NAMES="$XFAIL_NAMES $_name"
    fi
  elif [ "$_rc" -eq 0 ]; then
    pass "$_name"
  else
    fail "$_name" "$_log"
  fi
}

# run_compile <name> <outdir> <engine> <file...>: コンパイルを実行し rc を
# 返す。固定日時 SOURCE_DATE_EPOCH=1735689600、-interaction=nonstopmode
# -halt-on-error -output-directory=<outdir> は全呼出しで共通（pdflatex
# 起動フラグは既存スイートと同一; boxdump のみ例外的に -halt-on-error
# なしで直接呼ぶ）。<name> は互換のため受け取るだけで使用しない。
run_compile() {
  _name=$1; _dir=$2; _eng=$3; shift 3
  SOURCE_DATE_EPOCH=1735689600 "$_eng" -interaction=nonstopmode \
    -halt-on-error -output-directory="$_dir" "$@" >"$_dir/compile.out" 2>&1
}

# run <name> <outdir> <engine> <file...>: コンパイル成功のみを検査する
# 最小ヘルパ（verdict は付かない; 既知不良管理が必要な検査は verdict を
# 直接使う）。
run() {
  _name=$1; _dir=$2; _eng=$3; shift 3
  if run_compile "$_name" "$_dir" "$_eng" "$@"; then
    pass "$_name"
  else
    fail "$_name" "$_dir/compile.out"
  fi
}

# ===========================================================================
# フォント資源はコミットされていない（make pdftex-fonts が TeX Live の
# フォントから生成する。生成の要否はタイムスタンプで make が判断する）。
if ! make pdftex-fonts >"$OUT/pdftex-fonts.out" 2>&1; then
  fail "pdftex-fonts" "$OUT/pdftex-fonts.out"
fi

echo "== T0: プリフライト（必須資源の検査; 欠損はSKIPではなくFAIL） =="
# ===========================================================================
T0_MISSING=""
# JFM .def 12組: pdftex-jfm-manifest.lua（唯一の一覧とする生成
# manifest）から .def ファイル名を抽出する。manifest が読めない場合は
# それ自体が FAIL（下の必須チェックで拾う）。
T0_JFM_DEFS=$(sed -n 's/.*file[[:space:]]*=[[:space:]]*"\(jlreq-pdftex-jfm[^"]*\.def\)".*/\1/p' \
  pdftex-jfm-manifest.lua 2>/dev/null | sort -u)
T0_JFM_COUNT=$(printf '%s\n' $T0_JFM_DEFS | grep -c '\.def$' || true)
if [ "$T0_JFM_COUNT" -ne 12 ]; then
  echo "FAIL: T0-preflight manifest yields $T0_JFM_COUNT JFM defs (want 12) from pdftex-jfm-manifest.lua"
  FAILED=$((FAILED+1))
fi
for f in $T0_JFM_DEFS \
         pdftex-jfm-manifest.lua \
         jlreq-pdftex.sty jlreq-pdftex-rules.sty jlreq-pdftex-ruby.sty \
         jlreq-pdftex-paragraph.sty \
         jlreq-trimmarks-pdftex.def jlreq.cls; do
  [ -f "$f" ] || T0_MISSING="$T0_MISSING $f"
done
# フォントプロファイル（両組）と第1シャードの aux 縦フォント資源
# （profile .def + TFM/enc/TTF）は縦組みの必須資源。fonts/pdftex/ は
# `make pdftex-fonts` の出力先（ビルド成果物）。
for f in fonts/pdftex/jlreq-pdftex-fonts-ipaex.def \
         fonts/pdftex/jlreq-pdftex-fonts-ipa.def \
         fonts/pdftex/jlreq-pdftex-fonts-haranoaji.def \
         fonts/pdftex/haranoaji-mincho-ttf.ttf \
         fonts/pdftex/haranoaji-mincho-bold-ttf.ttf \
         fonts/pdftex/haranoaji-gothic-ttf.ttf \
         fonts/pdftex/haranoaji-gothic-bold-ttf.ttf \
         fonts/pdftex/jlreqv-ipaex-mc-00.tfm fonts/pdftex/jlreqv-ipaex-mc-00.enc \
         fonts/pdftex/jlreqv-ipaex-mc-00.ttf fonts/pdftex/jlreqv-ipaex-mc-01.tfm \
         fonts/pdftex/jlreqv-ipaex-mc-01.enc fonts/pdftex/jlreqv-ipaex-mc-01.ttf \
         fonts/pdftex/jlreqv-ipaex-gt-00.tfm fonts/pdftex/jlreqv-ipaex-gt-00.enc \
         fonts/pdftex/jlreqv-ipaex-gt-00.ttf fonts/pdftex/jlreqv-ipaex-gt-01.tfm \
         fonts/pdftex/jlreqv-ipaex-gt-01.enc fonts/pdftex/jlreqv-ipaex-gt-01.ttf \
         fonts/pdftex/jlreqv-ipa-mc-00.tfm fonts/pdftex/jlreqv-ipa-mc-00.enc \
         fonts/pdftex/jlreqv-ipa-mc-00.ttf fonts/pdftex/jlreqv-ipa-mc-01.tfm \
         fonts/pdftex/jlreqv-ipa-mc-01.enc fonts/pdftex/jlreqv-ipa-mc-01.ttf \
         fonts/pdftex/jlreqv-ipa-gt-00.tfm fonts/pdftex/jlreqv-ipa-gt-00.enc \
         fonts/pdftex/jlreqv-ipa-gt-00.ttf fonts/pdftex/jlreqv-ipa-gt-01.tfm \
         fonts/pdftex/jlreqv-ipa-gt-01.enc fonts/pdftex/jlreqv-ipa-gt-01.ttf \
         fonts/pdftex/jlreqv-haranoaji-mc-00.tfm fonts/pdftex/jlreqv-haranoaji-mc-00.enc \
         fonts/pdftex/jlreqv-haranoaji-mc-00.ttf fonts/pdftex/jlreqv-haranoaji-mc-01.tfm \
         fonts/pdftex/jlreqv-haranoaji-mc-01.enc fonts/pdftex/jlreqv-haranoaji-mc-01.ttf \
         fonts/pdftex/jlreqv-haranoaji-mc-02.tfm fonts/pdftex/jlreqv-haranoaji-mc-02.enc \
         fonts/pdftex/jlreqv-haranoaji-mc-02.ttf fonts/pdftex/jlreqv-haranoaji-mc-03.tfm \
         fonts/pdftex/jlreqv-haranoaji-mc-03.enc fonts/pdftex/jlreqv-haranoaji-mc-03.ttf \
         fonts/pdftex/jlreqv-haranoaji-gt-00.tfm fonts/pdftex/jlreqv-haranoaji-gt-00.enc \
         fonts/pdftex/jlreqv-haranoaji-gt-00.ttf fonts/pdftex/jlreqv-haranoaji-gt-01.tfm \
         fonts/pdftex/jlreqv-haranoaji-gt-01.enc fonts/pdftex/jlreqv-haranoaji-gt-01.ttf \
         fonts/pdftex/jlreqv-haranoaji-gt-02.tfm fonts/pdftex/jlreqv-haranoaji-gt-02.enc \
         fonts/pdftex/jlreqv-haranoaji-gt-02.ttf fonts/pdftex/jlreqv-haranoaji-gt-03.tfm \
         fonts/pdftex/jlreqv-haranoaji-gt-03.enc fonts/pdftex/jlreqv-haranoaji-gt-03.ttf; do
  [ -f "$f" ] || T0_MISSING="$T0_MISSING $f"
done
for f in ipxm-r-u30.pfb ipxg-r-u30.pfb cmtt9.tfm; do
  kpsewhich "$f" >/dev/null 2>&1 || T0_MISSING="$T0_MISSING $f(kpsewhich)"
done
if [ -n "$T0_MISSING" ]; then
  echo "FAIL: T0-preflight missing required files:$T0_MISSING"
  FAILED=$((FAILED+1))
else
  pass "T0-preflight (JFM .def x12 + manifest, backend .sty x3, trimmarks .def, ipxm/ipxg fonts, cmtt9, font profiles + aux vert fonts x3 fontsets + haranoaji horizontal TTFs x4)"
fi

# ===========================================================================
echo "== T1: JFMデータ検証 =="
# ===========================================================================
d=$(outdir_for t1 jfm)
if make check-pdftex-jfm >"$d/check.out" 2>&1; then
  pass "check-jfm-diff (make check-pdftex-jfm)"
else
  fail "check-jfm-diff" "$d/check.out"
fi
if texlua check_jfm_pdftex.lua >"$d/check-full.out" 2>&1; then
  pass "check-jfm-full (texlua check_jfm_pdftex.lua)"
else
  fail "check-jfm-full" "$d/check-full.out"
fi

# ===========================================================================
echo "== T3/T4: 組版規則の実測 =="
# ===========================================================================
for f in tests/fixtures/pdflatex-rules/*.tex; do
  name=$(basename "$f" .tex)
  d=$(outdir_for t3-rules "$name")
  run "rules-$name" "$d" pdflatex "$f"
done
# pairs.tex: ログ内判定（全PASSであること）
d=$(outdir_for t3-rules pairs 2)
if pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" \
     tests/fixtures/pdflatex-rules/pairs.tex >"$d/compile.out" 2>&1 \
     && { ! grep -q '^FAIL' "$d/pairs.log" 2>/dev/null; } \
     && grep -q '^PASS' "$d/pairs.log" 2>/dev/null; then
  echo "PASS: rules-pairs-log-assertions ($(grep -c '^PASS' "$d/pairs.log") measurements)"
else
  fail "rules-pairs-log-assertions" "$d/compile.out"
fi
# endadjust.tex: Overfull 0件
d=$(outdir_for t3-rules endadjust 2)
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" \
  tests/fixtures/pdflatex-rules/endadjust.tex >"$d/compile.out" 2>&1
if grep -q 'Overfull' "$d/endadjust.log" 2>/dev/null; then
  fail "endadjust-overfull-check" "$d/endadjust.log"
else
  pass "endadjust-overfull-check"
fi
# hanging-punct.tex: ログ内判定（HANG-PASS/FAIL）
d=$(outdir_for t3-rules hanging-punct 2)
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" \
  tests/fixtures/pdflatex-rules/hanging-punct.tex >"$d/compile.out" 2>&1
if grep -q 'HANG-FAIL' "$d/hanging-punct.log" 2>/dev/null; then
  fail "hanging-punct-log-assertions" "$d/hanging-punct.log"
elif grep -q 'HANG-PASS' "$d/hanging-punct.log" 2>/dev/null; then
  echo "PASS: hanging-punct-log-assertions ($(grep -c 'HANG-PASS' "$d/hanging-punct.log") assertions)"
else
  fail "hanging-punct-log-assertions" "$d/hanging-punct.log"
fi
# 行頭禁則のbbox機械検証（閉じ約物が行頭に来ないこと; 5 fixtures）
k1=$(outdir_for t3-rules kinsoku pdf)
k2=$(outdir_for t3-rules punctuation-consecutive pdf)
k3=$(outdir_for t3-rules punct-width pdf)
k4=$(outdir_for t3-rules preclose-latin pdf)
k5=$(outdir_for t3-rules boundary-ja-la pdf)
if python3 tests/check-kinsoku.py "$k1"/kinsoku.pdf "$k2"/punctuation-consecutive.pdf \
     "$k3"/punct-width.pdf "$k4"/preclose-latin.pdf "$k5"/boundary-ja-la.pdf \
     >"$OUT/t3-rules/kinsoku-check.out" 2>&1; then
  pass "kinsoku-bbox-line-head-scan (5 fixtures)"
else
  fail "kinsoku-bbox-line-head-scan" "$OUT/t3-rules/kinsoku-check.out"
fi

# ---- T3b: 行末追込みの4エンジンparity（endadjust-lineend）----
# 行末追込みの addendadj 修正により parity は成立している
# （tests/reference/kinsoku-lines.md 訂正節参照）。通常ゲートとして
# 0.1pt で固定検査する（行末候補列再構成が参照から離れないため）。
d=$(outdir_for t3b endadjust-lineend pdflatex)
run_compile x "$d" pdflatex tests/fixtures/pdflatex-rules/endadjust-lineend.tex
dp_rc=$?
d=$(outdir_for t3b endadjust-lineend lualatex)
run_compile x "$d" lualatex tests/fixtures/pdflatex-rules/endadjust-lineend.tex
dl_rc=$?
d=$(outdir_for t3b endadjust-lineend platex)
run_compile x "$d" platex tests/fixtures/pdflatex-rules/endadjust-lineend.tex
dp2_rc=$?
dvipdfmx -o "$d/x.pdf" "$d/endadjust-lineend.dvi" >"$d/dvipdfmx.out" 2>&1
dp2_pdf=$?
d=$(outdir_for t3b endadjust-lineend uplatex)
run_compile x "$d" uplatex tests/fixtures/pdflatex-rules/endadjust-lineend.tex
du_rc=$?
dvipdfmx -o "$d/x.pdf" "$d/endadjust-lineend.dvi" >"$d/dvipdfmx.out" 2>&1
du_pdf=$?
t3b_log="$OUT/t3b/endadjust-lineend"
mkdir -p "$t3b_log"
if [ "$dp_rc" -ne 0 ] || [ "$dl_rc" -ne 0 ] || [ "$dp2_rc" -ne 0 ] \
   || [ "$du_rc" -ne 0 ] || [ "$dp2_pdf" -ne 0 ] || [ "$du_pdf" -ne 0 ]; then
  fail "endadjust-lineend-parity-compile" "$OUT/t3b/endadjust-lineend"
else
  if python3 tests/check-endadjust-parity.py \
       "$OUT/t3b/endadjust-lineend/pdflatex/endadjust-lineend.pdf" \
       "$OUT/t3b/endadjust-lineend/platex/x.pdf" \
       "$OUT/t3b/endadjust-lineend/uplatex/x.pdf" \
       "$OUT/t3b/endadjust-lineend/lualatex/endadjust-lineend.pdf" \
       >"$t3b_log/parity.out" 2>&1; then
    pass "endadjust-lineend-parity (4-engine line-1 xMax within 0.1pt)"
  else
    fail "endadjust-lineend-parity" "$t3b_log/parity.out"
  fi
fi

# ===========================================================================
echo "== T5: 文書フィクスチャ =="
# ===========================================================================
for f in tests/fixtures/pdflatex-mixed.tex tests/fixtures/pdflatex-bench/long.tex; do
  name=$(basename "$f" .tex)
  d=$(outdir_for t5-doc "$name")
  run "doc-$name" "$d" pdflatex "$f"
done
for f in tests/fixtures/pdflatex-coexist/*.tex; do
  name=$(basename "$f" .tex)
  # 昇格済みの2ゲート（today-wareki / label-japanese）は下の専用ブロック
  # が複数パス・チェック付きで検査するためここではコンパイルのみ行う。
  d=$(outdir_for t5-coexist "$name")
  run "coexist-$name" "$d" pdflatex "$f"
done
# ---- label・date・space: 昇格済みの通常ゲート ----
# label-packages: 3パス収束。3パスは同一 outdir で回す（aux を引き継ぐ）。
# 判定: 最終パスで「ラベル変更/Rerun」警告が出ないこと + 全面解決。
lp=$(outdir_for t5-coexist label-packages 3pass)
lp_rc=0
for passno in 1 2 3; do
  if ! run_compile x "$lp" pdflatex \
       tests/fixtures/pdflatex-coexist/label-packages.tex; then
    lp_rc=1
  fi
done
if grep -q 'Label(s) may have changed' \
     "$lp/label-packages.log" 2>/dev/null; then
  lp_rc=1
fi
if [ "$lp_rc" -ne 0 ]; then
  fail "label-packages-3pass" "$lp/compile.out"
else
  pass "label-packages-3pass"
fi
if python3 tests/check-label-packages.py "$lp/label-packages.pdf" \
     "$lp/label-packages.log" >"$lp/check.out" 2>&1; then
  pass "label-packages-matrix (ref/pageref*/eqref/autoref/nameref/cref/hyperref/refcount)"
else
  fail "label-packages-matrix" "$lp/check.out"
fi
# date-boundaries: 和暦5境界日 + 元年 + \西暦true/\和暦 切替
db=$(outdir_for t5-coexist date-boundaries 1)
if run_compile x "$db" pdflatex \
     tests/fixtures/pdflatex-coexist/date-boundaries.tex; then
  if python3 tests/check-date-boundaries.py "$db/date-boundaries.pdf" \
       >"$db/check.out" 2>&1; then
    pass "date-boundaries (5 era dates + gan-nen + style toggle)"
  else
    fail "date-boundaries" "$db/check.out"
  fi
else
  fail "date-boundaries" "$db/compile.out"
fi
# space-dispatcher: \　命令・literal U+3000・\jaspace の共存
sd=$(outdir_for t5-coexist space-dispatcher 1)
if run_compile x "$sd" pdflatex \
     tests/fixtures/pdflatex-coexist/space-dispatcher.tex; then
  if python3 tests/check-space-dispatcher.py "$sd/space-dispatcher.pdf" \
       >"$sd/check.out" 2>&1; then
    pass "space-dispatcher (command/literal/jaspace coexist)"
  else
    fail "space-dispatcher" "$sd/check.out"
  fi
else
  fail "space-dispatcher" "$sd/compile.out"
fi
# kanji-numbers.tex: ログ内判定
d=$(outdir_for t5-coexist kanji-numbers 2)
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" \
  tests/fixtures/pdflatex-coexist/kanji-numbers.tex >"$d/compile.out" 2>&1
if grep -q 'KANSUJI-FAIL' "$d/kanji-numbers.log" 2>/dev/null; then
  fail "kanji-numbers-log-assertions" "$d/kanji-numbers.log"
elif grep -q 'KANSUJI-PASS' "$d/kanji-numbers.log" 2>/dev/null; then
  echo "PASS: kanji-numbers-log-assertions ($(grep -c 'KANSUJI-PASS' "$d/kanji-numbers.log") assertions)"
else
  fail "kanji-numbers-log-assertions" "$d/kanji-numbers.log"
fi
# mag-tombow.tex: 描画座標の mag 不変性
d=$(outdir_for t5-coexist mag-tombow 2)
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" \
  tests/fixtures/pdflatex-coexist/mag-tombow.tex >"$d/compile.out" 2>&1
if python3 tests/check-tombow-mag.py "$d/mag-tombow.pdf" >"$d/tombow.out" 2>&1; then
  pass "tombow-mag1200-stream-parity"
else
  fail "tombow-mag1200-stream-parity" "$d/tombow.out"
fi
# trimmarks-banner.tex: 実PDFの幾何検証（自己申告 BANNER-PD-PASS は廃止）
d=$(outdir_for t5-coexist trimmarks-banner 2)
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" \
  tests/fixtures/pdflatex-coexist/trimmarks-banner.tex >"$d/compile.out" 2>&1
if python3 tests/check-banner-slots.py "$d/trimmarks-banner.pdf" \
     >"$d/banner.out" 2>&1; then
  pass "trimmarks-banner-geometry (6 slots, fixed windows, pymupdf)"
else
  fail "trimmarks-banner-geometry" "$d/banner.out"
fi
# trimmarks-twoside.tex: 奇偶ページ属性のshipout/beforeフック検証
#   - 各ページのTrimBox/BleedBoxがページ奇偶に従って分かれていること
#   - 旧\@outputpageのtl_putパッチで出ていた "Missing number" が無いこと
#   - dドライバからpapersize specialが出ないこと（"Non-PDF special
#     ignored!" がログに無いこと）
d=$(outdir_for t5-coexist trimmarks-twoside 1)
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" \
  tests/fixtures/pdflatex-coexist/trimmarks-twoside.tex >"$d/compile.out" 2>&1
tw_rc=$?
if grep -q 'Missing number' "$d/trimmarks-twoside.log" 2>/dev/null; then
  tw_rc=1
fi
if grep -q 'Non-PDF special ignored' "$d/trimmarks-twoside.log" 2>/dev/null; then
  tw_rc=1
fi
if [ "$tw_rc" -ne 0 ] \
   || ! python3 tests/check-trimmarks-pageattr.py "$d/trimmarks-twoside.pdf" \
        >"$d/pageattr.out" 2>&1; then
  fail "trimmarks-twoside-pageattr (shipout/before hook)" "$d/pageattr.out"
else
  pass "trimmarks-twoside-pageattr (shipout/before hook)"
fi
# trimmarks-tate-banner.tex: 縦組文書の回転バナースロットが
# uplatex ground truth（dvipdfmx経由・同一フィクスチャ実測）と
# 0.5pt以内で一致すること。20スロット（2ページ×10スロット族）。
d=$(outdir_for t5-coexist trimmarks-tate-banner 1)
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" \
  tests/fixtures/pdflatex-coexist/trimmarks-tate-banner.tex >"$d/compile.out" 2>&1
if python3 tests/check-banner-tate.py "$d/trimmarks-tate-banner.pdf" \
     >"$d/tatebanner.out" 2>&1; then
  pass "trimmarks-tate-banner-geometry (uplatex GT windows)"
else
  fail "trimmarks-tate-banner-geometry" "$d/tatebanner.out"
fi
# reference-mark-interlinear.tex: ログ内判定（INTER-PASS x3）
d=$(outdir_for t5-coexist reference-mark-interlinear 2)
pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" \
  tests/fixtures/pdflatex-coexist/reference-mark-interlinear.tex >"$d/compile.out" 2>&1
n_inter=$(grep -c 'INTER-PASS' "$d/reference-mark-interlinear.log" 2>/dev/null)
n_inter=${n_inter:-0}
if grep -q 'INTER-FAIL' "$d/reference-mark-interlinear.log" 2>/dev/null \
   || [ "$n_inter" -ne 3 ]; then
  fail "interlinear-log-assertions" "$d/reference-mark-interlinear.log"
else
  pass "interlinear-log-assertions (3 assertions)"
fi
# ===========================================================================
echo "== T11: strict paragraph jlreqparagraph =="
# ===========================================================================
# strict-basic: スナップショット一致 + 多行 + 連続環境（STRICT-PASS/FAIL）
d=$(outdir_for t11 strict-basic)
run_compile x "$d" pdflatex tests/fixtures/pdflatex-paragraph/strict-basic.tex
sb_rc=$?
if grep -q 'STRICT-FAIL' "$d/strict-basic.log" 2>/dev/null; then
  fail "strict-basic-snapshot-multiline" "$d/strict-basic.log"
elif [ "$sb_rc" -ne 0 ]; then
  fail "strict-basic-snapshot-multiline" "$d/compile.out"
else
  pass "strict-basic-snapshot-multiline (snapshot + multiline + consecutive envs)"
fi
if grep -qE 'Overfull|Underfull' "$d/strict-basic.log" 2>/dev/null; then
  fail "strict-basic-overfull-check" "$d/strict-basic.log"
else
  pass "strict-basic-overfull-check"
fi
# strict-inputmodel: 許可構成要素すべて（INM-PASS/FAIL + エラー0）
d=$(outdir_for t11 strict-inputmodel)
run_compile x "$d" pdflatex tests/fixtures/pdflatex-paragraph/strict-inputmodel.tex
im_rc=$?
if grep -q 'INM-FAIL' "$d/strict-inputmodel.log" 2>/dev/null \
   || [ "$im_rc" -ne 0 ]; then
  fail "strict-inputmodel-matrix" "$d/compile.out"
else
  pass "strict-inputmodel-matrix (CJK/word/space/inhibitglue/hspace/kern/penalty/allowbreak/math/mbox/makebox/label/hyperlink)"
fi
# strict-errors: 禁止構成要素の具体的エラー文言（halt なしで実行）
d=$(outdir_for t11 strict-errors)
pdflatex -interaction=nonstopmode -output-directory="$d" \
  tests/fixtures/pdflatex-paragraph/strict-errors.tex >"$d/compile.out" 2>&1
if grep -q 'footnote~is~not~allowed~inside' \
     "$d/strict-errors.log" 2>/dev/null \
   && grep -q 'display~math~is~not~allowed~inside' \
     "$d/strict-errors.log" 2>/dev/null \
   && grep -q 'Undefined control sequence' \
     "$d/strict-errors.log" 2>/dev/null; then
  pass "strict-errors-forbidden-constructs (footnote/display-math specific errors + unknown macro)"
else
  fail "strict-errors-forbidden-constructs" "$d/strict-errors.log"
fi
# strict-integration: 非ゼロ rightskip/parskip・looseness・emergencystretch・
# parshape・前後接続（INTEG-PASS/FAIL）
d=$(outdir_for t11 strict-integration)
run_compile x "$d" pdflatex tests/fixtures/pdflatex-paragraph/strict-integration.tex
ig_rc=$?
if grep -q 'INTEG-FAIL' "$d/strict-integration.log" 2>/dev/null \
   || [ "$ig_rc" -ne 0 ]; then
  fail "strict-integration-params-continuity" "$d/compile.out"
else
  pass "strict-integration-params-continuity (rightskip/parskip/parshape/continuity)"
fi
if grep -qE 'Overfull|Underfull' "$d/strict-integration.log" 2>/dev/null; then
  fail "strict-integration-overfull-check" "$d/strict-integration.log"
else
  pass "strict-integration-overfull-check"
fi
# strict-tate: 縦組みでの厳密段落（TATE-STRICT-PASS + エラー0）
d=$(outdir_for t11 strict-tate)
run_compile x "$d" pdflatex tests/fixtures/pdflatex-paragraph/strict-tate.tex
tt_rc=$?
if grep -q 'TATE-STRICT-FAIL' "$d/strict-tate.log" 2>/dev/null \
   || [ "$tt_rc" -ne 0 ] \
   || ! grep -q 'TATE-STRICT-PASS' "$d/strict-tate.log" 2>/dev/null; then
  fail "strict-tate-environment" "$d/compile.out"
else
  pass "strict-tate-environment (tate strict paragraph)"
fi
# strict-tierdiff: 2-tier差の実証（計画の検証行「2tier以上でnative一括
# 伸縮と差が出る例」）-- tier-50 の明示グルーが需要を全量受け、
# それ以外の tier（kanjiskip 0 / JFM pair -10）は 0。RBWD 再構成幅
# 照合（1sp 以内）もこの fixture で検査する。
d=$(outdir_for t11 strict-tierdiff)
run_compile x "$d" pdflatex tests/fixtures/pdflatex-paragraph/strict-tierdiff.tex
td_rc=$?
# (a) the explicit tier-50 hspace glue (30pt stretch spec) received a
#     NONZERO delta
if ! grep -qE 'TIERTOP: line=1 gk=[0-9]+ *delta=[0-9.]+pt[^0]' \
     "$d/strict-tierdiff.log" 2>/dev/null; then
  fail "strict-tierdiff-explicit-share" "$d/strict-tierdiff.log"
else
  pass "strict-tierdiff-explicit-share (tier-50 glue takes the whole stretch)"
fi
# (b) every OTHER glue got exactly 0 (tier order: lower tiers unfilled).
#     POSIX pipelines (the runner is #!/bin/sh -- no process subst).
if grep -a 'TIERTOP' "$d/strict-tierdiff.log" 2>/dev/null \
     | grep -v 'GI={0.0pt}{30.0pt}' | grep -v 'delta=0pt' \
     | grep -q TIERTOP; then
  fail "strict-tierdiff-lower-tiers-zero" "$d/strict-tierdiff.log"
else
  pass "strict-tierdiff-lower-tiers-zero (kanjiskip/JFM tiers receive 0)"
fi
# (c) compile rc + rebuilt line width matches the measured width
#     within 1sp (RBWD VERDICT=OK on every line)
if [ "$td_rc" -ne 0 ] \
   || grep -q 'VERDICT=DIFF' "$d/strict-tierdiff.log" 2>/dev/null \
   || ! grep -q 'VERDICT=OK' "$d/strict-tierdiff.log" 2>/dev/null; then
  fail "strict-tierdiff-rebuild-width" "$d/strict-tierdiff.log"
else
  pass "strict-tierdiff-rebuild-width (RBWD delta within 1sp, all lines)"
fi
if grep -qE 'Overfull|Underfull' "$d/strict-tierdiff.log" 2>/dev/null; then
  fail "strict-tierdiff-overfull-check" "$d/strict-tierdiff.log"
else
  pass "strict-tierdiff-overfull-check"
fi
# strict-finalsel: aw_step1_last -- the final line's end_adjust
# candidate RE-CHOSEN by the parfillskip condition differs from the
# native choice (FINS log: native-e=0.0pt win-e=5.0pt slack=0.0pt)
d=$(outdir_for t11 strict-finalsel)
run_compile x "$d" pdflatex tests/fixtures/pdflatex-paragraph/strict-finalsel.tex
fs_rc=$?
if [ "$fs_rc" -ne 0 ] \
   || ! grep -q 'FINS: native-e=0.0pt win-e=5.0pt' \
     "$d/strict-finalsel.log" 2>/dev/null \
   || grep -q 'VERDICT=DIFF' "$d/strict-finalsel.log" 2>/dev/null; then
  fail "strict-finalsel-aw-step1-last" "$d/strict-finalsel.log"
else
  pass "strict-finalsel-aw-step1-last (parfill re-selection differs from native: e=0 -> e=5pt)"
fi
if grep -qE 'Overfull|Underfull' "$d/strict-finalsel.log" 2>/dev/null; then
  fail "strict-finalsel-overfull-check" "$d/strict-finalsel.log"
else
  pass "strict-finalsel-overfull-check"
fi
# ===========================================================================
echo "== T5b: wareki today / Japanese label（昇格済み: 通常ゲート）=="
# ===========================================================================
# today-wareki: pdflatex 対 lualatex 参照（同一ソース・固定日時）
tw_d=$(outdir_for t5b today-wareki pdflatex)
tw_l=$(outdir_for t5b today-wareki lualatex)
tw_rc=0
if ! run_compile x "$tw_d" pdflatex \
     tests/fixtures/pdflatex-coexist/today-wareki.tex; then
  tw_rc=1
fi
if ! run_compile x "$tw_l" lualatex \
     tests/fixtures/pdflatex-coexist/today-wareki.tex; then
  tw_rc=1
fi
python3 tests/check-today-wareki.py "$tw_d/today-wareki.pdf" \
     "$tw_l/today-wareki.pdf" >"$OUT/t5b/today-wareki/check.out" 2>&1
tw_check=$?
if [ "$tw_rc" -ne 0 ] || [ "$tw_check" -ne 0 ]; then tw_result=1; else tw_result=0; fi
if expect_xfail today-wareki; then
  # 期待値反転モード: 成功が正、失敗は FAIL
  if [ "$tw_result" -eq 0 ]; then pass "today-wareki"; else
    fail "today-wareki" "$OUT/t5b/today-wareki/check.out"; fi
else
  verdict "today-wareki" "$OUT/t5b/today-wareki/check.out" "$tw_result"
fi

# label-japanese: 2パス・aux検査・lualatex 参照
lj_d=$(outdir_for t5b label-japanese pdflatex)
lj_l=$(outdir_for t5b label-japanese lualatex)
lj_rc=0
for passno in 1 2; do
  if ! run_compile x "$lj_d" pdflatex \
       tests/fixtures/pdflatex-coexist/label-japanese.tex; then
    lj_rc=1
  fi
  if ! run_compile x "$lj_l" lualatex \
       tests/fixtures/pdflatex-coexist/label-japanese.tex; then
    lj_rc=1
  fi
done
python3 tests/check-label-japanese.py "$lj_d/label-japanese.pdf" \
     "$lj_d/label-japanese.aux" "$lj_l/label-japanese.pdf" \
     >"$OUT/t5b/label-japanese/check.out" 2>&1
lj_check=$?
if [ "$lj_rc" -ne 0 ] || [ "$lj_check" -ne 0 ]; then lj_result=1; else lj_result=0; fi
if expect_xfail label-japanese; then
  if [ "$lj_result" -eq 0 ]; then pass "label-japanese"; else
    fail "label-japanese" "$OUT/t5b/label-japanese/check.out"; fi
else
  verdict "label-japanese" "$OUT/t5b/label-japanese/check.out" "$lj_result"
fi

# ===========================================================================
echo "== T7: 3エンジン回帰（コンパイル + バックエンド非読込 + ベースライン照合）=="
# ===========================================================================
for f in tests/fixtures/basic-mixed.tex tests/fixtures/math-japanese.tex \
         tests/fixtures/tate-vertical.tex; do
  name=$(basename "$f" .tex)
  for e in platex uplatex lualatex; do
    d=$(outdir_for t7 "$name" "$e")
    run "reg-$name-$e" "$d" "$e" "$f"
    # バックエンドが読み込まれていないこと
    if grep -q 'jlreq-pdftex' "$d/$name.log" 2>/dev/null; then
      fail "reg-$name-$e-backend-isolation" "$d/$name.log"
    else
      pass "reg-$name-$e-backend-isolation"
    fi
    # ベースライン照合（実装前に記録した正規化バイトとの比較）
    if [ $e = lualatex ]; then ext=pdf; else ext=dvi; fi
    base="tests/reference/baselines/$e/$name.$ext"
    if [ ! -f "$base" ]; then
      fail "reg-$name-$e-baseline (missing baseline $base)" "$base"
      continue
    fi
    python3 tests/normalize-output.py "$ext" "$d/$name.$ext" >"$d/normalized.$ext" 2>"$d/normalize.err" \
      || { fail "reg-$name-$e-baseline (normalize error)" "$d/normalize.err"; continue; }
    if cmp -s "$d/normalized.$ext" "$base"; then
      pass "reg-$name-$e-baseline (byte-identical to pre-implementation record)"
    else
      echo "FAIL: reg-$name-$e-baseline (output differs from baseline; see $d/normalized.$ext vs $base)" >&2
      FAILED=$((FAILED+1))
    fi
  done
done

# \jidori/\akigumi は4エンジンで定義必須（l/u/p側の定義喪失回帰ガード）。
for e in platex uplatex lualatex; do
  d=$(outdir_for t7 jidori-akigumi "$e")
  run "reg-jidori-$e" "$d" "$e" tests/fixtures/pdflatex-rules/jidori-akigumi.tex
done

# ===========================================================================
echo "== T8: pdfTeX 縦組み（shipout rotation; tate .def 欠損はFAIL）=="
# ===========================================================================
# tate JFM データは必須資源（T0 で検査済み。ここでは欠けていたら即FAIL）。
if [ ! -f jlreq-pdftex-jfm-tate.def ]; then
  fail "tate-fixtures" "jlreq-pdftex-jfm-tate.def"
else
  # pdflatex+tate はエラーにならない（回転出荷アーキテクチャ + 情報行）
  d=$(outdir_for t8 tate-ok)
  printf '\\documentclass[pdflatex,tate]{jlreq}\n\\begin{document}あ\\end{document}' >"$d/tate-ok.tex"
  if pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$d" \
       "$d/tate-ok.tex" >"$d/compile.out" 2>&1 \
     && grep -q 'pdfTeX tate support: shipout-rotation architecture' "$d/tate-ok.log" 2>/dev/null; then
    pass "tate-option-compiles-with-info"
  else
    fail "tate-option-compiles-with-info" "$d/compile.out"
  fi
  # tate fixtures: コンパイル + ログ内 TATE-PASS 判定
  #   pdflatex-tate-pairs.tex はsmokeのみ（期待値と実値が同じペア表を読む
  #   循環検査であるため成功基準から外した。実値検証は T1 の JFM .def
  #   等価性検査 check_jfm_pdftex.lua が担う）。ここではコンパイル成立のみ。
  for f in tests/fixtures/pdflatex-tate-basic.tex tests/fixtures/pdflatex-tate-pairs.tex; do
    name=$(basename "$f" .tex)
    d=$(outdir_for t8 "$name")
    run "tate-$name" "$d" pdflatex "$f"
    case $name in
      pdflatex-tate-pairs)
        # smoke: ログ内判定は循環検査のため成功基準に含めない
        ;;
      *)
        if grep -q 'TATE-FAIL' "$d/$name.log" 2>/dev/null; then
          fail "$name-log-assertions" "$d/$name.log"
        elif grep -q 'TATE-PASS' "$d/$name.log" 2>/dev/null; then
          echo "PASS: $name-log-assertions ($(grep -c 'TATE-PASS' "$d/$name.log") assertions)"
        else
          fail "$name-log-assertions" "$d/$name.log"
        fi
        ;;
    esac
  done
  # T3: 注（脚注/後注/傍注）と浮遊体の縦組みフィクスチャ
  for f in tests/fixtures/pdflatex-tate-notes.tex tests/fixtures/pdflatex-tate-float.tex; do
    name=$(basename "$f" .tex)
    d=$(outdir_for t8 "$name")
    run "tate-$name" "$d" pdflatex "$f"
    if grep -q 'TATE-FAIL' "$d/$name.log" 2>/dev/null; then
      fail "$name-log-assertions" "$d/$name.log"
    elif grep -q 'TATE-PASS' "$d/$name.log" 2>/dev/null; then
      echo "PASS: $name-log-assertions ($(grep -c 'TATE-PASS' "$d/$name.log") assertions)"
    else
      fail "$name-log-assertions" "$d/$name.log"
    fi
  done
  # 局所方向・縦中横フィクスチャ（dir-* / tcy-*）
  #   tcy-star-error は意図的な ClassError を含むため -halt-on-error
  #   なしで実行し、ログ内 TATE-PASS とエラー文言の両方を検査する。
  for f in tests/fixtures/pdflatex-tate/dir-roundtrip.tex \
           tests/fixtures/pdflatex-tate/dir-callers.tex \
           tests/fixtures/pdflatex-tate/dir-index-yoko.tex \
           tests/fixtures/pdflatex-tate/tcy-digits.tex \
           tests/fixtures/pdflatex-tate/tcy-fontchange.tex; do
    name=$(basename "$f" .tex)
    d=$(outdir_for t8 "$name")
    run "tate-$name" "$d" pdflatex "$f"
    if grep -q 'TATE-FAIL' "$d/$name.log" 2>/dev/null; then
      fail "$name-log-assertions" "$d/$name.log"
    elif grep -q 'TATE-PASS' "$d/$name.log" 2>/dev/null; then
      echo "PASS: $name-log-assertions ($(grep -c 'TATE-PASS' "$d/$name.log") assertions)"
    else
      fail "$name-log-assertions" "$d/$name.log"
    fi
  done
  d=$(outdir_for t8 tcy-star-error)
  pdflatex -interaction=nonstopmode -output-directory="$d" \
    tests/fixtures/pdflatex-tate/tcy-star-error.tex >"$d/compile.out" 2>&1
  if grep -q 'TATE-FAIL' "$d/tcy-star-error.log" 2>/dev/null; then
    fail "tcy-star-error-log-assertions" "$d/tcy-star-error.log"
  elif grep -q 'is not allowed in yoko mode' "$d/tcy-star-error.log" 2>/dev/null \
    && grep -q 'direction.of.an.unknown.box' "$d/tcy-star-error.log" 2>/dev/null \
    && grep -q 'TATE-PASS' "$d/tcy-star-error.log" 2>/dev/null; then
    echo "PASS: tcy-star-error-log-assertions ($(grep -c 'TATE-PASS' "$d/tcy-star-error.log") assertions + 2 expected errors)"
  else
    fail "tcy-star-error-log-assertions" "$d/tcy-star-error.log"
  fi
  # pdflatex-tate-math.tex のアサーションは「測定シフト vs
  # 独立計算した δ 式（plcore adjustbaseline と同一式を fixture 内で
  # 再実装）」に改訂済み（旧 0.343zw 実装定数との自己申告比較は撤去）。
  # everymath 1回・mathsurround 1対・境界グルー・禁則はこのフィクスチャが、
  # raw box ClassError と one-shot 副作用は math-* フィクスチャ群が担う。
  d=$(outdir_for t8 pdflatex-tate-math)
  run "tate-pdflatex-tate-math" "$d" pdflatex \
    tests/fixtures/pdflatex-tate-math.tex
  if grep -q 'TATE-FAIL' "$d/pdflatex-tate-math.log" 2>/dev/null; then
    fail "pdflatex-tate-math-log-assertions" "$d/pdflatex-tate-math.log"
  elif grep -q 'TATE-PASS' "$d/pdflatex-tate-math.log" 2>/dev/null; then
    echo "PASS: pdflatex-tate-math-log-assertions ($(grep -c 'TATE-PASS' "$d/pdflatex-tate-math.log") assertions)"
  else
    fail "pdflatex-tate-math-log-assertions" "$d/pdflatex-tate-math.log"
  fi
  # ---- 一回実行契約（everymath/everydisplay/mathmc/mbox/amstext） ----
  d=$(outdir_for t8 pdflatex-tate-math-oneshot)
  run "tate-pdflatex-tate-math-oneshot" "$d" pdflatex \
    tests/fixtures/pdflatex-tate/pdflatex-tate-math-oneshot.tex
  if grep -q 'TATE-FAIL' "$d/pdflatex-tate-math-oneshot.log" 2>/dev/null; then
    fail "pdflatex-tate-math-oneshot-log-assertions" "$d/pdflatex-tate-math-oneshot.log"
  elif [ "$(grep -c 'TATE-PASS' "$d/pdflatex-tate-math-oneshot.log" 2>/dev/null)" = 6 ]; then
    pass "pdflatex-tate-math-oneshot-log-assertions (6 assertions)"
  else
    fail "pdflatex-tate-math-oneshot-log-assertions" "$d/pdflatex-tate-math-oneshot.log"
  fi
  # ---- raw primitive box 境界（ClassError 2件を含むため halt なし） ----
  d=$(outdir_for t8 pdflatex-tate-math-rawbox)
  pdflatex -interaction=nonstopmode -output-directory="$d" \
    tests/fixtures/pdflatex-tate/pdflatex-tate-math-rawbox.tex >"$d/compile.out" 2>&1
  if grep -q 'TATE-FAIL' "$d/pdflatex-tate-math-rawbox.log" 2>/dev/null; then
    fail "pdflatex-tate-math-rawbox-log-assertions" "$d/pdflatex-tate-math-rawbox.log"
  elif grep -q 'TATE-PASS: LEGAL' "$d/pdflatex-tate-math-rawbox.log" 2>/dev/null \
    && grep -q 'TATE-PASS: RAWERR' "$d/pdflatex-tate-math-rawbox.log" 2>/dev/null \
    && grep -q 'TATE-PASS: VBOXERR' "$d/pdflatex-tate-math-rawbox.log" 2>/dev/null \
    && grep -q 'raw~primitive~box.*hbox' "$d/pdflatex-tate-math-rawbox.log" 2>/dev/null \
    && grep -q 'raw~primitive~box.*vbox' "$d/pdflatex-tate-math-rawbox.log" 2>/dev/null \
    && grep -q 'Replace~it~with' "$d/pdflatex-tate-math-rawbox.log" 2>/dev/null; then
    pass "pdflatex-tate-math-rawbox-log-assertions (3 assertions + 2 expected ClassErrors)"
  else
    fail "pdflatex-tate-math-rawbox-log-assertions" "$d/pdflatex-tate-math-rawbox.log"
  fi
  # ---- moving argument（section/TOC/mark/bookmark/eqref; 2パス） ----
  mvd=$(outdir_for t8 pdflatex-tate-math-movarg)
  mv_rc=0
  for passno in 1 2; do
    if ! run_compile x "$mvd" pdflatex \
         tests/fixtures/pdflatex-tate/pdflatex-tate-math-movarg.tex; then
      mv_rc=1
    fi
  done
  if grep -q 'Label(s) may have changed' "$mvd/pdflatex-tate-math-movarg.log" 2>/dev/null; then
    mv_rc=1
  fi
  if grep -q 'Reference `eq:mv'"'"' on page' "$mvd/pdflatex-tate-math-movarg.log" 2>/dev/null; then
    mv_rc=1
  fi
  # しおり: 数式を含む見出しの PDF 文字列（hyperref math fallback）が
  # UTF-16BE で .out に残る。数式部分 a+b は \000a\000+\000b として
  # 現れるため、その存在で検査する（日本語部分の byte 並びは
  # フォント/normalizer に依存させない）。
  if ! grep -q '\\000a\\000+\\000b' "$mvd/pdflatex-tate-math-movarg.out" 2>/dev/null; then
    mv_rc=1
  fi
  if ! grep -q 'TATE-PASS: BODY' "$mvd/pdflatex-tate-math-movarg.log" 2>/dev/null; then
    mv_rc=1
  fi
  if [ "$mv_rc" -ne 0 ]; then
    fail "pdflatex-tate-math-movarg (section/mark/bookmark/eqref)" "$mvd/compile.out"
  else
    pass "pdflatex-tate-math-movarg (section/mark/bookmark/eqref, 2 passes, refs resolved)"
  fi
  # boxdump（\showbox の ! OK のため -halt-on-error 不使用; END マーカで成立確認）
  d=$(outdir_for t8 tate-boxdump)
  pdflatex -interaction=nonstopmode -output-directory="$d" \
    tests/fixtures/pdflatex-tate-boxdump.tex >"$d/compile.out" 2>&1
  if ! grep -q 'TATE-GALLEY-END' "$d/pdflatex-tate-boxdump.log" 2>/dev/null; then
    fail "tate-boxdump-compile" "$d/compile.out"
  elif python3 tests/check-tate-boxdump.py "$d/pdflatex-tate-boxdump.log" \
       >"$d/boxdump.out" 2>&1; then
    pass "tate-boxdump-kinsoku"
  else
    fail "tate-boxdump-kinsoku" "$d/boxdump.out"
  fi

  # ---- T8b: 縦中横（\tatechuyoko）通常ゲート（昇格済み） ----
  # 仕様: \tatechuyoko{12} は縦組みで直立・1zw正規化（advance=1zw・
  # cross=体幅半分ずつ・baseline=進行起点; uplatex showbox 実測契約）、
  # star 形は縦組みでも同一構造・横組みでは透過、横組み非star形は
  # ClassError。\jlreq@iftdir は live 化しており gate は PASS する。
  tcy_d=$(outdir_for t8b tcy-basic)
  tcy_rc=0
  if ! run_compile x "$tcy_d" pdflatex \
       tests/fixtures/pdflatex-tate/tcy-basic.tex; then
    tcy_rc=1
  fi
  if [ -f "$tcy_d/tcy-basic.pdf" ]; then
    python3 tests/check-tatechuyoko.py "$tcy_d/tcy-basic.pdf" \
      >"$tcy_d/tcy.out" 2>&1 || tcy_rc=1
  else
    tcy_rc=1
  fi
  if [ "$tcy_rc" -eq 0 ]; then pass "tatechuyoko-basic"; else
    fail "tatechuyoko-basic" "$tcy_d/compile.out"; fi

  # ---- T8c: 出力ルーチン薄層化・目次リーダーゲート ----
  # (1) hook probe: build/page/{before,after} + shipout/before が
  #     1ページにちょうど1回だけ発火することを d-tate と d-yoko
  #     両方で検査（薄ラッパがフックを二重化していない証拠）。
  #     各フックの発火系列が 1,2,3 の各ページで1回ずつであること
  #     （build/page/after は kernel が \stepcounter{page} の後で
  #     走るため page=2,3,4 と報告される: 仕様通り）。
  # (2) tate TOC 2パス: 「Leaders not followed by proper glue」不良
  #     （frame-pop \aftergroup + リーダーのグループ括り）の
  #     回収を、両パスのコンパイル成立 + TOC-PASS マーカで固定する。
  # (3) kernel 本体コピー不在: ソース grep（アサーション1の実行証拠）。
  #     tate ラッパは saved kernel 実装を呼ぶだけであること。
  hp=$(outdir_for t8c hook-probe tate)
  hp_rc=0
  if ! run_compile x "$hp" pdflatex \
       tests/fixtures/pdflatex-tate/out-hook-probe.tex; then
    hp_rc=1
  fi
  if [ "$hp_rc" -eq 0 ]; then
    for n in 1 2 3; do
      [ "$(grep -c "HOOK-BEFORE-$n: page=$n" "$hp/out-hook-probe.log" 2>/dev/null)" = 1 ] || hp_rc=1
      [ "$(grep -c "HOOK-AFTER-$n: page=$((n+1))" "$hp/out-hook-probe.log" 2>/dev/null)" = 1 ] || hp_rc=1
      [ "$(grep -c "SHIPOUT-$n: page=$n" "$hp/out-hook-probe.log" 2>/dev/null)" = 1 ] || hp_rc=1
    done
    [ "$(grep -c "HOOK-BEFORE-" "$hp/out-hook-probe.log")" = 3 ] || hp_rc=1
    [ "$(grep -c "HOOK-AFTER-" "$hp/out-hook-probe.log")" = 3 ] || hp_rc=1
  fi
  hy=$(outdir_for t8c hook-probe yoko)
  if ! run_compile x "$hy" pdflatex \
       tests/fixtures/pdflatex-tate/out-hook-probe-yoko.tex; then
    hp_rc=1
  fi
  if [ "$hp_rc" -eq 0 ]; then
    for n in 1 2 3; do
      [ "$(grep -c "HOOK-BEFORE-$n: page=$n" "$hy/out-hook-probe-yoko.log" 2>/dev/null)" = 1 ] || hp_rc=1
      [ "$(grep -c "HOOK-AFTER-$n: page=$((n+1))" "$hy/out-hook-probe-yoko.log" 2>/dev/null)" = 1 ] || hp_rc=1
      [ "$(grep -c "SHIPOUT-$n: page=$n" "$hy/out-hook-probe-yoko.log" 2>/dev/null)" = 1 ] || hp_rc=1
    done
  fi
  if [ "$hp_rc" -eq 0 ]; then
    pass "out-hook-probe (build/page+shipout hooks fire once/page, tate+yoko)"
  else
    fail "out-hook-probe" "$hp/compile.out"
  fi

  tg=$(outdir_for t8c toc-twopass 2pass)
  tg_rc=0
  for passno in 1 2; do
    if ! run_compile x "$tg" pdflatex \
         tests/fixtures/pdflatex-tate/toc-twopass.tex; then
      tg_rc=1
    fi
  done
  if grep -q "Leaders not followed" "$tg/toc-twopass.log" 2>/dev/null; then
    tg_rc=1
  fi
  [ "$(grep -c "TOC-PASS" "$tg/toc-twopass.log" 2>/dev/null)" = 1 ] || tg_rc=1
  if [ "$tg_rc" -eq 0 ]; then
    pass "toc-twopass (tate TOC, no Leaders error, 2 passes)"
  else
    fail "toc-twopass" "$tg/compile.out"
  fi

  if grep -qE '\\shipout |\\@begindvi|\\stepcounter\{page\}' jlreq-pdftex.sty; then
    fail "outputpage-copy-gone (kernel body must not be copied in source)"
  else
    pass "outputpage-copy-gone (grep: no shipout/@begindvi/stepcounter in backend)"
  fi

  # ---- T8c: savepos・割注ゲート（aux frame-id 往復 + 論理行方向計測） ----
  # 検査: 割注開始時の savepos 測定（\jlreq@savepos@for@rest@linewidth）
  # が縦組みでも論理行方向で取れること。20zw 行・割注前 6 セルの
  # 幾何期待（current=6zw, rest=14zw）を 0.5pt で検査する。
  # この値は pass 2 で初めて確定する（pass 1 は aux 原点なし）ため
  # 2パス実行して最終パスのログで判定 = aux frame-id 往復の証拠でもある。
  # uplatex 同一ソース対照: current=60.0pt / rest=140.0001pt
  # （実測・ビット一致; ゲート値は幾何期待から独立に算出）。
  sw=$(outdir_for t8c savepos-warichu 2pass)
  sw_rc=0
  for passno in 1 2; do
    if ! run_compile x "$sw" pdflatex \
         tests/fixtures/pdflatex-tate/savepos-warichu.tex; then
      sw_rc=1
    fi
  done
  swv=$(grep -o "REST-WIDTH: current=[0-9.]*pt, rest=[0-9.]*pt" \
       "$sw/savepos-warichu.log" 2>/dev/null | tail -1)
  case "$swv" in
    "REST-WIDTH: current=60.0pt, rest=140.0001pt") ;;
    *) sw_rc=1 ;;
  esac
  grep -q "MARK-POS-FAIL" "$sw/savepos-warichu.log" 2>/dev/null && sw_rc=1
  if [ "$sw_rc" -eq 0 ]; then
    pass "savepos-warichu (tate logical-line extents, aux round-trip, uplatex-parity 60.0/140.0001pt)"
  else
    fail "savepos-warichu" "$sw/compile.out"
  fi

  # ---- T8c: savepos mag≠1000 ゲート ----
  # 検査: \mag=1200 でも論理行方向の current/rest が mag=1000 と
  # 同一（60.0pt / 140.0001pt）。raw \pdflastxpos はデザイン座標
  # （mag 不変）であることを実測済み; クラス側の原点・側余白が
  # 物理 1in 基準（1truein 補償）に揃うため、計測式の末項を
  # -1truein にした修正の回帰ガート。MAG-RAW 行は素の
  # savepos 値の記録（ドキュメント参照）。
  sm=$(outdir_for t8c savepos-warichu-mag 2pass)
  sm_rc=0
  for passno in 1 2; do
    if ! run_compile x "$sm" pdflatex \
         tests/fixtures/pdflatex-tate/savepos-warichu-mag.tex; then
      sm_rc=1
    fi
  done
  smv=$(grep -o "REST-WIDTH: current=[0-9.]*pt, rest=[0-9.]*pt" \
       "$sm/savepos-warichu-mag.log" 2>/dev/null | tail -1)
  case "$smv" in
    "REST-WIDTH: current=60.0pt, rest=140.0001pt") ;;
    *) sm_rc=1 ;;
  esac
  if [ "$sm_rc" -eq 0 ]; then
    pass "savepos-warichu-mag (mag=1200 logical extents = mag=1000, design-size parity)"
  else
    fail "savepos-warichu-mag" "$sm/compile.out"
  fi

  # ---- T8c: marginpar 列/側 + 遅延脚注位置ゲート ----
  # 検査: d-tate で \marginpar（奇数ページ）と遅延脚注（偶数ページ）の
  # savepos マーカを記録し、両エンジンの「行方向相対距離」が一致する
  # ことを検査する。uplatex の tate savepos は行直交方向から数える
  # （DVI 座標系の軸が回転出荷と異なる）ため、原点を共有する相対距離
  # （marginpar マーカ − 脚注マーカ）で比較する:
  #   pdflatex: dX(行方向) = 160.0007pt
  #   uplatex : dy(行方向) = 160.0007pt（符号は原点側の違いのみ）
  # 絶対原点はエンジンごとに異なるため、これが座標系変換を一度だけ
  # 行う単一比較点（frame metadata で統一する方針）。
  # 2パス実行（aux 原点は pass 2 で確定）。
  mpx=$(outdir_for t8c savepos-marginpar pd)
  mpu=$(outdir_for t8c savepos-marginpar up)
  mp_rc=0
  for passno in 1 2; do
    if ! run_compile x "$mpx" pdflatex \
         tests/fixtures/pdflatex-tate/savepos-marginpar.tex; then
      mp_rc=1
    fi
  done
  sed -e 's/\\documentclass\[pdflatex,/\\documentclass[uplatex,/' \
       tests/fixtures/pdflatex-tate/savepos-marginpar.tex >"$mpx/up-variant.tex"
  for passno in 1 2; do
    if ! run_compile x "$mpu" uplatex "$mpx/up-variant.tex"; then
      mp_rc=1
    fi
  done
  # pdflatex: mpar/fnote の X（行方向）
  pdm=$(grep -o "MPAR-POS: x=[0-9.]*pt" "$mpx/savepos-marginpar.log" 2>/dev/null | tail -1 | sed 's/.*x=//;s/pt//')
  pdf=$(grep -o "FNOTE-POS: x=[0-9.]*pt" "$mpx/savepos-marginpar.log" 2>/dev/null | tail -1 | sed 's/.*x=//;s/pt//')
  # uplatex: X は行直交方向、Y が行方向 → aux の Y ラベルを読む
  upm=$(grep -E 'mpar\.Y\.[0-9]+\}\{[0-9]+\}' "$mpu/up-variant.aux" 2>/dev/null | head -1 | sed 's/.*}{//;s/}//')
  upf=$(grep -E 'fnote\.Y\.[0-9]+\}\{[0-9]+\}' "$mpu/up-variant.aux" 2>/dev/null | head -1 | sed 's/.*}{//;s/}//')
  if [ -n "$pdm" ] && [ -n "$pdf" ] && [ -n "$upm" ] && [ -n "$upf" ]; then
    pd_delta=$(python3 -c "print('%.4f' % ($pdm - $pdf))")
    up_delta=$(python3 -c "print('%.4f' % (abs($upm - $upf)/65536.0))")
    ok=$(python3 -c "print(1 if abs($pd_delta - $up_delta) < 0.1 else 0)")
    [ "$ok" = 1 ] || mp_rc=1
  else
    mp_rc=1
  fi
  if [ "$mp_rc" -eq 0 ]; then
    pass "savepos-marginpar (tate marginpar column + deferred footnote, line-dir parity pd/up = ${pd_delta}pt)"
  else
    fail "savepos-marginpar" "$mpx/compile.out"
  fi

  # ---- T8c: PDF インクレベル・アンカー対照ゲート ----
  # 検査: tate ページの本文グリフ走り（あ..こ = 先頭行）が pdflatex
  # と uplatex(dvipdfmx) の PDF で 0.1pt 以内に一致すること（savepos/
  # 論理フレーム契約の PDF 側証拠。実測: worst 0.0010pt）。
  # 報告のみ（ゲート外）: 脚注領域の ◆/☆ アンカーは tate 脚注・
  # 合印マイクロレイアウトの既知残差（マーク位置 d≈(+1.49,+7.61)pt、
  # 脚注テキスト d≈2.3-5.5pt、脚注列間隔 11.458 vs 13.748pt;
  # 同機構の yoko 対照は 0.006/0.53pt）— docs/pdftex-internals.md
  # の縦組み脚注パリティ数値表参照。up 変換は dvipdfmx -p "182mm,257mm"（JIS B5;
  # クラスは papersize special を出さないため）。
  ap_pd=$(outdir_for t8c anchor-parity pd)
  ap_up=$(outdir_for t8c anchor-parity up)
  ap_rc=0
  for passno in 1 2; do
    if ! run_compile x "$ap_pd" pdflatex \
         tests/fixtures/pdflatex-tate/savepos-anchor-pdf.tex; then
      ap_rc=1
    fi
  done
  sed -e 's/\\documentclass\[pdflatex,/\\documentclass[uplatex,/' \
       tests/fixtures/pdflatex-tate/savepos-anchor-pdf.tex >"$ap_up/src.tex"
  for passno in 1 2; do
    if ! run_compile x "$ap_up" uplatex "$ap_up/src.tex"; then
      ap_rc=1
    fi
  done
  if ! dvipdfmx -p "182mm,257mm" -o "$ap_up/up.pdf" "$ap_up/src.dvi" \
       >"$ap_up/dvipdfmx.out" 2>&1; then
    ap_rc=1
  fi
  if [ "$ap_rc" -eq 0 ]; then
    if python3 tests/check-anchor-parity.py \
         "$ap_pd/savepos-anchor-pdf.pdf" "$ap_up/up.pdf" \
         >"$ap_pd/anchor.out" 2>&1; then
      pass "anchor-parity (tate body-run ink parity pd/up, PDF level)"
    else
      fail "anchor-parity" "$ap_pd/anchor.out"
    fi
  else
    fail "anchor-parity" "$ap_pd/compile.out"
  fi


  # ---- T8c: 脚注ブロック・パリティゲート（10pt/12pt） ----
  # 検査: d-tate の脚注ブロック微細レイアウト（罫線位置・本文列頭・
  # （１）マーク列頭・罫線長・罫線→本文列間隔）が uplatex 同一ソース
  # PDF とインクレベルで一致すること（tol 0.5pt; 実測 worst 0.003pt）。
  # これは従来の「tate 脚注・合印マイクロレイアウト残差」
  # （修正前: 罫線 -8.54pt / 本文列 -1.72pt / マーク -3.71pt @10pt）
  # を閉じた修正（脚注罫線カーン捕捉・補助縦フォントの実寸
  # スケール・縦字形の +90° 予備回転と vf 同一置き型・挿入物文脈の
  # ht/dp 正規化 + 先頭脚注の高さ/行末深さストラット）の回帰ガード。
  # fontsize=10pt と 12pt の両方で検査する。up 変換は dvipdfmx -p a5。
  for fnfs in 10 12; do
    fp_pd=$(outdir_for t8c footnote-parity "pd${fnfs}")
    fp_up=$(outdir_for t8c footnote-parity "up${fnfs}")
    fp_rc=0
    sed -e "s/\\\\documentclass\\[pdflatex,tate,paper=a5\\]/\\\\documentclass[pdflatex,tate,paper=a5,fontsize=${fnfs}pt]/" \
        tests/fixtures/pdflatex-tate/footnote-parity.tex >"$fp_pd/src.tex"
    if ! run_compile x "$fp_pd" pdflatex "$fp_pd/src.tex"; then
      fp_rc=1
    fi
    sed -e "s/\\\\documentclass\\[pdflatex,tate,paper=a5\\]/\\\\documentclass[uplatex,tate,paper=a5,fontsize=${fnfs}pt]/" \
        tests/fixtures/pdflatex-tate/footnote-parity.tex >"$fp_up/src.tex"
    if ! run_compile x "$fp_up" uplatex "$fp_up/src.tex"; then
      fp_rc=1
    fi
    if ! dvipdfmx -p a5 -o "$fp_up/up.pdf" "$fp_up/src.dvi" \
         >"$fp_up/dvipdfmx.out" 2>&1; then
      fp_rc=1
    fi
    if [ "$fp_rc" -eq 0 ]; then
      if python3 tests/check-footnote-parity.py \
           "$fp_pd/src.pdf" "$fp_up/up.pdf" >"$fp_pd/parity.out" 2>&1; then
        pass "footnote-parity-${fnfs}pt (tate fn block ink parity pd/up: rule/text/mark/length/gap)"
      else
        fail "footnote-parity-${fnfs}pt" "$fp_pd/parity.out"
      fi
    else
      fail "footnote-parity-${fnfs}pt" "$fp_pd/compile.out"
    fi
  done

  # ---- T8c: 家具オプション縦組み対照ゲート ----
  # 検査: head_space/foot_space/gutter/fore_edge 非対称 + twoside +
  # twocolumn + 遅延脚注 + \marginpar を d-tate で組んだときの
  # クラス幾何レジスタが uplatex 同一ソースの実測値
  # （oddsidemargin=12.7299pt / evensidemargin=82.73001pt /
  #  textwidth=551.31902pt / columnwidth=265.6595pt; 実測）
  # と一致すること。縦組み \Cht/\Cdp を縦JFM class 0 で測り直した
  # 修正の回帰ガードでもある（修正前は余白系に一定 3.8pt の
  # オフセットがあった）。2パス実行（aux 安定後の値で判定）。
  # ゲート内判定: FURN-PASS / TWOCOL-PASS / DEFNOTE カウンタ=2。
  fo=$(outdir_for t8c furniture-options 2pass)
  fo_rc=0
  for passno in 1 2; do
    if ! run_compile x "$fo" pdflatex \
         tests/fixtures/pdflatex-tate/furniture-options.tex; then
      fo_rc=1
    fi
  done
  fov=$(grep -o "GEOM: oddsidemargin=[0-9.]*pt, evensidemargin=[0-9.]*pt" \
       "$fo/furniture-options.log" 2>/dev/null | tail -1)
  case "$fov" in
    "GEOM: oddsidemargin=12.7299pt, evensidemargin=82.73001pt") ;;
    *) fo_rc=1 ;;
  esac
  grep -q "FURN-PASS" "$fo/furniture-options.log" 2>/dev/null || fo_rc=1
  grep -q "TWOCOL-PASS" "$fo/furniture-options.log" 2>/dev/null || fo_rc=1
  grep -q "DEFNOTE: footnotecounter=2" "$fo/furniture-options.log" 2>/dev/null || fo_rc=1
  grep -q "FURN-FAIL\|TWOCOL-FAIL" "$fo/furniture-options.log" 2>/dev/null && fo_rc=1
  if [ "$fo_rc" -eq 0 ]; then
    pass "furniture-options (tate asym gutter/head/foot + twoside + 2col + deferred notes + marginpar, uplatex-parity)"
  else
    fail "furniture-options" "$fo/compile.out"
  fi
fi


# ---- pdftex_fontset=haranoaji（横組・縦組レンダリング実証ゲート） ----
# 判定: rc=0、ログマーカ、埋込フォント面の実在（pdffonts:
#   横組 = Mincho-Regular + Mincho-Bold + Gothic-Regular + Gothic-Bold
#          （実Bold面; emboldenではない）、
#   縦組 = Mincho-Regular + 補助縦フォント JLreqVertharanoaji
#          （vert字形は補助縦TTFから供給される）、
# 抽出照合（pdftotext で本文断片と縦字形対象文字のcodepointが再現）。
for f in haranoaji-yoko haranoaji-tate; do
  d=$(outdir_for t8-hara "$f")
  run "haranoaji-$f" "$d" pdflatex \
    "tests/fixtures/pdflatex-haranoaji/$f.tex"
  hrc=0
  case $f in
    haranoaji-yoko) hmarker=HARANOAJI-YOKO-PASS ;;
    *) hmarker=HARANOAJI-TATE-PASS ;;
  esac
  grep -q "$hmarker" "$d/$f.log" 2>/dev/null || hrc=1
  pdffonts "$d/$f.pdf" 2>/dev/null | grep -q "HaranoAjiMincho-Regular" || hrc=1
  if [ "$f" = haranoaji-yoko ]; then
    pdffonts "$d/$f.pdf" 2>/dev/null | grep -q "HaranoAjiMincho-Bold" || hrc=1
    pdffonts "$d/$f.pdf" 2>/dev/null | grep -q "HaranoAjiGothic-Bold" || hrc=1
    pdffonts "$d/$f.pdf" 2>/dev/null | grep -q "HaranoAjiGothic-Regular" || hrc=1
  else
    pdffonts "$d/$f.pdf" 2>/dev/null | grep -q "JLreqVertharanoaji" || hrc=1
    # 縦字形対象文字の抽出（ToUnicode契約）: ー っ ‥ が原文codepointで出る
    # pdftotext はグリフ間へ空白を挿入することがあるため空白も除去する
    pdftotext "$d/$f.pdf" - 2>/dev/null | tr -d '\n ' | \
      grep -q 'ー' || hrc=1
    pdftotext "$d/$f.pdf" - 2>/dev/null | tr -d '\n ' | \
      grep -q 'っ' || hrc=1
    pdftotext "$d/$f.pdf" - 2>/dev/null | tr -d '\n ' | \
      grep -q '‥' || hrc=1
  fi
  # 本文断片の抽出照合。pdftotext はフォントセットによりグリフ間へ空白を
  # 挿入し、さらに縦組/行列配置では読み順そのものが入れ替わる（実測:
  # 縦組で「原の味」が「原 字 の 味」のように複数行の字が交互に出る）
  # ため、**連続 substring 照合は成立しない**。ここでは空白除去後の抽出
  # テキストに本文の各文字が全て含まれること（順非依存の文字集合照合）を
  # 検査する。文字の網羅性＝ToUnicode/埋込の実証として十分。
  for ch in 原 の 味; do
    pdftotext "$d/$f.pdf" - 2>/dev/null | tr -d '\n ' | \
      grep -q "$ch" || hrc=1
  done
  if [ "$hrc" -eq 0 ]; then
    pass "haranoaji-$f (fontset embedding + real bold + extraction)"
  else
    fail "haranoaji-$f (fontset embedding/extraction)" "$d/compile.out"
  fi
done

# ===========================================================================
echo "== T9: ruby（ruby.sty provider 適合）=="
# ===========================================================================
# T0 追加資源: アダプタ jlreq-pdftex-ruby.sty（バックエンド .sty 3本目）
for f in jlreq-pdftex-ruby.sty; do
  [ -f "$f" ] || { echo "FAIL: T9-ruby missing required file: $f"; FAILED=$((FAILED+1)); }
done

# ---- 9.1 ruby-basic（横組み: 上付き・境界グルー・連続/overlap/nooverlap/
#      本文より長いルビ・状態隔離・rubylatin; ログ内自己表明 17件） ----
rb=$(outdir_for t9 ruby-basic)
if pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$rb" \
     tests/fixtures/pdflatex-rules/ruby-basic.tex >"$rb/compile.out" 2>&1 \
   && grep -q "RUBY-DONE" "$rb/ruby-basic.log" 2>/dev/null; then
  if grep -q "RUBY-FAIL" "$rb/ruby-basic.log" 2>/dev/null; then
    fail "ruby-basic-log-assertions" "$rb/ruby-basic.log"
  else
    echo "PASS: ruby-basic-log-assertions ($(grep -c 'RUBY-PASS' "$rb/ruby-basic.log") assertions)"
  fi
else
  fail "ruby-basic-compile" "$rb/compile.out"
fi

# ---- 9.2 ruby-tate（縦組み: reading-frame 右・縦字形・境界グルー;
#      ログ内自己表明 10件） ----
rt=$(outdir_for t9 ruby-tate)
if pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$rt" \
     tests/fixtures/pdflatex-tate/ruby-tate.tex >"$rt/compile.out" 2>&1 \
   && grep -q "RUBY-DONE-TATE" "$rt/ruby-tate.log" 2>/dev/null; then
  if grep -q "RUBY-FAIL" "$rt/ruby-tate.log" 2>/dev/null; then
    fail "ruby-tate-log-assertions" "$rt/ruby-tate.log"
  else
    echo "PASS: ruby-tate-log-assertions ($(grep -c 'RUBY-PASS' "$rt/ruby-tate.log") assertions)"
  fi
else
  fail "ruby-tate-compile" "$rt/compile.out"
fi

# ---- 9.3 ruby-coexist（hyperref 共存・段落先頭末尾・句読点・抽出;
#      2パス（目次/ラベル安定後の抽出検査） ----
rc=$(outdir_for t9 ruby-coexist 2pass)
rc_rc=0
for passno in 1 2; do
  if ! run_compile x "$rc" pdflatex \
       tests/fixtures/pdflatex-coexist/ruby-coexist.tex; then
    rc_rc=1
  fi
done
grep -q "RUBY-FAIL" "$rc/ruby-coexist.log" 2>/dev/null && rc_rc=1
[ "$(grep -c 'RUBY-PASS' "$rc/ruby-coexist.log" 2>/dev/null)" -ge 4 ] || rc_rc=1
# 文字抽出: base・annotation 両テキストが PDF に残る
pdftotext "$rc/ruby-coexist.pdf" "$rc/extract.txt" >/dev/null 2>&1
grep -q "依存" "$rc/extract.txt" 2>/dev/null || rc_rc=1
grep -q "いぞん" "$rc/extract.txt" 2>/dev/null || rc_rc=1
# しおり: ルビ付き見出しの base 文字列が PDF 文字列に含まれる
# （ルビ本体の vrule 引数が PDF 文字列に漏れるのは provider 自身の
#  既知挙動 — lualatex+ruby.sty 同一ソースでも同一。base 部分の存在を検査）
python3 - "$rc/ruby-coexist.out" >"$rc/bookmark.out" 2>&1 <<'PYEOF' || rc_rc=1
import re
import sys

# The .out bookmark title is a TeX string of \NNN octal escapes holding
# UTF-16BE bytes. The ruby provider's box arithmetic leaks raw tokens
# into the PDF string (identically under lualatex+ruby.sty -- provider
# limitation, both engines); the heading's BASE text must still be
# present. Decode the escapes and look for the base fragments.
data = open(sys.argv[1], "rb").read().decode("utf-8", "replace")
m = re.search(r"\\BOOKMARK \[1\]\[-\]\{section\*\.1\}\{(.*)\}\{\}%", data)
if m is None:
    print("bookmark-contains-base-text: no section bookmark found")
    sys.exit(1)
bs = bytes(int(x, 8) for x in re.findall(r"\\([0-7]{3})", m.group(1)))
txt = bs[2:].decode("utf-16-be", "replace")
ok = ("見出しと" in txt) and ("漢字" in txt) and ("かんじ" in txt)
print("bookmark-contains-base-text:", ok, repr(txt[:24]))
sys.exit(0 if ok else 1)
PYEOF
if [ "$rc_rc" -eq 0 ]; then
  pass "ruby-coexist (hyperref link/heading + paragraph head/tail + punctuation + extraction + bookmark base text)"
else
  fail "ruby-coexist" "$rc/compile.out"
fi

# ---- 9.4 lualatex+ruby.sty 位置 parity（縦横; 同一 provider による
#      位置 oracle。横: annotation 基線オフセット・中央寄せ exact;
#      縦: reading-frame 右・縦字形・中央寄せ structural exact） ----
py_src=$(outdir_for t9 ruby-parity src)
sed -e 's/\\documentclass\[paper=a5\]/\\documentclass[pdflatex,paper=a5]/' \
     tests/fixtures/pdflatex-rules/ruby-parity.tex >"$py_src/pd.tex"
cp tests/fixtures/pdflatex-rules/ruby-parity.tex "$py_src/lu.tex"
py_rc=0
if ! run_compile x "$py_src" pdflatex "$py_src/pd.tex"; then py_rc=1; fi
if ! run_compile x "$py_src" lualatex "$py_src/lu.tex"; then py_rc=1; fi
if [ "$py_rc" -eq 0 ]; then
  if python3 tests/check-ruby-parity.py "$py_src/pd.pdf" "$py_src/lu.pdf" \
       >"$py_src/parity-yoko.out" 2>&1; then
    echo "PASS: ruby-parity-yoko (vs lualatex+ruby.sty, ann baseline offset/centering/size exact)"
  else
    fail "ruby-parity-yoko" "$py_src/parity-yoko.out"
  fi
else
  fail "ruby-parity-yoko" "$py_src/compile.out"
fi
# tate 変種（同一ソースの tate 版: [paper=a5] → [tate,paper=a5] /
# [pdflatex,tate,paper=a5]）
pyt=$(outdir_for t9 ruby-parity tate)
sed -e 's/\\documentclass\[paper=a5\]/\\documentclass[pdflatex,tate,paper=a5]/' \
     tests/fixtures/pdflatex-rules/ruby-parity.tex >"$pyt/pd.tex"
sed -e 's/\\documentclass\[paper=a5\]/\\documentclass[tate,paper=a5]/' \
     tests/fixtures/pdflatex-rules/ruby-parity.tex >"$pyt/lu.tex"
pt_rc=0
if ! run_compile x "$pyt" pdflatex "$pyt/pd.tex"; then pt_rc=1; fi
if ! run_compile x "$pyt" lualatex "$pyt/lu.tex"; then pt_rc=1; fi
if [ "$pt_rc" -eq 0 ]; then
  if python3 tests/check-ruby-parity.py "$pyt/pd.pdf" "$pyt/lu.pdf" tate \
       >"$pyt/parity-tate.out" 2>&1; then
    echo "PASS: ruby-parity-tate (ann reading-frame right + vertical glyphs + centering vs lualatex+ruby.sty)"
  else
    fail "ruby-parity-tate" "$pyt/parity-tate.out"
  fi
else
  fail "ruby-parity-tate" "$pyt/compile.out"
fi

# ---- 9.5 ruby アダプタ非汚染（provider 未読み込み文書に影響しない） ----
# ruby.sty を読まない文書でアダプタのインストールが no-op であること:
# \ruby は定義されず、コンパイルは通常どおり。
nr=$(outdir_for t9 ruby-absent)
printf '\\documentclass[pdflatex]{jlreq}\n\\begin{document}\n\\makeatletter\n\\ifdefined\\ruby ERR\\else OK\\fi\n\\message{RUBY-UNDEF: \\ifdefined\\ruby defined\\else undefined\\fi}\n漢\n\\makeatother\n\\end{document}\n' >"$nr/src.tex"
if pdflatex -interaction=nonstopmode -halt-on-error -output-directory="$nr" \
     "$nr/src.tex" >"$nr/compile.out" 2>&1 \
   && grep -q "RUBY-UNDEF: undefined" "$nr/src.log" 2>/dev/null; then
  pass "ruby-adapter-noop-without-provider (no jlreq-native ruby defined)"
else
  fail "ruby-adapter-noop-without-provider" "$nr/compile.out"
fi

# ===========================================================================
echo "== T12: staged install smoke（配布物だけでの -no-shell-escape コンパイル）=="
# ===========================================================================
# 目的: 「-no-shell-escape でインストール済みTDSだけから本文・縦中横・
# ルビ・厳密段落をコンパイルできる」ことの実証。
#   1. make install を一時 texmf 木へ（JLREQ_TEXMF 変数で配置先を指定）
#   2. リポジトリ外の作業ディレクトリで、TEXINPUTS/TEXFONTS/ENCFONTS を
#      staged TEXMF（+ システム既定）に向けて pdflatex -no-shell-escape
#   3. 判定: rc=0、ログに shell-out 証跡（runsystem/write18/shellescape）
#      0 件、STAGED-*-PASS マーカ、pdftotext 抽出に本文が含まれる
# 欠損資源・失敗はSKIPではなくFAIL。
staged=$(mktemp -d "${TMPDIR:-/tmp}/jlreq-staged.XXXXXXXX") || {
  echo "FAIL: cannot create staged temp dir"; exit 1; }
if make install JLREQ_TEXMF="$staged/texmf" >"$staged/install.out" 2>&1; then
  pass "staged-install (make install JLREQ_TEXMF=<tmp>, all modules + fonts + defs + manifest)"
else
  fail "staged-install" "$staged/install.out"
fi
smokework=$(mktemp -d "${TMPDIR:-/tmp}/jlreq-smoke.XXXXXXXX") || {
  echo "FAIL: cannot create smoke temp dir"; exit 1; }
cp tests/fixtures/pdflatex-staged/staged-smoke-yoko.tex \
   tests/fixtures/pdflatex-staged/staged-smoke-tate.tex \
   tests/fixtures/pdflatex-staged/staged-smoke-haranoaji.tex "$smokework/"
for f in staged-smoke-yoko staged-smoke-tate staged-smoke-haranoaji; do
  d="$smokework/$f"
  mkdir -p "$d"
  cp "$smokework/$f.tex" "$d/"
  ( cd "$d" \
    && TEXINPUTS="$staged/texmf/tex/latex/jlreq:" \
      TEXFONTS="$staged/texmf/fonts/tfm//:$staged/texmf/fonts/truetype//:" \
      ENCFONTS="$staged/texmf/fonts/enc//:${ENCFONTS:-}" \
      pdflatex -no-shell-escape -interaction=nonstopmode \
        -halt-on-error "$f.tex" >compile.out 2>&1 )
  rc=$?
  marker=STAGED-YOKO-PASS
  [ "$f" = staged-smoke-tate ] && marker=STAGED-TATE-PASS
  [ "$f" = staged-smoke-haranoaji ] && marker=STAGED-HARA-PASS
  if [ "$rc" -ne 0 ]; then
    fail "staged-$f (repo-external cwd, -no-shell-escape)" "$d/compile.out"
    continue
  fi
  # shell-out 証跡 0 件（実行時の texlua/python 起動は禁止）
  if grep -qiE 'runsystem|write18|shellescape' "$d/$f.log" 2>/dev/null; then
    fail "staged-$f (shell-out detected)" "$d/$f.log"
    continue
  fi
  if ! grep -q "$marker" "$d/$f.log" 2>/dev/null; then
    fail "staged-$f (missing $marker)" "$d/$f.log"
    continue
  fi
  # 縦組みPDFのpdftotext出力は1文字1行になるため、改行を除去してから
  # 本文の連続性を判定する（横組みでも同一パイプで成立する）。
  # pdftotext は抽出時に単語間へ空白を挿入することがある（fontset により
  # グリフ並びが変わるため）。本文判定は空白も除去して行う。
  # haranoaji は読み順入れ替わり実測済みのため下の専用判定へ委ね、
  # この連続 substring 判定はスキップする。
  if [ "$f" != staged-smoke-haranoaji ] && \
     ! pdftotext "$d/$f.pdf" - 2>/dev/null | tr -d '\n ' | grep -q 'これは'; then
    fail "staged-$f (text extraction does not contain body)" "$d/$f.pdf"
    continue
  fi
  # haranoaji smoke: 変換済み横組TTFが kpathsea（TEXFONTS）経由で
  # pdfmapline に解決されていることを埋込面で実証する。本文抽出照合は
  # haranoaji の縦組レイアウトでは pdftotext の読み順が複数行を交互に
  # 出す（実測: 「これは」が「こ れ は」+別行の字と混在）ため、
  # 上の連続 substring 判定の代わりに順非依存の文字集合照合で行う。
  if [ "$f" = staged-smoke-haranoaji ]; then
    hbody_rc=0
    for ch in こ れ は 縦 組 脚 注; do
      pdftotext "$d/$f.pdf" - 2>/dev/null | tr -d '\n ' | \
        grep -q "$ch" || hbody_rc=1
    done
    if [ "$hbody_rc" -ne 0 ]; then
      fail "staged-$f (text extraction does not contain body chars)" "$d/$f.pdf"
      continue
    fi
    if ! pdffonts "$d/$f.pdf" 2>/dev/null | grep -q "JLreqVertharanoaji"; then
      fail "staged-$f (aux vertical font not embedded)" "$d/$f.pdf"
      continue
    fi
  fi
  pass "staged-$f (staged TDS only, -no-shell-escape, 0 shell-outs, extraction OK)"
done
echo "staged workdir: $smokework (texmf: $staged/texmf)"

# ===========================================================================
echo ""
echo "== サマリ =="
echo "workdir: $OUT"
echo "FAILED: $FAILED"
echo "XFAIL:  $XFAILED${XFAIL_NAMES:+ ($XFAIL_NAMES )}"
echo "XPASS:  $XPASSED${XPASS_NAMES:+ ($XPASS_NAMES )}"
if [ "$XPASSED" -gt 0 ]; then
  echo ""
  echo "XPASS 検出: 以下の既知不良は実装で解消された可能性があります。"
  echo "  昇格手順: KNOWN_DEFECTS から削除し、該当検査を通常セクションへ"
  echo "  移動した上で docs/pdftex-tests.md を更新してください:"
  for n in $XPASS_NAMES; do echo "    - $n"; done
  exit 1
fi
if [ "$FAILED" -eq 0 ]; then
  echo ""
  echo "ALL TESTS PASSED${XFAILED:+ (with $XFAILED expected XFAIL${XFAILED:+s}:$XFAIL_NAMES )}"
  exit 0
else
  echo ""
  echo "$FAILED TEST(S) FAILED"
  exit 1
fi
