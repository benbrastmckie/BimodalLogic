# Implementation Plan: Task #587

- **Task**: 587 - Repair or retire the two broken `BimodalTest` benchmark modules
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/587_repair_or_retire_broken_benchmark_modules/reports/02_benchmark-repair-measurement.md
- **Artifacts**: plans/02_repair-and-retire-benchmarks.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Clear both `broken:` entries in `scripts/module-invariants-manifest.txt` using the split outcome
the research measured. `DerivationBenchmark` is repaired (a verified 35-line scratch repair, 0
errors, `#eval` runs all 15 benchmarks) and re-manifested as a plain C6 compile-checked module.
`SemanticBenchmark` is retired to `FormalSystem/Boneyard/` with a README, because it never calls
`TruthAt` and times a hand-written toy `Bool` evaluator, so repairing it would make the tree green
while keeping a benchmark that measures nothing. Stale prose in the test root, the test READMEs and
the two benchmark docs is fixed alongside. Success criterion: `check-module-invariants.sh` passes
with zero `broken:` entries, B0 still finds exactly 1 Boneyard directory, and C11 resolves every
archived import.

### Research Integration

- Real error counts: 38 (DerivationBenchmark, 8 root causes) and 20 (SemanticBenchmark, 5 root
  causes). `ProofSearchBenchmark` compiles and is imported by `Tests/BimodalTest.lean`, so it is
  not a blocker.
- DerivationBenchmark root-cause table (report section "Root causes"): `.atom "p"` -> `.atomS`;
  `DerivationTree fc Γ φ` with `fc : FrameClass`; `DerivationTree.axiom` needs `h_fc` (closed
  `by decide` at `.Base`); `Axiom.temp_4` removed (replacement `temporal4Derived` is
  `noncomputable`, unusable in `#eval`) -> use `Axiom.modal_future`; `all_future` -> `allFuture`;
  `swap_temporal` -> `swapTemporal`; `get! i` -> `[i]!`; `False.elim (List.not_mem_nil x hx)` ->
  `simp at hx`.
- Gate mechanics: C6 fails on a manifest entry naming a nonexistent module, so the archive move
  and the manifest-line deletion must land in one commit. B0 counts directories named `Boneyard`,
  so a new subdirectory is fine. C11's import regex resolves all of the archived file's
  `FormalSystem.*`/`BimodalTest.*` imports without a waiver.
- Invocation measurement: 0 live and 0 `Tests/` invocations for both modules; the
  `scripts/run-benchmarks.sh` both docs cite does not exist.

### Planning-time additions (verified by direct read)

- `FormalSystem/Boneyard/README.md` has two generated inventory blocks
  (`<!-- BEGIN GENERATED: inventory dir=FormalSystem/Boneyard ... -->`, lines ~102 and ~202)
  that must be regenerated with `bash scripts/check-module-invariants.sh --emit-inventory` and
  verified with `--emit-inventory --check`. It also has hand-written entries that need a new row
  each: the category/status table (~line 307), the per-directory `###` sections (alphabetical,
  e.g. `### RetiredTactics` ~line 538), and the dated archive log (~line 741, which cites a
  commit hash).
- C9 forbids task-number citations under `FormalSystem/` and `scripts/`, so the new Boneyard
  README and the manifest comment must use durable anchors only.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch.

## Goals & Non-Goals

**Goals**:
- `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` compiles with 0 errors and its
  trailing `#eval` runs; manifested as a plain (compile-checked) C6 entry.
- `SemanticBenchmark.lean` archived under `FormalSystem/Boneyard/SemanticBenchmarkToyEvaluator/`
  with `#exit` after the imports and a README recording what it claimed vs. what it measured.
- Zero `broken:` lines in `scripts/module-invariants-manifest.txt`.
- No stale prose referencing the old reasons, the nonexistent `run-benchmarks.sh`, the retired
  semantic benchmark, or the prefix-less `BimodalTest/...` paths.

**Non-Goals**:
- Writing a real computable `TruthAt` benchmark (new work, not a repair).
- Wiring `DerivationBenchmark` into `Tests/BimodalTest.lean` (its top-level `#eval` would run on
  every `lake test`).
