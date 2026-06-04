# Teammate B Findings: Prior Art and Alternative Paradigms

- **Task**: 283 — Mitigate cross-product explosion in exhaustive formula enumeration at complexity >= 8
- **Date**: 2026-06-04
- **Angle**: Alternative approaches, prior art, and community best practices
- **Teammate**: B (Alternative Approaches)

## 1. SPOT randltl: Probabilistic Generation with Simplification

### Key Findings

SPOT's `randltl` generates random LTL formulas using a **probabilistic grammar-based** approach, not exhaustive enumeration. The algorithm:

1. **Tree-size parameterized**: Builds syntax trees recursively from the root, selecting a target tree size (default 15, configurable via `--tree-size=N` or ranges like `--tree-size=22..30`).
2. **Operator priorities**: Each operator has a probability weight (default: atomic propositions=3, binary/unary=1 each). Selection probability = priority / sum_of_all_priorities. Adjustable via `--ltl-priorities`.
3. **Automatic simplification**: During construction, trivial simplifications are applied (e.g., `F(F(a))` -> `F(a)`), so output formulas may be smaller than the specified tree size. The `-r` flag enables stronger rewriting.
4. **Duplicate avoidance**: By default, `randltl` never outputs the same formula twice, internally retrying up to 100,000 times. `--allow-dups` disables this.

### Relevance to Task 283

SPOT does **not** enumerate exhaustively. Its approach is fundamentally probabilistic, sampling from the space of formulas with configurable operator distribution. The simplification-during-construction pattern is directly relevant — applying S5/temporal simplifications during cross-product generation (not after) would avoid materializing trivially reducible formulas.

### Recommended Approach
Adapt SPOT's operator-priority-weighted sampling as a **complement** to exhaustive enumeration at high complexity. For c9+, switch from exhaustive to priority-weighted sampling with duplicate detection.

**Confidence**: High (well-documented, mature tool)

---

## 2. LTLBench: Pipeline-Based Benchmark Synthesis

### Key Findings

LTLBench (2024) is a benchmark for evaluating temporal reasoning in LLMs, consisting of 2,000 temporal reasoning challenges across 12 LLMs. Its generation pipeline:

1. Uses **random directed graph generation** combined with LTL formulas
2. Employs the **NuSMV model checker** for verification
3. Controls difficulty by varying the number of formula operators and events
4. Automatically synthesizes challenges rather than enumerating all possible formulas

### Relevance to Task 283

LTLBench demonstrates that the community has moved away from exhaustive enumeration for benchmark generation. The key insight: **generate formulas with verifiable properties rather than generating all formulas and filtering**. This aligns with task 283's observation that only 5-11% of enumerated formulas are valid — a 90%+ waste rate.

### Recommended Approach
Consider a **property-directed generation** strategy: generate formulas that are guaranteed to have interesting properties (valid, invalid-but-hard, specific proof patterns) rather than exhaustively enumerating and filtering.

**Confidence**: Medium (approach is sound but LTLBench targets a different use case — LLM evaluation, not prover training)

---

## 3. SynLogic (NeurIPS 2025): Rule-Based Parameterized Generation

### Key Findings

SynLogic is a framework for synthesizing verifiable reasoning data covering **35 diverse logical reasoning tasks** (Sudoku, Game of 24, Cipher, etc.). Key design decisions:

1. **Parameter-identified difficulty control**: For each task, key parameters controlling difficulty are identified (e.g., grid size in Sudoku).
2. **Rule-based generators**: Manually implemented generators with embedded constraints produce valid instances directly.
3. **Task-specific verifiers**: Each task has a corresponding verifier for automated correctness checking.
4. **Difficulty calibration**: Upper bounds set using strong models (DeepSeek R1, OpenAI-o3-mini), lower bounds using chat models.

### Relevance to Task 283

SynLogic does **not** cover temporal or modal logic specifically. However, its approach of parameterized generation with verifiers is directly applicable. The key principle: **generate instances with built-in difficulty control and immediate verification**, rather than brute-force enumeration.

For bimodal logic, this maps to:
- Parameters: complexity, modal depth, temporal depth, operator distribution
- Generator: Grammar-based with structural constraints
- Verifier: The existing tableau prover

