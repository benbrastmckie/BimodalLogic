/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples
import FormalSystem.PlusLanguage.PlusNonValidities

/-!
# The Two Limit Targets, and Their Genuine ℤ-Time Non-Validity

Two ℤ-time non-validities of `PlusFormula` are the specifications against which the L⁺
certificate class's *limits* are measured. This module states them in library form, proves each
is a real non-validity, and lands the closure-membership scaffolding the two limit theorems read.
It states no limit itself: the refutations live beside it and consume what is here.

## The primitive syntax, spelled out

Both targets are built from one atom `p` by abbreviations that the definitions below unfold to
on the nose, so that a reader can check the shape rather than trust it:

* `nextTrue p` is `Xp := p U⊥`, i.e. `untl ⊥ p` — "`p` at the next moment"
* `nextFalse p` is `X¬p := untl ⊥ (p → ⊥)`
* `someFuture p` is `Fp := untl ⊤ p`, with `⊤` the `PlusFormula.top` abbreviation `⊥ → ⊥`
* `someNextTrue p` is `⟐Xp := (⊡(Xp → ⊥)) → ⊥`, the stability-modal dual
* `someNextFalse p` is `⟐X¬p := (⊡(X¬p → ⊥)) → ⊥`
* `hopTarget p` is `□⟐Xp → (□⟐X¬p → ⊥)`
* `pumpTarget p` is `□⟐Xp → (□⟐X¬p → ((Fp → Fp) → ⊥))`

`hopTarget` says: it is not the case that every history has a state-agreeing history branching
to `p` next *and* one branching to `¬p` next. `pumpTarget` is `hopTarget` with a
vacuously-true-looking `Fp → Fp` inserted in the consequent; the insertion is not decoration —
it is what forces `Fp` and its guard `⊤` into the subformula closure, and hence what makes the
eventuality available to the argument that pumps a long `¬p`-postponement.

## Why the two membership blocks are not factored

`plusClosureOf` is indexed by the context, so `plusClosureOf ([] ++ [hopTarget p])` and
`plusClosureOf ([] ++ [pumpTarget p])` are different `Finset PlusFormula` values. Every
membership fact is a fact about one of them, and no lemma stated about either transports to the
other without a monotonicity principle that neither limit theorem needs. The two chains below are
therefore stated twice, at thirteen and seventeen steps; the shared prefix is a shared *shape*,
not a shared theorem.

The ℤ-time non-validity proofs *are* factored, through
`plusTruthAt_box_someNextTrue` and `plusTruthAt_box_someNextFalse`: both targets have the same
two antecedents, and on the permissive frame both hold at the constant history for the same
reason.

## Provenance

Transcription of Steps 1 and 2 of the compiled certificate-limit probes recorded with the second
research round on L⁺ compression; the non-validity proofs are unchanged in argument. The probes
are retained as the provenance record and are not superseded by this module: what changes here is
that the two targets become library declarations, parametric in the atom rather than fixed to a
concrete one, and the membership chains are named after the formula each places.

## Main Definitions

- `PlusSharingWitnessFamily.nextTrue`, `.nextFalse`, `.someFuture` — the tense abbreviations
- `PlusSharingWitnessFamily.someNextTrue`, `.someNextFalse` — their stability-modal duals
- `PlusSharingWitnessFamily.hopTarget` — the target no hop-free family can certify
- `PlusSharingWitnessFamily.pumpTarget` — the target no family of the landed class can certify
- `PlusSharingWitnessFamily.hopClosure`, `.pumpClosure` — the two subformula closures

## Main Results

- `PlusSharingWitnessFamily.not_plusValidZTime_hopTarget` — `hopTarget` is a genuine ℤ-time
  non-validity
- `PlusSharingWitnessFamily.not_plusValidZTime_pumpTarget` — and so is `pumpTarget`
- `PlusSharingWitnessFamily.plusTruthAt_box_someNextTrue`,
  `.plusTruthAt_box_someNextFalse` — the two shared antecedents, true on the permissive frame
- the two membership chains, each named `…_mem_hopClosure` / `…_mem_pumpClosure` after the
  formula it places
- `PlusSharingWitnessFamily.untl_mem_hopClosure`, `.untl_mem_pumpClosure` — the closures' `untl`
  members, characterized rather than assumed, with the guard corollaries
  `.untl_guard_eq_bot_of_mem_hopClosure` and `.untl_guard_eq_bot_or_top_of_mem_pumpClosure`

## Tags

