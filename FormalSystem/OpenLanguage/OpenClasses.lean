/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.PlusPasting

/-!
# The three restricted history classes: `⟨τ⟩_x`, `|τ⟩_x` and `⟨τ|_x`

The manuscript's subsection *Restricted Modalities* (`sub:RestrictedModalities`) restricts the set
`H_F` of possible worlds in three ways, relative to a world `τ` and a time `x`:

```
⟨τ⟩_x := {σ ∈ H_F | σ(x) = τ(x)}                     the worlds that intersect τ at x
|τ⟩_x := {σ ∈ H_F | σ(y) = τ(y) for all y ≤ x}       "Open Futures"
⟨τ|_x := {σ ∈ H_F | σ(y) = τ(y) for all y ≥ x}       "Open Pasts"
```

This module states the three classes as sets of world histories over the live `WorldHistory` /
`TaskFrame` and proves what the manuscript asserts of them: each is an equivalence class of an
explicit relation, `|τ⟩_x ⊆ ⟨τ⟩_x` and `⟨τ|_x ⊆ ⟨τ⟩_x` with `|τ⟩_x ∩ ⟨τ|_x = {τ}`, and
`|τ⟩_y ⊆ |τ⟩_x`, `⟨τ|_x ⊆ ⟨τ|_y` for `x ≤ y` — "moving forward in time narrows the open futures
and widens the open pasts".

The two agreement relations are **not redefined**: they are `AgreeUpTo` and `AgreeFrom` of
`PlusLanguage/PlusPasting.lean`, where they already serve the purity congruences of the pasting
validities. The type `WorldHistory F` *is* the manuscript's `H_F` (`def:world-history`), which is
why `stabClass_subset_univ` is the form the inclusion `⟨τ⟩_x ⊆ H_F` takes here.

## Main Definitions

- `stabClass τ x` (`⟨τ⟩_x`), `openFutureClass τ x` (`|τ⟩_x`), `openPastClass τ x` (`⟨τ|_x`)

## Main Results

- `sameState_equivalence`, `agreeUpTo_equivalence`, `agreeFrom_equivalence` — each class is the
  equivalence class of `τ` under an explicit equivalence relation on `H_F`
- `openFutureClass_subset_stabClass`, `openPastClass_subset_stabClass`, `stabClass_subset_univ`
- `openFutureClass_inter_openPastClass` — `|τ⟩_x ∩ ⟨τ|_x = {τ}`
- `openFutureClass_anti`, `openPastClass_mono` — the monotonicity sentence
- `paste_mem_openFutureClass_inter_openPastClass` — a world through a shared state whose past is
  one world's and whose future is another's: the two-history instance of `app:gluing`, which is
  why `⟨τ⟩_x` is the *product* of the open pasts and the open futures at `x`

## References

* JPL paper `sub:RestrictedModalities` — the items *Open Futures* and *Open Pasts*, and the
  sentence beginning "the construction of possible worlds makes `⟨τ⟩_x`, `|τ⟩_x`, and `⟨τ|_x`
  definable"
* JPL paper `def:BLstar-semantics` — `⟨τ⟩_x`
* JPL paper `def:world-history` — `H_F`
* JPL paper `app:gluing` — gluing two histories that agree on their overlap
* `FormalSystem/PlusLanguage/PlusPasting.lean` — `AgreeUpTo`, `AgreeFrom`, `paste`

## Tags

open-language · open-future · open-past · stability-modal
-/

namespace FormalSystem.OpenLanguage

open FormalSystem.Semantics
open FormalSystem.PlusLanguage

variable {F : TaskFrame}

/-! ## The three classes -/

/-- `⟨τ⟩_x`: the possible worlds that occupy `τ`'s world state at `x`. The class the stability
modal `⊡` quantifies over (`def:BLstar-semantics`). -/
def stabClass (τ : WorldHistory F) (x : F.Duration) : Set (WorldHistory F) :=
  {σ | τ.state x = σ.state x}

/-- `|τ⟩_x`, the manuscript's *Open Futures*: the possible worlds that occupy the same world
state as `τ` "at each time up to and including `x` while possibly diverging at later times". -/
def openFutureClass (τ : WorldHistory F) (x : F.Duration) : Set (WorldHistory F) :=
  {σ | AgreeUpTo τ σ x}

/-- `⟨τ|_x`, the manuscript's *Open Pasts*: the possible worlds that occupy the same world states
as `τ` "at `x` and all later times while possibly diverging at earlier times". -/
def openPastClass (τ : WorldHistory F) (x : F.Duration) : Set (WorldHistory F) :=
  {σ | AgreeFrom τ σ x}

theorem mem_stabClass_iff {τ σ : WorldHistory F} {x : F.Duration} :
    σ ∈ stabClass τ x ↔ τ.state x = σ.state x := Iff.rfl

theorem mem_openFutureClass_iff {τ σ : WorldHistory F} {x : F.Duration} :
    σ ∈ openFutureClass τ x ↔ AgreeUpTo τ σ x := Iff.rfl

