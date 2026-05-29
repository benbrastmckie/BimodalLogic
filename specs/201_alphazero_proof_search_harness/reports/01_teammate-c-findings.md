# Research Report: Task #201 — Critic Findings

**Task**: 201 - AlphaZero-style training harness for bimodal logic theorem proving
**Role**: Teammate C (Critic) — gap identification, risk assessment, realistic constraints
**Started**: 2026-05-28
**Completed**: 2026-05-28
**Effort**: 4 hours
**Sources/Inputs**: Web research (papers, technical reports), codebase analysis

---

## Executive Summary

The AlphaZero-for-theorem-proving idea is intellectually compelling and well-motivated by recent
successes (AlphaProof, DeepSeek-Prover, HTPS). However, applying it to the bimodal logic TM
formalization in this repository faces a cluster of serious, interacting problems that the
optimistic framing likely underestimates:

1. The corpus is too small and too closed for pure self-play to bootstrap from.
2. Lean verification latency, while manageable at scale, becomes a bottleneck at small CPU counts.
3. The reward signal is genuinely sparse; existing systems address this with massive compute or
   pre-trained LLMs—neither of which is "small training run" territory.
4. There is no documented path from the bimodal TM syntax to a training distribution broad enough
   to support generalization.
5. Every successful system in this space required either massive infrastructure (AlphaProof:
   thousands of TPUs over 2.5 years) or a pre-trained LLM at 7B+ parameters as the backbone
   (DeepSeek-Prover, ReProver).

None of this means the project is impossible. But the framing "set up a training harness" risks
understating the engineering and research difficulty by an order of magnitude.

---

## Key Findings

### 1. Compute Reality: AlphaZero Is Not Small

**Finding**: Every successful MCTS+neural-network theorem proving system in the literature
required either (a) massive cloud infrastructure, or (b) a pre-trained LLM as the backbone that
already encodes mathematical reasoning. The idea that a "small training run" suffices has not been
demonstrated at the level of useful proof search.

**Evidence**:

- **AlphaProof**: 2.5 years of development at Google DeepMind. Test-time compute: "the limit was
  entirely how many TPUs we could get our hands on" (TPU v6e pods). Pre-training involved 12
  trillion tokens of code and mathematical text. The system proved this is tractable—at massive
  scale.

- **DeepSeek-Prover-V1.5**: 7B parameter model, A100-40G GPUs for inference, "thousands of CPU
  cores" for Lean REPL verification. MCTS budget reported as 32×6400 = 192,000 total proof
  generation attempts to achieve 63.5% on miniF2F.

- **ReProver/LeanDojo**: The *minimal* useful configuration is 5 days of training on a single
  A100-80GB GPU (one GPU-week), evaluated on 2 days of eight V100 GPUs. This is the
  retrieve-and-prove approach—no MCTS, no RL, just fine-tuned retrieval—and it achieves ~38%
  on miniF2F.

- **LeanTree**: 59 GPU-hours plus 450 CPU-hours on a node with 8 AMD MI210 accelerators and 192
  CPU cores. Best-first search achieved 26.23% on miniF2F.

- **HTPS**: Online training with MCTS increased Metamath performance from 65.4% to 82.6%. The
  comparable computational budget statement suggests this is not cheap; no actual numbers were
  published, but this is Meta AI research with substantial GPU clusters.

**Critical point**: There is no published result showing MCTS+NN proof search working usefully
from a cold start on a *custom* logic with a *small* model (< 1B parameters) and *limited*
compute (< 8 GPUs). The scaling curves for MCTS in theorem proving likely have a minimum useful
compute threshold that has not been characterized in the literature.

**Confidence**: High.

---

### 2. Lean Verification Is a Real Bottleneck—But Manageable with Sufficient CPUs

**Finding**: Lean type-checking is not free. For MCTS-based proof search, where each node
expansion requires a Lean verification call, the throughput of the verification server becomes
the outer loop bottleneck if the neural network is fast.