plus-language · certificate · incompleteness · stability-modal · target
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.ProofSystem
open PlusTruth

namespace PlusSharingWitnessFamily

/-! ## The primitive syntax -/

/-- `Xp := untl ⊥ p` — `p` holds at the next moment. -/
def nextTrue (p : Atom) : PlusFormula :=
  PlusFormula.untl PlusFormula.bot (PlusFormula.atom p)

/-- `X¬p := untl ⊥ (p → ⊥)` — `p` fails at the next moment. -/
def nextFalse (p : Atom) : PlusFormula :=
  PlusFormula.untl PlusFormula.bot (PlusFormula.imp (PlusFormula.atom p) PlusFormula.bot)

/-- `Fp := untl ⊤ p` — `p` holds at some strictly future moment. -/
def someFuture (p : Atom) : PlusFormula :=
  PlusFormula.untl PlusFormula.top (PlusFormula.atom p)

/-- `⟐Xp := (⊡(Xp → ⊥)) → ⊥` — some state-agreeing history has `p` next. -/
def someNextTrue (p : Atom) : PlusFormula :=
  PlusFormula.imp (PlusFormula.stab (PlusFormula.imp (nextTrue p) PlusFormula.bot))
    PlusFormula.bot

/-- `⟐X¬p := (⊡(X¬p → ⊥)) → ⊥` — some state-agreeing history has `¬p` next. -/
def someNextFalse (p : Atom) : PlusFormula :=
  PlusFormula.imp (PlusFormula.stab (PlusFormula.imp (nextFalse p) PlusFormula.bot))
    PlusFormula.bot

/-- `□⟐Xp → (□⟐X¬p → ⊥)`: the target with no long-range eventuality. -/
def hopTarget (p : Atom) : PlusFormula :=
  PlusFormula.imp (PlusFormula.box (someNextTrue p))
    (PlusFormula.imp (PlusFormula.box (someNextFalse p)) PlusFormula.bot)

/-- `□⟐Xp → (□⟐X¬p → ((Fp → Fp) → ⊥))`: `hopTarget` with the eventuality `Fp` forced into the
closure by an otherwise inert `Fp → Fp`. -/
def pumpTarget (p : Atom) : PlusFormula :=
  PlusFormula.imp (PlusFormula.box (someNextTrue p))
    (PlusFormula.imp (PlusFormula.box (someNextFalse p))
      (PlusFormula.imp (PlusFormula.imp (someFuture p) (someFuture p)) PlusFormula.bot))

/-! ## The two shared antecedents on the permissive frame

Both targets are refuted at the constant-`0` history of `PlusLanguage.NF` at time `0`, and both
antecedents hold there for the same reason: `NF` admits *every* function `ℤ → ℕ` as a history, so
from any history `σ` the two one-step variants of `σ` that agree with it at `0` and sit at state
`0` (resp. state `1`) at time `1` are themselves histories. Under `natModel` an atom is true
exactly at world state `0`, so those two variants witness `Xp` and `X¬p` respectively.
-/

/--
**`□⟐Xp` holds at the constant history and time `0` of the permissive frame.**

Paper: — (a formalization-native refutation; the paper states no such result)
-/
theorem plusTruthAt_box_someNextTrue (p : Atom) :
    PlusTruthAt natModel (natHist fun _ => 0) 0 (PlusFormula.box (someNextTrue p)) := by
  intro σ hstab
  refine hstab (natHist fun s => if s = 1 then 0 else (show ℕ from σ.state 0)) ?_ ?_
  · change σ.state 0 = (if (0 : ℤ) = 1 then 0 else (show ℕ from σ.state 0))
    simp
  · refine ⟨(1 : ℤ), (by decide : (0 : ℤ) < 1), ?_, ?_⟩
    · change (if (1 : ℤ) = 1 then (0 : ℕ) else (show ℕ from σ.state 0)) = 0
      simp
    · intro r h0 h1
      exfalso
      have h0' : (0 : ℤ) < (show ℤ from r) := h0
      have h1' : (show ℤ from r) < (1 : ℤ) := h1
      generalize (show ℤ from r) = z at h0' h1'
      omega

/--
**`□⟐X¬p` holds at the constant history and time `0` of the permissive frame.**

