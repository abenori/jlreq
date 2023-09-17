kpse.set_program_name("texlua","lualatex")

no_jis_chars = {'｟','〘','〖','«','〝','｠','〙','〗','»','〟','‼','⁇','⁈','⁉','〳','〴','〵','〻','ゕ','ゖ','ㇰ','ㇱ','ㇲ','ㇳ','ㇴ','ㇵ','ㇶ','ㇷ','ㇸ','ㇹ','ㇺ','ㇻ','ㇼ','ㇽ','ㇾ','ㇿ','ㇷ゚','€','№','㏋','ℓ','㌃','㌍','㌔','㌘','㌢','㌣','㌦','㌧','㌫','㌶','㌻','㍉','㍊','㍍','㍑','㍗','㎎','㎏','㎜','㎝','㎞','㎡','㏄','ゔ','か゚','き゚','く゚','け゚','こ゚','ヷ','ヸ','ヹ','ヺ','カ゚','キ゚','ク゚','ケ゚','コ゚','セ゚','ツ゚','ト゚','゠','–','ｦ', 'ｧ', 'ｨ', 'ｩ', 'ｪ', 'ｫ', 'ｬ', 'ｭ', 'ｮ', 'ｯ', 'ｰ', 'ｱ', 'ｲ', 'ｳ', 'ｴ', 'ｵ', 'ｶ', 'ｷ', 'ｸ', 'ｹ', 'ｺ', 'ｻ', 'ｼ', 'ｽ', 'ｾ', 'ｿ', 'ﾀ', 'ﾁ', 'ﾂ', 'ﾃ', 'ﾄ', 'ﾅ', 'ﾆ', 'ﾇ', 'ﾈ', 'ﾉ', 'ﾊ', 'ﾋ', 'ﾌ', 'ﾍ', 'ﾎ', 'ﾏ', 'ﾐ', 'ﾑ', 'ﾒ', 'ﾓ', 'ﾔ', 'ﾕ', 'ﾖ', 'ﾗ', 'ﾘ', 'ﾙ', 'ﾚ', 'ﾛ', 'ﾜ', 'ﾝ','｡', '｢', '｣', '､', '･', 'ﾞ', 'ﾟ'}

if arg[1] == nil then
	print('Usage: texlua luajfm2pl.lua [--noutf] <JFM for LuaTeX-ja> [<PL file name>]')
	os.exit(0)
end

local luajfm
if arg[1] ~= "--noutf" then
	no_jis_chars = {}
	luajfm = arg[1]
	outputfile = arg[2]
else
	luajfm = arg[2]
	outputfile = arg[3]
end

local jfmfile = kpse.find_file("jfm-" .. luajfm .. ".lua")
if jfmfile == nil then
	print("JFM " .. luajfm .. " is not found")
	os.exit(1)
end

--. JFMロード
jfm = nil
luatexja = {}
luatexja.jfont = {}

function luatexja.jfont.define_jfm(j)
	jfm = j
end

dofile(jfmfile)

local fp = nil
if outputfile == nil then
	fp = io.stdout
else
	local msg
	fp,msg = io.open(outputfile,"w")
	if fp == nil then
		print(msg)
		os.exit(1)
	end
end


--. 関数群
local function merge_sort(list,from,to,comp)
	local tmplist = {}
	if to - from > 1 then
		local mid = math.floor((to + from)/2)
		merge_sort(list,from,mid,comp)
		merge_sort(list,mid+1,to,comp)
		local left = from
		local right = mid + 1
		local i = 1
		while left <= mid or right <= to do
			if left > mid then
				tmplist[i] = list[right]
				right = right + 1
			elseif right > to then
				tmplist[i] = list[left]
				left = left + 1
			elseif comp(list[right],list[left]) == true then
				tmplist[i] = list[right]
				right = right + 1
			else
				tmplist[i] = list[left]
				left = left + 1
			end
			i = i + 1
		end
		for j = from,to do
			list[j] = tmplist[j - from + 1]
		end
	elseif to - from == 1 then
		if comp(list[to],list[from]) then
			list[to],list[from] = list[from],list[to]
		end
	end
	return list
