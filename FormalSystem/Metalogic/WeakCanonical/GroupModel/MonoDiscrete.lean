/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.GroupModel.BlockDecomposition
import FormalSystem.Metalogic.WeakCanonical.MixedSum

/-!
# Monochromatic discrete completeness at depth `k`

Doets 1987, 1.0.2 (back-and-forth for linear orders, pp. 1-22) and 1.0.3
((i) `m ≡ⁿ ω + ω*` for `m ≥ 2ⁿ - 1`; (ii) `ω ≡ⁿ ω + ζ`): any two *monochromatic* discrete
linear orders with the same endpoint profile from {no endpoints, min-only, max-only} are
`KEquiv` at every depth `k` — the classical completeness of `Th(ℤ,<)` and `Th(ω,<)`,
transposed to monadic structures whose predicates are constant (and matching) on both sides.

## The invariant

The Duplicator strategy is the standard threshold invariant: with `d` rounds remaining, each
matched pair of points has, against every other matched pair, the same order relation and the
same truncated succ-distance — *equal when below `2^d`, indistinguishably large otherwise*.
Distances are handled purely through the *partial* reachability statements
`succ^[m] x = y` for `m` below the threshold; no total distance function is ever defined,
which is what lets the argument run on non-Archimedean discrete orders.

Matched pairs are carried as a `List (M.carrier × N.carrier)` (`MonoInv`), so endpoint anchors
can be pinned into the invariant without occupying `BackForth` environment positions: the
min-only variant starts from the singleton list holding the two minima, the no-endpoint
variant from the empty list. The max-only variant is obtained from the min-only one by order
duality (`dualStructure`), transporting `BackForth` along the mirror involution on atoms.

## Main results

* `monoInv_step` — the Duplicator answering step: one Spoiler move in `N` is answered in `M`,
  restoring the invariant one threshold down.
* `backForth_of_monoInv` — the invariant yields a `BackForth` strategy.
* `kEquiv_monoDiscrete_noEnds` — monochromatic discrete unbounded orders are `≡ₖ` for all `k`.
* `kEquiv_monoDiscrete_minNoMax` — the min-only variant (`ω ≡ⁿ ω + ζ·L` family).
* `kEquiv_monoDiscrete_maxNoMin` — the max-only variant, by duality.
* `kEquiv_colourStructure_const`, `kEquiv_colourStructure_const_min`,
  `kEquiv_colourStructure_const_max` — the corollaries at `colourSig` for constant colourings
  consumed by the Ramsey factorization (`GroupModel/RamseyFactorization.lean`).

## References

- Doets 1987, ch. 1, pp. 1-22 (1.0.2, 1.0.3).
- `literature/Doets_1989_Monadic_Pi11_Theories.md`.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open Order

/-! ## Toolkit extensions -/

section Toolkit

variable {α : Type} [LinearOrder α] [SuccOrder α]

/-- `succ` iterates from a fixed base are monotone in the iterate count. -/
theorem succ_iterate_le_succ_iterate (x : α) {m n : ℕ} (h : m ≤ n) :
    succ^[m] x ≤ succ^[n] x := by
  have hn : n = (n - m) + m := by omega
  rw [hn, Function.iterate_add_apply]
  exact Order.le_succ_iterate _ _

/-- On an order with no maximum, `succ` iterates return to the base only trivially. -/
theorem succ_iterate_eq_self_iff [NoMaxOrder α] (x : α) (m : ℕ) :
    succ^[m] x = x ↔ m = 0 := by
  constructor
  · intro h
    by_contra hm
    exact absurd h (ne_of_gt (lt_succ_iterate_of_pos x (by omega)))
  · rintro rfl; rfl

/-- Either `pred^[s]` is exactly inverted by `succ^[s]` at `x`, or `x` sits within `s` `succ`
steps above a minimal element. This is the truncation dichotomy the min-anchored variant
needs, since `Order.succ_pred` is unavailable there. -/
theorem succ_iterate_pred_iterate_or_min [PredOrder α] (x : α) :
    ∀ s : ℕ, succ^[s] (pred^[s] x) = x ∨ ∃ q < s, ∃ z : α, IsMin z ∧ succ^[q] z = x := by
  intro s
  induction s with
  | zero => exact Or.inl rfl
  | succ s ih =>
    rcases ih with hex | ⟨q, hq, z, hz, hzq⟩
    · by_cases hmin : IsMin (pred^[s] x)
      · exact Or.inr ⟨s, by omega, pred^[s] x, hmin, hex⟩
      · refine Or.inl ?_
        have e1 : Order.pred^[s + 1] x = Order.pred (Order.pred^[s] x) :=
          Function.iterate_succ_apply' _ _ _
        rw [e1, Function.iterate_succ_apply, Order.succ_pred_of_not_isMin hmin]
        exact hex
    · exact Or.inr ⟨q, by omega, z, hz, hzq⟩

end Toolkit

