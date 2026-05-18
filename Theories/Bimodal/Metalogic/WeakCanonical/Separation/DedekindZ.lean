import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.Eliminations
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
  -- Goal: ¬ int_truth M t (.imp (.untl (.imp .bot .bot) (.imp q .bot)) .bot)
  -- = (U(top, ¬q)(t) → False) → False is false
  -- i.e., ¬¬U(top, ¬q)(t)
  -- We show U(top, ¬q)(t) directly
  intro h
  apply h
  -- Goal: int_truth M t (.untl (.imp .bot .bot) (.imp q .bot))
  -- = ∃ s > t, (⊥ → ⊥) ∧ ∀ r ∈ (t, s), (q(r) → ⊥)
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
  -- Formula.and X Y = neg (imp X (neg Y)) = (X → Y → ⊥) → ⊥
  -- So int_truth is: (X(t) → Y(t) → False) → False
  -- where X = neg(K+(neg B)), Y = K-(neg B)
  -- We need to show this is False. I.e., for any h, provide X(t) → Y(t) → False.
  -- Y = K-(neg B) is false, so we just need to derive False from Y.
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
  -- We need: B(z) ∨ A(z) ∨ ¬S(C, ¬A)(z)
  rw [Q_Z, int_truth_or_iff, int_truth_or_iff, int_truth_neg_iff]
  -- Suppose S(C, ¬A)(z). We show B(z) ∨ A(z).
  by_cases hS : int_truth M z (.snce C (Formula.neg A))
  · -- S(C, ¬A)(z): ∃ u < z, C(u) ∧ ¬A on (u, z)
    obtain ⟨u, huz, hCu, hnotA_guard⟩ := hS
    by_cases hut0 : t0 < u
    · -- u ∈ (t0, t1), C(u) → U(A,B)(u)
      have hut1 : u < t1 := lt_trans huz hz1
      obtain ⟨w, huw, hAw, hBgd⟩ := hguard u hut0 hut1 hCu
      -- w > u. Compare w to z.
      by_cases hwz : w ≤ z
      · rcases eq_or_lt_of_le hwz with rfl | hwz'
        · -- w = z: A(z)
          exact Or.inl (Or.inr hAw)
        · -- u < w < z: ¬A(w) from hnotA_guard. Contradiction with hAw.
          exact absurd hAw (hnotA_guard w huw hwz')
      · -- w > z: B(z) since u < z < w
        push_neg at hwz
        exact Or.inl (Or.inl (hBgd z huz hwz))
    · -- u ≤ t0
      push_neg at hut0
      -- U(A,B)(t0): ∃ w > t0, A(w) ∧ B on (t0, w)
      obtain ⟨w, ht0w, hAw, hBgd⟩ := hinit
      by_cases hwz : w ≤ z
      · rcases eq_or_lt_of_le hwz with rfl | hwz'
        · exact Or.inl (Or.inr hAw)
        · -- u ≤ t0 < w < z. Since u ≤ t0 < w, we have u < w.
          -- Since w < z, hnotA_guard w huw' hwz' gives ¬A(w).
          have huw' : u < w := lt_of_le_of_lt hut0 ht0w
          exact absurd hAw (hnotA_guard w huw' hwz')
      · -- w > z: B(z) since t0 < z < w
        push_neg at hwz
        exact Or.inl (Or.inl (hBgd z hz0 hwz))
  · -- ¬S(C, ¬A)(z): third disjunct
    exact Or.inr hS

/-! ## Q-Lemma Backward Direction -/

set_option maxHeartbeats 1600000 in
/-- Q-lemma backward direction for Z.
    If Q_Z(A,B,C) holds on (t0, t1) and the endpoint condition holds,
    then C implies U(A,B) on (t0, t1). -/
theorem Q_lemma_Z_bwd (A B C : Formula) (M : IntStructure) (t0 t1 : ℤ)
    (_ht : t0 < t1)
    (hQ : ∀ z : ℤ, t0 < z → z < t1 → int_truth M z (Q_Z A B C))
    (hend : int_truth M t1 A
          ∨ int_truth M t1 (Formula.and B (.untl A B))) :
    ∀ z : ℤ, t0 < z → z < t1 →
      (int_truth M z C → int_truth M z (.untl A B)) := by
  intro z hz0 hz1 hCz
  -- We build U(A,B)(z): find w > z with A(w) and B on (z, w).
  -- Consider the interval [z+1, t1]. Walk right looking for A.
  -- At each point r in (z, t1) where ¬A(r), Q_Z gives B(r) ∨ A(r) ∨ ¬S(C, ¬A)(r).
  -- Since ¬A(r) and we have S(C, ¬A)(r) (via C(z) and ¬A on (z,r)), we get B(r).
  -- So B holds at all points in (z, y) where y is the first point with A.
  -- Either A holds at some point y ≤ t1, giving U(A,B)(z) with witness y,
  -- or A never holds and B holds on (z, t1), then we use hend.
  by_cases hA_exists : ∃ w : ℤ, z < w ∧ w ≤ t1 ∧ int_truth M w A
  · -- There exists a point with A in (z, t1]
    haveI : DecidablePred (fun w => int_truth M w A) := Classical.decPred _
    -- Find the least such point
    obtain ⟨w₀, hw₀⟩ := hA_exists
    -- Use well-ordering to find the least w > z with A(w)
    have hex : ∃ n, z < n ∧ int_truth M n A := ⟨w₀, hw₀.1, hw₀.2.2⟩
    obtain ⟨y, hzy, hAy, hmin⟩ := Int.exists_least_above hex
    -- y is the least point > z with A(y). B holds on (z, y).
    refine ⟨y, hzy, hAy, fun r hzr hry => ?_⟩
    -- Show B(r) for r ∈ (z, y).
    -- r ∈ (z, y), so ¬A(r) by minimality of y.
    have hnotAr : ¬ int_truth M r A := hmin r hzr hry
    -- r ∈ (z, t1) since y ≤ t1 (if y ≤ t1) or y > t1 (impossible since w₀ ≤ t1 and y ≤ w₀).
    -- Actually y may be > t1. We need to check.
    -- Since w₀ ≤ t1 and A(w₀) and y is the LEAST with A, y ≤ w₀ ≤ t1.
    have hyt1 : y ≤ t1 := by
      by_contra h; push_neg at h
      exact hmin w₀ hw₀.1 (lt_of_le_of_lt hw₀.2.1 h) hw₀.2.2
    have hrt1 : r < t1 := lt_of_lt_of_le hry hyt1
    have hrt0 : t0 < r := lt_trans hz0 hzr
    -- Q_Z(r): B(r) ∨ A(r) ∨ ¬S(C, ¬A)(r)
    have hQr := hQ r hrt0 hrt1
    rw [Q_Z, int_truth_or_iff, int_truth_or_iff, int_truth_neg_iff] at hQr
    rcases hQr with (hBr | hAr) | hnotS
    · exact hBr
    · exact absurd hAr hnotAr
    · -- ¬S(C, ¬A)(r). But we can show S(C, ¬A)(r) via witness z.
      exfalso; apply hnotS
      refine ⟨z, hzr, hCz, fun r' hr'z hr'r => ?_⟩
      -- r' ∈ (z, r) ⊆ (z, y). So ¬A(r') by minimality.
      exact hmin r' hr'z (lt_trans hr'r hry)
  · -- No point in (z, t1] has A. So we use hend and B holds on (z, t1].
    push_neg at hA_exists
    -- hA_exists : ∀ w, z < w → w ≤ t1 → ¬ int_truth M w A
    -- First, B holds on (z, t1): for any r ∈ (z, t1), Q_Z(r) and ¬A(r) and S(C,¬A)(r) gives B(r).
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
    -- Now use hend.
    rcases hend with hAt1 | hBUt1
    · -- A(t1): contradicts hA_exists at t1
      exact absurd hAt1 (hA_exists t1 hz1 (le_refl t1))
    · -- B(t1) ∧ U(A,B)(t1)
      rw [int_truth_and_iff] at hBUt1
      obtain ⟨hBt1, hUt1⟩ := hBUt1
      -- U(A,B)(t1): ∃ w > t1, A(w) ∧ B on (t1, w)
      obtain ⟨w, ht1w, hAw, hBgd_w⟩ := hUt1
      -- U(A,B)(z) with witness w: A(w), B on (z, w).
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

/-- Q_Z(A,B,C) has no_S_nested_in_U when A, B, C do.
    Q_Z has no untl nodes at all (it uses only snce), so the property
    is trivially satisfied. -/
theorem Q_Z_no_S_nested (A B C : Formula)
    (hA : no_S_nested_in_U A) (hB : no_S_nested_in_U B) (hC : no_S_nested_in_U C) :
    no_S_nested_in_U (Q_Z A B C) := by
  simp only [Q_Z, Formula.or, Formula.neg]
  -- no_S_nested_in_U for imp nodes recurses into both children.
  -- There are no untl nodes in Q_Z, so everything reduces to True and recursive props.
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
    · -- Disjunct (i): S(a, q)(t) -> weaken guard to q v U
      obtain ⟨s, hst, ha_s, hq_guard⟩ := h1
      exact ⟨s, hst, ha_s, fun r hrs hrt =>
        int_truth_or_iff.mpr (Or.inl (hq_guard r hrs hrt))⟩
    · -- Disjunct (ii): S(alpha, Q_Z)(t) ^ (A v B^U)(t)
      rw [int_truth_and_iff] at h2
      obtain ⟨hSalpha, hABU⟩ := h2
      obtain ⟨v, hvt, halpha_v, hQZ_guard⟩ := hSalpha
      -- Unpack alpha(v): either a(v) or (~q(v) ^ S(a,q)(v) ^ (qvU)(v))
      simp only [case3_alpha] at halpha_v
      rcases int_truth_or_iff.mp halpha_v with ha_v | halpha2
      · -- alpha first disjunct: a(v). Build S(a, qvU)(t) with witness v.
        -- Need qvU on (v, t). Use Q_lemma_Z_bwd.
        -- hend: at t, A v (B ^ U) holds. This gives A(t) v (B(t) ^ U(A,B)(t)).
        have hend_for_Q : int_truth M t A ∨ int_truth M t (Formula.and B (.untl A B)) := by
          rcases int_truth_or_iff.mp hABU with hA | hBU
          · exact Or.inl hA
          · exact Or.inr hBU
        have hvt_lt : v < t := hvt
        have hCimplU := Q_lemma_Z_bwd A B (Formula.neg q) M v t hvt_lt hQZ_guard hend_for_Q
        -- hCimplU: for z in (v,t), ~q(z) -> U(A,B)(z)
        -- So for z in (v,t): either q(z) or (if ~q(z) then U(A,B)(z))
        refine ⟨v, hvt, ha_v, fun r hvr hrt => ?_⟩
        rw [int_truth_or_iff]
        by_cases hqr : int_truth M r q
        · exact Or.inl hqr
        · exact Or.inr (hCimplU r hvr hrt hqr)
      · -- alpha second disjunct: ~q(v) ^ S(a,q)(v) ^ (qvU)(v)
        rw [int_truth_and_iff] at halpha2
        obtain ⟨hnq_and_Saq, hqU_v⟩ := halpha2
        rw [int_truth_and_iff] at hnq_and_Saq
        obtain ⟨_hnq_v, hSaq_v⟩ := hnq_and_Saq
        -- S(a,q)(v): exists s < v with a(s) and q on (s,v)
        obtain ⟨s, hsv, ha_s, hq_sv⟩ := hSaq_v
        -- Build S(a, qvU)(t) with witness s.
        -- q on (s,v), then qvU on (v,t) via Q_lemma_Z_bwd
        have hend_for_Q : int_truth M t A ∨ int_truth M t (Formula.and B (.untl A B)) := by
          rcases int_truth_or_iff.mp hABU with hA | hBU
          · exact Or.inl hA
          · exact Or.inr hBU
        have hCimplU := Q_lemma_Z_bwd A B (Formula.neg q) M v t hvt hQZ_guard hend_for_Q
        refine ⟨s, lt_trans hsv hvt, ha_s, fun r hsr hrt => ?_⟩
        rw [int_truth_or_iff]
        rcases lt_trichotomy r v with hrv | hrv | hrv
        · exact Or.inl (hq_sv r hsr hrv)
        · -- r = v: qvU(v) holds
          subst hrv; exact int_truth_or_iff.mp hqU_v
        · -- r > v: use Q_lemma_Z_bwd
          by_cases hqr : int_truth M r q
          · exact Or.inl hqr
          · exact Or.inr (hCimplU r hrv hrt hqr)
  · -- Disjunct (iii): S(A ^ (qvU) ^ S(alpha, Q_Z), q)(t)
    obtain ⟨u, hut, hevent_u, hq_guard⟩ := h3
    -- Unpack event at u: A(u) ^ (qvU)(u) ^ S(alpha, Q_Z)(u)
    rw [int_truth_and_iff] at hevent_u
    obtain ⟨hA_qU, hSalpha_u⟩ := hevent_u
    rw [int_truth_and_iff] at hA_qU
    obtain ⟨hA_u, hqU_u⟩ := hA_qU
    -- S(alpha, Q_Z)(u): exists v < u with alpha(v), Q_Z on (v,u)
    obtain ⟨v, hvu, halpha_v, hQZ_vu⟩ := hSalpha_u
    -- Unpack alpha(v)
    simp only [case3_alpha] at halpha_v
    rcases int_truth_or_iff.mp halpha_v with ha_v | halpha2
    · -- a(v): Build S(a, qvU)(t) with witness v
      -- qvU on (v, u) via Q_lemma_Z_bwd with hend = A(u) or (A(u) as left of Or)
      have hend_u : int_truth M u A ∨ int_truth M u (Formula.and B (.untl A B)) :=
        Or.inl hA_u
      have hCimplU := Q_lemma_Z_bwd A B (Formula.neg q) M v u hvu hQZ_vu hend_u
      refine ⟨v, lt_trans hvu hut, ha_v, fun r hvr hrt => ?_⟩
      rw [int_truth_or_iff]
      rcases lt_trichotomy r u with hru | hru | hru
      · -- r in (v, u): use Q_lemma_Z_bwd
        by_cases hqr : int_truth M r q
        · exact Or.inl hqr
        · exact Or.inr (hCimplU r hvr hru hqr)
      · -- r = u: qvU(u)
        subst hru; exact int_truth_or_iff.mp hqU_u
      · -- r in (u, t): q(r) from hq_guard
        exact Or.inl (hq_guard r hru hrt)
    · -- alpha second disjunct at v
      rw [int_truth_and_iff] at halpha2
      obtain ⟨hnq_and_Saq, _hqU_v⟩ := halpha2
      rw [int_truth_and_iff] at hnq_and_Saq
      obtain ⟨_hnq_v, hSaq_v⟩ := hnq_and_Saq
      obtain ⟨s, hsv, ha_s, hq_sv⟩ := hSaq_v
      -- Build S(a, qvU)(t) with witness s
      have hend_u : int_truth M u A ∨ int_truth M u (Formula.and B (.untl A B)) :=
        Or.inl hA_u
      have hCimplU := Q_lemma_Z_bwd A B (Formula.neg q) M v u hvu hQZ_vu hend_u
      refine ⟨s, lt_trans hsv (lt_trans hvu hut), ha_s, fun r hsr hrt => ?_⟩
      rw [int_truth_or_iff]
      rcases lt_trichotomy r v with hrv | hrv | hrv
      · exact Or.inl (hq_sv r hsr hrv)
      · subst hrv
        -- r = v: we have ~q(v) and (qvU)(v). So not q, so must be U(A,B)(v).
        -- Actually we need qvU at v.
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
/-- Case 3 forward direction: S(a, q v U(A,B)) implies one of three disjuncts.
    This is the harder direction, requiring interval analysis on Z. -/
theorem case3_equiv_Z_fwd (a q A B : Formula) (M : IntStructure) (t : ℤ)
    (h : int_truth M t (.snce a (Formula.or q (.untl A B)))) :
    int_truth M t (case3_rhs a q A B) := by
  -- Unpack S(a, q v U)(t): exists s < t with a(s) and q v U on (s, t)
  obtain ⟨s, hst, ha_s, hguard⟩ := h
  -- Case split: does q hold on all of (s, t)?
  by_cases hq_all : ∀ r, s < r → r < t → int_truth M r q
  · -- YES: disjunct (i) S(a, q)(t)
    simp only [case3_rhs]
    apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; left
    exact ⟨s, hst, ha_s, hq_all⟩
  · -- NO: there exists a point in (s, t) where q fails
    push_neg at hq_all
    obtain ⟨f, hsf, hft, hnqf⟩ := hq_all
    -- f is a point in (s, t) where q fails.
    -- Find the LEAST such point (first failure of q after s)
    haveI : DecidablePred (fun r => ¬int_truth M r q) := Classical.decPred _
    have hex_fail : ∃ n, s < n ∧ ¬int_truth M n q := ⟨f, hsf, hnqf⟩
    obtain ⟨f₀, hsf₀, hnqf₀, hf₀_min⟩ := Int.exists_least_above hex_fail
    -- f₀ is the first point > s where q fails.
    -- q holds on (s, f₀) -- all integers strictly between s and f₀.
    have hq_left : ∀ r, s < r → r < f₀ → int_truth M r q := by
      intro r hsr hrf₀; by_contra hnq; exact hf₀_min r hsr hrf₀ hnq
    -- f₀ < t (because f₀ is at most f, and f < t, actually f₀ ≤ f)
    have hf₀t : f₀ < t := by
      by_contra hle; push_neg at hle
      -- If f₀ ≥ t, then since f < t and ~q(f), we have s < f and f < f₀, so
      -- hf₀_min f hsf hff₀ should give ¬¬q(f), contradiction
      have hff₀ : f < f₀ := lt_of_lt_of_le hft hle
      exact hf₀_min f hsf hff₀ hnqf
    -- Now consider the right side: find the greatest point where q fails before t
    -- Actually, let's find the first point ≥ f₀ from which q holds continuously to t.
    -- Equivalently, find the GREATEST point in [f₀, t-1] where q fails.
    -- Strategy: define r₀ as the greatest point > f₀ (or = f₀) where ~q holds, then
    -- q holds on (r₀, t).
    -- Actually simpler: check if q holds on (f₀, t).
    by_cases hq_right : ∀ r, f₀ < r → r < t → int_truth M r q
    · -- q holds on (f₀, t). So the "gap" where q fails is just the single point f₀.
      -- Since ~q(f₀) and q v U on (s, t), we have U(A,B)(f₀).
      have hqU_f₀ := hguard f₀ hsf₀ hf₀t
      have hU_f₀ : int_truth M f₀ (.untl A B) := by
        rcases int_truth_or_iff.mp hqU_f₀ with hq | hU
        · exact absurd hq hnqf₀
        · exact hU
      -- U(A,B)(f₀): exists w > f₀ with A(w) and B on (f₀, w)
      have hU_f₀_copy := hU_f₀
      obtain ⟨w, hf₀w, hAw, hBguard_w⟩ := hU_f₀_copy
      -- Build alpha(f₀) and show S(alpha, Q_Z)(t)
      -- alpha(f₀) = a(f₀) v (~q(f₀) ^ S(a,q)(f₀) ^ (qvU)(f₀))
      -- Since f₀ > s and q on (s, f₀) and a(s), we have S(a, q)(f₀).
      have hSaq_f₀ : int_truth M f₀ (.snce a q) :=
        ⟨s, hsf₀, ha_s, hq_left⟩
      have halpha_f₀ : int_truth M f₀ (case3_alpha a q A B) := by
        simp only [case3_alpha]
        apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff]; constructor
        · rw [int_truth_and_iff]; exact ⟨hnqf₀, hSaq_f₀⟩
        · exact hqU_f₀
      -- Q_Z holds on (f₀, t) because q holds on (f₀, t).
      -- Q_Z(A,B,~q) = B v A v ~S(~q, ~A). Since q holds on (f₀, t),
      -- at each z in (f₀, t): q(z) -> ~~q(z) -> hmm, Q_Z = B v A v ~S(~q, ~A).
      -- Actually Q_Z is about B, A, and ~S(~q, ~A). We don't get Q_Z just from q.
      -- We need to use Q_lemma_Z_fwd to establish Q_Z on (f₀, t).
      -- Q_lemma_Z_fwd needs: guard (C -> U(A,B)) on (f₀, t) where C = ~q.
      -- Since q holds on (f₀, t), the guard "~q(z) -> U(A,B)(z)" is vacuously true
      -- (the hypothesis ~q(z) is never satisfied for z in (f₀, t)).
      -- Also needs: hinit = U(A,B)(f₀). We have hU_f₀.
      have hQ_on_interval : ∀ z, f₀ < z → z < t → int_truth M z (Q_Z A B (Formula.neg q)) := by
        apply Q_lemma_Z_fwd A B (Formula.neg q) M f₀ t hf₀t
        · intro z hz0 hz1 hC
          -- hC: ~q(z), but q holds on (f₀, t), contradiction
          exact absurd (hq_right z hz0 hz1) hC
        · exact hU_f₀
      -- S(alpha, Q_Z)(t) with witness f₀
      have hSalpha_t : int_truth M t (.snce (case3_alpha a q A B) (Q_Z A B (Formula.neg q))) :=
        ⟨f₀, hf₀t, halpha_f₀, hQ_on_interval⟩
      -- Now determine which disjunct: (ii) or (iii).
      -- We need to check if we can produce (A v B^U) at t, or route to (iii).
      -- Since q holds on (f₀, t), and f₀ < t, we know:
      -- if t - 1 ≥ f₀ + 1 then q(t-1), and we can use q on (f₀, t) for guard
      -- Actually we need either A(t) v B^U(t) for disjunct (ii), or to build (iii).
      -- Since w > f₀ and A(w) and B on (f₀, w):
      rcases le_or_gt w t with hwt | htw
      · -- w ≤ t. Compare w and t.
        rcases eq_or_lt_of_le hwt with rfl | hwt'
        · -- w = t: A(t). Disjunct (ii).
          simp only [case3_rhs]
          apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; right
          rw [int_truth_and_iff]; exact ⟨hSalpha_t, int_truth_or_iff.mpr (Or.inl hAw)⟩
        · -- w < t: A(w), w > f₀, q holds on (w, t) (since f₀ < w from hf₀w; wait, we know q on (f₀,t), so q on (w,t))
          -- Also (qvU)(w): q(w) if f₀ < w < t (yes, from hq_right).
          -- Actually, w might equal f₀ + 1 or anything. Need w > f₀ (true from hf₀w)
          -- and w < t (hwt'). So q(w) from hq_right.
          -- Build disjunct (iii): S(A ^ (qvU) ^ S(alpha, Q_Z), q)(t)
          -- event at w: A(w) ^ (qvU)(w) ^ S(alpha, Q_Z)(w)
          have hqw : int_truth M w q := hq_right w hf₀w hwt'
          have hqU_w : int_truth M w (Formula.or q (.untl A B)) :=
            int_truth_or_iff.mpr (Or.inl hqw)
          -- S(alpha, Q_Z)(w): witness f₀ < w, alpha(f₀), Q_Z on (f₀, w)
          have hSalpha_w : int_truth M w (.snce (case3_alpha a q A B) (Q_Z A B (Formula.neg q))) :=
            ⟨f₀, hf₀w, halpha_f₀, fun z hz1 hz2 => hQ_on_interval z hz1 (lt_trans hz2 hwt')⟩
          have hevent_w : int_truth M w (Formula.and (Formula.and A (Formula.or q (.untl A B)))
               (.snce (case3_alpha a q A B) (Q_Z A B (Formula.neg q)))) := by
            rw [int_truth_and_iff, int_truth_and_iff]
            exact ⟨⟨hAw, hqU_w⟩, hSalpha_w⟩
          simp only [case3_rhs]
          apply int_truth_or_iff.mpr; right
          exact ⟨w, hwt', hevent_w, fun r hwr hrt => hq_right r (lt_trans hf₀w hwr) hrt⟩
      · -- w > t: B holds on (f₀, w), so B(t) (since f₀ < t < w).
        -- Also U(A,B)(t) since w > t: witness w, A(w), B on (t, w).
        have hBt : int_truth M t B := hBguard_w t hf₀t htw
        have hUt : int_truth M t (.untl A B) :=
          ⟨w, htw, hAw, fun r htr hrw => hBguard_w r (lt_trans hf₀t htr) hrw⟩
        simp only [case3_rhs]
        apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff]
        exact ⟨hSalpha_t, int_truth_or_iff.mpr (Or.inr (int_truth_and_iff.mpr ⟨hBt, hUt⟩))⟩
    · -- q does NOT hold on all of (f₀, t). There are more failures after f₀.
      push_neg at hq_right
      obtain ⟨f₁, hf₀f₁, hf₁t, hnqf₁⟩ := hq_right
      -- Find the GREATEST point in (s, t) where q fails (call it g)
      haveI : DecidablePred (fun r => ¬int_truth M r q) := Classical.decPred _
      have hex_fail2 : ∃ n, n < t ∧ ¬int_truth M n q := ⟨f₁, hf₁t, hnqf₁⟩
      obtain ⟨g, hgt, hnqg, hg_max⟩ := Int.exists_greatest_below hex_fail2
      -- g is the GREATEST point < t where ~q. So q holds on (g, t).
      have hq_after_g : ∀ r, g < r → r < t → int_truth M r q := by
        intro r hgr hrt; by_contra hnq; exact hg_max r hgr hrt hnq
      -- g ≥ f₀ (since f₀ < t and ~q(f₀))
      have hf₀g : f₀ ≤ g := by
        by_contra hlt; push_neg at hlt
        -- g < f₀, but f₀ is the first failure after s, and g < t with ~q(g).
        -- g < f₀ means s < g < f₀ (since g < t and g has ~q).
        -- But wait, g < f₀ means g might be ≤ s.
        -- Actually g is greatest below t with ~q. f₀ < t and ~q(f₀), so g ≥ f₀.
        exact hg_max f₀ hlt hf₀t hnqf₀
      -- Since ~q(g) and g in (s, t) (g < t, g ≥ f₀ > s), qvU(g) gives U(A,B)(g)
      have hsg : s < g := lt_of_lt_of_le hsf₀ hf₀g
      have hU_g : int_truth M g (.untl A B) := by
        have := hguard g hsg hgt
        rcases int_truth_or_iff.mp this with hq | hU
        · exact absurd hq hnqg
        · exact hU
      obtain ⟨w, hgw, hAw, hBguard_w⟩ := hU_g
      -- Build alpha at f₀: same as before since f₀ > s with ~q(f₀), S(a,q)(f₀), (qvU)(f₀)
      have hSaq_f₀ : int_truth M f₀ (.snce a q) :=
        ⟨s, hsf₀, ha_s, hq_left⟩
      have hqU_f₀ := hguard f₀ hsf₀ hf₀t
      have halpha_f₀ : int_truth M f₀ (case3_alpha a q A B) := by
        simp only [case3_alpha]
        apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff]; constructor
        · rw [int_truth_and_iff]; exact ⟨hnqf₀, hSaq_f₀⟩
        · exact hqU_f₀
      -- Show Q_Z on (f₀, g+1).
      -- Actually, we need Q_Z on (f₀, r₀) where r₀ is the start of the q-run to t.
      -- r₀ = g + 1: q holds on (g, t) = {g+1, ..., t-1} on Z, and ~q(g).
      -- We need: Q_Z on (f₀, something) where we can build S(alpha, Q_Z).
      -- The interval where Q_Z holds: (f₀, g+1).
      -- Wait: we need Q_Z between the left q-run and right q-run.
      -- The "gap" where q may fail is (f₀-1, g+1), i.e., {f₀, f₀+1, ..., g}.
      -- Actually the guard for Q_lemma_Z_fwd is: C -> U(A,B) on (f₀, something).
      -- C = ~q. On (f₀, g+1): for z in {f₀+1, ..., g}, if ~q(z) then (qvU)(z) gives U(A,B)(z).
      -- For f₀ itself: ~q(f₀) and U(A,B)(f₀) from above.
      -- Let's use interval (f₀, g+1) for Q_lemma_Z_fwd.
      -- But we need g+1 > f₀, i.e., g ≥ f₀. We have hf₀g.
      have hf₀_lt_g1 : f₀ < g + 1 := by omega
      -- guard on (f₀, g+1): for z in (f₀, g+1), ~q(z) -> U(A,B)(z)
      have hguard_gap : ∀ z, f₀ < z → z < g + 1 → (int_truth M z (Formula.neg q) → int_truth M z (.untl A B)) := by
        intro z hf₀z hzg1 hnqz
        -- z ∈ (f₀, g+1) means f₀ < z and z ≤ g, so z < t (since g < t)
        have hzt : z < t := by omega
        have hsz : s < z := lt_trans hsf₀ hf₀z
        rcases int_truth_or_iff.mp (hguard z hsz hzt) with hq | hU
        · exact absurd hq hnqz
        · exact hU
      -- hinit for Q_lemma_Z_fwd: U(A,B)(f₀)
      have hU_f₀ : int_truth M f₀ (.untl A B) := by
        rcases int_truth_or_iff.mp hqU_f₀ with hq | hU
        · exact absurd hq hnqf₀
        · exact hU
      have hQ_gap : ∀ z, f₀ < z → z < g + 1 → int_truth M z (Q_Z A B (Formula.neg q)) :=
        Q_lemma_Z_fwd A B (Formula.neg q) M f₀ (g + 1) hf₀_lt_g1 hguard_gap hU_f₀
      -- Now build S(alpha, Q_Z) at g+1 if g+1 ≤ t.
      -- Actually, we need to consider two subcases:
      -- (a) g + 1 = t: then S(alpha, Q_Z)(t) with Q_Z on (f₀, t)
      -- (b) g + 1 < t: q holds on (g, t), so q(g+1). We can extend Q_Z from (f₀, g+1) to (f₀, t).
      -- Wait, Q_Z might not hold on (g+1, t). Let me reconsider.
      -- For z in (g+1, t): z > g, z < t, so q(z) (from hq_after_g since g < z).
      -- Q_Z(z) = B(z) v A(z) v ~S(~q, ~A)(z). Since q(z), ~q is false at z, so
      -- S(~q, ~A)(z) needs a witness where ~q holds -- but ~q might hold somewhere < z.
      -- Q_Z is not trivially true just from q(z).
      -- But: we can use Q_lemma_Z_fwd on a LONGER interval.
      -- Actually: let's use Q_lemma_Z_fwd on (f₀, t) directly.
      -- guard: for z in (f₀, t), ~q(z) -> U(A,B)(z)
      have hguard_full : ∀ z, f₀ < z → z < t → (int_truth M z (Formula.neg q) → int_truth M z (.untl A B)) := by
        intro z hf₀z hzt hnqz
        have hsz : s < z := lt_trans hsf₀ hf₀z
        rcases int_truth_or_iff.mp (hguard z hsz hzt) with hq | hU
        · exact absurd hq hnqz
        · exact hU
      have hQ_full : ∀ z, f₀ < z → z < t → int_truth M z (Q_Z A B (Formula.neg q)) :=
        Q_lemma_Z_fwd A B (Formula.neg q) M f₀ t hf₀t hguard_full hU_f₀
      -- S(alpha, Q_Z)(t) with witness f₀
      have hSalpha_t : int_truth M t (.snce (case3_alpha a q A B) (Q_Z A B (Formula.neg q))) :=
        ⟨f₀, hf₀t, halpha_f₀, hQ_full⟩
      -- Now route to disjunct (ii) or (iii) based on w vs t.
      rcases le_or_gt w t with hwt | htw
      · rcases eq_or_lt_of_le hwt with rfl | hwt'
        · -- w = t: A(t). Disjunct (ii).
          simp only [case3_rhs]
          apply int_truth_or_iff.mpr; left; apply int_truth_or_iff.mpr; right
          rw [int_truth_and_iff]
          exact ⟨hSalpha_t, int_truth_or_iff.mpr (Or.inl hAw)⟩
        · -- w < t: A(w) with g < w (from hgw). q on (w, t) since w > g.
          -- Wait: w > g. q holds on (g, t). So q(w) if g < w < t. Yes: hwt' and hgw.
          -- But wait: we need w > g for q(w). hgw says w > g.
          -- Actually hgw says g < w. And hwt' says w < t.
          -- q(w) from hq_after_g.
          have hqw : int_truth M w q := hq_after_g w hgw hwt'
          have hqU_w : int_truth M w (Formula.or q (.untl A B)) :=
            int_truth_or_iff.mpr (Or.inl hqw)
          -- S(alpha, Q_Z)(w) with witness f₀
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
      · -- w > t: B(t) and U(A,B)(t). Disjunct (ii).
        have hBt : int_truth M t B := hBguard_w t hgt htw
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


