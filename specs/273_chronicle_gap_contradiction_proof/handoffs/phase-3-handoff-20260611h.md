# Phase 3 Handoff: Nested buildRight Formula — Design Resolution

**Task**: 273 | **Session**: sess_1781193902_83bc5c | **Date**: 2026-06-11

## Current State

NegationClosure.lean: 1 sorry at line 427 (unchanged). Plan v20 Phase 3 marked [IN PROGRESS].

No code changes made in this session — the full budget was spent on resolving a deep design issue that previous attempts (plan v19 and handoffs 20260611f/g) identified but did not resolve at the implementation level.

### Sorry Location
- File: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean:427`
- Context: `master_induction`, P2(k+1) backward direction
- Goal: `∃ x, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x fun x => t) sub_nf`
- Given: `h_formula : temporal_truth M atomMap t (nf_exist_formula atomMap h_surj (k + 1) char_kp1 parent_atoms sub_nf)`

### Other Sorries (unchanged)
- NfCharFormula.lean:572 — `nf_2var_exist_formula_prior` (downstream, closes once P2 is sorry-free)
- KampPrior.lean:149 — `nf_characterizable_temporal_prior k+1` (downstream)

## Design Resolution (DEFINITIVE)

### Why the Current Formula Fails

The formula `nf_exist_formula` at depth k+1 encodes:
- Atom compatibility of witness x with sub_nf at variable 0
- Order between x and t (via Until/Since/identity)
- Depth-(k+1) 1-var NF of x (via char_kp1)

It does NOT encode `sub_nf.2` (the quantifier part: NormalForm sig k 3 -> Bool).

The backward direction is UNPROVABLE with this formula because:
- char_kp1(nf_x) at x tells us x has the right 1-var NF
- But the 2-var NF of (x, t) is NOT determined by the 1-var NFs of x and t
- The 2-var NF includes sub_nf.2, which records depth-k 3-var quantifier conditions
- These conditions involve interactions between y, x, AND t simultaneously
- At depth k >= 1, these cross-variable interactions are NOT captured by 1-var NFs alone

### Why Previous Approaches Fail

1. **NF-transfer**: "Same 1-var NF => same existential" is FALSE at depth k >= 1. The existential has quantifier depth k+2, exceeding depth-(k+1) NF agreement (doets_lemma_1_1 preserves truth for quantifier depth <= k+1 only).

2. **P2_gen with all-same-point env**: Defining P2_gen(k, n) with env = (fun _ => t) only handles the case where all n parent variables equal t. For n > 1 with distinct parent points (e.g., the 3-var condition with parents = (x, t)), order atoms between parents are all false with (fun _ => t), which doesn't match the actual env = (x, t) where order(x, t) may be true.

3. **Standalone sub-formulas for inner conditions**: The 3-var condition involves x (a quantified variable from the outer Until), which is not accessible from a standalone formula evaluated at t. The inner condition MUST be part of the outer formula structure.

### The Correct Design: Nested buildRight

The formula for P2(k+1) must be a SINGLE formula at t that INTERNALLY nests k+1 levels of buildRight/buildLeft.

**Formula structure (Until case, t < x)**:

The formula uses `buildRight` to place witnesses in order t < y_1 < y_2 < ... < y_m < x, where:
- Each y_i is characterized by `char_k(nf_{y_i})`
- x is characterized by `char_{kp1}(nf_x)`
- Guards between consecutive witnesses encode negative conditions (no forbidden types)
- Event formulas at each witness include DEEPER nesting for quantifier conditions

**Nesting levels**:
- Level 0: places x via buildRight from t, using char_{k+1}(nf_x)
- Level 1: places y's in (t, x) via nested buildRight/Since from within level 0's event, using char_k(nf_y)
- Level 2: places z's in sub-intervals via nested buildRight/Since from within level 1's events, using char_{k-1}(nf_z)
- ...
- Level k: places bottom-level witnesses using char_1 or char_0 (atoms only at depth 0)

At depth 0 (the base of recursion), the NF conditions are atoms only, fully determined by 1-var NFs + positions. No further nesting needed.

**Formula definition** (recursive on k):

```
nf_exist_formula_nested(k, sub_nf, chars, parent_atoms) :=
  case k = 0: nf_exist_formula (existing, works at depth 0)
  case k+1:
    disjunction over compatible (nf_x, witness_configs) of:
      buildRight [
        ... (interval witness placements from sub_nf.2 conditions)
        (char_{k+1}(nf_x) AND nested_event_conditions, guard_x)
      ] guard_right
```

where `witness_configs` enumerates all valid orderings and typings of interval witnesses, and `nested_event_conditions` at each witness recursively apply the same construction at depth k-1.

**Forward direction** (existential -> formula):
Given the existential, extract x and all interval witnesses y_1, ..., y_m. Determine their 1-var NFs and positions. The buildRight chain for the matching configuration is satisfied (by buildRight_correct). The nested conditions are satisfied recursively.

**Backward direction** (formula -> existential):
From the buildRight truth, extract witnesses x, y_1, ..., y_m (by buildRight_correct). Their 1-var NFs are determined by char formulas (by char_correct). Their positions are determined by the buildRight structure. At depth 0, the multi-var NF is fully determined by 1-var NFs + positions (atoms only). At depth k > 0, the multi-var NF is determined by the nested conditions (induction on nesting level).

### Import Restructuring Needed

1. Remove `import Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` from NegationClosure.lean (KampPrior is not used in code, only in comments)
2. Add `import Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosure` to KampPrior.lean
3. Fill `nf_characterizable_temporal_prior` (KampPrior.lean:149) using master_induction from NegationClosure
4. For NfCharFormula.lean:572: either delete (unused externally) or leave sorry (off critical path)

## Immediate Next Action

**Phase 3: Define `nf_exist_formula_nested`**

1. Define a recursive function `nf_exist_formula_nested` that builds the k+1-level nested formula, by recursion on k:
   - Base (k = 0): use the existing `nf_exist_formula` (atoms only, backward already proved by backward_depth0)
   - Step (k+1): build buildRight chain placing x and interval witnesses, with nested conditions

2. Replace line 423 in master_induction: change from `nf_exist_formula` to `nf_exist_formula_nested`

3. Prove the forward direction: adapt `nf_exist_formula_forward'` to the nested formula

4. Prove the backward direction: induction on nesting level, using buildRight_correct at each level

**Estimated effort**: ~400 lines of new Lean code (formula definition ~100, forward ~100, backward ~200)

## Key Available Infrastructure

- `buildRight_correct` (Translation.lean): semantic correctness of buildRight chains
- `buildLeft_correct` (Translation.lean): symmetric for Since chains
- `char_k_correct` (from P1(k) IH): depth-k 1-var NF characterization on Prior structures
- `char_kp1_correct` (from P1(k+1)): depth-(k+1) 1-var NF characterization
- `p2_k` (from P2(k) IH): depth-k 2-var existential formulas
- `h_UZ`, `h_SZ` (Prior axioms): first/last occurrence properties
- `nf_characteristic_satisfies`: every point satisfies its characteristic NF
- `nf_eval_unique`: NF uniqueness
- `Fintype` instances for all NF types (for finite enumeration)
- `TemporalPred` wrapper for formulas in buildRight

## File Inventory (unchanged)

| File | Sorries |
|------|---------|
| Kamp/NegationClosure.lean | 1 (k+1 backward, line 427) |
| Kamp/NfCharFormula.lean | 1 (nf_2var_exist_formula_prior) |
| Kamp/KampPrior.lean | 1 (nf_characterizable_temporal_prior k+1) |
| All others | 0 |
