/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.UntlSnceFree

/-! # D4. The label residual, **replaced**: the `boxFree` shape gate and the world coordinate

**What this section delivers.** A route to clause 1 at `signedUniverse C L`, and to a seed-level
terminus, that carries **no** `UnorderedSuccessorLabelClosed` hypothesis at all. Section C11 proves
that residual false at every nonempty finite `L` (`unorderedSuccessorLabelClosed_nonempty_false`),
so the nine theorems that assume it are vacuously true at exactly the universes anyone cares about.
A *discharge* of it is therefore not available and never was — it is not a hard lemma, it is a false
statement. What is available is a **replacement**: a different hypothesis, satisfiable at a nonempty
`L` and discharged rather than assumed, bought at the price of a syntactic restriction on the stock.

**Why the replacement has to bite on the stock and not on `L`.** `freshWorldHeadroom_not_universal`
proves that for no nonempty finite `L` does every `L`-confined branch have the headroom: each
enlargement of `L` raises the reachable `maxWorld` at least as much as it adds, so the gap re-opens.
Every `L`-side repair is refuted before it is written. The one remaining place to intervene is
**before the world-minting rules can fire at all**, and that means a condition on the formulas a
branch may carry.

**Why exactly two rules have to be stopped.** `applyRule_emitted_world_mem` bounds the worlds a rule
emits at by `b.worldFinset` under exactly two hypotheses, `rule ≠ .boxNeg` and `rule ≠ .diamondPos`.
Those two inequalities *are* the world-minting census — there is no third rule, and if there were,
`findApplicableRule_not_worldMinting`'s conclusion below would be incomplete rather than merely
weak. `boxFree` closes both at the **shape gate**: `.boxNeg` is gated by `isApplicable`'s
`| .boxNeg, .neg, .box _ => true` arm, and `.diamondPos` by `asDiamond? φ`, whose only matching
pattern is itself built from a `.box` node. A branch carrying no `.box` anywhere can have neither
picked, at any frame class and any tracker.

**No frame-class restriction, for the same structural reason as D3.** The exclusion happens at the
shape gate, before `isApplicable` consults any `fc`-dependent gate, so nothing in this section
quantifies `fc` away or restricts it.

**What this is not — read this before citing anything below.** The terminus this section builds
combines `boxFree` with D3's `untlSnceFree`, and the two together collapse the stock to the **purely
propositional fragment**: atoms, `⊥`, `→`, and nothing else. That is a severe narrowing, and it is
**forced rather than a proof weakness**. `freshWorldHeadroom_not_universal` rules out every `L`-side
alternative, so the only handle is the stock; and stopping `.boxNeg` and `.diamondPos` at the stock
means excluding `□` outright, since both are gated on a `.box` node. No artifact may read this
section as a discharge over the modal fragment, as a general discharge, or as superseding D3's
reach: D3's `MintPaysForTime` result covers the whole modal fragment **including** `□`, and this
section does not. What this section adds is orthogonal to D3 — it removes a *false* hypothesis from
a terminus, at the one fragment where removing it is possible. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The syntactic condition**: no `.box` node anywhere in the formula.

Stated on the raw constructors rather than on the `asDiamond?` view, for the same reason
`untlSnceFree` is: it is then manifestly closed under subformulas and manifestly checkable on a
concrete stock by `rfl`. Like `untlSnceFree` it is *sufficient* rather than necessary — `asDiamond?`
also rejects `.box`-bearing shapes this predicate excludes outright — and sufficiency is all the
replacement needs. -/
def boxFree : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp a b => boxFree a && boxFree b
  | .box _ => false
  | .untl a b => boxFree a && boxFree b
  | .snce a b => boxFree a && boxFree b

/-- **The `◇` view is empty on a `boxFree` formula.** `asDiamond? φ` matches only the shape whose
body is a `.box` node, so a formula with no `.box` anywhere cannot present as a diamond. This is the
half of the census that is *not* visible from `isApplicable`'s own pattern match, which is why it is
stated separately. -/
theorem asDiamond_eq_none_of_boxFree {φ : Formula} (h : boxFree φ = true) :
    asDiamond? φ = none := by
  cases φ <;> simp_all only [boxFree, asDiamond?, Bool.and_eq_true, Bool.false_eq_true]
  rename_i a b
  cases a <;> simp_all [boxFree]

