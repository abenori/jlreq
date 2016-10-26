TEXMF=$(shell kpsewhich -var-value=TEXMFHOME)




all: jfm

jfm: \
	jfm-jlreqv.lua jfm-bjlreq.lua jfm-bjlreqv.lua jfm-bzjlreq.lua jfm-bzjlreqv.lua \
	jlreq.tfm bjlreq.tfm zjlreq.tfm bzjlreq.tfm \
	jlreq.vf bjlreq.vf zjlreq.vf bzjlreq.vf \
	ujlreq.tfm ubjlreq.tfm uzjlreq.tfm ubzjlreq.tfm \
	ujlreq.vf ubjlreq.vf uzjlreq.vf ubzjlreq.vf \
	jlreqg.tfm bjlreqg.tfm zjlreqg.tfm bzjlreqg.tfm \
	jlreqg.vf bjlreqg.vf zjlreqg.vf bzjlreqg.vf \
	ujlreqg.tfm ubjlreqg.tfm uzjlreqg.tfm ubzjlreqg.tfm \
	ujlreqg.vf ubjlreqg.vf uzjlreqg.vf ubzjlreqg.vf \
	jlreq-v.tfm bjlreq-v.tfm zjlreq-v.tfm bzjlreq-v.tfm \
	jlreq-v.vf bjlreq-v.vf zjlreq-v.vf bzjlreq-v.vf \
	ujlreq-v.tfm ubjlreq-v.tfm uzjlreq-v.tfm ubzjlreq-v.tfm \
	ujlreq-v.vf ubjlreq-v.vf uzjlreq-v.vf ubzjlreq-v.vf \
	jlreqg-v.tfm bjlreqg-v.tfm zjlreqg-v.tfm bzjlreqg-v.tfm \
	jlreqg-v.vf bjlreqg-v.vf zjlreqg-v.vf bzjlreqg-v.vf \
	ujlreqg-v.tfm ubjlreqg-v.tfm uzjlreqg-v.tfm ubzjlreqg-v.tfm \
	ujlreqg-v.vf ubjlreqg-v.vf uzjlreqg-v.vf ubzjlreqg-v.vf \

u%-v.pl: jfm-%v.lua luajfm2pl.lua
	texlua luajfm2pl.lua $*v $@

%-v.pl: jfm-%v.lua luajfm2pl.lua
	texlua luajfm2pl.lua --noutf $*v $@

u%.pl: jfm-%.lua luajfm2pl.lua
	texlua luajfm2pl.lua $* $@

%.pl: jfm-%.lua luajfm2pl.lua
	texlua luajfm2pl.lua --noutf $* $@

u%g-v.vf: u%g-v.tfm
	makejvf -i -u jis $< ugbmv.tfm

u%g.vf: u%g.tfm
	makejvf -i -u jis $< ugbm.tfm

%g-v.vf: %g-v.tfm
	makejvf -i $< gbmv.tfm

%g.vf: %g.tfm
	makejvf -i $< gbm.tfm

u%-v.vf: u%-v.tfm
	makejvf -i -u jis $< urmlv.tfm

%-v.vf: %-v.tfm
	makejvf -i $< rmlv.tfm

u%.vf: u%.tfm
	makejvf -i -u jis $< urml.tfm

%.vf: %.tfm
	makejvf -i $< rml.tfm

u%.tfm: u%.pl
	uppltotf $< $@

%.tfm: %.pl
	ppltotf $< $@

%g-v.tfm: %-v.tfm
	cp $< $@

%g.tfm: %.tfm
	cp $< $@


jfm-%v.lua jfm-b%,lua jfm-z%.lua: make_variant_jfm.lua jfm-jlreq.lua
	texlua make_variant_jfm.lua

doc:
	pandoc --verbose -f markdown_github README.md -o README.pdf -V documentclass=jlreq --latex-engine=lualatex

latexdoc:
	pandoc --verbose --standalone -f markdown_github README.md -o README.tex -V documentclass=jlreq --latex-engine=lualatex

install: jfm
	mkdir -p ${TEXMF}/fonts/tfm/public/jlreq
	mv -f *.tfm ${TEXMF}/fonts/tfm/public/jlreq
	mkdir -p ${TEXMF}/fonts/vf/public/jlreq
	mv -f *.vf ${TEXMF}/fonts/vf/public/jlreq

uninstall:
	rm -rf ${TEXMF}/fonts/tfm/public/jlreq
	rm -rf ${TEXMF}/fonts/vf/public/jlreq

clean:
	rm -f *.tfm *.pl *.vf
	rm -f jfm-jlreqv.lua
	rm -f jfm-bjlreq.lua jfm-bjlreqv.lua jfm-bzjlreq.lua jfm-bzjlreqv.lua

