# Implementation Summary: Boneyard Archive Hygiene — No Live Imports

- **Task**: 359 - boneyard_archive_hygiene_no_live_imports
- **Plan**: plans/01_boneyard-hygiene-plan.md (all 4 phases [COMPLETED])
- **Session**: sess_1784886673_059c3f_359
- **Date**: 2026-07-24
- **Status**: implemented (skeleton: false; sorry_inventory empty)

## Phases Executed

| Phase | Commit | What |
|-------|--------|------|
| 1 | cafd4849a | Archived the dead 4-decl CarrierK1V `endInterval` skeleton to `Kamp/Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean` (126 lines); breadcrumb at excision site; stale prose fixed in `InteriorGateGeneralK.lean` |
| 2 | b901a8be1 | Retired the EANegation backward-direction closure (5-decl B2 set + 3-decl B3 warm-up trio) to `Kamp/Boneyard/EANegationVBracketBackward.lean` (613 lines); `EANegation.lean` is now sorry-free; impossibility note and both Rabinovich docstrings preserved verbatim |
| 3 | 7c0c9c68c | Mechanical normalization: all 145 Boneyard `.lean` files now carry an `ARCHIVED (Boneyard)` module-docstring marker and exactly one `#exit` immediately after the import block (143 files changed; census 145/145 conforms) |
| 4 | (this commit) | README inventory reconciliation for both Boneyards + tombstone markers + 5-gate final verification |

## Phase 4 Detail

- **TB README** (`Theories/Bimodal/Boneyard/README.md`): inventory table reconciled against
  the measured tree — totals corrected 67 / ~39,619 → **83 files / 51,243 lines**; per-subdir
  file/line counts refreshed; four missing rows added (DeadChronicleGapElimination,
  KampBypassArchive, RestrictedMCSDeferral, VecEADecomposition); UltrafilterFrame corrected to
  3 files (AlgebraicCompleteness.lean acknowledged). Tombstones section added listing the 9
  README-only subdirectories.
- **9 tombstone READMEs**: first line marked
  `TOMBSTONE — code deleted; README retained as historical record.` (BundleTemporalCoherence,
  BX1DependentCode, ClosedGuardLegacy, NonBurgessSeed, OpenGuardInvalid,
  StageInductionGapAnalysis, TAxiomDependentCode, UltrafilterDeadCode, XuLemma321Legacy).
  Nothing deleted.
- **KB README** (`Kamp/Boneyard/README.md`): NfMultiAnchorBridgeRetired updated to 5 files with
  an `EndIntervalSkeleton.lean` entry; new section for `EANegationVBracketBackward.lean`
  (613 lines) documenting the retired closure, its supersession by `VVecEA2.negFix_iff` and
  `EANegationClosure.lean`, and the preserved Rabinovich labels. Durable anchors only — no
  task numbers introduced anywhere.

## Final Verification (all 5 gates PASS, 2026-07-24)

1. **No live imports**: `grep -rn "^import.*Boneyard" Theories/ Tests/ | grep -v /Boneyard/` → empty.
2. **Build**: `lake build` GREEN (1789 jobs) and `lake build BimodalTest` GREEN (1824 jobs).
3. **Axiom baseline**: `lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete` →
   exactly `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`,
   no sorryAx, no warnings (the two `Lean.*` entries are the known native_decide caveat,
   part of the baseline).
4. **No task-number references introduced**: 0 added lines in the `Theories/` diff match a
   task-reference pattern; new README rows use `--` in the Task column. (Pre-existing task
   references in old Boneyard content were left untouched, as scoped.)
5. **Preservation spot-check**: `EANegationVBracketBackward.lean` contains the impossibility
   note (`IMPOSSIBILITY: The backward direction of the Corollary 5.4 biconditional is
   UNPROVABLE at the BracketFormula level`, :579) and both Rabinovich docstrings
   ("Lemma 5.1 (Rabinovich 2014, pp.7-11)" :182, "Corollary 5.4" :76/:480) verbatim.

Additional checks: 0 code sorries introduced across the whole task (Phase 4 diff "sorry" hits
are README prose only); 0 new axioms (`^axiom` count outside Boneyard: 0); the single vacuous
pattern hit (`Examples/TemporalStructures.lean:269`) is pre-existing pedagogical code untouched
by this task.

## Plan Deviations

- Phase 3 census baseline corrected (comment-aware recount: 14/29/100/2, not the report's
  19/24/40) — annotated inline in the plan.
- Phase 4 TB recount expanded to add 4 missing inventory rows and fix the UltrafilterFrame
  file count — required for the table to actually match the tree; annotated inline.
- Tombstones section implemented by upgrading the pre-existing "Directories with README Only"
  section (avoids duplicated lists).

## Follow-Up Recommendation

The Tier-2 dead-sorried-decl sweep (~16 decls across 8 live files) was explicitly DESCOPED
(plan Non-Goals). The research report's Tier-2 table (reports/01_boneyard-hygiene-audit.md
§(b) Tier 2) with per-decl destinations is the ready-made charter for a follow-up task; each
excision requires a fresh per-decl consumer re-grep (Medium-confidence evidence).

## Sorry Inventory

Empty — no sorries introduced or inherited; `EANegation.lean` went from 2 sorries to 0.