/-- **`.boxNeg` is inapplicable to a `boxFree` trigger**, at every frame class. Straight off
`isApplicable`'s `| .boxNeg, .neg, .box _ => true` arm: the arm requires a `.box` constructor, and
`boxFree` excludes it. -/
theorem isApplicable_boxNeg_false_of_boxFree {sf : SignedFormula}
    {fc : FormalSystem.ProofSystem.FrameClass} (h : boxFree sf.formula = true) :
    isApplicable .boxNeg sf fc = false := by
  cases sf with
  | mk sign formula label =>
    cases sign <;> cases formula <;> simp_all [isApplicable, boxFree]

/-- **`.diamondPos` is inapplicable to a `boxFree` trigger**, at every frame class. Through
`asDiamond_eq_none_of_boxFree`: the arm consults the view, and the view is `none`. -/
theorem isApplicable_diamondPos_false_of_boxFree {sf : SignedFormula}
    {fc : FormalSystem.ProofSystem.FrameClass} (h : boxFree sf.formula = true) :
    isApplicable .diamondPos sf fc = false := by
  cases sf with
  | mk sign formula label =>
    cases sign <;>
      simp_all [isApplicable, asDiamond_eq_none_of_boxFree h]

/-- **The first stage cannot pick a world-minting rule on a `boxFree` trigger.** The
world-coordinate counterpart of `findApplicableRule_not_mintsFreshTime`, and the fact
`pick_stage_source_noWorldMint` threads to the successor.

The conclusion is stated as the pair of inequalities `applyRule_emitted_world_mem` asks for, rather
than as a `ruleMintsFreshLabel` fact, because that lemma's hypotheses are the authoritative census:
`.boxNeg` and `.diamondPos` are the only two rules that can emit outside `b.worldFinset`, and both
are gated on a `.box` node — the first by `isApplicable`'s own pattern, the second through
`asDiamond?`. This is the structural reason the whole route carries no frame-class restriction: the
shape gate is consulted before any `fc`-dependent gate. -/
theorem findApplicableRule_not_worldMinting {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass}
    {r : TableauRule} {res : RuleResult} {o : TimeOrdering}
    (hfree : boxFree sf.formula = true)
    (h : findApplicableRule sf b ord fc = some (r, res, o)) :
    r ≠ .boxNeg ∧ r ≠ .diamondPos := by
  have happ := findApplicableRule_isApplicable h
  constructor
  · rintro rfl
    simp [isApplicable_boxNeg_false_of_boxFree (fc := fc) hfree] at happ
  · rintro rfl
    simp [isApplicable_diamondPos_false_of_boxFree (fc := fc) hfree] at happ


/-! ### The world-subset machinery, mirroring D3's time machinery

Three declarations, in the same order and the same shapes as `pick_stage_source_noMint`,
`pickBranches_knownTimes_subset` and `unorderedSuccessor_knownTimes_subset`. The mirror is
**strictly simpler than its template** in one respect worth naming rather than leaving a reader to
wonder about: `applyRule_emitted_world_mem` carries no `OrdTimesKnown b ord` hypothesis where
`applyRule_emitted_time_mem` does, so none of the three below takes one either. The asymmetry is
real and is recorded at `applyRule_emitted_time_mem_ordTimesKnown_needed`: the time sweep needs the
ordering's times to be branch-known because `timeLinearity` reads times off `ord`, whereas nothing
reads *worlds* off the ordering at all.

**Footnote, added later.** The asymmetry is real but it is not permanent on this fragment:
`unorderedSuccessor_knownTimes_subset_of_untlSnceFree` (section D3) is the time-coordinate mirror
without the run invariant, and the boundary block at the end of this section records what that
buys. -/

