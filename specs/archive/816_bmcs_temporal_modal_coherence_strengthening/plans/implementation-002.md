# Implementation Plan: Task #816

- **Task**: 816 - bmcs_temporal_modal_coherence_strengthening
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (builds on existing BMCS infrastructure)
- **Research Inputs**: specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-013.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement **modal-saturated multi-family BMCS construction** to eliminate the `modal_backward` sorry in `Construction.lean` and connect the completeness proof to `Validity.lean`. The current single-family BMCS trivializes modal semantics because `Box phi = phi` when there is only one family.

The correct approach uses FMP bounds (2^|closure| families, 2*temporalDepth+1 time points) to construct a finite BMCS that is **modal-saturated**: for every diamond formula `Diamond psi` in the closure, if it is in any MCS, there exists a witness family where `psi` holds.

### Research Integration

From research-013.md:
- Single-family construction is architecturally wrong (trivializes modal dimension)
- `modal_backward` sorry exists because one family cannot provide diamond witnesses
- FMP bounds: at most 2^|closure| distinct families needed
- Temporal backward sorries are omega-rule limitations (mathematically unavoidable)
- Modal saturation enables sorry-free `modal_backward` by construction

### Previous Plan (001) Status

Implementation-001 attempted forward-direction-only restructuring but was marked [PARTIAL]. The goal was to eliminate sorries by only proving the forward direction. This is inadequate because:
1. The implication case proof structure requires IH in both directions
2. `modal_backward` sorry in Construction.lean remains regardless of TruthLemma structure
3. Does not address the fundamental single-family limitation

This plan supersedes implementation-001 with the correct multi-family approach.

## Goals & Non-Goals

**Goals**:
- Implement modal-saturated multi-family BMCS construction
- Prove `modal_backward` from modal saturation (no sorry)
- Connect saturated BMCS to `Validity.lean` completeness
- Document why temporal backward sorries are mathematically unavoidable (omega-rule)
- Achieve sorry-free completeness for modal operators

**Non-Goals**:
- Proving temporal backward directions (omega-rule limitation - fundamental)
- Implementing omega-saturation for temporal operators (infinitary construction)
- Full FMP formalization with explicit cardinality bounds (can be future work)
- Changing the temporal operator semantics

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Modal saturation construction is complex | High | Medium | Leverage existing Closure.lean and FMP infrastructure |
| Universe polymorphism issues with saturation | Medium | Medium | Use Int-specific construction, lift to polymorphic later |
| IndexedMCSFamily coherence for new families | High | Medium | Use constant family pattern from existing construction |
| Interaction with existing Completeness.lean | Medium | Low | Completeness uses forward direction only; should be compatible |
| FMP bounds proof complexity | Medium | High | Start with existence proof; explicit bounds can follow |

## Implementation Phases

### Phase 1: Modal Saturation Infrastructure [NOT STARTED]

**Goal**: Define the core structures and properties for modal saturation

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- [ ] Define `DiamondFormulas (phi : Formula) : Set Formula` - diamond subformulas in closure
- [ ] Define `DiamondWitnessExists (families : Set (IndexedMCSFamily D)) (psi : Formula) (t : D)` - property that some family witnesses psi
- [ ] Define `ModalSaturated (families : Set (IndexedMCSFamily D)) (phi : Formula)` - all diamonds have witnesses
- [ ] Prove `ModalSaturated -> modal_backward` for BMCS constructed from saturated families

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`

**Verification**:
- Module compiles
- `ModalSaturated -> modal_backward` theorem compiles without sorry

---

### Phase 2: Witness Family Construction [NOT STARTED]

**Goal**: Implement the construction of witness families for diamond formulas

**Tasks**:
- [ ] Define `witnessSet (M : Set Formula) (psi : Formula) : Set Formula` - the consistent set `{psi} union {phi | Box phi in M}`
- [ ] Prove `witnessSet` is consistent when `Diamond psi` is in M (contrapositive of Box reasoning)
- [ ] Use Lindenbaum to extend `witnessSet` to MCS
- [ ] Construct `IndexedMCSFamily` from witness MCS (use constant family pattern)
- [ ] Define `addWitnessFamily (families : Set (IndexedMCSFamily D)) (phi : Formula) (t : D) : Set (IndexedMCSFamily D)`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` (add to Phase 1 file)

