/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.QuantLanguage.QuantTruth
import FormalSystem.Semantics.HistoryMorphism

/-!
# Quantifiers over lifted propositions are invisible

Along a history-lifting morphism `g : HistMorphism F' F`
(`FormalSystem/Semantics/HistoryMorphism.lean`), the **lifted** propositions of `F'` are the
preimages `g⁻¹(T)` of sets `T` of world states of `F`: the propositions of `F'` that cannot tell
two preimages of one state apart. When the propositional quantifier of `F'` ranges over the lifted
propositions only, truth on `F'` at the pulled-back model equals **standard** truth on `F` at the
image history, for every formula.

So propositional quantifiers restricted to clock-independent propositions add nothing the base
language does not already see: whatever is invisible along a history-lifting morphism stays
invisible. The contrast is `standard_not_invariant` of `QuantLanguage/QuantRecurrence.lean`: let
the quantifier of `F'` range over **every** set of world states and the invariance fails.

## Main Definitions

- `pulledBack g` — the lifted propositions along a history-lifting map

## Main Results

- `pullM_updateAtom` — pulling back commutes with re-interpreting a letter, the new set pulled
  back too
- `lifted_invariance` — truth under the lifted family on `F'` equals standard truth on `F`

## References

* `FormalSystem/Semantics/HistoryMorphism.lean` — `HistMap`, `HistMorphism`, `HistMap.mapH`,
  `HistMap.pullM`
* `FormalSystem/QuantLanguage/QuantTruth.lean` — `QuantTruthAt`, `TaskModel.updateAtom`
* `FormalSystem/HybridLanguage/HybridInvariance.lean` — the sibling invariance, for the
  register-free fragment of the hybrid state language

## Tags

quant-language · invariance · history-lifting-morphism · admissible-family
-/

namespace FormalSystem.QuantLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {D : TemporalOrder} {F' F : FrameOver D}

/-- The lifted (clock-independent along `g`) propositions: the preimages of sets of world states
of the target frame.

Paper: — (formalization-native; the paper defines no morphism of task frames) -/
def pulledBack (g : HistMap F' F) : Set (Set F'.WorldState) :=
  {S | ∃ T : Set F.WorldState, S = g.toFun ⁻¹' T}

/-- Pulling a model back commutes with re-interpreting a letter, provided the new set is pulled
back as well. Definitional. -/
theorem pullM_updateAtom (g : HistMap F' F) (M : TaskModel F.toTaskFrame) (p : Atom)
    (T : Set F.WorldState) :
    g.pullM (M.updateAtom p T) = (g.pullM M).updateAtom p (g.toFun ⁻¹' T) := rfl

/--
**Quantifiers ranging over lifted propositions see nothing the base frame does not**: truth under
the lifted family on `F'`, at the pulled-back model, equals standard truth on `F` at the image
history, along any history-lifting morphism.

By induction on `φ`, the model generalized. The `box` case uses `onto` and
`WorldHistory.ext_state`. In the `all` case a set `T` of states of `F` is traded for its preimage,
which is lifted by construction, and every lifted set is such a preimage; `pullM_updateAtom` moves
the update across the pull-back.

Paper: — (formalization-native; the paper's languages have no propositional quantifiers)
-/
theorem lifted_invariance (g : HistMorphism F' F) :
    ∀ (φ : QuantFormula) (M : TaskModel F.toTaskFrame) (τ' : WorldHistory F'.toTaskFrame)
      (t : ↑D),
      QuantTruthAt (g.pullM M) τ' t (pulledBack g.toHistMap) φ ↔
        QuantTruthAt M (g.mapH τ') t Set.univ φ := by
  intro φ
  induction φ with
  | atom p => intro M τ' t; exact Iff.rfl
  | bot => intro M τ' t; exact Iff.rfl
  | imp a b ih1 ih2 => intro M τ' t; exact imp_congr (ih1 M τ' t) (ih2 M τ' t)
  | box a ih =>
    intro M τ' t
    constructor
    · intro hb ρ
      obtain ⟨ρ', hρ'⟩ := g.onto ρ
      have hm : g.mapH ρ' = ρ := WorldHistory.ext_state hρ'
      have := (ih M ρ' t).1 (hb _)
      rwa [hm] at this
    · intro hb σ'; exact (ih M σ' t).2 (hb _)
  | untl a b ih1 ih2 =>
    intro M τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 M τ' s) (forall_congr' fun u => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 M τ' u)
  | snce a b ih1 ih2 =>
    intro M τ' t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 M τ' s) (forall_congr' fun u => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 M τ' u)
  | all p a ih =>
    intro M τ' t
    constructor
    · intro h T _
      refine (ih (M.updateAtom p T) τ' t).1 ?_
      rw [pullM_updateAtom]
      exact h (g.toFun ⁻¹' T) ⟨T, rfl⟩
    · rintro h S ⟨T, rfl⟩
      rw [← pullM_updateAtom]
      exact (ih (M.updateAtom p T) τ' t).2 (h T (Set.mem_univ _))

end FormalSystem.QuantLanguage
