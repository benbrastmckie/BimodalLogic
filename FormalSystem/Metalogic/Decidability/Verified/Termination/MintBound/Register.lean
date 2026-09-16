/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel

/-! # C9. The do-not-re-attempt register

Twenty-five statements that look like the natural next lemma and are **not** available. Each is cited
by declaration name and, where one exists, by refuting witness — never by an issue number or a
tracker entry, both of which outlive their meaning. A reader who finds one of these attractive has
already been here.

1. **`buildTableau_isSome`, unconditionally.** False at the engine's own default: the first line of
   `expandBranchWithFuel` returns `none` once `branchesUsed` reaches `maxBranches = 50000`, at
   every fuel figure whatsoever. Any true statement has to quantify the branch budget, which is
   what `buildTableauAt_isSome_of_budget` does. The default is a deliberate runtime guard and is
   not edited by this development.

2. **`buildTableau_isSome_of_budget` in the original target shape** — the branch budget quantified
   as the *only* new hypothesis, with `soundFuel' φ` as the fuel. Refuted by measurement:
   `φ = F(G p)` returns `none` at `fuel = 229376` and `maxBranches = 10¹²`, and the cause is
   `resolveOpenArm = none`, neither the fuel guard nor the budget guard. Raising either number
   changes nothing, because neither appears in the disagreement.

3. **A `.splitOrdered` cardinality twin of `expandOnceUnblocked_split_card_lt`.** Branch
   cardinality is not monotone across an ordered split — arm 3 merges two times and can shrink the
   branch as a set — so there is no `b.toFinset.card < p.1.toFinset.card` to be had. The ordered
   dimension is measured by `splitOrderedRank` instead.

4. **An `allClosed` `iff` between `buildTableauAt` and `buildTableau`.** False, not merely
   unproved. `buildTableauAt_allClosed_imp` is the direction that holds; the converse fails exactly
   when the literal test finds outstanding work at the top-level open branch, the blocking-aware
   test does not, and the post-blocking pass would have closed the branch. That is a genuine
   difference in verdict.

5. **The unconditional, `IrreflOrd`-free form of `witnessPresent_identifyTime`.** Refuted by
   `witnessPresent_identifyTime_unconditional_false`: `TimeOrdering.identifyTime` drops every
   constraint whose endpoints rename together, including a pre-existing self-loop, and a witness
   reachable only around such a loop is destroyed.

6. **Route (a): a lower bound on `(b.identifyTime t₂ t₁).toFinset.card` in terms of
   `b.toFinset.card`.** Dead by definition — `Branch.identifyTime` is `(b.map relabel).eraseDups`
   and the merge is bounded only by `|U|`. Bounding the *loss* from above is available and is
   `shrinkage_le_card`; bounding the survivors from below is not. A reader who meets
   `shrinkage_le_card` and thinks it revives this route has the direction backwards.

7. **Preservation of `OrdTimesLeMaxTime` across the ordered split's identification arm.** Refuted,
   not merely unproved, by `ordTimes_identifyTime_arm3_false`, which decides a configuration where
   `Branch.maxTime` drops from `5` to `0`. The settled repair is `OrdTimesKnown` with
   `ordTimesKnown_identifyTime`, and `ordTimesLeMaxTime_of_ordTimesKnown` records that this is a
   **strengthening** rather than a weakening. A reader who "simplifies" the run invariant back to
   the `≤ maxTime` form is re-attempting a refuted statement.

8. **`BudgetedTotality` with its `β`-linear budget hypothesis and nothing else.** Refuted by
   `budgetedTotality_beta_zero_false`: at `β = 0` the hypothesis degenerates to
   `branchesUsed ≤ maxBranches`, which the engine's strict guard does not respect. The coefficient
   needs `β ≥ 1` to make the budget hypothesis strict and `β ≥ 3` to cover the measured split
   arity; `BudgetedTotalityAt` carries both. Separately, the *figure* in `BudgetedTotality` is
   short — see the divergence recorded in section C7 — which is why the landed statement is at
   `mintAwareFuel`, with `splitAwareFuel_le_mintAwareFuel` recording that the derived figure
   enlarges rather than replaces the landed one.

9. **`DifficultyBounded fc U D` at any `D`, for a `U` the engine fires on.** Refuted, not merely
   unproved, by `difficultyBounded_multiplicity_false`, which is universally quantified in `D` and in
   the frame class. The cause in one line: `estimateBranchDifficulty` sums over the branch **list**
   and adds `b.length / 4`, confinement to `U` bounds only `b.toFinset`, and no `Nodup` invariant on
   a branch exists anywhere in the development — successors are built as raw `formulas ++ b` with no
   `eraseDups` (`Tableau.lean:2233-2239`) and avoiding a `Nodup` side condition was a deliberate
   design goal (`BranchOrder.lean:275-290`). So a `U`-confined branch can be arbitrarily long, and
   `estimateBranchDifficulty_length_le` turns any difficulty bound into a bound on that length.

   **Widening `temporalCount`/`modalCount` does not revive it.** A reader who reaches for
   `Saturation.lean` on the strength of an older version of `DifficultyBounded`'s own docstring has
   already been here: `private` blocks name resolution, not unfolding, so a bound is statable and
   provable from this file with the markers exactly as they are — `estimateBranchDifficulty_length_le`
   and `estimateBranchDifficulty_le_of_subperm` are the demonstrations. And the refuting witness is
   an implication between two atoms, on which both counters are `0`, so the refutation never touches
   them. `Saturation.lean` is deliberately not edited.

   The settled repair is `StepLengthBounded`, which is equivalent to the difficulty bound up to a
   factor of `4` (`difficultyBounded_of_stepLengthBounded`, `stepLengthBounded_of_difficultyBounded`)
   and is satisfiable; `buildTableauAt_isSome_of_lengthBudget` and
   `buildTableauAt_isSome_at_seed_lengthBudget` are the termini stated at it, and
   `difficultyBoundedAt_ceiling` reduces the length-hypothesis form to the rule-local
   `StepLengthGrowth`, whose full obligation map is recorded on its own docstring.

10. **Clause 2 of `UniverseClosed fc U`, at any nonempty `U`.** Refuted, not merely unproved, by
    `universeClosed_identify_retime_false`, which is universally quantified in `U` and takes no frame
    class at all. The cause in one line: the conjunct quantifies the identification's merge **target**
    `t₁` over all of `TimeIndex` with nothing tying it to the branch, so a `Finset` universe would
    have to contain a distinct retiming of one of its own members at every one of infinitely many
    times. `universeClosed_identify_empty` shows it *does* hold at `U = ∅`, so its satisfiability set
    is exactly `{∅}` — satisfiable only where the terminus it guards is vacuous, since
    `signedUniverse C L` is empty only when `C` or `L` is. `universeClosed_nonempty_false` is the
    residual-level corollary.

    **The settled repair is `UniverseClosedAt`**, which restricts `t₁` — and only `t₁` — to
    `b.knownTimes`, and `universeClosedAt_of_universeClosed` records the direction: the new hypothesis
    is *weaker*, so every theorem restated against it is a strengthening. The restriction leaks no new
    hypothesis into the terminus, because both consuming sites reach `t₁` through
    `expandOnceUnblocked_splitOrdered_shape` and `firstIncomparablePair_spec` already returns
    `t₁ ∈ b.knownTimes`; `universeClosedAt_identify_at_trigger` is that bridge.
    `buildTableauAt_isSome_of_lengthBudget_at` and its siblings are the termini stated at the repaired
    shape, and `timeMergeClosed_identifyTime_signedUniverse` discharges the repaired clause at
    `U = signedUniverse C L` under `TimeMergeClosed L`. `UniverseClosed` itself is retained verbatim,
    because the landed terminus is stated against it and nothing in this file is withdrawn.

