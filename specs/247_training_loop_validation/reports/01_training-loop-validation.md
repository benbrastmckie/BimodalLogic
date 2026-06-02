# Research Report: Task #247

**Task**: 247 - training_loop_validation
**Started**: 2026-06-02T00:00:00Z
**Completed**: 2026-06-02T00:30:00Z
**Effort**: M
**Dependencies**: Tasks 201, 203, 209, 213 (BimodalLogic pipeline); BimodalHarness tasks 5, 7, 16
**Sources/Inputs**: Codebase exploration of BimodalLogic and BimodalHarness repositories
**Artifacts**: specs/247_training_loop_validation/reports/01_training-loop-validation.md
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- The complete pipeline from Lean tableau proofs to BimodalHarness training is **architecturally sound and partially functional** — data export works, sync works, and BimodalHarness ingestion is implemented. The critical blocker is a **schema gap** between `proof_extractor`'s 8-field JSONL output and `load_proof_steps()`'s 12-field expectation, which is **already documented and partially bridged** by `load_bmlogic_proof_steps()` in ingestion.py.
- All required data already exists: 10,063 proof steps across 310 theorems, 1,513 c5 formulas, and 49,904 c7 formulas are present at `/home/benjamin/Projects/BimodalLogic/data/` and synced to `/home/benjamin/Projects/BimodalHarness/data/bimodal/`.
- A smoke test script (`smoke-test-training.sh`) needs to be created; the individual components exist but are not wired into a single end-to-end validation script. The recommended approach uses the existing `load_bmlogic_proof_steps()` adapter and `ExpertIterationLoop` with a minimal 1-iteration config.

---

## Context & Scope

Task 247 targets end-to-end validation of the BimodalLogic → BimodalHarness pipeline:
- Data export from Lean tableau proofs
- Sync to BimodalHarness
- Data ingestion into Python training types
- Supervised training on proof steps
- One epoch of expert iteration
- Benchmark evaluation
- Documentation of schema mismatches

Both repos were inspected. The BimodalLogic repo is at `/home/benjamin/Projects/BimodalLogic` and BimodalHarness at `/home/benjamin/Projects/BimodalHarness`.

---

## Findings

### Codebase Patterns

#### 1. Data Export Pipeline (BimodalLogic)

The export pipeline is fully implemented with two `lake exe` targets:

**`lake exe dataset_generator`** (CLI entry point: `DatasetExport.lean`)
- Enumerates bimodal logic formulas via `FormulaEnumerator.lean`
- Labels each formula as `valid`/`invalid`/`timeout` using `DatasetGenerator.lean`
- Outputs JSONL with 11 fields per record plus a companion `_metadata.json`
- Current data: `bmlogic-c5.jsonl` (1,513 lines), `bmlogic-c7.jsonl` (49,904 lines)
- Wrapper scripts: `scripts/run_dataset_generation.sh` and `scripts/export-training-data.sh`

**`lake exe proof_extractor`** (CLI entry point: `ProofStepExtractor.lean`)
- Walks `DerivationTree` values from a hardcoded `theoremRegistry`
- Emits 8 fields per step: `theorem_name`, `step_index`, `context`, `goal`, `rule`, `axiom_name`, `subgoals`, `frame_class`
- Current data: `proof_steps.jsonl` (10,063 lines), covering 310 theorems
- Rule distribution: axiom (4,635), modus_ponens (4,325), temporal_necessitation (991), temporal_duality (63), necessitation (49)
- Missing from output: `step_id`, `goal_json`/`goal_pretty`, `action_index`, `depth`, `proof_height`

**JSONL Record Schema (dataset_generator output)**:
```json
{
  "id": "bmlogic-00001",
  "split": "train",
  "formula_str": "(□p → p)",
  "formula_ast": {"tag": "imp", "left": {"tag": "box", ...}, ...},
  "frame_class": "Base",
  "label": "valid",
  "proof_trace": {"height": 0, "axioms_used": ["modal_t"], "rules_applied": []},
  "countermodel": null,
  "pattern_key": {"modalDepth": 1, "temporalDepth": 0, "impCount": 1, "complexity": 3, "topOperator": "Implication"},
  "metrics": {"complexity": 3, "modalDepth": 1, "temporalDepth": 0, "impCount": 1, "atomCount": 1, "decisionTimeMs": 2, "difficultyTier": "easy"},
  "augmentation": null
}
```

**Proof Step Schema (proof_extractor output, 8 fields)**:
```json
{
  "theorem_name": "identity",
  "step_index": 0,
  "context": [],
  "goal": {"tag": "imp", "left": {"tag": "atom", "name": "p"}, "right": {"tag": "atom", "name": "p"}},
  "rule": "modus_ponens",
  "axiom_name": null,
  "subgoals": [...],
  "frame_class": "Base"
}
```

