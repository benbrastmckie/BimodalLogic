# Implementation Summary: Task #744

- **Task**: 744 - Wrap the RaySummary and KTypeSummary inventory tables in BEGIN GENERATED markers so their module line counts cannot drift again
- **Status**: [COMPLETED]
- **Started**: 2026-10-17T18:48:18Z
- **Completed**: 2026-10-17T19:06:00Z
- **Effort**: ~20 minutes wall clock (plan estimate 5.5 hours)
- **Dependencies**: None
- **Artifacts**: plans/01_wrap-inventory-tables-generated-markers.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The two named READMEs, and 21 further READMEs whose inventory tables fit the generator's
default column set, now carry `<!-- BEGIN GENERATED: inventory dir=... -->` / `<!-- END
GENERATED -->` markers, so `check-module-invariants.sh`'s INV check owns their line counts.
A one-line escape-aware change to the generator's `split_row` preserves GFM-escaped `\|`
inside hand-written descriptions, and every one of the 164 pre-existing descriptions across the
23 wrapped tables was verified byte-identical after regeneration. INV was demonstrated (not
assumed) to name each of the 23 READMEs on a deliberately corrupted count.

## What Changed

- `scripts/check-module-invariants.sh` — `split_row` now splits on `re.split(r"(?<!\\)\|", body)`
  instead of `body.split("|")`; the `--emit-inventory` header comment states that an escaped `\|`
  inside a cell is preserved as content
