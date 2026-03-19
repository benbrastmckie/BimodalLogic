# Implementation Plan: Task #1002

- **Task**: 1002 - Design Modal Witness Infrastructure for Multi-Family BFMCS
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (research/design task)
- **Research Inputs**: specs/988_dense_algebraic_completeness/reports/16_spawn-analysis.md
- **Artifacts**: plans/01_modal-witness-design.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean

## Overview

This task analyzes why single-family BFMCS constructions cannot prove `modal_backward` and designs the modal witness infrastructure needed for a correct multi-family approach. The core problem is that "phi in MCS implies Box phi in MCS" is not valid in general modal logic - S5 semantics require Diamond witnesses in different accessible worlds. The solution requires a bundle of families where Diamond formulas have witnesses in genuinely different families, enabling the contrapositive argument for modal_backward.

### Research Integration

- **16_spawn-analysis.md**: Documents the blocker where `modal_backward` cannot be proven for singleton BFMCS because Box phi -> phi (T-axiom) does not imply phi -> Box phi in general.

## Goals & Non-Goals

**Goals**:
- Analyze mathematically why single-family modal_backward fails
- Design DiamondWitness structure connecting families across the bundle
- Specify ModalWitnessFamily construction from consistent seeds
- Document proof strategy for modal_backward using contrapositive argument
- Produce Lean structure sketches that can guide implementation

**Non-Goals**:
- Full implementation of the witness infrastructure (that is task 1003)
- Modifying existing BFMCS.lean or Construction.lean files
- Proving soundness or completeness theorems
- Integration with temporal coherence (already handled by CanonicalFMCS)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Diamond witness may require Box content preservation | High | Medium | Leverage existing SetMaximalConsistent.neg_box_implies_box_neg_box from ModalSaturation.lean |
| Witness family construction may not preserve MCS properties | High | Low | Use Lindenbaum lemma pattern from Construction.lean |
| Cardinality issues with infinite Diamond obligations | Medium | Low | Use subformula closure approach (already exists) to bound obligations |

## Implementation Phases

### Phase 1: Mathematical Analysis of Single-Family Failure [NOT STARTED]

**Goal**: Document precisely why phi in MCS does not imply Box phi in MCS for singleton families.

**Tasks**:
- [ ] Write formal analysis showing the counterexample: a consistent set {phi, neg(Box phi)} exists
- [ ] Explain why T-axiom (Box phi -> phi) does NOT imply its converse
- [ ] Document that S5 semantics require quantification over multiple accessible worlds
- [ ] Reference the archived singleFamily_modal_backward_axiom removal (task 905)

**Timing**: 45 minutes

**Files to create**:
- `specs/1002_design_modal_witness_infrastructure/reports/01_mathematical-analysis.md`

**Verification**:
- Analysis explains the mathematical impossibility clearly
- References existing code showing where the proof attempt fails

---

### Phase 2: DiamondWitness Structure Design [NOT STARTED]

**Goal**: Design the data structure that connects Diamond formulas to their witness families.

**Tasks**:
- [ ] Define DiamondWitness structure with fields: source_family, source_time, diamond_formula, witness_family
- [ ] Specify the consistency property: psi in witness_family.mcs(t) when Diamond(psi) in source_family.mcs(t)
- [ ] Design the witness tracking mechanism (Set vs indexed family)
- [ ] Document how DiamondWitness enables the contrapositive proof of modal_backward

**Timing**: 1 hour

**Lean structure sketch**:
```lean
/-- A diamond witness links a Diamond formula in one family to its witness in another family. -/
structure DiamondWitness (D : Type*) [Preorder D] where
  /-- The family containing Diamond(psi) -/
  source_family : FMCS D
  /-- The time point where Diamond(psi) holds -/
  time : D
  /-- The formula psi where Diamond(psi) is in source_family.mcs(time) -/
  inner_formula : Formula
  /-- Proof that Diamond(psi) is in the source MCS -/
  diamond_mem : inner_formula.diamond ∈ source_family.mcs time
  /-- The witness family containing psi -/
  witness_family : FMCS D
  /-- Proof that psi is in the witness family's MCS -/
  witness_mem : inner_formula ∈ witness_family.mcs time
```

**Verification**:
- Structure captures all necessary components for witness relationship
- Design aligns with existing FMCS and BFMCS patterns

---

### Phase 3: ModalWitnessFamily Construction Specification [NOT STARTED]

**Goal**: Specify how to construct a new FMCS family to serve as a Diamond witness.

**Tasks**:
- [ ] Design modal_witness_seed: the set {psi} union box_content(source_family.mcs(t))
- [ ] Prove modal_witness_seed consistency (when Diamond(psi) in source MCS)
- [ ] Specify extension to full FMCS via Lindenbaum + temporal structure
- [ ] Document BoxContent preservation requirements for S5 coherence

**Timing**: 1.5 hours

**Key insight from ModalSaturation.lean**:
```lean
-- If Diamond psi is in MCS, then psi is consistent (diamond_implies_psi_consistent)
-- BoxContent must propagate: if neg(Box chi) in source, then neg(Box chi) in witness
-- This is needed for S5 negative introspection
```

