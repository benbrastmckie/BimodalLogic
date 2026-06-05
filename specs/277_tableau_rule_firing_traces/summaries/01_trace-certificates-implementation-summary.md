# Task 277: Tableau Rule Firing Traces — Implementation Summary

## Goal
Instrument the tableau decision procedure in `Theories/Bimodal/Metalogic/Decidability/`
with rule-firing trace certificates, exposed as a JSONL executable and a
library API. Threads `StateM ProofCertificate` through the existing
saturation loop without breaking the four existing termination/soundness
proofs in `Saturation.lean`.

## Status: All 8 Phases Completed

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Define trace certificate types | ✅ COMPLETED |
| 2 | Add deriving instances and `record` primitive | ✅ COMPLETED |
| 3 | Wrap `expandOnceWithApplied` and `expandBranchWithFuel` | ✅ COMPLETED |
| 4 | Instrument all 28 rule sites | ✅ COMPLETED |
| 5 | Add `decideWithTrace` to DecisionProcedure | ✅ COMPLETED |
| 6 | String-based JSON serialization | ✅ COMPLETED |
| 7 | `lake exe trace_exporter` CLI | ✅ COMPLETED |
| 8 | Test suite and e2e smoke test | ✅ COMPLETED |

## Files Created/Modified

### Created (4)
- `Theories/Bimodal/Metalogic/Decidability/TraceCertificate.lean` (303 lines)
  - `TraceEntry` (5 constructors: `ruleFired`, `branchCreated`, `branchClosed`, `blockingFired`, `fuelExhausted`)
  - `CertOutcome` (4 cases: `validProof`, `countermodel`, `timeout`, `blocked`)
  - `ProofCertificate` (with manual `Inhabited` instance)
  - `ProofCertificate.empty`
  - `TraceFailure` (3 cases)
  - `TraceResult` (sum type)
  - `ruleToString`, `entryDepth`, `updateFingerprint`
  - `TraceM` StateM monad and helpers

- `Theories/Bimodal/Metalogic/Decidability/TraceExport.lean` (217 lines)
  - String-based JSON serializers for all certificate types
  - `proofCertificateToJsonString`, `traceResultToJsonString`
  - Helper serializers for `TableauRule`, `Sign`, `FrameClass`, `CertOutcome`,
    `Label`, `SignedFormula`, `ClosureReason`, `TraceEntry`, fingerprint

- `Theories/Bimodal/Automation/TraceExporter.lean` (281 lines)
  - S-expression formula parser
  - CLI argument parser (`--fuel`, `--frame-class`)
  - Main loop: read formula per line, output JSONL certificate

- `Tests/BimodalTest/TraceCertificateTest.lean` (155 lines)
  - 9 unit tests for certificate types and `decideWithTrace`

- `Tests/BimodalTest/TraceExportTest.lean` (166 lines)
  - 13 round-trip tests for JSON serialization

- `Tests/BimodalTest/TraceExporterE2ETest.lean` (146 lines)
  - 6 end-to-end tests with semantic correctness checks

### Modified (3)
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean`
  - Added `BEq, Hashable` to `TableauRule`'s `deriving` clause (Phase 2)

- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean`
  - Added import of `TraceCertificate`
  - Added `expandOnceWithApplied_tracedImpl` (StateM wrapper)
  - Added `expandBranchWithFuel_tracedImpl` (StateM wrapper with `termination_by fuel`)
  - Added `expandBranchWithFuel_traced` (public API)
  - Original `expandBranchWithFuel` and all 4 proofs **preserved unchanged**

- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean`
  - Added import of `TraceCertificate`
  - Added `decideWithTrace` (returns `TraceResult`)
  - Added `decideAutoWithTrace` (adaptive fuel)
  - Added `finalizeCertificate` (post-process)
  - Added `computeBranchingFactor` (aggregation)

- `lakefile.lean`
  - Added `lean_exe trace_exporter` configuration

## Key Design Decisions

### 1. Strategy A: Parallel `_tracedImpl` Functions
Rather than refactoring `expandBranchWithFuel` (which would require re-proving
`termination_by fuel` and `expandBranchWithFuel_sound`), we added parallel
`expandOnceWithApplied_tracedImpl` and `expandBranchWithFuel_tracedImpl`
functions. These use the same recursion shape and `termination_by fuel`
measure, so the termination proof transfers directly.

**Result**: All 4 existing proofs continue to compile unmodified.
- `termination_by fuel` at the original `expandBranchWithFuel` (line 191)
- `termination_by fuel` at `saturateBlocked` (line 429) — line shifted by 150
- `tryBranch_inr` (line 953) — line shifted by 150
- `expandBranchWithFuel_sound` (line 1029) — line shifted by 150

### 2. Higher-Level Instrumentation (Phase 4)
The plan called for instrumenting each of the 28 `applyRule` arms directly.
Instead, we record `TraceEntry.ruleFired` at the `expandOnceWithApplied_tracedImpl`
level by inspecting `findApplicableRuleWithApplied`. This is **functionally
equivalent** — every `applyRule` call produces exactly one `record` event —
and avoids modifying `applyRule` (which is referenced in 2 places and
is the foundation of all tableau proofs).

All 28 rules are covered via the `RuleResult.linear / .branching / .persistent`
cases in the trace wrapper.

### 3. String-Based JSON Serialization
Used `String ++ String` concatenation rather than `ToJson` instances. Reasons:
- Simpler (no Mathlib `ToJson` machinery needed for the certificate types)
- No need to register new `ToJson` instances
- Easier to debug (raw strings)

The output is parseable by any standard JSON parser (verified with Python's
`json.loads`).

### 4. `findBlockedTime` Returns Single `TimeIndex`
The `findBlockedTime` function in `Saturation.lean` returns `Option TimeIndex`
(not a tuple of `(blockedTime, ancestorTime)`). For the `blockingFired`
event, we use the blocked time as a placeholder for both fields. This is
documented in the code.

## Test Results

### TraceCertificateTest.lean (9 tests)
```
PASS Test 1: empty cert has correct formula
PASS Test 2: empty cert serializes to valid JSON
PASS Test 3: tautology has outcome validProof
PASS Test 4: tautology trace has rule_fired events
PASS Test 5: tautology trace has branchClosed event
PASS Test 6: fingerprint is non-empty
PASS Test 7: low-fuel formula returned failure with non-empty trace
PASS Test 8: totalSteps equals trace length
PASS Test 9: all outcome types serialize correctly
```

### TraceExportTest.lean (13 tests)
```
PASS Test 1: empty certificate has 'formula' key
PASS Test 2: empty certificate has 'outcome' key
PASS Test 3: empty certificate has 'trace' key
PASS Test 4: empty certificate has 'axiom_fingerprint' key
PASS Test 5: frame class is 'Base'
PASS Test 6: decideWithTrace on tautology has 'outcome' key
PASS Test 6b: tautology trace contains 'rule_fired' events
PASS Test 7: TraceResult.success has 'status' key
PASS Test 7b: status is 'success'
PASS Test 8: TraceResult.failure has 'status' key
PASS Test 8b: failure_kind is 'out_of_fuel'
PASS Test 9: empty axiom_fingerprint renders as empty-object
PASS Test 10: empty trace renders as '[]'
```

### TraceExporterE2ETest.lean (6 tests)
```
PASS Test 1: p → p is valid
PASS Test 2: p → q is invalid (countermodel)
PASS Test 3: □p → □p is valid
PASS Test 4: JSON serialization of e2e result is well-formed
PASS Test 5: trace on □p → □p is non-empty
PASS Test 6: fingerprint contains expected modal/imp rules
```

**Total: 28/28 tests passing.**

## CLI Usage

```bash
# Build the executable
lake build trace_exporter

# Run on a single formula
echo "(imp (atom p) (atom p))" | lake exe trace_exporter

# Run with custom fuel
echo "(imp (atom p) (atom q))" | lake exe trace_exporter -- --fuel 1000

# Run with different frame class
echo "(box (imp (atom p) (atom p)))" | lake exe trace_exporter -- --frame-class Dense
```

## Example Output

```json
{
  "status": "success",
  "certificate": {
    "formula": {"tag": "imp", "left": {"tag": "atom", "name": "p"}, "right": {"tag": "atom", "name": "p"}},
    "formula_pretty": "(p → p)",
    "frame_class": "Base",
    "outcome": "valid_proof",
    "total_steps": 2,
    "max_depth": 0,
    "branching_factor": 1.000000,
    "elapsed_ms": 0,
    "axiom_fingerprint": {"impNeg": 1},
    "trace": [
      {
        "event": "rule_fired",
        "step": 0,
        "rule": "impNeg",
        "sign": "neg",
        "formula": {...},
        "label": {"world": 0, "time": 0},
        "produced": [...],
        "is_persistent": false,
        "branch_depth": 1
      },
      {
        "event": "branch_closed",
        "step": 1,
        "branch_id": 2,
        "reason": {"kind": "contradiction", ...}
      }
    ]
  }
}
```

## Verification Checklist

- [x] **No sorries** in any modified/created file (grep verified)
- [x] **No new axioms** introduced
- [x] **No vacuous definitions** (no `def X := True` patterns)
- [x] **All 4 existing proofs preserved** (`termination_by fuel` × 2, `tryBranch_inr`, `expandBranchWithFuel_sound`)
- [x] **Full `lake build` passes** (1686 jobs, no errors)
- [x] **All 28 tests pass** (9 unit + 13 round-trip + 6 e2e)
- [x] **Executable runs and emits valid JSONL** (verified with `python -m json.tool`)

## Notes for Future Work

1. **Formula parser**: The current S-expression parser handles a limited
   set of tags (`atom`, `bot`, `imp`, `box`, `untl`, `snce`). Adding more
   tags (like derived forms for `and`, `or`, `neg`, `diamond`, etc.) would
   require either more `(tag :: args :: ")" :: more)` cases or a more
   general parser.

2. **Frame class for blocking**: `findBlockedTime` returns a single
   `TimeIndex`, not a tuple. The `blockingFired` event uses the blocked
   time as a placeholder. If a future change makes `findBlockedTime`
   return a tuple, the `blockingFired` constructor can be updated.

3. **Elapsed time**: The current `decideWithTrace` sets `elapsedMs := 0`.
   An `IO` wrapper that calls `IO.monoMsNow` before/after could fill
   this in. (Out of scope for this task.)

4. **Test runner**: Tests are run via `lake build` (which executes
   `#eval` blocks at compile time). A dedicated `lake test` target
   is not currently set up for these tests, but the build failures
   effectively serve as test failures.
