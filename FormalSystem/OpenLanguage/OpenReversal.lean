/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenValidity
import FormalSystem.Semantics.Reversal

/-!
# Time reversal of frames, histories and L^▷ truth

The manuscript's time-reflection lemma (`lem:time-reflection`) passes from a task frame to its
**converse frame**, whose task relation is `w ⇒⁻_x u := w ⇒_{-x} u`, and from a possible world
`τ` to the world `x ↦ τ(-x)` over the converse frame. This module builds both *semantically*, for
an arbitrary task frame, and proves the one transport theorem that turns every validity about the
open-future operator into a validity about the open-past operator:

```
M, τ, t ⊨ φ     iff     M⁻, τ⁻, -t ⊨ φ.reflectTime
```

The reversal exchanges the two agreement classes — `σ ∈ |τ⟩_t` iff `σ⁻ ∈ ⟨τ⁻|_{-t}` — and fixes
`⟨τ⟩_t`, which is why `reflectTime` exchanges `▷` with `◁` and fixes `⊡`
(`OpenLanguage/Formula.lean`).

The repository's existing reflection machinery (`TruthAntiIso`, `Semantics/TruthTransport.lean`)
cannot serve here: it transports the six L clauses along an atom-level agreement, and a clause
that quantifies over a *class* of histories needs the class itself to be transported.

**Siting.** The frame, model and history halves of the reversal are language-independent and
live in `Semantics/`: `FrameOver.rev` and `TaskFrame.rev` in `Semantics/TaskFrame.lean`, beside
the `def:frame` constraint predicates they are proved against, and `TaskModel.rev`,
`WorldHistory.rev` and the base-language transport in `Semantics/Reversal.lean`. This module
carries the L^▷ half only: the three agreement-class swaps and the transport theorem over them.

## Main Definitions

None. The reversal operations this module reasons about — `FrameOver.rev`, `TaskFrame.rev`,
`TaskModel.rev`, `WorldHistory.rev` — are declared in `Semantics/` and used here through dot
notation.

## Main Results

- `agreeUpTo_rev_iff`, `agreeFrom_rev_iff` — the class swaps this layer owns: reversal exchanges
  `|τ⟩_t` with `⟨τ⁻|_{-t}`. That it *fixes* `⟨τ⟩_t` is `sameState_rev_iff`, which is
  language-free and lives in `Semantics/Reversal.lean`
- `image_rev_stabClass` — the image form of that fixing: `τ ↦ τ⁻` carries `⟨τ⟩_x` **onto**
  `⟨τ⁻⟩_{-x}`, as a `Set.image` equation
- `openTruthAt_rev` — the transport theorem
- `openValidOn_rev_iff` and `openValid_reflectTime` — validity is closed under time reflection

## References

* JPL paper `lem:time-reflection` — the converse frame and the reflected world
* JPL paper `def:frame` — *Compositionality*, *Seriality*, *Limit* and *Saturation*, each of
  which the converse frame inherits
* `FormalSystem/Semantics/TaskFrame.lean` — `FrameOver`, `TaskFrame.reflect`,
  `FrameOver.reflection`, and the converse frame `FrameOver.rev` / `TaskFrame.rev`
* `FormalSystem/Semantics/Reversal.lean` — `TaskModel.rev`, `WorldHistory.rev` and
  `truthAt_rev`, which is `lem:time-reflection` for the base language

## Tags

open-language · time-reflection · converse-frame
-/

namespace FormalSystem.OpenLanguage

/-! The reversal operations live in `FormalSystem.Semantics` — `FrameOver.rev` and
`TaskFrame.rev` in `Semantics/TaskFrame.lean`, `TaskModel.rev` and `WorldHistory.rev` in
`Semantics/Reversal.lean` — and are used here through dot notation. What follows is the L^▷
half: the agreement-class swaps and the transport theorems over them. -/

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage.OpenFormula
open FormalSystem.Semantics

