# Research Report: Task #523 (Revision 3)

**Task**: 523 - Clean Up Bimodal Lean Source Files After Task 505
**Date**: 2026-01-17
**Focus**: Improved Bimodal/Metalogic/ directory structure supporting ideal proof dependency tree with representation theorem as foundation
**Session ID**: sess_1768657879_19f5ce

## Summary

This research proposes a restructured Bimodal/Metalogic/ directory that places the Representation Theorem at the foundation, from which Completeness, Decidability, and Compactness all derive. The proposed structure supports clean proof dependencies, eliminates circular imports, and ensures decidability is properly included in the architecture (currently missing from research-002.md). The key insight is that FMP (Finite Model Property) should be the central bridge between the Representation Theorem and all downstream metalogical results.

## Findings

### 1. Current State Analysis

#### 1.1 Existing Directory Structure
```
Metalogic/
├── Core/
│   ├── Basic.lean              # Consistent, Valid, MaximalConsistent, FinitelyConsistent
│   └── Provability.lean        # Context-based provability
├── Soundness/
│   ├── Soundness.lean          # Main soundness theorem (670 lines)
│   └── SoundnessLemmas.lean    # Supporting lemmas (932 lines)
├── Representation/
│   ├── CanonicalModel.lean     # MCS, canonical frame/model construction
│   ├── TruthLemma.lean         # Truth lemma details
│   ├── RepresentationTheorem.lean  # Main representation theorem
│   ├── FiniteModelProperty.lean    # FMP bridge (scaffolding)
│   └── ContextProvability.lean     # Context provability infrastructure
├── Completeness/
│   ├── CompletenessTheorem.lean    # Derives completeness from representation
│   └── FiniteCanonicalModel.lean   # Finite model construction (4288 lines, proven semantic completeness)
├── Applications/
│   └── Compactness.lean        # Compactness theorem (scaffolding)
├── Decidability/               # (8 submodules)
│   ├── SignedFormula.lean
│   ├── Tableau.lean
│   ├── Closure.lean
│   ├── Saturation.lean
│   ├── ProofExtraction.lean
│   ├── CountermodelExtraction.lean
│   ├── DecisionProcedure.lean
│   └── Correctness.lean
├── Completeness.lean           # Legacy (3719 lines, deprecated)
├── DeductionTheorem.lean
└── Decidability.lean           # Module hub
```

#### 1.2 Current Proof Dependencies (Implicit)
```
               Soundness
                   ↑
    DeductionTheorem   Core/Basic
          ↑               ↑
          └───────┬───────┘
                  ↓
         Representation/
         CanonicalModel
                  ↓
      Representation/TruthLemma
                  ↓
    Representation/RepresentationTheorem
                  ↓
    ┌─────────────┼─────────────┐
    ↓             ↓             ↓
Completeness  Decidability  Compactness
    ↑                           ↑
    └───────────────────────────┘
         (circular risk!)
```

#### 1.3 Problems with Current Structure

1. **Decidability not properly rooted in FMP**: The Decidability module is isolated and doesn't connect to the Representation/FMP infrastructure.

2. **Circular dependency risk**: Completeness and Compactness both reference each other in comments and may create import cycles.

3. **Missing FMP as central bridge**: The Finite Model Property should be the key result that enables both decidability AND completeness, but it's currently buried as a scaffolding file.

4. **Redundant FiniteCanonicalModel.lean**: At 4288 lines, this file duplicates work that should flow from the representation theorem.

5. **Decidability/Correctness.lean has FMP dependency noted but not implemented**: Line 77 notes "Requires FMP and tableau completeness proof" but no import exists.

### 2. Ideal Proof Dependency Tree

Based on standard metalogic for modal/temporal logics, the ideal dependency structure is:

