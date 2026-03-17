# Implementation Plan: Dense Algebraic Completeness via Multi-Family W/D Separation (v4)

- **Task**: 988 - dense_algebraic_completeness
- **Status**: [NOT STARTED]
- **Effort**: 15 hours (5 phases)
- **Dependencies**: Task 985 (complete)
- **Research Inputs**: research-005.md (forward_F blocker analysis, multi-family recommendation)
- **Artifacts**: plans/04_multi-family-dense-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This v4 plan implements the **Multi-Family W/D Separation Architecture** recommended in research-005.md. The key insight is that witnesses don't need to be in D (the time domain) - they need to be in W (the world state space). This resolves the forward_F blocker that blocked v3.

**Root Cause of v3 Blocker**: `canonical_forward_F` witnesses (via Lindenbaum extension) may not be CanonicalR-reachable from the root MCS, hence not in TimelineQuot. The staged construction only contains MCS reachable from M0.

**The Solution**:
- **D = TimelineQuot ≃o Rat** (provides LinearOrder, Countable, DenselyOrdered, NoEndpoints - already proven)
- **W = CanonicalMCS** (provides ALL witnesses via proven `canonicalMCS_forward_F`, `canonicalMCS_backward_P`)
- **Multi-family BFMCS**: Witness families provide F/P witnesses from CanonicalMCS; the BFMCS `temporally_coherent` condition is satisfied across families

### Research Integration

Key findings from research-005.md Section 5-6:
1. TimelineQuot provides all order-theoretic properties needed for D (via CantorApplication.lean)
2. `canonicalMCS_forward_F` and `canonicalMCS_backward_P` in CanonicalFMCS.lean are **fully proven without sorry**
3. The ParametricTruthLemma's backward direction requires `B.temporally_coherent`, which only needs F/P witnesses to exist in SOME family
4. Multi-history witness pattern from ParametricTruthLemma.lean already handles cross-family witnesses (parametric_shifted_truth_lemma)

## Goals & Non-Goals

**Goals**:
- Define multi-family BFMCS over Rat with D = TimelineQuot (via Cantor), W = CanonicalMCS
- Construct witness families using existing `canonicalMCS_forward_F`/`canonicalMCS_backward_P`
- Prove `BFMCS.temporally_coherent` for the multi-family bundle
- Provide `construct_bfmcs_rat` satisfying `dense_representation_conditional` signature
- Prove `dense_algebraic_completeness : valid_dense phi -> Nonempty (DerivationTree [] phi)`
- Zero sorries, zero new axioms

**Non-Goals**:
- Proving `timelineQuotFMCS_forward_F` directly within TimelineQuot (this is the blocker)
- Modifying the staged construction (dovetailing, backlog processing)
- Using constant witness families (proven flawed in ModalSaturation.lean archive)
- Changing the parametric truth lemma infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Witness family coherence breaks FMCS properties | High | LOW | Witness families inherit forward_G/backward_H from CanonicalMCS structure |
| Modal saturation complexity for multi-family BFMCS | Medium | MEDIUM | Follow saturated_modal_backward pattern from ModalSaturation.lean |
| Cantor transfer of multi-family structure | Medium | LOW | Transfer each family independently, preserve coherence conditions |
| Type mismatch between TimelineQuot and CanonicalMCS domains | High | LOW | Use parametric history mapping h : D -> W with explicit separation |

## Sorry Characterization

### Pre-existing Sorries in Scope
- `timelineQuotFMCS_forward_F` (ClosureSaturation.lean:659) - **bypassed** by multi-family approach
- `timelineQuotFMCS_backward_P` (ClosureSaturation.lean:664) - **bypassed** by multi-family approach

### Expected Resolution
- No new sorries introduced
- Existing sorries remain (in unused code path) - this plan bypasses them via multi-family architecture

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

## Implementation Phases

### Phase 1: CanonicalMCS-based FMCS Structure [BLOCKED]

**Goal**: Define an FMCS over Rat using CanonicalMCS as the MCS source, with forward_F/backward_P from existing proven theorems.

