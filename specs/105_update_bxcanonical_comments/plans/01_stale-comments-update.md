# Implementation Plan: Update Stale BXCanonical Comments

- **Task**: 105 - Update stale sorry-blocker comments in BXCanonical code files
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None (tasks 90, 92, 98, 102 already completed)
- **Research Inputs**: specs/105_update_bxcanonical_comments/reports/01_stale-comments-audit.md
- **Artifacts**: plans/01_stale-comments-update.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Update 6 stale sorry-blocker comments across 4 BXCanonical files and 2 stale docstrings in Formula.lean. These comments reference sorry states or proof approaches that are no longer current after tasks 90, 92, 98, and 102 resolved the Frame.lean sorries and the project transitioned to irreflexive semantics. All changes are documentation-only edits with no code modifications.

### Research Integration

Research report identified 6 stale comments (Priority 1-2) across BXCanonical.lean, Completeness.lean, Frame.lean, and TruthLemma.lean, plus 2 stale X/Y operator docstrings in Formula.lean. An additional 2 minor items (Priority 3) in BXCanonical.lean:27 and Completeness.lean:28-30 are included for completeness. All findings have been integrated into this plan.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task maintains documentation accuracy for the BXCanonical completeness path described in ROADMAP.md. Updating stale comments ensures that developers working on the remaining 5 RootScopedChain.lean sorries (task 109) have accurate contextual information.

## Goals & Non-Goals

**Goals**:
- Update all 6 stale sorry-blocker comments to reflect current proof state
- Update 2 Formula.lean X/Y docstrings to not frame strict semantics as hypothetical
- Update 2 minor items (BXCanonical.lean:27 LocusControl description, Completeness.lean:28-30 countermodel reference)
- Verify `lake build` still succeeds after changes

**Non-Goals**:
- Modifying any Lean code or proofs
- Updating comments in Boneyard/ files (archived dead code)
- Updating comments that are still accurate (e.g., TruthLemma.lean:287,311)
- Resolving any actual sorry sites

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Comment edit accidentally modifies code | H | L | All edits are within comment/docstring blocks only; verify with lake build |
| Line numbers shifted since research | L | M | Verify content at target lines before editing |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Update All Stale Comments and Docstrings [NOT STARTED]

**Goal**: Edit all 8 stale comments/docstrings across 5 files

**Tasks**:
- [ ] **BXCanonical.lean:20** -- Change `(sorry for full completeness)` to `(wired through; leaf sorries in chain construction)`
- [ ] **BXCanonical.lean:27** -- Clarify LocusControl description as delegation interface
- [ ] **Frame.lean:493-494** -- Replace "For now, sorry the full modal equivalence" with note that proof is complete via S5 forward (modal_4) and backward (negative introspection)
- [ ] **Frame.lean:22** -- Update header to note bx_le_refl is sorry'd under irreflexive semantics
- [ ] **Completeness.lean:32** -- Update to mention both CanonicalModel.lean and RootScopedChain.lean as sorry locations
- [ ] **Completeness.lean:120-121** -- Update to reference `dd_countermodel` (not `bx_countermodel`), list both sorry-location files, remove "modal saturation" description
- [ ] **Completeness.lean:28-30** -- Update `bx_countermodel` reference to `dd_countermodel` if present
- [ ] **TruthLemma.lean:37** -- Update "sorry for the TaskModel construction" to reference dd_countermodel and chain coherence sorries
- [ ] **Formula.lean:328-329** -- Update X operator docstring: remove "Under discrete strict semantics" qualifier, state directly that X(phi) at t holds iff phi holds at t+1
- [ ] **Formula.lean:332-333** -- Update Y operator docstring: same pattern as X

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` -- lines 20, 27
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- lines 22, 493-494
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- lines 28-32, 120-121
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- line 37
- `Theories/Bimodal/Syntax/Formula.lean` -- lines 328-334

**Verification**:
- Each edited line contains only comment/docstring text, no code changes
- All stale references to `bx_countermodel`, "sorry the full modal equivalence", and "sorry for TaskModel construction" are removed

---

### Phase 2: Build Verification [NOT STARTED]

**Goal**: Confirm that comment-only changes do not break the build

**Tasks**:
- [ ] Run `lake build` and verify no new errors
- [ ] Spot-check that edited files have no syntax issues (docstring delimiters closed, comment prefixes intact)

**Timing**: 10 minutes

**Depends on**: 1

**Files to modify**: None (verification only)

**Verification**:
- `lake build` exits with same status as before changes
- No new warnings or errors in the 5 modified files

## Testing & Validation

- [ ] All 6 Priority 1-2 stale comments updated
- [ ] Both Formula.lean X/Y docstrings updated
- [ ] Both Priority 3 minor items addressed
- [ ] `lake build` succeeds without new errors
- [ ] No accidental code modifications (diff shows only comment/docstring lines)

## Artifacts & Outputs

- `specs/105_update_bxcanonical_comments/plans/01_stale-comments-update.md` (this plan)
- `specs/105_update_bxcanonical_comments/summaries/01_stale-comments-summary.md` (after implementation)

## Rollback/Contingency

All changes are comment/docstring-only edits. If any change causes issues, revert with `git checkout` on the individual files. No code logic is modified, so rollback risk is minimal.
