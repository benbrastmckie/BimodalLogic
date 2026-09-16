# Research Report: Task #587

**Task**: 587 - Repair or retire the two broken `BimodalTest` benchmark modules
**Started**: 2026-09-16T08:51:48-07:00
**Completed**: 2026-09-16T08:56:00-07:00
**Effort**: Small (about 1-2 hours). One file needs 35 changed lines; the other is archived with a README, plus about 6 files of prose updates.
**Dependencies**: None
**Sources/Inputs**: - Codebase (`lake env lean` on both modules and on repair attempts in a scratch copy), `scripts/check-module-invariants.sh` (B0/C6/C11 source), `scripts/module-invariants-manifest.txt`, `FormalSystem/Syntax/Formula.lean`, `FormalSystem/ProofSystem/{Derivation,Axioms}.lean`, `FormalSystem/Theorems/TemporalDerived.lean`, `FormalSystem/Boneyard/{README.md,RetiredTactics/README.md}`, docs that cite the benchmarks. No Mathlib search was needed: this is a repair-or-retire task, not a proof task.
**Artifacts**: - specs/587_repair_or_retire_broken_benchmark_modules/reports/02_benchmark-repair-measurement.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The real error counts are 38 and 20, not a single `String`/`Atom` change.** The code has drifted in several ways since these files were written: `Formula`'s primitives are now `untl`/`snce`, so `all_future`/`all_past` are gone; `DerivationTree` now takes a `FrameClass` index, and its `axiom` constructor needs a proof `h_fc`; `Axiom.temp_4` was removed and is now the `noncomputable` `temporal4Derived`; `atom_s`/`swap_temporal` were renamed to `atomS`/`swapTemporal`; and `List.get!` no longer exists. Most of the 38 errors are knock-on failures from about 8 root causes.
- **The dependency is fine.** `BimodalTest.Automation.ProofSearchBenchmark` is imported by `Tests/BimodalTest.lean:35`, so the normal build reaches it. It compiles in isolation in 2 s, with exit code 0.
- **DerivationBenchmark: REPAIR. This is proven, not estimated.** A scratch copy with 35 changed lines compiles with **0 errors** and its `#eval` runs all 15 benchmarks in about 1.9 s. It measures real `DerivationTree` construction and height, so it is worth keeping. Pair the repair with changing its manifest line from `broken:` to a plain line, so C6 runs `lake build` on it every time.
- **SemanticBenchmark: RETIRE to the Boneyard.** It **never calls `TruthAt`**. It times a hand-written 6-case `Bool` function (`evalFormula`) that hard-codes "box is always true". Its `benchFrame`/`benchModel`/`benchHistory`/`domainProof0` are defined but never used. Its "correctness" column compares a hand-typed constant against that function. A 12-line mechanical fix compiles with 0 errors, but running it gives **14/16 "correct"**: Gp and Hp now come out `false`, because the function's `untl`/`snce` branches are made up. There is no correct value to pick, because the function has no link to the library's semantics. Repairing it would make the tree green while keeping a benchmark that measures nothing.
- **Recommended approach: split the decision.** Repair and re-manifest `DerivationBenchmark`, and archive `SemanticBenchmark` to `FormalSystem/Boneyard/<dir>/` with a README. Either way the success test is met: `check-module-invariants.sh` passes with zero `broken:` entries. B0 is unaffected, because it counts directories named `Boneyard`, not their subdirectories. C11 resolves all of `SemanticBenchmark`'s archived imports: its `import Mathlib...` line is outside C11's import regex, and the other three targets still exist.

## Context & Scope

This covers the two modules marked `broken:` in `scripts/module-invariants-manifest.txt` (lines 102-103), which C6 skips (`scripts/check-module-invariants.sh:898-900`). What was measured:

1. Whether the imported `ProofSearchBenchmark` compiles.
2. The real error count for each module (`lake env lean`).
3. The actual repair size, by repairing scratch copies until they compiled, then running their `#eval`.
4. The invocation count used to retire `RetiredTactics/`: real invocations in live code or `Tests/`.
5. How B0, C6 and C11 would treat each outcome.

No repository `.lean` files were changed. All trial repairs are in the session scratchpad.

## Findings

### Baseline measurements

| Module | `lake env lean` exit | `error` lines | Distinct root causes |
|---|---|---:|---|
| `BimodalTest.Automation.ProofSearchBenchmark` | 0 | 0 | reachable via `Tests/BimodalTest.lean:35`; not a blocker |
| `BimodalTest.ProofSystem.DerivationBenchmark` | 1 | 38 | 8 (below); 17 of the 38 are `Unknown identifier mkX` knock-on errors |
| `BimodalTest.Semantics.SemanticBenchmark` | 1 | 20 | 5; 12 of the 20 are the `atom_s` rename |

