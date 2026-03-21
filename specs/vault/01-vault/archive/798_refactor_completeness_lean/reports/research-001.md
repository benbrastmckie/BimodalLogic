# Research Report: Refactor Completeness.lean

**Task**: 798 - refactor_completeness_lean
**Session**: sess_1769989120_92b027
**Date**: 2026-02-01

## Executive Summary

The file `Theories/Bimodal/Metalogic/Completeness.lean` is a monolithic ~3720 line file containing both essential completeness infrastructure and deprecated/experimental constructions. This report analyzes the file structure and provides specific extraction and archival recommendations.

## File Analysis

### Current File Statistics
- **Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`
- **Total Lines**: ~3720 lines
- **Sorry Count**: ~15 sorry gaps (mostly in Duration-based infrastructure)
- **Axiom Count**: 5 axioms (`someWorldState_exists`, `anotherWorldState_exists`, `truth_lemma`, `weak_completeness`, `strong_completeness`)

### File Structure Overview

| Line Range | Section | Category |
|------------|---------|----------|
| 1-78 | Imports and module documentation | Keep |
| 79-113 | `Consistent`, `MaximalConsistent` (list-based) | **Extract to Core/SetConsistency.lean** |
| 114-167 | `SetConsistent`, `SetMaximalConsistent`, `ConsistentExtensions`, `contextToSet` | **Extract to Core/SetConsistency.lean** |
| 168-331 | `usedFormulas`, `derivation_uses_finite_context`, chain lemmas | **Extract to Core/Lindenbaum.lean** |
| 332-409 | `ConsistentSupersets`, `set_lindenbaum` (Zorn's lemma) | **Extract to Core/Lindenbaum.lean** |
| 410-733 | MCS helper lemmas, `set_mcs_closed_under_derivation`, propositional MCS properties | **Extract to Core/SetConsistency.lean** |
| 734-1073 | Temporal MCS properties (`set_mcs_all_future_all_future`, `set_mcs_all_past_all_past`, etc.) | Keep in refactored Completeness.lean |
| 1074-1282 | Diamond-box duality proofs | Keep in refactored Completeness.lean |
| 1283-1413 | Saturation lemma stubs, `CanonicalWorldState` | Keep in refactored Completeness.lean |
| 1414-1983 | **Duration construction** (TemporalChain, ChainSegment, PositiveDuration, Grothendieck) | **Archive to Boneyard** |
| 1984-2440 | `canonical_task_rel`, `canonical_nullity`, `canonical_compositionality`, `canonical_frame` | **Archive to Boneyard** |
| 2441-2696 | `forward_seed`, `backward_seed`, `canonical_valuation`, `canonical_model` | **Archive to Boneyard** |
| 2697-3397 | Chain-based history construction (`canonical_forward_chain`, `canonical_backward_chain`, etc.) | **Archive to Boneyard** |
| 3398-3568 | World history helper lemmas, `chain_indexed_history`, `canonical_history` | **Archive to Boneyard** |
| 3569-3648 | `truth_lemma` axiom, `weak_completeness` axiom, `strong_completeness` axiom, `provable_iff_valid` | **Archive to Boneyard** |
| 3649-3720 | Audit documentation | **Archive to Boneyard** |

## Extraction Targets

### 1. Core/SetConsistency.lean (New File)

**Purpose**: Core set-based consistency definitions and basic MCS properties

**Contents to Extract**:
```lean
-- From lines 79-167
def Consistent (Γ : Context) : Prop
def MaximalConsistent (Γ : Context) : Prop
def SetConsistent (S : Set Formula) : Prop
def SetMaximalConsistent (S : Set Formula) : Prop
def ConsistentExtensions (base : Set Formula) : Set (Set Formula)
lemma base_mem_consistent_extensions
def contextToSet (Γ : Context) : Set Formula
lemma consistent_implies_set_consistent

