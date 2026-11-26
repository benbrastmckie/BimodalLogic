# Implementation Plan: Task #428 — Residual Verdicts and the Closability Boundary (v5)

- **Task**: 428 - engine_totality_at_a_quantified_branch_budget
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None blocking. The one dependency edge (on task 465) is discharged. Consumes
  the 21 landed modules of `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/`
  (0 `sorry`, 0 `axiom`, measured 2026-11-24), which were extended well past plan v4's close by
  tasks 463, 464, 465, 550, 554 and 804 — all archived. Tasks 412 and 430 consume this record's
  terminus and are `not_started`; Phase 5 is what tells them what is actually available.
- **Research Inputs**:
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md`
    (newly integrated; see "Research Integration" — its root-cause section is **superseded by
    source**, and this plan records why rather than carrying it forward)
  - `specs/428_engine_totality_at_a_quantified_branch_budget/plans/04_ordtimesknown-strengthening-totality.md`
    (plan v4, fully executed; holds the completion record for its 17 phases)
  - In-source, and treated as primary over every prior artifact:
    `MintBound/Register.lean` (26 do-not-re-attempt entries), `MintBound/Terminus.lean`,
    `MintBound/Measure.lean`, `MintBound/ClosureResidual.lean`, `MintBound/SeedRunTermini.lean`,
    `MintBound/BoxFree.lean`, `MintBound/README.md`
- **Artifacts**: plans/06_residual-verdicts-and-closability.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, artifact-formats.md,
  tasks.md, lean4.md, plan-compliance.md, no-task-references-in-deliverables.md
- **Type**: lean4
- **Lean Intent**: true

---

## Overview

Plan v4 closed with four named residual hypotheses on the terminus and a `blockers` field
recording them as the remaining work. **All four have since moved, and the `blockers` field no
longer describes the source.** `MintBound.lean` is now a 131-line aggregator over 21 submodules
(17,961 lines measured 2026-11-24, 0 `sorry`, 0 `axiom`): one residual is discharged outright,
two are refuted-with-repair, and the fourth's advertised repair is refutable by a witness already
sitting in the same file. This plan's job is to land the determinate verdicts that settle which
residuals are closable, run the one decisive probe the source itself names as unprobed, and record
the closability boundary plainly — so that the record becomes dispatchable without scheduling open
research as if it were implementation work.

The definition of done is **not** an unconditional terminus. It is a record whose every remaining
residual is either proved, refuted, or named as not closable with the obstruction cited, and whose
two dependents can be re-planned against what exists.

### Research Integration

`reports/05_spawn-analysis.md` (2026-08-06) is integrated here, and the integration is mostly a
**correction**, which is the honest outcome rather than a failure of the report. The report was
written against `MintBound.lean` at 4512 lines and proposed spawning the four residuals as tasks
0-3. Those tasks were in effect run (463, 464, 465), and the source has moved past the report's
root-cause section on every one of its four items:

| Report 05 item | Report's position | Source today |
|---|---|---|
| `DifficultyBounded` | "not a proof problem" — blocked on `temporalCount`/`modalCount` being `private` to `Saturation.lean`; a visibility scope decision | **Visibility framing refuted in-source.** Register entry 9: `private` blocks name resolution, not unfolding; the refuting witness is an implication between two atoms on which both counters are `0`. The predicate is **false at every `D`** by list multiplicity (`difficultyBounded_multiplicity_false`) |
| `UniverseClosed` | "a closure property ... plus, newly, the identification arm" — a 4-6 hour discharge | Clause 2 **repaired and discharged** at `signedUniverse C L` (`timeMergeClosed_identifyTime_signedUniverse`). Clause 1 **refuted**, and every `L`-side repair refuted (`freshWorldHeadroom_not_universal`); the residue is **false** at every nonempty `L` (register entries 11, 21) |
| `PostBlockingSettles` | "a genuine proof effort, not a restatement" — 6-10 hours | **Refuted** as stated (entry 22); its repair `PostBlockingSettlesRun` **refuted** (entry 25). The live narrowing `PostBlockingSettlesSeedRun` is neither proved nor refuted, with one **named, unprobed** refutation route |
| `MintPaysForTime` | "the open mathematical core ... unresolved mathematics" — 10-15 hours, hardest and last | **Discharged.** `mintPaysForTimeGap_of_any` (`MintPaysAssembly.lean`) proves the repaired residual at **every** frame class, at an arbitrary universe, **with no hypothesis at all** |

The report's dependency reasoning (four mathematically independent residuals, serialized only by
file overlap) was sound and is preserved: it is why the three spawned tasks could run as a chain.

### The one finding this plan rests on, stated before any phase

`StepLengthBounded fc U L` is the hypothesis the entire live terminus family consumes in place of
the refuted `DifficultyBounded`. Three places in source assert it is satisfiable — register entry
9 ("the settled repair is `StepLengthBounded` ... and is satisfiable"), `Terminus.lean`'s
sibling-terminus block ("it is satisfiable — `StepLengthGrowth` reduces it to a finite case
analysis over `applyRule`'s 36 arms"), and `ClosureResidual.lean`'s residual list
("`StepLengthBounded ...` — satisfiable; `difficultyBoundedAt_ceiling_at` reduces it further to
the rule-local `StepLengthGrowth`"). **No witness is exhibited at any of the three, and the
witness that refutes it is already in the file.**

`StepLengthBounded fc U L` asks every successor of every `U`-confined branch to have length `≤ L`
for one fixed `L`. `multBranch n = List.replicate n multWitness` is `U`-confined at every `n`
(`multWitness_mem_multUniverse`), and `expandOnceUnblocked_multBranch` proves the engine's step on
it is `.extended (multEmitted ++ multBranch (n + 1))` at **every** frame class and tracker, of
length `n + 3`. Taking `n := L` gives a successor of length `L + 3`. That refutes
`StepLengthBounded fc multUniverse L` for every `fc` and every `L`, by the same multiplicity
mechanism and the same witness family as `difficultyBounded_multiplicity_false`.

Two consequences, and this plan is built around them:

1. The `_lengthBudget` terminus family — including `buildTableauAt_isSome_at_seed_lengthBudget_gap_seedRun`,
   the development's current best line — carries a hypothesis no caller can supply, so it is
   vacuous for a reason the register does not yet record. The repair is not a repair.
2. The reduction the source advertises is **broken at a different point than its prose suggests**.
   `difficultyBoundedAt_ceiling` and `difficultyBoundedAt_ceiling_at` conclude
   `DifficultyBoundedAt`, not `StepLengthBounded` — a different predicate carrying an extra
   `b.length ≤ L` hypothesis — and `DifficultyBoundedAt` has **zero consumers**: it is produced by
   those two lemmas and read by nothing in the 21 modules. So landing `StepLengthGrowth fc 5`
   against the chain as it stands reaches a dead end, not a terminus.

This is exactly the class of claim this task's own description says must be machine-checked before
a plan rests on it ("This task has twice had a plan rest on an unverified lemma that later turned
out FALSE"). Phase 1 machine-checks it first, and every later phase is conditioned on the result.

### Prior Plan Reference

Plan v4 (`plans/04_ordtimesknown-strengthening-totality.md`) is fully executed: all 17 phase
headings `[COMPLETED]`, every Success Criterion it wrote down met, and criterion 11 (the terminus
being conditional) deliberately left unchecked. Nothing in it is reopened here. Its two
non-surviving premises stay recorded where they are: `BudgetedTotality` is false as stated
(`budgetedTotality_beta_zero_false`, register entry 8), and the "path figure fits, no divergence
needed" claim is withdrawn, with `splitAwareFuel_le_mintAwareFuel` recording enlargement rather
than replacement.

### Roadmap Alignment

The roadmap pass of 2026-11-25 ruled the only admissible actions were a plan revision into phases
or spawning the residuals out as separate records, and the user chose the revision. The spawn
route has in fact already been taken once (tasks 463/464/465), which is why the residual landscape
this plan addresses is not the one `reports/05_spawn-analysis.md` proposed spawning.

---

## Goals & Non-Goals

**Goals**:
- `stepLengthBounded_multiplicity_false` -- refute the hypothesis the live terminus family
  consumes, at every frame class and every `L`, by the witness family already in `Measure.lean`.
- `stepLengthGrowth_five` -- discharge the one obligation the source says is "left unproved **by
  scope decision**, not by discovery of an obstruction", from the complete 36-arm map on
  `StepLengthGrowth`'s own docstring.
- `difficultyBoundedAt_ceiling_five` -- give the reduction an unconditional form, removing
  `StepLengthGrowth` from the hypothesis list of the one predicate it actually reaches.
- Decide the post-blocking seed-run narrowing by running the probe register entry 25 names as
  unprobed, and record the verdict whichever way it falls.
- Record the closability boundary: which residuals are remaining work, which are open mathematics
  or engine-policy divergences, and what each costs the terminus -- in-source, so tasks 412 and
  430 can be re-planned against what exists rather than against a promise.

**Non-Goals**:
- The unconditional `buildTableau_isSome`. It is **false at the engine's default budget at any
  fuel**, the refutation is a property of the engine signature, and it stays on the
  do-not-re-attempt register (entry 1). Not revisited under any framing.
- Weakening any landed statement to make a phase fit. No residual hypothesis is dropped from a
  terminus without a proof that discharges it; no quantifier is specialised to make a conditional
  look closed; the branch-budget quantification is the point of this record and stays.
- **De-privatizing `temporalCount`/`modalCount`, or editing `Saturation.lean` at all.** See
  `## Decisions`, D1 -- the privacy question is settled in source and the answer is that it was
  never the obstruction.
