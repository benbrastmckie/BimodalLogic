# Final 4 Sorries: Deep Analysis and Approaches

## Session
- Session: sess_1778014444_dca927
- Date: 2026-05-06

## Overview

The 4 remaining sorries in the completeness proof are deeply interconnected and require substantial work. This handoff documents the analysis of all approaches considered.

## Sorry 1 & 2: C5/C5' n>=1 (CE:725, CE:839)

### Goal (CE:725 - C5 forward)
```
h_r3m : BurgessR3Maximal (chi.f pc.x) B C
h_eq : not (pc.x = max_old)
goal: BurgessR3Maximal (chi.f max_old) B C
```

### Goal (CE:839 - C5' backward)  
```
h_hc_sub : h_content (chi.f pc.x) subset C
h_eq : not (pc.x = min_old)
goal: exists B_new, BurgessR3Maximal C B_new (chi.f min_old)
```

### Root Cause
The construction places the new point y after ALL domain points (C5) or before ALL (C5'). This creates a new adjacent pair (max_old, y) or (y, min_old). The BurgessR3Maximal (or existence thereof) is needed for f(max_old)/f(min_old), but B/C were constructed using lemma_2_4 for f(pc.x), which differs.

### Why Direct Approaches Fail

1. **g_content propagation**: `g_content(f(pc.x)) subset C` does NOT imply `g_content(f(max_old)) subset C`. G-formulas propagate FORWARD through the c2' chain, so g_content FORWARD of f(pc.x) goes into subsequent f-values, but g_content of f(max_old) involves different G-formulas that may not be in C.

2. **h_content duality**: `g_content(A) subset B` iff `h_content(B) subset A` (for MCS). So we'd need `h_content(C) subset f(max_old)`, but we only have `h_content(C) subset f(pc.x)`. h_content values from C don't propagate forward.

3. **No F-propagation**: We cannot show `F(event) in f(max_old)` from `F(event) in f(pc.x)`. There's no axiom like `F(a) -> G(F(a))` in the system (and it's not semantically valid).

### Correct Approach: Burgess 2.10 Induction

Burgess 2.10 case n=m+1 works by induction on domain points after pc.x:

