# Implementation Summary: Task #230

**Completed**: 2026-07-14
**Duration**: 5 phases across two sessions (phases 1-4 by a prior interrupted agent; phase 5 resumed and completed here)

## Overview

Regenerated all benchmark-derived artifacts after task 229's contamination resolution via
in-place enrichment of `data/bmlogic-bench.jsonl` — never rerunning
`scripts/finalize_benchmark.py`. The benchmark now carries the full 20-field v1.3 schema
(0 null `pattern_key`, +5 fields: `nl_paraphrase`, `nl_paraphrase_method`, `formula_sexpr`,
`formula_tokens`, `pattern_features`), splits are regenerated with correct classification, all
downstream metadata is synced, and `python data/hf-dataset/validate.py --config bmlogic-bench`
exits 0.

## What Changed

Note: everything under `data/` is gitignored (`.gitignore:82`), so data/script/metadata changes
live on disk only; git history captures the specs/ artifacts.

**Phases 1-4** (committed 1030bd424, 73f1f09f8, b2ea6e98c, e9401bb02):
- `data/scripts/enrich_benchmark.py` — new two-mode enrichment script (atomic rewrite pattern)
- `data/bmlogic-bench.jsonl` — 15 null `pattern_key` filled + stale `metrics` repaired
  (calibration 762/762); +3 schema fields on all 777 records (fidelity gate 6,029/6,029
  byte-equal vs training data); +2 paraphrase fields (validator exit 0, 46/46 unit tests)
- `data/scripts/generate_splits.py` — hardcoded generation_date fixed
- `data/bmlogic-bench-splits.json` — regenerated: 73/149/378/177 = 777, exact partition
- `data/scripts/test_paraphrases.py` — two stale integration expectations updated (727 -> 777)

**Phase 5** (this session):
- `data/dataset-card.md` — denormalized-depth note documenting the KEEP decision for
  `max_modal_depth`/`max_temporal_depth` (benchmark schema table was already updated on disk)
- `data/README.md` — same KEEP-decision sentence; stale croissant note fixed (15 fields/v1.1 ->
  20 fields/v1.3)
- `data/hf-dataset/README.md` — benchmark schema heading 15/v1.2 -> 20/v1.3, +5 field rows,
  example record replaced with the real record 00001 including the new fields; stale training
  `pattern_features` description corrected to
  `[modalDepth, temporalDepth, impCount, complexity, topOperator.toNat]`
- `data/hf-dataset/validate.py` — 5 new fields added to `REQUIRED_FIELDS["bmlogic-bench"]`;
  c5/c6/c7 `EXPECTED_COUNTS` untouched
- `data/bmlogic-bench_metadata.json`, `data/croissant.json` (v1.3) — verified already complete
  on disk from the prior agent's uncommitted work; not re-edited
- Removed `data/bmlogic-bench.jsonl.phase{1,2,3}.bak` after the final gate passed

## Decisions

- **Sub-item 4 (KEEP)**: `max_modal_depth`/`max_temporal_depth` retained in training data and
  documented as intentional denormalization for flat filtering (verified redundant, 0 mismatches
  over 6,029 records); removal would break the 16-field schema contract and validators.
- Complexity convention: plain AST node count (the benchmark's generation-time convention), not
  the task 274/285 derived-op variant — established by phase 1 calibration (762/762).
- **HF Hub push intentionally deferred**: phase 5 ends at the local `validate.py` green gate per
  orchestrator directive; uploading to the Hugging Face Hub awaits explicit user approval
  (`data/hf-dataset/upload.py` not run).

## Plan Deviations

- **Tasks 5.2-5.4** altered: `bmlogic-bench_metadata.json`, `croissant.json` v1.3, and the
  `dataset-card.md` benchmark table were already updated on disk by the prior interrupted agent
  (data/ is gitignored, so the edits survived uncommitted); verified correct instead of re-done.
- **Task 5.5** altered (scope+): adjacent stale docs corrected while updating the HF README
  field table (example record, training `pattern_features` description, lead sentence,
  `data/README.md` croissant note).
- **Phase 3** deviation (prior session): generator-branch fix contingency skipped — validation
  never failed on anchor_invalid shapes.
- **HF push** deferred awaiting user approval (see Decisions).

## Verification

- Build: N/A (data/docs task; no Lean changes)
- Tests: Passed — `validate.py --config bmlogic-bench` exit 0 (777 records, 16 required fields
  non-null, labels 369 valid / 408 invalid); phase-level gates all green (see plan)
- Invariants re-verified at phase 5 resume: 777 records, ids byte-identical to the phase-1
  backup, `contamination_flag` 553 true / 224 false, 0 null `pattern_key`, 20 fields per record
- `scripts/finalize_benchmark.py` never executed

## Notes

- Follow-up (user-approval gated): push the refreshed benchmark + metadata to the HF Hub
  (`logos-labs/bmlogic-bench`). All local artifacts are ready ("All checks passed. Ready to
  upload.").
- `data/hf-dataset/README.md` "Training Schema (17 fields...)" heading count predates task-250
  folded fields (19 in other docs); left as-is — training-doc reconciliation is out of scope.
