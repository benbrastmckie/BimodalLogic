/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.MintPotential

/-! # D1. The time coordinate: the minting census

The world coordinate is complete (`applyRule_emitted_world_dichotomy`). This section builds the
same accounting in the **time** coordinate, and the first thing it needs is the list of rules that
can put a formula at a time the branch does not already know. The section notes above record that
no statement in the development says what that list is. This is that statement.

**`ruleMintsFreshLabel` is the wrong list, in both directions.** It is a list of *witness-guarded*
rules — the ones `findApplicableRule` gates on `witnessPresent` — and witness-guardedness and
time-minting are two different properties:

* `boxNeg` and `diamondPos` are in `ruleMintsFreshLabel` and mint **no time**. Both emit at
  `Branch.nextWorld` while carrying the trigger's own time (their witness) or a branch formula's own
  time (their `boxPosFormulas` / `diamondNegFormulas` propagation blocks). Fresh *world*, known time.
* `densityRule` mints a time and is deliberately **absent** from `ruleMintsFreshLabel`: it carries
  its own `existingIntermediates`-style gap guard (the maximal-target filter on
  `TimeOrdering.futureOf`) instead of a witness test, so re-guarding it would have been redundant.
* the ACTIVE arms of `untlNeg` and `snceNeg` mint `Branch.nextTime` and are absent from
  `ruleMintsFreshLabel` too, because they are `ruleSelfGuarded`: they filter their target times
  through their own `unprocessed` test and re-include the trigger in every arm.

So neither list contains the other, and `freshTimeRules_incomparable_freshLabelRules` decides that
rather than asserting it. `expandOnceNoFresh` is the in-repo operational evidence for the same fact:
it runs the `ruleMintsFreshLabel` test **and then**, separately, a
`newOrd.constraints.length > timeOrd.constraints.length` test. Two tests in sequence are necessary
only when neither subsumes the other — a single test would do if one list contained the other.

**The census is read off `applyRule`, not guessed from the sibling list.** Every fresh time in
`applyRule` is `branch.nextTime`, bound at exactly nine sites: the `allFutureNeg` / `allPastNeg` /
`someFuturePos` / `somePastPos` / `untlPos` / `sncePos` arms, the ACTIVE arms of `untlNeg` /
`snceNeg`, and `densityRule`'s interpolation site. There is no `nextTime + k` anywhere, which is why
the dichotomy below has the same two-case shape as its world twin. -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

/-- **The nine rules that can emit at a time outside `Branch.knownTimes`.**

Derived by walking `applyRule`'s thirty-six constructor arms and recording which reach a
`freshTime := branch.nextTime` binding. Deliberately *not* derived from `ruleMintsFreshLabel`: see
the section note above for why the two lists are incomparable. -/
def ruleMintsFreshTime : TableauRule → Bool
  | .allFutureNeg | .allPastNeg | .someFuturePos | .somePastPos
  | .untlPos | .sncePos | .untlNeg | .snceNeg | .densityRule => true
  | _ => false

/-- The census as a `Finset`, mirroring `freshLabelRules`. -/
def freshTimeRules : Finset TableauRule :=
  {TableauRule.allFutureNeg, TableauRule.allPastNeg, TableauRule.someFuturePos,
   TableauRule.somePastPos, TableauRule.untlPos, TableauRule.sncePos,
   TableauRule.untlNeg, TableauRule.snceNeg, TableauRule.densityRule}

/-- The `Finset` and the `Bool` predicate agree, over all thirty-six constructors. The anti-drift
guarantee `mem_freshLabelRules` already gives the sibling list. -/
theorem mem_freshTimeRules {r : TableauRule} :
    r ∈ freshTimeRules ↔ ruleMintsFreshTime r = true := by
  cases r <;> simp [freshTimeRules, ruleMintsFreshTime]

/-- There are exactly nine, decided rather than counted by hand. -/
theorem freshTimeRules_card : freshTimeRules.card = 9 := by decide

/-- **The two rule lists are incomparable, not nested.** Both directions, decided.

The first two conjuncts are the world-minting-is-not-time-minting direction: `boxNeg` and
`diamondPos` are witness-guarded and mint no time. The last three are the converse: `densityRule`
(gap-guarded) and the `untlNeg` / `snceNeg` ACTIVE arms (`ruleSelfGuarded`) mint a time while
sitting outside `freshLabelRules`.

`expandOnceNoFresh` is the operational evidence: it tests `ruleMintsFreshLabel` and **then** tests
`newOrd.constraints.length`, two tests in sequence, which is only necessary because neither list
subsumes the other. A reader who reads "not in `ruleMintsFreshLabel`" as "introduces no time" is
re-attempting a refuted statement — see the register entry. -/
theorem freshTimeRules_incomparable_freshLabelRules :
    (TableauRule.boxNeg ∈ freshLabelRules ∧ TableauRule.boxNeg ∉ freshTimeRules) ∧
    (TableauRule.diamondPos ∈ freshLabelRules ∧ TableauRule.diamondPos ∉ freshTimeRules) ∧
    (TableauRule.densityRule ∈ freshTimeRules ∧ TableauRule.densityRule ∉ freshLabelRules) ∧
    (TableauRule.untlNeg ∈ freshTimeRules ∧ TableauRule.untlNeg ∉ freshLabelRules) ∧
    (TableauRule.snceNeg ∈ freshTimeRules ∧ TableauRule.snceNeg ∉ freshLabelRules) := by
  decide

