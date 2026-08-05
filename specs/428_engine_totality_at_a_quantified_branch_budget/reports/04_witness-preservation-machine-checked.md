# Research Report: Witness Preservation and Non-Deletion, Machine-Checked

- **Task**: 428 - engine_totality_at_a_quantified_branch_budget
- **Started**: 2026-08-05
- **Completed**: 2026-08-05
- **Effort**: ~4 hours (one research dispatch; 27 lemmas elaborated across 12 build cycles)
- **Dependencies**: none blocking. Consumes phases 1-10 of `plans/02_lexicographic-splitordered-measure.md`
  (landed, sorry-free, green) as given. Coordinates with task 426 on `Fuel.lean`, which was
  **read-only** in this dispatch, so no concurrent-edit hazard was created. Task 412 remains
  sequenced behind this task.
- **Sources/Inputs**:
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/03_phase11-potential-obstruction.md` (primary; sections 1, 3 steps 3-4, and 4 are load-bearing)
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/01_budget-totality-refuted-and-repair.md`
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/02_splitordered-measure-blocker.md`
  - `specs/428_engine_totality_at_a_quantified_branch_budget/plans/02_lexicographic-splitordered-measure.md`
  - `specs/state.json` — the task description, carrying both prior retarget decisions and the do-not-re-attempt register
  - Live repo at Lean v4.33.0-rc1: `FormalSystem/Metalogic/Decidability/{Tableau,Saturation,SignedFormula}.lean`
    and `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`
- **Artifacts**:
  - `specs/428_engine_totality_at_a_quantified_branch_budget/reports/04_witness-preservation-machine-checked.md` (this report)
  - `specs/428_engine_totality_at_a_quantified_branch_budget/scratch/04_witness-preservation.lean`
    (514 lines, 27 lemmas; elaborates sorry-free and warning-free via `lake env lean`, exit 0;
    held outside the build — nothing landed in the library)
- **Standards**: report-format.md, artifact-management.md, artifact-formats.md, lean4.md,
  plan-compliance.md, no-task-references-in-deliverables.md
- **Type**: lean4

---

## Executive Summary — Verdicts, Up Front

**Claim (i) — witness preservation across `.splitOrdered` arm 3: VERIFIED for all eight rules, but
CONDITIONAL on a side condition report 03 never named.**

The reachability transport that the six temporal rules need is real, provable, and now
machine-checked. The two modal rules are trivial as report 03 predicted. But the transport
**requires the constraint list to be irreflexive** (`∀ p ∈ ord.constraints, p.1 ≠ p.2`, called
`hnsl` in report 03 section 1). Report 03 carried `hnsl` only as a hypothesis of
`identifyTime_no_collapse` and never asked whether it holds; it is in fact **load-bearing and not
optional**: I have a machine-checked counterexample showing claim (i) is FALSE without it.

**Claim (ii) — "formulas are never deleted": VERIFIED, engine level, all four result shapes.**
Two of the four were already landed. The `.splitOrdered` case is now closed end-to-end, including
a fact nobody had proved: that `timeLinearity` is the *only* rule that can produce
`.branchingOrdered`, so the three-arm enumeration is exhaustive.

**ROUTE (b) SURVIVES.** This is not a third retarget decision. But route (b) acquires **one new,
previously-unnamed proof obligation** — engine-level irreflexivity of the `TimeOrdering` constraint
list — which must be added to the approved work plan. Two of its three preservation cases are
already machine-checked here; the third (fresh-time mints) is reduced to landed infrastructure but
has one identified risk point (`densityRule` at frame classes ≥ `.Dense`). See Recommendations
section 5.

---

## Context & Scope

### The gate this dispatch had to clear

Report 03 recommended route (b) (an independent mint bound) and the user approved it, but marked
**two load-bearing claims UNCERTAIN**. The task record required both to be machine-checked in Lean
*before* any plan is written, because this task has twice had a plan rest on an unverified lemma
that later proved FALSE (first the unconditional `buildTableau_isSome`, then the `.splitOrdered`
cardinality twin). Prose argument was explicitly not acceptable output.

- **Claim (i)** (report 03 section 3, step 4): witness preservation across `.splitOrdered` arm 3.
  Argued, not machine-checked. The two modal rules were expected to be trivial; the six temporal
  rules need a reachability transport that was never verified.
- **Claim (ii)** (report 03 section 3, step 3): "formulas are never deleted". Read off the rule
  shapes and consistent with the landed `expandOnceUnblocked_card_lt` /
  `expandOnceUnblocked_split_card_lt`, but not proved.

The failure branch was pre-agreed: if witness preservation failed for **any** temporal rule, route
(b) would be dead and that would be a third retarget decision requiring human approval — to be
reported plainly, never worked around, narrowed, or weakened. That branch was not taken; both
claims hold. The negative result that *did* surface (Findings section 2) is a side condition, not a
refutation of the route.

### In scope

- Machine-checking both claims against the real definitions in `Tableau.lean`, `Saturation.lean`,
  `SignedFormula.lean`, and `Fuel.lean`.
- Per-rule reporting for all eight fresh-label rules.
- Recording what the approved route-(b) work items need, now that both claims are verified.
- Flagging any additional obstruction in the amortized chain.

### Out of scope, and deliberately not touched

- Route (a) (a lower bound on branch cardinality after identification) — dead by definition per the
  second retarget decision. Not revisited.
- The refuted unconditional `buildTableau_isSome` and the refuted `.splitOrdered` cardinality twin —
  on the do-not-re-attempt register. Neither re-attempted.
- `resolveOpenArmCancellable` in `CancellableExpansion.lean` — a declared, deliberately-unrepaired
  out-of-scope divergence.
- Landing anything in the library. This is the research stage, where landing is optional.

### What was consumed as given vs. re-derived

**Consumed as given** (landed by phases 1-10): `bfsClosure_sound`, `bfsClosure_complete`,
`reachableForward_eq`, `reachableBackward_eq`, `PathN`, `firstIncomparablePair_spec`,
`applyRule_timeLinearity_arms_trigger`, `expandOnceUnblocked_adds_new`,
`expandOnceUnblocked_split_subset`, `findApplicable{,Serial,Linearity}Rule_applyRule_eq`,
`le_maxTime`, `not_mem_of_time_nextTime`.

**Re-derived, because it turned out not to exist**: the three lemmas report 03 section 1 described
as "already machine-checked" — `mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`,
`identifyTime_no_collapse`. They were proved in a throwaway `lean_run_code` snippet and **never
landed in `Fuel.lean`**. Any plan that says "resting on the three lemmas already machine-checked in
report 03 section 1" must budget for landing them.

### Method

All verification used `lake env lean` against a self-contained scratch file importing
`FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel`. A claim counts as machine-checked
here only if a Lean statement of it elaborates sorry-free; every such statement is in the scratch
file with its line number cited below.

---

## Findings

### 1. Claim (i), rule by rule

Statement machine-checked (`witnessPresent_identifyTime`, scratch line 257). Let
`ρ = rho t₂ t₁ = fun t => if t = t₂ then t₁ else t` and `ρ_SF` its action on a signed formula's
label:

```lean
theorem witnessPresent_identifyTime (rule : TableauRule) (b : Branch) (ord : TimeOrdering)
    (t₁ t₂ : TimeIndex) (s : Sign) (φ : Formula) (w : WorldIndex) (tm : TimeIndex)
    (hinc : incomparableB ord (t₁, t₂) = true)
    (hnsl : ∀ p ∈ ord.constraints, p.1 ≠ p.2)
    (h : witnessPresent rule ⟨s, φ, ⟨w, tm⟩⟩ b ord = true) :
    witnessPresent rule ⟨s, φ, ⟨w, rho t₂ t₁ tm⟩⟩
      (b.identifyTime t₂ t₁) (ord.identifyTime t₂ t₁) = true
