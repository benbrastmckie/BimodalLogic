/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Correspondence.Galois
import FormalSystem.Semantics.Correspondence.Indicator
import FormalSystem.Semantics.Correspondence.FwdRec
import FormalSystem.Semantics.Correspondence.DurationFrames
import FormalSystem.Semantics.Correspondence.FwdRecPeriodicity
import FormalSystem.Semantics.Correspondence.FwdRecBridge
import FormalSystem.Semantics.Correspondence.Rigidity
import FormalSystem.Semantics.Correspondence.RigiditySharpness

/-!
# `FormalSystem.Semantics.Correspondence` — the frame-class Galois layer

Aggregator for `Semantics/Correspondence/`. See `Semantics/Correspondence/README.md`.

## Modules

- `Correspondence.Galois` — the `Th`/`Mod` Galois connection between sets of task frames and
  sets of formulas
- `Correspondence.Indicator` — indicator exactness for the dense and paper-Discrete classes
- `Correspondence.FwdRec` — forward recurrence, the frame-level correspondent of the density
  schema (atomic half)
- `Correspondence.DurationFrames` — witness frames for the duration-level correspondence
  theorems `app:discrete`, `app:dense`, `app:complete`
- `Correspondence.FwdRecPeriodicity` — walks, minimal cycles, and per-history periodicity
- `Correspondence.FwdRecBridge` — the `ℤ` bridge: a task frame over `ℤ` is a digraph and its
  histories are walks
- `Correspondence.Rigidity` — over a dense Archimedean order a task frame is static iff it has a
  uniform dwell time, so every finite-carrier frame over such an order is static
- `Correspondence.RigiditySharpness` — compiled witnesses that neither density (`ℤ`) nor the
  Archimedean property (`ℚ ×ₗ ℚ`) can be dropped from the rigidity theorem
-/
