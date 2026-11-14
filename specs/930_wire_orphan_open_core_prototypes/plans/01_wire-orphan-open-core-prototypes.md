# Implementation Plan: Task #930

- **Task**: 930 - Promote and wire the two orphan open-core prototypes into the evidence gate
- **Status**: [IMPLEMENTING]
- **Effort**: 2.75 hours
- **Dependencies**: None
- **Research Inputs**: specs/930_wire_orphan_open_core_prototypes/reports/01_wire-orphan-open-core-prototypes.md
- **Artifacts**: plans/01_wire-orphan-open-core-prototypes.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Two compiled prototypes that `RaySummary/README.md` cites as the sole authority for two
load-bearing refutations about the depth-`0` open core sit in gitignored `specs/archive/`, where
the evidence gate cannot hold them and a fresh clone does not have them. This plan promotes both
verbatim (one header line changed each) into `specs/evidence/seam-gluing-ray-product/`, wires each
into `scripts/check-evidence-probes.sh` as a `WIRED` entry with its table block, and rewrites the
two README citations to name the new wired paths, dropping the "not a wired probe" qualifier that
ceases to be true. No proof content changes: this is a records/gate-wiring operation, and the
no-weakening rule forbids touching either statement.

### Research Integration

The research round measured, rather than projected, every quantity this plan depends on:

- **Neither README authority claim is stale.** Both prototypes compile clean against the live tree
  (`lake env lean` exit 0 through the build guard, 2.37 s and 1.75 s), and every headline theorem's
  `#print axioms` shows only a subset of `[propext, Classical.choice, Quot.sound]` — no `sorryAx`,
  no custom axiom, no `native_decide`. The serious outcome the task description flagged as the more
  dangerous possibility did not materialize, so no stale-authority finding is owed.
- **The promotion itself was run end-to-end and reverted.** Promoted copies at the paths this plan
  names, intent-to-added, with both `WIRED` entries present, produced
  `PASS  all 60 wired probe(s) compile`, exit 0 — the 58-probe baseline raised by exactly two, with
  every other probe row byte-identical. The working tree carries no promotion edits now.
- **The library cites both prototypes by bare filename only**, so the promotion needs no companion
  edit anywhere outside the two README parentheticals.
- **Collection and naming** are fixed by sibling precedent: `seam-gluing-ray-product/` already holds
  the whole `ladder-*` family, including `ladder-cell-obligation-refutation.lean`, promoted from the
  same archived prototype directory as `tight-chain-regime-b.lean`.

### Premise Re-Validation (Carried-Figure Discipline)

Every figure-bearing claim in the dispatch description was checked against live state at plan time,
not inherited from the description or the report:

| Carried claim | Live check | Result |
|---|---|---|
| `README.md:1002` cites `tight-chain-regime-b.lean` | `grep -n` on the live README | CONFIRMED, line 1002 exact |
| `README.md:1039` cites `spanning-divisibility.lean` | same grep | CONFIRMED, line 1039 exact |
| Both prototypes sit in gitignored `specs/archive/` | `ls` + `.gitignore` lines 94-97 | CONFIRMED (`specs/archive/` ignored; `specs/evidence/` is not) |
| The gate's insertion point exists | `grep -n` on `scripts/check-evidence-probes.sh` | CONFIRMED: table row at 2170, `WIRED` entry at 2486, array closes at 2492 |
| Gate requires tracked-ness, not mere presence | read `check_probe` at lines 2652-2659 | CONFIRMED: `git ls-files --error-unmatch` after the `[ -f ]` test |
| The one header line to replace | `sed -n '1,12p'` on both prototypes | CONFIRMED: 836B line 5, 838B line 4, identical text |

Two gate-collision conditions from `context/project/lean4/patterns/plan-authoring-gate-collisions.md`
were additionally resolved mechanically at plan time rather than left for the implementer:

