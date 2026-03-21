# Research Report: Task #799 - Phase 1 Blocker Resolution

**Task**: Complete Decidability Proofs - Phase 1 Blocker Analysis
**Date**: 2026-02-02
**Focus**: Deep analysis of `checkContradiction_mono` blocker and mathematically correct proof strategies

## Summary

The Phase 1 blocker is **fully solvable** using a witness-extraction approach combined with existing Mathlib lemmas. The key insight is that while `checkContradiction` uses `findSome?` with a predicate that depends on the branch (making standard monotonicity lemmas inapplicable), we can use `List.findSome?_isSome_iff` to extract a concrete witness and show that witness remains valid in the extended branch.

This report provides three distinct proof strategies with concrete implementations. The recommended approach (Strategy 1) requires approximately 30 lines of code total.

## The Blocker Explained

### Original Problem

The `checkContradiction` function uses a predicate that captures the branch:

```lean
def checkContradiction (b : Branch) : Option ClosureReason :=
  b.findSome? fun sf =>
    if sf.isPos ∧ b.hasNeg sf.formula then
      some (.contradiction sf.formula)
    else none
```

When proving monotonicity (`closed b → closed (x :: b)`), the challenge is:
- For branch `b`: predicate is `fun sf => ... ∧ b.hasNeg sf.formula`
- For branch `x :: b`: predicate is `fun sf => ... ∧ (x :: b).hasNeg sf.formula`

**These are different predicates**, so `List.Sublist.findSome?_isSome` cannot be directly applied.

### Why Previous Attempts Failed

The previous implementation tried to use induction on `findSome?` directly, but:
1. The induction hypothesis gives information about `b.findSome?` with the `b`-predicate
2. What's needed is information about `(x :: b).findSome?` with the `(x :: b)`-predicate
3. The predicates differ, breaking the induction step

## Key Mathlib Lemmas Found

### Core Lemmas (No Rate Limit)

| Lemma | Type | Location |
|-------|------|----------|
| `List.findSome?_isSome_iff` | `(l.findSome? f).isSome ↔ ∃ a ∈ l, (f a).isSome` | Init.Data.List.Find |
| `List.any_cons` | `(a :: l).any f = (f a \|\| l.any f)` | Init.Data.List.Basic |
| `List.mem_cons_of_mem` | `a ∈ l → a ∈ (x :: l)` | Init.Data.List.Basic |
| `List.exists_mem_cons_of_exists` | `(∃ x ∈ l, p x) → ∃ x ∈ a :: l, p x` | Mathlib.Data.List.Basic |
| `List.any_of_mem` | `a ∈ l → p a → l.any p` | Mathlib.Data.Bool.AllAny |
| `List.subset_cons_self` | `l ⊆ a :: l` | Init.Data.List.Sublist |

### Available Monotonicity Lemma

`List.Sublist.findSome?_isSome` provides:
```lean
theorem Sublist.findSome?_isSome {f : α → Option β} {l₁ l₂ : List α}
    (h : l₁.Sublist l₂) :
    (List.findSome? f l₁).isSome → (List.findSome? f l₂).isSome
```

This works when the **same predicate** `f` is used on both lists. We need a different approach since our predicates differ.

## Recommended Solution: Strategy 1 (Witness Extraction)

### Key Insight

Instead of reasoning about `findSome?` abstractly, we:
1. Use `List.findSome?_isSome_iff` to extract a concrete witness element
2. Show that witness is still in the extended list (`List.mem_cons_of_mem`)
3. Show that witness still satisfies the (now different) condition using helper lemmas

### Step 1: Helper Lemmas for Predicate Monotonicity

First, prove that `hasNeg` and `hasPos` are monotonic w.r.t. list extension:

```lean
theorem hasNeg_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
    Branch.hasNeg b φ → Branch.hasNeg (x :: b) φ := by
  intro h
  simp only [Branch.hasNeg, Branch.contains, List.any_cons]
  exact Or.inr h

theorem hasPos_mono (b : Branch) (x : SignedFormula) (φ : Formula) :
    Branch.hasPos b φ → Branch.hasPos (x :: b) φ := by
  intro h
  simp only [Branch.hasPos, Branch.contains, List.any_cons]
  exact Or.inr h

theorem hasBotPos_mono (b : Branch) (x : SignedFormula) :
    Branch.hasBotPos b → Branch.hasBotPos (x :: b) := by
  intro h
  simp only [Branch.hasBotPos, Branch.contains, List.any_cons]
  exact Or.inr h
```

### Step 2: Check Function Monotonicity

