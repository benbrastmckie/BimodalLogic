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

### Phase 4: Engine-level `IrreflOrd` across all four result shapes [COMPLETED]

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

### Phase 4.2: `OrdTimesKnown` at the branching shapes and at engine level [COMPLETED]

**Goal**: Supply the one piece of the repair that is **not** in the scratch file — the `.branching`
result-shape analogue — and lift the strong invariant to `expandOnceUnblocked`. **This phase is new
proof**, and it is where R8 lives.

**Tasks**:
- [x] Prove `applyRule_ordTimesKnown_branching`, the strong twin of the landed
      `applyRule_ordTimes_branching` (`MintBound.lean:1016`):
      `(hsf : sf ∈ b) (haux : OrdTimesKnown b ord) : ∀ nb ∈ branchingResultBranches b (applyRule rule sf b ord).1, OrdTimesKnown nb (applyRule rule sf b ord).2`.
      Transcribe the weak twin's proof skeleton and make exactly these substitutions:
      `le_maxTime hsf` → `mem_knownTimes_of_mem hsf`; `ordTimes_mono` → `ordTimesKnown_mono`; the
      three `ordTimes_*_cons` → their `ordTimesKnown_*_cons` twins. Branch growth is identical
      (`branchingResultBranches` maps `fs ++ b`, covered by `sub_append`). Carry
      `set_option maxHeartbeats 4000000 in` from the weak twin — do **not** raise it further; if the
      elaboration budget is exceeded, **report the measured time** rather than raising it silently.
- [x] Prove the strong pick-stage lemma `pickBranches_ordTimesKnown`, the twin of the landed private
      `pickBranches_ordTimes` (`:1127`), joining the non-branching and branching `applyRule` lemmas.
      Reuse the landed `pick_stage_source` (`:1085`) unchanged — it supplies
      `∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)` and is invariant-agnostic.
- [x] Prove `expandOnceUnblocked_ordTimesKnown`, the twin of the landed `expandOnceUnblocked_ordTimes`
      (`:1152`): `(haux : OrdTimesKnown b ord) : ∀ nb ∈ unorderedSuccessorBranches (expandOnceUnblocked b ord fc tr).1, OrdTimesKnown nb (expandOnceUnblocked b ord fc tr).2`.
      Reuse the landed `pick_ord_eq` and `pick_branches_eq` unchanged — both are invariant-agnostic.
- [x] Prove the strong `expandOnceUnblocked_irreflOrd_of_known`:
      `(hord : IrreflOrd ord) (haux : OrdTimesKnown b ord) : IrreflOrd (expandOnceUnblocked b ord fc tr).2`.
      **Do not re-prove the case analysis.** Compose: `expandOnceUnblocked_irreflOrd hord (ordTimesLeMaxTime_of_ordTimesKnown haux)`.
      Expect one line. The landed weak-threaded `expandOnceUnblocked_irreflOrd` stays in place as the
      lemma this is built from.
- [x] Add an in-source note, adjacent to the strong engine-level results, recording that the weak
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

### Phase 4.3: The ordered split closes — `IrreflOrd` becomes a run invariant [COMPLETED]

**Goal**: Close the Phase 4 blocker. Prove that `OrdTimesKnown` survives **every** arm of the
ordered split, including arm 3, and package the pair `(IrreflOrd, OrdTimesKnown)` as the run
invariant the fuel induction carries. **This is the deliverable the whole revision exists for.**

**Tasks**:
- [x] Prove `expandOnceUnblocked_splitOrdered_ordTimesKnown`: given
      `(expandOnceUnblocked b ord fc tr).1 = .splitOrdered bs` and `OrdTimesKnown b ord`, every
      `p ∈ bs` satisfies `OrdTimesKnown p.1 p.2`. Route: `expandOnceUnblocked_splitOrdered_shape`
      (landed, `:788`) supplies the exact three-arm list and the trigger
      `firstIncomparablePair b ord = some (t₁, t₂)`; arms 1-2 are
      `ordTimesKnown_splitOrdered_arms12 htrig haux` (branch literally unchanged); **arm 3** is
      `ordTimesKnown_identifyTime haux`, which needs neither the trigger nor `IrreflOrd`.
- [x] Package the run invariant as a single named definition, e.g.
      `RunInvariant (b : Branch) (ord : TimeOrdering) : Prop := IrreflOrd ord ∧ OrdTimesKnown b ord`,
      so Phases 8, 10, 13 and 14 consume **one** name rather than a two-element bundle spelled out
      at every call site. Supply its two projections and the derived weak form
      (`ordTimesLeMaxTime_of_ordTimesKnown ∘ .2`).
- [x] State and prove `expandOnceUnblocked_runInvariant`: the invariant holds at every successor of
      an unblocked expansion step — `.extended` and `.split` arms from 4.2 plus
      `expandOnceUnblocked_irreflOrd_of_known`; `.splitOrdered` arms from this phase's first task
      plus the landed `expandOnceUnblocked_splitOrdered_irreflOrd` (which carries over unchanged —
      it takes only `IrreflOrd ord`); `.saturated` contributes no successor.
- [x] Prove `runInvariant_initial (b : Branch) : RunInvariant b TimeOrdering.empty`, from
      `ordTimesKnown_empty` and the vacuous `IrreflOrd TimeOrdering.empty`. Docstring must repeat the
      initial-condition note from 4.1: vacuous **because the seed ordering has no constraints**, not
      because anything was narrowed.
- [x] Add an in-source section note recording that this closes the obligation the weak invariant
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

### Phase 8: Witness monotonicity and one-step preservation, all four shapes [COMPLETED]

**Goal**: Turn arm-3 preservation into a statement about **every** expansion step, which is what the
mint counting actually consumes. This phase is **new proof**, not transcription.

