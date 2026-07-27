/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallNF

/-!
# Translation Correctness (Rabinovich 2014, Proposition 3.5)

Proves that the Until/Since chain translation of exists-forall formulas
is semantically correct. The key results are:

- `buildRight_correct`: the right Until chain captures the right part
  of an interval decomposition (existence of witnesses with specified types)
- `buildLeft_correct`: symmetric for the left Since chain
- `translateEF1_correct`: combines both directions

## Semantic Specification

`buildRight [(alpha_1, beta_1), ..., (alpha_m, beta_m)] beta_right` at point t
holds iff there exist strictly increasing witnesses x_1 < ... < x_m all > t with:
- alpha_i holds at x_i
- beta_1 holds in (t, x_1), beta_i holds in (x_{i-1}, x_i) for i >= 2
- beta_right holds for all s > x_m

`buildLeft [(alpha_1, beta_1), ..., (alpha_m, beta_m)] beta_left` at point t
holds iff there exist strictly decreasing witnesses x_1 > ... > x_m all < t with:
- alpha_i holds at x_i
- beta_1 holds in (x_1, t), beta_i holds in (x_i, x_{i-1}) for i >= 2
- beta_left holds for all s < x_m

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 3.5
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Helper lemmas for temporal truth of derived connectives -/

/-- `TemporalTruth` for `Formula.neg` is classical negation. -/
theorem temporal_truth_neg {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (φ : Formula) :
    TemporalTruth M atomMap t φ.neg ↔ ¬TemporalTruth M atomMap t φ := by
  simp only [Formula.neg, TemporalTruth]

/-- `TemporalTruth` for `Formula.top` is True. -/
theorem temporal_truth_top {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) :
    TemporalTruth M atomMap t Formula.top := by
  simp only [Formula.top, TemporalTruth]; intro h; exact h

/-- `TemporalTruth` for `Formula.and` is conjunction. -/
theorem temporal_truth_and {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (φ ψ : Formula) :
    TemporalTruth M atomMap t (Formula.and φ ψ) ↔
    TemporalTruth M atomMap t φ ∧ TemporalTruth M atomMap t ψ := by
  simp only [Formula.and, Formula.neg, TemporalTruth]
  tauto

/-- `TemporalTruth` for `Formula.or` is disjunction. -/
theorem temporal_truth_or {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (φ ψ : Formula) :
    TemporalTruth M atomMap t (Formula.or φ ψ) ↔
    TemporalTruth M atomMap t φ ∨ TemporalTruth M atomMap t ψ := by
  simp only [Formula.or, Formula.neg, TemporalTruth]
  tauto

/-- `TemporalTruth` for G(φ) = allFuture φ = ¬F(¬φ). -/
theorem temporal_truth_all_future {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (φ : Formula) :
    TemporalTruth M atomMap t φ.allFuture ↔
    ∀ s : M.carrier, t < s → TemporalTruth M atomMap s φ := by
  simp only [Formula.allFuture, Formula.someFuture]
  rw [temporal_truth_neg]
  simp only [TemporalTruth]
  constructor
  · intro h s h_lt
    by_contra h_neg
    apply h
    exact ⟨s, h_lt, (temporal_truth_neg M atomMap s φ).mpr h_neg,
           fun _ _ _ => temporal_truth_top M atomMap _⟩
  · intro h ⟨s, h_lt, h_neg, _⟩
    exact (temporal_truth_neg M atomMap s φ).mp h_neg (h s h_lt)

/-- `TemporalTruth` for H(φ) = allPast φ = ¬P(¬φ). -/
theorem temporal_truth_all_past {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) (φ : Formula) :
    TemporalTruth M atomMap t φ.allPast ↔
    ∀ s : M.carrier, s < t → TemporalTruth M atomMap s φ := by
  simp only [Formula.allPast, Formula.somePast]
  rw [temporal_truth_neg]
  simp only [TemporalTruth]
  constructor
  · intro h s h_lt
    by_contra h_neg
    apply h
    exact ⟨s, h_lt, (temporal_truth_neg M atomMap s φ).mpr h_neg,
           fun _ _ _ => temporal_truth_top M atomMap _⟩
  · intro h ⟨s, h_lt, h_neg, _⟩
    exact (temporal_truth_neg M atomMap s φ).mp h_neg (h s h_lt)

/-! ## Semantic specification of buildRight -/

/-- The semantic specification of what `buildRight pairs rightmost` means.

    `buildRight pairs rightmost` evaluated at t holds iff there exist
    strictly increasing future witnesses with the specified types:
    - Base: rightmost holds everywhere to the right (G rightmost)
    - Step: ∃ future witness x where alpha(x) and rest holds at x,
      with beta holding in the interval (t, x) -/
def BuildRightSpec {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (pairs : List (TemporalPred × TemporalPred)) (rightmost : TemporalPred)
    (t : M.carrier) : Prop :=
  match pairs with
  | [] =>
    -- No witnesses remain: rightmost holds everywhere strictly to the right
    ∀ s : M.carrier, t < s → rightmost.EvalAt M atomMap s
  | (alpha, beta) :: rest =>
    -- There exists a future witness x where alpha holds, beta holds in (t, x),
    -- and the rest of the chain continues from x
    ∃ x : M.carrier, t < x ∧ alpha.EvalAt M atomMap x ∧
      (∀ r : M.carrier, t < r → r < x → beta.EvalAt M atomMap r) ∧
      BuildRightSpec M atomMap rest rightmost x

/-- The semantic specification of what `buildLeft pairs leftmost` means.
    Symmetric to `BuildRightSpec`: witnesses are in the past. -/
def BuildLeftSpec {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (pairs : List (TemporalPred × TemporalPred)) (leftmost : TemporalPred)
    (t : M.carrier) : Prop :=
  match pairs with
  | [] =>
    -- No witnesses remain: leftmost holds everywhere strictly to the left
    ∀ s : M.carrier, s < t → leftmost.EvalAt M atomMap s
  | (alpha, beta) :: rest =>
    -- There exists a past witness x where alpha holds, beta holds in (x, t),
    -- and the rest of the chain continues from x
    ∃ x : M.carrier, x < t ∧ alpha.EvalAt M atomMap x ∧
      (∀ r : M.carrier, x < r → r < t → beta.EvalAt M atomMap r) ∧
      BuildLeftSpec M atomMap rest leftmost x

/-! ## Correctness of buildRight -/

/-- Correctness of `buildRight`: the temporal formula captures the semantic specification.
    Proof by induction on the pair list.

    The base case unfolds to G(rightmost) = ∀ s > t, rightmost(s).
    The step case unfolds to alpha(t) ∧ ∃ s > t, (right rest)(s) ∧ ∀ r ∈ (t,s), beta(r). -/
theorem buildRight_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (pairs : List (TemporalPred × TemporalPred)) (rightmost : TemporalPred)
    (t : M.carrier) :
    TemporalTruth M atomMap t (buildRight pairs rightmost) ↔
    BuildRightSpec M atomMap pairs rightmost t := by
  induction pairs generalizing t with
  | nil =>
    -- Base case: buildRight [] rightmost = G(rightmost) = ¬F(¬rightmost)
    simp only [buildRight, BuildRightSpec, TemporalPred.EvalAt]
    -- The formula is (untl (neg rightmost.formula) top).imp bot
    -- which is ¬(∃ s > t, ¬rightmost(s) ∧ ⊤) = ∀ s > t, rightmost(s)
    simp only [TemporalTruth]
    constructor
    · intro h s h_lt
      by_contra h_neg
      apply h
      exact ⟨s, h_lt, (temporal_truth_neg M atomMap s rightmost.formula).mpr h_neg,
             fun _ _ _ => temporal_truth_top M atomMap _⟩
    · intro h ⟨s, h_lt, h_neg_s, _⟩
      exact (temporal_truth_neg M atomMap s rightmost.formula).mp h_neg_s (h s h_lt)
  | cons pair rest ih =>
    -- Step case: buildRight (pair :: rest) rightmost = beta Until (alpha ∧ buildRight rest
    -- rightmost)
    obtain ⟨alpha, beta⟩ := pair
    simp only [buildRight, BuildRightSpec, TemporalPred.EvalAt]
    -- The formula is: Formula.untl (Formula.and alpha.formula (buildRight rest rightmost))
    -- beta.formula
    -- TemporalTruth: ∃ s > t, (alpha(s) ∧ (buildRight rest)(s)) ∧ ∀ r ∈ (t,s), beta(r)
    simp only [TemporalTruth]
    constructor
    · -- Forward: ∃ s > t, (alpha(s) ∧ (buildRight rest)(s)) ∧ guard
      intro ⟨s, h_lt, h_event, h_guard⟩
      have h_and := (temporal_truth_and M atomMap s alpha.formula (buildRight rest rightmost)).mp
          h_event
      exact ⟨s, h_lt, h_and.1, h_guard, (ih s).mp h_and.2⟩
    · -- Backward: ∃ x > t, alpha(x) ∧ guard ∧ rest_at_x
      intro ⟨x, h_lt, h_alpha, h_guard, h_rest⟩
      exact ⟨x, h_lt,
        (temporal_truth_and M atomMap x alpha.formula (buildRight rest rightmost)).mpr
          ⟨h_alpha, (ih x).mpr h_rest⟩,
        h_guard⟩

/-! ## Correctness of buildLeft -/

/-- Correctness of `buildLeft`: symmetric to `buildRight_correct`. -/
theorem buildLeft_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (pairs : List (TemporalPred × TemporalPred)) (leftmost : TemporalPred)
    (t : M.carrier) :
    TemporalTruth M atomMap t (buildLeft pairs leftmost) ↔
    BuildLeftSpec M atomMap pairs leftmost t := by
  induction pairs generalizing t with
  | nil =>
    -- Base case: buildLeft [] leftmost = H(leftmost) = ¬P(¬leftmost)
    simp only [buildLeft, BuildLeftSpec, TemporalPred.EvalAt]
    simp only [TemporalTruth]
    constructor
    · intro h s h_lt
      by_contra h_neg
      apply h
      exact ⟨s, h_lt, (temporal_truth_neg M atomMap s leftmost.formula).mpr h_neg,
             fun _ _ _ => temporal_truth_top M atomMap _⟩
    · intro h ⟨s, h_lt, h_neg_s, _⟩
      exact (temporal_truth_neg M atomMap s leftmost.formula).mp h_neg_s (h s h_lt)
  | cons pair rest ih =>
    -- Step case: buildLeft (pair :: rest) leftmost = beta Since (alpha ∧ buildLeft rest leftmost)
    obtain ⟨alpha, beta⟩ := pair
    simp only [buildLeft, BuildLeftSpec, TemporalPred.EvalAt]
    simp only [TemporalTruth]
    constructor
    · -- Forward: ∃ s < t, (alpha(s) ∧ (buildLeft rest)(s)) ∧ guard
      intro ⟨s, h_lt, h_event, h_guard⟩
      have h_and := (temporal_truth_and M atomMap s alpha.formula (buildLeft rest leftmost)).mp
          h_event
      exact ⟨s, h_lt, h_and.1, h_guard, (ih s).mp h_and.2⟩
    · -- Backward: ∃ x < t, alpha(x) ∧ guard ∧ rest_at_x
      intro ⟨x, h_lt, h_alpha, h_guard, h_rest⟩
      exact ⟨x, h_lt,
        (temporal_truth_and M atomMap x alpha.formula (buildLeft rest leftmost)).mpr
          ⟨h_alpha, (ih x).mpr h_rest⟩,
        h_guard⟩

/-! ## Correctness of translateEF1

The combined translation: alpha_k holds at t, the right chain holds, and the left chain holds. -/

/-- `translateEF1 n k alpha beta` at point t holds iff:
    - alpha_k holds at t (the free variable IS the k-th witness)
    - The right chain holds: witnesses x_{k+1} < ... < x_n exist to the right with correct types
    - The left chain holds: witnesses x_{k-1} > ... > x_0 exist to the left with correct types -/
theorem translateEF1_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (k : Fin (n + 1))
    (alpha : Fin (n + 1) → TemporalPred)
    (beta : Fin (n + 2) → TemporalPred)
    (t : M.carrier) :
    TemporalTruth M atomMap t (translateEF1 n k alpha beta) ↔
    (alpha k).EvalAt M atomMap t ∧
    BuildRightSpec M atomMap
      ((List.finRange (n - k.val)).map fun i =>
        let idx := k.val + 1 + i.val
        (alpha ⟨idx, by omega⟩, beta ⟨idx, by omega⟩))
      (beta ⟨n + 1, by omega⟩) t ∧
    BuildLeftSpec M atomMap
      ((List.finRange k.val).map fun i =>
        let idx := k.val - 1 - i.val
        (alpha ⟨idx, by omega⟩, beta ⟨idx + 1, by omega⟩))
      (beta ⟨0, by omega⟩) t := by
  simp only [translateEF1]
  rw [temporal_truth_and]
  constructor
  · intro ⟨h_ak, h_rl⟩
    refine ⟨h_ak, ?_⟩
    rw [temporal_truth_and] at h_rl
    exact ⟨(buildRight_correct M atomMap _ _ t).mp h_rl.1,
           (buildLeft_correct M atomMap _ _ t).mp h_rl.2⟩
  · intro ⟨h_ak, h_right, h_left⟩
    refine ⟨h_ak, ?_⟩
    rw [temporal_truth_and]
    exact ⟨(buildRight_correct M atomMap _ _ t).mpr h_right,
           (buildLeft_correct M atomMap _ _ t).mpr h_left⟩

/-! ## VEF1 to Temporal Translation

An EF1 formula (single interval pattern with a free variable) is equivalent to
the temporal formula produced by `translateEF1`. A VEF1 (disjunction of EF1s)
is equivalent to the disjunction of the individual translations. -/

/-- For any single EF formula (interval pattern with the free variable at position k
    among n+1 witnesses), `translateEF1 n k alpha beta` is a temporal formula
    that is equivalent to it on any ordered structure.

    This is Rabinovich Proposition 3.5: every EF formula with one free variable
    has an equivalent TL(U,S) formula. -/
noncomputable def ef1ToTemporal
    (n : Nat) (k : Fin (n + 1))
    (alpha : Fin (n + 1) → TemporalPred)
    (beta : Fin (n + 2) → TemporalPred) :
    { A : Formula //
      ∀ {sig : MonadicSignature}
        (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
        (t : M.carrier),
        TemporalTruth M atomMap t A ↔
        ((alpha k).EvalAt M atomMap t ∧
         BuildRightSpec M atomMap
           ((List.finRange (n - k.val)).map fun i =>
             let idx := k.val + 1 + i.val
             (alpha ⟨idx, by omega⟩, beta ⟨idx, by omega⟩))
           (beta ⟨n + 1, by omega⟩) t ∧
         BuildLeftSpec M atomMap
           ((List.finRange k.val).map fun i =>
             let idx := k.val - 1 - i.val
             (alpha ⟨idx, by omega⟩, beta ⟨idx + 1, by omega⟩))
           (beta ⟨0, by omega⟩) t) } :=
  ⟨translateEF1 n k alpha beta, fun M atomMap t => translateEF1_correct M atomMap n k alpha beta t⟩

/-- `translateVEF1` correctness: the disjunction formula holds iff some disjunct holds. -/
theorem translateVEF1_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (disjuncts : List Formula) (t : M.carrier) :
    TemporalTruth M atomMap t (translateVEF1 disjuncts) ↔
    ∃ f ∈ disjuncts, TemporalTruth M atomMap t f := by
  induction disjuncts with
  | nil =>
    simp only [translateVEF1, TemporalTruth, List.not_mem_nil, false_and, exists_const]
  | cons f rest ih =>
    cases rest with
    | nil =>
      simp only [translateVEF1, List.mem_cons, List.not_mem_nil, or_false]
      exact ⟨fun h => ⟨f, rfl, h⟩, fun ⟨_, hf, h⟩ => hf ▸ h⟩
    | cons g rest' =>
      simp only [translateVEF1]
      rw [temporal_truth_or]
      constructor
      · rintro (hf | hrest)
        · exact ⟨f, by simp, hf⟩
        · obtain ⟨f', hf'_mem, hf'⟩ := ih.mp hrest
          exact ⟨f', by simp [hf'_mem], hf'⟩
      · rintro ⟨f', hf'_mem, hf'⟩
        simp only [List.mem_cons] at hf'_mem
        rcases hf'_mem with rfl | hmem
        · exact Or.inl hf'
        · exact Or.inr (ih.mpr ⟨f', by simp [hmem], hf'⟩)

end FormalSystem.Metalogic.WeakCanonical.Kamp
