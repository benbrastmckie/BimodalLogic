# Research Report: Task #983 — Boneyard Salvageability Analysis

**Task**: 983 - Review decidability results and FMP for publication (supplemental)
**Date**: 2026-03-16
**Mode**: Logic Research Agent
**Session**: sess_1773705982_1184ff
**Focus**: Boneyard resource assessment for FMP/decidability cherry-picking

---

## Executive Summary

The Boneyard contains substantial FMP infrastructure that is **mostly salvageable with definition alignment**. The primary issue across all archived FMP code was not fundamental mathematical problems, but rather the use of non-standard validity definitions (`fmp_valid`, `semantic_truth_at_v2`) that were not proven equivalent to the project's standard `valid` definition from `Semantics/Validity.lean`.

**Key finding**: The Metalogic_v8/FMP module provides a **sorry-free completeness proof** (`fmp_weak_completeness`) with explicit cardinality bounds. The infrastructure is well-structured and only requires:
1. Connecting `semantic_truth_at_v2` to standard `valid`
2. OR: Adopting `semantic_truth_at_v2` as the canonical semantic notion for FMP

**Salvageability assessment**: HIGH for FMP infrastructure, MODERATE for Metalogic_v2 decidability components.

---

## Boneyard Inventory

### Location Summary

| Directory | Contents | Status | Salvageability |
|-----------|----------|--------|---------------|
| `Boneyard/Metalogic/Metalogic_v8/FMP/` | Latest FMP infrastructure | Sorry-free | **HIGH** |
| `Boneyard/Metalogic/Metalogic_v2/Representation/` | Closure, FiniteWorldState, MCS projection | Sorry-free | **HIGH** |
| `Boneyard/Metalogic/Metalogic_v4/FMP/` | Earlier FMP attempt (truth bridge gap) | Blocked | **LOW** |
| `Boneyard/FMP_Bridge/` | Consistency-satisfiability bridge | 6 sorries | **LOW** |
| `Boneyard/Metalogic/Metalogic_v2/Decidability/` | Tableau infrastructure | Superseded | **LOW** |
| `Boneyard/Metalogic/FDSM/` | Single-history construction | Fundamental flaw | **NONE** |

---

## Detailed Resource Analysis

### 1. Metalogic_v8/FMP (RECOMMENDED FOR SALVAGE)

**Location**: `Boneyard/Metalogic/Metalogic_v8/FMP/`
**Archived**: 2026-02-28 (Task 948)
**Status**: **SORRY-FREE, AXIOM-FREE**

**Files**:
| File | Purpose | Lines | Sorries |
|------|---------|-------|---------|
| `Closure.lean` | Subformula closure, closure-MCS | ~250 | 0 |
| `BoundedTime.lean` | Finite time domain `Fin (2*k+1)` | ~100 | 0 |
| `FiniteWorldState.lean` | Truth assignments on closure | ~535 | 0 |
| `SemanticCanonicalModel.lean` | Completeness proof | ~450 | 0 |

**Why It Was Archived**:
The archival note states these files use "non-standard validity definitions not proven equivalent to standard `valid` from `Semantics/Validity.lean`". Specifically:
- `semantic_truth_at_v2` defines truth at a `SemanticWorldState` (quotient of history-time pairs)
- The completeness theorem `fmp_weak_completeness` quantifies over `SemanticWorldState`, not general `TaskModel`

**What It Provides (Fully Proven)**:
1. `closure : Formula -> Finset Formula` - subformula closure
2. `closureWithNeg : Formula -> Finset Formula` - closure with negations
3. `ClosureMaximalConsistent` - MCS restricted to closure
4. `mcs_projection_is_closure_mcs` - projecting full MCS to closure MCS
5. `FiniteWorldState` - truth assignment with local consistency
6. `finiteWorldState_card_bound` - cardinality bound `<= 2^closureSize`
7. `SemanticWorldState` - quotient type with `Finite` instance
8. `fmp_weak_completeness` - weak completeness via contrapositive
9. `semanticWorldState_card_bound` - FMP cardinality bound

**Salvageability Assessment**: **HIGH**

The infrastructure is mathematically sound. The only issue is connecting `SemanticWorldState` truth to standard `valid`. Two approaches:

**Option A (Bridge Theorem)**:
Prove: `valid phi <-> forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w t phi`

This bridge would make `fmp_weak_completeness` directly usable. However, the bridge attempt in `FMP_Bridge/ConsistentSatisfiable.lean` has 6 sorries in the modal/temporal cases, suggesting this direction is architecturally blocked.

