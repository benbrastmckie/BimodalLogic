# Research Report: Task #470 (Supplemental)

**Task**: 470 - Finite Model Computational Optimization
**Date**: 2026-01-18
**Focus**: Metalogic_v2 architecture analysis and optimization opportunities

## Summary

This supplemental research focuses on the Metalogic_v2 architecture, which is the active implementation to be optimized. The old Metalogic directory will be deprecated. The key insight is that Metalogic_v2 uses a **representation-first architecture** with the Finite Model Property (FMP) as the central bridge theorem. Optimization opportunities exist primarily in: (1) completing the remaining sorries to enable full compilation, (2) making `noncomputable` definitions computable where possible, and (3) leveraging the quotient-based SemanticWorldState architecture for efficient enumeration.

## Context & Scope

This research supplements research-001.md which analyzed the old `Metalogic/Completeness/FiniteCanonicalModel.lean`. This report focuses exclusively on:

1. `Theories/Bimodal/Metalogic_v2/` - The active codebase
2. Representation theorem approach as the core proof strategy
3. Computational efficiency in the context of the new architecture

The old Metalogic will be deleted, so optimizations should target Metalogic_v2 only.

## Findings

### 1. Metalogic_v2 Architecture Overview

The v2 architecture follows a layered structure:

```
┌─────────────────────────────────────────────────────────────┐
│                     FMP.lean (Hub)                          │
│               Central interface layer                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│Completeness │ │Decidability │ │ Compactness │
└─────────────┘ └─────────────┘ └─────────────┘
        ▲              ▲              ▲
        └──────────────┼──────────────┘
                       │
         ┌─────────────┴─────────────┐
         │    Representation Layer    │
         │  - FiniteModelProperty     │
         │  - SemanticCanonicalModel  │
         │  - FiniteWorldState        │
         │  - Closure                 │
         │  - RepresentationTheorem   │
         │  - TruthLemma              │
         └────────────┬──────────────┘
                      │
         ┌────────────┴──────────────┐
         │        Core Layer          │
         │  - MaximalConsistent       │
         │  - DeductionTheorem        │
         │  - Basic/Provability       │
         └───────────────────────────┘
```

### 2. Key Files and Their Roles

| File | Lines | Sorries | Purpose |
|------|-------|---------|---------|
| `FiniteWorldState.lean` | 377 | 1 | Finite world state structure, temporal bounds |
| `SemanticCanonicalModel.lean` | 570 | 4 | Semantic approach using quotient types |
| `FiniteModelProperty.lean` | 507 | 0 | FMP theorem and constructive bounds |
| `Closure.lean` | 616 | 9 | Closure infrastructure, MCS projection |
| `RepresentationTheorem.lean` | 188 | 0 | Core representation theorem |

### 3. Semantic vs Syntactic Approach Comparison

The v2 architecture provides **two parallel approaches**:

**Syntactic Approach** (FiniteWorldState):
- `FiniteTruthAssignment phi`: Function `closure phi -> Bool`
- `IsLocallyConsistent`: Propositional consistency constraint
- Status: One sorry at `closure_mcs_implies_locally_consistent` (line 316)
- Issue: Requires temporal reflexivity axioms (H phi -> phi, G phi -> phi) which don't hold in TM logic

**Semantic Approach** (SemanticCanonicalModel):
- `SemanticWorldState phi`: Quotient of `(FiniteHistory, FiniteTime)` pairs
- `htEquiv`: Equivalence relation based on underlying world state equality
- Status: 4 sorries (compositionality, time arithmetic, truth bridge)
- Advantage: Compositionality trivial by construction

**Recommendation**: Focus optimization on the Semantic Approach as it has cleaner architecture and fewer fundamental issues.

### 4. Current Sorry Analysis

