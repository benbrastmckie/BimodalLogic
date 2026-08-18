/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Fintype.Pigeonhole
import Mathlib.SetTheory.Cardinal.Finite
import FormalSystem.Semantics.IntNormalForm

/-!
# Periodic Extension over a Finite Carrier

The Extension Theorem says every partial history extends to a possible world, and it gets there
through Zorn's lemma: a maximal element of the extension order, produced non-constructively, with
no description of the world it names. Over ℤ-time with a **finite** carrier that is more than is
needed. A bounded history has two orbits leaving it — one forward, one backward — and a finite
carrier forces each to revisit a state, so the extension can be taken **doubly ultimately
periodic**, with both periods bounded by the number of world states.

That is what this module proves. It **strengthens** the finite discrete case; it does not replace
the general theorem, which stands exactly as it is for arbitrary `W` and `D`, and which this
module neither imports nor mentions in any proof.

## No seriality hypothesis, and that is deliberate

The informal statement of this result says "with a serial relation". No such hypothesis appears
below, because *Seriality* is already a **field** of `TaskFrame`: `TaskFrame.serial` instantiated
at duration `x = 1` yields forward and backward one-step seriality at once, which is exactly what
`exists_iter_fwd` and `exists_iter_bwd` consume. Adding a hypothesis would duplicate a field and
diverge from the frame-intrinsic discipline the extension results are written in. Read the absence
as discharged, not as omitted.

## Relation to the effective, certificate-bearing counterpart

`FormalSystem.Metalogic.Decidability.IntPresentation.extend_periodic` proves a companion result
whose conclusion is a **finite object**: three lists of states plus an integer origin, with
coherence decidable, which a model checker can emit and a consumer re-verify.

These are two theorems, not one, and deliberately so. `Finite` is a non-constructive `Prop`: it
asserts that a bijection with some `Fin n` exists without producing one, so it yields no
enumeration and cannot drive a computation. `IntPresentation` is *data*. No bridge from the first
to the second is written anywhere, because extracting an equivalence to `Fin n` out of a
`Prop`-level existential — together with decidability of a `Prop`-valued relation — is
`Classical.choice` in its most literal role, and would produce a non-computable presentation,
destroying precisely the property the effective version exists to obtain. The theorem below is
proved **directly**, with no presentation appearing anywhere in it.

## Main Results

- `FormalSystem.Semantics.exists_repeat_of_card_le` — pigeonhole on a window of `Nat.card W`
  consecutive times
- `TaskFrame.extend_periodic` — the extension theorem for a finite carrier over ℤ, with both
  periods bounded by `Nat.card`
-/

namespace FormalSystem.Semantics

/-!
## Pigeonhole at the sharp threshold

A window of `Nat.card W + 1` consecutive times — that is, of `Nat.card W` *steps* — already
repeats a state, so the repeat's span is at most `Nat.card W`. This is the threshold the periods
in `TaskFrame.extend_periodic` are bounded by, and it is one tighter than the strict-inequality
form of the same pigeonhole gives, which yields a span of `Nat.card W + 1`. Adjacency plays no
role in either; the statement is about a bare function on ℤ, and saying so keeps it reusable.
-/

/--
**Pigeonhole on a window, at the sharp threshold.** Any `Nat.card W` consecutive steps repeat a
state, so the two occurrences are at most `Nat.card W` apart.
-/
theorem exists_repeat_of_card_le {W : Type} [Finite W] (f : ℤ → W) (c : ℤ) :
    ∃ i j : ℤ, c ≤ i ∧ i < j ∧ j ≤ c + (Nat.card W : ℤ) ∧ f i = f j := by
  classical
  haveI := Fintype.ofFinite W
  have hcW : Fintype.card W = Nat.card W := Nat.card_eq_fintype_card.symm
  have hc : Fintype.card W < Fintype.card (Fin (Nat.card W + 1)) := by
    rw [Fintype.card_fin, hcW]; omega
  obtain ⟨x, y, hxy, hfxy⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun k : Fin (Nat.card W + 1) => f (c + (k : ℕ))) hc
  rcases lt_or_gt_of_ne (fun h : (x : ℕ) = (y : ℕ) => hxy (Fin.ext h)) with hlt | hlt
  · exact ⟨c + (x : ℕ), c + (y : ℕ), by omega, by exact_mod_cast by omega,
      by have := y.isLt; omega, hfxy⟩
  · exact ⟨c + (y : ℕ), c + (x : ℕ), by omega, by exact_mod_cast by omega,
      by have := x.isLt; omega, hfxy.symm⟩