- **Condition 1 (coupled generated surface)** does NOT fire. `typst-sync-check.sh`'s
  `formalsystem_line_count` is computed over `BIMODAL_DIR="${REPO_ROOT}/FormalSystem"` (line 91), so
  two new `.lean` files under `specs/evidence/` move no quantity it derives. The `.githooks/pre-commit`
  hook still FIRES (its trigger is "the staged set touches any `.lean` path"), but Check 2 then
  compares an unchanged count and is a no-op pass. No regeneration step is owed, and
  `typst/generated/status.typ` is deliberately NOT in any phase's file scope.
- **Condition 6 (C26 snake_case `def`/`abbrev`)** does NOT fire. `check-module-invariants.sh`'s
  `SCAN_ROOTS` (line 3346) is `["FormalSystem", "BimodalTools", "docs", "typst", "Tests", "scripts",
  "README.md"]` — `specs/` is not among them, so a verbatim promotion carrying the prototypes' own
  snake_case `def` names is safe. No renames are mandated, which is what keeps the promotion verbatim.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context, and `roadmap_flag` is not set;
`specs/ROADMAP.md` was not consulted and is not modified by this plan.

## Goals & Non-Goals

**Goals**:

- Both prototypes exist at tracked, durable paths under `specs/evidence/seam-gluing-ray-product/`,
  byte-identical to their archived originals apart from exactly one header line each.
- `scripts/check-evidence-probes.sh` holds two new `WIRED` entries with their table blocks, and
  reports `PASS  all 60 wired probe(s) compile`, exit 0.
- `RaySummary/README.md`'s two citations name the new wired paths and no longer claim "not a wired
  probe" or route through "the task record".

**Non-Goals**:

- Any change to the refutations themselves, to `(K1)`-`(K4)`, or to the reserved name
  `cellLE_zero_const_of_kappa_eq` (grep-confirmed: neither prototype claims it).
- Pruning the chain lemmas `tight-chain-regime-b.lean` shares with the wired
  `ladder-tight-chain-nonliftability.lean`. That would edit a compiled record to save ~2 s of gate
  time, against the gate's own no-weakening rule.
- Promoting the three further orphan prototypes of the same defect class
  (`838_.../pin-free-side.lean`, `838_.../idle-gap-lengthening.lean`,
  `836_.../cell-obligation-refutation.lean`). No live-library file cites them, so they are outside
  the defect this task repairs. Recorded under Risks so the gap stays visible.
- Refreshing `RaySummary/README.md`'s `*Last verified: 2026-10-13*` stamp. It is already stale before
  this task touches anything, readme-lint Check 4 reports it without gating on it, and refreshing it
  would assert a whole-document verification this task does not perform.
- Force-tracking or in-place editing either archived original. The gate's own failure text names
  force-tracking under `specs/archive/` as the wrong remedy.
- Refreshing the deployed `.claude/` tree (known stale for `core`, `lean`, `sapience`). Pre-existing
  and unrelated to this task's edits.

## Lean Challenge Statements

<!-- lean-challenge-statements:none -->

This plan proves nothing new. Both prototypes are promoted verbatim; no theorem is stated, restated,
or re-proved, so there is no signature to pin.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A sibling task edits `scripts/check-evidence-probes.sh` or `RaySummary/README.md` concurrently (task 929 is dispatched this cycle with no declared `file_scope`) | H | M | Re-read each file immediately before editing; stage only this task's own files by explicit path (never `git add -A`/`.`/a directory pathspec); if a foreign commit or foreign uncommitted modification to either file appears, STOP and report after checking `git log` |
| Live gate baseline is no longer 58 (a sibling wired or unwired a probe since the research run) | M | L | Phase 2 re-measures the baseline live before editing and asserts the delta `+2` against that live number, never against the literal 58 |
| The `.githooks/pre-commit` hook blocks Phase 1's commit on count drift caused by a concurrent writer's uncommitted `.lean` file | M | L | Run `bash scripts/typst-sync-check.sh --counts-only` before committing; a drift whose source is a `FormalSystem/**` file this task never touched is a concurrency finding to report, not a regression to repair, and must not be papered over with `--no-verify` |
| `generate-decidability-inventory.sh --strict --diff` reports two added `REFUTED` probe ids | L | H | Expected and benign: the script is not in CI and is not in this task's VERIFY list. Record the two ids in the summary so a later baseline refresh picks them up |
| `verify-deploy.sh` in Phase 4 reports findings from the stale deployed `.claude/` tree | M | M | Phase 4's criterion is a baseline delta, not a bare exit 0: findings naming only files this plan never touched are pre-existing and are recorded, not repaired. Do not hand-patch `.claude/**` |
| The gate holds the exclusive `.lake/build-guard.lock` for its whole run | L | H | Accepted by design; do not launch a guarded build in parallel with a gate run |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel. Phase 3 depends on Phase 1 (its replacement
text names paths that must exist) but not on Phase 2.

