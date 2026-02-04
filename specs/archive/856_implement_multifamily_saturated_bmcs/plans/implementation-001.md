# Implementation Plan: Task #856

- **Task**: 856 - Implement multi-family saturated BMCS construction
- **Status**: [PARTIAL]
- **Effort**: 45 hours
- **Dependencies**: None (self-contained)
- **Research Inputs**: reports/research-001.md, reports/research-002.md, reports/research-003.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete Option A (SaturatedConstruction.lean) - the mathematically most correct approach for eliminating `singleFamily_modal_backward_axiom`. This implements the standard Henkin canonical model construction using Zorn's lemma to produce a BMCS with full S5 semantics. The file has 3 sorries remaining at lines 714, 733, and 785 in `exists_fullySaturated_extension`, all related to the coherent witness construction challenge.

### Research Integration

Key findings from research-003.md integrated into this plan:
- **Root Cause**: Lindenbaum extension can add new Box formulas that create coherence obligations
- **Mathematical Soundness**: The approach is correct; sorries are formalization gaps, not mathematical flaws
- **Core Challenge**: Proving `{psi} union BoxContent` is consistent requires a modal existence lemma for collections

## Goals & Non-Goals

**Goals**:
- Resolve all 3 sorries in SaturatedConstruction.lean (lines 714, 733, 785)
- Complete the `exists_fullySaturated_extension` theorem
- Enable removal of `singleFamily_modal_backward_axiom` from Construction.lean
- Provide a mathematically correct BMCS construction with full modal saturation

**Non-Goals**:
- Completing WeakCoherentBundle.lean (alternative approach, Option B)
- Refactoring completeness.lean to use the new construction (future task)
- Addressing temporal backward directions (separate Task 857/858)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multi-family consistency lemma harder than expected | High | Medium | Develop incremental approach with helper lemmas |
| Temporal uniformity of BoxContent unachievable | Medium | Medium | Restrict to constant families where temporal uniformity is trivial |
| Controlled Lindenbaum construction not expressible in Lean | High | Low | Use classical choice with existential properties |
| Proof complexity exceeds estimates | Medium | High | Build modular infrastructure that can be reused |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries in `SaturatedConstruction.lean` at lines 714, 733, 785 (in `exists_fullySaturated_extension`)
- These block the Zorn's lemma argument for saturated BMCS construction

### Expected Resolution
- Phase 1 resolves line 733 sorry via temporal uniformity lemmas for constant families
- Phase 2 resolves line 714 sorry via modal existence lemma for box-coherent collections
- Phase 3 resolves line 785 sorry via coherent witness construction
- Phase 4 verifies overall construction and integration

### New Sorries
- None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt
After this implementation:
- 0 sorries expected in `SaturatedConstruction.lean`
- `exists_fullySaturated_extension` will be fully proven
- `singleFamily_modal_backward_axiom` can be removed from Construction.lean
- Publication no longer blocked by these specific sorries

## Implementation Phases

### Phase 1: BoxContent Temporal Uniformity [PARTIAL]

**Goal**: Resolve the sorry at line 733 by proving that BoxContent is well-behaved across times for constant families.

**Tasks**:
- [ ] Analyze the structure of constant families and their BoxContent
- [ ] Prove `constant_family_box_formula_temporal_uniform`: For constant families, `Box chi in fam.mcs s` implies `Box chi in fam.mcs t` for all s, t
- [ ] Prove `constant_boxcontent_time_invariant`: BoxContent(M) at time s equals BoxContent(M) at time t when all families are constant
- [ ] Prove `boxcontent_at_t_equals_universal`: When families are constant, BoxContent restricted to time t equals the universal BoxContent
- [ ] Apply these lemmas to resolve line 733 sorry

**Timing**: 8 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Add temporal uniformity lemmas and resolve sorry

**Verification**:
- `lake build` passes with line 733 sorry removed
- `lean_goal` shows no unsolved goals at line 733 location

---

### Phase 2: Modal Existence Lemma for Collections [NOT STARTED]

**Goal**: Resolve the sorry at line 714 by proving that `{psi} union BoxContent` is consistent when `Diamond psi` is in a box-coherent collection.

**Tasks**:
- [ ] Formalize the modal existence lemma: If `Diamond psi in fam.mcs t` and fam is in a box-coherent M, then `{psi} union BoxContent(M)` is consistent
- [ ] Prove the key contradiction argument: If `{psi} union BoxContent` is inconsistent, derive `Box(neg psi)` must be in some M family
- [ ] Use box_coherence to show `neg psi` would be in all families including fam
- [ ] Show this contradicts `Diamond psi in fam.mcs t`
- [ ] Connect the K-distribution argument to the multi-family setting
- [ ] Apply to resolve line 714 sorry

