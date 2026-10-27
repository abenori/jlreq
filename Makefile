# この変数名に TEXMF を使わないこと: kpsewhich の木リスト変数
# TEXMF と衝突し、GNU make 4.4+ はコマンドライン変数を
# $(shell) の環境へ export するため、texlua/kpsewhich が
# 全検索パスを失い make install TEXMF=<tmp> が壊れる。
JLREQ_TEXMF ?= $(shell kpsewhich -var-value=TEXMFHOME)
MAKEJVFCNF:=$(shell ls -RL $(shell kpsewhich --var-value=TEXMFDIST)/fonts/source 2>/dev/null | awk '/:$$/{sub(/:$$/,"");f=$$0} tolower($$0) ~ /makejvf-upjpn\.cnf$$/{print f"/"$$0}' | head -n 1)

# pdfTeX backend JFM data (12 variants, manifest-driven).
# The .def files ARE committed (unlike .tfm/.vf, which are built at install
# time): the pdfTeX backend needs them at run time and users may not have
# texlua.  Regeneration-diff-zero is checked by `make check-pdftex-jfm`
# (run it in CI / after touching jfm-jlreq.lua or make_pdftex_jfm.lua).
# The file list comes from the GENERATOR'S MANIFEST (single source):
# make_pdftex_jfm.lua --print-manifest lists the 12 .def files plus
# the manifest itself.
PDFTEX_JFM_MANIFEST := pdftex-jfm-manifest.lua
PDFTEX_JFM_DEFS := $(filter-out $(PDFTEX_JFM_MANIFEST),$(shell texlua make_pdftex_jfm.lua --print-manifest))

TFMS = jlreq.tfm bjlreq.tfm zjlreq.tfm bzjlreq.tfm \
	ujlreq.tfm ubjlreq.tfm uzjlreq.tfm ubzjlreq.tfm \
	ujlreq-q.tfm ubjlreq-q.tfm uzjlreq-q.tfm ubzjlreq-q.tfm \
	jlreqg.tfm bjlreqg.tfm zjlreqg.tfm bzjlreqg.tfm \
	ujlreqg.tfm ubjlreqg.tfm uzjlreqg.tfm ubzjlreqg.tfm \
	ujlreqg-q.tfm ubjlreqg-q.tfm uzjlreqg-q.tfm ubzjlreqg-q.tfm \
	jlreq-v.tfm bjlreq-v.tfm zjlreq-v.tfm bzjlreq-v.tfm \
	ujlreq-v.tfm ubjlreq-v.tfm uzjlreq-v.tfm ubzjlreq-v.tfm \
	jlreqg-v.tfm bjlreqg-v.tfm zjlreqg-v.tfm bzjlreqg-v.tfm \
	ujlreqg-v.tfm ubjlreqg-v.tfm uzjlreqg-v.tfm ubzjlreqg-v.tfm \
	jlreq-jidori.tfm jlreqg-jidori.tfm jlreq-v-jidori.tfm jlreqg-v-jidori.tfm \
	ujlreq-jidori.tfm ujlreqg-jidori.tfm ujlreq-v-jidori.tfm ujlreqg-v-jidori.tfm \
	ujlreq-jidori-q.tfm ujlreqg-jidori-q.tfm

VFS = jlreq.vf bjlreq.vf zjlreq.vf bzjlreq.vf \
	ujlreq.vf ubjlreq.vf uzjlreq.vf ubzjlreq.vf \
	ujlreq-q.vf ubjlreq-q.vf uzjlreq-q.vf ubzjlreq-q.vf \
	jlreqg.vf bjlreqg.vf zjlreqg.vf bzjlreqg.vf \
	ujlreqg.vf ubjlreqg.vf uzjlreqg.vf ubzjlreqg.vf \
	ujlreqg-q.vf ubjlreqg-q.vf uzjlreqg-q.vf ubzjlreqg-q.vf \
	jlreq-v.vf bjlreq-v.vf zjlreq-v.vf bzjlreq-v.vf \
	ujlreq-v.vf ubjlreq-v.vf uzjlreq-v.vf ubzjlreq-v.vf \
	jlreqg-v.vf bjlreqg-v.vf zjlreqg-v.vf bzjlreqg-v.vf \
	ujlreqg-v.vf ubjlreqg-v.vf uzjlreqg-v.vf ubzjlreqg-v.vf \
	jlreq-jidori.vf jlreqg-jidori.vf jlreq-v-jidori.vf jlreqg-v-jidori.vf \
	ujlreq-jidori.vf ujlreqg-jidori.vf ujlreq-v-jidori.vf ujlreqg-v-jidori.vf \
	ujlreq-jidori-q.vf ujlreqg-jidori-q.vf

