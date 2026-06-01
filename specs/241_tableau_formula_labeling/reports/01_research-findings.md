# Task 241: Rebuild DatasetGenerator for Correct Tableau Integration

## Research Findings

**Date**: 2026-06-01
**Session**: sess_1780346173_ad4948

---

## 1. Current Architecture

### 1.1 DatasetGenerator.lean

**Location**: `Theories/Bimodal/Automation/DatasetGenerator.lean`
**Imports**: `DecisionProcedure`, `SuccessPatterns`, `FormulaEnumerator`, `DataExport`

The labeling pipeline works as follows:

1. `labelFormula : Formula -> IO LabeledFormula` calls `decideAuto phi` (the main entry point).
2. `decideAuto` computes `soundFuel` from the subformula closure and calls `decide phi depth fuel fc`.
3. On timeout, there is a retry with `decideOptimized` (IDDFS first, then full tableau).
4. Results are classified into `FormulaLabel.valid | .invalid | .timeout`.

**Key structures**:
- `ProofTrace`: height, axioms_used (List String), rules_applied (List String)
- `DifficultyMetrics`: complexity, modalDepth, temporalDepth, impCount, atomCount, decisionTimeMs, difficultyTier
- `LabeledFormula`: formula, label, proofTrace (Option), countermodel (Option SimpleCountermodel), metrics, patternKey

`extractProofTrace` recursively walks a `DerivationTree` to collect proof height, axiom names, and rule names. It covers all 7 `DerivationTree` constructors (axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening).

### 1.2 DataExport.lean

**Location**: `Theories/Bimodal/Automation/DataExport.lean`
**Imports**: `Syntax`, `SuccessPatterns`, `CountermodelExtraction`, `Derivation`

Provides JSON serialization for all core types:
- `Formula.toJson`, `Formula.prettyPrint`, `Formula.toSExpr`, `Formula.tokenize`
- `Atom.toJson`
- `PatternKey.toJson`, `PatternKey.featureVectorToJson`
- `GoalCategory.toJson`, `GoalCategory.toNat`
- `SimpleCountermodel.toJson` (trueAtoms, falseAtoms, formula)
- `RuleProfile` + `walkDerivationTree` (axiom/assumption/mp/necessitation/temporal_nec/temporal_dual/weakening counts)
- `proofMetricsToJson` (height + rules)
- Utility: `escapeJsonString`, `listToJsonArray`, `tokenListToJson`

### 1.3 DatasetExport.lean (JSONL pipeline)

**Location**: `Theories/Bimodal/Automation/DatasetExport.lean`

The JSONL streaming pipeline for `lake exe dataset_generator`. Key additions beyond DataExport:
- `DatasetRecord`: Full export record with id, split, formula representations (str/ast/sexpr/tokens/features), label, proof_trace, countermodel, pattern_key, metrics, augmentation info, modal/temporal depths.
- `datasetRecordToJson`: Serializes a complete JSONL line.
- `labeledToRecord`: Converts `LabeledFormula` to `DatasetRecord` with ID and split.
- `assignSplit`: Deterministic hash-based 80/10/10 train/val/test split.
- `writeDatasetJSONL`: Streaming write pipeline.
- `main`: CLI with argument parsing for the compiled executable.

### 1.4 DatasetExporter.lean (JSON pipeline, legacy)

**Location**: `Theories/Bimodal/Automation/DatasetExporter.lean`

Older JSON (not JSONL) pipeline using `EnumConfig`-based API:
- `generateAndExportDataset`: enumerate -> label -> metadata -> export JSON -> write
- `generateSplitDatasets`: enumerate -> label -> stratified split -> export both
- Uses `enumerateUpToDepth` from FormulaEnumerator.

### 1.5 DatasetValidator.lean

**Location**: `Theories/Bimodal/Automation/DatasetValidator.lean`

Conformance testing and feasibility gate:
- 10 known valid formulas (axiom instances)
- 20 known invalid formulas
- `runConformanceTests`: checks labeling correctness against known formulas
- `computeDiversityReport`: operator distribution, depth histograms, proof height stats
- `evaluateGate`: pass/fail criteria (provability ratio 15-70%, height variance > 2.0, category diversity)

### 1.6 EnrichedCountermodel.lean

