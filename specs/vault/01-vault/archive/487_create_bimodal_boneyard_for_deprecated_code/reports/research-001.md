# Research Report: Task #487

**Task**: Create Bimodal/Boneyard/ for deprecated code
**Date**: 2026-01-13
**Focus**: Identify deprecated completeness code for archival in Boneyard directory

## Summary

Research identified two categories of deprecated code totaling approximately 2,400 lines across two files. The syntactic approach in FiniteCanonicalModel.lean (lines 740-1650, ~900 lines) and the infinite Duration-based code in Completeness.lean (lines 1415-2200, ~785 lines) are candidates for the Boneyard. Both have been superseded by the semantic approach using SemanticWorldState.

## Findings

### 1. File Analysis Summary

| File | Total Lines | Deprecated Code | Active Code |
|------|-------------|-----------------|-------------|
| FiniteCanonicalModel.lean | 3,823 | ~900 (lines 740-1650) | ~2,900 |
| Completeness.lean | 3,719 | ~785 (lines 1415-2200) | ~2,900 |

### 2. Deprecated Code in FiniteCanonicalModel.lean

**Location**: Lines ~740-1650 (approximately)

**Sections to deprecate**:
- **Phase 2-4: Finite World States and Task Relation (Original Approach)** (lines 740-1320)
  - `IsLocallyConsistent` - Consistency definition (soundness only, not maximality)
  - `FiniteWorldState` - Syntactic world states with local consistency
  - `FiniteTaskRel` namespace - Task relation via transfer conditions
  - `finite_task_rel` - Original task relation definition
  - Related lemmas and helper functions

- **Deprecated Truth Lemma** (lines 3283-3520)
  - `finite_truth_lemma` - Has 6+ sorry gaps in backward directions
  - `finite_weak_completeness` - Axiom, never proven

**Why deprecated**: The `IsLocallyConsistent` definition only captures soundness (one direction), not the maximality/negation-completeness needed for truth lemma backward directions. Task 473 introduced `SemanticWorldState` as quotients of (history, time) pairs, making compositionality trivial by construction.

**Key comment from file (lines 24-34)**:
```
### 1. Syntactic Approach (Original, DEPRECATED)

The original approach using `FiniteWorldState`, `finite_task_rel`, and `finite_truth_lemma`.

**Status**: Has 6+ sorry gaps in backward directions due to requiring negation-completeness.
The `IsLocallyConsistent` definition only provides soundness (one direction), not the
maximality needed for completeness proofs.
```

### 3. Deprecated Code in Completeness.lean

**Location**: Lines ~1415-2200 (approximately)

**Sections to deprecate**:
- **Agnostic Duration Construction (Task 446)** (lines 1416-1965)
  - `TemporalChain` structure
  - `ChainSegment` structure
  - `ChainSegmentSigma` - Sigma type for segments
  - `orderTypeEquiv` - Equivalence relation
  - `orderTypeSetoid` - Setoid instance
  - `PositiveDuration` - Quotient of segments
  - `PositiveDuration.zero`, `add`, `nsmul`
  - `AddCommMonoid PositiveDuration` instance
  - `Duration` - Grothendieck group completion
  - `Duration.le`, `instPreorder`, `instPartialOrder`, `instLinearOrder`
  - `Duration.instIsOrderedAddMonoid`
  - `CanonicalTime` abbreviation (using Duration)

- **Canonical Task Relation (Duration-based)** (lines 1990-2200)
  - `modal_transfer`, `future_transfer`, `past_transfer`
  - `canonical_task_rel` - Using Duration as time
  - `canonical_nullity`
  - `future_formula_persistence`, `past_formula_persistence`
  - `canonical_compositionality`

**Why deprecated**: The Duration-based approach was an attempt to be "agnostic" about temporal structure (discrete/dense/continuous). However, the finite model approach proved more tractable. The semantic approach with `FiniteTime k` and `SemanticWorldState` successfully achieved completeness. The Duration construction has multiple sorry gaps and was never completed.

**Axiom in deprecated code**:
```lean
axiom someWorldState_exists : ∃ S : Set Formula, SetMaximalConsistent S
```

