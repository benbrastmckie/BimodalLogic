# Research Report: Task #750

**Task**: Refactor the metalogic architecture to achieve completeness from the algebraic representation theorem and decidability via FMP
**Date**: 2026-01-29
**Focus**: Ideal metalogic architecture with dependency flow charts, grounded in what is actually proven or achievable

## Summary

This research provides a comprehensive analysis of the current metalogic architecture, mapping theorem dependencies and identifying paths to a clean two-pillar architecture for completeness (via algebraic approach) and decidability (via FMP). The analysis reveals that the current architecture has **no sorry-free path to standard completeness** - both the Algebraic and FMP paths have limitations that prevent them from fully replacing the Representation path. This report provides detailed dependency flow charts, feasibility analysis, and concrete recommendations.

## Findings

### 1. Current Architecture Overview

The metalogic is structured into three main components:

```
Metalogic/
├── Core/                    # MCS theory, deduction theorem (SORRY-FREE)
├── Algebraic/               # Lindenbaum-Tarski algebra (SORRY-FREE)
├── FMP/                     # Finite Model Property (1 sorry)
├── Representation/          # Canonical model construction (20+ sorries)
├── Completeness/            # Completeness theorems (1 sorry - soundness)
└── Compactness/             # Compactness theorem (depends on above)
```

### 2. Dependency Flow Chart (Current State)

```
                    CORE DEFINITIONS (SORRY-FREE)
                    ========================

                    Core/MaximalConsistent.lean
                    Core/MCSProperties.lean
                    Core/DeductionTheorem.lean
                            |
         +------------------+------------------+
         |                  |                  |
         v                  v                  v
    ALGEBRAIC PATH     REPRESENTATION    FMP PATH
    (SORRY-FREE)       PATH              (1 sorry)
    ==============     (20+ sorries)     =========

    LindenbaumQuotient UniversalCanonicalModel  Closure.lean
         |                    |                     |
    BooleanStructure     TruthLemma.lean      BoundedTime.lean
         |                    |                     |
    InteriorOperators    CanonicalHistory    FiniteWorldState
         |                    |                     |
    UltrafilterMCS       TaskRelation        SemanticCanonicalModel
         |                    |                     |
    AlgebraicRepresentation   CoherentConstruction  FiniteModelProperty
         |                    |                     |
         v                    v                     v
    algebraic_             representation_    semantic_weak_
    representation_        theorem            completeness
    theorem                    |                     |
         |                     v                     |
         |              WeakCompleteness.lean -------+
         |                     |
         |                     v
         |              weak_completeness
         |              provable_iff_valid
         |                     |
         |                     v
         |              StrongCompleteness
         |              Compactness
         v
    AlgSatisfiable <-> AlgConsistent
    (DIFFERENT from standard `valid`)
```

### 3. The Three Paths in Detail

#### 3.1 Algebraic Path (Algebraic/)

**Status**: SORRY-FREE (verified by code inspection)

**Key Files**:
- `LindenbaumQuotient.lean` - Quotient by provable equivalence
- `BooleanStructure.lean` - BooleanAlgebra instance
- `InteriorOperators.lean` - G/H as interior operators
- `UltrafilterMCS.lean` - Bijection: ultrafilters <-> MCS
- `AlgebraicRepresentation.lean` - Main theorem

**Main Theorem**:
```lean
theorem algebraic_representation_theorem (phi : Formula) :
    AlgSatisfiable phi <-> AlgConsistent phi
```

Where:
- `AlgSatisfiable phi := exists U : AlgWorld, algTrueAt U phi`
- `AlgConsistent phi := not Nonempty (derivation [] phi.neg)`
- `AlgWorld := Ultrafilter LindenbaumAlg`
- `algTrueAt U phi := toQuot phi in U.carrier`

**Limitation**: This theorem proves satisfiability in an *algebraic model* (ultrafilters of the Lindenbaum algebra), NOT in the semantic models used by the standard `valid` predicate:
```lean
def valid (phi : Formula) : Prop :=
    forall D F M tau t, truth_at M tau t phi
```

