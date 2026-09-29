# Implementation Summary: Task #696

- **Task**: 696 - stability_modal_substrate_design
- **Status**: [COMPLETED]
- **Started**: 2026-09-29T04:30:00Z
- **Completed**: 2026-09-29T10:40:00Z
- **Effort**: ~6 hours across two dispatches (phases 1-5 in dispatch 6, phases 6-12 in dispatch 7)
- **Dependencies**: 700 (complete)
- **Artifacts**: plans/02_trans-arrival-substrate-refactor.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The branching witness-family substrate now separates one-step succession from state-identity at a
time. `SharingSkeleton` carries a fourth periodic datum — three segments of Boolean succession
matrices at the representatives' own periods — and the `lift` obligation that datum creates;
`Thread.step` reads the arrival-pruned relation `trans` rather than `share (u+1)`; and (C1')'s two
temporal clauses quantify over succession rather than over `share`-classes. Five declarations
recording an empty certificate class for a stability modal over a tense operator were retired, and
four positive results replaced them: a six-condition certificate at non-trivial sharing for each
temporal direction, and a refutation of each retired congruence.

Soundness was never at issue and did not move. `plusTruth_iff_mem`, `plusRefutes_of_certifies`
and `total_eq_thread` are byte-identical to their pre-refactor form.

## What Changed

### The substrate

- `WitnessFamily/Sharing/Skeleton.lean` — `Thread.step` flipped to `K.trans u (idx u) (idx (u+1))`;
  `Thread.const` rebuilt from `trans_refl'`; `total_eq_thread` reproved from the `lift` field with
  its statement unchanged; the **no-hopping bundle** `transId` / `transIdOf` / `transIdOf_refl` /
  `transMatOf_id` / `transId_eq` added; the mirror lifting lemma `liftable_of_constant_above`
  added; `unrollOf_singletons` / `repOf_singletons` added for producers discharging `lift` inside
  their own structure literal; module docstring rewritten for the fourth datum and `lift`.
- `WitnessFamily/Sharing/Basic.lean`, `PlusWitnessFamily/Basic.lean` — `trans_pred_iff`, the
  bridge from `S.trans (t-1) k i` to an arrival share stated at `t` itself.
- `WitnessFamily/Sharing/Window.lean`, `Sharing/Fulfil.lean`, `PlusWitnessFamily/Fulfil.lean` —
  the `succF` / `predF` edge filters carry a `transRaw` row beside the `share` row; the walk layer
  gained `transRaw_succ`; the four `walkIdx_step` proofs now produce `trans` facts.

### (C1') re-quantified

- `Sharing/Predicates.lean`, `PlusWitnessFamily/Predicates.lean` — the `untl` clause quantifies
  over `S.trans t i j`, the `snce` clause over `S.trans (t-1) k i`.
- `Sharing/Decide.lean`, `PlusWitnessFamily/Decide.lean` — `shareClauseAt` carries the two
  succession matrices as data; `CoherentShareAt`, `coherentShareAt_congr` and
  `exists_window_repr` extended; `transRaw_congr_NB` / `transRaw_congr_NF` added on each side.
- `Sharing/Fulfil.lean`, `Sharing/Agreement.lean`, `Sharing/Specialize.lean`,
  `PlusWitnessFamily/Fulfil.lean`, `PlusWitnessFamily/Agreement.lean` — propagation and
  along-thread lemmas feed the clauses `Thread.step` and `thread_trans_pred` directly.
- `Sharing/Agreement.lean` — `untl_succ_congr` and `snce_pred_congr`, the residual agreement the
  clauses still force, with a section header stating why it is semantically forced and why it is
  not the repaired defect.

### The defect record, emptied and replaced

- `PlusWitnessFamily/Incompleteness.lean` — `snce_share_congr`, `untl_shift_share_congr`,
  `not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise` and
  `not_plusCertifies_stabUntl` removed; module docstring rewritten; `not_snce_share_congr`,
  `not_untl_shift_share_congr`, `targetA_eq` and `targetB_eq` added.
- `PlusWitnessFamily/Examples.lean` — Family A (shares from the origin on) and Family B (shares up
  to the origin), both with index-identity succession, their six per-condition proofs, and
  `plusCertifies_stabSnce_example` / `plusCertifies_stabUntl_example`.
- `scripts/check-module-invariants.sh` — five C2 rows retired and four added (nineteen to
  eighteen), pass message and block comment rewritten to say the retirement was the intended
  signal of a successful repair.
- `docs/theorem-index.md` — the same five rows out, four in.

### Evidence and documentation

- `specs/evidence/stability-modal-substrate/closure-field-is-necessary.lean` — new wired probe,
  `stabFamily_not_liftable_at_transId`: the `lift` field is a genuine obligation.
- `scripts/check-evidence-probes.sh` — the probe wired, with its header table entry.
- `WitnessFamily/Sharing/README.md`, `PlusWitnessFamily/README.md`,
  `PlusWitnessFamily.lean` — every prose account brought into line with what exists, including
  the export contract's additive extension.

## Decisions

- **Arrival pruning over a bare succession relation.** `trans u i j` is
  `transRaw u i j = true ∧ share (u+1) i j`. The second conjunct keeps `Step` and every frame
  lemma byte-identical, so the frame layer needed no re-proof at all.
- **The edge filters carry the raw Bool row, not the bundled `trans`.** `Finset.filter`'s
  decidability instance stays syntactic, and `mem_succF`'s right-hand side is literally the
  `trans_def` conjunction, so a `trans` fact splits and reassembles with no glue lemma.
- **`data_congr_back` / `data_congr_fwd` were not extended.** `exists_window_repr` consumes the
  `transRaw_congr_*` lemmas as two further `first` alternatives instead, which avoided renumbering
  every `.1`/`.2` projection at their call sites.
- **The gate families use index-identity succession.** That is what lets them share states
  non-trivially without any thread crossing between the shared indices — the separation the single
  relation made inexpressible, and the reason the certificates exist.

## Plan Deviations

- **Phase 6** altered: `PlusWitnessFamily/Fulfil.lean` was not in the phase's file list but needed
  the `mem_succF`/`mem_predF` delegations, two `foldRel_transRaw` delegations and four proof sites.
  The `succF`/`predF` filters carry the raw `transRaw` row rather than the bundled `trans`, and
  `transRaw_succ` is a walk lemma rather than a structure field.
- **Phase 7** altered: `data_congr_*` kept their statements (see Decisions);
  `thread_share_pred` was retained unchanged and the clause's new side condition is a separate
  lemma `thread_trans_pred`, stated at the succession's own argument order.
- **Phase 8** altered: the Plus-side succession congruences delegate through the window projection
  rather than being re-derived; the two stale README defect narratives got a SUPERSEDED banner in
  this phase and their full rewrite in Phase 12.
- **Phase 9** altered: the probe's short names collided with `Incompleteness.lean`'s and were
  renamed; the probe's external `trans` parameter became the no-hopping bundle, which was added to
  `Skeleton.lean`; `Examples.lean` now imports `Agreement.lean` and `Incompleteness.lean` imports
  `Examples.lean`.
- **Phase 10** altered: Family B is the mirror shape, so `liftable_of_constant_below` did not
  apply and `liftable_of_constant_above` was added; `famB_L` was split into a three-segment raw
  form and the two-way form consumers use.
- **Phase 11** altered: the obstruction is stated as `stabFamily_not_liftable_at_transId`, a
  refutation of `LiftableRaw` at the family's own raw data with the no-hopping bundle substituted,
  rather than at a locally-defined predicate.
- **Phase 12** altered: the two section headings the plan named had drifted; both were renamed
  rather than edited in place.

## Verification

- Build: Success. `lake build` green over all 2771 jobs, via the guarded detached invocation.
- Sorry count: 0
- Vacuous count: 0
- Axiom count: 14, unchanged from the pre-refactor tree
- `scripts/check-module-invariants.sh`: ALL CHECKS PASSED, C2 at eighteen pinned axiom sets
- `scripts/check-evidence-probes.sh`: PASS, all 7 wired probes compile
- `scripts/readme-lint.sh`: PASS
- `scripts/check-copyright-headers.sh`: 0 nonconforming, 0 missing, 605 files
- Soundness: `plusTruth_iff_mem`, `plusRefutes_of_certifies` and `total_eq_thread` are
  byte-identical to their form at the pre-refactor commit, confirmed by direct comparison
- Files verified: Yes

## Impacts

- The L⁺ certificate class is no longer empty for a stability modal over a tense operator. A
  decision procedure enumerating certified families no longer answers "valid" for `Pp → ⊡Pp`, and
  the L⁺ analogue of `exists_witnessFamily_of_not_validZTime` is no longer refuted by the
  condition set.
- The model checker's export contract gains three optional lists, additively. A checker that omits
  them is read as supplying the all-true succession matrix, which is the pre-redesign substrate, so
  every certificate emitted before the redesign is still valid unchanged. The accepting branch's
  `Refutes Γ Del` codomain did not move.
- Task 694's prescribed `trans` datum is a strict subset of what landed here. Per the recorded user
  decision, task 694 should be re-scoped to the deferred exact-closure work below.

## Follow-ups

- **Exact closure for `lift`**, the work task 694 is to be re-scoped to: `LiftWindow`,
  `liftable_of_liftWindow` and `Decidable LiftWindow`, so a producer's `lift` obligation can be
  checked rather than discharged by matching one of three sufficient conditions.
- **(C2')'s recorded limitation survives**, and was re-examined rather than inherited. Its window
  reduction's far-left and far-right cases consume exactly the relation a thread's step supplies,
  so the re-quantification transferred verbatim. The limitation is about the position graph's
  backward region being a path rather than a cycle, not about the substrate datum.
- Three READMEs carry informational lint notes (missing date stamps, unlisted files) that predate
  this work.

## References

- specs/696_stability_modal_substrate_design/plans/02_trans-arrival-substrate-refactor.md
- specs/696_stability_modal_substrate_design/reports/01_stability-modal-substrate-design.md
- specs/696_stability_modal_substrate_design/reports/02_trans-redesign-gate-verification.md
- specs/696_stability_modal_substrate_design/probes/03_trans_redesign_gate_probe.lean
- specs/evidence/stability-modal-substrate/closure-field-is-necessary.lean
