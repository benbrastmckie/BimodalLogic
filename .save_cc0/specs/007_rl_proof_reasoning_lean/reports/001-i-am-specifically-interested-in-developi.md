# RL Training Loops for AI Systems in LEAN 4 Proof Systems: Research Report

## Metadata
- **Date**: 2025-12-01
- **Agent**: research-specialist
- **Topic**: Reinforcement learning training loops for AI theorem proving in LEAN 4-implemented proof systems
- **Report Type**: Comparative analysis and architectural recommendations
- **Research Complexity**: 2
- **Workflow**: research-only

## Executive Summary

This research reveals that **a hybrid Python+LEAN 4 architecture is strongly recommended for RL training loops** targeting LEAN 4 proof systems. Unlike the previous report's conclusion that pure LEAN 4 is optimal for proof-checker implementation, RL training specifically benefits from Python's mature ML ecosystem (PyTorch, JAX, Hugging Face) while leveraging LEAN 4 as a formal verification environment. The dominant pattern across all successful systems (AlphaProof, DeepSeek-Prover-V2, LeanDojo/ReProver, Goedel-Prover) uses **process-based communication** where Python orchestrates training while LEAN 4 provides binary reward signals through proof verification. Key findings:

1. **Process-Based Architecture is Standard**: All state-of-the-art systems use subprocess/LSP communication rather than FFI
2. **Python Handles ML Training**: PyTorch/JAX for RL algorithms (GRPO, PPO), data pipelines, model training
3. **LEAN 4 as Verification Oracle**: Binary accept/reject signals serve as reward mechanism
4. **Three Integration Options**: LeanDojo (gym-like environment), LeanInteract (REPL-based), Pantograph (MCTS-optimized)
5. **Reward Shaping Critical**: Progress prediction, unlikeliness rewards, and structural consistency rewards address sparse reward problem
6. **Expert Iteration + Curriculum Learning**: State-of-the-art approach combines synthetic data generation with progressive difficulty
7. **Proof State Representation**: Abstract syntax trees (ASTs), proof states with premises via retrieval augmentation

**Recommendation**: Implement proof-checker in pure LEAN 4 (per previous report), but build separate Python-based RL training infrastructure using LeanDojo or Pantograph for gym environment, communicating via process-based interface.

## Findings

### 1. State-of-the-Art Systems Using RL with LEAN 4

#### 1.1 AlphaProof (Google DeepMind, 2024-2025)

**Overview:**
- Published in Nature (November 2025): "Olympiad-Level Formal Mathematical Reasoning with Reinforcement Learning"
- Achieved silver medal performance at IMO 2024 (28/42 points)
- Solved P6, the hardest problem (only 5/609 human participants succeeded)
- First AI to reach medal-worthy performance on formal math competition problems

**Training Architecture:**
- **Pre-training**: 300 billion tokens of general code and mathematical text
- **Supervised Phase**: 300,000 expert-written math proofs in LEAN environment
- **Synthetic Data Generation**: Second network formalizes 1 million natural language theorem statements into 80 million distinct LEAN statements
- **RL Phase**: AlphaZero-inspired agent learns to find formal proofs through RL by training on millions of auto-formalized problems
- **Test-Time RL**: Generates and learns from millions of related problem variants at inference time for deep, problem-specific adaptation

**Key Innovation - Product Nodes:**
- AlphaZero-style tree search adapted for LEAN proof structure
- Product nodes handle multiple independent sub-goals (e.g., induction cases)
- Tracks which sub-goals are complete, focuses compute on hardest remaining branches
- Enables efficient parallel exploration of proof branches

**Reward Mechanism:**
- Binary reward: LEAN compiler accepts proof (success) or rejects (failure)
- Optimizes for shorter, more elegant proofs during training
- Test-time RL creates problem-specific reward landscape

**Architecture Pattern:**
- Language model coupled with AlphaZero RL algorithm
- LEAN as formal verification environment
- Training phases: general pre-training → expert demonstrations → synthetic data RL → test-time adaptation

#### 1.2 DeepSeek-Prover Series (DeepSeek AI, 2024-2025)

**DeepSeek-Prover-V1 (May 2024):**
- Base model: DeepSeekMath 7B
- 46.3% accuracy on miniF2F-test with 64 samples (whole-proof generation)
- Trained on 8 million synthetic formal statements
- Outperformed GPT-4 (23.0%) and previous RL methods (41.0%)

**DeepSeek-Prover-V1.5 (August 2024):**
- Enhanced with Monte-Carlo Tree Search (MCTS) integration
- RMaxTS: Variant using intrinsic-reward-driven exploration for diverse proof paths
- Truncate-and-resume mechanism: Scheduled truncation points via tree search policy
- Reward-free exploration algorithm addresses reward sparsity in proof search

