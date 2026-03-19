# Implementation Plan: Task #988 - Dense Algebraic Completeness

- **Task**: 988 - dense_algebraic_completeness
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: Task #1000 (modal_backward blocker), Task #1001 (forward_F blocker)
- **Research Inputs**: reports/13_dense-completeness-synthesis.md (teammate A + B findings)
- **Artifacts**: plans/11_zorn-saturated-chain.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan addresses dense algebraic completeness via the Zorn saturated chain approach, avoiding the termination gap in the TimelineQuot forward_F proofs. The key insight is that instead of proving forward_F witnesses exist in a pre-built timeline, we use Zorn's lemma to construct a maximal chain that already contains witnesses by construction.

The research synthesis (13_dense-completeness-synthesis.md) identifies two independent blockers:
1. **Blocker 1**: forward_F/backward_P chain witness termination (recursive depth when j > 0)
2. **Blocker 2**: modal_backward for singleton BFMCS (requires S5 converse T axiom)

This plan uses the Zorn saturated chain approach which sidesteps Blocker 1 by construction and addresses Blocker 2 via the existing multi-family BFMCS architecture in ChainFMCS.lean.

### Research Integration

Integrated from reports/12_teammate-a-findings.md and reports/12_teammate-b-findings.md:
- ChainFMCS infrastructure provides sorry-free `chainFMCS_forward_F_in_CanonicalMCS` and `chainFMCS_backward_P_in_CanonicalMCS`
- `Flag.exists_mem` in Mathlib proves every CanonicalMCS element is in some maximal chain
- Saturation is established by Zorn upper bound construction, not recursive proof
- `iterated_future_encoding_unbounded` from DovetailedCoverage.lean proves density encoding grows without bound

## Goals & Non-Goals

**Goals**:
- Define a `SaturatedFlag` predicate capturing F/P-completeness for maximal chains
- Prove Zorn's lemma gives a maximal saturated flag containing any given MCS
- Prove saturated flags satisfy DenselyOrdered, NoMinOrder, NoMaxOrder
- Apply Cantor's theorem to get ≃o Rat isomorphism
- Wire to `dense_representation_conditional` for final completeness

**Non-Goals**:
- Fixing the TimelineQuot forward_F termination gap (this plan sidesteps it)
- Singleton BFMCS approach (multi-family is required for modal_backward)
- Modifying the existing ChainFMCS infrastructure (we build on it)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Saturation predicate too weak | H | M | Strengthen to include density witnesses explicitly |
| Zorn argument universe issues | M | L | `Flag.exists_mem` already uses Classical.choice successfully |
| DN axiom insufficient for density | H | L | Literature confirms DN characterizes density in tense logic |
| ChainFMCS modal_backward gap | H | M | Multi-family BFMCS bundle architecture handles this |
| Cantor theorem typing issues | M | M | Use existing `cantor_iso` infrastructure from CantorApplication.lean |

## Implementation Phases

### Phase 1: Saturated Chain Definition and Zorn Argument [COMPLETED]