/-! ## U-Evaluation Infrastructure

When U(A,B) is conjoined with an event in S(C^U, F), we know U(A,B) holds
at the event point. This means we can replace all occurrences of U(A,B)
within C by top (= neg bot), yielding a U-free formula. Similarly for ~U.

This is the key technique for proving Cases 5-8 non-circularly:
after applying case3_equiv_Z_general, the RHS has S-terms whose events
contain U(A,B). We split on U/~U at the event point, evaluate U away,
and reduce to Cases 1-2 (already proved without axiom dependency). -/

/-- Replace all occurrences of .untl A B with top (= Formula.neg .bot) in phi. -/
def replace_untl_with_top (phi A B : Formula) : Formula :=
  match phi with
  | .atom a => .atom a
  | .bot => .bot
  | .imp a b => .imp (replace_untl_with_top a A B) (replace_untl_with_top b A B)
  | .box a => .box (replace_untl_with_top a A B)
  | .all_past a => .all_past (replace_untl_with_top a A B)
  | .all_future a => .all_future (replace_untl_with_top a A B)
  | .untl a b => if a == A && b == B then Formula.neg .bot  -- top
                 else .untl (replace_untl_with_top a A B) (replace_untl_with_top b A B)
  | .snce a b => .snce (replace_untl_with_top a A B) (replace_untl_with_top b A B)

