# Implementation Summary: Task #660

- **Task**: 660 - Repair check-evidence-probes.sh: phase7-filtered-frame-is-universal does not compile
- **Status**: [COMPLETED]
- **Started**: 2026-09-23T09:05:32Z
- **Completed**: 2026-09-23T09:20:00Z
- **Effort**: ~20 minutes
- **Dependencies**: None (task 661 depends on this task)
- **Artifacts**: plans/01_repair-filtered-frame-probe.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The evidence-probe gate `scripts/check-evidence-probes.sh` could not exit 0 because one of its
five wired probes, `phase7-filtered-frame-is-universal.lean`, no longer compiled: its `simp`
unfolded `RefinedFilteredTaskFrame`, whose `_proof_4` carries a definitionally-unfolded
`TaskFrame.Limit`, so the unfolded application is not type-correct at the transparency `simp`
works at and no syntactic rewrite matched. All three proof bodies were replaced with term-mode
proofs citing the frame's own bridge lemma `RefinedFilteredTaskFrame.rel_iff` — the route the
four downstream axiom theorems already take. The gate now passes all five wired probes at exit 0.

## What Changed

- `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean` — three
  `by simp [...]` proof bodies replaced by term-mode proofs; one 5-line comment added above Probe A
  recording the transparency reason and pointing at `FormalSystem/Semantics/TaskFrame.lean`'s
  `ofReflective_taskRel` docstring. The three proved propositions (all anonymous `example`s):
  - Probe A: `(FiniteFilteredTaskFrame intOrder phi).toFrameOver.step w u`, now
    `(RefinedFilteredTaskFrame.rel_iff intOrder phi w 1 u).mpr (Or.inl one_ne_zero)`
  - Probe B: `IsStepPath (FiniteFilteredTaskFrame intOrder phi).toFrameOver f`, now
    `fun n => (RefinedFilteredTaskFrame.rel_iff intOrder phi (f n) 1 (f (n + 1))).mpr (Or.inl one_ne_zero)`
  - Probe C: `(FiniteFilteredTaskFrame intOrder phi).TaskRel w d u`, now
    `(RefinedFilteredTaskFrame.rel_iff intOrder phi w d u).mpr (Or.inl hd)`

No file under `FormalSystem/`, `Tests/`, `BimodalTools/`, or `scripts/` was modified.
`scripts/check-evidence-probes.sh` itself is untouched, and the deferred probe
`spike-untl-unfolding-and-fwd-obstruction` remains deliberately unwired.

**The three obstruction statements are not weakened.** Each `example`'s proposition is
byte-identical to its pre-repair form; the only change on a signature line is the trailing
` := by` becoming ` :=`, the proof-mode marker that term mode requires. Nothing was deleted,
generalized, or hypothesis-strengthened.

## Decisions

- Cited `RefinedFilteredTaskFrame.rel_iff` (`FormalSystem/Metalogic/Decidability/FMP/Filtration.lean:362`)
  rather than any `ofReflective*_taskRel*` simp lemma. The plan forbade the "obvious"
  `ofReflectiveRegular_taskRel_eq` substitution because research had already compiled that variant
  and found it leaves the identical unsolved goal and unused-lemma warning; it was not attempted.
- Term mode rather than tactic mode, so no tactic-level transparency question arises. The recorded
  tactic-mode contingency was not needed — the term proofs elaborated in place on the first run.
- The comment was placed above Probe A and scoped to all three probes, rather than repeated three
  times.

## Plan Deviations

- **Phase 1, "Leave ... the three `example` signatures ... exactly as they are"** altered: the
  three propositions are byte-identical, but each signature's trailing ` := by` became ` :=`.
  Dropping the `by` proof-mode marker is unavoidable for a term-mode proof and changes no part of
  the proposition. The plan's own Phase 1 tasks prescribe exactly these term-mode replacements, so
  this is an artifact of how the plan's verification criterion was worded, not a departure from
  its intent.

## Verification

