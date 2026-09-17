# Implementation Summary: Task #586

**Task**: 586 - Rewrite typst proof-automation chapter against the retired-tactics tree
(widened: all non-`docs/` retired-tactic prose; final phase: CI wiring of
`typst-sync-check.sh`)
**Plan**: `specs/586_rewrite_typst_proof_automation_chapter/plans/02_proof-automation-chapter-rewrite.md`
**Status**: [COMPLETED] (all 4 phases)

## What was built

### Phase 1 — Module-map generator and Check 2 extension
- `scripts/typst-module-map.sh`: a build-free generator (no `lake`/`lean` invocation) that globs
  `FormalSystem/Automation/{Tactics,ProofSearch}/*.lean` and `SuccessPatterns.lean` (excluding
  any `Boneyard/` subtree) and emits `(path, lines, sorry_free)` rows. `--json` mode feeds
  `typst-sync-check.sh`; default mode writes `typst/generated/automation-module-map.typ`.
- Extended `scripts/typst-sync-check.sh` Check 2 with a module-map sub-check ("Check 2b") diffing
  the committed generated file against a live regeneration.
- Recorded the machine-generation decision in `typst/SYNC-MAP.md`.

### Phase 2 — Rewrite the proof-automation chapter
- Full rewrite of `typst/chapters/p4-proof-automation.typ` against the live `Automation/` tree:
  the correct tactic surface (`Tactics/{UserTactics,Commands,Deduction,PropDecide}.lean`), the
  Aesop integration replaced with a past-tense retirement note (citing
  `Boneyard/RetiredTactics/README.md`), and — the load-bearing correction the planner flagged —
  the tactic search engine (`Tactics/Search.lean`) and the `ProofSearch/` engine now described as
  two distinct engines with different callers, rather than as one engine the old chapter
  conflated. The Module Map table now renders from Phase 1's generated data via an
  assert-guarded `roles` dictionary lookup, so a renamed/added/removed module fails loudly at
  `typst compile` time instead of drifting silently.
- Removed the two orphaned `@[aesop norm unfold]`/`@[aesop safe forward]` whitelist entries after
  confirming (grep) the chapter was their sole consumer.

### Phase 3 — Widened retired-tactic prose outside the chapter
- Fixed the four remaining live-tree present-tense mentions: `p4-dual-verification.typ`'s
  decide-workflow bullet, `Automation/README.md`'s `Tactics/` directory row and usage example,
  and `ProofSearch/README.md`'s integration-point claim, "Used by" line, and stale module-table
  counts (also correcting a second false claim there: the engine is reached from `decide`'s
  fast path, not from `modal_search`).
- Chose to hand-fix `ProofSearch/README.md`'s table rather than convert it to the
  `<!-- BEGIN GENERATED -->` marker convention, because `--emit-inventory` has no per-file
  scoping and would have written to files other concurrently-running tasks were actively
  editing in this shared working tree — a real write-race risk, not merely a broader diff.

### Phase 4 — Wire typst-sync-check.sh into CI
- Verified `typst-sync-check.sh` exits 0 on a **fresh checkout** (via detached `git worktree`,
  not the always-populated local dev tree), which surfaced two genuine CI-breaking gaps unrelated
  to retired tactics: a `data/` directory reference with zero tracked files (fixed with a
  whitelist entry) and a `lakefile.toml` citation that Check 1's path-like detection didn't
  recognize because `.toml` was missing from its suffix list (fixed at the root cause in
  `typst-sync-check.sh` itself, since a whitelist entry would not generalize to future `.toml`
  citations).
- Added the `Typst sync check (scripts/typst-sync-check.sh)` step to `.github/workflows/ci.yml`,
  directly before `Report results`, following the established wiring convention exactly.
- Updated `docs/development/CI_CD_PROCESS.md` (wired-scripts list, Runtime Budget table row).
- Mutation-tested the gate (reintroduced a bare, non-`Boneyard/`-qualified `AesopRules.lean`
  citation; confirmed Check 1 catches it; reverted cleanly).

## Verification (final)

- `bash scripts/typst-sync-check.sh`: exits 0 on the committed tree (confirmed via a detached
  worktree checkout at HEAD, bypassing all local working-tree noise).
