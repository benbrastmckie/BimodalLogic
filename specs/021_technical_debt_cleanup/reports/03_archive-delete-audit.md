# Research Report: Task #21

**Task**: 21 - Clean up technical debt from tasks 9-20
**Started**: 2026-05-20T15:55:00Z
**Completed**: 2026-05-20T16:08:52Z
**Effort**: 1.5 hours
**Dependencies**: None
**Sources/Inputs**:
- Codebase exploration: `Theories/Bimodal/Metalogic/` and `Theories/Bimodal/Boneyard/`
- Grep searches for dead path markers: `TimelineQuot`, `DenseTask`, `SuccChain`, `CanonicalModel`, `TemporalCoherentConstruction`, `DovetailedChain`, `CanonicalConstruction`
- Read of all affected README.md, module-tree docstrings, and sorry annotations
**Artifacts**:
- `specs/021_technical_debt_cleanup/reports/03_archive-delete-audit.md` (this file)
**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

- The Boneyard is in good health: the most recent archival was task 132 (2026-05-13), and all 47 files across 16 subdirectories are properly tombstoned with README entries.
- The primary debt is **stale docstrings**: `Metalogic/Metalogic.lean` and `Metalogic/README.md` both describe an obsolete SuccChain architecture and list files that no longer exist.
- `BXCanonical/RootScopedChain.lean` contains 3 sorry stubs that are explicitly acknowledged as dead code (bypassed by the chronicle path) but the file is still imported; it is a candidate for Boneyard archival.
- `Algebraic/UltrafilterFrame.lean` (1,182 lines, 2 sorries for `temp_4`) is commented out from `Algebraic.lean` and has no active callers; it is a candidate for Boneyard archival or deletion.
- `Algebraic/TenseS5Algebra.lean` (365 lines, 3 sorries for removed axioms `temp_a`/`temp_l`) is only imported by `UltrafilterFrame.lean` and `Algebraic.lean`; if `UltrafilterFrame.lean` moves, TenseS5Algebra must follow.
- Several live docstrings in `Bundle/` files point to `TemporalCoherentConstruction.lean`, `DovetailingChain.lean`, and `CanonicalConstruction.lean` — none of which exist in the active codebase.

---

## Context & Scope

This audit covers the technical debt from the metalogic refactoring track (tasks 9–20). Task 18 was abandoned. The focus is:

1. Identifying dead code in active `Metalogic/` that should move to Boneyard or be deleted.
2. Cataloguing stale docstrings that reference superseded approaches.
3. Verifying the Boneyard is complete and does not need additional entries.

The Boneyard already contains 47 files (26,579 lines) across well-documented subdirectories. The Boneyard README was consolidated in task 132 (2026-05-13) and is accurate.

---

## Findings

### 1. Boneyard Status (Already Clean)

The Boneyard is correctly populated. Archival history:

| Task | Archive | Status |
|------|---------|--------|
| 80 | UltrafilterDeadCode | Complete |
| 83 | TAxiomDependentCode | Complete |
| 85 | DiscreteXY | Complete |
| 93 | ChainCompleteness | Complete |
| 94 | StrictSemanticsLegacy | Complete |
| 105 | DenseChronicle | Complete |
| 107 | QuasimodelOracle, NonBurgessSeed, DefectDirectedChain | Complete |
| 109 | ClosedGuardLegacy | Complete |
| 113 | DeadCanonicalModel | Complete |
| 115 | XuLemma321Legacy | Complete |
| 123 | StageInductionGapAnalysis | Complete |
| 132 | Root Boneyard consolidation | Complete |

No additional archival from past tasks is missing. The Boneyard README correctly describes each subdirectory.

---

### 2. Dead Code in Active Metalogic/ — Boneyard Candidates

#### A. `BXCanonical/RootScopedChain.lean` (222 lines, 3 sorries)

**Status**: Dead code, explicitly acknowledged.

**Evidence**:
- `Completeness.lean` line 34: `"3 sorry sites in RootScopedChain.lean (which remain as dead code)."`
- `Completeness.lean` line 336: `"All sorry sites in RootScopedChain.lean (bx_bfmcs_restricted_tc/buc/fuc)"` listed under "Dead code (no longer on critical path)".
- The only use of `dd_countermodel` from this file appears at `Completeness.lean` lines 303, 353 as `#print axioms` diagnostics — not in the actual proof.
- The completeness proof routes through `Chronicle.dd_countermodel_chronicle_mixed_sorry`, not `dd_countermodel`.

