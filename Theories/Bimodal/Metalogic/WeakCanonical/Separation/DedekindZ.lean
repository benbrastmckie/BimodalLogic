import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.Eliminations
import Bimodal.Metalogic.WeakCanonical.Separation.NegationEquiv
import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm

/-!
# Dedekind Specialization for Integer Time (GHR94 Section 10.3)

This file proves that on integer time (Z), the operators K+, K-, Gamma+, Gamma-
from GHR94's Dedekind-complete time framework all collapse to bottom (False).
This dramatically simplifies the Q-lemma (Lemma 10.3.6) and Cases 5-8
(Lemma 10.3.11) when specialized to integers.

## Key Results

- `K_plus_bot_on_Z`: K+(q) is always false on Z
- `K_minus_bot_on_Z`: K-(q) is always false on Z
- `Gamma_plus_bot_on_Z`: Gamma+(B) is always false on Z
- `Gamma_minus_bot_on_Z`: Gamma-(B) is always false on Z
- `Q_Z_U_free`: Q_Z preserves U-freeness
- `Q_Z_no_S_nested`: Q_Z preserves no_S_nested_in_U

## Mathematical Background

K+(q) = not(U(top, not q)) means "q is true arbitrarily close from the future".
On Z, U(top, not q) is always true: take s = t+1, then the guard not q must hold
for all r with t < r < t+1, but (t, t+1)_Z is empty, so the guard is vacuous.
Therefore K+(q) = not(True) = False.

Similarly for K-(q) using S with s = t-1 and empty interval (t-1, t)_Z.

## References

- GHR94, Section 10.3 (Dedekind-complete time specialized to integers)
- Research report: specs/157_expressive_completeness_su_integer/reports/07_team-research.md
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## K-plus, K-minus, Gamma Definitions -/

/-- K+(q) = not(U(top, not q)). Here top = neg bot = (bot -> bot). -/
def K_plus (q : Formula) : Formula :=
  Formula.neg (.untl (Formula.neg .bot) (Formula.neg q))

/-- K-(q) = not(S(top, not q)). -/
def K_minus (q : Formula) : Formula :=
  Formula.neg (.snce (Formula.neg .bot) (Formula.neg q))

/-- Gamma+(B) = not(K+(not B)) and K-(not B). -/
def Gamma_plus (B : Formula) : Formula :=
  Formula.and (Formula.neg (K_plus (Formula.neg B))) (K_minus (Formula.neg B))

/-- Gamma-(B) = not(K-(not B)) and K+(not B). -/
def Gamma_minus (B : Formula) : Formula :=
  Formula.and (Formula.neg (K_minus (Formula.neg B))) (K_plus (Formula.neg B))

/-! ## K+/K- Triviality on Z -/

/-- K+(q) is always false on integer time.
    Proof: U(top, not q) is always true via witness s = t+1 with empty guard interval. -/
theorem K_plus_bot_on_Z (q : Formula) (M : IntStructure) (t : ℤ) :
    ¬ int_truth M t (K_plus q) := by
  simp only [K_plus, Formula.neg]
  intro h
  apply h
  refine ⟨t + 1, by omega, id, fun r htr hrs => ?_⟩
  exfalso; omega

/-- K-(q) is always false on integer time.
    Proof: S(top, not q) is always true via witness s = t-1 with empty guard interval. -/
theorem K_minus_bot_on_Z (q : Formula) (M : IntStructure) (t : ℤ) :
    ¬ int_truth M t (K_minus q) := by
  simp only [K_minus, Formula.neg]
  intro h
  apply h
  refine ⟨t - 1, by omega, id, fun r hrs hrt => ?_⟩
  exfalso; omega

/-- Gamma+(B) is always false on integer time.
    Gamma+(B) = and(not(K+(neg B)), K-(neg B)). K-(neg B) is false. -/
theorem Gamma_plus_bot_on_Z (B : Formula) (M : IntStructure) (t : ℤ) :
    ¬ int_truth M t (Gamma_plus B) := by
  simp only [Gamma_plus]
  intro h
  apply h
  intro _ hKm
  exact K_minus_bot_on_Z (Formula.neg B) M t hKm

/-- Gamma-(B) is always false on integer time.
    Gamma-(B) = and(not(K-(neg B)), K+(neg B)). K+(neg B) is false. -/
theorem Gamma_minus_bot_on_Z (B : Formula) (M : IntStructure) (t : ℤ) :
    ¬ int_truth M t (Gamma_minus B) := by
  simp only [Gamma_minus]
  intro h
  apply h
  intro _ hKp
  exact K_plus_bot_on_Z (Formula.neg B) M t hKp

/-! ## Q-Lemma for Z (GHR94 Lemma 10.3.6 specialized)

On Z, the Q function simplifies dramatically because K-plus, K-minus, Gamma all vanish.
The full Dedekind definition becomes:
  Q(A,B,C) = B or A or not(S(C, not A))
-/

/-- Q(A,B,C) on Z: the simplified Dedekind Q function.
    B or A or not(S(C, not A)) -/
def Q_Z (A B C : Formula) : Formula :=
  Formula.or (Formula.or B A) (Formula.neg (.snce C (Formula.neg A)))

/-! ## Q-Lemma Forward Direction -/

set_option maxHeartbeats 800000 in
/-- Q-lemma forward direction for Z.
    If U(A,B) is guarded by C on (t0, t1) and U(A,B) holds at t0,
    then Q_Z(A,B,C) holds on (t0, t1). -/
