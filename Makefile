TEXMF=$(shell kpsewhich -var-value=TEXMFHOME)

all: jfm

jfm: \
	jfm-jlreqv.lua \
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
	
	rm -f rml.tfm rmlv.tfm gbm.tfm gbmv.tfm uprml-h.tfm uprml-hq.tfm upgbm-h.tfm upgbm-hq.tfm uprml-v.tfm uprml-vq.tfm upgbm-v.tfm upgbm-vq.tfm

# .pl
u%-v.pl: jfm-%v.lua luajfm2pl.lua
	texlua luajfm2pl.lua $*v $@

%-v.pl: jfm-%v.lua luajfm2pl.lua
	texlua luajfm2pl.lua --noutf $*v $@

u%.pl: jfm-%.lua luajfm2pl.lua
	texlua luajfm2pl.lua $* $@

%.pl: jfm-%.lua luajfm2pl.lua
	texlua luajfm2pl.lua --noutf $* $@

# .vf
u%g-q.vf: u%g-q.tfm
	makejvf -u jisq $< upgbm-hq.tfm

u%-q.vf: u%-q.tfm
	makejvf -u jisq $< uprml-hq.tfm

u%g-v.vf: u%g-v.tfm
	makejvf -i -u jis $< upgbm-v.tfm

u%g.vf: u%g.tfm u%g-q.tfm
	makejvf -i -u jis -U u$*g-q $< upgbm-h.tfm

%g-v.vf: %g-v.tfm
	makejvf -i $< gbmv.tfm

%g.vf: %g.tfm
	makejvf -i $< gbm.tfm

u%-v.vf: u%-v.tfm
	makejvf -i -u jis $< uprml-v.tfm

%-v.vf: %-v.tfm
	makejvf -i $< rmlv.tfm

u%.vf: u%.tfm u%-q.tfm
	makejvf -i -u jis -U u$*-q $< uprml-h.tfm

%.vf: %.tfm
	makejvf -i $< rml.tfm

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

jfm-%v.lua jfm-b%.lua jfm-z%.lua: make_variant_jfm.lua jfm-jlreq.lua
	texlua make_variant_jfm.lua

doc: pdfdoc htmldoc

latexdoc: jlreq.tex jlreq-ja.tex

jlreq%tex: README%md README-template.tex
	pandoc --verbose -f gfm -t latex --pdf-engine=lualatex --template README-template.tex $< -o $@

pdfdoc: jlreq.pdf jlreq-ja.pdf

jlreq%pdf: README%md README-template.tex
	pandoc --verbose -f gfm -t latex --pdf-engine=lualatex --template README-template.tex $< -o $@

htmldoc: jlreq.html jlreq-ja.html

jlreq-ja.html: README-ja.md README-template.html
	pandoc --verbose -f gfm -t html5 -V lang=ja -M title=jlreq --template README-template.html -o jlreq-ja.html README-ja.md

jlreq.html: README.md README-template.html
	pandoc --verbose -f gfm -t html5 -V lang=ja -M title=jlreq --template README-template.html -o jlreq.html README.md

jfm-install: jfm
	mkdir -p ${TEXMF}/fonts/tfm/public/jlreq
	install *.tfm ${TEXMF}/fonts/tfm/public/jlreq
	mkdir -p ${TEXMF}/fonts/vf/public/jlreq
	install *.vf ${TEXMF}/fonts/vf/public/jlreq
	mkdir -p ${TEXMF}/tex/luatex/jlreq
	install jfm-jlreqv.lua jfm-jlreq.lua ${TEXMF}/tex/luatex/jlreq

cls-install:
	mkdir -p ${TEXMF}/tex/latex/jlreq
	install jlreq.cls ${TEXMF}/tex/latex/jlreq

install: jfm-install cls-install

tds: jfm jlreq.cls README.md README-ja.md LICENSE jlreq.html jlreq-ja.html
	mkdir -p ./tds/fonts/tfm/public/jlreq
	cp -f *.tfm ./tds/fonts/tfm/public/jlreq
	mkdir -p ./tds/fonts/vf/public/jlreq
	cp -f *.vf ./tds/fonts/vf/public/jlreq
	mkdir -p ./tds/tex/luatex/jlreq
	cp jfm-jlreq.lua ./tds/tex/luatex/jlreq
	cp jfm-jlreqv.lua ./tds/tex/luatex/jlreq
	mkdir -p ./tds/tex/latex/jlreq
	cp jlreq.cls ./tds/tex/latex/jlreq
	mkdir -p ./tds/doc/latex/jlreq
	cp README.md ./tds/doc/latex/jlreq
	cp README-ja.md ./tds/doc/latex/jlreq
	cp LICENSE ./tds/doc/latex/jlreq
	cp jlreq.html ./tds/doc/latex/jlreq
	cp jlreq-ja.html ./tds/doc/latex/jlreq

uninstall:
	rm -rf ${TEXMF}/fonts/tfm/public/jlreq
	rm -rf ${TEXMF}/fonts/vf/public/jlreq

clean:
	rm -f *.tfm *.pl *.vf
	rm -f jfm-jlreqv.lua
	rm -f jfm-bjlreq.lua jfm-bjlreqv.lua jfm-bzjlreq.lua jfm-bzjlreqv.lua jfm-zjlreq.lua jfm-zjlreqv.lua
	rm -f jlreq.tex jlreq.pdf jlreq.html jlreq-ja.tex jlreq-ja.pdf jlreq-ja.html

