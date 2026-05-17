# Expressive Completeness of {S,U} over Integer Time: Full Pseudo-Lean Proof Map

## Executive Summary

This report provides a complete, rigorous pseudo-Lean specification of the proof that {Since, Until} is expressively complete over integer time. The proof follows GHR94 Chapter 10.2 (syntactic separation) combined with Theorem 9.3.1 (separation implies expressive completeness). The formalization decomposes into two major modules:

1. **Separation Module** (~1800 LOC): Prove every {U,S}-formula is equivalent to a separated formula over integer time.
2. **Expressive Completeness Module** (~700 LOC): Prove separation implies expressive completeness (Theorem 9.3.1).

Total estimated: ~2500 lines of Lean.

---

## 1. Existing Infrastructure (Reusable)

### 1.1 Formula Syntax (`Theories/Bimodal/Syntax/Formula.lean`)

```lean
-- Already defined:
inductive Formula : Type where
  | atom : Atom → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | all_past : Formula → Formula
  | all_future : Formula → Formula
  | untl : Formula → Formula → Formula  -- U(event, guard)
  | snce : Formula → Formula → Formula  -- S(event, guard)

-- Derived operators already available:
def neg (φ : Formula) : Formula := φ.imp bot
def and (φ ψ : Formula) : Formula := (φ.imp ψ.neg).neg
def or (φ ψ : Formula) : Formula := φ.neg.imp ψ
def some_past (φ : Formula) : Formula := φ.neg.all_past.neg   -- P
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg -- F
```

### 1.2 Monadic FO (`Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean`)

```lean
-- Already defined:
inductive MonadicFormula (sig : MonadicSignature) : Nat → Type where
  | atom | lt | not | and | all | ex
def eval : OrderedMonadicStructure sig → (Fin n → carrier) → MonadicFormula sig n → Prop
def MonadicFormula.quantifier_depth : MonadicFormula sig n → Nat
```

### 1.3 Table Translation (`Theories/Bimodal/Metalogic/WeakCanonical/Table.lean`)

```lean
-- Already proved:
def table (sig : MonadicSignature) (atomMap : Formula → sig.preds) (φ : Formula) : MonadicFormula sig 1
theorem table_correctness : eval M env (table sig atomMap φ) ↔ temporal_truth M atomMap t φ
theorem table_depth_bound : (table sig atomMap φ).quantifier_depth ≤ operator_depth φ
```

### 1.4 Temporal Truth (`Theories/Bimodal/Metalogic/WeakCanonical/Table.lean`)

```lean
-- Already defined:
def temporal_truth (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier) : Formula → Prop
-- Semantics on OrderedMonadicStructure matching the task frame semantics
```

### 1.5 Semantics on TaskFrame (`Theories/Bimodal/Semantics/Truth.lean`)

```lean
-- Already defined:
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
-- With Until: ∃ s, t < s ∧ truth_at ... s φ ∧ ∀ r, t < r → r < s → truth_at ... r ψ
-- With Since: ∃ s, s < t ∧ truth_at ... s φ ∧ ∀ r, s < r → r < t → truth_at ... r ψ
```

---

## 2. New Definitions Required

### 2.1 Integer Temporal Semantics (Simplified)

For the separation proof, we work on a simpler semantic domain -- a temporal structure over the integers directly (no modal component, no task frame). This aligns with GHR94's setup.

```lean
-- File: Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-- A temporal structure over integers: just a valuation mapping atoms to sets of ℤ. -/
structure IntStructure where
  val : Atom → Set ℤ

/-- Truth of a formula at time t in an integer temporal structure.
    Note: box is treated as always-false (no modal component in this context).
    This matches GHR94's "linear temporal structure" (T, <, h). -/
def int_truth (M : IntStructure) (t : ℤ) : Formula → Prop
  | .atom a => t ∈ M.val a
  | .bot => False
  | .imp φ ψ => int_truth M t φ → int_truth M t ψ
  | .box _ => True  -- degenerate: modal not relevant for separation
  | .all_past φ => ∀ s : ℤ, s < t → int_truth M s φ
  | .all_future φ => ∀ s : ℤ, t < s → int_truth M s φ
  | .untl φ ψ => ∃ s : ℤ, t < s ∧ int_truth M s φ ∧
      ∀ r : ℤ, t < r → r < s → int_truth M r ψ
  | .snce φ ψ => ∃ s : ℤ, s < t ∧ int_truth M s φ ∧
      ∀ r : ℤ, s < r → r < t → int_truth M r ψ

/-- Semantic equivalence of formulas over integer time. -/
def int_equiv (φ ψ : Formula) : Prop :=
  ∀ (M : IntStructure) (t : ℤ), int_truth M t φ ↔ int_truth M t ψ
```

### 2.2 Purity Predicates

```lean
/-- A formula is "pure past" if its truth at t depends only on the past of t. -/
def is_pure_past (φ : Formula) : Prop :=
  ∀ (M₁ M₂ : IntStructure) (t : ℤ),
    (∀ (a : Atom) (s : ℤ), s < t → (s ∈ M₁.val a ↔ s ∈ M₂.val a)) →
    (int_truth M₁ t φ ↔ int_truth M₂ t φ)

/-- A formula is "pure future" if its truth at t depends only on the future of t. -/
def is_pure_future (φ : Formula) : Prop :=
  ∀ (M₁ M₂ : IntStructure) (t : ℤ),
    (∀ (a : Atom) (s : ℤ), t < s → (s ∈ M₁.val a ↔ s ∈ M₂.val a)) →
    (int_truth M₁ t φ ↔ int_truth M₂ t φ)

/-- A formula is "pure present" if its truth at t depends only on time t. -/
def is_pure_present (φ : Formula) : Prop :=
  ∀ (M₁ M₂ : IntStructure) (t : ℤ),
    (∀ (a : Atom), (t ∈ M₁.val a ↔ t ∈ M₂.val a)) →
    (int_truth M₁ t φ ↔ int_truth M₂ t φ)
```

### 2.3 Syntactic Separation Predicate

```lean
/-- A formula is "syntactically U-free": contains no `untl` constructor. -/
def is_U_free : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_U_free φ && is_U_free ψ
  | .box φ => is_U_free φ
  | .all_past φ => is_U_free φ
  | .all_future φ => is_U_free φ
  | .untl _ _ => false
  | .snce φ ψ => is_U_free φ && is_U_free ψ

/-- A formula is "syntactically S-free": contains no `snce` constructor. -/
def is_S_free : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_S_free φ && is_S_free ψ
  | .box φ => is_S_free φ
  | .all_past φ => is_S_free φ
  | .all_future φ => is_S_free φ
  | .untl φ ψ => is_S_free φ && is_S_free ψ
  | .snce _ _ => false

/-- A formula is "syntactically separated" if it is a boolean combination of:
    - atoms (pure present)
    - U-formulas with S-free arguments (pure future)
    - S-formulas with U-free arguments (pure past)
    
    We define this recursively. A formula is separated if:
    - It is an atom or bot
    - It is imp φ ψ with both separated
    - It is all_future φ with S-free φ (hence pure future)
    - It is all_past φ with U-free φ (hence pure past)
    - It is untl φ ψ with both S-free (hence pure future)
    - It is snce φ ψ with both U-free (hence pure past)
    - It is box φ (treated as atomic/present) -/
def is_syntactically_separated : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => is_syntactically_separated φ && is_syntactically_separated ψ
  | .box _ => true  -- box treated as atomic
  | .all_past φ => is_U_free φ
  | .all_future φ => is_S_free φ
  | .untl φ ψ => is_S_free φ && is_S_free ψ
  | .snce φ ψ => is_U_free φ && is_U_free ψ

/-- A formula is "separable" if it is integer-equivalent to a syntactically separated formula. -/
def is_separable (φ : Formula) : Prop :=
  ∃ ψ : Formula, is_syntactically_separated ψ = true ∧ int_equiv φ ψ
```

