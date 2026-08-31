/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.ClockFrame
import FormalSystem.Metalogic.Independence.LoopingDuration
import FormalSystem.Metalogic.Independence.CoNotPriorU

/-!
# Independence results

Underivability results, established by exhibiting a model of the assumptions in which the target
formula fails.

The one result carried here is that the paper's `CO` principle does not derive Reynolds'
`Axiom.prior_U_gap` over the dense base. The converse direction — Reynolds' triple *does* derive
`CO` — is `FormalSystem.Theorems.DedekindDerived.co_derived`, so the two files together settle
the relationship in both directions.

## Contents

* `Independence/ClockFrame.lean` — the periodic clock frame `D = ℚ`, `W = ℚ ⧸ ℤ`, with all
  `ParamTaskFrame` obligations discharged, and its reference total history.
* `Independence/LoopingDuration.lean` — the reusable content: a frame carrying a *looping
  duration* has periodic histories, hence periodic truth, hence validates `Hψ → Gψ` and every
  instance of `CO`.
* `Independence/CoNotPriorU.lean` — the symmetric irrational arc valuation, the refutation of
  `Axiom.prior_U_gap` in that model, and the two independence statements.

## The method

Every result here follows the same four steps, and the shape is worth naming because this is the
tree's first independence result:

1. build a concrete frame satisfying every structural axiom of the semantics;
2. prove a truth-invariance lemma for it — a symmetry or periodicity constraining *every* formula
   uniformly, by induction on `Formula` with the history universally quantified **inside** the
   induction, so that the `□` case (which ranges over all total histories) can apply the
   induction hypothesis;
3. show the assumed axioms hold in the model, taking the base axioms free from the matching
   `soundness_*` theorem;
4. `rintro ⟨d⟩` on the derivation, apply soundness at the concrete model, and contradict the
   refutation.
-/
