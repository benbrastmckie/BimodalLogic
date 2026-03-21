# Implementation Plan: Task #1008

- **Task**: 1008 - Establish genuine truth_at completeness theorems for TM logic
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: Task #1007 (archive satisfies_at infrastructure)
- **Research Inputs**: specs/1008_genuine_truth_at_completeness/reports/01_completeness-architecture.md
- **Artifacts**: plans/02_completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan establishes genuine completeness theorems for base, dense, and discrete TM logic using `truth_at` semantics over `TaskFrame D` with convex `WorldHistory` structures. The core challenge is constructing a multi-family `BFMCS D` satisfying both modal coherence (modal_backward requires multiple families) and temporal coherence (forward_F/backward_P).

The parametric infrastructure is already sorry-free: `ParametricCanonicalTaskFrame D`, `parametric_to_history` with `domain = True` (trivially convex), and `parametric_shifted_truth_lemma`. The blocking problem is providing `construct_bfmcs` for concrete D values.

### Research Integration

Research report `01_completeness-architecture.md` identified:
- The CanonicalFMCS construction over CanonicalMCS has sorry-free F/P (all MCSs in domain)
- The fundamental limitation: CanonicalMCS is a Preorder, not an ordered abelian group
- Four approaches: (A) D = Int with universal domain, (B) Omega-squared construction, (C) Transfer from CanonicalMCS, (D) Separate base/dense/discrete
- This plan follows **Approach A + C**: use `domain = True` + transfer FMCS structure via embedding

## Goals & Non-Goals

**Goals**:
- Complete `parametric_algebraic_representation_conditional` by providing `construct_bfmcs` for D = Int
- Extend to D = Rat for dense completeness using Cantor embedding
- Wire completeness theorems to export modules (`AlgebraicBaseCompleteness`, `AlgebraicDenseCompleteness`)
- Eliminate blocking sorries in the completeness pipeline

**Non-Goals**:
- Full discrete completeness (requires SuccOrder/PredOrder from Task 974)
- Constructing CanonicalMCS-to-Int bijection (impossible - different cardinalities)
- Achieving sorry-free modal_backward for singleton BFMCS (fundamentally impossible)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multi-family BFMCS requires complex construction | H | M | Use modal saturation module to generate required families |
| CanonicalMCS transfer loses structure | H | L | Work with FMCS D where D = CanonicalMCS, avoid embedding |
| F/P coherence for Int chain unsolvable | H | H | Use CanonicalMCS directly as D parameter (Preorder suffices for completeness) |
| Dense/discrete require different approaches | M | M | Phase 5-6 address variant-specific challenges |

## Implementation Phases

### Phase 1: Establish CanonicalMCS-Based Completeness [NOT STARTED]

**Goal**: Prove base completeness using D = CanonicalMCS with existing sorry-free infrastructure.

**Tasks**:
- [ ] Create `AlgebraicCanonicalCompletenessBase.lean` module
- [ ] Define `construct_bfmcs_CanonicalMCS` using `canonicalMCSBFMCS` from CanonicalFMCS.lean
- [ ] Wire modal saturation to achieve multi-family BFMCS (use `modal_saturated_bfmcs`)
- [ ] Instantiate `parametric_algebraic_representation_conditional` with D = CanonicalMCS
- [ ] Export `CanonicalMCS_base_completeness : valid phi -> provable phi`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicCanonicalCompletenessBase.lean` (create)
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` (extend if needed)

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.AlgebraicCanonicalCompletenessBase`
- Confirm no sorries in completeness theorem
- Check that `valid` uses `truth_at` semantics

---

### Phase 2: Multi-Family BFMCS via Modal Saturation [NOT STARTED]

**Goal**: Construct proper multi-family BFMCS to eliminate modal_backward sorry.

**Tasks**:
- [ ] Analyze `ModalSaturation.lean` for `modal_saturated_bfmcs` construction
- [ ] Verify `modal_backward` is satisfied via saturation (all Box-equivalence classes represented)
- [ ] Connect saturated BFMCS to temporal coherent family existence
- [ ] Prove `saturated_bfmcs_temporally_coherent` using CanonicalMCS forward_F/backward_P

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean`

**Verification**:
- No sorry in `modal_backward` for saturated BFMCS
- `temporally_coherent` proven for saturated families

---

### Phase 3: Int-Indexed Completeness via CanonicalMCS Slicing [NOT STARTED]

**Goal**: Provide Int-indexed completeness by slicing CanonicalMCS along a chain.

