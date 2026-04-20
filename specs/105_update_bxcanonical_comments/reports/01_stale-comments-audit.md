# Research Report: Stale Sorry-Blocker Comments in BXCanonical

- **Task**: 105 - Update stale sorry-blocker comments in BXCanonical code files
- **Started**: 2026-04-20T00:00:00Z
- **Completed**: 2026-04-20T00:30:00Z
- **Effort**: Small (documentation-only changes)
- **Dependencies**: None (tasks 90, 92, 98, 102 completed)
- **Sources/Inputs**:
  - All 10 live BXCanonical files (excluding Boneyard/)
  - Quasimodel/ (6 files), Filtration/ (2 files)
  - Formula.lean X/Y docstrings
  - TODO.md task descriptions for 98, 102, 109
- **Artifacts**: This report
- **Standards**: status-markers.md, artifact-formats.md

## Executive Summary

- 6 stale comments identified across 4 files requiring updates (BXCanonical.lean, Completeness.lean, Frame.lean, TruthLemma.lean)
- 2 stale docstrings in Formula.lean (X/Y operators reference "strict semantics" as if it were a future change, but it is now the current semantics)
- Frame.lean line 493 comment says "sorry the full modal equivalence" but the proof is fully complete (lines 497-552)
- Completeness.lean header (line 32) and status block (lines 120-121) reference "remaining leaf sorries" that are still accurate for CanonicalModel.lean -- these are NOT stale
- BXCanonical.lean line 20 says "sorry for full completeness" which is partially stale -- the proof is wired through but leaf sorries remain
- No stale references found in Boneyard/ files (those are archived dead code, comments are historically accurate)

## Context & Scope

Task 105 asks to audit all BXCanonical files for stale sorry-related comments after the completion of tasks 90, 92, 98, and 102, which closed the 4 original Frame.lean sorries (Until/Since eventuality resolution and modal equivalence). The project now uses irreflexive semantics (strict `<` ordering).

## Findings

### Finding 1: BXCanonical.lean line 20 -- STALE

**File**: `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean`
**Line 20**: `3. \`Completeness.lean\` — BX completeness theorem (sorry for full completeness)`

**Status**: Stale. The completeness theorem itself (`bx_completeness`) is wired through `dd_countermodel` without sorry at the top level. The leaf sorries are in CanonicalModel.lean and RootScopedChain.lean (chain construction, task 109 scope). The parenthetical should be updated to reflect the actual situation.

**Recommended update**: `3. \`Completeness.lean\` — BX completeness theorem (wired through; leaf sorries in chain construction)`

### Finding 2: BXCanonical.lean line 27 -- Minor staleness

**File**: `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean`
**Line 27**: `- \`LocusControl.lean\` — Locus-control and sorry-closure interface`

**Status**: This is accurate but could benefit from clarification that these are delegation interfaces, not sorry sites themselves. Low priority.

### Finding 3: Frame.lean line 493 comment -- STALE

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`
**Lines 493-494**:
```
-- This is the hardest part of modal canonical models. For now, sorry the
-- full modal equivalence and prove the forward direction.
```

**Status**: STALE. The full modal equivalence proof is complete (lines 497-552). Both directions are proved: forward via modal_4 (line 500-509), backward via S5 negative introspection (lines 510-551). No sorry is used. The comment is a leftover from when the proof was incomplete.

**Recommended update**: Remove or replace with something like:
```
-- Full modal equivalence proved via S5: forward uses modal_4,
-- backward uses negative introspection (¬□φ → □(¬□φ)).
```

### Finding 4: Frame.lean line 22 -- Minor staleness

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`
**Line 22**: `- \`bx_le_refl\`: Reflexivity (from BX1: G(φ) → φ)`

**Status**: Under irreflexive semantics, BX1 (G(φ) -> φ) was removed. `bx_le_refl` at line 202-205 is sorry'd with the comment "Under irreflexive semantics, bx_le is NOT reflexive." The header doc still lists this as a main definition. It should note that reflexivity no longer holds and the lemma is sorry'd (or dead code).

### Finding 5: Completeness.lean lines 32, 120-121 -- Partially stale

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`
**Line 32**: `Remaining leaf sorries are in CanonicalModel.lean (temporal coherence proofs).`
**Lines 120-121**: `**Status**: Proof completed via \`bx_countermodel\`. Remaining leaf sorries are in CanonicalModel.lean (temporal coherence, modal saturation).`

**Status**: Partially stale.
- The proof now goes through `dd_countermodel` (RootScopedChain.lean), not `bx_countermodel` (which was removed as dead code per CanonicalModel.lean lines 459-472).
- Leaf sorries are in BOTH CanonicalModel.lean (6 sorry sites) AND RootScopedChain.lean (5 sorry sites, including chain coherence).
- "modal saturation" is not an accurate description of the remaining sorries.

**Recommended update**: Reference `dd_countermodel` and list both files as sorry locations. Mention that task 109 tracks these.

### Finding 6: TruthLemma.lean line 37 -- STALE

**File**: `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean`
**Line 37**: `The completeness theorem is stated with sorry for the TaskModel construction.`

