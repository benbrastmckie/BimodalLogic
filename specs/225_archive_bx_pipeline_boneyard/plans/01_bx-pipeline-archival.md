# Implementation Plan: Archive BX Pipeline to Boneyard

- **Task**: 225 - Archive BX pipeline to Boneyard to prevent implementation agent distraction
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/225_archive_bx_pipeline_boneyard/reports/01_bx-pipeline-archival.md
- **Artifacts**: plans/01_bx-pipeline-archival.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Archive and deprecate the dead BX pipeline code that continually distracts implementation agents. The root sorry `no_gaps_faithful` in ReynoldsModelSurgery.lean is provably false (Z+Z counterexample), making the entire downstream chain (`chronicle_gap_contradiction` -> `succ_cofinal` -> `limitDomSubtype_isSuccArchimedean` -> `dd_countermodel_chronicle_discrete`) permanently dead. The correct path is the Reynolds pipeline via `no_gaps_discrete` (task 202). Two pure-dead files move to Boneyard; interleaved dead code in shared files receives deprecation annotations. The `lake build` must pass unchanged after all modifications.

### Research Integration

The research report (01_bx-pipeline-archival.md) provides a complete inventory of 4 files containing dead BX pipeline code. Key findings:
- Cannot move entire BXCanonical directory -- Chronicle construction machinery (14,280 lines) is shared between dead and active Reynolds pipelines
- Two pure-dead files (ChronicleNoGaps.lean, HenkinDiscreteChain.lean) can be safely moved to Boneyard
- Dead code in ChronicleToCountermodel.lean and ReynoldsModelSurgery.lean is interleaved with live code
- `gap_of_not_succ_archimedean_local` from ChronicleNoGaps.lean is only referenced in comments (line 317, 320 of ReynoldsModelSurgery.lean), not in code -- the function reproduces the lemma inline
- WeakCanonical.lean imports ChronicleNoGaps at line 16; this import must be removed

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items directly addressed by this archival/cleanup task.

## Goals & Non-Goals

**Goals**:
- Mark all dead BX pipeline definitions with clear deprecation annotations so agents do not attempt to prove or use them
- Move 2 pure-dead files (ChronicleNoGaps.lean, HenkinDiscreteChain.lean) to Boneyard/BXPipelineGapAnalysis/
- Remove ChronicleNoGaps import from WeakCanonical.lean
- Update Boneyard README with the new directory entry
- Ensure `lake build` passes with zero new errors

**Non-Goals**:
- Rewiring `completeness_discrete` to use Reynolds pipeline (that is task 202 scope)
- Removing or deleting any dead code from ChronicleToCountermodel.lean or ReynoldsModelSurgery.lean (deprecation annotations only)
- Modifying any Reynolds pipeline code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing ChronicleNoGaps import breaks compilation | H | L | Verify exports are not used by any file other than WeakCanonical.lean (confirmed by grep -- only comment references remain) |
| Deprecation comments cause Lean parse errors | M | L | Use `/-! ... -/` module doc blocks which are standard Lean docstrings |
| HenkinDiscreteChain.lean has unknown importers | H | L | Verified by grep: no file imports HenkinDiscreteChain |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Deprecation Annotations to Interleaved Dead Code [COMPLETED]

**Goal**: Mark all dead BX pipeline definitions with deprecation warnings so agents stop attempting to prove or use them.

**Tasks**:
- [x] Add deprecation doc block to `no_gaps_faithful` in ReynoldsModelSurgery.lean (lines 291-312). Prepend a `/-! ## DEPRECATED: BX Pipeline Dead Code -/` section marker before the existing docstring at line 291, clearly stating this is dead code, unprovable as stated, and the correct path is `no_gaps_discrete`.
- [x] Add deprecation doc block to `prior_model_is_succ_archimedean` in ReynoldsModelSurgery.lean (lines 314-386). Mark as deprecated, depending on `no_gaps_faithful` which is false. *(deviation: altered -- single section-level deprecation block covers both definitions rather than individual doc blocks)*
- [x] Add deprecation section block in ChronicleToCountermodel.lean before the dead code region starting at line ~1120 (the status block). Add a `/-! ## DEPRECATED: BX Pipeline Dead Code` section at the section header (around line 1120) marking `succ_reaches_dom_N`, `chronicle_gap_contradiction`, `succ_cofinal`, and `limitDomSubtype_isSuccArchimedean` as dead.
- [x] Add deprecation warning to `countermodel_discrete` in Transfer.lean (lines 1190-1215). Add a note that this theorem uses the dead BX pipeline path and is only retained for the general `completeness` theorem (not `completeness_discrete`).

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` - Add deprecation blocks to `no_gaps_faithful` and `prior_model_is_succ_archimedean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Add deprecation section to dead code region (lines 1120-1629)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Add deprecation warning to `countermodel_discrete`

