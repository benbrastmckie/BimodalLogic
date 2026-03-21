# Research Report: Task #472

**Task**: 472 - Lindenbaum extension for finite closures
**Started**: 2026-01-13T19:20:00Z
**Completed**: 2026-01-13T20:15:00Z
**Effort**: 8-12 hours (estimated implementation)
**Priority**: Medium
**Parent**: Task 458
**Dependencies**: None (builds on existing infrastructure)
**Sources/Inputs**:
  - FiniteCanonicalModel.lean (current implementation)
  - Completeness.lean (set_lindenbaum, SetMaximalConsistent, set_mcs_negation_complete)
  - Task 449 research (truth lemma gaps)
  - Task 473 research (compositionality gaps analysis)
  - Mathlib (Finite.exists_le_maximal, FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem)
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Core Need**: The finite canonical model needs a restricted Lindenbaum lemma that extends consistent formula sets to maximal consistent sets *within the finite subformula closure*, not over all formulas
- **Key Insight**: Unlike full Lindenbaum (uses Zorn's lemma over infinite sets), finite closure Lindenbaum can use simpler induction over the finite closure elements
- **Existing Infrastructure**: `set_lindenbaum` and `SetMaximalConsistent` in Completeness.lean provide the full Lindenbaum lemma; `set_mcs_negation_complete` provides negation-completeness
- **Strategy**: Define `ClosureMaximalConsistent` as restriction of `SetMaximalConsistent` to closure, then either (A) project existing MCS to closure, or (B) build finite MCS directly using `Finite.exists_le_maximal`
- **Blockers Resolved**: This lemma directly enables proving existence axioms (`finite_forward_existence`, `finite_backward_existence`) and truth lemma backward directions

## Context & Scope

### Problem Statement

Task 458 implemented a finite canonical model approach for completeness. The implementation created `FiniteCanonicalModel.lean` with:

1. **FiniteWorldState** - Truth assignments on subformula closure with `IsLocallyConsistent`
2. **finite_task_rel** - Task relation with transfer and persistence properties
3. **finite_truth_lemma** - Truth lemma (has 8 sorry gaps in backward directions)
4. **Existence axioms** - `finite_forward_existence`, `finite_backward_existence`

The key missing piece is the **Lindenbaum extension for finite closures**: given a consistent set of formulas (subset of the closure), extend it to a maximal consistent set within the closure.

### Why Finite Lindenbaum is Different

The standard Lindenbaum lemma (proven as `set_lindenbaum` in Completeness.lean) uses Zorn's lemma to extend a consistent set to a maximal consistent set over *all formulas*. This produces an infinite set.

For the finite canonical model, we need:
1. **Bounded Extension**: The maximal set must be a subset of `closure phi` (finite)
2. **Closure-Relative Maximality**: Maximal with respect to adding formulas from the closure, not all formulas
3. **Negation-Completeness**: For each formula in closure, either it or its negation (if in closure) is in the maximal set

### Current Gaps This Addresses

| Gap Location | Gap Type | How Lindenbaum Helps |
|--------------|----------|----------------------|
| `finite_forward_existence` (axiom) | Existence | Construct successor state by extending transfer requirements |
| `finite_backward_existence` (axiom) | Existence | Construct predecessor state by extending transfer requirements |
| `finite_truth_lemma` lines 1296, 1300 | Imp backward | Negation-completeness for implication-completeness |
| `finite_truth_lemma` lines 1328, 1338 | Box backward | Negation-completeness for canonical property |
| `finite_truth_lemma` lines 1360, 1382 | Temporal backward | Negation-completeness for temporal formulas |

## Findings

### 1. Existing Lindenbaum Infrastructure

The following is already proven in `Completeness.lean`:

```lean
-- Set-based consistency
def SetConsistent (S : Set Formula) : Prop :=
  ∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → Consistent L

-- Set-based maximal consistency
def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S ∧ ∀ φ : Formula, φ ∉ S → ¬SetConsistent (insert φ S)

-- Lindenbaum's lemma (uses Zorn)
theorem set_lindenbaum (S : Set Formula) (hS : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent M

-- Negation completeness
theorem set_mcs_negation_complete {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) (φ : Formula) :
    φ ∈ S ∨ (Formula.neg φ) ∈ S
```

### 2. Closure-Restricted Definitions Needed

For the finite model, we need analogous definitions restricted to a closure:

```lean
/-- Closure-restricted consistency: consistent when considering only closure formulas. -/
def ClosureConsistent (phi : Formula) (S : Set Formula) : Prop :=
  S ⊆ closure phi ∧ SetConsistent S

/-- Closure-restricted maximal consistency. -/
def ClosureMaximalConsistent (phi : Formula) (S : Set Formula) : Prop :=
  ClosureConsistent phi S ∧
  ∀ ψ ∈ closure phi, ψ ∉ S → ¬SetConsistent (insert ψ S)

/-- Closure-restricted negation completeness (key property). -/
theorem closure_mcs_negation_complete {phi : Formula} {S : Set Formula}
    (h_mcs : ClosureMaximalConsistent phi S) (ψ : Formula)
    (h_psi : ψ ∈ closure phi) (h_neg : Formula.neg ψ ∈ closure phi) :
    ψ ∈ S ∨ (Formula.neg ψ) ∈ S
```

### 3. Two Strategies for Finite Lindenbaum

#### Strategy A: Project Full MCS to Closure

Use the existing `set_lindenbaum` to get a full MCS, then project to the closure:

```lean
theorem closure_lindenbaum_via_projection (phi : Formula) (S : Set Formula)
    (h_sub : S ⊆ closure phi) (h_cons : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ ClosureMaximalConsistent phi M := by
  -- Step 1: Get full MCS containing S
  obtain ⟨M_full, h_S_sub, h_mcs⟩ := set_lindenbaum S h_cons
  -- Step 2: Project to closure
  let M := M_full ∩ closure phi
  use M
  constructor
  · -- S ⊆ M follows from S ⊆ M_full and S ⊆ closure phi
    intro ψ h_ψ
    exact ⟨h_S_sub h_ψ, h_sub h_ψ⟩
  · constructor
    · constructor
      · -- M ⊆ closure phi (by definition)
        exact Set.inter_subset_right
      · -- SetConsistent M (subset of consistent M_full)
        intro L h_L
        have h_L_full : ∀ φ ∈ L, φ ∈ M_full := fun φ hφ => (h_L φ hφ).1
        exact h_mcs.1 L h_L_full
    · -- Closure-restricted maximality
      intro ψ h_ψ_closure h_ψ_not_M h_cons'
      -- If ψ ∈ closure phi and ψ ∉ M, then either:
      -- 1. ψ ∉ M_full → contradicts maximality of M_full
      -- 2. ψ ∈ M_full → contradicts ψ ∉ M (since M = M_full ∩ closure)
      by_cases h : ψ ∈ M_full
      · exact h_ψ_not_M ⟨h, h_ψ_closure⟩
      · exact h_mcs.2 ψ h h_cons'
```

**Pros**: Reuses proven infrastructure, straightforward proof
**Cons**: Requires classical reasoning (Zorn), may be overkill for finite case

#### Strategy B: Direct Finite Construction

Use `Finite.exists_le_maximal` from Mathlib directly on the finite closure:

```lean
-- From Mathlib
theorem Finite.exists_le_maximal [Finite α] (h : p a) : ∃ b, a ≤ b ∧ Maximal p b

theorem closure_lindenbaum_finite (phi : Formula) (S : Finset Formula)
    (h_sub : ↑S ⊆ closure phi) (h_cons : SetConsistent ↑S) :
    ∃ M : Finset Formula, S ⊆ M ∧ ↑M ⊆ closure phi ∧
      ∀ ψ ∈ closure phi, ψ ∉ M → ¬SetConsistent (insert ψ ↑M) := by
  -- Define predicate: consistent subsets of closure containing S
  let P : Finset Formula → Prop := fun T => S ⊆ T ∧ ↑T ⊆ closure phi ∧ SetConsistent ↑T
  -- S satisfies P
  have h_S_P : P S := ⟨Finset.Subset.refl S, h_sub, h_cons⟩
  -- Apply Finite.exists_le_maximal on subsets of (closure phi)
  -- This requires showing (Finset.powerset (closure phi)) is finite (automatic)
  -- and that P-satisfying sets form a finite type
  sorry -- Requires careful setup of the order structure
```

**Pros**: Avoids Zorn, more constructive, directly works with finite sets
**Cons**: More setup required, need to handle Finset/Set conversions

### 4. Bridging to FiniteWorldState

Once we have `ClosureMaximalConsistent`, we need to show it induces `IsLocallyConsistent`:

```lean
/-- A closure-maximal consistent set induces a locally consistent truth assignment. -/
theorem closure_mcs_implies_locally_consistent (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) :
    IsLocallyConsistent phi (assignmentFromSet phi S)
```

The proof uses:
1. **Bot is false**: Consistency implies bot ∉ S
2. **Implications respected**: Follows from closure under derivation (set_mcs_closed_under_derivation)
3. **T axiom**: Box(ψ) ∈ S → ψ ∈ S (from axiom derivability)
4. **Temporal reflexivity**: Similar to T axiom

### 5. Key Theorem: Negation-Completeness for Closure

The most important property is negation-completeness restricted to closure:

```lean
theorem closure_mcs_negation_complete {phi : Formula} {S : Set Formula}
    (h_mcs : ClosureMaximalConsistent phi S) (ψ : Formula)
    (h_psi : ψ ∈ closure phi) (h_neg : Formula.neg ψ ∈ closure phi) :
    ψ ∈ S ∨ (Formula.neg ψ) ∈ S := by
  by_cases h : ψ ∈ S
  · left; exact h
  · right
    -- If ψ ∉ S and ψ ∈ closure phi, then insert ψ S is inconsistent
    have h_incons := h_mcs.2 ψ h_psi h
    -- Extract derivation of ⊥ from S ∪ {ψ}
    -- By deduction theorem: S ⊢ ψ → ⊥, i.e., S ⊢ ¬ψ
    -- Since ¬ψ ∈ closure phi, we need ¬ψ ∈ S by closure under derivation
    sorry -- Similar to set_mcs_negation_complete proof
```

**Key Insight**: The proof mirrors `set_mcs_negation_complete` but only works when `Formula.neg ψ ∈ closure phi`.

### 6. Closure Must Include Negations

**Issue**: The current `closure phi` is just subformulas of `phi`, which may not include negations.

**Example**: If `phi = p.box`, then `closure phi = {p.box, p}`. Neither `p.neg` nor `p.box.neg` are in the closure.

**Solution**: Use `closureWithNeg` (already defined in FiniteCanonicalModel.lean):

```lean
def closureWithNeg (phi : Formula) : Finset Formula :=
  closure phi ∪ (closure phi).image Formula.neg
```

This ensures that for any `ψ ∈ closure phi`, we have `ψ.neg ∈ closureWithNeg phi`.

**Alternative**: Only require negation-completeness for formulas whose negations are already in the closure. This is more restrictive but simpler.

### 7. Integration with Truth Lemma

The truth lemma backward directions require this pattern:

```lean
-- Implication case backward direction
-- Have: finite_truth_at psi → finite_truth_at chi
-- Need: (psi.imp chi) ∈ state

-- By negation completeness (from closure MCS):
-- Either (psi.imp chi) ∈ state or (psi.imp chi).neg ∈ state

-- If (psi.imp chi) ∈ state, done.
-- If (psi.imp chi).neg ∈ state:
--   By derivation: (psi.imp chi).neg = psi.and chi.neg
--   So psi ∈ state and chi.neg ∈ state
--   psi ∈ state → finite_truth_at psi (by IH)
--   finite_truth_at psi → finite_truth_at chi (by hypothesis)
--   chi ∈ state (by IH reverse)
--   chi ∈ state and chi.neg ∈ state → contradiction (consistency)
```

### 8. Mathlib Patterns

Relevant Mathlib theorems:

| Theorem | Use |
|---------|-----|
| `Finite.exists_le_maximal` | Direct finite maximality |
| `Set.Finite.exists_le_maximal` | Finite set maximality |
| `Finset.exists_le_maximal` | Finset maximality |
| `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem` | Pattern for negation-completeness |
| `Set.Finite.exists_maximal_wrt` | Maximal with respect to a function |

### 9. Dependencies and Blocking

| Blocked Item | How Lindenbaum Unblocks |
|--------------|-------------------------|
| `finite_forward_existence` | Construct successor by extending transfer requirements to closure MCS |
| `finite_backward_existence` | Construct predecessor by extending transfer requirements to closure MCS |
| Truth lemma imp backward | Negation-completeness gives implication-completeness |
| Truth lemma box backward | Negation-completeness for box formulas |
| Truth lemma temporal backward | Negation-completeness for temporal formulas |
| `finite_history_from_state` | Use existence lemmas with closure MCS states |

## Decisions

1. **Primary Strategy**: Use Strategy A (project full MCS to closure)
   - Reuses proven `set_lindenbaum`
   - Simpler proof structure
   - Classical reasoning is acceptable in completeness proofs

2. **Closure Definition**: Use `closureWithNeg` for negation-completeness
   - Ensures `ψ.neg ∈ closure` for all `ψ ∈ closure`
   - Small increase in closure size (at most 2x)
   - Enables full negation-completeness

3. **World State Bridge**: Add `ClosureMaximalConsistent` structure
   - Bridge between `SetMaximalConsistent` and `IsLocallyConsistent`
   - Enables reuse of MCS properties in finite model

## Recommendations

### Phase 1: Define Closure-Restricted Structures (2 hours)

1. Define `closureWithNeg` if not already done (it is defined but may need properties)
2. Define `ClosureConsistent` and `ClosureMaximalConsistent`
3. Prove basic properties (subset relations, consistency inheritance)

### Phase 2: Prove Closure Lindenbaum (3 hours)

1. Implement `closure_lindenbaum_via_projection` using `set_lindenbaum`
2. Prove closure-restricted negation-completeness
3. Prove closure under derivation for closure MCS

### Phase 3: Bridge to FiniteWorldState (2 hours)

1. Prove `closure_mcs_implies_locally_consistent`
2. Define `worldStateFromClosureMCS`
3. Prove world state inherits negation-completeness

### Phase 4: Prove Existence Lemmas (3 hours)

1. Replace `finite_forward_existence` axiom with theorem
2. Replace `finite_backward_existence` axiom with theorem
3. Update `finite_history_from_state` to use proven existence

### Phase 5: Complete Truth Lemma (2 hours)

1. Fill backward direction sorries using negation-completeness
2. Verify all cases complete
3. Run diagnostics to confirm no remaining sorries

### Estimated Total: 12 hours

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `closureWithNeg` size explosion | Medium | Low | Size at most 2x original closure |
| MCS projection loses properties | High | Low | Verify projection preserves negation-completeness |
| Classical reasoning in finite case | Low | Low | Acceptable for completeness proofs |
| Interaction with compositionality gaps | Medium | Medium | Compositionality gaps are orthogonal to this work |

## Appendix

### Key Code Locations

| Component | File | Lines | Status |
|-----------|------|-------|--------|
| `closure` | FiniteCanonicalModel.lean | 243-245 | Defined |
| `closureWithNeg` | FiniteCanonicalModel.lean | 366-367 | Defined |
| `IsLocallyConsistent` | FiniteCanonicalModel.lean | 413-441 | Needs negation-completeness |
| `set_lindenbaum` | Completeness.lean | 360-409 | Proven |
| `set_mcs_negation_complete` | Completeness.lean | 679-732 | Proven |
| `finite_forward_existence` | FiniteCanonicalModel.lean | 1097-1098 | Axiom (to be proven) |
| `finite_backward_existence` | FiniteCanonicalModel.lean | 1106-1107 | Axiom (to be proven) |

### Mathlib Search Results

1. `Finite.exists_le_maximal` - Direct finite maximality
2. `Set.Finite.exists_le_maximal` - Finite set maximality
3. `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem` - Pattern for negation-completeness
4. `zorn_subset_nonempty` - Used in `set_lindenbaum`

### Related Tasks

- **Task 449**: Truth lemma (depends on this task for backward directions)
- **Task 473**: Compositionality gaps (orthogonal to this work)
- **Task 450**: Completeness theorems (depends on truth lemma)
- **Task 458**: Parent task (finite canonical model)

## Next Steps

1. Run `/plan 472` to create detailed implementation plan
2. Begin with Phase 1: closure-restricted structures
3. Coordinate with Task 449 (truth lemma) for integration