**Case A: guard not in g(pc.x, x')** where x' = successor of pc.x:
- Apply `lemma_2_7` with A=f(pc.x), B=g(pc.x,x'), C=f(x'), xi=guard, eta=event.
- Requires: `guard not in g(pc.x, x')` (from case split)
- Requires: `SetDeductivelyClosed B` (from `BurgessR3Maximal_sdc`)
- Requires: `g_content(f(pc.x)) subset f(x')` (from `BurgessR3Maximal_g_content_sub`)
- Get: B', D, B'' with BurgessR3Maximal(f(pc.x), B', D), BurgessR3Maximal(D, B'', f(x'))
- Insert z between pc.x and x': f'(z)=D, g'(pc.x,z)=B', g'(z,x')=B''
- event in D gives c5_forward_witness z > pc.x

**Case B: guard in g(pc.x, x') AND untl(guard,event) in f(x')**:
- "Move" to x': counterexample at x' has n-1 domain points after it
- Recurse (well-founded on Finset.card of domain points after pc.x)
- c5_forward_witness from recursion: y > x' > pc.x

**Case C: guard in g AND untl(guard,event) not in g(pc.x, x')**:
- BX5 gives enriched formula: untl(guard AND untl(guard,event), event) in f(pc.x)
- Key fact: guard AND untl(guard,event) not in g (since untl not in g + CUD closure)
- Apply lemma_2_7 with enriched guard
- Same construction as Case A

**Case D: guard in g AND untl(guard,event) in g AND untl(guard,event) not in f(x')**:
- REQUIRES Burgess Lemma 2.8 (not formalized)
- Lemma 2.8 hypothesis: not(event OR (guard AND untl(guard,event))) in f(x')
- This follows from: event not in f(x') (from h_no_wit) + (guard AND untl) not in f(x')
- Formalizing Lemma 2.8 requires ~200 lines (modification of Lemma 2.7 proof)

### Implementation Plan for CE:725/839

1. Add helper lemma `c5_eliminate_with_induction` using well-founded recursion on `(chi.dom.filter (. > pc.x)).card`
2. Handle Cases A, B, C using existing lemma_2_7 + BX5
3. For Case D: either formalize lemma_2_8 or leave targeted sorry
4. Restructure g' definition in `eliminate_potential_counterexample` to use case-split B values
5. Update c2' proof for new adjacent pairs

### Key Dependencies
- `lemma_2_7` (exists, proven in PointInsertion.lean)
- `BurgessR3Maximal_sdc` (exists, proven in CE file)
- `BurgessR3Maximal_g_content_sub` (exists, proven in CE file)  
- `exists_rat_between_not_in_finset` (exists, proven in CE file)
- `lemma_2_8` (NOT exists, needs formalization for Case D)

## Sorry 3 & 4: FUC/FSC (CTC:634, CTC:638)

### Goal (CTC:634 - Forward Until Coherence)
```
h_until : untl(phi, psi) in mcs(t)
goal: exists s1, t < s1 AND psi in mcs(s1) AND forall r, t < r -> r < s1 -> phi in mcs(r)
```

### Goal (CTC:638 - Forward Since Coherence)
Mirror of FUC for Since direction.

### What We Have
- `limit_satisfies_c5_weak`: gives endpoint witness (exists y > t, psi in mcs(y)) -- NO guard
- `limit_c3_interval_subset_point`: g(x,z) subset f(y) for x < y < z -- gives guard IF phi in g(x,y)
- `limit_g` defined as: {phi | forall z in limit_dom, x < z < y -> phi in limit_f(z)}

### What We Need
The guard condition: phi in mcs(r) for all t < r < s1. This is equivalent to phi in limit_g(x_t, x_s1) where x_t, x_s1 are the corresponding limit_dom points.

### Root Cause
The `EliminationResult.c5_forward_witness` field only exposes:
```
exists y in val.dom, pc.x < y AND pc.eta in val.f y
```
It does NOT expose that the guard (pc.xi) is in g(pc.x, y). The guard IS computed during C5 elimination (via lemma_2_4's B set), but DISCARDED from the result type.

### Burgess 2.11 Argument
"If U(xi, eta) in f(x), then by C5a there is y with x < y and xi in f(y) and eta in g(x,y). If z with x < z < y, then by C3, g(x,y) subset f(z), whence eta in f(z)."

This uses TWO things:
1. Full C5 with guard: exists y with event in f(y) AND guard in g(x,y)
2. C3: g(x,y) subset f(z) for intermediate z

We have (2) via limit_c3_interval_subset_point. We need (1).

### Approaches for FUC/FSC

**Approach A: Strengthen EliminationResult** (upstream change)
- Add `c5_forward_guard` field: guard in val.g pc.x y
- This requires proving guard in B (the g-value constructed by lemma_2_4)
- Challenge: B is the maximal CUD set, guard may or may not be in B
- BX5 self-accumulation could help: enriched guard includes untl itself

**Approach B: Prove full C5 at limit directly**
- Prove: untl(phi,psi) in limit_f(x) -> exists y > x, psi in limit_f(y) AND phi in limit_g(x,y)
- By definition of limit_g: phi in limit_f(z) for all z between x and y
- Requires tracking how guard propagates through the omega-chain
- At some stage n, C5 counterexample is eliminated: witness y with psi in f_n(y)
- Need: phi in f_m(z) for all z added between x and y at stages m > n
- This requires: phi in g_n(x, y) (the guard is in the interval value)
- Which requires: the construction puts phi in the g-value

**Approach C: Use BX5 enrichment + C5_weak**
- From untl(phi,psi) in mcs(t): BX5 gives untl(phi AND untl(phi,psi), psi) in mcs(t)
- C5_weak gives: exists y > t with psi in mcs(y)
- At intermediate r: need phi AND untl(phi,psi) in mcs(r)
- This is the full C5 guard condition -- circular!
- Forward_G can propagate G-formulas, but guard phi is not a G-formula

### Recommended Path for FUC/FSC
1. First fix CE:725/839 (ensure guard is in g-value during C5 elimination)
2. Strengthen EliminationResult to expose guard info
3. Thread guard info through omega_chain_c5_witness
4. Prove limit_satisfies_c5_full using the guard info
5. Use limit_c3_interval_subset_point + full C5 to close FUC/FSC

## Dependency Graph
```
lemma_2_8 formalization -----> CE:725/839 closure (Case D)
                                    |
                                    v
    EliminationResult strengthening (guard in result type)
                                    |
                                    v
    omega_chain_c5_witness with guard
                                    |
                                    v  
    limit_satisfies_c5_full (full C5 with guard at limit)
                                    |
                                    v
    CTC:634/638 (FUC/FSC) closure
```

## Estimated Effort
- Cases A/B/C of CE:725 (without Case D): ~400 lines, medium difficulty
- lemma_2_8 formalization (Case D): ~300 lines, high difficulty
- EliminationResult strengthening: ~100 lines, medium difficulty
- limit_satisfies_c5_full: ~150 lines, medium difficulty
- FUC/FSC closure: ~50 lines, low difficulty (once full C5 is available)

Total: ~1000 lines

## File Locations
- CounterexampleElimination.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`
- ChronicleToCountermodel.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
- ChronicleConstruction.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`
- PointInsertion.lean (lemma_2_7): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- ChronicleTypes.lean (definitions): `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`

## Key Insight Summary
All 4 sorries are caused by the same root issue: the C5 elimination discards the guard from its output. The guard (phi/xi) IS computed during elimination (via lemma_2_4 and BurgessR3Maximal), but the EliminationResult type doesn't expose it. The downstream FUC/FSC sorries exist because the limit construction can't prove the guard condition without this information.