---

### Phase 1: Promote both prototypes into `specs/evidence/seam-gluing-ray-product/` [COMPLETED]

**Goal**: Both compiled records exist at tracked, durable paths, verbatim apart from one header
line each, re-verified against the live tree.

**Tasks**:

- [ ] Re-read both archived originals immediately before copying (concurrency discipline).
- [ ] Copy `specs/archive/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean`
      to `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-regime-b.lean`.
- [ ] Copy `specs/archive/838_two_sided_open_core_pin_free_pigeonhole/prototype/spanning-divisibility.lean`
      to `specs/evidence/seam-gluing-ray-product/ladder-spanning-divisibility.lean`.
- [ ] In EACH promoted copy, replace the single header line
      ``Prototype, compiled standalone with `lake env lean` through the build guard; NOT a wired probe.``
      (836B line 5, 838B line 4 — one occurrence each) with
      ``A wired probe, compiled by `scripts/check-evidence-probes.sh`.``
      Change nothing else.
- [ ] Confirm the diff is exactly that: `diff <archived original> <promoted copy>` shows one changed
      line and nothing more, for each file.
- [ ] Track both promoted files: `git add -- specs/evidence/seam-gluing-ray-product/ladder-tight-chain-regime-b.lean specs/evidence/seam-gluing-ray-product/ladder-spanning-divisibility.lean`
      (explicit file list; the gate's `git ls-files --error-unmatch` test requires tracked-ness, so
      this must precede any gate run).
- [ ] Compile each promoted file individually:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 300 -- env lean <path>`, once per file.
- [ ] Record each file's `#print axioms` output for every headline theorem from that compile, and
      confirm no `sorryAx`, no custom axiom, no `native_decide`.
