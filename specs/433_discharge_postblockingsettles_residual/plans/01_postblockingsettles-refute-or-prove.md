# Implementation Plan: Discharge the `PostBlockingSettles` residual

- **Task**: 433 - Discharge `PostBlockingSettles fc`, one of the four residual hypotheses on the totality terminus `buildTableauAt_isSome_of_budget`
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours
- **Dependencies**: None blocking. Consumes (does not re-author) what tasks 432, 434 and 436 landed in `MintBound.lean`.
- **Research Inputs**: `specs/433_discharge_postblockingsettles_residual/reports/01_spawn-inherited-research.md` (inherited stub); `specs/428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md` (source blocker analysis)
- **Artifacts**: plans/01_postblockingsettles-refute-or-prove.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`PostBlockingSettles fc` (`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:5168`)
says that whenever the post-blocking pass returns an open branch, that branch passes the
blocking-aware saturation test:

```
∀ ob oOrd fuel satBr satOrd,
  saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd)) →
  findUnexpandedUnblockedWith satBr satOrd fc
    (blockedTimes satBr satOrd fc (armTracker satBr)) = none
```

It is the single settlement residual on the terminus: it closes `buildTableauAt`'s
post-blocking arm directly and `resolveOpenArm`'s `none` arm through
`armSettlement_of_postBlockingSettles` (`MintBound.lean:5178`). Its own docstring names the
open question precisely — "whether the gap can be closed by fuel alone" — and this task answers
that question in one direction or the other, machine-checked, and then either proves the
predicate or lands the minimal repair with its direction lemma and a concrete non-vacuous
discharge.

The work is **additive only** in `MintBound.lean`. `Saturation.lean` and `Tableau.lean` are
md5-pinned FROZEN and are not edited; every fact this plan needs about `saturateBlocked`,
`expandOnceNoFresh`, `blockedTimes`, `findUnexpandedUnblockedWith`, `isExpanded`,
`findApplicableRule` and `armTracker` is obtainable from `MintBound.lean` because all of them
are **public `def`s** — `private` blocks name resolution, not unfolding, and no lemma below
names a private symbol (this is register entry 9's observation used in the direction where it
helps).

### Research Integration

The inherited research is a stub; the substantive input is the source blocker analysis plus the
in-file record. Three source-level facts drive the phase structure and were read directly out of
the frozen files during planning:

1. **`saturateBlocked` at `fuel = 0` returns its input unchanged** (`Saturation.lean:435`,
   `| 0 => some (.inr (b, timeOrd))`). So the hypothesis of `PostBlockingSettles` is satisfiable
   at *every* branch with `fuel = 0`, and the predicate as literally stated therefore asserts
   that **every** branch whatsoever is blocking-aware saturated. This is the trivial gap and
   Phase 1's gate.
2. **`expandOnceNoFresh` *skips* label-introducing candidates rather than reporting them**
   (`Tableau.lean:2335`): its `pick` returns `none` for any `sf` whose applicable rule satisfies
   `ruleMintsFreshLabel` or lengthens `newOrd.constraints`, and the search continues. It reports
   `.saturated` when no **label-free** rule applies **anywhere on the branch**, with no reference
   to the blocked set at all. `saturateBlocked` stops there (`Saturation.lean:447`).
3. **`findUnexpandedUnblockedWith` tests something strictly different**
   (`Tableau.lean:2189`): `b.find? fun sf => !blocked.contains sf.label.time && !isExpanded sf b ord fc`,
   with `isExpanded sf b ord fc = (findApplicableRule sf b ord fc).isNone` (`Tableau.lean:2023`).
   So a formula sitting at an **unblocked** time whose only applicable rule mints a fresh label is
   invisible to (2) and visible to (3), **at every fuel figure**.

Facts (2) and (3) together are the plan's central hypothesis: the fuel-vs-condition gap is a
*label-minting* gap, not a fuel gap, and raising fuel therefore cannot close it. Phase 2 decides
that hypothesis rather than assuming it.

### Prior Plan Reference

