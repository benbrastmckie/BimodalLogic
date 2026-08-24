# Implementation Plan: Task #426

- **Task**: 426 - Settle anchor row: countermodel or non-termination for `(G p) → □(G p)`
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: `specs/426_settle_anchor_row_countermodel_or_nontermination_for_g_p_box_g_p/reports/01_settle-anchor-row-verdict.md`
- **Artifacts**: plans/01_record-anchor-row-verdict.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Research settled the task's primary question: for `φ = (G p) → □(G p)` the answer is
hypothesis **(a) — budget, already satisfied**. The branch saturates, the measured fuel ceiling is
25, `decide φ = .invalid`, and `getCountermodel?.isSome = true` in the current working tree. No
theorem, bound, or engine behaviour needs to change. What remains is to (i) re-measure the numbers
independently so the assertions committed to source are grounded, (ii) fix the one in-scope
factual defect — `CrossWorldPropagationProbe.lean`'s module docstring, which still narrates the
superseded "a wrong answer became no answer / it exhausts its fuel" state and contradicts row F
eleven lines below it — and (iii) record the measured ceiling and the diagnosed `F(G p)`
non-termination witness in `Fuel.lean`, the file the task scoped the (a)-branch obligation to.

### Research Integration

Findings carried directly into the phases below:

- **Primary verdict (a)**: `buildTableau φ n .Base` is `none` for `n ≤ 24` and `.hasOpen` with a
  40-formula certified open branch for every `n ≥ 25` out to 1000. The `none` below 25 is genuine
  exhaustion inside `expandBranchWithFuel`, not the "still not saturated" arm — verified by
  splitting the two stages. Phase 1 re-measures this bracket; Phase 4 records it.
- **Row F already correct**: `CrossWorldPropagationProbe.lean` row F pins
  `(false, true, false, false, false)` and is green. Its own docstring is current. The task's
  "update that row if the verdict moves" obligation is already discharged — no `#guard_msgs`
  value moves in this plan.
- **The in-scope defect is the module docstring** (lines 51-56), whose every emphasised clause is
  false of the current engine, plus its dangling `see the plan's Phase 6 triage` pointer.
- **Hypothesis (b) is real but on a different formula**: `F(G p)` reaches a stationary 21-formula
  branch at every fuel ≥ 25; the residue is an unfulfilled `T(F ¬p)` eventuality at a blocked
  time, so no fuel figure can rescue it. That sharpens `Fuel.lean:2256`'s existing witness note
  from a named counterexample into a diagnosed one.
- **Countermodel caveat (out of scope)**: the Layer-0 `SimpleCountermodel` flattens the
  `(world, time)` label, so the returned valuation is unusable even though the refutation is
  sound. `CountermodelExtraction.lean` is outside `file_scope`; recorded, not worked.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` carries no item naming the tableau anchor rows or the decidability fuel
ceiling; this work advances no tracked roadmap item and none should be marked. Recorded here so a
later reader does not re-search for an alignment that does not exist.

## Goals & Non-Goals

**Goals**:

- Independently reproduce the (a)-vs-(b) discrimination for `(G p) → □(G p)` before any measured
  number is written into source, and record the reproduction in a task artifact.
- Replace `Tests/BimodalTest/CrossWorldPropagationProbe.lean`'s module-docstring narrative with
  the three-step history (wrong answer → no answer → right answer), the measured ceiling, and no
  dangling plan-phase pointer.
- Record the measured anchor-row ceiling and its headroom in `soundFuel'`'s docstring in
  `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`, discharging the task's
  "(a) → find and record the ceiling" obligation in the file it was scoped to.
- Sharpen the `F(G p)` witness note at `Fuel.lean:2256` from *named* to *diagnosed*, foreclosing
  the next reader's temptation to raise a fuel figure.
- Add constructor-pinning sibling rows for rows A and C, closing for the whole A-C family the
  `isValid`-blindness that row F closed for row B.

**Non-Goals**:

- **Do NOT** reintroduce any temporal-copy propagation block into `boxNeg`/`diamondPos`. That is
  the removed unsoundness; the branch reaches `.invalid` by *saturating an open branch*, the
  opposite of closing, and reinstating the copy would restore a false claim of validity.