- Editing `Fuel.lean`, `Saturation.lean`, or `Tableau.lean`. `buildTableau`, its `fuel := 1000`
  default, and `expandBranchWithFuel`'s `maxBranches := 50000` default stay untouched.
- Re-attempting anything on the 26-entry register in the positive direction: the naked
  `BudgetedTotality` (8), `DifficultyBounded` at any `D` (9), clause 2 of `UniverseClosed` (10),
  clause 1 and its `L`-side repairs (11, 21), `MintPaysForTime` as stated (14),
  `PostBlockingSettles` (22), `PostBlockingSettlesAt` (23), `PostBlockingSettlesRun` (24, 25),
  `MintPaysForTimeFixed` at `.Dense`/`.RTime` (26), and an `ArmSettlement` discharge of the entry
  point's post-blocking arm (25, too weak).
- A positive proof of `PostBlockingSettlesSeedRun`, or of clause 1's label coordinate. Both are
  named in `## Decisions` as not closable here. Phase 4 probes the first for a **refutation**; it
  does not schedule a proof.
- Repairing `resolveOpenArmCancellable` in `CancellableExpansion.lean` -- a declared,
  deliberately-unrepaired out-of-scope divergence.

**Absolute prohibitions** (a phase violating any of these is a failure, not a deviation):
- No `sorry`. No `axiom`. No `def X := True` / `:= Unit` / `:= trivial` vacuous placeholder, and
  no `noncomputable` `Decidable`-valued declaration.
- No narrowing a statement into vacuity to make it check, and no landing a terminus whose
  non-vacuity is asserted rather than exhibited. A new hypothesis must be shown satisfiable at a
  nonempty universe **before** it is stated as a repair -- the exact failure this plan's Phase 1
  exists to catch in the landed source.