/-- A maximizer over a list for an arbitrary key, relative to a predicate. -/
private theorem exists_max_key {γ β : Type} [LinearOrder β] (f : γ → β) {P : γ → Prop} :
    ∀ {l : List γ}, (∃ x ∈ l, P x) → ∃ x ∈ l, P x ∧ ∀ y ∈ l, P y → f y ≤ f x := by
  intro l
  induction l with
  | nil => rintro ⟨x, hx, _⟩; cases hx
  | cons hd tl ih =>
    intro h
    by_cases htl : ∃ x ∈ tl, P x
    · obtain ⟨x, hxl, hxP, hxmax⟩ := ih htl
      by_cases hhd : P hd
      · rcases le_total (f hd) (f x) with hle | hle
        · refine ⟨x, List.mem_cons_of_mem _ hxl, hxP, ?_⟩
          intro y hy hPy
          rcases List.mem_cons.mp hy with rfl | hy'
          · exact hle
          · exact hxmax y hy' hPy
        · refine ⟨hd, List.mem_cons_self .., hhd, ?_⟩
          intro y hy hPy
          rcases List.mem_cons.mp hy with rfl | hy'
          · exact le_refl _
          · exact (hxmax y hy' hPy).trans hle
      · refine ⟨x, List.mem_cons_of_mem _ hxl, hxP, ?_⟩
        intro y hy hPy
        rcases List.mem_cons.mp hy with rfl | hy'
        · exact absurd hPy hhd
        · exact hxmax y hy' hPy
    · obtain ⟨x, hxl, hxP⟩ := h
      rcases List.mem_cons.mp hxl with rfl | hx'
      · refine ⟨x, List.mem_cons_self .., hxP, ?_⟩
        intro y hy hPy
        rcases List.mem_cons.mp hy with rfl | hy'
        · exact le_refl _
        · exact absurd ⟨y, hy', hPy⟩ htl
      · exact absurd ⟨x, hx', hxP⟩ htl

/-! ## The threshold invariant -/

section MonoInvariant

variable {sig : MonadicSignature} (M N : OrderedMonadicStructure sig)
variable [SuccOrder M.carrier] [SuccOrder N.carrier]

/--
**The Duplicator threshold invariant** at `d` remaining rounds: every two matched pairs agree
on order, and on every succ-reachability statement truncated below the threshold `2^d` —
distances are equal when small, and jointly at-least-threshold otherwise (Doets 1.0.2/1.0.3).
-/
def MonoInv (d : ℕ) (pairs : List (M.carrier × N.carrier)) : Prop :=
  ∀ p ∈ pairs, ∀ q ∈ pairs,
    (p.1 < q.1 ↔ p.2 < q.2) ∧
    ∀ m : ℕ, m < 2 ^ d → (succ^[m] p.1 = q.1 ↔ succ^[m] p.2 = q.2)

variable {M N}

theorem MonoInv.order_iff {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (h : MonoInv M N d pairs) {p q : M.carrier × N.carrier}
    (hp : p ∈ pairs) (hq : q ∈ pairs) : p.1 < q.1 ↔ p.2 < q.2 :=
  (h p hp q hq).1

theorem MonoInv.dist_iff {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (h : MonoInv M N d pairs) {p q : M.carrier × N.carrier}
    (hp : p ∈ pairs) (hq : q ∈ pairs) {m : ℕ} (hm : m < 2 ^ d) :
    succ^[m] p.1 = q.1 ↔ succ^[m] p.2 = q.2 :=
  (h p hp q hq).2 m hm

theorem MonoInv.le_iff {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (h : MonoInv M N d pairs) {p q : M.carrier × N.carrier}
    (hp : p ∈ pairs) (hq : q ∈ pairs) : p.1 ≤ q.1 ↔ p.2 ≤ q.2 := by
  rw [← not_lt, ← not_lt]
  exact not_congr (h.order_iff hq hp)

theorem MonoInv.mono {d d' : ℕ} {pairs : List (M.carrier × N.carrier)}
    (hd : d' ≤ d) (h : MonoInv M N d pairs) : MonoInv M N d' pairs := by
  intro p hp q hq
  refine ⟨(h p hp q hq).1, fun m hm => (h p hp q hq).2 m ?_⟩
  exact lt_of_lt_of_le hm (Nat.pow_le_pow_right (by norm_num) hd)

theorem monoInv_swap {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (h : MonoInv M N d pairs) : MonoInv N M d (pairs.map Prod.swap) := by
  intro p hp q hq
  obtain ⟨p', hp', rfl⟩ := List.mem_map.mp hp
  obtain ⟨q', hq', rfl⟩ := List.mem_map.mp hq
  exact ⟨(h p' hp' q' hq').1.symm, fun m hm => ((h p' hp' q' hq').2 m hm).symm⟩

theorem monoInv_of_swap {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (h : MonoInv N M d (pairs.map Prod.swap)) : MonoInv M N d pairs := by
  intro p hp q hq
  have h' := h p.swap (List.mem_map_of_mem hp) q.swap (List.mem_map_of_mem hq)
  exact ⟨h'.1.symm, fun m hm => (h'.2 m hm).symm⟩

/-- Extending the invariant by one matched pair reduces to the new pair's obligations against
the old pairs; the new-new diagonal is discharged once and for all here. -/
theorem monoInv_cons [NoMaxOrder M.carrier] [NoMaxOrder N.carrier]
    {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (hinv : MonoInv M N d pairs) (a : M.carrier) (b : N.carrier)
    (horder : ∀ q ∈ pairs, (a < q.1 ↔ b < q.2) ∧ (q.1 < a ↔ q.2 < b))
    (hdist : ∀ q ∈ pairs, ∀ m : ℕ, m < 2 ^ d →
      ((succ^[m] a = q.1 ↔ succ^[m] b = q.2) ∧ (succ^[m] q.1 = a ↔ succ^[m] q.2 = b))) :
    MonoInv M N d ((a, b) :: pairs) := by
  intro p hp q hq
  rcases List.mem_cons.mp hp with rfl | hp' <;> rcases List.mem_cons.mp hq with rfl | hq'
  · refine ⟨by simp, fun m hm => ?_⟩
    show succ^[m] a = a ↔ succ^[m] b = b
    rw [succ_iterate_eq_self_iff, succ_iterate_eq_self_iff]
  · exact ⟨(horder q hq').1, fun m hm => (hdist q hq' m hm).1⟩
  · exact ⟨(horder p hp').2, fun m hm => (hdist p hp' m hm).2⟩
  · exact hinv p hp' q hq'

/-! ## The Duplicator answering step

The Spoiler move `b : N.carrier` is answered according to its position among the matched
`N`-points: equal to one (`monoInv_step`, case A); within threshold distance above the
nearest matched point below (`monoInv_step_left_near`); within threshold distance below the
nearest matched point above (`monoInv_step_right`, which needs an exact `pred`-point,
produced by `exists_succ_source`); or at least threshold away from all neighbours
(`monoInv_step_left_far` / `monoInv_step_far_right`).
-/

private theorem monoInv_step_left_near [NoMaxOrder M.carrier] [NoMaxOrder N.carrier]
    {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (hinv : MonoInv M N (d + 1) pairs) {b : N.carrier}
    (hA : ¬ ∃ p ∈ pairs, p.2 = b)
    {pL : M.carrier × N.carrier} (hpL : pL ∈ pairs) (hpLb : pL.2 < b)
    (hpLmax : ∀ y ∈ pairs, y.2 < b → y.2 ≤ pL.2)
    {r : ℕ} (hrT : r < 2 ^ d) (hrb : succ^[r] pL.2 = b) :
    MonoInv M N d ((succ^[r] pL.1, b) :: pairs) := by
  have hTT : 2 ^ (d + 1) = 2 ^ d + 2 ^ d := by rw [pow_succ]; omega
  have hlow : MonoInv M N d pairs := hinv.mono (Nat.le_succ d)
  have htri : ∀ q ∈ pairs, q.2 < b ∨ b < q.2 := fun q hq =>
    lt_or_gt_of_ne fun he => hA ⟨q, hq, he⟩
  have hr0 : 0 < r := by
    rcases Nat.eq_zero_or_pos r with rfl | h
    · exact absurd (by simpa using hrb) (ne_of_lt hpLb)
    · exact h
  have hpLa : pL.1 < succ^[r] pL.1 := lt_succ_iterate_of_pos _ hr0
  have haq : ∀ q ∈ pairs, b < q.2 → succ^[r] pL.1 < q.1 := by
    intro q hq hbq
    by_contra hc
    rw [not_lt] at hc
    have hpLq : pL.1 < q.1 := (hinv.order_iff hpL hq).mpr (hpLb.trans hbq)
    obtain ⟨j, hj, hje⟩ := exists_succ_iterate_of_le_of_le r pL.1 q.1 hpLq.le hc
    have hjeN : succ^[j] pL.2 = q.2 := (hinv.dist_iff hpL hq (by omega)).mp hje
    have hle : q.2 ≤ b := by
      rw [← hjeN, ← hrb]
      exact succ_iterate_le_succ_iterate _ hj
    exact absurd hbq (not_lt.mpr hle)
  refine monoInv_cons hlow _ _ ?_ ?_
  · intro q hq
    rcases htri q hq with hqb | hbq
    · have hq1 : q.1 ≤ pL.1 := (hinv.le_iff hq hpL).mpr (hpLmax q hq hqb)
      have h1 : q.1 < succ^[r] pL.1 := lt_of_le_of_lt hq1 hpLa
      exact ⟨iff_of_false (not_lt.mpr h1.le) (not_lt.mpr hqb.le), iff_of_true h1 hqb⟩
    · exact ⟨iff_of_true (haq q hq hbq) hbq,
        iff_of_false (not_lt.mpr (haq q hq hbq).le) (not_lt.mpr hbq.le)⟩
  · intro q hq m hm
    constructor
    · -- (a → q): the answer is exactly placed, so this is the anchor's clause shifted by `r`.
      rw [← hrb, ← Function.iterate_add_apply, ← Function.iterate_add_apply]
      exact hinv.dist_iff hpL hq (by omega)
    · rcases htri q hq with hqb | hbq
      · have hq2 : q.2 ≤ pL.2 := hpLmax q hq hqb
        have hq1 : q.1 ≤ pL.1 := (hinv.le_iff hq hpL).mpr hq2
        constructor
        · intro h
          have hple : pL.1 ≤ succ^[m] q.1 := by
            rw [h]; exact Order.le_succ_iterate r pL.1
          obtain ⟨j, hjm, hje⟩ := exists_succ_iterate_of_le_of_le m q.1 pL.1 hq1 hple
          have h1 : succ^[m - j] pL.1 = succ^[m] q.1 := by
            rw [← hje, ← Function.iterate_add_apply, show m - j + j = m by omega]
          have hmj : m - j = r := succ_iterate_count_inj pL.1 (h1.trans h)
          have hjeN : succ^[j] q.2 = pL.2 := (hinv.dist_iff hq hpL (by omega)).mp hje
          calc succ^[m] q.2 = succ^[m - j] (succ^[j] q.2) := by
                rw [← Function.iterate_add_apply, show m - j + j = m by omega]
            _ = b := by rw [hjeN, hmj, hrb]
        · intro h
          have hple : pL.2 ≤ succ^[m] q.2 := by rw [h]; exact hpLb.le
          obtain ⟨j, hjm, hje⟩ := exists_succ_iterate_of_le_of_le m q.2 pL.2 hq2 hple
          have h1 : succ^[m - j] pL.2 = succ^[m] q.2 := by
            rw [← hje, ← Function.iterate_add_apply, show m - j + j = m by omega]
          have hmj : m - j = r := succ_iterate_count_inj pL.2 (h1.trans (h.trans hrb.symm))
          have hjeM : succ^[j] q.1 = pL.1 := (hinv.dist_iff hq hpL (by omega)).mpr hje
          calc succ^[m] q.1 = succ^[m - j] (succ^[j] q.1) := by
                rw [← Function.iterate_add_apply, show m - j + j = m by omega]
            _ = succ^[r] pL.1 := by rw [hjeM, hmj]
      · exact iff_of_false
          (succ_iterate_ne_of_gt (haq q hq hbq) m)
          (succ_iterate_ne_of_gt hbq m)

private theorem monoInv_step_left_far [NoMaxOrder M.carrier] [NoMaxOrder N.carrier]
    {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (hinv : MonoInv M N (d + 1) pairs) {b : N.carrier}
    (hA : ¬ ∃ p ∈ pairs, p.2 = b)
    {pL : M.carrier × N.carrier} (hpL : pL ∈ pairs) (hpLb : pL.2 < b)
    (hpLmax : ∀ y ∈ pairs, y.2 < b → y.2 ≤ pL.2)
    (hnr : ¬ ∃ r, r < 2 ^ d ∧ succ^[r] pL.2 = b)
    (hup : ∀ u, u < 2 ^ d → ∀ q ∈ pairs, b < q.2 → succ^[u] b ≠ q.2) :
    MonoInv M N d ((succ^[2 ^ d] pL.1, b) :: pairs) := by
  have hT0 : 0 < 2 ^ d := pow_pos (by norm_num) d
  have hTT : 2 ^ (d + 1) = 2 ^ d + 2 ^ d := by rw [pow_succ]; omega
  have hlow : MonoInv M N d pairs := hinv.mono (Nat.le_succ d)
  have htri : ∀ q ∈ pairs, q.2 < b ∨ b < q.2 := fun q hq =>
    lt_or_gt_of_ne fun he => hA ⟨q, hq, he⟩
  have hpLa : pL.1 < succ^[2 ^ d] pL.1 := lt_succ_iterate_of_pos _ hT0
  have haq : ∀ q ∈ pairs, b < q.2 → succ^[2 ^ d] pL.1 < q.1 := by
    intro q hq hbq
    by_contra hc
    rw [not_lt] at hc
    have hpLq : pL.1 < q.1 := (hinv.order_iff hpL hq).mpr (hpLb.trans hbq)
    obtain ⟨j, hj, hje⟩ := exists_succ_iterate_of_le_of_le (2 ^ d) pL.1 q.1 hpLq.le hc
    have hjeN : succ^[j] pL.2 = q.2 := (hinv.dist_iff hpL hq (by omega)).mp hje
    obtain ⟨v, hv, hve⟩ := exists_succ_iterate_of_le_of_le j pL.2 b hpLb.le
      (by rw [hjeN]; exact hbq.le)
    have hvj : v < j := by
      rcases Nat.lt_or_ge v j with h1 | h1
      · exact h1
      · exfalso
        have hveq : v = j := by omega
        rw [hveq, hjeN] at hve
        exact absurd hve.symm (ne_of_lt hbq)
    exact hnr ⟨v, by omega, hve⟩
  refine monoInv_cons hlow _ _ ?_ ?_
  · intro q hq
    rcases htri q hq with hqb | hbq
    · have hq1 : q.1 ≤ pL.1 := (hinv.le_iff hq hpL).mpr (hpLmax q hq hqb)
      have h1 : q.1 < succ^[2 ^ d] pL.1 := lt_of_le_of_lt hq1 hpLa
      exact ⟨iff_of_false (not_lt.mpr h1.le) (not_lt.mpr hqb.le), iff_of_true h1 hqb⟩
    · exact ⟨iff_of_true (haq q hq hbq) hbq,
        iff_of_false (not_lt.mpr (haq q hq hbq).le) (not_lt.mpr hbq.le)⟩
  · intro q hq m hm
    rcases htri q hq with hqb | hbq
    · have hq2 : q.2 ≤ pL.2 := hpLmax q hq hqb
      have hq1 : q.1 ≤ pL.1 := (hinv.le_iff hq hpL).mpr hq2
      constructor
      · exact iff_of_false
          (succ_iterate_ne_of_gt (lt_of_le_of_lt hq1 hpLa) m)
          (succ_iterate_ne_of_gt hqb m)
      · refine iff_of_false (fun h => ?_) (fun h => ?_)
        · have hple : pL.1 ≤ succ^[m] q.1 := by
            rw [h]; exact Order.le_succ_iterate _ _
          obtain ⟨j, hjm, hje⟩ := exists_succ_iterate_of_le_of_le m q.1 pL.1 hq1 hple
          have h1 : succ^[m - j] pL.1 = succ^[m] q.1 := by
            rw [← hje, ← Function.iterate_add_apply, show m - j + j = m by omega]
          have hmj : m - j = 2 ^ d := succ_iterate_count_inj pL.1 (h1.trans h)
          omega
        · have hple : pL.2 ≤ succ^[m] q.2 := by rw [h]; exact hpLb.le
          obtain ⟨j, hjm, hje⟩ := exists_succ_iterate_of_le_of_le m q.2 pL.2 hq2 hple
          have h1 : succ^[m - j] pL.2 = succ^[m] q.2 := by
            rw [← hje, ← Function.iterate_add_apply, show m - j + j = m by omega]
          exact hnr ⟨m - j, by omega, h1.trans h⟩
    · constructor
      · refine iff_of_false (fun h => ?_) (fun h => ?_)
        · have h2 : succ^[m + 2 ^ d] pL.1 = q.1 := by
            rw [Function.iterate_add_apply]; exact h
          have h2N : succ^[m + 2 ^ d] pL.2 = q.2 := (hinv.dist_iff hpL hq (by omega)).mp h2
          obtain ⟨v, hv, hve⟩ := exists_succ_iterate_of_le_of_le (m + 2 ^ d) pL.2 b hpLb.le
            (by rw [h2N]; exact hbq.le)
          have hvT : 2 ^ d ≤ v := by
            by_contra hc
            rw [not_le] at hc
            exact hnr ⟨v, hc, hve⟩
          have h3 : succ^[m + 2 ^ d - v] b = q.2 := by
            rw [← hve, ← Function.iterate_add_apply, show m + 2 ^ d - v + v = m + 2 ^ d by omega]
            exact h2N
          exact hup (m + 2 ^ d - v) (by omega) q hq hbq h3
        · exact hup m hm q hq hbq h
      · exact iff_of_false
          (succ_iterate_ne_of_gt (haq q hq hbq) m)
          (succ_iterate_ne_of_gt hbq m)

private theorem monoInv_step_right [NoMaxOrder M.carrier] [NoMaxOrder N.carrier]
    {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (hinv : MonoInv M N (d + 1) pairs) {b : N.carrier}
    (hA : ¬ ∃ p ∈ pairs, p.2 = b)
    {pR : M.carrier × N.carrier} (hpR : pR ∈ pairs) (hbpR : b < pR.2)
    (hpRmin : ∀ y ∈ pairs, b < y.2 → pR.2 ≤ y.2)
    {s : ℕ} (hsT : s < 2 ^ d) (hs0 : 0 < s) (hsb : succ^[s] b = pR.2)
    {a : M.carrier} (ha : succ^[s] a = pR.1) :
    MonoInv M N d ((a, b) :: pairs) := by
  have hTT : 2 ^ (d + 1) = 2 ^ d + 2 ^ d := by rw [pow_succ]; omega
  have hlow : MonoInv M N d pairs := hinv.mono (Nat.le_succ d)
  have htri : ∀ q ∈ pairs, q.2 < b ∨ b < q.2 := fun q hq =>
    lt_or_gt_of_ne fun he => hA ⟨q, hq, he⟩
  have haR : a < pR.1 := by rw [← ha]; exact lt_succ_iterate_of_pos a hs0
  have habove : ∀ q ∈ pairs, b < q.2 → a < q.1 := fun q hq hbq =>
    lt_of_lt_of_le haR ((hinv.le_iff hpR hq).mpr (hpRmin q hq hbq))
  have hbelow : ∀ q ∈ pairs, q.2 < b → q.1 < a := by
    intro q hq hqb
    by_contra hc
    rw [not_lt] at hc
    have hqR : q.1 < pR.1 := (hinv.order_iff hq hpR).mpr (hqb.trans hbpR)
    obtain ⟨j, hjs, hje⟩ := exists_succ_iterate_of_le_of_le s a q.1 hc
      (by rw [ha] at *; exact hqR.le)
    have hjlt : j < s := by
      rcases Nat.lt_or_ge j s with h1 | h1
      · exact h1
      · exfalso
        have hjeq : j = s := by omega
        rw [hjeq, ha] at hje
        exact absurd hje.symm (ne_of_lt hqR)
    have h2 : succ^[s - j] q.1 = pR.1 := by
      rw [← hje, ← Function.iterate_add_apply, show s - j + j = s by omega]
      exact ha
    have h2N : succ^[s - j] q.2 = pR.2 := (hinv.dist_iff hq hpR (by omega)).mp h2
    have hlt : succ^[s - j] q.2 < succ^[s] b := by
      calc succ^[s - j] q.2 < succ^[s - j] b := (Order.succ_strictMono.iterate (s - j)) hqb
        _ ≤ succ^[s] b := succ_iterate_le_succ_iterate b (by omega)
    rw [h2N, hsb] at hlt
    exact absurd hlt (lt_irrefl _)
  refine monoInv_cons hlow _ _ ?_ ?_
  · intro q hq
    rcases htri q hq with hqb | hbq
    · exact ⟨iff_of_false (not_lt.mpr (hbelow q hq hqb).le) (not_lt.mpr hqb.le),
        iff_of_true (hbelow q hq hqb) hqb⟩
    · exact ⟨iff_of_true (habove q hq hbq) hbq,
        iff_of_false (not_lt.mpr (habove q hq hbq).le) (not_lt.mpr hbq.le)⟩
  · intro q hq m hm
    rcases htri q hq with hqb | hbq
    · constructor
      · exact iff_of_false (succ_iterate_ne_of_gt (hbelow q hq hqb) m)
          (succ_iterate_ne_of_gt hqb m)
      · constructor
        · intro h
          have h2 : succ^[m + s] q.1 = pR.1 := by
            rw [show m + s = s + m by omega, Function.iterate_add_apply, h]
            exact ha
          have h2N : succ^[m + s] q.2 = pR.2 := (hinv.dist_iff hq hpR (by omega)).mp h2
          have h3 : succ^[s] (succ^[m] q.2) = succ^[s] b := by
            rw [← Function.iterate_add_apply, show s + m = m + s by omega, h2N, hsb]
          exact succ_iterate_injective s h3
        · intro h
          have h2N : succ^[m + s] q.2 = pR.2 := by
            rw [show m + s = s + m by omega, Function.iterate_add_apply, h]
            exact hsb
          have h2 : succ^[m + s] q.1 = pR.1 := (hinv.dist_iff hq hpR (by omega)).mpr h2N
          have h3 : succ^[s] (succ^[m] q.1) = succ^[s] a := by
            rw [← Function.iterate_add_apply, show s + m = m + s by omega, h2, ha]
          exact succ_iterate_injective s h3
    · constructor
      · rcases Nat.lt_or_ge m s with hms | hms
        · refine iff_of_false (fun h => ?_) (fun h => ?_)
          · have hlt : succ^[m] a < pR.1 := by
              rw [← ha]; exact succ_iterate_lt_succ_iterate a hms
            rw [h] at hlt
            exact absurd ((hinv.le_iff hpR hq).mpr (hpRmin q hq hbq)) (not_le.mpr hlt)
          · have hlt : succ^[m] b < pR.2 := by
              rw [← hsb]; exact succ_iterate_lt_succ_iterate b hms
            rw [h] at hlt
            exact absurd (hpRmin q hq hbq) (not_le.mpr hlt)
        · have e1 : succ^[m] a = succ^[m - s] pR.1 := by
            rw [← ha, ← Function.iterate_add_apply, show m - s + s = m by omega]
          have e2 : succ^[m] b = succ^[m - s] pR.2 := by
            rw [← hsb, ← Function.iterate_add_apply, show m - s + s = m by omega]
          rw [e1, e2]
          exact hinv.dist_iff hpR hq (by omega)
      · exact iff_of_false (succ_iterate_ne_of_gt (habove q hq hbq) m)
          (succ_iterate_ne_of_gt hbq m)

private theorem monoInv_step_far_right [NoMaxOrder M.carrier] [NoMaxOrder N.carrier]
    {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (hinv : MonoInv M N (d + 1) pairs) {b : N.carrier}
    {pR : M.carrier × N.carrier} (hpR : pR ∈ pairs) (hbpR : b < pR.2)
    (hpRmin : ∀ y ∈ pairs, b < y.2 → pR.2 ≤ y.2)
    (hnos : ¬ ∃ u, u < 2 ^ d ∧ succ^[u] b = pR.2)
    (hall : ∀ q ∈ pairs, b < q.2)
    {a : M.carrier} (ha : succ^[2 ^ d] a = pR.1) :
    MonoInv M N d ((a, b) :: pairs) := by
  have hT0 : 0 < 2 ^ d := pow_pos (by norm_num) d
  have hlow : MonoInv M N d pairs := hinv.mono (Nat.le_succ d)
  have haR : a < pR.1 := by rw [← ha]; exact lt_succ_iterate_of_pos a hT0
  have habove : ∀ q ∈ pairs, a < q.1 := fun q hq =>
    lt_of_lt_of_le haR ((hinv.le_iff hpR hq).mpr (hpRmin q hq (hall q hq)))
  refine monoInv_cons hlow _ _ ?_ ?_
  · intro q hq
    exact ⟨iff_of_true (habove q hq) (hall q hq),
      iff_of_false (not_lt.mpr (habove q hq).le) (not_lt.mpr (hall q hq).le)⟩
  · intro q hq m hm
    constructor
    · refine iff_of_false (fun h => ?_) (fun h => ?_)
      · have hlt : succ^[m] a < pR.1 := by
          rw [← ha]; exact succ_iterate_lt_succ_iterate a hm
        rw [h] at hlt
        exact absurd ((hinv.le_iff hpR hq).mpr (hpRmin q hq (hall q hq))) (not_le.mpr hlt)
      · obtain ⟨u, hu, hue⟩ := exists_succ_iterate_of_le_of_le m b pR.2 hbpR.le
          (by rw [h]; exact hpRmin q hq (hall q hq))
        exact hnos ⟨u, by omega, hue⟩
    · exact iff_of_false (succ_iterate_ne_of_gt (habove q hq) m)
        (succ_iterate_ne_of_gt (hall q hq) m)

/-- The exact `pred`-point producer: an `a` with `succ^[s] a = pR.1`, available either from
genuine unboundedness below, or because a pinned bottom anchor makes truncation contradict
the threshold obstruction on the `N` side. -/
private theorem exists_succ_source [NoMaxOrder N.carrier] [PredOrder M.carrier]
    {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (hinv : MonoInv M N (d + 1) pairs)
    (hbot : (∃ p₀ ∈ pairs, (∀ x, p₀.1 ≤ x) ∧ (∀ y, p₀.2 ≤ y)) ∨
      (NoMinOrder M.carrier ∧ NoMinOrder N.carrier))
    {b : N.carrier} {pR : M.carrier × N.carrier} (hpR : pR ∈ pairs) (hbpR : b < pR.2)
    (s : ℕ) (hs2 : s < 2 ^ (d + 1))
    (hobs : ∀ j, j < s → succ^[j] b ≠ pR.2) :
    ∃ a : M.carrier, succ^[s] a = pR.1 := by
  rcases succ_iterate_pred_iterate_or_min pR.1 s with hex | ⟨q, hqs, z, hzmin, hzq⟩
  · exact ⟨_, hex⟩
  · rcases hbot with ⟨p₀, hp₀, hp₀M, hp₀N⟩ | ⟨hM, _⟩
    · exfalso
      have hz : z = p₀.1 := le_antisymm (hzmin (hp₀M z)) (hp₀M z)
      rw [hz] at hzq
      have hqN : succ^[q] p₀.2 = pR.2 := (hinv.dist_iff hp₀ hpR (by omega)).mp hzq
      obtain ⟨jb, hjb, hjbe⟩ := exists_succ_iterate_of_le_of_le q p₀.2 b (hp₀N b)
        (by rw [hqN]; exact hbpR.le)
      have h3 : succ^[q - jb] b = pR.2 := by
        rw [← hjbe, ← Function.iterate_add_apply, show q - jb + jb = q by omega]
        exact hqN
      exact hobs (q - jb) (by omega) h3
    · haveI := hM
      exact ⟨_, succ_iterate_pred_iterate pR.1 s⟩

/--
**The Duplicator answering step** (Doets 1.0.2's induction step, threshold form): any Spoiler
move `b` in `N` is answered by an `a` in `M` restoring the invariant one threshold down. The
region below the matched configuration is protected either by a pinned bottom-anchor pair or
by unboundedness below on both sides.
-/
theorem monoInv_step [NoMaxOrder M.carrier] [NoMaxOrder N.carrier]
    [PredOrder M.carrier] [Nonempty M.carrier]
    {d : ℕ} {pairs : List (M.carrier × N.carrier)}
    (hbot : (∃ p₀ ∈ pairs, (∀ x, p₀.1 ≤ x) ∧ (∀ y, p₀.2 ≤ y)) ∨
      (NoMinOrder M.carrier ∧ NoMinOrder N.carrier))
    (hinv : MonoInv M N (d + 1) pairs) (b : N.carrier) :
    ∃ a : M.carrier, MonoInv M N d ((a, b) :: pairs) := by
  have hT0 : 0 < 2 ^ d := pow_pos (by norm_num) d
  have hTT : 2 ^ (d + 1) = 2 ^ d + 2 ^ d := by rw [pow_succ]; omega
  have hlow : MonoInv M N d pairs := hinv.mono (Nat.le_succ d)
  by_cases hA : ∃ p ∈ pairs, p.2 = b
  · obtain ⟨p, hp, hpb⟩ := hA
    subst hpb
    exact ⟨p.1, monoInv_cons hlow _ _
      (fun q hq => ⟨hlow.order_iff hp hq, hlow.order_iff hq hp⟩)
      (fun q hq m hm => ⟨hlow.dist_iff hp hq hm, hlow.dist_iff hq hp hm⟩)⟩
  · have htri : ∀ q ∈ pairs, q.2 < b ∨ b < q.2 := fun q hq =>
      lt_or_gt_of_ne fun he => hA ⟨q, hq, he⟩
    by_cases hL : ∃ q ∈ pairs, q.2 < b
    · obtain ⟨pL, hpL, hpLb, hpLmax⟩ := exists_max_key (fun q => q.2) hL
      by_cases hr : ∃ r, r < 2 ^ d ∧ succ^[r] pL.2 = b
      · obtain ⟨r, hrT, hrb⟩ := hr
        exact ⟨_, monoInv_step_left_near hinv hA hpL hpLb hpLmax hrT hrb⟩
      · by_cases hR : ∃ q ∈ pairs, b < q.2
        · obtain ⟨pR, hpR, hbpR, hpRmin⟩ := exists_max_key (fun q => OrderDual.toDual q.2) hR
          have hpRmin' : ∀ y ∈ pairs, b < y.2 → pR.2 ≤ y.2 := fun y hy hby => hpRmin y hy hby
          by_cases hs : ∃ u, u < 2 ^ d ∧ succ^[u] b = pR.2
          · obtain ⟨s, hsT, hsb⟩ := hs
            have hs0 : 0 < s := by
              rcases Nat.eq_zero_or_pos s with rfl | h
              · exact absurd (by simpa using hsb) (ne_of_lt hbpR)
              · exact h
            obtain ⟨a, ha⟩ := exists_succ_source hinv hbot hpR hbpR s (by omega)
              (fun j hj hje =>
                absurd (succ_iterate_count_inj b (hje.trans hsb.symm)) (by omega))
            exact ⟨a, monoInv_step_right hinv hA hpR hbpR hpRmin' hsT hs0 hsb ha⟩
          · have hup : ∀ u, u < 2 ^ d → ∀ q ∈ pairs, b < q.2 → succ^[u] b ≠ q.2 := by
              intro u hu q hq hbq hue
              obtain ⟨v, hv, hve⟩ := exists_succ_iterate_of_le_of_le u b pR.2 hbpR.le
                (by rw [hue]; exact hpRmin' q hq hbq)
              exact hs ⟨v, by omega, hve⟩
            exact ⟨_, monoInv_step_left_far hinv hA hpL hpLb hpLmax hr hup⟩
        · have hup : ∀ u, u < 2 ^ d → ∀ q ∈ pairs, b < q.2 → succ^[u] b ≠ q.2 :=
            fun u _ q hq hbq _ => absurd ⟨q, hq, hbq⟩ hR
          exact ⟨_, monoInv_step_left_far hinv hA hpL hpLb hpLmax hr hup⟩
    · by_cases hR : ∃ q ∈ pairs, b < q.2
      · obtain ⟨pR, hpR, hbpR, hpRmin⟩ := exists_max_key (fun q => OrderDual.toDual q.2) hR
        have hpRmin' : ∀ y ∈ pairs, b < y.2 → pR.2 ≤ y.2 := fun y hy hby => hpRmin y hy hby
        have hall : ∀ q ∈ pairs, b < q.2 := by
          intro q hq
          rcases htri q hq with h1 | h1
          · exact absurd ⟨q, hq, h1⟩ hL
          · exact h1
        by_cases hs : ∃ u, u < 2 ^ d ∧ succ^[u] b = pR.2
        · obtain ⟨s, hsT, hsb⟩ := hs
          have hs0 : 0 < s := by
            rcases Nat.eq_zero_or_pos s with rfl | h
            · exact absurd (by simpa using hsb) (ne_of_lt hbpR)
            · exact h
          obtain ⟨a, ha⟩ := exists_succ_source hinv hbot hpR hbpR s (by omega)
            (fun j hj hje =>
              absurd (succ_iterate_count_inj b (hje.trans hsb.symm)) (by omega))
          exact ⟨a, monoInv_step_right hinv hA hpR hbpR hpRmin' hsT hs0 hsb ha⟩
        · obtain ⟨a, ha⟩ := exists_succ_source hinv hbot hpR hbpR (2 ^ d) (by omega)
            (fun j hj hje => hs ⟨j, hj, hje⟩)
          exact ⟨a, monoInv_step_far_right hinv hpR hbpR hpRmin' hs hall ha⟩
      · refine ⟨Classical.arbitrary M.carrier, monoInv_cons hlow _ _ ?_ ?_⟩
        · intro q hq
          exact absurd (htri q hq)
            (by rintro (h | h); exacts [hL ⟨q, hq, h⟩, hR ⟨q, hq, h⟩])
        · intro q hq m hm
          exact absurd (htri q hq)
            (by rintro (h | h); exacts [hL ⟨q, hq, h⟩, hR ⟨q, hq, h⟩])

end MonoInvariant

/-! ## From the invariant to a strategy -/

private theorem atom_agree_of_monoInv {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig}
    [SuccOrder M.carrier] [SuccOrder N.carrier]
    {d n : ℕ} {pairs : List (M.carrier × N.carrier)}
    (hmono : ∀ p : sig.preds,
      ((∀ x, M.interp p x) ∧ (∀ y, N.interp p y)) ∨
      ((∀ x, ¬ M.interp p x) ∧ (∀ y, ¬ N.interp p y)))
    (hinv : MonoInv M N d pairs)
    {eM : Fin n → M.carrier} {eN : Fin n → N.carrier}
    (hmem : ∀ i, (eM i, eN i) ∈ pairs) :
    ∀ ak : AtomKind sig n, AtomEval M eM ak ↔ AtomEval N eN ak := by
  intro ak
  cases ak with
  | pred p i =>
    rcases hmono p with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact iff_of_true (h1 _) (h2 _)
    · exact iff_of_false (h1 _) (h2 _)
  | order i j hne =>
    exact hinv.order_iff (hmem i) (hmem j)

/-- **The invariant yields a strategy** — the master induction of Doets 1.0.2 in threshold
form. Matched pairs are carried as a list, so pinned endpoint anchors survive every move. -/
theorem backForth_of_monoInv {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig}
    [SuccOrder M.carrier] [SuccOrder N.carrier]
    [NoMaxOrder M.carrier] [NoMaxOrder N.carrier]
    [PredOrder M.carrier] [PredOrder N.carrier]
    [Nonempty M.carrier] [Nonempty N.carrier]
    (hmono : ∀ p : sig.preds,
      ((∀ x, M.interp p x) ∧ (∀ y, N.interp p y)) ∨
      ((∀ x, ¬ M.interp p x) ∧ (∀ y, ¬ N.interp p y))) :
    ∀ (d : ℕ) (pairs : List (M.carrier × N.carrier)),
      ((∃ p₀ ∈ pairs, (∀ x, p₀.1 ≤ x) ∧ (∀ y, p₀.2 ≤ y)) ∨
        (NoMinOrder M.carrier ∧ NoMinOrder N.carrier)) →
      ∀ (n : ℕ) (eM : Fin n → M.carrier) (eN : Fin n → N.carrier),
        (∀ i, (eM i, eN i) ∈ pairs) → MonoInv M N d pairs →
        BackForth sig d n M N eM eN := by
  intro d
  induction d with
  | zero => intro _ _ _ _ _ _ _; trivial
  | succ d ih =>
    intro pairs hbot n eM eN hmem hinv
    have hmem' : ∀ (a : M.carrier) (b : N.carrier),
        ∀ i : Fin (n + 1),
          ((Fin.cons a eM : Fin (n + 1) → M.carrier) i,
            (Fin.cons b eN : Fin (n + 1) → N.carrier) i) ∈ (a, b) :: pairs := by
      intro a b i
      cases i using Fin.cases with
      | zero => simp only [Fin.cons_zero]; exact List.mem_cons_self ..
      | succ j => simp only [Fin.cons_succ]; exact List.mem_cons_of_mem _ (hmem j)
    have hbot' : ∀ (a : M.carrier) (b : N.carrier),
        (∃ p₀ ∈ (a, b) :: pairs, (∀ x, p₀.1 ≤ x) ∧ (∀ y, p₀.2 ≤ y)) ∨
          (NoMinOrder M.carrier ∧ NoMinOrder N.carrier) := by
      intro a b
      rcases hbot with ⟨p₀, hp₀, h1, h2⟩ | h
      · exact Or.inl ⟨p₀, List.mem_cons_of_mem _ hp₀, h1, h2⟩
      · exact Or.inr h
    constructor
    · intro b
      obtain ⟨a, hstep⟩ := monoInv_step hbot hinv b
      exact ⟨a, atom_agree_of_monoInv hmono hstep (hmem' a b),
        ih ((a, b) :: pairs) (hbot' a b) (n + 1) _ _ (hmem' a b) hstep⟩
    · intro a
      have hbotSwap : (∃ p₀ ∈ pairs.map Prod.swap, (∀ x, p₀.1 ≤ x) ∧ (∀ y, p₀.2 ≤ y)) ∨
          (NoMinOrder N.carrier ∧ NoMinOrder M.carrier) := by
        rcases hbot with ⟨p₀, hp₀, h1, h2⟩ | ⟨h1, h2⟩
        · exact Or.inl ⟨p₀.swap, List.mem_map_of_mem hp₀, h2, h1⟩
        · exact Or.inr ⟨h2, h1⟩
      obtain ⟨b, hstep'⟩ := monoInv_step (M := N) (N := M) hbotSwap (monoInv_swap hinv) a
      have hstep : MonoInv M N d ((a, b) :: pairs) := monoInv_of_swap hstep'
      exact ⟨b, atom_agree_of_monoInv hmono hstep (hmem' a b),
        ih ((a, b) :: pairs) (hbot' a b) (n + 1) _ _ (hmem' a b) hstep⟩

/-! ## The endpoint-profile variants -/

/-- **Monochromatic discrete completeness, no endpoints**: two monochromatic discrete
unbounded structures are `≡ₖ` for every `k` (the `Th(ℤ,<)` completeness family). -/
theorem kEquiv_monoDiscrete_noEnds {sig : MonadicSignature} (k : ℕ)
    (M N : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [Nonempty M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [Nonempty N.carrier]
    (hmono : ∀ p : sig.preds,
      ((∀ x, M.interp p x) ∧ (∀ y, N.interp p y)) ∨
      ((∀ x, ¬ M.interp p x) ∧ (∀ y, ¬ N.interp p y))) :
    KEquiv sig k M N := by
  refine (kEquiv_iff_backForth k M N).mpr ?_
  refine backForth_of_monoInv hmono k [] (Or.inr ⟨inferInstance, inferInstance⟩) 0
    Fin.elim0 Fin.elim0 (fun i => i.elim0) ?_
  intro p hp
  simp at hp

/-- **Monochromatic discrete completeness, min-only** (`ω ≡ⁿ ω + ζ·L` family,
Doets 1.0.3(ii)): monochromatic discrete structures with least elements and no greatest are
`≡ₖ` for every `k`. -/
theorem kEquiv_monoDiscrete_minNoMax {sig : MonadicSignature} (k : ℕ)
    (M N : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    (hMmin : ∃ m : M.carrier, ∀ x, m ≤ x) (hNmin : ∃ m : N.carrier, ∀ y, m ≤ y)
    (hmono : ∀ p : sig.preds,
      ((∀ x, M.interp p x) ∧ (∀ y, N.interp p y)) ∨
      ((∀ x, ¬ M.interp p x) ∧ (∀ y, ¬ N.interp p y))) :
    KEquiv sig k M N := by
  obtain ⟨mM, hmM⟩ := hMmin
  obtain ⟨mN, hmN⟩ := hNmin
  haveI : Nonempty M.carrier := ⟨mM⟩
  haveI : Nonempty N.carrier := ⟨mN⟩
  refine (kEquiv_iff_backForth k M N).mpr ?_
  refine backForth_of_monoInv hmono k [(mM, mN)]
    (Or.inl ⟨(mM, mN), List.mem_cons_self .., hmM, hmN⟩) 0
    Fin.elim0 Fin.elim0 (fun i => i.elim0) ?_
  intro p hp q hq
  rcases List.mem_cons.mp hp with rfl | hp'
  swap
  · simp at hp'
  rcases List.mem_cons.mp hq with rfl | hq'
  swap
  · simp at hq'
  refine ⟨by simp, fun m hm => ?_⟩
  show succ^[m] mM = mM ↔ succ^[m] mN = mN
  rw [succ_iterate_eq_self_iff, succ_iterate_eq_self_iff]

/-! ## Order duality, and the max-only variant -/

/-- The order dual of a monadic structure: same points and predicates, reversed order.

Deliberately `@[reducible]`: the duality-transfer proofs below constantly mix
`(dualStructure M).carrier` with `M.carrierᵒᵈ` inside one application, and only reducible
projection keeps those applications type-correct at the transparency levels `simp` and `rw`
congruence use. -/
@[reducible] def dualStructure {sig : MonadicSignature} (M : OrderedMonadicStructure sig) :
    OrderedMonadicStructure sig where
  carrier := M.carrierᵒᵈ
  interp := fun p x => M.interp p (OrderDual.ofDual x)
  carrierOrder := inferInstance

/--
A `BackForth` strategy between duals is one between the originals, **on the same
environments**: `OrderDual` is a definitional type synonym, so the carriers coincide
definitionally, the dual order is the definitional flip, and atom agreement transfers by
playing the order atoms with their variable pair mirrored. Everything is `exact`-level
definitional unfolding; no environment rewriting occurs.
-/
theorem backForth_of_dualStructure {sig : MonadicSignature} :
    ∀ (d n : ℕ) (M N : OrderedMonadicStructure sig)
      (eM : Fin n → (dualStructure M).carrier) (eN : Fin n → (dualStructure N).carrier),
      BackForth sig d n (dualStructure M) (dualStructure N) eM eN →
      BackForth sig d n M N eM eN := by
  intro d
  induction d with
  | zero => intro _ _ _ _ _ _; trivial
  | succ d ih =>
    intro n M N eM eN h
    obtain ⟨hfwd, hbwd⟩ := h
    constructor
    · intro b
      obtain ⟨a, hat, hbf⟩ := hfwd b
      refine ⟨a, ?_, ih (n + 1) M N (Fin.cons a eM) (Fin.cons b eN) hbf⟩
      intro ak
      cases ak with
      | pred p i => exact hat (.pred p i)
      | order i j hne => exact hat (.order j i (Ne.symm hne))
    · intro a
      obtain ⟨b, hat, hbf⟩ := hbwd a
      refine ⟨b, ?_, ih (n + 1) M N (Fin.cons a eM) (Fin.cons b eN) hbf⟩
      intro ak
      cases ak with
      | pred p i => exact hat (.pred p i)
      | order i j hne => exact hat (.order j i (Ne.symm hne))

/-- `≡ₖ` between duals gives `≡ₖ` between the originals. -/
theorem kEquiv_of_dualStructure {sig : MonadicSignature} {k : ℕ}
    {M N : OrderedMonadicStructure sig}
    (h : KEquiv sig k (dualStructure M) (dualStructure N)) : KEquiv sig k M N := by
  rw [kEquiv_iff_backForth] at h ⊢
  exact backForth_of_dualStructure k 0 M N Fin.elim0 Fin.elim0 h

/-- **Monochromatic discrete completeness, max-only** — the dual of
`kEquiv_monoDiscrete_minNoMax`, obtained by transporting the strategy across
`dualStructure`. -/
theorem kEquiv_monoDiscrete_maxNoMin {sig : MonadicSignature} (k : ℕ)
    (M N : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMinOrder M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMinOrder N.carrier]
    (hMmax : ∃ m : M.carrier, ∀ x, x ≤ m) (hNmax : ∃ m : N.carrier, ∀ y, y ≤ m)
    (hmono : ∀ p : sig.preds,
      ((∀ x, M.interp p x) ∧ (∀ y, N.interp p y)) ∨
      ((∀ x, ¬ M.interp p x) ∧ (∀ y, ¬ N.interp p y))) :
    KEquiv sig k M N := by
  apply kEquiv_of_dualStructure
  haveI : SuccOrder (dualStructure M).carrier := inferInstanceAs (SuccOrder M.carrierᵒᵈ)
  haveI : PredOrder (dualStructure M).carrier := inferInstanceAs (PredOrder M.carrierᵒᵈ)
  haveI : NoMaxOrder (dualStructure M).carrier := inferInstanceAs (NoMaxOrder M.carrierᵒᵈ)
  haveI : SuccOrder (dualStructure N).carrier := inferInstanceAs (SuccOrder N.carrierᵒᵈ)
  haveI : PredOrder (dualStructure N).carrier := inferInstanceAs (PredOrder N.carrierᵒᵈ)
  haveI : NoMaxOrder (dualStructure N).carrier := inferInstanceAs (NoMaxOrder N.carrierᵒᵈ)
  refine kEquiv_monoDiscrete_minNoMax k (dualStructure M) (dualStructure N) ?_ ?_ ?_
  · obtain ⟨m, hm⟩ := hMmax
    exact ⟨OrderDual.toDual m, fun x => hm (OrderDual.ofDual x)⟩
  · obtain ⟨m, hm⟩ := hNmax
    exact ⟨OrderDual.toDual m, fun y => hm (OrderDual.ofDual y)⟩
  · intro p
    rcases hmono p with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨fun x => h1 _, fun y => h2 _⟩
    · exact Or.inr ⟨fun x => h1 _, fun y => h2 _⟩

/-! ## Corollaries at `colourSig` for constant colourings

The Ramsey factorization applies the mixing lemma
(`kEquiv_orderedSum_of_kEquiv_colour`) to index orders whose `k`-type colourings are
*constant* (all segments share one Ramsey type `τ`). These corollaries close exactly those
coloured-order obligations.
-/

section ColourConst

variable {ι : Type}

private theorem mono_const (τ : ι) (I J : Type) [LinearOrder I] [LinearOrder J] :
    ∀ p : (colourSig ι).preds,
      ((∀ x, (colourStructure I fun _ => τ).interp p x) ∧
        (∀ y, (colourStructure J fun _ => τ).interp p y)) ∨
      ((∀ x, ¬ (colourStructure I fun _ => τ).interp p x) ∧
        (∀ y, ¬ (colourStructure J fun _ => τ).interp p y)) := by
  intro z
  by_cases h : τ = z
  · exact Or.inl ⟨fun _ => h, fun _ => h⟩
  · exact Or.inr ⟨fun _ => h, fun _ => h⟩

/-- Constant colourings of discrete unbounded index orders are `≡ₖ`. -/
theorem kEquiv_colourStructure_const (k : ℕ) (τ : ι) (I J : Type)
    [LinearOrder I] [SuccOrder I] [PredOrder I] [NoMaxOrder I] [NoMinOrder I] [Nonempty I]
    [LinearOrder J] [SuccOrder J] [PredOrder J] [NoMaxOrder J] [NoMinOrder J] [Nonempty J] :
    KEquiv (colourSig ι) k (colourStructure I fun _ => τ)
      (colourStructure J fun _ => τ) := by
  haveI : SuccOrder (colourStructure I fun _ => τ).carrier := inferInstanceAs (SuccOrder I)
  haveI : PredOrder (colourStructure I fun _ => τ).carrier := inferInstanceAs (PredOrder I)
  haveI : NoMaxOrder (colourStructure I fun _ => τ).carrier :=
    inferInstanceAs (NoMaxOrder I)
  haveI : NoMinOrder (colourStructure I fun _ => τ).carrier :=
    inferInstanceAs (NoMinOrder I)
  haveI : Nonempty (colourStructure I fun _ => τ).carrier := inferInstanceAs (Nonempty I)
  haveI : SuccOrder (colourStructure J fun _ => τ).carrier := inferInstanceAs (SuccOrder J)
  haveI : PredOrder (colourStructure J fun _ => τ).carrier := inferInstanceAs (PredOrder J)
  haveI : NoMaxOrder (colourStructure J fun _ => τ).carrier :=
    inferInstanceAs (NoMaxOrder J)
  haveI : NoMinOrder (colourStructure J fun _ => τ).carrier :=
    inferInstanceAs (NoMinOrder J)
  haveI : Nonempty (colourStructure J fun _ => τ).carrier := inferInstanceAs (Nonempty J)
  exact kEquiv_monoDiscrete_noEnds k _ _ (mono_const τ I J)

/-- Constant colourings of discrete min-only index orders are `≡ₖ` — `ω ≡ⁿ ω + ℚ ×ₗ ζ` at a
single segment type, the exact index-order obligation of tail absorption. -/
theorem kEquiv_colourStructure_const_min (k : ℕ) (τ : ι) (I J : Type)
    [LinearOrder I] [SuccOrder I] [PredOrder I] [NoMaxOrder I]
    [LinearOrder J] [SuccOrder J] [PredOrder J] [NoMaxOrder J]
    (hI : ∃ m : I, ∀ x, m ≤ x) (hJ : ∃ m : J, ∀ x, m ≤ x) :
    KEquiv (colourSig ι) k (colourStructure I fun _ => τ)
      (colourStructure J fun _ => τ) := by
  haveI : SuccOrder (colourStructure I fun _ => τ).carrier := inferInstanceAs (SuccOrder I)
  haveI : PredOrder (colourStructure I fun _ => τ).carrier := inferInstanceAs (PredOrder I)
  haveI : NoMaxOrder (colourStructure I fun _ => τ).carrier :=
    inferInstanceAs (NoMaxOrder I)
  haveI : SuccOrder (colourStructure J fun _ => τ).carrier := inferInstanceAs (SuccOrder J)
  haveI : PredOrder (colourStructure J fun _ => τ).carrier := inferInstanceAs (PredOrder J)
  haveI : NoMaxOrder (colourStructure J fun _ => τ).carrier :=
    inferInstanceAs (NoMaxOrder J)
  exact kEquiv_monoDiscrete_minNoMax k _ _ hI hJ (mono_const τ I J)

/-- Constant colourings of discrete max-only index orders are `≡ₖ` — the `ω*` dual of
`kEquiv_colourStructure_const_min`. -/
theorem kEquiv_colourStructure_const_max (k : ℕ) (τ : ι) (I J : Type)
    [LinearOrder I] [SuccOrder I] [PredOrder I] [NoMinOrder I]
    [LinearOrder J] [SuccOrder J] [PredOrder J] [NoMinOrder J]
    (hI : ∃ m : I, ∀ x, x ≤ m) (hJ : ∃ m : J, ∀ x, x ≤ m) :
    KEquiv (colourSig ι) k (colourStructure I fun _ => τ)
      (colourStructure J fun _ => τ) := by
  haveI : SuccOrder (colourStructure I fun _ => τ).carrier := inferInstanceAs (SuccOrder I)
  haveI : PredOrder (colourStructure I fun _ => τ).carrier := inferInstanceAs (PredOrder I)
  haveI : NoMinOrder (colourStructure I fun _ => τ).carrier :=
    inferInstanceAs (NoMinOrder I)
  haveI : SuccOrder (colourStructure J fun _ => τ).carrier := inferInstanceAs (SuccOrder J)
  haveI : PredOrder (colourStructure J fun _ => τ).carrier := inferInstanceAs (PredOrder J)
  haveI : NoMinOrder (colourStructure J fun _ => τ).carrier :=
    inferInstanceAs (NoMinOrder J)
  exact kEquiv_monoDiscrete_maxNoMin k _ _ hI hJ (mono_const τ I J)

end ColourConst

end FormalSystem.Metalogic.WeakCanonical