```

It is stated for **every** `TableauRule`, not just the eight fresh-label ones — the other twenty-odd
are covered vacuously because `witnessPresent` returns `false` on them, and that vacuity is itself
discharged by the proof rather than assumed.

| # | Rule | Kind | Status | Lean evidence |
|---|------|------|--------|---------------|
| 1 | `boxNeg` | modal | **VERIFIED** | case `h_1`, via `any_knownWorlds_transport` + `knownWorlds_identifyTime` |
| 2 | `diamondPos` | modal | **VERIFIED** | case `h_2`, same route through `asDiamond?` |
| 3 | `allFutureNeg` | temporal | **VERIFIED** | case `h_3`, via `any_futureOf_transport` → `futureOf_transport` |
| 4 | `allPastNeg` | temporal | **VERIFIED** | case `h_4`, via `any_pastOf_transport` → `pastOf_transport` |
| 5 | `someFuturePos` | temporal | **VERIFIED** | case `h_5`, through `asSomeFuture?` |
| 6 | `somePastPos` | temporal | **VERIFIED** | case `h_6`, through `asSomePast?` |
| 7 | `untlPos` | temporal | **VERIFIED** | case `h_7`; the disjunctive witness (`event`, or `guard ∧ untl`) transported componentwise |
| 8 | `sncePos` | temporal | **VERIFIED** | case `h_8`; past-directed mirror |
| — | all other rules | — | **VERIFIED (vacuous, proved)** | case `h_9`: `witnessPresent = false` |

No rule is FAILED. No rule is NOT REACHED.

`#print axioms witnessPresent_identifyTime` → `[propext, Classical.choice, Quot.sound]`. No `sorry`,
no new axiom.