**DeepSeek-Prover-V2 (April 2025) - State-of-the-Art:**
- Base model: DeepSeek-V3 671B parameters
- **Performance**: 88.9% pass ratio on MiniF2F-test, 49/658 problems on PutnamBench
- Open-source: Available on [GitHub](https://github.com/deepseek-ai/DeepSeek-Prover-V2) and [Hugging Face](https://huggingface.co/deepseek-ai/DeepSeek-Prover-V2-671B)

**Training Pipeline (Two-Stage):**

*Stage 1 - Expert Iteration with Curriculum Learning:*
1. **Cold-Start Dataset**: DeepSeek-V3 decomposes theorems into high-level proof sketches
2. **Recursive Proving**: 7B model handles proof search for each subgoal (reduces compute)
3. **Data Accumulation**: Successful proofs iteratively added to SFT dataset with progressively increasing difficulty
4. **Chain-of-Thought Pairing**: Complete step-by-step formal proofs paired with CoT reasoning

*Stage 2 - Reinforcement Learning (GRPO):*
1. **Group Relative Policy Optimization**: Eliminates separate critic model
2. **Binary Reward**: 1 if LEAN verifies proof as correct, 0 otherwise
3. **Structural Consistency Reward**: Enforces inclusion of planned subgoals (early consistency reward punishes structural misfitting)
4. **Sampling**: 256 problems per iteration, 32 candidate proofs per theorem, max 32,768 tokens
5. **Verification**: LEAN Prover serves as reward supervision

**Python-LEAN 4 Integration:**
- Training framework in Python (PyTorch/JAX implied but not explicitly stated)
- LEAN 4 as verification oracle via subprocess calls
- Model weights and inference code in Python ecosystem

**Key Innovations:**
- Subgoal decomposition with formal and informal reasoning integration
- NL-FL bootstrapping: Transfer informal reasoning capabilities to LEAN 4 proof writing
- Curriculum learning via difficulty-ranked synthetic problems

#### 1.3 LeanDojo and ReProver (Caltech/Stanford, 2023-2025)

**LeanDojo Framework:**
- Python library for learning-based theorem provers
- Supports both LEAN 3 and LEAN 4
- Two main features: (1) Data extraction from LEAN repos, (2) Programmatic interaction with LEAN

**Gym-Like Environment:**
```python
# Conceptual API structure
state = initialize(theorem)  # Returns initial proof state
action = model.generate_tactic(state, premises)  # Generate next tactic
new_state, reward, done = environment.step(action)  # Apply tactic, get feedback
```

- `initialize(theorem)`: Returns initial state (string representing proof goals and local contexts)
- Valid state: Current proof goals + local contexts
- Feedback: Success, error message, or proof completion
- Iterative process: Apply tactics to decompose states into simpler sub-states until all solved

**Proof State Representation:**
- String format: Current proof goals and local contexts
- Fine-grained annotations of premises in proofs
- Premise selection data (key bottleneck in theorem proving)

**LeanDojo Benchmark:**
- **LEAN 3**: 98,734 theorems/proofs, 217,776 tactics, 130,262 premises from mathlib
- **LEAN 4**: 122,517 theorems/proofs, 259,580 tactics, 167,779 premises from mathlib4

**ReProver Model Architecture:**
- Retrieval-augmented prover
- Given proof state → retrieves premises from math library
- Concatenates state + retrieved premises → encoder-decoder Transformer
- Generates next tactic conditioned on state and premises
- Trained on LeanDojo Benchmark data

**Usage Pattern:**
1. Trace LEAN repository (one-time per repo, cached for future use)
2. Extract proof data (states, tactics, premises)
3. Train ML model on extracted data
4. Deploy model to interact with LEAN programmatically
5. Optional: Use for RL training with gym-like interface

**Related Work:**
- TacticZero: "Learning to prove theorems from scratch with deep reinforcement learning" (NeurIPS 2021)

#### 1.4 Goedel-Prover (2024-2025)

**Overview:**
- Open-source series of LLMs for synthesizing complete formal proofs in LEAN 4
- Integrates expert iteration, scaffolded data synthesis, verifier-guided self-correction
- Addresses insufficient large-scale formally verified mathematical datasets

**Training Approach:**

*Expert Iteration:*
- Iteratively refine prover model
- Successful proofs added to training dataset
- Stepwise proof system for LEAN 4

*Scaffolded Data Synthesis for Curriculum Learning:*
- `extract_goal` feature: Mine failing subgoals from incorrect proofs
- Convert subgoals into easier, focused theorem-proving tasks
- Rank synthetic problems by difficulty
- Dataset expansion with progressively harder problems

*Verifier-Guided Self-Correction:*
- Compiler errors processed and fed back through long CoT prompts
- Correction loops until valid proof achieved or budget exhausted
- Time/memory constraints prevent infinite loops

**Block Training and Curriculum Sorting:**
- Block training enhances in-context learning ability
- Curriculum data sorting: Learn from easy to hard data
- Helps LLMs learn unfamiliar LEAN 4 theorem proving tasks

**Python Integration:**
- Python orchestrates training loop
- LEAN 4 provides verification feedback
- Process-based communication for error messages and success signals

#### 1.5 Additional Notable Systems

**LEAN-GitHub Dataset (July 2024):**
- Large-scale formal data from 8,639 LEAN 4 repos on GitHub
- Successfully extracted 6,352 files, 42,000 theorems
- Final dataset: 2,133 files, 28,000 theorems with valid tactic information
- InternLM-math-plus fine-tuned on this: 48.8% accuracy (single pass), 54.5% (64 passes) on miniF2F-test
- Surpassed previous SOTA (52%)

**Lean4trace (June 2024):**
- Open-source tool for training data extraction
- Deeply integrated into LEAN elaborator
- On-the-fly proof modification
- **Data Augmentation Methods:**
  1. Decomposing composite proof steps into simpler steps
  2. Testing existing proof automation tactics at each state, collecting successful ones
- Enables richer training datasets from existing LEAN code

**LeanNavigator (2025):**
- Generates theorems by traversing state graphs
- Interactive LEAN client + embedding-based-retrieval for tactic generation
- Applied to Mathlib4: Generated 4.7M theorems, 1B tokens
- Exceeds ReProver dataset (57M tokens) by order of magnitude
- Trained model outperforms state-of-the-art ReProver

**LeanProgress (February 2025):**
- Addresses RL impracticality due to combinatorial explosion of tactic sequences
- **Proof Progress Prediction**: Predicts remaining steps in proof trees
- Balances data distribution for training
- Takes proof state + optional proof history → predicts exact remaining steps
- Training: DeepSeek Coder V1 1.3B with MSE loss and AdamW optimizer
- Provides lightweight progress signal for search guidance (alternative to full RL)

**Lean-STaR:**
- Framework for training models to produce informal thoughts before proof steps
- Uses retrospective ground-truth tactics to generate synthetic thoughts
- Applies expert iteration: Fine-tune on correct proofs sampled and verified by LEAN

**ABEL System:**
- Three components: (1) Programming interface based on Aesop for proof search organization in LEAN 4, (2) HTPS proof search (AlphaZero-inspired), (3) Online retraining mechanism
- Policy model and critic model trained using ReProver's language model

### 2. Python-LEAN 4 Integration Tools and Architectures

#### 2.1 LeanDojo (Most Mature for RL)

**Interface Type:** Process-based via LEAN subprocess
**Primary Use Case:** ML/AI theorem proving, RL training, data extraction

**Key Features:**
- Traced repository system (one-time processing, cached results)
- Gym-like environment for RL agents
- Data extraction: Proof states, tactics, premises, ASTs, file dependencies
- Python library supports both LEAN 3 and LEAN 4
- Programmatic interaction with proof environment

**RL Training Pattern:**
```python
# Conceptual workflow
repo = LeanDojo.trace(project_path)  # One-time tracing
dataset = repo.extract_data()  # Extract training data

# Training loop
for episode in training_episodes:
    state = env.initialize(theorem)
    while not done:
        action = policy(state, premises)  # RL policy generates tactic
        state, reward, done = env.step(action)  # LEAN verifies
        buffer.add(state, action, reward)
    policy.update(buffer)  # Update RL policy
```

**Advantages for RL:**
- Mature ecosystem with benchmarks (98K+ theorems LEAN 3, 122K+ theorems LEAN 4)
- ReProver model provides baseline architecture
- Established data extraction pipeline
- Community support and documentation

**Citation:**
- Paper: "LeanDojo: Theorem Proving with Retrieval-Augmented Language Models" (NeurIPS 2023)
- Website: https://leandojo.org/

#### 2.2 LeanInteract (REPL-Based)

**Interface Type:** LEAN REPL (Read-Eval-Print Loop)
**Primary Use Case:** Direct code execution, benchmarks (MiniF2F, ProofNet), data extraction

**Key Features:**
- Seamless Python interaction through LEAN REPL
- Supports LEAN v4.8.0-rc1 through v4.26.0-rc2
- Cross-platform (Windows, macOS, Linux)
- **Data extraction capabilities (v0.9.0+)**: Extract declarations and info trees for dataset building
- **Incremental + Parallel elaboration (v0.9.0+)**: Reuse partial computations, enable Elab.async
- AutoLeanServer: Experimental subclass with automatic crash recovery and memory monitoring for multiprocessing

**Architecture:**
- LeanServer wrapper around LEAN REPL
- `run()` method for command execution
- Backports latest REPL features to older LEAN versions

**Advantages:**
- Simple setup, abstracts LEAN complexity
- Memory monitoring useful for large-scale RL training
- Automatic recovery from crashes (AutoLeanServer)

**Use Case for RL:**
- Data extraction for building training datasets
- Simpler interaction model for prototyping
- Less feature-rich than LeanDojo for gym-like RL environments

**Citation:**
- Published by Poiroux, Kuncak, and Bosselut (2025)
- GitHub: https://github.com/augustepoiroux/LeanInteract
- PyPI: https://pypi.org/project/lean-interact/

#### 2.3 leanclient (LSP-Based)

**Interface Type:** Language Server Protocol (LSP)
**Primary Use Case:** IDE-like interactions, batch processing

**Key Features:**
- Thin wrapper around native LEAN 4 language server
- Uses LSP for communication
- Synchronous requests with parallel batch processing
- **Fast**: >95% time spent waiting (minimal overhead)
- Author: Oliver Dressler

**Architecture:**
- LEAN LSP server runs in subprocess
- Python client sends LSP requests
- Efficient for batch operations

**Advantages:**
- Minimal overhead (>95% time in waiting)
- Standard protocol (LSP) ensures stability
- Good for batch processing multiple theorems

**Limitations for RL:**
- LSP not designed for iterative tactic application
- Less suitable than LeanDojo's gym interface for RL training
- Better for static analysis than dynamic proof search

**Citation:**
- GitHub: https://github.com/oOo0oOo/leanclient
- PyPI: https://pypi.org/project/leanclient/ (January 2025)

#### 2.4 Pantograph / PyPantograph (MCTS-Optimized)

**Interface Type:** Three interfaces - (1) PyPantograph (Python), (2) REPL, (3) C FFI
**Primary Use Case:** Monte Carlo Tree Search, advanced proof search algorithms, RL with offline triplets

**Key Features:**
- Written entirely in LEAN 4 (no external dependencies like Docker)
- Optimized for incremental tactic execution (MCTS-friendly)
- **Offline RL Support**: Extracts (before, after, tactic) triplets from LEAN files
- Three interfaces enable flexible integration
- Faster interaction than LeanDojo (native LEAN 4 implementation)

**Architecture Improvements over LeanDojo:**
- No Docker dependency
- Native LEAN 4 implementation improves speed
- Structured access to LEAN files via PyPantograph

**MCTS Integration:**
- Incremental tactic execution enables tree search
- Efficient proof state management
- Supports backtracking and branching exploration

**Offline RL Feature:**
- Runs LEAN 4 compiler on file
- Collects all tactics
- Returns list of (before_state, after_state, tactic) triplets
- Format conducive to offline RL training (behavior cloning, offline policy learning)

**Advantages for RL:**
- Superior for MCTS-based RL (AlphaZero-style)
- Offline RL data extraction built-in
- Faster than LeanDojo
- No external dependencies simplifies deployment

**Citation:**
- Paper: "Pantograph: A Machine-to-Machine Interaction Interface for Advanced Theorem Proving, High Level Reasoning, and Data Extraction in Lean 4" (2024)
- Authors: Leni Aniva, Chuyue Sun, Brando Miranda, Clark Barrett, Sanmi Koyejo
- arXiv: 2410.16429
- PyPantograph GitHub: https://github.com/stanford-centaur/PyPantograph
- Pantograph (leanprover mirror): https://github.com/leanprover/Pantograph

#### 2.5 Lean Copilot (FFI-Based, Native Inference)

**Interface Type:** Foreign Function Interface (C++ FFI)
**Primary Use Case:** In-proof assistance during development, not RL training

**Key Features:**
- Runs LLMs natively in LEAN through FFI
- CTranslate2 C++ library for efficient Transformer inference
- Works out of the box without Python setup
- Small and efficient (runs on laptops without GPUs)

**Architecture:**
- LLM inference via C++ shared library
- No inter-process communication overhead
- Three tools: suggest_tactics, search_proofs, select_premises

**Why NOT for RL Training:**
- Designed for human-assisted proving, not autonomous RL agents
- FFI adds complexity for training loops
- Python ML frameworks (PyTorch, JAX) better suited for RL training
- FFI best for inference, not training

**Comparison:**
- **FFI Approach (Lean Copilot)**: Low latency, no IPC overhead, but requires C++ integration, complex setup for training
- **Subprocess Approach (LeanDojo, Pantograph)**: Flexible, easy Python integration, mature ML frameworks, standard pattern for RL

**Citation:**
- Paper: "Towards Large Language Models as Copilots for Theorem Proving in Lean" (2024)

#### 2.6 Architecture Comparison Summary

| Tool | Interface | Speed | RL Support | MCTS Support | Offline RL | Setup Complexity | Best For |
|------|-----------|-------|------------|--------------|------------|------------------|----------|
| LeanDojo | Subprocess | Moderate | Excellent (gym) | Good | Manual extract | Moderate | RL training, data extraction |
| LeanInteract | REPL | Moderate | Good | Limited | Yes | Low | Data extraction, prototyping |
| leanclient | LSP | Fast (>95% wait) | Limited | No | No | Low | Batch processing |
| Pantograph/PyPantograph | Subprocess/REPL/FFI | Fast | Excellent | Excellent | Built-in | Low (no Docker) | MCTS, offline RL, speed-critical |
| Lean Copilot | C++ FFI | Very fast | No | No | No | High | In-proof assistance |

**Recommendation for RL Training:**
- **Primary**: Pantograph/PyPantograph (for MCTS-based RL, offline RL, speed)
- **Alternative**: LeanDojo (mature ecosystem, gym interface, large benchmarks)
- **Prototyping**: LeanInteract (simple setup, data extraction)

### 3. RL Training Loop Architectures and Best Practices

#### 3.1 Standard RL Training Loop Pattern

All successful systems follow this general architecture:

```
┌─────────────────────────────────────────────────┐
│           Python Training Controller            │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │  RL Algorithm (GRPO, PPO, Expert Iter.)  │  │
│  │  - Policy Network (PyTorch/JAX)          │  │
│  │  - Value Network (if PPO)                │  │
│  │  - Replay Buffer                         │  │
│  │  - Optimizer (AdamW)                     │  │
│  └──────────────────────────────────────────┘  │
│                      ▲                          │
│                      │                          │
│              state, reward, done                │
│                      │                          │
│                      ▼                          │
│  ┌──────────────────────────────────────────┐  │
│  │     Environment Wrapper (LeanDojo/       │  │
│  │     Pantograph/LeanInteract)             │  │
│  │     - initialize(theorem) → state        │  │
│  │     - step(tactic) → state, reward, done │  │
│  └──────────────────────────────────────────┘  │
│                      │                          │
└──────────────────────┼──────────────────────────┘
                       │ IPC (subprocess/pipe)
                       ▼
┌─────────────────────────────────────────────────┐
│            LEAN 4 Verification Oracle           │
│                                                 │
│  - Proof state management                      │
│  - Tactic execution                            │
│  - Type checking and verification              │
│  - Binary reward signal (accept/reject)        │
│  - Error messages for debugging                │
└─────────────────────────────────────────────────┘
```

#### 3.2 Process-Based vs In-Process Architecture

**Process-Based Communication (Standard):**
- **All state-of-the-art systems use this approach**
- Python training process ↔ LEAN 4 subprocess
- Communication via pipes, sockets, or LSP
- Advantages:
  - Isolation: LEAN crashes don't crash training
  - Language independence: Python ML frameworks + LEAN verification
  - Memory safety: Separate address spaces
  - Easier debugging: Clear separation of concerns
  - Standard pattern: Proven by AlphaProof, DeepSeek-Prover, LeanDojo

**In-Process FFI (Not Recommended for Training):**
- LEAN 4 FFI marked as **unstable** (breaking changes expected)
- Complex memory management across language boundaries
- Type marshalling overhead
- GIL limitations in Python
- **Use case**: Native inference during proving (Lean Copilot), not training

**Performance Comparison:**
- leanclient: >95% time in waiting (minimal overhead from process communication)
- Pantograph: Faster than LeanDojo due to native LEAN 4 implementation
- Process overhead negligible compared to LEAN proof checking and neural network inference

**Conclusion:** Process-based communication is the clear winner for RL training. FFI only beneficial for low-latency in-proof assistance.

#### 3.3 Training Loop Pseudocode

Based on state-of-the-art systems:

```python
# Initialization
env = LeanEnv(leandojo_benchmark)  # or Pantograph
policy = TransformerPolicy(base_model="deepseek-coder-1.3b")
optimizer = AdamW(policy.parameters())
replay_buffer = ExperienceBuffer()

# Main training loop (Expert Iteration + RL)
for iteration in range(num_iterations):
    # Phase 1: Data Collection
    for theorem in curriculum_dataset[iteration]:
        state = env.initialize(theorem)
        trajectory = []

        while not state.is_terminal():
            # Policy generates tactic (with exploration)
            premises = retrieve_premises(state, mathlib)
            tactic, log_prob = policy.sample(state, premises)

            # Execute tactic in LEAN 4
            next_state, lean_result = env.step(tactic)

            # Compute reward
            if lean_result.error:
                reward = 0  # Binary reward: failure
                done = True
            elif lean_result.proof_complete:
                reward = 1  # Binary reward: success
                done = True
            else:
                reward = 0  # Intermediate step (sparse reward)
                done = False

            # Optional: Add shaped rewards
            if use_progress_prediction:
                progress_reward = progress_model.predict(next_state)
                reward += progress_reward

            trajectory.append((state, tactic, log_prob, reward, next_state))
            state = next_state

        # Add successful trajectories to buffer
        if trajectory[-1].reward == 1:
            replay_buffer.add(trajectory)

    # Phase 2: Policy Update (GRPO or PPO)
    if rl_algorithm == "GRPO":
        # Group Relative Policy Optimization
        for batch in replay_buffer.sample_groups(group_size=32):
            # Compute group baseline (average reward)
            baseline = batch.rewards.mean()

            # Advantage = reward - baseline
            advantages = batch.rewards - baseline

            # Add unlikeliness reward (for rare correct proofs)
            unlikeliness = -batch.log_probs.detach()
            advantages += lambda_unlikeliness * unlikeliness

            # Policy gradient loss
            loss = -(batch.log_probs * advantages).mean()

            # Optional: Structural consistency reward
            if use_structural_consistency:
                consistency_loss = compute_consistency(batch)
                loss += lambda_consistency * consistency_loss

            # Update
            optimizer.zero_grad()
            loss.backward()
            optimizer.step()

    elif rl_algorithm == "PPO":
        for epoch in range(ppo_epochs):
            for batch in replay_buffer.sample_batches():
                # Standard PPO update with critic network
                # (requires separate value network)
                ...

    # Phase 3: Synthetic Data Generation (Curriculum)
    if iteration % curriculum_interval == 0:
        # Generate new synthetic problems at higher difficulty
        new_theorems = generate_synthetic_data(
            difficulty=iteration / num_iterations,
            base_model=decomposer_model
        )
        curriculum_dataset[iteration + 1].extend(new_theorems)

    # Phase 4: Self-Correction (Goedel-Prover style)
    if use_self_correction:
        for failed_attempt in replay_buffer.failed_proofs:
            error_msg = failed_attempt.lean_error
            corrected_tactic = self_correction_model(
                failed_attempt.state,
                error_msg
            )
            # Retry with correction...

    # Logging
    success_rate = replay_buffer.success_rate()
    print(f"Iteration {iteration}: Success rate = {success_rate:.2%}")
```

#### 3.4 Key Components Breakdown

**Policy Network:**
- Base: Pre-trained language model (DeepSeek-Coder, InternLM-math, CodeLlama)
- Architecture: Encoder-decoder Transformer or decoder-only
- Input: Proof state + retrieved premises (concatenated)
- Output: Next tactic (token sequence)
- Training: Supervised fine-tuning → RL fine-tuning

**Value Network (PPO only):**
- Not needed for GRPO (efficiency advantage)
- Estimates expected cumulative reward from state
- Used as baseline for advantage computation in PPO

**Environment Wrapper:**
- Abstracts LEAN 4 interaction
- Methods: `initialize()`, `step()`, `reset()`
- Manages subprocess communication
- Parses LEAN error messages
- Tracks proof state transitions

**Replay Buffer:**
- Stores successful trajectories for RL updates
- Optionally stores failed attempts for self-correction
- Curriculum sampling: Progressively harder problems

**Premise Retriever:**
- Embedding-based or BM25 retrieval
- Queries mathlib for relevant lemmas/theorems
- Critical for large proof libraries
- ReProver: Retrieval-augmented architecture

### 4. Reward Shaping and Signal Design

#### 4.1 The Sparse Reward Problem

**Challenge:** Binary LEAN verification (accept/reject) provides sparse rewards
- Most tactics: reward = 0 (intermediate step)
- Failed proof: reward = 0 (terminal state)
- Successful proof: reward = 1 (terminal state)
- Combinatorial explosion: Millions of possible tactic sequences
- Credit assignment: Which tactics in sequence led to success?

**Why Sparse Rewards are Problematic:**
- RL algorithms struggle with sparse feedback
- Random exploration unlikely to find successful proofs
- Training signal only at episode end
- Gradient vanishing for long proof sequences

#### 4.2 Reward Shaping Strategies

**1. Proof Progress Prediction (LeanProgress, February 2025):**
- Train auxiliary model to predict remaining proof steps
- Input: Current proof state (+ optional history)
- Output: Number of remaining steps until completion
- Training: Supervised learning on successful proofs with MSE loss
- Usage: Progress reward = 1 / (predicted_remaining_steps + 1)

**Benefits:**
- Provides dense reward signal at every step
- Guides search toward proof completion
- Lightweight: Small model (DeepSeek Coder 1.3B)
- No RL training needed for progress model itself

**2. Unlikeliness Reward (Addressing GRPO Bias):**
- **Problem**: GRPO reinforces already-probable solutions, neglects rare correct proofs
- **Solution**: Explicit unlikeliness reward for rare correct solutions
- Formula: `unlikeliness_reward = -log_prob(tactic | state)`
- Combined reward: `total_reward = binary_reward + λ * unlikeliness_reward`

**Benefits:**
- Improves pass@N metrics at large N (sample diversity)
- Encourages exploration of rare solution paths
- Particularly important for formal theorem proving (multiple valid proofs)

**3. Structural Consistency Reward (DeepSeek-Prover-V2):**
- **Early consistency reward**: Punishes structural misfitting
- Requires proof to follow decomposed lemma structures
- Ensures generated proof aligns with planned subgoals
- Enhances accuracy on difficult theorems

**Benefits:**
- Prevents wandering proof attempts that ignore problem structure
- Leverages proof decomposition from Chain-of-Thought planning
- Improves sample efficiency

**4. Intermediate Goal Rewards:**
- Reward for reducing number of open goals
- Reward for simplifying goal statements (heuristic: shorter expressions)
- Reward for applying known lemmas successfully

**5. Self-Correction Feedback:**
- Parse LEAN compiler error messages
- Provide error-specific reward penalties
- Differentiate error types: type errors, tactic failures, timeouts
- Train separate self-correction model on error → corrected tactic pairs

#### 4.3 Reward Shaping Best Practices

**Do:**
- Start with binary LEAN verification (ground truth)
- Add shaped rewards gradually, monitor for reward hacking
- Use auxiliary supervised models (progress prediction) rather than hand-crafted heuristics
- Balance exploration (unlikeliness) and exploitation (binary reward)
- Incorporate structural information from proof decomposition

**Don't:**
- Over-rely on hand-crafted heuristics (may lead to brittle behavior)
- Ignore binary verification signal (always primary reward source)
- Use shaped rewards that contradict LEAN verification
- Neglect reward normalization across different problem difficulties

**Validation:**
- Final evaluation always uses binary LEAN verification only
- Shaped rewards for training efficiency, not test-time
- Monitor for reward hacking: High shaped reward but low proof success

### 5. Data Extraction and Proof State Representation

#### 5.1 Data Extraction from LEAN Repositories

**LeanDojo Approach:**
1. **Tracing**: One-time processing of LEAN repository
2. **AST Extraction**: Abstract syntax trees of all definitions/theorems
3. **Dependency Graph**: File-level and declaration-level dependencies
4. **Proof Steps**: Sequence of tactic applications for each theorem
5. **Premise Annotations**: Which lemmas/theorems used in each proof
6. **Fine-Grained Annotations**: Location information for retrieval training

**Lean4trace Approach:**
1. **Elaborator Integration**: Deeply integrated into LEAN elaborator
2. **On-the-Fly Modification**: Can modify proofs during extraction
3. **Data Augmentation**:
   - Decompose composite proof steps into simpler steps
   - Test automation tactics at each state, collect successful ones
4. **Richer Training Data**: Multiple proof paths for same theorem

**Pantograph Approach:**
1. **Offline Triplet Extraction**: (before_state, after_state, tactic) triplets
2. **Format**: Convenient for offline RL training (behavior cloning)
3. **Compiler-Based**: Run LEAN 4 compiler on files, collect tactic applications

**LEAN-GitHub Dataset:**
- **Scale**: 8,639 LEAN source files from GitHub repositories
- **Extraction**: 6,352 files, 42,000 theorems successfully processed
- **Quality Filtering**: Final dataset of 2,133 files, 28,000 theorems with valid tactic info
- **Diversity**: Real-world LEAN code beyond mathlib

**LeanNavigator State Graph Traversal:**
- **Method**: Interactive LEAN client traverses state graphs
- **Scale**: Generated 4.7M theorems, 1B tokens from Mathlib4
- **Efficiency**: Embedding-based retrieval for tactic generation (faster than generative models)
- **Result**: 10x larger than ReProver training dataset (57M tokens)

#### 5.2 Proof State Representation

**String-Based Representation (LeanDojo, Standard):**
```
Goals:
  case pos
  n : ℕ
  hn : 0 < n
  ⊢ n.succ = n + 1

  case neg
  n : ℕ
  hn : n ≤ 0
  ⊢ n = 0

Local Context:
  n : ℕ
  h : n < 10
```

- Human-readable format
- Directly parsed from LEAN tactic state
- Includes: Current goals, local hypotheses, types
- Can be tokenized for Transformer models

**Abstract Syntax Tree (AST) Representation:**
- Tree structure of logical expressions
- Nodes: Function applications, variable bindings, operators
- Edges: Syntactic relationships
- Graph neural networks (GNNs) can operate on ASTs
- Richer structural information than strings

**Retrieval-Augmented Representation (ReProver):**
```
Input to Model:
  [State String] [SEP] [Retrieved Premise 1] [SEP] [Retrieved Premise 2] [SEP] ...

Example:
  ⊢ (a + b)^2 = a^2 + 2*a*b + b^2 [SEP] lemma sq_add : ... [SEP] lemma mul_comm : ...
```

- Concatenate proof state with relevant premises from library
- Retrieval: BM25 or dense embeddings (BERT-style)
- Transformer attends to both state and premises
- Critical for large libraries (mathlib: 130K+ premises)

**Premise Representation:**
- Name: Fully qualified name (e.g., `Nat.add_comm`)
- Type: Full type signature
- Statement: Natural language docstring (if available)
- Embedding: Dense vector for retrieval

#### 5.3 Tactic Representation

**String Format (Standard):**
```
Tactic Examples:
  "rw [Nat.add_comm]"       -- Rewrite using lemma
  "induction n with"        -- Induction on n
  "| zero => simp"          -- Induction base case
  "| succ n ih => ..."      -- Induction step
  "exact h"                 -- Use hypothesis h
  "apply mul_comm"          -- Apply lemma
```

- Natural language syntax
- Tokenized by language model
- Generation: Standard seq2seq decoding

**Action Space Considerations:**
- **Discrete**: Fixed set of tactic templates (limited expressiveness)
- **Continuous**: Generate tactic string token-by-token (used by all modern systems)
- **Hybrid**: Tactic name (discrete) + arguments (continuous generation)

**Tactic Complexity:**
- Simple tactics: `simp`, `refl`, `exact h`
- Parameterized tactics: `rw [lemma_name]`, `apply theorem`
- Structured tactics: `induction` with multiple cases, `calc` blocks
- Modern models generate full tactic syntax (continuous generation)

#### 5.4 Dataset Statistics and Benchmarks

**LeanDojo Benchmark (LEAN 4):**
- 122,517 theorems/proofs
- 259,580 tactics
- 167,779 unique premises
- Source: mathlib4 (LEAN's mathematics library)

**MiniF2F Benchmark:**
- 488 test problems (244 validation)
- Olympiad-level mathematics problems
- Formalized in multiple proof assistants (LEAN, Isabelle, HOL Light, Coq)
- Standard evaluation benchmark
- State-of-the-art: DeepSeek-Prover-V2 (88.9% pass@1)

**PutnamBench:**
- 658 problems from Putnam mathematics competition
- Extremely difficult (graduate level)
- State-of-the-art: DeepSeek-Prover-V2 (49/658 = 7.4%)

**Lean Workbook:**
- ~57K formal-informal question pairs
- Synthetic data pipeline
- Improves LLM translation of complex mathematical problems

**Herald Dataset:**
- Built from Mathlib4 with natural language annotations
- 93.2% accuracy (Pass@128) on formalizing miniF2F-test statements

### 6. Expert Iteration and Curriculum Learning

#### 6.1 Expert Iteration Pattern

**Definition:** Iteratively improve policy by learning from its own successful proofs

**Standard Algorithm:**
```
Initialize policy π with supervised learning on expert proofs
For iteration t = 1 to T:
    1. Generate proofs using current policy π_t
    2. Verify proofs with LEAN (filter successful ones)
    3. Add successful proofs to dataset D_t
    4. Train π_{t+1} on D_t via supervised learning
    Return final policy π_T
```

**Used By:** DeepSeek-Prover, Goedel-Prover, Lean-STaR, REAL-Prover

**Advantages:**
- No RL algorithm needed (supervised learning only)
- Stable training (no reward shaping complexity)
- Self-improvement: Policy generates its own training data
- LEAN verification ensures correctness

**Challenges:**
- Can get stuck in local optima (policy only explores near current distribution)
- Requires high initial success rate (warm start problem)
- Less sample efficient than RL (no credit assignment within episode)

**Hybrid Approach (State-of-the-Art):**
- Phase 1: Expert iteration for stable initial improvement
- Phase 2: RL fine-tuning for exploration and sample efficiency
- Example: DeepSeek-Prover-V2 uses both

#### 6.2 Curriculum Learning Strategies

**Progressive Difficulty:**
- Start with easy theorems (short proofs, simple tactics)
- Gradually increase difficulty (longer proofs, complex tactics)
- Metrics: Proof length, number of premises, statement complexity

**Goedel-Prover Scaffolded Data Synthesis:**
1. Run policy on hard theorems (expect failures)
2. Extract failing subgoals using LEAN's `extract_goal`
3. Convert subgoals into standalone easier theorems
4. Train on subgoals (curriculum: hard → easier subproblems)
5. Iterate: Policy improves on subgoals, try hard theorems again

**Benefits:**
- Breaks down hard problems into learnable sub-skills
- Addresses cold-start problem (hard theorems → extract easier goals)
- Automatic curriculum generation (no manual difficulty annotation)

**Curriculum Data Sorting (Block Training):**
- Sort dataset by difficulty estimate
- Train in blocks: easy → medium → hard
- Within blocks: Shuffle for mini-batch diversity
- Enhances in-context learning ability
- Helps LLMs learn unfamiliar LEAN 4 tasks

**OpenAI's Synthetic Data Generator (Formal Math Statement Curriculum):**
- Generate inequalities from known theorems (AM-GM, Cauchy-Schwarz, etc.)
- Difficulty parameters:
  - ND: Depth of theorem composition
  - NS: Complexity of input expressions
- Controllable difficulty for curriculum

**DeepSeek-Prover-V2 Subgoal Decomposition:**
- Use large model (DeepSeek-V3 671B) to decompose theorems
- High-level proof sketches with formal subgoals
- Smaller model (7B) proves each subgoal
- Progressive assembly: Subgoals → full proof
- Chain-of-Thought pairing with formal proof

#### 6.3 Cold-Start Problem Solutions

**Problem:** Need successful proofs to bootstrap expert iteration, but policy is weak initially

**Solutions:**

1. **Supervised Warm-Start:**
   - Pre-train on existing mathlib proofs
   - Supervised fine-tuning on expert demonstrations
   - Requires: Existing proof library (mathlib has 122K+ theorems)

2. **Synthetic Data Generation:**
   - Generate easy theorems programmatically
   - Difficulty-controlled synthetic problems
   - Enough to bootstrap learning

3. **Subgoal Extraction (Goedel-Prover):**
   - Even failed proofs contain useful subgoals
   - Extract and formalize subgoals as standalone theorems
   - Creates easier problems from hard ones

4. **Large Model Bootstrapping (DeepSeek-Prover-V2):**
   - Use very large general-purpose LLM (DeepSeek-V3) to create initial dataset
   - Decompose and formalize problems
   - Train smaller specialized model on this data
   - Expensive but effective

5. **Transfer Learning:**
   - Pre-train on general code/math text (300B+ tokens)
   - Fine-tune on formal mathematics
   - Leverages general reasoning abilities

### 7. Comparison to Other Proof Assistants and Transfer Insights

#### 7.1 Proof Assistants Landscape

**LEAN 4:**
- Dependent type theory
- Metaprogramming in LEAN itself (monolithic design)
- Modern, actively developed (2021+)
- Growing ML/AI ecosystem (LeanDojo, Pantograph, AlphaProof)

**Isabelle/HOL:**
- Higher-order logic
- Mature sledgehammer integration (ATP/SMT solvers)
- Large formalization libraries
- Established but less modern

**Coq:**
- Calculus of Inductive Constructions
- CoqHammer for ATP integration
- Strong community, theorem prover of choice for many (CompCert, Feit-Thompson)

**HOL Light / HOL4:**
- Simple higher-order logic
- Small trusted kernel
- Used in hardware verification

#### 7.2 LEAN 4 Advantages for RL Training

**1. Python Ecosystem Integration:**
- Multiple mature Python interfaces (LeanDojo, Pantograph, LeanInteract)
- Process-based communication (stable, easy)
- All recent RL systems target LEAN 4

**2. Language Model Friendliness:**
- Syntax closer to programming languages (familiar to LLMs pre-trained on code)
- Tactic mode similar to Python/functional programming
- Growing dataset availability

**3. Metaprogramming:**
- Custom tactics in LEAN itself (no need for external meta-language)
- Easier for RL agents to learn (unified language)

**4. Compilation to C:**
- Efficient execution (faster proof checking)
- Important for large-scale RL training (millions of proof attempts)

**5. Active Development:**
- New features added regularly
- Community momentum (mathlib4 growing rapidly)
- Industry interest (Google DeepMind's AlphaProof)

#### 7.3 Transfer Insights from Other Domains

**AlphaZero (Go, Chess, Shogi) → AlphaProof (LEAN Theorems):**
- **Transfer**: Self-play with tree search (MCTS)
- **Adaptation**: Product nodes for multiple sub-goals (induction, case splits)
- **Key Insight**: Domain-specific tree structure crucial (not just generic MCTS)

**Code Generation (GitHub Copilot) → Theorem Proving:**
- **Transfer**: Pre-training on code corpus
- **Adaptation**: Fine-tuning on formal proofs
- **Key Insight**: Code understanding transfers to formal mathematics (both syntactic reasoning)

**Machine Translation → Autoformalization:**
- **Transfer**: Natural language math → formal LEAN statements
- **Adaptation**: Specialized training on informal-formal pairs
- **Key Insight**: Translation task, but with formal verification as quality check

**Question Answering + Retrieval → Premise Selection:**
- **Transfer**: Retrieve relevant documents for answering questions
- **Adaptation**: Retrieve relevant lemmas from mathlib for proving theorems
- **Key Insight**: Retrieval augmentation critical for large knowledge bases

### 8. When to Use Python + LEAN 4 for RL (Decision Framework)

Based on previous report (pure LEAN 4 for proof-checker) and current research (Python+LEAN 4 for RL training):

#### 8.1 Use Pure LEAN 4 For:

✅ **Proof-Checker Core Implementation**
- Proof system logic (axioms, inference rules, derivability)
- Soundness and completeness proofs
- Custom tactics for your TM logic (modal_k, temporal_k)
- Type-safe formula representation
- Trusted verification kernel

**Rationale (from previous report):**
- Type safety ensures proof correctness
- Metaprogramming for custom tactics
- Single-language maintenance
- Formal verification within LEAN
- No FFI complexity

#### 8.2 Use Python + LEAN 4 Hybrid For:

✅ **RL Training Infrastructure**
- Training AI agents to find proofs in your TM system
- Automated proof search with learned policies
- Dataset extraction from your LEAN proof library
- Experiment management and hyperparameter tuning
- Reward shaping and progress prediction models

**Rationale (from current research):**
- **Mature ML ecosystem**: PyTorch, JAX, Hugging Face Transformers
- **Proven pattern**: AlphaProof, DeepSeek-Prover, LeanDojo all use Python for training
- **RL libraries**: Stable-Baselines3, TorchRL, RLlib (all Python)
- **Data processing**: Pandas, NumPy for dataset management
- **Monitoring**: TensorBoard, Weights & Biases integration
- **Process-based communication**: Standard, stable, no FFI complexity

#### 8.3 Architecture Recommendation for Your Logos Project

**Recommended Structure:**

```
Logos/
├── Logos/              # Pure LEAN 4 (Core Implementation)
│   ├── Syntax/                # Formula, Context, DSL
│   ├── ProofSystem/           # Axioms, Rules, Derivation
│   ├── Semantics/             # TaskFrame, Truth, Validity
│   ├── Metalogic/             # Soundness, Completeness
│   ├── Theorems/              # Perpetuity principles
│   └── Automation/            # Custom tactics (modal_k, temporal_k)
│
├── LogosRL/            # Python RL Training Infrastructure
│   ├── environment/           # LEAN 4 gym wrapper
│   │   ├── lean_env.py        # LeanDojo/Pantograph integration
│   │   ├── proof_state.py     # State representation
│   │   └── reward.py          # Reward shaping logic
│   ├── models/                # Neural network policies
│   │   ├── policy.py          # Transformer policy network
│   │   ├── retriever.py       # Premise retrieval
│   │   └── progress.py        # Progress prediction model
│   ├── algorithms/            # RL algorithms
│   │   ├── grpo.py            # Group Relative Policy Optimization
│   │   ├── ppo.py             # Proximal Policy Optimization
│   │   └── expert_iter.py     # Expert iteration
│   ├── data/                  # Dataset management
│   │   ├── extraction.py      # Extract from Logos LEAN code
│   │   ├── augmentation.py    # Data augmentation (Lean4trace style)
│   │   └── curriculum.py      # Curriculum learning logic
│   ├── training/              # Training loops
│   │   ├── train.py           # Main training script
│   │   ├── evaluate.py        # Evaluation on benchmarks
│   │   └── monitor.py         # Logging and monitoring
│   └── configs/               # Experiment configurations
│       ├── grpo_config.yaml
│       └── expert_iter_config.yaml
│
├── scripts/                   # Utility scripts
│   ├── trace_proofchecker.py # Trace Logos for LeanDojo
│   ├── export_dataset.py     # Export training data
│   └── benchmark.py           # Run evaluation benchmarks
│
└── integration/               # Communication layer
    ├── serialize.py           # Formula serialization (SMT-LIB, JSON)
    └── modelchecker.py        # Model-checker integration (separate, per previous report)
```

**Key Design Principles:**

1. **Clear Separation:**
   - Logos: Pure LEAN 4, no Python dependencies
   - LogosRL: Pure Python, interfaces with LEAN via subprocess

2. **Communication:**
   - LogosRL uses LeanDojo or Pantograph to interact with Logos
   - One-time tracing of Logos LEAN code
   - Cached proof state interactions

3. **Training Workflow:**
   ```
   1. Develop proof system in LEAN 4 (Logos/)
   2. Trace Logos with LeanDojo (one-time)
   3. Extract training data (theorems, tactics, proof states)
   4. Train policy network in Python (LogosRL/)
   5. Evaluate on held-out theorems
   6. Deploy trained policy as proof search assistant
   ```

4. **No Tight Coupling:**
   - Python RL code doesn't modify LEAN proof-checker
   - LEAN proof-checker remains standalone, verifiable
   - RL infrastructure is optional extension

#### 8.4 Comparison to Model-Checker Integration

From previous report: Model-Checker (Python/Z3) ↔ Proof-Checker (LEAN 4) via serialization (SMT-LIB, JSON)

**Three-Component Architecture:**

```
┌──────────────────────┐
│   Model-Checker      │  ← Separate, Python/Z3, validity checking
│   (Python + Z3)      │
└──────────────────────┘
          │
          │ SMT-LIB / JSON
          ▼
┌──────────────────────┐
│   Proof-Checker      │  ← Core, Pure LEAN 4, derivability checking
│   (Pure LEAN 4)      │
└──────────────────────┘
          │
          │ Subprocess / LeanDojo
          ▼
┌──────────────────────┐
│   RL Training        │  ← Optional, Python ML, proof search training
│   (Python + PyTorch) │
└──────────────────────┘
```

**All Three Components Communicate via Data Exchange:**
- Model-Checker ↔ Proof-Checker: SMT-LIB/JSON serialization (as previously designed)
- Proof-Checker ↔ RL Training: Process-based via LeanDojo/Pantograph
- No FFI, no tight coupling, clean interfaces

#### 8.5 When NOT to Use Python + LEAN 4

❌ **Avoid Python for:**
- Core proof verification logic (type safety risk)
- Axiom and inference rule definitions (must be formally verified)
- Soundness and completeness proofs (LEAN's metatheoretic guarantees needed)
- Performance-critical proof checking (LEAN compiles to C)
- Custom tactics that should be verified (LEAN metaprogramming better)

**Rationale:**
- Python's dynamic typing incompatible with formal verification
- No guarantee of correctness for proof-critical code
- LEAN's type system catches errors at compile time
- Python slower than compiled LEAN for intensive proof checking

### 9. Implementation Roadmap for Your Logos + RL System

Based on research findings and your project goals:

#### Phase 0: Foundation (Current - Complete Proof-Checker)
✅ **Already Planned/Designed:**
- Pure LEAN 4 implementation of TM bimodal logic proof system
- Layered architecture (Layer 0: Core TM)
- Soundness and completeness proofs
- Custom tactics (modal_k, temporal_k)
- Model-checker integration via serialization

**Deliverables:**
- Working Logos in LEAN 4 with all axioms, rules, theorems
- Test suite passing
- Documentation complete
- Model-checker integration functional

#### Phase 1: Data Extraction Setup (2-4 weeks)
🎯 **Goal:** Prepare Logos for RL training data extraction

**Tasks:**
1. **Install LeanDojo or Pantograph:**
   ```bash
   pip install leandojo  # or lean-interact for simpler approach
   ```

2. **Trace Logos Repository:**
   ```python
   from lean_dojo import LeanGitRepo, trace

   repo = LeanGitRepo(
       "Logos",
       path="/home/benjamin/Documents/Philosophy/Projects/Logos"
   )
   traced_repo = trace(repo)
   ```

3. **Extract Initial Dataset:**
   - Theorems from Theorems/Perpetuity.lean
   - Proofs of axiom instances
   - Derivations of key theorems
   - Expected size: ~100-500 theorems initially

4. **Validate Data Quality:**
   - Check proof state representations
   - Verify tactic extraction
   - Ensure premise annotations correct

**Deliverables:**
- Traced Logos repository cached
- Extracted dataset of theorems, proof states, tactics
- Data validation script

#### Phase 2: RL Environment Setup (3-6 weeks)
🎯 **Goal:** Create gym-like environment for RL agents to interact with Logos

**Tasks:**
1. **Implement Gym Wrapper:**
   ```python
   class LogosEnv:
       def __init__(self, leandojo_repo):
           self.repo = leandojo_repo
           self.theorems = load_theorems()

       def reset(self, theorem_name=None):
           """Initialize proof state for theorem."""
           theorem = select_theorem(theorem_name, self.theorems)
           self.state = self.repo.initialize(theorem)
           return self.state

       def step(self, tactic):
           """Apply tactic, return next state and reward."""
           result = self.repo.run_tactic(self.state, tactic)

           if result.error:
               reward = 0
               done = True
           elif result.proof_complete:
               reward = 1
               done = True
           else:
               reward = 0  # Intermediate step
               done = False

           self.state = result.next_state
           return self.state, reward, done, result.info
   ```

2. **Test Environment:**
   - Manual proof attempts via Python
   - Validate state transitions match LEAN behavior
   - Measure communication latency (should be <100ms per step)

3. **Implement Premise Retrieval:**
   - Index Logos definitions and theorems
   - Simple BM25 retrieval initially
   - Later: Dense embeddings with SBERT

**Deliverables:**
- LogosEnv gym wrapper functional
- Test suite for environment (10+ test theorems)
- Premise retrieval system operational

#### Phase 3: Baseline Policy (4-8 weeks)
🎯 **Goal:** Train initial policy network via supervised learning on extracted proofs

**Tasks:**
1. **Prepare Training Data:**
   - Format: (proof_state, premises, tactic) triplets
   - Split: 80% train, 10% validation, 10% test
   - Augmentation: Use Lean4trace style decomposition

2. **Implement Policy Network:**
   ```python
   class ProofPolicy(nn.Module):
       def __init__(self, base_model="deepseek-coder-1.3b"):
           self.encoder = AutoModel.from_pretrained(base_model)
           self.decoder = AutoModelForCausalLM.from_pretrained(base_model)

       def forward(self, state, premises):
           input_text = f"{state} [SEP] {premises}"
           input_ids = tokenizer(input_text, return_tensors="pt")
           outputs = self.decoder.generate(input_ids)
           tactic = tokenizer.decode(outputs[0])
           return tactic
   ```

3. **Supervised Training:**
   - Loss: Cross-entropy on tactic tokens
   - Optimizer: AdamW
   - Learning rate: 1e-5 with cosine schedule
   - Batch size: 16-32
   - Epochs: 10-20

4. **Evaluation:**
   - Pass@1 metric on test theorems
   - Target: >20% pass rate (modest baseline)

**Deliverables:**
- Trained baseline policy checkpoint
- Evaluation metrics on test set
- Inference script for policy deployment

#### Phase 4: Expert Iteration (6-12 weeks)
🎯 **Goal:** Improve policy via self-generated successful proofs

**Tasks:**
1. **Implement Expert Iteration Loop:**
   ```python
   policy = load_baseline_policy()

   for iteration in range(num_iterations):
       # Generate proofs with current policy
       new_proofs = []
       for theorem in curriculum_theorems:
           proof = policy.attempt_proof(theorem, env)
           if proof.success:
               new_proofs.append(proof)

       # Add to dataset
       dataset.extend(new_proofs)

       # Retrain policy
       policy = train_supervised(policy, dataset)

       # Evaluate
       success_rate = evaluate(policy, test_theorems)
       print(f"Iteration {iteration}: {success_rate:.1%} success")
   ```

2. **Curriculum Design:**
   - Start with simplest theorems (1-3 tactics)
   - Gradually add longer proofs
   - Use proof length as difficulty proxy

3. **Scaffolded Data Synthesis (Goedel-Prover style):**
   - Extract failing subgoals from unsuccessful attempts
   - Formalize subgoals as new theorems
   - Add to curriculum

4. **Target Performance:**
   - Iteration 1: 25% success rate
   - Iteration 5: 40% success rate
   - Iteration 10: 50%+ success rate

**Deliverables:**
- Expert iteration training pipeline
- Curriculum dataset with difficulty rankings
- Improved policy checkpoint
- Performance progression plots

#### Phase 5: RL Fine-Tuning (8-16 weeks)
🎯 **Goal:** Apply GRPO to explore beyond expert iteration local optimum

**Tasks:**
1. **Implement GRPO Algorithm:**
   - Group sampling: 32 proofs per theorem
   - Baseline: Average reward in group
   - Advantage: Individual reward - baseline
   - Unlikeliness reward: Encourage rare correct proofs

2. **Reward Shaping:**
   - Primary: Binary LEAN verification (0 or 1)
   - Secondary: Proof progress prediction model
   - Tertiary: Structural consistency (if using subgoal decomposition)

3. **Train Progress Prediction Model:**
   ```python
   progress_model = train_progress_predictor(
       dataset=successful_proofs,
       architecture="deepseek-coder-1.3b",
       loss=nn.MSELoss()
   )
   ```

4. **GRPO Training:**
   - 50-100 iterations
   - Monitor: Success rate, sample diversity, reward distribution
   - Validate: No reward hacking (high shaped reward but low success)

5. **Target Performance:**
   - 60%+ success rate on test theorems
   - High sample diversity (multiple valid proofs per theorem)

**Deliverables:**
- GRPO training pipeline
- Progress prediction model
- GRPO-fine-tuned policy checkpoint
- Analysis of sample diversity

#### Phase 6: Advanced Techniques (12-24 weeks, Optional)
🎯 **Goal:** State-of-the-art techniques for maximum performance

**Tasks:**
1. **Monte Carlo Tree Search Integration:**
   - Switch from LeanDojo to Pantograph (MCTS-optimized)
   - Implement product nodes for sub-goal branching
   - Combine policy network with tree search

2. **Test-Time Adaptation (AlphaProof style):**
   - Generate problem variants at inference time
   - Fine-tune policy on variants
   - Attempt original problem with adapted policy

3. **Large Model Bootstrapping:**
   - Use GPT-4 or DeepSeek-V3 to generate proof sketches
   - Decompose into subgoals
   - Train small model on decompositions

4. **Self-Correction:**
   - Parse LEAN error messages
   - Train correction model: (state, error, tactic) → corrected_tactic
   - Integrate into proof search loop

**Deliverables:**
- MCTS-enhanced policy
- Test-time adaptation pipeline
- Self-correction model
- State-of-the-art performance on your TM proof system

#### Phase 7: Integration and Deployment (4-8 weeks)
🎯 **Goal:** Deploy trained policy as proof assistant for Logos users

**Tasks:**
1. **Proof Search Tool:**
   - Command-line interface: `proofchecker-search "theorem_name"`
   - Returns: Suggested tactics or full proof
   - Timeout: 60 seconds per theorem

2. **VS Code Extension (Optional):**
   - Integrate with LEAN VS Code plugin
   - Real-time tactic suggestions
   - Similar to GitHub Copilot for proofs

3. **Benchmarking:**
   - Compare to baseline: Random search, best-first search
   - Measure: Success rate, proof length, search time
   - Publish results

4. **Documentation:**
   - User guide for RL-assisted proving
   - Developer guide for extending RL system
   - Paper: "RL for TM Bimodal Logic Theorem Proving"

**Deliverables:**
- Deployed proof search tool
- VS Code extension (optional)
- Benchmark results
- Documentation and paper

#### Timeline Summary

| Phase | Duration | Key Milestone |
|-------|----------|---------------|
| Phase 0 | Ongoing | Complete Logos (pure LEAN 4) |
| Phase 1 | 2-4 weeks | Data extraction setup |
| Phase 2 | 3-6 weeks | RL environment operational |
| Phase 3 | 4-8 weeks | Baseline policy (20%+ success) |
| Phase 4 | 6-12 weeks | Expert iteration (50%+ success) |
| Phase 5 | 8-16 weeks | GRPO fine-tuning (60%+ success) |
| Phase 6 | 12-24 weeks | Advanced techniques (optional) |
| Phase 7 | 4-8 weeks | Deployment and benchmarking |
| **Total** | **39-78 weeks** | **Full RL-assisted proof system** |

**Minimal Viable Product (Phases 1-4):** 15-30 weeks

### 10. Resource Requirements and Practical Considerations

#### 10.1 Computational Resources

**Development Phase (Phases 1-3):**
- **CPU**: Modern laptop sufficient (i7/M1 or better)
- **RAM**: 16GB minimum, 32GB recommended
- **Storage**: 50GB for datasets and model checkpoints
- **GPU**: Not required (using pre-trained models, small datasets)

**Training Phase (Phases 4-5):**
- **Baseline Policy Training (Supervised):**
  - GPU: Single RTX 3090 or V100 (24GB VRAM)
  - Training time: 2-4 days for 10 epochs
  - Can use cloud: Google Colab Pro ($10/month), Vast.ai (~$0.50/hour)

- **Expert Iteration:**
  - GPU: Single RTX 3090 or V100
  - Training time: 1 day per iteration, 10 iterations = 10 days
  - Proof generation: Can parallelize across CPUs (cheaper)

- **GRPO Training:**
  - GPU: Single A100 (40GB) or 2x RTX 3090
  - Training time: 5-10 days for 50-100 iterations
  - Memory: GRPO more efficient than PPO (no value network)

**Advanced Phase (Phase 6, Optional):**
- **MCTS Integration:**
  - CPU-heavy: MCTS tree search on CPUs
  - GPU: Policy network inference
  - Can use cluster: 10-50 CPU cores for parallel search

- **Large Model Bootstrapping:**
  - Expensive: GPT-4 API or DeepSeek-V3 inference
  - Cost: $100-500 for generating cold-start dataset
  - One-time cost

**Cost Estimate:**
- **Minimal (Cloud GPU rental)**: $500-1000 for Phases 1-5
- **Moderate (Single A100 for 6 months)**: $3000-5000
- **Advanced (Large model bootstrapping)**: $5000-10000

**Free/Low-Cost Options:**
- Google Colab Pro+ ($50/month, 500 compute units)
- Kaggle GPUs (30 hours/week free)
- University cluster access (if available)
- Hugging Face Spaces (free community GPU, limited)

#### 10.2 Software Dependencies

**LEAN 4 Side:**
```
# lean-toolchain (pin version)
leanprover/lean4:v4.26.0

# lakefile.toml
[[require]]
name = "mathlib4"
version = "v4.26.0"
```

**Python Side:**
```
# requirements.txt
lean-dojo>=2.0.0  # or pypantograph
torch>=2.0.0
transformers>=4.30.0
accelerate>=0.20.0
datasets>=2.12.0
numpy>=1.24.0
pandas>=2.0.0
matplotlib>=3.7.0
tensorboard>=2.13.0
wandb>=0.15.0  # Optional: Weights & Biases for monitoring
```

**Installation:**
```bash
# Python environment
python3 -m venv proofchecker_rl
source proofchecker_rl/bin/activate

# Install dependencies
pip install -r requirements.txt

# Trace Logos (one-time)
python scripts/trace_proofchecker.py
```

#### 10.3 Data Storage and Management

**Dataset Sizes:**
- Traced LEAN repository: 500MB - 2GB
- Extracted proof data: 100MB - 1GB
- Model checkpoints: 5GB per checkpoint (1.3B model)
- Training logs and metrics: 1GB per experiment

**Total Storage:** 50GB - 200GB depending on scale

**Backup Strategy:**
- Git LFS for model checkpoints (GitHub allows 2GB free)
- Hugging Face Hub for public models (unlimited public storage)
- Local backup: External drive or NAS

#### 10.4 Team and Skills

**Minimal Team (Solo Researcher):**
- Strong LEAN 4 skills (Phase 0: Logos implementation)
- Python ML skills (Phases 1-5: RL training)
- Time commitment: 20-30 hours/week for 9-18 months

**Recommended Team (2-3 People):**
- **Person 1**: LEAN 4 expert (Logos development, custom tactics)
- **Person 2**: ML engineer (RL training, model architecture)
- **Person 3**: DevOps/Infrastructure (Optional, for scaling)

**Skills Required:**
- LEAN 4 programming and theorem proving (advanced)
- Python and PyTorch (intermediate to advanced)
- Reinforcement learning algorithms (intermediate)
- Transformer architectures (intermediate)
- Unix/Linux command line (intermediate)
- Git version control (basic)

**Learning Resources:**
- LEAN 4: "Theorem Proving in Lean 4" (official book)
- RL: Sutton & Barto "Reinforcement Learning: An Introduction"
- Transformers: Hugging Face Course (free)
- GRPO: DeepSeekMath paper (arXiv:2402.03300)

#### 10.5 Monitoring and Debugging

**Key Metrics to Track:**
- **Training**: Loss, learning rate, gradient norms
- **Environment**: Success rate, average proof length, timeout rate
- **RL**: Reward mean/std, advantage mean/std, KL divergence (if PPO)
- **Inference**: Latency per tactic, LEAN subprocess responsiveness

**Tools:**
- **TensorBoard**: Real-time training plots
- **Weights & Biases**: Experiment tracking, hyperparameter sweeps
- **LEAN Language Server**: Syntax checking, error messages

**Common Issues and Solutions:**
- **LEAN subprocess hangs**: Implement timeout (60s per step), restart subprocess
- **Out of memory**: Reduce batch size, use gradient accumulation
- **Poor exploration**: Increase unlikeliness reward coefficient
- **Reward hacking**: Validate shaped rewards don't contradict LEAN verification

### 11. Alternative and Emerging Approaches (2024-2025)

#### 11.1 Whole-Proof Generation vs Step-by-Step

**Step-by-Step (Standard, Used Above):**
- Policy generates one tactic at a time
- Receives intermediate feedback from LEAN
- Iterative refinement until proof complete
- Advantages: Feedback at every step, easier credit assignment
- Disadvantages: Slow (many LEAN calls), sequential bottleneck

**Whole-Proof Generation:**
- Policy generates entire proof in one shot
- Single LEAN verification at end
- Advantages: Fast (one LEAN call), parallelizable sampling (pass@N)
- Disadvantages: Sparse feedback, difficult credit assignment
- Used by: DeepSeek-Prover-V1 (46.3% accuracy), improved by V2 with decomposition

**Hybrid (State-of-the-Art):**
- Decompose theorem into subgoals (whole-proof generation for decomposition)
- Prove each subgoal step-by-step
- Combine results
- Used by: DeepSeek-Prover-V2 (88.9% accuracy)

#### 11.2 Informal-to-Formal Translation (Autoformalization)

**Problem:** Natural language math → formal LEAN statements

**Approach:**
- Train translation model: Informal theorem statement → LEAN formalization
- Validate with LEAN compiler (type-checks)
- Use as data augmentation: Informal math textbooks → LEAN theorems

**Systems:**
- **Herald Dataset**: Natural language annotations for Mathlib4, 93.2% Pass@128 accuracy
- **Process-Driven Autoformalization**: Incremental translation with feedback
- **NL-FL Bootstrapping (DeepSeek-Prover-V2)**: Transfer informal reasoning to formal

**Relevance to Your Project:**
- Could generate natural language descriptions of TM theorems
- Train translation model: "If it is necessary that p, then p is always true" → `□p → always p`
- Useful for human-readable explanations of proofs

#### 11.3 Neurosymbolic Approaches

**Concept:** Combine neural networks with symbolic reasoning

**Approaches:**
- **Aesop (White-Box Automation)**: LEAN 4's extensible proof search, can integrate neural heuristics
- **Hammers**: Premise selection with ML, proof reconstruction in proof assistant
- **lean-auto**: Translates LEAN goals to FOL, calls SMT solvers (Z3, CVC5)

**Relevance:**
- Your model-checker (Z3) already neurosymbolic integration candidate
- RL policy could learn when to invoke model-checker vs. continue proof search
- Hybrid: Neural proof search + symbolic model-checking

#### 11.4 Large Model Test-Time Scaling

**Approach (AlphaProof):**
- Generate millions of problem variants at test time
- Fine-tune policy on variants
- Attempt original problem with adapted policy

**Benefits:**
- Problem-specific adaptation
- Leverages test-time compute
- Improves performance on hard problems

**Challenges:**
- Expensive: Millions of variant proofs
- Requires problem generator

**Relevance:**
- Could generate variants of TM theorems by:
  - Substituting formulas (p → q, etc.)
  - Changing operators (□ → ◇, past → future)
  - Varying axiom applications

#### 11.5 Multi-Agent and Hierarchical RL

**Concept:** Specialized agents for different proof tasks

**Approaches:**
- **Hierarchical RL**: High-level agent selects proof strategy, low-level agent executes tactics
- **Multi-Agent**: Separate agents for modal reasoning, temporal reasoning, combine outputs
- **Modular Policies**: Agent per operator type (modal, temporal, propositional)

**Relevance:**
- TM bimodal logic naturally hierarchical:
  - Modal sub-agent (S5 reasoning)
  - Temporal sub-agent (linear temporal logic)
  - Coordinator combines insights
- Could match your layered architecture (Layer 0 → Layer 1+)

## Recommendations

### 1. Adopt Hybrid Python+LEAN 4 Architecture for RL Training

**Rationale:**
- Proven pattern: All state-of-the-art systems (AlphaProof, DeepSeek-Prover-V2, LeanDojo) use Python for ML training with LEAN as verification oracle
- Mature ecosystem: PyTorch, JAX, Hugging Face enable faster development than pure LEAN
- Process-based communication: Stable, no FFI complexity, isolates LEAN crashes from training process
- Flexibility: Easy to swap RL algorithms, models, hyperparameters without modifying LEAN code

**Implementation:**
- Keep Logos in pure LEAN 4 (per previous report recommendation)
- Build separate LogosRL Python package for RL training infrastructure
- Use LeanDojo or Pantograph for gym-like environment

**Evidence:**
- AlphaProof: Python training controller + LEAN verification oracle → silver medal IMO 2024
- DeepSeek-Prover-V2: Python training (GRPO) + LEAN verification → 88.9% MiniF2F-test
- LeanDojo: Standard framework used by academic research and industry (Caltech, Stanford)

### 2. Use Pantograph for MCTS-Based RL, LeanDojo for Standard RL

**Rationale:**
- **Pantograph**: Optimized for Monte Carlo Tree Search, faster than LeanDojo, no Docker dependency
- **LeanDojo**: Mature ecosystem, larger benchmarks (122K+ theorems), retrieval-augmented baseline (ReProver)

**Decision Criteria:**
- If planning MCTS integration (AlphaProof-style): **Use Pantograph**
- If starting with simpler RL (GRPO, expert iteration): **Use LeanDojo** (easier onboarding)
- Can migrate later: Both provide process-based communication

**Implementation:**
```python
# Phase 2-4: Start with LeanDojo (simpler)
from lean_dojo import LeanGitRepo, Dojo

# Phase 6: Switch to Pantograph for MCTS (performance-critical)
from pypantograph import ProofState, RunTacticResult
```

**Evidence:**
- Pantograph paper: "Enables efficient proof search via powerful search algorithms such as Monte Carlo Tree Search"
- Pantograph: Written entirely in LEAN 4 (faster), no external dependencies
- LeanDojo: 122,517 theorems/proofs in Benchmark 4, established community

### 3. Implement GRPO Over PPO for RL Fine-Tuning

**Rationale:**
- **Memory efficiency**: No separate value network (50% less memory than PPO)
- **Simplicity**: Easier to implement and debug
- **Proven results**: DeepSeek-Prover-V2 (88.9% MiniF2F-test), DeepSeekMath success
- **Group baseline**: Natural fit for theorem proving (sample 32 proofs per theorem, compare within group)

**Implementation:**
```python
# Simplified GRPO vs PPO
# PPO: Requires policy network + value network + advantage estimation
# GRPO: Only policy network + group sampling + relative advantages

def grpo_loss(batch):
    baseline = batch.rewards.mean()  # Group baseline
    advantages = batch.rewards - baseline
    unlikeliness = -batch.log_probs.detach()  # Encourage diversity
    total_advantage = advantages + lambda_unlikeliness * unlikeliness
    loss = -(batch.log_probs * total_advantage).mean()
    return loss
```

**Modifications:**
- Add unlikeliness reward to address GRPO bias (recent research, arXiv:2506.02355)
- Increase PPO epochs if converting from PPO (mitigates distribution sharpening)

**Evidence:**
- DeepSeek-Prover-V2: State-of-the-art results with GRPO
- Memory: ~50% reduction vs PPO (no critic network)
- Research: "Rewarding the Unlikely: Lifting GRPO Beyond Distribution Sharpening" addresses limitations

### 4. Use Expert Iteration Before RL for Stable Bootstrap

**Rationale:**
- **Stable training**: Supervised learning more stable than RL initially
- **High-quality data**: Self-generated proofs verified by LEAN (no human annotation noise)
- **Warm start for RL**: Expert iteration gets to ~40-50% success rate, RL fine-tuning reaches 60%+

**Implementation Sequence:**
1. **Phase 3**: Supervised learning on extracted proofs → ~20% success rate
2. **Phase 4**: Expert iteration (10 iterations) → ~40-50% success rate
3. **Phase 5**: GRPO fine-tuning → ~60%+ success rate

**Hybrid Approach (DeepSeek-Prover-V2 Pattern):**
- Stage 1: Expert iteration with curriculum learning (non-CoT prover)
- Stage 2: RL with GRPO on top of expert iteration baseline

**Evidence:**
- DeepSeek-Prover-V2: Two-stage training (expert iteration + RL)
- Goedel-Prover: Expert iteration with scaffolded data synthesis
- REAL-Prover: Expert iteration pipeline for stepwise proofs

### 5. Implement Proof Progress Prediction for Dense Rewards

**Rationale:**
- **Solves sparse reward problem**: Binary LEAN verification only at proof completion
- **Lightweight**: Separate small model (1.3B parameters, MSE loss)
- **Proven effective**: LeanProgress demonstrates search guidance improvement

**Implementation:**
```python
# Train progress predictor on successful proofs
class ProgressPredictor(nn.Module):
    def __init__(self):
        self.encoder = AutoModel.from_pretrained("deepseek-coder-1.3b")
        self.regressor = nn.Linear(hidden_size, 1)  # Predict remaining steps

    def forward(self, proof_state, history):
        encoded = self.encoder(proof_state + history)
        remaining_steps = self.regressor(encoded)
        return remaining_steps

# Use in RL training
progress_reward = 1.0 / (progress_model(state) + 1.0)
total_reward = binary_lean_reward + lambda_progress * progress_reward
```

**Training Data:**
- Extract (state, actual_remaining_steps) from successful proofs
- Train with MSE loss and AdamW optimizer
- Validate: Predict on held-out proofs, check correlation with actual steps

**Evidence:**
- LeanProgress (February 2025): Lightweight framework for proof progress prediction
- Addresses RL impracticality from combinatorial explosion
- Alternative to full RL for search guidance

### 6. Start with Small Pre-Trained Models (1.3B-7B Parameters)

**Rationale:**
- **Faster iteration**: Smaller models train faster, cheaper
- **Sufficient capacity**: DeepSeek-Coder 1.3B used by LeanProgress, 7B by DeepSeek-Prover-V1 (46.3% accuracy)
- **Fine-tuning efficiency**: Pre-trained on code corpus, transfer to formal proofs

**Recommended Base Models:**
- **DeepSeek-Coder 1.3B**: Good balance of size and performance
- **DeepSeek-Coder 7B**: Better performance, still trainable on single GPU
- **CodeLlama 7B**: Alternative, strong code understanding

**Scaling Later (Optional):**
- After proving concept with 1.3B-7B models
- Scale to 34B-70B if needed (multi-GPU required)
- Optionally: Large model (DeepSeek-V3 671B) for cold-start data generation only

**Evidence:**
- LeanProgress: DeepSeek-Coder 1.3B
- DeepSeek-Prover-V1: 7B model, 46.3% accuracy (competitive)
- DeepSeek-Prover-V2: 671B model, 88.9% accuracy (state-of-the-art, but not necessary initially)

### 7. Extract and Augment Training Data Using Lean4trace Approach

**Rationale:**
- **Richer datasets**: Decompose composite proof steps, test automation tactics
- **Data efficiency**: More training examples from same LEAN code
- **Better generalization**: Multiple proof paths for same theorem

**Implementation:**
```python
# Data augmentation pipeline
def augment_proof(original_proof):
    augmented = []

    # Method 1: Decompose composite steps
    for step in original_proof:
        if is_composite(step):
            sub_steps = decompose(step)
            augmented.extend(sub_steps)
        else:
            augmented.append(step)

    # Method 2: Test automation tactics
    for state in original_proof.states:
        for tactic in automation_tactics:
            result = lean_env.test_tactic(state, tactic)
            if result.success:
                augmented.append((state, tactic, result.next_state))

    return augmented
```

**Automation Tactics to Test:**
- `simp`, `simp_all`: Simplification
- `omega`: Linear arithmetic
- `tauto`: Propositional tautologies
- `decide`: Decidable propositions
- `aesop`: Automated proof search

**Evidence:**
- Lean4trace paper (June 2024): Data augmentation for neural theorem proving
- Integrated into LEAN elaborator for on-the-fly modification
- Two methods: Decomposition + automation testing

### 8. Implement Curriculum Learning with Scaffolded Data Synthesis

**Rationale:**
- **Addresses cold-start**: Hard theorems → extract easier subgoals
- **Automatic difficulty ranking**: No manual annotation needed
- **Progressive learning**: Easy → medium → hard

**Implementation (Goedel-Prover Pattern):**
```python
# Curriculum generation
def generate_curriculum(hard_theorems, policy):
    curriculum = []

    for theorem in hard_theorems:
        # Attempt proof with current policy
        result = policy.attempt_proof(theorem)

        if result.failed:
            # Extract subgoals from failure
            subgoals = lean_env.extract_goal(result.failed_state)

            # Formalize subgoals as standalone theorems
            easy_theorems = [formalize_subgoal(sg) for sg in subgoals]
            curriculum.extend(easy_theorems)

    # Rank by difficulty (proof length proxy)
    curriculum.sort(key=lambda t: estimate_difficulty(t))
    return curriculum
```

**Difficulty Metrics:**
- Proof length (number of tactics)
- Number of premises required
- Statement complexity (AST depth)

**Evidence:**
- Goedel-Prover: Scaffolded data synthesis with `extract_goal`
- DeepSeek-Prover-V2: Subgoal decomposition with curriculum learning
- OpenAI Formal Math: Difficulty-parameterized synthetic data generators

### 9. Monitor for Reward Hacking and Validate with Pure LEAN Verification

**Rationale:**
- **Risk**: Shaped rewards (progress, unlikeliness, consistency) may not align with actual proof correctness
- **Solution**: Always validate final performance with binary LEAN verification only

**Monitoring:**
```python
# Training loop
for iteration in range(num_iterations):
    # Train with shaped rewards
    train_with_shaped_rewards(policy, shaped_reward_fn)

    # Validate with LEAN verification only
    lean_success_rate = evaluate_with_lean_only(policy, test_theorems)
    shaped_reward_mean = evaluate_shaped_rewards(policy, test_theorems)

    # Check for reward hacking
    if shaped_reward_mean > threshold and lean_success_rate < previous_success_rate:
        print("WARNING: Potential reward hacking detected")
        reduce_shaped_reward_weight()
```

**Red Flags:**
- High shaped reward but decreasing LEAN success rate
- Proofs that "look good" but don't verify
- Unusually long proofs (optimizing shaped reward instead of correctness)

**Mitigation:**
- Reduce shaped reward coefficients (λ_progress, λ_consistency)
- Increase weight of binary LEAN reward
- Ablation studies: Remove shaped rewards, check if performance drops

**Evidence:**
- Standard RL pitfall: Reward hacking when reward function misspecified
- Formal verification safeguard: LEAN provides ground truth, catch divergence early

### 10. Plan for Integration with Model-Checker (Three-Component Architecture)

**Rationale:**
- Previous report: Model-Checker (Python/Z3) ↔ Proof-Checker (LEAN 4) via serialization
- Current: RL training infrastructure also Python-based
- Opportunity: Unified Python ecosystem for model-checking + RL training

**Three-Component Integration:**

```python
# Component 1: Model-Checker (existing, Python + Z3)
from modelchecker import check_validity, get_counterexample

# Component 2: Proof-Checker (pure LEAN 4)
from lean_dojo import LeanGitRepo, Dojo

# Component 3: RL Training (new, Python + PyTorch)
from proofcheckerrl import ProofPolicy, LogosEnv

# Coordinated verification workflow
def hybrid_verification(formula):
    # Step 1: Check validity with model-checker (fast)
    is_valid, counterexample = check_validity(formula)

    if not is_valid:
        return "Invalid", counterexample

    # Step 2: Search for proof with RL policy (slower but certifies)
    proof = rl_policy.search_proof(formula, env)

    if proof:
        # Step 3: Verify proof in LEAN (ground truth)
        lean_verified = lean_env.verify(formula, proof)
        return "Proven", proof if lean_verified else None
    else:
        return "Valid but no proof found", None

# RL training with model-checker guidance
def train_with_modelchecker_hints(policy, theorems):
    for theorem in theorems:
        # Get model-checker hint (which formulas are valid)
        if check_validity(theorem):
            # Focus RL training on valid theorems (higher priority)
            policy.train_episode(theorem, weight=1.0)
        else:
            # Still train on invalid theorems (learn to recognize unprovable)
            policy.train_episode(theorem, weight=0.1)
```

**Benefits:**
- Model-checker filters unprovable theorems (saves RL exploration time)
- RL learns from model-checker counterexamples (negative examples)
- Proof certificates for valid theorems (LEAN proofs)
- Unified Python infrastructure (easier to maintain than Python+LEAN+separate-model-checker)

**Evidence:**
- VeriPlan (CHI 2025): Integrates LLM planner with formal verification, keep components separate
- INTEGRATION.md (lines 79-104): Coordinated verification pattern already designed

## Conclusion

This research establishes that **developing RL training loops for AI systems reasoning in LEAN 4 proof systems requires a hybrid Python+LEAN 4 architecture**. This recommendation differs from but complements the previous report's conclusion that pure LEAN 4 is optimal for proof-checker implementation.

**Key Insights:**

1. **Separation of Concerns**: Core proof verification logic belongs in pure LEAN 4 (type safety, formal guarantees), while RL training infrastructure belongs in Python (mature ML ecosystem, flexibility)

2. **Standard Pattern**: All state-of-the-art systems (AlphaProof achieving silver medal IMO 2024, DeepSeek-Prover-V2 reaching 88.9% MiniF2F-test) use process-based Python-LEAN communication, not FFI

3. **Tool Ecosystem**: Three mature options exist—LeanDojo (gym interface, large benchmarks), Pantograph (MCTS-optimized, faster), LeanInteract (REPL-based, simpler)—all enabling seamless Python-LEAN integration without tight coupling

4. **Training Methods**: Combine expert iteration (stable bootstrap), GRPO (memory-efficient RL), and proof progress prediction (dense rewards) for state-of-the-art performance

5. **Data is Critical**: Extract training data from LEAN repos using tools like Lean4trace (augmentation), LeanNavigator (state graph traversal), and LEAN-GitHub (large-scale datasets)

**Recommendations for Logos Project:**

- **Implement proof-checker in pure LEAN 4** (per previous report): TM bimodal logic, axioms, soundness, completeness, custom tactics
- **Build separate Python RL infrastructure**: LogosRL package with gym environment, policy networks, GRPO training
- **Use LeanDojo or Pantograph**: Start with LeanDojo (easier), migrate to Pantograph if adding MCTS
- **Training pipeline**: Supervised baseline → expert iteration → GRPO fine-tuning → advanced techniques (MCTS, test-time adaptation)
- **Three-component architecture**: Model-Checker (Python/Z3) ↔ Proof-Checker (LEAN 4) ↔ RL Training (Python) all via data exchange

The research clearly demonstrates that while pure LEAN 4 remains the best choice for implementing the proof system itself (correctness guarantees, type safety, formal verification), **RL training specifically benefits from Python's mature ML ecosystem** (PyTorch, JAX, Hugging Face) while using LEAN 4 as a verification oracle. This hybrid approach is not only justified but necessary for achieving state-of-the-art results in AI-assisted theorem proving.

## References

### Previous Research Report
- `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/005_lean4_language_research/reports/001-i-am-looking-to-build-a-proof-checker-pa.md` - LEAN 4 language integration research (conclusion: pure LEAN 4 optimal for proof-checker, Python+LEAN via serialization for model-checker integration)

### AlphaProof and AlphaZero-Inspired Systems
- [AlphaProof Paper - Julian's Blog](https://www.julian.ac/blog/2025/11/13/alphaproof-paper/)
- [AlphaProof system proves its worth at the Math Olympiad - StartupHub.ai](https://www.startuphub.ai/ai-news/ai-research/2025/alphaproof-system-proves-its-worth-at-the-math-olympiad/)
- [Mastering Olympiad Math Through Reinforcement Learning - BioEngineer.org](https://bioengineer.org/mastering-olympiad-math-through-reinforcement-learning/)
- [AI achieves silver-medal standard solving IMO problems - Google DeepMind](https://deepmind.google/blog/ai-solves-imo-problems-at-silver-medal-level/)
- [Olympiad-level formal mathematical reasoning with reinforcement learning - Nature](https://www.nature.com/articles/s41586-025-09833-y)
- [AI math genius delivers 100% accurate results - Phys.org](https://phys.org/news/2025-11-ai-math-genius-accurate-results.html)

### LeanDojo and ReProver
- [LeanDojo: Theorem Proving with Retrieval-Augmented Language Models](https://leandojo.org/leandojo.html)
- [LeanDojo: Machine Learning for Theorem Proving in Lean - Documentation](https://leandojo.readthedocs.io/)
- [LeanDojo: AI-Driven Formal Theorem Proving in the Lean Ecosystem](https://leandojo.org/)
- [ReProver: Retrieval-Augmented Theorem Provers for Lean - GitHub](https://github.com/lean-dojo/ReProver)
- [LeanDojo: Theorem Proving with Retrieval-Augmented Language Models - arXiv](https://ar5iv.labs.arxiv.org/html/2306.15626)

### DeepSeek-Prover Series
- [DeepSeek-Prover-V2 - GitHub](https://github.com/deepseek-ai/DeepSeek-Prover-V2)
- [DeepSeek-Prover-V2: Open-Source AI for Lean 4 Formal Theorem Proving - Medium](https://medium.com/aimonks/deepseek-prover-v2-open-source-ai-for-lean-4-formal-theorem-proving-ab7f9910576b)
- [DeepSeek-Prover-V1.5: Harnessing Proof Assistant Feedback for RL and MCTS - arXiv](https://arxiv.org/abs/2408.08152)
- [DeepSeek-Prover-V2: Advancing Formal Mathematical Reasoning via RL - arXiv](https://arxiv.org/abs/2504.21801)
- [DeepSeek-Prover: Advancing Theorem Proving in LLMs through Large-Scale Synthetic Data](https://arxiv.org/html/2405.14333v1)
- [deepseek-ai/DeepSeek-Prover-V2-671B - Hugging Face](https://huggingface.co/deepseek-ai/DeepSeek-Prover-V2-671B)

### Python-LEAN 4 Integration Tools
- [LeanInteract: A Python Interface for Lean 4 - GitHub](https://github.com/augustepoiroux/LeanInteract)
- [lean-interact - PyPI](https://pypi.org/project/lean-interact/)
- [leanclient: Python client for lean4 language server - GitHub](https://github.com/oOo0oOo/leanclient)
- [leanclient - PyPI](https://pypi.org/project/leanclient/)
- [Pantograph: A Machine-to-Machine Interaction Interface - arXiv](https://arxiv.org/abs/2410.16429)
- [PyPantograph - GitHub](https://github.com/stanford-centaur/PyPantograph)
- [Pantograph (leanprover mirror) - GitHub](https://github.com/leanprover/Pantograph)

### RL Algorithms and Training Methods
- [HTPS: Hypertree proof search for neural theorem proving - ABEL System](http://cermics.enpc.fr/~hayata/ABEL_pre.pdf)
- [DeepSeekMath: Pushing the Limits of Mathematical Reasoning - arXiv](https://arxiv.org/pdf/2402.03300)
- [Theory Behind GRPO - AI Engineering Academy](https://aiengineering.academy/LLM/TheoryBehindFinetuning/GRPO/)
- [Rewarding the Unlikely: Lifting GRPO Beyond Distribution Sharpening - arXiv](https://arxiv.org/abs/2506.02355v1)
- [The Math Behind DeepSeek: A Deep Dive into GRPO - Medium](https://medium.com/@sahin.samia/the-math-behind-deepseek-a-deep-dive-into-group-relative-policy-optimization-grpo-8a75007491ba)
- [What is GRPO? Group Relative Policy Optimization Explained - DataCamp](https://www.datacamp.com/blog/what-is-grpo-group-relative-policy-optimization)
- [Group Relative Policy Optimization (GRPO) - verl documentation](https://verl.readthedocs.io/en/latest/algo/grpo.html)

### Data Extraction and Dataset Building
- [LEAN-GitHub: A Large-Scale Dataset for ATP - MarkTechPost](https://www.marktechpost.com/2024/07/25/lean-github-a-large-scale-dataset-for-advancing-automated-theorem-proving/)
- [Lean4trace: Data augmentation for neural theorem proving - OpenReview](https://openreview.net/forum?id=sjLWmLeJ6R)
- [Lean Workbook: A large-scale Lean problem set - arXiv](https://arxiv.org/html/2406.03847v1)
- [Generating Millions Of Lean Theorems - arXiv](https://arxiv.org/html/2503.04772v1)
- [Herald: A Natural Language Annotated Lean 4 Dataset - arXiv](https://arxiv.org/abs/2410.10878)
- [A Lean Dataset for International Math Olympiad - arXiv](https://arxiv.org/html/2411.18872v2)

### Reward Shaping and Progress Prediction
- [LeanProgress: Guiding Search via Proof Progress Prediction - arXiv](https://arxiv.org/html/2502.17925)
- [LeanProgress: Guiding Search for Neural Theorem Proving](https://leandojo.org/leanprogress.html)

### Expert Iteration and Curriculum Learning
- [Lean-STaR: Learning to Interleave Thinking and Proving - arXiv](https://arxiv.org/html/2407.10040v1)
- [Goedel-Prover: Open-Source ATP in Lean 4 - EmergentMind](https://www.emergentmind.com/topics/goedel-prover)
- [REAL-Prover: Retrieval Augmented Lean Prover - arXiv](https://arxiv.org/html/2505.20613v1)
- [Formal Mathematics Statement Curriculum Learning - OpenAI (ICML 2022)](https://cdn.openai.com/papers/Formal_Mathematics_Statement_Curriculum_Learning__ICML_2022.pdf)

### Additional Systems and Tools
- [TheoremLlama: Transforming General-Purpose LLMs into Lean4 Experts - arXiv](https://arxiv.org/html/2407.03203v1)
- [Lean Copilot: Towards Large Language Models as Copilots for Theorem Proving - arXiv](https://arxiv.org/html/2404.12534v1)
- [Aesop: White-box automation for Lean 4 - GitHub](https://github.com/leanprover-community/aesop)
- [Lean-Auto: An Interface between Lean 4 and ATPs - SpringerLink](https://link.springer.com/chapter/10.1007/978-3-031-98682-6_10)
- [Process-Driven Autoformalization in Lean 4 - arXiv](https://arxiv.org/html/2406.01940v1)

### MCTS and Proof Search
- [Pantograph: A Machine-to-Machine Interaction Interface - SpringerLink](https://link.springer.com/chapter/10.1007/978-3-031-90643-5_6)
- [DeepSeek-Prover-V1.5: Harnessing MCTS - OpenReview](https://openreview.net/forum?id=I4YAIwrsXa)
- [BFS-Prover: Scalable Best-First Tree Search for LLM-based ATP - arXiv](https://arxiv.org/html/2502.03438)
- [Monte Carlo Tree Search Applications to Neural Theorem Proving - MIT](https://dspace.mit.edu/handle/1721.1/156761)

### General Resources
- [Lean 4 programming language and theorem prover - GitHub](https://github.com/leanprover/lean4)
- [Lean4: How the theorem prover works - VentureBeat](https://venturebeat.com/ai/lean4-how-the-theorem-prover-works-and-why-its-the-new-competitive-edge-in)
- [The Lean 4 Theorem Prover and Programming Language - lean-lang.org](https://lean-lang.org/papers/lean4.pdf)
- [Theorem Proving using Machine Learning – Lean 4 - IsaacTeng](https://isaacteng.co.uk/2024/04/15/theorem-proving-using-machine-learning-lean-4/)
- [Machine Learning for Theorem Proving - Lean Zulip Archive](https://leanprover-community.github.io/archive/stream/219941-Machine-Learning-for-Theorem-Proving/)

---

**Report Generated**: 2025-12-01
**Completion Status**: RESEARCH_COMPLETE