**Key Insight**: Rather than proving forward_F for TimelineQuot, we define an FMCS that directly uses CanonicalMCS witnesses. The time domain is Rat (or TimelineQuot via Cantor), but the MCS assignment comes from CanonicalMCS.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/CanonicalRatFMCS.lean`
- [ ] Define `CanonicalRatMCSAssignment : Rat -> CanonicalMCS` using Cantor embedding
  - Extract `cantor_iso : TimelineQuot ≃o Rat` from CantorApplication.lean
  - Define `ratToTimelineQuot : Rat -> TimelineQuot` via inverse of Cantor
  - Map TimelineQuot to its associated MCS via `timelineQuotMCS`
- [ ] Define `canonicalRatFMCS : FMCS Rat` with:
  - `mcs : Rat -> Set Formula := fun r => (ratToMCS r).world`
  - `is_mcs : forall r, SetMaximalConsistent (mcs r)` - from CanonicalMCS definition
  - `forward_G`, `backward_H` - from timelineQuotFMCS (preserved through Cantor)
- [ ] Prove `canonicalRatFMCS_forward_F : forall t phi, F(phi) in mcs t -> exists s > t, phi in mcs s`
  - Route to `canonicalMCS_forward_F` for the witness MCS
  - The witness may not be at a TimelineQuot time, handle via witness family (Phase 2)
- [ ] Prove `canonicalRatFMCS_backward_P` symmetrically

**Timing**: 4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalRatFMCS.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.CanonicalRatFMCS` passes
- `grep -n "\bsorry\b" CanonicalRatFMCS.lean` returns empty

---

### Phase 2: Witness Family Construction [NOT STARTED]

**Goal**: Define witness families for F/P obligations that cannot be satisfied within the primary family's timeline.

**Key Insight**: When `F(phi) in primary.mcs t` but no `s > t` in TimelineQuot has `phi in primary.mcs s`, we construct a witness family. The witness MCS W from `canonicalMCS_forward_F` exists in CanonicalMCS. We create a family where W appears at an appropriate time.

**Approach**: For each unsatisfied F/P obligation, construct a witness family that:
1. Maps some time point to the witness MCS W
2. Inherits temporal structure from CanonicalMCS properties
3. Provides the needed witness for `temporally_coherent`

**Tasks**:
- [ ] Define `WitnessFamilyData` structure capturing:
  - The origin family and time `(fam, t)`
  - The formula `phi` with `F(phi) in fam.mcs t`
  - The witness MCS `W` from `canonicalMCS_forward_F`
  - The target time `s > t` where W will appear
- [ ] Define `witnessFamily : WitnessFamilyData -> FMCS Rat`
  - Map `s` to `W`
  - Map other times appropriately (using CanonicalMCS forward_G/backward_H to extend W)
- [ ] Prove witness family satisfies FMCS properties:
  - `is_mcs` - W is MCS by construction
  - `forward_G`, `backward_H` - from CanonicalMCS properties
- [ ] Prove witness family provides the needed witness:
  - `phi in witnessFamily.mcs s` where `s > t`

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalRatFMCS.lean` (add witness family definitions)

**Verification**:
- Witness family construction compiles without sorry
- `lake build` passes

---

### Phase 3: Multi-Family BFMCS with Temporal Coherence [NOT STARTED]

**Goal**: Bundle the primary family with witness families into a BFMCS satisfying all coherence conditions.

**Key Insight**: The BFMCS contains:
1. The primary family (from Phase 1)
2. Witness families (from Phase 2) for each unsatisfied F/P obligation

The `temporally_coherent` condition requires that for each family fam:
- `F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s`

For the primary family, if the witness isn't in TimelineQuot, we use witness families. The BFMCS-level coherence is satisfied because witnesses exist in SOME family (we just need to track which).

**Note on temporally_coherent**: Reviewing the definition in TemporalCoherence.lean (line 217-220), `temporally_coherent` requires F/P witnesses **within the same family**. This means witness families themselves must satisfy forward_F/backward_P.

**Resolution**: Witness families are constructed from CanonicalMCS which has `canonicalMCS_forward_F`/`canonicalMCS_backward_P`. However, these give witnesses in CanonicalMCS (not necessarily at specific times in Rat). We need to ensure each witness family's own F/P obligations are satisfiable.

**Approach**: Use a recursive/inductive construction:
- Base: Primary family with some F/P gaps
- Step: For each gap, add witness family that may have its own gaps
- Termination: Countable formulas, each new family handles one obligation; overall construction is well-founded

**Tasks**:
- [ ] Define `MultiFamilyBFMCS : BFMCS Rat` structure
  - `families` includes primary family and all witness families
  - Ensure families is nonempty (primary family exists)
- [ ] Prove `modal_forward` and `modal_backward`:
  - For singleton primary: trivially holds
  - For multi-family: use modal saturation pattern from ModalSaturation.lean
- [ ] Prove `MultiFamilyBFMCS.temporally_coherent`:
  - For primary family: F/P at time t satisfied by witness family at s
  - For witness families: F/P satisfied by CanonicalMCS structure
- [ ] Define `construct_mult_family_bfmcs : (M : Set Formula) -> SetMaximalConsistent M -> BFMCS Rat`
  - Given MCS M, construct TimelineQuot rooted at M
  - Build primary FMCS
  - Add witness families as needed

**Timing**: 4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean`

**Verification**:
- `MultiFamilyBFMCS.temporally_coherent` proven without sorry
- `lake build` passes

