# Automation

Proof automation tactics for TM bimodal logic: normalization simp sets, the derived-lemma
database, the bounded proof-search engine, and the tactic elaborators.

**This directory used to serve two purposes, very unequal in size.** The second was the ML
dataset pipeline — formula enumeration, labelling, validation and JSONL export — and it was the
larger half by an order of magnitude: 24 of the 31 modules here, 14,527 lines against roughly
2,100. It has left, together with `Metalogic/Decidability/TraceExport.lean`, for
`lean_lib BimodalTools` at the repository root. `BimodalTools` sits outside `defaultTargets`, so
`lake build` no longer compiles any of it; see [`BimodalTools/README.md`](../../BimodalTools/README.md).

What remains here is library code, reachable from the published `FormalSystem` target. The
dependence runs one way and check `B3` says so: `BimodalTools` imports this directory, and
nothing here may import `BimodalTools`.

**`modal_search` is the pedagogical entry point, not library infrastructure.** It is the only
proof-search tactic — `tm_auto`, `temporal_search` and `propositional_search` were removed
after measurement showed they differed from it only in `SearchConfig` weight fields that the
search never read — and it has **three call sites in the whole repository, all in
`Examples/`**. Nothing in `Metalogic/`, `Theorems/` or `Semantics/` is proved by it. Reach for
it to demonstrate that a formula is derivable; do not build a proof on it. The one genuinely
load-bearing tactic in this directory is `propDecide`, and the six EF-game tactics in
`Metalogic/Expressiveness/EFGameTactics.lean` — which are not here — carry 68 call sites
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
| `Normalization.lean` | 929 | Bidirectional normalization for derived operators: the unfold direction reduces them to primitives, the fold direction restores them |
| `SuccessPatterns.lean` | 419 | Successful proof patterns: heuristic patterns for guided proof search |
| `ProofSearch/` | — | Proof search engine: bounded derivation search (Core.lean, Strategies.lean) |
| `Tactics/` | — | Tactic elaborators: `modal_search`, `apply_axiom`, `modal_t`, `assumption_search`, `deduction`, `undischarge`, `propDecide` (Commands.lean, UserTactics.lean, Deduction.lean, Meta.lean, PropDecide.lean, Search.lean) |
<!-- END GENERATED -->

## Decision: `SuccessPatterns` stays, undivided

`SuccessPatterns.lean` was the one genuinely ambiguous module in the library/tooling split, and
the decision was to leave it here **whole** rather than divide it. Three reasons, in order of
weight:

1. **There is no IO/JSON half to split off.** The module is pure data and pure functions:
   `PatternKey`, `GoalCategory`, `ProofStrategy`, `PatternDatabase` and the lookup/record
   operations over them. Nothing in it serializes, reads a file, or touches `IO`. A split would
   have to invent a seam rather than follow one.
2. **It has live library call sites.** `ProofSearch/Core.lean` imports it directly;
   `ProofSearch/Strategies.lean` uses `PatternDatabase` and `recordSuccess` through that import
   (`searchWithLearning`, `bestFirstSearch`), and
   `Tests/BimodalTest/Automation/ProofSearchBenchmark.lean` exercises the path. Moving it would
   put a `FormalSystem -> BimodalTools` edge into the published library — exactly what `B3`
   forbids — or force `ProofSearch/` out of the library behind it.
3. **The tooling reaches it the sanctioned way.** `BimodalTools` needs the `PatternKey` /
   `GoalCategory` vocabulary (`ProofFirstGeneratorMain` and `BenchmarkAnchorsMain` both call
   `PatternKey.fromFormula`, and `DataExport` serializes both types), and it gets there by
   importing `FormalSystem.Automation.SuccessPatterns`. That is the permitted
   direction and costs nothing.

**This supersedes `docs/development/PUBLICATION_REFACTOR.md` Phase 4's bullet "cut
`ProofSearch.Core -> SuccessPatterns`".** That bullet assumed `SuccessPatterns` was tooling and
that the edge was therefore a library-to-tooling dependency to be broken. It is not: both ends
stay in the library, the edge is library-internal, and there is nothing to cut. When Phase 4 is
planned, that bullet is a no-op — do not re-derive the cut from the bullet's wording.

## Proof Automation Components

| File | Purpose |
|------|---------|
| `SuccessPatterns.lean` | Heuristic proof patterns for `ProofSearch/` |
| `Tactics/` | Tactic elaboration (`modal_search`, `propDecide`, `deduction`, `apply_axiom`, `modal_t`) |
| `ProofSearch/` | Depth-limited proof search engine |

`EFGameTactics.lean` is **not** in this directory, despite `Automation.lean` re-exporting it.
It declares `namespace FormalSystem.Metalogic.Expressiveness` and its only consumer is the EF-game
development, so it lives at `Metalogic/Expressiveness/EFGameTactics.lean`, where its path and its
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
