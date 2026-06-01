# Research Report: Task #245

**Task**: 245 - Cross-repository data sync pipeline from BimodalLogic to BimodalHarness
**Started**: 2026-06-01T00:00:00Z
**Completed**: 2026-06-01T00:30:00Z
**Effort**: ~3 hours estimated implementation
**Dependencies**: None blocking (both repos accessible locally)
**Sources/Inputs**: Codebase (BimodalLogic, BimodalHarness), existing scripts and Lean source files
**Artifacts**: specs/245_cross_repo_data_pipeline/reports/01_cross-repo-pipeline-research.md
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- BimodalLogic already has fully operational `lake exe dataset_generator` and `lake exe proof_extractor` executables producing JSONL output; `data/proof_steps.jsonl` currently holds 10,063 validated proof steps.
- BimodalHarness already has a `make sync-data` target (basic rsync), `make validate-data`, and Python `load_lean_jsonl()` / `load_proof_steps()` ingestion functions — but the harness-side `data/bimodal/` directory does not exist yet (`SYNC_DATE=not-yet-synced`).
- **Critical schema gap**: The Lean `proof_extractor` emits 8 fields (`theorem_name`, `step_index`, `context`, `goal`, `rule`, `axiom_name`, `subgoals`, `frame_class`), but `load_proof_steps()` requires 12 fields including `step_id`, `goal_json` (renamed from `goal`), `goal_pretty`, `action_index`, `depth`, and `proof_height`. An adapter or Lean-side enhancement is needed before `load_proof_steps()` will work.
- Recommended approach: create `scripts/export-training-data.sh` in BimodalLogic that runs both executables, validates output, and writes `data/VERSION`; enhance BimodalHarness `make sync-data` with schema/action-space checks; and add `make verify-data` targeting the existing Python validation functions.

---

## Context & Scope

Task 245 asks for an automated cross-repository sync pipeline. The task description specifies:
1. `scripts/export-training-data.sh` in BimodalLogic running `lake exe dataset_generator` + `lake exe proof_extractor` with validation and VERSION file
2. Enhanced `make sync-data` in BimodalHarness with schema compatibility and 49-action-space alignment checks
3. `make verify-data` in BimodalHarness running `load_lean_jsonl()` and `load_proof_steps()` validation
4. Documentation in both repos

Research covers what currently exists and what gaps remain.

---

## Findings

### Codebase Patterns

#### BimodalLogic: Existing Executables (lakefile.lean)

Five production executables are already declared:

| Executable | Root module | Output |
|---|---|---|
| `dataset_generator` | `Bimodal.Automation.DatasetExport` | `data/bmlogic.jsonl` + `_metadata.json` |
| `dataset_validator` | `Bimodal.Automation.DatasetValidator` | conformance report |
| `proof_extractor` | `Bimodal.Automation.ProofStepExport` | `data/proof_steps.jsonl` |
| `benchmark_anchors` | `Bimodal.Automation.BenchmarkAnchors` | `data/axiom-instances.jsonl` |
| `benchmark_oracle` | `Bimodal.Automation.BenchmarkOracle` | validated benchmark JSONL |

The `dataset_generator` and `proof_extractor` are the two relevant to the sync pipeline.

#### BimodalLogic: Current Data Directory

`data/` contains the following JSONL files already produced:
- `bmlogic-c5.jsonl`, `bmlogic-c5_metadata.json`
- `bmlogic-c7.jsonl`, `bmlogic-c7_metadata.json`
- `proof_steps.jsonl`, `proof_steps_metadata.json`
- `axiom-instances.jsonl`, `bmlogic-bench.jsonl`, `bmlogic-bench-validated.jsonl`

The `proof_steps.jsonl` file is current (10,063 lines validated as of 2026-06-01 per comments in `ProofStepExport.lean`).

#### BimodalLogic: Existing Scripts

`scripts/run_dataset_generation.sh` is a comprehensive production script covering:
- c5, c7, c9, c11 complexity tiers
- `--dry-run` mode
- Post-run JSON validation (first/last line checks)
- Prerequisite checks (binary existence)

