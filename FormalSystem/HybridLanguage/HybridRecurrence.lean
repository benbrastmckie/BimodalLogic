/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.HybridLanguage.HybridValidity
import FormalSystem.Semantics.HistoryMorphism

/-!
# Recurrence is definable by one state register

The recurrence formula `¬(i ∧ (P i ∨ F i))` is valid on a task frame **iff** the frame is
recurrence-free (`TaskFrame.RecurrenceFree`, `FormalSystem/Semantics/HistoryMorphism.lean`), and
so is its register-closed form `↓ᵢ ¬(i ∧ (P i ∨ F i))`. One register suffices, free or bound.

Since every frame class contains a frame with recurrence (`exists_sat_not_recurrenceFree`), no
frame class validates the recurrence formula, while the recurrence-free members of every class do.
The hybrid state language therefore separates each frame class from its recurrence-free members,
which by `regFree_invariance` (`HybridLanguage/HybridInvariance.lean`) no register-free formula
can do along a history-lifting morphism.

## The minimal resource

What breaks the invariance is **a state-identity test across two times of one history**. The
register clause `τ(x) = r(i)` compares the present world state with a stored one; evaluated under
`P` or `F` it compares the states the history of evaluation occupies at two times. Every other
clause of the language tests state identity only up to the kernel of a history-lifting morphism:
the valuation is pulled back, and `⊡` and `[≡]` range over pairs the morphism lifts. The binder
adds no power here beyond the free register — it only closes the formula, so that no assignment is
needed.

## Main Results

- `recF_valid`, `bindRec_valid` — both formulas hold everywhere on a recurrence-free frame
- `recF_defines`, `bindRec_defines` — **definability**: validity on a frame iff the frame is
  recurrence-free. The refuting assignment names the recurring state; the model is irrelevant
- `recF_not_validIn` — at every frame class the recurrence formula is not class-valid
- `recF_validOnFrames_recurrenceFree` — it is valid over the recurrence-free members of every
  class

## Paper correspondence

Recurrence is the phenomenon the manuscript's construction section (`sec:Construction`) describes
in the passage "nothing prevents a world state from occurring at many times in a single history
so that τ(x) = τ(y) for x ≠ y". The manuscript states no formula that expresses it; the
definability results are formalization-native.

## References

* `FormalSystem/Semantics/HistoryMorphism.lean` — `TaskFrame.RecurrenceFree`,
  `exists_sat_not_recurrenceFree`
* `FormalSystem/HybridLanguage/HybridValidity.lean` — `TaskFrame.HybridValidOn`, `HybridValidIn`
* `FormalSystem/HybridLanguage/HybridInvariance.lean` — the invariance these results break

## Tags

hybrid-language · recurrence · definability · state-register
-/

namespace FormalSystem.HybridLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics
open HybridTruth

variable {G : TaskFrame}

/-- `¬(i ∧ (P i ∨ F i))` is true everywhere on a recurrence-free frame, under every assignment:
if the present state is the named one and so is the state at another time of the present history,
the history visits that state twice.

Paper: — (formalization-native; the paper states no formula expressing recurrence) -/
theorem recF_valid (hG : G.RecurrenceFree) (M : TaskModel G) (τ : WorldHistory G)
    (t : G.Duration) (r : ℕ → G.WorldState) (i : ℕ) :
    HybridTruthAt M τ t r (HybridFormula.recF i) := by
  simp only [HybridFormula.recF, neg_iff, and_iff, or_iff, somePast_iff, someFuture_iff, reg_iff]
  rintro ⟨hi, ⟨s, hs, hsi⟩ | ⟨s, hs, hsi⟩⟩
  · exact hs.ne (hG τ s t (hsi.trans hi.symm))
  · exact hs.ne' (hG τ s t (hsi.trans hi.symm))

/-- The register-closed sentence `↓ᵢ ¬(i ∧ (P i ∨ F i))` is true everywhere on a recurrence-free
frame; it needs no assignment, the binder supplying one. -/
theorem bindRec_valid (hG : G.RecurrenceFree) (M : TaskModel G) (τ : WorldHistory G)
    (t : G.Duration) (r : ℕ → G.WorldState) (i : ℕ) :
    HybridTruthAt M τ t r (HybridFormula.bind i (HybridFormula.recF i)) :=
  recF_valid hG M τ t _ i

/-- **Definability**: the recurrence formula is valid on a frame iff the frame is
recurrence-free. For the forward direction, a recurrence `τ(s) = τ(t)` with `s ≠ t` refutes the
formula at `(τ, s)` under the assignment naming `τ(s)`; the model is irrelevant.

Paper: — (formalization-native; the paper states no formula expressing recurrence) -/
theorem recF_defines (G : TaskFrame) (i : ℕ) :
    G.HybridValidOn (HybridFormula.recF i) ↔ G.RecurrenceFree := by
  constructor
  · intro h τ s t hst
    by_contra hne
    have h1 := h ⟨fun _ _ => False⟩ τ s (fun _ => τ.state s)
    simp only [HybridFormula.recF, neg_iff, and_iff, or_iff, somePast_iff, someFuture_iff,
      reg_iff] at h1
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · exact h1 ⟨trivial, Or.inr ⟨t, hlt, hst.symm⟩⟩
    · exact h1 ⟨trivial, Or.inl ⟨t, hgt, hst.symm⟩⟩
  · intro hG M τ t r; exact recF_valid hG M τ t r i

/-- **Definability by a register-closed sentence**: the binder in place of the assignment.

Paper: — (formalization-native; the paper states no formula expressing recurrence) -/
theorem bindRec_defines (G : TaskFrame) (i : ℕ) :
    G.HybridValidOn (HybridFormula.bind i (HybridFormula.recF i)) ↔ G.RecurrenceFree := by
  constructor
  · intro h τ s t hst
    by_contra hne
    have h1 := h ⟨fun _ _ => False⟩ τ s (fun _ => τ.state s)
    simp only [bind_iff, HybridFormula.recF, neg_iff, and_iff, or_iff, somePast_iff,
      someFuture_iff, reg_iff, Function.update_self] at h1
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · exact h1 ⟨trivial, Or.inr ⟨t, hlt, hst.symm⟩⟩
    · exact h1 ⟨trivial, Or.inl ⟨t, hgt, hst.symm⟩⟩
  · intro hG M τ t r; exact bindRec_valid hG M τ t r i

/-- **At every frame class the recurrence formula is not class-valid**: each class contains a
frame with recurrence. -/
theorem recF_not_validIn (fc : ProofSystem.FrameClass) (i : ℕ) :
    ¬ HybridValidIn fc (HybridFormula.recF i) := by
  intro h
  obtain ⟨G, hG, hrec⟩ := exists_sat_not_recurrenceFree fc
  exact hrec ((recF_defines G i).1 (h G hG))

/-- … while it is valid over the recurrence-free members of every class. -/
theorem recF_validOnFrames_recurrenceFree (fc : ProofSystem.FrameClass) (i : ℕ) :
    HybridValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) (HybridFormula.recF i) :=
  fun _ hG M τ t r => recF_valid hG.2 M τ t r i

end FormalSystem.HybridLanguage