- No task-number citations in any `.lean` or `.md` deliverable outside `specs/**`. Task numbers are
  fine in this plan; in-source provenance cites declaration names and section headings.

---

## Risks & Mitigations

| # | Risk | Impact | Likelihood | Mitigation |
|---|------|--------|------------|------------|
| R1 | Phase 1's refutation fails to close -- `StepLengthBounded` turns out satisfiable at `multUniverse` after all, and the whole plan's premise is wrong. | H | L | The proof is a strict prefix of `difficultyBounded_multiplicity_false`'s own proof, stopping at the length rather than continuing through `estimateBranchDifficulty_length_le`; every input (`multWitness_mem_multUniverse`, `expandOnceUnblocked_multBranch`, `length_multBranch`) is landed and public. If it nonetheless does not close, Phase 1 escalates `[BLOCKED]` with the goal state recorded and **the rest of the plan does not proceed on the assumption** -- Phases 2-3 are explicitly gated on Phase 1's verdict. |
| R2 | Phase 2's 36-arm case analysis hits the elaboration load that plan v4's R6/R8 measured on `applyRule`-wide splits (`maxHeartbeats 4000000`, 36 constructors x 2 signs). | M | M | The obligation map is already per-arm with line citations and a stated worst case (`2 + 4 * b.length`, fixing `c = 5`), so no reconnaissance is needed. If a single proof will not elaborate, split `StepLengthGrowth`'s two conjuncts into separately-proved per-result-shape lemmas before escalating -- the predicate is already a conjunction of two independent halves. |
| R3 | Phase 2 lands `stepLengthGrowth_five` and it buys nothing, because its only consumer `DifficultyBoundedAt` still has none. | M | H | **Accepted and planned for, not mitigated away.** Phase 3's whole job is to say plainly what the unconditional reduction does and does not reach, and to record the fuel-figure circularity that blocks giving `DifficultyBoundedAt` a terminus consumer. `stepLengthGrowth_five` is still worth landing: it is the one piece the source left open by scope decision rather than obstruction, and it is a prerequisite for any length-based route a future record attempts. |
| R4 | Phase 4's probe is inconclusive -- the blocked-set comparison neither exhibits a lost time nor proves monotonicity. | M | M | An inconclusive probe is a recorded outcome, not a failure: the phase closes with the measurement and a register amendment stating what was checked and what remains, and `PostBlockingSettlesSeedRun` stays a carried hypothesis with its status unchanged. It is never resolved by assertion in either direction. |
| R5 | Adding a module to `MintBound/` goes stale against the two READMEs' generated inventory blocks and their hand-written module counts. | L | H | Declared in Phase 1's file list and reconciled in Phase 5 via `check-module-invariants.sh --emit-inventory`, whose INV check fails on a stale block. The hand-written descriptions are stale **already** -- `Termination/README.md` says the aggregator "imports the 18 modules" where it imports 21 -- so Phase 5 repairs an existing defect alongside its own. |
| R6 | The plan is read as promising tasks 412 and 430 an unconditional terminus. | H | M | It does not, and Phase 5 says so in source and in the task description. The explicit statement of what 428 **cannot** deliver is a Phase 5 deliverable, not an omission. |

---

## Decisions

**D1. `Saturation.lean`'s `private` markers stay as they are, and this costs the terminus
nothing.** The `blockers` field and `reports/05_spawn-analysis.md` both record
`DifficultyBounded` as blocked on `temporalCount`/`modalCount` being `private` to
`Saturation.lean`, needing a visibility scope decision. That framing is **refuted in source**, and
the position this plan takes is the one register entry 9 and `Measure.lean`'s difficulty-toolkit
block already establish:

- `private` blocks **name resolution, not unfolding**. A bound on `estimateBranchDifficulty` is
  statable and provable from inside `MintBound/` with the markers exactly as they are, and two
  landed lemmas are the demonstration: `estimateBranchDifficulty_length_le` (proved by
  `simp only [estimateBranchDifficulty]; omega`, where the unfolding crosses the module boundary)
  and `estimateBranchDifficulty_le_of_subperm`.
- The refuting witness never touches the counters. `multWitness` is an implication between two
  atoms, so `temporalCount` and `modalCount` are both `0` on it; the entire refutation runs
  through `estimateBranchDifficulty`'s `b.length / 4` term. Making the counters public "would
  leave every step of this argument intact".
- The real obstruction is **list multiplicity**: successors are built as raw `formulas ++ b` with
  no `eraseDups`, no `Nodup` invariant on a branch exists anywhere in the development, and
  avoiding a `Nodup` side condition was a deliberate design goal. Confinement to `U` bounds only
  `b.toFinset`, never `b.length`.

So there is no de-privatization phase, and no blast radius to assess. `Saturation.lean` is not
edited, and the cost to the terminus is zero — because widening visibility would not have changed
any hypothesis on any terminus. What the terminus *does* lose is recorded under D2, and the cause
is unrelated to visibility.

**D2. The difficulty/length coordinate is named as not closable by this record, and the reason is
a fuel-figure circularity rather than a missing lemma.** After Phase 1, the position is: the
refuted `DifficultyBounded` and the refuted `StepLengthBounded` are the only two shapes any landed
terminus consumes, and `DifficultyBoundedAt` — the one shape that survives, because its extra
`b.length ≤ L` hypothesis is exactly what the multiplicity witness defeats without — has no
consumer. Giving it one requires a run-level branch-length bound, and the widest arms of
`applyRule` emit `2 + 4 * b.length`, so branch length along a run grows geometrically in the step
count: a run-level bound has the shape `5 ^ steps * (seed + 1)`. The terminus's fuel figure
`mintAwareFuel U.card Tmax mintBudget D β` takes `D` as an argument, and `D` would then be
`difficultyCeiling U (5 * L + 5)` with `L` geometric in the very fuel figure being derived. That
is a circularity of the same class as plan v4's R3, and of the same class as the split-arm fuel
scaling `Fuel.lean` documents as "a real property of a deliberate engine policy, not a gap in a
proof". Phase 3 records this as a register entry rather than attempting to break it; breaking it
would require weakening the engine's own proportional-fuel policy, which the task's realignment
addendum forbids and whose correct deliverable is the ASSESS-and-C9-register outcome that addendum
sanctions.