- No change to any theorem, definition, or fuel bound in `Fuel.lean`. Nothing measured
  contradicts anything proved there; `soundFuel'` (1 048 576) and `worldFuel' … 1` (≈1.1×10¹²)
  are ~4×10⁴ and ~4×10¹⁰ times the measured 25.
- No edits to `Tests/BimodalTest/BoxNegReachabilityProbe.lean`, whose module docstring (`:64-70`)
  and row-12 docstring (`:290-294`) carry the identical superseded narrative on the identical
  formula. Out of `file_scope`; needs an explicit scope extension or a follow-up task, and must
  not be fixed silently.
- No work on `CountermodelExtraction.lean`'s label-flattening caveat (out of `file_scope`).
- No work on `DecisionProcedure.lean:194`'s conflation of three `buildTableau = none` routes into
  `.fuelExhausted` (out of `file_scope`; recorded for a follow-up).
- No work on the decidable-branch-gate family (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`,
  `regionLabelCheck`, `rayUpOk`/`rayDnOk`) — the task description names it a separate concern.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Re-measurement contradicts the research numbers (ceiling ≠ 25, or `decide` ≠ `.invalid`) | H | L | Phase 1 gates Phases 2-4; docstrings assert only Phase-1-reproduced values. If the verdict itself moves, stop and re-dispatch rather than writing a third narrative. |
| An implementer "helpfully" fixes `BoxNegReachabilityProbe.lean`'s matching stale docstring | M | M | Explicit non-goal above; Phase 5 gate asserts `git diff --name-only` touches exactly the two `file_scope` files. |
| An implementer reinstates a temporal-copy block to make something close | H | L | Explicit prohibition in the task description and non-goals; Phase 5 gate asserts `Tableau.lean` is untouched in the diff. |
| Doc-comment edit breaks Lean elaboration (unbalanced `-/`, stray `/-!`) | M | M | Every doc-edit phase carries a `local` tier: build the edited module before the phase closes. |
| New prose cites a task number (both files live outside `specs/**`) | M | M | Phase 2 must *remove* the existing `see the plan's Phase 6 triage` pointer, and every new sentence must cite durable anchors (file paths, declaration names, measured values) only. |
| Ceiling recorded as a proved bound rather than an empirical measurement | M | L | Phase 4 wording must mark the figure as *measured*, adjacent to but not conflated with the proved `soundFuel'`/`worldFuel'` figures. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel. Phases 2 and 4 touch disjoint files
(`Tests/BimodalTest/CrossWorldPropagationProbe.lean` and
`FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` respectively) and may run
concurrently; Phase 3 edits the same file as Phase 2 and is therefore serialized after it.

---

### Phase 1: Reproduce the verdict and bracket the ceiling [COMPLETED]

**Goal**: Independently re-derive every number that Phases 2-4 will write into source, so no
committed assertion rests on a docstring or a prior report. Produce a measurement record.

**Tasks**:

- [x] Write a scratch `lake env lean` file (see the research report's §7 shape; no `lake build`
      required if the `.olean` tree is current) importing `FormalSystem.Metalogic.Decidability`
      and defining `p`, `gp := Formula.allFuture p`, `φ := gp.imp gp.box`.
- [x] Measure `decide φ` and record the tuple
      `(isValid, isInvalid, isFuelExhausted, isExtractionFailed, isUndecided)`.
- [x] Measure `(decide φ).getCountermodel?.isSome`.
- [x] Bracket the ceiling from **both** sides: evaluate `buildTableau φ n .Base` across
      `n ∈ [0, 40]` plus `45, 50, 60, 80, 100, 200, 400, 1000`; record the largest `n` returning
      `none` and the smallest returning `.hasOpen`, together with the open-branch length at each
      tested `n ≥` the ceiling (confirm it is stationary).
- [x] Split the two stages at and just below the ceiling: call
      `expandBranchWithFuel ib fuel TimeOrdering.empty .Base` directly, then `findUnexpanded` on
      its `.inr` payload, to confirm the sub-ceiling `none` is genuine exhaustion inside
      `expandBranchWithFuel` and **not** the "still not saturated" arm.
- [x] Run the same two-stage diagnostic on `ψ := F (G p)`: record `buildTableau ψ n .Base` across
      `n ∈ {10, 25, 50, 100, 200, 500, 1000, 2048, 4096}`, the `expandBranchWithFuel` branch
      length at each (confirm stationary), that `findUnexpanded` is `some _` at every fuel, and
      the identity of the residual formula before and after `saturateBlocked`.
- [x] Measure `decide` constructor tuples and `getCountermodel?.isSome` for row A
      (`(¬F p) → □(¬F p)`) and row C (`(¬P p) → □(¬P p)`) — the inputs Phase 3 needs.
- [x] Write the measurement table to
      `specs/426_settle_anchor_row_countermodel_or_nontermination_for_g_p_box_g_p/reports/02_measured-constants.md`,
      including the exact scratch-file source so the numbers are reproducible.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: The research asserts ceiling = 25 (none at `n ≤ 24`, `.hasOpen` at
`n ≥ 25`), certified open branch length 40, pre-post-pass branch length 37, `decide φ = .invalid`
with a countermodel, and for `F(G p)` a stationary 21-formula branch at every fuel ≥ 25 with
residue `T(F ¬p) @ (0,4)` after `saturateBlocked`. Every one of these is a hypothesis. Confirm by
direct `lake env lean` evaluation in this phase. **If the ceiling, the constructor, or the
countermodel flag differs from the research, do not proceed to Phases 2-4** — record the
divergence in `02_measured-constants.md` and stop, since the whole point of this task is that the
formula has already been re-narrated twice on unreproduced numbers.

**Files to modify**:

- `specs/426_settle_anchor_row_countermodel_or_nontermination_for_g_p_box_g_p/reports/02_measured-constants.md` -
  new task artifact: the measurement table plus reproduction source. No source file is touched in
  this phase.

**Verification**:

- Every number written into `02_measured-constants.md` is accompanied by the command that
  produced it.
- The ceiling is bracketed from both sides (a largest-`none` and a smallest-`hasOpen`), not
  merely observed from above.
- The sub-ceiling `none` is attributed to a specific stage (`expandBranchWithFuel` exhaustion vs
  the unsaturated arm), not left ambiguous.

---

### Phase 2: Realign the CrossWorldPropagationProbe module docstring [COMPLETED]

**Goal**: Replace the module docstring's superseded claim that the engine "no longer wrongly
closes, but neither does it positively refute — it exhausts its fuel" with the current, measured
state, so the file stops contradicting its own row F eleven lines below.

**Tasks**:

- [x] Locate the `**Row F is the discrimination rows A-C cannot make**` paragraph in the module
      docstring (research reports it at lines 51-56; confirm the anchor by content, not by line
      number).
- [x] Rewrite the paragraph to state the three-step history explicitly: `extractionFailed` (a
      wrong answer — under this codebase's R7 semantics an assertion of validity on an invalid
      formula) → `fuelExhausted` (no answer, honest ignorance) → `.invalid` with a countermodel
      (the right answer), and name the Phase-1-measured fuel ceiling as the budget at which the
      branch saturates.
- [x] Delete the dangling `see the plan's Phase 6 triage` pointer; it names no durable anchor.
      Do not replace it with any task-number reference — this file is outside `specs/**` and the
      no-task-references rule applies. Cite `Tableau.lean`'s `trivialEventWitnessed` and row F
      itself instead.
- [x] Re-read the surrounding module docstring (in particular the "This file's original thesis was
      superseded" section) for any other sentence the new verdict falsifies, and correct only
      those that are actually false — the deletion narrative in the opening sections remains
      accurate and must not be disturbed.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The research asserts exactly one in-scope defect in this file — the module
docstring at lines 51-56 — and that row F's own docstring and every `#guard_msgs` value are
already current. Confirm at implementation time by reading the whole 134-line file and checking
each factual claim against Phase 1's measurements; if a second stale claim is found, fix it in
this phase and say so, rather than treating the enumerated single defect as closed.

**Files to modify**:

- `Tests/BimodalTest/CrossWorldPropagationProbe.lean` - module docstring only; no `#eval` and no
  `#guard_msgs` value changes in this phase.

**Verification**:

- `lake env lean Tests/BimodalTest/CrossWorldPropagationProbe.lean` elaborates clean — every
  `#guard_msgs` still passes, confirming no pinned value moved.
- `git diff` on the file shows changed hunks confined to the module `/-! … -/` block.
- The string `Phase 6 triage` no longer appears in the file, and no `task N`-shaped reference was
  introduced (`scripts/check-task-references.sh` or an equivalent grep over the file is clean).

---

### Phase 3: Add constructor-pinning rows for A and C [IN PROGRESS]

**Goal**: Close for rows A and C the same `isValid`-blindness row F closed for row B. Rows A and C
are currently `isValid`-only, so they read `false` identically under `.invalid`,
`.fuelExhausted` and `.extractionFailed` — the exact indistinguishability that let this formula
family go a full cycle misread.

**Tasks**:

- [ ] Add a row G pinning the `decide` constructor tuple for row A's formula
      `(¬F p) → □(¬F p)`, using the same
      `(isValid, isInvalid, isFuelExhausted, isExtractionFailed, isUndecided)` shape as row F, with
      the value measured in Phase 1.
- [ ] Add a row H pinning the same tuple for row C's formula `(¬P p) → □(¬P p)`.
- [ ] Give each new row a docstring stating why it exists (row A/C's `isValid` collapses three
      constructors into one `false`) and what it pins. Optionally pin
      `getCountermodel?.isSome` alongside if Phase 1 measured it stably.
- [ ] Confirm this is a pure **addition**: no existing pinned value in the file changes.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The research asserts rows A and C both now decide `.invalid` with
`getCountermodel?.isSome = true`. Phase 1 confirms this directly; write the Phase-1 value, never
the research's. If either row measures a constructor other than `.invalid`, still pin the measured
value and document it — the row's purpose is discrimination, not a particular verdict.

**Files to modify**:

- `Tests/BimodalTest/CrossWorldPropagationProbe.lean` - two new `#guard_msgs`/`#eval` rows plus
  their docstrings, appended after row F and before the closing `end`.

**Verification**:

- `lake env lean Tests/BimodalTest/CrossWorldPropagationProbe.lean` elaborates clean with the new
  rows passing their `#guard_msgs`.
- `git diff` confirms rows A-F's pinned values are byte-identical to their pre-phase state.

---

### Phase 4: Record the ceiling and diagnose the `F(G p)` witness in Fuel.lean [IN PROGRESS]

**Goal**: Discharge the task's (a)-branch obligation ("find and record the ceiling") in the file
the task scoped it to, and upgrade the `F(G p)` note from a named counterexample to a diagnosed
one. Documentation only — no theorem, definition, or bound changes.

**Tasks**:

- [ ] In `soundFuel'`'s docstring (research anchor `:135-153`; confirm by content), add a measured
      anchor: `(G p) → □(G p)` saturates at the Phase-1 ceiling, against `soundFuel' = 1 048 576`
      and `worldFuel' … 1 ≈ 1.1×10¹²` for this φ (`|subformulaClosure φ| = 8`). State the ratios.
- [ ] Word the addition so the measured figure is unmistakably **empirical** and adjacent to — not
      conflated with — the proved bounds. Nothing here weakens, strengthens, or reinterprets
      `soundFuel'`; it supplies a witness that the bound has large headroom in practice.
- [ ] At the `resolveOpenArm = none` note (research anchor `:2256`; confirm by content), keep the
      existing claims (both still hold) and add *why* the `F(G p)` outcome is live and why no fuel
      figure can rescue it: `expandBranchWithFuel` reaches a stationary branch at every fuel above
      the ceiling and returns the same branch, `findUnexpanded` is `some _` at every fuel, and the
      residue after `saturateBlocked` is an unfulfilled `T(F ¬p)` eventuality at a **blocked**
      time — blocking has stopped new times being minted while `untlPos` remains applicable, so
      the `findUnexpanded … = none` certificate can never be produced. Note that
      `trivialEventWitnessed` correctly does not suppress it, since that guard keys on the
      syntactic `event == Formula.top` and this event is `¬p`.
- [ ] Cite durable anchors only (declaration names, file paths, measured values). No task-number
      references — this file is outside `specs/**`.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The research asserts two docstring sites (`soundFuel'` at `:135-153`, the
`resolveOpenArm = none` note at `:2256`), zero `sorry`s in the file, and that nothing measured
contradicts anything proved there. Confirm the two anchors by content match before editing (line
numbers in a 2600+-line file drift), and confirm the sorry count with a grep before and after.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` - two docstrings. No
  `def`, `theorem`, or bound changes.

**Verification**:

- The module builds: `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel`
  (or `lake env lean` on the file) is clean.
- `git diff` shows changed hunks confined to `/-- … -/` and `/-! … -/` blocks — no line outside a
  doc comment moves.
- `grep -c sorry` on the file is unchanged (and zero).

---

### Phase 5: Final gate — full build, prohibition compliance, scope compliance [NOT STARTED]

**Goal**: Run the complete gate set and mechanically confirm that the two prohibitions the task
description makes binding were respected.

**Tasks**:

- [ ] `lake build` clean across the repository.
- [ ] Run both `file_scope` files under `lake env lean` and confirm every `#guard_msgs` passes.
- [ ] Assert scope: `git diff --name-only` against the task's base commit lists exactly
      `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` and
      `Tests/BimodalTest/CrossWorldPropagationProbe.lean` (plus `specs/**` artifacts). Any other
      source path in the diff is a scope violation to be reverted, in particular
      `Tests/BimodalTest/BoxNegReachabilityProbe.lean` and `CountermodelExtraction.lean`.
- [ ] Assert prohibition compliance: `FormalSystem/Metalogic/Decidability/Tableau.lean` is absent
      from the diff, and no temporal-copy propagation block was added to `boxNeg` or
      `diamondPos`. Both rules must still emit `.linear (witness :: boxProps ++ diaProps)`.
- [ ] Assert zero new `sorry`s and zero new axioms across the diff.
- [ ] Run the task-reference lint (`scripts/check-task-references.sh` or equivalent) over both
      edited source files; both are outside `specs/**` and must carry no task-number citation.
- [ ] Confirm the primary deliverable is on the record: the (a)-vs-(b) discrimination is stated in
      the research report and `02_measured-constants.md`, and the ceiling it turns on is now in
      `Fuel.lean`.

**Timing**: 0.5 hours

**Depends on**: 2, 3, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:

- None (verification only). Any repair this phase forces belongs to the phase that introduced the
  defect.

**Verification**:

- `lake build` exits 0.
- Both `file_scope` files elaborate with all `#guard_msgs` green.
- The diff's source-file set is exactly the two declared `file_scope` files.
- `Tableau.lean` untouched; `boxNeg`/`diamondPos` unchanged.

---

## Testing & Validation

- [ ] `lake build` clean.
- [ ] `Tests/BimodalTest/CrossWorldPropagationProbe.lean` elaborates with all rows (A-F plus the
      two new constructor rows) passing `#guard_msgs`.
- [ ] Rows A-F's pre-existing pinned values are byte-identical after the change — this task
      re-baselines nothing.
- [ ] `Fuel.lean` builds with zero `sorry`s and no non-docstring hunks in its diff.
- [ ] The measured ceiling asserted in `Fuel.lean` matches the value in
      `reports/02_measured-constants.md`, which in turn carries the command that produced it.
- [ ] `Tests/BimodalTest/BoxNegReachabilityProbe.lean` is untouched.
- [ ] No temporal-copy block exists in `boxNeg`/`diamondPos`.

## Artifacts & Outputs

- `specs/426_settle_anchor_row_countermodel_or_nontermination_for_g_p_box_g_p/reports/02_measured-constants.md`
  — reproduced measurement table with reproduction source.
- `Tests/BimodalTest/CrossWorldPropagationProbe.lean` — corrected module docstring, two added
  constructor-pinning rows.
- `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` — measured anchor on
  `soundFuel'`, diagnosed `F(G p)` witness note.
- Two follow-up items recorded for a future task, not worked here:
  `DecisionProcedure.lean:194` conflating three `buildTableau = none` routes into
  `.fuelExhausted`; `BoxNegReachabilityProbe.lean`'s module and row-12 docstrings carrying the
  same superseded narrative as the defect fixed in Phase 2. `CountermodelExtraction.lean`'s
  label-flattening of `SimpleCountermodel` is a third, already recorded in that file's own probe.

## Rollback/Contingency

Every change in this plan is a docstring edit or a pure test-row addition, so rollback is
`git revert` of the phase commit with no proof or build consequence. Two contingencies are
distinguished:

- **Phase 1 diverges from the research** (ceiling, constructor, or countermodel flag differs):
  stop before Phase 2. Record the divergence in `02_measured-constants.md` and re-dispatch. Do not
  write a third narrative onto unreproduced numbers — that failure mode is precisely what this
  task exists to end.
- **Phase 1 reproduces but a later build breaks**: revert the offending doc edit; the pinned
  `#guard_msgs` rows are the safety net and will fail loudly rather than silently, so a broken
  state cannot be committed green.