11. **Clause 1 of `UniverseClosed`/`UniverseClosedAt` at a fixed finite `signedUniverse C L`, and any
    repair of it phrased as a condition on `L`.** Both are refuted.

    *The clause*: `universeClosed_fresh_world_escapes` exhibits `C = {□p, p}`, `L = {⟨0,0⟩}` and the
    one-formula branch `[F(□p)@⟨0,0⟩]`, whose step — `.boxNeg`, at **every** frame class and every
    tracker — emits `F(p)` at world `1`. `applyRule_boxNeg_emitted_world` and
    `applyRule_diamondPos_emitted_world` are why: those two rules emit **only** at
    `Branch.nextWorld`, which `nextWorld_not_mem_worldFinset` says is fresh. Since both predicates
    carry clause 1 verbatim, one witness refutes both;
    `universeClosedAt_fresh_world_escapes` states the second. Blocking does not save it: clause 1
    quantifies over every tracker, and the witness is proved at all of them.

    *Any `L`-side repair*: `freshWorldHeadroom_not_universal` proves that for **no** nonempty finite
    `L` does every `L`-confined branch have `FreshWorldHeadroom L b`. Each enlargement of `L` raises
    the reachable `maxWorld` at least as much as it adds, so the gap re-opens. A reader who, having
    seen `TimeMergeClosed` close clause 2's gap, reaches for the analogous condition on worlds has
    already been here — the asymmetry is real: identification moves a label *within* the existing
    coordinates, whereas `boxNeg` moves it *past* them. The repair therefore has to be branch-side,
    and the residue is carried as the named residual `UnorderedSuccessorLabelClosed`, whose
    per-coordinate obligation map is on its own docstring. What is **not** refuted, and is proved
    outright, is clause 1's *formula* coordinate: `unorderedSuccessor_formula_mem`, for both unordered
    successor shapes.

    *And the label coordinate is not open either — it is refuted outright.* Section C11 reduces the
    residual to the branch-side rectangle `FreshLabelHeadroom`
    (`unorderedSuccessorLabelClosedOrd_of_headroom`) with both coordinates fully accounted for, and
    `freshLabelHeadroom_not_universal` refutes that rectangle at every nonempty finite `L` by the same
    `maxWorld` argument. That much refutes the *reduction's antecedent*. The residual **itself** is
    refuted one step further on, at the same generality:
    `unorderedSuccessorLabelClosed_nonempty_false` and
    `unorderedSuccessorLabelClosedOrd_nonempty_false` are false at every nonempty finite `L`, at every
    frame class, and `unorderedSuccessorLabelClosed_empty` holds at `∅` — so the residual's
    satisfiability set is exactly `{∅}`. Entry 21 carries the consequence for the theorems that
    assume it.

12. **Repairing clause 2 by constraining `t₂`, or by constraining both `t₁` and `t₂`.** Neither is
    wrong in the sense of being false — they are weaker predicates than necessary, which makes every
    theorem assuming them weaker than it needs to be, and that is the defect.
    `timeMergeClosed_identifyTime_signedUniverse`'s proof is the evidence: it constrains only `t₁`,
    and the source time `t₂` is never used to build a label — only ever tested against — so a
    hypothesis about it would sit unused. Constraining `t₂` *instead* of `t₁` does not even repair the
    refutation, since `universeClosed_identify_retime_false` instantiates at
    `t₂ = x.label.time`, which is a known time of its witness branch already; the pigeonhole runs on
    `t₁`. A reader who constrains both has needlessly weakened `UniverseClosedAt`; one who constrains
    only `t₂` has not repaired anything.

13. **"Not in `ruleMintsFreshLabel`" read as "introduces no time".** Refuted in **both** directions
    by `freshTimeRules_incomparable_freshLabelRules`: `boxNeg` and `diamondPos` are witness-guarded
    and mint no time, while `densityRule` (gap-guarded) and the `untlNeg` / `snceNeg` ACTIVE arms
    (`ruleSelfGuarded`) mint a time while sitting outside the list. The two lists are incomparable,
    not nested. `expandOnceNoFresh` is the operational evidence and was there all along: it runs the
    `ruleMintsFreshLabel` test **and then**, separately, a `newOrd.constraints.length` test, and two
    tests in sequence are necessary only when neither list subsumes the other. The census that *is*
    the time-minting list is `freshTimeRules`, nine rules wide, with `mem_freshTimeRules` as its
    anti-drift guarantee.

14. **`MintPaysForTime fc U Tmax` as literally stated.** Refuted, not merely unproved, by
    `mintPaysForTime_untlNeg_false`, which is universally quantified in the frame class **and** in
    `Tmax`. The cause in one line: `untlNeg` is in `freshTimeRules` and not in `freshLabelRules`, so
    firing it mints a time while moving no pair of `mintPotential`'s index set `freshLabelRules ×ˢ U`
    — disjunct 1 fails because a known time was added, disjunct 2 fails because the potential is
    unchanged, and `mintTimeBudget` actually rises. `mintPaysForTime_empty` shows it does hold at
    `U = ∅`, so as with `UniverseClosed` its satisfiability set is where the terminus it guards is
    vacuous.

    **Neither obvious repair is available**, and both are closed off by decided statements rather
    than by argument. *Re-indexing the potential on `freshTimeRules`*:
    `witnessPresent_eq_false_of_not_freshLabel` proves `witnessPresent` is identically `false`
    outside `freshLabelRules` — its match has exactly eight arms — so the three added columns are
    permanently false, contribute `3 · |U|` to the count, and never move. *Dropping disjunct 1's
    cardinality conjunct*, leaving the ordering rank: `splitOrderedRank_lt_of_knownTimes_lt` proves
    one extra known time strictly raises `splitOrderedRank`, because its base `Tmax² + 1` is by
    construction one more than `incompPairs`' range, so the rank conjunct fails at **every**
    time-minting step; `mintPaysForTime_rank_repair_false` decides the weakened predicate false at
    the same configuration, at every frame class, for every `Tmax ≥ 3`.

    What is missing is a **fourth measure component** paying for the three self-guarded minting
    rules — `untlNeg` / `snceNeg`, whose guards are `futureOf`/`pastOf` emptiness plus
    `ord.timeCount < 4`, and `densityRule`, whose guard is the maximal-unfilled-gap set — that also
    survives the identification arm, which can lower `ord.timeCount`. That is open, and it is the
    only thing that is.

15. **Time reuse after an identification: it happens.** Not open, and not forbidden by the run
    invariant. `nextTime_reissues_retired_time` decides a configuration where
    `firstIncomparablePair` merges the branch's largest time away, `Branch.maxTime` drops with it,
    and the post-identification `Branch.nextTime` is exactly the retired value;
    `reuse_driven_through_engine` decides that two `expandOnceUnblocked` steps later that value is
    back on the branch, so this is a run and not a hand-assembled `Branch`. The available facts a
    reader will reach for — `src_not_mem_knownTimes_identifyTime`, `knownTimes_card_lt_identifyTime`
    — say nothing about `Branch.maxTime` and cannot rule it out.

    Consequently the **σ-hit hypothesis of `mintPotential_lt_of_mint` is false**, not merely
    undischarged: `rhoSF_time_ne_src` shows the renaming's image omits the retired time entirely,
    and `mint_not_in_rhoSF_image` turns that into the statement that nothing minted at the re-issued
    time lies in σ's image. The **live-times reformulation does not escape it**: that variant filters
    additionally on the formula's time being a fixed point of `σ`, and `rho_src_ne_src` shows the
    re-issued time is not one. The obstruction is intrinsic to identification-plus-`maxTime`.

16. **An unconditional `applyRule_emitted_time_mem`, without `OrdTimesKnown`.** Refuted by
    `applyRule_emitted_time_mem_ordTimesKnown_needed`. A reader who notices that
    `applyRule_emitted_world_mem` needs no run invariant and removes the hypothesis from its time
    twin has already been here: four rules — `allFuturePos`, `allPastPos`, `someFutureNeg`,
    `somePastNeg` — propagate to every time in `TimeOrdering.futureOf` / `pastOf` of the trigger, and
    nothing in `applyRule` ties an ordering time to the branch. The witness is one branch carrying
    `T(G p)` at the initial label with the ordering asserting `0 < 5`. Their world counterparts have
    no such freedom because all four emit at `l.world`; the asymmetry is real, and it is why
    `mem_knownTimes_of_mem_futureOf` / `_pastOf` exist. The hypothesis costs nothing at the consuming
    sites — `expandOnceUnblocked_ordTimesKnown` supplies it.

    *A syntactically restricted form does exist, and it does not weaken this entry.*
    `applyRule_emitted_time_mem_of_untlSnceFree` (section D3) is the same sweep with
    `OrdTimesKnown b ord` replaced by `∀ x ∈ b, untlSnceFree x.formula = true`, and it reaches
    exactly the `untl`/`snce`-free fragment. The two statements are **incomparable**, not ordered:
    neither hypothesis implies the other, and what this entry refutes is the *unconditional*
    statement — no run invariant, no syntactic condition, nothing — which stays refuted. The witness
    above fails the syntactic condition outright, since its branch carries `T(G p)` and
    `Formula.allFuture p` is an `untl` node.

    *Why it works, so that the boundary is not mistaken for luck.* `haux` is consumed at exactly five
    rule arms and by exactly three closer families, and every one of the five is shape-gated by the
    syntactic condition: `.allFuturePos` and `.allPastPos` through the raw `Formula.allFuture` /
    `Formula.allPast` constructor patterns, `.someFutureNeg` and `.somePastNeg` through the
    `asSomeFuture?` / `asSomePast?` views, and `.orderTrichotomy` through its `fires` guard's demand
    that the branch carry a `Formula.someFuture`-headed disjunct. The first four are gated by the
    *trigger's* shape; the fifth by what the *branch* carries, which is why the restricted form takes
    a branch-level hypothesis rather than a trigger-level one. `boxFree` plays no part: it closes the
    world coordinate, not this one.

    *What this buys downstream.* `unorderedSuccessor_knownTimes_subset_of_untlSnceFree` and, through
    it, `universeClosedAt_signedUniverse_of_propositional` — `UniverseClosedAt` at
    `signedUniverse C L` with no `UnorderedSuccessorLabelClosed`, no `OrdTimesKnown` and no
    frame-class restriction. See section D4's boundary block, and entry 21's closing paragraphs,
    which this supersedes on the point of Route 1 being unattempted.

