# Research Report: Task #993

**Task**: 993 - Declare integration_branch in .claude-extensions.json so that orchestration admission arms instead of falling back
**Started**: 2026-11-24
**Completed**: 2026-11-24
**Effort**: small (single-key JSON edit plus a falsification check)
**Dependencies**: None
**Sources/Inputs**:
- `.claude-extensions.json` (current state: exactly `extensions`, `version`)
- `.claude/context/standards/repo-level-declarations.md` (`integration_branch`/`worktree_isolation` sections)
- `.claude/scripts/lib/batch-admission-lib.sh` (the consumer, read in full)
- `.claude/context/standards/git-workflow-narrative.md` (Branch Strategy section)
- `git branch -a`, `git reflog show dev/m7-ladder-continuation`, `git log --all --oneline`
- A disposable synthetic git repo under the session scratchpad, used to exercise
  `batch_admission_evaluate` directly (admit / off_integration_branch / dirty_primary_tree)
**Artifacts**:
- This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The consumer (`batch_admission_evaluate` in `scripts/lib/batch-admission-lib.sh`) implements
  **pure branch-identity equality**, not a merge-target relationship: admission refuses
  (`off_integration_branch`) whenever `git symbolic-ref -q --short HEAD` in the primary tree is
  not byte-identical to the declared string, with no concept of "ahead of" or "will merge into."
  There is no soft "warn only" mode — a declared, mismatched branch always hard-refuses.
- Given that equality semantics, the correct value is **`dev/m7-ladder-continuation`** — the
  single long-lived branch this repository's `/orchestrate` dispatches actually stay checked out
  on today (confirmed via `git log`/`git reflog`) — **not** `main`. `main` sits well behind this
  branch (recent merges land via `pr*` branches/PRs), and declaring `main` would hard-refuse
  every ordinary invocation in the repository's current working pattern.
- This branch is milestone-scoped and has already been renamed once (`milestone/M7` ->
  `dev/m7-ladder-continuation`, confirmed via reflog): the declaration **will** need to be
  updated again at the next milestone transition. There is no existing automated rename
  machinery — the prior rename was a manual operator `git branch -m`. Recommendation: treat
  updating `integration_branch` as a required step of that same manual transition, not a
  separate maintenance burden.
- `worktree_isolation` should be declared explicitly as `"off"` (behavior-identical to leaving it
  absent, per the fail-open table, but self-documents that the key was evaluated rather than
  overlooked) — `"batch"` is declared-but-unimplemented and would hard-refuse every invocation.
- Falsification was run against a disposable synthetic repo (not this one) and confirms all three
  live paths: declaring a branch other than the checked-out one refuses with
  `off_integration_branch` and the exact expected message; declaring the checked-out branch on a
  clean tree admits and writes a batch record; a dirty tracked path outside the state territory
  refuses with `dirty_primary_tree`. The live falsification against *this* repository (confirming
  `/orchestrate --dry-run` actually reports the stop) is deferred to the implement phase, where it
  can run safely via the existing `--dry-run` path.
- Refuse-vs-warn (deliverable 4) is not an open design choice: the implementation offers only
  hard refuse once declared (or silent fallback + advisory if undeclared). The decision to record
  is therefore "declare it, accepting hard refuse," justified because the architecture already
  requires the primary tree to never switch branches during dispatch work — the gate enforces an
  invariant the system already claims to hold, rather than introducing a new restriction.

## Context & Scope

Researched what to declare in `.claude-extensions.json`'s `integration_branch` and
`worktree_isolation` keys so that `/orchestrate`'s admission check (currently disarmed, printing
an advisory every run) arms for real, without blocking the repository's actual working pattern.
Scope: read the consumer implementation exactly as written (not as summarized by its own
documentation) to pin down what semantics are actually tested; determine this repository's actual
branch practice from git history rather than assumption; validate the mechanism's refuse/admit
paths against a disposable synthetic repo; and record the `worktree_isolation` and
refuse-vs-warn decisions the dispatch asked for. Scope excludes: actually writing the key (that is
implement-phase work, since this is a `research` dispatch) and excludes redesigning the admission
mechanism itself (declared-but-unimplemented `batch` isolation, a possible future "warn-only"
mode) — those are out of scope for a single-key declaration task.

