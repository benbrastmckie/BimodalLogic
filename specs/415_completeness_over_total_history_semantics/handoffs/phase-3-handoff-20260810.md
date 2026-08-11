# Phase 3 Handoff — Dense truth-lemma re-host (420-UNBLOCKING MILESTONE: DISCHARGED)

- **Task**: 415
- **Session**: sess_1786417819_f9ee53
- **Phase closed**: 3 [COMPLETED] (atomic-batch, one commit)
- **Next action**: Phase 4 — superseded-parametric cleanup

## MILESTONE: task 420 phase 10's gate is discharged

`bundleFlowFrame` is live on all dense/Dedekind countermodel paths and
`ParametricCanonicalTaskFrame` survives only inside the superseded `Algebraic/Parametric*`
modules (Phase 4 deletes them). 420 phase 10 can now populate the new `TaskFrame` fields by
`exact` from `multiFamGen_comp_iff`/`_serial`/`_limit`/`_spherical` (generic) or their
`bundleFlow_*` specializations; the Coordination Contract carrier is
`{fam // fam ∈ B.families} × D` with `pos = Prod.snd` (`bundleFlow_pos_shift`).

## State at close

- `FlowFrame.lean` now hosts: the generic `multiFamTaskFrameGen`/`multiFamHistoryGen`/
  `multiFamOmegaGen` (+ shift_eq/shiftClosed/mem_omega) — MOVED from
  `ChronicleMonadicBridge.lean` (namespace changed `BXCanonical.Chronicle` → `Algebraic`;
  proofs verbatim; import direction inverted to break the cycle blocking
  ChronicleToCountermodelBasic from importing the truth lemma) — plus `bundleFlowOmega` (+
  shiftClosed/mem), the private imp-case tautologies, `bundleFlow_truth_lemma`, and
  `bundleFlow_completeness_from_neg_membership`.
- Truth-lemma statement shape: `φ ∈ fam.val.mcs (w₀ + t) ↔ TruthAt (bundleFlowModel B)
  (bundleFlowOmega B) (bundleFlowHistory fam w₀) t φ` with `fam` a bundle-subtype element;
  induction generalizes `fam w₀ t`; temporal cases translate the clock by `± w₀`
  (`lt_sub_iff_add_lt'`, `sub_lt_iff_lt_add'`, `add_lt_add_iff_left`); box case needs NO
  timeShift machinery.
- Re-pointed: `Completeness.lean` (`countermodel_dense_enriched`),
  `ChronicleToCountermodelBasic.lean` (`countermodel_dense`),
  `CompletenessDedekind.lean` (CarrierProbe: 3 probes + engine probe; `open ...Algebraic in`
  added to `countermodel_dedekind_dense` which consumes the moved generic names).
- Full `lake build` green (2334 jobs); sorry count exactly 1 (`Transfer.lean:1094`).

## Phase 4 pre-read

- Candidates: `ParametricCanonical.lean`, `ParametricHistory.lean`, `ParametricTruthLemma.lean`,
  `ParametricCompleteness.lean` — delete only zero-consumer modules per the pre-edit gate.
- NOTE: `parametric_box_persistent` (in `ParametricTruthLemma.lean`) is now consumed by
  `FlowFrame.lean`'s truth lemma — that lemma (or its module) must SURVIVE or be relocated.
- Also orphaned earlier: `unboundedZIntervalEquiv` (`Transfer.lean:544`), consumer-free since
  the Phase 2 device deletion — sweep it here.
