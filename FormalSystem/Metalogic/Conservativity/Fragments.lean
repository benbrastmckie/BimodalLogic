/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Fragments.Calculus
import FormalSystem.Metalogic.Conservativity.Fragments.PropComplete

/-!
# Conservativity of TM over the fragments of its language

A fragment of the language `L` is a set of formulas closed under the Boolean connectives. Its
logic is the part of TM whose derivations stay inside it. This directory states that logic as a
calculus and proves, for the fragments where it holds, that TM derives nothing new about the
formulas of the fragment.

**This file is the aggregator, and it holds no declarations.**

Each entry reads *Module* — *Contents*:

* `Conservativity/Fragments/Calculus.lean` — `Sublanguage`, `CellDerivable`, and the deduction
  theorem inside a sublanguage
* `Conservativity/Fragments/PropComplete.lean` — `evalProp`, `Tautology`, and
  `tautology_derivable`: propositional completeness inside a sublanguage
-/
