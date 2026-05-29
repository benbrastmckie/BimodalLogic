# Teammate A Findings: Primary Implementation Approach

**Task**: 203 — Formula Enumerator, Decider Labeling, and JSON Dataset Export
**Angle**: Primary implementation approach — enumeration strategy, decider integration, JSON export, metrics, benchmark
**Date**: 2026-05-29

---

## Key Findings

### 1. Formula Enumeration Strategy: Bounded Depth/Size Generation

The `Formula` inductive type has 6 constructors: `atom`, `bot`, `imp`, `box`, `untl`, `snce`. Existing infrastructure provides:
- `Formula.complexity` — structural size (connective count + 1)
- `Formula.modalDepth` — maximum box nesting
- `Formula.temporalDepth` — maximum untl/snce nesting
- `Formula.countImplications` — implication count
- `PatternKey.fromFormula` — extracts all structural features in one call

**Recommended enumeration algorithm**: Generate formulas by **bounded complexity** with **depth constraints** using a recursive generator:

```
enumerate(maxComplexity, maxModalDepth, maxTemporalDepth, atoms) → List Formula
```

The generator should work top-down by constructor:
- **Base cases** (complexity 1): `atom a` for each `a ∈ atoms`, plus `bot`
- **Unary** (complexity c, modal depth d): `box φ` where φ has complexity ≤ c-1, modalDepth ≤ d-1
- **Binary** (complexity c): `imp φ ψ`, `untl φ ψ`, `snce φ ψ` where φ.complexity + ψ.complexity ≤ c-1, distributing budget across subformulas

**Key design choices**:

1. **Fixed atom set**: Use 2-3 atoms (`p`, `q`, `r` via `Atom.mk_base`). This is sufficient for non-trivial formulas and controls combinatorial explosion. With 3 atoms, at complexity 5 we already get thousands of formulas.

2. **Memoization via complexity budget**: Use dynamic programming — for each (complexity, modalDepth, temporalDepth) triple, enumerate all formulas of exactly that specification. Cache results to avoid recomputation.

3. **Diversity enforcement**: Track the distribution of top-level constructors and discard excess propositional formulas. The feasibility gate requires <80% trivially propositional — this means formulas with modalDepth=0 AND temporalDepth=0 should be capped. A simple approach: enumerate all formulas, then filter/sample to maintain constructor diversity targets (e.g., ≥10% box, ≥10% untl, ≥10% snce).

4. **Redundancy reduction**: 
   - Skip formulas where both subformulas are identical in symmetric positions (e.g., `imp p p` is trivially valid)
   - Skip `imp bot φ` (always valid) and `imp φ bot` (just negation)
   - Skip nested double negations (`imp (imp φ bot) bot`)
   - Consider derived operators as first-class enumeration targets: generate `all_future φ`, `all_past φ`, `some_future φ`, `some_past φ`, `diamond φ`, `always φ` as specific patterns, not just raw constructor combinations

5. **Temporal duality doubling**: For every formula φ containing temporal operators, `swap_temporal φ` is a distinct formula with the same structural properties but swapped past/future semantics. Generate one and obtain the other for free via `Formula.swap_temporal`.

**Confidence**: HIGH — the structural metrics already exist in Formula.lean; the enumeration algorithm is straightforward recursion over bounded resources.

### 2. Decider Integration: Batch Pipeline

The existing `DecisionProcedure.lean` provides everything needed:

- **`decide φ searchDepth tableauFuel → DecisionResult φ`**: Main entry point. Returns `valid proof`, `invalid counter`, or `timeout`.
- **`decideAuto φ`**: Auto-scales fuel based on complexity. Good default.
- **`decideBatch formulas fuel`**: Already exists! Returns aggregate statistics. However, it only collects counts, not per-formula results. **This needs extension.**

**Recommended integration approach**:

```lean
structure LabeledFormula where
  formula : Formula
  label : String          -- "valid" | "invalid" | "timeout"
  proofHeight : Option Nat
  countermodel : Option SimpleCountermodel
  metrics : DifficultyMetrics
  deriving Repr
  
def labelFormula (φ : Formula) (fuel : Nat := 1000) : LabeledFormula :=
  let result := decideAuto φ
  match result with
  | .valid proof => { formula := φ, label := "valid", 
                      proofHeight := some proof.height,
                      countermodel := none, metrics := computeMetrics φ (some proof.height) none }
  | .invalid cm => { formula := φ, label := "invalid",
                     proofHeight := none, 
                     countermodel := some cm, metrics := computeMetrics φ none (some cm) }
  | .timeout => { formula := φ, label := "timeout",
                  proofHeight := none, countermodel := none, 
                  metrics := computeMetrics φ none none }
```

**Timeout handling**: Use `decideAuto` which automatically scales fuel to complexity. For very complex formulas (complexity > 20), set a hard fuel ceiling (e.g., 5000) and accept timeout as a valid label. Timeouts should be tracked but excluded from training data. The benchmark should report timeout rate.

**Proof trace extraction**: From `DecisionResult.valid proof`:
- `proof.height` — derivation tree height (available directly)
- Proof rule sequence — requires a tree walk function to extract the sequence of inference rules applied. This is novel code but straightforward: recursively walk the `DerivationTree` collecting constructor names.

**Countermodel extraction**: From `DecisionResult.invalid cm`:
- `cm.trueAtoms` — atoms assigned true
- `cm.falseAtoms` — atoms assigned false
- `cm.formula` — the refuted formula
- `cm.isConsistent` — self-consistency check

**Performance concern**: The decision procedure is O(2^n) worst case. For formulas of complexity ≤ 10, this is fast (milliseconds). For complexity 15-20, it may take seconds. For complexity > 20, timeouts become common. **Recommendation**: Generate formulas up to complexity 12-15 for the main corpus, with a smaller sample of complexity 16-20 for the "hard" tier.

**Confidence**: HIGH — all required APIs exist; the main new work is the `labelFormula` wrapper and proof trace extraction.

### 3. JSON Export from Lean 4

Lean 4 provides built-in JSON serialization via `Lean.Json`, `ToJson`, and `FromJson` typeclasses in `Lean.Data.Json.FromToJson`.

**Approach**: Use `deriving ToJson, FromJson` on the export structures.

```lean
import Lean.Data.Json

structure FormulaExport where
  id : Nat
  formulaStr : String        -- human-readable string representation
  formulaRepr : String       -- Lean Repr for exact reconstruction
  label : String             -- "valid" | "invalid" | "timeout"
  proofHeight : Option Nat
  proofTrace : Option (List String)   -- sequence of rule names
  countermodelTrue : Option (List String)   -- true atom names
  countermodelFalse : Option (List String)  -- false atom names
  metrics : MetricsExport
  deriving ToJson, FromJson, Repr

structure MetricsExport where
  complexity : Nat
  modalDepth : Nat
  temporalDepth : Nat
  impCount : Nat
  topOperator : String
  atomCount : Nat
  deriving ToJson, FromJson, Repr
```

**File I/O**: Use `IO.FS.writeFile` in a `main` function defined in an executable target:

```lean
def main : IO Unit := do
  let formulas := enumerate params
  let labeled := formulas.map labelFormula
  let jsonArray := labeled.map (fun lf => toJson (toExport lf))
  let jsonStr := (Lean.Json.arr jsonArray.toArray).pretty
  IO.FS.writeFile "dataset.json" jsonStr
```

**Lakefile configuration**: Add an `lean_exe` target in `lakefile.lean`:
```lean
lean_exe dataset_generator where
  root := `Bimodal.Automation.DatasetGenerator
  supportInterpreter := true
