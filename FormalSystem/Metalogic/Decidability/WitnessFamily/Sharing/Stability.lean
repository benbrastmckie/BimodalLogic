/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Agreement
import FormalSystem.Semantics.HistoryMorphism

/-!
# The Stability Quantifier at the Branching Frame

## The agreement lemma over all walks is already here

The agreement (truth) lemma over **all** world histories of `SharingWitnessFamily.frame` — the
box case included — is `SharingWitnessFamily.truth_iff_mem` in
`WitnessFamily/Sharing/Agreement.lean`. Nothing in this module re-proves it; it is consumed.
The box case is not the obstruction the branching device leaves open, and this module does not
re-import that framing. What the branching device leaves open is the **stability** modal `⊡`,
and that is what is settled below.

## The collapse

`⊡ψ` is true at `(σ, t)` when `ψ` holds at time `t` on every world history agreeing with `σ` on
the world **state** at `t`. The clause never inspects the formula, so its *quantifier shape* is
expressible at `Formula` even though the modal itself lives at `PlusFormula`; `StabQuant` is that
shape.

`stabQuant_iff_share_class` shows the quantifier does **not** range over walks on this frame. It
collapses to a finite quantifier over the `share`-class of the present index, with the right-hand
side ranging over `Fin S.lassos.length`. The two directions consume exactly the lemmas the box
case already consumes: `Thread.const` and `cls_eq` forward, `total_eq_thread` and
`share_of_cls_eq` back, with `truth_iff_mem` reading truth against membership in both.

`stabQuant_iff_self_of_share_eq` pins the branching device as the minimal extension at which this
stops being trivial: when `share u` is equality the class is a singleton and the collapse reads
`⊡ψ ↔ ψ`, matching `PlusLanguage.stab_iff_of_deterministic` on the deterministic device.

## The condition this hands downstream

The stability-faithfulness condition a certificate for the larger language needs is

```
stab φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u
```

`stabQuant_iff_share_class` is its soundness argument. It is **decidable for free**: the
statement reads only `rep u` and `L · u`, the same per-time datum `AtomCoherentAt` reads, so
`WitnessFamily/Sharing/Decide.lean`'s one-time window reduction (`atomCoherentAt_congr`,
`atomCoherent_iff_window`, with `Formula.atom p` replaced by `stab φ`) decides it verbatim. There
is no analogue here of the relative-decidability gap that governs the other conditions.

## Recurrence-freedom costs nothing

`frame_recurrenceFree` records that no world history of this frame visits a world state twice.
That is what makes the collapse a quantifier over **one** time: `share_of_cls_eq` forces two equal
classes to sit at the same time, so "every history through the present state" cannot drag in
another time. It is also not a restriction on refuting power:
`FormalSystem.Semantics.plusValidIn_iff_recurrenceFree` says validity of the larger language over
a frame class equals validity over that class's recurrence-free members, so whatever a
recurrence-free witness frame cannot refute, no frame refutes.

## The completeness-side failure mode does not transfer

On the completeness side the hazard is a trace that postpones an inevitability forever, cured by
limit-closure schemata in the logic together with progress measures carried in the state. That
hazard is about **deriving** fulfilment. Here fulfilment is an assumed and checked hypothesis —
`ThreadFulfilling`, decided by `WitnessFamily/Sharing/Fulfil.lean`'s least fixpoint. The
certificate side's counterpart to a limit-closure schema is that decided fixpoint, already
landed; no limit-closure schema is adopted or needed in this module.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace SharingWitnessFamily

variable {Γ Del : Context}

/-! ## The quantifier shape -/

/--
**The stability quantifier, at the branching frame, over a closure formula.**

`StabQuant S hat σ t ψ` is the semantic content of `⊡ψ` at `(σ, t)`: truth of `ψ` at every
world history agreeing with `σ` on the world state at time `t`. This is `PlusTruthAt`'s `stab`
clause with `PlusFormula` replaced by `Formula`, which is legitimate because the clause never
inspects the formula.
-/
def StabQuant (S : SharingWitnessFamily Γ Del) (hat : S.AtomCoherent)
    (σ : WorldHistory S.frame.toTaskFrame) (t : ℤ) (ψ : Formula) : Prop :=
  ∀ ρ : WorldHistory S.frame.toTaskFrame, σ.state t = ρ.state t →
    TruthAt (S.model hat) ρ t ψ

/-! ## The collapse -/

/--
**The collapse.**

