# Implementation Plan: Task #1002 (Revised)

- **Task**: 1002 - Design Modal Witness Infrastructure for Multi-Family BFMCS
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None (research complete)
- **Research Inputs**: specs/1002_design_modal_witness_infrastructure/reports/02_modal-witness-research.md
- **Artifacts**: plans/02_revised-modal-witness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This revised plan focuses on IMPLEMENTATION rather than research. The research phase discovered that the codebase already contains all the infrastructure needed to prove `modal_backward`:

1. **`saturated_modal_backward`** (ModalSaturation.lean line 328) - ALREADY PROVES modal_backward from modal saturation
2. **`modal_witness_seed_consistent`** (ChainFMCS.lean line 322) - ALREADY PROVES {psi} union BoxContent(M) is consistent when Diamond(psi) in M
3. **`buildWitnessMCS`** (WitnessChainFMCS.lean line 66) - ALREADY CONSTRUCTS witness MCS via Lindenbaum extension
4. **`buildWitnessMCS_contains_psi`** and **`buildWitnessMCS_contains_boxcontent`** - ALREADY PROVE witness properties

The solution is to wire these existing components to construct a **modally saturated BFMCS** over CanonicalMCS, then apply `saturated_modal_backward`.

### Research Integration

Key findings from reports/02_modal-witness-research.md:
- The singleton BFMCS approach in MultiFamilyBFMCS.lean cannot prove modal_backward because "phi in MCS implies Box phi in MCS" is not valid
- The all-MCS approach in CanonicalFMCS.lean provides the architectural pattern: use ALL CanonicalMCS elements as domain
- The witness MCS from `buildWitnessMCS` is automatically a CanonicalMCS element (no reachability requirement)
- Modal saturation closure can be achieved by including witness families for each Diamond formula

## Goals & Non-Goals

**Goals**:
- Create design document specifying Lean structure definitions
- Define `SaturatedCanonicalBFMCS` construction
- Specify proof strategy for `is_modally_saturated` using existing witnesses
- Produce integration guide for task 1003 implementation

**Non-Goals**:
- Implementing the code (that is task 1003)
- Modifying existing sorry-free theorems
- Researching alternative approaches (research is complete)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Witness family temporal coherence | Medium | Low | Witness MCS inherits BoxContent which ensures S5 coherence |
| Bundle cardinality complexity | Low | Low | Use subformula closure to bound witness count |
| Integration with task 988 construction | Medium | Medium | Design clear interface for multi-family construction |

## Implementation Phases

### Phase 1: Design Document - Core Structures [NOT STARTED]

**Goal**: Define the Lean structures needed for saturated BFMCS construction.

**Tasks**:
- [ ] Define `WitnessFamilyData` structure linking Diamond formula to witness family
- [ ] Define `SaturatedCanonicalBFMCS` combining BFMCS with saturation proof
- [ ] Document how witness families wrap `canonicalMCSBFMCS` pattern
- [ ] Specify interface for adding witness families to base BFMCS

**Timing**: 1 hour

**Deliverable**:
Design section in `specs/1002_design_modal_witness_infrastructure/reports/03_design-document.md`

**Structure Definitions**:

```lean
/-- Data for a single modal witness: links Diamond(psi) in a family to psi in a witness family. -/
structure ModalWitnessData where
  /-- The formula psi where Diamond(psi) appears -/
  inner_formula : Formula
  /-- The source MCS containing Diamond(psi) -/
  source_mcs : Set Formula
  /-- Proof that source is maximal consistent -/
  source_is_mcs : SetMaximalConsistent source_mcs
  /-- Proof that Diamond(psi) is in source -/
  diamond_mem : inner_formula.diamond ∈ source_mcs
  /-- The witness MCS containing psi (built via buildWitnessMCS) -/
  witness_mcs : Set Formula := buildWitnessMCS source_mcs source_is_mcs inner_formula diamond_mem
  /-- Proof witness is maximal consistent -/
  witness_is_mcs : SetMaximalConsistent witness_mcs := buildWitnessMCS_is_mcs ...
  /-- Proof that psi is in witness -/
  witness_contains : inner_formula ∈ witness_mcs := buildWitnessMCS_contains_psi ...

/-- A BFMCS over CanonicalMCS with explicit witness families for all Diamond formulas. -/
structure SaturatedCanonicalBFMCS where
  /-- The underlying BFMCS -/
  bfmcs : BFMCS CanonicalMCS
  /-- Collection of witness data for each Diamond formula -/
  witnesses : Set ModalWitnessData
  /-- Saturation property: every Diamond has a witness in the bundle -/
  is_saturated : is_modally_saturated bfmcs
```

**Verification**:
- Structures align with existing BFMCS and FMCS patterns
- Witness data uses existing `buildWitnessMCS` from WitnessChainFMCS.lean

---

### Phase 2: Design Document - Proof Strategy [NOT STARTED]

**Goal**: Document the proof strategy for constructing a saturated BFMCS.

**Tasks**:
- [ ] Document how to construct witness family from ModalWitnessData
- [ ] Specify proof of `is_modally_saturated` using witness construction
- [ ] Show how `saturated_modal_backward` applies to give modal_backward
- [ ] Document BoxContent propagation for modal coherence