**Evidence**:

- **Kimina Lean Server benchmarks (2025)**:
  - 8 CPU cores: 0.272 seconds per proof (average)
  - 16 CPU cores: 0.139 seconds per proof
  - 32 CPU cores: 0.074 seconds per proof
  - 64 CPU cores: 0.051 seconds per proof
  - LRU caching for common imports: ~1.94x speedup
  - REPL initialization overhead is the dominant per-call cost; caching addresses this

- **DeepSeek-Prover-V1.5**: "A cluster with thousands of CPU cores" for Lean REPL; each proof
  attempt given a maximum of 15 seconds.

- **Tactic-level interaction** (not just whole-proof): The Lean LSP and REPL must reload state
  at each step in tactic-mode search. At tactic granularity (one step at a time), REPL
  round-trip is dominated by imports and state serialization. No published latency numbers
  exist for single-tactic steps in an RL loop, but it will be slower than whole-proof
  verification because there are more round-trips per proof.

**For this project**: With 8–16 CPUs and an MCTS tree, throughput is roughly 3–7 verifications
per second (whole-proof). For MCTS with 100 rollouts per move and 20 moves per proof, that is
2,000 Lean calls per proof attempt. At 7 verifications/second, one proof attempt takes ~5
minutes. This is the bottleneck, not the neural network.

At 64 CPUs, the same estimate yields ~39 seconds per proof attempt. Still expensive when
training requires tens of thousands of proof attempts to gather signal.

**Confidence**: High for the per-proof latency numbers; medium for the tactic-level extrapolation.

---

### 3. Reward Signal Sparsity Is Severe and Structural

**Finding**: In theorem proving, the vast majority of proof attempts fail completely—no partial
credit, no gradient signal, no informative feedback. This is categorically harder than Go,
where every game produces a terminal reward.

**Evidence**:

- DeepSeek-Prover-V1.5 explicitly identifies "extremely sparse extrinsic rewards, receiving
  signals only upon complete proof verification" as a core design challenge.

- HTPS used *online training* on the *unproved* theorems specifically to address the cold-start
  problem—provers learn from theorems they cannot yet prove, which at the start is almost
  everything.

- The "sparse reward" problem forces either:
  (a) Process reward models (PRM) that give per-step signals—but PRMs require labeled
      intermediate proof steps as training data, which this project does not have.
  (b) Intrinsic motivation / curiosity-driven exploration (RMaxTS in DeepSeek-Prover-V1.5)—
      but this requires the RL training loop to already be working.
  (c) Subgoal decomposition (DeepSeek-Prover-V2)—but this requires a sufficiently powerful
      base model to propose decompositions.
  (d) Hindsight experience replay—works for first-order logic; application to Lean tactic proofs
      is an open research question.

- LeanTree reported only 18.36% success rate with MCTS rollouts on miniF2F—a benchmark
  consisting of *known, human-written* high-school competition problems. On a custom bimodal
  logic with no external training data, the cold-start success rate is likely near zero.

**Critical implication**: If the system starts from a random or untrained network, essentially
zero proof attempts succeed. Zero successes mean zero positive reward signal. Zero positive
signal means the policy and value network do not improve. This is the cold-start problem in
its starkest form.

**Confidence**: High.

---

### 4. The Domain Has Insufficient Coverage for Self-Play Scaling

**Finding**: AlphaZero works because Go generates unlimited new games automatically. This project
cannot replicate that property—the bimodal logic has a finite and small set of formulas that
are both (a) non-trivially provable and (b) expressible in the current syntax.

**Evidence from the codebase** (analyzed directly):

- The Theories directory contains 217 Lean files.
- There are approximately 2,519 `theorem` or `lemma` declarations across all files.
- However, many of these are infrastructure lemmas (substitution, derivability, semantics
  machinery), not target theorems for proof search.
- The user-facing theorem set (in Theorems/, Examples/, Metalogic/) is much smaller—dozens to
  low hundreds of non-trivial logical theorems.