/-- A one-step iterate is a one-step relation. -/
private theorem step_of_iter_one {W : Type} {R : W → W → Prop} {w u : W} (h : iter R 1 w u) :
    R w u := by
  obtain ⟨v, hwv, hvu⟩ := h
  rwa [(iter_zero R w v).mp hwv]

/-- An orbit that repeats at `m < n` is periodic with period `n - m` from index `m` onward. -/
private theorem iterate_periodic {W : Type} (g : W → W) (w : W) {m n : ℕ}
    (h : g^[m] w = g^[n] w) (hmn : m ≤ n) {k : ℕ} (hk : m ≤ k) :
    g^[k + (n - m)] w = g^[k] w := by
  obtain ⟨d, rfl⟩ : ∃ d, k = m + d := ⟨k - m, by omega⟩
  rw [show m + d + (n - m) = d + n by omega, show m + d = d + m by omega,
    Function.iterate_add_apply, Function.iterate_add_apply, h]

namespace TaskFrame

/--
**Periodic extension over a finite carrier.**

A partial history whose domain is exactly the integer interval `[a, b]` extends to a possible
world that is ultimately periodic in *both* directions, with both periods bounded by the number of
world states: some `n₁` past which the world repeats with period `p₁`, and some `n₀` before which
it repeats with period `p₀`.

The construction is the one the informal argument describes. Seriality — taken from
`TaskFrame.serial` at duration `1`, through `exists_iter_fwd` and `exists_iter_bwd` — supplies a
successor and a predecessor at every state. Iterating them out of the two ends of the window gives
two orbits; finiteness forces each to revisit a state (`exists_repeat_of_card_le`), which makes it
periodic from that visit onward; and `TaskFrame.HFofStepPath` turns the resulting bi-infinite walk
into a genuine element of `H_F`, discharging the all-pairs task-respect obligation from adjacency
alone.