### 2.4 Structural Measures for Induction

```lean
/-- Junction depth of a formula: maximum alternation depth of U/S nesting.
    This is the key induction measure for Lemma 10.2.8. -/
def junction_depth : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => max (junction_depth φ) (junction_depth ψ)
  | .box φ => junction_depth φ
  | .all_past φ => junction_depth φ
  | .all_future φ => junction_depth φ
  | .untl φ ψ => max (junction_depth_U φ) (junction_depth_U ψ)
  | .snce φ ψ => max (junction_depth_S φ) (junction_depth_S ψ)
where
  /-- Junction depth relative to an outer U context. -/
  junction_depth_U : Formula → Nat
    | .atom _ => 0
    | .bot => 0
    | .imp φ ψ => max (junction_depth_U φ) (junction_depth_U ψ)
    | .box φ => junction_depth_U φ
    | .all_past φ => junction_depth_U φ
    | .all_future φ => junction_depth_U φ
    | .untl φ ψ => max (junction_depth_U φ) (junction_depth_U ψ)
    | .snce φ ψ => 1 + max (junction_depth φ) (junction_depth ψ) -- alternation!
  /-- Junction depth relative to an outer S context. -/
  junction_depth_S : Formula → Nat
    | .atom _ => 0
    | .bot => 0
    | .imp φ ψ => max (junction_depth_S φ) (junction_depth_S ψ)
    | .box φ => junction_depth_S φ
    | .all_past φ => junction_depth_S φ
    | .all_future φ => junction_depth_S φ
    | .untl φ ψ => 1 + max (junction_depth φ) (junction_depth ψ) -- alternation!
    | .snce φ ψ => max (junction_depth_S φ) (junction_depth_S ψ)

/-- U-nesting depth beneath S: maximum depth of U under S (with no intervening S). -/
def U_depth_under_S : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => max (U_depth_under_S φ) (U_depth_under_S ψ)
  | .box φ => U_depth_under_S φ
  | .all_past φ => U_depth_under_S φ
  | .all_future φ => U_depth_under_S φ
  | .untl φ ψ => 1 + max (U_depth_under_S φ) (U_depth_under_S ψ)
  | .snce _ _ => 0  -- S resets the counter

/-- S-nesting depth above a specific U occurrence. -/
def S_nesting_above_U (φ : Formula) : Nat := sorry -- defined per specific U(A,B) occurrence

/-- Count of distinct maximal U-subformulas in a formula (whose arguments are S/U-free). -/
def count_U_subformulas (φ : Formula) : Nat := sorry -- counts distinct U(Ai,Bi) patterns
```

---

## 3. Literature Proof Structure

### Source: GHR94 Chapter 10.2 + Chapter 9.3

**Strategy**: Two-stage proof:
- **Stage A** (Separation, Lemmas 10.2.1-10.2.8, Theorem 10.2.9): Every {U,S}-formula over integer time is equivalent to a syntactically separated formula. Proof by nested induction.
- **Stage B** (Expressive Completeness, Theorem 9.3.1 + 10.2.10): Separation implies expressive completeness. Proof by induction on quantifier depth of monadic FO formulas.

### Step Map

| Step | GHR94 Ref | Description | Lean Statement |
|------|-----------|-------------|----------------|
| 1 | Lemma 10.2.1 | Distributivity of U/S over boolean ops | `elim_distrib_*` |
| 2 | Lemma 10.2.2 | Negation of U/S over integers | `neg_until_equiv`, `neg_since_equiv` |
| 3 | Lemma 10.2.3 | Eight elimination cases | `elim_case_1` through `elim_case_8` |
| 4 | Lemma 10.2.4 | Single S(C,F) with top-level U(A,B) | `single_S_with_U_separable` |
| 5 | Lemma 10.2.5 | Single U-formula, induction on S-depth | `single_U_separable` |
| 6 | Lemma 10.2.6 | Multiple U-formulas, induction on count | `multi_U_separable` |
| 7 | Lemma 10.2.7 | No S-within-U, induction on U-depth | `no_S_within_U_separable` |
| 8 | Lemma 10.2.8 | General case, junction depth induction | `junction_depth_separable` |
| 9 | Thm 10.2.9 | Separation theorem | `separation_theorem_int` |
| 10 | Thm 9.3.1 | Separation -> Expressive completeness | `separation_implies_expressiveness` |
| 11 | Thm 10.2.10 | {U,S} expressively complete over Z | `expressive_completeness_int` |

### Dependencies

```
Step 3 depends on Steps 1, 2
Step 4 depends on Step 3
Step 5 depends on Step 4
Step 6 depends on Step 5
Step 7 depends on Step 6
Step 8 depends on Step 7
Step 9 depends on Step 8
Step 10 depends on Chapter 9 infrastructure (independent of Steps 1-9)
Step 11 depends on Steps 9 and 10
```

---

## 4. Complete Pseudo-Lean: Stage A (Separation)

### 4.1 Lemma 10.2.1: Distributivity Laws

```lean
-- File: Theories/Bimodal/Metalogic/WeakCanonical/Separation/Distributivity.lean

/-- U distributes over disjunction in first argument (valid over all linear time). -/
theorem until_distrib_or_left (A B C : Formula) :
    int_equiv (.untl (.or A B) C) (.or (.untl A C) (.untl B C)) := by
  intro M t
  constructor
  · rintro ⟨s, hts, hAB, hguard⟩
    cases hAB with  -- A ∨ B at s
    | inl hA => exact Or.inl ⟨s, hts, hA, hguard⟩
    | inr hB => exact Or.inr ⟨s, hts, hB, hguard⟩
  · rintro (⟨s, hts, hA, hg⟩ | ⟨s, hts, hB, hg⟩)
    · exact ⟨s, hts, Or.inl hA, hg⟩
    · exact ⟨s, hts, Or.inr hB, hg⟩

/-- S distributes over disjunction in first argument (valid over all linear time). -/
theorem since_distrib_or_left (A B C : Formula) :
    int_equiv (.snce (.or A B) C) (.or (.snce A C) (.snce B C)) := by
  -- Symmetric to until_distrib_or_left with s < t
  sorry

/-- U distributes over conjunction in second argument (valid over all linear time). -/
theorem until_distrib_and_right (A B C : Formula) :
    int_equiv (.untl A (.and B C)) (.and (.untl A B) (.untl A C)) := by
  intro M t
  constructor
  · rintro ⟨s, hts, hA, hBC⟩
    exact ⟨⟨s, hts, hA, fun r hr1 hr2 => (hBC r hr1 hr2).1⟩,
           ⟨s, hts, hA, fun r hr1 hr2 => (hBC r hr1 hr2).2⟩⟩
  · rintro ⟨⟨s₁, hts₁, hA₁, hB⟩, ⟨s₂, hts₂, hA₂, hC⟩⟩
    -- Take s = min s₁ s₂ -- need linearity argument
    sorry

/-- S distributes over conjunction in second argument (valid over all linear time). -/
theorem since_distrib_and_right (A B C : Formula) :
    int_equiv (.snce A (.and B C)) (.and (.snce A B) (.snce A C)) := by
  sorry
```

