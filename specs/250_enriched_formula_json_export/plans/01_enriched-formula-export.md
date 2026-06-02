# Implementation Plan: Task #250

- **Task**: 250 - enriched_formula_json_export
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: Task 248 (fold direction formula normalization) -- COMPLETED
- **Research Inputs**: specs/250_enriched_formula_json_export/reports/01_enriched-formula-export.md
- **Artifacts**: plans/01_enriched-formula-export.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Task 248 has completed the Lean-side work: enriched formula fields (formula_folded_json, formula_folded_str, formula_folded_sexpr) are wired into DatasetRecord, and goal_folded_json is wired into ProofStep. Task 250 covers the downstream Python integration in BimodalHarness: updating schema constants and AST types to support all 21 enriched tags, extending the formula tokenizer to linearize enriched JSON trees, adding formula_folded_* field handling to the ingestion pipeline, and regenerating JSONL datasets with the new fields.

All work targets the BimodalHarness repository at `/home/benjamin/Projects/BimodalHarness`. No Lean-side changes are needed.

### Research Integration

Key findings from the research report:
- The enriched JSON schema uses 21 tags (6 primitive + 15 enriched). BimodalHarness currently knows 15 of these (missing 6: weak_future, weak_past, always, sometimes, some_future, some_past).
- The _linearize function in formula_encoder.py only handles 6 primitive tags; enriched tags silently map to UNK.
- _ENRICHED_TAG_TOKENS has 11 tokens (IDs 18-28) but is missing 4: weak_future, weak_past, always, sometimes.
- formula/ast.py has 15 FormulaNode types but is missing 6: SomeFuture, SomePast, WeakFuture, WeakPast, Always, Sometimes.
- TrainingRecord and ProofStepRecord have no formula_folded_* fields yet.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items directly reference this task. The work advances the "dataset-enhancement" topic by enabling enriched formula representations in the training pipeline.

## Goals & Non-Goals

**Goals**:
- Update VALID_ENRICHED_FORMULA_TAGS to cover all 21 tags from Normalization.lean
- Add 6 missing AST node types with full unfold/fold/from_json/to_json support
- Extend formula tokenizer to linearize enriched JSON trees (not just primitive)
- Add formula_folded_json, formula_folded_str, formula_folded_sexpr fields to TrainingRecord
- Add goal_folded_json field to ProofStepRecord
- Update ingestion pipeline to parse these new fields from JSONL
- Regenerate JSONL datasets with enriched fields

**Non-Goals**:
- Enriching ProofStep context formulas (lower priority, deferred)
- Enriching ProofStep subgoal formulas (lower priority, deferred)
- Updating the LabeledFormula.toJson path in DatasetExporter.lean (rarely used)
- Training model changes (the extended vocabulary mechanism already exists)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Tag set mismatch between Lean and Python | M | L | Verify all 21 tags against Normalization.lean EnrichedFormula constructors |
| Tokenizer vocab size change breaks saved checkpoints | M | L | Existing vocab migration mechanism in FormulaTransformerEncoder handles this |
| Enriched field names differ from research expectations | L | L | Inspect actual JSONL output from task 248 before coding ingestion |
| Dataset regeneration takes hours (c9) | L | H | Run c5 for fast validation; schedule c9 overnight |
| Existing tests break on new AST types | M | M | Run full test suite after each phase; add tests incrementally |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Schema Constants and AST Types [COMPLETED]

**Goal**: Bring BimodalHarness Python types into alignment with the full 21-tag enriched formula schema from Normalization.lean.

**Tasks**:
- [x] Update VALID_ENRICHED_FORMULA_TAGS in `src/bimodal_harness/schema/constants.py` to add 6 missing tags: `some_future`, `some_past`, `weak_future`, `weak_past`, `always`, `sometimes` *(completed)*
- [x] Add 6 missing AST node dataclasses to `src/bimodal_harness/formula/ast.py`:
  - `SomeFuture(child)` -- Untl(child, Top) in primitive form. Tag: `some_future`
  - `SomePast(child)` -- Snce(child, Top) in primitive form. Tag: `some_past`
  - `WeakFuture(child)` -- Imp(Untl(Neg(child), Top), Bot). Tag: `weak_future`
  - `WeakPast(child)` -- Imp(Snce(Neg(child), Top), Bot). Tag: `weak_past`
  - `Always(child)` -- And(child, AllFuture(child)) in enriched form. Tag: `always`
  - `Sometimes(child)` -- Or(child, SomeFuture(child)) in enriched form. Tag: `sometimes`
  *(completed)*
