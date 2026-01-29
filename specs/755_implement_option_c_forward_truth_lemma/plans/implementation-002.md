# Implementation Plan: Task #755 (Revised)

- **Task**: 755 - Implement Option C: Forward Truth Lemma via FMP Path
- **Status**: [NOT STARTED]
- **Version**: 002
- **Created**: 2026-01-29
- **Previous Version**: implementation-001.md (blocked by architectural gap)
- **Effort**: 4-6 hours
- **Priority**: High
- **Research Inputs**:
  - specs/755_implement_option_c_forward_truth_lemma/reports/research-001.md
  - specs/755_implement_option_c_forward_truth_lemma/summaries/implementation-summary-20260129.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Revised approach** based on findings from implementation-001.md: Accept that `semantic_weak_completeness` IS the sorry-free completeness theorem. The forward truth lemma (`truth_at_implies_semantic_truth`) cannot be proven for arbitrary `SemanticWorldState`s without architectural changes.

### Why the Original Plan Failed

The original plan tried to prove `truth_at_implies_semantic_truth` for arbitrary SemanticWorldStates. Analysis revealed:

1. `IsLocallyConsistent` only constrains the modus ponens direction (v(imp)=true ∧ v(psi)=true → v(chi)=true)
2. The forward direction (recursive truth → assignment truth) requires MCS properties
3. Arbitrary SemanticWorldStates are not necessarily MCS-derived

### The Solution: Use `semantic_weak_completeness`

The existing `semantic_weak_completeness` theorem IS fully sorry-free and provides:
```lean
semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi), semantic_truth_at_v2 phi w origin phi) → ⊢ phi
```

This theorem works by contrapositive: if phi is not provable, construct an MCS-derived countermodel where phi is false BOTH in assignment AND recursively. MCS-derived states guarantee correspondence.

**Key Insight**: The hypothesis `∀ w, semantic_truth_at_v2 phi w origin phi` is equivalent to saying "phi is true in all finite world state assignments over the closure". This IS a form of validity, just for the finite model rather than all models.

### Revised Goal

Instead of trying to connect `valid phi` (truth in ALL models including infinite ones) to `semantic_truth_at_v2`, we:

1. Document that `semantic_weak_completeness` IS sorry-free completeness for finite models
2. Create a "finite validity" predicate that captures the correct hypothesis
3. Prove that this finite validity implies full validity (soundness direction)
4. Update documentation to clarify the relationship between theorems

## Goals & Non-Goals

**Goals**:
- Provide a clean, documented sorry-free completeness API
- Create `finite_valid` predicate matching `semantic_weak_completeness` hypothesis
- Prove soundness: `finite_valid phi → valid phi` (to show finite validity is weaker)
- Document the architectural limitations and why this is the correct approach
- Update README.md with usage guidance

**Non-Goals**:
- Proving `truth_at_implies_semantic_truth` for arbitrary world states (architecturally blocked)
- Changing the `SemanticCanonicalModel` frame definition
- Removing the compositionality sorry (mathematically false)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `finite_valid` already exists | Low | Low | Search codebase first; reuse if found |
| Soundness proof complex | Medium | Low | Standard FMP soundness argument |
| Documentation unclear | Medium | Medium | Follow existing patterns in FMP/README.md |

## Implementation Phases

### Phase 1: Define Finite Validity Predicate [NOT STARTED]

**Goal**: Create a predicate that captures exactly what `semantic_weak_completeness` requires.

**Tasks**:
- [ ] Search for existing finite validity definitions in codebase
- [ ] Define `finite_valid (phi : Formula) : Prop` as:
  ```lean
  def finite_valid (phi : Formula) : Prop :=
    ∀ (w : SemanticWorldState phi), semantic_truth_at_v2 phi w origin phi
  ```
- [ ] Add documentation explaining the relationship to universal validity

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

**Verification**:
- Definition compiles
- `lean_hover_info` shows expected type

---

### Phase 2: Prove Soundness for Finite Validity [NOT STARTED]

**Goal**: Show that finite validity implies truth in all models (soundness direction).

**Tasks**:
- [ ] Prove `finite_valid_implies_valid`:
  ```lean
  theorem finite_valid_implies_valid (phi : Formula) :
      finite_valid phi → valid phi
  ```
- [ ] The proof should show that if phi is true in all SemanticWorldStates (assignment-based), then phi is true in all models (recursive)
- [ ] This may require showing that SemanticCanonicalModel contains "enough" worlds