### 4.2 Lemma 10.2.2: Negation of U/S over Integers

```lean
-- File: Theories/Bimodal/Metalogic/WeakCanonical/Separation/NegationEquiv.lean

/-- ¬U(A,B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A) over integer time.
    
    KEY: uses discreteness of ℤ. The proof:
    - (→): If ¬U(A,B) at t, then either A never holds in the future (G(¬A)),
      or there exists a first point where the guard B fails (before any A).
      At that first failure point, ¬A ∧ ¬B holds, with ¬A holding between t and it.
      In integer time, "first failure" exists by well-ordering of ℕ.
    - (←): If G(¬A) then clearly ¬U(A,B). If U(¬A ∧ ¬B, ¬A), then at the
      witness s we have ¬A ∧ ¬B, and ¬A holds between t and s, so U(A,B) fails. -/
theorem neg_until_equiv (A B : Formula) :
    int_equiv (.neg (.untl A B))
      (.or (.all_future (.neg A)) (.untl (.and (.neg A) (.neg B)) (.neg A))) := by
  intro M t
  constructor
  · intro h_not_until
    -- h_not_until : ¬(∃ s > t, A(s) ∧ ∀ r ∈ (t,s), B(r))
    -- Either ∀ s > t, ¬A(s) [= G(¬A)], or
    -- ∃ s > t, ¬A(s) and we find first failure of B
    by_cases hGA : ∀ s : ℤ, t < s → ¬int_truth M s A
    · exact Or.inl hGA
    · push_neg at hGA
      obtain ⟨s₀, hts₀, hAs₀⟩ := hGA
      -- There exists some future point with A. Since ¬U(A,B),
      -- B must fail somewhere between t and the first such point.
      -- Use well-ordering on {n : ℕ | ...} to find first failure.
      -- Key: in ℤ, intervals (t, s₀) are finite, so minimum exists.
      sorry
  · rintro (hGA | ⟨s, hts, ⟨hnAs, hnBs⟩, hguard⟩)
    · -- G(¬A) implies ¬U(A,B)
      intro ⟨s, hts, hAs, _⟩
      exact hGA s hts hAs
    · -- U(¬A ∧ ¬B, ¬A): at s, ¬A ∧ ¬B; between t and s, ¬A
      intro ⟨s', hts', hAs', hBguard⟩
      -- s' > t with A(s'). Since ¬A on (t,s) and ¬A at s, need s' > s.
      -- But at s, ¬B, and ¬A between t and s, so B fails at or before s.
      -- We get s < s' and ¬B(s), contradicting the guard of U(A,B) at s.
      sorry

/-- ¬S(A,B) ↔ H(¬A) ∨ S(¬A ∧ ¬B, ¬A) over integer time.
    Dual of neg_until_equiv. -/
theorem neg_since_equiv (A B : Formula) :
    int_equiv (.neg (.snce A B))
      (.or (.all_past (.neg A)) (.snce (.and (.neg A) (.neg B)) (.neg A))) := by
  sorry -- dual of neg_until_equiv

/-- Alternative negation: ¬U(A,B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, B ∧ ¬A) over integers.
    (Second form from GHR94 Lemma 10.2.2) -/
theorem neg_until_equiv' (A B : Formula) :
    int_equiv (.neg (.untl A B))
      (.or (.all_future (.neg A)) (.untl (.and (.neg A) (.neg B)) (.and B (.neg A)))) := by
  sorry
```

### 4.3 Lemma 10.2.3: The Eight Elimination Cases

This is the core of the proof. Each case eliminates a nested U from under an S.

