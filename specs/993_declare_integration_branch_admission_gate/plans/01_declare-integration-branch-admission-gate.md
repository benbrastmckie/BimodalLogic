# Implementation Plan: Task #993

- **Task**: 993 - Declare integration_branch in .claude-extensions.json so that orchestration admission arms instead of falling back
- **Status**: [COMPLETED]
- **Effort**: 1.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/993_declare_integration_branch_admission_gate/reports/01_declare-integration-branch-admission-gate.md
- **Artifacts**: plans/01_declare-integration-branch-admission-gate.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add two hand-authored top-level sibling keys to the project-root `.claude-extensions.json` —
`integration_branch: "dev/m7-ladder-continuation"` and `worktree_isolation: "off"` — so that
`scripts/lib/batch-admission-lib.sh` stops emitting its disarmed-gate advisory and begins actually
testing the branch and the tree at every `/orchestrate` admission. The declaration is proven to
have armed the gate by a two-arm live falsification against this repository (a deliberately wrong
declared branch must produce a real `off_integration_branch` refusal; the correct declaration must
then produce an `admit`), never by the advisory merely ceasing to print. A short, tracked note then
records the maintenance obligations the declaration creates, because the manifest itself is
gitignored here and cannot carry them. Done when both keys are declared, both admission arms are
observed firing against the live repository, and the obligations are recorded in a tracked file.

### Research Integration

The research report settles the two questions this plan would otherwise have had to guess at, and
both findings were re-derived at plan-authoring time rather than carried:

- **Consumer semantics**: `batch_admission_evaluate` tests pure branch-identity equality —
  `git symbolic-ref -q --short HEAD` against the declared string, with no ancestry, descendant, or
  merge-target relation anywhere in the predicate. Re-read directly at
  `.claude/scripts/lib/batch-admission-lib.sh:255-340` and confirmed. The declared value is
  therefore **the branch the primary tree is required to sit on**, not an eventual merge target.
  This is what makes `main` the wrong value and the active working branch the right one.
- **Refuse vs. warn is not an open choice**: the implementation offers exactly two states —
  undeclared (one advisory, neither arm armed) or declared (hard refuse on mismatch, every cycle).
  There is no soft mode to select, so deliverable 4's "recorded decision" is a decision to accept
  hard refuse, with grounds, not a selection between implemented alternatives.
- **`worktree_isolation`**: `"off"` and absent are behaviourally identical; `"batch"` is
  declared-but-unimplemented and refuses every invocation with `isolation_unimplemented`. Declaring
  `"off"` explicitly costs nothing and records that the key was evaluated.

### Premise Re-Validation (Carried-Figure Discipline)

Every trigger-shaped claim in the dispatch description was checked against live state at
plan-authoring time. Four confirm unchanged; one material fact is **new and absent from the
research report**, and it changes where deliverable 3's obligations are recorded.

| Claim from the description | Live check | Result |
|---|---|---|
| The manifest carries exactly two keys, `extensions` and `version` | `jq -r 'keys\|join(", ")' .claude-extensions.json` | CONFIRMED: `extensions, version` |
| The advisory string is emitted on every run | `grep -n` in `batch-admission-lib.sh` | CONFIRMED at `batch-admission-lib.sh:297`, first cycle only |
| `repo-level-declarations.md` has a "Why `.claude-extensions.json` Survives a Hand-Authored Sibling Key" section | `grep -n` | CONFIRMED at `repo-level-declarations.md:21` |
| This is not a write under `.claude/**`, so the source-store boundary rule does not apply | target path is the project-root manifest | CONFIRMED; the task is correctly sited here |
| The checked-out branch is a `dev/*` feature branch while `main` has moved ahead | `git symbolic-ref -q --short HEAD`; `git branch --list main` | CONFIRMED: `dev/m7-ladder-continuation`; `main` exists locally |

**New finding, not in the research report**: `.claude-extensions.json` is **gitignored** in this
repository (`.gitignore:81-82` also ignores the project-root `CLAUDE.md`). Two consequences the
report's recommendations did not account for:

1. The declaration **cannot be committed**. A commit attempt scoped to it reports the
   non-failure skip documented in `.claude/rules/git-workflow.md` (`git-commit-scoped.sh` exit
   `8`/`9`) rather than producing a commit. This is expected, not a gap — but it means the
   declaration lives only in this working copy.