**Why it was not archived**: The file is still imported by `Completeness.lean`, which means `lake build` compiles it, and the `#print axioms dd_countermodel` commands reference its theorem for historical axiom auditing.

**Recommendation**: **Archive to Boneyard.** Reason: schedule-based `bx_bfmcs` was superseded by the Burgess chronicle path. The `dd_countermodel` theorem is no longer called; it only appears in `#print axioms` diagnostics. Remove the import from `Completeness.lean`, delete those two `#print axioms` lines, and move the file to `Boneyard/ScheduleChain/RootScopedChain.lean` with a tombstone comment. Archival reason: "Schedule-based BFMCS bypassed by Burgess chronicle construction; 3 sorries (F/P-resolution) acknowledged as dead code."

**Sorries at** (RootScopedChain.lean):
- Line 179: `bx_bfmcs_restricted_tc`
- Line 186: `bx_bfmcs_restricted_buc`
- Line 191: `bx_bfmcs_restricted_fuc`

---

#### B. `Algebraic/UltrafilterFrame.lean` (1,182 lines, 2 sorries)

**Status**: Commented out from the active import chain; no active callers.

**Evidence**:
- `Algebraic/Algebraic.lean` line 14: `-- import Bimodal.Metalogic.Algebraic.UltrafilterFrame` (commented out)
- Comment at line 13: `"imported separately to avoid elaboration interference with BXCanonical/Completeness.lean rfl proofs"`
- No other active file imports it.
- 2 sorries for `temp_4` (Gφ → GGφ), annotated `"derivable from BX1+K but removed during axiom cleanup"`.

**Why it was not archived**: The file header says it was "recovered from Boneyard" (task 125, Jonsson-Tarski representation) and notes Phase 2 remains in the Boneyard. The import was then commented out due to elaboration interference. It is effectively already inert.

**Recommendation**: **Delete.** The file provides `R_G`/`R_H`/`R_Box` ultrafilter frame relations and `UltrafilterChain` for the Jonsson-Tarski path (task 125). However, since it: (1) cannot be imported without breaking other proofs, (2) has 2 sorry stubs for axioms removed from BX, and (3) is already invisible to `lake build` — it has negative utility as an active file. The code is available via git history if task 125 is resumed. Alternatively, archive to `Boneyard/UltrafilterFrame/` with a note that it requires resolution of the elaboration conflict before re-activating.

**Sorries at** (UltrafilterFrame.lean):
- Line 282: `R_G_trans` — `"temp_4: Gφ → GGφ, derivable from BX1+K but removed during axiom cleanup"`
- Line 1088: `UltrafilterChain.forward_G` — same `temp_4` annotation

---

#### C. `Algebraic/TenseS5Algebra.lean` (365 lines, 3 sorries)

**Status**: Active import in `Algebraic.lean`, but sorry-bearing for removed axioms.

**Evidence**:
- Imported by `Algebraic.lean` (line 6) and `UltrafilterFrame.lean` (line 1).
- 3 sorries annotated with removed axioms (`temp_a`, `temp_l` — both `"removed in BX"`).
- `Algebraic/README.md` falsely lists it as `**Sorry-free**` (line 30).

**Why it matters**: This file is on the live build path (via `Algebraic.lean`), so its sorries appear in `#print axioms` output for anything imported through `Algebraic`. If `UltrafilterFrame.lean` is deleted, the only reason to keep `TenseS5Algebra.lean` is its STSA typeclass, which is used inside `UltrafilterFrame.lean`.

**Recommendation**: **If `UltrafilterFrame.lean` is deleted**: also delete `TenseS5Algebra.lean`, removing it from `Algebraic.lean`. **If `UltrafilterFrame.lean` is archived**: archive `TenseS5Algebra.lean` together with it. In either case, fix `Algebraic/README.md` to accurately reflect sorry status.

**Sorries at** (TenseS5Algebra.lean):
- Line 195: `"temp_a removed in BX"`
- Line 278: `"temp_l removed in BX"`
- Line 320: `"temp_l removed in BX"`