.PHONY: all jfm doc latexdoc pdfdoc htmldoc jfm-install cls-install sty-install install tds uninstall jfmclean docclean clean pdftex-jfm check-pdftex-jfm check-pdftex-jfm-static pdftex-fonts check-pdftex-fonts

all: jfm

jfm: jfm-jlreqv.lua jfm-jlreqv-jidori.lua $(VFS) $(TFMS)
	
	rm -f rml.tfm rmlv.tfm gbm.tfm gbmv.tfm uprml-h.tfm uprml-hq.tfm upgbm-h.tfm upgbm-hq.tfm uprml-v.tfm uprml-vq.tfm upgbm-v.tfm upgbm-vq.tfm

# pdfTeXバックエンド用JFMデータの生成（12組）
# 出力は決定的（タイムスタンプなし・ソート済み）。manifest
# （pdftex-jfm-manifest.lua）がバリアント一覧の唯一のソース。
pdftex-jfm: $(PDFTEX_JFM_DEFS) $(PDFTEX_JFM_MANIFEST)

$(PDFTEX_JFM_DEFS) $(PDFTEX_JFM_MANIFEST)&: make_pdftex_jfm.lua jfm-jlreq.lua jfm-jlreqv.lua
	@tmp=`mktemp -d "$${TMPDIR:-/tmp}/pdftex-jfm.XXXXXXXX"` \
	  && texlua make_pdftex_jfm.lua --all-variants \
	       --outdir="$$tmp" --manifest="$$tmp/$(PDFTEX_JFM_MANIFEST)" \
	  && mv "$$tmp"/* . \
	  && rmdir "$$tmp" \
	  || { rm -rf "$$tmp"; exit 1; }

# 再生成してコミット済みファイルとの差分ゼロを検査する（CI 用）。
# このターゲットは `all` には含めない: 通常のビルド（make jfm）は
# pTeX/upTeX/LuaTeX 用であり、pdfTeX 用データの検査は独立に実行する。
# チェックは一時ディレクトリ（mktemp）で行う: 固定名のチェックdirは
# 並列makeで衝突するため廃止（共有dis/json・固定check dirは
# 廃止）。
check-pdftex-jfm:
	@tmp=`mktemp -d "$${TMPDIR:-/tmp}/pdftex-jfm-check.XXXXXXXX"`; \
	trap 'rm -rf "$$tmp"' EXIT HUP INT TERM; \
	texlua make_pdftex_jfm.lua --all-variants \
	  --outdir="$$tmp" --manifest="$$tmp/$(PDFTEX_JFM_MANIFEST)" \
	  || exit 1; \
	rc=0; \
	for f in $(PDFTEX_JFM_DEFS) $(PDFTEX_JFM_MANIFEST); do \
	  cmp "$$tmp/$$f" "$$f" || { \
	    echo "FAIL: check-pdftex-jfm: regenerated $$f differs"; rc=1; }; \
	done; \
	texlua check_jfm_pdftex.lua || rc=1; \
	if [ $$rc -eq 0 ]; then \
	  echo "check-pdftex-jfm: regeneration diff zero, all 12 variants validated"; \
	fi; \
	exit $$rc

# ---------------------------------------------------------------------------
# 補助縦フォント・フォントプロファイル。
# make_pdftex_fonts.py が ipaex / ipa 両組の aux TTF/enc/TFM と profile .def
# を fonts/pdftex/ へ生成する。生成は決定的（固定日時・ソート済み）。
# 通常の文書コンパイルは生成済み資源だけを使い python/fontTools/ttf2tfm
# は実行しない（ビルド/利用分離）。この manifest は JFM 生成器
# （pdftex-jfm-manifest.lua）とは独立で、中間物を共有しない。
PDFTEX_FONTS_DIR := fonts/pdftex
PDFTEX_FONTSETS := ipaex ipa haranoaji
PDFTEX_FONT_PROFILES := jlreq-pdftex-fonts-ipaex.def jlreq-pdftex-fonts-ipa.def jlreq-pdftex-fonts-haranoaji.def
# The asset list comes from the generator's manifest (not a wildcard over
# existing files: a wildcard is empty on a fresh checkout and make would
# skip the build).
PDFTEX_FONT_ASSETS := $(filter-out $(PDFTEX_FONT_PROFILES),$(shell python3 make_pdftex_fonts.py --print-manifest))

# 生成物は repo root からの相対 outdir（fonts/pdftex）へ出す:
# ttf2tfm は TFM ヘッダに起動引数のパスを焼き付けるため、outdir を
# 変えると配布物とバイト一致しなくなる（絶対パス outdir では
# "Created by" 文字列が変わる）。二重の manifest 共有は無い: この
# 生成器の資源一覧は PDFTEX_FONT_ASSETS（JFM manifest とは独立）。
# GNU make 4.3 grouped target &: 全出力をこの一つのrecipeが所有する
# （-j4 で単一recipeだけが走る）。
$(addprefix $(PDFTEX_FONTS_DIR)/,$(PDFTEX_FONT_PROFILES) $(PDFTEX_FONT_ASSETS))&: make_pdftex_fonts.py
	@for fs in $(PDFTEX_FONTSETS); do \
	  python3 make_pdftex_fonts.py --fontset $$fs --outdir $(PDFTEX_FONTS_DIR) || exit 1; \
	done
	@echo "pdftex-fonts: built aux vertical fonts + profiles into $(PDFTEX_FONTS_DIR)"

pdftex-fonts: $(addprefix $(PDFTEX_FONTS_DIR)/,$(PDFTEX_FONT_PROFILES) $(PDFTEX_FONT_ASSETS))

# 決定性（2回生成のバイト一致）+ 構造検査（tests/check-pdftex-fonts.py）。
# 退避/比較は一時ディレクトリ（mktemp）で行う: 固定名のチェックdirは
# 並列makeで衝突するため廃止。再生成は repo root からの相対 outdir
# （＝配布物と同一の TFM ヘッダになる）で行う。
check-pdftex-fonts: pdftex-fonts
	@tmp=`mktemp -d "$${TMPDIR:-/tmp}/pdftex-fonts-check.XXXXXXXX"`; \
	trap 'rm -rf "$$tmp"' EXIT HUP INT TERM; \
	cp -r $(PDFTEX_FONTS_DIR) "$$tmp/regen" || exit 1; \
	$(MAKE) pdftex-fonts || exit 1; \
	diff -r "$$tmp/regen" $(PDFTEX_FONTS_DIR) || { \
	  echo "FAIL: regeneration is not byte-identical"; exit 1; }; \
	python3 tests/check-pdftex-fonts.py $(PDFTEX_FONTS_DIR) $(PDFTEX_FONT_PROFILES) || exit 1; \
	echo "check-pdftex-fonts: deterministic regeneration + structural checks OK"


# 静的検査のみ（再生成なし）。check_jfm_pdftex.lua は既定で manifest に
# 記載の12ファイルを全検証する。
check-pdftex-jfm-static:
	texlua check_jfm_pdftex.lua


# .pl
ujlreq-v.pl ubjlreq-v.pl uzjlreq-v.pl ubzjlreq-v.pl: u%-v.pl: jfm-%v-pl.lua luajfm2pl.lua
	texlua luajfm2pl.lua $*v-pl $@

jlreq-v.pl bjlreq-v.pl zjlreq-v.pl bzjlreq-v.pl: %-v.pl: jfm-%v-pl.lua luajfm2pl.lua
	texlua luajfm2pl.lua --noutf $*v-pl $@

ujlreq.pl ubjlreq.pl uzjlreq.pl ubzjlreq.pl: u%.pl: jfm-%-pl.lua luajfm2pl.lua
	texlua luajfm2pl.lua $*-pl $@

jlreq.pl bjlreq.pl zjlreq.pl bzjlreq.pl: %.pl: jfm-%-pl.lua luajfm2pl.lua
	texlua luajfm2pl.lua --noutf $*-pl $@

jlreq-jidori.pl: jfm-jlreq-jidori-pl.lua
	texlua luajfm2pl.lua --noutf jlreq-jidori-pl $@

jlreq-v-jidori.pl: jfm-jlreqv-jidori-pl.lua
	texlua luajfm2pl.lua --noutf jlreqv-jidori-pl $@

ujlreq-jidori.pl: jfm-jlreq-jidori-pl.lua
	texlua luajfm2pl.lua jlreq-jidori-pl $@

ujlreq-v-jidori.pl: jfm-jlreqv-jidori-pl.lua
	texlua luajfm2pl.lua jlreqv-jidori-pl $@


# .vf
ujlreqg-q.vf ubjlreqg-q.vf uzjlreqg-q.vf ubzjlreqg-q.vf: %.vf: %.tfm
	makejvf -i -u jisq $< upgbm-hq.tfm

ujlreq-q.vf ubjlreq-q.vf uzjlreq-q.vf ubzjlreq-q.vf: %.vf: %.tfm
	makejvf -i -u jisq $< uprml-hq.tfm

ujlreqg-v.vf ubjlreqg-v.vf uzjlreqg-v.vf ubzjlreqg-v.vf: %.vf: %.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} $< upgbm-v.tfm

ujlreqg.vf ubjlreqg.vf uzjlreqg.vf ubzjlreqg.vf: %.vf: %.tfm %-q.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} -H -U $*-q $< upgbm-h.tfm

jlreqg-v.vf bjlreqg-v.vf zjlreqg-v.vf bzjlreqg-v.vf: %.vf: %.tfm
	makejvf -i $< gbmv.tfm

jlreqg.vf bjlreqg.vf zjlreqg.vf bzjlreqg.vf: %.vf: %.tfm
	makejvf -i $< gbm.tfm

ujlreq-v.vf ubjlreq-v.vf uzjlreq-v.vf ubzjlreq-v.vf: %.vf: %.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} $< uprml-v.tfm

jlreq-v.vf bjlreq-v.vf zjlreq-v.vf bzjlreq-v.vf: %.vf: %.tfm
	makejvf -i $< rmlv.tfm

ujlreq.vf ubjlreq.vf uzjlreq.vf ubzjlreq.vf: %.vf: %.tfm %-q.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} -H -U $*-q $< uprml-h.tfm

jlreq.vf bjlreq.vf zjlreq.vf bzjlreq.vf: %.vf: %.tfm
	makejvf -i $< rml.tfm

jlreq-jidori.vf: jlreq-jidori.tfm
	makejvf  -i $< rml.tfm

jlreq-v-jidori.vf: jlreq-v-jidori.tfm
	makejvf  -i $< rmlv.tfm

jlreqg-jidori.vf: jlreqg-jidori.tfm
	makejvf  -i $< gbm.tfm

jlreqg-v-jidori.vf: jlreqg-v-jidori.tfm
	makejvf  -i $< gbmv.tfm

ujlreq-jidori-q.vf: ujlreq-jidori-q.tfm
	makejvf -i -u jisq $< uprml-hq.tfm

ujlreqg-jidori-q.vf: ujlreqg-jidori-q.tfm
	makejvf -i -u jisq $< upgbm-hq.tfm

ujlreq-jidori.vf: ujlreq-jidori.tfm ujlreq-jidori-q.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} -H -U ujlreq-jidori-q $< uprml-h.tfm

ujlreq-v-jidori.vf: ujlreq-v-jidori.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} -H $< uprml-v.tfm

ujlreqg-jidori.vf: ujlreqg-jidori.tfm ujlreqg-jidori-q.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} -H -U ujlreqg-jidori-q $< upgbm-h.tfm

ujlreqg-v-jidori.vf: ujlreqg-v-jidori.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} -H $< upgbm-v.tfm


# .tfm
ujlreq-q.tfm ubjlreq-q.tfm uzjlreq-q.tfm ubzjlreq-q.tfm: %-q.tfm: %.pl
	uppltotf -kanji=uptex $< $@

ujlreqg-q.tfm ubjlreqg-q.tfm uzjlreqg-q.tfm ubzjlreqg-q.tfm: %g-q.tfm: %-q.tfm
	cp $< $@

jlreqg-v.tfm bjlreqg-v.tfm zjlreqg-v.tfm bzjlreqg-v.tfm ujlreqg-v.tfm ubjlreqg-v.tfm uzjlreqg-v.tfm ubzjlreqg-v.tfm: %g-v.tfm: %-v.tfm
	cp $< $@

jlreqg.tfm bjlreqg.tfm zjlreqg.tfm bzjlreqg.tfm ujlreqg.tfm ubjlreqg.tfm uzjlreqg.tfm ubzjlreqg.tfm: %g.tfm: %.tfm
	cp $< $@

ujlreq.tfm ubjlreq.tfm uzjlreq.tfm ubzjlreq.tfm ujlreq-v.tfm ubjlreq-v.tfm uzjlreq-v.tfm ubzjlreq-v.tfm: %.tfm: %.pl
	uppltotf -kanji=uptex $< $@

jlreq.tfm bjlreq.tfm zjlreq.tfm bzjlreq.tfm jlreq-v.tfm bjlreq-v.tfm zjlreq-v.tfm bzjlreq-v.tfm: %.tfm: %.pl
	ppltotf -kanji=utf8 $< $@

ujlreq-jidori.tfm ujlreq-v-jidori.tfm: %.tfm: %.pl
	uppltotf -kanji=uptex $< $@

jlreq-jidori.tfm jlreq-v-jidori.tfm: %.tfm: %.pl
	ppltotf -kanji=utf8 $< $@

ujlreqg-jidori.tfm: ujlreq-jidori.tfm
	cp $< $@

ujlreqg-v-jidori.tfm: ujlreq-v-jidori.tfm
	cp $< $@

jlreqg-jidori.tfm: jlreq-jidori.tfm
	cp $< $@

jlreqg-v-jidori.tfm: jlreq-v-jidori.tfm
	cp $< $@

ujlreq-jidori-q.tfm: ujlreq-jidori.pl
	uppltotf -kanji=uptex $< $@

ujlreqg-jidori-q.tfm: ujlreq-jidori-q.tfm
	cp $< $@


jfm-jlreqv.lua jfm-jlreq-pl.lua jfm-bjlreq-pl.lua jfm-zjlreq-pl.lua jfm-bzjlreq-pl.lua jfm-jlreqv-pl.lua jfm-bjlreqv-pl.lua jfm-zjlreqv-pl.lua jfm-bzjlreqv-pl.lua jfm-jlreqv-jidori.lua jfm-jlreq-jidori-pl.lua jfm-jlreqv-jidori-pl.lua: make_variant_jfm.lua jfm-jlreq.lua jfm-jlreq-jidori.lua
	texlua make_variant_jfm.lua

doc: pdfdoc htmldoc

latexdoc: jlreq.tex jlreq-ja.tex

jlreq%tex: README%md README-template.tex
	pandoc --verbose -f gfm -t latex --pdf-engine=lualatex --template README-template.tex $< -o $@

pdfdoc: jlreq.pdf jlreq-ja.pdf

# 文書PDFのフォントプリセット。既定は上流テンプレートの hiragino-pron
# （Hiragino を持つ環境向け）。Hiragino の無い環境（CI 等）では
# README_LTPRESET=ipaex を渡してビルドする（フォント資源不足を
# SKIPにしない: プリセットを明示指定しない場合はビルドが失敗する）。
README_LTPRESET ?= hiragino-pron
jlreq.pdf: README.md README-template.tex
	sed 's/hiragino-pron/$(README_LTPRESET)/' README-template.tex > jlreq.template.tex
	sed -e "s/\\[README-ja.md\\](README-ja.md)/[jlreq-ja.pdf](jlreq-ja.pdf)/" README.md | pandoc --verbose -f gfm -t latex --pdf-engine=lualatex --template jlreq.template.tex -o $@
	rm -f jlreq.template.tex

jlreq-ja.pdf: README-ja.md README-template.tex
	sed 's/hiragino-pron/$(README_LTPRESET)/' README-template.tex > jlreq-ja.template.tex
	pandoc --verbose -f gfm -t latex --pdf-engine=lualatex --template jlreq-ja.template.tex -o $@ README-ja.md
	rm -f jlreq-ja.template.tex

htmldoc: jlreq.html jlreq-ja.html jlreq-trimmarks.html jlreq-trimmarks-ja.html

jlreq-ja.html: README-ja.md README-template.html
	pandoc --verbose -f gfm -t html5 -V lang=ja -M title=jlreq --template README-template.html -o jlreq-ja.html README-ja.md

jlreq.html: README.md README-template.html
	sed -e "s/\\[README-ja.md\\](README-ja.md)/[jlreq-ja.html](jlreq-ja.html)/" README.md | pandoc --verbose -f gfm -t html5 -V lang=en -M title=jlreq --template README-template.html -o jlreq.html

jlreq-trimmarks-ja.html: jlreq-trimmarks-ja.md README-template.html
	pandoc --verbose -f gfm -t html5 -V lang=ja -M title=jlreq-trimmarks --template README-template.html -o jlreq-trimmarks-ja.html jlreq-trimmarks-ja.md

jlreq-trimmarks.html: jlreq-trimmarks.md README-template.html
	pandoc --verbose -f gfm -t html5 -V lang=en -M title=jlreq-trimmarks --template README-template.html -o jlreq-trimmarks.html jlreq-trimmarks.md


jfm-install: jfm
	mkdir -p ${JLREQ_TEXMF}/fonts/tfm/public/jlreq
	install ${TFMS} ${JLREQ_TEXMF}/fonts/tfm/public/jlreq
	mkdir -p ${JLREQ_TEXMF}/fonts/vf/public/jlreq
	install ${VFS} ${JLREQ_TEXMF}/fonts/vf/public/jlreq
	mkdir -p ${JLREQ_TEXMF}/tex/luatex/jlreq
	install jfm-jlreqv.lua jfm-jlreq.lua jfm-jlreq-jidori.lua jfm-jlreqv-jidori.lua ${JLREQ_TEXMF}/tex/luatex/jlreq

cls-install:
	mkdir -p ${JLREQ_TEXMF}/tex/latex/jlreq
	install jlreq-helpers.sty ${JLREQ_TEXMF}/tex/latex/jlreq
	install jlreq-complements.sty ${JLREQ_TEXMF}/tex/latex/jlreq
	install jlreq.cls ${JLREQ_TEXMF}/tex/latex/jlreq
	install jlreq-pdftex.sty ${JLREQ_TEXMF}/tex/latex/jlreq
	install jlreq-pdftex-rules.sty ${JLREQ_TEXMF}/tex/latex/jlreq
	install jlreq-pdftex-ruby.sty ${JLREQ_TEXMF}/tex/latex/jlreq
	install jlreq-pdftex-paragraph.sty ${JLREQ_TEXMF}/tex/latex/jlreq
	install $(addprefix ${PDFTEX_FONTS_DIR}/,${PDFTEX_FONT_PROFILES}) ${JLREQ_TEXMF}/tex/latex/jlreq
	mkdir -p ${JLREQ_TEXMF}/fonts/truetype/jlreq-pdftex
	install ${PDFTEX_FONTS_DIR}/jlreqv-*.ttf ${JLREQ_TEXMF}/fonts/truetype/jlreq-pdftex
	install ${PDFTEX_FONTS_DIR}/haranoaji-*-ttf.ttf ${JLREQ_TEXMF}/fonts/truetype/jlreq-pdftex
	mkdir -p ${JLREQ_TEXMF}/fonts/tfm/jlreq-pdftex
	install ${PDFTEX_FONTS_DIR}/jlreqv-*.tfm ${JLREQ_TEXMF}/fonts/tfm/jlreq-pdftex
	mkdir -p ${JLREQ_TEXMF}/fonts/enc/jlreq-pdftex
	install ${PDFTEX_FONTS_DIR}/jlreqv-*.enc ${JLREQ_TEXMF}/fonts/enc/jlreq-pdftex
	install ${PDFTEX_JFM_DEFS} ${PDFTEX_JFM_MANIFEST} ${JLREQ_TEXMF}/tex/latex/jlreq
	mkdir -p ${JLREQ_TEXMF}/doc/latex/jlreq
	install ${PDFTEX_FONTS_DIR}/LICENSE-aux-*.txt ${JLREQ_TEXMF}/doc/latex/jlreq

sty-install:
	mkdir -p ${JLREQ_TEXMF}/tex/latex/jlreq
	install jlreq-trimmarks.sty ${JLREQ_TEXMF}/tex/latex/jlreq
	install jlreq-trimmarks-pdftex.def ${JLREQ_TEXMF}/tex/latex/jlreq

# pdftex-jfm/pdftex-fonts: cls-install globs jlreqv-*.ttf/.tfm/.enc and the
# JFM .defs (all build outputs) -- a fresh checkout has none of them, so bare
# `make install` would die on the glob. Mirror the tds: prereqs.
install: jfm-install cls-install sty-install pdftex-jfm pdftex-fonts

tds: jfm pdftex-jfm pdftex-fonts pdfdoc htmldoc jlreq.cls README.md README-ja.md LICENSE
	mkdir -p ./tds/fonts/tfm/public/jlreq
	cp -f ${TFMS} ./tds/fonts/tfm/public/jlreq
	mkdir -p ./tds/fonts/vf/public/jlreq
	cp -f ${VFS} ./tds/fonts/vf/public/jlreq
	mkdir -p ./tds/tex/luatex/jlreq
	cp jfm-jlreq.lua ./tds/tex/luatex/jlreq
	cp jfm-jlreqv.lua ./tds/tex/luatex/jlreq
	cp jfm-jlreq-jidori.lua ./tds/tex/luatex/jlreq
	cp jfm-jlreqv-jidori.lua ./tds/tex/luatex/jlreq
	mkdir -p ./tds/tex/latex/jlreq
	cp jlreq.cls ./tds/tex/latex/jlreq
	cp jlreq-helpers.sty ./tds/tex/latex/jlreq
	cp jlreq-complements.sty ./tds/tex/latex/jlreq
	cp jlreq-trimmarks.sty ./tds/tex/latex/jlreq
	cp jlreq-trimmarks-pdftex.def ./tds/tex/latex/jlreq
	cp jlreq-pdftex.sty ./tds/tex/latex/jlreq
	cp jlreq-pdftex-rules.sty ./tds/tex/latex/jlreq
	cp jlreq-pdftex-ruby.sty ./tds/tex/latex/jlreq
	cp jlreq-pdftex-paragraph.sty ./tds/tex/latex/jlreq
	cp $(PDFTEX_JFM_DEFS) $(PDFTEX_JFM_MANIFEST) ./tds/tex/latex/jlreq
	cp $(addprefix ${PDFTEX_FONTS_DIR}/,${PDFTEX_FONT_PROFILES}) ./tds/tex/latex/jlreq

	mkdir -p ./tds/fonts/truetype/jlreq-pdftex
	cp ${PDFTEX_FONTS_DIR}/jlreqv-*.ttf ./tds/fonts/truetype/jlreq-pdftex
	cp ${PDFTEX_FONTS_DIR}/haranoaji-*-ttf.ttf ./tds/fonts/truetype/jlreq-pdftex
	mkdir -p ./tds/fonts/tfm/jlreq-pdftex
	cp ${PDFTEX_FONTS_DIR}/jlreqv-*.tfm ./tds/fonts/tfm/jlreq-pdftex
	mkdir -p ./tds/fonts/enc/jlreq-pdftex
	cp ${PDFTEX_FONTS_DIR}/jlreqv-*.enc ./tds/fonts/enc/jlreq-pdftex
	mkdir -p ./tds/doc/latex/jlreq
	cp README.md ./tds/doc/latex/jlreq
	cp README-ja.md ./tds/doc/latex/jlreq
	cp jlreq-trimmarks.md ./tds/doc/latex/jlreq
	cp jlreq-trimmarks-ja.md ./tds/doc/latex/jlreq
	cp docs/pdftex-compatibility.md ./tds/doc/latex/jlreq
	cp docs/pdftex-internals.md ./tds/doc/latex/jlreq
	cp docs/pdftex-tests.md ./tds/doc/latex/jlreq
	cp docs/pdftex-jfm-generation.md ./tds/doc/latex/jlreq
	cp docs/pdftex-dependencies.md ./tds/doc/latex/jlreq
	cp ${PDFTEX_FONTS_DIR}/LICENSE-aux-*.txt ./tds/doc/latex/jlreq
	cp LICENSE ./tds/doc/latex/jlreq
	cp jlreq.html ./tds/doc/latex/jlreq
	cp jlreq-ja.html ./tds/doc/latex/jlreq
	cp jlreq-trimmarks.html ./tds/doc/latex/jlreq
	cp jlreq-trimmarks-ja.html ./tds/doc/latex/jlreq
	cp jlreq.pdf ./tds/doc/latex/jlreq
	cp jlreq-ja.pdf ./tds/doc/latex/jlreq
	mkdir -p ./tds/source/latex/jlreq
	cp README-template.html ./tds/source/latex/jlreq
	cp README-template.tex ./tds/source/latex/jlreq
	cp Makefile ./tds/source/latex/jlreq
	cp make_variant_jfm.lua ./tds/source/latex/jlreq
	cp luajfm2pl.lua ./tds/source/latex/jlreq
	cp make_pdftex_jfm.lua ./tds/source/latex/jlreq
	cp check_jfm_pdftex.lua ./tds/source/latex/jlreq
	cp make_pdftex_fonts.py ./tds/source/latex/jlreq
	cp tests/check-pdftex-fonts.py ./tds/source/latex/jlreq

uninstall:
	rm -rf ${JLREQ_TEXMF}/fonts/tfm/public/jlreq
	rm -rf ${JLREQ_TEXMF}/fonts/vf/public/jlreq
	rm -rf ${JLREQ_TEXMF}/tex/luatex/jlreq
	rm -rf ${JLREQ_TEXMF}/tex/latex/jlreq
	rm -rf ${JLREQ_TEXMF}/fonts/truetype/jlreq-pdftex
	rm -rf ${JLREQ_TEXMF}/fonts/tfm/jlreq-pdftex
	rm -rf ${JLREQ_TEXMF}/fonts/enc/jlreq-pdftex

jfmclean:
	rm -f *jlreq*.pl ${VFS} ${TFMS}
	rm -f jfm-jlreqv.lua
	rm -f jfm-*jlreq*-pl.lua
	rm -f jfm-jlreqv-jidori.lua
	rm -rf pdftex-jfm-check pdftex-fonts-check

docclean:
	rm -f jlreq.tex jlreq.pdf jlreq.html jlreq-ja.tex jlreq-ja.pdf jlreq-ja.html jlreq-trimmarks.html jlreq-trimmarks-ja.html

clean: jfmclean docclean