**Goal**: Define the saturated chain predicate and prove Zorn gives a maximal saturated flag containing any root MCS.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean`
- [ ] Define `FlagSaturated : Flag CanonicalMCS → Prop` capturing forward_F and backward_P completeness:
  - For all `w` in flag, if `F phi ∈ w.world`, then exists `v > w` in flag with `phi ∈ v.world`
  - For all `w` in flag, if `P phi ∈ w.world`, then exists `v < w` in flag with `phi ∈ v.world`
- [ ] Define `SaturatedChain : Set CanonicalMCS → Prop` for chains (not necessarily maximal)
- [ ] Prove: if `C` is a chain of saturated flags, then `⋃C` is saturated (Zorn chain closure)
- [ ] Prove: `exists_saturated_flag_containing` - Zorn gives maximal saturated flag containing M₀

**Timing**: 3 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean` - New file

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.SaturatedChain`
- No sorries in Phase 1 deliverables

---

### Phase 2: Density and Order Properties [IN PROGRESS]

**Goal**: Prove saturated flags satisfy DenselyOrdered, NoMinOrder, NoMaxOrder using the DN axiom and seriality.

**Tasks**:
- [ ] Add to `SaturatedChain.lean` or create `SaturatedChainProperties.lean`
- [ ] Prove `saturatedFlag_denselyOrdered`: Between any `w < w'` in saturated flag, exists `v` with `w < v < w'`
  - Use DN axiom: `F(F phi) → F phi` + saturation to find density witnesses
  - Key lemma: `iterated_future_in_mcs` from CantorPrereqs.lean
- [ ] Prove `saturatedFlag_noMinOrder`: No minimum element
  - Use seriality: every MCS contains `P(neg bot)`, saturation gives witness
- [ ] Prove `saturatedFlag_noMaxOrder`: No maximum element
  - Use seriality: every MCS contains `F(neg bot)`, saturation gives witness
- [ ] Prove `saturatedFlag_countable`: Flag is countable (via Countable CanonicalMCS)
- [ ] Establish `saturatedFlag_isCountableDenseLinearOrder`: Combine above properties

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean` - Add order properties

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.SaturatedChain`
- Verify `DenselyOrdered`, `NoMinOrder`, `NoMaxOrder` instances compile

---

### Phase 3: Cantor Isomorphism and BFMCS Construction [NOT STARTED]

**Goal**: Apply Cantor's theorem to saturated flag, build BFMCS over Rat, wire to completeness.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/SaturatedChainBFMCS.lean`
- [ ] Define `SaturatedFlagDomain flag : Type` as `{ w : CanonicalMCS // w ∈ flag }`
- [ ] Prove `SaturatedFlagDomain` satisfies `CountableDenseLinearOrder` without endpoints
- [ ] Apply `cantor_iso_rat` (from Mathlib or CantorApplication.lean) to get `≃o Rat`
- [ ] Define `saturatedFMCS : FMCS (SaturatedFlagDomain flag)` using chainFMCS infrastructure
- [ ] Transfer to `saturatedRatFMCS : FMCS Rat` via isomorphism
- [ ] Define `saturatedBFMCS : BFMCS Rat` as multi-family bundle
- [ ] Prove `saturatedBFMCS_temporally_coherent` using saturation properties

**Timing**: 3 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChainBFMCS.lean` - New file

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.SaturatedChainBFMCS`
- No sorries in BFMCS construction

---

### Phase 4: Wire to Completeness and Integration [NOT STARTED]

**Goal**: Connect saturated chain BFMCS to dense_representation_conditional for final completeness theorem.

**Tasks**:
- [ ] In `SaturatedChainBFMCS.lean` or new `DenseCompletenessViaZorn.lean`:
- [ ] Define `construct_bfmcs_rat_saturated` matching signature of `construct_bfmcs_rat`:
  ```lean
  noncomputable def construct_bfmcs_rat_saturated (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
      Σ' (B : BFMCS ℚ) (h_tc : B.temporally_coherent)
         (fam : FMCS ℚ) (hfam : fam ∈ B.families) (t : ℚ),
         M = fam.mcs t
  ```
- [ ] Prove root MCS appears in the saturated BFMCS at the isomorphism image of root flag element
- [ ] Prove `valid_dense_of_provable` using `dense_representation_conditional`
- [ ] Update `AlgebraicDense.lean` to use saturated chain construction
- [ ] Remove or archive TimelineQuot-based approach sorries

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChainBFMCS.lean` - Add completeness wiring
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicDense.lean` - Update to use new construction
- `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean` - Archive or replace sorries

**Verification**:
- `lake build` - Full project builds
- Verify `valid_dense_of_provable` has no sorries (or only well-documented blockers)
- Verify sorry count in Algebraic/ directory decreased

---

## Testing & Validation

- [ ] `lake build` passes with no new errors
- [ ] `grep -c sorry Theories/Bimodal/Metalogic/Algebraic/*.lean` shows reduction from baseline
- [ ] Key theorems compile without sorry:
  - `exists_saturated_flag_containing`
  - `saturatedFlag_denselyOrdered`
  - `saturatedBFMCS_temporally_coherent`
- [ ] Document any remaining sorries with clear dependency analysis

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean` - Core definitions and Zorn argument
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChainBFMCS.lean` - BFMCS construction
- `specs/988_dense_algebraic_completeness/plans/11_zorn-saturated-chain.md` - This plan
- `specs/988_dense_algebraic_completeness/summaries/MM_zorn-chain-summary.md` - Execution summary

## Rollback/Contingency

- If Zorn approach encounters fundamental obstacle:
  1. Archive SaturatedChain*.lean files
  2. Fall back to total-depth induction fix (Option 4 from research)
  3. Restructure Boneyard forward_F proofs to use `total = j + i` induction

- If saturation predicate proves insufficient:
  1. Strengthen to include explicit density witness enumeration
  2. Consider hybrid approach with dovetailed construction

- Preserve existing TimelineQuot infrastructure until new approach is verified
