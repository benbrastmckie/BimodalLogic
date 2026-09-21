/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.HybridLanguage.HybridTruth
import FormalSystem.Semantics.HistoryMorphism

/-!
# The same-state modality is invisible: invariance of the register-free fragment

Truth of every **register-free** formula of the hybrid state language — every L⁺ formula, and
every formula built with the same-state modality `[≡]` — is invariant along any history-lifting
morphism (`FormalSystem/Semantics/HistoryMorphism.lean`), for arbitrary register vectors on the
two sides.

## Why `[≡]` cannot see recurrence

`[≡]φ` tests state identity across times: it ranges over every (history, time) pair occupying the
present world state. It still cannot detect that a history revisits a state, because it cannot
tell the pair `(τ, s)` from a pair `(σ, s)` for another history `σ` through the same state: the
clause hands `φ` every pair at the state and never says which of them lie on the history of
evaluation. A history-lifting morphism preserves exactly that much — the `same` case below is
discharged by `lift` at the freed time, as the `stab` case is by `lift` at the present time — so
the register-free fragment is as blind to recurrence and transposition as L⁺ is.

The invariance breaks at `reg` and `bind`, and only there: no other clause consults a world
state's identity. `HybridLanguage/HybridRecurrence.lean` shows that one register is enough to
break it.

## Main Results

- `regFree_invariance` — truth of a register-free formula at the pulled-back model and a history
  of the source equals its truth at the model and the image history
- `ofPlus_invariance` — the L⁺ instance, through `HybridFormula.regFree_ofPlus`

## Not formalized

The **class-level corollary** — that class validity of a register-free formula equals validity
over the recurrence-free members of the class — needs a history-lifting morphism from a
recurrence-free frame onto each frame of the class. The translation product of a frame supplies
one, and it is not part of this component.

## References

* `FormalSystem/Semantics/HistoryMorphism.lean` — `HistMorphism`, `HistMap.mapH`, `HistMap.pullM`
* `FormalSystem/HybridLanguage/HybridTruth.lean` — `HybridTruthAt`
* JPL paper `def:BLstar-semantics` — the `⊡` clause, whose invariance argument the `[≡]` case
  repeats at a freed time

## Tags

hybrid-language · invariance · history-lifting-morphism · same-state
-/

namespace FormalSystem.HybridLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.Semantics

variable {D : TemporalOrder} {F' F : FrameOver D}

/--
**Truth of every register-free formula — in particular every `[≡]φ` — is invariant along any
history-lifting morphism**, for arbitrary register vectors on both sides.

By induction on `φ`. The `box` case uses `onto` and `WorldHistory.ext_state`; the `stab` case uses
`lift` at the present time; the `same` case uses `lift` at the freed time `s`, exactly as `stab`
does at `t`: a history through the image state at time `s` lifts to a history through the given
state at time `s`. The `reg` and `bind` cases are excluded by `RegFree`.

Paper: — (formalization-native; the paper defines no morphism of task frames)
-/
theorem regFree_invariance (g : HistMorphism F' F) (M : TaskModel F.toTaskFrame) :
    ∀ (φ : HybridFormula), φ.RegFree → ∀ (τ' : WorldHistory F'.toTaskFrame) (t : ↑D)
      (r' : ℕ → F'.WorldState) (r : ℕ → F.WorldState),
      HybridTruthAt (g.pullM M) τ' t r' φ ↔ HybridTruthAt M (g.mapH τ') t r φ := by
  intro φ
  induction φ with
  | atom p => intro _ τ' t r' r; exact Iff.rfl
  | bot => intro _ τ' t r' r; exact Iff.rfl
  | imp a b ih1 ih2 =>
    intro h τ' t r' r
    exact imp_congr (ih1 h.1 τ' t r' r) (ih2 h.2 τ' t r' r)
  | box a ih =>
    intro h τ' t r' r
    constructor
    · intro hb ρ
      obtain ⟨ρ', hρ'⟩ := g.onto ρ
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih h ρ' t r' r).1 (hb _)
      rwa [hm] at this
    · intro hb σ'; exact (ih h σ' t r' r).2 (hb _)
  | untl a b ih1 ih2 =>
    intro h τ' t r' r
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 h.2 τ' s r' r) (forall_congr' fun u => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 h.1 τ' u r' r)
  | snce a b ih1 ih2 =>
    intro h τ' t r' r
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 h.2 τ' s r' r) (forall_congr' fun u => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 h.1 τ' u r' r)
  | stab a ih =>
    intro h τ' t r' r
    constructor
    · intro hs ρ hρ
      obtain ⟨ρ', hρ't, hρ'⟩ := g.lift ρ (τ'.state t) t hρ
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih h ρ' t r' r).1 (hs _ hρ't.symm)
      rwa [hm] at this
    · intro hs σ' he
      exact (ih h σ' t r' r).2 (hs _ (congrArg g.toFun he))
  | same a ih =>
    intro h τ' t r' r
    constructor
    · intro hs ρ s hρ
      obtain ⟨ρ', hρ's, hρ'⟩ := g.lift ρ (τ'.state t) s hρ.symm
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih h ρ' s r' r).1 (hs _ _ hρ's)
      rwa [hm] at this
    · intro hs σ' s he
      exact (ih h σ' s r' r).2 (hs _ _ (congrArg g.toFun he))
  | reg i => intro h; exact False.elim h
  | bind i a _ => intro h; exact False.elim h

/-- The L⁺ instance: truth of an embedded L⁺ formula is invariant along any history-lifting
morphism. -/
theorem ofPlus_invariance (g : HistMorphism F' F) (M : TaskModel F.toTaskFrame)
    (φ : PlusFormula) (τ' : WorldHistory F'.toTaskFrame) (t : ↑D) (r' : ℕ → F'.WorldState)
    (r : ℕ → F.WorldState) :
    HybridTruthAt (g.pullM M) τ' t r' (HybridFormula.ofPlus φ) ↔
      HybridTruthAt M (g.mapH τ') t r (HybridFormula.ofPlus φ) :=
  regFree_invariance g M _ (HybridFormula.regFree_ofPlus φ) τ' t r' r

end FormalSystem.HybridLanguage
