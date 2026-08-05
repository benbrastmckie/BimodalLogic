# Implementation Plan: Task #428 (revision 2)

- **Task**: 428 - engine_totality_at_a_quantified_branch_budget
- **Status**: [PARTIAL]
- **Effort**: 23 hours total (7 landed across phases 1-4; 16 remaining across phases 5-13)
- **Dependencies**: None blocking (tasks 426 and 412 are sequenced *behind* this one in state.json; Fuel.lean is unshared for the duration of this task)
- **Research Inputs**:
  - specs/428_engine_totality_at_a_quantified_branch_budget/reports/01_budget-totality-refuted-and-repair.md
  - specs/428_engine_totality_at_a_quantified_branch_budget/reports/02_splitordered-measure-blocker.md
- **Artifacts**: plans/02_lexicographic-splitordered-measure.md (this file); supersedes plans/01_budget-totality-engine-repair.md, which is retained unchanged as the historical record
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, lean4.md, plan-compliance.md
- **Type**: lean4
- **Lean Intent**: false
- **reports_integrated**: 01_budget-totality-refuted-and-repair.md, 02_splitordered-measure-blocker.md

## Overview

Plan 01 executed cleanly through Phase 3 and partway into Phase 4, then hit a genuine refutation:
its task 4.1 asked for a `.splitOrdered` twin of the split-growth lemma, and that twin is **false**,
exhibited by the landed, machine-checked `applyRule_timeLinearity_arms`. Phase 6's fuel figure
rested on it, so Phases 5-8 were correctly not started and the blocker was escalated rather than
worked around.

This revision keeps every landed asset and replaces the refuted route with the **lexicographic
measure** validated in `reports/02_splitordered-measure-blocker.md`:

```
splitOrderedMeasure b ord := ( b.knownTimes.toFinset.card , (incompPairs b ord).card )
```

`timeLinearity`'s arms 1-2 (`addFuture`) leave the branch *literally unchanged*, so component 1 is
equal and component 2 strictly decreases; arm 3 (`identifyTime`) strictly decreases component 1.
Fourteen supporting lemmas were type-checked against the real repo via `lean_run_code` before this
plan was written.

The revision also **does not oversell the fix**. The measure bounds `.splitOrdered` depth *between
fresh-time mints*, not globally, so Phase 10's fuel figure needs an a-priori carried bound
`|b.knownTimes| ≤ Tmax`, and Phase 12 must discharge it. That discharge is **UNVERIFIED and is this
plan's main risk**; it is carried as a first-class risk with an explicit `[BLOCKED]` escalation
clause, not buried in a task list.

Definition of done is unchanged from plan 01: `buildTableauAt_isSome_of_budget` lands sorry-free
with no `NoSplit` hypothesis, `lake build` is green repo-wide, and the world dimension is supplied
rather than assumed.

### Research Integration

Newly integrated in this revision: **`reports/02_splitordered-measure-blocker.md`** (all findings
below marked VERIFIED were type-checked via `lean_run_code` at Lean v4.33.0-rc1 with the project's
own imports; the two UNVERIFIED items are named as such and are load-bearing risks, not settled
facts).

- **G1 (VERIFIED, the fix)**: the lexicographic measure above strictly decreases at all three arms
  of `applyRule .timeLinearity`. Fourteen supporting lemmas type-check: `pathN_mono`,
  `directFutureOf_mono`, `directPastOf_mono`, `futureOf_mono`, `pastOf_mono`,
  `mem_futureOf_addFuture`, `mem_pastOf_addFuture`, `firstIncomparablePair_spec`,
  `incomparableB_mono`, `incompPairs_mono`, `incompPairs_lt_addFuture`,
  `src_not_mem_knownTimes_identifyTime`, `knownTimes_identifyTime_subset`,
  `knownTimes_card_lt_identifyTime`.
- **G2 (VERIFIED, the sidestep)**: because arm 3 drops component 1, **no fact about the rewritten
  `TimeOrdering` produced by `identifyTime` is ever needed.** Proving that `identifyTime`'s
  constraint substitution preserves comparability of the surviving times — the hardest part of the
  original proposal — is *not required by any phase of this plan*. Do not attempt it.
- **G3 (VERIFIED, no privacy obstruction)**: `futureOf`/`pastOf` route through `reachableForward`/
  `reachableBackward`, which are `private` to `SignedFormula.lean`, but `Fuel.lean:98` already
  carries `open private reachableForward reachableBackward from …`, and Fuel.lean:690-905 already
  provides the whole BFS calculus (`PathN`, `bfsClosure`, `reachableForward_eq`/
  `reachableBackward_eq`, `mem_bfsClosure_of_mem_visited`, `bfsClosure_sound`, `BfsInv`,
  `bfsClosure_complete_aux`, `bfsClosure_complete`, `PathN.snoc`, `PathN.reverse`,
  `mem_directFutureOf_iff`, `orderDual_holds`). **None of it needs to be built and no engine file is
  edited.** This is a different situation from the `temporalCount`/`modalCount` privacy issue
  recorded as finding 4 in the phase-4 handoff, which remains unresolved and unaddressed here.