variable {F : TaskFrame}

/-! ## The class swaps -/

/-- **Reversal carries `⟨τ⟩_x` onto `⟨τ⁻⟩_{-x}`.** The image form of `sameState_rev_iff`, which
is the pointwise statement and lives at the semantic layer: this is the shape the paper's word
*onto* asserts, with `stabClass` the named `⟨τ⟩_x`. Surjectivity of reversal on histories
(`WorldHistory.rev_surjective`) is what makes the inclusion an equality. -/
theorem image_rev_stabClass (τ : WorldHistory F) (x : F.Duration) :
    WorldHistory.rev '' stabClass τ x = stabClass τ.rev (-x) := by
  ext σ'
  constructor
  · rintro ⟨σ, hσ, rfl⟩
    exact (sameState_rev_iff τ σ x).mp hσ
  · intro hσ'
    obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
    exact ⟨σ, (sameState_rev_iff τ σ x).mpr hσ', rfl⟩

/-- Reversal sends `|τ⟩_t` to `⟨τ⁻|_{-t}`. -/
theorem agreeUpTo_rev_iff (τ σ : WorldHistory F) (t : F.Duration) :
    AgreeUpTo τ σ t ↔ AgreeFrom τ.rev σ.rev (-t) := by
  constructor
  · intro h s hs
    change τ.state (-s) = σ.state (-s)
    exact h (-s) (neg_le.mp hs)
  · intro h s hs
    have := h (-s) (neg_le_neg hs)
    change τ.state (- -s) = σ.state (- -s) at this
    rwa [neg_neg] at this

/-- Reversal sends `⟨τ|_t` to `|τ⁻⟩_{-t}`. -/
theorem agreeFrom_rev_iff (τ σ : WorldHistory F) (t : F.Duration) :
    AgreeFrom τ σ t ↔ AgreeUpTo τ.rev σ.rev (-t) := by
  constructor
  · intro h s hs
    change τ.state (-s) = σ.state (-s)
    exact h (-s) (le_neg.mp hs)
  · intro h s hs
    have := h (-s) (neg_le_neg hs)
    change τ.state (- -s) = σ.state (- -s) at this
    rwa [neg_neg] at this

/-! ## The transport theorem -/

/--
**L^▷ truth commutes with time reversal.** A formula is true at `(M, τ, t)` exactly when its time
reflection is true at the reflected point `(M⁻, τ⁻, -t)` of the converse frame.

