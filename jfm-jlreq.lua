--[[
3.1.3
3.1.6.a
]]

--[[
優先順位は，第n段階を3 - nに対応させる．
  段階   1, 2, 3, 4, 5, 6
priority 2, 1, 0,-1,-2,-3
xkanjiskipは{1,-3},kanjiskip={0,0}
\ltjsetparameter{stretch_priority={kanjiskip=1,xkanjiskip=-3}}
\ltjsetparameter{stretch_priority={kanjiskip=0,xkanjiskip=0}}
]]

local stretch_width = 0.25 -- 空き第四段階の空き量

local jfm = {
	dir = 'yoko',
	zw = 1.0,
	zh = 1.0,
	version = 3,
	-- 文字クラス4,9,10,11,15,16,19との間は(x)kanjiskipで調整する．
	kanjiskip = {0, 0.25, 0},
	xkanjiskip = {0.25, 0.25, 0.125},
	
	-- alignは適当
	[1] = { -- 始め括弧類
		chars = {'（', '〔', '［', '｛', '〈', '《', '「', '『', '【', '｟', '〘', '〖', '«', '〝',
			'‘', '“'},
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'right',
		glue = {
			[1] = {0, 0, 0, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0, 0, 0, kanjiskip_natural = 1},
			[9] = {0, 0, 0, kanjiskip_natural = 1},
			[10] = {0, 0, 0, kanjiskip_natural = 1},
			[11] = {0, 0, 0, kanjiskip_natural = 1},
			[12] = {0, 0, 0, kanjiskip_natural = 1},
			[13] = {0, 0, 0, kanjiskip_natural = 1},
			[14] = {0, 0, 0, kanjiskip_natural = 1},
			[15] = {0, 0, 0, kanjiskip_natural = 1},
			[16] = {0, 0, 0, kanjiskip_natural = 1},
			[0] = {0, 0, 0, kanjiskip_natural = 1},
			[27] = {0, 0, 0, kanjiskip_natural = 1},
--[[
			[20] = {0, 0, 0},
			[21] = {0, 0, 0},
			[22] = {0, 0, 0},
			[23] = {0, 0, 0},
			[24] = {0, 0, 0},
			[25] = {0, 0, 0},
			[26] = {0, 0, 0},
			[28] = {0, 0, 0},
			[29] = {0, 0, 0},
			[30] = {0, 0, 0},
			-- [22][23] 注1
		]]
		},
	},
	
	[2] = { -- 終わり括弧類
		chars = { '）', '〕', '］', '｝', '〉', '》', '」', '』', '】', '｠', '〙', '〗', '»', '〟',
			 '’', '”'},
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'left',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}, kanjiskip_natural = 1},
			[4] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[9] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}, kanjiskip_natural = 1},
			[10] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}, kanjiskip_natural = 1},
			[11] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}, kanjiskip_natural = 1},
			[12] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[13] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[14] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[15] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[16] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[0] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[27] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[22] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[23] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[24] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[25] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[26] = {0.5, 0, 0, ratio = 0, priority = {0,-2}},
			[28] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[29] = {0, 0, 0},
			[30] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
		]]
		},
		end_adjust = {0.5,0},
	},
	
	-- [3*]はハイフン類．幅が違うので分ける．
	[300] = {
		chars = {'‐'},
		width = 0.25,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[9] = {0, 0, 0, kanjiskip_natural = 1},
			[10] = {0, 0, 0, kanjiskip_natural = 1},
			[11] = {0, 0, 0, kanjiskip_natural = 1},
			[12] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[13] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[14] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[15] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[16] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[0] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[27] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
--[[
			[20] = {0, 0, 0},
			[21] = {0, 0, 0},
			[22] = {0, 0, 0},
			[23] = {0, 0, 0},
			[24] = {0, 0, 0},
			[25] = {0, 0, 0},
			[26] = {0, 0, 0},
			[28] = {0, 0, 0},
			[29] = {0, 0, 0},
			[30] = {0, 0, 0},
]]
		}
	},
	
	[301] = {
		chars = {'゠', '–'},
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {} -- 後で処理
	},

	[302] = {
		chars = {'〜'},
		width = 1,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {} -- 後で処理
	},

	[4] = { -- 区切り約物
		chars = {'！', '？', '‼', '⁇', '⁈', '⁉'},
		width = 1,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, stretch_width, 0.25, ratio = 1, priority = {-1,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[9] = {0, 0, 0, kanjiskip_natural = 1},
			[10] = {0, 0, 0, kanjiskip_natural = 1},
			[11] = {0, 0, 0, kanjiskip_natural = 1},
			[12] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[13] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[14] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[15] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[16] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[0] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
--			[27] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[22] = {0, 0, 0},
			[23] = {0, 0, 0},
			[24] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[25] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[26] = {0, 0, 0},
			[28] = {0, 0, 0},
			[29] = {0, 0, 0},
			[30] = {0, 0, 0},
		]]
		},
	},
	
	[5] = { -- 中点類
		chars = {'・', '：', 
			'；'
		},
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.25, stretch_width, 0.25, ratio = 0, priority = {-1,-1}, kanjiskip_natural = 1},
			[2] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}, kanjiskip_natural = 1},
			[300] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}, kanjiskip_natural = 1},
			[4] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}, kanjiskip_natural = 1},
			[5] = {0.5, 0, 0.5, ratio = 0.5, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}, kanjiskip_natural = 1},
			[7] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}, kanjiskip_natural = 1},
			[8] = {0.25, stretch_width, 0.25, ratio = 0, priority = {-1,-1}, kanjiskip_natural = 1},
			[9] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}, kanjiskip_natural = 1},
			[10] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}, kanjiskip_natural = 1},
			[11] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}, kanjiskip_natural = 1},
			[12] = {0.25, stretch_width, 0.25, ratio = 0, priority = {-1,-1}, kanjiskip_natural = 1},
			[13] = {0.25, stretch_width, 0.25, ratio = 0, priority = {-1,-1}, kanjiskip_natural = 1},
			[14] = {0.25, stretch_width, 0.25, ratio = 0, priority = {-1,-1}, kanjiskip_natural = 1},
			[15] = {0.25, stretch_width, 0.25, ratio = 0, priority = {-1,-1}, kanjiskip_natural = 1},
			[16] = {0.25, stretch_width, 0.25, ratio = 0, priority = {-1,-1}, kanjiskip_natural = 1},
			[0] = {0.25, stretch_width, 0.25, ratio = 0, priority = {-1,-1}, kanjiskip_natural = 1},
			[27] = {0.25, stretch_width, 0.25, ratio = 0, priority = {-1,-1}, kanjiskip_natural = 1},
		--[[
			[20] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}},
			[21] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}},
			[22] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}},
			[23] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}},
			[24] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}},
			[25] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}},
			[26] = {0.25, 0, 0, ratio = 0, priority = {0,-1}},
			[28] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}},
			[29] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}},
			[30] = {0.25, 0, 0.25, ratio = 0, priority = {0,-1}},
		]]
		},
		end_adjust = {0.25,0}, -- 0.25 -> 0は詰め，優先順位は第三段階
	},
	
	[6] = { -- 句点類
		chars = {'。', 
			'．'}, -- 縦書きでは使わない
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'left',
		glue = {
			[1] = {0.5, stretch_width, 0, ratio = 0, priority = {-1,0}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0.5, 0, 0, ratio = 0, kanjiskip_natural = 1},
			[4] = {0.5, 0, 0, ratio = 0, kanjiskip_natural = 1},
			[5] = {0.75, 0, 0.25, ratio = 0.33333333, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0.5, stretch_width, 0, ratio = 0, priority = {-1,0}, kanjiskip_natural = 1},
			[9] = {0.5, 0, 0, ratio = 0, kanjiskip_natural = 1},
			[10] = {0.5, 0, 0, ratio = 0, kanjiskip_natural = 1},
			[11] = {0.5, 0, 0, ratio = 0, kanjiskip_natural = 1},
			[12] = {0.5, stretch_width, 0, ratio = 0, priority = {-1,0}, kanjiskip_natural = 1},
			[13] = {0.5, stretch_width, 0, ratio = 0, priority = {-1,0}, kanjiskip_natural = 1},
			[14] = {0.5, stretch_width, 0, ratio = 0, priority = {-1,0}, kanjiskip_natural = 1},
			[15] = {0.5, stretch_width, 0, ratio = 0, priority = {-1,0}, kanjiskip_natural = 1},
			[16] = {0.5, stretch_width, 0, ratio = 0, priority = {-1,0}, kanjiskip_natural = 1},
			[0] = {0.5, stretch_width, 0, ratio = 0, priority = {-1,0}, kanjiskip_natural = 1},
			[27] = {0.5, stretch_width, 0, ratio = 0, priority = {-1,0}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0.5, 0, 0, ratio = 0},
			[22] = {0.5, 0, 0, ratio = 0},
			[23] = {0.5, 0, 0, ratio = 0},
			[24] = {0.5, 0, 0, ratio = 0},
			[25] = {0.5, 0, 0, ratio = 0},
			[26] = {0.5, 0, 0, ratio = 0},
			[28] = {0.5, 0, 0, ratio = 0},
			[29] = {0.5, 0, 0, ratio = 0},
			[30] = {0.5, 0, 0, ratio = 0},
		]]
		},
		end_adjust = {0.5, 0},
	},
	
	[7] = { -- 読点類
		chars = {'、', 
			'，'}, -- 縦書きでは使わない
		width = 0.5,height = 0.88,depth = 0.12,
		align = 'left',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}, kanjiskip_natural = 1},
			[4] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}, kanjiskip_natural = 1},
			[5] = {0.75, 0, 0.75, ratio = 0.33333333, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[9] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}, kanjiskip_natural = 1},
			[10] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}, kanjiskip_natural = 1},
			[11] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}, kanjiskip_natural = 1},
			[12] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[13] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[14] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[15] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[16] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[0] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
			[27] = {0.5, stretch_width, 0.5, ratio = 0, priority = {-1,-2}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[22] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[23] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[24] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[25] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[26] = {0.5, 0, 0, ratio = 0, priority = {0,-2}},
			[28] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[29] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
			[30] = {0.5, 0, 0.5, ratio = 0, priority = {0,-2}},
		]]
		},
		end_adjust = {0.5, 0},
	},
	
	[8] = { -- 分離禁止文字
		chars = {'—', '…', '‥', '〳', '〴', '〵'},
		width = 1,height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0, 0, 0}, -- 空き注4
