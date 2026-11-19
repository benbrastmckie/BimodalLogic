# Implementation Plan: Task #938

- **Task**: 938 - Convert the repository's measured-but-unenforced health signals into pinned baselines that block regressions
- **Status**: [COMPLETED]
- **Effort**: 9 hours
- **Dependencies**: None. Concurrent sibling task 829 (plan phase, no declared `file_scope`) shares this working tree; task 937 owns the red CI workflows this record explicitly does not.
- **Research Inputs**: specs/938_enforceable_repo_health_baselines/reports/01_enforceable-health-baselines.md
- **Artifacts**: plans/01_enforceable-health-baselines.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Three already-measured repo-health signals print their counts at every gate and never affect an
exit code, so the counts drift upward while every gate reports PASS. This plan pins each signal
to a committed, keyed, ratchet-only baseline file and makes the gate that already measures it
exit non-zero when a count rises above that baseline — the repository's own three-times-used
mechanism (`scripts/nolints.json`, `scripts/c20-declaration-baseline.txt`,
`scripts/warning-budget.txt`), not a new one. The completion criterion is "no new findings," so
no phase burns existing debt to zero; every phase instead proves the gate it built can fail, by
seeding one new finding, observing FAIL **together with** a non-zero exit status, reverting the
seed, and re-observing PASS and exit 0 — the deliberate-negative-test discipline
`docs/development/MODULE_INVARIANTS.md`'s "Adding a Check" section already requires of every
enforced check in this tree.

### Premise re-validation (Carried-Figure Discipline)

Every figure the dispatch description asserts was checked this dispatch against live state, not
carried on the research report's word:

| Dispatch figure | Verdict this dispatch | Evidence |
|---|---|---|
| 62 `STALE DATE`, 84 total READMEs, exit `PASS` | **CONFIRMED, unchanged** | `bash scripts/readme-lint.sh` → 62 STALE DATE, 4 MISSING DATE, `Total READMEs found: 84`, `RESULT: PASS`, exit 0 |
| 10 recorded declaration-span mismatches still to repair | **CONFIRMED, unchanged** | `bash scripts/check-module-invariants.sh --no-build` → `TODO C20 declaration span: 10 recorded mismatch(es) on scripts/c20-declaration-baseline.txt still to repair` |
| 145 of 1030 citations carry no declaration name | **CONFIRMED, unchanged** | same run → `TODO C20 declaration span: 145 of 1030 file.lean:NNN citations carry no declaration name` |
| 39 citations name something the target does not declare | **CONFIRMED, unchanged** | same run → `INFO C20 declaration span: 39 citation(s) name something the target file does not declare` |
| 30 citations name an ambiguous/unresolvable filename | **CONFIRMED, unchanged** | same run → `INFO C20 30 citation(s) name a filename that is ambiguous or resolves to no live file` |
| 231 findings across 16 of 18 non-`FormalSystem` roots | **CARRIED-UNVERIFIED for the numerator; denominator independently CONFIRMED at 18** | `python3 scripts/lake_targets.py exe-roots` → 15 roots; `lib-roots` → 4 roots; 19 − `FormalSystem` = 18. The 231/16 figures need a per-root build + lint sweep, which Phase 3 performs as its first step rather than assuming. |
| `check-module-invariants.sh` exits 0 on an unmodified tree | **CONFIRMED for the `--no-build` form** (the form CI runs); full-mode exit status is re-observed in Phase 6 | the `--no-build` run above |

Two corrections the description's figures do not carry, both load-bearing for Phase 1:

1. **62 is the default-root figure, not CI's.** `readme-lint.sh` defaults to `ROOTS=("FormalSystem")`;
   `.github/workflows/ci.yml` invokes it as `bash scripts/readme-lint.sh FormalSystem BimodalTools`.
   Measured this dispatch: `FormalSystem BimodalTools` → **63** STALE DATE, 4 MISSING DATE, 86
   READMEs. The baseline must therefore be keyed by README path, not by count, so one committed
   file serves every root subset the script is ever invoked with.
2. **CI is not `continue-on-error` in effect.** Every check step in `ci.yml` carries
   `continue-on-error: true`, but the terminal `Report results` step maps each step's `outcome`
   and `exit 1`s the job when any reported outcome is a failure. Making `readme-lint.sh` and the
   C20 block exit non-zero therefore makes both signals CI-blocking immediately. The C16-roots
   signal does **not** become CI-blocking — see Risks.

### Research Integration

The research report's decisive mechanical findings are carried into the phase design rather than
re-derived:

- **The key shape is chosen per signal by what identity is stable across a legitimate edit.**
  `c20-declaration-baseline.txt` omits line numbers because re-anchoring moves a number without
  making a citation more wrong; `warning-budget.py`'s own docstring rejects a bare aggregate
  count because it "cannot catch one warning fixed and another introduced in the same class."
  Every baseline below is keyed by item identity, never by a repository-wide total.
- **`nolints.json` is deliberately NOT the vehicle for C16's widened scope**, departing from the
  research report's Recommendation 3 — a documented planning decision, see Decisions below.