**Key lemma**:
```lean
lemma diamond_implies_witness_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : Formula.neg (Formula.box (Formula.neg psi)) ∈ M) :
    SetConsistent (witnessSet M psi)
```

**Verification**:
- Witness construction compiles without sorry
- `addWitnessFamily` produces valid IndexedMCSFamily

---

### Phase 3: Saturation Fixed Point [NOT STARTED]

**Goal**: Implement the modal saturation iteration to fixed point

**Tasks**:
- [ ] Define `saturationStep (families : Set (IndexedMCSFamily D)) (phi : Formula) : Set (IndexedMCSFamily D)` - one step of adding missing witnesses
- [ ] Define `saturatedFamilies (phi : Formula) (h_cons : SetConsistent {phi}) : Set (IndexedMCSFamily D)` - fixed point construction
- [ ] Prove termination: families bounded by 2^|closure| (use `closureSize` from Closure.lean)
- [ ] Prove `saturatedFamilies` is `ModalSaturated`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` (continue)

**Key insight**: The fixed point exists because:
1. Each saturation step adds at most one family per diamond formula per time
2. Diamond formulas are bounded by closure size
3. Distinct MCS restricted to closure are bounded by 2^|closure|

**Verification**:
- Fixed point construction compiles
- `ModalSaturated (saturatedFamilies phi h_cons)` theorem compiles without sorry

---

### Phase 4: Saturated BMCS Construction [NOT STARTED]

**Goal**: Replace single-family BMCS with saturated multi-family BMCS

**Tasks**:
- [ ] Create `saturatedBMCS (phi : Formula) (h_cons : SetConsistent {phi}) : BMCS D`
- [ ] Prove `modal_forward` for saturated BMCS (should follow from MCS properties)
- [ ] Prove `modal_backward` for saturated BMCS (from `ModalSaturated` property)
- [ ] Prove context preservation: `phi in eval_family.mcs 0`
- [ ] Update or add alternative to `construct_bmcs` using saturated construction

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` (continue)
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (add new construction, keep old for reference)

**Key theorem**:
```lean
noncomputable def saturatedBMCS (phi : Formula) (h_cons : SetConsistent {phi}) : BMCS D where
  families := saturatedFamilies phi h_cons
  nonempty := saturatedFamilies_nonempty phi h_cons
  modal_forward := saturatedBMCS_modal_forward phi h_cons
  modal_backward := saturatedBMCS_modal_backward phi h_cons  -- NO SORRY!
  eval_family := ...
  eval_family_mem := ...
```

**Verification**:
- `saturatedBMCS` compiles without sorry in `modal_backward`
- Build passes for Construction.lean

---

### Phase 5: Update Completeness Chain [NOT STARTED]

**Goal**: Connect saturated BMCS to Completeness.lean theorems

**Tasks**:
- [ ] Create `saturatedBMCS_representation` using `saturatedBMCS` instead of `construct_bmcs`
- [ ] Verify existing `bmcs_representation` can use the new construction
- [ ] Update docstrings to reflect sorry-free modal_backward
- [ ] Verify `Completeness.lean` still compiles (should use forward direction only)
- [ ] Add `saturated_bmcs_weak_completeness` if signatures differ

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (minor updates)

**Verification**:
- All theorems in Completeness.lean compile
- Sorry count reduced from Construction.lean

---

### Phase 6: Validity.lean Bridge [NOT STARTED]

**Goal**: Connect BMCS completeness to `Validity.lean` semantic validity

**Tasks**:
- [ ] Analyze gap between `bmcs_valid` and `Validity.valid`
- [ ] Define `TaskModel` from saturated BMCS (if not already bridged)
- [ ] Prove or document: `bmcs_valid phi -> valid phi` (requires TaskModel construction)
- [ ] Document the completeness path: `consistent -> bmcs_satisfiable -> valid` contrapositive
- [ ] Update module docstrings with completeness status