- `docs/reference/readme-standard.md` — "Generating the table" says an inline `|` in a
  description must be written `\|` and the generator preserves it
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — wrapped; 16 descriptions preserved
  (three contain `\|`); `AnchorLayer` 406→418, `Profile` 578→581, `Periodic` 1624→1,627 refreshed
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` — wrapped; 6 descriptions preserved
- Ten READMEs wrapped in the Expressiveness / BXCanonical/Filtration / WeakCanonical sweep
  (`EFGames`, `GameTransfer`, `Kamp/NfMultiAnchorBridge/SharedWitness`, `Kamp/EANegationFix`,
  `Kamp/EANegationFixFaithful`, `BXCanonical/Filtration`, `WeakCanonical/DenseModelSurgery`,
  `WeakCanonical/IntegerModel`, `WeakCanonical/RealModel`, `WeakCanonical/GroupModel`) — 61
  descriptions preserved; 39 stale counts refreshed; `IntegerModel` gained three described rows
  (`GoodStructuresModelSurgery.lean`, `NoGapsDiscreteProof.lean`, `ReynoldsBridge.lean`)
- Eleven READMEs wrapped in the Decidability / Theorems / Automation / Semantics / Syntax /
  ProofSystem sweep (`Decidability/WitnessFamily/Sharing`, `Decidability/Verified/Termination`,
  `Decidability/Verified/Bridge`, `Decidability/BiLasso`, `Decidability/Propositional`,
  `Theorems/Propositional`, `Automation/ProofSearch`, `Semantics/Correspondence`,
  `Semantics/Extension`, `Syntax/SubformulaClosure`, `ProofSystem`) — 81 descriptions preserved;
  66 stale counts refreshed; `Sharing` gained described rows for `Stability.lean` and
  `Window.lean`, `Termination` a described `MintBound/` subdirectory row; the `TimeTypeBound.lean`
  description's inline `|C|` was escaped to `\|C\|` so it is one cell

In total: 23 new generated surfaces, 164 descriptions byte-identical, 108 stale line counts
corrected by the generator (none by hand), 6 new descriptions authored from module doc-comments.

### New generated surfaces

Any later `.lean` edit in one of these directories now forces `bash
scripts/check-module-invariants.sh --emit-inventory` before INV is green again:

```
FormalSystem/Automation/ProofSearch/README.md
FormalSystem/Metalogic/BXCanonical/Filtration/README.md
FormalSystem/Metalogic/Decidability/BiLasso/README.md
FormalSystem/Metalogic/Decidability/Propositional/README.md
FormalSystem/Metalogic/Decidability/RaySummary/README.md
FormalSystem/Metalogic/Decidability/Verified/Bridge/README.md
FormalSystem/Metalogic/Decidability/Verified/Termination/README.md
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md
FormalSystem/Metalogic/Expressiveness/EFGames/README.md
FormalSystem/Metalogic/Expressiveness/GameTransfer/README.md
FormalSystem/Metalogic/Expressiveness/Kamp/EANegationFix/README.md
FormalSystem/Metalogic/Expressiveness/Kamp/EANegationFixFaithful/README.md
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/SharedWitness/README.md
FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/README.md
FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md
FormalSystem/Metalogic/WeakCanonical/IntegerModel/README.md
FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md
FormalSystem/Metalogic/WeakCanonical/RealModel/README.md
FormalSystem/ProofSystem/README.md
FormalSystem/Semantics/Correspondence/README.md
FormalSystem/Semantics/Extension/README.md
FormalSystem/Syntax/SubformulaClosure/README.md
FormalSystem/Theorems/Propositional/README.md
```

Cross-check: `git log --name-only` over this task's commits lists exactly these 23 READMEs under
`FormalSystem/`; none carried a generated block before the task's first commit; the tree now has
51 wrapped READMEs under `FormalSystem/` (28 pre-existing + 23 new).

## Sweep Report

Re-derived against the tree at close (27 READMEs under `FormalSystem/` carry neither a generated
block nor a hand-maintained registration). Stale counts in every unwrapped table were left as
found, per the task's NON-GOALS — the recurrence stays visible rather than being papered over.

**Tier B — count-carrying tables left unwrapped, with the specific blocker** (wrap once resolved):

| README | Blocker (re-verified) |
|--------|------------------------|
| `Metalogic/BXCanonical/Chronicle/README.md` | phantom row `HenkinDiscreteChain.lean`; 8 live files have no row |
| `Metalogic/BXCanonical/Quasimodel/README.md` | phantom row `EnrichedClosure.lean` |
| `Metalogic/Core/RestrictedMCS/README.md` | phantom row `Deferral.lean` |
| `Metalogic/Expressiveness/Separation/README.md` | 10 phantom `.lean` rows and 2 phantom subdirectory rows (`DedekindZ/`, `Hierarchy/`) — the directory now holds only `Defs`, `KampTranslation`, `SemanticBridge`; the table describes a layout that has moved |
| `Metalogic/Expressiveness/README.md` | subdirectory rows carry numeric line totals (`EFGames/` 11,800, `GameTransfer/` 9,507, `Kamp/` 77,714, `Separation/` 926); `cols=lines` would render `—`, `cols=files-lines` needs a four-column header rewrite |
| `Metalogic/WeakCanonical/README.md` | same shape: five subdirectory rows with numeric totals |
| `Metalogic/Decidability/WitnessFamily/README.md` | upper table (line 74) is `rows=loose`-shaped (no subdirectory rows for `Compression/`, `Sharing/`); lower table (line 111) keys rows on `Sharing/`-prefixed paths the generator would not emit |
| `Metalogic/Expressiveness/Kamp/README.md`, `Kamp/NfMultiAnchorBridge/README.md` | `\| \| Files \| Lines \|` directory rollups — `cols=files-lines` shape with an empty header cell; option-requiring |
| `Metalogic/BXCanonical/README.md` | fits apart from the pinned row `../BXCanonical.lean`, which the generator keeps with refreshed numbers — a clean follow-up candidate, left out because the pinned-row path was not exercised by this task's description-preservation check |

**Tier C — report-only (no count column the default column set owns)**: `Decidability/FMP`
(`| File | Decls | Description |`), `Decidability/Verified/Termination/MintBound`
(`| Module | Lines | Decls | Role |`, four columns), the `| Module | Contents |` tables under
`Decidability/PlusSlicedCertificate`, `PlusSlicedCertificate/Limits`, `PlusWitnessFamily/Compression`,
`PlusWitnessFamily/Limits`, `WitnessFamily/Compression`; the `| File | Description |` tables in
`Examples`, `Semantics/Nomic`, `Theorems/Perpetuity`; `| File | Role |` in `Metalogic/Deterministic`;
and the `| Module | Purpose | Status |` / `| Theorem | Type | Status | File |` status tables in
`Metalogic/Algebraic`, `Metalogic/Bundle`, `Metalogic/Core`, `Metalogic/Decidability`.
`Decidability/PlusWitnessFamily` and `Decidability/Verified` carry no inventory-shaped table.

## Decisions

- Header lines `| File | Lines | Role |` and `| Module | Lines | Role |` are kept verbatim by the
  generator, so tables with those headers were wrapped without a header rewrite.
- Alphabetical re-ordering and `{:,}` thousands separators were accepted as regeneration effects;
  layering labels live in the descriptions and survive.
- Restore via the writer: `corrupt-check.sh` regenerates a corrupted block with `--emit-inventory`
  rather than a pathspec checkout, in line with the shared-worktree discipline.
- `git-snapshot.sh --no-revert` was dropped after phase 2: no destructive git command follows the
  writer, and the snapshot's untracked-backup copies were swept into the phase 2 commit by the
  task-directory pathspec (removed again in phase 3).

## Plan Deviations

- **Task 2.4** altered: the three-rollup-README restore step was unnecessary — sibling 812 had
  already regenerated them (INV PASS at baseline), so the writer only ever rewrote this task's
  own blocks.
- **Task 3.1** altered: restore via the writer, not `git checkout --`.
- **Task 4.3 / 5.2** skipped: pre-writer snapshot (see Decisions).
- **Task 5.1** altered: escaped the unescaped `|C|` in Termination's `TimeTypeBound.lean` row
  before wrapping.

## Verification

- Build: N/A (markdown and one shell script; no `.lean` change)
- Tests: `bash scripts/check-module-invariants.sh --no-build` — 46 PASS, 0 FAIL, "ALL CHECKS
  PASSED"; since every check passes there is no status change relative to the starting commit
- INV coverage: `corrupt-check.sh` on all 23 wrapped READMEs — each FAIL line names exactly the
  corrupted README (exit 1), each post-restore `--check` is PASS (exit 0), `git diff` empty
  afterwards. The plan's caveat that INV's exit code would be red regardless did not apply: the
  rollup READMEs were current throughout.
- Description preservation: key-sorted `desc-snapshot.py` diff empty for all 23 files (164 rows)
- `bash .claude/scripts/verify-deploy.sh --only-gate 4` (task-reference lint): PASS after every
  wrap phase
- Batch gate deferral: this dispatch ran the scoped tier named by its dispatch file (gate 4 plus
  the repository's own `check-module-invariants.sh --no-build`); the complete `verify-deploy.sh`
  gate set is deferred to the once-per-invocation batch stage, not independently run here
- Files verified: Yes

## Impacts

- 23 READMEs are now generated surfaces; a `.lean` edit in any of those directories turns INV red
  until `--emit-inventory` is run. A plan-time `file_scope` harvest that discovers generated blocks
  at run time picks these up automatically.
- The wrapped RaySummary block is self-guarding: if `split_row` ever regresses on `\|`, INV
  fails on that README.

## Follow-ups

- Wrap the Tier-B tables once their blockers are resolved (phantom rows removed or described;
  the `cols=files-lines` rollups rewritten with a four-column header; `WitnessFamily/README.md`'s
  two tables given `rows=loose` / re-keyed); `BXCanonical/README.md` is the easiest — only its
  pinned `../BXCanonical.lean` row needs a one-time check.
- A `sort=existing` generator option only if alphabetization proves costly to readers.

## References

- specs/744_wrap_inventory_tables_generated_markers/plans/01_wrap-inventory-tables-generated-markers.md
- specs/744_wrap_inventory_tables_generated_markers/reports/01_wrap-inventory-tables-generated-markers.md
- specs/744_wrap_inventory_tables_generated_markers/progress/phase-{1..6}-progress.json
- specs/744_wrap_inventory_tables_generated_markers/issues.jsonl
