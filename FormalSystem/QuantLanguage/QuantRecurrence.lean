/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.QuantLanguage.QuantTruth
import FormalSystem.Semantics.HistoryMorphism
import FormalSystem.Semantics.Extension.Extension

/-!
# Standard propositional quantifiers name world states and see recurrence

Under the **standard** semantics, where the propositional quantifier ranges over every set of
world states, the atom formula

```
Atom(p) := E p ∧ ∀q (A(p → q) ∨ A(p → ¬q))
```

says exactly that `p` is true at **one world state** (`isAtom_iff`). The quantifier thereby
manufactures a state nominal, and the quantified recurrence sentence
`∀p (Atom(p) → ¬(p ∧ (P p ∨ F p)))` is valid on a frame iff the frame is recurrence-free
(`qRec_defines`). Consequently standard quantifier truth is **not** invariant along a
history-lifting morphism from a recurrence-free frame onto a frame with recurrence
(`standard_not_invariant`) — in contrast with `lifted_invariance` of
`QuantLanguage/QuantInvariance.lean`, where the quantifier ranges over the lifted propositions
only. That contrast is what the admissible family exists to state.

## A world state, not an instant

`Atom(p)` is the construction of a world-proposition — a proposition true somewhere that settles
every proposition — read over sets of world states. A letter of a task model denotes a set of
world states (`def:BL-semantics`), so what `Atom(p)` names is a **world state**, not an instant or
a (history, time) pair. That is why it can exhibit what an instant cannot: an instant does not
recur, and a world state may. The manuscript makes the corresponding point about strictly ordered
world states in `sub:WorldStates`: "taking world states to be strictly ordered prevents the same
world state from occurring more than once in any history".

## Main Results

- `isAtom_iff` — `Atom(p)` holds iff some world state satisfies `p` and every occurring `p`-state
  is that state. The `←` direction gets `E p` from `cor:occurrence`
- `qRec_valid`, `qRec_defines` — the quantified recurrence sentence defines recurrence-freeness
- `standard_not_invariant` — standard quantifier truth is not invariant along a history-lifting
  morphism from a recurrence-free frame onto a frame with recurrence

## References

* JPL paper `cor:occurrence` — every world state occurs at any prescribed time in some possible
  world
* JPL paper `def:BL-semantics` — a sentence letter denotes a set of world states
* JPL paper `sub:WorldStates` — strictly ordered world states exclude recurrence
* `FormalSystem/Semantics/Extension/Extension.lean` — `PartialHistory.occurrence`
* `FormalSystem/Semantics/HistoryMorphism.lean` — `TaskFrame.RecurrenceFree`, `HistMorphism`
* `FormalSystem/QuantLanguage/QuantInvariance.lean` — `lifted_invariance`, the contrast

## Tags

quant-language · recurrence · definability · state-nominal · propositional-quantifier
-/

namespace FormalSystem.QuantLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics
open QuantTruth

variable {G : TaskFrame}

/--
**`Atom(p)` under the standard semantics says that `p` names a world state**: some world state
satisfies `p`, and every occurring `p`-state is that state.

`→`: the witness of `E p` is a state `ρ₀(s₀)`; instantiate the quantifier at its singleton. The
second disjunct is refuted at `(ρ₀, s₀)`, so the first holds, and it says every occurring
`p`-state lies in the singleton. `←`: `E p` holds because the state occurs in some possible world
(`cor:occurrence`), and for a set `S` the disjunct is chosen by whether the state is in `S`. The
hypothesis `p ≠ q` is used exactly once, to read `p` off the model updated at `q`.

Paper: — (formalization-native; the `←` direction consumes `cor:occurrence`)
-/
theorem isAtom_iff [G.IsRegular]
    (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) {p q : Atom}
    (hpq : p ≠ q) :
    QuantTruthAt M τ t Set.univ (QuantFormula.isAtom p q) ↔
      ∃ w, M.valuation w p ∧
        ∀ (ρ : WorldHistory G) (s : G.Duration), M.valuation (ρ.state s) p → ρ.state s = w := by
  rw [QuantFormula.isAtom, and_iff, exist_iff, all_iff]
  simp only [or_iff, univ_iff, imp_iff, neg_iff, atom_iff,
    TaskModel.updateAtom_valuation_self, TaskModel.updateAtom_valuation_of_ne _ hpq]
  constructor
  · rintro ⟨⟨ρ₀, s₀, h₀⟩, hq⟩
    refine ⟨ρ₀.state s₀, h₀, fun ρ s hs => ?_⟩
    rcases hq {ρ₀.state s₀} (Set.mem_univ _) with h | h
    · exact h ρ s hs
    · exact absurd (Set.mem_singleton _) (h ρ₀ s₀ h₀)
  · rintro ⟨w, hw, huniq⟩
    obtain ⟨ρ₀, hρ₀⟩ := PartialHistory.occurrence G w t
    refine ⟨⟨ρ₀, t, by rw [hρ₀]; exact hw⟩, fun S _ => ?_⟩
    by_cases hwS : w ∈ S
    · left; intro ρ s hs; rw [huniq ρ s hs]; exact hwS
    · right; intro ρ s hs; rw [huniq ρ s hs]; exact hwS