#### 1.1 The reachability transport (the part report 03 never verified)

Chain, all machine-checked:

1. `identifyTime_edge` (line 11) — a constraint that does not collapse survives, renamed:
   `(a,b) ∈ ord.constraints → ρa ≠ ρb → (ρa, ρb) ∈ (ord.identifyTime t₂ t₁).constraints`.
2. `identifyTime_no_collapse` (line 49) — report 03 section 1's lemma, re-derived here. Consumes
   `mem_futureOf_of_mem_constraints` / `mem_pastOf_of_mem_constraints` (lines 28, 35), also
   re-derived.
3. `pathN_along` (line 98) — transport of `TimeOrdering.PathN` along an arbitrary renaming,
   **length preserving**. This is the step that makes the fuel budget work out: the path found at
   fuel `100` maps to a path of the *same* length, so `bfsClosure_complete` re-finds it at the same
   fuel `100`.
4. `futureOf_transport` / `pastOf_transport` (lines 137, 153) —
   `t ∈ ord.futureOf s → ρt ∈ (ord.identifyTime t₂ t₁).futureOf (ρs)`, and the backward mirror.
   Built from landed `Fuel.lean` infrastructure only: `bfsClosure_sound`, `bfsClosure_complete`,
   `reachableForward_eq`, `reachableBackward_eq`.

Report 03's sketch was correct in substance. The one thing it got wrong by omission is finding 2.

#### 1.2 The side conditions

- **`hinc` is free.** `incomparableB_of_firstIncomparablePair` (line 336) derives it directly from
  the landed `firstIncomparablePair_spec`. A caller sitting on the arm-3 branch always has the
  trigger equation, so this costs nothing. Packaged as `arm3_preserves_witness` (line 480), which
  takes `firstIncomparablePair b ord = some (t₁, t₂)` instead of `hinc`.
- **`hnsl` is NOT free.** See finding 2.

### 2. `hnsl` is necessary — machine-checked counterexample

`TimeOrdering.identifyTime` drops **every** constraint whose two components rename to the same
index (`SignedFormula.lean:705-711`). Report 03 read that as "the obvious mechanism by which
identification could destroy order information" and proved (correctly) that it never fires on the
pair `timeLinearity` identifies. What it did not check is that the same filter **also silently
deletes any pre-existing self-loop `(a, a)` with `a ∉ {t₁, t₂}`** — those rename to `(a, a)`, which
is caught by the very same `if a' == b' then none` test.

Machine-checked, in the scratch file (all `by decide` / `by rfl` on the real definitions):

```lean
example : (5 : TimeIndex) ∈ (TimeOrdering.mk [(5, 5)]).futureOf 5 := by decide
example : (5 : TimeIndex) ∉ ((TimeOrdering.mk [(5, 5)]).identifyTime 1 0).futureOf 5 := by decide
example : incomparableB (TimeOrdering.mk [(5, 5)]) (0, 1) = true := by decide
```

Lifted to the engine's own guard, also machine-checked:

```lean
-- p := atom "p";  sf := F(G p) @ (0,5);  wit := F(p) @ (0,5);  b := [sf, wit];  ord := ⟨[(5,5)]⟩
witnessPresent .allFutureNeg sf b ord = true ∧
  witnessPresent .allFutureNeg (relabelled sf) (b.identifyTime 1 0) (ord.identifyTime 1 0) = false
```