---

### Phase 4: Wire to dense_representation_conditional [NOT STARTED]

**Goal**: Provide the `construct_bfmcs` function required by `dense_representation_conditional` in DenseInstantiation.lean.

**Tasks**:
- [ ] Define `construct_bfmcs_rat : (M : Set Formula) -> SetMaximalConsistent M -> Sigma' (B : BFMCS Rat) ...`
  - Use `construct_mult_family_bfmcs` from Phase 3
  - Return sigma type with:
    - `B : BFMCS Rat`
    - `h_tc : B.temporally_coherent`
    - `fam : FMCS Rat` (the primary family)
    - `hfam : fam in B.families`
    - `t : Rat` (time 0 or the evaluation point)
    - `h_eq : M = fam.mcs t`
- [ ] Instantiate `dense_representation_conditional` with `construct_bfmcs_rat`
- [ ] Define `dense_representation : not_provable phi -> exists countermodel`
  - Direct application of conditional theorem with constructor

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`
  - Import MultiFamilyBFMCS.lean
  - Add `construct_bfmcs_rat`
  - Add `dense_representation`

**Verification**:
- `dense_representation_conditional` instantiates correctly
- `lake build` passes

---

### Phase 5: Dense Algebraic Completeness Theorem [NOT STARTED]

**Goal**: Prove the final completeness theorem: `valid_dense phi -> Nonempty (DerivationTree [] phi)`.

**Tasks**:
- [ ] Define `valid_dense : Formula -> Prop`
  - phi is valid in all dense TaskFrame models (D = Rat with DenselyOrdered)
  - Or use the DenseCanonicalTaskFrame specific validity
- [ ] Define `valid_in_dense_canonical : Formula -> Prop`
  - phi is true at all histories, all times in DenseCanonicalTaskModel
- [ ] Prove connection between validity notions:
  - `valid_dense phi -> valid_in_dense_canonical phi` (soundness of canonical model)
  - Or use existing soundness infrastructure
- [ ] Prove `dense_algebraic_completeness`:
  ```lean
  theorem dense_algebraic_completeness (phi : Formula) :
      valid_dense phi -> Nonempty (Bimodal.ProofSystem.DerivationTree [] phi)
  ```
  - Contrapositive of `dense_representation`:
    - If not provable, then countermodel exists (from Phase 4)
    - Contrapositive: if valid (no countermodel), then provable
- [ ] Add module to lakefile and verify full build
- [ ] Create implementation summary

**Timing**: 3 hours (includes summary writing)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean`
  - Add `valid_dense` definition
  - Add `dense_algebraic_completeness` theorem
- `Theories/Bimodal.lean` (module imports if needed)

**Verification**:
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Algebraic/*.lean` returns no new sorries
- `grep -n "^axiom "` in new files shows no new axioms
- `dense_algebraic_completeness` theorem type-checks

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] All new files have zero sorries
- [ ] No new axioms introduced
- [ ] `dense_algebraic_completeness` theorem exists and type-checks

### Theorem Verification
- [ ] `canonicalRatFMCS` satisfies FMCS interface
- [ ] Witness families satisfy FMCS properties
- [ ] `MultiFamilyBFMCS.temporally_coherent` is fully proven
- [ ] `construct_bfmcs_rat` satisfies `dense_representation_conditional` signature
- [ ] Final theorem chain: unprovable -> countermodel -> not valid_dense (contrapositive gives completeness)

## Artifacts & Outputs

**New files**:
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalRatFMCS.lean` - Phase 1
- `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean` - Phase 3

**Modified files**:
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` - Phases 4-5
- `Theories/Bimodal.lean` (module imports)

**Summary (on completion)**:
- `specs/988_dense_algebraic_completeness/summaries/05_execution-summary.md`

## Rollback/Contingency

If the multi-family approach encounters fundamental issues:

1. **Witness family coherence fails**:
   - Review whether witness families need to satisfy forward_F/backward_P independently
   - May need to recursively construct witness families for witness families
   - Alternative: prove witness families have "trivial" F/P (all obligations immediately satisfied)

2. **Modal saturation for multi-family BFMCS fails**:
   - Review `saturated_modal_backward` pattern in ModalSaturation.lean
   - May need explicit modal saturation construction

3. **Type mismatch in Cantor transfer**:
   - Work directly with TimelineQuot instead of Rat
   - The representation theorem holds for any D satisfying the constraints

4. **Construction complexity exceeds timeline**:
   - Split into sub-tasks: Phase 1-2 as one task, Phase 3-5 as another
   - Each phase can be independently verified

The multi-family W/D separation architecture from research-005.md is mathematically sound and aligned with standard completeness proofs in the literature. The key is that witnesses don't need to be in D - they need to be in W.