- **G4 (UNVERIFIED — RESIDUAL GAP 1, this plan's main risk)**: the measure does **not** by itself
  bound split depth. `.split` can mint fresh times (`untlPos`/`sncePos` are branching **and** in
  `ruleMintsFreshLabel`), raising `knownTimes` and resetting the order measure, while
  `.splitOrdered` arm 3 *shrinks* the branch — so a naive lexicographic combination of the two
  measures fails in **both** orderings. Phase 10 therefore carries `hT : |knownTimes| ≤ Tmax` as an
  a-priori invariant and Phase 12 must discharge it. Research 02 did not verify that T2
  (`TimeTypeBound.lean`) delivers the bound in a form Phase 12 can consume, and flags the phase-4
  handoff's own remark that `WorldWitness` is "an invariant, **not** discharged there" as a warning
  sign. See Risks R1.
- **G5 (UNVERIFIED — RESIDUAL GAP 2)**: task 4.1's *first* half is also unlanded. Only the
  non-strict `expandOnceUnblocked_split_card_le` exists; the strict version is what a `.split` depth
  bound needs. It is provable from the `.branching` containment guard
  (`Tableau.lean:1924-1934` rejects an arm when `bss.any (fun fs => fs.all branch.contains)`), but
  needs **three** cases because `ruleSelfGuarded` (`.untlNeg`, `.snceNeg`) and `ruleMintsFreshLabel`
  (`.untlPos`, `.sncePos`) bypass that guard. The guard structure is read from source — strong
  evidence, not proof. Phase 8 owns it. See Risks R2.

Carried forward unchanged from `reports/01_budget-totality-refuted-and-repair.md` (F1-F6) and from
plan 01's own Research Integration section; **none of it is re-derived by any phase here**. The
five findings that remain load-bearing: F1 (the refutation, settled), F2 (the `resolveOpenArm`
repair, landed in Phase 2), F3 (the `saturateBlocked_isSome` asset, landed in Phase 1), F4 (the
budget is per-path and the invariant is `β`-linear, not exponential), F5/F6 (`worldFuel'` is
supplied; the residual is discharging `WorldWitness`, and the hard quantitative content is fuel
decay at splits).

### Prior Plan Reference

`plans/01_budget-totality-engine-repair.md` is the immediate predecessor and remains on disk
unmodified as the historical record, including its `BLOCKER (Phase 4)` entry. This plan supersedes
it. Every phase of plan 01 maps into this plan as follows:

| Plan 01 phase | This plan | Change |
|---|---|---|
| 1 — `saturateBlocked_isSome` | Phase 1 `[COMPLETED]` | none; landed |
| 2 — blocking-aware `resolveOpenArm` | Phase 2 `[COMPLETED]` | none; landed |
| 3 — budget entry point + certificate | Phase 3 `[COMPLETED]` | none; landed |
| 4 — split-arm quantitative prerequisites | Phase 4 `[COMPLETED WITH EXCLUSIONS]` | restated to the landed subset; the refuted `.splitOrdered` cardinality twin is **excluded**; the strict `.split` half is **relocated** to Phase 8 |
| (new) | Phases 5, 6, 7 | the lexicographic `.splitOrdered` measure — research 02 items 1-10 |
| (new) | Phase 8 | strict `.split` cardinality growth — research 02 item 11 (relocated from plan 01 task 4.1) |
| 5 — split-fold preservation helpers | Phase 9 | unchanged in content; renumbered |
| 6 — `NoSplit`-free totality | Phases 10, 11 | split in two, and rebuilt on the lexicographic measure plus the carried `hT` — research 02 items 12-15 |
| 7 — close the world dimension | Phase 12 | gains the `hT` discharge obligation (the main risk) |
| 8 — the terminus | Phase 13 | unchanged in content; renumbered |

Effort calibration for the new phases is taken from research 02's own measured figures (e.g.
`futureOf_mono` is 6 lines; `mem_futureOf_addFuture` is 4 lines) and from the observed pace of
Phase 4, which landed 9 lemmas in one dispatch.

### Roadmap Alignment

No `specs/ROADMAP.md` present; no roadmap phases added.

## Goals & Non-Goals

**Goals**:
- Supply a *correct* progress measure for the `.splitOrdered` constructor, replacing the refuted
  branch-cardinality route with the verified lexicographic measure.
- Land the strict `.split` cardinality growth lemma, or carry strictness as an explicit hypothesis
  if it does not close.
- Remove the `NoSplit` hypothesis from engine totality by supplying the split-arm fuel accounting it
  currently hides, using a fuel figure built from **both** measures plus the carried time bound.
- Close the world dimension by discharging `WorldWitness` for the engine's seed run, and discharge
  the carried `hT` bound from T2 (or its named fallback).
- Land `buildTableauAt_isSome_of_budget` sorry-free with a caller-dischargeable budget hypothesis.

**Non-Goals**:
- **Never** edit `buildTableau`, its `fuel := 1000` default, or `expandBranchWithFuel`'s
  `maxBranches := 50000` default. All three must remain **byte-identical** to their pre-task form;
  the budget entry point is purely additive. The `50000` guard is a deliberate runtime guard.
- **Never** re-attempt the refuted unconditional `buildTableau_isSome`, nor
  `buildTableau_isSome_of_budget` in the shape given in the task description (`maxBranches`
  quantified as the only new hypothesis, `soundFuel' φ` as the fuel). Both are on the
  do-not-re-attempt register; refuted by `φ = F(G p)` at `fuel = 229376`, `maxBranches = 10¹²`,
  cause `resolveOpenArm = none`, independent of both parameters. Reproduction harness:
  `assets/expandDiag-instrumented-mirror.lean.txt`.
- **Never** re-attempt the refuted `.splitOrdered` cardinality twin (see Phase 4's Reasoned
  Exclusions). It is false, not merely unproved.
- **Never** attempt to prove that `TimeOrdering.identifyTime` preserves comparability of surviving
  times. Per G2 it is not needed by any phase; attempting it is wasted effort on the hardest
  available sub-problem.
- **Never** weaken the existing `ExpandedTableau.hasOpen` proof field. Phase 3 already added the
  second, weaker, differently-named `BudgetedTableau` certificate instead.
- Do not edit `CancellableExpansion.lean`, `Tableau.lean`, or any Bridge/TruthLemma file — they are
  outside this task's declared `file_scope`. The `resolveOpenArmCancellable` drift introduced by
  Phase 2 is a **declared, reported out-of-scope divergence** and is deliberately not repaired here
  (see Carried Divergences below).
- Do not edit `allocateFuelProportionally` or `estimateBranchDifficulty`. The proportional policy
  stays; the proof accommodates it.
- Do not change the visibility of `temporalCount`/`modalCount`. They are `private` to
  `Saturation.lean`; the landed `totalDifficulty_le` works around this with an abstract per-arm
  bound `D` and that workaround stands.

### Carried Divergences (declared, not silently repaired)

