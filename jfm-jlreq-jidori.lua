local jfm = {
	dir = 'yoko',
	zw = 1.0,
	zh = 1.0,
	-- 使わない
	kanjiskip = {0, 0, 0},
	xkanjiskip = {0, 0, 0},
	version = 3,
	[0] = {
		left = 0,
		align = 'middle',
		width = 1,height = 0.88,depth = 0.12,
		glue = {
			[1] = {0.5, 0, 0, kanjiskip_stretch = 1},
			[2] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, kanjiskip_stretch = 1},
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
			[300] = {0, 0, 0},
			[301] = {0, 0, 0},
			[302] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1},
			[7] = {0, 0, 0},
			[8] = {0, 0, 0},
			[14] = {0, 0, 0},
			[27] = {0, 0, 0},
		}
	},
	[2] = { -- 終わり括弧類
		chars = { '）', '〕', '］', '｝', '〉', '》', '」', '』', '】', '｠', '〙', '〗', '»', '〟',
			 '’', '”'},
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'left',
		glue = {
			[0] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[1] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[2] = {0, 0, 0},
			[300] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[301] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[302] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, kanjiskip_stretch = 1},
			[8] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[27] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
		}
	},
	[300] = {
		chars = {'‐'},
		width = 0.25,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, 0, 0.5, ratio = 1, kanjiskip_stretch = 1},
			[2] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
		}
	},
	
	[301] = {
		chars = {'゠', '–'},
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, 0, 0.5, ratio = 1, kanjiskip_stretch = 1},
			[2] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
		}
	},

	[302] = {
		chars = {'〜'},
		width = 1,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, 0, 0.5, ratio = 1, kanjiskip_stretch = 1},
			[2] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
		}
	},
	[5] = { -- 中点類
		chars = {'・', '：', 
			'；'
		},
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[0] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
			[1] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
			[2] = {0.25, 0, 0.25, ratio = 0},
			[300] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
			[301] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
			[302] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
			[5] = {0.25, 0, 0.25, ratio = 0.5, kanjiskip_stretch = 1},
			[6] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
			[7] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
			[8] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
			[14] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
			[27] = {0.25, 0, 0.25, ratio = 0, kanjiskip_stretch = 1},
		}
	},
	[6] = { -- 句点類
		chars = {'。', 
			'．'}, -- 縦書きでは使わない
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'left',
		glue = {
			[0] = {0.5, 0, 0, ratio = 0, kanjiskip_stretch = 1},
			[1] = {0.5, 0, 0, ratio = 0, kanjiskip_stretch = 1},
			[2] = {0, 0, 0},
			[300] = {0.5, 0, 0, ratio = 0, kanjiskip_stretch = 1},
			[301] = {0.5, 0, 0, ratio = 0, kanjiskip_stretch = 1},
			[302] = {0.5, 0, 0, ratio = 0, kanjiskip_stretch = 1},
			[5] = {0.75, 0, 0.25, ratio = 0.33333333, kanjiskip_stretch = 1},
			[8] = {0.5, 0, 0, ratio = 0, kanjiskip_stretch = 1},
			[14] = {0.5, 0, 0, ratio = 0, kanjiskip_stretch = 1},
			[27] = {0.5, 0, 0, ratio = 0, kanjiskip_stretch = 1},
		}
	},
	[7] = { -- 読点類
		chars = {'、', 
			'，'}, -- 縦書きでは使わない
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'left',
		glue = {
			[0] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[1] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[2] = {0, 0, 0},
			[300] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[301] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[302] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[5] = {0.75, 0, 0.75, ratio = 0.33333333, kanjiskip_stretch = 1},
			[8] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[14] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
			[27] = {0.5, 0, 0.5, ratio = 0, kanjiskip_stretch = 1},
		}
	},
	[8] = { -- 分離禁止文字
		chars = {'—', '…', '‥', '〳', '〴', '〵'},
		width = 1,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, 0, 0.5, ratio = 1, kanjiskip_stretch = 1},
			[2] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1, kanjiskip_stretch = 1},
			[8] = {0, 0, 0},
		}
	},
	[14] = { -- 和字間隔，前には空きが入り後ろには入らないようにする．
		chars = {'　'},
		align = 'middle',
		width= 1,height = 0.88,depth = 0.12,
		glue = {
			[0] = {0, 0, 0},
			[1] = {0, 0, 0},
			[2] = {0, 0, 0},
			[300] = {0, 0, 0},
			[301] = {0, 0, 0},
			[302] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1},
			[6] = {0, 0, 0},
			[8] = {0, 0, 0},
			[27] = {0, 0, 0},
		},
	},
	[27] = {-- 欧文
		chars = {'alchar'},
		glue = {
			[1] = {0.5, 0, 0, kanjiskip_stretch = 1},
			[2] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1, kanjiskip_stretch = 1},
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