**SemanticCanonicalModel.lean** (4 sorries):
1. Line 207: `semantic_task_rel_compositionality` - History gluing needed
2. Line 286: `finiteHistoryToWorldHistory.respects_task` - Time arithmetic
3. Line 404: `semantic_truth_implies_truth_at` - Formula induction bridge
4. Line 554: `main_weak_completeness_v2` - Final completeness (uses above)

**FiniteWorldState.lean** (1 sorry):
1. Line 321: `closure_mcs_implies_locally_consistent` - Temporal axiom issue

**Closure.lean** (9 sorries):
1. Line 348: `closure_mcs_neg_complete` - Double negation handling
2. Line 472: `mcs_projection_is_closure_mcs` - Projection maximality
3. Lines 487-523: Subformula membership lemmas (5 sorries)
4. Line 608: `closure_mcs_imp_iff` backward direction

### 5. Computational Patterns in v2

**Efficient Patterns Already in Place**:

```lean
-- Quotient-based world state (computable equality)
def SemanticWorldState (phi : Formula) := Quotient (htSetoid phi)

-- Injection-based finiteness proof
instance semanticWorldState_finite : Finite (SemanticWorldState phi) := by
  apply Finite.of_injective toFiniteWorldState
  intro w1 w2 h
  exact (eq_iff_toFiniteWorldState_eq w1 w2).mpr h

-- Cardinality bound
theorem semanticWorldState_card_bound (φ : Formula) :
    @Fintype.card (SemanticWorldState φ) (Fintype.ofFinite _) ≤ 2 ^ closureSize φ
```

**Noncomputable Definitions** (optimization targets):

```lean
-- Line 216 in SemanticCanonicalModel.lean
noncomputable def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int where
  WorldState := SemanticWorldState phi
  task_rel := semantic_task_rel phi  -- Uses ∃ h : FiniteHistory...
  nullity := semantic_task_rel_nullity phi
  compositionality := ... -- Sorry

-- Line 233 in SemanticCanonicalModel.lean
noncomputable def SemanticCanonicalModel (phi : Formula) : TaskModel ...

-- Line 252 in SemanticCanonicalModel.lean
noncomputable def intToFiniteTime (phi : Formula) (t : Int)
    (h : inFiniteDomain phi t) : FiniteTime (temporalBound phi) := ...

-- Line 266 in SemanticCanonicalModel.lean
noncomputable def finiteHistoryToWorldHistory (phi : Formula) ...
```

**Why noncomputable?**
- `SemanticCanonicalFrame`: Uses existential `∃ h : FiniteHistory...` in task_rel
- `intToFiniteTime`: Uses `.toNat` with proof, generally computable
- `finiteHistoryToWorldHistory`: Depends on noncomputable `intToFiniteTime`

### 6. Closure Implementation Analysis

The closure in v2 reuses old Metalogic infrastructure:

```lean
-- Closure.lean line 57
def closure (phi : Formula) : Finset Formula :=
  (Formula.subformulas phi).toFinset

-- Size definition
def closureSize (phi : Formula) : Nat := (closure phi).card
```

**Computational Efficiency**:
- Uses `Finset` for O(log n) membership checking via decidable equality
- `closureWithNeg` extends with negations: `closure phi ∪ (closure phi).image Formula.neg`
- Instance: `DecidablePred (· ∈ closure phi)` via `Finset.decidableMem`

**Issue**: The `subformulas` function is imported from old Metalogic:
```lean
import Bimodal.Metalogic.Decidability.SignedFormula
open Bimodal.Metalogic.Decidability (Formula.subformulas)
```

This dependency on old Metalogic should be migrated.

### 7. FiniteTime Implementation (Computable)

The time domain is well-optimized in v2:

```lean
-- Efficient bounded time domain
abbrev FiniteTime (k : Nat) := Fin (2 * k + 1)

-- Computable operations
def toInt (k : Nat) (t : FiniteTime k) : Int := (t.val : Int) - (k : Int)
def origin (k : Nat) : FiniteTime k := ⟨k, by omega⟩

-- All basic operations proven without sorry
theorem toInt_injective (k : Nat) : Function.Injective (toInt k)
theorem toInt_range (k : Nat) (t : FiniteTime k) : -(k : Int) ≤ toInt k t ∧ toInt k t ≤ (k : Int)
```