- **`resolveOpenArmCancellable`** in `FormalSystem/Metalogic/Decidability/CancellableExpansion.lean`
  still tests saturation with the literal `findUnexpanded` at both of its decision points, and its
  two call sites inside `expandBranchWithFuelCancellable`'s `.split` and `.splitOrdered` folds are
  now out of sync with the repaired `resolveOpenArm` in `Saturation.lean`. That file is outside
  `file_scope`; the drift is recorded in `resolveOpenArm`'s docstring naming the function and its
  call sites, and in the plan-01 implementation summary. The cancellable path is `IO`-only and feeds
  no verified result. **This plan does not repair it.** Any phase that finds itself wanting to is
  out of scope and must escalate rather than widen.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **R1 (MAIN RISK) — the carried time bound `hT` (`knownTimes.toFinset.card ≤ Tmax`) cannot be discharged for the engine's seed run.** Research 02 flags this UNVERIFIED: T2 (`TimeTypeBound.lean`) is the intended source but its bound was not confirmed to be in a consumable form, and `WorldWitness` is documented as "an invariant, not discharged there" | H | M | Phase 12 owns the discharge and carries an explicit `[BLOCKED]` escalation clause. Named fallback route: bound fresh-time mints directly via the `witnessPresent` guard (each existential signed formula mints at most one witness, and the existential formulas live in the finite universe `U`) — an independent route to the same bound at higher cost. If neither route closes, the phase is `[BLOCKED]` and `hT` stays an explicitly named hypothesis in the terminus, reported as such in the summary. **Forbidden**: admitting `hT` or `WorldWitness` as an unproved axiom, reintroducing `NoSplit`, or leaving a `sorry` |
