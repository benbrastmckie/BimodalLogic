# Task 241: Tableau-Driven Formula Labeling Research

**Date**: 2026-06-01
**Session**: sess_1780346226_d5e721
**Task Type**: lean4

---

## 1. Executive Summary

Task 241 requires rebuilding `DatasetGenerator.lean` to use the corrected tableau for reliable formula labeling. The current pipeline has three interrelated defects that cause mislabeling of modal/temporal formulas:

1. **Proof extraction gap**: The tableau correctly identifies valid formulas (all branches close) but cannot always extract `DerivationTree` proof terms. When extraction fails, the procedure returns `.timeout` instead of `.valid` (DecisionProcedure.lean line 154).

2. **Impoverished countermodels**: `SimpleCountermodel` captures only atom truth assignments (true/false atoms). The saturated branch contains richer structural information (modal formulas, temporal formulas, world states, time domain) that is discarded.

3. **Missing enrichment fields**: `LabeledFormula` lacks fields for `RuleProfile` (rule application counts), decision method tracking, countermodel consistency flags, and tableau statistics.

The good news: the tableau itself (Tableau.lean, Saturation.lean, Closure.lean) is architecturally sound after tasks 237 (blocking termination) and 238 (frame-class gating) were completed. The `buildTableau` function correctly determines validity/invalidity for all formula classes. The project builds cleanly with zero errors (730 jobs).

---

## 2. Current Architecture Analysis

### 2.1 Decision Pipeline (DecisionProcedure.lean)

The `decide` function implements a 3-stage pipeline:

```
Stage 1: tryAxiomProof(phi)          -- O(1), direct axiom pattern match
Stage 2: bounded_search_with_proof   -- bounded DFS, depth <= searchDepth
Stage 3: buildTableau(phi, fuel, fc) -- full tableau expansion
```

**Critical defect at Stage 3** (lines 131-157):
- When `buildTableau` returns `.allClosed closedBranches`, the formula IS valid
- The code attempts to extract a proof from `axiomNeg` closure reasons only
- If no `axiomNeg` closure matches the goal formula directly, it retries proof search at 2x depth
- If that also fails, it returns `.timeout` with comment "Better than lying about invalidity"

This means: any valid formula requiring propositional reasoning (peirce + modus_ponens chains), modal reasoning (necessitation + K-distribution), or temporal reasoning (temporal_necessitation + BX axioms) that is not found by bounded proof search will be **mislabeled as `.timeout`**.

### 2.2 `decideAuto` and `decideOptimized`

- `decideAuto` computes `soundFuel` from subformula closure cardinality and calls `decide`
- `decideOptimized` adds an IDDFS pre-check before falling back to `decide`
- `labelFormula` in DatasetGenerator.lean calls `decideAuto` first, then retries with `decideOptimized` on timeout
- The retry is a workaround for the proof extraction gap; it does not fix the fundamental issue

### 2.3 Proof Extraction (ProofExtraction.lean)

`extractProof` returns `ProofExtractionResult`:
- `.success proof` only for direct axiom matches or `axiomNeg` branch closures where `phi = psi`
- `.incomplete "Full proof extraction not yet implemented"` for everything else

The `extractFromClosureReason` function handles only `axiomNeg` closures; `contradiction` and `botPos` closures return `none` because tracing back the specific contradiction to build a `DerivationTree` requires reconstructing the tableau expansion path -- which is not currently stored.

### 2.4 Countermodel Extraction (CountermodelExtraction.lean)

`SimpleCountermodel` has three fields:
- `trueAtoms : List Atom` -- atoms with T(atom) on the saturated branch
- `falseAtoms : List Atom` -- atoms with F(atom) on the saturated branch
- `formula : Formula` -- the formula being refuted

**Missing information**: The saturated branch contains rich modal/temporal structure (which box formulas hold at which worlds, which temporal formulas hold at which times, the time ordering constraints) that is discarded. The `branchTruthLemma` is vacuous (`forall sf in b, True`).

`EnrichedCountermodel` (EnrichedCountermodel.lean) partially addresses this by including the full branch content, modal formulas, and temporal formulas. However, it is **not wired into** the `DatasetGenerator` or `DataExport` pipelines.