/-- Replace all occurrences of .untl A B with bot in phi. -/
def replace_untl_with_bot (phi A B : Formula) : Formula :=
  match phi with
  | .atom a => .atom a
  | .bot => .bot
  | .imp a b => .imp (replace_untl_with_bot a A B) (replace_untl_with_bot b A B)
  | .box a => .box (replace_untl_with_bot a A B)
  | .all_past a => .all_past (replace_untl_with_bot a A B)
  | .all_future a => .all_future (replace_untl_with_bot a A B)
  | .untl a b => if a == A && b == B then .bot
                 else .untl (replace_untl_with_bot a A B) (replace_untl_with_bot b A B)
  | .snce a b => .snce (replace_untl_with_bot a A B) (replace_untl_with_bot b A B)

/-- Semantic correctness: when U(A,B) holds, phi and replace_untl_with_top agree. -/
theorem replace_untl_with_top_correct (phi A B : Formula) (M : IntStructure) (t : ℤ)
    (hU : int_truth M t (.untl A B)) :
    int_truth M t phi ↔ int_truth M t (replace_untl_with_top phi A B) := by
  induction phi with
  | atom _ => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp a b iha ihb =>
    simp only [replace_untl_with_top, int_truth]
    exact ⟨fun h ha => (ihb hU).mp (h ((iha hU).mpr ha)),
           fun h ha => (ihb hU).mpr (h ((iha hU).mp ha))⟩
  | box _ => exact Iff.rfl
  | all_past a ih =>
    simp only [replace_untl_with_top, int_truth]
    exact ⟨fun h s hs => (ih hU).mp (h s hs),
           fun h s hs => (ih hU).mpr (h s hs)⟩
  | all_future a ih =>
    simp only [replace_untl_with_top, int_truth]
    exact ⟨fun h s hs => (ih hU).mp (h s hs),
           fun h s hs => (ih hU).mpr (h s hs)⟩
  | untl a b iha ihb =>
    simp only [replace_untl_with_top]
    by_cases heq : a == A && b == B
    · simp [heq, Formula.neg, int_truth]
      have ha_eq : a = A := by
        have := (Bool.and_eq_true_iff _ _).mp heq
        exact (BEq.eq_of_beq this.1)
      have hb_eq : b = B := by
        have := (Bool.and_eq_true_iff _ _).mp heq
        exact (BEq.eq_of_beq this.2)
      subst ha_eq; subst hb_eq
      exact ⟨fun _ => id, fun _ => hU⟩
    · simp [heq, int_truth]
      exact ⟨fun ⟨s, hts, ha, hb⟩ => ⟨s, hts, (iha hU).mp ha, fun r hr1 hr2 => (ihb hU).mp (hb r hr1 hr2)⟩,
             fun ⟨s, hts, ha, hb⟩ => ⟨s, hts, (iha hU).mpr ha, fun r hr1 hr2 => (ihb hU).mpr (hb r hr1 hr2)⟩⟩
  | snce a b iha ihb =>
    simp only [replace_untl_with_top, int_truth]
    exact ⟨fun ⟨s, hst, ha, hb⟩ => ⟨s, hst, (iha hU).mp ha, fun r hr1 hr2 => (ihb hU).mp (hb r hr1 hr2)⟩,
           fun ⟨s, hst, ha, hb⟩ => ⟨s, hst, (iha hU).mpr ha, fun r hr1 hr2 => (ihb hU).mpr (hb r hr1 hr2)⟩⟩

