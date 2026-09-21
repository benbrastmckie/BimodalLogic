/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Init
import Mathlib.Tactic.Common
import FormalSystem.Tactic.Attr

/-!
# FormalSystem Initialization

This is the intended root file for `FormalSystem`, modeled on CSLib's `Cslib/Init.lean` (in turn
modeled on `Mathlib.Init`): a file every module in the library is meant to import, carrying the
linters and common tactics that should be active by default throughout. Exactly as in CSLib, it
pins a local tactic-attribute module -- `FormalSystem.Tactic.Attr` -- alongside the two Mathlib
roots, so that every module in the library inherits the library's attributes and named simp sets
(`truth_norm`, `reflect_time_norm`, `formula_unfold`, `formula_fold`, `@[tmLemma]`) transitively
and none has to import them directly. `Tactic/Attr.lean` imports `Lean` alone; it must not import
this file, since that edge would close a cycle.

`scripts/CheckInitImportsMain.lean` checks that every `FormalSystem` module transitively imports
this file, and `scripts/check-module-invariants.sh` runs it as enforced check C24. That property now
holds across the tree: the eight minimal elements of the internal import DAG -- the modules with no
`FormalSystem.*` import of their own beyond this file -- import this file directly, and every other
module inherits it through them. Two modules are recorded exceptions.
`FormalSystem.ForMathlib.Order.PFilter` is staged for upstreaming and so may not depend on anything
under `FormalSystem`; the sibling aggregator `FormalSystem/ForMathlib.lean` carries the import on
its consumers' behalf. `FormalSystem.Tactic.Attr` is imported *by* this file and so cannot import
it back.
-/
