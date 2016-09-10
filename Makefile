all: \
	jfm-jlreqv.lua \
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

%.pl: jfm-%.lua luajfm2pl.lua
	texlua luajfm2pl.lua --noutf $* $@

u%.pl: jfm-%.lua luajfm2pl.lua
	texlua luajfm2pl.lua $* $@

%-v.pl: jfm-%v.lua luajfm2pl.lua
	texlua luajfm2pl.lua --noutf $*v $@

u%-v.pl: jfm-%v.lua luajfm2pl.lua
	texlua luajfm2pl.lua $*v $@

%.tfm: %.pl
	ppltotf $< $@

u%.tfm: u%.pl
	uppltotf $< $@

%g-v.tfm: %-v.tfm
	cp $< $@

%g.tfm: %.tfm
	cp $< $@

%.vf: %.tfm
	makejvf -i -u jis $< rml.tfm

u%.vf: u%.tfm
	makejvf -i -u jis $< urml.tfm

%-v.vf: %-v.tfm
	makejvf -i -u jis $< rmlv.tfm

u%-v.vf: u%-v.tfm
	makejvf -i -u jis $< urmlv.tfm

%g.vf: %g.tfm
	makejvf -i -u jis $< gbm.tfm

%g-v.vf: %g-v.tfm
	makejvf -i -u jis $< gbmv.tfm

u%g.vf: u%g.tfm
	makejvf -i -u jis $< ugbm.tfm

u%g-v.vf: u%g-v.tfm
	makejvf -i -u jis $< ugbmv.tfm

jfm-%v.lua jfm-b%,lua jfm-z%.lua: make_variant_jfm.lua
	texlua make_variant_jfm.lua

clean:
	rm -f *.tfm *.pl *.vf
	rm -f jfm-jlreqv.lua