Paper: — (a formalization-native refutation; the paper states no such result)
-/
theorem plusTruthAt_box_someNextFalse (p : Atom) :
    PlusTruthAt natModel (natHist fun _ => 0) 0 (PlusFormula.box (someNextFalse p)) := by
  intro σ hstab
  refine hstab (natHist fun s => if s = 1 then 1 else (show ℕ from σ.state 0)) ?_ ?_
  · change σ.state 0 = (if (0 : ℤ) = 1 then 1 else (show ℕ from σ.state 0))
    simp
  · refine ⟨(1 : ℤ), (by decide : (0 : ℤ) < 1), ?_, ?_⟩
    · intro hp
      change (if (1 : ℤ) = 1 then (1 : ℕ) else (show ℕ from σ.state 0)) = 0 at hp
      simp at hp
    · intro r h0 h1
      exfalso
      have h0' : (0 : ℤ) < (show ℤ from r) := h0
      have h1' : (show ℤ from r) < (1 : ℤ) := h1
      generalize (show ℤ from r) = z at h0' h1'
      omega

/-! ## Each target is a genuine ℤ-time non-validity -/

/--
**`hopTarget p` is not ℤ-time valid.**

Refuted on the permissive ℤ-frame `PlusLanguage.NF` with `natModel`, at the constant history and
time `0`: both antecedents hold there, and the consequent is `⊥`.

Paper: — (a formalization-native refutation; the paper states no such result)
-/
theorem not_plusValidZTime_hopTarget (p : Atom) : ¬ PlusValidZTime (hopTarget p) := by
  intro h
  have hsat : FrameClass.ZTime.Sat FormalSystem.PlusLanguage.NF :=
    ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩
  exact h FormalSystem.PlusLanguage.NF hsat natModel (natHist fun _ => 0) 0
    (plusTruthAt_box_someNextTrue p) (plusTruthAt_box_someNextFalse p)

/--
**`pumpTarget p` is not ℤ-time valid.**

The same refutation as `not_plusValidZTime_hopTarget`, with the inert `Fp → Fp` discharged by
identity — which is exactly why inserting it costs nothing semantically while changing the
closure.

Paper: — (a formalization-native refutation; the paper states no such result)
-/
theorem not_plusValidZTime_pumpTarget (p : Atom) : ¬ PlusValidZTime (pumpTarget p) := by
  intro h
  have hsat : FrameClass.ZTime.Sat FormalSystem.PlusLanguage.NF :=
    ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩
  exact h FormalSystem.PlusLanguage.NF hsat natModel (natHist fun _ => 0) 0
    (plusTruthAt_box_someNextTrue p) (plusTruthAt_box_someNextFalse p) (fun hF => hF)

/-! ## The closure of `hopTarget`