/-! ### The time-coordinate plumbing

The closers the time sweep is built from, one per emission shape `applyRule` uses. Three are
mirrors of the world sweep's helpers (`mem_filterMap_world`, `mem_filterMap_const_world`,
`mem_boxDiamondPersistence_label`); the rest have no world counterpart, and the reason each is
needed is worth stating because it is exactly the asymmetry between the two coordinates.

**The time coordinate needs an ordering hypothesis and the world coordinate does not.** Four rules —
`allFuturePos`, `allPastPos`, `someFutureNeg`, `somePastNeg` — propagate to *every* time in
`TimeOrdering.futureOf` / `pastOf` of the trigger. Nothing about `applyRule` ties those times to the
branch: a formula may be emitted at an ordering time the branch has never carried. Their world
counterparts have no such freedom, because all four emit at `l.world`. This is why
`applyRule_emitted_time_mem` below carries `OrdTimesKnown b ord` where its world twin carries
nothing, and `applyRule_emitted_time_mem_ordTimesKnown_needed` is the witness that the hypothesis is
not removable. `mem_knownTimes_of_mem_futureOf` / `_pastOf` are the bridge, and they are exactly the
reason section A7's strengthened invariant exists.

**Identification rewrites times; it does not rewrite worlds.** `mem_identifyTime_world` concludes
`∈ b.worldFinset` outright. Its time analogue cannot: `Branch.identifyTime src tgt` moves everything
at `src` to `tgt`, and `tgt` is an arbitrary parameter of the function. So `mem_identifyTime_time`
states the honest disjunction, and `mem_identifyTime_time_at_trigger` collapses it at the only place
the engine calls it — where `tgt` is the `t₁` of `firstIncomparablePair`, already a known time. An
unconditional `∈ b.knownTimes` conclusion is not available and must not be attempted. -/