/-- **`pick_stage_source` with the no-world-mint fact attached**, the world-coordinate counterpart
of `pick_stage_source_noMint`. The three stages differ only in how the fact arrives: stage one has
it from `findApplicableRule_not_worldMinting`; stages two and three run exactly one rule each
(`serialityRule` via `findApplicableSerialRule_rule`, `timeLinearity` via
`findApplicableLinearityRule_rule`), and neither is `.boxNeg` or `.diamondPos`, so both close on the
rule identity alone. -/
private theorem pick_stage_source_noWorldMint (b : Branch) (ord : TimeOrdering)
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker)
    (hfree : ∀ x ∈ b, boxFree x.formula = true) :
    ∀ r res o,
      (match findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with
       | some sf => findApplicableRule sf b ord fc
       | none =>
         match b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
             && (findApplicableSerialRule sf b ord).isSome) with
         | some sf => findApplicableSerialRule sf b ord
         | none =>
           match b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
               && (findApplicableLinearityRule sf b ord).isSome) with
           | some sf => findApplicableLinearityRule sf b ord
           | none => none) = some (r, res, o) →
      ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧ r ≠ .boxNeg ∧ r ≠ .diamondPos := by
  intro r res o h
  rcases hpick : findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with _ | sf
  · rw [hpick] at h
    rcases hser : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                             && (findApplicableSerialRule sf b ord).isSome) with _ | sf2
    · rw [hser] at h
      rcases hlin : b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                               && (findApplicableLinearityRule sf b ord).isSome) with _ | sf3
      · rw [hlin] at h
        simp only at h
        exact absurd h (by simp)
      · rw [hlin] at h
        simp only at h
        refine ⟨sf3, List.mem_of_find?_eq_some hlin,
          findApplicableLinearityRule_applyRule_pair h, ?_⟩
        rw [findApplicableLinearityRule_rule h]
        exact ⟨by simp, by simp⟩
    · rw [hser] at h
      simp only at h
      refine ⟨sf2, List.mem_of_find?_eq_some hser,
        findApplicableSerialRule_applyRule_pair h, ?_⟩
      rw [findApplicableSerialRule_rule h]
      exact ⟨by simp, by simp⟩
  · rw [hpick] at h
    simp only at h
    have hmem : sf ∈ b := by
      unfold findUnexpandedUnblockedWith at hpick
      exact List.mem_of_find?_eq_some hpick
    exact ⟨sf, hmem, findApplicableRule_applyRule_pair h,
      findApplicableRule_not_worldMinting (hfree sf hmem) h⟩

/-- One pick stage adds no world, given that its rule is neither of the two that can. The join of
`applyRule_emitted_world_mem` with the no-world-mint source, in the shape
`pickBranches_knownTimes_subset` uses for the time coordinate — and with no `OrdTimesKnown`
argument, which is exactly the hypothesis its time twin needs and this one does not. -/
private theorem pickBranches_worldFinset_subset {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧
      r ≠ .boxNeg ∧ r ≠ .diamondPos) :
    ∀ nb ∈ pickBranches b p, ∀ w ∈ nb.worldFinset, w ∈ b.worldFinset := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA, h1, h2⟩ := hp r res o rfl
    intro nb hnb w hw
    obtain ⟨-, hsub⟩ := resultBranch_sub (b := b) (nb := nb) (res := res) hnb
    obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_worldFinset hw
    rcases hsub x hx with hxe | hxb
    · refine applyRule_emitted_world_mem (rule := r) (sf := sf) (ord := ord) hsf h1 h2 x ?_
      rw [hA]
      exact hxe
    · exact Branch.mem_worldFinset hxb

/-- **No unordered successor of a `boxFree` branch carries a new world.**

The engine-level statement, and the world-coordinate half of what the replacement consumes. Compare
`unorderedSuccessor_world_dichotomy`, which is unconditional and therefore has to admit
`w = b.nextWorld` as a second case: here the second case is *closed*, at the cost of the syntactic
hypothesis. That closure is precisely what no condition on `L` could ever buy —
`freshWorldHeadroom_not_universal` refutes every such attempt — and it is why the replacement route
has to restrict the stock.

