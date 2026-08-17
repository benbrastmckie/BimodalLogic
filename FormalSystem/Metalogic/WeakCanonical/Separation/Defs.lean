/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import Mathlib.Algebra.Order.Group.Int

/-!
# Separation Definitions: Integer Temporal Semantics

Core definitions for the separation theorem over integer time (GHR94 Chapter 10.2).

## Key Definitions

- `IntStructure`: A temporal structure over integers (valuation on Z)
- `IntTruth`: Recursive truth evaluation for formulas over Z
- `IntEquiv`: Semantic equivalence over integer time
- `IsPurePast`, `IsPureFuture`, `IsPurePresent`: Semantic purity predicates
- `isUFree`, `isSFree`: Syntactic absence predicates (decidable)
- `isSyntacticallySeparated`: Recursive syntactic separation check
- `IsSeparable`: Existential separation predicate
- `junctionDepth`, `uDepthUnderS`, `countUSubformulas`: Structural measures

## References

- GHR94, Chapter 10, Section 10.2 (pp. 569-592)
- Design provenance: the expressive-completeness proof for U/S over integer time
-/

namespace FormalSystem.Metalogic.WeakCanonical.Separation

open FormalSystem.Syntax

/-! ## Integer Temporal Structure -/

/-- A temporal structure over integers: a valuation mapping atoms to sets of Z.
    This is GHR94's "linear temporal structure" (T, <, h) specialized to T = Z. -/
structure IntStructure where
  /-- The times at which each atom holds. This is GHR94's valuation `h`. -/
  val : Atom → Set ℤ

/-! ## Truth Evaluation -/

/-- Truth of a formula at time t in an integer temporal structure.
    Note: box is treated as True (degenerate: modal component irrelevant for separation).
    This matches GHR94's "linear temporal structure" setup. -/
def IntTruth (M : IntStructure) (t : ℤ) : Formula → Prop
  | .atom a => t ∈ M.val a
  | .bot => False
  | .imp φ ψ => IntTruth M t φ → IntTruth M t ψ
  | .box _ => True  -- degenerate: modal not relevant for separation
  | .untl ψ φ => ∃ s : ℤ, t < s ∧ IntTruth M s φ ∧
      ∀ r : ℤ, t < r → r < s → IntTruth M r ψ
  | .snce ψ φ => ∃ s : ℤ, s < t ∧ IntTruth M s φ ∧
      ∀ r : ℤ, s < r → r < t → IntTruth M r ψ

/-! ## IntTruth simp lemmas for derived temporal operators -/

@[simp] theorem int_truth_all_past (M : IntStructure) (t : ℤ) (φ : Formula) :
    IntTruth M t (Formula.allPast φ) ↔ ∀ s : ℤ, s < t → IntTruth M s φ := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top, IntTruth]
  constructor
  · intro h s hs
    by_contra hns
    exact h ⟨s, hs, hns, fun _ _ _ h => h⟩
  · rintro h ⟨s, hs, hns, _⟩
    exact hns (h s hs)

@[simp] theorem int_truth_all_future (M : IntStructure) (t : ℤ) (φ : Formula) :
    IntTruth M t (Formula.allFuture φ) ↔ ∀ s : ℤ, t < s → IntTruth M s φ := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top, IntTruth]
  constructor
  · intro h s hs
    by_contra hns
    exact h ⟨s, hs, hns, fun _ _ _ h => h⟩
  · rintro h ⟨s, hs, hns, _⟩
    exact hns (h s hs)

@[simp] theorem int_truth_some_past (M : IntStructure) (t : ℤ) (φ : Formula) :
    IntTruth M t (Formula.somePast φ) ↔ ∃ s : ℤ, s < t ∧ IntTruth M s φ := by
  simp only [Formula.somePast, Formula.top, IntTruth]
  constructor
  · rintro ⟨s, hs, hphi, _⟩
    exact ⟨s, hs, hphi⟩
  · rintro ⟨s, hs, hphi⟩
    exact ⟨s, hs, hphi, fun _ _ _ h => h⟩

