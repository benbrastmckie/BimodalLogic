# Task 172: Metalogic.lean Docstring Audit

## Scope

Two files contain stale docstrings that need rewriting:

1. **`Theories/Bimodal/Metalogic.lean`** (top-level aggregator, lines 6-65)
2. **`Theories/Bimodal/Metalogic/Metalogic.lean`** (inner re-export module, lines 7-88)

Both docstrings are severely stale, referencing dead architecture, nonexistent files, and incorrect semantics descriptions.

---

## File 1: `Theories/Bimodal/Metalogic.lean` (Top-Level Aggregator)

### Stale Reference Inventory

| Line | Stale Content | Problem |
|------|--------------|---------|
| 18 | `Completeness \| IN PROGRESS \| BXCanonical architecture` | Status is misleading. Completeness theorem exists but has sorry dependencies. Should say "SORRY (chronicle construction)" |
| 26 | `bmcs_truth_lemma: Truth lemma for BFMCS (Bundle/TruthLemma.lean)` | **`Bundle/TruthLemma.lean` does not exist.** The theorem `bmcs_truth_lemma` also does not exist. The live truth lemma is in `BXCanonical/TruthLemma.lean` and `WeakCanonical/TruthLemma.lean` |
| 45 | `BXCanonical/: Reflexive BX completeness architecture (active)` | Says "Reflexive" but project uses **irreflexive** semantics (task 93). Should say "irreflexive" or omit the qualifier |
| 64 | `SuccChain/: Successor chain completeness (active development)` | **`Metalogic/SuccChain/` directory does not exist.** SuccChain was dead code; the relevant files were `Bundle/SuccChainFMCS.lean`, etc., which also no longer exist |

### What Needs Fixing

1. Remove reference to `bmcs_truth_lemma` and `Bundle/TruthLemma.lean`
2. Remove "Reflexive" from BXCanonical description
3. Remove SuccChain reference entirely
4. Update status table to reflect actual sorry status
5. Add references to the actual live modules: `BXCanonical/Chronicle/`, `WeakCanonical/`, `Algebraic/`

---

## File 2: `Theories/Bimodal/Metalogic/Metalogic.lean` (Inner Re-Export)

This file is **far more severely stale** and contains extensive fabricated file listings.

### Stale Reference Inventory

| Line | Stale Content | Problem |
|------|--------------|---------|
| 12-16 | "Reflexive G/H Semantics" section | **Completely wrong.** Project uses irreflexive semantics (task 93). G/H quantify over strictly future/past times (< not <=). The docstring says "REFLEXIVE" and claims `canonicalR_reflexive` is proven via T-axiom. |
| 25 | `Base Completeness \| base_truth_lemma \| SORRY-FREE` | **`base_truth_lemma` does not exist** as a declaration. |
| 26-27 | Dense/Discrete Completeness rows | Status descriptions are vague. Should precisely reference the sorry chain. |
| 32-36 | "SuccChain architecture" section | **Dead architecture.** None of these files exist: `Bundle/SuccChainFMCS.lean`, `Bundle/SuccChainTaskFrame.lean`, `Bundle/SuccChainTruth.lean`, `Bundle/SuccChainWorldHistory.lean`, `Completeness/SuccChainCompleteness.lean` |
| 57 | `CanonicalConstruction.lean` | **Does not exist** (also misspelled: "Constru*c*tion") |
| 67-70 | SuccChain file listings | All 4 files nonexistent |
| 73 | `Completeness/SuccChainCompleteness.lean` | Does not exist. There is no `Completeness/` subdirectory. |
| 82 | `BaseCompleteness.lean` | Does not exist (archived to `Boneyard/StrictSemanticsLegacy/`) |
| 83 | `DenseCompleteness.lean` | Does not exist (archived to `Boneyard/StrictSemanticsLegacy/`) |
| 84 | `DiscreteCompleteness.lean` | Does not exist (archived to `Boneyard/StrictSemanticsLegacy/`) |
| 85 | `Representation.lean` | Does not exist |

### Files Listed That Don't Exist (Total: 11)

1. `Bundle/CanonicalConstruction.lean` (misspelled, nonexistent)
2. `Bundle/SuccChainFMCS.lean`
3. `Bundle/SuccChainTaskFrame.lean`
4. `Bundle/SuccChainTruth.lean`
5. `Bundle/SuccChainWorldHistory.lean`
6. `Completeness/SuccChainCompleteness.lean`
7. `BaseCompleteness.lean`
8. `DenseCompleteness.lean`
9. `DiscreteCompleteness.lean`
10. `Representation.lean`
11. `Decidability/` listed without `FMP/` subdirectory

