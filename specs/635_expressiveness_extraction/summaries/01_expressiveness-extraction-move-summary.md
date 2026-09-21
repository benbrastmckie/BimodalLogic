# Implementation Summary: Task #635

- **Task**: 635 - Extract the 141-file Expressiveness set into `Metalogic/Expressiveness/`
- **Status**: [COMPLETED]
- **Started**: 2026-09-21
- **Completed**: 2026-09-21
- **Effort**: ~9 hours
- **Dependencies**: task 634 (landed at `d3f912858`)
- **Artifacts**: plans/01_expressiveness-extraction-move.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Relocated the 141-module / 104,087-line expressiveness development out of
`FormalSystem/Metalogic/WeakCanonical/` into `FormalSystem/Metalogic/Expressiveness/`, renaming
`WeakCanonical.X -> Expressiveness.X` throughout and `WeakCanonical/Expressiveness/` ->
`Expressiveness/GameTransfer/`, so the two headline results ADR-011 exists to fix
(`Kamp.kampPriorExpressiveCompleteness`, `uSExpressivelyCompleteOverPrior`) no longer carry
"weak canonical" in their fully-qualified names. A second commit renamed 12 paper-numbered
files to content names and deleted 2 declaration-free stubs. No proof was edited and no `sorry`
was introduced or discharged: this was a structural relocation throughout.

## What Changed

Three commits, each independently green:

- `5fcd97e0b` — `scripts/typst-status-counts.sh`: anchored `SORRY_KAMP_BONEYARD` at
  `${REPO_ROOT}`. The path had resolved relative to `FormalSystem/` since the archive moved to
  the repository root, so any regeneration would have rewritten a true `sorry-total = 4` to `0`.
  Landed before any regeneration, as the plan required.
- `bae5ac591` — the move (313 files). 141 modules relocated; the 29 moved files declaring the
  bare `FormalSystem.Metalogic.WeakCanonical` namespace renamed path-scoped (29 `namespace`,
  29 `end`, 104 `open`, 4 `_root_` headers); new sibling aggregator
  `FormalSystem/Metalogic/Expressiveness.lean` (14 imports moved out of `WeakCanonical.lean`),
  wired into `Metalogic.lean`; both directory READMEs rewritten; ADR-011 accepted and ADR-006's
  pointer and cycle block corrected (9 -> 5 import lines);
  `scripts/measure-refactor-partitions.py` re-pointed at the two post-move roots with a new
  empty-set failure branch; `nolints.json` (98 names), the C2/C14 axiom baselines,
  `docs/theorem-index.md`, `MainResults.lean` and `typst/generated` re-pointed or regenerated.
- `17743588f` — 12 renames + 2 stub deletions (59 files), plus the corrected
  `PUBLICATION_REFACTOR.md` Phase 6 inventory row.

Work the plan did not anticipate, found by verification rather than by inspection:

- **20 residual modules referenced moved declarations as same-namespace siblings.** Sitting in
  `namespace ...WeakCanonical`, they resolved names like `OrderedMonadicStructure` and
  `MonadicSignature` implicitly. That resolution broke on the split; each now opens
  `Expressiveness` explicitly. Only the build surfaced this.
- **6 extension definitions on a moved type.** `OrderedMonadicStructure.{openSubinterval,
  halfOpenSubinterval, belowSubinterval, aboveSubinterval, hoSubinterval, restrictSet}` are
  declared in residual files but extend a type that moved, so they landed in the wrong namespace
  and dot-notation projection failed. Re-rooted with
  `_root_.FormalSystem.Metalogic.Expressiveness.`.
- **The tool falsified far more history than the plan's two named sites.** See Decisions.

## Decisions

- **`move-modules.py` falsified history at scale, not just at the two named sites.** The plan
  named ADR-011's *Today* column and ADR-006's cycle enumeration. Both were falsified exactly as
  predicted and both were restored. But the same collapse hit **17 Boneyard READMEs**, whose
  provenance tables are headed `Path before consolidation` / `Live origin before archival` —
  unambiguously historical — and whose prose includes statements like "This directory is the
  former `.../Kamp/Boneyard/`". Rewriting those to `Expressiveness/` asserts the files were
  archived from a directory that did not exist at archival time. All 17 were reverted to HEAD and
  exactly 4 lines re-applied: two navigational links and two explicitly present-tense sentences
  ("The live tree keeps a separation development at ..."). `typst/SYNC-MAP.md` was reverted whole
  for the same reason — it states outright that "its historical stamps are preserved as written".
- **The test used throughout**: does the sentence assert something about the past? A provenance
  column, an "original location", a "used to be", a dated audit stamp — historical, revert. A
  navigational link, a "the live tree keeps", a "develops toward" — present tense, update. The
  inverse error was also real and fixed: 10 present-tense citations the tool deliberately left
  alone (bare-form) had gone stale, including this repository's root `README.md` and
  `FormalSystem/Automation/README.md`.
- **Two plan assertions were wrong and are recorded as such rather than worked around.** The
  `countermodel_discrete` baseline count is 2 at HEAD, not 1 (baseline text plus `#print axioms`
  probe); the invariant it guards — residual baselines uncorrupted — holds. And a strict
  re-derivation of paper-numbered names gives 15, not 14.
