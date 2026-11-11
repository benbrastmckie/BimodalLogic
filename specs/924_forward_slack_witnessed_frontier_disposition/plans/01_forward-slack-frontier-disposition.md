# Implementation Plan: Task #924

- **Task**: 924 - Decide the fate of the `ForwardSlackWitnessed` frontier, now that its only
  landed discharge route is refuted
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None blocking. Territory-serialized against task 918 — see "Territory" below.
- **Research Inputs**: `specs/924_forward_slack_witnessed_frontier_disposition/reports/01_forward-slack-frontier-disposition.md`
- **Artifacts**: plans/01_forward-slack-frontier-disposition.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md,
  plan-compliance.md, lean4.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research dispatch reached neither of the task description's two terminal outcomes and said so:
outcome (b) — "a compiled statement of why no route through the currently landed machinery can
succeed" — is FALSE, because a route through the currently landed machinery does succeed and was
compiled as task evidence. This plan lands that route in the library, lands the route-space
closure that makes the remaining frontier exactly one named sub-regime, and records the resulting
disposition in the durable places the parent task used — with the one correction the compiled
route forces: the `certStabK` restatement obligation stays PROVISIONAL rather than being made
permanent.

Three things land, in dependency order. The two route-(a) statements go into `LadderIdle.lean`
(both of them, with an added `import ... LadderCell`, rather than splitting the cell-level half
into `LadderCell.lean`). The route-space closure goes in as a wired evidence probe beside the
parent's `pin-cascade-straddle.lean`. The disposition is then recorded in the `LadderChain.lean`
module docstring, the refuted primitive's own docstring, `KTypeSummaryAxiomTest.lean`'s
Requirement (W) narrative, and `specs/state.json`.

Nothing here removes `ForwardSlackWitnessed` from the five depth-`0` cell-equality schemas, and
no docstring may be written as if it did. The discharge is CONDITIONAL on a run-local premise that
`ParamsOk` does not supply.

### Research Integration

The plan executes the research report's four recommendations, with one placement changed and one
addition:

- **Recommendation 1 (land the two statements)** — executed in Phase 1. The report offers two
  placements for the cell-level half ("it must import `LadderCell` or be placed in a module
  downstream of both"); this plan takes the FIRST, landing both statements in `LadderIdle.lean`
  with an added `import ... LadderCell`, rather than the report's parenthetical
  `LadderIdle`/`LadderCell` split. Rationale in Decisions 1.
- **Recommendation 2 (wire the route-space closure as a probe)** — executed in Phase 2, with the
  report's own territory warning honored (see "Territory" below).
- **Recommendation 3 (record the disposition in four durable places, `certStabK` provisional)** —
  executed in Phase 3. The `AUTO` answer recorded in `.decisions.json` settles the judgment call
  the report raised: the obligation stays PROVISIONAL and both conditional-discharge statements
  land.
- **Recommendation 4 (do NOT attempt the open side here)** — honored as a Non-Goal. No phase
  attempts the `I = 1` side.
- **Addition not in the report**: the generated-surface regeneration steps
  (`typst/generated/status.typ`, the module-inventory blocks). These are mechanical consequences
  of changing Lean line counts, enumerated by `plan-authoring-gate-collisions.md` Condition 1; the
  report had no occasion to name them.

Load-bearing facts carried from the report into the phase work:

- `idleGapLengtheningOfIdleRunRepeat_holds` leaves the next region's countdown EQUAL while raising
  the idle run by `d · k`. That one clause is the whole route: the regime asks
  `K ≤ n + cntAt g z + I - l` and the free Lipschitz bound already gives `K ≤ n + cntAt g z + I`.
- `idleSplice_pins` discharges the pin clause unconditionally, so no part of `(K2)`'s
  `cascadeBound` is spent and the refuted route's obstruction is never re-entered.
- The premise is NOT `ParamsOk`-derivable: `(K1)` quantifies `prodCycleLens`, `objCycleLens` and
  `satPeriod`, never `idleCycleLens`, and `idle_run_lt_tIdle_of_no_idleCycle` is the bound the
  other way.
- Both evidence files already compile `sorry`-free and diagnostic-free under `lake env lean`
  against the project's own oleans, so Phases 1 and 2 are transcription-and-scoping work, not
  proof-search work.

### Prior Plan Reference

No prior plan exists for task 924. The PARENT task's plan
(`specs/917_forward_slack_witnessed_discharge_or_refutation/plans/01_forward-slack-witnessed-discharge.md`)
was read as reference only; no phase is copied from it. Three things were calibrated against it:

- **Effort calibration.** The parent's per-phase Lean-landing estimates (roughly 1-1.5 h for a
  phase adding 50-120 lines of already-compiled proof plus its scoping docstring) are the basis
  for this plan's Phase 1 and Phase 3 estimates.
- **Validated approach.** The parent's phases each committed once, green, with the
  generated-surface regeneration staged alongside the Lean change rather than deferred. That
  shape is reused verbatim here, because the pre-commit hook makes any other shape fail.
- **Risk awareness.** The parent's Phase 5 was a decision gate whose FAIL branch it had planned
  for in advance. This plan has no gate: both evidence files are already compiled, so the
  uncertainty the parent carried does not recur. What it carries instead is a territory risk the
  parent did not have.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context and `roadmap_flag` is not