```

This compiles the generator as a standalone executable that can be run: `lake exe dataset_generator`.

**Format options**:
1. **Single JSON file** — simple, works for datasets up to ~100K entries
2. **JSON Lines (.jsonl)** — one JSON object per line, better for streaming large datasets to Python
3. **Recommendation**: Use JSON Lines format. Write one record per line using `IO.FS.Handle.putStrLn`. This is the standard format for ML training data (used by HuggingFace datasets, etc.)

**Online resources confirm**: Lean 4 structures with `deriving ToJson` work out of the box for serialization. The `Lean.Json` module provides `Json.pretty` for formatted output and `toString` for compact output. The `lean4-json-schema` library (2026) provides even stronger compile-time guarantees but is overkill for our use case.

**Confidence**: HIGH — Lean 4's built-in `ToJson`/`FromJson` deriving is mature and well-documented.

### 4. Difficulty Metrics

From both existing codebase functions and the task 201 research findings, the following metrics should be computed per formula:

| Metric | Source | Purpose |
|--------|--------|---------|
| `complexity` | `Formula.complexity` | Structural size |
| `modalDepth` | `Formula.modalDepth` | Box nesting depth |
| `temporalDepth` | `Formula.temporalDepth` | Untl/snce nesting depth |
| `impCount` | `Formula.countImplications` | Branching factor estimate |
| `topOperator` | `goalCategory` | Formula category |
| `atomCount` | `Formula.atoms.card` | Vocabulary size |
| `proofHeight` | `DerivationTree.height` | Proof complexity (valid only) |
| `countermodelSize` | `cm.trueAtoms.length + cm.falseAtoms.length` | Refutation complexity (invalid only) |
| `isTemporalDual` | Check if `swap_temporal` is also in dataset | Data augmentation flag |

**Additional derived metrics** (cheap to compute):

- `maxDepth := max modalDepth temporalDepth` — overall nesting
- `operatorBalance := temporalDepth.toFloat / (modalDepth + temporalDepth + 1).toFloat` — modal-temporal mix
- `isPropositional := modalDepth == 0 && temporalDepth == 0` — diversity tracking
- `hasUntil := formulaContainsUntl φ` — Until presence
- `hasSince := formulaContainsSnce φ` — Since presence
- `hasBox := modalDepth > 0` — Box presence

**Proof trace as a metric**: For valid formulas, extracting the sequence of inference rule applications gives a rich training signal. The trace can be represented as `List String` where each entry is one of: `"axiom:{name}"`, `"assumption"`, `"modus_ponens"`, `"necessitation"`, `"temporal_necessitation"`, `"temporal_duality"`, `"weakening"`.

**Confidence**: HIGH — all base metrics already exist as functions on Formula; proof height is directly available.

### 5. Benchmark Design

The evaluation benchmark should be a held-out set of 500-1K formulas with specific properties:

**Stratified sampling strategy**:

1. **By validity**: ~50% valid, ~50% invalid (ensures balanced evaluation)
2. **By difficulty tier**:
   - Easy (complexity 3-5, depth ≤ 1): ~20%
   - Medium (complexity 6-10, depth ≤ 2): ~40%
   - Hard (complexity 11-15, depth ≤ 3): ~30%
   - Very Hard (complexity 16+, depth > 3): ~10%
3. **By operator coverage**: Ensure all 6 constructors appear as top-level, and all combinations of modal/temporal operators are represented
4. **By frame class**: For each formula, record which frame classes make it valid (may differ between Base/Dense/Discrete). This requires running `decide` at each frame class level.

**Benchmark structure**:
```json
{
  "metadata": {
    "version": "1.0",
    "generated": "2026-05-29",
    "total_formulas": 1000,
    "valid_count": 512,
    "invalid_count": 488,
    "difficulty_distribution": {...}
  },
  "formulas": [...]
}
```

**Separation**: Use a deterministic hash of the formula string to assign train/test split. This ensures reproducibility without storing split assignments.

**Known formula inclusion**: Include all 42 BX axiom instances as known-valid anchors, and include known non-theorems (e.g., `atom "p"`, `box (atom "p")` without context) as known-invalid anchors.

**Confidence**: MEDIUM-HIGH — the stratified design is sound, but the exact distribution of valid/invalid across complexity tiers needs empirical validation during enumeration.

---

## Recommended Approach: Module Architecture

### File 1: `Automation/FormulaEnumerator.lean`

**Responsibilities**:
- `enumerate : EnumParams → List Formula` — main enumeration function
- `EnumParams` structure: maxComplexity, maxModalDepth, maxTemporalDepth, atoms, maxFormulas
- Internal memoization table keyed by (complexity, modalDepth, temporalDepth)
- Diversity filtering: cap propositional formulas at percentage threshold
- `enrichWithDuals : List Formula → List Formula` — add temporal duals

**Estimated size**: ~200-300 lines

### File 2: `Automation/DatasetGenerator.lean`

**Responsibilities**:
- `labelFormula : Formula → LabeledFormula` — run decider, extract traces
- `labelBatch : List Formula → List LabeledFormula` — batch labeling with progress
- `computeMetrics : Formula → DifficultyMetrics` — all difficulty metrics
- `extractProofTrace : DerivationTree → List String` — rule sequence extraction
- `splitBenchmark : List LabeledFormula → (List LabeledFormula × List LabeledFormula)` — train/test split

**Estimated size**: ~300-400 lines

### File 3: `Automation/DatasetExport.lean`

**Responsibilities**:
- `FormulaExport` and `MetricsExport` structures with `ToJson` deriving
- `toLabeledJson : LabeledFormula → FormulaExport` — convert to export format
- `writeDataset : List FormulaExport → FilePath → IO Unit` — JSONL writer
- `writeBenchmark : List FormulaExport → DatasetMetadata → FilePath → IO Unit` — benchmark JSON writer
- `main : IO Unit` — executable entry point

**Estimated size**: ~200-300 lines

### Lakefile addition:
```lean
lean_exe dataset_generator where
  root := `Bimodal.Automation.DatasetExport
  supportInterpreter := true
```