| **R2 — the strict `.split` cardinality lemma does not close.** UNVERIFIED; needs three cases because `ruleSelfGuarded` and `ruleMintsFreshLabel` bypass the `.branching` containment guard | M | M | Phase 8 carries a Scope Hypothesis and an escalation clause: if case 2 or 3 does not close, keep the landed non-strict `expandOnceUnblocked_split_card_le` and **carry strictness as an explicit hypothesis on the downstream statements** rather than narrowing the statement or dropping cases. Record which case failed and the exact goal state |
| **R3 — a later reader mistakes `hT` for `NoSplit` reintroduced under another name** | H | M | `NoSplit` *forbids* the split constructors outright, so any theorem carrying it is vacuous on branching runs. `hT` *permits* both split constructors and merely quantifies the time dimension — the same kind of hypothesis as the existing `hU : ∀ b, P b → ∀ x ∈ b, x ∈ U`, which the landed `expandBranchWithFuel_isSome_of_noSplit` already carries without anyone calling it vacuous. Phase 10 must state this distinction **in the in-source docstring**, not only here. Phase 11's branching non-vacuity witness is the mechanical check: it is what demonstrates `hT` did not silently become `NoSplit` |
| R4 — a phase needs an edit outside `file_scope` (e.g. a `findApplicableRule` lemma statable only in `Tableau.lean`, or a visibility change on `temporalCount`/`modalCount`) | M | M | Mark the phase `[BLOCKED]` and escalate per `plan-compliance.md`. Do not silently widen scope; do not substitute a different decomposition |
| R5 — the lexicographic measure fails to transcribe cleanly into `Fuel.lean` despite the research's `lean_run_code` checks | M | L | The 14 lemmas were type-checked with the project's own imports against the real repo, and all consume only the already-present BFS calculus (G3). If a statement fails to elaborate, the cause is a transcription error, not a mathematical one — re-check against research 02's stated forms before re-deriving anything |
| R6 — effort is spent proving that `identifyTime` preserves comparability | M | M | Explicitly forbidden (Non-Goals, G2). Arm 3 drops component 1 of the lexicographic measure, so nothing about the rewritten ordering is needed. Any phase reaching for it has taken a wrong turn |
| R7 — parallel dispatch collides on `Fuel.lean` | M | M | Every remaining phase (5-13) writes the same single file. The wave table below records logical dependency only; **remaining phases MUST be dispatched sequentially**, one agent run per phase |
| R8 — the frozen defaults drift | H | L | `git diff` on `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s `maxBranches := 50000` default at every phase close. All three are byte-identical today and must stay so |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2, 3, 4 | -- (landed) |
| 1 | 5, 8, 9 | 4 |
| 2 | 6 | 5 |
| 3 | 7 | 6 |
| 4 | 10 | 7, 8 |
| 5 | 11 | 9, 10 |
| 6 | 12 | 11 |
| 7 | 13 | 3, 12 |

**Sequential-dispatch constraint**: the wave table expresses logical dependency only. Unlike plan
01, whose two tracks were file-disjoint (`Saturation.lean` vs `Fuel.lean`), **every remaining phase
writes `Fuel.lean` and only `Fuel.lean`**. Phases 5, 8, and 9 are logically independent but must
still be dispatched one at a time. One agent run per phase.

---

### Phase 1: Land `saturateBlocked_isSome` from the preserved asset [COMPLETED]

**Goal**: Close two provably-dead `none` arms by lifting the already-proved, sorry-free asset into
`Saturation.lean`.

**Landed** (do not re-prove; consume): `split_fold_isSome`, `splitOrdered_fold_isSome`,
`saturateBlocked_isSome`, `saturateBlocked_ne_none`, plus the two dead-arm corollaries
`resolveOpenArm_eq_none_imp` and `buildTableau_saturateBlocked_arm_unreachable`. The scope
hypothesis held exactly: no tactic block was edited. `lean_verify` reports
`[propext, Classical.choice, Quot.sound]`.

**Timing**: 1 hour (spent)

**Depends on**: none

**Verification Tier**: local

---

### Phase 2: Blocking-aware `resolveOpenArm` [COMPLETED]

**Goal**: Swap the *literal* saturation test for the engine's *real* one at `resolveOpenArm`'s two
decision points.

**Landed** (do not revisit): both sites now use `findUnexpandedUnblocked`. The tracker decision was
corrected mid-phase: `EventualityTracker.empty` is the **permissive** extreme (because
`allEventualitiesFulfilledOrDuplicated` quantifies over `tracker.pendingAtTime`, empty under the
empty tracker, so the condition holds vacuously and *more* times count as blocked), so both sites
use `armTracker`, recomputing the arm's eventualities from the arm's own branch. No conformance
verdict flipped; the `ArmSettlingProbes` section pins the measured rows by running them.

**Carried divergence**: `resolveOpenArmCancellable` is now out of sync — see Carried Divergences
above. Not repaired here.

**Timing**: 2 hours (spent)

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

---

### Phase 3: Budget-parameterised entry point and its certificate [COMPLETED]

**Goal**: Add `buildTableauAt` alongside the frozen `buildTableau`, with a blocking-aware
certificate that is a named addition rather than a weakening.

**Landed** (do not re-prove; consume): `BudgetedTableau` (carrying the tracker as a field),
`buildTableauAt`, `BudgetedTableau.upgrade` + `upgrade_hasOpen_isSome_iff`,
`findUnexpanded_isSome_of_unblocked_isSome`, `buildTableauAt_allClosed_imp`,
`buildTableauAt_hasOpen_findClosure_none`, `BudgetedTableauProbes`. All additive;
`ExpandedTableau`, `buildTableau` and its defaults are byte-identical.

**Two findings a successor must not re-derive**:
1. The `buildTableauAt`/`buildTableau` `allClosed` **iff is FALSE**, not merely unproved. Only the
   implication that matters (`buildTableauAt` closed ⟹ `buildTableau` closed) is landed; the
   converse's failure is characterised in-source.
2. `saturateBlocked` returning `.inr` does **not** imply closure-freedom (its `fuel = 0` base case
   returns the branch unexamined). `buildTableau` shares this latent gap; it is inherited, not
   introduced.

**Timing**: 2 hours (spent)

**Depends on**: 2

**Verification Tier**: local

---

### Phase 4: Split-arm quantitative prerequisites, landed subset [COMPLETED WITH EXCLUSIONS]

**Goal** (as restated for this revision): land the split-arm quantitative facts that are *true*,
and close out the refuted one as a decided exclusion.

**Landed** (all sorry-free, `lake build` green repo-wide; do not re-prove, consume):
`expandOnceUnblocked_split_shape`, `expandOnceUnblocked_split_subset`,
`expandOnceUnblocked_split_card_le` (the **non-strict** `.split` card lemma),
`applyRule_timeLinearity_arms`, `estimateBranchDifficulty_pos`, `allocateFuelProportionally_ge`,
`totalDifficulty_le`, `applyRule_branching_arity_le`, `expandOnceUnblocked_split_arity_le`.

**Scope-hypothesis outcome (arity)**: resolved **in favour of the theorem**. `β = 3` is now proved
outright via a 36-rule case analysis of `applyRule` lifted through all three pick stages — it is no
longer a census. The literal `3` is still not baked in anywhere: `splitBudget_preserved` and its
cluster keep carrying `β` generically, and downstream phases must keep doing so.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The `.splitOrdered` twin of the split-growth lemma (plan 01 task 4.1, second half) | It is **false**, not merely hard. `timeLinearity` is the only rule producing `.branchingOrdered`; its first two arms carry the branch unchanged and its third *identifies two times*, which can only merge signed formulas. Branch cardinality is monotone-nonincreasing across an ordered split, so it cannot bound split depth — precisely the purpose task 4.1 stated for it. Permanently excluded; superseded by the lexicographic measure in Phases 5-7 | Machine-checked by the landed `applyRule_timeLinearity_arms`, which exhibits the three arms as `[(b, ord.addFuture t₁ t₂), (b, ord.addFuture t₂ t₁), (b.identifyTime t₂ t₁, ord.identifyTime t₂ t₁)]`. Corroborated by `findApplicableRule`'s own source comment: "the arms of an ordered split are replacement branches, so 'the branch already contains this arm's output' is trivially true of every arm". Full record: `plans/01_budget-totality-engine-repair.md` BLOCKER (Phase 4), and `reports/02_splitordered-measure-blocker.md` |

**Relocated, NOT excluded**: the *first* half of plan 01 task 4.1 — the **strict** `.split`
cardinality lemma — is real, unlanded work. It is not excluded and is not abandoned; it is
re-homed as **Phase 8** of this plan, which owns it in full with its own escalation clause. Only
the non-strict `≤` version landed here. A reader must not read this phase's closure as meaning the
strict lemma was done or dropped.

**Timing**: 2 hours (spent)

**Depends on**: none

**Verification Tier**: local

---

### Phase 5: Closure monotonicity calculus for the time ordering [COMPLETED]

**Goal**: Land the monotonicity facts about `futureOf`/`pastOf` under constraint extension, and the
two "the new edge is actually seen" lemmas. These are the core of the `addFuture` arms of the
lexicographic measure. All seven are VERIFIED (research 02 item groups 1-4).

**Tasks**:
- [x] Confirm the BFS calculus is present before starting (see Scope Hypothesis) and that
      `Fuel.lean:98`'s `open private reachableForward reachableBackward from …` is in force. Do not
      rebuild any of it.
- [x] Prove `pathN_mono`: `(∀ x y, y ∈ f x → y ∈ g x) → PathN f n a b → PathN g n a b`.
- [x] Prove `directFutureOf_mono` and `directPastOf_mono`: `constraints ⊆ constraints′` implies
      `directFutureOf` / `directPastOf` grows.
- [x] Prove `futureOf_mono` and `pastOf_mono`: `constraints ⊆ constraints′` implies `futureOf` /
      `pastOf` grows, **at the same fuel 100**. Route: `bfsClosure_sound` extracts a path of length
      `1 ≤ n ≤ 100`, `pathN_mono` transports it along the bigger edge set, `bfsClosure_complete`
      re-finds it at the same fuel. Research 02 measures this at ~6 lines. The fuel bound is not an
      obstacle precisely because soundness and completeness are stated at a *matching* bound — the
      same observation `orderDual_holds` already relies on.
- [x] Prove `mem_futureOf_addFuture` (`t₂ ∈ (ord.addFuture t₁ t₂).futureOf t₁`) and
      `mem_pastOf_addFuture` (`t₂ ∈ (ord.addFuture t₂ t₁).pastOf t₁`), each ~4 lines via a one-edge
      `PathN` plus `bfsClosure_complete`. Note that the *same* witness pair `(t₁, t₂)` is killed by
      arm 1 through the `futureOf` conjunct and by arm 2 through the `pastOf` conjunct, so **arm 2
      needs no appeal to `orderDual_holds`**.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that the full BFS calculus already exists in
`Fuel.lean:690-905` — specifically `PathN`, `bfsClosure`, `reachableForward_eq`,
`reachableBackward_eq`, `mem_bfsClosure_of_mem_visited`, `bfsClosure_sound`, `BfsInv`,
`bfsClosure_complete_aux`, `bfsClosure_complete`, `PathN.snoc`, `PathN.reverse`,
`mem_directFutureOf_iff`, `orderDual_holds` — and that nothing needs to be built. Confirm by
grepping each name before starting. A missing lemma materially changes this phase's sizing and must
be reported, not silently supplied.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - seven new lemmas in the BFS
  calculus region.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- `grep -c sorry` on the file still reports 0.
- No existing declaration appears in the diff except by addition.

---

### Phase 6: The incomparable-pair measure and the `addFuture` arms [NOT STARTED]

**Goal**: Define the second component of the lexicographic measure and prove it strictly decreases
at `timeLinearity`'s two `addFuture` arms. All VERIFIED (research 02 item groups 5-8).

**Tasks**:
- [ ] Prove `firstIncomparablePair_spec`: `firstIncomparablePair b ord = some (t₁,t₂)` implies
      `t₁ ∈ b.knownTimes ∧ t₂ ∈ b.knownTimes ∧ t₂ ≠ t₁ ∧ t₂ ∉ ord.futureOf t₁ ∧ t₂ ∉ ord.pastOf t₁`.
      This is the `some`-direction companion to the already-landed
      `comparable_of_firstIncomparablePair_none`, and it does not exist yet. Everything downstream
      consumes it.
- [ ] Add the two definitions, **transcribing `firstIncomparablePair`'s own test verbatim** rather
      than re-deriving it — this is deliberate, so the measure cannot drift from the trigger it is
      meant to track:
      ```lean
      def incomparableB (ord : TimeOrdering) (p : TimeIndex × TimeIndex) : Bool :=
        p.2 != p.1 && !(ord.futureOf p.1).contains p.2 && !(ord.pastOf p.1).contains p.2

      def incompPairs (b : Branch) (ord : TimeOrdering) : Finset (TimeIndex × TimeIndex) :=
        ((b.knownTimes ×ˢ b.knownTimes).filter (incomparableB ord)).toFinset
      ```
- [ ] Prove `incomparableB_mono` and `incompPairs_mono`: `constraints ⊆ constraints′` implies
      `incompPairs b ord' ⊆ incompPairs b ord`. Consume Phase 5's `futureOf_mono`/`pastOf_mono`.
