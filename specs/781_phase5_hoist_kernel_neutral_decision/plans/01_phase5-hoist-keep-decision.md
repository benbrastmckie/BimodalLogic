# Implementation Plan: Task #781

- **Task**: 781 - Decide whether the Phase 5 inner-fixpoint hoist in LiveFix.lean should stay
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: None (no research artifact for this round; see Overview)
- **Artifacts**: plans/01_phase5-hoist-keep-decision.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The hoist landed in `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean`
replaced a per-vertex evaluation of the inner fixpoint with a per-closure-member table
(`untlLiveOf`/`snceLiveOf`, `untlTable`/`snceTable`, `untlLiveAtTab`/`snceLiveAtTab`, plus the two
unconditional equalities `untlLiveAtTab_eq`/`snceLiveAtTab_eq`). A zero-rebuild A/B measured it
NEUTRAL under the kernel at the hard certificate (25.9 s OLD vs 24.4 s NEW, 1.06x — inside
variance), 5.4x better at the same certificate under `#eval`, and ~25 % worse at the small
embedded witness under `#eval`. Correctness is not at issue. This plan closes the one gap in that
evidence — the small embedded witness was never A/B'd **under the kernel** — applies a
pre-committed decision rule to the completed evidence, and then makes the module's recorded
justification match what was measured.

**Definition of done**: a durable, evidence-backed verdict on keep-vs-revert exists next to the
code; the module docstring no longer asserts a kernel win the measurement refutes; the three
generated surfaces coupled to the module's line count are reconciled; the full gate set is green
or its findings are shown to be pre-existing.

### Research Integration

No research artifact was produced for this round, and none was needed. The task description
carries the defect, the measured evidence, and the acceptance question; the remaining facts
(which declarations the hoist introduced, who references them, which generated surfaces couple to
the file's line count) were established at planning time by direct `Read`/`Grep` over the tree.
Those findings are recorded inline in this plan rather than in a separate report.

Established at planning time, and load-bearing for the phases below:

- The Tab family (`untlLiveOf`, `snceLiveOf`, `untlTable`, `snceTable`, `untlLiveAtTab`,
  `snceLiveAtTab`, `untlLiveAtTab_eq`, `snceLiveAtTab_eq`) has **zero references outside
  `LiveFix.lean`**. The pre-hoist vocabulary `untlLiveAt`/`snceLiveAt` is what downstream code
  reads, via `Bridge.lean:405`, `Bridge.lean:474` and `FixtureStable.lean:189`, and it is
  reached through the unchanged characterizations `mem_fwdLiveStep`/`mem_bwdLiveStep`. The hoist
  is therefore fully encapsulated: both branches of the decision are invisible to every consumer.
- `LiveFix.lean` has exactly two direct importers:
  `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` and
  `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Bridge.lean`.
- The kernel obligations the hoist was built for are
  `TotalEdge.certA_certifies : certA.Certifies := by decide` (the hard certificate) and
  `example : ((liveFamily.sliced (-1)).liveAt (-1)).card = 1 := by decide` (the small embedded
  witness), both in `Examples.lean`. Both are inventoried in
  `scripts/certificate-witness-inventory.txt`.
- Any change to the file's line count — **including a pure docstring edit** — moves three
  generated surfaces: `typst/generated/status.typ`'s `formalsystem-line-count` (commit-BLOCKING
  via `.githooks/pre-commit`), the `dir=FormalSystem rows=totals` block in `README.md`, and the
  `dir=FormalSystem/Metalogic rows=subdirs` block's `Decidability/` row in
  `FormalSystem/Metalogic/README.md`. No other generated inventory block covers
  `PlusSlicedCertificate/`.
- `LiveFix.lean` is 621 lines, far below the 1500-line `longFile` ceiling, so no baseline bump is
  in scope.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied for this dispatch; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- Produce the missing datapoint: a zero-rebuild **kernel** A/B of the hoist at the small embedded
  witness, plus a reconfirmation of the certA kernel A/B on the current tree.
