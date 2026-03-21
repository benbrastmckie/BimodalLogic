# Research Report: Task #738 (Supplementary)

**Task**: Port FMP to parametric architecture - FMP/Decidability Relationships
**Date**: 2026-01-29
**Focus**: FMP-tableau decidability method and dependency map with parametric architecture
**Session**: sess_1769693880_92fe98

## Summary

This supplementary research maps the relationships between the Finite Model Property (FMP), decidability via tableau methods, the parametric metalogic architecture, and related completeness properties. The goal is to provide a clear dependency map for completing the decidability procedure via FMP-tableau.

## Context: Two Parallel Architectures

The codebase has two metalogic implementations that must be understood in relation:

| Architecture | Location | Key Features | Status |
|--------------|----------|--------------|--------|
| **Parametric Universal** | `Metalogic/` | Generic `D` type, IndexedMCSFamily, completeness proven | Active, production |
| **Hardcoded FMP** | `Boneyard/Metalogic_v2/` | `Int` only, finite models, tableau decidability | Deprecated but contains FMP/decidability |

**Key Insight**: The parametric architecture (Metalogic/) has completeness but NO FMP/decidability. The deprecated architecture (Boneyard/) has FMP/decidability but hardcoded to Int. Task 738 bridges these.

## Dependency Map: FMP → Decidability Chain

```
                     COMPLETENESS CHAIN
                     (Parametric D, proven)
                           │
    ┌──────────────────────┼──────────────────────┐
    │                      │                      │
    ▼                      ▼                      ▼
IndexedMCSFamily     CoherentConstruction    TruthLemma
(MCS indexed by D)   (builds coherent MCS)   (MCS ↔ truth)
    │                      │                      │
    └──────────────────────┼──────────────────────┘
                           │
                           ▼
              UniversalCanonicalModel
              (representation theorem)
                           │
                           ▼
              WeakCompleteness ─────► StrongCompleteness
              (valid → provable)       (Γ ⊨ φ → Γ ⊢ φ)
                           │
                           │    ┌─────────────────────┐
                           │    │   FMP CHAIN         │
                           │    │   (needs porting)   │
                           │    └─────────────────────┘
                           ▼                  │
                 Compactness                  │
              (finite approx)                 │
                           │                  │
    ╔══════════════════════╧══════════════════╧════════════════╗
    ║                                                          ║
    ║              FINITE MODEL PROPERTY (FMP)                 ║
    ║       satisfiable φ → ∃ finite model M. M ⊨ φ            ║
    ║          with |worlds| ≤ 2^|closure(φ)|                  ║
    ║                                                          ║
    ╚══════════════════════════════════════════════════════════╝
                           │
    ┌──────────────────────┼──────────────────────┐
    │                      │                      │
    ▼                      ▼                      ▼
Closure                SemanticCanonical     Cardinality
(subformula set)        Model (finite)        Bound
    │                      │                      │
    └──────────────────────┼──────────────────────┘
                           │
    ╔══════════════════════╧═══════════════════════════════════╗
    ║                                                          ║
    ║              TABLEAU DECIDABILITY                        ║
    ║   Terminates with fuel = 2^closureSize * 2               ║
    ║   Closed tableau → valid (proof extraction)              ║
    ║   Open branch → invalid (countermodel extraction)        ║
    ║                                                          ║
    ╚══════════════════════════════════════════════════════════╝
                           │
    ┌──────────────────────┼──────────────────────┐
    │                      │                      │
    ▼                      ▼                      ▼
SignedFormula       Saturation           DecisionProcedure
(+/- formulas)      (with FMP fuel)      (decide function)
    │                      │                      │
    ▼                      ▼                      ▼
BranchClosure       ProofExtraction      CountermodelExtraction
```

## Key Properties and Their Relationships

### 1. Finite Model Property (FMP)

**Definition**: If φ is satisfiable, then φ is satisfiable in a finite model with bounded size.

**Formal Statement** (from `FiniteModelProperty.lean`):
```lean
theorem finite_model_property_constructive (φ : Formula) (h_sat : formula_satisfiable φ) :
    ∃ (F : TaskFrame Int) (M : TaskModel F) (τ : WorldHistory F) (t : Int)
      (_h_finite : Finite F.WorldState)
      (_h_fintype : Fintype F.WorldState),
      truth_at M τ t φ ∧
      Fintype.card F.WorldState ≤ 2 ^ (closureSize φ)
```