`hinc` holds in that configuration (`0` and `1` are incomparable), so the failure is attributable to
the self-loop alone. **Claim (i) in unconditional form is false.** With `hnsl` it is true.

There is no cheaper repair. Shortening a path around a deleted self-loop works for every path of
length ≥ 2, but the single-step case `s = t = a` is exactly the counterexample above and cannot be
shortened. `hnsl` is the right statement, not a convenience.

### 3. Claim (ii), by result shape

The claim needed by the mint bound is: **an expansion step never removes a formula** (up to the
arm-3 renaming), so a witness once present stays present.

| `ExpansionResult` shape | Status | Evidence |
|---|---|---|
| `.extended nb` (from `.linear` / `.persistent`) | **VERIFIED (already landed)** | `expandOnceUnblocked_adds_new`'s `hsub`; the pick's result is literally `fs ++ b` (`Tableau.lean:2234, 2238`) |
| `.split bs` (from `.branching`) | **VERIFIED (already landed)** | `expandOnceUnblocked_split_subset` (`Fuel.lean:1711`): every arm is `fs ++ b` |
| `.splitOrdered bs` arms 1-2 | **VERIFIED (new)** | branch literally unchanged; `expandOnceUnblocked_splitOrdered_shape` |
| `.splitOrdered bs` arm 3 | **VERIFIED (new)** | `mem_identifyTime` (line 179): `x ∈ b → ρ_SF x ∈ b.identifyTime t₂ t₁` |
| `.saturated` | n/a | no successor branch |

Packaged as `expandOnceUnblocked_splitOrdered_no_deletion` (line 463).

#### 3.1 The exhaustiveness fact nobody had proved

Report 03's step 3 enumerated the arm shapes by reading the rule definitions. Making that
enumeration *exhaustive at the engine level* needs a fact that was assumed rather than proved:
`timeLinearity` is the only rule that can produce `.branchingOrdered`. `Tableau.lean` asserts it in
prose twice ("the only rule that produces this constructor"); there was no lemma. Now
machine-checked (line 424):

```lean
theorem applyRule_branchingOrdered_rule (rule : TableauRule) (sf : SignedFormula) (b : Branch)
    (ord : TimeOrdering) (bs : List (Branch × TimeOrdering))
    (h : (applyRule rule sf b ord).1 = RuleResult.branchingOrdered bs) : rule = .timeLinearity
```

(exhaustive case analysis over all ~32 constructors × both signs; needs `maxHeartbeats 4000000`).

#### 3.2 A Phase-11 asset that fell out

Getting claim (ii) to engine level required the bridge from `expandOnceUnblocked` to the arms,
across all three pick stages (ordinary / seriality / linearity). That bridge is now proved (line
441) and is directly reusable by the approved route-(b) work:

```lean
theorem expandOnceUnblocked_splitOrdered_shape
    (h : (expandOnceUnblocked b ord fc tr).1 = ExpansionResult.splitOrdered bs) :
    ∃ t₁ t₂, firstIncomparablePair b ord = some (t₁, t₂) ∧
      bs = [ (b, ord.addFuture t₁ t₂), (b, ord.addFuture t₂ t₁),
             (b.identifyTime t₂ t₁, ord.identifyTime t₂ t₁) ]
```

It consumes landed `findApplicable{,Serial,Linearity}Rule_applyRule_eq` plus a local re-proof of the
`private` `pick_splitOrdered`. Note: the landed `splitOrderedRank_lt_of_timeLinearity` is stated at
the `applyRule` level and had no engine-level consumer; this is that consumer.

---

## Decisions

1. **Route (b) is confirmed, and this dispatch is NOT a third retarget decision.** The pre-agreed
   failure branch (any temporal rule failing witness preservation) was not triggered: all six
   temporal rules verify. No claim was weakened, narrowed into vacuity, or worked around to reach
   this verdict. The gate is cleared on its own terms.

2. **`hnsl` is reported as a new obligation rather than absorbed as a hypothesis.** The cheaper
   move — carrying irreflexivity as an assumption in the shape `hT` has — is exactly the pattern the
   user explicitly rejected for the mint bound, and it would push the same discharge obligation
   downstream. It is therefore surfaced as a first-class work item with its own phase (see
   Recommendations section 5), not buried in a lemma signature.

