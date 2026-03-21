# Research Report: Decidability Proofs (Task 799)

**Session**: sess_1769991147_20e4b3
**Date**: 2026-02-02
**Status**: Complete

## Executive Summary

This report analyzes 6 sorries in the Decidability module, categorizing them into three types:

1. **Closure.lean (2 sorries)**: List monotonicity lemmas for `findSome?`
2. **Saturation.lean (1 sorry)**: Termination measure decreases lemma
3. **Correctness.lean (3 sorries)**: Completeness-related theorems requiring FMP

The Closure.lean sorries are straightforward list lemmas. The Saturation.lean sorry requires showing expansion decreases a complexity measure. The Correctness.lean sorries are more substantial, requiring the finite model property (FMP) infrastructure that already exists in `Theories/Bimodal/Metalogic/FMP/`.

## Detailed Analysis

### 1. Closure.lean - Sorry #1: `closed_extend_closed`

**Location**: Line 175-185

**Theorem**:
```lean
theorem closed_extend_closed (b : Branch) (sf : SignedFormula) :
    isClosed b → isClosed (sf :: b)
```

**Goal State** (inferred from code context):
The proof needs to show that if `findClosure b = some reason` for some `reason`, then `findClosure (sf :: b) = some reason'` for some `reason'`.

**Proof Strategy**:
The key insight is that `findClosure` uses `checkBotPos`, `checkContradiction`, and `checkAxiomNeg`, all of which use `List.findSome?` or `List.any`. The closure reason from `b` remains present in `sf :: b` because `b` is a suffix.

**Required Lemmas from Mathlib**:
- `List.findSome?_cons` - For unfolding `findSome?` on cons
- `List.any_cons` - For unfolding `any` on cons

**Proof Sketch**:
```lean
theorem closed_extend_closed (b : Branch) (sf : SignedFormula) :
    isClosed b → isClosed (sf :: b) := by
  intro h
  simp only [isClosed] at *
  cases hb : findClosure b with
  | none => simp [hb] at h
  | some reason =>
    -- Show findClosure (sf :: b) finds something
    simp only [findClosure, checkBotPos, checkContradiction, checkAxiomNeg]
    -- Case analysis on what caused closure
    simp only [findClosure, checkBotPos] at hb
    -- For hasBotPos: if b.hasBotPos then (sf :: b).hasBotPos
    -- For checkContradiction: if b.findSome? f = some x then (sf :: b).findSome? f = some x or finds earlier
    -- The key is that adding sf can only add more chances to find closure, not remove them
    sorry -- Detailed case analysis on each closure type
```

**Estimated Difficulty**: Medium - requires careful case analysis on closure reasons

---

### 2. Closure.lean - Sorry #2: `add_neg_causes_closure`

**Location**: Line 190-195

**Theorem**:
```lean
theorem add_neg_causes_closure (b : Branch) (φ : Formula) :
    b.hasPos φ → isClosed (SignedFormula.neg φ :: b)
```

**Goal State** (inferred from code context):
Need to show that adding `F(φ)` to a branch containing `T(φ)` causes closure via the contradiction check.

**Proof Strategy**:
The proof should show that `checkContradiction (SignedFormula.neg φ :: b)` returns `some (.contradiction φ)`.

**Required Definitions**:
- `Branch.hasPos` - checks if positive formula is in branch
- `Branch.hasNeg` - checks if negative formula is in branch
- `checkContradiction` - uses `findSome?` to find contradictions

**Proof Sketch**:
```lean
theorem add_neg_causes_closure (b : Branch) (φ : Formula) :
    b.hasPos φ → isClosed (SignedFormula.neg φ :: b) := by
  intro hpos
  simp only [isClosed, findClosure, checkBotPos, checkContradiction]
  -- Need to show findSome? finds the contradiction
  simp only [List.findSome?_cons]
  -- The first element is SignedFormula.neg φ, which is negative
  -- So we check if sf.isPos ∧ b.hasNeg sf.formula
  -- sf = SignedFormula.neg φ, so sf.isPos = false
  -- So the first element doesn't match, continue to rest of list
  -- Eventually we find SignedFormula.pos φ in b (from hpos)
  -- At that point, sf.isPos = true and we need (sf :: b).hasNeg φ
  -- But SignedFormula.neg φ is at the head, so hasNeg holds
  sorry -- Unfold definitions and show contradiction is found
```

**Estimated Difficulty**: Easy-Medium - straightforward unfolding

---

