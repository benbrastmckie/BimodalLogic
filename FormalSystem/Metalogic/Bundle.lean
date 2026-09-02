/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.BFMCS
import FormalSystem.Metalogic.Bundle.FMCSDef
import FormalSystem.Metalogic.Bundle.LimitMCS
import FormalSystem.Metalogic.Bundle.LimitMCSCoherence
import FormalSystem.Metalogic.Bundle.RealExtension
import FormalSystem.Metalogic.Bundle.RealExtensionBundle
import FormalSystem.Metalogic.Bundle.TemporalCoherence
import FormalSystem.Metalogic.Bundle.TemporalContent
import FormalSystem.Metalogic.Bundle.WitnessSeed

/-!
# Metalogic.Bundle: The Canonical Frame Construction

Aggregator for `Metalogic/Bundle/`. This directory builds the canonical task
frame out of bundled families of maximal consistent sets (BFMCS/FMCS) and
establishes the coherence conditions the truth lemma needs.

## Contents

- `FMCSDef`, `FMCS`, `BFMCS` — families of MCSs and their bundling
- `LimitMCS` — the limit set of a `Rat`-indexed family at a real point, and its consistency
- `LimitMCSCoherence` — `forward_G`/`backward_H` across the rational/limit case matrix
- `RealExtension` — the `Rat`-to-`ℝ` extension of a family by rational selection
- `RealExtensionBundle` — the real bundle over a rational bundle, box time-stability, and the
  transport of restricted temporal coherence
- `WitnessSeed` — witness seeds and their consistency, used to build bundles
- `TemporalCoherence`, `TemporalContent` — the coherence properties and the g/h/f/p content maps

The canonical-frame half of this directory — `CanonicalFrame`, `CanonicalTaskRelation`,
`SuccRelation`, `Construction`, `UntilSinceCoherence` and `ModalSaturation` — was retired to
`Boneyard/BundleDeadHalf/`.

## Position in the Layering

`Bundle` sits above `Core` and beneath `Algebraic`, `BXCanonical` and `WeakCanonical`. There is
no longer a reverse edge: `Core/RestrictedMCS/Basic.lean` reaches the iterated-temporal syntax it
needs through `Syntax/SubformulaClosure/IteratedTemporal.lean`, so `Core`/`Bundle` is no longer a
directory-level cycle. See `Metalogic/README.md`.

This aggregator imports concrete leaf modules only.
-/
