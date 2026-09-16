# Automation

Proof automation tactics and ML dataset generation pipeline for TM bimodal logic.

This directory serves two purposes, and they are very unequal in size:
1. **Proof automation**: custom Lean 4 tactics for TM derivability goals
2. **ML dataset pipeline**: formula enumeration, labelling, validation and export for ML
   benchmarks

**The ML pipeline is the larger half by an order of magnitude**, and it is what most of the
files here are. It rests on `ProofSearch/` and on the decision procedure in `Metalogic/`.

**`modal_search` is the pedagogical entry point, not library infrastructure.** It is the only
proof-search tactic — `tm_auto`, `temporal_search` and `propositional_search` were removed
after measurement showed they differed from it only in `SearchConfig` weight fields that the
search never read — and it has **three call sites in the whole repository, all in
`Examples/`**. Nothing in `Metalogic/`, `Theorems/` or `Semantics/` is proved by it. Reach for
it to demonstrate that a formula is derivable; do not build a proof on it. The one genuinely
load-bearing tactic in this directory is `propDecide`, and the six EF-game tactics in
`Metalogic/WeakCanonical/EFGameTactics.lean` — which are not here — carry 68 call sites
between them.

There is no Aesop rule set. One existed and was retired for having zero consumers; see
[`Boneyard/RetiredTactics/README.md`](../Boneyard/RetiredTactics/README.md).

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Automation -->
| File | Lines | Description |
|------|-------|-------------|
| `AtomCanonicalization.lean` | 147 | Canonical form for formulas under atom permutation, so formulas identical up to atom renaming collapse to one dataset entry |
| `AxiomNames.lean` | 57 | The canonical 45 `ProofSystem.Axiom` constructor names in `Axioms.lean` source order, extracted into a leaf module |
| `BenchmarkAnchors.lean` | 593 | Benchmark anchor formulas: ground-truth valid/invalid formula pairs |
| `BenchmarkOracle.lean` | 370 | Batch oracle: reads formula JSON, runs decision procedure, outputs JSONL labels |
| `DataExport.lean` | 395 | Core data export: JSONL serialization for formula-label pairs |
| `DatasetAssembly.lean` | 350 | Dataset assembly: structured JSON dataset with metadata and train/eval split |
| `DatasetGenerator.lean` | 2,296 | Dataset generator: runs `decide` on enumerated formulas, extracts proof traces |
| `DatasetGeneratorMain.lean` | 1,354 | Dataset export pipeline: formatting, splitting, output orchestration |
| `DatasetValidatorMain.lean` | 604 | Dataset validator: conformance tests, diversity metrics, feasibility gate |
| `EnrichedCountermodel.lean` | 223 | Enriched countermodel extraction for dataset negative examples |
| `EnumBenchmark.lean` | 227 | Enumeration benchmark: performance testing for formula enumeration |
| `FormulaEnumerator.lean` | 2,374 | Formula enumerator: depth-bounded enumeration of all TM formulas |
| `FormulaMutator.lean` | 1,191 | Formula mutator: systematic mutation for dataset augmentation |
| `ForwardProofGenerator.lean` | 400 | Forward-chaining proof generation: applies the productive inference rules from axiom instances to build a pool of `(formula, DerivationTree)` pairs |
| `InterestingnessMetrics.lean` | 584 | Deterministic three-tier interestingness scoring for theorems and derivations |
| `LemmaDB.lean` | 48 | Declares the `@[tmLemma]` label attribute the `modal_search` tactic family uses to enumerate derived theorems |
| `MachineAppendixExport.lean` | 498 | Exports the complete TM axiomatization — 45 schemata, 7 rules, derived-operator definitions — as the JSONL machine appendix shipped with BimodalReference |
| `Normalization.lean` | 1,271 | Bidirectional normalization for derived operators: the unfold direction reduces them to primitives, the fold direction restores them |
| `NormalizationAttr.lean` | 44 | Declares the two simp sets `Normalization.lean` tags its unfold and fold lemmas with |
| `PrefilterSoundness.lean` | 174 | Soundness proofs for each invalid-pattern recognizer in `DatasetGenerator.lean` |
| `ProofFirstBenchmark.lean` | 188 | Eight cross-corpus metrics for labeled formula datasets, plus a side-by-side comparison utility |
| `ProofFirstExporter.lean` | 148 | CLI executable: runs the forward-chaining generator and emits `LabeledFormula` records as JSONL |
| `ProofStepExport.lean` | 1,692 | Proof step export: serializes `DerivationTree` steps to JSONL |
| `ProofStepExtractor.lean` | 361 | Proof step extractor: traverses derivation trees to extract steps |
| `SuccessPatterns.lean` | 429 | Successful proof patterns: heuristic patterns for guided proof search |
| `TableauBridge.lean` | 648 | Persistent REPL with a JSONL stdin/stdout protocol, composing the formula parser with the decision procedure for live queries |
| `TableauProofStepPipeline.lean` | 696 | Pipeline joining `FormulaEnumerator`, `DecisionProcedure` and `ProofStepExtractor` into large-scale proof-step training data |
| `TraceExporter.lean` | 265 | CLI executable: reads S-expression formulas and streams JSONL `ProofCertificate`s to stdout |
| `TruthNormAttr.lean` | 57 | Declares the `truth_norm` and `swap_norm` simp sets used by the truth layer's characterization lemmas |
| `ProofSearch/` | — | Proof search engine: bounded derivation search (Core.lean, Strategies.lean) |
| `Tactics/` | — | Tactic elaborators: `apply_axiom`, `modal_t`, `tm_auto` (Commands.lean, Helpers.lean) |
<!-- END GENERATED -->

## Proof Automation Components

| File | Purpose |
|------|---------|
| `SuccessPatterns.lean` | Heuristic proof patterns for `ProofSearch/` |
| `Tactics/` | Tactic elaboration (`modal_search`, `propDecide`, `deduction`, `apply_axiom`, `modal_t`) |
| `ProofSearch/` | Depth-limited proof search engine |

`EFGameTactics.lean` is **not** in this directory, despite `Automation.lean` re-exporting it.
It declares `namespace FormalSystem.Metalogic.WeakCanonical` and its only consumer is the EF-game
development, so it lives at `Metalogic/WeakCanonical/EFGameTactics.lean`, where its path and its
namespace agree.

## ML Dataset Pipeline

The pipeline flows left-to-right:

```
FormulaEnumerator → DatasetGenerator → DatasetValidatorMain → DatasetGeneratorMain/DatasetAssembly
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
| `DatasetValidatorMain.lean` | Step 3: validate quality and diversity metrics |
| `BenchmarkOracle.lean` | Step 4: batch re-labeling oracle for benchmarking |
| `EnumBenchmark.lean` | Performance testing for enumeration |
| `DataExport.lean` | Core JSONL serialization utilities |
| `DatasetGeneratorMain.lean` | Full export pipeline orchestration |
| `DatasetAssembly.lean` | Configurable exporter (format options, splitting) |

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
lake exe dataset_generator -- --output data/bmlogic.jsonl

# Run benchmark oracle on formulas
lake exe benchmark_oracle -- --input formulas.jsonl --output results.jsonl
```

## Related Documentation

- [ProofSearch README](ProofSearch/README.md)
- [Tactics README](Tactics/README.md)
- [Parent README](../README.md)
- [Decidability README](../Metalogic/Decidability/README.md)

---

*Last verified: 2026-09-07*