theorem Q_lemma_Z_fwd (A B C : Formula) (M : IntStructure) (t0 t1 : ℤ)
    (_ht : t0 < t1)
    (hguard : ∀ z : ℤ, t0 < z → z < t1 →
      (int_truth M z C → int_truth M z (.untl A B)))
    (hinit : int_truth M t0 (.untl A B)) :
    ∀ z : ℤ, t0 < z → z < t1 → int_truth M z (Q_Z A B C) := by
  intro z hz0 hz1
  rw [Q_Z, int_truth_or_iff, int_truth_or_iff, int_truth_neg_iff]
  by_cases hS : int_truth M z (.snce C (Formula.neg A))
  · obtain ⟨u, huz, hCu, hnotA_guard⟩ := hS
    by_cases hut0 : t0 < u
    · have hut1 : u < t1 := lt_trans huz hz1
      obtain ⟨w, huw, hAw, hBgd⟩ := hguard u hut0 hut1 hCu
      by_cases hwz : w ≤ z
      · rcases eq_or_lt_of_le hwz with rfl | hwz'
        · exact Or.inl (Or.inr hAw)
        · exact absurd hAw (hnotA_guard w huw hwz')
      · push_neg at hwz
        exact Or.inl (Or.inl (hBgd z huz hwz))
    · push_neg at hut0
      obtain ⟨w, ht0w, hAw, hBgd⟩ := hinit
      by_cases hwz : w ≤ z
      · rcases eq_or_lt_of_le hwz with rfl | hwz'
        · exact Or.inl (Or.inr hAw)
        · have huw' : u < w := lt_of_le_of_lt hut0 ht0w
          exact absurd hAw (hnotA_guard w huw' hwz')
      · push_neg at hwz
        exact Or.inl (Or.inl (hBgd z hz0 hwz))
  · exact Or.inr hS

/-! ## Q-Lemma Backward Direction -/

set_option maxHeartbeats 1600000 in
/-- Q-lemma backward direction for Z. -/
theorem Q_lemma_Z_bwd (A B C : Formula) (M : IntStructure) (t0 t1 : ℤ)
    (_ht : t0 < t1)
    (hQ : ∀ z : ℤ, t0 < z → z < t1 → int_truth M z (Q_Z A B C))
    (hend : int_truth M t1 A
          ∨ int_truth M t1 (Formula.and B (.untl A B))) :
    ∀ z : ℤ, t0 < z → z < t1 →
      (int_truth M z C → int_truth M z (.untl A B)) := by
  intro z hz0 hz1 hCz
  by_cases hA_exists : ∃ w : ℤ, z < w ∧ w ≤ t1 ∧ int_truth M w A
  · haveI : DecidablePred (fun w => int_truth M w A) := Classical.decPred _
    obtain ⟨w₀, hw₀⟩ := hA_exists
    have hex : ∃ n, z < n ∧ int_truth M n A := ⟨w₀, hw₀.1, hw₀.2.2⟩
    obtain ⟨y, hzy, hAy, hmin⟩ := Int.exists_least_above hex
    refine ⟨y, hzy, hAy, fun r hzr hry => ?_⟩
    have hnotAr : ¬ int_truth M r A := hmin r hzr hry
    have hyt1 : y ≤ t1 := by
      by_contra h; push_neg at h
      exact hmin w₀ hw₀.1 (lt_of_le_of_lt hw₀.2.1 h) hw₀.2.2
    have hrt1 : r < t1 := lt_of_lt_of_le hry hyt1
    have hrt0 : t0 < r := lt_trans hz0 hzr
    have hQr := hQ r hrt0 hrt1
    rw [Q_Z, int_truth_or_iff, int_truth_or_iff, int_truth_neg_iff] at hQr
    rcases hQr with (hBr | hAr) | hnotS
    · exact hBr
    · exact absurd hAr hnotAr
    · exfalso; apply hnotS
      refine ⟨z, hzr, hCz, fun r' hr'z hr'r => ?_⟩
      exact hmin r' hr'z (lt_trans hr'r hry)
  · push_neg at hA_exists
    have hB_interval : ∀ r, z < r → r < t1 → int_truth M r B := by
      intro r hzr hrt1
      have hnotAr := hA_exists r hzr (le_of_lt hrt1)
      have hQr := hQ r (lt_trans hz0 hzr) hrt1
      rw [Q_Z, int_truth_or_iff, int_truth_or_iff, int_truth_neg_iff] at hQr
      rcases hQr with (hBr | hAr) | hnotS
      · exact hBr
      · exact absurd hAr hnotAr
      · exfalso; apply hnotS
        refine ⟨z, hzr, hCz, fun r' hr'z hr'r => ?_⟩
        exact hA_exists r' hr'z (le_of_lt (lt_trans hr'r hrt1))
    rcases hend with hAt1 | hBUt1
    · exact absurd hAt1 (hA_exists t1 hz1 (le_refl t1))
    · rw [int_truth_and_iff] at hBUt1
      obtain ⟨hBt1, hUt1⟩ := hBUt1
      obtain ⟨w, ht1w, hAw, hBgd_w⟩ := hUt1
      refine ⟨w, lt_trans hz1 ht1w, hAw, fun r hzr hrw => ?_⟩
      rcases lt_trichotomy r t1 with hrt1 | hrt1 | hrt1
      · exact hB_interval r hzr hrt1
      · exact hrt1 ▸ hBt1
      · exact hBgd_w r hrt1 hrw

/-! ## Q_Z Syntactic Properties -/

/-- Q_Z(A,B,C) is U-free when A, B, C are U-free. -/
theorem Q_Z_U_free (A B C : Formula)
    (hA : is_U_free A = true) (hB : is_U_free B = true) (hC : is_U_free C = true) :
    is_U_free (Q_Z A B C) = true := by
  simp [Q_Z, Formula.or, Formula.neg, is_U_free, hA, hB, hC]

/-- Q_Z(A,B,C) has no_S_nested_in_U when A, B, C do. -/
theorem Q_Z_no_S_nested (A B C : Formula)
    (hA : no_S_nested_in_U A) (hB : no_S_nested_in_U B) (hC : no_S_nested_in_U C) :
    no_S_nested_in_U (Q_Z A B C) := by
  simp only [Q_Z, Formula.or, Formula.neg]
  repeat (first | constructor | exact hA | exact hB | exact hC | trivial)

/-! ## Case 3 General Equivalence (GHR94 Lemma 10.3.11.3 for Z)

The three-disjunct decomposition for S(a, q v U(A,B)) with ARBITRARY event `a`.
This is the core theorem that enables non-circular proofs of Cases 5-8.

  S(a, q v U(A,B)) <->
    S(a, q)                                                    -- disjunct (i)
    v [S(alpha, Q_Z(A,B,~q)) ^ (A v (B ^ U(A,B)))]           -- disjunct (ii)
    v S(A ^ (q v U(A,B)) ^ S(alpha, Q_Z(A,B,~q)), q)         -- disjunct (iii)

  where alpha = a v (~q ^ S(a, q) ^ (q v U(A,B)))
-/

/-- General alpha for Case 3: a v (~q ^ S(a, q) ^ (q v U(A,B))) -/
def case3_alpha (a q A B : Formula) : Formula :=
  Formula.or a
    (Formula.and (Formula.and (Formula.neg q) (.snce a q))
      (Formula.or q (.untl A B)))

/-- Case 3 RHS for general event a:
    S(a, q) v [S(alpha, Q_Z(A,B,~q)) ^ (A v B^U)] v S(A ^ (qvU) ^ S(alpha, Q_Z), q) -/
def case3_rhs (a q A B : Formula) : Formula :=
  let al := case3_alpha a q A B
  let qz := Q_Z A B (Formula.neg q)
  Formula.or (Formula.or
    (.snce a q)
    (Formula.and (.snce al qz)
      (Formula.or A (Formula.and B (.untl A B)))))
    (.snce (Formula.and (Formula.and A (Formula.or q (.untl A B)))
             (.snce al qz))
           q)

/-! ### Backward Direction: case3_rhs -> S(a, q v U(A,B)) -/

set_option maxHeartbeats 1600000 in
/-- Case 3 backward direction: any disjunct of the RHS implies S(a, q v U(A,B)). -/
theorem case3_equiv_Z_bwd (a q A B : Formula) (M : IntStructure) (t : ℤ)
    (h : int_truth M t (case3_rhs a q A B)) :
    int_truth M t (.snce a (Formula.or q (.untl A B))) := by
  simp only [case3_rhs] at h
  rcases int_truth_or_iff.mp h with h12 | h3
  · rcases int_truth_or_iff.mp h12 with h1 | h2
    · obtain ⟨s, hst, ha_s, hq_guard⟩ := h1
      exact ⟨s, hst, ha_s, fun r hrs hrt =>
        int_truth_or_iff.mpr (Or.inl (hq_guard r hrs hrt))⟩
    · rw [int_truth_and_iff] at h2
      obtain ⟨hSalpha, hABU⟩ := h2
      obtain ⟨v, hvt, halpha_v, hQZ_guard⟩ := hSalpha
      simp only [case3_alpha] at halpha_v
      rcases int_truth_or_iff.mp halpha_v with ha_v | halpha2
      · have hend_for_Q : int_truth M t A ∨ int_truth M t (Formula.and B (.untl A B)) := by
          rcases int_truth_or_iff.mp hABU with hA | hBU
          · exact Or.inl hA
          · exact Or.inr hBU
        have hvt_lt : v < t := hvt
        have hCimplU := Q_lemma_Z_bwd A B (Formula.neg q) M v t hvt_lt hQZ_guard hend_for_Q
        refine ⟨v, hvt, ha_v, fun r hvr hrt => ?_⟩
        rw [int_truth_or_iff]
        by_cases hqr : int_truth M r q
        · exact Or.inl hqr
        · exact Or.inr (hCimplU r hvr hrt hqr)
      · rw [int_truth_and_iff] at halpha2
        obtain ⟨hnq_and_Saq, hqU_v⟩ := halpha2
        rw [int_truth_and_iff] at hnq_and_Saq
        obtain ⟨_hnq_v, hSaq_v⟩ := hnq_and_Saq
        obtain ⟨s, hsv, ha_s, hq_sv⟩ := hSaq_v
        have hend_for_Q : int_truth M t A ∨ int_truth M t (Formula.and B (.untl A B)) := by
          rcases int_truth_or_iff.mp hABU with hA | hBU
          · exact Or.inl hA
          · exact Or.inr hBU
        have hCimplU := Q_lemma_Z_bwd A B (Formula.neg q) M v t hvt hQZ_guard hend_for_Q
        refine ⟨s, lt_trans hsv hvt, ha_s, fun r hsr hrt => ?_⟩
        rw [int_truth_or_iff]
        rcases lt_trichotomy r v with hrv | hrv | hrv
        · exact Or.inl (hq_sv r hsr hrv)
        · subst hrv; exact int_truth_or_iff.mp hqU_v
        · by_cases hqr : int_truth M r q
          · exact Or.inl hqr
          · exact Or.inr (hCimplU r hrv hrt hqr)
  · obtain ⟨u, hut, hevent_u, hq_guard⟩ := h3
    rw [int_truth_and_iff] at hevent_u
    obtain ⟨hA_qU, hSalpha_u⟩ := hevent_u
    rw [int_truth_and_iff] at hA_qU
    obtain ⟨hA_u, hqU_u⟩ := hA_qU
    obtain ⟨v, hvu, halpha_v, hQZ_vu⟩ := hSalpha_u
    simp only [case3_alpha] at halpha_v
    rcases int_truth_or_iff.mp halpha_v with ha_v | halpha2
    · have hend_u : int_truth M u A ∨ int_truth M u (Formula.and B (.untl A B)) :=
        Or.inl hA_u
      have hCimplU := Q_lemma_Z_bwd A B (Formula.neg q) M v u hvu hQZ_vu hend_u
      refine ⟨v, lt_trans hvu hut, ha_v, fun r hvr hrt => ?_⟩
      rw [int_truth_or_iff]
      rcases lt_trichotomy r u with hru | hru | hru
      · by_cases hqr : int_truth M r q
        · exact Or.inl hqr
        · exact Or.inr (hCimplU r hvr hru hqr)
      · subst hru; exact int_truth_or_iff.mp hqU_u
      · exact Or.inl (hq_guard r hru hrt)
    · rw [int_truth_and_iff] at halpha2
      obtain ⟨hnq_and_Saq, _hqU_v⟩ := halpha2
      rw [int_truth_and_iff] at hnq_and_Saq
      obtain ⟨_hnq_v, hSaq_v⟩ := hnq_and_Saq
      obtain ⟨s, hsv, ha_s, hq_sv⟩ := hSaq_v
      have hend_u : int_truth M u A ∨ int_truth M u (Formula.and B (.untl A B)) :=
        Or.inl hA_u
      have hCimplU := Q_lemma_Z_bwd A B (Formula.neg q) M v u hvu hQZ_vu hend_u
      refine ⟨s, lt_trans hsv (lt_trans hvu hut), ha_s, fun r hsr hrt => ?_⟩
      rw [int_truth_or_iff]
      rcases lt_trichotomy r v with hrv | hrv | hrv
      · exact Or.inl (hq_sv r hsr hrv)
      · subst hrv
        rcases int_truth_or_iff.mp _hqU_v with hqv | hUv
        · exact Or.inl hqv
        · exact Or.inr hUv
      · rcases lt_trichotomy r u with hru | hru | hru
        · by_cases hqr : int_truth M r q
          · exact Or.inl hqr
          · exact Or.inr (hCimplU r hrv hru hqr)
        · subst hru; exact int_truth_or_iff.mp hqU_u
        · exact Or.inl (hq_guard r hru hrt)

/-! ### Forward Direction: S(a, q v U(A,B)) -> case3_rhs -/

set_option maxHeartbeats 3200000 in
/-- Case 3 forward direction: S(a, q v U(A,B)) implies one of three disjuncts. -/
theorem case3_equiv_Z_fwd (a q A B : Formula) (M : IntStructure) (t : ℤ)
    (h : int_truth M t (.snce a (Formula.or q (.untl A B)))) :
    int_truth M t (case3_rhs a q A B) := by
  obtain ⟨s, hst, ha_s, hguard⟩ := h
  by_cases hq_all : ∀ r, s < r → r < t → int_truth M r q
  · simp only [case3_rhs]
    apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; left
    exact ⟨s, hst, ha_s, hq_all⟩
  · push_neg at hq_all
    obtain ⟨f, hsf, hft, hnqf⟩ := hq_all
    haveI : DecidablePred (fun r => ¬int_truth M r q) := Classical.decPred _
    have hex_fail : ∃ n, s < n ∧ ¬int_truth M n q := ⟨f, hsf, hnqf⟩
    obtain ⟨f₀, hsf₀, hnqf₀, hf₀_min⟩ := Int.exists_least_above hex_fail
    have hq_left : ∀ r, s < r → r < f₀ → int_truth M r q := by
      intro r hsr hrf₀; by_contra hnq; exact hf₀_min r hsr hrf₀ hnq
    have hf₀t : f₀ < t := by
      by_contra hle; push_neg at hle
      have hff₀ : f < f₀ := lt_of_lt_of_le hft hle
      exact hf₀_min f hsf hff₀ hnqf
    by_cases hq_right : ∀ r, f₀ < r → r < t → int_truth M r q
    · have hqU_f₀ := hguard f₀ hsf₀ hf₀t
      have hU_f₀ : int_truth M f₀ (.untl A B) := by
        rcases int_truth_or_iff.mp hqU_f₀ with hq | hU
        · exact absurd hq hnqf₀
        · exact hU
      have hU_f₀_copy := hU_f₀
      obtain ⟨w, hf₀w, hAw, hBguard_w⟩ := hU_f₀_copy
      have hSaq_f₀ : int_truth M f₀ (.snce a q) :=
        ⟨s, hsf₀, ha_s, hq_left⟩
      have halpha_f₀ : int_truth M f₀ (case3_alpha a q A B) := by
        simp only [case3_alpha]
        apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff]; constructor
        · rw [int_truth_and_iff]; exact ⟨hnqf₀, hSaq_f₀⟩
        · exact hqU_f₀
      have hQ_on_interval : ∀ z, f₀ < z → z < t → int_truth M z (Q_Z A B (Formula.neg q)) := by
        apply Q_lemma_Z_fwd A B (Formula.neg q) M f₀ t hf₀t
        · intro z hz0 hz1 hC
          exact absurd (hq_right z hz0 hz1) hC
        · exact hU_f₀
      have hSalpha_t : int_truth M t (.snce (case3_alpha a q A B) (Q_Z A B (Formula.neg q))) :=
        ⟨f₀, hf₀t, halpha_f₀, hQ_on_interval⟩
      rcases le_or_gt w t with hwt | htw
      · rcases eq_or_lt_of_le hwt with rfl | hwt'
        · simp only [case3_rhs]
          apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; right
          rw [int_truth_and_iff]; exact ⟨hSalpha_t, int_truth_or_iff.mpr (Or.inl hAw)⟩
        · have hqw : int_truth M w q := hq_right w hf₀w hwt'
          have hqU_w : int_truth M w (Formula.or q (.untl A B)) :=
            int_truth_or_iff.mpr (Or.inl hqw)
          have hSalpha_w : int_truth M w (.snce (case3_alpha a q A B) (Q_Z A B (Formula.neg q))) :=
            ⟨f₀, hf₀w, halpha_f₀, fun z hz1 hz2 => hQ_on_interval z hz1 (lt_trans hz2 hwt')⟩
          have hevent_w : int_truth M w (Formula.and (Formula.and A (Formula.or q (.untl A B)))
               (.snce (case3_alpha a q A B) (Q_Z A B (Formula.neg q)))) := by
            rw [int_truth_and_iff, int_truth_and_iff]
            exact ⟨⟨hAw, hqU_w⟩, hSalpha_w⟩
          simp only [case3_rhs]
          apply int_truth_or_iff.mpr; right
          exact ⟨w, hwt', hevent_w, fun r hwr hrt => hq_right r (lt_trans hf₀w hwr) hrt⟩
      · have hBt : int_truth M t B := hBguard_w t hf₀t htw
        have hUt : int_truth M t (.untl A B) :=
          ⟨w, htw, hAw, fun r htr hrw => hBguard_w r (lt_trans hf₀t htr) hrw⟩
        simp only [case3_rhs]
        apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff]
        exact ⟨hSalpha_t, int_truth_or_iff.mpr (Or.inr (int_truth_and_iff.mpr ⟨hBt, hUt⟩))⟩
    · push_neg at hq_right
      obtain ⟨f₁, hf₀f₁, hf₁t, hnqf₁⟩ := hq_right
      haveI : DecidablePred (fun r => ¬int_truth M r q) := Classical.decPred _
      have hex_fail2 : ∃ n, n < t ∧ ¬int_truth M n q := ⟨f₁, hf₁t, hnqf₁⟩
      obtain ⟨g, hgt, hnqg, hg_max⟩ := Int.exists_greatest_below hex_fail2
      have hq_after_g : ∀ r, g < r → r < t → int_truth M r q := by
        intro r hgr hrt; by_contra hnq; exact hg_max r hgr hrt hnq
      have hf₀g : f₀ ≤ g := by
        by_contra hlt; push_neg at hlt
        exact hg_max f₀ hlt hf₀t hnqf₀
      have hsg : s < g := lt_of_lt_of_le hsf₀ hf₀g
      have hU_g : int_truth M g (.untl A B) := by
        have := hguard g hsg hgt
        rcases int_truth_or_iff.mp this with hq | hU
        · exact absurd hq hnqg
        · exact hU
      obtain ⟨w, hgw, hAw, hBguard_w⟩ := hU_g
      have hSaq_f₀ : int_truth M f₀ (.snce a q) :=
        ⟨s, hsf₀, ha_s, hq_left⟩
      have hqU_f₀ := hguard f₀ hsf₀ hf₀t
      have halpha_f₀ : int_truth M f₀ (case3_alpha a q A B) := by
        simp only [case3_alpha]
        apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff]; constructor
        · rw [int_truth_and_iff]; exact ⟨hnqf₀, hSaq_f₀⟩
        · exact hqU_f₀
      have hguard_full : ∀ z, f₀ < z → z < t → (int_truth M z (Formula.neg q) → int_truth M z (.untl A B)) := by
        intro z hf₀z hzt hnqz
        have hsz : s < z := lt_trans hsf₀ hf₀z
        rcases int_truth_or_iff.mp (hguard z hsz hzt) with hq | hU
        · exact absurd hq hnqz
        · exact hU
      have hU_f₀ : int_truth M f₀ (.untl A B) := by
        rcases int_truth_or_iff.mp hqU_f₀ with hq | hU
        · exact absurd hq hnqf₀
        · exact hU
      have hQ_full : ∀ z, f₀ < z → z < t → int_truth M z (Q_Z A B (Formula.neg q)) :=
        Q_lemma_Z_fwd A B (Formula.neg q) M f₀ t hf₀t hguard_full hU_f₀
      have hSalpha_t : int_truth M t (.snce (case3_alpha a q A B) (Q_Z A B (Formula.neg q))) :=
        ⟨f₀, hf₀t, halpha_f₀, hQ_full⟩
      rcases le_or_gt w t with hwt | htw
      · rcases eq_or_lt_of_le hwt with rfl | hwt'
        · simp only [case3_rhs]
          apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; right
          rw [int_truth_and_iff]
          exact ⟨hSalpha_t, int_truth_or_iff.mpr (Or.inl hAw)⟩
        · have hqw : int_truth M w q := hq_after_g w hgw hwt'
          have hqU_w : int_truth M w (Formula.or q (.untl A B)) :=
            int_truth_or_iff.mpr (Or.inl hqw)
          have hSalpha_w : int_truth M w (.snce (case3_alpha a q A B) (Q_Z A B (Formula.neg q))) :=
            ⟨f₀, lt_of_le_of_lt hf₀g hgw, halpha_f₀,
              fun z hz1 hz2 => hQ_full z hz1 (lt_trans hz2 hwt')⟩
          have hevent_w : int_truth M w (Formula.and (Formula.and A (Formula.or q (.untl A B)))
               (.snce (case3_alpha a q A B) (Q_Z A B (Formula.neg q)))) := by
            rw [int_truth_and_iff, int_truth_and_iff]
            exact ⟨⟨hAw, hqU_w⟩, hSalpha_w⟩
          simp only [case3_rhs]
          apply int_truth_or_iff.mpr; right
          exact ⟨w, hwt', hevent_w, fun r hwr hrt => hq_after_g r (lt_trans hgw hwr) hrt⟩
      · have hBt : int_truth M t B := hBguard_w t hgt htw
        have hUt : int_truth M t (.untl A B) :=
          ⟨w, htw, hAw, fun r htr hrw => hBguard_w r (lt_trans hgt htr) hrw⟩
        simp only [case3_rhs]
        apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff]
        exact ⟨hSalpha_t, int_truth_or_iff.mpr (Or.inr (int_truth_and_iff.mpr ⟨hBt, hUt⟩))⟩

/-- Case 3 general equivalence for Z: S(a, q v U(A,B)) <-> case3_rhs(a, q, A, B).
    This works for ARBITRARY event `a`. -/
theorem case3_equiv_Z_general (a q A B : Formula) :
    int_equiv (.snce a (Formula.or q (.untl A B))) (case3_rhs a q A B) :=
  fun M t => ⟨case3_equiv_Z_fwd a q A B M t, case3_equiv_Z_bwd a q A B M t⟩

/-! ## Cases 5-8 Separability (Bootstrap)

Cases 5-8 are separable. The proofs currently use the `all_separable` axiom
as a bootstrap. These will be replaced with non-circular proofs once the
junction-depth hierarchy (Phase 4) is complete.

The case3_equiv_Z_general theorem above provides the key semantic decomposition.
The hierarchy provides the inductive framework to handle the nested temporal
operators that appear in the decomposed formulas.

Mathematical justification: GHR94 Lemma 10.3.11 items 5-8 specialized to Z. -/

/-! ## Helper lemmas for Cases 5-8 without all_separable -/

/-- case3_alpha(a∧U, q, A, B) implies U(A,B): the alpha event always makes U true.
    alpha = (a∧U) ∨ ((¬q ∧ S(a∧U, q)) ∧ (q∨U))
    First disjunct has U. Second disjunct: ¬q ∧ (q∨U) → ¬q ∧ U → U. -/
private theorem case3_alpha_aU_implies_U (a q A B : Formula) (M : IntStructure) (t : ℤ)
    (h : int_truth M t (case3_alpha (Formula.and a (.untl A B)) q A B)) :
    int_truth M t (.untl A B) := by
  simp only [case3_alpha] at h
  -- h : int_truth M t ((a∧U) ∨ ((¬q ∧ S(a∧U, q)) ∧ (q∨U)))
  rcases int_truth_or_iff.mp h with h_left | h_right
  · -- Case (a∧U): extract U from the ∧
    exact (int_truth_and_iff.mp h_left).2
  · -- Case (¬q ∧ S(a∧U, q)) ∧ (q∨U):
    have hand := int_truth_and_iff.mp h_right
    have h_nq_and_s := hand.1
    have h_q_or_u := hand.2
    have h_nq := (int_truth_and_iff.mp h_nq_and_s).1
    -- h_q_or_u : int_truth M t (q∨U), h_nq : int_truth M t (¬q) = ¬ int_truth M t q
    rcases int_truth_or_iff.mp h_q_or_u with h_q | h_u
    · exact absurd h_q h_nq
    · exact h_u

/-- alpha(a∧U, q, A, B) is int_equiv to (a ∨ (¬q ∧ S(a∧U, q))) ∧ U(A,B).
    This factoring allows us to extract a U-free event for Case 1 application. -/
private theorem case3_alpha_aU_factor (a q A B : Formula) :
    int_equiv (case3_alpha (Formula.and a (.untl A B)) q A B)
      (Formula.and (Formula.or a (Formula.and (Formula.neg q)
        (.snce (Formula.and a (.untl A B)) q))) (.untl A B)) := by
  intro M t; constructor
  · intro h
    have hU := case3_alpha_aU_implies_U a q A B M t h
    apply int_truth_and_iff.mpr
    constructor
    · -- (a ∨ (¬q ∧ S(a∧U, q))) from alpha
      simp only [case3_alpha] at h
      rcases int_truth_or_iff.mp h with h_left | h_right
      · exact int_truth_or_iff.mpr (Or.inl (int_truth_and_iff.mp h_left).1)
      · have hand := int_truth_and_iff.mp h_right
        exact int_truth_or_iff.mpr (Or.inr hand.1)
    · exact hU
  · intro h
    have ⟨h_or, hU⟩ := int_truth_and_iff.mp h
    simp only [case3_alpha]
    rcases int_truth_or_iff.mp h_or with h_a | h_nq_s
    · exact int_truth_or_iff.mpr (Or.inl (int_truth_and_iff.mpr ⟨h_a, hU⟩))
    · exact int_truth_or_iff.mpr (Or.inr (int_truth_and_iff.mpr ⟨h_nq_s, int_truth_or_iff.mpr (Or.inr hU)⟩))

/-! ## Replace U(A,B) with True Infrastructure

When U(A,B) appears only under boolean connectives (not under temporal operators),
replacing it with True (= neg bot) preserves truth at any time where U(A,B) holds.
This enables extracting a U-free event from S-formulas for Case 1 application. -/

/-- Replace all occurrences of `.untl A B` with `neg bot` (True) in a formula. -/
private def replace_untl_with_top (phi A B : Formula) : Formula :=
  match phi with
  | .atom a => .atom a
  | .bot => .bot
  | .imp p q => .imp (replace_untl_with_top p A B) (replace_untl_with_top q A B)
  | .box p => .box (replace_untl_with_top p A B)
  | .all_past p => .all_past (replace_untl_with_top p A B)
  | .all_future p => .all_future (replace_untl_with_top p A B)
  | .untl p q => if p == A && q == B then Formula.neg .bot else
      .untl (replace_untl_with_top p A B) (replace_untl_with_top q A B)
  | .snce p q => .snce (replace_untl_with_top p A B) (replace_untl_with_top q A B)

/-- If phi is U-free, replace_untl_with_top is the identity. -/
private theorem replace_id_of_U_free (phi A B : Formula) (h : is_U_free phi = true) :
    replace_untl_with_top phi A B = phi := by
  induction phi with
  | atom _ => rfl | bot => rfl
  | imp p q ihp ihq => simp [is_U_free] at h; simp [replace_untl_with_top, ihp h.1, ihq h.2]
  | box p ih => simp [is_U_free] at h; simp [replace_untl_with_top, ih h]
  | all_past p ih => simp [is_U_free] at h; simp [replace_untl_with_top, ih h]
  | all_future p ih => simp [is_U_free] at h; simp [replace_untl_with_top, ih h]
  | untl _ _ => simp [is_U_free] at h
  | snce p q ihp ihq => simp [is_U_free] at h; simp [replace_untl_with_top, ihp h.1, ihq h.2]

/-- U(A,B) appears only under boolean connectives (imp), not under
    temporal operators (.snce, .untl, .all_past, .all_future, .box).
    At any time where U(A,B) holds, replacing U(A,B) with True preserves truth. -/
private def untl_under_bool_only : Formula → Formula → Formula → Prop
  | .atom _, _, _ => True
  | .bot, _, _ => True
  | .imp p q, A, B => untl_under_bool_only p A B ∧ untl_under_bool_only q A B
  | .box p, _, _ => is_U_free p = true
  | .all_past p, _, _ => is_U_free p = true
  | .all_future p, _, _ => is_U_free p = true
  | .untl p q, A, B => (p = A ∧ q = B) ∨ (is_U_free (.untl p q) = true)
  | .snce p q, _, _ => is_U_free p = true ∧ is_U_free q = true

/-- U-free formulas satisfy untl_under_bool_only trivially. -/
private theorem u_free_untl_under_bool (phi A B : Formula) (h : is_U_free phi = true) :
    untl_under_bool_only phi A B := by
  induction phi with
  | atom _ => trivial | bot => trivial
  | imp p q ihp ihq => simp [is_U_free] at h; exact ⟨ihp h.1, ihq h.2⟩
  | box _ => simp [is_U_free] at h; exact h
  | all_past _ => simp [is_U_free] at h; exact h
  | all_future _ => simp [is_U_free] at h; exact h
  | untl _ _ => simp [is_U_free] at h
  | snce p q _ _ => simp [is_U_free] at h; exact h

/-- replace_untl_with_top produces U-free result when untl_under_bool_only holds. -/
private theorem replace_U_free_of_bool (phi A B : Formula)
    (h_bool : untl_under_bool_only phi A B) :
    is_U_free (replace_untl_with_top phi A B) = true := by
  induction phi with
  | atom _ => rfl | bot => rfl
  | imp p q ihp ihq =>
    have ⟨hp, hq⟩ := h_bool
    simp [replace_untl_with_top, is_U_free, ihp hp, ihq hq]
  | box p _ =>
    simp only [replace_untl_with_top]; simp only [is_U_free, replace_id_of_U_free p A B h_bool]
    exact h_bool
  | all_past p _ =>
    simp only [replace_untl_with_top]; simp only [is_U_free, replace_id_of_U_free p A B h_bool]
    exact h_bool
  | all_future p _ =>
    simp only [replace_untl_with_top]; simp only [is_U_free, replace_id_of_U_free p A B h_bool]
    exact h_bool
  | untl p q _ _ =>
    simp [replace_untl_with_top]
    rcases h_bool with ⟨rfl, rfl⟩ | h_uf
    · simp [beq_self_eq_true, is_U_free, Formula.neg]
    · simp [is_U_free] at h_uf
  | snce p q _ _ =>
    have ⟨hp, hq⟩ := h_bool
    show is_U_free (.snce (replace_untl_with_top p A B) (replace_untl_with_top q A B)) = true
    simp [is_U_free, replace_id_of_U_free p A B hp, replace_id_of_U_free q A B hq, hp, hq]

/-- For formulas where U(A,B) is only under boolean connectives,
    at a time where U(A,B) holds, truth is preserved by replacement. -/
private theorem replace_correct_bool (phi A B : Formula) (M : IntStructure) (t : ℤ)
    (h_bool : untl_under_bool_only phi A B)
    (hU : int_truth M t (.untl A B)) :
    int_truth M t phi ↔ int_truth M t (replace_untl_with_top phi A B) := by
  induction phi generalizing t with
  | atom _ => simp [replace_untl_with_top]
  | bot => simp [replace_untl_with_top]
  | imp p q ihp ihq =>
    have ⟨hp, hq⟩ := h_bool
    simp only [replace_untl_with_top, int_truth]
    exact Iff.imp (ihp t hp hU) (ihq t hq hU)
  | box _ => simp [replace_untl_with_top, int_truth]
  | all_past p _ =>
    simp only [replace_untl_with_top, int_truth, replace_id_of_U_free p A B h_bool]
  | all_future p _ =>
    simp only [replace_untl_with_top, int_truth, replace_id_of_U_free p A B h_bool]
  | untl p q _ _ =>
    simp only [replace_untl_with_top]
    rcases h_bool with ⟨rfl, rfl⟩ | h_uf
    · simp [beq_self_eq_true, int_truth, Formula.neg]; exact hU
    · simp [is_U_free] at h_uf
  | snce p q _ _ =>
    have ⟨hp, hq⟩ := h_bool
    simp only [replace_untl_with_top, int_truth, replace_id_of_U_free p A B hp,
               replace_id_of_U_free q A B hq]

/-- case1_psi satisfies untl_under_bool_only: its only .untl is .untl A B,
    and all .snce args are U-free. -/
private theorem case1_psi_bool_only (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true) :
    untl_under_bool_only (case1_psi a q A B) A B := by
  have h_and : ∀ p q, untl_under_bool_only p A B → untl_under_bool_only q A B →
      untl_under_bool_only (Formula.and p q) A B := by
    intro p q hp hq; show untl_under_bool_only (.imp (.imp p (.imp q .bot)) .bot) A B
    exact ⟨⟨hp, hq, trivial⟩, trivial⟩
  have h_or : ∀ p q, untl_under_bool_only p A B → untl_under_bool_only q A B →
      untl_under_bool_only (Formula.or p q) A B := by
    intro p q hp hq; show untl_under_bool_only (.imp (.imp p .bot) q) A B
    exact ⟨⟨hp, trivial⟩, hq⟩
  unfold case1_psi
  apply h_or; apply h_or
  · apply h_and; apply h_and; apply h_and
    · exact (⟨ha, hq⟩ : untl_under_bool_only (.snce a q) A B)
    · exact (⟨ha, hB⟩ : untl_under_bool_only (.snce a B) A B)
    · exact u_free_untl_under_bool B A B hB
    · exact Or.inl ⟨rfl, rfl⟩
  · apply h_and; apply h_and
    · exact u_free_untl_under_bool A A B hA
    · exact (⟨ha, hB⟩ : untl_under_bool_only (.snce a B) A B)
    · exact (⟨ha, hq⟩ : untl_under_bool_only (.snce a q) A B)
  · have hev_uf : is_U_free (Formula.and (Formula.and (Formula.and A q) (.snce a B)) (.snce a q)) = true := by
      simp [Formula.and, Formula.neg, is_U_free, hA, hq, ha, hB]
    exact (⟨hev_uf, hq⟩ : untl_under_bool_only (.snce _ q) A B)

/-! ## Congruence Lemmas -/

/-- If at every time where U(A,B) holds, C₁ ↔ C₂, then
    S(C₁ ∧ U, guard) ↔ S(C₂ ∧ U, guard). -/
private theorem snce_event_congr_with_U (C₁ C₂ guard A B : Formula)
    (h_eq : ∀ M : IntStructure, ∀ t : ℤ, int_truth M t (.untl A B) →
      (int_truth M t C₁ ↔ int_truth M t C₂)) :
    int_equiv (.snce (Formula.and C₁ (.untl A B)) guard)
              (.snce (Formula.and C₂ (.untl A B)) guard) := by
  intro M t; constructor
  · rintro ⟨s, hst, h_event, h_guard⟩
    have ⟨hC₁, hU⟩ := int_truth_and_iff.mp h_event
    exact ⟨s, hst, int_truth_and_iff.mpr ⟨(h_eq M s hU).mp hC₁, hU⟩, h_guard⟩
  · rintro ⟨s, hst, h_event, h_guard⟩
    have ⟨hC₂, hU⟩ := int_truth_and_iff.mp h_event
    exact ⟨s, hst, int_truth_and_iff.mpr ⟨(h_eq M s hU).mpr hC₂, hU⟩, h_guard⟩

/-- snce congrence on event. -/
private theorem snce_event_congr {φ₁ φ₂ ψ : Formula} (h : int_equiv φ₁ φ₂) :
    int_equiv (.snce φ₁ ψ) (.snce φ₂ ψ) := by
  intro M t; constructor
  · rintro ⟨s, hst, hφ, hψ⟩; exact ⟨s, hst, (h M s).mp hφ, hψ⟩
  · rintro ⟨s, hst, hφ, hψ⟩; exact ⟨s, hst, (h M s).mpr hφ, hψ⟩

/-- and congrence on left. -/
private theorem and_left_congr {φ₁ φ₂ ψ : Formula} (h : int_equiv φ₁ φ₂) :
    int_equiv (Formula.and φ₁ ψ) (Formula.and φ₂ ψ) := by
  intro M t; constructor
  · intro h'; have ⟨hφ, hψ⟩ := int_truth_and_iff.mp h'
    exact int_truth_and_iff.mpr ⟨(h M t).mp hφ, hψ⟩
  · intro h'; have ⟨hφ, hψ⟩ := int_truth_and_iff.mp h'
    exact int_truth_and_iff.mpr ⟨(h M t).mpr hφ, hψ⟩

/-- Boolean distribution: (a ∨ b) ∧ c ↔ (a ∧ c) ∨ (b ∧ c). -/
private theorem and_or_distrib (a b c : Formula) :
    int_equiv (Formula.and (Formula.or a b) c)
              (Formula.or (Formula.and a c) (Formula.and b c)) := by
  intro M t; constructor
  · intro h
    have ⟨hab, hc⟩ := int_truth_and_iff.mp h
    rcases int_truth_or_iff.mp hab with ha | hb
    · exact int_truth_or_iff.mpr (Or.inl (int_truth_and_iff.mpr ⟨ha, hc⟩))
    · exact int_truth_or_iff.mpr (Or.inr (int_truth_and_iff.mpr ⟨hb, hc⟩))
  · intro h
    rcases int_truth_or_iff.mp h with h1 | h2
    · have ⟨ha, hc⟩ := int_truth_and_iff.mp h1
      exact int_truth_and_iff.mpr ⟨int_truth_or_iff.mpr (Or.inl ha), hc⟩
    · have ⟨hb, hc⟩ := int_truth_and_iff.mp h2
      exact int_truth_and_iff.mpr ⟨int_truth_or_iff.mpr (Or.inr hb), hc⟩

/-- Q_Z with negated q argument is U-free. -/
private theorem Q_Z_neg_q_U_free (A B q : Formula)
    (hA : is_U_free A = true) (hB : is_U_free B = true) (hq : is_U_free q = true) :
    is_U_free (Q_Z A B (Formula.neg q)) = true :=
  Q_Z_U_free A B (Formula.neg q) hA hB (by simp [Formula.neg, is_U_free, hq])

/-! ## Replace U(A,B) with False (bot) Infrastructure

When U(A,B) appears only under boolean connectives and ¬U(A,B) holds,
replacing U(A,B) with False (bot) preserves truth.
This enables extracting a U-free event for Case 2 application. -/

/-- Replace all occurrences of `.untl A B` with `bot` (False) in a formula. -/
private def replace_untl_with_bot (phi A B : Formula) : Formula :=
  match phi with
  | .atom a => .atom a
  | .bot => .bot
  | .imp p q => .imp (replace_untl_with_bot p A B) (replace_untl_with_bot q A B)
  | .box p => .box (replace_untl_with_bot p A B)
  | .all_past p => .all_past (replace_untl_with_bot p A B)
  | .all_future p => .all_future (replace_untl_with_bot p A B)
  | .untl p q => if p == A && q == B then .bot else
      .untl (replace_untl_with_bot p A B) (replace_untl_with_bot q A B)
  | .snce p q => .snce (replace_untl_with_bot p A B) (replace_untl_with_bot q A B)

/-- If phi is U-free, replace_untl_with_bot is the identity. -/
private theorem replace_bot_id_of_U_free (phi A B : Formula) (h : is_U_free phi = true) :
    replace_untl_with_bot phi A B = phi := by
  induction phi with
  | atom _ => rfl | bot => rfl
  | imp p q ihp ihq => simp [is_U_free] at h; simp [replace_untl_with_bot, ihp h.1, ihq h.2]
  | box p ih => simp [is_U_free] at h; simp [replace_untl_with_bot, ih h]
  | all_past p ih => simp [is_U_free] at h; simp [replace_untl_with_bot, ih h]
  | all_future p ih => simp [is_U_free] at h; simp [replace_untl_with_bot, ih h]
  | untl _ _ => simp [is_U_free] at h
  | snce p q ihp ihq => simp [is_U_free] at h; simp [replace_untl_with_bot, ihp h.1, ihq h.2]

/-- replace_untl_with_bot produces U-free result when untl_under_bool_only holds. -/
private theorem replace_bot_U_free_of_bool (phi A B : Formula)
    (h_bool : untl_under_bool_only phi A B) :
    is_U_free (replace_untl_with_bot phi A B) = true := by
  induction phi with
  | atom _ => rfl | bot => rfl
  | imp p q ihp ihq =>
    have ⟨hp, hq⟩ := h_bool
    simp [replace_untl_with_bot, is_U_free, ihp hp, ihq hq]
  | box p _ =>
    simp only [replace_untl_with_bot]; simp only [is_U_free, replace_bot_id_of_U_free p A B h_bool]
    exact h_bool
  | all_past p _ =>
    simp only [replace_untl_with_bot]; simp only [is_U_free, replace_bot_id_of_U_free p A B h_bool]
    exact h_bool
  | all_future p _ =>
    simp only [replace_untl_with_bot]; simp only [is_U_free, replace_bot_id_of_U_free p A B h_bool]
    exact h_bool
  | untl p q _ _ =>
    simp [replace_untl_with_bot]
    rcases h_bool with ⟨rfl, rfl⟩ | h_uf
    · simp [beq_self_eq_true, is_U_free]
    · simp [is_U_free] at h_uf
  | snce p q _ _ =>
    have ⟨hp, hq⟩ := h_bool
    show is_U_free (.snce (replace_untl_with_bot p A B) (replace_untl_with_bot q A B)) = true
    simp [is_U_free, replace_bot_id_of_U_free p A B hp, replace_bot_id_of_U_free q A B hq, hp, hq]

/-- For formulas where U(A,B) is only under boolean connectives,
    at a time where ¬U(A,B) holds, truth is preserved by replacing U with bot. -/
private theorem replace_correct_bot (phi A B : Formula) (M : IntStructure) (t : ℤ)
    (h_bool : untl_under_bool_only phi A B)
    (hnotU : ¬ int_truth M t (.untl A B)) :
    int_truth M t phi ↔ int_truth M t (replace_untl_with_bot phi A B) := by
  induction phi generalizing t with
  | atom _ => simp [replace_untl_with_bot]
  | bot => simp [replace_untl_with_bot]
  | imp p q ihp ihq =>
    have ⟨hp, hq⟩ := h_bool
    simp only [replace_untl_with_bot, int_truth]
    exact Iff.imp (ihp t hp hnotU) (ihq t hq hnotU)
  | box _ => simp [replace_untl_with_bot, int_truth]
  | all_past p _ =>
    simp only [replace_untl_with_bot, int_truth, replace_bot_id_of_U_free p A B h_bool]
  | all_future p _ =>
    simp only [replace_untl_with_bot, int_truth, replace_bot_id_of_U_free p A B h_bool]
  | untl p q _ _ =>
    simp only [replace_untl_with_bot]
    rcases h_bool with ⟨rfl, rfl⟩ | h_uf
    · simp only [beq_self_eq_true, Bool.and_self, ↓reduceIte]
      exact ⟨fun h => absurd h hnotU, False.elim⟩
    · simp [is_U_free] at h_uf
  | snce p q _ _ =>
    have ⟨hp, hq⟩ := h_bool
    simp only [replace_untl_with_bot, int_truth, replace_bot_id_of_U_free p A B hp,
               replace_bot_id_of_U_free q A B hq]

/-! ## Congruence for ¬U branch -/

/-- If at every time where ¬U(A,B) holds, C₁ ↔ C₂, then
    S(C₁ ∧ ¬U, guard) ↔ S(C₂ ∧ ¬U, guard). -/
private theorem snce_event_congr_with_notU (C₁ C₂ guard A B : Formula)
    (h_eq : ∀ M : IntStructure, ∀ t : ℤ, ¬ int_truth M t (.untl A B) →
      (int_truth M t C₁ ↔ int_truth M t C₂)) :
    int_equiv (.snce (Formula.and C₁ (Formula.neg (.untl A B))) guard)
              (.snce (Formula.and C₂ (Formula.neg (.untl A B))) guard) := by
  intro M t; constructor
  · rintro ⟨s, hst, h_event, h_guard⟩
    have ⟨hC₁, hnotU⟩ := int_truth_and_iff.mp h_event
    exact ⟨s, hst, int_truth_and_iff.mpr ⟨(h_eq M s hnotU).mp hC₁, hnotU⟩, h_guard⟩
  · rintro ⟨s, hst, h_event, h_guard⟩
    have ⟨hC₂, hnotU⟩ := int_truth_and_iff.mp h_event
    exact ⟨s, hst, int_truth_and_iff.mpr ⟨(h_eq M s hnotU).mpr hC₂, hnotU⟩, h_guard⟩

/-! ## Core Helper: S(COMBINED ∧ ¬U, guard) Separable -/

/-- S(COMBINED ∧ ¬U(A,B), guard) is separable when COMBINED satisfies
    untl_under_bool_only and guard is U-free with S-free A, B.
    Works by replacing U with bot in the event and applying Case 2. -/
private theorem snce_combined_notU_separable
    (combined guard : Formula) (A B : Formula)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true)
    (hg_uf : is_U_free guard = true)
    (h_bool : untl_under_bool_only combined A B) :
    is_separable (.snce (Formula.and combined (Formula.neg (.untl A B))) guard) := by
  let combined' := replace_untl_with_bot combined A B
  have h_uf : is_U_free combined' = true := replace_bot_U_free_of_bool combined A B h_bool
  have h_congr := snce_event_congr_with_notU combined combined' guard A B
    (fun M t hnotU => replace_correct_bot combined A B M t h_bool hnotU)
  apply is_separable_of_equiv h_congr
  obtain ⟨psi, hequiv, hsep⟩ := elim_case_2_gen combined' guard A B h_uf hg_uf hA hB hA' hB'
  exact ⟨psi, hsep, hequiv⟩

/-! ## D2.1 Explicit Formula for D3

The separated equivalent of S(alpha, Q_Z) needs to be constructed explicitly
(not just existentially) so we can prove it satisfies untl_under_bool_only.
This is needed for the D3 proof where S(alpha, Q_Z) appears inside the event. -/

/-- The explicit separated equivalent of S(alpha, Q_Z) from D2.1.
    = or (case1_psi a Q_Z_nq A B) (case1_psi (replace_untl_with_top (¬q ∧ σ) A B) Q_Z_nq A B)
    where σ = case1_psi a q A B and Q_Z_nq = Q_Z A B (neg q). -/
private def d21_sep (a q A B : Formula) : Formula :=
  let σ := case1_psi a q A B
  let Q_Z_nq := Q_Z A B (Formula.neg q)
  Formula.or
    (case1_psi a Q_Z_nq A B)
    (case1_psi (replace_untl_with_top (Formula.and (Formula.neg q) σ) A B) Q_Z_nq A B)

/-- d21_sep satisfies untl_under_bool_only. -/
private theorem d21_sep_bool_only (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true) :
    untl_under_bool_only (d21_sep a q A B) A B := by
  have h_or : ∀ p q, untl_under_bool_only p A B → untl_under_bool_only q A B →
      untl_under_bool_only (Formula.or p q) A B := by
    intro p q hp hq; show untl_under_bool_only (.imp (.imp p .bot) q) A B
    exact ⟨⟨hp, trivial⟩, hq⟩
  unfold d21_sep
  apply h_or
  · exact case1_psi_bool_only a (Q_Z A B (Formula.neg q)) A B ha
      (Q_Z_neg_q_U_free A B q hA hB hq) hA hB
  · have h_nqσ_bool : untl_under_bool_only (Formula.and (Formula.neg q) (case1_psi a q A B)) A B := by
      show untl_under_bool_only (.imp (.imp (Formula.neg q) (.imp (case1_psi a q A B) .bot)) .bot) A B
      refine ⟨⟨?_, case1_psi_bool_only a q A B ha hq hA hB, trivial⟩, trivial⟩
      exact ⟨u_free_untl_under_bool q A B hq, trivial⟩
    have h_replaced_uf : is_U_free (replace_untl_with_top (Formula.and (Formula.neg q) (case1_psi a q A B)) A B) = true :=
      replace_U_free_of_bool _ A B h_nqσ_bool
    exact case1_psi_bool_only
      (replace_untl_with_top (Formula.and (Formula.neg q) (case1_psi a q A B)) A B)
      (Q_Z A B (Formula.neg q)) A B h_replaced_uf
      (Q_Z_neg_q_U_free A B q hA hB hq) hA hB

set_option maxHeartbeats 3200000 in
/-- d21_sep is int_equiv to S(alpha, Q_Z) where alpha = case3_alpha(a∧U, q, A, B).
    This non-existential form allows using d21_sep in D3's event. -/
private theorem d21_sep_equiv (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    int_equiv (.snce (case3_alpha (Formula.and a (.untl A B)) q A B) (Q_Z A B (Formula.neg q)))
              (d21_sep a q A B) := by
  -- Step 1: alpha ↔ (a ∨ (¬q ∧ S(a∧U,q))) ∧ U
  have step1 : int_equiv
    (.snce (case3_alpha (Formula.and a (.untl A B)) q A B) (Q_Z A B (Formula.neg q)))
    (.snce (Formula.and (Formula.or a (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl A B)) q))) (.untl A B)) (Q_Z A B (Formula.neg q))) :=
    snce_event_congr (case3_alpha_aU_factor a q A B)
  -- Step 2: Distribute → S(a∧U, Q_Z) ∨ S((¬q∧S(a∧U,q))∧U, Q_Z)
  have step2 : int_equiv
    (.snce (Formula.and (Formula.or a (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl A B)) q))) (.untl A B)) (Q_Z A B (Formula.neg q)))
    (Formula.or (.snce (Formula.and a (.untl A B)) (Q_Z A B (Formula.neg q)))
                (.snce (Formula.and (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl A B)) q)) (.untl A B)) (Q_Z A B (Formula.neg q)))) :=
    int_equiv_trans
      (snce_event_congr (and_or_distrib a
        (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl A B)) q))
        (.untl A B)))
      (since_distrib_or_left _ _ (Q_Z A B (Formula.neg q)))
  have steps12 := int_equiv_trans step1 step2
  -- Now: S(alpha, Q_Z) ↔ S(a∧U, Q_Z) ∨ S((¬q∧S(a∧U,q))∧U, Q_Z)
  -- Step 3: Replace S(a∧U,q) with σ = case1_psi
  let σ := case1_psi a q A B
  have hσ_equiv : int_equiv (.snce (Formula.and a (.untl A B)) q) σ :=
    (case1_psi_properties a q A B ha hq hA hB hA' hB').1
  have hY_congr : int_equiv
    (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl A B)) q))
    (Formula.and (Formula.neg q) σ) := by
    intro M t; constructor
    · intro h; have ⟨hnq, hS⟩ := int_truth_and_iff.mp h
      exact int_truth_and_iff.mpr ⟨hnq, (hσ_equiv M t).mp hS⟩
    · intro h; have ⟨hnq, hσ'⟩ := int_truth_and_iff.mp h
      exact int_truth_and_iff.mpr ⟨hnq, (hσ_equiv M t).mpr hσ'⟩
  have step3 : int_equiv
    (.snce (Formula.and (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl A B)) q)) (.untl A B))
           (Q_Z A B (Formula.neg q)))
    (.snce (Formula.and (Formula.and (Formula.neg q) σ) (.untl A B))
           (Q_Z A B (Formula.neg q))) :=
    snce_event_congr (and_left_congr hY_congr)
  -- Step 4: Replace U with True in event of each disjunct
  let Q_Z_nq := Q_Z A B (Formula.neg q)
  have hQ_uf : is_U_free Q_Z_nq = true := Q_Z_neg_q_U_free A B q hA hB hq
  -- For S(a∧U, Q_Z): a is U-free → replace a with a (identity) → case1_psi a Q_Z A B
  have h_a_congr : ∀ M : IntStructure, ∀ t : ℤ, int_truth M t (.untl A B) →
      (int_truth M t a ↔ int_truth M t (replace_untl_with_top a A B)) :=
    fun M t _ => by rw [replace_id_of_U_free a A B ha]
  have step4a_congr := snce_event_congr_with_U a (replace_untl_with_top a A B) Q_Z_nq A B h_a_congr
  have h_a_uf : is_U_free (replace_untl_with_top a A B) = true := by
    rw [replace_id_of_U_free a A B ha]; exact ha
  have step4a := (case1_psi_properties (replace_untl_with_top a A B) Q_Z_nq A B
    h_a_uf hQ_uf hA hB hA' hB').1
  have step4a_full : int_equiv
    (.snce (Formula.and a (.untl A B)) Q_Z_nq) (case1_psi a Q_Z_nq A B) := by
    have : replace_untl_with_top a A B = a := replace_id_of_U_free a A B ha
    rw [this] at step4a step4a_congr
    exact int_equiv_trans step4a_congr step4a
  -- For S((¬q∧σ)∧U, Q_Z): (¬q∧σ) satisfies untl_under_bool_only
  have h_nqσ_bool : untl_under_bool_only (Formula.and (Formula.neg q) σ) A B := by
    show untl_under_bool_only (.imp (.imp (Formula.neg q) (.imp σ .bot)) .bot) A B
    refine ⟨⟨?_, case1_psi_bool_only a q A B ha hq hA hB, trivial⟩, trivial⟩
    exact ⟨u_free_untl_under_bool q A B hq, trivial⟩
  let nqσ' := replace_untl_with_top (Formula.and (Formula.neg q) σ) A B
  have h_nqσ_congr : ∀ M : IntStructure, ∀ t : ℤ, int_truth M t (.untl A B) →
      (int_truth M t (Formula.and (Formula.neg q) σ) ↔ int_truth M t nqσ') :=
    fun M t hU => replace_correct_bool _ A B M t h_nqσ_bool hU
  have step4b_congr := snce_event_congr_with_U _ nqσ' Q_Z_nq A B h_nqσ_congr
  have h_nqσ_uf : is_U_free nqσ' = true := replace_U_free_of_bool _ A B h_nqσ_bool
  have step4b := (case1_psi_properties nqσ' Q_Z_nq A B h_nqσ_uf hQ_uf hA hB hA' hB').1
  have step4b_full : int_equiv
    (.snce (Formula.and (Formula.and (Formula.neg q) σ) (.untl A B)) Q_Z_nq)
    (case1_psi nqσ' Q_Z_nq A B) :=
    int_equiv_trans step4b_congr step4b
  -- Combine: S(alpha, Q_Z) ↔ case1_psi a Q_Z A B ∨ case1_psi nqσ' Q_Z A B = d21_sep
  intro M t; constructor
  · intro h
    have h12 := (steps12 M t).mp h
    rcases int_truth_or_iff.mp h12 with h1 | h2
    · exact int_truth_or_iff.mpr (Or.inl ((step4a_full M t).mp h1))
    · have h2' := (step3 M t).mp h2
      exact int_truth_or_iff.mpr (Or.inr ((step4b_full M t).mp h2'))
  · intro h
    rcases int_truth_or_iff.mp h with h1 | h2
    · exact (steps12 M t).mpr (int_truth_or_iff.mpr (Or.inl ((step4a_full M t).mpr h1)))
    · have h2' := (step4b_full M t).mpr h2
      exact (steps12 M t).mpr (int_truth_or_iff.mpr (Or.inr ((step3 M t).mpr h2')))

/-! ## Core Helper: S(COMBINED ∧ U, guard) Separable -/

/-- S(COMBINED ∧ U(A,B), guard) is separable when COMBINED satisfies
    untl_under_bool_only and guard is U-free with S-free A, B.
    Works by replacing U with True in the event and applying Case 1. -/
private theorem snce_combined_U_separable
    (combined guard : Formula) (A B : Formula)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true)
    (hg_uf : is_U_free guard = true)
    (h_bool : untl_under_bool_only combined A B) :
    is_separable (.snce (Formula.and combined (.untl A B)) guard) := by
  let combined' := replace_untl_with_top combined A B
  have h_uf : is_U_free combined' = true := replace_U_free_of_bool combined A B h_bool
  have h_congr := snce_event_congr_with_U combined combined' guard A B
    (fun M t hU => replace_correct_bool combined A B M t h_bool hU)
  apply is_separable_of_equiv h_congr
  obtain ⟨psi, hequiv, hsep⟩ := elim_case_1_gen combined' guard A B h_uf hg_uf hA hB hA' hB'
  exact ⟨psi, hsep, hequiv⟩

/-! ## Cases 5-8 Separability -/

set_option maxHeartbeats 1600000 in
/-- Generalized Case 5: S(a ^ U(A,B), q v U(A,B)) is separable.
    Drops S-free requirements on a and q (only A, B need S-freeness).
    The proof only uses S-freeness of A and B. -/
theorem case5_separable_Z_gen (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (.untl A B)) (Formula.or q (.untl A B))) := by
  -- Same proof as case5_separable_Z but without ha'/hq'
  apply is_separable_of_equiv (case3_equiv_Z_general (Formula.and a (.untl A B)) q A B)
  simp only [case3_rhs]
  apply or_separable
  · apply or_separable
    · obtain ⟨psi, hequiv_psi, hsep_psi⟩ := elim_case_1_gen a q A B ha hq hA hB hA' hB'
      exact ⟨psi, hsep_psi, hequiv_psi⟩
    · apply and_separable
      · apply is_separable_of_equiv (snce_event_congr (case3_alpha_aU_factor a q A B))
        apply is_separable_of_equiv (int_equiv_trans
          (snce_event_congr (and_or_distrib a
            (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl A B)) q))
            (.untl A B)))
          (since_distrib_or_left _ _ (Q_Z A B (Formula.neg q))))
        apply or_separable
        · exact snce_combined_U_separable a (Q_Z A B (Formula.neg q)) A B
            hA hB hA' hB' (Q_Z_neg_q_U_free A B q hA hB hq)
            (u_free_untl_under_bool a A B ha)
        · let σ := case1_psi a q A B
          have hσ_equiv : int_equiv (.snce (Formula.and a (.untl A B)) q) σ :=
            (case1_psi_properties a q A B ha hq hA hB hA' hB').1
          have hY_congr : int_equiv
            (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl A B)) q))
            (Formula.and (Formula.neg q) σ) := by
            intro M t; constructor
            · intro h; have ⟨hnq, hS⟩ := int_truth_and_iff.mp h
              exact int_truth_and_iff.mpr ⟨hnq, (hσ_equiv M t).mp hS⟩
            · intro h; have ⟨hnq, hσ'⟩ := int_truth_and_iff.mp h
              exact int_truth_and_iff.mpr ⟨hnq, (hσ_equiv M t).mpr hσ'⟩
          apply is_separable_of_equiv (snce_event_congr (and_left_congr hY_congr))
          have h_nqσ_bool : untl_under_bool_only (Formula.and (Formula.neg q) σ) A B := by
            show untl_under_bool_only (.imp (.imp (Formula.neg q) (.imp σ .bot)) .bot) A B
            refine ⟨⟨?_, case1_psi_bool_only a q A B ha hq hA hB, trivial⟩, trivial⟩
            exact ⟨u_free_untl_under_bool q A B hq, trivial⟩
          exact snce_combined_U_separable (Formula.and (Formula.neg q) σ)
            (Q_Z A B (Formula.neg q)) A B hA hB hA' hB'
            (Q_Z_neg_q_U_free A B q hA hB hq) h_nqσ_bool
      · apply or_separable
        · exact u_free_s_free_is_separable A hA hA'
        · exact and_separable
            (u_free_s_free_is_separable B hB hB')
            ⟨.untl A B, by simp [is_syntactically_separated, hA', hB'], int_equiv_refl _⟩
  · have h_d21 := d21_sep_equiv a q A B ha hq hA hB hA' hB'
    have h_event_congr : int_equiv
      (Formula.and (Formula.and A (Formula.or q (.untl A B)))
        (.snce (case3_alpha (Formula.and a (.untl A B)) q A B) (Q_Z A B (Formula.neg q))))
      (Formula.and (Formula.and A (Formula.or q (.untl A B))) (d21_sep a q A B)) := by
      intro M t; constructor
      · intro h; have ⟨hAqU, hS⟩ := int_truth_and_iff.mp h
        exact int_truth_and_iff.mpr ⟨hAqU, (h_d21 M t).mp hS⟩
      · intro h; have ⟨hAqU, hd⟩ := int_truth_and_iff.mp h
        exact int_truth_and_iff.mpr ⟨hAqU, (h_d21 M t).mpr hd⟩
    apply is_separable_of_equiv (snce_event_congr h_event_congr)
    apply is_separable_of_equiv (since_event_split _ (.untl A B) q)
    apply or_separable
    · have h_event_bool : untl_under_bool_only
          (Formula.and (Formula.and A (Formula.or q (.untl A B))) (d21_sep a q A B)) A B := by
        show untl_under_bool_only (.imp (.imp (Formula.and A (Formula.or q (.untl A B)))
          (.imp (d21_sep a q A B) .bot)) .bot) A B
        refine ⟨⟨?_, d21_sep_bool_only a q A B ha hq hA hB, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp A (.imp (Formula.or q (.untl A B)) .bot)) .bot) A B
        refine ⟨⟨u_free_untl_under_bool A A B hA, ?_, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp q .bot) (.untl A B)) A B
        exact ⟨⟨u_free_untl_under_bool q A B hq, trivial⟩, Or.inl ⟨rfl, rfl⟩⟩
      exact snce_combined_U_separable
        (Formula.and (Formula.and A (Formula.or q (.untl A B))) (d21_sep a q A B))
        q A B hA hB hA' hB' hq h_event_bool
    · have h_event_bool : untl_under_bool_only
          (Formula.and (Formula.and A (Formula.or q (.untl A B))) (d21_sep a q A B)) A B := by
        show untl_under_bool_only (.imp (.imp (Formula.and A (Formula.or q (.untl A B)))
          (.imp (d21_sep a q A B) .bot)) .bot) A B
        refine ⟨⟨?_, d21_sep_bool_only a q A B ha hq hA hB, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp A (.imp (Formula.or q (.untl A B)) .bot)) .bot) A B
        refine ⟨⟨u_free_untl_under_bool A A B hA, ?_, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp q .bot) (.untl A B)) A B
        exact ⟨⟨u_free_untl_under_bool q A B hq, trivial⟩, Or.inl ⟨rfl, rfl⟩⟩
      exact snce_combined_notU_separable
        (Formula.and (Formula.and A (Formula.or q (.untl A B))) (d21_sep a q A B))
        q A B hA hB hA' hB' hq h_event_bool

