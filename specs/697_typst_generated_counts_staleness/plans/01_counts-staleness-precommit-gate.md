# Implementation Plan: Task #697

- **Task**: 697 - Typst generated counts staleness
- **Status**: [IMPLEMENTING]
- **Effort**: 5.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/697_typst_generated_counts_staleness/reports/01_generated_counts_staleness.md
- **Artifacts**: plans/01_counts-staleness-precommit-gate.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

`typst/generated/status.typ` carries counts that only ever change when Lean source changes, and
nothing in the repository regenerates it — so CI's `typst-sync-check.sh` Check 2 goes red after
the fact, twice observed. This plan closes the gap with the research-chosen mechanism: a
versioned `.githooks/pre-commit` gate that fires when the staged set touches any `.lean` file,
plus an idempotent installer wiring `core.hooksPath`. The gate is **build-free and blocking, not
auto-regenerating**: it delegates the comparison to a new `--counts-only` mode on
`typst-sync-check.sh` (so there is exactly one implementation of the Check 2 comparison), and on
mismatch prints a one-command remedy — a new `--fix` mode on the same script — instead of
attempting a multi-minute `lake build` inside `git commit`. Done means: the hook demonstrably
blocks a synthetic `.lean` addition that moves a count, `--fix` repairs it, CI's Check 2 is
untouched as the backstop, and the full CI-equivalent gate sweep is green.

### Research Integration

Key findings carried into this plan from
`reports/01_generated_counts_staleness.md`:

- **Option (a) chosen**, shaped as a build-free blocking gate rather than a silent
  regenerate-and-restage hook. This resolves both stated constraints at once: the gate path
  never needs oleans (it uses `--json`, the same build-free mode CI already uses), and because
  it compares only the non-stamp fields Check 2 compares, a commit whose counts are unchanged
  does nothing at all — no regeneration, no spurious `stamp-commit`/`stamp-date` diff.
- **Option (b) (`--fix`) adopted as a complementary secondary addition**, not the primary
  mechanism: it is the exact remedy command the hook's failure message points at, and is
  independently useful after a deliberate `--no-verify` bypass.
- **Option (c) rejected as written**: "wire it into the workflow that lands Lean files" read as
  the `.claude/` agent orchestrator would cross the source-store/deploy boundary
  (`.claude/rules/source-store-deploy-boundary.md`). It needs no in-repo substitute, because
  `.claude/scripts/git-commit-scoped.sh` invokes a plain `git commit` with **no `--no-verify`**
  (re-verified during this planning pass), so a git hook covers the orchestrator-driven commit
  path — the population both observed failures came from — transparently.
- **Option (d) rejected**: Typst has no glob/readdir primitive and cannot invoke `lake env
  lean`, so the per-declaration axiom report can never be computed at compile time; relocating
  only the scalar counts into a `#read`-able JSON file moves the staleness class rather than
  deleting it.

Grounding added during this planning pass, beyond the report:

- **`core.hooksPath` is already explicitly set in this tree's `.git/config`** to the absolute
  path `/home/benjamin/Projects/BimodalLogic/.git/hooks` (`git config --show-origin --get-all
  core.hooksPath` → `file:.git/config`). The report recorded the *effective* default; the
  installer must therefore **overwrite an existing explicit local value**, not merely set an
  unset one. `.git/hooks/` contains only `*.sample` files, so nothing is displaced.
- **The counts are currently in sync** (all six scale scalars verified equal: 604/316549,
  75/22445, 40/18216), so no drift needs repairing — the deliverable is the mechanism plus its
  demonstration. Sibling task 695 is landing `.lean` files on this same working tree this cycle,
  so the implementer must re-verify before building the demonstration.
- **The hook should call `typst-sync-check.sh`, not reimplement Check 2.** Duplicating the
  comparison in the hook would directly violate the "generator and checker must stay
  compatible" constraint by creating a third methodology to keep in step. A new `--counts-only`
  mode keeps one implementation and, as a bonus, covers the sorry-table and string fields Check 2
  already compares (which also move on `.lean` edits), not just the six scale scalars.
