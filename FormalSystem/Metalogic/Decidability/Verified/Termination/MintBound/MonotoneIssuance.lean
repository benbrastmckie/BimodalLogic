/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.ClosureResidual
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.TimeReuse

/-! # Monotone time issuance: the identification-side gate

**VERDICT: TRUE.** The mechanism prevents the reuse, at the witness and along the engine-driven
run, and all three settled invariants survive it. Phases 2-9 of the repair are unlocked by this
module; nothing that depends on it is assumed by anything it depends on.

*What the gate is deciding.* Entry 15 records that the ordered split's identification arm can
retire the branch's **largest** time, dropping `Branch.maxTime` and making `Branch.nextTime`
re-issue the value just retired. The arm calls `branch.identifyTime t₂ t₁`, retiring `t₂` whatever
its magnitude, and `firstIncomparablePair_spec` guarantees only `t₂ ≠ t₁` — never `t₁ < t₂`. The
mechanism prototyped here **orients the merge by numeric order** instead: retire `min t₁ t₂`, keep
`max t₁ t₂`. Which numeral survives is semantically arbitrary — identification asserts the two
instants are the *same*, and nothing in the semantics reads the numeral's magnitude — so the
orientation is free, and it is exactly what makes `maxTime` non-decreasing at the arm.

*Why this is a gate and not the repair.* Everything here is **additive** and calls the existing,
byte-unchanged `Branch.identifyTime` / `TimeOrdering.identifyTime`. No engine file is touched by
this subsection. That constraint is not stylistic: `Verified/Decidable.lean` carries 102
`Branch.nextTime` references — `lt_nextTime_of_mem_knownTimes`, `OrdWithin.bound` and
`OrdWithin.nextTime_not_mem` among them — which consume `nextTime = maxTime + 1` *definitionally*.
Redefining the bookkeeping would break all of them; reorienting the call site breaks none.

*The measured contrast, which is what makes the verdict attributable to the mechanism.* Along the
same two engine steps from the same witness:

| | `maxTime` trajectory | retired index | re-issued? |
|---|---|---|---|
| current arm (`identifyTime t₂ t₁`) | `2 → 1 → 1 → 2` | `2` | **yes** (`reuse_driven_through_engine`) |
| oriented arm (`identifyTime (min) (max)`) | `2 → 2 → 2 → 3` | `0` | **no** |

`oriented_arm_is_not_inert` decides both rows side by side. Without that pairing the gate could not
distinguish "the mechanism prevents the reuse" from "the configuration stopped applying" — the same
discriminating discipline `selfGuardPotential_lt_at_gate_with_id` sets for the refuted
fourth-component route.

*Ladder rung used.* Candidate A (merge orientation) only. The two fallback rungs — a `horizon`
field on `TimeOrdering`, and a run-level mint counter threaded through `applyRule` — were not
prototyped, because the first rung decided the gate. Their measured costs (29 files and 82 literal
sites; two engine signatures plus `Saturation.lean`) are recorded here so a reader who needs them
does not have to re-measure. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The orientation, as a pure function on the trigger's pair.** `(retired, surviving)`: the
numeral that disappears is the smaller, the numeral that survives is the larger.

That single choice is the whole mechanism. `Branch.identifyTime src tgt` relabels everything at
`src` to sit at `tgt` and leaves every other time alone, so the post-arm branch's times are the
pre-arm branch's times minus `src`. If `src` is the smaller of a pair both of whose members are
known times, it cannot have been the branch's maximum — the larger member is a known time too, and
they are distinct — so nothing the branch loses can lower `Branch.maxTime`, and `Branch.nextTime`,
being `maxTime + 1` by definition, cannot fall either. -/
def identifyOrient (t₁ t₂ : TimeIndex) : TimeIndex × TimeIndex := (min t₁ t₂, max t₁ t₂)

/-- **The prototype arm-3 successor.** The ordered split's identification arm as it would read
under the orientation, assembled here without touching `Tableau.lean`.

