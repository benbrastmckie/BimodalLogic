/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.IntTransfer
import FormalSystem.PlusLanguage.PlusValidity

/-!
# L⁺ carrier normalization: `PlusValidZTime φ ↔ PlusValidInt φ`

`PlusValidZTime` quantifies over *every* discrete duration carrier — every nontrivial
successor-Archimedean ordered abelian group. This module shows that quantifier is redundant for
L⁺ exactly as `Semantics/IntTransfer.lean` shows it is for L: one carrier, `ℤ`, already decides
it. The headline result is

  `plusValidZTime_iff_plusValidInt : PlusValidZTime φ ↔ PlusValidInt φ`

and it is the L⁺ twin of `Semantics.validZTime_iff_validInt`, sharing that module's entire
transport stack — `FrameOver.map`, `TaskModel.map`, `WorldHistory.map`/`.comap`, `Aligned` — with
nothing new at the frame, model or history level. Only truth transfer is re-proved, because
`PlusTruthAt` is a native recursion on `PlusFormula` and not an instance of `TruthAt`.

## Why a direct induction and not a `PlusTruthCorr` structure

`Semantics.truthAt_map` is a one-liner: it is `Truth.truthAt_of_truthCorr` at the instance
`alignedCorr`. No such collapse is available here. `PlusTruthAt` recurses over `PlusFormula`'s
seven constructors, and its seventh clause — the paper's stability clause
(`def:BLstar-semantics`) — quantifies over the world histories sharing `τ`'s world state at the
evaluation time, a side condition no `Semantics.TruthCorr` field mentions. A structure carrying
that extra field would have to live somewhere, and `Semantics/TruthClauses.lean`'s stated
extension contract forbids the obvious home ("**No recursor** … Nothing provable only by
`induction φ` belongs here"). The seven-case induction is therefore paid either way, and it is
paid here, in the open, matching the three L⁺/L⋆ transports already in this tree
(`plusTruthAt_timeShift`, `plus_invariance`, `star_invariance`), every one of them a direct
induction for the same recorded reason. The `atom` case does reuse `alignedCorr`'s own
valuation-agreement field rather than restating it.

## The stability case costs no transport

The state-agreement side condition crosses the transport without `HEq`, without a world-state
bijection, and without any dependent rewriting, because `(FrameOver.map F e).WorldState` is
*definitionally* `F.WorldState` (see `Semantics/IntTransfer.lean`'s "Design decision: `Aligned`,
a relation"). Both sides of the equation `σ'.state (e t) = σ.state t` therefore live in the one
type `F.WorldState`, and `WorldHistory.comap` together with `aligned_comap` carry a candidate
history back across the transport with its state equation intact.

## Main definitions

- `PlusValidInt`: L⁺ validity over `ℤ`-frames only, the binder-for-binder mirror of
  `Semantics.ValidInt`.

## Main results

- `plusTruthAt_map`: `PlusTruthAt M σ t φ ↔ PlusTruthAt (M.map e) σ' (e t) φ` for aligned `σ`,
  `σ'` — the seven-case `PlusFormula` twin of `Semantics.truthAt_map`.
- `plusValidZTime_iff_plusValidInt`: **carrier normalization for L⁺**. This is the prerequisite
  any integer-indexed enumeration route for L⁺ rests on: without it, a candidate enumeration over
  `ℤ`-indexed structures certifies nothing about `PlusValidZTime`.

## References

* JPL paper `def:BLstar-semantics` — the stability clause the `stab` case transports
* `FormalSystem/Semantics/IntTransfer.lean` — the L result this mirrors, and the whole shared
  frame/model/history transport
* `FormalSystem/Semantics/Frames/TranslationProduct.lean` — `plus_invariance`, the seven-case
  induction template
* `FormalSystem/Semantics/DurationClassification.lean` — `intIso`, the normalizing isomorphism

## Tags

ztime · transfer · plus-language · normal-form
-/

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {D E : TemporalOrder}

/--
**L⁺ truth transfers across the frame transport.** For aligned world histories `σ` and `σ'`, the
L⁺ formula `φ` holds at `t` in `M` along `σ` exactly when it holds at `e t` in `M.map e` along
`σ'`.

The `PlusFormula` twin of `Semantics.truthAt_map`, proved by a direct seven-case induction
generalised over both histories and the time. The six L cases follow the body of
`Truth.truthAt_of_truthCorr`; the `atom` case is `alignedCorr`'s own valuation-agreement field,
written inline so the `Rel` projection reduces to `Aligned e`. The seventh case transports the
stability clause's state-agreement side condition, which goes through as an ordinary equation in
`F.WorldState` — see this module's header for why no dependent transport is needed.
-/
theorem plusTruthAt_map {F : FrameOver D} [F.IsRegular]
    (e : ↑D ≃+o ↑E) (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    ∀ (σ : WorldHistory F.toTaskFrame) (σ' : WorldHistory (FrameOver.map F e).toTaskFrame),
      Aligned e σ σ' →
      ∀ t : ↑D, (PlusTruthAt M σ t φ ↔ PlusTruthAt (TaskModel.map M e) σ' (e t) φ) := by
  -- the atom case reuses the `TruthCorr` instance's own valuation-agreement field
  induction φ with
  | atom p => intro σ σ' h t; exact (alignedCorr e M).atom σ σ' h t p
  | bot => intro σ σ' _ t; exact Iff.rfl
  | imp a b iha ihb =>
      intro σ σ' h t
      exact Iff.imp (iha σ σ' h t) (ihb σ σ' h t)
  | box a ih =>
      intro σ σ' _ t
      constructor
      · intro h ρ'
        exact (ih (WorldHistory.comap e ρ') ρ' (aligned_comap e ρ') t).mp (h _)
      · intro h ρ
        exact (ih ρ (ρ.map e) (aligned_map e ρ) t).mpr (h _)
  | untl b a ihb iha =>
      intro σ σ' h t
      constructor
      · rintro ⟨s, hts, hs, hmin⟩
        refine ⟨e s, (map_lt_map_iff e).mpr hts, (iha σ σ' h s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := e.surjective r'
        exact (ihb σ σ' h r).mp (hmin r ((map_lt_map_iff e).mp h1) ((map_lt_map_iff e).mp h2))
      · rintro ⟨s', hts', hs', hmin'⟩
        obtain ⟨s, rfl⟩ := e.surjective s'
        refine ⟨s, (map_lt_map_iff e).mp hts', (iha σ σ' h s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihb σ σ' h r).mpr
          (hmin' (e r) ((map_lt_map_iff e).mpr h1) ((map_lt_map_iff e).mpr h2))
  | snce b a ihb iha =>
      intro σ σ' h t
      constructor
      · rintro ⟨s, hst, hs, hmin⟩
        refine ⟨e s, (map_lt_map_iff e).mpr hst, (iha σ σ' h s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := e.surjective r'
        exact (ihb σ σ' h r).mp (hmin r ((map_lt_map_iff e).mp h1) ((map_lt_map_iff e).mp h2))
      · rintro ⟨s', hst', hs', hmin'⟩
        obtain ⟨s, rfl⟩ := e.surjective s'
        refine ⟨s, (map_lt_map_iff e).mp hst', (iha σ σ' h s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihb σ σ' h r).mpr
          (hmin' (e r) ((map_lt_map_iff e).mpr h1) ((map_lt_map_iff e).mpr h2))
  | stab a ih =>
      intro σ σ' ha t
      -- the state-agreement bridge: both sides are the SAME equation in `F.WorldState`
      have hσ : σ'.state (e t) = σ.state t := by
        rw [ha (e t), e.symm_apply_apply]
      constructor
      · intro h ρ' hst
        have hρ : ρ'.state (e t) = (WorldHistory.comap e ρ').state t := rfl
        refine (ih (WorldHistory.comap e ρ') ρ' (aligned_comap e ρ') t).mp (h _ ?_)
        rw [← hσ, ← hρ]; exact hst
      · intro h ρ hst
        have hρ : (ρ.map e).state (e t) = ρ.state t := by
          change ρ.state (e.symm (e t)) = ρ.state t
          rw [e.symm_apply_apply]
        refine (ih ρ (ρ.map e) (aligned_map e ρ) t).mpr (h _ ?_)
        rw [hσ, hρ]; exact hst

/--
An L⁺ formula is **`ℤ`-valid** if it is true in every model over a `ℤ`-frame, at every world
history, at every time.

This is `PlusValidZTime` with the carrier quantifier collapsed to the single carrier `ℤ`, and the
binder-for-binder mirror of `Semantics.ValidInt`. All eight instance binders of `PlusValidZTime`
vanish here: `ℤ` supplies every one of them from Mathlib with no instance work.
-/
def PlusValidInt (φ : PlusFormula) : Prop :=
  ∀ (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ), PlusTruthAt M τ t φ

/--
**Carrier normalization for L⁺.** Quantifying over every discrete duration carrier is the same as
quantifying over `ℤ` alone, for L⁺ exactly as `Semantics.validZTime_iff_validInt` has it for L.

The forward direction is a single instantiation: `ℤ` discharges the whole `PlusValidZTime` binder
bundle. The reverse direction normalizes an arbitrary discrete carrier by
`DurationClassification.lean`'s `intIso : D ≃+o ℤ`, carries the model across with `FrameOver.map`
/ `TaskModel.map` / `WorldHistory.map`, and carries L⁺ truth back with `plusTruthAt_map`. The
transfer must be an *additive* order isomorphism — durations add — so the order-only
`orderIsoIntOfLinearSuccPredArch` could not be used here.

This is the prerequisite for any integer-indexed decidability route for L⁺: it is what makes an
enumeration over `ℤ`-indexed structures say something about `PlusValidZTime`.

Paper: — (formalization-native; carrier normalization is a reduction the paper has no need of,
since it quantifies over its intended duration carrier directly and supplies no such reduction)
-/
theorem plusValidZTime_iff_plusValidInt (φ : PlusFormula) :
    PlusValidZTime φ ↔ PlusValidInt φ := by
  constructor
  · intro h F _ M τ t
    exact h F.toTaskFrame ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩ M τ t
  · intro h F hF M τ t
    sat_intro hF
    -- Ascribe the target at `↑intOrder`, not at `ℤ`: the transport's `E` is a `TemporalOrder`,
    -- and Lean cannot invert `↑E ≟ ℤ` to recover `E := intOrder` on its own.
    let e : ↑F.Duration ≃+o ↑intOrder := intIso
    refine (plusTruthAt_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e M φ τ
      (WorldHistory.map τ e) (aligned_map (D := F.Duration) (E := intOrder) (F := F.toFibre) e τ)
      t).mpr ?_
    exact h (FrameOver.map F.toFibre e) (TaskModel.map (F := F.toFibre) M e)
      (WorldHistory.map τ e) (e t)

end FormalSystem.PlusLanguage
