# Research Report: Task #227

**Task**: 227 - Dataset Pipeline Automation + Croissant Sync Infrastructure
**Started**: 2026-05-30T17:00:00Z
**Completed**: 2026-05-30T17:30:00Z
**Effort**: 30 minutes (moderate — codebase-only, no web research needed)
**Dependencies**: None
**Sources/Inputs**:
- `data/` directory (all files, sizes, schemas)
- `data/croissant.json` (full structure)
- `data/bmlogic-bench_metadata.json`
- `data/bmlogic-bench-splits.json`
- `data/README.md`
- `data/hf-dataset/README.md` (YAML frontmatter)
- `data/hf-dataset/validate.py`
- `scripts/finalize_benchmark.py`
- `data/scripts/generate_splits.py`
- `.claude/agents/lean-implementation-agent.md`
- `.claude/agents/general-implementation-agent.md`
- `.claude/extensions/lean/manifest.json`
- `.claude/context/index.json`
- `lakefile.lean` (benchmark executables)
**Artifacts**:
- `specs/227_dataset_pipeline_automation_croissant_sync/reports/01_dataset-pipeline-research.md`
**Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

---

## Executive Summary

- `data/bmlogic-bench.jsonl` grew from 727 to **777 records** (task 220) but `croissant.json` still records the old SHA-256 hash, `668 KB` size, and **727-record count** — it is stale on all three dimensions for this one file
- `bmlogic-bench-splits.json` records **727 total_records** and must be regenerated from the 777-record benchmark using `data/scripts/generate_splits.py`; the file itself exists but is stale
- `data/hf-dataset/validate.py` hardcodes `727` as the expected benchmark count and needs updating to `777`; it does not validate SHA-256 hashes or croissant.json at all
- **No existing SHA-256 sync script exists** — `scripts/finalize_benchmark.py` writes only `bmlogic-bench.jsonl` and `bmlogic-bench_metadata.json`; no script currently touches `croissant.json` or computes hashes
- The croissant.json **benchmark schema** declares 15 fields (including `nl_paraphrase` + `nl_paraphrase_method`) but the actual JSONL has 14 fields — the two NL paraphrase fields are absent; `axiom_name` is present in the actual data but not in the croissant schema
- The best integration point for automated sync is a **dedicated `scripts/sync-dataset-artifacts.sh`** called as a final step in `scripts/finalize_benchmark.py` invocations, with documentation in a new `.claude/context/project/` entry that the lean-implementation-agent and general-implementation-agent can load

---

## Context & Scope

This research covers four areas: (1) the complete dataset artifact inventory in `data/`, (2) existing pipeline scripts and what they do/don't update, (3) agent/skill integration points for wiring in sync automation, and (4) croissant.json correctness and validation tooling.

The project is a Lean 4 formalization of bimodal logic with an associated ML benchmark dataset (`BMLogic-Bench`). The `data/` directory holds JSONL datasets, metadata JSON files, a Croissant 1.0 metadata file, and a HuggingFace dataset card. After task 220 expanded `bmlogic-bench.jsonl` from 727 to 777 records, several downstream artifacts were not updated.

---

## Findings

### Area 1: Dataset Artifact Inventory

**Files in `data/` and their current state:**

| File | Actual Size | Actual Records | Purpose | LFS |
|------|-------------|----------------|---------|-----|
| `bmlogic-bench.jsonl` | 766 KB | **777** | Evaluation benchmark | No |
| `bmlogic-c5.jsonl` | 1.4 MB | 1,513 | Training complexity-5 | No |
| `bmlogic-c7.jsonl` | ~52 MB | 49,904 | Training complexity-7 | Yes |
| `proof_steps.jsonl` | ~15 MB | 2,424 | Proof step supervision | Yes |
| `axiom-instances.jsonl` | ~136 KB | 110 | Benchmark anchor inputs | No |
| `bmlogic-bench-candidates.jsonl` | ~1.8 MB | 1,950 | Pipeline intermediate | No |
| `bmlogic-bench-validated.jsonl` | ~2 MB | 1,950 | Pipeline intermediate | No |
| `bmlogic-bench_metadata.json` | 1.2 KB | — | Benchmark stats | No |
| `bmlogic-bench-splits.json` | 23 KB | — | Cross-logic split metadata | No |
| `croissant.json` | 22.8 KB | — | MLCommons Croissant 1.0 | No |
| `dataset-card.md` | 15 KB | — | HF dataset card (backup) | No |

