/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Nat.Find
import Mathlib.Order.SuccPred.Basic
import Mathlib.Order.SuccPred.Archimedean

/-!
# The order cores of the discrete-frame soundness lemmas

The four discrete-order validity proofs in `FrameClassVariants.lean` — `prior_UZ_valid`,
`prior_SZ_valid`, `z1_valid`, `z1_past_valid` — are two arguments, each written out twice: once
forwards over `Order.succ` and once backwards over `Order.pred`. Both arguments are about the
*order* alone. Neither needs `Formula`, `TruthAt`, or `TaskModel`, and this module deliberately
mentions none of them: its whole content is two theorems over an abstract predicate
`P : D → Prop`, plus their order duals.

## The two cores

- `exists_nearest_gt` — the `Nat.find` descent. If `P` holds somewhere strictly above `t`, then
  it holds at a *nearest* such point: some `u > t` with `P u` and no `P` strictly between.
  Instantiating `P := fun x => TruthAt M τ x φ` is exactly Prior-UZ's `Until` witness.
- `forall_gt_of_succ_step` — the backward induction. If `P` propagates down one `succ`-step from
  above (`hstep`) and holds everywhere above some `s₀ > t`, then it holds everywhere above `t`.
  Instantiating the same way is exactly Z1.

## The duals are instantiations, not mirrors

`exists_nearest_lt` and `forall_lt_of_pred_step` are obtained by instantiating their forward
twins at `Dᵒᵈ`, not by re-running the argument with `pred` for `succ`. Mathlib supplies the
dualisation instances — `PredOrder α → SuccOrder αᵒᵈ` (`Mathlib/Order/SuccPred/Basic.lean`) and
`IsPredArchimedean α → IsSuccArchimedean αᵒᵈ` (`Mathlib/Order/SuccPred/Archimedean.lean`) — and
the two cores' *statements* mention only `<` and `P`, never `succ`, so the dual statement is the
forward one read in `Dᵒᵈ` with nothing to transport. `Separability.lean`'s
`sep_order` / `sep_order_mirror` pair is the precedent this follows.

**The dualisation is of the carrier `D`, never of `Formula`.** A single-frame
`F.ValidOn φ → F.ValidOn φ.swapTemporal` closure lemma does not exist and is false in general;
`Metalogic/Independence/LexIntWitness.lean` records that. Nothing here dualises a formula.
-/

namespace FormalSystem.Metalogic.SoundnessLemmas

variable {D : Type*} [LinearOrder D] {P : D → Prop} {t : D}

/-! ## Core 1 — the nearest witness above -/

/--
**A witness strictly above `t` has a nearest witness strictly above `t`.**

Discreteness is what makes "nearest" available: `IsSuccArchimedean` presents every point above
`t` as `Order.succ^[k + 1] t`, which turns the search into a `Nat.find` over `k` and hands back
both the witness and its minimality. Over a dense order there is no nearest witness and the
statement is false, which is why Prior-UZ is a discrete-only axiom.
-/
theorem exists_nearest_gt [SuccOrder D] [IsSuccArchimedean D] {s : D} (hts : t < s) (hs : P s) :
    ∃ u, t < u ∧ P u ∧ ∀ r, t < r → r < u → ¬ P r := by
  obtain ⟨n, hn⟩ := (Order.succ_le_of_lt hts).exists_succ_iterate
  have hn1 : Order.succ^[n + 1] t = s := by
    simp only [Function.iterate_succ, Function.comp_apply]; exact hn
  classical
  have h_ex : ∃ k, P (Order.succ^[k + 1] t) := ⟨n, hn1 ▸ hs⟩
  have hk₀ : P (Order.succ^[Nat.find h_ex + 1] t) := Nat.find_spec h_ex
  have hk₀_min : ∀ m < Nat.find h_ex, ¬ P (Order.succ^[m + 1] t) :=
    fun m hm => Nat.find_min h_ex hm
  have h_iter_mono : Monotone (fun i => Order.succ^[i] t) :=
    Order.succ_mono.monotone_iterate_of_le_map (Order.le_succ t)
  have h_not_max : ¬IsMax t := hts.not_isMax
  refine ⟨Order.succ^[Nat.find h_ex + 1] t, ?_, hk₀, ?_⟩
  · have h1 := h_iter_mono (Nat.one_le_iff_ne_zero.mpr (Nat.succ_ne_zero (Nat.find h_ex)))
    simp only at h1
    exact lt_of_lt_of_le (Order.lt_succ_of_not_isMax h_not_max) h1
  · intro r htr hrs
    obtain ⟨j, hj⟩ := (Order.succ_le_of_lt htr).exists_succ_iterate
    have hj1 : Order.succ^[j + 1] t = r := by
      simp only [Function.iterate_succ, Function.comp_apply]; exact hj
    have hj_lt : j < Nat.find h_ex := by
      by_contra h_ge
      push Not at h_ge
      have h_le := h_iter_mono (show Nat.find h_ex + 1 ≤ j + 1 by omega)
      simp only at h_le
      rw [hj1] at h_le
      exact absurd hrs (not_lt.mpr h_le)
    rw [← hj1]
    exact hk₀_min j hj_lt

