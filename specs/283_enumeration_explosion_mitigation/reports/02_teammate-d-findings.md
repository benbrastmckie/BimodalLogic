# Teammate D (Horizons): Strategic Analysis of Enumeration Optimization

**Task**: 283 — Mitigate cross-product explosion in exhaustive formula enumeration at complexity ≥ 8
**Date**: 2026-06-04
**Angle**: Long-term alignment, paradigm assessment, strategic direction

---

## 1. Is Exhaustive Enumeration the Right Paradigm?

### Key Finding: Exhaustive enumeration has diminishing returns above c7, and the field has moved toward quality-focused synthetic data generation.

**The efficiency problem by the numbers:**

| Tier | Records | Valid | Invalid | Timeout | Useful for Training |
|------|---------|-------|---------|---------|-------------------|
| c4   | 408     | 23 (5.6%)   | 333 (81.6%) | 52 (12.7%)  | 356 (87.3%) |
| c5   | 2,283   | 162 (~7%)   | ~1,800      | 321 (~14%)  | ~1,962 (86%) |
| c6   | 13,064  | ~1,176 (9%) | ~10,800     | ~2,220 (17%)| ~11,980 (83%) |
| c7   | 77,272  | 8,182 (10.6%)| 52,885 (68.4%)| 16,205 (21%)| 61,067 (79%) |
| c8 (est.) | ~500K | ~55K (11%) | ~340K | ~105K (21%+)| ~395K (79%) |

**Critical observation**: 21% of c7 formulas timeout — producing **zero training signal**. At c8+, this percentage will likely increase further. Every timeout represents wasted computation that could have been spent on formulas that produce labeled data.

**What the ML field says (2024-2026 state of the art)**:

1. **DeepSeek-Prover-V2** (April 2025): Entirely bootstrapped from synthetic data with NO exhaustive enumeration. Uses backward proof generation via subgoal decomposition — starts from theorems, decomposes into subgoals, solves each with a 7B prover, then reconstructs complete proofs. Training data is "hundreds of high-quality examples" per round, not millions of enumerated formulas.

2. **"Theorem Prover as a Judge"** (ACL 2025): Only 3,508 formally-verified training samples achieved competitive performance, with the authors noting that "OpenMathInstruct reported only a 3.9% improvement on MATH despite an 8× increase in dataset size." Quality verification of intermediate steps outperforms raw quantity.

3. **SynLogic** (NeurIPS 2025): Parameterized task generation with difficulty control and rule-based verifiers. Generates ~49K samples across 35 task types. The key insight: controllable difficulty is more valuable than exhaustive coverage.

4. **LeanAgent** (ICLR 2025): Uses curriculum learning with complexity measures derived from proof structure — trains on increasingly difficult problems. The ordering matters more than the count.

**Confidence**: HIGH — The ML research consensus is clear: quality, difficulty calibration, and proof certificates matter more than exhaustive enumeration for training neural provers.

### Recommended Approach

Exhaustive enumeration should remain **for c4-c7** (already complete, fast, serves as ground truth). For c8+, switch to a **hybrid generation strategy** that prioritizes:
- Formulas with interesting proof structure (non-trivial valid and non-trivial invalid)
- Difficulty calibration using existing prover performance as signal
- Proof certificates for valid formulas (backward generation)
- Incremental delivery rather than all-or-nothing enumeration

---

## 2. Backward/Goal-Directed Generation Assessment

### Key Finding: Backward generation from axiom schemas could produce higher-value training data at c8+ with proof certificates and zero timeout waste.

**How it would work for TM bimodal logic:**

1. **Start from axiom schemas**: Instantiate the 41 BX axiom schemas with subformulas of increasing complexity. Each instantiation is a valid formula with a proof certificate (the axiom instance itself).

2. **Derive via inference rules**: Apply modus ponens, temporal/modal necessitation to produce derived valid formulas. Each derived formula has a proof tree.

3. **Compose theorems**: Apply BX5 (self-accumulation), BX6 (absorption), BX7 (linearity) to construct complex Until/Since theorems. These are exactly the "interesting" formulas that the exhaustive enumerator struggles to find among millions of syntactic variants.

