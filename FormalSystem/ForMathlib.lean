/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ForMathlib.Order.BallSpace
import FormalSystem.ForMathlib.Order.PFilter
import FormalSystem.ForMathlib.Topology.Sierpinski
import FormalSystem.Init

/-!
# ForMathlib — Mathlib-shaped extensions intended for upstreaming

Everything under `FormalSystem/ForMathlib/` is written in Mathlib's own namespaces, with lemma
names one-for-one with the Mathlib declarations they dualise or extend, so that when a file is
upstreamed it is simply deleted here and no consumer changes a name. The convention (`ForMathlib/`
beside the project's own tree) follows downstream-project precedent such as `PFR/ForMathlib/` and
`LeanLTL/ForMathlib.lean`; it is project precedent, not a Mathlib rule.

## Dependency rule

**Nothing under `FormalSystem/ForMathlib/` imports `FormalSystem.*`.** The import direction is
strictly `Mathlib → ForMathlib → FormalSystem.* → downstream`.

## Contents

* `FormalSystem.ForMathlib.Order.BallSpace` — ball spaces in the sense of Ćmiel, Kuhlmann and
  Kuhlmann: nests (`Order.IsNest`), spherical completeness `S₁` over an arbitrary ball predicate
  (`Order.SphericallyComplete`), cofinal nests (`Order.HasCofinalNest`), the hierarchy's
  implication `S₁ᵈ → S₁` in members-witness form (`Order.IsNest.exists_subset_inter`) and the
  reduction `Order.sInter_nonempty_of_sphericallyComplete`. Mathlib carries no ball-space API.
* `FormalSystem.ForMathlib.Order.PFilter` — proper, maximal and prime filters
  (`Order.PFilter.IsProper`, `Order.PFilter.IsMaximal`, `Order.PrimeFilter`), the filter side of
  `Mathlib/Order/Ideal.lean` and `Mathlib/Order/PrimeIdeal.lean`.
* `FormalSystem.ForMathlib.Topology.Sierpinski` — Sierpiński's theorem on countable closed
  partitions of the line (`Sierpinski.const_of_isClosed_levelSet`,
  `Sierpinski.const_of_countable_range`), which Mathlib does not carry: its `Sierpinski*`
  declarations are all about the Sierpiński *space*.
-/
