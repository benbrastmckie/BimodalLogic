import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.NegationEquiv
import Bimodal.Metalogic.WeakCanonical.Separation.Distributivity
import Bimodal.Metalogic.WeakCanonical.Separation.IntHelpers

/-!
# Elimination Cases (GHR94 Lemma 10.2.3)

The eight elimination cases that form the core of the separation proof.
Each case eliminates a nested U from under an S, producing an equivalent
formula where U(A,B) appears only at top level (not under S).

## References

- GHR94, Lemma 10.2.3, pp. 572-580
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax
open Classical

/-! ## Helper Lemmas -/

theorem int_truth_and_iff {M : IntStructure} {t : ℤ} {φ ψ : Formula} :
    int_truth M t (Formula.and φ ψ) ↔ int_truth M t φ ∧ int_truth M t ψ := by
  show ((int_truth M t φ → int_truth M t ψ → False) → False) ↔ _
  constructor
  · intro h; exact ⟨byContradiction (fun hp => h (fun p _ => hp p)),
                    byContradiction (fun hq => h (fun _ q => hq q))⟩
  · rintro ⟨hp, hq⟩ h; exact h hp hq

theorem int_truth_or_iff {M : IntStructure} {t : ℤ} {φ ψ : Formula} :
    int_truth M t (Formula.or φ ψ) ↔ int_truth M t φ ∨ int_truth M t ψ := by
  show ((int_truth M t φ → False) → int_truth M t ψ) ↔ _
  constructor
  · intro h; by_cases hp : int_truth M t φ; exact Or.inl hp; exact Or.inr (h hp)
  · rintro (hp | hq) hn; exact absurd hp hn; exact hq

theorem int_truth_neg_iff {M : IntStructure} {t : ℤ} {φ : Formula} :
    int_truth M t (Formula.neg φ) ↔ ¬ int_truth M t φ := Iff.rfl

theorem u_free_s_free_imp_separated (φ : Formula)
    (hu : is_U_free φ = true) (hs : is_S_free φ = true) :
    is_syntactically_separated φ = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_syntactically_separated, is_U_free, is_S_free] at *
    exact ⟨ih1 hu.1 hs.1, ih2 hu.2 hs.2⟩
  | box _ => rfl
  | untl _ _ => simp [is_U_free] at hu
  | snce _ _ => simp [is_S_free] at hs

/-- U-free + S-free → separable. Public version for use across files. -/
theorem u_free_s_free_is_separable (φ : Formula)
    (hu : is_U_free φ = true) (hs : is_S_free φ = true) :
    is_separable φ :=
  ⟨φ, u_free_s_free_imp_separated φ hu hs, int_equiv_refl φ⟩

private theorem neg_separated {φ : Formula} (h : is_syntactically_separated φ = true) :
    is_syntactically_separated (Formula.neg φ) = true := by
  simp [Formula.neg, is_syntactically_separated, h]

private theorem and_separated {φ ψ : Formula}
    (h1 : is_syntactically_separated φ = true) (h2 : is_syntactically_separated ψ = true) :
    is_syntactically_separated (Formula.and φ ψ) = true := by
  simp [Formula.and, Formula.neg, is_syntactically_separated, h1, h2]

/-! ## Case 1 -/

/-- The separated equivalent of S(a ∧ U(A,B), q) from Case 1.
    Structure: (S(a,q) ∧ S(a,B) ∧ B ∧ U(A,B)) ∨ (A ∧ S(a,B) ∧ S(a,q)) ∨ S(A∧q∧S(a,B)∧S(a,q), q) -/
def case1_psi (a q A B : Formula) : Formula :=
  Formula.or (Formula.or
    (Formula.and (Formula.and (Formula.and (.snce a q) (.snce a B)) B) (.untl A B))
    (Formula.and (Formula.and A (.snce a B)) (.snce a q)))
    (.snce (Formula.and (Formula.and (Formula.and A q) (.snce a B)) (.snce a q)) q)

