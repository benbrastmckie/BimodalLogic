/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Countermodels.Complete
import BimodalLibTest.Fixtures.UnresolvedNearMiss

/-!
# Tests of the countermodel half

Four things are pinned here:

* **renaming** — the lookup's matching relation, in both verdicts, including the strict case a
  one-directional substitution test gets wrong;
* **lookup** — a positive hit at a renamed atom and a negative on a near-miss shape, so the
  lookup is tested and not merely present;
* **the per-grade census** — every admitted grade carries at least one row, which is the
  milestone's own DONE WHEN clause, asserted rather than read off a generated file;
* **the near-miss invariant** — in its *failing* direction, aimed at the fixture module. A
  build-time check that stops failing where it should is what a test library exists to catch.

The `BimodalLib` root is not imported, for the reason `BimodalLibTest.SubsumptionTest` records:
it registers `FormalSystem.Theorems.Combinators.identity`, which
`BimodalLibTest.ProofFragmentTest` also registers as a fixture, and the test library root then
fails to import both. `BimodalLib.Countermodels.Complete` brings in the whole countermodel half
without any theorem registration.
-/

namespace BimodalLibTest.CountermodelTest

open FormalSystem.Syntax FormalSystem.ProofSystem BimodalLib

/-! ### Fixtures

The atoms are spelled as `schemaVar` is, so the tests range over exactly the formulas a landed
row states, plus one ordinary atom distinct from both.
-/

/-- The first schema variable's atom. -/
def a0 : Atom := Atom.mkFresh "p" 0

/-- The second schema variable's atom. -/
def a1 : Atom := Atom.mkFresh "p" 1

/-- An atom distinct from every schema variable. -/
def a2 : Atom := Atom.mkBase "q"

/-! ### Renaming

Renaming is mutual substitution-instance. The six cases below are the ones that separate it from
the one-directional test: a genuine renaming passes, a variable collapse fails in one direction
and so is refused, and a strict instance is refused although the one-directional test accepts it.
-/

/-- `p₀ → p₁` and `p₁ → q` are the same up to renaming. -/
example : sameUpToRenaming (.imp (.atom a0) (.atom a1)) (.imp (.atom a1) (.atom a2)) = true := by
  decide

/-- `p₀ → p₀` and `p₀ → p₁` are not: the first identifies two positions the second separates. -/
example : sameUpToRenaming (.imp (.atom a0) (.atom a0)) (.imp (.atom a0) (.atom a1)) = false := by
  decide

/-- The collapse direction is refused too, so the relation is symmetric in its verdict. -/
example : sameUpToRenaming (.imp (.atom a0) (.atom a1)) (.imp (.atom a0) (.atom a0)) = false := by
  decide

/-- A renaming under a modal operator is still a renaming. -/
example :
    sameUpToRenaming (.imp (.box (.atom a0)) (.atom a0))
      (.imp (.box (.atom a1)) (.atom a1)) = true := by
  decide

/-- `p₀ → ⊥` and `□p₀ → ⊥` are **not** the same up to renaming: the second is strictly less
general. This is the case that makes the mutual test necessary. -/
example : sameUpToRenaming (.imp (.atom a0) .bot) (.imp (.box (.atom a0)) .bot) = false := by
  decide

/-- The one-directional test accepts that same pair, which is why the lookup does not use it. -/
example : isSubstInstance (.imp (.atom a0) .bot) (.imp (.box (.atom a0)) .bot) = true := by decide

/-! ### Renaming over the extended language

The companion matcher adds the `⊡` case and nothing else, so `⊡` must match `⊡` head to head.
-/

/-- `⊡p₀ → □⊡p₀` and `⊡p₁ → □⊡p₁` are the same up to renaming. -/
example :
    sameUpToRenamingP (.imp (.stab (.atom a0)) (.box (.stab (.atom a0))))
      (.imp (.stab (.atom a1)) (.box (.stab (.atom a1)))) = true := by
  decide

/-- `⊡` does not match `□`: the two modal operators are distinct constructors. -/
example :
    sameUpToRenamingP (.imp (.stab (.atom a0)) (.box (.stab (.atom a0))))
      (.imp (.box (.atom a1)) (.box (.stab (.atom a1)))) = false := by
  decide

/-! ### The lookup

The rows are supplied as data, which is the lookup's own interface: the registry is a set of
constants in the environment, which a compiled function cannot walk.
-/

