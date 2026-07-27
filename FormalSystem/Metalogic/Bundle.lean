/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.BFMCS
import FormalSystem.Metalogic.Bundle.CanonicalFrame
import FormalSystem.Metalogic.Bundle.CanonicalTaskRelation
import FormalSystem.Metalogic.Bundle.Construction
import FormalSystem.Metalogic.Bundle.FMCSDef
import FormalSystem.Metalogic.Bundle.FMCSDef
import FormalSystem.Metalogic.Bundle.LimitMCS
import FormalSystem.Metalogic.Bundle.LimitMCSCoherence
import FormalSystem.Metalogic.Bundle.ModalSaturation
import FormalSystem.Metalogic.Bundle.RealExtension
import FormalSystem.Metalogic.Bundle.SuccRelation
import FormalSystem.Metalogic.Bundle.TemporalCoherence
import FormalSystem.Metalogic.Bundle.TemporalContent
import FormalSystem.Metalogic.Bundle.UntilSinceCoherence
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
- `CanonicalFrame`, `CanonicalTaskRelation`, `SuccRelation` — the frame and its relations
- `Construction`, `WitnessSeed` — building bundles from a seed
- `ModalSaturation`, `TemporalCoherence`, `TemporalContent`, `UntilSinceCoherence` —
  the saturation and coherence properties

## Position in the Layering

`Bundle` sits above `Core` (18 import edges into it) and beneath `Algebraic`,
`BXCanonical` and `WeakCanonical`. The single reverse edge — `Core/RestrictedMCS/Basic.lean`
importing `Bundle.CanonicalTaskRelation` — makes `Core`/`Bundle` a directory-level
cycle; see `Metalogic/README.md`.

This aggregator imports concrete leaf modules only.
-/
