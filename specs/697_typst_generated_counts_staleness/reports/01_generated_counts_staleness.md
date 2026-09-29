# Research Report: Task #697

**Task**: 697 - Typst generated counts staleness
**Started**: 2026-09-29T00:00:00Z
**Completed**: 2026-09-29T00:00:00Z
**Effort**: medium
**Dependencies**: None
**Sources/Inputs**: - Codebase (`scripts/typst-status-counts.sh`, `scripts/typst-sync-check.sh`, `scripts/typst-module-map.sh`, `scripts/typst-machine-appendix.sh`, `.github/workflows/ci.yml`, `docs/development/CI_CD_PROCESS.md`, `CONTRIBUTING.md`, `.claude/scripts/git-commit-scoped.sh`, `docs/reference/paper-definitions-of-record.md`), live count regeneration (`--json` mode)
**Artifacts**: - `specs/697_typst_generated_counts_staleness/reports/01_generated_counts_staleness.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The gap is structural, not a bug in either script: `typst-status-counts.sh` (generator) and
  `typst-sync-check.sh` Check 2 (checker) agree byte-for-byte on methodology, but **no workflow
  in this repository ever invokes the generator**. Every fix to date has been the same
  post-hoc manual command after CI already went red.
- **Recommendation: Option (a) — a versioned pre-commit hook + installer, but designed as a
  fast build-free *gate* that blocks the commit and prints the fix command, not as a
  silent auto-regenerate-and-restage hook.** This resolves the "spurious diff" and "needs a
  built library" constraints simultaneously (see Findings) and, because it hangs off `git
  commit` itself, transparently covers both human contributors and this repository's actual
  dominant commit path — `.claude/scripts/git-commit-scoped.sh`, which calls a plain `git
  commit` with no `--no-verify` (verified below).
- Option (c) ("regenerate as a step in whatever workflow lands Lean files") is the right
  *instinct* but, read as "wire it into the `.claude/` agent orchestrator," is not
  implementable from this task: that orchestrator is deployed from a separate repository
  (`agent-system`) per `.claude/rules/source-store-deploy-boundary.md`, exactly the boundary
  task 698 already had to respect for an analogous enforcement gap. The recommended git hook
  achieves the *same effect* without crossing that boundary, because every landing path in
  practice — human or agent — funnels through one `git commit` invocation in this repo.
- Option (b) (`--fix` mode on the checker) is cheap, complementary, and worth adding as the
  one-line manual remedy — but it is **detection with a nicer UI**, not prevention: the
  failure recurred twice specifically because nothing *prompted* anyone to run any command,
  and `--fix` does not change that.
- Option (d) (compute counts at Typst compile time) is investigated and **rejected**: Typst's
  compiler has no directory-listing/glob primitive and cannot shell out to `lake env lean`,
  so the per-declaration axiom report (which the task's own constraint says needs a **built
  library**) can never be produced inside a `.typ` file. At best the *scalar* file/line
  counts could be relocated into a small JSON data file read via `#read`/`#json`, but that
  JSON still needs the same generation step — this relocates the staleness class rather than
  deleting it, and does nothing for the axiom-report half.

## Context & Scope

Task 697's declared `file_scope` is `scripts/typst-status-counts.sh`,
`scripts/typst-sync-check.sh`, `typst/generated/status.typ`. This research investigated the
four listed candidate mechanisms plus any the investigation itself surfaced, and confirmed the
counts are presently in sync (a live `--json` regeneration matches every scalar `#let` binding
committed in `typst/generated/status.typ` as of this research pass — see Appendix), so no
drift needs to be fixed today; the deliverable is the *mechanism*, to be implemented and
demonstrated (on a synthetic `.lean` addition) in the implementation phase.

## Findings

### Codebase Patterns

