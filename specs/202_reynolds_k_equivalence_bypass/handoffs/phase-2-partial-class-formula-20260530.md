# Phase 2 Partial Handoff: class_temporal_formula sorry

**Date**: 2026-05-30
**Session**: sess_1780151044_orch202r3
**Phase**: 2 (Reynolds Model Surgery Core)
**Status**: PARTIAL

## What was accomplished

`reynolds_model_surgery_core` (GoodStructuresModelSurgery.lean) is now PROVEN
(zero sorry in the theorem body), using a clean 40-line proof that delegates
to a single helper lemma `class_temporal_formula`.

### Proof structure of reynolds_model_surgery_core

1. Obtain temporal formula R from `class_temporal_formula` with:
   `temporal_truth M atomMap t R ↔ contemp_equiv sig k M a t`

2. R holds at a (by contemp_equiv reflexivity)

3. For y >= a: if R fails at y, Prior-UZ gives first transition at (c, succ(c)).
   R at c means c in class(a); h_succ_closed gives succ(c) in class(a);
   R at succ(c). Contradiction with not R at succ(c).

4. For y < a: symmetric using Prior-SZ and contemp_equiv_pred_closed.

5. So R holds everywhere, meaning all points are in class(a).

### Downstream impact

- `gap_contradicts_prior`: sorry-free (calls reynolds_model_surgery_core)
- `gap_contradicts_prior_below`: sorry-free (calls reynolds_model_surgery_core)
- `no_gaps_discrete_model_surgery`: sorry-free (calls the above two)
- ALL transitively depend on class_temporal_formula (one sorry)

## Remaining sorry

### class_temporal_formula (GoodStructuresModelSurgery.lean:527-538)

```lean
private noncomputable def class_temporal_formula
    {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a : M.carrier) :
    { R : Formula //
      ∀ t : M.carrier,
        temporal_truth M atomMap t R ↔ contemp_equiv sig k M a t } := by
  sorry
```

### Why this is hard

The challenge is encoding `contemp_equiv sig k M a t` as `eval M (fun _ => t) psi`
for some `MonadicFormula sig 1 psi`, then applying `US_expressively_complete_over_prior`.

The fundamental difficulty: `contemp_equiv sig k M a t` depends on the specific
element `a`, but `MonadicFormula sig 1` has only one free variable (for `t`) and
cannot reference specific carrier elements.

### Approaches analyzed

1. **Direct MonadicFormula construction**: Express contemp_equiv using quantifiers
   over subintervals, k-type checks (via NormalForm Fintype), and order constraints.
   Issue: need to reference `a` without a named constant. ~200 lines.

2. **Extended signature approach**: Add predicate `is_a` (true only at a), extend
   signature and atomMap, verify Prior-UZ/SZ for extended structure, construct
   MonadicFormula in extended language. Issue: verifying Prior-UZ/SZ for extended
   structure is non-trivial (~100 lines).

3. **Non-constructive existence**: Argue that the formula exists by expressive
   completeness (the set class(a) IS definable in monadic FO with parameter a,
   hence temporally definable on Prior structures). Issue: need Lean proof of
   existence, not just mathematical argument.

### Recommended next steps

The **extended signature approach** (option 2) is most likely to succeed:
1. Define `sig' := sig with one extra predicate`
2. Define `M' := M with is_a predicate` (interp is_a t = (t = a))
3. Define `atomMap' := atomMap extended with fresh atom for is_a`
4. Prove `h_surj'` for atomMap' (add one fresh atom via Atom.fresh_for)
5. Prove Prior-UZ/SZ for M' with atomMap' (~50-100 lines, key challenge)
6. Construct `MonadicFormula sig' 1` expressing `contemp_equiv(the_is_a_point, t)`
   (~100 lines, encoding very_good as finite disjunction of k-type patterns)
7. Apply `US_expressively_complete_over_prior` on sig', M', atomMap'
8. Show the resulting temporal Formula works on the original M

Estimated effort: 200-400 lines, 6-10 hours.

## Files modified

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
  - `class_temporal_formula`: NEW, sorry'd (~20 lines including signature)
  - `reynolds_model_surgery_core`: REWRITTEN, sorry-free (~40 lines)
  - Module docstring updated to reflect new proof structure

## Immediate next action

Close `class_temporal_formula` using the extended signature approach, OR attempt
the direct MonadicFormula construction.
