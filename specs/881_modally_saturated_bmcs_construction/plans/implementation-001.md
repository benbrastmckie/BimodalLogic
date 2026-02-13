# Implementation Plan: Task #881

- **Task**: 881 - Modally Saturated BMCS Construction
- **Status**: [PARTIAL] - Phases 1-3 complete, Phase 4 in progress
- **Effort**: 4-6 hours
- **Dependencies**: None (builds on existing SaturatedConstruction.lean infrastructure)
- **Research Inputs**: research-003.md, teammate-a-v2-findings.md, teammate-b-v2-findings.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Replace the `fully_saturated_bmcs_exists` axiom in TemporalCoherentConstruction.lean with a constructive proof. Research consensus recommends fixing the existing 3 sorries in SaturatedConstruction.lean using S5 BoxContent invariance rather than building a new unified construction. This requires deriving axiom 5 (negative introspection) from `modal_5_collapse` and proving BoxContent invariance for constant families, then addressing temporal coherence integration.

### Research Integration

Reports integrated: research-003.md (2026-02-13), teammate-a-v2-findings.md, teammate-b-v2-findings.md

Key findings:
- Both teammates independently concluded the unified Zorn construction is over-engineered
- Fix existing 3 sorries with ~100 lines of new code using S5 axioms
- Axiom 5 derivation: `neg(Box phi) -> Box(neg(Box phi))` from `modal_5_collapse` contrapositive
- BoxContent invariance resolves all 3 sorries at lines 985, 1005, 1069
- Temporal coherence integration requires investigation of truth lemma usage

## Goals & Non-Goals

**Goals**:
- Eliminate the `fully_saturated_bmcs_exists` axiom in TemporalCoherentConstruction.lean
- Fix the 3 sorries in `FamilyCollection.exists_fullySaturated_extension` (SaturatedConstruction.lean)
- Derive negative introspection (axiom 5) from `modal_5_collapse`
- Prove BoxContent invariance for constant families within a box-coherent set
- Wire the constructive proof to replace the axiom usage

**Non-Goals**:
- Building a unified single-pass Zorn construction (research-002.md approach superseded)
- Creating new data structures like `UnifiedCoherentPartialFamily`
- Eliminating Zorn's lemma (unavoidable for full modal saturation)
- Fully resolving temporal coherence for all families (addressed as separate concern if needed)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Temporal coherence requires all-family F/P satisfaction | High | Phase 3 investigates truth lemma usage; may require temporal coherence scope change |
| BoxContent invariance proof more complex than expected | Medium | Leverage existing `constant_families_boxcontent_time_invariant` lemma |
| Axiom 5 derivation requires additional infrastructure | Low | Standard contrapositive derivation, `contraposition` utility exists |
| Constant-family restriction breaks existing Zorn proofs | Low | Property preserved by unions; existing proofs unaffected |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries in `FamilyCollection.exists_fullySaturated_extension` (SaturatedConstruction.lean lines 985, 1005, 1069)
- 1 sorry in `temporal_coherent_family_exists` generic version (line 636)

### Expected Resolution
- Phase 2 resolves all 3 modal saturation sorries via S5 BoxContent invariance lemmas
- Temporal sorry addressed via wiring if truth lemma only needs eval_family coherence

### New Sorries
- None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt
After this implementation:
- 0 modal saturation sorries expected in SaturatedConstruction.lean
- Temporal coherence sorry status TBD based on Phase 3 findings
- Publication path cleared for modal completeness components

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in TemporalCoherentConstruction.lean: `fully_saturated_bmcs_exists` (line 773)

### Expected Resolution
- Phase 4 eliminates axiom by wiring constructive proof from SaturatedConstruction.lean
- Structural proof approach: constant-family Zorn construction with S5 BoxContent invariance

### New Axioms
- None. NEVER introduce new axioms. All gaps resolved through constructive proofs.

### Remaining Debt
After this implementation:
- 0 axioms expected for modal saturation
- `temporal_coherent_family_exists` generic sorry remains (Int-specific version proven)
- Completeness theorem axiom-free for modal components

## Implementation Phases

### Phase 1: Derive Axiom 5 (Negative Introspection) [COMPLETED]

- **Dependencies:** None
- **Goal:** Derive `neg(Box phi) -> Box(neg(Box phi))` from `modal_5_collapse` contrapositive

**Tasks**:
- [ ] Add `neg_box_to_box_neg_box` theorem in ModalSaturation.lean or CoherentConstruction.lean
- [ ] Proof: `modal_5_collapse` gives `Diamond(Box phi) -> Box phi`; contrapositive gives `neg(Box phi) -> neg(Diamond(Box phi)) = Box(neg(Box phi))`
- [ ] Use existing `contraposition` utility from Propositional.lean
- [ ] Verify with `lake build`

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Add axiom 5 derivation

**Verification**:
- Theorem compiles without sorry
- `lake build` succeeds

---

