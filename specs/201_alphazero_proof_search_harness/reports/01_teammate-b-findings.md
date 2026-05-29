# Research Report: Task #201 — Teammate B (Alternative Approaches)

**Task**: 201 — AlphaZero-style Proof Search Harness for Bimodal Logic TM
**Role**: Teammate B — Alternative Patterns and Prior Art
**Completed**: 2026-05-28
**Sources**: WebSearch, WebFetch, Codebase inspection (Axioms.lean, Derivation.lean)

---

## Key Findings

### 1. The Non-MCTS Landscape Is Richer Than AlphaZero

The dominant paradigm in 2024–2026 neural theorem proving has shifted *away* from pure MCTS toward:

- **Iterative self-play with conjecture generation** (STP, Goedel-Prover)
- **Subgoal decomposition with RL** (DeepSeek-Prover-V2)
- **Proof artifact co-training** (PACT — no RL needed, just self-supervised signals from proof terms)
- **GNN-based atomic tactic networks** (Nazrin — 1.5M parameters, runs on CPU)
- **Retrieval-augmented tactic generation** (LeanDojo ReProver — 1 GPU-week)
- **Proof progress prediction as value network** (LeanProgress — integrates into BFS)

For a *small domain* like bimodal logic TM (finite axiom set, decidable, ~42 axiom constructors, 7 inference rules), several of these are far more tractable than AlphaZero-style MCTS, which was designed for game trees with continuous branching.

### 2. Three Open-Source Harnesses Ready for Adaptation