### 3. Saturation.lean - Sorry #1: `expansion_decreases_measure`

**Location**: Line 217-221

**Theorem**:
```lean
theorem expansion_decreases_measure (b : Branch) (h : ¬isSaturated b) :
    ∀ b', (expandOnce b = .extended b' ∨
           ∃ bs, expandOnce b = .split bs ∧ b' ∈ bs) →
    expansionMeasure b' < expansionMeasure b
```

**Goal State** (inferred from code context):
Need to show that after applying a tableau rule, the sum of unexpanded complexities decreases.

**Proof Strategy**:
The key is that each tableau rule decomposes a formula into strictly smaller subformulas. The `expansionMeasure` sums `sf.formula.complexity` for unexpanded formulas. When a rule is applied:
1. The principal formula is removed (or marked expanded)
2. New formulas are added, each with strictly smaller complexity
3. The total measure decreases because complexity of principal > sum of complexities of conclusions

**Required Lemmas**:
- `Formula.complexity` definitions for each constructor
- Properties of `isExpanded` after rule application
- List sum/fold lemmas

**Proof Sketch**:
```lean
theorem expansion_decreases_measure (b : Branch) (h : ¬isSaturated b) :
    ∀ b', (expandOnce b = .extended b' ∨
           ∃ bs, expandOnce b = .split bs ∧ b' ∈ bs) →
    expansionMeasure b' < expansionMeasure b := by
  intro b' hexp
  -- From h: findUnexpanded b = some sf for some unexpanded sf
  -- From hexp: a rule was applied to sf, producing b'
  -- The principal formula sf has complexity c
  -- The conclusions have complexity < c (each subformula is strictly smaller)
  -- After expansion: sf is removed, conclusions added
  -- expansionMeasure b' = expansionMeasure b - c + (sum of conclusion complexities) < expansionMeasure b
  sorry -- Detailed case analysis on which rule was applied
```

**Estimated Difficulty**: Hard - requires case analysis on all tableau rules and showing complexity decreases

**Note**: This is the key termination lemma. Consider using `omega` or `simp_arith` for the arithmetic.

---

### 4. Correctness.lean - Sorry #1: `tableau_complete`

**Location**: Line 74-77

**Theorem**:
```lean
theorem tableau_complete (φ : Formula) :
    (⊨ φ) → ∃ (fuel : Nat), (buildTableau φ fuel).isSome ∧
             ∀ t, buildTableau φ fuel = some t → t.isValid
```

**Goal State**:
Need to show that valid formulas have closing tableaux with sufficient fuel.

**Proof Strategy**:
This requires the finite model property (FMP). The proof goes:
1. If φ is valid, its negation ¬φ is unsatisfiable
2. By FMP, if ¬φ were satisfiable, it would be satisfiable in a finite model
3. The tableau procedure terminates on finite inputs
4. Since ¬φ is unsatisfiable, all branches close

**Required Theorems from FMP Module**:
```lean
-- From Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean
theorem finite_model_property (phi : Formula) :
    formula_satisfiable phi -> exists (D : Type) ... truth_at M tau t phi

-- From Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi), ...) -> |- phi
```

**Proof Sketch**:
```lean
theorem tableau_complete (φ : Formula) :
    (⊨ φ) → ∃ (fuel : Nat), (buildTableau φ fuel).isSome ∧
             ∀ t, buildTableau φ fuel = some t → t.isValid := by
  intro hvalid
  -- By FMP, the tableau search space is finite
  -- Set fuel = 2^(closureSize φ) * k for some constant k
  use 2^(closureSize φ) * 10 + 100  -- Generous upper bound
  constructor
  · -- Show buildTableau returns some
    -- This follows from termination of tableau on finite closure
    sorry
  · -- Show result is valid (all branches closed)
    intro t ht
    -- If not valid, there's an open saturated branch
    -- This would give a countermodel to φ
    -- Contradiction with hvalid
    sorry
```

**Estimated Difficulty**: Very Hard - requires connecting FMP infrastructure to tableau procedure

---

### 5. Correctness.lean - Sorry #2: `decide_complete`

**Location**: Line 86-88

**Theorem**:
```lean
theorem decide_complete (φ : Formula) (hvalid : ⊨ φ) :
    ∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof
```

**Goal State**:
Need to show that the decision procedure returns a valid proof for valid formulas.