**Gap to Standard Completeness**: To connect algebraic satisfiability to semantic validity, we would need:
1. A bridge theorem: `AlgSatisfiable phi <-> formula_satisfiable phi`
2. Or equivalently: `AlgConsistent phi <-> exists model, truth_at model phi`

This bridge does not exist and would require:
- Constructing a TaskFrame/TaskModel from an ultrafilter
- Defining a valuation from ultrafilter membership
- Proving a truth lemma relating algebraic truth to semantic truth

#### 3.2 Representation Path (Representation/)

**Status**: 20+ sorries across multiple files

**Key Files**:
- `CanonicalWorld.lean` - 2 sorries (neg_complete, deductively_closed)
- `IndexedMCSFamily.lean` - 4 sorries (helper lemmas)
- `TaskRelation.lean` - 5 sorries (MCS equality, temporal propagation)
- `CanonicalHistory.lean` - 2 sorries (T-axiom applications)
- `TruthLemma.lean` - 4 sorries (box cases, backward temporal)
- `CoherentConstruction.lean` - 10+ sorries (consistency, cross-origin cases)
- `UniversalCanonicalModel.lean` - 4 sorries (G-bot/H-bot exclusion)

**Main Theorem**:
```lean
theorem representation_theorem (phi : Formula) (h_cons : SetConsistent {phi}) :
    exists (family : IndexedMCSFamily Z) (t : Z),
      phi in family.mcs t /\
      truth_at (canonical_model Z family) (canonical_history_family Z family) t phi
```

**Why it Matters**: This is the ONLY path that connects to standard `truth_at` and `valid`. The completeness theorem uses this directly:

```lean
theorem weak_completeness (phi : Formula) : valid phi -> ContextDerivable [] phi
```

The proof uses `representation_theorem` to show non-derivable formulas have countermodels.

#### 3.3 FMP Path (FMP/)

**Status**: 1 sorry (compositionality in SemanticCanonicalFrame)

**Key Files**:
- `Closure.lean` - Subformula closure (SORRY-FREE)
- `BoundedTime.lean` - Finite time domain (SORRY-FREE)
- `FiniteWorldState.lean` - Finite world states (SORRY-FREE)
- `SemanticCanonicalModel.lean` - 1 sorry (compositionality)
- `FiniteModelProperty.lean` - Uses semantic_weak_completeness

**Main Theorems**:
```lean
-- PROVEN (sorry-free within the theorem)
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    derivation [] phi

-- PROVEN (sorry-free)
theorem semanticWorldState_card_bound (phi : Formula) :
    Fintype.card (SemanticWorldState phi) <= 2 ^ closureSize phi
```

**Dependency Issue**: The FMP path imports `WeakCompleteness.lean`:
```lean
import Bimodal.Metalogic.Completeness.WeakCompleteness
```

And uses from it:
- `soundness` (axiomatized with sorry)
- `SetConsistent`, `set_lindenbaum`

**Limitation**: `semantic_weak_completeness` proves completeness for a *specialized* truth predicate:
- `semantic_truth_at_v2` operates on `SemanticWorldState` (finite quotient type)
- NOT the standard `truth_at` on `TaskModel`

The theorem says: "If phi is true in all finite semantic world states, then phi is provable"
This is NOT: "If phi is valid (true in all models), then phi is provable"

### 4. Sorry Inventory by Severity

| File | Sorries | Severity | Notes |
|------|---------|----------|-------|
| CoherentConstruction.lean | 10+ | HIGH | Blocks representation_theorem |
| TruthLemma.lean | 4 | MEDIUM | Box/backward not needed for completeness |
| TaskRelation.lean | 5 | HIGH | Blocks canonical model construction |
| UniversalCanonicalModel.lean | 4 | HIGH | Blocks representation_theorem |
| CanonicalHistory.lean | 2 | MEDIUM | T-axiom, can work around |
| IndexedMCSFamily.lean | 4 | MEDIUM | Helper lemmas |
| CanonicalWorld.lean | 2 | MEDIUM | Can be filled with MCS properties |
| WeakCompleteness.lean | 1 | LOW | Soundness - axiomatized |
| SemanticCanonicalModel.lean | 1 | LOW | Compositionality - documented false |
| FiniteModelProperty.lean | 1 | LOW | Truth bridge - not needed |