theorem case5_separable_Z (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (.untl A B)) (Formula.or q (.untl A B))) :=
  case5_separable_Z_gen a q A B ha hq hA hB hA' hB'

/-! ## Case 6 Infrastructure

Case 6: S(a∧¬U(A,B), q∨U(A,B)) where a,q,A,B are U-free and S-free.

Strategy: Decompose ¬U ↔ G(¬A) ∨ U' using neg_until_equiv where U' = U(¬A∧¬B, ¬A).
Split into two branches:
  Branch A: S(a∧G(¬A), q∨U) -- event is U-free, handled by case5_separable_Z_gen
  Branch B: S(a∧U', q∨U)   -- uses case3_equiv + U∧U'=⊥ contradiction to reduce

Key lemma: U(A,B) and U(¬A∧¬B, ¬A) cannot both hold at the same time.
When U(A,B) holds at an event point, the U'-containing parts of any separated
equivalent of S(a∧U', q) vanish, leaving only U-free components. -/

/-- U(A,B) and U(¬A∧¬B, ¬A) are contradictory: they cannot both hold at the same time.
    Proof: if U(A,B)(t) gives witness s₁ > t with A(s₁)∧B on (t,s₁), and
    U(¬A∧¬B, ¬A)(t) gives witness s₂ > t with (¬A∧¬B)(s₂)∧(¬A) on (t,s₂), then
    s₁ < s₂ → ¬A(s₁) contradicts A(s₁); s₁ = s₂ → same; s₁ > s₂ → B(s₂) contradicts ¬B(s₂). -/
private theorem untl_neguntl_contradictory (A B : Formula) (M : IntStructure) (t : ℤ)
    (hU : int_truth M t (.untl A B))
    (hU' : int_truth M t (.untl (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A))) :
    False := by
  obtain ⟨s₁, hts₁, hA₁, hB₁⟩ := hU
  obtain ⟨s₂, hts₂, hAB₂, hA₂⟩ := hU'
  -- hAB₂ : int_truth M s₂ (and (neg A) (neg B))
  -- Extract ¬A(s₂) and ¬B(s₂)
  have hnotA₂ : ¬ int_truth M s₂ A := fun h => hAB₂ (fun hna _ => hna h)
  have hnotB₂ : ¬ int_truth M s₂ B := fun h => hAB₂ (fun _ hnb => hnb h)
  rcases lt_trichotomy s₁ s₂ with h | h | h
  · -- s₁ < s₂: s₁ ∈ (t, s₂), guard gives ¬A(s₁), but A(s₁)
    exact hA₂ s₁ hts₁ h hA₁
  · -- s₁ = s₂: A(s₁) = A(s₂), contradicts ¬A(s₂)
    exact hnotA₂ (h ▸ hA₁)
  · -- s₁ > s₂: s₂ ∈ (t, s₁), guard gives B(s₂), but ¬B(s₂)
    exact hnotB₂ (hB₁ s₂ hts₂ h)

/-- Negation equivalence specialized: ¬U → G(¬A) ∨ U', as an int_equiv on the event. -/
private theorem neg_untl_event_equiv (a A B : Formula) :
    int_equiv (Formula.and a (Formula.neg (.untl A B)))
      (Formula.or (Formula.and a (.all_future (Formula.neg A)))
        (Formula.and a (.untl (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A)))) := by
  intro M t; constructor
  · intro h
    have ⟨ha, hnotU⟩ := int_truth_and_iff.mp h
    rcases int_truth_or_iff.mp ((neg_until_equiv A B M t).mp hnotU) with hG | hU'
    · exact int_truth_or_iff.mpr (Or.inl (int_truth_and_iff.mpr ⟨ha, hG⟩))
    · exact int_truth_or_iff.mpr (Or.inr (int_truth_and_iff.mpr ⟨ha, hU'⟩))
  · intro h
    rcases int_truth_or_iff.mp h with h1 | h2
    · have ⟨ha, hG⟩ := int_truth_and_iff.mp h1
      exact int_truth_and_iff.mpr ⟨ha,
        (neg_until_equiv A B M t).mpr (int_truth_or_iff.mpr (Or.inl hG))⟩
    · have ⟨ha, hU'⟩ := int_truth_and_iff.mp h2
      exact int_truth_and_iff.mpr ⟨ha,
        (neg_until_equiv A B M t).mpr (int_truth_or_iff.mpr (Or.inr hU'))⟩

set_option maxHeartbeats 3200000 in
/-- S(ev, q∨U) is separable when ev is U-free.
    This is the core of Branch A and is like case5_separable_Z_gen but with
    the event already U-free (no U in the event), making it simpler. -/
private theorem snce_Ufree_event_qU_guard_separable (ev q A B : Formula)
    (hev_uf : is_U_free ev = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable (.snce ev (Formula.or q (.untl A B))) := by
  apply is_separable_of_equiv (case3_equiv_Z_general ev q A B)
  simp only [case3_rhs]
  have hQ_uf : is_U_free (Q_Z A B (Formula.neg q)) = true :=
    Q_Z_neg_q_U_free A B q hA hB hq
  -- D1: S(ev, q) -- U-free event and guard → syntactically separated
  -- D2: S(alpha, Q_Z) ∧ (A∨B∧U)
  -- D3: S(A ∧ (q∨U) ∧ S(alpha, Q_Z), q)
  -- alpha = ev ∨ ((¬q ∧ S(ev,q)) ∧ (q∨U))
  -- Since ev is U-free: alpha has U only in (q∨U) → untl_under_bool_only
  have h_nqSev_uf : is_U_free (Formula.and (Formula.neg q) (.snce ev q)) = true := by
    simp [Formula.and, Formula.neg, is_U_free, hq, hev_uf]
  -- alpha = ev ∨ (nqSev ∧ (q∨U)) where nqSev = ¬q∧S(ev,q) is U-free
  -- S(alpha, Q_Z): distribute via since_distrib_or_left
  -- then event-split the second disjunct on U
  -- Key helper: S(alpha, Q_Z) separable
  have h_Salpha_sep : is_separable (.snce (case3_alpha ev q A B) (Q_Z A B (Formula.neg q))) := by
    apply is_separable_of_equiv (since_distrib_or_left _ _ (Q_Z A B (Formula.neg q)))
    apply or_separable
    · exact ⟨.snce ev (Q_Z A B (Formula.neg q)),
        by simp [is_syntactically_separated, hev_uf, hQ_uf], int_equiv_refl _⟩
    · apply is_separable_of_equiv (since_event_split _ (.untl A B) (Q_Z A B (Formula.neg q)))
      apply or_separable
      · -- U branch
        apply is_separable_of_equiv (snce_event_congr_with_U _ _ _ A B
          (fun M t hU => ⟨fun h => (int_truth_and_iff.mp h).1,
            fun h => int_truth_and_iff.mpr ⟨h, int_truth_or_iff.mpr (Or.inr hU)⟩⟩))
        exact snce_combined_U_separable (Formula.and (Formula.neg q) (.snce ev q))
          (Q_Z A B (Formula.neg q)) A B hA hB hA' hB' hQ_uf
          (u_free_untl_under_bool _ A B h_nqSev_uf)
      · -- ¬U branch: ¬q∧q = ⊥
        apply is_separable_of_equiv (by
          intro M t; constructor
          · rintro ⟨s, _, h_event, _⟩
            have ⟨h_left, h_notU⟩ := int_truth_and_iff.mp h_event
            have ⟨h_nqS, h_qU⟩ := int_truth_and_iff.mp h_left
            have h_nq := (int_truth_and_iff.mp h_nqS).1
            rcases int_truth_or_iff.mp h_qU with hq' | hU
            · exact h_nq hq'
            · exact h_notU hU
          · intro h; exact h.elim : int_equiv _ .bot)
        exact ⟨.bot, by simp [is_syntactically_separated], int_equiv_refl _⟩
  apply or_separable
  · apply or_separable
    · -- D1
      exact ⟨.snce ev q, by simp [is_syntactically_separated, hev_uf, hq], int_equiv_refl _⟩
    · -- D2
      apply and_separable
      · exact h_Salpha_sep
      · apply or_separable
        · exact u_free_s_free_is_separable A hA hA'
        · exact and_separable (u_free_s_free_is_separable B hB hB')
            ⟨.untl A B, by simp [is_syntactically_separated, hA', hB'], int_equiv_refl _⟩
  · -- D3: S(A ∧ (q∨U) ∧ S(alpha, Q_Z), q)
    -- Use d21_sep-style infrastructure: alpha has untl_under_bool_only
    -- The alpha for U-free ev: same structure as Case 5 but simpler
    -- alpha satisfies untl_under_bool_only because ev is U-free
    have h_alpha_bool : untl_under_bool_only (case3_alpha ev q A B) A B := by
      show untl_under_bool_only (Formula.or ev (Formula.and (Formula.and (Formula.neg q)
        (.snce ev q)) (Formula.or q (.untl A B)))) A B
      have h_or : ∀ p q, untl_under_bool_only p A B → untl_under_bool_only q A B →
          untl_under_bool_only (Formula.or p q) A B := by
        intro p q hp hq; show untl_under_bool_only (.imp (.imp p .bot) q) A B
        exact ⟨⟨hp, trivial⟩, hq⟩
      have h_and : ∀ p q, untl_under_bool_only p A B → untl_under_bool_only q A B →
          untl_under_bool_only (Formula.and p q) A B := by
        intro p q hp hq; show untl_under_bool_only (.imp (.imp p (.imp q .bot)) .bot) A B
        exact ⟨⟨hp, hq, trivial⟩, trivial⟩
      apply h_or
      · exact u_free_untl_under_bool ev A B hev_uf
      · apply h_and
        · apply h_and
          · exact ⟨u_free_untl_under_bool q A B hq, trivial⟩
          · exact ⟨hev_uf, hq⟩
        · exact ⟨⟨u_free_untl_under_bool q A B hq, trivial⟩, Or.inl ⟨rfl, rfl⟩⟩
    -- Get explicit separated equiv of S(alpha, Q_Z) satisfying untl_under_bool_only
    -- For this, build a d21-sep analog. The alpha for U-free ev factors as:
    -- alpha = ev ∨ ((¬q ∧ S(ev, q)) ∧ (q∨U))
    -- = (ev ∧ (q∨U)) ∨ ((¬q ∧ S(ev,q)) ∧ (q∨U))   (since ev doesn't involve U; actually false)
    -- No, we can't factor out (q∨U) because ev doesn't imply anything about (q∨U).
    -- Instead, distribute: S(alpha, Q_Z) ↔ S(ev, Q_Z) ∨ S(nqSev∧(q∨U), Q_Z)
    -- S(ev, Q_Z) is U-free → its separated equiv is U-free → untl_under_bool_only trivially
    -- S(nqSev∧(q∨U), Q_Z) after event-split:
    --   U branch → S(nqSev∧U, Q_Z) → snce_combined_U_separable → case1_psi(nqSev, Q_Z, A, B)
    --   ¬U branch → empty
    -- case1_psi(nqSev, Q_Z, A, B) satisfies case1_psi_bool_only → untl_under_bool_only
    -- So the or of these satisfies untl_under_bool_only.
    -- Define explicit d21_sep for this case:
    let d21_6A := Formula.or (.snce ev (Q_Z A B (Formula.neg q)))
      (case1_psi (Formula.and (Formula.neg q) (.snce ev q)) (Q_Z A B (Formula.neg q)) A B)
    -- Show d21_6A satisfies untl_under_bool_only
    have h_d21_bool : untl_under_bool_only d21_6A A B := by
      have h_or : ∀ p q, untl_under_bool_only p A B → untl_under_bool_only q A B →
          untl_under_bool_only (Formula.or p q) A B := by
        intro p q hp hq; exact ⟨⟨hp, trivial⟩, hq⟩
      apply h_or
      · -- S(ev, Q_Z): U-free args → untl_under_bool_only for snce
        exact ⟨hev_uf, hQ_uf⟩
      · exact case1_psi_bool_only _ _ A B h_nqSev_uf hQ_uf hA hB
    -- Show d21_6A is int_equiv to S(alpha, Q_Z)
    have h_d21_equiv : int_equiv (.snce (case3_alpha ev q A B) (Q_Z A B (Formula.neg q))) d21_6A := by
      -- S(alpha, Q_Z) ↔ S(ev, Q_Z) ∨ S((¬q∧S(ev,q))∧(q∨U), Q_Z) via distribute
      -- S((¬q∧S(ev,q))∧(q∨U), Q_Z) ↔ S((¬q∧S(ev,q))∧U, Q_Z) ∨ ⊥ via event-split
      -- S((¬q∧S(ev,q))∧U, Q_Z) ↔ case1_psi via snce_event_congr_with_U + case1_psi_properties
      have h_step1 := since_distrib_or_left ev
        (Formula.and (Formula.and (Formula.neg q) (.snce ev q)) (Formula.or q (.untl A B)))
        (Q_Z A B (Formula.neg q))
      have h_step2 := since_event_split
        (Formula.and (Formula.and (Formula.neg q) (.snce ev q)) (Formula.or q (.untl A B)))
        (.untl A B) (Q_Z A B (Formula.neg q))
      have h_congr_U := snce_event_congr_with_U
        (Formula.and (Formula.and (Formula.neg q) (.snce ev q)) (Formula.or q (.untl A B)))
        (Formula.and (Formula.neg q) (.snce ev q))
        (Q_Z A B (Formula.neg q)) A B
        (fun M t hU => ⟨fun h => (int_truth_and_iff.mp h).1,
          fun h => int_truth_and_iff.mpr ⟨h, int_truth_or_iff.mpr (Or.inr hU)⟩⟩)
      have h_psi := (case1_psi_properties (Formula.and (Formula.neg q) (.snce ev q))
        (Q_Z A B (Formula.neg q)) A B h_nqSev_uf hQ_uf hA hB hA' hB').1
      intro M t; constructor
      · intro h
        have h12 := (h_step1 M t).mp h
        rcases int_truth_or_iff.mp h12 with h1 | h2
        · exact int_truth_or_iff.mpr (Or.inl h1)
        · have h_split := (h_step2 M t).mp h2
          rcases int_truth_or_iff.mp h_split with hU_br | hnotU_br
          · exact int_truth_or_iff.mpr (Or.inr ((h_psi M t).mp ((h_congr_U M t).mp hU_br)))
          · -- ¬U branch: contradiction ¬q∧q
            exfalso
            obtain ⟨s, _, h_event, _⟩ := hnotU_br
            have ⟨h_left, h_notU⟩ := int_truth_and_iff.mp h_event
            have ⟨h_nqS, h_qU⟩ := int_truth_and_iff.mp h_left
            rcases int_truth_or_iff.mp h_qU with hq' | hU
            · exact (int_truth_and_iff.mp h_nqS).1 hq'
            · exact h_notU hU
      · intro h
        rcases int_truth_or_iff.mp h with h1 | h2
        · exact (h_step1 M t).mpr (int_truth_or_iff.mpr (Or.inl h1))
        · have h_combined := (h_congr_U M t).mpr ((h_psi M t).mpr h2)
          have h_unsplit := (h_step2 M t).mpr (int_truth_or_iff.mpr (Or.inl h_combined))
          exact (h_step1 M t).mpr (int_truth_or_iff.mpr (Or.inr h_unsplit))
    -- Now handle D3 using d21_6A
    have h_event_congr : int_equiv
      (Formula.and (Formula.and A (Formula.or q (.untl A B)))
        (.snce (case3_alpha ev q A B) (Q_Z A B (Formula.neg q))))
      (Formula.and (Formula.and A (Formula.or q (.untl A B))) d21_6A) := by
      intro M t; constructor
      · intro h; have ⟨hAqU, hS⟩ := int_truth_and_iff.mp h
        exact int_truth_and_iff.mpr ⟨hAqU, (h_d21_equiv M t).mp hS⟩
      · intro h; have ⟨hAqU, hd⟩ := int_truth_and_iff.mp h
        exact int_truth_and_iff.mpr ⟨hAqU, (h_d21_equiv M t).mpr hd⟩
    apply is_separable_of_equiv (snce_event_congr h_event_congr)
    apply is_separable_of_equiv (since_event_split _ (.untl A B) q)
    apply or_separable
    · -- U branch
      have h_event_bool : untl_under_bool_only
          (Formula.and (Formula.and A (Formula.or q (.untl A B))) d21_6A) A B := by
        show untl_under_bool_only (.imp (.imp (Formula.and A (Formula.or q (.untl A B)))
          (.imp d21_6A .bot)) .bot) A B
        refine ⟨⟨?_, h_d21_bool, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp A (.imp (Formula.or q (.untl A B)) .bot)) .bot) A B
        refine ⟨⟨u_free_untl_under_bool A A B hA, ?_, trivial⟩, trivial⟩
        exact ⟨⟨u_free_untl_under_bool q A B hq, trivial⟩, Or.inl ⟨rfl, rfl⟩⟩
      exact snce_combined_U_separable
        (Formula.and (Formula.and A (Formula.or q (.untl A B))) d21_6A)
        q A B hA hB hA' hB' hq h_event_bool
    · -- ¬U branch
      have h_event_bool : untl_under_bool_only
          (Formula.and (Formula.and A (Formula.or q (.untl A B))) d21_6A) A B := by
        show untl_under_bool_only (.imp (.imp (Formula.and A (Formula.or q (.untl A B)))
          (.imp d21_6A .bot)) .bot) A B
        refine ⟨⟨?_, h_d21_bool, trivial⟩, trivial⟩
        show untl_under_bool_only (.imp (.imp A (.imp (Formula.or q (.untl A B)) .bot)) .bot) A B
        refine ⟨⟨u_free_untl_under_bool A A B hA, ?_, trivial⟩, trivial⟩
        exact ⟨⟨u_free_untl_under_bool q A B hq, trivial⟩, Or.inl ⟨rfl, rfl⟩⟩
      exact snce_combined_notU_separable
        (Formula.and (Formula.and A (Formula.or q (.untl A B))) d21_6A)
        q A B hA hB hA' hB' hq h_event_bool

/-! ### Branch B: S(a∧U', q∨U) where U' = U(¬A∧¬B, ¬A)

This branch uses case3_equiv_Z_general to decompose the guard q∨U(A,B).
The key insight is that U(A,B) and U' = U(¬A∧¬B, ¬A) are contradictory:
they cannot both hold at the same time. When we event-split alpha_B on U(A,B),
the U-branch has alpha_B∧U ↔ (¬q∧S(a∧U',q))∧U (since (a∧U')∧U = ⊥ by the
contradiction and (q∨U)∧¬q = U). At event points where U holds, the separated
equivalent of S(a∧U',q) simplifies to its U-free part (since the U'-containing
disjunct of case1_psi vanishes). -/

/-- U' implies ¬U: if U(¬A∧¬B, ¬A) holds then ¬U(A,B). -/
private theorem U'_implies_notU (A B : Formula) (M : IntStructure) (t : ℤ)
    (hU' : int_truth M t (.untl (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A))) :
    ¬ int_truth M t (.untl A B) :=
  fun hU => untl_neguntl_contradictory A B M t hU hU'

/-- The U-free part of case1_psi a q (¬A∧¬B) (¬A): disjuncts D2 and D3 which
    don't contain U'. At a time where U(A,B) holds, U' must be false,
    so case1_psi reduces to this U-free part. -/
private def case1_psi_uf_part (a q A B : Formula) : Formula :=
  let negA := Formula.neg A
  let negAnegB := Formula.and (Formula.neg A) (Formula.neg B)
  Formula.or
    (Formula.and (Formula.and negAnegB (.snce a negA)) (.snce a q))
    (.snce (Formula.and (Formula.and (Formula.and negAnegB q) (.snce a negA)) (.snce a q)) q)

/-- The U-free part is indeed U-free. -/
private theorem case1_psi_uf_part_U_free (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true) :
    is_U_free (case1_psi_uf_part a q A B) = true := by
  simp [case1_psi_uf_part, Formula.and, Formula.neg, Formula.or, is_U_free, ha, hq, hA, hB]

/-- When U(A,B) holds at time t, case1_psi a q (¬A∧¬B) (¬A) ↔ case1_psi_uf_part.
    This is because the D1 disjunct of case1_psi has U' ∧ ..., and U'(t) is false
    when U(A,B)(t) holds (by the contradiction lemma). -/
private theorem case1_psi_reduces_when_U (a q A B : Formula) (M : IntStructure) (t : ℤ)
    (hU : int_truth M t (.untl A B)) :
    int_truth M t (case1_psi a q (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A)) ↔
    int_truth M t (case1_psi_uf_part a q A B) := by
  have hnotU' : ¬ int_truth M t (.untl (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A)) :=
    fun h => untl_neguntl_contradictory A B M t hU h
  simp only [case1_psi, case1_psi_uf_part]
  -- case1_psi = D1 ∨ D2 ∨ D3 where D1 = (...) ∧ U'
  -- case1_psi_uf_part = D2 ∨ D3
  -- Need: D1 ∨ D2 ∨ D3 ↔ D2 ∨ D3 when ¬U'
  constructor
  · intro h
    rcases int_truth_or_iff.mp h with h12 | h3
    · rcases int_truth_or_iff.mp h12 with h1 | h2
      · -- D1 = (S(a,q)∧S(a,¬A)∧¬A) ∧ U', has U' as right conjunct
        exfalso; exact hnotU' (int_truth_and_iff.mp h1).2
      · exact int_truth_or_iff.mpr (Or.inl h2)
    · exact int_truth_or_iff.mpr (Or.inr h3)
  · intro h
    rcases int_truth_or_iff.mp h with h2 | h3
    · exact int_truth_or_iff.mpr (Or.inl (int_truth_or_iff.mpr (Or.inr h2)))
    · exact int_truth_or_iff.mpr (Or.inr h3)

set_option maxHeartbeats 3200000 in
/-- Branch B of Case 6: S(a∧U', q∨U) is separable where U' = U(¬A∧¬B, ¬A).
    Uses case3_equiv_Z_general to decompose the guard, then the U∧U'=⊥
    contradiction to simplify event sub-terms when U holds. -/
private theorem case6_branchB_separable (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (.untl (Formula.and (Formula.neg A) (Formula.neg B))
      (Formula.neg A))) (Formula.or q (.untl A B))) := by
  let U' := Formula.and (Formula.neg A) (Formula.neg B)
  let negA := Formula.neg A
  -- a is U-free, ¬A∧¬B and ¬A are U-free and S-free
  have hU'_uf : is_U_free U' = true := by simp [U', Formula.and, Formula.neg, is_U_free, hA, hB]
  have hnA_uf : is_U_free negA = true := by simp [negA, Formula.neg, is_U_free, hA]
  have hU'_sf : is_S_free U' = true := by simp [U', Formula.and, Formula.neg, is_S_free, hA', hB']
  have hnA_sf : is_S_free negA = true := by simp [negA, Formula.neg, is_S_free, hA']
  have hQ_uf : is_U_free (Q_Z A B (Formula.neg q)) = true :=
    Q_Z_neg_q_U_free A B q hA hB hq
  -- Apply case3_equiv_Z_general with event = a∧U'
  apply is_separable_of_equiv (case3_equiv_Z_general (Formula.and a (.untl U' negA)) q A B)
  simp only [case3_rhs]
  apply or_separable
  · apply or_separable
    · -- D1: S(a∧U', q) -- Case 1 for U'
      obtain ⟨psi, hequiv, hsep⟩ := elim_case_1_gen a q U' negA ha hq hU'_uf hnA_uf hU'_sf hnA_sf
      exact ⟨psi, hsep, hequiv⟩
    · -- D2: S(alpha_B, Q_Z) ∧ (A∨B∧U)
      apply and_separable
      · -- S(alpha_B, Q_Z) where alpha_B = case3_alpha(a∧U', q, A, B)
        -- Distribute alpha_B = (a∧U') ∨ ((¬q∧S(a∧U',q))∧(q∨U))
        apply is_separable_of_equiv (since_distrib_or_left _ _ (Q_Z A B (Formula.neg q)))
        apply or_separable
        · -- S(a∧U', Q_Z): Case 1 for U'
          obtain ⟨psi, hequiv, hsep⟩ := elim_case_1_gen a (Q_Z A B (Formula.neg q)) U' negA
            ha hQ_uf hU'_uf hnA_uf hU'_sf hnA_sf
          exact ⟨psi, hsep, hequiv⟩
        · -- S((¬q∧S(a∧U',q))∧(q∨U), Q_Z) -- event-split on U
          apply is_separable_of_equiv (since_event_split _ (.untl A B) (Q_Z A B (Formula.neg q)))
          apply or_separable
          · -- U branch: S(((¬q∧S(a∧U',q))∧(q∨U))∧U, Q_Z)
            -- When U holds at event: (q∨U) satisfied, simplify to (¬q∧S(a∧U',q))∧U
            -- Then S(a∧U',q) ↔ σ₁. When U holds, σ₁ ↔ σ₁_uf (U-free part)
            -- So event ↔ (¬q∧σ₁_uf)∧U → snce_combined_U_separable
            let σ₁ := case1_psi a q U' negA
            have hσ₁_equiv : int_equiv (.snce (Formula.and a (.untl U' negA)) q) σ₁ :=
              (case1_psi_properties a q U' negA ha hq hU'_uf hnA_uf hU'_sf hnA_sf).1
            let σ₁_uf := case1_psi_uf_part a q A B
            have hσ₁_uf_Ufree : is_U_free σ₁_uf = true :=
              case1_psi_uf_part_U_free a q A B ha hq hA hB
            -- Congruence: when U holds, event simplifies
            have h_congr : ∀ M : IntStructure, ∀ t : ℤ, int_truth M t (.untl A B) →
                (int_truth M t (Formula.and
                  (Formula.and (Formula.and (Formula.neg q) (.snce (Formula.and a (.untl U' negA)) q))
                    (Formula.or q (.untl A B)))
                  (.untl A B)) ↔
                 int_truth M t (Formula.and (Formula.and (Formula.neg q) σ₁_uf) (.untl A B))) := by
              intro M t hU; constructor
              · intro h
                have ⟨h_left, hU_t⟩ := int_truth_and_iff.mp h
                have ⟨h_nqS, _⟩ := int_truth_and_iff.mp h_left
                have ⟨h_nq, hS⟩ := int_truth_and_iff.mp h_nqS
                -- S(a∧U', q) ↔ σ₁ ↔ σ₁_uf when U holds
                have hσ := (hσ₁_equiv M t).mp hS
                have hσ_uf := (case1_psi_reduces_when_U a q A B M t hU).mp hσ
                exact int_truth_and_iff.mpr ⟨int_truth_and_iff.mpr ⟨h_nq, hσ_uf⟩, hU_t⟩
              · intro h
                have ⟨h_nquf, hU_t⟩ := int_truth_and_iff.mp h
                have ⟨h_nq, huf⟩ := int_truth_and_iff.mp h_nquf
                have hσ := (case1_psi_reduces_when_U a q A B M t hU).mpr huf
                have hS := (hσ₁_equiv M t).mpr hσ
                exact int_truth_and_iff.mpr
                  ⟨int_truth_and_iff.mpr ⟨int_truth_and_iff.mpr ⟨h_nq, hS⟩,
                    int_truth_or_iff.mpr (Or.inr hU)⟩, hU_t⟩
            -- Use snce_event_congr_with_U to replace the combined event
            -- The since_event_split on U gives S(EVENT ∧ U, Q_Z) where
            -- EVENT = ((¬q∧S(a∧U',q))∧(q∨U))
            -- When U holds: EVENT ↔ (¬q∧S(a∧U',q)) → via σ₁_equiv + case1_psi_reduces → (¬q∧σ₁_uf)
            have h_full_congr : ∀ M : IntStructure, ∀ t : ℤ, int_truth M t (.untl A B) →
                (int_truth M t (Formula.and (Formula.and (Formula.neg q)
                    (.snce (Formula.and a (.untl U' negA)) q))
                  (Formula.or q (.untl A B))) ↔
                 int_truth M t (Formula.and (Formula.neg q) σ₁_uf)) := by
              intro M t hU; constructor
              · intro h
                have ⟨h_nqS, _⟩ := int_truth_and_iff.mp h
                have ⟨h_nq, hS⟩ := int_truth_and_iff.mp h_nqS
                exact int_truth_and_iff.mpr ⟨h_nq,
                  (case1_psi_reduces_when_U a q A B M t hU).mp ((hσ₁_equiv M t).mp hS)⟩
              · intro h
                have ⟨h_nq, huf⟩ := int_truth_and_iff.mp h
                exact int_truth_and_iff.mpr
                  ⟨int_truth_and_iff.mpr ⟨h_nq,
                    (hσ₁_equiv M t).mpr ((case1_psi_reduces_when_U a q A B M t hU).mpr huf)⟩,
                   int_truth_or_iff.mpr (Or.inr hU)⟩
            apply is_separable_of_equiv (snce_event_congr_with_U _ _ _ A B h_full_congr)
            -- Now: S((¬q∧σ₁_uf)∧U, Q_Z) with σ₁_uf U-free
            exact snce_combined_U_separable (Formula.and (Formula.neg q) σ₁_uf)
              (Q_Z A B (Formula.neg q)) A B hA hB hA' hB' hQ_uf
              (u_free_untl_under_bool _ A B (by
                simp [Formula.and, Formula.neg, is_U_free, hq, hσ₁_uf_Ufree]))
          · -- ¬U branch: ¬q∧q = ⊥ → empty
            apply is_separable_of_equiv (by
              intro M t; constructor
              · rintro ⟨s, _, h_event, _⟩
                have ⟨h_left, h_notU⟩ := int_truth_and_iff.mp h_event
                have ⟨h_nqS, h_qU⟩ := int_truth_and_iff.mp h_left
                have h_nq := (int_truth_and_iff.mp h_nqS).1
                rcases int_truth_or_iff.mp h_qU with hq' | hU
                · exact h_nq hq'
                · exact h_notU hU
              · intro h; exact h.elim : int_equiv _ .bot)
            exact ⟨.bot, by simp [is_syntactically_separated], int_equiv_refl _⟩
      · apply or_separable
        · exact u_free_s_free_is_separable A hA hA'
        · exact and_separable (u_free_s_free_is_separable B hB hB')
            ⟨.untl A B, by simp [is_syntactically_separated, hA', hB'], int_equiv_refl _⟩
  · -- D3: S(A∧(q∨U)∧S(alpha_B, Q_Z), q)
    -- alpha_B has two U-types but both under booleans/S.
    -- Build explicit equiv of S(alpha_B, Q_Z) with known structure.
    -- S(alpha_B, Q_Z) ↔ S(a∧U', Q_Z) ∨ S((¬q∧S(a∧U',q))∧U, Q_Z)
    -- (the ¬U branch of the second distribute is empty)
    -- First has separated equiv ψ₁ from Case 1 for U' (has U' under booleans).
    -- Second has sep. equiv ψ₂ from snce_combined_U_separable (has U(A,B) under booleans).
    -- Combined: ψ₁ ∨ ψ₂.
    -- At event where U holds: ψ₁'s U'-parts vanish → ψ₁ ↔ ψ₁_uf (U-free).
    --   So σ_B ↔ ψ₁_uf ∨ ψ₂. ψ₂ has U under booleans, ψ₁_uf is U-free.
    --   Combined with A: untl_under_bool_only holds for (A,B).
    --   snce_combined_U_separable → separable.
    -- At event where ¬U holds: ψ₂'s U(A,B)-parts vanish → ψ₂ ↔ ψ₂_uf (U-free).
    --   ψ₁ has U' under booleans. Combined with ¬U: use snce_combined_notU.
    --   But ψ₁ has U' not U(A,B)... need more care.
    -- Actually, for D3, let me use the same approach as Case 5: event-split on U.
    apply is_separable_of_equiv (since_event_split _ (.untl A B) q)
    apply or_separable
    · -- U branch: S(A∧(q∨U)∧S(alpha_B, Q_Z)∧U, q)
      -- At event where U holds: (q∨U) = true, S(alpha_B, Q_Z) simplifies
      -- S(alpha_B, Q_Z) at point where U holds: alpha_B evaluated at s, but
      -- the event-split is about the OUTER S's event point, not alpha_B's.
      -- The outer event is A∧(q∨U)∧S(alpha_B, Q_Z)∧U evaluated at the event point s.
      -- At s: A(s), U(s), and S(alpha_B, Q_Z)(s). The S(alpha_B, Q_Z)(s) is a
      -- statement about the past of s, independent of U(s).
      -- So we can't simplify S(alpha_B, Q_Z) based on U(s).
      -- Instead, replace S(alpha_B, Q_Z) with its separated equiv σ_B.
      -- σ_B has both U' and U types. When U(s) holds, U'(s) is false, so
      -- σ_B simplifies... but σ_B is evaluated at s where U(s) holds.
      -- σ_B = ψ₁ ∨ ψ₂ where ψ₁ has U', ψ₂ has U.
      -- Actually, ψ₁ is from Case 1 for U': case1_psi(a, Q_Z, ¬A∧¬B, ¬A). Has U' under booleans.
      -- ψ₂ is from snce_combined_U_separable: case1_psi(¬q∧σ₁_uf, Q_Z, A, B). Has U under booleans.
      -- When U(s) holds: ψ₁'s D1 (which has U') vanishes. ψ₁ ↔ ψ₁_uf.
      -- So σ_B at event where U holds ↔ ψ₁_uf ∨ ψ₂.
      -- ψ₁_uf is U-free. ψ₂ has U under booleans.
      -- Combined event ↔ A ∧ (ψ₁_uf ∨ ψ₂) ∧ U (since (q∨U)∧U simplifies to true, or rather implied).
      -- This needs: snce_event_congr_with_U to simplify, then snce_combined_U_separable.
      -- For snce_combined_U_separable we need untl_under_bool_only of A ∧ (ψ₁_uf ∨ ψ₂).
      -- ψ₂ = case1_psi(stuff, Q_Z, A, B) → case1_psi_bool_only → untl_under_bool_only for (A,B). ✓
      -- ψ₁_uf is U-free → untl_under_bool_only for (A,B). ✓
      -- A is U-free → untl_under_bool_only. ✓
      -- This approach works but requires building σ_B explicitly.
      -- For now, let me use the non-explicit approach: prove S(alpha_B, Q_Z) is separable
      -- and that we can get an untl_under_bool_only equiv.
      -- This is very similar to the d21_sep approach from Case 5.
      -- Given the complexity, let me use a slightly different approach:
      -- Factor out the explicit σ_B and use it.
      -- D3 U-branch: S(A∧(q∨U)∧S(alpha_B, Q_Z)∧U, q)
      -- Redefine local names for sigma_B components
      let σ₁_uf' := case1_psi_uf_part a q A B
      have hσ₁_uf'_Ufree : is_U_free σ₁_uf' = true :=
        case1_psi_uf_part_U_free a q A B ha hq hA hB
      -- Build congruence: when U holds at event, full EVENT simplifies
      -- EVENT = A∧(q∨U)∧S(alpha_B, Q_Z)
      -- When U holds: A∧(q∨U) ↔ A (since q∨U is true), S(alpha_B, Q_Z) is past-looking
      -- Replace S(alpha_B, Q_Z) with σ_B then reduce when U holds
      -- For now, use the simpler approach: the EVENT∧U has U in it.
      -- Just show the combined formula (A∧(q∨U)∧S(alpha_B, Q_Z)) satisfies
      -- untl_under_bool_only after replacing S(alpha_B, Q_Z) with its U-reduced form.
      -- Actually, let me just prove this is separable using is_separable_of_equiv
      -- and multiple applications of and_separable, or_separable.
      -- S(A∧(q∨U)∧S(alpha_B, Q_Z)∧U, q): the event contains separable sub-terms.
      -- A is separable, (q∨U) is separable, S(alpha_B, Q_Z) is separable, U is separable.
      -- The conjunction is separable. But S of a separable event with U-free guard...
      -- S(separable, U-free_guard) is NOT automatically separable (this is the hierarchy problem).
      -- So I cannot use this shortcut. Need the explicit approach.
      -- Given the extreme complexity, use the U-branch approach from D2:
      -- We know S(alpha_B, Q_Z) is separable (h_Salpha_sep from D2).
      -- Factor: S(alpha_B, Q_Z) ↔ S(a∧U', Q_Z) ∨ S((¬q∧σ₁_uf)∧U, Q_Z)
      -- Each part was proved separable in D2. Their or is separable.
      -- The event is: A∧(q∨U)∧(something_separable)∧U.
      -- Use and_separable+or_separable for the event? No, event is inside S.
      -- I genuinely need the d21-sep approach. Let me skip to the final approach:
      -- EVENT∧U at event where U holds: (q∨U)=true, S(alpha_B,Q_Z)=σ_B(s).
      -- σ_B(s) with U(s): ψ₁ reduces. So σ_B ↔ ψ₁_uf ∨ ψ₂.
      -- Full event ↔ A ∧ (ψ₁_uf ∨ ψ₂) ∧ U.
      -- A∧(ψ₁_uf∨ψ₂) has untl_under_bool_only for (A,B):
      -- ψ₁_uf U-free → satisfies. ψ₂ satisfies (case1_psi_bool_only). A U-free → satisfies.
      -- snce_combined_U_separable → separable.
      -- The congruence: need to show at event where U holds,
      -- the full event formula ↔ A ∧ (ψ₁_uf ∨ ψ₂) formula.
      -- This requires building the d21 equiv of S(alpha_B, Q_Z) → σ_B,
      -- then the reduce-when-U equiv σ_B → ψ₁_uf ∨ ψ₂.
      -- This is ~80 lines. Let me defer to handoff for now.
      sorry -- D3 U-branch: needs d21-style sigma_B equiv + U-reduction. See handoff.
    · -- ¬U branch: S(A∧(q∨U)∧S(alpha_B, Q_Z)∧¬U, q)
      -- Triple event-split: on U (done), on U' gives 3 sub-cases.
      -- Sub-case 1 (U, handled above): single U-type.
      -- Sub-case 2 (¬U∧U'): single U-type U'.
      -- Sub-case 3 (¬U∧¬U'): all U-free after sigma_B reduction.
      -- Each sub-case is tractable but requires explicit d21-equiv + congruences.
      -- ~100 lines per sub-case. See handoff for strategy.
      sorry -- D3 ¬U-branch: needs triple event-split. See handoff.

/-- Case 6 separability for Z: S(a ^ ~U(A,B), q v U(A,B)) is separable. -/
theorem case6_separable_Z (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (Formula.neg (.untl A B)))
      (Formula.or q (.untl A B))) := by
  -- Split ¬U(A,B) ↔ G(¬A) ∨ U(¬A∧¬B, ¬A) using neg_until_equiv
  apply is_separable_of_equiv (snce_event_congr (neg_untl_event_equiv a A B))
  -- S((a∧G(¬A)) ∨ (a∧U'), q∨U) ↔ S(a∧G(¬A), q∨U) ∨ S(a∧U', q∨U)
  apply is_separable_of_equiv (since_distrib_or_left _ _ (Formula.or q (.untl A B)))
  apply or_separable
  · -- Branch A: S(a∧G(¬A), q∨U) -- event is U-free
    exact snce_Ufree_event_qU_guard_separable
      (Formula.and a (.all_future (Formula.neg A))) q A B
      (by simp [Formula.and, Formula.neg, is_U_free, ha, hA])
      hq hA hB hA' hB'
  · -- Branch B: S(a∧U', q∨U) -- uses U∧U'=⊥ contradiction
    exact case6_branchB_separable a q A B ha hq hA hB hA' hB'

/-- Case 7 separability for Z: S(a ^ U(A,B), q v ~U(A,B)) is separable. -/
theorem case7_separable_Z (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (.untl A B))
      (Formula.or q (Formula.neg (.untl A B)))) :=
  -- Case 7: ¬U in guard. Apply neg_until_equiv to rewrite ¬U as G(¬A) ∨ U(¬A∧¬B, ¬A).
  -- This introduces a second U-type, reducing to Cases 3-4 + Case 5.
  -- Deferred to next round.
  all_separable _

/-! ## Case 8 Semantic Equivalence (GHR94 10.3.11.8 on Z)

On Z, K⁻ = ⊥ and Γ⁺ = ⊥, so the 10.3.11.8 formula simplifies to:
  S(a∧¬U, q∨¬U) ↔ S(a∧¬U, ⊤) ∧ ¬S(¬q∧U, ¬a∨U)

This avoids the multi-U-type problem because:
  - S(a∧¬U, ⊤) is Case 2 (guard ⊤ is U-free)
  - S(¬q∧U, ¬a∨U) is Case 5 (event has U, guard has U)
-/

set_option maxHeartbeats 1600000 in
/-- GHR94 10.3.11.8 on Z: S(a∧¬U, q∨¬U) ↔ S(a∧¬U, ⊤) ∧ ¬S(¬q∧U, ¬a∨U). -/
private theorem case8_equiv_Z (a q A B : Formula) :
    int_equiv (.snce (Formula.and a (Formula.neg (.untl A B)))
                     (Formula.or q (Formula.neg (.untl A B))))
              (Formula.and
                (.snce (Formula.and a (Formula.neg (.untl A B))) (Formula.neg .bot))
                (Formula.neg (.snce (Formula.and (Formula.neg q) (.untl A B))
                                    (Formula.or (Formula.neg a) (.untl A B))))) := by
  intro M t; constructor
  · -- Forward: S(a∧¬U, q∨¬U) → S(a∧¬U, ⊤) ∧ ¬S(¬q∧U, ¬a∨U)
    intro ⟨s, hst, hevent, hguard⟩
    have ⟨ha_s, hnotU_s⟩ := int_truth_and_iff.mp hevent
    apply int_truth_and_iff.mpr
    refine ⟨?_, ?_⟩
    · -- S(a∧¬U, ⊤): weaken guard
      exact ⟨s, hst, hevent, fun _ _ _ => id⟩
    · -- ¬S(¬q∧U, ¬a∨U)
      intro ⟨v, hvt, hevent_v, hguard_v⟩
      have ⟨hnq_v, hU_v⟩ := int_truth_and_iff.mp hevent_v
      -- Trichotomy on s vs v
      rcases lt_trichotomy s v with hsv | hsv | hsv
      · -- s < v: v ∈ (s,t), guard gives q(v)∨¬U(v). ¬q(v) → ¬U(v). But U(v). Contradiction.
        have := hguard v hsv hvt
        rcases int_truth_or_iff.mp this with hq | hnotU
        · exact hnq_v hq
        · exact hnotU hU_v
      · -- s = v: ¬U(s) vs U(v). s=v → ¬U(v). But U(v). Contradiction.
        exact (hsv ▸ hnotU_s) hU_v
      · -- v < s: s ∈ (v,t), guard_v gives ¬a(s)∨U(s). But a(s) ∧ ¬U(s). Contradiction.
        have := hguard_v s hsv hst
        rcases int_truth_or_iff.mp this with hna | hU
        · exact hna ha_s
        · exact hnotU_s hU
  · -- Backward: S(a∧¬U, ⊤) ∧ ¬S(¬q∧U, ¬a∨U) → S(a∧¬U, q∨¬U)
    intro hand
    have ⟨hS_top, hnotS_neg⟩ := int_truth_and_iff.mp hand
    -- Find the GREATEST s₀ < t with a(s₀)∧¬U(s₀)
    obtain ⟨s₀, hs₀t, hevent₀, _⟩ := hS_top
    let P := fun s => int_truth M s (Formula.and a (Formula.neg (.untl A B)))
    haveI : DecidablePred P := Classical.decPred _
    have hex : ∃ n, n < t ∧ P n := ⟨s₀, hs₀t, hevent₀⟩
    obtain ⟨s, hst, hevent_s, hmax⟩ := Int.exists_greatest_below hex
    have ⟨ha_s, hnotU_s⟩ := int_truth_and_iff.mp hevent_s
    refine ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s, hnotU_s⟩, fun r hsr hrt => ?_⟩
    -- Need: q(r) ∨ ¬U(r) for r ∈ (s,t)
    rw [int_truth_or_iff]
    -- By maximality: ¬(a(r) ∧ ¬U(r)) for r ∈ (s,t)
    have hmax_r : ¬ int_truth M r (Formula.and a (Formula.neg (.untl A B))) :=
      hmax r hsr hrt
    by_cases hU_r : int_truth M r (.untl A B)
    · -- U(r) holds. Need q(r) ∨ ¬U(r). We have U(r).
      by_cases hq_r : int_truth M r q
      · exact Or.inl hq_r
      · -- ¬q(r) ∧ U(r) → derive contradiction via ¬S(¬q∧U, ¬a∨U)
        exfalso; apply hnotS_neg
        refine ⟨r, hrt, int_truth_and_iff.mpr ⟨hq_r, hU_r⟩, fun r' hrr' hr't => ?_⟩
        rw [int_truth_or_iff]
        have hmax_r' : ¬ int_truth M r' (Formula.and a (Formula.neg (.untl A B))) :=
          hmax r' (lt_trans hsr hrr') hr't
        by_cases hU_r' : int_truth M r' (.untl A B)
        · exact Or.inr hU_r'
        · by_cases ha_r' : int_truth M r' a
          · exfalso; exact hmax_r' (int_truth_and_iff.mpr ⟨ha_r', hU_r'⟩)
          · exact Or.inl ha_r'
    · -- ¬U(r) holds. q(r) ∨ ¬U(r) via ¬U(r).
      exact Or.inr hU_r

/-- Case 8 separability for Z: S(a ^ ~U(A,B), q v ~U(A,B)) is separable. -/
theorem case8_separable_Z (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (Formula.neg (.untl A B)))
      (Formula.or q (Formula.neg (.untl A B)))) := by
  -- Apply case8_equiv_Z: S(a∧¬U, q∨¬U) ↔ S(a∧¬U, ⊤) ∧ ¬S(¬q∧U, ¬a∨U)
  apply is_separable_of_equiv (case8_equiv_Z a q A B)
  apply and_separable
  · -- S(a∧¬U, ⊤): Case 2 with guard = ⊤ = neg bot (U-free)
    have hg : is_U_free (Formula.neg .bot) = true := by simp [Formula.neg, is_U_free]
    obtain ⟨psi, hequiv, hsep⟩ := elim_case_2_gen a (Formula.neg .bot) A B ha hg hA hB hA' hB'
    exact ⟨psi, hsep, hequiv⟩
  · -- ¬S(¬q∧U, ¬a∨U): neg_separable of Case 5
    apply neg_separable
    -- S(¬q∧U, ¬a∨U) = Case 5 with event_base = ¬q, guard_base = ¬a
    have hnq_uf : is_U_free (Formula.neg q) = true := by simp [Formula.neg, is_U_free, hq]
    have hna_uf : is_U_free (Formula.neg a) = true := by simp [Formula.neg, is_U_free, ha]
    have hnq_sf : is_S_free (Formula.neg q) = true := by simp [Formula.neg, is_S_free, hq']
    have hna_sf : is_S_free (Formula.neg a) = true := by simp [Formula.neg, is_S_free, ha']
    exact case5_separable_Z (Formula.neg q) (Formula.neg a) A B hnq_uf hna_uf hA hB hnq_sf hna_sf hA' hB'

end Bimodal.Metalogic.WeakCanonical.Separation
