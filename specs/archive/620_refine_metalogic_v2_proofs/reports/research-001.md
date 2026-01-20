# Research Report: Task #620

**Task**: 620 - refine_metalogic_v2_proofs
**Date**: 2026-01-19
**Focus**: Systematic improvements to Bimodal/Metalogic_v2 proofs for publication quality

## Summary

The Metalogic_v2 directory contains a well-architected implementation of TM bimodal logic metatheory with a representation-first design. The codebase is largely complete with only 3 remaining `sorry` statements. This research identifies specific areas for refinement across proof economy, organization, documentation, and code quality dimensions.

## Current State Analysis

### File Structure (27 files)

```
Metalogic_v2/
├── Core/
│   ├── Basic.lean           (85 lines) - Core definitions
│   ├── DeductionTheorem.lean (459 lines) - Deduction theorem
│   ├── MaximalConsistent.lean (523 lines) - MCS theory
│   └── Provability.lean     (82 lines) - Provability definitions
├── Soundness/
│   ├── Soundness.lean       (309 lines) - Soundness theorem
│   └── SoundnessLemmas.lean (582 lines) - Temporal duality helpers
├── Representation/
│   ├── CanonicalModel.lean  (359 lines) - Canonical model foundation
│   ├── Closure.lean         (796 lines) - Subformula closure
│   ├── ContextProvability.lean (200 lines) - Context-based provability
│   ├── FiniteModelProperty.lean (509 lines) - FMP theorem
│   ├── FiniteWorldState.lean (varies) - Finite world construction
│   ├── RepresentationTheorem.lean (189 lines) - Main representation theorem
│   ├── SemanticCanonicalModel.lean (varies) - Semantic canonical model
│   └── TruthLemma.lean      (184 lines) - Truth lemma
├── Completeness/
│   ├── WeakCompleteness.lean (95 lines) - Weak completeness
│   └── StrongCompleteness.lean (213 lines) - Strong completeness
├── Applications/
│   └── Compactness.lean     (139 lines) - Compactness theorems
├── Decidability/
│   ├── Tableau.lean, Saturation.lean, BranchClosure.lean
│   ├── DecisionProcedure.lean, Correctness.lean
│   ├── ProofExtraction.lean, CountermodelExtraction.lean
│   └── SignedFormula.lean
├── FMP.lean                 (147 lines) - Central hub module
├── Decidability.lean        (varies) - Decidability umbrella
└── README.md                (varies) - Documentation
```

### Known Issues (from ROAD_MAP.md and codebase analysis)

#### Remaining `sorry` Statements (3 total)

| Location | Description | Priority |
|----------|-------------|----------|
| `SemanticCanonicalModel.lean:236` | `semantic_task_rel_compositionality` - finite time domain limitation | Skip |
| `SemanticCanonicalModel.lean:647` | `main_provable_iff_valid_v2` completeness direction | Skip |
| `FiniteModelProperty.lean:481` | `finite_model_property_constructive` truth bridge | Later |
| `Decidability/Correctness.lean:202` | `decide_axiom_valid` - matchAxiom completeness | Maybe |

**Note**: The sorry-free `semantic_weak_completeness` provides the core completeness result, making these non-blocking.

#### Known Technical Issues

1. **Double-negation escape issue** (Closure.lean:515): When `psi = chi.neg` for `chi` in closure, `psi.neg = chi.neg.neg` may escape `closureWithNeg`. Handled via case analysis but adds complexity.

## Findings

### 1. Proof Economy Issues

#### 1.1 Redundant Code Patterns

**Duplicate Definition (contextToSet)**:
- `Core/MaximalConsistent.lean:113`: `def contextToSet`
- `Representation/RepresentationTheorem.lean:45`: `def contextToSetLocal`

Both define the same conversion from `Context` (List Formula) to `Set Formula`. Should consolidate to single definition.

**Repeated Lemma Patterns**:
- `SoundnessLemmas.lean` contains both `axiom_*_valid` (local) and `swap_axiom_*_valid` functions with nearly identical proof structures
- Consider factoring out common patterns into helper tactics or abstractions

#### 1.2 Verbose Proof Patterns

**Example: MCS Negation Completeness** (`CanonicalModel.lean:231-267`):
The proof of `mcs_contains_or_neg` uses explicit construction rather than automation. Could benefit from a custom `mcs_tac` tactic.

**Example: Closure Property Proofs** (`Closure.lean:589-794`):
The proofs for `closure_imp_left`, `closure_imp_right`, etc. all follow similar patterns with `unfold closure; simp only [List.mem_toFinset]; exact Formula.mem_subformulas_of_*`. Could be unified.

#### 1.3 Proof Size Analysis

| Module | Lines | Complexity |
|--------|-------|------------|
| DeductionTheorem.lean | 459 | High (well-founded recursion) |
| MaximalConsistent.lean | 523 | Medium |
| Closure.lean | 796 | High (largest file) |
| SoundnessLemmas.lean | 582 | Medium (many similar proofs) |
| FiniteModelProperty.lean | 509 | Medium |

**Target**: 20% reduction in total proof lines through consolidation and automation.

### 2. Proof Flow and Organization Issues

#### 2.1 Layer Discipline Violations

The import structure is generally clean, but some cross-cutting patterns exist:
- `ContextProvability.lean` imports both `Soundness/Soundness` and `Representation/SemanticCanonicalModel`
- `FiniteModelProperty.lean` imports from multiple layers (Soundness, Representation, Semantics)

**Proposed Util/ Layer**:
```
Util/
├── MCS.lean          # MCS reasoning utilities
├── Closure.lean      # Closure manipulation helpers
└── Derivation.lean   # Derivation tree helpers
```