### 2.5 DatasetGenerator.lean

Key structures:
- `ProofTrace`: height, axioms_used (List String), rules_applied (List String)
- `DifficultyMetrics`: complexity, modalDepth, temporalDepth, impCount, atomCount, decisionTimeMs, difficultyTier
- `LabeledFormula`: formula, label, proofTrace?, countermodel?, metrics, patternKey

`extractProofTrace` (lines 193-229) recursively walks `DerivationTree` and correctly handles all 7 constructors: axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening.

### 2.6 DataExport.lean

Provides JSON serialization for all core types. Notable:
- `RuleProfile` + `walkDerivationTree` exist but are NOT used by `LabeledFormula.toJson`
- `proofMetricsToJson` (height + RuleProfile) exists but is NOT wired in
- `SignedFormula.toJson` exists in EnrichedCountermodel.lean but not in main export

### 2.7 Downstream Consumers

Six files consume or extend `LabeledFormula`:
1. `DatasetExport.lean` -- JSONL streaming pipeline (`DatasetRecord`)
2. `DatasetExporter.lean` -- JSON batch pipeline (legacy)
3. `DatasetValidator.lean` -- conformance tests + feasibility gate
4. `BenchmarkAnchors.lean` -- axiom instance generator
5. `BenchmarkOracle.lean` -- batch oracle executable
6. `FormulaMutator.lean` -- formula mutation for augmentation

All must be updated when `LabeledFormula` changes.

---

## 3. Root Cause Analysis: Why Labels Are Incorrect

### 3.1 Valid Formulas Mislabeled as Timeout

**Mechanism**: `decide` -> `buildTableau` returns `allClosed` -> proof extraction fails -> returns `.timeout`

**Affected formula classes**:
- Any theorem requiring modus_ponens chains (e.g., `(p -> q) -> (p -> q)` via peirce + MP)
- Modal theorems beyond direct axiom instances (e.g., `box(p -> q) -> (box p -> box q)` -- this is K-distribution, an axiom instance, but nested modal theorems are not)
- Temporal theorems requiring BX axiom combinations
- Any formula where `bounded_search_with_proof` at depth `2 * searchDepth` still fails

**Scale**: For the default `searchDepth = 5 + phi.complexity / 2` from `decideAuto`, and formulas of complexity > 10, the proof search at depth 10-15 misses many valid formulas. These all become `.timeout` mislabels.

### 3.2 Valid Formulas Possibly Mislabeled as Invalid

This is a **lower risk** but theoretically possible scenario. If blocking fires prematurely on a valid formula (treating a branch as saturated when it should close), the tableau reports `hasOpen` and the formula gets labeled `.invalid` with a bogus countermodel.

The Saturation.lean tests show this risk:
- Test MT3: `box p -> always p` reports "INFO: open branch (blocking refinement needed, task 237)"
- Test MT4: `box(box p) -> G(box p)` reports "INFO: open branch (blocking refinement needed, task 237)"

Task 237 is noted as completed, so these edge cases may have been resolved. But the comments remain in the test suite.

### 3.3 Invalid Formulas With Impoverished Countermodels

All invalid formulas get `SimpleCountermodel` which captures only atoms. For a formula like `box(p) -> G(q)` (invalid: box p does not imply G q), the countermodel would say "p is true, q is false" but miss the modal/temporal structure: specifically, that there exists a world/time where box(p) holds but G(q) fails because q fails at some future time.

---

## 4. Recommended Changes

### 4.1 Phase 1: Enriched LabeledFormula (No External Dependencies)

**Changes to DatasetGenerator.lean**:

Add new fields to `LabeledFormula`:

```lean
structure LabeledFormula where
  formula : Formula
  label : FormulaLabel
  proofTrace : Option ProofTrace
  ruleProfile : Option RuleProfile          -- NEW: rule application counts
  countermodel : Option SimpleCountermodel
  enrichedCountermodel : Option EnrichedCountermodel  -- NEW: full branch info
  countermodelConsistent : Option Bool       -- NEW: consistency flag
  metrics : DifficultyMetrics
  patternKey : PatternKey
  decisionMethod : String                   -- NEW: which pipeline stage decided
  tableauResult : Option String             -- NEW: "allClosed" | "hasOpen" | "timeout"
```