- **`Tests/` is the safe home for the synthetic demonstration file**: `BimodalTest`'s root is
  `Tests/BimodalTest.lean`, so a stray unimported file there is never compiled, and it does not
  perturb `lake exe mk_all --lib FormalSystem --check` (which a synthetic file under
  `FormalSystem/` would fail). It still moves `tests-file-count`, which Check 2 compares.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied with this dispatch (`roadmap_path` absent, `roadmap_flag` not
set), so no roadmap phases are included. `specs/ROADMAP.md` does mention
`typst-status-counts.sh`/`typst-sync-check.sh` as mechanical claim-verification tooling; this
plan strengthens that tooling but is not scoped to update the roadmap.

## Goals & Non-Goals

**Goals**:
- Add `--counts-only` and `--fix` modes to `scripts/typst-sync-check.sh` without changing its
  bare-invocation behaviour (CI calls it with no arguments).
- Add a versioned `.githooks/pre-commit` that blocks a commit whose staged set contains any
  `.lean` path while `typst/generated/status.typ` disagrees with a live regeneration.
- Add an idempotent `scripts/install-git-hooks.sh`, and run it against this working tree so the
  mechanism is live rather than merely committed.
- Demonstrate the mechanism firing on a synthetic `.lean` addition, and `--fix` repairing it.
- Document the one-time installer step wherever contributor setup is documented.
- Leave CI's Check 2 byte-for-byte unchanged as the unbypassable backstop.

**Non-Goals**:
- Any change to `scripts/typst-status-counts.sh`'s counting methodology, JSON schema, or write
  path. The generator is not defective; it is merely never called.
- Extending the hook to cover Check 2b (`typst-module-map.sh`) or Check 3
  (`typst-machine-appendix.sh`). The report records this as a natural follow-on; it is outside
  this task's declared `file_scope` and is deliberately not attempted.
- Any edit under `.claude/**` (agent-orchestrator changes are out of scope per
  `source-store-deploy-boundary.md`).
- Any change to `.github/workflows/ci.yml`.
- Moving the counts to Typst compile time (option (d), rejected).
- Repairing count drift as an end in itself: the counts are currently in sync.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **False block from a concurrent writer**: the gate reads the *working tree*, so an uncommitted `.lean` file belonging to sibling task 695 makes the live counts disagree with `status.typ`, blocking a commit this task cannot legitimately fix | M | M | Accept and document rather than paper over: the gate fires only when the committer itself stages a `.lean` path, and its failure message must name `git commit --no-verify` as the sanctioned escape for exactly this case, with CI's Check 2 as the backstop. Computing from the index instead would introduce a third counting methodology, which the "must stay compatible" constraint forbids. |
| Reimplementing the Check 2 comparison inside the hook lets the three copies drift | H | M | The hook calls `typst-sync-check.sh --counts-only`; there is exactly one comparison implementation, and `--counts-only` reuses the existing Check 2 code path rather than copying it. |
| Adding argument parsing regresses CI's bare `bash scripts/typst-sync-check.sh` invocation | H | L | Phase 1 verification runs the bare form and diffs its stderr/exit code against the pre-change behaviour; unknown flags must exit non-zero with usage rather than being silently ignored. |
| A naive always-run hook dirties `status.typ` with stamp-only diffs | M | L (designed out) | The gate never writes: it compares only the fields Check 2 compares (which exclude `stamp-commit`/`stamp-date`) and blocks. Regeneration happens only when a human runs `--fix`. |
| `lake build` invoked inside `git commit` hangs for minutes | M | L (designed out) | The gate is build-free by construction (`--json`); the build-requiring remedy runs outside the commit, by hand. |
| Installer clobbers a contributor's pre-existing custom hooks or `core.hooksPath` | M | L | Installer prints the prior value before overwriting, refuses silently-destructive behaviour, warns if `.git/hooks` holds any non-`*.sample` file, and is safe to re-run. |
| Synthetic demonstration file left behind, or breaking a sibling's build | M | L | Place it under `Tests/` (unimported, uncompiled), never run `lake build`/`lake test` while it exists, remove it in the same phase, and verify `git status --porcelain` carries no trace before the phase closes. |
| `core.hooksPath` is per-clone local config, so committing the hook does not activate it anywhere | H | H (certain without the step) | Phase 3 runs the installer against this live working tree as an explicit, verified step, not just an added file. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: `--counts-only` and `--fix` modes on `typst-sync-check.sh` [COMPLETED]