- Apply the decision rule stated under `## Decisions` to the completed evidence and record the
  verdict durably under `specs/evidence/`.
- Make `LiveFix.lean`'s recorded justification match what was measured, so no future reader
  inherits a counting argument the kernel refutes.
- Reconcile the three generated surfaces coupled to the module's line count, with the
  commit-blocking one reconciled in the same phase that moves the count.

**Non-Goals**:

- Changing any theorem statement, any externally visible signature, or any downstream consumer.
  Both branches of the decision are encapsulated inside `LiveFix.lean`.
- Wiring the new A/B harness into `scripts/check-evidence-probes.sh`. A wall-clock timing
  comparison is not a compile-check invariant, and wiring it would make the gate permanently
  carry a mirrored copy of a decommissioned clause shape. See `## Decisions`.
- Optimizing either clause shape further. This record decides between two shapes that already
  exist; it does not propose a third.
- Redeploying the stale `.claude/` tree. The dispatch reports `core` stale; that is another
  record's work and is handled as a risk here, not as a phase.
- Editing `Examples.lean`, `Live.lean`, `Check.lean` or `Stable.lean` — all four are in a
  concurrent sibling's declared file scope (see `## Risks & Mitigations`).

## Decisions

**D1 — The decision rule, pre-committed before the measurement runs.** Let `r = median(NEW) /
median(OLD)` over 3 runs each, measured under the kernel at a given site.

- **KEEP** the hoist if `r <= 1.15` at BOTH certA and the small embedded witness — that is, the
  table shape is nowhere materially slower than the per-vertex shape on the path the build
  actually pays.
- **REVERT** the hoist if `r > 1.15` at either site.

The 1.15 band is set deliberately above the 1.06x the existing certA A/B already called "inside
variance", so the rule cannot be tripped by the noise that measurement characterized.

**D2 — The expected branch is KEEP, and the reasoning is recorded here so the implementer is not
re-deriving it mid-phase.** (a) Correctness is untouched on either branch — the equalities are
unconditional and the consumers read the pre-hoist vocabulary. (b) Kernel-neutral means reverting
has no measured kernel upside, so a revert is churn on a module sitting on the critical path of a
~25 s kernel `decide`, against a non-zero risk of moving that 25 s the wrong way. (c) The 5.4x
`#eval` improvement at the hard certificate is a real, measured developer-facing win on the path
used for interactive fixture work. (d) The ~25 % `#eval` regression is at the small embedded
witness, whose absolute cost `Examples.lean`'s own docstring records as ~0.2 s — immaterial in
absolute terms. What does **not** survive is the docstring's counting argument, which predicts a
kernel win the measurement refutes, because the kernel's whnf cache had already removed the
duplication that argument assumed. Correcting that claim is the real deliverable of the KEEP
branch; keeping the code is the cheap part.

**D3 — Why this plan declares zero Lean goals.** Neither branch introduces a new theorem. The
KEEP branch is a prose correction plus generated-surface reconciliation. The REVERT branch deletes
eight declarations and restores two existing ones (`fwdLiveStep`/`bwdLiveStep`) and their existing
characterizations (`mem_fwdLiveStep`/`mem_bwdLiveStep`) to a pre-hoist body under their unchanged
signatures — no new identifier is committed to. The `## Lean Challenge Statements` section
therefore carries the zero-goal marker.

**D4 — The harness is recorded, not wired.** The A/B files land under
`specs/evidence/phase5-hoist-kernel-ab/` so the measurement is reproducible by a future reader,
but are deliberately left out of `scripts/check-evidence-probes.sh`'s `WIRED` list. The script
does not scan the directory for unlisted files, so an unwired probe there is inert. Wiring it
would oblige the gate to keep compiling a mirrored OLD clause shape forever, which is exactly the
maintenance cost the decision is about.

