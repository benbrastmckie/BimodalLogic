# Phase 4 Handoff — Superseded-parametric cleanup

- **Task**: 415
- **Session**: sess_1786417819_f9ee53
- **Phase closed**: 4 [COMPLETED]
- **Next eligible**: Phases 5-7 GATED on task 414 (gate re-checked this dispatch: closed);
  Phase 8 GATED on 420 phase 10 (gate re-checked: closed). Dispatch ends at this boundary.

## State at close

- Deleted (all consumer-free after relocation): `Algebraic/ParametricCanonical.lean`,
  `ParametricHistory.lean`, `ParametricTruthLemma.lean`, `ParametricCompleteness.lean`,
  `RestrictedParametricTruthLemma.lean`; plus the orphaned `unboundedZIntervalEquiv`
  (`Transfer.lean`).
- Relocated/re-hosted survivors: `fmcs_box_persistent` (+ private `past_tf_deriv`) now in
  `FlowFrame.lean`; `fc_theorem_true_in_bundle_flow_model` replaces
  `fc_theorem_true_in_parametric_model` in `Bundle/LimitMCS.lean`.
- FlowFrame.lean's imports are now fully parametric-free: `Semantics.TaskFrame`,
  `Semantics.Truth`, `Bundle.TemporalCoherence`, `Syntax.SubformulaClosure.TemporalFormulas`,
  `Theorems.Propositional.Core`.
- Full `lake build` green (2324 jobs); sole live sorry `Transfer.lean:1068`
  (`countermodel_discrete`, line shifted by deletions). Zero mentions of any parametric-stack
  symbol remain in the live tree.

## For Phases 5-7 (when 414 lands)

- Gate check command: `grep -n "IsTotal" FormalSystem/Semantics/Truth.lean
  FormalSystem/Semantics/Validity.lean` must return hits AND `TruthAt` must no longer take an
  `Omega` parameter. Re-run `bash scripts/check-paper-definitions.sh` at dispatch start.
- The Option-A second pass (box-case swap in `bundleFlow_truth_lemma`, Phase 6) replaces
  Omega-destructuring (`obtain ⟨⟨fam', w₀'⟩, rfl⟩ := h_σ_mem`) with totality-destructuring via
  `bundleFlow_total_eq`; `bundleFlowOmega` and its two lemmas then likely retire.