### Files That Exist But Are NOT Listed

1. `Algebraic/` (entire directory -- 13 files, including the parametric completeness path)
2. `BXCanonical/Chronicle/` (6 files -- the primary dense completeness path)
3. `BXCanonical/Filtration/` (2 files)
4. `BXCanonical/Quasimodel/` (6 files)
5. `WeakCanonical/` (entire directory -- 15+ files, the Reynolds/Doets discrete path)
6. `ConservativeExtension/` (4 files)
7. `DenseSoundness.lean`
8. `DiscreteSoundness.lean`
9. `Decidability/FMP/` (6 files -- finite model property)

---

## Current Architecture (Ground Truth)

### Semantics

The project uses **irreflexive temporal semantics** (task 93):
- G/H quantify over **strictly** future/past times (< not <=)
- Until/Since use strict witness with open guard
- T-axioms (Gp -> p, Hp -> p) are **NOT** temporal axioms; they are **modal** axioms only
- The canonical temporal relation is **irreflexive**

### Completeness Architecture

Three parallel approaches exist:

1. **BXCanonical/Chronicle/** (Burgess 1982 chronicle construction)
   - Primary path for dense completeness (`countermodel_dense`)
   - Uses `Rat` as the domain via Cantor isomorphism
   - `completeness` theorem wired through this path
   - **Sorry status**: ~5 sorry sites in `ChronicleToCountermodel.lean` (succ_cofinal, density g-value consistency, mixed case)

2. **WeakCanonical/** (Reynolds/Doets discrete completeness)
   - Primary path for discrete completeness (`countermodel_discrete`)
   - Uses `Int` as the domain
   - Currently delegates to chronicle construction as interim fallback
   - **Sorry status**: Multiple sorry sites in Transfer.lean, IntegerModel.lean, TruthLemma.lean (U/S cases)

3. **Algebraic/** (D-parametric algebraic completeness)
   - Provides parametric truth lemma over arbitrary duration type D
   - Used by Chronicle path for the actual countermodel construction
   - `ParametricCompleteness.lean` provides the main parametric theorem

### Sorry Status Summary

| Component | Theorem | Status |
|-----------|---------|--------|
| **Soundness** | `soundness` | SORRY-FREE |
| **Soundness (dense)** | `soundness_dense` | SORRY-FREE |
| **Soundness (discrete)** | `soundness_discrete` | SORRY-FREE |
| **Completeness** | `completeness` | SORRY (via chronicle construction: ~5 leaf sorry sites) |
| **Completeness (dense)** | `completeness_dense` | SORRY (inherits chronicle + frame-class theory) |
| **Completeness (discrete)** | `completeness_discrete` | SORRY (inherits discrete pipeline + frame-class theory) |
| **Decidability** | `decide` | SORRY-FREE |

### Module Structure (Actual)

```
Metalogic/
├── Core/                        # MCS theory, deduction theorem
│   ├── MaximalConsistent.lean
│   ├── MCSProperties.lean
│   ├── DeductionTheorem.lean
│   └── RestrictedMCS.lean
├── Bundle/                      # BFMCS infrastructure
│   ├── FMCS.lean, FMCSDef.lean, BFMCS.lean
│   ├── Construction.lean
│   ├── CanonicalFrame.lean, CanonicalTaskRelation.lean
│   ├── CanonicalIrreflexivity.lean
│   ├── TemporalCoherence.lean, TemporalContent.lean
│   ├── UntilSinceCoherence.lean
│   ├── ModalSaturation.lean, WitnessSeed.lean
│   ├── SuccRelation.lean, SuccExistence.lean
├── Algebraic/                   # D-parametric algebraic completeness
│   ├── LindenbaumQuotient.lean, BooleanStructure.lean
│   ├── InteriorOperators.lean, UltrafilterMCS.lean
│   ├── AlgebraicCompleteness.lean, TenseS5Algebra.lean
│   ├── ParametricCanonical.lean, ParametricHistory.lean
│   ├── ParametricTruthLemma.lean, ParametricCompleteness.lean
│   ├── RestrictedParametricTruthLemma.lean
│   └── UltrafilterFrame.lean
├── BXCanonical/                 # Completeness theorem and chronicle construction
│   ├── BXCanonical.lean, Completeness.lean
│   ├── CanonicalChain.lean, CanonicalModel.lean
│   ├── Frame.lean, TruthLemma.lean
│   ├── RootScopedChain.lean (dead code)
│   ├── OrderedSeedConsistency.lean
│   ├── Chronicle/               # Burgess chronicle (primary dense path)
│   │   ├── ChronicleTypes.lean, ChronicleConstruction.lean
│   │   ├── ChronicleToCountermodel.lean
│   │   ├── CounterexampleElimination.lean
│   │   ├── PointInsertion.lean, RRelation.lean
│   ├── Filtration/              # Sigma ordering, defect chains
│   └── Quasimodel/             # Hintikka points, enriched closure
├── WeakCanonical/               # Reynolds/Doets discrete completeness
│   ├── WeakCanonical.lean, ReflexiveCanonical.lean
│   ├── TruthLemma.lean, FrameProperties.lean
│   ├── ChronicleExtraction.lean
│   ├── NEquivalence.lean, NormalForm.lean, MonadicFO.lean
│   ├── OrderedSum.lean, Table.lean
│   ├── IntegerModel.lean, Transfer.lean
│   ├── ExpressiveCompleteness.lean
│   └── Separation/             # Separation theorem (11 files)
├── ConservativeExtension/       # Conservative extension results
├── Decidability/                # Tableau decision procedure (sorry-free)
│   ├── FMP/                     # Finite model property (6 files)
│   └── ...                      # SignedFormula, Tableau, Closure, etc.
├── Soundness.lean               # Soundness theorem (sorry-free)
├── SoundnessLemmas.lean
├── DenseSoundness.lean
├── DiscreteSoundness.lean
├── Completeness.lean            # MCS properties for completeness
└── Decidability.lean            # Decidability interface
```

---

## Dead Code / Boneyard Candidates

### Already in Boneyard

The following have already been archived:
- `Boneyard/StrictSemanticsLegacy/BaseCompleteness.lean`
- `Boneyard/StrictSemanticsLegacy/DenseCompleteness.lean`
- `Boneyard/StrictSemanticsLegacy/DiscreteCompleteness.lean`
- `Boneyard/DefectDirectedChain/RootScopedChain.lean`
- Various other legacy constructions

### Candidates for Boneyard

1. **`BXCanonical/RootScopedChain.lean`** -- Explicitly documented as dead code in `BXCanonical/Completeness.lean`. Has 3 sorry sites that are no longer on the critical path. The chronicle construction bypasses it entirely.

2. **`BXCanonical/Quasimodel/Realization.lean`** -- Contains 4 sorry sites with a note that "sorry root cause analysis has been moved." Check if any live code imports it.

3. **`Relational/` directory** -- Empty placeholder with only a README.md. Could be deleted or kept as a placeholder.

### References to Remove from Docstrings

- All SuccChain references (dead architecture, files deleted)
- "Reflexive G/H Semantics" section (wrong -- irreflexive)
- `bmcs_truth_lemma` reference (nonexistent theorem)
- `Bundle/TruthLemma.lean` reference (nonexistent file)
- All 11 nonexistent file paths in the module structure diagram

---

## Proposed Replacement Docstring: `Theories/Bimodal/Metalogic.lean`

```lean
/-!
# Bimodal.Metalogic - Soundness, Completeness, and Decidability

Aggregates all metalogic components for bimodal logic TM (Tense and Modality). Provides
the foundational metalogical results: soundness, completeness, and tableau-based decision
procedures.

## Main Results

| Component | Status | Key Theorem |
|-----------|--------|-------------|
| Soundness | SORRY-FREE | `soundness`, `soundness_dense`, `soundness_discrete` |
| Completeness | SORRY (chronicle) | `completeness` (BXCanonical/Completeness.lean) |
| Decidability | SORRY-FREE | `decide` (Decidability/DecisionProcedure.lean) |

## Publication-Ready Theorems

The following theorems are sorry-free with zero custom axioms:

- `soundness`: If Gamma derives phi (dense-compatible), then phi is valid
- `soundness_dense`: Dense-frame-specific soundness
- `soundness_discrete`: Discrete-frame-specific soundness
- `decide`: Tableau-based decision procedure with proof/countermodel extraction

## Axiom Dependencies

Standard Lean axioms only (no custom axioms on publication path):
- `propext`: Propositional extensionality
- `Classical.choice`: Classical choice
- `Quot.sound`: Quotient soundness
- `Lean.ofReduceBool`, `Lean.trustCompiler`: Compiler primitives (from `native_decide`)

## Submodules

- `SoundnessLemmas`: Bridge theorems connecting syntax and semantics
- `Soundness`: Main soundness theorem with proofs for all axioms and rules
- `Completeness`: MCS properties (disjunction, conjunction, modal closure)
- `Decidability`: Tableau-based decision procedure with proof/countermodel extraction
- `BXCanonical/`: Completeness architecture (Chronicle/Burgess construction)
- `WeakCanonical/`: Reynolds/Doets discrete completeness path
- `Algebraic/`: D-parametric algebraic completeness and truth lemma

## References

* [Soundness.lean](Metalogic/Soundness.lean) - Soundness proof
* [BXCanonical/Completeness.lean](Metalogic/BXCanonical/Completeness.lean) - Completeness theorem
* [Decidability.lean](Metalogic/Decidability.lean) - Decision procedure
-/
```

## Proposed Replacement Docstring: `Theories/Bimodal/Metalogic/Metalogic.lean`

```lean
/-!
# Bimodal Metalogic

This module re-exports the metalogical foundations for bimodal logic TM:
soundness, completeness, and decidability.

## Irreflexive Temporal Semantics

Under irreflexive semantics (task 93), G and H quantify over strictly future/past
times (s > t and s < t respectively, excluding the current time). Until uses strict
witness (s > t) with open guard (t, s). Since uses strict witness (s < t) with open
guard (s, t).

The modal T-axiom (Box phi -> phi) is valid (S5 universal accessibility), but the
temporal analogs (G phi -> phi, H phi -> phi) are NOT valid under irreflexive semantics.

## Publication-Ready Results

| Result | Theorem | Status |
|--------|---------|--------|
| **Soundness** | `soundness` | SORRY-FREE |
| **Soundness (dense)** | `soundness_dense` | SORRY-FREE |
| **Soundness (discrete)** | `soundness_discrete` | SORRY-FREE |
| **Completeness** | `completeness` | SORRY (chronicle construction) |
| **Completeness (dense)** | `completeness_dense` | SORRY (chronicle + frame-class theory) |
| **Completeness (discrete)** | `completeness_discrete` | SORRY (discrete pipeline + frame-class theory) |
| **Decidability** | `decide` | SORRY-FREE |

## Completeness Architecture

The completeness proof uses a three-way case split based on MCS membership:

1. **Dense case** (Box(F'T) in M): Countermodel on Rat via Cantor isomorphism
   (Chronicle/ChronicleToCountermodel.lean, Algebraic/ParametricCompleteness.lean)
2. **Discrete case** (Box(U(T,bot)) in M): Countermodel on Int
   (WeakCanonical/Transfer.lean)
3. **Mixed case**: Eliminated by `mcs_mixed_case_absurd` (task 142)

### Key Components

- **Algebraic/ParametricTruthLemma**: D-parametric truth lemma (core of countermodel)
- **BXCanonical/Chronicle/**: Burgess 1982 chronicle construction for dense case
- **WeakCanonical/**: Reynolds/Doets pipeline for discrete case
- **Bundle/**: BFMCS infrastructure (shared by all paths)

## Axiom Dependencies

Standard Lean axioms only on publication path:
- `propext`, `Classical.choice`, `Quot.sound`

## Module Structure

```
Metalogic/
├── Core/                        # MCS theory, deduction theorem
├── Bundle/                      # BFMCS infrastructure
├── Algebraic/                   # D-parametric algebraic completeness
├── BXCanonical/                 # Completeness theorem
│   ├── Chronicle/               # Burgess chronicle (dense path)
│   ├── Filtration/              # Sigma ordering
│   └── Quasimodel/             # Hintikka points, enriched closure
├── WeakCanonical/               # Reynolds/Doets discrete completeness
│   └── Separation/             # Separation theorem
├── ConservativeExtension/       # Conservative extension results
├── Decidability/                # Tableau decision procedure
│   └── FMP/                     # Finite model property
├── Soundness.lean               # Soundness (sorry-free)
├── SoundnessLemmas.lean         # Soundness helpers
├── DenseSoundness.lean          # Dense soundness (sorry-free)
├── DiscreteSoundness.lean       # Discrete soundness (sorry-free)
├── Completeness.lean            # MCS properties for completeness
└── Decidability.lean            # Decidability interface
```
-/
```

---

## Implementation Guidance

### Changes Required

1. **Replace docstring in `Theories/Bimodal/Metalogic.lean`** (lines 6-65) with proposed text
2. **Replace docstring in `Theories/Bimodal/Metalogic/Metalogic.lean`** (lines 7-88) with proposed text
3. No code changes needed -- only doc comments

### Dead Code Actions (Optional, Could Be Separate Task)

- `BXCanonical/RootScopedChain.lean`: Consider archiving to Boneyard (3 dead sorry sites)
- `Relational/`: Empty placeholder directory, consider removing
- SuccChain references in Bundle/ files (lines in FMCSDef.lean:20, SuccExistence.lean:364, etc.) are in comments only and can be left as historical context

### Verification

After implementation, run `lake build` to confirm no compilation impact (docstring-only changes should be safe).
