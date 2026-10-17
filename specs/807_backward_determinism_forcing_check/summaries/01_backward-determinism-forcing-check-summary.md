# Implementation Summary: Task #807

- **Task**: 807 - Backward-determinism forcing check: can a closed L⁺ formula force backward closure on a regular ℤ-frame?
- **Status**: [COMPLETED]
- **Started**: 2026-10-17T14:41:31Z
- **Completed**: 2026-10-17T14:54:20Z
- **Effort**: ~25 minutes
- **Dependencies**: 809 (discharged before dispatch)
- **Artifacts**: plans/01_backward-determinism-forcing-check.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The verdict is **POSITIVE — a forcing formula exists**. The closed L⁺ formula
`(q S ⊥) → ⊡(q S ⊥)` ("yesterday `q` is settled") is valid on a regular ℤ-frame **iff** the frame is
backward deterministic; it is refuted on the backward-branching `Probe733Mirror` and valid on the
backward-deterministic, forward-branching `Probe719Backward`, so it forces backward and not forward
determinism. The research round's compiled draft was promoted to a wired evidence probe, the two
programme documents that called this risk "unrealized" now record the realized verdict with the
Stage 0 ruling pending, and the probe is registered as the thirty-ninth `WIRED` entry. **The
know-time-do-not-forget reduction was NOT attempted and no undecidability is claimed.**

## What Changed

- `specs/evidence/seam-gluing-ray-product/backward-determinism-forcing-formula.lean` — new wired probe
  (1365 lines). Namespace `Probe807Forcing`: `yest`, `bdForce`, `HistBwdDet` (Thomason 1984 §4
  Def. 6(2), one-step synchronous form), `StepBwdDet` (unique predecessors), `yest_iff`,
  `histBwdDet_of_valid` (singleton valuation `|q| = {τ(t−1)}`), `valid_of_histBwdDet`,
  `valid_iff_histBwdDet`, `histBwdDet_iterate`, `histBwdDet_of_stepBwdDet`,
  `stepBwdDet_of_histBwdDet` (via `exists_worldHistory_two_point`), `valid_iff_stepBwdDet`. Both
  fixtures transcribed byte-identically from the current wired originals (`diff` empty); instantiations
  `Probe733Mirror.not_histBwdDet` / `bdForce_not_valid` / `not_stepBwdDet` and
  `Probe719Backward.stepBwdDet_node` / `stepBwdDet` / `forward_branching` / `bdForce_valid`.
  Axiom record, verbatim:
  - `'Probe807Forcing.valid_iff_histBwdDet' depends on axioms: [propext, Quot.sound]`
  - `'Probe807Forcing.valid_iff_stepBwdDet' depends on axioms: [propext, Classical.choice, Quot.sound]`
  - `'Probe733Mirror.bdForce_not_valid' depends on axioms: [propext, Classical.choice, Quot.sound]`
  - `'Probe733Mirror.not_stepBwdDet' depends on axioms: [propext, Classical.choice, Quot.sound]`
  - `'Probe719Backward.bdForce_valid' depends on axioms: [propext, Classical.choice, Quot.sound]`
  - `'Probe719Backward.forward_branching' does not depend on any axioms`
- `scripts/check-evidence-probes.sh` — decision-row block labelled **POSITIVE (forcing formula
  exists)** below `realizable-type-certificate`, and the 39th `WIRED` entry (no task number in the file).
