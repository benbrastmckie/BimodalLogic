# Research Report: Task #201 — Teammate D (Horizons)

**Task**: 201 - AlphaZero-Style Training Harness for Bimodal Logic Proof Search
**Role**: Horizons Researcher — Long-term alignment, strategic direction, creative alternatives
**Started**: 2026-05-28T00:00:00Z
**Completed**: 2026-05-28T00:30:00Z
**Effort**: ~2.5 hours equivalent research
**Sources/Inputs**: Codebase (Automation/, ProofSystem/, Metalogic/), WebSearch (8 queries), WebFetch (5 pages)
**Standards**: report-format.md

---

## Executive Summary

- The field has moved decisively past "AlphaZero for provers" as a concept: AlphaProof (2024), DeepSeek-Prover-V2 (2025), and Nazrin (2025) represent the frontier. The raw AlphaZero framing is no longer novel by itself.
- However, the ProofChecker project occupies a uniquely advantaged position: a **bounded, decidable domain** with an existing **tableau-based decision procedure**, handcrafted **pattern success tracking** (SuccessPatterns.lean), and structured **derivation trees** — ingredients that enable a tractable, publishable system at much lower compute cost than general-math provers.
- The highest-value first step is NOT full AlphaZero. It is a **proof-progress value estimator** trained on tableau search traces, feeding back into the existing `modal_search` tactic. This delivers measurable proof-search speedup, generates training data organically, and has a clear publication story.
- Long-term, the most strategically valuable direction is **bidirectional synergy**: neural guidance accelerates tactic search, and tactic success data trains the neural system — a self-reinforcing loop anchored in Lean's verifier as ground truth.

---

## Context & Scope

### What was researched

1. State-of-the-art neural theorem proving systems (AlphaProof, DeepSeek-Prover-V1.5/V2, LeanProgress, Nazrin, Stepwise)
2. Publication landscape for ML + formal verification (ICLR, NeurIPS, CADE, COLM)
3. The ProofChecker codebase: Automation/, Metalogic/Decidability/, SuccessPatterns.lean
4. Architectural patterns relevant to the bounded TM logic domain
5. Creative alternatives to full AlphaZero

### Key Codebase Observations

The project already has building blocks that most neural prover projects have to create from scratch:

- `SuccessPatterns.lean`: A `PatternDatabase` that records formula structural features (`modalDepth`, `temporalDepth`, `impCount`, `complexity`, `topOperator`) and which `ProofStrategy` closed each goal. This is already a shallow value network — it needs a neural backbone, not a redesign.
- `AesopRules.lean`: Forward-chaining axiom set that enumerates the discrete tactic alphabet (exactly 7 strategies: Axiom variants, Assumption, ModusPonens, ModalK, TemporalK). This small action space is a massive simplification vs. general Lean proving.
- `Metalogic/Decidability/`: A complete tableau-based decision procedure with correctness proofs. This can generate unlimited verified training examples without external annotation.
- The derivation tree is a typed inductive structure in Lean — its syntax is machine-readable and structurally well-defined, which makes GNN encoding natural.

---

## Findings

### State of the Art (2024–2026)

**AlphaProof** (DeepMind, 2024, Nature 2025): The flagship system. Uses MCTS over Lean 4 tactic states, with a policy network trained by SFT on ~300k human Mathlib proof steps, then an RL loop where Lean verification provides the win signal. Achieved silver-medal IMO 2024. Key insight: proof search = game where states are tactic goals, moves are tactics, win = Lean accepts proof. Not open-source; requires enormous compute (TPU-scale).

**DeepSeek-Prover-V2** (2025): Introduces *subgoal decomposition* curriculum. Decomposes hard theorems into subgoals using a large LLM, then trains a smaller model with GRPO RL and Lean binary reward. Achieves 88.9% on miniF2F at 671B scale. Key innovation: curriculum from easy subgoals to hard theorems.