- `typst compile typst/BimodalReference.typ`: succeeds (pre-existing font warnings only).
- Every module named in the rewritten chapter resolves to a live file with a matching `wc -l`
  (guaranteed by the generated-data rendering; Check 1's 0 violations independently confirms
  every backticked path resolves).
- No archived declaration (`tm_auto`, `temporal_search`, `propositional_search`,
  `AesopRules.lean`, `Tactics/Helpers.lean`) is described in the present tense outside `docs/`
  and `Boneyard/` (re-grepped repo-wide, excluding `docs/`/`Boneyard/`/`specs/`/`.claude/`/
  `agent-system/`; all remaining hits are past-tense).
- The chapter correctly distinguishes the tactic engine (`Tactics/Search.lean`) from the
  `ProofSearch/` engine `decide` reaches for.
- `bash scripts/readme-lint.sh`: `RESULT: PASS`.
- `bash scripts/check-module-invariants.sh --no-build`: not fully green at the whole-repo level
  (`FAIL INV 2 file(s) carry a stale generated inventory block`), but isolated via direct `wc -l`
  comparison to line-count drift in six files this task never touched, caused by other tasks
  (578/584/590/591/602/etc.) concurrently sharing this working tree. See the Phase 3 handoff for
  the full isolation evidence.
- `bash .claude/scripts/typst-element-lint.sh --verbose` on every `.typ` file touched by this
  task (`typst/generated/automation-module-map.typ`, `typst/chapters/p4-proof-automation.typ`,
  `typst/chapters/p4-dual-verification.typ`): PASS, 0 remarks, 0 placement failures.
- Decision recorded in `typst/SYNC-MAP.md`; CI step present in `.github/workflows/ci.yml`.

## Plan Deviations

- **Phase 3**: chose to hand-fix `ProofSearch/README.md`'s module table rather than convert it
  to the `<!-- BEGIN GENERATED -->` marker convention (plan offered either as acceptable),
  because of the write-race risk explained above. Recorded in the Phase 3 handoff.
- **Phase 4**: two additional fixes not named in the plan, both necessary to make the plan's own
  stated gate condition ("once it exits 0") actually true on a clean checkout rather than just
  the local dev tree: a `data/` whitelist entry, and a `.toml` suffix added to Check 1's
  path-like detection in `scripts/typst-sync-check.sh`. Both documented with full reasoning in
  the Phase 4 handoff and its addendum; neither is a "whitelist is not the fix" evasion of this
  task's own retired-tactic violations (a different concern from a different file), and both are
  root-cause or narrowly-justified fixes rather than papering over anything.
- No other deviations. The M4-claim softening and the `deduction`/`propDecide` additions in
  Phase 2 were both explicitly anticipated by the plan's own wording.

## Files touched (all phases)

- `scripts/typst-module-map.sh` (new)
- `typst/generated/automation-module-map.typ` (new)
- `scripts/typst-sync-check.sh` (Check 2b module-map sub-check; `.toml` path-like fix)
- `typst/SYNC-MAP.md` (decision record)
- `typst/chapters/p4-proof-automation.typ` (full rewrite)
- `typst/sync-check-whitelist.txt` (orphaned Aesop entries removed; `data/` entry added)
- `typst/chapters/p4-dual-verification.typ` (one-word fix)
- `FormalSystem/Automation/README.md` (two prose fixes + stamp bump)
- `FormalSystem/Automation/ProofSearch/README.md` (integration claim, Used-by, module table,
  stamp bump)
- `.github/workflows/ci.yml` (new CI step; landed via a concurrent commit, see Phase 4 handoff)
- `docs/development/CI_CD_PROCESS.md` (wired-scripts list, runtime budget row)

## Handoffs

- `specs/586_rewrite_typst_proof_automation_chapter/handoffs/phase-1-handoff-20260917-011539.md`
- `specs/586_rewrite_typst_proof_automation_chapter/handoffs/phase-2-handoff-20260917-013500.md`
- `specs/586_rewrite_typst_proof_automation_chapter/handoffs/phase-3-handoff-20260917-014800.md`
- `specs/586_rewrite_typst_proof_automation_chapter/handoffs/phase-4-handoff-20260917-020500.md`
