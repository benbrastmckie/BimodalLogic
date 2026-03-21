# Research Report: Task #569

**Task**: 569 - Analyze Proof Strategy Alternatives
**Started**: 2026-01-18T04:00:00Z
**Completed**: 2026-01-18T04:45:00Z
**Effort**: 2-3 hours
**Priority**: High
**Dependencies**: Task 566 (parent)
**Sources/Inputs**:
- FiniteCanonicalModel.lean (Metalogic)
- ContextProvability.lean (Metalogic_v2)
- Validity.lean (Semantics)
- Research from task 566
- Lean MCP tools (lean_local_search, lean_leansearch, lean_leanfinder)
**Artifacts**:
- specs/569_analyze_proof_strategy_alternatives/reports/research-001.md (this file)
**Standards**: report-format.md, subagent-return.md
**Session ID**: sess_1768707854_ab7139

## Executive Summary

- **Three viable proof strategies** exist for completing the semantic embedding in task 566
- **Strategy C (Use main_provable_iff_valid)** is the MOST PROMISING - bypasses all bridge sorries entirely using PROVEN theorems
- **Strategy A (Contrapositive via semantic_weak_completeness)** is a solid fallback using PROVEN infrastructure
- **Strategy B (Complete 4 bridge sorries)** should be DEFERRED - high complexity, not necessary if A or C work
- **Key discovery**: `valid_iff_empty_consequence` + `main_provable_iff_valid` may provide a direct path without any sorries

## Context & Scope

This research analyzes alternative proof strategies for completing the semantic embedding gap identified in task 566. The gap exists in bridging:

1. **Canonical model truth**: `phi in w.carrier` (set membership in MCS)
2. **Polymorphic semantic validity**: `semantic_consequence [] phi` (quantified over ALL temporal types D)

The current proof structure in `ContextProvability.lean` uses `semantic_consequence_implies_semantic_world_truth` as a bridge lemma, which has a sorry that depends on `truth_at_implies_semantic_truth` (4 sorries for compound formulas).

### Current Implementation State

**ContextProvability.lean** structure:
```lean
theorem representation_theorem_backward_empty : semantic_consequence [] phi -> ContextDerivable [] phi := by
  intro h_sem
  have h_all_sw := semantic_consequence_implies_semantic_world_truth h_sem  -- Bridge lemma (sorry)
  have h_prov := semantic_world_validity_implies_provable phi h_all_sw     -- Uses semantic_weak_completeness (PROVEN)
  exact ⟨h_prov⟩
```

**Bridge lemma dependency chain**:
```
semantic_consequence [] phi                    (hypothesis)
    |
    v (semantic_consequence_implies_semantic_world_truth - HAS SORRY)
forall w : SemanticWorldState phi, semantic_truth_at_v2 phi w origin phi
    |
    v (semantic_weak_completeness - PROVEN)
⊢ phi
    |
    v (wrap in ContextDerivable)
ContextDerivable [] phi
```

## Findings

### Strategy C: Use main_provable_iff_valid Directly (RECOMMENDED)

**Description**: The theorem `main_provable_iff_valid` (PROVEN, FiniteCanonicalModel.lean lines 4100-4111) establishes:

```lean
theorem main_provable_iff_valid (phi : Formula) : Nonempty (⊢ phi) ↔ valid phi
```

**Key Discovery**: Combined with `valid_iff_empty_consequence` (PROVEN, Validity.lean lines 136-142):

```lean
theorem valid_iff_empty_consequence (phi : Formula) : (⊨ phi) ↔ ([] ⊨ phi)
```

This gives a DIRECT path:

```
semantic_consequence [] phi
    ↔  valid phi                       (by valid_iff_empty_consequence.symm)
    →  Nonempty (⊢ phi)               (by main_provable_iff_valid.mpr)
    →  ContextDerivable [] phi         (trivial wrap)
```

**Proposed Implementation**:
```lean
theorem representation_theorem_backward_empty : semantic_consequence [] phi -> ContextDerivable [] phi := by
  intro h_sem
  -- Convert semantic_consequence [] phi to valid phi
  have h_valid : valid phi := (Validity.valid_iff_empty_consequence phi).mpr h_sem
  -- Use main_provable_iff_valid to get Nonempty (⊢ phi)
  have h_prov : Nonempty (⊢ phi) := main_provable_iff_valid phi |>.mpr h_valid
  -- Wrap in ContextDerivable
  exact h_prov.elim (fun d => ⟨d⟩)
```

**Advantages**:
- Uses ONLY proven theorems (main_provable_iff_valid, valid_iff_empty_consequence)
- Bypasses ALL bridge lemmas and their sorries
- Cleanest and shortest proof path
- No changes to FiniteCanonicalModel.lean needed

**Potential Issues**:
- Need to verify imports compile (FiniteCanonicalModel is already imported)
- Universe level compatibility (both use `Type` not `Type*`)
- The `main_provable_iff_valid` returns `Nonempty (⊢ phi)` which wraps to `ContextDerivable [] phi`