```
                    ┌───────────────────┐
                    │   FOUNDATIONAL    │
                    │   (Soundness)     │
                    └─────────┬─────────┘
                              │
            ┌─────────────────┼─────────────────┐
            ↓                 ↓                 ↓
     DeductionTheorem    Core/Basic    Core/Provability
            ↓                 ↓                 ↓
            └─────────────────┼─────────────────┘
                              ↓
                 ┌────────────────────────┐
                 │  REPRESENTATION LAYER  │
                 │                        │
                 │  CanonicalModel.lean   │
                 │  TruthLemma.lean       │
                 │  RepresentationThm.lean│
                 └────────────┬───────────┘
                              │
                              ↓
                 ┌────────────────────────┐
                 │  FINITE MODEL PROPERTY │
                 │                        │
                 │  (Central Bridge)      │
                 │  FMP.lean              │
                 └────────────┬───────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ↓                     ↓                     ↓
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│ COMPLETENESS  │    │ DECIDABILITY  │    │  COMPACTNESS  │
│               │    │               │    │               │
│ WeakComplete  │    │ DecidableValid│    │ FiniteSat→Sat│
│ StrongComplete│    │ DecisionProc  │    │               │
└───────────────┘    └───────────────┘    └───────────────┘
```

**Key Principle**: FMP is the central result that enables all three downstream theorems:
- **Completeness**: FMP ensures canonical model is finite, truth lemma works
- **Decidability**: FMP bounds search space, enables termination
- **Compactness**: FMP enables reduction to finite satisfiability

### 3. Proposed Hierarchical Metalogic Structure

```
Metalogic/
├── Core/                           # Foundation definitions
│   ├── Basic.lean                  # Consistency, Validity definitions
│   ├── Provability.lean            # ContextDerivable, derivation trees
│   └── README.md                   # Core concepts documentation
│
├── Soundness/                      # Direction: Derivable → Valid
│   ├── Soundness.lean              # Main theorem
│   ├── SoundnessLemmas.lean        # Supporting lemmas
│   └── README.md                   # Soundness strategy documentation
│
├── Representation/                 # THE CENTRAL LAYER
│   ├── CanonicalModel.lean         # MCS, canonical frame construction
│   ├── TruthLemma.lean             # φ ∈ Γ ↔ M,Γ ⊨ φ
│   ├── RepresentationTheorem.lean  # Consistent → Satisfiable
│   ├── FiniteModelProperty.lean    # *** KEY: Satisfiable → Finite-Satisfiable ***
│   └── README.md                   # Architecture documentation
│
├── Completeness/                   # Direction: Valid → Derivable (from FMP)
│   ├── WeakCompleteness.lean       # ⊨ φ → ⊢ φ
│   ├── StrongCompleteness.lean     # Γ ⊨ φ → Γ ⊢ φ
│   └── README.md                   # Completeness strategy
│
├── Decidability/                   # FMP → Decidable (from FMP)
│   ├── Core/
│   │   ├── SignedFormula.lean      # Signed formula types
│   │   └── Branch.lean             # Branch/Tableau types
│   ├── Tableau/
│   │   ├── Rules.lean              # Expansion rules
│   │   ├── Closure.lean            # Closure detection
│   │   └── Saturation.lean         # Saturation check
│   ├── Extraction/
│   │   ├── ProofExtraction.lean    # Closed → Proof
│   │   └── CountermodelExtraction.lean  # Open → Countermodel
│   ├── DecisionProcedure.lean      # Main decide function
│   ├── Correctness.lean            # Sound + Complete (from FMP)
│   └── README.md                   # Decision procedure docs
│
├── Compactness/                    # From FMP
│   ├── Compactness.lean            # Main theorem
│   └── README.md                   # Compactness applications
│
├── DeductionTheorem.lean           # Proof-theoretic tool
│
├── Boneyard/                       # Deprecated code preservation
│   ├── SyntacticFiniteModel.lean   # Old syntactic approach
│   ├── DurationConstruction.lean   # Old Duration-based approach
│   └── README.md                   # Deprecation reasons
│
└── README.md                       # Master architecture documentation
```

### 4. Dependency Graph (Imports)