- The syntax has 6 primitive constructors and ~8 derived operators. The space of well-formed
  formulas is infinite, but the space of *provable* formulas over the TM axiom system is
  constrained by the logic itself.

**The generation problem**:

- Synthetic theorem generation for propositional and first-order logic is tractable (random
  formulas, check satisfiability). For modal logics, "extending to modal logics requires
  nontrivial template engineering and richer deductive engines" (OpenReview finding).

- The bimodal TM logic combines S5 modality with linear temporal logic. Generating interesting,
  non-trivial, non-trivially-equivalent theorems in this logic requires either:
  (a) A forward proof search system that can enumerate derivable formulas.
  (b) Random formula generation + Lean verification (most random formulas will be
      unprovable or trivially equivalent to existing ones).
  (c) Human-authored curriculum—which scales to maybe 1,000 problems with significant effort.

- Existing synthetic generation results show modest improvement: +1.2% on miniF2F from
  synthetic data alone (37.3% -> 38.5%). The benefit is incremental, not transformative.

**Critical gap**: There is no automatic way to generate a curriculum of bimodal TM theorems that
scales to the millions of training examples AlphaZero-style systems typically require.

**Confidence**: High.

---

### 5. Engineering Complexity Is Severely Underestimated

**Finding**: A full AlphaZero-style proof search harness is a multi-component distributed
system. The gap between "set up a training harness" and "working RL loop" is large.

**Required components** (each non-trivial):

1. **Lean REPL server**: A running, parallelized Lean 4 server that accepts proof states and
   returns verification results. This exists (Kimina, lean-repl) but requires configuration and
   integration. The REPL must maintain imports for the bimodal logic library at startup.

2. **Proof state representation**: Converting Lean tactic states (which are Lean-specific AST
   structures) to a format consumable by a neural network. This requires either:
   - Tokenization of Lean syntax (requires a tokenizer trained on Lean)
   - Symbolic encoding (formula embedding, possibly graph neural networks)
   - String-based encoding (crude but used by some systems)

3. **Policy network**: A network that maps proof states to tactic distributions. The action
   space in Lean is enormous and semi-continuous (free-text tactics). Constraining it to the
   bimodal-logic-specific tactic set is necessary but requires manual enumeration.

4. **Value network**: A network that estimates "how close is this state to a proof?" This is
   notoriously hard to train because the value is not smooth—states look similar but have
   vastly different distances to proof.

5. **MCTS implementation**: The search algorithm itself, operating over Lean proof states as
   nodes. Unlike Go, where states are discrete board positions, Lean proof states have
   variable structure and cannot be hashed for transposition tables.

6. **RL training loop**: Asynchronous self-play generation + network updates. Requires careful
   replay buffer design, batch normalization, and convergence monitoring.

7. **Data pipeline**: Converting Lean REPL outputs to training tensors and back.

**Existing tools that help but do not solve the problem**:
- `lean-repl` (GitHub): Provides a REPL interface. Requires Python bindings to be useful.
- `LeanDojo`: Python library for interacting with Lean; supports tactic-state extraction.
  But it is designed for retrieval-based search, not RL.
- `Kimina Lean Server`: High-performance whole-proof verification. Does not support
  tactic-level step-by-step interaction for MCTS.

**Honest engineering estimate**:
- A minimal working prototype (MCTS + random policy, Lean verification, no learning): 1–2
  person-months.
- A working RL loop with policy/value networks, training, and evaluation: 4–8 person-months.
- A system that demonstrably improves over random on the bimodal logic: unknown—the research
  question is whether this is even achievable with the available domain size.

**Confidence**: Medium-high. Based on analogous ML engineering projects; individual factors may vary.

---

### 6. Evaluation Methodology Has No Clear Baseline

**Finding**: There is no existing benchmark or baseline for theorem proving in the bimodal TM
logic. "Success" is undefined in a way that makes progress assessment impossible.

