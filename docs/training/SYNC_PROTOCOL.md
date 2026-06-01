# BimodalLogic → BimodalHarness Sync Protocol

**Direction**: One-way, BimodalLogic exports → BimodalHarness imports  
**Audience**: Operators maintaining both repositories

---

## Overview

BimodalLogic is the canonical source for training data. BimodalHarness consumes
that data for neural proof search training. The sync pipeline uses two scripts:

1. **BimodalLogic**: `scripts/export-training-data.sh` — generates JSONL files and
   writes `data/VERSION`
2. **BimodalHarness**: `make sync-data` — rsyncs data files into `data/bimodal/`
   and reads `data/VERSION` for tracking

The BimodalHarness `data/bimodal/` directory is a read-only mirror. No data flows
back from BimodalHarness to BimodalLogic.

---

## Step-by-Step Sync Instructions

### 1. Export data from BimodalLogic

```bash
# Standard export: c5 dataset + all proof steps
./scripts/export-training-data.sh c5

# Or to regenerate both c5 and c7
./scripts/export-training-data.sh all

# Dry-run to preview commands without executing
./scripts/export-training-data.sh --dry-run c5
```

The script:
- Checks that `dataset_generator` and `proof_extractor` binaries are present
- Runs `lake exe dataset_generator` for the requested tier
- Runs `lake exe proof_extractor` (no tier argument)
- Validates all JSONL output (line count > 0, first/last lines are valid JSON)
- Writes `data/VERSION` with schema version, git commit, and export timestamp

After the script completes, verify `data/VERSION` is current:

```bash
cat data/VERSION
```

### 2. Sync data to BimodalHarness

From the BimodalHarness repository root (assumes repos are siblings):

```bash
make sync-data
```

Or if BimodalLogic is at a non-standard path:

```bash
BIMODAL_LOGIC_PATH=/path/to/BimodalLogic make sync-data
```

The `sync-data` target rsyncs `bmlogic-*.jsonl` and `proof_steps.jsonl` into
`data/bimodal/` and copies `data/VERSION`.

### 3. Verify data in BimodalHarness

```bash
# If available:
make verify-data
```

This runs `load_lean_jsonl()` on the dataset files and `load_proof_steps()` on
proof steps. Note that `load_proof_steps()` requires the Python-side adapter
(see schema gap section below) before it will succeed.

---

## `data/VERSION` File Format

Both BimodalLogic and BimodalHarness maintain a `data/VERSION` file. The format
is a flat key=value file (shell-sourceable).

### Fields

| Field | Type | Description |
|---|---|---|
| `SCHEMA_VERSION` | Integer | Schema version. Increment on breaking changes (see below). |
| `LEAN_VERSION` | String | Lean 4 toolchain version (from `lean-toolchain`). |
| `EXPORT_DATE` | ISO 8601 | UTC timestamp of last export run. |
| `GIT_COMMIT` | String | Short git commit hash of BimodalLogic at export time. |
| `DATASET_TIERS` | String | Comma-separated tiers exported (e.g., `c5`, `c5,c7`). |
| `PROOF_STEPS_COUNT` | Integer | Number of lines in `proof_steps.jsonl`. |

### Example

```
SCHEMA_VERSION=1
LEAN_VERSION=v4.27.0-rc1
EXPORT_DATE=2026-06-01T00:00:00Z
GIT_COMMIT=60c440244
DATASET_TIERS=c5,c7
PROOF_STEPS_COUNT=10063
```

### SCHEMA_VERSION Bump Protocol

Increment `SCHEMA_VERSION` when:
- A field is removed from any JSONL output
- A field is renamed (without backward-compatible alias)
- The type or semantics of an existing field changes incompatibly

Do **not** bump `SCHEMA_VERSION` when:
- A new optional field is added to JSONL output
- Record counts change
- A new tier is added (e.g., c9, c11)

