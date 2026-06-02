# Implementation Summary: Task #242

**Task**: 242 - Tableau-derived proof step extraction and JSONL pipeline
**Status**: Implemented
**Session**: sess_1780355308_a08e2f_242
**Date**: 2026-06-01

## What Was Accomplished

Created a new Lean 4 pipeline module (`TableauProofStepPipeline.lean`) that connects the existing `FormulaEnumerator`, `DecisionProcedure` (`decideAuto`), and `ProofStepExtractor` (`extractStepSequence`) into a single executable for generating large-scale proof step training data in JSONL format.

### Artifacts Created

1. **`Theories/Bimodal/Automation/TableauProofStepPipeline.lean`** (660 lines) -- New pipeline module containing:
   - `PipelineConfig`: Configurable parameters (complexity, depths, seed count, wrap depth, output path, dedup flag)
   - `StepDistribution`: Diversity metrics with rule/axiom/complexity histograms
   - `hashProofStep`: Step-level deduplication via structural hashing on `(context, goal, rule, axiomName)`
   - `processFormula`: Core decide + extract function
   - `runEnumerationPipeline`: Strategy 1 -- exhaustive enumeration + decision + extraction
   - `runAxiomSeedPipeline`: Strategy 2 -- axiom-seeded valid formula generation
   - `runDeepWrappingPipeline`: Strategy 3 -- G^n temporal wrapping with direct proof wrapping
   - `runFullPipeline`: Orchestrator combining all three strategies with cross-source dedup
   - `writeProofStepsJSONL` / `writeMetadataJSON`: Output generation
   - `parseArgs` / `main`: CLI entry point

2. **`lakefile.lean`** -- Added `lean_exe tableau_proof_steps` target

### Key Design Decision: Direct Proof Wrapping

The initial deep wrapping strategy tried to re-decide `G^n(phi)` from scratch using `decideAuto`, which failed because wrapped formulas have much higher complexity and cause timeouts. The fix was to wrap the `DerivationTree` directly using `temporal_necessitation`, mirroring the approach in `ProofStepExport.lean`. This makes wrapping instant and always successful for valid formulas.

## Validated Results (Complexity 5 Test)

| Metric | Value |
|--------|-------|
| Enumerated formulas | 4,992 |
| Valid formulas | 218 (4.4%) |
| Enumeration steps | 302 unique |
| Axiom seed steps | 0 unique (all duplicates of enumeration) |
| Wrapping steps (218 formulas x 5 depths) | 1,090 unique |
| **Total unique steps** | **1,392** |
| Rule coverage | 3/7 (axiom, modus_ponens, temporal_necessitation) |
| Axiom name coverage | 4/42 (ex_falso, prop_k, prop_s, modal_t) |
| JSONL validation | All 1,392 lines valid JSON with all required fields |
| axiom_name consistency | 0 violations |

## Smoke Test (Complexity 3)

- 126 formulas, 11 valid, 31 unique steps
- Valid JSONL output confirmed

## 100K Step Target Assessment

The 100K step target from the research report was optimistic. Analysis:
- At complexity 5: ~1,400 unique steps (with wrapping)
- Extrapolating to complexity 7 (~50K formulas, ~1,700 valid, x10 depths): ~20,000-30,000 steps
- The bottleneck is that most valid formulas at low complexity are simple axiom instances (1-3 steps)
- To reach 100K: need complexity 9+ or significantly larger seed pools, which requires extended runtime

The pipeline architecture supports scaling to higher complexity via CLI parameters without code changes.

## Rule Coverage Analysis

| Rule | Present | Why |
|------|---------|-----|
| axiom | Yes | Core of all proofs |
| modus_ponens | Yes | Used in non-trivial proofs |
| temporal_necessitation | Yes | From G^n wrapping |
| assumption | No | Requires non-empty context proofs |
| weakening | No | Requires non-empty context proofs |
| necessitation | No | Requires box-level proof composition |
| temporal_duality | No | Requires H-wrapping (could be added) |

## Pre-existing Build Issue

`Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` has pre-existing compilation errors (from tasks 240/259) that prevent a clean `lake build` from completing. These errors are in a transitive dependency of `DecisionProcedure` and are unrelated to this task. When build cache is available (from prior builds), the pipeline compiles and runs successfully. The executable was built and tested successfully multiple times during development.

## Plan Deviations

- **Phase 2, Task 2.1**: `processFormula` signature altered to `Formula -> String -> Option (List ProofStep)` (pure function taking name directly, not index)
- **Phase 3, Task 3.1**: `writeProofStepsJSONL` takes `Array ProofStep` instead of `List` for performance
- **Phase 3, Task 3.5**: Registry merge skipped; existing `lake exe proof_extractor` provides registry steps independently
- **Phase 4, Task 4.3**: Module import in `Automation.lean` skipped; module defines `main` and should not be imported through the umbrella (consistent with all other `lean_exe` targets)
- **Phase 5, Task 5.1**: Full c7 run validated at c5 instead; c7 takes 36+ minutes runtime
- **Phase 5, Task 5.7**: Parameter tuning for 100K deferred; pipeline supports configurable parameters for future scaling

## Files Modified

- `Theories/Bimodal/Automation/TableauProofStepPipeline.lean` -- **New** (660 lines)
- `lakefile.lean` -- Added `lean_exe tableau_proof_steps` target (6 lines)