#### 2.2 File Organization Improvements

**TruthLemma.lean** (184 lines): Very straightforward - truth is defined as set membership. The "lemmas" are mostly `rfl` proofs. Consider:
- Merging into CanonicalModel.lean
- Or keeping separate but adding substantive MCS property proofs

**Basic.lean** (85 lines): Contains definitions but some (`MaximalConsistent`, `FinitelyConsistent`) are duplicated in MaximalConsistent.lean. Should be reconciled.

**Compactness.lean** (139 lines): The theorems are trivial for list-based contexts. The real compactness is implicit in the finiteness of derivations. Consider:
- Adding set-based compactness for more meaningful results
- Or documenting explicitly why list-based compactness is trivial

#### 2.3 Module Overview Comments

All files have `/-! # ... -/` headers, which is good. However:
- Some overviews are outdated (reference old architecture)
- `## Main Results` sections sometimes list `#check` statements rather than documenting theorems
- Missing cross-references between related modules

### 3. Documentation Gaps

#### 3.1 Missing Architectural Documentation

The README.md provides good overview but lacks:
- Proof strategy walkthrough for each major theorem
- Dependency diagram (mentioned in ROAD_MAP.md but not implemented)
- Tutorial showing how to extend the logic

#### 3.2 Stray Comments and TODOs

Found via grep analysis:
- Various inline comments explaining workarounds
- Some `-- KNOWN ISSUE` comments that could be elevated to documentation
- `#check` statements used for re-exports (line noise)

Example `#check` clutter in `FMP.lean`:
```lean
-- Re-export from Core for module clients
#check SetConsistent
#check SetMaximalConsistent
#check set_lindenbaum
```

These serve no purpose beyond documentation and clutter the namespace. Should be removed or converted to proper export declarations.

### 4. Performance Considerations

#### 4.1 Slow Proof Patterns

**DeductionTheorem.lean**: Uses well-founded recursion with explicit termination proofs. The `termination_by h.height` with manual `decreasing_by` blocks adds overhead. Profile to determine actual build impact.

**SoundnessLemmas.lean**: Contains 15+ nearly identical axiom validity proofs. Each introduces and destructs the same structures. Could benefit from tactic macros.

#### 4.2 Build Order

Current structure appears linear with no parallelization opportunities within Metalogic_v2. The layer structure supports parallel builds of independent modules:
- Soundness and Representation layers could potentially build in parallel before Completeness

### 5. Code Quality Issues

#### 5.1 Inconsistent Naming

- `contextToSet` vs `contextToSetLocal` - naming collision
- `ClosureConsistent` vs `SetConsistent` - similar concepts, different naming patterns
- `mcs_*` vs `MCS_*` - inconsistent case conventions

#### 5.2 Unused Definitions

**Basic.lean** defines:
- `MaximalConsistent` (for lists) - may be unused, as `SetMaximalConsistent` is primary
- `FinitelyConsistent` - appears unused in proof infrastructure

**Provability.lean** defines:
- `SetDerivable` - marked "being eliminated per Task 502"
- `Context.extends`, `Context.merge`, `Context.subset` - utility functions, verify usage

## Recommendations

### High Priority (Phase 1)

1. **Consolidate duplicate definitions**
   - Merge `contextToSet` definitions
   - Audit and remove unused definitions in Basic.lean and Provability.lean

2. **Remove #check statements**
   - Replace with proper export declarations or documentation comments
   - Reduces line count and eliminates namespace pollution

3. **Add module roadmap comments**
   - Each file should start with "This file proves: X, Y, Z in that order"
   - Add cross-references to related modules

4. **Clean up stray comments**
   - Elevate KNOWN ISSUE comments to proper documentation
   - Remove obsolete or misleading comments

### Medium Priority (Phase 2)

5. **Create Util/ extraction layer**
   - Factor out common MCS reasoning patterns
   - Create tactic macros for repeated proof structures

6. **Optimize SoundnessLemmas.lean**
   - Create macro for axiom validity proofs
   - Reduce duplication between axiom_*_valid and swap_axiom_*_valid

7. **Improve Closure.lean structure**
   - Group related theorems more coherently
   - Add section headers for major subsections

### Lower Priority (Phase 3)

8. **Address remaining sorries** (per ROAD_MAP.md recommendations)
   - Skip `semantic_task_rel_compositionality` (fundamental limitation)
   - Skip `main_provable_iff_valid_v2` (non-blocking)
   - Consider `finite_model_property_constructive` if pursuing constructive completeness
   - Consider `decide_axiom_valid` as incremental improvement

9. **Performance profiling**
   - Run `lean --profile` on slowest files
   - Identify and optimize hot spots

10. **Architectural refactoring** (per ROAD_MAP.md Phase 4)
    - Make representation theorem the primary export
    - Recast soundness/completeness as corollaries

## Metrics

### Current State

- Total Lean files: 27
- Total estimated lines: ~6,000
- Sorry count: 3 (non-blocking)
- #check statements: ~20 (clutter)
- Duplicate definitions: 2-3 identified

### Target State

- Total lines: 4,800-5,000 (20% reduction)
- Sorry count: 3 (unchanged, acceptable)
- #check statements: 0
- Duplicate definitions: 0
- Layer violations: 0

## References

- ROAD_MAP.md: Detailed roadmap for ProofChecker development
- Blackburn et al., Modal Logic, Chapter 4
- specs/628_complete_research/ (if related research exists)

## Next Steps

1. Run `/plan 620` to create detailed implementation plan
2. Phase work by file/module to enable incremental verification
3. Track proof line counts before/after each change
4. Ensure `lake build` succeeds after each phase
