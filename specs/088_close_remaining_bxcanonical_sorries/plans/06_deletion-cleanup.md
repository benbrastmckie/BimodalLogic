# Implementation Plan: Delete CanonicalEmbedding.lean and Clean Up References

- **Task**: 88 - Close remaining BXCanonical sorries
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: reports/06_deletion-impact.md
- **Artifacts**: plans/06_deletion-cleanup.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Delete the dead-end `CanonicalEmbedding.lean` file (434 lines, 1 sorry) and clean up all references to it. The constant-history approach is permanently rejected: G collapses to identity on constant histories, making any truth bridge for G inside imp mathematically impossible. Report 06 confirmed the file is entirely self-contained with zero external dependents. Three useful validity reduction lemmas will be relocated to `Semantics/Validity.lean` before deletion. This eliminates 1 sorry from the BXCanonical module and documents the anti-pattern for future reference. Definition of done: `lake build` succeeds, sorry count in BXCanonical/ decreases by 1, and ROAD_MAP.md contains the anti-pattern entry.

### Research Integration

Report 06 (deletion impact analysis) confirmed: (1) all ~15 definitions in CanonicalEmbedding.lean are self-contained with no external consumers, (2) the only references are an import in BXCanonical.lean line 3 and comments in Completeness.lean lines 144-159, (3) three validity reduction lemmas (`valid_of_valid_all_future`, `valid_of_valid_all_past`, `valid_of_valid_box`) are correct, sorry-free, and worth preserving in Semantics/Validity.lean.

### Prior Plan Reference

Plan v5 attempted to close the sorry at CanonicalEmbedding.lean:418 using a USF truth lemma from Bundle architecture with restricted temporal coherence. That approach (12h estimated) is superseded by this deletion plan (1h estimated). Key lesson from v5: the constant-history infrastructure serves no purpose outside CanonicalEmbedding.lean, so fixing the sorry is wasted effort compared to deleting the dead-end file entirely.

### Roadmap Alignment

No ROAD_MAP.md found. This plan will create a ROAD_MAP.md anti-pattern entry documenting why constant-history completeness is permanently rejected.

## Goals & Non-Goals

**Goals**:
- Delete `CanonicalEmbedding.lean` entirely (removes 1 sorry)
- Relocate 3 useful validity reduction lemmas to `Semantics/Validity.lean`
- Remove import and update docstring in `BXCanonical.lean`
- Update comments in `Completeness.lean` to remove stale references
- Add anti-pattern entry to `ROAD_MAP.md` (or create if absent)
- Verify with `lake build`

**Non-Goals**:
- Closing the Completeness.lean:160 sorry (remains unchanged)
- Closing Frame.lean eventuality resolution sorries (separate concern)
- Modifying any proof strategy or axiom system
- Replacing CanonicalEmbedding.lean with a new approach

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Validity lemma relocation introduces import cycle | M | L | Check import graph before adding; Validity.lean imports only Truth.lean and Syntax, no BXCanonical dependency |
| Hidden dependency on CanonicalEmbedding.lean not caught by report 06 | H | VL | Run `lake build` after deletion; any missing dependency surfaces as compile error |
| Validity lemma signatures differ from what Validity.lean expects | L | L | Adapt signatures if needed; these are simple semantic lemmas |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Relocate Validity Lemmas [COMPLETED]

**Goal**: Move three useful validity reduction lemmas from CanonicalEmbedding.lean to Semantics/Validity.lean before deletion.