- Build: Success — `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
  detached, exit 0, `Build completed successfully (2725 jobs)`, zero `error:` lines. This task
  changed no module in the build graph (the probe compiles outside it), so the build is a
  no-regression confirmation only, not the acceptance gate — as research recommendation 4 and the
  plan both specify.
- Probe compile: `lake env lean specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`
  exits 0 with completely empty output — no errors and no warnings (the `unusedSimpArgs` warning
  the old `simp` produced is gone).
- Evidence-probe gate: `bash scripts/check-evidence-probes.sh` exits 0. Banner reads
  `PASS  all 5 wired probe(s) compile`, with `PASS` for `phase3-scan-bound-is-false`,
  `phase7-filtered-frame-is-universal`, `phase12-check-not-compositional`,
  `phase10-origin-anchoring-obstruction`, and `mixed-sign-composition-obstruction`, and
  `SKIP (deferred: frame-class uniformity work)` for `spike-untl-unfolding-and-fwd-obstruction`.
  The plan's Scope Hypothesis (6 probes: 5 wired + 1 deferred) is confirmed against the actual
  banner.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots; empty inventory). The
  probe itself contains no `sorry` and no `axiom`.
- Vacuous count: 1 — a pre-existing baseline at
  `FormalSystem/Examples/TemporalStructures.lean:495` (`int_domain_universal ... := trivial`),
  in a file this task never touched. 0 introduced by this task.
- Axiom count: 14 — unchanged pre-existing baseline; 0 introduced. `git diff --name-only HEAD~1 HEAD`
  shows zero paths under any resolved source root, so both baselines are untouched by construction.
- Tests: N/A (no test-suite change; the evidence-probe gate is the relevant suite and it passes).
- Files verified: Yes.

## Impacts

- `scripts/check-evidence-probes.sh` is green again and can be relied on as a gate by downstream
  work. The frame-constraints audit that surfaced this failure had closed its gate phase
  `[COMPLETED WITH EXCLUSIONS]` because of it; that exclusion no longer has a live cause.
- The probe is now bound to the named library lemma `RefinedFilteredTaskFrame.rel_iff` that the
  four `RefinedFilteredTaskFrame_*` axiom theorems also depend on. A future frame-API change that
  would break the probe now breaks `lake build` too, so it is caught in-graph rather than only by
  this out-of-graph gate.
- The probe stops being the one site in the repository that unfolds a frame constructor instead of
  citing its bridge, restoring the convention `TaskFrame.lean`'s `ofReflective_taskRel` docstring
  prescribes.

## Follow-ups

- The latent unfolded-`TaskFrame.Limit` trap remains open for other `ofReflectiveRegular` call
  sites. No live failure exists anywhere under `FormalSystem/`, so nothing is broken; research
  recommendation 5 records restating `TaskFrame.limit_of_permissive` / `limit_of_succOrder` /
  `limit_of_shift` with return type `TaskFrame.Limit R` as a separate task, to be argued on its own
  merits — it reverses a documented decision at `TaskFrame.lean:700-706` and touches at least five
  frames.
- A pattern note on frame bridge lemmas was suggested by research but deliberately not authored
  here: it belongs in the agent-system source store, not in the disposable `.claude/` deploy tree
  (see `.claude/rules/source-store-deploy-boundary.md`). The in-file comment carries the
  immediately useful part.
- `spike-untl-unfolding-and-fwd-obstruction` remains deferred pending frame-class uniformity work.
  This task neither wired it nor altered its deferral.

## References

- `specs/660_repair_check_evidence_probes_filtered_frame/plans/01_repair-filtered-frame-probe.md`
- `specs/660_repair_check_evidence_probes_filtered_frame/reports/01_repair-filtered-frame-probe.md`
- `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`
- `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean:362` — `RefinedFilteredTaskFrame.rel_iff`
- `FormalSystem/Semantics/TaskFrame.lean:1292-1305` — `ofReflective_taskRel` and its docstring
- `scripts/check-evidence-probes.sh`
