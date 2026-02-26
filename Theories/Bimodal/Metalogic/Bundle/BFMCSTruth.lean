import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# BMCS Truth Definition

This module defines truth evaluation within a Bundle of Maximal Consistent Sets (BMCS),
using Henkin-style semantics where box quantifies over bundled histories only.

## Key Insight

The crucial change from standard Kripke semantics is in the box case:
- **Standard**: `box φ` is true iff φ is true at ALL accessible worlds
- **BMCS**: `box φ` is true iff φ is true at ALL families IN THE BUNDLE

This restriction makes the truth lemma provable (the box case goes through)
while NOT weakening the completeness result. This is analogous to Henkin
semantics for higher-order logic.

## Main Definitions

- `bmcs_truth_at`: Truth of a formula at a specific family and time
- `bmcs_valid`: A formula is valid iff true at all families, times in all BMCS

## Main Results

- `bmcs_truth_neg`: Truth of negation
- `bmcs_truth_and`: Truth of conjunction
- `bmcs_truth_or`: Truth of disjunction
- `bmcs_truth_diamond`: Truth of diamond (possibility)

## Why This Doesn't Weaken Completeness

Completeness is an **existential** statement: If Γ is consistent, then there
exists a model satisfying Γ. The BMCS construction provides exactly ONE such
model. We don't need to characterize ALL models - just ONE satisfying model.

This is standard practice in mathematical logic (cf. Henkin models for HOL).

## References

- Research report: specs/812_canonical_model_completeness/reports/research-007.md
- Implementation plan: specs/812_canonical_model_completeness/plans/implementation-003.md
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

variable {D : Type*} [Preorder D]

/-!
## BMCS Truth Definition

The key definition is `bmcs_truth_at`, which evaluates formulas in a BMCS.

**Critical Design Decision**: The box case quantifies ONLY over families in the bundle,
not over all possible MCS families. This makes the truth lemma provable.
-/

/--
Truth of a formula at a specific family and time within a BMCS.

**Parameters**:
- `B`: The BMCS providing the bundle of families
- `fam`: The specific family at which we evaluate
- `t`: The time point at which we evaluate
- `φ`: The formula to evaluate

**Cases**:
- `atom p`: True iff the atom is in the MCS at (fam, t)
- `bot`: Always false
- `imp φ ψ`: True iff φ true implies ψ true (classical implication)
- `box φ`: True iff φ is true at ALL families in the bundle at time t
  (THIS IS THE KEY CHANGE - only quantifies over bundle families)
- `all_past φ`: True iff φ is true at all past times s ≤ t
- `all_future φ`: True iff φ is true at all future times s ≥ t

**Note on Temporal Semantics**:
We use NON-STRICT inequalities (≤, ≥) for temporal operators because the
proof system includes the T axioms (G φ → φ, H φ → φ), which require
reflexivity (the current time is both past and future of itself).
-/
def bmcs_truth_at (B : BMCS D) (fam : BFMCS D) (t : D) : Formula → Prop
  | Formula.atom p => Formula.atom p ∈ fam.mcs t
  | Formula.bot => False
  | Formula.imp φ ψ => bmcs_truth_at B fam t φ → bmcs_truth_at B fam t ψ
  | Formula.box φ => ∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ
  | Formula.all_past φ => ∀ s, s ≤ t → bmcs_truth_at B fam s φ
  | Formula.all_future φ => ∀ s, t ≤ s → bmcs_truth_at B fam s φ

/-!
## BMCS Validity

A formula is BMCS-valid if it's true at all families, times, and bundles.
-/

/--
BMCS validity: a formula is valid iff true everywhere in every BMCS.

This is the semantic notion for the Henkin-style completeness proof.
Completeness states: `bmcs_valid φ ↔ Derivable [] φ`
-/
def bmcs_valid (φ : Formula) : Prop :=
  ∀ (D : Type) [Preorder D],
  ∀ (B : BMCS D), ∀ fam ∈ B.families, ∀ t : D, bmcs_truth_at B fam t φ

