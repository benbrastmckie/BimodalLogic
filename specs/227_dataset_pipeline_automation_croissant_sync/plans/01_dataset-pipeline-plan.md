# Implementation Plan: Task #227

- **Task**: 227 - Dataset pipeline automation + Croissant sync infrastructure
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/227_dataset_pipeline_automation_croissant_sync/reports/01_dataset-pipeline-research.md
- **Artifacts**: plans/01_dataset-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Build end-to-end automation for dataset artifact synchronization after benchmark regeneration. The immediate trigger is croissant.json staleness after task 220 grew bmlogic-bench.jsonl from 727 to 777 records without updating downstream metadata. The plan fixes the immediate staleness, creates a deterministic sync script that future tasks can call, wires agent context so planners include a sync phase in benchmark-related tasks, and documents the full pipeline narrative in data/README.md with VERSION provenance for BimodalHarness consumption.

### Research Integration

Research report (01_dataset-pipeline-research.md) confirmed:
- Only bmlogic-bench.jsonl has a stale SHA-256 hash in croissant.json (6ce78a... should be 170e08...)
- contentSize stale ("668 KB" should be "766 KB"), description stale ("727 held-out records" should be "777")
- bmlogic-bench-splits.json is stale (records 727 total, should be 777) -- regeneration script exists at data/scripts/generate_splits.py
- croissant.json benchmark-schema-v1 has 2 phantom fields (nl_paraphrase, nl_paraphrase_method) and is missing 1 actual field (axiom_name)
- data/hf-dataset/validate.py hardcodes EXPECTED_COUNTS with 727 -- must be updated to 777
- No sync automation exists; finalize_benchmark.py does not touch croissant.json or splits
- mlcroissant CLI unavailable on NixOS; use sha256sum + jq structural checks
- BimodalHarness consumes data/ via make sync-data (rsync from ../BimodalLogic/data/)
- Recommended agent integration: context file + agent documentation (Options 2+5 from research)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No specific ROADMAP.md items are directly advanced by this task. This is infrastructure supporting the Dataset Enhancements section of TODO.md (tasks 216-221, 227). It ensures future dataset tasks produce consistent artifacts.

## Goals & Non-Goals

**Goals**:
- Fix all stale metadata in croissant.json (SHA-256 hash, contentSize, description, schema fields)
- Regenerate bmlogic-bench-splits.json from current 777-record benchmark
- Create scripts/sync-dataset-artifacts.sh that automates all downstream updates
- Create scripts/update_croissant.py for safe JSON-LD manipulation
- Write data/VERSION with git commit provenance for BimodalHarness
- Add agent context entry so benchmark-related plans include a sync step
- Document the full pipeline in data/README.md

**Non-Goals**:
- Verifying LFS-tracked files (bmlogic-c7.jsonl hash cannot be checked without git lfs pull)
- Building CI/CD integration or GitHub Actions for validation
- Modifying finalize_benchmark.py itself (sync is a separate downstream step)
- Implementing mlcroissant CLI validation (confirmed unavailable on NixOS)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| jq in-place JSON edit corrupts croissant.json nested structure | High | Medium | Use Python (json.load/json.dump) via scripts/update_croissant.py for all JSON manipulation |
| bmlogic-c7.jsonl SHA-256 cannot be verified (LFS pointer) | Low | High | Document LFS constraint in sync script; skip LFS files; compute only for non-LFS distributions |
| generate_splits.py produces different output format than expected | Medium | Low | Validate split output structure before committing; the script already exists and works |
| Agent context entry not loaded for relevant tasks | Medium | Medium | Document sync requirement both in context file AND in data/README.md for human reference |
| sync script auto-commits when user wants to review first | Low | Medium | Make commit step opt-in via --commit flag; default is dry run with changes staged |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix Immediate Croissant Staleness [NOT STARTED]

**Goal**: Bring all dataset metadata artifacts into consistency with the current 777-record bmlogic-bench.jsonl.