Current gate baseline (`check-module-invariants.sh --no-build`): `PASS B0` (exactly 1 directory), `PASS C6` (15 unreachable modules manifested), `INFO C6 2 module(s) manifested as known-broken`, `PASS C11` (536 archived import lines in 168 files resolve, 7 waived).

### Root causes (DerivationBenchmark)

| # | Old | Current API | Evidence |
|---|---|---|---|
| 1 | `.atom "p"` | `.atomS "p"` (`Formula.atomS`, `Formula.lean:133`) | 3 abbrevs |
| 2 | `DerivationTree Γ φ` | `DerivationTree fc Γ φ`, `fc : FrameClass` | `Derivation.lean:91` |
| 3 | `DerivationTree.axiom Γ φ h` | extra `h_fc : h.minFrameClass ≤ fc` (closed by `by decide` at `.Base`) | `Derivation.lean:98` |
| 4 | `Axiom.temp_4` | removed; `temporal4Derived` is `noncomputable` (`TemporalDerived.lean:244`), so it cannot be used in an `#eval` benchmark | `Axioms.lean:136` |
| 5 | `Formula.all_future` | `Formula.allFuture` (derived, `Formula.lean:169`) | |
| 6 | `.swap_temporal` | `.swapTemporal` | `Derivation.lean:156` |
| 7 | `sortedTimes.get! i` | `sortedTimes[i]!` | `List.get!` removed |
| 8 | `False.elim (List.not_mem_nil x hx)` | `simp at hx` | signature change |

### Verified DerivationBenchmark repair (scratch trial)

The changes that took the file to **0 errors**:

- Apply causes 1, 2, 3, 5, 6, 7 and 8 mechanically (about 30 lines).
- `mkTemp4` (cause 4): replace the removed `temp_4` axiom with a computable one that uses a temporal operator, `Axiom.modal_future p : □p → □Gp` (`Axioms.lean:295`). `mkTemporalDuality` then applies `temporal_duality` to that proof. Rename the benchmark labels to match ("Axiom (Modal-Future)"). The alternative is to drop the two temporal-4 benchmarks, but that loses coverage for no reason.
- Total: **35 changed lines** out of 374.
- Run output with the trailing `#eval` active: 15 benchmarks, heights 0/1/2 as expected, total about 2 µs, whole file 1.9 s wall time.
- Minor, pre-existing: `Average tree height: 0` is integer division (12/15). Optionally print it as a fraction; this does not block the task.

The trailing top-level `#eval BimodalTest.ProofSystem.Benchmark.runAllDerivationBenchmarks` (line 374) runs during compilation. C6 compiles with `lake build <module>` (`check-module-invariants.sh:907`), so every C6 run would also run the benchmark: about 40 lines of output that C6 captures, and under 2 s. Keep it. It is the only thing that actually executes the harness, so without it the "guarded" module could compile and still fail at run time.

### SemanticBenchmark: why a repair is not worth it

- The docstring claims "Benchmarks for evaluating `TruthAt` evaluation performance". `grep TruthAt` finds only the docstring and one comment. `evalFormula` (lines 89-106) is a separate `Bool` function: `.box _ => true`, `.all_past _ => true`, `.all_future _ => true`.
- `benchFrame`, `benchModel`, `benchHistory` and `domainProof0` (lines 50-60) appear nowhere else in the file.
- The scratch repair renamed the atoms and operators, rewrote the valuation as `Atom.mkBase "p"`, replaced the two removed match arms with `.untl _ _ => true` / `.snce _ _ => true`, and applied the `get!` fix. It compiled with **0 errors**. When run, the harness reported `Correct results: 14/16` and a WARNING for `Gp` and `Hp`, because `allFuture p = ¬(⊤ U ¬p)` flows through the made-up `untl` branch. Any value chosen for those branches is arbitrary. The benchmark was never checking semantics.
- `docs/project-info/performance-targets.md` describes this suite as "Benchmarks for `FormalSystem.Semantics.Truth`" with "Correctness: PASS" baselines. That claim was false when it was written.
- A real semantic benchmark would need a computable evaluator for `TruthAt` (a `Prop` that is not decidable in general) over a finite model. That is new work, not a repair, and is out of scope here.

### Invocation measurement (the `RetiredTactics/` test)

Searched for `runAll*Benchmarks`, each `run*Benchmarks` category, and `*BenchmarkResult` across the repository, excluding `.lake` and `specs/archive`:

| Module | Live invocations | Test invocations | Mentions that are not invocations |
|---|---:|---:|---|
| DerivationBenchmark | 0 | 0 (only its own trailing `#eval`) | `docs/project-info/performance-targets.md`, `docs/development/BENCHMARKING_GUIDE.md`, `Tests/BimodalTest/ProofSystem/README.md`, `Tests/BimodalTest.lean:79` comment |
| SemanticBenchmark | 0 | 0 (only its own trailing `#eval`) | same docs, `Tests/BimodalTest/Semantics/README.md`, `Tests/BimodalTest.lean:79` comment |

