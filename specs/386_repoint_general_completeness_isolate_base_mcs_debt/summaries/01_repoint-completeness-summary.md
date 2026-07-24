# Implementation Summary: Re-point General Completeness (Base) — Isolate Base-MCS Discrete Debt

- **Task**: 386 - repoint_general_completeness_isolate_base_mcs_debt
- **Plan**: plans/01_repoint-completeness-plan.md
- **Status**: COMPLETED (2 of 2 phases)
- **Session**: sess_1784886673_059c3f_386
- **Files modified**: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (only file)

## Phases Executed

### Phase 1 (commit e5946d709): Branch re-points + lemma relocation

- Moved `countermodel_dense_enriched` (docstring + theorem, ~31 lines) above the
  `/-! ## BX Completeness Theorem -/` header and de-privatized it (declaration-order fix;
  `private` alone would not have compiled due to the same-file forward reference).
- Dense branch of `completeness` re-pointed from `Chronicle.countermodel_dense` to
  `countermodel_dense_enriched` with `h_valid Rat ...` (mirror of `completeness_dense`).
- Mixed branch re-pointed from `Chronicle.dd_countermodel_chronicle_mixed_sorry` to
  `False.elim (Chronicle.mcs_mixed_case_absurd FrameClass.Base ...)` (mirror of
  `completeness_discrete`).
- Discrete branch untouched (`WeakCanonical.countermodel_discrete` byte-for-byte).

### Phase 2 (this dispatch): Prose alignment and sole-residue documentation

- `completeness` docstring rewritten per report Change 5.1: three-way case-split Proof
  Strategy naming `countermodel_dense_enriched` (dense, on ℚ), deprecated
  `WeakCanonical.countermodel_discrete` as SOLE remaining `sorryAx` source (discrete), and
  `mcs_mixed_case_absurd` via `discrete_box_necessity` (mixed); Sorry Status paragraph
  incorporates the report's sole-residue wording (Base-MCS not automatically
  Discrete-consistent; Reynolds pipeline not reusable; `succ_cofinal` unfixable — ℤ+ℤ
  counterexample; discharge is a genuine open construction). Stale
  `Chronicle/ChronicleToCountermodel.lean` anchor removed (Change 5.4).
- File-header Status block updated (Change 5.2): dense → `countermodel_dense_enriched`,
  mixed → `mcs_mixed_case_absurd`; dropped `Chronicle.countermodel_dense` /
  `dd_countermodel_chronicle_mixed_sorry` as live dependencies.
- EOF audit print annotated (Change 5.3): `Chronicle.countermodel_dense` audit retained
  with a note that it is no longer consumed by `completeness`, pending archival.
- In-proof case-split roadmap comment corrected (mixed case: "eliminated by the structural
  axiom", not "vacuously true"; discrete case labeled as sole sorryAx source).

## Plan Deviations

- Phase 2 sweep (annotated inline in the plan): also removed two pre-existing task-number
  references in archival comments (file-top Boneyard note and the
  `countermodel_discrete_enriched` archival note) to satisfy the plan's
  `grep -in "task [0-9]"` → no-matches verification criterion.

## Final Verification Results

- Scoped build `lake build Bimodal.Metalogic.BXCanonical.Completeness`: green.
- Full `lake build`: green (1789 jobs).
- Axiom profiles byte-identical to the F1 baseline:
  - `completeness`: `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` (sorryAx retained, sole source: discrete branch)
  - `completeness_dense` / `completeness_discrete`: same set WITHOUT `sorryAx` (clean)
- Zero new `sorry` tokens (all in-file matches are prose/`sorryAx` mentions).
- `dd_countermodel_chronicle_mixed_sorry`: zero occurrences in the file.
- `Chronicle.countermodel_dense`: appears only in the annotated EOF audit.
- `grep -in "task [0-9]"` on the file: zero matches.

## Sorry Inventory

Empty. The `sorryAx` in `completeness` flows through the pre-existing, deliberately-retained
deprecated dependency `WeakCanonical.countermodel_discrete` (WeakCanonical/Transfer.lean) —
outside this task's file and explicitly out of scope per the plan (no sorry token exists in
`Completeness.lean` itself).

## Archival Unlocks (for follow-up task creation)

Both lemmas lose their last live consumers and are now archivable:

- `Chronicle.dd_countermodel_chronicle_mixed_sorry`
  (`Theories/Bimodal/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean`) — also removes the
  misleading `_sorry` name from the live tree.
- `Chronicle.countermodel_dense`
  (`Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`) —
  only the top-level wrapper is dead; its supporting chain is shared with
  `countermodel_dense_enriched`.