3. **Nothing was landed in the library; all 27 lemmas are held in scratch.** Two reasons. First,
   this is the research stage and landing is optional. Second, `Fuel.lean` is shared with task 426,
   and landing here would have created precisely the concurrent-edit hazard the task record warns
   against. `Fuel.lean` was read-only throughout. This defers the file-placement question (extend
   `Fuel.lean` vs. open a new file) to the implementation plan, which is where the task-426
   sequencing will actually be known.

4. **Claim (ii) was proved as a membership statement, not a cardinality statement.**
   `x ∈ b → ρ_SF x ∈ arm` is compatible with the refuted `.splitOrdered` cardinality twin on the
   do-not-re-attempt register: arm 3 still shrinks `toFinset.card` via `eraseDups` merging, and
   nothing here claims otherwise. This framing was chosen deliberately so that the register is
   respected rather than circumvented.

5. **The `linter.unusedTactic` warning in the scratch file was silenced with an explanation rather
   than "fixed" by deleting the tactic.** The flagged `exact RuleResult.noConfusion h` is not dead
   code — it is the `first`-alternative's failure mechanism, and deleting it leaves 12 goals
   unsolved. Removal was attempted and reverted; the file now carries a
   `set_option linter.unusedTactic false in` with a comment naming the 12 affected constructors.

---

## Recommendations

### 4. What route (b) needs, restated against verified ground

Both gate claims hold, so the approved work items stand. Grounding notes per item:

#### 4.1 Work item 1 — witness preservation (~3 phases)

**Largely done by this research.** `arm3_preserves_witness` is the target statement and it
elaborates sorry-free. Remaining work for the implementation phases is (a) landing these lemmas in
`Fuel.lean` (or a new file — see the task-426 coordination note), and (b) the *new* obligation in
section 5. Reusable assets, all in the scratch file:

`identifyTime_edge`, `mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`,
`identifyTime_no_collapse`, `mem_directFutureOf_iff'`, `mem_directPastOf_iff'`, `pathN_along`,
`directFutureOf_transport`, `directPastOf_transport`, `futureOf_transport`, `pastOf_transport`,
`mem_identifyTime`, `contains_identifyTime`, `knownWorlds_identifyTime`,
`any_knownWorlds_transport`, `any_futureOf_transport`, `any_pastOf_transport`, `contains_at`,
`witnessPresent_identifyTime`, `incomparableB_of_firstIncomparablePair`, `IrreflOrd`,
`irreflOrd_identifyTime`, `irreflOrd_addFuture`, `applyRule_branchingOrdered_rule`,
`expandOnceUnblocked_splitOrdered_shape`, `expandOnceUnblocked_splitOrdered_no_deletion`,
`arm3_preserves_witness`.

Budget note: three of these (`mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`,
`identifyTime_no_collapse`) were described by report 03 as already machine-checked but were never
landed. Do not plan as if they exist in the library.

#### 4.2 Work item 2 — restatement with an explicit mint-budget parameter (~1 phase)

Unchanged and unobstructed. Report 03 section 4's negative result stands (a per-step potential over
`(b, ord)` provably cannot express the amortized bound), and `maxTime` remains a non-proxy (arm 3
can lower it). The parameter goes in the `branchesUsed`/`maxBranches` shape already established at
`Saturation.lean:590-594`.

#### 4.3 Work item 3 — amortized induction (~2-3 phases)

The chain `#mints ≤ 8·|U|` → `#identifications ≤ |knownTimes|₀ + #mints` →
`total shrinkage ≤ #identifications · |U|` → `#extensions ≤ |U| + total shrinkage` → terminus. Both
premises of step 1 are now verified (a mint requires `witnessPresent = false`; after it the witness
is present — `Tableau.lean:2336` — and stays present, findings 1 and 3). **No additional obstruction
was found in the counting chain itself.** The one additional obstruction found is section 5, and it
sits in work item 1, not in the chain.

### 5. NEW OBLIGATION: irreflexivity of the constraint list

Route (b) must now discharge:

```lean
def IrreflOrd (ord : TimeOrdering) : Prop := ∀ p ∈ ord.constraints, p.1 ≠ p.2
```

as an invariant of the run, threaded through `expandBranchWithFuel` alongside the existing state.
Status of the three preservation cases:

