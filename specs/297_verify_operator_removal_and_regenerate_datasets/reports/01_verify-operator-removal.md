# Research Report: Verify Operator Removal and Regenerate Datasets

**Task**: 297
**Date**: 2026-06-08
**Session**: sess_1780972822_732c53

## Summary

The 6 removed binary temporal operators (`release`, `weak_until`, `trigger`, `weak_since`, `strong_release`, `strong_trigger`) are confirmed absent from `FormulaEnumerator.lean`'s 4 target functions. The pipeline modules build cleanly. Existing datasets (c4-c7) also contain zero occurrences of these operators. Enumeration count changes after removal are the primary unknown to verify.

---

## 1. Build Status

**Automation modules build cleanly.**

```
lake build Bimodal.Automation.FormulaEnumerator Bimodal.Automation.DatasetGenerator \
           Bimodal.Automation.DatasetExport Bimodal.Automation.EnumBenchmark
```
Result: `Build completed successfully (738 jobs)` with one unrelated deprecation warning (`String.trimLeft`).

**Full project build fails** at `CanonicalTaskRelation.lean:740` (heartbeat timeout in `simp`). This is a pre-existing issue unrelated to task 297 (confirmed in task 295 diagnostic report).

---

## 2. Operator Removal Verification

### FormulaEnumerator.lean — 4 Target Functions

Running `grep` for all 6 operators across the file returns **zero matches** in code. No references to `release`, `weak_until`, `trigger`, `weak_since`, `strong_release`, or `strong_trigger` appear anywhere in `FormulaEnumerator.lean`.

**What remains in `enumExactHelper`** (derived unary temporal operators, lines 199-264):
- `some_future` (F), `some_past` (P)
- `all_future` (G), `all_past` (H)
- `always`, `sometimes`
- `next`, `prev`
- `weak_future`, `weak_past`
- `diamond` (modal, not temporal)
- Binary: `imp`, `untl`, `snce` only (no derived binary)

**`sampleOne`** (LCG sampler, lines 376-481):
- `derivedUnarySlots := if hasDerived then 5 else 0` covering 5 derived unary pairs
- No binary derived operators in dispatch table

**`sampleOneRandom`** (IO sampler, lines 783-893):
- Same 10 choices (indices 0-10): `atom/bot, imp, box, diamond, untl, snce, F/P, G/H, always/sometimes, next/prev, weak_future/weak_past`
- No `release`, `weak_until`, `trigger`, `weak_since`, `strong_release`, `strong_trigger`

**`randomSubFormula`** (axiom seeder, lines 1005-1069):
- 9 branches (choice 0-8): `atom, imp, box, all_future, all_past, some_future, some_past, untl, snce`
- No binary derived operators

### Verdict: Removal is complete and consistent across all 4 functions.

---

## 3. Residual References in Other Files

### DatasetGenerator.lean
- Zero code references to the 6 removed operators (only `eviction triggers` in a comment at line 1203)

### DatasetExport.lean / DatasetExporter.lean
- Zero references to the 6 removed operators

### FormulaMutator.lean
- **Has references** to `release`, `weak_until`, `trigger`, `strong_release`, `strong_trigger` throughout (lines 84-786)
- These are mutation operators that SWAP between derived forms (e.g., `untl` <-> `release`)
- This is correct: `FormulaMutator` operates on existing formulas for contrastive pair generation — it does not enumerate new formulas
- Not a problem: the `contrastive_generator` executable uses `FormulaMutator` on formulas from the enumerator

### Formula.lean (Syntax)
- `release`, `weak_until`, `trigger`, `weak_since`, `strong_release`, `strong_trigger` are **defined as abbreviations** (lines 448-480) and have complexity `#eval` tests (lines 488-503)
- These definitions are fine to keep — they are domain API, not enumeration choices
- The enumerator simply no longer instantiates them

### Test Files
- `FormulaMutatorTest.lean`: Tests `trySwapUntilRelease`, `trySwapReleaseUntil`, etc. — correct (testing the mutator swaps)
- `FormulaPropertyTest.lean`: Tests complexity properties of derived operators — correct (unit tests for syntax layer)
- `NormalizationTest.lean`: Tests that `strong_release` and `strong_trigger` survive normalization — correct

### Summary: No unexpected residuals. All references outside FormulaEnumerator.lean are appropriate.

---

## 4. Benchmark / Verification Entry Points

### A. Enumeration Count Verification (`#eval` in FormulaEnumerator.lean)

