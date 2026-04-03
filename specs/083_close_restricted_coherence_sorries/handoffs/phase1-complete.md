# Handoff: Phase 1 Complete

## What Was Done

Phase 1 (Formula Type Extension) is complete. Two new constructors `untl` (Until) and `snce` (Since)
have been added to the `Formula` inductive type, and all pattern matches across the entire codebase
(63+ files) have been updated to compile cleanly.

### Key Naming Decision

The constructors are named `untl` and `snce` (not `until` and `since`) because `until` is a reserved
keyword in Lean 4 (used in `repeat ... until ...` syntax).

### Files Modified in Phase 1

Core syntax:
- `Theories/Bimodal/Syntax/Formula.lean` -- New constructors, updated complexity/modalDepth/temporalDepth/countImplications/swap_temporal/atoms/needsPositiveHypotheses/beq_refl/eq_of_beq
- `Theories/Bimodal/Syntax/Subformulas.lean` -- New cases for subformulas, membership theorems
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- New cases for subst, fresh_eq, swap_temporal_subst

Semantics:
- `Theories/Bimodal/Semantics/Truth.lean` -- New truth_at cases (Until: exists witness, Since: exists past witness), truth_double_shift_cancel cases, time_shift_preserves_truth cases (sorry)

Metalogic:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- truth_at_swap_swap cases
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- Sorry cases for both truth lemmas
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- Sorry cases for three truth lemmas
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` -- Subformulas, subformulas_trans, unexpandedComplexity

Automation:
- `Theories/Bimodal/Automation/SuccessPatterns.lean` -- GoalCategory + goalCategory

### New Sorries Introduced (12 total, all in truth lemma proofs)

| File | Count | Description |
|------|-------|-------------|
| Truth.lean | 2 | time_shift_preserves_truth for untl/snce |
| ParametricTruthLemma.lean | 4 | Two truth lemma proofs x 2 constructors |
| CanonicalConstruction.lean | 6 | Three truth lemma proofs x 2 constructors |

These are all in the "truth lemma backward direction" where we need to show that truth in the canonical model implies MCS membership. For Until/Since, this requires the dovetailed chain construction (Phase 6) and completeness rewiring (Phase 7).

## What Remains

Phases 2-7 of the plan at `specs/083_close_restricted_coherence_sorries/plans/06_restricted-coherence.md`.

### Phase 2: SubformulaClosure and DeferralClosure Extension
- Update `Theories/Bimodal/Syntax/SubformulaClosure.lean` for untl/snce
- Update deferralClosure to handle Until/Since deferral patterns
- Update finiteness theorems

### Phase 3: Axioms and Proof System
- Add 10 new axiom constructors to `Theories/Bimodal/ProofSystem/Axioms.lean`:
  - until_unfold, until_intro, until_induction, until_linearity
  - since_unfold, since_intro, since_induction, since_linearity
  - until_connectedness, since_connectedness
- Update frameClass, isDenseCompatible, isDiscreteCompatible, isBase
- Update axiom_subst in Substitution.lean

### Phase 4: Semantics Extension
- Close the 2 sorry in Truth.lean (time_shift_preserves_truth for untl/snce)
- Prove soundness of all 10 new axioms in Soundness.lean
- Update SoundnessLemmas.lean with swap validity for new axioms

### Phase 5: Temporal Content and Succ Relation
- Add u_content/s_content to TemporalContent.lean
- Add u_step/s_step to SuccRelation.lean
- Update successor existence proofs

### Phase 6: Dovetailed Chain Construction
- Extend DovetailedChain.lean with Until/Since fair scheduling
- Prove dovetailed_forward_U using U-Induction

### Phase 7: Completeness Rewiring
- Close the 12 new sorry in truth lemma proofs
- Close the 2 original sorry (succ_chain_restricted_forward_F/backward_P)
- Wire dovetailed chain into completeness path

## Build Status

`lake build` passes with 0 errors. All sorry are tracked above.
