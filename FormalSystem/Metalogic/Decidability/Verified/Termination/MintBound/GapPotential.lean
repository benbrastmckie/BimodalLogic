/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.UntlSnceFree

/-! # D6. The density coordinate: `gapPotential`

**The gap this section closes.** `densityRule` mints a fresh time while lying outside **both**
`freshLabelRules` and `selfGuardRules`. So at a `densityRule` step no disjunct of the
three-disjunct residual `MintPaysForTimeFixed` can move — for **any** σ whatsoever: disjunct 1
fails because the mint raises `knownTimes`, disjunct 2 cannot move because `densityRule` is not in
`mintPotential`'s index set, and disjunct 3 cannot move because `densityRule` is not in
`selfGuardPotential`'s. That is why `mintPaysForTimeFixed_of_not_dense` carries the hypothesis
`¬ (FrameClass.Dense ≤ fc)`: the rule is `denseRules`-gated, and off `.Dense` it simply never
fires. This section supplies the missing coordinate and retires that hypothesis.

**The component counts unfilled pairs, not open gaps, and that polarity choice is the design.**
`densityRule`'s gap-target filter has two conjuncts over `timeOrd.futureOf l.time`: (i) `t'` is
maximal — `(timeOrd.futureOf t').isEmpty` — and (ii) `t'` is not already reached through an
intermediate — `!(futureTimes.any fun t'' => (timeOrd.futureOf t'').contains t')`. Conjunct (i) is
**anti-monotone**: any rule minting a fresh maximal time creates a new gap *target*, so a ledger
over the rule's own target set *rises* at ordinary steps and cannot be a measure. Only conjunct
(ii) is monotone, and read with the polarity inverted it says *filled*. `gapFilled` is conjunct
(ii) transcribed verbatim in that inverted polarity — exactly as `selfGuardDischarged`
(`TimeReuse.lean`) transcribes `untlNeg`/`snceNeg`'s own guards, and for the same reason.

**What the component does not read.** `ord.timeCount`. The maxTime-lowering mechanism that refuted
earlier candidates — `nextTime_reissues_retired_time`, `reuse_driven_through_engine` — acts on that
quantity and on nothing else, and `densityRule`'s guard never mentions it. So the identification
arm, which can lower `timeCount`, has nothing to act on here; preservation is `futureOf_transport`
applied twice and nothing deeper.

**What is dropped from the shape the prior work expected.** The `U ×ˢ U` indexing holds up.
The `denseRules` gating does not, and is deliberately absent: monotonicity and the strict drop both
hold at every frame class, so gating would add an `fc` parameter to a measure that currently has
none for no soundness gain, and would reintroduce exactly the frame-class restriction this section
exists to retire.

## Contents

- `gapFilled` / `gapPotential`, the ceiling `gapPotential_le_sq`, and the growth (non-increase)
  facts `gapFilled_le_of_grow` / `gapPotential_le_of_grow`
- preservation across the identification arm: `gapFilled_identifyTime`,
  `gapPotential_identifyTime`, `gapPotential_identifyOriented` — Constraint (F) for this coordinate
- the payment: the `applyRule .densityRule` inversion facts and `gapPotential_lt_of_density`
- the refutation half: `mintPaysForTimeFixed_dense_false` and `mintPaysForTimeFixed_rtime_false`,
  which decide that the residual as landed is **false** at `.Dense` and `.RTime` rather than merely
  unproved there, so the repair below is a necessity rather than a preference
- the repair `MintPaysForTimeGap` and its direction lemma
  `mintPaysForTimeGap_of_mintPaysForTimeFixed`
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-! ### The component, its ceiling, and its growth -/

/-- **The gap between two times is filled**: some intermediate time lies strictly after `s` and
strictly before — reaches — `t`.

This is `densityRule`'s own *second* gap-target filter conjunct
(`!(futureTimes.any fun t'' => (timeOrd.futureOf t'').contains t')`, `Tableau.lean`) transcribed
verbatim with the polarity inverted: the rule fires at a target whose gap is **un**filled, so
"filled" is what a step of the rule achieves and what a measure over it can count down.

**The rule's *first* conjunct — `t'` is maximal in `s`'s future — is deliberately absent, and its
absence is the whole design.** That conjunct is anti-monotone: minting a fresh maximal time *adds*
a candidate target, so a ledger over the rule's own target set rises at ordinary steps and is not a
measure at all. Only this conjunct is monotone under ordering growth, which is what
`gapFilled_le_of_grow` records. The same polarity reasoning is written out at
`selfGuardDischarged`, whose catch-all is `true` for the identical reason: a column that can only
turn on is a column a measure can count down.

`ord.timeCount` is likewise absent, and here there is nothing to omit — `densityRule`'s guard never
mentions it. That is why the identification arm, which can lower `timeCount`, cannot touch this
coordinate. -/
def gapFilled (ord : TimeOrdering) (s t : TimeIndex) : Bool :=
  (ord.futureOf s).any fun m => (ord.futureOf m).contains t

/-- **The gap potential**: the number of ordered time pairs, drawn from the fixed index set
`U ×ˢ U` through the accumulated renaming σ, whose gap is **not** yet filled.

It takes no `Branch`, exactly like `selfGuardPotential`: filledness is a property of the ordering
alone, so the branch-growth half of `mintPotential`'s monotonicity has no analogue here and no call
site has to supply a branch-side hypothesis.

`σ` is the composition of the `rhoSF`s of the ordered splits taken so far, carried for the same
reason `mintPotential` and `selfGuardPotential` carry it: it keeps the index set fixed across the
whole run even as the arm renames the branch's times.

The index set is `U ×ˢ U` and **not** gated on `denseRules`. Gating was the shape prior work
expected; it is dropped because the growth, transport and payment facts below all hold at every
frame class, so an `fc` parameter would buy nothing and would reintroduce the frame-class
restriction the coordinate exists to retire. -/
def gapPotential (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (ord : TimeOrdering) : Nat :=
  ((U ×ˢ U).filter fun p => gapFilled ord (σ p.1).label.time (σ p.2).label.time = false).card

/-- **The ceiling**: the potential is bounded by `|U|²`, the size of its own index set. This is the
figure `derivedTmaxGap` and `mintPathBoundGap` are built on. -/
theorem gapPotential_le_sq (U : Finset SignedFormula) (σ : SignedFormula → SignedFormula)
    (ord : TimeOrdering) : gapPotential U σ ord ≤ U.card * U.card := by
  simp only [gapPotential]
  calc ((U ×ˢ U).filter fun p => gapFilled ord (σ p.1).label.time (σ p.2).label.time = false).card
      ≤ (U ×ˢ U).card := Finset.card_filter_le _ _
    _ = U.card * U.card := Finset.card_product _ _

/-- **A filled gap stays filled as the ordering grows.** Two applications of
`TimeOrdering.futureOf_mono`: the intermediate witness `m` is re-found in the larger ordering's
forward reach of `s`, and `t` is re-found in the larger ordering's forward reach of `m`, both at
the same fuel of `100` because the transport is length-preserving.

The hypothesis is supplied at every call site by the mint arms themselves: `addFuture` and
`addPast` only cons onto `ord.constraints`, so the pre-step constraint list is literally a sublist
of the post-step one. Modelled on `selfGuardDischarged_le_of_grow`. -/
theorem gapFilled_le_of_grow {ord ord' : TimeOrdering}
    (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) (s t : TimeIndex)
    (h : gapFilled ord s t = true) : gapFilled ord' s t = true := by
  simp only [gapFilled, List.any_eq_true, List.contains_iff_mem] at h ⊢
  obtain ⟨m, hm, ht⟩ := h
  exact ⟨m, TimeOrdering.futureOf_mono hord s m hm,
    TimeOrdering.futureOf_mono hord m t ht⟩

/-- **An ordinary step does not increase the gap potential.** The ordering grows, so `gapFilled` can
only turn on; contrapositively the after-`false` set is a *subset* of the before-`false` set inside
the same index set, and no injection is needed.

Transcribed from `selfGuardPotential_le_of_grow` with the inner lemma swapped and nothing else
changed. This covers `.extended`, `.split`, and the ordered split's first two arms — every step
that keeps σ. -/
theorem gapPotential_le_of_grow {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {ord ord' : TimeOrdering}
    (hord : ∀ q ∈ ord.constraints, q ∈ ord'.constraints) :
    gapPotential U σ ord' ≤ gapPotential U σ ord := by
  refine Finset.card_le_card ?_
  intro p hp
  simp only [Finset.mem_filter] at hp ⊢
  refine ⟨hp.1, ?_⟩
  rcases hd : gapFilled ord (σ p.1).label.time (σ p.2).label.time with _ | _
  · rfl
  · rw [gapFilled_le_of_grow hord _ _ hd] at hp
    exact absurd hp.2 (by simp)

/-! ### Preservation across the identification arm — Constraint (F) for this coordinate

**The obstacle the task description warned about does not arise here, and it is worth being
precise about why.** Every earlier candidate component died at the ordered split's arm 3 because
it was affine in a quantity `TimeOrdering.identifyTime` can *lower*: a mint raises
`ord.timeCount` and the identification arm lowers it, so no sign of coefficient satisfies both
(`nextTime_reissues_retired_time`, `reuse_driven_through_engine`). **Nothing in this coordinate
reads `ord.timeCount`** — `densityRule`'s own gap-target guard never mentions it, so `gapFilled`
transcribes a condition the lowering mechanism has no purchase on. What has to be shown instead is
only that the arm does not *raise* the uncured count, and it does not: no constraint is dropped at
an incomparable trigger (`identifyTime_no_collapse`), reachability transports edge by edge
(`futureOf_transport`) length-preservingly, so the filled set only grows and the unfilled count
only falls.

The `incomparableB ord (t₁, t₂)` side condition is not a new hypothesis: it is available at the
consuming site from `firstIncomparablePair_spec` and at the engine's own orientation from
`incomparableB_of_firstIncomparablePair_oriented`. `IrreflOrd` is the run invariant's own first
conjunct, and it is *necessary* rather than convenient —
`witnessPresent_identifyTime_unconditional_false` (register entry 5) refutes the `IrreflOrd`-free
form for the sibling predicate, and the reason carries over verbatim, since
`TimeOrdering.identifyTime` drops a pre-existing self-loop whose two endpoints rename together. -/

/-- **A filled gap survives the identification arm, renamed.**

`futureOf_transport` applied to **both** memberships, with the intermediate witness `m` carried to
`rho t₂ t₁ m`: the renamed witness is in the renamed source's forward reach, and the renamed target
is in the renamed witness's. Both transports are length-preserving, so the fuel of `100` is re-met
at the same length and the two hops never exceed it.

Modelled on `selfGuardDischarged_identifyTime`, one membership deeper. The column index lines up
because `rhoSF` acts on the label's time by exactly the `rho` the reach transport is stated at —
`rhoSF src tgt sf` is `sf` with `sf.label.time` replaced by `rho src tgt sf.label.time` — which is
what lets `gapPotential_identifyTime` below read this lemma at its own index set without moving
it. -/
theorem gapFilled_identifyTime {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (hinc : incomparableB ord (t₁, t₂) = true) (hnsl : IrreflOrd ord) (s t : TimeIndex)
    (h : gapFilled ord s t = true) :
    gapFilled (ord.identifyTime t₂ t₁) (rho t₂ t₁ s) (rho t₂ t₁ t) = true := by
  simp only [gapFilled, List.any_eq_true, List.contains_iff_mem] at h ⊢
  obtain ⟨m, hm, ht⟩ := h
  exact ⟨rho t₂ t₁ m, futureOf_transport ord t₁ t₂ hinc hnsl s m hm,
    futureOf_transport ord t₁ t₂ hinc hnsl m t ht⟩

/-- **The identification arm does not increase the gap potential.**

`Finset.card_le_card` over the previous lemma: the filter's `true`-set only grows, so the
`false`-set only shrinks, inside an index set that does not move. No injection from the after-set
into the before-set is required, and none is available — `rhoSF t₂ t₁` is not injective on `U`.
This is `selfGuardPotential_identifyTime`'s skeleton with the inner lemma swapped.

Because the renaming is **post-composed** onto the parameter, the statement applies unchanged at a
second, third or `n`-th identification along the same run. -/
theorem gapPotential_identifyTime {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (hinc : incomparableB ord (t₁, t₂) = true) (hnsl : IrreflOrd ord) :
    gapPotential U (fun x => rhoSF t₂ t₁ (σ x)) (ord.identifyTime t₂ t₁)
      ≤ gapPotential U σ ord := by
  refine Finset.card_le_card ?_
  intro p hp
  obtain ⟨hmem, hafter⟩ := Finset.mem_filter.mp hp
  refine Finset.mem_filter.mpr ⟨hmem, ?_⟩
  rcases hd : gapFilled ord (σ p.1).label.time (σ p.2).label.time with _ | _
  · rfl
  · exact absurd (hafter.symm.trans (gapFilled_identifyTime hinc hnsl _ _ hd)) (by simp)

/-- **…at the engine's own orientation.** `gapPotential_identifyTime` read at
`(min t₁ t₂, max t₁ t₂)`, which is the merge arm 3 actually performs.

One fact deeper and nothing else: `incomparableB_of_firstIncomparablePair_oriented` supplies the
side condition at the flipped pair. Mirrors `selfGuardPotential_identifyOriented`. -/
theorem gapPotential_identifyOriented {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂)) (hirr : IrreflOrd ord) :
    gapPotential U
        (fun x => rhoSF (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2 (σ x))
        (identifyOriented b ord t₁ t₂).2
      ≤ gapPotential U σ ord :=
  gapPotential_identifyTime (incomparableB_of_firstIncomparablePair_oriented htrig) hirr

/-! ### The strict drop at a density step — the payment

**The direction here is a GATE, not a nicety.** `gapPotential_lt_of_density` concludes a strict
`<`, never a `≤`, and its hypothesis list is not widened to make it close: the whole point of a
measure coordinate is that the step it pays for strictly spends it. Register entry 7 exists
because a weakening was once mistaken for a repair, and the same standard applies here. If the
strict drop had failed, the honest outcome would have been a recorded impossibility result rather
than a `≤` presented as a payment.

The payment is stated at the **ordering operation** rather than at the rule, exactly as
`selfGuardPotential_lt_of_addFuture` is: the content is that two fresh edges `(s, f)` and
`(f, t')` fill the gap `(s, t')`, and the rule's identity enters only through the inversion
lemmas above it, which say that `densityRule` is what produces those two edges and that its own
guard is what makes the gap unfilled beforehand. -/

/-- **`densityRule`'s own gap-target list**, transcribed verbatim from the rule's arm.

Both of the rule's filter conjuncts are here, in the rule's own order and polarity: (i) `t'` is
maximal in `s`'s forward reach, (ii) `t'` is not already reached through an intermediate. Only
(ii) is what `gapFilled` measures — see `gapFilled`'s docstring for why (i) is deliberately not a
measure coordinate — but the list itself needs both, because it is the rule's own selection and
the inversion lemmas below read the rule's `match` against it. -/
def densityGapTargets (ord : TimeOrdering) (s : TimeIndex) : List TimeIndex :=
  (ord.futureOf s).filter fun t' =>
    (ord.futureOf t').isEmpty
      && !((ord.futureOf s).any fun t'' => (ord.futureOf t'').contains t')

/-- **The rule's second filter conjunct, read as "the gap is unfilled".** This is the equation
that makes `gapFilled` the right transcription rather than a guess: the rule's own conjunct (ii)
on a selected target is literally `gapFilled ord s t' = false`. -/
theorem gapFilled_eq_false_of_mem_densityGapTargets {ord : TimeOrdering} {s t' : TimeIndex}
    (h : t' ∈ densityGapTargets ord s) : gapFilled ord s t' = false := by
  simp only [densityGapTargets, List.mem_filter, Bool.and_eq_true, Bool.not_eq_true'] at h
  exact h.2.2

/-- **A selected target lies in the source's forward reach.** The `U`-side membership the density
bucket needs for its target column: under `OrdTimesKnown` this puts `t'` in the branch's known
times, and confinement then puts a formula at `t'` in `U`. -/
theorem mem_futureOf_of_mem_densityGapTargets {ord : TimeOrdering} {s t' : TimeIndex}
    (h : t' ∈ densityGapTargets ord s) : t' ∈ ord.futureOf s :=
  List.mem_of_mem_filter h

/-- **`densityRule`'s trigger shape, recovered from `isApplicable`.** The rule's arm is
`| .densityRule, .pos, .allFuture _ => decide (FrameClass.Dense ≤ fc)`, so applicability fixes the
sign and the formula's top constructor. Destructuring `sf` in the conclusion is what lets the
consumer feed the inversion lemmas below, whose trigger argument is a literal
`⟨Sign.pos, Formula.allFuture ψ, l⟩`, without a further rewrite. -/
theorem isApplicable_densityRule_trigger {sf : SignedFormula}
    {fc : FormalSystem.ProofSystem.FrameClass}
    (hA : isApplicable TableauRule.densityRule sf fc = true) :
    ∃ ψ l, sf = ⟨Sign.pos, Formula.allFuture ψ, l⟩ := by
  obtain ⟨sign, φ, l⟩ := sf
  cases sign
  case neg => simp [isApplicable] at hA
  case pos =>
    -- `Formula.allFuture ψ` is the derived shape `((⊥ → ⊥) untl (ψ → ⊥)) → ⊥`, so the arm's
    -- pattern is only visible once the implication, the `untl`, its guard and its event are all
    -- split apart. Same extra nesting `applyRule_allFuturePos_emitted_nil_of_untlSnceFree`
    -- needs, and for the same reason.
    cases φ with
    | imp a c =>
        cases c with
        | bot =>
            cases a with
            | untl g e =>
                cases g with
                | imp g1 g2 =>
                    cases g1 with
                    | bot =>
                        cases g2 with
                        | bot =>
                            cases e with
                            | imp e1 e2 =>
                                cases e2 with
                                | bot => exact ⟨e1, l, rfl⟩
                                | _ => simp [isApplicable] at hA
                            | _ => simp [isApplicable] at hA
                        | _ => simp [isApplicable] at hA
                    | _ => simp [isApplicable] at hA
                | _ => simp [isApplicable] at hA
            | _ => simp [isApplicable] at hA
        | _ => simp [isApplicable] at hA
    | _ => simp [isApplicable] at hA

/-- **The rule fires only into a nonempty target list**, inverted from a non-`notApplicable`
result. One `by_contra`-shaped rewrite and no arm analysis: on a trigger the arm accepts there are
exactly two outcomes — the `t' :: _` branch, or `.notApplicable` — so a reported result that is not
`.notApplicable` *forces* the list nonempty. Same inversion shape as
`applyRule_untlNeg_active_guard`. -/
theorem applyRule_densityRule_targets_ne_nil {ψ : Formula} {l : Label} {b : Branch}
    {ord : TimeOrdering} {res : RuleResult} {o : TimeOrdering}
    (hA : applyRule TableauRule.densityRule ⟨Sign.pos, Formula.allFuture ψ, l⟩ b ord = (res, o))
    (hne : res ≠ RuleResult.notApplicable) : densityGapTargets ord l.time ≠ [] := by
  intro hnil
  simp only [densityGapTargets] at hnil
  rw [show applyRule TableauRule.densityRule ⟨Sign.pos, Formula.allFuture ψ, l⟩ b ord
      = (RuleResult.notApplicable, ord) by
    simp only [applyRule, Formula.allFuture, Formula.someFuture, Formula.neg, Formula.top]
    rw [hnil]] at hA
  exact hne (by simp_all)

/-- **The ordering the rule returns, read off the engine.** Two edges and nothing else:
`l.time < freshTime` and `freshTime < t'`, where `freshTime` is `b.nextTime` and `t'` is the head
of the rule's own target list. This is what makes `gapPotential_lt_of_density`'s `addFuture`
hypotheses the engine's own output rather than a modelling choice. -/
theorem applyRule_densityRule_ord {ψ : Formula} {l : Label} {b : Branch} {ord : TimeOrdering}
    {t' : TimeIndex} {tail : List TimeIndex}
    (hgt : densityGapTargets ord l.time = t' :: tail) :
    (applyRule TableauRule.densityRule ⟨Sign.pos, Formula.allFuture ψ, l⟩ b ord).2
      = (ord.addFuture l.time b.nextTime).addFuture b.nextTime t' := by
  simp only [densityGapTargets] at hgt
  simp only [applyRule, Formula.allFuture, Formula.someFuture, Formula.neg, Formula.top]
  rw [hgt]

/-- **The two inversions assembled**: at a firing `densityRule` the target list has a head, the
head's gap is unfilled, the head is in the trigger's forward reach, and the returned ordering is
the two-edge interpolation at that head. This is the single fact the density bucket consumes. -/
theorem applyRule_densityRule_shape {ψ : Formula} {l : Label} {b : Branch} {ord : TimeOrdering}
    {res : RuleResult} {o : TimeOrdering}
    (hA : applyRule TableauRule.densityRule ⟨Sign.pos, Formula.allFuture ψ, l⟩ b ord = (res, o))
    (hne : res ≠ RuleResult.notApplicable) :
    ∃ t', gapFilled ord l.time t' = false ∧ t' ∈ ord.futureOf l.time
      ∧ o = (ord.addFuture l.time b.nextTime).addFuture b.nextTime t' := by
  rcases hgt : densityGapTargets ord l.time with _ | ⟨t', tail⟩
  · exact absurd hgt (applyRule_densityRule_targets_ne_nil hA hne)
  · have hmem : t' ∈ densityGapTargets ord l.time := by rw [hgt]; exact List.mem_cons_self
    refine ⟨t', gapFilled_eq_false_of_mem_densityGapTargets hmem,
      mem_futureOf_of_mem_densityGapTargets hmem, ?_⟩
    have ho := applyRule_densityRule_ord (ψ := ψ) (b := b) hgt
    rw [hA] at ho
    exact ho

/-- **Interpolating into an unfilled gap strictly drops the gap potential.**

Stated at the ordering operation rather than at the rule, for the same reason
`selfGuardPotential_lt_of_addFuture` is: the content is that the two fresh edges `(s, f)` and
`(f, t')` fill the column `(s, t')`, and `gapFilled_le_of_grow` says no other column can flip the
other way, because edges are added and never removed. One column strictly lost from a set that
only shrinks is a strict decrease.

**The conclusion is a strict `<`.** It is not a `≤`, and the hypothesis list below is not widened
to make it close — see the section prose on register entry 7.

Every hypothesis is one a consumer already has. `hunfilled` is the rule's own conjunct (ii),
supplied by `applyRule_densityRule_shape`. The two σ-hits are supplied at the engine level by
`SigmaFixed` plus confinement for the trigger, and by `mem_knownTimes_of_mem_futureOf` under
`OrdTimesKnown` plus confinement for the target. Nothing is assumed about the frame class, `Tmax`,
or the shape of `U` — which is why the discharge this feeds carries no frame-class hypothesis.

The fresh time `f` never appears in a reach longer than one edge here, so `futureOf`'s fuel of
`100` is nowhere near reached. -/
theorem gapPotential_lt_of_density {U : Finset SignedFormula}
    {σ : SignedFormula → SignedFormula} {ord : TimeOrdering} {s f t' : TimeIndex}
    (hunfilled : gapFilled ord s t' = false)
    {x y : SignedFormula} (hx : x ∈ U) (hy : y ∈ U)
    (hhx : (σ x).label.time = s) (hhy : (σ y).label.time = t') :
    gapPotential U σ ((ord.addFuture s f).addFuture f t') < gapPotential U σ ord := by
  have hgrow : ∀ q ∈ ord.constraints, q ∈ ((ord.addFuture s f).addFuture f t').constraints := by
    intro q hq
    simp only [TimeOrdering.addFuture, List.mem_cons]
    exact Or.inr (Or.inr hq)
  refine Finset.card_lt_card ⟨?_, ?_⟩
  · intro p hp
    obtain ⟨hmem, hafter⟩ := Finset.mem_filter.mp hp
    refine Finset.mem_filter.mpr ⟨hmem, ?_⟩
    rcases hd : gapFilled ord (σ p.1).label.time (σ p.2).label.time with _ | _
    · rfl
    · exact absurd (hafter.symm.trans (gapFilled_le_of_grow hgrow _ _ hd)) (by simp)
  · intro hsub
    have hcol : ((x, y) : SignedFormula × SignedFormula)
        ∈ (U ×ˢ U).filter
          (fun p => gapFilled ord (σ p.1).label.time (σ p.2).label.time = false) := by
      refine Finset.mem_filter.mpr ⟨Finset.mem_product.mpr ⟨hx, hy⟩, ?_⟩
      rw [hhx, hhy]
      exact hunfilled
    have hfilled : gapFilled ((ord.addFuture s f).addFuture f t') s t' = true := by
      simp only [gapFilled, List.any_eq_true, List.contains_iff_mem]
      refine ⟨f, mem_futureOf_of_mem_constraints _ s f ?_,
        mem_futureOf_of_mem_constraints _ f t' ?_⟩
      · simp [TimeOrdering.addFuture]
      · simp [TimeOrdering.addFuture]
    have hafter := (Finset.mem_filter.mp (hsub hcol)).2
    rw [hhx, hhy, hfilled] at hafter
    exact absurd hafter (by simp)

/-! ### The refutation half: the landed residual is **false** at `.Dense` and `.RTime`

The repair below is a **necessity**, not a preference, and this subsection is what establishes
that. `mintPaysForTimeFixed_of_not_dense` discharges `MintPaysForTimeFixed` under
`¬ (FrameClass.Dense ≤ fc)`, and the natural next ask — extend that discharge to `.Dense` and
`.RTime` — cannot be met, because the predicate is **refuted** there rather than merely unproved.

**Why all three disjuncts fail, independently of any witness.** At a `densityRule` step:

* disjunct 1 fails because the step mints a fresh time, so `knownTimes` strictly *rises* and the
  first conjunct `|kt nb| ≤ |kt b|` is false (and the rank conjunct rises with it, by
  `splitOrderedRank_lt_of_knownTimes_lt`);
* disjunct 2 cannot move because `densityRule ∉ freshLabelRules`, so `mintPotential`'s index set
  `freshLabelRules ×ˢ U` never mentions the rule and the count is unchanged;
* disjunct 3 cannot move because `densityRule ∉ selfGuardRules`, so `selfGuardPotential`'s index
  set never mentions it either and that count is unchanged too.

None of these three facts mentions σ, which is why the universally quantified σ in the predicate
buys nothing: **no** choice of σ rescues it. The witnesses below decide it; the prose above is
what explains it.

**The vehicle.** One branch, three formulas, at which the engine's very next step *is* a density
step — no prior steps needed. At `[T(Gp)@(0,0), F(F¬p)@(0,0), T(p)@(0,1)]` with ordering `0 < 1`,
every cheaper rule is already exhausted at the trigger: `negPos`'s output `F(F¬p)@(0,0)` is
already on the branch, `allFuturePos`'s propagation `T(p)@(0,1)` is already on the branch, and
`orderTrichotomy` has no incomparable pair to work with. So `densityRule` fires, interpolating the
fresh time `2` into the gap `0 < 1`, and it does so identically at `.Dense` and at `.RTime`.

Measured at the vehicle and then kernel-decided below (`|U| = 3`): `knownTimes` `2 → 3`,
`mintPotential` `24 → 24`, `selfGuardPotential` `3 → 3`, `mintTimeBudget` `26 → 27`,
`splitOrderedRank 3` `20 → 30` — and `gapPotential` `9 → 7`, which is the coordinate this file
adds and the only one that moves.

Nothing here deletes, weakens or restates `mintPaysForTimeFixed_of_not_dense`. It remains the
correct statement at `.Base` and `.ZTime`, and is superseded in prose only. -/

/-- The witness atom. -/
private def gapWitnessAtom : Formula := .atom (Atom.mkBase "p")

/-- `G p`, the density trigger. -/
private def gapWitnessG : Formula := Formula.allFuture gapWitnessAtom

/-- `F ¬p`, carried negatively so that `negPos`'s output at the trigger is already present and the
cheaper rule reports nothing. -/
private def gapWitnessF : Formula := Formula.someFuture (Formula.neg gapWitnessAtom)

/-- The witness branch. `T(p)@(0,1)` exists so that `allFuturePos`'s propagation into the one
future time is already present too, and so that time `1` — which the ordering's single constraint
mentions — is a known time, as `OrdTimesKnown` requires. -/
private def gapWitnessBranch : Branch :=
  [SignedFormula.pos gapWitnessG ⟨0, 0⟩, SignedFormula.neg gapWitnessF ⟨0, 0⟩,
   SignedFormula.pos gapWitnessAtom ⟨0, 1⟩]

/-- The witness ordering: `0 < 1`, one unfilled maximal gap, which is exactly `densityRule`'s
gap-target condition. -/
private def gapWitnessOrd : TimeOrdering := { constraints := [(0, 1)] }

/-- The witness universe: the branch itself, so confinement is immediate. -/
private def gapWitnessUniverse : Finset SignedFormula :=
  {SignedFormula.pos gapWitnessG ⟨0, 0⟩, SignedFormula.neg gapWitnessF ⟨0, 0⟩,
   SignedFormula.pos gapWitnessAtom ⟨0, 1⟩}

/-- The successor the density step reports: the interpolant `T(p)@(0,2)` consed onto the branch,
which the rule keeps because it is `.persistent`. -/
private def gapWitnessSucc : Branch :=
  [SignedFormula.pos gapWitnessAtom ⟨0, 2⟩, SignedFormula.pos gapWitnessG ⟨0, 0⟩,
   SignedFormula.neg gapWitnessF ⟨0, 0⟩, SignedFormula.pos gapWitnessAtom ⟨0, 1⟩]

/-- The witness state satisfies the run invariant, so the refutation is not reached by feeding the
predicate a state the engine cannot occupy. -/
private theorem gapWitness_runInvariant : RunInvariant gapWitnessBranch gapWitnessOrd := by
  constructor
  · unfold IrreflOrd gapWitnessOrd; decide
  · unfold OrdTimesKnown; decide

/-- …and it is confined to the witness universe. -/
private theorem gapWitness_confined : ∀ x ∈ gapWitnessBranch, x ∈ gapWitnessUniverse := by decide

/-- …and `σ = id` satisfies the predicate's own σ clause for free, so the refutation does not turn
on an exotic renaming. This matters: register entry 17's refutation of `MintPaysForTimeAt` turned
on a σ no run produces, and that is precisely the objection this witness does not invite. -/
private theorem gapWitness_sigmaFixed : SigmaFixed id gapWitnessBranch := fun _ _ => rfl

/-- **`MintPaysForTimeFixed` is false at `.Dense`.** Decided, at a configuration the engine itself
drives, with `σ = id`.

All three disjuncts fail at the same step, and the section prose above says why they must — this
theorem is the kernel's confirmation of that argument rather than a separate fact. The consequence
is that "extend the `MintPaysForTimeFixed` discharge to `.Dense`" is not an open goal but a
refuted one; the repair `MintPaysForTimeGap` below is what replaces it. -/
theorem mintPaysForTimeFixed_dense_false :
    ∃ (U : Finset SignedFormula) (Tmax : Nat),
      ¬ MintPaysForTimeFixed FormalSystem.ProofSystem.FrameClass.Dense U Tmax := by
  refine ⟨gapWitnessUniverse, 3, ?_⟩
  intro h
  have key := h id gapWitnessBranch gapWitnessOrd EventualityTracker.empty
    gapWitness_runInvariant gapWitness_confined gapWitness_sigmaFixed
  rcases key gapWitnessSucc (by decide) with ⟨h1, -⟩ | ⟨-, h2⟩ | ⟨-, h3⟩
  · exact absurd h1 (by decide)
  · exact absurd h2 (by decide)
  · exact absurd h3 (by decide)

/-- **…and at `.RTime`**, the Dedekind-complete class, where the same vehicle drives the same step:
`densityRule` is `denseRules`-gated and `FrameClass.Dense ≤ FrameClass.RTime`, and the Dedekind
rules — which `allRulesForFC` puts *ahead* of the base rules — all trigger on a conjunction, which
the trigger `T(G p)` is not. So the pick, the successor and every figure are identical. -/
theorem mintPaysForTimeFixed_rtime_false :
    ∃ (U : Finset SignedFormula) (Tmax : Nat),
      ¬ MintPaysForTimeFixed FormalSystem.ProofSystem.FrameClass.RTime U Tmax := by
  refine ⟨gapWitnessUniverse, 3, ?_⟩
  intro h
  have key := h id gapWitnessBranch gapWitnessOrd EventualityTracker.empty
    gapWitness_runInvariant gapWitness_confined gapWitness_sigmaFixed
  rcases key gapWitnessSucc (by decide) with ⟨h1, -⟩ | ⟨-, h2⟩ | ⟨-, h3⟩
  · exact absurd h1 (by decide)
  · exact absurd h2 (by decide)
  · exact absurd h3 (by decide)

/-- **The gap coordinate does move at the same step**, so the repair below is not merely consistent
with the refutation — it is paid for at the very configuration that refutes the landed predicate.
`9 → 7` at `|U| = 3`, decided rather than evaluated. -/
theorem gapPotential_lt_at_gapWitness :
    gapPotential gapWitnessUniverse id
        (expandOnceUnblocked gapWitnessBranch gapWitnessOrd
          FormalSystem.ProofSystem.FrameClass.Dense EventualityTracker.empty).2
      < gapPotential gapWitnessUniverse id gapWitnessOrd := by decide

/-! ### The repaired residual, and the direction lemma that makes it a repair

A repaired predicate is not landed in this file without a direction lemma. Register entry 7 exists
because a weakening was once mistaken for a repair, and the standard it set is that the
implication has to be *stated* and *proved*, in words and in Lean, in the same place the
definition lands. -/

/-- **The repaired time-minting residual, with the density coordinate.**
`MintPaysForTimeFixed`'s three disjuncts **verbatim** — same order, same conjuncts, same
hypothesis list — plus a **fourth** and nothing removed.

The fourth disjunct is the density coordinate: a `densityRule` step is paid for by filling one of
the gaps the rule's own guard selected, which is invisible to all three existing disjuncts. At
such a step disjunct 1 fails because the mint raises `knownTimes`, disjunct 2 cannot move because
`densityRule ∉ freshLabelRules` so `mintPotential`'s index set never mentions the rule, and
disjunct 3 cannot move because `densityRule ∉ selfGuardRules` — **for every σ whatsoever**, which
is why no choice of σ rescues the landed predicate. `mintPaysForTimeFixed_dense_false` and
`mintPaysForTimeFixed_rtime_false` decide that.

**The direction.** Nothing is dropped and a disjunct is added, so this predicate is **weaker**
than `MintPaysForTimeFixed`: the implication runs `Fixed → Gap` and never the other way, and every
theorem restated against it is a **strengthening**. That is
`mintPaysForTimeGap_of_mintPaysForTimeFixed` below, the `universeClosedAt_of_universeClosed` idiom
once more.

**What the fourth disjunct is NOT.** It is not a re-indexing of `mintPotential` on
`freshTimeRules` instead of `freshLabelRules` — register entry 14's first forbidden move, refuted
by `witnessPresent_eq_false_of_not_freshLabel`, whose match has exactly eight arms so the three
added columns would be permanently false and the component permanently inert. And it does not drop
disjunct 1's cardinality conjunct in favour of the ordering-rank conjunct alone — entry 14's
second forbidden move, refuted by `splitOrderedRank_lt_of_knownTimes_lt` together with
`mintPaysForTime_rank_repair_false`. Neither is attempted here: the first three disjuncts are
copied unchanged, and the new coordinate is a fresh ledger over a fresh index set `U ×ˢ U`.

The combined conjunct is paired with the strict drop rather than offered bare, for the same reason
disjunct 3's is: a bare drop is refuted (register entry 19's route 2), and the pairing is what
makes the whole measure's arithmetic close exactly. -/
def MintPaysForTimeGap (fc : FormalSystem.ProofSystem.FrameClass) (U : Finset SignedFormula)
    (Tmax : Nat) : Prop :=
  ∀ (σ : SignedFormula → SignedFormula) (b : Branch) (ord : TimeOrdering)
    (tr : EventualityTracker), RunInvariant b ord → (∀ x ∈ b, x ∈ U) → SigmaFixed σ b →
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      (nb.knownTimes.toFinset.card ≤ b.knownTimes.toFinset.card ∧
        splitOrderedRank Tmax nb (expandOnceUnblocked b ord fc tr).2
          ≤ splitOrderedRank Tmax b ord)
      ∨ (mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
            ≤ mintTimeBudget U σ b ord ∧
          mintPotential U σ nb (expandOnceUnblocked b ord fc tr).2
            < mintPotential U σ b ord)
      ∨ (mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
            + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
            ≤ mintTimeBudget U σ b ord + selfGuardPotential U σ ord ∧
          selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
            < selfGuardPotential U σ ord)
      ∨ (mintTimeBudget U σ nb (expandOnceUnblocked b ord fc tr).2
            + selfGuardPotential U σ (expandOnceUnblocked b ord fc tr).2
            + gapPotential U σ (expandOnceUnblocked b ord fc tr).2
            ≤ mintTimeBudget U σ b ord + selfGuardPotential U σ ord + gapPotential U σ ord ∧
          gapPotential U σ (expandOnceUnblocked b ord fc tr).2 < gapPotential U σ ord)

/-- **Direction lemma.** Nothing is dropped and a disjunct is added, so `MintPaysForTimeGap` is
**weaker** than `MintPaysForTimeFixed` and every theorem restated against it is a strengthening.
The implication runs `Fixed → Gap` and never the other way.

The predicate above is not landed without this lemma; see the section prose and register entry 7.
This is the `universeClosedAt_of_universeClosed` idiom. -/
theorem mintPaysForTimeGap_of_mintPaysForTimeFixed
    {fc : FormalSystem.ProofSystem.FrameClass} {U : Finset SignedFormula} {Tmax : Nat}
    (h : MintPaysForTimeFixed fc U Tmax) : MintPaysForTimeGap fc U Tmax := by
  intro σ b ord tr hri hconf hfix nb hnb
  rcases h σ b ord tr hri hconf hfix nb hnb with h1 | h2 | h3
  · exact Or.inl h1
  · exact Or.inr (Or.inl h2)
  · exact Or.inr (Or.inr (Or.inl h3))

/-- …and the composite from the predicate the chain started at, so the whole chain of weakenings
`MintPaysForTime → MintPaysForTimeStable → MintPaysForTimeFixed → MintPaysForTimeGap` is one
statement. -/
theorem mintPaysForTimeGap_of_mintPaysForTime {fc : FormalSystem.ProofSystem.FrameClass}
    {U : Finset SignedFormula} {Tmax : Nat} (h : MintPaysForTime fc U Tmax) :
    MintPaysForTimeGap fc U Tmax :=
  mintPaysForTimeGap_of_mintPaysForTimeFixed (mintPaysForTimeFixed_of_mintPaysForTime h)

end FormalSystem.Metalogic.Decidability