```lean
-- Core (no metalogic dependencies)
Core/Basic.lean       → Bimodal.ProofSystem, Bimodal.Semantics
Core/Provability.lean → Core/Basic

-- Soundness (independent of completeness)
Soundness/Soundness.lean       → Core/Basic, Bimodal.Semantics
Soundness/SoundnessLemmas.lean → Soundness/Soundness

-- Representation (depends on Core, not on Soundness)
Representation/CanonicalModel.lean      → Core/Basic, Core/Provability
Representation/TruthLemma.lean          → Representation/CanonicalModel
Representation/RepresentationTheorem.lean → Representation/TruthLemma
Representation/FiniteModelProperty.lean  → Representation/RepresentationTheorem

-- Completeness (from FMP)
Completeness/WeakCompleteness.lean   → Representation/FiniteModelProperty, Soundness/Soundness
Completeness/StrongCompleteness.lean → Completeness/WeakCompleteness

-- Decidability (from FMP)
Decidability/Correctness.lean → Representation/FiniteModelProperty
                              → Decidability/DecisionProcedure

-- Compactness (from FMP)
Compactness/Compactness.lean → Representation/FiniteModelProperty
                             → Completeness/WeakCompleteness  -- optional
```

### 5. Critical Design Principles

#### 5.1 FMP as the Bridge
The Finite Model Property is the central theorem that enables everything downstream:

```lean
-- In FiniteModelProperty.lean
theorem finite_model_property {φ : Formula} :
    satisfiable φ → ∃ (M : FiniteModel), M.card ≤ 2^(φ.complexity) ∧ M ⊨ φ

-- This enables:
-- 1. Completeness: Finite truth lemma is straightforward
-- 2. Decidability: Bounded search space for tableau
-- 3. Compactness: Reduction to finite satisfiability
```

#### 5.2 Semantic vs Syntactic Separation
The semantic approach (proven in FiniteCanonicalModel.lean) should be canonical:

```lean
-- Semantic: φ ∈ MCS(Γ) ↔ SemanticModel,Γ ⊨ φ  (PROVEN, use this)
-- Syntactic: Build finite model directly from syntax (DEPRECATED, move to Boneyard)
```

#### 5.3 Import Discipline
```
        Core
         ↓
     Soundness ← → Representation
                     ↓
                    FMP
                     ↓
    ┌────────────────┼────────────────┐
    ↓                ↓                ↓
Completeness    Decidability    Compactness
```

No imports from Completeness/Decidability/Compactness back to Representation.

### 6. Refactoring Actions

#### Phase 1: Create FMP-Centric Structure (2-3 hours)

1. **Elevate FiniteModelProperty.lean** to be the central result:
   - Move from `Representation/` to its own prominent location OR
   - Ensure it's clearly the bridge imported by all downstream

2. **Connect Decidability/Correctness.lean to FMP**:
   ```lean
   import Bimodal.Metalogic.Representation.FiniteModelProperty

   theorem decide_complete (φ : Formula) (hvalid : ⊨ φ) :
       ∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof := by
     have h_fmp := finite_model_property
     -- Use FMP to bound search space
     ...
   ```

3. **Create explicit Compactness module** (rename Applications/):
   ```
   Compactness/
   ├── Compactness.lean          # Main theorem
   └── Applications.lean         # Corollaries (Los-Tarski, etc.)
   ```

#### Phase 2: Clean FiniteCanonicalModel.lean (3-4 hours)

1. **Extract proven semantic results** to Representation/:
   - `semantic_truth_lemma_v2` → `Representation/TruthLemma.lean`
   - `semantic_weak_completeness` → `Completeness/WeakCompleteness.lean`

2. **Move deprecated syntactic approach** to Boneyard:
   - Lines 800-1900 (FiniteWorldState, finite_task_rel)
   - Document deprecation reasons

3. **Reduce file to essential finite model construction**:
   - SemanticWorldState definition
   - Finite bounds theorem
   - Bridge lemmas to FMP

#### Phase 3: Documentation (1-2 hours)

