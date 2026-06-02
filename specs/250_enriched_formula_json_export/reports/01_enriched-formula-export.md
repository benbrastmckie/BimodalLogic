# Research Report: Enriched Formula JSON Export

- **Task**: 250 — enriched_formula_json_export
- **Type**: lean4
- **Dependencies**: Task 248 (fold direction formula normalization)
- **Date**: 2026-06-02

## Executive Summary

Task 248 has a complete plan to add enriched formula fields (`formula_folded_json`, `formula_folded_str`, `formula_folded_sexpr`) to `DatasetRecord` (DatasetExport.lean) and `goal_folded_json` to `ProofStep` (ProofStepExtractor.lean). The fold algorithm and all serialization functions already exist in Normalization.lean. Task 248 is currently in "planned" status. If task 248 is implemented as planned, **task 250 has minimal remaining work** -- the bulk of what "enriched formula JSON export" means is exactly what task 248's plan already covers. The residual work for task 250 consists of: (1) updating BimodalHarness Python schema to accept enriched fields, (2) extending the `_linearize` tokenizer to handle enriched tags, and (3) regenerating the JSONL dataset files with the new fields.

## 1. Current Export Pipeline Architecture

### 1.1 Two Export Pipelines

The project has two independent export pipelines:

**Pipeline A: Dataset Generator** (`lake exe dataset_generator`)
- Entry point: `DatasetExport.lean` main function
- Flow: `FormulaEnumerator` -> `DatasetGenerator.labelFormula` -> `DatasetExport.writeDatasetJSONL`
- Output: `data/bmlogic-bench.jsonl` (and variants: `bmlogic-c5.jsonl`, `bmlogic-c7.jsonl`, `bmlogic-c9.jsonl`)
- Record type: `DatasetRecord` (in `DatasetExport.lean`)
- Contains: `formula_str`, `formula_ast`, `formula_sexpr`, `formula_tokens`, `pattern_features`, label, proof trace, countermodel, metrics

**Pipeline B: Proof Step Extractor** (`lake exe proof_extractor`)
- Entry point: `ProofStepExport.lean` main function
- Flow: `theoremRegistry` -> `extractStepSequence` -> `ProofStep.toJson` -> JSONL
- Output: `data/proof_steps.jsonl`
- Record type: `ProofStep` (in `ProofStepExtractor.lean`)
- Contains: `theorem_name`, `step_index`, `context` (list of formulas), `goal`, `rule`, `axiom_name`, `subgoals`, `frame_class`

**Pipeline C: Dataset Exporter** (`DatasetExporter.lean`)
- Alternative structured JSON output (not JSONL)
- Uses `LabeledFormula.toJson` directly
- Provides train/eval split functionality
- Less commonly used than Pipeline A

### 1.2 Current Formula Representations

Both pipelines serialize formulas using `Formula.toJson` from `DataExport.lean`, which outputs **primitive-only** JSON with 6 tags: `atom`, `bot`, `imp`, `box`, `untl`, `snce`. For example, `neg p` (which is `imp p bot`) produces:

```json
{"tag": "imp", "left": {"tag": "atom", "name": "p"}, "right": {"tag": "bot"}}
```

There is no way for downstream consumers to distinguish `neg p` from a "real" implication `p -> bot` -- they are structurally identical in the primitive representation.

### 1.3 Key Source Files

| File | Role |
|------|------|
| `Automation/Normalization.lean` | EnrichedFormula ADT, fold algorithm, serialization (toJson, prettyPrint, toSExpr) |
| `Automation/DataExport.lean` | Primitive JSON serialization utilities (Formula.toJson, prettyPrint, toSExpr, etc.) |
| `Automation/DatasetExport.lean` | DatasetRecord structure, JSONL writer, CLI main for dataset_generator |
| `Automation/DatasetGenerator.lean` | LabeledFormula, labelFormula, labeling pipeline |
| `Automation/ProofStepExtractor.lean` | ProofStep structure, extractStepSequence, TheoremEntry |
| `Automation/ProofStepExport.lean` | theorem registry (310 entries), main for proof_extractor |
| `Automation/DatasetExporter.lean` | Alternative structured JSON exporter |

