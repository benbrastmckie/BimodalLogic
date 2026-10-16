/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.ShiftFiniteTypeDictionary
import FormalSystem.Metalogic.Decidability.FrameLassoCertificate

/-!
# Axiom-profile evidence for the effective shift-of-finite-type cluster

This module is **permanent evidence**, not a conventional test. Five library modules —
`Semantics/IntNormalFormEffective.lean`, `Semantics/ShiftFiniteType.lean`,
`Semantics/ShiftFiniteTypeDictionary.lean`, `Metalogic/Decidability/EffectiveOrbit.lean`,
`Metalogic/Decidability/EffectivePeriodicExtension.lean` and
`Metalogic/Decidability/FrameLassoCertificate.lean` — make precise claims in prose about where
`Classical.choice` enters their results and where it does not. A claim of that shape kept only in
prose rots the moment anyone edits a proof. Every one of those claims that is mechanically
checkable is checked here, one guard per declaration those modules introduce.

## What is claimed, and which guard checks it

| Claim | Guard |
|---|---|
| The ℤ membership chain is choice-free at `intOrder` | `reflection_int`, and the four below it |
| The SFT identification is choice-carrying *in its statement* | `mem_HF_iff_no_forbidden` |
| The *finite type* half is choice-carrying, by API | `finite_forbiddenBlocks` |
| The Mathlib dictionary is choice-carrying, by API | `isStepPath_iff_mem_forbidden` |
| The effective toolkit is choice-free | `succOfEnum`, `exists_dup_of_enum` |
| The extension theorem at an enumerated carrier is choice-free | `extend_periodic_enum` |
| The check and both correctness directions are choice-free | `presentsWindow_sound` |
| A `Nat.card` in a **statement** carries choice unread | `natCardInStatementProbe` |

## Why `whitespace := lax`

These declaration names are long enough that `#print axioms` wraps its output, and this file is
held to a 100-column limit, so an exactly-matching docstring is not always writable. `lax`
relaxes the comparison over whitespace only: the axiom list itself is still matched exactly.

## The definitions run

Choice-freedom of a proof is weaker than computability of a definition: a definition can be
`[propext, Quot.sound]` and still be stuck behind an irreducible `Classical.dec`. The `#eval` and
`#guard` blocks at the end close that gap by *running* the successor selection, the forward
orbit, the decoding and the certificate check on the two-state cycle `flipFrame`.

## When one of these guards fires

A red build here means an axiom profile moved. The expected block is updated **in the same commit
as the change that moved it**, with the move justified in that commit — never on its own to turn
a red build green. A guard that has grown `Classical.choice` in the choice-free sections is a
regression to investigate, not an expectation to rewrite. A profile that *shrinks* in the
deliberately choice-carrying sections is a welcome improvement: update the block and the
corresponding docstring together, and do not turn the shrinkage into a constructivity claim the
measurement does not support.
-/

namespace BimodalTest.Metalogic

open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability


/-! ## The ℤ membership chain, scrubbed

`IntNormalFormEffective.lean` restates `IntNormalForm.lean`'s route from adjacency to `H_F`
membership with `Decidable.eq_or_ne` in place of `eq_or_ne`. `reflection_int` is the one
declaration where the substitution happens; the other four inherit the result. A profile here
that has grown `Classical.choice` means the chain has been re-routed through the general
`FrameOver.reflection`, and every choice-free claim downstream of it has lapsed.
-/

/-- info: 'FormalSystem.Semantics.FrameOver.reflection_int' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.reflection_int


/--
info: 'FormalSystem.Semantics.FrameOver.taskRel_eq_iter_int' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.taskRel_eq_iter_int


/--
info: 'FormalSystem.Semantics.FrameOver.respects_of_isStepPath_int' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.respects_of_isStepPath_int


/--
info: 'FormalSystem.Semantics.FrameOver.worldHistoryOfStepPathInt' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.worldHistoryOfStepPathInt