No CI workflow or script runs them. `.github/workflows/ci.yml` has no benchmark step, and the `scripts/run-benchmarks.sh` that both docs cite **does not exist**. The docs also give the paths without the `Tests/` prefix (`BimodalTest/...`), which has been wrong since the move to `Tests/`. So the retirement measurement applies to both modules. `DerivationBenchmark` stays only because it is cheap to repair and measures something real; `SemanticBenchmark` fails on both counts.

### Gate mechanics for each outcome

- **C6** (`check-module-invariants.sh:861-921`): the manifest is split into `manifest` and `manifest_broken`. It fails if an unreachable live module is missing from the manifest, or if a manifest entry names a module that does not exist or is reachable. Plain entries are checked with `lake build <m>`.
  - Repaired `DerivationBenchmark`: change `broken: BimodalTest.ProofSystem.DerivationBenchmark` to `BimodalTest.ProofSystem.DerivationBenchmark`. C6's count goes from 15 to 16 compile-checked modules.
  - Archived `SemanticBenchmark`: **delete** its manifest line in the same commit as the move. Otherwise C6 fails on an entry naming a module that no longer exists.
- **B0** (`:611-624`) counts directories *named* `Boneyard`, so a new subdirectory under `FormalSystem/Boneyard/` keeps it at exactly 1.
- **C11** (`:773`, `:990-1046`): `imp_re` matches only `FormalSystem.*`/`BimodalTest.*` imports. The archived file's imports are `Mathlib.Algebra.Order.Group.Int` (not matched), `FormalSystem.Semantics.Truth` and `FormalSystem.Semantics.TaskFrame` (both exist), and `BimodalTest.Automation.ProofSearchBenchmark`. That last one is resolved by `mod_to_path` under `Tests/` (`:760-762`) and exists. No waiver is needed.
- **Archive convention** (`Boneyard/README.md`): every archived file has `#exit` right after its import block (compare `RetiredTactics/Helpers.lean:14`). The directory README states what the code measured and the measurement that retired it.

### Recommendations

1. **Repair `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`** with the 8 root-cause fixes above, using `Axiom.modal_future` in place of the removed `temp_4` for the axiom and temporal-duality benchmarks, and keep the trailing `#eval`. Check with `lake env lean <file>` (exit 0) and `lake build BimodalTest.ProofSystem.DerivationBenchmark`.
2. **Re-manifest it** as a plain compile-checked line. Rewrite the comment above it in the `# --- Tests ---` block: it is a benchmark kept out of `Tests/BimodalTest.lean` because its top-level `#eval` would run on every `lake test`, and C6 compiles it in isolation.
3. **Archive `SemanticBenchmark.lean`** with `git mv` to a new directory, for example `FormalSystem/Boneyard/SemanticBenchmarkToyEvaluator/SemanticBenchmark.lean`. Insert `#exit` after the imports. Add a `README.md` that records:
   - what it claimed to measure versus what it actually measured (a toy `Bool` evaluator, not `TruthAt`)
   - the 0/0 invocation table
   - the 14/16 result after a mechanical repair
   - the guard-first convention note: it has no `untl`/`snce` call sites, so the archive-wide swap banner has nothing to swap. Say so explicitly, as `RetiredTactics/README.md` does.

   Delete its manifest line. Mention it in `FormalSystem/Boneyard/README.md` if that file keeps a directory index.
4. **Fix the prose that becomes stale in the same commit**, because C13/C20 and future readers depend on it:
   - `Tests/BimodalTest.lean:73-85`: now 3 excluded modules; `DerivationBenchmark` is excluded because of its top-level `#eval`, not because it fails to compile.
   - `Tests/BimodalTest/Semantics/README.md:12`: remove the row.
   - `Tests/BimodalTest/ProofSystem/README.md:12`: keep.
   - `docs/project-info/performance-targets.md`: remove the "Semantic Evaluation" section; add the `Tests/` path prefix; remove or replace the nonexistent `./scripts/run-benchmarks.sh`; replace the Temporal 4 rows with the renamed benchmarks.
   - `docs/development/BENCHMARKING_GUIDE.md:51-60, 96-114`: remove the `SemanticBenchmark` layout and run lines; fix the paths; the example struct can stay as a pattern.
   - Keep task numbers out of all deliverables (`no-task-references-in-deliverables.md`).
