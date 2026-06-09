# Phase 1 Handoff: Plan v13 Blocker Analysis

**Task**: 273 — Generalized Existential Transfer via 2-var Interval Types
**Plan**: v13 (plans/13_generalized-transfer-plan.md)
**Phase**: 1 (2-var Zone Matching Infrastructure) — BLOCKED
**Session**: sess_1781031097_68830a
**Timestamp**: 2026-06-09

## Current State

Phase 1 is blocked at the fundamental proof structure level. The plan v13 approach of strengthening hypotheses from `interval_nf_types` to `interval_2var_nf_types` is NECESSARY but INSUFFICIENT. The core issue is an arity-growth problem in the quantifier component.

### Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`: Added `atom_agree_from_pointwise` helper theorem (lines ~2213-2238). This helper proves atom agreement at arbitrary arity n from pairwise 1-var NF agreement and ordering agreement. It will be needed by any future implementation.

### Root Cause Analysis

The sorry sites at lines 2353 and 2435 in `nf_2var_existential_transfer` need:
```
(∃ w, nf_eval M' j' 4 (w :: u' :: x' :: t') sub_nf) ↔
(∃ w, nf_eval M j' 4 (w :: u :: x :: t) sub_nf)
```

This is 4-var existential transfer at depth j' for the 3-point config (u,x,t)/(u',x',t').

**The Arity Growth Problem**: To prove 4-var transfer at depth j', one needs:
1. Zone-match the new point w to w' (needs interval data for sub-intervals)
2. Show atoms agree at 4 vars (from zone matching)
3. Show quant agrees: 5-var transfer at depth j'-1 for (w,u,x,t)/(w',u',x',t')

Step 3 recurses: 5-var transfer at depth j'-1 requires 6-var transfer at depth j'-2, etc. After j' steps, one reaches depth 0 where atoms at arity 3+j'+1 suffice. This recursion is well-founded because depth strictly decreases.

**Why Plan v13 Is Insufficient**: The plan proposes adding infrastructure for 2-var zone matching (Tasks 1.1-1.4) and then modifying the existential transfer to use 2-var interval types (Tasks 2.1-2.3). However:

- Task 1.3 (sub-interval transfer from 2-var NF) gives 3-var transfer for pairs, not 4-var transfer for triples.
- Task 1.4 (sub-interval 2-var type agreement from 2-var NF) gives sub-interval data at depth K-1, not depth K.
- The quant step in Task 2.2 requires the arity-parametric argument, which the plan doesn't provide.

### What GHR93 Actually Does (Proposition 7)

GHR93 Proposition 7 proves the result by induction on n (game rounds = depth j in our terms), with the number of points m being a FREE VARIABLE that grows at each step. The key features:

1. **Arity is universally quantified**: The statement is "for all m-tuples with interval strategies, Duplicator wins the n-round game." The IH at round n-1 applies to (m+1)-tuples.

2. **Sub-interval strategies come from decomposition formula matching** (Lemma 11): When zone-matching a new point, the 2-var NF (= decomposition formula) of (new_point, endpoint) provides the sub-interval game strategies. These strategies are at one LOWER game depth.

3. **Depth budget decreases**: The functions f(n) and g(n) grow with n, ensuring sufficient depth at each step. In NF terms: the hypothesis depth K decreases by some amount at each step, but remains ≥ j.

### Correct Implementation Path (Plan v14 Requirements)

A correct implementation requires:

1. **Matched Configuration Predicate**: Define `IsMatchedConfig` parametric in n (arity), K (data depth), with:
   - ∀ i : Fin n, 1-var NF agreement at depth K
   - ∀ i j : Fin n, ordering agreement
   - For each pair of "adjacent" points (in sorted order): interval_nf_types at depth K agree

2. **Zone Matching Preserves Matching**: Prove that zone-matching w in interval (x_i, x_{i+1}) of a matched n-config produces:
   - w' with same 1-var NF at depth K
   - Same orderings relative to all n points
   - The (n+1)-config (with w inserted) is matched at depth K-1 (sub-interval data from 2-var NF)

3. **Main Theorem by Nat.strongRecOn on j**: For all n and matched n-configs at depth K ≥ j, the (n+1)-var transfer holds at depth j. Base j=0 uses atoms. Step j+1 uses zone matching + IH at depth j for arity n+1.

4. **Corollaries**: Derive `nf_2var_existential_transfer` (n=2) and `nf_2var_from_interval_data` (via nf_fraisse_compression) as special cases.

### Estimated Effort

The correct implementation requires approximately:
- 50-80 lines: Matched configuration predicate and basic properties
- 100-150 lines: Zone matching preserves matching (including sub-interval data derivation)
- 80-120 lines: Main arity-parametric transfer theorem (the actual induction)
- 30-50 lines: Corollary derivations

Total: ~260-400 new lines, plus modifications to existing theorems (~50 lines).

### Key Decisions

1. The zone matching data format: `interval_nf_types` (1-var) vs `interval_2var_nf_types` (2-var) at each sub-interval. The 2-var version is richer and enables the depth-decrease argument.

2. The depth-decrease mechanism: At each zone-matching step, the available data depth decreases by 1 (K → K-1). This is sufficient because j also decreases by 1 at each step (j → j-1), and the invariant K ≥ j is maintained.

3. The sorted-order formulation: The "adjacent pairs" in the matched config depend on the ordering, which requires sorting the n points. This can be handled by quantifying over all pairs (i, j) with env_M i < env_M j and no point between them.

### Immediate Next Action

Create plan v14 that implements the arity-parametric approach. The plan should follow GHR93 Proposition 7 exactly, with each step mapped to a specific lemma/theorem in Lean.