**`data/README.md`**: Present and comprehensive. Documents file inventory, generation commands, and NL paraphrase fields. However, the File Inventory table still shows `bmlogic-bench.jsonl` as `727 records` (line 15) despite task 220. Also claims SHA-256 hashes are "populated" in croissant.json (line 117) — this is true for the hash values, but they are stale for bmlogic-bench.jsonl.

**`data/hf-dataset/README.md` YAML frontmatter**: Correct structure with 4 configs (`default`, `bmlogic-c5`, `bmlogic-c7`, `proof-steps`). No record counts in frontmatter — count is embedded only in the card body text (which says 727).

#### Croissant.json Staleness Analysis

| Distribution | Croissant SHA-256 | Actual SHA-256 | Croissant Size | Actual Size | Status |
|---|---|---|---|---|---|
| `bmlogic-c5.jsonl` | `6baa29...` | `6baa29...` | 1.4 MB | 1.4 MB | **CORRECT** |
| `bmlogic-c7.jsonl` | `48358a...` | (LFS, not checked) | 52 MB | ~52 MB | assumed correct |
| `bmlogic-bench.jsonl` | `6ce78a...` | **`170e08...`** | **668 KB** | **766 KB** | **STALE** |
| `proof_steps.jsonl` | `c460c3...` | `c460c3...` | 14.7 MB | ~15 MB | **CORRECT** |
| `bmlogic-bench-splits.json` | `cbf80a...` | `cbf80a...` | `< 1 MB` | 23 KB | **CORRECT** |

**Critical**: Only `bmlogic-bench.jsonl` has a stale hash. The SHA-256 was `6ce78a...` (old 727-record file) but is now `170e08...` (777-record file). The contentSize `668 KB` is stale; actual is 766 KB.

#### Croissant Schema vs Actual JSONL Field Mismatch

The croissant.json `benchmark-schema-v1` RecordSet declares **15 fields**. The actual `bmlogic-bench.jsonl` has **14 fields**:

| Field | In Croissant | In Actual JSONL | Status |
|-------|--------------|-----------------|--------|
| `id` | Yes | Yes | OK |
| `split` | Yes | Yes | OK |
| `formula_str` | Yes | Yes | OK |
| `formula_ast` | Yes | Yes | OK |
| `frame_class` | Yes | Yes | OK |
| `label` | Yes | Yes | OK |
| `proof_trace` | Yes | Yes | OK |
| `countermodel` | Yes | Yes | OK |
| `pattern_key` | Yes | Yes | OK |
| `metrics` | Yes | Yes | OK |
| `source` | Yes | Yes | OK |
| `difficulty_tier` | Yes | Yes | OK |
| `benchmark_category` | Yes | Yes | OK |
| `nl_paraphrase` | **Yes** | **No** | **MISMATCH** |
| `nl_paraphrase_method` | **Yes** | **No** | **MISMATCH** |
| `axiom_name` | **No** | **Yes** | **UNDOCUMENTED** |

The `nl_paraphrase` and `nl_paraphrase_method` fields were added to croissant.json anticipating task 216 (NL paraphrase generation) but were never written to the JSONL. `axiom_name` is present in all 777 records of the actual JSONL but not documented in the croissant schema.

The `bmlogic-bench_metadata.json` correctly reflects the current state: `total_count: 777`, generated `2026-05-30T16:56:30`. It is **up to date**.

#### bmlogic-bench-splits.json Staleness

`bmlogic-bench-splits.json` records `total_records: 727` and was generated `2026-05-29`. After task 220 grew the benchmark to 777 records, this file is stale — the split stats (propositional-only: 97, modal-only: 144, temporal-only: 247, bimodal: 239 = 727 total) do not reflect the full 777-record set. The regeneration script exists at `data/scripts/generate_splits.py`.

---

### Area 2: Existing Pipeline Scripts

**Benchmark generation pipeline (full):**
```
lake exe benchmark_anchors      -> data/axiom-instances.jsonl
python scripts/curate_benchmark.py ... -> data/bmlogic-bench-candidates.jsonl
lake exe benchmark_oracle       -> data/bmlogic-bench-validated.jsonl
python scripts/finalize_benchmark.py -> data/bmlogic-bench.jsonl + data/bmlogic-bench_metadata.json
```

**What `scripts/finalize_benchmark.py` does:**
- Reads `data/bmlogic-bench-validated.jsonl`
- Performs stratified sampling, deduplication, axiom anchor coverage
- Writes `data/bmlogic-bench.jsonl` with sequential IDs
- Writes `data/bmlogic-bench_metadata.json` with statistics
- Does NOT update: `croissant.json`, `bmlogic-bench-splits.json`, `data/README.md`, `data/hf-dataset/README.md`, or HF validate expected counts

