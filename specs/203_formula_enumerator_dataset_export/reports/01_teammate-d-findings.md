# Teammate D (Horizons) Findings: Task #203

**Task**: 203 — Formula enumerator, decider labeling, and JSON dataset export
**Date**: 2026-05-29
**Angle**: Strategic alignment, creative approaches, publication opportunities

---

## Key Findings

### 1. Strategic Alignment: Task 203 Is Exactly Phase 0 — But Should Also Serve the Completeness Effort

**Confidence**: HIGH

Task 203's scope aligns precisely with Phase 0 from the task 201 decomposition plan. However, the current scoping misses an important synergy: the formula enumerator can also serve the completeness proof effort (task 202).

**Specific opportunities**:
- The benchmark should include formulas drawn from the actual completeness proof — instances of the 42 BX axiom constructors, composed formulas that exercise Until/Since interplay, and known edge cases from the `ChronicleToCountermodel.lean` path
- Testing the decision procedure at scale provides a regression test for the decidability module — if `decide` returns `timeout` on formulas it should handle, that reveals bugs
- The held-out evaluation benchmark can double as a certification suite for the completeness proof: after `bx_completeness` is sorry-free (task 202), the benchmark formulas should all return `valid` with proof certificates. This creates a cross-validation between the syntactic proof system and the semantic decision procedure

**Strategic recommendation**: Add a "known theorems" partition to the benchmark — formulas that are proven in the codebase. This validates both the enumerator's diversity AND the decision procedure's correctness on real use cases.

### 2. The Saturation-Driven Dataset Generation Pattern Is Directly Applicable

**Confidence**: HIGH

A September 2025 paper, "Saturation-Driven Dataset Generation for LLM Mathematical Reasoning in the TPTP Ecosystem" (arXiv:2509.06809), describes a framework strikingly similar to what task 203 needs:

| Feature | TPTP Paper | Task 203 |
|---------|-----------|----------|
| Generation method | E-prover saturation over axiom sets | Bounded formula enumeration + tableau decision |
| Validity guarantee | Theorem derivation in FOL | `DecisionResult.valid` / `DecisionResult.invalid` |
| Difficulty control | Proof depth + perturbation count | Modal/temporal depth + formula complexity |
| Interestingness filter | AGInTRater (complexity, surprisingness, usefulness) | Feasibility gate: >80% non-trivially-propositional |
| Output tasks | Entailment verification, premise selection, proof reconstruction | Value estimation, policy training, proof search |

