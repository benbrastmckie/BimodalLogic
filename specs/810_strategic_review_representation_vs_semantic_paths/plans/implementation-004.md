# Implementation Plan: Task #810 (v004 - Contrapositive Approach)

- **Task**: 810 - Strategic review: Representation/ approach vs semantic completeness paths
- **Status**: [IMPLEMENTING]
- **Version**: 004 (Revised based on research-005.md - blockage analysis)
- **Effort**: 2-3 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/810_strategic_review_representation_vs_semantic_paths/reports/research-005.md (blockage analysis)
  - specs/810_strategic_review_representation_vs_semantic_paths/reports/research-004.md (FMP feasibility)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**CRITICAL REVISION**: Research-005 discovered that the bridge lemma approach in v003 is **architecturally flawed** and cannot be completed for modal/temporal operators. The 6 sorries in `mcs_world_truth_correspondence` are **not recoverable**.

### Why v003 Failed

| Issue | Root Cause |
|-------|------------|
| Modal box sorries (3) | Model has non-MCS states reachable (task_rel = True) |
| Temporal sorries (3) | Constant history loses temporal structure |
| Architecture | Direct model construction requires canonical model infrastructure |

### New Strategy: Contrapositive via Weak Completeness

Instead of building models directly, use the **already-proven** `semantic_weak_completeness` via contrapositive:

```
semantic_weak_completeness (PROVEN, sorry-free)
        │
        ▼
consistent_implies_satisfiable (via contrapositive, NOT direct construction)
        │
        ▼
infinitary_strong_completeness (via finite witness + soundness)
        │
        ▼
compactness (corollary)
```

**Key insight**: We don't need truth correspondence for all operators - we only need to show a formula **false** at one world, which the existing `worldStateFromClosureMCS_not_models` lemma already provides.

## Goals & Non-Goals

**Goals**:
- Fix `FiniteStrongCompleteness.lean` syntax errors (broken references)
- Prove `consistent_implies_satisfiable` via contrapositive (not direct construction)
- Achieve `infinitary_strong_completeness` using the new approach
- Achieve `compactness` as corollary
- Archive ConsistentSatisfiable.lean (keep propositional fragment, mark modal/temporal as blocked)
- Ensure all target results are sorry-free

