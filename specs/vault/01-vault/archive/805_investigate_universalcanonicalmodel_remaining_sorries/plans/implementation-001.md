# Implementation Plan: Task #805

- **Task**: 805 - Investigate UniversalCanonicalModel.lean remaining sorries
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Dependencies**: Task 801, Task 803 (completed)
- **Research Inputs**: specs/805_investigate_universalcanonicalmodel_remaining_sorries/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

The research phase identified 2 sorries in UniversalCanonicalModel.lean (not 3 as originally expected). Both are in corollary theorems (`non_provable_satisfiable` and `completeness_contrapositive`) and are provable using existing infrastructure from `SemanticCanonicalModel.lean`. The main `representation_theorem` is already fully proven. This is a straightforward implementation task requiring an import addition and application of existing lemmas.

### Research Integration

Key findings from research-001.md:
- **2 sorries** found, not 3 as task description indicated
- Both sorries are in corollary theorems, not the main representation_theorem
- `phi_consistent_of_not_refutable` (SemanticCanonicalModel.lean:318) solves `non_provable_satisfiable`
- `neg_set_consistent_of_not_provable` (SemanticCanonicalModel.lean:291) enables `completeness_contrapositive`
- Both lemmas are in `Bimodal.Metalogic.FMP.SemanticCanonicalModel`

## Goals & Non-Goals

**Goals**:
- Resolve all sorries in UniversalCanonicalModel.lean
- Maintain existing proof structure and documentation
- Verify build succeeds with no sorries remaining

**Non-Goals**:
- Modifying the main representation_theorem (already complete)
- Addressing sorries in TruthLemma.lean (separate architectural limitations)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycle | H | L | FMP module is downstream; verify import structure first |
| Signature mismatch | M | L | Use lean_hover_info to verify lemma types match |

## Implementation Phases

### Phase 1: Complete Corollary Theorems [COMPLETED]

**Note**: This work was already completed by Task 807 (commit 52b82d03).

**Goal**: Resolve both sorries using existing infrastructure from SemanticCanonicalModel.lean

**Tasks**:
- [x] Add import for `Bimodal.Metalogic.FMP.SemanticCanonicalModel`
- [x] Complete `non_provable_satisfiable` using `phi_consistent_of_not_refutable`
- [x] Complete `completeness_contrapositive` using `neg_set_consistent_of_not_provable` and truth lemma
- [ ] Verify build with `lake build` - BLOCKED by pre-existing SoundnessLemmas.lean errors

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` - add import, complete 2 theorems

**Detailed Implementation**:

1. **Add Import** (Line 4):
```lean
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
```

2. **Complete `non_provable_satisfiable`** (Lines 176-180):
Replace the sorry block with:
```lean
have h_cons : SetConsistent {phi} :=
  phi_consistent_of_not_refutable phi h_not_prov
```

3. **Complete `completeness_contrapositive`** (Lines 196-198):
Replace the sorry with proof using:
- `neg_set_consistent_of_not_provable` to establish `{phi.neg}` is consistent
- Lindenbaum to extend to MCS
- Coherent construction for the indexed family
- Truth lemma (backward direction via contrapositive) to show phi is false

**Verification**:
- `lake build` completes with no errors
- `grep -c sorry UniversalCanonicalModel.lean` returns 0

---

## Testing & Validation

- [ ] `lake build` succeeds with no errors - BLOCKED by SoundnessLemmas.lean
- [x] No sorries remain in UniversalCanonicalModel.lean (verified with grep)
- [x] Verify import doesn't create circular dependency (confirmed)

## Artifacts & Outputs

- Modified `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` with all sorries resolved

## Rollback/Contingency

If import causes issues:
1. Check if FMP module imports Representation module (would create cycle)
2. If cycle exists, copy the lemmas locally or restructure imports
3. As fallback, prove lemmas inline without import

The proofs are straightforward given the hypothesis transformations needed, so inline proofs are viable if import issues arise.