**Advantages over exhaustive enumeration:**
- Every generated formula is valid with a proof certificate → no prover calls needed for the valid set
- No timeout waste — only formulas that are constructively provable are generated
- Natural difficulty ordering from derivation depth
- The `axiom-instances.jsonl` file (136KB, already exists) shows this approach is partially implemented

**Disadvantages:**
- Biased toward provable formulas — invalid examples must come from elsewhere
- Coverage gaps: may miss valid formulas not reachable from BX axioms via known derivation strategies
- Need a separate mechanism for generating high-quality invalid examples

**A balanced approach**: Use backward generation for valid formulas (c8+) and targeted structural mutations for invalid formulas (negate subformulas of known valid formulas, swap temporal operators, introduce modal-temporal mismatches).

**Evidence**: DeepSeek-Prover-V2's entire training pipeline is backward: decompose hard theorems into subgoals, solve subgoals, reconstruct. They never enumerate all possible theorems at a given complexity.

**Confidence**: HIGH — Backward generation is the dominant paradigm in 2025-2026 neural theorem prover training.

---

## 3. Incremental Delivery, Monitoring, and Logging

### Key Finding: The current all-or-nothing enumeration architecture is the biggest operational risk, independent of algorithmic optimization.

**Current pain points** (from the c8 runtime trace in report 01):
- 3h42m of enumeration before ANY output — a crash/kill loses everything
- No progress visibility: RSS monitoring was the only available signal
- No ability to resume from where things left off
- No incremental datasets: can't start training on partial data

**Recommended monitoring infrastructure:**

1. **Per-level progress callbacks**: After each complexity level completes, emit a structured log line:
   ```
   {"level": 7, "formulas": 259888, "elapsed_ms": 480, "cache_entries": 1247, "rss_mb": 310}
   ```

2. **Per-partition progress within a level**: For c8's 21 partitions, emit after each:
   ```
   {"level": 8, "partition": "(3,4)", "operator": "imp", "cross_product_size": 126720, "filtered": 31680, "elapsed_ms": 45000}
   ```

3. **Incremental JSONL flushing**: Write formulas to disk after each level or partition completes. This means c4-c7 data is available in seconds, and c8 partitions are saved as they complete.

4. **Resumable checkpointing**: Serialize the `EnumCache` HashMap after each level completes. On restart, load the cache and skip already-computed levels. This requires changing the return type to include the cache.

5. **ETA estimation**: Track formulas/second per partition, use the growth factor (~6.5×) to estimate remaining time.

**Implementation priority**: Incremental JSONL flushing is the highest-value change — it provides crash resilience AND enables partial dataset use. The monitoring metrics are a close second.

**Connection to the optimization task**: Even with Array-based accumulation (5-20× speedup), c8 will still take minutes. Monitoring transforms minutes of blind waiting into informed progress tracking.

**Confidence**: HIGH — This is standard engineering practice for long-running computations. No research needed, just implementation.

---

## 4. ML Training Perspective: What Dataset Properties Matter?

### Key Finding: For neural theorem provers, diversity and difficulty calibration matter far more than exhaustive coverage.

**Properties that matter most (ranked):**

1. **Label balance**: The current datasets are heavily imbalanced (89% invalid at c7). Neural provers need roughly balanced valid/invalid examples, or at minimum intentional upsampling of the minority class. The current approach generates massive invalid sets and tiny valid sets.

2. **Proof structure diversity**: For valid formulas, the proof tree structure is training signal. A formula proved by one modus ponens step is less valuable than one requiring temporal induction over Until operators. The existing `interestingness_score` field (visible in the JSONL records) partially captures this but isn't used during generation.

3. **Difficulty calibration**: SynLogic (NeurIPS 2025) uses model performance to calibrate difficulty — generating problems at the frontier of what the model can solve. The existing `difficultyTier` field could drive this: stop generating "easy" formulas and focus on "medium" and "hard" tiers.

4. **Countermodel quality**: For invalid formulas, the countermodel IS the training signal. The existing enriched countermodels (with branch formulas, modal/temporal formulas) are excellent — this is a strength of the current approach.

5. **Multiple representations**: The existing dataset provides 9 formula representations (string, AST, s-expr, tokens, pattern key, features, folded variants). This is unusually comprehensive and valuable for training.

**What existing benchmarks look like:**

