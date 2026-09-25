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
import FormalSystem.Metalogic.Independence.ZTimeSharpness
import FormalSystem.Metalogic.Independence.DenseRTimeSharpness
import FormalSystem.Metalogic.Independence.SepSharpness
import FormalSystem.Metalogic.Independence.RealTranslationFrame
import FormalSystem.Metalogic.Independence.DriftFrame
import FormalSystem.Metalogic.Independence.DriftHistories
import FormalSystem.Metalogic.Independence.OrderTransfer
import FormalSystem.Metalogic.Independence.StateSetTruth
import FormalSystem.Metalogic.Independence.DeterminismUndefinable
import FormalSystem.Metalogic.Independence.StabUndefinable
import FormalSystem.Metalogic.Independence.NaiveSystem
import FormalSystem.Metalogic.Independence.CoarsenedModels
import FormalSystem.Metalogic.Independence.PastedCoarseModels
import FormalSystem.Metalogic.Independence.PastingIndependence
import FormalSystem.Metalogic.Independence.StarDiscrimination
import FormalSystem.Metalogic.Independence.ForwardDeterministicFrame
import FormalSystem.Metalogic.Independence.LimitClosureFrame
import FormalSystem.Metalogic.Independence.LimitClosureCountermodel
import FormalSystem.Metalogic.Independence.PlusIncompleteness
import FormalSystem.Metalogic.Independence.TranslationProductCoarse

/-!
# Independence results

Underivability results, established by exhibiting a model of the assumptions in which the target
formula fails.

Twelve results are carried here. This list and the one in `Independence/README.md` enumerate the
same twelve results in the same order; earlier revisions of the two drifted apart (this docstring
carried six, the README nine, overlapping in five) and were reconciled to their union.

1. The paper's `CO` principle does not derive Reynolds' `Axiom.prior_U_gap` over the dense base.
   The converse direction — Reynolds' triple *does* derive `CO` — is
   `FormalSystem.Theorems.DedekindDerived.coDerived`, so the two settle the relationship in both
   directions.
2. `Sat .RTime ⊊ Mod (AxiomSet .RTime)`, witnessed by the static frame over `ℚ`
   (`sat_rtime_ssubset_mod_axiomSet`).
3. `Sat .ZTime ⊊ Mod (AxiomSet .ZTime)`, witnessed by the static frame over `ℤ ×ₗ ℤ`
   (`sat_ztime_ssubset_mod_axiomSet`).
4. The stability modal `⊡` is **not L-definable** (`stabNotDefinable`): no `Formula` is
   equivalent to `⊡Fp` across all task models. This is what makes L⁺ a genuinely larger language
   rather than notation for something L can already say.
5. `TaskFrame.Deterministic` is **not L⁺-definable** (`cor:no-characterization`,
   `deterministic_not_plusDefinable`), witnessed by the indistinguishable pair `F°`/`F¹` over
   `ℝ`. The same pair refutes the converse of the deterministic collapse
   (`PlusLanguage/PlusDeterminism.lean`): `F°` validates *Determined* without being
   deterministic.
6. The two **pasting schemata are not derivable** from the naive `⊡`-set {SK, ST, S4, S5, MS, AS}
   together with TM (`pasteNotNaiveDerivable`, `untlPasteNotNaiveDerivable`), so TM⁺'s axiom set
   is non-redundant (`plusAxiomSetNonRedundant`).
7. **Store and recall discriminate where nothing without them can**
   (`star_discriminates_where_plus_cannot`). `sent:det` is valid over the deterministic
   translation frame `F¹` and refuted over the drift frame `F°`, while result 5 shows that no set
   of `PlusFormula`s separates them at all.