1. **Create Metalogic/README.md** with:
   - Architecture diagram showing FMP centrality
   - Module hierarchy
   - Dependency graph
   - Theorem inventory

2. **Update each subdirectory README.md** with:
   - Module purpose
   - Key theorems
   - Import requirements
   - Status (proven vs scaffolding)

### 7. Key Theorems by Module

| Module | Theorem | Status | Dependencies |
|--------|---------|--------|--------------|
| **Core/Basic** | `Consistent`, `Valid` | Definitions | None |
| **Soundness** | `soundness : Γ ⊢ φ → Γ ⊨ φ` | PROVEN | Core |
| **Representation/CanonicalModel** | `lindenbaum`, `canonical_frame` | Proven | Core |
| **Representation/TruthLemma** | `truth_lemma : φ ∈ Γ ↔ M,Γ ⊨ φ` | PROVEN | CanonicalModel |
| **Representation/RepresentationThm** | `representation_theorem` | Scaffolding | TruthLemma |
| **Representation/FMP** | `finite_model_property` | CRITICAL | RepresentationThm |
| **Completeness/Weak** | `weak_completeness : ⊨ φ → ⊢ φ` | PROVEN | FMP |
| **Completeness/Strong** | `strong_completeness : Γ ⊨ φ → Γ ⊢ φ` | Scaffolding | WeakCompleteness |
| **Decidability** | `validity_decidable : Decidable (⊨ φ)` | Partial | FMP |
| **Compactness** | `compactness` | Scaffolding | FMP |

### 8. Why This Structure is Ideal

1. **Clear dependency hierarchy**: Each module imports only from layers above it.

2. **FMP as pivot point**: All advanced metalogical results derive from FMP.

3. **No circular dependencies**: Strict import discipline prevents cycles.

4. **Modular verification**: Each layer can be verified independently.

5. **Decidability properly grounded**: Decision procedure correctness derives from FMP bounds.

6. **Historical separation**: Boneyard keeps deprecated approaches without cluttering main code.

7. **Extensibility**: Adding new results (interpolation, conservativity) follows same pattern.

## Recommendations

### Immediate Actions

1. **Verify FMP proof status**: If `finite_model_property` in `Representation/FiniteModelProperty.lean` has sorries, prioritize proving it.

2. **Connect Decidability to FMP**: Add import and complete `tableau_complete` and `decide_complete` using FMP bounds.

3. **Create master README**: Document the FMP-centric architecture.

### Medium-term Actions

1. **Extract semantic_weak_completeness**: Move proven theorem from FiniteCanonicalModel.lean to Completeness/WeakCompleteness.lean.

2. **Deprecate syntactic approach**: Move ~1000 lines to Boneyard.

3. **Unify completeness theorems**: Ensure all completeness variants derive from the single proven `semantic_weak_completeness`.

### Architecture Principles to Maintain

1. **FMP is central**: All downstream metalogical results must import and use FMP.

2. **Semantic > Syntactic**: Prefer the proven semantic approach.

3. **Single source of truth**: One proven theorem per concept, others derive from it.

4. **Clean imports**: No cycles, no import from downstream to upstream.

## Conclusion

The key insight of this research is that the **Finite Model Property should be the central bridge** in the Bimodal metalogic architecture. The current structure partially implements this but:

1. Decidability is isolated from FMP
2. Multiple overlapping completeness theorems exist
3. Historical commentary and deprecated code clutters the proven results

The proposed restructuring:
- Places FMP as the explicit bridge between Representation and {Completeness, Decidability, Compactness}
- Ensures clean proof dependencies with no cycles
- Properly includes decidability in the metalogical architecture
- Separates proven results from scaffolding and deprecated code

**Estimated Cleanup Effort**: 6-9 hours across 3 phases
**Risk Level**: Low (mostly moving/renaming, not changing proofs)
**Expected Benefits**: Clear architecture, proper decidability grounding, maintainable codebase

## Next Steps

Run `/plan 523` to create implementation plan for restructuring activities.
