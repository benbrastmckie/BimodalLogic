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
The key insight: if U(A,B) holds at some guard point r, it provides a U-witness.
By well-ordering in Z, we can "chase the chain" of U-witnesses until either:
(a) a witness passes t (giving U(A,B) at t), (b) a witness equals t (giving A at t),
or (c) q takes over (reducing to Case 1's third disjunct structure).

The separated formula:
  [S(a, B) ^ B ^ U(A,B)]    -- some U-witness after t
  v [A ^ S(a, B)]            -- some U-witness exactly at t
  v S(A ^ q ^ S(a, B), q)   -- chain terminates, q takes over
-/

/-- Target separated formula for Case 5: simplified vs Case 1 (no S(a,q) needed). -/
private def case5_psi (a q A B : Formula) : Formula :=
  Formula.or (Formula.or
    (Formula.and (Formula.and (.snce a B) B) (.untl A B))
    (Formula.and A (.snce a B)))
    (.snce (Formula.and (Formula.and A q) (.snce a B)) q)

set_option maxHeartbeats 800000 in
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
  refine ⟨case5_psi a q A B, ?_, ?_⟩
  · -- Semantic equivalence
    intro M t
    simp only [case5_psi]
    constructor
    · -- Forward: S(a ^ U(A,B), q v U(A,B)) -> psi5
      intro ⟨s, hst, hand, hguard⟩
      have ⟨ha_s, huntl⟩ := int_truth_and_iff.mp hand
      obtain ⟨u, hsu, hAu, hB_guard⟩ := huntl
      -- Chase the chain of U-witnesses using well-ordering
      -- Key: either some U-witness reaches or passes t, or q eventually takes over
      rcases lt_trichotomy u t with hut | hut | hut
      · -- u < t: chain may continue; use well-ordering to find resolution
        -- Either we find a U-witness at or past t, or q takes over from some point
        -- Use classical logic: either ∃ w ∈ (s,t) with A(w) and B covers (s,w) reachable from chain
        -- and eventually past t, OR there's a "last A-point" after which q holds
        -- Strategy: find the LAST point w in [u, t) such that U(A,B) is "needed"
        -- by considering whether U(A,B)(t) holds
        by_cases hUt : ∃ v, t < v ∧ int_truth M v A ∧ ∀ r, t < r → r < v → int_truth M r B
        · -- U(A,B) holds at t: first disjunct
          apply int_truth_or_iff.mpr; left
          apply int_truth_or_iff.mpr; left
          rw [int_truth_and_iff, int_truth_and_iff]
          obtain ⟨v, htv, hAv, hBv⟩ := hUt
          refine ⟨⟨⟨s, hst, ha_s, fun r hsr hrt => ?_⟩, ?_⟩, v, htv, hAv, hBv⟩
          · -- B(r) for r in (s, t): chain provides this
            -- r is in (s, u) since u < t, but r could be in (u, t) too
            rcases lt_or_ge r u with hru | hru
            · exact hB_guard r hsr hru
            · -- r in [u, t): need B(r)
              -- We know U(A,B)(t) holds. For the guard q ∨ U in (s,t):
              -- This doesn't directly give B(r). We need a different argument.
              -- Actually from the guard: (q ∨ U)(r) for r ∈ (s,t).
              -- If U(A,B)(r): ∃ w > r with A(w) and B on (r,w). We have v > t > r.
              -- But we need B(r) specifically, not U(A,B)(r).
              -- Key insight: we DON'T necessarily have B on all of (s,t).
              -- The first disjunct needs S(a,B), which needs B on (s,t) for SOME s.
              -- Let's reconsider: we need S(a,B) at t meaning ∃ s' < t with a(s') and B on (s', t).
              -- We have a(s). Do we have B on (s, t)?
              -- We have B on (s, u) from U(A,B)(s). For r ∈ [u, t): not given directly.
              -- PROBLEM: We cannot prove S(a,B) without B on the full interval.
              -- Need to reconsider the formula.
              sorry
          · -- B(t): also not directly available
            sorry
        · -- U(A,B) does not hold at t: chain terminates, find last A-point
          push_neg at hUt
          -- Every future U-witness from points in (u, t) must have witness ≤ t
          -- Find the "last" point in (s,t) where A holds and has appropriate B-guard
          -- After that point, q must hold until t
          -- Use the guard: for r in (u, t), q(r) ∨ U(A,B)(r)
          -- If U(A,B)(r), witness v > r with A(v) ∧ B on (r,v).
          -- Since U(A,B)(t) fails, for witness from r: either v ≤ t or ¬(A(v) ∧ B on (r,v)) for v > t
          -- Actually hUt says: ∀ v > t, ¬A(v) ∨ ∃ r' ∈ (t,v), ¬B(r')
          -- This means any U-chain from points < t has witnesses ≤ t
          sorry
      · -- u = t: second disjunct
        subst hut
        apply int_truth_or_iff.mpr; left
        apply int_truth_or_iff.mpr; right
        rw [int_truth_and_iff]
        exact ⟨hAu, s, hst, ha_s, hB_guard⟩
      · -- u > t: first disjunct
        apply int_truth_or_iff.mpr; left
        apply int_truth_or_iff.mpr; left
        rw [int_truth_and_iff, int_truth_and_iff]
        exact ⟨⟨⟨s, hst, ha_s, fun r hsr hrt => hB_guard r hsr (lt_trans hrt hut)⟩,
               hB_guard t hst hut⟩,
               ⟨u, hut, hAu, fun r htr hru => hB_guard r (lt_trans hst htr) hru⟩⟩
    · -- Backward: psi5 -> S(a ^ U(A,B), q v U(A,B))
      intro hrhs
      rcases int_truth_or_iff.mp hrhs with h12 | h3
      · rcases int_truth_or_iff.mp h12 with hd1 | hd2
        · -- d1: S(a,B) ^ B(t) ^ U(A,B)(t)
          rw [int_truth_and_iff, int_truth_and_iff] at hd1
          obtain ⟨⟨⟨s, hst, ha_s, hB_s⟩, hBt⟩, ⟨u, htu, hAu, hBu⟩⟩ := hd1
          refine ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s, u, lt_trans hst htu, hAu, fun r hsr hru => ?_⟩,
                  fun r hsr hrt => ?_⟩
          · -- B(r) for r in (s, u): split on r vs t
            rcases lt_trichotomy r t with hrt | hrt | hrt
            · exact hB_s r hsr hrt
            · exact hrt ▸ hBt
            · exact hBu r hrt hru
          · -- Guard: q(r) v U(A,B)(r) for r in (s, t)
            -- U(A,B)(r) holds: witness u > t > r
            apply int_truth_or_iff.mpr; right
            exact ⟨u, lt_trans hrt htu, hAu, fun w hwr hwu => by
              rcases lt_trichotomy w t with hwt | hwt | hwt
              · exact hB_s w (lt_trans hsr hwr) hwt
              · exact hwt ▸ hBt
              · exact hBu w hwt hwu⟩
        · -- d2: A(t) ^ S(a,B)
          rw [int_truth_and_iff] at hd2
          obtain ⟨hAt, ⟨s, hst, ha_s, hB_s⟩⟩ := hd2
          refine ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s, t, hst, hAt, hB_s⟩,
                  fun r hsr hrt => ?_⟩
          -- Guard: for r in (s, t), U(A,B)(r) via witness t
          apply int_truth_or_iff.mpr; right
          exact ⟨t, hrt, hAt, fun w hrw hwt => hB_s w (lt_trans hsr hrw) hwt⟩
      · -- d3: S(A ^ q ^ S(a,B), q)
        obtain ⟨w, hwt, hw_and, hq_rest⟩ := h3
        rw [int_truth_and_iff, int_truth_and_iff] at hw_and
        obtain ⟨⟨hAw, hqw⟩, ⟨s, hsw, ha_s, hB_s⟩⟩ := hw_and
        refine ⟨s, lt_trans hsw hwt, int_truth_and_iff.mpr ⟨ha_s,
          w, hsw, hAw, hB_s⟩, fun r hsr hrt => ?_⟩
        -- Guard: q(r) v U(A,B)(r) for r in (s, t)
        apply int_truth_or_iff.mpr
        rcases lt_trichotomy r w with hrw | hrw | hrw
        · -- r < w: U(A,B)(r) via witness w
          right; exact ⟨w, hrw, hAw, fun v hrv hvw => hB_s v (lt_trans hsr hrv) hvw⟩
        · -- r = w: q(w) holds
          left; exact hrw ▸ hqw
        · -- r > w: q(r) from hq_rest
          left; exact hq_rest r hrw hrt
  · -- Separation check
    simp [case5_psi, Formula.and, Formula.or, Formula.neg,
          is_syntactically_separated, is_U_free, ha, hq, hA, hB, hA', hB']
    exact ⟨u_free_s_free_imp_separated B hB hB',
           u_free_s_free_imp_separated A hA hA'⟩

