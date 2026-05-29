# Implementation Plan: Task #201 -- AlphaZero Proof Search Task Decomposition

- **Task**: 201 - alphazero_proof_search_harness
- **Status**: [NOT STARTED]
- **Effort**: 40 hours (planning/setup effort across 6 sub-tasks; full implementation is 4-8 person-months)
- **Dependencies**: None (completeness work is independent; the harness uses the existing axiom/rule infrastructure)
- **Research Inputs**: specs/201_alphazero_proof_search_harness/reports/01_team-research.md
- **Artifacts**: plans/01_task-decomposition.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan decomposes the AlphaZero-style proof search harness (task 201) into 6 concrete sub-tasks, each independently researchable, plannable, and implementable via the task system. The decomposition follows the phased approach unanimously recommended by team research: foundation infrastructure first (formula enumeration, Python-Lean bridge, benchmark), then value estimation, then policy network with expert iteration, and finally full MCTS. Each phase in this plan defines a sub-task with a seed research brief, deliverables, dependencies, effort estimate, and open questions for that sub-task's own `/research` cycle. The plan is complete when all 6 sub-tasks have been created with their seed descriptions.

### Research Integration

The team research report (4 teammates) provided the following key findings integrated into this plan:

- The bimodal TM logic has 42 axiom constructors + 7 inference rules, yielding a finite, enumerable action space comparable to Go's branching factor (~50-200)
- `DerivationTree.height` provides exact value-network labels (steps-to-completion)
- The tableau decision procedure generates unlimited training data via formula enumeration
- `SuccessPatterns.lean` already implements a shallow value function (`PatternKey -> ProofStrategy`)
- LeanDojo-v2 + LeanProgress is the recommended harness; Nazrin GNN architecture matches the domain
- Expert iteration (not full RL from scratch) is the right training paradigm
- Minimum viable: CPU-only for Phases 0-1, single GPU for Phase 2, A100 for Phase 3
- No published result shows MCTS+NN proof search working from cold start at small compute in a custom domain, but value estimators and retrieval-based approaches DO work at small scale

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task is not on the completeness critical path. It represents a new research direction (neural proof search) that builds on the existing formalized axiom system and proof infrastructure. The ROADMAP does not currently list neural proof search items, but the harness leverages:
- The 42 BX axiom constructors and 7 inference rules (Axioms.lean)
- The existing `Automation/ProofSearch/` infrastructure
- The `SuccessPatterns.lean` shallow value function
- The `SubformulaClosure/` module for bounded formula generation
- The tableau decision procedure in `Metalogic/Decidability/`

## Goals & Non-Goals

**Goals**:
- Define 6 concrete sub-tasks with clear scope, deliverables, and dependencies
- Provide seed research briefs drawn from team research findings for each sub-task
- Identify key open questions that each sub-task's own `/research` should investigate
- Establish a dependency graph so sub-tasks can be executed in order or in parallel where possible

