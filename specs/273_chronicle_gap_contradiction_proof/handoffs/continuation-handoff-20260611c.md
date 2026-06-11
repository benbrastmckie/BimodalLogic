# Continuation Handoff: Rabinovich Pipeline (Plan v18) -- Phase 3 Analysis

**Task**: 273 | **Status**: PARTIAL (Phases 1-2 complete, Phase 3 blocked)
**Session**: sess_1781193902_83bc5c | **Date**: 2026-06-11

## Progress This Session

### Phase 3 Incremental Progress
- Added `nf_exist_formula_forward'`: M-specific version of `nf_exist_formula_forward` that accepts Prior-dependent char_k_correct. Proved sorry-free.
- Deleted unused sorry'd lemmas `nf_char_formula_of_nf_eval` and `nf_eval_of_nf_char_formula` (both require the backward direction; replaced with explanatory doc comment).
- Sorry count in NfCharFormula.lean: 4 -> 1 (only `nf_2var_exist_formula_prior` remains).
- Sorry count in KampPrior.lean: 1 (unchanged, line 149).
- Build passes (Kamp pipeline; CanonicalTaskRelation.lean has pre-existing simp failures).

## The Single Remaining Mathematical Challenge

### Statement: `nf_2var_exist_formula_prior`
```lean
theorem nf_2var_exist_formula_prior
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p, ∃ a, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → Formula)
    (char_k_correct : ∀ nf_k M h_UZ h_SZ t,
        temporal_truth M atomMap t (char_k nf_k) ↔ nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ A, ∀ M h_UZ h_SZ t,
      (∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
      (temporal_truth M atomMap t A ↔ ∃ x, nf_eval_nf M k (1+1) (Fin.cons x (fun _ => t)) sub_nf)
```

### Why It Is Hard (Detailed Analysis)

The natural candidate formula is `nf_exist_formula` (Until/Since over depth-k char formulas with top guard). The FORWARD direction (existential -> formula) is proved by `nf_exist_formula_forward'`.

The BACKWARD direction (formula -> existential) asks: if `Until witness_type top` holds at t, then `exists x, nf_eval_nf M k 2 ...`. The Until formula gives x > t with some depth-k 1-var char formula `char_k nf_x` holding at x. But:

**The 1-var depth-k NF of x does NOT determine the 2-var depth-k NF of (x, t).**

The 2-var NF includes quantifier data about 3-variable NFs (involving y, x, t), which depend on the model's structure between x and t. On general linear orders, the backward direction is FALSE (documented: StaviCompleteness.lean, sorry site 3).

On Prior structures, the backward direction IS provable because the Prior-UZ/SZ axioms (attained first/last occurrences) constrain interval properties enough to determine the 2-var NF from boundary data. But proving this requires one of:

1. **Rabinovich's negation closure** (Lemma 5.1): shows VEF is closed under negation using HasDefinableINF/HasDefinableSUP. This is the approach from the original plan (Phases 3-4).

2. **Composition theorem for Prior structures**: directly shows the 2-var NF is determined by 1-var NFs + order + interval type, where Prior axioms determine the interval type.

3. **Strengthened formula**: replace `top` guard with `interval_guard` (disjunction of all char_k) and prove the backward direction using the interval type data. This is the StaviCompleteness approach (`nf_exist_sf_guarded`), but the backward direction is ALSO sorry'd there.

All three approaches require 600-1000 lines of new proof infrastructure implementing the core Rabinovich case analysis (3 cases per pp. 9-11):
- Case 1: endpoint failure
- Case 2: guard succeeds, no witness (interval type extends throughout)
- Case 3: splitting at definable infimum point (uses HasDefinableINF/HasDefinableSUP)

### Approaches That Were Tried and Why They Failed

1. **Using nf_exist_formula with top guard**: Forward direction works, backward fails at k > 0 because 1-var NF doesn't determine 2-var NF.

2. **Classical choice via doets_lemma_1_1**: The existential has depth k+1, but we only have depth-k temporal characterizations. The depth-(k+1) characterization is circular (it's what we're building).

3. **Uniqueness argument**: The negative quantifier conditions (quant=false) rule out some NFs via contraposition, but the positive conditions (quant=true) are underdetermined without the backward direction.

4. **Structural induction on MonadicFormula**: Requires handling existential at all arities, which reduces to the VEF closure / negation closure.

5. **Inner k-induction inside nf_2var_exist_formula_prior**: At depth k=0, backward direction is trivial. At depth k+1, the quantifier part involves arity-3 NFs that can't be reduced without the composition theorem.

### Why the k=0 Case Alone Is Insufficient

The original sorry at KampPrior.lean:149 is for `succ k ih` which covers ALL k >= 0. `nf_characterizable_temporal_prior_classical` needs `nf_2var_exist_formula_prior` at depth k (the depth of the sub_nf). The full pipeline needs it for all k.

## Recommended Approach for Next Session

**Implement the Rabinovich negation closure (Lemma 5.1) for Prior structures**, using the simplified version where first/last occurrences are ATTAINED (the K+ disjunct is vacuous). This gives a proof of `nf_2var_exist_formula_prior` via:

1. Show every `MonadicFormula sig n` is VEF-equivalent on Prior structures (structural induction using negation closure)
2. In particular, `.ex (nf_to_formula sub_nf)` has a VEF equivalent
3. VEF at arity 1 translates to temporal formulas (Phase 1 infrastructure: translateEF1/translateVEF1)
4. This gives the classical existence of A

This requires:
- VEF closure under conjunction (merge witness sequences) -- currently skipped
- VEF closure under existential quantification (project out one variable) -- currently skipped
- VEF negation closure using HasDefinableINF/HasDefinableSUP -- the core content

Estimated: 600-1000 lines total for VEF conjunction + existential + negation closure.

**Alternative**: prove the composition theorem for Prior structures directly (2-var NF determined by 1-var NFs + order on Prior). This avoids the VEF machinery but requires similar case analysis.

## File Inventory

| File | Status | Sorries |
|------|--------|---------|
| Kamp/Translation.lean | Sorry-free | 0 |
| Kamp/PriorINF.lean | Sorry-free | 0 |
| Kamp/ExistsForallNF.lean | Clean | 0 |
| Kamp/NfCharFormula.lean | 1 sorry (nf_2var_exist_formula_prior) | 1 |
| Kamp/KampPrior.lean | 1 sorry (nf_characterizable_temporal_prior k+1) | 1 |

## Build Status

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds
- Pre-existing build failures in CanonicalTaskRelation.lean (unrelated)
- `nf_exist_formula_forward'` verified no sorryAx

## Immediate Next Action

1. Implement VEF closure under conjunction (`VEF.closed_conj`)
2. Implement VEF closure under existential quantification (`VEF.closed_ex`)
3. Implement Rabinovich Lemma 5.3 (base negation closure, all beta_i = True)
4. Implement Rabinovich Lemma 5.1 (full negation closure) -- the core, 3 cases
5. Derive `nf_2var_exist_formula_prior` from the negation closure + VEF-to-temporal translation
6. Fill KampPrior.lean:149 via `nf_characterizable_temporal_prior_classical`
