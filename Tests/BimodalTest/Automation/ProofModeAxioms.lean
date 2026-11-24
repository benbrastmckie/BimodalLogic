/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.ProofMode

/-!
# Axiom assertions for the derivation proof mode

The proof mode advertises itself as assembling native `DerivationTree` and `PlusDerivationTree`
constructors and proved rules only, with nothing semantic standing in for a derivation. This file
makes that claim an assertion rather than a promise: one representative script per tactic family,
in TM and in TM⁺, gets a `#guard_msgs`-pinned `#print axioms` row, so a tactic that quietly
acquires a new dependency fails the build instead of changing a number nobody re-reads.

The permitted sets are `propext`, `Classical.choice` and `Quot.sound` -- Lean's own -- or any
subset. Nothing else is a new baseline; in particular `Lean.ofReduceBool`, which a stray
`native_decide` would introduce, is a hard stop. No row below reports it.

## Two readings this file exists to pin, which `WalkthroughAxioms.lean` has no need of

**The tactic-family partition is not the axiom partition.** The interesting line inside the basic
family is not basic-against-modal but `lintro`/`lcases` against everything else. `lintro`
discharges through the deduction theorem, which transforms a whole derivation and lives in
`FormalSystem/Metalogic/`, which is where `Classical.choice` and `Quot.sound` enter; `lcases` on a
disjunction takes the same route. A script of `lstart`/`lapply`/`lexact`/`lsplit` alone stays at
`[propext]`. The `[propext]`-only rows below are therefore **intentionally narrow**: they pin the
boundary, not merely its classical side. Widening one to admit the classical axioms would delete
the only evidence that the boundary is where it is, so a future reader should treat a newly
classical `[propext]` row as a finding about the tactic, not a stale expectation to fix.

**TM⁺ rows measure lighter than their TM counterparts**: `[propext, Quot.sound]`, with no
`Classical.choice`. The TM⁺ rule copies under `FormalSystem/Theorems/ProofMode/` take a different
route than their TM originals. That asymmetry is pinned here deliberately, so that any later
deletion of the TM⁺ copies in favour of a shared interface has a tripwire rather than a silent
change of foundation.

## Why named `def` mirrors rather than annotations on the acceptance fixtures

`#print axioms` cannot name an anonymous declaration: the acceptance fixtures under
`Tests/BimodalTest/Automation/ProofMode*Test.lean` are all `example`s, and
`#print axioms <module>._example` reports `Unknown constant`. The fixtures are also required to
keep passing unchanged, so they are not converted. Each row below is instead a named `def` whose
script body is the same shape as its fixture, measured in its own right.

The cost probe under `specs/evidence/proof-mode-cost-baseline/` carries a deliberate second copy
of these mirrors. That duplication is forced by the instrument -- `#count_heartbeats` can only
measure an elaboration it performs itself, so it cannot read an already-elaborated import -- and
not by oversight.
-/

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalTest.Automation.ProofModeAxioms

/-! ### Basic family, the `[propext]` side of the boundary

`lstart`, `lapply`, `lexact` and `lsplit` build a derivation by applying constructors and proved
rules directly. Nothing re-transforms an existing derivation, so no classical principle is
reached. These two rows are the narrow side of the boundary described in the module docstring.
-/

/-- Modus ponens by hand: `lstart`, then `lapply` and `lexact`. -/
def basicMP (A B : Formula) : [A.imp B, A] ⊢ B := by
  lstart hAB hA
  lapply hAB
  lexact hA

/-- A complete branch join: `lsplit` into two leaves, each closed by `lexact`. -/
def basicSplit (A B : Formula) : [A, B] ⊢ A.and B := by
  lstart hA hB
  lsplit
  · lexact hA
  · lexact hB

/-- info: 'BimodalTest.Automation.ProofModeAxioms.basicMP' depends on axioms: [propext] -/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.basicMP