**Tasks**:
- [ ] Update croissant.json bmlogic-bench.jsonl distribution: SHA-256 to `170e086e916c078edff00bb0f1ee47ab001e6ca9a09012ff3a25c5648a53df3b`, contentSize to `"766 KB"`, description from "727 held-out records" to "777 held-out records"
- [ ] Fix croissant.json benchmark-schema-v1 RecordSet: remove nl_paraphrase and nl_paraphrase_method fields, add axiom_name field (type: Text, description: "Name of the axiom constructor being tested")
- [ ] Regenerate bmlogic-bench-splits.json by running `python data/scripts/generate_splits.py`
- [ ] Update SHA-256 for bmlogic-bench-splits.json in croissant.json (recompute after regeneration)
- [ ] Update data/hf-dataset/validate.py EXPECTED_COUNTS: change `"bmlogic-bench": 727` to `"bmlogic-bench": 777`
- [ ] Update data/README.md File Inventory table: bmlogic-bench.jsonl row to 777 records, ~766 KB
- [ ] Update data/hf-dataset/README.md body text: replace 727 with 777 where referring to benchmark count
- [ ] Verify croissant.json is valid JSON after edits: `python3 -c "import json; json.load(open('data/croissant.json'))"`

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `data/croissant.json` - SHA-256, contentSize, description, schema fields
- `data/bmlogic-bench-splits.json` - regenerated from current benchmark
- `data/hf-dataset/validate.py` - EXPECTED_COUNTS update
- `data/README.md` - File Inventory table record count
- `data/hf-dataset/README.md` - body text record count references

**Verification**:
- `python3 -c "import json; json.load(open('data/croissant.json'))"` succeeds
- `jq -e '."cr:distribution"[] | select(.name == "bmlogic-bench-jsonl") | .["sc:sha256"]' data/croissant.json` returns new hash
- `python data/scripts/generate_splits.py` runs without error
- `grep -c 777 data/hf-dataset/validate.py` returns at least 1
- `wc -l < data/bmlogic-bench.jsonl` returns 777

---

### Phase 2: Create Deterministic Sync Script and Python Updater [NOT STARTED]

**Goal**: Build reusable automation that can be run after any benchmark regeneration to update all downstream artifacts.

**Tasks**:
- [ ] Create `scripts/update_croissant.py`: Python script that takes file-to-hash mappings as arguments and updates croissant.json safely using json.load/json.dump (preserves structure, handles nested JSON-LD)
  - Accept arguments: `--file <name> --sha256 <hash> --size <size> [--count <N>]` (repeatable)
  - Update sc:sha256, contentSize, and description count for matching distributions
  - Preserve all JSON-LD structure (@context, cr:recordSet, etc.)
  - Write output with consistent formatting (indent=2)
- [ ] Create `scripts/sync-dataset-artifacts.sh`: Main orchestration script
  - Compute SHA-256 for non-LFS files (bmlogic-bench.jsonl, bmlogic-c5.jsonl, proof_steps.jsonl, bmlogic-bench-splits.json)
  - Compute file sizes with `du -h` or `stat` for human-readable format
  - Count records with `wc -l` for each JSONL
  - Call `scripts/update_croissant.py` with computed values
  - Run `python data/scripts/generate_splits.py` to regenerate splits
  - Recompute splits hash after regeneration and update croissant.json again
  - Run jq structural validation on croissant.json
  - Update record counts in data/README.md File Inventory table via sed
  - Update EXPECTED_COUNTS in data/hf-dataset/validate.py
  - Write data/VERSION with BIMODAL_LOGIC_COMMIT (git rev-parse HEAD) and SYNC_DATE (ISO 8601)
  - Accept `--commit` flag: if set, stage all changed files and commit with `sync: dataset artifacts after benchmark regeneration`
  - Accept `--dry-run` flag: print what would change without modifying files
  - Exit with clear error messages if any step fails (set -euo pipefail)
- [ ] Make both scripts executable: `chmod +x scripts/sync-dataset-artifacts.sh scripts/update_croissant.py`
- [ ] Test the sync script by running it on the current (already-fixed) state and verifying idempotency

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `scripts/update_croissant.py` - new file
- `scripts/sync-dataset-artifacts.sh` - new file
- `data/VERSION` - new file (created by sync script)

