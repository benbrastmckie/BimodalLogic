# Research Report: Task #203

**Task**: 203 — Build formula enumerator, decider labeling, and JSON dataset export
**Date**: 2026-05-29
**Mode**: Team Research (4 teammates)
**Session**: sess_1780075776_0c2472

---

## Summary

Four researchers investigated the design and implementation of the formula enumeration, decider labeling, and JSON export pipeline for task 203. The team converged on a **hybrid enumeration strategy** (exhaustive at low complexity, sampling above), a **compiled Lake executable** with streaming JSONL output using Lean 4's built-in `ToJson` deriving, and a **simplified ProofTrace type** instead of full DerivationTree serialization. The critic identified several critical constraints: exhaustive enumeration is infeasible above complexity ~7 (~60K formulas), the `decide` function only supports the Base frame class, and `SimpleCountermodel` provides only atom-level valuations. The horizons researcher identified a strong publication opportunity ("BMLogic-Bench") and recommended multi-representation export and contrastive pair generation as high-value, low-cost additions.

**Recommended path**: Compiled Lean executable producing streaming JSONL, with configurable depth bounds. Default run: 2K-5K formulas (fast, for Phase 1 iteration). Deep run: 10K-50K formulas (overnight, for benchmark publication). Include temporal duality augmentation and contrastive mutation pairs.

---

## Key Findings

### 1. Exhaustive Enumeration Is Infeasible Above Complexity ~7 — Sampling Required

**Confidence**: HIGH (Teammate C, confirmed by A and B)

The formula space grows super-exponentially. With 3 atoms and 6 primitive constructors:

| Max Complexity | Total Formulas | Feasible? |
|:-:|:-:|:-:|
| 5 | ~1,652 | Yes (trivial) |
| 7 | ~60,460 | Yes (~10 min to decide all) |
| 9 | ~2,554,596 | Marginal (~71 hours) |
| 11 | ~117,615,644 | No |

**Critical detail**: Depth-bounded enumeration is also unbounded because `imp` doesn't increase modal/temporal depth — it can nest arbitrarily within any fixed depth bound. The central design decision is the **sampling strategy**, not enumeration bounds.

**Resolution**: Exhaustive enumeration at complexity ≤ 7 (produces ~60K formulas, all decidable in reasonable time). Above complexity 7, use grammar-based random sampling with configurable production weights and a depth budget. This hybrid approach provides complete coverage at small scales and controlled diversity at larger scales.

### 2. Existing Codebase Infrastructure Covers Most Needs

**Confidence**: HIGH (Teammate A, confirmed by all)

The codebase already provides:
- `Formula.complexity` — structural size measure
- `Formula.modalDepth` / `Formula.temporalDepth` — depth measures
- `Formula.countImplications` — branching factor
- `PatternKey.fromFormula` — extracts all structural features in one call
- `goalCategory` — formula classification
- `decide` / `decideAuto` — decision procedure with auto-scaling fuel
- `Formula.swap_temporal` — temporal duality involution
- `SubformulaClosure/NestingDepth.lean` — F/P-nesting depth computation

New code required: ~700-1000 lines across 3-4 files. The primary engineering is JSON serialization boilerplate (~200-400 lines of `ToJson` instances, since no existing code imports `Lean.Data.Json`) and the enumeration/sampling logic.

### 3. The `decide` Function Only Supports Base Frame Class

**Confidence**: HIGH (Teammate C — code-inspected)

`decide` returns `⊢ φ` which is notation for `DerivationTree FrameClass.Base [] φ`. The proof extraction path explicitly checks `ax.minFrameClass ≤ FrameClass.Base`. Consequences:

- Dense-only axioms (`density`, `dense_indicator`) are never used in extracted proofs
- Discrete-only axioms (`prior_UZ`, `prior_SZ`, `z1`) are never used
- Formulas valid in Dense/Discrete but not Base are labeled `invalid` (correct but incomplete)

**Resolution**: Label the dataset as Base-class only. Add a `frame_class: "Base"` field to every record. Document prominently that Dense/Discrete labeling requires future work on the decision procedure. This is acceptable for Phase 1 (value estimator) since Base is the most general frame class.

### 4. SimpleCountermodel Is Atom-Level Only — Asymmetric Training Signal

**Confidence**: HIGH (Teammate C — code-inspected)

`SimpleCountermodel` contains only `trueAtoms`, `falseAtoms`, and `formula` — a propositional valuation, not a modal/temporal countermodel. No world structure, time structure, or task relations are captured. This means:

- Valid formulas get rich proof trees (derivation height, axioms used, rule sequences)
- Invalid formulas get only which atoms are true/false at the initial world/time