set, so no roadmap review/update phases are generated and `specs/ROADMAP.md` is NOT written by
this task. For the record, and as information for whoever next sweeps that file: `ROADMAP.md`
currently carries the line "`ForwardSlackWitnessed`'s discharge route is REFUTED at the pin
layer", which this task's outcome makes incomplete rather than wrong — the pin-layer route stays
refuted; a second, cascade-free route exists and is conditional. Correcting it is out of scope
here.

## Goals & Non-Goals

**Goals**:
- `hasForwardSlack_of_idleRunRepeat` -- the path level: the pumped path sits at the same ladder
  state at `z`, realizes the same stab-free type there, and carries the forward-slack regime at
  amount `l`.
- `IdleRunPumpable` -- the run-local premise as a named predicate: pending-forever past at `z`,
  the pending-forever gap, and an `(objAt, tpOf)`-repeat block inside the intervening idle run.
- `forwardSlackWitnessed_of_cell_idleRunPumpable` -- the cell level:
  `ForwardSlackWitnessed … x z l x.1.2.2` at EVERY amount `l`, from the amount-free run-local
  premise.

**Non-Goals**:
- Removing `ForwardSlackWitnessed` from the five depth-`0` cell-equality schemas of
  `LadderCell.lean`. The discharge is conditional; the hypothesis stays carried, and every
  docstring landed here says so explicitly.
- Claiming the reserved name `cellLE_zero_const_of_kappa_eq`. It stays claimed by nothing, and no
  declaration introduced here may take that name or any prefix of it.
- Attempting the open side — the paths whose intervening idle run has length `1`. The research
  report's Recommendation 4 is explicit that this belongs to a separate task with its own
  question (whether the object-layer shortenability of its Finding 6 can be lifted at all).
- Any amendment to `(K1)`. Excluded by the task description, assessed in the sibling research as
  carrying a blast radius of all wired probes, and orthogonal — the obstruction lives in the pin
  layer, not the periodicity layer.
- Making the `certStabK` restatement obligation PERMANENT. That is the second half of outcome (b);
  the compiled route removes its justification, and the recorded decision keeps it PROVISIONAL.
- Re-entering the doubling cascade, or weakening `ForwardSlackWitnessed`'s statement to make the
  open side go through.
- Writing `specs/ROADMAP.md` (see "Roadmap Alignment" above).

## Territory

**Two concurrent siblings hold files this plan must touch.** This is declared here, at plan
level, rather than only inside the phases, because it governs when the implementation may be
dispatched at all.

| File this plan touches | Held by | Phase |
|---|---|---|
| `scripts/check-evidence-probes.sh` | 918 | 2 |
| `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` | 918 | 3 |
| `README.md` | 918 | 4 |
| `FormalSystem/README.md` | 918 | 4 |
| `FormalSystem/Metalogic/README.md` | 918 | 4 |
| `FormalSystem/Metalogic/Decidability/RaySummary/README.md` | 918 | 4 |
| `typst/generated/status.typ` | 918 | 1, 3 |

`LadderIdle.lean`, `LadderChain.lean`, `specs/evidence/forward-slack-pin-cascade/`,
`scripts/c20-declaration-baseline.txt` and `specs/state.json` are free of both siblings. 925 holds
`LadderPump.lean` only, which this plan does not touch.

