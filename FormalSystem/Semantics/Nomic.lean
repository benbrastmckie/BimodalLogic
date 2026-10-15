/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Nomic.Frame
import FormalSystem.Semantics.Nomic.Recovery
import FormalSystem.Semantics.Nomic.ZTime
import FormalSystem.Semantics.Nomic.Witnesses
import FormalSystem.Semantics.Nomic.Uniformity

/-!
# `FormalSystem.Semantics.Nomic` — nomic frames and their law-histories

Aggregator for `Semantics/Nomic/`. See `Semantics/Nomic/README.md`.

## Modules

- `Nomic.Frame` — `def:nomic-frame` (one carrier, one task relation per world state), the derived
  family `F.at w`, the law-history sets `lawHist`/`HF`, the three properties of
  `def:nomic-properties` with the two implications from *Uniform*, and `lem:nomic-occurrence`
- `Nomic.Recovery` — the two-point partial history as a general lemma over `TaskFrame`, and
  `lem:nomic-recovery`: the law-histories at `w` recover the relativized relation `⇒ʷ`
- `Nomic.ZTime` — `def:nomic-witnesses`: the ℤ-time presentation `ofStepFamily`, the two
  `lawHist`-over-ℤ membership bridges, law-history monotonicity, and the two step-path invariants
- `Nomic.Witnesses` — `prop:nomic-hierarchy`: the finite ℤ-time witnesses separating *Static*,
  *Lawful* and *Uniform*, their per-witness independence theorems, and `nomic_hierarchy`
- `Nomic.Uniformity` — `def:nomic-frame`'s accessibility relation `accRel`, `thm:nomic-uniform`'s
  six equivalent conditions as a cycle of implications with the bundled `nomic_uniform`, the
  `H_F × H_F` identification and its equivalence-relation consequence, and the cut
  `rmk:nomic-uniform`'s per-state transitivity `TransAtState`
-/