**Timing**: 12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Add modal existence lemma and resolve sorry
- Possibly `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - Add helper lemmas if needed

**Verification**:
- `lake build` passes with line 714 sorry removed
- The `h_witness_set_consistent` proof is complete

---

### Phase 3: Coherent Witness Construction [NOT STARTED]

**Goal**: Resolve the sorry at line 785 by proving that Lindenbaum extensions can be controlled or that box-coherence is preserved.

**Tasks**:
- [ ] Analyze what Box formulas Lindenbaum can add beyond the seed
- [ ] Strategy A: Prove that any Box chi added by Lindenbaum has chi already in all M families
  - Use: If Box chi is added, it's because neg(Box chi) leads to inconsistency
  - neg(Box chi) = Diamond(neg chi), which would require a witness for neg chi
  - If neg chi had a witness in M, the seed would already contain chi (from BoxContent)
- [ ] Strategy B (fallback): Construct a "minimal" MCS that avoids adding unnecessary Box formulas
  - Use classical choice to select an MCS with specific properties
  - Define the property: contains seed, excludes Box formulas not forced by the seed
- [ ] Prove box_coherence is preserved when adding the witness family to M
- [ ] Apply to resolve line 785 sorry

**Timing**: 15 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Add coherent witness construction and resolve sorry
- Possibly `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - Add controlled Lindenbaum lemmas

**Verification**:
- `lake build` passes with line 785 sorry removed
- The `h_extended_coherence` proof is complete
- The full `exists_fullySaturated_extension` theorem compiles without sorry

---

### Phase 4: Integration and Verification [NOT STARTED]

**Goal**: Verify the complete construction works and prepare for axiom removal.

**Tasks**:
- [ ] Run `lake build` to verify all sorries are resolved
- [ ] Verify `exists_fullySaturated_extension` theorem is fully proven
- [ ] Verify `FamilyCollection.saturate` works correctly
- [ ] Verify `constructSaturatedBMCS` produces a valid BMCS
- [ ] Test `construct_bmcs_saturated` preserves context
- [ ] Document the proof structure with clear comments
- [ ] Create follow-up task for removing `singleFamily_modal_backward_axiom` from Construction.lean
- [ ] Update sorry count in repository_health

**Timing**: 6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Add documentation
- `specs/state.json` - Update repository_health metrics

**Verification**:
- `lake build` passes with 0 sorries in SaturatedConstruction.lean
- `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` returns 0
- All dependent theorems compile correctly

---

### Phase 5: Axiom Elimination Preparation [NOT STARTED]

**Goal**: Prepare the pathway for eliminating `singleFamily_modal_backward_axiom`.

**Tasks**:
- [ ] Analyze how `construct_bmcs` is used in `bmcs_representation` (Completeness.lean)
- [ ] Design the replacement: either modify `construct_bmcs` or create alternative path
- [ ] Verify `construct_bmcs_saturated` provides equivalent functionality
- [ ] Document the dependency chain from new construction to completeness theorem
- [ ] Create detailed follow-up task with implementation plan for axiom removal

**Timing**: 4 hours

**Files to modify**:
- `specs/TODO.md` - Add follow-up task
- `specs/state.json` - Add follow-up task entry

**Verification**:
- Clear pathway documented from saturated construction to completeness
- Follow-up task created with sufficient detail for implementation

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No new sorries introduced
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` returns 0 after Phase 3
- [ ] `exists_fullySaturated_extension` theorem is transitively sorry-free
- [ ] `constructSaturatedBMCS` produces valid BMCS instances

## Artifacts & Outputs

- `specs/856_implement_multifamily_saturated_bmcs/plans/implementation-001.md` (this file)
- `specs/856_implement_multifamily_saturated_bmcs/summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` with resolved sorries
- Possibly modified `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` or `MaximalConsistent.lean`
- Follow-up task for axiom elimination

## Rollback/Contingency

If any phase proves intractable:
1. **Phase 1 (temporal uniformity)**: Could restrict entire construction to constant families only
2. **Phase 2 (modal existence)**: Could add as a justified axiom with clear mathematical proof sketch
3. **Phase 3 (coherent witness)**: Could switch to Option B (WeakCoherentBundle) as alternative
4. **Full rollback**: Preserve current axiom-based approach, document why saturation was infeasible

All changes should be committed incrementally so partial progress is preserved.