17. **A fourth measure component in the shape of a second defect ledger over `selfGuardRules ×ˢ U`,
    paying for the self-guarded minting rules by their own discharge.** This is the component entry
    14 says is missing, built in the one shape that survives every objection entry 14 raises — and
    it is refuted anyway, not merely unproved, by `mintPaysForTimeAt_reuse_false`, which is
    universally quantified in the frame class **and** in `Tmax`. The design is landed and named
    (`selfGuardRules`, `selfGuardDischarged`, `selfGuardPotential`, `MintPaysForTimeAt`) only
    because a refutation has to be stated about something; none of it is offered as a repair.

    *What the design gets right, so that a reader does not re-attempt it by fixing the wrong thing.*
    It is a **second** ledger with its own defect notion rather than a widening of `mintPotential`'s,
    so entry 14's `witnessPresent_eq_false_of_not_freshLabel` route does not touch it — the
    catch-all polarity of `selfGuardDischarged` is `true`, making out-of-range columns permanently
    *cured* and contributing `0`, the mirror image of the polarity that kills the re-indexing route.
    It is stated against `ord.futureOf` / `ord.pastOf` emptiness and never against `ord.timeCount`,
    so `TimeOrdering.identifyTime` lowering the cap does not reach it. And it is not inert:
    `selfGuardPotential_lt_at_gate_with_id` decides that at the very step that refutes it the
    potential **does** fall, `4` to `3`, under `σ = id`.

    *What refutes it.* Entry 15's σ-hit obligation, inherited in a weakened **time-hit** form and
    still false. `selfGuardPotential`'s columns are indexed by the σ-image's *time*, not by the
    σ-image formula, so it needs only some `sf ∈ U` with `(σ sf).label.time` equal to the trigger's
    time — strictly less than the literal `σ sf` that `mintPotential_lt_of_mint` demands. **The
    weakening escapes nothing, and the reason is one line.** `rhoSF_time_ne_src` is *already* a
    statement about times: `(rhoSF src tgt sf).label.time ≠ src`, for every `sf` whatsoever. Entry
    15's formula-hit refutation `mint_not_in_rhoSF_image` is three lines on top of it. A weakening
    cannot escape the statement its own refutation was a corollary of.

    *The general reason, then the decided instance.* `selfGuard_no_column_at_retired_time`: the
    curing edge that `untlNeg`'s ACTIVE arm adds is anchored at the trigger's time, so when that
    time is one an earlier identification retired — which entry 15 decides the engine re-issues —
    **no column of `selfGuardRules ×ˢ U` is indexed there at all**, the arm cures nothing, and the
    count cannot fall. That holds for every `U`, every trigger and every retired time; the concrete
    gate is an instance of it, not a lucky configuration. At that gate (`σ = rhoSF 2 0`) all three
    disjuncts fail on decided numbers: the step mints time `3`, so `knownTimes` goes `3 → 4` and
    disjunct 1's `4 ≤ 3` is false; `mintTimeBudget` goes `27 → 28` while `mintPotential` is `24`
    before and after, so both of disjunct 2's conjuncts are false; and `selfGuardPotential` is `3`
    before and after, so disjunct 3's `3 < 3` is false. `gate_is_reissue_hazard` decides all seven
    preconditions separately, so the failure is attributable to the arm rather than to a violated
    hypothesis, and the `σ = id` measurement above locates it at σ rather than at the ledger's shape.

    **So no reshaping of this component is the repair.** The obstruction is intrinsic to
    identification-plus-`maxTime` — the same wall entry 15's live-times reformulation hits — and it
    is indifferent to whether the decrease is witnessed at the trigger's formula or at its time. A
    reader who arrives holding a fourth component whose decrease is witnessed anywhere on the
    trigger's *label* has already been here. What entry 14 says is missing is still missing; this is
    one more closed route to it.

    *What is **not** refuted.* The density coordinate. `densityRule` is outside `selfGuardRules` by
    construction, its termination argument is about the *gap set* rather than about any self-guard,
    and nothing above touches it. The intended second component `gapPotential` — indexed by
    `U ×ˢ U`, `denseRules`-gated, quadratic in `|U|` — is a named residual recorded in the
    subsection "The density residual" above the register, unattempted rather than refuted.

18. **A `nextTime` redefinition, a `TimeOrdering` highwater field, or any other bookkeeping-side
    cure for entry 15's time reuse.** Not refuted — *closed by being unnecessary*, which is why this
    entry reads differently from the seventeen above it. It is here so that a reader who arrives
    holding one of those designs stops before paying for it.

    *What was actually wrong.* Entry 15 is a statement about `Branch.identifyTime` retiring the
    branch's **largest** time. The ordered split's arm 3 called `branch.identifyTime t₂ t₁`, and
    `firstIncomparablePair_spec` guarantees only `t₂ ≠ t₁` — never `t₁ < t₂` — so the arm retired
    `t₂` whatever its magnitude, `Branch.maxTime` fell with it, and `Branch.nextTime`, being
    `maxTime + 1`, handed back the value just retired. The defect was in *which numeral the arm
    chose to keep*, not in `nextTime`'s definition and not in the measure.

    *The repair, in one line.* Arm 3 now merges `min t₁ t₂` into `max t₁ t₂`. Which numeral survives
    is semantically arbitrary — identification asserts the two instants are the same, and nothing in
    the semantics reads a time index's magnitude — so the orientation is free, and it makes
    `Branch.maxTime` non-decreasing at the only branch step that could lower it.
    `maxTime_le_identifyTime_of_le` is the whole content: identifying a time into a time at least as
    large never lowers the maximum, on an arbitrary branch, with no membership hypothesis.
    `retired_lt_nextTime_oriented` is the form that replaces the obstruction — the retired index is
    strictly below the post-arm `nextTime`, so it can never be re-issued — and
    `maxTime_monotone_along_run` / `nextTime_monotone_along_run` lift it off the arm to every
    successor of every shape the engine reports, over the checked shape census
    `expandOnce_branch_shape_census` rather than over the prose claim that arm 3 is the engine's
    only non-additive step.

    *Read entry 15 with this correction.* Entry 15 says `reuse_driven_through_engine` shows the
    reuse "is a run and not a hand-assembled `Branch`". That is half right, and the half that is
    wrong matters here. `reuse_driven_through_engine` is driven from `reuseWitnessState`, which is
    assembled by a **direct** `Branch.identifyTime reuseWitnessBranch 2 0` call rather than by the
    engine's arm; what it decides is the *conditional* "if a run reaches a branch whose `maxTime`
    has fallen below an index it once carried, the engine re-mints that index." That conditional is
    as true now as it ever was, and it is deliberately left at its original decided value.
    `oriented_engine_does_not_produce_reuse` supplies the measurement it cannot make: at the same
    witness, the arm now hands back `maxTime = 2` and `nextTime = 3` where it used to hand back `1`
    and `2`, and one further engine step does not recover the retired value. The implication stands;
    its antecedent is unreachable.

    *Why not the bookkeeping-side designs, measured rather than asserted.* Two were costed before
    the arm was touched. A `horizon : TimeIndex` field on `TimeOrdering`, raised at every mint and
    never lowered: `TimeOrdering` is referenced in 29 files, with 35 `{ constraints := }` sites and
    47 `: TimeOrdering :=` bindings, and Lean's anonymous constructor does not fill default field
    values, so every literal breaks — including the closed terms the `decide`-based witnesses in
    this file evaluate. A run-level mint counter threaded through `applyRule` /
    `expandOnceUnblocked`: changes the signature of the engine's two central functions, which this
    file alone references hundreds of times, and pulls `Saturation.lean` into scope. Neither was
    prototyped, because the arm orientation decided the question at zero new state, zero signature
    changes and one edited call site.

    *The scope fact a future reader needs before reaching for a `nextTime` redefinition.*
    `Verified/Decidable.lean` carries **102** `Branch.nextTime` references —
    `lt_nextTime_of_mem_knownTimes`, `OrdWithin.bound` and `OrdWithin.nextTime_not_mem` among them —
    which consume `nextTime = maxTime + 1` *definitionally*. That file independently rediscovered
    this same obstruction from the `OrdWithin` side and recorded it in prose, with its own
    counterexample (`b = [f₀, f₇]`, `ord = ⟨[(5, 7)]⟩`). The repair therefore holds
    `Branch.nextTime`, `Branch.maxTime`, `Branch.identifyTime` and `TimeOrdering.identifyTime`
    **byte-unchanged** and goes to the call site instead; under that constraint `Decidable.lean`'s
    exposure collapses from 102 references to one docstring paragraph, and the nine `branch.nextTime`
    mint sites in `Tableau.lean` need no edit at all, since a monotone `maxTime` makes `nextTime`
    monotone for free at every one of them.

    *What survived, checked and not assumed.* `OrdTimesKnown` (entries 7 and 16) by
    `ordTimesKnown_identifyTime_oriented`; the run invariant by `runInvariant_identifyTime_oriented`;
    `UniverseClosedAt`'s clause 2 (entries 10-12) by `universeClosedAt_identify_at_trigger_oriented`
    and `timeMergeClosed_identifyTime_oriented`, discharging the clause **as it stands** — no
    both-times constraint was added, so entry 12's finding is untouched; the `.splitOrdered`
    measure's first component by `knownTimes_card_lt_at_arm3_oriented`. The one lemma that needed
    genuinely new content is `incomparableB_symm`, whose proof needed the backward half of the
    reachability duality (`orderDual_backward`) because `orderDual_holds` states it forwards only.
    `ordTimes_identifyTime_arm3_false` was re-checked and is still **true**: the orientation does not
    accidentally rescue the refuted `OrdTimesLeMaxTime`, and entry 7 stands as written.

    *And what this does **not** do — read this before treating entry 14 as reopened.* It does not
    supply the missing fourth measure component, and it does not make `MintPaysForTime` true. Entry
    14's refutation is about the predicate as literally stated and is untouched. Entry 17's
    refutation of the `selfGuardRules ×ˢ U` ledger stands as a statement **about the unoriented
    arm**: its σ-hit obligation was inherited from entry 15's reuse configuration, and that
    configuration no longer occurs on the engine path — so whether a measure-side component is now
    *provable* is a genuinely open follow-on question, not something this entry answers and not
    something entry 17 forecloses any more. Nobody should read "the reuse is closed" as "the measure
    is closed". They are different claims, and only the first is established here.