**Status**: STALE. The completeness theorem is no longer stated with sorry for TaskModel construction. It uses `dd_countermodel` which constructs the countermodel. The sorry sites are in the chain coherence proofs, not the TaskModel construction.

### Finding 7: TruthLemma.lean lines 287, 311 -- Accurate (not stale)

**Lines 287, 311**: `This lemma is sorry'd pending redesign.`

**Status**: ACCURATE. `until_backward_refl_mcs` (line 291-292) and `since_backward_refl_mcs` (line 315-316) are both sorry'd. Under irreflexive semantics, psi -> (phi U psi) and psi -> (phi S psi) are not axiomatically valid. These are correctly documented.

### Finding 8: Formula.lean lines 328-334 -- STALE docstrings

**File**: `Theories/Bimodal/Syntax/Formula.lean`
**Lines 328-329**: `/-- Next-step operator: X(phi) = bot U phi. Under discrete strict semantics, X(phi) at t means phi holds at t+1. -/`
**Lines 332-333**: `/-- Previous-step operator: Y(phi) = bot S phi. Under discrete strict semantics, Y(phi) at t means phi holds at t-1. -/`

**Status**: STALE phrasing. The project now uses irreflexive (strict) semantics as the primary semantics. The docstrings say "Under discrete strict semantics" as if this were a hypothetical or alternative mode. They should state this is the standard semantics, or simply describe the operator without qualifying it.

**Recommended update**:
```
/-- Next-step operator: X(phi) = bot U phi.
    X(phi) at t holds iff phi holds at the immediate successor t+1. -/
```

### Finding 9: Additional sorry-related comments (NOT stale)

The following comments are accurate and should NOT be changed:

| File | Lines | Comment | Status |
|------|-------|---------|--------|
| Frame.lean | 203-204 | "Under irreflexive semantics, bx_le is NOT reflexive" | Accurate |
| CanonicalModel.lean | 51-53 | "Sorry'd pending Phase 2 redesign" | Accurate (task 109) |
| RootScopedChain.lean | 631, 659 | "g/h_content_subset_self is sorry'd" | Accurate |
| RootScopedChain.lean | 1091-1099 | "For now, sorry this case/direction" | Accurate |
| Quasimodel/Construction.lean | 157, 203 | "Sorry'd (non-critical path)" | Accurate |
| Quasimodel/OracleStep.lean | multiple | Oracle sorry documentation | Accurate |
| Quasimodel/Realization.lean | 66, 70, 196, 248 | "Sorry'd (non-critical path)" | Accurate |
| Filtration/SigmaOrdering.lean | 79, 96, 140 | "Sorry'd for non-critical path" | Accurate |
| CanonicalChain.lean | 137-141 | Delegation bridge comments | Accurate |

## Decisions

1. Boneyard/ files are out of scope -- they are archived dead code with historically accurate comments
2. Comments that say "sorry'd" about actual sorry sites are accurate and not stale
3. The "Phase 2 redesign" references in CanonicalModel.lean are task 109 scope and remain accurate

## Recommendations

### Priority 1 (clearly stale, should fix)
1. **Frame.lean:493-494** -- Remove "For now, sorry" comment, replace with note that proof is complete
2. **BXCanonical.lean:20** -- Update parenthetical about completeness sorry status
3. **TruthLemma.lean:37** -- Remove or update TaskModel sorry reference
4. **Completeness.lean:120-121** -- Update to reference `dd_countermodel` and both sorry locations
5. **Completeness.lean:32** -- Update to mention both CanonicalModel.lean and RootScopedChain.lean

### Priority 2 (stale phrasing, should fix)
6. **Formula.lean:328-333** -- Update X/Y docstrings to not frame strict semantics as alternative/hypothetical
7. **Frame.lean:22** -- Update header to note bx_le_refl is sorry'd under irreflexive semantics

### Priority 3 (minor, optional)
8. **BXCanonical.lean:27** -- Clarify LocusControl description (low priority)
9. **Completeness.lean:28-30** -- Update `bx_countermodel` reference to `dd_countermodel`

## Risks & Mitigations

- **Risk**: Accidentally changing comments on lines where sorry still exists, making them seem resolved
  - **Mitigation**: Each finding above classifies whether the underlying sorry is resolved or still present
- **Risk**: Boneyard files have stale comments
  - **Mitigation**: Boneyard is archived dead code; comments there are historical and should not be updated

## Appendix

### Sorry count by file (non-Boneyard)

| File | sorry count | Notes |
|------|-------------|-------|
| Frame.lean | 2 | 1 code (bx_le_refl), 1 comment-only (line 493) |
| Completeness.lean | 1 | comment-only (line 32, "remaining") |
| TruthLemma.lean | 5 | 2 code (backward_refl), 3 comments |
| CanonicalModel.lean | 11 | 6 code, 5 comments |
| RootScopedChain.lean | 9 | 5 code, 4 comments |
| CanonicalChain.lean | 1 | comment-only |
| Quasimodel/Construction.lean | 3 | 2 code, 1 comment |
| Quasimodel/OracleStep.lean | 25 | ~10 code, ~15 comments |
| Quasimodel/Realization.lean | 5 | 3 code, 2 comments |
| Filtration/SigmaOrdering.lean | 4 | 3 code, 1 comment |
