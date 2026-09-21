/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.MonadicFO
import FormalSystem.Metalogic.Expressiveness.NormalForm
import FormalSystem.Metalogic.Expressiveness.Kamp.ESigmaExpansion
import FormalSystem.Metalogic.Expressiveness.Kamp.ExistsForallFormula
import FormalSystem.Metalogic.Expressiveness.Kamp.VeeExistsForall
import FormalSystem.Metalogic.Expressiveness.Kamp.ExistsForallLemmas
import FormalSystem.Metalogic.Expressiveness.Table
import FormalSystem.Metalogic.Expressiveness.PriorDefsDense
import FormalSystem.Metalogic.Expressiveness.Kamp.DedekindINFDense
import FormalSystem.Metalogic.Expressiveness.Kamp.KPlusFaithful
import FormalSystem.Metalogic.Expressiveness.PriorExpressivenessDense
import FormalSystem.Metalogic.Expressiveness.StaviConnectives
import FormalSystem.Metalogic.Expressiveness.EFGames.StaviCompleteness
import FormalSystem.Metalogic.Expressiveness.GameTransfer.CaseAnalysis

/-!
# Expressiveness: Kamp/Stavi Expressive Completeness

This module aggregates the expressive-completeness development: the monadic first-order
framework, the Ehrenfeucht-Fraïssé game apparatus, the normal-form theory, the Gabbay
separation route, and the Kamp and Stavi theorems that sit on top of them.

The development is about **expressive power**, not about canonical models. It answers "which
first-order properties are definable by a temporal formula?" — a question that is independent
of the Reynolds/Doets completeness construction in `Metalogic/WeakCanonical/`, where these
modules used to live. The two are separate developments and are now separate directories; no
module here imports anything from `WeakCanonical/` or `BXCanonical/`, which is what makes the
split a genuine partition rather than a renaming.

## Architecture

1. **MonadicFO**: the monadic signature, `MonadicFormula`, and its evaluation
2. **NormalForm**: normal forms for monadic formulas
3. **Kamp**: the Kamp theorem chain — ∃∀ formulas, the `K⁺` bracket rendering,
   Dedekind/INF density, and the faithful-rendering bridges
4. **Table**: the temporal-to-monadic table translation
5. **PriorDefs / PriorDefsDense / PriorExpressiveness / PriorExpressivenessDense**: the Prior
   connectives and their expressiveness results
6. **StaviConnectives / EFGames**: the Stavi connectives and the Ehrenfeucht-Fraïssé games
   establishing `StaviCompleteness`
7. **Separation**: the Gabbay separation route
8. **GameTransfer**: transfer of game equivalences across structures
9. **MonadicFO / EFGameTactics**: shared vocabulary and proof automation

## Main Exports

`Kamp.kampPriorExpressiveCompleteness` and `uSExpressivelyCompleteOverPrior` — the two headline
expressive-completeness results. Both are on the main-results page and both are pinned by
check C14's axiom baseline in `scripts/check-module-invariants.sh`.

## Status

**This subtree is sorry-free**, as is all of `FormalSystem/` outside `Boneyard/`. Check C3 of
`scripts/check-module-invariants.sh` asserts the structural-`sorry` inventory is ZERO by
content, over the whole tree, so the claim is re-derivable rather than maintained by hand.

All definitions are NON-VACUOUS (no `True`, `trivial`, or `Unit` bodies).

## References
- [kamp1968], the original expressive-completeness theorem
- [gabbay1994], Chapter 9, Section 3 — the Stavi connectives completing the
  Dedekind-incomplete case
- [rabinovich2014], the separation-based modern proof
- [gabbay1994], Chapter 10 — the separation property
-/