- [ ] Confirm neither promoted file claims the reserved name:
      `grep -c cellLE_zero_const_of_kappa_eq <each promoted path>` returns 0.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only` and record its result before committing
      (the pre-commit hook will run it; see Risks for the drift-attribution rule).
- [ ] Commit the two promoted files only.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that exactly one header line differs per file, at 836B
line 5 and 838B line 4. Confirm by running `diff` between each archived original and its promoted
copy and reading the full diff — a second differing hunk means the copy was not verbatim and the
phase does not close until it is.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for
`specs/evidence/seam-gluing-ray-product/*.lean` (no shell suite covers it), and the honest covering
check for these paths is the compiler itself:
`bash .claude/scripts/lake-build-guard.sh build --timeout 300 -- env lean <path>` per file, which is
exactly what the evidence gate will later run on them.

**Files to modify**:

- `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-regime-b.lean` - new; verbatim promotion
  of the archived 836B prototype with its one header line rewritten
- `specs/evidence/seam-gluing-ray-product/ladder-spanning-divisibility.lean` - new; verbatim
  promotion of the archived 838B prototype with its one header line rewritten

**Verification**:

- `diff` against each archived original shows exactly one changed line, in the header.
- `lake env lean` through the build guard exits 0 for each promoted file.
- `#print axioms` on every headline theorem of each file shows only a subset of
  `[propext, Classical.choice, Quot.sound]`; no `sorryAx`, no custom axiom, no `native_decide`.
- `git ls-files --error-unmatch` succeeds on both promoted paths.
- `grep -c cellLE_zero_const_of_kappa_eq` returns 0 on each promoted file.
- Neither archived original is modified: `git status --short` shows no change under `specs/archive/`
  (and would not, since that tree is gitignored — confirm on disk with `diff` against a reference
  copy or by checking mtimes).

---

### Phase 2: Wire both probes into `scripts/check-evidence-probes.sh` [COMPLETED]

**Goal**: The evidence gate holds both promoted records, and reports two more passing probes than
the live pre-edit baseline with no other probe disturbed.

**Tasks**:

- [ ] Re-read `scripts/check-evidence-probes.sh` immediately before editing (concurrency discipline).
- [ ] Capture the LIVE baseline first: run `bash scripts/check-evidence-probes.sh`, record its wired
      pass count and exit code, and save the full per-probe output for the later row-by-row diff.
- [ ] Add two table blocks in the comment table above `WIRED=(`, immediately after the
      `seam-gluing-ray-product/lowering-anchor-deficit` block (which begins at line 2170 as of plan
      time — locate it by `grep -n`, not by the literal line number). Match the file's fixed column
      format: `# ` + probe id, padded so the `|` sits at column 61, description from column 63,
      wrapped at roughly column 100. Each row states the decision the probe holds in place and closes
      with its measured axiom profile, as the neighbouring rows do.
- [ ] Add two `WIRED` array entries immediately after `"seam-gluing-ray-product/lowering-anchor-deficit"`:
      `"seam-gluing-ray-product/ladder-tight-chain-regime-b"` and
      `"seam-gluing-ray-product/ladder-spanning-divisibility"`.
- [ ] Keep both entries in `WIRED`, not `WIRED_REPO`: `WIRED_REPO` exists only for a probe with a
      named promotion blocker, and neither of these has one.
- [ ] Do NOT edit the table's C9-exempt status or name any `specs/NNN_slug/` path in the README later;
      the gate script itself is excluded from the C9 scan, so a table block may name the archived
      origin.
- [ ] Re-run `bash scripts/check-evidence-probes.sh` and diff its per-probe output against the
      captured baseline, row by row.
- [ ] Commit `scripts/check-evidence-probes.sh` only.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts the wired pass count rises by exactly two and that the
live baseline is 58 (`PASS  all 58 wired probe(s) compile`, measured during research). Confirm by
capturing the baseline live in this phase's FIRST task, before any edit, and asserting the delta
against that captured number — never against the literal 58, which a sibling task could have moved.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for
`scripts/check-evidence-probes.sh` (no shell suite covers it); the covering check is the script's own
consumer run, `bash scripts/check-evidence-probes.sh`, which compiles every wired probe across all
collections and is the only consumer of the `WIRED` array this edit feeds.

**Files to modify**:

- `scripts/check-evidence-probes.sh` - two comment-table blocks and two `WIRED` array entries

**Verification**:

- `bash scripts/check-evidence-probes.sh` exits 0 and reports a wired pass count exactly two higher
  than the baseline captured in this phase's first task.
- Row-by-row diff of the gate output against that baseline shows exactly two added rows and no other
  probe's row changed.
- Both new entries appear in `WIRED`, neither in `WIRED_REPO`, and the `DEFERRED` entry is untouched.

---

### Phase 3: Rewrite the two README citations [COMPLETED]

**Goal**: `RaySummary/README.md` cites each refutation's wired probe by its new tracked path, with
the "not a wired probe" qualifier and the "in the task record" framing both gone.

**Tasks**:

- [ ] Re-read `FormalSystem/Metalogic/Decidability/RaySummary/README.md` immediately before editing
      (concurrency discipline).
- [ ] Locate both citations by content, not by line number:
      `grep -n 'tight-chain-regime-b\|spanning-divisibility' FormalSystem/Metalogic/Decidability/RaySummary/README.md`.
- [ ] Replace the first parenthetical (currently spanning lines 1001-1003: "the\nstandalone prototype
      `tight-chain-regime-b.lean` in the task record that landed this layer, not\na wired probe") with
      a reference to the wired probe
      ``specs/evidence/seam-gluing-ray-product/ladder-tight-chain-regime-b.lean``.
- [ ] Replace the second parenthetical (currently spanning lines 1038-1039: "(The standalone prototype\n
      `spanning-divisibility.lean` in the task record, not a wired probe.)") with the same shape for
      ``specs/evidence/seam-gluing-ray-product/ladder-spanning-divisibility.lean``.
- [ ] Use a BACKTICKED path, never a `[text](path)` markdown link: readme-lint Check 3 and C13 parse
      only markdown links, and the surrounding README prose already uses backticked paths.
- [ ] Re-wrap each touched paragraph to the file's existing wrap width so the diff stays confined to
      the rewritten sentences.
- [ ] Confirm the replacement text introduces no `task N` or `specs/NNN_slug/` shape (C9) and no
      `FormalSystem|Boneyard|Tests|Logos|Bimodal`-rooted slash path (C12).
- [ ] Do not touch the `*Last verified:*` stamp (see Non-Goals).
- [ ] Run `bash scripts/readme-lint.sh`, `bash .claude/scripts/check-task-references.sh --quiet`, and
      `bash scripts/check-module-invariants.sh --no-build`.
- [ ] Commit `FormalSystem/Metalogic/Decidability/RaySummary/README.md` only.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the two citations sit at README.md:1002 and README.md:1039
and that exactly two live-library citation sites exist. Confirm by re-running the grep in this
phase's second task: a count other than two, or line numbers that have moved, means a sibling has
edited the README and the edit is re-sited against live content before proceeding.

**Tier Justification**: `bash scripts/readme-lint.sh` plus
`bash scripts/check-module-invariants.sh --no-build` are this repository's only checks that read
`RaySummary/README.md`'s prose (readme-lint Check 3; C9, C12, C13), while `suite_selection_select`
on this phase's touched path returns only agent-system shell suites — `test-check-record-versioning.sh`,
`test-check-task-references.sh`, `test-dispatch-worktree.sh`, `test-gate3-parallel-equivalence.sh`,
`test-gate3-strict-equivalence.sh`, `test-gate-cache-equivalence.sh`, `test-index-entries-schema.sh`,
`test-lean-src-roots.sh`, `test-lint-agent-contracts.sh`, `test-lint-dead-command-recommendations.sh`,
`test-lint-extension-readme-table.sh`, `test-manifest-scripts-sync.sh`, `test-orchestrate-batch-admit.sh`,
`test-plan-file-scope-harvest.sh`, `test-record-version-patterns.sh`, `test-script-inventory.sh`,
`test-validate-state.sh` — none of which range over `FormalSystem/**` content, so the repository
gates above are the covering checks and the full suite set is deferred to Phase 4.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - two citation parentheticals rewritten
  to name the new wired paths

**Verification**:

- `grep -n 'tight-chain-regime-b\|spanning-divisibility'` on the README returns exactly two hits,
  both naming a `specs/evidence/seam-gluing-ray-product/ladder-*.lean` path.
- Neither hit retains "not a wired probe" or "in the task record".
- `bash scripts/readme-lint.sh` exits 0.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- `bash scripts/check-module-invariants.sh --no-build` reports no new C9/C12/C13 finding naming this
  README.

---

### Phase 4: Full gate set and task-level verification [NOT STARTED]

**Goal**: Every VERIFY criterion the task description names is measured green on the assembled tree,
with any pre-existing finding separated from this task's own edits.

**Tasks**:

- [ ] Re-run `bash scripts/check-evidence-probes.sh` on the assembled tree; confirm exit 0 and the
      `+2` delta against the Phase 2 baseline still holds.
- [ ] Re-run `#print axioms` verification for every headline theorem of both promoted files (via the
      gate's own compile output or a per-file `lake env lean` run); confirm no `sorryAx`, no custom
      axiom, no `native_decide`.
- [ ] Run `bash scripts/readme-lint.sh`; confirm exit 0.
- [ ] Run `bash .claude/scripts/check-task-references.sh --quiet`; confirm exit 0.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build`; confirm no new finding naming any file
      this plan touched.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only`; confirm no drift attributable to this
      task (the task moves no `FormalSystem/**` line count).
- [ ] Run `bash .claude/scripts/verify-deploy.sh` and record its findings as a DELTA: enumerate any
      finding that names a file this plan touched (these are this task's to fix) separately from
      findings that name only untouched files or the known-stale deployed `core`/`lean`/`sapience`
      extensions (these are pre-existing and are recorded, not repaired).
- [ ] Record the two new `REFUTED` probe ids that `generate-decidability-inventory.sh --strict --diff`
      would report, for a future baseline refresh. Do not refresh that baseline here.
- [ ] Confirm `git status --short` carries no stray artifact of the work (no trial copy of the gate
      script, no scratch file under `scripts/`).
- [ ] Commit any remaining task artifact; write the summary.

**Timing**: 0.75 hours

**Depends on**: 2, 3

**Verification Tier**: full

**Files to modify**:

- (none — verification only; the summary artifact under
  `specs/930_wire_orphan_open_core_prototypes/summaries/` is written by postflight)

**Verification**:

The complete gate set, every item measured and recorded, none projected:

- `bash scripts/check-evidence-probes.sh` — exit 0, wired pass count `baseline + 2`, no other probe
  row changed.
- `#print axioms` on every headline theorem of both promoted files — no `sorryAx`, no custom axiom,
  no `native_decide`.
- `bash scripts/readme-lint.sh` — exit 0.
- `bash .claude/scripts/check-task-references.sh --quiet` — exit 0.
- `bash scripts/check-module-invariants.sh --no-build` — no new finding naming a touched file.
- `bash scripts/typst-sync-check.sh --counts-only` — no drift attributable to this task.
- `bash .claude/scripts/verify-deploy.sh` — findings enumerated as a delta against the standing
  baseline, with pre-existing and deploy-staleness findings named explicitly rather than folded into
  a bare pass/fail.

## Testing & Validation

- [ ] Both promoted files compile individually through the build guard (`lake env lean`, exit 0).
- [ ] Both promoted files are tracked by git (`git ls-files --error-unmatch` succeeds).
- [ ] The evidence gate exits 0 with the wired pass count raised by exactly two.
- [ ] No other probe's gate row changed relative to the pre-edit baseline.
- [ ] Every headline theorem of both files shows no `sorryAx`, no custom axiom, no `native_decide`.
- [ ] `readme-lint.sh` and `check-task-references.sh --quiet` each exit 0.
- [ ] Neither archived original was modified, and neither was force-tracked.
- [ ] The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing in either promoted file.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-regime-b.lean` (new, tracked)
- `specs/evidence/seam-gluing-ray-product/ladder-spanning-divisibility.lean` (new, tracked)
- `scripts/check-evidence-probes.sh` (two table blocks, two `WIRED` entries)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (two citations rewritten)
- Recorded measurements: per-file compile times and axiom profiles, the gate's pre-edit and post-edit
  wired pass counts, and the two `REFUTED` probe ids a decidability-inventory baseline refresh will
  need.

## Rollback/Contingency

Each phase commits independently, so rollback is per-phase and by commit, never by discarding an
uncommitted tree.

- **A promoted file fails to compile against the live tree** (contradicting the research
  measurement): STOP. Record the goal state and the exact error, mark the phase `[BLOCKED]`, and
  report it. Do NOT weaken, restate, or delete the obstruction to make it pass — that is the gate's
  own no-weakening rule, and a genuine compile failure would mean a README authority claim is stale,
  which must be surfaced rather than absorbed.
- **The gate reports a count other than `baseline + 2`, or another probe's row changes**: revert the
  Phase 2 edit to `scripts/check-evidence-probes.sh` by committing its inverse (or
  `git revert` the phase commit); do not leave a partially wired array.
- **A foreign commit or foreign uncommitted modification appears on a touched file**: STOP and report
  after confirming via `git log` that the work is not this task's own. Do not merge, overwrite, or
  dismiss it.
- **Before any intentional rollback that would otherwise be blocked by the destructive-git guard**:
  `bash .claude/scripts/git-snapshot.sh 930` first. For an ordinary defensive checkpoint (not a
  rollback), use `bash .claude/scripts/git-snapshot.sh 930 --no-revert` instead.
