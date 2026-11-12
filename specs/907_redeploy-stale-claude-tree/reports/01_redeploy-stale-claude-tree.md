# Research Report: Task #907

**Task**: 907 - Redeploy-stale-claude-tree
**Started**: 2026-11-12T13:30:00Z
**Completed**: 2026-11-12T13:39:00Z
**Effort**: small (single bounded script run + verification)
**Dependencies**: Recurrence of the condition addressed by closed task 715
**Sources/Inputs**:
- Codebase: `.claude/scripts/deploy-headless.sh`, `.claude/scripts/verify-deploy.sh`,
  `.claude/scripts/lib/deploy-freshness-lib.sh`, `.claude/scripts/check-deploy-freshness.sh`,
  `.claude/scripts/skill-base.sh`
- Live command execution (deploy + verification), not external research
**Artifacts**:
- `specs/907_redeploy-stale-claude-tree/reports/01_redeploy-stale-claude-tree.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Ran `timeout 540 bash .claude/scripts/deploy-headless.sh` (bounded-wait idiom, Bash tool
  timeout raised to 600000ms). It resynced 7 extensions into
  `/home/benjamin/Projects/BimodalLogic/.claude` and its inline `verify-deploy.sh --skip-slow`
  pass reported `PASS -- 15 check(s), 0 failure(s)`; final line
  `[deploy-headless] RESULT=landed_verify_clean`.
- Directly queried the staleness algorithm (`deploy_freshness_status` in
  `.claude/scripts/lib/deploy-freshness-lib.sh`) for all six extensions named in the task
  description (core, formal, lean, literature, memory, typst): all six now report `FRESH`.
- Ran `check-deploy-freshness.sh` (the advisory CHECKPOINT 1 consumer) directly: it exits 0
  with no WARN output, confirming the per-extension staleness warning described in
  `skill-base.sh` (the `skill_deploy_freshness_stale_names` / WARN block) no longer fires.
- No source file under `.claude/**` was hand-patched; the only mechanism used was the sanctioned
  regeneration path (`deploy-headless.sh`), consistent with the dispatch's explicit prohibition.
- `.claude/` and `.claude-extensions.json` are both gitignored (`.gitignore` lines 81, 106), so
  the redeploy produces no tracked git diff — `git status --porcelain` after the redeploy shows
  only pre-existing, unrelated changes (`specs/TODO.md`, `specs/events.jsonl`, `specs/state.json`
  modifications, and untracked `.pid` / `specs/evidence/...` / this task directory).
- This is a recurrence of the condition closed by task 715; no further code change is
  recommended — the fix is operational (run the redeploy), which this dispatch has now done.

## Context & Scope

Two prior dispatches (research/implementation work on other tasks) reported the deployed
`.claude/` tree in this repository as stale relative to the source store
(`agent-system/extensions/`) for six extensions: core, formal, lean, literature, memory, typst.
This dispatch's own injected `<deploy-freshness-context>` block (captured at dispatch-build
time, before this dispatch ran) named only two of those six as currently stale: core and lean —
consistent with the staleness condition narrowing between when the two prior dispatches ran and
when this dispatch's context was assembled, not a discrepancy in this dispatch's own findings.

The scope of this phase was narrow and mechanical: (1) run the sanctioned redeploy script under
the bounded-wait idiom, (2) verify the deploy succeeded, (3) confirm the per-extension staleness
warning no longer fires for any of the six named extensions, and (4) confirm neither reporting
dispatch depended on a stale deployed command (per the dispatch description, stating this is
already true and needs no corrective redo). No hand-patching of `.claude/**` was in scope or
performed — the dispatch explicitly prohibits that as it would mask divergence rather than fix
it.

## Findings

### Codebase Patterns

- **Deploy engine**: `deploy-headless.sh` drives the manifest-driven extension loader
  (`neotex.plugins.ai.shared.extensions.init`'s `manager`) headlessly via Neovim. Default
  (no-flag) mode is non-destructive: force-loads `core`, then force-resyncs every other
  currently-active extension via `manager.resync_all`. This run resynced 7 extensions.
- **Verification gate**: `verify-deploy.sh` runs 29 numbered gates against the target repo.
  Gates 3, 5, 6, 7, 9–13, 15, 17–29 all `[SKIP]` here because this repository is a deploy
  *consumer*, not the source store (`agent-system/extensions/` does not live at this repo
  root) — this is expected and does not indicate incomplete verification; those gates compare
  the deployed tree against a co-located source store, which only exists in the system's own
  source repository. The gates that do apply to a consumer repo (event/error store file
  presence, hook registration, task-reference lint, runtime-file tracking policy, the
  `routing_hard`/`routing_agents_hard` absence guard) all `[PASS]`ed: 15 checks, 0 failures.
  `verify-deploy.sh`'s own header is explicit that a PASS here certifies deployment and hook
  registration only, not that the redeployed machinery has since been exercised by real command
  invocations — a narrower claim than "the system now works end-to-end," and this report makes
  no broader claim than that narrower one.
- **Staleness algorithm** (`deploy-freshness-lib.sh`): for each extension entry in
  `.claude-extensions.json` carrying both `source_dir` and `source_git_head`, it recomputes the
  path-scoped source-store revision (`git log -1 --format=%H -- <source_dir>` against the
  enclosing source-store repo's toplevel) and compares against the recorded value. Three-way
  result per extension: `STALE`, `FRESH`, or `CANNOTVERIFY` (silent on any failure mode —
  missing file, missing jq/git, missing fields, non-git source_dir, empty recomputed revision —
  by design, so "cannot verify" never reads as either a false-fresh or a false-alarm).
- **Warning emission site**: `skill-base.sh` lines ~468-473 call
  `skill_deploy_freshness_stale_names` (a thin wrapper around `deploy_freshness_stale_names`)
  once per skill/agent dispatch, immediately before a stale instruction file would be read, and
  emits three `WARN:` lines to stderr naming the stale extensions plus the redeploy remedy — a
  non-blocking advisory, never a hard failure.
- **Verification performed**: direct shell invocation of `deploy_freshness_status
  "<repo_root>" "<ext>"` for core, formal, lean, literature, memory, typst — all six returned
  `FRESH`. Separately, running `.claude/scripts/check-deploy-freshness.sh` (the advisory
  CHECKPOINT-1 consumer wrapping the same library) produced no WARN output and exited 0,
  confirming the same conclusion through the actual consumer surface rather than only the
  library primitive.
- No file under `.claude/**` was edited by hand at any point in this dispatch; the redeploy ran
  twice (once as the primary fix, once as an idempotency check) and both runs reported
  `RESULT=landed_verify_clean` with identical PASS counts, which is the expected signature of a
  clean, repeatable regeneration rather than a one-off fluke.

### External Resources

None consulted — this is a local, mechanical operational task fully resolved by the codebase's
own scripts; no web research was needed or performed.

## Decisions

- Used the default (non-destructive) `deploy-headless.sh` mode, not `--wipe` — the staleness
  condition here is "source store moved ahead of the recorded resync," which `manager.resync_all`
  is designed to close; nothing suggested divergence requiring a full wipe-and-reload.
- Verified freshness via two independent surfaces (the library's `deploy_freshness_status`
  queried directly for all six named extensions, and the actual `check-deploy-freshness.sh`
  consumer script) rather than trusting `deploy-headless.sh`'s own bundled
  `verify-deploy.sh --skip-slow` pass alone, since that bundled pass does not itself probe
  `deploy_freshness_status` — it checks deploy-tree completeness and hook registration, a
  different gate than extension-level source-store freshness.
- Did not re-run `verify-deploy.sh` without `--skip-slow` (the full shell test suite): out of
  scope for this phase, which targets the specific staleness symptom named in the dispatch, and
  the dispatch's own remedy text names only the `--skip-slow` inline pass as the required
  verification step.

## Recommendations

- No further code or configuration change is recommended for this occurrence: the fix was
  purely operational (running the existing, sanctioned `deploy-headless.sh`), and it is now
  verified complete for all six named extensions.
- This is an explicitly acknowledged recurrence of the condition closed by task 715. If this
  staleness condition continues to recur across tasks, a follow-up worth considering (not
  undertaken here, as it is out of this phase's narrow scope) is whether the inter-cycle redeploy
  checkpoint described in `context/patterns/batch-orchestration-guardrails.md`'s "The
  Inter-Cycle Redeploy Checkpoint" section is firing as often as intended, or whether its
  trigger condition should be tightened. This is a process-cadence question, not a defect in the
  redeploy mechanism itself, which worked correctly here.

## Risks & Mitigations

- **Risk**: hand-patching a deployed `.claude/**` file to silence the staleness WARN, masking
  real divergence from the source store. **Mitigation**: not done; the dispatch explicitly
  prohibits it, and the sanctioned `deploy-headless.sh` regeneration path was used instead.
- **Risk**: declaring "fixed" based only on the bundled `verify-deploy.sh --skip-slow` pass,
  which does not itself assert extension-level freshness. **Mitigation**: freshness was verified
  through two additional, independent surfaces (direct library query and the actual
  `check-deploy-freshness.sh` consumer), both confirming FRESH/silent-no-WARN for all six named
  extensions.
- **Risk**: the deploy tree verifying as current immediately after regeneration but recurring
  stale again before this task's postflight commits, if another writer concurrently touches the
  source store. **Mitigation**: none applied beyond the two closely-spaced verification runs
  performed here (deploy, then a second idempotent redeploy run both landing
  `RESULT=landed_verify_clean`); a window of this kind, if it matters, is a concern for the
  orchestrator's own redeploy-checkpoint cadence, not for this single dispatch.

## Context Extension Recommendations

None. The relevant mechanisms (`deploy-headless.sh`, `verify-deploy.sh`,
`deploy-freshness-lib.sh`, `check-deploy-freshness.sh`, and `skill-base.sh`'s WARN emission site)
are already well-documented in their own file headers and in
`context/patterns/batch-orchestration-guardrails.md`'s inter-cycle redeploy checkpoint section;
no gap was identified during this research.

## Appendix

Commands run (in order):
```
timeout 540 bash .claude/scripts/deploy-headless.sh          # primary redeploy, RESULT=landed_verify_clean
timeout 540 bash .claude/scripts/deploy-headless.sh          # idempotency re-check, RESULT=landed_verify_clean
source .claude/scripts/lib/deploy-freshness-lib.sh
deploy_freshness_status "<repo_root>" core        # FRESH
deploy_freshness_status "<repo_root>" formal      # FRESH
deploy_freshness_status "<repo_root>" lean        # FRESH
deploy_freshness_status "<repo_root>" literature  # FRESH
deploy_freshness_status "<repo_root>" memory      # FRESH
deploy_freshness_status "<repo_root>" typst       # FRESH
bash .claude/scripts/check-deploy-freshness.sh    # exit 0, no WARN output
```

References:
- `.claude/scripts/deploy-headless.sh` (deploy engine, mode documentation in header comment)
- `.claude/scripts/verify-deploy.sh` (29-gate verification, consumer-vs-source-store SKIP logic)
- `.claude/scripts/lib/deploy-freshness-lib.sh` (`deploy_freshness_stale_names`,
  `deploy_freshness_status` — the staleness algorithm)
- `.claude/scripts/check-deploy-freshness.sh` (advisory CHECKPOINT 1 consumer)
- `.claude/scripts/skill-base.sh` (lines ~468-473, the per-dispatch WARN emission site)
- `context/patterns/batch-orchestration-guardrails.md` ("The Inter-Cycle Redeploy Checkpoint")
