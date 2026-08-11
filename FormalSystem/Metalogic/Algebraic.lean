/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Algebraic.BooleanStructure
import FormalSystem.Metalogic.Algebraic.FlowFrame
import FormalSystem.Metalogic.Algebraic.InteriorOperators
import FormalSystem.Metalogic.Algebraic.LindenbaumQuotient
import FormalSystem.Metalogic.Algebraic.UltrafilterMCS

/-!
# Metalogic.Algebraic: The Algebraic Layer and the Flow-Frame Engine

Aggregator for `Metalogic/Algebraic/`. This directory hosts the Lindenbaum-Tarski quotient
algebra and the flow-frame countermodel engine consumed by the chronicle route.

The former parametric canonical model (`ParametricCanonical`/`ParametricHistory`/
`ParametricTruthLemma`/`RestrictedParametricTruthLemma`/`ParametricCompleteness`) violated
the frame definition's *Limit* axiom (`def:frame#Limit`) over dense duration types and has
been deleted; its truth lemma is re-hosted on `bundleFlowFrame` in `FlowFrame.lean`.

## Contents

- `BooleanStructure`, `LindenbaumQuotient`, `InteriorOperators` — the quotient algebra
  and the modal operators on it
- `UltrafilterMCS` — the ultrafilter/MCS correspondence
- `FlowFrame` — the generic multi-family flow frame, its four-axiom conformance and
  totality layer, the bundle flow frame/model, and the re-hosted dense truth lemma

## Position in the Layering

`Algebraic` sits above `Core` and `Bundle` and is a sibling of `BXCanonical`
(the chronicle route) and `WeakCanonical` (the Kamp/Reynolds route). Unlike those
two it participates in no cycle. See `Metalogic/README.md` for the three-way
comparison and the measured edge table.

This aggregator imports concrete leaf modules only.
-/