/--
BMCS satisfiability: a formula is satisfiable in a BMCS at some family and time.
-/
def bmcs_satisfiable_at (B : BMCS D) (φ : Formula) : Prop :=
  ∃ fam ∈ B.families, ∃ t : D, bmcs_truth_at B fam t φ

/--
Context is satisfied in a BMCS at a given family and time.
-/
def bmcs_satisfies_context (B : BMCS D) (fam : BFMCS D) (t : D)
    (Γ : List Formula) : Prop :=
  ∀ γ ∈ Γ, bmcs_truth_at B fam t γ

/-!
## Basic Truth Properties

These lemmas establish the truth conditions for derived operators.
-/

/--
Truth of negation: `¬φ` is true iff `φ` is false.

Since `neg φ = φ → ⊥`, we have `bmcs_truth_at B fam t (neg φ) = (bmcs_truth_at B fam t φ → False)`.
-/
theorem bmcs_truth_neg (B : BMCS D) (fam : BFMCS D) (t : D) (φ : Formula) :
    bmcs_truth_at B fam t (Formula.neg φ) ↔ ¬bmcs_truth_at B fam t φ := by
  unfold Formula.neg
  simp only [bmcs_truth_at]

/--
Truth of conjunction: `φ ∧ ψ` is true iff both `φ` and `ψ` are true.

Since `and φ ψ = ¬(φ → ¬ψ)`, we need to unfold the definition.
-/
theorem bmcs_truth_and (B : BMCS D) (fam : BFMCS D) (t : D) (φ ψ : Formula) :
    bmcs_truth_at B fam t (Formula.and φ ψ) ↔
    bmcs_truth_at B fam t φ ∧ bmcs_truth_at B fam t ψ := by
  unfold Formula.and Formula.neg
  simp only [bmcs_truth_at]
  constructor
  · intro h
    by_contra h_neg
    simp only [not_and_or] at h_neg
    cases h_neg with
    | inl h_not_phi =>
      -- If ¬φ, then (φ → (ψ → ⊥)) holds vacuously, so (φ → (ψ → ⊥)) → False should give us False
      apply h
      intro hφ
      exact absurd hφ h_not_phi
    | inr h_not_psi =>
      -- If ¬ψ, then (φ → (ψ → ⊥)) implies (ψ → ⊥), which is true
      apply h
      intro _ hψ
      exact absurd hψ h_not_psi
  · intro ⟨hφ, hψ⟩
    intro h_imp
    exact h_imp hφ hψ

/--
Truth of disjunction: `φ ∨ ψ` is true iff `φ` or `ψ` is true.

Since `or φ ψ = ¬φ → ψ`, the truth condition is classical disjunction.
-/
theorem bmcs_truth_or (B : BMCS D) (fam : BFMCS D) (t : D) (φ ψ : Formula) :
    bmcs_truth_at B fam t (Formula.or φ ψ) ↔
    bmcs_truth_at B fam t φ ∨ bmcs_truth_at B fam t ψ := by
  unfold Formula.or Formula.neg
  simp only [bmcs_truth_at]
  constructor
  · intro h
    by_cases hφ : bmcs_truth_at B fam t φ
    · left; exact hφ
    · right; exact h hφ
  · intro h h_not_phi
    cases h with
    | inl hφ => exact absurd hφ h_not_phi
    | inr hψ => exact hψ

/--
Truth of diamond (possibility): `◇φ` is true iff `φ` is true at some family.