@[simp] theorem int_truth_some_future (M : IntStructure) (t : ℤ) (φ : Formula) :
    IntTruth M t (Formula.someFuture φ) ↔ ∃ s : ℤ, t < s ∧ IntTruth M s φ := by
  simp only [Formula.someFuture, Formula.top, IntTruth]
  constructor
  · rintro ⟨s, hs, hphi, _⟩
    exact ⟨s, hs, hphi⟩
  · rintro ⟨s, hs, hphi⟩
    exact ⟨s, hs, hphi, fun _ _ _ h => h⟩

/-! ## Formula Atoms -/

/-- Collect all atoms occurring in a formula (as a `Set Atom`). -/
def FormulaAtoms : Formula → Set Atom
  | .atom a => {a}
  | .bot => ∅
  | .imp φ ψ => FormulaAtoms φ ∪ FormulaAtoms ψ
  | .box φ => FormulaAtoms φ
  | .untl ψ φ => FormulaAtoms φ ∪ FormulaAtoms ψ
  | .snce ψ φ => FormulaAtoms φ ∪ FormulaAtoms ψ

@[simp] theorem formula_atoms_all_past (φ : Formula) :
    FormulaAtoms (Formula.allPast φ) = FormulaAtoms φ := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top, FormulaAtoms]
  ext a; simp only [Set.mem_union, Set.mem_empty_iff_false, or_false]

@[simp] theorem formula_atoms_all_future (φ : Formula) :
    FormulaAtoms (Formula.allFuture φ) = FormulaAtoms φ := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top, FormulaAtoms]
  ext a; simp only [Set.mem_union, Set.mem_empty_iff_false, or_false]

/-! ## Semantic Equivalence -/

/-- Semantic equivalence of formulas over integer time. -/
def IntEquiv (φ ψ : Formula) : Prop :=
  ∀ (M : IntStructure) (t : ℤ), IntTruth M t φ ↔ IntTruth M t ψ

/-- IntEquiv is reflexive. -/
theorem int_equiv_refl (φ : Formula) : IntEquiv φ φ :=
  fun _ _ => Iff.rfl

/-- IntEquiv is symmetric. -/
theorem int_equiv_symm {φ ψ : Formula} (h : IntEquiv φ ψ) : IntEquiv ψ φ :=
  fun M t => (h M t).symm

/-- IntEquiv is transitive. -/
theorem int_equiv_trans {φ ψ χ : Formula} (h1 : IntEquiv φ ψ) (h2 : IntEquiv ψ χ) :
    IntEquiv φ χ :=
  fun M t => (h1 M t).trans (h2 M t)

/-! ## Semantic Purity Predicates -/

/-- A formula is "pure past" if its truth at t depends only on the past of t. -/
def IsPurePast (φ : Formula) : Prop :=
  ∀ (M₁ M₂ : IntStructure) (t : ℤ),
    (∀ (a : Atom) (s : ℤ), s < t → (s ∈ M₁.val a ↔ s ∈ M₂.val a)) →
    (IntTruth M₁ t φ ↔ IntTruth M₂ t φ)

/-- A formula is "pure future" if its truth at t depends only on the future of t. -/
def IsPureFuture (φ : Formula) : Prop :=
  ∀ (M₁ M₂ : IntStructure) (t : ℤ),
    (∀ (a : Atom) (s : ℤ), t < s → (s ∈ M₁.val a ↔ s ∈ M₂.val a)) →
    (IntTruth M₁ t φ ↔ IntTruth M₂ t φ)

/-- A formula is "pure present" if its truth at t depends only on time t. -/
def IsPurePresent (φ : Formula) : Prop :=
  ∀ (M₁ M₂ : IntStructure) (t : ℤ),
    (∀ (a : Atom), (t ∈ M₁.val a ↔ t ∈ M₂.val a)) →
    (IntTruth M₁ t φ ↔ IntTruth M₂ t φ)

/-! ## Syntactic Predicates -/