**Premise change under the revision — FLAGGED**: this phase's `.splitOrdered` arm-3 bullet consumes
`IrreflOrd` *carried along a run*. Under plan 03 that meant carrying
`(IrreflOrd, OrdTimesLeMaxTime)`; it now means carrying `RunInvariant` (Phase 4.3). This is a
**hypothesis-bundle rename with no change to the proof content** — `arm3_preserves_witness` itself
is untouched, and the weak form is still available from `RunInvariant` by projection where any
`OrdTimesLeMaxTime` consumer needs it.

**Tasks**:
- [x] Prove `witnessPresent` is monotone in the branch:
      `b ⊆ b' → witnessPresent rule sf b ord = true → witnessPresent rule sf b' ord = true`.
      Every clause is a `contains` / `any … contains` test, so this is a `List.Subset` argument on
      `Branch.contains`. *(landed as `witnessPresent_branch_mono`, with helpers `contains_mono`
      and `knownWorlds_mono`)*
- [x] Prove `witnessPresent` is monotone in the ordering:
      `ord.constraints ⊆ ord'.constraints → witnessPresent rule sf b ord = true → witnessPresent rule sf b ord' = true`,
      via the landed `futureOf_mono` / `pastOf_mono` and `addFuture_constraints_mono`.
      *(landed as `witnessPresent_ord_mono`; `futureOf_mono`/`pastOf_mono` live in the
      `TimeOrdering` namespace and must be qualified. Needed the module's standing
      `maxHeartbeats 4000000` — not raised beyond it.)*
- [x] Combine into `expandOnceUnblocked_preserves_witness`, for each of the four result shapes:
      *(landed. The prerequisite the plan did not name — engine-level **ordering growth** — was
      stated and proved first as `applyRule_ord_mono` → `pickOrd_mono` →
      `expandOnceUnblocked_ord_mono`, mirroring the `applyRule`-level case analysis the invariant
      lemmas use. Branch growth needed one new shape lemma too:
      `expandOnceUnblocked_extended_shape` (the `.extended` mirror of `Fuel.lean`'s
      `expandOnceUnblocked_split_shape`, which exists only for `.split`), joined with the landed
      `expandOnceUnblocked_split_subset` in `expandOnceUnblocked_branch_mono`. Scope Hypothesis (a)
      is thereby **CONFIRMED BY PROOF**, not by reading.)*
      - `.extended nb`: `nb = fs ++ b` (`Tableau.lean:2234, 2238`), so branch monotonicity; the
        ordering only ever grows by `addFuture` / `addPast`, so ordering monotonicity.
      - `.split bs`: every arm is `fs ++ b` via the landed `expandOnceUnblocked_split_subset`.
      - `.splitOrdered` arms 1-2: branch literally unchanged, ordering grows —
        `expandOnceUnblocked_splitOrdered_shape` plus ordering monotonicity.
      - `.splitOrdered` arm 3: Phase 6's `arm3_preserves_witness`, with `IrreflOrd` supplied by
        `RunInvariant.1` (Phase 4.3) rather than by a standalone hypothesis.
      - `.saturated`: no successor branch, vacuous.
- [x] State the corollary in the form the counting needs: **`witnessPresent` never flips
      `true → false` along a run** (up to the arm-3 renaming), stated against `RunInvariant`.
      *(landed as `witnessPresent_no_flip`. At an ordered split, "the successor reports no witness"
      is the conjunction of `sf` and `rhoSF t₂ t₁ sf` both reporting none — the renaming is bound
      by an explicit `firstIncomparablePair b ord = some (t₁, t₂)` hypothesis rather than an
      existential, so the corollary and the theorem it contraposes share one quantifier shape and
      compose without re-deriving the trigger.)*

**Timing**: 2 hours

**Depends on**: 6, 7

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that (a) the ordering only ever grows by edge addition
except at arm 3, and (b) every `witnessPresent` clause is monotone in both arguments.
**(b) CONFIRMED** by reading `witnessPresent`'s body (`Tableau.lean:1838`): eight real arms plus a
`_ => false` default; every real arm is a `knownWorlds`/`futureOf`/`pastOf` `any` search whose body
is a positive combination of `Branch.contains` tests joined by `||` and `&&`. **No negation
anywhere, so no anti-monotone clause.** **(a) CONFIRMED BY PROOF**, not merely by reading:
`applyRule_ord_mono` discharges it at rule level over the full 36-constructor × 2-sign split —
every rule either returns `ord` unchanged, prepends one edge (`addFuture`/`addPast`), or prepends
two (`densityRule`); `timeLinearity` returns `ord` itself in the second component, its per-arm
orderings living inside the result — and `expandOnceUnblocked_ord_mono` lifts it through the three
pick stages. The single exception the hypothesis already carved out, arm 3, is exactly where the
proof routes through `arm3_preserves_witness` instead. No anti-monotone clause was found in either
argument.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `expandOnceUnblocked_preserves_witness` covers all four shapes, checkable by reading the statement.
- Sorry-free; `#print axioms` reports exactly the three standard axioms.

**Completion notes**: green on the **first** build attempt for tasks 3-4. Measured whole-module
`lake build` after tasks 3-4: **130s wall / 6m03s user** (tasks 1-2 measured 120s / 5m10s), so the
seven new declarations — including one further 36 × 2 case split in `applyRule_ord_mono` — cost
about 10s wall. The R6/R8 elaboration worry did not compound. **No `set_option` was added or
raised**: `applyRule_ord_mono` closes inside the module's default budget, unlike
`witnessPresent_ord_mono`, which needed the standing `maxHeartbeats 4000000`. `lean_verify` on
`applyRule_ord_mono`, `expandOnceUnblocked_preserves_witness` and `witnessPresent_no_flip` each
reports exactly `[propext, Classical.choice, Quot.sound]`.