**Proof Strategy**:
This builds on `tableau_complete`. The proof goes:
1. By `tableau_complete`, the tableau closes with sufficient fuel
2. When the tableau closes, `decide` either finds an axiom proof or uses proof search
3. Valid formulas are provable (by completeness)
4. Therefore, `decide` returns `.valid proof`

**Required Theorems**:
- `tableau_complete` (sorry #4 above)
- `semantic_weak_completeness` from FMP module
- `bounded_search_with_proof` behavior on provable formulas

**Proof Sketch**:
```lean
theorem decide_complete (φ : Formula) (hvalid : ⊨ φ) :
    ∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof := by
  -- From tableau_complete, we get a fuel value and closed tableau
  obtain ⟨fuel, hsome, hvalid_t⟩ := tableau_complete φ hvalid
  -- Use this fuel value
  use fuel
  -- Unfold decide and analyze cases
  simp only [decide]
  -- Case 1: tryAxiomProof succeeds
  -- Case 2: bounded_search_with_proof succeeds
  -- Case 3: tableau closes and we extract proof
  -- The key is that semantic_weak_completeness gives us ⊢ φ
  -- So one of the proof extraction methods must succeed
  sorry
```

**Estimated Difficulty**: Very Hard - depends on `tableau_complete` and proof extraction

---

### 6. Correctness.lean - Sorry #3: `decide_axiom_valid`

**Location**: Line 168-172

**Theorem**:
```lean
theorem decide_axiom_valid (φ : Formula) (ax : Axiom φ) :
    ∃ proof, decide φ = .valid proof
```

**Goal State**:
Need to show that axiom instances are decided as valid.

**Proof Strategy**:
The `decide` function first checks `tryAxiomProof φ`. For axiom instances, `matchAxiom` should succeed.

**Required Definitions**:
- `tryAxiomProof` - attempts to build axiom proof directly
- `matchAxiom` - pattern matches axiom schemas

**Proof Sketch**:
```lean
theorem decide_axiom_valid (φ : Formula) (ax : Axiom φ) :
    ∃ proof, decide φ = .valid proof := by
  use DerivationTree.axiom [] φ ax
  simp only [decide]
  -- First case: tryAxiomProof
  -- Need to show tryAxiomProof φ = some (DerivationTree.axiom [] φ ax)
  -- This requires showing matchAxiom φ = some ⟨φ, ax⟩
  -- Which should follow from the definition of matchAxiom
  sorry
```

**Estimated Difficulty**: Medium - requires understanding `matchAxiom` behavior

---

## Summary Table

| File | Line | Theorem | Difficulty | Dependencies |
|------|------|---------|------------|--------------|
| Closure.lean | 175 | `closed_extend_closed` | Medium | List lemmas |
| Closure.lean | 190 | `add_neg_causes_closure` | Easy-Medium | List lemmas |
| Saturation.lean | 217 | `expansion_decreases_measure` | Hard | Complexity lemmas |
| Correctness.lean | 74 | `tableau_complete` | Very Hard | FMP module |
| Correctness.lean | 86 | `decide_complete` | Very Hard | `tableau_complete` |
| Correctness.lean | 168 | `decide_axiom_valid` | Medium | `matchAxiom` |

## Recommended Implementation Order

1. **Start with Closure.lean sorries** - These are self-contained list lemmas
2. **Then Saturation.lean** - The termination lemma
3. **Then `decide_axiom_valid`** - Medium difficulty, tests `matchAxiom`
4. **Finally completeness theorems** - These are substantial and may require refactoring to properly integrate FMP

## Key Mathlib Lemmas Found

### For List Operations
- `List.findSome?_cons` - Unfolds `findSome?` on cons
- `List.findSome?_nil` - Base case for `findSome?`
- `List.any_cons` - Unfolds `any` on cons

### For Natural Number Arithmetic
- `Nat.sum_cons` - Sum of cons list
- `Nat.sum_append` - Sum distributes over append
- `Nat.add_lt_add_right` - For showing sum decreases

## Notes on FMP Integration

The FMP infrastructure is complete in `Theories/Bimodal/Metalogic/FMP/`:
- `semantic_weak_completeness` provides: valid -> provable
- `finite_model_property` provides: satisfiable -> finite model
- `closureSize` provides the cardinality bound

The Correctness.lean sorries need to bridge from the tableau procedure to this FMP infrastructure. This may require:
1. Showing tableau branches correspond to closure-maximal sets
2. Connecting `buildTableau` fuel to `closureSize` bounds
3. Using contrapositive: if tableau doesn't close, we get an open branch = countermodel

---

*End of Research Report*
