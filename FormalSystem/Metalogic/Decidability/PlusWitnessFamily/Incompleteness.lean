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

## The obstruction, in four steps

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

4. `untl_shift_share_congr`, `not_plusCertifies_stabUntl` and `not_plusValidZTime_stabUntl` do
   all three again on the future-tense side. The `untl` clause quantifies its successor over the
   `share`-class at `t+1` rather than at `t`, so the collapse is displaced by one step rather
   than avoided: reading the clause at `t-1` recovers it. Both temporal directions are therefore
   closed, which is what rules out re-timing one clause to match the other as a repair.

## What this does NOT show

**Soundness is untouched.** `plusTruth_iff_mem` and `plusRefutes_of_certifies` are unaffected: a
family that does meet the six conditions still presents a genuine countermodel. What fails is
*completeness* of the certificate class — the class is empty for these targets, not unsound on
them.

**Stability-modal decidability is not refuted.** Nothing here says `⊡` makes validity
undecidable. It says this particular certificate cannot be the route, because a decision
procedure built on enumerating certified families would answer "valid" for `Pp → ⊡Pp`.

**The `untl` side is not an escape either, and this is now machine-checked.**
`untl_shift_share_congr` and `not_plusCertifies_stabUntl` record the same obstruction on the
future-tense side, displaced by one step, and `not_plusValidZTime_stabUntl` makes that emptiness
a completeness failure too. An earlier version of this docstring called the `untl` half
defect-free by inspection; that claim was wrong, and the two theorems replacing it are what
corrects the record.

## Where the fix belongs

