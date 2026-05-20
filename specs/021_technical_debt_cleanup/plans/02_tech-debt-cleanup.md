# Implementation Plan: Task #21

- **Task**: 21 - Clean up technical debt from tasks 9-20
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: reports/03_archive-delete-audit.md
- **Artifacts**: plans/02_tech-debt-cleanup.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Clean up the remaining technical debt from the metalogic refactoring track (tasks 9-20) that is not covered by sibling tasks. Task 130 handles BXCanonical pipeline dead-code sorries (including RootScopedChain.lean archival). Task 173 handles TemporalDerived.lean sorry stubs. Task 172 handles the Metalogic.lean docstring rewrite. This plan covers the residual scope: archive two dead Algebraic files to Boneyard (removing 5 sorries from the build path), fix stale docstrings in Bundle/ files that reference superseded approaches, correct ghost file references in Algebraic/ parametric files, and update two README files with accurate module information.

### Research Integration

Key findings from reports/03_archive-delete-audit.md:
- `Algebraic/UltrafilterFrame.lean` (1,182 lines, 2 sorries) is commented out of the import chain with no active callers and elaboration conflicts preventing re-activation. Candidate for Boneyard archival.
- `Algebraic/TenseS5Algebra.lean` (365 lines, 3 sorries for removed axioms) must follow UltrafilterFrame if archived, as its only consumer is that file. Currently on the live build path via `Algebraic.lean`, adding 3 sorries.
- 6 Bundle/ files contain stale docstrings referencing SuccChain, DenseTask, TemporalCoherentConstruction, and DovetailingChain -- all superseded or archived approaches.
- 3 Algebraic/ parametric files reference a ghost file `CanonicalConstruction.lean` that does not exist.
- `Algebraic/README.md` falsely marks TenseS5Algebra.lean as sorry-free.
- `Metalogic/README.md` and `Bundle/README.md` both have stale module trees and phantom directory entries.

### Prior Plan Reference

The prior plan (plans/01_tech-debt-cleanup-plan.md, 5.5 hours) focused primarily on axiom elimination -- replacing axioms with proofs in SuccChainFMCS.lean and SuccExistence.lean. That scope has been superseded by the task decomposition into tasks 130, 172, and 173. Effort calibration from the prior plan: individual file operations take 30-45 minutes; docstring updates are low-risk and batch well. The prior plan's Phase 6 (documentation cleanup) is closest to this plan's scope.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Archive `Algebraic/UltrafilterFrame.lean` and `Algebraic/TenseS5Algebra.lean` to Boneyard, removing 5 sorries from the live build path
- Fix stale docstrings in 6 Bundle/ files that reference superseded approaches (SuccChain, DenseTask, TemporalCoherentConstruction, DovetailingChain)
- Correct ghost file references to `CanonicalConstruction.lean` in 3 Algebraic/ parametric files
- Update `Algebraic/README.md` and `Metalogic/README.md` and `Bundle/README.md` with accurate module information