There is **no** `scripts/export-training-data.sh` yet. The new script should wrap both `dataset_generator` and `proof_extractor`, perform schema validation, and write `data/VERSION`.

#### BimodalHarness: Current State

- `data/bimodal/` directory **does not exist** (the sync has never been run)
- `data/VERSION` file exists with `SYNC_DATE=not-yet-synced` and `SCHEMA_VERSION=1`
- `Makefile` has `make sync-data` (basic rsync from `../BimodalLogic/data/` to `./data/bimodal/`) and `make validate-data` (calls `scripts/validate-data.py` which uses the legacy `load_jsonl()` path)
- `src/bimodal_harness/data/ingestion.py` has `load_lean_jsonl()` (Layer 2) and `load_proof_steps()` (Layer 3) — both fully implemented
- `src/bimodal_harness/schema/actions.py` defines the 49-action space (indices 0-48) plus 33 derived rules (indices 49-81)

#### The 49-Action Space

The action space is partitioned as:
- Indices 0-41: 42 axiom constructors (AXIOM_ACTIONS) — layers 1-8 matching `Axiom.toName` in Lean
- Indices 42-48: 7 inference rules (RULE_ACTIONS): `axiom`, `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`, `weakening`

Note: `action_index` for rule "axiom" is determined by `axiom_name` (the specific axiom constructor, indices 0-41), not by the rule name itself. For all other rules, the rule name maps directly to indices 42-48.

### Schema Gap Analysis: proof_extractor vs load_proof_steps()

The Lean `proof_extractor` currently emits these 8 fields per step:

```json
{
  "theorem_name": "identity",
  "step_index": 0,
  "context": [],
  "goal": {"tag": "imp", "left": {...}, "right": {...}},
  "rule": "modus_ponens",
  "axiom_name": null,
  "subgoals": [...],
  "frame_class": "Base"
}
```

The `ProofStepRecord.from_dict()` in BimodalHarness requires 12 fields:

| Field | Status | Gap resolution |
|---|---|---|
| `step_id` | **MISSING** | Generate as `f"{theorem_name}/{step_index}"` |
| `theorem_name` | Present | Maps directly |
| `context` | Present | Needs prettyprint conversion (currently JSON trees, harness wants strings) |
| `goal_json` | **MISSING** (field is named `goal`) | Rename field |
| `goal_pretty` | **MISSING** | Derive from `goal` via `Formula.prettyPrint` |
| `rule` | Present | Maps directly |
| `axiom_name` | Present | Maps directly |
| `action_index` | **MISSING** | Compute via `step_to_action_index(rule, axiom_name)` |
| `subgoals` | Present | Type is list of Formula JSON, matches |
| `depth` | **MISSING** | Track during tree traversal (not currently tracked) |
| `frame_class` | Present | Maps directly |
| `proof_height` | **MISSING** | Compute from tree structure |

**Four fields need to be added to the Lean `ProofStep` struct and `extractStepSequence`**:
- `step_id` (derived, trivial to add)
- `goal_pretty` (Formula.prettyPrint already exists in DataExport.lean)
- `action_index` (requires computing axiom-to-index mapping in Lean, or Python-side injection)
- `depth` (requires passing depth counter through extractStepSequence)
- `proof_height` (requires a pre-pass to compute tree height, or post-processing)

**Alternative approach**: Add a Python-side adapter in BimodalHarness's `load_proof_steps()` that tolerates the 8-field format and computes/defaults the missing fields. This is simpler and avoids modifying Lean code.

The `context` field in the Lean output contains Formula JSON trees; the harness `context` field expects strings (prettyprint). The `contextToJson` in Lean currently serializes to JSON array of formula JSON objects. The harness deserialization code does `tuple(str(c) for c in data.get("context", []))` which will produce stringified JSON objects, not pretty-printed strings. This is a latent compatibility issue.

### Schema Gap Analysis: dataset_generator vs load_lean_jsonl()

