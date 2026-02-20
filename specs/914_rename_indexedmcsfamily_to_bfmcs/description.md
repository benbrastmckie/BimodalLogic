# Task 914: Rename IndexedMCSFamily to BFMCS across codebase

## Objective

Rename `IndexedMCSFamily` to `BFMCS` (Bundled Family of Maximal Consistent Sets) throughout the codebase to make the two-level ontological structure explicit.

## Rationale

The current naming obscures the proof architecture. The completeness proof has a two-level bundling structure:

```
BMCS  =  { BFMCS₁, BFMCS₂, ... }     -- modal bundle (possible worlds)
BFMCSᵢ = { MCS_t | t ∈ ℤ }            -- temporal family (one world history)
```

Each `IndexedMCSFamily` is itself a **bundled family** of MCSes — it bundles one MCS per time point into a temporally coherent chain representing a single world history. The name "IndexedMCSFamily" is too generic and doesn't communicate this. "BFMCS" makes it clear that:

1. Each BFMCS is a **bundled** collection (of time-indexed MCSes)
2. The bundling has **temporal coherence** constraints (G/H propagation, F/P witnesses)
3. The full canonical model (BMCS) is a **bundle of BFMCSes** — a second level of bundling with **modal coherence** constraints

## Scope

420 occurrences across 38 files:

### Active source files (priority)
- `IndexedMCSFamily.lean` — definition file (14 occurrences), rename file to `BFMCS.lean`
- `BMCS.lean` — references BFMCS as component (11 occurrences)
- `BMCSTruth.lean` — truth evaluation (31 occurrences)
- `CoherentConstruction.lean` — construction (80 occurrences)
- `SaturatedConstruction.lean` — saturation (43 occurrences)
- `WeakCoherentBundle.lean` — weak bundle (34 occurrences)
- `Construction.lean` — main construction (20 occurrences)
- `TemporalCoherentConstruction.lean` — temporal coherence (14 occurrences)
- `TruthLemma.lean` — truth lemma (11 occurrences)
- `RecursiveSeed.lean` — seed construction (10 occurrences)
- `ModalSaturation.lean` — modal saturation (9 occurrences)
- `FinalConstruction.lean` — final assembly (9 occurrences)
- `ZornFamily.lean` — Zorn construction (8 occurrences)
- `SeedBMCS.lean` — seed BMCS (8 occurrences)
- `DovetailingChain.lean` — dovetailing chain (6 occurrences)
- Plus 12 other files with 1-5 occurrences each

### Boneyard files (lower priority)
- `Metalogic_v5/Representation/` files — older versions
- `Metalogic_v3/` and `Metalogic_v2/` files

### Documentation
- `README.md` files in Metalogic directories
- `04-Metalogic.tex` (LaTeX)
- `04-metalogic.typ` (Typst)

## Approach

1. Rename the structure definition in `IndexedMCSFamily.lean`
2. Rename the file to `BFMCS.lean` (update all imports)
3. Use find-and-replace across all active files
4. Update all doc comments to explain the BFMCS ontology
5. Update Boneyard files for consistency
6. Verify build passes

## Language
lean