--			[9] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[10] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[11] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[12] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[13] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[14] = {0, 0, 0, kanjiskip_natural = 1},
--			[15] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[16] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[0] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[27] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0, 0.25, 0, priority = {0,0}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0, 0, 0},
			[25] = {0, 0, 0},
			[26] = {0, 0, 0},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		]]
		},
	},
	
	[9] = { -- 繰返し記号
		chars = {'ヽ', 'ヾ', 'ゝ', 'ゞ', '々', '〻'},
		height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
--			[9] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[10] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[11] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[12] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[13] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[14] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
--			[15] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[16] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[0] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[27] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[25] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[26] = {0, 0, 0},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		]]
		},
	},

	[10] = { -- 長音記号
		chars = {'ー'},
		height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
--			[9] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[10] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[11] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[12] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[13] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[14] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
--			[15] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[16] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[0] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[27] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[25] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[26] = {0, 0, 0},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		]]
		},
	},
	
	[11] = { -- 小書きの仮名
		chars = {'ぁ', 'ぃ', 'ぅ', 'ぇ', 'ぉ', 'ァ', 'ィ', 'ゥ', 'ェ', 'ォ', 'っ', 'ゃ', 'ゅ', 'ょ', 'ゎ', 'ゕ', 'ゖ', 'ッ', 'ャ', 'ュ', 'ョ', 'ヮ', 'ヵ', 'ヶ', 'ㇰ', 'ㇱ', 'ㇲ', 'ㇳ', 'ㇴ', 'ㇵ', 'ㇶ', 'ㇷ', 'ㇸ', 'ㇹ', 'ㇺ', 'ㇻ', 'ㇼ', 'ㇽ', 'ㇾ', 'ㇿ', 'ㇷ゚'},
		height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
--			[9] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[10] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[11] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[12] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[13] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[14] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
--			[15] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[16] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[0] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[27] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0.25, 0, 0.125, ratio = 0, priority = {1,-3}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0.25, 0, 0.125, ratio = 0, priority = {1,-3}},
			[25] = {0.25, 0, 0.125, ratio = 0, priority = {1,-3}},
			[26] = {0, 0, 0},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		]]
		},
	},
	
	[12] = { -- 前置省略記号
		chars = {'￥', '＄', '￡', '＃', '€', '№'},
		height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, 0, 0.5, ratio = 1, priority = {0,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
--			[8] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[9] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[10] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[11] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[12] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[13] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[14] = {0, 0, 0, kanjiskip_natural = 1},
--			[15] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[16] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[0] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[27] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0, 0.25, 0, priority = {0,0}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0, 0, 0},
			[25] = {0, 0.25, 0, priority = {0,0}},
			[26] = {0, 0, 0},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		]]
		},
	},
	
	[13] = { -- 後置省略記号
		chars = {'°', '′', '″', '℃', '￠', '％', '‰', '㏋', 'ℓ', '㌃', '㌍', '㌔', '㌘', '㌢', '㌣', '㌦', '㌧', '㌫', '㌶', '㌻', '㍉', '㍊', '㍍', '㍑', '㍗', '㎎', '㎏', '㎜', '㎝', '㎞', '㎡', '㏄'},
		height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
--			[8] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[9] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[10] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[11] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[12] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[13] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[14] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
--			[15] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[16] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[0] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[27] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0, 0.25, 0, priority = {0,0}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0, 0.25, 0, priority = {0,0}},
			[25] = {0, 0.25, 0, priority = {0,0}},
			[26] = {0, 0, 0},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		]]
		},
	},
	
	[14] = { -- 和字間隔
		chars = {'　'},
		align = 'middle',
		width= 1,height = 0.88,depth = 0.12,
		glue = {
			[1] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[9] = {0, 0, 0, kanjiskip_natural = 1},
			[10] = {0, 0, 0, kanjiskip_natural = 1},
			[11] = {0, 0, 0, kanjiskip_natural = 1},
			[12] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[13] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[14] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[15] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[16] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[0] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
			[27] = {0, stretch_width, 0, priority = {-1,0}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0, 0, 0},
			[22] = {0, 0, 0},
			[23] = {0, 0, 0},
			[24] = {0, 0, 0},
			[25] = {0, 0, 0},
			[26] = {0, 0, 0},
			[28] = {0, 0, 0},
			[29] = {0, 0, 0},
			[30] = {0, 0, 0},
		]]
		},
	},
	
	[15] = { -- 平仮名
		chars = {'あ', 'い', 'う', 'え', 'お', 'か', 'が', 'き', 'ぎ', 'く', 'ぐ', 'け', 'げ', 'こ', 'ご', 'さ', 'ざ', 'し', 'じ', 'す', 'ず', 'せ', 'ぜ', 'そ', 'ぞ', 'た', 'だ', 'ち', 'ぢ', 'つ', 'づ', 'て', 'で', 'と', 'ど', 'な', 'に', 'ぬ', 'ね', 'の', 'は', 'ば', 'ぱ', 'ひ', 'び', 'ぴ', 'ふ', 'ぶ', 'ぷ', 'へ', 'べ', 'ぺ', 'ほ', 'ぼ', 'ぽ', 'ま', 'み', 'む', 'め', 'も', 'や', 'ゆ', 'よ', 'ら', 'り', 'る', 'れ', 'ろ', 'わ', 'ゐ', 'ゑ', 'を', 'ん', 'ゔ', 'か゚', 'き゚', 'く゚', 'け゚', 'こ゚'},
		height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
--			[8] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[9] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[10] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[11] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[12] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[13] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[14] = {0, 0, 0, kanjiskip_natural = 1},
--			[15] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[16] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[0] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[27] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[25] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[26] = {0, 0, 0},
		]]
		--[[
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		]]
		},
	},
	
	[16] = { -- 片仮名
		chars = {'ア', 'イ', 'ウ', 'エ', 'オ', 'カ', 'ガ', 'キ', 'ギ', 'ク', 'グ', 'ケ', 'ゲ', 'コ', 'ゴ', 'サ', 'ザ', 'シ', 'ジ', 'ス', 'ズ', 'セ', 'ゼ', 'ソ', 'ゾ', 'タ', 'ダ', 'チ', 'ヂ', 'ツ', 'ヅ', 'テ', 'デ', 'ト', 'ド', 'ナ', 'ニ', 'ヌ', 'ネ', 'ノ', 'ハ', 'バ', 'パ', 'ヒ', 'ビ', 'ピ', 'フ', 'ブ', 'プ', 'ヘ', 'ベ', 'ペ', 'ホ', 'ボ', 'ポ', 'マ', 'ミ', 'ム', 'メ', 'モ', 'ヤ', 'ユ', 'ヨ', 'ラ', 'リ', 'ル', 'レ', 'ロ', 'ワ', 'ヰ', 'ヱ', 'ヲ', 'ン', 'ヴ', 'ヷ', 'ヸ', 'ヹ', 'ヺ', 'カ゚', 'キ゚', 'ク゚', 'ケ゚', 'コ゚', 'セ゚', 'ツ゚', 'ト゚'},
		height = 0.88,depth = 0.12,
		align = 'middle',
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
--			[8] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[9] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[10] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[11] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[12] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[13] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[14] = {0, 0, 0, kanjiskip_natural = 1},
--			[15] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[16] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[0] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[27] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[25] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[26] = {0, 0, 0},
		]]
		--[[
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		]]
		},
	},

	[161] = { -- 半角カナ
      chars = {'ｦ', 'ｧ', 'ｨ', 'ｩ', 'ｪ', 'ｫ', 'ｬ', 'ｭ', 'ｮ', 'ｯ', 'ｰ', 'ｱ', 'ｲ', 'ｳ', 'ｴ', 'ｵ', 'ｶ', 'ｷ', 'ｸ', 'ｹ', 'ｺ', 'ｻ', 'ｼ', 'ｽ', 'ｾ', 'ｿ', 'ﾀ', 'ﾁ', 'ﾂ', 'ﾃ', 'ﾄ', 'ﾅ', 'ﾆ', 'ﾇ', 'ﾈ', 'ﾉ', 'ﾊ', 'ﾋ', 'ﾌ', 'ﾍ', 'ﾎ', 'ﾏ', 'ﾐ', 'ﾑ', 'ﾒ', 'ﾓ', 'ﾔ', 'ﾕ', 'ﾖ', 'ﾗ', 'ﾘ', 'ﾙ', 'ﾚ', 'ﾛ', 'ﾜ', 'ﾝ','｡', '｢', '｣', '､', '･', 'ﾞ', 'ﾟ'},
		width = 0.5, height = 0.88, depth = 0.12,
		align = 'left',
		glue = {} -- あとで処理
	},

	
	--[[
	[17] = { -- 等号類
		chars = {'＝', '≠', '≒', '≃', '≅', '≈', '≡', '≢', '＜', '＞', '≦', '≧', '≪', '≫', '≶', '≷', '⋚', '⋛', '∧', '∨', '⌅', '⌆', '⊂', '⊃', '⊄', '⊅', '⊆', '⊇', '⊊', '⊋', '∈', '∋', '∉', '∪', '∩', '∥', '∦', '⇒', '⇔', '↔', '∽', '∝', '⊥', '⊕', '⊗'},
		align = 'middle',
		width = 1,
	},
	
	[18] = { -- 演算記号
		chars = {'＋', '－', '×', '÷', '±', '∓'},
		align = 'middle',
		width = 1,
	},
	]]
	
	-- [19] -- 漢字等：「その他の和文」として[0]で扱う
	[0] = { -- = [19]
		left = 0,
		align = 'middle',
		width = 1,height = 0.88,depth = 0.12,
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
--			[8] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[9] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[10] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[11] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[12] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[13] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[14] = {0, 0, 0, kanjiskip_natural = 1},
--			[15] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[16] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[0] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[27] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}, kanjiskip_natural = 1},
		--[[
			[20] = {0, 0, 0},
			[21] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[25] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[26] = {0, 0, 0},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		]]
		},
	},
	[191] = { -- 1/2数字，よくわからないので漢字等と同じ扱いにする
		left = 0,
		chars = {"AJ1-247","AJ1-248","AJ1-249","AJ1-250","AJ1-251","AJ1-252","AJ1-253","AJ1-254","AJ1-255","AJ1-256"},
		align = 'left',
		width = 0.5,height = 0.88,depth = 0.12,
		glue = { -- あとで処理
		},
	},
	[192] = { -- 1/3数字，同様
		left = 0,
		chars = {"AJ1-9758","AJ1-9759","AJ1-9760","AJ1-9761","AJ1-9762","AJ1-9763","AJ1-9764","AJ1-9765","AJ1-9766","AJ1-9767"},
		align = 'left',
		width = 1/3,height = 0.88,depth = 0.12,
		glue = { -- あとで処理
		},
	},
	[193] = { -- 1/4数字，同様
		left = 0,
		chars = {"AJ1-9738","AJ1-9739","AJ1-9740","AJ1-9741","AJ1-9742","AJ1-9743","AJ1-9744","AJ1-9745","AJ1-9746","AJ1-9747"},
		align = 'left',
		width = 1/4,height = 0.88,depth = 0.12,
		glue = { -- あとで処理
		},
	},

	
	--[[
	[20] = { -- 合印中の文字
		glue = {
			[1] = {0,5, 0, 0.5, ratio = 1, priority = {0,-2}},
			[2] = {0, 0, 0},
			[300] = {0, 0, 0},
			[4] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}},
			[6] = {0, 0, 0},
			[7] = {0, 0, 0},
			[8] = {0, 0.25, 0, priority = {0,0}},
			[9] = {0, 0.25, 0, priority = {0,0}},
			[10] = {0, 0.25, 0, priority = {0,0}},
			[11] = {0, 0.25, 0, priority = {0,0}},
			[12] = {0, 0.25, 0, priority = {0,0}},
			[13] = {0, 0.25, 0, priority = {0,0}},
			[14] = {0, 0, 0},
			[15] = {0, 0.25, 0, priority = {0,0}},
			[16] = {0, 0.25, 0, priority = {0,0}},
			[0] = {0, 0.25, 0, priority = {0,0}},
			[20] = {0, 0, 0},
			[21] = {0, 0.25, 0, priority = {0,0}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0, 0.25, 0, priority = {0,0}},
			[25] = {0, 0.25, 0, priority = {0,0}},
			[26] = {0, 0, 0},
			[27] = {0, 0.25, 0, priority = {0,0}},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		},
	},
	
	[21] = {-- 親文字群中の文字（添え字付き）
		glue = {
			[1] = {0,5, 0, 0.5, ratio = 1, priority = {0,-2}},
			[2] = {0, 0, 0},
			[300] = {0, 0, 0},
			[4] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}},
			[6] = {0, 0, 0},
			[7] = {0, 0, 0},
			[8] = {0, 0.25, 0, priority = {0,0}},
			[9] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[10] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[11] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[12] = {0, 0.25, 0, priority = {0,0}},
			[13] = {0, 0.25, 0, priority = {0,0}},
			[14] = {0, 0, 0},
			[15] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[16] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[0] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[20] = {0, 0, 0},
			[21] = {0, 0, 0},-- 注9，空け注5
			[22] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[23] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[24] = {0, 0.25, 0, priority = {0,0}},
			[25] = {0, 0.25, 0, priority = {0,0}},
			[26] = {0, 0, 0},
			[27] = {0, 0.25, 0, priority = {0,0}},
			[28] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},表6と表3が整合的でない
			[29] = {0, 0, 0},
			[30] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
		},
	},
	
	[22] = { -- 親文字群中の文字（熟語ルビ以外のルビ付き）
		glue = {
			[1] = {0,5, 0, 0.5, ratio = 1, priority = {0,-2}},
			[2] = {0, 0, 0},
			[300] = {0, 0, 0},
			[4] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}},
			[6] = {0, 0, 0},
			[7] = {0, 0, 0},
			[8] = {0, 0.25, 0, priority = {0,0}},
			[9] = {0, 0.25, 0, priority = {0,0}},
			[10] = {0, 0.25, 0, priority = {0,0}},
			[11] = {0, 0.25, 0, priority = {0,0}},
			[12] = {0, 0.25, 0, priority = {0,0}},
			[13] = {0, 0.25, 0, priority = {0,0}},
			[14] = {0, 0, 0},
			[15] = {0, 0.25, 0, priority = {0,0}},
			[16] = {0, 0.25, 0, priority = {0,0}},
			[0] = {0, 0.25, 0, priority = {0,0}},
			[20] = {0, 0, 0},
			[21] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[22] = {0, 0.25, 0, priority = {0,0}}, -- 空け注10
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[25] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[26] = {0, 0, 0},
			[27] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		},
	},
	
	[23] = { -- 親文字群中の文字（熟語ルビ付き）
		glue = {
			[1] = {0,5, 0, 0.5, ratio = 1, priority = {0,-2}},
			[2] = {0, 0, 0},
			[300] = {0, 0, 0},
			[4] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}},
			[6] = {0, 0, 0},
			[7] = {0, 0, 0},
			[8] = {0, 0.25, 0, priority = {0,0}},
			[9] = {0, 0.25, 0, priority = {0,0}},
			[10] = {0, 0.25, 0, priority = {0,0}},
			[11] = {0, 0.25, 0, priority = {0,0}},
			[12] = {0, 0.25, 0, priority = {0,0}},
			[13] = {0, 0.25, 0, priority = {0,0}},
			[14] = {0, 0, 0},
			[15] = {0, 0.25, 0, priority = {0,0}},
			[16] = {0, 0.25, 0, priority = {0,0}},
			[0] = {0, 0.25, 0, priority = {0,0}},
			[20] = {0, 0, 0},
			[21] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},-- 空け注7
			[24] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[25] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[26] = {0, 0, 0},
			[27] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		},
	},
	
	[24] = { -- 連数字中の文字
		chars = {'	', ',', '.', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'},
		glue = {
			[1] = {0,5, 0, 0.5, ratio = 1, priority = {0,-2}},
			[2] = {0, 0, 0},
			[300] = {0, 0, 0},
			[4] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}},
			[6] = {0, 0, 0},
			[7] = {0, 0, 0},
			[8] = {0, 0.25, 0, priority = {0,0}},
			[9] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[10] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[11] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[12] = {0, 0.25, 0, priority = {0,0}},
			[13] = {0, 0, 0},-- 空け注8
			[14] = {0, 0, 0},
			[15] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[16] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[0] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[20] = {0, 0, 0},
			[21] = {0, 0.25, 0, priority = {0,0}},
			[22] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[23] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[24] = {0, 0, 0},
			[25] = {0.25, 0, 0, ratio = 0},
			[26] = {0, 0, 0},
			[27] = {0, 0, 0},-- 空け注9
			[28] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[29] = {0, 0, 0},
			[30] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
		}
	},
	
	[25] = { -- 単位記号中の文字
		chars = {'	', '(', ')', '/', '1', '2', '3', '4', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'Ω', 'μ', '℧', 'Å', '−', '・'},
		glue = {
			[1] = {0,5, 0, 0.5, ratio = 1, priority = {0,-2}},
			[2] = {0, 0, 0},
			[300] = {0, 0, 0},
			[4] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}},-- 注12
			[6] = {0, 0, 0},
			[7] = {0, 0, 0},
			[8] = {0, 0.25, 0, priority = {0,0}},
			[9] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[10] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[11] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[12] = {0, 0.25, 0, priority = {0,0}},
			[13] = {0, 0.25, 0, priority = {0,0}},
			[14] = {0, 0, 0},
			[15] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[16] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[0] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[20] = {0, 0, 0},
			[21] = {0, 0.25, 0, priority = {0,0}},
			[22] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[23] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[24] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[25] = {0, 0, 0},
			[26] = {0, 0, 0},
			[27] = {0, 0, 0},
			[28] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[29] = {0, 0, 0},
			[30] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
		}
	},
	
	[26] = { -- 欧文間隔
		chars = {' '},
		glue = { -- 表3の方には記述がないのは何故？
			[1] = {0.5, 0, 0.5, ratio = 1},
			[2] = {0, 0, 0},
			[300] = {0, 0, 0},
			[4] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1},
			[6] = {0, 0, 0},
			[7] = {0, 0, 0},
			[8] = {0, 0, 0},
			[9] = {0, 0, 0},
			[10] = {0, 0, 0},
			[11] = {0, 0, 0},
			[12] = {0, 0, 0},
			[13] = {0, 0, 0},
			[14] = {0, 0, 0},
			[15] = {0, 0, 0},
			[16] = {0, 0, 0},
			[0] = {0, 0, 0},
			[21] = {0, 0, 0},
			[22] = {0, 0, 0},
			[23] = {0, 0, 0},
			[24] = {0, 0, 0},
			[25] = {0, 0, 0},
			[26] = {0, 0, 0},
			[27] = {0, 0, 0},
			[28] = {0, 0, 0},
			[29] = {0, 0, 0},-- 注13, （空け）注4
			[30] = {0, 0, 0},
		}
	},
]]
	[27] = {-- 欧文
		chars = {'alchar'},
		glue = {
			[1] = {0.5, stretch_width, 0.5, ratio = 1, priority = {-1,-2}, kanjiskip_natural = 1},
			[2] = {0, 0, 0, kanjiskip_natural = 1},
			[300] = {0, 0, 0, kanjiskip_natural = 1},
			[4] = {0, 0, 0, kanjiskip_natural = 1},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}, kanjiskip_natural = 1},
			[6] = {0, 0, 0, kanjiskip_natural = 1},
			[7] = {0, 0, 0, kanjiskip_natural = 1},
			[8] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