- [ ] Prove `incompPairs_lt_addFuture`: on the trigger's own hypotheses,
      `(incompPairs b (ord.addFuture t₁ t₂)).card < (incompPairs b ord).card`. This covers
      `timeLinearity` arms 1 and 2, whose branch is literally unchanged. Consume
      `firstIncomparablePair_spec`, `incompPairs_mono`, and Phase 5's `mem_futureOf_addFuture` /
      `mem_pastOf_addFuture`.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - two definitions and four
  lemmas.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- `grep -c sorry` reports 0.
- `incomparableB`'s body is textually the same test as `firstIncomparablePair`'s, checkable by
  reading the two side by side.

---

### Phase 7: The identification arm and the lexicographic combination [NOT STARTED]

**Goal**: Prove the first component of the measure strictly drops at `timeLinearity`'s
identification arm, then land the lexicographic measure and its decrease theorem — the direct
replacement for the refuted lemma. All VERIFIED (research 02 item groups 9-10).

**Tasks**:
- [ ] Prove `src_not_mem_knownTimes_identifyTime`: `src ≠ tgt → src ∉ (b.identifyTime src tgt).knownTimes`.
- [ ] Prove `knownTimes_identifyTime_subset`: `tgt ∈ b.knownTimes` implies identification introduces
      no new times.
- [ ] Prove `knownTimes_card_lt_identifyTime`:
      `((b.identifyTime t₂ t₁).knownTimes).toFinset.card < (b.knownTimes).toFinset.card`.
- [ ] Define
      `splitOrderedMeasure b ord := ( b.knownTimes.toFinset.card , (incompPairs b ord).card )`.
- [ ] Prove `splitOrderedMeasure_lt_of_timeLinearity`: the measure strictly decreases in the
      lexicographic order at every arm of `applyRule .timeLinearity`, dispatching on the landed
      `applyRule_timeLinearity_arms`. Arms 1-2: component 1 equal (branch literally unchanged),
      component 2 strictly down by Phase 6. Arm 3: component 1 strictly down by
      `knownTimes_card_lt_identifyTime`.
- [ ] **Do not** prove, assume, or state anything about the `TimeOrdering` that `identifyTime`
      produces. Per G2 the lexicographic split makes it unnecessary — arm 3 is discharged entirely
      on component 1. Record this in the measure's docstring so a future reader does not go looking
      for the missing fact and conclude the proof has a hole.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that `applyRule .timeLinearity`'s arms are exactly the
three exhibited by the landed `applyRule_timeLinearity_arms`, and that `timeLinearity` is the only
rule producing `.branchingOrdered`. The first is already a theorem. Confirm the second by grepping
`branchingOrdered` across `Tableau.lean` before stating the decrease theorem; a second producer
would mean the theorem as stated is incomplete and must be reported.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - three identification
  lemmas, the measure definition, and the decrease theorem.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- `grep -c sorry` reports 0.
- `grep` confirms no lemma in this phase mentions `identifyTime`'s output *ordering* — only its
  output *branch*.

---

### Phase 8: Strict `.split` cardinality growth [NOT STARTED]

**Goal**: Land the strict version of the `.split` card lemma — the first half of plan 01's task 4.1,
relocated here. This is what bounds `.split` depth by the universe cardinality. **UNVERIFIED**:
research 02 read the guard structure from source but did not machine-check the lemma.

**Tasks**:
- [ ] Prove `expandOnceUnblocked_split_card_lt`: when `(expandOnceUnblocked b ord fc tr).1 = .split bs`,
      every `nb ∈ bs` satisfies `b.toFinset.card < nb.toFinset.card`. Three cases, because two
      predicates bypass the `.branching` containment guard:
      1. **Ordinary rules** — `findApplicableRule`'s `.branching` arm (`Tableau.lean:1924-1934`)
         rejects the result when `bss.any (fun fs => fs.all branch.contains)`, so every accepted arm
         contributes a formula the branch lacks. Direct.
      2. **`ruleSelfGuarded`** (`.untlNeg`, `.snceNeg`) — their surviving active arm mints a fresh
         time, so its output sits at a label the branch does not carry.
      3. **`ruleMintsFreshLabel`** (`.untlPos`, `.sncePos` among the branching rules) — same
         argument.
- [ ] Consume the landed `expandOnceUnblocked_split_shape` / `_split_subset` / `_split_card_le`
      rather than re-deriving the containment; only the strictness is new.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts a **three**-case decomposition, on the basis that exactly
two predicates (`ruleSelfGuarded`, `ruleMintsFreshLabel`) bypass the `bss.any` containment guard.
This count is read from source, not proved. Confirm at implementation time by enumerating the guard
bypasses before starting; a fourth bypass changes the sizing and must be reported.