## Findings

### Codebase Patterns

- **`.claude-extensions.json` current state** (`jq 'keys'`): exactly `["extensions", "version"]`
  — the file does carry only the two deploy-owned keys the dispatch description states, confirming
  the task is correctly sited (a hand-authored sibling key, not a `.claude/**` write, so
  `source-store-deploy-boundary.md` does not apply).

- **Exact consumer semantics** (`batch_admission_evaluate`, read in full): the predicate order is
  (1) `worktree_isolation` not `off`/absent -> refuse `isolation_unimplemented`; (2) not a git work
  tree -> skip; (3) `integration_branch` undeclared -> advisory only, admit; (4) declared **and**
  `git symbolic-ref -q --short HEAD` differs from the declared string (or HEAD is detached) ->
  refuse `off_integration_branch`, tested every cycle; (5) declared, first cycle only, a tracked
  path outside `specs/`, `.claude-extensions.json`, `.memory` differs from `HEAD` -> refuse
  `dirty_primary_tree`; (6) otherwise admit, writing a batch record on the first cycle. The branch
  test is **symbolic-ref equality**, nothing richer — no ancestry check, no "is this a descendant
  of the declared branch" relationship, no notion of a PR target. This directly answers the
  dispatch's "state which semantics the consumer actually implements" instruction: the declared
  value is **the branch the primary tree must be checked out on**, full stop, not "where this
  eventually lands."

- **This repository's actual branch practice** (`git branch -a`, `git log --all --oneline`,
  `git reflog show dev/m7-ladder-continuation`): the current branch, `dev/m7-ladder-continuation`,
  is the one every recent task commit (993, 989, 994/995, roadmap regenerations, etc.) lands on
  directly — exactly the "Hot-Path Branch" `git-workflow-narrative.md` describes: "the primary
  working tree stays on the declared integration branch and is never switched during dispatch
  work." `main` is multiple PRs behind (visible via `pr8-*`, `pr10-*` branches and
  `Merge pull request #10 ...` on `main`); the repository's actual pattern is PRs/merges carrying
  work *into* `main` periodically, while ongoing `/orchestrate` dispatch work stays on the one
  milestone branch. Declaring `main` would therefore refuse essentially every `/orchestrate`
  invocation under the repository's current practice (confirmed empirically below).

- **The branch is milestone-scoped and has already been renamed once**: the reflog shows
  `2e530a5bf dev/m7-ladder-continuation@{32}: Branch: renamed refs/heads/milestone/M7 to
  refs/heads/dev/m7-ladder-continuation` immediately followed by `@{33}: branch: Created from
  HEAD`. No script in `.claude/scripts/` performs a `git branch -m`/rename for this purpose
  (`grep -rn "branch -m" .claude/scripts/*.sh` returns nothing on-point); the M7 rename was a
  manual operator action. This confirms the dispatch's own warning: naming the current feature
  branch risks going stale at the next milestone transition — but it already did, once, with no
  automated catch, and the fix path (update the declaration alongside the rename) is as cheap as
  the rename itself.

- **`worktree_isolation`**: undeclared and `"off"` are byte-identical in behavior (fail-open
  table in `repo-level-declarations.md`); `"batch"` is declared-but-unimplemented and hard-refuses
  every invocation (`isolation_unimplemented`), naming
  `batch_worktree_creation_when_isolation_on` — one of five explicitly on-hold tasks named by slug
  in `git-workflow-narrative.md` (`batch_worktree_creation_when_isolation_on`,
  `two_root_contract_dispatch_and_commit_scripts`, `two_root_contract_in_hooks`,
  `two_root_classification_of_remaining_consumers`,
  `batch_worktree_cleanup_retention_orphan_report`). This repository runs single-tree, no-worktree
  dispatch today (confirmed by the Hot-Path Branch narrative and by this session's own territory
  block showing concurrent-sibling dispatch sharing one working tree) — `"off"` is the only
  value that does not hard-refuse.