Routed through `pick_branches_eq` and `pick_stage_source_noWorldMint`, so the three-stage pick is
not destructured a second time. Carries no frame-class restriction and no `OrdTimesKnown`. -/
theorem unorderedSuccessor_worldFinset_subset {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hfree : ∀ x ∈ b, boxFree x.formula = true) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      ∀ w ∈ nb.worldFinset, w ∈ b.worldFinset := by
  have keyB : unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1
      = pickBranches b
          (match findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with
           | some sf => findApplicableRule sf b ord fc
           | none =>
             match b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                 && (findApplicableSerialRule sf b ord).isSome) with
             | some sf => findApplicableSerialRule sf b ord
             | none =>
               match b.find? (fun sf => !(blockedTimes b ord fc tr).contains sf.label.time
                   && (findApplicableLinearityRule sf b ord).isSome) with
               | some sf => findApplicableLinearityRule sf b ord
               | none => none) := pick_branches_eq
  rw [keyB]
  exact pickBranches_worldFinset_subset (pick_stage_source_noWorldMint b ord fc tr hfree)


/-! ### The composite: clause 1's label dimension at the propositional fragment

The two per-coordinate subset facts, joined by the rectangle. This is the same assembly as
`unorderedSuccessor_label_mem_of_headroom`, with one decisive difference: there the four quadrants
are paid for by `FreshLabelHeadroom L b`, which `freshLabelHeadroom_not_universal` refutes at every
nonempty finite `L`; here they are paid for by `TimeMergeClosed L`, which `timeMergeClosed_product`
exhibits at every rectangle. The hypothesis is satisfiable, and that is the entire point of the
exercise. -/

/-- **Clause 1's label dimension, discharged from satisfiable hypotheses.** Every formula on every
unordered successor of an `L`-confined `boxFree`, `untl`/`snce`-free branch sits at a label of `L`.

**How the four quadrants are paid for.** A label is a *pair*, and the two coordinate facts arrive
separately: `unorderedSuccessor_worldFinset_subset` puts the successor's world among `b`'s worlds,
`unorderedSuccessor_knownTimes_subset` puts its time among `b`'s times. Confinement of `b` then
supplies a formula `y ∈ b` carrying that world and a formula `z ∈ b` carrying that time, each at a
label in `L` — but `y` and `z` are in general *different* formulas, so
`⟨y.label.world, z.label.time⟩` is a quadrant confinement alone does not reach. That cross-product
gap is exactly the one register entry 21 warns about, and `TimeMergeClosed L` is exactly what closes
it: `timeMergeClosed_iff_product` characterizes a time-merge-closed label set as precisely a full
rectangle of worlds against times, which is the cross-product closure a pair-valued label needs. No
further hypothesis is required, and a reader who expects to have to re-derive the worry can stop
here.

`TimeMergeClosed L` is not new currency either: it is already a sibling hypothesis at every terminus
in the chain, where it discharges `UniverseClosedAt`'s clause 2.

`OrdTimesKnown b ord` is inherited from `unorderedSuccessor_knownTimes_subset` and through it from
`applyRule_emitted_time_mem`, where `applyRule_emitted_time_mem_ordTimesKnown_needed` shows it is
not removable. It is the one hypothesis here that the world coordinate does not need — see the
section note on the asymmetry — and it is the reason this composite cannot be stated at
`UniverseClosedAt`'s clause 1, which carries no such hypothesis. -/
theorem unorderedSuccessor_label_mem_of_propositional {L : Finset Label} {b : Branch}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesKnown b ord) (hL : TimeMergeClosed L)
    (hbox : ∀ x ∈ b, boxFree x.formula = true)
    (hfree : ∀ x ∈ b, untlSnceFree x.formula = true)
    (hbl : ∀ x ∈ b, x.label ∈ L) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      ∀ x ∈ nb, x.label ∈ L := by
  intro nb hnb x hx
  have hw : x.label.world ∈ b.worldFinset :=
    unorderedSuccessor_worldFinset_subset hbox nb hnb x.label.world (Branch.mem_worldFinset hx)
  have ht : x.label.time ∈ b.knownTimes :=
    unorderedSuccessor_knownTimes_subset haux hfree nb hnb x.label.time (mem_knownTimes_of_mem hx)
  obtain ⟨y, hy, hyw⟩ := exists_mem_of_mem_worldFinset hw
  obtain ⟨z, hz, hzt⟩ := exists_mem_of_mem_knownTimes ht
  have hkey := hL y.label (hbl y hy) z.label (hbl z hz)
  rw [hyw, hzt] at hkey
  exact hkey

/-- **The same composite without `OrdTimesKnown`.** Identical to
`unorderedSuccessor_label_mem_of_propositional` except that the time coordinate is routed through
`unorderedSuccessor_knownTimes_subset_of_untlSnceFree`, so the run invariant is not required.

