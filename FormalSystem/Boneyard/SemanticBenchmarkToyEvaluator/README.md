# SemanticBenchmarkToyEvaluator -- a semantics benchmark that never evaluated the semantics

Archived 2026-09-16.

One whole module, `SemanticBenchmark.lean` (358 lines), moved unchanged apart from the archival
banner and `#exit` from `Tests/BimodalTest/Semantics/SemanticBenchmark.lean`. It was a
`#eval`-driven benchmark harness, not a correctness test, and nothing ever compiled it: it was not
imported by `Tests/BimodalTest.lean` and sat in `scripts/module-invariants-manifest.txt` as a
`broken:` entry, which C6 skips. It was retired rather than repaired because a repair would have
made the tree green while keeping a benchmark that measures nothing.

## What it claimed versus what it measured

**The claim.** The module docstring reads "Benchmarks for evaluating `TruthAt` evaluation
performance", with an "expected vs. actual" correctness column described as a soundness check.
`docs/project-info/performance-targets.md` presented it as the benchmark suite for
`FormalSystem.Semantics.Truth`, with "Correctness: PASS" baselines.

**The reality.**

- `TruthAt` is **never called**. The name occurs only in the docstring and in one comment.
- What is timed is `evalFormula`, a hand-written six-case `Formula -> Bool` function private to
  this file. It hard-codes `.box _ => true`, `.all_past _ => true` and `.all_future _ => true`,
  and evaluates atoms by string comparison against `"p"`.
- `benchFrame`, `benchModel`, `benchHistory` and `domainProof0` -- the only declarations that
  touch the library's semantic types (`FrameOver`, `TaskModel`, `ConvexHistory`) -- are defined
  and then never used.
- The "correctness" column compares a hand-typed constant against `evalFormula`. It checks the
  toy function against the author's expectation of the toy function, not anything against the
  library's semantics.

## The measurement that retired it

The same test that retired [`../RetiredTactics/`](../RetiredTactics/README.md): real invocations,
not mentions.

| Entry point | Live invocations | Test invocations | Mentions that are not invocations |
|---|---:|---:|---|
| `runAllSemanticBenchmarks` and the five `run*Benchmarks` categories | 0 | 0 | its own trailing `#eval`; its own docstring's usage block |
| `SemanticBenchmarkResult` | 0 | 0 | copied as a pattern example into `docs/development/BENCHMARKING_GUIDE.md` (since renamed there) |

No CI workflow or script ran it. The `scripts/run-benchmarks.sh` that its documentation cited as
the way to run it does not exist.

## Why it was not repaired

At archival, `lake env lean` on the file reported **20 errors from 5 root causes**, among them the `Atom`
type change (`p = "p"` in the valuation), the `atom_s` -> `atomS` rename (12 of the 20), the
removal of `all_past`/`all_future` as `Formula` constructors in favour of the `untl`/`snce`
primitives, and the removal of `List.get!`.

A mechanical repair was trialled in a scratch copy: rename the atoms, rewrite the valuation over
`Atom`, replace the two removed match arms with `.untl _ _ => true` / `.snce _ _ => true`, and use
`[i]!`. It compiled with 0 errors. Run, it reported **`Correct results: 14/16`**, with `Gp` and
`Hp` now `false`: `allFuture p` is now derived from `untl`, so it flows through a branch whose
value was invented for the repair. There is no correct value to choose for those branches,
because `evalFormula` has no connection to the library's semantics. The benchmark was never
checking anything.

The derivation-tree benchmark that shared its manifest block,
`Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`, was in the same state and was
**repaired** instead: it builds and measures real `DerivationTree` values. It is now a plain,
compile-checked entry in `scripts/module-invariants-manifest.txt`.

## Convention note: nothing here to swap

The archive-wide banner in [`../README.md`](../README.md) tells you to swap the two arguments of
every `Formula.untl` and `Formula.snce` before resurrecting an archived file. This file contains
**no** `untl` or `snce` occurrence -- it predates those primitives and uses the removed
`all_past`/`all_future` constructors instead -- so the banner's swap has nothing to act on here.
The work on resurrection is the API repair above, not an argument swap.

## Resurrecting something from here

Do not resurrect `evalFormula`. A real semantic-evaluation benchmark is new work, not a repair:
`TruthAt` is a `Prop` and is not decidable in general, so benchmarking it needs a computable
evaluator over a **finite** model that is proved to agree with `TruthAt` on that model, and a
correctness column that compares against that evaluator. The timing harness here (`timed`,
median of 100 runs) is the only reusable part, and it is shared with the live
`Tests/BimodalTest/Automation/ProofSearchBenchmark.lean`, which is where it should be taken from.
