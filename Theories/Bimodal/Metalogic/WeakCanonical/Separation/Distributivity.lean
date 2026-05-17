import Bimodal.Metalogic.WeakCanonical.Separation.Defs

/-!
# Distributivity Laws (GHR94 Lemma 10.2.1)

U and S distribute over boolean connectives. These are valid over ALL
linear flows of time (not just integers).

## Key Results

- `until_distrib_or_left`: U(A v B, C) <-> U(A,C) v U(B,C)
- `since_distrib_or_left`: S(A v B, C) <-> S(A,C) v S(B,C)
- `until_distrib_and_right`: U(A, B ^ C) <-> U(A,B) ^ U(A,C)
- `since_distrib_and_right`: S(A, B ^ C) <-> S(A,B) ^ S(A,C)

## References

- GHR94, Lemma 10.2.1, p. 571
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Helper: or/and unfolding

  or A B = neg A -> B = (A -> bot) -> B
  and A B = neg (A -> neg B) = (A -> (B -> bot)) -> bot
  neg A = A -> bot

  int_truth M t (or A B) = (int_truth M t A -> False) -> int_truth M t B
  int_truth M t (and A B) = ((int_truth M t A -> (int_truth M t B -> False)) -> False)
-/

/-! ## Left Distributivity (Event over Disjunction) -/

/-- U distributes over disjunction in the event (first) argument.
    U(A v B, C) <-> U(A,C) v U(B,C)
    Valid over all linear time. -/
theorem until_distrib_or_left (A B C : Formula) :
    int_equiv (.untl (Formula.or A B) C) (Formula.or (.untl A C) (.untl B C)) := by
  intro M t
  -- Unfold: or X Y at truth level means (not X -> Y), i.e., (X_truth -> False) -> Y_truth
  show (∃ s, t < s ∧ ((int_truth M s A → False) → int_truth M s B) ∧
        ∀ r, t < r → r < s → int_truth M r C) ↔
       ((∃ s, t < s ∧ int_truth M s A ∧ ∀ r, t < r → r < s → int_truth M r C) → False) →
        (∃ s, t < s ∧ int_truth M s B ∧ ∀ r, t < r → r < s → int_truth M r C)
  constructor
  · rintro ⟨s, hts, hAB, hguard⟩ h_not_UA
    have hnotA : ¬ int_truth M s A := fun hA => h_not_UA ⟨s, hts, hA, hguard⟩
    exact ⟨s, hts, hAB hnotA, hguard⟩
  · intro h_or
    by_cases hUA : ∃ s, t < s ∧ int_truth M s A ∧ ∀ r, t < r → r < s → int_truth M r C
    · obtain ⟨s, hts, hA, hC⟩ := hUA
      exact ⟨s, hts, fun hnotA => absurd hA hnotA, hC⟩
    · obtain ⟨s, hts, hB, hC⟩ := h_or hUA
      exact ⟨s, hts, fun _ => hB, hC⟩

/-- S distributes over disjunction in the event (first) argument.
    S(A v B, C) <-> S(A,C) v S(B,C)
    Valid over all linear time. -/
theorem since_distrib_or_left (A B C : Formula) :
    int_equiv (.snce (Formula.or A B) C) (Formula.or (.snce A C) (.snce B C)) := by
  intro M t
  show (∃ s, s < t ∧ ((int_truth M s A → False) → int_truth M s B) ∧
        ∀ r, s < r → r < t → int_truth M r C) ↔
       ((∃ s, s < t ∧ int_truth M s A ∧ ∀ r, s < r → r < t → int_truth M r C) → False) →
        (∃ s, s < t ∧ int_truth M s B ∧ ∀ r, s < r → r < t → int_truth M r C)
  constructor
  · rintro ⟨s, hst, hAB, hguard⟩ h_not_SA
    have hnotA : ¬ int_truth M s A := fun hA => h_not_SA ⟨s, hst, hA, hguard⟩
    exact ⟨s, hst, hAB hnotA, hguard⟩
  · intro h_or
    by_cases hSA : ∃ s, s < t ∧ int_truth M s A ∧ ∀ r, s < r → r < t → int_truth M r C
    · obtain ⟨s, hst, hA, hC⟩ := hSA
      exact ⟨s, hst, fun hnotA => absurd hA hnotA, hC⟩
    · obtain ⟨s, hst, hB, hC⟩ := h_or hSA
      exact ⟨s, hst, fun _ => hB, hC⟩

/-! ## Right Distributivity (Guard over Conjunction) -/

/-- U distributes over conjunction in the guard (second) argument.
    U(A, B ^ C) <-> U(A,B) ^ U(A,C)

    The (→) direction is straightforward.
    The (←) direction requires linearity: take s = min(s1, s2) where s1, s2
    are witnesses for U(A,B) and U(A,C) respectively.

    Note: this uses LINEARITY of the time order but NOT discreteness. -/
