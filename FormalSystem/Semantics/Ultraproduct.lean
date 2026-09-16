/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Ultraproduct.Carrier
import FormalSystem.Semantics.Ultraproduct.IndexFilter
import FormalSystem.Semantics.Ultraproduct.ShiftSetProduct
import FormalSystem.Semantics.Ultraproduct.Los

/-!
# `FormalSystem.Semantics.Ultraproduct` — the ultraproduct shift set and Łoś's theorem

Aggregator for `Semantics/Ultraproduct/`. See `Semantics/Ultraproduct/README.md`.

## Modules

- `Ultraproduct.Carrier` — the dependent ultraproduct carrier `UD φ D` and the lifted shift action
- `Ultraproduct.IndexFilter` — the ultrafilter on the index type of finite sublists
- `Ultraproduct.ShiftSetProduct` — the ultraproduct temporal order and shift set `uShiftSet`
- `Ultraproduct.Los` — Łoś's theorem at `ShiftTruth` and at `TruthAt`
-/