**Timing**: 1 hour

**Files to examine/modify**:
- `Theories/Bimodal/Semantics/Validity.lean` (examine)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (add bridge)
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` (add TaskModel construction if needed)

**Key insight**: The saturated BMCS with multiple families provides genuine multi-history semantics that matches Validity.lean's quantification over all WorldHistory.

**Verification**:
- Clear documentation of Validity.lean completeness status
- If bridge theorem exists, it compiles without sorry

---

### Phase 7: Documentation and Cleanup [NOT STARTED]

**Goal**: Document the construction and remaining limitations

**Tasks**:
- [ ] Update TruthLemma.lean docstrings explaining temporal sorry status
- [ ] Add detailed docstrings to ModalSaturation.lean explaining the construction
- [ ] Update BMCS.lean docstrings to reflect multi-family requirement
- [ ] Create implementation summary documenting:
  - What was changed
  - Why temporal sorries remain (omega-rule)
  - How modal_backward is now sorry-free
  - Validity.lean completeness status
- [ ] Verify full `lake build` passes

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` (docstrings)
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` (docstrings)
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` (docstrings)

**Verification**:
- All modules have clear docstrings
- `lake build` passes with no errors
- Sorry count: modal_backward eliminated, temporal backward documented as limitation

---

## Testing & Validation

- [ ] `lake build` passes with no errors
- [ ] `modal_backward` in Construction.lean has no sorry (or new saturatedBMCS has no sorry)
- [ ] Completeness.lean remains sorry-free
- [ ] TruthLemma.lean temporal sorries are documented as omega-rule limitations
- [ ] ModalSaturation.lean has clear mathematical justification in docstrings
- [ ] Grep for sorry in Bundle/ - count reduced from current baseline

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` (new file)
- Modified `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- Modified `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- Updated docstrings in TruthLemma.lean, BMCS.lean
- Implementation summary at `specs/816_bmcs_temporal_modal_coherence_strengthening/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails:
1. Restore modified files: `git checkout -- Theories/Bimodal/Metalogic/Bundle/`
2. Keep ModalSaturation.lean partial work in branch for future attempt
3. Document what failed and why
4. Current state with documented sorries is acceptable fallback

**Fallback approach**: If full saturation construction is too complex:
1. Implement simpler "two-family" construction for specific formulas
2. Prove modal_backward for specific cases
3. Document general construction as future work

## Mathematical Summary

### Why Single-Family Fails

In a single-family BMCS `{fam}`:
- `modal_backward` requires: `(forall fam' in {fam}, phi in fam'.mcs t) -> Box phi in fam.mcs t`
- This becomes: `phi in fam.mcs t -> Box phi in fam.mcs t`
- But `phi in MCS` does NOT imply `Box phi in MCS` in general modal logic

### Why Multi-Family Works

With modal saturation:
- If `Diamond psi` is in any MCS, there exists a witness family with `psi`
- Contrapositive: if `psi` is in ALL families, then `neg (Box (neg psi)) = Diamond (neg psi)` cannot be in any MCS
- Therefore `Box (neg psi)` must be in every MCS (by MCS completeness)
- This is exactly `modal_backward` for `neg psi`

### Temporal Omega-Rule Limitation

For `G phi` (all future):
- Truth -> MCS would require: `(forall t' > t, phi true at t') -> G phi in MCS at t`
- This is the omega-rule: from infinitely many premises, derive universal
- Cannot be captured by finitary proof systems
- NOT fixable by better proof engineering - fundamental limitation

### Completeness Path

```
Consistent {phi}
    |
    v (Lindenbaum)
MCS containing phi
    |
    v (Modal Saturation)
Saturated BMCS with phi true at eval point
    |
    v (Truth Lemma forward)
bmcs_valid phi
    |
    v (BMCS to TaskModel bridge)
Validity.valid phi

Contrapositive:
NOT derivable phi
    |
    v
NOT Validity.valid phi (completeness)
```