/-- `∀p (Atom(p) → ¬(p ∧ (P p ∨ F p)))` is true everywhere on a recurrence-free frame: a
proposition that names a state and is true at two times of one history makes the history visit
that state twice.

Paper: — (formalization-native; the paper's languages have no propositional quantifiers) -/
theorem qRec_valid [G.IsRegular] (hG : G.RecurrenceFree) (M : TaskModel G) (τ : WorldHistory G)
    (t : G.Duration) {p q : Atom} (hpq : p ≠ q) :
    QuantTruthAt M τ t Set.univ (QuantFormula.qRec p q) := by
  rw [QuantFormula.qRec, all_iff]
  intro S _
  rw [imp_iff, isAtom_iff _ _ _ hpq, neg_iff, and_iff, or_iff, somePast_iff, someFuture_iff]
  simp only [atom_iff, TaskModel.updateAtom_valuation_self]
  rintro ⟨w, -, huniq⟩ ⟨ht, ⟨s, hs, hs'⟩ | ⟨s, hs, hs'⟩⟩
  · exact hs.ne (hG τ s t ((huniq τ s hs').trans (huniq τ t ht).symm))
  · exact hs.ne' (hG τ s t ((huniq τ s hs').trans (huniq τ t ht).symm))

/--
**Definability under standard quantification**: the quantified recurrence sentence is valid on a
frame iff the frame is recurrence-free. For the forward direction the quantifier is instantiated
at the singleton of the recurring state — the propositional quantifier manufactures the state
nominal itself; the model is irrelevant.

Paper: — (formalization-native; the paper's languages have no propositional quantifiers)
-/
theorem qRec_defines (G : TaskFrame) [G.IsRegular] {p q : Atom} (hpq : p ≠ q) :
    (∀ (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration),
      QuantTruthAt M τ t Set.univ (QuantFormula.qRec p q)) ↔ G.RecurrenceFree := by
  constructor
  · intro h τ s t hst
    by_contra hne
    have h1 := h ⟨fun _ _ => False⟩ τ s
    rw [QuantFormula.qRec, all_iff] at h1
    have h2 := h1 {τ.state s} (Set.mem_univ _)
    rw [imp_iff, isAtom_iff _ _ _ hpq, neg_iff, and_iff, or_iff, somePast_iff,
      someFuture_iff] at h2
    simp only [atom_iff, TaskModel.updateAtom_valuation_self] at h2
    apply h2
    · exact ⟨τ.state s, Set.mem_singleton _, fun ρ u hu => hu⟩
    · refine ⟨Set.mem_singleton _, ?_⟩
      rcases lt_or_gt_of_ne hne with hlt | hgt
      · exact Or.inr ⟨t, hlt, hst.symm⟩
      · exact Or.inl ⟨t, hgt, hst.symm⟩
  · intro hG M τ t; exact qRec_valid hG M τ t hpq

/--
**Standard-semantics quantifier truth is not invariant** along any history-lifting morphism from a
recurrence-free frame onto a frame with recurrence. Were it invariant, the quantified recurrence
sentence, valid on the source, would be valid on the target, which would then be recurrence-free.
Contrast `lifted_invariance`.

Paper: — (formalization-native; the paper defines no morphism of task frames)
-/
theorem standard_not_invariant {D : TemporalOrder} {F' F : FrameOver D} [F'.IsRegular]
    [F.IsRegular] (g : HistMorphism F' F)
    (hF' : F'.toTaskFrame.RecurrenceFree) (hF : ¬ F.toTaskFrame.RecurrenceFree) :
    ¬ ∀ (φ : QuantFormula) (M : TaskModel F.toTaskFrame) (τ' : WorldHistory F'.toTaskFrame)
        (t : ↑D),
      QuantTruthAt (g.pullM M) τ' t Set.univ φ ↔ QuantTruthAt M (g.mapH τ') t Set.univ φ := by
  intro hinv
  apply hF
  have hpq : Atom.mkFresh "" 0 ≠ Atom.mkFresh "" 1 := by decide
  rw [← qRec_defines _ hpq]
  intro M τ t
  obtain ⟨τ', hτ'⟩ := g.onto τ
  have hm : g.mapH τ' = τ := WorldHistory.ext_state hτ'
  rw [← hm]
  exact (hinv _ M τ' t).1 (qRec_valid hF' _ τ' t hpq)

end FormalSystem.QuantLanguage
