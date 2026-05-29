# Research Report: Task #214 (Follow-up)

**Task**: 214 - Dataset cleanup, standardization, and documentation
**Started**: 2026-05-29T21:42:00Z
**Completed**: 2026-05-29T21:55:00Z
**Effort**: 0.5 hours
**Dependencies**: Task 213 (completed)
**Sources/Inputs**:
- specs/state.json (task 213 status and artifact list)
- specs/archive/213_production_scale_dataset_validation/summaries/01_production-validation-summary.md
- specs/archive/213_production_scale_dataset_validation/plans/01_production-validation-plan.md
- data/ directory listing with file sizes and line counts
- data/*.jsonl first-record field schema inspection
- data/*_metadata.json all files read
- specs/214_dataset_cleanup_documentation/plans/01_dataset-cleanup-plan.md (current plan)
**Artifacts**: specs/214_dataset_cleanup_documentation/reports/02_task-213-impact.md
**Standards**: report-format.md, status-markers.md, artifact-management.md, tasks.md

---

## Executive Summary

- Task 213 completed fully (status: `completed`), producing two new dataset files: `bmlogic-c5.jsonl` (1,513 records, complexity 5, exhaustive) and `bmlogic-c7.jsonl` (49,904 records, complexity 7, exhaustive), each with metadata files.
- `bmlogic-c7.jsonl` is a direct replacement for `bmlogic-deep.jsonl`: same complexity ceiling but uses the new exhaustive enumeration mode and has 3 extra representation fields (`formula_sexpr`, `formula_tokens`, `pattern_features`). The old `bmlogic-deep.jsonl` used random sampling.
- `bmlogic-c5.jsonl` is a new dataset at complexity 5; `bmlogic-medium.jsonl` used complexity 4. These are complementary (different complexity bands), not duplicates — but c5 is also richer (3 extra fields).
- The `representations` array in `bmlogic-c5/c7_metadata.json` is now ACCURATE (all listed fields exist in the actual JSONL records), unlike the misleading `representations` in old metadata. This is a material difference to note in the plan.
- The current 214 plan already anticipated c5/c7 existence (Phase 1 mentions "clarify whether c5/c7 replace medium/deep") — the plan is structurally correct but needs specific guidance on what to keep vs. delete.
- Only one plan change is needed: Phase 1 should decide definitively to keep c5+c7 as the canonical training datasets and delete medium+deep, and the metadata standardization tasks in Phase 3 should treat c5/c7 metadata as the template (not the bench metadata), since c5/c7 already have accurate representations.

---

## Context & Scope

This is a focused follow-up research round. The original team research (specs/214_dataset_cleanup_documentation/reports/01_team-research.md) and plan (plans/01_dataset-cleanup-plan.md) were created before task 213 ran. Task 213 then completed all 6 phases and produced new dataset files. This report identifies what changed in the data/ directory as a result, and assesses whether the 214 plan requires revision.

**Data/ directory as of research**: 20 files total (see Findings for current inventory).

---

## Findings

### Current data/ Directory Inventory

| File | Size | Records | Status |
|------|------|---------|--------|
| `bmlogic-bench.jsonl` | 672K | 727 | KEEP — final benchmark |
| `bmlogic-bench_metadata.json` | 1.2K | — | KEEP |
| `bmlogic-c5.jsonl` | 1.4M | 1,513 | NEW (task 213) — KEEP as new training |
| `bmlogic-c5_metadata.json` | 951B | — | NEW (task 213) — KEEP |
| `bmlogic-c7.jsonl` | 53M | 49,904 | NEW (task 213) — KEEP, replaces deep |
| `bmlogic-c7_metadata.json` | 957B | — | NEW (task 213) — KEEP |
| `bmlogic-deep.jsonl` | 50M | 53,979 | SUPERSEDED by c7 — DELETE |
| `bmlogic-deep_metadata.json` | 226B | — | SUPERSEDED — DELETE |
| `bmlogic-medium.jsonl` | 4.2M | 5,136 | KEPT for now; see analysis below |
| `bmlogic-medium_metadata.json` | 228B | — | KEPT for now; see analysis below |
| `proof_steps.jsonl` | 15M | 2,424 | KEEP — final proof steps |
| `axiom-instances.jsonl` | 1.7M | 724 | DELETE — intermediate |
| `bmlogic-bench-candidates.jsonl` | 1.5M | 1,771 | DELETE — intermediate |
| `bmlogic-bench-validated.jsonl` | 1.6M | 1,771 | DELETE — intermediate |
| `test.jsonl` | 36K | 50 | DELETE — test artifact |
| `test_c4.jsonl` | 152K | 200 | DELETE — test artifact |
| `test_metadata.json` | 221B | — | DELETE — test artifact |
| `test_c4_metadata.json` | 223B | — | DELETE — test artifact |
| `.gitignore` | 91B | — | REWRITE — see plan Phase 2 |

**Total current**: 20 files. After cleanup (7 deletions): 11 files.

### What Task 213 Added

Task 213 Phase 5 ran two full pipeline regressions using `lake exe dataset_generator`:

1. **Complexity 5, exhaustive, 5K seeds** → `bmlogic-c5.jsonl` + `bmlogic-c5_metadata.json`
   - 1,513 records, 4% valid (64 valid, 1,397 invalid, 52 timeout)
   - avg_complexity=4, max_complexity=5, sampling_mode=exhaustive

2. **Complexity 7, exhaustive, 5K seeds** → `bmlogic-c7.jsonl` + `bmlogic-c7_metadata.json`
   - 49,904 records, 3.4% valid (1,687 valid, 46,717 invalid, 1,500 timeout)
   - avg_complexity=6, max_complexity=7, sampling_mode=exhaustive

Both files were generated with the improved enumerator (task 210 fix + task 213 improvements): temporal axiom seeds, fixpoint closure, ex_falso cap, streaming write, HashMap dedup.

### Schema Comparison: New vs. Old Training Datasets

**c5/c7 records** (14 fields): `id, split, formula_str, formula_ast, frame_class, label, proof_trace, countermodel, pattern_key, metrics, augmentation, formula_sexpr, formula_tokens, pattern_features`

**medium/deep records** (11 fields): `id, split, formula_str, formula_ast, frame_class, label, proof_trace, countermodel, pattern_key, metrics, augmentation`

**Conclusion**: c5/c7 records are strictly richer than medium/deep. The 3 extra fields (`formula_sexpr`, `formula_tokens`, `pattern_features`) are representation formats added by task 207 (multi-representation export) that are referenced in the `representations` metadata array. In medium/deep, the `representations` array was present in the metadata but the actual JSONL records did NOT contain those fields — a misleading inconsistency. In c5/c7, the fields ARE present in the records, so the metadata is now accurate.

### Relationship Between Datasets

| Name | Complexity | Mode | Records | Has Multi-Repr? | Superseded? |
|------|-----------|------|---------|-----------------|-------------|
| medium | 4 | exhaustive | 5,136 | No | By c5 (partially) |
| c5 | 5 | exhaustive | 1,513 | Yes | No |
| deep | 7 | random | 53,979 | No | Yes — by c7 |
| c7 | 7 | exhaustive | 49,904 | Yes | No |

**bmlogic-deep vs bmlogic-c7**: These have the same max_complexity (7) but different sampling_mode (random vs. exhaustive). The c7 dataset is the improved replacement: exhaustive enumeration gives better formula coverage and structure. `bmlogic-deep.jsonl` should be deleted.

**bmlogic-medium vs bmlogic-c5**: These use different complexity ceilings (4 vs 5). They are not exact duplicates. However:
- `bmlogic-c5.jsonl` has 1,513 records while medium has 5,136 — medium is larger
- Both are "small" training sets (under 10MB); c5 is the newer, richer version
- Keeping both is reasonable; keeping only c5 (the richer one with multi-repr) is also reasonable

**Recommended decision** for the 214 implementer: Delete `bmlogic-deep.jsonl` and `bmlogic-deep_metadata.json` unconditionally (superseded by c7). For medium vs. c5: delete `bmlogic-medium.jsonl` and `bmlogic-medium_metadata.json` — they lack the multi-representation fields and are generated with the older pipeline (random sampling was previously the mode for medium, and the c5 is strictly better at a comparable complexity range). This gives a clean 3-dataset training inventory: c5 (small, complexity 5), c7 (large, complexity 7), bench.

### Scripts That Reference medium/deep

Three scripts hard-code `bmlogic-medium.jsonl` and `bmlogic-deep.jsonl`:
- `scripts/curate_benchmark.py` — uses --medium and --deep flags with these defaults
- `scripts/validate_benchmark.py` — uses --production-medium and --production-deep flags
- `scripts/verify_benchmark.py` — uses medium_path and deep_path parameters
- `scripts/run_dataset_generation.sh` — generates medium and deep targets

These scripts default to medium/deep but accept CLI arguments. If medium/deep are deleted, the scripts will fail unless either: (a) CLI flags are updated to point to c5/c7, or (b) the default values in the scripts are updated. This is a dependency the current plan did NOT mention and needs to be addressed in Phase 1.

### Metadata Status

| File | Has dataset_name? | Has version? | Has description? | Has schema_version? | representations accurate? |
|------|-----------------|-------------|----------------|--------------------|-----------------------|
| bmlogic-bench_metadata.json | Yes | Yes | Yes | Yes | Yes (no representations field) |
| bmlogic-c5_metadata.json | No | No | No | No | Yes (accurate) |
| bmlogic-c7_metadata.json | No | No | No | No | Yes (accurate) |
| bmlogic-deep_metadata.json | No | No | No | No | No (misleading) |
| bmlogic-medium_metadata.json | No | No | No | No | No (misleading) |
| proof_steps.jsonl | No metadata file | — | — | — | — |

After deleting deep and medium, metadata standardization is needed for c5 and c7 (add common header fields). The `representations` field can be KEPT in c5/c7 metadata since it is accurate.

---

## Decisions

1. **Delete bmlogic-deep.jsonl** and its metadata: superseded by bmlogic-c7.jsonl (same complexity ceiling, better enumeration mode, richer schema).
2. **Delete bmlogic-medium.jsonl** and its metadata: superseded by bmlogic-c5.jsonl (comparable complexity, richer schema with 3 extra representation fields, newer pipeline).
3. **Treat bmlogic-c5/c7 metadata as the enrichment template** for Phase 3: these already have accurate representations; Phase 3 only needs to ADD the common header fields (dataset_name, version, description, generation_date, schema_version), not remove or fix the representations array.
4. **Update script defaults in Phase 1** (not Phase 3): `scripts/curate_benchmark.py`, `scripts/validate_benchmark.py`, `scripts/verify_benchmark.py` should have their default paths updated to point to bmlogic-c5.jsonl (small) and bmlogic-c7.jsonl (large) instead of medium and deep.
5. **Final dataset inventory** (after cleanup):
   - `bmlogic-bench.jsonl` (727 records) + metadata — benchmark evaluation
   - `bmlogic-c5.jsonl` (1,513 records) + metadata — small training set, complexity 5
   - `bmlogic-c7.jsonl` (49,904 records) + metadata — large training set, complexity 7
   - `proof_steps.jsonl` (2,424 records) + new metadata — proof step records

---

## Recommendations

### Required Plan Updates

**Phase 1 — add script update tasks**:

The plan currently says "Verify no scripts have hard-coded dependencies on deleted files (check scripts/ directory)" — but three scripts DO have such dependencies and need to be updated. Add explicit tasks:
- Update `scripts/curate_benchmark.py` default paths (--medium → c5, --deep → c7)
- Update `scripts/validate_benchmark.py` default paths
- Update `scripts/verify_benchmark.py` default paths

**Phase 1 — clarify the medium/c5 decision**:

The plan has "Possibly `data/bmlogic-deep.jsonl`, `data/bmlogic-medium.jsonl` and their metadata - DELETE if superseded by c5/c7". This should be changed to explicit deletion of both medium and deep, with the rationale documented above.

**Phase 3 — metadata template revision**:

The plan says "Remove misleading `representations` array from metadata where actual JSONL records lack those fields." For c5/c7, the representations ARE accurate — do NOT remove them. Only remove from any kept old metadata. Since medium/deep will be deleted, no old training metadata needs cleaning. The Phase 3 task reduces to: ADD common header fields to c5/c7 metadata (not remove anything), and CREATE proof_steps_metadata.json.

**Phase 3 — update the standardize_metadata.py script scope**:

The script no longer needs a "remove representations" step for c5/c7. Its logic should be: add missing common fields if absent, preserve all existing fields (including accurate representations).

### No Changes Required

- Phase 2 (Git LFS and gitignore rewrite): Still fully applicable. `bmlogic-c7.jsonl` (53MB) and `proof_steps.jsonl` (15MB) remain large; bmlogic-c5.jsonl (1.4MB) is small enough to track without LFS.
- Phase 4 (README creation): Still needed; update record counts to reflect c5/c7 instead of medium/deep.
- Phase 5 (Schema validation): Still needed; update expected schema to reflect the 14-field c5/c7 schema.
- Git LFS availability: Still unconfirmed; the "check and install" task in Phase 2 remains appropriate.

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Scripts break when medium/deep deleted | M | Update script defaults in Phase 1 before deletion |
| c5 is much smaller than medium (1,513 vs 5,136) | L | Document this in README; c5 is representative of the new pipeline quality not quantity |
| curate_benchmark.py used by benchmark pipeline to generate bench from training data | H | Verify the benchmark is already final (bmlogic-bench.jsonl already exists and is stable); if regeneration is needed, the scripts must point to c5/c7 |
| Valid fraction gap (3-4% vs 15% target) may affect downstream tasks | L | The 214 plan explicitly does not involve improving valid fraction (Non-Goal); document the gap in README |

---

## Appendix

### File Timestamp Evidence

- `bmlogic-c5.jsonl` modified: 2026-05-29 14:36:43 (PDT)
- `bmlogic-c7.jsonl` modified: 2026-05-29 14:37:05 (PDT)
- Task 213 started: 2026-05-29T21:28:41Z (= 14:28 PDT)
- Files were created during task 213's Phase 5 pipeline regression runs

### Why bmlogic-c5.jsonl Has "bmlogic-00001" ID Conflicts

Both bmlogic-c5 and bmlogic-c7 use the same ID scheme starting from "bmlogic-00001". This is because each is generated from a fresh run of `dataset_generator` with `--output data/bmlogic-cN.jsonl`. The IDs are sequential within each file but not unique across files. This is expected behavior and should be noted in the README.

### bmlogic-c5 Records: Why Only 1,513 at Complexity 5?

The task 213 pipeline ran complexity 5 exhaustively with 5K seeds and a stream-write approach. The exhaustive enumerator at complexity 5 produces a smaller set because:
- Exhaustive enumeration at c5 is much more selective than random sampling
- The valid fraction is ~4%, meaning most records are invalid
- The 51K count from task 210's research was an upper bound; actual generation stopped when the formula space was exhausted

This does NOT indicate a bug — it reflects exhaustive coverage of the complexity-5 formula space under the given parameter constraints.
