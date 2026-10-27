--[[---------------------------------------------------------------------------
  check_jfm_pdftex.lua --- static validator for the generated pdfTeX JFM
  data files.
  Naming follows the existing check_jfm.lua convention (repo root).

  Run from the repository root (default paths) or pass a .def explicitly:

    texlua check_jfm_pdftex.lua [<path-to-.def> ...] [--jfm=<path>]

  With no arguments, ALL TWELVE committed variants are validated, driven by
  the generator's manifest (pdftex-jfm-manifest.lua -- the single source of
  the variant list):
    jlreq-pdftex-jfm.def         (yoko, zenkaku_tentsuki,  burasage=false)
    jlreq-pdftex-jfm-b.def       (yoko, zenkaku_tentsuki,  burasage=true)
    jlreq-pdftex-jfm-z.def       (yoko, zenkakunibu_nibu,  burasage=false)
    jlreq-pdftex-jfm-bz.def      (yoko, zenkakunibu_nibu,  burasage=true)
    jlreq-pdftex-jfm-n.def       (yoko, nibu_tentsuki,     burasage=false)
    jlreq-pdftex-jfm-bn.def      (yoko, nibu_tentsuki,     burasage=true)
    jlreq-pdftex-jfm-tate.def    (tate, zenkaku_tentsuki,  burasage=false)
    jlreq-pdftex-jfm-tate-b.def  (tate, zenkaku_tentsuki,  burasage=true)
    jlreq-pdftex-jfm-tate-z.def  (tate, zenkakunibu_nibu,  burasage=false)
    jlreq-pdftex-jfm-tate-bz.def (tate, zenkakunibu_nibu,  burasage=true)
    jlreq-pdftex-jfm-tate-n.def  (tate, nibu_tentsuki,     burasage=false)
    jlreq-pdftex-jfm-tate-bn.def (tate, nibu_tentsuki,     burasage=true)
  The tate variants use jfm-jlreqv.lua as their source oracle (the
  RUNTIME vertical JFM with the full stretch/priority data and the alchar
  compensation pair, which the old -pl table dropped), loaded with the same
  jlreq option globals, so the b/z/n hooks are honored identically.

  Per variant, each check prints a line and any failure sets rc=1:
    1. HEADER    declares generator version, source sha256, options and
                 variant suffix consistently with the file name.
    2. COVERAGE  every char entry of every class's chars list in
                 the source JFM appears exactly once in the .def dispatch
                 (single-codepoint chars as \cls@<hex>, combos, AJ1 glyphs,
                 pseudo names), and no char appears in two classes.
    3. PAIRS     ALL defined pair glues are byte-checked against the
                 freshly loaded JFM table (incl. defaults ratio=0.5,
                 priority={0,0}, kanjiskip_natural normalization as in
                 ltj-jfont.lua:141,144,157); no extra pairs beyond the
                 source. Additionally independent canary pairs are
                 asserted with hardcoded values (see CANARY_* below).
    4. METRICS   class width/height/depth/align/left and
                 kanjiskip/xkanjiskip/zw/zh/dir match; end_adjust sorted;
                 the emitted classlist matches the loaded class set.
    5. STRUCTURE every emitted line is a comment (%% / %), blank, or a \def
                 of the documented families; family counts reported;
                 total \def count = the sum of emitted families.
    6. SEMANTICS variant-specific oracles, independent of the generator's
                 code path:
                 - b/bz/tate-b/tate-bz: end_adjust of classes 6,7 must be
                   {-0.5}{0}{0.5} (source {0.5,0} + {-0.5}, sorted).
                 - z/bz/tate-z/tate-bz: class 1 width 1.0; every k->1
                   glue natural is exactly 0.5 zw smaller than the
                   default variant's; 90->1 == {0,0,0} ratio 1.5.
                 - n/bn/tate-n/tate-bn: nibu_tentsuki = danraku "nibu" +
                   orikaeshi "tentsuki" (jfm-jlreq.lua parses the option
                   as "<danraku>_<orikaeshi>"), so ONLY the paragraph-head
                   branch fires: 90->1 = {-0.5,0,0} ratio -0.5 (arithmetic:
                   add_space(90,1,"glue",-0.5,1) on the default {0,0,0}
                   ratio 0.5 gives natural 0-0.5 = -0.5 and ratio
                   (0*0.5 + (-0.5)*1)/(0+1) = -0.5), class 1 width stays
                   0.5, and every other k->1 pair is byte-IDENTICAL to the
                   default variant (empirically verified against the
                   generated tables).
                 - tate: height=depth=0.5 per class; the pair stretch
                   values are the RUNTIME ones (e.g. 0->1 stretch 0.25
                   with priority {-1,-2} -- the -pl table had zeroed it).
-----------------------------------------------------------------------------]]