`hfree` was already present for the time coordinate; it now pays for that coordinate outright.
Nothing else changes: the world coordinate is `unorderedSuccessor_worldFinset_subset` as before, and
the four quadrants are still closed by `TimeMergeClosed L`.

The `haux`-carrying original is retained beside it and is unmodified. -/
theorem unorderedSuccessor_label_mem_of_propositional_ordFree {L : Finset Label} {b : Branch}
    {ord : TimeOrdering} {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (hL : TimeMergeClosed L)
    (hbox : ∀ x ∈ b, boxFree x.formula = true)
    (hfree : ∀ x ∈ b, untlSnceFree x.formula = true)
    (hbl : ∀ x ∈ b, x.label ∈ L) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      ∀ x ∈ nb, x.label ∈ L := by
  intro nb hnb x hx
  have hw : x.label.world ∈ b.worldFinset :=
    unorderedSuccessor_worldFinset_subset hbox nb hnb x.label.world (Branch.mem_worldFinset hx)
  have ht : x.label.time ∈ b.knownTimes :=
    unorderedSuccessor_knownTimes_subset_of_untlSnceFree hfree nb hnb x.label.time
      (mem_knownTimes_of_mem hx)
  obtain ⟨y, hy, hyw⟩ := exists_mem_of_mem_worldFinset hw
  obtain ⟨z, hz, hzt⟩ := exists_mem_of_mem_knownTimes ht
  have hkey := hL y.label (hbl y hy) z.label (hbl z hz)
  rw [hyw, hzt] at hkey
  exact hkey


/-- **Clause 1 at `signedUniverse C L`, both dimensions, from satisfiable hypotheses.**

The mirror of `unorderedSuccessor_confined_signedUniverse_of_headroom` with its
`UnorderedSuccessorLabelClosed fc L` argument **gone**: the formula coordinate is discharged as
before by `unorderedSuccessor_formula_mem` from `hC`/`hT`, and the label coordinate by
`unorderedSuccessor_label_mem_of_propositional` from the two syntactic conditions and
`TimeMergeClosed L`. Nothing here is assumed that cannot be exhibited — contrast the `_of_headroom`
original, whose `hlab` is false at every nonempty `L`, and the C11 sibling
`unorderedSuccessor_confined_signedUniverse_of_freshLabelHeadroom`, whose `FreshLabelHeadroom L b`
is refutable as a universally quantified condition.

The `_of_headroom` original is retained byte-identical and is what the landed terminus chain
consumes; this is an additional declaration stated beside it, exactly as
`UnorderedSuccessorLabelClosedOrd` is stated beside `UnorderedSuccessorLabelClosed`.

**Note the `OrdTimesKnown b ord` in the quantifier prefix**, which the `_of_headroom` original does
not have and which the C11 `FreshLabelHeadroom` sibling does. It is not decoration, and it is why
this theorem stops here rather than continuing into a restated terminus — see the boundary note
below. -/
theorem unorderedSuccessor_confined_signedUniverse_of_propositional {C : Finset Formula}
    {L : Finset Label} {fc : FormalSystem.ProofSystem.FrameClass}
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hbox : ∀ φ ∈ C, boxFree φ = true) (hfree : ∀ φ ∈ C, untlSnceFree φ = true) :
    ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker),
      OrdTimesKnown b ord →
      (∀ x ∈ b, x ∈ signedUniverse C L) →
      ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ nb,
        x ∈ signedUniverse C L := by
  intro b ord tr haux hb nb hnb x hx
  have hbf : ∀ y ∈ b, y.formula ∈ C :=
    fun y hy => (formula_label_of_mem_signedUniverse (hb y hy)).1
  have hbl : ∀ y ∈ b, y.label ∈ L :=
    fun y hy => (formula_label_of_mem_signedUniverse (hb y hy)).2
  exact mem_signedUniverse
    (unorderedSuccessor_formula_mem hC hT hbf nb hnb x hx)
    (unorderedSuccessor_label_mem_of_propositional haux hL
      (fun y hy => hbox _ (hbf y hy)) (fun y hy => hfree _ (hbf y hy)) hbl nb hnb x hx)