/--
info: 'FormalSystem.Semantics.FrameOver.worldHistoryOfStepPathInt.path' depends on axioms:
[propext, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.worldHistoryOfStepPathInt.path


/--
info: 'FormalSystem.Semantics.FrameOver.mem_HF_iff_adjacent_int' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.mem_HF_iff_adjacent_int



/-! ## The shift-of-finite-type identification

`Forbidden`, `forbiddenBlocks` and `instDecidableForbidden` are the vocabulary;
`mem_HF_iff_no_forbidden` is the identification and `finite_forbiddenBlocks` the half that earns
the phrase "finite type".

The last two are **measured choice-carrying, and recorded as such rather than treated as
defects**. `finite_forbiddenBlocks` goes through `Set.toFinite` at `[Finite W]`, and
`mem_HF_iff_no_forbidden` needs double-negation elimination because `Forbidden` is a negation and
`F.step` carries no `Decidable` instance — classical reasoning in the *statement*, not in the
route. The choice-free form of the same identification is `mem_HF_iff_adjacent_int`, guarded
above, and it is what every downstream result consumes.
-/

/-- info: 'FormalSystem.Semantics.FrameOver.Forbidden' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.Forbidden


/-- info: 'FormalSystem.Semantics.FrameOver.forbidden_def' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.forbidden_def


/-- info: 'FormalSystem.Semantics.FrameOver.forbiddenBlocks' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.forbiddenBlocks


/-- info: 'FormalSystem.Semantics.FrameOver.mem_forbiddenBlocks' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.mem_forbiddenBlocks


/-- info: 'FormalSystem.Semantics.FrameOver.instDecidableForbidden' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.instDecidableForbidden


/--
info: 'FormalSystem.Semantics.FrameOver.finite_forbiddenBlocks' depends on axioms: [propext,
Classical.choice, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.finite_forbiddenBlocks


/--
info: 'FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden' depends on axioms: [propext,
Classical.choice, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.mem_HF_iff_no_forbidden



/-! ## The Mathlib subshift dictionary

Both declarations of `ShiftFiniteTypeDictionary.lean` measure
`[propext, Classical.choice, Quot.sound]`, for two independent reasons that are properties of
the API rather than of the proofs: `Mathlib.Dynamics.SymbolicDynamics.Basic` is a
`noncomputable section` whose `Pattern.occursInAt` and `forbidden` both carry choice, and the
dictionary's `←` direction needs the same double-negation elimination
`mem_HF_iff_no_forbidden` does.

This is the measurement the module docstring quotes, pinned so the quotation cannot drift. A
profile here that *shrinks* is a welcome improvement; update this block and that docstring in
the same commit, and do not turn the shrinkage into a constructivity claim it does not support.
-/

/--
info: 'FormalSystem.Semantics.FrameOver.nonEdgePatterns' depends on axioms: [propext,
Classical.choice, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.nonEdgePatterns


/--
info: 'FormalSystem.Semantics.FrameOver.isStepPath_iff_mem_forbidden' depends on axioms:
[propext, Classical.choice, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Semantics.FrameOver.isStepPath_iff_mem_forbidden



/-! ## The effective toolkit

`succOfEnum` / `predOfEnum` select by `List.find?` over the supplied enumeration, so seriality is
consumed only to refute the `none` branch — an elimination of `∃` into `False`, which costs
nothing. `exists_dup_of_enum` is the pigeonhole at `enum.length`, composing `List.idxOf` into
`Fin` and applying `exists_dup_lt`.

A profile here that has grown `Classical.choice` means a selection has been re-routed through
`Classical.choose`, or that the pigeonhole has been replaced by a library call — every
pigeonhole in Mathlib carries choice, which is the whole reason these exist.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.exists_step_fwd' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.exists_step_fwd


/-- info: 'FormalSystem.Metalogic.Decidability.exists_step_bwd' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.exists_step_bwd


/--
info: 'FormalSystem.Metalogic.Decidability.succOfEnum' depends on axioms: [propext, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.succOfEnum


/--
info: 'FormalSystem.Metalogic.Decidability.succOfEnum_step' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.succOfEnum_step


/--
info: 'FormalSystem.Metalogic.Decidability.predOfEnum' depends on axioms: [propext, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.predOfEnum


/--
info: 'FormalSystem.Metalogic.Decidability.predOfEnum_step' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.predOfEnum_step


/--
info: 'FormalSystem.Metalogic.Decidability.iterSuccEnum' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterSuccEnum


/--
info: 'FormalSystem.Metalogic.Decidability.iterSuccEnum_zero' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterSuccEnum_zero


/--
info: 'FormalSystem.Metalogic.Decidability.iterSuccEnum_succ' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterSuccEnum_succ


/--
info: 'FormalSystem.Metalogic.Decidability.iterPredEnum' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterPredEnum


/--
info: 'FormalSystem.Metalogic.Decidability.iterPredEnum_zero' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterPredEnum_zero


/--
info: 'FormalSystem.Metalogic.Decidability.iterPredEnum_succ' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterPredEnum_succ


/--
info: 'FormalSystem.Metalogic.Decidability.iterSuccEnum_step' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterSuccEnum_step


/--
info: 'FormalSystem.Metalogic.Decidability.iterPredEnum_step' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterPredEnum_step


/--
info: 'FormalSystem.Metalogic.Decidability.exists_dup_of_enum' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.exists_dup_of_enum



/-! ## The choice-free extension theorem

`extend_periodic_enum` is the task's central claim: the conclusion of the Extension Theorem, at
a frame whose carrier arrives as data, with both periods bounded by `enum.length` and **no**
`Classical.choice`.

Two traps are pinned by this block rather than described. The proof must not open with
`classical`, and it must not reach for Mathlib's `eq_or_lt_of_le`, which measures
`[propext, Classical.choice, Quot.sound]` and would contaminate the whole theorem through two
otherwise routine ℤ case splits. Both ℤ case splits are discharged by `omega` instead.
-/

/--
info: 'FormalSystem.Metalogic.Decidability.iterate_periodic_of_eq' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterate_periodic_of_eq


/--
info: 'FormalSystem.Metalogic.Decidability.iterSuccEnum_eq_iterate' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterSuccEnum_eq_iterate


/--
info: 'FormalSystem.Metalogic.Decidability.iterPredEnum_eq_iterate' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.iterPredEnum_eq_iterate


/-- info: 'FormalSystem.Metalogic.Decidability.fwdRun' depends on axioms: [propext, Quot.sound] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.fwdRun


/-- info: 'FormalSystem.Metalogic.Decidability.bwdRun' depends on axioms: [propext, Quot.sound] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.bwdRun


/--
info: 'FormalSystem.Metalogic.Decidability.fwdRun_length' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.fwdRun_length


/--
info: 'FormalSystem.Metalogic.Decidability.bwdRun_length' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.bwdRun_length


/--
info: 'FormalSystem.Metalogic.Decidability.fwdRun_getElem' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.fwdRun_getElem


/--
info: 'FormalSystem.Metalogic.Decidability.bwdRun_getElem' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.bwdRun_getElem


/--
info: 'FormalSystem.Metalogic.Decidability.extend_periodic_enum' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.extend_periodic_enum



/-! ## The certificate, its check, and both directions of its correctness

Three further contamination routes are pinned here, each discovered by measurement rather than
by inspection:

- `omega` discharging a goal that mentions `Int.emod` measures
  `[propext, Classical.choice, Quot.sound]`. `exists_reduce_int` exists so that no caller ever
  keeps a `%` in scope for `omega` to meet.
- every lemma in Mathlib's `Data/List/GetD.lean` — `List.getD_eq_getElem`, `getD_append`,
  `getD_append_right` — carries choice. `getD_eq_getElem_of_lt` goes through
  `List.getD_eq_getElem?_getD` and `List.getElem?_eq_getElem` instead.
- `exact_mod_cast` on a bare `ℕ → ℤ` inequality carries choice; `omega` handles the casts
  natively.

A profile in this section that has grown `Classical.choice` is one of those three creeping back.
-/

/--
info: 'FormalSystem.Metalogic.Decidability.reduce_emod_int' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.reduce_emod_int


/-- info: 'FormalSystem.Metalogic.Decidability.emod_succ_congr_int' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.emod_succ_congr_int


/--
info: 'FormalSystem.Metalogic.Decidability.exists_reduce_int' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.exists_reduce_int


/-- info: 'FormalSystem.Metalogic.Decidability.cyc_eq_getD_shift' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.cyc_eq_getD_shift


/--
info: 'FormalSystem.Metalogic.Decidability.unrollOf_step_of_window' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.unrollOf_step_of_window


/-- info: 'FormalSystem.Metalogic.Decidability.FrameLasso' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.FrameLasso


/-- info: 'FormalSystem.Metalogic.Decidability.FrameLasso.unroll' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.FrameLasso.unroll


/--
info: 'FormalSystem.Metalogic.Decidability.FrameLasso.unroll_def' depends on axioms: [propext]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.FrameLasso.unroll_def


/--
info: 'FormalSystem.Metalogic.Decidability.FrameLasso.windowTime' depends on axioms: [propext]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.FrameLasso.windowTime


/--
info: 'FormalSystem.Metalogic.Decidability.FrameLasso.unroll_sub_back_length' depends on axioms:
[propext, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.FrameLasso.unroll_sub_back_length


/--
info: 'FormalSystem.Metalogic.Decidability.FrameLasso.unroll_add_fwd_length' depends on axioms:
[propext, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.FrameLasso.unroll_add_fwd_length


/-- info: 'FormalSystem.Metalogic.Decidability.Coherent' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.Coherent


/-- info: 'FormalSystem.Metalogic.Decidability.decidableCoherent' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.decidableCoherent


/-- info: 'FormalSystem.Metalogic.Decidability.AgreesWindow' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.AgreesWindow


/--
info: 'FormalSystem.Metalogic.Decidability.decidableAgreesWindow' depends on axioms: [propext]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.decidableAgreesWindow


/-- info: 'FormalSystem.Metalogic.Decidability.presentsWindow' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.presentsWindow


/--
info: 'FormalSystem.Metalogic.Decidability.coherent_of_presentsWindow' depends on axioms:
[propext]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.coherent_of_presentsWindow


/--
info: 'FormalSystem.Metalogic.Decidability.agreesWindow_of_presentsWindow' depends on axioms:
[propext]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.agreesWindow_of_presentsWindow


/--
info: 'FormalSystem.Metalogic.Decidability.step_of_coherent' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.step_of_coherent


/--
info: 'FormalSystem.Metalogic.Decidability.isStepPath_of_coherent' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.isStepPath_of_coherent


/--
info: 'FormalSystem.Metalogic.Decidability.presentsWindow_sound' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.presentsWindow_sound


/--
info: 'FormalSystem.Metalogic.Decidability.getD_eq_getElem_of_lt' depends on axioms: [propext]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.getD_eq_getElem_of_lt


/-- info: 'FormalSystem.Metalogic.Decidability.getD_rangeMap' depends on axioms: [propext] -/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.getD_rangeMap


/--
info: 'FormalSystem.Metalogic.Decidability.getD_append_three' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.getD_append_three


/--
info: 'FormalSystem.Metalogic.Decidability.fwdRun_getD' depends on axioms: [propext, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.fwdRun_getD


/--
info: 'FormalSystem.Metalogic.Decidability.bwdRun_getD' depends on axioms: [propext, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.bwdRun_getD


/--
info: 'FormalSystem.Metalogic.Decidability.coherent_of_segments' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.coherent_of_segments


/--
info: 'FormalSystem.Metalogic.Decidability.presentsWindow_complete' depends on axioms: [propext,
Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms FormalSystem.Metalogic.Decidability.presentsWindow_complete



/-! ## The statement-versus-proof trap, demonstrated in-build

`FrameOver.extend_periodic`'s period bound is `Nat.card F.WorldState`, and that is why it is
choice-carrying no matter how its proof is written: `#print axioms` traverses a declaration's
**type** as well as its value, and `Nat.card` goes through `Cardinal.toNat`. The probe below has
the most trivial proof there is and still measures `Classical.choice`, purely because the axiom
appears in what it says rather than in how it is shown.

That is the reason `extend_periodic_enum`'s bound is `enum.length` — a natural number of the
supplied data — and not a cardinal of the carrier.
-/

/-- A declaration whose *type* mentions `Nat.card` and whose proof is `rfl`. -/
theorem natCardInStatementProbe : Nat.card Bool = Nat.card Bool := rfl

/--
info: 'BimodalTest.Metalogic.natCardInStatementProbe' depends on axioms: [propext,
Classical.choice, Quot.sound]
-/
#guard_msgs(whitespace := lax) in
#print axioms natCardInStatementProbe

/-! ## The definitions run

`flipFrame` (`Semantics/IntNormalForm.lean`) is the two-state cycle `… 0 1 0 1 …`, synthesized by
`FrameOver.ofStep` from `fun w u : Bool => w ≠ u`. It is a plain `def`, so the four instances
below have to be supplied by hand; the `Fintype` one is needed only so that `Finite` fires inside
`FrameOver.ofStep_step`.
-/

instance : DecidableEq flipFrame.WorldState := inferInstanceAs (DecidableEq Bool)
instance : Inhabited flipFrame.WorldState := inferInstanceAs (Inhabited Bool)
instance : Fintype flipFrame.WorldState := inferInstanceAs (Fintype Bool)
instance : flipFrame.IsRegular := FrameOver.ofStep_isRegular _ _ _

instance instDecidableFlipStep : DecidableRel flipFrame.step := fun w u =>
  decidable_of_iff (w ≠ u) (FrameOver.ofStep_step _ _ _ w u).symm

/-- Both states of the two-state cycle, as the carrier-as-data enumeration. -/
def flipEnum : List flipFrame.WorldState := [true, false]

theorem flipEnum_complete : ∀ w : flipFrame.WorldState, w ∈ flipEnum := by decide

/-- info: false -/
#guard_msgs in
#eval succOfEnum flipFrame flipEnum flipEnum_complete true

/-- info: false -/
#guard_msgs in
#eval predOfEnum flipFrame flipEnum flipEnum_complete true

/-- info: [true, false, true, false] -/
#guard_msgs in
#eval (List.range 4).map (iterSuccEnum flipFrame flipEnum flipEnum_complete true)

/-- The alternating bi-infinite path with the origin at a `true`, as a certificate: empty window,
both cycles the two-element list. -/
def flipLasso : FrameLasso flipFrame where
  back := [true, false]
  mid := []
  fwd := [true, false]
  origin := 0
  back_ne := by simp
  fwd_ne := by simp

/-- The constant path, which is **not** a walk in the two-state cycle: `step w w` is false there,
so the check must reject it. -/
def flipLassoBad : FrameLasso flipFrame where
  back := [true]
  mid := []
  fwd := [true]
  origin := 0
  back_ne := by simp
  fwd_ne := by simp

/-- info: [true, false, true, false, true] -/
#guard_msgs in
#eval (List.range 5).map fun k => flipLasso.unroll ((k : ℤ) - 2)

/-- info: true -/
#guard_msgs in
#eval presentsWindow flipLasso 0 [true, false]

/-- info: false -/
#guard_msgs in
#eval presentsWindow flipLassoBad 0 [true]

/-! The check is not vacuously `true`: it accepts the alternating certificate and rejects the
constant one, against the frame's real adjacency. -/

#guard presentsWindow flipLasso 0 [true, false]

#guard ! presentsWindow flipLassoBad 0 [true]

end BimodalTest.Metalogic
