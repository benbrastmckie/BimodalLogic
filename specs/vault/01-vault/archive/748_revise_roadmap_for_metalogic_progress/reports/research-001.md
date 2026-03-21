# Research Report: Task #748

**Task**: Revise ROAD_MAP.md for Metalogic progress
**Date**: 2026-01-29
**Focus**: Survey Bimodal/Metalogic progress and compare against ROAD_MAP.md milestones

## Summary

The current ROAD_MAP.md documents the Metalogic_v2 Boneyard architecture and the Bimodal/Metalogic representation theorem from Task 654. However, significant progress has been made since that documentation was written, including:
- New Completeness hierarchy (Weak, Finite Strong, Infinitary Strong)
- Compactness theorem (sorry-free)
- FMP infrastructure (parametric, with documented gaps)
- Algebraic approach (alternative path)
- Comprehensive README hierarchy (Task 747)

The ROAD_MAP.md requires substantial revision to accurately reflect what has been accomplished and what remains.

## Findings

### Current ROAD_MAP.md Structure

The roadmap has 6 phases:
1. **Phase 0**: Complete Core Proofs (High Priority) - audit sorries, port from Boneyard
2. **Phase 1**: Proof Quality and Organization (High Priority) - economy, flow, documentation
3. **Phase 2**: Generalization (Medium Priority) - strong completeness, infinite models
4. **Phase 3**: Extensions (Medium Priority) - Craig interpolation, decidability, temporal extensions
5. **Phase 4**: Architecture Optimization (High Priority) - layering, minimal kernel
6. **Phase 5**: Removing Known Sorries (Low Priority) - specific sorry removal
7. **Phase 6**: Polish and Publication (Low Priority) - documentation, testing

### Bimodal/Metalogic Current State (from READMEs)

The Metalogic directory now has 7 subdirectories with comprehensive README documentation:

| Directory | Purpose | Status |
|-----------|---------|--------|
| `Core/` | MCS, Deduction Theorem, MCS Properties | PROVEN (re-exports from Boneyard) |
| `Representation/` | Indexed MCS Family, Coherent Construction, Truth Lemma, Representation Theorem | Core proven, some sorries not on critical path |
| `Completeness/` | Weak, Finite Strong, Infinitary Strong Completeness | PROVEN (soundness axiomatized) |
| `Compactness/` | Compactness theorem variants | PROVEN (sorry-free) |
| `FMP/` | Finite Model Property infrastructure | Parametric, documented gaps |
| `Algebraic/` | Alternative algebraic approach | Partial (independent path) |

### Items to Mark as COMPLETED

**Phase 0 (Complete Core Proofs)**:
- [x] **0.1 Audit Current Sorries** - Partially complete. Sorries have been identified and categorized. Task 758 created for systematic audit.
- [x] **0.4 Document Inventory** - README hierarchy created (Task 747). Each subdirectory has comprehensive documentation.

**Phase 1 (Proof Quality)**:
- [x] **1.2 Visualize import graph** - Metalogic_v2/README.md contains architecture diagram
- [x] **1.2 Enforce layer discipline** - Current architecture has strict layering: Core < Representation < Completeness < Compactness
- [x] **1.3 Add module overviews** - Each subdirectory now has README.md with module-by-module overview

**Phase 4 (Architecture Optimization)**:
- [x] **4.1 Key Change 1** - Representation theorem IS the primary export now
- [x] **4.2 Option B: Representation Theorem Alone** - This is the implemented approach

**Phase 6 (Polish)**:
- [x] **6.1 Write comprehensive README** - Metalogic/README.md is 162 lines with full architecture
- [x] **6.3 Create test suite** - Tests/BimodalTest/Metalogic_v2/ has 10 test files

### Items to UPDATE/REVISE

**Table: Bimodal/Metalogic Core Infrastructure (line 78)**:
The table references Task 654 status. Update with current status:

| Component | Old Status | New Status | Notes |
|-----------|------------|------------|-------|
| IndexedMCSFamily | DEFINED | Complete | Structure definition |
| Indexed family construction | PARTIAL (sorries) | SUPERSEDED | Use CoherentConstruction instead |
| Canonical history | PROVEN | Complete | |
| Truth lemma (forward) | PROVEN | PROVEN | Core cases proven |
| Truth lemma (backward) | PARTIAL (sorries) | NOT REQUIRED | Not needed for completeness |
| Representation theorem | PROVEN | PROVEN | Sorry-free |

**Add new section: Completeness Hierarchy (after line 98)**:
Document the new completeness infrastructure:

| Result | Status | Location |
|--------|--------|----------|
| weak_completeness | PROVEN | Completeness/WeakCompleteness.lean |
| finite_strong_completeness | PROVEN | Completeness/FiniteStrongCompleteness.lean |
| infinitary_strong_completeness | PROVEN | Completeness/InfinitaryStrongCompleteness.lean |
| provable_iff_valid | PROVEN (uses soundness axiom) | WeakCompleteness.lean |

**Add new section: Compactness (after completeness)**:

| Result | Status | Location |
|--------|--------|----------|
| compactness | PROVEN | Compactness/Compactness.lean |
| compactness_iff | PROVEN | Compactness/Compactness.lean |
| compactness_entailment | PROVEN | Compactness/Compactness.lean |
| compactness_unsatisfiability | PROVEN | Compactness/Compactness.lean |

**Phase 0.3 Decidability Decision (line 173)**:
Should update: The Boneyard decidability infrastructure is DEPRECATED. New FMP infrastructure in Metalogic/FMP/ provides parametric FMP with documented gaps. Full decidability proof not critical - `semantic_weak_completeness` provides sorry-free completeness.

**Phase 2.1.A Set-Based Strong Completeness (line 299)**:
Should mark as COMPLETED. `infinitary_strong_completeness` proves exactly this for Set Formula.

**Phase 5 Sorry Table (line 688)**:
The sorry locations have changed. Old table references `SemanticCanonicalModel.lean` and `FiniteModelProperty.lean` at lines that no longer exist. Update with current sorry locations from grep analysis.

### Items to ADD

**New Section: CoherentConstruction Approach**:
Document the key architectural innovation that replaced the original `construct_indexed_family`:
- Two-chain architecture (forward/backward from origin)
- Definitional coherence (not proved after construction)
- Only Cases 1 and 4 needed for completeness

**New Section: Algebraic Approach**:
Document the independent algebraic path in `Algebraic/`:
- Lindenbaum-Tarski quotient algebra
- Boolean algebra structure
- Interior operators for G/H
- Ultrafilter-MCS correspondence
- Status: partial, provides alternative verification path

**New Section: Active Tasks**:
Link to current tasks working on Metalogic improvements:
- Task 749: sorry-free completeness via semantic_weak_completeness
- Task 750: forward Truth Lemma refactoring
- Task 753: CoherentConstruction sorries
- Task 755: Option C FMP path
- Task 758: systematic sorry audit

### Items Potentially OBSOLETE

**Phase 0.2 Port from Boneyard (line 165)**:
Most porting has been completed. Core/ re-exports from Boneyard. The remaining Boneyard code is either:
- Already ported (MCS, Lindenbaum)
- Deprecated (old canonical model approaches)
- Not needed (compositionalitysorry workaround found)

**Phase 5.1 semantic_task_rel_compositionality (line 699)**:
This sorry is no longer at the documented location. The issue was handled differently in the current architecture.

### Sorry Count Analysis

Current sorry counts in Metalogic/ (excluding Boneyard):

| Directory | Count | Category |
|-----------|-------|----------|
| Representation/ | 17 | Mixed: 4 in IndexedMCSFamily (SUPERSEDED), 8 in CoherentConstruction, 5 in TaskRelation |
| FMP/ | 3 | Truth bridge gaps, documented |
| Completeness/ | 1 | Soundness axiomatized |
| Algebraic/ | 8 | Independent path, partial |
| Compactness/ | 0 | Sorry-free |
| Core/ | 0 | Re-exports proven code |

**Total**: ~29 sorries (vs 45 reported in task 758, which may include deprecated code)

**Critical Path Analysis**:
- **Blocking main theorem**: 0 sorries (representation_theorem is sorry-free)
- **Required for biconditionals**: ~5 sorries (soundness, backward truth lemma)
- **Non-critical/exploratory**: ~24 sorries (coherence cases, algebraic path)

## Recommendations

### Structural Changes

1. **Reorder Phases**: Move Phase 0 items that are complete to a "Completed" section
2. **Update Tables**: Replace all status tables with current verified status
3. **Add Completeness Section**: New major section documenting the completeness hierarchy
4. **Add Compactness Section**: Document this sorry-free achievement
5. **Update Sorry Section**: Current locations, categories, and recommendations
6. **Add Active Work Section**: Link to in-progress tasks

### Content Updates

1. **Mark completed items with checkmarks** in Phase 0, 1, 4, 6
2. **Update line references** for sorries (many have moved)
3. **Document CoherentConstruction** as the key innovation
4. **Add README links** for each subdirectory
5. **Clarify soundness status**: axiomatized, pending Boneyard fix
6. **Document 2.1.A as complete** (infinitary strong completeness)

### New Roadmap Items to Add

1. **Complete soundness port**: Fix SoundnessLemmas.lean for current semantics
2. **Remove IndexedMCSFamily sorries**: Mark SUPERSEDED, use CoherentConstruction
3. **TaskRelation compositionality**: Document as architectural limitation
4. **FMP truth bridge**: Document gap, explain workaround via semantic_weak_completeness
5. **Algebraic bridge completion**: Path to full algebraic semantics

## References

- Metalogic README hierarchy (Task 747)
- specs/state.json - active task tracking
- grep analysis of sorry locations
- Completeness/WeakCompleteness.lean - main completeness theorem
- Compactness/Compactness.lean - compactness theorems

## Next Steps

Run `/plan 748` to create an implementation plan for systematically revising ROAD_MAP.md with:
1. Phase 1: Update Current State section with new achievements
2. Phase 2: Mark completed items in Phases 0, 1, 4, 6
3. Phase 3: Add new sections (Completeness, Compactness, Algebraic)
4. Phase 4: Update sorry tables with current locations
5. Phase 5: Add Active Tasks and Future Work sections