```lean
-- File: Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean

/-- CASE 1: S(a ∧ U(A,B), q) where a, q, A, B are atoms.
    
    Equivalent to:
      [S(a, q) ∧ S(a, B) ∧ B ∧ U(A,B)]     -- U-witness after t
      ∨ [A ∧ S(a, B) ∧ S(a, q)]              -- U-witness AT t  
      ∨ S(A ∧ q ∧ S(a, B) ∧ S(a, q), q)     -- U-witness before t
    
    The three disjuncts correspond to the U(A,B)-witness being:
    - u > t (future): Then B holds from s to u, covering (s,t); plus B at t; plus U(A,B) at t.
    - u = t (present): A at t; B held from s to t.
    - u < t (past): A was true at some u ∈ (s,t); B held from s to u.
      Rewrite using S. -/
theorem elim_case_1 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    int_equiv
      (.snce (.and a (.untl A B)) q)
      (.or (.or
        (.and (.and (.snce a q) (.snce a B)) (.and B (.untl A B)))
        (.and (.and A (.snce a B)) (.snce a q)))
        (.snce (.and (.and (.and A q) (.snce a B)) (.snce a q)) q)) := by
  intro M t
  constructor
  · -- (→) Given S(a ∧ U(A,B), q) at t:
    -- ∃ s < t with a(s) ∧ U(A,B)(s) ∧ ∀ r ∈ (s,t), q(r)
    -- U(A,B)(s) gives ∃ u > s with A(u) ∧ ∀ w ∈ (s,u), B(w)
    -- Case split on u vs t: u > t, u = t, or s < u < t
    rintro ⟨s, hst, ⟨ha_s, ⟨u, hsu, hAu, hBguard⟩⟩, hq_guard⟩
    rcases lt_trichotomy u t with hu_lt | hu_eq | hu_gt
    · -- Case u < t: witness in the past
      right
      exact ⟨u, hu_lt,
        ⟨hAu, hq_guard u (by linarith) hu_lt, ⟨s, hst, ha_s, fun r hrs hru => hBguard r hrs hru⟩,
         ⟨s, hst, ha_s, hq_guard⟩⟩,
        fun r hru hrt => hq_guard r (by linarith) hrt⟩
    · -- Case u = t: witness at present
      left; right
      subst hu_eq
      exact ⟨hAu, ⟨s, hst, ha_s, fun r hrs hrt => hBguard r hrs hrt⟩,
             ⟨s, hst, ha_s, hq_guard⟩⟩
    · -- Case u > t: witness in the future
      left; left
      exact ⟨⟨s, hst, ha_s, hq_guard⟩,
             ⟨s, hst, ha_s, fun r hrs hrt => hBguard r hrs (by linarith)⟩,
             hBguard t (by linarith) hu_gt,
             ⟨u, hu_gt, hAu, fun r htr hru => hBguard r (by linarith) hru⟩⟩
  · -- (←) Each disjunct implies S(a ∧ U(A,B), q)
    sorry

/-- CASE 2: S(a ∧ ¬U(A,B), q).
    Strategy: Use neg_until_equiv to rewrite ¬U(A,B), then reduce to Case 1
    and simpler sub-cases.
    
    Equivalent to:
      [S(a, q ∧ ¬A) ∧ ¬A ∧ ¬U(A,B)]
      ∨ [¬A ∧ ¬B ∧ S(a, ¬A ∧ q)]
      ∨ S(¬A ∧ ¬B ∧ q ∧ S(a, ¬A ∧ q), q) -/
theorem elim_case_2 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    int_equiv
      (.snce (.and a (.neg (.untl A B))) q)
      (.or (.or
        (.and (.snce a (.and q (.neg A))) (.and (.neg A) (.neg (.untl A B))))
        (.and (.and (.neg A) (.neg B)) (.snce a (.and (.neg A) q))))
        (.snce (.and (.and (.and (.neg A) (.neg B)) q) (.snce a (.and (.neg A) q))) q)) := by
  sorry

/-- CASE 3: S(a, q ∨ U(A,B)).
    Strategy: Negate and use Case 2 on the negation (via Lemma 10.2.2).
    
    Equivalent to:
      ¬( H(¬a)
         ∨ [S(¬a ∧ ¬q, ¬a ∧ ¬A) ∧ ¬A ∧ (¬U(A,B) ∨ ¬B)]
         ∨ S(¬A ∧ ¬B ∧ ¬a ∧ S(¬a ∧ ¬q, ¬A ∧ ¬a), ¬a) ) -/
theorem elim_case_3 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ ψ : Formula, int_equiv (.snce a (.or q (.untl A B))) ψ ∧
      -- ψ has U(A,B) only at top level, not under any S
      sorry := by
  sorry

/-- CASE 4: S(a, q ∨ ¬U(A,B)).
    Strategy: Direct semantic argument.
    
    Equivalent to:
      S(a, ¬a ∧ [S(¬q ∧ ¬a, ¬a ∧ B) ⇒ ¬A])
      ∧ (S(¬q ∧ ¬a, ¬a ∧ B) ⇒ ¬[A ∨ (B ∧ U(A,B))]) -/
theorem elim_case_4 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ ψ : Formula, int_equiv (.snce a (.or q (.neg (.untl A B)))) ψ ∧
      sorry := by
  sorry

/-- CASE 5: S(a ∧ U(A,B), q ∨ U(A,B)).
    Strategy: Split on whether A is true in the future or past of t.
    
    Equivalent to:
      S(a, B) ∧ [A ∨ (B ∧ U(A,B))]
      ∨ S(A ∧ S(a, B), A ∨ B ∨ ¬S(¬q, ¬A))
        ∧ [A ∨ (B ∧ U(A,B))] ∧ ¬S(¬q, ¬A) -/
theorem elim_case_5 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ ψ : Formula, int_equiv (.snce (.and a (.untl A B)) (.or q (.untl A B))) ψ ∧
      sorry := by
  sorry

/-- CASE 6: S(a ∧ ¬U(A,B), q ∨ U(A,B)).
    Strategy: Consider the first occurrence of ¬B after s. Reduces to Cases 3, 5.
    
    Equivalent to:
      [S(a, q ∧ ¬A) ∧ ¬A ∧ ¬(B ∧ U(A,B))]
      ∨ S(¬B ∧ ¬A ∧ (q ∨ U(A,B)) ∧ S(a, q ∧ ¬A), q ∨ U(A,B)) -/
theorem elim_case_6 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ ψ : Formula, int_equiv (.snce (.and a (.neg (.untl A B))) (.or q (.untl A B))) ψ ∧
      sorry := by
  sorry

/-- CASE 7: S(a ∧ U(A,B), q ∨ ¬U(A,B)).
    Strategy: Consider when A is true. Reduces to Cases 4, 8.
    
    Equivalent to:
      [S(A ∧ (q ∨ ¬U(A,B)) ∧ S(a, B ∧ q), q ∨ ¬U(A,B))]
      ∨ [S(a, B ∧ q) ∧ A]
      ∨ [S(a, B ∧ q) ∧ B ∧ U(A,B)] -/
theorem elim_case_7 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ ψ : Formula, int_equiv (.snce (.and a (.untl A B)) (.or q (.neg (.untl A B)))) ψ ∧
      sorry := by
  sorry

/-- CASE 8: S(a ∧ ¬U(A,B), q ∨ ¬U(A,B)).
    Strategy: Negate and reduce to Case 5 via:
      ¬S(a ∧ z, q ∨ y) ↔ H(¬a ∨ ¬z)
                         ∨ S(¬q ∧ ¬y ∧ ¬a, ¬a ∨ ¬z)
                         ∨ S(¬q ∧ ¬y ∧ ¬z, ¬a ∨ ¬z)
    With y = z = ¬U(A,B), this becomes cases involving S(..., ... ∨ U(A,B)). -/
theorem elim_case_8 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ ψ : Formula, int_equiv (.snce (.and a (.neg (.untl A B))) (.or q (.neg (.untl A B)))) ψ ∧
      sorry := by
  sorry
```

### 4.4 Lemma 10.2.4: Single S with Top-Level U(A,B)

```lean
-- File: Theories/Bimodal/Metalogic/WeakCanonical/Separation/SingleSWithU.lean

/-- Lemma 10.2.4: If U only appears as the formula U(A,B) in S(C,F), where
    A,B are S/U-free and each appearance of U(A,B) in C,F is NOT under any S,
    then S(C,F) is equivalent to a separated formula where U only appears
    as the formula U(A,B) at top level.
    
    Proof strategy:
    1. Put C in DNF, F in CNF (using boolean equivalences)
    2. Use distributivity (Lemma 10.2.1) to reduce S(C,F) to a boolean
       combination of S(C_i, F_j) where each C_i is a conjunction of
       literals (atoms or ±U(A,B)) and F_j is a disjunction.
    3. Each resulting S(C_i, F_j) falls into one of the 8 elimination cases.
    4. Apply the appropriate elimination from Lemma 10.2.3. -/
theorem single_S_with_U (A B C F : Formula)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true)
    -- C and F have U appearing only as U(A,B), not under any S
    (hC : u_appearances_top_level_only C A B)
    (hF : u_appearances_top_level_only F A B) :
    ∃ ψ : Formula,
      int_equiv (.snce C F) ψ ∧
      u_appears_only_as_top_level ψ A B ∧
      is_syntactically_separated ψ = true := by
  sorry
```

### 4.5 Lemma 10.2.5: Single U-Formula

