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

end FormalSystem.Metalogic.Decidability
