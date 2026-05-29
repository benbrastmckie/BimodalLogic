# Research Report: Task #201 — AlphaZero-Style Proof Search Harness

**Task**: 201 — Set up AlphaZero-style proof search harness for bimodal logic
**Date**: 2026-05-28
**Mode**: Team Research (4 teammates)
**Session**: sess_1780027576_cf65c3

---

## Summary

Four researchers investigated the feasibility and design of an AlphaZero-style training harness for bimodal logic TM. The unanimous finding is that **full AlphaZero is the wrong Phase 1** — but a phased approach starting with a value estimator is both tractable and publishable. The bimodal TM logic has decisive structural advantages over general Lean proving (finite action space, decidability, existing pattern database), but the critic identified real constraints around compute, corpus size, and engineering complexity that must be respected.

The recommended path: **LeanProgress-style proof-progress predictor → policy network via SFT on generated data → full MCTS (Phase 3 only)**. Each phase is independently publishable and builds infrastructure for the next.

---

## Key Findings

### 1. The MDP Formulation Is Well-Understood

Theorem proving maps to an **AND/OR hypergraph search** (not a standard game tree). States are proof goals `(FrameClass, Context, Formula)`, actions are the 42 BX axiom instantiations + 7 inference rules, and transitions produce child goals that must ALL be proved (AND-nodes). The Aristotle system (Harmonic Team, 2025) provides the most transparent implementation reference.

The backup operator is NOT minimax — it uses a lower-confidence-bound (weakest-link) principle: a state's value equals its weakest child's value. This is a critical implementation detail missed by naive AlphaZero ports.

**Confidence**: High (confirmed across Teammate A + B sources: Aristotle, HTPS, LeanTree).

### 2. Bimodal TM Has Exceptional Structural Advantages

The project occupies a uniquely favorable position for neural proof search:

| Property | Advantage |
|----------|-----------|
| **42 axiom constructors + 7 rules** | Action space is finite and enumerable (~50-200 branching factor, comparable to Go) |
| **`DerivationTree.height`** | Exact value-network labels for free (steps-to-completion) |
| **Decidability** | Tableau decider generates unlimited verified training data without human annotation |
| **`SuccessPatterns.lean`** | Existing shallow value function (`PatternKey → ProofStrategy`) provides a baseline to beat |
| **Three `FrameClass` values** | Natural curriculum: Base → Dense → Discrete |
| **Temporal duality** | Every Base proof doubles training data via its dual |

The only genuinely open-ended choice in proof search is the intermediate formula in `modus_ponens` — this is precisely where neural guidance adds value.

**Confidence**: High (confirmed by codebase inspection across Teammates B + D).

### 3. Full AlphaZero Requires Massive Compute — But Simpler Approaches Don't

The critic documented concrete compute requirements from published systems:

| System | Compute | Approach |
|--------|---------|----------|
| AlphaProof | Thousands of TPU v6e pods, 2.5 years | Full MCTS + RL |
| DeepSeek-Prover-V1.5 | A100 GPUs + thousands of CPU cores | MCTS + GRPO |
| ReProver | 1 A100-80GB week | Retrieval + BFS (no MCTS, no RL) |
| LeanProgress | 1 GPU, 80k trajectories | Value estimator only |
| Nazrin | CPU-only, 1.5M params | GNN + atomic tactics |

**Critical finding**: No published result shows MCTS+NN proof search working from a cold start at small compute in a custom domain. However, value estimators (LeanProgress) and retrieval-based approaches (ReProver) DO work at small scale. The phased approach avoids the compute cliff.

**Confidence**: High (Teammate C, with concrete per-system numbers).

### 4. The Corpus Size Problem Is Solvable Via the Decision Procedure

The codebase has ~2,519 theorem/lemma declarations, but only dozens to low hundreds of non-trivial target theorems. This is 3-4 orders of magnitude too small for pure self-play.

**Resolution**: The tableau decision procedure (`Metalogic/Decidability/`) can generate unlimited training examples:
1. Enumerate TM formulas up to bounded modal/temporal depth
2. Run the decider → labels each formula as provable/unprovable
3. For provable formulas, extract the proof trace (states visited, rules applied, proof depth)
4. For unprovable formulas, extract the countermodel (true negative training signal)

This sidesteps the corpus problem entirely — the training distribution is controlled, diverse, and unlimited. The `SubformulaClosure/` module provides bounded formula generation infrastructure.

**Conflict noted**: Teammate C flagged this as "nontrivial template engineering." Teammate D argued it's tractable given the existing codebase infrastructure. Resolution: the formula enumerator is a concrete Phase 0 deliverable with its own feasibility gate.