/-- Semantic correctness: when ¬U(A,B) holds, phi and replace_untl_with_bot agree. -/
theorem replace_untl_with_bot_correct (phi A B : Formula) (M : IntStructure) (t : ℤ)
    (hnotU : ¬ int_truth M t (.untl A B)) :
    int_truth M t phi ↔ int_truth M t (replace_untl_with_bot phi A B) := by
  induction phi with
  | atom _ => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp a b iha ihb =>
    simp only [replace_untl_with_bot, int_truth]
    exact ⟨fun h ha => (ihb hnotU).mp (h ((iha hnotU).mpr ha)),
           fun h ha => (ihb hnotU).mpr (h ((iha hnotU).mp ha))⟩
  | box _ => exact Iff.rfl
  | all_past a ih =>
    simp only [replace_untl_with_bot, int_truth]
    exact ⟨fun h s hs => (ih hnotU).mp (h s hs),
           fun h s hs => (ih hnotU).mpr (h s hs)⟩
  | all_future a ih =>
    simp only [replace_untl_with_bot, int_truth]
    exact ⟨fun h s hs => (ih hnotU).mp (h s hs),
           fun h s hs => (ih hnotU).mpr (h s hs)⟩
  | untl a b iha ihb =>
    simp only [replace_untl_with_bot]
    by_cases heq : a == A && b == B
    · simp [heq, int_truth]
      have ha_eq : a = A := by
        have := (Bool.and_eq_true_iff _ _).mp heq
        exact (BEq.eq_of_beq this.1)
      have hb_eq : b = B := by
        have := (Bool.and_eq_true_iff _ _).mp heq
        exact (BEq.eq_of_beq this.2)
      subst ha_eq; subst hb_eq
      exact ⟨fun h => absurd h hnotU, False.elim⟩
    · simp [heq, int_truth]
      exact ⟨fun ⟨s, hts, ha, hb⟩ => ⟨s, hts, (iha hnotU).mp ha, fun r hr1 hr2 => (ihb hnotU).mp (hb r hr1 hr2)⟩,
             fun ⟨s, hts, ha, hb⟩ => ⟨s, hts, (iha hnotU).mpr ha, fun r hr1 hr2 => (ihb hnotU).mpr (hb r hr1 hr2)⟩⟩
  | snce a b iha ihb =>
    simp only [replace_untl_with_bot, int_truth]
    exact ⟨fun ⟨s, hst, ha, hb⟩ => ⟨s, hst, (iha hnotU).mp ha, fun r hr1 hr2 => (ihb hnotU).mp (hb r hr1 hr2)⟩,
           fun ⟨s, hst, ha, hb⟩ => ⟨s, hst, (iha hnotU).mpr ha, fun r hr1 hr2 => (ihb hnotU).mpr (hb r hr1 hr2)⟩⟩