By induction on `φ`, generalizing the history and the time. `box` uses the surjectivity of
reversal on histories; `untl` and `snce` negate the bounds; `stab` is the semantic layer's
`sameState_rev_iff`; `ofut`
and `opast` are the two agreement swaps.
-/
theorem openTruthAt_rev (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula) :
    OpenTruthAt M τ t φ ↔ OpenTruthAt M.rev τ.rev (-t) φ.reflectTime := by
  induction φ generalizing τ t with
  | atom p =>
    change M.valuation (τ.state t) p ↔ M.valuation (τ.state (- -t)) p
    rw [neg_neg]
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih =>
    constructor
    · intro h σ'
      obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
      exact (ih σ t).mp (h σ)
    · intro h σ
      exact (ih σ t).mpr (h σ.rev)
  | untl ψ φ ihψ ihφ =>
    constructor
    · rintro ⟨s, hts, hφ, hψ⟩
      refine ⟨-s, neg_lt_neg hts, (ihφ τ s).mp hφ, ?_⟩
      intro r' h1 h2
      obtain ⟨r, rfl⟩ : ∃ r : F.Duration, r' = -r := ⟨-r', (neg_neg r').symm⟩
      exact (ihψ τ r).mp (hψ r (neg_lt_neg_iff.mp h2) (neg_lt_neg_iff.mp h1))
    · rintro ⟨s', hs't, hφ, hψ⟩
      obtain ⟨s, rfl⟩ : ∃ s : F.Duration, s' = -s := ⟨-s', (neg_neg s').symm⟩
      refine ⟨s, neg_lt_neg_iff.mp hs't, (ihφ τ s).mpr hφ, ?_⟩
      intro r h1 h2
      exact (ihψ τ r).mpr (hψ (-r) (neg_lt_neg h2) (neg_lt_neg h1))
  | snce ψ φ ihψ ihφ =>
    constructor
    · rintro ⟨s, hst, hφ, hψ⟩
      refine ⟨-s, neg_lt_neg hst, (ihφ τ s).mp hφ, ?_⟩
      intro r' h1 h2
      obtain ⟨r, rfl⟩ : ∃ r : F.Duration, r' = -r := ⟨-r', (neg_neg r').symm⟩
      exact (ihψ τ r).mp (hψ r (neg_lt_neg_iff.mp h2) (neg_lt_neg_iff.mp h1))
    · rintro ⟨s', hts', hφ, hψ⟩
      obtain ⟨s, rfl⟩ : ∃ s : F.Duration, s' = -s := ⟨-s', (neg_neg s').symm⟩
      refine ⟨s, neg_lt_neg_iff.mp hts', (ihφ τ s).mpr hφ, ?_⟩
      intro r h1 h2
      exact (ihψ τ r).mpr (hψ (-r) (neg_lt_neg h2) (neg_lt_neg h1))
  | stab φ ih =>
    constructor
    · intro h σ' hs
      obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
      exact (ih σ t).mp (h σ ((sameState_rev_iff τ σ t).mpr hs))
    · intro h σ hs
      exact (ih σ t).mpr (h σ.rev ((sameState_rev_iff τ σ t).mp hs))
  | ofut φ ih =>
    constructor
    · intro h σ' hs
      obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
      exact (ih σ t).mp (h σ ((agreeUpTo_rev_iff τ σ t).mpr hs))
    · intro h σ hs
      exact (ih σ t).mpr (h σ.rev ((agreeUpTo_rev_iff τ σ t).mp hs))
  | opast φ ih =>
    constructor
    · intro h σ' hs
      obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
      exact (ih σ t).mp (h σ ((agreeFrom_rev_iff τ σ t).mpr hs))
    · intro h σ hs
      exact (ih σ t).mpr (h σ.rev ((agreeFrom_rev_iff τ σ t).mp hs))

/-! ## Validity is closed under time reflection -/

/-- A formula is valid over a frame exactly when its time reflection is valid over the converse
frame. -/
theorem openValidOn_rev_iff (F : TaskFrame) (φ : OpenFormula) :
    F.rev.OpenValidOn φ.reflectTime ↔ F.OpenValidOn φ := by
  constructor
  · intro h M τ t
    exact (openTruthAt_rev M τ t φ).mpr (h M.rev τ.rev (-t))
  · intro h M' τ' t'
    obtain ⟨τ, rfl⟩ := WorldHistory.rev_surjective τ'
    have key := (openTruthAt_rev (M'.rev : TaskModel F) τ (-t') φ).mp (h _ τ (-t'))
    rw [neg_neg] at key
    exact key

/-- **Validity is closed under time reflection.** Every task frame is the converse of its own
converse (`TaskFrame.rev_rev`), so a validity about `▷` yields the mirrored validity about `◁`.
Stated at the unconstrained class only.

Paper: — (formalization-native; `lem:time-reflection` is stated for the base language, and this
is its extension to `⊡`, `▷` and `◁` at the level of validity) -/
theorem openValid_reflectTime (φ : OpenFormula) : OpenValid φ → OpenValid φ.reflectTime := by
  intro h
  refine OpenValid.of_forall_regular fun F _ M τ t => ?_
  have hrev : F.rev.OpenValidOn φ := fun M' τ' t' => h.apply F.rev M' τ' t'
  exact (openValidOn_rev_iff F.rev φ).mpr hrev M τ t

end FormalSystem.OpenLanguage