5. **Verify**: `bash scripts/check-module-invariants.sh` (full, not `--no-build`) shows `PASS B0 ... exactly 1 directory`, `PASS C6 all 16 manifested module(s) still compile`, no `known-broken` INFO line, `PASS C11` with 537 import lines in 169 files; `grep -c '^broken:' scripts/module-invariants-manifest.txt` is 0; `lake build` and `lake test` are unchanged.

There is a path with no `sorry` for everything: neither file contains or needs a proof obligation beyond `by decide`/`by simp` membership and frame-class goals, all of which the trial closed.

## Decisions

- Recommend splitting the outcome rather than applying one rule to both files. The task's small-vs-large test does not fit `SemanticBenchmark`: its repair is small, but what it measures is worthless. The success test (zero `broken:` entries, B0 and C11 green) is met either way.
- Replace the removed `temp_4` with `modal_future` rather than making the benchmark `noncomputable`: `#eval` cannot run noncomputable definitions.
- Keep `DerivationBenchmark`'s trailing `#eval`, so the C6 compile check also checks that it runs.
- Do not wire `DerivationBenchmark` into `Tests/BimodalTest.lean`: its top-level `#eval` would run and print on every `lake test`, which is the cost the task asks to avoid.
- No `user_decision` is set. The dispatch description already gives the repair/archive rule, and the split follows from measured evidence.

## Risks & Mitigations

- **Risk**: Moving a manifest line and the file in separate commits leaves C6 red (the entry names a module that does not exist). **Mitigation**: do the `git mv`, the manifest deletion and the `#exit` insertion in one commit.
- **Risk**: Archiving without `#exit` could leave a Boneyard file with live imports that fails if anything ever compiles it. **Mitigation**: follow the `RetiredTactics/` convention; B0 already ensures `lake build` produces no Boneyard `.olean`.
- **Risk**: The repaired benchmark could drift again. **Mitigation**: that is what the plain C6 entry is for; it runs `lake build <module>` on every full gate run.
- **Risk**: `performance-targets.md` baselines (about 90 ns) come from an older machine and API; the trial shows about 140 ns. **Mitigation**: refresh the numbers from the repaired run, or label them as indicative only; do not treat them as regressions.
- **Risk**: C17's dead-declaration scan count changes slightly. **Mitigation**: it is advisory only ("never affects FAILURES").

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `(Axiom.modal_t p).minFrameClass ≤ .Base` (and modal_4/modal_b/modal_future) | `decide` | success | `FrameClass` has `DecidableEq` + a matched `LE` |
| `p ∈ [p]`, `p ∈ [p, q]`, context membership in `ctxMP1/ctxMP2` | `simp` / `simp [ctxMP2]` | success | default simp set (unchanged from original) |
| `x ∈ [] → x ∈ [□p]` (weakening subset) | `intro x hx; simp at hx` | success | replaces `False.elim (List.not_mem_nil x hx)`, whose signature changed |

## Context Extension Recommendations

- **Topic**: API drift in files that nothing builds
- **Gap**: No context file warns that `broken:` manifest entries collect drift beyond the stated cause. Here the manifest comment named one cause (`String`/`Atom`), and there were 8.
- **Recommendation**: none needed if this task removes the last `broken:` entry. If the mechanism stays, the manifest header could require a measured error count and date for each `broken:` line.

## Appendix

Commands run (repository root):

```
lake env lean Tests/BimodalTest/Automation/ProofSearchBenchmark.lean      # exit 0, 2.1 s
lake env lean Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean      # exit 1, 38 errors
lake env lean Tests/BimodalTest/Semantics/SemanticBenchmark.lean          # exit 1, 20 errors
lake env lean <scratch>/DB.lean      # repaired copy: 0 errors (35 changed lines)
lake env lean <scratch>/DBrun.lean   # with #eval: 15 benchmarks run, 1.9 s
lake env lean <scratch>/SB.lean      # mechanical repair: 0 errors
lake env lean <scratch>/SBrun.lean   # with #eval: "Correct results: 14/16", Gp/Hp wrong
bash scripts/check-module-invariants.sh --no-build   # B0 PASS, C6 PASS + 2 broken INFO, C11 PASS
grep -rn 'runAll(Derivation|Semantic)Benchmarks|run*Benchmarks|*BenchmarkResult'  # invocation measurement
```

Key file:line anchors: `scripts/module-invariants-manifest.txt:97-103`; `scripts/check-module-invariants.sh:611-624` (B0), `:760-762` (`mod_to_path`), `:773` (`imp_re`), `:861-921` (C6), `:990-1046` (C11); `FormalSystem/ProofSystem/Derivation.lean:91-166`; `FormalSystem/ProofSystem/Axioms.lean:125-137,295,538`; `FormalSystem/Theorems/TemporalDerived.lean:244`; `FormalSystem/Syntax/Formula.lean:77-133`; `Tests/BimodalTest/Semantics/SemanticBenchmark.lean:50-60,89-106`.