---

### Phase 9: The world dimension and an independent `Tmax` [COMPLETED]

**Goal**: Supply the world dimension so that `|U|` is a real number rather than a circular one, and
supply `Tmax` **independently of the mint chain** so R3 does not bite.

**Premise under the revision**: **UNCHANGED.** This phase concerns `WorldWitness`, `worldFinset`,
and `timeFinset` and consumes no ordering-times invariant. Its unattempted-`WorldWitness` risk (R4),
its named fallback, and its never-an-axiom clause are **preserved verbatim** from plan 03.

**Tasks**:
- [x] **Read first, prove second.** Read `chain_le_worldFuel'` (`Fuel.lean:2619`),
      `worldFinset_card_le` (`:1230`), `worldWitness_self` (`:1302`), and
      `timeFinset_card_le_of_not_blocked` (`:588`), and record in the completion notes exactly what
      each supplies and what each demands. `chain_le_worldFuel'`'s docstring states that
      `hww : WorldWitness C S (run n)` is an invariant **not discharged there** — that is the
      warning sign for this phase. *(done — findings recorded below.)*
- [x] **Confirm T2 delivers `Tmax` in a consumable form** (R3). `timeFinset_card_le_of_not_blocked`
      is landed and bounds `Branch.timeFinset.card`; confirm its hypotheses are satisfiable along an
      engine run before building anything on it. If it is not consumable, say so explicitly and take
      the fallback below — do **not** reshape `TimeTypeBound.lean` (outside scope).
      *(**CONFIRMED, and landed as a lemma rather than left as prose**: `timeFinset_card_le_of_mem_stock`.
      The one hypothesis that looked like it might not be reachable, `TimeChain b ord`, is supplied
      by the landed `timeChain_of_linearity_saturated` from `firstIncomparablePair b ord = none`.
      No fallback needed.)*
- [x] Discharge `WorldWitness` for the engine's seed configuration
      (`initialBranch = [SignedFormula.neg phi Label.initial]`, so `S.card = 1`). Scope to the seed
      run, not the general invariant. *(landed as `seedBranch`, `seedWorlds_card` — which **computes**
      `|S| = 1` by `rfl` rather than assuming it — and `worldWitness_seedBranch`. This is the seed
      branch only; the run-level invariant is NOT discharged — see the residual note below.)*
- [x] Derive `hL : L.card ≤ (s + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card)` at `s = 1` via
      `worldFinset_card_le`, in the exact shape the downstream phases consume.
      *(landed as `labelFinset_card_le_of_worldWitness` at general `s`, and
      `labelFinset_card_le_at_seed_worlds` at `s = 1`.)*
- [ ] **Named fallback for `Tmax`** *(not taken — T2 delivered; `timeFinset_card_le_of_mem_stock` is landed)*, taken only if T2 does not deliver: bound fresh-time mints
      directly by the `witnessPresent` guard — each existential signed formula mints at most one
      witness and the existential formulas live in `U`. This route **reintroduces R3's circularity**
      unless `|U|` is closed first; if taken, the phase must state precisely how the circularity is
      broken, or escalate.
- [ ] **Named fallback for `WorldWitness`** *(not taken — the primary induction closed; see the run-level completion notes)*, taken only if the induction over `applyRule` does not
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

#### Completion notes so far (tasks 1-4 landed; tasks 5-6 not reached)

**Read-and-report findings (task 1).**

| Declaration | Supplies | Demands |
|---|---|---|
| `timeFinset_card_le_of_not_blocked` (`Fuel.lean:588`) | `b.timeFinset.card ≤ 2 ^ (2·\|C\|)` — a function of the **stock alone** | branch-in-stock, `TimeChain b ord`, eventualities fulfilled-or-duplicated, `findBlockedTime = none` |
| `timeChain_of_linearity_saturated` (`:1001`) | `TimeChain b ord` | `firstIncomparablePair b ord = none` — the linearity stage's own silence, since `timeLinearity` is self-suppressing |
| `worldFinset_card_le` (`:1230`) | `\|worlds\| ≤ \|S\| + 2·\|C\|·\|times\|` | `WorldWitness C S b` |
| `worldWitness_self` (`:1302`) | `WorldWitness C b.worldFinset b` | nothing — but only at `S := b.worldFinset`, degenerate unless `\|S\|` is separately known small |
| `Branch.card_labelFinset_le` (`:519`) | `\|labels\| ≤ \|worlds\|·\|times\|` | nothing |
| `chain_le_worldFuel'` (`:2619`) | `n ≤ worldFuel' φ \|S\|` | eight hypotheses **including `hww : WorldWitness C S (run n)`, explicitly not discharged there** |

**R3 is broken — confirmed, and the confirmation is a landed lemma, not prose.**
`timeFinset_card_le_of_mem_stock` composes the first two rows. Its four hypotheses are
branch-in-stock, linearity-saturated, eventuality-fulfilled, blocking-silent; **none of the four
mentions a world, a mint, or `\|U\|`**, and its conclusion `2 ^ (2·\|C\|)` is a function of the
stock alone. The mint chain may therefore rest on it without circularity. Phase 10's third task
(the R3 read-and-confirm) can cite this row and this lemma rather than re-deriving it.

**Scope Hypothesis, `applyRule` arm count**: the plan's "~36-case induction" figure is **CONFIRMED**
— `TableauRule` has exactly 36 constructors, the same count Phase 7 established and Phases 4.2 and
8 have now each paid for twice (36 × 2 signs). The phase sizing stands.