**Verification**:
- `scripts/sync-dataset-artifacts.sh --dry-run` runs without error and reports "no changes needed" (since Phase 1 already fixed everything)
- `scripts/sync-dataset-artifacts.sh` is idempotent: running twice produces identical output
- `scripts/update_croissant.py --help` shows usage
- `data/VERSION` contains valid BIMODAL_LOGIC_COMMIT and SYNC_DATE fields
- `python3 -c "import json; json.load(open('data/croissant.json'))"` still succeeds after script run

---

### Phase 3: Agent Context Integration [NOT STARTED]

**Goal**: Wire the sync script into agent workflows so that future benchmark-related tasks automatically include a sync step.

**Tasks**:
- [ ] Create `.claude/context/project/dataset/benchmark-sync.md`: Context file documenting:
  - When to run the sync script (after any benchmark regeneration: finalize_benchmark.py, generate_splits.py, anchor expansion, training data changes)
  - How to run it (`scripts/sync-dataset-artifacts.sh` or `scripts/sync-dataset-artifacts.sh --commit`)
  - What it updates (croissant.json, splits, README counts, VERSION, validate.py counts)
  - Cross-repo impact: BimodalHarness consumes data/ via `make sync-data` (rsync), so artifacts must be consistent before handoff
  - Note for planners: any implementation plan involving benchmark regeneration MUST include a final phase that runs the sync script
- [ ] Add entry to `.claude/context/index.json` for the new context file:
  - path: `.claude/context/project/dataset/benchmark-sync.md`
  - load_when: agents including `planner-agent` and `general-implementation-agent`; task_types including `general` and `lean4`; keyword-triggered for "benchmark", "dataset", "croissant"
  - Estimated line count for the context file
- [ ] Verify context discovery: run a jq query against index.json to confirm the entry is loaded for planner-agent

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `.claude/context/project/dataset/benchmark-sync.md` - new file
- `.claude/context/index.json` - new entry

**Verification**:
- `jq -r '.entries[] | select(.path | contains("benchmark-sync"))' .claude/context/index.json` returns the new entry
- `jq -r --arg agent "planner-agent" '.entries[] | select(any(.load_when.agents[]?; . == $agent)) | .path' .claude/context/index.json` includes the new file
- The context file exists and is well-formatted markdown

---

### Phase 4: Document Pipeline in data/README.md and VERSION Provenance [NOT STARTED]

**Goal**: Add comprehensive pipeline documentation so humans and agents understand the full data lifecycle.

**Tasks**:
- [ ] Add "Dataset Pipeline Architecture" section to data/README.md:
  - Dependency graph: `benchmark_anchors` -> `curate_benchmark.py` -> `benchmark_oracle` -> `finalize_benchmark.py` -> `sync-dataset-artifacts.sh`
  - What each artifact is and which script produces it
  - Which artifacts are final (bmlogic-bench.jsonl, bmlogic-c5.jsonl, bmlogic-c7.jsonl, proof_steps.jsonl) vs intermediate (candidates, validated)
  - How croissant.json, splits, VERSION, and README stats stay in sync
- [ ] Add "Sync After Regeneration" section to data/README.md:
  - One-liner: `scripts/sync-dataset-artifacts.sh` (or `--commit` for auto-commit)
  - What it does (list of updates)
  - When to run it
  - How to verify (validate.py, jq structural check)
- [ ] Add "Cross-Repository Consumption" section to data/README.md:
  - BimodalHarness consumes data/ via `make sync-data` (rsync from ../BimodalLogic/data/)
  - data/VERSION contains BIMODAL_LOGIC_COMMIT and SYNC_DATE for provenance
  - BimodalHarness should check VERSION to ensure data freshness