**Effort Estimate**: 1-2 hours

**Status**: HIGHEST PRIORITY - attempt first

### Strategy A: Direct Instantiation via Contrapositive

**Description**: Use the contrapositive of `semantic_weak_completeness` directly, avoiding the current bridge lemma approach.

**Key Insight**: The `semantic_weak_completeness` theorem (PROVEN, lines 3050-3102 in FiniteCanonicalModel.lean) already proves:

```lean
(forall w : SemanticWorldState phi, semantic_truth_at_v2 phi w origin phi) -> ⊢ phi
```

Its CONTRAPOSITIVE is:
```lean
not (⊢ phi) -> exists w : SemanticWorldState phi, not (semantic_truth_at_v2 phi w origin phi)
```

**Proof Sketch**:
```lean
theorem representation_theorem_backward_empty : semantic_consequence [] phi -> ContextDerivable [] phi := by
  -- Use contrapositive: show ¬ContextDerivable [] phi → ¬semantic_consequence [] phi
  apply Function.mtr  -- Mathlib contrapositive helper
  intro h_not_deriv

  -- Step 1: Get falsifying SemanticWorldState from semantic_weak_completeness contrapositive
  have h_not_prov : ¬Nonempty (⊢ phi) := h_not_deriv
  -- By contrapositive of semantic_weak_completeness: ∃ w, ¬semantic_truth_at_v2 phi w origin phi

  -- Step 2: Get WorldHistory containing the falsifying state
  -- Use semantic_world_state_has_world_history (PROVEN)

  -- Step 3: Instantiate semantic_consequence with D = Int, F = SemanticCanonicalFrame phi

  -- Step 4: Get contradiction (semantic_consequence says true, but state says false)
```

**Advantages**:
- Uses PROVEN infrastructure (semantic_weak_completeness, semantic_world_state_has_world_history)
- Contrapositive is a natural proof strategy for completeness
- Avoids the forward bridge direction entirely

**Disadvantages**:
- More complex than Strategy C
- Requires careful handling of Nonempty vs Prop coercions
- Still needs to instantiate the polymorphic quantifier explicitly

**Effort Estimate**: 2-3 hours

**Status**: Recommended fallback if Strategy C fails

### Strategy B: Complete Bridge Sorries in truth_at_implies_semantic_truth

**Description**: Complete the 4 remaining sorries in `truth_at_implies_semantic_truth` for compound formulas (imp, box, all_past, all_future).

**Current State** (FiniteCanonicalModel.lean lines 3588-3652):

| Case | Status | Complexity |
|------|--------|------------|
| atom | PROVEN | Low |
| bot | PROVEN | Low |
| imp | SORRY | Medium - requires understanding assignment for compound formulas |
| box | SORRY | High - requires modal consistency across all histories |
| all_past | SORRY | High - requires temporal consistency |
| all_future | SORRY | High - requires temporal consistency |

**Analysis of Root Cause**:

The fundamental issue is the mismatch between:

1. **`truth_at`** (recursive semantic evaluation):
   - For `psi.imp chi`: `truth_at M tau t psi -> truth_at M tau t chi`
   - For `psi.box`: `forall sigma, truth_at M sigma t psi`
   - For `psi.all_past`: `forall s < t, truth_at M tau s psi`
   - For `psi.all_future`: `forall s > t, truth_at M tau s psi`

2. **`FiniteWorldState.assignment`** (flat lookup):
   - Defined as: `closure phi -> Bool`
   - The assignment is constructed from a maximal consistent set
   - `models psi h_mem := assignment ⟨psi, h_mem⟩ = true`

Converting `truth_at` to assignment requires proving the **canonical model property** - that the assignment correctly represents semantic truth. This requires negation-completeness of the underlying MCS construction.

**Effort Estimate**: 4-6 hours (significant complexity)

**Status**: DEFER - not needed if Strategy A or C work

### Comparison of Strategies

| Strategy | Proven Parts | Blocking Sorries | Effort | Recommendation |
|----------|--------------|------------------|--------|----------------|
| **C: main_provable_iff_valid** | All (main_provable_iff_valid, valid_iff_empty_consequence) | None | 1-2 hrs | **TRY FIRST** |
| **A: Contrapositive** | semantic_weak_completeness, semantic_world_state_has_world_history | None (different path) | 2-3 hrs | Fallback |
| **B: Complete sorries** | Partial | 4 compound formula cases | 4-6 hrs | Defer |

### Alternative Lemmas from Rollback Section

The implementation plan mentions using `finite_model_property_contrapositive`. Searching revealed:

- `finite_model_property_v2` exists (line 4210) but uses satisfiability direction
- No direct `finite_model_property_contrapositive` found by that name
- The FMP approach would require same bridge infrastructure

The `main_provable_iff_valid` approach (Strategy C) is cleaner than going through FMP.

## Decisions