### 4. Code to KEEP (Not Deprecated)

**In FiniteCanonicalModel.lean**:
- Phase 1: FiniteTime, closure definitions (lines 1-740)
- Phase 5-7: SemanticWorldState approach (lines 1650-3280)
  - `SemanticWorldState` - Quotient of (history, time) pairs
  - `SemanticTaskRelV2` namespace
  - `semantic_truth_lemma_v2` - Proven, no sorries
  - `semantic_weak_completeness` - Proven
  - `SemanticCanonicalFrame`, `SemanticCanonicalModel`
- Summary sections and documentation

**In Completeness.lean**:
- Lines 1-1415: Consistency definitions, Lindenbaum infrastructure (all proven)
- Lines 2200+: MCS properties, set_mcs_* theorems (all proven)

### 5. Sorries in Deprecated Code

**FiniteCanonicalModel.lean (deprecated sections)**:
- `closureSize_le_complexity` - Sorry in closure size lemma
- `closure_consistent_empty` - Sorry in empty set consistency
- `closure_lindenbaum_via_projection` - Sorry in maximality case
- `closure_mcs_negation_complete` - Sorry in negation completeness
- `closure_mcs_imp_closed` - Sorry in implication closure
- `finite_truth_lemma` - 6+ sorries in backward directions

**Completeness.lean (deprecated sections)**:
- `concat_respects_equiv` - Sorry in concatenation equivalence
- `PositiveDuration.zero_add` - Sorry in identity proof
- `PositiveDuration.add_zero` - Sorry in identity proof
- `PositiveDuration.add_assoc` - Sorry in associativity
- `PositiveDuration.add_comm` - Sorry in commutativity
- `IsLeftCancelAdd PositiveDuration` - Sorry in cancellation
- `Duration.le_antisymm` - Sorry in antisymmetry
- `Duration.le_total` - Sorry in totality
- Plus sorries in canonical_compositionality cases

### 6. Boneyard Directory Structure

Recommended structure:
```
Theories/Bimodal/Boneyard/
├── README.md                           # Documentation of deprecation reasons
├── SyntacticApproach.lean             # From FiniteCanonicalModel.lean
│   - FiniteWorldState
│   - FiniteTaskRel
│   - finite_truth_lemma
│   - finite_weak_completeness
└── DurationConstruction.lean          # From Completeness.lean
    - TemporalChain, ChainSegment
    - PositiveDuration, Duration
    - canonical_task_rel (Duration-based)
```

### 7. Import Considerations

**Boneyard files will need**:
- `import Bimodal.Syntax.Formula`
- `import Bimodal.Semantics`
- `import Bimodal.ProofSystem`
- `import Bimodal.Metalogic.Decidability.SignedFormula`
- `import Bimodal.Metalogic.Completeness` (for SetMaximalConsistent, etc.)
- Mathlib imports for order theory, Grothendieck groups

**Main files will need updates**:
- Remove deprecated code from FiniteCanonicalModel.lean
- Remove deprecated code from Completeness.lean
- Update any cross-references

## Recommendations

1. **Create Boneyard directory structure** with proper documentation
2. **Move syntactic approach code** from FiniteCanonicalModel.lean (~900 lines)
3. **Move Duration construction** from Completeness.lean (~785 lines)
4. **Add deprecation README** explaining why code was deprecated
5. **Update lakefile.lean** if Boneyard files should not be built by default
6. **Verify lake build** succeeds after refactoring
7. **Update documentation** to reference Boneyard for historical context

## Dependencies

- No tasks depend on this refactoring
- This is cleanup work that preserves historical code without blocking active development

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking imports | Build failure | Test lake build after each move |
| Losing git history | Reduced traceability | Use git mv or preserve history notes |
| Incomplete extraction | Orphaned code | Grep for references before removing |

## References

- FiniteCanonicalModel.lean module documentation (lines 13-95)
- Task 473: SemanticWorldState architecture
- Task 446: Duration construction
- Task 458: Completeness research
- specs/473_fix_compositionality_gaps_task_458/reports/research-004.md

## Next Steps

Run `/plan 487` to create detailed implementation plan for code extraction and Boneyard organization.
