"""Reverse import closures (= Lake rebuild sets) from graph.tsv written by WholeRepoUsesProbe.lean.
Usage: python3 rebuild_sets.py <dir-with-graph.tsv> [--list SRC]"""
import sys, collections
S = sys.argv[1]
G = collections.defaultdict(list)
for l in open(S + '/graph.tsv'):
    a, b = l.rstrip('\n').split('\t'); G[a].append(b)
F = 'FormalSystem.'; T = F + 'Metalogic.Decidability.Verified.Termination.'
roots = ('FormalSystem', 'BimodalTest', 'BimodalTools', 'BimodalToolsTest')
ours = sorted({m for m in G if m.split('.')[0] in roots} | {r for r in roots if r in G})
memo = {}
def clo(m):
    if m in memo: return memo[m]
    seen = set(); st = [m]
    while st:
        x = st.pop()
        for y in G.get(x, []):
            if y not in seen: seen.add(y); st.append(y)
    memo[m] = seen; return seen
def rdeps(src): return [m for m in ours if src in clo(m)]
term = [m for m in ours if m.startswith(T)]
print('project modules', len(ours), 'termination modules', len(term))
fuel = clo(T + 'Fuel'); allt = set().union(*[clo(m) for m in term])
print('FormalSystem modules in import closure of termination subtree', len([m for m in allt if m.startswith(F) and not m.startswith(T)]))
print('  of which Semantics', len([m for m in allt if m.startswith(F + 'Semantics')]))
print('external modules in closure of Fuel', len([m for m in fuel if m.split('.')[0] not in roots]))
if len(sys.argv) > 3 and sys.argv[2] == '--list':
    for m in rdeps(F + sys.argv[3]): print(m)
    sys.exit(0)
for src in ['ProofSystem.Axioms', 'Semantics', 'Syntax', 'ProofSystem.Derivation', 'Syntax.Context',
            'ProofSystem.Derivable', 'ProofSystem.DerivedAxioms', 'Syntax.Formula', 'Syntax.Subformulas',
            'Syntax.SubformulaClosure.Closure', 'Syntax.SubformulaClosure.NestingDepth',
            'Syntax.SubformulaClosure.TemporalFormulas', 'Semantics.Validity', 'Semantics.Truth', 'Semantics.TaskFrame']:
    r = rdeps(F + src)
    print(f'{src}\t{len(r)}\t{len([m for m in r if m.startswith(T)])}')