**Resolution**: Accept this asymmetry for now. The atom-level countermodel is sufficient for basic negative signal (binary classification). Richer countermodels (Tier 2/3 from task 201 round 2) are future work. The task should explicitly call out this limitation in the dataset documentation.

### 5. Full DerivationTree Serialization Is Impractical — Use Simplified ProofTrace

**Confidence**: HIGH (Teammates A + C — convergent recommendation)

`DerivationTree` is a dependent type containing Lean propositions (`h : φ ∈ Γ`, `h_fc : ...`), 42 axiom constructors, and nested recursive trees. Full serialization is impractical.

**Resolution**: Create a simplified `ProofTrace` type:
```lean
structure ProofTrace where
  height : Nat
  axioms_used : List String     -- axiom constructor names (e.g., "ax_T", "box_imp")
  rules_applied : List String   -- rule names in order (e.g., "modus_ponens", "necessitation")
  pattern_key : PatternKeyExport  -- PatternKey numeric features
```

This captures the ML-relevant information (what rules were used, in what order, how deep) without attempting to serialize Lean proof terms.

### 6. Architecture Must Use Compiled Executable with Streaming Output

**Confidence**: HIGH (Teammates A + B + C — unanimous)

Lean 4's `#eval` is 10-100x slower than compiled native code for custom recursive computations. The pipeline must:
- Define a `main : IO Unit` entry point
- Use `lake exe dataset_generator` to build a native binary
- Stream JSONL output via `IO.FS.Handle.putStrLn` (one record per line)
- Process formulas one-at-a-time, not accumulating all results in memory

For 50K formulas with average ~500 bytes per record, the output is ~10-25MB — manageable in JSONL format.

### 7. Prior Art Supports the Hybrid Approach

**Confidence**: HIGH (Teammate B — literature survey)

Five relevant prior systems:

| System | Method | Scale | Lesson |
|--------|--------|-------|--------|
| **LeanDojo** | Extraction from existing proofs | ~1,659 test theorems | Schema design reference |
| **Alchemy** | Mutation-based synthesis | 6.3M from 110K seed | Mutation expands corpus 25-44x |
| **DeepSeek-Prover** | Autoformalization + filtering | 712K-8M | Early filtering is critical |
| **LTLBench** | Graph-based temporal formula gen | 2,000 problems | Closest temporal logic prior art |
| **Random Modal CNF** (JAIR 2011) | Parameterized CNF generation | Variable | Phase-transition controls difficulty |

The recommended composite strategy (exhaustive at low depth + grammar-based random sampling + mutation-based supplementation) is well-supported by this literature.

### 8. Temporal Duality and Contrastive Pairs Are Free/Cheap Data Augmentation

**Confidence**: MEDIUM-HIGH (Teammates A + D)

- **Temporal duality**: `swap_temporal` maps every theorem to its dual (which is also valid in Base). Free 2x multiplier on the valid portion of the dataset.
- **Contrastive pairs**: For each valid formula, generate 2-3 mutations (atom→⊥ substitution, □→◇ weakening, subformula deletion). Run `decide` on each mutation. Produces (valid, invalid, countermodel) triples — the dual-verification signal from task 201 round 2.
- **Cost**: ~200 LOC for a `FormulaMutator` module, plus marginal `decide` calls.

### 9. BMLogic-Bench Publication Opportunity

**Confidence**: MEDIUM-HIGH (Teammate D)

No benchmark exists for decidable non-classical logics. Existing ML-for-theorem-proving benchmarks (miniF2F, ProofNet, HolStep, PutnamBench) are all undecidable. A decidable benchmark with verified ground-truth labels AND proof certificates/countermodels is novel.

**Publication target**: NeurIPS 2026 Datasets and Benchmarks track or AITP 2026.
**HuggingFace release**: `logos-labs/bmlogic-bench` with train/val/test splits and `dataset_info.json`.

### 10. The >80% Non-Propositional Feasibility Gate Is Trivially Easy

**Confidence**: HIGH (Teammate C)

The propositional fraction drops below 10% at complexity ≥ 5. The gate passes trivially for any reasonable enumeration. The **real** diversity concern is formulas that are syntactically modal/temporal but semantically trivial (e.g., `□(p → p)` contains a box but is propositionally valid).

**Resolution**: Augment the feasibility gate with:
- **< 20% timeout rate** (decision procedure completes on ≥80% of formulas)
- **≥ 30% valid formulas** in the labeled dataset (avoid skew toward invalidity)
- **Structural diversity score**: entropy over `PatternKey` dimensions

---

## Synthesis

### Conflicts Resolved