**D3. Clause 1 of `UniverseClosedAt` — the label coordinate — is open mathematics and gets no
phase.** This is the requirement to name what cannot be closed rather than schedule a phase that
will stall. The accounting is complete and the residual still does not fall:

- Clause 1 is **refuted** at a fixed finite `signedUniverse C L` (`universeClosed_fresh_world_escapes`,
  `universeClosedAt_fresh_world_escapes`): `.boxNeg` and `.diamondPos` emit only at
  `Branch.nextWorld`, which is fresh, at every frame class and every tracker.
- **Every `L`-side repair is refuted before it is written** (`freshWorldHeadroom_not_universal`):
  each enlargement of `L` raises the reachable `maxWorld` at least as much as it adds.
- The carried residue `UnorderedSuccessorLabelClosed` is not merely un-discharged but **false** at
  every nonempty finite `L`, with satisfiability set exactly `{∅}`
  (`unorderedSuccessorLabelClosed_nonempty_false`, `unorderedSuccessorLabelClosed_empty`) — and
  `signedUniverse C ∅ = ∅`, so the only label set at which it is available is the one at which the
  universe is empty. Nine landed theorems carry it and are vacuous at every nonempty `L`.
- The one replacement route that reaches further bites on the **stock** rather than on `L`
  (`BoxFree.lean`), and `boxFree` together with `untlSnceFree` collapses the stock to the purely
  propositional fragment — forced, not a proof weakness, since both world-minting rules are gated
  on a `.box` node. That composite is itself vacuous: `tableauClosed_untlSnceFree_false` decides
  that `TableauClosed C` and `∀ φ ∈ C, untlSnceFree φ` cannot both hold, because `serialityRule`
  emits `T(F⊤)` from no trigger and `Formula.someFuture ⊤` is `⊤ untl ⊤`.

Register entry 21 names exactly two openings that are unattempted **and** unrefuted: a
stock-closure predicate weaker than `TableauClosed`, not demanding `serialityRule`'s two outputs,
with `unorderedSuccessor_formula_mem` re-derived at it; or a shape condition weaker than
`untlSnceFree` admitting `⊤ untl ⊤` while still excluding the five arms entry 16 names. Both are
research with an uncertain outcome, and both are capped at a fragment that excludes `□` — which is
not what tasks 412 and 430 need. Scheduling either as an implementation phase would produce a
stalled phase, so neither is scheduled. Phase 5 records the boundary instead.

**D4. `MintPaysForTime` is closed and is not work.** `mintPaysForTimeGap_of_any` discharges the
repaired residual at every frame class, at an arbitrary universe, with no hypothesis. The
`blockers` field's "genuine open research" and report 05's 10-15 hour task are both obsolete. No
phase addresses it; Phase 5 records that it is discharged so no future record re-opens it.

**D5. `ArmSettlement` and `PostBlockingSettlesSeedRun` are probed together, because they are the
same mechanism.** `ArmSettlement`'s own docstring locates its gap as "a disagreement between two
eventuality trackers ... closing the gap means comparing the two blocked sets — not adding fuel",
and register entry 25's cheapest probe against `PostBlockingSettlesSeedRun` is a blocked-set
comparison: "does `blockedTimes satBr satOrd fc (armTracker satBr)` ever lose a time that
`blockedTimes ob oOrd fc (armTracker ob)` held?". One measurement serves both. This matters
because `ArmSettlement` is carried bare on both seedRun lines — its only producer,
`armSettlement_of_postBlockingSettles`, needs the refuted `PostBlockingSettles` — so it is a fifth
residual that the four-residual framing omits.

---

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

All new declarations land in **one new submodule**,
`MintBound/ResidualVerdicts.lean`, placed at the bottom of the import DAG (importing
`SeedRunTermini`, the deepest existing join, so it can see every predicate it reasons about).
No existing module's declarations are edited; edits to existing modules are confined to docstring
and register prose, which Phase 5 owns.

### Phase 1: The refutation that settles the length coordinate [NOT STARTED]

- **Goal**: Machine-check, before anything is built on it, that `StepLengthBounded` — the
  hypothesis every live terminus consumes — is false at `multUniverse` at every frame class and
  every `L`, and record that `DifficultyBoundedAt` has no consumer.