**LeanProgress** (2025): A lightweight alternative to full AlphaZero. Trains a 1.3B model to predict *remaining proof steps* from the current tactic state. Combined with a tactic generator's log-probability via `C(s) = 0.2·N(s) + 0.8·P(s)`, achieves +3.8% on Mathlib4. Very relevant: this is essentially a value network without the policy network overhead.

**Nazrin** (2025): GNN applied to atomic tactics in Lean 4. Defines a small finite set of atomic tactics sufficient to prove any provable Lean statement; GNN over proof state graphs predicts which atomic tactic to apply. The small-action-space design directly parallels what TM logic has naturally.

**DeepSeek-Prover-V1.5** (2024): GRPO RL with Lean binary reward + RMaxTS (exploration-driven MCTS with intrinsic novelty rewards for unseen tactic states). Key insight: intrinsic rewards prevent search from getting stuck on already-explored branches.

### The Competitive Landscape for Publication

The "AlphaZero for general math" niche is crowded with billion-parameter models from well-resourced labs. However, **domain-specific applications in formal logic remain essentially open**:

- No published work applies neural proof search specifically to **bimodal or combined modal-temporal logics** in Lean.
- Decidability-exploiting neural training (using the decision procedure as an oracle) has not been done.
- The `SuccessPatterns.lean` architecture (structural pattern keys → strategy selection) anticipates what the field is converging on (Nazrin's atomic tactics + GNN pattern matching), making it publishable as a concrete instantiation.

**Relevant venues**:
- **CADE** (Conference on Automated Deduction) — ideal target; formal methods community
- **LICS** (Logic in Computer Science) — high prestige; focus on logic + computation
- **IJCAR** (International Joint Conference on Automated Reasoning)
- **NeurIPS workshops** (Math-AI, Formal Mathematics workshops) — lower bar, good for early results
- **ICLR** — requires strong empirical baselines; achievable with solid eval framework
- **TABLEAUX** — directly relevant if tableau-guided neural training is the angle

### Unique Structural Advantages of TM Logic

1. **Bounded action space**: The TM proof system has exactly ~10 primitive rules/axioms (MP, Necessitation, BX1-BX6, propositional axioms). This is far simpler than the ~1000+ possible Lean tactics in general Mathlib proving. Nazrin-style atomic tactic GNNs become genuinely tractable.

2. **Decidability as training oracle**: The tableau decision procedure (`Metalogic/Decidability/DecisionProcedure.lean`) can generate *unlimited* verified training examples by enumerating formulas and running the decider. No manual annotation, no dependence on human proof libraries. This is a decisive advantage over Mathlib-scale systems that require human corpus bootstrapping.

3. **Structured derivation trees**: The `DerivationTree` type is an inductive term — it has natural tree topology suitable for GNN or tree-LSTM encoding. Proof states are typed and structurally constrained (unlike arbitrary Lean terms).

4. **Existing partial value function**: `SuccessPatterns.lean` already implements a key-lookup value approximation using `PatternKey` (5 structural features). Replacing the hash-map lookup with a neural network is a drop-in substitution with measurable baseline comparison.

5. **Existing modal/temporal depth metrics**: `Formula.modalDepth`, `Formula.temporalDepth`, `Formula.complexity` are already defined and can serve as initial neural features.

### Neural Architecture Options

**Option A — GNN over Formula AST** (recommended for first publication):
- Nodes: formula subterms; edges: syntactic structure + `□`, `U`, `S` operators
- Message passing encodes modal and temporal operator nesting naturally
- Predict: which ProofStrategy closes the current goal (7-class classification)
- This directly replaces `PatternDatabase.bestStrategyHint` with a generalized neural version
- Training data: enumerate TM formulas, run tableau decider, extract proof traces

**Option B — Progress Estimator (value network only)**:
- Following LeanProgress: predict "remaining tableau steps" from current proof state
- Lighter to train; doesn't require full policy network
- Integrates with `modal_search` scoring as an additive heuristic
- Provides measurable speedup metric without changing proof search architecture

**Option C — Transformer on serialized tactic states**:
- Serialize derivation tree state to text (formula + context + depth)
- Fine-tune a small LM (1B–3B parameters, e.g., DeepSeek-Coder 1.3B)
- Predict next best tactic application
- Higher capability ceiling but requires more compute and less domain-specific

**Option D — MCTS with UCB over DerivationTree nodes** (full AlphaZero):
- Full game-tree: state = (Context, Formula, DerivationTree prefix), move = tactic application
- Policy network: probability distribution over 7 ProofStrategies
- Value network: probability that current state leads to completed proof
- Lean compilation is the win signal
- Requires: training infrastructure, GPU, substantial engineering

---

## Strategic Recommendations

### Recommendation 1: Start with LeanProgress-Style Value Estimator (3–6 months)

**Why**: LeanProgress is the simplest credible neural prover component. Training data is free (enumerate formulas, run decider). The metric is clear (proof search nodes visited, time to proof). The existing `SuccessPatterns.lean` baseline makes for a compelling A/B comparison.

**What to build**:
1. A formula enumerator (generate TM formulas up to modal/temporal depth N)
2. A training data extractor that runs `modal_search` and records (formula, proof_steps, success)
3. A lightweight GNN or MLP over `PatternKey` features that predicts proof-step count
4. Integration with `modal_search`'s heuristic scorer as an additive bonus

**Publication angle**: "Neural guidance for decidable bimodal logic proof search using structural formula features." TABLEAUX 2026 or CADE 2026 are realistic targets.

### Recommendation 2: Exploit Decidability for Unlimited Training Data (months 1–3)

The tableau decision procedure is the crown jewel for ML purposes. Unlike Mathlib-scale work that scrapes human proofs:
- Generate any formula of desired complexity
- Run `decide` or the tableau procedure
- Extract the search trace (states visited, branches closed, proof tree)
- Label: valid/invalid, proof depth, which closure rule fired

This yields a controllable curriculum: start with propositional TM (no modalities), then add □ at depth 1, then temporal operators, then interactions. This is precisely the "curriculum from easy to hard" approach that DeepSeek-Prover-V2 showed is critical.

### Recommendation 3: Treat Neural Guidance and Tactic Library as Complementary, Not Competing

The project roadmap targets `modal_search`, `modal_norm`, `tm_prove` as human-authored tactics. Neural guidance should augment these, not replace them:

- `modal_search` sets the search policy; neural score adjusts heuristic weights
- Neural system's learned strategies can inform which new lemmas to add to the tactic database
- Human proofs in the project are training signal for the neural system (currently ~30+ theorems in Theorems/)
- Neural system's failures identify hard cases that warrant new human-authored lemmas

This bidirectional synergy is the key insight missing from most neural prover framing.

### Recommendation 4: Reserve Full AlphaZero for Phase 2

Full AlphaZero (policy + value + MCTS) is the right long-term architecture but premature as a first step. The feasibility risks are:
- Requires GPU infrastructure
- Policy training needs millions of proof rollouts
- MCTS requires careful implementation (virtual loss, UCB calibration, etc.)

The correct sequencing is: value estimator (Phase 1) → policy network via SFT on existing proofs (Phase 2) → joint MCTS training (Phase 3).

---

## Creative Alternatives

### Alternative A: Formula Difficulty Classifier

**What**: Train a classifier that, given a TM formula, predicts its "proof difficulty bucket" (trivial / easy / medium / hard / intractable-for-current-search).

**Why it's useful**: Enables smart ordering of proof obligations. The Lean file builds could prioritize easy proofs first (reducing compilation time), and hard formulas could trigger deeper search automatically.

**Implementation**: Label formulas with proof-step count from tableau search; train binary or multi-class classifier; integrate as a pre-filter in `modal_search` or `tm_prove`.

**Novelty**: Difficulty prediction for a specific decidable bimodal logic is unpublished territory.

### Alternative B: Counter-model Generator Guidance

**What**: For invalid formulas (those where the decider finds an open branch / countermodel), train a neural system to predict the countermodel structure quickly.

**Why it's interesting**: Countermodel extraction (`CountermodelExtraction.lean`) is already implemented. A neural "fast countermodel predictor" would be a dual system to the proof predictor — and the combination (prove OR refute) is useful for interactive proof development.

**Publication angle**: "Dueling neural networks for bimodal logic: fast proof and countermodel synthesis."

### Alternative C: Proof Sketch Generator

**What**: Following the DeepSeek-Prover-V2 paradigm applied to the TM logic specifically: given a hard theorem (like the completeness theorem parts still using sorry), generate a "proof sketch" as a sequence of subgoals.

**Why it's strategically aligned**: The project's open sorries in `bx_completeness` are exactly the kind of hard goals this could assist with. If the neural system can suggest "try proving auxiliary lemma X first," even a single successful suggestion is high-value.

**Practical scope**: Sketch generation doesn't require training from scratch — a fine-tuned LLM prompted with the TM axiom system and existing theorems may generate useful sketches without any ML training infrastructure.

### Alternative D: Symbolic-Neural Hybrid for Tactic Selection

**What**: Rather than replacing `modal_search`, wrap it with a meta-level selector: given the current proof state, classify it into one of {propositional, modal, temporal, mixed} and dispatch to a specialized sub-tactic. The classification model is the only neural component.

**Why it's accessible**: The classifier can be a simple decision tree or shallow neural net trained on formula structure features. No deep learning infrastructure required. This is the "learned tactic selector" variant — the most computationally accessible option.

**Integration point**: The existing `GoalCategory` enum in `SuccessPatterns.lean` already does manual categorization. A neural categorizer replaces the hard-coded `match` statement.

### Alternative E: Attention Over Derivation Trees

**What**: Use a tree Transformer (as in Tree-LSTM or hierarchical attention models) over the inductive `DerivationTree` type. Each node in the derivation tree is a proof step; attention heads learn which prior steps are most relevant to predicting the next step.

**Why it's creative**: Unlike formula-level GNNs (which encode the goal), derivation-tree attention encodes the *proof construction process* — capturing "which subgoals opened which other subgoals." This is closer to how human proof writers think.

**Uniqueness**: Tree attention over Lean's typed derivation trees (not arbitrary text) has not been published. The inductive type structure gives a natural attention mask (children attend to parents, not siblings).

---

## Long-Term Vision

### v2: Discovery-Assisted Proof Development

If the neural system learns patterns across all TM theorems:
- It could suggest which *new lemmas* would be useful (lemmas that appear often as subgoals in failed proofs)
- It could flag *redundancy* (lemmas that are always provable by existing tactics and don't need explicit entries)
- It could *order the proof development roadmap* by predicted difficulty, helping the human developer prioritize

### v3: Transfer to Related Logics

TM is a specific combination of S5 + linear time. The same architecture applies to:
- S4 + dense time (a weaker combination)
- K + branching time (CTL-like)
- Epistemic + temporal combinations

Training data from TM's decidable fragment can bootstrap models for related logics via transfer learning, since the modal/temporal operator encodings share structure.

### v4: Human Proof Discovery Assistance

The ultimate long-term value: a system that, during interactive Lean proof development, provides real-time feedback like "this proof branch has historically led to dead ends — consider the following alternative subgoal." This is the "GitHub Copilot for formal logic" vision, but specialized to TM logic where the domain knowledge is concentrated enough to be learnable at small scale.

---

## Decisions

1. **The tableau decider should be the primary training data source** (not human proofs alone). This gives unlimited, verified, diversely-distributed data.

2. **The first deliverable should measure search efficiency** (nodes visited, time to proof), not just proof success rate — the existing automation already has high success rate on easy formulas. The neural contribution should be speed.

3. **SuccessPatterns.lean should be the integration point** for any neural component — it already provides the right abstraction (PatternKey → strategy → heuristic bonus).

4. **Full AlphaZero is Phase 3, not Phase 1**. Phases 1 and 2 should yield publishable results independently.

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Tableau decider not generating diverse enough formulas | Medium | Add formula generation with parameterized modal/temporal depth bounds; use random substitution of atoms |
| Neural overhead exceeds search speedup (net negative) | Medium | Profile `modal_search` first; only integrate neural component if search is the bottleneck |
| GPU/infrastructure unavailability | Medium | LeanProgress showed 1.3B models run on personal computers; start with shallow MLP, not LLM |
| Publication competition from large labs | Low | Domain specificity (bimodal TM in Lean) and decidability-oracle advantage are defensible niches |
| Lean MCP / tool integration complexity | Low | Existing lean-lsp MCP tools and the Automation/ directory already provide the right hooks |
| Over-engineering (building full MCTS before value net is validated) | High | Enforce phase gates: value estimator must show measurable speedup before MCTS is built |

---

## Context Extension Recommendations

- **Topic**: Neural-guided proof search integration patterns for Lean 4
- **Gap**: No context file documents how to connect Python ML training infrastructure to Lean 4 proof search (the boundary between Python training loop and Lean tactic integration)
- **Recommendation**: Create `.claude/context/project/lean4/neural-tactic-integration.md` when implementation begins

- **Topic**: Formula enumeration strategies for TM logic
- **Gap**: No documented approach for generating a training corpus of TM formulas with controlled complexity
- **Recommendation**: Document in a context file after enumerator is built

---

## Appendix

### Search Queries Used
1. "AlphaZero theorem proving neural network formal verification 2024 2025"
2. "neural theorem proving modal logic temporal logic machine learning 2024 2025"
3. "AlphaProof Lean 4 reinforcement learning proof search MCTS 2024 2025"
4. "publication venues ML formal verification theorem proving ICLR NeurIPS CADE 2025"
5. "graph neural network formula AST proof search logic 2024 2025"
6. "learned tactic selection neural network Lean proof assistant value network simpler alternatives AlphaZero 2024"
7. "reinforcement learning proof assistant curriculum learning formula difficulty easy to hard logic 2024"
8. "ICLR NeurIPS 2025 2026 neural theorem proving Lean acceptance papers formal math"
9. "DeepSeek-Prover-V2 subgoal decomposition curriculum small scale training data 2025"
10. "neuro-symbolic proof search small domain specialized logic tractable training bimodal temporal modal 2024"

### References

- [AlphaProof: Olympiad-level formal mathematical reasoning (Nature 2025)](https://www.nature.com/articles/s41586-025-09833-y)
- [AlphaProof AI Wiki](https://aiwiki.ai/wiki/alphaproof)
- [DeepSeek-Prover-V1.5: RL + MCTS for Lean](https://arxiv.org/html/2408.08152v1)
- [DeepSeek-Prover-V2: Subgoal Decomposition](https://arxiv.org/abs/2504.21801)
- [LeanProgress: Proof Progress Prediction](https://arxiv.org/html/2502.17925v3)
- [Nazrin: Atomic Tactics GNN for Lean 4](https://arxiv.org/pdf/2602.18767)
- [Neural Theorem Proving (MLNR 2025)](https://arxiv.org/abs/2504.17017)
- [Stepwise: Neuro-Symbolic Proof Search](https://arxiv.org/pdf/2603.19715)
- [DL4TP Survey (COLM 2024)](https://github.com/zhaoyu-li/DL4TP)
- [Graph Representations for HOL Theorem Proving](https://arxiv.org/pdf/1905.10006)
- [Continuous Modal Logical Neural Networks](https://arxiv.org/pdf/2603.04019)
- [Advancing Mathematics Research with AI-Driven Formal Proof Search](https://arxiv.org/html/2605.22763v1)