/-- A formula is "syntactically U-free": contains no `untl` constructor. -/
def isUFree : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => isUFree φ && isUFree ψ
  | .box φ => isUFree φ
  | .untl _ _ => false
  | .snce ψ φ => isUFree φ && isUFree ψ

/-- A formula is "syntactically S-free": contains no `snce` constructor. -/
def isSFree : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => isSFree φ && isSFree ψ
  | .box φ => isSFree φ
  | .untl ψ φ => isSFree φ && isSFree ψ
  | .snce _ _ => false

/-! ### Simp lemmas for isUFree and isSFree at derived temporal operators -/

@[simp] theorem is_U_free_all_past (φ : Formula) :
    isUFree (Formula.allPast φ) = isUFree φ := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top, isUFree,
    Bool.and_true]

@[simp] theorem is_U_free_all_future (φ : Formula) :
    isUFree (Formula.allFuture φ) = false := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top, isUFree,
    Bool.false_and]

@[simp] theorem is_S_free_all_past (φ : Formula) :
    isSFree (Formula.allPast φ) = false := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top, isSFree,
    Bool.false_and]

@[simp] theorem is_S_free_all_future (φ : Formula) :
    isSFree (Formula.allFuture φ) = isSFree φ := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top, isSFree,
    Bool.and_true]

/-- A formula is "syntactically separated" if it is a boolean combination of:
    - atoms (pure present)
    - U-formulas with S-free arguments (pure future)
    - S-formulas with U-free arguments (pure past)

    We define this recursively. A formula is separated if:
    - It is an atom or bot
    - It is imp phi psi with both separated
    - It is allFuture phi with S-free phi (hence pure future)
    - It is allPast phi with U-free phi (hence pure past)
    - It is untl phi psi with both S-free (hence pure future)
    - It is snce phi psi with both U-free (hence pure past)
    - It is box phi (treated as atomic/present) -/
def isSyntacticallySeparated : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => isSyntacticallySeparated φ && isSyntacticallySeparated ψ
  | .box _ => true  -- box treated as atomic
  | .untl ψ φ => isSFree φ && isSFree ψ
  | .snce ψ φ => isUFree φ && isUFree ψ

@[simp] theorem is_syntactically_separated_all_past (φ : Formula) :
    isSyntacticallySeparated (Formula.allPast φ) = isUFree φ := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top,
    isSyntacticallySeparated, isUFree, Bool.and_true]

@[simp] theorem is_syntactically_separated_all_future (φ : Formula) :
    isSyntacticallySeparated (Formula.allFuture φ) = isSFree φ := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top,
    isSyntacticallySeparated, isSFree, Bool.and_true]

/-- A formula is "separable" if it is integer-equivalent to a syntactically
    separated formula. -/
def IsSeparable (φ : Formula) : Prop :=
  ∃ ψ : Formula, isSyntacticallySeparated ψ = true ∧ IntEquiv φ ψ

/-! ## Proper Purity Predicates (Option D from Report 07)

These predicates correctly model GHR94's semantic separation for our formalization
where `allFuture` (G) and `allPast` (H) are primitive constructors rather than
derived from U/S. A "future-only" formula contains no past temporal operators,
and a "past-only" formula contains no future temporal operators. -/

/-- A formula is "future-only": contains no `allPast` and no `snce`.
    Permits `allFuture`, `untl`, atoms, boolean connectives.
    This correctly captures "pure future" for our primitive operator set. -/
def isFutureOnly : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => isFutureOnly φ && isFutureOnly ψ
  | .box φ => isFutureOnly φ
  | .untl ψ φ => isFutureOnly φ && isFutureOnly ψ
  | .snce _ _ => false

@[simp] theorem is_future_only_all_past (φ : Formula) :
    isFutureOnly (Formula.allPast φ) = false := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top, isFutureOnly,
    Bool.false_and]

@[simp] theorem is_future_only_all_future (φ : Formula) :
    isFutureOnly (Formula.allFuture φ) = isFutureOnly φ := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top, isFutureOnly,
    Bool.and_true]

