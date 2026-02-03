# Implementation Plan: Task #851 - Define CoherentBundle Structure

- **Task**: 851 - define_coherentbundle_structure
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: Task 844 (CoherentWitness implementation - COMPLETED)
- **Research Inputs**: specs/851_define_coherentbundle_structure/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan defines the CoherentBundle structure that collects coherent witnesses with mutual coherence enforcement. The key insight from research is the **constant-family restriction**: since all witnesses constructed via `constructCoherentWitness` are constant families, we can enforce mutual coherence via a shared `UnionBoxContent` computation spanning all families. This sidesteps the Lindenbaum control problem that causes sorries in SaturatedConstruction.lean.

### Research Integration

- From research-001.md: Constant-family witnesses have time-independent BoxContent, simplifying mutual coherence
- Key theorem `diamond_boxcontent_consistent_constant` is complete (no sorries)
- Zorn's lemma infrastructure in SaturatedConstruction.lean is correctly structured (lines 469-487)
- MutuallyCoherent predicate should require: for all fam in families, for all chi in UnionBoxContent, chi in fam.mcs t for all t

## Goals & Non-Goals

**Goals**:
- Define `UnionBoxContent` for multi-family BoxContent aggregation
- Define `MutuallyCoherent` predicate for inter-family coherence
- Define `CoherentBundle` structure with constant-family constraint
- Define `CoherentBundle.isSaturated` predicate
- Prove basic properties of CoherentBundle (e.g., BoxContent subset, membership)
- Define `CoherentBundle.toBMCS` conversion function (with saturation hypothesis)

**Non-Goals**:
- Implementing full Zorn's lemma saturation (follow-up task)
- Eliminating `singleFamily_modal_backward_axiom` (requires saturation)
- Proving saturation can always be achieved (requires Zorn's lemma work)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| UnionBoxContent consistency proof may require new lemmas | Medium | Medium | Generalize existing `diamond_boxcontent_consistent_constant` |
| MutuallyCoherent may be too strong for practical construction | Low | Low | Research confirms constant families avoid time-mismatch issues |
| toBMCS conversion proof complexity | Medium | Medium | Focus on structure; saturation proof is a separate step |
| Integration with existing SaturatedConstruction.lean | Low | Low | CoherentBundle is a parallel approach, not a replacement |

## Sorry Characterization

### Pre-existing Sorries
- 3 sorries in `SaturatedConstruction.lean` at lines 714, 733, 785 (BoxContent preservation issues)
- These are in a different code path (general saturation approach)

### Expected Resolution
- This implementation creates NEW structures for the constant-family approach
- Pre-existing sorries remain (they are in the general approach, not constant-family approach)

### New Sorries
- None expected in structure definitions
- `toBMCS` may require sorry for `modal_backward` if full proof is complex (tolerated during development, remediation in saturation follow-up task)

### Remaining Debt
- Post-implementation: sorries in SaturatedConstruction.lean remain unchanged
- Remediation: Future task to complete Zorn's lemma saturation using CoherentBundle structures

## Implementation Phases

### Phase 1: UnionBoxContent and MutuallyCoherent Definitions [COMPLETED]

**Goal**: Define the core predicates for multi-family coherence

**Tasks**:
- [ ] Define `UnionBoxContent : Set (IndexedMCSFamily D) -> Set Formula`
- [ ] Prove `BoxContent_subset_UnionBoxContent`: Single-family BoxContent is subset of union
- [ ] Prove `UnionBoxContent_monotone`: Adding families only increases UnionBoxContent
- [ ] Define `MutuallyCoherent : Set (IndexedMCSFamily D) -> Prop`
- [ ] Prove `MutuallyCoherent_singleton`: Single constant family is trivially mutually coherent

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add new definitions after existing CoherentWitness section

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CoherentConstruction` succeeds
- All 5 definitions/lemmas compile without sorry

---

### Phase 2: CoherentBundle Structure Definition [COMPLETED]

**Goal**: Define the main CoherentBundle structure with all required fields

**Tasks**:
- [ ] Define `CoherentBundle` structure with:
  - `families : Set (IndexedMCSFamily D)`
  - `all_constant : forall fam in families, IsConstantFamily fam`
  - `nonempty : families.Nonempty`
  - `eval_family : IndexedMCSFamily D`
  - `eval_family_mem : eval_family in families`
  - `mutually_coherent : MutuallyCoherent families`
- [ ] Add docstring explaining purpose and relationship to BMCS
- [ ] Define `CoherentBundle.isSaturated` predicate
- [ ] Prove `CoherentBundle.eval_family_constant`: eval_family is constant

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add CoherentBundle structure

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CoherentConstruction` succeeds
- CoherentBundle structure compiles with all fields

---

### Phase 3: Basic CoherentBundle Properties [COMPLETED]

**Goal**: Prove fundamental lemmas about CoherentBundle structure

**Tasks**:
- [ ] Prove `CoherentBundle.chi_in_all_families`: If Box chi in any family, chi in all families
- [ ] Prove `CoherentBundle.box_content_uniform`: BoxContent is same for all constant families in bundle
- [ ] Prove `CoherentBundle.families_box_coherent`: Box formulas propagate correctly
- [ ] Prove `CoherentBundle.member_contains_union_boxcontent`: Each family contains UnionBoxContent

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add lemmas in CoherentBundle section

**Verification**:
- All 4 lemmas compile without sorry
- `lake build` succeeds

---

### Phase 4: CoherentBundle to BMCS Conversion [IN PROGRESS]

**Goal**: Define conversion from saturated CoherentBundle to BMCS

**Tasks**:
- [ ] Define `CoherentBundle.toBMCS` function with saturation hypothesis
- [ ] Prove `modal_forward` field: From mutual coherence + T-axiom
- [ ] Prove `modal_backward` field: From saturation hypothesis via contraposition
- [ ] Add theorem `CoherentBundle.toBMCS_preserves_eval_family`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add toBMCS definition and proofs

**Verification**:
- `toBMCS` compiles (with or without sorry depending on complexity)
- If sorry needed, document as technical debt with clear remediation path
- `lake build Bimodal.Metalogic.Bundle.CoherentConstruction` succeeds

---

### Phase 5: Integration and Documentation [NOT STARTED]

**Goal**: Integrate CoherentBundle with existing codebase and document

**Tasks**:
- [ ] Update module docstring to document CoherentBundle approach
- [ ] Add section header for CoherentBundle (Phase 4-6 replacement)
- [ ] Document relationship to SaturatedConstruction.lean approach
- [ ] Run full `lake build` to verify no regressions
- [ ] Update Summary of Sorry Status section in module

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Update docstrings

**Verification**:
- `lake build` succeeds with no new errors
- Module docstring accurately describes CoherentBundle purpose
- Sorry Status section reflects actual sorry count

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.CoherentConstruction` compiles without errors
- [ ] All new definitions have docstrings
- [ ] No new sorries introduced (except possibly in modal_backward of toBMCS)
- [ ] Existing theorems (`diamond_boxcontent_consistent_constant`, `constructCoherentWitness`) still compile
- [ ] Full `lake build` succeeds with no regressions

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Extended with CoherentBundle
- `specs/851_define_coherentbundle_structure/summaries/implementation-summary-YYYYMMDD.md` - Upon completion

## Rollback/Contingency

- If CoherentBundle structure doesn't work: Keep existing `CoherentWitness` as-is, document blockers
- If `toBMCS` requires sorry: Accept sorry as technical debt, create follow-up task for saturation proof
- If integration causes build failures: Isolate new code in separate namespace/section