1. **Strategy C should be attempted first** - Uses only PROVEN theorems, bypasses all sorries
2. **Strategy A is the recommended fallback** - Contrapositive using proven infrastructure
3. **Strategy B should be deferred** - Only needed if A and C both fail
4. **The current bridge lemma is deprecated** - `semantic_consequence_implies_semantic_world_truth` with its sorry is unnecessary

## Recommendations

### Primary Recommendation: Implement Strategy C

1. **Verify type compatibility**:
   ```lean
   #check @main_provable_iff_valid
   -- Expected: (phi : Formula) : Nonempty (⊢ phi) ↔ valid phi

   #check @Validity.valid_iff_empty_consequence
   -- Expected: (phi : Formula) : (⊨ phi) ↔ ([] ⊨ phi)
   ```

2. **Rewrite representation_theorem_backward_empty**:
   ```lean
   theorem representation_theorem_backward_empty : semantic_consequence [] phi -> ContextDerivable [] phi := by
     intro h_sem
     have h_valid : valid phi := (Validity.valid_iff_empty_consequence phi).mpr h_sem
     have h_prov : Nonempty (⊢ phi) := (main_provable_iff_valid phi).mpr h_valid
     exact h_prov.elim (fun d => ⟨d⟩)
   ```

3. **Remove the deprecated bridge lemma** `semantic_consequence_implies_semantic_world_truth`

4. **Verify with lake build and #print axioms**

### Secondary Recommendation: Strategy A (if C fails)

If Strategy C has issues (universe levels, import cycles):

1. Use `Function.mtr` for contrapositive
2. Leverage `semantic_weak_completeness` contrapositive direction
3. Use `semantic_world_state_has_world_history` (PROVEN)
4. Construct the countermodel instantiation explicitly

### Tertiary: Create Subtask for Strategy B (if both fail)

If both A and C fail, create Task 571 to specifically address:
- Completing the 4 compound formula cases
- Establishing negation-completeness for SemanticWorldState
- Documenting the proof obligations

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Universe level mismatch in Strategy C | High | Low | Both valid and semantic_consequence use `Type` not `Type*` |
| Import cycle issues | Medium | Low | FiniteCanonicalModel already imported |
| Nonempty vs Prop coercion issues | Low | Medium | Standard elimination patterns |
| Strategy C definitional equivalence fails | Medium | Low | Fall back to Strategy A |

## Appendix

### Search Queries Used

1. `lean_local_search "not_derivable"` - Found `not_derivable_implies_neg_consistent`
2. `lean_local_search "semantic_truth_lemma"` - Found `semantic_truth_lemma_v2` (PROVEN)
3. `lean_local_search "semantic_consequence"` - Found key theorems
4. `lean_local_search "finite_model_property"` - Found FMP variants
5. `lean_leansearch "contrapositive of implication"` - Found `Function.mtr`, `not_imp_not`
6. `lean_leanfinder "proof by instantiation of universal quantifier"` - Found `ball_of_forall`

### Key File Locations

| Theorem | File | Line | Status |
|---------|------|------|--------|
| main_provable_iff_valid | FiniteCanonicalModel.lean | ~4100 | **PROVEN** |
| valid_iff_empty_consequence | Validity.lean | ~136 | **PROVEN** |
| semantic_weak_completeness | FiniteCanonicalModel.lean | ~3050 | **PROVEN** |
| semantic_truth_lemma_v2 | FiniteCanonicalModel.lean | ~2801 | **PROVEN** |
| semantic_world_state_has_world_history | FiniteCanonicalModel.lean | ~3443 | **PROVEN** |
| truth_at_implies_semantic_truth | FiniteCanonicalModel.lean | ~3588 | 4 SORRIES |
| semantic_consequence_implies_semantic_world_truth | ContextProvability.lean | ~157 | HAS SORRY |
| representation_theorem_backward_empty | ContextProvability.lean | ~226 | HAS SORRY (via bridge) |

### Mathlib References

- `Function.mtr` - Contrapositive helper: `(¬q → ¬p) → p → q`
- `not_imp_not` - `(¬a → ¬b) ↔ (b → a)`
- `Quotient.out` - Extract representative from quotient
- `Quotient.out_eq` - `Quotient.mk (Quotient.out q) = q`

### Proof Infrastructure Summary

The key insight is that the completeness proof can be structured as:

```
          semantic_consequence [] phi
                    ↓
          valid_iff_empty_consequence (PROVEN)
                    ↓
                valid phi
                    ↓
          main_provable_iff_valid (PROVEN)
                    ↓
             Nonempty (⊢ phi)
                    ↓
          ContextDerivable [] phi
```

This bypasses ALL the bridge infrastructure and its sorries.

## Next Steps

1. **Immediate**: Attempt Strategy C implementation in ContextProvability.lean
2. **Verify**: Run `lake build` and `#print axioms representation_theorem_backward_empty`
3. **If C fails**: Implement Strategy A (contrapositive approach)
4. **Cleanup**: Remove deprecated `semantic_consequence_implies_semantic_world_truth` lemma
5. **Document**: Update task 566 plan with the successful strategy
