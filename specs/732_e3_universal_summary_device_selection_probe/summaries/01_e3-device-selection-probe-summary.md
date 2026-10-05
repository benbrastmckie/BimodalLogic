# Implementation Summary: Task #732

- **Task**: 732 - Run experiment E3: select the universal summary device for the seam-gluing stab fibre check
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-05T18:53:58Z
- **Completed**: 2026-10-05T19:16:14Z
- **Effort**: Phase 1 ~7 min (dispatch 3); Phase 2 ~15 min (dispatch 4)
- **Dependencies**: None (task 711 depends on this one)
- **Artifacts**: plans/01_e3-device-selection-probe.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1 and 2 of 3 are complete. Phase 1 transcribed the compiled E3 comparison core from the
research prototype into `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`.
Phase 2 (this dispatch) bridged that abstract core to the real formula
`PlusTruthAt Mf τ t (.stab (someFuture (.atom pa)))` on the shared two-state Bool fixture: the
fixture and `will_iff_allPathsMeet` are restated verbatim from the necessity probe, and two
bridge lemmas prove that on this fixture `⊡(Fp)` equals its lasso restriction by pigeonhole
alone, so all four candidate devices coincide with the reachability summary already proved.
Phase 3 (scoped selection header, gate wiring, collection run) remains.

## What Changed

- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` (192 -> 318 lines) —
  Phase 2 added, under `Probe732Device`: the Bool fixture restated verbatim (`Rf`, `Rf_fwd`,
  `Rf_bwd`, `Ff`, `instance : Ff.IsRegular`, `pa`, `Mf`, `IsFwdPath`, `AllFwdPathsMeet`);
  `will_iff_allPathsMeet` restated verbatim; `allFwdPathsMeet_iff_abstract` (`Iff.rfl`);
  the headline `stab_will_iff_lasso` on the real formula; a per-device prose block
  (`/-! ## What the shape exercises of each device -/`); three further `#print axioms` lines.
  Phase 1 content unchanged. Committed as `4097d75aa` (one file).

## Decisions

- Fixture-level summary named `AllFwdPathsMeet` (sibling: `AllPathsMeet`) because the abstract
  `AllPathsMeet R P w₀` already occupies the name in this namespace; definition unchanged.
- `stab_will_iff_lasso` closes with `rw [will_iff_allPathsMeet, allFwdPathsMeet_iff_abstract,
  allPathsMeet_iff_lasso]` followed by `exact Iff.rfl` for the residual
  `IsPath (Rf 0) … ↔ IsFwdPath …` (definitional, not reducible-transparent) — the fallback the
  plan named. Bridge: 2 declarations, 3 proof lines, within the plan's <= 10-line hypothesis.
- Declined `git commit --no-verify` when the typst-sync pre-commit gate refused the first commit
  attempt on drift caused by a foreign uncommitted `StateTopology.lean` edit; the drift cleared
  on the other writer's side and the retry landed unchanged.

## Plan Deviations

- None (implementation followed plan; the `exact Iff.rfl` closer is the plan's own named
  fallback, annotated inline on the Phase 2 checklist).

## Verification

- Build: Success (full guarded `lake build`, exit 0, "Build completed successfully (2819 jobs)",
  0 `error:` lines, `.olean`s newer than sources; probe itself: `lake env lean` exit 0, no
  warnings)
- Sorry count: 0 (stripper 0, compiler 0, cross-check MATCH)
- Sorry inventory: None
- Vacuous count: 1 (`FormalSystem/Examples/TemporalStructures.lean:495 int_domain_universal := trivial`,
  pre-existing at HEAD and unchanged; no file under the source roots modified by this task)
- Axiom count: 14 (baseline 14, unchanged)
- Printed axioms: `will_iff_allPathsMeet` `[propext, Classical.choice, Quot.sound]` — identical to
  the sibling's live output; `allFwdPathsMeet_iff_abstract` none; `stab_will_iff_lasso`
  `[propext, Classical.choice, Quot.sound]`
- Comparator gate: not run (`compare_flag` not set)

## Impacts

- The report's one Medium-confidence, uncompiled claim (`IsFwdPath`/`IsPath (Rf 0)`
  identification) is now a compiled theorem; Phase 3's header can state the device-inertness
  result on the real formula over the fixture the necessity probe used.
- Not yet wired into `scripts/check-evidence-probes.sh`; the collection gate is unchanged.

## Follow-ups

- Phase 3: collision check on `scripts/check-evidence-probes.sh`, re-grep cited names, scoped
  selection header (must contain "not selected", "does not establish", "no complexity bound"),
  `WIRED` entry, collection run, commit.
- Territory observations recorded in `issues.jsonl` and reported to the orchestrator: foreign
  edits to `FormalSystem/Semantics/StateTopology.lean` and three docs files (staged by another
  writer), a sibling `lake build BimodalTools.TableauBridgeMain`, a stale build-guard holder.

## References

- Plan: specs/732_e3_universal_summary_device_selection_probe/plans/01_e3-device-selection-probe.md
- Report: specs/732_e3_universal_summary_device_selection_probe/reports/01_e3-device-selection-probe.md
- Handoffs: specs/732_e3_universal_summary_device_selection_probe/handoffs/phase-1-handoff-20261005T185650Z.md, specs/732_e3_universal_summary_device_selection_probe/handoffs/phase-2-handoff-20261005T191440Z.md
- Deliverable: specs/evidence/seam-gluing-ray-product/device-selection-probe.lean
