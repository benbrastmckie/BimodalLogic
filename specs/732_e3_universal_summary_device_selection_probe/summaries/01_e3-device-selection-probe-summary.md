# Implementation Summary: Task #732

- **Task**: 732 - Run experiment E3: select the universal summary device for the seam-gluing stab fibre check
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-05T18:53:58Z
- **Completed**: 2026-10-05T19:00:00Z
- **Effort**: ~10 minutes (Phase 1 of 3; this dispatch)
- **Dependencies**: None (task 711 depends on this one)
- **Artifacts**: plans/01_e3-device-selection-probe.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Single-phase hard-mode dispatch (dispatch 3) executing Phase 1 of the plan: transcribe the
compiled research prototype (`probes/device-probe-proto.lean`) into the deliverable probe
`specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`. The phase moves proved text
and proves nothing new; it compiled first time with zero proof edits. Phases 2 (bridge to the
real `⊡(Fp)` formula on the Bool fixture) and 3 (scoped selection header, gate wiring, collection
run) remain and are the next dispatches' work.

## What Changed

- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` — new (192 lines).
  Provisional two-line header (finalized in Phase 3), `import FormalSystem`, the sibling `open`
  lines, and `namespace Probe732Device` carrying, with names unchanged from the prototype:
  `IsPath`, `IsLasso`, `AllPathsMeet`, `lassoIdx`, `lassoIdx_pos`, `lassoIdx_lt`,
  `exists_lasso_of_repeat`, `allPathsMeet_iff_lasso` (lasso sufficiency for the `Fp` shape by
  pigeonhole alone), `allBwdPathsMeet_iff_lasso` (the `Pp` dual by graph reversal), `detRun`,
  `detRun_true_iff`, `detRun_accepts_iff` (the per-path `Fp` acceptor is a 2-state deterministic
  automaton), `chainR`, `chain_path_strictAnti`, `chain_no_lasso`,
  `not_lasso_sufficient_on_chain` (pigeonhole-tier lasso sufficiency fails on the infinite
  `ℤ`-chain). Four-line `#print axioms` foot.
- `specs/732_e3_universal_summary_device_selection_probe/plans/01_e3-device-selection-probe.md` —
  Phase 1 heading promoted to `[COMPLETED]`, all six Phase 1 checklist items ticked.
- `specs/732_e3_universal_summary_device_selection_probe/handoffs/phase-1-handoff-20261005T185650Z.md`
  — continuation handoff for Phase 2.

## Decisions

- `import Mathlib.Data.Fintype.Pigeonhole` dropped: `Finite.exists_ne_map_eq_of_infinite` is
  transitively available through `import FormalSystem`, so the probe follows the collection
  convention (a probe imports `FormalSystem` only). The plan's fallback note is not needed.
- `omit [Finite S] in` placements kept exactly as in the prototype (before the docstring).
- `lake env lean` on the single probe file was run in the foreground (it is a 4-second file
  compile, not a `lake build`); the Stage 6 full `lake build` ran detached through
  `lake-build-guard.sh`.

## Plan Deviations

- None (implementation followed plan; the "try without the Mathlib import first" branch
  succeeded, so the import-restoration branch was not exercised).

## Verification

- Build: Success — guarded `lake build`, exit 0, `Build completed successfully (2819 jobs)`,
  0 `error:` lines over captured stdout/stderr; no `FormalSystem/` module was touched, so the
  per-module `.olean` check has no touched modules to cover (the probe lives outside the build
  graph).
- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`
  exit 0, no warnings. Printed axioms: `allPathsMeet_iff_lasso`, `allBwdPathsMeet_iff_lasso`
  `[propext, Classical.choice, Quot.sound]`; `detRun_accepts_iff`,
  `not_lasso_sufficient_on_chain` `[propext, Quot.sound]` — identical to the prototype baseline.
- Sorry count: 0 (`lean-sorry-census.sh --cross-check` over the resolved source roots:
  stripper 0, compiler 0, `cross_check: MATCH`; probe file alone: 0)
- Sorry inventory: None
- Vacuous count: 1 — `FormalSystem/Examples/TemporalStructures.lean:495`
  (`theorem int_domain_universal … := trivial`), pre-existing at HEAD and unchanged by this
  dispatch (0 Lean files under the source roots modified)
- Axiom count: 14 (HEAD baseline 14; not increased)

## Impacts

- The comparison core the Phase 3 header will cite now exists at its deliverable path with the
  report's mapping-table names intact; Phase 2 can add the fixture section without touching it.
- `scripts/check-evidence-probes.sh` is untouched; the probe is not yet in `WIRED` (Phase 3).

## Follow-ups

- Phase 2: Bool-fixture restatement, verbatim `will_iff_allPathsMeet`, bridge lemmas
  `allFwdPathsMeet_iff_abstract` and `stab_will_iff_lasso`.
- Phase 3: final scoped selection header, `WIRED` entry, run the whole collection; begins with
  the `scripts/check-evidence-probes.sh` collision check.
- After the task: `/revise 711` to discharge its blocked reason (not performed by this task).

## References

- Plan: specs/732_e3_universal_summary_device_selection_probe/plans/01_e3-device-selection-probe.md
- Report: specs/732_e3_universal_summary_device_selection_probe/reports/01_e3-device-selection-probe.md
- Prototype: specs/732_e3_universal_summary_device_selection_probe/probes/device-probe-proto.lean
- Handoff: specs/732_e3_universal_summary_device_selection_probe/handoffs/phase-1-handoff-20261005T185650Z.md
- Issue log: specs/732_e3_universal_summary_device_selection_probe/issues.jsonl