theorem until_distrib_and_right (A B C : Formula) :
    int_equiv (.untl A (Formula.and B C)) (Formula.and (.untl A B) (.untl A C)) := by
  intro M t
  -- and X Y truth = ((X_truth -> (Y_truth -> False)) -> False)
  show (∃ s, t < s ∧ int_truth M s A ∧
        ∀ r, t < r → r < s →
          ((int_truth M r B → (int_truth M r C → False)) → False)) ↔
       ((∃ s, t < s ∧ int_truth M s A ∧ ∀ r, t < r → r < s → int_truth M r B) →
        ((∃ s, t < s ∧ int_truth M s A ∧ ∀ r, t < r → r < s → int_truth M r C) → False)) →
       False
  constructor
  · -- (→): from U(A, B^C) derive U(A,B) ∧ U(A,C) (encoded as ¬(U(A,B) → ¬U(A,C)))
    rintro ⟨s, hts, hA, hBC⟩
    intro h_imp
    apply h_imp
    · -- U(A,B): same witness s, extract B from B∧C
      exact ⟨s, hts, hA, fun r hr1 hr2 => by
        have := hBC r hr1 hr2
        by_contra hnotB
        exact this (fun hB _ => hnotB hB)⟩
    · -- U(A,C): same witness s, extract C from B∧C
      exact ⟨s, hts, hA, fun r hr1 hr2 => by
        have := hBC r hr1 hr2
        by_contra hnotC
        exact this (fun _ hC => hnotC hC)⟩
  · -- (←): from U(A,B) ∧ U(A,C) derive U(A, B^C)
    -- Need linearity argument (take min of witnesses)
    intro h_and
    -- h_and : ¬(U(A,B) → ¬U(A,C))
    -- This means U(A,B) and U(A,C) both hold
    by_contra h_not
    apply h_and
    intro ⟨s1, hts1, hA1, hB⟩
    intro ⟨s2, hts2, hA2, hC⟩
    -- Take s = min s1 s2. A holds at s (either s1 or s2).
    -- B holds on (t, s1) so on (t, min s1 s2).
    -- C holds on (t, s2) so on (t, min s1 s2).
    apply h_not
    by_cases hle : s1 ≤ s2
    · -- Use s1 as witness
      exact ⟨s1, hts1, hA1, fun r hr1 hr2 => by
        intro h_imp_BC
        apply h_imp_BC
        · exact hB r hr1 hr2
        · exact hC r hr1 (lt_of_lt_of_le hr2 hle)⟩
    · -- Use s2 as witness
      push_neg at hle
      exact ⟨s2, hts2, hA2, fun r hr1 hr2 => by
        intro h_imp_BC
        apply h_imp_BC
        · exact hB r hr1 (lt_trans hr2 hle)
        · exact hC r hr1 hr2⟩

/-- S distributes over conjunction in the guard (second) argument.
    S(A, B ^ C) <-> S(A,B) ^ S(A,C)
    Dual of until_distrib_and_right; uses the same linearity argument. -/
theorem since_distrib_and_right (A B C : Formula) :
    int_equiv (.snce A (Formula.and B C)) (Formula.and (.snce A B) (.snce A C)) := by
  intro M t
  show (∃ s, s < t ∧ int_truth M s A ∧
        ∀ r, s < r → r < t →
          ((int_truth M r B → (int_truth M r C → False)) → False)) ↔
       ((∃ s, s < t ∧ int_truth M s A ∧ ∀ r, s < r → r < t → int_truth M r B) →
        ((∃ s, s < t ∧ int_truth M s A ∧ ∀ r, s < r → r < t → int_truth M r C) → False)) →
       False
  constructor
  · rintro ⟨s, hst, hA, hBC⟩
    intro h_imp
    apply h_imp
    · exact ⟨s, hst, hA, fun r hr1 hr2 => by
        have := hBC r hr1 hr2
        by_contra hnotB
        exact this (fun hB _ => hnotB hB)⟩
    · exact ⟨s, hst, hA, fun r hr1 hr2 => by
        have := hBC r hr1 hr2
        by_contra hnotC
        exact this (fun _ hC => hnotC hC)⟩
  · intro h_and
    by_contra h_not
    apply h_and
    intro ⟨s1, hst1, hA1, hB⟩
    intro ⟨s2, hst2, hA2, hC⟩
    apply h_not
    by_cases hle : s2 ≤ s1
    · -- Use s1 as witness (s1 >= s2, so (s1, t) subset of (s2, t))
      exact ⟨s1, hst1, hA1, fun r hr1 hr2 => by
        intro h_imp_BC
        apply h_imp_BC
        · exact hB r hr1 hr2
        · exact hC r (lt_of_le_of_lt hle hr1) hr2⟩
    · -- Use s2 as witness
      push_neg at hle
      exact ⟨s2, hst2, hA2, fun r hr1 hr2 => by
        intro h_imp_BC
        apply h_imp_BC
        · exact hB r (lt_trans hle hr1) hr2
        · exact hC r hr1 hr2⟩

end Bimodal.Metalogic.WeakCanonical.Separation
