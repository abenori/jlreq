#!/usr/bin/env python3
"""行頭禁則検証: 実PDFのbboxから、閉じ約物（」』）。，・？！…‥）が
行頭（左余白 x<100pt）に来ていないかを機械判定する。
Usage: check-kinsoku.py <pdf> [<pdf> ...]

行のグルーピングは round(yMin) ではなく 3pt 以内の yMin クラスタで行う：
約物グリフのインク高さは字種ごとに0.7pt程度異なり（F2の0.5zw箱化で
顕在化），丸めで同一視覚行が2行に分裂し誤検出するため。
"""
import subprocess, sys, re

PUNCT = set('」』）。，・？！…‥')

def rows_of(pdf):
    out = subprocess.run(['pdftotext', '-bbox', pdf, '-'],
                        capture_output=True, text=True).stdout
    words = []
    for m in re.finditer(r'xMin="([0-9.]+)" yMin="([0-9.]+)"[^>]*>([^<]+)<', out):
        words.append((float(m.group(2)), float(m.group(1)), m.group(3)))
    words.sort()
    rows = []  # each row: [seed_y, [(x, y, t), ...]]
    for y, x, t in words:
        for row in rows:
            if abs(row[0] - y) < 3:
                row[1].append((x, y, t))
                break
        else:
            rows.append([y, [(x, y, t)]])
    return [row[1] for row in rows]

def check(pdf):
    bad = []
    for row in rows_of(pdf):
        row.sort()
        x, y, t = row[0]
        if t and t[0] in PUNCT and x < 100:
            bad.append(t[:3])
    return bad

ok = True
for pdf in sys.argv[1:]:
    bad = check(pdf)
    if bad:
        print(f'FAIL {pdf}: line-head punctuation {bad}')
        ok = False
    else:
        print(f'PASS {pdf}')
sys.exit(0 if ok else 1)