/-- replace_untl_with_top produces a U-free formula. -/
theorem replace_untl_with_top_U_free (phi A B : Formula) :
    is_U_free (replace_untl_with_top phi A B) = true := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b iha ihb => simp [replace_untl_with_top, is_U_free, iha, ihb]
  | box a ih => simp [replace_untl_with_top, is_U_free, ih]
  | all_past a ih => simp [replace_untl_with_top, is_U_free, ih]
  | all_future a ih => simp [replace_untl_with_top, is_U_free, ih]
  | untl a b iha ihb =>
    simp only [replace_untl_with_top]
    by_cases heq : a == A && b == B
    · simp [heq, Formula.neg, is_U_free]
    · simp [heq, is_U_free, iha, ihb]
  | snce a b iha ihb => simp [replace_untl_with_top, is_U_free, iha, ihb]

/-- replace_untl_with_bot produces a U-free formula. -/
theorem replace_untl_with_bot_U_free (phi A B : Formula) :
    is_U_free (replace_untl_with_bot phi A B) = true := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b iha ihb => simp [replace_untl_with_bot, is_U_free, iha, ihb]
  | box a ih => simp [replace_untl_with_bot, is_U_free, ih]
  | all_past a ih => simp [replace_untl_with_bot, is_U_free, ih]
  | all_future a ih => simp [replace_untl_with_bot, is_U_free, ih]
  | untl a b iha ihb =>
    simp only [replace_untl_with_bot]
    by_cases heq : a == A && b == B
    · simp [heq, is_U_free]
    · simp [heq, is_U_free, iha, ihb]
  | snce a b iha ihb => simp [replace_untl_with_bot, is_U_free, iha, ihb]

