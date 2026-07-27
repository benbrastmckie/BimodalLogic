/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.CanonicalTaskRelation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Bundle.FMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.UntilSinceCoherence
import Bimodal.Metalogic.Bundle.WitnessSeed

/-!
# Metalogic.Bundle: The Canonical Frame Construction

Aggregator for `Metalogic/Bundle/`. This directory builds the canonical task
frame out of bundled families of maximal consistent sets (BFMCS/FMCS) and
establishes the coherence conditions the truth lemma needs.

## Contents

- `FMCSDef`, `FMCS`, `BFMCS` — families of MCSs and their bundling
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