### Recommended Approach
Design a **parameterized generator** for bimodal logic formulas that produces instances at controlled difficulty levels, rather than enumerating all formulas at a given complexity. This is especially valuable for c9+ where exhaustive enumeration is infeasible regardless of optimization.

**Confidence**: Medium (the framework concept is strong, but adapting it to bimodal logic requires significant domain-specific design)

---

## 4. Canonical Normal Forms for LTL

### Key Findings

The Esparza-Rubio-Sickert line of work on LTL normalization (LICS 2020, JACM 2023) provides:

1. **Normal form**: Every LTL formula is equivalent to a formula of the form `⋀ᵢ₌₁ⁿ (GF φᵢ ∨ FG ψᵢ)` where φᵢ and ψᵢ contain only past operators.
2. **Single exponential blow-up**: Previous procedures had non-elementary worst-case; the 2023 version achieves single exponential via purely syntactic rewrite rules.
3. **Direct syntactic procedure**: No need for intermediate automata or regular expression conversion.

A companion paper (arXiv:2304.08872, "A Simple Rewrite System for the Normalization of Linear Temporal Logic") provides a simpler rewrite-rule-based approach.

### Relevance to Task 283

For **pure LTL**, enumerating only formulas in normal form would dramatically reduce the search space since many syntactically distinct formulas map to the same normal form. However, the TM bimodal logic combines S5 modality with LTL, and no canonical normal form exists for the full combined logic.

The **partial application** is: use LTL normal form insights to prune the temporal subformula space. For instance:
- `G(G(φ))` ≡ `G(φ)` — already noted in the existing report (structural pruning)
- `F(F(φ))` ≡ `F(φ)` — same
- Under S5: `□(□(φ))` ≡ `□(φ)`

More powerfully: `φ U (ψ U χ)` can be rewritten, and many untl/snce combinations have canonical simplifications.

### Recommended Approach
Implement a **normalization filter** that checks during cross-product generation whether the resulting formula is already in a simplified/canonical form. Reject formulas that are not canonical representatives. This extends the structural pruning (strategy 5.4 in the existing report) with formal backing from LTL normalization theory.

**Confidence**: Medium-high (the theory is solid, but adapting LTL normal forms to bimodal logic with S5 requires careful handling of the modal/temporal interaction)

---

## 5. Alpha-Equivalence Under Atom Permutation

### Key Findings

The theory of generating objects modulo symmetry is well-established:

1. **Burnside's lemma**: Counts the number of distinct objects under a group action. With 3 atoms and S₃ symmetry, the number of distinct formulas is |F|/6 on average (upper bound — the actual orbit sizes vary).
2. **Pólya enumeration theorem**: Generalizes Burnside to weighted counting. Can compute exact counts of formulas-up-to-permutation without enumerating all formulas.
3. **Canonical representative selection**: Use the lexicographically smallest member of each equivalence class. For formulas: atoms appear in order of first occurrence in a left-to-right DFS traversal.
4. **McKay's canonical construction path / canonical deletion**: A general algorithm for isomorph-free exhaustive generation that visits every equivalence class exactly once. The key insight: objects are only output when their construction path matches the canonical deletion path. This is entirely local — no global storage of visited objects needed.

### Concrete Algorithm for Bimodal Logic

For 3 atoms {p, q, r}:
1. **Canonical ordering**: In any formula, the first atom encountered in left-to-right DFS must be `p`, the second must be `q`, the third must be `r`.
2. **Filtering rule**: During enumeration, after constructing a formula, check if atoms appear in canonical order. If not, reject.
3. **Expected reduction**: With 3 atoms, up to 3! = 6 permutations of each formula exist. Average reduction factor is **3-6x** (not all formulas use all 3 atoms, so some have smaller orbits).

### McKay Adaptation

The canonical construction path can be adapted:
- **Objects**: Bimodal logic formulas with labeled atoms
- **Augmentations**: Adding subformulas (imp, box, untl, etc.)
- **Canonical labeling**: Re-label atoms so they appear in DFS-first-occurrence order
- **Rejection test**: After augmentation, check if the canonical labeling of the result matches the construction path used

This is more sophisticated than the simple first-occurrence filter and guarantees no redundancy, but is more complex to implement.

### Recommended Approach
Start with the **simple first-occurrence filter** (atoms appear in DFS order). This is O(|formula|) per formula and provides 3-6x reduction with minimal implementation effort. If further reduction is needed, implement the full McKay-style canonical construction path.

