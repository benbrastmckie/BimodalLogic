import json,sys,collections
path=sys.argv[1]
c=collections.Counter(); meth=collections.Counter(); rp=collections.Counter()
cm=collections.Counter()
for line in open(path):
    line=line.strip()
    if not line: continue
    d=json.loads(line)
    lab=d["label"]
    if lab=="valid":
        c["valid"]+=1
        c["has_trace"]+= 1 if d.get("proof_trace") else 0
        meth[d.get("proof_reconstruction_method")]+=1
        if d.get("rule_profile"): c["has_rule_profile"]+=1
    elif lab=="invalid":
        c["invalid"]+=1
        if d.get("enriched_countermodel"): c["inv_enriched"]+=1
        if d.get("countermodel_consistent"): c["inv_consistent"]+=1
        sc=d.get("semantic_countermodel") or {}
        cm[(sc.get("world_count"),sc.get("time_count"))]+=1
    else:
        c[lab]+=1
print(path)
print(" ", dict(c))
print("  proof_reconstruction_method:", dict(meth))
print("  invalid countermodel (worlds,times) top:", cm.most_common(8))
