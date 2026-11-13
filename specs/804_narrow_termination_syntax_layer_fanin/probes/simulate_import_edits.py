import sys,collections,copy
S=sys.argv[1]
G=collections.defaultdict(list)
for l in open(S+'/graph.tsv'):
    a,b=l.rstrip('\n').split('\t'); G[a].append(b)
U=collections.defaultdict(dict)
for l in open(S+'/uses.tsv'):
    a,b,c=l.rstrip('\n').split('\t'); U[a][b]=c
F='FormalSystem.'; D=F+'Metalogic.Decidability.'; T=D+'Verified.Termination.'
def clo(g,m,memo):
    if m in memo: return memo[m]
    seen=set();st=[m]
    while st:
        x=st.pop()
        for y in g.get(x,[]):
            if y not in seen: seen.add(y);st.append(y)
    memo[m]=seen;return seen
ours=[m for m in G if m.split('.')[0] in('FormalSystem','BimodalTest','BimodalTools')]+['FormalSystem','BimodalTest','BimodalTools']
ours=sorted(set(ours))
# sanity: current graph has no violations
def violations(g):
    memo={};out=[]
    for m in ours:
        c=clo(g,m,memo)
        for dm,ex in U.get(m,{}).items():
            if dm not in c: out.append((m,dm,ex))
    return out
print('baseline violations',len(violations(G)))
def rdeps(g,src):
    memo={};return [m for m in ours if src in clo(g,m,memo)]
def edit(g,relocate):
    g=copy.deepcopy(g)
    def rm(m,x): g[m]=[y for y in g[m] if y!=x]
    def add(m,x):
        if x not in g[m]: g[m].append(x)
    rm(F+'Automation.ProofSearch.Core',F+'Semantics'); rm(F+'Automation.ProofSearch.Core',F+'ProofSystem')
    add(F+'Automation.ProofSearch.Core',F+'ProofSystem.Derivation'); add(F+'Automation.ProofSearch.Core',F+'ProofSystem.DerivedAxioms')
    rm(F+'Automation.SuccessPatterns',F+'Syntax'); add(F+'Automation.SuccessPatterns',F+'Syntax.Formula')
    rm(D+'SignedFormula',F+'ProofSystem')
    rm(D+'TraceCertificate',F+'Syntax'); rm(D+'TraceCertificate',F+'ProofSystem')
    rm(T+'SubformulaProperty',F+'Syntax.SubformulaClosure.Closure')
    if relocate:
        FC=F+'ProofSystem.FrameClass'; g[FC]=[x for x in g[F+'ProofSystem.Axioms'] if not x.startswith(F)]
        add(F+'ProofSystem.Axioms',FC); add(D+'Tableau',FC)
    else: add(D+'Tableau',F+'ProofSystem.Axioms')
    return g
for rel in (False,True):
    g=edit(G,rel)
    v=violations(g)
    if rel:
        # FrameClass constants now live in FC module
        FC=F+'ProofSystem.FrameClass'; memo={}
        v=[(m,dm,ex) for (m,dm,ex) in v if not (dm==F+'ProofSystem.Axioms' and FC in clo(g,m,memo))] # approximate; refined below
    print('== relocate',rel,'violations',len(v))
    bym=collections.defaultdict(list)
    for m,dm,ex in v: bym[m].append((dm,ex))
    for m in sorted(bym): print('  ',m,'needs',[(d.replace('FormalSystem.',''),e) for d,e in bym[m]][:6], '(+%d)'%max(0,len(bym[m])-6))
    for src in ['ProofSystem.Axioms','ProofSystem.Derivation','ProofSystem.Derivable','ProofSystem.DerivedAxioms','Syntax.Formula','Syntax.Context','Syntax.Subformulas','Syntax.SubformulaClosure.Closure','Syntax.SubformulaClosure.NestingDepth','Syntax.SubformulaClosure.TemporalFormulas','Syntax','Semantics','Semantics.Validity','Semantics.Truth','Semantics.TaskFrame','Theorems.Combinators']:
        b=rdeps(G,F+src); a=rdeps(g,F+src)
        tb=[m for m in b if m.startswith(T)]; ta=[m for m in a if m.startswith(T)]
        db=[m for m in b if m.startswith(D)]; da=[m for m in a if m.startswith(D)]
        print(f'  edit {src}: rdeps {len(b)} -> {len(a)}; Decidability {len(db)} -> {len(da)}; Termination {len(tb)} -> {len(ta)}')
    if rel:
        import pickle; pickle.dump(g,open(S+'/gnew.pkl','wb'))
        lost=sorted(set(rdeps(G,F+'ProofSystem.Axioms'))-set(rdeps(g,F+'ProofSystem.Axioms'))); print('  no longer rebuilt on Axioms edit:',[m.replace(D,'D.') for m in lost])
        lost=sorted(set(rdeps(G,F+'Semantics'))-set(rdeps(g,F+'Semantics'))); print('  no longer rebuilt on Semantics.lean edit (%d):'%len(lost),[m.replace(D,'D.').replace(F,'') for m in lost][:200])
        still=sorted(m for m in rdeps(g,F+'Semantics') if m.startswith(D)); print('  Decidability still downstream of Semantics aggregator:',len(still),[m.replace(D,'') for m in still][:60])