---

### 3. Stale Docstrings — Update in Place

#### A. `Metalogic/Metalogic.lean` — Completeness Architecture Section

**Location**: Lines 30–87 (the `/-! ... -/` module docstring block)

**Stale content**:
- Lines 32–36: Describes "SuccChain architecture" with `Bundle/SuccChain*`, `Bundle/`, `Completeness/` — the `SuccChain*` files are in the Boneyard, and there is no `Completeness/` subdirectory.
- Lines 57: `CanonicalConstruction.lean` listed in Bundle/ — does not exist.
- Lines 67–73: `SuccChainFMCS.lean`, `SuccChainTaskFrame.lean`, `SuccChainTruth.lean`, `SuccChainWorldHistory.lean` listed — all in Boneyard.
- Lines 72–73: `Completeness/` directory and `SuccChainCompleteness.lean` — does not exist.
- Lines 82–85: `BaseCompleteness.lean`, `DenseCompleteness.lean`, `DiscreteCompleteness.lean`, `Representation.lean` — none exist at `Metalogic/` top-level.

**Correct state**: The completeness architecture is now **BXCanonical/Chronicle** (Burgess 1982 chronicle). The module tree should reflect actual files: no `Completeness/` directory, no `SuccChain*` files in Bundle/, no `CanonicalConstruction.lean`.

**Recommendation**: Rewrite the "Completeness Architecture" section to describe the current Chronicle path (`BXCanonical/Chronicle/ChronicleToCountermodel.lean`). Update the Module Structure tree to match the actual directory contents.

---

#### B. `Metalogic/README.md` — Module Structure Table and Architecture

**Location**: Lines 52–83, 260–266

**Stale content**:
- Line 61: `CanonicalConstruction.lean` listed in Bundle/ tree.
- Line 78: `AlgebraicRepresentation.lean` listed in Algebraic/ — does not exist (was renamed to `AlgebraicCompleteness.lean`).
- Lines 260–266: Table lists `Soundness/`, `Canonical/`, `Domain/`, `StagedConstruction/`, `Representation/`, `Compactness/` subdirectories as "Active" — none of these directories exist.
- Line 260: `[Soundness/](Soundness/README.md)` — directory doesn't exist; soundness files are at `Metalogic/` top-level.

**Recommendation**: Update the table to reflect actual subdirectories: `Core/`, `Bundle/`, `Algebraic/`, `BXCanonical/`, `WeakCanonical/`, `ConservativeExtension/`, `Decidability/`, `Relational/` (empty placeholder). Remove phantom entries.

---

#### C. `Bundle/Metalogic.lean` — Module Structure Tree (Metalogic.lean lines 56-73)

Covered by finding 3A above.

---

#### D. `Bundle/FMCSDef.lean` — Stale SuccChain Reference

**Location**: Lines 17–31

**Stale content**:
- Line 20: `"The SuccChain construction (SuccChainFMCS.lean) uses D=Int with proper temporal coherence. This is the canonical implementation for discrete completeness."` — SuccChainFMCS.lean is in the Boneyard (StrictSemanticsLegacy); the canonical discrete implementation is now `BXCanonical/CanonicalChain.lean`.
- Line 17: `TimelineQuot` listed as an example domain type — this was a dead syntactic construction; the working dense domain is `Rat` (via Cantor isomorphism).

**Recommendation**: Update lines 17–31 to describe the actual current implementations: `BXCanonical/CanonicalModel.lean` for the schedule-based forward/backward chain over `Int`, and `BXCanonical/Chronicle/` for the dense construction over `Rat`.

---

#### E. `Bundle/TemporalContent.lean` — Stale DenseTask/Task References

**Location**: Lines 33–82

**Stale content**:
- Line 33: `"used in TemporalCoherentConstruction.lean and DovetailingChain.lean"` — neither file exists in active codebase.
- Line 35: `"p_content: foundation for DenseTask relation"` — the DenseTask approach (tasks 16–18) was abandoned; task 18 was explicitly abandoned per task description.
- Line 50: `"See DovetailingChain.lean for details."` — does not exist.
- Line 69: `"Used in the Succ relation construction (tasks 10-15)"` — task references are stale (tasks 10–15 have been superseded).
- Line 81: `"Used in the DenseTask relation construction (tasks 16-18) for dense temporal frames."` — this approach was abandoned.