**D5 — If the measurement cannot be obtained.** If the OLD-shape mirror cannot be written without
a rebuild (making the A/B no longer zero-rebuild and therefore no longer confound-free), Phase 1
is recorded `[PARTIAL]`, the gap is stated plainly in the evidence README, and the decision falls
back to the existing certA kernel A/B alone: KEEP, because there is no evidence of kernel harm and
reverting without evidence of harm is unjustified churn. The plan still completes; it completes
with a narrower evidence base, stated as such.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A concurrent `lake build` rewrites `.lake` during the A/B, producing either a missing-object-file error or silently corrupted timings | H | M | Hold an `flock` on `$REPO_ROOT/.lake/build-guard.lock` for the whole measurement, following `scripts/check-evidence-probes.sh`'s SHARED `.lake` LOCK block (bounded `flock -w`, announced on stderr, fd held to exit). Treat any `object file '...' does not exist` as an environment failure, never as a result |
| The measurement contradicts D2 and the REVERT branch is taken, making Phase 3 materially larger than its KEEP branch | M | L | Phase 3's REVERT branch is scoped and timed separately below; if it cannot be completed as written, `plan-compliance.md` governs — mark the phase `[BLOCKED]` and escalate rather than substituting a different edit to a `.lean` file |
| The commit of the line-count-changing phase is refused by `.githooks/pre-commit` because `typst/generated/status.typ` is stale | M | H if unscheduled | `scripts/typst-sync-check.sh --fix` is scheduled inside Phase 3 itself and `typst/generated/status.typ` is carried in that phase's own file scope, never deferred |
| `verify-deploy.sh` reports findings unrelated to this record (the dispatch reports the deployed `.claude/` tree STALE for `core`) | M | H | Per the gate-collision checklist's Condition 2 corollary, Phase 4's criterion is phrased as a delta: findings naming this task's own touched files block; standing-baseline findings are enumerated and recorded as pre-existing. Redeploying is out of scope for this record |
| A repo-wide inventory regeneration rewrites a README that a concurrent sibling is working in | M | L | `--emit-inventory` rewrites only blocks whose content changed; the only blocks a `LiveFix.lean` line delta moves are the two enumerated above, neither of which is in any sibling's declared scope. Re-read both files immediately before staging, and stage only those two paths |
| The OLD-shape mirror drifts from the library's real pre-hoist shape, so the A/B measures the wrong thing | H | L | Derive the mirror from the surviving `untlLiveAt`/`snceLiveAt` definitions, which are still live in the module and are exactly the pre-hoist clause; state in the harness header which library declarations it mirrors and at which commit |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel; this plan's phases form a strict chain.

### Phase 1: Close the Kernel Measurement Gap [COMPLETED]

**Goal**: Produce the datapoint the existing evidence lacks — a zero-rebuild kernel A/B of the
two clause shapes at the small embedded witness — and reconfirm the certA kernel A/B on the
current tree, so the decision rule is applied to complete evidence rather than to one site.

**Tasks**:

- [x] Confirm the import closure is built, so the A/B is genuinely zero-rebuild. Run
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.PlusSlicedCertificate`.
      Prefer the plain foreground `timeout 1800 <guard call>` form with the Bash tool `timeout`
      parameter raised to `600000`; if it does not fit one call, detach it as a shell-level
      background job and block on it with the bounded single-call idiom from
      `context/patterns/bounded-build-waiter.md`. Never `Bash(run_in_background: true)`.
- [x] Create `specs/evidence/phase5-hoist-kernel-ab/ab-new.lean`: a standalone file importing
      `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate` that re-states, under the
      library's own current (table) clause shape, both kernel obligations — the certA backward
      fixpoint and the small embedded witness's `liveAt` cardinality — each closed `by decide`.
- [x] Create `specs/evidence/phase5-hoist-kernel-ab/ab-old.lean`: the same two obligations
      against a locally defined OLD-shape mirror. Build the mirror from the library's surviving
      `untlLiveAt`/`snceLiveAt` (the pre-hoist clause, still live in `LiveFix.lean`): define
      `fwdLiveStep`/`bwdLiveStep` analogues filtering with `G.untlLiveAt X v ψ = true` /
      `G.snceLiveAt X v ψ = true` directly, take `Nu.gfp'` over each, intersect for the `liveT`
      analogue, and restate both obligations against it. Record in the file header exactly which
      library declarations are mirrored and at which commit.
