/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Lean
import Mathlib.Lean.CoreM
import Batteries.Data.List.Basic
import ImportGraph

open Lean Core Elab Command

/-!
# Check Init Imports

Near-verbatim port of CSLib's `scripts/CheckInitImports.lean` (`Cslib` -> `FormalSystem`), with
two deliberate deviations from the original, each documented at its site below: a constant exit
status rather than the truncating count, and a differently-populated `exceptions` list. This repo
has no local lint/tactic-attribute module analogous to `Cslib.Foundations.Lint.Basic` needing a
circular-dependency exception -- `FormalSystem.Init`'s own two imports, `Mathlib.Init` and
`Mathlib.Tactic.Common`, are rooted at `Mathlib`, not `FormalSystem`, so the
`name.getRoot = `FormalSystem`` filter below already excludes them -- but it does have the
`ForMathlib` upstreaming rule, which supplies the one non-self exception.

This script checks that all `FormalSystem` modules (transitively) import `FormalSystem.Init`.
It is a *gate*: it is wired into `scripts/check-module-invariants.sh` as check C24, which runs it
in build mode and fails the invariants harness when any module in the `FormalSystem` root closure
lacks a transitive path to `FormalSystem.Init`. Every module in that closure now has one, reached
from the eleven minimal elements of the internal import DAG rather than from 457 direct import
lines. Run standalone with `lake exe checkInitImports`.
-/

/-- Modules with technical constraints preventing a `FormalSystem.Init` import. -/
def exceptions : List Name := [
  -- `FormalSystem.Init` does not (and cannot) import itself.
  `FormalSystem.Init,
  -- `FormalSystem/ForMathlib/` holds Mathlib-shaped material staged for upstreaming, and the
  -- documented rule for that directory is that nothing under it imports `FormalSystem.*` -- an
  -- upstreamed file must carry no dependency on this repository. Importing `FormalSystem.Init`
  -- here would break that rule. The sibling aggregator `FormalSystem/ForMathlib.lean`, which sits
  -- beside the directory rather than under it, carries the import instead, so every *consumer* of
  -- this module still reaches `FormalSystem.Init`.
  `FormalSystem.ForMathlib.Order.PFilter,
]

def main : IO UInt32 := do
  let searchPath ← addSearchPathFromEnv (← getBuiltinSearchPath (← findSysroot))
  CoreM.withImportModules #[`FormalSystem] (searchPath := searchPath) (trustLevel := 1024) do
    let env ← getEnv
    let graph := env.importGraph.transitiveClosure
    let noInitGraph :=
      graph.filter (fun name imports => name.getRoot = `FormalSystem ∧ !imports.contains `FormalSystem.Init)
    let diff := noInitGraph.keys.diff exceptions
    if diff.length > 0 then
      IO.eprintln s!"error: {diff.length} module(s) do not (transitively) import `FormalSystem.Init`:"
      for name in diff do
        IO.eprintln s!"  {name}"
    -- Deliberate deviation from the near-verbatim CSLib original, which returns the count.
    -- A POSIX exit status is 8 bits, so a count-returning gate is silently truncated mod 256:
    -- at the historical count of 457 this process exited 201, and any count that happened to be
    -- a non-zero multiple of 256 would have exited 0 -- a gate reporting failure while telling
    -- the shell it passed. Return a constant instead: 1 on any failure, 0 on success.
    return if diff.isEmpty then 0 else 1
