# Implementation Summary: Task #940

- **Task**: 940 - Fix the API Documentation runner OOM: the LEAN_NUM_THREADS route is refuted by a pushed run, and the failure is a process-spawn ENOMEM, not heap exhaustion.
- **Status**: [COMPLETED]
- **Started**: 2026-11-19T16:27:41Z
- **Completed**: 2026-11-19T17:48:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/02_docgen-cache-gate-fix.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Implemented the five-phase plan for `.github/workflows/docs.yml`, confined entirely to that one
file. Added in-run memory/overcommit instrumentation around the docgen step, removed the
measured-refuted `LEAN_NUM_THREADS: "1"` env entry, added an independently-gated
`actions/cache/save` step that breaks `docgen-action`'s own internal `post-if: "success()"`
cache gate (the gate that has kept the Mathlib-docs cache permanently empty), and rewrote the
file's header comment to state measured reality instead of the refuted account it previously
carried. Each phase landed as its own verified-green commit.

## What Changed

- `.github/workflows/docs.yml` — added "Record pre-docgen memory and overcommit state" (with a
  detached background sampler) and "Report docgen memory trace" (`if: always()`) steps; removed
  the `LEAN_NUM_THREADS: "1"` `env:` block from the docgen step; added "Persist the Mathlib docs
  cache even when the doc build fails" (`actions/cache/save@5a3ec84...` pinned to `v4.2.3`,
  `if: always()`, `continue-on-error: true`, key
  `Docs-${{ hashFiles('lake-manifest.json', 'references.bib') }}`, and the verbatim 41-entry
  `path:` list recovered from run 44492038639's log); rewrote the leading comment block to state
  the spawn-vs-heap distinction, the cache-gate root cause, the four measured-closed routes with
  their evidence, the two-run convergence expectation, and the conditional escalation ladder.

## Decisions

- Measured (not acted on) the overcommit/fork-refusal hypothesis: Phase 1's instrumentation logs
  `Committed_AS`/`CommitLimit`/overcommit sysctls read-only, deliberately not mutating them in
  this round so the next run's trace is a clean, unconfounded measurement.
- Chose the cache-save route over fan-out reduction, a forked docgen-action, or a CLI-bypass:
  additive, reversible, and the only candidate directly confirmed from this repository's own run
  logs (the `post-if: "success()"` gate and the `hashFiles` key reproduction).
- Removed `LEAN_NUM_THREADS` outright rather than leaving it inert or lowering it, per the
  dispatch's explicit instruction to decide.

## Plan Deviations

- None (implementation followed plan). One correction surfaced during Phase 3's re-verification
  and is recorded in the plan's checklist annotations and as an issue-log `win` entry: the
  `hashFiles` cache-key reproduction requires concatenating the two files' sha256 digests as raw
  bytes, not hex strings — a hex-string attempt first produced a non-matching key.

## Verification

- Build: N/A (no Lean build touched)
- Tests: N/A (GitHub Actions workflow file; no repository test suite covers this path)
- Files verified: Yes — `.github/workflows/docs.yml` parses under `yaml.safe_load` after every
  phase; each new `run:` body passes `bash -n`; the cache key reproduces exactly
  (`a123379d6db94f6a6c99fecd852af470f05772553661bc654a4c62dbce0f7b9d`); the `actions/cache`
  SHA pin resolves to tag `v4.2.3` and matches `docgen-action`'s own `5a3ec84` prefix; the
  `path:` entry count (41) matches the live log; `actionlint` ran clean (exit 0, one
  intentional info-level shellcheck note); `bash .claude/scripts/verify-deploy.sh` (complete
  gate set) ran green in this dispatch — PASS, 12 checks, 0 failures; the final `git status
  --short` shows no unintended residue from this task's own edits; no `git push`, `gh pr
  create`, or `/merge` was invoked.

**Objective status is explicitly NOT met.** The process-spawn ENOMEM is a property of the
hosted GitHub Actions runner and cannot be reproduced or verified locally — only a real pushed
`API Documentation` run can confirm it. This mirrors the predecessor effort's calibration
failure (claiming success on upstream precedent alone, which a real run then contradicted) and
this implementation deliberately avoids repeating it.

## Impacts

- The next `API Documentation` run after this commit is expected to still be cold and may still
  fail, but will for the first time populate the Mathlib/dependency docs cache (watch: the
  "Persist the Mathlib docs cache even when the doc build fails" step completes rather than
  reporting `outcome=skipped`; the new memory trace prints).
- The run after that should restore the cache and shrink doc-gen4's external-process fan-out to
  `FormalSystem`'s own modules (watch: a `Cache restored from key: Docs-a123379d...` line, and a
  materially shorter docgen step wall-clock than the 13m20s seen in run 44492038639).
- If a warm-cache run still OOMs on `FormalSystem`'s own fan-out, the header comment documents
  the next step: read the memory trace, and only if `Committed_AS` approaches `CommitLimit` at
  failure, add a `sudo sysctl -w vm.overcommit_memory=1` step; otherwise escalate to the
  `linglib-community/linglib` CLI-bypass precedent (driving `doc-gen4`'s `single`/`fromDb`
  subcommands directly with an explicit `xargs -P N`).

## Follow-ups

- The user's remaining step is to push this commit and watch the next two `API Documentation`
  runs for the success signals named above in Impacts/Verification.
- If the cache-save route proves insufficient even with a warm cache, the escalation ladder in
  the workflow's own header comment names the next two candidates in order (conditional
  overcommit sysctl, then the CLI-bypass rewrite) — neither is implemented in this round.

## References

- Plan: `specs/940_fix_api_docs_oom_process_spawn_enomem/plans/02_docgen-cache-gate-fix.md`
- Research: `specs/940_fix_api_docs_oom_process_spawn_enomem/reports/01_process_spawn_enomem_cache_gate.md`
- Workflow: `.github/workflows/docs.yml`
- Phase handoffs: `specs/940_fix_api_docs_oom_process_spawn_enomem/handoffs/phase-{1..5}-handoff-*.md`
- Commits: `bfe22eb21`, `8a1b4a16e`, `031f77805`, `2d7f2497f`, `b6254ec47`