--			[9] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}, kanjiskip_natural = 1},
--			[10] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}, kanjiskip_natural = 1},
--			[11] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}, kanjiskip_natural = 1},
			[12] = {0, 0.25, 0, priority = {0,0}, kanjiskip_natural = 1},
			[13] = {0, 0.25, 0, priority = {0,0}},-- 空け注10
			[14] = {0, 0, 0, kanjiskip_natural = 1},
--			[15] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}, kanjiskip_natural = 1},
--			[16] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}, kanjiskip_natural = 1},
--			[0] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}, kanjiskip_natural = 1},
--			[27] = {0, 0, 0, ratio = 0, priority = {1,0}, kanjiskip_natural = 1},
--[[
			[20] = {0, 0, 0},
			[21] = {0, 0.25, 0, priority = {0,0}},
			[22] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[23] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[24] = {0, 0, 0},
			[25] = {0.25, 0, 0.125, ratio = 0, priority = {0,-1}},
			[26] = {0, 0, 0},
			[27] = {0, 0, 0},
			[28] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
			[29] = {0, 0, 0},
			[30] = {0.25, 0.25, 0.125, ratio = 0, priority = {1,-3}},
--]]
		}
	},
--[[
	[28] = { -- 割注始め括弧類
		chars = {'（', '〔', '［'},
		glue = {
			[1] = {0, 0, 0},
			[2] = {0, 0, 0},
			[3] = {0, 0, 0},
			[4] = {0, 0, 0},
			[5] = {0, 0, 0},
			[6] = {0, 0, 0},
			[7] = {0, 0, 0},
			[8] = {0, 0, 0},
			[9] = {0, 0, 0},-- 注14
			[10] = {0, 0, 0},-- 注15
			[11] = {0, 0, 0},-- 注16
			[12] = {0, 0, 0},
			[13] = {0, 0, 0},
			[14] = {0, 0, 0},
			[15] = {0, 0, 0},
			[16] = {0, 0, 0},
			[0] = {0, 0, 0},
			[20] = {0, 0, 0},
			[21] = {0, 0, 0},
			[22] = {0, 0, 0},
			[23] = {0, 0, 0},
			[24] = {0, 0, 0},
			[25] = {0, 0, 0},
			[26] = {0, 0, 0}, -- 注13, （空け）注4
			[27] = {0, 0, 0},
			[28] = {0, 0, 0},
			[29] = {0, 0, 0},
			[30] = {0, 0, 0},
		}
	},
	
	[29] = { -- 割注終わり括弧類
		chars = {'）', '〕', '］'},
		glue = {
			[1] = {0.5, 0, 0.5, ratio = 1, priority = {0,-2}},
			[2] = {0, 0, 0},
			[3] = {0, 0, 0},
			[4] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}},
			[6] = {0, 0, 0},
			[7] = {0, 0, 0},
			[8] = {0, 0.25, 0, priority = {0,0}},
			[9] = {0, 0.25, 0, priority = {0,0}},
			[10] = {0, 0.25, 0, priority = {0,0}},
			[11] = {0, 0.25, 0, priority = {0,0}},
			[12] = {0, 0.25, 0, priority = {0,0}},
			[13] = {0, 0.25, 0, priority = {0,0}},
			[14] = {0, 0, 0},
			[15] = {0, 0.25, 0, priority = {0,0}},
			[16] = {0, 0.25, 0, priority = {0,0}},
			[0] = {0, 0.25, 0, priority = {0,0}},
			[20] = {0, 0, 0},
			[21] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0.25, 0.25, 0.125, ratio = 1}, priority = {1,-3},
			[25] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[26] = {0, 0, 0},
			[27] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		}
	},
	
	[30] = { -- 縦中横中の文字
		glue = {
			[1] = {0.5, 0, 0.5, ratio = 1, priority = {0,-2}},
			[2] = {0, 0, 0},
			[3] = {0, 0, 0},
			[4] = {0, 0, 0},
			[5] = {0.25, 0, 0.25, ratio = 1, priority = {0,-1}},
			[6] = {0, 0, 0},
			[7] = {0, 0, 0},
			[8] = {0, 0.25, 0, priority = {0,0}},
			[9] = {0, 0.25, 0, priority = {0,0}},
			[10] = {0, 0.25, 0, priority = {0,0}},
			[11] = {0, 0.25, 0, priority = {0,0}},
			[12] = {0, 0.25, 0, priority = {0,0}},
			[13] = {0, 0.25, 0, priority = {0,0}},
			[14] = {0, 0, 0},
			[15] = {0, 0.25, 0, priority = {0,0}},
			[16] = {0, 0.25, 0, priority = {0,0}},
			[0] = {0, 0.25, 0, priority = {0,0}},
			[20] = {0, 0, 0},
			[21] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[22] = {0, 0.25, 0, priority = {0,0}},
			[23] = {0, 0.25, 0, priority = {0,0}},
			[24] = {0.25, 0.25, 0.125, ratio = 1}, priority = {1,-3},
			[25] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[26] = {0, 0, 0},
			[27] = {0.25, 0.25, 0.125, ratio = 1, priority = {1,-3}},
			[28] = {0, 0.25, 0, priority = {0,0}},
			[29] = {0, 0, 0},
			[30] = {0, 0.25, 0, priority = {0,0}},
		}
	},
	]]

	[90] = { -- 行頭
		chars = {'parbdd','boxbdd'},
		glue = {
			[1] = {0, 0, 0}, -- 行頭括弧はベタ組
		},
	},
}

