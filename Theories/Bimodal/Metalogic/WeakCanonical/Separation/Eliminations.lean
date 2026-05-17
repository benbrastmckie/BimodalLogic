import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.NegationEquiv
import Bimodal.Metalogic.WeakCanonical.Separation.Distributivity
import Bimodal.Metalogic.WeakCanonical.Separation.IntHelpers

/-!
# Elimination Cases (GHR94 Lemma 10.2.3)

The eight elimination cases that form the core of the separation proof.
Each case eliminates a nested U from under an S, producing an equivalent
formula where U(A,B) appears only at top level (not under S).

## Key Results

- `elim_case_1`: S(a ^ U(A,B), q)
- `elim_case_2`: S(a ^ not U(A,B), q)
- `elim_case_3`: S(a, q v U(A,B))
- `elim_case_4`: S(a, q v not U(A,B))
- `elim_case_5`: S(a ^ U(A,B), q v U(A,B))
- `elim_case_6`: S(a ^ not U(A,B), q v U(A,B))
- `elim_case_7`: S(a ^ U(A,B), q v not U(A,B))
- `elim_case_8`: S(a ^ not U(A,B), q v not U(A,B))

## References

- GHR94, Lemma 10.2.3, pp. 572-580
- Research report Section 4.3
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax
open Classical

/-! ## Helper Lemmas -/

/-- Unfold int_truth for Formula.and to standard conjunction. -/
private theorem int_truth_and_iff {M : IntStructure} {t : ℤ} {φ ψ : Formula} :
    int_truth M t (Formula.and φ ψ) ↔ int_truth M t φ ∧ int_truth M t ψ := by
  show ((int_truth M t φ → int_truth M t ψ → False) → False) ↔ _
  constructor
  · intro h; exact ⟨byContradiction (fun hp => h (fun p _ => hp p)),
                    byContradiction (fun hq => h (fun _ q => hq q))⟩
  · rintro ⟨hp, hq⟩ h; exact h hp hq

/-- Unfold int_truth for Formula.or to standard disjunction. -/
private theorem int_truth_or_iff {M : IntStructure} {t : ℤ} {φ ψ : Formula} :
    int_truth M t (Formula.or φ ψ) ↔ int_truth M t φ ∨ int_truth M t ψ := by
  show ((int_truth M t φ → False) → int_truth M t ψ) ↔ _
  constructor
  · intro h; by_cases hp : int_truth M t φ; exact Or.inl hp; exact Or.inr (h hp)
  · rintro (hp | hq) hn; exact absurd hp hn; exact hq

/-- Unfold int_truth for Formula.neg to standard negation. -/
private theorem int_truth_neg_iff {M : IntStructure} {t : ℤ} {φ : Formula} :
    int_truth M t (Formula.neg φ) ↔ ¬ int_truth M t φ := by
  show (int_truth M t φ → False) ↔ ¬ int_truth M t φ
  exact Iff.rfl

/-- If a formula is both U-free and S-free, it is syntactically separated.
    Such formulas contain only atoms, bot, imp, box, all_past, all_future. -/
private theorem u_free_s_free_imp_separated (φ : Formula)
    (hu : is_U_free φ = true) (hs : is_S_free φ = true) :
    is_syntactically_separated φ = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_syntactically_separated, is_U_free, is_S_free] at *
    exact ⟨ih1 hu.1 hs.1, ih2 hu.2 hs.2⟩
  | box _ => rfl
  | all_past _ =>
    simp [is_syntactically_separated, is_U_free] at *; exact hu
  | all_future _ =>
    simp [is_syntactically_separated, is_S_free] at *; exact hs
  | untl _ _ => simp [is_U_free] at hu
  | snce _ _ => simp [is_S_free] at hs

/-! ## Case 1: S(a ^ U(A,B), q)

The three disjuncts correspond to the U(A,B)-witness being:
- u > t (future): Then B holds from s to u, covering (s,t); plus B at t; plus U(A,B) at t.
- u = t (present): A at t; B held from s to t.
- u < t (past): A was true at some u in (s,t); B held from s to u.
-/

/-- Target separated formula for Case 1. -/
private def case1_psi (a q A B : Formula) : Formula :=
  Formula.or (Formula.or
    (Formula.and (Formula.and (Formula.and (.snce a q) (.snce a B)) B) (.untl A B))
    (Formula.and (Formula.and A (.snce a B)) (.snce a q)))
    (.snce (Formula.and (Formula.and (Formula.and A q) (.snce a B)) (.snce a q)) q)

