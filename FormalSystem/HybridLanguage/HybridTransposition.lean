/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.HybridLanguage.HybridValidity
import FormalSystem.Semantics.HistoryMorphism
import FormalSystem.PlusLanguage.PlusPasting
import FormalSystem.PlusLanguage.PlusNonValidities

/-!
# Transposition forces recurrence

Two world histories **transpose** two world states when one passes through the first and later
through the second while the other passes through them in the opposite order. The transposition
formula `¬(E(i ∧ F j) ∧ E(j ∧ F i))` says that the states named by `i` and `j` are not transposed.

**Any transposition forces a recurrence.** Shift the second history in time so that the two
histories occupy the state `j` at one time, and paste the first history's past onto the shifted
second history's future (`paste`, `PlusLanguage/PlusPasting.lean`): the pasted history passes
through `i`, then `j`, then `i` again. So a recurrence-free frame is transposition-free
(`recurrenceFree_not_transposed`), whether the two states are equal or distinct. The converse
fails: the one-state frame has recurrence and, having one state, transposes no two distinct ones.

Consequently the transposition formula at two registers **also defines recurrence-freeness**
(`transF_defines`): validity quantifies over every assignment, including the one that gives both
registers one recurring state. It is nonetheless a formula about transposition: it is refuted on
the permissive frame `NF` with the two registers naming **distinct** states
(`transF_refuted_distinct`).

## Main Results

- `recurrenceFree_not_transposed` — the frame-level core: no two histories of a recurrence-free
  frame transpose two states
- `transF_valid` — the transposition formula holds everywhere on a recurrence-free frame
- `transF_refuted_of_recur` — it fails wherever a state recurs, both registers naming that state
- `transF_defines` — validity of `transF 0 1` on a frame iff the frame is recurrence-free
- `transF_refuted_distinct` — a refutation on `NF` with `r 0 ≠ r 1`
- `transF_not_validIn` — at every frame class the transposition formula is not class-valid

## Paper correspondence

Transposition is the phenomenon the manuscript's construction section (`sec:Construction`)
describes in the passage "nothing prevents two histories τ and σ from passing through the same
world states in a different order between two times x < y … as in chess games which transpose
move order". The pasting of two histories that meet at a time is the two-history instance of
`app:gluing`. The manuscript states no formula that expresses transposition and does not observe
that transposition forces recurrence; both are formalization-native.

## References

* JPL paper `app:gluing` — gluing histories that agree where they meet
* `FormalSystem/PlusLanguage/PlusPasting.lean` — `paste`, `paste_agreeUpTo`, `paste_agreeFrom`
* `FormalSystem/PlusLanguage/PlusNonValidities.lean` — `NF`, `natHist`
* `FormalSystem/HybridLanguage/HybridRecurrence.lean` — the recurrence formula

## Tags

hybrid-language · transposition · recurrence · definability · pasting
-/

namespace FormalSystem.HybridLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.Semantics
open HybridTruth

variable {G : TaskFrame}

/-- **The frame-level core**: no two world histories of a recurrence-free frame transpose two
world states. If `τ₁` occupies a state at `s₁` and another at the later `t₁`, while `τ₂` occupies
the second at `s₂` and the first at the later `t₂`, then shifting `τ₂` by `s₂ - t₁` makes the two
meet at `t₁`, and the pasted history occupies the first state at `s₁` and again at
`t₁ + (t₂ - s₂)`.

Paper: — (formalization-native; the pasting step is the two-history instance of `app:gluing`) -/
theorem recurrenceFree_not_transposed [G.IsRegular] (hG : G.RecurrenceFree)
    (τ₁ τ₂ : WorldHistory G)
    {s₁ t₁ s₂ t₂ : G.Duration} (h₁ : s₁ < t₁) (h₂ : s₂ < t₂)
    (hi : τ₁.state s₁ = τ₂.state t₂) (hj : τ₁.state t₁ = τ₂.state s₂) : False := by
  -- shift `τ₂` so that it occupies the second state at time `t₁`
  have hσ : τ₁.state t₁ = (τ₂.timeShift (s₂ - t₁)).state t₁ := by
    rw [WorldHistory.timeShift_state, show t₁ + (s₂ - t₁) = s₂ by abel, hj]
  have hle : t₁ ≤ t₁ + (t₂ - s₂) := le_add_of_nonneg_right (sub_nonneg.2 h₂.le)
  have e1 : (paste τ₁ (τ₂.timeShift (s₂ - t₁)) t₁ hσ).state s₁ = τ₁.state s₁ :=
    paste_agreeUpTo τ₁ _ t₁ hσ s₁ h₁.le
  have e2 : (paste τ₁ (τ₂.timeShift (s₂ - t₁)) t₁ hσ).state (t₁ + (t₂ - s₂)) = τ₂.state t₂ := by
    rw [paste_agreeFrom τ₁ _ t₁ hσ _ hle, WorldHistory.timeShift_state,
      show t₁ + (t₂ - s₂) + (s₂ - t₁) = t₂ by abel]
  exact (lt_of_lt_of_le h₁ hle).ne (hG _ s₁ _ (e1.trans (hi.trans e2.symm)))