```lean
/-- Lemma 10.2.5: If A, B are built without S or U, and the only appearance
    of U in D is as U(A,B), then D is separable.
    
    Proof: Induction on k = max number of nested S's above any U(A,B).
    - k = 0: D is already separated (U(A,B) is at top level).
    - k > 0: Apply Lemma 10.2.4 to the most deeply nested S(C,F)
      containing U(A,B), reducing the nesting depth by 1. -/
theorem single_U_separable (A B D : Formula)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true)
    (hD : u_appears_only_as D A B) :  -- only U in D is as U(A,B)
    ∃ ψ : Formula,
      int_equiv D ψ ∧
      is_syntactically_separated ψ = true ∧
      u_appears_only_as_top_level ψ A B := by
  -- Induction on S_nesting_above_U D
  sorry
```

### 4.6 Lemma 10.2.6: Multiple U-Formulas

```lean
/-- Lemma 10.2.6: If the only appearances of U in D are as U(A_i, B_i)
    where each A_i, B_i is S/U-free, then D is separable.
    
    Proof: Induction on n = number of distinct U-subformulas.
    - n = 1: Lemma 10.2.5.
    - n > 1: Focus on U(A_n, B_n). Replace other U(A_i, B_i) by fresh
      atoms q_i to get D'. Apply Lemma 10.2.5 to D'. In the result,
      resubstitute U(A_i, B_i) for q_i. The pure-past parts now contain
      fewer than n U-formulas; apply induction hypothesis. -/
theorem multi_U_separable (D : Formula)
    (Us : List (Formula × Formula))  -- list of (A_i, B_i) pairs
    (hUs : ∀ (p : Formula × Formula), p ∈ Us →
      is_U_free p.1 = true ∧ is_U_free p.2 = true ∧
      is_S_free p.1 = true ∧ is_S_free p.2 = true)
    (hD : all_U_in_D_are_from_Us D Us) :
    is_separable D := by
  -- Induction on Us.length
  induction Us.length with
  | zero => sorry -- no U at all, already separated
  | succ n ih => sorry -- focus on last U, substitute others, apply single_U_separable
```

### 4.7 Lemma 10.2.7: No S-within-U

```lean
/-- Lemma 10.2.7: If D contains no S nested within a U, then D is separable.
    
    Proof: Induction on n = max depth of U-nesting beneath an S.
    - n = 0: No U under any S at all. D is already separated.
    - n = 1: The U-subformulas under S have S/U-free arguments. Lemma 10.2.6.
    - n > 1: Let U(A_i, B_i) be maximal U-subformulas of D. Each A_i, B_i
      is a boolean combination of atoms and U(X_ij, Y_ij). Replace each
      U(X_ij, Y_ij) in A_i, B_i by fresh atoms z_ij to get A'_i, B'_i.
      Replace U(A_i, B_i) in D by U(A'_i, B'_i) to get D'. D' has U-depth 1
      under S, so Lemma 10.2.6 separates it. Resubstitute U(X_ij, Y_ij)
      for z_ij. The former pure-past parts now have U-depth < n; use IH. -/
theorem no_S_within_U_separable (D : Formula)
    (hD : no_S_nested_in_U D) :
    is_separable D := by
  -- Induction on U_depth_under_S D
  sorry
```

### 4.8 Lemma 10.2.8: General Case (Junction Depth)

```lean
/-- Lemma 10.2.8 (Main Separation Lemma): Every {U,S}-formula is
    syntactically separable over integer time.
    
    Proof: Induction on junction_depth D.
    - Junction depth 0 or 1: No alternation of U/S nesting. Already separated.
    - Junction depth >= 2: D is a boolean combination of atoms, S(D1,D2), U(D1,D2).
      WLOG consider S(D1, D2) (duality handles U(D1,D2)).
      
      Let U(A_i, B_i) be the maximal U-subformulas. Each may contain S-subformulas
      S(E,F) inside. Replace each maximal S(E,F) inside U(A_i, B_i) by fresh
      atoms z_ij to get U(A'_i, B'_i). Change S(D1,D2) to E' by replacing
      U(A_i, B_i) by U(A'_i, B'_i). Now E' has NO S within U (the S's have been
      replaced by atoms). Apply Lemma 10.2.7 to separate E'.
      
      Resubstitute the original S-formulas for z_ij. The result is equivalent
      to S(D1, D2) but has junction depth decreased by at least 1.
      Apply induction hypothesis. -/
theorem junction_depth_separable (D : Formula) :
    is_separable D := by
  -- Well-founded induction on junction_depth D
  sorry
```

### 4.9 Theorem 10.2.9: Separation Theorem

```lean
/-- Theorem 10.2.9 (Separation Theorem): Each wff in the language with
    {U, S} is equivalent, over the integer flow of time, to a separated wff.
    
    This follows directly from junction_depth_separable because syntactic
    separation implies semantic separation. -/
theorem separation_theorem_int (φ : Formula) :
    is_separable φ :=
  junction_depth_separable φ
```

---

## 5. Complete Pseudo-Lean: Stage B (Expressive Completeness)

### 5.1 Statement of Expressive Completeness

```lean
-- File: Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean

/-- Expressive completeness: for every monadic FO formula ψ(t, Q_1,...,Q_n) with
    one free variable t and quantifier depth m, there exists a temporal formula
    A in {U,S} such that for all integer structures M and all t:
    
    M |= ψ(t, P_1,...,P_n) ↔ int_truth M t A
    
    where the P_i are the interpretations of atoms q_i in M. -/
def expressively_complete_at_depth (m : Nat) : Prop :=
  ∀ (sig : MonadicSignature) (ψ : MonadicFormula sig 1),
    ψ.quantifier_depth ≤ m →
    ∃ (A : Formula) (atomMap : sig.preds → Atom),
      ∀ (M_struct : IntStructureFromSig sig atomMap) (t : ℤ),
        eval_int_sig sig M_struct t ψ ↔ int_truth (to_int_struct M_struct) t A

/-- The main expressive completeness theorem. -/
theorem expressive_completeness_int :
    ∀ (sig : MonadicSignature) (ψ : MonadicFormula sig 1),
      ∃ (A : Formula) (atomMap : sig.preds → Atom),
        ∀ (M_struct : IntStructureFromSig sig atomMap) (t : ℤ),
          eval_int_sig sig M_struct t ψ ↔ int_truth (to_int_struct M_struct) t A := by
  sorry
```

### 5.2 Theorem 9.3.1: Separation Implies Expressive Completeness