#### 2. BimodalHarness Project Structure

BimodalHarness is at `/home/benjamin/Projects/BimodalHarness` with Python source in `src/bimodal_harness/`. Key modules for this task:

| Module | Purpose |
|--------|---------|
| `data/ingestion.py` | JSONL -> TrainingRecord and ProofStepRecord adapters |
| `schema/records.py` | Python dataclasses: TrainingRecord, ProofStepRecord |
| `schema/actions.py` | 82-action space with AXIOM_ACTIONS (42), RULE_ACTIONS (7), DERIVED_RULE_ACTIONS (33) |
| `training/loop.py` | ExpertIterationLoop: SEARCH -> EXTRACT -> ACCUMULATE -> RETRAIN -> EVALUATE |
| `training/policy_trainer.py` | PolicyTrainer with cross-entropy loss on ProofStepRecord |
| `training/value_trainer.py` | ValueTrainer with MSE on TrainingRecord |
| `models/policy.py` | PolicyNetwork (Tree-GRU + MLP, output dim 49 primitives) |
| `models/value.py` | ValueNetwork (feature-based, input dim 12) |
| `search/best_first.py` | PythonBestFirstSearch |
| `search/mcts.py` | MCTSSearch (AlphaZero-style) |

Data currently synced to `data/bimodal/`: `bmlogic-c5.jsonl`, `bmlogic-c7.jsonl`, `proof_steps.jsonl`, `tableau_proof_steps_c5.jsonl`, `test_tableau_c5_v2.jsonl`, `test_tableau_steps.jsonl`, `bmlogic-bench.jsonl`, `bmlogic-bench-validated.jsonl`, `bmlogic-bench-candidates.jsonl`, `axiom-instances.jsonl`.

#### 3. Action Space Mapping

The action space is well-aligned between Lean and Python:

| Index Range | Category | Count | Source |
|-------------|----------|-------|--------|
| 0–41 | Axiom constructors (AXIOM_ACTIONS) | 42 | `Axiom.toName` in Lean, `actions.py` in Python |
| 42–48 | Inference rules (RULE_ACTIONS) | 7 | Hardcoded in both repos |
| 49–81 | Derived rules (Python MCTS only) | 33 | BimodalHarness `derived_rules.py` |

The 7 rule names match exactly: `axiom`, `assumption`, `modus_ponens`, `necessitation`, `temporal_necessitation`, `temporal_duality`, `weakening`. For a step with `"rule": "axiom"`, the action index is the axiom constructor index (0-41), not 42.

Key translation: `step_to_action_index(rule, axiom_name)` in `actions.py` handles this dispatch.

#### 4. Schema Gap: proof_extractor (8 fields) vs ProofStepRecord (12 fields)

**Status**: Documented gap. A bridge function `load_bmlogic_proof_steps()` was implemented in `data/ingestion.py` that resolves all 4 missing fields:

| Missing Field | Resolution in `load_bmlogic_proof_steps()` |
|---------------|---------------------------------------------|
| `step_id` | Derived as `f"{theorem_name}/{step_index}"` |
| `goal_json` + `goal_pretty` | `goal` field renamed; `goal_pretty` from `formula_json_to_pretty()` |
| `action_index` | Computed via `step_to_action_index(rule, axiom_name)` |
| `depth` | Set to `step_index` (approximation) |
| `proof_height` | Defaults to `0` |

The `context` field in proof_extractor output contains Formula JSON objects (not pretty-printed strings). `load_bmlogic_proof_steps()` passes these through as-is; the downstream `ProofStepDataset` likely expects strings. This is a **remaining incompatibility** that needs verification.

The `load_proof_steps()` function (strict 12-field) will fail on raw `proof_extractor` output because it calls `ProofStepRecord.from_dict()` which expects `step_id` and `goal_json`. Use `load_bmlogic_proof_steps()` instead.

#### 5. Formula AST Schema: Documented Mismatch

The `cross-repo-integration.md` in BimodalHarness (doc version 2) shows:
```json
{"tag": "box", "child": <FormulaNode>, "event": <FormulaNode>}
```
But Lean's `DataExport.lean` produces:
```json
{"tag": "box", "child": <FormulaNode>}
```
(No `event` field.) The `.context/data-contract.md` correctly documents that `box` uses only `child`. The PIPELINE.md also notes this discrepancy. The deprecated `data.schema.FormulaNode` is wrong; the current `schema.records.TrainingRecord` path (via `lean_export_to_training_record`) handles `box.child` correctly.

#### 6. Training Loop: Supervised + Expert Iteration

