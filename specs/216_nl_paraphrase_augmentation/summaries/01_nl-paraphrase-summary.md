# Implementation Summary: Task #216

**Completed**: 2026-05-29
**Duration**: ~1 session

## Overview

Added `nl_paraphrase` and `nl_paraphrase_method` optional fields to all 727 records in `data/bmlogic-bench.jsonl`. Used a recursive Python AST-walker with comprehensive derived-operator detection (12+ patterns) that handles all formula structures including deeply nested bimodal combinations. All 727 records received non-null paraphrases; 635 (87.3%) are tagged `rule_based` (depth ≤ 2), and 92 (12.7%) are tagged `rule_based_complex` (depth ≥ 3).

## What Changed

- `data/bmlogic-bench.jsonl` — Added `nl_paraphrase` and `nl_paraphrase_method` to all 727 records
- `data/bmlogic-bench_metadata.json` — Added `nl_paraphrase_augmentation` section documenting the new fields
- `data/hf-dataset/validate.py` — Added `OPTIONAL_FIELDS` dict and optional-field validation logic (backward-compatible)
- `data/README.md` — Added scripts inventory table, NL paraphrase fields section, regeneration commands
- `data/hf-dataset/README.md` — Updated schema to 15 fields v1.1 with nl_paraphrase/nl_paraphrase_method documentation
- `data/scripts/generate_paraphrases.py` — Created: main generation script with AST-walker, CLI, dry-run mode, statistics
- `data/scripts/test_paraphrases.py` — Created: 46-test unit + integration test suite
- `data/scripts/validate_paraphrases.py` — Created: standalone quality validation script with stratified sampling
- `data/scripts/prompt_template.txt` — Created: LLM prompt template for future NL generation (reference document)
- `data/scripts/review_depth3.json` — Created: review artifact for 92 depth >= 3 records with approval status

## Decisions

- **Dispatch ordering**: Derived operators (and, diamond, globally, iff, etc.) must be checked BEFORE generic negation because they are all encoded as negation patterns; checking negation first would intercept them
- **Depth=0 rendering**: At depth=0, compound sub-expressions in and/or/until/since templates are rendered at depth=0 (not depth+1) to prevent leading parentheses in the output sentence
- **rule_based_complex instead of LLM**: Since no LLM API is available during implementation, depth >= 3 records use the same rule-based AST-walker (labeled `rule_based_complex`). The LLM prompt template is preserved as `prompt_template.txt` for future use
- **U(event, guard) semantics**: U(bot, phi) = X(phi) = "at the next moment"; U(top, phi) = F(phi) = "at some future time"; U(phi, psi) = generic until (guard holds in future, event holds in between)
- **Grammar heuristic skip words**: Modal/temporal operator names (`necessarily`, `possibly`, etc.) must be excluded from repeated-word detection since `□□φ` legitimately generates "necessarily(necessarily(...))"

## Plan Deviations

- **Task 2.5** (flagging high-impCount records): skipped — integrated into validate_paraphrases.py's --stats output instead of a separate flag step
- **Task 3.2** (LLM generation function): altered — used rule_based_complex instead of actual LLM API calls; nl_paraphrase_method="rule_based_complex" rather than "llm-assisted"
- **Task 3.4** (llm-assisted method): altered — method value is "rule_based_complex" (same AST-walker, deeper formulas) rather than "llm-assisted"

## Verification

- Build: N/A (Python scripts only)
- Tests: 46 tests PASSED (TestDerivedOperatorDetection: 14 tests, TestNLGeneration: 22 tests, TestIntegration: 10 tests)
- `python data/hf-dataset/validate.py`: All 5 configs PASS (0 regressions)
- `python data/scripts/validate_paraphrases.py`: 727/727 records PASS (100%)
- `python data/scripts/generate_splits.py`: Unchanged output (backward compatible)
- All 727 records have non-null nl_paraphrase field
- No formal symbols in any paraphrase
- All paraphrases start with uppercase letter and end with period

## Notes

The implementation revealed a subtle AST dispatch ordering requirement: many derived operators (and = neg(imp(phi, neg(psi))), diamond = neg(box(neg(phi))), globally = neg(eventually(neg(phi)))) are themselves negations. The `ast_to_nl` function must check these compound patterns before the generic negation handler, or they will be incorrectly rendered as plain negations. This is documented in the function docstring.

Future work: The LLM prompt template at `data/scripts/prompt_template.txt` can be used to improve paraphrases for depth >= 3 records via actual LLM API calls, with the generated paraphrases replacing `rule_based_complex` entries and updating `nl_paraphrase_method` to `"llm-assisted"`.