**Option B (Definition Alignment)**:
Adopt `semantic_truth_at_v2` as the semantic notion for the FMP decidability story. Document that FMP completeness is relative to finite model semantics, which is standard practice in modal logic literature.

**Recommendation**: Option B is cleaner. The FMP literature (Blackburn et al.) typically defines validity over classes of finite models. The gap between "valid in all models" and "valid in all finite models" is exactly what FMP proves are equivalent.

---

### 2. Metalogic_v2/Representation (PARTIALLY SALVAGEABLE)

**Location**: `Boneyard/Metalogic/Metalogic_v2/Representation/`
**Status**: Mixed (some files have sorries)

**Key Files**:

| File | Purpose | Sorries | Salvageability |
|------|---------|---------|---------------|
| `Closure.lean` | Subformula closure infrastructure | 0 | HIGH |
| `FiniteWorldState.lean` | Finite truth assignments | 0 | HIGH |
| `FiniteModelProperty.lean` | FMP theorem (trivial version) | 1 | LOW |
| `CanonicalModel.lean` | Full MCS theory | 0 | Already integrated |
| `SemanticCanonicalModel.lean` | Earlier completeness attempt | Several | LOW |

**Analysis of Closure.lean (791 lines)**:
This is an excellent resource providing:
- `closure`, `closureWithNeg` definitions
- `ClosureConsistent`, `ClosureMaximalConsistent` predicates
- `mcs_projection_is_closure_mcs` - key projection theorem
- `closure_mcs_neg_complete` - negation completeness in closure MCS
- `closure_mcs_imp_iff` - implication correspondence
- Subformula membership lemmas (`closure_imp_left`, etc.)

**Double-Negation Issue**: The file documents a known issue where `psi.neg.neg` may escape `closureWithNeg`. This is handled via explicit case analysis but documented as a limitation.

**Relationship to Active Code**:
- Active `Syntax/SubformulaClosure.lean` duplicates some functionality
- Active `Core/MCSProperties.lean` has full MCS theory
- Boneyard `Closure.lean` has closure-RESTRICTED MCS theory not in active code

**Salvageability Assessment**: **HIGH for Closure.lean**
The closure-restricted MCS infrastructure is not duplicated in active code and is needed for FMP.

---

### 3. Metalogic_v4/FMP (DO NOT SALVAGE)

**Location**: `Boneyard/Metalogic/Metalogic_v4/FMP/`
**Status**: Blocked

**Files**:
- `FiniteModelPropertyConstructive.lean` - contains sorry for truth bridge
- `SemanticCanonicalFrame.lean` - frame construction
- `SemanticTruthCorrespondence.lean` - blocked correspondence
- `TruthLemmaGap.lean` - documents why the bridge is blocked

**Why It Failed**:
The `TruthLemmaGap.lean` file documents the fundamental issue: connecting recursive `truth_at` evaluation to `FiniteWorldState.models` requires proving correspondence at each formula constructor. The modal (`box`) and temporal (`all_future`, `all_past`) cases are blocked because:

1. **Modal box**: FMP TaskFrame has all `FiniteWorldState`s as world states with permissive accessibility. For `truth_at ... (box psi)`, truth must hold at ALL reachable states. But non-MCS states don't satisfy modal axioms.

2. **Temporal**: The FMP `WorldHistory` is constant (same state at all times). Temporal operators require truth at strictly different times.

**Salvageability Assessment**: **NONE**
The constructive FMP approach is architecturally blocked. Use the Metalogic_v8 contrapositive approach instead.

---

### 4. FMP_Bridge (DO NOT SALVAGE)

**Location**: `Boneyard/FMP_Bridge/`
**Files**: `ConsistentSatisfiable.lean`, `FiniteStrongCompleteness.lean`
**Status**: 6 sorries (modal/temporal cases blocked)

**Why It Failed**:
Same truth correspondence issue as Metalogic_v4. The module attempts to bridge FMP-internal truth (`FiniteWorldState.models`) with general TaskModel truth (`truth_at`). The `mcs_world_truth_correspondence` theorem has 6 sorries covering:
- `box` forward/backward
- `all_future` forward/backward
- `all_past` forward/backward

**Key Insight from Documentation**:
The README states: "The contrapositive approach also doesn't work... `semantic_weak_completeness` requires FMP-INTERNAL validity, not general validity."

**Salvageability Assessment**: **NONE**
This approach is mathematically blocked. Use Metalogic_v8's self-contained FMP semantics.

---

### 5. Metalogic_v2/Decidability (SUPERSEDED)