end

function stable_sort(list,comp)
	if comp == nil then comp = function(a,b) return a < b end end
	return merge_sort(list,1,#list,comp)
end

local function array_uniq(t)
	local n = 1
	for i = 1,#t do
		local newone = true
		for j = 1,n - 1 do
			if t[i] == t[j] then
				newone = false
				break
			end
		end
		if newone == true then
			t[n] = t[i]
			n = n + 1
		end
	end
	local m = #t
	for i = n,m do table.remove(t) end
	return t
end

local function exists(t,v)
	for _,val in pairs(t) do 
		if v == val then return true end
	end
	return false
end


local function isempty(t) return next(t) == nil end
local function isemptyornil(t) return t == nil or isempty(t) end

--. JFMの改変
-- デフォルト値の設定
for cls,val in pairs(jfm) do
	if type(cls) == "number" then
		if val.width == nil then jfm[cls].width = 1 end
		if val.height == nil then
			if jfm.dir == 'tate' then jfm[cls].height = 0.5
			else jfm[cls].height = 0.88 end
		end
		if val.depth == nil then
			if jfm.dir == 'tate' then jfm[cls].depth = 0.5
			else jfm[cls].depth = 0.12 end
		end
		if val.italic == nil then jfm[cls].italic = 0 end
	end
end

-- charsを書き出す文字列に変換しておく．
local no_jis_chars_hash = {}
for _,c in ipairs(no_jis_chars) do no_jis_chars_hash[c] = true end

alcharclass = nil
noxalcharclass = nil

for class,val in pairs(jfm) do
	if type(class) ~= "number" or class == 0 then goto continue end
	local chars = {}
	for _,c in ipairs(val.chars) do
		local ac = nil
		-- 'alchar'や'nox_alchar'が入っているクラスを記憶
		if c == 'alchar' then alcharclass = class
		elseif c == 'nox_alchar' then noxalcharclass = class
		elseif unicode.utf8.len(c) == 1 then ac = c
		elseif unicode.utf8.len(c) == 2 then
			local cs = {}
			for _,cc in string.utfcharacters(c) do
				table.insert(cs,cc)
			end
			if cs[2] == "*" then ac = cs[1] end
		end
		if no_jis_chars_hash[ac] ~= true then table.insert(chars,ac) end
	end
	chars = array_uniq(chars)
 	-- charsが空になった場合は消しておく
	if class ~= alcharclass and class ~= noxalcharclass and isempty(chars) == true then
		io.stderr:write("Class " .. class .. " has no char, so we omit it\n")
		jfm[class] = nil
	else jfm[class].chars = table.concat(chars," ") end
	::continue::
end


if alcharclass == noxalcharclass then noxalcharclass = nil end
for _,class in ipairs({alcharclass,noxalcharclass}) do
	if class ~= nil then
		if jfm[class].chars == "" then
			io.stderr:write("Class " .. class .. " has only Alchar, so we omit it\n")
			jfm[class] = nil
		end
	end
end


-- 存在しないクラスに対するglue/kernは消す
for _,gluekern in ipairs({"glue","kern"}) do
	for class,val in pairs(jfm) do
		if type(class) == "number" and val[gluekern] ~= nil then
			for target,_ in pairs(val[gluekern]) do
				if jfm[target] == nil then
					io.stderr:write("Class " .. tostring(target) .. " does not exist, the corresponding " .. gluekern .. " in Class " .. tostring(class) .. " is omitted\n")
					jfm[class][gluekern][target] = nil
				end
			end
		end
	end
end

-- glueやkernが同じ挙動であるか調べる
function isthesamespace(gluekern,clses,c1,c2)
	return isthesamespace_before(gluekern,c1,c2) and isthesamespace_after(gluekern,clses,c1,c2)
end
-- c1,c2を前とするグルーが同じか．
function isthesamespace_before(gluekern,c1,c2)
	-- 片方がnilの場合
	if jfm[c1][gluekern] == jfm[c2][gluekern] then return true end
	if jfm[c1][gluekern] == nil or jfm[c2][gluekern] == nil then return false end
	--この段階で両方tableなはず
	local targetclses = {} -- c1とc2のglueやkernのunion
	for c,_ in pairs(jfm[c1][gluekern]) do table.insert(targetclses,c) end
	for c,_ in pairs(jfm[c2][gluekern]) do table.insert(targetclses,c) end
	targetclses = array_uniq(targetclses)
	for _,chk in ipairs(targetclses) do
		if jfm[c1][gluekern][chk] == jfm[c2][gluekern][chk] then goto continue end
		if jfm[c1][gluekern][chk] == nil or jfm[c2][gluekern][chk] == nil then return false end
		if type(jfm[c1][gluekern][chk]) == "number" or type(jfm[c2][gluekern][chk]) == "number" then return false end
		if jfm[c1][gluekern][chk][1] ~= jfm[c2][gluekern][chk][1] then return false end
		if gluekern == "glue" then
			if jfm[c1][gluekern][chk][2] ~= jfm[c2][gluekern][chk][2] or jfm[c1][gluekern][chk][3] ~= jfm[c2][gluekern][chk][3] then return false end
		end
		::continue::
	end
	return true
end

function isthesamespace_after(gluekern,clses,c1,c2)
	for _,c in pairs(clses) do
		if jfm[c][gluekern] == nil then goto continue end
		if jfm[c][gluekern][c1] == jfm[c][gluekern][c2] then goto continue end
		if jfm[c][gluekern][c1] == nil or jfm[c][gluekern][c2] == nil then return false end
		if type(jfm[c][gluekern][c1]) == "number" or type(jfm[c][gluekern][c2]) == "number" then return false end
		if jfm[c][gluekern][c1][1] ~= jfm[c][gluekern][c2][1] then return false end
		if kernglue == "glue" then
			if jfm[c][gluekern][c1][2] ~= jfm[c][gluekern][c2][2] or jfm[c][gluekern][c1][3] ~= jfm[c][gluekern][c2][3] then return false end
		end
		::continue::
	end
	return true
end

-- 同じ挙動を示すクラスをまとめる
local classes = {}
for k,_ in pairs(jfm) do if type(k) == "number" then table.insert(classes,k) end end
classes = stable_sort(classes)
for _,from in pairs(classes) do
	for index,to in pairs(classes) do
		if to <= from or to == 0 or from == 0 then goto continue end
		if jfm[from].width ~= jfm[to].width or jfm[from].height ~= jfm[to].height or jfm[from].depth ~= jfm[to].depth or jfm[from].italic ~= jfm[to].italic then goto continue end
		if isthesamespace("glue",classes,from,to) and isthesamespace("kern",classes,from,to) then
			io.stderr:write("Class " .. tostring(to) .. " is merged to Class " .. tostring(from) .. "\n")
			jfm[from].chars = jfm[from].chars .. " " .. jfm[to].chars
			jfm[to] = nil
			classes[index] = nil
			for _,cls in pairs(classes) do
				if jfm[cls].glue ~= nil then jfm[cls].glue[to] = nil end
				if jfm[cls].kern ~= nil then jfm[cls].kern[to] = nil end
			end
		end
		::continue::
	end
end

-- 番号を連続的にする．
-- classmaptable[JFM内クラス番号] = JPL内クラス番号
classes = {}
for k,_ in pairs(jfm) do if type(k) == "number" then table.insert(classes,k) end end
classes = stable_sort(classes)
local classmaptable = {}
local jplclass = 1
for _,class in ipairs(classes) do
	if type(class) == "number" then
		if class == 0 then classmaptable[class] = 0
		else
			if class ~= jplclass then
				io.stderr:write("Class " .. tostring(class) .. " is mapped to Class " .. tostring(jplclass) .. "\n")
			end
			classmaptable[class] = jplclass
			jplclass = jplclass + 1
		end
	end
end


fp:write("(COMMENT JPL file from jfm-" .. luajfm .. ".lua)\n")
fp:write("(CODINGSCHEME TEX KANJI TEXT)\n")
fp:write("(DIRECTION " .. string.upper(jfm.dir) .. ")\n")
-- fp:write("(DESIGNSIZE R 10.0)\n")
fp:write("(FONTDIMEN \n")
fp:write("  (SLANT R 0.0)\n")
fp:write("  (SPACE R " .. tostring(jfm.kanjiskip[1]) .. ")\n")
fp:write("  (STRETCH R " .. tostring(jfm.kanjiskip[2]) .. ")\n")
fp:write("  (SHRINK R " .. tostring(jfm.kanjiskip[3]) .. ")\n")
fp:write("  (XHEIGHT R " .. tostring(jfm.zh) .. ")\n")
fp:write("  (QUAD R " .. tostring(jfm.zw) .. ")\n")
fp:write("  (EXTRASPACE R " .. tostring(jfm.xkanjiskip[1]) .. ")\n")
-- 下二つはFONTDIMENの下で良いのかな？
fp:write("  (EXTRASTRETCH R " .. tostring(jfm.xkanjiskip[2]) .. ")\n")
fp:write("  (EXTRASHRINK R " .. tostring(jfm.xkanjiskip[3]) .. ")\n")
fp:write(")\n")

classes = {}
for k,_ in pairs(jfm) do if type(k) == "number" then table.insert(classes,k) end end
classes = stable_sort(classes,function(a,b) return classmaptable[a] < classmaptable[b] end)

for _,class in ipairs(classes) do
	if class ~= 0 then
		fp:write("(CHARSINTYPE D " .. tostring(classmaptable[class]) .. "\n  " .. jfm[class].chars .. "\n)\n")
	end
	fp:write("(TYPE D " .. tostring(classmaptable[class]) .. "\n")
	fp:write("  (CHARWD R " .. tostring(jfm[class].width) .. ")\n")
	fp:write("  (CHARHT R " .. tostring(jfm[class].height) .. ")\n")
	fp:write("  (CHARDP R " .. tostring(jfm[class].depth) .. ")\n")
	fp:write("  (CHARIC R " .. tostring(jfm[class].italic) .. ")\n")
	fp:write(")\n")
	::continue::
end

fp:write("(GLUEKERN\n")
for _,class in ipairs(classes) do
	if (jfm[class].glue == nil or isempty(jfm[class].glue) == true) and (jfm[class].kern == nil or (type(jfm[class].kern) == "table" and isempty(jfm[class].kern) == true)) then goto continue end
	fp:write("  (LABEL D " .. tostring(classmaptable[class]) .. ")\n")
	if jfm[class].glue ~= nil then
		for _,targetcls in ipairs(classes) do
			if jfm[class].glue[targetcls] ~= nil then
				fp:write("    (GLUE D " .. tostring(classmaptable[targetcls]) .. " R " .. tostring(jfm[class].glue[targetcls][1]) .. " R " .. tostring(jfm[class].glue[targetcls][2]) .. " R " .. tostring(jfm[class].glue[targetcls][3]) .. ")\n")
			end
		end
	end
	if jfm[class].kern ~= nil then
		for _,targetcls in ipairs(classes) do
			if jfm[class].kern[targetcls] ~= nil then
				fp:write("    (KRN D " .. tostring(classmaptable[targetcls]) .. " R ")
				if type(kernval) == "number" then fp:write(tostring(jfm[class],kern[targetcls]) .. ")\n")
				else fp:write(tostring(jfm[class].kern[targetcls][1]) .. ")\n") end
			end
		end
	end
	fp:write("  (STOP)\n")
	::continue::
end
fp:write(")\n")
