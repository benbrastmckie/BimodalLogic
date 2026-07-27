/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.Algebraic.BooleanStructure
import Bimodal.Metalogic.Algebraic.InteriorOperators
import Bimodal.Metalogic.Algebraic.LindenbaumQuotient
import Bimodal.Metalogic.Algebraic.ParametricCanonical
import Bimodal.Metalogic.Algebraic.ParametricCompleteness
import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.Algebraic.ParametricTruthLemma
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Bimodal.Metalogic.Algebraic.UltrafilterMCS

/-!
# Metalogic.Algebraic: The Parametric/Algebraic Completeness Route

Aggregator for `Metalogic/Algebraic/`. This is one of the three completeness
developments in the tree; it works through the Lindenbaum-Tarski quotient algebra
and a parametric canonical model rather than through an explicit chronicle.

## Contents

- `BooleanStructure`, `LindenbaumQuotient`, `InteriorOperators` — the quotient algebra
  and the modal operators on it
- `UltrafilterMCS` — the ultrafilter/MCS correspondence
- `ParametricCanonical`, `ParametricHistory` — the parametric canonical model
- `ParametricTruthLemma`, `RestrictedParametricTruthLemma`, `ParametricCompleteness` —
  the truth lemma and the completeness result

## Position in the Layering

`Algebraic` sits above `Core` and `Bundle` and is a sibling of `BXCanonical`
(the chronicle route) and `WeakCanonical` (the Kamp/Reynolds route). Unlike those
two it participates in no cycle. See `Metalogic/README.md` for the three-way
comparison and the measured edge table.

This aggregator imports concrete leaf modules only.
-/