19. **Re-reading entry 17's refutation as closing the fourth-component question, and the four
    routes that closing suggests.** The last of these entries and, like entry 18, not a refutation:
    it records a verdict that has been **overturned**, and the four things a reader who has just
    read entry 17 will try next, three of which are closed and one of which is done.

    *What was withdrawn, and what was not.* `mintPaysForTimeAt_reuse_false` is untouched, still
    true, and still the correct statement about `MintPaysForTimeAt`: that predicate quantifies `σ`
    with no tie to the state it is read at, so a renaming no run produces refutes it. What entry 17
    could not say — because the arm had not been reoriented when it was written — is that its own
    refuting renaming, `gateSigma = rhoSF 2 0`, is the *unoriented* arm's output at the reuse
    witness's trigger `(0, 2)`. `identifyOrient` retires the smaller numeral, so the arm now
    produces `rhoSF 0 2` there, and `gateSigma_not_sigmaTimeStable` decides that the old renaming
    moves the gate's own trigger off its own time while no renaming the oriented arm produces does
    that to a formula the branch still carries. At the oriented gate the component's potential falls
    `3 → 1` where entry 17 measured `3 → 3` (`orientedGate_verdict_side_by_side`), and the design
    entry 17 refuted is the design that now carries the measure. Entry 18 anticipated exactly this
    and said so; this entry is its resolution.

    *Route 1, closed: `MintPaysForTimeAt → MintPaysForTimeStable`.* Not available, and the reason is
    not fixable by proof effort. The two predicates' third disjuncts differ: `MintPaysForTimeAt`'s is
    the bare `selfGuardPotential` drop, `MintPaysForTimeStable`'s pairs that drop with a
    **combined-budget** non-increase, `mintTimeBudget + selfGuardPotential`. The pairing is forced —
    see route 2 — so the implication does not hold and is not claimed.
    `mintPaysForTimeStable_of_mintPaysForTime` is proved directly from disjuncts 1 and 2 instead.

    *Route 2, closed: a bare `selfGuardPotential` drop as the third disjunct, at any weight.*
    `extensionAllowance` is `|U| + mintTimeBudget·|U| − |b|`, so it rises by a full `|U|` for every
    unit of mint budget a step spends, and a self-guarded mint spends one — it adds a time to
    `knownTimes` and leaves `mintPotential` alone, `untlNeg` and `snceNeg` not being in
    `freshLabelRules`. A disjunct that constrains only `selfGuardPotential` therefore leaves the
    measure's second component unbounded above at the very step it is meant to pay for, and no
    weight on the fourth component is a function of `|U|` in a way that fixes it while `Tmax` is
    free. The repair is the combined conjunct, and the weight that goes with it is
    `2·(Tmax² + 1) + |U|` — the `|U|` is exactly the allowance's per-budget-unit factor.

    *Route 3, closed: keeping `BudgetState` as the carried state.* Its budget clause is
    `mintTimeBudget ≤ Tmax`, and a self-guarded mint raises `mintTimeBudget` by one, so the state
    cannot survive the step however the measure is weighted — the failure is in the state predicate,
    not in the measure. `BudgetStateAt` carries `mintTimeBudget + selfGuardPotential ≤ Tmax`
    instead, which is non-increasing at that step because the mint spends exactly one unit of the
    fourth component to buy the one unit of mint budget it consumes. The cost is a figure:
    the mint-budget floor rises `8·|U| → 10·|U|` and `derivedTmax → derivedTmaxAt`, both recorded as
    enlargements (`derivedTmax_le_derivedTmaxAt`, `mintAwareFuel_le_mintAwareFuelAt`), and no
    caller's hypothesis list changes.

    *Route 4, open and named: the discharge at a nonempty universe.* This is the one thing left, and
    it is **not** the σ-hit obligation any more — that is discharged, by
    `sigma_time_hit_of_sigmaTimeStable`, from confinement plus a σ-time-stability hypothesis that
    `BudgetStateAt` carries and both step lemmas preserve (`sigmaTimeFixed_identifyOriented` at the
    arm, `sigmaTimeFixed_grow_of_fixesFrom` with `unorderedSuccessor_time_dichotomy` and
    `nextTime_monotone_along_run` at every additive step). What blocks it is the **density**
    coordinate, unchanged since entry 17 named it: `densityRule` mints a fresh time and lies outside
    both `freshLabelRules` and `selfGuardRules`, so at a `densityRule` step disjunct 1 fails and
    neither of the other two can move. `densityRule` is `denseRules`-gated, so a discharge
    restricted to frame classes outside `.Dense` / `.RTime` is not refuted; what it needs is a
    rule-by-rule census showing every remaining rule either mints no time, is witness-guarded, or is
    self-guarded. That census is not attempted here, and `gapPotential` — indexed by `U ×ˢ U`,
    `denseRules`-gated — remains implemented nowhere and assumed by nothing.
    `mintPaysForTimeStable_signedUniverse_empty` is how far the discharge goes today: the same
    boundary `mintPaysForTime_empty` records, at a concrete `signedUniverse C L`.

    *What is delivered, so the record is not only negative.* `MintPaysForTimeStable` with its
    direction lemma and no-leak confirmation; `selfGuardPotential`'s ceiling, growth and
    identification-arm preservation (Constraint (F), discharged with equality-or-better); the
    `untlNeg` and `snceNeg` discharge lemmas with their engine-level ordering shapes; the
    four-component measure `budgetPotentialAt` with both step lemmas and the C6 instantiation; and
    the two seed-level termini restated with an identical hypothesis list, one weaker residual and
    two larger figures. Entry 14's "what is missing" is now missing only at the density coordinate.

    *One line of this entry is withdrawn by entry 20.* The closing sentence above — that only the
    density coordinate is left — is wrong, and wrong in a way that was decidable when it was
    written. Read it as "missing at the density coordinate **and** at the formula coordinate";
    everything else in this entry stands.