- **Tasks**:
  - [ ] Create `MintBound/ResidualVerdicts.lean` with the standard copyright header, importing
        `MintBound.SeedRunTermini`, in namespace `FormalSystem.Metalogic.Decidability` with
        `open FormalSystem.Syntax`. Add its import to the aggregator `MintBound.lean`.
  - [ ] Prove `stepLengthBounded_multiplicity_false (fc) (L) : ¬ StepLengthBounded fc multUniverse L`.
        The proof is a prefix of `difficultyBounded_multiplicity_false`'s: instantiate
        `StepLengthBounded` at `multBranch (L + 1)` with `TimeOrdering.empty` and
        `EventualityTracker.empty`, take confinement from `multWitness_mem_multUniverse` via
        `List.eq_of_mem_replicate`, take the successor from `expandOnceUnblocked_multBranch L fc`,
        rewrite its length by `length_multBranch` and `multEmitted`'s own two elements, and close
        with `omega` on `L + 3 ≤ L`. Do **not** route through `estimateBranchDifficulty` — the
        point of this lemma is that the length coordinate falls on its own.
  - [ ] Confirm mechanically that the refutation is not frame-class-local: the statement quantifies
        `fc`, and `expandOnceUnblocked_multBranch` and `findApplicableRule_multWitness` are both
        proved at every `fc`. Record the confirmation in the lemma's docstring.
  - [ ] Verify by `grep` over all 21 modules that `DifficultyBoundedAt` is read by nothing —
        expected hits are its `def` in `Measure.lean` and the two producing lemmas
        `difficultyBoundedAt_ceiling` (`Measure.lean`) and `difficultyBoundedAt_ceiling_at`
        (`ClosureResidual.lean`), and no consumer. Record the enumeration in the new module's
        header docstring, by declaration name.
  - [ ] Run `lean_verify` on the new lemma: fully qualified name, 0 `sorry`, axioms within
        `[propext, Classical.choice, Quot.sound]`.
  - [ ] **Gate**: if the lemma does not close, stop and escalate `[BLOCKED]` with the goal state
        recorded. Phases 2, 3 and 5 are conditioned on this verdict and must not proceed on the
        assumption.
- **Timing**: 2-3 hours
- **Depends on**: none
- **Verification Tier**: interface
- **Tier Justification**: the edit adds one module and one aggregator import, so the blast radius
  is the new module plus the aggregator and its direct dependents, covered by
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound`
  — no existing declaration's signature changes, so no transitive re-check is owed.
- **Scope Hypothesis**: that `DifficultyBoundedAt` has exactly three occurrences across the 21
  modules and zero consumers (carried from this plan's own Overview measurement of 2026-11-24, not
  from a prior record); confirmed at implementation time by the `grep` task above, and if a
  consumer is found, Phase 3's premise changes and Phase 3 must be re-scoped before it is entered.
- **Files to modify**:
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ResidualVerdicts.lean` - new module; the refutation and the consumer enumeration
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` - one added import
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md` - module table gains a row (line/decl counts are machine-owned; reconciled in Phase 5)
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/README.md` - generated inventory block and the stale aggregator description (reconciled in Phase 5)

### Phase 2: `StepLengthGrowth fc 5` — the 36-arm obligation discharged [NOT STARTED]

- **Goal**: Discharge the one obligation the development left open by scope decision rather than
  by obstruction, from the complete per-arm map already recorded on `StepLengthGrowth`'s docstring.
- **Tasks**:
  - [ ] Transcribe the obligation map from `StepLengthGrowth`'s docstring rather than re-deriving
        it: constant arms (`.andPos`, `.orNeg`, `.impNeg` at 2; `.andNeg`, `.orPos`, `.impPos` at 1
        per arm; `.negPos`, `.negNeg` at 1; `.boxTemporal` and `.serialityRule` at most 2;
        `.orderTrichotomy` at 2 per arm; `.denseIndicatorClosure` at 0; the six `.persistent`
        rules at 1); branch-mapped arms (`.boxPos`, `.diamondNeg` at most `b.length`; `.boxNeg`,
        `.diamondPos` at most `1 + 2 * b.length`; `.densityRule` at most `1 + b.length`; the four
        `allFutureNeg`/`allPastNeg`/`someFuturePos`/`somePastPos` at most `1 + 4 * b.length`; the
        `.branching` arms of `.untlPos`/`.sncePos`/`.untlNeg`/`.snceNeg` at most `2 + 4 * b.length`,
        the widest and what fixes `c = 5`); the four ordering-driven arms, which is where
        `RunInvariant`'s `OrdTimesKnown` is consumed to put every `futureOf`/`pastOf` element in
        `b.knownTimes`; and `.timeLinearity`, benign because all three arms are at most `b.length`.
  - [ ] Prove the two conjuncts of `StepLengthGrowth fc 5` — the unordered-successor half and the
        `.splitOrdered` half — as separate named lemmas first, then assemble. Proving them
        separately is not optional decomposition: it is the R2 mitigation, since the predicate is
        already a conjunction of two independent halves and a single combined proof carries the
        full 36 x 2 elaboration load.
  - [ ] Land `stepLengthGrowth_five (fc) : StepLengthGrowth fc 5`.
  - [ ] Record the measured elaboration cost and any `set_option maxHeartbeats` figure actually
        needed, in the lemma's docstring. Do not raise `maxHeartbeats` above the figure measured
        for `applyRule`-wide splits elsewhere in the tree without recording why.
  - [ ] `lean_verify`: 0 `sorry`, axioms within the permitted three.
  - [ ] **Conditioned on Phase 1**: enter only if Phase 1's refutation landed. If Phase 1 escalated,
        this phase does not run.
- **Timing**: 5-7 hours
- **Depends on**: 1
- **Verification Tier**: local
- **Tier Justification**: every declaration is added to `ResidualVerdicts.lean` with no change to
  any existing signature, so a build of that one module covers it:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.ResidualVerdicts`.
- **Scope Hypothesis**: that `applyRule` has 36 arms and that `c = 5` suffices, with
  `2 + 4 * b.length` the widest emission — carried from `StepLengthGrowth`'s own in-source
  obligation map in `MintBound/Measure.lean`, not independently re-derived at plan time. Confirmed
  at implementation time by the transcription task above, arm by arm against `Tableau.lean`'s
  source; if any arm's emission exceeds the map's figure, widen `c` (it is a parameter, so nothing
  downstream restates) and record the correction on the lemma's docstring rather than narrowing
  the predicate.
