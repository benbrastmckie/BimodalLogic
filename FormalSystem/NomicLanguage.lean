/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.NomicLanguage.Formula
import FormalSystem.NomicLanguage.NomicTruth
import FormalSystem.NomicLanguage.NomicTenseFree
import FormalSystem.NomicLanguage.NomicValidity
import FormalSystem.NomicLanguage.NomicFour

/-!
# `FormalSystem.NomicLanguage` — BL plus the nomic operator

Aggregator for `NomicLanguage/`. See `NomicLanguage/README.md`.

A **semantic-only** language component, in `OpenLanguage/`'s pattern: no proof system, no
axiomatisation, no soundness or completeness claim. The paper offers none for the nomic operator,
exactly as it offers none for the open-future and open-past modals.

## Modules

- `NomicLanguage.Formula` — the language of BL plus the nomic modal `◈`
  (`sub:RestrictedModalities`), its derived operators with `Formula`'s right-hand sides, and the
  embedding `ofFormula`
- `NomicLanguage.NomicTruth` — `NomicModel`, the seven-clause truth recursion `NomicTruthAt` with
  `def:nomic-frame`'s Nomic clause, the sixteen clause lemmas, and the uniformity collapse
  `nomic_iff_box_of_uniform`
- `NomicLanguage.NomicTenseFree` — `prop:nomic-tense-free`: the fragment `TenseFree`, the state-set
  recursion `nomicSatSet`, the bridge `tenseFree_satSet_iff`, the collapse
  `nomic_iff_box_tenseFree`, and the five **S5** schemata on the fragment
- `NomicLanguage.NomicValidity` — `NomicFrame.NomicValidOn`, seriality (`nomic_serial`) over every
  nomic frame, and the uniformity collapse as a pair of validities
- `NomicLanguage.NomicFour` — `app:nomic-four`: over ℤ-time, axiom 4 for the nomic operator and
  the interderivability `◈φ ↔ □φ` are each valid exactly on the Uniform frames, with the shared
  countermodel and the invalidity claim at `prop:nomic-hierarchy`'s static-and-lawful witness
-/
