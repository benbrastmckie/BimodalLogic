import Bimodal.Metalogic.WeakCanonical.Kamp.ConjInterleave

/-!
# Conjunction closure of ∨∃∀-formulas (Rabinovich Lemma 3.4, ∧-part, PDF p.5)

The **conjunction-closure** half of Lemma 3.4 (p.5): the set of ∨∃∀-formulas is closed under
conjunction. Where the disjunction closure (`veeSat_append`, `VeeExistsForall.lean`) is a pure list
concatenation independent of Lemma 3.2, the conjunction closure is the genuine content resting on
Lemma 3.2(1) — packaged as `conjInterleave_iff` (`ConjInterleave.lean`).

The construction distributes ∧ over the two disjunctions,
`(⋁ᵢ ψᵢ) ∧ (⋁ⱼ φⱼ) = ⋁ᵢ ⋁ⱼ (ψᵢ ∧ φⱼ)`, realizing each pairwise conjunct `ψᵢ ∧ φⱼ` as the
∨∃∀-formula `conjInterleave ψᵢ φⱼ ψᵢ.pin φⱼ.pin`, then flattening. The characterization
`veeConj_iff` follows by pushing `veeSat` through the two `flatMap`s and applying
`conjInterleave_iff` pointwise.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Lemma 3.4 (p.5). Cited by PDF page.
- `ConjInterleave.lean`: `conjInterleave` and its characterization `conjInterleave_iff`
  (Lemma 3.2(1)).
- `VeeExistsForall.lean`: the ∨∃∀ object `VeeExistsForall`, `veeSat`, and the ∨-closure
  `veeSat_append`.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax (Formula)

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. Satisfaction through a `flatMap` of ∨∃∀-formulas -/

/-- **`veeSat` through a `flatMap`.** A `flatMap` of ∨∃∀-formulas over a list `l` is satisfied iff
some element `a ∈ l` yields a satisfied ∨∃∀-formula `f a`. This is the list-bookkeeping lever for
pushing `veeSat` through the two distributive `flatMap`s of `veeConj`. -/
theorem veeSat_flatMap {r : Nat} {α : Type*} (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (l : List α) (f : α → VeeExistsForall sig F r) :
    veeSat N env (l.flatMap f) ↔ ∃ a ∈ l, veeSat N env (f a) := by
  simp only [veeSat, List.mem_flatMap]
  constructor
  · rintro ⟨χ, ⟨a, ha, hχ⟩, hsat⟩
    exact ⟨a, ha, χ, hχ, hsat⟩
  · rintro ⟨a, ha, χ, hχ, hsat⟩
    exact ⟨χ, ⟨a, ha, hχ⟩, hsat⟩

/-! ## 2. The conjunction of two ∨∃∀-formulas -/

/-- **`veeConj` (Rabinovich Lemma 3.4, ∧-part, p.5).** The conjunction of two ∨∃∀-formulas, built by
distributing ∧ over both disjunctions and realizing each pairwise conjunct `ψ ∧ φ` as the
∨∃∀-formula `conjInterleave ψ φ ψ.pin φ.pin`. -/
noncomputable def veeConj {r : Nat} (Ψ₁ Ψ₂ : VeeExistsForall sig F r) : VeeExistsForall sig F r :=
  Ψ₁.flatMap (fun ψ => Ψ₂.flatMap (fun φ => conjInterleave ψ φ ψ.pin φ.pin))

/-! ## 3. The conjunction-closure characterization -/

/-- **Conjunction closure (Lemma 3.4, ∧-part, p.5).** `veeConj Ψ₁ Ψ₂` is satisfied at `env`
exactly when both `Ψ₁` and `Ψ₂` are: ∨∃∀-formulas are closed under conjunction. Proved by pushing
`veeSat` through both distributive `flatMap`s (`veeSat_flatMap`) and applying `conjInterleave_iff`
to each pairwise conjunct, then rearranging the nested existentials. -/
theorem veeConj_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (Ψ₁ Ψ₂ : VeeExistsForall sig F r) :
    veeSat N env (veeConj Ψ₁ Ψ₂) ↔ veeSat N env Ψ₁ ∧ veeSat N env Ψ₂ := by
  unfold veeConj
  rw [veeSat_flatMap]
  constructor
  · rintro ⟨ψ, hψ, hrest⟩
    rw [veeSat_flatMap] at hrest
    obtain ⟨φ, hφ, hpair⟩ := hrest
    rw [conjInterleave_iff] at hpair
    obtain ⟨e1, e2⟩ := hpair
    exact ⟨⟨ψ, hψ, e1⟩, ⟨φ, hφ, e2⟩⟩
  · rintro ⟨⟨ψ, hψ, e1⟩, ⟨φ, hφ, e2⟩⟩
    refine ⟨ψ, hψ, ?_⟩
    rw [veeSat_flatMap]
    refine ⟨φ, hφ, ?_⟩
    rw [conjInterleave_iff]
    exact ⟨e1, e2⟩

end Bimodal.Metalogic.WeakCanonical
