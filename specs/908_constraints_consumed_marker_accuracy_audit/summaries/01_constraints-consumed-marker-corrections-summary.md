# Implementation Summary: Task #908

- **Task**: 908 - Constraints-consumed marker accuracy audit
- **Status**: [COMPLETED]
- **Started**: 2026-11-11
- **Completed**: 2026-11-11
- **Effort**: 8 phases across orchestration cycles 7-15
- **Dependencies**: None
- **Artifacts**: plans/01_constraints-consumed-marker-corrections.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All eight phases are complete. The audit examined 68 `Constraints consumed:` sites classified at
research time, corrected the 28 that over-reported, and left the 40 accurate ones byte-identical.
Phase 8 closed the task by re-deriving the C34a discharge-group counts from the gate's own output,
writing them into the two specification documents, and re-running the classification probe over
all 68 sites against the rebuilt olean set.

The correction pattern throughout was route 2 of `REFERENCE_NORMAL_FORM.md`: prove the claim at a
binder-free twin carrying the honest marker, and keep the binder-carrying original as a one-line
delegating corollary whose signature line is byte-identical, so no call site moved. Route 1
(binder deletion) was used only at the three `None` sites, each after a transplant probe confirmed
the binder was not needed for elaboration.

## What Changed

- `FormalSystem/Semantics/ConeUnravelling.lean` — one over-reporting marker corrected; binder-free
  twin plus delegating corollary. Its three accurate rows untouched.
- `FormalSystem/Semantics/IntNormalForm.lean` — two enabler twins
  (`FrameOver.respects_of_isStepPath_of_constraints`,
  `FrameOver.isTotal_respects_iff_adjacent_of_constraints`,
  `base_taskRel_eq_ofStepRel_of_constraints`).
- `FormalSystem/Semantics/Nomic/Witnesses.lean` — two markers corrected.
- `FormalSystem/Semantics/Nomic/ZTime.lean` — four markers corrected.
- `FormalSystem/Semantics/Presheaf/Behavior.lean` — the binder-free germ constructor
  `Beh.ofGermOfSerialLimit`.
- `FormalSystem/Semantics/Presheaf/Path.lean` — 21 markers corrected across three clusters
  (identity and category structure, windows/`toPath`/the three `None` sites, `ofStep`/`ofPath`/the
  path equivalence). File grew 1,762 → 1,851 lines; full-four occurrences 21 → 0.
- `docs/development/MODULE_INVARIANTS.md` — the C34a/C34b row's delegation count 18 → 45 and its
  omits-nothing count 7 → 39.
- `docs/development/REFERENCE_NORMAL_FORM.md` — rule 1's measured live surface 7 → 39 and rule 2's
  18 → 45.

## Decisions

- **Route 2 as the default at every binder-carrying site.** It is the pattern of record, it keeps
  every public signature byte-identical, and it is the one route structurally guaranteed to
  satisfy C34a's `delegates()` predicate.
- **Counts taken from the gate's own `PASS C34a` line, never computed by hand.** The line read:
  `all 188 marker(s) are honest ... (86 of them carry a binder: 45 discharge it by delegating to a
  binder-free declaration, 2 by field re-export, and 39 omit nothing and so claim nothing)`.
- **Two figures re-derived and deliberately left unchanged.** Both documents' "8 recognizable
  tree-wide, 2 marked" claim about field re-exports was re-measured by running the recorded
  `reexport_field` recognizer over both live roots: it still returns 8, and the gate still reports
  2 discharging. Unchanged on measured evidence, not on assumption.
- **The two authority sections need no change.** "What the line claims" and "Consumption is not
  elimination" were read against the corrected tree. The worked example the second names,
  `PartialHistory.isTotal_of_isMax`, is an accurate site this task never touched and still carries
  its full-four marker.

## Plan Deviations

- **Task 8.6** altered: `typst-sync-check.sh --fix` was run as the bare form, because all four
  checks were already green with `MISMATCH_COUNT=0`. `typst/generated/status.typ` was neither
  re-stamped nor staged, so it is absent from this phase's diff.
- **Task 8.7** deferred: the complete gate set is deferred to the batch invocation's single
  end-of-batch run, per this dispatch's batch-gate-deferral directive. No scoped substitute
  existed — `suite_selection_select` over the phase's touched paths returns `__FULL_SWEEP__`, and
  `verify-deploy.sh`'s gates scope to the `.claude/**` deploy tree this phase does not touch.
  `scripts/check-module-invariants.sh`, the repository gate that does cover these two documents,
  was run in full instead.