The `load_lean_jsonl()` adapter is already designed to handle the `dataset_generator` output format. Key mappings it handles:
- `id` -> `record_id`
- `formula_ast` -> `formula_json`
- `formula_str` -> `formula_pretty`
- `pattern_key` camelCase -> PatternKey fields
- `metrics` camelCase -> DifficultyMetrics fields
- Both `rules_applied` list and `rules` dict formats for ProofTrace

The existing data files (`bmlogic-c5.jsonl`, `bmlogic-c7.jsonl`) should be consumable by `load_lean_jsonl()` with no changes.

### BimodalHarness: Missing make verify-data Target

The Makefile has `validate-data` (calls old `load_jsonl()` schema) but no `verify-data`. A new `verify-data` target should:
1. Call `load_lean_jsonl()` on `data/bimodal/bmlogic-c5.jsonl` (or all `bmlogic-*.jsonl` files)
2. Call `load_proof_steps()` on `data/bimodal/proof_steps.jsonl`
3. Verify record counts and action index coverage

### BimodalHarness: Enhanced make sync-data

The current `sync-data` target is minimal (rsync + manual instruction to update VERSION). Enhancement needed:
1. Schema compatibility check: read `BimodalLogic/data/VERSION` (does not exist yet) and compare `SCHEMA_VERSION`
2. 49-action-space check: verify proof_steps.jsonl was generated with 42-axiom Lean build
3. Update `data/VERSION` with `BIMODAL_LOGIC_COMMIT` and `SYNC_DATE` automatically

---

## Decisions

1. **Two-phase gap closure**: The `proof_steps.jsonl` schema gap (missing 4 fields) should be resolved by a Python-side adapter in BimodalHarness rather than modifying the Lean ProofStep struct — this avoids a lake build dependency and is consistent with how `load_lean_jsonl()` already handles the `dataset_generator` gap.

2. **BimodalLogic VERSION file**: Create `data/VERSION` (parallel to BimodalHarness `data/VERSION`) that records `SCHEMA_VERSION`, `LEAN_VERSION`, `EXPORT_DATE`, and git commit. Written by `export-training-data.sh`.

3. **Validation approach**: Use `scripts/validate_datasets.py` (already exists in BimodalLogic) as a model for the export-side validation step. For the harness side, `load_lean_jsonl()` + `load_proof_steps()` provide the validation via their strict deserialization.

4. **Sync direction**: BimodalLogic → BimodalHarness only (one-way). BimodalHarness `data/bimodal/` is treated as a read-only mirror; no back-sync.

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| `proof_steps.jsonl` incompatible with `load_proof_steps()` due to missing `step_id`, `action_index`, `depth`, `proof_height` | High | Add Python adapter in BimodalHarness OR add fields to Lean ProofStep; both are tractable |
| `context` field format mismatch (JSON objects vs prettyprinted strings) | Medium | Harness code does `str(c)` which serializes JSON — add explicit prettyprint path |
| BimodalHarness action index 49-81 (derived rules) not present in Lean | Low | Derived rules only apply in Python-side MCTS; Lean exports primitive rules only; no conflict |
| `data/bimodal/` rsync including non-training files (benchmark data, croissant.json) | Low | Use `--include='bmlogic*.jsonl' --include='proof_steps.jsonl'` filter in sync |
| Schema drift (future Lean changes break Python readers) | Medium | Document SCHEMA_VERSION bump protocol in both repos; existing VERSION contract already specifies this |
| `make sync-data` without `BIMODAL_LOGIC_PATH` set defaults to `../BimodalLogic` | Low | Works if repos are siblings; document alternative |

---

## What Needs To Be Built

### BimodalLogic Side

1. **`scripts/export-training-data.sh`** (new file, ~150 lines):
   - Build `dataset_generator` and `proof_extractor` binaries if stale (`lake build dataset_generator proof_extractor`)
   - Run `dataset_generator` for c5 (and optionally c7) tiers
   - Run `proof_extractor --output data/proof_steps.jsonl`
   - Run `dataset_validator` on output
   - Validate JSON format of all output files
   - Write `data/VERSION` with `SCHEMA_VERSION=1`, `LEAN_VERSION`, `EXPORT_DATE`, git commit hash
   - Support `--dry-run` flag