- **The C16/CI wiring gap is real and is recorded, not closed.** Both C16 halves sit inside
  `if [ "$RUN_BUILD" -eq 1 ]`, and CI invokes the script with `--no-build`, so CI never executes
  either half.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context and no roadmap phases are
required. `specs/ROADMAP.md` was not read or modified.

## Goals & Non-Goals

**Goals**:

- A committed, keyed, ratchet-only baseline file for each of the three signals.
- For each signal, a gate invocation that exits non-zero when its count rises above that baseline
  and exits 0 on the unmodified tree.
- Falsification evidence per signal: a seeded new finding produces a printed FAIL **and** a
  non-zero exit status in the same run; the seed's removal restores PASS and exit 0.
- The documentation surfaces that make each new baseline discoverable and each gate's enforcement
  semantics correct: `MODULE_INVARIANTS.md` rows, the script-header companion-file list, and the
  `scripts/README.md` inventory rows.

**Non-Goals**:

- Burning any of the three signals down to zero. The pinned ceiling is the deliverable.
- The two red CI workflows (task 937's scope).
- Any content rewrite of the mathematics, any `.lean` edit committed to the tree, and any
  re-anchoring of existing citations.
- A new CI step for the widened C16 scope. Deferred deliberately — see Decisions and Risks.

## Decisions

Two choices between known-workable approaches are made here so no implementation dispatch
re-litigates them.

**Decision 1 — the C16-roots baseline is a new keyed file, not an extension of
`scripts/nolints.json`.** Both options copy an established in-repo mechanism, and the research
report recommended the `nolints.json` route. A separate file is chosen instead, for four reasons
measurable at authoring time:

- `lake exe runLinter --update` rewrites `nolints.json` **wholesale**, keeping only findings for
  the roots named on that invocation. The script's own header records an observed 914 → 237-line
  collapse from exactly this. The file it would rewrite is the one CI's `lean-action` `lint: true`
  step enforces for `FormalSystem` today, and that step is not `continue-on-error`. The blast
  radius of a regeneration mistake is a live CI gate for the main library.
- Grandfathering a finding in `nolints.json` makes `runLinter` stop reporting it, so the per-root
  counts this task exists to pin would all read zero. The signal would be enforced and
  simultaneously invisible — the opposite of the dispatch's framing that an advisory count drifts
  because nobody sees it.
- `nolints.json`'s key is `[linterClass, declName]` with no root component, so it cannot express
  "this module is counted once per root that reaches it," which the C16 second half's own comment
  states is how its sum is formed.
- A separate file needs no `--update` run at all, so the enforced first half of C16 and CI's
  `lake lint` gate are untouched by this task.

**Decision 2 — a README baseline row pins the stamped date, not merely the path.** A
presence-only row would permanently exempt 62 of 84 READMEs from ever gating again, which is a
poor fit for a record whose own framing is "uniform standards." Pinning the stamp date makes the
grandfathering exact: a row matches only while the README still carries the date it carried when
the baseline was taken, so the moment anyone refreshes a stamp that README is automatically
un-grandfathered and held to refresh-on-touch thereafter. The debt can then only shrink, and a
row that no longer matches is reported for pruning on the `c20-declaration-baseline.txt`
precedent.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `ENFORCE_C16_ROOTS=1` changes only the **local full-mode** gate's exit code, not CI's — both C16 halves are inside `if [ "$RUN_BUILD" -eq 1 ]` and CI runs `--no-build` | M | Certain (measured) | Do not paper over it. Phase 4 states the asymmetry in the script's own C16 header and Phase 5 states it in `MODULE_INVARIANTS.md`, both naming the local full-mode invocation as the gate of record. Adding a CI step is out of scope: `ci.yml`'s `Report results` step asserts `seen -eq expected`, so a new check step requires a matching `report` line and an `expected` bump in the same change — a `ci.yml` edit this record defers to task 937. |
| A falsification seed is accidentally committed | H | L | No seed is ever staged. Each falsification sub-step reverts the seed and re-observes PASS **before** the phase's commit. `git status --short` is read immediately before every `git add`, and only the phase's own enumerated paths are staged. |
| A `.lean` falsification seed trips `.githooks/pre-commit` | M | L | The hook fires only when the **staged** set touches a `.lean` path; no seed is staged, and this plan commits no `.lean` file at all, so the hook is a no-op for every phase. Verified by reading the hook's trigger condition this dispatch. |
| Sibling task 829 edits a shared file mid-phase | M | M | Re-read every target file immediately before editing it; stage only this task's own hunks with an explicit file list (never `git add -A`, a directory, or a glob); treat an unexpected failure outside this plan's `Files to modify` set as possibly a sibling's in-flight edit and report rather than "fix" it. |
| A new docs row trips an enforced invariant in the same gate it documents | M | M | `C9_DOCS` (no task-number citations under `docs/`) and `C14` (stale status literals in `docs/` + `README.md` + `FormalSystem/**/*.lean`) are both enforced. Phase 5 writes no task number anywhere outside `specs/**` and writes no axiom-count or sorry-count-shaped literal. Phase 5's own verification is the `--no-build` run that executes C9_DOCS and C14. |
| New prose in `scripts/` or `docs/` uses record-versioning language | L | M | `.claude/rules/no-record-versioning-in-deliverables.md` covers the whole repository except `specs/**`. The C16 header and `MODULE_INVARIANTS.md` paragraphs rewritten in Phases 4-5 state the current enforcement rule only — no "no longer", "previously", "used to", or supersession framing. |
| The per-root sweep's wall-clock cost overruns a phase | M | M | Oleans for all 19 roots are present on this tree (spot-checked this dispatch), so `lake build <root>` is a near-no-op per root and the cost is 18 `runLinter` imports. Phase 3 runs the sweep as a detached shell-level background job with a hard `timeout` and a bounded waiter per `context/patterns/bounded-build-waiter.md`, and writes its raw logs to disk so a re-run is not needed to re-parse them. |
| `runLinter`'s grouped output does not parse at module granularity | L | M | Phase 3's parser is written against the format read from Batteries' own `Frontend.lean` this dispatch (`/- The \`<linter>\` linter reports:` section headers, `-- <Module>` group headers, `path:line:col: error: <decl> <msg>` rows). If module grouping proves unreliable on real output, fall back to the coarser `<count> <root> <linter>` key — still per-class, still not a bare aggregate — and record the fallback in the baseline file's header. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 3 |
| 3 | 5 | 1, 2, 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel. Phases 2 and 4 both edit
`scripts/check-module-invariants.sh`, in disjoint regions (the C20 python heredoc and the C16
second half); they are in different waves, so they never run concurrently.

---

### Phase 1: Pin the README verification-date baseline and gate it [COMPLETED]

**Goal**: `readme-lint.sh` Check 4 exits non-zero on a README that is newly stale or newly
missing a `Last verified` stamp, and exits 0 on the tree as it stands.

**Tasks**:

- [x] Re-measure before writing anything: run `bash scripts/readme-lint.sh` and
      `bash scripts/readme-lint.sh FormalSystem BimodalTools`, recording both STALE/MISSING counts
      and both exit statuses. Treat the Scope Hypothesis below as refuted if either differs. *(completed)*
- [x] Create `scripts/readme-date-baseline.txt` with a comment header stating: one row per
      finding, shape `<class> <path> <stamp>` where `<class>` is `stale` or `missing` and
      `<stamp>` is the README's recorded `YYYY-MM-DD` stamp (`-` for a `missing` row); the file
      only ever SHRINKS; a `stale` row matches only while the README still carries the recorded
      stamp, so refreshing a stamp un-grandfathers that README permanently; never add a row to
      quiet a new finding — refresh the stamp instead. *(completed)*
- [x] Generate the rows from the union of both invocations above (`FormalSystem` and
      `FormalSystem BimodalTools`), so one committed file covers every root subset. Sort rows
      deterministically (class, then path). *(completed)*
- [x] Add `ENFORCE_README_DATES=${ENFORCE_README_DATES:-1}` near the top of `readme-lint.sh`,
      with a comment stating it defaults to enforced because the baseline pins the current debt
      in this same change, and that it must never be flipped to 0 to quiet a new finding. *(completed)*
- [x] In the Summary block (not the Check 4 loop — that loop runs in a `while read` subshell and
      its `WARNINGS` increments do not reach the parent, which is why the Summary already
      recomputes `NO_DATE`), recompute the stale set and the missing set, diff each against the
      baseline, and set two new counters: `STALE_NEW` (a stale README with no matching baseline
      row) and `NODATE_NEW` (a missing-stamp README with no matching baseline row). *(completed)*
- [x] Print, in the Summary block, the total `Stale dates (info):` count — absent there today,
      so the 62 figure is currently visible only by scrolling the per-line warnings — alongside
      `Stale dates (new):` and `Missing dates (new):`. *(completed)*
- [x] Report, not fail, each baseline row that no longer matches a live finding, with the
      instruction to prune it (the `c20-declaration-baseline.txt` stale-key precedent). *(completed)*
- [x] Extend the final exit condition to
      `[ "$MISSING" -gt 0 ] || [ "$BROKEN" -gt 0 ] || [ "$STALE_NEW" -gt 0 ] || [ "$NODATE_NEW" -gt 0 ]`
      when `ENFORCE_README_DATES` is 1, and update the `RESULT: FAIL (...)` message to name which
      counter failed. *(completed)*
- [x] Update the script's own header: Check 4 is no longer described as reported-only, and the
      gated-vs-reported section names the baseline file. *(completed)*
- [x] **Falsify.** Pick one README that is currently clean and NOT on the baseline. Edit its
      `Last verified` stamp to a date before its directory's last commit date
      (`git log -1 --format=%cs -- <dir>`). Run `bash scripts/readme-lint.sh FormalSystem BimodalTools`
      and record both the printed `STALE DATE` / `RESULT: FAIL` lines and `echo $?`, confirming a
      non-zero status in the same run. Then also falsify the missing-stamp arm: delete the stamp
      line from a clean README not on the baseline and re-observe FAIL + non-zero exit. Revert
      both edits with a targeted `git checkout -- <path>` only after confirming `git status --short`
      shows no staged content, and re-observe `RESULT: PASS` and exit 0. *(completed)*
- [x] Commit only `scripts/readme-lint.sh` and `scripts/readme-date-baseline.txt`, staged by
      explicit file list. *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts 62 stale / 4 missing / 84 READMEs for the default root
and 63 / 4 / 86 for `FormalSystem BimodalTools`, both measured this dispatch. The implementer
confirms both by re-running the two invocations as the phase's first task and generating the
baseline from that run's own output — never from the numbers written here.

**Tier Justification**: `bash scripts/readme-lint.sh FormalSystem BimodalTools` is the exact
command whose exit code this phase changes and the one CI invokes, and it is the only consumer of
either touched file.

**Files to modify**:

- `scripts/readme-lint.sh` - add the `ENFORCE_README_DATES` flag, the baseline diff and the two
  new counters in the Summary block, the stale-date total line, the pruning report, and the
  extended exit condition; refresh the header's gated-vs-reported description.
- `scripts/readme-date-baseline.txt` - new; the pinned stale/missing rows with their header.

**Verification**:

- `bash scripts/readme-lint.sh` and `bash scripts/readme-lint.sh FormalSystem BimodalTools` both
  print `RESULT: PASS` and exit 0 on the tree with the baseline committed and no seed present.
- The seeded stale README produces a `RESULT: FAIL` line naming the new-stale counter **and**
  `echo $?` prints non-zero in the same run; the seeded missing-stamp README does the same.
- Reverting both seeds restores `RESULT: PASS` and exit 0.
- The Summary block prints a stale-date total, and that total equals the per-line `STALE DATE`
  count (`grep -c`).

---

### Phase 2: Pin the C20 residual, unverifiable and ambiguous-filename baselines and gate them [COMPLETED]

**Goal**: C20's three un-gated sub-counts fail the gate when any citer file's count in any of the
three categories rises above its pinned entry, and pass on the tree as it stands.

**Tasks**:

- [x] Re-measure first: `bash scripts/check-module-invariants.sh --no-build`, recording the four
      C20 lines verbatim and the script's exit status. Treat the Scope Hypothesis as refuted if
      any of 145 / 1030 / 39 / 30 differs. *(completed)*
- [x] In the C20 python heredoc, collect a per-citer residual list alongside the existing
      `unverifiable` and `unnamed` lists — the loop already has the citer path `p` and the
      verdict, so this adds a list append, not a new scan. Keep the existing printed totals
      exactly as they read today. *(completed)*
- [x] Add an emit mode on the existing `C20_DECL_PRINT_KEYS` precedent (e.g.
      `C20_RESIDUAL_EMIT=1`) that prints the baseline rows to stdout for redirection, so the
      generator and the gate can never disagree about the key shape. *(completed)*
- [x] Create `scripts/c20-residual-baseline.txt` with a comment header stating: generated by the
      emit mode named above; shape `<count> <citer-path> <category>` with `<category>` one of
      `residual`, `unverifiable-decl`, `unverifiable-file`; the counts are a CEILING and may only
      decrease; no line number is recorded, deliberately, because an unrelated edit above a
      citation would otherwise manufacture a new finding; never regenerate the file to make a
      regression disappear. *(completed)*
- [x] Populate it from the emit mode's own output, sorted deterministically. *(completed)*
- [x] Add `ENFORCE_C20_RESIDUAL=${ENFORCE_C20_RESIDUAL:-1}` to the flag block, enforced from the
      outset because the baseline pins the debt in the same change — the same reason C12-C15 ship
      flagless — and `export` it alongside `ENFORCE_C20 ENFORCE_C20_DECL`. *(completed)*
- [x] Implement the comparison in the heredoc: a `(path, category)` pair whose live count exceeds
      its baseline count fails; a pair absent from the baseline with a non-zero live count fails
      (a file newly introducing the defect class); a pair whose live count is below its baseline
      entry is reported for pruning and never fails. Print the failing rows (capped, in the
      existing `note(...)` style) with the repair instruction: name the declaration, or drop the
      line number and cite the name alone. *(completed)*
- [x] Set the block's `status = 1` on a failure so the heredoc's `sys.exit(status)` propagates to
      `C20_STATUS` and the script's `FAILURES` counter, exactly as tier 1 and the declaration-span
      assertion already do. *(completed)*
- [x] Update the C20 header comment: the residual is no longer described as never holding the gate
      hostage; state the current rule — the residual, the unverifiable-declaration and the
      unverifiable-filename counts are each pinned per citer file and gated against an increase —
      and name the baseline file. *(completed)*
- [x] **Falsify**, one seed per category, since a check answering three routes proves nothing
      about two of them if only one is exercised. (a) `residual`: add a bare `Foo.lean:NNN`
      citation, with no declaration name, to a comment in a file already in `SCAN_ROOTS` whose
      count for that category is pinned, choosing a target line that exists and is non-blank so
      tier 1 stays green and only the residual arm moves. (b) `unverifiable-decl`: add a citation
      naming something the target file does not declare. (c) `unverifiable-file`: add a citation
      whose filename resolves to no live file. For each, run
      `bash scripts/check-module-invariants.sh --no-build`, record the printed `FAIL C20` line and
      `echo $?` showing non-zero in the same run, then revert the seed and re-observe the `PASS`
      lines and exit 0. Prefer a `.sh` or `.md` citer over a `.lean` one so no seed can interact
      with the `.lean` pre-commit trigger at all. *(completed)*
- [x] Commit only `scripts/check-module-invariants.sh` and `scripts/c20-residual-baseline.txt`. *(completed)*

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts 145 of 1030 residual, 39 unverifiable-declaration and 30
unverifiable-filename citations, and that the 10 recorded declaration-span mismatches already
ratchet and need no new mechanism. All four were observed live this dispatch. The implementer
re-runs `bash scripts/check-module-invariants.sh --no-build` as the phase's first task and
generates the baseline from the emit mode's own output on that tree, never from these numbers.

**Tier Justification**: `bash scripts/check-module-invariants.sh --no-build` is the exact gate
whose exit code this phase changes, is the form CI runs, and executes the C20 block in full — no
cheaper check reaches the edited heredoc.

**Files to modify**:

- `scripts/check-module-invariants.sh` - C20 heredoc: per-citer residual collection, the emit
  mode, the baseline comparison and its failure/pruning reports, the `status = 1` path; the
  `ENFORCE_C20_RESIDUAL` flag and its `export`; the C20 header comment's statement of what is
  gated; the header's companion-file list entry for the new baseline.
- `scripts/c20-residual-baseline.txt` - new; the pinned per-citer per-category ceilings with their
  header.

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` prints the existing four C20 lines
  unchanged, prints `PASS` for the new assertion, and exits 0.
- Each of the three seeds produces a printed `FAIL C20` naming its category **and** a non-zero
  script exit status in the same run; each revert restores `PASS` and exit 0.
- The emit mode re-run on the unmodified tree reproduces the committed baseline byte-for-byte
  (`diff <(C20_RESIDUAL_EMIT=1 ...) scripts/c20-residual-baseline.txt` modulo the comment header).

---

### Phase 3: Measure the C16 root sweep and generate its pinned baseline [COMPLETED]

**Goal**: a committed per-root baseline for the env_linter findings across every non-`FormalSystem`
lakefile root, generated from a real sweep, plus a generator/checker script that owns both the
parse and the comparison.

**Tasks**:

- [x] Enumerate the roots from the single existing scrape site:
      `python3 scripts/lake_targets.py exe-roots` and `... lib-roots`, minus `FormalSystem`.
      Record the count. Do not hand-write the list anywhere. *(completed)*
- [x] Run the sweep: for each root, `lake build <root>` then `lake exe runLinter <root>`, keeping
      each root's raw log on disk under the session scratchpad so the parse can be re-run without
      re-sweeping. Route every `lake` invocation through
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- ...`; run the whole sweep
      as a detached shell-level background job with a hard `timeout` and block on it with the
      bounded single-call waiter idiom (`context/patterns/bounded-build-waiter.md`) — never
      `Bash(run_in_background: true)`, never an unbounded foreground call. *(completed)*
- [x] Record the measured per-root totals and the dirty-root count, and compare them against the
      231/16-of-18 figure this plan carries unverified. State the result explicitly either way,
      including when it confirms the carried figure unchanged. *(completed: the 231 TOTAL is
      confirmed exactly, but the denominator is 15 of 17 MEASURABLE roots, not 16 of 18 --
      `BimodalToolsTest`'s build is broken by a pre-existing "Ambiguous term closureList" error
      independent of env_linter and already filed and owned elsewhere, not by this record. The
      prior unwidened mechanism's "16 dirty" figure counted `BimodalToolsTest` as dirty-but-zero
      only because its crash log happened not to match a `grep -c 'error: '` fallback pattern --
      a silent miscount this phase's own parser refuses to repeat, excusing that one root
      loudly via `scripts/c16-roots-unmeasurable.txt` instead of silently reporting it as a
      measured zero. See Deviations below.)*
- [x] Write `scripts/c16_roots_baseline.py` on the `scripts/warning-budget.py` model: it parses
      the per-root logs, emits rows `<count> <root> <module> <linter>`, and supports `--update`
      (rewrite the baseline) and a default compare mode (exit 0 when no row exceeds its baseline,
      exit 1 when one does, exit 2 when the measurement itself could not be trusted — a log it
      cannot parse, or a root whose log is missing). The exit-2 arm matters: a measurement that
      silently degrades to "no findings" would bless a regression. *(completed)*
- [x] Follow `warning-budget.txt`'s disposition-row discipline: every linter class observed in the
      sweep gets a row in the baseline header recording its disposition, and a class with no row
      is exit 2 rather than a silent pass. This is what stops a future linter class being absorbed
      into the baseline by a routine `--update` with nobody reading it. *(completed)*
- [x] Generate `scripts/c16-roots-baseline.txt` via `--update`, with a header stating: the counts
      are a CEILING and may only decrease; a module reachable from two roots is counted once per
      root, which is why the root is part of the key; never regenerate to make a regression
      disappear. *(completed)*
- [x] Confirm the generator is idempotent: a second `--update` over the same logs changes no byte,
      and the default compare mode exits 0 against the freshly generated baseline. *(completed)*
- [x] Add a `scripts/README.md` row for the new generator script. *(completed)*
- [x] Commit only `scripts/c16_roots_baseline.py`, `scripts/c16-roots-baseline.txt` and
      `scripts/README.md`. *(deviation: altered — a fourth file,
      `scripts/c16-roots-unmeasurable.txt`, is committed alongside the three named here. It is
      the `scripts/module-invariants-manifest.txt` (C6) precedent applied to a root whose BUILD,
      not its linting, cannot be measured right now — see the annotation on the measurement task
      above. Without it the generator's own anti-silence guard would never let `--update` or the
      compare-mode gate succeed at all, for a reason outside this record's scope to fix.)*

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase assumes 18 non-`FormalSystem` roots (independently confirmed this
dispatch from `lake_targets.py`: 15 exe + 4 lib − `FormalSystem`) and carries 231 findings across
16 of them as UNVERIFIED. It further assumes the sweep is cheap because oleans for all 19 roots
are present on this tree (spot-checked this dispatch for `BimodalTools`, `BimodalTest`,
`DatasetGeneratorMain`, `MachineAppendixMain`). The implementer confirms both by the sweep itself
and reports the measured numerator rather than this plan's carried one.

**Tier Justification**: `python3 scripts/c16_roots_baseline.py` in compare mode against the
freshly generated baseline is the only consumer of either new file in this phase — no gate wiring
exists yet, so no broader check can observe these edits.

**Files to modify**:

- `scripts/c16_roots_baseline.py` - new; the log parser, `--update` writer, compare mode, and
  untrusted-measurement exit-2 arm.
- `scripts/c16-roots-baseline.txt` - new; the pinned per-root per-module per-linter ceilings, with
  the disposition rows and header.
- `scripts/README.md` - add the inventory row for the new generator script.

**Verification**:

- The sweep's per-root totals are recorded with the commands that produced them, and the measured
  numerator and dirty-root count are stated against the carried 231/16 figure.
- `python3 scripts/c16_roots_baseline.py --update` run twice over the same logs leaves the
  baseline byte-identical.
- Compare mode exits 0 against the committed baseline, and exits 2 (not 0) when handed a missing
  or unparseable log — demonstrated once, deliberately.

---

### Phase 4: Wire the C16-roots gate and flip `ENFORCE_C16_ROOTS` [COMPLETED]

**Goal**: a full-mode `check-module-invariants.sh` run exits non-zero when any root's env_linter
count rises above the pinned baseline, and exits 0 on the unmodified tree.

**Tasks**:

- [x] Re-read `scripts/check-module-invariants.sh`'s C16 second half immediately before editing
      (sibling task 829 shares this tree and has no declared `file_scope`). *(completed)*
- [x] Have the second half write each root's `runLinter` log to a per-root path and hand the set to
      `scripts/c16_roots_baseline.py` in compare mode, replacing the bare `C16R_TOTAL`/`C16R_DIRTY`
      verdict with that script's row-level one. Keep printing the live per-root figures — the
      debt stays visible, which is the point of the signal. *(completed)*
- [x] Map the generator's exit codes onto the gate: 0 → `pass C16`; 1 → `fail C16` when
      `ENFORCE_C16_ROOTS` is 1 and `soft C16` otherwise; 2 → `fail C16` unconditionally, not
      suppressed by the flag, on the `ENFORCE_C28=0` precedent for an untrusted measurement. *(completed)*
- [x] Flip `ENFORCE_C16_ROOTS` from `0` to `1` and rewrite its inline comment to state the current
      rule: the gate fails when a root's count rises above `scripts/c16-roots-baseline.txt`, not
      when the count is non-zero. *(completed)*
- [x] Delete the two now-wrong notes (`set ENFORCE_C16_ROOTS=1 to make this exit-code-affecting
      once the count reaches zero`, and the clean-tree variant) and replace them with the pruning
      instruction and a pointer to the baseline. *(completed)*
- [x] Replace the hand-written dated per-root table in the C16 header with a pointer to the
      generated baseline file. A hand-written snapshot living beside a check that exists because
      such snapshots drift is the defect class this task closes, in miniature. *(completed)*
- [x] State the local/CI asymmetry explicitly in the C16 header: both halves sit inside
      `if [ "$RUN_BUILD" -eq 1 ]`, CI invokes the script with `--no-build`, so the gate of record
      for the widened scope is the local full-mode invocation. State the current arrangement
      only — no "previously", "no longer", or supersession framing (`.claude/rules/no-record-versioning-in-deliverables.md`). *(completed)*
- [x] Add the new baseline to the script header's companion-file list. *(completed)*
- [x] **Falsify.** Introduce one env_linter finding in a module belonging to a root OTHER than the
      cheapest-to-build one, on the C25 precedent that a seed in the module under repair proves
      nothing about the gate: e.g. a `def` with a non-trailing underscore, or an unused argument,
      in an out-of-closure module. Rebuild that root and run the full-mode
      `bash scripts/check-module-invariants.sh` (no `--no-build`). Record the printed `FAIL C16`
      line naming the above-baseline row **and** `echo $?` showing non-zero in the same run. Note
      what did NOT fail in the same run — `runLinter FormalSystem` and the `--no-build` pass —
      since that is exactly the invisible-failure condition this half closes. Revert the seed,
      rebuild, and re-observe `PASS C16` and exit 0. Never stage the seeded `.lean` file. *(completed)*
- [x] Commit only `scripts/check-module-invariants.sh`. *(completed)*

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase assumes the C16 second half's verdict can be replaced without
touching the enforced first half (`runLinter FormalSystem` against `scripts/nolints.json`) and
without any `--update` to `nolints.json`. The implementer confirms by observing the first half's
own `PASS C16` line unchanged in the same full-mode run, and by `git diff --stat` showing
`scripts/nolints.json` untouched.

**Tier Justification**: `bash scripts/check-module-invariants.sh` in full mode is the only
invocation that executes the edited C16 block at all, and it is the gate whose exit code this
phase changes.

**Files to modify**:

- `scripts/check-module-invariants.sh` - C16 second half: per-root log capture, the generator
  call, the three-way exit-code mapping; the `ENFORCE_C16_ROOTS` flip and its comment; removal of
  the two stale enforcement notes and the dated per-root table; the local/CI asymmetry statement;
  the header companion-file entry.

**Verification**:

- `bash scripts/check-module-invariants.sh` (full mode) prints `PASS C16` for both halves and
  exits 0 on the unmodified tree.
- The seeded env_linter finding produces a printed `FAIL C16` naming the above-baseline row
  **and** a non-zero script exit status in the same run; the revert restores `PASS C16` and exit 0.
- `bash scripts/check-module-invariants.sh --no-build` still exits 0 and still prints the two
  `INFO C16 ... skipped (--no-build)` lines — this phase does not change CI's behavior, and that
  is stated rather than assumed.
- `git diff --stat` for the phase's commit lists exactly one file and does not list
  `scripts/nolints.json`.

---

### Phase 5: Record the three mechanisms in the documentation surfaces [COMPLETED]

**Goal**: each new baseline and each gate's enforcement semantics are discoverable from the places
this repository already keeps that record, and the falsification evidence is written down in the
form "Adding a Check" requires.

**Tasks**:

- [x] Add a `MODULE_INVARIANTS.md` entry for the C20 residual/unverifiable assertion and for the
      C16-roots baseline comparison, each naming its baseline file, its `ENFORCE_*` flag and its
      default. *(completed)*
- [x] Amend `MODULE_INVARIANTS.md`'s "Adding a Check" treatment of `ENFORCE_C16_ROOTS`: the rule
      is now a pinned ceiling with a gate that fails on an increase, not "flip the default to 1
      once it reaches zero". State the current rule directly and state why a pinned non-zero
      ceiling was chosen over waiting for zero — without record-versioning language. *(completed)*
- [x] Record the deliberate negative tests in the same section's established narrative form, one
      per seeded arm (two for README dates, three for C20, one for C16-roots): what was seeded,
      where, that the printed FAIL and the non-zero exit were observed **together**, that the seed
      was reverted and PASS and exit 0 re-observed, and — for C16 — what did not fail in the same
      run. *(completed)*
- [x] State the local/CI asymmetry for the widened C16 scope in `MODULE_INVARIANTS.md` too, naming
      the local full-mode invocation as the gate of record, and that extending CI coverage means a
      `ci.yml` check step plus a matching `report` line and `expected` bump — work this record does
      not own. *(completed)*
- [x] Add `scripts/README.md` rows for `scripts/readme-date-baseline.txt`,
      `scripts/c20-residual-baseline.txt` and `scripts/c16-roots-baseline.txt`. *(completed)*
- [x] Re-read the diff for task-number citations (`C9`/`C9_DOCS` are enforced; no task number may
      appear outside `specs/**`) and for status-literal shapes `C14` scans for. *(completed)*
- [x] Commit only `docs/development/MODULE_INVARIANTS.md` and `scripts/README.md`. *(completed)*

**Timing**: 1 hour

**Depends on**: 1, 2, 4

**Verification Tier**: prose

**Commit Mode**: per-substep

**Tier Justification**: every hunk is markdown prose with no executable surface, and
`bash scripts/check-module-invariants.sh --no-build` executes the enforced checks that actually
read these two files (C9_DOCS, C14's content half, C5, C10, C13, C32), so it is the cheapest
command that covers the edit.

**Files to modify**:

- `docs/development/MODULE_INVARIANTS.md` - the two new check entries; the amended
  `ENFORCE_C16_ROOTS` paragraph; the negative-test records; the local/CI asymmetry statement.
- `scripts/README.md` - inventory rows for the three new baseline files.

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` exits 0, with `PASS C9`, `PASS C9D`,
  `PASS C14` and `PASS C13` among its lines — the enforced checks that read `docs/` prose.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0 (Check 3 reads the markdown
  links added in this phase).
- A diff read-through confirms every changed hunk is prose, carries no task number, and uses no
  record-versioning phrasing.

---

### Phase 6: Whole-tree verification and the consolidated falsification record [COMPLETED]

**Goal**: the complete gate set is green on an unmodified tree with all three gates enforced, and
the task's falsification evidence exists as one readable record.

**Tasks**:

- [x] Confirm the tree is clean of every seed: `git status --short` lists no modification outside
      this task's own committed paths, and no `.lean` file at all. *(completed)*
- [x] Run the complete gate set, recording each command and its exit status:
      `bash scripts/check-module-invariants.sh` (full mode),
      `bash scripts/check-module-invariants.sh --no-build`,
      `bash scripts/check-module-invariants.sh --emit-inventory --check`,
      `bash scripts/readme-lint.sh`,
      `bash scripts/readme-lint.sh FormalSystem BimodalTools`,
      and `python3 scripts/c16_roots_baseline.py` in compare mode. *(completed)*
- [x] For any gate that reports a finding, apply the baseline-delta reading rather than an
      absolute-zero one: enumerate the findings, show each lies outside this plan's
      `Files to modify` set and is pre-existing, and show each touched file passes individually.
      A pre-existing finding outside this task's scope is a recorded PASS for this phase, not a
      blocker, and never grounds to edit an out-of-scope file to force a count to zero. *(completed)*
- [x] Assemble the consolidated falsification record for the task summary: for each of the six
      seeded arms, the seed, the command, the printed FAIL line, the observed non-zero exit status,
      and the post-revert PASS and exit 0. *(completed)*
- [x] Confirm the three enforcement flags' defaults are as intended
      (`ENFORCE_README_DATES=1`, `ENFORCE_C20_RESIDUAL=1`, `ENFORCE_C16_ROOTS=1`) and that each
      gate's exit code actually responds to its flag being set to 0 — a flag that does nothing is
      a flag that lies. *(completed)*
- [x] Record the C16 local/CI asymmetry one final time as a stated, decided outcome, not an
      oversight: the widened scope's gate of record is the local full-mode run; CI coverage is
      task 937's `ci.yml` territory. *(completed)*

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:

- (none) - verification and evidence assembly only. `scripts/c16-roots-baseline.txt` may need a
  pruning edit if the final sweep reports a row below its ceiling; if so, commit that one file
  alone.

**Verification**:

- The complete gate set above runs, with every command and exit status recorded. All six
  invocations exit 0, or every non-zero exit is accounted for as a pre-existing finding outside
  this plan's `Files to modify` set, with the per-file evidence that each touched file passes.
- All three new baseline files are committed and tracked (`git ls-files` lists each).
- The consolidated falsification record covers all six seeded arms, each with a printed FAIL and
  an observed non-zero exit status in the same run, and each with a post-revert PASS and exit 0.
- `git status --short` shows no residual seed.

---

## Testing & Validation

- [x] `bash scripts/readme-lint.sh` exits 0; `bash scripts/readme-lint.sh FormalSystem BimodalTools`
      exits 0.
- [x] `bash scripts/check-module-invariants.sh --no-build` exits 0.
- [x] `bash scripts/check-module-invariants.sh` (full mode) exits 0.
- [x] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [x] Each of the three signals has a committed baseline file and a gate invocation observed to
      exit non-zero on a seeded increase and 0 after the seed's removal.
- [x] No `.lean` file appears in any of this task's commits, and `scripts/nolints.json` is
      untouched throughout.

## Artifacts & Outputs

- `scripts/readme-date-baseline.txt` — pinned README stale/missing-stamp rows.
- `scripts/c20-residual-baseline.txt` — pinned per-citer-file ceilings for C20's residual,
  unverifiable-declaration and unverifiable-filename counts.
- `scripts/c16-roots-baseline.txt` — pinned per-root per-module per-linter env_linter ceilings.
- `scripts/c16_roots_baseline.py` — the sweep-log parser, `--update` writer and compare-mode gate.
- Edits to `scripts/readme-lint.sh`, `scripts/check-module-invariants.sh`,
  `docs/development/MODULE_INVARIANTS.md`, `scripts/README.md`.
- A consolidated falsification record (six seeded arms) in the task's completion summary.

## Rollback/Contingency

Every phase is a separate commit touching only enumerated, repo-owned `scripts/` and `docs/`
files; no `.lean` source, no `scripts/nolints.json`, no `ci.yml`. A phase is reverted with
`git revert` of its own commit, which restores the prior advisory-tier behavior of that one gate
and leaves the other two unaffected.

If a gate turns out to fail on legitimate work after landing, the escape hatch is the phase's own
`ENFORCE_*` flag set to 0 for one local run — never a baseline regenerated to absorb the finding,
and never a flag default flipped back to 0 in the committed script. If Phase 3's sweep cannot be
completed within its budget, Phases 1-2 still land independently (they are in the same wave and
share no file with Phase 3), and Phases 3-4 are the only ones deferred; the task is then
`[PARTIAL]` with two of three signals enforced, which is a strictly better state than the
current three-of-three advisory one.
