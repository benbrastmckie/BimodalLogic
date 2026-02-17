# Implementation Plan: Task #887

- **Task**: 887 - Create FinalConstruction.lean and prove fully_saturated_bmcs_exists_int
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/887_create_finalconstruction_prove_fully_saturated_bmcs/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Create FinalConstruction.lean that combines modal saturation (from SaturatedConstruction.lean) with temporal coherence (from TemporalCoherentConstruction.lean) to implement a sorry-free proof of `fully_saturated_bmcs_exists_int`. The key insight from research is that `constant_family_temporally_saturated_is_coherent` is already proven - constant families from temporally saturated MCSes are temporally coherent. The approach uses this existing infrastructure to ensure witness families added during modal saturation inherit temporal coherence.

### Research Integration

Research report (research-001.md) identified:
1. `constructSaturatedBMCS` returns modally saturated BMCS with all constant families
2. `constant_family_temporally_saturated_is_coherent` proves constant families from temporally saturated MCSes are coherent
3. The gap: witness families are built with regular Lindenbaum, not temporal Lindenbaum
4. **Option B (Most Viable)**: Prove regular Lindenbaum preserves temporal saturation when seed is temporally saturated

## Goals & Non-Goals

**Goals**:
- Create FinalConstruction.lean with sorry-free `fully_saturated_bmcs_exists_int`
- Combine modal saturation from `exists_fullySaturated_extension` with temporal coherence from DovetailingChain
- Prove `lindenbaum_preserves_temporal_saturation` - that regular Lindenbaum preserves temporal saturation
- Ensure witness families constructed during modal saturation are temporally coherent

**Non-Goals**:
- Fixing sorries in TemporalLindenbaum.lean (those remain as separate technical debt)
- Fixing sorries in DovetailingChain.lean (those remain as mathematical technical debt)
- Implementing InterleaveConstruction (alternative approach - not this task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `lindenbaum_preserves_temporal_saturation` proof is more complex than expected | H | M | Fall back to direct construction approach or accept DovetailingChain sorries |
| Witness seed may not preserve temporal saturation through Box/Diamond content | H | L | Extend seed to include GContent/HContent explicitly |
| Circular import issues between SaturatedConstruction and TemporalCoherentConstruction | M | L | FinalConstruction imports both - no circular dependency |
| Proof fails due to missing infrastructure | M | M | Can add partial result with sorry, document remaining work |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:822) - the target
- 1 sorry in `fully_saturated_bmcs_exists_constructive` (SaturatedConstruction.lean:1367) - related
- 6 sorries in TemporalLindenbaum.lean - out of scope
- 4 sorries in DovetailingChain.lean - out of scope (mathematically valid)

### Expected Resolution
- Phase 3 resolves the sorry in `fully_saturated_bmcs_exists_int` by proving it via the combined construction
- The sorry in `fully_saturated_bmcs_exists_constructive` may be resolved as a consequence

### New Sorries
- None expected if `lindenbaum_preserves_temporal_saturation` can be proven
- If not provable, may need 1 sorry for temporal preservation, documented with remediation path

### Remaining Debt
After this implementation:
- 0 sorries in FinalConstruction.lean (target)
- TemporalLindenbaum.lean sorries remain (separate technical debt)
- DovetailingChain.lean sorries remain (separate technical debt)

## Axiom Characterization

### Pre-existing Axioms
- `fully_saturated_bmcs_exists` in TemporalCoherentConstruction.lean is an **axiom** (not a sorry)
- This axiom provides the polymorphic version for any OrderedCommGroup D

### Expected Resolution
- Phase 3 provides a proven theorem for D = Int, eliminating need for axiom in Int case
- The polymorphic axiom remains for generic D (expected, as Int is the primary use case)

### New Axioms
- None. NEVER introduce new axioms. If proof complexity requires gap, use sorry with remediation timeline.

### Remaining Debt
After this implementation:
- 0 new axioms
- `fully_saturated_bmcs_exists` axiom remains for polymorphic case (expected)
- For D = Int, `fully_saturated_bmcs_exists_int` theorem provides constructive proof

## Implementation Phases

### Phase 1: Lindenbaum Temporal Preservation [NOT STARTED]

