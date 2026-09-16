# Implementation Plan: Task #582

- **Task**: 582 - Break or re-baseline the Conservativity <-> Deterministic directory cycle in `Metalogic/`
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: Task 583 (soft: records the CI wiring pattern Phase 4 follows; not a hard blocker)
- **Research Inputs**: specs/582_break_or_rebaseline_metalogic_cycle/reports/02_cycle-break-costing.md (primary), specs/582_break_or_rebaseline_metalogic_cycle/reports/01_conservativity-deterministic-cycle.md (evidence), specs/583_wire_check_scripts_into_ci/reports/02_wire-check-scripts-ci.md (CI wiring pattern)
- **Artifacts**: plans/02_cycle-break-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Resolve the second directory-level cycle by **Option A1**: relocate the single declaration that
creates the `Conservativity -> Deterministic` edge, `detDerivable_ofFormula_iff`, from
`Conservativity/Plus/Corollaries.lean` into `Deterministic/Completeness.lean` (directly after
`detDerivable_iff_derivable_erasePlus`, of which it is a specialization), and delete the now-unused
import. The kept edge `Deterministic -> Conservativity` is the natural layering (the extension
reusing TM+'s axiom-validity lemmas). Then update the three documentation anchors that name the
theorem's old fully-qualified name/file, confirm every gate, and wire
`scripts/check-metalogic-cycles.sh` into CI so a new cycle cannot land undetected again.

### Decision Record (A1 vs A2 vs B)

The task requires the choice to be costed and presented, not picked silently. Research costed all
three; the orchestrator proceeds on A1, and the choice is surfaced to the user as non-blocking.

| Option | Change set | Outcome | Verdict |
|--------|-----------|---------|---------|
| **A1** relocate the consuming theorem | 1 theorem (5 lines) moved, 1 import deleted, 3 doc rows | Cycle gone; layering inversion removed; script/ADR-006/README claims already correct | **Chosen** - verified by scratch compile and a simulated script run (exit 0) |
| A2 lift `plusAxiom_validIn` / `plusAxiom_swap_validIn` to a third directory | ~520 lines of `AxiomValidity` + `Atomization` moved; 5+ importers re-pathed | Cycle gone but moves the *correct*-direction dependency | Rejected: several times A1's cost for the same result |
| B accept and re-baseline to 2 | Script count + header, README:73, ADR-006 (4 sites), MODULE_INVARIANTS.md:273, new ADR | Cycle stays; inversion stays | Rejected: more churn than A1, and contradicts ADR-006's own "relocate first" consequence |

A1 is fully reversible (restore the import and move the theorem back).

### Research Integration

- The edge has exactly one consumer: `detDerivable_ofFormula_iff` (Corollaries.lean:195-213,
  including its section header and docstring). Everything else in `Corollaries.lean` is reachable
  via `Conservativity.Plus.Forward` (verified: scratch copy without import + theorem compiles
  clean).
- The relocated theorem compiles in `namespace FormalSystem.Metalogic.Deterministic` importing
  only `Deterministic.Completeness`'s closure; axioms are the ambient `propext`,
  `Classical.choice`, `Quot.sound`.
- Nothing in Lean or tests references the theorem; references are `docs/theorem-index.md:177`
  (enforced by invariant C15), `Conservativity/Plus/README.md:36,49`, and the
  `Deterministic/README.md:50` file-table row.
- `FormalSystem/Metalogic/README.md:73`, `scripts/check-metalogic-cycles.sh`, ADR-006, and
  `docs/development/MODULE_INVARIANTS.md` all assert count 1 and need no textual change under A1.
- Task 583 (status: planning) recommends: new check steps after the "Compile lean_exe roots" step
  and before "Report results"; step `name:` states the check in plain words with the script
  basename in `run:`; `set -euo pipefail` and `::group::`/`::endgroup::` wrapping.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch.

## Goals & Non-Goals

**Goals**:
- `bash scripts/check-metalogic-cycles.sh` exits 0 (exactly one cycle: `BXCanonical <-> WeakCanonical`)
- `lake build` exits 0; `bash scripts/check-module-invariants.sh` passes in full
- `Metalogic/README.md`'s cycle claim matches what the script asserts
- The cycle script runs in CI, and a deliberately introduced cycle fails that step

**Non-Goals**:
- Changing any proof (declaration location only)
- Resolving the accepted `BXCanonical <-> WeakCanonical` cycle
- Wiring the other check scripts into CI (owned by task 583)
- Mandatory narrowing of `Deterministic/Soundness.lean:9` to `AxiomValidity` (optional hygiene only; does not affect the directory edge)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fully-qualified name change breaks a missed reference | M | L | Repo-wide grep (excluding `.lake`, `specs`) before and after; C15 catches the theorem-index row |
| Concurrent agents running `lake build` | M | M | Use `.claude/scripts/lake-build-guard.sh` for the full build per long-builds guidance |
| Warm-olean scratch compile hid a problem | L | L | Full guarded `lake build` + full `check-module-invariants.sh` (C4, C6, C15, C24) in Phase 3 |
| Task 583 and this task both edit `.github/workflows/ci.yml` | M | M | Phase 4 re-reads `ci.yml` at start; if 583 has landed, insert alongside its steps in its order; if not, add a self-contained step following 583's recorded pattern and note it in the summary for 583 to conform |
| Deliberate-cycle test leaks into a commit | H | L | Do the negative test in a scratch copy of the tree (or `git stash`-protected edit) and confirm `git status` is clean of `.lean` changes before commit |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Relocate `detDerivable_ofFormula_iff` and delete the cycle-forming import [COMPLETED]

**Goal**: Remove the `Conservativity -> Deterministic` edge with no proof changes.

**Tasks**:
- [x] Baseline: run `bash scripts/check-metalogic-cycles.sh` and record the FAIL (2 cycles)
- [x] In `FormalSystem/Metalogic/Deterministic/Completeness.lean`, add `detDerivable_ofFormula_iff`
      immediately after `detDerivable_iff_derivable_erasePlus` (~line 192), inside
      `namespace FormalSystem.Metalogic.Deterministic`: keep the docstring verbatim (including the
      `Paper: —` line), drop the `Deterministic.` qualifiers on `DetDerivable`,
      `detDerivable_iff_derivable_erasePlus`, `erasePlus_ofFormula`; confirm `ofFormula`, `Formula`,
      and `ProofSystem.Derivable` resolve (add `open`/qualifiers only if needed)
- [x] Add the theorem to that module docstring's main-results prose
- [x] In `FormalSystem/Metalogic/Conservativity/Plus/Corollaries.lean`: delete line 8
      (`import FormalSystem.Metalogic.Deterministic.Completeness`), the
      "The transfer back to the L level" section header, docstring and theorem (lines ~195-213),
      and replace the module-docstring bullet at line 52 with a one-line pointer to
      `Deterministic/Completeness.lean`
- [x] `lean_diagnostic_messages` on both files: zero errors *(deviation: altered — `lean_diagnostic_messages` is a blocked tool; verified instead by a guarded scoped `lake build` of both modules, exit 0; the Corollaries module-docstring intro prose was also reworded to point at the new location)*
- [x] `lean_verify FormalSystem.Metalogic.Deterministic.detDerivable_ofFormula_iff`: axioms are
      `propext`, `Classical.choice`, `Quot.sound` only; no `sorry`
- [x] `bash scripts/check-metalogic-cycles.sh` exits 0 with `PASS exactly 1 directory-level import cycle`
- [ ] Optional: narrow `Deterministic/Soundness.lean:9` to `Conservativity.Plus.AxiomValidity`
      only if the file still compiles and Phase 3's build is green; otherwise leave as is *(deviation: skipped — optional hygiene, does not affect the directory edge; kept the change set minimal)*

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch (the move and the import deletion must land together; either half
alone breaks the build or duplicates the declaration)

**Scope Hypothesis**: The theorem is the sole consumer of the deleted import. Confirm by compiling
`Corollaries.lean` after deletion (zero errors) rather than trusting the research grep.

**Files to modify**:
- `FormalSystem/Metalogic/Deterministic/Completeness.lean` - receive the theorem, docstring update
- `FormalSystem/Metalogic/Conservativity/Plus/Corollaries.lean` - drop import, section, theorem, docstring bullet
- `FormalSystem/Metalogic/Deterministic/Soundness.lean` - optional import narrowing

**Verification**:
- Both files diagnostics-clean; cycle script exits 0; axiom footprint unchanged

---

### Phase 2: Update documentation anchors for the moved theorem [COMPLETED]

**Goal**: Every reference names the new fully-qualified name and file, so C15 and the READMEs agree.

**Tasks**:
- [x] `docs/theorem-index.md:177`: name column -> `FormalSystem.Metalogic.Deterministic.detDerivable_ofFormula_iff`,
      file column -> `FormalSystem/Metalogic/Deterministic/Completeness.lean`
- [x] `FormalSystem/Metalogic/Conservativity/Plus/README.md:36`: remove the theorem from the
      `Corollaries.lean` row and update the line count (measure with `wc -l`)
- [x] `FormalSystem/Metalogic/Conservativity/Plus/README.md:49`: remove the theorem from the
      `Corollaries.lean` key-results bullet (or leave a pointer to `Deterministic/Completeness.lean`)
- [x] `FormalSystem/Metalogic/Deterministic/README.md:50`: add `detDerivable_ofFormula_iff`
      (conservativity of TM+ + *Determined* over TM) to the `Completeness.lean` row, and to that
      README's key-results list if one exists
- [x] `grep -rn detDerivable_ofFormula_iff --exclude-dir=.lake --exclude-dir=specs .` shows only the
      new declaration and the updated anchors; no remaining `Conservativity.detDerivable_ofFormula_iff`
- [x] Re-read `FormalSystem/Metalogic/README.md:73` and confirm "exactly one directory-level cycle"
      is now true verbatim (no edit expected)

**Timing**: 20 minutes

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Four anchor sites (theorem-index row, two Plus/README lines, one
Deterministic/README row). Confirm with the grep above before and after editing.

**Files to modify**:
- `docs/theorem-index.md` - row 177
- `FormalSystem/Metalogic/Conservativity/Plus/README.md` - lines 36, 49
- `FormalSystem/Metalogic/Deterministic/README.md` - line 50

**Verification**:
- Grep clean; README cycle claim matches script output

---

### Phase 3: Full gate run [COMPLETED]

**Goal**: Confirm the relocation is green across the whole build and all module invariants.

**Tasks**:
- [x] Full `lake build` via `.claude/scripts/lake-build-guard.sh` (wait for any concurrent build);
      exit 0
- [x] `bash scripts/check-module-invariants.sh` in full (not `--no-build`); all invariants pass,
      specifically C4, C6, C15, C24 *(deviation: altered — first run failed only INV (stale generated inventory line counts in `Metalogic/README.md` and root `README.md`, caused by the move); regenerated, `--emit-inventory --check` now PASS; every other invariant PASS)*
- [x] `bash scripts/check-metalogic-cycles.sh` exit 0 (re-run after the build)
- [x] If the optional Soundness import narrowing was applied and anything fails, revert that one
      line and re-run rather than debugging it
- [x] Commit: `task 582: phase 3: break Conservativity <-> Deterministic cycle` (Phases 1-3 changes)

**Timing**: 45 minutes (dominated by build time)

**Depends on**: 1, 2

**Verification Tier**: full

**Files to modify**:
- none expected (fix-ups only if a gate fails)

**Verification**:
- All three commands exit 0

---

### Phase 4: Wire the cycle check into CI and prove it fails on a new cycle [COMPLETED]

**Goal**: A third directory-level cycle can never land undetected again.

**Tasks**:
- [x] Re-read `.github/workflows/ci.yml` and task 583's status/plan/summary: if 583's steps have
      landed, place the new step consistently with them; otherwise follow 583's recorded pattern
      directly
- [x] Add a step after "Compile lean_exe roots (outside the library closures)" and before
      "Report results", e.g.:
      `name: Check Metalogic directory-level import cycles`, `run:` with `set -euo pipefail`,
      `::group::`/`::endgroup::`, and `bash scripts/check-metalogic-cycles.sh`; add a short comment
      stating that the script asserts exactly one accepted cycle (see ADR-006) and why it is in CI
      (a second cycle previously went undetected); do not cite task numbers in the comment
- [ ] If `docs/development/CI_CD_PROCESS.md` has a per-step "CI Steps Explained" section (per 583's
      recommendation), add a brief entry for this step; skip if 583 has not created the convention
      and note it in the summary *(deviation: skipped — the 583 "Wiring a New Check Script" section is not yet in `CI_CD_PROCESS.md`; step appended directly before "Report results" after 583's uncommitted steps, named with the script path per 583's plan)*
- [x] Negative test (never committed): in a scratch copy of the repo tree (or a temporary edit
      reverted immediately), add `import FormalSystem.Metalogic.Deterministic.Completeness` to a
      live `Conservativity/` file, run the step's exact `run:` body locally, confirm non-zero exit
      and a `FAIL ... found 2` line naming the new cycle; restore and re-run to confirm exit 0
- [x] Validate workflow YAML syntax (e.g. `python3 -c 'import yaml,sys; yaml.safe_load(open(".github/workflows/ci.yml"))'`
      or `actionlint` if available)
- [x] `git status` shows no stray `.lean` changes from the negative test
- [x] Commit: `task 582: phase 4: wire metalogic cycle check into CI`

**Timing**: 40 minutes

**Depends on**: 3

**Verification Tier**: interface

**Files to modify**:
- `.github/workflows/ci.yml` - new named step
- `docs/development/CI_CD_PROCESS.md` - optional step entry (conditional on 583's convention)

**Verification**:
- YAML parses; the step body passes on the clean tree and fails on the deliberately introduced cycle

## Testing & Validation

- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0
- [ ] `lake build` exits 0
- [ ] `bash scripts/check-module-invariants.sh` passes in full
- [ ] `FormalSystem/Metalogic/README.md:73` cycle claim matches the script's assertion (one cycle)
- [ ] Relocated theorem's axioms: `propext`, `Classical.choice`, `Quot.sound` only; no sorry
- [ ] CI step fails on a deliberately introduced cycle and passes on the clean tree

## Artifacts & Outputs

- `FormalSystem/Metalogic/Deterministic/Completeness.lean` (theorem added)
- `FormalSystem/Metalogic/Conservativity/Plus/Corollaries.lean` (import and theorem removed)
- `docs/theorem-index.md`, `FormalSystem/Metalogic/Conservativity/Plus/README.md`, `FormalSystem/Metalogic/Deterministic/README.md`
- `.github/workflows/ci.yml` (new check step)
- `specs/582_break_or_rebaseline_metalogic_cycle/summaries/02_cycle-break-plan-summary.md`

## Rollback/Contingency

- Phases 1-3 are one logical commit: `git revert` restores the import and the theorem's old
  location and anchors.
- If A1 unexpectedly fails the full build in a way not fixable by qualifier adjustment, stop and
  return `partial` with the diagnostics; do not fall back to Option B without a user decision,
  since B requires a recorded ADR and was explicitly not to be chosen silently.
- Phase 4 is independently revertible (single workflow step).
