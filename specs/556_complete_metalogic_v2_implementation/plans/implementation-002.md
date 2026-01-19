# Implementation Plan: Task #556 (Revised)

- **Task**: 556 - Complete Metalogic_v2 Implementation
- **Version**: 002
- **Status**: [PLANNED]
- **Effort**: 2-3 hours (reduced from 8-10)
- **Priority**: High
- **Dependencies**: 554 (completed)
- **Research Inputs**:
  - specs/556_complete_metalogic_v2_implementation/reports/research-001.md
  - specs/561_cleanup_and_documentation/reports/research-001.md
- **Previous Plan**: implementation-001.md
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

This plan replaces implementation-001.md in light of substantial progress made through subtasks 557-560, archived tasks 586-593, and related work. The original plan identified 11 sorries and 1 axiom; **all have been resolved**.

### Progress Since Original Plan

| Original Item | Status | Resolution |
|--------------|--------|------------|
| `mcs_contains_or_neg` (Phase 1) | ✅ PROVEN | Task 586 |
| `mcs_modus_ponens` (Phase 1) | ✅ PROVEN | Task 586 |
| `consistent_implies_satisfiable` (Phase 2) | ✅ PROVEN | FiniteModelProperty.lean |
| `subformulaList_finite` (Phase 2) | ✅ PROVEN | FiniteModelProperty.lean |
| `entails_imp_chain` (Phase 3) | ✅ PROVEN | StrongCompleteness.lean |
| `imp_chain_to_context` (Phase 3) | ✅ PROVEN | StrongCompleteness.lean |
| Double negation elimination (Phase 3) | ✅ RESOLVED | Removed/simplified |
| Canonical world contradiction (Phase 3) | ✅ RESOLVED | Removed/simplified |
| `representation_theorem_backward_empty` axiom (Phase 4) | ✅ PROVEN | Task 590, uses Strategy C via `main_provable_iff_valid` |
| `consistent_iff_consistent'` (Phase 5) | ✅ RESOLVED | Task 593, definition unified |
| `necessitation_lemma` (Phase 5) | ✅ PROVEN | Task 588 |

### Current State (January 2026)

- **Sorries in Metalogic_v2**: 0 (verified via grep)
- **Axioms**: 0 custom axioms (only Lean/Mathlib standard axioms)
- **Build status**: `lake build Bimodal.Metalogic_v2` succeeds when old Metalogic/ build issues are resolved
- **README.md**: Outdated (still claims 2 sorries, actually 0)

## Overview

Complete the Metalogic_v2 implementation by:
1. Updating documentation to accurately reflect the representation-theorem-centered architecture
2. Cleaning up historical/outdated comments
3. Resolving build dependency on deprecated Metalogic/ directory

The architecture follows a **representation-first approach** where the Representation Theorem serves as the foundation for:
- **Completeness**: `valid φ → provable φ` via `main_provable_iff_valid`
- **Decidability**: Finite model bound via subformula closure
- **Compactness**: Finite entailment via strong completeness

## Goals & Non-Goals

**Goals**:
- Update README.md to accurately reflect zero sorries and the proven architecture
- Clean historical markers from code comments (identified in task 561 research)
- Ensure `lake build Bimodal.Metalogic_v2` compiles independently
- Prepare for deprecation of old Metalogic/ directory