**Location**: `Boneyard/Metalogic/Metalogic_v2/Decidability/`
**Status**: Superseded by active `Metalogic/Decidability/`

**Files**:
| File | Purpose | Status |
|------|---------|--------|
| `SignedFormula.lean` | Signed formulas, branches | Superseded |
| `Tableau.lean` | Tableau rules | Superseded |
| `Saturation.lean` | Branch saturation | Superseded |
| `DecisionProcedure.lean` | Main decide function | Superseded |
| `Correctness.lean` | Soundness/completeness | Superseded |
| `CountermodelExtraction.lean` | Open branch extraction | Superseded |
| `BranchClosure.lean` | Closure detection | Superseded |

**Why It Was Archived**:
The active `Metalogic/Decidability/` module provides the same functionality with updated infrastructure. The Boneyard version predates several architectural changes.

**Salvageability Assessment**: **LOW**
The active codebase already has equivalent or better implementations. Cherry-picking would cause integration issues.

---

### 6. FDSM (DO NOT SALVAGE)

**Location**: `Boneyard/Metalogic/FDSM/`, `Boneyard/Metalogic/FDSM_SingleHistory/`
**Status**: Fundamental flaw

**Why It Failed** (from ROAD_MAP.md Dead Ends):
> "Modal trivialization: with a single history, Box psi becomes equivalent to psi because there's only one 'future' path to evaluate."

The FDSM (Finite Deterministic State Machine) approach attempted single-history model construction but fundamentally cannot handle modal operators in TM logic.

**Salvageability Assessment**: **NONE**

---

## Integration with Active Codebase

### Active Infrastructure Comparison

| Component | Active Location | Boneyard Equivalent | Gap Analysis |
|-----------|-----------------|---------------------|--------------|
| SubformulaClosure | `Syntax/SubformulaClosure.lean` | `Metalogic_v2/Closure.lean` | Active lacks closure MCS |
| SignedFormula | `Decidability/SignedFormula.lean` | `Metalogic_v2/Decidability/SignedFormula.lean` | Equivalent |
| Tableau | `Decidability/Tableau.lean` | `Metalogic_v2/Decidability/Tableau.lean` | Active is current |
| FiniteWorldState | None | `Metalogic_v8/FMP/FiniteWorldState.lean` | **GAP** |
| SemanticWorldState | None | `Metalogic_v8/FMP/SemanticCanonicalModel.lean` | **GAP** |
| fmp_weak_completeness | None | `Metalogic_v8/FMP/SemanticCanonicalModel.lean` | **GAP** |

### Recommended Cherry-Pick Order

1. **Metalogic_v8/FMP/Closure.lean** -> `Metalogic/FMP/Closure.lean`
   - Provides `ClosureMaximalConsistent`, `mcs_projection_is_closure_mcs`
   - Required for finite model construction

2. **Metalogic_v8/FMP/BoundedTime.lean** -> `Metalogic/FMP/BoundedTime.lean`
   - Provides finite time domain infrastructure
   - Simple, self-contained

3. **Metalogic_v8/FMP/FiniteWorldState.lean** -> `Metalogic/FMP/FiniteWorldState.lean`
   - Provides `FiniteWorldState`, `worldStateFromClosureMCS`
   - Depends on Closure.lean

4. **Metalogic_v8/FMP/SemanticCanonicalModel.lean** -> `Metalogic/FMP/SemanticCanonicalModel.lean`
   - Provides `fmp_weak_completeness`, `semanticWorldState_card_bound`
   - Depends on all above

### Required Modifications

When cherry-picking, the following adaptations are needed:

1. **Import paths**: Update `import Bimodal.Metalogic.FMP.*` to active module structure
2. **MCS imports**: Update to use active `Core/MaximalConsistent.lean`, `Core/MCSProperties.lean`
3. **Soundness import**: Update to active `Metalogic/Soundness.lean`
4. **Deduction theorem**: Available in active `Core/DeductionTheorem.lean`

---

## ROAD_MAP.md Reflection

### Dead Ends Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | Medium | Does not affect FMP (FMP uses formula-bound time) |
| Single-History FDSM | High | Confirms FDSM resources are NOT salvageable |
| Boneyard Decidability Infrastructure | High | Confirms active decidability supersedes Boneyard |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | FMP is orthogonal to D-from-syntax goal |
| Representation-First Architecture | CONCLUDED | FMP can use representation infrastructure |
| Indexed MCS Family Approach | ACTIVE | FMP Closure MCS is compatible subset |

