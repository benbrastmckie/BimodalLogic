/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Agreement
import FormalSystem.PlusLanguage.PlusNonValidities

/-!
# The Branching L⁺ Certificate Is Incomplete for ℤ-Time Refutation

`Agreement.lean` proves the certificate *sound*: `plusRefutes_of_certifies` turns any family
meeting the six conditions into a genuine ℤ-time countermodel. This module proves the converse
direction **false**. There is a ℤ-time non-validity that no family meeting those conditions can
certify, at any time and at any size, so the L⁺ analogue of the deterministic route's
`exists_witnessFamily_of_not_validZTime` cannot be proved against the landed condition set.

## The obstruction, in three steps

1. `snce_share_congr` is the root cause. (C1') `PlusLocalCoherentShare`'s `snce` clause
   quantifies its predecessor universally over the `share`-class at the **same** time `t`.
   Reading the one clause twice — once at `i` with `k := j`, once at `j` with `k := j` by
   reflexivity — forces any two indices naming the same world state at `t` to agree on every
   `snce` formula of the closure. So in every presented model, past-tense truth is a function of
   the world state alone.

2. `not_plusCertifies_stabSnce` and `not_plusCertifies_stabSnce_premise` are the consequence.
   No `PlusSharingWitnessFamily` certifies any instance of the schema `(g S e) → ⊡(g S e)`,
   whether the schema sits in the conclusion list (`Del = [φ]`) or as a negated premise
   (`Γ = [¬φ]`, `Del = []`) — so restating the target is not an escape. The argument uses only
   (C1')'s `imp`/`bot`/`snce` clauses, (C4) and (C5): neither (C0) nor (C2') nor (C3) is touched,
   and no size bound appears anywhere in it.

3. `not_plusValidZTime_stabSnce` closes the gap. At `g := ⊤`, `e := p` the schema instance is
   `Pp → ⊡Pp`, and it is refuted on the permissive ℤ-frame `NF` by the same two histories
   `PlusNonValidities.refute_somePast_stab` uses. So the empty certificate class of step 2 is not
   the vacuous fact that the schema is valid; the certificate misses a real non-validity.

## What this does NOT show

**Soundness is untouched.** `plusTruth_iff_mem` and `plusRefutes_of_certifies` are unaffected: a
family that does meet the six conditions still presents a genuine countermodel. What fails is
*completeness* of the certificate class — the class is empty for these targets, not unsound on
them.

**Stability-modal decidability is not refuted.** Nothing here says `⊡` makes validity
undecidable. It says this particular certificate cannot be the route, because a decision
procedure built on enumerating certified families would answer "valid" for `Pp → ⊡Pp`.

**The `untl` side is defect-free by inspection, not by machine check.** (C1')'s `untl` clause
quantifies forward along a thread rather than over the `share`-class at the label's own time, so
the same collapse does not arise there. That is an inspection result recorded here as such; no
theorem below asserts it, and the positive obligation — exhibiting a full six-condition family
separating `Fp` from `⊡Fp` — belongs to the substrate redesign, not to the absence of a
refutation.

## Where the fix belongs

Not in a re-wording of (C1'). The rule of thumb the proof exposes is general: *any* condition
quantifying over the `share`-class at a label's **own** time forces class agreement on that
label, so weakening the `snce` clause's quantifier range while leaving the substrate alone just
relocates the problem. The repair is at the substrate level — `Thread`'s step field currently
reads `share (u+1) (idx u) (idx (u+1))`, tying one-step succession to the same equivalence that
carries the `⊡` quantifier, and separating those two roles needs a fourth periodic datum
alongside `rep`. `WitnessFamily/Sharing/README.md` records that requirement.

## Main Definitions

- `PlusSharingWitnessFamily.stabSnceTarget` — the schema `(g S e) → ⊡(g S e)`
- `PlusSharingWitnessFamily.notStabSnceTarget` — its negation, for the premise placement

## Main Results

- `PlusSharingWitnessFamily.snce_share_congr` — (C1') forces `share`-class agreement on every
  `snce` formula of the closure, at the class's own time
- `PlusSharingWitnessFamily.not_plusCertifies_stabSnce` — no family certifies
  `(g S e) → ⊡(g S e)` in the conclusion placement
- `PlusSharingWitnessFamily.not_plusCertifies_stabSnce_premise` — nor in the negated-premise
  placement
- `PlusSharingWitnessFamily.not_plusValidZTime_stabSnce` — `Pp → ⊡Pp` is a genuine ℤ-time
  non-validity
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.ProofSystem
open PlusTruth

namespace PlusSharingWitnessFamily

/-! ## The root cause: (C1')'s `snce` clause makes past truth state-determined -/

/--
**(C1') forces `share`-class agreement on past-tense labels.**

Two indices naming the same world state at `t` agree on every `snce` formula of the closure.
Both readings are of the *one* clause: at `i` with `k := j`, and at `j` with `k := j` by
reflexivity of `share`. No other condition is used, and no bound appears.

This is the sibling of `stabFaithful_share_congr`, and it is what makes the two of them
incompatible in the presence of a `snce` under a `stab`.

Paper: — (a formalization-native obstruction; the paper states no such result)
-/
theorem snce_share_congr {Γ Del : PlusContext} (S : PlusSharingWitnessFamily Γ Del)
    (hloc : S.PlusLocalCoherentShare) (t : ℤ) (i j : Fin S.lassos.length)
    (hij : S.share t i j) (g e : PlusFormula)
    (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) :
    (PlusFormula.snce g e ∈ S.L i t ↔ PlusFormula.snce g e ∈ S.L j t) :=
  ((hloc i t).2.2.2.2 j hij g e hc).trans
    ((hloc j t).2.2.2.2 j (S.share_refl t j) g e hc).symm

/-! ## The consequence: an empty certificate class -/

/-- The schema `(g S e) → ⊡(g S e)`, whose every instance is beyond the certificate's reach. -/
def stabSnceTarget (g e : PlusFormula) : PlusFormula :=
  .imp (PlusFormula.snce g e) (.stab (PlusFormula.snce g e))

/--
**No branching L⁺ certificate refutes any instance of `(g S e) → ⊡(g S e)`.**

At any time, at any size, with the schema in the conclusion list. (C4) puts the target's
negation-shaped obligation on the main index, (C1')'s `imp` clause unpacks it to `g S e` present
and `⊡(g S e)` absent, (C5) turns the absence into a `share`-class member missing `g S e`, and
`snce_share_congr` contradicts that. Nothing reads (C0), (C2') or (C3).

Paper: — (a formalization-native obstruction; the paper states no such result)
-/
theorem not_plusCertifies_stabSnce (g e : PlusFormula)
    (S : PlusSharingWitnessFamily [] [stabSnceTarget g e]) (t : ℤ) : ¬ S.PlusCertifies t := by
  classical
  rintro ⟨-, ⟨hloc, -⟩, -, htgt, hstab⟩
  set A : PlusFormula := PlusFormula.snce g e with hAdef
  have hcl_tgt : stabSnceTarget g e ∈ plusClosureOf (([] : PlusContext) ++ [stabSnceTarget g e]) :=
    plusConclusion_mem_closure (List.mem_singleton_self _)
  have hcl_stab :
      PlusFormula.stab A ∈ plusClosureOf (([] : PlusContext) ++ [stabSnceTarget g e]) :=
    plusClosureOf_imp_right hcl_tgt
  have hcl_A : A ∈ plusClosureOf (([] : PlusContext) ++ [stabSnceTarget g e]) :=
    plusClosureOf_stab hcl_stab
  set i := S.toPlusWitnessFamily.mainIdx with hidef
  have hnotL : PlusFormula.imp A (PlusFormula.stab A) ∉ S.L i t :=
    htgt.2 _ (List.mem_singleton_self _)
  have himp := (hloc i t).2.1 A (PlusFormula.stab A) hcl_tgt
  have h1 : ¬ (A ∈ S.L i t → PlusFormula.stab A ∈ S.L i t) := fun h => hnotL (himp.mpr h)
  have hAi : A ∈ S.L i t := by
    by_contra hno
    exact h1 (fun h => absurd h hno)
  have hSt : PlusFormula.stab A ∉ S.L i t := fun h => h1 (fun _ => h)
  rw [hstab i t A hcl_stab] at hSt
  have hex : ∃ j, S.share t i j ∧ A ∉ S.L j t := by
    by_contra hc
    refine hSt (fun j hj => ?_)
    by_contra hno
    exact hc ⟨j, hj, hno⟩
  obtain ⟨j, hij, hAj⟩ := hex
  exact hAj ((snce_share_congr S hloc t i j hij g e hcl_A).mp hAi)

/-- `¬((g S e) → ⊡(g S e))`, for the premise placement. -/
def notStabSnceTarget (g e : PlusFormula) : PlusFormula :=
  PlusFormula.imp (stabSnceTarget g e) PlusFormula.bot

/--
**The same, with the target as a negated premise** (`Γ = [¬φ]`, `Del = []`).

Moving the target from the conclusion list to the premise list is not an escape: the extra step
is one more `imp`-clause reading, against (C1')'s `bot` clause, to recover the same two facts the
conclusion placement got from (C4) directly.

Paper: — (a formalization-native obstruction; the paper states no such result)
-/
theorem not_plusCertifies_stabSnce_premise (g e : PlusFormula)
    (S : PlusSharingWitnessFamily [notStabSnceTarget g e] []) (t : ℤ) :
    ¬ S.PlusCertifies t := by
  classical
  rintro ⟨-, ⟨hloc, -⟩, -, htgt, hstab⟩
  set A : PlusFormula := PlusFormula.snce g e with hAdef
  set B : PlusFormula := PlusFormula.imp A (PlusFormula.stab A) with hBdef
  have hcl_n : notStabSnceTarget g e ∈
      plusClosureOf (([notStabSnceTarget g e] : PlusContext) ++ []) :=
    plusPremise_mem_closure (List.mem_singleton_self _)
  have hcl_B : B ∈ plusClosureOf (([notStabSnceTarget g e] : PlusContext) ++ []) :=
    plusClosureOf_imp_left hcl_n
  have hcl_stab : PlusFormula.stab A ∈
      plusClosureOf (([notStabSnceTarget g e] : PlusContext) ++ []) :=
    plusClosureOf_imp_right hcl_B
  have hcl_A : A ∈ plusClosureOf (([notStabSnceTarget g e] : PlusContext) ++ []) :=
    plusClosureOf_stab hcl_stab
  set i := S.toPlusWitnessFamily.mainIdx with hidef
  have hin : PlusFormula.imp B PlusFormula.bot ∈ S.L i t :=
    htgt.1 _ (List.mem_singleton_self _)
  have hbot : PlusFormula.bot ∉ S.L i t := (hloc i t).1
  have himpn := (hloc i t).2.1 B PlusFormula.bot hcl_n
  have hBnot : B ∉ S.L i t := fun hB => hbot (himpn.mp hin hB)
  have himp := (hloc i t).2.1 A (PlusFormula.stab A) hcl_B
  have h1 : ¬ (A ∈ S.L i t → PlusFormula.stab A ∈ S.L i t) := fun h => hBnot (himp.mpr h)
  have hAi : A ∈ S.L i t := by
    by_contra hno
    exact h1 (fun h => absurd h hno)
  have hSt : PlusFormula.stab A ∉ S.L i t := fun h => h1 (fun _ => h)
  rw [hstab i t A hcl_stab] at hSt
  have hex : ∃ j, S.share t i j ∧ A ∉ S.L j t := by
    by_contra hc
    refine hSt (fun j hj => ?_)
    by_contra hno
    exact hc ⟨j, hj, hno⟩
  obtain ⟨j, hij, hAj⟩ := hex
  exact hAj ((snce_share_congr S hloc t i j hij g e hcl_A).mp hAi)

/-! ## The schema is a genuine ℤ-time non-validity -/

/--
**`Pp → ⊡Pp` is not ℤ-time valid.**

The `stabSnceTarget` instance at `g := ⊤`, `e := p`, refuted on the permissive ℤ-frame `NF` with
the two histories of `PlusNonValidities.refute_somePast_stab`: one that was at state `0`
throughout, and one that was at state `1` at every negative time. They agree at `0`, so `⊡`
quantifies over both, and only the first has a past `p`.

Together with `not_plusCertifies_stabSnce` this is what makes the empty certificate class a
*completeness* failure rather than a vacuity.

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

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