-- ------------------------- arguments ----------------------------------------
local deffiles = {}
local jfmfile_opt = nil
do
  local i = 1
  while i <= #arg do
    local a = arg[i]
    if a:sub(1, 6) == "--jfm=" then
      jfmfile_opt = a:sub(7)
    elseif a:sub(1, 2) == "--" then
      io.stderr:write("check_jfm_pdftex.lua: unknown option " .. a .. "\n")
      os.exit(2)
    else
      deffiles[#deffiles + 1] = a
    end
    i = i + 1
  end
end
local scriptdir = arg and arg[0] and arg[0]:match("^(.*)/[^/]*$") or "."

-- ------------------------- manifest (single source) ------------------------
-- The default variant list comes from the generator's manifest so that
-- the checker, the Makefile and the runtime loader all share ONE list.
-- The manifest is a plain Lua file returning
--   { gen_version = "2.0", variants = { { suffix, file, dir,
--       open_bracket_pos, burasage }, ... } }
-- (written by make_pdftex_jfm.lua --all-variants).  tate variants get
-- jfm-jlreqv.lua as their source oracle (the RUNTIME vertical JFM).
local MANIFEST_NAME = "pdftex-jfm-manifest.lua"
local function load_manifest()
  local paths = { scriptdir .. "/" .. MANIFEST_NAME, MANIFEST_NAME }
  for _, p in ipairs(paths) do
    local f = io.open(p, "r")
    if f then f:close() return dofile(p), p end
  end
  return nil
end
local function manifest_error()
  io.stderr:write("check_jfm_pdftex.lua: cannot load " .. MANIFEST_NAME
    .. " (run `make pdftex-jfm` first; it regenerates the manifest)\n")
  os.exit(2)
end
local DEFAULT_DEFS = nil
if #deffiles == 0 then
  local m = load_manifest()
  if not m or type(m.variants) ~= "table" or #m.variants == 0 then
    manifest_error()
  end
  DEFAULT_DEFS = {}
  for _, v in ipairs(m.variants) do
    DEFAULT_DEFS[#DEFAULT_DEFS + 1] = {
      suffix = v.suffix, file = v.file,
      obp = v.open_bracket_pos, bura = v.burasage,
      tate = (v.dir == "tate"),
      jfmfile = (v.dir == "tate") and "jfm-jlreqv.lua" or nil,
    }
  end
  for _, d in ipairs(DEFAULT_DEFS) do
    local f = io.open(d.file, "r")
    if not f then
      io.stderr:write("check_jfm_pdftex.lua: cannot open " .. d.file
        .. " (run `make pdftex-jfm` first)\n")
      os.exit(2)
    end
    f:close()
  end
  deffiles = DEFAULT_DEFS
end

-- ------------------------- helpers ------------------------------------------
local failures = 0
local function fail(msg)
  print("  FAIL: " .. msg)
  failures = failures + 1
end
local function num(x)
  if x == 0 then x = 0 end
  return string.format("%.6f", x)
end
local function hexn(cp) return string.format("%X", cp) end

-- split_groups(s): list of top-level {..} group contents in s.
local function split_groups(s)
  local groups = {}
  local pos = 1
  while true do
    local s0 = s:find("{", pos, true)
    if not s0 then break end
    local depth, p = 1, s0 + 1
    while depth > 0 and p <= #s do
      local c = s:sub(p, p)
      if c == "{" then depth = depth + 1 elseif c == "}" then depth = depth - 1 end
      p = p + 1
    end
    if depth ~= 0 then return nil end
    groups[#groups + 1] = s:sub(s0 + 1, p - 2)
    pos = p
  end
  return groups
end

-- ------------------------- JFM loading --------------------------------------
kpse.set_program_name("texlua", "lualatex")
require("lualibs")

local jfmfile = jfmfile_opt
  or (function()
    local f = io.open(scriptdir .. "/jfm-jlreq.lua", "r")
    if f then f:close(); return scriptdir .. "/jfm-jlreq.lua" end
    return kpse.find_file("jfm-jlreq.lua")
  end)()
if not jfmfile then
  io.stderr:write("check_jfm_pdftex.lua: cannot find jfm-jlreq.lua\n")
  os.exit(2)
end

local function load_jfm(obp, bura, src)
  jlreq = { open_bracket_pos = obp, burasage = bura }
  local jfm
  luatexja = { jfont = {} }
  function luatexja.jfont.define_jfm(j) jfm = j end
  dofile(src or jfmfile)
  return jfm
end

local function sha256_hex(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local data = f:read("*a")
  f:close()
  local raw = sha2.digest256(data)
  return (raw:gsub(".", function(c) return string.format("%02x", string.byte(c)) end))
end
local JFM_SHA256 = sha256_hex(jfmfile)

-- expected suffix of a .def given its declared options (same arithmetic as
-- the generator's variant_suffix: b/z/n letters; tate gets the prefix).
local function variant_suffix(obp, bura, tate)
  local s = ""
  if bura then s = s .. "b" end
  if obp == "zenkakunibu_nibu" then s = s .. "z"
  elseif obp == "nibu_tentsuki" then s = s .. "n" end
  if tate then s = "tate" .. (s ~= "" and ("-" .. s) or "") end
  return s
end

-- serialize one glue entry exactly as the generator does (ltj-jfont defaults)
local function glue_fields(g)
  if not g then return nil end
  return {
    num(g[1]), num(g[2]), num(g[3]),
    num(g.ratio or 0.5),                  -- ltj-jfont.lua:141 default
    tostring((g.priority or {0, 0})[1]),  -- ltj-jfont.lua:144
    tostring((g.priority or {0, 0})[2]),
    tostring(g.kanjiskip_natural or 0),    -- norm_val, ltj-jfont.lua:157
    tostring(g.kanjiskip_stretch or 0),
    tostring(g.kanjiskip_shrink or 0),
  }
end

local U = unicode.utf8

-- ---------- independent canary pairs (default variant, hardcoded) ----------
-- Byte-level oracles for representative values, transcribed from
-- jfm-jlreq.lua directly (NOT via the loader), so a loader regression cannot
-- mask an emission error.  Each entry cites its source location.
-- NOTE: class 0 has NO self pair 0->0 (commented out at jfm-jlreq.lua:22).
local CANARY_DEFAULT = {
  -- [0].glue[1] = {0.5, stretch_width=0.25, 0.5, ratio=1, priority={-1,-2}, knat=1}
  { "pair@0@1",   "{0.500000}{0.250000}{0.500000}{1.000000}{-1}{-2}{1}{0}{0}" },   -- :9
  -- [2].glue[0] (close bracket -> kanji): {0.5, 0.25, 0.5, ratio=0, priority={-1,-2}}
  { "pair@2@0",   "{0.500000}{0.250000}{0.500000}{0.000000}{-1}{-2}{1}{0}{0}" },   -- :66
  -- [5].glue[6] (middle dot -> full stop): {0.25, 0, 0.25, ratio=0, priority={0,-1}}
  { "pair@5@6",   "{0.250000}{0.000000}{0.250000}{0.000000}{0}{-1}{1}{0}{0}" },   -- :250
  -- [6].glue[5] (full stop -> middle dot): {0.75, 0, 0.25, ratio=0.33333333, priority={0,-1}}
  { "pair@6@5",   "{0.750000}{0.000000}{0.250000}{0.333333}{0}{-1}{1}{0}{0}" },   -- :285
  -- [1].glue[5] (open bracket -> middle dot): {0.25, 0, 0.25, ratio=1, priority={0,-1}}
  { "pair@1@5",   "{0.250000}{0.000000}{0.250000}{1.000000}{0}{-1}{1}{0}{0}" },   -- :37
  -- [0].glue[5]: {0.25, 0, 0.25, ratio=1, priority={0,-1}}
  { "pair@0@5",   "{0.250000}{0.000000}{0.250000}{1.000000}{0}{-1}{1}{0}{0}" },   -- :10
  -- [90].glue[1] = {0,0,0} (default; line-start bracket is betagumi)
  { "pair@90@1",  "{0.000000}{0.000000}{0.000000}{0.500000}{0}{0}{0}{0}{0}" },   -- :1127
  -- [7].glue[5] (comma -> middle dot): {0.75, 0, 0.75, ratio=0.33333333, priority={0,-1}}
  { "pair@7@5",   "{0.750000}{0.000000}{0.750000}{0.333333}{0}{-1}{1}{0}{0}" },   -- :311
  -- [2].glue[1] (close -> open bracket): {0.5, 0.25, 0.5, ratio=0, priority={-1,-2}}
  { "pair@2@1",   "{0.500000}{0.250000}{0.500000}{0.000000}{-1}{-2}{1}{0}{0}" },  -- :65
  -- class metrics: [1] width 0.5 (default), [6] w/h/d, align
  { "class@1",    "{0.500000}{0.880000}{0.120000}{right}{0.000000}" },
  { "class@6",    "{0.500000}{0.880000}{0.120000}{left}{0.000000}" },
  { "class@0",    "{1.000000}{0.880000}{0.120000}{middle}{0.000000}" },
  -- kanjiskip / xkanjiskip (jfm-jlreq.lua:23-24)
  { "kanjiskip",  "{0.000000}{0.250000}{0.000000}" },
  { "xkanjiskip", "{0.250000}{0.250000}{0.125000}" },
  -- end_adjust of 6 in the DEFAULT variant: source {0.5, 0} (:276), emitted
  -- sorted ascending -> {0, 0.5} (ltj-jfont.lua:123 sorts too)
  { "endadj@6",   "{0.000000}{0.500000}" },
  -- end_adjust of 2 (close brackets): {0.5, 0} sorted -> {0, 0.5} (:104)
  { "endadj@2",   "{0.000000}{0.500000}" },
}
-- Same pairs for the z variants: every k->1 glue shifts by -0.5 with the
-- ratio re-blended per add_space (jfm-jlreq.lua:1137), 90->1 gains +0.5.
-- Expected values were computed independently and hardcoded here.
local CANARY_Z = {
  ["pair@0@1"]   = "{0.000000}{0.250000}{0.500000}{0.000000}{-1}{-2}{1}{0}{0}",
  ["pair@2@1"]   = "{0.000000}{0.250000}{0.500000}{-0.333333}{-1}{-2}{1}{0}{0}",
  ["pair@90@1"]  = "{0.000000}{0.000000}{0.000000}{1.500000}{0}{0}{0}{0}{0}",
  ["class@1"]    = "{1.000000}{0.880000}{0.120000}{right}{0.000000}",
}
-- For b/bz/tate-b/tate-bz: end_adjust of 6,7 gains -0.5
-- (jfm-jlreq.lua:1167-1171), then is sorted ascending: {-0.5, 0, 0.5}.
local CANARY_B_EA = {
  ["endadj@6"]   = "{-0.500000}{0.000000}{0.500000}",
  ["endadj@7"]   = "{-0.500000}{0.000000}{0.500000}",
}
-- For n/bn (nibu_tentsuki): danraku "nibu" + orikaeshi "tentsuki", so
-- ONLY add_space(90,1,"glue",-0.5,1) fires (jfm-jlreq.lua:1159-1160) ->
-- 90->1 = {-0.5, 0, 0} ratio -0.5 (ratio arithmetic:
-- (0*0.5 + (-0.5)*1)/(0+1) = -0.5).  class 1 width stays 0.5 and every
-- other pair is byte-identical to the default variant.  Empirically
-- verified against the generated jlreq-pdftex-jfm-n.def.
local CANARY_N = {
  ["pair@90@1"]  = "{-0.500000}{0.000000}{0.000000}{-0.500000}{0}{0}{0}{0}{0}",
}
-- tate base overrides (jfm-jlreqv.lua): height=depth=0.5 per class; the
-- pair values are the RUNTIME ones (the -pl table zeroed the stretch of
-- negative-priority pairs and deleted 4->0; jfm-jlreqv.lua keeps both).
-- 0->1: {0.5, 0.25, 0.5} ratio 1 priority {-1,-2} (stretch 0.25 SURVIVES);
-- 4->0 (alchar compensation, deleted in -pl): {0.25, 0.25, 0.125} default
-- glue with knat=1 -- asserted by the PAIRS byte-check against the source.
local CANARY_TATE = {
  ["class@1"]    = "{0.500000}{0.500000}{0.500000}{right}{0.000000}",
  ["class@6"]    = "{0.500000}{0.500000}{0.500000}{left}{0.000000}",
  ["class@0"]    = "{1.000000}{0.500000}{0.500000}{middle}{0.000000}",
  ["pair@0@1"]   = "{0.500000}{0.250000}{0.500000}{1.000000}{-1}{-2}{1}{0}{0}",
  ["pair@2@0"]   = "{0.500000}{0.250000}{0.500000}{0.000000}{-1}{-2}{1}{0}{0}",
  ["pair@90@1"]  = "{0.000000}{0.000000}{0.000000}{0.500000}{0}{0}{0}{0}{0}",
  ["pair@2@1"]   = "{0.500000}{0.250000}{0.500000}{0.000000}{-1}{-2}{1}{0}{0}",
  ["pair@0@5"]   = "{0.250000}{0.000000}{0.250000}{1.000000}{0}{-1}{1}{0}{0}",
  ["pair@6@5"]   = "{0.750000}{0.000000}{0.250000}{0.333333}{0}{-1}{1}{0}{0}",
  ["pair@7@5"]   = "{0.750000}{0.000000}{0.750000}{0.333333}{0}{-1}{1}{0}{0}",
  ["pair@5@6"]   = "{0.250000}{0.000000}{0.250000}{0.000000}{0}{-1}{1}{0}{0}",
  ["pair@1@5"]   = "{0.250000}{0.000000}{0.250000}{1.000000}{0}{-1}{1}{0}{0}",
  ["endadj@6"]   = "{0.000000}{0.500000}",
  ["endadj@2"]   = "{0.000000}{0.500000}",
  ["kanjiskip"]  = "{0.000000}{0.250000}{0.000000}",
  ["xkanjiskip"] = "{0.250000}{0.250000}{0.125000}",
}

-- ---------- per-variant check driver ----------------------------------------
local function check_variant(spec)
  local deffile, obp, bura, suffix =
    spec.file, spec.obp, spec.bura, spec.suffix
  print("== " .. deffile
    .. " (open_bracket_pos=" .. obp .. " burasage=" .. tostring(bura) .. ")")
  local vfail0 = failures

  -- ---- parse the .def ------------------------------------------------------
  local defs = {}      -- name -> {top-level group contents}
  local defnames = {}  -- ordered list of defined macro names
  local nlines, ndef = 0, 0
  local header = {}
  local df = io.open(deffile, "r")
  if not df then print("  FAIL: cannot open " .. deffile) os.exit(2) end
  for line in df:lines() do
    nlines = nlines + 1
    if line:sub(1, 2) == "%%" then
      header[#header + 1] = line:sub(3)
    elseif line:sub(1, 1) == "%" then
      -- section comment
    elseif line:sub(1, 1) == "\\" and line:match("^\\expandafter\\def\\csname") then
      ndef = ndef + 1
      local name, rest = line:match("^\\expandafter\\def\\csname ([^ ]+)\\endcsname(.*)$")
      if not name then
        fail("line " .. nlines .. ": unparseable csname def")
      else
        local args = split_groups(rest)
        if not args then
          fail("line " .. nlines .. ": unbalanced braces")
        else
          if defs[name] then fail("line " .. nlines .. ": duplicate def of " .. name) end
          defs[name] = args
          defnames[#defnames + 1] = name
        end
      end
    elseif line:match("^\\def\\") then
      ndef = ndef + 1
      local name, rest = line:match("^\\def\\([^ {]+)(.*)$")
      if not name then
        fail("line " .. nlines .. ": unparseable \\def")
      else
        local args = split_groups(rest)
        if not args then
          fail("line " .. nlines .. ": unbalanced braces")
        else
          if defs[name] then fail("line " .. nlines .. ": duplicate \\def of " .. name) end
          defs[name] = args
          defnames[#defnames + 1] = name
        end
      end
    elseif line:match("^%s*$") then
      -- blank
    else
      fail("line " .. nlines .. ": unrecognized line: " .. line)
    end
  end
  df:close()

  -- ---- 1. HEADER -----------------------------------------------------------
  do
    local h = table.concat(header, "\n")
    local want_sha
    -- options line: the generator (>= 2.0) always writes
    --   %% options: dir=<yoko|tate> open_bracket_pos=<obp> burasage=<bool>
    local hop = "options: dir=" .. (spec.tate and "tate" or "yoko")
      .. " open_bracket_pos=" .. obp .. " burasage=" .. tostring(bura)
    if not h:find(hop, 1, true) then
      fail("header options line mismatched (want '" .. hop .. "')")
    end
    if spec.tate then
      -- tate variant's declared source is jfm-jlreqv.lua (the RUNTIME
      -- vertical JFM, not the -pl table that dropped negative-priority
      -- stretches and the alchar compensation pair)
      local ssrc = scriptdir .. "/" .. spec.jfmfile
      local f = io.open(ssrc, "r")
      if not f then ssrc = kpse.find_file(spec.jfmfile) else f:close() end
      local tsha = sha256_hex(ssrc)
      want_sha = "source sha256: " .. tostring(tsha)
      if not h:find("source: " .. spec.jfmfile, 1, true) then
        fail("header does not name tate source " .. spec.jfmfile)
      end
    else
      want_sha = "source sha256: " .. JFM_SHA256
    end
    if not h:find(want_sha, 1, true) then
      fail("header sha256 line missing/mismatched (want " .. want_sha .. ")")
    end
    if not h:find("generated by make_pdftex_jfm%.lua ") then
      fail("header does not name the generator")
    end
    if (defs["jlreqpdf@jfm@variant"] or {{""}})[1] ~= suffix then
      fail("jlreqpdf@jfm@variant is "
        .. tostring((defs["jlreqpdf@jfm@variant"] or {{}})[1])
        .. ", want " .. suffix)
    end
    -- variant implied by options must match the file name suffix
    -- (both directions: yoko ""/b/z/bz/n/bn, tate tate[-b|-z|-bz|-n|-bn])
    local implied = variant_suffix(obp, bura, spec.tate)
    if implied ~= suffix then
      fail("options imply variant '" .. implied .. "' but file suffix is '" .. suffix .. "'")
    end
  end

  -- ---- load the JFM for this variant ---------------------------------------
  local jfm = load_jfm(obp, bura, spec.jfmfile and (scriptdir .. "/" .. spec.jfmfile) or nil)
  if not jfm then fail("JFM did not load") return end

  local classes = {}
  for k in pairs(jfm) do if type(k) == "number" then classes[#classes + 1] = k end end
  table.sort(classes)

  -- ---- 2. COVERAGE -----------------------------------------------------------
  local n_expect, n_ok = 0, 0
  for _, c in ipairs(classes) do
    local chars = jfm[c].chars
    if chars then
      for _, ch in ipairs(chars) do
        n_expect = n_expect + 1
        if type(ch) == "string" and ch:sub(1, 4) == "AJ1-" then
          local gid = ch:sub(5)
          local a = defs["jlreqpdf@jfm@ajone@" .. c]
          local inner = a and a[1] and split_groups(a[1])
          local ok = inner ~= nil
          if ok then
            local found = false
            for _, g in ipairs(inner) do if g == gid then found = true end end
            ok = found
          end
          if ok then n_ok = n_ok + 1
          else fail("AJ1 glyph " .. ch .. " missing from ajone@" .. c) end
        elseif type(ch) == "string" and U.len(ch) == 1 then
          local cp = U.byte(ch)
          local cls = defs["jlreqpdf@jfm@cls@" .. hexn(cp)]
          if not cls then
            fail(string.format("char U+%X (%s) missing from dispatch", cp, ch))
          elseif cls[1] ~= tostring(c) then
            fail(string.format("char U+%X dispatched to %s, expected %d", cp, cls[1], c))
          else
            n_ok = n_ok + 1
          end
        elseif type(ch) == "string" and (ch == "alchar" or ch == "nox_alchar"
          or ch == "parbdd" or ch == "boxbdd" or ch == "jcharbdd" or ch == "glue") then
          local p = defs["jlreqpdf@jfm@pseudo@" .. ch]
          if not p then
            fail("pseudo char " .. ch .. " missing from dispatch")
          elseif p[1] ~= tostring(c) then
            fail("pseudo " .. ch .. " dispatched to " .. p[1] .. ", expected " .. c)
          else
            n_ok = n_ok + 1
          end
        elseif type(ch) == "string" and U.len(ch) >= 2 then
          local a = defs["jlreqpdf@jfm@combo@" .. c]
          local ok = a and a[1] and true
          if ok then
            local hs = {}
            for k = 1, U.len(ch) do hs[#hs + 1] = "U+" .. hexn(U.byte(ch, k)) end
            local want = table.concat(hs, ",")
            local found = false
            for item in a[1]:gmatch("%S+") do if item == want then found = true end end
            ok = found
          end
          if ok then n_ok = n_ok + 1
          else fail("combo " .. ch .. " missing from combo@" .. c) end
        else
          fail("unclassifiable source entry " .. tostring(ch) .. " in class " .. c)
        end
      end
    end
  end
  if n_expect > 0 and n_ok == n_expect then
    print(string.format("  coverage: %d/%d char entries accounted for", n_ok, n_expect))
  else
    fail(string.format("coverage incomplete: %d/%d", n_ok, n_expect))
  end

  -- no char in two classes (source side check)
  local seen = {}
  for _, c in ipairs(classes) do
    local chars = jfm[c].chars
    if chars then
      for _, ch in ipairs(chars) do
        if type(ch) == "string" and U.len(ch) == 1 then
          local cp = U.byte(ch)
          if seen[cp] then
            fail(string.format("char U+%X appears in classes %d and %d in source",
              cp, seen[cp], c))
          end
          seen[cp] = c
        end
      end
    end
  end

  -- ---- 3. PAIRS: ALL defined pairs byte-checked ----------------------------
  local npairs_src = 0
  for _, f in ipairs(classes) do
    local g = jfm[f].glue or {}
    local tos = {}
    for t in pairs(g) do tos[#tos + 1] = t end
    table.sort(tos)
    for _, t in ipairs(tos) do
      npairs_src = npairs_src + 1
      local want = glue_fields(g[t])
      local d = defs[string.format("jlreqpdf@jfm@pair@%d@%d", f, t)]
      if not d then
        fail(string.format("pair %d->%d missing from .def", f, t))
      else
        -- 新形式: 本体は \jlreqpdf@pairfields{f1}...{f9} マクロ呼び出し
        -- （.def側で引数再括弧化問題を回避するため）。
        local body = d[1]:gsub("^\\jlreqpdf@pairfields", "")
        local got = split_groups(body)
        local ok = got ~= nil and #got == #want
        if ok then
          for k = 1, #want do if got[k] ~= want[k] then ok = false end end
        end
        if not ok then
          fail(string.format("pair %d->%d: .def {%s} != expected {%s}",
            f, t, d[1], table.concat(want, "}{")))
        end
      end
    end
  end
  -- no EXTRA pairs in the .def beyond the source
  local npairs_def = 0
  for _, name in ipairs(defnames) do
    if name:match("^jlreqpdf@jfm@pair@") then npairs_def = npairs_def + 1 end
  end
  if npairs_def ~= npairs_src then
    fail(string.format("pair count mismatch: .def has %d, source defines %d",
      npairs_def, npairs_src))
  end
  print(string.format("  pairs: %d/%d defined pairs byte-checked (no extras)",
    npairs_src, npairs_def))

  -- ---- independent canaries -------------------------------------------------
  -- Byte-level oracles on top of the loader-based checks.  Dispatch:
  --   tate  -> CANARY_TATE (runtime-stretch values) overrides the yoko
  --            defaults first;
  --   z-ish (z, bz, tate-z, tate-bz) -> CANARY_Z overrides on top;
  --   n-ish (n, bn, tate-n, tate-bn) -> CANARY_N on top (only 90->1);
  --   b-ish (any suffix containing "b") -> CANARY_B_EA on top.
  -- The z bracket-width override uses the direction-correct height/depth
  -- (yoko 0.88/0.12, tate 0.5/0.5).
  local ncanary = 0
  local is_zish = (suffix == "z" or suffix == "bz"
    or suffix == "tate-z" or suffix == "tate-bz")
  local is_nish = (suffix == "n" or suffix == "bn"
    or suffix == "tate-n" or suffix == "tate-bn")
  local is_bish = suffix ~= "" and suffix:find("b", 1, true) ~= nil
  local CANARY_Z_CLASS1 = spec.tate
    and "{1.000000}{0.500000}{0.500000}{right}{0.000000}"
    or "{1.000000}{0.880000}{0.120000}{right}{0.000000}"
  for _, chk in ipairs(CANARY_DEFAULT) do
    local name, want = chk[1], chk[2]
    if spec.tate and CANARY_TATE[name] then
      want = CANARY_TATE[name]
    end
    if is_zish then
      if name == "pair@0@1" then want = CANARY_Z["pair@0@1"]
      elseif name == "pair@2@1" then want = CANARY_Z["pair@2@1"]
      elseif name == "pair@90@1" then want = CANARY_Z["pair@90@1"]
      elseif name == "class@1" then want = CANARY_Z_CLASS1 end
    elseif is_nish then
      -- nibu_tentsuki: only 90->1 changes (CANARY_N); every other pair
      -- stays at the tate/default values, incl. class 1 width 0.5.
      if name == "pair@90@1" then want = CANARY_N["pair@90@1"] end
    end
    if is_bish and (name == "endadj@6" or name == "endadj@7") then
      want = CANARY_B_EA[name]
    end
    local d = defs["jlreqpdf@jfm@" .. name]
    local body = d and d[1]
    if body and name:match("^pair@") then
      body = body:gsub("^\\jlreqpdf@pairfields", "")
    end
    if not d then
      fail("canary " .. name .. " missing")
    elseif body ~= want then
      fail("canary " .. name .. " = " .. body .. ", want " .. want)
    else
      ncanary = ncanary + 1
    end
  end
  print(string.format("  canaries: %d hardcoded byte-oracles OK", ncanary))

  -- ---- 4. METRICS -------------------------------------------------------------
  do
    local ks = split_groups(defs["jlreqpdf@jfm@kanjiskip"][1])
    local xs = split_groups(defs["jlreqpdf@jfm@xkanjiskip"][1])
    if defs["jlreqpdf@jfm@zw"][1] ~= num(jfm.zw) then fail("zw mismatch") end
    if defs["jlreqpdf@jfm@zh"][1] ~= num(jfm.zh) then fail("zh mismatch") end
    if defs["jlreqpdf@jfm@dir"][1] ~= jfm.dir then fail("dir mismatch") end
    if defs["jlreqpdf@jfm@version"][1] ~= tostring(jfm.version or 1) then fail("version mismatch") end
    if not ks or ks[1] ~= num(jfm.kanjiskip[1]) or ks[2] ~= num(jfm.kanjiskip[2])
      or ks[3] ~= num(jfm.kanjiskip[3]) then
      fail("kanjiskip mismatch: got {" .. defs["jlreqpdf@jfm@kanjiskip"][1]
        .. "} want {" .. num(jfm.kanjiskip[1]) .. "}{" .. num(jfm.kanjiskip[2])
        .. "}{" .. num(jfm.kanjiskip[3]) .. "}")
    end
    if not xs or xs[1] ~= num(jfm.xkanjiskip[1]) or xs[2] ~= num(jfm.xkanjiskip[2])
      or xs[3] ~= num(jfm.xkanjiskip[3]) then
      fail("xkanjiskip mismatch")
    end
    -- classlist: the emitted comma-separated class list must equal the
    -- loaded JFM's class set exactly (sorted, no extras, no omissions).
    local cl = defs["jlreqpdf@jfm@classlist"]
    if not cl then
      fail("jlreqpdf@jfm@classlist missing (P2 format)")
    else
      local got = {}
      for n in cl[1]:gmatch("[^,]+") do got[#got + 1] = tonumber(n) end
      if #got ~= #classes then
        fail("classlist has " .. #got .. " classes, loaded JFM has " .. #classes)
      else
        for k = 1, #classes do
          if got[k] ~= classes[k] then
            fail("classlist[" .. k .. "] = " .. tostring(got[k])
              .. ", want " .. classes[k])
          end
        end
      end
    end
  end
  for _, c in ipairs(classes) do
    local v = jfm[c]
    local w, h, d = v.width or 1, v.height or 0.88, v.depth or 0.12
    local left = v.left or 0
    local got = defs["jlreqpdf@jfm@class@" .. c]
    if got then got = split_groups(got[1]) end -- {{w}{h}{d}{align}{left}}
    if not got then
      fail("class " .. c .. " metrics missing")
    elseif got[1] ~= num(w) or got[2] ~= num(h) or got[3] ~= num(d)
      or got[4] ~= (v.align or "left") or got[5] ~= num(left) then
      fail("class " .. c .. " metrics mismatch: {" .. table.concat(got, ",")
        .. "} expected {" .. num(w) .. "," .. num(h) .. "," .. num(d) .. ","
        .. (v.align or "left") .. "," .. num(left) .. "}")
    end
    local ea = v.end_adjust
    local ge = defs["jlreqpdf@jfm@endadj@" .. c]
    if ea then
      local copy = {}
      for k = 1, #ea do copy[k] = ea[k] end
      table.sort(copy) -- ltj-jfont.lua:123 sorts too
      local inner = ge and ge[1] and split_groups(ge[1])
      if not inner or #inner ~= #copy then
        fail("class " .. c .. " end_adjust missing/size")
      else
        for k = 1, #copy do
          if inner[k] ~= num(copy[k]) then
            fail("class " .. c .. " end_adjust[" .. k .. "] mismatch")
          end
        end
      end
    elseif ge then
      fail("class " .. c .. " has endadj in .def but none in JFM")
    end
  end
  print("  metrics: all " .. #classes .. " classes + kanjiskip/xkanjiskip/zw/zh/dir OK")

  -- ---- 5. STRUCTURE ------------------------------------------------------------
  local family_counts = {}
  for _, name in ipairs(defnames) do
    local fam = name:match("^jlreqpdf@jfm@([%w]+)@") or name:match("^jlreqpdf@jfm@([%w]+)$") or "?"
    family_counts[fam] = (family_counts[fam] or 0) + 1
  end
  local fams = {}
  for f in pairs(family_counts) do fams[#fams + 1] = f end
  table.sort(fams)
  local cl = {}
  for _, f in ipairs(fams) do cl[#cl + 1] = f .. "=" .. family_counts[f] end
  print("  families: " .. table.concat(cl, " "))
  print(string.format("  total \\defs: %d  (lines: %d)", ndef, nlines))

  -- ---- 6. SEMANTICS: variant-specific oracles -----------------------------------
  local is_z = (suffix == "z" or suffix == "bz"
    or suffix == "tate-z" or suffix == "tate-bz")
  local is_n = (suffix == "n" or suffix == "bn"
    or suffix == "tate-n" or suffix == "tate-bn")
  local is_b = suffix ~= "" and suffix:find("b", 1, true) ~= nil
  if is_z then
    -- jfm-jlreq.lua:1148-1155: class 1 width +0.5; every k->1 glue -0.5
    -- (ratio re-blended by add_space); :1159-1160: 90->1 +0.5.
    local c1 = split_groups(defs["jlreqpdf@jfm@class@1"][1])
    if not c1 or c1[1] ~= num(1.0) then
      fail("z variant: class 1 width must be 1.000000, got "
        .. defs["jlreqpdf@jfm@class@1"][1])
    end
    -- every k->1 natural is exactly 0.5 less than in the default table,
    -- except 90->1 whose net is 0 (=-0.5 then +0.5), ratio 1.5.  The
    -- default table is the SAME direction's zenkaku_tentsuki table.
    local jd = load_jfm("zenkaku_tentsuki", false, spec.jfmfile)
    for _, f in ipairs(classes) do
      local gd = jd[f].glue and jd[f].glue[1]
      local gz = jfm[f].glue and jfm[f].glue[1]
      if gd and gz then
        local dz = split_groups(defs[string.format("jlreqpdf@jfm@pair@%d@1", f)][1])
        local want_nat = num(gd[1] - 0.5 + (f == 90 and 0.5 or 0))
        if dz[1] ~= want_nat then
          fail(string.format("z variant: pair %d->1 natural %s, want %s (default-0.5)",
            f, dz[1], want_nat))
        end
      elseif gd and not gz then
        fail("z variant: pair " .. f .. "->1 lost")
      elseif gz and not gd then
        fail("z variant: pair " .. f .. "->1 appeared from nowhere")
      end
    end
    local p901 = split_groups(defs["jlreqpdf@jfm@pair@90@1"][1])
    if p901[1] ~= num(0) or p901[4] ~= num(1.5) then
      fail("z variant: pair 90->1 must be {0.000000}...{1.500000}, got "
        .. defs["jlreqpdf@jfm@pair@90@1"][1])
    end
    print("  semantics: z oracle OK (class1 width 1.0, all ->1 pairs -0.5, 90->1 {0}r1.5)")
  elseif is_n then
    -- nibu_tentsuki = danraku "nibu" + orikaeshi "tentsuki"
    -- (jfm-jlreq.lua:1145 splits at "_"; the fold-line branch
    -- orikaeshi=="nibu" does NOT fire).  Only 90->1 changes:
    -- add_space(90,1,"glue",-0.5,1) on {0,0,0} ratio 0.5 ->
    -- natural -0.5, ratio (0*0.5 + (-0.5)*1)/(0+1) = -0.5.
    local c1 = split_groups(defs["jlreqpdf@jfm@class@1"][1])
    if not c1 or c1[1] ~= num(0.5) then
      fail("n variant: class 1 width must stay 0.500000 (only the danraku "
        .. "branch fires), got " .. defs["jlreqpdf@jfm@class@1"][1])
    end
    local p901 = split_groups(defs["jlreqpdf@jfm@pair@90@1"][1])
    if p901[1] ~= num(-0.5) or p901[4] ~= num(-0.5) then
      fail("n variant: pair 90->1 must be {-0.500000}{0.000000}{0.000000}"
        .. "{-0.500000}..., got " .. defs["jlreqpdf@jfm@pair@90@1"][1])
    end
    -- every OTHER k->1 pair is byte-identical to the same direction's
    -- default table (empirical nibu oracle: only 90->1 diverges).
    local jd = load_jfm("zenkaku_tentsuki", false, spec.jfmfile)
    for _, f in ipairs(classes) do
      if f ~= 90 then
        local gd = jd[f].glue and jd[f].glue[1]
        local gn = jfm[f].glue and jfm[f].glue[1]
        if (gd == nil) ~= (gn == nil) then
          fail("n variant: pair " .. f .. "->1 presence differs from default")
        elseif gd and gn then
          local dn = split_groups(defs[string.format("jlreqpdf@jfm@pair@%d@1", f)][1])
          if dn[1] ~= num(gd[1]) then
            fail(string.format("n variant: pair %d->1 natural %s must equal the "
              .. "default %s (only 90->1 changes)", f, dn[1], num(gd[1]))
            )
          end
        end
      end
    end
    print("  semantics: n oracle OK (90->1 {-0.5}r-0.5, other pairs = default)")
  else
    local c1 = split_groups(defs["jlreqpdf@jfm@class@1"][1])
    if not c1 or c1[1] ~= num(0.5) then
      fail("default/b variant: class 1 width must be 0.500000, got "
        .. defs["jlreqpdf@jfm@class@1"][1])
    end
  end
  if is_b then
    -- jfm-jlreq.lua:1167-1171: end_adjust of 6,7 = source {0.5,0} + {-0.5},
    -- then sorted ascending -> {-0.5, 0, 0.5} (ltj-jfont.lua:123 sorts too)
    local b_ok = true
    for _, c in ipairs({ 6, 7 }) do
      local got = split_groups(defs["jlreqpdf@jfm@endadj@" .. c][1])
      if not got or #got ~= 3 or got[1] ~= num(-0.5) or got[2] ~= num(0)
        or got[3] ~= num(0.5) then
        fail("b variant: end_adjust of class " .. c
          .. " must be {-0.500000}{0.000000}{0.500000} (sorted), got "
          .. defs["jlreqpdf@jfm@endadj@" .. c][1])
        b_ok = false
      end
    end
    if b_ok then
      print("  semantics: b oracle OK (end_adjust of 6,7 = {-0.5}{0}{0.5})")
    end
  else
    -- non-b: end_adjust of 6,7 stays the source {0.5,0}, sorted -> {0,0.5}
    local nb_ok = true
    for _, c in ipairs({ 6, 7 }) do
      local got = split_groups(defs["jlreqpdf@jfm@endadj@" .. c][1])
      if not got or #got ~= 2 or got[1] ~= num(0) or got[2] ~= num(0.5) then
        fail("non-b variant: end_adjust of class " .. c
          .. " must be {0.000000}{0.500000}, got "
          .. defs["jlreqpdf@jfm@endadj@" .. c][1])
        nb_ok = false
      end
    end
    if nb_ok then
      print("  semantics: non-b oracle OK (end_adjust of 6,7 = {0}{0.5})")
    end
  end
  if spec.tate then
    -- tate oracle: the RUNTIME vertical JFM keeps the stretch of
    -- negative-priority pairs (the -pl table zeroed it) and the alchar
    -- compensation pair 4->0 (the -pl table deleted it).  Both would be
    -- caught by the PAIRS byte-check already; assert the two flagships
    -- here as independent canaries with their arithmetic.
    local p01 = split_groups(defs["jlreqpdf@jfm@pair@0@1"][1])
    if p01[2] ~= num(0.25) then
      fail("tate: pair 0->1 stretch must be 0.250000 (runtime value; the "
        .. "-pl table zeroed it), got " .. p01[2])
    end
    local p40 = defs["jlreqpdf@jfm@pair@4@0"]
    if not p40 then
      fail("tate: pair 4->0 (alchar compensation) missing; the -pl table "
        .. "deleted it, the runtime jfm-jlreqv.lua keeps it")
    end
    local c1 = split_groups(defs["jlreqpdf@jfm@class@1"][1])
    if c1[2] ~= num(0.5) or c1[3] ~= num(0.5) then
      fail("tate: class height/depth must be 0.5 (make_variant_jfm tate())")
    end
    print("  semantics: tate oracle OK (0->1 stretch 0.25 kept, 4->0 kept, h/d 0.5)")
  end

  -- cross-variant diff summary (informational, via committed sibling files)
  print((failures == vfail0) and ("  PASS " .. deffile) or ("  FAILED " .. deffile))
  return failures == vfail0
end

-- ------------------------- run ----------------------------------------------
local all_ok = true
for _, f in ipairs(deffiles) do
  local spec
  if type(f) == "table" then
    spec = f
  else
    -- explicit file argument: infer the variant from the file name
    -- (suffix letters: b/bz/n/bn for yoko; tate[-b|-z|-bz|-n|-bn] for tate)
    local sfx = f:match("jlreq%-pdftex%-jfm%-?(%w*)%.def$") or "?"
    local known = { [""] = true, b = true, z = true, bz = true,
      n = true, bn = true, tate = true, ["tate-b"] = true,
      ["tate-z"] = true, ["tate-bz"] = true, ["tate-n"] = true,
      ["tate-bn"] = true }
    if not known[sfx] then
      io.stderr:write("check_jfm_pdftex.lua: cannot infer variant of " .. f .. "\n")
      os.exit(2)
    end
    local tate = sfx:sub(1, 4) == "tate"
    spec = {
      file = f, suffix = sfx, tate = tate,
      jfmfile = tate and "jfm-jlreqv.lua" or nil,
      obp = (sfx == "z" or sfx == "bz" or sfx == "tate-z" or sfx == "tate-bz")
          and "zenkakunibu_nibu"
        or (sfx == "n" or sfx == "bn" or sfx == "tate-n" or sfx == "tate-bn")
          and "nibu_tentsuki" or "zenkaku_tentsuki",
      bura = sfx == "b" or sfx == "bz" or sfx == "bn"
        or sfx == "tate-b" or sfx == "tate-bz" or sfx == "tate-bn",
    }
  end
  if not check_variant(spec) then all_ok = false end
  print("")
end
if all_ok then
  print("check_jfm_pdftex: ALL CHECKS PASSED (" .. #deffiles .. " file(s))")
  os.exit(0)
else
  print("check_jfm_pdftex: " .. failures .. " failure(s)")
  os.exit(1)
end
