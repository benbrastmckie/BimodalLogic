# Implementation Summary: Task #229

**Completed**: 2026-06-02
**Duration**: ~1 hour

## Overview

Implemented Option B (contamination_flag) to resolve the 71.2% train/benchmark formula overlap in the BMLogic-Bench dataset. All 777 benchmark records now include a `contamination_flag` boolean field indicating whether the formula appears verbatim in the `bmlogic-c7.jsonl` training set. All downstream artifacts (metadata, splits, croissant schema, dataset card, HF README, validation script) were updated to reflect the new field and document the contamination analysis.

## What Changed

- `data/scripts/add_contamination_flag.py` — New script: loads c7 training formulas, flags each benchmark record, overwrites benchmark file
- `data/bmlogic-bench.jsonl` — Added `contamination_flag` field to all 777 records (553=true, 224=false)
- `data/bmlogic-bench_metadata.json` — Added `contamination_analysis` section and `fields` list
- `data/bmlogic-bench-splits.json` — Regenerated with correct `total_records: 777` (was stale at 727); split sizes also updated
- `data/croissant.json` — Added `contamination_flag` field to benchmark schema; replaced non-existent `nl_paraphrase`/`nl_paraphrase_method` fields with correct `axiom_name` + `contamination_flag`; updated record count and description
- `data/dataset-card.md` — Added "Contamination Analysis" section with per-split breakdown, Python usage example, distribution caveats; updated benchmark schema table to 15 fields; fixed stale split counts
- `data/hf-dataset/README.md` — Added "Contamination Analysis" section; updated field table to v1.2; fixed stale record counts (727 -> 777); updated data instance example
- `data/hf-dataset/validate.py` — Updated expected count (727 -> 777), added `contamination_flag` to required fields, removed stale `nl_paraphrase` optional fields

## Decisions

- Used exact `formula_str` string comparison (same approach as research verification), confirming 553/553 expected count exactly
- Split counts in splits.json changed from (97, 144, 247, 239) to (80, 144, 376, 177) because the benchmark was updated after the research was conducted; the important fix is total_records = 777
- Removed `nl_paraphrase`/`nl_paraphrase_method` fields from croissant.json schema because they don't exist in the actual benchmark data (task 230 will add them)
- HF data directory uses symlinks, so no copy was needed; the benchmark sync was automatic

## Plan Deviations

- None (implementation followed plan)

## Verification

- Build: N/A
- Tests: `python data/hf-dataset/validate.py --config bmlogic-bench` — PASS (777 records, all required fields non-null, contamination_flag present)
- Contamination counts verified: 553/777 contaminated, 224/777 held-out (exact match with research findings)
- All JSON files parse without errors

## Notes

- The 224 held-out records are skewed toward `very_hard` (56%) and `sampled-invalid` (55%) — documented in dataset card
- A follow-up task to regenerate the benchmark from complexity >= 8 would produce a balanced held-out set
- Task 230 (NL paraphrase generation) should add `nl_paraphrase` and `nl_paraphrase_method` fields and update the croissant schema accordingly