### Falsification (empirical, synthetic repo)

Ran `batch_admission_evaluate` directly (sourced from `.claude/scripts/lib/batch-admission-lib.sh`)
against a disposable git repo under the session scratchpad — **not** this repository, to avoid
disrupting this session's own live admission state:

1. Checked out `dev/m7-ladder-continuation`, declared `integration_branch: "main"` ->
   `VERDICT=refuse REASON=off_integration_branch`, message: *"the primary working tree is on
   branch 'dev/m7-ladder-continuation', but .claude-extensions.json declares integration_branch
   'main'. Switch the primary tree to 'main' before invoking /orchestrate."* — this is the exact
   failure mode a `main` declaration would produce in this repository's real working pattern.
2. Redeclared `integration_branch: "dev/m7-ladder-continuation"`, `worktree_isolation: "off"`,
   clean tree -> `VERDICT=admit`, and a batch record was written with
   `integration_branch_declared: true` and the resolved `integration_tip_at_cut`.
3. Dirtied a tracked path outside the state territory -> `VERDICT=refuse
   REASON=dirty_primary_tree`, naming the offending path — confirming the second refusal arm also
   fires once the branch arm is satisfied.

This discharges the dispatch's falsification requirement at the mechanism level: admission now
arms, in both directions (refuses on mismatch, admits on match), not merely "the advisory stopped
printing." A **live** falsification against this actual repository — temporarily declaring a
branch other than `dev/m7-ladder-continuation` and confirming a real
`scripts/orchestrate-cycle-plan.sh --dry-run` invocation reports `off_integration_branch` — is
left to the implement phase, where `--dry-run` (confirmed in `orchestrate-cycle-plan.sh`: no
session/state writes under that flag) makes it safe to run against the live tree without side
effects, immediately before and after the real declaration is written.

### External Resources

None consulted — this is a purely internal, mechanism-and-practice question; no web research was
relevant.

## Recommendations

