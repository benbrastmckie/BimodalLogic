# Implementation Plan: Task #58 - Greedy Extension Approach (v17)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Dependencies**: Phase 1 from v16 (single_brs_element_with_g_content_consistent is PROVEN)
- **Research Inputs**: reports/76_team-research.md (Greedy Extension + Deferral Disjunction approaches)
- **Previous Plan**: plans/16_g-wrapping-approach.md (Phase 1 COMPLETED, Phase 2 BLOCKED)
- **Artifacts**: plans/17_greedy-extension.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v16 Phase 1 proved `single_brs_element_with_g_content_consistent` (lines 1444-1590 in SuccChainFMCS.lean), but Phase 2 was BLOCKED because naive multi-BRS approaches fail: extending from `{psi_1} ∪ g_content(u)` to `{psi_1, psi_2} ∪ g_content(u)` cannot use G-wrapping since `G(psi_1) ∉ u` in general.

Team research (report 76) identified the fundamental gap: `F(psi) ∈ u` does NOT imply `G(psi) ∈ u`. Two viable paths emerged:

1. **Greedy Extension (Primary)**: Build MCS incrementally, prove BRS elements are always compatible with u-extensions via compatibility lemma
2. **Deferral Disjunction (Fallback)**: Replace bare `psi` in seed with `psi ∨ F(psi)` which IS in u

This plan pursues Greedy Extension first, with Deferral Disjunction as contingency if Phase 1 is blocked.

### Research Integration (Report 76)

**Key Finding**: All naive multi-BRS approaches are fundamentally blocked by `F(psi) ∈ u ≠ G(psi) ∈ u`.

**Greedy Extension Insight**: BRS elements are DEFINED to be compatible via F-witnesses. If adding `psi` to a consistent extension of u causes inconsistency, we can derive `psi.neg` from the extension. Since the extension contains `g_content(u)`, G-wrapping gives `G(psi.neg) ∈ u`, contradicting `F(psi) ∈ u`.

## Goals & Non-Goals

**Goals**:
- Prove `brs_element_compatible_with_extension` compatibility lemma
- Use greedy fold to build consistent seed
- Complete `constrained_successor_seed_restricted_consistent` (lines 1646-1844+)
- Wire through to eliminate `dense_completeness_fc` and `completeness_over_Int` sorries

**Non-Goals**:
- `discrete_completeness_fc` (separate blocker: `discrete_Icc_finite_axiom`)
- Restructuring BRS definition
- Alternative proof architectures if Greedy Extension succeeds

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Compatibility lemma blocked | H | M | Fallback to Deferral Disjunction (Phase 1B) |
| G-content relationship doesn't propagate through extensions | H | L | Research shows it should; acc extends u means acc is "G-closed" |
| Greedy fold construction non-trivial in Lean | M | M | Use Finset.fold with careful termination |
| Deferral disjunction breaks successor construction | M | M | If blocked, pursue Path C (restructure Lindenbaum) |

---

## Implementation Phases

### Phase 1: Prove BRS Element Compatibility Lemma [NOT STARTED]

**Goal**: Prove that any BRS element is compatible with any consistent extension of u

This is the core insight from the research: BRS elements don't introduce inconsistencies because their negations can be G-wrapped to contradict their F-membership in u.

**Tasks**:
- [ ] Create compatibility lemma:
  ```lean
  lemma brs_element_compatible_with_extension (phi : Formula) (u : Set Formula)
      (h_mcs : DeferralRestrictedMCS phi u)
      (acc : Set Formula) (h_acc_ext : g_content u ⊆ acc) (h_acc_cons : SetConsistent acc)
      (psi : Formula) (h_psi_brs : psi ∈ boundary_resolution_set phi u) :
      SetConsistent (acc ∪ {psi})
  ```
- [ ] Proof structure:
  1. Suppose `L ⊆ acc ∪ {psi}` with `L ⊢ ⊥`
  2. If `psi ∉ L`: `L ⊆ acc`, contradicts `acc`'s consistency
  3. If `psi ∈ L`: Deduction theorem gives `L \ {psi} ⊢ psi.neg`
  4. Key: `L \ {psi} ⊆ acc` and `g_content(u) ⊆ acc`
  5. Need: For `chi ∈ L \ {psi}`, can we get `G(chi) ∈ u`?
  6. If `chi ∈ g_content(u)`, then `G(chi) ∈ u` by definition
  7. Otherwise chi is from "other" parts of acc - this is where it gets subtle
- [ ] Analyze whether proof requires `acc ⊆ u` or just `g_content(u) ⊆ acc`
- [ ] If blocked, document specific obstruction and proceed to Phase 1B

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (add after line 1590)

**Verification**:
- `brs_element_compatible_with_extension` compiles without sorry
- OR clear documentation of why it's blocked

---

### Phase 1B (Contingency): Deferral Disjunction Approach [NOT STARTED]