```lean
-- Lines 1986-2001 — fast inline tests
#eval (enumExactHelper defaultAtoms 2 2 4 {}).1.size   -- c4 count
#eval (enumExactHelper defaultAtoms 2 2 5 {}).1.size   -- c5 count
#eval (generateBimodalSlice defaultAtoms 2 2 [5]).1.length
#eval (enumExactHelper defaultAtoms 2 2 2 {}).1.toList.any (· == Formula.diamond (.atom (Atom.mk_base "p")))
#eval (enumExactHelper defaultAtoms 2 2 2 {}).1.toList.any (· == Formula.next (.atom (Atom.mk_base "p")))
#eval (enumExactHelper defaultAtoms 2 2 2 {}).1.toList.any (· == Formula.prev (.atom (Atom.mk_base "p")))
```

To verify removal reduced counts, compare current `#eval` output against task 295 baseline:
- Task 295 baseline (raw enumeration, pre-dedup): c4=7,852, c5=75,914, c6=~170K, c7=1.25M

### B. Full Enumeration Benchmark (`lake exe enum_benchmark`)

Runs complexity 5, 6, 7 benchmarks with formula counts and timing gates:
```bash
lake exe enum_benchmark
```
Output format: `Formulas: N, Time: Xms, PASS/FAIL (<gate ms)`

Gates: c5 < 5000ms, c6 < 30000ms, c7 < 60000ms

### C. Dataset Regeneration (`lake exe dataset_generator`)

CLI for generating JSONL datasets:
```bash
# c4
lake exe dataset_generator -- --max-complexity 4 --output data/bmlogic-c4.jsonl

# c5
lake exe dataset_generator -- --max-complexity 5 --output data/bmlogic-c5.jsonl

# c6 (borderline feasible, ~15 min)
lake exe dataset_generator -- --max-complexity 6 --output data/bmlogic-c6.jsonl

# c7 (marginal, ~20-30 min, stratified preferred)
lake exe dataset_generator -- --max-complexity 7 --mode exhaustive --output data/bmlogic-c7.jsonl
```

Default: `--max-complexity 5`, `--mode exhaustive`, `--valid-seed-count 500`, `--include-duals` off.

---

## 5. Existing Dataset Baselines (Pre-Removal)

These are the current datasets to be regenerated:

| File | Records | Valid | Invalid | Timeout |
|------|---------|-------|---------|---------|
| `bmlogic-c4.jsonl` | 408 | 23 | 333 | 52 |
| `bmlogic-c5.jsonl` | 6,031 | 103 | 4,772 | 1,156 |
| `bmlogic-c6.jsonl` | 39,832 | 816 | 28,694 | 10,322 |
| `bmlogic-c7.jsonl` | 77,272 | 8,182 | 52,885 | 16,205 |

**Note**: Existing datasets already contain zero occurrences of the 6 removed operators (confirmed via grep). This is consistent with task 295's finding that `release`, `weak_until`, etc. contributed zero pipeline-surviving formulas even when they were enumerated — they were eliminated during canonicalization dedup.

**Expected behavior after regeneration**: Formula counts will **decrease** slightly (only the binary cross-product combinations are gone). The pipeline-surviving record counts may be identical or very close to the above baselines since these operators were already being eliminated by dedup.

---

## 6. Verification Strategy (Recommended Implementation Steps)

1. **Run `#eval` blocks** in FormulaEnumerator.lean to confirm current c4/c5 exact-complexity counts (fast, seconds)

2. **Run `lake exe enum_benchmark`** to get c5/c6/c7 counts and confirm timing gates still pass

3. **Check for removed operators in new enumeration**: Add or use existing `#eval` to verify:
   ```lean
   -- Should be false: no release(p, q) in c4
   #eval (enumExactHelper defaultAtoms 2 2 4 {}).1.toList.any (fun φ =>
     φ == Formula.release (.atom (Atom.mk_base "p")) (.atom (Atom.mk_base "q")))
   ```

4. **Regenerate c4 dataset** (fast, ~1 second) and compare record count

5. **Regenerate c5 dataset** (fast, ~11 seconds) and compare

6. **Regenerate c6 and c7** if required (slower, 15-30 min each)

---

## 7. Key Architecture Facts

- **Formula definitions are in `Syntax/Formula.lean`** — `release`, `weak_until` etc. are still defined there as abbreviations. This is correct; the enumerator simply stopped generating them.
- **`FormulaMutator.lean`** still references these operators for mutation-based contrastive pair generation. This is correct and does not need changing.
- **`randomSubFormula` in FormulaEnumerator.lean** uses 9 branches (no binary derived) — removal is clean.
- **The `sampleOne` LCG sampler** uses `derivedUnarySlots = 5` (10 operators in 5 pairs). This is correct for the remaining unary derived operators.
- **No new axiom additions were made** — this is a pure subtraction of derived binary operators from the enumerator dispatch tables.
