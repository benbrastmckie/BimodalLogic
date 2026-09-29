/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Agreement
import FormalSystem.PlusLanguage.PlusNonValidities

/-!
# The Two Stability Targets, and Their Genuine ℤ-Time Non-Validity

This module records the two schema instances that drove the substrate redesign, and the fact
that each is a real ℤ-time non-validity. It no longer records an obstruction, because there is
no longer one to record.

## What this module used to say, and why it no longer says it

Until the `trans` substrate landed, (C1') `PlusLocalCoherentShare`'s `snce` clause quantified
its predecessor universally over the `share`-class at the **same** time `t`. Reading the one
clause twice — once at `i` with `k := j`, once at `j` with `k := j` by reflexivity of `share` —
forced any two indices naming one world state at `t` to agree on every `snce` formula of the
closure. Past-tense truth was therefore a function of the world state alone, which is exactly
what `⊡` quantifies over, so no six-condition family could certify any instance of
`(g S e) → ⊡(g S e)`. The `untl` side carried the same defect displaced by one step.

Five declarations recorded that: `snce_share_congr`, `untl_shift_share_congr`,
`not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise` and
`not_plusCertifies_stabUntl`. All five are **retired**, and their retirement is the evidence the
redesign worked rather than an unexplained deletion. The two clauses now quantify over
`trans`, the arrival-pruned succession relation, which is strictly finer than state-identity at
a time: two indices naming one state at `t` need not have a common predecessor, so the doubled
reading that produced the congruence no longer type-checks. `Sharing/Agreement.lean`'s
`snce_pred_congr` and `untl_succ_congr` state exactly how much agreement the clauses still
force, and why that residue is semantically forced rather than a relapse.

The corresponding rows were removed from `scripts/check-module-invariants.sh`'s C2 baseline and
from `docs/theorem-index.md` in the same edit, so the tree and the baselines never disagreed.

## What survives, and why it is still worth stating

The three target schemas and the two non-validity theorems. `not_plusValidZTime_stabSnce` and
`not_plusValidZTime_stabUntl` were never consequences of the defect — they are facts about
ℤ-time frames — and they are what made the old empty certificate class a *completeness* failure
rather than a vacuity. They now serve the opposite role: they are the targets the certificates
of `PlusWitnessFamily/Examples.lean` must actually refute, and so they are the specification the
redesign is measured against.

## Soundness was never at issue

`plusTruth_iff_mem` and `plusRefutes_of_certifies` are unchanged in statement, across the whole
redesign. A family meeting the six conditions always presented a genuine countermodel; what
failed was completeness of the certificate class on these two targets.

## Main Definitions

- `PlusSharingWitnessFamily.stabSnceTarget` — the schema `(g S e) → ⊡(g S e)`
- `PlusSharingWitnessFamily.notStabSnceTarget` — its negation, for the premise placement
- `PlusSharingWitnessFamily.stabUntlTarget` — the `untl`-side target `Fp → (¬p → ⊡Fp)`

## Main Results

- `PlusSharingWitnessFamily.not_plusValidZTime_stabSnce` — `Pp → ⊡Pp` is a genuine ℤ-time
  non-validity
- `PlusSharingWitnessFamily.not_plusValidZTime_stabUntl` — and so is `Fp → (¬p → ⊡Fp)`
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.ProofSystem
open PlusTruth

namespace PlusSharingWitnessFamily

/-! ## The three targets -/

/-- The schema `(g S e) → ⊡(g S e)`, the `snce`-side target of the redesign. -/
def stabSnceTarget (g e : PlusFormula) : PlusFormula :=
  .imp (PlusFormula.snce g e) (.stab (PlusFormula.snce g e))

/-- `¬((g S e) → ⊡(g S e))`, for the premise placement. -/
def notStabSnceTarget (g e : PlusFormula) : PlusFormula :=
  PlusFormula.imp (stabSnceTarget g e) PlusFormula.bot

/-- The `untl`-side target `Fp → (¬p → ⊡Fp)`. -/
def stabUntlTarget (p : Atom) : PlusFormula :=
  .imp (PlusFormula.untl PlusFormula.top (.atom p))
    (.imp (.imp (.atom p) .bot) (.stab (PlusFormula.untl PlusFormula.top (.atom p))))

/-! ## The schema is a genuine ℤ-time non-validity -/

/--
**`Pp → ⊡Pp` is not ℤ-time valid.**

The `stabSnceTarget` instance at `g := ⊤`, `e := p`, refuted on the permissive ℤ-frame `NF` with
the two histories of `PlusNonValidities.refute_somePast_stab`: one that was at state `0`
throughout, and one that was at state `1` at every negative time. They agree at `0`, so `⊡`
quantifies over both, and only the first has a past `p`.

This is the target the `snce`-side certificate must refute. Before the substrate redesign it
served the opposite purpose: together with the retired `not_plusCertifies_stabSnce` it made the
then-empty certificate class a *completeness* failure rather than a vacuity.

Paper: — (a formalization-native obstruction; the paper states no such result)
-/
theorem not_plusValidZTime_stabSnce (p : Atom) :
    ¬ PlusValidZTime (stabSnceTarget PlusFormula.top (PlusFormula.atom p)) := by
  intro h
  have hsat : FrameClass.ZTime.Sat FormalSystem.PlusLanguage.NF :=
    ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩
  have hv := h FormalSystem.PlusLanguage.NF hsat natModel (natHist fun _ => 0) 0
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0 (somePast (PlusFormula.atom p)) := by
    rw [somePast_iff]
    exact ⟨(-1 : ℤ), (by decide : (-1 : ℤ) < 0), (rfl : (0 : ℕ) = 0)⟩
  have hB := hv hA (natHist fun s => if s < 0 then 1 else 0)
    (by change (0 : ℕ) = (if (0 : ℤ) < 0 then 1 else 0); simp)
  rw [show PlusFormula.snce PlusFormula.top (PlusFormula.atom p)
      = somePast (PlusFormula.atom p) from rfl, somePast_iff] at hB
  obtain ⟨s, hs, hat⟩ := hB
  rw [atom_iff] at hat
  have hs' : (s : ℤ) < 0 := hs
  have v' : (if (s : ℤ) < 0 then (1 : ℕ) else 0) = 0 := hat
  rw [if_pos hs'] at v'
  exact one_ne_zero v'

/--
**`Fp → (¬p → ⊡Fp)` is not ℤ-time valid.**

The `untl`-side twin of `not_plusValidZTime_stabSnce`, on the same permissive ℤ-frame `NF`. The
history that sits at state `1` up to time `0` and at state `0` from time `1` on has a future `p`
and no present `p` at time `0`; the constant-`1` history agrees with it at `0` and has no future
`p` at all. This is the target the `untl`-side certificate must refute; before the substrate
redesign it made the then-empty certificate class a completeness failure on this side too.

Paper: — (a formalization-native obstruction; the paper states no such result)
-/
theorem not_plusValidZTime_stabUntl (p : Atom) : ¬ PlusValidZTime (stabUntlTarget p) := by
  intro h
  have hsat : FrameClass.ZTime.Sat FormalSystem.PlusLanguage.NF :=
    ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩
  -- One history is at state 1 at times ≤ 0 and at state 0 from time 1 on: `Fp` holds at 0,
  -- and `p` fails at 0.  The constant-1 history agrees with it at 0 and has no future `p`.
  have hv := h FormalSystem.PlusLanguage.NF hsat natModel
    (natHist fun s => if s ≤ 0 then 1 else 0) 0
  have hA : PlusTruthAt natModel (natHist fun s => if s ≤ 0 then 1 else 0) 0
      (someFuture (PlusFormula.atom p)) := by
    rw [someFuture_iff]
    refine ⟨(1 : ℤ), (by decide : (0 : ℤ) < 1), ?_⟩
    change (if (1 : ℤ) ≤ 0 then (1 : ℕ) else 0) = 0
    simp
  have hnp : PlusTruthAt natModel (natHist fun s => if s ≤ 0 then 1 else 0) 0
      (PlusFormula.imp (.atom p) .bot) := by
    intro hp
    change (if (0 : ℤ) ≤ 0 then (1 : ℕ) else 0) = 0 at hp
    simp at hp
  have hB := hv hA hnp (natHist fun _ => 1)
    (by change (if (0 : ℤ) ≤ 0 then (1 : ℕ) else 0) = 1; simp)
  rw [show PlusFormula.untl PlusFormula.top (PlusFormula.atom p)
      = someFuture (PlusFormula.atom p) from rfl, someFuture_iff] at hB
  obtain ⟨s, _, hat⟩ := hB
  change (1 : ℕ) = 0 at hat
  exact one_ne_zero hat

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