**THE RESIDUAL IS NOW DISCHARGED — the run-level `WorldWitness` induction closed.** What the
first pass left open (`WorldWitness` at the seed branch only, the `n = 0` case) is now proved as a
run invariant. R4 is retired by proof, not by fallback; **neither named fallback was taken**, and
the escalation clause's sanctioned degraded outcome was **not** invoked.

**The definition really was not inductive, and the repair is the one the first pass predicted.**
`WorldWitness` (`Fuel.lean:1214`) constrains `wit w` only by `(wit w).formula ∈ C` and
`(wit w).label.time ∈ b.timeFinset` — not by branch membership and not by sitting at the world it
witnesses. Both are needed at a mint, because the only reason the new world's signature is fresh
is that a matching witness **on the branch** would have made `witnessPresent` true and suppressed
the rule. `WorldWitnessKnown` adds exactly those two clauses; `worldWitness_of_known` recovers the
weak form, so every landed `WorldWitness` consumer keeps working. `Fuel.lean` is byte-untouched.

**The world dimension is far narrower than the "~36-case induction" figure suggested, and this is
a material finding about the sizing rather than about the plan.** Of `TableauRule`'s 36
constructors exactly **two** mint a world — `boxNeg` and `diamondPos` — and both do it by emitting
at `Branch.nextWorld`. The split still has to be paid once, to show the *other* 34 introduce no
world (`applyRule_emitted_world_mem`, stated against `RuleResult.emitted` so one statement covers
all five result shapes), but the content of the invariant lives in two named cases rather than
thirty-six.

**What landed, in dependency order.**

| Declaration | What it settles |
|---|---|
| `applyRule_emitted_world_mem` | The 34 non-minting rules emit only at worlds the branch already mentions. The full 34 × 2 split. |
| `applyRule_boxNeg_emitted_world`, `applyRule_diamondPos_emitted_world` | The two minting rules emit **only** at `Branch.nextWorld` — witness and both auto-propagation blocks alike. |
| `applyRule_boxNeg_shape` / `_eq` / `_witness` / `_result` (and the `diamondPos` mirrors) | A world appeared ⇒ the trigger had the rule's own shape ⇒ the result is `.linear` ⇒ the rule's own witness is on the successor. |
| `boxNeg_guard_sig`, `diamondPos_guard_sig` | **The guard, in signature form.** `witnessPresent`'s scan is world-indifferent, so its failure says exactly that no branch formula shares the minted witness's signature. This is the injectivity clause. |
| `worldWitnessKnown_of_no_new_world`, `worldWitnessKnown_mint` | The two preservation shapes, stated abstractly over the successor. |
| `applyRule_worldWitnessKnown` | One rule application preserves the strong discipline at every successor branch. |
| `findApplicableRule_guard_mint`, `findApplicableSerialRule_rule`, `findApplicableLinearityRule_rule`, `pick_stage_source_guarded` | The guard recovered from the pick. Stages two and three need none: they run one rule each and neither is world-minting. |
| `expandOnceUnblocked_worldWitnessKnown` | Engine level, `.extended` and every arm of a `.split`. |
| `worldWitnessKnown_seedBranch`, `worldWitnessKnown_chain` | Base case and the induction over an `ExtendStep` chain, with the stock hypothesis supplied at each step by `branchStock_chain`. |
| `worldWitness_chain_of_seed`, `labelFinset_card_le_of_seed_run`, `chain_le_worldFuel'_of_seed` | The payoff: `chain_le_worldFuel'`'s `hww` is discharged for runs out of the engine's own seed, at `S.card = 1`. |

**A real limitation, recorded rather than glossed: the ordered split's identification arm breaks
the injectivity clause.** `rho` *merges* two times, so two non-seed worlds whose witnesses differ
only in carrying the merged pair have distinct signatures before arm 3 and the same signature
after it. `WorldWitnessKnown` is therefore **not** transported along `rhoSF` — the same shape of
failure `ordTimes_identifyTime_arm3_false` records for the ordering-times invariant, and it is a
property of the arm, not a gap in the proof.

It costs nothing here, and the reason is structural rather than lucky: `ExtendStep`
(`Fuel.lean:423`) is defined as `(expandOnceUnblocked b ord fc tr).1 = .extended nb`, so every run
`chain_le_worlds_bounded` and `chain_le_worldFuel'` quantify over is `.extended`-only — no split of
either kind occurs along it. A consumer that needs the discipline **across** an ordered split would
need a repair of the same shape as `OrdTimesKnown`, and does not have one. This is recorded
in-source adjacent to `expandOnceUnblocked_worldWitnessKnown`.

**Build (R6/R8)**: green on the **first** attempt at both milestones. Whole-module `lake build`
**150s wall / 8m23s user** after the `applyRule`-level block (was 130s / 6m03s), and **143s wall /
9m01s user** after the engine lift. The 34 × 2 split cost about 20s wall. `set_option
maxHeartbeats` was raised to `4000000` for `applyRule_emitted_world_mem` only (the module's
standing figure, not above it) and to `1000000` for the per-rule shape lemmas. `lean_verify` /
`#print axioms` on `applyRule_worldWitnessKnown`, `expandOnceUnblocked_worldWitnessKnown`,
`worldWitnessKnown_chain`, `worldWitness_chain_of_seed`, `labelFinset_card_le_of_seed_run` and
`chain_le_worldFuel'_of_seed` each reports exactly `[propext, Classical.choice, Quot.sound]`.

**Build**: green on the first attempt; whole-module `lake build` 130s wall / 6m03s user, unchanged
from the Phase 8 figure. `lean_verify` on `worldWitness_seedBranch`,
`timeFinset_card_le_of_mem_stock` and `labelFinset_card_le_at_seed_worlds` each reports exactly
`[propext, Classical.choice, Quot.sound]`.