No `IntPresentation` appears here, and none can: see this module's docstring on why the effective
counterpart is a separate theorem rather than a corollary.
-/
theorem extend_periodic {F : TaskFrame ℤ} [Finite F.WorldState]
    (τ : PartialHistory F) (a b : ℤ) (hab : a ≤ b)
    (hdom : ∀ t : ℤ, τ.domain t ↔ a ≤ t ∧ t ≤ b) :
    ∃ σ : F.HF, PartialHistory.Extends σ.val.toPartialHistory τ ∧
      ∃ n₀ p₀ n₁ p₁ : ℤ, 0 < p₀ ∧ 0 < p₁ ∧
        p₀ ≤ (Nat.card F.WorldState : ℤ) ∧ p₁ ≤ (Nat.card F.WorldState : ℤ) ∧
        (∀ x : ℤ, n₁ ≤ x → σ.path (x + p₁) = σ.path x) ∧
        (∀ x : ℤ, x ≤ n₀ → σ.path (x - p₀) = σ.path x) := by
  classical
  haveI : Inhabited F.WorldState := Classical.inhabited_of_nonempty F.nonempty
  -- Seriality at duration `1`, in both directions, through the iterate lemmas.
  have hser1 : ∀ w : F.WorldState, ∃ u, F.step w u := by
    intro w
    obtain ⟨u, hu⟩ :=
      exists_iter_fwd (R₁ := F.step) (fun v => (F.serial v 1 (by omega)).1) 1 w
    exact ⟨u, step_of_iter_one hu⟩
  have hser2 : ∀ w : F.WorldState, ∃ v, F.step v w := by
    intro w
    obtain ⟨v, hv⟩ :=
      exists_iter_bwd (R₁ := F.step) (fun u => (F.serial u 1 (by omega)).2) 1 w
    exact ⟨v, step_of_iter_one hv⟩
  set sc : F.WorldState → F.WorldState := fun w => Classical.choose (hser1 w) with hscdef
  set pr : F.WorldState → F.WorldState := fun w => Classical.choose (hser2 w) with hprdef
  have hsc : ∀ w, F.step w (sc w) := fun w => Classical.choose_spec (hser1 w)
  have hpr : ∀ w, F.step (pr w) w := fun w => Classical.choose_spec (hser2 w)
  -- The states of `τ`, extended by an irrelevant default off its domain.
  set g : ℤ → F.WorldState := fun t => if h : τ.domain t then τ.states t h else default with hg
  -- The extended path: the window in the middle, the two orbits outside it.
  set f : ℤ → F.WorldState := fun t =>
    if t < a then pr^[(a - t).toNat] (g a)
    else if t ≤ b then g t
    else sc^[(t - b).toNat] (g b) with hfdef
  have hfa : f a = g a := by
    simp only [hfdef]
    rw [if_neg (by omega), if_pos hab]
  have hfb : f b = g b := by
    simp only [hfdef]
    rw [if_neg (by omega), if_pos (le_refl b)]
  have hflt : ∀ t : ℤ, t < a → f t = pr^[(a - t).toNat] (g a) := by
    intro t ht
    simp only [hfdef]
    rw [if_pos ht]
  have hfgt : ∀ t : ℤ, b < t → f t = sc^[(t - b).toNat] (g b) := by
    intro t ht
    simp only [hfdef]
    rw [if_neg (by omega), if_neg (by omega)]
  have hfmid : ∀ t : ℤ, a ≤ t → t ≤ b → f t = g t := by
    intro t h1 h2
    simp only [hfdef]
    rw [if_neg (by omega), if_pos h2]
  -- `f` is a bi-infinite step path: two orbits, two seams, and the window itself.
  have hstep : IsStepPath F f := by
    intro t
    rcases lt_or_ge t (a - 1) with h1 | h1
    · -- Within the backward orbit.
      rw [hflt t (by omega), hflt (t + 1) (by omega),
        show (a - t).toNat = (a - (t + 1)).toNat + 1 by omega,
        Function.iterate_succ_apply']
      exact hpr _
    rcases eq_or_lt_of_le h1 with h2 | h2
    · -- The backward-to-window seam.
      rw [hflt t (by omega), show (a - t).toNat = 1 by omega,
        show t + 1 = a by omega, hfa]
      simpa using hpr (g a)
    rcases lt_or_ge t b with h3 | h3
    · -- Within the window.
      have hta : a ≤ t := by omega
      have ht1 : τ.domain (t + 1) := (hdom (t + 1)).mpr ⟨by omega, by omega⟩
      have ht0 : τ.domain t := (hdom t).mpr ⟨by omega, by omega⟩
      rw [hfmid t hta (by omega), hfmid (t + 1) (by omega) (by omega)]
      have hrel := τ.respects_task t (t + 1) ht0 ht1
      rw [show t + 1 - t = (1 : ℤ) by omega] at hrel
      have e0 : g t = τ.states t ht0 := by rw [hg]; exact dif_pos ht0
      have e1 : g (t + 1) = τ.states (t + 1) ht1 := by rw [hg]; exact dif_pos ht1
      rw [e0, e1]
      exact (F.taskRel_one_iff_step _ _).mp hrel
    rcases eq_or_lt_of_le h3 with h4 | h4
    · -- The window-to-forward seam.
      rw [← h4, hfb, hfgt (b + 1) (by omega), show (b + 1 - b).toNat = 1 by omega]
      simpa using hsc (g b)
    · -- Within the forward orbit.
      rw [hfgt t (by omega), hfgt (t + 1) (by omega),
        show (t + 1 - b).toNat = (t - b).toNat + 1 by omega,
        Function.iterate_succ_apply']
      exact hsc _
  refine ⟨HFofStepPath F f hstep, ⟨fun _ _ => trivial, ?_⟩, ?_⟩
  · -- Agreement on the window is extension.
    intro t ht
    obtain ⟨h1, h2⟩ := (hdom t).mp ht
    show f t = τ.states t ht
    rw [hfmid t h1 h2, hg]
    exact dif_pos ht
  -- Both periodicities, from a revisit in each orbit.
  obtain ⟨i₁, j₁, hi₁, hij₁, hj₁, heq₁⟩ :=
    exists_repeat_of_card_le (fun k : ℤ => sc^[k.toNat] (g b)) 0
  obtain ⟨i₀, j₀, hi₀, hij₀, hj₀, heq₀⟩ :=
    exists_repeat_of_card_le (fun k : ℤ => pr^[k.toNat] (g a)) 0
  refine ⟨a - i₀ - 1, j₀ - i₀, b + i₁ + 1, j₁ - i₁, by omega, by omega, by omega, by omega,
    ?_, ?_⟩
  · -- Forward: past `b + i₁ + 1` the path repeats with period `j₁ - i₁`.
    intro x hx
    show f (x + (j₁ - i₁)) = f x
    rw [hfgt _ (by omega), hfgt _ (by omega),
      show (x + (j₁ - i₁) - b).toNat = (x - b).toNat + (j₁.toNat - i₁.toNat) by omega]
    exact iterate_periodic sc (g b) heq₁ (by omega) (by omega)
  · -- Backward: before `a - i₀ - 1` the path repeats with period `j₀ - i₀`.
    intro x hx
    show f (x - (j₀ - i₀)) = f x
    rw [hflt _ (by omega), hflt _ (by omega),
      show (a - (x - (j₀ - i₀))).toNat = (a - x).toNat + (j₀.toNat - i₀.toNat) by omega]
    exact iterate_periodic pr (g a) heq₀ (by omega) (by omega)

end TaskFrame

end FormalSystem.Semantics