**Confidence**: High (the mathematical foundations are rock-solid; the simple filter is easy to implement; the McKay adaptation is well-understood for combinatorial objects)

---

## 6. Grammar-Based Generation with Coverage Guarantees

### Key Findings

The SAT community has developed sophisticated formula generators:

1. **Community-structured generation** (Ansótegui et al., AIJ 2017): Generates SAT instances with community structure matching industrial problems. Uses modularity-based random generation.
2. **Scale-free generation** (2017): Variables are selected with non-uniform probability following a power-law distribution.
3. **Hidden-solution generators** (2005): Generate satisfiable instances by planting solutions and building clauses around them.
4. **AIGEN (CAV 2021)**: Uses ROBDDs for uniform random generation of Boolean functions / transition systems. The canonical BDD representation enables true uniform sampling over the space of all Boolean functions with n variables.

### Relevance to Task 283

For bimodal logic dataset generation, the key insight from SAT generators is: **you don't need all formulas — you need representative formulas with controlled properties**. Generators like AIGEN achieve diversity through uniform sampling over canonical representations (BDDs), not through exhaustive enumeration.

The AIGEN approach is particularly interesting: using canonical representations (BDDs for Boolean functions, or a canonical normal form for bimodal logic) as the enumeration basis, rather than syntax trees. Every distinct canonical form represents a unique semantic class. However, this requires a canonical form for bimodal logic, which doesn't fully exist.

### Recommended Approach
For c8: stick with optimized exhaustive enumeration (Array + streaming filter). For c9+: transition to a **grammar-based generator** with structural diversity controls (operator distribution targets, depth constraints, atom balance) and use the tableau prover as the quality oracle.

**Confidence**: Medium (the approach is sound but requires significant engineering to match the coverage of exhaustive enumeration at lower complexities)

---

## 7. Semantic Deduplication via Small-Model Hashing

### Key Findings

1. **S5 small model property**: Any satisfiable S5 formula has a model with at most linearly many worlds (in the formula size). For S5 specifically, NP-completeness of satisfiability implies models of polynomial size.
2. **Temporal small model property**: For LTL over finite traces or with bounded time, small models exist. For the combined S5+LTL, the small model property holds via the filtration construction (already proved sorry-free in this project per ROADMAP.md).
3. **Semantic fingerprinting**: Evaluate each formula on all assignments over a small Kripke model. With 2 worlds, 2 time points, 3 atoms: 2^(3×2×2) = 4096 possible truth assignments per (world, time) pair, but the relevant space is the 2^12 = 4096 distinct truth-value vectors over the 12 atom-world-time combinations. Two formulas with identical truth-value vectors are semantically equivalent on this model.
4. **Completeness of fingerprint**: For S5 modal logic alone, 2-world models suffice for formulas up to modal depth 1. For modal depth d, approximately 2^d worlds suffice. For the temporal component, time points need to match the Until/Since nesting depth.

### Concrete Sizing for Bimodal Logic

For complexity-8 formulas with modal depth ≤ 2, temporal depth ≤ 2, 3 atoms:
- Worlds needed: ~4 (for modal depth 2 under S5)
- Time points needed: ~4 (for temporal depth 2)
- Atoms: 3
- Total atom assignments: 2^(3 × 4 × 4) = 2^48 — too large for exhaustive evaluation

**Practical alternative**: Use a small fixed model (2 worlds × 3 time points × 3 atoms = 18 Boolean variables, 2^18 = 262,144 assignments) and accept that the fingerprint is an **approximation** — formulas with different fingerprints are definitely semantically distinct, but formulas with the same fingerprint may or may not be equivalent.

### Recommended Approach
Implement semantic fingerprinting as a **post-processing deduplication** step, not during enumeration. Use a fixed small model (2w × 3t × 3a) for fast hashing. Hash each formula's truth vector. Keep one representative per hash bucket. Expected reduction: **30-50%** at c7+ based on the growing dedup ratio trend (2.7x at c4 → 4.0x at c7 → projected ~4.5x at c8).

**Confidence**: Medium (the fingerprint approach is sound but the model needs to be large enough to distinguish formulas. False positives — collapsing semantically distinct formulas — must be managed)

---

## 8. Recent Advances in Formal Logic Dataset Generation (2025-2026)

### Key Findings

