# Implementation Plan: Task #827

- **Task**: 827 - Complete multi-family BMCS construction to resolve modal_backward sorry
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: Task 818 (Bimodal metalogic refactor - completed)
- **Research Inputs**: specs/827_complete_multi_family_bmcs_construction/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement a multi-family BMCS construction with modal saturation to eliminate the `modal_backward` sorry at Construction.lean line 220. The current single-family construction cannot prove `phi -> Box phi` because this is not valid in general modal logic. A modally saturated BMCS with multiple families satisfies `modal_backward` BY CONSTRUCTION through contrapositive reasoning: if phi is in all families but Box phi is not, then Diamond (neg phi) exists, requiring a witness family with neg phi, contradicting phi being universal.

### Research Integration

Key findings from research-001.md:
- The sorry exists because single-family BMCS lacks modal witnesses
- Saturation adds witness families for every Diamond formula
- Termination relies on closure finiteness (finite subformula set)
- Temporal coherence must be preserved for new families
- The proof is by contraposition using MCS negation completeness

## Goals & Non-Goals

**Goals**:
- Eliminate the `modal_backward` sorry in Construction.lean
- Define a modal saturation predicate for BMCS
- Implement `saturate_bmcs` function that adds witness families
- Prove termination via closure finiteness
- Prove `modal_backward` holds for saturated BMCS
- Update `construct_bmcs` to produce saturated result

**Non-Goals**:
- Proving general diamond witness existence theorems (covered by existing `bmcs_diamond_witness`)
- Modifying the BMCS structure definition itself
- Addressing temporal backward direction sorries (separate task 828)
- Implementing FDSM saturation (separate task 825/826)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Termination proof difficult with Set (not Finset) | High | Medium | Use closure finiteness + well-founded recursion on finite set |
| Temporal coherence for new families hard to prove | Medium | Medium | New families use constant MCS pattern (same as existing) |
| Closure definition may be missing | Medium | Low | Verify existence or define subformula closure |
| Diamond formula enumeration complex | Medium | Medium | Use existential witness construction rather than enumeration |

## Implementation Phases

### Phase 1: Foundation - Saturation Predicate [COMPLETED]

**Goal**: Define the modal saturation predicate and supporting infrastructure

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- [ ] Define `is_modally_saturated` predicate for BMCS
- [ ] Define helper for Diamond formulas in closure
- [ ] Define `needs_witness` predicate for unsatisfied diamonds
- [ ] Add imports to Construction.lean

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Create new file
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Add import

**Verification**:
- File compiles without errors
- Saturation predicate is well-formed

---

### Phase 2: Witness Family Construction [COMPLETED]

**Goal**: Implement construction of witness families for unsatisfied diamond formulas

**Tasks**:
- [ ] Define `construct_witness_family` that creates family with phi in MCS
- [ ] Prove witness family has required MCS property (phi in MCS)
- [ ] Prove witness family satisfies temporal coherence (forward_G, backward_H, etc.)
- [ ] Define `add_witness_family` that extends BMCS with new family

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Add witness construction

**Verification**:
- `construct_witness_family` compiles
- Temporal coherence proofs complete
- New family properly typed as `IndexedMCSFamily D`

---

### Phase 3: Saturation Function [COMPLETED]

**Goal**: Implement the saturation function that iteratively adds witness families

**Tasks**:
- [ ] Define `saturation_step` that processes one unsatisfied diamond
- [ ] Define `saturate_bmcs` using well-founded recursion
- [ ] Prove termination via closure finiteness (finite diamonds to satisfy)
- [ ] Prove `saturate_bmcs` produces valid BMCS (modal_forward preserved)

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Add saturation function

**Verification**:
- `saturate_bmcs` compiles without `sorry` in termination proof
- Saturation function is `noncomputable` (uses classical choice)
- Output is valid BMCS

---

### Phase 4: Modal Backward Proof [COMPLETED]

**Goal**: Prove that saturated BMCS satisfies `modal_backward`

**Tasks**:
- [ ] State `saturated_modal_backward` theorem
- [ ] Implement contrapositive proof:
  - Assume phi in all families, Box phi not in fam.mcs
  - By MCS negation completeness: Diamond (neg phi) in fam.mcs
  - By saturation: exists witness family with (neg phi)
  - Contradiction with phi in all families
- [ ] Prove `saturate_bmcs_is_saturated` (saturation predicate holds)

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Add modal_backward proof

**Verification**:
- `saturated_modal_backward` compiles without sorry
- Contrapositive structure clear in proof

---

### Phase 5: Integration and Sorry Elimination [IN PROGRESS]

**Goal**: Update Construction.lean to use saturated BMCS and eliminate sorry

**Tasks**:
- [ ] Define `saturatedBMCS` that wraps saturation
- [ ] Update `construct_bmcs` to call saturation
- [ ] Replace sorry in `singleFamilyBMCS.modal_backward` with saturation-based proof
- [ ] Update documentation in Construction.lean
- [ ] Verify Completeness.lean still compiles

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Integrate saturation, eliminate sorry
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Verify compatibility

**Verification**:
- `lake build` succeeds
- No `sorry` in Construction.lean modal_backward
- Completeness theorems still compile
- Sorry count reduced by 1

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/Construction.lean` returns 0 results
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` returns 0 results
- [ ] Completeness.lean compiles without changes to theorem statements
- [ ] Run `lake build` on full project to ensure no regressions

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - New file with saturation infrastructure
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Updated with sorry eliminated
- `specs/827_complete_multi_family_bmcs_construction/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If implementation fails or introduces regressions:
1. Revert to current Construction.lean (sorry is acceptable per research)
2. Document specific blocker in error report
3. Consider alternative: Document sorry as "accepted limitation" with cross-reference to this task
4. Option: Create partial implementation leaving some sorries with clearer path forward