No prior plan for this task. The three sibling residual tasks worked in the same batch supply
calibration rather than content: gate-first phase structure with binary verdicts (432, 436),
mandatory machine-checked direction lemmas before any predicate is called a "repair" (register
entry 7's lesson, re-paid by 434 and 436), and one-agent-run phase sizing.

### Batch Context: What Has Landed, and What This Task May Assume

| Task | Status | Landed and consumable by this task |
|------|--------|-------------------------------------|
| 436 | COMPLETED | `SigmaTimeStable`, `MintPaysForTimeStable`, the oriented-arm re-gate, the four-component measure, two seed-level termini restated |
| 434 | PARTIAL (8/9) | `MintPaysForTimeFixed` (:10461) + direction lemma, `applyRule_emitted_time_dichotomy` (:7048), `expandOnceUnblocked_ord_mono` (:1945) |
| 432 | COMPLETED | `UniverseClosed` clauses 1-2 at `signedUniverse C L`, `applyRule_emitted_world_dichotomy`, `FreshWorldHeadroom`, `UnorderedSuccessorLabelClosed` |

**Cross-task dependency finding, stated explicitly rather than assumed away.**
`PostBlockingSettles` does **not** need the engine-level assembly that task 434 left open.
That open item (threading the pick's rule through `expandOnceUnblocked`'s three stages, plus
`gapPotential` for the density coordinate) is about the *measure* — `mintPotential`,
`selfGuardPotential`, `budgetPotentialAt` — and this residual touches none of them. This residual
lives entirely in the `saturateBlocked` / `findUnexpandedUnblockedWith` pair and never mentions
`expandOnceUnblocked`. The one place 434 matters is Phase 6: the terminus family that must be
restated is whichever is currently landed (`buildTableauAt_isSome_of_budget_fixed` and its five
predecessors), which is a *consumption* dependency, not a blocker. If 434's residual later
lands a further family, Phase 6's restatement pattern applies to it unchanged.

### Roadmap Alignment

No `specs/ROADMAP.md` consulted for this task (no `roadmap_path` in the delegation context, no
`roadmap_flag`). No roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Decide, machine-checked, whether `PostBlockingSettles fc` as literally stated is true or false.
- Decide, machine-checked and universally quantified in `fuel`, whether the gap its docstring
  names can be closed by fuel alone.
- On the refutation branch: land the **minimal** repaired predicate, its direction lemma, the
  proof that it still discharges both settlement points, and a discharge at a concrete
  **non-vacuous** instantiation.
- Restate the affected termini at the repaired residual, additively, with the landed ones
  byte-unchanged.
- Add C9 register entries for every route this task refutes.

**Non-Goals**:
- Discharging `PostBlockingSettles` via `ArmSettlement`. Proved strictly too weak in-file
  (`MintBound.lean:5144-5147`): `resolveOpenArm` tests `findClosure satBr` *before* its
  saturation test and `buildTableauAt` does not, so `ArmSettlement` cannot cover
  `buildTableauAt`'s arm. Any phase output that reaches for it is a defect, not a shortcut.
- Editing `Saturation.lean` or `Tableau.lean` (md5-pinned FROZEN), or `Fuel.lean`.
- Altering any previously-landed declaration in `MintBound.lean`. Every output is additive.
- Widening the terminus's *conclusion*, weakening the saturation test that `buildTableauAt`
  actually runs, or replacing `findUnexpandedUnblockedWith` with a label-free-restricted finder
  in the residual's conclusion. Any of these is a weakening dressed as a repair, and Phase 3's
  direction-lemma gate exists to catch it.
- The measure-side work: `gapPotential`, the density coordinate, and 434's engine-level assembly.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A "repair" that is secretly a weakening (register entry 7's recorded mistake) | H | M | Phase 3 is a hard gate: both bridges (`armSettlement_of_*` and `buildTableauAt_isSome_of_settles*`) must compile against the repaired predicate before any later phase runs. A repair that fails this is discarded, not patched. |
| The repaired predicate is only dischargeable at a vacuous instantiation (the `mintPaysForTime_empty` / `universeClosed_identify_empty` failure mode, twice recorded in C9) | H | M | Phase 5 requires a `decide`-checked **non-vacuity** witness beside the discharge. A discharge available only at the empty/vacuous boundary must be reported as such, in those words, never presented as a discharge. |
| Refutation witness not universally quantified in `fc`, leaving the register entry weaker than entries 9/10/14/20 | M | M | Phases 1-2 require `∀ fc` (and `∀ fuel` in Phase 2) in the statement, following `difficultyBounded_multiplicity_false` and `mintPaysForTimeStable_signedUniverse_false`. A witness that needs a specific frame class is recorded as such and the entry says so. |
| `decide`-based witnesses blow the heartbeat budget on an 11.8k-line file | M | M | Follow the file's existing convention: `set_option maxHeartbeats` locally in a `section`, as the `applyRule` sweeps do (`Tableau.lean:2380` precedent, `MintBound.lean` witness sections). Keep witness branches to one or two formulas. |
| Phase 2 comes back FALSE (no fuel-independent counterexample), invalidating the plan's central hypothesis | H | L | Phase 2 pre-declares both continuations. FALSE routes to Phase 8 (the proof branch): a fuel-quantified positive statement, with Phases 4-6 re-read as proof rather than repair. The phase text states both, so a later dispatch cannot rationalize either way. |
| Scope creep into `Saturation.lean` to get a lemma about `expandOnceNoFresh` | M | M | All required symbols are public; unfolding is available from `MintBound.lean`. Phase 4 names the three lemmas needed and confirms each is statable without a private name. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 8 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |
| 6 | 7 | 5, 6, 8 |

Phases within the same wave can execute in parallel.

**Wave 3 is exclusive, not parallel.** Phases 3 and 8 are the two branches of Phase 2's binary
verdict: TRUE runs Phase 3 and closes Phase 8 as `[COMPLETED WITH EXCLUSIONS]`; FALSE runs Phase 8
and closes Phase 3 the same way. Exactly one of them executes.

---

### Phase 1: Gate 1 — the fuel-zero verdict on the literal predicate [COMPLETED]

- **Goal:** Decide, machine-checked and universally quantified in the frame class, whether
  `PostBlockingSettles fc` as literally stated survives the `fuel = 0` arm of `saturateBlocked`.