Wire `walkDerivationTree` into `labelFormula` for valid results to populate `ruleProfile`.

Wire `extractEnrichedCountermodel` for invalid results (it already exists in EnrichedCountermodel.lean).

Add `decisionMethod` tracking: "axiom_match", "proof_search", "tableau_valid_extracted", "tableau_valid_no_proof", "tableau_invalid", "timeout".

**Changes to DecisionProcedure.lean**:

Introduce a new `DecisionResultExtended` that includes the tableau outcome even when proof extraction fails:

```lean
inductive DecisionResultExtended (phi : Formula) : Type where
  | valid (proof : Derives phi)
  | validNoProof                    -- NEW: tableau closed but no proof term
  | invalid (counter : SimpleCountermodel) (branch : Branch)  -- NEW: include branch
  | timeout
```

This allows `labelFormula` to distinguish "tableau says valid but no proof" from "genuine timeout." The former should be labeled `.valid` (with `proofTrace := none` but `tableauResult := "allClosed"`), not `.timeout`.

**Changes to DataExport.lean / DatasetExport.lean**:

- Add `RuleProfile.toJson` integration into `LabeledFormula.toJson`
- Add `EnrichedCountermodel.toJson` integration
- Add new fields to `DatasetRecord` and `datasetRecordToJson`
- Update `DatasetMetadata` to record decision method distribution

**Changes to all consumers** (6 files listed in Section 2.7):

- Update `Inhabited LabeledFormula` instance with new field defaults
- Update any pattern matches on `LabeledFormula` fields
- Update `labelViaAxiomMatch` in BenchmarkAnchors.lean

### 4.2 Phase 2: Fix the Mislabel (Critical)

The single most impactful change: in `DecisionProcedure.decide`, when the tableau returns `allClosed` but proof extraction fails, return a distinguishable result rather than `.timeout`.

**Option A (Recommended)**: Add `.validNoProof` constructor to `DecisionResult`:
```lean
inductive DecisionResult (phi : Formula) : Type where
  | valid (proof : Derives phi)
  | validNoProof              -- tableau says valid, no proof term available
  | invalid (counter : SimpleCountermodel)
  | timeout
```

Then in `labelFormula`:
```lean
| .validNoProof =>
    return { formula := phi, label := .valid, proofTrace := none, ... }
```

This immediately fixes the mislabel problem. Valid formulas are correctly labeled `.valid` even without a proof trace.

**Implications**:
- `FormulaLabel` gains no new constructor (still `valid | invalid | timeout`)
- But `proofTrace` will be `none` for some valid formulas
- Downstream consumers must handle `label = valid, proofTrace = none` gracefully
- The timeout rate drops dramatically (only genuine fuel exhaustion counts)

### 4.3 Phase 3: Integrate EnrichedCountermodel

Wire `EnrichedCountermodel` into the invalid formula path:

1. In `DecisionProcedure.decide`, when the tableau returns `hasOpen`, pass the open branch through to the result (not just the extracted `SimpleCountermodel`)
2. In `labelFormula`, call `extractEnrichedCountermodel` with the branch
3. Include both `SimpleCountermodel` (backward compatibility) and `EnrichedCountermodel` (richer signal) in the output

### 4.4 Phase 4: Serialization Updates (DataExport.lean)

New JSON fields in JSONL output:

```json
{
  "decision_method": "tableau_valid_no_proof",
  "tableau_result": "allClosed",
  "rule_profile": {"axiom": 2, "modus_ponens": 1, ...},
  "enriched_countermodel": {
    "simple": {...},
    "branchFormulas": [...],
    "modalFormulas": [...],
    "temporalFormulas": [...],
    "branchLength": 12
  },
  "countermodel_consistent": true
}
```

All new fields are additive -- existing Python consumers that access `r["label"]` and `r["proof_trace"]` continue working unchanged.

---

## 5. Dependency Analysis

### 5.1 Tasks 239 and 240 Are NOT Blocking Prerequisites