**Lean structure sketch**:
```lean
/-- Modal witness seed: {psi} ∪ box_content(M) where box_content extracts Box formulas -/
def modal_witness_seed (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} ∪ box_content M

/-- box_content extracts the "modal content" that must propagate to witnesses -/
def box_content (M : Set Formula) : Set Formula :=
  { chi | Formula.box chi ∈ M } ∪ { (Formula.box chi).neg | (Formula.box chi).neg ∈ M }
```

**Verification**:
- Seed construction preserves consistency when Diamond condition holds
- BoxContent preservation enables S5 modal coherence

---

### Phase 4: Proof Strategy for modal_backward [NOT STARTED]

**Goal**: Document the complete proof strategy using witness families.

**Tasks**:
- [ ] Write the contrapositive argument step by step
- [ ] Show how saturated_modal_backward in ModalSaturation.lean already uses this pattern
- [ ] Specify the saturation closure requirement: every Diamond has a witness family in the bundle
- [ ] Define ModallyClosedBFMCS as a BFMCS with saturation guarantee

**Timing**: 1 hour

**Proof strategy outline**:
```
To prove: phi in ALL families' MCS(t) implies Box(phi) in fam.mcs(t)

By contraposition:
1. Assume phi in all families but Box(phi) NOT in fam.mcs(t)
2. By MCS negation completeness: neg(Box phi) in fam.mcs(t)
3. Using S5 axiom 5: neg(Box phi) implies Diamond(neg phi) (via box_dne_theorem)
4. By modal saturation: exists witness family fam' where neg(phi) in fam'.mcs(t)
5. But phi is in ALL families including fam' - contradiction
6. Therefore Box(phi) in fam.mcs(t)
```

**Verification**:
- Proof strategy aligns with saturated_modal_backward theorem
- All required lemmas are identified

---

### Phase 5: Design Document and Lean Sketches [NOT STARTED]

**Goal**: Consolidate findings into a design document with complete Lean structure sketches.

**Tasks**:
- [ ] Create comprehensive design document summarizing all phases
- [ ] Provide complete Lean structure definitions (non-compiling sketches)
- [ ] List key lemma statements needed for implementation
- [ ] Specify integration points with existing infrastructure

**Timing**: 45 minutes

**Files to create**:
- `specs/1002_design_modal_witness_infrastructure/reports/02_design-document.md`

**Key lemma statements to specify**:
```lean
-- 1. Seed consistency
theorem modal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : psi.diamond ∈ M) :
    SetConsistent (modal_witness_seed M psi)

-- 2. BoxContent preservation
theorem box_content_preserved_in_witness (M W : Set Formula)
    (h_W_from_seed : modal_witness_seed M psi ⊆ W) (h_W_mcs : SetMaximalConsistent W) :
    box_content M ⊆ W

-- 3. Saturation implies modal_backward (already proven in ModalSaturation.lean)
theorem saturated_modal_backward (B : BFMCS D) (h_sat : is_modally_saturated B) ...

-- 4. Closure construction produces saturated bundle
theorem closure_is_saturated (B_init : BFMCS D) :
    is_modally_saturated (modal_saturation_closure B_init)
```

**Verification**:
- Design document is self-contained and actionable
- Lean sketches compile conceptually (types align)
- Integration points are clearly specified

---

## Testing & Validation

- [ ] Mathematical analysis is reviewed for logical soundness
- [ ] Lean structure sketches type-check conceptually
- [ ] Design aligns with existing ModalSaturation.lean patterns
- [ ] Key lemma statements are well-formed and provable
- [ ] Design document is sufficient for implementation task 1003

## Artifacts & Outputs

- `specs/1002_design_modal_witness_infrastructure/reports/01_mathematical-analysis.md` - Mathematical analysis of why single-family fails
- `specs/1002_design_modal_witness_infrastructure/reports/02_design-document.md` - Complete design document with Lean sketches

## Rollback/Contingency

This is a design task with no code changes. If the design proves unworkable:
- Document the failure mode
- Identify alternative approaches (e.g., transfinite construction, quotient approach from task 982)
- Update task 1003 dependencies accordingly

## Key Insights from Codebase Analysis

### Existing Infrastructure

1. **BFMCS.lean**: Defines the bundle structure with modal_forward and modal_backward requirements
2. **ModalSaturation.lean**: Contains `saturated_modal_backward` - the key theorem using contraposition
3. **WitnessSeed.lean**: Pattern for temporal witness seeds (forward_temporal_witness_seed, past_temporal_witness_seed)
4. **CanonicalFMCS.lean**: All-MCS approach that works for temporal coherence but needs modal saturation

### Why Temporal Witnesses Work But Modal Witnesses Are Different

Temporal witnesses use the same MCS domain (CanonicalMCS contains all MCSes), so F(psi) witnesses are automatically in the domain. Modal witnesses require multiple FMCS families in the bundle - the witness must be a different family, not just a different time point in the same family.

### S5-Specific Requirements

The modal logic is S5, which provides:
- T-axiom: Box phi -> phi (reflexivity)
- 5-axiom collapse: Diamond(Box phi) -> Box phi (negative introspection)

The existing `axiom_5_negative_introspection` and `neg_box_to_box_neg_box` in ModalSaturation.lean provide the key tools for BoxContent preservation.