**Goal**: If Phase 1 is blocked, reformulate seed using `psi ∨ F(psi)` instead of bare `psi`

**Rationale**: For each BRS element `psi`, we have `psi ∨ F(psi) ∈ u` (via deferralDisjunctions). Using these disjunctions instead of bare BRS elements means the entire seed is a subset of u.

**Tasks**:
- [ ] Define alternative seed using disjunctions:
  ```lean
  def constrained_successor_seed_disjunctive (phi : Formula) (u : Set Formula) : Set Formula :=
    g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u ∪
    { psi.or (Formula.some_future psi) | psi ∈ boundary_resolution_set phi u }
  ```
- [ ] Prove `constrained_successor_seed_disjunctive ⊆ u`
- [ ] Analyze: Does successor construction still work?
  - Successor needs to satisfy `psi` at next state
  - Does having `psi ∨ F(psi)` suffice?
  - May need case analysis in truth lemma
- [ ] If disjunctive approach works, adapt main proof
- [ ] If blocked, document and recommend Path C (Lindenbaum restructuring)

**Timing**: 2 hours (only if Phase 1 blocked)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- Clear path to consistency proof OR documented blocker

---

### Phase 2: Build Seed via Greedy Extension [NOT STARTED]

**Goal**: Use greedy fold over BRS elements to build consistent seed

**Prerequisites**: Phase 1 (or 1B) completed successfully

**Tasks**:
- [ ] Define greedy extension construction:
  ```lean
  def greedy_extension (phi : Formula) (u : Set Formula)
      (base : Set Formula) (h_base_cons : SetConsistent base)
      (h_gc_sub : g_content u ⊆ base) : Set Formula :=
    (boundary_resolution_set phi u).toFinset.fold
      (fun acc psi => acc ∪ {psi})  -- Always add since always compatible
      base
  ```
- [ ] Prove greedy extension is consistent via induction:
  ```lean
  lemma greedy_extension_consistent (phi : Formula) (u : Set Formula)
      (h_mcs : DeferralRestrictedMCS phi u)
      (base : Set Formula) (h_base_cons : SetConsistent base)
      (h_gc_sub : g_content u ⊆ base) :
      SetConsistent (greedy_extension phi u base h_base_cons h_gc_sub)
  ```
- [ ] Show greedy extension equals `base ∪ boundary_resolution_set`:
  ```lean
  lemma greedy_extension_eq_union :
      greedy_extension phi u base h h' = base ∪ boundary_resolution_set phi u
  ```
- [ ] Apply to `g_content u` as base to get `g_content_union_brs_consistent`:
  ```lean
  lemma g_content_union_brs_consistent (phi : Formula) (u : Set Formula)
      (h_mcs : DeferralRestrictedMCS phi u) :
      SetConsistent (g_content u ∪ boundary_resolution_set phi u)
  ```
- [ ] Run `lake build` to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `g_content_union_brs_consistent` compiles without sorry
- `#print axioms` shows no sorryAx

---

### Phase 3: Complete Main Consistency Theorem [NOT STARTED]

**Goal**: Assemble results to complete `constrained_successor_seed_restricted_consistent`

**Prerequisites**: Phase 2 completed

**Tasks**:
- [ ] Show remaining seed components preserve consistency:
  ```lean
  -- deferralDisjunctions and p_step_blocking_restricted are subsets of u
  -- Adding subsets of u to a consistent set that extends u preserves consistency
  lemma adding_u_subset_preserves_g_content_brs_consistency :
      SetConsistent (g_content u ∪ boundary_resolution_set phi u ∪
                     deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u)
  ```
- [ ] Restructure existing proof at lines 1646-1844+
- [ ] Remove current sorry-filled approach
- [ ] Insert new proof structure using greedy extension results
- [ ] Verify `augmented_seed_consistent` (line 1606) also becomes sorry-free
- [ ] Run `lake build` to confirm compilation

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `constrained_successor_seed_restricted_consistent` is sorry-free
- `augmented_seed_consistent` is sorry-free
- `#print axioms` shows no sorryAx for both

---

### Phase 4: Wire Through to Completeness Theorems [NOT STARTED]

**Goal**: Eliminate `dense_completeness_fc` and `completeness_over_Int` sorries

**Prerequisites**: Phase 3 completed

With seed consistency proven, the dependency chain completes:
1. Seed consistent -> Lindenbaum extension succeeds
2. Successor construction works -> canonical model exists
3. Truth lemma applies -> completeness follows

**Tasks**:
- [ ] Trace dependency chain from `constrained_successor_seed_restricted_consistent`:
  - SuccChainFMCS.lean -> constrained_successor_restricted construction
  - -> SuccChain model construction
  - -> truth lemma
  - -> completeness