| Source of a new constraint | Status | Note |
|---|---|---|
| `TimeOrdering.identifyTime` (arm 3) | **VERIFIED** (`irreflOrd_identifyTime`, line 348) | Unconditional — the collapse filter is exactly what makes this free |
| `addFuture t₁ t₂` (arms 1-2 of `timeLinearity`) | **VERIFIED** (`irreflOrd_addFuture`, line 362, plus `firstIncomparablePair_spec`) | `t₂ ≠ t₁` is one of the trigger's own guarantees |
| `addFuture l.time freshTime` (nine fresh-time mint sites) | **NOT PROVED — reduced, not closed** | Needs `l.time ≠ b.nextTime`, i.e. `l.time ≤ b.maxTime`, i.e. `sf ∈ b`. `Tableau.lean:2597 le_maxTime` and `:2608 not_mem_of_time_nextTime` are landed and are the right tools; all nine sites use `branch.nextTime` (`Tableau.lean:761, 801, 834, 878, 924, 971, 1069, 1168, 1370`) |

**One identified risk point, not resolved here.** `densityRule` (`Tableau.lean:1370-1373`) adds a
*second* edge, `addFuture freshTime t'`, where `t'` is drawn from `timeOrd.futureOf l.time`. That
needs `t' ≠ freshTime`, which follows from an auxiliary invariant "every time mentioned in the
ordering is a branch time" — plausible but unproved, and with a visible way to fail: a `.branching`
step hands the *same* `newOrd` to every arm, so an arm whose formula list does not carry the fresh
witness would hold an ordering edge to a time absent from its own branch, and that arm's `nextTime`
could then collide. `densityRule` only appears at frame classes ≥ `.Dense` (`denseRules`,
`Tableau.lean:1593-1595`, gated in `allRulesForFC` at `:1626`), so the risk is confined — but the
target theorem is quantified over `fc`, so it is not avoidable by scoping.

**Recommendation for the plan**: make irreflexivity its own phase, ordered **before** the
witness-preservation phases that consume it, with an explicit `[BLOCKED]` escalation clause on the
`densityRule` sub-case. Do not fold it into an existing phase as an afterthought — it is exactly the
shape of thing this task has twice been burned by.

### 6. Sequencing recommendation

1. Phase: land `IrreflOrd` plus its three preservation cases (two already proved; the mint case via
   `le_maxTime`), with the `densityRule` `[BLOCKED]` clause.
2. Phases: land the witness-preservation stack (work item 1), consuming the invariant from step 1.
3. Phase: restatement with the mint-budget parameter (work item 2).
4. Phases: amortized induction and terminus (work item 3).

Resolve the `Fuel.lean`-vs-new-file placement question against task 426's state at plan time.

---

## Constraint Compliance

- No engine file touched. `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s
  `maxBranches := 50000` default are byte-identical; `git status` shows no `.lean` file under
  `FormalSystem/` modified.
- Nothing landed in the library, so the repo stays green. All verification was done with
  `lake env lean` against a self-contained scratch file importing
  `FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel`; final elaboration is exit 0 with
  zero warnings.
- No `NoSplit`, no admitted `WorldWitness`, no admitted `hT`, no `sorry`, no new axiom.
- Neither item on the do-not-re-attempt register was re-attempted: no unconditional
  `buildTableau_isSome`, no `.splitOrdered` cardinality twin. Finding 3 proves *non-deletion*
  (`x ∈ b → ρ_SF x ∈ arm`), which is a membership statement and is compatible with the refuted
  cardinality statement.
- Route (a) not revisited. No mint bound proposed as a carried hypothesis. No obligation pushed onto
  task 412.
- Task-426 coordination: `Fuel.lean` was **read only**. The 27 new lemmas are held in
  `specs/428_engine_totality_at_a_quantified_branch_budget/scratch/04_witness-preservation.lean`,
  outside the build, so there is no concurrent-edit hazard until an implementation phase
  deliberately lands them.
- Task-number citations appear only in this report and the sibling scratch file, both under
  `specs/**`; no file outside `specs/**` was written.

---

## Note for the Consuming Task

Unchanged: `buildTableauAt_isSome_of_budget` is **not landed**, and task 412 must not yet be planned
against it. The Phase 3 assets (`BudgetedTableau`, `buildTableauAt`, `BudgetedTableau.upgrade`)
remain available and sorry-free.