- [ ] Ensure data/VERSION file format is documented:
  - `BIMODAL_LOGIC_COMMIT=<sha>` (full 40-char git SHA)
  - `SYNC_DATE=<ISO 8601 date>`
  - Parseable by shell scripts via `source data/VERSION`

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `data/README.md` - add 3 new sections (Pipeline Architecture, Sync After Regeneration, Cross-Repository Consumption)

**Verification**:
- data/README.md contains "Dataset Pipeline Architecture" section
- data/README.md contains "Sync After Regeneration" section with the sync command
- data/README.md contains "Cross-Repository Consumption" section mentioning BimodalHarness
- data/VERSION format is documented in README

---

### Phase 5: End-to-End Validation [NOT STARTED]

**Goal**: Verify the complete pipeline works correctly and all artifacts are consistent.

**Tasks**:
- [ ] Run `scripts/sync-dataset-artifacts.sh --dry-run` and verify it reports no pending changes (all artifacts already consistent from Phase 1)
- [ ] Run `python data/hf-dataset/validate.py` and verify all checks pass (no 727-count failures)
- [ ] Run jq structural validation on croissant.json: verify all distributions have sc:sha256, contentSize, contentUrl
- [ ] Verify bmlogic-bench-splits.json total_records matches 777
- [ ] Verify data/VERSION exists with valid BIMODAL_LOGIC_COMMIT and SYNC_DATE
- [ ] Verify croissant.json benchmark-schema-v1 has axiom_name field and no nl_paraphrase fields
- [ ] Run `sha256sum data/bmlogic-bench.jsonl` and confirm it matches the hash in croissant.json

**Timing**: 0.5 hours

**Depends on**: 3, 4

**Files to modify**:
- None (validation only; fix any issues found)

**Verification**:
- All validation checks pass with zero errors
- Sync script is idempotent on already-consistent state

## Testing & Validation

- [ ] `python3 -c "import json; json.load(open('data/croissant.json'))"` succeeds (valid JSON)
- [ ] `jq -e '."cr:distribution" | length > 0' data/croissant.json` succeeds (has distributions)
- [ ] `jq -e '."cr:distribution"[] | has("sc:sha256") and has("contentSize") and has("contentUrl")' data/croissant.json` succeeds for all entries
- [ ] `python data/hf-dataset/validate.py` passes all checks
- [ ] `scripts/sync-dataset-artifacts.sh --dry-run` reports no pending changes after full run
- [ ] `wc -l < data/bmlogic-bench.jsonl` returns 777
- [ ] bmlogic-bench-splits.json total_records equals 777
- [ ] SHA-256 of bmlogic-bench.jsonl matches croissant.json sc:sha256 value
- [ ] data/VERSION contains valid git SHA and ISO date

## Artifacts & Outputs

- `specs/227_dataset_pipeline_automation_croissant_sync/plans/01_dataset-pipeline-plan.md` (this file)
- `scripts/sync-dataset-artifacts.sh` - main sync orchestration script
- `scripts/update_croissant.py` - Python helper for safe croissant.json updates
- `data/VERSION` - git commit provenance file for BimodalHarness
- `.claude/context/project/dataset/benchmark-sync.md` - agent context for benchmark sync awareness
- Updated `data/croissant.json` - corrected SHA-256, sizes, schema fields
- Updated `data/bmlogic-bench-splits.json` - regenerated from 777-record benchmark
- Updated `data/README.md` - pipeline documentation sections
- Updated `data/hf-dataset/validate.py` - corrected EXPECTED_COUNTS
- Updated `data/hf-dataset/README.md` - corrected record counts
- Updated `.claude/context/index.json` - new entry for benchmark-sync context

## Rollback/Contingency

All changes are file-level and version-controlled. If the sync script produces incorrect results:
1. Revert data/croissant.json and data/bmlogic-bench-splits.json from git
2. Delete scripts/sync-dataset-artifacts.sh and scripts/update_croissant.py
3. Remove the .claude/context/project/dataset/benchmark-sync.md entry from index.json
4. Revert data/README.md changes

The sync script itself is designed with `--dry-run` as a safety valve. No destructive operations are performed without the `--commit` flag.