- **Files to modify**:
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ResidualVerdicts.lean` - the two half-lemmas and `stepLengthGrowth_five`

### Phase 3: The unconditional reduction, and the circularity that stops it [NOT STARTED]

- **Goal**: Give the surviving reduction an unconditional form, and record precisely why that form
  still has no terminus consumer — so the boundary is a cited obstruction rather than an absence.
- **Tasks**:
  - [ ] Land `difficultyBoundedAt_ceiling_five (fc) {U} {L} (hUcl : UniverseClosedAt fc U) :
        DifficultyBoundedAt fc U L (difficultyCeiling U (5 * L + 5))`, as
        `difficultyBoundedAt_ceiling_at (stepLengthGrowth_five fc) hUcl`.
  - [ ] State plainly in its docstring what it is **not**: it retains `hUcl`, and
        `UniverseClosedAt`'s clause 1 is refuted at every nonempty `signedUniverse C L` (register
        entries 11, 21), so this corollary is not a non-vacuity claim about anything. Naming that
        in the docstring is required, not optional — an unqualified "unconditional" reading is the
        precise defect D3 and Phase 1 exist to catch.
  - [ ] Derive and record the run-level length consequence: from `stepLengthGrowth_five`, a branch
        reachable in `n` engine steps from a seed of length `s` has length at most
        `5 ^ n * (s + 1)`. Land it as a lemma if it closes cheaply by induction on `n`; if it does
        not, record the arithmetic in the register entry below rather than carrying a half-proved
        lemma.
  - [ ] Write register entry 27 in `MintBound/Register.lean`, in the register's established style
        (statement, verdict, cause in one line, refuting witness where one exists, settled repair
        or named boundary): the `StepLengthBounded` refutation from Phase 1, the zero-consumer fact
        about `DifficultyBoundedAt`, and the fuel-figure circularity of D2 — `D` would be
        `difficultyCeiling U (5 * L + 5)` with `L` geometric in the very fuel figure
        `mintAwareFuel ... D ...` being derived. Cite the three prose sites that assert
        `StepLengthBounded` is satisfiable, by declaration and section name, as corrected by
        Phase 5.
  - [ ] `lean_verify` on every new declaration.
  - [ ] **Conditioned on Phase 1 and 2**: if Phase 1 escalated, or Phase 2 did not land
        `stepLengthGrowth_five`, this phase closes `[COMPLETED WITH EXCLUSIONS]` with a
        `#### Reasoned Exclusions` record citing the blocking phase's measurement, and Phase 5
        records the boundary from Phase 1's verdict alone.
- **Timing**: 3-4 hours
- **Depends on**: 2
- **Verification Tier**: local
- **Tier Justification**: the corollary and lemma land in `ResidualVerdicts.lean` and the register
  entry is prose in a module that carries no declarations and that nothing imports except the
  aggregator, so a build of those two modules covers it:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.ResidualVerdicts`.
- **Scope Hypothesis**: that `Register.lean` currently holds 26 entries, so the new one is entry 27
  — carried from `MintBound/README.md`'s module table and the register's own header, both read
  2026-11-24. Confirmed at implementation time by the numbered-entry enumeration in
  `Register.lean`; if the count differs, number the new entry from the actual maximum rather than
  from this figure.
- **Files to modify**:
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ResidualVerdicts.lean` - `difficultyBoundedAt_ceiling_five` and the run-level length lemma
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Register.lean` - entry 27

### Phase 4: The blocked-set probe — deciding the post-blocking narrowing [NOT STARTED]

- **Goal**: Run the one probe register entry 25 names as unprobed, and decide
  `PostBlockingSettlesSeedRun` and `ArmSettlement` — the same tracker-disagreement mechanism —
  whichever way the measurement falls.
- **Tasks**:
  - [ ] Build the probe entry 25 specifies: for engine exits `ob`, does
        `blockedTimes satBr satOrd fc (armTracker satBr)` ever lose a time that
        `blockedTimes ob oOrd fc (armTracker ob)` held? Mechanise it as a `#guard_msgs`-checked
        evaluation over concrete branches, in the style `postBlockingRunProbe` already uses in
        `MintBound/PostBlocking.lean`, rather than as an asserted argument.
  - [ ] Drive the probe along the route entry 25 names: `saturateBlocked` may **extend** `ob`, and
        `expandOnceNoFresh` ignores blocking entirely, so it can do label-free work at a blocked
        time; the formulas it adds can break `isSubsetBlocked` (or `timeSaturated` at the ancestor)
        and thereby unblock a time carrying label-minting work that `expandOnceNoFresh` itself
        skips. Start from `seedBranch` exits, as `pbrWitnessBranch` does, and at the empty tracker
        — the seed narrowing fixes `tr := EventualityTracker.empty`, which is what kills entry 25's
        own doctored-tracker witness.
  - [ ] **If the probe exhibits a lost time**: land the refutation
        `postBlockingSettlesSeedRun_*_false` at whichever frame class the witness is found, note
        that refuting at one frame class refutes the predicate, and amend register entry 25 to
        record the route as probed and the verdict as negative. The eight `_fixed_seedRun` /
        `_gap_seedRun` members then join the vacuous list, which Phase 5 records. This is the
        ASSESS-and-C9-register outcome the task's realignment addendum sanctions as a **valid,
        complete** result — the post-blocking arm is then an engine-policy divergence of the same
        class as the settled `buildTableau_isSome` refutation, and a C9 register entry naming
        which theorem carries the exposure and under what hypothesis is the deliverable. Do not
        force past it by weakening `NoSplit`, reintroducing a forbidden hypothesis, or narrowing a
        statement into vacuity.
  - [ ] **If the probe exhibits no lost time**: land the monotonicity fact the probe supports, at
        exactly the generality measured and no wider, and amend entry 25 to record the route as
        probed with a negative result for the refutation. A positive proof of
        `PostBlockingSettlesSeedRun` is **not** attempted here — it is open research, it is named
        as such in Phase 5, and an `ArmSettlement` discharge of the entry point's post-blocking arm
        stays barred by entry 25 as strictly too weak.
  - [ ] **If the probe is inconclusive**: close with the measurement recorded and entry 25 amended
        to state what was checked and what remains. R4's mitigation. Never resolve by assertion.
  - [ ] Record, in all three branches, that `ArmSettlement` is a fifth carried residual with no
        available producer (its only one, `armSettlement_of_postBlockingSettles`, needs the refuted
        `PostBlockingSettles`), and what the probe decided about it.
