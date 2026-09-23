# Implementation Plan: Repair the filtered-frame-is-universal evidence probe

- **Task**: 660 - Repair check-evidence-probes.sh: phase7-filtered-frame-is-universal does not compile
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Dependencies**: None (task 661 depends on this task; 660 must fully complete first)
- **Research Inputs**: `specs/660_repair_check_evidence_probes_filtered_frame/reports/01_repair-filtered-frame-probe.md`
- **Artifacts**: plans/01_repair-filtered-frame-probe.md (this file), summaries/01_repair-filtered-frame-probe-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`scripts/check-evidence-probes.sh` cannot exit 0 because one of its five wired probes,
`specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`, no longer
compiles. Research pinned the cause to a transparency-level matching failure — the probe's `simp`
unfolds `RefinedFilteredTaskFrame`, and the resulting application is not type-correct at
`implicit` transparency because `RefinedFilteredTaskFrame._proof_4` carries an unfolded
`TaskFrame.Limit` shape. The repair is therefore not a lemma substitution and not a restatement:
replace the three tactic blocks with the compiler-verified term-mode proofs that cite the
library's own per-frame bridge `RefinedFilteredTaskFrame.rel_iff`, leaving all three `example`
signatures byte-identical. Done means the probe file compiles with exit 0 and no warnings, and
`bash scripts/check-evidence-probes.sh` reports all five wired probes passing and exits 0.

### Research Integration

The research report supplies a repair that was already compiled end-to-end (`lake env lean`, exit
0, zero errors, zero warnings) against the probe's exact imports, opens, and statements, so this
plan transcribes verified proof terms rather than proposing candidates. Three findings shape the
phase structure:

- **The cited-lemma drift named in the task description is a red herring.** Substituting
  `ofReflectiveRegular_taskRel_eq` for `ofReflective_taskRel_eq` leaves the identical unsolved
  goal and the identical `unusedSimpArgs` warning. Phase 1 must not attempt it.
- **`RefinedFilteredTaskFrame.rel_iff` (`Filtration.lean:359`) is the designated bridge**, proved
  by term application at default transparency, and is already the route the four downstream axiom
  theorems take. `TaskFrame.lean:1300-1306`'s docstring explicitly instructs that each frame
  states its own bridge rather than unfolding the constructor; the probe is the only site in the
  repository that broke that convention, and the only one that fails.
- **Term mode, not tactic mode.** The failure class lives inside tactic matching; term-mode proofs
  sidestep it entirely and leave the file warning-free. A tactic-mode variant also compiles and is
  recorded below as the contingency, not the primary.

Research recommendation 4 is adopted: `lake build` is not the acceptance gate for this repair
(the probe is outside the build graph and no library file changes). It is run in Phase 2 only as
a no-regression confirmation, never as the criterion that decides success.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided with this dispatch.

## Goals & Non-Goals

**Goals**:
- Make `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean` compile
  with exit 0 and empty output (no errors, no warnings).
- Restore `bash scripts/check-evidence-probes.sh` to `PASS`, all 5 wired probes, exit 0.
- Preserve all three `example` statements character-for-character, honouring the script's
  no-weakening rule literally: only proof bodies change.
- Leave a one-line in-file comment naming the transparency reason, so the next contributor
  reaching for `simp` does not re-run this incident.

**Non-Goals**:
- No change to any file under `FormalSystem/`. In particular, restating
  `TaskFrame.limit_of_permissive` / `limit_of_succOrder` / `limit_of_shift` with return type
  `TaskFrame.Limit R` is explicitly out of scope: it reverses a documented decision at
  `TaskFrame.lean:700-706` and touches at least five frames. Research recommendation 5 records it
  as a separate task to be argued on its own merits.
- No change to `scripts/check-evidence-probes.sh`. Repairing the one file is sufficient.
- No work on the deferred probe `spike-untl-unfolding-and-fwd-obstruction`, which remains
  deliberately unwired pending frame-class uniformity work.
- No restatement of the obstruction against the regular constructor. The task description offered
  this; research found it unnecessary and not recommended.
- No authoring of the suggested `.claude/context/project/lean4/patterns/frame-bridge-lemmas.md`
  pattern note. `.claude/**` is a disposable deploy artifact (see
  `.claude/rules/source-store-deploy-boundary.md`) and the note belongs in the source store under
  its own task; the in-file comment in Phase 1 carries the immediately useful part of that
  knowledge.

### Lean Challenge Statements — deliberately absent