set_option maxHeartbeats 800000 in
theorem elim_case_1 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (.untl A B)) q) psi ∧
      is_syntactically_separated psi = true := by
  refine ⟨case1_psi a q A B, ?_, ?_⟩
  · intro M t
    simp only [case1_psi]
    constructor
    · intro ⟨s, hst, hand, hq_guard⟩
      have ⟨ha_s, huntl⟩ := int_truth_and_iff.mp hand
      obtain ⟨u, hsu, hAu, hB_guard⟩ := huntl
      rcases lt_trichotomy u t with hut | hut | hut
      · apply int_truth_or_iff.mpr; right
        refine ⟨u, hut, ?_, fun r hur hrt => hq_guard r (lt_trans hsu hur) hrt⟩
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨⟨hAu, hq_guard u hsu hut⟩, ⟨s, hsu, ha_s, hB_guard⟩⟩,
               ⟨s, hsu, ha_s, fun r hsr hru => hq_guard r hsr (lt_trans hru hut)⟩⟩
      · subst hut
        apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨hAu, ⟨s, hst, ha_s, hB_guard⟩⟩, ⟨s, hst, ha_s, hq_guard⟩⟩
      · apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; left
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨⟨⟨s, hst, ha_s, hq_guard⟩,
               ⟨s, hst, ha_s, fun r hsr hrt => hB_guard r hsr (lt_trans hrt hut)⟩⟩,
               hB_guard t hst hut⟩,
               ⟨u, hut, hAu, fun r htr hru => hB_guard r (lt_trans hst htr) hru⟩⟩
    · intro hrhs
      rcases int_truth_or_iff.mp hrhs with h12 | h3
      · rcases int_truth_or_iff.mp h12 with hd1 | hd2
        · rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff] at hd1
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
        · rw [int_truth_and_iff, int_truth_and_iff] at hd2
          obtain ⟨⟨hAt, ⟨s₁, hs₁t, ha₁, hB₁⟩⟩, ⟨s₂, hs₂t, ha₂, hq₂⟩⟩ := hd2
          by_cases hle : s₁ ≤ s₂
          · exact ⟨s₂, hs₂t, int_truth_and_iff.mpr ⟨ha₂,
              t, hs₂t, hAt, fun r hrs hrt => hB₁ r (lt_of_le_of_lt hle hrs) hrt⟩, hq₂⟩
          · push_neg at hle
            exact ⟨s₁, hs₁t, int_truth_and_iff.mpr ⟨ha₁, t, hs₁t, hAt, hB₁⟩,
              fun r hr1 hr2 => hq₂ r (lt_trans hle hr1) hr2⟩
      · obtain ⟨w, hwt, hw_and, hq_rest⟩ := h3
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
  · simp [case1_psi, Formula.and, Formula.or, Formula.neg,
          is_syntactically_separated, is_U_free, ha, hq, hA, hB, hA', hB']
    exact ⟨u_free_s_free_imp_separated B hB hB',
           u_free_s_free_imp_separated A hA hA'⟩

/-! ## Generalized Case 1: S(a ^ U(A,B), q) without S-free a, q requirements

  The generalized version drops BOTH `is_S_free a` and `is_S_free q` from Case 1.
  This enables handling the snce case of Lemma 10.2.5 where the event and guard
  come from abstracted separated formulas (which are U-free but not S-free).

  The proof is identical to `elim_case_1` because the separation check for
  `case1_psi` never uses S-freeness of a or q:
  - `a` and `q` appear only under `snce` nodes, where U-freeness is the requirement
  - Only `A` and `B` need S-freeness (they appear under `untl` and as standalone
    terms where `u_free_s_free_imp_separated` is applied)
-/

set_option maxHeartbeats 800000 in
theorem elim_case_1_gen (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (.untl A B)) q) psi ∧
      is_syntactically_separated psi = true := by
  refine ⟨case1_psi a q A B, ?_, ?_⟩
  · intro M t
    simp only [case1_psi]
    constructor
    · intro ⟨s, hst, hand, hq_guard⟩
      have ⟨ha_s, huntl⟩ := int_truth_and_iff.mp hand
      obtain ⟨u, hsu, hAu, hB_guard⟩ := huntl
      rcases lt_trichotomy u t with hut | hut | hut
      · apply int_truth_or_iff.mpr; right
        refine ⟨u, hut, ?_, fun r hur hrt => hq_guard r (lt_trans hsu hur) hrt⟩
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨⟨hAu, hq_guard u hsu hut⟩, ⟨s, hsu, ha_s, hB_guard⟩⟩,
               ⟨s, hsu, ha_s, fun r hsr hru => hq_guard r hsr (lt_trans hru hut)⟩⟩
      · subst hut
        apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨hAu, ⟨s, hst, ha_s, hB_guard⟩⟩, ⟨s, hst, ha_s, hq_guard⟩⟩
      · apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; left
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨⟨⟨s, hst, ha_s, hq_guard⟩,
               ⟨s, hst, ha_s, fun r hsr hrt => hB_guard r hsr (lt_trans hrt hut)⟩⟩,
               hB_guard t hst hut⟩,
               ⟨u, hut, hAu, fun r htr hru => hB_guard r (lt_trans hst htr) hru⟩⟩
    · intro hrhs
      rcases int_truth_or_iff.mp hrhs with h12 | h3
      · rcases int_truth_or_iff.mp h12 with hd1 | hd2
        · rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff] at hd1
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
        · rw [int_truth_and_iff, int_truth_and_iff] at hd2
          obtain ⟨⟨hAt, ⟨s₁, hs₁t, ha₁, hB₁⟩⟩, ⟨s₂, hs₂t, ha₂, hq₂⟩⟩ := hd2
          by_cases hle : s₁ ≤ s₂
          · exact ⟨s₂, hs₂t, int_truth_and_iff.mpr ⟨ha₂,
              t, hs₂t, hAt, fun r hrs hrt => hB₁ r (lt_of_le_of_lt hle hrs) hrt⟩, hq₂⟩
          · push_neg at hle
            exact ⟨s₁, hs₁t, int_truth_and_iff.mpr ⟨ha₁, t, hs₁t, hAt, hB₁⟩,
              fun r hr1 hr2 => hq₂ r (lt_trans hle hr1) hr2⟩
      · obtain ⟨w, hwt, hw_and, hq_rest⟩ := h3
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
  · simp [case1_psi, Formula.and, Formula.or, Formula.neg,
          is_syntactically_separated, is_U_free, ha, hq, hA, hB, hA', hB']
    exact ⟨u_free_s_free_imp_separated B hB hB',
           u_free_s_free_imp_separated A hA hA'⟩