---

### Phase 10: The mint potential and the budget-carrying restatement [COMPLETED]

**Goal**: Work item 2 — give `expandBranchWithFuel_isSome_of_budget` an explicit **mint-budget
parameter** in the `branchesUsed`/`maxBranches` shape, and land the definitions and arithmetic
scaffolding it rests on. **This phase carries the plan's central design bet (R2).**

**Premise change under the revision — FLAGGED**: the invariant this phase carries into the arm-3
monotonicity argument is now `RunInvariant` (Phase 4.3) rather than `(IrreflOrd, OrdTimesLeMaxTime)`.
This is a **hypothesis-bundle rename**; it does not touch R2, which is about `rhoSF`'s
non-injectivity and is untouched by the strengthening. The bet is **still the plan's own unproved
proposal and still not machine-checked.**

**Tasks**:
- [x] **Settle the measure design before writing the statement.** *(deviation: altered — the landed
      `mintPotential` carries an explicit accumulated-renaming parameter `σ` and filters on
      `witnessPresent p.1 (σ p.2) b ord = false`. The shape below is the `σ = id` specialization
      and is not preserved by the identification arm; see task 2.)* Proposed shape:
      ```
      mintPotential (U : Finset SignedFormula) (b : Branch) (ord : TimeOrdering) : Nat :=
        ((freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 p.2 b ord = false)).card
      ```
      with `freshLabelRules` the eight-element rule set. `mintPotential ≤ 8 * U.card` is then
      immediate. **The bet**: Phase 8 makes `witnessPresent` monotone, so `mintPotential` is
      non-increasing along a run and strictly decreases on a mint — a *per-state* quantity the
      induction can carry.
- [x] **Settle the arm-3 obligation first, before any induction is written.** *(settled by the
      plan's own named alternative, landed as `mintPotential_identifyTime` — a proved lemma, not a
      note. No injection was needed and none was built.)* Arm 3 renames via
      `rhoSF`, which is **not injective on `U`**, so `mintPotential(after) ≤ mintPotential(before)`
      is not immediate from Phase 6: it needs an injection from the after-false set into the
      before-false set, and a `(rule, sf')` false after arm 3 need not lie in `rhoSF`'s image. Reach
      that goal and discharge it explicitly.
      **Named alternative if it does not discharge**: define the potential over the *pre-renaming*
      pair set and transport the filter along `rhoSF` (i.e. measure
      `(freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 (rhoSF t₂ t₁ p.2) b' ord' = false)`),
      turning the injection obligation into a pointwise implication Phase 6 already supplies. Try
      this before escalating.
- [x] **Confirm R3 is broken.** *(**CONFIRMED, and the confirmation is a landed lemma rather than
      a reading**: `timeFinset_card_le_of_mem_stock`. Its four hypotheses — branch-in-stock,
      linearity-saturated, eventuality-fulfilled, blocking-silent — mention no world, no mint and
      no `|U|`, and its conclusion `2 ^ (2·|C|)` is a function of the stock alone. Nothing further
      is owed here; do not re-derive it.)* Before writing the statement, confirm from Phase 9's findings that
      `Tmax` — and hence `|U| = |signedUniverse C L|` — is supplied independently of the mint chain,
      i.e. from T2's `timeFinset_card_le_of_not_blocked` (`Fuel.lean:588`). Record the confirmation.
      If Phase 9 could not supply it, **escalate here** rather than writing a statement whose
      hypotheses are circular.
- [x] Land `mintBudget_preserved`, the arithmetic mirror of the landed `splitBudget_preserved`: a
      step consumes at most one unit of mint budget, so used-and-remaining is invariant across
      extending and splitting steps.
- [x] *(deviation: altered — landed as the `Prop`-valued definition `BudgetedTotality`, not as an
      unproved `theorem`. A theorem statement cannot be landed without a proof and `sorry` is
      absolutely prohibited here; a named `Prop` fixes the target exactly as the task intends and
      Phase 13 proves `BudgetedTotality …`. Every element the task lists is present in it.)*
      State `expandBranchWithFuel_isSome_of_budget` with the mint budget as an explicit parameter,
      `NoSplit` **deleted**, `hT`/`TimeBounded` instantiated at `Tmax` from Phase 9 (not assumed),
      `RunInvariant` on the initial `(b, ord)` as the carried side condition, and the fuel figure
      the landed `splitAwareFuel` supplies. **Do not prove it here** — Phase 13 closes the induction.
      Land the statement plus its scaffolding so Phases 11-12 have a fixed target.
- [x] Record in-source, adjacent to the statement, **why the section-4 impossibility does not apply**:
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

#### Completion notes so far (task 3 discharged; task 2 analysed, not settled)

**Task 3 (R3) is discharged and needs no further work** — see the annotation above.
`timeFinset_card_le_of_mem_stock` is landed and non-circular by inspection of its hypotheses.

**Task 2 (the arm-3 obligation, R2) — analysis, explicitly NOT a settled result.** No Lean was
written for this phase, deliberately: the plan's own task order requires the arm-3 monotonicity to
be settled *before* the measure is committed to, and it is not settled. What is established:

- The primary shape's obligation is `mintPotential U b' ord' ≤ mintPotential U b ord` at
  `b' = b.identifyTime t₂ t₁`. Phase 8's `witnessPresent_no_flip` gives, at an ordered split, only
  the **two-premise** form: a successor reporting no witness for *both* `sf` and `rhoSF t₂ t₁ sf`
  implies no witness before. Counting needs one premise per pair, so it does not apply directly.