This plan's `task_type` is `lean4`, but the `## Lean Challenge Statements` section is
intentionally omitted rather than left empty or filled with invented names. That section's hard
requirement is that the identifier set it declares equal the identifier set named under
`- **Goals**:`. This task proves no named declarations: the probe contains three anonymous
`example`s whose signatures must remain byte-identical, so both identifier sets are empty and a
Challenge module would have nothing to pin. Recording the reason here keeps the omission
auditable instead of looking like an oversight.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The repair is read as weakening the obstruction the probe records | H | L | Keep the three `example` signatures byte-identical; Phase 2 verifies this mechanically with `git diff` restricted to proof bodies, and the summary states it explicitly |
| Implementer reaches for the "obvious" lemma substitution instead of the verified term proofs | M | M | Research tested it: it fails identically. Phase 1 tasks name the exact terms to write and forbid the substitution |
| Term-mode proof fails in place despite compiling standalone in research | M | L | Research compiled against the probe's exact imports, opens, and statements. If it still fails, the recorded tactic-mode fallback is in Rollback/Contingency below |
| A future frame-API change breaks the probe again | M | M | Citing `RefinedFilteredTaskFrame.rel_iff` binds the probe to a named library lemma the four axiom theorems also depend on, so such a change would break `lake build` too and be caught in-graph rather than only by this out-of-graph gate |
| The latent unfolded-`Limit` trap is left open for other `ofReflectiveRegular` call sites | L | H | Accepted for this task: no live failure exists anywhere in `FormalSystem/`. Recorded as research recommendation 5, a separate task |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Replace the three tactic proofs with verified term-mode proofs [COMPLETED]

**Goal**: `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`
compiles with exit 0 and empty output, with all three `example` signatures unchanged.

**Tasks**:
- [x] Read the probe file and confirm its current shape: three `example`s at lines 9-12, 16-21,
      and 25-29, each proved by a `simp` citing `FrameOver.ofReflective_taskRel_eq`. *(confirmed verbatim)*
- [x] Replace Probe A's proof body (`by simp [...]`) with the term
      `(RefinedFilteredTaskFrame.rel_iff intOrder phi w 1 u).mpr (Or.inl one_ne_zero)`.
- [x] Replace Probe B's proof body (`by intro n; simp [...]`) with the term
      `fun n => (RefinedFilteredTaskFrame.rel_iff intOrder phi (f n) 1 (f (n + 1))).mpr (Or.inl one_ne_zero)`.
- [x] Replace Probe C's proof body (`by simp [...]`) with the term
      `(RefinedFilteredTaskFrame.rel_iff intOrder phi w d u).mpr (Or.inl hd)`.
- [x] Do NOT substitute `ofReflectiveRegular_taskRel` / `ofReflectiveRegular_taskRel_eq` into the
      existing `simp` calls. Research compiled that variant: it leaves the identical unsolved goal
      and the identical unused-lemma warning.
- [x] Leave the imports, the three `open` lines, the three `example` signatures, and the three
      explanatory comments (lines 8, 14-15, 23-24) exactly as they are. *(deviation: altered — the
      three statements are byte-identical, but each signature's trailing ` := by` became ` :=`;
      dropping the `by` proof-mode marker is unavoidable for a term-mode proof and changes no
      part of the proposition)*
- [x] Confirm research recommendation 2: check whether any inline comment names the broken
      citation `ofReflective_taskRel_eq`. It currently does not, so expect no comment edit here.
- [x] Add one short comment above Probe A naming why the bridge lemma is cited rather than
      unfolding the frame — the `_proof_4` unfolded-`TaskFrame.Limit` transparency reason — with a
      pointer to `FormalSystem/Semantics/TaskFrame.lean`'s `ofReflective_taskRel` docstring.
- [x] Run `lake env lean specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`
      and confirm exit 0 with empty output. *(exit 0, empty output)* A warning (including `unusedSimpArgs`) is a failure of
      this phase, not a pass.
- [x] Commit the file once green.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the edit is confined to exactly one file
(`specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`) and to exactly
three proof bodies plus one added comment, with zero changes under `FormalSystem/` or `scripts/`.
Confirm at implementation time with `git status --short` (exactly one modified path) and
`git diff -- specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`
(every removed/added line lies inside a proof body or is the new comment; no `example` signature
line appears in the diff).

**Files to modify**:
- `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean` - three `by
  simp [...]` proof bodies replaced by term-mode proofs citing
  `RefinedFilteredTaskFrame.rel_iff`; one explanatory comment added

**Verification**:
- `lake env lean specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`
  exits 0 and prints nothing.
- `git diff` on the probe shows no change to any line beginning `example` or to any line of the
  three `example` signatures.
