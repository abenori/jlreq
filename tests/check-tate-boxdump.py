#!/usr/bin/env python3
"""check-tate-boxdump.py -- kinsoku check for the pdfTeX tate path.

Parses the \\showbox galley dump produced by
tests/fixtures/pdflatex-tate-boxdump.tex (markers TATE-GALLEY-BEGIN/END)
and asserts:
  1. the galley was broken into >= 3 galley lines (columns after
     shipout rotation),
  2. no galley line starts with a CJK pre-break-penalty punct:
     、 (U+3001) or 。 (U+3002) -- plane "30", byte 1/2. These pages
     appear in the dump as C70/<fam>/m/n/10/30 ^^A / ^^B / control
     bytes.
Exit 0 on success, 1 on violation.
"""
import sys, re

log = open(sys.argv[1], encoding='latin-1').read()
m = re.search(r'TATE-GALLEY-BEGIN(.*?)TATE-GALLEY-END', log, re.S)
if not m:
    print("TATE-BOXDUMP-FAIL: no galley markers in log"); sys.exit(1)
gal = m.group(1)

# split into depth-1 line boxes: lines starting with ".\hbox("
if 'No Detail Version' in gal:
    pass
lines = []
cur = None
for l in gal.splitlines():
    if re.match(r'^\.\\hbox\(', l):
        if cur is not None:
            lines.append(cur)
        cur = l
    else:
        if cur is not None:
            cur += '\n' + l
if cur is not None:
    lines.append(cur)

if len(lines) < 3:
    print(f"TATE-BOXDUMP-FAIL: only {len(lines)} galley lines (<3)"); sys.exit(1)

PUNCT = re.compile(r'C70/[^\s]*/[^\s]*/[^\s]*/([0-9a-fA-F]{2}) (\S)')
def bytevalue(tok):
    if len(tok) == 2 and tok[0] == '^' and tok[1] == '^':
        return -1  # ^^XX hex-ish notation, not a punct case here
    if len(tok) == 1:
        v = ord(tok)
        return v
    if tok.startswith('^^') and len(tok) > 2:
        # control char, e.g. ^^A (0x01) / ^^B (0x02)
        return ord(tok[2]) - 64
    # multi-byte UTF-8 char (non-punct for our purposes)
    return -1

found_bad = []
firsts = []
for i, block in enumerate(lines):
    g = PUNCT.search(block)
    if not g:
        firsts.append(('??', '?'))
        continue
    plane, tok = g.group(1), g.group(2)
    bv = bytevalue(tok)
    firsts.append((plane, tok, bv))
    if plane == '30' and bv in (1, 2):
        found_bad.append(i)

print(f"TATE-BOXDUMP: {len(lines)} galley lines; line-head glyphs: {firsts}")
if found_bad:
    print(f"TATE-BOXDUMP-FAIL: 、。 opening galley line(s) {found_bad}")
    sys.exit(1)
print("TATE-BOXDUMP-PASS")
sys.exit(0)