**Non-Goals**:
- Proving additional theorems (all required theorems are proven)
- Modifying the proven infrastructure
- Deleting old Metalogic/ (separate task after this completes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build failure due to Metalogic/ dependency | Medium | Medium | ContextProvability.lean imports FiniteCanonicalModel.lean from Metalogic/; may need import adjustment |
| Documentation inaccuracies | Low | Low | Research from task 561 provides precise line references |
| Historical markers removal breaks build | Low | Very Low | Comments only, no code changes |

## Implementation Phases

### Phase 1: Documentation Accuracy Update [NOT STARTED]

**Goal**: Update README.md to accurately reflect the proven state of Metalogic_v2.

**Tasks**:
- [ ] Remove "With Sorries" section entirely (lines 89-95)
- [ ] Add `necessitation_lemma` and `finite_model_property` to "Proven" section
- [ ] Update "Future Work" section to remove "Complete remaining sorries"
- [ ] Add note: "All theorems in Metalogic_v2 are fully proven with no sorry statements"
- [ ] Update count from "1 total" to "0" in Future Work

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/README.md`

**Verification**:
- README accurately states zero sorries
- All proven theorems listed in "Proven" section

---

### Phase 2: Historical Markers Cleanup [NOT STARTED]

**Goal**: Remove outdated historical language from code comments.

**Tasks**:
- [ ] WeakCompleteness.lean line 66: Update "which will be proven once..." to "Uses representation_theorem_backward_empty (proven)"
- [ ] FiniteModelProperty.lean line 185: Change "For now, just use" to "Use"
- [ ] ContextProvability.lean line 123: Change "With Strategy C, we now use" to "Strategy C uses"
- [ ] README.md line 159: Remove word "currently"

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean`
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`
- `Theories/Bimodal/Metalogic_v2/README.md`

**Verification**:
- `lake build Bimodal.Metalogic_v2` succeeds
- Grep for "will be proven", "For now", "currently" returns no matches in Metalogic_v2/

---

### Phase 3: Import Dependency Analysis [NOT STARTED]

**Goal**: Analyze and document the dependency on old Metalogic/ directory.

**Tasks**:
- [ ] Identify all imports from `Bimodal.Metalogic.Completeness.FiniteCanonicalModel`
- [ ] Document which definitions/theorems are used:
  - `SemanticCanonicalFrame`, `SemanticCanonicalModel`, `SemanticWorldState`
  - `semantic_weak_completeness`, `main_provable_iff_valid`
  - `FiniteTime`, `temporalBound`
- [ ] Assess whether FiniteCanonicalModel.lean can be moved to Metalogic_v2/ or if duplication is needed
- [ ] Create recommendation for follow-up task on Metalogic/ deprecation

**Timing**: 1 hour

**Files to analyze**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` (line 9)
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Output**:
- Written analysis in implementation summary
- Recommendation for Metalogic/ deprecation approach

**Verification**:
- Dependencies documented
- Clear path forward for deprecation

---

### Phase 4: Build Verification & Summary [NOT STARTED]

**Goal**: Verify complete build and document the representation-theorem-centered architecture.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic_v2` and verify success
- [ ] Verify zero sorries: `grep -r "sorry" Theories/Bimodal/Metalogic_v2/ --include="*.lean"`
- [ ] Verify zero custom axioms: `grep -r "^axiom" Theories/Bimodal/Metalogic_v2/ --include="*.lean"`
- [ ] Document the representation theorem as the architectural center:
  ```
  Representation Theorem (proven)
       ↓
  main_provable_iff_valid (imported from FiniteCanonicalModel)
       ↓
  ┌────┴────┬──────────────┐
  ↓         ↓              ↓
  Weak      Strong         FMP
  Completeness  Completeness   ↓
                           Decidability
                           Compactness
  ```
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- `specs/556_complete_metalogic_v2_implementation/summaries/implementation-summary-YYYYMMDD.md` (create)

**Verification**:
- All builds pass
- Zero sorries confirmed
- Zero custom axioms confirmed

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic_v2` compiles successfully
- [ ] No `sorry` placeholders in any .lean file (grep verification)
- [ ] No project-specific `axiom` declarations (grep verification)
- [ ] README.md accurately reflects implementation state
- [ ] Historical markers removed from identified locations

## Artifacts & Outputs

- `specs/556_complete_metalogic_v2_implementation/plans/implementation-002.md` (this file)
- `specs/556_complete_metalogic_v2_implementation/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified files:
  - `Theories/Bimodal/Metalogic_v2/README.md`
  - `Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` (comments only)
  - `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` (comments only)
  - `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` (comments only)

## Architectural Summary: Representation-First Design

The Metalogic_v2 architecture centers on the **Representation Theorem** as the foundational bridge:

### The Representation Theorem Hierarchy

```
                    Representation Theorem
                    (RepresentationTheorem.lean)
                    Consistent Γ ↔ Satisfiable in Canonical Model
                              │
          ┌───────────────────┼───────────────────┐
          ↓                   ↓                   ↓
    TruthLemma          CanonicalModel      MaximalConsistent
    (MCS ↔ truth)       (construction)      (MCS theory)
          │                   │
          └─────────┬─────────┘
                    ↓
           ContextProvability
           representation_theorem_backward_empty
           (uses main_provable_iff_valid)
                    │
      ┌─────────────┼─────────────┐
      ↓             ↓             ↓
   Weak          Strong        FMP/Decidability
Completeness  Completeness    FiniteModelProperty
  ⊨ φ → ⊢ φ    Γ ⊨ φ → Γ ⊢ φ   Satisfiable → Finite Model
      │             │             │
      └─────────────┼─────────────┘
                    ↓
              Compactness
         (Applications/Compactness.lean)
```

### Key Design Decisions

1. **Strategy C for Completeness**: Uses `main_provable_iff_valid` from FiniteCanonicalModel.lean as the completeness engine, converting `semantic_consequence [] φ` → `valid φ` → `provable φ`

2. **List-Based Contexts**: Uses `List Formula` instead of `Set Formula` for computable proofs, with `MaximalConsistent.lean` providing set-based MCS theory via Zorn's lemma

3. **Modular Soundness**: Soundness is proven independently and combined with completeness for `provable_iff_valid`

4. **FMP as Bridge**: The Finite Model Property connects the representation layer to decidability, though currently using a trivial witness (identity function on satisfiability)

### What Remains for Full Self-Sufficiency

To fully deprecate old Metalogic/, the following from `FiniteCanonicalModel.lean` would need to be either:
- Moved to Metalogic_v2/
- Or re-proven independently

Key imports used by ContextProvability.lean:
- `SemanticCanonicalFrame`, `SemanticCanonicalModel`
- `SemanticWorldState`, `semantic_weak_completeness`
- `main_provable_iff_valid` (the completeness engine)
- `FiniteTime`, `temporalBound`, auxiliary helpers

This is documented for follow-up task planning.

## Rollback/Contingency

If implementation fails:
1. Git revert to pre-implementation commit
2. All proven theorems remain functional
3. Documentation can be reverted independently of code changes
4. Build dependency on Metalogic/ can remain if import changes cause issues
