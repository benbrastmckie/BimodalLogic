# Phase 1 Handoff: Lean Axiom Instance Generator

**Completed**: 2026-05-29
**Next action**: Phase 2 - Python Curation Script

## Key Decisions

- Used `flatMap` instead of `bind` for List operations (Lean 4 convention)
- Imported `DataExport` instead of `DatasetExport` to avoid `main` symbol conflict
- Substitution vocabulary: 8 terms for 1-param, 5 for 2-param (smallVocab), 3 for 3/4-param (tinyVocab)
- All 42 axiom constructors covered

## Current State

- `BenchmarkAnchors.lean` compiles and runs as `lake exe benchmark_anchors`
- Output: `data/axiom-instances.jsonl` with 724 records
- 118 valid, 543 invalid, 63 timeout
- Many temporal axiom instances timeout because decision procedure fuel is limited for complex formulas
- Data file is gitignored; only source files committed

## Deviations

None. Implementation followed plan.