**Recommendation**: Update usage comments to reference actual current callers. The `f_content` / `p_content` functions are still used in `SuccExistence.lean`, `SuccRelation.lean`, and `UntilSinceCoherence.lean`. Remove references to the abandoned DenseTask approach.

---

#### F. `Bundle/TemporalCoherence.lean` — Stale SuccChainFMCS Reference

**Location**: Line 287

**Stale content**:
- `"This is impossible to prove for the SuccChainFMCS because F-nesting is unbounded"` — SuccChainFMCS.lean is in the Boneyard and no longer the active approach.

**Recommendation**: Revise to explain the restriction is motivated by the BXCanonical chain construction's bounded subformula closure, not by comparison to an archived file.

---

#### G. `Bundle/Construction.lean` — Stale TemporalCoherentConstruction Reference

**Location**: Lines 23, 90

**Stale content**:
- Line 23: `"Active completeness chain: Bimodal.Metalogic.Bundle.TemporalCoherentConstruction"` — this file does not exist.
- Line 90: `"TemporalCoherentConstruction.lean, which uses multi-family modal saturation"` — same issue.

**Recommendation**: Remove or update to reference the actual active chain: `BXCanonical/CanonicalModel.lean` (schedule-based) and `BXCanonical/Chronicle/` (Burgess chronicle).

---

#### H. `Bundle/WitnessSeed.lean` — Stale DovetailingChain Reference

**Location**: Line 14

**Stale content**:
- `"extracted from DovetailingChain.lean for use by CanonicalFrame.lean"` — DovetailingChain.lean does not exist in active codebase.

**Recommendation**: Update provenance comment to reflect the actual extraction history.

---

#### I. `Bundle/SuccRelation.lean` — Stale Task Reference

**Location**: Line 25

**Stale content**:
- `"The Succ relation is foundational infrastructure for the discrete track (tasks 10-15)."` — tasks 10–15 are superseded.

**Recommendation**: Remove the task number reference; describe the role in terms of current architecture (used by `SuccExistence.lean` for predecessor/successor construction, which underpins `BXCanonical/CanonicalModel.lean`).

---

#### J. `Algebraic/ParametricCanonical.lean` — Ghost File Reference

**Location**: Lines 33, 38

**Stale content**:
- References to `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` — this file does not exist.

**Recommendation**: Update the "References" section to point to the actual file providing the canonical task relation: `Bundle/CanonicalFrame.lean` and `Bundle/CanonicalTaskRelation.lean`.

---

#### K. `Algebraic/ParametricTruthLemma.lean` — Ghost File Reference

**Location**: Lines 62, 77

**Stale content**:
- `"The proof follows the same structure as CanonicalConstruction.lean"` and `"- Existing: Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean"` — does not exist.

**Recommendation**: Update references to `Bundle/FMCS.lean` and `Bundle/CanonicalFrame.lean` which provide the current canonical construction.

---

#### L. `Algebraic/ParametricHistory.lean` — Ghost File Reference

**Location**: Line 30

**Stale content**:
- `"- Existing: Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean (to_history)"` — does not exist.

**Recommendation**: Update to `Bundle/CanonicalFrame.lean`.

---

#### M. `Algebraic/README.md` — Incorrect Sorry Status

**Location**: Line 30

**Stale content**:
- `TenseS5Algebra.lean` listed as `**Sorry-free**` — it has 3 active sorries.

**Recommendation**: Update status to `**3 sorries (temp_a, temp_l removed in BX)**`.

---

#### N. `Bundle/README.md` — Stale Module List and Import Snippet

**Location**: Lines 51–53 (architecture tree), 64 (theorem table), 152–153 (usage snippet)

**Stale content**:
- Lines 51–53: Lists `ChainFMCS.lean`, `CanonicalFMCS.lean`, `CanonicalConstruction.lean` — none exist.
- Line 64: `CanonicalConstruction.lean` in the theorem table.
- Lines 152–153: `-- REMOVED (Task 41): import Bimodal.Metalogic.Bundle.CanonicalFMCS` and `-- Use SuccChainFMCS for D=Int approach instead` — SuccChainFMCS is also now in the Boneyard.