- [x] Acquire the shared build lock for the whole measurement, following
      `scripts/check-evidence-probes.sh`'s SHARED `.lake` LOCK block: open
      `$REPO_ROOT/.lake/build-guard.lock`, try `flock -n`, fall back to an announced bounded
      `flock -w 600`, hold the fd to exit. A timing run taken without the lock is not a result.
- [x] *(deviation: altered — three passes per arm were taken as written, then a 10-pass-per-arm batch was added under the same lock and build because the 3-pass medians proved to be inside the ~20 % within-arm spread; both batches are recorded in the README)* Time three runs of each file: `lake env lean specs/evidence/phase5-hoist-kernel-ab/ab-old.lean`
      and `... /ab-new.lean`. Record every individual run, not only the medians. If any run
      reports `object file '...' does not exist`, discard the whole batch as an environment
      failure and re-run once the competing build has finished — never record it as a result.
- [x] Write `specs/evidence/phase5-hoist-kernel-ab/README.md` holding the raw per-run numbers,
      the medians, the two ratios `r_certA` and `r_witness`, the toolchain and commit the
      measurement was taken at, and an explicit statement that both shapes ran against one
      unchanged build.
- [x] Record an issue-log entry for this phase (`issue-record.sh`, `--phase plan` superseded by
      `--phase implement`), including an explicit `kind: win` or `kind: issue` as warranted; if
      genuinely nothing arose, attest that in the handoff prose rather than recording nothing.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts it creates exactly three new files, all under
`specs/evidence/phase5-hoist-kernel-ab/`, and modifies nothing existing. Confirm at
implementation time with `git status --short` before staging: any path outside that directory
appearing in the diff falsifies the hypothesis and must be reported, not silently committed.

**Tier Justification**: `suite_selection_select` returns the sentinel `__FULL_SWEEP__` for all
three paths (they lie entirely under `specs/**`, sub-case (a)), so no shell suite covers them;
the covering check is that each new probe compiles standalone — `lake env lean
specs/evidence/phase5-hoist-kernel-ab/ab-old.lean` and `... /ab-new.lean` both exit 0 — which is
this phase's own measurement run.

**Files to modify**:
- `specs/evidence/phase5-hoist-kernel-ab/ab-new.lean` - new: both kernel obligations under the library's current table clause shape
- `specs/evidence/phase5-hoist-kernel-ab/ab-old.lean` - new: the same two obligations against a locally mirrored per-vertex clause shape
- `specs/evidence/phase5-hoist-kernel-ab/README.md` - new: raw per-run timings, medians, the two ratios, and the measurement conditions

**Verification**:
- Both `.lean` files compile standalone under `lake env lean`, exit 0, with no `sorry` and no
  `object file` error in either output.
- Six timing runs are recorded individually in the README (3 OLD, 3 NEW, at each of the two
  sites), together with the commit and toolchain, and a statement that no rebuild occurred
  between the OLD and NEW runs.
- The README states both ratios `r_certA` and `r_witness` numerically.

---

### Phase 2: Apply the Decision Rule and Record the Verdict [COMPLETED]

**Goal**: Turn the completed evidence into a stated verdict under `## Decisions`' rule D1, so the
library edit in Phase 3 executes a decision already made rather than making one mid-edit.

**Tasks**:

- [x] Compare `r_certA` and `r_witness` from Phase 1 against D1's 1.15 band and state the branch
      — KEEP or REVERT — explicitly.
- [x] Append a "Verdict" section to `specs/evidence/phase5-hoist-kernel-ab/README.md` carrying:
      the branch taken, the two ratios it was derived from, the rule it was applied under, and
      the `#eval` figures from the original A/B as context the kernel numbers do not replace.