- Phases 4-7 left the plan's `## Lean Challenge Statements` identifiers unedited although C26
  forbids the recorded snake_case `def` names. The recorded *signatures* are honored; only the
  identifiers differ, and only because an enforced repository invariant forbids the recorded ones.
  Per `plan-compliance.md` the recorded Challenge was not quietly edited to match.

## Verification

- Build: Success. Full library via the build guard, `GUARD_EXIT=0`,
  `Build completed successfully (2974 jobs)`, zero `error:` lines.
- Sorry count: 0. `lean-sorry-census.sh --cross-check`: stripper 0, compiler 0, `MATCH`.
- Sorry inventory: None.
- Vacuous count: 1, pre-existing and outside every phase's territory
  (`FormalSystem/Examples/TemporalStructures.lean:495`).
- Axiom count: 14, unchanged. The task's whole `.lean` diff adds zero `axiom` and zero `sorry`
  lines.
- `scripts/check-module-invariants.sh --no-build`: exit 0, `ALL CHECKS PASSED`, with `PASS C34`,
  `PASS C34a`, `PASS C34b`.
- `scripts/check-module-invariants.sh` (full form, with build): exit 1, from the single
  **pre-existing** `FAIL C16` (env_linter `unusedArguments` at
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean:1825` and `:1868`), recorded
  byte-identically in every phase of this task and outside every phase's file territory. The
  plan's "exits 0" criterion is therefore not met on the nose; stated plainly rather than implied.
- `scripts/check-module-invariants.sh --emit-inventory --check`: exit 0, `PASS INV`.
- `scripts/typst-sync-check.sh`: exit 0, all four checks green.
- Probe re-run: 68 `R4` rows, no `TARGET NOT FOUND`; comparison against the live markers gives
  `TOTAL=68 MISMATCH=0 UNMATCHED=0`.
- `grep -rn "Constraints consumed: Compositionality, Seriality, Limit, Saturation" FormalSystem/`
  returns 41 lines (40 accurate sites plus the `Presheaf/Worlds.lean` prose quotation), down from
  69. 41 + 28 removed = 69.
- The 40 accurate sites are untouched: the task's whole `.lean` diff reaches exactly six files,
  none of them in `NomicLanguage/`, `Nomic/Uniformity.lean`, `Nomic/Recovery.lean`,
  `Nomic/Frame.lean`, `Extension/`, `Presheaf/Directed.lean`, `Presheaf/Worlds.lean`,
  `Correspondence/RigidityReal.lean` or `Validity.lean`.

## Impacts

- A `Constraints consumed:` line in this tree can now be read as what it claims to be: the whole of
  what the elaborated term reaches. The over-claim that kept the *Saturation* question looking open
  is gone from all 28 sites that carried it.
- Nineteen new binder-free twins are available to callers that want the explicit-hypothesis form,
  most of them in `Presheaf/Path.lean`. Every original survives with a byte-identical signature
  line, so no existing call site moved.
- C34a's delegation discharge group is now the dominant one (45 of 86 binder-carrying markers,
  against 18 before), which is the arrangement the invariant was designed to reward.

## Follow-ups

- `FAIL C16` at `LadderPump.lean:1825` and `:1868` is pre-existing, outside this task's territory,
  and still open.
- Both documents' "46 of the 212 binder-carrying declarations" figure for the *deferred broad
  projection rule* was not re-derived: measuring it would mean implementing the declined rule, and
  the live C34 census now reports a different binder-carrying population (338 across both roots).
  The figure is a recorded measurement of a declined option, not a discharge-group count, so it was
  left alone rather than silently restated.
- Six of the eight recognizable field re-exports still carry no marker. None triggers C34b, so none
  is required; `REFERENCE_NORMAL_FORM.md` already records this as a follow-up rather than a defect.

## References

- `specs/908_constraints_consumed_marker_accuracy_audit/plans/01_constraints-consumed-marker-corrections.md`
- `specs/908_constraints_consumed_marker_accuracy_audit/reports/01_constraints-consumed-marker-audit.md`
- `specs/evidence/constraints-consumed-marker-audit/` — `classification.tsv` (the 68-row record),
  `marker-consumption-probe.lean`, `c34a-gate-simulation.py`
- `specs/evidence/history-morphism-saturation-audit/` — the two compiled transplant probes from the
  originating work
- `docs/development/REFERENCE_NORMAL_FORM.md` section 3 — the convention this work applied
- `docs/development/MODULE_INVARIANTS.md` — the `C34a / C34b (both enforced)` row
