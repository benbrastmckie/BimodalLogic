# Phase 5: Wave 3 Phase 1 - Lindenbaum Lemma and Maximal Sets

## Metadata
- **Date**: 2025-12-02
- **Phase**: Phase 5 of TODO Implementation Systematic Plan
- **Feature**: Prove Lindenbaum lemma and maximal consistent set properties for completeness foundation
- **Status**: [NOT STARTED]
- **Estimated Hours**: 20-30 hours
- **Complexity**: High
- **Dependencies**: Phase 4 (Wave 2 Completion)
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Parent Plan**: [TODO Implementation Systematic Plan](../plans/001-research-todo-implementation-plan.md)
- **Research Reports**:
  - [TODO Implementation Systematic Plan Report](../reports/001-todo-implementation-systematic-plan.md)

## Overview

This phase begins the completeness proof work by establishing the foundational properties of maximal consistent sets. This is the first of three phases in Wave 3 that will complete the metalogic proofs for TM logic. The phase focuses on replacing 3 axiom declarations in `Logos/Metalogic/Completeness.lean` with actual proofs.

**Current State**:
- `lindenbaum` (line 116): Declared as `axiom`, needs proof using Zorn's lemma or transfinite induction
- `maximal_consistent_closed` (line 140): Declared as `axiom`, needs proof using maximality + consistency
- `maximal_negation_complete` (line 154): Declared as `axiom`, needs proof using maximality property
- Axiom count in file: 11 total

**Target State**:
- All 3 theorems proven with zero `sorry` placeholders
- Axiom count decreased: 11 → 8
- Comprehensive tests in `LogosTest/Metalogic/CompletenessTest.lean`
- Documentation updated to reflect progress

**Why This Phase First**:
These three lemmas establish the fundamental properties of maximal consistent sets that are required for canonical model construction in Phase 6. Without these properties, we cannot prove that the canonical frame satisfies the task frame axioms or that the truth lemma holds.

## Success Criteria

- [ ] `lindenbaum` proven: Every consistent set extends to maximal consistent set
- [ ] `maximal_consistent_closed` proven: Maximal sets closed under modus ponens
- [ ] `maximal_negation_complete` proven: Maximal sets contain `φ` or `¬φ` for all formulas
- [ ] Axiom count decreased from 11 to 8 in Completeness.lean
- [ ] All tests pass: `lake test LogosTest.Metalogic.CompletenessTest`
- [ ] Zero `sorry` placeholders in the 3 proven theorems
- [ ] Documentation updated: TODO.md, IMPLEMENTATION_STATUS.md

## Technical Design

### Proof Strategy Overview

**1. Lindenbaum Lemma**

We have two viable approaches:

**Approach A: Zorn's Lemma** (Recommended for LEAN 4)
- Use `Zorn.chain_Sup` from Mathlib's order theory
- Construct chain of consistent extensions ordered by subset inclusion
- Apply Zorn's lemma to obtain maximal element
- Prove maximal element is maximal consistent

**Approach B: Transfinite Induction**
- Enumerate all formulas using well-ordering
- Iteratively extend context by adding formulas if consistent
- Construct transfinite sequence of consistent sets
- Prove limit is maximal consistent