- [x] For each new type: implement `to_json()`, `from_json()`, and `tag` property *(completed)*
- [x] Update `FormulaNode` type alias to include all 21 types *(completed)*
- [x] Update `_TAG_TO_CLASS` dispatch table with the 6 new tags *(completed)*
- [x] Add `unfold()` cases for the 6 new types (expand to primitives) *(completed)*
- [x] Add metric function cases (`complexity`, `modal_depth`, `temporal_depth`, `imp_count`, `top_operator`) for each new type *(completed)*
- [x] Update `fold()` to optionally recognize these patterns (or leave fold as-is since Lean handles folding) *(completed: fold recurses into enriched node children)*
- [x] Add unit tests in `tests/test_formula/test_ast.py` for new types: construction, to_json, from_json round-trip, unfold correctness *(completed)*
- [x] Run existing test suite to verify no regressions: `cd /home/benjamin/Projects/BimodalHarness && python -m pytest tests/test_formula/ tests/test_schema/` *(completed: 153 passed test_ast.py, 332 passed test_schema/)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `src/bimodal_harness/schema/constants.py` -- add 6 tags to VALID_ENRICHED_FORMULA_TAGS
- `src/bimodal_harness/formula/ast.py` -- add 6 dataclasses, update FormulaNode union, update _TAG_TO_CLASS, update unfold/fold/metrics
- `tests/test_formula/test_ast.py` -- add tests for new types

**Verification**:
- `python -m pytest tests/test_formula/test_ast.py -v` passes with new tests
- `python -m pytest tests/test_schema/ -v` passes (no regressions)
- `python -c "from bimodal_harness.schema.constants import VALID_ENRICHED_FORMULA_TAGS; assert len(VALID_ENRICHED_FORMULA_TAGS) == 21"` succeeds

---

### Phase 2: Formula Tokenizer Extension [COMPLETED]

**Goal**: Extend the formula tokenizer to correctly linearize enriched JSON trees and add missing enriched tag tokens to the vocabulary.

**Tasks**:
- [x] Add 4 missing tokens to `_ENRICHED_TAG_TOKENS` in `src/bimodal_harness/models/formula_encoder.py`: `weak_future` (29), `weak_past` (30), `always` (31), `sometimes` (32). Note: `some_future` and `some_past` are already at IDs 25-26 *(completed)*
- [x] Update `_EXTENDED_VOCAB` (will now be 33 tokens total: 18 base + 15 enriched) *(completed)*
- [x] Rewrite `_linearize()` to handle enriched tags by child structure *(completed: added token_to_id parameter; handles all 21 tags correctly)*
- [x] Update the `_linearize` function to use the instance `_token_to_id` map instead of the global `_TOKEN_TO_ID` when enriched tokens are active *(completed: FormulaTokenizer.tokenize() now passes self._token_to_id)*
- [x] Add tests in `tests/test_models/test_formula_encoder.py` for enriched tag tokenization *(completed: TestEnrichedTagTokenization with 13 new tests)*
- [x] Run tokenizer tests: `cd /home/benjamin/Projects/BimodalHarness && python -m pytest tests/test_models/test_formula_encoder.py -v` *(completed: 47 passed)*

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `src/bimodal_harness/models/formula_encoder.py` -- add 4 tokens, rewrite _linearize
- `tests/test_models/test_formula_encoder.py` -- add enriched tokenization tests

**Verification**:
- `python -m pytest tests/test_models/test_formula_encoder.py -v` passes
- Manual check: `FormulaTokenizer(extra_tokens=_ENRICHED_TAG_TOKENS).tokenize({"tag": "neg", "child": {"tag": "atom", "name": "p"}})` returns `[BOS, neg_id, atom_id, bucket_id, EOS]` (no UNK)

---

### Phase 3: Ingestion Pipeline and Record Schema [COMPLETED]

**Goal**: Add formula_folded_* fields to TrainingRecord and ProofStepRecord, and update the ingestion pipeline to parse them from JSONL.

**Tasks**:
- [x] Add optional fields to `TrainingRecord` in `src/bimodal_harness/schema/records.py`:
  - `formula_folded_json: dict[str, Any] | None = None` -- enriched JSON tree
  - `formula_folded_str: str | None = None` -- enriched pretty-print string
  - `formula_folded_sexpr: str | None = None` -- enriched S-expression
  *(completed)*
- [x] Add optional field to `ProofStepRecord` in `src/bimodal_harness/schema/records.py`:
  - `goal_folded_json: dict[str, Any] | None = None` -- enriched goal JSON
  *(completed)*
- [x] Update `TrainingRecord.__post_init__` if needed *(deviation: skipped validation for performance — fields are optional and caller trusts Lean output)*
- [x] Update `ProofStepRecord.to_dict()` and `ProofStepRecord.from_dict()` to handle `goal_folded_json` *(completed)*
- [x] Update `lean_export_to_training_record()` in `src/bimodal_harness/data/ingestion.py` to extract `formula_folded_json`, `formula_folded_str`, `formula_folded_sexpr` from JSONL dicts *(completed: function name corrected from lean_jsonl_to_training_record)*
- [x] Update `load_bmlogic_proof_steps()` in `src/bimodal_harness/data/ingestion.py` to extract `goal_folded_json` from proof step JSONL dicts *(completed: deviation — updated load_bmlogic_proof_steps not load_proof_steps)*
- [x] Add tests in `tests/test_schema/test_records.py` for new fields *(completed: TestTrainingRecordEnrichedFields + TestProofStepRecordGoalFoldedJson)*
- [x] Add tests in `tests/test_data/test_ingestion.py` for JSONL lines with enriched fields *(completed: TestEnrichedFieldIngestion with 7 tests)*
- [x] Run full test suite: `cd /home/benjamin/Projects/BimodalHarness && python -m pytest tests/ -v` *(completed: 2278 passed, 2 skipped, 29 deselected)*

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `src/bimodal_harness/schema/records.py` -- add optional fields to TrainingRecord and ProofStepRecord
- `src/bimodal_harness/data/ingestion.py` -- extract new fields during JSONL loading
- `tests/test_schema/test_records.py` -- test new fields
- `tests/test_data/test_ingestion.py` -- test enriched field ingestion