20. **`MintPaysForTimeStable fc U Tmax` at any nonempty `U`, and the reading of entry 19's route 4
    that goes with it.** Refuted, not merely unproved, by
    `mintPaysForTimeStable_signedUniverse_false`, which is universally quantified in the frame class
    **and** in `Tmax` and is stated at a concrete nonempty `signedUniverse C L` — the universe shape
    the seed-level termini actually consume. There is no `densityRule` in the vehicle.

    *The cause, in one line.* `SigmaTimeStable` constrains σ's **times**; disjunct 2 needs it to
    constrain σ's **formulas**. `mintPotential_lt_of_mint` asks for `σ sf = g` on the nose, and
    `sigma_time_hit_of_sigmaTimeStable`'s own docstring already recorded that it does not supply
    that. Disjunct 2 is the only disjunct that pays for the six rules of
    `freshLabelRules ∩ freshTimeRules`, and disjunct 3 cannot stand in for it at a trigger whose
    reach is already non-empty — which is the ordinary case, not a contrived one.

    *The vehicle, and why it is not a technicality.* `flatSigma` sends every signed formula to a
    fixed positive atom at its own label. `witnessPresent_flatSigma` decides that its image is
    witness-free at all thirty-six rules, so `mintPotential_flatSigma` pins the potential at its own
    ceiling `8·|U|` at **every** state of **every** run — disjunct 2's strict inequality is
    unavailable everywhere, before any configuration is chosen. `selfGuardPotential_flatSigma` shows
    the same renaming leaves the fourth component measuring exactly what `id` measures, so the
    refutation cannot be dismissed as one that breaks the self-guard ledger too. The step is
    `untlPos` — witness-guarded, so squarely one of the six — at a time whose future is already
    non-empty; `knownTimes` goes `3 → 4`, `mintPotential` is `144` either side, and
    `selfGuardPotential` is `12` either side because the step's one new edge is `(1, 3)` and no
    formula of the universe sits at time `3`.

    *What this does **not** withdraw.* Nothing. `mintPaysForTimeStable_of_mintPaysForTime`, the
    no-leak confirmation, the four-component measure, `budgetPotentialAt` and the six restated
    termini all stand exactly as written; what changes is the reading of the residual they carry.
    Entry 19's routes 1, 2 and 3 are untouched — they are about the third disjunct's shape and the
    carried state's budget clause, neither of which appears here.

    *The repair, landed with its direction lemma.* State the hypothesis at the coordinate the
    obligation lives at: `SigmaFixed σ b` (σ fixes every branch formula) in place of
    `SigmaTimeStable σ b`, giving `MintPaysForTimeFixed`, with
    `mintPaysForTimeFixed_of_mintPaysForTimeStable` fixing the direction — the hypothesis is
    stronger, so the predicate is **weaker**, so every restatement is a strengthening. The repair is
    free at the only step that changes σ, and that is a fact about `rhoSF` rather than a
    coincidence: `rhoSF_eq_of_ne_src` strengthens `rhoSF_time_eq_of_ne_src`'s conclusion from "same
    time" to "same formula" by the same one line, so `sigmaFixed_identifyOriented` and
    `sigmaFormulaFixed_identifyOriented` are their time-level originals' proofs verbatim. It costs
    **no figure**: `budgetPotentialAt`, `mintPathBoundAt`, `mintAwareFuelAt` and `derivedTmaxAt` are
    reused byte for byte by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_fixed` and
    its five predecessors. `flatSigma_not_sigmaFixed` decides that the vehicle above does not reach
    the repaired predicate.

    *What is left, stated so it is not mistaken for what entry 19 said was left.* One thing now,
    where there were two. **(a)** The engine-level assembly is **landed**, in section D5. The
    per-rule payments all existed — `mintPotential_lt_of_pick_linear_sigmaFixed` and
    `..._branching_sigmaFixed` for the six witness-guarded minting rules,
    `selfGuardPotential_lt_of_untlNeg` / `..._snceNeg` for the two self-guarded ones,
    `applyRule_emitted_time_dichotomy` plus `expandOnceUnblocked_ord_mono` for the twenty-seven that
    mint no time — and what was missing was threading the pick's rule through
    `expandOnceUnblocked`'s three stages so that the case split is available at the successor.
    `pick_stage_source_rule` is that threading, `pickBranches_mintPays` is the four-bucket case
    split it enables, and `mintPaysForTimeFixed_of_not_dense` is the discharge, at an arbitrary
    universe under the single hypothesis `¬ (FrameClass.Dense ≤ fc)`;
    `mintPaysForTimeFixed_signedUniverse_of_not_dense` is its `signedUniverse C L` form, for **every**
    stock `C` including one carrying `untl` and `snce` — the case this entry calls the hard one, and
    the case section D3's syntactic fragment excludes. **(b)** The density coordinate, exactly as
    entry 19 describes it and untouched by any of this, is what remains. The frame-class hypothesis
    excludes `densityRule` rather than paying for it; a discharge at `.Dense` and `.RTime` still
    needs `gapPotential`, which remains implemented nowhere and assumed by nothing.

    *And the scope of (a), stated so it is not overread.* Landing the assembly makes **no** terminus
    in this file non-vacuous, and no artifact should claim otherwise. The nine `hlab` carriers stay
    vacuous at every nonempty `L` by `unorderedSuccessorLabelClosed_nonempty_false`, whatever happens
    to `hmint`; and every `hlab`-free `hmint`-carrying terminus stays conditioned on
    `UniverseClosedAt` plus `DifficultyBounded` or `StepLengthBounded` plus `PostBlockingSettles` or
    `PostBlockingSettlesRun`, three of which entries 9, 11 and 22 refute. What (a) delivers is that
    one named residual of the four is now a theorem at a nonempty universe off `.Dense`, and that
    section D3's discharge is generalized off its syntactic fragment. The count of *satisfiable*
    residual conditions blocking any terminus is unchanged. Omitting this sentence would reproduce
    exactly the failure mode entry 21 documents.

    *And what neither (a) nor (b) is needed for.* Both are obligations on a **time mint**, so both
    are vacuous on a universe where no rule can mint. Section D3 discharges `MintPaysForTime`
    itself — not `MintPaysForTimeFixed`, and not a further repair — at every universe of
    `untl`/`snce`-free formulas, at **every** frame class including `.Dense` and `.RTime`:
    all nine members of `freshTimeRules` are gated by `isApplicable` on a shape containing an
    `untl` or `snce` node, `densityRule` among them through `Formula.allFuture`'s expansion, and
    the engine's other two stages run only `serialityRule` and `timeLinearity`. So the reading to
    avoid is that (a) and (b) gate *every* discharge; they gate the discharge at a universe carrying
    a temporal operator, which is the case `mintPaysForTime_untlNeg_false` shows is the hard one.

21. **Discharging `UnorderedSuccessorLabelClosed` now that the time coordinate has landed.** The
    accounting is complete and the residual still does not fall, and this entry exists because the
    file itself once said otherwise: `UnorderedSuccessorLabelClosed`'s docstring recorded the time
    coordinate as *the missing piece*, which invites the reading that supplying it would finish the
    job. It does not, and the corrected paragraph on that docstring says so.

    *What the time analogue does buy.* The **reduction**, in full. Section C11's
    `unorderedSuccessor_label_mem_of_headroom` proves clause 1's label dimension outright — no
    hypothesis about the successor, no residual, both coordinates accounted for — from
    `unorderedSuccessor_world_dichotomy`, `unorderedSuccessor_time_dichotomy` and the branch-side
    rectangle `FreshLabelHeadroom`. `unorderedSuccessorLabelClosedOrd_of_headroom` is that reduction
    at the residual's own shape, and
    `unorderedSuccessor_confined_signedUniverse_of_freshLabelHeadroom` is clause 1 at
    `signedUniverse C L` with nothing residual left standing.

    *Why the residual survives it.* Because the reduced antecedent is refutable:
    `freshLabelHeadroom_not_universal` proves that for **no** nonempty finite `L` does every
    `L`-confined branch carry the rectangle, by the same `maxWorld` argument as entry 11 —
    `freshWorldHeadroom_of_freshLabelHeadroom` is the one line that transports it. The obstruction is
    the world coordinate's refutation, and it was never the missing time lemma. A reader who reaches
    for the time analogue expecting the residual to close has already been here.

    *And the residual is not merely un-discharged — it is FALSE, at every nonempty finite `L`.* This
    is stronger than the paragraph above, which refutes only the *reduced antecedent* and so leaves
    open the reading that a route not through `FreshLabelHeadroom` might still succeed at some
    carefully chosen `L`. No such `L` exists. `unorderedSuccessorLabelClosedOrd_nonempty_false`
    refutes the weaker `Ord` form at every nonempty finite `L` at every frame class, and
    `unorderedSuccessorLabelClosed_nonempty_false` is the one-line consequence for the original;
    `unorderedSuccessorLabelClosed_empty` supplies the other end. **The satisfiability set of
    `UnorderedSuccessorLabelClosed fc L` is exactly `{∅}`** — and `signedUniverse C ∅ = ∅`, so the
    only label set at which the hypothesis is available is the one at which the universe is empty.

    The generalization from `unorderedSuccessorLabelClosed_not_universal`'s single witness is
    mechanical, and the reason is structural rather than lucky: the engine's shape gates match a
    signed formula's **sign and formula constructor**, never its label, so `F(□p)` fires `.boxNeg`
    wherever it is put and the emission always lands at `Branch.nextWorld`. Running the witness at a
    label of maximal world in `L` therefore escapes `L` by maximality. The label-generalized witness
    family (`freshWorldWitnessAt`, `freshWorldBranchAt`, `freshWorldEmittedAt`) sits in section C11
    beside the original, which is retained.

    *The consequence for the nine theorems that assume it.* Every one of these carries
    `hlab : UnorderedSuccessorLabelClosed fc L` as a live hypothesis, and each is therefore a
    **vacuously true conditional at every `L` for which its universe is nonempty**:

    - `unorderedSuccessor_confined_signedUniverse_of_headroom`
    - `universeClosedAt_signedUniverse_of_headroom`
    - `buildTableauAt_isSome_of_lengthBudget_signedUniverse`
    - `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse`
    - `buildTableauAt_isSome_of_lengthBudget_signedUniverse_selfGuarded`
    - `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_selfGuarded`
    - `buildTableauAt_isSome_of_lengthBudget_signedUniverse_fixed`
    - `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_fixed`
    - `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`

    That last one is worth naming twice, because its section heading promises a discharge "at a
    **nonempty** universe" and its docstring once read as though the promise were kept: the `hmint`
    half is kept, the `hlab` half is not, and the theorem is vacuous at exactly the universes the
    section is about. This is the failure mode `DifficultyBounded` fell into and that
    `timeMergeClosed_product` exists to rule out elsewhere. Discharging `hmint` at a nonempty
    universe — a separate line of work — does **not** unlock any of the nine; `hlab` has to go, and
    going means being *replaced* by a condition that is satisfiable, not proved.

    *What a replacement may not be.* Any candidate replacement must be exhibited as satisfiable at a
    nonempty `L` before it is stated as a discharge, and no `L`-side condition can do it:
    `freshWorldHeadroom_not_universal` proves that no condition on a finite `L` absorbs a fresh
    world. A replacement therefore has to bite on the *stock*, before the world-minting rules can
    fire at all.

    *The rectangle is not an over-approximation that a sharper proof would shrink.* A label is a
    **pair** and the two dichotomies are per-coordinate, so four quadrants have to be covered.
    Confinement of `b` covers none of them: `∀ x ∈ b, x.label ∈ L` constrains the pairs `b` carries,
    not their cross product, so `⟨w, t⟩` for a `w` and a `t` that `b` carries on *different* formulas
    is not thereby in `L`. `FreshWorldHeadroom` covers one quadrant, which is why it alone was never
    going to be enough even with both dichotomies in hand. The same rectangle shape appears on the
    clause-2 side as `timeMergeClosed_iff_product`, arrived at from the opposite direction.

    *What is not withdrawn.* Nothing. `UnorderedSuccessorLabelClosed`,
    `unorderedSuccessor_confined_signedUniverse_of_headroom` and the terminus chain that consumes
    them stand exactly as written; `UnorderedSuccessorLabelClosedOrd` is an additional, weaker
    predicate stated beside the original, with
    `unorderedSuccessorLabelClosedOrd_of_unorderedSuccessorLabelClosed` fixing the direction and
    `unorderedSuccessorLabelClosedOrd_not_universal` confirming that adding `OrdTimesKnown` does not
    weaken it into vacuity.

    *The `L`-side replacement route, how far it reaches, and where it stops.* Section D4 supplies the
    replacement this entry calls for, and it reaches further than C11 did without reaching a
    terminus. The world coordinate — the one `freshWorldHeadroom_not_universal` proves no condition
    on a finite `L` can ever close — is closed outright on a `boxFree` branch
    (`unorderedSuccessor_worldFinset_subset`), and joined with D3's time coordinate and the
    `TimeMergeClosed` rectangle it gives
    `unorderedSuccessor_confined_signedUniverse_of_propositional`: clause 1 at `signedUniverse C L`
    from hypotheses that are **all satisfiable**. That is strictly better than C11's position, where
    the reduced antecedent was itself refutable.

    *The shape mismatch this entry once recorded as the stopping point is gone.* An earlier version
    of this paragraph said the section stopped one step short of a restated terminus because every
    route through the time coordinate carried `OrdTimesKnown b ord` — which
    `applyRule_emitted_time_mem_ordTimesKnown_needed` proves is not removable from
    `applyRule_emitted_time_mem` — while `UniverseClosedAt`'s clause 1 quantifies `ord` freely and
    offers no such hypothesis. It named two routes past the mismatch and recorded the first of them,
    removing `OrdTimesKnown` on this fragment, as **unattempted**. It has since been attempted and it
    works: `applyRule_emitted_time_mem_of_untlSnceFree` trades the run invariant for branch-level
    `untl`/`snce`-freeness (entry 16 records why, arm by arm), and
    `universeClosedAt_signedUniverse_of_propositional` is `UniverseClosedAt fc (signedUniverse C L)`
    with **no** `UnorderedSuccessorLabelClosed`, **no** `OrdTimesKnown` and **no** frame-class
    hypothesis, every one of whose hypotheses is exhibitable. The second route — an `Ord`-flavoured
    `UniverseClosedAt` and `DifficultyBounded` cascading through some twenty restatements — remains
    unattempted and is no longer needed for this purpose.

    *What has not changed.* None of the nine carriers below has been restated, so every one still
    takes `hlab` and **all nine remain vacuous at every nonempty `L`**. This entry's consequence
    paragraph stands as written.

    *And the replacement composite is vacuous too, for an unrelated reason — so re-pointing the
    carriers at it would buy nothing.* `tableauClosed_untlSnceFree_false` (section D4) decides that
    `TableauClosed C` and `∀ φ ∈ C, untlSnceFree φ = true` cannot both hold: `TableauClosed`'s
    `serialFuture` field demands `Formula.top.someFuture ∈ C`, because `serialityRule` emits `T(F⊤)`
    at every label from no trigger at all, and `Formula.someFuture ⊤` is `⊤ untl ⊤`. So
    `universeClosedAt_signedUniverse_of_propositional`,
    `unorderedSuccessor_confined_signedUniverse_of_propositional` and its `ordFree` sibling are all
    vacuously true, and `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree` —
    already in the list of nine — is vacuous twice over, through `hlab` and through this.

    This does **not** retract anything above and it does not touch the machinery that carries only
    the shape condition: `applyRule_emitted_time_mem_of_untlSnceFree`,
    `unorderedSuccessor_knownTimes_subset_of_untlSnceFree`,
    `unorderedSuccessor_label_mem_of_propositional_ordFree` and section D3's
    `mintPaysForTime_of_untlSnceFree` chain take no `TableauClosed` and stand non-vacuously. The
    obstruction has moved: it is no longer `OrdTimesKnown`, and it is no longer on the `L` side at
    all. It is that no stock is simultaneously closed under the engine's unconditional outputs and
    free of `untl`. A reader who wants a non-vacuous propositional terminus needs a stock-closure
    predicate weaker than `TableauClosed` — one not demanding `serialityRule`'s two outputs — with
    `unorderedSuccessor_formula_mem` re-derived at it, or a shape condition weaker than
    `untlSnceFree` that admits `⊤ untl ⊤` while still excluding the five arms entry 16 names.
    Neither is attempted and neither is refuted.

    *And the narrowing is forced.* D4's replacement reaches only the purely propositional fragment,
    because `boxFree` and `untlSnceFree` together exclude `□`, `untl` and `snce`. That is not a proof
    weakness: `freshWorldHeadroom_not_universal` refutes every `L`-side alternative, so the only
    available handle is the stock, and both world-minting rules are gated on a `.box` node. A reader
    who wants the replacement at the modal fragment is asking for something the world coordinate's
    refutation rules out.

22. **`PostBlockingSettles fc` as literally stated.** Refuted, not merely unproved, by two witnesses,
    both universally quantified in the frame class: `postBlockingSettles_fuel_zero_false` at the
    `fuel = 0` arm, and `postBlockingSettles_fuel_gap_false` at a nonzero one.

    *The cause in one line.* `expandOnceNoFresh` **skips** any candidate whose applicable rule mints
    a fresh label or lengthens the ordering constraints — its `pick` returns `none` and the search
    continues past it — while `findUnexpandedUnblockedWith` tests only `!isExpanded`, which is
    `findApplicableRule ≠ none` with no reference to minting at all. So a formula at an unblocked
    time whose only rule mints is invisible to the first test and visible to the second, and the two
    tests disagree at **every** fuel.

    ***Fuel does not close it***, which answers the open question the residual's own docstring used
    to pose. `postBlockingSettles_gap_at_every_fuel` exhibits both halves at once, universally
    quantified in `fuel`: `saturateBlocked freshWorldBranch fuel TimeOrdering.empty fc` returns the
    branch unchanged while the saturation test reports outstanding work on it. The fuel-universal
    step is `saturateBlocked_eq_self_of_noFresh_saturated`, two cases and no induction — from
    `fuel + 1` the pass reaches its `(.saturated, _)` arm before any guard. The witness is the landed
    `freshWorldBranch = [F(□p)@⟨0,0⟩]` reused from entry 11's refutation; `.boxNeg` mints a fresh
    **world**, so it trips `expandOnceNoFresh`'s *first* rejection test. Entry 13 records why there
    are two rejection tests and why a time-minting witness would refute the predicate the same way
    through the second.

    *The `fuel = 0` arm is not a technicality, and the reader who wants to "just require `fuel > 0`"
    should read this sentence.* At `fuel = 0` the pass hands its input back untested, so the
    predicate's hypothesis is satisfied at **every** branch whatsoever and the predicate then asserts
    that every branch is blocking-aware saturated. That arm is reachable at every top-level fuel
    figure, because the pass recurses with the fuel decremented.

    *What the settlement question actually reduces to*, proved rather than asserted:
    `postBlockingSettlesAt_settlement` shows that `expandOnceNoFresh` reporting `.saturated`, plus no
    label-minting work at an unblocked time (`NoUnblockedFreshWork`), forces the conclusion. The
    inversion it runs on is `expandOnceNoFresh_saturated_imp`, which needs
    `findApplicableRule_result_ne_notApplicable` to kill `expandOnceNoFresh`'s *second* route to
    `.saturated` — its `.notApplicable` arm, which returns the picked ordering rather than the
    incoming one. Entry 23 says why that is not a repair.

23. **`PostBlockingSettlesAt`, and every repair of entry 22 that relocates conditions onto the
    post-blocking pass's output branch.** Not open: closed, and closed twice over.

    *The design, so a reader does not re-attempt it by fixing the wrong part.* Add the two conditions
    the settlement argument actually uses as antecedents on the output branch —
    `LabelFreeSaturatedExit` (the pass ran to label-free saturation rather than being truncated) and
    `NoUnblockedFreshWork` (no label-minting work at an unblocked time) — leaving the conclusion
    verbatim. `postBlockingSettlesAt_of_postBlockingSettles` fixes the direction in the register's
    own idiom: the hypothesis list is longer, so the predicate is weaker, so every restatement would
    be a strengthening. All of it is landed, and none of it is offered as a repair.

    *First closure: the consuming sites cannot supply the antecedents.* Both
    `armSettlement_of_postBlockingSettles` and `buildTableauAt_isSome_of_settles` reach the residual
    holding exactly one fact about the output pair, the exit equation.
    `labelFreeSaturatedExit_not_of_saturateBlocked_inr` decides that this equation does not carry
    `LabelFreeSaturatedExit`: at `fuel = 0`, `saturateBlocked (multBranch 1) 0 ord fc` returns its
    input while `expandOnceNoFresh` fires `.impNeg` on it. The one bridge shape that would typecheck
    carries the extra hypothesis `PostBlockingExitSettled fc`, and `postBlockingExitSettled_false`
    refutes that at every frame class — it implies entry 22's refuted predicate through
    `postBlockingSettles_of_postBlockingExitSettled`. So the only available bridge is a weakening
    dressed as a repair. No terminus is restated against it; that is deliberate, and it is the same
    judgement entry 7 records having once got wrong.

    *Second closure, and the sharper one: the second antecedent is the conclusion in disguise.*
    `noUnblockedFreshWork_of_settled` proves, unconditionally, that a branch whose settlement test
    already closes satisfies `NoUnblockedFreshWork` — its antecedent is then unsatisfiable. Together
    with the settlement lemma this gives
    `noUnblockedFreshWork_iff_of_labelFreeSaturatedExit`: *given* `LabelFreeSaturatedExit`, the two
    are **equivalent**. So `PostBlockingSettlesAt fc` is a theorem — `postBlockingSettlesAt_holds`,
    outright, at every frame class — for a reason that is not progress, and a reader who reads
    "the repaired predicate is proved" as "the residual is discharged" has the situation backwards.

    *What the design does buy, so the record is not only negative.* The residual's content is now
    located exactly: it is a **fuel-adequacy** fact about the pass plus a **label-minting** fact about
    the branch it reaches, and neither is a settlement question. `LabelFreeUniverseAt` with
    `noUnblockedFreshWork_of_labelFreeUniverseAt` is the one direction the equivalence does not
    collapse — a branch-independent sufficient condition, checkable from the universe and the
    ordering without looking at the branch. It has to be stated at a fixed ordering rather than at a
    universe alone, and that is forced rather than conservative: `orderTrichotomy` is in
    `allRulesForFC`, is applicable to *every* signed formula, and lengthens the ordering exactly when
    the ordering carries an incomparable pair. And the discharge is not at a vacuous boundary —
    `saturateBlocked_multBranch_one_run` decides that the pass itself produces the three-formula
    branch `multSettledBranch` at every frame class and every positive fuel, and
    `postBlockingSettlesAt_labelFree` is the settlement delivered there.

    *The route that was named here as unattempted, and is now landed.* Restrict entry 22's
    quantification from "every `(ob, oOrd, fuel)`" to the pair the terminus's own run produces — a
    branch some `expandBranchWithFuel` call returned open, at that call's own fuel.
    `PostBlockingSettlesRun` is that predicate, and it is the settled repair of entry 22.
    `freshWorldBranch` does not refute it, because no engine run hands that branch to the pass; the
    `fuel = 0` degeneracy that refutes the unrestricted form cannot reach it either, since
    `expandBranchWithFuel_eq_none_zero` makes its antecedent unsatisfiable there rather than
    universally satisfied (`postBlockingSettlesRun_zero`).

    *Why this is a repair where the output-branch design was not, in one line.* The output-branch
    design added conditions the consuming site had to **discharge**; the narrowed design removes
    quantifiers the consuming site never needed, and hands the site back an equation it already
    holds. `buildTableauAt_isSome_of_settlesRun` is the bridge, and it compiles for exactly that
    reason: `buildTableauAt`'s own `expandBranchWithFuel` call is in scope at the point its
    post-blocking arm is decided.

    *And what it costs.* One hypothesis becomes explicit. `PostBlockingSettles` supplied **two**
    things to the landed termini — `ArmSettlement fc`, through
    `armSettlement_of_postBlockingSettles`, for `expandBranchWithFuel`'s split folds, and the entry
    point's own arm. The narrowed residual covered only the second, so the restated termini named
    `ArmSettlement` instead of manufacturing it from a refuted predicate. (Those termini have since
    been retired as vacuous — entry 25's verdict reaches the very figures they were stated at — and
    section C12's retirement record carries the disposition. What is recorded here is the cost
    accounting as it stood: the exchange was the right one and was still not enough.) That is not a
    new cost:
    `ArmSettlement` is a landed residual of this file, is *already* quantified the honest way — its
    own docstring is where the "restricted to arms an engine run actually hands the fold" idiom
    comes from — and was always what the fold consumed.

    *Relocating to the pass's input branch is still closed and should still not be tried*:
    `LabelFreeSaturatedExit` is false at `ob` by construction, since `buildTableauAt` runs the pass
    precisely when its guard found outstanding work there.

24. **Reading `PostBlockingSettlesRun` as discharged.** It is not, and this entry exists so the
    narrowing is not mistaken for a proof. It is a **hypothesis** everywhere it appears, exactly as
    `ArmSettlement` is. It is now **decided, and decided in the negative**: entry 25 records the
    verdict, and `postBlockingSettlesRun_terminusFuel_false` is the theorem — the predicate is false
    at the terminus's own fuel figure, at `.Base`, for every value of every parameter. The clause
    that used to stand here, that nothing in this file decides it in either direction, was true when
    it was written and is false now; it is corrected rather than deleted so the sequence of findings
    stays legible.

    *The consequence for the termini, and the corrected count.* **Nine** termini were stated against
    the narrowed residual, not six. The six-count was an undercount twice over: it read one terminus
    plus its five named siblings off a single sentence three sections up, and it silently assumed all
    of them stood at `mintAwareFuelAt …` when four stood at the un-`At` `mintAwareFuel …`. All nine have been
    retired as vacuous, by the same discipline this entry states for itself — the record is corrected
    and kept rather than deleted. Section C12's retirement record names each of the nine, gives the
    refutation that reaches it, and carries the frame-class split. The removal was cost-free: a
    whole-environment reverse-dependency scan found zero dependents of the nine outside the nine
    themselves, and `FormalSystem.Metalogic.Decidability.decide` reaches no constant of this file at
    all.

    *What is established about it.* It is not refuted by either witness that kills the unrestricted
    form (entry 22), and it is not vacuous: `postBlockingRunProbe`'s `#guard_msgs`-checked
    measurements run the terminus's own two calls in sequence — `expandBranchWithFuel` from a seed,
    then `saturateBlocked` on its open exit at the same fuel — and report, at every frame class and
    on propositional, temporal and world-minting seeds, that the run reaches an open exit, that the
    pass strictly extends it, and that the settlement test closes on the result. The pass doing real
    work rather than handing its input back is separately *proved*, at every frame class and every
    positive fuel, by `saturateBlocked_multBranch_one_run` with
    `multBranch_one_length_lt_multSettledBranch`.

    *What is not established, stated so the two are not confused.* The `#guard_msgs` probes are
    checked **measurements**, not kernel proofs: `expandBranchWithFuel` is compiled by well-founded
    recursion and does not reduce definitionally, so proving its half of the antecedent would mean
    transcribing an eleven-formula open exit and unfolding the equation lemma once per engine step.
    They have the same standing as `branchingWitness`'s non-vacuity probe, and are
    recorded with the same honesty about what they are. Across fourteen formula shapes, four frame
    classes and three fuel figures no probed run made the settlement test fail — evidence, not a
    proof. The same sweep found `buildTableauAt`'s own guard never firing on those shapes: the
    threaded tracker and the recomputed `armTracker` agreed everywhere, so the entry point did not
    consult its post-blocking arm on any of them. That is a fact about the probe's reach, not about
    the residual.