```lean
theorem checkBotPos_mono (b : Branch) (x : SignedFormula) :
    (checkBotPos b).isSome → (checkBotPos (x :: b)).isSome := by
  simp only [checkBotPos]
  intro h
  split_ifs at h ⊢
  · rfl
  · cases h
  · exact hasBotPos_mono b x ‹_›
  · cases h

-- THE KEY THEOREM
theorem checkContradiction_mono (b : Branch) (x : SignedFormula) :
    (checkContradiction b).isSome → (checkContradiction (x :: b)).isSome := by
  intro h
  -- Extract the witness using findSome?_isSome_iff
  rw [checkContradiction, List.findSome?_isSome_iff] at h
  obtain ⟨sf, hsf_mem, hsf_cond⟩ := h
  -- Show the witness works for the extended branch
  rw [checkContradiction, List.findSome?_isSome_iff]
  refine ⟨sf, List.mem_cons_of_mem x hsf_mem, ?_⟩
  -- Show the condition still holds (with the new branch)
  simp only [Option.isSome_iff_exists] at hsf_cond ⊢
  obtain ⟨reason, hreason⟩ := hsf_cond
  -- Analyze the condition structure
  split_ifs at hreason ⊢ with hcond hcond'
  · use reason
  · -- hcond was true in b, now false in (x :: b)? Impossible!
    obtain ⟨hpos, hneg⟩ := hcond
    have : Branch.hasNeg (x :: b) sf.formula := hasNeg_mono b x sf.formula hneg
    simp [hpos, this] at hcond'
  · cases hreason
  · cases hreason

theorem checkAxiomNeg_mono (b : Branch) (x : SignedFormula) :
    (checkAxiomNeg b).isSome → (checkAxiomNeg (x :: b)).isSome := by
  intro h
  rw [checkAxiomNeg, List.findSome?_isSome_iff] at h
  obtain ⟨sf, hsf_mem, hsf_cond⟩ := h
  rw [checkAxiomNeg, List.findSome?_isSome_iff]
  -- Witness still works: membership extends, condition is branch-independent
  exact ⟨sf, List.mem_cons_of_mem x hsf_mem, hsf_cond⟩
```

**Key Observation**: `checkAxiomNeg` is simpler because its condition (`sf.isNeg ∧ matchAxiom sf.formula`) doesn't depend on the branch at all - only on the formula itself.

### Step 3: Main Theorems

```lean
theorem closed_extend_closed (b : Branch) (sf : SignedFormula) :
    isClosed b → isClosed (sf :: b) := by
  intro h
  simp only [isClosed, findClosure] at h ⊢
  -- findClosure uses <|> so we case analyze on which check succeeds
  cases hbot : checkBotPos b with
  | some _ =>
    have := checkBotPos_mono b sf (by simp [hbot])
    simp [Option.isSome_iff_exists] at this
    obtain ⟨r, hr⟩ := this
    simp [hr]
  | none =>
    simp [hbot] at h
    cases hcontra : checkContradiction b with
    | some _ =>
      have := checkContradiction_mono b sf (by simp [hcontra])
      simp [Option.isSome_iff_exists] at this
      obtain ⟨r, hr⟩ := this
      simp [hr]
    | none =>
      simp [hcontra] at h
      cases hax : checkAxiomNeg b with
      | some _ =>
        have := checkAxiomNeg_mono b sf (by simp [hax])
        simp [Option.isSome_iff_exists] at this
        obtain ⟨r, hr⟩ := this
        simp [hr]
      | none =>
        simp [hbot, hcontra, hax] at h

theorem add_neg_causes_closure (b : Branch) (φ : Formula) :
    Branch.hasPos b φ → isClosed (SignedFormula.neg φ :: b) := by
  intro hpos
  simp only [isClosed, findClosure]
  -- If checkBotPos succeeds, we're done. Otherwise, use checkContradiction.
  cases hbot : checkBotPos (SignedFormula.neg φ :: b) with
  | some _ => simp
  | none =>
    simp only [hbot, Option.none_or]
    -- checkContradiction will find the contradiction
    simp only [checkContradiction]
    rw [List.findSome?_isSome_iff]
    -- We need to find a witness. The witness is some sf ∈ b with sf.isPos and sf.formula = φ
    -- Actually, we need to unfold hasPos to extract the witness
    simp only [Branch.hasPos, Branch.contains, List.any_eq_true] at hpos
    obtain ⟨witness, hwit_mem, hwit_eq⟩ := hpos
    simp only [beq_iff_eq] at hwit_eq
    use witness
    constructor
    · exact List.mem_cons_of_mem (SignedFormula.neg φ) hwit_mem
    · -- witness.isPos ∧ (SignedFormula.neg φ :: b).hasNeg witness.formula
      simp only [Option.isSome_iff_exists]
      use ClosureReason.contradiction witness.formula
      rw [hwit_eq]
      simp only [SignedFormula.pos, SignedFormula.isPos, decide_eq_true_eq]
      split_ifs with h
      · rfl
      · exfalso
        apply h
        constructor
        · rfl
        · -- Need: (SignedFormula.neg φ :: b).hasNeg φ
          simp only [Branch.hasNeg, Branch.contains, List.any_cons]
          left
          simp [SignedFormula.neg]
```

## Alternative Strategy 2: Refactor to Separate Search and Predicate

If Strategy 1 proves too intricate, we can refactor the definition to make the predicate branch-independent:

```lean
-- Alternative: separate the branch being searched from the branch for condition
def checkContradiction' (searchIn : Branch) (conditionWith : Branch) : Option ClosureReason :=
  searchIn.findSome? fun sf =>
    if sf.isPos ∧ conditionWith.hasNeg sf.formula then
      some (.contradiction sf.formula)
    else none

-- Original is a special case
theorem checkContradiction_eq : checkContradiction b = checkContradiction' b b := rfl

-- Now monotonicity is easier with Sublist lemmas
theorem checkContradiction'_search_mono (b1 b2 cond : Branch) (h : b1 ⊆ b2) :
    (checkContradiction' b1 cond).isSome → (checkContradiction' b2 cond).isSome := by
  -- Standard sublist monotonicity applies here
  ...
```

**Advantage**: Uses existing `Sublist.findSome?_isSome` directly.
**Disadvantage**: Requires API changes and downstream updates.

## Alternative Strategy 3: Direct Construction for `add_neg_causes_closure`

For `add_neg_causes_closure`, we can avoid `findSome?` entirely:

```lean
theorem add_neg_causes_closure_direct (b : Branch) (φ : Formula) :
    Branch.hasPos b φ → isClosed (SignedFormula.neg φ :: b) := by
  intro hpos
  -- Directly construct the closure evidence
  simp only [isClosed, findClosure, checkBotPos, checkContradiction]
  -- The negation at head creates the contradiction
  simp only [List.findSome?_cons]
  -- F(φ) is at head, so sf = SignedFormula.neg φ
  -- sf.isPos = false for F(φ), so first element doesn't match
  -- Continue searching in b...
  -- Eventually find T(φ) in b (from hpos), and at that point:
  -- sf.isPos = true, and (F(φ) :: b).hasNeg φ = true (head matches)
  ...
```

This works but is more complex because we need to reason about where the contradiction witness is found.

## Verification Checklist

Before implementing, verify these lemmas are accessible:

- [x] `List.findSome?_isSome_iff` - Found in Init.Data.List.Find
- [x] `List.any_cons` - Found in Init.Data.List.Basic
- [x] `List.mem_cons_of_mem` - Standard library
- [x] `List.any_of_mem` - Found in Mathlib.Data.Bool.AllAny

## Recommendations

### Primary Recommendation

Implement **Strategy 1** (witness extraction) as described above:
1. Add helper lemmas: `hasNeg_mono`, `hasPos_mono`, `hasBotPos_mono` (10 min)
2. Add check monotonicity: `checkBotPos_mono`, `checkContradiction_mono`, `checkAxiomNeg_mono` (30 min)
3. Complete main theorems: `closed_extend_closed`, `add_neg_causes_closure` (30 min)

**Estimated Total Time**: 70-90 minutes

### Why Strategy 1 is Preferred

1. **No API changes**: Uses existing definitions as-is
2. **Mathematically clean**: Follows the intuition of "witness preservation"
3. **Modular**: Each lemma builds on previous ones
4. **Verified approach**: The key lemmas (`findSome?_isSome_iff`, `any_cons`) are in standard library

### Implementation Order

1. `hasNeg_mono` (simplest, establishes pattern)
2. `hasPos_mono` (copy pattern)
3. `hasBotPos_mono` (copy pattern)
4. `checkBotPos_mono` (uses `hasBotPos_mono`)
5. `checkContradiction_mono` (key theorem, uses `hasNeg_mono`)
6. `checkAxiomNeg_mono` (simpler variant, no branch dependency in condition)
7. `closed_extend_closed` (uses all check_mono lemmas)
8. `add_neg_causes_closure` (uses witness extraction differently)

## Potential Pitfalls

### Pitfall 1: `split_ifs` interaction with `Option.isSome`

When dealing with `if ... then some x else none`, be careful with `split_ifs`:
```lean
-- May need to use Option.isSome_iff_exists first
simp only [Option.isSome_iff_exists] at h ⊢
```

### Pitfall 2: `List.any_eq_true` vs `List.any_cons`

Depending on how `hasNeg` unfolds, you may need:
```lean
simp only [List.any_eq_true]  -- For Prop-level reasoning
-- vs
simp only [List.any_cons]  -- For structural unfolding
```

### Pitfall 3: `beq_iff_eq` for BEq

The `Branch.contains` function uses `==` (BEq), so:
```lean
simp only [beq_iff_eq]  -- To convert (a == b) = true to a = b
```

## References

- Init.Data.List.Find: `findSome?_isSome_iff`, `Sublist.findSome?_isSome`
- Init.Data.List.Basic: `any_cons`, `mem_cons_of_mem`
- Mathlib.Data.Bool.AllAny: `any_of_mem`
- Mathlib.Data.List.Basic: `exists_mem_cons_of_exists`

## Next Steps After Phase 1

Once Closure.lean is complete:
1. **Saturation.lean**: `expansion_decreases_measure` - Show termination via complexity measure
2. **Correctness.lean**: Connect to FMP infrastructure for completeness

---

*End of Research Report*