local function add_space(before,after,glueorkern,space,ratio)
	if jfm[before][glueorkern] == nil then jfm[before][glueorkern] = {} end
	if jfm[before][glueorkern][after] == nil then jfm[before][glueorkern][after] = {0} end
	local origratio = jfm[before][glueorkern][after].ratio
	if origratio == nil then origratio = 0.5 end
	jfm[before][glueorkern][after].ratio = (jfm[before][glueorkern][after][1] * origratio + space * ratio) /  (jfm[before][glueorkern][after][1] + ratio)
	jfm[before][glueorkern][after][1] = jfm[before][glueorkern][after][1] + space
end

if jlreq ~= nil then
	if type(jlreq.open_bracket_pos) == "string" then
		local r = jlreq.open_bracket_pos:find("_")
		local danraku = jlreq.open_bracket_pos:sub(1,r - 1)
		local orikaeshi = jlreq.open_bracket_pos:sub(r + 1)

		-- 折り返し行頭の開き括弧を二分下げる……つもり
		if orikaeshi == "nibu" then
			-- widthを二分増やし，その代わりJFMグルーを二分減らす
			jfm[1].width = jfm[1].width + 0.5
			for k,v in pairs(jfm) do
				if type(k) == "number" then
					add_space(k,1,"glue",-0.5,1)
				end
			end
		end

		-- 段落行頭の下げ
		if danraku == "zenkakunibu" then
			add_space(90,1,"glue",0.5,1)
		elseif danraku == "nibu" then
			add_space(90,1,"glue",-0.5,1)
		end
	end

	-- ぶら下げ組を有効にする．
	if jlreq.burasage == true then
		for _,class in ipairs({6,7}) do
			table.insert(jfm[class].end_adjust,-0.5)
		end
	end
end

local function copy_jfm(from,to)
	if jfm[from].glue ~= nil then jfm[to].glue = table.fastcopy(jfm[from].glue) end
	for tc,_ in pairs(jfm) do
		if type(tc) == "number" then
			if jfm[tc].glue[from] ~= nil then
				jfm[tc].glue[to] = table.fastcopy(jfm[tc].glue[from])
			end
		end
	end
end

copy_jfm(0,191)
copy_jfm(0,192)
copy_jfm(0,193)
copy_jfm(16,161)
copy_jfm(300,301)
copy_jfm(300,302)

luatexja.jfont.define_jfm(jfm)
