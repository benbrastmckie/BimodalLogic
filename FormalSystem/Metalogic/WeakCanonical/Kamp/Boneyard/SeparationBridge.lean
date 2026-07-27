import FormalSystem.Metalogic.WeakCanonical.PriorDefs

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# GHR94 Lemma 10.2.2 on Prior Structures

The GHR94 negation equivalences for Until/Since hold on Prior structures
(satisfying Prior-UZ/SZ), not just on integer time. This is because
Prior-UZ/SZ provides the same "first/last occurrence" property that
integer discreteness provides.

## Key Results

- `neg_until_equiv_prior`: ¬U(A,B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A) on Prior-UZ structures
- `neg_since_equiv_prior`: ¬S(A,B) ↔ H(¬A) ∨ S(¬A ∧ ¬B, ¬A) on Prior-SZ structures

## References

- GHR94, Lemma 10.2.2 (negation of Until/Since over integer time)
- The proofs here adapt the integer argument using Prior-UZ/SZ instead of discreteness
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Helper: temporal_truth of negation -/

private theorem temporal_truth_neg' {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (t : M.carrier) (φ : Formula) :
    temporal_truth M atomMap t φ.neg ↔ ¬ temporal_truth M atomMap t φ := by
  simp only [Formula.neg, temporal_truth]

/-! ## GHR94 Lemma 10.2.2: Negation of Until on Prior Structures

On structures satisfying Prior-UZ:
  ¬U(A, B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A)

The forward direction (G(¬A) ∨ U(¬A ∧ ¬B, ¬A) → ¬U(A,B)) holds on ALL
linear orders. The backward direction (¬U(A,B) → G(¬A) ∨ U(¬A ∧ ¬B, ¬A))
uses Prior-UZ: if ¬G(¬A) (i.e., A holds somewhere in the future), then
Prior-UZ gives the FIRST occurrence of A, and the argument constructs the
U(¬A ∧ ¬B, ¬A) witness from this first occurrence. -/