1. **Exhaustive vs. sampling enumeration**:
   - Teammate A: exhaustive bounded recursion is "straightforward"
   - Teammate C: exhaustive is infeasible above complexity ~7 (60K→2.5M→117M)
   - Teammate B: hybrid of exhaustive + grammar-based random
   - **Resolution**: C is right on the numbers. Use exhaustive at complexity ≤ 7 as the core corpus, supplement with stratified random sampling at higher complexity. The hybrid approach from B is the correct synthesis.

2. **Schema simplicity vs. multi-representation**:
   - Teammate A: flat JSONL with basic fields (formula string, label, metrics)
   - Teammate D: multi-representation (S-expression, token list, AST, PatternKey simultaneously)
   - Teammate B: flat JSONL with 17 comprehensive fields
   - **Resolution**: The Lean side exports a canonical representation (formula string, AST, PatternKey, label, proof trace, countermodel, metrics). A thin Python post-processor can generate additional representations (token lists, custom encodings). This keeps the Lean boundary clean while supporting downstream diversity.

3. **Feasibility gate criteria**:
   - Task description: ">80% non-trivially propositional"
   - Teammate C: this gate is trivially easy, needs semantic non-triviality measures
   - **Resolution**: C is right. Replace the single syntactic gate with a three-part gate: timeout rate < 20%, valid fraction ≥ 30%, and PatternKey entropy above a threshold.

4. **Dataset scale**:
   - Task description: 10K-50K formulas
   - Teammate D: start with 2K-5K, iterate fast
   - **Resolution**: Configurable depth bounds. Default run: 2K-5K (fast, ~minutes). Deep run: 10K-50K (overnight). The benchmark (500-1K held-out) draws from the deep run. Phase 1 (value estimator) can begin with the fast run.

### Gaps Identified

1. **Dense/Discrete frame class support**: `decide` only handles Base. No immediate fix; document as a limitation.
2. **Countermodel richness**: `SimpleCountermodel` provides only atom-level data. Tier 2/3 corrective signals (task 201 round 2) require separate work.
3. **Formula equivalence handling**: Logically equivalent formulas (e.g., `p → q` vs `¬p ∨ q`) are syntactically distinct. For ML training this is arguably a feature; the benchmark should test equivalence awareness.
4. **`decideAuto` fuel adequacy**: `recommendedFuel φ = 10 * φ.complexity + 100` may be too conservative for temporal formulas at complexity 9+. Needs empirical tuning.
5. **No existing JSON infrastructure**: Zero files in `Theories/` import `Lean.Data.Json`. All `ToJson` instances must be built from scratch (~200-400 lines).
6. **Existing `Arbitrary Formula` instance** (test generators) doesn't generate `untl`/`snce` directly — uses derived operators. The enumerator must use all 6 primitive constructors.

---

## Recommendations

### Module Architecture (3 files, ~700-1000 LOC total)

**File 1: `Automation/FormulaEnumerator.lean` (~250-350 lines)**
- `EnumParams` structure: maxComplexity, maxModalDepth, maxTemporalDepth, atoms, maxFormulas, samplingMode
- `enumerateExhaustive : EnumParams → List Formula` — all formulas up to bounds (for complexity ≤ 7)
- `sampleRandom : EnumParams → IO (List Formula)` — grammar-based random sampling (for larger formulas)
- `enrichWithDuals : List Formula → List Formula` — temporal duality augmentation
- `mutateFormula : Formula → List Formula` — contrastive pair generation (optional, week 4)
- Diversity tracking and rejection sampling

**File 2: `Automation/DatasetGenerator.lean` (~300-400 lines)**
- `LabeledFormula` structure with formula, label, proof trace, countermodel, metrics
- `ProofTrace` simplified type (height, axioms_used, rules_applied)
- `labelFormula : Formula → IO LabeledFormula` — run decider, extract results, measure timing
- `computeMetrics : Formula → Option Nat → DifficultyMetrics` — all difficulty metrics
- `extractProofTrace : DerivationTree → ProofTrace` — simplified extraction
- Streaming batch processing with progress reporting

**File 3: `Automation/DatasetExport.lean` (~250-350 lines)**
- `FormulaExport` and `MetricsExport` structures with `ToJson` deriving
- `ToJson` instances for `Formula` (tagged AST), `ProofTrace`, `SimpleCountermodel`, `PatternKey`
- `writeDatasetJSONL : List LabeledFormula → FilePath → IO Unit` — streaming JSONL writer
- `writeBenchmark : List LabeledFormula → DatasetMetadata → FilePath → IO Unit` — benchmark with metadata header
- `main : IO Unit` — CLI entry point with configurable parameters

**Lakefile addition:**
```lean
lean_exe dataset_generator where
  root := `Bimodal.Automation.DatasetExport
  supportInterpreter := true