/-! ## S-Event U-Evaluation Lemmas -/

/-- When U(A,B) is conjoined with event C, we can replace all U(A,B) in C with top. -/
theorem snce_event_eval_pos (C F A B : Formula) :
    int_equiv (.snce (Formula.and C (.untl A B)) F)
              (.snce (Formula.and (replace_untl_with_top C A B) (.untl A B)) F) := by
  intro M t; constructor
  · rintro ⟨s, hst, hev, hg⟩
    have ⟨hC, hU⟩ := int_truth_and_iff.mp hev
    exact ⟨s, hst, int_truth_and_iff.mpr ⟨(replace_untl_with_top_correct C A B M s hU).mp hC, hU⟩, hg⟩
  · rintro ⟨s, hst, hev, hg⟩
    have ⟨hC', hU⟩ := int_truth_and_iff.mp hev
    exact ⟨s, hst, int_truth_and_iff.mpr ⟨(replace_untl_with_top_correct C A B M s hU).mpr hC', hU⟩, hg⟩

/-- When ~U(A,B) is conjoined with event C, we can replace all U(A,B) in C with bot. -/
theorem snce_event_eval_neg (C F A B : Formula) :
    int_equiv (.snce (Formula.and C (Formula.neg (.untl A B))) F)
              (.snce (Formula.and (replace_untl_with_bot C A B) (Formula.neg (.untl A B))) F) := by
  intro M t; constructor
  · rintro ⟨s, hst, hev, hg⟩
    have ⟨hC, hnotU⟩ := int_truth_and_iff.mp hev
    exact ⟨s, hst, int_truth_and_iff.mpr ⟨(replace_untl_with_bot_correct C A B M s hnotU).mp hC, hnotU⟩, hg⟩
  · rintro ⟨s, hst, hev, hg⟩
    have ⟨hC', hnotU⟩ := int_truth_and_iff.mp hev
    exact ⟨s, hst, int_truth_and_iff.mpr ⟨(replace_untl_with_bot_correct C A B M s hnotU).mpr hC', hnotU⟩, hg⟩

