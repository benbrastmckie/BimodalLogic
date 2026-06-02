# Implementation Plan: Task #247

- **Task**: 247 - training_loop_validation
- **Status**: [COMPLETED]
- **Effort**: 8 hours
- **Dependencies**: Tasks 242, 245, 246
- **Research Inputs**: specs/247_training_loop_validation/reports/01_training-loop-validation.md
- **Artifacts**: plans/01_training-loop-validation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Validate the complete end-to-end pipeline from Lean tableau proof export through BimodalHarness data ingestion, supervised training, expert iteration, and benchmark evaluation. The research report confirms that all data already exists (10,063 proof steps, 1,513 c5 formulas) and is synced to BimodalHarness, but a critical `context` field encoding incompatibility (dict vs string) in `ProofStepDataset` needs verification and likely a fix before training can proceed. The plan creates a reusable `smoke-test-training.sh` script that validates each pipeline stage, documents all schema mismatches, and confirms action predictions align with the 49-primitive Lean action space.

### Research Integration

Key findings from the research report integrated into this plan:
- **Schema gap**: proof_extractor outputs 8 fields; ProofStepRecord expects 12 fields. Already bridged by `load_bmlogic_proof_steps()` in `data/ingestion.py`.
- **Context field risk**: `context` contains Formula JSON dicts but `ProofStepDataset`/`policy_collate_fn` may expect strings. Needs verification in Phase 1.
- **Data already exists**: `proof_steps.jsonl` (10,063 lines), `bmlogic-c5.jsonl` (1,513 lines), `bmlogic-c7.jsonl` (49,904 lines) -- all synced to `BimodalHarness/data/bimodal/`.
- **Action space aligned**: 42 axiom actions + 7 rule actions match between Lean and Python. `step_to_action_index()` handles dispatch.
- **Use BFS for expert iteration**: BFS (not MCTS) avoids overhead on small budgets.
- **Benchmark available**: `data/bimodal/bmlogic-bench-validated.jsonl` for held-out evaluation.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the tableau-training topic. It validates the pipeline infrastructure that connects the Lean formalization (BimodalLogic) to the neural network training system (BimodalHarness), which is a prerequisite for all downstream ML training tasks.

## Goals & Non-Goals

**Goals**:
- Verify data ingestion of proof steps via `load_bmlogic_proof_steps()` adapter
- Fix the `context` field encoding incompatibility if confirmed
- Run supervised training on proof steps (1 epoch, PolicyNetwork)
- Run a single iteration of expert iteration (BFS, 20 train formulas)
- Evaluate on benchmark formulas and verify action predictions align with Lean action space
- Document all schema mismatches encountered
- Create `scripts/smoke-test-training.sh` in BimodalHarness as a reusable validation script

**Non-Goals**:
- Re-running `lake exe dataset_generator` or `lake exe proof_extractor` (data already exists)
- Achieving good training accuracy (this is validation, not production training)
- Modifying the Lean-side export pipeline
- Training for multiple epochs or hyperparameter tuning
- Fixing BimodalHarness bugs unrelated to the ingestion/training pipeline

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `context` dict-vs-string incompatibility in ProofStepDataset | H | M | Test with `policy_collate_fn` first; fix with `formula_json_to_pretty()` in `load_bmlogic_proof_steps()` |
| BimodalHarness not installed in Python env | H | H | Run `pip install -e .` in BimodalHarness as first step |
| PyTorch not installed or wrong version | H | M | Check `import torch` and fail gracefully with instructions |
| W&B API key not set causing training hang | M | L | Set `WANDB_DISABLED=true` in smoke test env |
| PolicyNetwork output dim mismatch (49 vs 82 actions) | M | L | Policy uses `NUM_PRIMITIVE_ACTIONS=49`; verify Base frame mask |
| Expert iteration BFS finds no proofs in small budget | L | M | Use `max_expansions=50` on known-easy formulas from c5 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Data Ingestion Verification and Context Field Fix [COMPLETED]

**Goal**: Confirm that proof steps and labeled formulas load correctly into BimodalHarness Python types, and fix the `context` field encoding incompatibility if present.

