kpse.set_program_name("texlua","lualatex")
require('lualibs')

function burasage(t)
	t = table.fastcopy(t)
	-- 句読点の幅を0にして，句読点に続くglueを0.5増やす．
	for _,class in ipairs({6,7}) do
		local width = t[class].width
		t[class].width = 0
		if t[class].glue ~= nil then
			for key,_ in pairs(t[class].glue) do
				t[class].glue[key][1] = t[class].glue[key][1] + width
			end
		end
		if t[class].kern ~= nil then
			for key,val in pairs(t[class].kern) do
				if type(val) == "table" then
					t[class].glue[key][1] = t[class].glue[key][1] + width
				else
					t[class].glue[key] = t[class].glue[key] + width
				end
			end
		end
	end
	return t
end

function zenkaku_kakko(t)
	t = table.fastcopy(t)
	-- 開き括弧のwidthを0.5増やす
	t[1].width = t[1].width + 0.5
	for cls,val in pairs(t) do
		if type(cls) ~= "number" then goto continue end
		if t[cls].glue ~= nil and t[cls].glue[1] ~= nil then
			t[cls].glue[1][1] = t[cls].glue[1][1] - 0.5
		end
		if t[cls].kern ~= nil and t[cls].kern[1] ~= nil then
			if type(t[cls].kern[1]) == "table" then
				t[cls].kern[1][1] = t[cls].kern[1][1] - 0.5
			else
				t[cls].kern[1] = t[cls].kern[1] - 0.5
			end
		end
		::continue::
	end
	return t
end

function tate(t)
	t = table.fastcopy(t)
	t.dir = 'tate'
	for key,_ in ipairs(t) do
		if type(key) == "number" then
			t[key].height = 0.5
			t[key].depth = 0.5
		end
	end
	return t
end

-- jfmのテーブル，ファイル名
function make_jfmfile(t,f)
	table.tofile(f,t,"jfm")
	local fp = io.open(f,"a")
	fp:write("luatexja.jfont.define_jfm(jfm)\n")
end

local originaljfm = "jlreq"

local jfmfile = kpse.find_file("jfm-" .. originaljfm .. ".lua")
if jfmfile == nil then
	print("JFM " .. originaljfm .. " is not found")
	os.exit(1)
end

jfm = nil
luatexja = {}
luatexja.jfont = {}

function luatexja.jfont.define_jfm(j)
	jfm = j
end

dofile(jfmfile)

make_jfmfile(burasage(jfm),"jfm-b" .. originaljfm .. ".lua")
make_jfmfile(zenkaku_kakko(jfm),"jfm-z" .. originaljfm .. ".lua")
make_jfmfile(burasage(zenkaku_kakko(jfm)),"jfm-bz" .. originaljfm .. ".lua")
make_jfmfile(tate(jfm),"jfm-" .. originaljfm .. "v.lua")
make_jfmfile(burasage(tate(jfm)),"jfm-b" .. originaljfm .. "v.lua")
make_jfmfile(zenkaku_kakko(tate(jfm)),"jfm-z" .. originaljfm .. "v.lua")
make_jfmfile(burasage(zenkaku_kakko(tate(jfm))),"jfm-bz" .. originaljfm .. "v.lua")