/-- **Clause 1 at `signedUniverse C L`, in `UniverseClosedAt`'s own shape.**

`unorderedSuccessor_confined_signedUniverse_of_propositional` with the `OrdTimesKnown b ord →`
arrow deleted from the quantifier prefix and nothing else changed. That arrow was the one thing
standing between the propositional route and `UniverseClosedAt`'s clause 1, which quantifies `ord`
universally and unconstrained; `unorderedSuccessor_knownTimes_subset_of_untlSnceFree` removes it,
and the statement below is now literally clause 1 at `U = signedUniverse C L`.

The `haux`-carrying original is retained beside it and is unmodified. -/
theorem unorderedSuccessor_confined_signedUniverse_of_propositional_ordFree {C : Finset Formula}
    {L : Finset Label} {fc : FormalSystem.ProofSystem.FrameClass}
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hbox : ∀ φ ∈ C, boxFree φ = true) (hfree : ∀ φ ∈ C, untlSnceFree φ = true) :
    ∀ (b : Branch) (ord : TimeOrdering) (tr : EventualityTracker),
      (∀ x ∈ b, x ∈ signedUniverse C L) →
      ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ nb,
        x ∈ signedUniverse C L := by
  intro b ord tr hb nb hnb x hx
  have hbf : ∀ y ∈ b, y.formula ∈ C :=
    fun y hy => (formula_label_of_mem_signedUniverse (hb y hy)).1
  have hbl : ∀ y ∈ b, y.label ∈ L :=
    fun y hy => (formula_label_of_mem_signedUniverse (hb y hy)).2
  exact mem_signedUniverse
    (unorderedSuccessor_formula_mem hC hT hbf nb hnb x hx)
    (unorderedSuccessor_label_mem_of_propositional_ordFree hL
      (fun y hy => hbox _ (hbf y hy)) (fun y hy => hfree _ (hbf y hy)) hbl nb hnb x hx)

/-- **`UniverseClosedAt fc (signedUniverse C L)` with no residual and no frame-class restriction.**

The theorem section D4's boundary block recorded as *not stateable*. Its hypotheses are two stock
conditions (`TableauClosed C`, `TrichStock C`), the label-set closure condition
(`TimeMergeClosed L`, satisfied by every rectangle — `timeMergeClosed_product`), and the two
syntactic shape conditions on the stock. There is **no** `UnorderedSuccessorLabelClosed`, **no**
`OrdTimesKnown`, and **no** frame-class hypothesis.

Assembled exactly as `universeClosedAt_signedUniverse_of_headroom` is: a two-component anonymous
constructor whose clause 2 is `timeMergeClosed_identifyTime_signedUniverse hL`, unchanged and taking
no argument the `_of_headroom` original does not also give it. Only clause 1 differs, and it is the
`ordFree` composite above.

