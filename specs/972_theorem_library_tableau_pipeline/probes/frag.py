import json, sys, collections

TEMPORAL = {"untl","sinc","all_future","some_future","all_past","some_past","always","sometimes","next","prev"}
def prof(a, acc):
    t = a.get("tag")
    if t == "box": acc.add("box")
    elif t in ("stab","circ","stab_box"): acc.add("stab")
    elif t in TEMPORAL: acc.add("temporal")
    for k,v in a.items():
        if isinstance(v, dict) and "tag" in v: prof(v, acc)
    return acc

def frag(acc):
    m = "box" in acc or "stab" in acc
    tp = "temporal" in acc
    if m and tp: return "ModalTemporalBoolean"
    if m: return "ModalBoolean"
    if tp: return "TemporalBoolean"
    return "Boolean"

path = sys.argv[1]
tab = collections.defaultdict(lambda: collections.Counter())
bycx = collections.defaultdict(lambda: collections.Counter())
tiers = collections.defaultdict(lambda: collections.Counter())
n=0
for line in open(path):
    line=line.strip()
    if not line: continue
    d=json.loads(line); n+=1
    acc = prof(d["formula_ast"], set())
    f = frag(acc)
    lab = d["label"]
    ops = "+".join(sorted(acc)) or "none"
    tab[(f,ops)][lab]+=1
    tab[(f,ops)]["total"]+=1
    cx = d["metrics"]["complexity"]
    bycx[cx][lab]+=1; bycx[cx]["total"]+=1
    if lab=="valid":
        tiers[f][d.get("interestingness_tier")]+=1
print("records:", n)
print("\n%-26s %-16s %7s %7s %9s %9s" % ("fragment","opset","total","valid","invalid","undet"))
for (f,ops),c in sorted(tab.items()):
    print("%-26s %-16s %7d %7d %9d %9d" % (f,ops,c["total"],c["valid"],c["invalid"],c["total"]-c["valid"]-c["invalid"]))
print("\nby metrics.complexity:")
print("%6s %8s %7s %9s %9s" % ("cx","total","valid","invalid","undet"))
for cx in sorted(bycx):
    c=bycx[cx]
    print("%6d %8d %7d %9d %9d" % (cx,c["total"],c["valid"],c["invalid"],c["total"]-c["valid"]-c["invalid"]))
print("\nvalid-formula interestingness tiers by fragment:")
for f,c in sorted(tiers.items()):
    print(" ", f, dict(c))