/-- **The transposition formula is true everywhere on a recurrence-free frame**, under every
assignment: two histories through `i` then `j`, respectively `j` then `i`, are a transposition.

Paper: — (formalization-native; the paper states no formula expressing transposition) -/
theorem transF_valid [G.IsRegular] (hG : G.RecurrenceFree) (M : TaskModel G)
    (τ : WorldHistory G)
    (t : G.Duration) (r : ℕ → G.WorldState) (i j : ℕ) :
    HybridTruthAt M τ t r (HybridFormula.transF i j) := by
  simp only [HybridFormula.transF, neg_iff, and_iff, exist_iff, someFuture_iff, reg_iff]
  rintro ⟨⟨τ₁, s₁, h₁, t₁, hs₁, h₁'⟩, ⟨τ₂, s₂, h₂, t₂, hs₂, h₂'⟩⟩
  exact recurrenceFree_not_transposed hG τ₁ τ₂ hs₁ hs₂ (h₁.trans h₂'.symm) (h₁'.trans h₂.symm)

/-- The transposition formula fails wherever a state recurs: let both registers name the
recurring state, and the one history witnesses both conjuncts. -/
theorem transF_refuted_of_recur (τ : WorldHistory G) {s t : G.Duration} (hst : s < t)
    (h : τ.state s = τ.state t) :
    ∃ (M : TaskModel G) (r : ℕ → G.WorldState),
      ¬ HybridTruthAt M τ s r (HybridFormula.transF 0 1) := by
  refine ⟨⟨fun _ _ => False⟩, fun _ => τ.state s, ?_⟩
  simp only [HybridFormula.transF, neg_iff, and_iff, exist_iff, someFuture_iff, reg_iff, not_not]
  exact ⟨⟨τ, s, rfl, t, hst, h.symm⟩, ⟨τ, s, rfl, t, hst, h.symm⟩⟩

/-- **Definability**: the transposition formula at two registers is valid on a frame iff the
frame is recurrence-free. The forward direction is `transF_refuted_of_recur`, the backward one
`transF_valid`.

Paper: — (formalization-native; the paper states no formula expressing transposition) -/
theorem transF_defines (G : TaskFrame) [G.IsRegular] :
    G.HybridValidOn (HybridFormula.transF 0 1) ↔ G.RecurrenceFree := by
  constructor
  · intro h τ s t hst
    by_contra hne
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · obtain ⟨M, r, hr⟩ := transF_refuted_of_recur τ hlt hst
      exact hr (h M τ s r)
    · obtain ⟨M, r, hr⟩ := transF_refuted_of_recur τ hgt hst.symm
      exact hr (h M τ t r)
  · intro hG M τ t r; exact transF_valid hG M τ t r 0 1

/-- **Transposition with two distinct named states.** On the permissive frame `NF`, with register
`0` naming state `1` and register `1` naming state `0`, the history `1, 0` from time `0` and the
history `0, 1` from time `0` refute `¬(E(i ∧ F j) ∧ E(j ∧ F i))`. So the formula is refuted with
`i ≠ j` enforced, not only by letting the two registers coincide.

The clause `Iff`s are chained by hand: `simp` does not match a clause lemma whose binder is typed
at `NF.Duration` against a goal at `ℤ`. -/
theorem transF_refuted_distinct :
    ∃ (M : TaskModel NF) (τ : WorldHistory NF) (t : NF.Duration) (r : ℕ → NF.WorldState),
      r 0 ≠ r 1 ∧ ¬ HybridTruthAt M τ t r (HybridFormula.transF 0 1) := by
  refine ⟨⟨fun _ _ => False⟩, natHist (fun x => if x = 0 then 1 else 0), (0 : ℤ),
    (fun n => if n = 0 then 1 else 0 : ℕ → ℕ), ?_, ?_⟩
  · change (1 : ℕ) ≠ 0
    exact one_ne_zero
  · intro h
    refine (neg_iff _ _ _ _ _).1 h ((and_iff _ _ _ _ _ _).2 ⟨?_, ?_⟩)
    · exact (exist_iff _ _ _ _ _).2 ⟨natHist (fun x => if x = 0 then 1 else 0), (0 : ℤ),
        (and_iff _ _ _ _ _ _).2 ⟨rfl,
          (someFuture_iff _ _ _ _ _).2 ⟨(1 : ℤ), zero_lt_one, rfl⟩⟩⟩
    · exact (exist_iff _ _ _ _ _).2 ⟨natHist (fun x => if x = 1 then 1 else 0), (0 : ℤ),
        (and_iff _ _ _ _ _ _).2 ⟨rfl,
          (someFuture_iff _ _ _ _ _).2 ⟨(1 : ℤ), zero_lt_one, rfl⟩⟩⟩

/-- **At every frame class the transposition formula is not class-valid**: each class contains a
frame with recurrence. -/
theorem transF_not_validIn (fc : ProofSystem.FrameClass) :
    ¬ HybridValidIn fc (HybridFormula.transF 0 1) := by
  intro h
  obtain ⟨G, hG, hrec⟩ := exists_sat_not_recurrenceFree fc
  haveI := hG.isRegular
  exact hrec ((transF_defines G).1 (h G hG))

end FormalSystem.HybridLanguage