- Attempting the injection on the complement (true-before ↦ true-after) fails for the reason R2
  already names: the map `(r, sf) ↦ (r, rhoSF t₂ t₁ sf)` is **not injective on `U`**, because
  `rhoSF` merges `t₂` into `t₁`.
- **A concrete shape showing the primary measure is not obviously monotone**, recorded so a
  successor does not re-find it: after the arm, `b'` carries *nothing* at time `t₂`, so **every**
  pair whose formula sits at `t₂` reports no witness at `b'`. A pair at `t₂` whose witness was also
  at `t₂` was therefore `true` before and is `false` after — an *increase* in the potential at that
  pair. Whether the simultaneous decreases at `t₁` always dominate is exactly the open question;
  it has **not** been decided in either direction, and nothing here refutes the measure.
- **The plan's named alternative is the next thing to try, and it has a promising pointwise form.**
  Indexing the filter over the pre-renaming pair set turns the obligation into
  `witnessPresent r (rhoSF t₂ t₁ sf) b' ord' = false → witnessPresent r sf b ord = false`, which is
  the contrapositive of Phase 6's landed `arm3_preserves_witness` — available pointwise, with no
  injection. What is **not** yet worked out is how that step-indexed measure composes along a run
  with a second identification. That is the first thing the next dispatch should settle.

Per the phase's escalation clause this is **not** a `[BLOCKED]` outcome: the named alternative has
not been tried in Lean, so the route is not exhausted. Nothing was narrowed, substituted, or
admitted, and no statement was written that would have to be unwritten.

#### Completion notes — the phase closed; R2 is settled by proof

**The named alternative worked, and it worked in one attempt.** Every declaration below elaborated
green on the **first** try, in a scratch file against the built module, and then again unchanged
inside `MintBound.lean`. The escalation clause was not reached; nothing was narrowed, admitted, or
substituted.

**What settles R2.** `mintPotential` takes the accumulated renaming `σ` as an explicit parameter
and filters `freshLabelRules ×ˢ U` on `witnessPresent p.1 (σ p.2) b ord = false`. That keeps the
index set **fixed for the whole run**, so successive potentials are cardinalities of subsets of one
finset. Both step shapes then become pointwise *subset* facts, and **the injection R2 demands is
not needed and was not built**:

| Landed | What it settles |
|---|---|
| `freshLabelRules`, `freshLabelRules_card`, `mem_freshLabelRules` | The eight-rule index factor, with `Finset`/`Bool` agreement **proved** over all 36 constructors rather than asserted. |
| `mintPotential` | The measure, with the carried renaming. `σ = id` is the plan's proposed shape. |
| `mintPotential_le_eight_mul` | `mintPotential ≤ 8 · \|U\|` at every state and every `σ`. Scope Hypothesis (b) **CONFIRMED BY PROOF**. |
| `mintPotential_le_of_grow` | Ordinary steps do not increase it — `.extended`, `.split`, and ordered-split arms 1-2. |
| **`mintPotential_identifyTime`** | **Arm 3 does not increase it.** The contrapositive of `arm3_preserves_witness`, pointwise. **This is R2's obligation, discharged.** |
| `mintPotential_lt_of_mint` | A mint strictly decreases it, with the residual visible in the hypotheses (below). |
| `mintPotential_expandOnceUnblocked` | Engine level, unordered successors. |
| `mintPotential_expandOnceUnblocked_splitOrdered` | Engine level, all three ordered arms, each reporting which renaming the run carries onward. |
| `mintBudget_preserved`, `mintBudget_preserved_mint` | The per-step arithmetic, mirroring `splitBudget_preserved` / `extendBudget_preserved`. |
| `mints_le_eight_mul` | **The composition** — `#mints ≤ 8·\|U\|` over an arbitrary run, with arbitrarily many identifications. |
| `BudgetedTotality` | The fixed target for Phases 11-13. |

**The open piece the previous cycle named is now closed.** It asked how a step-indexed measure
composes along a run with a *second* identification. The answer is that the renaming is
**post-composed onto a parameter** rather than fixed inside the measure, so
`mintPotential_identifyTime` applies unchanged at the second, third and `n`-th identification;
`mints_le_eight_mul` is that composition, machine-checked over an arbitrary sequence of states,
renamings and mint counts.

**Scope Hypothesis (a), stated precisely rather than claimed wholesale.** "`mintPotential` is
monotone across all four result shapes" is **CONFIRMED** for the `σ`-carrying measure at every
shape, arm 3 included. It is **NOT** confirmed for the `σ`-free measure, and the plan's own
concrete shape (recorded above) is why: after the arm the branch carries nothing at `t₂`, so a pair
at `t₂` whose witness also sat at `t₂` was `true` before and is `false` after. That remains
undecided in both directions and is now moot — the committed measure does not depend on it.

**The residual, named.** `mintPotential_lt_of_mint` requires the minting pair to be **`σ`-hit**:
the formula the rule fires on must be `σ sf` for some `sf ∈ U`. `σ`'s image omits exactly the times
earlier identifications merged away, so the obligation is that a minting formula does not sit at a
merged-away time. **This is a question about time reuse, not about the measure**: `Branch.nextTime`
is `Branch.maxTime + 1` and `Branch.identifyTime` can lower `Branch.maxTime` (the configuration
`ordTimes_identifyTime_arm3_false` decides drops it from `5` to `0`), so a fresh time can in
principle re-issue a value an earlier identification removed. The "live times" reformulation —
filter additionally on the formula's time being a fixed point of `σ` — carries the *identical*
obligation, which is what shows it is intrinsic rather than an artifact of this shape. It is
**Phase 11's first obligation**, it appears as a visible hypothesis rather than an assumption, and
it is recorded in-source next to the lemma.