**Issues**:

- miniF2F, ProofNet, and MiniF2F-curriculum are the standard benchmarks in neural theorem
  proving. They cover Lean + Mathlib theorems (high school and undergraduate mathematics). This
  project's bimodal TM logic is not in any standard benchmark.

- The system cannot be compared to existing systems, which means there is no external validation
  of whether the learned policy is doing something useful or overfitting.

- The proofs already in the codebase (the 2,519 theorems) could serve as a test set, but they
  were hand-written with specific tactics. A learned system may find different proof paths that
  are valid but structurally dissimilar, making evaluation non-trivial.

- "Does the system prove new theorems?" is the right evaluation question, but "new" requires
  defining a held-out set of theorems that: (a) are actually true, (b) have not been proved
  in the codebase, and (c) are within reach of the current proof system. Building this
  benchmark is itself a research task.

**Confidence**: High.

---

## Critical Questions (Unvalidated Assumptions)

These are assumptions implicit in the task description that have not been validated:

1. **"This should follow a modern rendition of AlphaZero"**: AlphaZero requires a self-play
   environment with clear terminal states. Is Lean proof search a self-play environment?
   *No*—there is no adversary. This is closer to AlphaGo's single-player mode or puzzle-solving.
   The analogy requires clarification: what is the "game" being played?

2. **"Using Lean for the positive signal"**: Lean provides a binary positive signal (proof
   verified or not). This is correct but sparse. Has anyone validated that binary Lean
   verification is sufficient as the sole reward for RL training without process supervision or
   a pre-trained LLM backbone?

3. **"Value network and prediction network"**: In AlphaZero, these are trained on millions of
   games from a clean state distribution. What is the analogous training distribution here?
   Where does the initial training data come from before self-play generates anything?

4. **"Generator that seeks to prove theorems"**: What is the generator? If it is a randomly
   initialized policy network, its output will be syntactically invalid Lean tactics nearly
   100% of the time. A constrained action space (only known valid tactics for this logic)
   must be defined before training can begin.

5. **"Small training runs"**: This phrase appears in the task context. No system in the
   literature has demonstrated that MCTS+NN proof search works at "small" scale in a novel
   domain. The minimum viable compute threshold is unknown and potentially higher than the
   budget.

---

## Minimum Viable Requirements

If this project is to have any chance of producing a working system, the following are
*necessary* (not sufficient) conditions:

### Computational Floor
- **CPU**: At minimum 32 dedicated CPU cores for Lean REPL verification; 64 preferred.
  Below this, verification throughput is the bottleneck and training is impractically slow.
- **GPU**: At minimum 1 A100-class GPU (80GB) for a model small enough to be useful (7B
  parameters or a smaller domain-specific model).
- **Time**: Expect weeks to months of continuous training, not hours or days.

### Data/Domain Floor
- A synthetic theorem generator for bimodal TM that can produce at least 10,000–100,000
  verifiable (but non-trivial) problems. This is a prerequisite, not a deliverable of the
  harness itself.
- A held-out evaluation set of 500–1,000 theorems of varying difficulty.

### Pre-training Floor
- The policy/value network must be initialized from a model that already understands Lean
  syntax and basic tactic structure, OR the action space must be severely constrained to
  domain-specific tactics. A randomly initialized network will not generate valid tactics.

### Engineering Floor
- A functioning Python–Lean REPL bridge (LeanDojo or similar) that supports tactic-level
  interaction with the bimodal logic library loaded.
- A formalized MCTS implementation that can handle variable-structure proof states as tree
  nodes.
- Reproducible training infrastructure (Docker or Nix environment) before any ML training
  begins.

---

## What Could Make This Work at Smaller Scale

The following modifications could lower the bar significantly:

1. **Abandon MCTS, use best-first search**: MCTS adds substantial implementation complexity
   for unclear benefit in the theorem proving setting. Best-first search (like ReProver) is
   simpler and achieves competitive results.

