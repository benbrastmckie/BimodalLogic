/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PartialHistory
import Mathlib.Order.Zorn

/-!
# The extension order on partial histories

This module lands the order-theoretic machinery used *en route to* the Extension Theorem: the
extension preorder, its interaction with time shift, the union of a chain of partial histories,
and Zorn's lemma over that order.

## Paper Specification Reference

The order itself is the paper's, quoted verbatim from `specs/paper-definitions-of-record.md`,
anchor `def:world-history`:

> `A partial history $\sigma$ \textit{extends} $\tau$ just in case
> $\dom{\tau} \subseteq \dom{\sigma}$ and $\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$.`

`PartialHistory.Extends` (in `PartialHistory.lean`) is that relation; the `Preorder` instance
below simply names it `≤`, oriented so that `τ ≤ σ` means "`σ` extends `τ`".

## Status of `exists_maximal_extension` — an internal lemma, not the target

`exists_maximal_extension` is an **internal lemma en route to the Extension Theorem**, demoted
from an earlier round's framing of it as the target existence theorem. The target predicate of
validity is **totality** (`PartialHistory.IsTotal`, `∀ t, τ.domain t`), never Mathlib's `IsMax`
or any order-theoretic maximality predicate. Maximality appears here only as the engine that
Zorn's lemma supplies; the Step Lemma is what converts a maximal partial history into a total
one. See `specs/decisions/total-history-validity-decisions.md`, Decision A.

`isMax_of_total` is the load-bearing direction: *total implies maximal*. Its converse
(*maximal implies total*) is **not** provable from the order alone — it needs the Step Lemma, and
is proved with it.

## Main Definitions

- `Preorder (PartialHistory F)` — the extension order
- `PartialHistory.timeShift` — time shift on partial histories
- `PartialHistory.chainSup` — the union of a nonempty chain of partial histories

## Main Results

- `PartialHistory.timeShift_mono` — the extension order is preserved by time shift
- `PartialHistory.le_timeShift_timeShift_neg` / `timeShift_timeShift_neg_le` — the shift/unshift
  pair, exhibiting `timeShift · Δ` followed by `timeShift · (-Δ)` as order-equivalent to the
  identity
- `PartialHistory.le_chainSup` — every chain member is below the chain union
- `PartialHistory.exists_maximal_extension` — Zorn's lemma over the extension order
- `PartialHistory.isMax_of_total` — a total partial history is maximal

## Implementation Notes

- `chainSup.states` picks a chain member with `Classical.choose`; well-definedness across members
  is exactly `chain_states_agree`, from `IsChain.total` plus the order's agreement clause. This
  "union of a chain of partial functions" step is not available off the shelf in Mathlib.
- `chainSup` takes the chain's nonemptiness as an explicit argument, because
  `PartialHistory.nonempty_domain` is a **field**: the union of the empty chain has empty domain
  and is therefore not a partial history at all. Zorn's `zorn_le_nonempty_Ici₀` supplies exactly
  the needed witness (`∀ y ∈ c`), so this costs nothing at the only call site.
-/

namespace FormalSystem.Semantics

namespace PartialHistory

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] {F : ParamTaskFrame D}

/-! ## The extension order -/

/--
The **extension order**: `τ ≤ σ` iff `σ` extends `τ`.