/-- A formula is "past-only": contains no `allFuture` and no `untl`.
    Permits `allPast`, `snce`, atoms, boolean connectives.
    This correctly captures "pure past" for our primitive operator set. -/
def isPastOnly : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => isPastOnly φ && isPastOnly ψ
  | .box φ => isPastOnly φ
  | .untl _ _ => false
  | .snce ψ φ => isPastOnly φ && isPastOnly ψ

@[simp] theorem is_past_only_all_past (φ : Formula) :
    isPastOnly (Formula.allPast φ) = isPastOnly φ := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top, isPastOnly,
    Bool.and_true]

@[simp] theorem is_past_only_all_future (φ : Formula) :
    isPastOnly (Formula.allFuture φ) = false := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top, isPastOnly,
    Bool.false_and]

/-- A formula is "properly separated" if it is a boolean combination of:
    - atoms (pure present)
    - future-only formulas under `allFuture` or `untl`
    - past-only formulas under `allPast` or `snce`

    This matches GHR94's semantic separation requirement: S-arguments must be
    genuinely past-dependent (no future operators), and U-arguments must be
    genuinely future-dependent (no past operators). -/
def isProperlySeparated : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => isProperlySeparated φ && isProperlySeparated ψ
  | .box _ => true
  | .untl ψ φ => isFutureOnly φ && isFutureOnly ψ
  | .snce ψ φ => isPastOnly φ && isPastOnly ψ

@[simp] theorem is_properly_separated_all_past (φ : Formula) :
    isProperlySeparated (Formula.allPast φ) = isPastOnly φ := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top,
    isProperlySeparated, isPastOnly, Bool.and_true]

@[simp] theorem is_properly_separated_all_future (φ : Formula) :
    isProperlySeparated (Formula.allFuture φ) = isFutureOnly φ := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top,
    isProperlySeparated, isFutureOnly, Bool.and_true]

/-- A formula is "properly separable" if it is integer-equivalent to a
    properly separated formula. This is the correct notion for Theorem 9.3.1. -/
def IsProperlySeparable (φ : Formula) : Prop :=
  ∃ ψ : Formula, isProperlySeparated ψ = true ∧ IntEquiv φ ψ

/-! ## Structural Measures for Induction -/

mutual
/-- Junction depth of a formula: maximum alternation depth of U/S nesting.
    This is the key induction measure for Lemma 10.2.8.
    Mutually recursive with junctionDepthU and junctionDepthS. -/
def junctionDepth : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp phi psi => max (junctionDepth phi) (junctionDepth psi)
  | .box phi => junctionDepth phi
  | .untl psi phi => max (junctionDepthU phi) (junctionDepthU psi)
  | .snce psi phi => max (junctionDepthS phi) (junctionDepthS psi)

/-- Junction depth of a formula read from inside an `untl`: like `junctionDepth`,
    but a nested `snce` counts as one alternation and resets the measure to the
    plain `junctionDepth` of its arguments. Mutually recursive with
    `junctionDepth` and `junctionDepthS`. -/
def junctionDepthU : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp phi psi => max (junctionDepthU phi) (junctionDepthU psi)
  | .box phi => junctionDepthU phi
  | .untl psi phi => max (junctionDepthU phi) (junctionDepthU psi)
  | .snce psi phi => 1 + max (junctionDepth phi) (junctionDepth psi)

/-- Junction depth of a formula read from inside an `snce`: the past-directed
    mirror of `junctionDepthU`, so a nested `untl` is what counts as an
    alternation. Mutually recursive with `junctionDepth` and
    `junctionDepthU`. -/
def junctionDepthS : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp phi psi => max (junctionDepthS phi) (junctionDepthS psi)
  | .box phi => junctionDepthS phi
  | .untl psi phi => 1 + max (junctionDepth phi) (junctionDepth psi)
  | .snce psi phi => max (junctionDepthS phi) (junctionDepthS psi)
end

/-! ### Simp lemmas for junctionDepth at derived temporal operators -/