- Removing the `broken:` mechanism from `check-module-invariants.sh` itself.
- Fixing the pre-existing integer-division "Average tree height" display (optional nicety only).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Archive move and manifest deletion land in separate commits, leaving C6 red | M | M | Phase 2 is `atomic-batch`: `git mv`, `#exit`, manifest deletion, README all in one commit |
| Boneyard generated inventory blocks go stale | M | H | Run `--emit-inventory` then `--emit-inventory --check` in Phase 2 |
| Repaired benchmark drifts again | M | L | Plain C6 entry runs `lake build <module>` on every full gate run |
| Scratch repair not reproducible (scratchpad gone) | L | M | Root-cause table in the report is complete; re-derive from `lake env lean` errors |
| Doc baselines (~90 ns) conflict with repaired run (~140 ns) | L | M | Refresh numbers from the repaired run or label them indicative |
| Task-number citation slips into Boneyard README or manifest comment | M | L | C9 catches it; cite filenames/section headings only |
| The dated archive log row needs a commit hash that does not exist until commit | L | H | Commit the archive batch first, then add the log row with the real hash in a follow-up edit (or in Phase 3's commit) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases are serialized: phases 1 and 2 both edit the `# --- Tests ---` block of
`scripts/module-invariants-manifest.txt`, and phase 3 rewrites prose describing both outcomes.

### Phase 1: Repair and re-manifest DerivationBenchmark [COMPLETED]

**Goal**: `DerivationBenchmark.lean` compiles with 0 errors, its `#eval` runs, and C6
compile-checks it.

**Tasks**:
- [x] Apply the 8 root-cause fixes from the research report to
      `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`: `.atomS`; add the `FrameClass`
      index (use `.Base`) to every `DerivationTree`; add `h_fc` (`by decide`) to each
      `DerivationTree.axiom`; `allFuture`; `swapTemporal`; `[i]!`; `simp at hx`.
- [x] Replace the removed `Axiom.temp_4` in `mkTemp4` with `Axiom.modal_future p`
      (`□p → □Gp`); keep `mkTemporalDuality` applying `temporal_duality` to it; rename the
      affected benchmark labels (e.g. "Axiom (Modal-Future)") and any function names that say
      `Temp4`. *(completed: `mkTemp4` -> `mkModalFuture`)*
- [x] Keep the trailing top-level `#eval ...runAllDerivationBenchmarks`.
- [x] Run `lake env lean Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` until exit 0 and
      15 benchmarks print.
- [x] In `scripts/module-invariants-manifest.txt`, change
      `broken: BimodalTest.ProofSystem.DerivationBenchmark` to the plain line, and give it its own
      comment: a benchmark kept out of `Tests/BimodalTest.lean` because its top-level `#eval`
      would run on every `lake test`; C6 compiles (and so runs) it in isolation.
- [x] `lake build BimodalTest.ProofSystem.DerivationBenchmark` exits 0.

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: about 35 changed lines of 374, per the research's scratch trial. Confirm
by `git diff --stat` after the repair; if the diff grows well past ~60 lines, re-check that no
benchmark was silently dropped.

**Files to modify**:
- `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` - API-drift repair
- `scripts/module-invariants-manifest.txt` - `broken:` -> plain entry, new comment

**Verification**:
- `lake env lean` on the file exits 0 with no `error` lines; output lists 15 benchmarks.
- `lake build BimodalTest.ProofSystem.DerivationBenchmark` exits 0.
- No `sorry` in the file (`grep -c sorry` is 0).

---

### Phase 2: Archive SemanticBenchmark to the Boneyard [NOT STARTED]

**Goal**: Retire `SemanticBenchmark` following the `RetiredTactics/` precedent, with C6, B0 and
C11 green in the same commit.

**Tasks**:
- [ ] `git mv Tests/BimodalTest/Semantics/SemanticBenchmark.lean
      FormalSystem/Boneyard/SemanticBenchmarkToyEvaluator/SemanticBenchmark.lean`.
- [ ] Insert `#exit` directly after the import block (compare
      `FormalSystem/Boneyard/RetiredTactics/Helpers.lean`).
- [ ] Write `FormalSystem/Boneyard/SemanticBenchmarkToyEvaluator/README.md` recording: the claim
      ("benchmarks `TruthAt` evaluation") vs. reality (`evalFormula` is a 6-case `Bool` function,
      box always true, `TruthAt` never called; `benchFrame`/`benchModel`/`benchHistory`/
      `domainProof0` unused); the 0 live / 0 `Tests/` invocation measurement; the 20-error
      baseline; the mechanical repair yielding 14/16 "correct" (Gp, Hp) because the `untl`/`snce`
      branches have no correct value; what a real replacement would need (a computable evaluator
      over a finite model); and the guard-first note (no `untl`/`snce` call sites to swap). No
      task numbers.
- [ ] Delete the `broken: BimodalTest.Semantics.SemanticBenchmark` line from
      `scripts/module-invariants-manifest.txt` and replace the "These two do not compile" comment
      so it no longer describes a broken pair.
- [ ] Update `FormalSystem/Boneyard/README.md` hand-written parts: add a
      `### SemanticBenchmarkToyEvaluator` section (alphabetical position), a row in the
      category/status table (Orphaned, Not Refuted -- retired on a measurement; or the category
      that best fits a benchmark that measured nothing real), and, if the section describing
      measurement-based retirements names `RetiredTactics/` alone, mention the new directory too.
- [ ] Regenerate the inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`,
      then `--emit-inventory --check` exits 0.
- [ ] Commit this batch as one commit, then add the dated archive-log row
      (`| 2026-09-16 | <hash> | SemanticBenchmarkToyEvaluator/ -- ... |`) with the real hash.

**Timing**: 50 minutes

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Files to modify**:
- `Tests/BimodalTest/Semantics/SemanticBenchmark.lean` - moved (git mv)
- `FormalSystem/Boneyard/SemanticBenchmarkToyEvaluator/SemanticBenchmark.lean` - new location, `#exit` added
- `FormalSystem/Boneyard/SemanticBenchmarkToyEvaluator/README.md` - new
- `FormalSystem/Boneyard/README.md` - section, table row, log row, regenerated inventory
- `scripts/module-invariants-manifest.txt` - delete broken line, rewrite comment

**Verification**:
- `grep -c '^broken:' scripts/module-invariants-manifest.txt` prints 0.
- `bash scripts/check-module-invariants.sh --no-build` shows `PASS B0` (exactly 1 directory),
  `PASS C6`, no `known-broken` INFO line, `PASS C11` (one more archived file than the 168
  baseline), `PASS C9`.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.

---

### Phase 3: Fix stale prose [NOT STARTED]

**Goal**: No deliverable describes the old broken state, the retired semantic benchmark as live,
the nonexistent `run-benchmarks.sh`, or prefix-less test paths.

**Tasks**:
- [ ] `Tests/BimodalTest.lean` (excluded-modules comment, ~lines 73-85): three excluded modules;
      `DerivationBenchmark` excluded because its top-level `#eval` would run on every `lake test`
      (compile-checked by the manifest), not because it fails to compile; drop
      `SemanticBenchmark`; fix "All four".
- [ ] `Tests/BimodalTest/Semantics/README.md`: remove the `SemanticBenchmark.lean` row.
- [ ] `docs/project-info/performance-targets.md`: remove the "Semantic Evaluation" section; use
      `Tests/BimodalTest/...` paths; replace `./scripts/run-benchmarks.sh` with the real command
      (`lake env lean Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`); replace Temporal-4
      rows with the renamed Modal-Future benchmarks; refresh or label baselines as indicative.
- [ ] `docs/development/BENCHMARKING_GUIDE.md`: remove the `SemanticBenchmark` layout/run lines
      and the `run-benchmarks.sh` references (~lines 98-114, 179); fix paths; the example result
      struct may stay as a pattern (rename away from `SemanticBenchmarkResult` if it reads as a
      live file).
- [ ] Final `grep -rn "SemanticBenchmark\|run-benchmarks" --exclude-dir=.lake --exclude-dir=specs .`
      returns only the Boneyard directory and its README mentions.

**Timing**: 35 minutes

**Depends on**: 2

**Verification Tier**: prose

**Files to modify**:
- `Tests/BimodalTest.lean` - comment block only
- `Tests/BimodalTest/Semantics/README.md` - row removal
- `docs/project-info/performance-targets.md` - section removal, paths, command, rows
- `docs/development/BENCHMARKING_GUIDE.md` - layout, run commands, paths

**Verification**:
- The grep above shows no live references.
- `check-module-invariants.sh --no-build` C12/C13 (docs paths and links) pass.

---

### Phase 4: Full gate verification [NOT STARTED]

**Goal**: Confirm the success criterion with the full (building) gate.

**Tasks**:
- [ ] `bash scripts/check-module-invariants.sh` (full, not `--no-build`).
- [ ] Confirm: `PASS B0 ... exactly 1 directory`; `PASS C6` with 16 compile-checked modules and
      no `known-broken` INFO; `PASS C11`; `PASS C9`; C12/C13 pass; no new failures anywhere.
- [ ] `lake build` and `lake test` succeed, unchanged from baseline.
- [ ] Fix any regression found and re-run.

**Timing**: 20 minutes (plus build wall time)

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- None expected (fixes only if a gate fails)

**Verification**:
- Full gate exits 0; `grep -c '^broken:' scripts/module-invariants-manifest.txt` is 0.

## Testing & Validation

- [ ] `lake env lean Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` exits 0, 15 benchmarks run
- [ ] `grep -c '^broken:' scripts/module-invariants-manifest.txt` = 0
- [ ] Full `check-module-invariants.sh`: B0 (exactly 1), C6 (16 modules, no broken INFO), C11, C9, C12, C13 pass
- [ ] `--emit-inventory --check` exits 0
- [ ] `lake build` and `lake test` green

## Artifacts & Outputs

- Repaired `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`
- `FormalSystem/Boneyard/SemanticBenchmarkToyEvaluator/{SemanticBenchmark.lean,README.md}`
- Updated manifest, Boneyard README, test root comment, test README, two docs
- `specs/587_repair_or_retire_broken_benchmark_modules/summaries/02_repair-and-retire-benchmarks-summary.md`

## Rollback/Contingency

- Each phase commits separately; `git revert` the phase commit to back out.
- If the DerivationBenchmark repair unexpectedly balloons (e.g. new drift since research), fall
  back to archiving it as well into the same new Boneyard directory (renamed to cover both), with
  the same 0/0 invocation measurement, and delete its manifest line -- the zero-`broken:` success
  criterion still holds.
- If C11 unexpectedly fails on the archived imports, add a waiver per the existing C11 waiver
  mechanism rather than editing the archived file's imports.