**Task 3 (R3)** needed no further work; the confirmation is restated in-source in the C3 section
note, citing `timeFinset_card_le_of_mem_stock`'s four world-free, mint-free, `|U|`-free hypotheses.

**Task 6** is in-source adjacent to `BudgetedTotality`: `mintPotential` is a **fourth component
outside** the linear three-component family `Ψ = A·(|U| − |b|) + B·|knownTimes| + C·|incompPairs|`
that the measured obstruction rules out — it mentions none of the three and is not a linear
combination of them.

**Build (R6/R8)**: green on the first attempt (measured twice, 122s/7m40s then 124s/7m48s after a
docstring-only edit). Whole-module `lake build` **124s wall / 7m48s user**, *down* from Phase 9's
143s / 9m01s despite +298 lines — the new block is `Finset`
cardinality reasoning with no case split over `TableauRule`, so it costs almost nothing. **No
`set_option` was added or raised anywhere in this phase**; every declaration closes at the module's
default budget. `#print axioms` on all eight new theorems reports exactly
`[propext, Classical.choice, Quot.sound]` (`freshLabelRules_card`, decided, reports the subset
`[propext, Quot.sound]`).

**Constraint status**: `Saturation.lean` `ae47004e06e77f2846cc3e1dfa408382`, `Tableau.lean`
`cfd82332c8e400ac97ab709ece5dfb4a`, `Fuel.lean` `8a395bd7117a682c1f8302a2ac5f0f1f` — all three
still match. `MintBound.lean` 2879 → 3177 lines, purely additive; no landed declaration edited,
renamed or deleted. 0 `sorry`, 0 `axiom`, 0 `NoSplit`, 0 task-number citations.

---

### Phase 11: `#mints ≤ 8·|U|` — the once-only bound [COMPLETED]

**Goal**: The first link of the amortized chain: each `(rule, sf)` pair mints at most once, so the
total number of fresh-time mints along any path is bounded absolutely, with no reference to branch
growth.

**Premise under the revision**: **UNCHANGED.** This phase consumes source readings and Phase 8's
corollary; it does not consume an ordering-times invariant directly. It inherits whatever hypothesis
bundle Phase 8's corollary carries, which is now `RunInvariant` — a rename, not a new obligation.

**Tasks**:
- [x] *(landed as `findApplicableRule_guard_linear` / `findApplicableRule_guard_branching`, with
      `not_selfGuarded_of_fresh`. **The reading is CONFIRMED against the source**: the guard is in
      the *else*-free position — `if ruleMintsFreshLabel rule then (witness test) else (output
      test)` — so it replaces the output-presence test rather than `&&`-composing with it, in both
      arms. The two unguarded shapes are excluded by taking the result shape as a hypothesis.)*
      Prove the mint guard fact: `findApplicableRule` gates every `ruleMintsFreshLabel` rule on
      `witnessPresent rule sf branch timeOrd` in **both** the `.linear` and `.branching` arms
      (`Tableau.lean:1908`, `:1931`), and **instead of** the output-presence test, never in addition
      to it. Confirm this reading against the source before relying on it.
- [x] *(landed as `applyRule_fresh_witness_nonbranching` and `applyRule_fresh_witness_branching`,
      covering all eight rules at both result shapes — the two branching rules' arms are proved
      individually, neither absorbed into the other.)*
      Prove the post-mint fact: the rule's output **is** the witness (`Tableau.lean:2336` — all
      eight constructors return a syntactic cons whose head is the witness), so immediately after a
      mint `witnessPresent = true` for that pair.
- [x] Combine with Phase 8 (never flips `true → false`) to get: a mint strictly decreases
      `mintPotential`, and a non-mint does not increase it. *(landed as
      `mintPotential_lt_of_pick_linear` / `mintPotential_lt_of_pick_branching` for the strict
      half; the non-increase half is Phase 10's `mintPotential_le_of_grow`,
      `mintPotential_identifyTime` and the two engine-level lemmas.)*
- [x] Conclude `#mints ≤ 8 * |U|` along any path, as a statement about the induction's carried
      counter — **absolute**, with no reference to branch growth. *(landed as
      `mints_le_eight_mul`, which came in with Phase 10's block because the composition question
      had to be settled there; its statement mentions no branch and no branch growth. Nothing was
      re-derived here.)*

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

#### Completion notes

**All three Scope Hypothesis readings CONFIRMED against the source before anything was built on
them, and the one that mattered most is confirmed in the strong direction.** The guard at
`Tableau.lean:1908` and `:1931` is in the `then` position of `if ruleMintsFreshLabel rule`, with
the output-presence test in the *else* branch — it **replaces** that test rather than
`&&`-composing with it, in both arms. An `&&`-composition would have broken the once-only
argument, and the phase said so in advance; it is not one. The `.branching` arm checks
`ruleSelfGuarded` first, and `not_selfGuarded_of_fresh` proves no fresh-label rule is
self-guarded, so the guard is always reached. The witness-is-the-output reading at `:2336` and the
eight-constructor count are both confirmed — the latter is now a proved `Finset`/`Bool` agreement
(`mem_freshLabelRules`) rather than a census.

**Landed**: `not_selfGuarded_of_fresh`; `findApplicableRule_guard_linear` /
`findApplicableRule_guard_branching` (the guard, generalised from the two world-minting rules of
`findApplicableRule_guard_mint` to all eight by taking the result shape as a hypothesis instead of
excluding the unguarded shapes rule by rule); `applyRule_fresh_witness_nonbranching` /
`applyRule_fresh_witness_branching` (the post-mint witness, all eight rules, **both** arms of each
branching rule proved individually); `mintPotential_lt_of_pick_linear` /
`mintPotential_lt_of_pick_branching` (the two halves meeting at the pick).