/-- info: 'BimodalTest.Automation.ProofModeAxioms.basicSplit' depends on axioms: [propext] -/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.basicSplit

/-! ### Basic family, the classical side of the boundary

`lintro` discharges through the deduction theorem and `lcases` on a disjunction does the same.
Both transform a whole derivation rather than extending one, and both therefore reach the
classical machinery in `FormalSystem/Metalogic/`.
-/

/-- A single `lintro`, the cheapest script that crosses into the classical axioms. -/
def oneIntro (A : Formula) : ⊢ A.imp A := by
  lintro hA
  lexact hA

/-- `lcases` on a disjunction, closing both branches through the supplied maps. -/
def basicCases (A B C : Formula) : [A.or B, A.imp C, B.imp C] ⊢ C := by
  lstart hAB hAC hBC
  lcases hAB as hA hB
  · lapply hAC
    lexact hA
  · lapply hBC
    lexact hB

/--
info: 'BimodalTest.Automation.ProofModeAxioms.oneIntro' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.oneIntro

/--
info: 'BimodalTest.Automation.ProofModeAxioms.basicCases' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.basicCases

/-! ### Modal, temporal and discrete families in TM

Each scope-introducing tactic selects the guarantees that travel into the fresh world or time and
rebuilds the subderivation there, which routes through the same deduction-theorem machinery as
`lintro`.
-/

/-- Modal K: `lmodal_intro necessity` with an explicit selection. -/
def modalK (A B : Formula) : [(A.imp B).box, A.box] ⊢ B.box := by
  lstart hAB hA
  lmodal_intro necessity using [hAB, hA] as hAB hA
  lapply hAB
  lexact hA

/-- Temporal K: `ltemporal_intro future` with an explicit selection. -/
def temporalK (A B : Formula) : [(A.imp B).allFuture, A.allFuture] ⊢ B.allFuture := by
  lstart hAB hA
  ltemporal_intro future using [hAB, hA] as hAB hA
  lapply hAB
  lexact hA

/-- The discrete family: `lstep future` at `FrameClass.ZTime`. -/
def discreteStep (A B : Formula) : [(A.imp B).next, A.next] ⊢[FrameClass.ZTime] B.next := by
  lstart hMap hA
  lstep future using [hMap, hA] as hMap hA
  lapply hMap
  lexact hA

/--
info: 'BimodalTest.Automation.ProofModeAxioms.modalK' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.modalK

/--
info: 'BimodalTest.Automation.ProofModeAxioms.temporalK' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.temporalK

/--
info: 'BimodalTest.Automation.ProofModeAxioms.discreteStep' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.discreteStep

/-! ### The same two families over `PlusDerivationTree`

TM⁺ measures at `[propext, Quot.sound]`. The absence of `Classical.choice` is the asymmetry the
module docstring records; it is a fact about the TM⁺ rule copies, not a weaker assertion.
-/