@[simp] theorem junction_depth_all_past (φ : Formula) :
    junctionDepth (Formula.allPast φ) = junctionDepthS φ := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top,
    junctionDepth, junctionDepthS]; omega

@[simp] theorem junction_depth_all_future (φ : Formula) :
    junctionDepth (Formula.allFuture φ) = junctionDepthU φ := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top,
    junctionDepth, junctionDepthU]; omega

/-- U-nesting depth beneath S: maximum depth of U under S (with no intervening S).
    Used for Lemma 10.2.7 induction. -/
def uDepthUnderS : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => max (uDepthUnderS φ) (uDepthUnderS ψ)
  | .box φ => uDepthUnderS φ
  | .untl ψ φ => 1 + max (uDepthUnderS φ) (uDepthUnderS ψ)
  | .snce _ _ => 0  -- S resets the counter

/-- Count of maximal U-subformulas in a formula.
    Used for Lemma 10.2.6 induction on the number of distinct U-patterns. -/
def countUSubformulas : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => countUSubformulas φ + countUSubformulas ψ
  | .box φ => countUSubformulas φ
  | .untl _ _ => 1  -- count the U itself, not sub-U's
  | .snce ψ φ => countUSubformulas φ + countUSubformulas ψ

/-- Total count of ALL `.untl` nodes at ALL depths in a formula.
    Unlike `countUSubformulas` (which counts surface-level `.untl` nodes as 1 each),
    this recurses into `.untl` children. Used for oracle-free separation proofs
    where innermost U-types are abstracted. -/
def countUTotal : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => countUTotal φ + countUTotal ψ
  | .box φ => countUTotal φ
  | .untl ψ φ => 1 + countUTotal φ + countUTotal ψ
  | .snce ψ φ => countUTotal φ + countUTotal ψ

/-- `countUTotal phi = 0` iff the formula is U-free. -/
theorem count_U_total_zero_iff_U_free (phi : Formula) :
    countUTotal phi = 0 ↔ isUFree phi = true := by
  induction phi with
  | atom _ => simp [countUTotal, isUFree]
  | bot => simp [countUTotal, isUFree]
  | imp a b ih1 ih2 =>
    simp only [countUTotal, isUFree, Nat.add_eq_zero_iff, Bool.and_eq_true, ih1, ih2]
  | box a ih => simp only [countUTotal, isUFree]; exact ih
  | untl _ _ =>
    simp only [countUTotal, isUFree]
    exact iff_of_false (by omega) (by decide)
  | snce b a ih2 ih1 =>
    simp only [countUTotal, isUFree, Nat.add_eq_zero_iff, Bool.and_eq_true, ih1, ih2]

/-- S-nesting depth above U occurrences. Used for Lemma 10.2.5 induction.
    Counts the maximum number of S's between the root and any U. -/
def sNestingAboveU : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => max (sNestingAboveU φ) (sNestingAboveU ψ)
  | .box φ => sNestingAboveU φ
  | .untl _ _ => 0  -- U found; no S above it on this path
  | .snce ψ φ =>
    -- If there's a U below, this S adds 1 to the nesting
    let sub := max (sNestingAboveUInner φ) (sNestingAboveUInner ψ)
    if sub > 0 then 1 + sub else 0