**Escalation clause**: if case 2 or case 3 does not close within this phase, mark the phase
`[BLOCKED]` and report the exact goal state reached and which case failed. The sanctioned fallback
is to **keep the landed non-strict `expandOnceUnblocked_split_card_le` and carry strictness as an
explicit named hypothesis** on Phase 10's and Phase 11's statements. It is **not** sanctioned to
narrow the statement to the cases that did close, to drop a case silently, to leave a `sorry`, or
to edit `Tableau.lean` (outside `file_scope`) to reshape the guard. Per `plan-compliance.md`, a
would-be deviation on a `.lean` file is escalated, not silently annotated.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - one lemma (plus at most one
  private helper per case).

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- `grep -c sorry` reports 0.
- The landed non-strict lemma is still present and unmodified (this phase is additive).

---

### Phase 9: Split-fold preservation helpers [NOT STARTED]

**Goal**: Prove that `expandBranchWithFuel`'s two split folds preserve `isSome`, given that each arm
does — the structural half of removing `NoSplit`, separated from the quantitative half. Content
unchanged from plan 01 Phase 5.

**Tasks**:
- [ ] State and prove a fold-preservation lemma for the `.split` fold: given a starting accumulator
      that is `isSome` and a hypothesis that each arm's `expandBranchWithFuel` call is `isSome`, the
      fold's result is `isSome`. Model the shape on the landed `split_fold_isSome`, which is the
      same argument for `saturateBlocked`.
- [ ] Prove the `.splitOrdered` twin, which additionally carries each arm's own `TimeOrdering`.
      (Note: this twin is a *fold* lemma and is unaffected by the Phase 4 refutation, which was
      about branch cardinality, not fold structure.)
- [ ] Both folds pass through `resolveOpenArm` on an arm reported open. Discharge that step using
      the landed `saturateBlocked_isSome` and `resolveOpenArm_eq_none_imp` plus Phase 2's repaired
      body: state explicitly which `resolveOpenArm` outcomes are reachable and prove the `none`
      outcome does not defeat the fold under the phase's hypotheses. If `resolveOpenArm = none`
      remains genuinely reachable, that is a finding — carry it as a named hypothesis on the arm and
      report it, rather than assuming it away.
- [ ] Keep both lemmas stated over an **abstract arm hypothesis** so Phases 10-11 can supply the
      quantitative content without restating the fold reasoning.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - two fold-preservation
  lemmas.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- Each lemma is stated over an abstract hypothesis, verifiable by reading the statement: no
  `worldFuel'`, `soundFuel'`, or `NoSplit` appears in either.

---

### Phase 10: The carried time bound and the split-aware fuel figure [NOT STARTED]

**Goal**: Add the a-priori `hT` invariant to the bundle and define the fuel figure that combines
both split measures. This is where G4's residual gap is *named and carried*, not papered over.
(Research 02 items 12-13.)

**Tasks**:
- [ ] Add `hT : ∀ b, P b → b.knownTimes.toFinset.card ≤ Tmax` to the invariant bundle, alongside the
      existing `hU : ∀ b, P b → ∀ x ∈ b, x ∈ U`.
- [ ] **Write the `NoSplit` distinction into the docstring, in-source.** State plainly that `hT` is a
      *bound*, not an exclusion: `NoSplit` forbids the split constructors outright, so any theorem
      carrying it is vacuous on branching runs, whereas `hT` permits **both** split constructors and
      merely quantifies the time dimension — the same kind of hypothesis as `hU`, which the landed
      `expandBranchWithFuel_isSome_of_noSplit` already carries without anyone calling it vacuous.
      This paragraph is a required deliverable of the phase, not optional prose.
- [ ] Record, also in-source, **why a naive combination of the two measures fails**, so a future
      reader does not retry it: `.split` can mint fresh times (`untlPos`/`sncePos` are branching and
      in `ruleMintsFreshLabel`; `untlNeg`/`snceNeg` are `ruleSelfGuarded` with passive arms retired,
      so they fire only through an active arm that also mints), raising `knownTimes` and resetting
      the order measure, while `.splitOrdered` arm 3 *shrinks* the branch. A naive lexicographic
      combination therefore fails in **both** orderings. `hT` exists precisely to break this.
- [ ] Define the split-aware fuel figure over `(|U|, Tmax, β)`: `.split` depth ≤ `|U|` (Phase 8),
      `.splitOrdered` depth between fresh-time mints ≤ `Tmax + Tmax²` (Phase 7). Name it distinctly;
      **do not overload `soundFuel'` or `worldFuel'`**, both of which are frozen. Keep `β` a carried
      parameter — do not bake in the literal `3` even though `expandOnceUnblocked_split_arity_le`
      now proves it.

**Timing**: 1.5 hours

**Depends on**: 7, 8

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that `Tmax + Tmax²` bounds `.splitOrdered` depth between
fresh-time mints, given the lexicographic measure of Phase 7. Confirm by deriving it from the
measure's own range (`|knownTimes| ≤ Tmax` gives at most `Tmax` drops of component 1 and at most
`Tmax²` incomparable pairs to eliminate between drops) before writing the figure. If the derivation
gives a different exponent or a different combination, use the derived one and record the
divergence — do not write down the plan's figure unchecked.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - the `hT` invariant field,
  the split-aware fuel figure, and the two required docstring records.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- `grep` confirms `soundFuel'` and `worldFuel'` are unmodified.
- `grep` confirms the literal `3` is not baked into the figure.
- The `NoSplit`-vs-`hT` distinction paragraph is present in-source, checkable by reading.

---

### Phase 11: `NoSplit`-free totality of `expandBranchWithFuel` [NOT STARTED]

**Goal**: Land the budget-parameterised totality of `expandBranchWithFuel` with the `NoSplit`
hypothesis **deleted**, using the split-aware figure. (Research 02 items 14-15.)

**Tasks**:
- [ ] State `expandBranchWithFuel_isSome_of_budget`: same shape as the landed
      `expandBranchWithFuel_isSome_of_noSplit` but with `hP : NoSplit P fc` **deleted**, `hT` added,
      and the fuel hypothesis strengthened to Phase 10's split-aware figure. Keep the budget
      hypothesis in the `β`-linear form the landed `splitBudget_preserved` /
      `budget_le_of_betaBudget` supply — per F4 the invariant is linear, not exponential.
