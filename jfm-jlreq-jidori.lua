local jfm = {
	dir = 'yoko',
	zw = 1.0,
	zh = 1.0,
	kanjiskip = {0, 0, 0},
	xkanjiskip = {0.25, 0.25, 0.125},
	version = 3,
	[0] = { -- = [19]
		left = 0,
		align = 'middle',
		width = 1,height = 0.88,depth = 0.12,
		glue = {
			[1] = {0.5, 0, 0, kanjiskip_stretch = 1, kanjiskip_shrink = 1},
			[2] = {0, 0, 0},
		}
	},
	[1] = { -- 始め括弧類
		chars = {'（', '〔', '［', '｛', '〈', '《', '「', '『', '【', '｟', '〘', '〖', '«', '〝',
			'‘', '“'},
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'right',
		glue = {
			[0] = {0, 0, 0},
			[1] = {0, 0, 0},
			[2] = {0, 0, 0},
			[8] = {0, 0, 0},
			[27] = {0, 0, 0},
		}
	},
	[2] = { -- 終わり括弧類
		chars = { '）', '〕', '］', '｝', '〉', '》', '」', '』', '】', '｠', '〙', '〗', '»', '〟',
			 '’', '”'},
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'left',
		glue = {
			[0] = {0.5, 0, 0, kanjiskip_stretch = 1, kanjiskip_shrink = 1},
			[1] = {0.5, 0, 0, kanjiskip_stretch = 1, kanjiskip_shrink = 1},
			[2] = {0, 0, 0},
			[8] = {0.5, 0, 0, kanjiskip_stretch = 1, kanjiskip_shrink = 1},
			[27] = {0.5, 0, 0, kanjiskip_stretch = 1, kanjiskip_shrink = 1},
		}
	},
	[8] = { -- 分離禁止文字
		chars = {'—', '…', '‥', '〳', '〴', '〵'},
		width = 1,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, 0, 0, kanjiskip_stretch = 1, kanjiskip_shrink = 1},
			[2] = {0, 0, 0},
			[8] = {0, 0, 0},
		}
	},
	[14] = { -- 和字間隔
		chars = {'　'},
		align = 'middle',
		width= 1,height = 0.88,depth = 0.12,
		glue = {
			[0] = {0, 0, 0},
			[1] = {0, 0, 0},
			[2] = {0, 0, 0},
			[8] = {0, 0, 0},
			[27] = {0, 0, 0},
		},
	},
	[27] = {-- 欧文
		chars = {'alchar'},
		glue = {
			[1] = {0.5, 0, 0, kanjiskip_stretch = 1, kanjiskip_shrink = 1},
			[2] = {0, 0, 0},
			[27] = {0, 0, 0},
		}
	},
	[90] = { -- 行頭
		chars = {'parbdd','boxbdd'},
		glue = {
			[1] = {0, 0, 0},
		},
	},
}

luatexja.jfont.define_jfm(jfm)

