# Teammate B Findings: Alternative Approaches and Prior Art

**Task**: 203 — Formula Enumerator, Decider Labeling, and JSON Dataset Export
**Angle**: Alternative patterns, prior art, best practices
**Date**: 2026-05-29

---

## Key Findings

### 1. Prior Art in Dataset Generation for ML Theorem Proving

Five major approaches exist in the literature, each offering lessons for Task 203:

**A. LeanDojo Benchmark (Extraction-Based)**
LeanDojo traces existing Mathlib4 proofs to extract (theorem, proof state, tactic) tuples. The Lean 4 benchmark comprises ~1,659 test theorems. The extraction is done via a Python tracing library that instruments the Lean elaborator. **Lesson for Task 203**: LeanDojo extracts from existing proofs; Task 203 needs to *generate* novel formulas, so this approach is complementary, not directly applicable. However, the data schema design (theorem + tactic steps + metadata) is a useful reference.

**B. Alchemy (Mutation-Based, 2024)**
The Alchemy framework synthesizes ~6.3M new theorems from Mathlib's 110k by symbolic mutation. It uses two operators: `rw` (rewriting with equivalent forms) and `apply` (leveraging implication). Each candidate is mutated, then verified in Lean. This achieved a 25-44x corpus expansion. **Lesson for Task 203**: Mutation is powerful for generating *related but distinct* formulas. For the TM bimodal logic, the analogous approach would be: take proven theorems, substitute subformulas systematically, and re-run the decision procedure. This could complement exhaustive enumeration for diversity.

**C. DeepSeek-Prover (Autoformalization + Filtering)**
DeepSeek-Prover generates Lean 4 formal statements from natural language competition problems, then filters via a model scorer. V1 curated 712,073 high-quality statements; V2 expanded to 8M statement-proof pairs via expert iteration. **Lesson for Task 203**: The filtering stage is critical — raw generation produces many trivial/duplicate items. The feasibility gate ("not >80% trivially propositional") should be checked early and continuously during generation.

**D. LTLBench (Graph-Based Temporal Logic, 2024)**
LTLBench generates LTL formulas by: (1) creating random directed graph structures, (2) composing LTL operators over node events with controlled depth, (3) labeling via NuSMV model checker. It controls complexity via two parameters: number of events (n) and number of operators (m). **Lesson for Task 203**: This is the closest prior art for temporal logic dataset generation. The graph-first approach (generate a model, then derive formulas about it) is an alternative to formula-first enumeration. For TM bimodal logic, generating task-frame models first, then checking which formulas hold, could produce more diverse invalid examples.

**E. Random Modal CNF Method (Patel-Schneider et al., JAIR 2011)**
The standard method for benchmarking modal decision procedures. Generates random CNF formulas parameterized by: number of propositional variables (N), number of modalities (M), modal subformulae per clause (K, L), modal depth (D), and satisfiability probability (P). This generalized the earlier TANCS/LWB benchmark generators. **Lesson for Task 203**: The CNF-based approach produces formulas clustered near the satisfiability phase transition — exactly where decision procedures are stressed. However, it generates CNF-specific structure that may not represent naturally occurring TM bimodal formulas. Consider implementing a variant as one generation mode alongside the exhaustive enumerator.

### 2. Alternative Enumeration Strategies (Ranked)

**Strategy A: Exhaustive Bounded Enumeration (Recommended Primary)**
Generate all formulas up to a given complexity/depth bound. This is the most natural approach given the inductive structure of TM's `Formula` type (6 constructors). The codebase already has `complexity`, `modalDepth`, `temporalDepth` measures that can bound generation.

Pros: Complete coverage within bounds; reproducible; deterministic.
Cons: Exponential blowup — depth-3 modal+temporal over 3 atoms could produce millions of formulas. Must use deduplication (modulo alpha-equivalence for atoms).

**Strategy B: Grammar-Based Random Sampling**
Use the Formula BNF as a probabilistic context-free grammar. Assign production probabilities to control the distribution (e.g., P(box) = 0.15, P(untl) = 0.15, P(snce) = 0.15, P(imp) = 0.3, P(atom) = 0.15, P(bot) = 0.1). Recursively sample with a depth budget.

Pros: Scales to larger formulas without combinatorial explosion; tunable distribution.
Cons: No completeness guarantee; harder to reproduce exact sets; risk of distribution skew.

**Strategy C: Mutation-Based (Alchemy-Inspired)**
Take the 42 BX axiom schemas and known theorems, apply systematic mutations: substitute subformulas, negate subgoals, swap temporal operators (via `swap_temporal`), change frame classes.

Pros: Generates formulas "near" known interesting theorems; excellent for diversity.
Cons: Requires a seed corpus; doesn't explore formula space independently.

