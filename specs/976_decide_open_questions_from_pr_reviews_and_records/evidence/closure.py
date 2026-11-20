import subprocess, sys, re, functools
ref = sys.argv[1]; roots = sys.argv[2:]
files = subprocess.run(["git","ls-tree","-r","--name-only",ref,"FormalSystem"],capture_output=True,text=True).stdout.split()
mods = {f[:-5].replace("/","."):f for f in files if f.endswith(".lean")}
LAY={"Syntax":0,"ProofSystem":0,"ForMathlib":0,"Init":0,"Tactic":0,"Version":0,"Semantics":1,"Theorems":2,"Metalogic":3,"Automation":3,"Examples":4,"MainResults":4}
@functools.lru_cache(None)
def imps(m):
    src = subprocess.run(["git","show",f"{ref}:{mods[m]}"],capture_output=True,text=True).stdout
    out=[]
    for l in src.splitlines():
        mm = re.match(r'^\s*(?:public\s+)?(?:meta\s+)?import\s+(?:all\s+)?(\S+)',l)
        if mm and mm.group(1) in mods: out.append(mm.group(1))
    return tuple(out)
def closure(m):
    seen=set(); st=[m]
    while st:
        x=st.pop()
        for y in imps(x):
            if y not in seen: seen.add(y); st.append(y)
    return seen
for r in roots:
    c=closure(r)
    by={}
    for m in c:
        d=m.split(".")[1]
        by.setdefault(d,[]).append(m)
    print("==",r,"direct:",[i for i in imps(r)])
    print("   closure size",len(c),"by top dir:",{k:len(v) for k,v in sorted(by.items())})
    for k in ("Theorems","Metalogic","Automation","Examples"):
        if k in by: print("   ",k,sorted(by[k])[:12])