- [ ] Identify and fix any intermediate sorries in the chain
- [ ] Update `dense_completeness_fc` (Completeness.lean line 115-120)
- [ ] Update `completeness_over_Int` (Completeness.lean line 234-237)
- [ ] Handle `bundle_validity_implies_provability` (line 186-214) - model-theoretic glue
- [ ] Run full `lake build`

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`
- Potentially intermediate files in dependency chain

**Verification**:
- `dense_completeness_fc` is sorry-free OR reduced to model-theoretic glue
- `completeness_over_Int` is sorry-free OR reduced to model-theoretic glue
- `lake build` succeeds with no errors
- `#print axioms` verification

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] Each new theorem verified with `#print axioms` (no sorryAx)
- [ ] `brs_element_compatible_with_extension` proof follows research sketch
- [ ] `g_content_union_brs_consistent` uses sound induction
- [ ] `constrained_successor_seed_restricted_consistent` is sorry-free
- [ ] Completeness theorems are sorry-free (or reduced to documented model-theoretic glue)
- [ ] `discrete_completeness_fc` remains sorry (separate blocker, documented)

## Artifacts & Outputs

- plans/17_greedy-extension.md (this file)
- Modified: SuccChainFMCS.lean (compatibility lemma, greedy extension, main theorem)
- Modified: Completeness.lean (sorries eliminated via dependency chain)

## Rollback/Contingency

### If Phase 1 (Compatibility Lemma) is Blocked

**Diagnosis**: The G-content relationship may not propagate through arbitrary extensions of u. The proof requires showing that `L \ {psi} ⊆ acc` implies G-wrapping works, but if acc contains elements not in g_content(u), their G-images may not be in u.

**Contingency**: Proceed to Phase 1B (Deferral Disjunction approach).

### If Phase 1B (Deferral Disjunction) is Also Blocked

**Diagnosis**: Successor construction may require bare BRS elements, not disjunctions.

**Path C**: Restructure Lindenbaum construction:
- Start with u (consistent)
- Greedily add seed elements while maintaining consistency AND required properties
- Avoid proving seed consistency a priori
- This is invasive but architecturally sound

### If Phase 2 (Greedy Extension) Has Lean Issues

**Diagnosis**: Finset.fold may have termination/complexity issues.

**Alternative**: Use explicit induction on BRS cardinality instead of fold.

### General Fallback

If fundamentally blocked:
- Document specific mathematical obstruction
- Create new task for alternative approach
- Preserve all partial progress

## Key Lemmas from Existing Infrastructure

**Proven and Available**:
- `single_brs_element_with_g_content_consistent` (SuccChainFMCS.lean:1444-1590) - Phase 1 from v16
- `generalized_temporal_k` (Theorems/): `L ⊢ phi -> G(L) ⊢ G(phi)`
- `neg_not_in_seed_when_in_brs` (SuccChainFMCS.lean:1409-1426): BRS elements don't have negations in seed
- `brs_mutual_exclusion` (SuccChainFMCS.lean): No chi, chi.neg both in BRS
- `g_content_subset_deferral_restricted_mcs`: g_content(u) ⊆ u
- `deferralDisjunctions_subset_deferral_restricted_mcs`: deferralDisjunctions(u) ⊆ u
- `p_step_blocking_restricted_subset`: p_step_blocking_restricted(phi, u) ⊆ u
- `set_consistent_not_both`: MCS can't contain phi and phi.neg
- `drm_closed_under_derivation`: DRM is closed under derivation
- `deferral_restricted_mcs_negation_complete`: DRM has psi or psi.neg for psi in closure

**From Research (to be proven)**:
- `brs_element_compatible_with_extension` - core Phase 1 lemma
- `g_content_union_brs_consistent` - Phase 2 result
- `constrained_successor_seed_restricted_consistent` - final target

## Approaches Definitively Ruled Out

| Approach | Why Blocked | Reference |
|----------|-------------|-----------|
| Naive multi-BRS induction | G-wrapping fails: G(psi_i) ∉ u | Report 76 |
| Subset consistency (BRS ⊆ u) | BRS ⊄ u by definition | Report 76 |
| Semantic model building | Circular - needs consistency to build model | Report 76 |
| Compactness arguments | Just restates the problem | Report 76 |
| proof_by_cases_bot | Second branch FALSE | Report 76 |
| Simultaneous G-wrapping | G(psi_i) ∈ u not derivable from F(psi_i) ∈ u | Report 76 |
| "No contradictory pairs" alone | Insufficient in Hilbert systems | Report 63 |

## Critical Path

```
Phase 1 (Compatibility) ─┬─> Phase 2 (Greedy) -> Phase 3 (Main) -> Phase 4 (Wire)
                         │
Phase 1B (Disjunction) ──┘ (fallback if Phase 1 blocked)
```

If Phase 1 succeeds, skip Phase 1B. If Phase 1 blocked, Phase 1B becomes primary path.