- **miniF2F**: 488 problems, manually curated from math olympiads. Quality over quantity.
- **ProverBench**: 325 problems including hard AIME instances. Focused on difficulty frontier.
- **ModalLogicBench** (2025): Evaluates modal logic reasoning in LLMs — directly relevant, though focused on evaluation rather than training.
- **LTLBench** (2024): 2,000 temporal reasoning challenges generated via random directed graphs + LTL formulas + NuSMV model checker. Uses graph-based generation, NOT exhaustive enumeration.
- **LTLZinc** (2025): Benchmarking framework for neuro-symbolic temporal reasoning with parameterized difficulty.

**Key insight from the literature**: NO major benchmark or training dataset uses exhaustive syntactic enumeration. They all use targeted generation strategies — parameterized puzzles (SynLogic), backward proof construction (DeepSeek-Prover), graph-based generation (LTLBench), or manual curation (miniF2F).

**Confidence**: HIGH — Well-supported by the literature review.

---

## 5. Dataset Versioning and Reproducibility

### Key Finding: The current dataset infrastructure is surprisingly mature but lacks version tracking as the enumerator evolves.

**Current strengths** (already implemented):
- Rich metadata files per complexity tier (`_metadata.json`)
- Multiple formula representations (9 per record)
- Decision method distribution tracking
- Interestingness scoring
- Split management (`bmlogic-bench-splits.json`)

**Missing pieces:**

1. **Enumerator version hash**: Each dataset should record the git commit of the enumerator that generated it. When the enumerator changes (e.g., Array-based accumulation), regenerated datasets should be traceable.

2. **Generation parameters record**: Store the exact `EnumConfig` / `EnumParams` used, including any new parameters (filter settings, canonical form flags, sampling strategies).

3. **Diff tracking**: When regenerating a tier after enumerator improvement, record what changed — new formulas added, formulas removed (if any due to dedup changes), formulas reclassified.

4. **Schema version**: The JSONL schema has evolved (enriched countermodels, folded representations were added). A schema version field enables compatibility checks.

5. **Provenance chain**: For datasets generated by multiple methods (exhaustive c4-c7 + backward generation c8+), each record should indicate its generation method.

**Confidence**: MEDIUM — Good practice but not blocking. The existing metadata infrastructure is a solid foundation.

---

## 6. Strategic Alignment with Project Roadmap

### Key Finding: Dataset generation is strategically peripheral to the completeness effort but has independent publication value.

**Direct roadmap impact**: Minimal. The completeness proof (tasks 155 → 202) doesn't use the dataset, and the dataset doesn't help prove completeness. The two workstreams are independent.

**Indirect synergies:**

1. **Prover improvements benefit both**: The tableau prover used for dataset labeling is the same infrastructure that could eventually be used for automated reasoning within completeness proofs. Fixing timeout issues (21% at c7) would benefit both the dataset and any future prover-assisted proof steps.

2. **Axiom instance generation validates axiom soundness**: The `axiom-instances.jsonl` file effectively tests that axiom schema instantiation produces valid formulas. This is a lightweight sanity check on soundness.

3. **Dataset as publication artifact**: A high-quality, exhaustive bimodal logic dataset with proof certificates could be an independent publication — "BMLogic: A Verified Training Dataset for Bimodal Temporal-Modal Reasoning." This complements the completeness paper.

**Resource allocation recommendation**: The completeness proof is the primary academic goal. Dataset optimization should be time-boxed — Phase 1 (Array + streaming filter) from report 01 should take 1-2 hours and unlock c8. Don't spend 16-24 hours on elaborate enumeration redesigns when the completeness proof needs those hours more.

**Confidence**: HIGH — Clear from the roadmap structure.

---

## 7. Creative Alternatives and Strategic Recommendations

### 7.1 Hybrid Generation Strategy

**Recommended architecture for c8+:**

```
Tier 1: Exhaustive (c4-c7) — DONE, 93K records
  ↓ provides: ground truth, balanced coverage, reproducible baseline

Tier 2: Optimized Exhaustive (c8) — Task 283 Phase 1-2
  ↓ Array accumulation + streaming filter → feasible in 10-30 min
  ↓ provides: ~500K records, extending the exhaustive foundation

Tier 3: Backward Generation (c8-c10+) — New task recommended
  ↓ Axiom schema instantiation → derivation → proof certificates
  ↓ provides: valid formulas with proofs, no timeout waste

Tier 4: Targeted Invalid Generation (c8+) — New task recommended
  ↓ Structural mutation of valid formulas from Tier 3
  ↓ provides: hard invalid examples near the validity boundary

Tier 5: Active Learning Loop (future) — Aspirational
  ↓ Model uncertainty → generate formulas at decision boundary
  ↓ provides: maximally informative training examples
```