```

### JSON Schema (per record in JSONL)

```json
{
  "id": "bmlogic_00001",
  "split": "train",
  "formula_str": "□(p → G(q))",
  "formula_ast": {"tag": "box", "child": {"tag": "imp", "left": {"tag": "atom", "name": "p"}, "right": {"tag": "all_future", "child": {"tag": "atom", "name": "q"}}}},
  "frame_class": "Base",
  "label": "valid",
  "proof_trace": {
    "height": 4,
    "axioms_used": ["ax_T", "box_imp"],
    "rules_applied": ["necessitation", "modus_ponens", "modus_ponens"]
  },
  "countermodel": null,
  "pattern_key": {"modal_depth": 1, "temporal_depth": 1, "imp_count": 1, "complexity": 7, "top_operator": "ModalTemporal"},
  "metrics": {
    "complexity": 7,
    "modal_depth": 1,
    "temporal_depth": 1,
    "imp_count": 1,
    "atom_count": 2,
    "decision_time_ms": 12,
    "difficulty_tier": "medium"
  },
  "augmentation": {
    "temporal_dual_id": "bmlogic_00002",
    "is_dual": false
  }
}
```

### Feasibility Gates (Revised)

| Gate | Criterion | Rationale |
|------|-----------|-----------|
| Timeout rate | < 20% | Decision procedure should complete on most formulas |
| Valid fraction | ≥ 30% | Sufficient positive training signal |
| PatternKey entropy | Above threshold | Structural diversity across dimensions |
| Operator coverage | All 6 constructors represented | No missing formula families |

### Benchmark Design (500-1K held-out)

- **Stratified by difficulty**: Easy (20%), Medium (40%), Hard (30%), Very Hard (10%)
- **Balanced validity**: ~50% valid, ~50% invalid
- **Known anchors**: Include all 42 BX axiom instances (valid) and known non-theorems (invalid)
- **Deterministic split**: Hash-based assignment (hash formula string → bucket) for reproducibility
- **Cross-validation**: Include formulas from the completeness proof as test cases

### Implementation Timeline

| Week | Deliverable | LOC |
|------|------------|-----|
| 1 | FormulaEnumerator.lean — bounded generation, dedup, diversity check | ~300 |
| 2 | DatasetGenerator.lean — decide wrapper, ProofTrace extraction, metrics | ~350 |
| 3 | DatasetExport.lean — ToJson instances, JSONL writer, main entry point | ~300 |
| 4 | Temporal duality augmentation, contrastive pairs, benchmark curation | ~150 |

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary Implementation | completed | high | Module architecture, enumeration algorithm, decider integration, JSON export approach |
| B | Alternative Approaches | completed | high | Prior art survey (5 systems), hybrid enumeration strategy, JSONL schema with 17 fields |
| C | Critic | completed | high | Combinatorial explosion analysis, Base-only limitation, SimpleCountermodel shallowness, sampling requirement |
| D | Horizons | completed | high | BMLogic-Bench publication opportunity, multi-representation schema, contrastive pairs, start-small strategy |

---

## References

### Prior Art (ML for Theorem Proving)
- Alchemy (arXiv:2410.15748) — Mutation-based theorem synthesis, 6.3M from 110K
- LTLBench (arXiv:2407.05434) — Temporal logic formula generation + model checker labeling
- DeepSeek-Prover V1/V2 — Autoformalization + filtering + expert iteration
- MUSTARD (arXiv:2402.08957) — Uniform synthesis of theorem and proof data
- Saturation-Driven Dataset Generation (arXiv:2509.06809) — TPTP-based enumeration
- Goedel-Prover-V2 (arXiv:2508.03613) — Scaffolded data synthesis
- "Training a First-Order Theorem Prover from Synthetic Data" (arXiv:2103.03798)
- "Learning to Prove by Learning to Generate" (arXiv:2002.07019)
- Random Modal CNF (Patel-Schneider et al., JAIR 2011) — Phase-transition formula generation

### Benchmarks
- miniF2F (arXiv:2109.00110) — 488 Olympiad problems, cross-system
- HolStep (arXiv:1703.00426) — 2M+ examples from HOL Light
- ProofNet — Undergraduate math benchmark for Lean
- PutnamBench — Competition math benchmark

### Lean 4 Infrastructure
- Lean.Data.Json API — Built-in ToJson/FromJson typeclasses
- LeanDojo v2 — Python-Lean 4 tracing infrastructure
- LeanUniverse (Facebook Research) — Dataset standardization
- LeanSerde — Type-safe serialization library

### Task 201 Findings (Parent Task)
- Round 1: AlphaZero-style proof search design, phased approach (Phase 0 = this task)
- Round 2: Three-tier corrective signal strategy, Lean-native countermodels as Tier 1