### 5. Ideal Two-Pillar Architecture

The goal is a clean architecture where:
- **Pillar A (Completeness)**: Sorry-free proof of `valid phi -> derivable [] phi`
- **Pillar B (Decidability)**: Sorry-free proof of decidability via FMP

```
                  IDEAL ARCHITECTURE
                  ==================

    PILLAR A: COMPLETENESS          PILLAR B: DECIDABILITY
    ======================          =======================

    Algebraic/                      FMP/
    ├── LindenbaumQuotient          ├── Closure
    ├── BooleanStructure            ├── BoundedTime
    ├── InteriorOperators           ├── FiniteWorldState
    ├── UltrafilterMCS              ├── SemanticCanonicalModel
    ├── AlgebraicRepresentation     └── FiniteModelProperty
    └── AlgebraicToSemantic*            |
            |                           |
            v                           v
    weak_completeness*              decidability*
    (via algebraic bridge)          (via FMP)
            |                           |
            v                           v
    strong_completeness*            sat_decidable*
    compactness*                    validity_decidable*

    * = Currently has sorries or missing pieces
```

### 6. Feasibility Analysis

#### 6.1 Making Algebraic Path Complete

**Required New Theorems**:
1. `AlgebraicToSemantic`: Connect ultrafilter worlds to TaskFrame/TaskModel
2. `algebraic_truth_lemma`: `algTrueAt U phi <-> truth_at (semanticize U) phi`
3. `algebraic_completeness`: `valid phi -> derivable [] phi` via algebraic path

**Challenges**:
- Ultrafilters are propositional (no time structure)
- Need to build temporal relations from ultrafilter membership
- Box semantics in ultrafilters vs universal quantification over histories

**Estimated Effort**: HIGH (2-4 weeks for careful construction)

**Mathlib Support**: Good - has BooleanAlgebra, Ultrafilter, ClosureOperator

#### 6.2 Making FMP Path Independent

**Required Changes**:
1. Remove dependency on `WeakCompleteness.lean`
2. Prove `semantic_truth_at_v2` connects to standard `truth_at`
3. Prove compositionality or work around it

**Challenges**:
- `semantic_truth_at_v2` is fundamentally different (finite domain)
- Compositionality IS mathematically false for unbounded durations
- Truth bridge requires careful formula induction

**Estimated Effort**: MEDIUM (1-2 weeks)

#### 6.3 Fixing Representation Path

**Required Proofs**:
1. G-bot/H-bot exclusion in UniversalCanonicalModel
2. Cross-origin coherence cases in CoherentConstruction
3. MCS equality arguments in TaskRelation

**Challenges**:
- Cross-origin cases are mathematically complex
- Some may require changes to MCS family construction

**Estimated Effort**: HIGH (2-3 weeks of careful work)

### 7. Safe Archival Analysis

Based on the dependency analysis, here are files that can be safely archived:

#### 7.1 Safe to Archive NOW

| File | Reason |
|------|--------|
| NONE | All files in active Metalogic/ are imported by completeness proofs |

#### 7.2 Safe to Archive IF FMP Path Made Independent

| File | Condition |
|------|-----------|
| Representation/TaskRelation.lean | After FMP proves semantic completeness |
| Representation/CanonicalHistory.lean | After FMP proves semantic completeness |

#### 7.3 Safe to Archive IF Algebraic Path Made Complete