## 2. What Task 248 Already Provides

### 2.1 Fold Algorithm (Implemented)

Normalization.lean (lines 249-1031) contains:

- **`EnrichedFormula` ADT** (21 constructors: 6 primitive + 15 enriched) -- fully defined and tested
- **`Formula.foldFormula`** -- bottom-up greedy fold with ambiguity resolution
- **`EnrichedFormula.recognizeComposites`** -- second-pass for `always`, `sometimes`, `or_`
- **`Formula.foldFormulaFull`** -- combined two-pass fold
- **`EnrichedFormula.toPrimitive`** -- inverse (enriched -> primitive)
- **Round-trip tests** -- all pass for 21+ test formulas

### 2.2 Serialization (Implemented)

Three convenience functions on `Formula`:
- `Formula.toEnrichedJson` -- fold + JSON with enriched tags (neg, and, or, diamond, always, etc.)
- `Formula.toEnrichedPretty` -- fold + human-readable (Delta, nabla, G, H, F, P, X, Y, etc.)
- `Formula.toEnrichedSExpr` -- fold + S-expression with enriched tags

### 2.3 Task 248 Plan (Not Yet Implemented)

Task 248's plan (`plans/01_fold-direction-normalization.md`) specifies two phases:

**Phase 1**: Add to `DatasetRecord` in `DatasetExport.lean`:
- `formula_folded_json : String` -- `Formula.toEnrichedJson`
- `formula_folded_str : String` -- `Formula.toEnrichedPretty`
- `formula_folded_sexpr : String` -- `Formula.toEnrichedSExpr`
- Update `datasetRecordToJson` serializer
- Update `datasetMetadataToJson` representations array

**Phase 2**: Add to `ProofStep` in `ProofStepExtractor.lean`:
- `goal_folded_json : String` -- `goal.toEnrichedJson`
- Update `ProofStep.toJson` serializer

**Status**: Task 248 is "planned" but NOT YET IMPLEMENTED. Both phases are `[NOT STARTED]`.

## 3. Gap Analysis: What Task 250 Should Cover

Given that task 248 handles the Lean-side pipeline wiring, task 250's scope should focus on the **downstream integration** that task 248 does not cover.

### 3.1 Already Covered by Task 248 (No Overlap Needed)

| Work Item | Covered By |
|-----------|-----------|
| `DatasetRecord` enriched fields | Task 248 Phase 1 |
| `ProofStep` enriched goal field | Task 248 Phase 2 |
| Normalization.lean import in pipeline files | Task 248 Phases 1-2 |
| JSONL serialization updates | Task 248 Phases 1-2 |
| Metadata representations array | Task 248 Phase 1 |

### 3.2 NOT Covered by Task 248 (Task 250 Scope)

**A. BimodalHarness Python Schema Updates**

The BimodalHarness at `/home/benjamin/Projects/BimodalHarness` needs to be updated to:

1. **Add enriched formula tags to validation** -- `schema/constants.py` already has `VALID_ENRICHED_FORMULA_TAGS` with 9 enriched tags (lines 75-87), but it is missing 6 that Normalization.lean produces: `weak_future`, `weak_past`, `always`, `sometimes`, `some_future`, `some_past` (it has `some_future` and `some_past` via `all_future`/`all_past` patterns, but `weak_future`, `weak_past`, `always`, `sometimes` are entirely absent). These need to be added.

2. **Add `formula_folded_*` fields to ingestion** -- `schema/records.py` `TrainingRecord` and `schema/serialization.py` `jsonl_dict_to_record` do not reference `formula_folded_json`, `formula_folded_str`, or `formula_folded_sexpr`. These fields need to be either (a) mapped to new TrainingRecord attributes or (b) treated as pass-through fields in the ingestion pipeline.