Since `diamond φ = ¬□¬φ`, this holds iff there exists a family where φ is true.
-/
theorem bmcs_truth_diamond (B : BMCS D) (fam : BFMCS D) (t : D) (φ : Formula) :
    bmcs_truth_at B fam t (Formula.diamond φ) ↔
    ∃ fam' ∈ B.families, bmcs_truth_at B fam' t φ := by
  unfold Formula.diamond Formula.neg
  simp only [bmcs_truth_at]
  constructor
  · intro h
    -- h : (∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ → False) → False
    by_contra h_no_witness
    push_neg at h_no_witness
    apply h
    intro fam' hfam' h_phi
    exact h_no_witness fam' hfam' h_phi
  · intro ⟨fam', hfam', hφ⟩ h_all
    exact h_all fam' hfam' hφ

/-!
## Monotonicity Properties

These lemmas show how truth behaves under various operations.
-/

/--
Truth at the evaluation family: shorthand for truth at B.eval_family.
-/
def bmcs_truth_eval (B : BMCS D) (t : D) (φ : Formula) : Prop :=
  bmcs_truth_at B B.eval_family t φ

/--
If φ is true at all families, then φ is true at the evaluation family.
-/
lemma bmcs_truth_eval_of_all (B : BMCS D) (t : D) (φ : Formula)
    (h : ∀ fam ∈ B.families, bmcs_truth_at B fam t φ) :
    bmcs_truth_eval B t φ :=
  h B.eval_family B.eval_family_mem

/-!
## Box Properties

The box operator has special properties due to the BMCS structure.
-/

/--
Box truth is independent of which family we evaluate at.

Since box quantifies over ALL families in the bundle, the result
doesn't depend on which specific family we're at.
-/
theorem bmcs_truth_box_family_independent (B : BMCS D)
    (fam1 fam2 : BFMCS D) (_ : fam1 ∈ B.families) (_ : fam2 ∈ B.families)
    (t : D) (φ : Formula) :
    bmcs_truth_at B fam1 t (Formula.box φ) ↔ bmcs_truth_at B fam2 t (Formula.box φ) := by
  -- Both are (∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ)
  constructor <;> (intro h; exact h)

/--
Box implies the formula at the same family (reflexivity / T axiom).
-/
theorem bmcs_truth_box_reflexive (B : BMCS D) (fam : BFMCS D)
    (hfam : fam ∈ B.families) (t : D) (φ : Formula)
    (h : bmcs_truth_at B fam t (Formula.box φ)) :
    bmcs_truth_at B fam t φ := by
  simp only [bmcs_truth_at] at h
  exact h fam hfam

/--
Box-box implies box (transitivity / 4 axiom).

In BMCS, □□φ and □φ have the same truth condition (universal over bundle).
-/
theorem bmcs_truth_box_transitive (B : BMCS D) (fam : BFMCS D)
    (_ : fam ∈ B.families) (t : D) (φ : Formula)
    (h : bmcs_truth_at B fam t (Formula.box (Formula.box φ))) :
    bmcs_truth_at B fam t (Formula.box φ) := by
  simp only [bmcs_truth_at] at h ⊢
  intro fam' hfam'
  exact h fam' hfam' fam' hfam'

/--
Necessitation: if φ is true everywhere, then □φ is true everywhere.
-/
theorem bmcs_truth_necessitation (B : BMCS D) (fam : BFMCS D)
    (t : D) (φ : Formula)
    (h : ∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ) :
    bmcs_truth_at B fam t (Formula.box φ) := by
  simp only [bmcs_truth_at]
  exact h

/-!
## Temporal Properties

The temporal operators have standard behavior with non-strict inequalities.
-/

/--
G (all_future) is reflexive: G φ → φ.

This follows because t ≤ t, so the current time is included in "all future".
-/
theorem bmcs_truth_all_future_reflexive (B : BMCS D) (fam : BFMCS D)
    (t : D) (φ : Formula)
    (h : bmcs_truth_at B fam t (Formula.all_future φ)) :
    bmcs_truth_at B fam t φ := by
  simp only [bmcs_truth_at] at h
  exact h t (le_refl t)

/--
H (all_past) is reflexive: H φ → φ.