### BimodalHarness Side

2. **`make sync-data` enhancement** (Makefile modification):
   - After rsync, read `$(LOCAL_DATA)/VERSION` and validate `SCHEMA_VERSION` matches `data/VERSION`
   - Run `scripts/validate-action-space.py` (or inline check) verifying proof_steps.jsonl contains rules from the 49-action space
   - Auto-update `data/VERSION` fields `BIMODAL_LOGIC_COMMIT` and `SYNC_DATE`
   - Create `data/bimodal/` if missing

3. **`make verify-data`** (new Makefile target, calls new `scripts/verify-data.py`):
   - Load all `data/bimodal/bmlogic-*.jsonl` via `load_lean_jsonl()`
   - Load `data/bimodal/proof_steps.jsonl` via `load_proof_steps()` (with `validate_action_index=True`)
   - Print statistics: record counts, action index coverage, rule distribution
   - Exit non-zero on any validation error

4. **Python adapter for proof step schema gap** (modify `ingestion.py` or add adapter):
   - Handle the 8-field format emitted by current `proof_extractor`
   - Compute `step_id` as `f"{theorem_name}/{step_index}"`
   - Compute `action_index` via `step_to_action_index(rule, axiom_name)`
   - Default `depth` to `step_index` (approximate) or 0
   - Default `proof_height` to 0 (unknown without full tree)
   - Convert `goal` field to `goal_json` + `goal_pretty` (using `formula_json_to_pretty`)
   - Convert `context` JSON objects to prettyprinted strings

### Documentation

5. **`docs/training/SYNC_PROTOCOL.md`** in BimodalLogic (new file, ~50 lines):
   - Step-by-step sync instructions for both automated (`export-training-data.sh`) and manual paths
   - SCHEMA_VERSION bump protocol
   - Link to BimodalHarness `data/VERSION`

---

## Context Extension Recommendations

- **Topic**: Cross-repo sync protocol
- **Gap**: No `.claude/context/` entry documents the BimodalLogic → BimodalHarness sync protocol, VERSION file format, or the proof step schema gap
- **Recommendation**: After implementation, create `.claude/context/project/sync-protocol.md` summarizing the sync flow, VERSION contract, and known schema mismatches

---

## Appendix

### Search Queries Used
- `lakefile.lean` for executable targets
- `Theories/Bimodal/Automation/` for all automation Lean files
- `BimodalHarness` keyword grep across all source files
- `ProofStepExtractor.lean`, `ProofStepExport.lean` for schema details
- `BimodalHarness/src/bimodal_harness/schema/records.py` for ProofStepRecord schema
- `BimodalHarness/src/bimodal_harness/data/ingestion.py` for load_lean_jsonl() and load_proof_steps()
- `BimodalHarness/Makefile` for existing targets
- `BimodalHarness/data/VERSION` for current SYNC_DATE and SCHEMA_VERSION

### Key File Paths

| Path | Purpose |
|---|---|
| `/home/benjamin/Projects/BimodalLogic/lakefile.lean` | Executable targets |
| `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Automation/ProofStepExtractor.lean` | ProofStep struct + extractStepSequence |
| `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Automation/ProofStepExport.lean` | proof_extractor entry point (310 theorems, 10063 steps) |
| `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Automation/DatasetExport.lean` | dataset_generator entry point |
| `/home/benjamin/Projects/BimodalLogic/data/proof_steps.jsonl` | Current proof steps output (10,063 lines) |
| `/home/benjamin/Projects/BimodalLogic/scripts/run_dataset_generation.sh` | Model for export script |
| `/home/benjamin/Projects/BimodalHarness/Makefile` | sync-data and validate-data targets |
| `/home/benjamin/Projects/BimodalHarness/data/VERSION` | SCHEMA_VERSION=1, SYNC_DATE=not-yet-synced |
| `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/data/ingestion.py` | load_lean_jsonl(), load_proof_steps() |
| `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/schema/records.py` | ProofStepRecord (12 required fields) |
| `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/schema/actions.py` | step_to_action_index(), 49-action space |
