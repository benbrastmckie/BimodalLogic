# Research Report: Dataset Quality and Stall Diagnosis

- **Task**: 261 - Dataset Quality and Stall Diagnosis
- **Started**: 2026-06-02T12:00:00Z
- **Completed**: 2026-06-02T12:30:00Z
- **Effort**: medium (8-12 hours)
- **Dependencies**: Task 253
- **Sources/Inputs**: Saturation.lean, DatasetExport.lean, bmlogic-c9.jsonl, bmlogic-c7.jsonl
- **Artifacts**: specs/261_dataset_quality_and_stall_diagnosis/reports/01_dataset-quality-stall.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

The c9 generation run produced 5,671 of ~1.6M formulas before stalling indefinitely. Three root causes were identified:

1. **Persistent rule loop** (Saturation.lean lines 745-765): The `boxPos` persistent rule interacts with consumable rules (`impPos`, `negPos`) to create infinite cycles that exhaust fuel. This accounts for **94.9% of all timeouts** (617/649) and all ~201 provably-valid formulas mislabeled as timeout.

2. **Exponential branching in `expandBranchWithFuel`** (Saturation.lean line 173): When a branching rule fires, each sub-branch receives the **full remaining fuel** value, not a fraction. This creates O(2^fuel) worst-case work. With `soundFuel` capped at 100,000, certain formulas trigger effectively infinite computation. This is the **direct cause of the 2+ hour stall**.

3. **Missing JSONL fields**: The c9 dataset is missing 6 fields (`decision_method`, `proof_reconstruction_method`, `rule_profile`, `countermodel_consistent`, `enriched_countermodel`, `semantic_countermodel`) because the binary was built before task 241 added those fields to `LabeledFormula` and `DatasetExport.lean`.

---

## 1. Stall Root Cause Analysis

### 1.1 The Stalling Formula

The process completed record #5671 (`(box(bot -> bot) -> q)`, complexity 6, timeout) and began writing record #5672 (`(box(bot -> bot) -> r)`, complexity 6). The JSONL line for #5672 was truncated mid-write, indicating the process was interrupted (likely killed after 2+ hours of 100% CPU on the next formula, #5673).

### 1.2 Exponential Branching Bug

The core stall mechanism is in `expandBranchWithFuel` (Saturation.lean):

```lean
| (.split branches, newOrd) =>
    let tryBranch := fun acc newBranch =>
      match acc with
      | some (.inr openBr) => some (.inr openBr)
      | _ =>
          match expandBranchWithFuel newBranch fuel newOrd fc tracker with
          ...
    branches.foldl tryBranch ...
```

Each sub-branch in a split receives the **same `fuel` value** as the parent. For formulas that repeatedly branch (e.g., nested box-implication combinations), the work grows exponentially:
- 1 split with 2 branches: 2 sub-problems, each with full fuel
- Each sub-problem splits again: 4 sub-problems
- After k splits: 2^k sub-problems, each with full fuel

For formulas with `soundFuel = 100000` and repeated branching, this creates billions of tableau states. The process consumes 100% CPU and never completes.

### 1.3 Persistent Rule Loop (Known Bug)

Documented in Saturation.lean lines 745-765. The mechanism:

1. `T(box(psi))` is on the branch (persistent -- not consumed)
2. `boxPos` propagates `T(psi)` to all known worlds
3. If `psi` is reducible (e.g., `psi = bot -> bot`, an implication), a consumable rule like `impPos` removes `T(psi)` and branches
4. `boxPos` no longer sees `T(psi)` on the branch, so it re-fires, adding `T(psi)` again
5. Repeat until fuel exhaustion

**Affected formula patterns**: Any formula containing `T(box(psi))` where `psi` is a compound formula:
- `box(bot -> X)`: 95 timeout instances (provably valid, should be fast)
- `box(X -> X)`: provably valid, should be axiom match
- `(box(bot) -> X)`: provably valid (ex falso from box(bot))
- `box(X -> Y)` where X, Y are compound

**Counterexample from source**: `diamond(p)` (i.e., `(box(p -> bot)) -> bot`) fails with `soundFuel = 160`.

### 1.4 Until/Since Timeout Pattern

32 non-box timeouts follow the pattern `U(bot, X) -> Y` or `S(bot, X) -> Y`:
- `U(bot, guard)` means "there exists a future time where bot holds, with guard holding until then" -- unsatisfiable since bot never holds
- So `U(bot, X) -> Y` is vacuously valid
- The `untlPos` rule keeps branching: event-witness (bot at fresh time) vs guard-continue
- The guard-continue branch re-introduces `T(U(bot, X))` at a fresh time, creating an infinite chain
- Subset blocking should eventually fire, but for small `soundFuel` values (160), fuel runs out first

---

## 2. Timeout vs. Valid Mislabeling Analysis