**Goal**: Give the checker two new invocation modes — a build-free, Check-2-only gate mode the
hook can call, and a self-healing `--fix` mode that is the remedy the hook points at — while
leaving the bare invocation CI uses behaviourally identical.

**Tasks**:
- [x] Re-read `scripts/typst-sync-check.sh` immediately before editing (sibling tasks are live on
  this tree). *(completed)*
- [x] Record the pre-change baseline: `bash scripts/typst-sync-check.sh; echo "exit=$?"` captured
  to the scratchpad for the Phase 1 comparison. *(completed)*
- [x] Add an argument-parsing block after `set -uo pipefail`, supporting `--counts-only`,
  `--fix`, `--help`, no arguments (unchanged full three-check run), and an explicit non-zero
  exit + usage on any unrecognized flag. *(completed)*
- [x] Extend the header comment's `# Usage:` line (currently `scripts/typst-sync-check.sh` with
  no arguments) to document all three forms, including that `--fix` needs a built library and
  `--counts-only` does not. *(completed)*
- [x] Implement `--counts-only`: run Check 2's `status.typ` comparison alone — skipping Check 1,
  Check 2b and Check 3 — and exit 0/1 on its result. Reuse the existing comparison block rather
  than copying it: guard the other checks behind the mode flag so the compared field set cannot
  diverge from the full run's. *(completed: factored into run_check2_status(), shared by full,
  --counts-only, and --fix)*
- [x] Implement `--fix`: on a Check 2 mismatch, invoke `bash scripts/typst-status-counts.sh`
  (the write path), then re-run the comparison and report the fields that changed; exit 0 when
  the regeneration resolved every mismatch, non-zero otherwise. *(completed)*
- [x] Make `--fix` honest about its reach: it repairs `typst/generated/status.typ` only. On a
  Check 2b or Check 3 mismatch it must report the mismatch plus the corresponding generator
  command (`scripts/typst-module-map.sh`, `scripts/typst-machine-appendix.sh`) without
  attempting a fix, and exit non-zero. *(completed)*
- [x] Have `--fix` state clearly in its output that it does not `git add` the regenerated file.
  *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: Check 2's `status.typ` comparison is asserted to cover 8 count scalars + 6
scale scalars + 3 string fields + a 6-row `sorry-table`, all with `stamp-commit`/`stamp-date`
deliberately excluded (read from `scripts/typst-sync-check.sh` lines ~199-295 during planning).
Confirm at implementation time by re-reading that block before touching it; if the field set has
changed, `--counts-only` must still delegate to whatever the block actually compares rather than
to this enumeration.

**Files to modify**:
- `scripts/typst-sync-check.sh` - add argument parsing, `--counts-only` mode, `--fix` mode,
  `--help`/usage; extend the header `# Usage:` block. No change to the comparison's field set.

**Verification**:
- `bash scripts/typst-sync-check.sh; echo "exit=$?"` matches the captured pre-change baseline
  (same three checks run, same PASS line, same exit code).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 on the current in-sync tree, prints
  only the Check 2 section, and invokes no `lake` (confirm by reading the code path; the
  wall-clock time should be comparable to `typst-status-counts.sh --json` alone).
- `bash scripts/typst-sync-check.sh --bogus-flag; echo "exit=$?"` exits non-zero and prints usage.
- `bash scripts/typst-sync-check.sh --help` prints all three forms and exits 0.
- `--fix` on an already-in-sync tree reports "nothing to fix" and leaves
  `typst/generated/status.typ` unmodified (`git status --porcelain typst/generated/status.typ`
  empty) — i.e. it does not regenerate unconditionally and so cannot create a stamp-only diff.
- `bash -n scripts/typst-sync-check.sh` clean.

---