**It is nevertheless vacuous, for a reason that has nothing to do with `hlab`.** `hC` and `hfree`
are jointly unsatisfiable: `TableauClosed.serialFuture` requires `Formula.top.someFuture ∈ C`, and
`Formula.someFuture ⊤` is `⊤ untl ⊤`, which `untlSnceFree` rejects.
`tableauClosed_untlSnceFree_false` below decides this, and it is stated immediately after this
theorem rather than in a note so that no reader takes the removal of `hlab` for a discharge. The
same collision hits `unorderedSuccessor_confined_signedUniverse_of_propositional` and its `ordFree`
sibling above, and section D3's
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`, all of which carry both
hypotheses.

What is *not* hit is anything that takes only the syntactic condition:
`applyRule_emitted_time_mem_of_untlSnceFree`,
`unorderedSuccessor_knownTimes_subset_of_untlSnceFree`,
`unorderedSuccessor_label_mem_of_propositional_ordFree`, and section D3's
`mintPaysForTime_of_untlSnceFree` chain take no `TableauClosed` and are non-vacuous. The collision
is between stock *closure* and stock *shape*, and it is located at exactly one field.

What this does **not** do is restate the terminus. The `_at` / `_selfGuarded` / `_fixed` families
and `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_*` are untouched, and removing their
`hlab` is separate, downstream work. See the boundary block below. -/
theorem universeClosedAt_signedUniverse_of_propositional {C : Finset Formula} {L : Finset Label}
    {fc : FormalSystem.ProofSystem.FrameClass}
    (hC : TableauClosed C) (hT : TrichStock C) (hL : TimeMergeClosed L)
    (hbox : ∀ φ ∈ C, boxFree φ = true) (hfree : ∀ φ ∈ C, untlSnceFree φ = true) :
    UniverseClosedAt fc (signedUniverse C L) :=
  ⟨unorderedSuccessor_confined_signedUniverse_of_propositional_ordFree hC hT hL hbox hfree,
    fun _ _ _ hbU ht₁ => timeMergeClosed_identifyTime_signedUniverse hL hbU ht₁⟩

/-- **`TableauClosed C` and `∀ φ ∈ C, untlSnceFree φ = true` cannot both hold.** Decided, not
argued, and in one field: `TableauClosed.serialFuture` demands `Formula.top.someFuture ∈ C` —
`serialityRule` emits `T(F⊤)` at every label from no trigger at all, so any stock closed under the
engine's outputs contains it — and `Formula.someFuture ⊤` unfolds to `Formula.untl ⊤ ⊤`, which
`untlSnceFree` rejects by its `untl` arm.

**What this decides, and what it does not.** Every theorem in this file carrying *both* hypotheses
is therefore vacuously true, whatever else its signature says. That is four declarations:
`unorderedSuccessor_confined_signedUniverse_of_propositional` and its `ordFree` sibling,
`universeClosedAt_signedUniverse_of_propositional`, and section D3's
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree` — the last of which
register entry 21 already records as vacuous through `hlab`, and which is now vacuous twice over and
for independent reasons.

Nothing carrying only the syntactic condition is affected, and that is most of the machinery:
section D3's `applyRule_emitted_time_mem_of_untlSnceFree`,
`unorderedSuccessor_knownTimes_subset_of_untlSnceFree`, `mintPaysForTime_of_untlSnceFree` and its
descendants, and this section's `unorderedSuccessor_label_mem_of_propositional_ordFree` all stand
non-vacuously. Removing `OrdTimesKnown` from the time coordinate was real work with a real result;
what it turns out not to buy is a non-vacuous composite at `signedUniverse C L`.

**Where the obstruction actually sits, for whoever picks this up.** Not in the shape condition and
not in the time coordinate, but in `TableauClosed`'s `serialFuture` / `serialPast` fields, which are
forced by `serialityRule` firing unconditionally at every label. A non-vacuous propositional
composite therefore needs either a weakened stock-closure predicate that does not demand the
seriality outputs — and then a re-derivation of `unorderedSuccessor_formula_mem` at it — or a
syntactic condition weaker than `untlSnceFree` that admits `⊤ untl ⊤` while still excluding the four
propagation arms and `.orderTrichotomy`. Neither is attempted here, and neither is refuted. -/
theorem tableauClosed_untlSnceFree_false {C : Finset Formula}
    (hC : TableauClosed C) (hfree : ∀ φ ∈ C, untlSnceFree φ = true) : False := by
  have h := hfree _ hC.serialFuture
  simp [Formula.someFuture, untlSnceFree] at h

/-! ### The boundary: what Route 1 turned out to be, and where this section now stops

**An earlier version of this block recorded a shape mismatch as settled and Route 1 as
unattempted. Both halves are now false, and the block is rewritten rather than patched so that no
reader inherits the superseded verdict.** What it said was this: `UniverseClosedAt fc U`'s clause 1
is

  `∀ b ord tr, (∀ x ∈ b, x ∈ U) → ∀ nb ∈ unorderedSuccessorBranches …, ∀ x ∈ nb, x ∈ U`

with `ord` **universally quantified and unconstrained**, while every theorem closing the time
coordinate carried `OrdTimesKnown b ord`, inherited through `unorderedSuccessor_knownTimes_subset`
from `applyRule_emitted_time_mem` — where `applyRule_emitted_time_mem_ordTimesKnown_needed` proves
the hypothesis is not removable. Two routes past it were named: re-derive the time sweep on this
fragment's reachable rules (Route 1), or thread `OrdTimesKnown` through the whole closure interface
(Route 2).