/-! ## Case 2: S(a ^ not U(A,B), q) -/

set_option maxHeartbeats 800000 in
/-- CASE 2: S(a ^ not U(A,B), q).
    Strategy: apply neg_until_equiv to rewrite not U(A,B), then reduce.
    ¬U(A,B) ↔ G(¬A) ∨ U(¬A∧¬B, ¬A), so:
    S(a ∧ ¬U(A,B), q) ↔ S(a ∧ G(¬A), q) ∨ S(a ∧ U(¬A∧¬B, ¬A), q)
    First part: already separated. Second part: Case 1. -/
theorem elim_case_2 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (Formula.neg (.untl A B))) q) psi ∧
      is_syntactically_separated psi = true := by
  -- Auxiliary facts about ¬A, ¬B, ¬A∧¬B
  have hAneg_Ufree : is_U_free (Formula.neg A) = true := by
    simp [Formula.neg, is_U_free, hA]
  have hBneg_Ufree : is_U_free (Formula.neg B) = true := by
    simp [Formula.neg, is_U_free, hB]
  have hAneg_Sfree : is_S_free (Formula.neg A) = true := by
    simp [Formula.neg, is_S_free, hA']
  have hBneg_Sfree : is_S_free (Formula.neg B) = true := by
    simp [Formula.neg, is_S_free, hB']
  have hAndNegAB_Ufree : is_U_free (Formula.and (Formula.neg A) (Formula.neg B)) = true := by
    simp [Formula.and, Formula.neg, is_U_free, hA, hB]
  have hAndNegAB_Sfree : is_S_free (Formula.and (Formula.neg A) (Formula.neg B)) = true := by
    simp [Formula.and, Formula.neg, is_S_free, hA', hB']
  -- Apply Case 1 to the second disjunct
  obtain ⟨psi1, hequiv1, hsep1⟩ := elim_case_1 a q
    (Formula.and (Formula.neg A) (Formula.neg B)) (Formula.neg A)
    ha hq hAndNegAB_Ufree hAneg_Ufree ha' hq' hAndNegAB_Sfree hAneg_Sfree
  -- The first disjunct S(a ∧ G(¬A), q) is separated
  -- G(¬A) = all_future(neg A). This is S-free (A is S-free) and U-free (A is U-free).
  -- S(a ∧ all_future(neg A), q): event is a ∧ all_future(neg A), both U-free; guard is q, U-free.
  -- So snce with U-free args IS syntactically separated.
  let psi_left := Formula.snce (Formula.and a (.all_future (Formula.neg A))) q
  have hsep_left : is_syntactically_separated psi_left = true := by
    simp [psi_left, Formula.and, Formula.neg, is_syntactically_separated, is_U_free, ha, hq, hA]
  -- The full witness is or(psi_left, psi1)
  refine ⟨Formula.or psi_left psi1, ?_, ?_⟩
  · -- Semantic equivalence
    intro M t
    constructor
    · -- Forward: S(a ∧ ¬U(A,B), q) → or(psi_left, psi1)
      intro ⟨s, hst, hand, hqguard⟩
      have ⟨ha_s, hnotU_s⟩ := int_truth_and_iff.mp hand
      -- hnotU_s : int_truth M s (neg (untl A B)) = (int_truth M s (untl A B) → False)
      -- Apply neg_until_equiv at s: ¬U(A,B)(s) ↔ G(¬A)(s) ∨ U(¬A∧¬B, ¬A)(s)
      have hne := (neg_until_equiv A B M s).mp hnotU_s
      rcases int_truth_or_iff.mp hne with hGA | hU'
      · -- G(¬A)(s): all_future(neg A) holds at s
        apply int_truth_or_iff.mpr; left
        exact ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s, hGA⟩, hqguard⟩
      · -- U(¬A∧¬B, ¬A)(s): this is Case 1's hypothesis
        apply int_truth_or_iff.mpr; right
        exact (hequiv1 M t).mp ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s, hU'⟩, hqguard⟩
    · -- Backward: or(psi_left, psi1) → S(a ∧ ¬U(A,B), q)
      intro hrhs
      rcases int_truth_or_iff.mp hrhs with hleft | hright
      · -- psi_left: S(a ∧ G(¬A), q)
        obtain ⟨s, hst, hand, hqguard⟩ := hleft
        have ⟨ha_s, hGA_s⟩ := int_truth_and_iff.mp hand
        refine ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s, ?_⟩, hqguard⟩
        -- Need: ¬U(A,B)(s), i.e., (neg_until_equiv).mpr applied to G(¬A)
        exact (neg_until_equiv A B M s).mpr (int_truth_or_iff.mpr (Or.inl hGA_s))
      · -- psi1: equivalent to S(a ∧ U(¬A∧¬B, ¬A), q)
        have hS := (hequiv1 M t).mpr hright
        -- hS : int_truth M t (.snce (.and a (.untl ...)) q) = ∃ s, s < t ∧ ...
        obtain ⟨s, hst, hand, hqguard⟩ := hS
        have ⟨ha_s, hU'_s⟩ := int_truth_and_iff.mp hand
        refine ⟨s, hst, int_truth_and_iff.mpr ⟨ha_s, ?_⟩, hqguard⟩
        exact (neg_until_equiv A B M s).mpr (int_truth_or_iff.mpr (Or.inr hU'_s))
  · -- Separation check: or(psi_left, psi1) is separated
    -- or X Y = (neg X).imp Y = (X.imp bot).imp Y
    simp [Formula.or, Formula.neg, is_syntactically_separated, hsep_left, hsep1]

/-! ## Case 4: S(a, q v not U(A,B)) -/

/-- Helper: separated implies neg-separated. If φ is syntactically separated,
    then neg φ (= imp φ bot) is also syntactically separated. -/
private theorem neg_separated {φ : Formula}
    (h : is_syntactically_separated φ = true) :
    is_syntactically_separated (Formula.neg φ) = true := by
  simp [Formula.neg, is_syntactically_separated, h]

/-- Helper: and of two separated formulas is separated. -/
private theorem and_separated {φ ψ : Formula}
    (h1 : is_syntactically_separated φ = true) (h2 : is_syntactically_separated ψ = true) :
    is_syntactically_separated (Formula.and φ ψ) = true := by
  simp [Formula.and, Formula.neg, is_syntactically_separated, h1, h2]

/-- Helper: int_equiv is a congruence for negation. -/
private theorem int_equiv_neg {φ ψ : Formula} (h : int_equiv φ ψ) :
    int_equiv (Formula.neg φ) (Formula.neg ψ) := by
  intro M t
  show (int_truth M t φ → False) ↔ (int_truth M t ψ → False)
  exact ⟨fun hf hp => hf ((h M t).mpr hp), fun hf hp => hf ((h M t).mp hp)⟩

set_option maxHeartbeats 1200000 in
/-- CASE 3: S(a, q v U(A,B)).
    Strategy: negate using neg_since_equiv, then apply Case 2 to the negation.
    ¬S(a, q∨U) ↔ H(¬a) ∨ S(¬a∧¬q∧¬U(A,B), ¬a) [by neg_since_equiv with A'=a, B'=q∨U]
    The second disjunct S(¬a∧¬q∧¬U(A,B), ¬a) is Case 2 form.
    So S(a, q∨U) ↔ ¬H(¬a) ∧ ¬ψ₂ where ψ₂ is the Case 2 result. -/
theorem elim_case_3 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce a (Formula.or q (.untl A B))) psi ∧
      is_syntactically_separated psi = true := by
  -- neg_since_equiv applied to S(a, q∨U(A,B)):
  -- ¬S(a, q∨U) ↔ H(¬a) ∨ S(¬a ∧ ¬(q∨U), ¬a)
  -- ¬(q∨U) = ¬q ∧ ¬U (classically)
  -- So the second part is S(¬a ∧ ¬q ∧ ¬U(A,B), ¬a) = Case 2 with event=¬a∧¬q, guard=¬a, same A,B.
  -- Actually: ¬a ∧ ¬(q∨U) = ¬a ∧ (¬q ∧ ¬U). Written as a formula:
  -- Formula.and (neg a) (Formula.and (neg q) (neg (untl A B)))
  -- Regrouped: Formula.and (Formula.and (neg a) (neg q)) (neg (untl A B))
  -- This is Case 2 form: S(X ∧ ¬U(A,B), Y) with X = ¬a ∧ ¬q, Y = ¬a.
  -- Apply Case 2:
  have ha_neg_Ufree : is_U_free (Formula.neg a) = true := by
    simp [Formula.neg, is_U_free, ha]
  have hq_neg_Ufree : is_U_free (Formula.neg q) = true := by
    simp [Formula.neg, is_U_free, hq]
  have ha_neg_Sfree : is_S_free (Formula.neg a) = true := by
    simp [Formula.neg, is_S_free, ha']
  have hq_neg_Sfree : is_S_free (Formula.neg q) = true := by
    simp [Formula.neg, is_S_free, hq']
  have haq_neg_Ufree : is_U_free (Formula.and (Formula.neg a) (Formula.neg q)) = true := by
    simp [Formula.and, Formula.neg, is_U_free, ha, hq]
  have haq_neg_Sfree : is_S_free (Formula.and (Formula.neg a) (Formula.neg q)) = true := by
    simp [Formula.and, Formula.neg, is_S_free, ha', hq']
  obtain ⟨psi2, hequiv2, hsep2⟩ := elim_case_2
    (Formula.and (Formula.neg a) (Formula.neg q)) (Formula.neg a) A B
    haq_neg_Ufree ha_neg_Ufree hA hB haq_neg_Sfree ha_neg_Sfree hA' hB'
  -- hequiv2: S((¬a∧¬q)∧¬U(A,B), ¬a) ↔ psi2
  -- The H(¬a) part: all_past(neg a) is syntactically separated since neg a is U-free
  have hsep_H : is_syntactically_separated (.all_past (Formula.neg a)) = true := by
    simp [is_syntactically_separated, Formula.neg, is_U_free, ha]
  -- neg_since_equiv gives: ¬S(a, q∨U) ↔ H(¬a) ∨ S(¬a∧¬(q∨U), ¬a)
  -- But our neg_since_equiv has a specific form. Let me use it properly.
  -- neg_since_equiv a (q∨U) gives: ¬S(a, q∨U) ↔ H(¬a) ∨ S(¬a∧¬(q∨U), ¬a)
  -- Now ¬(q∨U) at the formula level is (Formula.neg (Formula.or q (untl A B)))
  -- which equals Formula.neg (imp (neg q) (untl A B)) -- complex!
  -- The semantic meaning is ¬q ∧ ¬U(A,B).
  -- Our neg_since_equiv is stated as:
  -- neg_since_equiv A' B' : ¬S(A', B') ↔ H(¬A') ∨ S(¬A'∧¬B', ¬A')
  -- We need it with A' = a, B' = or q (untl A B).
  -- The "¬B'" = neg(or q (untl A B)).
  -- At the semantic level: int_truth M s (neg (or q (untl A B))) = ¬(q(s) ∨ U(A,B)(s)) = ¬q(s) ∧ ¬U(A,B)(s)
  -- The S-formula in the RHS of neg_since_equiv is S(¬a ∧ ¬(q∨U), ¬a).
  -- int_truth M t (snce (and (neg a) (neg (or q (untl A B)))) (neg a))
  -- = ∃ s < t, [¬a(s) ∧ ¬(q(s) ∨ U(A,B)(s))] ∧ ∀r∈(s,t), ¬a(r)
  -- = ∃ s < t, ¬a(s) ∧ ¬q(s) ∧ ¬U(A,B)(s) ∧ ∀r∈(s,t), ¬a(r)
  -- Now we need this to equal: S((¬a∧¬q)∧¬U(A,B), ¬a)
  -- = ∃ s < t, [(¬a(s)∧¬q(s)) ∧ ¬U(A,B)(s)] ∧ ∀r∈(s,t), ¬a(r)
  -- These are semantically the same! ¬a ∧ (¬q ∧ ¬U) = (¬a ∧ ¬q) ∧ ¬U.
  -- So we can use neg_since_equiv directly.
  -- Final formula: S(a, q∨U) ↔ ¬[H(¬a) ∨ S_equiv_formula]
  -- = ¬H(¬a) ∧ ¬psi2 (where psi2 ≃ S_formula)
  -- The witness: and (neg (all_past (neg a))) (neg psi2)
  -- which equals: and (some_past a) (neg psi2)  [semantically]
  -- Syntactically: Formula.and (Formula.neg (.all_past (Formula.neg a))) (Formula.neg psi2)
  refine ⟨Formula.and (Formula.neg (.all_past (Formula.neg a))) (Formula.neg psi2), ?_, ?_⟩
  · -- Semantic equivalence
    intro M t
    constructor
    · -- Forward: S(a, q∨U) → ¬H(¬a) ∧ ¬psi2
      intro hS
      rw [int_truth_and_iff, int_truth_neg_iff, int_truth_neg_iff]
      constructor
      · -- ¬H(¬a): i.e., ¬(∀s<t, ¬a(s)), i.e., ∃s<t, a(s)
        obtain ⟨s, hst, ha_s, _⟩ := hS
        intro hall
        exact hall s hst ha_s
      · -- ¬psi2: since psi2 ↔ S((¬a∧¬q)∧¬U, ¬a), we need ¬S((¬a∧¬q)∧¬U, ¬a)
        intro hpsi2
        have hS2 := (hequiv2 M t).mpr hpsi2
        -- hS2 : S((¬a∧¬q)∧¬U(A,B), ¬a) at t
        obtain ⟨s2, hs2t, hand2, hguard2⟩ := hS2
        -- hand2: (¬a∧¬q)(s2) ∧ ¬U(A,B)(s2)
        have ⟨haq2, hnotU2⟩ := int_truth_and_iff.mp hand2
        -- haq2: (¬a∧¬q)(s2), encoded as ¬(¬a(s2) → ¬¬q(s2))
        have hna2 : ¬ int_truth M s2 a := by
          intro ha2
          have := int_truth_and_iff.mp haq2
          exact this.1 ha2
        -- hguard2: ∀r∈(s2,t), ¬a(r)
        -- From hS: ∃ s < t, a(s) ∧ ∀r∈(s,t), (q∨U)(r)
        obtain ⟨s, hst, ha_s, hqU_guard⟩ := hS
        -- a(s) holds. s must relate to s2.
        -- hguard2 says ¬a on (s2, t). So s ≤ s2 (since a(s) and s < t).
        have hs_le_s2 : s ≤ s2 := by
          by_contra h; push_neg at h
          exact hguard2 s h hst ha_s
        -- But the guard of S(a, q∨U) gives (q∨U)(r) for r ∈ (s,t).
        -- In particular, for r = s2 (if s < s2 < t): (q∨U)(s2)
        -- But we have ¬q(s2) (from haq2) and ¬U(A,B)(s2). Contradiction!
        rcases eq_or_lt_of_le hs_le_s2 with heq | hlt
        · -- s = s2: a(s) but ¬a(s2). Contradiction since s = s2.
          exact hna2 (heq ▸ ha_s)
        · -- s < s2 < t: (q∨U)(s2) from guard
          have hqU_s2 := hqU_guard s2 hlt hs2t
          -- hqU_s2: q(s2) ∨ U(A,B)(s2)  [semantically from int_truth_or_iff]
          have hqU_or := int_truth_or_iff.mp hqU_s2
          rcases hqU_or with hq2 | hU2
          · -- q(s2): contradicts ¬q(s2)
            have hnq2 : ¬ int_truth M s2 q := by
              intro hq2'
              have := int_truth_and_iff.mp haq2
              exact this.2 hq2'
            exact hnq2 hq2
          · -- U(A,B)(s2): contradicts ¬U(A,B)(s2)
            exact hnotU2 hU2
    · -- Backward: ¬H(¬a) ∧ ¬psi2 → S(a, q∨U)
      intro hand
      rw [int_truth_and_iff, int_truth_neg_iff, int_truth_neg_iff] at hand
      obtain ⟨hnotH, hnotPsi2⟩ := hand
      -- hnotH: ¬(∀s<t, ¬a(s)), so ∃s<t, a(s)
      -- hnotPsi2: ¬(int_truth M t psi2)
      -- Since psi2 ↔ S((¬a∧¬q)∧¬U, ¬a):
      have hnotS2 : ¬ int_truth M t (.snce (Formula.and (Formula.and (Formula.neg a) (Formula.neg q)) (Formula.neg (.untl A B))) (Formula.neg a)) := by
        intro hS2
        exact hnotPsi2 ((hequiv2 M t).mp hS2)
      -- neg_since_equiv for S(a, q∨U):
      -- ¬S(a, q∨U) ↔ H(¬a) ∨ S(¬a∧¬(q∨U), ¬a)
      -- Contrapositively: S(a, q∨U) ↔ ¬H(¬a) ∧ ¬S(¬a∧¬(q∨U), ¬a)
      -- We have ¬H(¬a). We need ¬S(¬a∧¬(q∨U), ¬a) → S(a, q∨U).
      -- Actually: ¬[H(¬a) ∨ S(...)] = ¬H(¬a) ∧ ¬S(...)
      -- And ¬S(a, q∨U) ↔ H(¬a) ∨ S(...)
      -- So S(a, q∨U) ↔ ¬(H(¬a) ∨ S(...)) = ¬H(¬a) ∧ ¬S(...)
      -- We need to use neg_since_equiv in the .mpr direction.
      -- neg_since_equiv a (or q (untl A B)) M t gives:
      -- ¬S(a, q∨U) ↔ H(¬a) ∨ S(¬a∧¬(q∨U), ¬a)
      -- We want S(a, q∨U), i.e., we want to show ¬(¬S(a, q∨U))
      by_contra hnotS
      -- hnotS : ¬ int_truth M t (.snce a (or q (untl A B)))
      have hne := (neg_since_equiv a (Formula.or q (.untl A B)) M t).mp hnotS
      rcases int_truth_or_iff.mp hne with hH | hS_neg
      · -- H(¬a): contradicts hnotH
        exact hnotH hH
      · -- S(¬a∧¬(q∨U), ¬a): need to relate this to S((¬a∧¬q)∧¬U, ¬a)
        -- Semantically: ¬a∧¬(q∨U) at s means ¬a(s) ∧ ¬q(s) ∧ ¬U(A,B)(s)
        -- = (¬a∧¬q)(s) ∧ ¬U(A,B)(s), which is the same.
        -- At the formula level: and (neg a) (neg (or q (untl A B)))
        -- vs: and (and (neg a) (neg q)) (neg (untl A B))
        -- These are semantically equivalent but syntactically different.
        -- We need to show int_truth M t S((¬a∧¬q)∧¬U, ¬a) from S(¬a∧¬(q∨U), ¬a).
        obtain ⟨s, hst, hevent, hguard⟩ := hS_neg
        -- hevent: int_truth M s (and (neg a) (neg (or q (untl A B))))
        -- = ¬(¬a(s) → ¬¬(q∨U)(s)) = ¬a(s) ∧ ¬(q∨U)(s) = ¬a(s) ∧ ¬q(s) ∧ ¬U(A,B)(s)
        have ⟨hna_s, hnotQU_s⟩ := int_truth_and_iff.mp hevent
        -- hnotQU_s: ¬(q∨U)(s) = ¬((q→⊥)→U)  semantically = ¬q(s) ∧ ¬U(s)
        have hnotQ_s : ¬ int_truth M s q := by
          intro hq_s
          exact (int_truth_neg_iff.mp hnotQU_s) (int_truth_or_iff.mpr (Or.inl hq_s))
        have hnotU_s : ¬ int_truth M s (.untl A B) := by
          intro hU_s
          exact (int_truth_neg_iff.mp hnotQU_s) (int_truth_or_iff.mpr (Or.inr hU_s))
        -- Now construct: S((¬a∧¬q)∧¬U, ¬a)
        apply hnotS2
        exact ⟨s, hst, int_truth_and_iff.mpr ⟨int_truth_and_iff.mpr ⟨hna_s, hnotQ_s⟩, hnotU_s⟩, hguard⟩
  · -- Separation check
    exact and_separated (neg_separated hsep_H) (neg_separated hsep2)

/-! ## Case 4: S(a, q v not U(A,B)) -/

set_option maxHeartbeats 1200000 in
/-- CASE 4: S(a, q v not U(A,B)).
    Strategy: Same as Case 3 but with ¬U in guard instead of U.
    Reduce using neg_since_equiv + Case 5.
    ¬S(a, q∨¬U) ↔ H(¬a) ∨ S(¬a∧¬(q∨¬U), ¬a) = H(¬a) ∨ S(¬a∧¬q∧U(A,B), ¬a)
    The second disjunct S(¬a∧¬q∧U(A,B), ¬a) is Case 1 form (U in event). -/
theorem elim_case_4 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce a (Formula.or q (Formula.neg (.untl A B)))) psi ∧
      is_syntactically_separated psi = true := by
  -- Same strategy as Case 3: negate using neg_since_equiv
  -- ¬S(a, q∨¬U) ↔ H(¬a) ∨ S(¬a∧¬(q∨¬U), ¬a)
  -- ¬(q∨¬U) = ¬q ∧ U(A,B) [semantically, since ¬¬U = U]
  -- So: S(¬a∧¬q∧U(A,B), ¬a) is Case 1 with event = (¬a∧¬q), guard = ¬a, and U(A,B).
  -- More precisely: S((¬a∧¬q)∧U(A,B), ¬a) = elim_case_1 (¬a∧¬q) (¬a) A B.
  have ha_neg_Ufree : is_U_free (Formula.neg a) = true := by
    simp [Formula.neg, is_U_free, ha]
  have hq_neg_Ufree : is_U_free (Formula.neg q) = true := by
    simp [Formula.neg, is_U_free, hq]
  have ha_neg_Sfree : is_S_free (Formula.neg a) = true := by
    simp [Formula.neg, is_S_free, ha']
  have hq_neg_Sfree : is_S_free (Formula.neg q) = true := by
    simp [Formula.neg, is_S_free, hq']
  have haq_neg_Ufree : is_U_free (Formula.and (Formula.neg a) (Formula.neg q)) = true := by
    simp [Formula.and, Formula.neg, is_U_free, ha, hq]
  have haq_neg_Sfree : is_S_free (Formula.and (Formula.neg a) (Formula.neg q)) = true := by
    simp [Formula.and, Formula.neg, is_S_free, ha', hq']
  -- Apply Case 1: S((¬a∧¬q)∧U(A,B), ¬a)
  obtain ⟨psi1, hequiv1, hsep1⟩ := elim_case_1
    (Formula.and (Formula.neg a) (Formula.neg q)) (Formula.neg a) A B
    haq_neg_Ufree ha_neg_Ufree hA hB haq_neg_Sfree ha_neg_Sfree hA' hB'
  have hsep_H : is_syntactically_separated (.all_past (Formula.neg a)) = true := by
    simp [is_syntactically_separated, Formula.neg, is_U_free, ha]
  -- Witness: and (neg (all_past (neg a))) (neg psi1)
  refine ⟨Formula.and (Formula.neg (.all_past (Formula.neg a))) (Formula.neg psi1), ?_, ?_⟩
  · -- Semantic equivalence
    intro M t
    constructor
    · -- Forward: S(a, q∨¬U) → ¬H(¬a) ∧ ¬psi1
      intro hS
      rw [int_truth_and_iff, int_truth_neg_iff, int_truth_neg_iff]
      constructor
      · -- ¬H(¬a)
        obtain ⟨s, hst, ha_s, _⟩ := hS
        intro hall; exact hall s hst ha_s
      · -- ¬psi1
        intro hpsi1
        have hS1 := (hequiv1 M t).mpr hpsi1
        -- hS1: S((¬a∧¬q)∧U(A,B), ¬a) at t
        obtain ⟨s1, hs1t, hevent1, hguard1⟩ := hS1
        have ⟨haq1, hU1⟩ := int_truth_and_iff.mp hevent1
        have hna1 : ¬ int_truth M s1 a := by
          intro h; exact (int_truth_and_iff.mp haq1).1 h
        have hnq1 : ¬ int_truth M s1 q := by
          intro h; exact (int_truth_and_iff.mp haq1).2 h
        -- From hS: ∃ s < t, a(s) ∧ ∀r∈(s,t), (q∨¬U)(r)
        obtain ⟨s, hst, ha_s, hguard_S⟩ := hS
        -- a(s) and ¬a on (s1,t) from hguard1. So s ≤ s1.
        have hs_le : s ≤ s1 := by
          by_contra h; push_neg at h
          exact hguard1 s h hst ha_s
        rcases eq_or_lt_of_le hs_le with heq | hlt
        · exact hna1 (heq ▸ ha_s)
        · -- s < s1: from guard of S: (q∨¬U)(s1)
          have hg := hguard_S s1 hlt hs1t
          rcases int_truth_or_iff.mp hg with hq_s1 | hnotU_s1
          · exact hnq1 hq_s1
          · -- ¬U(A,B)(s1): contradicts hU1
            exact (int_truth_neg_iff.mp hnotU_s1) hU1
    · -- Backward: ¬H(¬a) ∧ ¬psi1 → S(a, q∨¬U)
      intro hand
      rw [int_truth_and_iff, int_truth_neg_iff, int_truth_neg_iff] at hand
      obtain ⟨hnotH, hnotPsi1⟩ := hand
      have hnotS1 : ¬ int_truth M t (.snce (Formula.and (Formula.and (Formula.neg a) (Formula.neg q)) (.untl A B)) (Formula.neg a)) := by
        intro hS1; exact hnotPsi1 ((hequiv1 M t).mp hS1)
      by_contra hnotS
      have hne := (neg_since_equiv a (Formula.or q (Formula.neg (.untl A B))) M t).mp hnotS
      rcases int_truth_or_iff.mp hne with hH | hS_neg
      · exact hnotH hH
      · -- S(¬a ∧ ¬(q∨¬U), ¬a) at t
        -- ¬(q∨¬U) = ¬q ∧ U(A,B) semantically
        obtain ⟨s, hst, hevent, hguard⟩ := hS_neg
        have ⟨hna_s, hnotG⟩ := int_truth_and_iff.mp hevent
        -- hnotG: ¬(q∨¬U)(s) semantically = ¬q(s) ∧ U(A,B)(s)
        have hnotQ_s : ¬ int_truth M s q := by
          intro hq_s
          exact (int_truth_neg_iff.mp hnotG)
            (int_truth_or_iff.mpr (Or.inl hq_s))
        have hU_s : int_truth M s (.untl A B) := by
          by_contra hnotU
          exact (int_truth_neg_iff.mp hnotG)
            (int_truth_or_iff.mpr (Or.inr (int_truth_neg_iff.mpr hnotU)))
        -- Construct S((¬a∧¬q)∧U(A,B), ¬a) for the contradiction
        apply hnotS1
        exact ⟨s, hst, int_truth_and_iff.mpr ⟨int_truth_and_iff.mpr ⟨hna_s, hnotQ_s⟩, hU_s⟩, hguard⟩
  · exact and_separated (neg_separated hsep_H) (neg_separated hsep1)

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