It calls the **existing, unmodified** `Branch.identifyTime` and `TimeOrdering.identifyTime` — no
new field, no new signature, no threaded counter. Demonstrating that the mechanism needs nothing
but a swap of two arguments at one call site is the point of stating it this way, and it is the
constraint the whole repair rests on. -/
def identifyOriented (b : Branch) (ord : TimeOrdering) (t₁ t₂ : TimeIndex) :
    Branch × TimeOrdering :=
  (b.identifyTime (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2,
   ord.identifyTime (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2)

/-- **Question (a) at the witness: the oriented arm does not re-issue.** Decided at
`reuseWitnessBranch` / `reuseWitnessOrd` with the pair `(0, 2)` that `firstIncomparablePair`
actually selects there (`gate_is_reissue_hazard` conjunct 3), so the measurement is at the
configuration entry 15 is about and not at a configuration chosen to make it come out right.

Three conjuncts. Time `2` is a known time; the post-arm `nextTime` is strictly above it, so `2`
cannot be minted next; and `Branch.maxTime` did not fall across the arm — which is the property
that generalises, and the one Phase 2 lifts off this configuration. -/
theorem oriented_arm_does_not_reissue :
    2 ∈ reuseWitnessBranch.knownTimes ∧
      (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).1.nextTime > 2 ∧
      reuseWitnessBranch.maxTime
        ≤ (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).1.maxTime := by
  decide

/-- The state `reuseWitnessState` would have been under the oriented arm. The counterpart of
`reuseWitnessState`, and the seed of the engine-driven measurement below. -/
def orientedReuseWitnessState : Branch × TimeOrdering :=
  identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2

/-- **Question (a) driven through the engine: the retired index does not come back.** The direct
counterpart of `reuse_driven_through_engine`, and the conjunct that makes the verdict a statement
about *runs* rather than about a hand-assembled `Branch`.

Under the orientation the index the arm retires is `0`, not `2`. Two `expandOnceUnblocked` steps
later it is still absent from `knownTimes`, and `Branch.maxTime` has gone `2 → 2 → 3` rather than
`2 → 1 → 2`. Reuse is not merely unobserved here: `Branch.nextTime` is `maxTime + 1` and `maxTime`
never fell, so every mint along this run is at a value strictly above every index the run has ever
retired.

A gate that checked only `oriented_arm_does_not_reissue` would be checking the arm in isolation.
This is the conjunct that checks the mechanism where entry 15 does its damage. -/
theorem oriented_reuse_not_driven_through_engine :
    ((reuseStep orientedReuseWitnessState).bind reuseStep).map
        (fun s => s.1.knownTimes.contains 0) = some false ∧
      (reuseStep orientedReuseWitnessState).map (fun s => s.1.maxTime) = some 2 ∧
      ((reuseStep orientedReuseWitnessState).bind reuseStep).map
        (fun s => s.1.maxTime) = some 3 := by
  decide

/-- **The discriminating measurement.** At the *same* witness, the *current* orientation re-issues
and the oriented one does not — decided side by side, in one statement, so the verdict cannot be an
artifact of the configuration having stopped applying.

Conjuncts 1 and 3 restate what `nextTime_reissues_retired_time` and `reuse_driven_through_engine`
already decide, at the same numbers; conjuncts 2 and 4 are their oriented counterparts. Conjuncts 5
and 6 exhibit the `maxTime` drop that causes the re-issue and its absence under the orientation, so
the mechanism is visible and not merely its consequence.

This is the pairing `selfGuardPotential_lt_at_gate_with_id` sets the precedent for: a gate that
reports only the favourable half of a comparison has measured nothing. -/
theorem oriented_arm_is_not_inert :
    (Branch.identifyTime reuseWitnessBranch 2 0).nextTime = 2 ∧
      (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).1.nextTime = 3 ∧
      ((reuseStep reuseWitnessState).bind reuseStep).map
        (fun s => s.1.knownTimes.contains 2) = some true ∧
      ((reuseStep orientedReuseWitnessState).bind reuseStep).map
        (fun s => s.1.knownTimes.contains 0) = some false ∧
      (Branch.identifyTime reuseWitnessBranch 2 0).maxTime < reuseWitnessBranch.maxTime ∧
      reuseWitnessBranch.maxTime
        ≤ (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).1.maxTime := by
  decide

/-- The reuse witness's universe, **closed under retiming within its own known times**: its three
atoms against world `0` and times `0`-`2`.

Stated in the `signedUniverse` shape rather than as the three-formula literal, because the bare
literal is not retiming-closed and confinement across *any* identification arm would fail against
it — under the current orientation exactly as much as under this one. That is register entry 10's
finding, not a cost of the mechanism, and `UniverseClosedAt` is the settled repair for it. -/
def orientedReuseUniverse : Finset SignedFormula :=
  signedUniverse
    ({.atom ⟨"p", none⟩, .atom ⟨"q", none⟩, .atom ⟨"r", none⟩} : Finset Formula)
    ((({0} : Finset WorldIndex) ×ˢ ({0, 1, 2} : Finset TimeIndex)).image
      (fun p => (⟨p.1, p.2⟩ : Label)))

/-- **Question (b): the settled invariants survive the oriented arm.** Seven conjuncts, decided at
**both** landed witness configurations, in the discipline `gate_is_reissue_hazard` uses — without
the trigger conjuncts a negative verdict would be attributable to a violated precondition rather
than to the mechanism.

1-2. the pair each configuration's trigger actually reports, so the oriented arm below is applied
   at the pair the engine itself would hand it;
3. `RunInvariant` — hence `IrreflOrd` **and** `OrdTimesKnown`, register entries 7 and 16's settled
   repair — holds after the oriented arm at the reuse witness;
4. …and at the gate configuration;
5. the oriented merge **target** is a known time at both configurations. This is precisely
   `UniverseClosedAt` clause 2's restriction (entries 10-12), so the confinement bridge
   `universeClosedAt_identify_at_trigger` applies at the oriented arm with nothing extra assumed —
   note clause 2 already quantifies its *source* time freely, which is why the swap costs nothing
   there;
6. confinement itself, decided: the post-arm branch stays inside the retiming-closed universe;
7. **at the gate configuration the oriented arm and the current arm are the same list.** The gate's
   trigger reports `(2, 0)`, so `min = 0 = t₂` and `max = 2 = t₁`, and the orientation is already
   what the current arm does there. Nothing at the gate regresses, and nothing at the gate is
   evidence *for* the mechanism either — which is why the reuse witness, where the two orientations
   genuinely differ, carries the verdict. -/
theorem oriented_gate_invariants :
    firstIncomparablePair reuseWitnessBranch reuseWitnessOrd = some (0, 2) ∧
    firstIncomparablePair gateBranch gateOrd = some (2, 0) ∧
    RunInvariant (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).1
      (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).2 ∧
    RunInvariant (identifyOriented gateBranch gateOrd 2 0).1
      (identifyOriented gateBranch gateOrd 2 0).2 ∧
    ((identifyOrient 0 2).2 ∈ reuseWitnessBranch.knownTimes ∧
      (identifyOrient 2 0).2 ∈ gateBranch.knownTimes) ∧
    ((∀ x ∈ reuseWitnessBranch, x ∈ orientedReuseUniverse) ∧
      ∀ x ∈ (identifyOriented reuseWitnessBranch reuseWitnessOrd 0 2).1,
        x ∈ orientedReuseUniverse) ∧
    (identifyOriented gateBranch gateOrd 2 0).1 = Branch.identifyTime gateBranch 0 2 := by
  refine ⟨by decide, by decide, ⟨?_, ?_⟩, ⟨?_, ?_⟩, by decide, by decide, by decide⟩
  · unfold IrreflOrd; decide
  · unfold OrdTimesKnown; decide
  · unfold IrreflOrd; decide
  · unfold OrdTimesKnown; decide

/-- **The one exposure the orientation inherits, measured at the gate before it is proved in
general.** `identifyTime_no_collapse` is stated from an `incomparableB ord (t₁, t₂)` hypothesis
whose three conjuncts are written asymmetrically in `t₁` / `t₂`, so applying it at the flipped
orientation needs `incomparableB` to be symmetric in its pair.

Decided here at both witness orderings, in both directions. That is evidence, not proof: the
general `incomparableB_symm` is a named obligation of the next phase, and if it turns out to be
false in general the mechanism dies there rather than here. Recording the decided instances now
means a reader can see the obligation was identified before it was needed. -/
theorem oriented_arm_symmetric_trigger :
    incomparableB reuseWitnessOrd (0, 2) = true ∧
      incomparableB reuseWitnessOrd (2, 0) = true ∧
      incomparableB gateOrd (2, 0) = true ∧
      incomparableB gateOrd (0, 2) = true := by decide


/-! #### Run-level monotonicity, off the gate configuration

Phase 1 decided the mechanism at two witnesses. This subsection lifts it: the same statements
quantified over every branch, every ordering and both times, plus the one citation the design rests
on turned into a checked statement.

*The one finding worth recording up front.* The general form needs **no membership hypotheses at
all**. `maxTime_le_identifyTime_of_le` asks only `src ≤ tgt`, and `min t₁ t₂ ≤ max t₁ t₂` is
unconditional, so `maxTime_le_identifyTime_oriented` holds for arbitrary times on an arbitrary
branch. The plan-time shape carried `t₁ ∈ b.knownTimes` and `t₂ ∈ b.knownTimes`; both turned out to
be unnecessary, which is a strengthening rather than a shortcut — the hypotheses reappear only in
`retired_lt_nextTime_oriented`, where the *retired* index has to be located below `b.maxTime` and
membership is genuinely what does it. -/

/-- **The mechanism in one lemma, with the orientation abstracted away.** Identifying a time into a
time at least as large never lowers `Branch.maxTime`.

Every branch formula survives the relabelling (`mem_identifyTime`), so it is enough to place each
pre-arm time under the post-arm maximum. A formula not sitting at `src` keeps its time outright; a
formula sitting at `src` moves to `tgt`, and `src ≤ tgt` is exactly what carries the bound across
that move. No membership hypothesis is used, and none is available to be used — the statement is
true on an arbitrary branch at arbitrary times.

This is the whole of Candidate A's content. Everything below is instantiation. -/
theorem maxTime_le_identifyTime_of_le {b : Branch} {src tgt : TimeIndex} (h : src ≤ tgt) :
    b.maxTime ≤ (b.identifyTime src tgt).maxTime := by
  refine maxTime_le_of_forall ?_
  intro sf hsf
  have hle : (rhoSF src tgt sf).label.time ≤ (b.identifyTime src tgt).maxTime :=
    le_maxTime (mem_identifyTime b src tgt sf hsf)
  by_cases hc : sf.label.time = src
  · have hr : (rhoSF src tgt sf).label.time = tgt := by simp [rhoSF, rho, hc]
    rw [hr] at hle
    exact le_trans (hc ▸ h) hle
  · have hr : (rhoSF src tgt sf).label.time = sf.label.time := by simp [rhoSF, rho, hc]
    rw [hr] at hle
    exact hle

/-- **`Branch.maxTime` is non-decreasing across the oriented arm**, on every branch and at every
pair. The general form of `oriented_arm_does_not_reissue`'s third conjunct, and the reason the
orientation is the mechanism rather than a coincidence of the witness.

Contrast `ordTimes_identifyTime_arm3_false` and `oriented_arm_is_not_inert` conjunct 5: at the
*current* orientation `Branch.maxTime` demonstrably falls. There is no hypothesis that could be
added to rescue the current arm, because the drop is what the arm does. -/
theorem maxTime_le_identifyTime_oriented (b : Branch) (ord : TimeOrdering) (t₁ t₂ : TimeIndex) :
    b.maxTime ≤ (identifyOriented b ord t₁ t₂).1.maxTime :=
  maxTime_le_identifyTime_of_le min_le_max

/-- **…and so is `Branch.nextTime`.** The immediate corollary, stated separately because this is
the form the nine mint sites in `Tableau.lean` consume: each of them reads `branch.nextTime`, and
none of them needs an edit once this holds, since `Branch.nextTime = Branch.maxTime + 1` is
unchanged and `Nat.succ` is monotone.

That is the payoff of the byte-unchanged-definitions constraint, stated as a theorem rather than
argued: the repair reaches all nine mint sites without touching any of them. -/
theorem nextTime_le_identifyTime_oriented (b : Branch) (ord : TimeOrdering) (t₁ t₂ : TimeIndex) :
    b.nextTime ≤ (identifyOriented b ord t₁ t₂).1.nextTime :=
  Nat.succ_le_succ (maxTime_le_identifyTime_oriented b ord t₁ t₂)

/-- **The statement that replaces the obstruction.** The index the oriented arm retires is strictly
below the branch's next fresh time *after* the arm — so it cannot be the value the next mint
issues, and register entry 15's configuration cannot arise.

Membership of both times is used here and is genuinely needed: the retired index has to be placed
under `b.maxTime` before monotonicity can carry it under the post-arm `nextTime`, and only
membership does that. `firstIncomparablePair_spec` supplies both at the engine's own trigger, so
the hypotheses cost nothing at the one call site there is.

This is the theorem C9 entry 18 cites. If a later phase fails, it fails downstream of this. -/
theorem retired_lt_nextTime_oriented {b : Branch} (ord : TimeOrdering) {t₁ t₂ : TimeIndex}
    (h₁ : t₁ ∈ b.knownTimes) (h₂ : t₂ ∈ b.knownTimes) :
    (identifyOrient t₁ t₂).1 < (identifyOriented b ord t₁ t₂).1.nextTime := by
  have hmax : max t₁ t₂ ≤ b.maxTime := by
    rcases Nat.le_total t₁ t₂ with hle | hle
    · rw [Nat.max_eq_right hle]; exact le_maxTime_of_mem_knownTimes h₂
    · rw [Nat.max_eq_left hle]; exact le_maxTime_of_mem_knownTimes h₁
  calc (identifyOrient t₁ t₂).1 ≤ b.maxTime := le_trans min_le_max hmax
    _ < b.nextTime := Nat.lt_succ_self _
    _ ≤ _ := nextTime_le_identifyTime_oriented b ord t₁ t₂

/-- The ordered split's three arms as they read under the orientation. Arms 1 and 2 are byte-for-byte
what `applyRule .timeLinearity` already produces; only the third differs.

Stated here so run-level monotonicity is provable **before** `Tableau.lean` is edited, and so the
edit that lands in the engine has a named referent to be checked against rather than being its own
specification. -/
def orientedSplitArms (b : Branch) (ord : TimeOrdering) (t₁ t₂ : TimeIndex) :
    List (Branch × TimeOrdering) :=
  [ (b, ord.addFuture t₁ t₂), (b, ord.addFuture t₂ t₁), identifyOriented b ord t₁ t₂ ]

/-- **The "single non-additive step" claim, checked rather than cited.**
The "Well-formedness of the `(branch, ordering)` pair" section of `Verified/Decidable.lean`
asserts in prose that the ordered split's identification arm is the engine's only non-additive
branch step. This is that assertion as a theorem, and the enumeration
behind it is complete: `ExpansionResult` has exactly **four** constructors, and every one is
accounted for.

* `.saturated` — no successor branch at all, so `unorderedSuccessorBranches` is `[]`.
* `.extended` — one successor, of shape `fs ++ b` (`expandOnceUnblocked_extended_shape`).
* `.split` — its arms, each containing `b` (`expandOnceUnblocked_split_subset`).
* `.splitOrdered` — contributes nothing to `unorderedSuccessorBranches` by construction, and is
  covered by the second conjunct, which returns the exact three-arm list.

Conjunct 1 is `expandOnceUnblocked_branch_mono`, which was already landed and is stated at exactly
the generality the check needs; conjunct 2 is `expandOnceUnblocked_splitOrdered_shape`. Composing
them is the check: **every** successor of **every** shape either contains `b` verbatim or is one of
the three ordered-split arms, of which only the third moves a time. No second branch-shrinking arm
exists, so Phase 1's verdict about arm 3 does establish run-level monotonicity rather than a
statement about one arm.

Conjunct 2 now reads `bs = orientedSplitArms b ord t₁ t₂` on the nose. That is not a restatement
for tidiness: since the engine's arm is itself oriented, `orientedSplitArms` has stopped being a
prototype standing in for the arm and *is* the arm, so everything proved about it below is a
statement about runs the engine actually takes. -/
theorem expandOnce_branch_shape_census {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, ∀ x ∈ b, x ∈ nb) ∧
    (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
      ∃ t₁ t₂, firstIncomparablePair b ord = some (t₁, t₂) ∧
        bs = orientedSplitArms b ord t₁ t₂) :=
  ⟨expandOnceUnblocked_branch_mono, fun _ h => expandOnceUnblocked_splitOrdered_shape h⟩

/-- `Branch.maxTime` does not fall at any of the three oriented arms. Arms 1 and 2 leave the branch
literally unchanged — they move only the ordering — so they are `Nat.le_refl`; arm 3 is
`maxTime_le_identifyTime_oriented`. -/
theorem maxTime_le_orientedSplitArms (b : Branch) (ord : TimeOrdering) (t₁ t₂ : TimeIndex) :
    ∀ p ∈ orientedSplitArms b ord t₁ t₂, b.maxTime ≤ p.1.maxTime := by
  intro p hp
  simp only [orientedSplitArms, List.mem_cons, List.not_mem_nil, or_false] at hp
  rcases hp with rfl | rfl | rfl
  · exact Nat.le_refl _
  · exact Nat.le_refl _
  · exact maxTime_le_identifyTime_oriented b ord t₁ t₂

/-- **Run-level monotonicity of `Branch.maxTime`**, composing the shape census with the arm result:
across every successor of every shape the engine can report, the branch maximum is non-decreasing.

Conjunct 1 covers `.extended` and `.split` — the additive shapes — through
`expandOnceUnblocked_branch_mono` and `maxTime_mono`. Conjunct 2 covers the ordered split, stated
at the engine's **own** `.splitOrdered` result rather than at a hypothetical arm list: since the
live arm is the oriented one, the shape census turns any reported `bs` into `orientedSplitArms` and
`maxTime_le_orientedSplitArms` finishes. `.saturated` reports no successor and is covered by
conjunct 1 vacuously, which is absence of a successor rather than a weakening of the claim.

Together the two conjuncts exhaust the engine's step: **no successor of any shape has a smaller
`Branch.maxTime` than the branch it came from.** This is the run-level statement Phase 1's gate
decided at one configuration. -/
theorem maxTime_monotone_along_run {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        b.maxTime ≤ nb.maxTime) ∧
      (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        ∀ p ∈ bs, b.maxTime ≤ p.1.maxTime) :=
  ⟨fun nb hnb => maxTime_mono (expandOnceUnblocked_branch_mono nb hnb),
   fun _ h => by
     obtain ⟨t₁, t₂, -, rfl⟩ := (expandOnce_branch_shape_census (fc := fc) (tr := tr)).2 _ h
     exact maxTime_le_orientedSplitArms b ord t₁ t₂⟩

/-- **…and hence of fresh-time issuance itself.** `Branch.nextTime` is `Branch.maxTime + 1` by a
definition this task leaves byte-unchanged, so monotonicity of the one is monotonicity of the
other. This is the run-level form of the property register entry 15 says is unavailable — and it
*was* unavailable at the unoriented arm, which is why the repair went to the arm and not to the
measure.

**Read as a statement about reuse**: every fresh time the engine mints is `nb.maxTime + 1` for the
branch it mints on, and no branch along a run has a smaller `maxTime` than its predecessor, so
every mint is strictly above every time index the run has ever carried — including every index an
earlier identification retired. `nextTime_reissues_retired_time`'s configuration cannot recur on
the engine path; see `reuse_driven_through_engine` for the same fact decided at that witness. -/
theorem nextTime_monotone_along_run {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker} :
    (∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
        b.nextTime ≤ nb.nextTime) ∧
      (∀ bs, (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs →
        ∀ p ∈ bs, b.nextTime ≤ p.1.nextTime) :=
  ⟨fun nb hnb => Nat.succ_le_succ
      (maxTime_monotone_along_run (fc := fc) (tr := tr) |>.1 nb hnb),
   fun bs h p hp => Nat.succ_le_succ
     (maxTime_monotone_along_run (fc := fc) (tr := tr) |>.2 bs h p hp)⟩


/-! #### Invariant survival at the oriented arm, generally

The three settled repairs the register protects — `OrdTimesKnown` (entries 7 and 16), the
`UniverseClosedAt` confinement (entries 10-12), and the `.splitOrdered` measure's first component —
re-proved at the oriented arm for arbitrary branches and times, not only at the gate.

*R1 is closed, and the answer is the favourable one.* `incomparableB_symm` was the plan's single
most likely point of failure: `identifyTime_no_collapse` is stated from an `incomparableB
ord (t₁, t₂)` hypothesis written asymmetrically in `t₁` / `t₂`, and the oriented arm applies it at
the flipped pair whenever `t₁ < t₂`. The symmetry **holds**, and it reduces to the reachability
duality this development already owns — with one gap, recorded below.

*The one thing that was genuinely missing.* `orderDual_holds` (`Fuel.lean`) states the duality in
the forward direction only: `t₂ ∈ futureOf t₁ → t₁ ∈ pastOf t₂`. `incomparableB_symm` needs the
mirror as well, and the mirror was not landed anywhere. `orderDual_backward` supplies it, by the
same three-step argument at the converse step relation. That is the only declaration in this
subsection that is not an instantiation of something already proved, and recording it is the point
of the plan's "a lemma that needed an independent proof is a signal" instruction: the signal here
is small and localised — a missing mirror in a reachability calculus, not a defect in the
orientation.

*Where those two live.* `orderDual_backward` and `incomparableB_symm` are landed in section A,
alongside `incomparableB_of_firstIncomparablePair`, rather than here: the engine-facing arm-3
lemmas consume them far above this subsection, and Lean's dependency order decides the position.
Their content is this subsection's; only their location is not. -/

/-- **Collapse-freedom at the oriented arm.** `identifyTime_no_collapse` restated at
`(min t₁ t₂, max t₁ t₂)`, by a case split on which of the two times is the smaller.

When `t₂ ≤ t₁` the oriented arm *is* the current arm and the lemma applies verbatim. When
`t₁ ≤ t₂` the arguments are flipped and `incomparableB_symm` supplies the hypothesis at the flipped
pair. Both branches are direct instantiations; the case split is the whole of the new content. -/
theorem identifyTime_no_collapse_oriented (ord : TimeOrdering) (t₁ t₂ : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true) (hnsl : IrreflOrd ord)
    (a b : TimeIndex) (h : (a, b) ∈ ord.constraints) :
    rho (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2 a
      ≠ rho (identifyOrient t₁ t₂).1 (identifyOrient t₁ t₂).2 b := by
  simp only [identifyOrient]
  rcases Nat.le_total t₁ t₂ with hle | hle
  · rw [Nat.min_eq_left hle, Nat.max_eq_right hle]
    exact identifyTime_no_collapse ord t₂ t₁ (incomparableB_symm hinc) hnsl a b h
  · rw [Nat.min_eq_right hle, Nat.max_eq_left hle]
    exact identifyTime_no_collapse ord t₁ t₂ hinc hnsl a b h

/-- Irreflexivity at the oriented arm. A direct instantiation:
`irreflOrd_identifyTime` is already quantified over both of its times and takes no hypotheses at
all, so the orientation is invisible to it. -/
theorem irreflOrd_identifyTime_oriented (b : Branch) (ord : TimeOrdering) (t₁ t₂ : TimeIndex) :
    IrreflOrd (identifyOriented b ord t₁ t₂).2 :=
  irreflOrd_identifyTime ord _ _

/-- **Register entries 7 and 16's settled repair, at the oriented arm.** A direct instantiation, as
the plan predicted: `ordTimesKnown_identifyTime`'s docstring records that it needs *no trigger
hypotheses at all* — not `firstIncomparablePair`, not `IrreflOrd` — because it is a structural fact
about branch and ordering being relabelled by the same `rho`. A fact of that shape cannot notice
which way round its two times are.

This is the lemma whose failure would have been the quiet regression the plan warns about, so it is
stated separately rather than only inside the bundle below. -/
theorem ordTimesKnown_identifyTime_oriented {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (h : OrdTimesKnown b ord) :
    OrdTimesKnown (identifyOriented b ord t₁ t₂).1 (identifyOriented b ord t₁ t₂).2 :=
  ordTimesKnown_identifyTime h

/-- The run invariant survives the oriented arm, bundled. Both components are unconditional in the
orientation, so the bundle is too. -/
theorem runInvariant_identifyTime_oriented {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    (h : RunInvariant b ord) :
    RunInvariant (identifyOriented b ord t₁ t₂).1 (identifyOriented b ord t₁ t₂).2 :=
  ⟨irreflOrd_identifyTime_oriented b ord t₁ t₂, ordTimesKnown_identifyTime_oriented h.2⟩

/-- **R2, discharged: the termination measure's first component still strictly drops.**
`knownTimes_card_lt_identifyTime` at the oriented arguments.

Its hypotheses are membership of both times plus distinctness, and `firstIncomparablePair_spec`
supplies all three in either orientation — which is exactly why the risk register rated this low
and why it is proved **here**, in `MintBound.lean`, before `Tableau.lean` is touched. The
`.splitOrdered` lexicographic measure's arm-3 discharge is therefore never in doubt at any point in
the remaining phases. -/
theorem knownTimes_card_lt_identifyTime_oriented {b : Branch} {ord : TimeOrdering}
    {t₁ t₂ : TimeIndex} (h1 : t₁ ∈ b.knownTimes) (h2 : t₂ ∈ b.knownTimes) (hne : t₂ ≠ t₁) :
    ((identifyOriented b ord t₁ t₂).1.knownTimes).toFinset.card
      < (b.knownTimes).toFinset.card := by
  simp only [identifyOriented, identifyOrient]
  rcases Nat.le_total t₁ t₂ with hle | hle
  · rw [Nat.min_eq_left hle, Nat.max_eq_right hle]
    exact knownTimes_card_lt_identifyTime h2 h1 (Ne.symm hne)
  · rw [Nat.min_eq_right hle, Nat.max_eq_left hle]
    exact knownTimes_card_lt_identifyTime h1 h2 hne

/-! Register entries 10-12's confinement bridge at the oriented arm is
`universeClosedAt_identify_at_trigger_oriented`, landed beside its unoriented original where the
engine-level consumers reach it. It discharges the *existing* clause 2: the predicate already
quantifies its source time freely and restricts only its target, so swapping which member of the
pair is which costs exactly the one fact `firstIncomparablePair_spec_oriented` supplies, and adds
no hypothesis. Nothing here constrains `t₂` as well as `t₁` — entry 12 decides that both-times
form is the weaker one, not the repair. -/

/-- **…and clause 2 discharged at the concrete universe, at the oriented arm.**
`timeMergeClosed_identifyTime_signedUniverse` at the oriented merge, so the whole confinement chain
— predicate, bridge, and concrete discharge — is available in the oriented form rather than only
the first two links of it. Same one fact, same source: the surviving numeral is a known time. -/
theorem timeMergeClosed_identifyTime_oriented {C : Finset Formula} {L : Finset Label}
    (hL : TimeMergeClosed L) {b : Branch} {ord : TimeOrdering}
    (hb : ∀ x ∈ b, x ∈ signedUniverse C L) {t₁ t₂ : TimeIndex}
    (h1 : t₁ ∈ b.knownTimes) (h2 : t₂ ∈ b.knownTimes) :
    ∀ x ∈ (identifyOriented b ord t₁ t₂).1, x ∈ signedUniverse C L := by
  refine timeMergeClosed_identifyTime_signedUniverse hL hb (t₁ := (identifyOrient t₁ t₂).2)
    (t₂ := (identifyOrient t₁ t₂).1) ?_
  simp only [identifyOrient]
  rcases Nat.le_total t₁ t₂ with hle | hle
  · rw [Nat.max_eq_right hle]; exact h2
  · rw [Nat.max_eq_left hle]; exact h1

end FormalSystem.Metalogic.Decidability