**Key lesson**: The TPTP paper's three-task output structure (entailment verification, premise selection, proof reconstruction) maps naturally to the bimodal logic domain:
1. **Entailment verification** → "Is this formula valid?" (binary classification, the decider's job)
2. **Premise selection** → "Which axiom constructors are relevant?" (subset selection from the 42 BX axioms)
3. **Proof reconstruction** → "Given the formula and axioms, produce a proof" (the full proof search problem)

Structuring the dataset to support all three task types from day one makes the benchmark far more useful for the downstream phases.

### 3. Data Schema Must Support Multiple Representation Formats Simultaneously

**Confidence**: HIGH

The downstream pipeline needs the data in multiple representations for different model architectures:

| Consumer | Representation Needed | Phase |
|----------|----------------------|-------|
| Value estimator (Phase 1) | `PatternKey` features (5 numeric fields) | Immediate |
| GNN (Phase 1-2) | Formula AST as adjacency list + node types | Near-term |
| Transformer (Phase 2) | Tokenized string representation (S-expression or custom) | Medium-term |
| HuggingFace Datasets | JSON/JSONL with standardized metadata | Publication |
| Proof trace consumer | Linearized derivation tree (tactic sequence) | Phase 2 |

**Recommendation**: Export a "canonical" JSON where each record contains the formula in MULTIPLE encodings:
```json
{
  "id": "bmlogic_00001",
  "formula_sexp": "(imp (box (atom p)) (atom p))",
  "formula_tokens": ["imp", "box", "atom", "p", "atom", "p"],
  "formula_ast": {"type": "imp", "children": [{"type": "box", ...}, {"type": "atom", ...}]},
  "pattern_key": {"modal_depth": 1, "temporal_depth": 0, "imp_count": 1, "complexity": 4, "top_operator": "Implication"},
  "label": "valid",
  "frame_class": "Base",
  "decision_result": { ... },
  "difficulty_metrics": { ... }
}
```

This is standard practice in ML dataset papers — LeanDojo exports both structured proof data and flat text representations. The Lean side should export the canonical representation; downstream Python tools can generate additional encodings.

### 4. Temporal Duality and Contrastive Pairs Are High-Value, Low-Cost Data Augmentation

**Confidence**: MEDIUM-HIGH

The existing `swap_temporal` involution in `Formula.lean` automatically doubles the dataset: for every formula φ, its temporal dual swap_temporal(φ) preserves validity in the Base frame class. This is a free 2x multiplier that task 201's research explicitly called out.

**Contrastive pairs** are even more valuable. For each valid formula:
1. **Atom substitution**: Replace one atom with ⊥ — often invalidates the formula
2. **Operator weakening**: Replace □ with ◇ (or G with F) — changes validity
3. **Subformula deletion**: Remove an antecedent from an implication chain
4. **Depth reduction**: Strip one layer of modal/temporal nesting

Each mutation can be checked by the decision procedure, producing (valid_formula, invalid_mutation, countermodel) triples. This creates the contrastive training signal that task 201 round 2 identified as novel ("Learning to Disprove" uses syntactic mutation, but this approach pairs mutations with verified countermodels).

**Cost**: ~200 LOC in Lean for a `FormulaMutator` module, plus running the decision procedure on each mutation. Since `decide` is already being called on the original formulas, the marginal cost is just the mutations.

### 5. The Benchmark Itself Is a Publishable Artifact — "BMLogic-Bench"

**Confidence**: MEDIUM-HIGH

The ML-for-theorem-proving community has no benchmark for decidable non-classical logics. Existing benchmarks:

| Benchmark | Domain | Scale | Decidable? |
|-----------|--------|-------|------------|
| miniF2F | Olympiad math (Lean/Isabelle/Metamath) | 488 | No |
| ProofNet | Undergraduate math (Lean) | ~370 | No |
| PISA | Isabelle/HOL | ~180K | No |
| HolStep | HOL Light | ~2M | No |
| PutnamBench | Putnam competition | ~1697 | No |
| **BMLogic-Bench** | **Bimodal logic TM** | **10K-50K** | **Yes** |

The decisive advantage: because TM is decidable, every formula in the benchmark has a verified ground-truth label AND a proof certificate or countermodel. No other benchmark can claim this. This makes the benchmark suitable for:
- Training neural provers (standard use)
- Evaluating prover correctness (the oracle is available)
- Studying the gap between decidability and efficient proof search (novel research direction)

**Publication target**: NeurIPS 2026 Datasets and Benchmarks track or AITP 2026. Dataset papers are highly cited (miniF2F has 300+ citations) and establish the project in the community.

**HuggingFace compatibility**: The schema should follow HuggingFace Datasets conventions from the start — JSONL format, a `dataset_info.json` metadata file, and train/test/validation splits. The `proof-pile` dataset (Hoskinson Center) and `FineLeanCorpus` (M-A-P) show the standard patterns. This enables one-line loading: `datasets.load_dataset("logos-labs/bmlogic-bench")`.

### 6. Goedel-Prover-V2's Scaffolded Synthesis Pattern Applies to Proof Trace Generation

**Confidence**: MEDIUM

Goedel-Prover-V2 (July 2025, 88.1% on miniF2F) introduced "scaffolded data synthesis" — generating training data of increasing difficulty. Their approach:
1. Failed proof attempts → extract unsolved subgoals → new training problems
2. Negations of theorems → teach the model to recognize invalid statements
3. Simpler subproblems → build up from easy to hard

For task 203, the analogous approach:
1. Run `decide` on enumerated formulas → extract proof traces for valid ones
2. The negation of each valid formula is invalid — include it with its countermodel
3. Control difficulty via depth bounds (d_box, d_G, d_U) — the curriculum is built-in

**Key insight**: The three frame classes (Base, Dense, Discrete) provide an additional curriculum axis that Goedel-Prover's approach doesn't have. A formula valid in Base is also valid in Dense and Discrete (by monotonicity of frame classes). A formula valid in Discrete but not Base tests the neural model's understanding of frame-class-specific reasoning.

### 7. Risk of Over-Engineering: Start Small, Iterate Fast

**Confidence**: HIGH

The task description targets 10K-50K formulas, but the minimum viable dataset for Phase 1 (value estimator) is much smaller:
- LeanProgress (the reference for Phase 1) used ~80K proof trajectories but these are tactic-step-level, not formula-level
- A value estimator over `PatternKey` features has 5 input dimensions — even 1K-2K labeled formulas might suffice for initial training
- The Nazrin GNN (1.5M params) trained on comparably small datasets

**Recommendation**: Ship the enumerator with a configurable depth bound. The default run produces ~2K-5K formulas at low depth (fast). A deep run produces 10K-50K (overnight). The benchmark (500-1K held-out) comes from the deep run. This avoids blocking on large-scale enumeration.

**Concrete phasing**:
1. Week 1: `FormulaEnumerator.lean` — bounded generation, deduplication, diversity check
2. Week 2: `DatasetGenerator.lean` — run `decide`, extract labels + `PatternKey` features + proof height
3. Week 3: JSON export + temporal duality augmentation + train/test split
4. Week 4: Contrastive pair generation + countermodel export + benchmark curation

---

## Recommended Approach

### Core Recommendation

Build the dataset pipeline with three architectural principles:

1. **Multi-representation from day one**: Export formulas in S-expression, token list, AST, and `PatternKey` formats simultaneously. The marginal cost is trivial; the downstream time savings are large.

2. **Curriculum-aware structure**: Tag every formula with its difficulty tier (based on depth, complexity, and decision time) and frame class validity. This enables curriculum learning in Phase 1 without re-running the pipeline.

3. **Contrastive pairs as a first-class output**: For each valid formula, generate 2-3 mutations and check them. The (valid, invalid, countermodel) triples are the project's unique differentiator and enable the dual-verification paper from task 201 round 2.

### Schema Design

Recommended canonical JSON record:

```json
{
  "id": "bmlogic_00001",
  "split": "train",
  "formula": {
    "sexp": "(imp (box (atom p)) (atom p))",
    "tokens": ["imp", "box", "atom", "p", "atom", "p"],
    "ast": { "type": "imp", "children": [...] }
  },
  "pattern_key": {
    "modal_depth": 1,
    "temporal_depth": 0,
    "imp_count": 1,
    "complexity": 4,
    "top_operator": "Implication"
  },
  "decision": {
    "label": "valid",
    "proof_height": 3,
    "decision_time_ms": 12,
    "frame_class": "Base"
  },
  "proof_trace": {
    "rules_applied": ["ax_T", "modus_ponens"],
    "derivation_height": 3,
    "search_nodes_expanded": 7
  },
  "countermodel": null,
  "augmentation": {
    "temporal_dual_id": "bmlogic_00002",
    "contrastive_pairs": ["bmlogic_00003", "bmlogic_00004"]
  },
  "difficulty": {
    "tier": "easy",
    "is_propositional": false,
    "depth_class": "shallow"
  }
}
```

### Publication Strategy

1. **Immediate**: Build the dataset as task 203 specifies. Quality over quantity — 5K well-curated formulas beat 50K noisy ones.
2. **Short-term**: Write up "BMLogic-Bench" as a dataset paper for NeurIPS 2026 Datasets track (submission ~June 2026) or AITP 2026.
3. **Medium-term**: After Phase 1 results, write the neural guidance paper for TABLEAUX/CADE using the benchmark results.
4. **Long-term**: Release on HuggingFace with documentation, enabling reproducible research.

---

## Evidence/Examples

### Published Benchmark Comparisons

| Benchmark | Year | Formulas | Labels | Oracle? | Citation count |
|-----------|------|----------|--------|---------|----------------|
| miniF2F | 2021 | 488 | valid/invalid | No | 300+ |
| HolStep | 2017 | 2M+ | useful/not | No | 200+ |
| ProofNet | 2023 | 370 | valid/invalid | No | 50+ |
| TPTP-Sat | 2025 | ~100K | valid (by construction) | Yes | New |
| **BMLogic-Bench** | **2026** | **5K-50K** | **valid/invalid/timeout** | **Yes (decidable)** | **Proposed** |

### Key References

- [miniF2F](https://arxiv.org/pdf/2109.00110) — Cross-system benchmark (488 Olympiad problems)
- [Saturation-Driven Dataset Generation](https://arxiv.org/abs/2509.06809) — TPTP-based enumeration with difficulty control and interestingness filters
- [Goedel-Prover-V2](https://arxiv.org/abs/2508.03613) — Scaffolded data synthesis (negations, subgoals, difficulty progression)
- [LeanDojo](https://leandojo.org/) — JSON-based export with structured theorem/tactic/premise data
- [proof-pile](https://huggingface.co/datasets/hoskinson-center/proof-pile) — HuggingFace dataset format reference
- [FineLeanCorpus](https://huggingface.co/datasets/m-a-p/FineLeanCorpus) — Lean 4 dataset on HuggingFace
- [HolStep](https://arxiv.org/pdf/1703.00426) — Large-scale dataset structure for HOL Light
- [Learning Representations Through Contrastive Neural Model Checking](https://arxiv.org/html/2510.01853v2) — Contrastive learning for formal verification

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| Strategic alignment (completeness + neural search) | HIGH |
| Saturation-driven pattern applicability | HIGH |
| Multi-representation schema necessity | HIGH |
| Temporal duality augmentation value | MEDIUM-HIGH |
| Contrastive pair generation value | MEDIUM-HIGH |
| Publication opportunity (BMLogic-Bench) | MEDIUM-HIGH |
| Goedel-Prover scaffolding applicability | MEDIUM |
| Start-small iteration strategy | HIGH |

**Overall confidence**: HIGH — the strategic direction is clear and well-supported by published precedent. The main uncertainty is around the contrastive pair approach (novel, no direct precedent in modal logic) and the publication timeline (competitive venue acceptance).
