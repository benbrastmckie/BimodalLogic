/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Presheaf.Behavior
import FormalSystem.Semantics.Presheaf.Sheaf
import FormalSystem.Semantics.Presheaf.Site

/-!
# `FormalSystem.Semantics.Presheaf` — the interval site and the behavior presheaf

Aggregator for `Semantics/Presheaf/`. See `Semantics/Presheaf/README.md`.

## Modules

- `Presheaf.Site` — the interval site `Int(D)`: the translations `Tr p`, the three category laws,
  and the Johnstone coverage
- `Presheaf.Behavior` — the behavior presheaf `Beh F`: the sections over a duration, the
  restriction action in both its raw-data and site-indexed forms, presheaf functoriality, and the
  *Germs* clause `Beh F 0 ≃ F.WorldState`
- `Presheaf.Sheaf` — the *Sheaf* clause: two sections agreeing at a seam glue to a unique section
  over the joined interval, with both restriction identities and uniqueness
-/