Not in a re-wording of (C1'), and not in re-timing one clause's quantifier to match the other's.
The rule of thumb the two proofs expose is general: *any* condition quantifying over the one-step
reach of a position collapses whenever that reach is a whole `share`-class, at either time. The
`snce` clause quantifies its predecessor over the class at `t` and the `untl` clause its
successor over the class at `t+1`; both classes are `share`-classes, so both collapse, and
trading one timing for the other just trades one side's defect for the other's.

The repair is at the substrate level — `Thread`'s step field currently reads
`share (u+1) (idx u) (idx (u+1))`, tying one-step succession to the same equivalence that carries
the `⊡` quantifier, and separating those two roles needs a fourth periodic datum alongside `rep`.
`WitnessFamily/Sharing/README.md` records that requirement.

## Main Definitions

- `PlusSharingWitnessFamily.stabSnceTarget` — the schema `(g S e) → ⊡(g S e)`
- `PlusSharingWitnessFamily.notStabSnceTarget` — its negation, for the premise placement
- `PlusSharingWitnessFamily.stabUntlTarget` — the `untl`-side target `Fp → (¬p → ⊡Fp)`

## Main Results

- `PlusSharingWitnessFamily.snce_share_congr` — (C1') forces `share`-class agreement on every
  `snce` formula of the closure, at the class's own time
- `PlusSharingWitnessFamily.not_plusCertifies_stabSnce` — no family certifies
  `(g S e) → ⊡(g S e)` in the conclusion placement
- `PlusSharingWitnessFamily.not_plusCertifies_stabSnce_premise` — nor in the negated-premise
  placement
- `PlusSharingWitnessFamily.not_plusValidZTime_stabSnce` — `Pp → ⊡Pp` is a genuine ℤ-time
  non-validity
- `PlusSharingWitnessFamily.untl_shift_share_congr` — the same forced agreement on the `untl`
  side, one step shifted
- `PlusSharingWitnessFamily.not_plusCertifies_stabUntl` — no family certifies
  `Fp → (¬p → ⊡Fp)` either
- `PlusSharingWitnessFamily.not_plusValidZTime_stabUntl` — and that target is a genuine ℤ-time
  non-validity too
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

/--
**(C1') forces `share`-class agreement on future-tense labels, one step shifted.**

The `untl`-side twin of `snce_share_congr`. The `untl` clause quantifies its successor over the
`share`-class at `t+1` rather than at the label's own time, so the collapse is not immediate —
but reading the clause at `t-1` recovers it anyway: `share t i j` *is* `share ((t-1)+1) i j`, so
the one clause at `(i, t-1)` applies to both `i` and `j`, and the two readings force agreement on
the one-step unfolding `e ∨ (g ∧ g U e)` at `t`.

This is why re-timing the `snce` quantifier by analogy with `untl` is not a repair: the `untl`
side carries the same defect, displaced by one step. The general rule is about the one-step
*reach* of a position, not about which time the quantifier names.

Paper: — (a formalization-native obstruction; the paper states no such result)
-/
theorem untl_shift_share_congr {Γ Del : PlusContext} (S : PlusSharingWitnessFamily Γ Del)
    (hloc : S.PlusLocalCoherentShare) (t : ℤ) (i j : Fin S.lassos.length)
    (hij : S.share t i j) (g e : PlusFormula)
    (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) :
    ((e ∈ S.L i t ∨ (g ∈ S.L i t ∧ PlusFormula.untl g e ∈ S.L i t)) ↔
      (e ∈ S.L j t ∨ (g ∈ S.L j t ∧ PlusFormula.untl g e ∈ S.L j t))) := by
  have hii : S.share (t - 1 + 1) i i := S.share_refl _ i
  have hij' : S.share (t - 1 + 1) i j := by rw [sub_add_cancel]; exact hij
  have h1 := (hloc i (t - 1)).2.2.2.1 i hii g e hc
  have h2 := (hloc i (t - 1)).2.2.2.1 j hij' g e hc
  have h := h1.symm.trans h2
  rwa [sub_add_cancel] at h

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

/-- The `untl`-side target `Fp → (¬p → ⊡Fp)`, whose instances are equally beyond reach. -/
def stabUntlTarget (p : Atom) : PlusFormula :=
  .imp (PlusFormula.untl PlusFormula.top (.atom p))
    (.imp (.imp (.atom p) .bot) (.stab (PlusFormula.untl PlusFormula.top (.atom p))))

/--
**No branching L⁺ certificate refutes `Fp → (¬p → ⊡Fp)` either.**

The `untl`-side twin of `not_plusCertifies_stabSnce`, and the correction to the record: the
`untl` clause is *not* defect-free. The extra `¬p` antecedent is what the shifted congruence
needs — `untl_shift_share_congr` forces agreement on the unfolding `p ∨ (⊤ ∧ Fp)` rather than on
`Fp` itself, so ruling out the `p` disjunct at the witnessing index is the one additional step
over the `snce` side's argument.

Paper: — (a formalization-native obstruction; the paper states no such result)
-/
theorem not_plusCertifies_stabUntl (p : Atom)
    (S : PlusSharingWitnessFamily [] [stabUntlTarget p]) (t : ℤ) : ¬ S.PlusCertifies t := by
  classical
  rintro ⟨hat, ⟨hloc, -⟩, -, htgt, hstab⟩
  set F : PlusFormula := PlusFormula.untl PlusFormula.top (.atom p) with hF
  have hcl_tgt : stabUntlTarget p ∈ plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusConclusion_mem_closure (List.mem_singleton_self _)
  have hcl_F : F ∈ plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusClosureOf_imp_left hcl_tgt
  have hcl_R : PlusFormula.imp (.imp (.atom p) .bot) (.stab F) ∈
      plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusClosureOf_imp_right hcl_tgt
  have hcl_np : PlusFormula.imp (.atom p) .bot ∈
      plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusClosureOf_imp_left hcl_R
  have hcl_stab : PlusFormula.stab F ∈
      plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusClosureOf_imp_right hcl_R
  have hcl_top : PlusFormula.top ∈ plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusClosureOf_untl_right hcl_F
  set i := S.toPlusWitnessFamily.mainIdx with hidef
  have hnotL : stabUntlTarget p ∉ S.L i t := htgt.2 _ (List.mem_singleton_self _)
  have himp := (hloc i t).2.1 F _ hcl_tgt
  have hFi : F ∈ S.L i t := by
    by_contra hno
    exact hnotL (himp.mpr (fun h => absurd h hno))
  have hRnot : PlusFormula.imp (.imp (.atom p) .bot) (.stab F) ∉ S.L i t :=
    fun h => hnotL (himp.mpr (fun _ => h))
  have himpR := (hloc i t).2.1 _ _ hcl_R
  have hnpi : PlusFormula.imp (.atom p) .bot ∈ S.L i t := by
    by_contra hno
    exact hRnot (himpR.mpr (fun h => absurd h hno))
  have hstabnot : PlusFormula.stab F ∉ S.L i t := fun h => hRnot (himpR.mpr (fun _ => h))
  have hpi : PlusFormula.atom p ∉ S.L i t :=
    fun hp => (hloc i t).1 (((hloc i t).2.1 _ _ hcl_np).mp hnpi hp)
  rw [hstab i t F hcl_stab] at hstabnot
  have hex : ∃ j, S.share t i j ∧ F ∉ S.L j t := by
    by_contra hc
    refine hstabnot (fun j hj => ?_)
    by_contra hno
    exact hc ⟨j, hj, hno⟩
  obtain ⟨j, hij, hFj⟩ := hex
  have hpj : PlusFormula.atom p ∉ S.L j t := fun hp => hpi ((hat t i j hij p).mpr hp)
  have htopi : PlusFormula.top ∈ S.L i t :=
    ((hloc i t).2.1 .bot .bot hcl_top).mpr (fun h => h)
  have hcong := untl_shift_share_congr S hloc t i j hij PlusFormula.top (.atom p) hcl_F
  have hL : (PlusFormula.atom p ∈ S.L i t ∨ (PlusFormula.top ∈ S.L i t ∧ F ∈ S.L i t)) :=
    Or.inr ⟨htopi, hFi⟩
  rcases hcong.mp hL with h | ⟨_, h⟩
  · exact hpj h
  · exact hFj h

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

/--
**`Fp → (¬p → ⊡Fp)` is not ℤ-time valid.**

The `untl`-side twin of `not_plusValidZTime_stabSnce`, on the same permissive ℤ-frame `NF`. The
history that sits at state `1` up to time `0` and at state `0` from time `1` on has a future `p`
and no present `p` at time `0`; the constant-`1` history agrees with it at `0` and has no future
`p` at all. So the emptiness `not_plusCertifies_stabUntl` records is, on this side too, a
completeness failure rather than a vacuity.

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
