# Implementation Plan: Task #786

- **Task**: 786 - Harden `scripts/check-evidence-probes.sh` against the `.lake` read/write race and give it an environment-failure diagnostic class
- **Status**: [NOT STARTED]
- **Effort**: 3.25 hours
- **Dependencies**: None (the `dependencies[]` edge on 734 was dropped by recorded user decision, 2026-10-14)
- **Research Inputs**: `specs/786_evidence_probe_compile_failures_repair/reports/01_evidence-probe-compile-failures.md`
- **Artifacts**: plans/01_harden-evidence-probe-driver.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

All work lands in exactly one file, `scripts/check-evidence-probes.sh`, and closes the two
driver defects research established: it takes no lock on `.lake` while invoking `lake env lean`
33 times, and its failure vocabulary has no class for an environment/I/O failure, so a transient
missing-olean error is reported as though a probe's proof had rotted. The fix reuses the
in-repository precedent verbatim in shape — an `flock` on `$REPO_ROOT/.lake/build-guard.lock`,
the path `.claude/scripts/lake-build-guard.sh` publishes and `scripts/check-module-invariants.sh`
already takes at its `C1: build` block — rather than inventing a second lock. A third diagnostic
class then detects the missing-object-file error shape and labels it as an environment failure,
distinct from rot and from untracked. A stale header sentence claiming the script is not wired
into CI is corrected in the same pass, because a reader who believes it will mis-rank exactly
this failure mode. No probe file is touched and the wired manifest is unchanged.

### Research Integration

The plan is the research report's Recommendations 1-3 and 5-6, in that order, with Recommendation
4 (the dependency edge) already discharged by recorded user decision. Four findings shape the
phasing directly:

- The lock must be acquired **once for the whole run** and held to process exit, so the 33
  verdicts describe one consistent library snapshot — the same posture
  `check-module-invariants.sh` adopts by never releasing its fd.
- The detectable error shape is `object file '<path>' of module <Module> does not exist`, with
  four distinct tail modules observed across four consecutive WIRED entries in the originating
  run. That string is the detector's anchor.
- `lake env lean` is treated as a `.lake` *reader* that must take the same **exclusive** lock as
  a writer: both existing users of this lock path take exclusive locks, and `lake env` is not
  audited here as provably write-free.
- Research's Recommendation 6 (verify the fix, do not merely observe an already-green gate) is
  promoted to a full phase of deliberate negative controls, because a green gate is not evidence
  that either new code path works.

One finding this plan adds beyond the report: `scripts/generate-decidability-inventory.sh` is a
second consumer of this file. It regex-parses the `WIRED=(` / `WIRED_REPO=(` array anchors
(`^WIRED=\(\n...\n\)\n` with `^\s*"entry"\s*$` lines, behind an anti-silence guard that hard-fails
if the anchor moves), cites "the free-text comment table directly above `WIRED=(`", and under
`--compile-probes` derives `ALL_PASS`/`SOME_FAIL` from this script's **exit status** while
echoing its stdout verbatim under `--verbose`. Consequences honored below: insert no code between
the comment table and `WIRED=(`, leave both array blocks byte-identical, and keep the existing
`FAIL  N of M wired probe(s) failed` summary line intact rather than rewriting it.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context, so no roadmap consultation was
performed and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- `scripts/check-evidence-probes.sh` acquires the shared `$REPO_ROOT/.lake/build-guard.lock`
  `flock` once per run, holds it for the whole run, waits boundedly with an announced notice, and
  degrades audibly when `flock` is absent from `PATH`.
- A third diagnostic class names an environment/I/O failure (missing or half-written `.lake`
  artifact) as one, in both the per-probe line and the foot guidance text, so a reader can tell
  which of the three classes they are looking at.
- The header's stale "not wired into CI" claim is replaced by the present wiring, and the new
  lock and the three-class vocabulary are documented in place with rationale.
- `bash scripts/check-evidence-probes.sh` still exits 0 with all 33 wired probes PASS.
- Both new code paths (environment class, lock wait/timeout) are demonstrated by deliberate
  negative controls, not inferred from an already-green gate.

**Non-Goals**:
- **No file under `specs/evidence/` is created, modified, or deleted** — hard constraint. All
  four originally-named probes are live, still-wanted records; the no-weakening rule for wired
  probes applies and nothing here weakens, restates, or retires one.