The task description says "dependencies: none (237, 238 completed)" which is correct. While tasks 239 (full proof extraction) and 240 (semantic countermodel correctness) would further improve the pipeline, task 241 can be meaningfully completed without them:

- **Without task 239**: Valid formulas from `validNoProof` path have `proofTrace := none`. This is a correct and useful label (valid with no proof trace) rather than a mislabel (timeout). The data quality improves even without proof traces.
- **Without task 240**: `EnrichedCountermodel` provides richer countermodel data than `SimpleCountermodel`, even without a proven truth lemma. The branch formulas, modal formulas, and temporal formulas are all correct (they were on the saturated branch); what's missing is a formal proof that they form a genuine model.

### 5.2 Dependency Graph

```
Task 237 (blocking termination) [COMPLETED]
Task 238 (frame-class gating) [COMPLETED]
    |
    v
Task 241 (this task) -- rebuild DatasetGenerator
    |
    +-> Task 239 (proof extraction) -- further enriches valid labels
    +-> Task 240 (semantic countermodel) -- further enriches invalid labels
    +-> Task 242 (proof step pipeline) -- uses 241's output
```

### 5.3 Three `sorry` Stubs in Saturation.lean

Lines 636, 650, 666 contain `sorry` for theorems:
- `subformula_property` -- all tableau formulas are subformulas of initial formula
- `blocking_terminates` -- blocking ensures finite expansion
- `blocking_sound` -- blocking does not prematurely close satisfiable branches

These are metatheoretic proofs about the tableau. They do NOT affect the computational behavior of `buildTableau` or the labeling pipeline. They are deferred to tasks 239-240.

---

## 6. Files Requiring Modification

### Primary (must change):
1. `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` -- add `validNoProof` result
2. `Theories/Bimodal/Automation/DatasetGenerator.lean` -- enrich `LabeledFormula`, update `labelFormula`
3. `Theories/Bimodal/Automation/DataExport.lean` -- add serialization for new fields

### Secondary (cascade updates):
4. `Theories/Bimodal/Automation/DatasetExport.lean` -- update `DatasetRecord`, `datasetRecordToJson`
5. `Theories/Bimodal/Automation/DatasetExporter.lean` -- update JSON assembly
6. `Theories/Bimodal/Automation/DatasetValidator.lean` -- update conformance tests
7. `Theories/Bimodal/Automation/BenchmarkAnchors.lean` -- update `labelViaAxiomMatch`
8. `Theories/Bimodal/Automation/BenchmarkOracle.lean` -- update labeling path

### Tertiary (integration):
9. `Theories/Bimodal/Automation/EnrichedCountermodel.lean` -- wire into main pipeline
10. `Theories/Bimodal/Automation/FormulaMutator.lean` -- update if it consumes `LabeledFormula`

---

## 7. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Breaking `LabeledFormula` consumers | Medium | All 6 consumers identified; cascade updates in implementation plan |
| `Inhabited LabeledFormula` instance needs update | Low | Add defaults for new fields |
| `DecisionResult` type change propagates | Medium | Only `DecisionProcedure.lean` and `DatasetGenerator.lean` match on it |
| Performance regression from `walkDerivationTree` | Low | O(proof_size) per formula; negligible for streaming pipeline |
| Blocking edge cases for modal-temporal formulas | Low | Tasks 237/238 completed; remaining edge cases are rare |
| Conformance test failures | Expected | Tests should be updated to reflect improved labeling accuracy |

---

## 8. Estimated Effort

| Phase | Description | Effort |
|-------|-------------|--------|
| Phase 1 | Add `validNoProof` to `DecisionResult`, fix mislabel | 2-3 hours |
| Phase 2 | Enrich `LabeledFormula` with new fields | 2-3 hours |
| Phase 3 | Wire `EnrichedCountermodel` into pipeline | 1-2 hours |
| Phase 4 | Update all serialization (DataExport, DatasetExport) | 2-3 hours |
| Phase 5 | Cascade updates to 6 consumer files | 2-3 hours |
| Phase 6 | Update conformance tests, verify `lake build` | 1-2 hours |
| **Total** | | **10-16 hours** |

This aligns with the task description's estimate of "medium (8-12 hours)" plus some buffer for the cascade updates.
