/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Countermodel.Lookup
import BimodalLib.Countermodel.Transfer
import BimodalLib.Countermodels.Boolean.GatedTableau
import BimodalLib.Countermodels.ModalBoolean.Base
import BimodalLib.Countermodels.ModalTemporalBoolean.Base
import BimodalLib.Countermodels.TemporalBoolean.Dense
import BimodalLib.Countermodels.TemporalBoolean.RTime
import BimodalLib.Countermodels.TemporalBoolean.ZTime
import BimodalLib.Index

/-!
# The countermodel half, complete

Every countermodel entry module is imported here, and the build invariants over the whole set
run here. Importing this module brings the whole countermodel half into scope, which is what the
index walk and the test library want.

## `assert_near_miss_targets_resolve`

The design record asks that a refuted inference and the theorem entry it is a near miss for
"name each other". Only one direction of that is constructible, and the asymmetry is real rather
than an omission: `TheoremEntry` is `Formula`-only by type, so the laws the five `⊡` refutations
bound — an axiom constructor, two semantic validity theorems — are not and cannot be registry
rows. There is no row for the countermodel row to be named by.

What is constructible is the direction that exists, so that is what is checked: every
`some nearMiss` must resolve in the environment. The command fails the build when a row names a
declaration that is not there, which is the failure a rename or a deletion would otherwise
introduce silently.

## Why there is no completeness check

`assert_registry_complete` demands a row for every closed derivation under
`FormalSystem/Theorems/`. The analogue here would demand a row for every `¬ Valid…`-shaped
theorem in `FormalSystem`, and that would indict around a hundred declarations across five
incompatible tiers: derivability-level independence results, definability results,
frame-property results, `StarFormula` refutations, and frame-level refutations with no class tag.
None of those is an inference failing in a model, so none of them is a countermodel row, and a
check that said otherwise would be wrong rather than strict. Registration here is by the
design record's explicit list, not by exhaustion.

## Tags

countermodel · invariant · near-miss · complete
-/

namespace BimodalLib

open Lean Meta Elab Command

/--
`assert_near_miss_targets_resolve` fails when a countermodel row's `nearMiss` field names a
declaration that is not in the environment, naming the row and the missing target. It logs how
many rows it checked and how many carry a near miss. Only imported modules are scanned, exactly
as `assert_registry_complete` is.
-/
syntax (name := assertNearMissTargetsResolve)
  "assert_near_miss_targets_resolve" : command

/-- Elaborates `assert_near_miss_targets_resolve`. -/
@[command_elab assertNearMissTargetsResolve]
def elabAssertNearMissTargetsResolve : CommandElab := fun stx =>
  match stx with
  | `(assert_near_miss_targets_resolve) => liftTermElabM do
    let rows ← countermodelRows
    let env ← getEnv
    let named := rows.filter (·.nearMiss.isSome)
    let mut offenders : Array MessageData := #[]
    for r in named do
      let some target := r.nearMiss | continue
      unless env.contains target do
        offenders := offenders.push
          m!"{r.decl} names {target} as its near miss, which is not in the environment"
    logInfo m!"checked {rows.size} countermodel row(s); {named.size} name a near miss"
    unless offenders.isEmpty do
      throwError "{offenders.size} countermodel row(s) name a near miss that does not \
        resolve; correct the name or drop the field:{indentD (MessageData.joinSep
          offenders.toList Format.line)}"
  | _ => throwUnsupportedSyntax

assert_near_miss_targets_resolve

end BimodalLib