- The `WIRED`, `WIRED_REPO`, and `DEFERRED` arrays and the comment tables above them are not
  edited: no probe is added, removed, or re-pointed.
- No change to `.github/workflows/ci.yml`, to `scripts/check-module-invariants.sh`, or to
  `.claude/scripts/lake-build-guard.sh`. The lock is joined, not re-specified.
- No change to the script's CLI (it still takes no arguments) and no new exit code: an
  environment-class failure still exits 1, with a correct label, which research established is
  the smaller and sufficient change.
- The context-extension recommendation in the research report (a "unguarded readers see
  half-written artifacts" section for `context/project/lean4/operations/long-builds.md`) is not
  implemented here: it targets the deployed `.claude/` tree, whose edits belong in the source
  store under a separate record.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 4's negative control removes a real `.olean` and fails to restore it, leaving `.lake` broken | H | M | Copy the olean into the scratchpad **before** removing it; restore in the same command chain; close the phase only after a green gate run re-measures exit 0 with 33 PASS. `lake build` regenerates it as a second recovery path |
| Code inserted near the `WIRED` arrays breaks `generate-decidability-inventory.sh`'s SRC2 anti-silence anchor | H | L | Insert the lock block *after* both array blocks and immediately before `failures=0`; leave the arrays and the comment table above `WIRED=(` byte-identical; verify with `bash scripts/generate-decidability-inventory.sh --diff` in Phase 4 |
| Phase 1/2 edits shift line numbers, so Phase 3's "lines 21-22" target moves | M | H | Phase 3 locates the stale sentence by its text (`grep -n 'not wired into CI'`), never by the line number this record quotes |
| The 600 s bounded wait masks a genuinely unbuilt project, converting a fast clear failure into a long wait | M | L | The environment class still fires in that case — an unbuilt project produces the same missing-object-file error with no contention at all. The wait is announced on stderr the moment it starts |
| Holding the lock for the whole run (~84 s warm, longer cold) delays a concurrent guarded build | L | M | This is the intended trade (a slower green in place of a spurious red) and the same accepted cost `check-module-invariants.sh` already pays; recorded in the in-place comment rather than re-litigated |
| Self-deadlock if the gate is ever invoked inside an outer holder of the same lock | M | L | The wait is bounded and announced, so the worst case is a labeled failure after the wait, never an unbounded hang; a header note states the constraint. `lake-build-guard.sh`'s `build` subcommand wraps only `lake build ...`, so the guard cannot nest this script today |
| Output-text changes break a downstream text consumer | M | L | The one known consumer reads exit status, not failure text; the existing `FAIL  N of M ...` summary line is preserved verbatim and the environment note is added as a separate following line |
| Driver collision with another live session (761 `[BLOCKED]`, 734 `[PARTIAL]` both declare this file in `file_scope`) | M | L | Both are idle with no execution evidence; the overlap was admitted rather than serialized by recorded decision. Confirm `git status --short scripts/check-evidence-probes.sh` is clean before the first edit and stage only this one file per commit |
| Correcting the stale CI sentence drifts into narrating the file's own edit history | L | M | `rules/no-record-versioning-in-deliverables.md` applies (this is a deliverable, not a `specs/**` artifact): state the present wiring only; never "this previously said", "no longer", or "formerly". The existing historical narration about the `specs/archive/` move is a fact about the probes' location, not draft lineage, and stays |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. Every wave here holds one phase: all four
phases edit or measure the same single file, so they are strictly serialized by construction.

### Phase 1: Acquire the shared `.lake` build lock [NOT STARTED]

**Goal**: The script serializes its 33 `lake env lean` reads against any other guarded build on
this tree, by taking the already-published shared lock once per run.

**Tasks**:
- [ ] Confirm the working tree is clean for this file (`git status --short scripts/check-evidence-probes.sh`) and confirm the current no-lock state (`grep -c flock scripts/check-evidence-probes.sh` returns 0).
- [ ] Re-read `scripts/check-module-invariants.sh`'s `C1: build` block (the `LOCK_FILE` / `C1_LOCK_FD` / `flock -n` then `flock -w 600` sequence) and mirror its shape, not a re-invention.
- [ ] Insert the acquisition block immediately before `failures=0`, i.e. after the `WIRED`, `WIRED_REPO`, and `DEFERRED` arrays — never between the comment table and `WIRED=(`.
- [ ] Define `REPO_ROOT="$(pwd)"` (valid: the script already `cd`s to the repository root) and `LOCK_FILE="$REPO_ROOT/.lake/build-guard.lock"`; `mkdir -p "$REPO_ROOT/.lake"` so a never-built clone can still take the lock.
- [ ] Acquire with `exec {PROBE_LOCK_FD}<>"$LOCK_FILE"`, then `flock -n`; on contention print one `check-evidence-probes: waiting on the shared build lock ($LOCK_FILE, up to ${PROBE_LOCK_WAIT_S}s)` notice to stderr and retry with `flock -w "$PROBE_LOCK_WAIT_S"`.
- [ ] Never release the fd (no `flock -u`): holding it to process exit is what covers every `check_probe` call for free.
- [ ] Add `PROBE_LOCK_WAIT_S="${PROBE_LOCK_WAIT_S:-600}"` as a documented env override whose sole purpose is making the timeout branch testable in Phase 4; default behavior is unchanged at 600 s.
- [ ] On `flock` absent from `PATH`, print `check-evidence-probes: flock not found on PATH; compile-checking probes unserialized` to stderr and continue (degrade audibly, never silently).
- [ ] On wait timeout, print a failure line naming the lock path and `exit 1` before any probe is attempted (Phase 2 re-words this under the shared environment-class vocabulary).
- [ ] Add the in-place rationale comment above the block: why a reader needs the writer's exclusive lock, that the lock is advisory and keyed on the path so this script and the deployed guard exclude each other with no reference from the repository into the disposable `.claude/` tree, and that the two rejected alternatives are recorded at `check-module-invariants.sh`'s `C1` block and are not re-litigated here.
- [ ] `bash -n scripts/check-evidence-probes.sh` and `shellcheck scripts/check-evidence-probes.sh` both clean (no new findings relative to the pre-edit baseline).
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 33 wired probe(s) compile`.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts exactly one file is modified, that the pre-edit script
takes zero locks, and that 33 wired probes PASS. Confirm at implementation time with
`git diff --stat` (one path only), `grep -c flock` on the pre-edit file (expect 0), and the
gate's own `all N wired probe(s)` line (expect N = 33); if N differs, record the measured value
rather than restating 33.

**Tier Justification**: The edit is confined to one standalone script with no sourcing importers
and no change to its CLI, exit codes, output lines, or the `WIRED`/`WIRED_REPO` anchors its one
dependent parses, and is covered by `bash -n scripts/check-evidence-probes.sh && shellcheck scripts/check-evidence-probes.sh && bash scripts/check-evidence-probes.sh`.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - add the `flock` acquisition block (plus its rationale comment and the `PROBE_LOCK_WAIT_S` default) immediately before `failures=0`

**Verification**:
- `grep -c flock scripts/check-evidence-probes.sh` is now non-zero and `grep -n 'build-guard.lock'` shows the published path, not a new one.
- `bash -n` clean; `shellcheck` reports nothing new.
- `bash scripts/check-evidence-probes.sh` exits 0, prints `PASS  all 33 wired probe(s) compile`, and prints no lock notice when uncontended (silence on the clean path).
- `git diff --stat` lists `scripts/check-evidence-probes.sh` and nothing else; `git diff -- specs/evidence/` is empty.

---

### Phase 2: Add the environment-failure diagnostic class [NOT STARTED]

**Goal**: A missing or half-written `.lake` artifact is reported as an environment failure, named
as such, and never again read as probe rot.

**Tasks**:
- [ ] Add an `env_failures=0` counter beside `failures=0` and a small predicate (e.g. `probe_env_failure`) that tests captured output for the missing-object-file shape `object file '<path>' of module <Module> does not exist`, anchored on that phrase rather than on any single module name.
- [ ] Include in the same predicate the adjacent artifact-absent shapes a never-built or mid-rewrite tree produces (for example a `no such file or directory` error naming a path under `.lake/`), and add a comment stating that the predicate is deliberately narrow: an unmatched failure must fall through to `FAIL (does not compile)`, because a false environment label would excuse genuine rot.
- [ ] In `check_probe`'s compile-failure branch, print `FAIL (environment: ...)` when the predicate matches — naming the `.lake` artifact absence and stating explicitly that this is **not** probe rot — and increment both `env_failures` and `failures`. Keep printing the indented captured output in both branches.
- [ ] Re-word Phase 1's lock-timeout failure to use this same environment-class vocabulary, so the three classes read consistently.
- [ ] Leave the existing `FAIL  $failures of $wired_total wired probe(s) failed` line byte-identical; when `env_failures` is non-zero, emit the environment note as a **separate following line**.
- [ ] Extend the foot guidance text with a third paragraph: an environment-class failure means the measurement never reached the probe's own content, so no probe is to be repaired, restated, or retired on that evidence; re-run once any concurrent `lake build` has finished, and if it persists with no other build running, the project is not built — run `lake build`.
- [ ] Verify the untouched classes still read correctly: the existing rot paragraph and the `FAIL (untracked: ...)` paragraph keep their current wording.
- [ ] `bash -n` and `shellcheck` clean; `bash scripts/check-evidence-probes.sh` exits 0 with 33 PASS (the new branch is unreachable on a healthy tree — it is exercised in Phase 4).

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts the detector needs exactly one anchor phrase, drawn from
the originating run's captured output as quoted verbatim in the research report's error table.
Confirm at implementation time by matching the predicate against that quoted text (and against
the archived `p4-gate.log` if it still exists in the originating scratchpad); if the live error
text in Phase 4's negative control differs from the quoted shape, widen the predicate to the
measured shape and record the difference rather than keeping the quoted one.

**Tier Justification**: This phase changes the script's stdout vocabulary, which is an externally
visible surface read by one enumerated direct dependent, `scripts/generate-decidability-inventory.sh`
(exit-status verdict plus verbatim stdout echo under `--compile-probes --verbose`), so the
covering check is the single-file pair `bash -n` + `shellcheck` **plus** that dependent:
`bash scripts/generate-decidability-inventory.sh --diff`.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - add `env_failures`, the environment-failure predicate, the third `FAIL (environment: ...)` branch in `check_probe`, the conditional summary note, and the third foot-guidance paragraph

**Verification**:
- `bash -n` clean; `shellcheck` reports nothing new.
- `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 33 wired probe(s) compile` and an unchanged clean-path output shape.
- `bash scripts/generate-decidability-inventory.sh --diff` still parses the `WIRED`/`WIRED_REPO` anchors (no `FAIL SRC2` anti-silence line) and reports no diff against the committed baseline.
- Reading the diff confirms all three classes are distinguishable in the per-probe line and each has its own foot paragraph.
- `git diff --stat` lists one path; the `WIRED=(`/`WIRED_REPO=(` blocks show no diff hunks.

---

### Phase 3: Truth up the header [NOT STARTED]

**Goal**: The header states the present CI wiring, the new lock, and the three-class diagnostic
vocabulary, so a reader triaging a red gate ranks this failure mode correctly.

**Tasks**:
- [ ] Locate the stale claim by text, not line number: `grep -n 'not wired into CI' scripts/check-evidence-probes.sh`.
- [ ] Replace that sentence with the present wiring: the script runs in CI as step id `evidence-probes` in `.github/workflows/ci.yml`, which is `continue-on-error: true` but is counted by the aggregating report step that exits 1 on any failure — so a rotted probe fails the job.
- [ ] Preserve the surrounding historical narration about the `specs/archive/` move and about why probes do not live in a task directory: only the CI-wiring claim is wrong. Re-word the sentence so the historical point (nothing announced either fact at the time) survives without asserting the present-tense claim.
- [ ] Honor `rules/no-record-versioning-in-deliverables.md`: state the current design only. No "previously", "no longer", "formerly", or any note that this sentence was corrected.
- [ ] Add a short `THREE DIAGNOSTIC CLASSES` header subsection naming rot (`does not compile`), left-version-control (`untracked:`), and environment (`environment:`), with the one-line triage rule that a missing-object-file error is never probe or source rot.
- [ ] Add a short header note that the script takes the shared `.lake/build-guard.lock` for its whole run, cross-referencing `check-module-invariants.sh`'s `C1` block for the rationale and rejected alternatives rather than restating them, and noting the bounded, announced wait and the `PROBE_LOCK_WAIT_S` override's test-only purpose.
- [ ] Update the `Exit status:` usage line so it covers the lock-timeout failure alongside the existing 0/1 contract.
- [ ] Confirm every hunk in this phase's diff lies inside the `#`-comment header region (no code line touched).

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: This record quotes the stale claim as living at `check-evidence-probes.sh:21-22`,
measured before Phases 1-2. That is a hypothesis about a line number that those phases shift.
Confirm by `grep -n 'not wired into CI'` at implementation time and edit at the measured location;
if the grep returns no hit, stop and re-read the header rather than editing by line number.

**Tier Justification**: Every hunk is confined to `#`-comment text with zero compile or
elaboration surface, and is covered by a `git diff -- scripts/check-evidence-probes.sh`
read-through confirming each changed line begins with `#`, plus `bash -n scripts/check-evidence-probes.sh`
as the mechanical backstop against an edit that escapes the comment region.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - correct the CI-wiring sentence; add the three-class and lock header subsections; update the `Exit status:` line

**Verification**:
- `grep -c 'not wired into CI' scripts/check-evidence-probes.sh` is 0; the replacement text names the `evidence-probes` step and the aggregating report step.
- `git diff` read-through: every changed line in this phase starts with `#`.
- `bash -n` clean; `bash scripts/check-evidence-probes.sh` exits 0 with 33 PASS.
- No record-versioning language introduced (`grep -nEi 'no longer|previously|formerly|used to' ` over the diff hunks returns nothing new in the edited region).

---

### Phase 4: Adversarial verification and the full gate set [NOT STARTED]

**Goal**: Both new code paths are demonstrated by deliberate negative controls rather than
inferred from an already-green gate, the hard constraint is proven, and the complete gate set is
observed green.

**Tasks**:
- [ ] **NC1 — environment class fires.** Copy a mid-closure olean (e.g. `.lake/build/lib/lean/FormalSystem/Examples.olean`) into the scratchpad, remove the original, run `bash scripts/check-evidence-probes.sh`, and record that affected probes report `FAIL (environment: ...)` (not `FAIL (does not compile)`), that the foot text shows the third paragraph, and that the script exits 1. Restore the olean immediately in the same command chain.
- [ ] **NC1 recovery.** Re-run the gate and record exit 0 with 33 PASS before proceeding. If the olean cannot be restored from the copy, run `lake build` to regenerate it and re-measure.
- [ ] **NC2 — lock wait is taken and announced.** Hold the lock from a bounded background holder (`flock .lake/build-guard.lock sleep 25 &`, capturing the PID), run the gate, and record that the `waiting on the shared build lock` notice appears on stderr and that the run then completes green once the holder exits. Follow `context/patterns/bounded-build-waiter.md` (hard timeout, `kill -0` on the captured PID) for any waiting.
- [ ] **NC3 — timeout branch fires.** With the lock held by a bounded background holder, run `PROBE_LOCK_WAIT_S=1 bash scripts/check-evidence-probes.sh` and record the environment-class timeout failure naming the lock path, exit 1, and that no probe was attempted.
- [ ] **NC4 — `flock`-absent degradation.** Run the gate with a `PATH` from which `flock` is absent and record the audible stderr notice plus an otherwise-green run. If this cannot be arranged cleanly on this host, record it as verified by read-through instead, explicitly, rather than claiming a measurement not taken.
- [ ] **Hard constraint proof.** `git status --short` and `git diff --stat` show `scripts/check-evidence-probes.sh` as the only modified path; `git diff -- specs/evidence/` is empty; `git diff` shows no hunk inside the `WIRED=(`, `WIRED_REPO=(`, or `DEFERRED=` blocks.
- [ ] **Green measurement of record.** `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 33 wired probe(s) compile`; capture the exit status and elapsed time explicitly rather than reading the text alone.
- [ ] **Dependent gate.** `bash scripts/generate-decidability-inventory.sh --diff` reports no `FAIL SRC2` anti-silence line and no diff against the committed baseline.
- [ ] **Full gate set.** `bash .claude/scripts/verify-deploy.sh` (the complete repository gate aggregator), plus the repository gates CI runs over this file's domain: `bash scripts/check-evidence-probes.sh`, `bash scripts/check-module-invariants.sh --no-build`, and `shellcheck scripts/check-evidence-probes.sh`. Record each one's exit status. Note that `check-module-invariants.sh` with a build would contend for the same lock by design; `--no-build` is what CI runs.
- [ ] Record each negative control's verbatim observed output in the phase handoff, so a reader can re-attribute the verdicts without re-running them.

**Timing**: 1.25 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts four negative controls suffice to cover the new code
paths and that the gate reports 33 wired probes. Confirm by enumerating the new branches from the
Phase 1-3 diff at implementation time and checking each is reached by one of NC1-NC4; if a branch
is uncovered, add a control or record it as read-through-verified with that stated explicitly.

**Files to modify**:
- None planned. This phase measures; it does not edit. Any repair this phase's measurements force is an edit to `scripts/check-evidence-probes.sh` and to no other path.

**Verification**:
- NC1, NC2, NC3 each observed with their verbatim output recorded; NC4 observed or explicitly recorded as read-through-verified.
- Post-NC1 recovery measured green (exit 0, 33 PASS) before the phase closes.
- `bash .claude/scripts/verify-deploy.sh` exits 0; `bash scripts/check-module-invariants.sh --no-build` exits 0; `shellcheck scripts/check-evidence-probes.sh` reports nothing new; `bash scripts/generate-decidability-inventory.sh --diff` exits clean.
- `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 33 wired probe(s) compile`.
- Exactly one file modified across the whole task; nothing under `specs/evidence/` touched.

---

## Testing & Validation

- [ ] `bash scripts/check-evidence-probes.sh` exits 0 and prints `PASS  all 33 wired probe(s) compile`.
- [ ] `grep -c flock scripts/check-evidence-probes.sh` is non-zero and the lock path is the published `$REPO_ROOT/.lake/build-guard.lock`, with no second lock introduced.
- [ ] The environment-failure class is demonstrated firing on a deliberately displaced olean, and the output names it as not probe rot.
- [ ] The lock wait notice, the bounded timeout failure, and the `flock`-absent degradation are each demonstrated or explicitly recorded as read-through-verified.
- [ ] `grep -c 'not wired into CI' scripts/check-evidence-probes.sh` is 0 and the header names the `evidence-probes` CI step and its aggregator.
- [ ] `bash -n` and `shellcheck` clean on the edited script.
- [ ] `bash scripts/generate-decidability-inventory.sh --diff` parses the array anchors and reports no diff.
- [ ] `bash .claude/scripts/verify-deploy.sh` and `bash scripts/check-module-invariants.sh --no-build` both exit 0.
- [ ] `git diff --stat` across the task lists exactly one path; `git diff -- specs/evidence/` is empty.

## Artifacts & Outputs

- `scripts/check-evidence-probes.sh` — locked, three-class, header-corrected driver (the only modified file).
- `specs/786_evidence_probe_compile_failures_repair/plans/01_harden-evidence-probe-driver.md` — this plan, with per-phase status markers updated as phases close.
- Per-phase handoffs under `specs/786_evidence_probe_compile_failures_repair/handoffs/`, with Phase 4's carrying the verbatim negative-control output.
- One commit per phase, scoped to the single edited file (Phase 4 commits only if a measurement forces a repair).
- `specs/786_evidence_probe_compile_failures_repair/summaries/01_harden-evidence-probe-driver-summary.md` at completion.

## Rollback/Contingency

- Every phase commits separately and stages only `scripts/check-evidence-probes.sh`, so any phase
  is reversible with `git revert` of its commit; no destructive git on a dirty tree is needed or
  permitted.
- If NC1 leaves `.lake` inconsistent, restore the copied olean from the scratchpad; failing that,
  `lake build` regenerates it. Do not close Phase 4 until a green gate run re-measures exit 0.
- If the environment-class predicate proves unable to distinguish an I/O failure from a genuine
  elaboration error without false positives, keep the lock (Phase 1, the substantive fix) and
  narrow the predicate to the exact observed missing-object-file phrase only, recording the
  narrowing and its reason in the phase handoff — a missed environment failure is recoverable, a
  rot mislabeled as environment is not.
- If the lock proves to deadlock against an unforeseen caller, the bounded wait already degrades
  to a labeled failure rather than a hang; the contingency is to shorten the default wait and
  record the caller, not to drop the lock.