2. **Use a pre-trained LLM backbone**: Fine-tuning DeepSeek-Prover-V1.5 (7B, open-source)
   on bimodal TM examples is more tractable than training from scratch. The model already
   knows Lean syntax.

3. **Whole-proof generation instead of tactic-level search**: Generate complete proof strings
   and verify with Lean (the DeepSeek V1.5 approach). This avoids the MCTS state space
   complexity and uses faster whole-proof verification.

4. **Scope to a proof sketcher, not a proof finder**: Use the network to suggest tactics for
   a human prover, rather than running autonomous proof search. This removes the RL component
   entirely and reduces to supervised learning on the existing codebase.

5. **Synthetic data generation as the first milestone**: Treat theorem generation as the
   primary research challenge and defer the ML training until the data pipeline is validated.

---

## Confidence Assessment

| Claim | Confidence | Basis |
|-------|-----------|-------|
| AlphaZero-style MCTS requires massive compute | High | Multiple published systems with concrete numbers |
| Lean REPL is a bottleneck at small CPU counts | High | Kimina benchmarks with per-proof latencies |
| Reward signal is severely sparse | High | Explicitly stated in DeepSeek-Prover-V1.5, HTPS |
| ~100 theorems is insufficient training data | High | Literature on data scarcity in NTP; confirmed by codebase count |
| Full system requires 4–8 person-months | Medium | Analogical estimate; engineering specifics vary |
| Evaluation requires custom benchmark construction | High | No existing benchmark for TM bimodal logic |
| Fine-tuning a pre-trained LLM is more tractable | High | Demonstrated by ReProver, DeepSeek-Prover |
| MCTS can be made to work with enough engineering | Medium | Demonstrated at scale; unclear at small scale |

---

## Appendix: Search Queries Used

- AlphaProof compute requirements scale neural theorem proving 2024 2025
- Lean 4 server throughput type checking latency proof search milliseconds
- HTPS hypertree proof search reward sparsity failure rate theorem proving
- Neural theorem proving minimum training data curriculum MCTS small scale failure modes
- Lean REPL proof verification speed seconds per check reinforcement learning pipeline
- ReProver LeanDojo training compute GPU hours theorem proving 2024
- DeepSeek-Prover MCTS proof search GPU compute training scale 2024 2025
- AlphaZero MCTS critical mass minimum scale does not work small compute
- Neural theorem proving small domain few theorems overfitting generalization failure
- Synthetic theorem generation modal logic propositional satisfiability training data generation
- Value network theorem proving training instability convergence failure policy collapse
- Neural theorem proving custom logic domain training from scratch no pretrained model

## References

- [AlphaProof: Olympiad-level formal mathematical reasoning with RL](https://www.nature.com/articles/s41586-025-09833-y)
- [AlphaProof Paper blog analysis](https://www.julian.ac/blog/2025/11/13/alphaproof-paper/)
- [Kimina Lean Server: High-Performance Lean Server for Large-Scale Verification](https://arxiv.org/abs/2504.21230)
- [DeepSeek-Prover-V1.5: Harnessing Proof Assistant Feedback for RL and MCTS](https://arxiv.org/html/2408.08152v1)
- [HyperTree Proof Search for Neural Theorem Proving (HTPS)](https://arxiv.org/abs/2205.11491)
- [LeanDojo: Theorem Proving with Retrieval-Augmented Language Models](https://arxiv.org/abs/2306.15626)
- [LeanTree: Accelerating White-Box Proof Search with Factorized States in Lean 4](https://arxiv.org/html/2507.14722v1)
- [Synthetic Theorem Generation in Lean](https://openreview.net/forum?id=EeDSMy5Ruj)
- [Neural Theorem Provers Do Not Learn Rules Without Exploration](https://arxiv.org/pdf/1906.06805)
- [Training a First-Order Theorem Prover from Synthetic Data](https://arxiv.org/pdf/2103.03798)
