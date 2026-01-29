# Implementation Plan: Task #760

- **Task**: 760 - Complete COMPLETE disposition sorries (12 exercise proofs)
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/760_determine_sorry_disposition_archive_vs_complete/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete 12 exercise sorries in the Examples/ directory that are marked for COMPLETE disposition. All are straightforward proof exercises with technique hints already in comments. The research report categorized these as "Exercises - straightforward to complete" requiring basic applications of existing infrastructure (generalized necessitation, De Morgan laws, contraposition, conjunction distribution).

### Research Integration

The research report (research-001.md) identified these 12 sorries as:
- 2 sorries in TemporalProofs.lean (lines 180, 194) - temporal K rule exercises
- 5 sorries in ModalProofStrategies.lean (lines 204, 252, 295, 325, 430) - modal distribution and S5 exercises
- 5 sorries in ModalProofs.lean (lines 168, 183, 196, 249, 256) - modal K, generalized necessitation, duality exercises

## Goals & Non-Goals

**Goals**:
- Complete all 12 exercise sorries in Examples/ files
- Use proof techniques specified in existing hints
- Verify compilation with `lake build`
- Demonstrate proof techniques for pedagogical value

**Non-Goals**:
- Archive any code to Boneyard (separate task)
- Touch Metalogic/ or other directories
- Modify non-example files
- Add new theorems or lemmas beyond exercise completion

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missing lemmas for proofs | Medium | Low | Use lean_leansearch, lean_loogle to find alternatives |
| Proof technique mismatch | Low | Low | Follow hint comments, use lean_hover_info for signatures |
| Import issues | Low | Low | Check existing imports, add if needed |

## Implementation Phases

### Phase 1: TemporalProofs.lean (2 sorries) [NOT STARTED]

**Goal**: Complete 2 temporal K rule exercises at lines 180 and 194.

**Tasks**:
- [ ] Complete sorry at line 180 - temporal K rule using `generalized_temporal_k`
- [ ] Complete sorry at line 194 - future lifting using temporal K rule
- [ ] Verify file compiles with `lake build Bimodal.Examples.TemporalProofs`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Examples/TemporalProofs.lean`

**Verification**:
- Both examples compile without `sorry`
- Module passes `lake build`

---

### Phase 2: ModalProofStrategies.lean (5 sorries) [NOT STARTED]

**Goal**: Complete 5 modal proof strategy exercises.

**Tasks**:
- [ ] Complete sorry at line 204 - possibility distribution over disjunction (De Morgan laws)
- [ ] Complete sorry at line 252 - curried modal modus ponens (modal_k_dist + imp_trans)
- [ ] Complete sorry at line 295 - S5 characteristic `diamond box phi -> phi` (contraposition + S5 axioms)
- [ ] Complete sorry at line 325 - S5 diamond iteration `diamond diamond phi -> diamond phi` (contraposition on M4)
- [ ] Complete sorry at line 430 - conjunction distribution under box (K distribution)
- [ ] Verify file compiles with `lake build Bimodal.Examples.ModalProofStrategies`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Examples/ModalProofStrategies.lean`

**Verification**:
- All 5 examples compile without `sorry`
- Module passes `lake build`

---

### Phase 3: ModalProofs.lean (5 sorries) [NOT STARTED]

**Goal**: Complete 5 modal proof exercises.

**Tasks**:
- [ ] Complete sorry at line 168 - modal modus ponens using modal_k_dist
- [ ] Complete sorry at line 183 - S5 characteristic `diamond box phi -> phi`
- [ ] Complete sorry at line 196 - generalized modal K using `generalized_modal_k`
- [ ] Complete sorry at line 249 - possibility of conjunction implies disjunction of possibilities
- [ ] Complete sorry at line 256 - modal duality using `dni` from Combinators
- [ ] Verify file compiles with `lake build Bimodal.Examples.ModalProofs`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Examples/ModalProofs.lean`

**Verification**:
- All 5 examples compile without `sorry`
- Module passes `lake build`

---

### Phase 4: Final Verification [NOT STARTED]

**Goal**: Verify all changes compile together and document completion.

**Tasks**:
- [ ] Run full `lake build` to verify no regressions
- [ ] Count remaining sorries in Examples/ to confirm reduction
- [ ] Update state.json with completion summary

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- Full build succeeds
- Sorry count in Examples/ reduced by 12
- No new warnings or errors introduced

## Testing & Validation

- [ ] Each file compiles individually after phase completion
- [ ] Full `lake build` succeeds after all phases
- [ ] No `sorry` remaining in modified proof terms
- [ ] Proof techniques match documented hints

## Artifacts & Outputs

- `Theories/Bimodal/Examples/TemporalProofs.lean` - 2 sorries completed
- `Theories/Bimodal/Examples/ModalProofStrategies.lean` - 5 sorries completed
- `Theories/Bimodal/Examples/ModalProofs.lean` - 5 sorries completed
- `specs/760_determine_sorry_disposition_archive_vs_complete/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If proofs cannot be completed:
1. Document which sorry could not be completed and why
2. Keep sorry in place with detailed comment explaining the blocker
3. Consider whether additional infrastructure is needed (separate task)
4. Partial completion is acceptable - each proof is independent