- No `sorry` and no new axiom appears in the file (`grep -n 'sorry\|axiom'` returns nothing).

---

### Phase 2: Run the full gate and confirm the probe suite is green [COMPLETED]

**Goal**: `bash scripts/check-evidence-probes.sh` reports all five wired probes passing and exits
0, with no regression elsewhere.

**Tasks**:
- [x] Run `bash scripts/check-evidence-probes.sh` and confirm exit 0 with all five wired probes
      `PASS` and `spike-untl-unfolding-and-fwd-obstruction` still `SKIP (deferred)`. *(exit 0;
      banner reads `PASS  all 5 wired probe(s) compile`; Scope Hypothesis confirmed: 5 wired + 1
      deferred)*
- [x] Confirm the deferred probe's status is unchanged from the documented baseline — this task
      must neither wire it nor alter its deferral. *(still `SKIP (deferred: frame-class uniformity
      work)`; `scripts/check-evidence-probes.sh` untouched)*
- [x] Run `lake build` as a no-regression confirmation only. Because no file under
      `FormalSystem/` changed, this is expected to be a cached no-op; it is not the acceptance
      criterion for the repair (research recommendation 4). Record its result either way. *(exit
      0, `Build completed successfully (2725 jobs)`, zero `error:` lines)*
- [x] Re-read the final diff for the whole task and confirm it touches exactly the one probe file.
      *(`git diff --name-only HEAD~1 HEAD`: the probe plus two `specs/660_.../` artifacts; zero
      paths under `FormalSystem/`, `Tests/`, `BimodalTools/`, or `scripts/`)*
- [x] Commit any remaining task artifacts and close the phase.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts the gate has exactly 6 probes — 5 wired plus 1
deferred — and that repairing the single failing file moves the suite from `FAIL 1 of 5` to a
clean pass. Confirm at implementation time by reading the script's actual output banner rather
than assuming the counts: the printed tally must name 5 wired probes and the exit status must be
0. If the script reports a different wired count than 5, stop and report the discrepancy rather
than adjusting the expectation silently.

**Files to modify**:
- None. This phase is verification and commit only.

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0; output shows `PASS` for
  `phase3-scan-bound-is-false`, `phase7-filtered-frame-is-universal`,
  `phase12-check-not-compositional`, `phase10-origin-anchoring-obstruction`, and
  `mixed-sign-composition-obstruction`, and `SKIP (deferred)` for
  `spike-untl-unfolding-and-fwd-obstruction`.
- `lake build` completes without new errors.
- `git diff` across the task's commits touches exactly
  `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean` plus
  `specs/660_repair_check_evidence_probes_filtered_frame/**` artifacts.

---

## Testing & Validation

- [x] `lake env lean specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`
      exits 0 with empty output — no errors and no warnings.
- [x] `bash scripts/check-evidence-probes.sh` exits 0 and reports all 5 wired probes passing.
- [x] The three `example` signatures in the probe are byte-identical to their pre-repair form.
      *(deviation: altered — the three propositions are byte-identical; each signature's trailing
      ` := by` became ` :=`, the proof-mode marker term mode requires)*
- [x] The probe contains no `sorry` and introduces no axiom.
- [x] No file under `FormalSystem/` or `scripts/` is modified.
- [x] `lake build` shows no regression.

## Artifacts & Outputs

- Modified: `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`
- `specs/660_repair_check_evidence_probes_filtered_frame/summaries/01_repair-filtered-frame-probe-summary.md`
  (written at implementation completion), stating explicitly that the three `example` statements
  are unchanged and the diff is confined to proof bodies
- Commits following `.claude/rules/git-workflow.md` conventions

## Rollback/Contingency

The change is confined to one file and is committed at the end of Phase 1, so after that point
rollback is a `git revert` of that single commit — no working-tree discard is involved and no
snapshot is needed.

Before that commit, if the working tree must be discarded to recover, follow
`context/contracts/recovery.md`'s rollback rung for the sanctioned snapshot-then-rollback
invocation shape (including its out-of-scope override flag) rather than running a bare
destructive git command.

**Technical contingency** if a term-mode proof unexpectedly fails to elaborate in place: research
compiled and recorded a tactic-mode fallback for the same statements —

```
show (RefinedFilteredTaskFrame intOrder phi).TaskRel w 1 u
exact FrameOver.ofReflectiveRegular_taskRel.mpr (by simp [refinedFilteredTaskRel])
```

This is a viable substitute but is the second choice: it may reintroduce warnings that the
term-mode version avoids, and Phase 1's empty-output criterion still applies. Do not fall back to
weakening or deleting any `example` — the gate's own failure banner forbids it.
