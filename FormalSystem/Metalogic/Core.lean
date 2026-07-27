/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.Metalogic.Core.MaximalConsistent
import FormalSystem.Metalogic.Core.MCSProperties
import FormalSystem.Metalogic.Core.RestrictedMCS.Basic

/-!
# Metalogic.Core: Shared Foundations for Every Completeness Route

Aggregator for `Metalogic/Core/`. This directory holds the maximal-consistent-set
machinery that all three completeness developments build on, so nothing here may
depend on a particular construction.

## Contents

- `DeductionTheorem` — the deduction theorem for the TM proof system
- `MaximalConsistent` — maximal consistent sets and Lindenbaum extension
- `MCSProperties` — closure properties of maximal consistent sets
- `RestrictedMCS.Basic` — MCSs restricted to a finite formula set

## Position in the Layering

`Core` is the foundation beneath `Bundle`, `Algebraic`, `BXCanonical` and
`WeakCanonical`. It is not quite a leaf: `RestrictedMCS/Basic.lean` imports
`Bundle.CanonicalTaskRelation`, the single `Core -> Bundle` edge, which is why
`Core` and `Bundle` form a directory-level cycle. The module-level dependency
graph remains acyclic; see `Metalogic/README.md` for the measured edge table.

This aggregator imports concrete leaf modules only. Nothing under `Core/`
imports this file — an aggregator that were imported by its own contents would
create a genuine module-level cycle.
-/