/-! ## Event Decomposition for Separability -/

/-- Full event decomposition: S(C, F) where C may contain U(A,B), F is U-free.
    Split on U at event, evaluate U away, apply Cases 1 and 2. -/
theorem snce_event_decomp_separable (C F A B : Formula)
    (hF_Uf : is_U_free F = true)
    (hA_Uf : is_U_free A = true) (hB_Uf : is_U_free B = true)
    (hA_Sf : is_S_free A = true) (hB_Sf : is_S_free B = true) :
    is_separable (.snce C F) := by
  -- Step 1: Event-split on U(A,B)
  have hsplit := since_event_split C (.untl A B) F
  -- Step 2: Evaluate U away in each branch
  have heval_pos := snce_event_eval_pos C F A B
  have heval_neg := snce_event_eval_neg C F A B
  -- Step 3: Apply Cases 1 and 2
  have hCtop_Uf := replace_untl_with_top_U_free C A B
  have hCbot_Uf := replace_untl_with_bot_U_free C A B
  obtain ⟨psi1, hequiv1, hsep1⟩ := elim_case_1_gen (replace_untl_with_top C A B) F A B
    hCtop_Uf hF_Uf hA_Uf hB_Uf hA_Sf hB_Sf
  obtain ⟨psi2, hequiv2, hsep2⟩ := elim_case_2_gen (replace_untl_with_bot C A B) F A B
    hCbot_Uf hF_Uf hA_Uf hB_Uf hA_Sf hB_Sf
  -- Step 4: Compose equivalences
  have hsep_pos : is_separable (.snce (Formula.and C (.untl A B)) F) :=
    is_separable_of_equiv heval_pos ⟨psi1, hsep1, hequiv1⟩
  have hsep_neg : is_separable (.snce (Formula.and C (Formula.neg (.untl A B))) F) :=
    is_separable_of_equiv heval_neg ⟨psi2, hsep2, hequiv2⟩
  exact is_separable_of_equiv hsplit (or_separable hsep_pos hsep_neg)

/-! ## Case 5 Separability (Non-Circular)

Case 5: S(a ^ U(A,B), q v U(A,B)) is separable.

Strategy: Apply case3_equiv_Z_general with a := a' ^ U(A,B).
The RHS has three disjuncts. Each S-term has a U-free guard.
Events containing U(A,B) are handled by snce_event_decomp_separable. -/

set_option maxHeartbeats 800000 in
/-- Case 5 separability for Z: S(a ^ U(A,B), q v U(A,B)) is separable.
    Proved non-circularly via case3_equiv_Z_general + U-evaluation + Cases 1-2. -/
