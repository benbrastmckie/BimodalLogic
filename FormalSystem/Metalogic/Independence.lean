/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.ClockFrame
import FormalSystem.Metalogic.Independence.LoopingDuration
import FormalSystem.Metalogic.Independence.CoNotPriorU
import FormalSystem.Metalogic.Independence.StaticFrame
import FormalSystem.Metalogic.Independence.RationalWitness
import FormalSystem.Metalogic.Independence.LexIntWitness

/-!
# Independence results

Underivability results, established by exhibiting a model of the assumptions in which the target
formula fails.

Three results are carried here, over six modules — the opening sentence of this docstring used to
say "the one result carried here", which stopped being true two witnesses ago:

1. The paper's `CO` principle does not derive Reynolds' `Axiom.prior_U_gap` over the dense base.
   The converse direction — Reynolds' triple *does* derive `CO` — is
   `FormalSystem.Theorems.DedekindDerived.co_derived`, so the two settle the relationship in both
   directions.
2. `Sat .Dedekind ⊊ Mod (AxiomSet .Dedekind)`, witnessed by the static frame over `ℚ`.
3. `Sat .Discrete ⊊ Mod (AxiomSet .Discrete)`, witnessed by the static frame over `ℤ ×ₗ ℤ`.

Results 2 and 3 are the two halves of the finding that the frame-class *narrowings* are not
Galois-closed, in contrast with the paper's bare classes.

## Contents

* `Independence/ClockFrame.lean` — the periodic clock frame `D = ℚ`, `W = ℚ ⧸ ℤ`, with all
  `FrameOver` obligations discharged, and its reference total history.
* `Independence/LoopingDuration.lean` — the reusable content: a frame carrying a *looping
  duration* has periodic histories, hence periodic truth, hence validates `Hψ → Gψ` and every
  instance of `CO`.
* `Independence/CoNotPriorU.lean` — the symmetric irrational arc valuation, the refutation of
  `Axiom.prior_U_gap` in that model, and the two independence statements.
* `Independence/StaticFrame.lean` — the static frame at an arbitrary duration group: full
  time-invariance from `LoopingDuration`, and the constant-truth `untl`/`snce` calculus that
  turns every later axiom check into a rewrite.
* `Independence/RationalWitness.lean` — `rat_not_complete`, the static frame over `ℚ` as a member
  of `Mod (AxiomSet .Dedekind)` outside `Sat .Dedekind`, and the Dedekind sandwich.
* `Independence/LexIntWitness.lean` — the discrete, non-Archimedean carrier `ℤ ×ₗ ℤ`, the static
  frame over it as a member of `Mod (AxiomSet .Discrete)` outside `Sat .Discrete`, and the
  Discrete sandwich with its semantic upper bound.

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