**The mechanism this plan relies on is declaration, not avoidance.** Every shared path above is
declared in its phase's `Files to modify` block, so `plan-file-scope-harvest.sh` writes it into
`active_projects[].file_scope` at plan postflight and `orchestrate-batch-admit.sh` sees the
overlap with 918 on the next cycle and serializes the two rather than co-dispatching them. That
is the designed route for a shared-territory pair (`batch-orchestration-guardrails.md`, "Batching
Is the Default"), and it is why this plan does NOT silently narrow its scope to the free files.

**Why the collision is unavoidable rather than an artifact of the phase split.** Any change to
Lean source line counts trips `typst/generated/status.typ`'s `formalsystem-line-count` /
`tests-line-count`, which `.githooks/pre-commit` enforces as a BLOCKING check on any commit whose
staged set touches a `.lean` path (`plan-authoring-gate-collisions.md` Condition 1). The
regeneration therefore cannot be deferred to a reconciliation phase; it must be staged in the same
commit as the Lean change. So every Lean-landing phase here touches a 918-held file by
construction.

**If 918 is still `implementing` when this plan's implementation dispatch begins**: per the
dispatch's own concurrency note item (5), do not proceed into a colliding phase. Close that phase
`[BLOCKED]` with the observed state recorded (`git log` for the file, 918's status in
`specs/state.json`), finish every non-colliding phase in full, and report the split. Do NOT edit a
file 918 has uncommitted changes in, and do NOT add a `dependencies[]` edge from inside the
implementation dispatch — an edge pointing at 918 would block 924's own admission, including the
phases that have no collision at all.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| 918 is mid-flight in a file a phase must edit | H | H | Declared file scope serializes the pair at admission; if the dispatch runs anyway, the colliding phase closes `[BLOCKED]` and the rest completes (see "Territory") |
| A scoped build of `LadderWindow.lean` fails for 918's reasons, not this task's | M | M | Dispatch concurrency note item (4): a failure in a file outside this task's own scope is possibly a sibling's in-flight edit. Check `git log`/`git status` for that file before treating it as a regression; never "fix" it |
| Adding `import ... LadderCell` to `LadderIdle.lean` creates an import cycle | H | L | Confirmed acyclic at authoring time: `LadderCell → LadderChain → {LadderPump, CounterQuotient}`, and `LadderIdle → LadderChain`; `LadderCell` does not import `LadderIdle`. `LadderWindow` already imports both. Re-confirm with the scoped build, which fails loudly on a cycle |
| The docstring edit at the top of `LadderIdle.lean` shifts every line number in the file, breaking a `LadderIdle.lean:NNN` citation elsewhere | M | M | C20's third assertion gates name-bearing citations that land outside their declaration's span, against `scripts/c20-declaration-baseline.txt`. Run `check-module-invariants.sh` and, if a NEW name-bearing finding appears, re-anchor the citation if it is in a file this plan may touch, or record it as an enumerated out-of-scope finding if it sits in another task's `specs/**` report |
| C16 (`env_linter`) reports a new finding on the added declarations | M | M | The declarations carry docstrings (docBlame) and reuse `set_option linter.unusedFintypeInType false in` per declaration exactly as `exists_iterIdleSpliced_ladderPath` does. If a NEW C16 finding lands on an added name, fix the declaration; do not add a `nolints.json` entry to paper over it |
| C16 is already red for pre-existing reasons (925 is clearing `LadderPump.lean`'s debt) | L | H | `plan-authoring-gate-collisions.md` Condition 4: a gate whose only failures are pre-existing and outside this task's file scope is a recorded PASS, with the pre-existing findings enumerated. Never edit an out-of-scope file to force an absolute zero |
| A docstring is written in a way a reader takes as an unconditional discharge | H | M | Every new docstring carries the three scoping clauses verbatim (Phase 1, task list). Phase 4 verifies each clause is present by grep before the task closes |
| `check-evidence-probes.sh`'s `WIRED` array or comment-table shape has changed under 918's edits | M | M | Phase 2's first task is to re-read the file immediately before editing (dispatch concurrency note item (1)) and match the live shape, not the shape recorded here |
| The probe's import closure cannot be loaded because a concurrent `lake build` is rewriting `.lake` | L | M | `check-evidence-probes.sh` reports this as its own `FAIL (environment: ...)` diagnostic class, which its header rules is NEVER probe rot. Re-run once the concurrent build has finished; repair no probe on that evidence |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |

Phases within the same wave can execute in parallel. Phase 4 is the final phase: it is the
highest-numbered phase, it is a terminal node of the dependency graph, and it depends transitively
on every other phase.

---

### Phase 1: The Two Route-(a) Statements, Landed in `LadderIdle.lean` [COMPLETED]

**Goal**: `ForwardSlackWitnessed` at every amount becomes derivable, in the library, from one
amount-free run-local premise — through the idle pump rather than through the refuted deletion.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` immediately before
      editing (concurrency note item (1)), and re-read
      `specs/924_forward_slack_witnessed_frontier_disposition/evidence/route-a-idle-pump-discharge.lean`
      as the source text.
- [x] Add `import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell` beside the existing
      `LadderChain` import. Confirm no cycle: `LadderCell` must not import `LadderIdle` (check by
      grep before building, not only by trusting the build).
- [x] Transcribe `IdleRunPumpable`, `hasForwardSlack_of_idleRunRepeat` and
      `forwardSlackWitnessed_of_cell_idleRunPumpable` into a new `section` at the END of the
      module (append-only; do not insert above an existing declaration, which would shift its
      line number for no gain). Statements and proofs are lifted VERBATIM from the evidence file —
      this is transcription, not re-derivation; `plan-compliance.md`'s Statement Fidelity clause
      governs the signatures, which are pinned below under `## Lean Challenge Statements`.
- [x] Drop the evidence file's `namespace Probe924` wrapper and its file-level
      `set_option linter.unusedFintypeInType false`; place the declarations inside
      `namespace FormalSystem.Metalogic.Decidability.RaySummary` and give each one its own
      `set_option linter.unusedFintypeInType false in` line, with the precedent cited in a
      preceding comment exactly as `exists_iterIdleSpliced_ladderPath` does in this same file.
- [x] Write each declaration's docstring carrying the three scoping clauses the research report
      requires, so the statement is not read as the discharge it is not: **(i)** the premise is an
      object/run datum and NOT `ParamsOk`-derivable, naming `idle_run_lt_tIdle_of_no_idleCycle`
      and `(K1)`'s three conjuncts (`prodCycleLens`, `objCycleLens`, `satPeriod` — never
      `idleCycleLens`); **(ii)** `ForwardSlackWitnessed` is NOT removed from the five depth-`0`
      cell-equality schemas of `LadderCell.lean`; **(iii)** the reserved
      `cellLE_zero_const_of_kappa_eq` stays claimed by nothing, the ordinary window regime
      `c ≤ n + 1` stays uncovered, and the room bounds remain.
- [x] Correct the module docstring's two now-false claims in its `## Contract` section: "Nothing
      imports this module" (already false before this phase — `LadderWindow.lean` imports it) and
      "It states NO cell-level consequence: no `cellAt` claim … and no discharge of any obligation
      reserved in `LadderCell.lean`". Replace with the accurate position: the module now states a
      CONDITIONAL cell-level consequence, which discharges nothing reserved, and bullet (iii)'s
      closing sentence "`LadderCell.lean` is not edited" stays true and is kept.
- [x] Append `#print axioms` lines for the three new names at the end of the file, matching the
      file's own existing convention (two such lines already sit after the namespace close).
      *(deviation: altered — the three new lines are landed inside a bare `section` with the
      namespace `open`ed rather than fully qualified; the fully-qualified form of
      `forwardSlackWitnessed_of_cell_idleRunPumpable` is 106 characters and trips
      `linter.style.longLine`, which is a build failure under CI's `--wfail`. The two
      pre-existing lines keep their fully-qualified form. All three names are pinned.)*
- [x] Regenerate `typst/generated/status.typ` with `bash scripts/typst-sync-check.sh --fix` and
      stage it in the SAME commit as the `.lean` change — the pre-commit hook is blocking, not
      auto-regenerating.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: `LadderIdle.lean` is 860 lines at authoring time (read live via `wc -l`) and
carries NO `set_option linter.style.longFile` baseline, so the default 1500-line limit applies;
this phase adds an estimated 120-150 lines, which should leave it comfortably inside that limit.
`LadderIdle.lean`'s direct dependents are asserted to be exactly three — `LadderWindow.lean`,
`RaySummary.lean` and `FormalSystem.lean` — from a repo-wide grep for
`RaySummary.LadderIdle` at authoring time. Confirm BOTH with `wc -l` and a re-run of that grep at
implementation time rather than trusting the carried figures; if the dependent set has grown, the
Tier Justification's enumerated build set grows with it.

**Tier Justification**: The added `import … LadderCell` changes this module's position in the
import DAG, which no single-module build can observe, so the covering check is the changed module
plus its enumerated direct dependents:
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow`
together with
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary`
(the aggregator, which covers the `RaySummary.lean` and `FormalSystem.lean` import-list
dependents).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` - the added `LadderCell`
  import, the three new declarations with their scoping docstrings, the corrected `## Contract`
  paragraph, and the three `#print axioms` lines
- `typst/generated/status.typ` - regenerated `formalsystem-line-count` / file-count fields
  (`--fix`), staged in the same commit

**Verification**:
- Both scoped guarded builds green, and warning-free on the three new declarations: no
  `linter.autoImplicit`, no `linter.style.show`, no unused-variable warning. CI builds with
  `--wfail`, so a warning is a failure.
- `lean_verify` on each of the three new fully-qualified names: no `sorryAx`, no custom axiom, and
  a profile that is a subset of `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 BEFORE the commit is attempted.
- Each new docstring contains all three scoping clauses (i), (ii), (iii) — confirmed by reading
  the three docstrings, not by assuming the template was followed.
- The module docstring no longer asserts "Nothing imports this module" and no longer asserts that
  the module states no cell-level consequence.
- `wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` is below 1500, or a
  `longFile` baseline is added in the same change inside the linter's `N - 200 ≤ lines < N`
  acceptance window.

---

### Phase 2: The Route-Space Closure, Wired as an Evidence Probe [COMPLETED]

**Goal**: What remains open is exactly one named sub-regime, held in place by a compiled record
that CI re-checks, rather than by a paragraph in a report.

**Tasks**:
- [x] Copy
      `specs/924_forward_slack_witnessed_frontier_disposition/evidence/route-space-closure.lean`
      to `specs/evidence/forward-slack-pin-cascade/route-space-closure.lean`, beside the parent's
      `pin-cascade-straddle.lean`. The collection path, not a task directory, is required: a probe
      under a task directory leaves version control when `/todo` archives that task.
- [x] Extend the copied file's module docstring with a pointer to the companion positive record —
      the three declarations landed in Phase 1 — so a reader of the closure finds the route that
      succeeds, and state explicitly that this file measures the `K` dial and the placements and
      refutes nothing about `ForwardSlackWitnessed` itself. *(note: the extension also re-pointed
      the docstring's one existing cross-reference to the task-directory file
      `route-a-idle-pump-discharge.lean` at the landed `LadderIdle.lean` declarations instead —
      within this item's own scope, and required by the same archive-leaves-version-control
      rationale the preceding item gives. No declaration, signature, or proof was touched.)*
- [x] Re-read `scripts/check-evidence-probes.sh` immediately before editing (concurrency note item
      (1)); match the live shape of the `WIRED` array and of the comment table that precedes it,
      not the shape recorded in this plan. **This file is confirmed to exist at authoring time**
      (the `WIRED` array and its preceding comment table were read directly); if its structure has
      changed under a sibling's edits, follow the live structure. If it is absent or unreadable,
      close this phase `[BLOCKED]` and record the observed state — do not invent a wiring
      mechanism.
- [x] Add the `"forward-slack-pin-cascade/route-space-closure"` entry to the `WIRED` array
      (collection-relative form — `WIRED_REPO` is for a stranded probe only and needs a named
      blocker recorded beside it).
- [x] Add the probe's row to the comment table above the array, in the established two-column
      shape, naming: what the probe holds in place (the route space is surveyed, not merely
      asserted); its five headline declarations (`pend_endpoints_of_rep`,
      `block_confined_of_hcl`, `idle_run_two_of_block`, `whole_region_anchor_refuted`,
      `saturated_chain_is_the_doubling_recurrence`); what it does NOT establish (it is a
      measurement at the arithmetic and placement layers, not a refutation of
      `ForwardSlackWitnessed`, which stays neither discharged nor refuted on the `I = 1` side); and
      its axiom profile.
- [x] Confirm the probe is TRACKED by git (`git ls-files --error-unmatch` on the new path) —
      presence alone is not a guard, and the script tests tracking explicitly.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the probe contributes five headline declarations and that
no FormalSystem/Tests/BimodalTools line count moves (so no `typst/generated/status.typ`
regeneration is needed even though the staged set contains a `.lean` path and the pre-commit hook
therefore fires). Confirm both at implementation time: count the declarations in the copied file,
and run `bash scripts/typst-sync-check.sh --counts-only` before committing rather than assuming
the counts are untouched.

**Tier Justification**: `bash scripts/check-evidence-probes.sh` is the complete covering check —
a probe lives under `specs/`, outside every Lake target root, so no library module can observe it
and no module build reaches it.

**Files to modify**:
- `specs/evidence/forward-slack-pin-cascade/route-space-closure.lean` - new file: the five closure
  measurements, with the module docstring extended to point at Phase 1's positive record
- `scripts/check-evidence-probes.sh` - the `WIRED` entry and its comment-table row

**Verification**:
- `bash scripts/check-evidence-probes.sh` is green, the new probe appears in its output as a
  compiled entry, and no pre-existing probe is newly red.
- A `FAIL (environment: ...)` line is NOT read as probe rot: re-run once any concurrent `lake
  build` has finished, per the script header's TRIAGE RULE. No probe is repaired on that evidence.
- `git ls-files --error-unmatch specs/evidence/forward-slack-pin-cascade/route-space-closure.lean`
  exits 0.
- The wired total reported by the script increased by exactly one.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 3: Record the Disposition, with `certStabK` PROVISIONAL [COMPLETED]

**Goal**: The four durable places the parent task used say what is now true — the pin-layer route
is refuted, a second cascade-free route exists and is conditional, the frontier is exactly the
`I = 1` side, and the `certStabK` restatement obligation is PROVISIONAL, not permanent.

**Tasks**:
- [x] `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`, module docstring: amend
      the closing "What this refutation does NOT establish" paragraph. It currently ends by naming
      the `certStabK` consequence with no qualifier. Add: a cascade-free, deletion-free route
      through the landed idle layer DOES discharge the hypothesis conditionally
      (`forwardSlackWitnessed_of_cell_idleRunPumpable`, `LadderIdle.lean`), on a run-local premise
      that `ParamsOk` does not supply; what stays open is exactly the paths whose intervening idle
      run has length `1`; and the `certStabK` restatement obligation is therefore PROVISIONAL —
      blocked on a condition dischargeable on the pumpable side, not on one refuted outright.
- [x] Same file, the primitive's own docstring on `exists_deleted_ladderPath_of_next_region_nxt`:
      amend its closing paragraph, which currently ends "only this route through the pin layer is
      refuted". Keep that sentence — it is correct — and name the route that is not refuted, by
      declaration name and module, so a reader who reaches the refutation finds the alternative.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, the "WHY THE WITNESSING HYPOTHESIS
      IS CARRIED RATHER THAN DISCHARGED, COMPILED" paragraph: it asserts that the idle-run
      lengthening route "is REFUTED, not merely unproved". That is true of the UNRESTRICTED schema
      and of the freed-increment form (`idleGapLengtheningAllIncrements_refuted`) and FALSE of the
      sharpened, run-repeat-premised form, which landed as a theorem
      (`idleGapLengtheningOfIdleRunRepeat_holds`). Rewrite the paragraph to carry that split
      explicitly: the mechanism is a theorem, the PREMISE is what is refuted as universally
      available.
- [x] Same file, Requirement (W): add the disposition. `ForwardSlackWitnessed` is still a
      hypothesis on all five schemas (unchanged); the pin-layer route is still refuted
      (unchanged); a second, cascade-free conditional route now exists and is named; the frontier
      is the `I = 1` side; and the `certStabK` restatement obligation is PROVISIONAL rather than
      permanent, with the reason stated.
- [x] Same file: add `#print axioms` / `#guard_msgs` pins for
      `hasForwardSlack_of_idleRunRepeat` and `forwardSlackWitnessed_of_cell_idleRunPumpable`,
      matching the established shape in that file. If the measured profile differs from
      `[propext, Classical.choice, Quot.sound]`, pin what is MEASURED and say so in the narrative;
      never adjust the declaration to hit an expected profile.
      *(deviation: altered — both profiles MEASURED as `[propext, Classical.choice,
      Quot.sound]` and pinned as measured; the two pins landed in a NEW
      `/-! ## Requirement (W): the run-local discharge route, CONDITIONAL -/` section rather
      than appended to the pin-layer block, because that block's narrative asserts "FIVE of
      the TEN pins below" and appending would have falsified a stated count)*
- [x] `specs/state.json`: append an OUTCOME paragraph to task 924's `description`, in the shape
      the parent task used — the verdict sentence, the two landed declarations by name, the probe
      path, the named frontier, and the PROVISIONAL `certStabK` consequence. Append; do not
      replace the description or the `artifacts` array (`state-management.md`: artifacts are
      append-only, and wholesale `.artifacts = [...]` assignment is prohibited). Regenerate
      `specs/TODO.md` with `bash .claude/scripts/generate-todo.sh` afterwards rather than editing
      it by hand.
- [x] *(addition not in the plan: `set_option linter.style.longFile` in
      `KTypeSummaryAxiomTest.lean` raised 2900 -> 3000, the file having grown past the old bound —
      a mechanical consequence of the prose this phase adds, not a scope change)*
- [x] Regenerate `typst/generated/status.typ` with `bash scripts/typst-sync-check.sh --fix` and
      stage it in the SAME commit as the `.lean` changes — both `formalsystem-line-count` and
      `tests-line-count` move in this phase.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that exactly four durable places carry the parent's
recorded consequence and therefore need amendment — the `LadderChain.lean` module docstring, the
primitive's own docstring, `KTypeSummaryAxiomTest.lean`, and `specs/state.json` — on the strength
of a repo-wide grep for `ForwardSlackWitnessed` run at authoring time (which also surfaced
`specs/TODO.md`, generated from `state.json`, and `specs/ROADMAP.md`, out of scope per "Roadmap
Alignment"). Re-run that grep at implementation time; if a fifth durable carrier has appeared,
amend it too rather than treating the count as fixed.

**Tier Justification**: the edits are docstrings and prose in two modules with no signature
change, and a Lean docstring is elaborated rather than ignored, so the covering checks are
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`
and
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest`
(the latter also re-checks every `#guard_msgs` axiom pin in that file, which is the only way the
new pins are measured at all).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the module docstring's
  verdict paragraph and the primitive's own closing paragraph
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the corrected
  idle-lengthening paragraph, the Requirement (W) disposition, and two new axiom pins
- `specs/state.json` - the appended OUTCOME paragraph on task 924's description
- `specs/TODO.md` - regenerated from `state.json`
- `typst/generated/status.typ` - regenerated count fields (`--fix`), staged in the same commit

**Verification**:
- Both scoped guarded builds green, every `#guard_msgs` pin in `KTypeSummaryAxiomTest.lean`
  satisfied including the two new ones.
- The `LadderChain.lean` module docstring and the primitive's docstring both name
  `forwardSlackWitnessed_of_cell_idleRunPumpable` and both use the word PROVISIONAL for the
  `certStabK` obligation — confirmed by grep, not by recollection.
- No durable place anywhere in the tree still states, without qualification, that the idle-run
  lengthening route is refuted: `grep -rn "idle" Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`
  over the amended paragraph confirms the sharpened/unrestricted split is stated.
- `jq -e '.active_projects[] | select(.project_number==924) | .artifacts | length >= 1'
  specs/state.json` succeeds, and the artifacts array still contains the research report entry —
  the append did not replace it.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 4: Reconciliation, Full Gate Set, and the Summary [NOT STARTED]

**Goal**: Every generated surface matches the tree, the complete gate set is observed green (or
green modulo enumerated pre-existing findings outside this task's file scope), and the task's
verdict is written down in one place a future reader will find.

**Tasks**:
- [ ] Regenerate the module-inventory blocks with
      `bash scripts/check-module-invariants.sh --emit-inventory`. Every README carrying a
      `<!-- BEGIN GENERATED: inventory -->` block on the edited files' ancestor-directory chain is
      a target: `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` (which
      carries seven such blocks) and
      `FormalSystem/Metalogic/Decidability/RaySummary/README.md`. Do not hand-edit a generated
      block.
- [ ] Run the full gate set (below) and read each verdict. For any failure, determine whether it
      names a file this task touched. A gate whose only failures are pre-existing and outside this
      task's file scope is a recorded PASS for this phase, WITH the pre-existing findings
      enumerated in the summary and with evidence that each touched file passes individually. It
      is not grounds to edit an out-of-scope file.
- [ ] If C20's third assertion reports a NEW name-bearing citation finding caused by this task's
      line shifts in `LadderIdle.lean`, re-anchor the citation if it lives in a file this plan may
      touch, or record it as an enumerated out-of-scope finding (another task's `specs/**` report)
      and, where the recorded baseline is the right carrier, update
      `scripts/c20-declaration-baseline.txt`.
- [ ] Write
      `specs/924_forward_slack_witnessed_frontier_disposition/summaries/01_forward-slack-frontier-disposition-summary.md`
      carrying: the verdict sentence (neither of the description's two terminal outcomes was
      reachable as worded; outcome (b) is factually false and was not recorded); what landed; the
      named frontier; the PROVISIONAL `certStabK` consequence; every pre-existing gate finding
      enumerated; and every phase that closed `[BLOCKED]` on territory, if any.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the inventory regeneration touches exactly four READMEs —
`README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` and
`FormalSystem/Metalogic/Decidability/RaySummary/README.md` — established at authoring time by
grepping each candidate on LadderIdle's ancestor chain for `BEGIN GENERATED`
(`FormalSystem/Metalogic/Decidability/README.md` carries none and is correctly absent). Confirm by
running `--emit-inventory` and reading which files the script reports as changed; if it names a
fifth target, that target is in scope for this phase and must be staged with the others, and if it
names fewer, stage only what it changed rather than touching a file the generator left alone.

**Files to modify**:
- `README.md` - regenerated module-inventory block
- `FormalSystem/README.md` - regenerated module-inventory block
- `FormalSystem/Metalogic/README.md` - regenerated module-inventory blocks (seven in this file)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - regenerated module-inventory block
- `scripts/c20-declaration-baseline.txt` - only if a C20 re-anchor requires it
- `specs/924_forward_slack_witnessed_frontier_disposition/summaries/01_forward-slack-frontier-disposition-summary.md` - new file: the implementation summary

**Verification**:

The complete gate set for this repository, all five observed in this dispatch and none trusted on
sight:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` — the full project
  build, green and warning-free (CI uses `--wfail`).
- `bash scripts/check-module-invariants.sh` — green, or green modulo enumerated pre-existing
  findings outside this task's file scope. C14's axiom baseline is a HARD STOP if it diverges.
- `bash scripts/typst-sync-check.sh` — green (not only `--counts-only`).
- `bash scripts/check-evidence-probes.sh` — green, with the new probe counted and no pre-existing
  probe newly red.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` — reports no stale generated
  inventory block.

Additionally:
- An exact-name sweep confirms `cellLE_zero_const_of_kappa_eq` still has no declaration site
  anywhere under `FormalSystem/` — the reserved name stays claimed by nothing.
- An exact-name sweep confirms all three Goals identifiers are present under `FormalSystem/`, with
  the signatures pinned in `## Lean Challenge Statements` below.
- `.claude/scripts/verify-deploy.sh` is NOT run and is not part of this task's gate set: it gates
  the agent-system deploy tree, and this task touches no file under the source store. Recorded so
  its absence is a decision rather than an omission.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

set_option linter.unusedFintypeInType false

theorem hasForwardSlack_of_idleRunRepeat {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (z : ℤ) (I k d l : ℕ) (a : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hgap : nxtAt g z + 2 ≤ cntAt g z)
    (hI : 0 < I) (hk : 0 < k) (hd : 0 < d)
    (hrun : ∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false)
    (hstart : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true)
    (hRa : z + (cntAt g z : ℤ) + 1 ≤ a)
    (hak : a + (k : ℤ) ≤ z + (cntAt g z : ℤ) + 1 + (I : ℤ))
    (hrep : objAt g a = objAt g (a + (k : ℤ)))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ a
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (a + (k : ℤ)))
    (hpay : l ≤ d * k) :
    ∃ (g' : ℤ → LadderState Q pend)
      (σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
      IsLadderPath step pend g' ∧ (∀ t : ℤ, σ'.state t = (t, g' t)) ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧
      HasForwardSlack g' z l (nxtAt g z) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ' z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry

def IdleRunPumpable {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (g : ℤ → LadderState Q pend)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : ℤ) : Prop := sorry

theorem forwardSlackWitnessed_of_cell_idleRunPumpable {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (x : LadderState Q pend) (z : ℤ) (l : ℕ)
    (hprem : ∀ T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z,
      ∃ (g : ℤ → LadderState Q pend)
        (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        IsLadderPath step pend g ∧ g z = x ∧ (∀ t : ℤ, σ.state t = (t, g t)) ∧
        tpOf (ladderModel step pend fwd bwd lab) φ σ z = T ∧
        IdleRunPumpable step pend fwd bwd lab φ g σ z) :
    ForwardSlackWitnessed step pend fwd bwd lab φ x z l x.1.2.2 := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Decisions

1. **Both statements land in `LadderIdle.lean`, with an added `import … LadderCell`, rather than
   splitting the cell-level half into `LadderCell.lean`.** The research report leaves this open
   ("it must import `LadderCell` or be placed in a module downstream of both"); this plan takes the
   first option for three reasons. It confines every Lean change of Phase 1 to ONE file, which is
   held by neither concurrent sibling — splitting into `LadderCell.lean` would add a 128 KB magnet
   file to the change set for no proof-level gain. It keeps the idle layer self-contained: the
   route's whole content is the idle pump's, and `LadderCell.lean` contributes only the `cellAt`
   vocabulary the conclusion is phrased in. And the edge is confirmed acyclic at authoring time
   (`LadderCell` does not import `LadderIdle`; `LadderWindow` already imports both). The cost is
   real and is paid explicitly: `LadderIdle.lean`'s module docstring currently asserts it states
   no cell-level consequence, and Phase 1 must correct that paragraph rather than leave a false
   contract standing.

2. **All three identifiers — including the `def` — are pinned in `## Lean Challenge Statements`,
   departing from the parent task's precedent.** The parent plan deliberately excluded `def`s from
   its Challenge block, on the ground that a snapshot forces the body to `sorry` and the pinned
   statement is therefore empty. That reasoning is sound for a `def` nothing else mentions, and it
   does not apply here: `forwardSlackWitnessed_of_cell_idleRunPumpable`'s SIGNATURE names
   `IdleRunPumpable`, so the Challenge module cannot type-check standalone without it, and the
   format's hard requirement is that the Challenge identifier set EQUAL the Goals identifier set.
   What the `def`'s pin buys is its argument list and its `Prop` result, which is not nothing: a
   silently-weakened premise predicate is exactly the kind of same-name substitution the Statement
   Fidelity clause exists to catch.

3. **The `certStabK` restatement obligation stays PROVISIONAL.** This reverses the second half of
   the task description's outcome (b) and changes a decision the parent task recorded. It is
   settled, not re-opened: the research report raised it as a `user_decision`, and
   `.decisions.json` carries the answer from cycle 1 (AUTO, non-blocking, proceeded on the agent's
   recommendation and surfaced to the user for override). The substantive reason is that making it
   permanent would assert "no landed route can succeed", which
   `forwardSlackWitnessed_of_cell_idleRunPumpable` contradicts by compiling.

4. **Outcome (b) is NOT recorded, and the plan says so in the summary rather than smoothing it.**
   The task description is explicit that reaching neither terminal outcome is a third,
   non-terminal result to be reported as such. Phase 4's summary carries that verdict sentence.
   What this task DOES deliver is strictly more than the description's (a) asked for on the
   pumpable side and strictly less than its (b) on the open side, and both halves are stated.

5. **The open side is not attempted in this task.** Research Recommendation 4 is followed
   verbatim. The honest next step is a separate task with one question — whether the object-layer
   shortenability the report's Finding 6 identifies can be lifted at all without the `(K1)`
   amendment — and a pin-set-reducing deletion primitive would need its own consumers to justify
   landing, since its anchor is unpayable at this frontier
   (`whole_region_anchor_refuted`, Phase 2's probe).

6. **The 918 territory collision is declared, not engineered around.** Three alternatives were
   considered and rejected. Narrowing the plan to the free files would drop the probe wiring and
   the Requirement (W) correction, which are two of the three things the task exists to produce.
   Adding a `dependencies[]` edge from inside the implementation dispatch would block 924's own
   admission, including the phases that have no collision. Deferring the generated-surface
   regeneration to Phase 4 is impossible: `.githooks/pre-commit` makes that check blocking on the
   commit of the phase that causes the drift. Declaring every shared path lets
   `orchestrate-batch-admit.sh` serialize the pair, which is the designed route.

7. **Phase 1 appends at the end of `LadderIdle.lean` rather than inserting mid-file.** Append-only
   placement shifts no existing declaration's line number, which keeps C20's name-bearing-citation
   assertion quiet for everything below the insertion point. The module-docstring correction at the
   top does shift the whole file, which is why the risk is carried explicitly and Phase 4 budgets
   for a possible re-anchor rather than assuming none is needed.

## Testing & Validation

- [ ] Every new declaration elaborates with no `sorry`, no `native_decide`, and no axiom beyond
      the standard `[propext, Classical.choice, Quot.sound]` profile (`lean_verify` per
      fully-qualified name).
- [ ] Every new declaration is warning-free: no `linter.autoImplicit`, no `linter.style.show`, no
      unused variable. CI builds with `--wfail`, so a warning is a failure.
- [ ] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` builds with every `#guard_msgs`
      axiom pin satisfied, including the two new ones.
- [ ] Each of the three new docstrings carries all three scoping clauses (premise not
      `ParamsOk`-derivable; hypothesis NOT removed from the five schemas; reserved name and window
      regime and room bounds unchanged).
- [ ] An exact-name sweep confirms `cellLE_zero_const_of_kappa_eq` has no declaration site anywhere
      under `FormalSystem/`.
- [ ] An exact-name sweep confirms each of the three Goals identifiers IS present under
      `FormalSystem/` with the signature pinned above.
- [ ] `bash scripts/check-evidence-probes.sh` is green, the new probe is counted, and no
      pre-existing probe is newly red.
- [ ] `bash scripts/check-module-invariants.sh` and `bash scripts/typst-sync-check.sh` are green,
      or green modulo enumerated pre-existing findings outside this task's file scope.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` reports no stale
      generated inventory block.
- [ ] `wc -l` on every `.lean` file this task touched sits below its `longFile` limit, or a
      baseline is raised in the same change inside the linter's `N - 200 ≤ lines < N` window.
- [ ] No claim anywhere in the landed text asserts that `ForwardSlackWitnessed` is discharged
      unconditionally, or that the frontier is closed.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` — the added `LadderCell`
  import, `IdleRunPumpable`, `hasForwardSlack_of_idleRunRepeat`,
  `forwardSlackWitnessed_of_cell_idleRunPumpable`, their scoping docstrings, the corrected
  `## Contract` paragraph, and three `#print axioms` lines.
- `specs/evidence/forward-slack-pin-cascade/route-space-closure.lean` — the route-space closure as
  a wired probe, plus its `WIRED` entry and comment-table row in
  `scripts/check-evidence-probes.sh`.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — the amended verdict paragraph
  and the amended primitive docstring.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — the corrected idle-lengthening
  paragraph, the Requirement (W) disposition, and two new axiom pins.
- `specs/state.json` (and the regenerated `specs/TODO.md`) — the OUTCOME paragraph.
- Regenerated generated surfaces: `typst/generated/status.typ`, and the module-inventory blocks in
  `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` and
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`.
- `specs/924_forward_slack_witnessed_frontier_disposition/summaries/01_forward-slack-frontier-disposition-summary.md`
  carrying the verdict sentence.

## Rollback/Contingency

Each phase commits once, green, with its generated-surface regeneration staged alongside its Lean
change, so reverting is a per-phase `git revert` of a single commit — no cross-phase unwinding is
needed. Phases 1 and 2 are independent of each other and of Phase 3; either can be kept if the
other is reverted.

If a phase must be abandoned mid-edit with uncommitted work in the tree, take a durable,
NON-reverting checkpoint first (`bash .claude/scripts/git-snapshot.sh 924 --no-revert`) and then
decide. Only a genuine rollback uses the default reverting mode, per `context/contracts/recovery.md`'s
rollback rung — and under concurrency that reverting mode is forbidden outright by this dispatch's
own concurrency note item (3), because it would discard a sibling's in-flight work as well as this
task's.

Two contingencies are planned rather than improvised:

- **Territory.** If 918 holds a file a phase must edit when that phase comes up, the phase closes
  `[BLOCKED]` with the observed state recorded and every non-colliding phase completes in full.
  Phase 1's only shared file is `typst/generated/status.typ`; Phases 2, 3 and 4 each hold a
  further shared file. A partial landing is an honest result and is reported as one, not smoothed
  into a completion.
- **Gate baseline.** If `check-module-invariants.sh` is already red for reasons outside this task's
  file scope — C16's `env_linter` batch is the live candidate, since a sibling is currently
  clearing lint debt in `LadderPump.lean` — that is a recorded PASS for the phase with the
  pre-existing findings enumerated, not a blocker and not grounds to edit an out-of-scope file to
  force the count to zero.