set_option maxHeartbeats 800000 in
/-- CASE 1: S(a ^ U(A,B), q) where a, q, A, B are U-free and S-free.

    Equivalent to:
      [S(a, q) ^ S(a, B) ^ B ^ U(A,B)]     -- U-witness after t
      v [A ^ S(a, B) ^ S(a, q)]              -- U-witness AT t
      v S(A ^ q ^ S(a, B) ^ S(a, q), q)     -- U-witness before t

    The output formula has U(A,B) only at top level. -/
theorem elim_case_1 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (.untl A B)) q) psi ∧
      is_syntactically_separated psi = true := by
  refine ⟨case1_psi a q A B, ?_, ?_⟩
  · -- Semantic equivalence
    intro M t
    simp only [case1_psi]
    constructor
    · -- Forward: S(a ^ U(A,B), q) -> RHS
      intro ⟨s, hst, hand, hq_guard⟩
      have ⟨ha_s, huntl⟩ := int_truth_and_iff.mp hand
      obtain ⟨u, hsu, hAu, hB_guard⟩ := huntl
      rcases lt_trichotomy u t with hut | hut | hut
      · -- u < t: third disjunct (U-witness before t)
        apply int_truth_or_iff.mpr; right
        refine ⟨u, hut, ?_, fun r hur hrt => hq_guard r (lt_trans hsu hur) hrt⟩
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨⟨hAu, hq_guard u hsu hut⟩, ⟨s, hsu, ha_s, hB_guard⟩⟩,
               ⟨s, hsu, ha_s, fun r hsr hru => hq_guard r hsr (lt_trans hru hut)⟩⟩
      · -- u = t: second disjunct (U-witness AT t)
        subst hut
        apply int_truth_or_iff.mpr; left
        apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨hAu, ⟨s, hst, ha_s, hB_guard⟩⟩, ⟨s, hst, ha_s, hq_guard⟩⟩
      · -- u > t: first disjunct (U-witness after t)
        apply int_truth_or_iff.mpr; left
        apply int_truth_or_iff.mpr; left
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨⟨⟨s, hst, ha_s, hq_guard⟩,
               ⟨s, hst, ha_s, fun r hsr hrt => hB_guard r hsr (lt_trans hrt hut)⟩⟩,
               hB_guard t hst hut⟩,
               ⟨u, hut, hAu, fun r htr hru => hB_guard r (lt_trans hst htr) hru⟩⟩
    · -- Backward: RHS -> S(a ^ U(A,B), q)
      intro hrhs
      rcases int_truth_or_iff.mp hrhs with h12 | h3
      · rcases int_truth_or_iff.mp h12 with hd1 | hd2
        · -- d1: S(a,q) ^ S(a,B) ^ B(t) ^ U(A,B)(t)
          rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff] at hd1
          obtain ⟨⟨⟨⟨s₁, hs₁t, ha₁, hq₁⟩, ⟨s₂, hs₂t, ha₂, hB₂⟩⟩, hBt⟩,
                  ⟨u, htu, hAu, hBu⟩⟩ := hd1
          by_cases hle : s₁ ≤ s₂
          · refine ⟨s₂, hs₂t, int_truth_and_iff.mpr ⟨ha₂,
              u, lt_trans hs₂t htu, hAu, fun r hrs hru => ?_⟩,
              fun r hrs hrt => hq₁ r (lt_of_le_of_lt hle hrs) hrt⟩
            rcases lt_trichotomy r t with hrt | hrt | hrt
            · exact hB₂ r hrs hrt
            · exact hrt ▸ hBt
            · exact hBu r hrt hru
          · push_neg at hle
            refine ⟨s₁, hs₁t, int_truth_and_iff.mpr ⟨ha₁,
              u, lt_trans hs₁t htu, hAu, fun r hrs hru => ?_⟩, hq₁⟩
            rcases lt_trichotomy r t with hrt | hrt | hrt
            · exact hB₂ r (lt_trans hle hrs) hrt
            · exact hrt ▸ hBt
            · exact hBu r hrt hru
        · -- d2: A(t) ^ S(a,B) ^ S(a,q)
          rw [int_truth_and_iff, int_truth_and_iff] at hd2
          obtain ⟨⟨hAt, ⟨s₁, hs₁t, ha₁, hB₁⟩⟩, ⟨s₂, hs₂t, ha₂, hq₂⟩⟩ := hd2
          by_cases hle : s₁ ≤ s₂
          · exact ⟨s₂, hs₂t, int_truth_and_iff.mpr ⟨ha₂,
              t, hs₂t, hAt, fun r hrs hrt => hB₁ r (lt_of_le_of_lt hle hrs) hrt⟩, hq₂⟩
          · push_neg at hle
            exact ⟨s₁, hs₁t, int_truth_and_iff.mpr ⟨ha₁, t, hs₁t, hAt, hB₁⟩,
              fun r hr1 hr2 => hq₂ r (lt_trans hle hr1) hr2⟩
      · -- d3: S(A ^ q ^ S(a,B) ^ S(a,q), q)
        obtain ⟨w, hwt, hw_and, hq_rest⟩ := h3
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff] at hw_and
        obtain ⟨⟨⟨hAw, hqw⟩, ⟨s₁, hs₁w, ha₁, hB₁⟩⟩, ⟨s₂, hs₂w, ha₂, hq₂⟩⟩ := hw_and
        by_cases hle : s₁ ≤ s₂
        · refine ⟨s₂, lt_trans hs₂w hwt, int_truth_and_iff.mpr ⟨ha₂,
            w, hs₂w, hAw, fun r hrs hrw => hB₁ r (lt_of_le_of_lt hle hrs) hrw⟩,
            fun r hrs hrt => ?_⟩
          rcases lt_trichotomy r w with hrw | hrw | hrw
          · exact hq₂ r hrs hrw
          · exact hrw ▸ hqw
          · exact hq_rest r hrw hrt
        · push_neg at hle
          refine ⟨s₁, lt_trans hs₁w hwt, int_truth_and_iff.mpr ⟨ha₁,
            w, hs₁w, hAw, hB₁⟩, fun r hrs hrt => ?_⟩
          rcases lt_trichotomy r w with hrw | hrw | hrw
          · exact hq₂ r (lt_trans hle hrs) hrw
          · exact hrw ▸ hqw
          · exact hq_rest r hrw hrt
  · -- Separation check
    simp [case1_psi, Formula.and, Formula.or, Formula.neg,
          is_syntactically_separated, is_U_free, ha, hq, hA, hB, hA', hB']
    exact ⟨u_free_s_free_imp_separated B hB hB',
           u_free_s_free_imp_separated A hA hA'⟩