**Location**: `Theories/Bimodal/Automation/EnrichedCountermodel.lean`

Extends `SimpleCountermodel` with full branch information:
- `EnrichedCountermodel`: simple (SimpleCountermodel), branchFormulas (List SignedFormula), modalFormulas, temporalFormulas, branchLength
- `extractEnrichedCountermodel`: builds from formula + saturated branch
- `SignedFormula.toJson` and `EnrichedCountermodel.toJson` for serialization

---

## 2. How the Tableau is Currently Used for Labeling

### 2.1 Decision Procedure Pipeline

`DecisionProcedure.decide` implements a 3-stage approach:

1. **Fast path**: `tryAxiomProof phi` -- direct axiom matching via `matchAxiom`.
2. **Proof search**: `bounded_search_with_proof [] phi searchDepth` -- bounded DFS.
3. **Tableau fallback**: `buildTableau phi tableauFuel fc` then analyze result.

When the tableau returns `allClosed`:
- Attempt direct axiom proof from closed branch reasons (`axiomNeg` closure).
- If that fails, retry proof search at 2x depth.
- If that also fails: **return `.timeout`** -- the formula is known valid but no proof term can be extracted. This is the critical gap.

When the tableau returns `hasOpen`:
- Extract `SimpleCountermodel` via `extractCountermodelSimple`.

### 2.2 Known Issues ("Broken Tableau")

The phrase "broken tableau" in the task description refers to several interrelated problems:

**Problem 1: Incomplete proof extraction (task 239)**
- `extractProof` in `ProofExtraction.lean` returns `"Full proof extraction not yet implemented"` for non-trivial cases.
- Only direct axiom matches and axiomNeg closures produce proof terms.
- Propositional case analysis (peirce-based), modal (necessitation + K-distribution), and temporal proofs cannot be extracted.
- **Consequence**: Valid formulas that the tableau confirms as valid but cannot produce a `DerivationTree` for are labeled as `.timeout` -- a **mislabel**.

**Problem 2: Vacuous countermodel correctness (task 240)**
- `branchTruthLemma` is trivially `forall sf in b, True` -- it proves nothing.
- `SimpleCountermodel` only captures true/false atoms; it does not capture the full model structure (worlds, times, temporal ordering, modal accessibility).
- No `SemanticCountermodel` type exists yet in the codebase.
- **Consequence**: Countermodels are structurally incomplete and unverified.

**Problem 3: Blocking termination for modal-temporal interaction (referenced as task 237)**
- Test comments in Saturation.lean indicate that formulas like `box p -> always p` and `box (box p) -> G(box p)` produce open branches or fuel exhaustion with notes "blocking refinement needed, task 237".
- The subset blocking (`findBlockedTime`) works for pure temporal formulas but has edge cases with modal-temporal interactions where valid formulas are not closed.
- **Consequence**: Some valid modal-temporal formulas are labeled `.timeout` or even `.invalid` when the tableau fails to close.

**Combined effect on dataset quality**:
- Valid formulas may be mislabeled as timeout (proof extraction failure).
- Valid modal-temporal formulas may be mislabeled as invalid or timeout (blocking issues).
- Invalid formula countermodels are structurally impoverished (atom-only SimpleCountermodel).
- Timeout rate is artificially inflated by proof extraction failures.

---

## 3. What Needs to Change

### 3.1 Prerequisites (External Dependencies)

Task 241 depends on:
- **Task 239** (proof extraction): Must be completed so valid formulas get `DerivationTree` proofs instead of fallback timeout.
- **Task 240** (countermodel correctness): Must be completed for `SemanticCountermodel` with world states, time domain, temporal ordering, and valuation.

Both are currently `[NOT STARTED]`. Without them, 241 cannot achieve its core objective. However, 241's state.json shows `dependencies: []` -- this should be updated to include 239 and 240.

### 3.2 Changes to DatasetGenerator.lean

1. **`labelFormula` rewrite**: Remove the 3-stage approach. With correct tableau:
   - `decideAuto phi` should directly use the improved tableau.
   - `.valid proof` case: works as-is (extract `ProofTrace` from `DerivationTree`).
   - `.invalid cm` case: convert to enriched countermodel (not just `SimpleCountermodel`).
   - `.timeout` case: should be genuinely rare (only for formulas exceeding `soundFuel`).

