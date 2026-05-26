import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.Eliminations
import Bimodal.Metalogic.WeakCanonical.Separation.NegationEquiv

/-!
# K+/K- Operators and Q-Lemma for Dedekind-Complete Integer Orders

K+/K- definitions, Q-lemma (forward and backward), Q_Z syntactic properties,
and Case 3 equivalence for Z.
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


end Bimodal.Metalogic.WeakCanonical.Separation