### Total estimated effort: ~700-1000 lines of new Lean code

---

## Evidence/Examples

### Enumeration count estimates (3 atoms: p, q, r)

| Max Complexity | Approx. Formulas | Non-trivial % |
|---------------|-----------------|---------------|
| 3 | ~30 | ~40% |
| 5 | ~500 | ~55% |
| 7 | ~5,000 | ~65% |
| 9 | ~50,000 | ~70% |
| 11 | ~500,000+ | ~75% |

These are rough estimates. The actual count depends heavily on redundancy filtering. With 3 atoms, complexity 9, and depth constraints (modalDepth ≤ 3, temporalDepth ≤ 3), the target of 10K-50K labeled formulas is easily achievable.

### Existing research confirms the approach

The paper "Training a First-Order Theorem Prover from Synthetic Data" (arXiv:2103.03798) describes a random formula generation and labeling pipeline for training neural theorem provers — the same general architecture proposed here. The paper "Learning to Prove Theorems by Learning to Generate Theorems" (arXiv:2002.07019) uses backward proof generation to synthesize training data, a complementary approach.

The HolStep dataset (arXiv:1703.00426) provides 2M+ training examples from 11,400 proofs — our target of 10K-50K is modest by comparison but appropriate for a domain-specific decidable logic.

---

## Confidence Level

**Overall**: HIGH

- Formula enumeration: HIGH (straightforward bounded recursion)
- Decider integration: HIGH (all APIs exist, need thin wrappers)
- JSON export: HIGH (Lean 4 built-in `ToJson` deriving is mature)
- Difficulty metrics: HIGH (existing functions cover most needs)
- Benchmark design: MEDIUM-HIGH (empirical validation needed for distribution targets)
- Feasibility gate: HIGH (diversity is achievable with 3 atoms and depth constraints)

---

## Sources

- [Lean.Data.Json.FromToJson](https://leanprover-community.github.io/mathlib4_docs/Lean/Data/Json/FromToJson.html) — Lean 4 JSON serialization API
- [Lean.Data.Json.FromToJson.Basic](https://lean-lang.org/doc/api/Lean/Data/Json/FromToJson/Basic.html) — Core ToJson/FromJson typeclasses
- [lean4-json-schema](https://predictablemachines.com/blog/announcing-lean4-json-schema/) — Proven-correct JSON Schema in Lean 4
- [LeanSerde](https://reservoir.lean-lang.org/@oOo0oOo/LeanSerde) — Type-safe serialization library
- [Training a First-Order Theorem Prover from Synthetic Data](https://arxiv.org/pdf/2103.03798) — Formula generation for ML theorem proving
- [Learning to Prove Theorems by Learning to Generate Theorems](https://arxiv.org/pdf/2002.07019) — Synthetic theorem generation
- [HolStep Dataset](https://arxiv.org/pdf/1703.00426) — ML dataset for theorem proving
- [LLM-based Automated Theorem Proving Hinges on Scalable Synthetic Data Generation](https://arxiv.org/pdf/2505.12031) — Scalable data generation
- [Lean 4 IO and File Operations](https://lean-lang.org/doc/reference/latest/IO/Files___-File-Handles___-and-Streams/) — File I/O reference