| File | Condition |
|------|-----------|
| Representation/* (all) | After algebraic path proves standard completeness |
| FMP/SemanticCanonicalModel.lean | If only using for decidability |

### 8. Dependency Flow Chart (Ideal State)

```
                    IDEAL FUTURE STATE
                    ==================

    CORE (SORRY-FREE)               ALGEBRAIC (SORRY-FREE)
    =================               ======================

    MaximalConsistent ──────────────> LindenbaumQuotient
    MCSProperties                          |
    DeductionTheorem                  BooleanStructure
                                           |
                                      InteriorOperators
                                           |
                                      UltrafilterMCS
                                           |
                                      AlgebraicRepresentation
                                           |
                                      AlgebraicSemanticBridge (NEW)
                                           |
                                           v
                     ┌─────────────────────┴──────────────────┐
                     |                                        |
                     v                                        v
              weak_completeness                     FMP/Closure (SORRY-FREE)
              (via algebraic path)                        |
                     |                              FMP/FiniteWorldState
                     v                                    |
              strong_completeness                   FMP/FiniteModelProperty
                     |                                    |
                     v                                    v
               compactness                          decidability
                                                   (FMP-based)


    ARCHIVED (Boneyard)
    ===================
    Representation/CoherentConstruction.lean
    Representation/TaskRelation.lean
    Representation/CanonicalHistory.lean
    Representation/TruthLemma.lean
    Representation/UniversalCanonicalModel.lean
```

## Recommendations

### 1. Near-Term: Document and Stabilize

**Do NOT archive any files yet.** Instead:

1. **Document the architecture** in Metalogic/README.md:
   - Current state with sorry locations
   - Three-path structure
   - Which theorems are sorry-free

2. **Mark sorry criticality** in code:
   - Add comments explaining which sorries block which theorems
   - Add "NOT REQUIRED FOR COMPLETENESS" comments where applicable

3. **Remove dead code** from TruthLemma.lean:
   - The backward direction proofs are not used
   - The box case proofs are not used

### 2. Medium-Term: Choose One Path

**Option A: Fix Representation Path**
- Invest in proving the sorries in CoherentConstruction
- This is the shortest path to standard completeness
- Risk: 20+ sorries, some mathematically challenging

**Option B: Build Algebraic Bridge**
- Create AlgebraicSemanticBridge.lean
- Define how to construct TaskModel from ultrafilter
- Prove the truth lemma connecting both worlds
- This is the most elegant long-term solution

**Option C: Strengthen FMP Path**
- Prove semantic_truth_at_v2 connects to truth_at
- Remove FMP dependency on WeakCompleteness
- This gives both completeness AND decidability

**Recommendation**: Option B (Algebraic Bridge) is the best long-term investment because:
- Algebraic path is already sorry-free
- Mathlib provides good infrastructure
- Result is more mathematically elegant
- Creates cleaner architecture

### 3. Long-Term: True Two-Pillar Architecture

Once one path achieves standard completeness:

1. Archive the Representation/ directory to Boneyard
2. Keep FMP/ for decidability (possibly refactored)
3. Result: Clean two-pillar architecture

## Concrete Implementation Roadmap

### Phase 1: Documentation (1-2 days)
- Add architecture documentation
- Mark sorries with criticality
- Clean up dead code in TruthLemma

### Phase 2: Algebraic Bridge (2-4 weeks)
1. Create `AlgebraicSemanticBridge.lean`
2. Define `ultrafilterToTaskFrame : Ultrafilter LindenbaumAlg -> TaskFrame Z`
3. Define `ultrafilterToModel : Ultrafilter LindenbaumAlg -> TaskModel`
4. Prove `algebraic_semantic_truth_lemma`
5. Prove `algebraic_completeness : valid phi -> derivable [] phi`

### Phase 3: FMP Independence (1-2 weeks)
1. Refactor FMP to not import WeakCompleteness
2. Add independent consistency lemmas to FMP
3. Prove decidability without representation path

### Phase 4: Archival (1 day)
1. Move Representation/ to Boneyard
2. Update imports in Metalogic.lean
3. Verify build succeeds

## References

- Previous research: research-004.md (dependency analysis)
- Previous research: research-003.md (three-path analysis)
- AlgebraicRepresentation.lean - sorry-free algebraic theorem
- WeakCompleteness.lean - current completeness proof
- SemanticCanonicalModel.lean - semantic_weak_completeness

## Next Steps

1. Review this analysis with stakeholder
2. Choose implementation path (A, B, or C)
3. Create implementation plan for chosen path
4. Execute phases with verification