3. **Extend `_linearize` for enriched tags** -- `models/formula_encoder.py` currently has `_ENRICHED_TAG_TOKENS` with 11 tokens (IDs 18-28: neg, top, next, prev, and, or, diamond, some_future, some_past, all_future, all_past). This is missing 4 enriched tags that Normalization.lean can produce: `weak_future`, `weak_past`, `always`, `sometimes`. The `_linearize` function needs to handle the enriched JSON tree structure (children may be `child`, `left`/`right`, or `event`/`guard`).

4. **formula.ast.py missing types** -- `formula/ast.py` defines 9 enriched types (Top, Neg, Next, Prev, And, Or, Diamond, AllFuture, AllPast) but is missing SomeFuture, SomePast, WeakFuture, WeakPast, Always, Sometimes. These would need to be added to support full enriched formula import.

**B. Dataset Regeneration**

After task 248 is implemented, the JSONL datasets need to be regenerated to include the new enriched fields:
```bash
lake exe dataset_generator -- --max-complexity 9 --output data/bmlogic-c9.jsonl
lake exe proof_extractor -- --output data/proof_steps.jsonl
```
This is mechanical but time-consuming (the c9 dataset takes hours to generate).

**C. Context Formulas in ProofStep**

Task 248 explicitly lists as a non-goal: "Adding folded context formulas in ProofStep (lower priority, can be done later)". The current `ProofStep.context` is `List Formula` serialized as primitive JSON. Task 250 could add `context_folded_json` (array of enriched JSON objects) for richer training signal, though this may be lower priority.

**D. Subgoals Enrichment**

Similarly, `ProofStep.subgoals` is `List Formula` serialized as primitive JSON. Enriching subgoals would give the model enriched representations of proof obligations.

**E. LabeledFormula.toJson (DatasetExporter path)**

`DatasetExporter.lean` uses `LabeledFormula.toJson` directly (not `DatasetRecord`). This function (in DatasetGenerator.lean, line 573) does NOT include enriched fields. If this alternative export path is to be used, `LabeledFormula.toJson` would also need enriched fields. However, this path is less commonly used.

**F. HF Hub Dataset Card Update**

The dataset card at `data/dataset-card.md` and `data/hf-dataset/README.md` should document the new `formula_folded_*` fields.

### 3.3 Enriched JSON Schema (for Reference)

The enriched JSON produced by `EnrichedFormula.toJson` uses 21 tags (6 primitive + 15 enriched):

| Tag | Arity | Child Fields | Example |
|-----|-------|-------------|---------|
| `atom` | 0 | `name` | `{"tag": "atom", "name": "p"}` |
| `bot` | 0 | -- | `{"tag": "bot"}` |
| `top` | 0 | -- | `{"tag": "top"}` |
| `imp` | 2 | `left`, `right` | `{"tag": "imp", "left": ..., "right": ...}` |
| `box` | 1 | `child` | `{"tag": "box", "child": ...}` |
| `untl` | 2 | `event`, `guard` | `{"tag": "untl", "event": ..., "guard": ...}` |
| `snce` | 2 | `event`, `guard` | `{"tag": "snce", "event": ..., "guard": ...}` |
| `neg` | 1 | `child` | `{"tag": "neg", "child": ...}` |
| `and` | 2 | `left`, `right` | `{"tag": "and", "left": ..., "right": ...}` |
| `or` | 2 | `left`, `right` | `{"tag": "or", "left": ..., "right": ...}` |
| `diamond` | 1 | `child` | `{"tag": "diamond", "child": ...}` |
| `some_future` | 1 | `child` | `{"tag": "some_future", "child": ...}` |
| `some_past` | 1 | `child` | `{"tag": "some_past", "child": ...}` |
| `all_future` | 1 | `child` | `{"tag": "all_future", "child": ...}` |
| `all_past` | 1 | `child` | `{"tag": "all_past", "child": ...}` |
| `next` | 1 | `child` | `{"tag": "next", "child": ...}` |
| `prev` | 1 | `child` | `{"tag": "prev", "child": ...}` |
| `weak_future` | 1 | `child` | `{"tag": "weak_future", "child": ...}` |
| `weak_past` | 1 | `child` | `{"tag": "weak_past", "child": ...}` |
| `always` | 1 | `child` | `{"tag": "always", "child": ...}` |
| `sometimes` | 1 | `child` | `{"tag": "sometimes", "child": ...}` |