**Strategy D: Template-Based Parameterized Generation**
Define formula templates like `□(p → G(q → U(r, s)))` with parameterized slots, then systematically vary atoms and nesting. Use the existing `GoalCategory` and `PatternKey` to ensure coverage across categories.

Pros: Guaranteed coverage of interesting structural patterns.
Cons: Templates must be manually designed; limited to anticipated patterns.

**Recommended Composite Strategy**: Primary = exhaustive bounded enumeration (Strategy A) for small depths (1-2 modal, 1-2 temporal) to build the core dataset. Supplement with grammar-based random sampling (Strategy B) for larger formulas. Add mutation-based generation (Strategy C) for near-boundary formulas. This achieves the diversity gate while maintaining reproducibility.

### 3. JSON Export Approaches from Lean 4

**Approach 1: Built-in `Lean.Json` (Recommended)**
Lean 4 has native JSON support via `Lean.Data.Json`:
- `ToJson` / `FromJson` typeclasses with `deriving` support for structures
- `Json` type with constructors for null, bool, num, str, arr, obj
- `IO.FS.writeFile` for file output

This is the most idiomatic approach. Key types:
```lean
class ToJson (α : Type u) where
  toJson : α → Json

class FromJson (α : Type u) where
  fromJson? : Json → Except String α
```

Structures can use `deriving ToJson, FromJson` for automatic instances. For the `Formula` inductive, a manual `ToJson` instance would serialize to a tagged JSON object (e.g., `{"tag": "imp", "left": ..., "right": ...}`).

**Approach 2: Manual String Building**
Build JSON strings directly with `String.intercalate` and format functions. Simpler but fragile (escaping issues, no validation).

**Approach 3: JSONL via Streaming**
Write one JSON object per line using `IO.FS.Handle.putStrLn` in a loop. Avoids loading the entire dataset into memory. This is the ML-standard format.

**Approach 4: Lake Executable Script**
Define an executable target in `lakefile.lean` that runs the generation pipeline:
```lean
-- In lakefile.lean
lean_exe dataset_gen where
  root := `DatasetGen