/--
**The order dual of `exists_nearest_gt`**, obtained by instantiating it at `Dᵒᵈ` rather than by
re-running the `Nat.find` descent over `Order.pred`. Only the two side conditions on `r` change
places, since `Dᵒᵈ`'s `<` reverses them.
-/
theorem exists_nearest_lt [PredOrder D] [IsPredArchimedean D] {s : D} (hst : s < t) (hs : P s) :
    ∃ u, u < t ∧ P u ∧ ∀ r, u < r → r < t → ¬ P r := by
  obtain ⟨u, hu, hPu, hmin⟩ :=
    exists_nearest_gt (D := Dᵒᵈ) (P := fun x => P (OrderDual.ofDual x))
      (t := OrderDual.toDual t) (s := OrderDual.toDual s) hst hs
  exact ⟨OrderDual.ofDual u, hu, hPu, fun r h₁ h₂ => hmin (OrderDual.toDual r) h₂ h₁⟩

/-! ## Core 2 — backward induction from a witness above -/

/--
**Backward induction along the `succ` chain.**

`hstep` says `P` holds at any `u > t` whose entire strict future satisfies `P`; `hs₀` says the
strict future of some `s₀ > t` already does. Discreteness closes the gap: `IsSuccArchimedean`
indexes the points of `(t, s₀]` by `k ↦ Order.succ^[k + 1] t` with `k ≤ n₀`, and strong induction
on the *remaining distance* `n₀ - k` walks `P` down from `s₀` to every point above `t`.

This is Z1's whole content. Over a dense order the indexing fails and Z1 is not valid.
-/
theorem forall_gt_of_succ_step [SuccOrder D] [IsSuccArchimedean D] {s₀ : D}
    (hstep : ∀ u, t < u → (∀ r, u < r → P r) → P u)
    (hts₀ : t < s₀) (hs₀ : ∀ r, s₀ < r → P r) :
    ∀ s, t < s → P s := by
  obtain ⟨n₀, hn₀⟩ := (Order.succ_le_of_lt hts₀).exists_succ_iterate
  have hn₀_eq : Order.succ^[n₀ + 1] t = s₀ := by
    change Order.succ^[n₀] (Order.succ t) = s₀; exact hn₀
  have h_iter_mono : Monotone (fun i => Order.succ^[i] t) :=
    Order.succ_mono.monotone_iterate_of_le_map (Order.le_succ t)
  have h_not_max : ¬IsMax t := hts₀.not_isMax
  have h_above_s0 : ∀ s, s₀ ≤ s → P s := by
    intro s hs
    rcases eq_or_lt_of_le hs with rfl | hlt
    · exact hstep s₀ hts₀ hs₀
    · exact hs₀ s hlt
  have h_all_iterates : ∀ k, P (Order.succ^[k + 1] t) := by
    suffices h_le : ∀ k, k ≤ n₀ → P (Order.succ^[k + 1] t) by
      intro k
      by_cases hk : k ≤ n₀
      · exact h_le k hk
      · exact h_above_s0 _ (hn₀_eq ▸ h_iter_mono (by omega : n₀ + 1 ≤ k + 1))
    have key : ∀ d, d ≤ n₀ → ∀ k, n₀ - k = d → k ≤ n₀ → P (Order.succ^[k + 1] t) := by
      intro d
      induction d using Nat.strong_induction_on with
      | _ d ih =>
        intro hd k hk hkn
        apply hstep
        · exact lt_of_lt_of_le (Order.lt_succ_of_not_isMax h_not_max)
            (h_iter_mono (by omega : 1 ≤ k + 1))
        · intro r hr
          obtain ⟨j, hj⟩ := (Order.succ_le_of_lt hr).exists_succ_iterate
          have hj_eq : Order.succ^[j + 1] (Order.succ^[k + 1] t) = r := by
            change Order.succ^[j] (Order.succ (Order.succ^[k + 1] t)) = r; exact hj
          rw [← hj_eq, ← Function.iterate_add_apply,
              show j + 1 + (k + 1) = (k + j + 1) + 1 from by omega]
          by_cases h_le : k + j + 1 ≤ n₀
          · exact ih (n₀ - (k + j + 1)) (by omega) (by omega) (k + j + 1) rfl h_le
          · exact h_above_s0 _ (hn₀_eq ▸ h_iter_mono (by omega : n₀ + 1 ≤ (k + j + 1) + 1))
    intro k hk
    exact key (n₀ - k) (by omega) k rfl hk
  intro s hts
  obtain ⟨m, hm⟩ := (Order.succ_le_of_lt hts).exists_succ_iterate
  have hm_eq : Order.succ^[m] (Order.succ t) = s := hm
  exact (show Order.succ^[m + 1] t = s from hm_eq) ▸ h_all_iterates m

/--
**The order dual of `forall_gt_of_succ_step`**, obtained by instantiating it at `Dᵒᵈ` rather
than by re-running the strong induction over `Order.pred`. This is Z1's past dual.
-/
theorem forall_lt_of_pred_step [PredOrder D] [IsPredArchimedean D] {s₀ : D}
    (hstep : ∀ u, u < t → (∀ r, r < u → P r) → P u)
    (hs₀t : s₀ < t) (hs₀ : ∀ r, r < s₀ → P r) :
    ∀ s, s < t → P s :=
  fun s hst =>
    forall_gt_of_succ_step (D := Dᵒᵈ) (P := fun x => P (OrderDual.ofDual x))
      (t := OrderDual.toDual t) (s₀ := OrderDual.toDual s₀)
      (fun u hu hfut => hstep (OrderDual.ofDual u) hu
        (fun r hr => hfut (OrderDual.toDual r) hr))
      hs₀t (fun r hr => hs₀ (OrderDual.ofDual r) hr) (OrderDual.toDual s) hst

end FormalSystem.Metalogic.SoundnessLemmas
