/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Tactic.Attr

/-!
# FormalSystem.Tactic — the library's layer-0 metaprogramming directory

Sibling aggregator for `FormalSystem/Tactic/`. The directory holds the declarations that have to
sit strictly upstream of the library because of a compilation-unit constraint rather than because
of a mathematical dependency.

## Submodules

- `Tactic.Attr`: every attribute and named simp set the library uses (`truth_norm`,
  `reflect_time_norm`, `formula_unfold`, `formula_fold`, `@[tmLemma]`). Imports `Lean` only.
  `FormalSystem/Init.lean` imports it, so every module in the library inherits the declarations
  transitively and nothing imports it directly.

## Why this aggregator imports `FormalSystem.Init`

`Tactic.Attr` imports `Lean` alone — it cannot import `Init`, because `Init` imports *it*, and
that would be a cycle. Without the explicit `import FormalSystem.Init` above, this aggregator
would reach no `FormalSystem.Init` path of its own and check C24 would fail on it. This is the
same pattern `FormalSystem/ForMathlib.lean` already uses for the same reason. It closes no cycle:
`Init` imports `Tactic.Attr`, not `Tactic`.
-/