## 4. BimodalHarness Data Ingestion Expectations

### 4.1 Current Schema

BimodalHarness expects records with these formula-related fields:
- `formula_json` (or `formula_ast`): primitive JSON tree with 6 tags
- `formula_pretty` (or `formula_str`): human-readable string (primitive notation)
- `formula_sexpr`: S-expression (primitive notation)
- `formula_tokens`: prefix-order token list

### 4.2 Formula Encoder

The `FormulaTokenizer` in `models/formula_encoder.py`:
- Base vocabulary: 18 tokens (4 special + 6 AST tags + 8 atom buckets)
- Extended vocabulary: 29 tokens (+11 enriched tags)
- Uses `_linearize()` which handles 6 primitive tags
- The extended vocabulary exists but `_linearize` does NOT handle enriched tags in tree traversal -- it would map them to UNK

### 4.3 Derived Rules Module

`schema/derived_rules.py` already has Python functions that recognize enriched patterns in both primitive and enriched JSON forms (e.g., `_is_neg_enriched`, `_is_diamond_enriched`, `_is_and_enriched`, `_is_all_future_enriched`, `_is_all_past_enriched`, `_is_or_enriched`). These operate on dicts with enriched tags.

### 4.4 Formula AST Module

`formula/ast.py` has Python dataclasses for 15 formula types (6 primitive + 9 enriched) with both `unfold()` and `fold()` functions. Missing types: SomeFuture, SomePast, WeakFuture, WeakPast, Always, Sometimes.

### 4.5 Constants

`VALID_ENRICHED_FORMULA_TAGS` in `constants.py` has 15 tags (6 primitive + 9 enriched). Missing from the enriched set: `weak_future`, `weak_past`, `always`, `sometimes`, `some_future`, `some_past` (note: `some_future` and `some_past` are NOT in the enriched set despite being valid Normalization.lean outputs; they are treated as `untl`/`snce` with folded guards in the Python fold() function).

## 5. Full Export Pipeline Map

```
                                 Lean Side
                                 =========
Formula (6 constructors)
    |
    +---> Formula.toJson ---------> primitive JSON (6 tags)  ---> formula_ast field
    |
    +---> Formula.prettyPrint ----> primitive string  ----------> formula_str field
    |
    +---> Formula.toSExpr -------> primitive S-expr  ----------> formula_sexpr field
    |
    +---> Formula.tokenize ------> token list  -----------------> formula_tokens field
    |
    +---> Formula.toEnrichedJson -> enriched JSON (21 tags) ----> formula_folded_json [TASK 248]
    |
    +---> Formula.toEnrichedPretty -> enriched string  ---------> formula_folded_str [TASK 248]
    |
    +---> Formula.toEnrichedSExpr -> enriched S-expr  ----------> formula_folded_sexpr [TASK 248]

                                 Dataset Generator
                                 =================
DatasetExport.lean:
  DatasetRecord { formula_ast, formula_str, formula_sexpr, formula_tokens,
                  formula_folded_json [248], formula_folded_str [248],
                  formula_folded_sexpr [248], ... }
      |
      v
  JSONL file (data/bmlogic-*.jsonl)

                                 Proof Step Extractor
                                 ====================
ProofStepExtractor.lean:
  ProofStep { goal (primitive JSON), goal_folded_json [248],
              context (primitive JSON list), subgoals (primitive JSON list) }
      |
      v
  JSONL file (data/proof_steps.jsonl)

                                 Python Side
                                 ===========
BimodalHarness reads JSONL:
  schema/serialization.py -> TrainingRecord
  models/formula_encoder.py -> FormulaTokenizer -> token IDs
  schema/derived_rules.py -> derived rule recognition
  formula/ast.py -> FormulaNode tree
```

