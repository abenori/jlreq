TEXMF:=$(shell kpsewhich -var-value=TEXMFHOME)
MAKEJVFCNF:=$(shell ls -R $(shell kpsewhich --var-value=TEXMFDIST)/fonts/source | awk '/:$$/{sub(/:$$/,"");f=$$0} tolower($$0) ~ /makejvf-upjpn\.cnf$$/{print f"/"$$0}' | head -n 1)

.PHONY: all jfm doc latexdoc pdfdoc htmldoc jfm-install cls-install sty-install install tds uninstall jfmclean docclean clean

all: jfm

jfm: \
	jfm-jlreqv.lua jfm-jlreqv-jidori.lua \
	jlreq.tfm bjlreq.tfm zjlreq.tfm bzjlreq.tfm \
	jlreq.vf bjlreq.vf zjlreq.vf bzjlreq.vf \
	ujlreq.tfm ubjlreq.tfm uzjlreq.tfm ubzjlreq.tfm \
	ujlreq.vf ubjlreq.vf uzjlreq.vf ubzjlreq.vf \
	ujlreq-q.tfm ubjlreq-q.tfm uzjlreq-q.tfm ubzjlreq-q.tfm \
	ujlreq-q.vf ubjlreq-q.vf uzjlreq-q.vf ubzjlreq-q.vf \
	jlreqg.tfm bjlreqg.tfm zjlreqg.tfm bzjlreqg.tfm \
	jlreqg.vf bjlreqg.vf zjlreqg.vf bzjlreqg.vf \
	ujlreqg.tfm ubjlreqg.tfm uzjlreqg.tfm ubzjlreqg.tfm \
	ujlreqg.vf ubjlreqg.vf uzjlreqg.vf ubzjlreqg.vf \
	ujlreqg-q.tfm ubjlreqg-q.tfm uzjlreqg-q.tfm ubzjlreqg-q.tfm \
	ujlreqg-q.vf ubjlreqg-q.vf uzjlreqg-q.vf ubzjlreqg-q.vf \
	jlreq-v.tfm bjlreq-v.tfm zjlreq-v.tfm bzjlreq-v.tfm \
	jlreq-v.vf bjlreq-v.vf zjlreq-v.vf bzjlreq-v.vf \
	ujlreq-v.tfm ubjlreq-v.tfm uzjlreq-v.tfm ubzjlreq-v.tfm \
	ujlreq-v.vf ubjlreq-v.vf uzjlreq-v.vf ubzjlreq-v.vf \
	jlreqg-v.tfm bjlreqg-v.tfm zjlreqg-v.tfm bzjlreqg-v.tfm \
	jlreqg-v.vf bjlreqg-v.vf zjlreqg-v.vf bzjlreqg-v.vf \
	ujlreqg-v.tfm ubjlreqg-v.tfm uzjlreqg-v.tfm ubzjlreqg-v.tfm \
	ujlreqg-v.vf ubjlreqg-v.vf uzjlreqg-v.vf ubzjlreqg-v.vf \
	jlreq-jidori.tfm jlreq-jidori.vf jlreqg-jidori.tfm jlreqg-jidori.vf \
	jlreq-v-jidori.tfm jlreq-v-jidori.vf jlreqg-v-jidori.tfm jlreqg-v-jidori.vf \
	ujlreq-jidori.tfm ujlreq-jidori.vf ujlreqg-jidori.tfm ujlreqg-jidori.vf \
	ujlreq-jidori-q.tfm ujlreq-jidori-q.vf ujlreqg-jidori-q.tfm ujlreqg-jidori-q.vf \
	ujlreq-v-jidori.tfm ujlreq-v-jidori.vf ujlreqg-v-jidori.tfm ujlreqg-v-jidori.vf
	
	rm -f rml.tfm rmlv.tfm gbm.tfm gbmv.tfm uprml-h.tfm uprml-hq.tfm upgbm-h.tfm upgbm-hq.tfm uprml-v.tfm uprml-vq.tfm upgbm-v.tfm upgbm-vq.tfm

# .pl
u%-v.pl: jfm-%v-pl.lua luajfm2pl.lua
	texlua luajfm2pl.lua $*v-pl $@

%-v.pl: jfm-%v-pl.lua luajfm2pl.lua
	texlua luajfm2pl.lua --noutf $*v-pl $@

u%.pl: jfm-%-pl.lua luajfm2pl.lua
	texlua luajfm2pl.lua $*-pl $@

%.pl: jfm-%-pl.lua luajfm2pl.lua
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
u%g-q.vf: u%g-q.tfm
	makejvf -i -u jisq $< upgbm-hq.tfm