where
  /-- Helper: counts S-nesting above U inside an S context.
      Returns 0 if there is no U below. -/
  sNestingAboveUInner : Formula → Nat
    | .atom _ => 0
    | .bot => 0
    | .imp φ ψ => max (sNestingAboveUInner φ) (sNestingAboveUInner ψ)
    | .box φ => sNestingAboveUInner φ
    | .untl _ _ => 1  -- U found inside S: contributes 1 (the S we're in)
    | .snce ψ φ =>
      let sub := max (sNestingAboveUInner φ) (sNestingAboveUInner ψ)
      if sub > 0 then 1 + sub else 0

/-! ## Auxiliary Predicates for Elimination Cases -/

/-- Predicate: U only appears in the formula as the specific subformula U(A,B),
    not under any S (i.e., all occurrences of U(A,B) are at "top level" w.r.t. S). -/
def UAppearancesTopLevelOnly : Formula → Formula → Formula → Prop
  | .atom _, _, _ => True
  | .bot, _, _ => True
  | .imp φ ψ, A, B => UAppearancesTopLevelOnly φ A B ∧ UAppearancesTopLevelOnly ψ A B
  | .box φ, A, B => UAppearancesTopLevelOnly φ A B
  | .untl ψ φ, A, B => φ = A ∧ ψ = B  -- Only the specific U(A,B) is allowed
  | .snce ψ φ, _, _ =>
    -- Under S: no untl allowed at all (U must be at top level, not under S)
    isUFree φ = true ∧ isUFree ψ = true

/-- Predicate: In the result formula, U(A,B) appears only at top level
    (not under any S). Equivalent to: under every S, the formula is U-free. -/
def UAppearsOnlyAsTopLevel : Formula → Formula → Formula → Prop
  | .atom _, _, _ => True
  | .bot, _, _ => True
  | .imp φ ψ, A, B => UAppearsOnlyAsTopLevel φ A B ∧ UAppearsOnlyAsTopLevel ψ A B
  | .box φ, A, B => UAppearsOnlyAsTopLevel φ A B
  | .untl ψ φ, A, B => UAppearsOnlyAsTopLevel φ A B ∧ UAppearsOnlyAsTopLevel ψ A B
  | .snce ψ φ, _, _ => isUFree φ = true ∧ isUFree ψ = true

/-- Predicate: the formula has no S nested within any U. -/
def NoSNestedInU : Formula -> Prop
  | .atom _ => True
  | .bot => True
  | .imp phi psi => NoSNestedInU phi ∧ NoSNestedInU psi
  | .box phi => NoSNestedInU phi
  | .untl psi phi => isSFree phi = true ∧ isSFree psi = true
  | .snce psi phi => NoSNestedInU phi ∧ NoSNestedInU psi

@[simp] theorem no_S_nested_in_U_all_past (φ : Formula) :
    NoSNestedInU (Formula.allPast φ) ↔ NoSNestedInU φ := by
  simp only [Formula.allPast, Formula.neg, Formula.somePast, Formula.top, NoSNestedInU,
    and_true]

@[simp] theorem no_S_nested_in_U_all_future (φ : Formula) :
    NoSNestedInU (Formula.allFuture φ) ↔ (isSFree φ = true) := by
  simp only [Formula.allFuture, Formula.neg, Formula.someFuture, Formula.top,
    NoSNestedInU, isSFree, Bool.and_true, and_true]

/-! ## Semantic Atom Dependence -/

/-- Truth of a formula depends only on atoms in `FormulaAtoms`.
    If two models agree on all atoms appearing in φ, then φ has the same truth value. -/
theorem int_truth_depends_only_on_atoms (φ : Formula) (M₁ M₂ : IntStructure) (t : ℤ)
    (h : ∀ a ∈ FormulaAtoms φ, M₁.val a = M₂.val a) :
    IntTruth M₁ t φ ↔ IntTruth M₂ t φ := by
  induction φ generalizing t with
  | atom a =>
    simp only [FormulaAtoms, Set.mem_singleton_iff] at h
    simp only [IntTruth]; rw [h a rfl]
  | bot => rfl
  | imp c d ih1 ih2 =>
    simp only [IntTruth]; exact Iff.imp
      (ih1 t (fun a ha => h a (Set.mem_union_left _ ha)))
      (ih2 t (fun a ha => h a (Set.mem_union_right _ ha)))
  | box _ => rfl
  | untl d c ih2 ih1 =>
    simp only [IntTruth]; constructor
    · rintro ⟨s, hts, hc, hd⟩
      exact ⟨s, hts, (ih1 s (fun a ha => h a (Set.mem_union_left _ ha))).mp hc,
        fun r hr1 hr2 => (ih2 r (fun a ha => h a (Set.mem_union_right _ ha))).mp (hd r hr1 hr2)⟩
    · rintro ⟨s, hts, hc, hd⟩
      exact ⟨s, hts, (ih1 s (fun a ha => h a (Set.mem_union_left _ ha))).mpr hc,
        fun r hr1 hr2 => (ih2 r (fun a ha => h a (Set.mem_union_right _ ha))).mpr (hd r hr1 hr2)⟩
  | snce d c ih2 ih1 =>
    simp only [IntTruth]; constructor
    · rintro ⟨s, hst, hc, hd⟩
      exact ⟨s, hst, (ih1 s (fun a ha => h a (Set.mem_union_left _ ha))).mp hc,
        fun r hr1 hr2 => (ih2 r (fun a ha => h a (Set.mem_union_right _ ha))).mp (hd r hr1 hr2)⟩
    · rintro ⟨s, hst, hc, hd⟩
      exact ⟨s, hst, (ih1 s (fun a ha => h a (Set.mem_union_left _ ha))).mpr hc,
        fun r hr1 hr2 => (ih2 r (fun a ha => h a (Set.mem_union_right _ ha))).mpr (hd r hr1 hr2)⟩

/-! ## Predicate Equivalence: Syntactic vs. Proper Separation

At the 6-constructor Formula level, `isSFree = isFutureOnly` and
`isUFree = isPastOnly`. This makes `isSyntacticallySeparated` and
`isProperlySeparated` identical predicates, so `IsSeparable` and
`IsProperlySeparable` are equivalent. -/

/-- `isSFree` and `isFutureOnly` are identical predicates on the 6-constructor Formula type.
    Both forbid `snce` and permit `untl`, `box`, `imp`, `atom`, `bot`. -/
theorem s_free_eq_future_only (φ : Formula) : isSFree φ = isFutureOnly φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 => simp [isSFree, isFutureOnly, ih1, ih2]
  | box a ih => simp [isSFree, isFutureOnly, ih]
  | untl b a ih2 ih1 => simp [isSFree, isFutureOnly, ih1, ih2]
  | snce _ _ => rfl

/-- `isUFree` and `isPastOnly` are identical predicates on the 6-constructor Formula type.
    Both forbid `untl` and permit `snce`, `box`, `imp`, `atom`, `bot`. -/
theorem u_free_eq_past_only (φ : Formula) : isUFree φ = isPastOnly φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 => simp [isUFree, isPastOnly, ih1, ih2]
  | box a ih => simp [isUFree, isPastOnly, ih]
  | untl _ _ => rfl
  | snce b a ih2 ih1 => simp [isUFree, isPastOnly, ih1, ih2]

/-- `isSyntacticallySeparated` and `isProperlySeparated` are identical predicates.
    At the `.untl` case, both require S-free/future-only arguments (equal by
    `s_free_eq_future_only`).
    At the `.snce` case, both require U-free/past-only arguments (equal by
    `u_free_eq_past_only`). -/
theorem syn_sep_eq_proper_sep (φ : Formula) :
    isSyntacticallySeparated φ = isProperlySeparated φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 => simp [isSyntacticallySeparated, isProperlySeparated, ih1, ih2]
  | box _ => rfl
  | untl b a _ _ => simp [isSyntacticallySeparated, isProperlySeparated, s_free_eq_future_only]
  | snce b a _ _ => simp [isSyntacticallySeparated, isProperlySeparated, u_free_eq_past_only]

/-- Corollary: a formula is separable iff it is properly separable. -/
theorem separable_iff_properly_separable (φ : Formula) :
    IsSeparable φ ↔ IsProperlySeparable φ := by
  constructor
  · rintro ⟨ψ, hsep, hequiv⟩
    exact ⟨ψ, (syn_sep_eq_proper_sep ψ) ▸ hsep, hequiv⟩
  · rintro ⟨ψ, hpsep, hequiv⟩
    exact ⟨ψ, (syn_sep_eq_proper_sep ψ).symm ▸ hpsep, hequiv⟩

end FormalSystem.Metalogic.WeakCanonical.Separation