```
This creates a standalone binary that generates the dataset on demand.

**Recommended**: Use `Lean.Json` with `ToJson` instances for type safety + JSONL format for output + Lake executable for orchestration. This gives idiomatic Lean code, ML-standard output, and a clean build/run pipeline.

### 4. Data Schema Designs

**Option A: Flat JSONL (Recommended)**
One JSON object per line, one file per frame class:
```jsonl
{"id":"base_00001","formula":"□(p → G(q))","ast":{"tag":"box","child":{"tag":"imp","left":{"tag":"atom","name":"p"},"right":{"tag":"all_future","child":{"tag":"atom","name":"q"}}}},"frame_class":"Base","label":"valid","proof_height":4,"modal_depth":1,"temporal_depth":1,"complexity":7,"decision_time_ms":12}
{"id":"base_00002","formula":"U(p,q) → □p","ast":{...},"frame_class":"Base","label":"invalid","countermodel":{"true_atoms":["q"],"false_atoms":["p"]},"modal_depth":1,"temporal_depth":1,"complexity":5,"decision_time_ms":8}
```

Pros: Standard ML format; streamable; works with HuggingFace datasets, PyTorch DataLoader, pandas.
Cons: Redundant field names per line (minor overhead).

**Option B: Split Files**
- `formulas.jsonl` — formula ASTs and metadata
- `labels.jsonl` — decision results indexed by formula ID
- `proofs.jsonl` — proof traces for valid formulas
- `countermodels.jsonl` — countermodel data for invalid formulas

Pros: Allows independent loading of expensive data.
Cons: More complex; join logic needed downstream.

**Option C: HuggingFace-Compatible Parquet**
Export in Parquet columnar format for direct upload to HuggingFace Hub.

Pros: Best for public dataset distribution.
Cons: Requires Parquet library (not available in Lean); would need a Python post-processing step.

**Recommended**: Option A (flat JSONL) as the primary export from Lean. If HuggingFace distribution is desired, add a simple Python script that converts JSONL → Parquet/HuggingFace datasets format. This keeps the Lean boundary clean (JSON out) while enabling ML ecosystem integration.

### 5. Schema Field Recommendations

Based on prior art survey, the following fields should be included per formula:

| Field | Type | Purpose | Source |
|-------|------|---------|--------|
| `id` | string | Unique identifier (frame_class + sequence) | Infrastructure |
| `formula_str` | string | Human-readable formula string | `Formula.toString` or custom printer |
| `ast` | object | Full AST as nested JSON | `ToJson Formula` |
| `frame_class` | string | "Base" / "Dense" / "Discrete" | Parameter |
| `label` | string | "valid" / "invalid" / "timeout" | `DecisionResult` |
| `proof_height` | nat? | DerivationTree height (if valid) | `proof.height` |
| `proof_trace` | array? | Sequence of rule applications (if valid) | Proof extraction |
| `countermodel` | object? | True/false atoms (if invalid) | `SimpleCountermodel` |
| `modal_depth` | nat | Formula modal depth | `Formula.modalDepth` |
| `temporal_depth` | nat | Formula temporal depth | `Formula.temporalDepth` |
| `complexity` | nat | Formula complexity measure | `Formula.complexity` |
| `imp_count` | nat | Implication count | `Formula.countImplications` |
| `top_operator` | string | GoalCategory name | `goalCategory` |
| `decision_time_ms` | nat | Wall-clock time for decision | IO timing |
| `search_depth` | nat | Depth used by decision procedure | Parameter |
| `tableau_fuel` | nat | Fuel used by tableau | Parameter |
| `split` | string | "train" / "val" / "test" | Post-generation assignment |

### 6. Existing Lean 4 Dataset Infrastructure

**LeanUniverse (Facebook Research)**: Python package for creating comprehensive datasets from Lean 4 GitHub repos. Ensures mathlib version consistency. Licensed CC-BY-NC 4.0. Not directly applicable (extracts from repos, doesn't generate novel formulas), but demonstrates the ecosystem expectation: Lean generates data → Python consumes.

**LeanDojo-v2**: End-to-end framework combining tracing, dataset management, fine-tuning. Supports local Lean 4 projects via `DynamicDatabase`. Can trace proofs from the BimodalLogic project, extracting (state, tactic) pairs as supplementary training data.

**TheoremLlama**: Uses curriculum learning for Lean 4 proof generation. Relevant approach: start with simpler formulas, increase difficulty. Aligns with the task's bounded-depth enumeration strategy.

---

## Recommended Approach

**Primary: Exhaustive + Random Hybrid with Lean.Json JSONL Export**

1. **Enumeration**: Implement `enumerateFormulas : Nat → Nat → Nat → List Formula` that exhaustively generates all formulas up to given modal depth, temporal depth, and atom count. For larger sizes, switch to grammar-based random sampling with a seed parameter for reproducibility.

2. **Labeling**: Use the existing `decide` / `decideAuto` functions. Batch with `decideBatch` for statistics. Record timing via `IO.monoMsNow`.

3. **Export**: Implement `ToJson` instances for `Formula`, `DecisionResult`, `SimpleCountermodel`, `PatternKey`. Write JSONL via `IO.FS.Handle.putStrLn` in a streaming loop. Create a Lake executable target.

4. **Schema**: Use the flat JSONL schema from Option A above with the full field set from the recommendations table.

5. **Diversity Control**: After generation, compute the distribution over `GoalCategory` and `PatternKey` dimensions. If >80% propositional (no box/untl/snce), increase the minimum modal+temporal depth bound or adjust random sampling weights.

6. **Benchmark Split**: Use hash-based deterministic splitting (hash formula string → bucket) for reproducible train/val/test splits (80/10/10).

---

## Evidence/Examples

- **Alchemy** (arXiv:2410.15748): 25-44x corpus expansion via symbolic mutation on Mathlib theorems, verifying each in Lean 4
- **LTLBench** (arXiv:2407.05434): Controlled-complexity temporal logic formula generation + NuSMV labeling for 2,000 problems
- **Patel-Schneider et al.** (JAIR 2011): Random CNF modal formula generation with phase-transition control for benchmarking decision procedures
- **LeanDojo v2**: Python-Lean 4 tracing infrastructure extracting (state, tactic) pairs from proof traces
- **LeanUniverse** (Facebook Research): Lean 4 dataset standardization library ensuring mathlib version consistency
- **DeepSeek-Prover V1/V2**: 712K-8M synthetic formal statements via autoformalization + filtering + expert iteration
- **Lean.Json API**: Built-in `ToJson`/`FromJson` typeclasses with `deriving` support, `Json` type constructors, used throughout Lean's own LSP and tooling

---

## Confidence Level

**High** for the overall approach (JSONL export, hybrid enumeration, `Lean.Json` usage). The prior art clearly converges on these patterns.

**Medium** for the specific enumeration parameters (depth bounds, sampling weights, diversity thresholds). These will need empirical tuning during implementation.

**Medium** for mutation-based generation as a supplement. While Alchemy proves it works at scale in Mathlib, the TM bimodal domain has a much smaller seed corpus (42 axioms + dozens of theorems), so the expansion factor may be lower.
