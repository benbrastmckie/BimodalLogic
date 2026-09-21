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

## Module naming

Executable roots and libraries are told apart by name alone:

- **Executable roots are `PascalCase(target) ++ "Main"`.** The root module of `lake exe foo_bar`
  is `FooBarMain`: `dataset_generator` → `DatasetGeneratorMain`, `proof_extractor` →
  `ProofExtractorMain`, `contrastive_generator` → `ContrastiveGeneratorMain`, and
  `checkInitImports` (srcDir `scripts`) → `CheckInitImportsMain`. Every root declares a
  root-namespace `main`, so two of them cannot be imported into one environment.
- **`Main` is reserved.** No module that is not an executable root ends in `Main`.
- **A library is named for what it produces.** `XExport` is the JSON serialization layer for X
  (`DataExport`, `Metalogic/Decidability/TraceExport`); `XAssembly` assembles a structured
  artifact (`DatasetAssembly`); `XExtractor` extracts (`ProofStepExtractor`); `XGenerator`
  generates (`DatasetGenerator`, `ForwardProofGenerator`).

`lake exe` target names are the stable external interface (documentation and the dataset card
cite them); module names follow from them. `ContrastiveGeneratorMain` was historically named
`FormulaMutator`, after the mutation technique its docstring still describes. Emitted provenance
strings such as `"BimodalLogic/DatasetExporter"` and `"BimodalLogic/MachineAppendixExport"` are
stable IDs, not module paths, and keep their historical spelling.

The rule is enforced by `scripts/check-module-invariants.sh` check C25N.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Automation -->
| File | Lines | Description |
|------|-------|-------------|
| `LemmaDB.lean` | 48 | Declares the `@[tmLemma]` label attribute the `modal_search` tactic family uses to enumerate derived theorems |
| `Normalization.lean` | 930 | Bidirectional normalization for derived operators: the unfold direction reduces them to primitives, the fold direction restores them |
| `NormalizationAttr.lean` | 44 | Declares the two simp sets `Normalization.lean` tags its unfold and fold lemmas with |
| `SuccessPatterns.lean` | 417 | Successful proof patterns: heuristic patterns for guided proof search |
| `TruthNormAttr.lean` | 58 | Declares the `truth_norm` and `reflect_time_norm` simp sets used by the truth layer's characterization lemmas |
| `ProofSearch/` | — | Proof search engine: bounded derivation search (Core.lean, Strategies.lean) |
| `Tactics/` | — | Tactic elaborators: `modal_search`, `apply_axiom`, `modal_t`, `assumption_search`, `deduction`, `undischarge`, `propDecide` (Commands.lean, UserTactics.lean, Deduction.lean, Meta.lean, PropDecide.lean, Search.lean) |
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
ContrastiveGeneratorMain  ProofStepExtractor                       DataExport (JSONL)
                          EnrichedCountermodel                     BenchmarkOracleMain
                          BenchmarkAnchorsMain
```

| File | Pipeline Role |
|------|--------------|
| `FormulaEnumerator.lean` | Step 1: enumerate TM formulas up to depth bound |
| `ContrastiveGeneratorMain.lean` | Step 1b: augment via systematic formula mutation |
| `DatasetGenerator.lean` | Step 2: label formulas using `decide` decision procedure |
| `ProofStepExtractor.lean` | Step 2b: extract individual proof steps from derivation trees |
| `ProofExtractorMain.lean` | Step 2c: serialize proof steps to JSONL |
| `EnrichedCountermodel.lean` | Step 2d: enrich negative examples with countermodel info |
| `BenchmarkAnchorsMain.lean` | Step 2e: inject ground-truth anchor pairs |
| `DatasetValidatorMain.lean` | Step 3: validate quality and diversity metrics |
| `BenchmarkOracleMain.lean` | Step 4: batch re-labeling oracle for benchmarking |
| `EnumBenchmarkMain.lean` | Performance testing for enumeration |
| `DataExport.lean` | Core JSONL serialization utilities |
| `DatasetGeneratorMain.lean` | Full export pipeline orchestration |
| `DatasetAssembly.lean` | Configurable exporter (format options, splitting) |

## Usage Examples

```lean
-- Proof automation: Apply axiom by name
example : ⊢ (Formula.box p).imp p := by
  apply_axiom  -- Finds and applies Axiom.modal_t

-- Bounded proof search: the single proof-search entry point
example : ⊢ (□p → p) := by
  modal_search  -- Default depth 10, visitLimit 1000
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

*Last verified: 2026-09-17*