u%-q.vf: u%-q.tfm
	makejvf -i -u jisq $< uprml-hq.tfm

u%g-v.vf: u%g-v.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} $< upgbm-v.tfm

u%g.vf: u%g.tfm u%g-q.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} -H -U u$*g-q $< upgbm-h.tfm

%g-v.vf: %g-v.tfm
	makejvf -i $< gbmv.tfm

%g.vf: %g.tfm
	makejvf -i $< gbm.tfm

u%-v.vf: u%-v.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} $< uprml-v.tfm

%-v.vf: %-v.tfm
	makejvf -i $< rmlv.tfm

u%.vf: u%.tfm u%-q.tfm
	makejvf -i -u custom -t ${MAKEJVFCNF} -H -U u$*-q $< uprml-h.tfm

%.vf: %.tfm
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
u%-q.tfm: u%.pl
	uppltotf -kanji=uptex $< $@

u%g-q.tfm: u%-q.tfm
	cp $< $@

%g-v.tfm: %-v.tfm
	cp $< $@

%g.tfm: %.tfm
	cp $< $@

u%.tfm: u%.pl
	uppltotf -kanji=uptex $< $@

%.tfm: %.pl
	ppltotf -kanji=utf8 $< $@

ujlreq%-jidori.tfm: ujlreq%-jidori.pl
	uppltotf -kanji=uptex $< $@

jlreq%-jidori.tfm: jlreq%-jidori.pl
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

jlreq.pdf: README.md README-template.tex
	sed -e "s/\\[README-ja.md\\](README-ja.md)/[jlreq-ja.pdf](jlreq-ja.pdf)/" README.md | pandoc --verbose -f gfm -t latex --pdf-engine=lualatex --template README-template.tex -o $@

jlreq-ja.pdf: README-ja.md README-template.tex
	pandoc --verbose -f gfm -t latex --pdf-engine=lualatex --template README-template.tex $< -o $@

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
	mkdir -p ${TEXMF}/fonts/tfm/public/jlreq
	install *.tfm ${TEXMF}/fonts/tfm/public/jlreq
	mkdir -p ${TEXMF}/fonts/vf/public/jlreq
	install *.vf ${TEXMF}/fonts/vf/public/jlreq
	mkdir -p ${TEXMF}/tex/luatex/jlreq
	install jfm-jlreqv.lua jfm-jlreq.lua jfm-jlreq-jidori.lua jfm-jlreqv-jidori.lua ${TEXMF}/tex/luatex/jlreq

cls-install:
	mkdir -p ${TEXMF}/tex/latex/jlreq
	install jlreq-helpers.sty ${TEXMF}/tex/latex/jlreq
	install jlreq-complements.sty ${TEXMF}/tex/latex/jlreq
	install jlreq.cls ${TEXMF}/tex/latex/jlreq

sty-install:
	mkdir -p ${TEXMF}/tex/latex/jlreq
	install jlreq-trimmarks.sty ${TEXMF}/tex/latex/jlreq

install: jfm-install cls-install sty-install

tds: jfm jlreq.cls README.md README-ja.md LICENSE jlreq.html jlreq-ja.html jlreq-trimmarks.html jlreq-trimmarks-ja.html jlreq.pdf jlreq-ja.pdf
	mkdir -p ./tds/fonts/tfm/public/jlreq
	cp -f *.tfm ./tds/fonts/tfm/public/jlreq
	mkdir -p ./tds/fonts/vf/public/jlreq
	cp -f *.vf ./tds/fonts/vf/public/jlreq
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
	mkdir -p ./tds/doc/latex/jlreq
	cp README.md ./tds/doc/latex/jlreq
	cp README-ja.md ./tds/doc/latex/jlreq
	cp jlreq-trimmarks.md ./tds/doc/latex/jlreq
	cp jlreq-trimmarks-ja.md ./tds/doc/latex/jlreq
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

uninstall:
	rm -rf ${TEXMF}/fonts/tfm/public/jlreq
	rm -rf ${TEXMF}/fonts/vf/public/jlreq
	rm -rf ${TEXMF}/tex/luatex/jlreq
	rm -rf ${TEXMF}/tex/latex/jlreq

jfmclean:
	rm -f *jlreq*.tfm *jlreq*.pl *jlreq*.vf
	rm -f jfm-jlreqv.lua
	rm -f jfm-*jlreq*-pl.lua
	rm -f jfm-jlreqv-jidori.lua

docclean:
	rm -f jlreq.tex jlreq.pdf jlreq.html jlreq-ja.tex jlreq-ja.pdf jlreq-ja.html jlreq-trimmarks.html jlreq-trimmarks-ja.html

clean: jfmclean docclean