**Dependencies**:
- Lindenbaum's Lemma (extend consistent sets to MCS)
- Closure infrastructure (subformula closure bounds)
- SemanticCanonicalModel construction

**What FMP Provides to Decidability**:
1. **Bounded search space**: At most 2^closureSize world states
2. **Termination guarantee**: Tableau exploration is finite
3. **Completeness of search**: If valid, tableau closes within bound

### 2. Decidability (via Tableau + FMP)

**Definition**: There exists an algorithm that determines whether φ is valid in TM logic.

**Formal Statement** (from `Correctness.lean`):
```lean
noncomputable instance validity_decidable_via_sat (φ : Formula) :
    Decidable (⊨ φ) :=
  validity_decidable_via_fmp φ
```

**The FMP-Tableau Connection** (from Correctness.lean comments):
```
1. FMP Bound: Any satisfiable formula has a model with ≤ 2^closureSize world states
2. Tableau Search Space: Branches contain formulas from closure, bounded by 2^(2*closureSize)
3. Termination: With fuel = 2^closureSize * 2, tableau terminates with:
   - All branches closed → valid (extract proof)
   - Open saturated branch → invalid (extract countermodel)
```

### 3. Completeness

**Definition**: Every valid formula is provable (and converse: soundness).

**Relationship to FMP**:
- **FMP does NOT require completeness**: FMP is about finite satisfiability
- **Completeness does NOT require FMP**: Completeness uses infinite canonical model
- **They work together for decidability**: FMP bounds the search, completeness ensures termination

**Proven in Parametric Architecture**:
```lean
theorem weak_completeness (φ : Formula) :
    (⊨ φ) → ContextDerivable [] φ
```

### 4. Compactness

**Definition**: If every finite subset of Γ is satisfiable, then Γ is satisfiable.

**Relationship to FMP**:
- FMP strengthens compactness by bounding model size
- From `Compactness.lean`: "FMP strengthens compactness by bounding the size of required models"

### 5. Truth Lemma (Forward and Backward)

**Definition**: φ ∈ mcs(t) ↔ truth_at(canonical_model, t, φ)

**Relationship to Decidability**:
- **Forward direction** (→): Used for completeness (already proven)
- **Backward direction** (←): Needed for full truth lemma, has sorries at lines 423, 441

**The Backward Truth Lemma Gap** (from Task 741 research):
- Lines 423, 441: `(∀ s ≤ t, truth_at s ψ) → H ψ ∈ mcs t`
- Requires **witness extraction**: `Hψ ∉ mcs(t) → ∃ s < t. ψ ∉ mcs(s)`
- Implemented in `TemporalCompleteness.lean` with sorries for H/G-completeness

## Current State of Each Component

### In Parametric Architecture (Metalogic/)

| Component | Status | File |
|-----------|--------|------|
| IndexedMCSFamily | ✅ Proven | Representation/IndexedMCSFamily.lean |
| CoherentConstruction | ✅ Proven | Representation/CoherentConstruction.lean |
| Truth Lemma (forward) | ✅ Proven | Representation/TruthLemma.lean |
| Truth Lemma (backward) | ⏳ Sorries at 423, 441 | Representation/TruthLemma.lean |
| H/G-Completeness | ⏳ Sorries | Representation/TemporalCompleteness.lean |
| Weak Completeness | ✅ Proven | Completeness/WeakCompleteness.lean |
| Strong Completeness | ✅ Proven | Completeness/FiniteStrongCompleteness.lean |
| Compactness | ✅ Proven | Compactness/Compactness.lean |
| **FMP** | ❌ Not present | - |
| **Decidability** | ❌ Not present | - |

### In Deprecated Architecture (Boneyard/Metalogic_v2/)

