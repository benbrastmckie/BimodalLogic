# Implementation Summary: Task #732

- **Task**: 732 - Run experiment E3: select the universal summary device for the seam-gluing stab fibre check
- **Status**: [COMPLETED]
- **Started**: 2026-10-05T18:30:00Z
- **Completed**: 2026-10-05T19:29:40Z
- **Effort**: 3 phases across dispatches 3-5 (approx. 1.5 hours of agent time)
- **Dependencies**: None
- **Artifacts**: plans/01_e3-device-selection-probe.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Delivered the E3 device-selection probe `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`
in three phases: Phase 1 transcribed the compiled comparison core (pigeonhole lasso reduction for the
`⊡(Fp)`/`⊡(Pp)` shapes, the deterministic 2-state per-path acceptor, the infinite-chain falsifier);
Phase 2 restated the Bool fixture and `will_iff_allPathsMeet` verbatim from the necessity probe and
bridged the abstract summary to the real formula (`stab_will_iff_lasso`); Phase 3 (this dispatch)
wrote the scoped selection header, wired the probe into `scripts/check-evidence-probes.sh`, and ran
the whole collection. The header records the selection on evidence: the time-axis Ramsey-coloured
summary (d) via the in-tree `FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs`, framed by the
MSO-over-`⟨ℤ,<⟩` quasimodel route (c) of Hodkinson–Wolter–Zakharyaschev 2000 / GKWZ 2003; (a)
Safra/Piterman and (b) Safraless are not selected.

## What Changed

- `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean` — provisional header replaced by
  the final selection header (outcome on the shapes; falsifier; selection scoped exactly; what is NOT
  established, incl. no complexity bound and that "no candidate is adequate" was an admissible
  outcome; no substrate work; compile line). No declaration changed; 383 lines; 0 sorries.
- `scripts/check-evidence-probes.sh` — DEVICE-SELECTION (E3) row in the commented decision table;
  `"seam-gluing-ray-product/device-selection-probe"` appended to `WIRED` (13 entries); the two
  `WIRED_REPO` paths for the archived 706/710 probes redirected to `specs/archive/`.

## Decisions

- Selection is by infrastructure and literature evidence, not behavioural discrimination: the probed
  shapes are device-inert on finite fixtures (`allPathsMeet_iff_lasso`, `allBwdPathsMeet_iff_lasso`,
  `detRun_accepts_iff`, `stab_will_iff_lasso`), and `not_lasso_sufficient_on_chain` refutes
  pigeonhole-tier summaries on infinite fibres. The header says so in those words.
- Cited the finite-width FMP refutation by its real name
  (`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`); the
  plan's `Probe710.` prefix does not exist in the tree.
- Repaired the two stale `WIRED_REPO` paths in the owned script so the collection gate exits 0, rather
  than leaving an unrelated pre-existing red; no sibling probe file was edited.

## Plan Deviations

- **Phase 3, re-verify names** altered: `Probe710.not_finite_width_fmp` -> in-tree
  `...NoFiniteWidth.not_finite_width_fmp` (`NoFiniteWidth.lean:1280`).
- **Phase 3, wire** altered: row lands after `:172` (not `:177`); additionally repaired two archived
  `WIRED_REPO` paths (pre-existing drift from `/todo` commit 70321e938).
- **Phase 3, run the gate** altered: expected count is 16 (13 `WIRED` + 3 `WIRED_REPO`), not 13.
  First run `FAIL 2 of 16` on the stale paths; second run `PASS  all 16 wired probe(s) compile`.

## Verification

- Build: Success — guarded, detached `lake build`: GUARD_EXIT=0, "Build completed successfully (2819
  jobs)", 0 `error:` lines over both captured streams; `.olean` newer than source for
  `PlusRayFibre`; no `FormalSystem/` file touched by this task.
- Evidence gate: `bash scripts/check-evidence-probes.sh` -> `PASS  all 16 wired probe(s) compile`,
  exit 0, `seam-gluing-ray-product/device-selection-probe PASS`.
- Probe compile: `lake env lean specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`
  exit 0, no warnings; `#print axioms`: standard axioms only (`allFwdPathsMeet_iff_abstract` none).
- Sorry count: 0 (`lean-sorry-census.sh --cross-check`: stripper 0, compiler 0, MATCH)
- Sorry inventory: None
- Vacuous count: 1 (identical at HEAD before this task — `Examples/TemporalStructures.lean:495`,
  inherited, not introduced)
- Axiom count: 14 `^axiom` lines (identical at HEAD before this task; not increased)
- Header reviewer check: "not selected" x1, "does NOT establish" x1, "no complexity bound" x1,
  "admissible outcome" x1; "right device"/"correct device" absent; the single "EXPTIME" occurrence
  is the mandated lower-bound sanity-ceiling sentence.

## Impacts

- Task 711's blocked reason ("device not yet selected; probe E3 pending") is now dischargeable by a
  separate `/revise 711` against the header's selection; this task does not perform it.
- The evidence collection gains a 13th `WIRED` probe and its `WIRED_REPO` block compiles again.

## Follow-ups

- `/revise 711`: re-scope the universal-summary substrate on time-axis Ramsey (d) framed by route
  (c), with the first behavioural discrimination on a finitely presented infinite fibre.
- Literature: Kupferman–Vardi FOCS 2005 remains WANTED.

## References

- `specs/732_e3_universal_summary_device_selection_probe/plans/01_e3-device-selection-probe.md`
- `specs/732_e3_universal_summary_device_selection_probe/reports/01_e3-device-selection-probe.md`
- `specs/732_e3_universal_summary_device_selection_probe/handoffs/phase-3-handoff-20261005T192829Z.md`
- `specs/732_e3_universal_summary_device_selection_probe/issues.jsonl`
- Commits: `4097d75aa` (phase 2), `e8cfcd868` (phase 3)
