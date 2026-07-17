# Execution Summary: Archive Off-Faithful-Path Kamp Infrastructure (v2)

- **Task**: 381 — Archive off-faithful-path Kamp infrastructure ahead of the E[Sigma] re-architecture
- **Plan**: `plans/02_off-path-archival.md` (v2; supersedes v1)
- **Status**: Implemented (all in-scope phases COMPLETED)
- **Type**: lean4 (verification-and-relocation only)

## Outcome

Plan v2 re-scoped the task to a single completable Definition of Done after v1 stalled on two
blockers. v1 had already landed Phases 0-3 and 6 GREEN. This v2 run executed the remaining
Phase 5 (DECISION B2) and Phase 7 (final audit). DECISION B1 (the `kvExtFib_*` / Fib sub-DAG
extraction) was dropped from scope and recorded as a deferred follow-up.

## What Landed (Phase 5: RefutationF2 prune + archive)

- Pruned the single dead-but-compiled import
  `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.RefutationF2` from the aggregator
  `NfMultiAnchorBridge.lean` (was line 86).
- MOVED (never deleted) `NfMultiAnchorBridge/RefutationF2.lean` into
  `Kamp/Boneyard/RefutationF2.lean` via `git mv` (rename detected at 98% similarity; history
  preserved).
- Added a durable-anchor header naming the declaration `f2_relativized_refutation` and its role as
  a dead-but-compiled F2 refutation certificate feeding the downstream k >= 2 lossiness verdict.
  No task numbers in the header. The quarantined body was left byte-identical per the file's own
  "retained byte-identical, do not extend" directive.

## Rebaseline

- Build guardrail rebaselined **1766 -> 1765 jobs**.
- Reason (one line): pruning the sole `RefutationF2` import removes exactly one compiled module
  (`f2_relativized_refutation`) from the live import closure — a fully-accounted one-job closure
  reduction. The `completeness_discrete` axiom invariant is untouched.

## Invariants Verified (Phase 7 audit)

- Full `lake build` **EXIT 0 at exactly 1765 jobs** (confirmed before commit and again after).
- `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` (via `lean_verify`) =
  `{propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}` —
  **byte-identical to the baseline** reference set. `sorryAx` retained = exactly the one permitted
  `_k+2` sorry; no new axiom, no lost live declaration.
- Bare `sorry` statements in `Kamp/` (excluding `Boneyard/`) unchanged from baseline: exactly the
  pre-existing three — `EANegation.lean:1090`, `EANegation.lean:1249` (protected, untouched), and
  `KampPrior.lean:562` (the permitted `_k+2` residual). **Zero new sorry introduced.**
- No live module references `RefutationF2` / `f2_relativized_refutation` after the prune.
- `Kamp/Boneyard/` is NOT emptied — 32 `.lean` files present, including the newly archived
  `RefutationF2.lean` with its durable-anchor header and a task-number-free filename.
- Binding criterion (Phase 6, unchanged): ZERO live-closure modules import `Kamp.Boneyard.*`. The
  three path-only reach-ins (`Prop43.lean` -> `Boneyard.VecEA_m`/`.EAVecNegationClosure`;
  `NfMultiAnchorBridge/NavigatedEndChar.lean` -> `Boneyard.NavigatedEndCharSinglePoint`) originate
  from files that are themselves DEAD (0 importers, not in the `Bimodal.lean` closure); tidying
  them belongs to the separate Boneyard-hygiene sibling task.
- No new `axiom` declarations and no vacuous definitions introduced (the pre-existing `^axiom`
  grep hits are prose in comments; the one `:= trivial` hit is a legitimate pre-existing lemma in
  `Examples/TemporalStructures.lean`, not in any file this task touched).

## Deferred Follow-up (NOT part of this task, per DECISION B1)

The `kvExtFib_*` / Fib sub-DAG (`igFoldBitFib`/`igEpLFib`/`igEpRFib`/`igPtWFib` +
`kvExtFib_gate_henv`) is off-path (0/5 proof-term reached from `completeness_discrete`) and belongs
in the Boneyard eventually, but extracting it requires splitting LIVE on-path declarations out of
shared files (notably `KampPrior.lean`, holding live `kampPrior_case1_arm_k0/_k1`). That is
proof-structure surgery beyond this task's verification-and-relocation-only charter and risks the
1765/axiom invariants. Sequence it AFTER the downstream k >= 2 E[Sigma] re-architecture is
re-scoped. Recorded in the plan's Non-Goals and Rollback/Contingency so it is not forgotten.

## Plan Deviations

- **Phase 5, durable-anchor header task — altered**: the header was added above the import as
  archival provenance; the quarantined body was left byte-identical per the file's own "retained
  byte-identical, do not extend" directive, so the pre-existing historical task-number comments
  inside the quarantined body were NOT rewritten (out of the verification-and-relocation-only
  charter). No PDF page anchor exists for this record, so the declaration name and the k=2
  refutation-target mathematical anchor were used instead.

## Artifacts

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/RefutationF2.lean` (relocated, header added).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (one import line removed).
- `specs/381_archive_off_faithful_path_kamp_infra/plans/02_off-path-archival.md` (Phases 5, 7 COMPLETED).
- This summary.

## Commits

- `task 381 phase 5: prune+archive RefutationF2, rebaseline 1766->1765`
- `task 381 phase 7: final audit + summary (1765 DoD)`