**Paper Reference**: `def:world-history` (verbatim: "A partial history $\sigma$
\textit{extends} $\tau$ just in case $\dom{\tau} \subseteq \dom{\sigma}$ and
$\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$.").

This is a `Preorder`, not a `PartialOrder`: antisymmetry would require a `PartialHistory`
extensionality principle, and Zorn's lemma needs only a preorder.
-/
instance : Preorder (PartialHistory F) where
  le τ σ := Extends σ τ
  le_refl τ := ⟨fun _ h => h, fun _ _ => rfl⟩
  le_trans _τ _σ _υ h1 h2 :=
    ⟨fun t ht => h2.subset t (h1.subset t ht),
     fun t ht => (h2.agree t (h1.subset t ht)).trans (h1.agree t ht)⟩

theorem le_def {τ σ : PartialHistory F} : τ ≤ σ ↔ Extends σ τ := Iff.rfl

/-- Domain inclusion, extracted from the order. -/
theorem domain_mono {τ σ : PartialHistory F} (h : τ ≤ σ) {t : D} (ht : τ.domain t) :
    σ.domain t :=
  (le_def.mp h).subset t ht

/-! ## Transport of states along equal times -/

/--
States are equal when the times are provably equal (dependent transport).

Needed because `states` is dependent on a domain proof, so `rw`-ing a time equality inside a
`states` application requires an explicit transport lemma.
-/
theorem states_eq_of_time_eq (τ : PartialHistory F) {t₁ t₂ : D} (h : t₁ = t₂)
    (h₁ : τ.domain t₁) (h₂ : τ.domain t₂) : τ.states t₁ h₁ = τ.states t₂ h₂ := by
  subst h; rfl

/-! ## Time shift -/

/--
Time-shifted partial history: `(τ.timeShift Δ)` is `τ` viewed `Δ` later, i.e. its domain at `z`
is `τ`'s domain at `z + Δ`.

Unlike the world-history case there is no convexity obligation, and `nonempty_domain` transports
by `t ↦ t - Δ`.
-/
def timeShift (τ : PartialHistory F) (Δ : D) : PartialHistory F where
  domain := fun z => τ.domain (z + Δ)
  nonempty_domain := by
    obtain ⟨t, ht⟩ := τ.nonempty_domain
    refine ⟨t - Δ, ?_⟩
    rwa [sub_add_cancel]
  states := fun z hz => τ.states (z + Δ) hz
  respects_task := by
    intro s t hs ht
    have h_duration : (t + Δ) - (s + Δ) = t - s := by rw [add_sub_add_right_eq_sub]
    rw [← h_duration]
    exact τ.respects_task (s + Δ) (t + Δ) hs ht

@[simp]
theorem timeShift_domain (τ : PartialHistory F) (Δ z : D) :
    (τ.timeShift Δ).domain z ↔ τ.domain (z + Δ) := Iff.rfl

/-- The extension order is preserved by time shift. -/
theorem timeShift_mono {τ σ : PartialHistory F} (Δ : D) (h : τ ≤ σ) :
    τ.timeShift Δ ≤ σ.timeShift Δ :=
  ⟨fun z hz => (le_def.mp h).subset (z + Δ) hz, fun z hz => (le_def.mp h).agree (z + Δ) hz⟩

/-- Shifting by `Δ` and then by `-Δ` returns to the original time coordinate. -/
theorem timeShift_timeShift_neg_domain_iff (τ : PartialHistory F) (Δ z : D) :
    ((τ.timeShift Δ).timeShift (-Δ)).domain z ↔ τ.domain z := by
  have h : z + -Δ + Δ = z := by rw [add_assoc, neg_add_cancel, add_zero]
  show τ.domain (z + -Δ + Δ) ↔ τ.domain z
  rw [h]

/-- States are unchanged by shifting by `Δ` and then by `-Δ`. -/
theorem timeShift_timeShift_neg_states (τ : PartialHistory F) (Δ z : D)
    (h : ((τ.timeShift Δ).timeShift (-Δ)).domain z) (h' : τ.domain z) :
    ((τ.timeShift Δ).timeShift (-Δ)).states z h = τ.states z h' :=
  states_eq_of_time_eq τ (by rw [add_assoc, neg_add_cancel, add_zero]) h h'

/-- First half of the shift/unshift pair: the double shift extends the original. -/
theorem le_timeShift_timeShift_neg (τ : PartialHistory F) (Δ : D) :
    τ ≤ (τ.timeShift Δ).timeShift (-Δ) :=
  ⟨fun t ht => (timeShift_timeShift_neg_domain_iff τ Δ t).mpr ht,
   fun t ht => timeShift_timeShift_neg_states τ Δ t _ ht⟩

/-- Second half of the shift/unshift pair: the original extends the double shift. -/
theorem timeShift_timeShift_neg_le (τ : PartialHistory F) (Δ : D) :
    (τ.timeShift Δ).timeShift (-Δ) ≤ τ :=
  ⟨fun t ht => (timeShift_timeShift_neg_domain_iff τ Δ t).mp ht,
   fun t ht => (timeShift_timeShift_neg_states τ Δ t ht _).symm⟩

/-! ## Chain unions and Zorn's lemma -/

/-- Any two members of a chain agree on their common domain. -/
theorem chain_states_agree {c : Set (PartialHistory F)} (hc : IsChain (· ≤ ·) c)
    {σ₁ σ₂ : PartialHistory F} (h1 : σ₁ ∈ c) (h2 : σ₂ ∈ c) (t : D)
    (ht1 : σ₁.domain t) (ht2 : σ₂.domain t) :
    σ₁.states t ht1 = σ₂.states t ht2 := by
  rcases hc.total h1 h2 with h | h
  · exact ((le_def.mp h).agree t ht1).symm
  · exact (le_def.mp h).agree t ht2

/--
The union of a **nonempty** chain of partial histories.

Nonemptiness of the chain is required because `nonempty_domain` is a field: the union of the
empty chain has empty domain and is not a partial history. Zorn's `zorn_le_nonempty_Ici₀`
supplies the witness at the only call site.
-/
noncomputable def chainSup (c : Set (PartialHistory F)) (hc : IsChain (· ≤ ·) c)
    (hne : c.Nonempty) : PartialHistory F where
  domain t := ∃ σ ∈ c, σ.domain t
  nonempty_domain := by
    obtain ⟨σ, hσ⟩ := hne
    obtain ⟨t, ht⟩ := σ.nonempty_domain
    exact ⟨t, σ, hσ, ht⟩
  states t ht := (Classical.choose ht).states t (Classical.choose_spec ht).2
  respects_task := by
    intro s t hs ht
    obtain ⟨hs_mem, hs_dom⟩ := Classical.choose_spec hs
    obtain ⟨ht_mem, ht_dom⟩ := Classical.choose_spec ht
    rcases hc.total hs_mem ht_mem with h | h
    · have hs_dom' : (Classical.choose ht).domain s := (le_def.mp h).subset s hs_dom
      have hrel := (Classical.choose ht).respects_task s t hs_dom' ht_dom
      rwa [(le_def.mp h).agree s hs_dom] at hrel
    · have ht_dom' : (Classical.choose hs).domain t := (le_def.mp h).subset t ht_dom
      have hrel := (Classical.choose hs).respects_task s t hs_dom ht_dom'
      rwa [(le_def.mp h).agree t ht_dom] at hrel

/-- Every member of a chain is below the chain union. -/
theorem le_chainSup {c : Set (PartialHistory F)} (hc : IsChain (· ≤ ·) c) (hne : c.Nonempty)
    {σ : PartialHistory F} (hσ : σ ∈ c) : σ ≤ chainSup c hc hne :=
  ⟨fun t ht => ⟨σ, hσ, ht⟩,
   fun _t ht =>
     chain_states_agree hc (Classical.choose_spec (⟨σ, hσ, ht⟩ :
         ∃ σ' ∈ c, σ'.domain _t)).1 hσ _t _ ht⟩

/--
Every partial history extends to a **maximal** one, by Zorn's lemma over the extension order.

**This is an internal lemma en route to the Extension Theorem**, not the target existence
theorem — see the module docstring. Maximality is not the predicate validity quantifies over;
totality is.
-/
theorem exists_maximal_extension (τ : PartialHistory F) : ∃ σ, τ ≤ σ ∧ IsMax σ :=
  zorn_le_nonempty_Ici₀ τ
    (fun c _hsub hchain y hy => ⟨chainSup c hchain ⟨y, hy⟩,
      fun _z hz => le_chainSup hchain ⟨y, hy⟩ hz⟩)
    τ le_rfl

/--
A **total** partial history is maximal under the extension order.

**This is the load-bearing direction** — the converse (maximal implies total) is not provable
from the order alone; it needs the Step Lemma, and is proved with it.
-/
theorem isMax_of_total {τ : PartialHistory F} (h : τ.IsTotal) : IsMax τ :=
  fun _σ hle => ⟨fun t _ => h t, fun t _ => ((le_def.mp hle).agree t (h t)).symm⟩

end PartialHistory

end FormalSystem.Semantics