```lean
/-- Theorem 9.3.1 (GHR94): If {U,S} has the separation property over ℤ
    and P, F are definable (which they are: P(A) = S(A,⊤), F(A) = U(A,⊤)),
    then {U,S} is expressively complete over ℤ.
    
    Proof by induction on quantifier depth m of the FO formula ψ.
    
    Base case (m = 0): Quantifier-free ψ(t). Replace t=t by ⊤, t<t by ⊥,
    Q_i(t) by atom q_i. Done.
    
    Inductive case (m > 0): Reduce to ∃z ψ(t,z) with ψ of depth ≤ m.
    
    1. Introduce predicates R_=(y) = (t=y), R_>(y) = (t<y), R_<(y) = (y<t).
    2. Rewrite ψ as ψ'(z, Q, R_=, R_>, R_<) not mentioning t explicitly.
    3. By IH, find temporal A_j for each depth-m sub-case ψ_j.
    4. Form B using Q_∃ (= P ∨ id ∨ F) to express ∃z.
    5. B contains extra atoms r_=, r_>, r_<. Use SEPARATION to decompose B
       into a boolean combination of pure past, pure future, pure present parts.
    6. Substitute: in pure past parts, r_> = ⊤, r_= = ⊥, r_< = ⊥;
       in pure future parts, r_> = ⊥, r_= = ⊥, r_< = ⊤;
       in pure present parts, r_> = ⊥, r_= = ⊤, r_< = ⊥.
    7. The resulting B* no longer mentions r_=, r_>, r_<, and is the temporal
       equivalent of ψ. -/
theorem separation_implies_expressiveness :
    (∀ φ : Formula, is_separable φ) →
    ∀ (sig : MonadicSignature) (ψ : MonadicFormula sig 1),
      ∃ A : Formula, ∀ (M : IntStructureFromSig sig) (t : ℤ),
        eval_Z_sig sig M t ψ ↔ int_truth (to_int_struct M) t A := by
  intro h_sep
  -- Induction on ψ.quantifier_depth
  sorry
```

### 5.3 Theorem 10.2.10: Final Result

```lean
/-- Theorem 10.2.10 (GHR94): The language {U, S} is expressively complete
    over integer time.
    
    Combines the Separation Theorem (10.2.9) with Theorem 9.3.1. -/
theorem US_expressively_complete_over_Z :
    ∀ (sig : MonadicSignature) (ψ : MonadicFormula sig 1),
      ∃ A : Formula, ∀ (M : IntStructureFromSig sig) (t : ℤ),
        eval_Z_sig sig M t ψ ↔ int_truth (to_int_struct M) t A :=
  separation_implies_expressiveness (fun φ => separation_theorem_int φ)
```

---

## 6. Supporting Infrastructure Required

### 6.1 Formula Substitution and Normal Forms

```lean
-- File: Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean

/-- Substitute a formula for an atom in a formula. -/
def Formula.subst (φ : Formula) (target : Atom) (replacement : Formula) : Formula :=
  match φ with
  | .atom a => if a = target then replacement else .atom a
  | .bot => .bot
  | .imp ψ₁ ψ₂ => .imp (ψ₁.subst target replacement) (ψ₂.subst target replacement)
  | .box ψ => .box (ψ.subst target replacement)
  | .all_past ψ => .all_past (ψ.subst target replacement)
  | .all_future ψ => .all_future (ψ.subst target replacement)
  | .untl ψ₁ ψ₂ => .untl (ψ₁.subst target replacement) (ψ₂.subst target replacement)
  | .snce ψ₁ ψ₂ => .snce (ψ₁.subst target replacement) (ψ₂.subst target replacement)

/-- Substitution preserves truth when the atom is interpreted as the replacement. -/
theorem subst_correctness (φ : Formula) (target : Atom) (replacement : Formula)
    (M : IntStructure) (t : ℤ) :
    int_truth M t (φ.subst target replacement) ↔
    int_truth (M.with target (fun s => int_truth M s replacement)) t φ := by
  sorry

/-- Put a formula in Disjunctive Normal Form (as a list of conjunctive clauses). -/
def to_DNF (φ : Formula) : List (List Formula) := sorry

/-- Put a formula in Conjunctive Normal Form. -/
def to_CNF (φ : Formula) : List (List Formula) := sorry

/-- DNF/CNF preserve equivalence. -/
theorem dnf_equiv (φ : Formula) : int_equiv φ (from_DNF (to_DNF φ)) := sorry
theorem cnf_equiv (φ : Formula) : int_equiv φ (from_CNF (to_CNF φ)) := sorry
```

### 6.2 Freshness Infrastructure

```lean
/-- Generate a fresh atom not appearing in a formula. -/
def fresh_atom (φ : Formula) : Atom :=
  Atom.mk_fresh (φ.atoms.toList.map Atom.base)

/-- Fresh atom does not appear in the formula. -/
theorem fresh_atom_not_in (φ : Formula) : fresh_atom φ ∉ φ.atoms := by
  sorry

/-- Generate n fresh atoms not appearing in a formula. -/
def fresh_atoms (φ : Formula) (n : Nat) : List Atom := sorry
```

### 6.3 Integer-Specific Helpers

```lean
/-- In ℤ, every bounded interval (t, s) with t < s is finite and non-empty. -/
theorem Int.Ioo_finite (t s : ℤ) (h : t < s) :
    Set.Finite (Set.Ioo t s) := by
  sorry -- follows from Int being discrete

/-- In ℤ, every non-empty finite subset of ℤ bounded below has a minimum. -/
theorem Int.exists_min_of_bdd_below_finite (S : Set ℤ) (hne : S.Nonempty)
    (hfin : S.Finite) : ∃ m ∈ S, ∀ x ∈ S, m ≤ x := by
  sorry

/-- Key property for Case 1: In ℤ with t < s, if f holds at s and 
    B holds on (t,s), then U(f, B) holds at t. -/
theorem until_witness_construction (M : IntStructure) (t s : ℤ) (hts : t < s)
    (f B : Formula) (hf : int_truth M s f)
    (hB : ∀ r : ℤ, t < r → r < s → int_truth M r B) :
    int_truth M t (.untl f B) :=
  ⟨s, hts, hf, hB⟩

/-- In ℤ, S(a, ⊤) ↔ P(a). -/
theorem since_top_is_past (a : Formula) :
    int_equiv (.snce a (.imp .bot .bot)) (.some_past a) := by
  sorry

/-- In ℤ, U(a, ⊤) ↔ F(a). -/
theorem until_top_is_future (a : Formula) :
    int_equiv (.untl a (.imp .bot .bot)) (.some_future a) := by
  sorry
```

### 6.4 FO Infrastructure for Theorem 9.3.1

