# Research Report: Evidence-Probe Compile Failures

**Task**: 786 - Repair the four wired evidence probes that fail to compile
**Started**: 2026-10-14T06:03:00Z
**Completed**: 2026-10-14T06:30:00Z
**Effort**: ~30 minutes (two full gate runs, one four-probe run, archived-log forensics)
**Dependencies**: None recorded in `specs/state.json` (see Findings -> Scope and Sequencing)
**Sources/Inputs**:
- `scripts/check-evidence-probes.sh` (the manifest/driver under investigation)
- `scripts/check-module-invariants.sh` (the precedent that already solves this problem)
- `.claude/scripts/lake-build-guard.sh` (the shared lock's publisher)
- The four probe sources under `specs/evidence/seam-gluing-ray-product/`
- `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/868956dd-f5e3-4e48-9514-86490285f59c/scratchpad/p4-gate.log` (the originating run's full gate output, with the per-probe error text)
- `/home/benjamin/.claude/projects/-home-benjamin-Projects-BimodalLogic/868956dd-f5e3-4e48-9514-86490285f59c/subagents/agent-a8deacd89a5d74645.jsonl` (the originating implement dispatch's transcript)
- `specs/778_residue_index_modulus_convention_record/` (plan, summary, handoffs, `issues.jsonl`, `metrics.jsonl`)
- `.github/workflows/ci.yml`, `git log`, `.lake/build/lib` olean mtimes
**Artifacts**:
- `specs/786_evidence_probe_compile_failures_repair/reports/01_evidence-probe-compile-failures.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task's premise is false as measured today.** `bash scripts/check-evidence-probes.sh`
  exits **0** with `PASS  all 33 wired probe(s) compile`, measured twice in this session
  (84 s warm on the second run, explicit `EXIT=0`). All four named probes PASS.
- **None of the four needs repair, restatement, or retirement.** Each compiles standalone,
  `sorry`-free, with axioms only `[propext, Classical.choice, Quot.sound]`, and none of the four
  source files has been modified since the commit that created it (three on 2026-10-03, one on
  2026-10-03 later the same day). The library has only moved forward since the failing run.
- **The four failures had one shared, environmental cause, not four independent source-level
  ones.** The originating run's full gate log survives, and every one of the four errors is
  `error: object file '.../FormalSystem/<Module>.olean' of module FormalSystem.<Module> does not
  exist` — a missing-`.olean` I/O error, naming four *different* modules of the `FormalSystem`
  import-closure tail. Not one Lean elaboration error among them.
- **Mechanism**: `check-evidence-probes.sh` invokes bare `lake env lean` 33 times and takes **no
  lock**, so its `.lake` reads raced a concurrent `lake build` that was rewriting exactly those
  tail oleans. The four failures are *consecutive* WIRED entries (9-12 of 33) — the shape of a
  moving rebuild frontier passing under a sequential reader, not of four coincident bit-rots.
- **The real defect, and the one worth fixing, is the driver's concurrency hole.** The gate can
  emit a false red at any time, which is precisely the masking hazard the task description names:
  a genuine new breakage would be indistinguishable from this noise. The fix already exists in
  this repository as precedent — `check-module-invariants.sh` takes an `flock` on
  `$REPO_ROOT/.lake/build-guard.lock` for exactly this reason, and documents its rejected
  alternatives in place.
- **Recommended**: re-scope to harden `check-evidence-probes.sh` with that same lock (plus a
  third diagnostic class in its failure output, so a `.lake` race is never again read as probe
  rot), and keep all four probes untouched.

## Context & Scope

The task was created from a measured exit-1 of `scripts/check-evidence-probes.sh` during task
778's implement dispatch, with four of 33 wired probes reported as `FAIL (does not compile)`.
The task description explicitly left the cause open ("Nobody has investigated WHY each of the
four fails"), instructed that each probe be treated as its own diagnosis, and anticipated three
possible per-probe remedies: repair, restatement, or retirement-with-rationale.

This research set out to do exactly that, probe by probe. The first measurement collapsed the
question: all four compile. The investigation therefore shifted to establishing *why they failed
then and pass now* with enough rigour to rule out a flapping or state-dependent defect, since a
probe that passes only sometimes is worse than one that fails reliably.

Constraints honoured: no probe statement was weakened, no probe was deleted, nothing under
`specs/evidence/` was edited at all. The driver script was read, not modified.

## Findings

### Current measured state: the gate is green

Two independent full runs in this session, both green:

| Run | Probes | Verdict | Exit | Elapsed |
|-----|--------|---------|------|---------|
| 1 | 33 wired + 1 deferred | `PASS  all 33 wired probe(s) compile` | 0 (per the script's own `exit 0` branch) | not timed |
| 2 | 33 wired + 1 deferred | `PASS  all 33 wired probe(s) compile` | `EXIT=0` captured | 84 s |

A separate direct run of the four named probes (`lake env lean <probe>` each) also exited 0 on
all four, emitting only their `#print axioms` lines plus one pre-existing
`linter.unusedSectionVars` warning on `mosaic-germ-amalgamation.lean:138` (an unused
`[F.IsRegular]` section variable — a warning, not an error; it does not affect the exit status).

### The four probes are unchanged, and are live records

| Probe | Created | Modified since | What it records |
|-------|---------|----------------|-----------------|
| `finite-graph-stab-summary.lean` | `7e4c1b739`, 2026-10-03 00:35 | never | POSITIVE forward factor: `⊡(F p)` at a seam state iff every forward root path meets the `p`-set, on a total `Bool` fixture; plus the decidably-False computational content |
| `mosaic-germ-amalgamation.lean` | `7e4c1b739`, 2026-10-03 00:35 | never | POSITIVE: the mosaic-method amalgamation precondition is free from `paste` alone; and fixes `StabSaturated` as a named, deliberately undecided predicate with its one same-state corner proved |
| `path-quantifier-alternation.lean` | `7e4c1b739`, 2026-10-03 00:35 | never | The existential/universal inequivalence: a nondeterministic run-summary does not compute `⊡`, so a universal (complementation-shaped) device is necessary for this fragment |
| `backward-dual-asymmetric-fixture.lean` | `21bf992ae`, 2026-10-03 15:51 | never | POSITIVE and state-dependent backward dual on a time-asymmetric fixture, with its own honest limit (the fixture is backward-deterministic) stated in place |

Each is a substantive, currently-wanted record with its own carefully bounded "what this does NOT
do" section. **No retirement candidate exists among them**, and the task's instruction not to
retire one without stating what it recorded and why that record is no longer wanted is satisfied
vacuously: all four records are still wanted.

### The originating failure: one cause, recoverable from the archived log

The task description had no error text. It survives in the originating dispatch's scratchpad
(`p4-gate.log`, mtime 2026-10-13 21:13) and is unambiguous. The four error lines, verbatim in
substance:

| WIRED index | Probe | Error |
|-------------|-------|-------|
| 9 | `finite-graph-stab-summary` | `object file '.../FormalSystem/Metalogic.olean' of module FormalSystem.Metalogic does not exist` |
| 10 | `mosaic-germ-amalgamation` | `object file '.../FormalSystem/MainResults.olean' of module FormalSystem.MainResults does not exist` |
| 11 | `path-quantifier-alternation` | `object file '.../FormalSystem/Examples/Walkthrough.olean' of module FormalSystem.Examples.Walkthrough does not exist` |
| 12 | `backward-dual-asymmetric-fixture` | `object file '.../FormalSystem/Examples.olean' of module FormalSystem.Examples does not exist` |

Five independent lines of evidence fix the cause:

1. **Error kind.** Every error is a missing-object-file I/O error. There is no type error, no
   unknown identifier, no deprecated-API error, no `sorry` — i.e. no evidence of citation drift
   of any kind. The script's `FAIL (does not compile)` label is accurate only in the weakest
   sense: `lean` exited nonzero, having never reached the probe's own content.
2. **Four different modules, one per probe.** The named missing modules are four distinct members
   of the `FormalSystem` import-closure tail. A source-level drift in four unrelated probe files
   would not present as four distinct missing oleans.
3. **Consecutiveness.** The failures are WIRED entries 9, 10, 11 and 12 of 33, with 1-8 and 13-33
   all PASS in the same run. A sequential reader crossing a rebuild frontier produces exactly
   this; four independent bit-rots would not cluster.
4. **Olean mtimes.** `RaySummary.olean`, `Decidability.olean`, `Metalogic.olean`,
   `Examples/Walkthrough.olean`, `MainResults.olean`, `Examples.olean` and `FormalSystem.olean`
   all carry mtime 2026-10-13 21:11 — inside the window of the gate run whose log was written at
   21:13. `LadderModel.olean` carries 21:00, from the earlier scoped build.
5. **The stale-tail setup.** The originating run's phase-1 build was *scoped*
   (`Built FormalSystem.Metalogic.Decidability.RaySummary.LadderModel`, 1182 jobs, 20:59 and
   21:00), so it rebuilt `LadderModel.olean` and left the whole downstream tail stale-but-present.
   The next unscoped build — the invariants script's C1 full `lake build`, whose log was written
   at 21:15 — had to rebuild precisely that tail, and did so at 21:11-21:12, concurrently with
   the gate.

Together these make the diagnosis a single statement: **the gate's unguarded `.lake` reads raced
a concurrent `lake build`'s rewrite of the import-closure tail, and four probes happened to read
during the window in which their respective oleans had been removed and not yet rewritten.**

### Why the driver is exposed, and where the fix already exists

- `scripts/check-evidence-probes.sh` line 1128 is `if out=$(lake env lean "$file" 2>&1); then` —
  a bare `lake` invocation, executed 33 times in a loop, with no lock acquisition anywhere in the
  script.
- `scripts/check-module-invariants.sh` (the `C1: build` block, around lines 995-1056) takes an
  `flock` on `$REPO_ROOT/.lake/build-guard.lock` before its `lake build` calls, holds the fd for
  the rest of the process lifetime so that later `.lake`-reading checks inherit the protection,
  waits up to 600 s, and degrades audibly when `flock` is absent. Its header states the reason in
  terms that describe this task's failure exactly: those invocations "race any other guarded build
  running against this same tree for `.lake` artifacts unless serialized". It also records two
  rejected alternatives (probe-for-the-guard; refuse-on-contention) that need not be re-litigated.
- `.claude/scripts/lake-build-guard.sh` publishes `<root>/.lake/build-guard.lock` as the stable
  convention and takes an exclusive `flock` on it. The lock is advisory and keyed on the path, so
  a repository script and the deployed guard exclude each other with no coupling and no reference
  from the repository into the disposable `.claude/` tree.
- This matches the documented hazard in `.claude/rules/lean4.md`: the guard's mutex is opt-in, so
  "any process that invokes `lake` directly (including a project-local script this agent system
  does not own and cannot edit) bypasses the lock entirely and can collide with a guarded build
  running at the same time". `check-evidence-probes.sh` is that process.

### Secondary findings

- **The script's failure text misdirects for this failure class.** On any failure it prints "A
  probe failing means a recorded design obstruction no longer compiles. Do NOT delete the probe or
  weaken its statements to make this pass: repair the citation drift...". It names two diagnostic
  classes (`does not compile` = rot; `untracked:` = left version control) and has no third for an
  environment failure. That omission is what turned a transient race into a Reasoned Exclusion on
  two phases and then into this task's premise. The conservative reading the originating run took
  was correct given the output it was handed; the output was the problem.
- **CI is not exposed, and a header sentence is stale.** The script *is* wired into CI
  (`.github/workflows/ci.yml`, step id `evidence-probes`, `continue-on-error: true` but counted by
  the aggregating report step, which exits 1 on any failure). The CI steps run sequentially with
  no concurrent build, so the race does not arise there. The script's own header still asserts
  "this script is not wired into CI", which no longer holds.
- **The declared dependency edge is absent from state.** The task description states that a
  `dependencies[]` edge on 734 is declared so the two serialize on the shared driver. In
  `specs/state.json`, task 786's `dependencies` is `[]`, and 734's is `[733]`. Task 734 is
  `[PARTIAL]` and does carry `scripts/check-evidence-probes.sh` in its `file_scope`, so the
  collision risk on the driver is real even though the edge was never recorded.
- **Task 734's probe is not among the four**, as the task description already warns:
  `mosaic-stab-saturated` is 734's and PASSES; `mosaic-germ-amalgamation` is this record's.

## Decisions

- **Decided: none of the four probes is touched.** Repair is not applicable (nothing is broken),
  restatement is not applicable (no underlying object changed shape), retirement is not applicable
  (all four records are still wanted and still bounded as written). Editing a probe to respond to
  an environment failure would be the "weaken the statement to make it pass" move the script's own
  header forbids.
- **Decided: the diagnosis is single-cause, not four-way.** The task instructed treating each
  probe as its own diagnosis. That instruction was followed to the point where the evidence
  contradicted its premise: four identical-kind errors, on four distinct modules of one import
  closure, on four consecutive entries, in one run, with matching olean mtimes, is one event.
  Recording four independent diagnoses here would be a fabrication.
- **Decided: the honest residual defect is the driver's missing lock**, and the remedy is to copy
  the in-repository precedent rather than invent a mechanism. No new convention is needed.
- **Decided: `lake env lean` is treated as a `.lake` *reader* that must hold the same exclusive
  lock as a writer.** A shared (`flock -s`) lock would admit concurrent probe runs, but both
  existing lock users take exclusive locks on this path, and `lake env` is not audited here as
  provably write-free against `.lake`. Matching the precedent is the lower-risk choice.
- **Deferred to the user (non-blocking): whether this task re-scopes or closes.** See
  Recommendations; research proceeds on the re-scope reading because it is the one that serves the
  task's own stated rationale.

## Recommendations

Priority order, all within the existing `file_scope`'s `scripts/check-evidence-probes.sh`:

1. **Take the shared build lock in `check-evidence-probes.sh`** (highest value; this is the whole
   fix). Mirror `check-module-invariants.sh`'s C1 block: `flock` on
   `$REPO_ROOT/.lake/build-guard.lock`, `flock -n` first then `flock -w 600` with an announced
   wait, hold the fd for the script's lifetime so every `check_probe` call is covered, and degrade
   audibly to unserialized operation (with a stderr line) when `flock` is not on `PATH`. Acquire
   once for the whole run rather than per probe, so the 33 verdicts describe one consistent
   library snapshot; note in a comment that this makes `lake-build-guard.sh status` report an
   in-flight build for the run's duration (~84 s warm), which is the same accepted cost the
   invariants script already pays.
2. **Add a third diagnostic class to the failure output.** Detect the missing-object-file shape in
   the captured output (`object file '...' of module ... does not exist`) and report it as an
   environment failure — "the library's `.lake` artifacts were absent or mid-rewrite; re-run after
   any concurrent build completes" — distinct from `FAIL (does not compile)` and
   `FAIL (untracked: ...)`. Without this, a future race under a `flock`-less machine still reads
   as probe rot. Decide at plan time whether such a detection should still exit 1 (safer; it is
   still a failed measurement) or exit with a distinguished status; exiting 1 with a correct label
   is sufficient and is the smaller change.
3. **Correct the stale header sentence** asserting the script is not wired into CI, stating the
   present wiring instead (the `evidence-probes` step and the aggregating report step that fails
   the job on its failure). Keep the surrounding historical narration about `specs/archive/`
   intact — only the CI-wiring claim is wrong.
4. **Record the dependency edge on 734** (or deliberately decline it, with a reason), since both
   tasks declare `scripts/check-evidence-probes.sh` in `file_scope` and 734 is `[PARTIAL]`.
5. **Do not edit any file under `specs/evidence/`.** Worth stating as an explicit plan non-goal,
   because the task description's three-remedy framing invites it.
6. **Optional validation of the fix**: reproduce the race deliberately — `touch` a mid-closure
   `FormalSystem` module, start a guarded `lake build` detached, and run the gate concurrently —
   then confirm the pre-fix script reproduces a missing-olean red and the post-fix script does
   not (it should instead announce the lock wait and then pass). This is the only way to verify
   the fix rather than merely observe a green gate, which is already green.

## Risks & Mitigations

- **Risk: concluding "green, nothing to do" and closing the task.** That restores the exact
  masking hazard the task was created to remove — the gate remains able to emit a false red, so
  the next plan naming it as a criterion can again be forced into a Reasoned Exclusion.
  *Mitigation*: Recommendation 1, which is a small, precedented change.
- **Risk: a reviewer reads this report as excusing the four probes without checking them.**
  *Mitigation*: the measurements are re-runnable in 84 s warm
  (`bash scripts/check-evidence-probes.sh`), and the archived error text is cited by path.
- **Risk: holding the lock for the whole run slows a concurrent build by up to ~84 s warm**, or
  considerably longer cold. *Mitigation*: bounded wait with an announced note, matching the
  invariants script; and this is strictly the intended trade (a slower green in place of a
  spurious red), which that script's header already records as the accepted resolution.
- **Risk: lock acquisition masks a genuine `.lake` absence** (e.g. the project was never built at
  all), turning a fast, clear failure into a 600 s wait. *Mitigation*: Recommendation 2's
  environment-failure label still fires in that case, because an unbuilt project produces the same
  missing-object-file error with no lock contention at all.
- **Risk: driver collision with task 734.** *Mitigation*: Recommendation 4.

## Tactic Survey Results

- Not applicable (no tactic survey performed). No proof goal was open in this task: the four
  probes compile as written, and no Lean source was edited.

## Context Extension Recommendations

- **Topic**: unguarded `lake` readers in repository-owned gate scripts.
  **Gap**: `.claude/rules/lean4.md` and `context/project/lean4/operations/long-builds.md` both
  document the guard-bypass hazard for `lake build` *writers*, and `long-builds.md` documents how
  to observe a build in flight. Neither names the symmetric hazard for a *reader* — a script that
  calls `lake env lean` (or any `.lake`-reading `lake` subcommand) in a loop and can observe
  half-rewritten build artifacts. The observable signature (`object file '...' does not exist`)
  and its correct attribution as an environment failure rather than a source failure are not
  written down anywhere an agent would find them while triaging a red gate.
  **Recommendation**: add a short section to `context/project/lean4/operations/long-builds.md`
  ("Unguarded readers see half-written artifacts"), naming the error signature, the
  `.lake/build-guard.lock` remedy with `check-module-invariants.sh`'s C1 block as the reference
  implementation, and the triage rule: a missing-object-file error is never probe or source rot.

## Appendix

### Commands run (all re-runnable)

- `bash scripts/check-evidence-probes.sh` — twice; both `PASS  all 33 wired probe(s) compile`,
  second run captured `EXIT=0` and `ELAPSED_S=84`.
- `lake env lean specs/evidence/seam-gluing-ray-product/{finite-graph-stab-summary,mosaic-germ-amalgamation,path-quantifier-alternation,backward-dual-asymmetric-fixture}.lean`
  — all four exit 0.
- `git log --format=... -- <each probe path>` — one creating commit each, no later commits.
- `git log -- FormalSystem/` — the only `FormalSystem` commit after the failing run touches
  `FormalSystem/Metalogic/README.md`.
- `find .lake/build/lib -name '*.olean' -newermt '2026-10-13 20:30'` — 21 files; the tail-module
  cluster at 21:11-21:12 and `LadderModel.olean` at 21:00.

### References

- `scripts/check-evidence-probes.sh` — header (probe convention, two entry forms, tracked-not-
  present rule), `WIRED` list (lines 1029-1062), `check_probe` (the bare `lake env lean` at line
  1128), failure guidance text at the foot.
- `scripts/check-module-invariants.sh` — the `C1: build` block and its lock rationale, including
  the two recorded rejected alternatives.
- `.claude/scripts/lake-build-guard.sh` — lock path convention (header), exclusive `flock`
  acquisition, and `cmd_status`'s non-blocking `flock -n` probe.
- `.claude/rules/lean4.md` — "The guard's mutex is real but opt-in" paragraph.
- `.github/workflows/ci.yml` — the `evidence-probes` step and the aggregating report step.
- `specs/778_residue_index_modulus_convention_record/` — `plans/01_...md` (the two Reasoned
  Exclusions tables), `summaries/01_...-summary.md`, `handoffs/phase-4-...md`,
  `handoffs/phase-6-...md`, `issues.jsonl` (the `gate-collision` entry), `metrics.jsonl`.
- `specs/786_evidence_probe_compile_failures_repair/issues.jsonl` — this dispatch's
  `wrong-premise` issue and `evidence-recovery` win.