This follows because t ≤ t, so the current time is included in "all past".
-/
theorem bmcs_truth_all_past_reflexive (B : BMCS D) (fam : BFMCS D)
    (t : D) (φ : Formula)
    (h : bmcs_truth_at B fam t (Formula.all_past φ)) :
    bmcs_truth_at B fam t φ := by
  simp only [bmcs_truth_at] at h
  exact h t (le_refl t)

/--
G is transitive: G φ → GG φ.
-/
theorem bmcs_truth_all_future_transitive (B : BMCS D) (fam : BFMCS D)
    (t : D) (φ : Formula)
    (h : bmcs_truth_at B fam t (Formula.all_future φ)) :
    bmcs_truth_at B fam t (Formula.all_future (Formula.all_future φ)) := by
  simp only [bmcs_truth_at] at h ⊢
  intro s hts u hsu
  exact h u (le_trans hts hsu)

/--
H is transitive: H φ → HH φ.
-/
theorem bmcs_truth_all_past_transitive (B : BMCS D) (fam : BFMCS D)
    (t : D) (φ : Formula)
    (h : bmcs_truth_at B fam t (Formula.all_past φ)) :
    bmcs_truth_at B fam t (Formula.all_past (Formula.all_past φ)) := by
  simp only [bmcs_truth_at] at h ⊢
  intro s hst u hus
  exact h u (le_trans hus hst)

/-!
## EvalBMCS Truth Definition

The EvalBMCS structure from CoherentConstruction.lean provides a weaker but sufficient
structure for completeness proofs. It guarantees:
- `modal_forward_eval`: Box phi in eval_family → phi in all families
- `modal_backward_eval`: phi in all families → Box phi in eval_family

This suffices for the truth lemma when evaluating at the eval_family.
-/

-- Import EvalBMCS from CoherentConstruction
-- Note: We define truth for EvalBMCS by reusing the same recursive definition
-- but the modal coherence properties are different.

/--
Truth of a formula at a specific family and time within an EvalBMCS.

**Parameters**:
- `B`: The EvalBMCS providing the bundle of families
- `fam`: The specific family at which we evaluate
- `t`: The time point at which we evaluate
- `φ`: The formula to evaluate

This mirrors `bmcs_truth_at` exactly - the semantic definition is the same.
The difference is in the structure (EvalBMCS vs BMCS) and what coherence properties hold.
-/
def eval_bmcs_truth_at (families : Set (BFMCS D))
    (fam : BFMCS D) (t : D) : Formula → Prop
  | Formula.atom p => Formula.atom p ∈ fam.mcs t
  | Formula.bot => False
  | Formula.imp φ ψ => eval_bmcs_truth_at families fam t φ → eval_bmcs_truth_at families fam t ψ
  | Formula.box φ => ∀ fam' ∈ families, eval_bmcs_truth_at families fam' t φ
  | Formula.all_past φ => ∀ s, s ≤ t → eval_bmcs_truth_at families fam s φ
  | Formula.all_future φ => ∀ s, t ≤ s → eval_bmcs_truth_at families fam s φ

/--
Context is satisfied in an EvalBMCS at a given family and time.
-/
def eval_bmcs_satisfies_context (families : Set (BFMCS D))
    (fam : BFMCS D) (t : D) (Γ : List Formula) : Prop :=
  ∀ γ ∈ Γ, eval_bmcs_truth_at families fam t γ

/-!
## EvalBMCS Truth Properties

These lemmas mirror the BMCS truth properties but for the EvalBMCS structure.
-/

/--
Truth of negation in EvalBMCS: `¬φ` is true iff `φ` is false.
-/
theorem eval_bmcs_truth_neg (families : Set (BFMCS D))
    (fam : BFMCS D) (t : D) (φ : Formula) :
    eval_bmcs_truth_at families fam t (Formula.neg φ) ↔
    ¬eval_bmcs_truth_at families fam t φ := by
  unfold Formula.neg
  simp only [eval_bmcs_truth_at]