**Supervised training** (policy network):
- Input: `ProofStepRecord` list (from `load_bmlogic_proof_steps()`)
- Dataset: `ProofStepDataset` wrapping records
- Trainer: `PolicyTrainer` with cross-entropy loss over 49 primitive action logits
- Entry point: `scripts/train-policy-network.py`

**Supervised training** (value network):
- Input: `TrainingRecord` list (from `load_lean_jsonl()`)
- Dataset: `BimodalDataset`
- Trainer: `ValueTrainer` with MSE over difficulty scores
- Entry point: `scripts/train-value-network.py`

**Expert iteration** (`ExpertIterationLoop.run()`):
1. **SEARCH**: `PythonBestFirstSearch` or `MCTSSearch` over train formulas
2. **EXTRACT**: `search_result_to_proof_steps()` and `search_result_to_value_targets()`
3. **ACCUMULATE**: `ReplayBuffer` with `(goal_hash, action_index)` deduplication
4. **RETRAIN**: `PolicyTrainer` + `ValueTrainer` rebuilt each iteration
5. **EVALUATE**: BFS solve rate on held-out eval formulas
- Entry point: `scripts/run_expert_iteration.py` with `--config configs/expert_iteration_default.json`

#### 7. Evaluation Approach

Evaluation uses `PythonBestFirstSearch` in Python-only mode (no Lean bridge) with `record_training_signals=False`. The solve rate is the fraction of eval formulas where `result.proved == True`. The proof verification is axiom-matching and assumption-checking in Python — it does not call `lake exe` at evaluation time.

The benchmark dataset `data/bimodal/bmlogic-bench-validated.jsonl` and `data/bimodal/bmlogic-bench.jsonl` are available for held-out evaluation.

#### 8. ProofStepRecord.from_dict() Context Field

Looking at `load_bmlogic_proof_steps()`, the `context` field is passed as-is (a list of Formula JSON dicts from Lean). The `ProofStepDataset` and `policy_collate_fn` encode context formulas via `_formula_to_string()`. If `_formula_to_string()` expects a string but receives a dict, this will fail. This is a risk that needs a brief test.

---

### Schema Mismatches Summary

| Mismatch | Severity | Resolution Status |
|----------|----------|-------------------|
| proof_extractor 8-field vs ProofStepRecord 12-field | High | Bridged by `load_bmlogic_proof_steps()` |
| `goal` key vs `goal_json` key | High | Handled in `load_bmlogic_proof_steps()` |
| `context` as Formula dicts vs strings | Medium | Unverified — may cause error in `ProofStepDataset` |
| `box` AST node: legacy `event` field in old schema | Low | Fixed in current code; only in deprecated `data.schema` |
| Label case: `"VALID"` vs `"valid"` | Low | Fixed in `lean_export_to_training_record()` via `.lower()` |
| `difficulty_tier` int 1-5 vs string `"easy"` etc. | Low | Fixed via `DIFFICULTY_TIER_MAP` in ingestion.py |
| `top_operator` camelCase vs PascalCase | Low | Fixed via `TOP_OPERATOR_MAP` |
| `data/VERSION` LEAN_VERSION format (`v4.27.0-rc1` vs `4.27.0-rc1`) | Cosmetic | Not code-blocking |

---

### Recommendations

#### Smoke Test Design

A minimal smoke test (`smoke-test-training.sh`) should validate:

1. **Data presence check**: Assert `data/proof_steps.jsonl` and `data/bmlogic-c5.jsonl` exist and are non-empty.
2. **BimodalHarness sync check**: Assert `data/bimodal/proof_steps.jsonl` exists (already synced).
3. **Ingestion test**: Run `python -c "from bimodal_harness.data.ingestion import load_bmlogic_proof_steps, load_lean_jsonl; ..."` loading ~100 records from each file and asserting non-empty output.
4. **Context field compatibility test**: Load 1 `ProofStepRecord` via `load_bmlogic_proof_steps()`, instantiate `ProofStepDataset([record])`, call `policy_collate_fn([dataset[0]])` and confirm no exception.
5. **Supervised training smoke**: Instantiate `PolicyNetwork`, `PolicyTrainer`, run 1 epoch on the loaded records.
6. **Expert iteration smoke**: Run `ExpertIterationLoop` for 1 iteration with `num_iterations=1`, `initial_max_expansions=10`, a subset of 20 train formulas from c5.
7. **Evaluation smoke**: Run `PythonBestFirstSearch` on 5 eval formulas from `bmlogic-bench.jsonl`.

#### Implementation Approach