1. **Goedel-Prover (2025)**: Open-source LLM achieving state-of-the-art automated theorem proving in Lean 4. Training data generated via:
   - Autoformalization: Natural language → Lean 4 statements via trained formalizers
   - Expert iteration: Iterative proof generation with formal verification
   - **Scaffolded data synthesis**: Generating synthetic tasks of increasing difficulty
   - Curated sub-problems from failed proof attempts

2. **Goedel-Prover-V2 (2025)**: Achieves 90.4% on MiniF2F at pass@32. Uses self-correction mode and scaled synthetic data.

3. **Saturation-Driven Dataset Generation (2025)**: For TPTP ecosystem:
   - Generates formulas through **saturation** — systematically deriving new formulas from axioms via inference rules
   - Controls difficulty by limiting inference steps, formula complexity, derivation depth
   - Eliminates factual errors by construction (purely symbolic)
   - Three challenges: entailment verification, premise selection, proof reconstruction

4. **Theorem Prover as Judge (2025)**: Uses formal verification to filter synthetic training data, ensuring correctness.

### Relevance to Task 283

The **saturation-driven approach** is directly relevant: instead of enumerating all formulas and checking properties, **derive** formulas from the axiom system. This guarantees:
- All generated formulas are related to the proof system (no wasted enumeration of uninteresting formulas)
- Difficulty is controlled by derivation depth
- No redundancy from syntactic variants (modulo the derivation path)

For bimodal logic with 41 BX axioms:
1. Start from the axiom schemas
2. Apply modus ponens, necessitation, temporal induction
3. Collect derived formulas at each depth
4. Use the derived formulas as training data

This **inverts the pipeline**: instead of enumerate → filter → label, it becomes derive → collect → label.

### Recommended Approach
Implement a **saturation-based generator** as an alternative to exhaustive enumeration for c9+. Use the 41 BX axioms as seeds, apply inference rules iteratively, and collect formulas at each derivation depth. This naturally produces formulas with known proofs and avoids the 90%+ waste rate of exhaustive enumeration.

**Confidence**: High (this is the state-of-the-art approach for generating training data for theorem provers as of 2025-2026)

---

## 9. Streaming and Incremental Output

### Key Findings

The current `enumerateWithProgress` function (FormulaEnumerator.lean:1363-1382) accumulates all formulas in a `List Formula` with per-level progress reporting. Key issues:

1. **No checkpointing**: A crash at 3.5 hours loses all work
2. **Full materialization**: All formulas must complete before downstream processing
3. **List append pattern**: `allFormulas := allFormulas ++ filtered` (line 1374) is O(n) per append

From streaming systems research:
- **Checkpointing with progress tracking**: Save state periodically so processing can resume from last checkpoint
- **Lazy evaluation / streaming**: Process items as they're generated, writing to disk incrementally
- **Stream fusion**: In Lean 4 and Rust, indexed stream fusion eliminates intermediate data structures (arXiv:2507.06456)

### Lean 4 Specifics

From the Lean 4 community discussion on performance-aware coding:
- `Array` with single-reference mutation provides O(1) amortized push
- Pre-allocate capacity to avoid reallocations
- Use `IO.monoMsNow` for timing
- Global `def` arrays incur copy-on-write on first modification

### Recommended Approach

Convert `enumerateWithProgress` to a **streaming architecture**:
1. Replace `List Formula` accumulation with `Array Formula` + in-place push
2. After each complexity level completes, **flush to disk** (append to JSONL file)
3. Maintain a checkpoint file with `(current_level, formulas_written, cache_state)`
4. On restart, read checkpoint and resume from the next level
5. Clear the in-memory array after each flush to bound memory usage

This enables:
- **Incremental delivery**: Downstream processing (labeling, export) can begin immediately on flushed data
- **Progress monitoring**: External tools can monitor the output file size and line count
- **Crash resilience**: At most one complexity level of work is lost
- **Memory bounding**: RSS is bounded by the largest single level, not the cumulative total

**Confidence**: High (standard streaming patterns, straightforward to implement in Lean 4)

---

## 10. Synthesis: Recommended Implementation Strategy

### Immediate (make c8 feasible in minutes)