2. **`LabeledFormula` enrichment** (see Section 4 below).

3. **Remove `decideOptimized` retry**: With correct blocking, the first `decideAuto` call should be reliable. The retry path currently masks the broken proof extraction.

4. **Add `RuleProfile` to valid labels**: `walkDerivationTree` already exists in DataExport.lean but is not used in `LabeledFormula`. Valid formulas should carry both `ProofTrace` (axiom/rule names) and `RuleProfile` (counts per rule type).

### 3.3 Changes to DecisionProcedure.lean

After task 239 completion:
- The `.valid proof` path in `decide` should succeed for all closed tableaux.
- The fallback to `.timeout` for "valid but no proof" should be eliminated.
- The `decideOptimized` function may become unnecessary.

### 3.4 Changes to DataExport.lean / DatasetExport.lean

1. **`SemanticCountermodel.toJson`**: New serialization for the richer countermodel type from task 240.
2. **`EnrichedCountermodel.toJson`**: Already exists; integrate into main export pipeline.
3. **`DatasetRecord` enrichment**: Add fields for `RuleProfile`, enriched countermodel, and proof reconstruction metadata.

---

## 4. LabeledFormula Structure and Needed Enrichments

### 4.1 Current Structure

```lean
structure LabeledFormula where
  formula : Formula
  label : FormulaLabel           -- valid | invalid | timeout
  proofTrace : Option ProofTrace -- height, axioms_used, rules_applied
  countermodel : Option SimpleCountermodel -- trueAtoms, falseAtoms, formula
  metrics : DifficultyMetrics
  patternKey : PatternKey
```

### 4.2 Needed Enrichments

**For valid formulas**:
- `ruleProfile : Option RuleProfile` -- detailed rule application counts from `walkDerivationTree`
- `proofHeight : Option Nat` -- redundant with ProofTrace.height but useful for quick access
- `proofReconstructionMethod : Option String` -- "axiom_match", "proof_search", "tableau_extraction" to track which method produced the proof

**For invalid formulas**:
- `enrichedCountermodel : Option EnrichedCountermodel` -- replace SimpleCountermodel with the enriched version that includes full branch, modal formulas, temporal formulas
- `semanticCountermodel : Option SemanticCountermodel` -- once task 240 is complete, include the genuine semantic model with worlds, times, ordering, valuation
- `countermodelConsistent : Option Bool` -- flag from `SimpleCountermodel.isConsistent`

**For all formulas**:
- `decisionMethod : String` -- "fast_path_axiom", "proof_search", "tableau_closed", "tableau_open", "timeout" to track which pipeline stage produced the decision
- `tableauStats : Option TableauStats` -- optional expansion statistics (branch count, max depth, blocking events, fuel consumed)

### 4.3 Recommended Phased Approach

**Phase A** (minimal, no external deps): Add `ruleProfile`, `decisionMethod`, `countermodelConsistent` fields. Wire `walkDerivationTree` into `labelFormula` for valid results. Track which decision stage produced the result.

**Phase B** (after task 240): Replace `SimpleCountermodel` with `SemanticCountermodel`. Add `enrichedCountermodel` field. Wire in the enriched countermodel pipeline from EnrichedCountermodel.lean.

**Phase C** (after task 239): Full proof extraction produces `DerivationTree` for all valid formulas. Remove the timeout-as-fallback path. Add `proofReconstructionMethod` tracking.

---

## 5. DataExport Serialization Changes

### 5.1 New JSON Fields Needed

For the `DatasetRecord` JSONL output:

```json
{
  "id": "bmlogic-00001",
  "formula_str": "...",
  "formula_ast": {...},
  "label": "valid",
  "decision_method": "tableau_closed",
  "proof_trace": {"height": 2, "axioms_used": [...], "rules_applied": [...]},
  "rule_profile": {"axiom": 2, "modus_ponens": 1, ...},
  "countermodel": null,
  "enriched_countermodel": null,
  "semantic_countermodel": null,
  "countermodel_consistent": null,
  "metrics": {...},
  "pattern_key": {...},
  "tableau_stats": {"branches": 4, "max_depth": 7, "fuel_consumed": 150}
}
```

### 5.2 Serialization Functions to Add

