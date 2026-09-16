/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Extension.Constraint
import FormalSystem.Semantics.Extension.Admissible
import FormalSystem.Semantics.Extension.Step
import FormalSystem.Semantics.Extension.Extension
import FormalSystem.Semantics.Extension.PeriodicExtension

/-!
# `FormalSystem.Semantics.Extension` — the extension theorem and its lemmas

Aggregator for `Semantics/Extension/`. See `Semantics/Extension/README.md`.

## Modules

- `Extension.Constraint` — `lem:constraint`: the constraints on a new duration form a directed
  family of nonempty sets
- `Extension.Admissible` — `lem:admissible`: the one-point extension is a partial history
- `Extension.Step` — `lem:step`: every partial history extends by one arbitrary duration
- `Extension.Extension` — `thm:extension` and `cor:occurrence` in hypothesis form. This is a
  content module that shares its directory's name, not an aggregator; this file is the
  directory's aggregator
- `Extension.PeriodicExtension` — periodic extension over a finite carrier at ℤ-time: a
  constructive, doubly ultimately periodic alternative to the Zorn argument
-/
