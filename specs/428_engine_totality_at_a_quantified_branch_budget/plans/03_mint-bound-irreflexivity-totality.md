# Implementation Plan: Task #428 — Route (b), the Mint Bound

- **Task**: 428 - engine_totality_at_a_quantified_branch_budget
- **Status**: [IMPLEMENTING]
- **Effort**: 22 hours
- **Dependencies**: None blocking. Consumes phases 1-10 of
  `plans/02_lexicographic-splitordered-measure.md` (landed, sorry-free, axiom-free, green) and the
  27 machine-checked lemmas in `scratch/04_witness-preservation.lean`. Coordinates with task 426 —
  see "The `Fuel.lean` placement decision" in the Overview, which resolves the hazard by not
  editing `Fuel.lean` at all.
- **Research Inputs**:
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/04_witness-preservation-machine-checked.md` (**primary, current ground truth**)
  - `specs/428_engine_totality_at_a_quantified_branch_budget/scratch/04_witness-preservation.lean` (27 machine-checked lemmas)
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/03_phase11-potential-obstruction.md` (route-(a) refutation and the section-4 impossibility proof remain load-bearing; its two UNCERTAIN markers are DISCHARGED by report 04)
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/01_budget-totality-refuted-and-repair.md`, `reports/02_splitordered-measure-blocker.md`
- **Artifacts**: plans/03_mint-bound-irreflexivity-totality.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, artifact-formats.md,
  lean4.md, plan-compliance.md, no-task-references-in-deliverables.md
- **Type**: lean4
- **Lean Intent**: true

---

## Overview

Route (b) — an independent bound on the number of fresh-time **mints** — is the user-approved path,
and the research gate on it is discharged. This plan lands it in four blocks: (A) the engine-level
irreflexivity invariant that report 04 discovered claim (i) silently depends on; (B) the witness
preservation stack, now conditional on (A); (C) a restatement of
`expandBranchWithFuel_isSome_of_budget` carrying an explicit mint budget; and (D) the amortized
counting chain and the terminus `buildTableauAt_isSome_of_budget`.

Phase mapping to the approved work shape: **A** = Phases 1-4, **B** = Phases 5-8, **C** = Phase 10,
**D** = Phases 9, 11-14. Phase 9 (the world dimension) is inherited from plan 02's unattempted
Phase 12 and is required by the task's DONE WHEN clause; it is sequenced early because it is the
highest-risk *inherited* item and running it early converts a late blocker into an early one.

### Research Integration

Everything in Phases 1, 4-7 is **transcription of already-elaborated Lean**, not new proof. Report
04's scratch file elaborates sorry-free with axioms `[propext, Classical.choice, Quot.sound]`. Two
findings reshape the plan relative to report 03's sketch:

1. **Claim (i) is CONDITIONAL on `IrreflOrd`** (`∀ p ∈ ord.constraints, p.1 ≠ p.2`). The
   unconditional form is FALSE by machine-checked counterexample: `identifyTime` drops pre-existing
   self-loops `(a,a)`, flipping `witnessPresent .allFutureNeg` from `true` to `false` on
   `ord = ⟨[(5,5)]⟩` with incomparability still holding. This is why Phases 1-4 exist and why they
   come first.
2. **The three lemmas report 03 called "already machine-checked" were never landed.**
   `mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`, `identifyTime_no_collapse`
   do not exist in the library. Phase 5 budgets for them explicitly.

Report 03 stays load-bearing for two things, neither superseded: its **route (a) refutation**
(`Branch.identifyTime = (b.map relabel).eraseDups`, so shrinkage is bounded only by `|U|` — dead by
definition, never revisited) and its **section 4 impossibility proof**. See "Why the section-4
impossibility does not block Phase 10" below.

#### A grounding correction report 04 did not make

Report 04 describes the nine fresh-time mint sites as `addFuture l.time freshTime`. Four of them are
actually `addPast`: `allPastNeg` (`Tableau.lean:801`), `somePastPos` (`:924`), `sncePos` (`:1168`),
and the `snceNeg` active arm (`:971`). `TimeOrdering.addPast t t_new = ⟨(t_new, t) :: constraints⟩`
(`SignedFormula.lean:689`), so the obligation is the same (`l.time ≠ freshTime`) but a mirror lemma
`irreflOrd_addPast` is needed alongside the machine-checked `irreflOrd_addFuture`. Phase 1 lands it.

#### Why the section-4 impossibility does not block Phase 10

Report 03 section 4 proves that no linear potential in the family
`Ψ = A·(|U| − |b|) + B·|knownTimes| + C·|incompPairs|` decreases at every arm. That is a statement
about **that three-component family**. This plan introduces a **fourth component** the family does
not contain — a *mint potential*, the count of `(rule, sf)` pairs that are still eligible to mint —
and witness preservation is exactly the fact that makes it monotone. The impossibility result
therefore does not apply. **This is the plan's central design bet and it is NOT machine-checked.**
Phase 10 carries a Scope Hypothesis and an escalation clause on it, with a named alternative.

### Prior Plan Reference

`plans/02_lexicographic-splitordered-measure.md` Phases 1-10 are landed, sorry-free, axiom-free, and
green repo-wide. This plan **consumes** them and re-proves nothing:

`splitOrderedMeasure`, `splitOrderedMeasure_lt_of_timeLinearity`, `splitOrderedRank`,
`splitOrderedRank_le`, `splitOrderedRank_lt_of_timeLinearity`, `orderedRunBound`, `splitPathBound`,
`splitAwareFuel`, `TimeBounded`, `incompPairs`, `incompPairs_card_le`, `incompPairs_mono`,
`incompPairs_lt_addFuture`, `expandOnceUnblocked_card_lt`, `expandOnceUnblocked_split_card_lt`,
`expandOnceUnblocked_split_subset`, `expandOnceUnblocked_split_arity_le`,
`expand_split_fold_isSome`, `expand_splitOrdered_fold_isSome`, `splitBudget_preserved`,
`extendBudget_preserved`, `budget_le_of_betaBudget`, `allocateFuelProportionally_ge`,
`allocateFuelProportionally_pos`, `firstIncomparablePair_spec`,
`applyRule_timeLinearity_arms_trigger`, `knownTimes_card_lt_identifyTime`,
`knownTimes_identifyTime_subset`, `bfsClosure_sound`, `bfsClosure_complete`, `PathN`,
`reachableForward_eq`, `reachableBackward_eq`, `futureOf_mono`, `pastOf_mono`,
`findApplicable{,Serial,Linearity}Rule_applyRule_eq`, `signedUniverse`, `card_signedUniverse_le`,
`WorldWitness`, `worldFinset_card_le`, `worldWitness_self`, `chain_le_worldFuel'`,
`timeFinset_card_le_of_not_blocked`, `expandBranchWithFuel_isSome_of_noSplit`,
`expandBranchWithFuel_isSome_at_worldFuel'`, `saturateBlocked_isSome`, `BudgetedTableau`,
`buildTableauAt`, `BudgetedTableau.upgrade`. From `Tableau.lean`: `le_maxTime`,
`not_mem_of_time_nextTime`.