### Phase 2: Fix the 3 Sorries in SaturatedConstruction.lean [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Eliminate all 3 sorries in `FamilyCollection.exists_fullySaturated_extension` using S5 lemmas

**Tasks**:
- [x] Add `isConstant` constraint to Zorn set S definition
- [x] Prove `allConstant_sUnion`: union of constant-family sets preserves allConstant property
- [x] Add `box_coherent_constant_boxcontent_complete`: BoxContent = {chi | Box chi in fam.mcs t}
- [x] Add `box_coherent_box_uniform`: Box chi in any family implies Box chi in all families (via axiom 4)
- [x] Fix sorry 1 (line 985): Applied `diamond_box_coherent_consistent` with h_boxcontent_boxes_in_fam
- [x] Fix sorry 2 (line 1005): Removed - now handled by constancy constraint on S
- [x] Fix sorry 3 (line 1044): Axiom 5 contradiction argument - if Box chi in W_set but chi not in BoxContent, then neg(Box chi) in BoxContent by axiom 5, contradicting W_set being consistent
- [x] Verify with `lake build`

**Completed**: All 3 sorries fixed. Build succeeds with only warnings about unused section variables.

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Fix sorries and add supporting lemmas

**Verification**:
- All 3 sorries eliminated
- `lake build` succeeds
- `FamilyCollection.exists_fullySaturated_extension` proof is sorry-free

---

### Phase 3: Investigate Truth Lemma Temporal Usage [COMPLETED]

- **Dependencies:** None (can run parallel to Phase 2)
- **Goal:** Determine if `bmcs_truth_lemma` uses temporal coherence for non-eval families

**Tasks**:
- [x] Examine `TruthLemma.lean` for temporal coherence usage patterns
- [x] Identify which families require forward_F/backward_P properties
- [x] Check if `B.temporally_coherent` is only used for eval_family
- [x] Document findings for temporal integration decision

**Findings**:
1. `bmcs_truth_lemma` requires `B.temporally_coherent` which applies to ALL families
2. However, the temporal cases (G, H) only use forward_F/backward_P for the SPECIFIC family being evaluated
3. Completeness.lean only uses truth lemma for `B.eval_family`
4. For CONSTANT families: if MCS is TemporalForwardSaturated and TemporalBackwardSaturated, then forward_F/backward_P are automatically satisfied
5. Key insight: Using `henkinLimit` + `temporalSetLindenbaum` for witness construction would ensure all witnesses are temporally coherent

**Decision**: Upgrade witness families using temporal Lindenbaum (henkinLimit + temporalSetLindenbaum) instead of regular set_lindenbaum

---

### Phase 4: Wire Constructive Proof to Replace Axiom [IN PROGRESS]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Replace `fully_saturated_bmcs_exists` axiom with constructive proof

**Tasks**:
- [ ] Based on Phase 3 findings, determine integration approach:
  - If temporal coherence only needed for eval_family: modify `temporally_coherent` requirement
  - If needed for all families: start from temporally coherent family, add constant witnesses
- [ ] Create `fully_saturated_bmcs_exists_constructive` theorem proving the axiom statement
- [ ] Wire through `FamilyCollection.exists_fullySaturated_extension` result
- [ ] Replace axiom usage in `construct_saturated_bmcs` with constructive proof
- [ ] Remove the axiom declaration (or mark deprecated)
- [ ] Update documentation comments referencing the axiom
- [ ] Verify with `lake build`

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Replace axiom
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Update references

**Verification**:
- Axiom removed or deprecated
- `construct_saturated_bmcs` uses constructive proof
- `lake build` succeeds
- Completeness chain remains valid

---

### Phase 5: Final Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Verify axiom-free completeness and clean up code

**Tasks**:
- [ ] Run full `lake build` to verify no regressions
- [ ] Count remaining sorries and axioms in the saturation modules
- [ ] Update module docstrings with axiom elimination status
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- Various module docstrings
- `specs/881_modally_saturated_bmcs_construction/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- `lake build` succeeds
- Axiom count reduced by 1 (`fully_saturated_bmcs_exists` eliminated)
- Completeness theorem no longer inherits axiom dependency

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `grep -r "sorry" SaturatedConstruction.lean` returns 0 matches after Phase 2
- [ ] `grep -r "axiom fully_saturated_bmcs_exists"` returns 0 matches after Phase 4 (or shows deprecated)
- [ ] TruthLemma.lean continues to compile without changes (backward compatible)
- [ ] Completeness.lean proofs remain valid

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified Lean files:
  - `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
  - `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
  - `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`

## Rollback/Contingency

If implementation fails:
1. Git revert to pre-implementation commit
2. Restore axiom `fully_saturated_bmcs_exists` if removed
3. Document blocking issues in error report
4. Create follow-up task with revised approach based on failure analysis

If temporal integration proves infeasible:
1. Keep modal saturation fixes (Phase 2)
2. Document temporal coherence as separate future task
3. Axiom partially eliminated (modal components constructive)