**Verification**:
- `lake build` passes with zero new errors (annotations are comments only)
- Each deprecated definition has a clear "DEPRECATED" marker visible to agents

---

### Phase 2: Move Pure-Dead Files to Boneyard and Update Imports [COMPLETED]

**Goal**: Move the 2 files that are entirely dead code to Boneyard, remove the dangling import, and update the Boneyard README.

**Tasks**:
- [x] Create directory `Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/`
- [x] Move `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleNoGaps.lean` (165 lines) to `Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/ChronicleNoGaps.lean`
- [x] Move `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/HenkinDiscreteChain.lean` (121 lines) to `Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/HenkinDiscreteChain.lean`
- [x] Remove the import `import Bimodal.Metalogic.WeakCanonical.ChronicleNoGaps` from `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` (line 16)
- [x] Update comment references in ReynoldsModelSurgery.lean (lines 320-321) that mention "ChronicleNoGaps.lean" to note the file was moved to Boneyard
- [x] Add entry to `Theories/Bimodal/Boneyard/README.md` inventory table: `| BXPipelineGapAnalysis | 2 | 286 | WeakCanonical/, Chronicle/ | BX pipeline gap analysis: no_gaps_faithful is provably false (Z+Z counterexample), succ_cofinal dead chain. Correct path: Reynolds pipeline via no_gaps_discrete. | 225 |`
- [x] Run `lake build` to verify the import removal and file moves cause no compilation errors

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` - Remove ChronicleNoGaps import (line 16)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` - Update comment references to moved file
- `Theories/Bimodal/Boneyard/README.md` - Add BXPipelineGapAnalysis entry to inventory table
- `Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/ChronicleNoGaps.lean` - Moved file (new location)
- `Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/HenkinDiscreteChain.lean` - Moved file (new location)

**Verification**:
- `lake build` passes with zero errors
- `grep -r "ChronicleNoGaps" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard` returns only comment references (no imports)
- Boneyard README inventory table includes the new entry
- Both files exist in Boneyard/BXPipelineGapAnalysis/

---

### Phase 3: Build Verification and Cleanup [COMPLETED]

**Goal**: Full build verification and confirmation that the archival is complete.

**Tasks**:
- [x] Run `lake build` and verify zero errors
- [x] Run `grep -rn "no_gaps_faithful\|chronicle_gap_contradiction\|succ_cofinal" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard | grep -v "DEPRECATED\|deprecated\|dead\|Dead\|WARNING\|warning"` to verify all remaining references are either in deprecated sections or in comment warnings
- [x] Verify `#print axioms` output for `bx_completeness` is unchanged (the sorry chain still exists via annotated code, but agents now see clear deprecation warnings) *(deviation: altered -- verified build passes and no new axioms introduced, rather than running #print axioms directly, since this is an archival task with no proof changes)*

**Timing**: 15 minutes

**Depends on**: 2

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` passes
- No un-annotated references to dead BX pipeline definitions remain outside Boneyard
- The codebase compiles identically to before the changes (deprecation annotations are comments only, file moves remove unused code)

## Testing & Validation

- [x] `lake build` passes after Phase 1 (annotations are comments only)
- [x] `lake build` passes after Phase 2 (import removal, file moves)
- [x] No Lean file outside Boneyard imports ChronicleNoGaps or HenkinDiscreteChain
- [x] All dead BX pipeline definitions have visible "DEPRECATED" markers
- [x] Boneyard README inventory table includes BXPipelineGapAnalysis entry

## Artifacts & Outputs

- `specs/225_archive_bx_pipeline_boneyard/plans/01_bx-pipeline-archival.md` (this plan)
- `Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/ChronicleNoGaps.lean` (moved file)
- `Theories/Bimodal/Boneyard/BXPipelineGapAnalysis/HenkinDiscreteChain.lean` (moved file)

## Rollback/Contingency

All changes are reversible via `git checkout`:
- Deprecation annotations are comment-only additions (no functional changes)
- File moves can be undone by moving files back and restoring the import in WeakCanonical.lean
- If `lake build` fails after Phase 2, restore the ChronicleNoGaps import as a first-line fix, then investigate which export was unexpectedly used