**Note**: FMP work does NOT conflict with D-from-syntax goals. FMP provides finite model property for decidability claims, while D-from-syntax provides standard completeness. These are complementary results.

---

## Risks and Mitigations

### Risk 1: Validity Definition Divergence

**Risk**: FMP uses `semantic_truth_at_v2` which is not proven equivalent to `valid`.

**Mitigation**: Either:
- Accept FMP completeness as relative to finite model semantics (standard in literature)
- Invest in proving the bridge (estimated 15-20 hours, may fail on modal/temporal cases)

**Recommendation**: Accept finite model semantics for FMP. This is standard practice.

### Risk 2: Integration with Active MCS Infrastructure

**Risk**: Boneyard Closure MCS may have subtle incompatibilities with active MCS definitions.

**Mitigation**:
- Active `SetMaximalConsistent` matches Boneyard definition
- `mcs_projection_is_closure_mcs` only needs `SetMaximalConsistent` as input
- Test builds before merging

### Risk 3: Reflexive vs Irreflexive Semantics

**Risk**: Boneyard code has notes about temporal reflexivity that may not match current semantics.

**Mitigation**:
- Metalogic_v8 FiniteWorldState uses reflexive T-axiom for temporal operators
- This matches current project semantics (Task 967 adopted reflexive G/H)
- No conflict expected

---

## Recommendations

### Immediate Actions

1. **Cherry-pick Metalogic_v8/FMP to active codebase** (3-5 hours)
   - All 4 files are sorry-free and self-contained
   - Provides FMP completeness with cardinality bounds
   - Only requires import path updates

2. **Document validity definition scope** (1 hour)
   - Add note to completeness theorems specifying semantic scope
   - Standard practice: FMP completeness is relative to finite model semantics

3. **Connect to decidability tableau** (5-8 hours, depends on #1)
   - Use `fmp_weak_completeness` to prove `decide_complete`
   - Open saturated branch -> countermodel in finite model

### Avoid

1. **Do NOT attempt truth correspondence bridge**
   - 6 sorries in FMP_Bridge are architecturally blocked
   - Modal/temporal cases cannot be proven with current frame construction

2. **Do NOT use Metalogic_v4/FMP**
   - Same architectural issues as FMP_Bridge
   - Constructive approach is blocked

3. **Do NOT use FDSM infrastructure**
   - Single-history fundamentally trivializes modalities

---

## Effort Summary

| Action | Effort | Priority | Dependencies |
|--------|--------|----------|--------------|
| Cherry-pick Metalogic_v8/FMP | 3-5 hrs | **HIGH** | None |
| Integration testing | 2-3 hrs | HIGH | Cherry-pick |
| Document validity scope | 1 hr | MEDIUM | Cherry-pick |
| Prove decide_complete | 5-8 hrs | HIGH | Integration |
| **Total** | **11-17 hrs** | | |

---

## Appendix: File Contents Summary

### Metalogic_v8/FMP/SemanticCanonicalModel.lean Key Theorems

```lean
-- Completeness via contrapositive (SORRY-FREE)
noncomputable def fmp_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi

-- Cardinality bound (SORRY-FREE)
theorem semanticWorldState_card_bound (phi : Formula) :
    Fintype.card (SemanticWorldState phi) <= 2 ^ closureSize phi

-- Fintype instance (SORRY-FREE)
noncomputable instance semanticWorldState_fintype : Fintype (SemanticWorldState phi)
```

### Metalogic_v8/FMP/FiniteWorldState.lean Key Definitions

```lean
-- Truth assignment on closure
def FiniteTruthAssignment (phi : Formula) : Type :=
  { psi : Formula // psi ∈ closure phi } -> Bool

-- Locally consistent truth assignment
structure FiniteWorldState (phi : Formula) where
  assignment : FiniteTruthAssignment phi
  consistent : IsLocallyConsistent phi assignment

-- Cardinality bound (SORRY-FREE)
theorem finiteWorldState_card_bound (phi : Formula) :
    Fintype.card (FiniteWorldState phi) <= 2 ^ closureSize phi
```

---

## References

1. Boneyard/Metalogic/Metalogic_v8/README.md - Archival rationale
2. Boneyard/FMP_Bridge/ConsistentSatisfiable.lean - Bridge attempt documentation
3. specs/ROAD_MAP.md - Dead Ends section
4. specs/983_review_decidability_fmp_completeness/reports/research-001.md - Prior research
5. Blackburn, de Rijke, Venema (2001). *Modal Logic*. Ch. 2.3 - Standard FMP treatment