This is already optimal - no changes needed.

### 8. Representation Theorem Approach

The v2 architecture makes the representation theorem central:

```lean
-- RepresentationTheorem.lean
theorem representation_theorem : Consistent Γ →
    ∃ w, ∀ φ ∈ Γ, canonicalTruthAt w φ

theorem strong_representation_theorem {φ : Formula} :
    ¬ContextDerivable Γ φ.neg → ∃ w, (∀ ψ ∈ Γ, canonicalTruthAt w ψ) ∧ canonicalTruthAt w φ
```

This is the correct approach - the representation theorem provides the semantic witness directly, avoiding the need to enumerate all possible world states.

### 9. Constructive FMP (Key for Decidability)

The `finite_model_property_constructive` theorem is the most important for optimization:

```lean
theorem finite_model_property_constructive (φ : Formula) (h_sat : formula_satisfiable φ) :
    ∃ (F : TaskFrame Int) (M : TaskModel F) (τ : WorldHistory F) (t : Int)
      (_h_finite : Finite F.WorldState)
      (_h_fintype : Fintype F.WorldState),
      truth_at M τ t φ ∧
      Fintype.card F.WorldState ≤ 2 ^ (closureSize φ)
```

This provides:
1. Explicit finite model (SemanticCanonicalFrame)
2. Fintype witness for enumeration
3. Cardinality bound: `|WorldState| ≤ 2^|closure(φ)|`

### 10. Comparison with Old Metalogic Patterns Worth Adapting

**Patterns to Adapt** (from old FiniteCanonicalModel.lean):

1. **Explicit time shift** (lines 224-250):
```lean
-- Old Metalogic has computable shift?
def shift? (k : Nat) (t : FiniteTime k) (delta : Int) : Option (FiniteTime k) := ...
```
v2 should use this instead of `Classical.choose` for time operations.

2. **Decidable membership** (explicit instances):
```lean
instance (phi : Formula) : DecidablePred (· ∈ closure phi) := ...
```
Already present in v2 - good.

**Patterns to Avoid** (from old Metalogic):

1. `Classical.choose` for time shifts - use explicit arithmetic
2. Deep nesting of universal quantifiers over closure
3. Noncomputable DecidableEq instances

## Recommendations

### Priority 1: Complete Critical Sorries (Unblocks Everything)

The 4 sorries in SemanticCanonicalModel.lean block the completeness proof. Completing these enables the full pipeline:

1. **History Gluing** (line 207): Implement `semantic_task_rel_compositionality`
   - Key insight: When two histories agree at a junction point, they can be glued
   - This is the most complex sorry - requires careful case analysis

2. **Time Arithmetic** (line 286): Implement `respects_task`
   - Relatively straightforward: show `toInt ft - toInt fs = t - s`
   - Main work is careful unfolding of definitions

3. **Truth Bridge** (line 404): Implement `semantic_truth_implies_truth_at`
   - Requires induction on formula structure
   - Key: connect finite world state truth to model truth_at

### Priority 2: Make Constructions Computable

Convert noncomputable definitions where possible:

1. **`intToFiniteTime`**: Already close to computable
   - Remove Classical dependency by explicit bounds checking

2. **`SemanticCanonicalFrame`**: The `task_rel` uses existential
   - Consider: Decidable version for finite enumeration
   - Alternative: Keep propositional for proofs, add decidable version for computation