**Tasks**:
- [ ] Read `CanonicalEmbedding.lean` lines 336-358 to extract the three lemmas: `valid_of_valid_all_future`, `valid_of_valid_all_past`, `valid_of_valid_box`
- [ ] Identify what imports they require (likely `Semantics.Truth` and `Semantics.Validity` definitions already present)
- [ ] Add the three lemmas to the end of `Semantics/Validity.lean` with a section comment explaining their origin
- [ ] Run `lake build Bimodal.Semantics.Validity` to verify the relocated lemmas compile

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Semantics/Validity.lean` -- Add 3 validity reduction lemmas

**Verification**:
- `lake build Bimodal.Semantics.Validity` succeeds
- All three lemmas type-check without sorry

---

### Phase 2: Delete CanonicalEmbedding.lean and Update BXCanonical.lean [COMPLETED]

**Goal**: Remove the dead-end file and clean up the module barrel file.

**Tasks**:
- [ ] Delete `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean`
- [ ] In `BXCanonical.lean` line 3: remove `import Bimodal.Metalogic.BXCanonical.CanonicalEmbedding`
- [ ] In `BXCanonical.lean` docstring (lines 6-17): remove item 3 mentioning CanonicalEmbedding.lean and update architecture description
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical` to verify no import errors

**Timing**: 10 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- DELETE
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` -- Remove import and update docstring

**Verification**:
- `CanonicalEmbedding.lean` no longer exists
- `lake build Bimodal.Metalogic.BXCanonical` succeeds
- No references to CanonicalEmbedding remain in BXCanonical.lean

---

### Phase 3: Update Completeness.lean Comments and Add Anti-Pattern Entry [COMPLETED]

**Goal**: Remove stale references to CanonicalEmbedding.lean in Completeness.lean and document the anti-pattern.

**Tasks**:
- [ ] In `Completeness.lean` lines 144-159: update the comment block to remove references to `fragment_completeness` and `CanonicalEmbedding.lean`, replacing with a note that the constant-history approach was permanently rejected (see ROAD_MAP.md)
- [ ] Create or append to `specs/ROAD_MAP.md` an anti-pattern section documenting why constant-history completeness is permanently rejected, per the template in report 06
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Completeness` to verify

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Update stale comments
- `specs/ROAD_MAP.md` -- Add anti-pattern entry (create if absent)

**Verification**:
- No references to CanonicalEmbedding.lean or fragment_completeness remain in Completeness.lean comments
- ROAD_MAP.md contains the anti-pattern entry
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeds

---

### Phase 4: Full Build Verification and Sorry Audit [COMPLETED]

**Goal**: Confirm the full project builds and the sorry count decreased.

**Tasks**:
- [ ] Run `lake build` (full project build)
- [ ] Run `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` to audit remaining sorries
- [ ] Confirm CanonicalEmbedding.lean sorry is gone (file deleted)
- [ ] Confirm Completeness.lean:160 sorry remains (unchanged, expected)
- [ ] Confirm Frame.lean sorries remain (unchanged, expected)
- [ ] Verify no new sorries were introduced in Validity.lean

**Timing**: 15 minutes

**Depends on**: 2, 3

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds with zero errors
- BXCanonical/ sorry count decreased by 1 (from 2 to 1 in non-Frame files)
- No new sorries anywhere in the project

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `CanonicalEmbedding.lean` no longer exists in the repository
- [ ] `grep -rn CanonicalEmbedding Theories/` returns zero results (no stale references)
- [ ] `grep -rn sorry Theories/Bimodal/Semantics/Validity.lean` returns zero sorry instances
- [ ] BXCanonical/ sorry count decreased by 1
- [ ] Three validity reduction lemmas are accessible from `Semantics/Validity.lean`
- [ ] ROAD_MAP.md contains anti-pattern documentation for constant-history approach

## Artifacts & Outputs

- `specs/088_close_remaining_bxcanonical_sorries/plans/06_deletion-cleanup.md` -- This plan
- `Theories/Bimodal/Semantics/Validity.lean` -- 3 relocated validity lemmas added
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- DELETED
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` -- Import and docstring updated
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Comments updated
- `specs/ROAD_MAP.md` -- Anti-pattern entry added

## Rollback/Contingency

All changes are reversible via git. If `lake build` fails after deletion:

1. `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` to restore the file
2. `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` to restore the import
3. Revert Validity.lean changes if they caused import issues

The deletion is extremely low risk since report 06 confirmed zero external dependencies.