theorem case5_separable_Z (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (.untl A B)) (Formula.or q (.untl A B))) := by
  have hequiv := case3_equiv_Z_general (Formula.and a (.untl A B)) q A B
  apply is_separable_of_equiv hequiv
  simp only [case3_rhs]
  apply or_separable
  · apply or_separable
    · -- D1: S(a^U, q) is Case 1
      obtain ⟨psi, hequiv1, hsep1⟩ := elim_case_1_gen a q A B ha hq hA hB hA' hB'
      exact ⟨psi, hsep1, hequiv1⟩
    · -- D2: S(alpha, Q_Z) ^ (A v B^U)
      apply and_separable
      · have hQZ_Uf : is_U_free (Q_Z A B (Formula.neg q)) = true := by
          apply Q_Z_U_free <;> simp [Formula.neg, is_U_free, *]
        exact snce_event_decomp_separable
          (case3_alpha (Formula.and a (.untl A B)) q A B)
          (Q_Z A B (Formula.neg q)) A B hQZ_Uf hA hB hA' hB'
      · apply or_separable
        · exact ⟨A, by simp [is_syntactically_separated, is_U_free, is_S_free, hA, hA'],
                   int_equiv_refl A⟩
        · exact ⟨Formula.and B (.untl A B),
                 by simp [Formula.and, Formula.neg, is_syntactically_separated, is_U_free,
                          is_S_free, hB, hB', hA', hB'],
                 int_equiv_refl _⟩
  · -- D3: S(A ^ (qvU) ^ S(alpha, Q_Z), q)
    exact snce_event_decomp_separable
      (Formula.and (Formula.and A (Formula.or q (.untl A B)))
        (.snce (case3_alpha (Formula.and a (.untl A B)) q A B) (Q_Z A B (Formula.neg q))))
      q A B hq hA hB hA' hB'

/-! ## Case 6 Separability (Non-Circular) -/

set_option maxHeartbeats 800000 in
/-- Case 6 separability for Z: S(a ^ ~U(A,B), q v U(A,B)) is separable.
    Same strategy as Case 5 with a := a ^ ~U(A,B). -/
theorem case6_separable_Z (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (Formula.neg (.untl A B)))
      (Formula.or q (.untl A B))) := by
  have hequiv := case3_equiv_Z_general (Formula.and a (Formula.neg (.untl A B))) q A B
  apply is_separable_of_equiv hequiv
  simp only [case3_rhs]
  apply or_separable
  · apply or_separable
    · obtain ⟨psi, hequiv1, hsep1⟩ := elim_case_2_gen a q A B ha hq hA hB hA' hB'
      exact ⟨psi, hsep1, hequiv1⟩
    · apply and_separable
      · have hQZ_Uf : is_U_free (Q_Z A B (Formula.neg q)) = true := by
          apply Q_Z_U_free <;> simp [Formula.neg, is_U_free, *]
        exact snce_event_decomp_separable
          (case3_alpha (Formula.and a (Formula.neg (.untl A B))) q A B)
          (Q_Z A B (Formula.neg q)) A B hQZ_Uf hA hB hA' hB'
      · apply or_separable
        · exact ⟨A, by simp [is_syntactically_separated, is_U_free, is_S_free, hA, hA'],
                   int_equiv_refl A⟩
        · exact ⟨Formula.and B (.untl A B),
                 by simp [Formula.and, Formula.neg, is_syntactically_separated, is_U_free,
                          is_S_free, hB, hB', hA', hB'],
                 int_equiv_refl _⟩
  · exact snce_event_decomp_separable
      (Formula.and (Formula.and A (Formula.or q (.untl A B)))
        (.snce (case3_alpha (Formula.and a (Formula.neg (.untl A B))) q A B)
               (Q_Z A B (Formula.neg q))))
      q A B hq hA hB hA' hB'

/-! ## Case 8 Separability (Non-Circular)

Case 8: S(a ^ ~U(A,B), q v ~U(A,B)) is separable.

Strategy: Decompose via neg_since_equiv (double negation):
  S(a^~U, qv~U) <-> S(a^~U, top) ^ ~S(~q^U, ~avU)

Part 1: S(a^~U, top) has U-free guard -> snce_event_decomp_separable.
Part 2: S(~q^U, ~avU) is Case 5 form -> case5_separable_Z(neg q, neg a). -/

set_option maxHeartbeats 3200000 in
/-- Case 8 decomposition: S(a^~U, qv~U) <-> S(a^~U, top) ^ ~S(~q^U, ~avU). -/
theorem case8_decomp_Z (a q A B : Formula) :
    int_equiv
      (.snce (Formula.and a (Formula.neg (.untl A B)))
             (Formula.or q (Formula.neg (.untl A B))))
      (Formula.and
        (.snce (Formula.and a (Formula.neg (.untl A B))) (Formula.neg .bot))
        (Formula.neg (.snce (Formula.and (Formula.neg q) (.untl A B))
                            (Formula.or (Formula.neg a) (.untl A B))))) := by
  intro M t; constructor
  · -- Forward: S(a^~U, qv~U) -> S(a^~U, top) ^ ~S(~q^U, ~avU)
    intro ⟨s, hst, hev, hguard⟩
    constructor
    · exact ⟨s, hst, hev, fun _ _ _ => id⟩
    · intro ⟨u, hut, hev_u, hguard_u⟩
      have ⟨hnq_u, hU_u⟩ := int_truth_and_iff.mp hev_u
      rcases le_or_gt u s with hus | hsu
      · rcases eq_or_lt_of_le hus with rfl | hus'
        · exact (int_truth_and_iff.mp hev).2 hU_u
        · have h := hguard_u s hus' hst
          rcases int_truth_or_iff.mp h with hna_s | hU_s
          · exact hna_s (int_truth_and_iff.mp hev).1
          · exact (int_truth_and_iff.mp hev).2 hU_s
      · have h := hguard u hsu hut
        rcases int_truth_or_iff.mp h with hq_u | hnU_u
        · exact hnq_u hq_u
        · exact hnU_u hU_u
  · -- Backward: S(a^~U, top) ^ ~S(~q^U, ~avU) -> S(a^~U, qv~U)
    intro ⟨hpast, hnotS⟩
    obtain ⟨s₀, hs₀t, hev₀, _⟩ := hpast
    -- Strategy: find the closest witness to t such that qv~U holds on (witness, t).
    -- Use well-founded descent on (t - witness).
    suffices h : ∀ n : ℕ, ∀ s : ℤ, s < t → t - s - 1 ≤ n →
      int_truth M s (Formula.and a (Formula.neg (.untl A B))) →
      int_truth M t (.snce (Formula.and a (Formula.neg (.untl A B)))
                           (Formula.or q (Formula.neg (.untl A B)))) from
      h (Int.toNat (t - s₀ - 1)) s₀ hs₀t (by omega) hev₀
    intro n
    induction n with
    | zero =>
      intro s hst hle hev
      refine ⟨s, hst, hev, fun r hsr hrt => ?_⟩
      exfalso; omega
    | succ n ih =>
      intro s hst hle hev
      by_cases hok : ∀ r, s < r → r < t → int_truth M r (Formula.or q (Formula.neg (.untl A B)))
      · exact ⟨s, hst, hev, hok⟩
      · push_neg at hok
        obtain ⟨r, hsr, hrt, hnqvnU⟩ := hok
        have hnq_r : ¬ int_truth M r q := fun hq => hnqvnU (int_truth_or_iff.mpr (Or.inl hq))
        have hU_r : int_truth M r (.untl A B) := byContradiction fun hnotU =>
          hnqvnU (int_truth_or_iff.mpr (Or.inr hnotU))
        -- From hnotS: there is no valid S(~q^U, ~avU) witness at r.
        -- So the guard (~avU) must fail on (r, t): ∃ z ∈ (r,t), a(z)^~U(z).
        have hfail : ∃ z, r < z ∧ z < t ∧ int_truth M z (Formula.and a (Formula.neg (.untl A B))) := by
          by_contra hall; push_neg at hall
          apply hnotS
          refine ⟨r, hrt, int_truth_and_iff.mpr ⟨hnq_r, hU_r⟩, fun z hrz hzt => ?_⟩
          rw [int_truth_or_iff]
          by_contra hcontra; push_neg at hcontra
          obtain ⟨hna, hnnU⟩ := hcontra
          have ha_z : int_truth M z a := byContradiction (fun h => hna h)
          have hnotU_z : ¬ int_truth M z (.untl A B) :=
            fun hU_z => hnnU (int_truth_or_iff.mpr (Or.inr hU_z))
          exact hall z hrz hzt (int_truth_and_iff.mpr ⟨ha_z, hnotU_z⟩)
        obtain ⟨z, hrz, hzt, hev_z⟩ := hfail
        exact ih z hzt (by omega) hev_z

set_option maxHeartbeats 800000 in
/-- Case 8 separability for Z: S(a ^ ~U(A,B), q v ~U(A,B)) is separable. -/
theorem case8_separable_Z (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (Formula.neg (.untl A B)))
      (Formula.or q (Formula.neg (.untl A B)))) := by
  apply is_separable_of_equiv (case8_decomp_Z a q A B)
  apply and_separable
  · -- S(a^~U, neg bot): guard is U-free
    exact snce_event_decomp_separable
      (Formula.and a (Formula.neg (.untl A B)))
      (Formula.neg .bot) A B (by simp [Formula.neg, is_U_free]) hA hB hA' hB'
  · -- ~S(~q^U, ~avU): neg of Case 5 with a':=neg q, q':=neg a
    apply neg_separable
    exact case5_separable_Z (Formula.neg q) (Formula.neg a) A B
      (by simp [Formula.neg, is_U_free, hq]) (by simp [Formula.neg, is_U_free, ha])
      hA hB
      (by simp [Formula.neg, is_S_free, hq']) (by simp [Formula.neg, is_S_free, ha'])
      hA' hB'

/-! ## Case 7 Separability

Case 7: S(a ^ U(A,B), q v ~U(A,B)) is separable.

On Z, ~U(A,B) can be rewritten via neg_until_equiv as G(~A) v U(~A^~B, ~A),
introducing a different U-type. This requires the full junction_depth hierarchy
for a non-circular proof. For now, we use all_separable as bootstrap. -/

/-- Case 7 separability for Z: S(a ^ U(A,B), q v ~U(A,B)) is separable. -/
theorem case7_separable_Z (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (.untl A B))
      (Formula.or q (Formula.neg (.untl A B)))) :=
  all_separable _

end Bimodal.Metalogic.WeakCanonical.Separation