- [x] *(D5's fallback was not taken; both sites were measured — stated as such in the Verdict section)* If D5's fallback was taken in Phase 1 (the measurement could not be obtained), state that
      plainly in the same section: which site is unmeasured, why, and that the verdict rests on
      the certA kernel A/B alone.
- [x] State in the same section what the verdict does **not** claim — in particular that it is a
      judgment about the hoist's recorded justification and maintenance cost, not about
      correctness, which the unconditional equalities settle independently.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Tier Justification**: the covering check is the `prose` row's diff read-through confirming every
changed hunk lies inside markdown prose in one `specs/**` file; the suite list
`suite_selection_select` returns for this path is a basename artifact of the file being named
`README.md`, and consists entirely of agent-system shell suites with no bearing on a
`specs/evidence/` markdown file.

**Files to modify**:
- `specs/evidence/phase5-hoist-kernel-ab/README.md` - append the Verdict section: branch, ratios, rule applied, and what the verdict does not claim

**Verification**:
- The README names exactly one branch, KEEP or REVERT, and the numbers it was derived from.
- The stated branch follows mechanically from D1 applied to the recorded ratios — re-check the
  arithmetic rather than asserting it.
- The diff touches only markdown prose in one file.

---

### Phase 3: Apply the Decision to LiveFix.lean and Reconcile the Blocking Surface [NOT STARTED]

**Goal**: Make the module match the verdict, and reconcile in this same phase the one generated
surface whose drift would otherwise refuse this phase's own commit.

**Tasks**:

- [ ] Re-read `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean`
      immediately before editing — a concurrent sibling is active on this same tree.
- [ ] **KEEP branch**: rewrite the `## The hoisted inner fixpoint` module-docstring section
      (currently at lines 167-186) so its justification is the measured one. It must state: the
      table computes the inner fixpoint once per closure member rather than once per vertex; the
      two `_eq` lemmas make the change unobservable to every consumer, which is why
      `mem_fwdLiveStep`/`mem_bwdLiveStep` are still stated in the `untlLiveAt`/`snceLiveAt`
      vocabulary; under the kernel the shape is neutral, because the whnf cache already removes
      most of the per-vertex duplication; the measured win is on the `#eval` path at the hard
      certificate, with a small absolute regression at the cheap embedded witness where the
      table's eager `|closure|` cost dominates. Delete the counting argument's claim of a kernel
      net win. Retain the `Finset.image`-not-`toList` note and the per-formula short-circuit
      note — both are still true and still load-bearing.
- [ ] **REVERT branch** (only if Phase 2 recorded REVERT): delete `untlLiveOf`, `snceLiveOf`,
      `untlTable`, `snceTable`, `untlLiveAtTab`, `snceLiveAtTab`, `untlLiveAtTab_eq` and
      `snceLiveAtTab_eq`; restore `fwdLiveStep`/`bwdLiveStep` to filter with
      `G.untlLiveAt X v ψ = true` / `G.snceLiveAt X v ψ = true` directly; and re-prove
      `mem_fwdLiveStep`/`mem_bwdLiveStep` under their unchanged signatures. Replace the
      `## The hoisted inner fixpoint` section with a short note recording that the table shape
      was measured and removed, and what the measurement showed. Do not alter any signature.
- [ ] Confirm the prose carries no task-number reference and no record-versioning language —
      `.claude/rules/no-task-references-in-deliverables.md` and
      `.claude/rules/no-record-versioning-in-deliverables.md` both apply to `FormalSystem/**`.
      State the current design and the measured fact; never "previously", "no longer", or a
      citation of this record's own number. Cite the declaration names and the measurement
      itself as the durable anchors.
- [ ] Regenerate the commit-blocking line-count surface in this same phase:
      `bash scripts/typst-sync-check.sh --fix`, then confirm with
      `bash scripts/typst-sync-check.sh --counts-only`.
- [ ] Build the changed module and its two direct dependents:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.LiveFix`,
      then `... -- build FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Bridge`, then
      `... -- build FormalSystem.Metalogic.Decidability.PlusSlicedCertificate`. Same foreground/
      detached preference and bounded-wait idiom as Phase 1.
- [ ] Stage exactly `LiveFix.lean` and `typst/generated/status.typ` by explicit file list — never
      `git add -A`, never a directory or glob pathspec — and review `git status --short` plus
      `git diff --staged` before committing.

**Timing**: KEEP branch 1 hour; REVERT branch 2 hours.

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the Tab family has zero references outside
`LiveFix.lean`, and therefore that the REVERT branch changes no externally visible signature and
breaks no consumer. Confirm before deleting anything:
`grep -rn 'untlLiveAtTab\|snceLiveAtTab\|untlTable\|snceTable\|untlLiveOf\|snceLiveOf' --include=*.lean FormalSystem Tests`
must return hits only inside `LiveFix.lean`. Any hit elsewhere falsifies the hypothesis and the
phase must stop and report rather than proceed.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for both paths, so no
shell suite covers them; the covering check is the guarded scoped build of the changed module
plus its complete, enumerated direct-dependent set — `lake-build-guard.sh build ... -- build` on
`...PlusSlicedCertificate.LiveFix`, `...PlusSlicedCertificate.Bridge` and
`...Decidability.PlusSlicedCertificate`, which are the only two importers of `LiveFix.lean` —
together with `scripts/typst-sync-check.sh --counts-only` for the regenerated surface.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` - KEEP: rewrite the `## The hoisted inner fixpoint` justification to the measured record; REVERT: delete the eight table declarations and restore the per-vertex step and its characterizations
- `typst/generated/status.typ` - regenerate `formalsystem-line-count` via `scripts/typst-sync-check.sh --fix`; coupled to this phase's line-count change and commit-blocking, so it cannot be deferred

**Verification**:
- All three guarded builds exit 0 with no `sorry` and no warning (CI builds `--wfail`, so a
  warning is a failure).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- The module's `## The hoisted inner fixpoint` section no longer asserts a kernel net win, and
  the prose contains no task-number reference and no "previously"/"no longer"/"supersedes"
  construction.
- On the REVERT branch only: the scope-hypothesis grep returns no hit outside `LiveFix.lean`, and
  `mem_fwdLiveStep`/`mem_bwdLiveStep` retain their exact prior signatures.
- `git diff --staged` shows exactly the two declared paths.

---

### Phase 4: Reconcile the Deferred Inventory Surfaces and Discharge the Full Gate Set [NOT STARTED]

**Goal**: Bring the two non-blocking generated inventory surfaces back in line with the module's
new line count, and discharge the complete gate set over the whole of this record's work.

**Tasks**:

- [ ] Re-read `README.md` and `FormalSystem/Metalogic/README.md` immediately before editing — a
      concurrent sibling is active on this same tree.
- [ ] Regenerate the inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`,
      then verify with `bash scripts/check-module-invariants.sh --emit-inventory --check`.
- [ ] Confirm the regeneration moved only the two expected blocks — `README.md`'s
      `dir=FormalSystem rows=totals` block and `FormalSystem/Metalogic/README.md`'s
      `dir=FormalSystem/Metalogic rows=subdirs` `Decidability/` row. If any other file appears
      in `git status --short`, stop and report it: it is either a sibling's in-flight edit or a
      surface this plan did not anticipate, and neither is this phase's to absorb silently.
- [ ] Run the full project build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached as a
      shell-level background job and blocked on with the bounded single-call idiom.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. Per the gate-collision
      checklist's Condition 2 corollary, separate findings that name this record's own touched
      files from the tree's standing baseline, and enumerate the latter explicitly in the phase
      record. A gate whose only failures are pre-existing and outside this task's file scope is a
      recorded PASS, not a blocker — and is never grounds to edit an out-of-scope file.
- [ ] Note, without acting on it, that the dispatch reported the deployed `.claude/` tree STALE
      for the `core` extension; any gate finding traceable to that staleness is pre-existing and
      belongs to the redeploy record, not to this one.
- [ ] Stage exactly `README.md` and `FormalSystem/Metalogic/README.md` by explicit file list and
      review `git status --short` plus `git diff --staged` before committing.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the inventory regeneration moves exactly the two declared
files. `FormalSystem/README.md` will additionally appear in this plan's harvested `file_scope` —
`scripts/plan-file-scope-harvest.sh` appends every ancestor-chain README carrying a
generated-inventory block, regardless of whether that block's rows cover the changed file — but
its block is `dir=FormalSystem rows=loose`, which lists only files sitting directly in
`FormalSystem/`, so a `LiveFix.lean` line delta does not move it and it is expected NOT to appear
in the diff. The confirmation step above is the check; any file beyond the two declared ones
appearing in the diff falsifies the hypothesis and is reported rather than committed.

**Files to modify**:
- `README.md` - regenerate the `dir=FormalSystem rows=totals` inventory block (live line and comment counts)
- `FormalSystem/Metalogic/README.md` - regenerate the `dir=FormalSystem/Metalogic rows=subdirs` block's `Decidability/` files/lines row

**Verification**:
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `bash scripts/typst-sync-check.sh --counts-only` still exits 0 after the inventory regeneration.
- The full guarded `lake build` exits 0 with no warning.
- `bash .claude/scripts/verify-deploy.sh` is green, or every finding is shown by name to be
  pre-existing and outside this record's file scope, with the enumeration recorded.
- `git diff --staged` shows exactly the two declared paths.

## Lean Challenge Statements

<!-- lean-challenge-statements:none -->

This plan commits to no new theorem. The rationale is recorded under `## Decisions` as D3: the
KEEP branch is a prose correction plus generated-surface reconciliation, and the REVERT branch
deletes declarations and restores two existing ones under their unchanged signatures, committing
to no new identifier.

## Testing & Validation

- [ ] Both A/B probes compile standalone under `lake env lean` and exit 0, with the shared
      `.lake` lock held for the whole measurement.
- [ ] Six individual timing runs recorded (3 OLD, 3 NEW) at each of the two kernel sites, with no
      rebuild between the OLD and NEW runs at either site.
- [ ] The verdict follows mechanically from D1 applied to the recorded medians.
- [ ] `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.LiveFix`, `...Bridge` and
      `...Decidability.PlusSlicedCertificate` all build clean, warning-free.
- [ ] Full guarded `lake build` exits 0, warning-free.
- [ ] `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` green, or every finding enumerated as pre-existing
      and outside this record's file scope.
- [ ] No task-number reference and no record-versioning construction in any file outside
      `specs/**`.

## Artifacts & Outputs

- `specs/evidence/phase5-hoist-kernel-ab/ab-old.lean` - the per-vertex-shape A/B harness
- `specs/evidence/phase5-hoist-kernel-ab/ab-new.lean` - the table-shape A/B harness
- `specs/evidence/phase5-hoist-kernel-ab/README.md` - raw timings, medians, ratios, conditions, and the verdict
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` - the decision applied: a corrected justification (KEEP) or the table family removed (REVERT)
- `typst/generated/status.typ` - regenerated `formalsystem-line-count`
- `README.md` - regenerated `dir=FormalSystem rows=totals` inventory block
- `FormalSystem/Metalogic/README.md` - regenerated `dir=FormalSystem/Metalogic rows=subdirs` inventory block

## Rollback/Contingency

Each phase commits separately and in dependency order, so rollback is per-phase and ordinary:
revert the phase's own commit. Phases 1 and 2 add only new files under `specs/evidence/` and have
no library effect to undo. Phase 3's library edit is encapsulated — nothing outside `LiveFix.lean`
reads the declarations either branch touches — so reverting its commit restores the module and its
two dependents without touching any consumer. Phase 4's inventory regeneration is idempotent:
re-running `scripts/check-module-invariants.sh --emit-inventory` after a revert restores whichever
state the tree is then in.

If an in-flight rollback of uncommitted work is genuinely required, take a snapshot first — see
`context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation shape,
including its out-of-scope override flag. Do not emit a bare precautionary `git-snapshot.sh 781`;
for an ordinary defensive checkpoint before the Phase 3 library edit, use the non-reverting
`--no-revert` form instead.

A concurrent sibling is active on this working tree. Before any revert, run `git log` to confirm
the commit being reverted is this record's own, and never discard uncommitted changes that may
belong to another writer.