**Tasks**:
- [x] **Task 1.1**: Verify BimodalHarness is installed *(completed: pip install blocked by NixOS venv; workaround: PYTHONPATH set in scripts)*
- [x] **Task 1.2**: Verify PyTorch is importable *(completed: torch 2.11.0)*
- [x] **Task 1.3**: Verify data files exist and are non-empty *(completed: proof_steps.jsonl 10063 lines, c5 1513 lines, bench 1950 lines)*
- [x] **Task 1.4**: Load proof steps via `load_bmlogic_proof_steps()` *(completed: 10063 records loaded)*
- [x] **Task 1.5**: Load labeled formulas via `load_lean_jsonl()` *(completed: 1461 records, 52 timeout skipped)*
- [x] **Task 1.6**: Test context field compatibility *(completed: no incompatibility — context is empty tuple in current dataset)*
- [x] **Task 1.7**: Fix `load_bmlogic_proof_steps()` if context field fails *(completed: no fix needed)*
- [x] **Task 1.8**: Verify `action_index` values within range *(deviation: altered — actual action space is 82, not 49 as plan assumed; proof steps use [0, 47], all valid)*
- [x] **Task 1.9**: Document schema mismatches in `docs/schema-mismatches.md` *(completed)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/data/ingestion.py` - Fix context field encoding if needed
- `/home/benjamin/Projects/BimodalHarness/docs/schema-mismatches.md` - New file documenting all mismatches

**Verification**:
- `load_bmlogic_proof_steps()` returns 10,063 records without errors
- `ProofStepDataset` + `policy_collate_fn` produce valid tensors
- All `action_index` values are in [0, 48]

---

### Phase 2: Supervised Training on Proof Steps [COMPLETED]

**Goal**: Run supervised training of the PolicyNetwork on proof step data for 1 epoch, confirming the training loop executes without errors.

**Tasks**:
- [x] **Task 2.1**: Load proof steps via `load_bmlogic_proof_steps()` *(completed: 5000 records used)*
- [x] **Task 2.2**: Instantiate `PolicyNetwork` with default config *(deviation: altered — num_actions=82 not 49; default PolicyNetworkConfig uses 82)*
- [x] **Task 2.3**: Instantiate `PolicyTrainer` with cross-entropy loss *(completed)*
- [x] **Task 2.4**: Run 1 epoch of supervised training on proof steps *(completed: train_loss=1.3606)*
- [x] **Task 2.5**: Verify loss is finite (not NaN/Inf) *(completed: PASS)*
- [x] **Task 2.6**: Verify predicted action indices are in valid range *(completed: top1=0.75, top5=0.994)*
- [x] **Task 2.7**: Log training metrics *(completed: loss=1.3606, top1=0.75, top5=0.994, 4500 records)*
- [x] **Task 2.8**: Load labeled formulas for value network *(completed: 1461 c5 records)*
- [x] **Task 2.9**: Instantiate `ValueNetwork` and `ValueTrainer` *(completed)*
- [x] **Task 2.10**: Run 1 epoch of value network training *(completed: train_loss=0.0125)*
- [x] **Task 2.11**: Verify value predictions are finite *(completed: mae=0.0104)*

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- No source file modifications expected (unless training reveals bugs)

**Verification**:
- PolicyTrainer completes 1 epoch without exceptions
- Loss values are finite and non-negative
- ValueTrainer completes 1 epoch without exceptions

---

### Phase 3: Expert Iteration Smoke Run [COMPLETED]

**Goal**: Run a minimal expert iteration loop (1 iteration, 20 formulas, BFS search) to validate the SEARCH -> EXTRACT -> ACCUMULATE -> RETRAIN -> EVALUATE cycle.

**Tasks**:
- [x] **Task 3.1**: Select 20 easy formulas from `bmlogic-c5.jsonl` *(completed: 64 found, 20 selected)*
- [x] **Task 3.2**: Select 5 eval formulas from `bmlogic-bench-validated.jsonl` *(deviation: altered — bench loaded via direct JSON dict; 1 overlap removed)*
- [x] **Task 3.3**: Configure `ExpertIterationLoop` *(completed: bfs, max_expansions=50, WANDB_DISABLED=true)*
- [x] **Task 3.4**: Run expert iteration loop for 1 iteration *(completed: 1.5s)*
- [x] **Task 3.5**: Verify SEARCH phase finds at least 1 proof *(completed: 16 proofs found)*
- [x] **Task 3.6**: Verify EXTRACT phase produces ProofStepRecord objects *(completed: buffer 903->919)*
- [x] **Task 3.7**: Verify ACCUMULATE phase adds records to replay buffer *(completed: value 200->216)*
- [x] **Task 3.8**: Verify RETRAIN phase runs PolicyTrainer without errors *(completed)*
- [x] **Task 3.9**: Verify EVALUATE phase reports a solve rate *(completed: solve_rate=1.0 (5/5))*
- [x] **Task 3.10**: Log iteration metrics *(completed: 16 proofs, 5/5 eval, 919 policy records, 216 value records)*

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- No source file modifications expected (configuration only)

**Verification**:
- ExpertIterationLoop completes 1 iteration without exceptions
- At least 1 proof found during SEARCH phase
- Replay buffer is non-empty after ACCUMULATE

---

### Phase 4: Action Space Alignment Verification [COMPLETED]

**Goal**: Verify that action predictions from the trained policy network map correctly to the Lean action space, and that all action indices correspond to valid axiom/rule names.

**Tasks**:
- [x] **Task 4.1**: Load trained policy network *(completed: re-trained 1 epoch, loss=1.3158)*
- [x] **Task 4.2**: Run inference on 10 proof step goals *(completed: probs shape [10, 82])*
- [x] **Task 4.3**: Verify all predicted top-k indices map to valid ALL_ACTIONS *(completed: PASS)*
- [x] **Task 4.4**: Cross-reference action indices with Lean rule names *(completed: 0-41=axioms, 42-48=rules, 49-81=derived)*
- [x] **Task 4.5**: Verify step_to_action_index produces correct indices for 20 proof steps *(completed: PASS, 0 mismatches)*
- [x] **Task 4.6**: Document action space mapping in docs/schema-mismatches.md *(completed)*
- [x] **Task 4.7**: Verify no action indices fall outside [0, 48] *(deviation: altered — actual range [0, 81] with 82 actions; all 10063 indices valid)*

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `/home/benjamin/Projects/BimodalHarness/docs/schema-mismatches.md` - Append action space mapping documentation

**Verification**:
- All action indices in proof steps are within [0, 48]
- `step_to_action_index` produces correct index for every rule/axiom_name combination in the dataset
- Policy network predictions are valid action indices

---

### Phase 5: Smoke Test Script and Documentation [COMPLETED]

**Goal**: Create a reusable `scripts/smoke-test-training.sh` in BimodalHarness that automates all validation steps, and document the results.

**Tasks**:
- [x] **Task 5.1**: Create `scripts/smoke-test-training.sh` with 8 steps *(completed)*
- [x] **Task 5.2**: Script exits non-zero on first failure, prints summary *(completed)*
- [x] **Task 5.3**: Script sets `WANDB_DISABLED=true` automatically *(completed)*
- [x] **Task 5.4**: Script supports `--quick` flag to skip expert iteration *(completed)*
- [x] **Task 5.5**: Make script executable *(completed: chmod +x)*
- [x] **Task 5.6**: Create Python helper `scripts/smoke_test_training.py` *(completed)*
- [x] **Task 5.7**: Run smoke test end-to-end and verify it passes *(completed: 8/8 steps PASSED, 18.8s; quick mode: 6/6 steps PASSED, 27.4s)*
- [x] **Task 5.8**: Update `docs/schema-mismatches.md` with final summary *(completed)*
- [x] **Task 5.9**: Update SYNC_PROTOCOL.md to mark Python adapter as DONE *(completed)*

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `/home/benjamin/Projects/BimodalHarness/scripts/smoke-test-training.sh` - New file: shell wrapper
- `/home/benjamin/Projects/BimodalHarness/scripts/smoke_test_training.py` - New file: Python test logic
- `/home/benjamin/Projects/BimodalHarness/docs/schema-mismatches.md` - Final summary of all mismatches
- `/home/benjamin/Projects/BimodalLogic/docs/training/SYNC_PROTOCOL.md` - Mark Python adapter as DONE

**Verification**:
- `smoke-test-training.sh` runs end-to-end and exits 0
- `smoke-test-training.sh --quick` runs and exits 0 (skipping expert iteration)
- All 8 test steps produce expected output

## Testing & Validation

- [ ] `load_bmlogic_proof_steps()` loads all 10,063 proof steps without errors
- [ ] `load_lean_jsonl()` loads all 1,513 c5 formulas without errors
- [ ] `ProofStepDataset` + `policy_collate_fn` produce valid tensors from loaded proof steps
- [ ] PolicyTrainer completes 1 epoch on proof steps with finite loss
- [ ] ValueTrainer completes 1 epoch on labeled formulas with finite loss
- [ ] ExpertIterationLoop completes 1 iteration (BFS, 20 formulas) without crash
- [ ] At least 1 proof found during BFS search on easy formulas
- [ ] All action_index values in proof step dataset are in [0, 48]
- [ ] `step_to_action_index()` produces correct indices for all rule/axiom_name pairs
- [ ] `smoke-test-training.sh` passes end-to-end

## Artifacts & Outputs

- `specs/247_training_loop_validation/plans/01_training-loop-validation.md` (this plan)
- `/home/benjamin/Projects/BimodalHarness/scripts/smoke-test-training.sh` (reusable validation script)
- `/home/benjamin/Projects/BimodalHarness/scripts/smoke_test_training.py` (Python test logic)
- `/home/benjamin/Projects/BimodalHarness/docs/schema-mismatches.md` (schema mismatch documentation)
- Updated `/home/benjamin/Projects/BimodalLogic/docs/training/SYNC_PROTOCOL.md` (adapter status)

## Rollback/Contingency

- If the `context` field fix breaks other ingestion paths, revert and add a separate adapter function (`load_bmlogic_proof_steps_v2`) instead of modifying the existing one.
- If expert iteration hangs or crashes, the smoke test script includes a `--quick` flag to skip it. Document the failure and file a separate bug.
- If PyTorch is not available in the environment, the smoke test script reports this as a prerequisite failure with installation instructions.
- All changes are in BimodalHarness (a separate repo); BimodalLogic changes are limited to documentation updates in SYNC_PROTOCOL.md which can be reverted independently.