1. **Declare**: `"integration_branch": "dev/m7-ladder-continuation"` and
   `"worktree_isolation": "off"` as new top-level sibling keys in `.claude-extensions.json`,
   alongside the existing `extensions`/`version` keys — a hand-authored addition, not a
   `.claude/**` write (consistent with `repo-level-declarations.md`'s "Why
   `.claude-extensions.json` Survives a Hand-Authored Sibling Key").
2. **Falsification in the implement phase**: before writing the declaration, run
   `scripts/orchestrate-cycle-plan.sh --dry-run ...` (or an equivalent direct call to
   `batch_admission_evaluate` against the live repo root) with a deliberately wrong branch name
   to confirm `off_integration_branch` fires against the real tree; then write the correct
   declaration and re-run to confirm a clean `admit`. Both runs are side-effect-free under
   `--dry-run`.
3. **Record the milestone-transition obligation**: wherever the next milestone's branch
   rename/cutover is performed (today a manual `git branch -m`, per the M7 reflog evidence), the
   same action must update `integration_branch` in `.claude-extensions.json` in the same breath —
   otherwise admission reverts to hard-refusing every invocation the moment the rename lands.
   This is not new overhead; it is one more edit alongside an already-manual step. Whether this
   becomes a written checklist item, a one-line addition to whatever doc governs milestone
   cutover, or stays tribal knowledge is a plan-phase/implement-phase call, not a research
   finding — but the obligation itself should not be silently assumed away.
4. **Do not declare `worktree_isolation: "batch"`.** It is unimplemented and would hard-refuse
   every invocation; this is already correctly treated as a non-goal by five held tasks named in
   `git-workflow-narrative.md`.

## Decisions

- **Semantics chosen**: the declared value names *the branch the primary tree is required to sit
  on*, not an eventual merge/PR target — this is what the consumer code tests (symbolic-ref
  equality), and it is the only reading consistent with a non-vacuous admission gate under this
  repository's current practice.
- **Value chosen**: `dev/m7-ladder-continuation`, not `main` — justified by both the consumer's
  literal-equality semantics and the empirical branch history (every recent task commit lands
  there; `main` trails behind via periodic PR merges).
- **`worktree_isolation` decision**: declare explicitly as `"off"` rather than leaving it absent.
  Behavior is identical either way (confirmed by the fail-open table and not separately
  retested, since it follows directly from the documented absent/`"off"` equivalence), but an
  explicit declaration records that the key was evaluated, not overlooked — useful to a future
  reader auditing `.claude-extensions.json` at the next milestone transition.
- **Refuse-vs-warn decision**: adopt hard refuse (the only mode the implementation offers once
  `integration_branch` is declared). This is not experienced as a new restriction: the
  architecture already states, independently of this gate, that "the primary working tree stays
  on the declared integration branch and is never switched during dispatch work"
  (`git-workflow-narrative.md`, Hot-Path Branch section). The gate enforces an invariant the
  system already claims to hold; a soft "warn only" mode would let that invariant silently drift
  without detection, which is the exact failure the task's own framing ("DO NOT silence the
  advisory by any route other than a real declaration") is written to prevent.

## Risks & Mitigations

- **Risk**: the next milestone transition renames the branch without updating the declaration,
  reintroducing a hard-refuse failure mode (worse than today's advisory-only state, since every
  invocation would refuse rather than merely warn). **Mitigation**: recommendation 3 above; the
  implement/plan phase should decide where this obligation is written down.
- **Risk**: a one-off operator checkout of a different branch (e.g. for manual PR inspection)
  while `/orchestrate` is invoked would now hard-refuse where it previously only warned.
  **Mitigation**: this is the intended, designed behavior per the Decisions section above — the
  architecture already forbids running dispatch work off the hot-path branch; the refusal
  surfaces a genuine operator error rather than silently proceeding on the wrong branch.
- **Risk**: the dirty-tree arm (`dirty_primary_tree`) is now also armed, since it is gated on
  `integration_branch` being declared. This was not separately requested by the dispatch but is
  an unavoidable side effect of arming the branch test (both arms share step 3's declared-branch
  gate in the predicate). **Mitigation**: none needed — this is correct, intended behavior per
  `repo-level-declarations.md`'s own documentation of the mechanism, and the falsification above
  confirms it behaves as documented (state-territory paths are excluded, so ordinary
  task-management writes do not trip it).

## Context Extension Recommendations

None. `repo-level-declarations.md` already documents this mechanism in full detail (schemas,
fail-open tables, the Hot-Path Branch narrative); no gap was found during this research that
warrants a new or updated context file.

## Appendix

### Search queries / commands used

- `jq 'keys' .claude-extensions.json` / `jq 'del(.extensions)' .claude-extensions.json`
- `cat .claude/context/standards/repo-level-declarations.md`
- `cat .claude/scripts/lib/batch-admission-lib.sh` (full read)
- `git branch -a`; `git log --all --oneline --decorate -20`; `git log main --oneline -5`
- `git reflog show dev/m7-ladder-continuation`
- `grep -rn "branch -m\|rename" .claude/scripts/*.sh`
- `cat .claude/context/standards/git-workflow-narrative.md` (Branch Strategy section)
- Synthetic-repo exercise of `batch_admission_evaluate` (three scenarios: branch mismatch, clean
  admit, dirty tree) under the session scratchpad directory

### References

- `.claude/context/standards/repo-level-declarations.md`
- `.claude/scripts/lib/batch-admission-lib.sh`
- `.claude/context/standards/git-workflow-narrative.md` (Branch Strategy, Hot-Path Branch section)
- `.claude/rules/git-workflow.md` (Branch section)
