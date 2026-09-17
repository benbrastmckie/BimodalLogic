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
import FormalSystem.Metalogic.Independence.RealTranslationFrame
import FormalSystem.Metalogic.Independence.DriftFrame
import FormalSystem.Metalogic.Independence.DriftHistories
import FormalSystem.Metalogic.Independence.OrderTransfer
import FormalSystem.Metalogic.Independence.StateSetTruth
import FormalSystem.Metalogic.Independence.DeterminismUndefinable
import FormalSystem.Metalogic.Independence.StabUndefinable
import FormalSystem.Metalogic.Independence.NaiveSystem
import FormalSystem.Metalogic.Independence.CoarsenedModels
import FormalSystem.Metalogic.Independence.PastingIndependence
import FormalSystem.Metalogic.Independence.StarDiscrimination
import FormalSystem.Metalogic.Independence.ForwardDeterministicFrame

/-!
# Independence results

Underivability results, established by exhibiting a model of the assumptions in which the target
formula fails.

Four results are carried here, over twelve modules — the opening sentence of this docstring used
to say "the one result carried here", which stopped being true three witnesses ago:

1. The paper's `CO` principle does not derive Reynolds' `Axiom.prior_U_gap` over the dense base.
   The converse direction — Reynolds' triple *does* derive `CO` — is
   `FormalSystem.Theorems.DedekindDerived.coDerived`, so the two settle the relationship in both
   directions.
2. `Sat .RTime ⊊ Mod (AxiomSet .RTime)`, witnessed by the static frame over `ℚ`.
3. `Sat .ZTime ⊊ Mod (AxiomSet .ZTime)`, witnessed by the static frame over `ℤ ×ₗ ℤ`.
4. `TaskFrame.Deterministic` is **not L⁺-definable** (`cor:no-characterization`), witnessed by
   the indistinguishable pair `F°`/`F¹` over `ℝ`. The same pair refutes the converse of the
   deterministic collapse (`Semantics/PlusLanguage/PlusDeterminism.lean`): `F°` validates *Determined*
   without being deterministic.

Results 2 and 3 are the two halves of the finding that the frame-class *narrowings* are not
Galois-closed, in contrast with the paper's bare classes.

## Contents

* `Independence/ClockFrame.lean` — the periodic clock frame `D = ℚ`, `W = ℚ ⧸ ℤ`, with all
  `FrameOver` obligations discharged, and its reference world history.
* `Independence/LoopingDuration.lean` — the reusable content: a frame carrying a *looping
  duration* has periodic histories, hence periodic truth, hence validates `Hψ → Gψ` and every
  instance of `CO`.
* `Independence/CoNotPriorU.lean` — the symmetric irrational arc valuation, the refutation of
  `Axiom.prior_U_gap` in that model, and the two independence statements.
* `Independence/StaticFrame.lean` — the static frame at an arbitrary duration group: full
  time-invariance from `LoopingDuration`, and the constant-truth `untl`/`snce` calculus that
  turns every later axiom check into a rewrite.
* `Independence/RationalWitness.lean` — `rat_not_complete`, the static frame over `ℚ` as a member
  of `Mod (AxiomSet .RTime)` outside `Sat .RTime`, and the Dedekind sandwich.
* `Independence/LexIntWitness.lean` — the discrete, non-Archimedean carrier `ℤ ×ₗ ℤ`, the static
  frame over it as a member of `Mod (AxiomSet .ZTime)` outside `Sat .ZTime`, and the
  Discrete sandwich with its semantic upper bound.
* `Independence/RealTranslationFrame.lean` — `realOrder`, and `F¹`, the deterministic
  translation flow over `ℝ`, built through `ShiftSet` so that its world-set characterization
  elaborates.
* `Independence/DriftFrame.lean` — `F°`, the drift band `x ≤ u - w ≤ 2x` over `ℝ`, with all five
  `FrameOver` axiom fields and its failure of `def:deterministic`.
* `Independence/DriftHistories.lean` — `F°`'s world histories are strictly increasing
  bi-Lipschitz bijections of `ℝ`; (H1) and (H2) discharged for `F°`.
* `Independence/OrderTransfer.lean` — the frame-independent layer: hypotheses (H1) `OrderFlow`
  and (H2) `StateOccurs`, and the order-transfer lemmas the temporal cases consume.
* `Independence/StateSetTruth.lean` — `satSet` and the state-set bridge: over an (H1)+(H2) frame,
  L⁺ truth depends only on the world state of evaluation.
* `Independence/DeterminismUndefinable.lean` — the instantiation at `F°` and `F¹`, and
  `deterministic_not_plusDefinable`.

## The method

Results 1-3 follow the same four steps, and the shape is worth naming because this was the
tree's first independence result. Result 4 is a variant: instead of *refuting* the target in one
model, it exhibits **two** models that agree on the whole language and disagree on the target
frame property — elimination by indistinguishability rather than by counterexample.

1. build a concrete frame satisfying every structural axiom of the semantics;
2. prove a truth-invariance lemma for it — a symmetry or periodicity constraining *every* formula
   uniformly, by induction on `Formula` with the history universally quantified **inside** the
   induction, so that the `□` case (which ranges over all world histories) can apply the
   induction hypothesis;
3. show the assumed axioms hold in the model, taking the base axioms free from the matching
   `soundness_*` theorem;
4. `rintro ⟨d⟩` on the derivation, apply soundness at the concrete model, and contradict the
   refutation.
-/
