# Implementation Plan: Task #428 — Route (b), the Mint Bound (v4, `OrdTimesKnown` strengthening)

- **Task**: 428 - engine_totality_at_a_quantified_branch_budget
- **Status**: [IMPLEMENTING]
- **Effort**: 27 hours (22 carried from plan 03, of which ~11 are already spent on landed phases; +5 for the Phase 4 repair)
- **Dependencies**: None blocking. Consumes phases 1-10 of
  `plans/02_lexicographic-splitordered-measure.md` (landed, sorry-free, axiom-free, green), the
  27 machine-checked lemmas in `scratch/04_witness-preservation.lean`, and the **nine**
  machine-checked results in `scratch/05_ordtimesknown-repair-check.lean` (commit `7f3c7dcb5`,
  sorry-free, elaborates exit 0). Coordinates with task 426 — see "The `Fuel.lean` placement
  decision" in the Overview, which resolves the hazard by not editing `Fuel.lean` at all.
- **Research Inputs**:
  - `specs/428_engine_totality_at_a_quantified_branch_budget/scratch/05_ordtimesknown-repair-check.lean`
    (**primary for the Phase 4 repair — nine machine-checked results, transcribe rather than re-derive**)
  - `specs/428_engine_totality_at_a_quantified_branch_budget/plans/03_mint-bound-irreflexivity-totality.md`
    (the superseded plan; **holds the full completion record for phases 1-3, 5-7 and the Phase 4
    blocker record** — this file compresses those records and points here for the detail)
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/04_witness-preservation-machine-checked.md`
    (27 machine-checked lemmas; still ground truth for phases 5-7)
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/03_phase11-potential-obstruction.md`
    (route-(a) refutation and the section-4 impossibility proof remain load-bearing)
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/01_budget-totality-refuted-and-repair.md`,
    `reports/02_splitordered-measure-blocker.md`
  - In-source refutation: `ordTimes_identifyTime_arm3_false` (`MintBound.lean:1217`), decided,
    axioms `[propext]`
- **Artifacts**: plans/04_ordtimesknown-strengthening-totality.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, artifact-formats.md,
  lean4.md, plan-compliance.md, no-task-references-in-deliverables.md
- **Type**: lean4
- **Lean Intent**: true

---

## Overview

This is a **revision of `plans/03_mint-bound-irreflexivity-totality.md`**, not a new plan. Plan 03
is 6/14 phases complete and green; Phase 4 blocked on a machine-checked refutation, and a follow-up
dispatch machine-checked the repair. This file folds the repair in. Plan 03 is **not edited** — it
holds the completion record for phases 1-3, 5-7 and the Phase 4 blocker record, and remains the
citable source for the detail this file compresses.

Route (b) — an independent bound on the number of fresh-time **mints** — is still the user-approved
path and nothing about it changes. The plan still lands in four blocks: (A) the engine-level
irreflexivity invariant; (B) the witness preservation stack; (C) a restatement of
`expandBranchWithFuel_isSome_of_budget` carrying an explicit mint budget; (D) the amortized counting
chain and the terminus `buildTableauAt_isSome_of_budget`.

Phase mapping: **A** = Phases 1-4 (now 1-3 plus 4, 4.1, 4.2, 4.3), **B** = Phases 5-8,
**C** = Phase 10, **D** = Phases 9, 11-14.

### What changed relative to plan 03

Exactly one thing changed, and it changed for a machine-checked reason.

**The refutation** (settled; do not re-litigate). `OrdTimesLeMaxTime` is **not preserved** by the
ordered split's identification arm (`timeLinearity`, arm 3). This is in-source at
`MintBound.lean:1217` as `ordTimes_identifyTime_arm3_false`, decided, axioms `[propext]`.
Refuting configuration: `b = [T p @(0,0), T q @(0,5)]`, `ord = ⟨[(3,4)]⟩`. The same theorem also
decides `firstIncomparablePair b ord = some (0,5)`, so it is a **genuinely reachable trigger** with
both standing hypotheses (`IrreflOrd`, `OrdTimesLeMaxTime`) satisfied — the failure is attributable
to the arm, not to a violated precondition. Root cause: `Branch.identifyTime` can *lower*
`Branch.maxTime` (5 → 0) while `TimeOrdering.identifyTime` leaves a constraint not mentioning `t₂`
untouched, so the invariant measures ordering times against a bound the arm is free to move
downward underneath them.

**The verified repair**: strengthen to

```lean
def OrdTimesKnown (b : Branch) (ord : TimeOrdering) : Prop :=
  ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes
```

— "every ordering time is a *known branch time*", rather than "every ordering time is
`≤ b.maxTime`".

### Research Integration

`scratch/05_ordtimesknown-repair-check.lean` (commit `7f3c7dcb5`, nine results, sorry-free,
elaborates exit 0) is the primary input for the repair. **Phase 4.1 is transcription of already-
elaborated Lean, not new proof.** The nine results, cited by the names the implementer must
transcribe:

| Scratch declaration | What it settles |
|---|---|
| `ordTimesKnown_identifyTime` | **Arm-3 preservation.** Needs **no trigger hypotheses at all** — not `firstIncomparablePair`, not `IrreflOrd`. A pure structural fact: branch and ordering relabel by the same `rho`. |
| `ordTimesLeMaxTime_of_ordTimesKnown` | The strong form implies the weak one. This is what makes the change a **strengthening**, not the forbidden weakening. |
| `counterexample_dies` | The refuting configuration fails the new invariant at its input, so it is not a counterexample to the strong form. |
| `applyRule_ordTimesKnown_nonbranching` | The strong invariant survives **all nine mint sites** — everywhere the weak form held, nothing is lost. |
| `ordTimesKnown_addFuture_cons`, `ordTimesKnown_addPast_cons`, `ordTimesKnown_density_cons` | The three per-site `_cons` lemmas the engine statement above is built from. |
| `ordTimesKnown_splitOrdered_arms12` | Ordered-split arms 1-2, **free** from `firstIncomparablePair_spec` (that function scans `b.knownTimes`, so the trigger hands over exactly the two membership facts the strong form needs). |
| `applyRule_irreflOrd_from_known` | Derives Phase 3's headline in **one line** by composing the strong invariant with the implication, leaving `applyRule_irreflOrd` **byte-untouched**. |

Supporting lemmas also in the scratch file and also to be transcribed: `mem_knownTimes_of_mem`,
`exists_mem_of_mem_knownTimes`, `le_maxTime_of_mem_knownTimes`, `mem_knownTimes_identifyTime`,
`knownTimes_mono`, `ordTimesKnown_mono`, `nextTime_mem_knownTimes_cons`, `sub_append`,
`ne_nextTime_from_known`.

### Shape (b) — confirmed from source, and why shape (a) is rejected

**Adopted: shape (b).** Add `OrdTimesKnown` **alongside** `OrdTimesLeMaxTime`; derive the weak from
the strong once (`ordTimesLeMaxTime_of_ordTimesKnown`); carry the strong one as the run invariant.

This was verified against the source, not assumed. Plan 03's Phase 3 landed five declarations that
mention `OrdTimesLeMaxTime`. Reading them:

| Phase 3 declaration | Role | Effect of shape (b) |
|---|---|---|
| `applyRule_irreflOrd` (`:413`) | **Consumer** — takes `haux : OrdTimesLeMaxTime b ord` | Byte-untouched. Reached from the strong form in one line via `applyRule_irreflOrd_from_known`. |
| `ordTimes_addFuture_cons` (`:472`) | **Producer** of the weak invariant | Stays true, goes unused by the strong chain. |
| `ordTimes_addPast_cons` (`:486`) | **Producer** | Stays true, goes unused. |
| `ordTimes_density_cons` (`:502`) | **Producer** | Stays true, goes unused. |
| `applyRule_ordTimes_nonbranching` (`:538`) | **Producer** | Stays true, goes unused. |

Four of the five are *producers*, not consumers. **Shape (b) reopens no completed phase.** No
Phase 3 declaration is edited, renamed, restated, or deleted — deleting a producer would itself be
an edit to a completed phase's deliverable and is forbidden here.

**Shape (a) — outright replacement of `OrdTimesLeMaxTime` plus re-proving Phase 3's five results —
is rejected.** It is strictly more expensive for no gain, and it reopens a `[COMPLETED]` phase.

### The initial condition — stated explicitly, because vacuity is a live failure mode here

At tableau start the ordering has **no constraints**: `buildTableauAt` (`Saturation.lean:2199`) and
`buildTableau` (`:1162`) both call `expandBranchWithFuel initialBranch fuel TimeOrdering.empty fc`,
and `TimeOrdering.empty := { constraints := [] }` (`SignedFormula.lean:679`). So
`OrdTimesKnown b TimeOrdering.empty` holds **vacuously**, for every `b`, by `List.not_mem_nil`.

This is recorded here deliberately. This task's do-not-re-attempt register already carries two
refuted theorems, and **narrowing a statement into vacuity is an explicitly prohibited failure mode
on this plan**. A later reader meeting a base case that discharges by `simp` must be able to tell,
without re-deriving anything, that the vacuity is a property of `TimeOrdering.empty` and *not* a
symptom of a narrowed statement. The base case is vacuous; the inductive step (Phases 4.1-4.3) is
not, and it is the inductive step that carries all the content.

### Prior Plan Reference

`plans/02_lexicographic-splitordered-measure.md` Phases 1-10 are landed, sorry-free, axiom-free,
and green repo-wide. This plan **consumes** them and re-proves nothing. The consumed set is
unchanged from plan 03 and is enumerated there under "Prior Plan Reference"; it is not repeated
here, so that there is exactly one place to update if task 426 renames something (R5).

Additionally consumed, all landed by this task's own completed phases: `rho`, `rhoSF`, `IrreflOrd`,
`irreflOrd_identifyTime`, `irreflOrd_addFuture`, `irreflOrd_addPast`,
`incomparableB_of_firstIncomparablePair`, `witnessPresent_identifyTime_unconditional_false`,
`time_ne_nextTime`, `applyRule_irreflOrd_of_ne_density`, the twelve transport lemmas,
`OrdTimesLeMaxTime` and its four producers, `applyRule_irreflOrd`, `witnessPresent_identifyTime`,
`arm3_preserves_witness`, `pick_splitOrdered'`, `applyRule_branchingOrdered_rule`,
`expandOnceUnblocked_splitOrdered_shape`, `expandOnceUnblocked_splitOrdered_no_deletion`,
`findApplicable{,Serial,Linearity}Rule_applyRule_pair`, `nonBranchingResultBranch`,
`branchingResultBranches`, `unorderedSuccessorBranches`, `pick_ord_eq`, `pick_branches_eq`,
`pick_stage_source`, `ordTimes_identifyTime_arm3_false`.