/-! ## Case 5: S(a ^ U(A,B), q v U(A,B))

Split on whether the U-witness is in the past, present, or future of t.
-/

/-- CASE 5: S(a ^ U(A,B), q v U(A,B)) where a, q, A, B are U-free and S-free.

    This case is more complex than Case 1 because the guard also contains U(A,B).
    The key observation is that if U(A,B) holds at r (between s and t), then
    the guard is satisfied at r regardless of q.

    The output formula has U(A,B) only at top level. -/
theorem elim_case_5 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (.untl A B)) (Formula.or q (.untl A B))) psi ∧
      is_syntactically_separated psi = true := by
  sorry

/-! ## Case 2: S(a ^ not U(A,B), q) -/

/-- CASE 2: S(a ^ not U(A,B), q).
    Strategy: apply neg_until_equiv to rewrite not U(A,B), then reduce. -/
theorem elim_case_2 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (Formula.neg (.untl A B))) q) psi ∧
      is_syntactically_separated psi = true := by
  sorry

/-! ## Case 4: S(a, q v not U(A,B)) -/

/-- CASE 4: S(a, q v not U(A,B)).
    Strategy: direct semantic argument about the "safe zone". -/
theorem elim_case_4 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce a (Formula.or q (Formula.neg (.untl A B)))) psi ∧
      is_syntactically_separated psi = true := by
  sorry

/-! ## Case 3: S(a, q v U(A,B)) -/

/-- CASE 3: S(a, q v U(A,B)).
    Strategy: negate, use 10.2.2, apply Case 2. -/
theorem elim_case_3 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce a (Formula.or q (.untl A B))) psi ∧
      is_syntactically_separated psi = true := by
  sorry

/-! ## Case 6: S(a ^ not U(A,B), q v U(A,B)) -/

/-- CASE 6: S(a ^ not U(A,B), q v U(A,B)).
    Strategy: reduces to Cases 3, 5. -/
theorem elim_case_6 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (Formula.neg (.untl A B)))
        (Formula.or q (.untl A B))) psi ∧
      is_syntactically_separated psi = true := by
  sorry

/-! ## Case 7: S(a ^ U(A,B), q v not U(A,B)) -/

/-- CASE 7: S(a ^ U(A,B), q v not U(A,B)).
    Strategy: reduces to Cases 4, 8. -/
theorem elim_case_7 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (.untl A B))
        (Formula.or q (Formula.neg (.untl A B)))) psi ∧
      is_syntactically_separated psi = true := by
  sorry

/-! ## Case 8: S(a ^ not U(A,B), q v not U(A,B)) -/

/-- CASE 8: S(a ^ not U(A,B), q v not U(A,B)).
    Strategy: negate, reduce to Case 5. -/
theorem elim_case_8 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (Formula.neg (.untl A B)))
        (Formula.or q (Formula.neg (.untl A B)))) psi ∧
      is_syntactically_separated psi = true := by
  sorry

end Bimodal.Metalogic.WeakCanonical.Separation