```lean
-- File: Theories/Bimodal/Metalogic/WeakCanonical/Separation/FOToTemporal.lean

/-- An integer structure with a monadic signature: interprets predicates on ℤ. -/
structure IntStructureFromSig (sig : MonadicSignature) where
  interp : sig.preds → ℤ → Prop

/-- Evaluate a MonadicFormula with 1 free variable on an integer monadic structure. -/
def eval_Z_sig (sig : MonadicSignature) (M : IntStructureFromSig sig)
    (t : ℤ) (ψ : MonadicFormula sig 1) : Prop :=
  eval (int_to_ordered_monadic M) (fun _ => t) ψ
  where
    int_to_ordered_monadic (M : IntStructureFromSig sig) : OrderedMonadicStructure sig :=
      { carrier := ℤ, interp := M.interp, carrier_order := inferInstance }

/-- Convert IntStructureFromSig to IntStructure given an atom map. -/
def to_int_struct {sig : MonadicSignature} (M : IntStructureFromSig sig)
    (atomMap : sig.preds → Atom) : IntStructure where
  val a := {t : ℤ | ∃ p : sig.preds, atomMap p = a ∧ M.interp p t}

/-- The Q_∃ connective: "exists sometime" = P(A) ∨ A ∨ F(A). -/
def q_exists (A : Formula) : Formula :=
  .or (.or (.some_past A) A) (.some_future A)

/-- Q_∃ correctly captures existential quantification over ℤ. -/
theorem q_exists_correct (A : Formula) (M : IntStructure) (t : ℤ) :
    int_truth M t (q_exists A) ↔ ∃ s : ℤ, int_truth M s A := by
  sorry

/-- Pure past formula has truth independent of future and present interpretation. -/
theorem pure_past_substitution (φ : Formula) (h : is_pure_past φ)
    (M : IntStructure) (t : ℤ) (M' : IntStructure)
    (hagree : ∀ a s, s < t → (s ∈ M.val a ↔ s ∈ M'.val a)) :
    int_truth M t φ ↔ int_truth M' t φ :=
  h M M' t hagree

/-- Pure future formula has truth independent of past and present interpretation. -/
theorem pure_future_substitution (φ : Formula) (h : is_pure_future φ)
    (M : IntStructure) (t : ℤ) (M' : IntStructure)
    (hagree : ∀ a s, t < s → (s ∈ M.val a ↔ s ∈ M'.val a)) :
    int_truth M t φ ↔ int_truth M' t φ :=
  h M M' t hagree
```

---

## 7. Induction Structure Summary

The proof uses a 4-level nested induction. Here is the complete diagram:

```
THEOREM 10.2.9 (separation_theorem_int)
│
└── LEMMA 10.2.8 (junction_depth_separable)
    │   Induction on: junction_depth D
    │   Base: junction_depth ≤ 1 → already separated
    │   Step: Replace S-under-U by atoms, apply 10.2.7, resubstitute, use IH
    │
    └── LEMMA 10.2.7 (no_S_within_U_separable)
        │   Induction on: max depth of U-nesting beneath S
        │   Base: depth 1 → use 10.2.6
        │   Step: Replace sub-U's by atoms, apply 10.2.6, resubstitute, use IH
        │
        └── LEMMA 10.2.6 (multi_U_separable)
            │   Induction on: number n of distinct U(A_i, B_i)
            │   Base: n = 1 → use 10.2.5
            │   Step: Focus on U(A_n, B_n), replace others, apply 10.2.5,
            │         resubstitute, separate pure-past parts via IH
            │
            └── LEMMA 10.2.5 (single_U_separable)
                │   Induction on: k = max S-nesting above U(A,B)
                │   Base: k = 0 → already separated
                │   Step: Apply 10.2.4 to deepest S, reduce k by 1
                │
                └── LEMMA 10.2.4 (single_S_with_U)
                    │   Uses: DNF/CNF + distributivity (10.2.1) to reduce to 8 cases
                    │
                    └── LEMMA 10.2.3 (eight elimination cases)
                        │   Uses: Lemma 10.2.1 (distributivity)
                        │         Lemma 10.2.2 (negation of U/S over ℤ)
                        │         Semantic reasoning about integer time
                        └── (base cases: direct semantic equivalences)
```

Then:

```
THEOREM 10.2.10 (US_expressively_complete_over_Z)
│
├── THEOREM 10.2.9 (separation_theorem_int)
│
└── THEOREM 9.3.1 (separation_implies_expressiveness)
        Induction on: quantifier depth m of FO formula
        Base: m = 0 → quantifier-free, trivial translation
        Step: m > 0 → introduce R_=, R_>, R_<; use IH; use SEPARATION to
              eliminate R-atoms from the temporal formula
```

---

## 8. File Organization Plan

```
Theories/Bimodal/Metalogic/WeakCanonical/
├── Separation/
│   ├── Defs.lean              -- IntStructure, int_truth, purity, separation predicates (~150 LOC)
│   ├── FormulaOps.lean        -- Substitution, DNF/CNF, freshness (~200 LOC)
│   ├── IntHelpers.lean        -- Integer-specific lemmas (finite intervals, min) (~100 LOC)
│   ├── Distributivity.lean    -- Lemma 10.2.1: U/S distribute over ∨/∧ (~200 LOC)
│   ├── NegationEquiv.lean     -- Lemma 10.2.2: ¬U/¬S equivalences over ℤ (~200 LOC)
│   ├── Eliminations.lean      -- Lemma 10.2.3: 8 elimination cases (~800 LOC)
│   ├── SingleSWithU.lean      -- Lemma 10.2.4: Single S with top-level U (~150 LOC)
│   ├── SingleU.lean           -- Lemma 10.2.5: Single U formula (~100 LOC)
│   ├── MultiU.lean            -- Lemma 10.2.6: Multiple U formulas (~100 LOC)
│   ├── NoSWithinU.lean        -- Lemma 10.2.7: No S within U (~100 LOC)
│   ├── JunctionDepth.lean     -- Lemma 10.2.8: Junction depth induction (~150 LOC)
│   └── SeparationThm.lean     -- Theorem 10.2.9: Main separation result (~20 LOC)
├── ExpressiveCompleteness.lean -- Theorem 9.3.1 + 10.2.10 (~700 LOC)
└── Separation.lean            -- Module imports (hub file)
```

Total: ~2570 lines estimated.

---

## 9. Key Technical Challenges

### 9.1 The Eight Eliminations (Highest Difficulty)

Each of the 8 cases in Lemma 10.2.3 requires:
1. Stating the exact equivalence (which RHS formula is equivalent to the LHS)
2. Proving (→): semantic argument, typically case-splitting on where the U-witness is
3. Proving (←): verifying each disjunct implies the original

The main difficulty is **Case 1** and **Case 5**, which are proved by direct semantic reasoning about the location of the U-witness relative to the current time. Cases 2, 3, 6, 7, 8 reduce to earlier cases.

**Mitigation**: Cases 2-8 can often be reduced to combinations of Case 1 plus Lemma 10.2.2. The pattern is:
- Case 2: Use 10.2.2 on ¬U, reduce to Case 1
- Case 3: Negate, use 10.2.2, apply Case 2
- Case 4: Direct semantic, simpler than Case 1
- Case 5: Direct semantic, split on past/future witness
- Case 6: Reduce to Cases 3, 5
- Case 7: Reduce to Cases 4, 8
- Case 8: Negate, reduce to Case 5

### 9.2 Termination for the Inductive Steps

Each induction level uses a natural number measure that strictly decreases:
- 10.2.8: `junction_depth` decreases by 1 per step
- 10.2.7: `U_depth_under_S` decreases by 1 per step
- 10.2.6: `count_U_subformulas` decreases by 1 per step
- 10.2.5: `S_nesting_above_U` decreases by 1 per step

In Lean 4, these translate to `Nat.rec` or `WellFoundedRelation` proofs. The key challenge is showing that the transformations actually decrease the measure -- this requires careful tracking of how substitution/elimination affects formula structure.

### 9.3 DNF/CNF and Distributivity Reduction