**The residual is unchanged and still visible.** `mintPotential_lt_of_pick_*` carries `hσ : σ sf =
sf₀` with `sf ∈ U` — the same `σ`-hit obligation Phase 10 named, now surfacing at the pick rather
than in the abstract. It is a hypothesis, not an assumption, and discharging it is a statement
about time reuse (see Phase 10's completion notes). Phases 12-13 own it.

**Build (R6/R8)**: green on the **first** attempt at both milestones. Whole-module `lake build`
**161s wall / 13m52s user** after the guard-and-witness block (was 124s / 7m48s), and **161s /
13m47s** after the pick-level block — the second block is free. The two witness lemmas are the
cost: `applyRule_fresh_witness_nonbranching` elaborates in ~66s standalone and
`applyRule_fresh_witness_branching` in ~121s, both being 36 × 2 splits with a `simp_all` inside
each surviving arm. `set_option maxHeartbeats 4000000` is carried on those two only — the module's
standing figure, **not raised above it**; every other declaration in this phase closes at the
default. `#print axioms` on all six new theorems reports exactly
`[propext, Classical.choice, Quot.sound]`.

**Constraint status**: `Saturation.lean`, `Tableau.lean`, `Fuel.lean` md5s all still match the
recorded baselines. `MintBound.lean` 3177 → 3370 lines, purely additive. 0 `sorry`, 0 `axiom`,
0 `NoSplit`, 0 task-number citations.

---

### Phase 12: The counting chain — identifications, shrinkage, extensions [COMPLETED]

**Goal**: The remaining three links, each absolute.

**Premise under the revision**: **UNCHANGED.** All three inequalities rest on landed cardinality
lemmas and mention no ordering-times invariant.

**Tasks**:
- [x] `#identifications ≤ |knownTimes|₀ + #mints`: each identification drops `|knownTimes|` by at
      least one (landed `knownTimes_card_lt_identifyTime`), each mint raises it by one. Note the
      payoff: this **derives** the time bound rather than assuming it, so `TimeBounded` is
      instantiated at `Tmax := |knownTimes|₀ + 8·|U|` rather than carried as an assumption — record
      that in-source, since it is what makes `hT` a discharged parameter rather than a residual.
- [x] `total shrinkage ≤ #identifications · |U|`: each identification's `eraseDups` merge count is
      bounded by the number of formulas at the source time, hence by `|U|`. This is the *upper*
      bound; the refuted route (a) was a *lower* bound on the post-identification cardinality and is
      not re-attempted here — record the distinction in-source so a future reader does not conflate
      them.
- [x] `#extensions ≤ |U| + total shrinkage`: the branch-as-a-set grows by at least one per extending
      step (landed `expandOnceUnblocked_card_lt`) and cannot exceed `|U|`; shrinkage is the only way
      budget returns.
- [x] Assemble the path-length bound and check it against the landed `splitPathBound` /
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

#### Completion notes

**Every premise was confirmed against the source before use, and all three landed as named
lemmas.** Each link is a fold of one per-step fact over an abstract carried counter — the shape
the phase's own text asks for ("a statement about the induction's carried counter") — so the
per-step hypotheses are exactly what Phase 13's induction will discharge from the engine lemmas
named beside them.

| Landed | Role |
|---|---|
| `fold_le_of_step` | The one fold all three links use. Additive form `f (i+1) + g i ≤ f i + g (i+1)`, so **no `Nat` subtraction appears anywhere** and `omega` closes every link. |
| `identStep_le`, `mintStep_le`, `plainStep_le` | The three per-step arithmetic facts of link 1. |
| `knownTimes_card_lt_at_arm3` | The concrete input: an identification drops the known-time count, with the trigger supplying `knownTimes_card_lt_identifyTime`'s three hypotheses. |
| `idents_le_knownTimes_add_mints` | **Link 1.** |
| `derivedTmax`, `derivedTmax_spec` | `Tmax := \|knownTimes\|₀ + 8·\|U\|`, **derived** from link 1 and `mints_le_eight_mul`; `BudgetedTotality`'s time hypothesis is satisfied at it definitionally. |
| `shrinkage_le_card` | One identification's loss is bounded by `\|U\|`. |
| `shrinkage_total_le` | **Link 2.** |
| `extensions_le` | **Link 3.** |
| `path_le_of_links`, `orderedRunBound_ge`, `path_le_splitPathBound` | The assembly, and the check against the landed figure. |

**The refuted-route distinction is recorded in-source**, adjacent to `shrinkage_le_card`: this is
an **upper** bound on the *loss*, which is available; route (a) sought a **lower** bound on the
*survivors*, which is dead by definition. A reader who reads the former as reviving the latter has
the direction backwards.

**Task 4's check came out clean and no divergence had to be recorded.** The assembled figure
`|U| + Tmax·|U| + Tmax` sits below `splitPathBound |U| Tmax = (|U| + 1) · (orderedRunBound Tmax + 1)`,
because `orderedRunBound Tmax ≥ Tmax` (`orderedRunBound_ge`) and the outer factor is `|U| + 1`. So
Phase 13 consumes `splitAwareFuel` **unchanged**; no new fuel figure is introduced.

**Build (R6/R8)**: green on the **first** attempt. Whole-module `lake build` **161s wall / 13m30s
user** — unchanged from Phase 11, because this block is `Nat` arithmetic with no case split over
`TableauRule`. **No `set_option` added or raised.** `#print axioms` reports exactly
`[propext, Classical.choice, Quot.sound]` throughout.

**Constraint status**: all three md5 baselines still match. `MintBound.lean` 3370 → 3524 lines,
purely additive. 0 `sorry`, 0 `axiom`, 0 `NoSplit`, 0 task-number citations.

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
