/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Init
import Mathlib.Tactic.Common

/-!
# FormalSystem Initialization

This is the intended root file for `FormalSystem`, modeled on CSLib's `Cslib/Init.lean` (in turn
modeled on `Mathlib.Init`): a file every module in the library is meant to import, carrying the
linters and common tactics that should be active by default throughout. Unlike CSLib, this repo
has no local lint/tactic-attribute module to pin alongside `Mathlib.Init`, so this file imports
only the two Mathlib roots.

`scripts/CheckInitImportsMain.lean` checks that every `FormalSystem` module transitively imports this
file, and `scripts/check-module-invariants.sh` runs it as enforced check C24. That property now
holds across the tree: the eleven minimal elements of the internal import DAG -- the modules with
no `FormalSystem.*` import of their own -- import this file directly, and every other module
inherits it through them. The sole recorded exception is
`FormalSystem.ForMathlib.Order.PFilter`, which is staged for upstreaming and so may not depend on
anything under `FormalSystem`; the sibling aggregator `FormalSystem/ForMathlib.lean` carries the
import on its consumers' behalf.
-/