25. **Re-attempting `PostBlockingSettlesRun` in the positive direction, at any positive figure.**
    The verdict is in and it is **FALSE**, and this entry exists so entry 24's narrowing is not
    mistaken for a *safe* one either. `postBlockingSettlesRun_terminusFuel_false` refutes the
    predicate at `.Base` at the terminus's own figure `mintAwareFuelAt U.card Tmax mintBudget D β`,
    for **all** parameter values: that figure is always at least one (`one_le_mintAwareFuelAt`, off
    `mintPathBound`'s trailing `+ 1` through `fuelFigure_pos`), and `postBlockingSettlesRun_false_succ`
    refutes it at every positive fuel. **Both** fuel figures are covered, not only the `At` one:
    `one_le_mintAwareFuel` and `postBlockingSettlesRun_mintAwareFuel_false` land the identical verdict
    at the un-`At` `mintAwareFuel …`, by the identical route. That is not tidiness — it is the figure
    four of the nine retired termini were actually stated at, so without it the vacuity claim reached
    only half of them. `postBlockingSettlesRun_false_dense` and
    `postBlockingSettlesRun_false_rtime` land the same verdict at two further classes. All of it is a
    kernel proof — no `sorry`, and no axiom beyond `propext`, `Classical.choice`, `Quot.sound`.

    *The mechanism: entry 24's narrowing was **incomplete**.* It restricted `(ob, oOrd, fuel)` to
    run-produced pairs and left `expandBranchWithFuel`'s `EventualityTracker` argument universally
    quantified. That argument is the **only** input the engine's blocked-set computation and the
    settlement test's recomputed `armTracker` do not share, and it is not inert. Blocking is monotone
    in pending entries at the ancestor — `isTemporallyBlockedSaturated` conjoins
    `allEventualitiesFulfilledOrDuplicated`, which asks for a pending entry with the same event
    formula and the same `isUntil` flag at the ancestor time — so a doctored tracker yields a
    **strictly larger** blocked set than `armTracker`, and the engine skips a time the settlement
    test still inspects. `pbrDoctoredTracker` parks one `q`-eventuality at an unused world, where the
    world-sensitive `fulfillEventualities` never discharges it while the world-blind subset half of
    blocking is still satisfied. `pbrWitnessBranch` is the engine's own open exit from
    `seedBranch (p → q)`, augmented, carrying `T(p untl q)@⟨9,4⟩` — a formula `untlPos` mints a time
    for, so `expandOnceNoFresh` skips it and `saturateBlocked_eq_self_of_noFresh_saturated` hands the
    branch back at **every** fuel.

    *Why the refutation is cheap where entry 24 records the positive direction as prohibitive.* The
    doctored run returns the witness at its **first** step, so `rw [expandBranchWithFuel]` unfolds the
    equation lemma exactly once and the `.saturated` arm closes the goal; no engine step is
    transcribed. That is what converts what entry 24 calls a measurement into a theorem, and it
    generalises: a kernel *refutation* about a well-founded-recursive engine function is cheap exactly
    when the witness is returned before the first recursive call, even where a kernel *proof* about
    the same function is not.

    *What this does NOT say.* It is not a claim that any engine run ever threads such a tracker —
    `buildTableauAt` does not. The predicate **as written** quantifies over the tracker, so the
    predicate as written is false. This is the same form of statement entry 22 makes about the
    `fuel = 0` degeneracy, and it is not to be softened to a caveat: the finding is that the narrowing
    was incomplete, and the completion is named next.

    *The named next narrowing, and why it is NOT claimed true.* `PostBlockingSettlesSeedRun` fixes the
    four arguments `buildTableauAt` always supplies at their defaults — `ord := TimeOrdering.empty`,
    `tr := EventualityTracker.empty`, `ap := {}`, `bu := 0` — and leaves the rest quantified.
    `buildTableauAt_isSome_of_settlesSeedRun` shows the bridge survives verbatim, and
    `buildTableauAt_isSome_of_budget_fixed_seedRun` is the representative terminus restated against
    it. That narrowing kills *this* witness (checked: at the empty tracker the same branch's
    `expandOnceUnblocked` reports `.extended`, not `.saturated`, and a genuine run from it reaches an
    exit whose settlement test passes), and it is **not** thereby true. A second, structurally
    independent refutation route against it is **unprobed**: `saturateBlocked` may *extend* `ob`, and
    `expandOnceNoFresh` ignores blocking entirely, so it can do label-free work at a *blocked* time,
    and the formulas it adds can break `isSubsetBlocked` (or `timeSaturated` at the ancestor) and
    thereby **unblock** a time carrying label-minting work that `expandOnceNoFresh` itself skips; the
    settlement test on `satBr` would then report it, with no doctored tracker anywhere. Any future
    claim that `PostBlockingSettlesSeedRun` holds must gate on that route first. The cheapest probe:
    for engine exits `ob`, does `blockedTimes satBr satOrd fc (armTracker satBr)` ever lose a time
    that `blockedTimes ob oOrd fc (armTracker ob)` held?

    *Do not re-attempt.* The unrestricted `PostBlockingSettles` (entry 22, refuted); the output-branch
    bridge `PostBlockingExitSettled` (entry 23, refuted); an `ArmSettlement` discharge of the entry
    point's post-blocking arm, which is strictly too weak because `resolveOpenArm` tests
    `findClosure satBr` before its saturation test and `buildTableauAt` does not; and
    `PostBlockingSettlesRun` itself in the positive direction, at any positive figure. What remains
    open is a fact about the **witness**, not about the verdict: at `.ZTime` the witness leaves
    `priorUZ` and `priorSZ` applicable at `⟨0,0⟩`, `⟨0,1⟩`, `⟨1,0⟩` and `⟨1,1⟩`, so its first
    obligation fails there. Completing that class is mechanical and buys only tidiness — refuting at
    one frame class already refutes the predicate.

    *That `.ZTime` caveat does not apply uniformly across the retired termini, and must not be read
    as though it did.* Eight of the nine carried `PostBlockingSettlesRun` and inherit exactly the gap
    just named: established vacuous at `.Base`, `.Dense` and `.RTime`, undecided here at `.ZTime` —
    where undecided still means undelivered, and where they had no dependent either. The ninth,
    `buildTableauAt_isSome_of_budget_of_run`, is not one of them. It carried the **unrestricted**
    `PostBlockingSettles`, which `postBlockingSettles_fuel_zero_false` refutes at every frame class,
    so it was unconditionally vacuous at **all four**. It sat inside what read as a uniform block and
    was not uniform with it.
    -/