**Timing**: 1 hour

**Deliverable**:
Proof strategy section in design document

**Key Lemma Statements**:

```lean
/-- Construct a canonical witness family from witness data.
    The witness MCS becomes a CanonicalMCS element (no reachability needed). -/
noncomputable def witnessAsCanonicalMCS (w : ModalWitnessData) : CanonicalMCS :=
  { world := w.witness_mcs, is_mcs := w.witness_is_mcs }

/-- The witness family contains psi at the source time. -/
theorem witness_family_contains_psi (w : ModalWitnessData) (fam : FMCS CanonicalMCS)
    (t : CanonicalMCS) (h_t_world : t.world = w.source_mcs) :
    w.inner_formula ∈ fam.mcs (witnessAsCanonicalMCS w)

/-- Constructing saturated BFMCS from base family plus all witness families.

    The construction:
    1. Start with canonicalMCSBFMCS as base family
    2. For each Diamond(psi) in any family at any time:
       - Build witness MCS via buildWitnessMCS
       - Wrap as CanonicalMCS (automatically in domain!)
       - Add as family to bundle
    3. Prove is_modally_saturated by construction
    4. Apply saturated_modal_backward to derive modal_backward -/
theorem saturated_canonical_bfmcs_exists :
    ∃ B : BFMCS CanonicalMCS,
      canonicalMCSBFMCS ∈ B.families ∧
      is_modally_saturated B

/-- Final modal_backward theorem. -/
theorem canonical_modal_backward (B : BFMCS CanonicalMCS) (h_sat : is_modally_saturated B) :
    B.modal_backward := saturated_modal_backward B h_sat
```

**Verification**:
- Proof strategy uses only existing proven lemmas
- No new mathematical insights required

---

### Phase 3: Integration Guide [NOT STARTED]

**Goal**: Create integration guide showing how task 1003 implements the design.

**Tasks**:
- [ ] Map design structures to implementation files
- [ ] Document integration with task 988 multi-family construction
- [ ] Specify test cases for verifying saturation property
- [ ] List potential implementation blockers and resolutions

**Timing**: 1 hour

**Deliverable**:
Integration section in design document

**File Mapping**:

| Design Component | Implementation File | Existing Infrastructure |
|------------------|---------------------|------------------------|
| `ModalWitnessData` | New: `Metalogic/Bundle/ModalWitnessData.lean` | Uses: `buildWitnessMCS` from WitnessChainFMCS |
| `witnessAsCanonicalMCS` | New or extend: `CanonicalFMCS.lean` | Uses: `CanonicalMCS` structure |
| `SaturatedCanonicalBFMCS` | New: `Metalogic/Bundle/SaturatedCanonicalBFMCS.lean` | Uses: `BFMCS`, `is_modally_saturated` |
| Saturation proof | Same file | Uses: `saturated_modal_backward` |

**Integration with Task 988**:

Task 988 currently uses `MultiFamilyBFMCS.lean` with a sorry at `modal_backward`. The integration path:

1. Task 1003 implements `SaturatedCanonicalBFMCS` following this design
2. Task 988 replaces `singletonCanonicalBFMCS` with `SaturatedCanonicalBFMCS`
3. The `modal_backward` sorry is eliminated by `saturated_modal_backward`

**Verification**:
- Integration guide is actionable
- File locations are consistent with project structure
- Dependencies are clearly identified

---

## Testing & Validation

- [ ] Design document structures type-check conceptually
- [ ] Proof strategy uses only existing proven lemmas (no new sorries)
- [ ] Integration guide maps cleanly to implementation task
- [ ] Design enables elimination of modal_backward sorry in MultiFamilyBFMCS.lean

## Artifacts & Outputs

- `specs/1002_design_modal_witness_infrastructure/plans/02_revised-modal-witness.md` (this file)
- `specs/1002_design_modal_witness_infrastructure/reports/03_design-document.md` (design document with Lean sketches)

## Rollback/Contingency

This is a design task with no code changes. The design leverages existing proven infrastructure:
- `saturated_modal_backward` in ModalSaturation.lean (sorry-free)
- `modal_witness_seed_consistent` in ChainFMCS.lean (sorry-free)
- `buildWitnessMCS` in WitnessChainFMCS.lean (sorry-free)
- `canonicalMCSBFMCS` in CanonicalFMCS.lean (sorry-free temporal coherence)

If implementation reveals design issues, revise the design document without code changes.

## Key Implementation Insight

The critical insight is that **witness MCSes are automatically CanonicalMCS elements**:

```lean
-- buildWitnessMCS returns a Set Formula that is SetMaximalConsistent
-- CanonicalMCS wraps any SetMaximalConsistent set
-- Therefore: witnessAsCanonicalMCS w : CanonicalMCS is always valid

-- This means:
-- 1. No reachability requirement (unlike the failed CanonicalReachable approach)
-- 2. The witness is automatically in the CanonicalMCS domain
-- 3. Modal saturation follows by construction
```

This mirrors the success pattern from CanonicalFMCS.lean where using ALL MCSes as domain made forward_F and backward_P trivial.