- **Binary verdict criteria** (state the verdict explicitly in the phase's commit message and in
  the theorem's docstring):
  - **TRUE = the literal predicate is refuted at `fuel = 0`.** `postBlockingSettles_fuel_zero_false`
    compiles, sorry-free. **Unblocks:** branch (b), the repair branch — the predicate the terminus
    carries is false as literally stated, and Phases 3-6 land the repair. Proceed to Phase 2 to
    decide whether the refutation is *only* about `fuel = 0` (a cheap fix) or is fuel-independent
    (a real one).
  - **FALSE = the fuel-zero refutation does not go through.** Record in the phase notes exactly
    which step fails — the two candidates are (i) `saturateBlocked b 0 ord fc` not reducing to
    `some (.inr (b, ord))` as read, and (ii) the chosen witness formula being reported
    `isExpanded` after all. **Blocks:** nothing; Phase 2 still runs and is the substantive gate.
    Do **not** weaken the statement to rescue a TRUE verdict.

- **Tasks:**
  - [x] Read `MintBound.lean:5130-5200` (the residual, its docstring, and
        `armSettlement_of_postBlockingSettles`) and `Saturation.lean:431-470` (`saturateBlocked`'s
        five arms) before writing anything.
  - [x] Pick a one-formula witness branch `ob` carrying a signed formula with an applicable
        **label-free** rule at the initial label — a conjunction is the canonical choice — so that
        `findApplicableRule` is `some` and the root time is unblocked (`blockedTimes` filters
        `knownTimes` by `isTemporallyBlockedSaturated`, and the root has no ancestors).
  - [x] `decide` the two halves separately, so a failure is attributable:
        `saturateBlocked ob 0 oOrd fc = some (.inr (ob, oOrd))` and
        `findUnexpandedUnblockedWith ob oOrd fc (blockedTimes ob oOrd fc (armTracker ob)) = some _`.
        *(deviation: altered — the two halves are landed as the separate named lemmas
        `saturateBlocked_fuel_zero` and `findUnexpandedUnblockedWith_multBranch_one`, proved by
        definitional unfolding rather than by `decide`. `decide` is unavailable here because both
        statements are universally quantified in `fc`, which is not a finite type this file
        enumerates; separability — the plan's actual requirement, so a failure is attributable — is
        preserved by the two-lemma split.)*
  - [x] State and prove `postBlockingSettles_fuel_zero_false (fc : FrameClass) : ¬ PostBlockingSettles fc`,
        universally quantified in `fc`, following the shape of
        `difficultyBounded_multiplicity_false` (`MintBound.lean:4755`).
  - [x] Write a docstring saying what the witness shows and — in one sentence — what it does
        **not** show: that it is a statement about the `fuel = 0` arm and settles nothing about
        larger fuel, which is Phase 2's question.
  - [x] Confirm sorry-free and axiom-clean for the new declaration (`lean_verify`, axioms within
        `{propext, Classical.choice, Quot.sound}`).

- **Timing:** 1.5 hours
- **Depends on:** none
- **Verification Tier:** local
- **Scope Hypothesis:** This phase asserts that a **one-formula** witness branch suffices and
  that `fc` can be left universally quantified. Confirm at implementation time by `decide`ing
  both halves at `.Base` and at one non-`.Base` class before committing to the `∀ fc` statement;
  if the witness needs a specific class, narrow the statement and say so in the docstring rather
  than forcing the quantifier.

- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive: one
    witness section (branch, ordering, `decide` facts) and one refutation theorem.

- **Verification:**
  - `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
  - No `sorry` in the new declarations; `lean_verify` on the new theorem reports only the three
    permitted axioms.
  - **Done when:** the verdict is recorded in one of the two forms above, with the corresponding
    theorem compiling (TRUE) or the failing step named in the phase notes (FALSE).

---

- **Verdict: TRUE.** The literal predicate is refuted at `fuel = 0`, at every frame class.
  `postBlockingSettles_fuel_zero_false` compiles, sorry-free, with axioms
  `{propext, Classical.choice, Quot.sound}`. Proceed to Phase 2 to decide whether the refutation is
  *only* about `fuel = 0`.

### Phase 2: Gate 2 — does fuel alone close the gap? [COMPLETED]

- **Goal:** Answer the residual docstring's own open question — "whether the fuel-vs-condition
  gap can be closed by fuel alone" — machine-checked and universally quantified in `fuel`. This
  is the phase the task turns on.

- **Binary verdict criteria:**
  - **TRUE = fuel does NOT close the gap.** A witness `(ob, oOrd)` exists at which
    `saturateBlocked ob fuel oOrd fc = some (.inr (ob, oOrd))` for **every** `fuel` while
    `findUnexpandedUnblockedWith ob oOrd fc (blockedTimes ob oOrd fc (armTracker ob)) = some _`.
    **Unblocks:** branch (b), and fixes the shape of the repair — the missing content is a
    *label-minting* side condition on the branch, not a fuel figure. Phases 3-6 proceed as
    written. The C9 entry this produces is the task's main negative result.
  - **FALSE = no fuel-independent witness is obtainable.** Every candidate `sf` at an unblocked
    time whose rule mints a label turns out to be reported `isExpanded`, or blocked, or the
    `.saturated` exit is unreachable from such a branch. **Blocks:** branch (b)'s premise.
    Route to **Phase 8** (the last phase below) and re-read Phases 4-6 as the proof branch: the repaired
    predicate becomes a *fuel-quantified* positive statement
    (`∀ fuel ≥ F(ob), …`) and Phase 4's content becomes the fuel bound rather than the
    side condition. Record the FALSE verdict and the specific obstruction in the phase notes;
    do not proceed to Phase 3 as written.

- **Tasks:**
  - [x] Read `Tableau.lean:2335-2355` (`expandOnceNoFresh`'s `pick`, both rejection tests) and
        `Tableau.lean:2189` / `2023` (`findUnexpandedUnblockedWith`, `isExpanded`) side by side.
        The gap this phase probes is the difference between "no label-free rule applies anywhere"
        and "no rule applies at an unblocked time".
  - [x] Construct a witness branch whose only applicable rule at the (unblocked) root **mints a
        fresh label** — a temporal existential such as `T(F p)@Label.initial` is the intended
        shape, since its rule is witness-guarded and lengthens the ordering constraints, so
        `expandOnceNoFresh`'s second rejection test fires and `pick` is `none`.
        *(deviation: altered — used the landed `freshWorldBranch = [F(□p)@⟨0,0⟩]` instead, whose
        `.boxNeg` rule mints a fresh **world** and so trips `expandOnceNoFresh`'s **first**
        rejection test (`ruleMintsFreshLabel`) rather than the second. The refutation is the same
        statement about the same disagreement — register entry 13 records that the two rejection
        tests exist precisely because neither rule list subsumes the other — and the vehicle comes
        with `findApplicableRule_freshWorldWitness`, a landed `∀ fc` reduction. Recorded in
        `postBlockingSettles_fuel_gap_false`'s own docstring.)*
  - [x] `decide` the three separable facts: `expandOnceNoFresh ob oOrd fc = (.saturated, oOrd)`;
        `findApplicableRule sf ob oOrd fc = some _` (so `isExpanded` is false);
        `blockedTimes ob oOrd fc (armTracker ob)` does not contain the root's time.
        *(deviation: altered — landed as three named lemmas proved by unfolding
        (`expandOnceNoFresh_freshWorldBranch`, `findUnexpandedUnblockedWith_freshWorldBranch`, and
        `blockedTimes_empty` reused for the third) rather than by `decide`, which is unavailable on
        statements universally quantified in `fc`. Separability is preserved.)*
  - [x] Prove the **fuel-universal** step: from `expandOnceNoFresh ob oOrd fc = (.saturated, _)`
        and `findClosure ob fc = none`, conclude `saturateBlocked ob fuel oOrd fc = some (.inr (ob, oOrd))`
        for every `fuel` — by `cases fuel` and one unfolding of `saturateBlocked`, with no
        induction needed: the `fuel + 1` arm reaches its `.saturated` case in one step. Name it
        `saturateBlocked_eq_self_of_noFresh_saturated`.
  - [x] State and prove `postBlockingSettles_fuel_gap_false (fc : FrameClass) : ¬ PostBlockingSettles fc`,
        instantiated at a **nonzero** fuel so that the statement is visibly not a restatement of
        Phase 1, and note in its docstring that the witness works at every fuel.
  - [x] Write the docstring as a verdict on the docstring question, in one line: fuel does not
        close it, because the two tests disagree about label-minting candidates and no fuel
        figure appears in that disagreement.

- **Timing:** 2 hours
- **Depends on:** 1
- **Verification Tier:** local
- **Scope Hypothesis:** This phase asserts that `saturateBlocked`'s reachable `.inr` exits from
  such a branch are exactly the `fuel = 0` arm and the `.saturated` arm — i.e. that the two
  `constraints.length` rejection guards are not reached from this witness. `Saturation.lean:441-445`
  states those guards are unreachable given `expandOnceNoFresh`'s own filter; confirm it **for
  this witness** by `decide` on the concrete step rather than by citing the comment, and if a
  guard is reachable, fold that arm into the fuel-universal lemma explicitly.

- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive: the
    witness section, `saturateBlocked_eq_self_of_noFresh_saturated`, and the refutation theorem.

- **Verification:**
  - `lake build` of the module green; new declarations sorry-free and axiom-clean.
  - The fuel-universal lemma is proved for **all** `fuel`, not checked at a ladder of figures.
  - **Done when:** the verdict is TRUE with `postBlockingSettles_fuel_gap_false` compiling, or
    FALSE with the obstruction named and Phase 8 selected.

---

- **Verdict: TRUE — fuel does NOT close the gap.** `postBlockingSettles_fuel_gap_false` compiles at
  a nonzero fuel, and `postBlockingSettles_gap_at_every_fuel` records both halves simultaneously,
  universally quantified in `fuel` and in `fc`. The missing content is a *label-minting* side
  condition on the branch, not a fuel figure. **Phase 8 is therefore not executed**; Phases 3-6
  proceed as the repair branch.
- **Scope Hypothesis confirmed.** The two `constraints.length` rejection guards are not on this
  witness's path at all: the pass reaches the `(.saturated, _)` arm in one step from `fuel + 1`, and
  that arm precedes every guard. `saturateBlocked_eq_self_of_noFresh_saturated`'s proof is two
  cases and no induction, so the guards never have to be folded in.

### Phase 3: The repaired predicate and its direction-lemma gate [COMPLETED WITH EXCLUSIONS]

- **Goal:** Land the **minimal** repaired predicate and prove, machine-checked, that it is a
  repair and not a weakening — i.e. that it still discharges **both** settlement points.

- **The repair, pre-declared so a later dispatch cannot invent a softer one.** Phase 2's witness
  locates the missing content at the branch, not at the fuel, so the repair relocates exactly two
  hypotheses and changes the conclusion **not at all**:
  - `LabelFreeSaturatedExit satBr satOrd fc` := `expandOnceNoFresh satBr satOrd fc = (.saturated, satOrd)`
    — the pass ran to label-free saturation rather than being truncated by fuel.
    *(deviation: altered — landed as `(expandOnceNoFresh satBr satOrd fc).1 = .saturated`, not the
    pair equation. `expandOnceNoFresh`'s `.notApplicable` arm returns `(.saturated, newOrd)` with the
    **picked** ordering, so the pair equation is strictly stronger than what the settlement argument
    consumes and than what `saturateBlocked`'s own `(.saturated, _)` arm reads. Phase 4's task list
    pre-sanctions exactly this narrowing. It weakens the hypothesis, hence strengthens every
    statement assuming it, so it cannot rescue a gate verdict.)*
  - `NoUnblockedFreshWork satBr satOrd fc` := every `sf ∈ satBr` at a time outside
    `blockedTimes satBr satOrd fc (armTracker satBr)` whose `findApplicableRule` is `some (rule, _, newOrd)`
    satisfies `¬ ruleMintsFreshLabel rule ∧ newOrd.constraints.length ≤ satOrd.constraints.length`
    — no label-minting work is left sitting at an unblocked time.
  - `PostBlockingSettlesAt fc` := `PostBlockingSettles`'s statement with those two added as
    antecedents on the **output** branch. The conclusion
    `findUnexpandedUnblockedWith satBr satOrd fc (blockedTimes …) = none` is carried over verbatim.

- **Binary verdict criteria (the anti-weakening gate):**
  - **TRUE = the repair is admissible.** BOTH bridges compile against `PostBlockingSettlesAt`:
    (i) `armSettlement_of_postBlockingSettlesAt`, the analogue of `MintBound.lean:5178`, and
    (ii) `buildTableauAt_isSome_of_settlesAt`, the analogue of `buildTableauAt_isSome_of_settles`.
    **Unblocks:** Phases 4-6.
  - **FALSE = the repair is a weakening.** Either bridge fails to compile because the added
    antecedents cannot be supplied at the consuming site. **Blocks:** this repair, permanently.
    Discard it — do **not** patch the bridge, do **not** narrow the conclusion, do **not** move
    the antecedent from the output branch to the input branch to make the bridge typecheck
    without checking that the consuming site can supply it. Record the failure as a C9 entry in
    Phase 7 and state the next candidate repair (relocating to the *input* branch `ob`, with the
    entry condition supplied by `expandBranchWithFuel`'s open exit) as a named, unattempted
    follow-on.

- **Tasks:**
  - [x] Read the two consuming sites in full before defining anything:
        `armSettlement_of_postBlockingSettles` (`MintBound.lean:5178-5194`) and
        `buildTableauAt_isSome_of_settles` (`MintBound.lean:5196` onward). The repaired predicate
        is admissible only if the added antecedents are available where those proofs consume it.
  - [x] Define `LabelFreeSaturatedExit`, `NoUnblockedFreshWork` and `PostBlockingSettlesAt`,
        each with a docstring saying which of Phase 2's two disagreements it closes.
  - [x] Prove the **direction lemma** `postBlockingSettlesAt_of_postBlockingSettles :
        PostBlockingSettles fc → PostBlockingSettlesAt fc`. Direction matters and must be stated
        in the docstring in the register's own idiom: the hypothesis list is longer, so the
        predicate is **weaker**, so every theorem restated against it is a **strengthening**.
        Follow `mintPaysForTimeFixed_of_mintPaysForTimeStable` (`MintBound.lean` :10461 region)
        and `universeClosedAt_of_universeClosed` as the pattern.
  - [ ] Prove bridge (i): `armSettlement_of_postBlockingSettlesAt`. *(deviation: skipped — gate returned FALSE; see the verdict record below. Not landed.)*
  - [ ] Prove bridge (ii): `buildTableauAt_isSome_of_settlesAt`. *(deviation: skipped — gate returned FALSE; see the verdict record below. Not landed.)*
  - [x] Add a "no-leak confirmation" note: state whether the two added antecedents introduce any
        hypothesis into the terminus that a caller cannot supply, and if they do, say so plainly —
        this is the check that separates this repair from `UniverseClosed`'s clause 2, whose
        satisfiability set turned out to be `{∅}`.

- **Timing:** 2 hours
- **Depends on:** 2
- **Verification Tier:** local
- **Scope Hypothesis:** This phase asserts that **exactly two** relocated hypotheses suffice — one
  per disagreement Phase 2 exhibits. Confirm at implementation time by attempting bridge (ii)
  with each antecedent dropped in turn: if the bridge still compiles without one, that antecedent
  is not minimal and must be removed before the phase closes.

- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive: three
    definitions, one direction lemma, two bridge theorems.

- **Verification:**
  - Module build green; all six new declarations sorry-free and axiom-clean.
  - Both bridges compile with **no** change to any landed declaration (`git diff` shows additions
    only in this file).
  - **Done when:** TRUE with both bridges compiling and the direction lemma proved, or FALSE with
    the repair discarded and the failure written up for Phase 7's register entry.

---

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Bridge (i) `armSettlement_of_postBlockingSettlesAt` | Not provable: the consuming site holds only the exit equation, which does not carry `LabelFreeSaturatedExit`. | `labelFreeSaturatedExit_not_of_saturateBlocked_inr` |
| Bridge (ii) `buildTableauAt_isSome_of_settlesAt` | Same obstruction at the same site. The only shape that typechecks carries `PostBlockingExitSettled fc`, which is refuted. | `postBlockingExitSettled_false` |
| Terminus restatements at `PostBlockingSettlesAt` (Phase 6) | Blocked by the above: there is nothing admissible to restate against. | as above |

- **Verdict: FALSE — the pre-declared repair is not admissible, and this is decided, not judged.**
  Both consuming sites reach the residual holding exactly one fact about the output pair, the exit
  equation `saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd))`.
  `labelFreeSaturatedExit_not_of_saturateBlocked_inr` decides that this equation does **not** carry
  `LabelFreeSaturatedExit`: at `fuel = 0` the pass hands its input back untested, at every branch.
  The one bridge shape that would typecheck carries the extra hypothesis `PostBlockingExitSettled fc`,
  and `postBlockingExitSettled_false` refutes it at every frame class — it implies the literal
  residual through `postBlockingSettlesAt_settlement`, and that residual is refuted by Phase 1. So
  the only available bridge is a weakening dressed as a repair, caught before anything was restated
  against it. The repair is discarded as a **drop-in** for the residual; the definitions are retained
  because Phase 7's register entry must cite them by name and because
  `postBlockingSettlesAt_holds` proves the relocated statement **true outright**, which is what
  locates the real residual.
- **Scope Hypothesis result.** The "exactly two relocated hypotheses" claim is confirmed as
  *necessary* — `postBlockingSettlesAt_settlement` uses both, and dropping either leaves a
  counterexample (`multBranch 1` for the first, `freshWorldBranch` for the second) — but the
  minimality test the phase prescribes (attempt bridge (ii) with each dropped in turn) is moot,
  since the bridge does not compile with both present.
- **No-leak confirmation.** The two added antecedents *do* introduce hypotheses the consuming sites
  cannot supply. Stated plainly, in the terms the plan requires: this is the same failure mode as
  `UniverseClosed`'s clause 2, whose satisfiability set turned out to be `{∅}` — here the supplying
  hypothesis is not merely hard to discharge, it is false.
- **The next candidate repair, named and deliberately unattempted.** Restrict the residual's
  quantification from "every `(ob, oOrd, fuel)`" to the pair the terminus's own run produces — the
  branch `expandBranchWithFuel` hands to `saturateBlocked` at the seed, at the terminus's own fuel
  figure. `freshWorldBranch` does not refute that form, because the engine never hands it to the
  pass at an adequate fuel. Relocating to the input branch `ob` (the plan's own suggestion) does not
  work: `LabelFreeSaturatedExit` is *false* at `ob` by construction — the pass runs precisely because
  `buildTableauAt`'s guard found outstanding work there.

### Phase 4: The settlement lemma — `.saturated` plus no unblocked fresh work is settlement [COMPLETED]

- **Goal:** Prove the mathematical content of the repair: that the two relocated antecedents
  really do force the conclusion, using only the frozen files' public interface.

- **The argument, stated so the phase can be checked against it.** If
  `expandOnceNoFresh satBr satOrd fc = (.saturated, satOrd)` then `pick` is `none`, so for every
  `sf ∈ satBr`, either `findApplicableRule sf satBr satOrd fc = none`, or the applicable rule
  mints a fresh label, or it lengthens the constraints. `NoUnblockedFreshWork` rules out the
  second and third disjuncts at every unblocked time. Hence every unblocked `sf` has
  `findApplicableRule = none`, i.e. `isExpanded sf satBr satOrd fc = true`, i.e.
  `findUnexpandedUnblockedWith satBr satOrd fc (blockedTimes …) = none` by `List.find?_eq_none`.

- **Tasks:**
  - [x] Prove `expandOnceNoFresh_saturated_imp`: from `expandOnceNoFresh b ord fc = (.saturated, _)`,
        for every `sf ∈ b`, `findApplicableRule sf b ord fc = none ∨ (mints a fresh label) ∨
        (lengthens constraints)`. This is `List.findSome?_eq_none` against `pick`'s body; confirm
        it is statable without naming any private symbol (all four symbols involved are public
        `def`s — `Tableau.lean:1829`, `1970`, `2335`).
  - [x] Prove `findUnexpandedUnblockedWith_eq_none_of_isExpanded`: if every `sf ∈ b` outside
        `blocked` has `isExpanded sf b ord fc = true`, the finder is `none`. Pure `List.find?`
        reasoning.
  - [x] Compose the two into `postBlockingSettlesAt_settlement`, the core lemma, and use it to
        prove `PostBlockingSettlesAt fc` **outright** — i.e. show the repaired predicate is not
        merely weaker but actually **true**, unconditionally in `fc`. If that succeeds, the
        repaired residual is discharged and Phase 5's remaining job is the non-vacuity of the
        antecedents rather than the discharge of the predicate.
  - [x] If the composition does **not** close (e.g. the `.saturated` exit's ordering component is
        not literally `satOrd`, or the `.notApplicable` arm of `expandOnceNoFresh` returns a
        different ordering), narrow `LabelFreeSaturatedExit` to the shape that does close and
        re-run Phase 3's bridge (ii) against the narrowed form before proceeding. A narrowing that
        breaks bridge (ii) is Phase 3's FALSE verdict arriving late; treat it as such.
  - [x] Docstring: say which of the two frozen-file disagreements each hypothesis pays for.

- **Timing:** 2 hours
- **Depends on:** 3
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Scope Hypothesis:** This phase asserts that **three** lemmas suffice (the `findSome?`
  inversion, the `find?` closure, and the composition). Confirm by writing the composition first
  as a `sorry`-free skeleton with the two inputs as explicit hypotheses; if the skeleton needs a
  fourth fact, name it before proving it, and record it in the phase notes.

- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive: three
    lemmas plus the outright discharge of `PostBlockingSettlesAt` if it goes through.

- **Verification:**
  - Module build green; sorry-free; axioms within `{propext, Classical.choice, Quot.sound}`.
  - **Done when:** `postBlockingSettlesAt_settlement` compiles and either (a)
    `PostBlockingSettlesAt fc` is proved outright for all `fc`, or (b) the phase notes name
    exactly which residue remains and why, with no `sorry` left in the file.

---

- **Outcome (a).** `postBlockingSettlesAt_settlement` compiles and `PostBlockingSettlesAt fc` is
  proved **outright** for every `fc` (`postBlockingSettlesAt_holds`). The repaired statement is not
  a residual at all; it is a theorem. That is the honest resolution of the residual's open question:
  the settlement test is decided by the branch, not by the fuel.
- **Scope Hypothesis result: a fourth fact was needed and is named.**
  `findApplicableRule_result_ne_notApplicable`. `expandOnceNoFresh` has a *second* route to
  `.saturated` — its `.notApplicable` arm, which returns the picked ordering — and the inversion has
  to rule that route out rather than assume it dead. It is dead because `findApplicableRule`'s own
  body maps `.notApplicable` to `none` before building its `some`.
- **Deviation (sequencing, not content): this phase ran on a FALSE Phase 3 verdict.** The plan makes
  Phase 4 depend on Phase 3 TRUE. Phase 4's content is independent of the bridge verdict — it is a
  statement about `expandOnceNoFresh` and `findUnexpandedUnblockedWith` alone — and it is the
  *evidence* that makes Phase 3's FALSE verdict decidable rather than merely observed
  (`postBlockingExitSettled_false` routes through `postBlockingSettlesAt_settlement`). Raised to the
  dispatching agent before proceeding; Phases 5-6 were **not** started pending that ruling.

### Phase 5: Discharge at a concrete useful instantiation, with a non-vacuity witness [COMPLETED]

- **Goal:** Show the repaired residual is usable, not just weaker: discharge its antecedents at a
  concrete instantiation the terminus is meant to be used at, and prove that instantiation is
  **non-vacuous**.

- **Binary verdict criteria:**
  - **TRUE = a non-vacuous discharge exists.** Both antecedents are discharged for a named class
    of branches, AND a `decide`-checked witness shows the class is inhabited by a branch the
    engine actually produces. **Unblocks:** the terminus is usable at that class; Phase 7 records
    a positive verdict.
  - **FALSE = the discharge is available only at a vacuous boundary** (the empty universe, the
    empty branch, or a class the seed run never reaches). **Blocks:** any claim that the residual
    is discharged. Report it in exactly those words — the file already carries two instances of
    this failure mode (`mintPaysForTime_empty`, `universeClosed_identify_empty`, each recorded as
    "satisfiable only where the terminus it guards is vacuous"), and a third must be named the
    same way, not dressed up.

- **The intended instantiation, pre-declared.** The label-minting-free fragment: branches confined
  to a `signedUniverse C L` whose closure `C` contains no formula whose rule mints a label — i.e.
  the purely propositional fragment, at **every** frame class. There, `NoUnblockedFreshWork` holds
  for every confined branch because no rule in play mints anything, and `LabelFreeSaturatedExit`
  follows from `saturateBlocked` reaching `.saturated` once the propositional work is exhausted.
  This is a genuinely useful class — the terminus applies to propositional `φ` — and it is not a
  boundary case.

- **Tasks:**
  - [x] Define the fragment predicate (e.g. `LabelFreeUniverse C`, or reuse an existing
        closure-side predicate if one is already landed — search `MintBound.lean` for an existing
        propositional-fragment or `freshTimeRules`-free notion before defining a new one).
        *(deviation: altered — landed as `LabelFreeUniverseAt fc U ord`, parameterised by the
        **ordering** as well as the universe. Forced by the frozen engine: `orderTrichotomy` is in
        `allRulesForFC` and is applicable to *every* signed formula, and it lengthens the ordering
        exactly when the ordering has an incomparable pair, so no condition on the formula stock
        alone can be sufficient. At `TimeOrdering.empty` it reports `.notApplicable`, which is where
        the witness runs. No existing propositional-fragment predicate was found by grep.)*
  - [x] Prove `noUnblockedFreshWork_of_labelFreeUniverse`: confinement to such a `C` gives the
        second antecedent for every branch and ordering.
  - [x] Discharge `LabelFreeSaturatedExit` on that fragment, or — if it needs a fuel figure —
        state the figure explicitly and prove the exit at it, rather than assuming "enough fuel".
        *(no fuel figure needed: `labelFreeSaturatedExit_multSettledBranch` is decided outright at
        all four frame classes, and `saturateBlocked_multBranch_one_run` holds at every `fuel + 1`.)*
  - [x] Prove the **non-vacuity witness**: `decide` that a concrete propositional `φ` seeds a run
        reaching a branch in the class, so the discharge is not about an empty class. Follow
        `mintPaysForTimeStable_signedUniverse_empty`'s placement as the *contrast* case — that one
        records how far a discharge goes; this one must go further, and if it does not, say so.
        *(deviation: altered — the non-vacuity witness is the **pass's own run**
        (`saturateBlocked_multBranch_one_run`, at every frame class and every `fuel + 1`) rather
        than a seed run through `buildTableauAt`. It is the stronger statement for this purpose: the
        branch the antecedents are discharged at is the one `saturateBlocked` itself returns, which
        is exactly the branch the residual quantifies over.)*
  - [x] Compose into `postBlockingSettlesAt_labelFree`, the concrete discharge.

- **Timing:** 2 hours
- **Depends on:** 4
- **Verification Tier:** local
- **Scope Hypothesis:** This phase asserts the propositional fragment is the right instantiation
  and that it is inhabited by an engine-reachable branch. Confirm the inhabitation by `decide` on
  a concrete seed run **before** writing the general lemmas; if the fragment turns out to be
  reachable only at the seed and never after one expansion step, narrow the claim to what the
  witness supports and record the narrowing.

- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive: the
    fragment predicate, two discharge lemmas, the non-vacuity witness, the composed theorem.

- **Verification:**
  - Module build green; sorry-free; axiom-clean.
  - **Done when:** TRUE with `postBlockingSettlesAt_labelFree` compiling beside a `decide`-checked
    non-vacuity witness, or FALSE with the vacuity stated in the terms above.

---

- **Verdict: TRUE on the letter of the criterion, with a caveat that changes how it reads — stated
  here rather than buried.** Both antecedents are discharged at a named branch
  (`labelFreeSaturatedExit_multSettledBranch`, `noUnblockedFreshWork_multSettledBranch`), the branch
  is nonempty and three formulas wide, and `saturateBlocked_multBranch_one_run` decides that the
  post-blocking pass **itself produces it**, at every frame class and every positive fuel. So this
  is not the `mintPaysForTime_empty` / `universeClosed_identify_empty` boundary: the discharge is not
  available only at the empty universe.
- **The caveat, in the plan's own required words.** `noUnblockedFreshWork_iff_of_labelFreeSaturatedExit`
  proves that *given* the first antecedent, the second is **equivalent** to the conclusion — the
  unconditional converse `noUnblockedFreshWork_of_settled` is the half that was not anticipated. So
  the class at which the pair is dischargeable is exactly the class at which the settlement test
  already closes, and the discharge therefore does not extend that class. This is why
  `PostBlockingSettlesAt` is a theorem rather than a repair, and it is the sharpest available
  statement of Phase 3's FALSE verdict. It is recorded as such and is not presented as a discharge
  of the residual.
- **What is left open, and is genuinely useful**: `LabelFreeUniverseAt` +
  `noUnblockedFreshWork_of_labelFreeUniverseAt` give the one direction the equivalence does not
  collapse — a **branch-independent** sufficient condition, checkable from the universe and the
  ordering without looking at the branch. Discharging `LabelFreeUniverseAt` at a concrete
  `signedUniverse C L` is not attempted here and is named as a follow-on.
- **Scope Hypothesis result.** The propositional fragment is the right instantiation, and it is
  inhabited by a pass-produced branch — confirmed by `decide` on the concrete run before the general
  lemmas were written, as the phase prescribes. The narrowing that was required is the ordering
  parameter on the fragment predicate, recorded inline above.

### Phase 6: Restate the termini at the repaired residual [NOT STARTED]

- **Goal:** Carry the repaired residual through the terminus chain, additively, with every landed
  declaration byte-unchanged.

- **Tasks:**
  - [ ] Enumerate the terminus family that currently takes `hpb : PostBlockingSettles fc` — from
        `grep -n "hpb : PostBlockingSettles" MintBound.lean`, the sites run from the
        `buildTableauAt_isSome_of_budget` region through `_at`, `_selfGuarded` and `_fixed` and
        their seed-level and `signedUniverse` siblings.
  - [ ] For each, add an additive sibling taking `hpb : PostBlockingSettlesAt fc` instead, proved
        from the original's proof plus `postBlockingSettlesAt_of_postBlockingSettles` where a
        direction step is needed. Use a single consistent suffix.
  - [ ] Confirm **no figure changes**: `mintAwareFuelAt`, `derivedTmaxAt`, `budgetPotentialAt` and
        `mintPathBoundAt` are reused byte for byte. Say so in the section docstring, following
        entry 20's "It costs **no figure**" formulation.
  - [ ] Confirm no landed declaration was altered: `git diff` on `MintBound.lean` shows insertions
        only.
  - [ ] Section docstring: state which residual each restated terminus now carries and that the
        originals are retained verbatim because nothing in this file is withdrawn.

- **Timing:** 1.5 hours
- **Depends on:** 4
- **Verification Tier:** local
- **Scope Hypothesis:** This phase asserts the restatement set is the sites `grep -n "hpb :
  PostBlockingSettles"` reports. Run that grep at implementation time and record the count in the
  phase notes; if a site consumes the residual indirectly (through a helper rather than as a named
  hypothesis), add it to the set explicitly rather than silently excluding it.

- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive: the
    restated terminus siblings.

- **Verification:**
  - Module build green; sorry-free; axiom-clean.
  - `git diff --stat` on `MintBound.lean` shows additions and no deletions.
  - **Done when:** every enumerated site has an additive sibling at the repaired residual, or the
    phase notes name the sites deliberately excluded and why.

---

### Phase 7: C9 register entries, verdict record, and the whole-repository gate [NOT STARTED]

- **Goal:** Record every route this task refuted, state the verdict honestly, and prove the
  repository is green, sorry-free and axiom-free.

- **Tasks:**
  - [ ] Add C9 register entry 22: **`PostBlockingSettles fc` as literally stated.** Refuted, with
        `postBlockingSettles_fuel_zero_false` and `postBlockingSettles_fuel_gap_false` as the two
        witnesses, and the one-line cause: `expandOnceNoFresh` skips label-minting candidates
        while `findUnexpandedUnblockedWith` counts them, so the two tests disagree at every fuel.
        Include the sentence a future reader needs: **fuel does not close it**, answering the
        residual docstring's open question, and name the settled repair
        (`PostBlockingSettlesAt`, with `postBlockingSettlesAt_of_postBlockingSettles` fixing the
        direction).
  - [ ] Add C9 register entry 23 **if and only if** Phase 3's or Phase 5's gate returned FALSE:
        record the discarded repair, or the vacuity of the discharge, in the same idiom the
        existing twenty-one entries use — by declaration name and refuting witness, never by
        narrative.
  - [ ] Update the `PostBlockingSettles` docstring's own open-question paragraph: it currently
        says "whether the gap can be closed by fuel alone … nothing here decides it". That
        sentence is now decided; correct it in place while leaving the `def` itself byte-unchanged,
        following the precedent set by entry 19's "One line of this entry is withdrawn by entry 20"
        and entry 21's corrected docstring.
  - [ ] Whole-repository gate: `lake build` green from a clean state.
  - [ ] Sorry audit: `grep -rn "sorry" FormalSystem/` reports nothing new; `lean_verify` on the
        task's headline declarations (`postBlockingSettles_fuel_gap_false`,
        `postBlockingSettlesAt_settlement`, `postBlockingSettlesAt_labelFree`, and each restated
        terminus) confirms axioms within `{propext, Classical.choice, Quot.sound}`.
  - [ ] Write the verdict record: which of outcome (a) or (b) this task delivered, in one
        paragraph, with no hedging in either direction.