Lemma 10.2.4 requires reducing S(C, F) where C, F may be complex boolean combinations into the 8 canonical forms. This requires:
1. Converting C to DNF
2. Converting F to CNF
3. Using S distributivity to split into multiple S-formulas
4. Each resulting S-formula matches one of the 8 patterns

This is mechanically involved but conceptually straightforward.

### 9.4 Theorem 9.3.1 (Separation → Expressiveness)

The main challenges here:
1. Formalizing the "introduce R_=, R_>, R_<" step at the FO level
2. The decomposition of ∃z ψ(t,z) into cases where z < t, z = t, z > t
3. The substitution step where pure past/future/present parts get different valuations for R
4. Tracking that the resulting formula A* is actually in {U,S} (no extra atoms)

This requires working with `MonadicFormula sig n` and extending it to handle the R-predicates. The existing `MonadicFO.lean` infrastructure provides the foundation.

---

## 10. What Can Be Reused from Existing Infrastructure

| Existing Component | Reuse For |
|---|---|
| `Formula` inductive type | All definitions and theorems |
| `Formula.atoms` | Freshness generation |
| `Formula.complexity` | Termination arguments |
| `Formula.subformulas` | Subformula tracking |
| `MonadicFormula sig n` | Theorem 9.3.1 FO reasoning |
| `eval` | Semantics for Theorem 9.3.1 |
| `temporal_truth` | Connecting separation to the existing pipeline |
| `table_correctness` | Bridge between FO and temporal for the final theorem |
| `Atom.mk_fresh` / freshness infrastructure | Fresh atom generation for substitution steps |

---

## 11. Connection to Task 155 / Reynolds Pipeline

### 11.1 How This Fits

The expressive completeness theorem (Theorem 10.2.10 = Reynolds' Theorem 5) is the prerequisite for Reynolds' Theorem 14 (gap elimination). The dependency chain is:

```
Theorem 5 (Expressive Completeness of {U,S} for Prior structures)
    ↓
Lemmas 6-14 (Gap Elimination Chain)
    ↓
Theorem 14 (No gaps in ~M classes)
    ↓
Theorem 15 (one_class without IsSuccArchimedean)
    ↓
Theorem 18 (Weak Completeness over ℤ)
```

Currently, `one_class` in `IntegerModel.lean` bypasses this chain for the discrete case by using the simpler argument that discrete orders have no gaps at all. The expressive completeness result would be needed if:
1. We remove the `IsSuccArchimedean` hypothesis (requiring the full Reynolds argument)
2. We extend to dense/Dedekind-complete flows of time

### 11.2 Statement Connecting to Existing Code

```lean
/-- Bridge theorem: Expressive completeness applied to the Reynolds pipeline.
    For any monadic FO formula ψ(x) with one free variable, there exists a
    temporal formula A such that for all Prior structures (T, <, h) satisfying
    the Prior-UZ and Prior-SZ axioms:
    
    (T, <, h) |= ψ(t) iff (T, <, h) |= A(t)
    
    This is Reynolds' Theorem 5, specialized to Prior structures. -/
theorem reynolds_theorem_5 (sig : MonadicSignature) (ψ : MonadicFormula sig 1) :
    ∃ A : Formula, ∀ (M : PriorStructure sig) (t : M.carrier),
      eval_prior sig M t ψ ↔ temporal_truth_prior M t A := by
  -- Follows from US_expressively_complete_over_Z
  -- Since Prior structures have integer-like flows (by prior axioms),
  -- and {U,S} is expressively complete over ℤ, the result transfers.
  sorry
```

---

## 12. Estimated Effort Breakdown

| Component | LOC | Difficulty | Weeks |
|-----------|-----|------------|-------|
| Defs + FormulaOps + IntHelpers | 450 | Medium | 0.5 |
| Distributivity (10.2.1) | 200 | Medium | 0.3 |
| Negation Equiv (10.2.2) | 200 | Medium-High | 0.4 |
| Eight Eliminations (10.2.3) | 800 | HIGH | 1.5 |
| Single S/U (10.2.4-10.2.5) | 250 | Medium | 0.4 |
| Multi U + No S in U (10.2.6-10.2.7) | 200 | Medium | 0.3 |
| Junction Depth (10.2.8) + Thm 10.2.9 | 170 | Medium | 0.2 |
| Expressive Completeness (9.3.1 + 10.2.10) | 700 | HIGH | 1.0 |
| **TOTAL** | **~2570** | | **~4.5 weeks** |

---

## 13. Risks and Mitigation

### Risk 1: Elimination Case Complexity
The 8 elimination cases are tedious but follow a pattern. Each case produces a formula where U(A,B) only appears at top level. The main risk is errors in stating the exact RHS equivalences.

**Mitigation**: Verify each equivalence with small integer models (e.g., ℤ restricted to [-5, 5]) before attempting full proofs.

### Risk 2: Termination Arguments
The nested induction must show strict decrease of measures at each level. The formula transformations (substitution, DNF, rewriting) must provably decrease the relevant measure.

**Mitigation**: Define measures as computable `Nat`-valued functions on formulas. Use `Nat.lt_wfRel` for well-founded recursion.

### Risk 3: Theorem 9.3.1 Generality
The proof of "separation implies expressiveness" works at the FO level and requires careful management of variable environments. The existing De Bruijn infrastructure in `MonadicFO.lean` helps but may need extensions for the R-predicate introduction.

**Mitigation**: Extend `MonadicSignature` with auxiliary predicates R_=, R_>, R_< as a signature extension operation.

### Risk 4: Box/Modal Treatment
Our formulas include `box` which is not part of GHR94's setup. For separation purposes, `box φ` is treated as atomic (its truth depends on the global modal structure, not on temporal position). This is consistent with how `table` treats it (as `atom (atomMap (box φ))`).

**Mitigation**: In `int_truth`, `box` is defined as `True` (degenerate). For the full connection to `truth_at`, a bridge lemma is needed showing that separation results transfer when box-subformulas are treated as atoms.

---

## Appendix: Dual Results

Every lemma about "pulling U out of S" has a dual about "pulling S out of U". In the formalization, these duals can be obtained mechanically via `swap_temporal`:

```lean
/-- Duality principle: if φ is equivalent to ψ over ℤ, then
    swap_temporal φ is equivalent to swap_temporal ψ over ℤ. -/
theorem dual_equiv (φ ψ : Formula) (h : int_equiv φ ψ) :
    int_equiv φ.swap_temporal ψ.swap_temporal := by
  sorry -- follows from swap_temporal being a semantics-preserving involution on ℤ

/-- The 8 elimination cases for "U out of S" yield 8 cases for "S out of U"
    by applying swap_temporal. -/
theorem elim_case_1_dual (a q A B : Formula) :
    int_equiv
      (.untl (.and a (.snce A B)) q)
      (-- dual of elim_case_1 result, obtained by swapping U↔S, <↔> 
       sorry) := by
  sorry
```

This reduces the total proof burden by roughly 40% (the 8 S-cases automatically give 8 U-cases).
