# Implementation Plan: Task #623 (Revision 2)

- **Task**: 623 - Build FMP-tableau connection infrastructure
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours (revised from 6)
- **Priority**: High
- **Dependencies**: Task 490 (parent task)
- **Research Inputs**: specs/623_build_fmp_tableau_connection_infrastructure/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**Why revised**: Prior implementation attempt for Phase 2 introduced ~40 compilation errors due to incorrect proof techniques. Changes were reverted. This revision incorporates lessons learned and provides correct technical approach.

**Key changes from v001**:
1. Fixed file paths (`Theories/` not `Logos/Theories/`)
2. Corrected Phase 1/2 status (Phase 1 complete, Phase 2 NOT complete)
3. Added detailed technical guidance for `isExpanded` lemmas (no `native_decide`)
4. Added new Phase 2.1 for fixing existing `open_branch_consistent` error
5. Restructured Phase 2 with correct proof techniques

## Overview

This plan implements infrastructure connecting Finite Model Property (FMP) bounds to tableau semantics. The work involves completing sorries in CountermodelExtraction.lean and Correctness.lean.

### Current State

| File | Status | Remaining Sorries |
|------|--------|-------------------|
| Saturation.lean | ✅ Complete | 0 |
| CountermodelExtraction.lean | 🔶 In Progress | 2 (lines 193, 217) + 1 existing error (line 176) |
| Correctness.lean | ❌ Not Started | 3 (lines 114, 163, 295) |

## Goals & Non-Goals

**Goals**:
- Fix `open_branch_consistent` proof error (line 176)
- Complete `saturated_imp_expanded` proof (line 193)
- Complete `branchTruthLemma` proof (line 217)
- Prove `tableau_complete` (Correctness.lean line 114)

**Non-Goals**:
- `decide_complete` (line 163) - depends on proof extraction, separate task
- `decide_axiom_valid` (line 295) - requires matchAxiom completeness, separate task
- Full FMP-to-TaskModel semantic bridge (would require significant new infrastructure)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `native_decide` doesn't work for `isExpanded` | H | Confirmed | Use `simp [isExpanded, applyRule]` with explicit case unfolding |
| Structure destructuring issues | M | Confirmed | Use `rcases sf with ⟨sign, formula⟩` not `cases sf` |
| BEq/Eq confusion | M | Confirmed | Always use `beq_iff_eq` for String equality |
| Semantic bridge gap | H | M | Use simplified `evalFormula` model, defer full semantics |

## Implementation Phases

### Phase 1: Complete expansion_decreases_measure [COMPLETED]

**Completed in prior session**. All sorries in Saturation.lean resolved. BEq lemmas added.

---

### Phase 2.1: Fix open_branch_consistent [COMPLETED]

**Goal**: Fix the existing error at CountermodelExtraction.lean line 176

**Issue**: The `obtain ⟨⟨_, hNoContra⟩, _⟩ := hOpen` tactic fails because the structure of `findClosure b = none` after the `Option.orElse_eq_none` rewrites doesn't match the expected pattern.

**Root Cause**: `findClosure` definition may have changed, or `Option.orElse_eq_none` produces a different structure than expected.

**Approach**:
1. Use `lean_goal` at line 175 to see actual goal state after rewrites
2. Use `lean_hover_info` on `findClosure` to understand its structure
3. Adjust the destructuring pattern to match actual structure

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean` - lines 174-176

**Verification**:
- No error at line 176
- `open_branch_consistent` compiles

---

### Phase 2.2: Prove saturated_imp_expanded [COMPLETED]

**Goal**: Complete the `saturated_imp_expanded` proof at line 193

**Key Insight**: This theorem is actually **vacuously true**. T(φ→ψ) cannot exist in a saturated branch because `isExpanded` returns false for it (the `impPos` rule applies). Since saturation means all formulas are expanded, T(φ→ψ) being in a saturated branch is a contradiction.

**Proof Strategy**:
```lean
theorem saturated_imp_expanded (b : Branch) (hSat : findUnexpanded b = none)
    (φ ψ : Formula) :
    SignedFormula.pos (.imp φ ψ) ∈ b → SignedFormula.neg φ ∈ b ∨ SignedFormula.pos ψ ∈ b := by
  intro h_imp_in
  exfalso
  -- Show that T(φ→ψ) would be unexpanded, contradicting saturation
  have h_not_expanded : isExpanded (SignedFormula.pos (.imp φ ψ)) = false := by
    simp only [isExpanded, applyRule]
    -- Case analysis shows impPos applies
    sorry  -- fill with actual tactics
  simp only [findUnexpanded, List.find?_eq_none] at hSat
  have h := hSat (SignedFormula.pos (.imp φ ψ)) h_imp_in
  simp only [decide_eq_true_eq] at h
  exact absurd h_not_expanded (by simp [h])
```

**DO NOT USE** `native_decide` for `isExpanded` - it doesn't work.

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean` - line 193

---

### Phase 2.3: Prove branchTruthLemma [COMPLETED]

**Goal**: Complete the `branchTruthLemma` proof at line 217

**Strategy**: The key insight from the failed attempt is correct - compound formulas cannot appear in saturated branches. But the implementation approach was wrong.

**Correct Approach**:

1. **Helper lemmas** (add before branchTruthLemma):
```lean
-- Prove by unfolding isExpanded and applyRule definitions
lemma isExpanded_pos_imp_false (φ ψ : Formula) :
    isExpanded (SignedFormula.pos (.imp φ ψ)) = false := by
  simp only [isExpanded]
  -- Show that applyRule impPos returns .linear, not .notApplicable
  sorry

lemma isExpanded_neg_imp_false (φ ψ : Formula) :
    isExpanded (SignedFormula.neg (.imp φ ψ)) = false := by
  simp only [isExpanded]
  sorry

-- Similar for box, all_future, all_past
```

2. **Structure for branchTruthLemma**:
```lean
theorem branchTruthLemma ... := by
  intro sf hsf_in
  constructor
  · intro hpos
    rcases sf with ⟨sign, formula⟩
    simp only [SignedFormula.sign] at hpos
    subst hpos
    match hf : formula with
    | .atom p =>
      -- Direct: extractValuation finds T(p) in branch
      simp only [evalFormula, extractValuation, List.any_eq_true]
      exact ⟨⟨.pos, .atom p⟩, hsf_in, by simp⟩
    | .bot =>
      -- T(⊥) closes branch, contradicts openness
      exfalso
      -- Use botPos_closes_branch or derive from hOpen
      sorry
    | .imp φ ψ =>
      -- T(φ→ψ) cannot be in saturated branch
      exfalso
      have := isExpanded_pos_imp_false φ ψ
      -- Contradiction with findUnexpanded = none
      sorry
    | .box φ => exfalso; sorry  -- Similar
    | .all_future φ => exfalso; sorry
    | .all_past φ => exfalso; sorry
  · intro hneg
    -- Symmetric negative case
    sorry
```

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean`

**Verification**:
- `lean_diagnostic_messages` shows no sorry in CountermodelExtraction.lean
- `lean_goal` at theorem end shows "no goals"

---

### Phase 3: Prove tableau_complete [BLOCKED]

**Goal**: Complete the `tableau_complete` theorem at Correctness.lean line 114

**Current signature** (not yet implemented):
```lean
theorem tableau_complete (φ : Formula) : (⊨ φ) →
    ∃ (fuel : Nat), (buildTableau φ fuel).isSome ∧
      ∀ t, buildTableau φ fuel = some t → t.isValid
```

**Strategy**:
This requires showing that for valid formulas, the tableau always closes (no open saturated branch).

**Proof outline**:
1. Use `fmpBasedFuel φ` as the witness fuel
2. Show `buildTableauWithFMPFuel` always returns `some` (by `fmp_fuel_sufficient`)
3. Case split on result:
   - `allClosed`: Done, `isValid = true`
   - `hasOpen b hSat`: Contradiction with validity
     - By `branchTruthLemma`, the branch describes a satisfying assignment
     - But we assumed `⊨ φ`, so F(φ) at root contradicts this

**Blocker**: The semantic bridge between `evalFormula` and `truth_at` is not established.

**Technical Gap Analysis**:
- `evalFormula` (CountermodelExtraction.lean:158-164) is a simplified propositional model that treats modal/temporal operators as identity functions
- `truth_at` (Semantics/TaskFrame.lean) is the full Kripke semantics with accessibility relations
- To prove `tableau_complete`, we need: `evalFormula b φ = false → ¬(⊨ φ)`
- This requires showing that the extracted branch describes a proper Kripke model where φ fails
- The gap is that `evalFormula` ignores modal semantics entirely (box/all_future/all_past = identity)

**What was achieved**:
- `branchTruthLemma` (CountermodelExtraction.lean:300) proves that saturated open branches correctly evaluate formulas under the simplified model
- This is the main infrastructure needed for future semantic bridge work
- `validity_decidable_via_fmp` provides decidability via classical logic as a fallback

**Future work to unblock**:
1. Create proper Kripke model from saturated branch with accessibility relation
2. Prove `evalFormula_implies_sat`: if `evalFormula b φ = false` then φ is not satisfiable in the extracted model
3. Connect extracted model to general `truth_at` semantics

**Files to modify (when unblocked)**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - add tableau_complete
- `Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean` - add semantic bridge lemmas

---

### Phase 4: Review and cleanup [COMPLETED]

**Goal**: Ensure all changes are clean and documented

**Tasks**:
- Remove any unused simp arguments (address linter warnings)
- Add docstrings to new lemmas
- Run `lake build` to verify clean build
- Create implementation summary

## Testing & Validation

- [ ] `lake build Bimodal` succeeds with no errors
- [ ] `lean_diagnostic_messages` on CountermodelExtraction.lean shows only warnings, no sorries
- [ ] `lean_diagnostic_messages` on Correctness.lean shows `tableau_complete` has no sorry
- [ ] All new lemmas have docstrings

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean` - fixed proofs
- `Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean` - tableau_complete
- Implementation summary at `specs/623_build_fmp_tableau_connection_infrastructure/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

1. If `isExpanded` lemmas prove intractable: Add them with `sorry` and detailed comments
2. If semantic bridge is too complex: Mark `tableau_complete` as blocked, document the gap
3. Preserve all working changes via incremental commits per phase