2. A fresh clone has no `.claude-extensions.json` at all, so the advisory returns there until the
   declaration is re-made. The *durability* risk is therefore larger than the branch-rename risk
   the report identified, and it is the reason deliverable 3's obligations are recorded in a
   **tracked** file (`docs/project-info/MAINTENANCE.md`) rather than beside the manifest.

The loader's own round-trip survival guarantee is unaffected by any of this: per
`repo-level-declarations.md:21-35`, the Lua read/write path re-encodes the whole top-level table
and never strips or allowlists keys, so the sibling keys survive every load, unload, and redeploy.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_flag` on this task record (`roadmap_flag: null` in `specs/state.json`); no roadmap
phases are added and `specs/ROADMAP.md` is not consulted or written.

## Goals & Non-Goals

**Goals**:
- Declare `integration_branch` with the branch this repository's `/orchestrate` dispatches actually
  stay checked out on, read from live git state rather than assumed.
- Declare `worktree_isolation` explicitly, with the only value that does not hard-refuse.
- Prove the gate armed by observing a real refusal and a real admit against this repository, not by
  observing the advisory's absence.
- Record, in a tracked file, the two maintenance obligations the declaration creates: re-declaring
  after a fresh clone, and updating the declaration in the same action as any rename of the
  long-lived working branch.

**Non-Goals**:
- Any route to silencing the advisory other than a real declaration. Suppressing the message while
  the gate stays disarmed is strictly worse than the present state and is out of bounds.
- Declaring `worktree_isolation: "batch"`, or building the worktree machinery it names. It is
  unimplemented and would refuse every invocation.
- Declaring `review_base`. It has no admission-gate effect (read only by
  `scripts/review-stack-prepare.sh`, on demand) and nothing in this task needs a review stack cut;
  declaring it would be unexercised configuration.
- Declaring `verification_scope` or `coupled_generated_surfaces`. Both are documented in the same
  file and both are legitimately absent here: the repository's touched-path verification resolves
  correctly under the default topology, and no generated surface in this repository derives from
  either of this plan's edit targets.
- Redesigning the admission mechanism to add a soft warn-only mode. The decision recorded below is
  to accept hard refuse; adding a mode is a change to the agent-system source store, which lives in
  a different repository and cannot be correctly sited here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The dirty-tree arm fires during the admit probe because a concurrent sibling dispatch left tracked Lean files modified | M | H | A `dirty_primary_tree` verdict is itself positive evidence the gate armed (that arm is reachable only once `integration_branch` is declared *and* the branch arm passed). Phase 1 records which arm fired and why, and treats it as a pass for the branch arm — not as a failed admit |
| A rename of the long-lived working branch leaves the declaration stale, turning today's advisory into a hard refusal on every invocation | H | M | Phase 2 records the obligation in a tracked file. The refusal is also self-documenting: its message names the declared branch and the exact fix |
| A fresh clone has no manifest, so the gate silently returns to disarmed | M | H | Same tracked note; the advisory itself re-announces the condition on the first invocation in any such clone |
| The deliberately-wrong declaration written during the refusal probe is observed by a real `/orchestrate` admission in the same window | M | L | The probe window is a single `--dry-run` invocation inside one sub-step, and the correct value is written in the immediately following sub-step of the same phase. The wrong intermediate state is never committed (and could not be: the file is gitignored) |
| The admit probe appears to pass for the wrong reason — e.g. the manifest failed to parse, so the key reads as absent | M | L | The probe asserts the positive signal, not the negative one: the `admit` run must show no `ADVISORY:` line at all. An unparseable manifest fails open to undeclared and would re-emit the advisory, which the check would catch |

## Decisions

- **Declared value: `dev/m7-ladder-continuation`, not `main`.** Forced by the consumer's literal
  symbolic-ref equality (re-derived at `batch-admission-lib.sh:255-340`): the declared value names
  the branch the tree must sit on. Every recent task commit lands on
  `dev/m7-ladder-continuation`; `main` trails behind via periodic PR merges, so a `main`
  declaration would refuse essentially every ordinary invocation. Phase 1's refusal probe
  demonstrates that failure mode directly rather than asserting it.
- **`worktree_isolation: "off"`, declared explicitly.** Behaviourally identical to leaving the key
  absent, so this costs nothing at runtime, and it records to a future reader that the key was
  evaluated rather than overlooked. `"batch"` is rejected: it is declared-but-unimplemented and
  refuses every invocation.
- **Refuse, not warn — accepted rather than chosen.** The implementation has no soft mode: once
  `integration_branch` is declared, a mismatch always hard-refuses. Accepting it is justified on
  its own merits and not only by the absence of an alternative. The architecture already states,
  independently of this gate, that the primary working tree stays on the declared integration
  branch and is never switched during dispatch work; the gate enforces an invariant the system
  already claims to hold. A warn-only mode would let that invariant drift undetected, which is the
  precise failure the task's own framing is written to prevent.
- **Dirty-tree arm armed as an accepted side effect.** The `dirty_primary_tree` test shares the
  declared-branch gate with the branch test, so it cannot be armed separately or left disarmed.
  It is scoped to the first cycle of an invocation and excludes the state territory (`specs/`,
  `.claude-extensions.json`, `.memory/`), so ordinary task-management writes never trip it. The
  practical change is that uncommitted tracked work outside that territory now refuses an
  invocation; this is intended behaviour, and the refusal names every offending path.
- **Obligations recorded in `docs/project-info/MAINTENANCE.md`, a tracked file.** The manifest and
  the project-root `CLAUDE.md` are both gitignored, so neither survives a fresh clone and neither
  can carry a durable obligation. `docs/project-info/MAINTENANCE.md` already holds this
  repository's workflow and commit-convention standards and is tracked, which makes it the one
  correctly-scoped durable home. The agent-system's own `repo-level-declarations.md` was rejected
  as a target: it is a deployed `.claude/**` artifact whose source store resolves to a different
  repository, so an edit there would be both wiped by the next regeneration and wrongly sited.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Land the Declaration Behind a Two-Arm Live Falsification [COMPLETED]

**Goal**: `integration_branch` and `worktree_isolation` are declared in the project-root manifest,
and the admission gate is proven armed by observing both a real refusal and a real admit against
this repository.

**Tasks**:
- [x] Capture the pre-state as the baseline, from the live tree rather than from this plan:
      `jq -r 'keys|join(", ")' .claude-extensions.json` (expect `extensions, version`) and
      `git symbolic-ref -q --short HEAD` (expect `dev/m7-ladder-continuation`). If the branch is
      anything else, STOP and report: the declared value chosen below was derived from this branch,
      and a different checked-out branch means the premise moved since plan time. *(completed:
      confirmed `extensions, version` and `dev/m7-ladder-continuation`, matching plan premise)*
- [x] Run the disarmed baseline probe and keep its output:
      `bash .claude/scripts/orchestrate-cycle-plan.sh --dry-run --state-file specs/state.json 993`
      with stdout and stderr captured to separate files in this dispatch's own scratchpad
      directory. Confirm the `ADVISORY: integration_branch is not declared` line appears on stderr
      and that `jq -r '.stop.reason // "null"'` over the stdout plan JSON is not
      `off_integration_branch`. This is the "before" half of the falsification and is why the
      later absence of the advisory means something. *(completed: advisory present, stop.reason
      null)*
- [x] **Refusal arm.** Add `"integration_branch": "main"` and `"worktree_isolation": "off"` as
      top-level sibling keys, leaving `extensions` and `version` untouched. `main` is deliberate,
      not a placeholder: it is the value the research considered and rejected, so this probe
      falsifies that alternative at the same time as it arms the gate. Re-read the file
      immediately before editing (a concurrent sibling dispatch shares this working tree).
      *(completed)*
- [x] Re-run the same `--dry-run` command and confirm the refusal actually fires: stderr carries
      `[orchestrate] ADMISSION REFUSED (off_integration_branch)` naming both the checked-out branch
      and the declared one, and the stdout plan JSON has `.stop.reason == "off_integration_branch"`
      with `.dispatch == []`. Do not commit this state. *(completed: both confirmed)*
- [x] **Admit arm.** Change the declared value to `"dev/m7-ladder-continuation"`, leaving
      `worktree_isolation: "off"` in place, and re-run the same command. Confirm all three of:
      `.stop.reason` is not `off_integration_branch`; no `ADVISORY: integration_branch is not
      declared` line appears anywhere on stderr; and `jq -r 'keys|join(", ")'` now reports four
      keys. Assert the positive signal, not merely the advisory's absence — an unparseable manifest
      fails open to undeclared and would re-emit the advisory. *(completed: see dirty-tree note
      below — the branch arm's own three positive signals all held)*
- [x] If the admit run instead returns `.stop.reason == "dirty_primary_tree"`, record that verdict
      and the paths it names as the observed outcome and treat the branch arm as PASSED: that arm
      is reachable only after the branch test succeeded, so it is positive evidence the gate armed,
      not a failure. Do not attempt to clean the tree to force an `admit` — a concurrent sibling's
      in-flight edits are not this task's to commit or discard. *(completed: the admit probe
      returned exactly this verdict — `dirty_primary_tree`, naming
      `FormalSystem/Automation/ProofMode/TemporalZTime.lean` and
      `FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalZTime.lean`, both inside
      sibling task 987's declared `file_scope` for this same batch cycle — treated as branch-arm
      PASS per this item; tree was left untouched)*
- [x] Attempt the scoped commit of `.claude-extensions.json` and record the result. A
      `git-commit-scoped.sh` exit `8`/`9` (ignored member, non-failure skip) is the expected
      outcome because the path is gitignored; record it as such rather than as a commit.
      *(completed: `git-commit-scoped.sh` exited 8, "every positive pathspec was gitignored" —
      no commit, as expected)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: full

**Tier Justification**: Orchestration admission is global config read by every `/orchestrate`
invocation before any dispatch is composed, and no single-module build or suite subset covers the
behaviour of the admission gate across that whole path — the cross-cutting surface here is the
admission predicate itself, which only a live end-to-end probe plus the manifest's own touched-path
sweep reaches.

**Scope Hypothesis**: This phase asserts the manifest carries exactly two top-level keys before the
edit and four after, and that `.claude-extensions.json` is its only edit target. The two-key figure
was re-derived from the live file at plan-authoring time (see Premise Re-Validation above), not
carried from the research report; confirm it again from the file itself in the first task above
rather than trusting this line, and if it reports anything other than `extensions, version`,
report the discrepancy before editing.

**Files to modify**:
- `.claude-extensions.json` - add two top-level sibling keys, `integration_branch` and `worktree_isolation`, leaving `extensions` and `version` byte-unchanged

**Verification**:
- `bash .claude/scripts/verify-touched.sh .claude-extensions.json` exits 0 (check the exit status,
  not only its printed output).
- The refusal probe's captured stdout satisfies `.stop.reason == "off_integration_branch"` and its
  stderr carries the `ADMISSION REFUSED` banner naming both branches.
- The admit probe's captured stdout does not carry `off_integration_branch`, and its stderr carries
  no `ADVISORY: integration_branch is not declared` line.
- `jq -e '.integration_branch == "dev/m7-ladder-continuation" and .worktree_isolation == "off" and
  has("extensions") and has("version")' .claude-extensions.json` exits 0.
- Under `/orchestrate`, this phase's own in-dispatch obligation is the scoped touched-path check
  above; the complete gate set is deferred to the orchestration close and is not invoked here.

---

### Phase 2: Record the Maintenance Obligations the Declaration Creates [COMPLETED]

**Goal**: The two obligations the declaration creates — re-declaring in a fresh clone, and updating
the declaration in the same action as any rename of the long-lived working branch — are recorded in
a tracked file, so they survive the gitignored manifest they protect.

**Tasks**:
- [x] Re-read `docs/project-info/MAINTENANCE.md` immediately before editing and locate its
      `## Commit Message Standards` section, confirmed present at plan-authoring time. If that
      heading is absent, append the new section at the end of the file instead of failing the
      phase — the placement anchor is a convenience, and the file's existence is the only real
      precondition. *(completed: confirmed present at line 406)*
- [x] Add one new top-level section, `## Orchestration Branch Declaration`, immediately after
      `## Commit Message Standards`, stating four things and nothing more: (a) the project-root
      `.claude-extensions.json` declares `integration_branch` and `worktree_isolation` beside the
      loader-owned `extensions`/`version` keys; (b) that file is gitignored, so a fresh clone must
      re-declare both keys before `/orchestrate` admission tests anything; (c) renaming the
      long-lived working branch requires updating `integration_branch` in the same action, because
      admission tests plain branch-name equality and a stale value refuses every invocation with
      `off_integration_branch`; (d) the refusal message names the declared branch and the fix, so a
      stale declaration announces itself rather than failing silently. *(completed)*
- [x] Keep the section free of task numbers and of any phrasing relative to an unstated past (no
      "previously", "no longer", "formerly") — `docs/**` is a deliverable tree governed by
      `.claude/rules/no-task-references-in-deliverables.md` and
      `.claude/rules/no-record-versioning-in-deliverables.md`. Reference the declaration file and
      the stop reason by name; those are durable anchors. *(completed: grep for task-number/
      record-versioning phrasing in the added hunk returned clean)*
- [x] Verify every relative link added resolves, then commit `docs/project-info/MAINTENANCE.md`
      alone as a scoped commit. This path is tracked and sits outside the admission gate's state
      territory, so leaving it uncommitted would refuse the next invocation's first cycle under the
      arm Phase 1 just armed. *(completed: no relative links were added by this section;
      `scripts/readme-lint.sh docs` exited 0 regardless)*

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: full

**Files to modify**:
- `docs/project-info/MAINTENANCE.md` - add one `## Orchestration Branch Declaration` section recording the re-declaration and branch-rename obligations

**Verification**:
- `grep -n '^## Orchestration Branch Declaration' docs/project-info/MAINTENANCE.md` returns exactly
  one hit.
- `bash scripts/readme-lint.sh docs` exits 0 (Check 3, broken relative references, is the gated
  check that an added link could break; check the exit status, not only the printed output). This
  root is outside CI's own `readme-lint.sh FormalSystem BimodalTools BimodalLib` invocation, so it
  is run here deliberately rather than relied on from CI.
- `bash .claude/scripts/verify-touched.sh docs/project-info/MAINTENANCE.md` exits 0.
- No task-number reference and no record-versioning phrasing in the added section, confirmed by
  reading the added hunk.
- Under `/orchestrate`, this phase's own in-dispatch obligation is the scoped touched-path check
  above, and the complete gate set is explicitly deferred to the orchestration close rather than
  invoked independently here. Under a standalone, non-orchestrated run with no such close to defer
  to, run `bash .claude/scripts/verify-deploy.sh` directly instead.

## Testing & Validation

- [ ] `jq -r 'keys|join(", ")' .claude-extensions.json` reports `extensions`, `version`,
      `integration_branch`, `worktree_isolation`, with the first two byte-unchanged.
- [ ] A `--dry-run` admission probe with a deliberately wrong declared branch produced a real
      `off_integration_branch` stop, captured and recorded — the falsification deliverable, and not
      satisfiable by the advisory's absence.
- [ ] A `--dry-run` admission probe with the correct declaration produced no
      `off_integration_branch` stop and no disarmed-gate advisory (or a `dirty_primary_tree` stop,
      which also evidences an armed gate and is recorded as such).
- [ ] `worktree_isolation` is declared `"off"`, and the rationale for not declaring `"batch"` is
      recorded in this plan's Decisions section.
- [ ] The refuse-vs-warn decision is recorded in this plan's Decisions section with its grounds.
- [ ] `docs/project-info/MAINTENANCE.md` carries the obligations section and `scripts/readme-lint.sh
      docs` exits 0.
- [ ] The implementation summary states plainly that the declaration itself is uncommittable here
      because the manifest is gitignored, and that a fresh clone must re-declare.

## Artifacts & Outputs

- `.claude-extensions.json` — two new top-level sibling keys (working-copy only; gitignored, so no
  commit carries it).
- `docs/project-info/MAINTENANCE.md` — one new `## Orchestration Branch Declaration` section
  (tracked and committed).
- Captured `--dry-run` probe outputs for the baseline, refusal, and admit runs, retained in the
  dispatch's scratchpad and quoted in the implementation summary as the falsification evidence.
- `specs/993_declare_integration_branch_admission_gate/summaries/01_declare-integration-branch-admission-gate-summary.md`.

## Rollback/Contingency

Both edits are additive and independently revertible, and no build artifact or generated surface
derives from either, so no snapshot-then-rollback recipe is needed.

- `.claude-extensions.json`: remove the two added keys with a targeted `jq 'del(.integration_branch,
  .worktree_isolation)'` into a temporary file and move it into place. Admission returns to its
  fail-open undeclared state — one advisory, neither arm armed — which is exactly today's
  behaviour. No history is involved, since the file is gitignored and no commit carries it.
- `docs/project-info/MAINTENANCE.md`: revert the single added section with a targeted edit, or
  `git revert` the one scoped commit that introduced it.
- If the admit probe cannot be made to show an armed gate at all — neither `admit` nor
  `dirty_primary_tree` — leave the keys removed rather than declared, report the probe output, and
  mark the task `[BLOCKED]`. A declaration that cannot be shown to arm the gate is the one outcome
  worse than the present advisory, and shipping it unverified is not an acceptable fallback.
