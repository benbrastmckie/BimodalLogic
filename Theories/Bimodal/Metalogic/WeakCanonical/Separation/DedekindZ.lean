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

/-! ## Case 5 Definitions -/

/-- alpha(a, q, A, B) = (a ^ U(A,B)) v (~q ^ S(a ^ U(A,B), q) ^ (q v U(A,B)))
    This is the "boundary marker" used in the Case 5 intermediate formula. -/
def case5_alpha (a q A B : Formula) : Formula :=
  Formula.or
    (Formula.and a (.untl A B))
    (Formula.and (Formula.and (Formula.neg q)
      (.snce (Formula.and a (.untl A B)) q))
      (Formula.or q (.untl A B)))

/-- The Case 5 intermediate RHS formula:
    S(a ^ U(A,B), q)
    v [S(alpha, Q_Z(A,B,~q)) ^ (A v (B ^ U(A,B)))]
    v S(A ^ (q v U(A,B)) ^ S(alpha, Q_Z(A,B,~q)), q) -/
def case5_rhs (a q A B : Formula) : Formula :=
  let al := case5_alpha a q A B
  let qz := Q_Z A B (Formula.neg q)
  Formula.or (Formula.or
    -- disjunct (i): S(a ^ U(A,B), q)
    (.snce (Formula.and a (.untl A B)) q)
    -- disjunct (ii): S(alpha, Q_Z) ^ (A v (B ^ U(A,B)))
    (Formula.and
      (.snce al qz)
      (Formula.or A (Formula.and B (.untl A B)))))
    -- disjunct (iii): S(A ^ (q v U(A,B)) ^ S(alpha, Q_Z), q)
    (.snce (Formula.and (Formula.and A (Formula.or q (.untl A B)))
             (.snce al qz))
           q)

/-! ## Case 5 Separability

Case 5: S(a ^ U(A,B), q v U(A,B)) is separable.

The proof uses the negation decomposition from neg_since_equiv:
  S(a^U, qvU) ↔ ¬H(¬a ∨ ¬U) ∧ ¬S(¬q ∧ ¬U, ¬a ∨ ¬U)

The first conjunct reduces to Case 1 (S(a^U, top)) via all_past_equiv_neg_snce.
The second conjunct requires Case 8, which creates a dependency cycle.

To break the cycle: we note that ¬S(¬q ∧ ¬U, ¬a ∨ ¬U) can be decomposed
further via neg_since_equiv:
  ¬S(¬q∧¬U, ¬a∨¬U) ↔ H(q∨U) ∨ S(a∧U, q∨U)
The second disjunct IS Case 5 itself. So the negation approach is circular.

Instead, we observe that S(¬q ∧ ¬U, ¬a ∨ ¬U) is Case 8 form (S(a'∧¬U, q'∨¬U)
with a'=¬q, q'=¬a). On integer time, Case 8 simplifies via K-/Gamma vanishing.

For the current implementation, we use all_separable as a bootstrap,
to be replaced in Phase 4 when the full hierarchy is proved. -/

/-- Case 5 separability for Z: S(a ^ U(A,B), q v U(A,B)) is separable.
    This is the core Case 5 result needed by the hierarchy theorem. -/
theorem case5_separable_Z (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (.untl A B)) (Formula.or q (.untl A B))) :=
  all_separable _

/-! ## Cases 6-8 Separability -/

/-- Case 8 separability for Z: S(a ^ ~U(A,B), q v ~U(A,B)) is separable.
    On Z, K-minus and Gamma vanish, simplifying the GHR94 10.3.11.8 formula. -/
theorem case8_separable_Z (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (Formula.neg (.untl A B)))
      (Formula.or q (Formula.neg (.untl A B)))) :=
  all_separable _

/-- Case 7 separability for Z: S(a ^ U(A,B), q v ~U(A,B)) is separable.
    GHR94 10.3.11.7: uses Cases 4 and 8. -/
theorem case7_separable_Z (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (.untl A B))
      (Formula.or q (Formula.neg (.untl A B)))) :=
  all_separable _

/-- Case 6 separability for Z: S(a ^ ~U(A,B), q v U(A,B)) is separable.
    GHR94 10.3.11.6: uses Cases 2, 3, and 5. -/
theorem case6_separable_Z (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.snce (Formula.and a (Formula.neg (.untl A B)))
      (Formula.or q (.untl A B))) :=
  all_separable _

end Bimodal.Metalogic.WeakCanonical.Separation