- **Timing**: 3-4 hours
- **Depends on**: 1
- **Verification Tier**: local
- **Tier Justification**: the probe and any resulting declaration land in `ResidualVerdicts.lean`
  with the register amendment in `Register.lean`, neither of which any module but the aggregator
  imports, so a build of those covers it:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.ResidualVerdicts`.
- **Scope Hypothesis**: that `PostBlockingSettlesSeedRun` is currently carried by exactly eight
  landed termini (the `_fixed_seedRun` line at S1-S4 and the `_gap_seedRun` line at S1-S4, across
  `MintBound/PostBlocking.lean` and `MintBound/SeedRunTermini.lean`) — carried from
  `SeedRunTermini.lean`'s own header and register entry 25, read 2026-11-24. Confirmed at
  implementation time by enumerating the predicate's occurrences across the 21 modules; the
  vacuity consequence Phase 5 records must cover whatever set is actually found, not this figure.
- **Files to modify**:
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ResidualVerdicts.lean` - the probe and whichever declaration the verdict forces
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Register.lean` - entry 25 amended with the probe's verdict

### Phase 5: The closability boundary, the corrections, and the full gate [NOT STARTED]

- **Goal**: Leave the record honest and dispatchable — every remaining residual proved, refuted, or
  named as not closable with its obstruction cited; every prose site that asserts otherwise
  corrected; and tasks 412 and 430 told what actually exists.
- **Tasks**:
  - [ ] Correct the three prose sites that assert `StepLengthBounded` is satisfiable, each to state
        the refutation and cite `stepLengthBounded_multiplicity_false`: register entry 9's "settled
        repair" paragraph in `Register.lean`; the sibling-terminus block in `Terminus.lean`; and
        the residual list on `buildTableauAt_isSome_of_lengthBudget_signedUniverse` in
        `ClosureResidual.lean`. Also correct `Measure.lean`'s difficulty-toolkit block, where the
        same claim sits beside `StepLengthGrowth`'s obligation map. Leaving any of these standing
        would reproduce exactly the drift this plan was written to catch.
  - [ ] Correct `difficultyBounded_multiplicity_false`'s own closing docstring sentence, which
        names `StepLengthBounded` as "the repaired hypothesis" on the strength of
        `stepLengthBounded_of_difficultyBounded` — a direction that shows the exchange loses
        nothing, never that the repair is satisfiable.
  - [ ] Write the **vacuity audit** into `ResidualVerdicts.lean`'s header: for every terminus in
        the 21 modules, which co-hypothesis makes it vacuous and by which refuting witness. Cover
        at minimum the `DifficultyBounded` line (entry 9), the `UnorderedSuccessorLabelClosed`
        carriers (entries 11, 21 — nine theorems), the `_lengthBudget` family (Phase 1's
        refutation), the `PostBlockingSettles` and `PostBlockingSettlesRun` lines (entries 22, 24,
        25), and the seedRun family per Phase 4's verdict. State explicitly that
        `MintPaysForTimeGap` is **discharged** (`mintPaysForTimeGap_of_any`) and is not a residual,
        so no future record re-opens it.
  - [ ] Write the closability boundary, by residual, in the same header: the length coordinate
        (D2 — not closable, fuel-figure circularity, register entry 27); the label coordinate
        (D3 — not closable, refuted at every nonempty `L`, with entry 21's two unattempted and
        unrefuted openings named and their fragment ceiling stated); the post-blocking coordinate
        (Phase 4's verdict); the minting coordinate (discharged). Name which are remaining work and
        which are open mathematics, and do not blur the two.
  - [ ] Add the C9 register entry the realignment addendum calls for if Phase 4 refuted the
        narrowing: which theorem still carries the split-arm scaling or post-blocking exposure, and
        under what hypothesis.
  - [ ] Update task 428's own description in `specs/state.json` to state what this record can and
        cannot deliver, and that tasks 412 and 430 must be re-planned against the conditional
        termini and their fragments rather than against an unconditional
        `buildTableauAt_isSome_of_budget`. The durable carrier is the task description and this
        plan, never a dispatch-created sidecar.
  - [ ] Reconcile the coupled generated surfaces: run
        `bash scripts/check-module-invariants.sh --emit-inventory` to rewrite the machine-owned
        columns of both READMEs' inventory blocks, and repair the hand-written descriptions by
        measurement — `Termination/README.md` currently says the aggregator "imports the 18
        modules" where it imports 21, and the MintBound row's module count and the
        `MintBound/README.md` module table both move with the new submodule. Confirm the INV check
        is green afterwards.
  - [ ] Final verification: full-project build green; 0 `sorry` and 0 `axiom` across the MintBound
        tree; `#print axioms` on every new declaration within `[propext, Classical.choice,
        Quot.sound]`; `Fuel.lean`, `Saturation.lean` and `Tableau.lean` unmodified relative to this
        task's branch point.
- **Timing**: 3-4 hours
- **Depends on**: 3, 4
- **Verification Tier**: full
- **Files to modify**:
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ResidualVerdicts.lean` - the vacuity audit and the closability boundary
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Register.lean` - entry 9 corrected; the C9 entry if Phase 4 refuted the narrowing
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Terminus.lean` - the sibling-terminus block's satisfiability claim corrected
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ClosureResidual.lean` - the residual list's satisfiability claim corrected
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Measure.lean` - the difficulty-toolkit block and `difficultyBounded_multiplicity_false`'s closing sentence corrected
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md` - module table reconciled by measurement
  - `FormalSystem/Metalogic/Decidability/Verified/Termination/README.md` - inventory block and stale aggregator description reconciled
  - `specs/state.json` - task 428's description updated with what the record delivers and what 412/430 must be re-planned against

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.ClosureResidual

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

theorem stepLengthBounded_multiplicity_false (fc : FormalSystem.ProofSystem.FrameClass)
    (L : Nat) : ¬ StepLengthBounded fc multUniverse L := sorry

theorem stepLengthGrowth_five (fc : FormalSystem.ProofSystem.FrameClass) :
    StepLengthGrowth fc 5 := sorry

theorem difficultyBoundedAt_ceiling_five (fc : FormalSystem.ProofSystem.FrameClass)
    {U : Finset SignedFormula} {L : Nat} (hUcl : UniverseClosedAt fc U) :
    DifficultyBoundedAt fc U L (difficultyCeiling U (5 * L + 5)) := sorry

end FormalSystem.Metalogic.Decidability
```