**Route 1 was attempted and it works.** `applyRule_emitted_time_mem_of_untlSnceFree` (section D3)
is the time sweep with `OrdTimesKnown b ord` replaced by `∀ x ∈ b, untlSnceFree x.formula = true`.
The replacement is exact, not approximate: `haux` is consumed at exactly five rule arms, and all
five are shape-gated by that condition —

* `.allFuturePos` and `.allPastPos`, whose `applyRule` arms match the raw `Formula.allFuture` /
  `Formula.allPast` shapes, each headed by an `untl` / `snce` node;
* `.someFutureNeg` and `.somePastNeg`, gated by `asSomeFuture?` / `asSomePast?`, which section D3's
  view lemmas already send to `none`;
* `.orderTrichotomy`, whose `fires` guard demands the branch carry
  `SignedFormula.neg d l0` for one of three `Formula.someFuture`-headed disjuncts.

The first four are excluded by the *trigger's* shape; the fifth is excluded by what the *branch*
carries, which is why the restricted sweep takes a branch-level hypothesis. That asymmetry is also
what makes the route work at all: clause 1 hands over `∀ x ∈ b, x ∈ signedUniverse C L`, from which
branch-level freeness follows in one line, and hands over nothing whatever about `ord`.

**One correction to the superseded block's own reasoning, recorded because it was load-bearing.**
That block conjectured Route 1 would need the pick to be constrained — the linearity stage yielding
`.branchingOrdered`, the seriality stage emitting at the trigger's label, and so on. None of that is
needed. The five exclusions are local to `applyRule`'s arms, no rule set is restricted, and
`boxFree` plays no part in the time coordinate at all: it is what closes the **world** coordinate
(`unorderedSuccessor_worldFinset_subset`), and the restricted sweep carries one syntactic hypothesis
rather than two.

**What the section now delivers.** `universeClosedAt_signedUniverse_of_propositional`:
`UniverseClosedAt fc (signedUniverse C L)` from `TableauClosed C`, `TrichStock C`,
`TimeMergeClosed L`, and the two shape conditions — with no `UnorderedSuccessorLabelClosed`, no
`OrdTimesKnown`, and no frame-class restriction. It is the statement this block previously recorded
as not stateable, and it is now stated and proved.

**And it is vacuous — a second obstruction, found only once the first was removed.**
`tableauClosed_untlSnceFree_false` decides that `TableauClosed C` and
`∀ φ ∈ C, untlSnceFree φ = true` cannot both hold: `TableauClosed.serialFuture` demands
`Formula.top.someFuture ∈ C`, and `Formula.someFuture ⊤` is `⊤ untl ⊤`. So the composite above,
`unorderedSuccessor_confined_signedUniverse_of_propositional` and its `ordFree` sibling, and section
D3's `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree` are all vacuously true
— the last one now for two independent reasons, `hlab` and this. This is stated plainly rather than
softened: removing `OrdTimesKnown` was necessary and is done, and it is not sufficient.

**What is not vacuous.** Everything that takes the shape condition without `TableauClosed`:
`applyRule_emitted_time_mem_of_untlSnceFree`,
`unorderedSuccessor_knownTimes_subset_of_untlSnceFree`,
`unorderedSuccessor_label_mem_of_propositional_ordFree`, and section D3's whole
`mintPaysForTime_of_untlSnceFree` chain. The time coordinate is genuinely closed on this fragment;
what is not available is a stock that is simultaneously closed under the engine's outputs and free
of `untl`.

**The boundary that remains, stated exactly.** No theorem in this section removes `hlab` from
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree` or from any of its eight
siblings, and doing so would in any case exchange one vacuity for another. The live question is no
longer `OrdTimesKnown`; it is whether a stock-closure predicate weaker than `TableauClosed` — one
that does not demand `serialityRule`'s two outputs — supports `unorderedSuccessor_formula_mem`, or
whether a shape condition weaker than `untlSnceFree` still excludes the five arms. Neither is
attempted here and neither is refuted.

**Route 2 remains unattempted and is now unnecessary for this purpose.** An `Ord`-flavoured
`UniverseClosedAt`, and the same for `DifficultyBounded`, cascading through roughly twenty
restatements down to `buildTableauAt`, was the fallback if Route 1 failed. It did not fail. Route 2
is neither started nor recommended. -/

end FormalSystem.Metalogic.Decidability