**Non-Goals**:
- Implementing any component of the harness in this plan (each sub-task handles its own implementation)
- Making final architecture decisions (each sub-task's research phase will resolve open questions)
- Building the full AlphaZero system (the phased approach means Phase 3 is only pursued if Phase 2 succeeds)
- Modifying any existing Lean source files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formula enumerator produces only trivial/redundant formulas | H | M | Phase 1 includes diversity validation; feasibility gate before investing in neural infrastructure |
| Python-Lean bridge does not work with ProofChecker's Lean version | H | M | Phase 1 tests multiple bridge options (LeanDojo-v2, lean-interact, PyPantograph) |
| Training corpus too small for meaningful learning | H | L | Tableau decision procedure generates unlimited data; research confirmed 10K-50K labeled formulas achievable |
| Value network does not beat SuccessPatterns.lean baseline | M | M | Phase 2 defines clear evaluation metrics; shallow MLP is low investment; negative result is still publishable |
| Compute requirements exceed available hardware | M | L | Phases 0-1 are CPU-only; Phase 2 needs only 1x 24GB GPU; Phase 3 (A100) is optional |
| Lean REPL throughput too slow for online training | M | M | Pre-generate training data offline using symbolic search; use Lean only for evaluation |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Sub-Task -- Formula Enumerator and Evaluation Benchmark [NOT STARTED]

**Goal**: Create a sub-task for building a TM formula enumerator that generates formulas at controlled modal/temporal depth, labels them via the tableau decision procedure, and produces a held-out evaluation benchmark.

**Tasks**:
- [ ] Draft sub-task description covering scope, deliverables, and constraints
- [ ] Include seed research brief from team research findings
- [ ] Create the sub-task via `/task` or manual task creation
- [ ] Verify sub-task appears in TODO.md and state.json

**Timing**: 1 hour (task creation only; sub-task implementation is estimated at 3-4 weeks)

**Depends on**: none

**Sub-Task Seed Research Brief**:

*Scope*: Build a Lean module that systematically enumerates TM formulas up to bounded modal depth (d_box), temporal depth (d_G, d_U), and formula size. Run the existing tableau decision procedure (`Metalogic/Decidability/`) on each formula to produce provability labels and proof traces. Output a structured dataset of (formula, label, proof_trace, difficulty_metrics) tuples. Separately, hold out 500-1K formulas of varying difficulty as an evaluation benchmark.

*Key findings from research*:
- The `SubformulaClosure/` module provides bounded formula generation infrastructure
- The codebase has only ~2,519 theorem/lemma declarations but the decision procedure can generate unlimited training examples
- For provable formulas, extract proof traces (states visited, rules applied, proof depth)
- For unprovable formulas, extract countermodels (true negative training signal)
- Target: 10K-50K labeled formulas for initial training corpus
- Three `FrameClass` values (Base, Dense, Discrete) provide a natural curriculum

*Deliverables*:
1. `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- bounded enumeration by depth/size
2. `Theories/Bimodal/Automation/DatasetGenerator.lean` -- run decider, produce labeled dataset
3. Evaluation benchmark (500-1K formulas with ground-truth provability and difficulty tier)
4. Diversity analysis: distribution of modal/temporal depth, operator usage, provability ratio
5. Export format: JSON or CSV for Python consumption

*Feasibility gate*: If the enumerator cannot produce diverse, non-trivial formulas at scale (e.g., >80% are trivially provable via propositional reasoning alone), reassess the approach before investing in neural infrastructure.

*Open questions for sub-task research*:
- What depth/size bounds produce the best difficulty distribution?
- How to ensure diversity (avoid generating permutations of the same formula)?
- Should enumeration use random sampling, exhaustive up-to-depth, or grammar-based generation?
- How to efficiently extract proof traces from the tableau procedure (not just yes/no)?
- What difficulty metrics beyond `DerivationTree.height` are informative (e.g., branching factor, backtrack count)?

**Verification**:
- Sub-task created with clear description, tagged as `lean4` type
- Seed research brief included in task description

---

### Phase 2: Sub-Task -- Python-Lean Bridge Validation [NOT STARTED]

**Goal**: Create a sub-task for validating that a Python-Lean bridge can interact with the ProofChecker project at the tactic level, send proof steps, and receive goal states.

**Tasks**:
- [ ] Draft sub-task description covering scope, deliverables, and constraints
- [ ] Include seed research brief from team research findings
- [ ] Create the sub-task via `/task` or manual task creation
- [ ] Verify sub-task appears in TODO.md and state.json

**Timing**: 1 hour (task creation only; sub-task implementation is estimated at 2-3 weeks)

**Depends on**: 1

**Sub-Task Seed Research Brief**:

*Scope*: Validate that one or more Python-Lean bridge libraries can interact with the ProofChecker project loaded. The bridge must support: (a) loading the ProofChecker environment, (b) setting up a proof state for a given formula, (c) sending individual tactic steps (axiom applications, inference rules), (d) receiving the resulting goal state, and (e) detecting proof completion or failure. This is the critical infrastructure connecting the Python ML training loop to the Lean proof engine.

*Key findings from research*:
- Three bridge options identified with different trade-offs:
  - **LeanDojo-v2**: End-to-end training pipeline, supports local Lean 4 projects via `DynamicDatabase`, has `SFTTrainer` and `GRPOTrainer` integrated
  - **lean-interact**: Simple REPL wrapper (`pip install lean-interact`), lightweight, easiest to get started
  - **PyPantograph**: Rich tactic-state API with metavariable coupling, most powerful but most complex
- Kimina Lean Server benchmarks: 0.272s per proof at 8 cores, 0.051s at 64 cores
- LRU caching provides ~1.94x speedup on repeated imports
- For tactic-level MCTS: 100 rollouts x 20 moves = 2,000 calls per attempt, yielding ~5 min/attempt at 8 cores
- Mitigation: pre-generate training data offline, use Lean only for evaluation

*Deliverables*:
1. Working Python script that loads ProofChecker, opens a proof state, applies tactics, reads goals
2. Latency benchmarks: single-tactic step time, proof-completion round-trip time
3. Compatibility report: which bridge(s) work with Lean v4.27.0-rc1 and Mathlib v4.27.0-rc1
4. Prototype tactic interface mapping the 42 axiom constructors + 7 rules to Python-callable actions
5. Documentation of failure modes and error handling

*Open questions for sub-task research*:
- Does LeanDojo-v2 support Lean v4.27.0-rc1 (it may lag behind latest toolchain)?
- What is the single-tactic-step latency for the ProofChecker project specifically (cold vs warm)?
- Can the bridge handle the project's large import graph without timeout?
- How to represent the AND/OR proof tree structure through the bridge API?
- Is it feasible to run the symbolic `ProofSearch/Core.lean` search engine from Python as a data generator?

**Verification**:
- Sub-task created with clear description, tagged as `lean4` type
- Seed research brief included in task description

---

### Phase 3: Sub-Task -- Training Data Extraction Pipeline [NOT STARTED]

**Goal**: Create a sub-task for building a pipeline that extracts (goal_state, tactic, result) training tuples from existing proofs and from the formula enumerator, producing a structured dataset for supervised learning.

**Tasks**:
- [ ] Draft sub-task description covering scope, deliverables, and constraints
- [ ] Include seed research brief from team research findings
- [ ] Create the sub-task via `/task` or manual task creation
- [ ] Verify sub-task appears in TODO.md and state.json

**Timing**: 1 hour (task creation only; sub-task implementation is estimated at 3-4 weeks)

**Depends on**: 1

**Sub-Task Seed Research Brief**:

*Scope*: Build a data pipeline with two sources: (1) LeanDojo tracing of existing proofs in `Theories/Bimodal/` to extract (goal, tactic) pairs from human-written proofs, and (2) symbolic proof search traces from the formula enumerator (Phase 1) to produce (goal_state, axiom_applied, resulting_state, proof_depth) tuples. The combined dataset provides supervised training data for both the value network (Phase 4) and the policy network (Phase 5).

*Key findings from research*:
- LeanDojo can trace existing Lean 4 projects to extract tactic-level proof data
- The PACT co-training approach mines `DerivationTree` instances as self-supervised targets
- `DerivationTree.height` provides exact value-network labels (steps-to-completion)
- `PatternKey` features (modalDepth, temporalDepth, impCount, complexity, topOperator) are already computed by `SuccessPatterns.lean`
- Expert iteration paradigm: generate proof attempts via search, verify with Lean, add verified (state, tactic) pairs to training data, retrain
- Three data sources in pipeline: (1) LeanDojo traces of existing proofs, (2) tableau decider synthetic corpus, (3) expert iteration loop (future)

*Deliverables*:
1. LeanDojo tracing configuration for ProofChecker project
2. Trace extraction script producing (goal, tactic, result) tuples in standardized format
3. Symbolic search trace extractor: run `ProofSearch/Core.lean` or IDDFS/best-first on enumerated formulas, record search trajectories
4. Combined dataset in PyTorch-compatible format (HuggingFace datasets or simple JSON/parquet)
5. Dataset statistics: size, tactic distribution, proof depth distribution, difficulty tier breakdown
6. `PatternKey` feature extractor for each goal state (connecting to `SuccessPatterns.lean`)

*Open questions for sub-task research*:
- How many usable (goal, tactic) pairs can LeanDojo extract from the existing ~2,519 declarations?
- What is the optimal representation of goal states for neural input (raw text, AST, graph)?
- How to handle the AND/OR structure: should each subgoal be a separate training example?
- Should the dataset include negative examples (failed proof attempts, dead-end paths)?
- What normalization/canonicalization of formulas improves dataset quality?

**Verification**:
- Sub-task created with clear description, tagged as `lean4` type
- Seed research brief included in task description

---

### Phase 4: Sub-Task -- Value Network (Proof-Progress Predictor) [NOT STARTED]

**Goal**: Create a sub-task for training a value network that predicts proof-step count from formula structure, integrated as an additive bonus to the existing `modal_search` heuristic scorer.

**Tasks**:
- [ ] Draft sub-task description covering scope, deliverables, and constraints
- [ ] Include seed research brief from team research findings
- [ ] Create the sub-task via `/task` or manual task creation
- [ ] Verify sub-task appears in TODO.md and state.json

**Timing**: 1 hour (task creation only; sub-task implementation is estimated at 6-8 weeks)

**Depends on**: 2, 3

**Sub-Task Seed Research Brief**:

*Scope*: Train a value network (LeanProgress-style proof-progress predictor) that takes a proof goal state and predicts the number of steps remaining to complete the proof. The model takes `PatternKey` features as input (already computed by `SuccessPatterns.lean`) and predicts `DerivationTree.height`. Integrate the trained model as an additive bonus to the `modal_search` heuristic scorer in `Automation/ProofSearch/`. Evaluate against the `SuccessPatterns.lean` baseline on the held-out benchmark from Phase 1.

*Key findings from research*:
- **Architecture**: Start with shallow MLP over `PatternKey` features (modalDepth, temporalDepth, impCount, complexity, topOperator). This is the simplest viable architecture (1.5M-10M params, CPU-trainable). Upgrade to GNN over formula AST or transformer in later iterations if needed.
- **Labels**: `DerivationTree.height` from successful proofs provides exact step-to-completion labels for free
- **Baseline**: `SuccessPatterns.lean` implements a shallow handcrafted value function; the neural predictor must beat this baseline
- **Evaluation metrics**: Nodes visited / time-to-proof on benchmark vs baseline
- **Training**: Supervised regression on (PatternKey_features, height) pairs from the dataset (Phase 3)
- **Integration point**: Additive bonus to `modal_search` heuristic scorer, not a replacement
- **Hardware**: CPU-only training viable for shallow MLP; single GPU for GNN/transformer variants
- **Publication target**: TABLEAUX 2026 or CADE 2026, "Neural guidance for decidable bimodal logic proof search"

*Deliverables*:
1. PyTorch model definition for proof-progress predictor (MLP baseline, optional GNN variant)
2. Training script with configurable hyperparameters
3. Trained model checkpoint with validation metrics
4. Lean integration: `Automation/ProofSearch/NeuralScorer.lean` or Python-side scorer via bridge
5. Evaluation report: nodes visited, time-to-proof, success rate on benchmark vs `SuccessPatterns.lean`
6. Analysis of what the network learns (feature importance, failure modes)

*Open questions for sub-task research*:
- Is `DerivationTree.height` the right label, or should it be log(height) or a binary provable/unprovable classification?
- Should the MLP input include formula structure beyond `PatternKey` (e.g., subformula counts, operator histograms)?
- How to handle the AND/OR tree structure: predict per-subgoal or per-root-goal?
- What is the right integration point: additive bonus vs multiplicative weight vs priority override?
- How much training data is needed for the MLP to beat the handcrafted baseline?
- Should the model be trained in Python and served via bridge, or compiled to Lean via ONNX?

**Verification**:
- Sub-task created with clear description, tagged as `lean4` type
- Seed research brief included in task description

---

### Phase 5: Sub-Task -- Policy Network and Expert Iteration [NOT STARTED]

**Goal**: Create a sub-task for training a policy network (tactic predictor) via supervised fine-tuning on proof traces, with an expert iteration loop that generates new training data from search guided by the current model.

**Tasks**:
- [ ] Draft sub-task description covering scope, deliverables, and constraints
- [ ] Include seed research brief from team research findings
- [ ] Create the sub-task via `/task` or manual task creation
- [ ] Verify sub-task appears in TODO.md and state.json

**Timing**: 1 hour (task creation only; sub-task implementation is estimated at 8-12 weeks)

**Depends on**: 4

**Sub-Task Seed Research Brief**:

*Scope*: Train a policy network that predicts the next tactic (axiom application or inference rule) given a proof goal state. Start with supervised fine-tuning (SFT) on the proof trace dataset from Phase 3, then implement an expert iteration loop: (1) use the current policy + value network to guide best-first search, (2) verify successful proofs with Lean, (3) add verified (state, tactic) pairs to the training data, (4) retrain. Use GRPOTrainer from LeanDojo-v2 if compatible, otherwise implement a custom SFT loop.

*Key findings from research*:
- **Architecture options**:
  - Fine-tune small LM (CodeBERT or DeepSeek-Coder-1.3B via LoRA) on (goal, tactic) pairs
  - GNN over formula AST (Nazrin-style, 1.5M params, matches domain structure)
  - T5-small/ByT5 transformer (Teammate A recommendation)
- **Training paradigm**: Expert iteration, NOT full online RL
  1. Generate proof attempts via search guided by current model
  2. Verify successful proofs with Lean
  3. Add verified (state, tactic) pairs to supervised training data
  4. Fine-tune model on accumulated data
  5. Repeat
- **Search strategy**: Best-first search (not MCTS) guided by policy + value heads. MCTS deferred to Phase 6.
- **LeanDojo-v2**: Provides `SFTTrainer` and `GRPOTrainer`, supports local Lean 4 projects via `DynamicDatabase`
- **Hardware**: 1x 24GB GPU for SFT/LoRA fine-tuning, 16+ CPU cores for Lean verification
- **Action space**: 42 axiom constructors + 7 inference rules = finite, enumerable action space. The only genuinely open-ended choice is the intermediate formula in `modus_ponens`.

*Deliverables*:
1. Policy network model definition and training script
2. Expert iteration loop implementation (search -> verify -> retrain)
3. Best-first search implementation guided by policy + value network
4. Trained policy model checkpoint with evaluation metrics
5. Evaluation: proof success rate, search efficiency, comparison to symbolic-only search
6. Analysis: what tactics the policy learns to prioritize, modus_ponens lemma selection patterns

*Open questions for sub-task research*:
- Is LeanDojo-v2's GRPOTrainer compatible with Lean v4.27.0-rc1, or do we need a custom training loop?
- What is the right action representation: one-hot over 49 base actions, or include formula arguments?
- How to handle modus_ponens lemma selection (the only high-branching action)?
- How many expert iteration rounds are needed before the model generates novel proofs?
- Should the policy and value networks share parameters (multi-task head) or be separate?
- What is the right search budget per formula during expert iteration (number of expansions)?

**Verification**:
- Sub-task created with clear description, tagged as `lean4` type
- Seed research brief included in task description

---

### Phase 6: Sub-Task -- Full MCTS with AND/OR Backup [NOT STARTED]

**Goal**: Create a sub-task for implementing full AlphaZero-style MCTS with AND/OR hypergraph backup, using the policy and value networks from Phase 5 as initialization.

**Tasks**:
- [ ] Draft sub-task description covering scope, deliverables, and constraints
- [ ] Include seed research brief from team research findings
- [ ] Create the sub-task via `/task` or manual task creation
- [ ] Verify sub-task appears in TODO.md and state.json

**Timing**: 1 hour (task creation only; sub-task implementation is estimated at 12-16 weeks)

**Depends on**: 5

**Sub-Task Seed Research Brief**:

*Scope*: Implement full AlphaZero-style Monte Carlo Tree Search adapted for theorem proving. This means AND/OR MCTS (not standard game-tree MCTS), where states are proof goals, actions are axiom/rule applications, and transitions produce child goals that must ALL be proved (AND-nodes). The backup operator uses a lower-confidence-bound (weakest-link) principle: a state's value equals its weakest child's value. Use the policy and value networks from Phase 5 as initialization, with PUCT for exploration-exploitation balance. This phase is only pursued if Phase 5 demonstrates that neural-guided search outperforms symbolic-only search.

*Key findings from research*:
- **AND/OR structure**: Theorem proving maps to an AND/OR hypergraph search, NOT a standard game tree. The backup operator is NOT minimax -- it uses weakest-link (lower-confidence-bound) principle.
- **PUCT**: Standard AlphaZero UCB formula adapted for AND/OR trees
- **Reference implementations**: Aristotle (Harmonic Team, 2025) provides the most transparent MCTS-for-Lean design; HTPS (Meta AI, NeurIPS 2022) is the foundational AND/OR proof search paper
- **Compute requirements**: This phase requires significant compute (1x A100 80GB, 64+ CPU cores for Lean verification). DeepSeek-Prover-V1.5 used A100 GPUs + thousands of CPU cores for their MCTS approach.
- **Online training**: MCTS generates training data from search trees; the model is updated online during search
- **Lean verification throughput**: Kimina Lean Server at 64 cores gives 0.051s per proof; for MCTS with 100 rollouts x 20 moves = 2,000 calls, that is ~40s per attempt
- **Contingency**: If MCTS does not outperform best-first search (Phase 5), the project still has a publishable result from Phases 4-5

*Deliverables*:
1. AND/OR MCTS implementation with PUCT exploration
2. Weakest-link backup operator for AND-nodes
3. Online training loop from MCTS search trees
4. Integration with Kimina Lean Server or equivalent for high-throughput verification
5. Evaluation: comparison to best-first search (Phase 5), symbolic search, and published baselines
6. Full system benchmark on the evaluation set from Phase 1

*Open questions for sub-task research*:
- What is the right PUCT constant for theorem proving (vs Go/Chess)?
- How to handle the variable branching factor (modus_ponens lemma selection)?
- Should virtual loss be used for parallelization of MCTS rollouts?
- How many rollouts per move are needed for theorem proving (Go uses 800, but proofs may need fewer)?
- Is progressive widening needed to handle the large action space?
- How to balance exploration of novel proof strategies vs exploitation of known patterns?
- What is the right budget for online training (how often to update the networks during search)?

**Verification**:
- Sub-task created with clear description, tagged as `lean4` type
- Seed research brief included in task description

---

## Testing & Validation

- [ ] All 6 sub-tasks created in TODO.md and state.json
- [ ] Each sub-task has a clear description with seed research brief
- [ ] Dependency chain is correctly specified (sub-tasks reference their prerequisites)
- [ ] Task types are correctly set to `lean4` for all sub-tasks
- [ ] Feasibility gate documented for Phase 1 (formula enumerator diversity)
- [ ] Hardware requirements documented for each sub-task

## Artifacts & Outputs

- `specs/201_alphazero_proof_search_harness/plans/01_task-decomposition.md` (this file)
- 6 new sub-tasks to be created via `/task` (each with seed description from this plan)

## Rollback/Contingency

This plan creates sub-tasks only; no code is modified. If the decomposition proves wrong after initial research rounds on the sub-tasks:
- Sub-tasks can be individually abandoned or revised via `/revise`
- The phased approach has explicit off-ramps: if Phase 1 (formula enumerator) fails the feasibility gate, Phases 2-6 are not pursued. If Phase 5 (policy network) does not outperform symbolic search, Phase 6 (MCTS) is not pursued.
- Each sub-task is independently publishable (especially Phases 4 and 5), so partial completion still yields value.