/-- A sample of the landed L rows, one per grade. -/
def rows : List (CountermodelEntry Formula) :=
  [ Countermodels.TemporalBoolean.RTime.cmPriorUZ
  , Countermodels.TemporalBoolean.RTime.cmZ1
  , Countermodels.TemporalBoolean.Dense.cmPriorUGap
  , Countermodels.TemporalBoolean.ZTime.cmDensity
  , Countermodels.TemporalBoolean.ZTime.cmBotUntl
  , Countermodels.Boolean.GatedTableau.cmGatedImpBot ]

/-- POSITIVE: Prior's UZ axiom at a different atom is found, because the lookup matches up to
renaming. -/
example :
    isRefutedUpToRenaming rows []
      ((Formula.atom a2).someFuture.imp (Formula.untl (Formula.atom a2).neg (Formula.atom a2)))
      = true := by
  decide

/-- POSITIVE: `q → ⊥` finds the gated-tableau row, whose statement is `p₀ → ⊥`. -/
example : isRefutedUpToRenaming rows [] (.imp (.atom a2) .bot) = true := by decide

/-- NEGATIVE: `□q → ⊥` is a near-miss shape — a strict generalization of a landed row — and is
**not** found. A lookup built on the one-directional test would report the gated row here. -/
example : isRefutedUpToRenaming rows [] (.imp (.box (.atom a2)) .bot) = false := by decide

/-- NEGATIVE: an inference no row refutes is not found. -/
example : isRefutedUpToRenaming rows [] (.imp (.atom a0) (.atom a0)) = false := by decide

/-- A premise added to a landed row's inference changes the inference, so the row no longer
matches it: the premise list is part of what is matched. -/
example : isRefutedUpToRenaming rows [.atom a2] (.imp (.atom a2) .bot) = false := by decide

/-! ### The per-grade census

The milestone's DONE WHEN clause asks that each of the three admitted grades carry at least one
entry. This asserts it over the same environment walk the index renders from, so the assertion
and the generated artifact cannot disagree. No count is printed: a pinned count would have to be
edited every time a row is added, and what is being tested is non-emptiness.
-/

run_cmd Lean.Elab.Command.liftTermElabM do
  let rows ← BimodalLib.countermodelRows
  for g in BimodalLib.gradeOrder do
    if (rows.filter (·.grade == g)).isEmpty then
      throwError "the grade {g.name} carries no countermodel row"

/-! ### Axioms, one row per grade

Each measured, not asserted from the others: a row's refutation is only as good as what it
rests on, and the triple below is the one every other `BimodalLib` theorem measures.
-/

/--
info: 'BimodalLib.Countermodels.TemporalBoolean.RTime.cmPriorUZ' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalLib.Countermodels.TemporalBoolean.RTime.cmPriorUZ

/--
info: 'BimodalLib.Countermodels.TemporalBoolean.ZTime.cmBotUntl' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalLib.Countermodels.TemporalBoolean.ZTime.cmBotUntl

/--
info: 'BimodalLib.Countermodels.Boolean.GatedTableau.cmGatedImpBot' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms BimodalLib.Countermodels.Boolean.GatedTableau.cmGatedImpBot

/-! The gate discharge itself, which is what the gated grade actually rests on. Measured, and
smaller than the rows above: `decide` on finite data needs `propext` alone, so the gated grade's
*checking step* is classical-choice-free even though the bridge theorem that consumes it is
not. -/

/--
info: 'BimodalLib.Countermodels.Boolean.GatedTableau.gates_ok' depends on axioms: [propext]
-/
#guard_msgs in
#print axioms BimodalLib.Countermodels.Boolean.GatedTableau.gates_ok

/-! ### The near-miss invariant, in its failing direction

The fixture module declares a landed row with its `nearMiss` replaced by a name that is not in
the environment. The invariant must fail and name both the row and the missing target. Only the
error is matched: the command's informational line carries a row count that would otherwise have
to be edited every time a row is added.
-/

/--
error: 1 countermodel row(s) name a near miss that does not resolve; correct the name or drop the field:
  BimodalLibTest.Fixtures.badNearMiss names BimodalLibTest.Fixtures.noSuchDeclaration as its near miss, which is not in the environment
-/
#guard_msgs(error) in
assert_near_miss_targets_resolve

end BimodalLibTest.CountermodelTest