## 6. Recommended Implementation Approach

### Dependency: Task 248 Must Complete First

Task 250 depends on task 248. The Lean-side enriched field wiring is entirely task 248's scope. Task 250 should NOT duplicate that work.

### Phase 1: BimodalHarness Schema Updates (Python)

After task 248 is implemented:

1. **Update `VALID_ENRICHED_FORMULA_TAGS`** in `constants.py` to include all 21 tags (add `weak_future`, `weak_past`, `always`, `sometimes`, `some_future`, `some_past`)
2. **Add missing AST types** to `formula/ast.py`: `SomeFuture`, `SomePast`, `WeakFuture`, `WeakPast`, `Always`, `Sometimes` with proper `unfold()` and `fold()` support
3. **Extend `_ENRICHED_TAG_TOKENS`** in `formula_encoder.py` with 4 missing tags (`weak_future`, `weak_past`, `always`, `sometimes`) -- total 33 tokens (or keep 29 if some_future/some_past are handled via folded guards)
4. **Update `_linearize`** to handle enriched tag children (child for unary, left/right for binary and/or, event/guard for temporal binary)
5. **Add `formula_folded_json`** handling to `schema/serialization.py` and `schema/records.py` -- either add fields to `TrainingRecord` or pass through as extra data

### Phase 2: Validation and Testing

1. Add validation for `formula_folded_json` fields (recursive enriched tag validation)
2. Test round-trip: parse enriched JSON -> unfold -> compare to primitive formula_ast
3. Verify FormulaTokenizer produces valid token sequences for enriched JSON

### Phase 3: Dataset Regeneration and Documentation

1. Regenerate JSONL files with enriched fields (after task 248 implementation)
2. Update dataset card and HF Hub README
3. Run dataset validation suite

### Alternative: Reduce Scope

If the goal is minimal viable enriched export, the implementation could be reduced to:
- Wait for task 248 to wire Lean-side fields
- Add pass-through field handling in BimodalHarness (no schema changes, just ignore unknown fields)
- Regenerate datasets
- Defer Python AST type completion to a separate task

## 7. Risks and Blockers

| Risk | Severity | Mitigation |
|------|----------|------------|
| Task 248 not yet implemented | **BLOCKER** | Task 250 cannot start Lean work until task 248 completes |
| Enriched tag set mismatch | Medium | Lean produces 21 tags; Python expects 15 -- gap must be closed |
| `_linearize` UNK fallback | Low | Enriched tags silently map to UNK(1) in current tokenizer -- needs fix |
| Dataset regeneration time | Low | c9 dataset takes hours; can be parallelized or scheduled |
| Cross-repo coordination | Medium | Changes span BimodalLogic (Lean) and BimodalHarness (Python) |

## 8. Summary of Findings

1. **Task 248 covers all Lean-side work** for enriched formula export -- adding fields to `DatasetRecord` and `ProofStep`, updating serializers, and importing Normalization.lean. Task 248 is planned but not yet implemented.

2. **Task 250's unique scope** is the BimodalHarness Python side: updating schema constants, adding missing AST node types, extending the tokenizer vocabulary and linearizer, and updating the ingestion pipeline to handle `formula_folded_*` fields.

3. **The enriched JSON schema** uses 21 tags (15 more than primitive). BimodalHarness currently knows about 15 of these 21 (missing 6: `weak_future`, `weak_past`, `always`, `sometimes`, `some_future`, `some_past`).

4. **Dataset regeneration** is a mechanical step that should follow both task 248 (Lean) and task 250 (Python) implementation.

5. **The `_linearize` function** in the formula encoder needs extension to traverse enriched JSON trees, which have different child field names per tag (child vs left/right vs event/guard).