/-- Forward: G(¬A) → ¬U(A,B). Universal (no Prior hypothesis needed). -/
private theorem g_neg_implies_neg_until {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (t : M.carrier) (A B : Formula)
    (h_g : ∀ s : M.carrier, t < s → ¬ temporal_truth M atomMap s A) :
    ¬ temporal_truth M atomMap t (.untl A B) := by
  intro ⟨s, hts, hAs, _⟩
  exact h_g s hts hAs

/-- Forward: U(¬A ∧ ¬B, ¬A) → ¬U(A,B). Universal (no Prior hypothesis needed). -/
private theorem u_neg_conj_implies_neg_until {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (t : M.carrier) (A B : Formula)
    (h_u : ∃ s : M.carrier, t < s ∧
      (¬ temporal_truth M atomMap s A ∧ ¬ temporal_truth M atomMap s B) ∧
      (∀ r : M.carrier, t < r → r < s → ¬ temporal_truth M atomMap r A)) :
    ¬ temporal_truth M atomMap t (.untl A B) := by
  obtain ⟨s₀, hts₀, ⟨h_nA_s₀, h_nB_s₀⟩, h_guard⟩ := h_u
  intro ⟨s, hts, hAs, hBguard⟩
  -- s₀ is a witness for U(¬A ∧ ¬B, ¬A): ¬A on (t, s₀) and ¬A ∧ ¬B at s₀
  -- s is a witness for U(A, B): A at s and B on (t, s)
  -- Case split: s ≤ s₀ or s₀ < s
  by_cases h : s ≤ s₀
  · -- s ≤ s₀: then s ∈ (t, s₀] so ¬A(s) by guard or at s₀
    rcases lt_or_eq_of_le h with h_lt | h_eq
    · exact h_guard s hts h_lt hAs
    · subst h_eq; exact h_nA_s₀ hAs
  · -- s₀ < s: s₀ ∈ (t, s) so B(s₀) must hold, contradicting ¬B(s₀)
    push_neg at h
    exact h_nB_s₀ (hBguard s₀ hts₀ h)

/-- Backward: ¬U(A,B) → G(¬A) ∨ U(¬A ∧ ¬B, ¬A) on Prior-UZ structures.

    Uses Prior-UZ: if A holds somewhere in the future, get the FIRST
    occurrence s₁ of A above t. Then ¬A on (t, s₁). Since ¬U(A,B) and
    A(s₁), there must be r ∈ (t, s₁) with ¬B(r). This r also has ¬A(r)
    (since r < s₁ and s₁ is first A point). So r witnesses U(¬A ∧ ¬B, ¬A). -/
private theorem neg_until_backward_prior {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (t : M.carrier) (A B : Formula)
    (h_neg : ¬ temporal_truth M atomMap t (.untl A B)) :
    (∀ s : M.carrier, t < s → ¬ temporal_truth M atomMap s A) ∨
    (∃ s : M.carrier, t < s ∧
      (¬ temporal_truth M atomMap s A ∧ ¬ temporal_truth M atomMap s B) ∧
      (∀ r : M.carrier, t < r → r < s → ¬ temporal_truth M atomMap r A)) := by
  -- Either G(¬A) holds or A holds somewhere in the future
  by_cases h_exists_A : ∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s A
  · -- A holds somewhere in the future. Use Prior-UZ to get first occurrence.
    right
    -- Prior-UZ gives first occurrence of A above t
    -- We apply it via the temporal_truth level: A as a temporal formula
    -- Prior-UZ: if F(A) at t, then there exists first s₁ > t with A(s₁)
    --   and ¬A on (t, s₁) (encoded as A.neg holds on (t, s₁))
    obtain ⟨s₁, hts₁, hAs₁, h_neg_between⟩ := h_UZ t A h_exists_A
    -- h_neg_between: ∀ r, t < r → r < s₁ → temporal_truth M atomMap r A.neg
    -- Since ¬U(A,B) at t and A(s₁), we need ∃r ∈ (t, s₁) with ¬B(r)
    have h_neg_B_witness : ∃ r : M.carrier, t < r ∧ r < s₁ ∧
        ¬ temporal_truth M atomMap r B := by
      -- From ¬U(A,B): for all s > t, ¬A(s) or ∃r ∈ (t,s) with ¬B(r)
      -- Apply to s₁: A(s₁) holds, so ∃r ∈ (t, s₁) with ¬B(r)
      by_contra h_all_B
      push_neg at h_all_B
      -- h_all_B: ∀ r, t < r → r < s₁ → temporal_truth M atomMap r B
      apply h_neg
      exact ⟨s₁, hts₁, hAs₁, fun r htr hrs₁ => h_all_B r htr hrs₁⟩
    obtain ⟨r₀, htr₀, hr₀s₁, h_nB_r₀⟩ := h_neg_B_witness
    -- r₀ ∈ (t, s₁) with ¬B(r₀). Also ¬A(r₀) since r₀ < s₁ (first A point)
    have h_nA_r₀ : ¬ temporal_truth M atomMap r₀ A := by
      have := h_neg_between r₀ htr₀ hr₀s₁
      exact (temporal_truth_neg' M atomMap r₀ A).mp this
    -- r₀ witnesses U(¬A ∧ ¬B, ¬A): ¬A ∧ ¬B at r₀, ¬A on (t, r₀)
    exact ⟨r₀, htr₀, ⟨h_nA_r₀, h_nB_r₀⟩, fun r htr hrs =>
      (temporal_truth_neg' M atomMap r A).mp
        (h_neg_between r htr (lt_trans hrs hr₀s₁))⟩
  · -- G(¬A): A never holds in the future
    left
    push_neg at h_exists_A
    exact h_exists_A

/-- GHR94 Lemma 10.2.2 (first equivalence) on Prior structures:
    ¬U(A,B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A)

    Here G(¬A) = ∀s > t, ¬A(s) and U(¬A ∧ ¬B, ¬A) uses the usual Until semantics.
    The equivalence holds on any structure satisfying semantic_prior_UZ. -/
theorem neg_until_equiv_prior {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (t : M.carrier) (A B : Formula) :
    ¬ temporal_truth M atomMap t (.untl A B) ↔
    ((∀ s : M.carrier, t < s → ¬ temporal_truth M atomMap s A) ∨
     (∃ s : M.carrier, t < s ∧
       (¬ temporal_truth M atomMap s A ∧ ¬ temporal_truth M atomMap s B) ∧
       (∀ r : M.carrier, t < r → r < s → ¬ temporal_truth M atomMap r A))) := by
  constructor
  · exact neg_until_backward_prior M atomMap h_UZ t A B
  · intro h
    rcases h with h_g | h_u
    · exact g_neg_implies_neg_until M atomMap t A B h_g
    · exact u_neg_conj_implies_neg_until M atomMap t A B h_u

/-- GHR94 Lemma 10.2.2 (second equivalence, dual) on Prior structures:
    ¬S(A,B) ↔ H(¬A) ∨ S(¬A ∧ ¬B, ¬A)

    Dual of `neg_until_equiv_prior`, using Prior-SZ. -/
theorem neg_since_equiv_prior {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) (A B : Formula) :
    ¬ temporal_truth M atomMap t (.snce A B) ↔
    ((∀ s : M.carrier, s < t → ¬ temporal_truth M atomMap s A) ∨
     (∃ s : M.carrier, s < t ∧
       (¬ temporal_truth M atomMap s A ∧ ¬ temporal_truth M atomMap s B) ∧
       (∀ r : M.carrier, s < r → r < t → ¬ temporal_truth M atomMap r A))) := by
  constructor
  · -- Backward: ¬S(A,B) → H(¬A) ∨ S(¬A ∧ ¬B, ¬A). Dual of Until case.
    intro h_neg
    by_cases h_exists_A : ∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s A
    · right
      obtain ⟨s₁, hs₁t, hAs₁, h_neg_between⟩ := h_SZ t A h_exists_A
      have h_neg_B_witness : ∃ r : M.carrier, s₁ < r ∧ r < t ∧
          ¬ temporal_truth M atomMap r B := by
        by_contra h_all_B
        push_neg at h_all_B
        apply h_neg
        exact ⟨s₁, hs₁t, hAs₁, fun r hsr hrt => h_all_B r hsr hrt⟩
      obtain ⟨r₀, hs₁r₀, hr₀t, h_nB_r₀⟩ := h_neg_B_witness
      have h_nA_r₀ : ¬ temporal_truth M atomMap r₀ A :=
        (temporal_truth_neg' M atomMap r₀ A).mp (h_neg_between r₀ hs₁r₀ hr₀t)
      exact ⟨r₀, hr₀t, ⟨h_nA_r₀, h_nB_r₀⟩, fun r hsr hrs =>
        (temporal_truth_neg' M atomMap r A).mp
          (h_neg_between r (lt_trans hs₁r₀ hsr) hrs)⟩
    · left
      push_neg at h_exists_A
      exact h_exists_A
  · -- Forward: H(¬A) ∨ S(¬A ∧ ¬B, ¬A) → ¬S(A,B). Universal.
    intro h
    rcases h with h_h | ⟨s₀, hs₀t, ⟨h_nA_s₀, h_nB_s₀⟩, h_guard⟩
    · -- H(¬A) → ¬S(A,B)
      intro ⟨s, hst, hAs, _⟩
      exact h_h s hst hAs
    · -- S(¬A ∧ ¬B, ¬A) → ¬S(A,B)
      intro ⟨s, hst, hAs, hBguard⟩
      by_cases h : s₀ ≤ s
      · rcases lt_or_eq_of_le h with h_lt | h_eq
        · exact h_guard s h_lt hst hAs
        · subst h_eq; exact h_nA_s₀ hAs
      · push_neg at h
        exact h_nB_s₀ (hBguard s₀ h hs₀t)

end Bimodal.Metalogic.WeakCanonical.Kamp