At a thread's trace, the stability quantifier over a closure formula is exactly the finite
conjunction of label membership over the `share`-class of the thread's index at that time.

* `→` instantiates the history quantifier at the CONSTANT thread at each class member, which is
  a history by `Thread.const` + `hist`, and reads truth back as membership by `truth_iff_mem`.
* `←` decomposes an arbitrary history by `total_eq_thread`, extracts `share` from the state
  equality by `share_of_cls_eq`, and reads membership forward as truth by `truth_iff_mem`.

No quantifier over walks survives: the right-hand side ranges over `Fin S.lassos.length`.
-/
theorem stabQuant_iff_share_class (S : SharingWitnessFamily Γ Del)
    (hat : S.AtomCoherent) (hloc : S.LocalCoherentShare) (hful : S.ThreadFulfilling)
    (hbox : S.toWitnessFamily.BoxFaithful)
    (ψ : Formula) (hψ : ψ ∈ closureOf (Γ ++ Del)) (θ : S.Thread) (s t : ℤ) :
    StabQuant S hat (S.hist θ s) t ψ ↔
      ∀ j : Fin S.lassos.length, S.share (s + t) (θ.idx (s + t)) j → ψ ∈ S.L j (s + t) := by
  constructor
  · intro h j hj
    have hst : (S.hist θ s).state t = (S.hist (Thread.const S j) s).state t := by
      show S.cls (θ.idx (s + t)) (s + t) = S.cls ((Thread.const S j).idx (s + t)) (s + t)
      rw [Thread.const_idx]
      exact cls_eq rfl hj
    have := h _ hst
    have hT := (truth_iff_mem S hat hloc hful hbox ψ hψ (Thread.const S j) s t).mp this
    rwa [Thread.const_idx] at hT
  · intro h ρ hρ
    obtain ⟨θ', s', hθ'⟩ := S.total_eq_thread ρ
    have heq : ρ = S.hist θ' s' := WorldHistory.ext_state (fun r => by rw [hθ' r]; rfl)
    subst heq
    have hstate : S.cls (θ.idx (s + t)) (s + t) = S.cls (θ'.idx (s' + t)) (s' + t) := hρ
    obtain ⟨htime, hshare⟩ := share_of_cls_eq hstate
    refine (truth_iff_mem S hat hloc hful hbox ψ hψ θ' s' t).mpr ?_
    have hmem := h _ hshare
    -- `subst` on `s' = s` eliminates the wrong variable here; rewrite the sum instead.
    rwa [show s + t = s' + t from by omega] at hmem

/--
**The deterministic cross-check.** When `share u` is equality the class is a singleton, so the
collapse reads `⊡ψ ↔ ψ`, matching `PlusLanguage.stab_iff_of_deterministic`.
-/
theorem stabQuant_iff_self_of_share_eq (S : SharingWitnessFamily Γ Del)
    (hat : S.AtomCoherent) (hloc : S.LocalCoherentShare) (hful : S.ThreadFulfilling)
    (hbox : S.toWitnessFamily.BoxFaithful)
    (hdiag : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.share u i j → i = j)
    (ψ : Formula) (hψ : ψ ∈ closureOf (Γ ++ Del)) (θ : S.Thread) (s t : ℤ) :
    StabQuant S hat (S.hist θ s) t ψ ↔ ψ ∈ S.L (θ.idx (s + t)) (s + t) := by
  rw [stabQuant_iff_share_class S hat hloc hful hbox ψ hψ θ s t]
  constructor
  · intro h; exact h _ (S.share_refl (s + t) _)
  · intro h j hj; rwa [← hdiag (s + t) _ _ hj]

/-! ## Recurrence-freedom -/

/--
**The branching frame is recurrence-free.**

Immediate from `total_eq_thread` and `share_of_cls_eq`: a history is a thread's trace, whose
state at `t` is the class of a pair whose time coordinate is `s + t`, and two equal classes have
equal time coordinates.
-/
theorem frame_recurrenceFree (S : SharingWitnessFamily Γ Del) :
    S.frame.toTaskFrame.RecurrenceFree := by
  intro τ a b hab
  obtain ⟨θ, s, hθ⟩ := S.total_eq_thread τ
  rw [hθ a, hθ b] at hab
  obtain ⟨htime, _⟩ := share_of_cls_eq hab
  -- `Duration` is not syntactically `ℤ` at this goal; the ascription is what lets `omega`'s
  -- cancellation lemma apply.
  have h : (s + a : ℤ) = (s + b : ℤ) := htime
  exact add_left_cancel h

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