### 7.2 Curriculum Training Strategy

Train in stages matching the dataset tiers:
1. Pre-train on c4-c6 (easy, fast convergence)
2. Fine-tune on c7 (medium difficulty, larger set)
3. Fine-tune on c8 optimized exhaustive + backward-generated valid formulas
4. RL phase using prover feedback on c9+ targeted formulas

This mirrors the LeanAgent approach (ICLR 2025) of curriculum-based training with increasing complexity.

### 7.3 Community Dataset Opportunities

- **ModalLogicBench** (2025): Could be adapted for training (currently evaluation-only)
- **LTLBench**: 2,000 temporal reasoning challenges — different logic but related domain
- **No existing S5+temporal bimodal logic training dataset exists** — this project's dataset would be first-of-its-kind

### 7.4 The Real Question: What Problem Are We Solving?

The task frames this as "mitigate explosion" — an engineering optimization. But the deeper question is: **what dataset do we actually need?**

If the goal is to train a neural theorem prover for TM bimodal logic:
- We need ~50-100K high-quality, balanced, diverse training examples
- We already have 93K exhaustive examples at c4-c7
- The c8 explosion is only a problem if exhaustive c8 enumeration is required
- It probably isn't — targeted generation at c8+ would be more valuable

**The strongest recommendation**: Do Phase 1 from report 01 (Array + streaming filter) to make c8 feasible. This is a 1-2 hour investment with 5-20× payoff. Then assess whether the resulting c8 dataset actually improves training before investing further in enumeration optimization. The 93K c4-c7 records may already be sufficient for initial model training, with c8+ data providing diminishing returns until the model architecture is validated.

**Confidence**: HIGH — This recommendation is conservative, evidence-based, and time-efficient.

---

## Summary of Confidence Levels

| Finding | Confidence | Basis |
|---------|-----------|-------|
| Exhaustive enumeration has diminishing returns | HIGH | ML literature consensus (DeepSeek-Prover-V2, SynLogic, TP-as-Judge) |
| Backward generation is the dominant paradigm | HIGH | 2025-2026 state of the art across multiple papers |
| Incremental delivery is critical | HIGH | Standard engineering practice |
| Diversity > exhaustiveness for training | HIGH | Curriculum learning literature (LeanAgent, GAR) |
| Hybrid generation strategy | HIGH | Combines strengths of multiple approaches |
| Dataset already has independent publication value | MEDIUM | Requires framing and comparison with existing benchmarks |
| Active learning loop is feasible | LOW | Aspirational — requires model infrastructure not yet built |

---

## Sources

- [DeepSeek-Prover-V2](https://arxiv.org/html/2504.21801v1) — Backward proof generation via subgoal decomposition
- [SynLogic (NeurIPS 2025)](https://arxiv.org/html/2505.19641v1) — Parameterized synthetic logic data with difficulty control
- [Theorem Prover as a Judge (ACL 2025)](https://arxiv.org/html/2502.13137) — Quality over quantity in synthetic data
- [LeanAgent (ICLR 2025)](https://proceedings.iclr.cc/paper_files/paper/2025/file/b67c77f8db8b991d73d6f2e16f491840-Paper-Conference.pdf) — Lifelong learning with curriculum complexity
- [GAR: Generative Adversarial RL](https://arxiv.org/pdf/2510.11769) — Implicit curriculum learning for theorem proving
- [LTLBench](https://arxiv.org/html/2407.05434v1) — Temporal logic benchmarks via graph-based generation
- [ModalLogicBench (2025)](https://link.springer.com/chapter/10.1007/978-981-95-0014-7_2) — Modal logic reasoning evaluation
- [SPOT randltl](https://spot.lre.epita.fr/randltl.html) — LTL formula generator with operator priority control
- [Lean 4 Collections](https://lean4.dev/language/data-modeling/collections) — Array vs List performance characteristics