### 2.1 Scale

- **Total timeouts in c9**: 649 (11.4% of 5,671 records)
- **Provably valid formulas mislabeled as timeout**: ~201 (31% of timeouts)
- **Timeout by complexity**: c4: 19, c5: 91, c6: 539
- **Timeout by pattern**: 617 contain box (95%), 32 are `U(bot,X)`/`S(bot,X)` (5%)

### 2.2 Comparison with c7

| Metric | c7 (complete) | c9 (partial) |
|--------|---------------|--------------|
| Total records | 49,904 | 5,671 |
| Valid | 1,687 (3.4%) | 208 (3.7%) |
| Invalid | 46,717 (93.6%) | 4,814 (84.9%) |
| Timeout | 1,500 (3.0%) | 649 (11.4%) |
| Max decision time | 1ms | 0ms |

The timeout rate nearly quadrupled from c7 to c9, because at higher complexity levels:
1. More formulas contain nested box patterns that trigger the persistent rule loop
2. `soundFuel` is larger, so the exponential branching takes longer per formula

### 2.3 Why All Decision Times Are 0ms

Every timeout formula has `decisionTimeMs: 0`. This is because:
- The `IO.monoMsNow` granularity is 1ms
- Fuel exhaustion (the persistent rule loop) completes in sub-millisecond time for small `soundFuel` values (160-384)
- The actual stall is not measured because it occurs during a single `decideAuto` call that never returns

---

## 3. Null Metrics Fields Analysis

### 3.1 Missing Fields

Six fields are absent from ALL c9 (and c7) records:

| Field | Expected For | Status |
|-------|-------------|--------|
| `decision_method` | all records | Missing |
| `proof_reconstruction_method` | valid records | Missing |
| `rule_profile` | valid records | Missing |
| `countermodel_consistent` | invalid records | Missing |
| `enriched_countermodel` | invalid records | Missing |
| `semantic_countermodel` | invalid records | Missing |

### 3.2 Root Cause

These fields were added in **task 241 phase 1** (commit `d1b45852c`, 2026-06-01 13:50). The c7 dataset was generated on 2026-05-29 (before the enrichment). The c9 dataset was generated on 2026-06-01 22:01, but the `dataset_generator` binary was likely not rebuilt after the task 241 changes.

The code paths are correctly implemented in the current `DatasetExport.lean`:
- `labeledToRecord` maps all 6 fields from `LabeledFormula` (lines 285-309)
- `datasetRecordToJson` serializes all 6 fields (lines 232-280)

### 3.3 Fix

Rebuild the binary (`lake build dataset_generator`) and re-run the generation. The fields will appear in the output. No code change is needed -- the existing code already includes these fields.

---

## 4. Frame Class Coverage Gap

### 4.1 Current State

The `DatasetExport.lean` hardcodes `frame_class: "Base"` throughout (lines 168, 210, 262, 292, 433). There is no CLI flag `--frame-class` to select Dense or Discrete.

The `labelFormula` function calls `decideAuto` which defaults to `FrameClass.Base`:
```lean
def decideAuto (phi : Formula) (fc : FrameClass := .Base) : DecisionResult phi :=
```

### 4.2 Impact

Dense and Discrete never ran because:
1. No CLI mechanism to select frame class
2. The default is hardcoded to Base
3. The run script (`run_dataset_generation.sh`) does not pass frame class

### 4.3 Recommendation

Add a `--frame-class` CLI flag to `DatasetExport.lean` that selects from `{Base, Dense, Discrete}`. Modify the generation loop to run all three frame classes per formula (producing 3x records) or to accept the frame class as a parameter. This would produce datasets like `bmlogic-c9-dense.jsonl` and `bmlogic-c9-discrete.jsonl`.

---

## 5. Enumeration Coverage Gap

### 5.1 Complexity Levels Reached

| Complexity | Records | % of Total |
|-----------|---------|------------|
| 3 | 36 | 0.6% |
| 4 | 144 | 2.5% |
| 5 | 1,312 | 23.1% |
| 6 | 4,179 | 73.7% |
| 7-9 | 0 | 0% |

The c9 run reached only complexity 6 before stalling. Complexity 7-9 was never started. Given that the total enumerated formula count for c9 is ~1.6M, the vast majority of formulas are at complexity 7-9.

### 5.2 Stalling Point