| Project | URL | Approach | Compute | Notes |
|---------|-----|----------|---------|-------|
| **LeanDojo-v2** | [lean-dojo/LeanDojo-v2](https://github.com/lean-dojo/LeanDojo-v2) | SFT + GRPO + Retrieval | 1 A100 (retriever); scalable | End-to-end: trace → train → prove |
| **ReProver** | [lean-dojo/ReProver](https://github.com/lean-dojo/ReProver) | Retrieval-augmented BFS | 1 A100 80GB (adjustable) | Proven to work on custom Lean4 projects |
| **STP** | [kfdong/STP](https://github.com/kfdong/STP) | Self-play conjecture+proof | TPU v4 (256 cores) | Full training scripts available; requires large compute |
| **Nazrin** | [arXiv:2602.18767](https://arxiv.org/abs/2602.18767) | GNN + atomic tactics | Consumer CPU (1.5M params) | Code pending release post-review; small model |

LeanDojo-v2 is the most actionable starting point: it supports `HFAgent` (local GPU), provides an `SFTTrainer` and `GRPOTrainer`, handles repository tracing automatically, and can ingest a local path rather than requiring a GitHub-indexed corpus.

### 3. HyperTree Proof Search (HTPS) — The Key Non-MCTS Algorithm

HTPS (Meta AI, NeurIPS 2022, [arXiv:2205.11491](https://arxiv.org/abs/2205.11491)) is the closest alternative to pure MCTS and is the conceptual foundation for LeanDojo-v2's proof search:

- **Key difference from MCTS**: HTPS works on *and-or hypergraphs* (proof trees are AND-trees where all subgoals must be proven) rather than game trees (only one branch is "taken"). This is the natural structure for theorem proving.
- **Online training loop**: The model learns from each proof search attempt, including failed ones, not just from successes.
- **Transformer policy only** (no separate value network in the original): The policy scores tactic expansions. A value estimate comes from search statistics rather than a trained critic.
- **Achieved**: 82.6% on Metamath, 42% on miniF2F (from 31% baseline). Code was not open-sourced by Meta.
- **Practical implication**: LeanProgress (see §5 below) adds a trained value-network analog to replace HTPS's search-derived estimates.

### 4. Proof Artifact Co-Training (PACT) — No RL Required

PACT ([arXiv:2102.06203](https://arxiv.org/abs/2102.06203)) extracts self-supervised training signals from proof *terms* (not just tactic sequences) for co-training alongside tactic prediction:

- **Key idea**: Lean's kernel-level proof terms contain rich sub-structure. PACT mines these for auxiliary prediction tasks (type ascription, term completion, subterm prediction) that act as implicit value/policy signals.
- **Result**: Improved from 32% to 48% on held-out theorems without RL.
- **Why relevant here**: The bimodal logic TM derivation trees are explicit Lean 4 `Type` values (`DerivationTree fc Γ φ`). These are inspectable, serializable proof terms — a perfect substrate for PACT-style co-training. Every subderivation is a training signal for the parent proof.

### 5. LeanProgress — A Plug-In Value Network

LeanProgress ([arXiv:2502.17925](https://arxiv.org/abs/2502.17925), TMLR 2025) directly addresses the value network problem:

- **Architecture**: Predicts *number of remaining steps* from the current proof state (a continuous progress signal).
- **Integration**: Plugs into ReProver's best-first search as a heuristic ranker; code is merged into LeanDojo-v2.
- **Performance**: 75.8% accuracy on step prediction; +3.8% improvement on Mathlib4 theorems.
- **For bimodal logic TM**: The derivation tree height (already computed as `DerivationTree.height`) is a perfect ground-truth label for training LeanProgress on TM proofs. The finite axiom set means proof depths are bounded and predictable.

### 6. Nazrin — GNN with Atomic Tactics, Consumer Hardware

Nazrin ([arXiv:2602.18767](https://arxiv.org/abs/2602.18767), Stanford/Northeastern, 2026) is the most hardware-accessible approach:

- **Atomic tactics**: A finite set of elementary tactics (intro, apply, cases, induction, rewritePos, tailArg, motivatedApply, generalizePos, generalizeAt) where each has finitely many parameter choices. This is the natural representation for a logic with a finite axiom set.
- **ExprGraph encoding**: Heterogeneous graphs with α-equivalence (identical subterms share vertices). Four properties: Symmetry, Self-Similarity, Locus Conservation, Condensation.
- **Scale**: 1.5M parameters on Lean standard library, 11M on Mathlib. Trains on a CPU-only machine.
- **Architecture**: Equivariant GNN (5 attention layers, 4 heads) + fixed-point GNN for unseen constants + per-tactic classification heads.
- **57% accuracy** on standard library test slice.
- **Critical insight**: For bimodal logic TM, the axiom set has exactly 42 constructors, all enumerable. Nazrin's "finite parameter choices per atomic tactic" design maps directly onto `Axiom.{modal_t, prop_k, ...}` constructor selection. This is the *most domain-compatible* architecture discovered.

### 7. Self-Play Loop (STP) — Conjecture + Prove

STP ([arXiv:2502.00212](https://arxiv.org/abs/2502.00212), [kfdong/STP](https://github.com/kfdong/STP)) implements a full self-play loop where two roles alternate:

- **Conjecturer**: Generates new theorem variants from seed theorems
- **Prover**: Attempts proofs; successes train both roles
- **Difficulty calibration**: Only conjectures with pass rate in (0, 1/4] survive (barely provable)
- **Elegancy filter**: Conjectures in lowest 20% by proof-length-to-statement-length ratio are discarded
- **24 iterations** for Lean, generating 2M conjectures; proved 28.5% of LeanWorkbook (2× previous best)
- **Compute**: Requires TPU v4 (256 cores) for full runs; not small-scale friendly

**For bimodal logic TM**: The conjecture generation is naturally constrained to the TM grammar (formulas are Lean 4 `Formula` values), making the search space far smaller than Mathlib. A custom conjecturer could enumerate formula combinations under bounded depth — no LLM required for conjecture generation.

### 8. GRPO — The Modern RL Alternative to REINFORCE/PPO

Group Relative Policy Optimization (GRPO) is now the standard RL training algorithm for theorem proving:

- **Idea**: For each theorem, sample K proof attempts; normalize rewards within the group; no critic model needed (unlike PPO).
- **Used in**: DeepSeek-Prover-V1.5, LeanDojo-v2 (GRPOTrainer), Goedel-Prover
- **Key limitation for theorem proving**: GRPO biases toward already-probable solutions; `pass@N` for rare correct proofs is degraded. Recent work (2025) addresses this with constrained variants.
- **Why it matters here**: The LeanDojo-v2 `GRPOTrainer` is drop-in; it takes binary Lean verification feedback as reward signal, which is exactly what Lean's `#check` / `lake build` provides.

### 9. Data Generation for Small Domains

For a custom Lean 4 project like ProofChecker, training data extraction requires:

1. **LeanDojo tracing**: Run `DynamicDatabase` on the local repo to extract `(proof_state, tactic, next_state)` triples from existing proofs in `Theories/Bimodal/`.
2. **Lean4trace augmentation** (ICML 2024): Decomposes composite proof steps, tests automation at each state — directly applicable to derive more training examples from existing TM derivations.
3. **Synthetic generation**: For bimodal logic TM, formulas are generated by the Lean `Formula` inductive type. A generator can enumerate formulas up to bounded subformula depth and invoke the proof system to check provability (decidability applies here).

The project already has extensive proofs in `Theorems/`, `ProofSystem/`, and `Examples/` — these constitute the initial training corpus. LeanDojo can trace them automatically.

### 10. Domain-Specific Advantages of Bimodal Logic TM

This project has structural properties that create advantages over general Lean proving:

| Property | Advantage |
|-----------|-----------|
| **Finite axiom set** (42 constructors) | Atomic tactic parameter space is enumerable; no open-ended premise retrieval needed |
| **7 inference rules** | Proof search branching factor is small and bounded |
| **`DerivationTree` as explicit Type** | Proof terms are inspectable Lean 4 values; height is computable; PACT-style co-training is natural |
| **Decidability** | Completeness is known; failed proof attempts are *informative negatives*, not inconclusive |
| **Frame class parameter** | Three-way `FrameClass` ({Base, Dense, Discrete}) provides a natural curriculum — train Base first, then extend |
| **Temporal duality** | `temporal_duality` rule means every Base proof doubles the training data via its dual |
| **Subformula closure structure** | `Syntax/SubformulaClosure/` provides bounded formula generation for synthetic training data |

The decidability point is especially important: unlike general mathematics, a failed proof search in bimodal logic TM after sufficient steps is a *true negative*, which can be used as a negative training signal. Most theorem proving work ignores this because general Lean proofs are not decidable.

---

## Recommended Approach

### Option A: LeanDojo-v2 + LeanProgress (Best Balance)

**Rationale**: End-to-end harness with SFT + GRPO training, built-in proof search, and plug-in value network.

**Steps**:
1. Install LeanDojo-v2; point it at the ProofChecker repo via `DynamicDatabase`
2. Trace existing proofs from `Theories/Bimodal/` to extract `(state, tactic)` pairs
3. Augment with Lean4trace's step decomposition
4. Train SFTTrainer on extracted data (small base model, e.g., CodeBERT or small GPT-2)
5. Add LeanProgress as value estimator (predict derivation height from proof state)
6. Run GRPOTrainer with Lean verification as binary reward
7. Use ReProver's best-first search with LeanProgress guidance

**Hardware**: 1 consumer GPU (8–24GB); adjustable batch size for smaller memory.

### Option B: Nazrin-style GNN (Most Domain-Compatible)

**Rationale**: Atomic tactics map exactly to TM's finite axiom constructors; runs on CPU; 1.5M parameters.

**Steps**:
1. Build ExprGraph representation for `Formula` and `DerivationTree` nodes
2. Define atomic tactic set = {assumption, axiom(c), modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening} where `axiom(c)` selects from 42 constructors
3. Train equivariant GNN on extracted proof traces
4. Run proof search as a policy network (greedy or beam search)
5. Add LeanProgress-style step predictor as value head

**Hardware**: CPU sufficient for initial training; no GPU required.

**Key limitation**: Nazrin code is not yet released (pending review as of March 2026).

### Option C: Enumeration + PACT Co-Training (No RL, Data-Efficient)

**Rationale**: Exploit proof term structure without RL; most data-efficient for small runs.

**Steps**:
1. Extract all `DerivationTree` instances from existing Lean files
2. Mine subderivations as co-training targets (predict axiom constructor from proof state)
3. Train a small transformer with PACT auxiliary objectives alongside tactic prediction
4. Use beam search for inference (no MCTS)

**Hardware**: Single GPU; minimal compute.

---

## Architecture Comparison

| Approach | Search | Value Network | Policy Network | Min Compute | Code Available |
|----------|--------|--------------|----------------|-------------|----------------|
| Pure AlphaZero/MCTS | MCTS | Separate neural | Separate neural | High | No (original AlphaProof) |
| HTPS | AND-OR hypergraph | Search statistics | Transformer | High | No (Meta proprietary) |
| **LeanDojo-v2 + LeanProgress** | Best-first search | LeanProgress predictor | SFT/GRPO model | Medium (1 GPU) | Yes |
| **Nazrin GNN** | Policy-guided BFS | GNN value head | GNN | Low (CPU) | Soon |
| STP self-play | Beam search | Implicit (pass rate) | LLM fine-tune | Very High (TPUs) | Yes |
| **PACT co-training** | Beam search | Height prediction | Transformer | Low | Partial |
| HER + saturation | Saturation-based | Clause scorer | GNN | Medium | Partial |

Bold = recommended for this project.

---

## Evidence and Examples

### Bimodal Logic TM Proof Term Structure (from codebase inspection)

The `DerivationTree fc Γ φ` type (Derivation.lean) has exactly 7 constructors:
- `axiom` — selects one of 42 `Axiom` constructors (fully enumerable)
- `assumption` — selects a formula from context
- `modus_ponens` — binary branching (the main search branching point)
- `necessitation` — unary, requires empty context
- `temporal_necessitation` — unary, requires empty context
- `temporal_duality` — unary, requires empty context
- `weakening` — unary, requires subset proof

This is an **extremely small action space** compared to Lean's general tactic language. The entire proof search problem reduces to: at each node, choose one of {assumption, axiom(c₁..c₄₂), modus_ponens(with what intermediate formula?), necessitation, temporal_necessitation, temporal_duality, weakening}.

The only genuinely open-ended choice is the intermediate formula in `modus_ponens`. This is precisely where neural guidance (either Nazrin's GNN or a retrieval model) adds value — it narrows the formula space to plausible intermediates.

### LeanProgress for TM Derivations

`DerivationTree.height` is already implemented and computable. For any proof state in a TM derivation, the remaining height is bounded by the subformula closure size (computed in `Syntax/SubformulaClosure/`). This means LeanProgress can be trained on TM proofs with exact labels — far more informative than the approximate step counts used in LeanWorkbook.

### Frame Class Curriculum

The three `FrameClass` values (Base, Dense, Discrete) provide a natural training curriculum:
- Phase 1: Train on Base axioms only (37 axioms, all linear temporal orders)
- Phase 2: Fine-tune on Dense (adds 2 axioms)
- Phase 3: Fine-tune on Discrete (adds 3 axioms: Prior-UZ, Prior-SZ, Z1)

This mirrors curriculum learning approaches like Proving Theorems using HER (ICML 2022), which adapts hindsight experience replay to handle sparse rewards and missing natural difficulty gradients.

---

## Confidence Assessment

| Finding | Confidence |
|---------|-----------|
| LeanDojo-v2 is the best adaptable harness | High — code confirmed, end-to-end |
| Nazrin GNN is most domain-compatible | High — architecture matches TM structure; code pending |
| Bimodal TM's finite axiom set is a major advantage | High — confirmed by codebase inspection |
| PACT co-training is viable without RL | Medium-High — approach confirmed; no TM-specific precedent |
| LeanProgress as value network | High — code in LeanDojo-v2; step labels available from `DerivationTree.height` |
| STP self-play can adapt to TM | Medium — needs custom conjecture generator; full compute is high |
| Decidability enables true negative signals | Medium — theoretically sound; no existing implementation for modal logics |

---

## Open-Source Repository Index

- **LeanDojo-v2**: https://github.com/lean-dojo/LeanDojo-v2
- **ReProver**: https://github.com/lean-dojo/ReProver
- **STP**: https://github.com/kfdong/STP
- **DeepSeek-Prover-V1.5**: https://github.com/deepseek-ai/DeepSeek-Prover-V1.5
- **DeepSeek-Prover-V2**: https://github.com/deepseek-ai/DeepSeek-Prover-V2
- **DL4TP Survey**: https://github.com/zhaoyu-li/DL4TP
- **Nazrin (paper)**: https://arxiv.org/abs/2602.18767

## Key Paper References

- HTPS: https://arxiv.org/abs/2205.11491
- STP: https://arxiv.org/abs/2502.00212
- LeanProgress: https://arxiv.org/abs/2502.17925
- PACT: https://arxiv.org/abs/2102.06203
- Goedel-Prover: https://arxiv.org/abs/2502.07640
- DeepSeek-Prover-V2: https://arxiv.org/abs/2504.21801
- Lean4trace: https://openreview.net/forum?id=sjLWmLeJ6R
- Draft-Sketch-Prove: https://arxiv.org/abs/2210.12283
- HER for Theorem Proving: https://arxiv.org/abs/2112.10664
