import re, os, json, sys, collections
S = os.environ['S']
raw = os.path.join(S, 'raw')
pos_re = re.compile(r'^(Theories/[^\s:]+\.lean):(\d+):(\d+): (warning|error): (.*)$')
note_re = re.compile(r'set_option (linter\.[A-Za-z.]+) false')
records = []  # (file, line, col, category, msg)
for fn in sorted(os.listdir(raw)):
    cur = None
    pending = []
    for ln in open(os.path.join(raw, fn), errors='replace'):
        m = pos_re.match(ln.rstrip('\n'))
        if m:
            if cur: records.append(cur)
            cur = [m.group(1), int(m.group(2)), int(m.group(3)), None, m.group(5)]
            continue
        if cur is not None:
            n = note_re.search(ln)
            if n and cur[3] is None:
                cur[3] = n.group(1)
    if cur: records.append(cur)
# categorize uncategorized
for r in records:
    if r[3] is None:
        msg = r[4]
        if 'has been deprecated' in msg or 'deprecated' in msg.lower():
            r[3] = '(deprecation)'
        else:
            r[3] = '(uncategorized)'
json.dump(records, open(os.path.join(S,'records.json'),'w'))
print("total warnings:", len(records))
cats = collections.Counter(r[3] for r in records)
sites = collections.Counter()
for c in cats:
    sites[c] = len({(r[0],r[1],r[2]) for r in records if r[3]==c})
print(f"{'category':38s} {'raw':>6s} {'sites':>6s} {'files':>6s}")
for c, n in cats.most_common():
    nf = len({r[0] for r in records if r[3]==c})
    print(f"{c:38s} {n:6d} {sites[c]:6d} {nf:6d}")
