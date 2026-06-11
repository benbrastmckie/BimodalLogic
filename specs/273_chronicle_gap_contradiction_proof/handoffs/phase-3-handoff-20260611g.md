# Phase 3 Handoff: Deep Analysis of Interval Formula Requirements

**Task**: 273 | **Session**: sess_1781193902_83bc5c | **Date**: 2026-06-11

## Current State

NegationClosure.lean: 1 sorry at line 447. Plan v19 Phase 3 marked [BLOCKED].

### Sorry Location
- File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean:447`
- Context: `master_induction`, P2(k+1) backward direction
- Goal: `∃ x, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x fun x => t) sub_nf`
- Given: `h_formula : temporal_truth M atomMap t (nf_exist_formula atomMap h_surj (k + 1) char_kp1 parent_atoms sub_nf)`

### Other Sorries (unchanged)
- NfCharFormula.lean:572 -- `nf_2var_exist_formula_prior` (downstream, closes once P2 is sorry-free)
- KampPrior.lean:149 -- `nf_characterizable_temporal_prior k+1` (downstream)

## Root Cause Analysis (Definitive -- confirmed by exhaustive analysis)

### The Problem
`nf_exist_formula` at depth k+1 encodes:
- Atom compatibility of witness x with sub_nf at variable 0
- Order between x and t (via Until/Since/identity)
- Depth-(k+1) arity-1 NF characterization of x (via char_kp1)

It does NOT encode `sub_nf.2` (the quantifier part: NF(k, 3) -> Bool).

The backward direction is UNPROVABLE with this formula because the formula truth guarantees x has the right atoms and the right 1-var NF, but the 2-var NF of (x, t) might differ from sub_nf in its quantifier part.

### Three Failed Alternative Approaches

1. **NF-transfer (good_forall)**: Define good(nf_t) = "for ALL Prior models where t has NF nf_t, the existential holds." Backward trivially works. But forward requires showing nf_t is good, which IS NF-transfer. NF-transfer fails because the 2-var existential has monadic FO depth k+2, exceeding the depth-(k+1) NF agreement provided by doets_lemma_1_1.

2. **Classical existence (good_exists)**: Define good(nf_t) = "SOME Prior model witnesses the existential at NF nf_t." Forward is trivial (current model witnesses). Backward gives a DIFFERENT model M' with the existential; need to transfer to current model M. This requires NF-transfer, which fails.

3. **P2_n arity generalization**: The quantifier conditions in sub_nf.2 are 3-variable existentials at depth k. P2(k) handles 2-variable existentials but NOT 3-variable. Generalizing P2 to arity n > 2 parent variables encounters a fundamental issue: temporal formulas are evaluated at a SINGLE point, so a formula for n > 1 parent variables cannot directly "see" the other parent points. The plan's P2_gen type signature is problematic.

### Why NF-Transfer Fails (mathematical proof)

At depth k >= 1, two points t and t' with the same depth-(k+1) 1-var NF can disagree on the property "exists x with depth-(k+1) 2-var NF (x, t) = sub_nf":

- nf_t.2 records which depth-k 2-var NFs are realized at t. Both t and t' realize the same depth-k 2-var patterns.
- But sub_nf requires depth-(k+1) 2-var conditions, which include depth-k 3-var quantifier conditions (sub_nf.2 : NF(k, 3) -> Bool).
- The depth-k 3-var NF of (y, x, t) involves interactions between all three variables that are NOT determined by the depth-k 2-var NFs of (y, t), (y, x), (x, t) individually.
- Specifically, at depth k >= 1, the depth-k 3-var NF includes a quantifier part NF(k-1, 4) -> Bool involving a 4th variable z. The condition "exists z in (t, y) with certain properties" depends on the model structure in the interval (t, y), which is NOT determined by the pairwise 2-var NFs.

Concrete counterexample at depth 1: Consider a Prior structure M with t < x. The depth-1 1-var NF of x says "exists y < x with depth-0 1-var NF tau." The depth-1 1-var NF of t says "exists y > t with type tau." But "exists y in (t, x) with type tau" is NOT determined by these facts -- all type-tau points below x could be <= t, and all type-tau points above t could be >= x.

## The Correct Approach

Replace `nf_exist_formula` with a nested buildRight formula that encodes sub_nf.2 using k+1 levels of Until/Since nesting.

### Formula Structure (k+1 nesting levels)

For the Until case (t < x):

**Level 0**: Until to find main witness x
- Event: char_{k+1}(nf_x) AND [at-x non-interval conditions] AND [interval conditions]
- Guard: top (or forbidden-type guards)

**Level 1**: Nested buildRight for interval witnesses y in (t, x)
- For each ssn : NF(k, 3) with sub_nf.2(ssn) = true and y in (t, x):
  - Place y with char_k(nf_y) as event
  - Include nested conditions for the depth-k 3-var NF of (y, x, t)

**Level 2**: Nested buildRight for z-witnesses in sub-intervals
- For each depth-(k-1) 4-var NF pattern:
  - Place z with char_{k-1}(nf_z)

**...**

**Level k**: Nested buildRight for bottom-level witnesses
- char_0 formulas (just predicates)
- At depth 0: n-var NFs are atoms, determined by predicates + positions

### Why This Works

At each level j (for j = 0, 1, ..., k):
- Witnesses are characterized by char_{k+1-j} formulas (depth k+1-j, arity 1)
- Position of each witness is determined by the buildRight structure
- At level k (depth 0): the (k+2)-var NF is determined by predicates + positions (atoms only, no quantifier conditions)
- Building up: at level j, the (k+2-j)-var NF at depth j is determined by:
  - The witness's depth-j 1-var NF (from char_j)
  - The witness's position (from buildRight)
  - The conditions on deeper witnesses (recursively guaranteed by levels j+1..k)
- This argument works by INDUCTION on the nesting level (k to 0)

### What is Available from the IH

- `p1_k : P1 atomMap k` -- depth-k 1-var NF characterization
- `p2_k : P2 atomMap k` -- depth-k 2-var existential formulas
- `p1_kp1 : P1 atomMap (k+1)` -- depth-(k+1) 1-var NF characterization (built from P1(k) + P2(k) via nf_char_kp1_from_2var)
- `char_k`, `char_kp1` -- the temporal characterization formulas
- `h_UZ`, `h_SZ` -- Prior axioms (for backward direction at each level)
- `buildRight_correct`, `buildLeft_correct` -- from Translation.lean (for correctness of Until/Since chains)

### Implementation Estimate

- Recursive formula definition: ~100 lines
- Forward direction (existential -> formula): ~100 lines (straightforward: extract witnesses, show chains hold)
- Backward direction (formula -> existential): ~200 lines (extract witnesses from chains, Prior-UZ at each level, recursive NF argument)
- Integration (wiring into master_induction): ~50 lines
- Total: ~450 lines

### Key Simplification for Prior Structures

On Prior structures, first occurrences are ATTAINED (Prior-UZ/SZ). This eliminates the K+ disjunct from Rabinovich's INF formula. Each interval witness placement via Until gives an ACTUAL point (not a limit point), which simplifies the backward direction argument.

## Immediate Next Action

Implement the nested buildRight formula for P2(k+1):

1. Define a recursive function `nf_exist_formula_nested k sub_nf char_functions` that builds the k+1-level nested Until/Since formula encoding the full sub_nf (atoms + quantifier part)
2. Prove forward direction: existential -> formula truth (by extracting witnesses at each level)
3. Prove backward direction: formula truth -> existential (by extracting witnesses from chains, using Prior-UZ/SZ at each level, and the recursive NF determination argument)
4. Wire into master_induction replacing the current nf_exist_formula

## File Inventory

| File | Sorries |
|------|---------|
| Kamp/NegationClosure.lean | 1 (k+1 backward, line 447) |
| Kamp/NfCharFormula.lean | 1 (nf_2var_exist_formula_prior) |
| Kamp/KampPrior.lean | 1 (nf_characterizable_temporal_prior k+1) |
| All others | 0 |
