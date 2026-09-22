/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Frames.Standard
import FormalSystem.Semantics.Frames.TranslationProduct

/-!
# `FormalSystem.Semantics.Frames` — the standard-frame index

Aggregator for `Semantics/Frames/`. See `Semantics/Frames/README.md`.

## Modules

- `Frames.Standard` — the concrete standard task frames the development builds directly
  (`translationFrame`, `permissiveFrame`)
- `Frames.TranslationProduct` — the translation product `FrameOver.translationProduct`, a proof
  device for what `L`, `L⁺` and `L⋆` cannot see of a frame (recurrence and transposition); never
  an intended model
-/