**What `data/scripts/generate_splits.py` does:**
- Reads `data/bmlogic-bench.jsonl`
- Classifies records into 4 logic-fragment slices
- Writes `data/bmlogic-bench-splits.json` with stats

**What `data/hf-dataset/validate.py` does:**
- Validates YAML frontmatter in README.md
- Checks JSONL files exist and field schemas match
- Checks record counts against **hardcoded 727** — will fail at 777
- Does NOT check SHA-256 hashes
- Does NOT validate croissant.json

**Scripts that currently exist for SHA-256/croissant update:** None. There is no `sync-dataset-artifacts.sh` or equivalent. SHA-256 computation and croissant.json update are entirely manual.

**Available tools:** `sha256sum` (system), `python3` (3.12.13), `jq` (installed). `mlcroissant` CLI is documented as unusable on NixOS due to libstdc++ issues — confirmed constraint.

---

### Area 3: Agent/Skill Integration Points

**Agent system structure relevant to integration:**

The `.claude/extensions/lean/manifest.json` has an empty `hooks` object — no lifecycle hooks are currently registered. The lean extension provides `skill-lean-implementation` which routes to `lean-implementation-agent.md`.

**lean-implementation-agent.md**: Uses `model: opus`. Contains workflow for Lean proof development. Has a `## Phase Status Updates` section. No mention of benchmark-related post-steps.

**general-implementation-agent.md**: Uses `model: sonnet`. Generic implementation agent. No benchmark-specific steps.

**Integration options evaluated:**

1. **Extension lifecycle hook** (manifest `hooks` field): Hooks run via `skill-base.sh` at lifecycle stages. The lean extension manifest has `"hooks": {}` — this would require writing a shell script and registering it as a `postflight` hook. This would run after every lean implementation task, which is too broad — most lean tasks don't involve benchmark regeneration.

2. **Agent context file** (`.claude/context/project/lean4/` or a new `project/dataset/`): A context file loadable by agents that documents the sync requirement. This requires agents to know to load it — requires index.json entry with appropriate `load_when` conditions.

3. **Benchmark-specific rule file** (`.claude/rules/benchmark-sync.md`): A rule file with path-based triggering. However, benchmark regeneration tasks use task types `general` or `lean4` — no specific file path pattern reliably identifies benchmark regeneration tasks.

4. **Post-implementation step in plan templates**: When `/plan` creates an implementation plan for benchmark-related tasks, the plan template could include a final "Sync Artifacts" phase. The planner-agent reads context files, so a context file with a note like "any task involving benchmark regeneration must include a sync phase" would work if loaded.

5. **Standalone sync script with documentation in `data/README.md`**: A `scripts/sync-dataset-artifacts.sh` script that developers (and agents) can run after benchmark regeneration. The lean-implementation-agent docs would reference this script. Most reliable and least fragile.

**Recommended approach** (see Decisions section): Combination of options 2 and 5 — create the sync script, document it in `data/README.md`, and add a context file entry that plan templates can load. This is more reliable than lifecycle hooks because benchmark regeneration is not every task.

**Context index pattern**: The `.claude/context/index.json` uses `load_when.task_types`, `load_when.agents`, and `load_when.commands` selectors. A new context entry for `task_type: lean4` or `task_type: general` with keywords about "benchmark" would require the planner-agent to conditionally include sync steps.

---

### Area 4: Croissant JSON-LD Validation

**Structural analysis of current `data/croissant.json`:**

- `@context`: Correct — includes all required Croissant 1.0 term mappings (`cr:`, `sc:`, `dct:`)
- `dct:conformsTo`: Correctly uses Dublin Core Terms prefix (`dct:conformsTo`: `"http://mlcommons.org/croissant/1.0"`) — not `cr:` which would be wrong
- `cr:distribution`: 5 distributions with `@type: cr:FileObject`; all have `sc:sha256` fields populated (but `bmlogic-bench.jsonl` entry is stale)
- `cr:recordSet`: 3 record sets (`training-schema-v2`, `benchmark-schema-v1`, `proof-steps-schema`) with field definitions
- `cr:task`: 2 task definitions (provability classification, proof step prediction)
- JSON is syntactically valid (confirmed)

**mlcroissant validation constraint**: The `mlcroissant` CLI cannot be installed on NixOS due to libstdc++ dependency issues. `data/README.md` already documents this. Alternative: `python3 -c "import json; json.load(open('data/croissant.json')); print('Valid JSON')"` for structural check. A `jq` walk can verify all required keys are present.