theorem mem_openPastClass_iff {τ σ : WorldHistory F} {x : F.Duration} :
    σ ∈ openPastClass τ x ↔ AgreeFrom τ σ x := Iff.rfl

/-! ## Each class is an equivalence class of an explicit relation -/

/-- `σ ∼_x τ := σ(x) = τ(x)` is an equivalence relation on `H_F`; `⟨τ⟩_x` is `τ`'s class. -/
theorem sameState_equivalence (x : F.Duration) :
    Equivalence (fun τ σ : WorldHistory F => τ.state x = σ.state x) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- Agreement at every time `≤ x` is an equivalence relation on `H_F`; `|τ⟩_x` is `τ`'s class. -/
theorem agreeUpTo_equivalence (x : F.Duration) :
    Equivalence (fun τ σ : WorldHistory F => AgreeUpTo τ σ x) :=
  ⟨fun _ _ _ => rfl, fun h s hs => (h s hs).symm, fun h₁ h₂ s hs => (h₁ s hs).trans (h₂ s hs)⟩

/-- Agreement at every time `≥ x` is an equivalence relation on `H_F`; `⟨τ|_x` is `τ`'s class. -/
theorem agreeFrom_equivalence (x : F.Duration) :
    Equivalence (fun τ σ : WorldHistory F => AgreeFrom τ σ x) :=
  ⟨fun _ _ _ => rfl, fun h s hs => (h s hs).symm, fun h₁ h₂ s hs => (h₁ s hs).trans (h₂ s hs)⟩

/-! ## The inclusions -/

/-- `|τ⟩_x ⊆ ⟨τ⟩_x`: agreement up to and including `x` is, in particular, agreement at `x`. -/
theorem openFutureClass_subset_stabClass (τ : WorldHistory F) (x : F.Duration) :
    openFutureClass τ x ⊆ stabClass τ x :=
  fun _ hag => hag x le_rfl

/-- `⟨τ|_x ⊆ ⟨τ⟩_x`: agreement from `x` onward is, in particular, agreement at `x`. -/
theorem openPastClass_subset_stabClass (τ : WorldHistory F) (x : F.Duration) :
    openPastClass τ x ⊆ stabClass τ x :=
  fun _ hag => hag x le_rfl

/-- `⟨τ⟩_x ⊆ H_F`. The type `WorldHistory F` is the manuscript's `H_F`, so the inclusion is into
the universal set. -/
theorem stabClass_subset_univ (τ : WorldHistory F) (x : F.Duration) :
    stabClass τ x ⊆ Set.univ :=
  Set.subset_univ _

/-- `|τ⟩_x ∩ ⟨τ|_x = {τ}`: a world that agrees with `τ` on both sides of `x` is `τ`. -/
theorem openFutureClass_inter_openPastClass (τ : WorldHistory F) (x : F.Duration) :
    openFutureClass τ x ∩ openPastClass τ x = {τ} := by
  ext σ
  constructor
  · rintro ⟨hup, hfrom⟩
    refine (WorldHistory.ext_state fun s => ?_).symm
    rcases le_total s x with h | h
    · exact hup s h
    · exact hfrom s h
  · rintro rfl
    exact ⟨fun _ _ => rfl, fun _ _ => rfl⟩

/-! ## Monotonicity in the time -/

/-- `|τ⟩_y ⊆ |τ⟩_x` for `x ≤ y`: moving forward in time narrows the open futures. -/
theorem openFutureClass_anti (τ : WorldHistory F) {x y : F.Duration} (h : x ≤ y) :
    openFutureClass τ y ⊆ openFutureClass τ x :=
  fun _ hag => agreeUpTo_mono h hag

/-- `⟨τ|_x ⊆ ⟨τ|_y` for `x ≤ y`: moving forward in time widens the open pasts. -/
theorem openPastClass_mono (τ : WorldHistory F) {x y : F.Duration} (h : x ≤ y) :
    openPastClass τ x ⊆ openPastClass τ y :=
  fun _ hag => agreeFrom_mono h hag

/-! ## `⟨τ⟩_x` is the product of the open pasts and the open futures -/

/-- For `σ ∈ ⟨τ⟩_x`, the pasted world `τ|(-∞,x] ⌢ σ|(x,∞)` lies in `τ`'s open-future class and in
`σ`'s open-past class at `x`: the two-history instance of `app:gluing`. -/
theorem paste_mem_openFutureClass_inter_openPastClass [F.IsRegular]
    (τ σ : WorldHistory F) (x : F.Duration)
    (h : τ.state x = σ.state x) :
    paste τ σ x h ∈ openFutureClass τ x ∩ openPastClass σ x :=
  ⟨fun s hs => (paste_agreeUpTo τ σ x h s hs).symm,
    fun s hs => (paste_agreeFrom τ σ x h s hs).symm⟩

end FormalSystem.OpenLanguage
