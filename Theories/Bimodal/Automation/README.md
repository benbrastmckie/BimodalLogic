# Automation

Proof automation tactics and ML dataset generation pipeline for TM bimodal logic.

This directory serves two complementary purposes:
1. **Proof automation**: Custom Lean 4 tactics and Aesop rule sets for TM logic proofs
2. **ML dataset pipeline**: Formula enumeration, labeling, validation, and export for ML benchmarks

The proof automation tools (AesopRules, EFGameTactics, SuccessPatterns) are used
throughout the library. The ML pipeline (DatasetGenerator, FormulaEnumerator, etc.)
produces the BMLogic benchmark datasets. Both rely on the ProofSearch/ and Tactics/
subdirectories for their implementation infrastructure.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `AesopRules.lean` | 276 | Aesop rule set for TM logic: TMLogic declaration, forward chaining, normalization |
| `BenchmarkAnchors.lean` | 496 | Benchmark anchor formulas: ground-truth valid/invalid formula pairs |
| `BenchmarkOracle.lean` | 365 | Batch oracle: reads formula JSON, runs decision procedure, outputs JSONL labels |
| `DataExport.lean` | 383 | Core data export: JSONL serialization for formula-label pairs |
| `DatasetExport.lean` | 578 | Dataset export pipeline: formatting, splitting, output orchestration |
| `DatasetExporter.lean` | 342 | Dataset exporter: configurable export with format options |
| `DatasetGenerator.lean` | 471 | Dataset generator: runs `decide` on enumerated formulas, extracts proof traces |
| `DatasetValidator.lean` | 589 | Dataset validator: conformance tests, diversity metrics, feasibility gate |
| `EFGameTactics.lean` | 326 | EF game automation tactics for expressive completeness proofs |
| `EnrichedCountermodel.lean` | 211 | Enriched countermodel extraction for dataset negative examples |
| `EnumBenchmark.lean` | 196 | Enumeration benchmark: performance testing for formula enumeration |
| `FormulaEnumerator.lean` | 1091 | Formula enumerator: depth-bounded enumeration of all TM formulas |
| `FormulaMutator.lean` | 785 | Formula mutator: systematic mutation for dataset augmentation |
| `ProofStepExport.lean` | 332 | Proof step export: serializes `DerivationTree` steps to JSONL |
| `ProofStepExtractor.lean` | 329 | Proof step extractor: traverses derivation trees to extract steps |
| `SuccessPatterns.lean` | 423 | Successful proof patterns: heuristic patterns for guided proof search |
| `ProofSearch/` | — | Proof search engine: bounded derivation search (Core.lean, Strategies.lean) |
| `Tactics/` | — | Tactic elaborators: `apply_axiom`, `modal_t`, `tm_auto` (Commands.lean, Helpers.lean) |

## Proof Automation Components

| File | Purpose |
|------|---------|
| `AesopRules.lean` | `@[aesop]` rule set; use via `tm_auto` tactic |
| `EFGameTactics.lean` | Tactics for WeakCanonical/EFGames proofs |
| `SuccessPatterns.lean` | Heuristic proof patterns for `ProofSearch/` |
| `Tactics/` | Tactic elaboration (`apply_axiom`, `modal_t`, `tm_auto`) |
| `ProofSearch/` | Depth-limited proof search engine |

## ML Dataset Pipeline

The pipeline flows left-to-right:

```
FormulaEnumerator → DatasetGenerator → DatasetValidator → DatasetExport/DatasetExporter
       |                  |                                        |
FormulaMutator      ProofStepExtractor                     DataExport (JSONL)
                    EnrichedCountermodel                   BenchmarkOracle
                    BenchmarkAnchors
```

| File | Pipeline Role |
|------|--------------|
| `FormulaEnumerator.lean` | Step 1: enumerate TM formulas up to depth bound |
| `FormulaMutator.lean` | Step 1b: augment via systematic formula mutation |
| `DatasetGenerator.lean` | Step 2: label formulas using `decide` decision procedure |
| `ProofStepExtractor.lean` | Step 2b: extract individual proof steps from derivation trees |
| `ProofStepExport.lean` | Step 2c: serialize proof steps to JSONL |
| `EnrichedCountermodel.lean` | Step 2d: enrich negative examples with countermodel info |
| `BenchmarkAnchors.lean` | Step 2e: inject ground-truth anchor pairs |
| `DatasetValidator.lean` | Step 3: validate quality and diversity metrics |
| `BenchmarkOracle.lean` | Step 4: batch re-labeling oracle for benchmarking |
| `EnumBenchmark.lean` | Performance testing for enumeration |
| `DataExport.lean` | Core JSONL serialization utilities |
| `DatasetExport.lean` | Full export pipeline orchestration |
| `DatasetExporter.lean` | Configurable exporter (format options, splitting) |

## Usage Examples

```lean
-- Proof automation: Apply axiom by name
example : ⊢ (Formula.box p).imp p := by
  apply_axiom  -- Finds and applies Axiom.modal_t

-- Comprehensive automation with Aesop
example : ⊢ (□p → p) := by
  tm_auto  -- Uses Aesop with TMLogic rule set
```

```bash
# ML pipeline: Generate dataset
lake run Bimodal.Automation.DatasetExporter -- output.jsonl

# Run benchmark oracle on formulas
lake run Bimodal.Automation.BenchmarkOracle -- formulas.jsonl results.jsonl
```

## Related Documentation

- [ProofSearch README](ProofSearch/README.md)
- [Tactics README](Tactics/README.md)
- [Parent README](../README.md)
- [Decidability README](../Metalogic/Decidability/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.
