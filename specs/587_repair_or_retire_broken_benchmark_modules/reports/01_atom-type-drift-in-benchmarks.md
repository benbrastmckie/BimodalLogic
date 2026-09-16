# Sweep Evidence Report: Task #587

**Task**: 587 — Repair or retire the two broken `BimodalTest` benchmark modules
**Produced**: 2026-09-16 (repository hygiene sweep)
**Status**: Pre-research evidence.
**Effort**: Small–Medium. 732 lines across two files; the fix is a type change, but the decision is whether to fix at all.
**Dependencies**: None.
**Sources/Inputs**:
- `scripts/module-invariants-manifest.txt`, `# --- Tests ---` section
- `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` (374 lines),
  `Tests/BimodalTest/Semantics/SemanticBenchmark.lean` (358 lines)
- `scripts/check-module-invariants.sh` C6 (rot guard) and its `broken:` mechanism
- `specs/reviews/review-2026-09-16.md`, Finding M2

## Executive Summary

- Both modules are recorded `broken:` in the C6 manifest, with the reason stated precisely: *"they
  pass `String` where `Atom` is now expected, i.e. they predate the Atom type change and were
  never updated because nothing builds them."*
- **The recording was the right call and should not be criticised.** Its stated purpose is to stop
  the rot being re-discovered on every run, which it achieves. But a `broken:` entry is a parking
  space, not a destination, and these two have been parked. C6 does not compile-check them, so
  they are the only two live `.lean` files in the repository with *no* guarantee of any kind.
- **The real question is whether they should exist.** Both are benchmark harnesses, not
  correctness tests. `FormalSystem/Automation/ProofFirstBenchmark` is separately manifested as
  unreachable for a related reason. If the project does not run benchmarks, archiving these to
  `FormalSystem/Boneyard/` is a cleaner outcome than repairing 732 lines of code nothing invokes —
  and there is precedent: `Boneyard/RetiredTactics/` retired fourteen declarations on exactly that
  measurement (zero invocations anywhere live or in `Tests/`).

## The two options

### Option A — repair

The failure is a single type change: `Atom` replaced `String` in whatever constructor these
harnesses feed. Mechanically small per site; the volume is unknown until the files are compiled.
First step is simply:

```
lake env lean Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean
lake env lean Tests/BimodalTest/Semantics/SemanticBenchmark.lean
```

which gives the true error count. Repairing alone is not enough, though — a repaired module that
stays unimported by `Tests/BimodalTest.lean` rots again immediately. Repair must be paired with
either (a) wiring it into the test root, or (b) moving its manifest line from `broken:` to the
plain unreachable list so C6 compile-checks it every run. Option (b) is the cheaper and probably
correct pairing, since a benchmark in the test root would slow every `lake test`.

Note `DerivationBenchmark.lean` imports `BimodalTest.Automation.ProofSearchBenchmark`, so check
that module's status before assuming the repair is confined to two files.

### Option B — archive

Move both to `FormalSystem/Boneyard/` with a README recording what they measured and why they
were retired, following the `RetiredTactics/` precedent. Delete both manifest lines (C6 fails if
an entry names a module that no longer exists, so this is enforced). C11 then takes over,
asserting their imports still resolve or are waived.

**Before choosing B, measure the same thing `RetiredTactics/` measured**: whether anything
invokes these harnesses. The `#eval runAllDerivationBenchmarks` usage block in
`DerivationBenchmark.lean`'s docstring suggests they were meant to be run by hand, which is a
weaker claim on existence than a wired test.

## Recommendation

Get the real error count first (two `lake env lean` invocations, minutes). If it is small, repair
and re-manifest as compile-checked — the harnesses have documented value and B0/C6 then guard
them. If it is large, archive with a README. Do not leave them `broken:`.

## Verification

- `bash scripts/check-module-invariants.sh` passes, with zero `broken:` entries remaining in
  `scripts/module-invariants-manifest.txt` — that is the concrete success criterion either way.
- If repaired: `lake env lean` on each file exits 0, and C6 reports them among the compile-checked
  unreachable modules rather than skipping them.
- If archived: B0 still reports exactly 1 Boneyard directory; C11 resolves or waives every
  archived import; the archive README records the measurement.
- `lake build` and `lake test` unaffected.