1. `decisionMethodToJson : String -> String` (trivial, just quote)
2. `TableauStats.toJson` (new structure + serialization)
3. `SemanticCountermodel.toJson` (after task 240; worlds array, times array, ordering, valuation)
4. Update `datasetRecordToJson` in DatasetExport.lean to include new fields
5. Update `DatasetMetadata` to record what decision methods were used across the batch

### 5.3 Backward Compatibility

The existing JSONL consumers (Python scripts) use `json.loads(line)`. New fields are additive -- existing consumers that access `r["label"]`, `r["proof_trace"]`, etc. will continue working. New fields are simply ignored by old consumers.

---

## 6. Key Risks and Dependencies

### 6.1 Critical Dependencies

| Dependency | Status | Impact if Unresolved |
|-----------|--------|---------------------|
| Task 239 (proof extraction) | NOT STARTED | Valid formulas with tableau-proved validity continue to be labeled `.timeout`. The enriched `LabeledFormula` with proof traces will have no data for tableau-proved formulas. |
| Task 240 (countermodel correctness) | NOT STARTED | `SemanticCountermodel` type does not exist. Enriched countermodel fields remain `none`. Invalid labels lack structural proof of invalidity. |

### 6.2 Risks

1. **Dependency ordering**: Task 241 as specified assumes 239 and 240 are done. However, state.json shows `dependencies: []`. The implementation plan should either (a) declare 239, 240 as prerequisites and defer, or (b) decompose into phases where Phase A (enrichments using existing types) can proceed independently.

2. **Breaking changes to LabeledFormula**: Adding fields changes the structure. All consumers of `LabeledFormula` must be updated: `DatasetExport.lean`, `DatasetExporter.lean`, `DatasetValidator.lean`. The `Inhabited` instance must be extended. The `.toJson` method must include new fields.

3. **Performance regression**: Adding `walkDerivationTree` to every valid formula's labeling adds O(proof_size) work per formula. For the streaming JSONL pipeline processing thousands of formulas, this should be negligible since `walkDerivationTree` is simple recursion.

4. **Conformance test breakage**: The `DatasetValidator` known valid/invalid formula tests rely on `labelFormula` producing specific labels. Changes to the decision pipeline may change which formulas timeout vs. succeed. Tests should be updated to reflect improved labeling accuracy.

5. **Blocking edge cases**: Even with task 237's blocking improvements, there may be formulas where the tableau oscillates near the blocking boundary, producing nondeterministic behavior (valid on one run, timeout on another if fuel is near the threshold). The `soundFuel` bound mitigates this but edge cases exist.

---

## 7. Module Dependency Map

```
FormulaEnumerator.lean
    |
    v
DatasetGenerator.lean  <-- DecisionProcedure.lean <-- ProofExtraction.lean (task 239)
    |                                               <-- CountermodelExtraction.lean (task 240)
    |                                               <-- Saturation.lean <-- Closure.lean <-- Tableau.lean
    |
    v
DataExport.lean  (JSON serialization primitives)
    |
    +-> DatasetExport.lean   (JSONL streaming pipeline, CLI)
    +-> DatasetExporter.lean (JSON batch pipeline, legacy)
    +-> DatasetValidator.lean (conformance tests, feasibility gate)
    +-> EnrichedCountermodel.lean (enriched countermodel extraction + JSON)
```

---

## 8. Recommendations

1. **Update task 241 dependencies**: Add tasks 239 and 240 as explicit prerequisites in state.json.

2. **Phase the implementation**:
   - Phase 1: Add `ruleProfile`, `decisionMethod`, `countermodelConsistent` to `LabeledFormula` and wire into pipeline. Update all serialization. No external deps.
   - Phase 2 (after 240): Integrate `EnrichedCountermodel` and future `SemanticCountermodel` into the pipeline.
   - Phase 3 (after 239): Replace proof extraction fallback. Remove `decideOptimized` retry. Full proof coverage.

3. **Fix the dependency graph**: Task 241's `dependencies: []` should become `dependencies: [239, 240]` to prevent premature implementation attempts.

4. **Preserve backward compatibility**: New JSONL fields should be additive. Old fields should not change semantics.

5. **Update conformance tests**: After changes, regenerate expected results for known valid/invalid formulas to verify improved accuracy.