### Phase 2: Versioned `.githooks/pre-commit` gate [COMPLETED]

**Goal**: Add the repository's first versioned git hook: a thin, build-free pre-commit gate that
blocks a `.lean`-touching commit whose counts have drifted, and is a no-op otherwise.

**Tasks**:
- [x] Create `.githooks/` and `.githooks/pre-commit`, executable (`chmod +x`), with a header
  comment explaining what it gates, why it is build-free, and that CI's Check 2 remains the
  backstop. *(completed)*
- [x] Trigger condition: exit 0 immediately unless `git diff --cached --name-only --diff-filter=ACMRD`
  contains at least one path matching `*.lean`. Include deletions (`D`) — a removed `.lean` file
  moves the counts exactly as an added one does. *(completed)*
- [x] On trigger, run `bash scripts/typst-sync-check.sh --counts-only`; exit 0 when it passes.
  *(completed)*
- [x] On failure, print a blocking message that (a) names the drifted fields (pass through the
  checker's own report), (b) gives the exact remedy
  `lake build && bash scripts/typst-sync-check.sh --fix && git add typst/generated/status.typ`,
  (c) states that `git commit --no-verify` bypasses the gate and names the legitimate case for it
  (drift attributable to another writer's uncommitted files on a shared tree), and (d) states
  that CI's Check 2 will still catch an unfixed bypass. Exit 1. *(completed)*
- [x] Make the hook robust to being run from a subdirectory: resolve the repository root via
  `git rev-parse --show-toplevel` rather than assuming the CWD. *(completed)*
- [x] Degrade safely, not silently: if `scripts/typst-sync-check.sh` is missing or unexecutable,
  print a loud warning and exit 0 (a hook must never wedge commits on a tree where the script was
  legitimately removed) — but never swallow a genuine mismatch this way. *(completed)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: the hook is asserted to be one new file of roughly 40-60 lines with no
other repository file changed in this phase. Confirm with `git status --short` at phase close:
exactly `.githooks/pre-commit` added, nothing else. *(Confirmed the "no other file changed"
half; the hook came out at 85 lines, not 40-60, because of the fuller header comment and
multi-line blocking message the Tasks above spell out in detail — this is a size-estimate miss,
not a scope deviation: exactly the enumerated Tasks were implemented, nothing extra.)*

**Files to modify**:
- `.githooks/pre-commit` - new executable hook: staged-`.lean` trigger, `--counts-only`
  delegation, blocking message with remedy and documented bypass.

**Verification**:
- `bash -n .githooks/pre-commit` clean; file mode is executable (`test -x`).
- Direct invocation with nothing staged exits 0 and prints nothing (the dominant path).
- Direct invocation from a subdirectory behaves identically (root resolution works).
- Invocation with a non-`.lean` path staged exits 0 without calling the checker.
- The mismatch branch is exercised in Phase 4, not here (the hook is not yet installed; this
  phase verifies the script in isolation).

---

### Phase 3: `scripts/install-git-hooks.sh` installer, and install it live [COMPLETED]

**Goal**: Make the hook reachable — an idempotent installer that points `core.hooksPath` at the
versioned directory, run once against this actual working tree so the mechanism is live.

**Tasks**:
- [x] Create `scripts/install-git-hooks.sh` (executable) that sets `git config core.hooksPath
  .githooks` at local scope, matching the repository's existing script conventions (`set -euo
  pipefail`, header comment block, `REPO_ROOT` resolution via `BASH_SOURCE`). *(completed)*
- [x] Handle the value that is already there: this tree's `.git/config` already carries an
  explicit absolute `core.hooksPath` of `.../.git/hooks`. Print the prior value (or "unset")
  before overwriting, then print the new one. Overwriting is correct and intended; it must be
  visible, not silent. *(completed)*
- [x] Warn — without failing — if `.git/hooks/` contains any file that is not a `*.sample`,
  since such a hook stops firing once `core.hooksPath` moves. *(completed)*
- [x] Make it idempotent: a second run is a no-op that reports "already installed" and exits 0.
  *(completed)*
- [x] Add a `--print`/`--check` read-only mode that reports whether the hooks are installed
  without changing anything (useful in docs and for a contributor verifying setup). *(completed)*
- [x] Run `bash scripts/install-git-hooks.sh` against this working tree, and record the
  before/after `git config --show-origin --get-all core.hooksPath` output in the phase notes.
  *(completed: prior `file:.git/config	/home/benjamin/Projects/BimodalLogic/.git/hooks` -> after
  `file:.git/config	.githooks`)*

**Timing**: 45 minutes

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: asserted to be one new file plus one local-git-config mutation (an
untracked change, not a committed one). Confirm: `git status --short` shows only
`scripts/install-git-hooks.sh`, and `git config --local --get core.hooksPath` returns `.githooks`.

**Files to modify**:
- `scripts/install-git-hooks.sh` - new executable installer; sets local `core.hooksPath`,
  reports the prior value, warns about displaced `.git/hooks` entries, idempotent, `--check` mode.
- *(not a file change)* this clone's `.git/config` `core.hooksPath` value — local config, never
  tracked, and therefore never committed.

**Verification**:
- `bash -n scripts/install-git-hooks.sh` clean; executable bit set.
- `git config --local --get core.hooksPath` returns `.githooks` after the run.
- A second run reports "already installed" and exits 0 (idempotence).
- `--check` mode exits 0 and mutates nothing (`git config` value unchanged afterwards).
- A deliberate no-op commit in this repo (e.g. the phase's own commit, which stages no `.lean`
  file) succeeds and produces no hook output — confirming the installed hook does not obstruct
  ordinary commits.
- `bash scripts/typst-sync-check.sh` still PASSes all three checks.

---

### Phase 4: Demonstrate the mechanism firing on a synthetic `.lean` addition [COMPLETED]

**Goal**: Show — not assert — that the stale-count class is now prevented: a staged synthetic
`.lean` file makes the gate block the commit, `--fix` repairs the counts, and the tree is
restored clean.

**Tasks**:
- [x] Re-verify the counts are in sync before starting (`bash scripts/typst-sync-check.sh
  --counts-only` exits 0). If sibling task 695 has landed `.lean` files and left real drift,
  resolve that first (`--fix`) and say so in the summary — do not build the demonstration on top
  of pre-existing drift. *(completed: found real drift twice from sibling task 695's in-flight
  edits to FormalSystem/Semantics/IntTransfer.lean and prior commits; resolved via `lake build` +
  `--fix` before starting, and again mid-phase after a sibling commit landed between the block
  transcript and the fix)*
- [x] Create a synthetic file `Tests/BimodalTest/SyntheticCountProbe.lean` with a one-line
  comment body. `Tests/` is chosen deliberately: `BimodalTest`'s root is `Tests/BimodalTest.lean`,
  so an unimported file there is never compiled, and unlike a file under `FormalSystem/` it does
  not perturb `lake exe mk_all --lib FormalSystem --check`. It still moves `tests-file-count`.
  *(completed)*
- [x] Do not run `lake build` or `lake test` while this file exists (the tree is shared with
  concurrent siblings). *(completed)*
- [x] `git add -- Tests/BimodalTest/SyntheticCountProbe.lean`, then attempt a real commit and
  capture the refusal: the hook must exit non-zero, name `tests-file-count` (and
  `tests-line-count`) as drifted, and print the remedy. Record the verbatim output. *(completed;
  transcript in the implementation summary)*
- [x] Confirm the commit did not happen (`git log -1` unchanged, file still staged). *(completed
  — HEAD stayed at the sibling's own commit throughout)*
- [x] Demonstrate the remedy end-to-end: run `bash scripts/typst-sync-check.sh --fix` (this
  needs a built library; if the build is not warm, `lake build` first and note the cost), confirm
  `typst/generated/status.typ` now reflects the synthetic file, and confirm a retried commit
  would pass the gate — verify by invoking `.githooks/pre-commit` directly rather than by
  committing the synthetic file. *(completed)*
- [x] Tear down: unstage and delete `Tests/BimodalTest/SyntheticCountProbe.lean`, then restore
  `typst/generated/status.typ` to its pre-demonstration content (`git checkout --` is forbidden
  on a dirty tree by `rules/git-workflow.md`; use `bash scripts/typst-sync-check.sh --fix` again
  to regenerate it from the now-synthetic-free tree, and accept that `stamp-commit`/`stamp-date`
  may differ — see the note below). *(completed)*
- [x] Handle the stamp residue explicitly: if the teardown regeneration leaves
  `typst/generated/status.typ` differing from HEAD only in `stamp-commit`/`stamp-date`, either
  commit that stamp-only refresh as its own clearly-labelled change or restore the committed
  version via `git restore --staged`-safe means; state which was done and why. Do not leave an
  uncommitted stray diff in a file inside this task's `file_scope`. *(completed: committed the
  stamp-only refresh as its own labelled commit, since a sibling commit had landed during
  teardown)*
- [x] Confirm `git status --porcelain` carries no trace of the synthetic path, and
  `bash scripts/typst-sync-check.sh --counts-only` exits 0. *(completed)*
- [x] Record the verbatim block/fix/teardown transcript for the implementation summary — this is
  the task's "demonstrably prevented" evidence. *(completed)*

**Timing**: 45 minutes

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: the synthetic addition is asserted to move exactly `tests-file-count`
(+1) and `tests-line-count`, and no other compared field. Confirm from the hook's own drift
report during the demonstration; if other fields also appear, a concurrent writer is responsible
and the demonstration must be re-run on a quiet tree rather than reported as-is.

**Files to modify**:
- `Tests/BimodalTest/SyntheticCountProbe.lean` - created and deleted within this phase; must not
  survive it and must never be committed.
- `typst/generated/status.typ` - transiently regenerated by the `--fix` demonstration and
  restored; any surviving change must be a deliberate, labelled stamp-only refresh.

**Verification**:
- Captured transcript shows a non-zero hook exit that blocked a real `git commit`, naming the
  drifted count fields.
- Captured transcript shows `--fix` resolving the drift and a subsequent direct `.githooks/pre-commit`
  invocation exiting 0.
- `git status --porcelain` shows no `Tests/BimodalTest/SyntheticCountProbe.lean`.
- `git log --oneline -3` shows no commit containing the synthetic file.
- `bash scripts/typst-sync-check.sh` PASSes all three checks at phase close.

---

### Phase 5: Document the contributor-facing setup step [COMPLETED]

**Goal**: Make the one-time installer discoverable where contributor setup and CI behaviour are
already documented, so a fresh clone gets the gate and a future reader of the CI doc understands
why staleness should now be rare.

**Tasks**:
- [x] Add a "Git Hooks" step to `CONTRIBUTING.md`'s "Development Setup" block, immediately after
  `lake build`: one line running `bash scripts/install-git-hooks.sh`, with a sentence saying what
  the hook gates (`.lean`-touching commits vs. `typst/generated/status.typ` freshness), that it
  is build-free, and that it can be bypassed with `git commit --no-verify` with CI as the
  backstop. *(completed)*
- [x] Mention the `--check` mode in `CONTRIBUTING.md`'s "Verifying Setup" block so a contributor
  can confirm the hook is active. *(completed)*
- [x] Add a short subsection to `docs/development/CI_CD_PROCESS.md` noting that Check 2's
  count-freshness gate now has a local pre-commit counterpart (`.githooks/pre-commit` via
  `scripts/install-git-hooks.sh`), that CI's step is deliberately unchanged and remains the
  authoritative backstop, and that the hook is not a substitute for it. Place it near the
  existing Typst-sync-check material rather than inventing a new top-level section. *(completed:
  added "### Typst Sync Check — Local Pre-Commit Counterpart" immediately after "Check README
  Health Step", the last of the existing per-check `###` subsections, before "## Wiring a New
  Check Script")*
- [x] Add `install-git-hooks.sh` to `scripts/README.md`'s script table, matching the existing
  one-line-description column style. *(completed, in the "Typst synchronization utilities"
  table)*
- [x] Add the `bash scripts/typst-sync-check.sh --fix` remedy to
  `docs/development/CI_CD_PROCESS.md`'s "Running CI Locally" block (or the nearest fitting
  place), since that is where a contributor looks after a red Check 2. *(completed, alongside the
  bare `typst-sync-check.sh` invocation which that block was missing entirely)*
- [x] Use no task-number references in any of these files (they are all outside `specs/**`; see
  `.claude/rules/no-task-references-in-deliverables.md`). *(completed; verified via grep)*

**Timing**: 45 minutes

**Depends on**: 3

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: asserted to be three documentation files
(`CONTRIBUTING.md`, `docs/development/CI_CD_PROCESS.md`, `scripts/README.md`) and no code.
Confirm with `git status --short` at phase close.

**Files to modify**:
- `CONTRIBUTING.md` - "Development Setup" gains the installer step; "Verifying Setup" gains the
  `--check` confirmation.
- `docs/development/CI_CD_PROCESS.md` - new short subsection on the local pre-commit counterpart
  to Check 2; `--fix` remedy added to the local-CI command list.
- `scripts/README.md` - one new row for `install-git-hooks.sh`.

**Verification**:
- Diff read-through confirms every changed hunk is prose/markdown with no executable surface.
- Every command quoted in the new documentation is executed once verbatim and observed to work
  (the installer line, the `--check` line, the `--fix` line).
- `bash scripts/readme-lint.sh` exits 0 (no broken relative references introduced — Check 3 is
  gated).
- `grep -nE '\b[Tt]ask [0-9]+' ` over the three changed files returns nothing.

---

### Phase 6: Full CI-equivalent gate sweep [NOT STARTED]

**Goal**: Confirm the change is green against the full local mirror of CI, and that CI's own
Check 2 behaviour is untouched.

**Tasks**:
- [ ] Confirm `Tests/BimodalTest/SyntheticCountProbe.lean` is absent and `git status --short` is
  clean of this task's stray files before starting the sweep.
- [ ] Run the local CI mirror documented in `docs/development/CI_CD_PROCESS.md`'s "Running CI
  Locally" section: `lake build --wfail`, `python3 scripts/warning-budget.py`, `lake test`,
  `lake lint`, `bash scripts/check-module-invariants.sh --no-build`,
  `bash scripts/check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem`,
  `bash scripts/readme-lint.sh`, `lake exe lint-style`,
  `lake exe mk_all --lib FormalSystem --check`, plus `bash scripts/typst-sync-check.sh` and
  `bash scripts/check-paper-definitions.sh`.
- [ ] Treat a failure in a file outside this task's `Files to modify` set as a possible sibling
  in-flight edit (task 695 is live on `FormalSystem/Semantics/**` this cycle): check `git log`
  and `git status` before attributing it to this change, and report rather than "fix" it.
- [ ] Confirm `git diff` against the merge-base shows no change to `.github/workflows/ci.yml`
  and no change to `scripts/typst-status-counts.sh`.
- [ ] Confirm the bare `bash scripts/typst-sync-check.sh` invocation CI uses is byte-identical in
  behaviour to the Phase 1 baseline capture.
- [ ] Record the per-gate results (pass/fail, and any sibling-attributed failure) for the
  implementation summary.

**Timing**: 45 minutes

**Depends on**: 4, 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the sweep is asserted to be the 11 commands enumerated above, derived from
`docs/development/CI_CD_PROCESS.md`'s "Running CI Locally" block plus the two check-script CI
steps. Confirm by re-reading that section and `.github/workflows/ci.yml`'s step list at
implementation time; if a gate has been added since, include it rather than relying on this list.

**Files to modify**:
- *(none — verification only)*

**Verification**:
- Every command in the sweep exits 0, or a non-zero exit is explicitly attributed with evidence
  (`git log`/`git status`) to a concurrent sibling's in-flight work rather than to this change.
- `bash scripts/typst-sync-check.sh` reports `PASS (all 3 checks green)`.
- `git diff --stat` against the merge-base lists only: `scripts/typst-sync-check.sh`,
  `.githooks/pre-commit`, `scripts/install-git-hooks.sh`, `CONTRIBUTING.md`,
  `docs/development/CI_CD_PROCESS.md`, `scripts/README.md` (plus, if deliberately taken, a
  labelled stamp-only `typst/generated/status.typ` refresh).

---

## Testing & Validation

- [ ] Bare `bash scripts/typst-sync-check.sh` behaves exactly as before (three checks, same PASS
  line, same exit code) — the CI call site is unchanged.
- [ ] `--counts-only` runs build-free, covers Check 2's `status.typ` comparison only, and exits
  0/1 correctly.
- [ ] `--fix` regenerates only on a real mismatch, never unconditionally (so it cannot create a
  stamp-only diff), and reports Check 2b/3 mismatches without attempting to fix them.
- [ ] An unrecognized flag exits non-zero with usage.
- [ ] The hook is a silent no-op when no `.lean` path is staged, and when staged `.lean` paths
  exist with counts in sync.
- [ ] The hook blocks a real `git commit` staging a synthetic `.lean` addition, naming the
  drifted fields and the remedy (Phase 4 transcript is the evidence).
- [ ] `--fix` resolves that drift and the gate then passes.
- [ ] The installer is idempotent, reports the prior `core.hooksPath`, and leaves
  `git config --local --get core.hooksPath` equal to `.githooks`.
- [ ] `git commit --no-verify` still bypasses the gate (documented behaviour, not a defect) and
  CI's Check 2 would still catch the result.
- [ ] Full CI-equivalent sweep green (Phase 6).
- [ ] No synthetic file survives; no `.claude/**` file modified; `.github/workflows/ci.yml` and
  `scripts/typst-status-counts.sh` unmodified.

## Artifacts & Outputs

- `scripts/typst-sync-check.sh` — `--counts-only`, `--fix`, `--help`; unchanged bare behaviour.
- `.githooks/pre-commit` — new versioned, executable, build-free pre-commit gate.
- `scripts/install-git-hooks.sh` — new idempotent installer with a read-only `--check` mode.
- `CONTRIBUTING.md` — "Development Setup" installer step and "Verifying Setup" confirmation.
- `docs/development/CI_CD_PROCESS.md` — local pre-commit counterpart subsection; `--fix` remedy.
- `scripts/README.md` — one new script-table row.
- `specs/697_typst_generated_counts_staleness/summaries/01_*-summary.md` — implementation summary
  carrying the Phase 4 block/fix/teardown transcript and the Phase 6 per-gate results.
- This clone's local `core.hooksPath` set to `.githooks` (untracked config, not an artifact file).

## Rollback/Contingency

The change is additive and confined to two new files, one script's argument handling, and three
documentation files, so rollback is per-phase and cheap:

- **Phase 1 regression** (CI's bare invocation changed behaviour): revert
  `scripts/typst-sync-check.sh` to its committed version with `git restore --staged`-safe means
  or a targeted re-edit; the file is in this task's own `file_scope`, so no cross-task
  coordination is needed.
- **Phase 2/3 problems** (hook misfires, blocks commits it should not): the mechanism is
  deactivated without touching any tracked file by running
  `git config --local --unset core.hooksPath` (or resetting it to `.git/hooks`). This is the
  first-resort contingency and needs no revert commit. Removing `.githooks/pre-commit` is the
  second resort.
- **Phase 4 residue** (synthetic file or stray `status.typ` diff left behind): delete the
  synthetic path and regenerate `typst/generated/status.typ` with
  `bash scripts/typst-sync-check.sh --fix`; do not use `git checkout --`/`git restore` pathspec
  discard on a dirty shared tree (forbidden by `rules/git-workflow.md`).
- **Phase 5** documentation is independently revertible with a targeted edit.
- **If a whole-tree rollback is ever genuinely required**, take a snapshot first per
  `context/contracts/recovery.md`'s rollback rung (including its out-of-scope override flag),
  then perform the revert. Concurrent siblings are live on this tree this cycle, so a whole-tree
  rollback is a last resort that must be reported, not taken quietly.
- CI's Check 2 is untouched throughout, so no rollback path can leave the repository with weaker
  enforcement than it has today.
