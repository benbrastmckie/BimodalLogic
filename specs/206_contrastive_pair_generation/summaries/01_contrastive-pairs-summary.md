# Implementation Summary: Contrastive Pair Generation

**Task**: 206 - contrastive_pair_generation
**Session**: sess_1780088191_17e016_b
**Date**: 2026-05-29
**Status**: Implemented

## What Was Implemented

A complete `FormulaMutator.lean` module in `Theories/Bimodal/Automation/` that generates contrastive training pairs from labeled formulas. The module implements 7 mutation strategies, a pipeline for batch pair generation, JSON serialization, and a standalone executable entry point.

## Files Modified

| File | Change |
|------|--------|
| `Theories/Bimodal/Automation/FormulaMutator.lean` | **New file**: Complete contrastive pair generation module (~780 lines) |
| `lakefile.lean` | Added `lean_exe contrastive_generator` entry |

## Key Implementation Decisions

1. **Local `substAtom` reimplementation**: Avoided importing the heavy `Separation.FormulaOps` dependency chain by implementing a local 10-line atom substitution function. This keeps build times fast.

2. **Computable `collectAtoms`**: The existing `Formula.atoms` returns a `Finset Atom` whose `toList` is noncomputable. Implemented a local `collectAtoms : Formula -> List Atom` that collects and deduplicates atoms at the `List` level for runtime use.

3. **Direct pattern matching for G/H recognition**: The `weakenAllToSome` function uses direct pattern matching on the primitive encoding of G(phi) and H(phi) rather than calling `matchAllFuture`/`matchAllPast` helpers, which ensures structural termination is provable to Lean's termination checker.

4. **Top-level `main` for executable linkage**: The `main` function is defined outside the `Bimodal.Automation.FormulaMutator` namespace at the module's top level, following the pattern established by `DatasetExport.lean`, so the Lean linker finds it.

5. **Enriched countermodels for invalid mutations**: When a mutation produces an invalid formula, the pipeline also extracts an `EnrichedCountermodel` (with full branch information) in addition to the `SimpleCountermodel`, providing richer corrective signal for training.

## Components Implemented

### Core Types
- `MutationType`: 8-variant inductive classifying mutation strategies
- `ContrastivePair`: Structure linking original formula to mutated variant with labels, countermodels, and proof traces

### Mutation Functions (7 strategies)
- `mutateAtomToBot`: Atom substitution with bot (falsity)
- `weakenBoxToDiamond`: Box to diamond operator weakening
- `weakenAllToSome`: G-to-F and H-to-P weakening via derived operator pattern recognition
- `deleteSubformula`: Subformula replacement with bot
- `reduceModalDepth`: Strip outermost box operators
- `reduceTemporalDepth`: Strip outermost untl/snce operators
- `swap_temporal` (reused): Temporal duality

### Pipeline
- `generateMutations`: Produces all applicable mutations for a formula
- `classifyMutation`: Runs `decideAuto` (with `decideOptimized` fallback) on mutations
- `generateContrastivePairs`: Full pipeline for a single labeled formula
- `filterContrastive`: Keeps only truly contrastive pairs (differing labels, non-trivial, no timeouts)
- `generateBatchContrastive`: Batch processing with progress reporting

### Serialization and Export
- `MutationType.toJson`, `MutationType.detailJson`: JSON mutation type encoding
- `ContrastivePair.toJson`: Full JSON record serialization
- `writeContrastiveJSONL`: JSONL file export with auto-incrementing IDs
- `ContrastiveBatchStats` and `computeContrastiveStats`: Summary statistics

### Executable
- `contrastive_generator`: Standalone executable entry in lakefile.lean
- CLI arguments: `--max-complexity`, `--max-modal-depth`, `--max-temporal-depth`, `--max-formulas`, `--output`

## Verification Results

| Check | Result |
|-------|--------|
| Sorry count | 0 |
| Vacuous definitions | 0 |
| New axioms | 0 |
| `lake build Bimodal.Automation.FormulaMutator` | Pass |
| `lake build contrastive_generator` | Pass |
| `lake build` (full project) | Pass |
| Existing executables (`dataset_generator`, `dataset_validator`, `proof_extractor`) | Pass |
| Plan compliance | All 20 definitions found |

## Plan Deviations

- [x] **Task 1.4**: `substAtom` *(deviation: altered -- implemented as `collectAtoms` companion was also needed since `Finset.toList` is noncomputable)*
- [x] **Task 1.8**: `weakenAllToSome` *(deviation: altered -- used direct pattern matching instead of calling matchAllFuture/matchAllPast helpers for termination)*
- [x] **Task 3.6**: `main` *(deviation: altered -- defined at top level outside namespace for linker compatibility, renamed parseArgs to parseContrastiveArgs)*

## Phases

| Phase | Status | Notes |
|-------|--------|-------|
| 1: Core Types and Mutation Functions | COMPLETED | All types and 7 mutations implemented |
| 2: Contrastive Pair Generation Pipeline | COMPLETED | Pipeline with enriched countermodels |
| 3: JSON Serialization and Export | COMPLETED | JSONL export and executable entry |
| 4: Integration Validation and Build Verification | COMPLETED | Full build passes, zero debt |