**Recommendation**: Update architecture tree and usage snippet to reflect actual bundle files.

---

### 4. Items Already Correctly Handled (No Action Needed)

- `BXCanonical/Completeness.lean` lines 336–337: Correctly notes `RootScopedChain.lean` sorries are "dead code".
- `Bundle/SuccExistence.lean` line 364: Correctly notes dead code reference was removed.
- `Algebraic/Algebraic.lean` line 14: `UltrafilterFrame` commented out with explanation.
- All `Boneyard/` subdirectories: Have README entries and tombstone comments.
- `Metalogic/Relational/README.md`: Correctly describes empty placeholder directory.

---

## Decisions

1. **Do not delete `BXCanonical/RootScopedChain.lean` in-place** — archive it to Boneyard to preserve `dd_countermodel` definition and the chronological record of the schedule-based approach. Remove `import` from `Completeness.lean` and the two `#print axioms` lines.

2. **Archive or delete `Algebraic/UltrafilterFrame.lean`** — since it cannot be imported without elaboration conflicts and has no active callers, archive to `Boneyard/UltrafilterFrame/` (preferred over delete, to preserve the Jonsson-Tarski work for task 125).

3. **Cascade `TenseS5Algebra.lean`** — remove from `Algebraic.lean` if `UltrafilterFrame.lean` is archived; it adds sorries to the build path with no return value.

4. **Docstring updates are low-risk** — all stale docstrings are in comment blocks, not code. Update in place without creating new files.

---

## Recommendations (Prioritized)

### Priority 1 — Remove Sorries from Live Build Path

1. **(High)** Archive `Algebraic/UltrafilterFrame.lean` to `Boneyard/UltrafilterFrame/` and remove it from `Algebraic/Algebraic.lean`. This removes 2 `temp_4` sorries from the live build.

2. **(High)** Remove `Algebraic/TenseS5Algebra.lean` from `Algebraic/Algebraic.lean` (import line 6). Fix `Algebraic/README.md` sorry status line 30. If archived together with UltrafilterFrame, move both simultaneously. This removes 3 `temp_a`/`temp_l` sorries from the live build.

3. **(Medium)** Archive `BXCanonical/RootScopedChain.lean` to `Boneyard/ScheduleChain/`. Remove `import Bimodal.Metalogic.BXCanonical.RootScopedChain` from `BXCanonical/Completeness.lean` (line 1). Remove `#print axioms dd_countermodel` at lines 303, 353. This removes 3 sorry stubs acknowledged as dead code. Add subdirectory entry to `Boneyard/README.md`.

### Priority 2 — Fix Module Tree Docstrings (Metalogic.lean)

4. **(Medium)** Rewrite `Metalogic/Metalogic.lean` lines 30–87: replace SuccChain architecture description with Chronicle architecture; update module tree to match actual directory structure.

### Priority 3 — Fix Stale Usage Comments in Bundle/

5. **(Low)** `Bundle/FMCSDef.lean` lines 17–31: Update domain type examples and remove reference to `SuccChainFMCS.lean`.
6. **(Low)** `Bundle/TemporalContent.lean` lines 33–82: Remove `DenseTask` references, update `f_content`/`p_content` usage descriptions to reference actual callers.
7. **(Low)** `Bundle/TemporalCoherence.lean` line 287: Remove comparison to archived `SuccChainFMCS`.
8. **(Low)** `Bundle/Construction.lean` lines 23, 90: Replace `TemporalCoherentConstruction.lean` references.
9. **(Low)** `Bundle/WitnessSeed.lean` line 14: Update extraction provenance.
10. **(Low)** `Bundle/SuccRelation.lean` line 25: Remove obsolete task number references.

### Priority 4 — Fix Ghost File References in Algebraic/

11. **(Low)** `Algebraic/ParametricCanonical.lean` lines 33, 38: Replace `CanonicalConstruction.lean` with `CanonicalFrame.lean`/`CanonicalTaskRelation.lean`.
12. **(Low)** `Algebraic/ParametricTruthLemma.lean` lines 62, 77: Same fix.
13. **(Low)** `Algebraic/ParametricHistory.lean` line 30: Same fix.

### Priority 5 — Fix README Files