### 5. Three Viable Open-Source Harnesses Exist

| Harness | Best For | Status |
|---------|----------|--------|
| **LeanDojo-v2 + LeanProgress** | End-to-end training pipeline with SFT + GRPO | Production-ready, works on custom Lean 4 projects |
| **Nazrin GNN architecture** | Domain-compatible model design (atomic tactics match TM's action space) | Paper published, code pending |
| **PACT co-training** | Data-efficient, no RL needed (mine DerivationTree instances as self-supervised targets) | Approach proven, no TM-specific implementation |

LeanDojo-v2 is the strongest starting point: it supports local Lean 4 projects via `DynamicDatabase`, provides `SFTTrainer` and `GRPOTrainer`, and has LeanProgress integrated for value estimation.

### 6. The Lean REPL Throughput Bottleneck Is Real But Manageable

Kimina Lean Server benchmarks (2025):
- 8 CPU cores: 0.272s per proof
- 64 CPU cores: 0.051s per proof
- LRU caching: ~1.94x speedup on repeated imports

For tactic-level MCTS (100 rollouts × 20 moves = 2,000 calls per attempt), this yields ~5 min/attempt at 8 cores or ~40s at 64 cores. The bottleneck is verification, not the neural network.

**Mitigation**: Pre-generate training data offline using the symbolic search engine (Automation/ProofSearch/Core.lean), avoiding online Lean calls during training. Use Kimina Lean Server for evaluation only.

### 7. Expert Iteration Is the Right Training Paradigm

All sources converge: the correct starting point is **expert iteration** (not full online RL):

1. Generate proof attempts via search guided by current model
2. Verify successful proofs with Lean
3. Add verified (state, tactic) pairs to supervised training data
4. Fine-tune model on accumulated data
5. Repeat

This avoids the cold-start problem (the symbolic search engine provides initial data), the reward sparsity problem (supervised signal from successful proofs), and the compute cliff (supervised training is much cheaper than RL).

---

## Synthesis

### Conflicts Resolved

1. **Architecture choice** (Transformer vs GNN):
   - Teammate A recommended T5-small/ByT5 transformer
   - Teammates B + D recommended GNN over formula AST (Nazrin-style)
   - **Resolution**: Start with the simpler approach. A shallow MLP/GNN over `PatternKey` features (already computed by `SuccessPatterns.lean`) for Phase 1. Upgrade to GNN over full formula AST or transformer in Phase 2. The existing `PatternKey` → `ProofStrategy` abstraction is the right integration point.

2. **Training data source**:
   - Teammate A: cold-start from existing IDDFS/best-first search traces
   - Teammate B: LeanDojo tracing of existing proofs
   - Teammate C: need synthetic generator (10K-100K problems minimum)
   - Teammate D: tableau decision procedure as unlimited oracle
   - **Resolution**: Use ALL sources in a pipeline. (1) LeanDojo traces existing codebase proofs for initial SFT data. (2) Tableau decider generates synthetic training corpus for broader coverage. (3) Expert iteration loop generates new proofs over time. Phase 0 validates the synthetic generator feasibility.

3. **Is small compute viable?**
   - Teammate C: no published result at small scale
   - Teammates A, B, D: domain advantages lower the bar
   - **Resolution**: The critic is right about full AlphaZero, but wrong about the phased approach. LeanProgress (1 GPU, 80K trajectories) and Nazrin (CPU-only, 1.5M params) prove that simpler approaches work at small scale. The bimodal TM domain is MORE tractable than general Lean, not less. Phase 1 does not require MCTS or RL.

### Gaps Identified

1. **No benchmark exists** for TM logic proof search. Must build a held-out eval set as Phase 0 deliverable.
2. **Formula enumerator** for training data generation needs implementation and diversity validation.
3. **Python-Lean bridge** for tactic-level interaction with the bimodal library loaded has not been tested.
4. **Lean REPL latency** for single-tactic steps (vs whole-proof) has no published numbers.
5. **Engineering timeline** is 4-8 person-months for a full working system (Teammate C estimate).

---

## Recommendations

### Phase 0: Foundation (1-2 months)

**Deliverables**:
1. **Formula enumerator**: Generate TM formulas at controlled modal/temporal depth. Run tableau decider for provability labels and proof traces. Target: 10K-50K labeled formulas.
2. **Evaluation benchmark**: Hold out 500-1K formulas of varying difficulty.
3. **Python-Lean bridge validation**: Confirm LeanDojo-v2 or lean-interact works with the ProofChecker project loaded.
4. **Training data extraction**: LeanDojo trace existing proofs from `Theories/Bimodal/` for initial supervised data.

**Feasibility gate**: If formula enumerator cannot produce diverse, non-trivial formulas at scale, reassess the approach before investing in neural infrastructure.

### Phase 1: Value Estimator (2-3 months)

**Architecture**: Predict proof-step count from formula structure.
- Input: `PatternKey` features (modalDepth, temporalDepth, impCount, complexity, topOperator) — already computed
- Model: Shallow MLP or GNN (1.5M-10M params, CPU-trainable)
- Labels: `DerivationTree.height` from successful proofs
- Integration: Additive bonus to `modal_search` heuristic scorer
- Evaluation: Nodes visited / time-to-proof on benchmark vs `SuccessPatterns.lean` baseline

**Publication target**: TABLEAUX 2026 or CADE 2026. "Neural guidance for decidable bimodal logic proof search."

### Phase 2: Policy Network + Expert Iteration (3-4 months)

**Architecture**: Tactic predictor via SFT on proof traces.
- Fine-tune small model (CodeBERT or DeepSeek-Coder-1.3B via LoRA) on (goal, tactic) pairs
- Use GRPOTrainer from LeanDojo-v2 with Lean binary verification as reward
- Expert iteration loop: search → verify → retrain
- Best-first search (not MCTS) guided by policy + value heads

### Phase 3: Full MCTS (4-6 months, only if Phase 2 succeeds)

**Architecture**: AlphaZero-style AND/OR MCTS with PUCT.
- Policy + value networks from Phase 2 as initialization
- MCTS with AND/OR backup (weakest-link principle)
- Online training from search trees
- Lean verification via Kimina Lean Server (64+ CPU cores)

### Minimum Viable Hardware

| Phase | GPU | CPU | Time |
|-------|-----|-----|------|
| Phase 0 | None | 8+ cores | 1-2 months |
| Phase 1 | Optional (CPU ok) | 8+ cores | 2-3 months |
| Phase 2 | 1x 24GB GPU | 16+ cores | 3-4 months |
| Phase 3 | 1x A100 80GB | 64+ cores | 4-6 months |

### Creative Alternatives Worth Exploring

From Teammate D's horizons analysis:
1. **Dueling networks**: Proof predictor + countermodel generator as competing systems
2. **Attention over derivation trees**: Tree transformer over typed `DerivationTree` nodes (unpublished architecture)
3. **Formula difficulty classifier**: Predict proof complexity before searching (simpler than value net)

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary (architecture + MDP) | completed | high | AND/OR hypergraph formulation, Lean interface tier comparison, expert iteration training loop |
| B | Alternatives (prior art + codebases) | completed | high | LeanDojo-v2/Nazrin/PACT harness comparison, domain advantage analysis, GRPO as modern RL |
| C | Critic (gaps + risks) | completed | high | Compute reality check, Lean throughput numbers, engineering timeline, cold-start severity |
| D | Horizons (strategy + vision) | completed | medium-high | SuccessPatterns.lean integration, publication venue analysis, phased roadmap, creative alternatives |

---

## Key Tools and References

### Open-Source Harnesses
- **LeanDojo-v2**: End-to-end SFT + GRPO training
- **ReProver**: Retrieval-augmented best-first search (1 A100 week)
- **Nazrin**: GNN + atomic tactics (CPU, 1.5M params) — code pending
- **DeepSeek-Prover-V1.5/V2**: MCTS + GRPO (7B+, open-source)

### Python-Lean Interface
- **lean-interact**: Simple REPL wrapper (`pip install lean-interact`)
- **PyPantograph**: Rich tactic-state API with metavariable coupling
- **Kimina Lean Server**: High-performance cached worker pool for RL training

### Key Papers
1. Aristotle (Harmonic Team, 2025) — Most transparent MCTS-for-Lean design
2. HTPS (Meta AI, NeurIPS 2022) — Foundational AND/OR proof search
3. LeanProgress (2025) — Value network as distance-to-goal
4. Nazrin (2025) — GNN with atomic tactics, 1.5M params
5. DeepSeek-Prover-V2 (2025) — Subgoal decomposition + GRPO
6. PACT (2021) — Self-supervised co-training on proof artifacts
7. ReProver/LeanDojo (NeurIPS 2023) — Retrieval-augmented tactic generation

### Publication Venues
- TABLEAUX 2026 / CADE 2026 (ideal for decidable-logic angle)
- LICS (high prestige, logic + computation)
- NeurIPS Math-AI Workshop (lower bar, good for early results)
- ICLR (requires strong empirical baselines)