When bumping, update in both repositories:
1. Update `ProofStepExtractor.lean` or `DatasetExport.lean` (BimodalLogic)
2. Update `data/VERSION` (written automatically by `export-training-data.sh`)
3. Update the Python adapter in BimodalHarness `ingestion.py`
4. Update BimodalHarness `data/VERSION` `SCHEMA_VERSION` field
5. Document the breaking change in both repos' CHANGELOG

---

## Schema Gap: proof_extractor (8 fields) vs load_proof_steps() (12 fields)

**Status**: Known gap. Recommend Python-side adapter in BimodalHarness.

The Lean `proof_extractor` currently emits 8 fields per proof step:

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

The BimodalHarness `load_proof_steps()` / `ProofStepRecord.from_dict()` requires
12 fields. Missing fields and recommended resolutions:

| Missing Field | Recommended Resolution |
|---|---|
| `step_id` | Generate as `f"{theorem_name}/{step_index}"` |
| `goal_json` | Rename from `goal` field |
| `goal_pretty` | Derive from `goal` JSON via `formula_json_to_pretty()` |
| `action_index` | Compute via `step_to_action_index(rule, axiom_name)` from `actions.py` |
| `depth` | Default to `step_index` (approximate) or 0 |
| `proof_height` | Default to 0 (unknown without full tree traversal) |

Additional compatibility note: the `context` field in Lean output contains
Formula JSON trees, but `load_proof_steps()` expects prettyprinted strings.
The adapter should convert `context` entries via `formula_json_to_pretty()`.

### Recommended Adapter Location

Add an adapter function in BimodalHarness:
`src/bimodal_harness/data/ingestion.py` → `_adapt_proof_step_v1(record: dict) -> dict`

Call this adapter inside `load_proof_steps()` when `step_id` is absent from the
record (indicating v1 Lean output).

---

## The 49-Action Space

The action index space is fully aligned between repositories:

| Index Range | Category | Count | Source |
|---|---|---|---|
| 0–41 | Axiom constructors (AXIOM_ACTIONS) | 42 | `Axiom.toName` in Lean |
| 42–48 | Inference rules (RULE_ACTIONS) | 7 | Hardcoded in both repos |
| 49–81 | Derived rules (Python MCTS only) | 33 | BimodalHarness `actions.py` only |

The 7 inference rule names (indices 42–48):
`axiom`, `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`,
`temporal_duality`, `weakening`

Note: for a step with `"rule": "axiom"`, `action_index` is determined by
`axiom_name` (the specific axiom constructor, index 0–41), not by rule "axiom"
itself (which would be index 42).

---

## BimodalHarness Follow-Up Checklist

The following work is needed in the BimodalHarness repository (not implemented here):

- [ ] **Python adapter**: Add `_adapt_proof_step_v1()` in `ingestion.py` to bridge
  the 8-field → 12-field gap (see schema gap section above)
- [ ] **`make sync-data` enhancement**: After rsync, read `$(LOCAL_DATA)/VERSION`
  and compare `SCHEMA_VERSION` to detect incompatible exports before sync
- [ ] **`make verify-data` target**: New Makefile target that runs `load_lean_jsonl()`
  on all `bmlogic-*.jsonl` files and `load_proof_steps()` on `proof_steps.jsonl`
- [ ] **Auto-update VERSION fields**: `make sync-data` should automatically update
  `BIMODAL_LOGIC_COMMIT` and `SYNC_DATE` fields in `data/VERSION`
- [ ] **Create `data/bimodal/` directory**: The target directory for rsync does not
  yet exist; `make sync-data` should `mkdir -p` it

---

## Troubleshooting

**Export script fails with "binary not found"**  
Run `lake build dataset_generator proof_extractor` first. This takes a few minutes
on a clean build.

**`load_proof_steps()` raises KeyError on `step_id` or `goal_json`**  
The Python-side adapter has not been applied. See schema gap section above.

**`make sync-data` uses wrong source path**  
Set `BIMODAL_LOGIC_PATH=/absolute/path/to/BimodalLogic` before calling `make sync-data`.

**`data/VERSION` shows `EXPORT_DATE` from the past**  
Re-run `./scripts/export-training-data.sh` to regenerate all files and refresh VERSION.
