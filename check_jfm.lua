kpse.set_program_name("texlua","lualatex")

if arg[1] ~= nil then
	jfm = arg[1]
else
	print("LuaTeX-ja JFM checker.")
	print("Usage: texlua check_jfm.lua <JFM name>")
	os.exit(0)
end

local file = kpse.find_file("jfm-" .. jfm .. ".lua")
if file == nil then
	print("JFM " .. jfm .. " is not found.")
	os.exit(0)
end

local function position_msg(position_table)
	if #position_table == 0 then return "."
	else return " in " .. table.concat(position_table," ") .. "."
	end
end

local function added_table(t,val)
	local rv = {}
	for _,v in ipairs(t) do table.insert(rv,v) end
	table.insert(rv,val)
	return rv;
end

local err_count = 0

local function print_error(msg)
	err_count = err_count + 1
	print(msg)
end

local function array_check(val,key,position,size)
	if type(val) ~= "table" then
		print_error(key .. " should be array, but it has the type " .. type(val) .. position_msg(position))
	else
		local num = 0
		for k,_v in pairs(val) do
			if type(k) ~= "number" then
				print_error(key .. " should be array, but it has a key of type " .. type(k) .. position_msg(position))
			end
			num = num + 1
		end
		if num ~= #val then
			print_error(key .. " should be array but it is not an array.")
		elseif size ~= nil and #val ~= size then
			print_error("The size of " .. key " should be " .. tostring(size) .. ", but it is " .. tostring(#val) .. position_msg(position))
		end
	end
end

local function type_check(val,t,key,position) 
	if type(t) == "string" then t = {t} end
	local exist = false
	for _,v in ipairs(t) do
		if type(val) == v then exist = true end
	end
	if exist == false then
		print_error(key .. " should be " .. table.concat(t," or ") .. " but it is " .. type(val) .. position_msg(position))
	end
	return exist
end

char_class = {}

local function each_kern_check(kerntable,version,position)
	for k,v in pairs(kerntable) do
		if type(k) == "number" then
			type_check(v,"number",k,position)
		elseif type(k) ~= "string" then
			print_error("key of type " .. type(k) .. position_msg(position))
		elseif k == "ratio" then
			if type_check(v,"number",k,position) == true then
				if v < 0 or v > 1 then print_error("ratio should be between 0 and 1 but it is " .. v .. position_msg(position)) end
			end
		else
			print_error("key " .. k .. " is not allowed" .. position_msg(position))
		end
	end
end

local function kern_check(kerntable,version,position)
	for k,v in pairs(kerntable) do
		if type(k) ~= "number" then
			print_error("key of type " .. type(k) .. position_msg(position))
		elseif type_check(k,{"number","table"},v,position) == true then
			if type(v) == "table" then
				each_kern_check(v,version,added_table(position,tostring(k)))
			end
		end
	end
end

local function each_glue_check(gluetable,version,position)
	for k,v in pairs(gluetable) do
		if type(k) == "number" then
			type_check(v,"number",k,position)
		elseif type(k) ~= "string" then
			print_error("key of type " .. type(k) .. position_msg(position))
		else
			if k == "kanjiskip_natural" or k == "kanjiskip_stretch" or k == "kanjiskip_shrink" then
				type_check(v,"number",k,position)
			elseif k == "priority" then
				if type_check(v,"number",k,position) == true then
					if v ~= -2 and v ~= -1 and v ~= 0 and v ~= 1 and v ~= 2 then
						print_error("priority should be in -2,-1,0,1,2" .. position_msg(position))
					end
				end
			elseif k == "ratio" then
				if type_check(v,"number",k,position) == true then
					if v < 0 or v > 1 then print_error("ratio should be between 0 and 1 but it is " .. v .. position_msg(position)) end
				end
			else
				print_error("key " .. k .. " is not allowed" .. position_msg(position))
			end
		end
	end
end

local function glue_check(gluetable,version,position)
	for k,v in pairs(gluetable) do
		if type(k) ~= "number" then
			print_error("key of type " .. type(k) .. position_msg(position))
		elseif type_check(v,"table",k,position) == true then
			each_glue_check(v,version,added_table(position,tostring(k)))
		end
	end
end

local function class_check(clstable,class,version,position)
	local exist_key = {}
	for k,v in pairs(clstable) do
		if type(k) ~= "string" then
			print_error("key of type " .. type(k) .. position_msg(position))
		else
			exist_key[k] = true
			if k == "chars" then
				if type_check(v,"table",k,position) == true then
					for kk,vv in pairs(v) do
						if type(kk) ~= "number" then
							print_error("chars should an array but key of type " .. type(kk) .. " found" .. position_msg(position))
						elseif char_class[vv] ~= nil then
							print_error("char " .. vv .. " is found in class " .. tostring(char_class[vv]) .. " and " .. tostring(class))
						end
						char_class[vv] = class
					end
				end
			elseif k == "width" or k == "height" or k == "depth" or k == "italic" or k == "left" or k == "down" then
				type_check(v,"number",k,position)
			elseif k == "align" then
				if v ~= "left" and v ~= "right" and v ~= "middle" then
					print_error(k .. " should be left/right/middle but it is " .. tostring(v) .. position_msg(position))
				end
			elseif k == "kern" then
				if type_check(v,"table",k,position) == true then
					kern_check(v,version,added_table(position,"kern"))
				end
			elseif k == "glue" then
				if type_check(v,"table",k,position) == true then
					glue_check(v,version,added_table(position,"glue"))
				end
			elseif version == 1 and (k == "end_stretch" or k == "end_shrink") then
				type_check(v,"number",k,position)
			elseif version >= 2 and (k == "end_adjust") then
				if array_check(v,k,position) == true then
					if #v == 0 then print("end_ajudst is empty" .. position_msg(position)) end
				end
			else
				print_error("key " .. k .. " is not allowed" .. position_msg(position))
			end
		end
	end
	if type(clstable.glue) == "table" and type(clstable.kern) == "table" then
		for k,_ in pairs(clstable.glue) do
			if clstable.kern[k] ~= nil then
				print_error("kern and glue are both defined for class " .. tostring(k) .. position_msg(position))
			end
		end
	end
	local required_keys = {}
	if class ~= 0 then table.insert(required_keys,"chars") end
	for _,v in ipairs(required_keys) do
		if exist_key[v] ~= true then
			print_error("Required field " .. v .. " is not found.")
		end
	end
end


local function jfm_check(jfmtable,version,position)
	local exist_key = {}
	for k,v in pairs(jfmtable) do
		if type(k) == "number" then
			if k < 0 then print_error("Negative class (" .. tostring(k) .. ") is found" .. position_msg(position)) end
			class_check(v,k,version,added_table(position,"Class " .. tostring(k)))
		elseif type(k) ~= "string" then
			print_error("key of type " .. type(k) .. " in JFM")
		else
			exist_key[k] = true
			if k == "dir" then
				if v ~= "yoko" and v ~= "tate" then
					print_error("dir should be yoko or tate but it is " .. tostring(v) .. position_msg(position))
				end
			elseif k == "zw" or k == "zh" then
				type_check(v,"number",k,position)
			elseif k == "kanjiskip" or k == "xkanjiskip" then
				array_check(v,k,position,3)
			elseif k ~= "version" then
				print_error("key " .. k .. " is not allowed" .. position_msg(position))
			end
		end
	end
	for _,v in ipairs({'dir','zw','zh'}) do
		if exist_key[v] ~= true then
			print_error("Required field " .. v .. " is not found.")
		end
	end
end

local loaded_jfm = nil
luatexja = {}
luatexja.jfont = {}

function luatexja.jfont.define_jfm(j)
	loaded_jfm = j
end

print("check JFM " .. jfm .. ".")
print("file = " .. file)
local function load_file()
	dofile(file)
end
xpcall(load_file,function(e) print("Syntax error in JFM " .. jfm .. ".\n" .. e) os.exit(0) end)
if loaded_jfm == nil then print("luatexja.jfont.define_jfm is not called.") os.exit(0) end

local version = 1
if loaded_jfm.version ~= nil then
	if type(loaded_jfm.version) ~= "number" then print_error("version should be a number.")
	else version = loaded_jfm.version end
end
if version ~= 1 and version ~= 2 then
	print_error("Only version 1 or 2 is supported. (We assume that the version of the JFM is 1.)")
	version = 1
end
print("version " .. tostring(version))
local function do_check()
	jfm_check(loaded_jfm,version,{})
end
xpcall(do_check,function(e) print(debug.traceback(tostring(e),2) .. "\n") end)
if err_count == 0 then print("No error is found.")
elseif err_count == 1 then print("There is an error.")
else print("There are " .. tostring(err_count) .. " errors.") end