**jq-based structural validation** is sufficient for CI/developer use:
```bash
jq -e '
  has("@context") and has("cr:distribution") and has("cr:recordSet") and
  (."cr:distribution" | length > 0) and
  (."cr:distribution"[] | has("sc:sha256") and has("contentSize") and has("contentUrl"))
' data/croissant.json
```

---

## Decisions

1. **bmlogic-bench.jsonl schema in croissant.json**: The `nl_paraphrase` and `nl_paraphrase_method` fields should be **removed** from the croissant schema (not present in actual data) and `axiom_name` should be **added** (present in actual data). This makes the schema match reality. The field count becomes 15 (with `axiom_name`) if we decide to document it, or 14 if we keep it as an undocumented internal field. Given `axiom_name` is used in benchmark evaluation (identifying semantic coverage), it should be documented.

2. **bmlogic-bench-splits.json regeneration**: Must be regenerated from the 777-record benchmark. The existing `data/scripts/generate_splits.py` handles this. The sync script should call it automatically.

3. **SHA-256 hashes in contentSize**: Use `sha256sum` (GNU coreutils) for hash computation — available on NixOS. Size should be in human-readable form (e.g., `"766 KB"`) matching the existing conventions. Alternatively use bytes (e.g., `"783947"`) for machine precision.

4. **data/hf-dataset/validate.py EXPECTED_COUNTS**: Update `"bmlogic-bench": 727` to `"bmlogic-bench": 777`. This is a one-line fix but must be done as part of the sync.

5. **Integration point for agent automation**: A new context file `data/README-benchmark-sync.md` (or similar) should be added as a `.claude/context/project/dataset/` entry, plus documentation in `data/README.md`. The lean-implementation-agent already has a section on "Post-Implementation Steps" that can reference the sync script.

---

## Recommendations

### Priority 1: Fix Immediate Staleness (can be scripted as one-shot)

1. **Update `croissant.json` for `bmlogic-bench.jsonl`**:
   - SHA-256: change from `6ce78a...` to `170e086e916c078edff00bb0f1ee47ab001e6ca9a09012ff3a25c5648a53df3b`
   - contentSize: change from `"668 KB"` to `"766 KB"`
   - description: update from `"727 held-out records"` to `"777 held-out records"`
   - RecordSet `benchmark-schema-v1`: remove `nl_paraphrase` and `nl_paraphrase_method` fields; add `axiom_name` field

2. **Regenerate `bmlogic-bench-splits.json`**:
   ```bash
   python data/scripts/generate_splits.py
   ```

3. **Update `data/README.md`** File Inventory table: `bmlogic-bench.jsonl` row → 777 records, ~766 KB

4. **Update `data/hf-dataset/validate.py`** `EXPECTED_COUNTS`: `"bmlogic-bench": 777`

5. **Update `data/hf-dataset/README.md`** body text: anywhere it says 727 records

### Priority 2: Create Deterministic Sync Script

Create `scripts/sync-dataset-artifacts.sh` with these operations in sequence:

```bash
#!/usr/bin/env bash
# Sync all downstream dataset artifacts after benchmark regeneration
set -euo pipefail

# 1. Recompute SHA-256 hashes for non-LFS files
BENCH_SHA=$(sha256sum data/bmlogic-bench.jsonl | awk '{print $1}')
C5_SHA=$(sha256sum data/bmlogic-c5.jsonl | awk '{print $1}')
SPLITS_SHA=$(sha256sum data/bmlogic-bench-splits.json | awk '{print $1}')
PROOF_SHA=$(sha256sum data/proof_steps.jsonl | awk '{print $1}')

# 2. Compute file sizes
BENCH_SIZE=$(du -h data/bmlogic-bench.jsonl | awk '{print $1}')

# 3. Get record count
BENCH_COUNT=$(wc -l < data/bmlogic-bench.jsonl)

# 4. Update croissant.json SHA-256 and contentSize via python
python3 scripts/update_croissant.py --bench-sha $BENCH_SHA --bench-size "$BENCH_SIZE" ...

# 5. Regenerate splits
python data/scripts/generate_splits.py

# 6. Validate croissant.json structure (jq check)
jq -e '."cr:distribution" | length > 0' data/croissant.json

# 7. Update record counts in data/README.md and validate.py

# 8. Commit with structured message
git add data/croissant.json data/bmlogic-bench-splits.json data/README.md
git commit -m "sync: dataset artifacts after benchmark regeneration (task N)"
```

A companion `scripts/update_croissant.py` handles the JSON-LD update with proper field manipulation (jq in-place JSON edits are fragile for nested structures).

### Priority 3: Wire Sync Into Agent Plans

**Option A (recommended)**: Add to `data/README.md` a new "Sync After Regeneration" section documenting the sync script as a required post-step. Add an index entry in `.claude/context/index.json` for a new `data/SYNC.md` context file loaded when task descriptions contain "benchmark" keywords.