- [ ] Prove it by induction on fuel: the `saturated` and `extended` arms carry over from the landed
      proof; the `.split` arm discharges via Phase 9's fold lemma plus Phase 8's strict growth plus
      the landed `allocateFuelProportionally_ge`; the `.splitOrdered` arm discharges via Phase 9's
      ordered fold lemma plus Phase 7's `splitOrderedMeasure_lt_of_timeLinearity`. The allocation
      lower bound is what re-establishes the arms' progress measure that the landed proof could not
      inherit (F6: fuel decays multiplicatively down the split tree while the universe bound does
      not shrink).
- [ ] Add a **branching non-vacuity witness** in the style of the existing `noSplit_nil` /
      `expandBranchWithFuel_nil_isSome` block, but at a branch that **actually splits**. This is not
      decoration: it is the mechanical demonstration that `hT` did not silently become `NoSplit`
      (Risk R3). A theorem that only applies to unbranching runs would have removed `NoSplit` in
      name only.
- [ ] Leave the landed `expandBranchWithFuel_isSome_of_noSplit` and
      `expandBranchWithFuel_isSome_at_worldFuel'` in place. They are consumed elsewhere and this is
      an addition, not a replacement.

**Timing**: 2.5 hours

**Depends on**: 9, 10

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that the split arms close with no hypothesis beyond `hT`,
the split-aware fuel figure, and the `β`-linear budget. Confirm by inspecting the landed theorem's
statement for residual hypotheses at phase end and listing any that appeared.

**Escalation clause**: if the induction cannot be closed within the phase, mark the phase
`[BLOCKED]` and report the exact goal state reached. **Forbidden**: reintroducing `NoSplit` in any
form or under any name; weakening the statement to an unbranching special case; substituting a
different decomposition; dropping the non-vacuity witness; leaving a `sorry`. Per
`plan-compliance.md`, a would-be deviation on a `.lean` file is escalated, not silently annotated.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - the `NoSplit`-free totality
  theorem and a branching non-vacuity witness.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- `grep` confirms `NoSplit` does not appear in the new theorem's statement.
- The non-vacuity witness is at a genuinely branching branch, checkable by reading it.
- The existing `SplitFuelProbes` `#guard_msgs` rows still pass unchanged.

---

### Phase 12: Close the world dimension and discharge the carried time bound [NOT STARTED]

**Goal**: Turn the `hL`/`hww` hypotheses **and the new `hT`** from assumptions into supplied facts,
for the engine's own seed run. **This phase carries the plan's main risk (R1) and is the most likely
to block.**

**Tasks**:
- [ ] Read `chain_le_worldFuel'` and `worldFinset_card_le` and confirm the exact shape of what must
      be supplied. `chain_le_worldFuel'` carries `hww : WorldWitness C S (run n)` and its docstring
      states it is an invariant, **not discharged there** — research 02 flags this as the warning
      sign for this phase.
- [ ] Discharge `WorldWitness` along engine runs for the seed configuration `buildTableauAt` uses
      (`initialBranch = [SignedFormula.neg phi Label.initial]`, so `S.card = 1`). Scope this to the
      **seed run**, not to the general invariant.
- [ ] Derive `hL : L.card ≤ (s + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card)` at `s = 1` from
      the discharged witness via `worldFinset_card_le`, in the exact form
      `expandBranchWithFuel_isSome_at_worldFuel'` and Phase 11's theorem consume.
- [ ] **Discharge `hT` for the engine's seed run** — supply `Tmax` such that
      `b.knownTimes.toFinset.card ≤ Tmax` holds along the run. Intended source: **T2**
      (`TimeTypeBound.lean`). Research 02 explicitly did **not** verify that T2's bound is in a form
      this phase can consume; that is why this is the plan's named main risk.
- [ ] **Named fallback route for `hT`, to be taken only if T2 does not deliver**: bound fresh-time
      mints directly via the `witnessPresent` guard — each existential signed formula mints at most
      one witness, and the existential formulas live in the finite universe `U`, so the total number
      of minted times is bounded by `|U|`. This is an independent route to the same bound, at higher
      cost. Take it before escalating.
- [ ] **Named fallback route for `WorldWitness`, to be taken only if the induction over `applyRule`
      does not close**: prove the narrower statement that the *world* component of the label set
      along a seed run is bounded by the run's fresh-world-minting steps, and state precisely which
      residual remains.

**Timing**: 3 hours

**Depends on**: 11

**Verification Tier**: local

**Scope Hypothesis**: The `WorldWitness` discharge is asserted by `Fuel.lean`'s own docstring to be
a 36-case induction over `applyRule`. Confirm the case count at implementation time by enumerating
`applyRule`'s arms before starting; a materially different count changes this phase's sizing and
must be reported. Separately, this phase asserts that T2 (`TimeTypeBound.lean`) supplies a
`knownTimes` cardinality bound — that assertion is **UNVERIFIED**. Confirm by reading T2's actual
statement **first**, before writing any proof; if T2's bound is not in a consumable form, say so
explicitly and move to the fallback route rather than reshaping T2 (which is outside `file_scope`).

**Escalation clause**: if neither the primary nor the fallback route closes for `hT`, or neither
closes for `WorldWitness`, mark the phase `[BLOCKED]` and report the exact goal state and which
route was tried. The **only** sanctioned degraded outcome is to carry the undischarged item as an
**explicitly named hypothesis** on Phase 13's terminus statement, documented in-source and reported
by name in the implementation summary. The task's DONE WHEN admits "its absence is proved harmless"
— that is acceptable **only if the harmlessness is itself proved**, never asserted.