/-- `ltemporal_use` over `PlusDerivationTree`, with stability inside the scope. -/
def plusModal (p q : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree FrameClass.Base
      [(p.stab.imp q).allPast, p.stab.allPast] q.allPast := by
  lstart hMap hP
  ltemporal_use hMap
  lexact hP

/-- `lmodal_cases` over `PlusDerivationTree`, joining the two settled branches. -/
def plusCases (p : FormalSystem.PlusLanguage.PlusFormula) :
    FormalSystem.PlusLanguage.PlusDerivationTree FrameClass.Base
      [p.stab.stab, p.stab.dstab] (p.stab.and p.stab).dstab := by
  lstart hSettled hPossible
  lmodal_cases hPossible using [hSettled] as hEvent hScoped
  lsplit
  · lexact hEvent
  · lexact hScoped

/--
info: 'BimodalTest.Automation.ProofModeAxioms.plusModal' depends on axioms: [propext, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.plusModal

/--
info: 'BimodalTest.Automation.ProofModeAxioms.plusCases' depends on axioms: [propext, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.plusCases

/-! ### The congruence kit

`lrewrite` is foundation-light where its rules are: transporting an implication through four
nested scopes stays at `[propext]`, because the congruence certificate is assembled from proved
scope-transport rules. `lsimp` is not light, but its additions come from the **rule list** rather
than from the simplifier: `doubleNegationIff` reaches classical machinery on its own. Pinning both
rows is what makes that attribution checkable rather than asserted.
-/

/-- `lrewrite` transporting an implication through the scope stack `□ G H □`. -/
def rewriteNested4 {fc : FrameClass} (Γ : Context) (A B C : Formula)
    (mapping : Γ ⊢[fc] (A.imp B).box.allPast.allFuture.box)
    (provider : Γ ⊢[fc] (A.or C).box.allPast.allFuture.box) :
    Γ ⊢[fc] (B.or C).box.allPast.allFuture.box := by
  lrewrite mapping at provider as mapped
  lexact mapped

/-- `lsimp only` with a single rule, reducing a double negation at a hypothesis. -/
def simpOneRule {fc : FrameClass} (Γ : Context) (A : Formula)
    (provider : Γ ⊢[fc] A.neg.neg) : Γ ⊢[fc] A := by
  lsimp only [FormalSystem.Theorems.ProofMode.doubleNegationIff] at provider as reduced
  lexact reduced

/--
info: 'BimodalTest.Automation.ProofModeAxioms.rewriteNested4' depends on axioms: [propext]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.rewriteNested4

/--
info: 'BimodalTest.Automation.ProofModeAxioms.simpOneRule' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.simpOneRule

/-! ### The views tier

A views-tier step produces the same judgment up to definitional equality or a cast, so it adds no
foundation beyond what the surrounding derivation already needed. Both rows stay at `[propext]`,
which is the tier separation the architecture record asserts, measured rather than assumed.
-/

/-- `lfold` at a hypothesis: `¬□¬A` presented as `◇A`. -/
def viewFold {fc : FrameClass} (Γ : Context) (A : Formula)
    (provider : Γ ⊢[fc] A.neg.box.neg) : Γ ⊢[fc] A.diamond := by
  lfold diamond at provider
  exact provider

/-- `lfold` at a hypothesis followed by `lunfold` at the goal. -/
def viewFoldUnfold {fc : FrameClass} (Γ : Context) (A : Formula)
    (provider : Γ ⊢[fc] A.neg.box.neg) : Γ ⊢[fc] A.diamond := by
  lfold diamond at provider
  lunfold diamond
  exact provider

/-- info: 'BimodalTest.Automation.ProofModeAxioms.viewFold' depends on axioms: [propext] -/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.viewFold

/--
info: 'BimodalTest.Automation.ProofModeAxioms.viewFoldUnfold' depends on axioms: [propext]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.viewFoldUnfold

/-! ### A long script

Five nested `lintro` steps, the threshold at which cost on long scripts was an open question.
Nesting `lintro` does not enlarge the axiom set beyond what one `lintro` already reaches: the
deduction theorem is applied repeatedly, not deepened. What nesting does change is cost, and that
is measured in `docs/development/proof-mode-cost-baseline.md`, not pinned here -- a heartbeat or
term-size figure is not stable across a toolchain bump and has no business in a `#guard_msgs`.
-/

/-- Five nested `lintro` steps, closing on the first introduced hypothesis. -/
def introLadder5 (A1 A2 A3 A4 A5 : Formula) :
    ⊢ A1.imp (A2.imp (A3.imp (A4.imp (A5.imp A1)))) := by
  lintro h1
  lintro h2
  lintro h3
  lintro h4
  lintro h5
  lexact h1

/--
info: 'BimodalTest.Automation.ProofModeAxioms.introLadder5' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalTest.Automation.ProofModeAxioms.introLadder5

end BimodalTest.Automation.ProofModeAxioms