**Approach**:
The SemanticCanonicalModel is a particular finite model. If phi is true at all its world states, AND the model is canonical in the sense that it captures all consistent theories, then phi must be valid.

Alternative: This direction may not be needed. The key is that `semantic_weak_completeness` works directly. If `finite_valid phi`, then `⊢ phi`, then by soundness, `valid phi`.

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

**Verification**:
- Soundness theorem compiles without sorry (or uses existing sorries only)

---

### Phase 3: Create Clean API Wrappers [NOT STARTED]

**Goal**: Provide a clean API that users can rely on for completeness.

**Tasks**:
- [ ] Create `completeness_via_finite_model` wrapper:
  ```lean
  /-- Sorry-free completeness: finite validity implies provability.

      Use this theorem for sorry-free completeness proofs.
      The hypothesis requires showing phi is true at all SemanticWorldStates,
      which can be done by case analysis on the finite set of world states.
  -/
  theorem completeness_via_finite_model (phi : Formula) :
      finite_valid phi → ⊢ phi :=
    semantic_weak_completeness phi
  ```
- [ ] Add deprecation notice to `sorry_free_weak_completeness` pointing to new API
- [ ] Document when to use which theorem

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

**Verification**:
- Wrapper compiles and applies `semantic_weak_completeness`

---

### Phase 4: Update Documentation [NOT STARTED]

**Goal**: Update all documentation to reflect the correct usage patterns.

**Tasks**:
- [ ] Update module docstring for SemanticCanonicalModel.lean
- [ ] Update FMP/README.md usage section:
  - Clarify that `semantic_weak_completeness` is the sorry-free theorem
  - Explain when to use `finite_valid` vs `valid`
  - Document the architectural limitation of `truth_at_implies_semantic_truth`
- [ ] Add comments to `sorry_free_weak_completeness` explaining its sorry status
- [ ] Remove or comment out misleading documentation about "proving the forward truth lemma"

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
- `Theories/Bimodal/Metalogic/FMP/README.md`

**Verification**:
- `lake build` passes
- Documentation is accurate and helpful

---

### Phase 5: Cleanup and Verification [NOT STARTED]

**Goal**: Final cleanup and verification.

**Tasks**:
- [ ] Run `lake build` and verify no new errors
- [ ] Verify sorry count is unchanged (2 sorries expected: compositionality + truth_at_implies_semantic_truth)
- [ ] Review all changes for consistency
- [ ] Create implementation summary

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` (final polish)

**Verification**:
- `lake build` passes
- All documentation is consistent
- Implementation summary created

## Testing & Validation

- [ ] `lake build` completes successfully
- [ ] `finite_valid` definition compiles
- [ ] `completeness_via_finite_model` applies correctly
- [ ] Documentation accurately describes the architecture

## Artifacts & Outputs

- `specs/755_implement_option_c_forward_truth_lemma/plans/implementation-002.md` (this file)
- `specs/755_implement_option_c_forward_truth_lemma/summaries/implementation-summary-{DATE}.md` (on completion)
- Modified `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
- Modified `Theories/Bimodal/Metalogic/FMP/README.md`

## Rollback/Contingency

Changes are incremental and additive. If any phase fails:
1. New definitions can be removed without affecting existing code
2. Documentation changes can be reverted
3. The existing `semantic_weak_completeness` theorem remains the primary API

## Technical Notes

### The Key Insight

The "completeness" we want is:
- **Universal validity** (`valid phi`): True in ALL models at ALL times
- **Finite validity** (`finite_valid phi`): True in all SemanticWorldStates (assignment-based)

The sorry-free theorem gives us:
```
finite_valid phi → ⊢ phi
```

By soundness, we also have:
```
⊢ phi → valid phi
```

The gap is:
```
valid phi → finite_valid phi   (requires truth_at_implies_semantic_truth, which has sorry)
```

**However**: For practical use, `finite_valid` is checkable (finite domain) and `semantic_weak_completeness` provides completeness for this checkable condition. This is sufficient for most applications.

### Why This Is The Right Solution

1. **Mathematical correctness**: The theorem IS true and proven
2. **Practical utility**: Users can check `finite_valid` for specific formulas
3. **No circular dependencies**: Avoids the architectural gap
4. **Clear documentation**: Users understand what's proven and what's sorry'd