**Tasks**:
- [ ] Define `Int_slice : Int -> CanonicalMCS` as a chain selector within CanonicalMCS
- [ ] Create `slice_FMCS_Int : FMCS Int` from `canonicalMCSBFMCS` via `Int_slice`
- [ ] Prove `slice_forward_F` and `slice_backward_P` using CanonicalMCS F/P (witness exists in full CanonicalMCS, then show it's in the chain via Lindenbaum properties)
- [ ] Alternatively: accept CanonicalMCS as the canonical D and export completeness for that

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/IntSliceCompleteness.lean` (create)
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` (extend)

**Verification**:
- `lake build` passes
- F/P sorries eliminated or clearly documented as non-blocking

---

### Phase 4: Wire Base Completeness Export [NOT STARTED]

**Goal**: Connect completeness to public export interface.

**Tasks**:
- [ ] Update `AlgebraicBaseCompleteness.lean` to use CanonicalMCS-based construction
- [ ] Remove dependency on sorry-backed `construct_bfmcs_from_mcs_Int`
- [ ] Export `base_completeness_truth_at : valid_truth_at phi -> provable phi`
- [ ] Document relationship between CanonicalMCS completeness and Int completeness

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean`
- `Theories/Bimodal/Metalogic/Representation.lean`

**Verification**:
- `AlgebraicBaseCompleteness` has no sorry or sorry-backed dependencies
- Exports use `truth_at`, not `satisfies_at`

---

### Phase 5: Dense Completeness via Cantor Transfer [NOT STARTED]

**Goal**: Establish dense completeness using Cantor isomorphism to Rat.

**Tasks**:
- [ ] Complete `ratFMCS_forward_F` and `ratFMCS_backward_P` in CanonicalEmbedding.lean
- [ ] Strategy: show TimelineQuot includes canonical F/P witnesses by staged construction
- [ ] Prove `TimelineQuot_includes_F_witness` using `StagedExecution` seed adding
- [ ] Wire to `construct_bfmcs_rat` for dense completeness
- [ ] Export `dense_completeness_truth_at : valid_dense phi -> provable phi`

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean` (if F-seed verification needed)
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean`

**Verification**:
- `ratFMCS_forward_F` and `ratFMCS_backward_P` sorry-free
- `dense_completeness_truth_at` exported

---

### Phase 6: Discrete Completeness Scaffolding [NOT STARTED]

**Goal**: Prepare discrete completeness structure (blocked by Task 974 for full proof).

**Tasks**:
- [ ] Create `AlgebraicDiscreteCompleteness.lean` scaffold
- [ ] Document dependency on `SuccOrder Int` and `PredOrder Int` from Task 974
- [ ] Define `discrete_completeness_conditional` assuming DF axiom witness existence
- [ ] Wire conditional completeness to export interface with clear sorry documentation

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicDiscreteCompleteness.lean` (create)
- `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean`

**Verification**:
- Scaffold compiles
- Sorries clearly document Task 974 dependency

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Algebraic.AlgebraicCanonicalCompletenessBase` succeeds
- [ ] `lake build Bimodal.Metalogic.Algebraic.AlgebraicBaseCompleteness` succeeds
- [ ] `lake build Bimodal.Metalogic.DenseCompleteness` succeeds
- [ ] Grep for `sorry` in modified files shows expected count reduction
- [ ] `lean_verify` confirms no axiom dependencies beyond standard library

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicCanonicalCompletenessBase.lean` - Core completeness
- `Theories/Bimodal/Metalogic/Algebraic/IntSliceCompleteness.lean` - Int-indexed variant
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicDiscreteCompleteness.lean` - Discrete scaffold
- Updated `AlgebraicBaseCompleteness.lean`, `CanonicalEmbedding.lean`, `DenseCompleteness.lean`
- `specs/1008_genuine_truth_at_completeness/summaries/03_completeness-summary.md` - Implementation summary

## Rollback/Contingency

If multi-family BFMCS construction proves intractable:
1. Accept CanonicalMCS-based completeness as the primary result
2. Document Int/Rat completeness as "requiring additional structure"
3. Export CanonicalMCS completeness as the genuine truth_at result
4. Archive Int/Rat attempts to Boneyard with clear documentation

The CanonicalMCS-based completeness is independently valuable and uses `truth_at` correctly. The F/P coherence is trivially satisfied because all MCSs are in the domain. This provides a genuine completeness theorem even if Int/Rat transfer proves difficult.
