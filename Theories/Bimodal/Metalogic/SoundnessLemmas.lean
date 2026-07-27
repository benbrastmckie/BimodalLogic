/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.SoundnessLemmas.Core
import Bimodal.Metalogic.SoundnessLemmas.DenseValidity
import Bimodal.Metalogic.SoundnessLemmas.FrameClassVariants

/-!
# Metalogic.SoundnessLemmas: Per-Axiom Validity Lemmas

Aggregator for `Metalogic/SoundnessLemmas/`. This directory holds the individual
validity lemmas that `Metalogic/Soundness.lean` assembles into the soundness
theorem; keeping them separate stops that file from growing without bound.

## Contents

- `Core` — validity lemmas for the base axiom schemas
- `DenseValidity` — validity lemmas specific to the dense frame class
- `FrameClassVariants` — validity across the frame-class variants

## Position in the Layering

Consumed by `Metalogic/Soundness.lean`. Independent of every completeness
route, so it depends on nothing under `Core/`, `Bundle/`, `Algebraic/`,
`BXCanonical/` or `WeakCanonical/`.

This aggregator imports concrete leaf modules only.
-/