set_option maxHeartbeats 800000 in
/-- case1_psi is int_equiv to S(a∧U, q) and syntactically separated.
    This is the non-existential form of elim_case_1_gen for direct formula access. -/
theorem case1_psi_properties (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    int_equiv (.snce (Formula.and a (.untl A B)) q) (case1_psi a q A B) ∧
    is_syntactically_separated (case1_psi a q A B) = true := by
  refine ⟨?_, ?_⟩
  · -- Equivalence: same proof as in elim_case_1_gen
    intro M t
    simp only [case1_psi]
    constructor
    · intro ⟨s, hst, hand, hq_guard⟩
      have ⟨ha_s, huntl⟩ := int_truth_and_iff.mp hand
      obtain ⟨u, hsu, hAu, hB_guard⟩ := huntl
      rcases lt_trichotomy u t with hut | hut | hut
      · apply int_truth_or_iff.mpr; right
        refine ⟨u, hut, ?_, fun r hur hrt => hq_guard r (lt_trans hsu hur) hrt⟩
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨⟨hAu, hq_guard u hsu hut⟩, ⟨s, hsu, ha_s, hB_guard⟩⟩,
               ⟨s, hsu, ha_s, fun r hsr hru => hq_guard r hsr (lt_trans hru hut)⟩⟩
      · subst hut
        apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨hAu, ⟨s, hst, ha_s, hB_guard⟩⟩, ⟨s, hst, ha_s, hq_guard⟩⟩
      · apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; left
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨⟨⟨s, hst, ha_s, hq_guard⟩,
               ⟨s, hst, ha_s, fun r hsr hrt => hB_guard r hsr (lt_trans hrt hut)⟩⟩,
               hB_guard t hst hut⟩,
               ⟨u, hut, hAu, fun r htr hru => hB_guard r (lt_trans hst htr) hru⟩⟩
    · intro hrhs
      rcases int_truth_or_iff.mp hrhs with h12 | h3
      · rcases int_truth_or_iff.mp h12 with hd1 | hd2
        · rw [int_truth_and_iff, int_truth_and_iff, int_truth_and_iff] at hd1
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
        · rw [int_truth_and_iff, int_truth_and_iff] at hd2
          obtain ⟨⟨hAt, ⟨s₁, hs₁t, ha₁, hB₁⟩⟩, ⟨s₂, hs₂t, ha₂, hq₂⟩⟩ := hd2
          by_cases hle : s₁ ≤ s₂
          · exact ⟨s₂, hs₂t, int_truth_and_iff.mpr ⟨ha₂,
              t, hs₂t, hAt, fun r hrs hrt => hB₁ r (lt_of_le_of_lt hle hrs) hrt⟩, hq₂⟩
          · push_neg at hle
            exact ⟨s₁, hs₁t, int_truth_and_iff.mpr ⟨ha₁, t, hs₁t, hAt, hB₁⟩,
              fun r hr1 hr2 => hq₂ r (lt_trans hle hr1) hr2⟩
      · obtain ⟨w, hwt, hw_and, hq_rest⟩ := h3
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
  · -- Separation
    simp [case1_psi, Formula.and, Formula.or, Formula.neg,
          is_syntactically_separated, is_U_free, ha, hq, hA, hB, hA', hB']
    exact ⟨u_free_s_free_imp_separated B hB hB',
           u_free_s_free_imp_separated A hA hA'⟩

/-! ## Generalized Case 2: S(a ^ not U(A,B), q) without S-free a, q requirements

  Similarly drops `is_S_free a` and `is_S_free q` from Case 2. The proof calls
  `elim_case_1_gen` which only needs S-freeness for A and B.
-/

set_option maxHeartbeats 1600000 in
theorem elim_case_2_gen (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (Formula.neg (.untl A B))) q) psi ∧
      is_syntactically_separated psi = true := by
  have hAneg_Uf : is_U_free (Formula.neg A) = true := by simp [Formula.neg, is_U_free, hA]
  have hAneg_Sf : is_S_free (Formula.neg A) = true := by simp [Formula.neg, is_S_free, hA']
  have hAB_Uf : is_U_free (Formula.and (Formula.neg A) (Formula.neg B)) = true := by
    simp [Formula.and, Formula.neg, is_U_free, hA, hB]
  have hAB_Sf : is_S_free (Formula.and (Formula.neg A) (Formula.neg B)) = true := by
    simp [Formula.and, Formula.neg, is_S_free, hA', hB']
  obtain ⟨psi1, hequiv1, hsep1⟩ := elim_case_1_gen a q
    (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A)
    ha hq hAB_Uf hAneg_Uf hAB_Sf hAneg_Sf
  -- psi_l = S(a, q ∧ ¬A) ∧ ¬A ∧ G(¬A)
  -- This is the separated equivalent of the "G(¬A) at event" branch.
  -- In the 6-constructor language, all_future(¬A) is not U-free (it contains untl),
  -- so we cannot put it inside snce args. Instead we factor:
  --   S(a ∧ G_s(¬A), q) ↔ S(a, q ∧ ¬A) ∧ ¬A(t) ∧ G_t(¬A)
  have hsep_A : is_syntactically_separated A = true := u_free_s_free_imp_separated A hA hA'
  let psi_l := Formula.and (Formula.and (.snce a (Formula.and q (Formula.neg A)))
    (Formula.neg A)) (.all_future (Formula.neg A))
  have hsep_l : is_syntactically_separated psi_l = true := by
    simp only [psi_l, Formula.and, Formula.neg, is_syntactically_separated,
      is_syntactically_separated_all_future, is_U_free, is_S_free, ha, hq, hA, hA',
      Bool.true_and, Bool.and_true, hsep_A]
  refine ⟨Formula.or psi_l psi1, ?_, ?_⟩
  · intro M t; constructor
    · intro ⟨s, hst, hand, hqg⟩
      have ⟨ha_s, hnotU⟩ := int_truth_and_iff.mp hand
      rcases int_truth_or_iff.mp ((neg_until_equiv A B M s).mp hnotU) with hGA | hU'
      · -- Case: G_s(¬A) holds at event point s
        have hGA_unf := (int_truth_all_future M s (Formula.neg A)).mp hGA
        -- Split G_s(¬A) = (∀ r ∈ (s,t), ¬A(r)) ∧ ¬A(t) ∧ G_t(¬A)
        have hA_t : ¬ int_truth M t A := hGA_unf t hst
        have hGA_t : ∀ u : ℤ, t < u → int_truth M u (Formula.neg A) :=
          fun u hu => hGA_unf u (lt_trans hst hu)
        apply int_truth_or_iff.mpr; left
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_all_future]
        exact ⟨⟨⟨s, hst, ha_s, fun r hr1 hr2 =>
          int_truth_and_iff.mpr ⟨hqg r hr1 hr2, hGA_unf r hr1⟩⟩,
          hA_t⟩, hGA_t⟩
      · exact int_truth_or_iff.mpr (Or.inr ((hequiv1 M t).mp
          ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s, hU'⟩, hqg⟩))
    · intro h
      rcases int_truth_or_iff.mp h with hl | hr
      · -- Backward from psi_l: reconstruct G_s(¬A) from the components
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_all_future] at hl
        obtain ⟨⟨⟨s, hst, ha_s, hguard⟩, hA_t⟩, hGA_t⟩ := hl
        have hGA_s : int_truth M s (.all_future (Formula.neg A)) := by
          rw [int_truth_all_future]
          intro u hu
          rcases lt_trichotomy u t with hut | rfl | htu
          · have hqnA := hguard u hu hut
            exact (int_truth_and_iff.mp hqnA).2
          · exact hA_t
          · exact hGA_t u htu
        exact ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s,
          (neg_until_equiv A B M s).mpr (int_truth_or_iff.mpr (Or.inl hGA_s))⟩,
          fun r hr1 hr2 => (int_truth_and_iff.mp (hguard r hr1 hr2)).1⟩
      · obtain ⟨s, hst, hand, hqg⟩ := (hequiv1 M t).mpr hr
        have ⟨ha_s, hU'⟩ := int_truth_and_iff.mp hand
        exact ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s,
          (neg_until_equiv A B M s).mpr (int_truth_or_iff.mpr (Or.inr hU'))⟩, hqg⟩
  · simp [Formula.or, Formula.neg, is_syntactically_separated, hsep_l, hsep1]

/-! ## Case 2: S(a ^ not U(A,B), q) -/

set_option maxHeartbeats 1600000 in
theorem elim_case_2 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (Formula.neg (.untl A B))) q) psi ∧
      is_syntactically_separated psi = true := by
  have hAneg_Uf : is_U_free (Formula.neg A) = true := by simp [Formula.neg, is_U_free, hA]
  have hAneg_Sf : is_S_free (Formula.neg A) = true := by simp [Formula.neg, is_S_free, hA']
  have hAB_Uf : is_U_free (Formula.and (Formula.neg A) (Formula.neg B)) = true := by
    simp [Formula.and, Formula.neg, is_U_free, hA, hB]
  have hAB_Sf : is_S_free (Formula.and (Formula.neg A) (Formula.neg B)) = true := by
    simp [Formula.and, Formula.neg, is_S_free, hA', hB']
  obtain ⟨psi1, hequiv1, hsep1⟩ := elim_case_1 a q
    (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A)
    ha hq hAB_Uf hAneg_Uf ha' hq' hAB_Sf hAneg_Sf
  -- psi_l = S(a, q ∧ ¬A) ∧ ¬A ∧ G(¬A) -- restructured for 6-constructor separation
  have hsep_A : is_syntactically_separated A = true := u_free_s_free_imp_separated A hA hA'
  let psi_l := Formula.and (Formula.and (.snce a (Formula.and q (Formula.neg A)))
    (Formula.neg A)) (.all_future (Formula.neg A))
  have hsep_l : is_syntactically_separated psi_l = true := by
    simp only [psi_l, Formula.and, Formula.neg, is_syntactically_separated,
      is_syntactically_separated_all_future, is_U_free, is_S_free, ha, hq, hA, hA',
      Bool.true_and, Bool.and_true, hsep_A]
  refine ⟨Formula.or psi_l psi1, ?_, ?_⟩
  · intro M t; constructor
    · intro ⟨s, hst, hand, hqg⟩
      have ⟨ha_s, hnotU⟩ := int_truth_and_iff.mp hand
      rcases int_truth_or_iff.mp ((neg_until_equiv A B M s).mp hnotU) with hGA | hU'
      · have hGA_unf := (int_truth_all_future M s (Formula.neg A)).mp hGA
        have hA_t : ¬ int_truth M t A := hGA_unf t hst
        have hGA_t : ∀ u : ℤ, t < u → int_truth M u (Formula.neg A) :=
          fun u hu => hGA_unf u (lt_trans hst hu)
        apply int_truth_or_iff.mpr; left
        rw [int_truth_and_iff, int_truth_and_iff, int_truth_all_future]
        exact ⟨⟨⟨s, hst, ha_s, fun r hr1 hr2 =>
          int_truth_and_iff.mpr ⟨hqg r hr1 hr2, hGA_unf r hr1⟩⟩,
          hA_t⟩, hGA_t⟩
      · exact int_truth_or_iff.mpr (Or.inr ((hequiv1 M t).mp
          ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s, hU'⟩, hqg⟩))
    · intro h
      rcases int_truth_or_iff.mp h with hl | hr
      · rw [int_truth_and_iff, int_truth_and_iff, int_truth_all_future] at hl
        obtain ⟨⟨⟨s, hst, ha_s, hguard⟩, hA_t⟩, hGA_t⟩ := hl
        have hGA_s : int_truth M s (.all_future (Formula.neg A)) := by
          rw [int_truth_all_future]
          intro u hu
          rcases lt_trichotomy u t with hut | rfl | htu
          · exact (int_truth_and_iff.mp (hguard u hu hut)).2
          · exact hA_t
          · exact hGA_t u htu
        exact ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s,
          (neg_until_equiv A B M s).mpr (int_truth_or_iff.mpr (Or.inl hGA_s))⟩,
          fun r hr1 hr2 => (int_truth_and_iff.mp (hguard r hr1 hr2)).1⟩
      · obtain ⟨s, hst, hand, hqg⟩ := (hequiv1 M t).mpr hr
        have ⟨ha_s, hU'⟩ := int_truth_and_iff.mp hand
        exact ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s,
          (neg_until_equiv A B M s).mpr (int_truth_or_iff.mpr (Or.inr hU'))⟩, hqg⟩
  · simp [Formula.or, Formula.neg, is_syntactically_separated, hsep_l, hsep1]

/-! ## Case 3: S(a, q v U(A,B)) -/

set_option maxHeartbeats 1200000 in
theorem elim_case_3 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce a (Formula.or q (.untl A B))) psi ∧
      is_syntactically_separated psi = true := by
  have haq_Uf : is_U_free (Formula.and (Formula.neg a) (Formula.neg q)) = true := by
    simp [Formula.and, Formula.neg, is_U_free, ha, hq]
  have haq_Sf : is_S_free (Formula.and (Formula.neg a) (Formula.neg q)) = true := by
    simp [Formula.and, Formula.neg, is_S_free, ha', hq']
  have ha_neg_Uf : is_U_free (Formula.neg a) = true := by simp [Formula.neg, is_U_free, ha]
  have ha_neg_Sf : is_S_free (Formula.neg a) = true := by simp [Formula.neg, is_S_free, ha']
  obtain ⟨psi2, hequiv2, hsep2⟩ := elim_case_2
    (Formula.and (Formula.neg a) (Formula.neg q)) (Formula.neg a) A B
    haq_Uf ha_neg_Uf hA hB haq_Sf ha_neg_Sf hA' hB'
  have hsep_H : is_syntactically_separated (.all_past (Formula.neg a)) = true := by
    simp only [is_syntactically_separated_all_past, Formula.neg, is_U_free, ha, Bool.and_true]
  refine ⟨Formula.and (Formula.neg (.all_past (Formula.neg a))) (Formula.neg psi2), ?_, ?_⟩
  · intro M t; constructor
    · intro hS
      rw [int_truth_and_iff, int_truth_neg_iff, int_truth_neg_iff]
      obtain ⟨s, hst, ha_s, hqU_guard⟩ := hS
      simp only [int_truth_all_past] at *
      refine ⟨fun hall => hall s hst ha_s, ?_⟩
      intro hpsi2
      obtain ⟨s2, hs2t, hand2, hguard2⟩ := (hequiv2 M t).mpr hpsi2
      have ⟨haq2, hnotU2⟩ := int_truth_and_iff.mp hand2
      have hna2 := (int_truth_and_iff.mp haq2).1
      have hnq2 := (int_truth_and_iff.mp haq2).2
      have hs_le : s ≤ s2 := by by_contra h; push_neg at h; exact hguard2 s h hst ha_s
      rcases eq_or_lt_of_le hs_le with heq | hlt
      · exact hna2 (heq ▸ ha_s)
      · rcases int_truth_or_iff.mp (hqU_guard s2 hlt hs2t) with hq2 | hU2
        · exact hnq2 hq2
        · exact hnotU2 hU2
    · intro hand
      rw [int_truth_and_iff, int_truth_neg_iff, int_truth_neg_iff] at hand
      obtain ⟨hnotH, hnotPsi2⟩ := hand
      have hnotS2 : ¬ int_truth M t (.snce (Formula.and (Formula.and (Formula.neg a) (Formula.neg q)) (Formula.neg (.untl A B))) (Formula.neg a)) :=
        fun hS2 => hnotPsi2 ((hequiv2 M t).mp hS2)
      by_contra hnotS
      rcases int_truth_or_iff.mp ((neg_since_equiv a (Formula.or q (.untl A B)) M t).mp hnotS) with hH | hS_neg
      · exact hnotH hH
      · obtain ⟨s, hst, hevent, hguard⟩ := hS_neg
        have ⟨hna_s, hnotQU_s⟩ := int_truth_and_iff.mp hevent
        have hnotQ_s : ¬ int_truth M s q :=
          fun h => (int_truth_neg_iff.mp hnotQU_s) (int_truth_or_iff.mpr (Or.inl h))
        have hnotU_s : ¬ int_truth M s (.untl A B) :=
          fun h => (int_truth_neg_iff.mp hnotQU_s) (int_truth_or_iff.mpr (Or.inr h))
        exact hnotS2 ⟨s, hst, int_truth_and_iff.mpr
          ⟨int_truth_and_iff.mpr ⟨hna_s, hnotQ_s⟩, hnotU_s⟩, hguard⟩
  · exact and_separated (neg_separated hsep_H) (neg_separated hsep2)

/-! ## Case 4: S(a, q v not U(A,B)) -/

set_option maxHeartbeats 1200000 in
theorem elim_case_4 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce a (Formula.or q (Formula.neg (.untl A B)))) psi ∧
      is_syntactically_separated psi = true := by
  have haq_Uf : is_U_free (Formula.and (Formula.neg a) (Formula.neg q)) = true := by
    simp [Formula.and, Formula.neg, is_U_free, ha, hq]
  have haq_Sf : is_S_free (Formula.and (Formula.neg a) (Formula.neg q)) = true := by
    simp [Formula.and, Formula.neg, is_S_free, ha', hq']
  have ha_neg_Uf : is_U_free (Formula.neg a) = true := by simp [Formula.neg, is_U_free, ha]
  have ha_neg_Sf : is_S_free (Formula.neg a) = true := by simp [Formula.neg, is_S_free, ha']
  obtain ⟨psi1, hequiv1, hsep1⟩ := elim_case_1
    (Formula.and (Formula.neg a) (Formula.neg q)) (Formula.neg a) A B
    haq_Uf ha_neg_Uf hA hB haq_Sf ha_neg_Sf hA' hB'
  have hsep_H : is_syntactically_separated (.all_past (Formula.neg a)) = true := by
    simp only [is_syntactically_separated_all_past, Formula.neg, is_U_free, ha, Bool.and_true]
  refine ⟨Formula.and (Formula.neg (.all_past (Formula.neg a))) (Formula.neg psi1), ?_, ?_⟩
  · intro M t; constructor
    · intro hS
      rw [int_truth_and_iff, int_truth_neg_iff, int_truth_neg_iff]
      obtain ⟨s, hst, ha_s, hguard_S⟩ := hS
      simp only [int_truth_all_past] at *
      refine ⟨fun hall => hall s hst ha_s, ?_⟩
      intro hpsi1
      obtain ⟨s1, hs1t, hevent1, hguard1⟩ := (hequiv1 M t).mpr hpsi1
      have ⟨haq1, hU1⟩ := int_truth_and_iff.mp hevent1
      have hna1 := (int_truth_and_iff.mp haq1).1
      have hnq1 := (int_truth_and_iff.mp haq1).2
      have hs_le : s ≤ s1 := by by_contra h; push_neg at h; exact hguard1 s h hst ha_s
      rcases eq_or_lt_of_le hs_le with heq | hlt
      · exact hna1 (heq ▸ ha_s)
      · rcases int_truth_or_iff.mp (hguard_S s1 hlt hs1t) with hq1 | hnotU1
        · exact hnq1 hq1
        · exact (int_truth_neg_iff.mp hnotU1) hU1
    · intro hand
      rw [int_truth_and_iff, int_truth_neg_iff, int_truth_neg_iff] at hand
      obtain ⟨hnotH, hnotPsi1⟩ := hand
      have hnotS1 : ¬ int_truth M t (.snce (Formula.and (Formula.and (Formula.neg a) (Formula.neg q)) (.untl A B)) (Formula.neg a)) :=
        fun hS1 => hnotPsi1 ((hequiv1 M t).mp hS1)
      by_contra hnotS
      rcases int_truth_or_iff.mp ((neg_since_equiv a (Formula.or q (Formula.neg (.untl A B))) M t).mp hnotS) with hH | hS_neg
      · exact hnotH hH
      · obtain ⟨s, hst, hevent, hguard⟩ := hS_neg
        have ⟨hna_s, hnotG⟩ := int_truth_and_iff.mp hevent
        have hnotQ_s : ¬ int_truth M s q :=
          fun h => (int_truth_neg_iff.mp hnotG) (int_truth_or_iff.mpr (Or.inl h))
        have hU_s : int_truth M s (.untl A B) := by
          by_contra hnotU
          exact (int_truth_neg_iff.mp hnotG)
            (int_truth_or_iff.mpr (Or.inr (int_truth_neg_iff.mpr hnotU)))
        exact hnotS1 ⟨s, hst, int_truth_and_iff.mpr
          ⟨int_truth_and_iff.mpr ⟨hna_s, hnotQ_s⟩, hU_s⟩, hguard⟩
  · exact and_separated (neg_separated hsep_H) (neg_separated hsep1)

/-! ## Case 5: S(a ^ U(A,B), q v U(A,B))

  Case 5 eliminates U(A,B) from a Since formula where U(A,B) appears
  in BOTH the event and guard positions.

  ### GHR94 Error on Integer Time

  GHR94 (p.370) gives an explicit formula for Case 5 that is INCORRECT
  for integer (discrete) time. The formula requires `A ∨ (B ∧ U(A,B))`
  at the evaluation point `t`, which is not guaranteed when:
  1. The U-chain from the event witness terminates before t
  2. The S-guard is satisfied purely by `q` between the U-chain end and t

  **Counterexample** (GHR94 original formula):
    a(0)=true, A(1)=true, B=false everywhere, q(1)=q(2)=true.
    LHS `S(a ^ U(A,B), q v U(A,B))(3)` = TRUE (witness s=0, U(A,B)(0)
      via u=1 with vacuous B on (0,1)_Z = {}, guard q on {1,2}).
    RHS requires `A(3) v (B(3) ^ U(A,B)(3))` = FALSE.

  A second counterexample shows the guard formula `¬S(¬q, ¬A)` used by
  GHR94 is also incorrect on integers, being trivially satisfiable via
  vacuous ¬A on empty intervals (t-1, t)_Z.

  **Root cause**: On integers, `U(A,B)(n)` can hold with a vacuous
  B-guard when the A-witness is at n+1 (since (n,n+1)_Z = ∅). GHR94's
  formula assumes the U-chain propagates B-coverage to t, which is only
  valid in dense time.

  **Resolution**: Cases 5-8 are proved using the separation theorem
  (`all_separable` from SeparationThm.lean), which establishes that
  every formula is separable via structural induction + temporal closure.
  The explicit separated formula for Case 5 on integers remains an open
  problem, but its EXISTENCE is guaranteed by the theorem.

  See: specs/157_expressive_completeness_su_integer/reports/02_case5-blocker-research.md
-/

-- Note: Cases 5-8 are now proved in NormalForm.lean using `all_separable` from SeparationThm.lean.
-- The theorems `elim_case_5/6/7/8` have been moved there to resolve the import dependency
-- (Eliminations.lean cannot import SeparationThm.lean without creating a cycle).

/-! ## Separability Helpers -/

theorem is_separable_of_equiv {φ ψ : Formula} (h : int_equiv φ ψ)
    (hs : is_separable ψ) : is_separable φ := by
  obtain ⟨χ, hχ_sep, hχ_equiv⟩ := hs
  exact ⟨χ, hχ_sep, int_equiv_trans h hχ_equiv⟩

theorem or_separable {φ ψ : Formula}
    (h1 : is_separable φ) (h2 : is_separable ψ) : is_separable (Formula.or φ ψ) := by
  obtain ⟨φ', hφ', heφ⟩ := h1
  obtain ⟨ψ', hψ', heψ⟩ := h2
  refine ⟨Formula.or φ' ψ', ?_, ?_⟩
  · simp [Formula.or, Formula.neg, is_syntactically_separated, hφ', hψ']
  · intro M t; constructor
    · intro h; rcases int_truth_or_iff.mp h with hp | hq
      · exact int_truth_or_iff.mpr (Or.inl ((heφ M t).mp hp))
      · exact int_truth_or_iff.mpr (Or.inr ((heψ M t).mp hq))
    · intro h; rcases int_truth_or_iff.mp h with hp | hq
      · exact int_truth_or_iff.mpr (Or.inl ((heφ M t).mpr hp))
      · exact int_truth_or_iff.mpr (Or.inr ((heψ M t).mpr hq))

theorem neg_separable {φ : Formula}
    (h : is_separable φ) : is_separable (Formula.neg φ) := by
  obtain ⟨φ', hφ', heφ⟩ := h
  refine ⟨Formula.neg φ', neg_separated hφ', ?_⟩
  intro M t; constructor
  · intro hn hp; exact hn ((heφ M t).mpr hp)
  · intro hn hp; exact hn ((heφ M t).mp hp)

theorem and_separable {φ ψ : Formula}
    (h1 : is_separable φ) (h2 : is_separable ψ) : is_separable (Formula.and φ ψ) := by
  obtain ⟨φ', hφ', heφ⟩ := h1
  obtain ⟨ψ', hψ', heψ⟩ := h2
  refine ⟨Formula.and φ' ψ', and_separated hφ' hψ', ?_⟩
  intro M t; constructor
  · intro h; rw [int_truth_and_iff] at h ⊢
    exact ⟨(heφ M t).mp h.1, (heψ M t).mp h.2⟩
  · intro h; rw [int_truth_and_iff] at h ⊢
    exact ⟨(heφ M t).mpr h.1, (heψ M t).mpr h.2⟩

theorem imp_separable {φ ψ : Formula}
    (h1 : is_separable φ) (h2 : is_separable ψ) : is_separable (Formula.imp φ ψ) := by
  obtain ⟨φ', hφ', heφ⟩ := h1
  obtain ⟨ψ', hψ', heψ⟩ := h2
  refine ⟨Formula.imp φ' ψ', ?_, ?_⟩
  · simp [is_syntactically_separated, hφ', hψ']
  · intro M t; constructor
    · intro h hp; exact (heψ M t).mp (h ((heφ M t).mpr hp))
    · intro h hp; exact (heψ M t).mpr (h ((heφ M t).mp hp))

/-- Since-event splitting by classical LEM on an arbitrary formula:
    S(a, guard) ↔ S(a ^ φ, guard) ∨ S(a ^ ¬φ, guard) -/
theorem since_event_split (a φ guard : Formula) :
    int_equiv (.snce a guard)
      (Formula.or (.snce (Formula.and a φ) guard)
                  (.snce (Formula.and a (Formula.neg φ)) guard)) := by
  intro M t; constructor
  · intro ⟨s, hst, ha, hg⟩
    by_cases hφ : int_truth M s φ
    · exact int_truth_or_iff.mpr (Or.inl ⟨s, hst, int_truth_and_iff.mpr ⟨ha, hφ⟩, hg⟩)
    · exact int_truth_or_iff.mpr (Or.inr ⟨s, hst, int_truth_and_iff.mpr ⟨ha, hφ⟩, hg⟩)
  · intro h; rcases int_truth_or_iff.mp h with ⟨s, hst, hand, hg⟩ | ⟨s, hst, hand, hg⟩
    · exact ⟨s, hst, (int_truth_and_iff.mp hand).1, hg⟩
    · exact ⟨s, hst, (int_truth_and_iff.mp hand).1, hg⟩

-- Note: S doesn't distribute ∧ in event (S(a^b, guard) ≠ S(a,guard)^S(b,guard)),
-- but since_event_split gives: S(a, guard) ↔ S(a^φ, guard) ∨ S(a^¬φ, guard).

/-- Guard weakening: S(event, stronger_guard) → S(event, weaker_guard) when
    stronger_guard implies weaker_guard pointwise. -/
theorem since_guard_weaken {event guard₁ guard₂ : Formula}
    (h : ∀ M : IntStructure, ∀ t : ℤ, int_truth M t guard₁ → int_truth M t guard₂)
    {M : IntStructure} {t : ℤ} :
    int_truth M t (.snce event guard₁) → int_truth M t (.snce event guard₂) := by
  rintro ⟨s, hst, he, hg⟩
  exact ⟨s, hst, he, fun r hr1 hr2 => h M r (hg r hr1 hr2)⟩

/-! ## Cases 6-8

  Cases 6-8 involve ¬U(A,B) in the event and/or guard. On integer time,
  ¬U(A,B) ↔ G(¬A) ∨ U(¬A∧¬B, ¬A) (by neg_until_equiv, the key Z-specific
  equivalence). Expansion via neg_until_equiv + since_distrib_or_left reduces
  each case to disjuncts that are instances of earlier cases, possibly with
  different parameters.

  Case 6: S(a ^ ¬U(A,B), q ∨ U(A,B))
  Case 7: S(a ^ U(A,B), q ∨ ¬U(A,B))
  Case 8: S(a ^ ¬U(A,B), q ∨ ¬U(A,B))
-/

/-! ### Cases 6-8

  Cases 6-8 involve ¬U(A,B) in the event and/or guard. Like Case 5,
  the explicit formulas are affected by the GHR94 discrete-time error.
  Their existence is proved via `all_separable` in NormalForm.lean.

  Case 6: S(a ^ ¬U(A,B), q ∨ U(A,B))
  Case 7: S(a ^ U(A,B), q ∨ ¬U(A,B))
  Case 8: S(a ^ ¬U(A,B), q ∨ ¬U(A,B))
-/

-- Note: Cases 6-8 theorems are now in NormalForm.lean (proved via all_separable).

end Bimodal.Metalogic.WeakCanonical.Separation