- **C5 vs. a true historical record.** Restoring ADR-011's *Today* column made C5 fail: it is a
  genuinely stale module path, and `module-invariants-allowlist.txt` states in its own header
  that "a genuinely stale MODULE path must be fixed, never allowlisted". Resolved by writing both
  columns root-relative (`Metalogic.WeakCanonical...`), the form the *After* column already used,
  which keeps the history true and satisfies the check without an exemption.
- **Added `open` lines by extending existing ones in place** rather than inserting new lines, so
  zero lines shifted and the C20 citation hazard the plan flagged was removed rather than routed
  around. Where insertion was unavoidable (4 files) and where reflowing over-long lines shifted
  lines (a further set), the 15 resulting C20 citations were re-pointed by computing each target
  file's exact line delta and verifying the shifted line carries byte-identical content to the
  original referent.

## Plan Deviations

- **Phase 1** altered: the `status.typ` regeneration diff is not literally empty — the generator
  unconditionally restamps `stamp-commit`/`stamp-date`. Every count line is byte-identical and
  `sorry-total` stays 4, so the substantive no-op assertion holds.
- **Phase 3** altered: the external `open` fixups are **18 lines across 15 files**, not 10 across
  7. The plan's anchored grep missed the multi-namespace form (8 lines in residual
  `DenseModelSurgery/`) and the `open ... in` form.
- **Phase 3** altered: opens were extended in place, not inserted (see Decisions).
- **Phase 3** altered: the `countermodel_discrete` assertion value is 2, not 1, and was already 2
  at HEAD.
- **Phase 5** altered: the `uSExpressivelyCompleteOverPrior` assertion reads 0 across tracked
  files; a bare `grep -r .` also hits 9 stale lines in the gitignored `.lake/` cache.
- **Phase 5** altered: `readme-lint` first read 22, not 21. The extra was a relative link in the
  residual `IntegerModel/README.md` that class-7 re-basing missed; fixed, returning it to 21.
- **Phase 6** altered: 15 paper-numbered names exist, not 14;
  `Kamp/Section5Correspondence.lean` is excluded with evidence, leaving the planned 12 renames.
- **Testing & Validation** altered: the file count is 141/38 after commit 1 and **139**/38 after
  commit 2, which deletes the 2 stubs. Both are correct at their commit.

## Verification

- Build: **Success** — `lake build` clean, 2651 jobs, zero warnings.
- Build-inclusive `scripts/check-module-invariants.sh`: **ALL CHECKS PASSED** after each commit,
  including C25 exe roots (which sit outside every build closure), C2/C14 axiom pinning, C16
  env_linter against `nolints.json`, and C20 citations.
- `scripts/check-metalogic-cycles.sh`: exactly **1** directory-level cycle, still
  `BXCanonical <-> WeakCanonical`.
- `measure-refactor-partitions.py --check`: PASS non-degenerately — **139** files against **38**.
  The new empty-set failure branch was proved to fire by running the script against a bogus root
  (exit 1), not merely assumed.
- Sorry count: **0** (`lean-sorry-census.sh`). Vacuous count: **0**. Axiom count: **12**
  word-"axiom" prose hits, **0** real `axiom` declarations — identical to the pre-task baseline
  `0c4b2891b`.
- `typst/generated/status.typ`: `sorry-total = 4` preserved; `typst-sync-check.sh` Check 2
  `MISMATCH_COUNT=0` (was 2).
- Pre-existing red baselines unchanged and not this task's: `readme-lint.sh` at **21** broken
  refs; `typst-sync-check.sh` Check 1 at **9** `docs/training/PIPELINE.md` violations.
- Files verified: Yes.

## Impacts

- `Kamp.kampPriorExpressiveCompleteness` and `uSExpressivelyCompleteOverPrior` are now
  `FormalSystem.Metalogic.Expressiveness.*`. Any external citation of the old names is stale —
  this is the rename ADR-011 exists to perform before the first release tag.
- `Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` **stays** in the residual set and
  its path is unchanged, so citations of it do not drift; `countermodel_discrete`'s
  fully-qualified name is likewise unchanged. Recorded durably in the residual README, without a
  task-number reference.
- `measure-refactor-partitions.py --check` is meaningful again rather than a permanent vacuous
  PASS, which is what ADR-011's "standing pre-move gate" promised.
- Task 178 depends on this task and cites Kamp-named results that were renamed here; the 12
  renames above are the mapping it needs.

## Follow-ups

- `docs/development/PUBLICATION_REFACTOR.md` Phase 6 is marked complete; Phases 7-9 of that
  programme are untouched.
- The `FormalSystem/Metalogic/README.md` aggregator table still carries one pre-existing
  `<!-- TODO: add description -->` for `Deterministic.lean`, unrelated to this task.
- `readme-lint.sh`'s 21 broken `../Boneyard/` refs and `typst-sync-check.sh` Check 1's 9
  violations remain red. Both are pre-existing, explicitly out of scope per the plan's Non-Goals,
  and were held at their baseline values rather than fixed.

## References

- `specs/635_expressiveness_extraction/plans/01_expressiveness-extraction-move.md`
- `specs/635_expressiveness_extraction/reports/01_expressiveness-extraction-move.md`
- `specs/635_expressiveness_extraction/{module-map,namespace-map,rename-map}.txt`
- `docs/architecture/ADR-011-Extract-Expressiveness.md`,
  `docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md`
- Commits `5fcd97e0b`, `bae5ac591`, `17743588f`
