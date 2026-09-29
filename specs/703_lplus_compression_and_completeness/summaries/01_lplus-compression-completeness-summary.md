# Implementation Summary: Task #703

- **Task**: 703 - L⁺ Compression and Completeness
- **Status**: [BLOCKED]
- **Started**: 2026-09-29T16:51:00Z
- **Completed**: 2026-09-29T18:35:00Z
- **Effort**: ~4 hours (7 of 13 phases complete, 1 blocked, 5 not started)
- **Dependencies**: `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` (landed); the
  redesigned sharing substrate as finally corrected (landed). Neither was a blocker.
- **Artifacts**: plans/01_lplus-compression-completeness.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1 through 7 of the thirteen-phase L⁺ compression plan are complete, sorry-free and
axiom-clean, and Phase 8's first task is landed. Phase 7 closed
`[COMPLETED WITH EXCLUSIONS]`: its Invariant A was dropped by a recorded decision, and its
Invariant B was implemented by a shift mechanism that is strictly stronger than the one the
blocker record sketched. Phase 8 is now **[BLOCKED]**, on an alignment budget forced by the
compression theorem's own `mid` bound.

The compression theorem `exists_plusSharingWitnessFamily_of_not_plusValidZTime` is **not** proved
and `plusFamilyBound` is **not** defined; those belong to Phases 8 through 13.

Soundness was never touched. `plusTruth_iff_mem` and `plusRefutes_of_certifies` have unchanged
statements, confirmed by an empty diff over `PlusWitnessFamily/Agreement.lean` across every
commit of this task.

## What Changed