**Verification**:
- `python -m pytest tests/test_schema/test_records.py tests/test_data/test_ingestion.py -v` passes
- `python -m pytest tests/ -v` passes (no regressions in full suite)

---

### Phase 4: Dataset Regeneration and Validation [NOT STARTED]

**Goal**: Regenerate JSONL datasets from the Lean pipeline (which now includes enriched fields from task 248) and validate that BimodalHarness can ingest them correctly.

**Tasks**:
- [ ] In BimodalLogic, rebuild the dataset generator: `cd /home/benjamin/Projects/BimodalLogic && lake build dataset_generator`
- [ ] Regenerate c5 dataset (fast, for validation): `lake exe dataset_generator -- --max-complexity 5 --output data/bmlogic-c5.jsonl`
- [ ] Verify enriched fields are present in output: `head -1 data/bmlogic-c5.jsonl | python -c "import sys,json; d=json.load(sys.stdin); print(d.get('formula_folded_json','MISSING'))"`
- [ ] In BimodalLogic, rebuild proof_extractor: `lake build proof_extractor`
- [ ] Regenerate proof steps: `lake exe proof_extractor -- --output data/proof_steps.jsonl`
- [ ] Verify goal_folded_json is present: `head -1 data/proof_steps.jsonl | python -c "import sys,json; d=json.load(sys.stdin); print(d.get('goal_folded_json','MISSING'))"`
- [ ] Test ingestion of regenerated data from BimodalHarness:
  ```python
  from bimodal_harness.data.ingestion import lean_jsonl_to_training_record
  import json
  with open("/home/benjamin/Projects/BimodalLogic/data/bmlogic-c5.jsonl") as f:
      for line in f:
          rec = lean_jsonl_to_training_record(json.loads(line))
          if rec and rec.formula_folded_json:
              print("OK:", rec.formula_folded_json.get("tag"))
              break
  ```
- [ ] Update `data/dataset-card.md` and `data/hf-dataset/README.md` in BimodalLogic to document the new formula_folded_* fields
- [ ] Optionally regenerate c7 dataset: `lake exe dataset_generator -- --max-complexity 7 --output data/bmlogic-c7.jsonl`

**Timing**: 1 hour (excluding dataset generation wall-clock time)

**Depends on**: 2, 3

**Files to modify**:
- `data/bmlogic-c5.jsonl` (BimodalLogic) -- regenerated
- `data/proof_steps.jsonl` (BimodalLogic) -- regenerated
- `data/dataset-card.md` (BimodalLogic) -- document new fields
- `data/hf-dataset/README.md` (BimodalLogic) -- document new fields

**Verification**:
- Regenerated JSONL files contain formula_folded_json, formula_folded_str, formula_folded_sexpr fields
- Proof step JSONL contains goal_folded_json field
- BimodalHarness ingestion pipeline loads the regenerated files without errors
- Enriched JSON tags in loaded records are all in VALID_ENRICHED_FORMULA_TAGS

## Testing & Validation

- [ ] All 21 tags in VALID_ENRICHED_FORMULA_TAGS match Normalization.lean EnrichedFormula constructors
- [ ] FormulaTokenizer produces no UNK tokens for any enriched tag in extended vocabulary mode
- [ ] AST round-trip: from_json(to_json(node)) == node for all 21 node types
- [ ] Unfold round-trip: fold(unfold(node)) recovers enriched structure for standard patterns
- [ ] Ingestion pipeline handles JSONL lines with and without enriched fields (backward compatible)
- [ ] Full BimodalHarness test suite passes: `python -m pytest tests/ -v`
- [ ] Regenerated datasets load end-to-end through the training pipeline smoke test

## Artifacts & Outputs

- `specs/250_enriched_formula_json_export/plans/01_enriched-formula-export.md` (this file)
- Modified files in BimodalHarness: constants.py, ast.py, formula_encoder.py, records.py, ingestion.py
- New/updated tests in BimodalHarness: test_ast.py, test_formula_encoder.py, test_records.py, test_ingestion.py
- Regenerated JSONL datasets in BimodalLogic: bmlogic-c5.jsonl, proof_steps.jsonl
- Updated documentation: dataset-card.md, hf-dataset/README.md

## Rollback/Contingency

All changes are in BimodalHarness Python code. Rollback is straightforward:
- `cd /home/benjamin/Projects/BimodalHarness && git checkout -- src/ tests/` to revert all source changes
- The new enriched fields in JSONL are additive (the old fields remain); reverting Python changes does not require re-regenerating datasets
- If dataset regeneration fails, the old JSONL files remain valid since BimodalLogic is a separate git repository