- **Dependencies:** None
- **Goal:** Prove that regular Lindenbaum extension preserves temporal saturation when applied to a temporally saturated seed

**Tasks**:
- [ ] Create FinalConstruction.lean with initial imports and namespace
- [ ] Define `TemporalForwardSaturated` for sets: `∀ φ, F(φ) ∈ S → φ ∈ S`
- [ ] Define `TemporalBackwardSaturated` for sets: `∀ φ, P(φ) ∈ S → φ ∈ S`
- [ ] Prove `lindenbaum_step_preserves_forward_sat`: adding a consistent formula preserves forward saturation
- [ ] Prove `lindenbaum_step_preserves_backward_sat`: adding a consistent formula preserves backward saturation
- [ ] Prove `lindenbaum_preserves_temporal_saturation`: full Lindenbaum chain preserves temporal saturation

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` - create new file

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.FinalConstruction` succeeds
- `lindenbaum_preserves_temporal_saturation` compiles without sorry

---

### Phase 2: Temporally Saturated Witness Construction [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Show that witness families built from temporally saturated seeds produce temporally coherent constant families

**Tasks**:
- [ ] Prove witness seed `{ψ} ∪ BoxContent(M) ∪ GContent(M) ∪ HContent(M)` is temporally saturated when M is temporally saturated
- [ ] Define `build_temporally_saturated_witness_family` using temporally saturated seed + Lindenbaum
- [ ] Apply `constant_family_temporally_saturated_is_coherent` to show result is temporally coherent
- [ ] Prove `witness_family_temporal_coherence`: witness families from temporally saturated MCS are temporally coherent

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` - add witness construction

**Verification**:
- `witness_family_temporal_coherence` compiles without sorry
- All helper lemmas compile without sorry

---

### Phase 3: Combined Construction Proof [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove `fully_saturated_bmcs_exists_int` constructively by combining temporal coherent initial family with temporally-aware modal saturation

**Tasks**:
- [ ] Import `temporal_coherent_family_exists_Int` from DovetailingChain (provides temporally coherent initial family)
- [ ] Modify construction to use temporal saturation-preserving witness construction
- [ ] Prove all witness families in the saturated BMCS are temporally coherent
- [ ] Combine to prove `BMCS.temporally_coherent` for the constructed BMCS
- [ ] Complete proof of `fully_saturated_bmcs_exists_int` without sorry
- [ ] Add documentation explaining the construction approach

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` - complete main theorem

**Verification**:
- `fully_saturated_bmcs_exists_int` compiles without sorry
- `lake build` succeeds with no new sorries or axioms in this file

---

### Phase 4: Integration and Documentation [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Integrate FinalConstruction.lean into the build and update documentation

**Tasks**:
- [ ] Add FinalConstruction.lean to ProofChecker.lean imports
- [ ] Run full `lake build` to verify no regressions
- [ ] Update SaturatedConstruction.lean summary to reference FinalConstruction.lean
- [ ] Update TemporalCoherentConstruction.lean to document that Int case now has constructive proof
- [ ] Verify sorry count reduction via `grep -r "sorry" Theories/ | wc -l`

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` - final documentation
- `ProofChecker.lean` - add import
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - update summary
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - update documentation

**Verification**:
- `lake build` succeeds
- No new sorries or axioms introduced
- Documentation accurately reflects the construction

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.FinalConstruction` succeeds without error
- [ ] `fully_saturated_bmcs_exists_int` has no sorry
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` returns 0
- [ ] `lake build` succeeds (full project build)
- [ ] No new axioms in FinalConstruction.lean

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/FinalConstruction.lean` - new file with constructive proof
- `specs/887_create_finalconstruction_prove_fully_saturated_bmcs/summaries/implementation-summary-YYYYMMDD.md` - completion summary

## Rollback/Contingency

If the proof approach fails:
1. FinalConstruction.lean can be reverted (new file, no dependencies yet)
2. The existing sorry-backed `fully_saturated_bmcs_exists_int` in TemporalCoherentConstruction.lean remains functional
3. Alternative: accept DovetailingChain's 4 sorries as transitive dependency rather than eliminating them
4. Document blockers in plan for future remediation