3. **`assignmentFromClosureMCS`** (FiniteWorldState.lean line 305):
```lean
-- Current (noncomputable due to Classical.propDecidable)
noncomputable def assignmentFromClosureMCS (phi : Formula) (S : Set Formula)
    (_h_mcs : ClosureMaximalConsistent phi S) : FiniteTruthAssignment phi :=
  fun ⟨psi, _⟩ => if Classical.propDecidable (psi ∈ S) |>.decide then true else false

-- Better: If S has decidable membership
def assignmentFromClosureMCS [DecidablePred (· ∈ S)] (phi : Formula) (S : Set Formula)
    (_h_mcs : ClosureMaximalConsistent phi S) : FiniteTruthAssignment phi :=
  fun ⟨psi, _⟩ => if psi ∈ S then true else false
```

### Priority 3: Migrate Subformulas from Old Metalogic

Create `Bimodal.Syntax.Subformulas` or similar to eliminate dependency:

```lean
-- Move from Bimodal.Metalogic.Decidability.SignedFormula to Bimodal.Syntax
def Formula.subformulas : Formula → List Formula
  | .atom p => [.atom p]
  | .bot => [.bot]
  | .imp ψ χ => (.imp ψ χ) :: (subformulas ψ ++ subformulas χ)
  | .box ψ => (.box ψ) :: subformulas ψ
  | .all_future ψ => (.all_future ψ) :: subformulas ψ
  | .all_past ψ => (.all_past ψ) :: subformulas ψ
```

### Priority 4: Add Decidable Task Relation for Finite Enumeration

For decidability proofs, add:

```lean
-- Decidable version of semantic_task_rel (for bounded search)
def semantic_task_rel_decidable (phi : Formula) (w v : SemanticWorldState phi) (d : Int) :
    Decidable (semantic_task_rel phi w d v) := by
  -- Enumerate all (h, t1, t2) combinations
  -- Check if any witness the relation
  sorry -- Needs Fintype instances
```

### Priority 5: Closure Computation Caching

For repeated closure operations:

```lean
-- Precomputed closure data structure
structure ClosureData (phi : Formula) where
  closure : Finset Formula
  closureWithNeg : Finset Formula
  closureSize : Nat
  boxFormulas : Finset { psi // Formula.box psi ∈ closure }
  temporalFormulas : Finset { psi // Formula.all_past psi ∈ closure ∨ Formula.all_future psi ∈ closure }

def mkClosureData (phi : Formula) : ClosureData phi := ...
```

This avoids recomputing closure on each access.

## Relevant Mathlib Theorems

| Theorem | Use Case |
|---------|----------|
| `Fintype.card_le_of_injective` | Bound |SemanticWorldState| via injection to |FiniteWorldState| |
| `Fintype.card_quotient_le` | Alternative bound via quotient cardinality |
| `Finite.of_injective` | Prove Finite from injection (already used) |
| `Finset.decidableMem` | Decidable closure membership (already used) |
| `Quotient.lift` | Define functions on quotient types (already used) |

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| History gluing is complex | Blocks completeness | Focus effort here; may need auxiliary lemmas about history concatenation |
| Classical dependencies deep | Hard to make computable | Accept propositional proofs as-is; add separate decidable layer for computation |
| Closure dependency on old Metalogic | Blocks deletion of old code | Extract subformulas to Syntax module first |
| Sorry count in Closure.lean (9) | Delays full verification | Most are subformula lemmas - straightforward but tedious |

## Next Steps

1. **Immediate**: Complete the 4 sorries in SemanticCanonicalModel.lean (especially compositionality)
2. **Short-term**: Migrate `Formula.subformulas` to Bimodal.Syntax
3. **Medium-term**: Add decidable versions of key relations for computation
4. **Long-term**: Implement efficient enumeration for decidability procedure

## References

- Metalogic_v2 Architecture: `Theories/Bimodal/Metalogic_v2/FMP.lean`
- SemanticWorldState: `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean`
- FiniteModelProperty: `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`
- Previous research: `specs/470_finite_model_computational_optimization/reports/research-001.md`
- Mathlib Fintype: `Mathlib.Data.Fintype.Card`