- **The generator and checker already agree; the gap is purely "nothing calls the generator."**
  `scripts/typst-status-counts.sh --json` emits the scalar counts build-free (`find`/`wc`
  only); `scripts/typst-sync-check.sh` Check 2 calls exactly that mode and diffs the result
  against the committed `#let` bindings, deliberately excluding `stamp-commit`/`stamp-date`
  from the comparison (`typst-sync-check.sh` lines ~200-230). No script or CI step ever runs
  the generator's *write* path (`bash scripts/typst-status-counts.sh`, no `--json`).
- **The write path needs a built library; the check path does not.** The five per-declaration
  `#print axioms` lines are read via `lake env lean` against the built `FormalSystem` library
  (`typst-status-counts.sh`'s final third). `--json` mode returns before that block runs. This
  is the task's stated constraint, confirmed by reading the script: any hook that must
  regenerate the *file* (not just diff `--json`) needs oleans present.
- **`core.hooksPath` is presently the default `.git/hooks` (unversioned), confirmed live**:
  `git config --get core.hooksPath` returns `.git/hooks`. No versioned `.githooks/` (or
  similar) directory exists anywhere in the repo (`find` for `hooks/` outside `.git/` and
  `.opencode*/` returns nothing). This matches the dispatch's own note and is a genuinely new
  piece of contributor-facing infrastructure, not an extension of something already there.
- **This repository has already considered and rejected a git pre-commit hook once, for a
  different reason that does not transfer here.** `docs/reference/paper-definitions-of-record.md`
  (`## Invocation from CI, skills or hooks — decision`) rejects a pre-commit hook for
  `check-paper-definitions.sh` because "commits here never touch the paper, so it would never
  fire on the event that causes drift." That reasoning is exactly inverted for task 697: the
  drift-causing event (adding/removing a `.lean` file) **is** a local commit, so a pre-commit
  hook fires precisely on the event that matters. This precedent shows the repo is not
  hook-averse in principle, only unwilling to add a hook that can't fire on the relevant event.
- **The repository's actual commit path does not bypass hooks.** `.claude/scripts/git-commit-scoped.sh`
  (the sanctioned committer used by the orchestrator workflow — see `git-workflow.md`) invokes
  a plain `git commit -m "$full_message" -- "${pathspecs[@]}"` with no `--no-verify` anywhere
  in the script (`grep -n "no-verify" .claude/scripts/git-commit-scoped.sh` returns nothing).
  This means a versioned pre-commit hook, once installed against this working tree's
  `.git/config`, would fire transparently for every task commit the orchestrator makes here —
  not just for an interactive human contributor. The two observed staleness incidents were
  both orchestrator-driven `.lean` commits, so this is the actual failure population the
  mechanism needs to cover, and a git hook covers it without touching `.claude/` at all.
- **No other generic bootstrap point exists to auto-install hooks.** This is a pure Lean/bash
  repository: no `package.json`/npm `postinstall`, no `pyproject.toml`, no Makefile, no
  existing installer script (`find` for `install-hooks*`/`setup-hooks*` returns nothing). The
  one-time `git config core.hooksPath` step will need to be either run once by hand (by every
  clone, including this session's own working tree) or documented in `CONTRIBUTING.md`'s
  "Development Setup" block (`CONTRIBUTING.md` lines 17-30) immediately after `git clone` — CI
  itself cannot install a hook for a contributor's *local* future clones.
- **Two sibling generated-file checks in the same script share this defect class but are out
  of this task's declared scope.** `typst-sync-check.sh` Check 2b (`typst-module-map.sh`,
  triggered by `Automation/` edits) and Check 3 (`typst-machine-appendix.sh`, triggered by
  `Axioms.lean`/`Derivation.lean` edits) are generated the same "nothing calls it" way.
  `typst-module-map.sh` is fully build-free even in its write mode (no `lake env lean` call at
  all — confirmed by reading its header); `typst-machine-appendix.sh`'s write mode needs a
  build (`lake build BimodalTools.MachineAppendixMain`), same as `typst-status-counts.sh`. Not
  in this task's `file_scope`, but the chosen hook design generalizes to both for free if a
  planner chooses to extend the trigger condition later — recorded here as a follow-on
  opportunity, not attempted.
- **Currently green**: a live `bash scripts/typst-status-counts.sh --json` regeneration was
  compared against the committed `typst/generated/status.typ` scalar bindings during this
  research pass and all six count fields (`formalsystem-file-count` = 604,
  `formalsystem-line-count` = 316549, `tests-file-count` = 75, `tests-line-count` = 22445,
  `tools-file-count` = 40, `tools-line-count` = 18216) match exactly. No drift exists right
  now; several sibling tasks are landing `.lean` changes on this same shared working tree this
  cycle, so this could change before task 697 reaches implementation — the implementer should
  re-check before building the "synthetic addition" demonstration.

### External Resources

Not applicable — this is a self-contained repository-tooling question with no external
dependency beyond Typst's documented compiler sandboxing (no filesystem glob/readdir
primitive, no shell-out capability), which is why option (d) is rejected below rather than
prototyped.