**Recommendation**: Approach A (Zorn's Lemma) is more idiomatic in LEAN 4 and integrates better with Mathlib. Estimated 12-15 hours.

**2. Maximal Consistent Closed**

Proof structure:
1. Assume `MaximalConsistent Γ`, `Γ ⊢ φ`, but `φ ∉ Γ` (for contradiction)
2. By maximality: `φ :: Γ` is inconsistent, so `φ :: Γ ⊢ ⊥`
3. Apply deduction theorem: `Γ ⊢ φ → ⊥` (i.e., `Γ ⊢ ¬φ`)
4. Combine `Γ ⊢ φ` and `Γ ⊢ ¬φ` to derive `Γ ⊢ ⊥` (contradiction with consistency)
5. Therefore `φ ∈ Γ`

**Dependency**: Requires deduction theorem for TM logic (may need to prove or axiomatize)

**3. Maximal Negation Complete**

Proof structure:
1. Assume `MaximalConsistent Γ` and `φ ∉ Γ`
2. By maximality: `φ :: Γ` is inconsistent, so `φ :: Γ ⊢ ⊥`
3. Apply deduction theorem: `Γ ⊢ φ → ⊥` (i.e., `Γ ⊢ ¬φ`)
4. By closure property (from Task 5.2): `¬φ ∈ Γ`
5. Done

**Dependency**: This proof uses `maximal_consistent_closed`, so must be proven after Task 5.2

### Component Interactions

```
Consistent (definition, line 78)
   ↓
MaximalConsistent (definition, line 91)
   ↓
lindenbaum (Task 5.1) ← Uses Zorn's lemma from Mathlib
   ↓
maximal_consistent_closed (Task 5.2) ← Uses deduction theorem
   ↓
maximal_negation_complete (Task 5.3) ← Uses maximal_consistent_closed
   ↓
Phase 6: canonical_task_rel, canonical_frame (use all 3 properties)
```

### Deduction Theorem Requirement

**Problem**: Both `maximal_consistent_closed` and `maximal_negation_complete` rely on the deduction theorem:
```
Γ ∪ {φ} ⊢ ψ  →  Γ ⊢ φ → ψ
```

**Options**:
1. **Prove deduction theorem** in `Logos/ProofSystem/Derivation.lean` (estimated 5-8 hours)
2. **Axiomatize deduction theorem** as a meta-property of the derivability relation (estimated 1 hour, but adds axiom)
3. **Use proof-theoretic shortcuts** specific to TM logic (estimated 3-5 hours, research needed)

**Recommendation**: Option 1 (prove deduction theorem) is most rigorous. Include as Task 5.1.5 subtask.

### LEAN 4 Dependencies

**Required Mathlib Imports**:
```lean
import Mathlib.Order.Zorn
import Mathlib.Order.Chain
import Mathlib.Data.Set.Basic
import Mathlib.Logic.Relation
```

**Key Mathlib Theorems**:
- `Zorn.chain_Sup`: Main Zorn's lemma statement
- `Set.subset_def`: Subset properties for consistent set chains
- `Relation.ReflTransGen`: Transitive closure for derivability

## Implementation Phases

### Task 5.1: Prove Lindenbaum Lemma (12-15 hours)

**Objective**: Replace axiom declaration at line 116 with proof using Zorn's lemma

**Detailed Proof Strategy**:

1. **Define Consistent Extensions Ordering** (2-3 hours)
```lean
/-- The set of all consistent extensions of Γ -/
def ConsistentExtensions (Γ : Context) : Set Context :=
  {Δ | (∀ φ, φ ∈ Γ → φ ∈ Δ) ∧ Consistent Δ}

/-- Subset ordering on consistent extensions -/
instance : PartialOrder (ConsistentExtensions Γ) where
  le := fun Δ₁ Δ₂ => ∀ φ, φ ∈ Δ₁.val → φ ∈ Δ₂.val
  le_refl := fun Δ φ h => h
  le_trans := fun Δ₁ Δ₂ Δ₃ h₁₂ h₂₃ φ h => h₂₃ φ (h₁₂ φ h)
  le_antisymm := sorry -- Prove contexts equal if mutually subset
```

2. **Prove Chain Upper Bound Property** (3-4 hours)
```lean
/-- Union of chain of consistent contexts is consistent -/
lemma chain_union_consistent (C : Set (ConsistentExtensions Γ))
    (hchain : IsChain (· ≤ ·) C) :
    Consistent (⋃₀ (Set.image Subtype.val C)) := by
  intro h_inconsistent
  -- If union derives ⊥, derivation uses finitely many formulas
  -- By chain property, all formulas in some Δ ∈ C
  -- But then Δ ⊢ ⊥, contradicting Δ consistent
  sorry
```

3. **Apply Zorn's Lemma** (3-4 hours)
```lean
theorem lindenbaum (Γ : Context) (h : Consistent Γ) :
    ∃ Δ : Context, (∀ φ, φ ∈ Γ → φ ∈ Δ) ∧ MaximalConsistent Δ := by
  -- Use Zorn.chain_Sup with ConsistentExtensions ordering
  have zorn := Zorn.chain_Sup chain_union_consistent
  obtain ⟨Δ, ⟨hext, hcons⟩, hmax⟩ := zorn ⟨Γ, Subset.refl Γ, h⟩
  use Δ
  constructor
  · exact hext
  · constructor
    · exact hcons
    · intro φ hφ hcons_ext
      -- Use maximality: if φ :: Δ consistent, contradicts Δ maximal
      have : φ :: Δ ∈ ConsistentExtensions Γ := ⟨_, hcons_ext⟩
      have : Δ ≤ (φ :: Δ) := fun ψ hψ => Or.inr hψ
      have : Δ = φ :: Δ := hmax ⟨_, hcons_ext⟩ this
      exact absurd (this ▸ List.mem_cons_self φ Δ) hφ
```

4. **Handle Finiteness of Derivations** (2-3 hours)

Key lemma needed:
```lean
/-- Derivability uses only finitely many premises -/
lemma derivable_finitary (Γ : Context) (φ : Formula) :
    Derivable Γ φ → ∃ Γ_finite : List Formula,
      Γ_finite ⊆ Γ ∧ Derivable Γ_finite φ := by
  intro h
  induction h with
  | axiom ax => use [], trivial, Derivable.axiom ax
  | assumption hφ => use [φ], List.subset_cons φ [], Derivable.assumption (List.mem_cons_self _ _)
  | modus_ponens h_imp h_φ ih_imp ih_φ =>
      obtain ⟨Γ₁, h₁_sub, h₁_der⟩ := ih_imp
      obtain ⟨Γ₂, h₂_sub, h₂_der⟩ := ih_φ
      use Γ₁ ++ Γ₂
      constructor
      · exact List.append_subset h₁_sub h₂_sub
      · exact Derivable.modus_ponens (weakening h₁_der _) (weakening h₂_der _)
  | -- Continue for other rules...
```

**Testing Strategy**:
```lean
-- LogosTest/Metalogic/CompletenessTest.lean
#test "lindenbaum_empty_context"
  let h : Consistent [] := fun h_bot =>
    match h_bot with
    | Derivable.axiom _ => sorry -- No axiom derives ⊥
  let ⟨Δ, hext, hmax⟩ := lindenbaum [] h
  -- Verify Δ is maximal consistent
  assert hmax.1  -- Consistency
  assert hmax.2  -- Maximality

#test "lindenbaum_singleton_atom"
  let Γ := [Formula.atom "p"]
  let h : Consistent Γ := sorry -- Prove {p} consistent
  let ⟨Δ, hext, hmax⟩ := lindenbaum Γ h
  -- Verify p ∈ Δ (by extension property)
  assert hext (Formula.atom "p") (List.mem_cons_self _ _)
```

**File Changes**:
- File: `Logos/Metalogic/Completeness.lean`
- Lines: 116-117 (replace `axiom lindenbaum` with `theorem lindenbaum`)
- New imports: Add `import Mathlib.Order.Zorn` at top
- New definitions: `ConsistentExtensions`, `PartialOrder` instance, helper lemmas

**Estimated Time**: 12-15 hours

---

### Task 5.2: Prove Maximal Consistent Closed (4-6 hours)

**Objective**: Replace axiom declaration at line 140 with proof using maximality and consistency

**Prerequisite**: Deduction theorem for TM logic

**Detailed Proof Strategy**:

1. **Prove Deduction Theorem** (if not already proven) (3-4 hours)
```lean
-- File: Logos/ProofSystem/Derivation.lean (new theorem)
/-- Deduction theorem for TM logic -/
theorem deduction (Γ : Context) (φ ψ : Formula) :
    Derivable (φ :: Γ) ψ → Derivable Γ (φ.imp ψ) := by
  intro h
  induction h with
  | axiom ax =>
      -- Use prop_s: φ → (ψ → φ) where ψ is axiom instance
      sorry
  | assumption hψ =>
      cases hψ with
      | head =>
          -- Use prop_k to derive φ → φ
          sorry
      | tail _ htail =>
          -- Use prop_s: ψ → (φ → ψ)
          sorry
  | modus_ponens h_imp h_φ ih_imp ih_φ =>
      -- Γ ⊢ φ → (ψ → χ) and Γ ⊢ φ → ψ
      -- Use prop_k: (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
      sorry
  -- Continue for other rules (weakening, modal_k, temporal_k, temporal_duality)
```

**Note**: Deduction theorem requires propositional axioms K and S (added in Phase 1, Tasks 1.2-1.3), so this dependency is satisfied.

2. **Prove Maximal Consistent Closed** (2-3 hours)
```lean
theorem maximal_consistent_closed (Γ : Context) (φ : Formula) :
    MaximalConsistent Γ → Derivable Γ φ → φ ∈ Γ := by
  intro ⟨hcons, hmax⟩ hder
  by_contra hφ
  -- Assume φ ∉ Γ
  -- By maximality: φ :: Γ is inconsistent
  have hinconsistent : ¬Consistent (φ :: Γ) := hmax φ hφ
  -- So φ :: Γ ⊢ ⊥
  unfold Consistent at hinconsistent
  push_neg at hinconsistent
  -- Apply deduction theorem: Γ ⊢ φ → ⊥
  have hder_neg : Derivable Γ (φ.imp Formula.bot) :=
    deduction Γ φ Formula.bot hinconsistent
  -- We have Γ ⊢ φ and Γ ⊢ φ → ⊥
  -- By modus ponens: Γ ⊢ ⊥
  have hder_bot : Derivable Γ Formula.bot :=
    Derivable.modus_ponens hder_neg hder
  -- Contradicts consistency of Γ
  exact hcons hder_bot
```

**Testing Strategy**:
```lean
-- LogosTest/Metalogic/CompletenessTest.lean
#test "maximal_closed_simple"
  -- Create maximal consistent set (using lindenbaum on {p})
  let Γ := [Formula.atom "p"]
  let h_cons : Consistent Γ := sorry
  let ⟨Δ, _, hmax⟩ := lindenbaum Γ h_cons

  -- Verify: if Δ ⊢ p (which holds by assumption), then p ∈ Δ
  have hder : Derivable Δ (Formula.atom "p") :=
    Derivable.assumption sorry  -- p in Δ by extension
  have hmem : Formula.atom "p" ∈ Δ :=
    maximal_consistent_closed Δ (Formula.atom "p") hmax hder
  assert hmem

#test "maximal_closed_modus_ponens"
  -- If φ ∈ Δ and φ → ψ ∈ Δ, then ψ ∈ Δ (by closure)
  sorry
```

**File Changes**:
- File: `Logos/ProofSystem/Derivation.lean`
  - Add `theorem deduction` (new, ~30 lines)
- File: `Logos/Metalogic/Completeness.lean`
  - Lines: 140-141 (replace `axiom maximal_consistent_closed` with `theorem maximal_consistent_closed`)

**Estimated Time**: 4-6 hours (including deduction theorem)

---

### Task 5.3: Prove Maximal Negation Complete (2-3 hours)

**Objective**: Replace axiom declaration at line 154 with proof using maximality

**Detailed Proof Strategy**:

```lean
theorem maximal_negation_complete (Γ : Context) (φ : Formula) :
    MaximalConsistent Γ → φ ∉ Γ → Formula.neg φ ∈ Γ := by
  intro ⟨hcons, hmax⟩ hφ
  -- By maximality: φ :: Γ is inconsistent
  have hinconsistent : ¬Consistent (φ :: Γ) := hmax φ hφ
  -- So φ :: Γ ⊢ ⊥
  unfold Consistent at hinconsistent
  push_neg at hinconsistent
  -- Apply deduction theorem: Γ ⊢ φ → ⊥
  have hder_neg : Derivable Γ (φ.imp Formula.bot) :=
    deduction Γ φ Formula.bot hinconsistent
  -- φ → ⊥ is equivalent to ¬φ by definition
  -- (assuming Formula.neg φ := φ.imp Formula.bot)
  -- By closure property (maximal_consistent_closed):
  have hneg_mem : (φ.imp Formula.bot) ∈ Γ :=
    maximal_consistent_closed Γ (φ.imp Formula.bot) ⟨hcons, hmax⟩ hder_neg
  -- If Formula.neg is defined as (φ.imp bot), we're done
  -- Otherwise, need to show equivalence
  convert hneg_mem
  -- Prove Formula.neg φ = φ.imp Formula.bot
  sorry
```

**Note on Negation Definition**: Need to verify how `Formula.neg` is defined in `Logos/Syntax/Formula.lean`. If it's defined as `imp bot`, proof is immediate. Otherwise, need equivalence lemma.

**Testing Strategy**:
```lean
-- LogosTest/Metalogic/CompletenessTest.lean
#test "maximal_negation_complete_simple"
  -- Create maximal consistent set
  let Γ := [Formula.atom "p"]
  let h_cons : Consistent Γ := sorry
  let ⟨Δ, hext, hmax⟩ := lindenbaum Γ h_cons

  -- Pick formula φ not in Δ (e.g., Formula.atom "q" if independent)
  let φ := Formula.atom "q"
  have hφ : φ ∉ Δ := sorry  -- Assume q independent of p

  -- Verify ¬φ ∈ Δ
  have hneg : Formula.neg φ ∈ Δ :=
    maximal_negation_complete Δ φ hmax hφ
  assert hneg

#test "maximal_negation_dichotomy"
  -- For any φ and maximal Δ: exactly one of {φ, ¬φ} is in Δ
  sorry
```

**File Changes**:
- File: `Logos/Metalogic/Completeness.lean`
  - Lines: 154-155 (replace `axiom maximal_negation_complete` with `theorem maximal_negation_complete`)
- File: `Logos/Syntax/Formula.lean` (potential)
  - Verify `Formula.neg` definition (read only, no changes expected)

**Estimated Time**: 2-3 hours

---

### Task 5.4: Write Tests for Maximal Set Properties (2-4 hours)

**Objective**: Comprehensive test coverage for all three proven theorems

**Test Organization**:
```lean
-- LogosTest/Metalogic/CompletenessTest.lean

namespace Logos.Test.Metalogic.Completeness

-- Helper: Create simple consistent contexts
def simple_consistent_contexts : List Context :=
  [ []  -- Empty context
  , [Formula.atom "p"]  -- Single atom
  , [Formula.atom "p", Formula.atom "q"]  -- Two atoms
  , [Formula.box (Formula.atom "p")]  -- Modal formula
  ]

-- Test Group 1: Lindenbaum Lemma
#test "lindenbaum_empty" := ...
#test "lindenbaum_singleton" := ...
#test "lindenbaum_preserves_membership" := ...
#test "lindenbaum_produces_maximal" := ...
#test "lindenbaum_produces_consistent" := ...

-- Test Group 2: Maximal Consistent Closed
#test "closed_by_assumption" := ...
#test "closed_by_modus_ponens" := ...
#test "closed_by_modal_k" := ...
#test "closed_preserves_consistency" := ...

-- Test Group 3: Maximal Negation Complete
#test "negation_complete_simple" := ...
#test "negation_complete_dichotomy" := ...
#test "negation_complete_complex_formulas" := ...

-- Test Group 4: Integration Tests
#test "maximal_has_all_three_properties" := ...
#test "lindenbaum_then_closed_then_negation" := ...

end Logos.Test.Metalogic.Completeness
```

**Detailed Test Specifications**:

1. **Lindenbaum Tests** (1 hour)
```lean
#test "lindenbaum_empty"
  -- Empty context is consistent
  have h : Consistent [] := fun h_bot =>
    nomatch h_bot  -- No derivation of ⊥ from []
  -- Apply lindenbaum
  let ⟨Δ, hext, ⟨hcons, hmax⟩⟩ := lindenbaum [] h
  -- Verify maximality: for any φ, either φ ∈ Δ or ¬Consistent (φ :: Δ)
  -- Verify consistency: ¬(Derivable Δ ⊥)
  assert hcons
  assert hmax
```

2. **Closure Tests** (1 hour)
```lean
#test "closed_by_modus_ponens"
  -- Create maximal set containing p and p → q
  let Γ := [Formula.atom "p",
            Formula.imp (Formula.atom "p") (Formula.atom "q")]
  have h_cons : Consistent Γ := sorry
  let ⟨Δ, hext, hmax⟩ := lindenbaum Γ h_cons

  -- Δ contains p and p → q (by extension)
  have hp : Formula.atom "p" ∈ Δ := hext _ (List.mem_cons_self _ _)
  have himp : Formula.imp (Formula.atom "p") (Formula.atom "q") ∈ Δ :=
    hext _ (List.mem_cons_of_mem _ (List.mem_cons_self _ _))

  -- By modus ponens: Δ ⊢ q
  have hder : Derivable Δ (Formula.atom "q") :=
    Derivable.modus_ponens
      (Derivable.assumption himp)
      (Derivable.assumption hp)

  -- By closure: q ∈ Δ
  have hq : Formula.atom "q" ∈ Δ :=
    maximal_consistent_closed Δ (Formula.atom "q") hmax hder
  assert hq
```

3. **Negation Complete Tests** (1 hour)
```lean
#test "negation_complete_dichotomy"
  -- For maximal set Δ and any formula φ: exactly one of {φ, ¬φ} in Δ
  let Γ := [Formula.atom "p"]
  have h_cons : Consistent Γ := sorry
  let ⟨Δ, hext, hmax⟩ := lindenbaum Γ h_cons

  let φ := Formula.atom "q"  -- Independent of p

  -- Either φ ∈ Δ or φ ∉ Δ (classical logic)
  by_cases h : φ ∈ Δ
  · -- If φ ∈ Δ, then ¬φ ∉ Δ (consistency)
    have : Formula.neg φ ∉ Δ := sorry  -- Prove using consistency
    assert h
    assert this
  · -- If φ ∉ Δ, then ¬φ ∈ Δ (negation completeness)
    have : Formula.neg φ ∈ Δ :=
      maximal_negation_complete Δ φ hmax h
    assert (¬(φ ∈ Δ))
    assert this
```

4. **Integration Tests** (1-2 hours)
```lean
#test "maximal_derivability_equivalence"
  -- For maximal Δ: φ ∈ Δ ↔ Derivable Δ φ
  -- Forward direction: membership implies derivability (by assumption rule)
  -- Backward direction: maximal_consistent_closed
  sorry
```

**File Changes**:
- File: `LogosTest/Metalogic/CompletenessTest.lean`
  - Add ~15-20 test cases (new file or append to existing)
  - Import: `import Logos.Metalogic.Completeness`

**Estimated Time**: 2-4 hours

---

### Task 5.5: Update Documentation (1-2 hours)

**Objective**: Synchronize documentation after Phase 1 completion

**Documentation Updates**:

1. **TODO.md Updates** (30 minutes)
```markdown
## Status Summary (Update Progress Tracking)
- **Overall**: 2/11 tasks complete (18%)  # Was 1/11 (9%)
- **High Priority**: 4/4 tasks complete (100%)  # No change
- **Medium Priority**: 4/4 tasks complete (100%)  # No change
- **Low Priority**: 1/3 tasks started (33%)  # Was 0/3

## Task 9: Complete Completeness Proofs (Wave 3) [IN PROGRESS]  # Was [NOT STARTED]
Status: Phase 1 complete, Phase 2-3 remaining
Estimated: 30-50 hours remaining (70-90 total)

### Phase 1: Lindenbaum and Maximal Sets [COMPLETE]  # Was [NOT STARTED]
Completion Date: [YYYY-MM-DD]
- [x] Prove lindenbaum lemma (Zorn's lemma approach)
- [x] Prove maximal_consistent_closed
- [x] Prove maximal_negation_complete
- [x] Write comprehensive tests
Result: 3 axiom declarations → 3 theorems, 11 axioms → 8 axioms

## Sorry Placeholder Resolution (Update Registry)
Remove these 3 entries:
- ~~Logos/Metalogic/Completeness.lean:116 - lindenbaum axiom~~
- ~~Logos/Metalogic/Completeness.lean:140 - maximal_consistent_closed axiom~~
- ~~Logos/Metalogic/Completeness.lean:154 - maximal_negation_complete axiom~~

Updated count: 22 total (was 22, no new sorry added, 3 axioms converted to theorems)
```

2. **IMPLEMENTATION_STATUS.md Updates** (30 minutes)
```markdown
## Metalogic/Completeness.lean
**Status**: 27% complete (was 0%)
**Sorry Count**: 8 axioms remaining (was 11)
**Last Updated**: YYYY-MM-DD

**Phase 1 (Maximal Sets) - COMPLETE**:
- ✅ `lindenbaum`: Proven using Zorn's lemma from Mathlib.Order.Zorn
- ✅ `maximal_consistent_closed`: Proven using deduction theorem + maximality
- ✅ `maximal_negation_complete`: Proven using closure property

**Phase 2 (Canonical Model) - NOT STARTED**:
- ⬜ `canonical_task_rel`: Axiom (needs definition + frame property proofs)
- ⬜ `canonical_frame`: Axiom (needs nullity + compositionality proofs)
- ⬜ `canonical_valuation`: Axiom (needs definition)
- ⬜ `canonical_model`: Axiom (needs construction)

**Phase 3 (Truth Lemma + Completeness) - NOT STARTED**:
- ⬜ `canonical_history`: Axiom (needs construction + task relation respect)
- ⬜ `truth_lemma`: Axiom (needs mutual induction proof)
- ⬜ `weak_completeness`: Axiom (needs proof using truth lemma)
- ⬜ `strong_completeness`: Axiom (needs proof using weak completeness)

**Dependencies for Remaining Work**:
- Phase 2 requires: Understanding of task relation semantics, frame constraint proofs
- Phase 3 requires: Phase 2 complete, complex mutual induction techniques
```

3. **KNOWN_LIMITATIONS.md Updates** (if applicable) (15 minutes)
```markdown
## Section 2: Metalogic Completeness Gaps (Update Progress)

**UPDATE**: Phase 1 of completeness proofs now complete. Maximal consistent set properties (lindenbaum, closure, negation completeness) are fully proven.

**Remaining Gaps**:
- Canonical model construction (Phase 2: 4 axioms)
- Truth lemma and completeness theorems (Phase 3: 4 axioms)

**Progress**: 3/11 completeness axioms replaced with proofs (27% complete)
```

4. **CONTRIBUTING.md Updates** (if applicable) (15 minutes)
```markdown
## Current Focus Areas (Update)

**Completeness Proofs (Active)**:
- Wave 3 Phase 1: ✅ COMPLETE (lindenbaum, closure, negation completeness)
- Wave 3 Phase 2: ⬜ NOT STARTED (canonical model construction)
- Wave 3 Phase 3: ⬜ NOT STARTED (truth lemma, weak/strong completeness)

Opportunities for contribution:
- Phase 2: Canonical frame construction and frame property proofs
- Phase 3: Truth lemma mutual induction (most complex proof)
```

**Verification Commands**:
```bash
# Verify axiom count decreased
grep -c "axiom" /home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Metalogic/Completeness.lean
# Expected: 8 (was 11)

# Verify documentation consistency
grep "Status.*Complete" /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md | grep -i completeness
# Should show 27% or similar

# Verify TODO.md updated
grep "Task 9.*\[IN PROGRESS\]" /home/benjamin/Documents/Philosophy/Projects/Logos/TODO.md
# Should match
```

**File Changes**:
- File: `TODO.md`
  - Update Task 9 status, Phase 1 checkbox, Sorry Registry
- File: `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
  - Update Completeness.lean section with Phase 1 status
- File: `Documentation/ProjectInfo/KNOWN_LIMITATIONS.md`
  - Update completeness gaps section (if exists)
- File: `Documentation/ProjectInfo/CONTRIBUTING.md`
  - Update current focus areas (if exists)

**Estimated Time**: 1-2 hours

---

## Testing Strategy

### Test Organization

All tests in: `LogosTest/Metalogic/CompletenessTest.lean`

**Test Groups**:
1. Lindenbaum Lemma Tests (5 tests)
2. Maximal Consistent Closed Tests (4 tests)
3. Maximal Negation Complete Tests (3 tests)
4. Integration Tests (3 tests)

**Total**: ~15 test cases

### Test Execution

**After Each Task**:
```bash
cd /home/benjamin/Documents/Philosophy/Projects/Logos

# Build specific module
lake build Logos.Metalogic.Completeness

# Run completeness tests
lake test LogosTest.Metalogic.CompletenessTest

# Verify no sorry in proven theorems
grep -A 20 "theorem lindenbaum" Logos/Metalogic/Completeness.lean | grep -c "sorry"
# Expected: 0

grep -A 10 "theorem maximal_consistent_closed" Logos/Metalogic/Completeness.lean | grep -c "sorry"
# Expected: 0

grep -A 10 "theorem maximal_negation_complete" Logos/Metalogic/Completeness.lean | grep -c "sorry"
# Expected: 0
```

**Phase Completion Verification**:
```bash
# Verify axiom count
echo "Axiom count: $(grep -c '^axiom' Logos/Metalogic/Completeness.lean)"
# Expected: 8

# Verify all tests pass
lake test

# Verify lint clean
lake lint

# Verify build success
lake build
```

### Coverage Requirements

From CLAUDE.md Testing Standards:
- Overall: ≥85%
- Metalogic: ≥90%

**Phase 5 Coverage Target**: 90%+ for Completeness.lean Phase 1 theorems

**Uncovered Code Acceptable**:
- Phase 2 axioms (canonical model construction)
- Phase 3 axioms (truth lemma, completeness theorems)
- Helper lemmas with `sorry` placeholders

## Dependencies

### Internal Dependencies

**Required Before Phase 5**:
- ✅ Phase 1 (Wave 1): Propositional axioms K and S (for deduction theorem)
- ✅ Phase 4 (Wave 2 Completion): Documentation synchronized, Layer 0 High/Medium complete

**Required During Phase 5**:
- Deduction theorem (Task 5.2 prerequisite, 3-4 hours to prove)
- Definition of `Formula.neg` (verify in Syntax/Formula.lean)

### External Dependencies

**Mathlib Dependencies**:
- `Mathlib.Order.Zorn`: Zorn's lemma for lindenbaum
- `Mathlib.Order.Chain`: Chain properties for consistent extensions
- `Mathlib.Data.Set.Basic`: Set operations and subset properties
- `Mathlib.Logic.Relation`: Relation properties for derivability

**LEAN 4 Toolchain**:
- Version: As specified in `lean-toolchain` file
- Lake: Build system for compilation and testing

### Blocking Dependencies for Phase 6

**Phase 6 (Wave 3 Phase 2) Requires**:
- All 3 theorems from Phase 5 proven (lindenbaum, closure, negation complete)
- Maximal set properties available for canonical frame construction
- Deduction theorem available for canonical model proofs

## Risk Mitigation

### Risk 1: Zorn's Lemma Complexity

**Risk**: Applying Zorn's lemma in LEAN 4 may be more complex than estimated

**Probability**: Medium (30%)

**Impact**: +5-8 hours to Task 5.1

**Mitigation**:
- Study Mathlib.Order.Zorn documentation before starting
- Look for LEAN 4 completeness proof examples in Mathlib
- Budget 15 hours for Task 5.1 (upper estimate) instead of 12
- If stuck >4 hours, consult LEAN Zulip chat or documentation

### Risk 2: Deduction Theorem Proof

**Risk**: Deduction theorem for TM logic may require significant case analysis

**Probability**: Medium (40%)

**Impact**: +3-5 hours to Task 5.2

**Mitigation**:
- Review existing deduction theorem proofs in Mathlib for modal/temporal logics
- Consider axiomatizing as meta-theorem if proof intractable (adds 1 axiom but saves time)
- Phased approach: Prove for propositional fragment first, then extend to modal/temporal
- Budget 6 hours for Task 5.2 (upper estimate)

### Risk 3: Negation Definition Mismatch

**Risk**: `Formula.neg` may not be defined as `imp bot`, requiring equivalence proof

**Probability**: Low (20%)

**Impact**: +1-2 hours to Task 5.3

**Mitigation**:
- Check `Logos/Syntax/Formula.lean` definition at start of phase
- If mismatch, prove equivalence lemma: `neg φ ↔ (φ.imp bot)`
- Budget 3 hours for Task 5.3 (upper estimate)

### Risk 4: Test Complexity

**Risk**: Creating maximal consistent sets for testing may be difficult

**Probability**: Low (15%)

**Impact**: +2-3 hours to Task 5.4

**Mitigation**:
- Use lindenbaum to construct maximal sets from simple consistent contexts
- Start with empty context and singleton atom contexts
- Use `sorry` placeholders for consistency proofs in tests if needed
- Budget 4 hours for Task 5.4 (upper estimate)

## Notes

**Phase 5 Position in Wave 3**:
- Wave 3 Phase 1 (this phase): Maximal set properties (3 theorems)
- Wave 3 Phase 2: Canonical model construction (4 axioms → theorems)
- Wave 3 Phase 3: Truth lemma + completeness (4 axioms → theorems)

**Why Phased Approach**:
The completeness proof is complex (70-90 hours total). Breaking into 3 phases:
1. Enables progress tracking and early issue detection
2. Creates natural checkpoints for testing and documentation
3. Reduces cognitive load (focus on one aspect at a time)
4. Allows parallel work on other tasks if blocked

**Key Success Factors**:
1. Study Mathlib Zorn's lemma examples before implementing lindenbaum
2. Prove deduction theorem carefully (required for Tasks 5.2 and 5.3)
3. Write tests incrementally (after each theorem proof)
4. Update documentation immediately after phase completion
5. Verify axiom count decreased before marking phase complete

**Next Phase Preview**:
Phase 6 will construct the canonical model (frame, task relation, valuation) using the maximal set properties proven in this phase. Estimated 20-30 hours, requires deep understanding of task semantics.

## Completion Checklist

Before marking Phase 5 complete, verify:

- [ ] `theorem lindenbaum` proven with zero `sorry` (Completeness.lean:116)
- [ ] `theorem maximal_consistent_closed` proven with zero `sorry` (Completeness.lean:140)
- [ ] `theorem maximal_negation_complete` proven with zero `sorry` (Completeness.lean:154)
- [ ] Deduction theorem proven in `Derivation.lean` (if needed)
- [ ] Axiom count: 8 (decreased from 11)
- [ ] All tests pass: `lake test LogosTest.Metalogic.CompletenessTest`
- [ ] Overall build passes: `lake build`
- [ ] Lint clean: `lake lint` returns zero warnings
- [ ] TODO.md updated: Task 9 Phase 1 marked `[COMPLETE]`, sorry registry updated
- [ ] IMPLEMENTATION_STATUS.md updated: Completeness status 27% or higher
- [ ] KNOWN_LIMITATIONS.md updated: Phase 1 gaps removed
- [ ] Phase completion date recorded in TODO.md
- [ ] Ready to begin Phase 6 (canonical model construction)