1. **Fix context encoding incompatibility first** (if confirmed): In `load_bmlogic_proof_steps()` or `ProofStepDataset`, convert `context` formula dicts to pretty-printed strings via `formula_json_to_pretty()`. This is a 3-line fix.
2. **Create `scripts/smoke-test-training.sh`** in BimodalHarness: orchestrates the 7 steps above, exits non-zero on first failure, prints summary at the end.
3. **Generate small dataset (1,000 formulas, 5,000 proof steps)**: The existing `bmlogic-c5.jsonl` (1,513 formulas) is large enough. The 10,063 proof steps already exceed 5,000. No new generation is needed for smoke testing.
4. **For benchmark evaluation**: Use `data/bimodal/bmlogic-bench-validated.jsonl` as the held-out eval set. Extract `formula_ast` fields as training formulas and `label` as ground truth.

---

## Decisions

- Use `load_bmlogic_proof_steps()` (not `load_proof_steps()`) when loading `proof_steps.jsonl` — the 8-field vs 12-field gap is bridged there.
- Smoke test should use existing data (no need to re-run `lake exe` targets) since all files are already present and synced.
- For the smoke expert iteration run, use `search_strategy="bfs"` (not MCTS) to avoid MCTS overhead on small budgets.
- The `data/bimodal/` directory already exists and is populated — `make sync-data` has already been run successfully.

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| `context` dict→string incompatibility in ProofStepDataset | Medium | Test with `policy_collate_fn` before full run; fix with `formula_json_to_pretty()` |
| PolicyNetwork output dim=49, but ALL_ACTIONS=82 | Low | Policy network uses `NUM_PRIMITIVE_ACTIONS=49`; smoke test uses Base frame class mask |
| BimodalHarness not installed in Python env | High | Run `pip install -e .` in `BimodalHarness/` before smoke test |
| PyTorch not installed | Medium | Smoke test should check `import torch` and fail gracefully with instructions |
| W&B API key not set | Low | Set `WANDB_DISABLED=true` in smoke test |
| `lake build dataset_generator proof_extractor` required for re-export | Low | Smoke test uses pre-existing files; only re-export if files are stale |

---

## Context Extension Recommendations

- **Topic**: BimodalHarness data ingestion adapter for proof steps
- **Gap**: The `load_bmlogic_proof_steps()` adapter in BimodalHarness is not documented in the BimodalLogic `SYNC_PROTOCOL.md`. The sync doc says a Python-side adapter is needed but doesn't record that it has been implemented.
- **Recommendation**: Update `docs/training/SYNC_PROTOCOL.md` to mark the Python adapter status as "DONE" and reference `data/ingestion.load_bmlogic_proof_steps()`.

---

## Appendix

### Search Queries / Files Examined

**BimodalLogic**:
- `scripts/export-training-data.sh` — export orchestrator
- `scripts/run_dataset_generation.sh` — dataset generation with tier support
- `docs/training/SYNC_PROTOCOL.md` — schema gap documentation
- `docs/training/PIPELINE.md` — complete pipeline reference (6 Lean modules)
- `data/VERSION` — schema v1, Lean v4.27.0-rc1, 10,063 proof steps
- `data/proof_steps_metadata.json` — 310 theorems, 10,063 steps
- `Theories/Bimodal/Automation/ProofStepExtractor.lean` — 8-field output schema

**BimodalHarness**:
- `.context/data-contract.md` — canonical field mapping reference
- `docs/architecture/cross-repo-integration.md` — integration architecture
- `docs/training/pipeline.md` — 5-stage training pipeline
- `src/bimodal_harness/schema/actions.py` — 82-action space definition
- `src/bimodal_harness/data/ingestion.py` — 4-layer ingestion pipeline
- `src/bimodal_harness/training/loop.py` — ExpertIterationLoop (1,927 lines)
- `scripts/run_expert_iteration.py` — expert iteration CLI entry point
- `configs/expert_iteration_default.json` — default config
- `data/bimodal/` — synced JSONL files (already populated)
- `Makefile` — `sync-data`, `validate-data`, `test` targets
- `tests/test_smoke.py` — package importability tests

### Current Data State

| File | Location | Size | Notes |
|------|----------|------|-------|
| `proof_steps.jsonl` | `BimodalLogic/data/` | 10,063 lines | 310 theorems |
| `bmlogic-c5.jsonl` | `BimodalLogic/data/` | 1,513 lines | Complexity 5 |
| `bmlogic-c7.jsonl` | `BimodalLogic/data/` | 49,904 lines | Complexity 7 |
| `proof_steps.jsonl` | `BimodalHarness/data/bimodal/` | synced | Already available |
| `bmlogic-bench-validated.jsonl` | `BimodalHarness/data/bimodal/` | present | Use as eval set |