### Recommendations — comparative scoring

Per the dispatch's instruction, each option is scored on (i) prevents vs. merely detects
sooner, (ii) cost to a fresh clone, (iii) whether CI still catches a bypass.

| Option | Prevents or detects? | Cost to a fresh clone | CI still catches a bypass? |
|---|---|---|---|
| **(a) Versioned pre-commit hook + installer + `core.hooksPath`** (recommended, see design below) | **Prevents** — blocks the commit until the contributor regenerates, for both human and orchestrator-driven commits (see `git-commit-scoped.sh` finding above) | Near-zero on the common path: the hook's own check is the build-free `--json` diff (a `find`+`wc` pass), and it *runs* only when the fix is actually needed does it ask for a build — which the contributor needs to do anyway to have a working commit. One-time setup cost: `git config core.hooksPath .githooks`, documented in `CONTRIBUTING.md`. | Yes, unchanged — CI's Check 2 is the mandatory backstop for an uninstalled hook, a `--no-verify` commit, or a hook that errors out |
| **(b) `--fix` mode on `typst-sync-check.sh`** | **Detects only**, with a nicer remedy UX (one command instead of two) — does not change *whether* anyone runs it, which is the actual failure mode observed twice | Zero — no new infra at all | Yes, unchanged (irrelevant either way — it's a manual command) |
| **(c) Regenerate inside "whatever workflow lands Lean files"** | Best in principle (same-commit atomicity) but, read literally as "the `.claude/` agent orchestrator," **not implementable from this task**: that orchestrator is deployed from a different repository (`agent-system`) per `source-store-deploy-boundary.md` — the same boundary task 698 had to respect. A repo-native version of "the landing workflow" collapses into option (a): every landing path (human `git commit` or the orchestrator's `git-commit-scoped.sh`) funnels through the same `git commit` invocation, which is exactly where a hook sits. | N/A as a distinct in-repo mechanism | Same as (a) |
| **(d) Compute at Typst compile time** | Would delete the class outright *if viable*, but is **rejected**: Typst has no glob/readdir primitive and cannot invoke `lake env lean`, so the axiom-report half (which the task's own constraint says needs a **built library**) can never live inside a `.typ` file. Relocating only the scalar counts into a `#read`/`#json`-loaded data file just moves the same staleness class into a different generated artifact — it does not delete it. | N/A (rejected) | N/A (rejected) |

### Recommended design (Option (a), refined to satisfy the stated constraints)

The dispatch's CONSTRAINTS section flags two hazards that a naive hook would hit; the design
below is shaped specifically to avoid both:

1. **"The generator needs a built library, which rules out any hook shape that must run
   without oleans."** Resolution: the hook's *gate* check uses **`--json` mode only**
   (build-free, matches exactly what CI's Check 2 already does) to decide whether a
   regeneration is even needed. It never calls the write path (and never needs `lake env
   lean`) unless a real mismatch is found — at which point it **blocks the commit** and prints
   the exact remedy (`lake build && bash scripts/typst-status-counts.sh && git add
   typst/generated/status.typ`) rather than attempting the potentially multi-minute build
   itself inside `git commit`. This keeps the hook fast on every commit where nothing drifted
   (the overwhelming majority) and never surprises a contributor with an unbounded hang.
2. **"stamp-commit/stamp-date mean a regeneration always dirties the file... a naive
   always-run hook would create spurious diffs."** Resolution: because the gate check compares
   only the same scalar fields CI's Check 2 already compares (explicitly excluding the stamp
   fields, mirroring `typst-sync-check.sh`'s own comparison), a commit where the *scalars* are
   unchanged does **nothing** — no regeneration, no re-stage, no diff. The stamp fields only
   move when a human explicitly runs the remedy command by hand (or the `--fix` addition from
   option (b) runs it for them), at which point a normal `git add` is expected and not
   "spurious."

Concretely, this means:

- A new versioned `.githooks/pre-commit` script: if `git diff --cached --name-only` contains
  any `*.lean` path, run `scripts/typst-status-counts.sh --json`, diff the same six scalar
  fields Check 2 diffs against the committed `typst/generated/status.typ`, and `exit 1` with
  the remedy command printed if any differ; `exit 0` (no-op) otherwise or when no `.lean` file
  is staged.
- A new `scripts/install-git-hooks.sh` (idempotent — safe to re-run) that runs `git config
  core.hooksPath .githooks`.
- `CONTRIBUTING.md`'s "Development Setup" block gets one new line running the installer,
  immediately after `git clone`/`cd`.
- CI's `typst-sync-check.sh` Check 2 is **left entirely unchanged** — it remains the mandatory
  backstop for an uninstalled hook, a `--no-verify` commit, or any hook failure.
- As a complementary, low-cost addition (option (b)), add a `--fix` flag to
  `typst-sync-check.sh` that, on a Check 2 mismatch, invokes `scripts/typst-status-counts.sh`
  itself and reports what changed — this becomes the exact one-line remedy the hook's failure
  message points to, and is also useful standalone for anyone who bypassed the hook
  deliberately (`--no-verify`) and wants to clean up before pushing.
- The implementer should run `bash scripts/install-git-hooks.sh` once against this actual
  working tree as part of landing the change, since `core.hooksPath` is local git config (not
  a tracked file) and will not otherwise take effect for this session's or any concurrent
  sibling's remaining commits this cycle.

## Decisions

- **Chosen mechanism: Option (a)**, a versioned `.githooks/pre-commit` + `scripts/install-git-hooks.sh`
  + `core.hooksPath`, built as a fast build-free blocking gate (using `--json` diff of the same
  scalar fields CI already compares) rather than a silent auto-regenerate-and-restage hook.
- **Option (b) (`--fix` mode) is adopted as a complementary secondary addition**, not the
  primary mechanism, because it addresses convenience, not the actual failure mode (nothing
  prompting anyone to run anything).
- **Option (c), read as "edit the `.claude/` agent orchestrator," is out of scope for this task**
  and must not be attempted from this repository per `source-store-deploy-boundary.md`; its
  goal (same-commit atomicity for the workflow that actually lands `.lean` files) is achieved
  instead by option (a), since the orchestrator's own committer (`git-commit-scoped.sh`) uses
  a plain `git commit` with no `--no-verify` and will trigger the same hook. No follow-on task
  is recorded in the `agent-system` repository for this, because option (a) already closes the
  gap without needing a change there — unlike task 698's enforcement-half gap, which had no
  in-repo substitute available.
- **Option (d) (Typst-compile-time computation) is rejected** for the reasons in Findings:
  Typst cannot glob the filesystem or invoke `lake env lean`, so it cannot eliminate the
  axiom-report half of the generated content, and relocating only the scalar counts would
  merely move the staleness class into a new generated JSON file rather than deleting it.
- Generalizing the same hook trigger to also cover `typst-module-map.sh` (Check 2b) and
  `typst-machine-appendix.sh` (Check 3) is noted as a natural follow-on extension but is
  explicitly **not** part of this task's `file_scope` and is left to a future task or to the
  planner's discretion if judged in-scope.

## Risks & Mitigations

- **Risk**: a contributor (or the orchestrator) bypasses the hook with `--no-verify`, or the
  hook is never installed on a given clone. **Mitigation**: CI's Check 2 is untouched and
  remains the mandatory, unbypassable backstop — this is explicitly why the design keeps CI as
  a parallel, independent enforcement layer rather than replacing it with the hook.
- **Risk**: the hook's `--json` regeneration itself becomes slow if `find`/`wc` over
  `FormalSystem/`/`Tests/`/`BimodalTools/` grows expensive at scale. **Mitigation**: this is
  the same call CI's Check 2 already makes on every PR; if it becomes a bottleneck there, it
  becomes a bottleneck for the hook identically, and the fix (memoizing or narrowing the walk)
  benefits both call sites.
- **Risk**: `core.hooksPath` is local, per-clone git config — this session's own working tree,
  and any concurrent sibling task's commits in the same shared working tree, will not benefit
  unless the installer is actually run once now. **Mitigation**: called out explicitly above;
  the implementation phase should run `scripts/install-git-hooks.sh` against the live working
  tree as part of landing the change, not just add the script.
- **Risk**: a hook that silently auto-regenerates and re-stages the file (the naive shape the
  dispatch explicitly warns against) would create a spurious stamp-only diff on every relevant
  commit even when counts are unchanged. **Mitigation**: the recommended design never
  regenerates or re-stages on its own; it only ever compares the same non-stamp scalar fields
  CI already compares and blocks with an actionable message, so it cannot itself dirty
  anything.

## Context Extension Recommendations

- **Topic**: contributor-facing git hook infrastructure.
- **Gap**: `CONTRIBUTING.md`'s "Development Setup" section currently has no step for
  installing repository-local git hooks (none exist yet), and `docs/development/CI_CD_PROCESS.md`
  documents CI's own check steps but has no equivalent "local pre-commit hooks" section.
- **Recommendation**: once implemented, add a short "Git Hooks" subsection to
  `CONTRIBUTING.md`'s Development Setup (the one-time `scripts/install-git-hooks.sh` step) and
  a corresponding pointer in `docs/development/CI_CD_PROCESS.md` noting that Check 2's
  count-freshness gate now has a local pre-commit counterpart, so a future reader who only
  reads the CI doc understands why staleness should be rare in practice despite CI still
  policing it.

## Appendix

- Search/verification commands used:
  - `git config --get core.hooksPath` → `.git/hooks` (confirms no versioned hooks dir active)
  - `find . -maxdepth 2 -iname hooks` (excluding `.git/`, `.claude/`) → only `.opencode/hooks`
    and `.opencode_OLD/hooks` (agent-hook systems, unrelated to git hooks)
  - `grep -n "no-verify" .claude/scripts/git-commit-scoped.sh` → no matches (confirms the
    orchestrator's committer does not bypass hooks)
  - `bash scripts/typst-status-counts.sh --json` compared field-by-field against
    `typst/generated/status.typ`'s committed `#let` bindings → all six scale counts match
    (604 files / 316549 lines FormalSystem, 75/22445 Tests, 40/18216 BimodalTools) as of this
    research pass
  - Read in full: `scripts/typst-status-counts.sh`, `scripts/typst-sync-check.sh`,
    `scripts/typst-module-map.sh` (header), `scripts/typst-machine-appendix.sh` (build
    dependency lines), `.github/workflows/ci.yml`, `docs/development/CI_CD_PROCESS.md`
    (headings + "Wiring a New Check Script"), `CONTRIBUTING.md` (Development Setup),
    `docs/reference/paper-definitions-of-record.md` (hook precedent section)
- References: `docs/reference/paper-definitions-of-record.md`'s "Invocation from CI, skills or
  hooks" section (prior, inverse-reasoning precedent on git hooks in this repo);
  `.claude/rules/source-store-deploy-boundary.md` (why option (c)'s literal agent-orchestrator
  reading is out of scope here); task 698's state.json description (the precedent for
  recording a cross-repository boundary rather than attempting to cross it).
