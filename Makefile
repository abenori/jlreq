all: \
	jlreq-v.tfm bjlreq-v.tfm zjlreq-v.tfm bzjlreq-v.tfm \
	jlreq-v.vf bjlreq-v.vf zjlreq-v.vf bzjlreq-v.vf \
	ujlreq-v.tfm ubjlreq-v.tfm uzjlreq-v.tfm ubzjlreq-v.tfm \
	ujlreq-v.vf ubjlreq-v.vf uzjlreq-v.vf ubzjlreq-v.vf \
	jlreqg-v.tfm bjlreqg-v.tfm zjlreqg-v.tfm bzjlreqg-v.tfm \
	jlreqg-v.vf bjlreqg-v.vf zjlreqg-v.vf bzjlreqg-v.vf \
	ujlreqg-v.tfm ubjlreqg-v.tfm uzjlreqg-v.tfm ubzjlreqg-v.tfm \
	ujlreqg-v.vf ubjlreqg-v.vf uzjlreqg-v.vf ubzjlreqg-v.vf \

%-v.tfm: %-v.pl
	ppltotf $< $@

u%-v.tfm: u%-v.pl
	uppltotf $< $@

u%-v.vf: u%-v.tfm
	makejvf -i -u jis $< urmlv.tfm

%-v.vf: %-v.tfm
	makejvf -i -u jis $< rmlv.tfm

%g-v.tfm: %-v.tfm
	cp $< $@

%g-v.vf: %g-v.tfm
	makejvf -i -u jis $< gbmv.tfm

u%g-v.vf: u%g-v.tfm
	makejvf -i -u jis $< ugbmv.tfm

u%-v.pl:  jfm-%v.lua luajfm2pl.lua
	texlua luajfm2pl.lua $*v $@

%-v.pl:  jfm-%v.lua luajfm2pl.lua
	texlua luajfm2pl.lua --noutf $*v $@

jfm-%.lua: make_variant_jfm.lua
	texlua make_variant_jfm.lua

clean:
	rm -f *.tfm *.pl *.vf