| Component | Status | File |
|-----------|--------|------|
| Closure | ✅ Proven (Int only) | Representation/Closure.lean |
| SemanticCanonicalModel | ⏳ compositionality sorry | Representation/SemanticCanonicalModel.lean |
| FMP | ⏳ truth bridge sorry (line 481) | Representation/FiniteModelProperty.lean |
| closureSize bound | ✅ Proven | Representation/FiniteModelProperty.lean |
| Tableau infrastructure | ✅ Proven | Decidability/*.lean |
| Decision procedure | ✅ Proven | Decidability/DecisionProcedure.lean |
| validity_decidable_via_fmp | ✅ Proven (modulo FMP sorry) | Decidability/Correctness.lean |

## The Two Blocking Sorries

### 1. FMP "Truth Bridge" (line 481 in FiniteModelProperty.lean)

```lean
-- truth_at (SemanticCanonicalModel φ) tau 0 φ
-- This requires a "truth bridge" connecting finite model truth to general truth_at.
sorry
```

**Why it's hard**: The SemanticCanonicalModel uses SemanticWorldState (finite), but truth_at is defined for general models. Connecting them requires formula induction with modal/temporal cases.

**Relationship to Parametric Port**:
- The parametric architecture avoids this by using UniversalCanonicalModel directly
- Porting FMP may sidestep this by stating FMP for the parametric model

### 2. H/G-Completeness (TemporalCompleteness.lean)

```lean
lemma H_completeness ... : Formula.all_past psi ∈ family.mcs t := by
  -- ... requires showing H psi derivable from coherence structure
  sorry
```

**Why it's hard**: TM logic lacks an ω-rule to derive Hψ from infinitely many ψ instances. The proof needs to analyze the construction of IndexedMCSFamily.

**Relationship to Decidability**:
- Required for backward Truth Lemma (lines 423, 441)
- NOT required for forward Truth Lemma or completeness (currently proven)
- Would strengthen the metatheory but not block FMP-tableau decidability

## Porting Strategy: FMP to Parametric Architecture

### Option A: Full Parametric Port

Port FMP with parametric D type:
```lean
theorem finite_model_property_parametric (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (φ : Formula) (h_sat : formula_satisfiable φ) :
    ∃ (F : TaskFrame D) ... Finite F.WorldState ∧ Fintype.card ≤ 2^closureSize
```

**Challenge**: The finite construction in Boneyard uses `FiniteTime k = Fin (2*k+1)` which maps to Int. Generalizing to arbitrary D requires defining bounded time subsets.

**Benefit**: Maximally general result, matches parametric architecture.

### Option B: Keep Int, Embed in Parametric

State FMP for Int only, use Int ↪ D embedding:
```lean
theorem fmp_int (φ : Formula) : ... TaskFrame Int ...  -- Keep existing

-- For any D with Int coercion
theorem fmp_via_int (D : Type) [AddCommGroup D] [LinearOrder D] ...
    [IntCast D] (φ : Formula) : ... -- Use Int result
```

**Challenge**: Needs Int ↪ D embedding preserving order and group structure.

**Benefit**: Minimal changes to FMP proof, leverages existing work.

### Option C: Minimal Port (Recommended for Task 738)

1. **Move Closure to parametric** (no duration type used)
2. **State FMP parametrically** but prove for D = Int
3. **Port tableau to parametric** (just type annotations)
4. **Document bound**: The 2^closureSize bound is independent of D

This matches the approach in `UniversalCanonicalModel.lean` which uses ℤ despite parametric definitions.

## Decidability via FMP-Tableau: Implementation Path

### Current Implementation (Boneyard/Metalogic_v2/Decidability/)

```
Decidability.lean (hub module)
├── SignedFormula.lean       ← closureSizeOf, fmpBasedFuel definitions
├── Tableau.lean             ← Expansion rules
├── BranchClosure.lean       ← Branch closure detection
├── Saturation.lean          ← Expansion with FMP fuel
├── ProofExtraction.lean     ← Extract proof from closed tableau
├── CountermodelExtraction.lean ← Extract countermodel from open branch
├── DecisionProcedure.lean   ← Main decide function
└── Correctness.lean         ← Soundness + FMP integration
```

### Key Functions

| Function | Purpose | FMP Dependency |
|----------|---------|----------------|
| `closureSizeOf φ` | Count subformulas | Used for fuel calculation |
| `fmpBasedFuel φ` | 2^closureSize * 2 | Guarantees termination |
| `buildTableauWithFMPFuel φ` | Construct tableau | Uses fmpBasedFuel |
| `decide φ` | Main decision | Returns Valid/Invalid/Timeout |

### FMP-Tableau Connection Detail

From `Saturation.lean`:
```lean
/-!
## FMP Integration

This module integrates with the Finite Model Property from Metalogic_v2.
The FMP provides explicit bounds on the search space:
- `closureSizeOf(φ)` gives the number of distinct subformulas
- `fmpBasedFuel(φ) = 2^closureSizeOf(φ) * 2` bounds the tableau expansion

This ensures that the tableau procedure terminates with sufficient fuel.
-/
```

From `Correctness.lean`:
```lean
/-!
## FMP-Tableau Connection

1. FMP Bound: `semanticWorldState_card_bound` gives ≤ 2^closureSize world states
2. Tableau Search Space: bounded by 2^(2 * closureSize)
3. Termination: With fuel = 2^closureSize * 2, tableau terminates
-/
```

## Relationship to Task 741 (Witness Extraction)

Task 741 addresses the backward Truth Lemma, which is **orthogonal** to FMP-decidability but related:

| Property | Truth Lemma Backward | FMP-Decidability |
|----------|---------------------|------------------|
| Goal | Complete truth_lemma | validity_decidable |
| Blocking? | Sorries at 423, 441 | Sorries at FMP line 481 |
| Approach | H/G-completeness lemmas | Finite model construction |
| Architecture | Parametric (Metalogic/) | Hardcoded (Boneyard/) |

**Key Insight**: These are parallel development paths. Completing either:
- Task 741 → Stronger metatheory (full truth lemma)
- Task 738 → Decidability procedure

They can be combined by:
1. Port FMP to parametric (Task 738)
2. Complete H/G-completeness (Task 741)
3. Use H/G-completeness in FMP proof (bridges both)

## Recommendations

### For Task 738: FMP Port

**Phase 1**: Move Closure infrastructure (minimal changes)
```
Boneyard/Metalogic_v2/Representation/Closure.lean
  → Metalogic/Representation/Closure.lean
```

**Phase 2**: Port FiniteWorldState with parametric time
- Keep FiniteTime as Fin but parametrize frame over D
- Use Int coercion where needed

**Phase 3**: Port FMP theorems
- `finite_model_property_constructive` → parametric statement
- `semanticWorldState_card_bound` → unchanged (combinatorial)

**Phase 4**: Port tableau decidability
- Move Decidability/ to parametric imports
- Update type signatures for generic D

### For Task 741: Witness Extraction

**Phase 1**: Prove H/G-completeness
- Analyze CoherentConstruction to derive H psi from coherence
- May require construction-specific argument

**Phase 2**: Complete backward Truth Lemma
- Use witness_from_not_H/G with negation completeness
- Apply forward IH at subformula level

**Phase 3**: Optionally use in FMP
- H/G-completeness provides alternative FMP proof path

## Appendix: Key Theorems Reference

### Core FMP Theorems (Boneyard)
```lean
theorem finite_model_property (φ : Formula) :
    formula_satisfiable φ → ∃ (F : TaskFrame Int) ... truth_at M τ t φ

theorem semanticWorldState_card_bound (φ : Formula) :
    Fintype.card (SemanticWorldState φ) ≤ 2 ^ closureSize φ

theorem consistent_implies_satisfiable (φ : Formula) (h_cons : Consistent [φ]) :
    formula_satisfiable φ
```

### Core Decidability Theorems (Boneyard)
```lean
def decide (φ : Formula) (searchDepth tableauFuel : Nat) : DecisionResult

theorem decide_sound (φ : Formula) (proof : DerivationTree [] φ) : ⊨ φ

noncomputable instance validity_decidable_via_sat (φ : Formula) : Decidable (⊨ φ)
```

### Core Parametric Theorems (Metalogic/)
```lean
theorem truth_lemma_forward (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi ∈ family.mcs t → truth_at (canonical_model D family) ... t phi

theorem representation_theorem (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (phi : Formula) (h_cons : SetConsistent {phi}) :
    ∃ (family : IndexedMCSFamily D) (t : D), phi ∈ family.mcs t ∧ ...

theorem weak_completeness (φ : Formula) : (⊨ φ) → ContextDerivable [] φ
```

## References

- Research 738-001: `specs/738_port_fmp_to_parametric_architecture/reports/research-001.md`
- Research 741-001: `specs/741_witness_extraction_architecture_for_backward_truth_lemma/reports/research-001.md`
- Metalogic README: `Theories/Bimodal/Metalogic/README.md`
- Blackburn et al., Modal Logic, Chapter 4 (FMP, Decidability)
- Wu, M., Verified Decision Procedures for Modal Logics

## Next Steps

1. **Decide port strategy**: Option A (full parametric) vs Option C (minimal port)
2. **Create implementation plan** with phased approach
3. **Consider parallel development** with Task 741 for potential synergies
4. **Document architectural decisions** for future reference
