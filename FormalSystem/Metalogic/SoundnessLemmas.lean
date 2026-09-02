/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.SoundnessLemmas.CoValidity
import FormalSystem.Metalogic.SoundnessLemmas.FrameClassVariants
import FormalSystem.Metalogic.SoundnessLemmas.Separability

/-!
# Metalogic.SoundnessLemmas: Per-Axiom Validity Lemmas

Aggregator for `Metalogic/SoundnessLemmas/`. This directory holds the individual
validity lemmas that `Metalogic/Soundness.lean` assembles into the soundness
theorem; keeping them separate stops that file from growing without bound.

## Contents

- `CoValidity` — `co_valid`, the semantic validity of the paper's CO principle (not a
  soundness case: CO is derived here, not primitive)
- `FrameClassVariants` — per-axiom validity and swap-validity across the frame-class variants
- `Separability` — the order-theoretic input to Reynolds' separability axiom

## Position in the Layering

Consumed by `Metalogic/Soundness.lean`. Independent of every completeness
route, so it depends on nothing under `Core/`, `Bundle/`, `Algebraic/`,
`BXCanonical/` or `WeakCanonical/`.

This aggregator imports concrete leaf modules only.
-/
