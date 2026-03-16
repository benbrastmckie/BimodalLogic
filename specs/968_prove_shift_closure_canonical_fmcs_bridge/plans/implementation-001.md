# Implementation Plan: Task #968

- **Task**: 968 - prove_shift_closure_canonical_fmcs_bridge
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: Task 967 (reflexive temporal semantics - completed)
- **Research Inputs**: specs/968_prove_shift_closure_canonical_fmcs_bridge/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This implementation ports the shift-closure pattern from `Boneyard/IntRepresentation/Representation.lean` to the active canonical construction in `CanonicalConstruction.lean`. The goal is to connect the sorry-free `canonical_truth_lemma` to standard semantic validity by constructing a shift-closed Omega and proving a `shifted_truth_lemma`. The key theorems are already implemented in the Boneyard file and are sorry-free, so this is primarily a porting exercise with integration work.

### Research Integration

From research-002.md:
- `bmcs_truth_at` is already bypassed by `canonical_truth_lemma` in CanonicalConstruction.lean
- The minimal bridge is `shifted_truth_lemma` extending the truth lemma to `ShiftClosedCanonicalOmega`
- `box_persistent` (Box phi persists to all times via TF axiom) is the key helper
- All theorems are expected to be sorry-free given existing infrastructure

## Goals & Non-Goals

**Goals**:
- Port `ShiftClosedCanonicalOmega` definition to CanonicalConstruction.lean
- Port `shiftClosedCanonicalOmega_is_shift_closed` proof
- Port `box_persistent` helper lemma
- Port `shifted_truth_lemma` connecting MCS membership to truth at shift-closed Omega
- Verify all ported code is sorry-free
- Ensure `lake build` passes

**Non-Goals**:
- Implementing full standard completeness theorems (these exist in Boneyard)
- Changing the BFMCS or FMCS definitions
- Adding FMCS shift operations (not needed for this approach)
- Replacing existing CanonicalConstruction.lean code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import cycle between modules | H | L | Add new content to existing CanonicalConstruction.lean rather than new file |
| Type mismatches between Boneyard and active code | M | M | Boneyard uses same types (BFMCS Int, FMCS Int); careful copy |
| Missing helper lemmas in active codebase | M | L | Research shows all dependencies exist (TF axiom, temporal duality) |
| Build failures due to namespace differences | L | M | Check namespace prefixes when porting |

## Sorry Characterization

### Pre-existing Sorries
- 0 sorries in CanonicalConstruction.lean (already sorry-free)
- 0 sorries in Boneyard/IntRepresentation/Representation.lean for the code being ported

### Expected Resolution
- No sorries to resolve; this is a porting task

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries in shift-closure infrastructure
- The `shifted_truth_lemma` provides the bridge for standard completeness theorems
- Upstream sorries in BFMCS construction remain out of scope

## Implementation Phases

### Phase 1: Port ShiftClosedCanonicalOmega Definition [IN PROGRESS]

- **Dependencies**: None
- **Goal**: Add the shift-closed Omega definition to CanonicalConstruction.lean

**Tasks**:
- [ ] Read existing `to_history` and `CanonicalOmega` definitions in CanonicalConstruction.lean
- [ ] Port `shiftClosedCanonicalOmega` definition from Representation.lean (lines 180-182)
- [ ] Port helper lemmas: `time_shift_canonicalHistory_compose` (lines 185-193)
- [ ] Port helper lemmas: `canonicalHistory_eq_time_shift_zero` (lines 196-202)
- [ ] Port `shiftClosedCanonicalOmega_is_shift_closed` theorem (lines 205-211)
- [ ] Port `canonicalOmega_subset_shiftClosed` theorem (lines 214-220)
- [ ] Run `lake build Bimodal.Metalogic.Bundle.CanonicalConstruction`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - add ShiftClosed infrastructure

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` returns empty

---

### Phase 2: Port box_persistent Helper [NOT STARTED]

- **Dependencies**: None (can run in parallel with Phase 1)
- **Goal**: Add the box_persistent lemma that enables shifted_truth_lemma

**Tasks**:
- [ ] Port `past_tf_deriv` derivation (lines 232-242 in Representation.lean)
- [ ] Port `box_persistent` theorem (lines 251-275)
- [ ] Verify proof uses only available infrastructure: TF axiom, temporal_duality, forward_G, backward_H
- [ ] Run `lake build Bimodal.Metalogic.Bundle.CanonicalConstruction`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - add box_persistent

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` returns empty

---

### Phase 3: Port shifted_truth_lemma [NOT STARTED]

- **Dependencies**: Phase 1, Phase 2
- **Goal**: Prove the shifted truth lemma connecting MCS membership to truth at ShiftClosedCanonicalOmega

**Tasks**:
- [ ] Port `shifted_truth_lemma` theorem (lines 438-553 in Representation.lean)
- [ ] Adapt to use active codebase structures: `CanonicalTaskFrame`, `CanonicalTaskModel`, `to_history`
- [ ] Ensure the box forward case uses `box_persistent` + `time_shift_preserves_truth`
- [ ] Verify temporal cases are identical to `canonical_truth_lemma` (they are Omega-independent)
- [ ] Run `lake build Bimodal.Metalogic.Bundle.CanonicalConstruction`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - add shifted_truth_lemma

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` returns empty
- `lean_goal` shows "no goals" at end of theorem

---

### Phase 4: Integration and Documentation [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Document the bridge, verify zero-debt completion

**Tasks**:
- [ ] Add module documentation explaining ShiftClosedCanonicalOmega and shifted_truth_lemma
- [ ] Run full `lake build` to verify no regressions
- [ ] Verify with `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- [ ] Verify with `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- [ ] Update implementation plan with progress notes

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - add documentation

**Verification**:
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` returns empty
- `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` shows no new axioms

---

### Phase 5: Standard Completeness Connection (Optional) [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Port standard_representation theorem to demonstrate the bridge works

**Tasks**:
- [ ] Port `standard_representation` theorem (lines 578-598) if time permits
- [ ] This demonstrates the end-to-end connection from consistency to satisfiability
- [ ] Run `lake build`

**Timing**: 1 hour (optional, stretch goal)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - add standard_representation

**Verification**:
- `lake build` passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` returns empty

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Integration Tests
- [ ] Dependent modules still compile: `lake build Bimodal`
- [ ] No regressions in existing theorems

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - extended with shift-closure infrastructure
- `specs/968_prove_shift_closure_canonical_fmcs_bridge/plans/implementation-001.md` (this file)
- `specs/968_prove_shift_closure_canonical_fmcs_bridge/summaries/implementation-summary-{DATE}.md` (on completion)

## Rollback/Contingency

The implementation adds new content to CanonicalConstruction.lean without modifying existing proofs. If issues arise:

1. **Partial port**: If some theorems are harder to port than expected, complete what is possible and mark remaining as [BLOCKED] with review_reason
2. **Type mismatches**: If the Boneyard structures diverge from active codebase, document the gaps and request user review
3. **Git revert**: Since all changes are additive, `git checkout -- Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` restores original state

## Notes

- The Boneyard code (Representation.lean) is marked DEPRECATED because it uses Int-indexed FMCS. However, the canonical construction in the active codebase ALSO uses Int, so the port is valid.
- Phase 5 (standard completeness) is optional stretch goal; the core deliverable is shifted_truth_lemma.
- The key insight from research: shift-closure is mathematically required for soundness of interaction axioms (MF, TF). This cannot be eliminated, only implemented cleanly.
