# Implementation Summary: Task #203

- **Task**: 203 - Build formula enumerator, decider labeling, and JSON dataset export
- **Status**: COMPLETED
- **Plan**: specs/203_formula_enumerator_dataset_export/plans/01_formula-enum-dataset.md

## What Was Built

A three-module Lean 4 pipeline under `Theories/Bimodal/Automation/` that enumerates TM bimodal logic formulas at controlled depth, labels them using the existing `DecisionProcedure.decideAuto` function, extracts simplified proof traces, and streams labeled records as JSONL via a compiled Lake executable.

## Artifacts Created

| File | Lines | Purpose |
|------|-------|---------|
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | ~700 | Bounded formula enumeration with exhaustive, random, and hybrid modes |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | ~350 | Decision procedure integration, ProofTrace extraction, batch labeling |
| `Theories/Bimodal/Automation/DatasetExport.lean` | ~500 | JSONL export, CLI argument parsing, `main` entry point |
| `lakefile.lean` | +6 | `lean_exe dataset_generator` target |
| `data/.gitignore` | 3 | Gitignore for generated JSONL and metadata files |

## Key Technical Decisions

1. **Reused existing DataExport.lean**: The existing `Bimodal.Automation.DataExport` module (from Task 201) already provided JSON serialization for Formula, Atom, PatternKey, GoalCategory, and SimpleCountermodel via string concatenation. The new `DatasetExport.lean` builds on these primitives rather than importing `Lean.Data.Json`.

2. **ProofTrace extraction**: Recursive traversal of `DerivationTree` extracting height, axiom constructor names (all 42 constructors handled), and inference rule names. This avoids the impractical full serialization of the dependent-type proof tree.

3. **Deterministic split assignment**: Uses `hash(formula_str) % 100` for reproducible train/val/test split (80/10/10).

4. **CLI executable**: `lake exe dataset_generator` compiles to a native binary with full CLI argument parsing.

## Validation Results (Complexity 3 / 50 formulas)

- **Timeout rate**: 0% (target: <20%) -- PASS
- **Valid fraction**: 36% (target: >=30%) -- PASS
- **Category diversity**: 3 GoalCategory types present -- PASS
- **JSONL output**: Well-formed JSON, all required fields present
- **Proof traces**: Valid formulas have non-empty axioms_used and rules_applied
- **Countermodels**: Invalid formulas have trueAtoms/falseAtoms populated
- **Build**: `lake build` and `lake build dataset_generator` succeed with no errors

## CLI Usage

```bash
# Quick test (complexity 3, ~50 formulas)
lake exe dataset_generator -- --max-complexity 3 --max-formulas 50 --output data/test.jsonl

# Fast run (complexity 5, ~5K formulas with temporal duals)
lake exe dataset_generator -- --max-complexity 5 --max-formulas 5000 --output data/bmlogic-fast.jsonl --include-duals

# Deep run (complexity 7, hybrid mode)
lake exe dataset_generator -- --max-complexity 7 --max-formulas 50000 --output data/bmlogic-deep.jsonl --mode hybrid --include-duals
```

## Plan Deviations

- **Phase 4, Task 4.1**: Altered -- validated on complexity 3/50 formulas as quick test; medium run at complexity 5/500 running asynchronously (long-running)
- **Phase 4, Task 4.4-4.5**: Deferred to user -- deep run (complexity 7, 50K formulas) is a multi-hour operation best run manually overnight
- **Phase 4, Task 4.6 (benchmark curation)**: Altered -- deterministic split implemented via hash; stratified difficulty tiers recorded per-record but not enforced at generation time; BX axiom anchor inclusion deferred to follow-up task
- **Phase 3**: JSON serialization uses string concatenation via existing DataExport.lean primitives rather than `Lean.Data.Json` imports, avoiding potential build isolation issues noted in the plan's risk section

## Architecture

```
FormulaEnumerator.lean    DatasetGenerator.lean    DatasetExport.lean
  EnumParams                ProofTrace                DatasetRecord
  SamplingMode              DifficultyMetrics         AugmentationInfo
  enumerateExhaustive       FormulaLabel              DatasetMetadata
  sampleRandom              LabeledFormula            writeDatasetJSONL
  enrichWithDuals           extractAxiomName          writeMetadata
  computeDiversity          extractProofTrace         parseCLIArgs
  generateFormulas          labelFormula              main
                            labelBatch
                            computeBatchStats
```

The pipeline flows: `EnumParams` -> `generateFormulas` -> `enrichWithDuals` -> `labelBatch` -> `writeDatasetJSONL`.