**Non-Goals**:
- Archiving BXCanonical/RootScopedChain.lean (task 130 scope)
- Archiving TemporalDerived.lean sorry stubs (task 173 scope)
- Rewriting Metalogic.lean docstring (task 172 scope)
- Proving or eliminating axioms (prior plan scope, now decomposed into other tasks)
- Restructuring directory hierarchy (task 176 scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing TenseS5Algebra.lean import from Algebraic.lean breaks downstream code | H | L | Run `lake build` after removal; the file only provides STSA typeclass used inside UltrafilterFrame.lean which is also being removed |
| UltrafilterFrame.lean needed for future task 125 (Jonsson-Tarski) | M | L | Archive to Boneyard rather than delete; code remains in git history |
| Docstring line numbers shifted since research report | L | M | Verify line numbers before editing; use grep to locate exact content |
| Stale docstring updates introduce incorrect architecture descriptions | M | L | Cross-reference actual file paths and current callers before writing replacements |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Archive Algebraic Dead Code to Boneyard [COMPLETED]

**Goal**: Move UltrafilterFrame.lean and TenseS5Algebra.lean to Boneyard, removing 5 sorries from the live build path.

**Tasks**:
- [x] Create `Theories/Bimodal/Boneyard/UltrafilterFrame/` directory
- [x] Move `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` to `Theories/Bimodal/Boneyard/UltrafilterFrame/UltrafilterFrame.lean`
- [x] Move `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` to `Theories/Bimodal/Boneyard/UltrafilterFrame/TenseS5Algebra.lean`
- [x] Add tombstone comment at top of each archived file *(deviation: altered -- used file-specific tombstone comments instead of identical text for both)*
- [x] Remove import of TenseS5Algebra from `Algebraic/Algebraic.lean`
- [x] Remove commented-out import of UltrafilterFrame from `Algebraic/Algebraic.lean`
- [x] Add entry to `Theories/Bimodal/Boneyard/README.md` for UltrafilterFrame subdirectory
- [x] Update `Algebraic/README.md`: change TenseS5Algebra from "Sorry-free" to "Archived", note both files archived, also fixed AlgebraicRepresentation->AlgebraicCompleteness rename and ParametricRepresentation->ParametricCompleteness
- [x] Run `lake build` to verify no errors (1647 jobs, build succeeded)

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` -- move to Boneyard
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` -- move to Boneyard
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` -- remove imports
- `Theories/Bimodal/Boneyard/README.md` -- add archive entry
- `Theories/Bimodal/Metalogic/Algebraic/README.md` -- fix sorry status, note archival

**Verification**:
- `lake build` passes with no new errors
- `grep -r "TenseS5Algebra\|UltrafilterFrame" Theories/Bimodal/Metalogic/` returns no active imports
- Boneyard/UltrafilterFrame/ contains both files with tombstone comments

---

### Phase 2: Fix Stale Docstrings in Bundle/ Files [COMPLETED]

**Goal**: Update 6 Bundle/ files that reference superseded approaches (SuccChain, DenseTask, TemporalCoherentConstruction, DovetailingChain) to accurately describe the current architecture.

**Tasks**:
- [x] `Bundle/FMCSDef.lean` (lines 17-31): Replaced TimelineQuot/SuccChainFMCS references with current implementations (BXCanonical, Chronicle, Algebraic/Parametric)
- [x] `Bundle/TemporalContent.lean` (lines 33-82): Removed references to TemporalCoherentConstruction.lean, DovetailingChain.lean, and DenseTask. Updated usage comments.
- [x] `Bundle/TemporalCoherence.lean` (line 287): Replaced SuccChainFMCS comparison with BXCanonical chain construction explanation
- [x] `Bundle/Construction.lean` (lines 23, 90): Replaced TemporalCoherentConstruction.lean references with BXCanonical paths
- [x] `Bundle/WitnessSeed.lean` (line 14): Removed DovetailingChain.lean reference
- [x] `Bundle/SuccRelation.lean` (line 25): Removed stale task number references; described role in current architecture

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` -- update domain examples and architecture references
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- remove dead approach references
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` -- update comparison context
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` -- fix active chain reference
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- fix provenance
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` -- remove stale task refs

**Verification**:
- `grep -rn "SuccChainFMCS\|TemporalCoherentConstruction\|DovetailingChain\|DenseTask" Theories/Bimodal/Metalogic/Bundle/` returns no hits in docstrings (only in Boneyard paths if any)
- `lake build` passes (docstrings are in comments, so build should not be affected, but verify)

---

### Phase 3: Fix Ghost File References in Algebraic/ [COMPLETED]

**Goal**: Replace all references to the non-existent `CanonicalConstruction.lean` in parametric Algebraic/ files with the correct current file paths.

**Tasks**:
- [x] `Algebraic/ParametricCanonical.lean` (lines 33, 38): Replaced CanonicalConstruction.lean references with Bundle/CanonicalFrame.lean and Bundle/CanonicalTaskRelation.lean
- [x] `Algebraic/ParametricTruthLemma.lean` (line 62): Replaced CanonicalConstruction.lean reference with Bundle/FMCS.lean and Bundle/CanonicalFrame.lean
- [x] `Algebraic/ParametricTruthLemma.lean` (line 77): Replaced CanonicalConstruction.lean in references with Bundle/CanonicalFrame.lean
- [x] `Algebraic/ParametricHistory.lean` (line 30): Replaced CanonicalConstruction.lean (to_history) with Bundle/CanonicalFrame.lean

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` -- fix 2 ghost refs
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- fix 2 ghost refs
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` -- fix 1 ghost ref

**Verification**:
- `grep -rn "CanonicalConstruction" Theories/Bimodal/Metalogic/Algebraic/` returns no hits
- Referenced replacement files (`Bundle/CanonicalFrame.lean`, `Bundle/CanonicalTaskRelation.lean`, `Bundle/FMCS.lean`) actually exist

---

### Phase 4: Update README Files [COMPLETED]

**Goal**: Bring `Metalogic/README.md` and `Bundle/README.md` in line with the actual directory structure and module inventory.

**Tasks**:
- [x] `Metalogic/README.md` (lines 52-83): Updated module structure -- replaced with actual Bundle/ files, renamed AlgebraicRepresentation to AlgebraicCompleteness, added BXCanonical/WeakCanonical/Algebraic parametric modules
- [x] `Metalogic/README.md` (lines 260-266): Replaced phantom subdirectory entries with actual directories (Core, Bundle, BXCanonical, WeakCanonical, Decidability, Algebraic, ConservativeExtension, Relational)
- [x] `Bundle/README.md` (lines 51-53): Replaced architecture tree with actual file inventory
- [x] `Bundle/README.md` (line 64): Replaced CanonicalConstruction.lean in theorem table with CanonicalFrame.lean and CanonicalTaskRelation.lean
- [x] `Bundle/README.md` (lines 152-153): Replaced stale import comments with current imports

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` -- fix module tree and subdirectory table
- `Theories/Bimodal/Metalogic/Bundle/README.md` -- fix architecture tree, theorem table, usage snippet

**Verification**:
- All files listed in README module trees actually exist on disk
- No phantom directory entries remain in subdirectory tables
- `grep -n "CanonicalConstruction\|CanonicalFMCS\|ChainFMCS\|SuccChainFMCS\|AlgebraicRepresentation" Theories/Bimodal/Metalogic/README.md Theories/Bimodal/Metalogic/Bundle/README.md` returns no hits

---

## Testing & Validation

- [ ] `lake build` passes after Phase 1 (critical -- this phase modifies imports)
- [ ] `lake build` passes after all phases complete (belt-and-suspenders check)
- [ ] No references to `CanonicalConstruction.lean` remain in active `Metalogic/` files
- [ ] No references to `SuccChainFMCS`, `TemporalCoherentConstruction`, `DovetailingChain`, or `DenseTask` remain in Bundle/ docstrings
- [ ] `Algebraic/README.md` accurately reflects sorry status of remaining files
- [ ] Boneyard/UltrafilterFrame/ directory exists with both archived files and tombstone comments
- [ ] Boneyard/README.md has an entry for UltrafilterFrame archival

## Artifacts & Outputs

- `plans/02_tech-debt-cleanup.md` (this file)
- `summaries/02_tech-debt-cleanup-summary.md` (upon completion)

## Rollback/Contingency

Phase 1 is the only phase that modifies code (import removal and file moves). If `lake build` fails after Phase 1:
1. Restore `TenseS5Algebra` import in `Algebraic/Algebraic.lean`
2. Move files back from Boneyard to Algebraic/
3. Investigate which downstream code depends on the removed imports
4. Create a narrower archival scope (archive only UltrafilterFrame, keep TenseS5Algebra with sorry annotations)

Phases 2-4 are pure docstring/README edits with zero build risk. If any edit introduces incorrect information, revert the specific file via `git checkout -- <file>`.