8. **`sent:det` defines only *forward* determinism**. The frame `F^N` (`W = ℕ`, `D = ℤ`, the
   absorbing predecessor map) is forward-deterministic and **not** `Deterministic`, and `sent:det`
   is valid over it at every state-local instance. Replacing `\Future` by `always` closes the gap
   (`StarLanguage/StarDeterminism.lean`'s `deterministic_starDefinable`).
9. The current axiom set of TM⁺ is **incomplete at `.Base`** (`plus_incomplete_base`): the
   limit-closure formula `(⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))` is valid over every task
   frame and is refuted in a paste-closed coarsened-state model, for which TM⁺ is sound. Nothing
   is claimed about extensions of the axiom set, or about the other frame classes.
10. The `.ZTime` row of `Axiom.minFrameClass` is **characterized**, not merely upper-bounded
    (`prior_UZ_validIn_iff_ztime`, `z1_validIn_iff_ztime`): each axiom's atomic instance is valid
    at `fc` exactly when `fc = .ZTime`. Minimality is the weaker half
    (`prior_UZ_minFrameClass_sharp`, `z1_minFrameClass_sharp`): no frame class strictly below
    `.ZTime` validates `Axiom.prior_UZ` or `Axiom.z1`. `.Dense` and `.RTime` are incomparable with
    `.ZTime` rather than below it, so they are refuted separately
    (`not_validIn_dense_*`, `not_validIn_rtime_*`), and `Metalogic.axiom_validIn_min` supplies the
    one positive case.
11. The `.Dense` rows of `Axiom.minFrameClass` are **characterized** and its `prior_U_gap` row is
    **minimal**. `density_validIn_iff` and `dense_indicator_validIn_iff` give
    `ValidIn fc φ ↔ .Dense ≤ fc`, off a single refutation on the translation frame over `ℤ`
    (`density_minFrameClass_sharp`, `dense_indicator_minFrameClass_sharp`);
    `prior_U_gap_minFrameClass_sharp` refutes `Axiom.prior_U_gap` at both `.Base` and `.Dense`,
    the two classes strictly below `.RTime`, over the periodic clock frame. The module also
    proves the boundary that fixes where a `sep` refutation could live:
    `sep_validOn_of_isLeastPos` shows `sep` is vacuously valid on every frame with a least
    positive duration, so no discrete witness for it can exist. Result 12 supplies the dense one.
12. The `sep` row of `Axiom.minFrameClass` is **characterized** (`SepSharpness.lean`). One
    refutation on the translation frame over the Hahn group `Lex (ℚ →₀ ℚ)`, with the atom true
    exactly on the positive-index single-support generators, gives `not_validIn_base_sep` and
    `not_validIn_dense_sep` at once, hence `sep_minFrameClass_sharp` through
    `base_or_dense_of_lt_rtime`. Unlike `prior_U_gap`, the `.ZTime` case is *positive* and
    schematic in `φ`: `sep_validIn_ztime` derives it from result 11's
    `sep_validOn_of_isLeastPos`, since `IsZTime` supplies a successor order and hence a least
    positive duration. So the characterization `sep_validIn_iff` reads
    `ValidIn fc φ ↔ fc = .ZTime ∨ .RTime ≤ fc`, not `↔ .RTime ≤ fc`, which would be false. The
    underivability corollary is `not_derivable_dense_sep`.

Results 2 and 3 are the two halves of the finding that the frame-class *narrowings* are not
Galois-closed, in contrast with the paper's bare classes. Results 10, 11 and 12 together settle
every row of `Axiom.minFrameClass`: each tag is now known minimal, and every non-`.Base` row is
characterized outright.

## Contents

* `Independence/ClockFrame.lean` — the periodic clock frame `D = ℚ`, `W = ℚ ⧸ ℤ`, with all
  `FrameOver` obligations discharged, and its reference world history.
* `Independence/LoopingDuration.lean` — the reusable content: a frame carrying a *looping
  duration* has periodic histories, hence periodic truth, hence validates `Hψ → Gψ` and every
  instance of `CO`.
* `Independence/CoNotPriorU.lean` — the symmetric irrational arc valuation, the refutation of
  `Axiom.prior_U_gap` in that model, and the two independence statements.
* `Independence/CoarsenedModels.lean` — the non-standard semantics the pasting-independence
  argument runs on: `CoarseModel`, `SameUnder`, `CTruthAt`, the structural ports, the atomization
  transfer, the six naive `⊡` validities, and naive soundness `naive_cValid`.
* `Independence/NaiveSystem.lean` — TM⁺ with the two pasting axioms withheld, as a predicate on
  the existing derivation trees (`NaiveOnly`, `NaiveDerivable`) rather than a second axiom
  inductive, plus its derived rules.
* `Independence/PastingIndependence.lean` — the refutation of both pasting schemata in one
  coarsened model: `pasteNotNaiveDerivable`, `untlPasteNotNaiveDerivable`,
  `plusAxiomSetNonRedundant`.
* `Independence/StabUndefinable.lean` — `stabNotDefinable`: no `Formula` is equivalent to `⊡Fp`
  over all task models, by a `TruthCorr` between the permissive frame over `ℤ` and the
  deterministic clock.
* `Independence/StarDiscrimination.lean` — the positive half of the discrimination footnote: the
  drift model with `|p| = [3/2, ∞)`, `fzero_refutes_sentDet`, `f1_sentDet`, and
  `star_discriminates_where_plus_cannot`.
* `Independence/ForwardDeterministicFrame.lean` — `F^N` (`W = ℕ`, `D = ℤ`, the absorbing
  predecessor map): forward-deterministic and not `Deterministic`, with `fn_sentDet_stateLocal`,
  `fn_separates`, and the two-sided bound `fn_sentDet_bounds`.
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
* `Independence/DriftFrame.lean` — `F°`, the drift band `x ≤ u - w ≤ 2x` over `ℝ`, regular
  (`fzeroFrame_isRegular`) and failing `def:deterministic`.
* `Independence/DriftHistories.lean` — `F°`'s world histories are strictly increasing
  bi-Lipschitz bijections of `ℝ`; (H1) and (H2) discharged for `F°`.
* `Independence/OrderTransfer.lean` — the frame-independent layer: hypotheses (H1) `OrderFlow`
  and (H2) `StateOccurs`, and the order-transfer lemmas the temporal cases consume.
* `Independence/StateSetTruth.lean` — `satSet` and the state-set bridge: over an (H1)+(H2) frame,
  L⁺ truth depends only on the world state of evaluation.
* `Independence/DeterminismUndefinable.lean` — the instantiation at `F°` and `F¹`, and
  `deterministic_not_plusDefinable`.
* `Independence/PastedCoarseModels.lean` — `CoarseModel.PasteClosed` (the splice exists at the
  level of `π`-images), under which PS and US are coarsely valid, so that every `.Base` theorem
  of TM⁺ is valid on every paste-closed coarse model (`not_plusDerivable_of_pcRefuted`).
* `Independence/LimitClosureFrame.lean` — `EF`, the budgeted digraph with a hub on
  `Option (Bool × ℕ)` over `ℤ`, with every `FrameOver` field discharged (*Saturation* by "contains
  the hub or is finite"), and the correspondence between its world histories and `eR`-walks.
* `Independence/LimitClosureCountermodel.lean` — the coarse model `eK` on `EF`: the `π`-image of
  its world histories is exactly the eventually-false sequences, which is paste-closed and not
  closed; `blc_cRefuted` and `blc_not_plusDerivable_base`.
* `Independence/PlusIncompleteness.lean` — the assembly: `plus_incomplete_base` and
  `not_plus_complete_base`.
* `Independence/TranslationProductCoarse.lean` — coarse models on the translation product
  (`Semantics/Frames/TranslationProduct.lean`, a proof device, never an intended model): `liftK`,
  `c_invariance`, paste-closure in both directions (`pasteClosed_liftK`, `pasteClosed_of_liftK`)
  and the transfer of coarse refutations to a recurrence-free frame with *Limit* for free
  (`c_refuted_lift`). Not an underivability result in its own right; the route a future one
  over a non-Limit frame would take.
* `Independence/ZTimeSharpness.lean` — the full characterization of the `.ZTime` row of
  `Axiom.minFrameClass`: both `.ZTime`-tagged axioms are refuted on the translation frame over any
  densely ordered duration group, hence are not valid at `.Base`, hence — `.Base` being the unique
  class strictly below `.ZTime` (`eq_base_of_lt_ztime`) — not valid at any class below `.ZTime`;
  and separately not valid at `.Dense` or `.RTime`, which are incomparable with `.ZTime`. With
  `axiom_validIn_min` for the positive case, `prior_UZ_validIn_iff_ztime` and
  `z1_validIn_iff_ztime` give `ValidIn fc φ ↔ fc = .ZTime`. What is refuted is discreteness,
  not the Archimedean property.
* `Independence/DenseRTimeSharpness.lean` — the same treatment for the `.Dense` and `.RTime` rows
  of `Axiom.minFrameClass`: `density_validIn_iff` and `dense_indicator_validIn_iff` characterize
  the two `.Dense`-tagged axioms off one refutation on the translation frame over `ℤ`;
  `prior_U_gap_minFrameClass_sharp` closes both classes strictly below `.RTime` off one refutation
  on the clock frame; and `sep_validOn_of_isLeastPos` proves the obstruction that confines any
  `sep` refutation to a densely ordered duration group.
* `Independence/SepSharpness.lean` — the `sep` row, over the Hahn group `Lex (ℚ →₀ ℚ)`: the
  missing `DenselyOrdered` instance, the single-support generators and the region they span, the
  three accumulation facts about it, and `not_validOn_sep_lexHahn`, from which
  `sep_minFrameClass_sharp` closes both classes strictly below `.RTime` at once. With the
  positive `sep_validIn_ztime`, `sep_validIn_iff` characterizes the row as
  `ValidIn fc φ ↔ fc = .ZTime ∨ .RTime ≤ fc` — the one row whose shape differs from the others,
  because `.ZTime` is incomparable with `.RTime` and `sep` is valid there.

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