Thirteen steps, each naming the formula it places. The chain is what lets a limit theorem read
(C1'), (C3), (C4) and (C5) at each of these labels: every clause of `PlusLocalCoherentShare` is
guarded by closure membership.
-/

/-- The singleton deletion whose closure the hop-free limit reads. -/
abbrev hopDelta (p : Atom) : PlusContext := [hopTarget p]

/-- The subformula closure the hop-free limit reads. -/
abbrev hopClosure (p : Atom) : Finset PlusFormula :=
  plusClosureOf (([] : PlusContext) ++ hopDelta p)

/-- `□⟐Xp → (□⟐X¬p → ⊥)` is in its own closure. -/
theorem hopTarget_mem_hopClosure (p : Atom) : hopTarget p ∈ hopClosure p :=
  plusConclusion_mem_closure (List.mem_singleton_self _)

/-- `□⟐Xp` is in the closure of `hopTarget`. -/
theorem boxSomeNextTrue_mem_hopClosure (p : Atom) :
    PlusFormula.box (someNextTrue p) ∈ hopClosure p :=
  plusClosureOf_imp_left (hopTarget_mem_hopClosure p)

/-- `□⟐X¬p → ⊥` is in the closure of `hopTarget`. -/
theorem impBoxSomeNextFalse_mem_hopClosure (p : Atom) :
    PlusFormula.imp (PlusFormula.box (someNextFalse p)) PlusFormula.bot ∈ hopClosure p :=
  plusClosureOf_imp_right (hopTarget_mem_hopClosure p)

/-- `□⟐X¬p` is in the closure of `hopTarget`. -/
theorem boxSomeNextFalse_mem_hopClosure (p : Atom) :
    PlusFormula.box (someNextFalse p) ∈ hopClosure p :=
  plusClosureOf_imp_left (impBoxSomeNextFalse_mem_hopClosure p)

/-- `⟐Xp` is in the closure of `hopTarget`. -/
theorem someNextTrue_mem_hopClosure (p : Atom) : someNextTrue p ∈ hopClosure p :=
  plusClosureOf_box (boxSomeNextTrue_mem_hopClosure p)

/-- `⟐X¬p` is in the closure of `hopTarget`. -/
theorem someNextFalse_mem_hopClosure (p : Atom) : someNextFalse p ∈ hopClosure p :=
  plusClosureOf_box (boxSomeNextFalse_mem_hopClosure p)

/-- `⊡(Xp → ⊥)` is in the closure of `hopTarget`. -/
theorem stabNotNextTrue_mem_hopClosure (p : Atom) :
    PlusFormula.stab (PlusFormula.imp (nextTrue p) PlusFormula.bot) ∈ hopClosure p :=
  plusClosureOf_imp_left (someNextTrue_mem_hopClosure p)

/-- `⊡(X¬p → ⊥)` is in the closure of `hopTarget`. -/
theorem stabNotNextFalse_mem_hopClosure (p : Atom) :
    PlusFormula.stab (PlusFormula.imp (nextFalse p) PlusFormula.bot) ∈ hopClosure p :=
  plusClosureOf_imp_left (someNextFalse_mem_hopClosure p)

/-- `Xp → ⊥` is in the closure of `hopTarget`. -/
theorem notNextTrue_mem_hopClosure (p : Atom) :
    PlusFormula.imp (nextTrue p) PlusFormula.bot ∈ hopClosure p :=
  plusClosureOf_stab (stabNotNextTrue_mem_hopClosure p)

/-- `X¬p → ⊥` is in the closure of `hopTarget`. -/
theorem notNextFalse_mem_hopClosure (p : Atom) :
    PlusFormula.imp (nextFalse p) PlusFormula.bot ∈ hopClosure p :=
  plusClosureOf_stab (stabNotNextFalse_mem_hopClosure p)

/-- `Xp` is in the closure of `hopTarget`. -/
theorem nextTrue_mem_hopClosure (p : Atom) : nextTrue p ∈ hopClosure p :=
  plusClosureOf_imp_left (notNextTrue_mem_hopClosure p)

/-- `X¬p` is in the closure of `hopTarget`. -/
theorem nextFalse_mem_hopClosure (p : Atom) : nextFalse p ∈ hopClosure p :=
  plusClosureOf_imp_left (notNextFalse_mem_hopClosure p)

/-- `p → ⊥` is in the closure of `hopTarget`. -/
theorem notAtom_mem_hopClosure (p : Atom) :
    PlusFormula.imp (PlusFormula.atom p) PlusFormula.bot ∈ hopClosure p :=
  plusClosureOf_untl_left (nextFalse_mem_hopClosure p)

/-! ### The closure's `untl` shape

The limit argument for `hopTarget` reasons about the labels a family may carry at an `untl`
formula, and every clause it reads is guarded by closure membership. What the closure actually
contains is therefore worth stating rather than assuming: `hopClosure p` has exactly two `untl`
members, `Xp` and `X¬p`, and both are guarded by `⊥`. The converse inclusion is
`nextTrue_mem_hopClosure` and `nextFalse_mem_hopClosure` above, so the pair is a full
characterization.
-/

/--
**The `untl` members of `hopClosure p` are exactly `Xp` and `X¬p`.**

Stated in the strong guard-and-event form rather than as the guard-only fact the argument
consumes, because the strong form is what the closure computation actually yields.
-/
theorem untl_mem_hopClosure (p : Atom) {g e : PlusFormula}
    (h : PlusFormula.untl g e ∈ hopClosure p) :
    (g = PlusFormula.bot ∧ e = PlusFormula.atom p) ∨
      (g = PlusFormula.bot ∧ e = PlusFormula.imp (PlusFormula.atom p) PlusFormula.bot) := by
  simpa [hopClosure, hopDelta, hopTarget, someNextTrue, someNextFalse, nextTrue, nextFalse,
    plusClosureOf, plusSubformulaClosure, PlusFormula.subformulas] using h

/-- Every `untl` member of `hopClosure p` is guarded by `⊥`: `hopTarget` has no eventuality. -/
theorem untl_guard_eq_bot_of_mem_hopClosure (p : Atom) {g e : PlusFormula}
    (h : PlusFormula.untl g e ∈ hopClosure p) : g = PlusFormula.bot := by
  rcases untl_mem_hopClosure p h with ⟨h, -⟩ | ⟨h, -⟩ <;> exact h

/-! ## The closure of `pumpTarget`

Seventeen steps: the thirteen of the hop chain re-derived in the other closure, plus the four
that the inserted `Fp → Fp` adds — `(Fp → Fp) → ⊥`, `Fp → Fp`, `Fp`, and `Fp`'s guard `⊤`. The
last is the one the pumping argument needs: `⊤`'s membership is what lets a family's labelling be
read as carrying the guard at every position, so a postponed `Fp` can be unfolded arbitrarily far.
-/

/-- The singleton deletion whose closure the compression limit reads. -/
abbrev pumpDelta (p : Atom) : PlusContext := [pumpTarget p]

/-- The subformula closure the compression limit reads. -/
abbrev pumpClosure (p : Atom) : Finset PlusFormula :=
  plusClosureOf (([] : PlusContext) ++ pumpDelta p)

/-- `pumpTarget` is in its own closure. -/
theorem pumpTarget_mem_pumpClosure (p : Atom) : pumpTarget p ∈ pumpClosure p :=
  plusConclusion_mem_closure (List.mem_singleton_self _)

/-- `□⟐Xp` is in the closure of `pumpTarget`. -/
theorem boxSomeNextTrue_mem_pumpClosure (p : Atom) :
    PlusFormula.box (someNextTrue p) ∈ pumpClosure p :=
  plusClosureOf_imp_left (pumpTarget_mem_pumpClosure p)

/-- `□⟐X¬p → ((Fp → Fp) → ⊥)` is in the closure of `pumpTarget`. -/
theorem impBoxSomeNextFalse_mem_pumpClosure (p : Atom) :
    PlusFormula.imp (PlusFormula.box (someNextFalse p))
        (PlusFormula.imp (PlusFormula.imp (someFuture p) (someFuture p)) PlusFormula.bot) ∈
      pumpClosure p :=
  plusClosureOf_imp_right (pumpTarget_mem_pumpClosure p)

/-- `□⟐X¬p` is in the closure of `pumpTarget`. -/
theorem boxSomeNextFalse_mem_pumpClosure (p : Atom) :
    PlusFormula.box (someNextFalse p) ∈ pumpClosure p :=
  plusClosureOf_imp_left (impBoxSomeNextFalse_mem_pumpClosure p)

/-- `(Fp → Fp) → ⊥` is in the closure of `pumpTarget`. -/
theorem notIdFuture_mem_pumpClosure (p : Atom) :
    PlusFormula.imp (PlusFormula.imp (someFuture p) (someFuture p)) PlusFormula.bot ∈
      pumpClosure p :=
  plusClosureOf_imp_right (impBoxSomeNextFalse_mem_pumpClosure p)

/-- `Fp → Fp` is in the closure of `pumpTarget`. -/
theorem idFuture_mem_pumpClosure (p : Atom) :
    PlusFormula.imp (someFuture p) (someFuture p) ∈ pumpClosure p :=
  plusClosureOf_imp_left (notIdFuture_mem_pumpClosure p)

/-- `Fp` is in the closure of `pumpTarget`. -/
theorem someFuture_mem_pumpClosure (p : Atom) : someFuture p ∈ pumpClosure p :=
  plusClosureOf_imp_left (idFuture_mem_pumpClosure p)

/-- `⊤`, the guard of `Fp`, is in the closure of `pumpTarget`. -/
theorem top_mem_pumpClosure (p : Atom) : PlusFormula.top ∈ pumpClosure p :=
  plusClosureOf_untl_right (someFuture_mem_pumpClosure p)

/-- `⟐Xp` is in the closure of `pumpTarget`. -/
theorem someNextTrue_mem_pumpClosure (p : Atom) : someNextTrue p ∈ pumpClosure p :=
  plusClosureOf_box (boxSomeNextTrue_mem_pumpClosure p)

/-- `⟐X¬p` is in the closure of `pumpTarget`. -/
theorem someNextFalse_mem_pumpClosure (p : Atom) : someNextFalse p ∈ pumpClosure p :=
  plusClosureOf_box (boxSomeNextFalse_mem_pumpClosure p)

/-- `⊡(Xp → ⊥)` is in the closure of `pumpTarget`. -/
theorem stabNotNextTrue_mem_pumpClosure (p : Atom) :
    PlusFormula.stab (PlusFormula.imp (nextTrue p) PlusFormula.bot) ∈ pumpClosure p :=
  plusClosureOf_imp_left (someNextTrue_mem_pumpClosure p)

/-- `⊡(X¬p → ⊥)` is in the closure of `pumpTarget`. -/
theorem stabNotNextFalse_mem_pumpClosure (p : Atom) :
    PlusFormula.stab (PlusFormula.imp (nextFalse p) PlusFormula.bot) ∈ pumpClosure p :=
  plusClosureOf_imp_left (someNextFalse_mem_pumpClosure p)

/-- `Xp → ⊥` is in the closure of `pumpTarget`. -/
theorem notNextTrue_mem_pumpClosure (p : Atom) :
    PlusFormula.imp (nextTrue p) PlusFormula.bot ∈ pumpClosure p :=
  plusClosureOf_stab (stabNotNextTrue_mem_pumpClosure p)

/-- `X¬p → ⊥` is in the closure of `pumpTarget`. -/
theorem notNextFalse_mem_pumpClosure (p : Atom) :
    PlusFormula.imp (nextFalse p) PlusFormula.bot ∈ pumpClosure p :=
  plusClosureOf_stab (stabNotNextFalse_mem_pumpClosure p)

/-- `Xp` is in the closure of `pumpTarget`. -/
theorem nextTrue_mem_pumpClosure (p : Atom) : nextTrue p ∈ pumpClosure p :=
  plusClosureOf_imp_left (notNextTrue_mem_pumpClosure p)

/-- `X¬p` is in the closure of `pumpTarget`. -/
theorem nextFalse_mem_pumpClosure (p : Atom) : nextFalse p ∈ pumpClosure p :=
  plusClosureOf_imp_left (notNextFalse_mem_pumpClosure p)

/-- `p → ⊥` is in the closure of `pumpTarget`. -/
theorem notAtom_mem_pumpClosure (p : Atom) :
    PlusFormula.imp (PlusFormula.atom p) PlusFormula.bot ∈ pumpClosure p :=
  plusClosureOf_untl_left (nextFalse_mem_pumpClosure p)

/-! ### The closure's `untl` shape

The same statement for `pumpClosure p`, and the one place the two targets genuinely differ:
`pumpClosure p` has a *third* `untl` member, `Fp`, and its guard is `⊤` rather than `⊥`. That is
the whole content of the insertion — an `untl` whose guard is satisfiable everywhere can be
unfolded arbitrarily far, so a postponement of `p` along a thread is a postponement the labelling
must keep carrying, and a finite eventually-periodic labelling can be pumped past any bound it
declares. `hopTarget`'s two `untl` members, guarded by `⊥`, admit no such postponement, which is
why the hop-free limit and the compression limit are independent rather than one implying the
other.
-/

/-- `⊤` is `⊥ → ⊥`, an implication, so no `untl` formula is among its subformulas. This is what
stops `Fp`'s guard from contributing a fourth `untl` member to `pumpClosure`. -/
theorem untl_not_mem_top_subformulas {g e : PlusFormula} :
    PlusFormula.untl g e ∉ PlusFormula.top.subformulas := by
  simp [PlusFormula.top, PlusFormula.subformulas]

/--
**The `untl` members of `pumpClosure p` are exactly `Xp`, `X¬p` and `Fp`.**

The third disjunct is the eventuality: guard `⊤`, not `⊥`. `⊤` contributes no further `untl`
member, by `untl_not_mem_top_subformulas`.
-/
theorem untl_mem_pumpClosure (p : Atom) {g e : PlusFormula}
    (h : PlusFormula.untl g e ∈ pumpClosure p) :
    (g = PlusFormula.bot ∧ e = PlusFormula.atom p) ∨
      (g = PlusFormula.bot ∧ e = PlusFormula.imp (PlusFormula.atom p) PlusFormula.bot) ∨
      (g = PlusFormula.top ∧ e = PlusFormula.atom p) := by
  simpa [pumpClosure, pumpDelta, pumpTarget, someNextTrue, someNextFalse, nextTrue, nextFalse,
    someFuture, plusClosureOf, plusSubformulaClosure, PlusFormula.subformulas,
    untl_not_mem_top_subformulas] using h

/-- Every `untl` member of `pumpClosure p` is guarded by `⊥` or by `⊤`. -/
theorem untl_guard_eq_bot_or_top_of_mem_pumpClosure (p : Atom) {g e : PlusFormula}
    (h : PlusFormula.untl g e ∈ pumpClosure p) :
    g = PlusFormula.bot ∨ g = PlusFormula.top := by
  rcases untl_mem_pumpClosure p h with ⟨h, -⟩ | ⟨h, -⟩ | ⟨h, -⟩
  · exact Or.inl h
  · exact Or.inl h
  · exact Or.inr h

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