**Option B**: Add a `## Post-Implementation: Dataset Sync` section to `lean-implementation-agent.md` and `general-implementation-agent.md` that says: "If this task involved benchmark regeneration (running `finalize_benchmark.py`), run `scripts/sync-dataset-artifacts.sh` as the final step."

Option B is simpler and more direct. Option A requires context loading machinery.

**Recommended**: Implement both — agent-level documentation (B) ensures it's in the agent's prompt, while the context file (A) is discoverable by the planner during plan creation.

### Priority 4: Document Pipeline Narrative in `data/README.md`

Add a "Dataset Pipeline Architecture" section explaining:
- What each artifact is and who produces it
- The dependency graph: `benchmark_anchors` → `curate_benchmark.py` → `benchmark_oracle` → `finalize_benchmark.py` → `sync-dataset-artifacts.sh`
- What `sync-dataset-artifacts.sh` keeps in sync
- What git history tracks (use `git log --oneline -- data/bmlogic-bench.jsonl` to see change history)

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| SHA-256 of bmlogic-c7.jsonl cannot be verified locally (LFS) | Medium | Document that LFS files' hashes must be updated manually after `git lfs pull` |
| mlcroissant validator unavailable on NixOS | Medium | Use jq structural validation as documented; SHA-256 comparison is independent of mlcroissant |
| sync script runs `git commit` automatically | Low | Make commit step opt-in with `--commit` flag; default is no commit |
| jq in-place JSON edit corrupts croissant.json | High | Use Python (`json.load`/`json.dump`) for JSON manipulation — safer for nested structure |
| validate.py EXPECTED_COUNTS becomes stale again | Medium | Have `sync-dataset-artifacts.sh` also patch `validate.py` counts using sed or python |
| Agent context entry not loaded for relevant tasks | Medium | Document sync requirement directly in agent definition files (most reliable) |

---

## Appendix

### File Size Convention in Croissant

Current croissant.json uses informal size strings: `"1.4 MB"`, `"52 MB"`, `"14.7 MB"`, `"668 KB"`, `"< 1 MB"`. The Croissant spec allows any string for `contentSize`. Recommendation: use consistent format like `"766 KB"` (matching `du -h` output rounded) or switch to bytes `"784332"` for precision. The implementation should pick one convention and apply it consistently.

### Existing SHA-256 Values (for reference)

| File | Verified SHA-256 |
|------|-----------------|
| `bmlogic-c5.jsonl` | `6baa29afb0d044eab4d110c8a56a1f3a11d062cd4d35f9ce3c77132702104709` |
| `bmlogic-bench.jsonl` (current, 777 records) | `170e086e916c078edff00bb0f1ee47ab001e6ca9a09012ff3a25c5648a53df3b` |
| `proof_steps.jsonl` | `c460c39ef3b149aaa3da5b9d683e561bdf60691d89f6268f75a27520976f9bb7` |
| `bmlogic-bench-splits.json` (stale, 727 records) | `cbf80aa6f79d4c686341d9dbf760dafe997f72de93ffd0eb6daeb70a384d0cef` |

### Actual vs Croissant Field Counts

| Schema | Croissant | Actual | Delta |
|--------|-----------|--------|-------|
| `training-schema-v2` (c5, c7) | 14 | 14 | 0 |
| `benchmark-schema-v1` (bench) | 15 | 14 | -1 (nl_paraphrase*, nl_paraphrase_method missing; axiom_name undocumented) |
| `proof-steps-schema` | 8 | 8 | 0 |

### Benchmark Pipeline Executables (from lakefile.lean)

| Executable | Input | Output |
|-----------|-------|--------|
| `lake exe benchmark_anchors` | — | `data/axiom-instances.jsonl` |
| `python scripts/curate_benchmark.py` | `bmlogic-c5.jsonl`, `bmlogic-c7.jsonl` | `bmlogic-bench-candidates.jsonl` |
| `lake exe benchmark_oracle` | `bmlogic-bench-candidates.jsonl` | `bmlogic-bench-validated.jsonl` |
| `python scripts/finalize_benchmark.py` | `bmlogic-bench-validated.jsonl` | `bmlogic-bench.jsonl`, `bmlogic-bench_metadata.json` |
| `python data/scripts/generate_splits.py` | `bmlogic-bench.jsonl` | `bmlogic-bench-splits.json` |
| `scripts/sync-dataset-artifacts.sh` (to create) | all data files | `croissant.json`, `bmlogic-bench-splits.json`, counts in README/validate.py |