Effort calibration from plan 02: its Phase 11 was estimated at 2.5 hours and blocked. Its Phases 5-9
each ran ~1.5-2 hours and landed. This plan sizes every phase at 1-2 hours accordingly and splits
the two riskiest obligations (`densityRule`, the mint potential) into their own phases so that a
block on either does not take a landed neighbour down with it.

### Roadmap Alignment

No `specs/ROADMAP.md` in this repository. No roadmap phases added.

### The `Fuel.lean` placement decision — stated explicitly, not left implicit

The 27 verified lemmas live in `specs/.../scratch/04_witness-preservation.lean`, outside the build.
The task record says task 428 and task 426 must not edit `Fuel.lean` concurrently; task 426 is
currently `not_started` with `Fuel.lean` in its `file_scope`.

**Decision: this plan does NOT edit `Fuel.lean` at all.** All new declarations land in a new module

```
FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean
```

which `import`s `FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel` and is registered by
a **one-line import addition** to `FormalSystem/Metalogic/Decidability.lean` (a file that is in
neither task's `file_scope` and that 426 has no reason to touch).

Rationale, and why the alternatives were rejected:

| Option | Verdict |
|---|---|
| Land in `Fuel.lean` | **Rejected.** Creates exactly the concurrent-edit hazard the task record forbids, and `Fuel.lean` is already 2,672 lines. |
| Wait for / merge with 426 | **Rejected.** 426 is `not_started` with no schedule; blocking on it converts a ready task into a stalled one, and 426's obstruction (`G p → □G p` anchor row) is unrelated to this chain. |
| New downstream module (chosen) | Everything needed is exported by `Fuel.lean`, which already imports `Saturation.lean` (it references `expandBranchWithFuel`, `resolveOpenArm`, `buildTableauAt`). Purely additive; nothing 426 could edit is touched. |

**Sequencing hazard, stated rather than assumed away**: if task 426 lands changes that *rename or
restate* a `Fuel.lean` declaration this plan consumes, `MintBound.lean` breaks at build time. That is
a loud, immediate failure (not a silent one) and the repair is a rename in one downstream file. The
consumed set is listed in "Prior Plan Reference" above so the blast radius is enumerable. This is
accepted as the cheaper risk; it is **not** claimed to be zero.

**`file_scope` note**: the task's declared `file_scope` lists `Fuel.lean` and `Saturation.lean`.
Per `state-management.md`, `file_scope` is descriptive/anticipated and is never validated against the
filesystem, so adding a new module downstream of both is not a scope violation. `Saturation.lean` is
**not** edited by this plan either.

---

## Goals & Non-Goals

**Goals**:
- Land the engine-level `IrreflOrd` invariant, with the `densityRule` sub-case either discharged or
  escalated as `[BLOCKED]` — never admitted, never narrowed.
- Land the full witness-preservation stack (all eight fresh-label rules, the ~24 vacuous rules
  proved vacuous) and engine-level non-deletion for all four `ExpansionResult` shapes.
- Land `expandBranchWithFuel_isSome_of_budget` with an explicit **mint-budget parameter** in the
  `branchesUsed`/`maxBranches` shape, `NoSplit`-free, and **discharge that parameter in-plan**.
- Land the terminus `buildTableauAt_isSome_of_budget`, sorry-free, axiom-free.
- Supply the world dimension, or prove its absence harmless.

**Non-Goals**:
- Editing `buildTableau`, its `fuel := 1000` default, or `expandBranchWithFuel`'s
  `maxBranches := 50000` default. All three stay **BYTE-IDENTICAL**. The budget-parameterised entry
  point (`buildTableauAt`, already landed) is an ADDITION alongside.
- Editing `Fuel.lean` or `Saturation.lean` at all (see the placement decision).
- Route (a). DEAD BY DEFINITION per the second retarget decision. Not revisited under any framing.
- The unconditional `buildTableau_isSome` and the `.splitOrdered` cardinality twin. Both remain on
  the **do-not-re-attempt register**.
- Repairing `resolveOpenArmCancellable` in `CancellableExpansion.lean` — a DECLARED, deliberately
  unrepaired out-of-scope divergence.
- Carrying the mint bound as a hypothesis in the shape `hT` has, or pushing its discharge onto
  task 412. **Explicitly rejected by the user.** The mint budget is a theorem *parameter* that this
  plan discharges (Phases 11-13), not a caller obligation.

**Absolute prohibitions** (a phase violating any of these is a failure, not a deviation):
- No `sorry`. No `axiom`. No `def X := True` / `:= Unit` / `:= trivial` vacuous placeholder.
- No `NoSplit` reintroduction under any name.
- No admitted `WorldWitness` and no admitted mint bound.
- No narrowing a statement into vacuity to make it check.
- **No task-number citations in any `.lean` file.** Per
  `.claude/rules/no-task-references-in-deliverables.md`, task numbers are fine in this plan (it is
  under `specs/**`) and forbidden in `MintBound.lean` and every other deliverable. In-source
  provenance notes must cite durable anchors (declaration names, section headings), never "task N".

---

## Risks & Mitigations

| # | Risk | Impact | Likelihood | Mitigation |
|---|------|--------|------------|------------|
| R1 | `densityRule`'s second edge (`addFuture freshTime t'`) needs an "every ordering time is a branch time" invariant that `.branching`'s shared `newOrd` gives a visible way to break. | H | M | Its own phase (3) with an explicit `[BLOCKED]` escalation clause; the eight non-density sites land first (Phase 2) so a block there does not take them down. Phase 4 carries the mirrored `.branching` clause. |
| R2 | The **mint potential** measure design (Phase 10) is the plan's own proposal and is NOT machine-checked. The specific hazard: arm 3's renaming `rhoSF` is not injective on `U`, so a cardinality-of-filter potential needs either an injection argument or a quotient. | H | M | Phase 10 carries a Scope Hypothesis requiring the arm-3 monotonicity to be settled **before** the induction is written, plus a named alternative (index the potential over the *pre-renaming* pair set and transport the filter along `rhoSF`). Escalate as `[BLOCKED]` rather than substitute. |
| R3 | **Universe/mint circularity.** `#mints ≤ 8·|U|` and `|U| = |signedUniverse C L|` with `L = worlds × times`, while times grow by mints. If `Tmax` is not supplied independently, the chain is circular. | H | M | `Tmax` must come from T2 (`timeFinset_card_le_of_not_blocked`, landed in `Fuel.lean:588`), **not** from the mint chain. Phase 9 owns this and Phase 10's first task is a read-and-report confirmation that T2's bound is in a consumable form, done before any statement is written. |
| R4 | `WorldWitness` discharge (Phase 9) was never attempted; plan 02's docstring calls it a ~36-case induction over `applyRule`. | H | M | Phase 9 has a named fallback (bound the world component along the seed run by fresh-world-minting steps) and a sanctioned degraded outcome: carry the residual as **one explicitly named hypothesis**, documented in-source and named in the summary. Never an axiom. |
| R5 | Task 426 lands a `Fuel.lean` rename that breaks `MintBound.lean`. | M | L | Loud build-time failure, not silent. Consumed declarations enumerated in "Prior Plan Reference"; repair is a rename in one file. |
| R6 | `applyRule_branchingOrdered_rule` needs `set_option maxHeartbeats 4000000` and a full 32-constructor × 2-sign case split; build time may be significant. | M | M | Isolated in Phase 7 with the `set_option` transcribed verbatim from the scratch file, including the `linter.unusedTactic false` line and its explanatory comment (the flagged `exact RuleResult.noConfusion h` is the `first`-alternative's failure mechanism — deleting it leaves 12 goals unsolved). |
| R7 | Phase sizing regression — this task has stalled twice on over-large phases. | M | M | 14 phases, each ~1-2 hours, each with a concrete mechanical completion criterion. Every phase whose content is transcription says so, so the implementer does not re-derive. |

---

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 5, 9 | 1 |
| 3 | 3, 6 | 2 / 5 |
| 4 | 4, 7 | 3 / 6 |
| 5 | 8 | 6, 7 |
| 6 | 10 | 4, 8, 9 |
| 7 | 11 | 8, 10 |
| 8 | 12 | 11 |
| 9 | 13 | 4, 10, 12 |
| 10 | 14 | 13 |

Phases within the same wave are logically independent. **Territory note**: every phase writes the
same file (`MintBound.lean`), so wave-parallel *execution* would collide. Waves record dependency
only; execute sequentially in phase-number order unless the implementer first splits the module,
which is not required and not planned.

---

### Phase 1: New module, `IrreflOrd`, and its two machine-checked preservation cases [COMPLETED]

**Goal**: Create the module, wire it into the build, and land the irreflexivity primitives —
including the counterexample that makes the side condition necessary rather than convenient.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` with
      `import FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel`, the project's standard
      copyright header, and a module docstring stating what the file is for. The docstring must NOT
      cite a task number.
- [x] Add the one-line `import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound`
      to `FormalSystem/Metalogic/Decidability.lean` (adjacent to the existing `...Termination.Fuel`
      import at line 21) so the module is in the default build target.
- [x] Land `rho` and `rhoSF` (scratch lines 8, 175) — the renaming and its action on a signed
      formula's label.
- [x] Land `IrreflOrd` (scratch line 345), `irreflOrd_identifyTime` (line 348, unconditional), and
      `irreflOrd_addFuture` (line 362) verbatim.
- [x] Land the **new mirror** `irreflOrd_addPast : IrreflOrd ord → t ≠ t' → IrreflOrd (ord.addPast t t')`.
      Not in the scratch file. Needed because four of the nine mint sites use `addPast`
      (`Tableau.lean:801, :924, :971, :1168`). `addPast t t_new = ⟨(t_new, t) :: constraints⟩`, so
      this is `irreflOrd_addFuture` with the pair flipped — expect a two-line proof.
- [x] Land `incomparableB_of_firstIncomparablePair` (scratch line 336), which derives the `hinc`
      side condition free from the landed `firstIncomparablePair_spec`.
- [x] Land the **counterexample record** (scratch lines 377-396): the three `decide`/`rfl` examples
      plus the `witnessPresent .allFutureNeg` flip, under a section comment stating plainly that the
      unconditional form of witness preservation is FALSE and belongs on the do-not-re-attempt
      register. This is a required deliverable, not decoration: it is what stops a future reader
      from dropping `IrreflOrd` as an apparently-cosmetic hypothesis.

**Completion notes**:
- Module created; import added to `FormalSystem/Metalogic/Decidability.lean` adjacent to the
  `...Termination.Fuel` import. Both scoped and aggregate builds green on first attempt.
- The counterexample record is landed as three anonymous `example`s plus one **named** theorem,
  `witnessPresent_identifyTime_unconditional_false`, so downstream in-source notes can cite it by
  declaration name (Phase 6's obligation).
- `lean_verify`: `irreflOrd_addPast` -> `[propext]`; `incomparableB_of_firstIncomparablePair` ->
  `[propext, Quot.sound]`; `witnessPresent_identifyTime_unconditional_false` -> `[propext]`. All
  subsets of the sanctioned `[propext, Classical.choice, Quot.sound]`.
- `grep -c 'sorry'` = 0, `grep -c '^axiom '` = 0, `grep -inE 'task [0-9]|tasks [0-9]'` = nothing.
- `Saturation.lean` and `Fuel.lean` md5 unchanged (`ae47004e...`, `8a395bd7...`).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — new file.
- `FormalSystem/Metalogic/Decidability.lean` — one import line.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `lake build FormalSystem.Metalogic.Decidability` green (confirms the import wiring).
- `grep -c 'sorry' MintBound.lean` reports 0; `grep -c '^axiom ' MintBound.lean` reports 0.
- `grep -inE 'task [0-9]|tasks [0-9]' MintBound.lean` reports nothing.
- The four counterexample `example`s elaborate (they are `by decide` / `by rfl`, so a green build
  is the check).

---

### Phase 2: `applyRule` preserves `IrreflOrd` at the eight non-density mint sites [COMPLETED]

**Goal**: Prove that `applyRule` returns an irreflexive ordering for every rule except
`densityRule`, given an irreflexive input and a source formula on the branch.

**Tasks**:
- [x] State
      `applyRule_irreflOrd_of_ne_density (hrule : rule ≠ .densityRule) (hsf : sf ∈ b) (h : IrreflOrd ord) : IrreflOrd (applyRule rule sf b ord).2`.
- [x] Establish the freshness fact once, as a named helper:
      `sf ∈ b → sf.label.time ≠ b.nextTime`, from the landed `le_maxTime` (`Tableau.lean:2597`) and
      `Branch.nextTime = maxTime + 1` — equivalently reuse `not_mem_of_time_nextTime`
      (`Tableau.lean:2608`) contrapositively. Every one of the eight sites reduces to this plus
      `irreflOrd_addFuture` / `irreflOrd_addPast`.
- [x] Discharge the eight sites: `allFutureNeg` (`:761`), `allPastNeg` (`:801`), `someFuturePos`
      (`:834`), `somePastPos` (`:878`), `untlPos` (`:1069`), `sncePos` (`:1168`), and the
      `untlNeg` / `snceNeg` active arms (`:924`, `:971`).
- [x] Discharge every remaining rule by the ordering being returned unchanged (`timeOrd` passed
      through). `timeLinearity` returns `.branchingOrdered` and is handled at the engine level in
      Phase 4, not here — state it as returning the input ordering in the `.2` component and confirm
      that reading against the source before relying on it.

**Completion notes**:
- **Mint-site enumeration (Scope Hypothesis, confirmed)**: `grep -n 'nextTime'
  FormalSystem/Metalogic/Decidability/Tableau.lean` reports exactly nine `branch.nextTime`
  occurrences inside `applyRule`, at lines 761, 801, 834, 878, 924, 971, 1069, 1168, 1370 —
  exactly the nine report 04 names. `densityRule` (`:1370`) is the only two-edge site.
- **Grounding correction to this plan's own task list**: the plan text pairs `sncePos` with
  `:1168` and the `snceNeg` active arm with `:971`. Reading the source, these are swapped —
  `:971` is `.sncePos` and `:1168` is the `snceNeg` active arm (likewise `:924` is `.untlPos`
  and `:1069` is the `untlNeg` active arm). The *set* of nine sites is unchanged, and the
  addFuture/addPast split is unchanged, so this is a labelling correction with no effect on the
  proof. Recorded rather than absorbed.
- **addFuture / addPast split, confirmed by reading each site**: `addFuture` at `:761`
  (`allFutureNeg`), `:834` (`someFuturePos`), `:924` (`untlPos`), `:1069` (`untlNeg` active),
  `:1370` (`densityRule` first edge). `addPast` at `:801` (`allPastNeg`), `:878` (`somePastPos`),
  `:971` (`sncePos`), `:1168` (`snceNeg` active). Four `addPast` sites, matching the plan's count.
- **`timeLinearity` reading, confirmed against the source** (`Tableau.lean:1513-1521`): its arm
  returns `(.branchingOrdered [...], timeOrd)` — the per-arm orderings live inside the
  `.branchingOrdered` payload and the `.2` component is the *input* ordering, unchanged. So it is
  discharged here by the ordering-unchanged alternative, and the per-arm orderings are Phase 4's
  obligation, exactly as the plan sequences it.
- **`contradiction` is load-bearing, not defensive.** `applyRule` is one `match` over three
  discriminants with overlapping patterns, so `split` emits *every* rule's arm inside each rule's
  case, each carrying a false discriminant equation (`TableauRule.impPos = TableauRule.densityRule`,
  `Sign.pos = Sign.neg`, …). This is the same phenomenon the scratch file documents for
  `applyRule_branchingOrdered_rule` (where it is discharged by `simp_all`); `contradiction` is the
  cheaper discharge and is recorded in the theorem's docstring so a future reader does not delete
  it. It also discharges the genuine `densityRule` case from `hrule`.
- **Integrity check performed**: deleting the `irreflOrd_addFuture` / `irreflOrd_addPast`
  alternatives leaves 10 unsolved-goal errors, confirming the mint sites are genuinely discharged
  by those lemmas and not swept up by `contradiction`.
- `lean_verify applyRule_irreflOrd_of_ne_density` -> exactly
  `[propext, Classical.choice, Quot.sound]`. Zero `sorry`, zero `axiom`.
- `set_option maxHeartbeats 4000000` is required (R6's phenomenon, one phase early). Measured
  module build time ~23s.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that exactly **nine** sites mint a fresh time, that eight of
them are single-edge, and that `densityRule` is the only two-edge one. Report 04 names the nine at
`Tableau.lean:761, 801, 834, 878, 924, 971, 1069, 1168, 1370`. Confirm by enumerating
`Branch.nextTime` occurrences in `applyRule` before writing any proof
(`grep -n 'branch.nextTime' FormalSystem/Metalogic/Decidability/Tableau.lean`). A different count or
a second two-edge site changes this phase's sizing and Phase 3's content and **must be reported**,
not absorbed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `applyRule_irreflOrd_of_ne_density` is sorry-free; `#print axioms` reports exactly
  `[propext, Classical.choice, Quot.sound]`.
- The enumerated mint-site count is recorded in the phase completion notes.

---

### Phase 3: `densityRule` and the ordering-times invariant [NOT STARTED]

**Goal**: Close the one mint site Phase 2 excludes, by supplying the auxiliary invariant its second
edge needs. **This is the phase report 04 flagged as the identified risk point, and it carries an
explicit `[BLOCKED]` escalation clause.**

**Tasks**:
- [ ] State the auxiliary invariant. Working name and shape:
      `OrdTimesLeMaxTime (b : Branch) (ord : TimeOrdering) : Prop := ∀ p ∈ ord.constraints, p.1 ≤ b.maxTime ∧ p.2 ≤ b.maxTime`
      — "every time mentioned in the ordering is a branch time". Confirm this is the weakest form
      that discharges the `densityRule` obligation before committing to it.
- [ ] Prove the `densityRule` case. `Tableau.lean:1370-1373` builds
      `newOrd := (timeOrd.addFuture l.time freshTime).addFuture freshTime t'` with `t'` drawn from
      `timeOrd.futureOf l.time`. The first edge is Phase 2's fact. The second needs
      `freshTime ≠ t'`, i.e. `t' ≤ b.maxTime < b.nextTime = freshTime`. Two sub-cases:
      - `t' = l.time`: immediate from `le_maxTime` and `sf ∈ b`.
      - `t' ≠ l.time`: then `t'` is reachable through `ord.constraints`, so `t'` is a component of
        some constraint pair, and `OrdTimesLeMaxTime` gives `t' ≤ b.maxTime`. The bridge from
        "reachable" to "appears in a constraint" is `mem_futureOf_of_mem_constraints`'s converse
        direction; if no such converse is available, derive it from `bfsClosure_sound` plus
        `mem_directFutureOf_iff'` (both landed / Phase 5) rather than assuming it.
- [ ] Land the unrestricted `applyRule_irreflOrd (hsf : sf ∈ b) (hord : IrreflOrd ord) (haux : OrdTimesLeMaxTime b ord) : IrreflOrd (applyRule rule sf b ord).2`,
      combining Phase 2 with the `densityRule` case.
- [ ] Prove `applyRule` preserves `OrdTimesLeMaxTime` **at the non-branching result shapes** (the
      branching shapes are Phase 4's obligation, and the hazard lives there).
- [ ] Do **not** scope the statement to frame classes below `.Dense`. `densityRule` only appears at
      frame classes `≥ .Dense` (`denseRules`, `Tableau.lean:1593-1595`, gated in `allRulesForFC` at
      `:1626`), so the risk is confined — but the target theorem is quantified over `fc`, so scoping
      it away would be a narrowing, not a fix.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that `OrdTimesLeMaxTime` is sufficient for the
`densityRule` second edge and is preserved at the non-branching shapes. Neither is machine-checked;
report 04 calls the invariant "plausible but unproved". Confirm sufficiency by reaching the
`freshTime ≠ t'` goal and discharging it from the invariant **before** investing in the preservation
proof. If the invariant as stated is insufficient, report the exact goal state and the strengthening
needed rather than silently strengthening it.

**Escalation clause — `[BLOCKED]`, mandatory**: if the `densityRule` sub-case cannot be discharged
within this phase, mark the phase `[BLOCKED]`, record the exact goal state reached, and stop.
**Forbidden**: admitting `OrdTimesLeMaxTime` (or any strengthening of it) as a hypothesis of the
final theorem; scoping the statement to `fc < .Dense`; deleting `densityRule` from `denseRules`;
substituting a weaker `IrreflOrd`; leaving a `sorry`; a vacuous placeholder. Per
`plan-compliance.md`, a would-be deviation on a `.lean` file is escalated, never silently annotated.
Phases 2 and 5-9 stand on their own if this phase blocks; Phases 4, 10-14 become unreachable and
stay `[NOT STARTED]` rather than being attempted out of order.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `applyRule_irreflOrd` is sorry-free with no `densityRule` exclusion and no frame-class restriction
  in its statement — checkable by reading the statement.
- `#print axioms applyRule_irreflOrd` reports exactly `[propext, Classical.choice, Quot.sound]`.

---

### Phase 4: Engine-level `IrreflOrd` across all four result shapes [NOT STARTED]

**Goal**: Lift Phase 3 from `applyRule` to `expandOnceUnblocked`, so `IrreflOrd` is a run invariant
the fuel induction can carry.

**Tasks**:
- [ ] Prove `expandOnceUnblocked_irreflOrd`: given `IrreflOrd ord` (and `OrdTimesLeMaxTime b ord`),
      the ordering component of `(expandOnceUnblocked b ord fc tr)` is irreflexive, and each arm's
      ordering in the `.split` / `.splitOrdered` cases is irreflexive.
- [ ] `.splitOrdered`: arms 1-2 are `ord.addFuture t₁ t₂` / `ord.addFuture t₂ t₁` with `t₂ ≠ t₁` from
      the landed `firstIncomparablePair_spec` — `irreflOrd_addFuture`. Arm 3 is
      `ord.identifyTime t₂ t₁` — `irreflOrd_identifyTime`, unconditional.
- [ ] `.split` / `.extended` / `.saturated`: route through Phase 3's `applyRule_irreflOrd` via the
      landed `findApplicable{,Serial,Linearity}Rule_applyRule_eq` bridges, using
      `pick_result_mem` (`Fuel.lean:282`) to supply the `sf ∈ b` side condition.
- [ ] Prove `expandOnceUnblocked` preserves `OrdTimesLeMaxTime` **at the branching shapes**. This is
      the mirrored half of R1: a `.branching` step hands the *same* `newOrd` to every arm, so an arm
      whose formula list omits the fresh witness would hold an ordering edge to a time absent from
      its own branch, and that arm's `nextTime` could then collide.
      **Grounding note, UNVERIFIED but promising**: reading `untlPos` (`Tableau.lean:1069-1100`),
      both arms are built at `freshLabel` (`branch1 := [SignedFormula.pos event freshLabel]`, and
      branch 2 is guard + continue also at `freshLabel`), so both arms' `maxTime` do cover
      `freshTime`. Report 04 flagged the shape as a *visible way to fail*, not a demonstrated
      failure. Check each branching mint rule's arms against this reading before assuming either
      outcome.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that all four `ExpansionResult` shapes are covered and that
the three pick stages are the only routes into `applyRule`. The pick-stage claim is grounded in the
landed `findApplicable{,Serial,Linearity}Rule_applyRule_eq` and in
`expandOnceUnblocked_splitOrdered_shape`'s own structure (scratch line 450), which enumerates exactly
those three. Confirm by reading `expandOnceUnblocked`'s body before writing the case split.

**Escalation clause**: if `OrdTimesLeMaxTime` cannot be preserved at a branching arm, mark the phase
`[BLOCKED]` and report which rule and which arm. **Forbidden**: weakening `OrdTimesLeMaxTime` into
something the `densityRule` case can no longer consume; admitting it; restricting the theorem to
non-branching runs (that is `NoSplit` by another name).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `expandOnceUnblocked_irreflOrd` covers all four shapes, checkable by reading the statement.
- `grep` confirms `NoSplit` does not appear anywhere in `MintBound.lean`.
- `#print axioms` on the phase's top-level lemma reports exactly the three standard axioms.

---

### Phase 5: The reachability transport stack [NOT STARTED]

**Goal**: Land the twelve transport lemmas that make claim (i) work. **All twelve are verbatim
transcription from the scratch file** — do not re-derive them.

**Tasks**:
- [ ] `identifyTime_edge` (scratch line 11) — a constraint that does not collapse survives, renamed.
- [ ] `mem_futureOf_of_mem_constraints` (line 28), `mem_pastOf_of_mem_constraints` (line 35).
      **These do not exist in the library** despite report 03 describing them as already
      machine-checked; budget for them here.
- [ ] `identifyTime_no_collapse` (line 49) — collapse-freedom, carrying `hinc` and `hnsl`. Also
      absent from the library for the same reason.
- [ ] `mem_directFutureOf_iff'` (line 77), `mem_directPastOf_iff'` (line 87).
- [ ] `pathN_along` (line 98) — transport of `TimeOrdering.PathN` along an arbitrary renaming,
      **length preserving**. This is the step that makes the fuel budget work: a path found at fuel
      `100` maps to a path of the same length, re-found by `bfsClosure_complete` at the same `100`.
- [ ] `directFutureOf_transport` (line 119), `directPastOf_transport` (line 128).
- [ ] `futureOf_transport` (line 137), `pastOf_transport` (line 153) — the two reachability
      transports, built from landed `bfsClosure_sound`, `bfsClosure_complete`, `reachableForward_eq`,
      `reachableBackward_eq` only.
- [ ] Restate `hnsl` in the landed `IrreflOrd` vocabulary where the scratch file spells it out as
      `∀ p ∈ ord.constraints, p.1 ≠ p.2`, so downstream phases consume one name.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts twelve declarations transcribe cleanly. They elaborated
sorry-free in the scratch file against the same `Fuel.lean`, so the expected failure mode is naming
or namespace drift, not proof failure. If any lemma does not transcribe, report which and why before
attempting a re-derivation.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `#print axioms futureOf_transport` and `#print axioms pastOf_transport` each report exactly
  `[propext, Classical.choice, Quot.sound]`.
- Zero `sorry`.

---

### Phase 6: Witness preservation across `.splitOrdered` arm 3 [NOT STARTED]

**Goal**: Land claim (i) — `witnessPresent_identifyTime` for all eight fresh-label rules with the
remaining rules proved vacuous, and the packaged `arm3_preserves_witness`. **Verbatim transcription.**

**Tasks**:
- [ ] `mem_identifyTime` (scratch line 179), `contains_identifyTime` (line 189),
      `knownWorlds_identifyTime` (line 198).
- [ ] `any_knownWorlds_transport` (line 212), `any_futureOf_transport` (line 220),
      `any_pastOf_transport` (line 231), `contains_at` (line 243).
- [ ] `witnessPresent_identifyTime` (line 257) — the eight-rule case analysis. Modal: `boxNeg`
      (case `h_1`), `diamondPos` (`h_2`). Temporal: `allFutureNeg` (`h_3`), `allPastNeg` (`h_4`),
      `someFuturePos` (`h_5`), `somePastPos` (`h_6`), `untlPos` (`h_7`, disjunctive witness
      transported componentwise), `sncePos` (`h_8`, past-directed mirror). Case `h_9` covers every
      other rule vacuously, and the vacuity is **proved**, not assumed.
- [ ] `arm3_preserves_witness` (line 489), taking `firstIncomparablePair b ord = some (t₁, t₂)`
      (so `hinc` is free) and `IrreflOrd ord`.
- [ ] Add an in-source note, adjacent to `witnessPresent_identifyTime`, that the `IrreflOrd`
      hypothesis is load-bearing and that the counterexample in Phase 1's record refutes the
      unconditional form. Cite the counterexample by declaration name, not by task number.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts eight fresh-label rules and ~24 vacuously-covered rules,
matching report 04's per-rule table. Confirm the fresh-label rule count against
`ruleMintsFreshLabel` in `Tableau.lean` at implementation time; if the engine carries a ninth
fresh-label rule the scratch file's case split does not reach, that is a material finding and must
be reported, not absorbed into `h_9`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `#print axioms witnessPresent_identifyTime` and `#print axioms arm3_preserves_witness` each report
  exactly `[propext, Classical.choice, Quot.sound]`.
- The statement of `witnessPresent_identifyTime` quantifies over **every** `TableauRule`, checkable
  by reading it.

---

### Phase 7: Non-deletion at engine level, all four result shapes [NOT STARTED]

**Goal**: Land claim (ii) — no expansion step deletes a formula — including the `.branchingOrdered`
exhaustiveness fact nobody had proved. **Verbatim transcription.**

**Tasks**:
- [ ] `pick_splitOrdered'` (scratch line 400) — the local re-proof of the `private`
      `pick_splitOrdered`.
- [ ] `applyRule_branchingOrdered_rule` (line 433) — `timeLinearity` is the ONLY rule that can
      produce `.branchingOrdered`. Transcribe **with** `set_option maxHeartbeats 4000000 in` and
      **with** `set_option linter.unusedTactic false in` plus the comment naming the 12 affected
      constructors (`impPos`, `impNeg`, `boxPos`, `boxNeg`, `boxTemporal`, `allFuturePos`,
      `allFutureNeg`, `allPastPos`, `allPastNeg`, `denseIndicatorClosure`, `densityRule`, `z1Rule`).
      The flagged `exact RuleResult.noConfusion h` is the `first`-alternative's failure mechanism;
      deleting it leaves 12 goals unsolved. Do not "fix" the linter warning by deleting the tactic.
- [ ] `expandOnceUnblocked_splitOrdered_shape` (line 450) — the engine-level shape of an ordered
      split across all three pick stages.
- [ ] `expandOnceUnblocked_splitOrdered_no_deletion` (line 472).
- [ ] Add an in-source note that non-deletion is proved as a **membership** statement
      (`x ∈ b → ρ_SF x ∈ arm`), which is compatible with — and deliberately not a re-attempt of — the
      refuted `.splitOrdered` cardinality twin on the do-not-re-attempt register. Arm 3 still shrinks
      `toFinset.card` via `eraseDups` merging and nothing here claims otherwise.
- [ ] Record the observed build time for `applyRule_branchingOrdered_rule` in the phase completion
      notes (R6).

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts an exhaustive case analysis over ~32 `TableauRule`
constructors × both signs, at `maxHeartbeats 4000000`. Confirm the constructor count at
implementation time; a materially different count changes the elaboration budget and must be
reported. If the build exceeds a reasonable wall-clock budget, report the measured time rather than
silently raising `maxHeartbeats` further.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `#print axioms expandOnceUnblocked_splitOrdered_shape` and
  `#print axioms expandOnceUnblocked_splitOrdered_no_deletion` each report exactly the three
  standard axioms.
- Measured build time recorded in the completion notes.

---

### Phase 8: Witness monotonicity and one-step preservation, all four shapes [NOT STARTED]

**Goal**: Turn arm-3 preservation into a statement about **every** expansion step, which is what the
mint counting actually consumes. This phase is **new proof**, not transcription.

**Tasks**:
- [ ] Prove `witnessPresent` is monotone in the branch: `b ⊆ b' → witnessPresent rule sf b ord = true → witnessPresent rule sf b' ord = true`.
      Every clause of `witnessPresent` is a `contains` / `any … contains` test, so this is a
      `List.Subset` argument on `Branch.contains`.
- [ ] Prove `witnessPresent` is monotone in the ordering:
      `ord.constraints ⊆ ord'.constraints → witnessPresent rule sf b ord = true → witnessPresent rule sf b ord' = true`,
      via the landed `futureOf_mono` / `pastOf_mono` and `addFuture_constraints_mono`.
- [ ] Combine into `expandOnceUnblocked_preserves_witness`: for each of the four result shapes,
      a witness present before the step is present after, at the (possibly renamed) source formula.
      - `.extended nb`: `nb = fs ++ b` (`Tableau.lean:2234, 2238`), so branch monotonicity; the
        ordering only ever grows by `addFuture` / `addPast`, so ordering monotonicity.
      - `.split bs`: every arm is `fs ++ b` via the landed `expandOnceUnblocked_split_subset`.
      - `.splitOrdered` arms 1-2: branch literally unchanged, ordering grows —
        `expandOnceUnblocked_splitOrdered_shape` plus ordering monotonicity.
      - `.splitOrdered` arm 3: Phase 6's `arm3_preserves_witness`, consuming `IrreflOrd` from Phase 4.
      - `.saturated`: no successor branch, vacuous.
- [ ] State the corollary in the form the counting needs: **`witnessPresent` never flips
      `true → false` along a run** (up to the arm-3 renaming).

**Timing**: 2 hours

**Depends on**: 6, 7

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that (a) the ordering only ever grows by edge addition
except at arm 3, and (b) every `witnessPresent` clause is monotone in both arguments. Both are read
off the definitions; confirm by reading `witnessPresent`'s body and `applyRule`'s ordering returns
before writing the proofs. If any clause is anti-monotone in either argument, that is a material
finding — report it, since it would put the whole mint bound at risk.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- `expandOnceUnblocked_preserves_witness` covers all four shapes, checkable by reading the statement.
- Sorry-free; `#print axioms` reports exactly the three standard axioms.

---

### Phase 9: The world dimension and an independent `Tmax` [NOT STARTED]

**Goal**: Supply the world dimension so that `|U|` is a real number rather than a circular one, and
supply `Tmax` **independently of the mint chain** so R3 does not bite. Content inherited from plan
02's unattempted Phase 12; required by the task's DONE WHEN clause.

**Tasks**:
- [ ] **Read first, prove second.** Read `chain_le_worldFuel'` (`Fuel.lean:2619`),
      `worldFinset_card_le` (`:1230`), `worldWitness_self` (`:1302`), and
      `timeFinset_card_le_of_not_blocked` (`:588`), and record in the completion notes exactly what
      each supplies and what each demands. `chain_le_worldFuel'`'s docstring states that
      `hww : WorldWitness C S (run n)` is an invariant **not discharged there** — that is the warning
      sign for this phase.
- [ ] **Confirm T2 delivers `Tmax` in a consumable form** (R3). `timeFinset_card_le_of_not_blocked`
      is landed and bounds `Branch.timeFinset.card`; confirm its hypotheses are satisfiable along an
      engine run before building anything on it. If it is not consumable, say so explicitly and take
      the fallback below — do **not** reshape `TimeTypeBound.lean` (outside scope).
- [ ] Discharge `WorldWitness` for the engine's seed configuration
      (`initialBranch = [SignedFormula.neg phi Label.initial]`, so `S.card = 1`). Scope to the seed
      run, not the general invariant.
- [ ] Derive `hL : L.card ≤ (s + 2 * C.card * 2 ^ (2 * C.card)) * 2 ^ (2 * C.card)` at `s = 1` via
      `worldFinset_card_le`, in the exact shape the downstream phases consume.
- [ ] **Named fallback for `Tmax`**, to be taken only if T2 does not deliver: bound fresh-time mints
      directly by the `witnessPresent` guard — each existential signed formula mints at most one
      witness and the existential formulas live in `U`. Note this route reintroduces R3's
      circularity unless `|U|` is closed first; if taken, the phase must state precisely how the
      circularity is broken or escalate.
- [ ] **Named fallback for `WorldWitness`**, to be taken only if the induction over `applyRule` does
      not close: prove the narrower statement that the world component of the seed run's label set is
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
`WorldWitness`, mark the phase `[BLOCKED]` and report the exact goal state and which route was tried.
The **only** sanctioned degraded outcome is to carry the undischarged item as **one explicitly named
hypothesis** on Phase 14's terminus, documented in-source and named by name in the implementation
summary. The task's DONE WHEN admits "its absence is proved harmless" — that is acceptable **only if
the harmlessness is itself proved**, never asserted. **Forbidden absolutely**: admitting
`WorldWitness` as an `axiom`; reintroducing `NoSplit`; a `sorry`; a vacuous placeholder; editing
`TimeTypeBound.lean` or any file outside this plan's declared set.

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

**Tasks**:
- [ ] **Settle the measure design before writing the statement.** Proposed shape:
      ```
      mintPotential (U : Finset SignedFormula) (b : Branch) (ord : TimeOrdering) : Nat :=
        ((freshLabelRules ×ˢ U).filter (fun p => witnessPresent p.1 p.2 b ord = false)).card
      ```
      with `freshLabelRules` the eight-element rule set. `mintPotential ≤ 8 * U.card` is then
      immediate. **The bet**: Phase 8 makes `witnessPresent` monotone, so `mintPotential` is
      non-increasing along a run and strictly decreases on a mint — a *per-state* quantity that the
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
      `Tmax` and hence `|U| = |signedUniverse C L|` are supplied independently of the mint chain.
      Record the confirmation. If Phase 9 could not supply it, escalate here rather than writing a
      statement whose hypotheses are circular.
- [ ] Land `mintBudget_preserved`, the arithmetic mirror of the landed `splitBudget_preserved`: a
      step consumes at most one unit of mint budget, so the sum of used-and-remaining is invariant
      across extending and splitting steps.
- [ ] State `expandBranchWithFuel_isSome_of_budget` with the mint budget as an explicit parameter,
      `NoSplit` **deleted**, `hT`/`TimeBounded` instantiated at `Tmax` from Phase 9 (not assumed),
      and the fuel figure the landed `splitAwareFuel` supplies. **Do not prove it here** — Phase 13
      closes the induction. Land the statement plus its scaffolding so Phases 11-12 have a fixed
      target.
- [ ] Record in-source, adjacent to the statement, **why the section-4 impossibility does not apply**:
      it rules out the three-component linear family, and `mintPotential` is a fourth component
      outside it. Cite the components by name, never by report or task number.

**Timing**: 2.5 hours

**Depends on**: 4, 8, 9

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts (a) that `mintPotential` is monotone across all four result
shapes, (b) that `mintPotential ≤ 8 * |U|`, and (c) that `Tmax` is independently supplied. **(a) is
NOT machine-checked and is the plan's central design bet.** Confirm (a) at arm 3 **before** anything
else in this phase; confirm (c) from Phase 9's recorded findings. If (a) fails at arm 3 under both
the primary shape and the named alternative, that is a material finding about route (b) itself and
must be reported plainly, not worked around.

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
- `grep` confirms `buildTableau`'s `fuel := 1000` and `expandBranchWithFuel`'s
  `maxBranches := 50000` are untouched (`git diff --stat` shows no change under
  `FormalSystem/Metalogic/Decidability/Saturation.lean`).
- The R3 and arm-3 confirmations are recorded in the completion notes.

---

### Phase 11: `#mints ≤ 8·|U|` — the once-only bound [NOT STARTED]

**Goal**: The first link of the amortized chain: each `(rule, sf)` pair mints at most once, so the
total number of fresh-time mints along any path is bounded absolutely, with no reference to branch
growth.

**Tasks**:
- [ ] Prove the mint guard fact: `findApplicableRule` gates every `ruleMintsFreshLabel` rule on
      `witnessPresent rule sf branch timeOrd` in **both** the `.linear` and `.branching` arms
      (`Tableau.lean:1908`, `:1931`), and **instead of** the output-presence test, never in addition
      to it. Confirm this reading against the source before relying on it.
- [ ] Prove the post-mint fact: the rule's output **is** the witness (`Tableau.lean:2336` — all eight
      constructors return a syntactic cons whose head is the witness), so immediately after a mint
      `witnessPresent = true` for that pair.
- [ ] Combine with Phase 8 (never flips `true → false`) to get: a mint strictly decreases
      `mintPotential`, and a non-mint does not increase it.
- [ ] Conclude `#mints ≤ 8 * |U|` along any path, as a statement about the induction's carried
      counter — **absolute**, with no reference to branch growth.

**Timing**: 2 hours

**Depends on**: 8, 10

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the guard reading at `Tableau.lean:1908, :1931` and the
witness-is-the-output reading at `:2336`, and that there are exactly eight minting constructors.
Report 03 section 3 states all three and report 04 confirms the eight. Confirm each against the
source **before** writing the proofs; a guard that is `&&`-composed with an output-presence test
rather than replacing it would break the once-only argument and must be reported.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- The mint bound's statement mentions neither `|b|` nor branch growth, checkable by reading it.
- Sorry-free; `#print axioms` reports exactly the three standard axioms.

---

### Phase 12: The counting chain — identifications, shrinkage, extensions [NOT STARTED]

**Goal**: The remaining three links, each absolute.

**Tasks**:
- [ ] `#identifications ≤ |knownTimes|₀ + #mints`: each identification drops `|knownTimes|` by at
      least one (landed `knownTimes_card_lt_identifyTime`), each mint raises it by one.
      Note the payoff: this **derives** the time bound rather than assuming it, so `TimeBounded` is
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
does not fit `splitAwareFuel`'s shape, use the derived figure and record the divergence rather than
writing the plan's figure unchecked.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- Each of the three inequalities is a named sorry-free lemma.
- The `Tmax` instantiation is present in-source with the "derived, not assumed" note.

---

### Phase 13: Close the induction — `expandBranchWithFuel_isSome_of_budget` [NOT STARTED]

**Goal**: Prove Phase 10's statement, `NoSplit`-free, using Phase 12's chain.

**Tasks**:
- [ ] Prove by induction on fuel. The `saturated` and `extended` arms carry over from the landed
      `expandBranchWithFuel_isSome_of_noSplit` (`Fuel.lean:1462`).
- [ ] `.split` arm: the landed `expand_split_fold_isSome` (`Fuel.lean:2237`) matches the goal's fold
      shape exactly; discharge the per-arm obligations with the landed
      `expandOnceUnblocked_split_card_lt`, `allocateFuelProportionally_ge`, and `splitBudget_preserved`.
- [ ] `.splitOrdered` arm: the landed `expand_splitOrdered_fold_isSome` (`Fuel.lean:2289`), plus
      Phase 10's `mintPotential` monotonicity at arm 3 — **this is the arm the previous plan could
      not close**, and the mint potential is what closes it.
- [ ] Add a **branching non-vacuity witness** in the style of the landed `noSplit_nil` /
      `expandBranchWithFuel_nil_isSome` block, but at a branch that **actually splits**. This is not
      decoration: it is the mechanical demonstration that the mint budget did not silently become
      `NoSplit`. A theorem that only applied to unbranching runs would have removed `NoSplit` in name
      only.
- [ ] Leave the landed `expandBranchWithFuel_isSome_of_noSplit` and
      `expandBranchWithFuel_isSome_at_worldFuel'` in place. They are consumed elsewhere; this is an
      addition, not a replacement.

**Timing**: 2.5 hours

**Depends on**: 4, 10, 12

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that the split arms close with no hypothesis beyond the mint
budget, the `splitAwareFuel` figure, and the β-linear branch budget. Inspect the landed theorem's
statement for residual hypotheses at phase end and list any that appeared.

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

**Tasks**:
- [ ] State and prove `buildTableauAt_isSome_of_budget`: for `phi`, `fc`, and a quantified
      `maxBranches` satisfying the β-linear budget condition at the split-aware fuel figure,
      `(buildTableauAt phi <fuel figure> fc maxBranches).isSome = true`.
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
      by refuting witness, never by task or report number:
      1. the unconditional `buildTableau_isSome`;
      2. `buildTableau_isSome_of_budget` in the original target shape (`maxBranches` quantified as
         the only new hypothesis, `soundFuel' φ` as the fuel), refuted by `φ = F(G p)` at
         `fuel = 229376`, `maxBranches = 10¹²`, cause `resolveOpenArm = none`;
      3. the `.splitOrdered` cardinality twin of the split-growth lemma;
      4. the `buildTableauAt` / `buildTableau` `allClosed` `iff`, which is false, not merely unproved;
      5. **new** — the unconditional (`IrreflOrd`-free) form of `witnessPresent_identifyTime`, false
         by the counterexample landed in Phase 1;
      6. **new** — route (a), a lower bound on `(b.identifyTime t₂ t₁).toFinset.card` in terms of
         `b.toFinset.card`, dead by definition since `Branch.identifyTime = (b.map relabel).eraseDups`
         and shrinkage is bounded only by `|U|`.
- [ ] Record for the consuming task in the implementation summary (not in-source): the replacement
      for the refuted `buildTableau_isSome` is against `buildTableauAt` / `BudgetedTableau`, **not**
      `buildTableau` / `ExpandedTableau`, and it carries a quantified branch budget plus any residual
      Phase 9 had to carry.
- [ ] Full-repo final gate.

**Timing**: 2 hours

**Depends on**: 13

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build` (full repo) green.
- `grep -c 'sorry' MintBound.lean` reports 0; `grep -c '^axiom ' MintBound.lean` reports 0.
- `lean_verify` on the fully-qualified terminus reports only `[propext, Classical.choice, Quot.sound]`.
- The terminus statement contains no `NoSplit` hypothesis.
- All six register entries are present in-source.
- `git diff` shows `FormalSystem/Metalogic/Decidability/Saturation.lean` and
  `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` **unchanged by this task**.

---

## Success Criteria

- [ ] `buildTableauAt_isSome_of_budget` is landed, sorry-free, axiom-free, with no `NoSplit`
      hypothesis and no undischarged mint bound.
- [ ] The mint budget is **discharged in-plan** (Phases 11-13), not carried as a caller obligation
      and not pushed onto task 412.
- [ ] Engine-level `IrreflOrd` is landed with the `densityRule` sub-case discharged — or the phase is
      honestly `[BLOCKED]` with the goal state recorded.
- [ ] The world dimension is supplied, or its absence is carried as exactly one explicitly named
      residual whose harmlessness is **proved**, not asserted.
- [ ] `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s `maxBranches := 50000`
      default are byte-identical to their pre-task form.
- [ ] `Fuel.lean` and `Saturation.lean` are unmodified by this task (the task-426 coordination
      decision, mechanically checkable by `git diff`).
- [ ] `lake build` green repo-wide.

## Testing & Validation

- [ ] `lake build` green repo-wide at Phase 14 (and at any phase whose tier is `full`).
- [ ] Zero `sorry` and zero `^axiom ` in `MintBound.lean`.
- [ ] `#print axioms` / `lean_verify` on each phase's top-level declaration reports exactly
      `[propext, Classical.choice, Quot.sound]`.
- [ ] The existing `SplitFuelProbes`, `ArmSettlingProbes`, and `BudgetedTableauProbes` `#guard_msgs`
      rows all still pass unchanged. They pin measured behavior and must not drift.
- [ ] `grep -inE 'task [0-9]|tasks [0-9]' FormalSystem/` reports nothing new — no task-number
      citations in any deliverable.
- [ ] Every phase that closes `[BLOCKED]` has its exact goal state recorded, and every carried
      residual hypothesis is named in the implementation summary.
- [ ] The branching non-vacuity witness (Phase 13) is at a genuinely branching branch.

## Artifacts & Outputs

- `specs/428_engine_totality_at_a_quantified_branch_budget/plans/03_mint-bound-irreflexivity-totality.md` (this file)
- `specs/428_engine_totality_at_a_quantified_branch_budget/summaries/03_mint-bound-irreflexivity-totality-summary.md`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — **new**: the
  irreflexivity invariant, the reachability transport stack, witness preservation, engine-level
  non-deletion, the mint potential, the amortized counting chain, the `NoSplit`-free
  `expandBranchWithFuel_isSome_of_budget`, the terminus, and the register.
- `FormalSystem/Metalogic/Decidability.lean` — one import line.
- **Unchanged, by design**: `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`,
  `FormalSystem/Metalogic/Decidability/Saturation.lean`, `FormalSystem/Metalogic/Decidability/Tableau.lean`.

## Rollback/Contingency

- Every phase is **purely additive** to a new file. Reverting a phase's commit restores the prior
  state with no downstream effect, because no existing declaration is edited anywhere.
- The entire task is revertible by deleting `MintBound.lean` and its one import line.
- **If Phase 3 blocks** (`densityRule`): Phases 1, 2, 5-9 stand as landed value — the irreflexivity
  primitives, the eight non-density mint sites, the full transport and witness-preservation stack,
  engine-level non-deletion, and the world dimension. Mark the task `[PARTIAL]` with the goal state
  recorded. **Do not** scope the theorem to `fc < .Dense` and do not admit the auxiliary invariant.
- **If Phase 9 blocks** after both routes: carry the undischarged item as one explicitly named
  hypothesis into the terminus and name it in the summary. **Do not** admit `WorldWitness` as an
  axiom.
- **If Phase 10 blocks** (the mint potential, R2): this is a finding about route (b) itself. Report
  it plainly with the exact goal state. Phases 1-9 stand as landed value. **Do not** substitute a
  carried mint-bound hypothesis, do not push the obligation onto task 412, and do not treat it as
  license to revisit route (a).
- Under no circumstance is a green terminus manufactured by reintroducing `NoSplit`, admitting a
  hypothesis as an axiom, narrowing a statement into vacuity, or leaving a `sorry`.