- `specs/ROADMAP.md` — Stage 1 risk row now **REALIZED (closed check, positive verdict; 807)** …
  "**Stage 0 ruling pending.**"; lead-in reworded ("the first unrealized, the second now realized with
  its Stage 0 ruling pending"); one Stage 0 checkbox "Rule on **807**'s positive verdict" with options
  (A, recommended) / (B) / (C); `/orchestrate 815,807` lines reduced to `815`; the "807 is dispatchable
  now" paragraph replaced by a closed notice.
- `specs/literature/README.md` — closing sentence of "The L⁺ position in the corpus" replaced by the
  POSITIVE verdict, the knowledge-and-time dictionary (`⊡` = single-agent synchronous perfect-recall
  knowledge with the world state as observation; `□` = same-time universal modality; state-local atoms =
  observable local state), "The reduction itself is NOT attempted and no undecidability is claimed", and
  the Stage 0 pointer.
- `specs/807_backward_determinism_forcing_check/issues.jsonl` — `follow_up_task` entry for the transfer
  question (option A's follow-up, to be created at the conclusion stage), one `win`, one `gate-collision`.

## Decisions

- Fixture namespaces `Probe733Mirror` / `Probe719Backward` kept verbatim: byte-identical transcription
  is what makes the drift check mechanical; the header's citation-hygiene paragraph qualifies every
  cross-file citation by file.
- `first | rfl | simp | (congr 1; norm_num)` at `not_histBwdDet` reduced to its live `rfl` arm: the
  draft's log showed the other arms unreachable (four linter warnings); the file now compiles with zero
  warnings.
- The reduction is not attempted and the Stage 0 ruling is not made; the ROADMAP/README edits are
  factual records with "ruling pending" stated in the text (non-blocking `user_decision` from the
  research round, option A executed per the user-decision contract).

## Plan Deviations

- **Phase 3, "Run every command under Verification"** altered: per the dispatch's Batch Gate Deferral
  directive, `verify-deploy.sh` was deferred to the batch stage (no gate of it covers a file this task
  touched); `check-module-invariants.sh` exited 1 on INV alone — three stale generated inventory blocks
  (README.md, FormalSystem/README.md, FormalSystem/Metalogic/README.md) differing by one pre-existing
  `Decidability/` module committed before this task's baseline (`4155ee185` is an ancestor of
  `08c4fe687`; no library-tree file changed since). Outside this task's files; recorded, not fixed.
- No other deviations (fixture drift did not materialize; all Phase 1–2 items executed as written).

## Verification

- Build: Success — full `lake build` via the guard, detached: exit 0, `Build completed successfully
  (2875 jobs)`, 0 `error:` lines; `FormalSystem.olean` newer than source. (The probe sits outside the
  build graph by design and is covered by its own guarded compile: exit 0, 0 warnings, 0 errors, 16
  `#print axioms` lines.)
- Sorry count: 0 (roots and probe; `lean-sorry-census.sh`)
- Vacuous count: 0 in this task's files. The repository-wide grep matches one pre-existing line,
  `FormalSystem/Examples/TemporalStructures.lean:495` (`:= trivial` on a goal that is `True` by
  definition), present unchanged at the baseline and untouched here.
- Axiom count: 14 (baseline 14; unchanged). `native_decide`: 0.
- Tests: N/A (no test suite covers `specs/**` or `scripts/check-evidence-probes.sh`'s table); the
  registry guard itself: `check-evidence-probes.sh` exit 0, `all 40 wired probe(s) compile` (39 `WIRED`
  + 1 `WIRED_REPO`); `bash -n` exit 0; `check-task-references.sh --quiet` exit 0.
- Gate deferred to the batch stage: `verify-deploy.sh`. Gate failed for a pre-existing reason outside
  this task's files: `check-module-invariants.sh` (INV only) — see Plan Deviations.
- Files verified: Yes — `git diff --stat 08c4fe687 HEAD -- FormalSystem/ Tests/ docs/` is empty; every
  `undecidab` hit across the four edited prose/comment sites negates the claim; plan compliance: all 12
  Goals declared in the probe; drift `diff`s empty; `Scratch807` count 0.

## Impacts

- The Stage 1 risk table no longer lists this route as unrealized: the know-time-do-not-forget family is
  now a candidate reduction target, and the transfer question (whether relativizing finitely many
  `Yχ → ⊡Yχ` instances reaches a non-r.e. row of Halpern–van der Meyden–Vardi 2004's Table 1, or the
  single-agent row that "simplifies") is a Stage 0 ruling the user must make.
- `Probe807Forcing.valid_iff_histBwdDet` is a choice-free frame-definability result available to any
  later probe (by transcription, per the collection's import rule).
- `ROADMAP.md` no longer schedules this task.

## Follow-ups

- Stage 0 ruling on the verdict (user; options A/B/C stated in `specs/ROADMAP.md`).
- Conclusion stage: create the transfer-question task from the `follow_up_task` issue entry (option A).
- Batch stage: run the deferred `verify-deploy.sh`; regenerate the three stale inventory blocks
  (`bash scripts/check-module-invariants.sh --emit-inventory`) under the owning task.
- Out of this task's scope (research Context Extension Recommendation 1): a
  `.claude/context/project/lean4/` note on "yesterday"/"tomorrow" over ℤ.

## References

- specs/807_backward_determinism_forcing_check/plans/01_backward-determinism-forcing-check.md
- specs/807_backward_determinism_forcing_check/reports/01_backward-determinism-forcing-check.md
- specs/807_backward_determinism_forcing_check/research-scratch/807-forcing-check-draft.lean (+ .log)
- specs/evidence/seam-gluing-ray-product/backward-determinism-forcing-formula.lean
- specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean
- specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean
- scripts/check-evidence-probes.sh; specs/ROADMAP.md; specs/literature/README.md