**Forbidden, absolutely**: admitting `WorldWitness` or `hT` as an `axiom`; reintroducing `NoSplit`
to manufacture a green terminus; leaving a `sorry`; substituting a vacuous placeholder that makes
the theorem trivially true; widening `file_scope` to edit `TimeTypeBound.lean` or any other file.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - `WorldWitness` discharge
  for the seed run, the `hL` derivation in consumable form, and the `hT` discharge.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` green.
- `grep -c '^axiom '` reports 0 in the file.
- The resulting lemmas' statements contain no undischarged `WorldWitness` or `hT` hypothesis — or,
  on a fallback route, contain **exactly** the explicitly named and documented residuals, each of
  which is listed by name in the phase's completion notes.

---

### Phase 13: The terminus — `buildTableauAt_isSome_of_budget` [NOT STARTED]

**Goal**: Land the task's target theorem against the repaired engine, sorry-free and with no
`NoSplit` hypothesis, and close out the register and the final gate. Content unchanged from plan 01
Phase 8.

**Tasks**:
- [ ] State and prove `buildTableauAt_isSome_of_budget`: for `phi`, `fc`, and a quantified
      `maxBranches` satisfying the `β`-linear budget condition at the split-aware fuel figure,
      `(buildTableauAt phi <fuel figure> fc maxBranches).isSome = true`.
- [ ] Discharge the top-level arms: the `expandBranchWithFuel` call via Phase 11, the
      `saturateBlocked` call via the landed `saturateBlocked_isSome`, and the two saturation tests
      via Phase 3's blocking-aware certificate. The arm that made the original `buildTableau`
      non-total (`| some _ => none` after the post-blocking pass) is exactly what Phase 3's
      certificate change eliminates; **verify that in the proof rather than assuming it**.
- [ ] State the budget side condition in a form a caller can actually discharge (the task's
      sub-obligation 3): supply a corollary at the engine's own seed with `maxBranches` given as an
      explicit closed-form expression in `phi`, so a caller reads off a number rather than a proof
      obligation.
- [ ] Append to the **do-not-re-attempt register**, as a docstring/section comment adjacent to the
      new theorem so a future reader meets it where they would otherwise re-attempt it:
      1. the unconditional `buildTableau_isSome`;
      2. `buildTableau_isSome_of_budget` in the task-description shape (`maxBranches` quantified as
         the only new hypothesis, `soundFuel' φ` as the fuel), refuted by `φ = F(G p)` at
         `fuel = 229376`, `maxBranches = 10¹²`, cause `resolveOpenArm = none`, reproduction harness
         `assets/expandDiag-instrumented-mirror.lean.txt`;
      3. the `.splitOrdered` cardinality twin of the split-growth lemma, refuted by the landed
         `applyRule_timeLinearity_arms` (see Phase 4's Reasoned Exclusions);
      4. the `buildTableauAt`/`buildTableau` `allClosed` `iff`, which is false, not merely unproved.
- [ ] Record for the consuming task (412): the replacement for the refuted `buildTableau_isSome` is
      against `buildTableauAt`/`BudgetedTableau`, **not** `buildTableau`/`ExpandedTableau`, and it
      carries a quantified budget hypothesis plus `hT` if Phase 12 had to carry it. Note this in the
      implementation summary so 412 is not planned against the wrong signature.
- [ ] Full-repo final gate.

**Timing**: 1.5 hours

**Depends on**: 3, 12

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - terminus theorem,
  caller-facing corollary, register addition.

**Verification**:
- `lake build` (full repo) green.
- `grep -c sorry` reports 0 in both `Saturation.lean` and `Fuel.lean`.
- `lean_verify` on the fully-qualified terminus theorem reports only
  `[propext, Classical.choice, Quot.sound]`.
- The theorem's statement contains no `NoSplit` hypothesis.
- All four register entries are present in-source.

---

## Testing & Validation

- [ ] `lake build` green repo-wide at Phase 13 end (and at any phase whose tier is `full`).
- [ ] Zero `sorry` in `FormalSystem/Metalogic/Decidability/Saturation.lean` and
      `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`. Both are at 0 today;
      this is a **preservation** check, not an improvement target.
- [ ] Zero `^axiom ` in both files. Both are at 0 today.
- [ ] `saturateBlocked_isSome` and `buildTableauAt_isSome_of_budget` each verify with only
      `[propext, Classical.choice, Quot.sound]`.
- [ ] The existing `SplitFuelProbes`, `ArmSettlingProbes` and `BudgetedTableauProbes` `#guard_msgs`
      rows all still pass unchanged. They pin measured behavior and must not drift.
- [ ] `buildTableau`'s signature, its `fuel := 1000` default, `expandBranchWithFuel`'s
      `maxBranches := 50000` default, and `ExpandedTableau.hasOpen`'s proof field are
      **byte-identical** to their pre-task form — verifiable by `git diff` on those declarations.
- [ ] `grep` confirms the literal split arity `3` is not baked into `splitBudget_preserved`, the
      split-aware fuel figure, or the terminus statement; `β` stays a carried parameter.
- [ ] Every phase that closes `[BLOCKED]` has its exact goal state recorded, and every carried
      residual hypothesis is named in the implementation summary.

## Artifacts & Outputs

- `specs/428_engine_totality_at_a_quantified_branch_budget/plans/02_lexicographic-splitordered-measure.md` (this file)
- `specs/428_engine_totality_at_a_quantified_branch_budget/summaries/02_lexicographic-splitordered-measure-summary.md`
- `FormalSystem/Metalogic/Decidability/Saturation.lean` — already carries Phases 1-3's additions;
  **no further edits are planned by this revision**.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` — closure monotonicity
  calculus, the incomparable-pair measure, the lexicographic `splitOrderedMeasure` and its decrease
  theorem, strict `.split` growth, fold-preservation helpers, the `hT` invariant and split-aware
  fuel figure, `NoSplit`-free `expandBranchWithFuel_isSome_of_budget`, world-dimension and `hT`
  discharge, `buildTableauAt_isSome_of_budget`, register addition.

## Rollback/Contingency

- Every remaining phase (5-13) is **purely additive**: reverting its commit restores the prior file
  state with no downstream effect, because no existing declaration is edited.
- Phase 2 was the only behavior-changing phase in the whole task and is already committed as a
  single `atomic-batch`. It is not revisited here.
- If Phase 8 blocks, Phases 5-7 and 9 stand on their own and the sanctioned fallback (carry
  strictness as a hypothesis) keeps Phases 10-13 reachable at the cost of one named residual.
- If Phase 11 blocks, Phases 1-10 stand as landed value (the repaired arm-settling, the budget entry
  point, a correct `.splitOrdered` progress measure, and the fold helpers) and the task is marked
  `[PARTIAL]` with the goal state recorded. **Do not reintroduce `NoSplit` to manufacture a green
  terminus.**
- If Phase 12 blocks after both routes, carry the undischarged item as one explicitly named
  hypothesis into the terminus statement and say so by name in the summary, rather than asserting an
  undischarged `WorldWitness` or `hT`. **Do not admit either as an axiom.**
- Under no circumstance is a green terminus manufactured by reintroducing `NoSplit`, admitting an
  unproved `WorldWitness` or `hT`, leaving a `sorry`, or narrowing a statement to a vacuous special
  case. A `[BLOCKED]` phase with an honest goal state is the correct outcome; a green-looking
  vacuous theorem is not.
