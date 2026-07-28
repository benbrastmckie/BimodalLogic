/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Frame
import FormalSystem.Metalogic.BXCanonical.TruthLemma
import FormalSystem.Metalogic.BXCanonical.Completeness
import FormalSystem.Metalogic.BXCanonical.CompletenessDedekind
import FormalSystem.Metalogic.BXCanonical.Quasimodel.SubformulaClosure
import FormalSystem.Metalogic.BXCanonical.Quasimodel.HintikkaPoint
import FormalSystem.Metalogic.BXCanonical.Quasimodel.Construction
import FormalSystem.Metalogic.BXCanonical.Quasimodel.Realization
import FormalSystem.Metalogic.BXCanonical.Quasimodel.LocusControl
import FormalSystem.Metalogic.BXCanonical.CanonicalChain
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGapWitness
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGuardWitness
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGuardAbove
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleRealExtension

/-!
# BX Canonical Model Completeness

This module collects the BX canonical model completeness proof.

## Architecture

1. `Frame.lean` — BXPoint, canonical ordering, forward/backward witnesses
2. `TruthLemma.lean` — Truth lemma by formula induction
3. `Completeness.lean` — BX completeness theorem (wired through; leaf sorries in chain construction)
4. `CanonicalChain.lean` — BX axiom lemmas for Until/Since, delegation bridges
5. `Quasimodel/` — Hintikka-set quasimodel infrastructure for Until/Since
   - `SubformulaClosure.lean` — Finite subformula closure (Sigma-closure)
   - `HintikkaPoint.lean` — Hintikka point definition and sigma-signature
   - `Construction.lean` — BX axiom lemmas at MCS level
   - `Realization.lean` — Realization lifting (delegates to Frame.lean)
   - `LocusControl.lean` — Locus-control delegation interface for chain construction
-/
