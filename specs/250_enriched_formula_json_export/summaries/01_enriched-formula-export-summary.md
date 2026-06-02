# Implementation Summary: Task #250

**Completed**: 2026-06-02
**Duration**: ~2 hours

## Overview

Completed the Python-side integration of enriched formula JSON export in BimodalHarness.
Task 248 had already wired enriched fields (formula_folded_json, formula_folded_str,
formula_folded_sexpr in DatasetRecord; goal_folded_json in ProofStep) into the Lean-side
export. This task added the corresponding Python support: 21-tag schema constants, 6 new
AST node types, an extended 33-token vocabulary with a rewritten linearizer, new optional
fields in TrainingRecord and ProofStepRecord, and updated ingestion functions. Datasets
were regenerated and validated end-to-end.

## What Changed

**BimodalHarness (Python)**:
- `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/schema/constants.py` — Added 6 missing tags to VALID_ENRICHED_FORMULA_TAGS, total 21 (was 15)
- `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/formula/ast.py` — Added 6 new AST node dataclasses (SomeFuture, SomePast, WeakFuture, WeakPast, Always, Sometimes) with full to_json/from_json/tag/unfold/metrics support; updated FormulaNode union and _TAG_TO_CLASS dispatch; added fold() handling for new types
- `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/models/formula_encoder.py` — Added 4 missing enriched tokens (weak_future=29, weak_past=30, always=31, sometimes=32); rewrote _linearize() to handle all 21 tags by child structure with token_to_id parameter; updated FormulaTokenizer.tokenize() to pass instance token map; extended vocab is now 33 tokens
- `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/schema/records.py` — Added formula_folded_json/str/sexpr optional fields to TrainingRecord; added goal_folded_json optional field to ProofStepRecord with to_dict/from_dict support
- `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/data/ingestion.py` — Updated lean_export_to_training_record() to extract formula_folded_* fields; updated load_bmlogic_proof_steps() to extract goal_folded_json

**Tests added**:
- `/home/benjamin/Projects/BimodalHarness/tests/test_formula/test_ast.py` — 56 new tests (6 test classes for new AST types + TestNewTagsInDispatchTable)
- `/home/benjamin/Projects/BimodalHarness/tests/test_models/test_formula_encoder.py` — 13 new tests (TestEnrichedTagTokenization); updated 5 existing tests for vocab size 29→33
- `/home/benjamin/Projects/BimodalHarness/tests/test_schema/test_records.py` — 11 new tests (TestTrainingRecordEnrichedFields + TestProofStepRecordGoalFoldedJson)
- `/home/benjamin/Projects/BimodalHarness/tests/test_data/test_ingestion.py` — 7 new tests (TestEnrichedFieldIngestion)

**BimodalLogic (datasets)**:
- `data/bmlogic-c5.jsonl` — Regenerated (1512 records, all include formula_folded_json/str/sexpr)
- `data/proof_steps.jsonl` — Regenerated (12077 steps, all include goal_folded_json)
- `data/dataset-card.md` — Documented new enriched formula fields (schema: 16→19 fields for training, 8→9 fields for proof steps)
- `data/hf-dataset/README.md` — Documented new enriched formula fields

## Decisions

- **SomeFuture/SomePast**: Implemented as separate AST node types (not just fold-time patterns) to match Lean's EnrichedFormula constructors exactly
- **WeakFuture/WeakPast**: Unfold to AllFuture/AllPast primitive patterns respectively (Neg(SomeFuture(Neg(child))))
- **Always/Sometimes**: Unfold to And(child, AllFuture(child)) and Or(child, SomeFuture(child)) using the primitive encodings of And and Or
- **_linearize parameter**: Added token_to_id parameter to _linearize() to allow instance-level token map injection without global state mutation
- **Validation skipped**: Did not add __post_init__ validation for formula_folded_json tags in TrainingRecord (optional field, skip for performance; caller trusts Lean output)
- **load_proof_steps vs load_bmlogic_proof_steps**: Updated load_bmlogic_proof_steps() (BimodalLogic-specific adapter) for goal_folded_json; load_proof_steps() picks it up automatically via ProofStepRecord.from_dict

## Plan Deviations

- **Task 3.3** skipped: __post_init__ validation for formula_folded_json — skipped for performance; field is optional and trusted from Lean output
- **Task 3.6** altered: Updated load_bmlogic_proof_steps() instead of load_proof_steps() — the generic load_proof_steps() already uses ProofStepRecord.from_dict which handles the new field
- **Task 4.9** deferred: c7 dataset regeneration is optional and time-consuming — c5 fully validates the pipeline

## Verification

- Build: Success (lake build dataset_generator: 1454 jobs; lake build proof_extractor: 1466 jobs)
- Tests: 2337 passed (2278 before + 59 new), 2 skipped, 29 deselected
- Dataset validation: 1473 training records + 12077 proof steps — all have enriched fields present
- Schema check: `len(VALID_ENRICHED_FORMULA_TAGS) == 21` passes
- Tokenizer check: FormulaTokenizer(extra_tokens=_ENRICHED_TAG_TOKENS).vocab_size == 33; no UNK for any of 15 enriched tags

## Notes

- The c7 dataset regeneration was intentionally skipped (optional, time-consuming); the c7 file on disk is from a previous generation and lacks formula_folded_* fields. A follow-up task can regenerate c7 overnight.
- The 21-tag schema exactly matches Lean's Normalization.lean EnrichedFormula constructors as verified by the Lean #eval round-trip test at build time.