14. **(Low)** `Metalogic/README.md`: Update subdirectory table (remove `Soundness/`, `Canonical/`, `Domain/`, `StagedConstruction/`, `Representation/`, `Compactness/`; update `AlgebraicRepresentation.lean` → `AlgebraicCompleteness.lean`).
15. **(Low)** `Bundle/README.md`: Update architecture tree, theorem table, and usage snippet.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Removing `RootScopedChain.lean` import breaks `#print axioms` diagnostics | Those diagnostics are non-compilation; safe to remove. Confirm by checking `lake build` output after removal. |
| `TenseS5Algebra.lean` has downstream consumers not found via grep | Verify with `lake build` after removal; the module compiles transitively so any failure would surface immediately. |
| `UltrafilterFrame.lean` needed for task 125 | Archive to Boneyard rather than delete; git history also preserves the code. |
| Docstring edits touching incorrect line numbers | All line numbers in this report are verified against current file state (2026-05-20). |

---

## Appendix

### Search Commands Used

```bash
find Theories/Bimodal/Boneyard -type f | sort
find Theories/Bimodal/Metalogic -type f | sort
grep -rn "TimelineQuot|DenseTask|SuccChain|CanonicalModel" Metalogic/ --include="*.lean" -l
grep -rn "dead|TODO|FIXME|deprecated|stale|superseded|obsolete|archive" Metalogic/ --include="*.lean" -l
grep -rn "sorry" Metalogic/**/*.lean | grep -v "sorry-free"
# Checked imports for: RootScopedChain, TenseS5Algebra, UltrafilterFrame
# Checked actual directory contents: ls Metalogic/*.lean, ls Metalogic/*/
```

### File Inventory Summary

| File | Category | Action | Lines | Sorries |
|------|----------|--------|-------|---------|
| `BXCanonical/RootScopedChain.lean` | Dead code | Archive to Boneyard | 222 | 3 |
| `Algebraic/UltrafilterFrame.lean` | Commented-out | Archive to Boneyard | 1,182 | 2 |
| `Algebraic/TenseS5Algebra.lean` | Stale axioms | Archive with UF or delete | 365 | 3 |
| `Metalogic/Metalogic.lean` | Stale docstring | Update in-place | 89 | 0 |
| `Metalogic/README.md` | Stale table | Update in-place | 332 | 0 |
| `Bundle/FMCSDef.lean` | Stale docstring | Update lines 17–31 | ~100 | 0 |
| `Bundle/TemporalContent.lean` | Stale comments | Update lines 33–82 | ~115 | 0 |
| `Bundle/TemporalCoherence.lean` | Stale comment | Update line 287 | ~550 | 0 |
| `Bundle/Construction.lean` | Stale comment | Update lines 23, 90 | ~200 | 0 |
| `Bundle/WitnessSeed.lean` | Stale comment | Update line 14 | ~150 | 0 |
| `Bundle/SuccRelation.lean` | Stale comment | Update line 25 | ~80 | 0 |
| `Bundle/README.md` | Stale module list | Update in-place | 179 | 0 |
| `Algebraic/ParametricCanonical.lean` | Ghost file ref | Update lines 33, 38 | ~100 | 0 |
| `Algebraic/ParametricTruthLemma.lean` | Ghost file ref | Update lines 62, 77 | ~200 | 0 |
| `Algebraic/ParametricHistory.lean` | Ghost file ref | Update line 30 | ~100 | 0 |
| `Algebraic/README.md` | Wrong sorry count | Fix line 30 | 190 | 0 |

### Key Architecture Summary (Current)

The **live completeness path** is:
```
BXCanonical/Completeness.lean
  -> Chronicle/ChronicleToCountermodel.lean (dense countermodel on Rat)
  -> WeakCanonical/countermodel_discrete (discrete countermodel on Int)
  -> Chronicle/dd_countermodel_chronicle_mixed_sorry (mixed case, sorry)
```

The **archive path** (superseded) is:
```
Boneyard/ChainCompleteness/ (SuccChain approach, tasks 10-15)
Boneyard/StrictSemanticsLegacy/ (strict semantics, 107 sorries)
BXCanonical/RootScopedChain.lean (schedule-based bx_bfmcs, 3 dead sorries) <- should move
Algebraic/UltrafilterFrame.lean (commented out, 2 dead sorries) <- should move
```