-- From lines 410-733
def inconsistent_derives_bot
def derives_neg_from_inconsistent_extension
def derives_bot_from_phi_neg_phi
lemma maximal_extends_inconsistent
lemma set_mcs_finite_subset_consistent
theorem maximal_consistent_closed
theorem maximal_negation_complete
-- All set_mcs_* propositional lemmas (implication, negation, disjunction, conjunction)
```

**Dependencies**:
- `Bimodal.ProofSystem`
- `Bimodal.Semantics`
- `Bimodal.Metalogic.DeductionTheorem`
- `Bimodal.Theorems.Propositional`

**Estimated Lines**: ~400 lines

### 2. Core/Lindenbaum.lean (New File)

**Purpose**: Lindenbaum's lemma (Zorn's lemma application) and chain consistency lemmas

**Contents to Extract**:
```lean
-- From lines 168-331
def usedFormulas
lemma usedFormulas_subset
lemma usedFormulas_empty_context
lemma usedFormulas_necessitation_eq_nil
theorem derivation_uses_finite_context
def derivation_from_subset_weaken
lemma finite_list_in_chain_member
theorem consistent_chain_union

-- From lines 332-409
def ConsistentSupersets (S : Set Formula) : Set (Set Formula)
lemma self_mem_consistent_supersets
theorem set_lindenbaum  -- Main Lindenbaum lemma using Zorn
```

**Dependencies**:
- `Bimodal.Metalogic.Core.SetConsistency` (new file)
- `Mathlib.Order.Zorn`
- `Mathlib.Order.Preorder.Chain`

**Mathlib Patterns Used**:
- `zorn_subset_nonempty` from `Mathlib.Order.Zorn` (line 386)
- `IsChain` from `Mathlib.Order.Preorder.Chain`

**Estimated Lines**: ~200 lines

## Archive Targets

### Boneyard/Metalogic_v4/Completeness/MonolithicCompleteness.lean (New File)

**Purpose**: Archive deprecated Duration-based canonical model infrastructure

**Contents to Archive**:

#### Duration Construction (lines 1414-1983)
```lean
structure TemporalChain
structure ChainSegment
def ChainSegmentSigma
def orderTypeEquiv
instance orderTypeSetoid
def PositiveDuration := Quotient orderTypeSetoid
-- All PositiveDuration monoid infrastructure
def Duration := Algebra.GrothendieckAddGroup PositiveDuration
-- All Duration order instances
abbrev CanonicalTime : Type := Duration
```

#### Canonical Task Relation (lines 1984-2440)
```lean
def modal_transfer
def future_transfer
def past_transfer
def canonical_task_rel
theorem canonical_nullity
theorem future_formula_persistence
theorem past_formula_persistence
theorem canonical_compositionality  -- Has 7 sorry gaps
def canonical_frame : TaskFrame Duration
```

#### Seed Definitions and Model (lines 2441-2696)
```lean
def forward_seed
theorem forward_seed_consistent  -- Has sorry
def backward_seed
theorem backward_seed_consistent  -- Has sorry
theorem forward_extension  -- Has sorry
theorem backward_extension  -- Has sorry
def canonical_valuation
def canonical_model
```

#### Chain-Based History Construction (lines 2697-3568)
```lean
axiom anotherWorldState_exists
noncomputable def anotherWorldState
noncomputable def chain_step_pd
noncomputable def chain_step
theorem chain_step_pd_ne_zero
noncomputable def canonical_forward_chain
noncomputable def canonical_backward_chain
noncomputable def canonical_states
noncomputable def chain_indexed_states
def chain_domain
noncomputable def chain_index
noncomputable def chain_indexed_history
noncomputable def canonical_history
```

#### Axioms/Stubs (lines 3569-3648)
```lean
axiom someWorldState_exists
axiom truth_lemma
axiom weak_completeness
axiom strong_completeness
theorem provable_iff_valid  -- Uses axioms
```

**Estimated Lines**: ~2800 lines

**Archive Justification**:
- Duration construction has ~15 sorry gaps and is deprecated
- FiniteCanonicalModel.lean contains working proofs via finite model property
- Infrastructure is preserved for potential future reference
- Axioms kept as placeholders point to actual proofs in FiniteCanonicalModel.lean

## Existing Infrastructure Analysis

### Current Core Directory
The `Theories/Bimodal/Metalogic/Core/` directory already contains:
- `Core.lean` - Re-exports MCS theory
- `MaximalConsistent.lean` - Re-exports from Boneyard/Metalogic_v2
- `DeductionTheorem.lean` - Deduction theorem infrastructure
- `MCSProperties.lean` - Essential MCS lemmas

### Boneyard/Metalogic_v2/Core/MaximalConsistent.lean
This file already contains much of the same content as lines 79-409 of Completeness.lean:
- `Consistent`, `MaximalConsistent` definitions
- `SetConsistent`, `SetMaximalConsistent` definitions
- `usedFormulas`, chain lemmas
- `set_lindenbaum` theorem

**Key Finding**: There is significant duplication between `Completeness.lean` and `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean`. The refactoring should consolidate these.

## Dependency Analysis

### What Depends on Completeness.lean?
Files importing `Bimodal.Metalogic.Completeness`:
1. `Completeness/Completeness.lean` - Import wrapper
2. `Completeness/FiniteCanonicalModel.lean` - Contains actual proofs

### Safe Extraction Order
1. Create `Core/SetConsistency.lean` with base definitions
2. Create `Core/Lindenbaum.lean` with Zorn's lemma application
3. Update `Core/MaximalConsistent.lean` to re-export from new files
4. Create archive file in Boneyard
5. Refactor `Completeness.lean` to import from Core and remove archived content

## Recommendations

### Implementation Strategy

1. **Phase 1**: Create `Core/SetConsistency.lean`
   - Extract consistency definitions and basic MCS properties
   - Keep proven content, no sorries in this file

2. **Phase 2**: Create `Core/Lindenbaum.lean`
   - Extract `set_lindenbaum` and supporting chain lemmas
   - This is proven content using `zorn_subset_nonempty`

3. **Phase 3**: Create `Boneyard/Metalogic_v4/Completeness/MonolithicCompleteness.lean`
   - Archive Duration construction (1500+ lines)
   - Archive canonical frame/model infrastructure
   - Archive weak/strong completeness axioms (actual proofs in FiniteCanonicalModel)

4. **Phase 4**: Refactor `Completeness.lean`
   - Import from new Core files
   - Keep only modal/temporal MCS properties
   - Remove archived content
   - Expected final size: ~600-800 lines

### File Organization After Refactor

```
Theories/Bimodal/Metalogic/
├── Core/
│   ├── Core.lean               # Re-exports
│   ├── SetConsistency.lean     # NEW: Consistency definitions
│   ├── Lindenbaum.lean         # NEW: Lindenbaum lemma
│   ├── MaximalConsistent.lean  # Updated re-exports
│   ├── DeductionTheorem.lean   # Existing
│   └── MCSProperties.lean      # Existing
├── Completeness.lean           # REFACTORED: ~700 lines
├── Completeness/
│   ├── Completeness.lean       # Existing wrapper
│   └── FiniteCanonicalModel.lean  # Existing actual proofs
└── ...

Theories/Bimodal/Boneyard/
├── Metalogic_v4/
│   └── Completeness/
│       └── MonolithicCompleteness.lean  # NEW: Archived infrastructure
└── ...
```

### Risk Assessment

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Import cycle issues | Medium | Use proper layer ordering, test `lake build` after each phase |
| Missing dependencies | Low | Thorough analysis complete, dependencies documented |
| Breaking existing code | Low | Only moving/renaming, not modifying logic |
| Duplication with Boneyard/Metalogic_v2 | High | Consider consolidating during refactor |

## Conclusion

The refactoring is feasible and well-scoped. The file naturally divides into:
1. **Essential Core**: Consistency definitions and Lindenbaum lemma (~600 lines to extract)
2. **Modal/Temporal MCS**: Keep in refactored Completeness.lean (~400 lines)
3. **Deprecated Infrastructure**: Duration construction and axioms (~2800 lines to archive)

The existing `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` already contains much of what would go into the new Core files. The implementation should consider whether to consolidate or maintain separation.