/-- A backward path of at least one edge has a last edge, so its endpoint is some constraint's
*source*. The past-directed mirror of `exists_constraint_to_of_pathN`. -/
theorem exists_constraint_from_of_pathN (ord : TimeOrdering) :
    ∀ (n : Nat) (a t : TimeIndex), 1 ≤ n →
      TimeOrdering.PathN ord.directPastOf n a t → ∃ x, (t, x) ∈ ord.constraints := by
  intro n
  induction n with
  | zero => intro a t hn; omega
  | succ m ih =>
    intro a t _ hp
    obtain ⟨c, hc, hrest⟩ := hp
    rcases Nat.eq_zero_or_pos m with rfl | hm
    · simp only [TimeOrdering.PathN] at hrest
      subst hrest
      exact ⟨a, (mem_directPastOf_iff' ord c a).mp hc⟩
    · exact ih c t hm hrest

/-- Anything in a time's past is the source of some ordering constraint. The mirror of
`exists_constraint_to_of_mem_futureOf`, and needed for the same reason: the `1 ≤ n` bound rules out
the empty path. -/
theorem exists_constraint_from_of_mem_pastOf (ord : TimeOrdering) (s t : TimeIndex)
    (h : t ∈ ord.pastOf s) : ∃ x, (t, x) ∈ ord.constraints := by
  rw [TimeOrdering.pastOf, TimeOrdering.reachableBackward_eq] at h
  rcases TimeOrdering.bfsClosure_sound _ 100 [s] [] h with hv | ⟨u, hu, n, hn1, -, hp⟩
  · simp at hv
  · exact exists_constraint_from_of_pathN ord n u t hn1 hp

/-- **The forward bridge**: under the strengthened run invariant, the ordering's forward reach lies
inside the branch's known times. This is what the four universal-propagation rules need and what
their world counterparts get for free. -/
theorem mem_knownTimes_of_mem_futureOf {b : Branch} {ord : TimeOrdering} {s t : TimeIndex}
    (haux : OrdTimesKnown b ord) (h : t ∈ ord.futureOf s) : t ∈ b.knownTimes := by
  obtain ⟨x, hx⟩ := exists_constraint_to_of_mem_futureOf ord s t h
  exact (haux (x, t) hx).2

/-- The past-directed mirror of `mem_knownTimes_of_mem_futureOf`. -/
theorem mem_knownTimes_of_mem_pastOf {b : Branch} {ord : TimeOrdering} {s t : TimeIndex}
    (haux : OrdTimesKnown b ord) (h : t ∈ ord.pastOf s) : t ∈ b.knownTimes := by
  obtain ⟨x, hx⟩ := exists_constraint_from_of_mem_pastOf ord s t h
  exact (haux (t, x) hx).1

/-- Time-level analogue of `mem_filterMap_world`: a propagation block reading formulas off the
branch through a `List.filter` selector and relabelling them emits only at times the branch already
carries. `hF` is discharged per block by opening the block's own `match`/`if`. -/
theorem mem_filterMap_time {b : Branch} {P : SignedFormula → Bool}
    {F : SignedFormula → Option SignedFormula} {g : SignedFormula}
    (hF : ∀ x y, F x = some y → y.label.time = x.label.time)
    (h : g ∈ (b.filter P).filterMap F) : g.label.time ∈ b.knownTimes := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  rw [hF x g hxg]
  exact mem_knownTimes_of_mem (List.mem_of_mem_filter hx)

/-- The same shape with a constant target time. Generic in the source list's element type, because
in the time coordinate the blocks that relabel to one fixed time range over worlds (`boxPos`,
`diamondNeg`) as well as over signed formulas — `mem_filterMap_const_world`'s `List SignedFormula`
would not cover them. -/
theorem mem_filterMap_const_time {α : Type _} {l : List α}
    {F : α → Option SignedFormula} {t : TimeIndex} {g : SignedFormula}
    (hF : ∀ x y, F x = some y → y.label.time = t) (h : g ∈ l.filterMap F) :
    g.label.time = t := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  exact hF x g hxg

/-- The forward universal-propagation shape: a `filterMap` over the ordering's forward reach. -/
theorem mem_filterMap_futureOf_time {b : Branch} {ord : TimeOrdering} {t : TimeIndex}
    {F : TimeIndex → Option SignedFormula} {g : SignedFormula}
    (haux : OrdTimesKnown b ord)
    (hF : ∀ x y, F x = some y → y.label.time = x)
    (h : g ∈ (ord.futureOf t).filterMap F) : g.label.time ∈ b.knownTimes := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  rw [hF x g hxg]
  exact mem_knownTimes_of_mem_futureOf haux hx

/-- The past-directed mirror of `mem_filterMap_futureOf_time`. -/
theorem mem_filterMap_pastOf_time {b : Branch} {ord : TimeOrdering} {t : TimeIndex}
    {F : TimeIndex → Option SignedFormula} {g : SignedFormula}
    (haux : OrdTimesKnown b ord)
    (hF : ∀ x y, F x = some y → y.label.time = x)
    (h : g ∈ (ord.pastOf t).filterMap F) : g.label.time ∈ b.knownTimes := by
  obtain ⟨x, hx, hxg⟩ := List.mem_filterMap.mp h
  rw [hF x g hxg]
  exact mem_knownTimes_of_mem_pastOf haux hx

/-! #### The `boxDiamondPersistence` time component is *not* a standalone declaration

The plan for this section called for a `mem_boxDiamondPersistence_time` beside its five siblings,
projected from `mem_boxDiamondPersistence_label`. It cannot be one: `boxDiamondPersistence` is
`private` to `Tableau.lean`, so no statement outside that module can *mention* it, and a lemma
whose hypothesis is `g ∈ boxDiamondPersistence branch w t ft` is unstateable here. What is available
is the projection *applied to a hypothesis already in scope* — `(mem_boxDiamondPersistence_label
hg).1` rewrites `g.label` to `{ world := w, time := ft }`, from which the time component follows —
and that is how the per-rule `nextTime` pinning lemmas below use it, exactly as
`applyRule_emitted_world_mem` uses it in the world coordinate.

This is register entry 9's observation in the one direction where it bites: `private` blocks name
resolution, and here the *name* is what the statement needs. It does not block unfolding, so nothing
is lost at the point of use. No `boxDiamondPersistence` block occurs in any rule the sweep below
covers — all eight rules carrying one are in `freshTimeRules` — so the sweep never needs it. -/

/-- **Identification, honestly.** Everything on `b.identifyTime src tgt` sits either at the merge
target or at a time the branch already knew.

This is where the time coordinate departs from `mem_identifyTime_world`, deliberately and
irreducibly: the world lemma concludes `∈ b.worldFinset` because identification never touches a
world, whereas here `tgt` is an arbitrary parameter and everything at `src` is moved onto it. An
unconditional `∈ b.knownTimes` conclusion is therefore false as stated — take `tgt` outside
`b.knownTimes` and any nonempty branch carrying `src`. The disjunction is collapsed at the engine's
own call site by `mem_identifyTime_time_at_trigger`; it must not be collapsed here. -/
theorem mem_identifyTime_time {b : Branch} {src tgt : TimeIndex} {g : SignedFormula}
    (h : g ∈ b.identifyTime src tgt) : g.label.time = tgt ∨ g.label.time ∈ b.knownTimes := by
  simp only [Branch.identifyTime, List.mem_eraseDups, List.mem_map] at h
  obtain ⟨x, hx, rfl⟩ := h
  by_cases hc : x.label.time = src
  · exact Or.inl (by simp [hc])
  · refine Or.inr ?_
    simp only [hc, beq_iff_eq, if_false]
    exact mem_knownTimes_of_mem hx

/-- **The disjunction collapses at the trigger.** `applyRule .timeLinearity` identifies `t₂` into
`t₁` where `(t₁, t₂)` is `firstIncomparablePair b ord`, and `firstIncomparablePair_spec` already
returns `t₁ ∈ b.knownTimes`. So at the engine's own identification site — the only site there is —
the honest disjunction of `mem_identifyTime_time` closes to plain membership.

This is the same bridge move `universeClosedAt_identify_at_trigger` makes for the closure repair:
the restriction that looks like a new obligation is already discharged by the pick. -/
theorem mem_identifyTime_time_at_trigger {b : Branch} {ord : TimeOrdering} {t₁ t₂ : TimeIndex}
    {g : SignedFormula} (htrig : firstIncomparablePair b ord = some (t₁, t₂))
    (h : g ∈ b.identifyTime t₂ t₁) : g.label.time ∈ b.knownTimes := by
  rcases mem_identifyTime_time h with hg | hg
  · exact hg ▸ (firstIncomparablePair_spec htrig).1
  · exact hg

/-- **The same bridge at the engine's own orientation.** Arm 3 merges `min t₁ t₂` into
`max t₁ t₂`, so a formula of the post-arm branch sits either at the surviving numeral or at an
untouched time; `firstIncomparablePair_spec_oriented` puts the surviving numeral in
`b.knownTimes`. This is the form `applyRule_emitted_time_mem` consumes at the `timeLinearity`
arm. -/
theorem mem_identifyTime_time_at_trigger_oriented {b : Branch} {ord : TimeOrdering}
    {t₁ t₂ : TimeIndex} {g : SignedFormula}
    (htrig : firstIncomparablePair b ord = some (t₁, t₂))
    (h : g ∈ b.identifyTime (min t₁ t₂) (max t₁ t₂)) : g.label.time ∈ b.knownTimes := by
  rcases mem_identifyTime_time h with hg | hg
  · exact hg ▸ (firstIncomparablePair_spec_oriented htrig).1
  · exact hg

/-! ### `applyRule_emitted_time_mem`: the time analogue of the world sweep

Three docstrings in this file say the same thing — `MintPaysForTime`'s own, the section note
preceding `applyRule_emitted_world_dichotomy`, and `UnorderedSuccessorLabelClosed`'s obligation
map: *there is no `applyRule_emitted_time_mem`, no statement bounding the times a rule emits at by
`b.knownTimes` with the time-minting rules separated out.* This is that statement.

**Which arm falls to which closer.** The twenty-seven non-minting constructors split five ways:

* *The trigger's own time.* The propositional rules (`andPos` … `negNeg`), the modal-temporal
  bridge `boxTemporal`, the discrete rules `priorUZ` / `priorSZ` / `z1Rule`, the Dedekind rules
  `priorUGap` / `priorSGap` / `sepRule`, `serialityRule`, and `denseIndicatorClosure` all emit at
  `l` itself. Closed by `mem_knownTimes_of_mem hsf`.
* *A constant time carried across a world change.* `boxPos` / `diamondNeg` propagate to
  `b.knownWorlds` at the trigger's time; `boxNeg` / `diamondPos` mint a fresh *world* and carry the
  trigger's time onto it. Closed by `mem_filterMap_const_time_mem` — note the source list ranges
  over worlds, which is why `mem_filterMap_const_time` was stated generically in the element type.
* *A branch formula's own time.* `boxNeg` / `diamondPos`'s `boxPosFormulas` / `diamondNegFormulas`
  auto-propagation blocks relabel branch formulas to the fresh world while keeping their times.
  Closed by `mem_filterMap_time`.
* *An ordering time.* `allFuturePos` / `allPastPos` / `someFutureNeg` / `somePastNeg` propagate to
  every time in `TimeOrdering.futureOf` / `pastOf` of the trigger. Closed by
  `mem_filterMap_futureOf_time` / `mem_filterMap_pastOf_time` — **and only under
  `OrdTimesKnown b ord`**, which is why this theorem carries a hypothesis its world twin does not.
  `applyRule_emitted_time_mem_ordTimesKnown_needed` decides that the hypothesis is not removable.
* *The identification arm.* `timeLinearity` returns whole branches: arms 1 and 2 hand back `b`
  unchanged, arm 3 hands back `b.identifyTime t₂ t₁`. Closed by `mem_knownTimes_of_mem` and
  `mem_identifyTime_time_at_trigger` respectively — the pre-declared fallback of excluding
  `timeLinearity` by hypothesis was **not** needed, because `firstIncomparablePair_spec` already
  discharges the merge target.

`orderTrichotomy` is the one arm that gets its own lemma rather than a line in the sweep: it emits
at the *common predecessor* `t₀`, which is not the trigger's time and reaches the branch only
through the candidate list's `ord.pastOf` source. Extracting that needs a `find?`-to-membership
step the sweep's `first` chain cannot perform by unification alone. -/

/-- `mem_filterMap_const_time` composed with membership of the constant. Stated separately rather
than inlined because the sweep below must run entirely in tactic mode: a term-level `by` block
inside a `first` alternative elaborates with error recovery, so a *failing* side goal would be
silently filled with `sorryAx` and the alternative would appear to succeed. Every closer in the
sweep is therefore a `refine … ?_` whose failure is a real, backtrackable failure. -/
theorem mem_filterMap_const_time_mem {α : Type _} {b : Branch} {l : List α}
    {F : α → Option SignedFormula} {t : TimeIndex} {g : SignedFormula}
    (ht : t ∈ b.knownTimes)
    (hF : ∀ x y, F x = some y → y.label.time = t) (h : g ∈ l.filterMap F) :
    g.label.time ∈ b.knownTimes := by
  rw [mem_filterMap_const_time hF h]; exact ht

/-- `orderTrichotomy`'s candidate list is built by a `flatMap` whose outermost source is
`ord.pastOf l.time`, so a surviving candidate's first component is in the trigger's past. Stated
against the list's *shape* rather than against `applyRule`, so that the three nested binders can be
peeled without re-entering the rule's guard. -/
theorem fst_mem_of_mem_trichotomyCandidates {ord : TimeOrdering} {t : TimeIndex}
    {sel : TimeIndex → List Formula} {filt : TimeIndex → Bool} {p : TimeIndex × Formula}
    (h : p ∈ (ord.pastOf t).flatMap fun t0 =>
      ((ord.futureOf t0).filter filt).flatMap fun t2 => (sel t2).map fun ψ => (t0, ψ)) :
    p.1 ∈ ord.pastOf t := by
  obtain ⟨t0, ht0, h⟩ := List.mem_flatMap.mp h
  obtain ⟨t2, -, h⟩ := List.mem_flatMap.mp h
  obtain ⟨ψ, -, rfl⟩ := List.mem_map.mp h
  exact ht0

set_option maxHeartbeats 1000000 in
/-- **`orderTrichotomy` emits at the common predecessor and at its own trigger, and at nothing
else.** The split's three arms are `[T(d) @ (w, t₀), sf]` for the three `temp_linearity` disjuncts
`d`, so every emission is either `sf` itself — on the branch by hypothesis — or sits at `t₀`, which
`fst_mem_of_mem_trichotomyCandidates` places in `ord.pastOf l.time` and
`mem_knownTimes_of_mem_pastOf` then places in `b.knownTimes` under the run invariant.

Separated from the sweep because the `find?`-to-membership step needs the candidate list named,
which a `first`-chain closer cannot do by unification. -/
theorem applyRule_orderTrichotomy_emitted_time {sf : SignedFormula} {b : Branch}
    {ord : TimeOrdering} (hsf : sf ∈ b) (haux : OrdTimesKnown b ord) :
    ∀ g ∈ (applyRule .orderTrichotomy sf b ord).1.emitted, g.label.time ∈ b.knownTimes := by
  have ht : sf.label.time ∈ b.knownTimes := mem_knownTimes_of_mem hsf
  intro g hg
  unfold applyRule at hg
  repeat' first
    | split at hg
    | simp only [apply_ite Prod.fst] at hg
  all_goals (try simp only [RuleResult.emitted] at hg)
  all_goals (try simp_all only [reduceCtorEq, List.not_mem_nil])
  have hcand := List.mem_of_find?_eq_some (by assumption)
  have ht0 := mem_knownTimes_of_mem_pastOf haux (fst_mem_of_mem_trichotomyCandidates hcand)
  simp only [List.map_cons, List.map_nil, List.flatten_cons, List.flatten_nil, List.append_nil,
    List.mem_append, List.mem_cons, List.not_mem_nil, or_false] at hg
  repeat' rcases hg with hg | hg
  all_goals first
    | exact ht0
    | exact ht

set_option maxHeartbeats 4000000 in
-- `linter.unusedTactic` calls the `assumption` in the `mem_identifyTime_time_at_trigger`
-- alternative below dead. It is NOT dead, and unlike the `_oriented` twin immediately after it
-- the linter is simply wrong here: that `refine ... ?_ hg` leaves the `?_` goal open and
-- `assumption` is what closes it. Deleting it was tried and the build failed with `unsolved
-- goals` at this declaration, so the alternative would have silently stopped discharging its
-- own side condition. The linter's per-tactic "changed nothing" test does not see a goal that
-- `refine` created and `assumption` consumed inside one `first` alternative.
set_option linter.unusedTactic false in
/-- **The time-dimension analogue of `applyRule_emitted_world_mem`.** A rule outside the minting
census emits only at times the branch already knows.

The exclusion is carried as `ruleMintsFreshTime rule = false` rather than as a chain of
`rule ≠ …` inequalities: the census is nine rules wide where the world lemma's was two, and the
`Bool` form keeps this signature stable if the census is ever re-derived. `mem_freshTimeRules`
is what ties the `Bool` back to the `Finset`.

**`OrdTimesKnown b ord` is a genuine hypothesis, not a convenience.** Its world twin needs
nothing, because every non-minting rule emits at a world some branch formula already carries.
The time coordinate has no such luck: `allFuturePos` and its three siblings propagate to
`TimeOrdering.futureOf` / `pastOf`, and nothing in `applyRule` ties an ordering time to the
branch. `applyRule_emitted_time_mem_ordTimesKnown_needed` decides a configuration where dropping
the hypothesis makes the statement false. The invariant is available at every consuming site —
it is section A7's, threaded by `ordTimesKnown_expandOnceUnblocked`.

**Footnote, added later.** On the `untl`/`snce`-free fragment the hypothesis is nevertheless
avoidable — not by weakening this statement, which stays exactly as it is, but by an incomparable
one stated beside it in section D3: `applyRule_emitted_time_mem_of_untlSnceFree` trades
`OrdTimesKnown b ord` for `∀ x ∈ b, untlSnceFree x.formula = true`, because the four propagation
arms above and `.orderTrichotomy` are all shape-gated by that condition. The refutation is
untouched: what it refutes is the *unconditional* statement, and its witness branch `[T(G p)]`
carries an `untl` node. -/
theorem applyRule_emitted_time_mem {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (haux : OrdTimesKnown b ord)
    (hmint : ruleMintsFreshTime rule = false) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.time ∈ b.knownTimes := by
  have ht : sf.label.time ∈ b.knownTimes := mem_knownTimes_of_mem hsf
  cases sf with
  | mk sign formula label =>
    cases rule <;> first
      | exact Bool.noConfusion hmint
      | exact applyRule_orderTrichotomy_emitted_time hsf haux
      | (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
          (try contradiction) <;>
          intro g hg <;>
          repeat' first
            | exact ht
            | exact mem_knownTimes_of_mem hg
            | (refine mem_identifyTime_time_at_trigger (ord := ord) ?_ hg
               assumption)
            | (refine mem_identifyTime_time_at_trigger_oriented (ord := ord) ?_ hg
               assumption)
            | (refine mem_filterMap_const_time_mem (t := label.time) ht ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (refine mem_filterMap_time ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (refine mem_filterMap_futureOf_time haux ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (refine mem_filterMap_pastOf_time haux ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (simp only [RuleResult.emitted, Branch.boxPosFormulas, Branch.diamondNegFormulas,
                 List.map_cons, List.map_nil, List.flatten_cons, List.flatten_nil,
                 List.append_nil, List.mem_cons, List.mem_append, List.not_mem_nil,
                 or_false, List.mem_filter] at hg)
            | (subst hg; exact ht)
            | (rcases hg with hg | hg))

/-- The same statement in the `Finset` coordinate, restoring shape parity with
`applyRule_emitted_world_mem`, which concludes in `b.worldFinset`. -/
theorem applyRule_emitted_timeFinset_mem {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hsf : sf ∈ b) (haux : OrdTimesKnown b ord)
    (hmint : ruleMintsFreshTime rule = false) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.time ∈ b.timeFinset := fun g hg =>
  List.mem_toFinset.mpr (applyRule_emitted_time_mem hsf haux hmint g hg)

/-! #### `OrdTimesKnown` is not removable from the sweep

The witness: one branch carrying `T(G p)` at the initial label, and an ordering asserting `0 < 5`
with nothing at time `5` on the branch. `allFuturePos` propagates `T(p)` to every time in
`ord.futureOf 0`, hence to time `5`, which `b.knownTimes = [0]` does not contain. The rule is
outside the minting census — it mints no time, it *reads* one off the ordering — so the exclusion
hypothesis is satisfied and the only thing standing between this configuration and a
counterexample is `OrdTimesKnown`, which the witness ordering fails. -/

private def otwP : Formula := .atom (Atom.mkBase "p")

/-- The trigger of the `OrdTimesKnown`-necessity witness: `T(G p)` at the initial label. -/
def ordTimesWitnessSF : SignedFormula :=
  SignedFormula.pos (Formula.allFuture otwP) Label.initial

/-- The witness branch: one formula, known times `[0]`. -/
def ordTimesWitnessBranch : Branch := [ordTimesWitnessSF]

/-- The witness ordering: `0 < 5`, with `5` on no branch formula. Fails `OrdTimesKnown`. -/
def ordTimesWitnessOrd : TimeOrdering := { constraints := [(0, 5)] }

/-- The witness ordering does fail the invariant — otherwise the configuration below would refute
`applyRule_emitted_time_mem` itself rather than justify its hypothesis. -/
theorem ordTimesWitnessOrd_not_ordTimesKnown :
    ¬ OrdTimesKnown ordTimesWitnessBranch ordTimesWitnessOrd := by
  unfold OrdTimesKnown; decide

/-- **`OrdTimesKnown` cannot be dropped from `applyRule_emitted_time_mem`.** Decided, not argued.

This is the time coordinate's structural departure from the world coordinate stated as a fact: the
world sweep needs no run invariant because no rule reads a world off anything but the branch,
whereas four rules read *times* off the ordering. A reader who removes the hypothesis on the
grounds that its world twin does without one is re-attempting a refuted statement. -/
theorem applyRule_emitted_time_mem_ordTimesKnown_needed :
    ¬ (∀ (rule : TableauRule) (sf : SignedFormula) (b : Branch) (ord : TimeOrdering),
        sf ∈ b → ruleMintsFreshTime rule = false →
        ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.time ∈ b.knownTimes) := by
  intro h
  have hbad := h .allFuturePos ordTimesWitnessSF ordTimesWitnessBranch ordTimesWitnessOrd
    (by decide) (by decide)
  revert hbad
  decide

/-! ### The time dichotomy, and its lift to the engine

The world coordinate is complete because `applyRule_emitted_world_dichotomy` says every emission
sits at a branch world or at `Branch.nextWorld`, with no third case. This subsection closes the
time coordinate the same way. The shape is the same because the *fact* is the same: every fresh
time in `applyRule` is `branch.nextTime`, bound at exactly nine sites, with no `nextTime + k`
anywhere.

The nine minting rules split two ways, and the split is not cosmetic:

* the **six** in `freshTimeRules ∩ freshLabelRules` are *consumable* — they do not re-include their
  trigger — so every one of their emissions is pinned to `Branch.nextTime` outright
  (`applyRule_emitted_nextTime_of_freshLabel`);
* the **three** in `freshTimeRules \ freshLabelRules` re-include the trigger in every arm
  (`untlNeg` and `snceNeg` are `ruleSelfGuarded`; `densityRule` emits alongside branch-carried
  material), so a `= Branch.nextTime` conclusion is *false* for them and the honest statement is
  the disjunction directly. That is why they get their own lemmas rather than joining the group. -/

set_option maxHeartbeats 2000000 in
/-- **The six consumable minting rules emit only at `Branch.nextTime`.** The exact time-coordinate
analogue of `applyRule_boxNeg_emitted_world` / `applyRule_diamondPos_emitted_world`, grouped
because all six share one arm shape: a witness at `freshLabel`, auto-propagation blocks relabelled
to `freshTime`, and a `boxDiamondPersistence` block whose label
`mem_boxDiamondPersistence_label` pins to `{ world := _, time := freshTime }`.

The two hypotheses together name exactly `freshTimeRules ∩ freshLabelRules` =
`{allFutureNeg, allPastNeg, someFuturePos, somePastPos, untlPos, sncePos}`. No `hsf` is needed:
nothing in these arms reaches back to the trigger's own time. -/
theorem applyRule_emitted_nextTime_of_freshLabel {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering}
    (hT : ruleMintsFreshTime rule = true) (hL : ruleMintsFreshLabel rule = true) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted, g.label.time = b.nextTime := by
  cases sf with
  | mk sign formula label =>
    cases rule <;> first
      | exact Bool.noConfusion hT
      | exact Bool.noConfusion hL
      | (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
          (try contradiction) <;>
          intro g hg <;>
          repeat' first
            | rfl
            | (rw [(mem_boxDiamondPersistence_label hg).1])
            | (refine mem_filterMap_const_time ?_ hg
               clear hg
               intro x y hy
               repeat' first
                 | split at hy
                 | simp only [Option.some.injEq] at hy
               all_goals first
                 | (subst hy; rfl)
                 | (simp only [reduceCtorEq] at hy))
            | (simp only [RuleResult.emitted,
                 Branch.allFuturePosFormulas, Branch.allPastPosFormulas,
                 Branch.someFutureNegFormulas, Branch.somePastNegFormulas,
                 List.flatten_cons, List.flatten_nil,
                 List.append_nil, List.mem_cons, List.mem_append, List.not_mem_nil,
                 or_false] at hg)
            | (subst hg; rfl)
            | (rcases hg with hg | hg))

set_option maxHeartbeats 2000000 in
/-- **The three self-guarded minting rules, at the honest disjunction.**

`untlNeg` and `snceNeg` re-include their trigger `sf` in **every** arm — that is what
`ruleSelfGuarded` means for them — and `densityRule` emits beside branch-carried material, so none
of the three admits a `= Branch.nextTime` conclusion. What is true is the disjunction, and it needs
`hsf` (for the re-included trigger) where the group lemma above needed nothing.

The three are handled together because their arms differ only in which auto-propagation blocks they
carry, all of which relabel to `freshTime`. `OrdTimesKnown` is *not* needed: unlike the sweep, no
arm here reads a time off the ordering. -/
theorem applyRule_emitted_time_dichotomy_selfGuarded {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} (hsf : sf ∈ b)
    (h : rule = .untlNeg ∨ rule = .snceNeg ∨ rule = .densityRule) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted,
      g.label.time ∈ b.knownTimes ∨ g.label.time = b.nextTime := by
  have ht : sf.label.time ∈ b.knownTimes := mem_knownTimes_of_mem hsf
  cases sf with
  | mk sign formula label =>
    rcases h with rfl | rfl | rfl <;>
      (cases sign <;> simp only [applyRule] <;> (repeat' split) <;>
        (try contradiction) <;>
        intro g hg <;>
        repeat' first
          | exact Or.inr rfl
          | exact Or.inl ht
          | exact Or.inl (mem_knownTimes_of_mem hg)
          | (refine Or.inr ?_; rw [(mem_boxDiamondPersistence_label hg).1])
          | (refine Or.inr (mem_filterMap_const_time ?_ hg)
             clear hg
             intro x y hy
             repeat' first
               | split at hy
               | simp only [Option.some.injEq] at hy
             all_goals first
               | (subst hy; rfl)
               | (simp only [reduceCtorEq] at hy))
          | (simp only [RuleResult.emitted,
               Branch.allFuturePosFormulas, Branch.someFutureNegFormulas,
               Branch.somePastNegFormulas,
               List.flatten_cons, List.flatten_nil,
               List.append_nil, List.mem_cons, List.mem_append, List.not_mem_nil,
               or_false] at hg)
          | (subst hg; exact Or.inl ht)
          | (subst hg; exact Or.inr rfl)
          | (rcases hg with hg | hg))

/-- **The time dichotomy, complete.** Every formula a rule emits sits either at a time the branch
already carries or at `Branch.nextTime` — there is no third case.

The exact counterpart of `applyRule_emitted_world_dichotomy`, and assembled the same way: from the
landed sweep (`applyRule_emitted_time_mem`, the 27 non-minting rules) plus the two minting lemmas
(the six consumable ones and the three self-guarded ones), and nothing else. The case split is on
the two `Bool` census predicates rather than on rule names, which is what keeps it nine-and-27
rather than a chain of 36 inequalities.

**It carries `OrdTimesKnown b ord`, and its world twin does not.** The hypothesis enters through
the sweep, not through the minting lemmas — neither of those needs it. See
`applyRule_emitted_time_mem_ordTimesKnown_needed` for why it cannot be dropped, and
`expandOnceUnblocked_ordTimesKnown` for why every consuming site already has it. -/
theorem applyRule_emitted_time_dichotomy {rule : TableauRule} {sf : SignedFormula}
    {b : Branch} {ord : TimeOrdering} (hsf : sf ∈ b) (haux : OrdTimesKnown b ord) :
    ∀ g ∈ (applyRule rule sf b ord).1.emitted,
      g.label.time ∈ b.knownTimes ∨ g.label.time = b.nextTime := by
  intro g hg
  by_cases hT : ruleMintsFreshTime rule = true
  · by_cases hL : ruleMintsFreshLabel rule = true
    · exact Or.inr (applyRule_emitted_nextTime_of_freshLabel hT hL g hg)
    · refine applyRule_emitted_time_dichotomy_selfGuarded hsf ?_ g hg
      simp only [Bool.not_eq_true] at hL
      revert hT hL
      cases rule <;> simp +decide
  · simp only [Bool.not_eq_true] at hT
    exact Or.inl (applyRule_emitted_time_mem hsf haux hT g hg)

/-! #### The lift to the engine

`MintPaysForTime` and `UnorderedSuccessorLabelClosed` quantify over
`unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1`, not over `applyRule`. The lift
routes through the same invariant-agnostic machinery `expandOnceUnblocked_ordTimesKnown` uses —
`pick_branches_eq`, `pick_stage_source`, `resultBranch_sub` — so the three-stage pick is never
destructured a second time. -/

theorem pickBranches_time_dichotomy {b : Branch} {ord : TimeOrdering}
    {p : Option (TableauRule × RuleResult × TimeOrdering)}
    (haux : OrdTimesKnown b ord)
    (hp : ∀ r res o, p = some (r, res, o) → ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)) :
    ∀ nb ∈ pickBranches b p, ∀ t ∈ nb.knownTimes, t ∈ b.knownTimes ∨ t = b.nextTime := by
  rcases p with _ | ⟨r, res, o⟩
  · simp [pickBranches]
  · obtain ⟨sf, hsf, hA⟩ := hp r res o rfl
    intro nb hnb t htm
    obtain ⟨-, hsub⟩ := resultBranch_sub (b := b) (nb := nb) (res := res) hnb
    obtain ⟨x, hx, rfl⟩ := exists_mem_of_mem_knownTimes htm
    rcases hsub x hx with hxe | hxb
    · refine applyRule_emitted_time_dichotomy (rule := r) (sf := sf) hsf haux x ?_
      rw [hA]
      exact hxe
    · exact Or.inl (mem_knownTimes_of_mem hxb)

/-- **The time dichotomy at engine level.** Every time an unordered successor knows is a time `b`
knew, or `b.nextTime`. One step adds at most the one fresh time, and never more.

This is the statement `MintPaysForTime`'s first disjunct is really about, lifted to the shape that
disjunct quantifies at. -/
theorem unorderedSuccessor_time_dichotomy {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesKnown b ord) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      ∀ t ∈ nb.knownTimes, t ∈ b.knownTimes ∨ t = b.nextTime := by
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
  exact pickBranches_time_dichotomy haux (pick_stage_source b ord fc tr)

/-- **The quantitative form: one step adds at most one time.**

`MintPaysForTime`'s first disjunct asks for `nb.knownTimes.card ≤ b.knownTimes.card`, which is
false at every minting step. This is the true inequality one apart from it, and it is a *theorem*
rather than a hypothesis — which is exactly why the repaired predicate in the next subsection
states its first disjunct against this rather than against the flat bound. -/
theorem knownTimes_card_le_succ_of_unorderedSuccessor {b : Branch} {ord : TimeOrdering}
    {fc : FormalSystem.ProofSystem.FrameClass} {tr : EventualityTracker}
    (haux : OrdTimesKnown b ord) :
    ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1,
      nb.knownTimes.toFinset.card ≤ b.knownTimes.toFinset.card + 1 := by
  intro nb hnb
  have hsub : nb.knownTimes.toFinset ⊆ insert b.nextTime b.knownTimes.toFinset := by
    intro t ht
    rcases unorderedSuccessor_time_dichotomy haux nb hnb t (List.mem_toFinset.mp ht) with h | h
    · exact Finset.mem_insert_of_mem (List.mem_toFinset.mpr h)
    · exact h ▸ Finset.mem_insert_self _ _
  exact le_trans (Finset.card_le_card hsub) (Finset.card_insert_le _ _)

end FormalSystem.Metalogic.Decidability