The stall occurred during labeling at complexity 6 (record #5672). The process enumerates in increasing complexity order, so complexity 7+ formulas had already been enumerated but not yet labeled.

---

## 6. Proposed Fixes (Priority Order)

### Fix 1: Per-Formula Wall-Clock Watchdog (CRITICAL -- Addresses Stall)

Add a per-formula time limit to `labelFormula`. Three approaches:

**(a) Adaptive fuel (simplest, no concurrency)** -- RECOMMENDED:
```lean
def decideAutoAdaptive (phi : Formula) (fc : FrameClass := .Base) : DecisionResult phi :=
  let fuels := [500, 2000, 10000]
  fuels.findSome? (fun fuel =>
    let depth := 5 + phi.complexity / 2
    match decide phi depth fuel fc with
    | .timeout => none
    | result => some result
  ) |>.getD .timeout
```
This ensures no formula uses more than 10,000 fuel, which typically completes in seconds.

**(b) IO.asTask with polling**:
```lean
def labelFormulaWithTimeout (phi : Formula) (timeoutMs : Nat := 5000) : IO LabeledFormula := do
  let task <- IO.asTask (labelFormula phi)
  let startTime <- IO.monoMsNow
  let rec poll : IO LabeledFormula := do
    match (<- IO.checkTask task) with
    | some result => return result
    | none =>
      let now <- IO.monoMsNow
      if now - startTime > timeoutMs then
        IO.cancelTask task
        return mkTimeoutResult phi (now - startTime)
      IO.sleep 10
      poll
  poll
```

**(c) Shell-level timeout per chunk**: Run batches of 1000 formulas as subprocesses with `timeout 300s`.

### Fix 2: Fix the Persistent Rule Loop (CRITICAL -- Addresses 95% of Timeouts)

Add an "already-applied" tracking set to `expandBranchWithFuel`:

```lean
structure ExpansionState where
  appliedPersistent : Std.HashSet (TableauRule x SignedFormula)
  tracker : EventualityTracker
```

Before applying a persistent rule, check if `(rule, sf)` is in `appliedPersistent`. If yes, skip. If no, apply and add to set.

Three documented approaches (Saturation.lean line 754):
- **(a) Track already-expanded instances** (recommended, simplest)
- **(b) Check for expanded descendants** in boxPos
- **(c) Make persistent outputs immune to consumption**

### Fix 3: Cap Branching Work (CRITICAL -- Addresses Stall)

Divide fuel among branches in the split case:
```lean
| (.split branches, newOrd) =>
    let branchFuel := fuel / branches.length.max 1
```

Or use a global step counter passed as a mutable reference.

### Fix 4: Fast Path for Box-Valid Formulas (MEDIUM -- Reduces Timeout Rate)

Extend `tryAxiomProof` with patterns:
- `box(inner)` where inner is provable -> necessitation
- `(box(bot) -> X)` -> vacuous implication
- `box(X -> X)` -> necessitation of identity

### Fix 5: Incremental Output Flush (LOW)

Add `handle.flush` after each `writeRecordJSONL` call.

### Fix 6: Rebuild Binary (TRIVIAL)

`lake build dataset_generator` -- resolves all 6 missing fields.

### Fix 7: Frame Class CLI Flag (LOW -- Feature Addition)

Add `--frame-class {Base,Dense,Discrete}` to CLI and thread through `labelFormula`.

---

## 7. Strategy for Feasible c9/c11 Generation

### Phase 1: Quick Wins (1-2 days)
1. Rebuild binary (Fix 6)
2. Add adaptive fuel with 10K cap (Fix 1a)
3. Add explicit flush after each record (Fix 5)
4. Re-run c9 generation

**Expected result**: c9 completes in 2-4 hours with ~15% timeout rate (persistent rule loop formulas). All timeouts are recorded, pipeline never stalls.

### Phase 2: Algorithmic Fixes (3-5 days)
1. Fix persistent rule loop (Fix 2a)
2. Cap branching work (Fix 3)
3. Re-run c9 generation

**Expected result**: Timeout rate drops to <5%. c9 completes in 1-2 hours.

### Phase 3: Full Coverage (5-7 days)
1. Add box fast path (Fix 4)
2. Add frame class CLI flag (Fix 7)
3. Generate c9-dense and c9-discrete datasets
4. Generate c11 with stratified sampling

**Expected result**: Complete coverage across all frame classes and complexities.

---

## 8. Key Files

| File | Role |
|------|------|
| `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` | Tableau expansion, blocking, `expandBranchWithFuel`, `buildTableau` |
| `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` | Tableau rules including persistent `boxPos` |
| `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` | `decideAuto`, `soundFuel` |
| `Theories/Bimodal/Metalogic/Decidability/Closure.lean` | Branch closure detection |
| `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` | Blocking detection (`findBlockedTime`) |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | `labelFormula` (no per-formula timeout) |
| `Theories/Bimodal/Automation/DatasetExport.lean` | CLI, JSONL streaming, `main` |
| `scripts/run_dataset_generation.sh` | Shell runner (no frame class flag) |
| `data/bmlogic-c9.jsonl` | Partial c9 output (5,671 of ~1.6M records) |
| `data/bmlogic-c7.jsonl` | Complete c7 output (49,904 records, 3% timeout) |
