/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Index
import BimodalLib.Conjectures.Conservativity

/-!
# Tests of the conservativity-edge table

The status of a row is the constructor of its verdict, a verdict cannot be built without the
proof its constructor asks for, and the rendered section lists every registered edge.
-/

namespace BimodalLibTest.EdgeTableTest

open Lean Meta BimodalLib

/-! ### The status of each row is read off its verdict -/

#guard Edges.baseIntoPlus.verdict.name == "proved"
#guard Edges.booleanIntoModalBoolean.verdict.name == "proved"
#guard Edges.booleanIntoTemporalBoolean.verdict.name == "proved"
#guard Edges.booleanIntoTM.verdict.name == "proved"
#guard Edges.modalBooleanIntoTM.verdict.name == "proved"
#guard Edges.modalBooleanBoxIntoBoxStab.verdict.name == "proved"
#guard Edges.temporalBooleanIntoTMBase.verdict.name == "refuted"
#guard Edges.temporalBooleanIntoTMDense.verdict.name == "open"
#guard Edges.temporalBooleanIntoTMZTime.verdict.name == "open"
#guard Edges.temporalBooleanIntoTMRTime.verdict.name == "open"
#guard Edges.temporalBooleanUniformIntoTMBase.verdict.name == "open"

/-! ### A verdict cannot be built without its proof -/

example : True := by
  fail_if_success (have : EdgeVerdict False := .proved trivial)
  fail_if_success (have : EdgeVerdict True := .refuted trivial)
  trivial

/-! ### The repaired edge and its conjecture state the same thing -/

example : Edges.temporalBooleanUniformIntoTMBase.statement =
    Conjectures.temporalBooleanUniformIntoTMBase.statement := rfl

/-! ### No conjecture for a settled edge reads unsettled -/

#guard Conjectures.booleanIntoModalBoolean.status == .derived
#guard Conjectures.booleanIntoTemporalBoolean.status == .derived
#guard Conjectures.modalBooleanIntoTM.status == .derived
#guard Conjectures.modalBooleanBoxIntoBoxStab.status == .derived
#guard Conjectures.temporalBooleanIntoTMBase.status == .refuted

/-! ### The rendered section lists every registered edge -/

/-- The references of the registered edges, read from the environment. -/
def edgeReferences : MetaM (Array String) := do
  let env ← getEnv
  let mut out := #[]
  for (n, ci) in env.constants.map₁.toList ++ env.constants.map₂.toList do
    unless ci.type.isConstOf ``ConservativityEdge do continue
    let .lit (.strVal reference) ← whnf (← mkAppM ``ConservativityEdge.reference #[mkConst n])
      | throwError "the conservativity edge {n} has no computable reference"
    out := out.push reference
  return out

run_meta do
  let text ← renderEdges
  let refs ← edgeReferences
  unless refs.size == 11 do
    throwError "expected 11 registered edges, found {refs.size}"
  for r in refs do
    unless (text.splitOn r).length > 1 do
      throwError "the edge section does not list {r}"

end BimodalLibTest.EdgeTableTest