- **Timing:** 1.5 hours
- **Depends on:** 5, 6, 8
- **Verification Tier:** full
- **Scope Hypothesis:** This phase asserts one or two new register entries. The count depends on
  Phases 3 and 5's verdicts; confirm by re-reading those phases' recorded verdicts before writing,
  and add an entry for **every** route actually refuted, not only the headline one.

- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive: register
    entries; in-place docstring correction on the `PostBlockingSettles` open-question paragraph.

- **Verification:**
  - Full `lake build` green across the repository.
  - Zero new `sorry`; zero new axioms outside the permitted three.
  - **Done when:** the register carries an entry for every refuted route, the residual docstring's
    open question is corrected, and the whole-repository build is green.

---

### Phase 8: The proof branch (executed ONLY on a FALSE verdict at Phase 2) [NOT STARTED]

- **Goal:** If Phase 2 finds no fuel-independent counterexample, prove `PostBlockingSettles fc`
  for the frame classes the terminus is meant to be used at, using only `Saturation.lean`'s public
  interface.

- **Entry condition:** Phase 2 returned FALSE. If Phase 2 returned TRUE, this phase is **not
  executed** and closes as `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record
  citing Phase 2's verdict as the evidence.

- **Tasks:**
  - [ ] Prove the fuel-truncation arm is the only obstruction: strengthen
        `saturateBlocked_eq_self_of_noFresh_saturated` (Phase 2) into a fuel-sufficiency statement
        — there is an `F(ob)` such that `fuel ≥ F(ob)` forces the pass to exit at `.saturated`
        rather than at the `fuel = 0` arm. The measure is branch-set growth against the finite
        signed closure, the same measure `expandOnceUnblocked_adds_new` (`Tableau.lean` progress
        section) uses.
  - [ ] Prove the label-minting disjunct is unreachable at an unblocked time on a branch the
        engine hands to `saturateBlocked` — this is what Phase 2's FALSE verdict asserts, and it
        must be proved, not inherited from the failure to find a counterexample.
  - [ ] State `PostBlockingSettlesFuel fc` (the fuel-quantified positive form) and prove it.
  - [ ] Re-read Phases 4-6 with `PostBlockingSettlesAt` replaced by `PostBlockingSettlesFuel`;
        the direction-lemma gate in Phase 3 applies unchanged and is still mandatory.

- **Timing:** 2 hours
- **Depends on:** 2
- **Verification Tier:** local
- **Scope Hypothesis:** This phase asserts a fuel bound `F(ob)` exists and is expressible from the
  public interface. Confirm by writing the bound's statement before attempting its proof; if the
  bound needs a fact about `expandOnceNoFresh` that is only available inside `Saturation.lean`,
  stop — that is a scope boundary, not a proof obstacle, and it must be reported rather than
  worked around by editing a frozen file.

- **Files to modify:**
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive.

- **Verification:**
  - Module build green; sorry-free; axiom-clean.
  - **Done when:** `PostBlockingSettlesFuel fc` is proved, or the phase is excluded on Phase 2's
    TRUE verdict with the Reasoned Exclusions record written.

---

## Testing & Validation

- [ ] `lake build` green across the whole repository at task close.
- [ ] `grep -rn "sorry" FormalSystem/` reports no new occurrences relative to the pre-task state.
- [ ] `lean_verify` on every headline declaration reports axioms within
      `{propext, Classical.choice, Quot.sound}`.
- [ ] `git diff` on `MintBound.lean` shows insertions plus the one in-place docstring correction in
      Phase 7 — no landed declaration's statement or proof is altered.
- [ ] `Saturation.lean`, `Tableau.lean` and `Fuel.lean` are byte-unchanged (re-check the md5 pins).
- [ ] Both settlement bridges (`armSettlement_of_*`, `buildTableauAt_isSome_of_settles*`) compile
      against whichever predicate the task lands.
- [ ] Every phase's binary verdict is recorded — TRUE or FALSE, in the phase notes and in the
      commit message — before the next phase runs.

## Artifacts & Outputs

- `specs/433_discharge_postblockingsettles_residual/plans/01_postblockingsettles-refute-or-prove.md` (this file)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — additive:
  refutation witnesses, the repaired predicate with its direction lemma, the settlement lemma, the
  concrete discharge, the restated termini, and C9 register entries 22 (and 23 if warranted)
- `specs/433_discharge_postblockingsettles_residual/summaries/01_postblockingsettles-summary.md` — implementation summary with the verdict record

## Rollback/Contingency

Every phase is additive to a single file and each closes at a green build, so rollback is
`git revert` of that phase's commit; no landed declaration is altered, so no downstream consumer
can break. If Phase 3's direction-lemma gate returns FALSE and the alternative repair also fails,
the honest terminus is: `PostBlockingSettles` refuted (Phases 1-2 stand on their own and are
committed), no admissible repair found, both recorded in the C9 register. That is a complete and
reportable outcome — the refutation is the deliverable — and the task closes `[PARTIAL]` with the
repair named as the open follow-on, not `[COMPLETED]`.
