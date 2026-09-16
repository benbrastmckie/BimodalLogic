# Implementation Summary: Task #582

- **Task**: 582 - Break or re-baseline the Conservativity <-> Deterministic directory cycle in `Metalogic/`
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T16:09:42Z
- **Completed**: 2026-09-16T16:15:12Z
- **Effort**: ~1.5 hours
- **Dependencies**: Task 583 (soft; CI wiring pattern)
- **Artifacts**: plans/02_cycle-break-plan.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Broke the second directory-level import cycle in `FormalSystem/Metalogic/` by Option A1:
the only thing `Conservativity/` needed from `Deterministic/` was one five-line theorem,
`detDerivable_ofFormula_iff`. It now sits in `Deterministic/Completeness.lean`, next to the
lemma it specializes, and the import that formed the cycle is gone. No proof changed. The cycle
check now runs in CI.

## What Changed

- `FormalSystem/Metalogic/Deterministic/Completeness.lean` — added
  `FormalSystem.Metalogic.Deterministic.detDerivable_ofFormula_iff` (docstring kept verbatim,
  including `Paper: —`) after `detDerivable_iff_derivable_erasePlus`; listed in Main Results
- `FormalSystem/Metalogic/Conservativity/Plus/Corollaries.lean` — removed
  `import FormalSystem.Metalogic.Deterministic.Completeness`, the "transfer back to the L level"
  section and theorem; module docstring now points at the new location
- `docs/theorem-index.md` — row renamed to the new fully-qualified name and file
- `FormalSystem/Metalogic/Conservativity/Plus/README.md`, `FormalSystem/Metalogic/Deterministic/README.md` — anchors updated
- `FormalSystem/Metalogic/README.md`, `README.md` — generated inventory line counts regenerated (INV)
- `.github/workflows/ci.yml` — new step "Check Metalogic directory-level import cycles
  (scripts/check-metalogic-cycles.sh)", placed right before "Report results"

## Decisions

- **Choice: A1 (move the theorem).** A2 (move ~520 lines of axiom-validity code into a third
  directory) would cost several times more for the same result. B (accept a second cycle) needs
  an ADR, changes to the script, the README, four ADR-006 sites and MODULE_INVARIANTS, and leaves
  the backwards dependency in place. A1 is fully reversible. Presented as a non-blocking
  `user_decision`.
- Kept edge `Deterministic -> Conservativity` (the extension reuses TM+ soundness), which is
  the natural layering.
- `FormalSystem/Metalogic/README.md:73` ("exactly one directory-level cycle") is now true
  verbatim; the script, ADR-006 and MODULE_INVARIANTS needed no textual change.

## Plan Deviations

- **Phase 1** altered: diagnostics checked with a guarded scoped `lake build` of both modules
  instead of the blocked `lean_diagnostic_messages` tool; Corollaries intro prose also reworded.
- **Phase 1** skipped: optional narrowing of the `Deterministic/Soundness.lean:9` import (it
  does not affect the directory edge).
- **Phase 3** altered: the first full invariants run failed only INV, because the move made the
  generated line counts stale. Regenerated the counts; `--emit-inventory --check` now passes.
- **Phase 4** skipped: `CI_CD_PROCESS.md` entry. Task 583's "Wiring a New Check Script"
  convention has not landed yet. The step already follows 583's planned naming (script path in
  `name:`, `set -euo pipefail`, `::group::`) and placement.

## Verification

- Build: Success — full guarded `lake build` (2653 jobs), exit 0
- `bash scripts/check-metalogic-cycles.sh`: exit 0, `PASS exactly 1 directory-level import cycle`
- `bash scripts/check-module-invariants.sh` (full): every check PASS, including C1, C4, C6,
  C15 and C24. INV passed after the regeneration.
- Relocated theorem axioms (`lean_verify`): `propext`, `Classical.choice`, `Quot.sound`
- Sorry count: 0 live (C3 PASS; Boneyard excluded)
- Vacuous count: 0 new (one pre-existing `int_domain_universal ... := trivial` proof term, untouched)
- Axiom count: unchanged (no `axiom` declarations; grep hits are docstring prose)
- CI step negative test: in a scratch copy of `FormalSystem/Metalogic/` plus the script,
  re-adding the deleted import made the step body exit 1 with `FAIL ... found 2` naming
  `Conservativity <-> Deterministic`. The clean copy exits 0. The real tree was never modified.
- Workflow YAML parses (python yaml); `actionlint` not available
- Files verified: Yes

## Impacts

- `Deterministic.detDerivable_ofFormula_iff` replaces `Conservativity.detDerivable_ofFormula_iff`
  (no Lean or test consumers existed)
- A new directory-level cycle in `Metalogic/` now fails CI

## Follow-ups

- When task 583 adds the "CI Steps Explained" / "Wiring a New Check Script" convention to
  `docs/development/CI_CD_PROCESS.md`, add an entry for the cycle-check step and its runtime
  (under a second; grep only)
- `scripts/check-metalogic-cycles.sh`'s header still says "Run it directly"; it is now also run in CI

## References

- specs/582_break_or_rebaseline_metalogic_cycle/plans/02_cycle-break-plan.md
- specs/582_break_or_rebaseline_metalogic_cycle/reports/02_cycle-break-costing.md
- specs/582_break_or_rebaseline_metalogic_cycle/reports/01_conservativity-deterministic-cycle.md
- specs/583_wire_check_scripts_into_ci/plans/02_wire-check-scripts-ci.md