| Priority | Strategy | Expected Impact | Effort | Source |
|----------|----------|----------------|--------|--------|
| 1 | Array-based accumulation | 5-20x speedup | 1-2h | Lean 4 docs, existing report |
| 2 | Streaming filter during cross-product | 4x memory reduction | 1h | SPOT pattern |
| 3 | Incremental output / checkpointing | Crash resilience, monitoring | 2h | Streaming systems |

### Short-term (reduce formula count 5-10x)

| Priority | Strategy | Expected Impact | Effort | Source |
|----------|----------|----------------|--------|--------|
| 4 | Alpha-canonical enumeration (first-occurrence filter) | 3-6x reduction | 2-3h | Burnside/McKay |
| 5 | LTL-inspired structural pruning | 10-20% reduction | 2h | Esparza-Sickert |
| 6 | Semantic fingerprint dedup (post-processing) | 30-50% additional reduction | 3-4h | Small model property |

### Medium-term (paradigm shift for c9+)

| Priority | Strategy | Expected Impact | Effort | Source |
|----------|----------|----------------|--------|--------|
| 7 | Saturation-driven generation from BX axioms | Eliminates 90%+ waste | 6-8h | Saturation-driven dataset gen (2025) |
| 8 | Parameterized grammar-based generator | Controlled difficulty | 4-6h | SynLogic, LTLBench |
| 9 | Priority-weighted sampling (SPOT-style) | Scalable to any complexity | 3-4h | SPOT randltl |

### Key Insight from Prior Art

The community consensus (2025-2026) is clear: **exhaustive enumeration does not scale for training data generation**. The state-of-the-art approaches are:

1. **Saturation-driven derivation** (generate from axioms, not from syntax)
2. **Parameterized generation with verifiers** (SynLogic pattern)
3. **Autoformalization + expert iteration** (Goedel-Prover pattern)

For task 283, the pragmatic path is:
- **c8**: Optimize the existing exhaustive approach (Array + streaming filter + alpha-canonical). This is feasible and preserves completeness.
- **c9+**: Switch to saturation-driven or grammar-based generation. Exhaustive enumeration is fundamentally infeasible at c9+ regardless of optimization.

---

## References

- [SPOT randltl documentation](https://spot.lre.epita.fr/randltl.html)
- [LTLBench: Towards Benchmarks for Evaluating Temporal Reasoning in LLMs (2024)](https://arxiv.org/abs/2407.05434)
- [SynLogic: Synthesizing Verifiable Reasoning Data at Scale (2025)](https://arxiv.org/html/2505.19641v1)
- [Efficient Normalization of Linear Temporal Logic (Esparza, Rubio, Sickert, JACM 2023)](https://arxiv.org/abs/2310.12613)
- [A Simple Rewrite System for LTL Normalization (2023)](https://arxiv.org/abs/2304.08872)
- [Burnside's Lemma (CP Algorithms)](https://cp-algorithms.com/combinatorics/burnside.html)
- [McKay: Isomorph-Free Exhaustive Generation](https://users.cecs.anu.edu.au/~bdm/papers/orderly.pdf)
- [Introduction to Canonical Deletion](https://computationalcombinatorics.wordpress.com/2012/08/13/canonical-deletion/)
- [AIGEN: Random Generation of Symbolic Transition Systems (CAV 2021)](https://link.springer.com/chapter/10.1007/978-3-030-81688-9_20)
- [Saturation-Driven Dataset Generation in TPTP Ecosystem (2025)](https://arxiv.org/pdf/2509.06809)
- [Goedel-Prover (2025)](https://arxiv.org/html/2502.07640v3)
- [Goedel-Prover-V2 (2025)](https://arxiv.org/abs/2508.03613)
- [Lean 4 Collection Types (DeepWiki)](https://deepwiki.com/leanprover/lean4/5.1-lists-arrays-and-vectors)
- [Lean 4 Performance-Aware Coding (Zulip)](https://leanprover-community.github.io/archive/stream/270676-lean4/topic/Performance.20aware.20coding.20in.20Lean.html)
- [Fast Collection Operations from Indexed Stream Fusion (2025)](https://arxiv.org/pdf/2507.06456)
- [Generating SAT Instances with Community Structure (AIJ 2017)](https://www.sciencedirect.com/science/article/pii/S0004370216300649)
- [S5 Modal Logic (Wikipedia)](https://en.wikipedia.org/wiki/S5_(modal_logic))
- [Small Model Property in Games and Automata (2021)](https://arxiv.org/pdf/2111.02998)