**Non-Goals**:
- Completing the 6 sorries in ConsistentSatisfiable.lean (architecturally infeasible)
- Building direct models for set satisfiability
- Decidability (separate FMP tableau work, out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Contrapositive formulation tricky | Medium | Medium | Follow research-005 Section 3.2 precisely |
| Need lemmas not yet in codebase | Medium | Low | Check Boneyard for `no_finite_witness_implies_union_consistent` |
| Build issues from fixes | Low | Low | Run `lake build` after each change |

## Implementation Phases

### Phase 1: Fix FiniteStrongCompleteness.lean [IN PROGRESS]

**Goal**: Fix syntax errors in `FiniteStrongCompleteness.lean` that reference non-existent functions.

**Background**: The file references `semantic_completeness` which doesn't exist. It should use `semantic_weak_completeness` from `FMP/SemanticCanonicalModel.lean`.

**Tasks**:
- [ ] Identify all broken references in the file
- [ ] Replace `semantic_completeness` with `semantic_weak_completeness`
- [ ] Ensure proper imports from FMP modules
- [ ] Verify `weak_completeness` and `finite_strong_completeness` compile
- [ ] Run `lake build` to verify

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Completeness.FiniteStrongCompleteness` succeeds
- No sorries in fixed code

---

### Phase 2: Prove Consistent Implies Satisfiable (Contrapositive) [NOT STARTED]

**Goal**: Prove that consistency implies satisfiability using contrapositive of weak completeness, NOT direct model construction.

**Proof Strategy** (from research-005, Section 3.2):

```lean
lemma consistent_implies_satisfiable (phi : Formula)
    (h_cons : Consistent phi) : Satisfiable phi := by
  -- Contrapositive: if not satisfiable, then not consistent
  by_contra h_not_sat
  -- Not satisfiable means phi.neg is valid (true everywhere)
  have h_neg_valid : Valid phi.neg := not_satisfiable_implies_neg_valid h_not_sat
  -- By semantic_weak_completeness: phi.neg is provable
  have h_neg_prov : ⊢ phi.neg := semantic_weak_completeness phi.neg h_neg_valid
  -- But phi consistent means phi.neg not provable (contradiction)
  exact h_cons (neg_provable_implies_inconsistent h_neg_prov)
```

**Key Difference from v003**: We use the contrapositive and soundness/completeness relationship, NOT direct model construction. This avoids needing truth correspondence for modal/temporal operators.

**Tasks**:
- [ ] Create `FMP/ConsistentSatisfiableV2.lean` with contrapositive approach
- [ ] Define/import necessary lemmas:
  - `not_satisfiable_implies_neg_valid`
  - `neg_provable_implies_inconsistent`
- [ ] Prove `consistent_implies_satisfiable` via contrapositive
- [ ] Verify no sorries

**Timing**: 1 hour

**Files to create**:
- `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiableV2.lean`

**Verification**:
- `lake build Bimodal.Metalogic.FMP.ConsistentSatisfiableV2` succeeds
- Theorem is sorry-free
- No direct model construction for modal/temporal

---

### Phase 3: Prove Infinitary Strong Completeness [NOT STARTED]

**Goal**: Prove `infinitary_strong_completeness` using the contrapositive bridge.

**Proof Strategy**:

```lean
theorem infinitary_strong_completeness (Γ : Set Formula) (phi : Formula)
    (h_sem : Γ ⊨ phi) : ∃ Δ : Finset Formula, ↑Δ ⊆ Γ ∧ Δ ⊢ phi := by
  -- Contrapositive: if no finite Δ ⊆ Γ derives phi, then Γ ⊭ phi
  by_contra h_no_finite
  -- By no_finite_witness_implies_union_consistent: Γ ∪ {phi.neg} is consistent
  have h_cons := no_finite_witness_implies_union_consistent h_no_finite
  -- By consistent_implies_satisfiable: Γ ∪ {phi.neg} is satisfiable
  have h_sat := consistent_implies_satisfiable h_cons
  -- There exists model satisfying Γ and phi.neg
  obtain ⟨M, w, h_Γ_sat, h_neg_sat⟩ := h_sat
  -- But Γ ⊨ phi and Γ satisfied means phi true at w
  have h_phi_true := h_sem M w h_Γ_sat
  -- Contradiction: phi and phi.neg both true at w
  exact absurd h_phi_true h_neg_sat
```

**Tasks**:
- [ ] Import or prove `no_finite_witness_implies_union_consistent`
  - Check if in Boneyard (research-005 mentions it)
  - May need to port from Representation
- [ ] Create `Completeness/InfinitaryStrongCompletenessFMP.lean`
- [ ] Prove `infinitary_strong_completeness` using Phase 2 bridge
- [ ] Verify no Representation imports (except utility lemmas)

**Timing**: 1 hour

**Files to create**:
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompletenessFMP.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Completeness.InfinitaryStrongCompletenessFMP` succeeds
- Theorem is sorry-free

---

### Phase 4: Prove Compactness [NOT STARTED]

**Goal**: Prove `compactness` as corollary of infinitary completeness.

**Proof Strategy**:
Compactness: If every finite subset of Γ is satisfiable, then Γ is satisfiable.

```lean
theorem compactness (Γ : Set Formula)
    (h_fin_sat : ∀ Δ : Finset Formula, ↑Δ ⊆ Γ → Satisfiable ↑Δ) :
    Satisfiable Γ := by
  -- Contrapositive: if Γ not satisfiable, some finite Δ ⊆ Γ not satisfiable
  by_contra h_not_sat
  -- Not satisfiable means Γ ⊨ ⊥
  have h_sem_bot : Γ ⊨ ⊥ := not_satisfiable_implies_entails_bot h_not_sat
  -- By infinitary_strong_completeness: some finite Δ ⊆ Γ derives ⊥
  obtain ⟨Δ, h_sub, h_derives⟩ := infinitary_strong_completeness Γ ⊥ h_sem_bot
  -- By soundness: Δ ⊨ ⊥, meaning Δ not satisfiable
  have h_Δ_not_sat := soundness_entails_bot h_derives
  -- But Δ ⊆ Γ and h_fin_sat says Δ is satisfiable
  exact h_Δ_not_sat (h_fin_sat Δ h_sub)
```

**Tasks**:
- [ ] Create `Compactness/CompactnessFMP.lean`
- [ ] Import from Phase 3
- [ ] Prove `compactness` and `compactness_iff`
- [ ] Verify no sorries

**Timing**: 0.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Compactness/CompactnessFMP.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Compactness.CompactnessFMP` succeeds
- Theorems are sorry-free

---

### Phase 5: Archive and Update Exports [NOT STARTED]

**Goal**: Archive blocked code and update module exports.

**Tasks**:
- [ ] Archive `ConsistentSatisfiable.lean`:
  - Keep file but add comment marking modal/temporal as blocked
  - OR move to Boneyard if propositional fragment not useful
- [ ] Update `FMP/FMP.lean` to export V2 version
- [ ] Update `Completeness/Completeness.lean` to export FMP versions
- [ ] Update `Compactness/Compactness.lean` to export FMP version
- [ ] Run full `lake build` to verify

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean` (add blocked notice)
- `Theories/Bimodal/Metalogic/FMP/FMP.lean`
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean`
- `Theories/Bimodal/Metalogic/Compactness/Compactness.lean`

**Verification**:
- `lake build` succeeds
- Main theorems accessible via top-level exports

---

## Testing & Validation

- [ ] `lake build` succeeds with 0 errors
- [ ] All target theorems are sorry-free:
  - [ ] `semantic_weak_completeness` (existing)
  - [ ] `finite_strong_completeness` (fixed in Phase 1)
  - [ ] `consistent_implies_satisfiable` (new in Phase 2)
  - [ ] `infinitary_strong_completeness` (new in Phase 3)
  - [ ] `compactness` (new in Phase 4)
- [ ] No blocked sorries in active exports
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard | grep -v "blocked"` returns nothing critical

## Success Criteria

| Criterion | Target | Priority |
|-----------|--------|----------|
| Main build passes | 0 errors | Critical |
| Target theorems sorry-free | 5/5 | Critical |
| Contrapositive approach works | No direct construction | Critical |
| Code cleanliness | Blocked code marked | High |

## Artifacts & Outputs

- `specs/810_strategic_review_representation_vs_semantic_paths/plans/implementation-004.md` (this file)
- New files:
  - `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiableV2.lean`
  - `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompletenessFMP.lean`
  - `Theories/Bimodal/Metalogic/Compactness/CompactnessFMP.lean`
- Modified:
  - `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean`
  - Various export files

## Comparison with v003

| Aspect | v003 | v004 (This Plan) |
|--------|------|------------------|
| Bridge lemma | Direct model construction | Contrapositive of weak completeness |
| Modal/temporal | Required truth correspondence | Avoided entirely |
| Sorries to resolve | 6 (blocked) | 0 (different approach) |
| Effort | 3-4 hours (stuck) | 2-3 hours |
| Feasibility | Blocked | Achievable |

## Key Insight

The v003 plan tried to prove `consistent → satisfiable` by constructing a model directly. This requires proving truth correspondence for all operators, which fails for modal/temporal because:

1. Modal box needs quantification over MCS-derived states only, but the model has all states
2. Temporal operators need indexed MCS families, but constant history trivializes time

The v004 plan avoids this entirely by using the **contrapositive**: `¬satisfiable → ¬consistent`. This only needs:
1. If not satisfiable, then negation is valid (definition)
2. If valid, then provable (weak completeness - already sorry-free)
3. If negation provable, then not consistent (definition)

No model construction required. No truth correspondence for modal/temporal needed.

## Rollback/Contingency

If contrapositive approach encounters issues:
1. Check lemma signatures carefully - may need to massage definitions
2. The existing `semantic_weak_completeness` should provide the core
3. Soundness relationship may need explicit statement

The archived ConsistentSatisfiable.lean propositional fragment remains as reference.