/--
Truth of conjunction in EvalBMCS: `φ ∧ ψ` is true iff both `φ` and `ψ` are true.
-/
theorem eval_bmcs_truth_and (families : Set (BFMCS D))
    (fam : BFMCS D) (t : D) (φ ψ : Formula) :
    eval_bmcs_truth_at families fam t (Formula.and φ ψ) ↔
    eval_bmcs_truth_at families fam t φ ∧ eval_bmcs_truth_at families fam t ψ := by
  unfold Formula.and Formula.neg
  simp only [eval_bmcs_truth_at]
  constructor
  · intro h
    by_contra h_neg
    simp only [not_and_or] at h_neg
    cases h_neg with
    | inl h_not_phi =>
      apply h
      intro hφ
      exact absurd hφ h_not_phi
    | inr h_not_psi =>
      apply h
      intro _ hψ
      exact absurd hψ h_not_psi
  · intro ⟨hφ, hψ⟩
    intro h_imp
    exact h_imp hφ hψ

/--
Truth of disjunction in EvalBMCS: `φ ∨ ψ` is true iff `φ` or `ψ` is true.
-/
theorem eval_bmcs_truth_or (families : Set (BFMCS D))
    (fam : BFMCS D) (t : D) (φ ψ : Formula) :
    eval_bmcs_truth_at families fam t (Formula.or φ ψ) ↔
    eval_bmcs_truth_at families fam t φ ∨ eval_bmcs_truth_at families fam t ψ := by
  unfold Formula.or Formula.neg
  simp only [eval_bmcs_truth_at]
  constructor
  · intro h
    by_cases hφ : eval_bmcs_truth_at families fam t φ
    · left; exact hφ
    · right; exact h hφ
  · intro h h_not_phi
    cases h with
    | inl hφ => exact absurd hφ h_not_phi
    | inr hψ => exact hψ

/--
Truth of diamond (possibility) in EvalBMCS: `◇φ` is true iff `φ` is true at some family.
-/
theorem eval_bmcs_truth_diamond (families : Set (BFMCS D))
    (fam : BFMCS D) (t : D) (φ : Formula) :
    eval_bmcs_truth_at families fam t (Formula.diamond φ) ↔
    ∃ fam' ∈ families, eval_bmcs_truth_at families fam' t φ := by
  unfold Formula.diamond Formula.neg
  simp only [eval_bmcs_truth_at]
  constructor
  · intro h
    by_contra h_no_witness
    push_neg at h_no_witness
    apply h
    intro fam' hfam' h_phi
    exact h_no_witness fam' hfam' h_phi
  · intro ⟨fam', hfam', hφ⟩ h_all
    exact h_all fam' hfam' hφ

/--
Box truth is independent of which family we evaluate at in EvalBMCS.
-/
theorem eval_bmcs_truth_box_family_independent (families : Set (BFMCS D))
    (fam1 fam2 : BFMCS D) (_ : fam1 ∈ families) (_ : fam2 ∈ families)
    (t : D) (φ : Formula) :
    eval_bmcs_truth_at families fam1 t (Formula.box φ) ↔
    eval_bmcs_truth_at families fam2 t (Formula.box φ) := by
  constructor <;> (intro h; exact h)

/--
Box implies the formula at the same family (reflexivity / T axiom) in EvalBMCS.
-/
theorem eval_bmcs_truth_box_reflexive (families : Set (BFMCS D))
    (fam : BFMCS D) (hfam : fam ∈ families) (t : D) (φ : Formula)
    (h : eval_bmcs_truth_at families fam t (Formula.box φ)) :
    eval_bmcs_truth_at families fam t φ := by
  simp only [eval_bmcs_truth_at] at h
  exact h fam hfam

end Bimodal.Metalogic.Bundle