This dispatch's changes, on top of the Phases 1-6 modules already summarised in the plan's
"Artifacts & Outputs" section:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Extract.lean` — Invariant B.
  `plusAlignOffset` and `two_mul_plusAlignOffset_le` fix the canonical mark and its arithmetic.
  `PlusLabelledLasso.preBlock`, `shiftBack` and `shiftBy` build the shifted lasso;
  `lab_shiftBy` proves the shift acts on the decoded function by translation, region by region;
  `lab_neg`, `lab_mid` and `lab_fwd` are the three region readers it uses.
  `plusLocalCoherentSeqLab_comp_sub` and `plusFulfillingSeqLab_comp_sub` carry the two sequence
  predicates across a translation. `exists_plusLabelledLasso_of_history_aligned` is the consumer
  form: one history compresses to one bounded lasso **marked at the constant**
  `plusAlignOffset Γ Del`. `exists_plusLabelledLasso_of_history_realized` was **strengthened**,
  never weakened: it now also returns `i < plusAlignOffset Γ Del` and
  `Λ.nm - i < plusAlignOffset Γ Del`.
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Saturate.lean` — new file,
  the (C5) demand. `plusSameState` with its three equivalence lemmas;
  `plusTruthAt_stab_of_sameState` and `plusTypeAtM_mem_of_stab_of_state_eq` for the `→`
  direction; `plusTypeAtM_stab_congr_state` and `plusTypeAtM_atom_congr_state` for the two
  congruences a `share`-class needs; `exists_history_state_eq_of_not_stab` and
  `plusTypeAtM_stab_demand` for the `←` direction's witness;
  `plusTypeAtM_stab_iff_forall_sameState` bundling both.
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` — one added import line.
- `typst/generated/status.typ` — regenerated twice, for the committed-count gate.

## Decisions

- **Invariant B normalises to a constant, not to a maximum.** The Phase 7 blocker's sketch
  aligned to the maximum landing offset over the extracted list, which makes the common mark
  depend on the list and pushes the shifted `mid` length below `3 · 2^κ`. The implementation
  aligns to `plusAlignOffset Γ Del = 2 ^ κ` instead, which is independent of the history, the
  time, the model and the list, and which keeps the shifted `mid` length below
  `2 · 2^κ = plusMidBoundC`. That is the original mid bound rather than a widened one, and it
  needs no `κ ≥ 1` side condition.
- **`back` is re-indexed by a `List.range` map rather than by `List.rotate`**, so that the
  decoding argument is a direct `getD` computation instead of a rotation-index lemma.
- **The extraction theorem was strengthened rather than duplicated.** Adding two conjuncts to
  `exists_plusLabelledLasso_of_history_realized` avoided re-proving its 230-line body for the
  aligned form.
- **`ring` is not available in this module's import closure**; every linear integer step uses
  `omega` instead. Recorded because it is not obvious from the file.
- **The Phase 8 obstruction was escalated, not worked around.** The dispatch's standing
  instruction is that a finding which would force a change to the theorem statement stops and
  reports. Nothing in the Lean Challenge Statement was edited.

## Plan Deviations

- **Phase 7, Invariant A** skipped: dropped by the orchestrator decision recorded in
  `.decisions.json` and annotated at the plan's Phase 7 heading. Not provable as written; not
  needed for the segment bounds, which come free from the unpadded extraction.
- **Phase 7, Invariant B** altered: normalised to the constant `plusAlignOffset Γ Del` rather
  than to a maximum over a list, and implemented by the `plusShift` prepend-and-rotate mechanism
  rather than by rotating Invariant A's padded segments, which no longer exist.
- **Phase 7 addition, recorded**: `plusAlignOffset`, `plusAlignOffset_pos`,
  `plusAlignOffset_eq_natCard`, `two_mul_plusAlignOffset_le`, the three region readers
  `lab_neg`/`lab_mid`/`lab_fwd`, and the two `getD`-on-append helpers, none of which the phase's
  task list names.
- **Phase 8, task 1** completed; tasks 2 through 6 blocked. Two `→`-direction lemmas and two
  state congruences were added beyond the task's wording, because the saturation and Phase 11
  both read them.
- **Phase 7 closed `[COMPLETED WITH EXCLUSIONS]`** rather than `[COMPLETED]`, the exclusion being
  Invariant A, enumerated and evidenced at the phase heading.

## Verification

- Build: Success. Full `lake build` through the build guard, exit 0, 2777 jobs, zero `error:`
  lines and zero `warning:` lines over both captured streams.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: 1, pre-existing and not introduced by this task —
  `FormalSystem/Examples/TemporalStructures.lean:495`, `int_domain_universal`, where
  `intTimeHistory.domain t` genuinely is `True`. No file this task touched contributes one.
- Axiom count: 14 across all resolved source roots, unchanged from the parent commit.
- Tests: N/A (no test module in scope).
- Files verified: Yes.
- Soundness: `git diff` over `PlusWitnessFamily/Agreement.lean` across this task's commits is
  empty, so `plusTruth_iff_mem` and `plusRefutes_of_certifies` are untouched.

## Impacts

- Invariant B is now available to Phases 9 and 11 as named lemmas rather than as a side condition
  buried in a proof, which is what the phase's verification criterion asked for.
- The (C5) demand layer is design-independent. Whatever shape the saturation eventually takes,
  and however the alignment-budget decision goes, Phase 11's `←` direction reads
  `plusTypeAtM_stab_demand` and its `→` direction reads
  `plusTypeAtM_mem_of_stab_of_state_eq`, unchanged.
- The Phase 8 finding bears on the Invariant A decision itself. That decision recorded "nothing
  downstream needs it for correctness", assessed against the segment bounds and `NB`/`NF`
  well-formedness. The (C5) saturation was not assessed, and it is where the consequence shows
  up. Whoever revisits the decision should read the Phase 8 blocker alongside it.

## Follow-ups

- **Blocking, needs a user or orchestrator decision**: the Phase 8 alignment budget. Three
  resolutions are enumerated in the plan's Phase 8 BLOCKER record; resolution 1 (give `mid` its
  own, larger bound in the Lean Challenge Statement, leaving `back` and `fwd` at
  `plusCompressionBound`) is recommended. It changes the Lean Challenge Statement, which is why
  it is being asked rather than taken.
- Phases 9 through 13 are untouched and unblocked in themselves; they depend on Phase 8.
- The acceptance gates of Phase 13 (a `docs/theorem-index.md` row and the C2 `AXIOM_BASELINE`
  pin) are **not** landed, because the theorem they would pin does not exist yet.

## References

- `specs/703_lplus_compression_and_completeness/plans/01_lplus-compression-completeness.md`
- `specs/703_lplus_compression_and_completeness/reports/01_lplus-compression-completeness-research.md`
- `specs/703_lplus_compression_and_completeness/handoffs/phase-7-handoff-20260929T180000Z.md`
- `specs/703_lplus_compression_and_completeness/handoffs/phase-8-handoff-20260929T183000Z.md`
- `specs/703_lplus_compression_and_completeness/.decisions.json`