The three identifiers above are exactly the three named under `- **Goals**:`, and no others. The
other two Goals bullets — the post-blocking verdict and the closability boundary — commit to a
measurement and a record rather than to a theorem whose statement is determinate at plan time:
Phase 4's deliverable is a `#guard_msgs`-checked probe plus whichever declaration the verdict
forces, and which of those two it is cannot honestly be pinned before the probe runs. Pinning a
signature here for a theorem whose polarity the measurement decides would be a prediction dressed
as a contract.

---

## Testing & Validation

- Per-phase scoped build through the repository's own guard, never bare `lake`:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.ResidualVerdicts`,
  checking the guard's exit status rather than a stdout diff.
- `lean_verify` on every new declaration, by fully qualified name: 0 `sorry`, and axioms within
  `[propext, Classical.choice, Quot.sound]`.
- `grep`-level confirmation that the MintBound tree carries no real `sorry` and no `axiom`. The
  three current `sorry` matches (`Register.lean`, `TimeCensus.lean`, `UntlSnceFree.lean`) are all
  prose mentions inside docstrings, measured 2026-11-24; the check is that this stays true and that
  no new match is a declaration body.
- `bash scripts/check-module-invariants.sh` — the INV check must be green at Phase 5, after
  `--emit-inventory` has rewritten the machine-owned README columns.
- Full-project build at Phase 5:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`.
- Frozen-file check at Phase 5: `git diff --stat` shows no change to
  `FormalSystem/Metalogic/Decidability/Saturation.lean`,
  `FormalSystem/Metalogic/Decidability/Tableau.lean`, or
  `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`.
- Independence obligation: the vacuity audit's enumeration of which termini are vacuous must not
  be confirmed by re-running the same `grep` pattern that produced it. Confirm each entry by
  reading the named refuting witness's statement, not by re-matching the predicate name.

---

## Artifacts & Outputs

- `specs/428_engine_totality_at_a_quantified_branch_budget/plans/06_residual-verdicts-and-closability.md`
  (this plan)
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ResidualVerdicts.lean`
  (new module: the refutation, `stepLengthGrowth_five`, the unconditional reduction, the probe, the
  vacuity audit, the closability boundary)
- Amendments in place: `MintBound/Register.lean` (entry 9 corrected, entry 25 amended, entry 27
  added, C9 entry if Phase 4 refutes), and the corrected satisfiability claims in
  `MintBound/Terminus.lean`, `MintBound/ClosureResidual.lean`, `MintBound/Measure.lean`
- Reconciled: `MintBound/README.md`, `Verified/Termination/README.md`
- `specs/428_engine_totality_at_a_quantified_branch_budget/summaries/06_residual-verdicts-and-closability-summary.md`
  (written at completion)
- Task 428's description in `specs/state.json`, stating what the record delivers and what tasks 412
  and 430 must be re-planned against

---

## Rollback/Contingency

Every phase is purely additive to one new module plus docstring and register prose in existing
ones, so rollback is per-commit revert — no landed declaration is deleted, renamed, or restated,
and no frozen file is touched. The phases commit per green sub-step, so a failed phase leaves the
preceding ones intact.

The contingency that matters is not a tree rollback but a verdict:

- **Phase 1's gate fails.** The plan's premise is wrong. Escalate `[BLOCKED]` with the goal state,
  and do not run Phases 2, 3 or 5 on the assumption. The correct next step is a research dispatch
  on `StepLengthBounded`'s actual satisfiability, not another plan revision.
- **Phase 2 will not elaborate.** Split the two conjuncts further, per R2. If it still will not
  close, Phase 2 escalates `[BLOCKED]` and Phase 3 closes
  `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record citing Phase 2's
  measurement. Phase 5 still runs: the boundary from Phase 1's verdict alone is the deliverable
  that unblocks the dependents, and it does not depend on Phase 2.
- **Phase 4 refutes the narrowing.** This is a success, not a contingency — the ASSESS-and-C9-register
  outcome the realignment addendum names as valid and complete. Record it and stop; do not force a
  proof past it.
- **The record closes with residuals still open.** Expected, and the intended terminus of this
  plan. The task's resting status is `[PARTIAL]`, not `[COMPLETED]`, and Phase 5's boundary record
  is what makes that partial status actionable rather than merely unfinished.
