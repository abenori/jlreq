all: ujlreq-v.vf ujlreq-v.tfm

ujlreq-v.vf: ujlreq-v.tfm
	makejvf -i -u jis ujlreq-v.tfm urmlv.tfm

ujlreq-v.tfm: ujlreq-v.pl
	uppltotf ujlreq-v.pl ujlreq-v.tfm

ujlreq-v.pl: jfm-jlreqv.lua luajfm2pl.lua
	texlua luajfm2pl.lua jlreqv ujlreq-v.pl