### Roadmap Alignment

No `specs/ROADMAP.md` in this repository. No roadmap phases added.

### The `Fuel.lean` placement decision — unchanged from plan 03

All new declarations land in
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`, which already exists and
is already wired into the build by a one-line import in
`FormalSystem/Metalogic/Decidability.lean`. **This plan does not edit `Fuel.lean` at all**, which is
what resolves the task-426 concurrent-edit hazard. The full rationale and the rejected alternatives
are in plan 03's Overview and are not restated here.

---

## Goals & Non-Goals

**Goals**:
- Land `OrdTimesKnown` as the **run invariant**, replacing `OrdTimesLeMaxTime` in that role while
  leaving every landed `OrdTimesLeMaxTime` result standing.
- Close the Phase 4 blocker: `IrreflOrd` becomes a run invariant the fuel induction can carry
  **across ordered splits**, including arm 3.
- Land the full witness-preservation stack and engine-level non-deletion for all four
  `ExpansionResult` shapes.
- Land `expandBranchWithFuel_isSome_of_budget` with an explicit **mint-budget parameter** in the
  `branchesUsed`/`maxBranches` shape, `NoSplit`-free, and **discharge that parameter in-plan**.
- Land the terminus `buildTableauAt_isSome_of_budget`, sorry-free, axiom-free, with the run
  invariant discharged at the engine's own seed rather than carried.
- Supply the world dimension, or prove its absence harmless.

**Non-Goals**:
- Editing `buildTableau`, its `fuel := 1000` default, or `expandBranchWithFuel`'s
  `maxBranches := 50000` default. All three stay **BYTE-IDENTICAL**.
- Editing `Fuel.lean`, `Saturation.lean`, or `Tableau.lean` at all. All three stay **BYTE-IDENTICAL**,
  currently true and independently verified by md5 each cycle.
- Deleting, renaming, restating, or re-proving `OrdTimesLeMaxTime` or any of its four producer
  lemmas. Shape (a) is rejected; the producers stay in source, true and unused by the strong chain.
- Route (a). DEAD BY DEFINITION per the second retarget decision. Not revisited under any framing.
- The unconditional `buildTableau_isSome` and the `.splitOrdered` cardinality twin. Both remain on
  the **do-not-re-attempt register**.
- Repairing `resolveOpenArmCancellable` in `CancellableExpansion.lean` — a DECLARED, deliberately
  unrepaired out-of-scope divergence.
- Carrying the mint bound as a hypothesis in the shape `hT` has, or pushing its discharge onto
  task 412. **Both explicitly rejected by the user.** The mint budget is a theorem *parameter* that
  this plan discharges (Phases 11-13), not a caller obligation.

**Absolute prohibitions** (a phase violating any of these is a failure, not a deviation):
- No `sorry`. No `axiom`. No `def X := True` / `:= Unit` / `:= trivial` vacuous placeholder.
- No `NoSplit` reintroduction under any name.
- No admitted `WorldWitness` and no admitted `hT` / mint bound.
- **No narrowing a statement into vacuity to make it check.** The one vacuous fact this plan
  sanctions is the initial condition `OrdTimesKnown b TimeOrdering.empty`, which is vacuous because
  `TimeOrdering.empty.constraints = []` — a property of the engine's seed, established by reading
  `Saturation.lean:2199` and `SignedFormula.lean:679`, not by narrowing anything.
- **No task-number citations in any `.lean` file.** Per
  `.claude/rules/no-task-references-in-deliverables.md`, task numbers are fine in this plan (it is
  under `specs/**`) and forbidden in `MintBound.lean` and every other deliverable. In-source
  provenance notes cite durable anchors (declaration names, section headings), never "task N".

---

## Risks & Mitigations

| # | Risk | Impact | Likelihood | Status / Mitigation |
|---|------|--------|------------|---------------------|
| R1 | `densityRule`'s second edge needs an "every ordering time is a branch time" invariant that `.branching`'s shared `newOrd` gives a visible way to break. | H | — | **RETIRED — discharged by proof.** Phase 3 closed the density obligation; Phase 4 confirmed the mirrored `.branching` half: all four branching mint sites (`untlPos`, `sncePos`, and the ACTIVE arms of `untlNeg`/`snceNeg`) build **both** arms headed at `freshLabel`, so every arm dominates the time it minted. Plan 03's UNVERIFIED grounding note on this point is now confirmed. |
| R2 | The **mint potential** measure design (Phase 10) is the plan's own **unproved proposal** and is NOT machine-checked. Specific hazard: arm 3's renaming `rhoSF` is **not injective on `U`**, so a cardinality-of-filter potential needs an injection argument at arm 3. | H | M | **PRESERVED VERBATIM.** Phase 10 carries a Scope Hypothesis requiring the arm-3 monotonicity to be settled **before** the induction is written, plus a named alternative (index the potential over the *pre-renaming* pair set and transport the filter along `rhoSF`). Escalate as `[BLOCKED]` rather than substitute. |
| R3 | **Universe/mint circularity.** `#mints ≤ 8·|U|` and `|U| = |signedUniverse C L|` with `L = worlds × times`, while times grow by mints. If `Tmax` is not supplied independently, the chain is circular. | H | M | **PRESERVED.** The circularity is broken **only** if `Tmax` comes independently from T2 — `timeFinset_card_le_of_not_blocked` (`Fuel.lean:588`) — and **not** from the mint chain. Phase 9 owns this; Phase 10's first task is a read-and-report confirmation that T2's bound is in a consumable form, done before any statement is written. |
| R4 | `WorldWitness` discharge (Phase 9) was **never attempted**; plan 02's docstring calls it a ~36-case induction over `applyRule`. | H | M | **PRESERVED.** Phase 9 has a named fallback (bound the world component along the seed run by fresh-world-minting steps) and a sanctioned degraded outcome: carry the residual as **one explicitly named hypothesis**, documented in-source and named in the summary. **Never an axiom.** |
| R5 | Task 426 lands a `Fuel.lean` rename that breaks `MintBound.lean`. | M | L | **PRESERVED.** Loud build-time failure, not silent. Consumed declarations enumerated in plan 03's "Prior Plan Reference"; repair is a rename in one file. |
| R6 | `applyRule_branchingOrdered_rule` needs `set_option maxHeartbeats 4000000` and a full 32-constructor × 2-sign case split; build time may be significant. | M | — | **RETIRED IN PRACTICE.** The "32-constructor" figure is **stale**: `TableauRule` has **36** constructors. Phase 7 is green at `maxHeartbeats 4000000` with measured whole-module build ~26s wall / ~73s user from a warm `Fuel.lean`; `maxHeartbeats` was never raised above the scratch file's figure. **Residual**: Phase 4.2's `applyRule_ordTimesKnown_branching` hits the same 36 × 2 elaboration load — see R8. |
| R7 | Phase sizing regression — this task has stalled twice on over-large phases. | M | M | **PRESERVED.** 17 phases, each ~1-2 hours, each with a concrete mechanical completion criterion. Every phase whose content is transcription says so, so the implementer does not re-derive. The Phase 4 repair is split into three sub-phases for exactly this reason. |
| R8 | **NEW.** `applyRule_ordTimesKnown_branching` — the `.branching` result-shape analogue — is the **one** piece of the repair that is **not** in `scratch/05`. It is new proof, and it carries the R6 elaboration load. | M | L | The weak twin `applyRule_ordTimes_branching` (`MintBound.lean:1016`) supplies the exact proof skeleton, and the three `_cons` lemmas have strong twins in `scratch/05`. The only substitution is `le_maxTime hsf` → `mem_knownTimes_of_mem hsf` and `ordTimes_mono` → `ordTimesKnown_mono`; `sub_append` covers branch growth identically because every arm is `fs ++ b`. If it does not close, Phase 4.2 escalates as `[BLOCKED]` with the goal state recorded — it does **not** get worked around by restricting the statement to non-branching results. |

---

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 5, 9 | 1 |
| 3 | 3, 6 | 2 / 5 |
| 4 | 4, 7 | 3 / 6 |
| 5 | 4.1 | 4 |
| 6 | 4.2 | 4.1 |
| 7 | 4.3 | 4.2 |
| 8 | 8 | 6, 7 |
| 9 | 10 | 4.3, 8, 9 |
| 10 | 11 | 8, 10 |
| 11 | 12 | 11 |
| 12 | 13 | 4.3, 10, 12 |
| 13 | 14 | 13 |

Phases within the same wave are logically independent. **Territory note**: every phase writes the
same file (`MintBound.lean`), so wave-parallel *execution* would collide. Waves record dependency
only; execute sequentially in phase-number order.

---

### Phase 1: New module, `IrreflOrd`, and its two machine-checked preservation cases [COMPLETED]

**Goal**: Create the module, wire it into the build, and land the irreflexivity primitives —
including the counterexample that makes the side condition necessary rather than convenient.

**Landed** (full completion record in plan 03, Phase 1): `MintBound.lean` created and imported from
`FormalSystem/Metalogic/Decidability.lean`; `rho`, `rhoSF`, `IrreflOrd`, `irreflOrd_identifyTime`,
`irreflOrd_addFuture`, the new mirror `irreflOrd_addPast`,
`incomparableB_of_firstIncomparablePair`, and the counterexample record (three anonymous `example`s
plus the **named** `witnessPresent_identifyTime_unconditional_false`, named so downstream in-source
notes can cite it by declaration name). `lean_verify` axioms all subsets of
`[propext, Classical.choice, Quot.sound]`. Zero `sorry`, zero `axiom`, zero task-number citations.
`Saturation.lean` / `Fuel.lean` md5 unchanged.

**Timing**: 1.5 hours (spent)

**Depends on**: none

**Verification Tier**: local

**Files to modify**: `MintBound.lean` (new), `FormalSystem/Metalogic/Decidability.lean` (one import
line). **Both already landed — do not re-open.**

---

### Phase 2: `applyRule` preserves `IrreflOrd` at the eight non-density mint sites [COMPLETED]

**Goal**: Prove `applyRule` returns an irreflexive ordering for every rule except `densityRule`.

**Landed** (full record in plan 03, Phase 2): `time_ne_nextTime` and
`applyRule_irreflOrd_of_ne_density`, discharging all eight single-edge mint sites plus every
ordering-unchanged rule. **Scope Hypothesis confirmed**: exactly nine `branch.nextTime` sites inside
`applyRule` (`Tableau.lean:761, 801, 834, 878, 924, 971, 1069, 1168, 1370`), `densityRule` (`:1370`)
the only two-edge one; four `addPast` sites (`:801, :878, :971, :1168`), five `addFuture`. A
labelling correction was recorded (`:971` is `.sncePos`, `:1168` is the `snceNeg` active arm) with
no effect on the proof. `lean_verify` reports exactly the three standard axioms.
`set_option maxHeartbeats 4000000` required; module build ~23s.

**Timing**: 2 hours (spent)

**Depends on**: 1

**Verification Tier**: local

**Files to modify**: `MintBound.lean`. **Already landed — do not re-open.**

---

### Phase 3: `densityRule` and the ordering-times invariant [COMPLETED]

**Goal**: Close the one mint site Phase 2 excludes, by supplying the auxiliary invariant its second
edge needs.

**Landed** (full record in plan 03, Phase 3 — the `[BLOCKED]` clause was NOT triggered):
`OrdTimesLeMaxTime`, `exists_constraint_to_of_pathN`, `exists_constraint_to_of_mem_futureOf`,
`ne_nextTime_of_mem_futureOf`, `irreflOrd_density_newOrd`, `applyRule_irreflOrd` (no rule excluded,
no frame-class restriction), the local `maxTime` re-proofs, `ordTimes_mono`,
`nextTime_le_maxTime_cons`, `ordTimes_addFuture_cons`, `ordTimes_addPast_cons`,
`ordTimes_density_cons`, `nonBranchingResultBranch`, `applyRule_ordTimes_nonbranching`.
`lean_verify` reports exactly the three standard axioms on the two headline results.

**Standing under the revision** — this is the crux of shape (b) and is stated here so no
implementer re-opens it: **all five `OrdTimesLeMaxTime` declarations stay byte-untouched.**
`applyRule_irreflOrd` is the only *consumer* and is reached from the strong invariant in one line
(`applyRule_irreflOrd_from_known`); the other four are *producers* that remain true and simply go
unused by the strong chain. Deleting an unused producer would itself be an edit to a completed
phase's deliverable and is forbidden.

**Timing**: 2 hours (spent)

**Depends on**: 2

**Verification Tier**: local

**Files to modify**: `MintBound.lean`. **Already landed — do not re-open.**

---

### Phase 4: Engine-level `IrreflOrd` across all four result shapes [IN PROGRESS]

**Goal**: Lift Phase 3 from `applyRule` to `expandOnceUnblocked`, so `IrreflOrd` is a run invariant
the fuel induction can carry.

**Status**: this phase is `[IN PROGRESS]`, not `[COMPLETED]` and not `[BLOCKED]`. Its four original
task bullets are all green and committed. Its *Goal* is not yet met, because the results below
thread the **weak** invariant and a run through the ordered split's arm 3 loses it. The remaining
work — the strong analogues — is decomposed into **Phases 4.1, 4.2 and 4.3** below.

**This decomposition re-works results that this phase itself landed** (`expandOnceUnblocked_irreflOrd`
at `MintBound.lean:931`, commit `77cb0930b`; `expandOnceUnblocked_ordTimes` at `:1152`, commit
`cc1ae9a5f`), and that is **real re-work, stated plainly rather than glossed**. It is not a reopened
completed phase: Phase 4 is `[IN PROGRESS]`, so its own deliverables are still in flight and are
this plan's to revise. **No `[COMPLETED]` phase is reopened by anything in 4.1-4.3.**

**Tasks** (all four landed under plan 03):
- [x] `findApplicable{,Serial,Linearity}Rule_applyRule_pair` — the three pick bridges carrying the
      ordering component. These did not exist and were a real prerequisite plan 03 did not name.
- [x] `expandOnceUnblocked_irreflOrd`, all four result shapes (weak-threaded — superseded by 4.3).
- [x] `expandOnceUnblocked_splitOrdered_irreflOrd`, the per-arm orderings (arms 1-2 via
      `irreflOrd_addFuture`, arm 3 via the unconditional `irreflOrd_identifyTime`). **Carries over
      unchanged** — it takes only `IrreflOrd ord`, never the times invariant.
- [x] `branchingResultBranches`, `applyRule_ordTimes_branching`, `pick_stage_source`,
      `unorderedSuccessorBranches`, `expandOnceUnblocked_ordTimes` (weak-threaded — superseded
      by 4.2), and the refutation `ordTimes_identifyTime_arm3_false`.

**Retained learnings (apply to 4.1-4.3)**:
- Keep the obligation on the **goal** side. A hypothesis of the form `applyRule … = (.linear fs, ord')`
  cannot be split in step with the goal — `split at h` fails to reach every `dite` once the equation
  is oriented. `nonBranchingResultBranch` / `branchingResultBranches` are the working shapes.
- `applyRule` is one `match` over three discriminants with overlapping patterns, so `split` emits
  *every* rule's arm inside each rule's case with a false discriminant equation — `contradiction` is
  the cheap discharge and is load-bearing, not defensive.
- A `first` alternative whose body contains a `by` block does **not** backtrack cleanly; put
  tactic-failure alternatives (`subst`, `obtain`) before any alternative containing `(by simp)`.
- `omega` is unusable on `TimeIndex` goals despite `TimeIndex` being an `abbrev` for `Nat`.
- `Branch` is an `abbrev` for `List SignedFormula`, so dot notation `(fs ++ b).maxTime` resolves to
  `List.maxTime` and fails; write `Branch.maxTime (fs ++ b)`.

**Timing**: 2 hours (spent)

**Depends on**: 3

**Verification Tier**: local

**Files to modify**: `MintBound.lean`

---

### Phase 4.1: `OrdTimesKnown` — the strengthened invariant, transcribed [COMPLETED]

**Goal**: Land the strengthened invariant and every one of its machine-checked supporting results,
plus the initial condition. **This phase is transcription of already-elaborated Lean, not new
proof.** Every declaration below exists, sorry-free, in
`specs/428_engine_totality_at_a_quantified_branch_budget/scratch/05_ordtimesknown-repair-check.lean`
(commit `7f3c7dcb5`, elaborates exit 0). **Read that file and transcribe. Do not re-derive.**

**Tasks**:
- [x] Land `OrdTimesKnown (b : Branch) (ord : TimeOrdering) : Prop := ∀ p ∈ ord.constraints, p.1 ∈ b.knownTimes ∧ p.2 ∈ b.knownTimes`
      with a docstring stating that it is a **strengthening** of `OrdTimesLeMaxTime`, that the weak
      form is **refuted** at the identification arm (citing `ordTimes_identifyTime_arm3_false` **by
      declaration name**), and that the weak form's landed results are retained and still true.
- [x] Transcribe `mem_knownTimes_of_mem`, `exists_mem_of_mem_knownTimes`,
      `le_maxTime_of_mem_knownTimes`.
- [x] Transcribe `ordTimesLeMaxTime_of_ordTimesKnown` — **the strengthening witness**. Its docstring
      must say that this is what makes the change a strengthening rather than the forbidden
      weakening, and that every landed `OrdTimesLeMaxTime` consumer keeps working through it.
- [x] Transcribe `counterexample_dies` — the refuting configuration fails the new invariant at its
      input. Adjacent to `ordTimes_identifyTime_arm3_false`, so a reader meets both together.
- [x] Transcribe `mem_knownTimes_identifyTime` and `ordTimesKnown_identifyTime` — **arm-3
      preservation, the crux**. Its docstring must record that it needs **no trigger hypotheses at
      all** (not `firstIncomparablePair`, not `IrreflOrd`), because it is a pure structural fact
      about branch and ordering relabelling by the same `rho`. That is strictly better than the weak
      form, which is false here even *with* both hypotheses.
- [x] Transcribe `knownTimes_mono`, `ordTimesKnown_mono`, `nextTime_mem_knownTimes_cons`,
      `sub_append`.
- [x] Transcribe `ordTimesKnown_addFuture_cons`, `ordTimesKnown_addPast_cons`,
      `ordTimesKnown_density_cons`.
- [x] Transcribe `applyRule_ordTimesKnown_nonbranching` (with its `set_option maxHeartbeats 4000000 in`)
      and `ordTimesKnown_splitOrdered_arms12`.
- [x] Transcribe `applyRule_irreflOrd_from_known` and `ne_nextTime_from_known` — the shape-(b)
      viability witnesses. `applyRule_irreflOrd` itself is **not edited**.
- [x] **Land the initial condition as a named lemma**:
      `ordTimesKnown_empty (b : Branch) : OrdTimesKnown b TimeOrdering.empty`. Its docstring must
      state plainly that this is **vacuously true because `TimeOrdering.empty.constraints = []`**
      (`SignedFormula.lean:679`), that the engine seeds every run at `TimeOrdering.empty`
      (`Saturation.lean:2199`, `:1162`), and that the vacuity is a property of the seed rather than
      a narrowed statement — so a future reader does not mistake a vacuous base case for a weakened
      invariant.
- [x] Add the **new do-not-re-attempt register entry** as a section comment adjacent to
      `ordTimes_identifyTime_arm3_false`: the preservation of `OrdTimesLeMaxTime` across the ordered
      split's identification arm is **refuted**, not merely unproved, and `OrdTimesKnown` is the
      settled repair. Cite by declaration name only — never by task or report number.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that the nine headline results plus their nine supporting
lemmas transcribe cleanly. They elaborated sorry-free in the scratch file against **this same**
`MintBound.lean` (the scratch file imports it), so the expected failure mode is namespace or binder
drift, not proof failure — note in particular that the scratch file works in namespace
`Scratch428Repair` and its statements will move into `FormalSystem.Metalogic.Decidability`. If any
lemma does not transcribe, **report which and why before attempting a re-derivation**.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- All nine headline declarations present by the names above, checkable by `grep`.
- `lean_verify ordTimesKnown_identifyTime`, `lean_verify applyRule_ordTimesKnown_nonbranching`, and
  `lean_verify ordTimesLeMaxTime_of_ordTimesKnown` each report a subset of
  `[propext, Classical.choice, Quot.sound]`.
- `grep -c 'sorry'` reports 0; `grep -c '^axiom '` reports 0.
- `grep -inE 'task [0-9]|tasks [0-9]' MintBound.lean` reports nothing.
- md5 of `Saturation.lean`, `Fuel.lean`, `Tableau.lean` unchanged.

---

### Phase 4.2: `OrdTimesKnown` at the branching shapes and at engine level [NOT STARTED]

**Goal**: Supply the one piece of the repair that is **not** in the scratch file — the `.branching`
result-shape analogue — and lift the strong invariant to `expandOnceUnblocked`. **This phase is new
proof**, and it is where R8 lives.

**Tasks**:
- [ ] Prove `applyRule_ordTimesKnown_branching`, the strong twin of the landed
      `applyRule_ordTimes_branching` (`MintBound.lean:1016`):
      `(hsf : sf ∈ b) (haux : OrdTimesKnown b ord) : ∀ nb ∈ branchingResultBranches b (applyRule rule sf b ord).1, OrdTimesKnown nb (applyRule rule sf b ord).2`.
      Transcribe the weak twin's proof skeleton and make exactly these substitutions:
      `le_maxTime hsf` → `mem_knownTimes_of_mem hsf`; `ordTimes_mono` → `ordTimesKnown_mono`; the
      three `ordTimes_*_cons` → their `ordTimesKnown_*_cons` twins. Branch growth is identical
      (`branchingResultBranches` maps `fs ++ b`, covered by `sub_append`). Carry
      `set_option maxHeartbeats 4000000 in` from the weak twin — do **not** raise it further; if the
      elaboration budget is exceeded, **report the measured time** rather than raising it silently.
- [ ] Prove the strong pick-stage lemma `pickBranches_ordTimesKnown`, the twin of the landed private
      `pickBranches_ordTimes` (`:1127`), joining the non-branching and branching `applyRule` lemmas.
      Reuse the landed `pick_stage_source` (`:1085`) unchanged — it supplies
      `∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)` and is invariant-agnostic.
- [ ] Prove `expandOnceUnblocked_ordTimesKnown`, the twin of the landed `expandOnceUnblocked_ordTimes`
      (`:1152`): `(haux : OrdTimesKnown b ord) : ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, OrdTimesKnown nb (expandOnceUnblocked b ord fc tr).2`.
      Reuse the landed `pick_ord_eq` and `pick_branches_eq` unchanged — both are invariant-agnostic.
- [ ] Prove the strong `expandOnceUnblocked_irreflOrd_of_known`:
      `(hord : IrreflOrd ord) (haux : OrdTimesKnown b ord) : IrreflOrd (expandOnceUnblocked b ord fc tr).2`.
      **Do not re-prove the case analysis.** Compose: `expandOnceUnblocked_irreflOrd hord (ordTimesLeMaxTime_of_ordTimesKnown haux)`.
      Expect one line. The landed weak-threaded `expandOnceUnblocked_irreflOrd` stays in place as the
      lemma this is built from.
- [ ] Add an in-source note, adjacent to the strong engine-level results, recording that the weak
      engine-level twins are **retained and still true** — they are what the strong forms compose
      through — and that the strong forms exist because the weak invariant is not carryable across
      the ordered split's identification arm. Cite `ordTimes_identifyTime_arm3_false` by declaration
      name.

**Timing**: 2 hours

**Depends on**: 4.1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that the weak twins' proof skeletons transfer under the
five named substitutions, and that the three invariant-agnostic helpers (`pick_stage_source`,
`pick_ord_eq`, `pick_branches_eq`) are reusable unchanged. Confirm the reusability by reading their
statements **before** re-proving anything. It further asserts the R6 elaboration figure (36
constructors × 2 signs at `maxHeartbeats 4000000`) holds for the strong branching analogue as it did
for the weak one; a materially different build time must be **reported**, not absorbed.

**Escalation clause — `[BLOCKED]`, mandatory**: if `applyRule_ordTimesKnown_branching` does not
close, mark the phase `[BLOCKED]`, record the exact goal state and the rule/arm at which it failed,
and stop. **Forbidden**: restricting the statement to non-branching result shapes (that is `NoSplit`
by another name); admitting `OrdTimesKnown` at the branching shapes; weakening `OrdTimesKnown` into
something `ordTimesKnown_identifyTime` can no longer be composed with; deleting the weak twins to
make room; a `sorry`; a vacuous placeholder. Per `plan-compliance.md`, a would-be deviation on a
`.lean` file is escalated, never silently annotated.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `expandOnceUnblocked_ordTimesKnown` covers `.extended` and every arm of a `.split`, checkable by
  reading the statement.
- `grep` confirms `NoSplit` does not appear anywhere in `MintBound.lean`.
- `lean_verify` on the phase's top-level lemmas reports exactly
  `[propext, Classical.choice, Quot.sound]`.
- Measured build time recorded in the completion notes (R6/R8).
- md5 of `Saturation.lean`, `Fuel.lean`, `Tableau.lean` unchanged.

---

### Phase 4.3: The ordered split closes — `IrreflOrd` becomes a run invariant [NOT STARTED]

**Goal**: Close the Phase 4 blocker. Prove that `OrdTimesKnown` survives **every** arm of the
ordered split, including arm 3, and package the pair `(IrreflOrd, OrdTimesKnown)` as the run
invariant the fuel induction carries. **This is the deliverable the whole revision exists for.**

**Tasks**:
- [ ] Prove `expandOnceUnblocked_splitOrdered_ordTimesKnown`: given
      `(expandOnceUnblocked b ord fc tr).1 = .splitOrdered bs` and `OrdTimesKnown b ord`, every
      `p ∈ bs` satisfies `OrdTimesKnown p.1 p.2`. Route: `expandOnceUnblocked_splitOrdered_shape`
      (landed, `:788`) supplies the exact three-arm list and the trigger
      `firstIncomparablePair b ord = some (t₁, t₂)`; arms 1-2 are
      `ordTimesKnown_splitOrdered_arms12 htrig haux` (branch literally unchanged); **arm 3** is
      `ordTimesKnown_identifyTime haux`, which needs neither the trigger nor `IrreflOrd`.
- [ ] Package the run invariant as a single named definition, e.g.
      `RunInvariant (b : Branch) (ord : TimeOrdering) : Prop := IrreflOrd ord ∧ OrdTimesKnown b ord`,
      so Phases 8, 10, 13 and 14 consume **one** name rather than a two-element bundle spelled out
      at every call site. Supply its two projections and the derived weak form
      (`ordTimesLeMaxTime_of_ordTimesKnown ∘ .2`).
- [ ] State and prove `expandOnceUnblocked_runInvariant`: the invariant holds at every successor of
      an unblocked expansion step — `.extended` and `.split` arms from 4.2 plus
      `expandOnceUnblocked_irreflOrd_of_known`; `.splitOrdered` arms from this phase's first task
      plus the landed `expandOnceUnblocked_splitOrdered_irreflOrd` (which carries over unchanged —
      it takes only `IrreflOrd ord`); `.saturated` contributes no successor.
- [ ] Prove `runInvariant_initial (b : Branch) : RunInvariant b TimeOrdering.empty`, from
      `ordTimesKnown_empty` and the vacuous `IrreflOrd TimeOrdering.empty`. Docstring must repeat the
      initial-condition note from 4.1: vacuous **because the seed ordering has no constraints**, not
      because anything was narrowed.
- [ ] Add an in-source section note recording that this closes the obligation the weak invariant
      could not meet, naming `ordTimes_identifyTime_arm3_false` as the refutation and
      `ordTimesKnown_identifyTime` as the repair. Never cite a task or report number.

**Timing**: 1.5 hours

**Depends on**: 4.2

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that `expandOnceUnblocked_splitOrdered_shape` enumerates
exactly the three arms and that `firstIncomparablePair_spec` supplies `t₁, t₂ ∈ b.knownTimes`
directly (it does — `firstIncomparablePair` scans `b.knownTimes`, `Tableau.lean:420-427`). Confirm
both by reading the statements before writing the case split. A fourth arm, or a trigger that does
not supply the two membership facts, is a material finding and must be **reported**, not absorbed.

**Escalation clause**: if any arm does not close, mark the phase `[BLOCKED]` and report which arm
and the exact goal state. **Forbidden**: restricting the run invariant to runs that avoid ordered
splits; admitting the arm-3 case; a `sorry`; a vacuous placeholder; reintroducing `NoSplit` under
any name.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `expandOnceUnblocked_splitOrdered_ordTimesKnown` covers all **three** arms, checkable by reading
  the proof's `rcases`.
- `expandOnceUnblocked_runInvariant` covers all four `ExpansionResult` shapes, checkable by reading
  the statement.
- `lean_verify` on both reports exactly `[propext, Classical.choice, Quot.sound]`.
- `grep` confirms `NoSplit` does not appear in `MintBound.lean`.
- md5 of `Saturation.lean`, `Fuel.lean`, `Tableau.lean` unchanged.

---

### Phase 5: The reachability transport stack [COMPLETED]

**Goal**: Land the twelve transport lemmas that make claim (i) work.

**Landed** (full record in plan 03, Phase 5): `identifyTime_edge`,
`mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`, `identifyTime_no_collapse`,
`mem_directFutureOf_iff'`, `mem_directPastOf_iff'`, `pathN_along`, `directFutureOf_transport`,
`directPastOf_transport`, `futureOf_transport`, `pastOf_transport`, and the `hnsl` restatement in
`IrreflOrd` vocabulary. All twelve transcribed **verbatim** and green on the first attempt.
`lean_verify` reports exactly the three standard axioms.

**Premise under the revision**: **UNCHANGED.** Nothing here mentions either times invariant.

**Timing**: 1.5 hours (spent)

**Depends on**: 1

**Verification Tier**: local

**Files to modify**: `MintBound.lean`. **Already landed — do not re-open.**

---

### Phase 6: Witness preservation across `.splitOrdered` arm 3 [COMPLETED]

**Goal**: Land claim (i) — `witnessPresent_identifyTime` for all eight fresh-label rules with the
remaining rules proved vacuous, and the packaged `arm3_preserves_witness`.

**Landed** (full record in plan 03, Phase 6): `mem_identifyTime`, `contains_identifyTime`,
`knownWorlds_identifyTime`, `any_knownWorlds_transport`, `any_futureOf_transport`,
`any_pastOf_transport`, `contains_at`, `witnessPresent_identifyTime` (eight-rule case analysis,
vacuity **proved** not assumed), `arm3_preserves_witness`. **Scope Hypothesis confirmed**:
`ruleMintsFreshLabel` has exactly eight `true` arms; there is no ninth fresh-label rule. The
required in-source note cites `witnessPresent_identifyTime_unconditional_false` **by declaration
name**. `lean_verify` reports exactly the three standard axioms.

**Premise under the revision**: **UNCHANGED.** `arm3_preserves_witness` takes
`firstIncomparablePair b ord = some (t₁, t₂)` and `IrreflOrd ord` — never a times invariant. What
changes is only *how* its `IrreflOrd` hypothesis is carried along a run (Phase 4.3, not here).

**Timing**: 2 hours (spent)

**Depends on**: 5

**Verification Tier**: local

**Files to modify**: `MintBound.lean`. **Already landed — do not re-open.**

---

### Phase 7: Non-deletion at engine level, all four result shapes [COMPLETED]

**Goal**: Land claim (ii) — no expansion step deletes a formula.

**Landed** (full record in plan 03, Phase 7): `pick_splitOrdered'`,
`applyRule_branchingOrdered_rule` (transcribed **with** both `set_option` lines and the full
12-constructor comment; the flagged `exact RuleResult.noConfusion h` was NOT deleted),
`expandOnceUnblocked_splitOrdered_shape`, `expandOnceUnblocked_splitOrdered_no_deletion`, and the
in-source membership-vs-cardinality note. **Scope Hypothesis corrected and recorded**: `TableauRule`
has **36** constructors, not ~32; the transcription elaborated unchanged at
`maxHeartbeats 4000000`. Measured whole-module build ~26s wall / ~73s user from a warm `Fuel.lean`.
`lean_verify` reports exactly the three standard axioms.

**Premise under the revision**: **UNCHANGED.** Non-deletion is a membership statement about branches
and mentions no ordering-times invariant.

**Timing**: 2 hours (spent)

**Depends on**: 6

**Verification Tier**: local

**Files to modify**: `MintBound.lean`. **Already landed — do not re-open.**

---

### Phase 8: Witness monotonicity and one-step preservation, all four shapes [NOT STARTED]

**Goal**: Turn arm-3 preservation into a statement about **every** expansion step, which is what the
mint counting actually consumes. This phase is **new proof**, not transcription.

**Premise change under the revision — FLAGGED**: this phase's `.splitOrdered` arm-3 bullet consumes
`IrreflOrd` *carried along a run*. Under plan 03 that meant carrying
`(IrreflOrd, OrdTimesLeMaxTime)`; it now means carrying `RunInvariant` (Phase 4.3). This is a
**hypothesis-bundle rename with no change to the proof content** — `arm3_preserves_witness` itself
is untouched, and the weak form is still available from `RunInvariant` by projection where any
`OrdTimesLeMaxTime` consumer needs it.

**Tasks**:
- [ ] Prove `witnessPresent` is monotone in the branch:
      `b ⊆ b' → witnessPresent rule sf b ord = true → witnessPresent rule sf b' ord = true`.
      Every clause is a `contains` / `any … contains` test, so this is a `List.Subset` argument on
      `Branch.contains`.
- [ ] Prove `witnessPresent` is monotone in the ordering:
      `ord.constraints ⊆ ord'.constraints → witnessPresent rule sf b ord = true → witnessPresent rule sf b ord' = true`,
      via the landed `futureOf_mono` / `pastOf_mono` and `addFuture_constraints_mono`.
- [ ] Combine into `expandOnceUnblocked_preserves_witness`, for each of the four result shapes:
      - `.extended nb`: `nb = fs ++ b` (`Tableau.lean:2234, 2238`), so branch monotonicity; the
        ordering only ever grows by `addFuture` / `addPast`, so ordering monotonicity.
      - `.split bs`: every arm is `fs ++ b` via the landed `expandOnceUnblocked_split_subset`.
      - `.splitOrdered` arms 1-2: branch literally unchanged, ordering grows —
        `expandOnceUnblocked_splitOrdered_shape` plus ordering monotonicity.
      - `.splitOrdered` arm 3: Phase 6's `arm3_preserves_witness`, with `IrreflOrd` supplied by
        `RunInvariant.1` (Phase 4.3) rather than by a standalone hypothesis.
      - `.saturated`: no successor branch, vacuous.
- [ ] State the corollary in the form the counting needs: **`witnessPresent` never flips
      `true → false` along a run** (up to the arm-3 renaming), stated against `RunInvariant`.

**Timing**: 2 hours

**Depends on**: 6, 7

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that (a) the ordering only ever grows by edge addition
except at arm 3, and (b) every `witnessPresent` clause is monotone in both arguments. Both are read
off the definitions; confirm by reading `witnessPresent`'s body and `applyRule`'s ordering returns
before writing the proofs. If any clause is anti-monotone in either argument, that is a material
finding — **report it**, since it would put the whole mint bound at risk.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `expandOnceUnblocked_preserves_witness` covers all four shapes, checkable by reading the statement.
- Sorry-free; `#print axioms` reports exactly the three standard axioms.

---

### Phase 9: The world dimension and an independent `Tmax` [NOT STARTED]

**Goal**: Supply the world dimension so that `|U|` is a real number rather than a circular one, and
supply `Tmax` **independently of the mint chain** so R3 does not bite.

**Premise under the revision**: **UNCHANGED.** This phase concerns `WorldWitness`, `worldFinset`,
and `timeFinset` and consumes no ordering-times invariant. Its unattempted-`WorldWitness` risk (R4),
its named fallback, and its never-an-axiom clause are **preserved verbatim** from plan 03.

**Tasks**:
- [ ] **Read first, prove second.** Read `chain_le_worldFuel'` (`Fuel.lean:2619`),
      `worldFinset_card_le` (`:1230`), `worldWitness_self` (`:1302`), and
      `timeFinset_card_le_of_not_blocked` (`:588`), and record in the completion notes exactly what
      each supplies and what each demands. `chain_le_worldFuel'`'s docstring states that
      `hww : WorldWitness C S (run n)` is an invariant **not discharged there** — that is the
      warning sign for this phase.
- [ ] **Confirm T2 delivers `Tmax` in a consumable form** (R3). `timeFinset_card_le_of_not_blocked`
      is landed and bounds `Branch.timeFinset.card`; confirm its hypotheses are satisfiable along an
      engine run before building anything on it. If it is not consumable, say so explicitly and take
      the fallback below — do **not** reshape `TimeTypeBound.lean` (outside scope).
- [ ] Discharge `WorldWitness` for the engine's seed configuration
      (`initialBranch = [SignedFormula.neg phi Label.initial]`, so `S.card = 1`). Scope to the seed
      run, not the general invariant.
- [ ] Derive `hL : L.card ≤ (s + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card)` at `s = 1` via
      `worldFinset_card_le`, in the exact shape the downstream phases consume.
- [ ] **Named fallback for `Tmax`**, taken only if T2 does not deliver: bound fresh-time mints
      directly by the `witnessPresent` guard — each existential signed formula mints at most one
      witness and the existential formulas live in `U`. This route **reintroduces R3's circularity**
      unless `|U|` is closed first; if taken, the phase must state precisely how the circularity is
      broken, or escalate.
- [ ] **Named fallback for `WorldWitness`**, taken only if the induction over `applyRule` does not
      close: prove the narrower statement that the world component of the seed run's label set is
      bounded by the run's fresh-world-minting steps, and state precisely which residual remains.

**Timing**: 3 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Plan 02's docstring asserts the `WorldWitness` discharge is a ~36-case
induction over `applyRule`. That count is **UNVERIFIED**. Enumerate `applyRule`'s arms before
starting; a materially different count changes this phase's sizing and must be reported. Separately,
"T2 supplies a consumable `knownTimes` bound" is **UNVERIFIED** — confirm by reading
`timeFinset_card_le_of_not_blocked`'s actual statement **first**, before writing any proof.

**Escalation clause**: if neither the primary nor the fallback route closes for `Tmax` or for
`WorldWitness`, mark the phase `[BLOCKED]` and report the exact goal state and which route was
tried. The **only** sanctioned degraded outcome is to carry the undischarged item as **one
explicitly named hypothesis** on Phase 14's terminus, documented in-source and named by name in the
implementation summary. The task's DONE WHEN admits "its absence is proved harmless" — that is
acceptable **only if the harmlessness is itself proved**, never asserted. **Forbidden absolutely**:
admitting `WorldWitness` as an `axiom`; reintroducing `NoSplit`; a `sorry`; a vacuous placeholder;
editing `TimeTypeBound.lean` or any file outside this plan's declared set.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `grep -c '^axiom ' MintBound.lean` reports 0.
- The resulting lemmas carry no undischarged `WorldWitness` — or, on a fallback route, **exactly**
  the explicitly named residuals, each listed by name in the completion notes.
- The read-and-report findings for T2 and `chain_le_worldFuel'` are recorded in the completion notes.

---

### Phase 10: The mint potential and the budget-carrying restatement [NOT STARTED]

**Goal**: Work item 2 — give `expandBranchWithFuel_isSome_of_budget` an explicit **mint-budget
parameter** in the `branchesUsed`/`maxBranches` shape, and land the definitions and arithmetic
scaffolding it rests on. **This phase carries the plan's central design bet (R2).**

**Premise change under the revision — FLAGGED**: the invariant this phase carries into the arm-3
monotonicity argument is now `RunInvariant` (Phase 4.3) rather than `(IrreflOrd, OrdTimesLeMaxTime)`.
This is a **hypothesis-bundle rename**; it does not touch R2, which is about `rhoSF`'s
non-injectivity and is untouched by the strengthening. The bet is **still the plan's own unproved
proposal and still not machine-checked.**

**Tasks**:
- [ ] **Settle the measure design before writing the statement.** Proposed shape:
      ```
      mintPotential (U : Finset SignedFormula) (b : Branch) (ord : TimeOrdering) : Nat :=
        ((freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 p.2 b ord = false)).card
      ```
      with `freshLabelRules` the eight-element rule set. `mintPotential ≤ 8 * U.card` is then
      immediate. **The bet**: Phase 8 makes `witnessPresent` monotone, so `mintPotential` is
      non-increasing along a run and strictly decreases on a mint — a *per-state* quantity the
      induction can carry.
- [ ] **Settle the arm-3 obligation first, before any induction is written.** Arm 3 renames via
      `rhoSF`, which is **not injective on `U`**, so `mintPotential(after) ≤ mintPotential(before)`
      is not immediate from Phase 6: it needs an injection from the after-false set into the
      before-false set, and a `(rule, sf')` false after arm 3 need not lie in `rhoSF`'s image. Reach
      that goal and discharge it explicitly.
      **Named alternative if it does not discharge**: define the potential over the *pre-renaming*
      pair set and transport the filter along `rhoSF` (i.e. measure
      `(freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 (rhoSF t₂ t₁ p.2) b' ord' = false)`),
      turning the injection obligation into a pointwise implication Phase 6 already supplies. Try
      this before escalating.
- [ ] **Confirm R3 is broken.** Before writing the statement, confirm from Phase 9's findings that
      `Tmax` — and hence `|U| = |signedUniverse C L|` — is supplied independently of the mint chain,
      i.e. from T2's `timeFinset_card_le_of_not_blocked` (`Fuel.lean:588`). Record the confirmation.
      If Phase 9 could not supply it, **escalate here** rather than writing a statement whose
      hypotheses are circular.
- [ ] Land `mintBudget_preserved`, the arithmetic mirror of the landed `splitBudget_preserved`: a
      step consumes at most one unit of mint budget, so used-and-remaining is invariant across
      extending and splitting steps.
- [ ] State `expandBranchWithFuel_isSome_of_budget` with the mint budget as an explicit parameter,
      `NoSplit` **deleted**, `hT`/`TimeBounded` instantiated at `Tmax` from Phase 9 (not assumed),
      `RunInvariant` on the initial `(b, ord)` as the carried side condition, and the fuel figure
      the landed `splitAwareFuel` supplies. **Do not prove it here** — Phase 13 closes the induction.
      Land the statement plus its scaffolding so Phases 11-12 have a fixed target.
- [ ] Record in-source, adjacent to the statement, **why the section-4 impossibility does not apply**:
      it rules out the three-component linear family
      `Ψ = A·(|U| − |b|) + B·|knownTimes| + C·|incompPairs|`, and `mintPotential` is a **fourth
      component outside that family**. Cite the components by name, never by report or task number.

**Timing**: 2.5 hours

**Depends on**: 4.3, 8, 9

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts (a) that `mintPotential` is monotone across all four result
shapes, (b) that `mintPotential ≤ 8 * |U|`, and (c) that `Tmax` is independently supplied. **(a) is
NOT machine-checked and is the plan's central design bet.** Confirm (a) at arm 3 **before** anything
else in this phase; confirm (c) from Phase 9's recorded findings. If (a) fails at arm 3 under both
the primary shape and the named alternative, that is a material finding about route (b) itself and
must be **reported plainly**, not worked around.

**Escalation clause**: if the arm-3 monotonicity cannot be established under either shape, mark the
phase `[BLOCKED]`, record the exact goal state, and stop. **Forbidden**: carrying the mint bound as
an undischarged hypothesis in the shape `hT` has (explicitly rejected by the user); pushing the
discharge onto task 412 (explicitly rejected); reintroducing `NoSplit`; narrowing to non-branching
runs; a `sorry`; a vacuous placeholder.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `mintPotential`, `mintBudget_preserved`, and the monotonicity lemma are sorry-free.
- `grep` confirms `NoSplit` does not appear in the new statement.
- `git diff --stat` shows no change under `FormalSystem/Metalogic/Decidability/Saturation.lean`
  (so `buildTableau`'s `fuel := 1000` and `expandBranchWithFuel`'s `maxBranches := 50000` are
  untouched).
- The R3 and arm-3 confirmations are recorded in the completion notes.

---

### Phase 11: `#mints ≤ 8·|U|` — the once-only bound [NOT STARTED]

**Goal**: The first link of the amortized chain: each `(rule, sf)` pair mints at most once, so the
total number of fresh-time mints along any path is bounded absolutely, with no reference to branch
growth.

**Premise under the revision**: **UNCHANGED.** This phase consumes source readings and Phase 8's
corollary; it does not consume an ordering-times invariant directly. It inherits whatever hypothesis
bundle Phase 8's corollary carries, which is now `RunInvariant` — a rename, not a new obligation.

**Tasks**:
- [ ] Prove the mint guard fact: `findApplicableRule` gates every `ruleMintsFreshLabel` rule on
      `witnessPresent rule sf branch timeOrd` in **both** the `.linear` and `.branching` arms
      (`Tableau.lean:1908`, `:1931`), and **instead of** the output-presence test, never in addition
      to it. Confirm this reading against the source before relying on it.
- [ ] Prove the post-mint fact: the rule's output **is** the witness (`Tableau.lean:2336` — all
      eight constructors return a syntactic cons whose head is the witness), so immediately after a
      mint `witnessPresent = true` for that pair.
- [ ] Combine with Phase 8 (never flips `true → false`) to get: a mint strictly decreases
      `mintPotential`, and a non-mint does not increase it.
- [ ] Conclude `#mints ≤ 8 * |U|` along any path, as a statement about the induction's carried
      counter — **absolute**, with no reference to branch growth.

**Timing**: 2 hours

**Depends on**: 8, 10

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the guard reading at `Tableau.lean:1908, :1931`, the
witness-is-the-output reading at `:2336`, and exactly eight minting constructors. Report 03 section 3
states all three and report 04 confirms the eight. Confirm each against the source **before** writing
the proofs; a guard that is `&&`-composed with an output-presence test rather than replacing it
would break the once-only argument and must be reported.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- The mint bound's statement mentions neither `|b|` nor branch growth, checkable by reading it.
- Sorry-free; `#print axioms` reports exactly the three standard axioms.

---

### Phase 12: The counting chain — identifications, shrinkage, extensions [NOT STARTED]

**Goal**: The remaining three links, each absolute.

**Premise under the revision**: **UNCHANGED.** All three inequalities rest on landed cardinality
lemmas and mention no ordering-times invariant.

**Tasks**:
- [ ] `#identifications ≤ |knownTimes|₀ + #mints`: each identification drops `|knownTimes|` by at
      least one (landed `knownTimes_card_lt_identifyTime`), each mint raises it by one. Note the
      payoff: this **derives** the time bound rather than assuming it, so `TimeBounded` is
      instantiated at `Tmax := |knownTimes|₀ + 8·|U|` rather than carried as an assumption — record
      that in-source, since it is what makes `hT` a discharged parameter rather than a residual.
- [ ] `total shrinkage ≤ #identifications · |U|`: each identification's `eraseDups` merge count is
      bounded by the number of formulas at the source time, hence by `|U|`. This is the *upper*
      bound; the refuted route (a) was a *lower* bound on the post-identification cardinality and is
      not re-attempted here — record the distinction in-source so a future reader does not conflate
      them.
- [ ] `#extensions ≤ |U| + total shrinkage`: the branch-as-a-set grows by at least one per extending
      step (landed `expandOnceUnblocked_card_lt`) and cannot exceed `|U|`; shrinkage is the only way
      budget returns.
- [ ] Assemble the path-length bound and check it against the landed `splitPathBound` /
      `splitAwareFuel` shapes so Phase 13's induction consumes a figure that already exists rather
      than a new one.

**Timing**: 2.5 hours

**Depends on**: 11

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts three inequalities whose premises are each landed
(`knownTimes_card_lt_identifyTime`, `expandOnceUnblocked_card_lt`, the `eraseDups` shape of
`Branch.identifyTime`). Confirm each premise's exact statement before use. If the assembled figure
does not fit `splitAwareFuel`'s shape, use the derived figure and **record the divergence** rather
than writing the plan's figure unchecked.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- Each of the three inequalities is a named sorry-free lemma.
- The `Tmax` instantiation is present in-source with the "derived, not assumed" note.

---

### Phase 13: Close the induction — `expandBranchWithFuel_isSome_of_budget` [NOT STARTED]

**Goal**: Prove Phase 10's statement, `NoSplit`-free, using Phase 12's chain.

**Premise change under the revision — FLAGGED**: the invariant the fuel induction carries is now
`RunInvariant` (Phase 4.3), and **the `.splitOrdered` arm is exactly where that matters**. Under
plan 03 this induction could not have been closed at all: the carried `OrdTimesLeMaxTime` is lost at
arm 3, so the inductive hypothesis would not have been re-establishable at the ordered split's third
arm. Re-establishing it is `expandOnceUnblocked_splitOrdered_ordTimesKnown`.

**Tasks**:
- [ ] Prove by induction on fuel, carrying `RunInvariant` as an inductive hypothesis alongside the
      budget. The `saturated` and `extended` arms carry over from the landed
      `expandBranchWithFuel_isSome_of_noSplit` (`Fuel.lean:1462`); re-establish `RunInvariant` at
      each successor from `expandOnceUnblocked_runInvariant` (Phase 4.3).
- [ ] `.split` arm: the landed `expand_split_fold_isSome` (`Fuel.lean:2237`) matches the goal's fold
      shape exactly; discharge the per-arm obligations with the landed
      `expandOnceUnblocked_split_card_lt`, `allocateFuelProportionally_ge`, and
      `splitBudget_preserved`.
- [ ] `.splitOrdered` arm: the landed `expand_splitOrdered_fold_isSome` (`Fuel.lean:2289`), plus
      Phase 10's `mintPotential` monotonicity at arm 3 and Phase 4.3's
      `expandOnceUnblocked_splitOrdered_ordTimesKnown` to re-establish the invariant — **this is the
      arm the previous plan could not close**, on two counts, and both are now supplied.
- [ ] Add a **branching non-vacuity witness** in the style of the landed `noSplit_nil` /
      `expandBranchWithFuel_nil_isSome` block, but at a branch that **actually splits**. This is not
      decoration: it is the mechanical demonstration that the mint budget did not silently become
      `NoSplit`. A theorem that only applied to unbranching runs would have removed `NoSplit` in name
      only.
- [ ] Leave the landed `expandBranchWithFuel_isSome_of_noSplit` and
      `expandBranchWithFuel_isSome_at_worldFuel'` in place. They are consumed elsewhere; this is an
      addition, not a replacement.

**Timing**: 2.5 hours

**Depends on**: 4.3, 10, 12

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that the split arms close with no hypothesis beyond the
mint budget, `RunInvariant`, the `splitAwareFuel` figure, and the β-linear branch budget. Inspect
the landed theorem's statement for residual hypotheses at phase end and **list any that appeared**.

**Escalation clause**: if the induction cannot be closed, mark the phase `[BLOCKED]` and report the
exact goal state. **Forbidden**: reintroducing `NoSplit` in any form or under any name; weakening to
an unbranching special case; substituting a different decomposition; dropping the non-vacuity
witness; a `sorry`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `grep` confirms `NoSplit` does not appear in the theorem's statement.
- The non-vacuity witness is at a genuinely branching branch, checkable by reading it.
- `#print axioms` reports exactly `[propext, Classical.choice, Quot.sound]`.

---

### Phase 14: The terminus, the register, and the full gate [NOT STARTED]

**Goal**: Land `buildTableauAt_isSome_of_budget`, append to the do-not-re-attempt register, and pass
the repo-wide gate.

**Premise change under the revision — FLAGGED**: the terminus must **discharge** `RunInvariant` at
the engine's own seed rather than carry it. `buildTableauAt` calls
`expandBranchWithFuel initialBranch fuel TimeOrdering.empty fc` (`Saturation.lean:2199`), so the
discharge is `runInvariant_initial` (Phase 4.3) — vacuous because `TimeOrdering.empty.constraints = []`.
A terminus that carried `RunInvariant` as a caller obligation would be a residual, and this plan does
not permit one here.

**Tasks**:
- [ ] State and prove `buildTableauAt_isSome_of_budget`: for `phi`, `fc`, and a quantified
      `maxBranches` satisfying the β-linear budget condition at the split-aware fuel figure,
      `(buildTableauAt phi <fuel figure> fc maxBranches).isSome = true`. **`RunInvariant` is
      discharged inside**, via `runInvariant_initial`, and does **not** appear in the statement.
- [ ] Discharge the top-level arms of `buildTableauAt` (`Saturation.lean:2196`): the
      `expandBranchWithFuel` call via Phase 13; the `saturateBlocked` call via the landed
      `saturateBlocked_isSome`; the two `findUnexpandedUnblockedWith` saturation tests via the landed
      blocking-aware certificate. The arm that made the original `buildTableau` non-total
      (`| some _ => none` after the post-blocking pass) is exactly what that certificate change
      eliminates — **verify that in the proof rather than assuming it**.
- [ ] Supply a caller-facing corollary at the engine's own seed, with `maxBranches` given as an
      explicit closed-form expression in `phi`, so a caller reads off a number rather than a proof
      obligation (the task's sub-obligation 3).
- [ ] Append the **do-not-re-attempt register**, as a section comment adjacent to the terminus so a
      future reader meets it where they would otherwise re-attempt it. Cite by declaration name and
      by refuting witness, **never** by task or report number:
      1. the unconditional `buildTableau_isSome`;
      2. `buildTableau_isSome_of_budget` in the original target shape (`maxBranches` quantified as
         the only new hypothesis, `soundFuel' φ` as the fuel), refuted by `φ = F(G p)` at
         `fuel = 229376`, `maxBranches = 10¹²`, cause `resolveOpenArm = none`;
      3. the `.splitOrdered` cardinality twin of the split-growth lemma;
      4. the `buildTableauAt` / `buildTableau` `allClosed` `iff`, which is false, not merely
         unproved;
      5. the unconditional (`IrreflOrd`-free) form of `witnessPresent_identifyTime`, false by the
         counterexample `witnessPresent_identifyTime_unconditional_false`;
      6. route (a), a lower bound on `(b.identifyTime t₂ t₁).toFinset.card` in terms of
         `b.toFinset.card`, dead by definition since `Branch.identifyTime = (b.map relabel).eraseDups`
         and shrinkage is bounded only by `|U|`;
      7. **new** — the preservation of `OrdTimesLeMaxTime` across the ordered split's identification
         arm, **refuted** (not merely unproved) by `ordTimes_identifyTime_arm3_false`; the settled
         repair is `OrdTimesKnown` with `ordTimesKnown_identifyTime`, and
         `ordTimesLeMaxTime_of_ordTimesKnown` records that this is a strengthening rather than a
         weakening. A reader who "simplifies" the run invariant back to the `≤ maxTime` form is
         re-attempting a refuted statement.
- [ ] Record for the consuming task in the implementation summary (**not** in-source): the
      replacement for the refuted `buildTableau_isSome` is against `buildTableauAt` /
      `BudgetedTableau`, **not** `buildTableau` / `ExpandedTableau`, and it carries a quantified
      branch budget plus any residual Phase 9 had to carry.
- [ ] Full-repo final gate.

**Timing**: 2 hours

**Depends on**: 13

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build` (full repo) green.
- `grep -c 'sorry' MintBound.lean` reports 0; `grep -c '^axiom ' MintBound.lean` reports 0.
- `lean_verify` on the fully-qualified terminus reports only
  `[propext, Classical.choice, Quot.sound]`.
- The terminus statement contains no `NoSplit` hypothesis and no `RunInvariant` hypothesis.
- All **seven** register entries are present in-source.
- `git diff` shows `Saturation.lean`, `Fuel.lean`, and `Tableau.lean` **unchanged by this task**.

---

## Success Criteria

- [ ] `buildTableauAt_isSome_of_budget` is landed, sorry-free, axiom-free, with no `NoSplit`
      hypothesis, no undischarged mint bound, and no carried `RunInvariant`.
- [ ] `OrdTimesKnown` is the carried run invariant, `ordTimesLeMaxTime_of_ordTimesKnown` witnesses
      that this is a **strengthening**, and every landed `OrdTimesLeMaxTime` declaration is
      byte-untouched.
- [ ] The ordered split's identification arm preserves the run invariant
      (`ordTimesKnown_identifyTime`, `expandOnceUnblocked_splitOrdered_ordTimesKnown`) — the Phase 4
      blocker is closed by proof, not by narrowing.
- [ ] The initial condition `runInvariant_initial` is landed and its vacuity is documented in-source
      as a property of `TimeOrdering.empty`, not of a narrowed statement.
- [ ] The mint budget is **discharged in-plan** (Phases 11-13), not carried as a caller obligation
      and not pushed onto task 412.
- [ ] The world dimension is supplied, or its absence is carried as exactly one explicitly named
      residual whose harmlessness is **proved**, not asserted.
- [ ] `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s
      `maxBranches := 50000` default are byte-identical to their pre-task form.
- [ ] `Fuel.lean`, `Saturation.lean`, and `Tableau.lean` are **BYTE-IDENTICAL**, verified by md5.
- [ ] The do-not-re-attempt register carries all seven entries, including the refuted arm-3
      preservation of `OrdTimesLeMaxTime`.
- [ ] `lake build` green repo-wide.

## Testing & Validation

- [ ] `lake build` green repo-wide at Phase 14 (and at any phase whose tier is `full`).
- [ ] Zero `sorry` and zero `^axiom ` in `MintBound.lean`.
- [ ] `#print axioms` / `lean_verify` on each phase's top-level declaration reports exactly
      `[propext, Classical.choice, Quot.sound]` (or a subset).
- [ ] md5 of `FormalSystem/Metalogic/Decidability/Saturation.lean`,
      `.../Verified/Termination/Fuel.lean`, and `.../Tableau.lean` unchanged at every phase end —
      currently `ae47004e06e77f2846cc3e1dfa408382`, `8a395bd7117a682c1f8302a2ac5f0f1f`, and
      `cfd82332c8e400ac97ab709ece5dfb4a`.
- [ ] The existing `SplitFuelProbes`, `ArmSettlingProbes`, and `BudgetedTableauProbes` `#guard_msgs`
      rows all still pass unchanged. They pin measured behavior and must not drift.
- [ ] `grep -inE 'task [0-9]|tasks [0-9]' FormalSystem/` reports nothing — no task-number citations
      in any deliverable.
- [ ] `grep 'NoSplit' MintBound.lean` reports nothing.
- [ ] Every phase that closes `[BLOCKED]` has its exact goal state recorded, and every carried
      residual hypothesis is named in the implementation summary.
- [ ] The branching non-vacuity witness (Phase 13) is at a genuinely branching branch.

## Artifacts & Outputs

- `specs/428_engine_totality_at_a_quantified_branch_budget/plans/04_ordtimesknown-strengthening-totality.md`
  (this file)
- `specs/428_engine_totality_at_a_quantified_branch_budget/plans/03_mint-bound-irreflexivity-totality.md`
  (**superseded but retained** — holds the full completion record for phases 1-3, 5-7 and the
  Phase 4 blocker record; **not edited by this revision**)
- `specs/428_engine_totality_at_a_quantified_branch_budget/scratch/05_ordtimesknown-repair-check.lean`
  (the machine-checked repair evidence Phase 4.1 transcribes; outside the build)
- `specs/428_engine_totality_at_a_quantified_branch_budget/summaries/04_ordtimesknown-strengthening-totality-summary.md`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — the irreflexivity
  invariant, the reachability transport stack, witness preservation, engine-level non-deletion,
  **`OrdTimesKnown` and the strengthened run invariant**, the mint potential, the amortized counting
  chain, the `NoSplit`-free `expandBranchWithFuel_isSome_of_budget`, the terminus, and the register.
- `FormalSystem/Metalogic/Decidability.lean` — one import line (already landed).
- **Unchanged, by design and verified by md5**:
  `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`,
  `FormalSystem/Metalogic/Decidability/Saturation.lean`,
  `FormalSystem/Metalogic/Decidability/Tableau.lean`.

## Rollback/Contingency

- Every phase is **purely additive** to a single file. Reverting a phase's commit restores the prior
  state with no downstream effect, because no existing declaration is edited anywhere — this is what
  makes shape (b) cheap and shape (a) expensive.
- The entire task is revertible by deleting `MintBound.lean` and its one import line.
- **If Phase 4.1 does not transcribe**: this contradicts the scratch file's exit-0 elaboration
  against this same module. Report the exact failure — it is a finding about namespace/binder drift,
  not about the repair. Do **not** re-derive the nine results from scratch.
- **If Phase 4.2 blocks** (R8, the branching analogue): Phases 1-3, 4, 4.1, 5-7 stand as landed
  value, including the full `OrdTimesKnown` primitive stack and arm-3 preservation. Mark the task
  `[PARTIAL]` with the goal state recorded. **Do not** restrict the statement to non-branching
  result shapes and **do not** delete the weak twins.
- **If Phase 4.3 blocks**: the invariant is machine-checked at all three arms already
  (`ordTimesKnown_splitOrdered_arms12` for arms 1-2, `ordTimesKnown_identifyTime` for arm 3), so a
  block here is an engine-level plumbing failure, not a mathematical one. Report the exact goal
  state; do **not** narrow the run invariant.
- **If Phase 9 blocks** after both routes: carry the undischarged item as one explicitly named
  hypothesis into the terminus and name it in the summary. **Do not** admit `WorldWitness` as an
  axiom.
- **If Phase 10 blocks** (the mint potential, R2): this is a finding about route (b) itself. Report
  it plainly with the exact goal state. Phases 1-9 stand as landed value. **Do not** substitute a
  carried mint-bound hypothesis, do not push the obligation onto task 412, and do not treat it as
  license to revisit route (a).
- Under no circumstance is a green terminus manufactured by reintroducing `NoSplit`, admitting a
  hypothesis as an axiom, narrowing a statement into vacuity, or leaving a `sorry`.
