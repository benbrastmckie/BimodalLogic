# Implementation Plan: Task #608

- **Task**: 608 - Restructure Completeness via Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: None (self-contained refactoring)
- **Research Inputs**: specs/608_restructure_completeness_via_representation_theorem/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements Strategy A from the research report: port the proven `semantic_weak_completeness` theorem from the old Metalogic to Metalogic_v2. The old theorem (lines 3644-3713 of FiniteCanonicalModel.lean) uses `semantic_truth_at_v2` to define truth internally to the finite model, avoiding the problematic truth bridge that plagues the current Metalogic_v2 approach. The existing Metalogic_v2 infrastructure already has all the pieces needed (`SemanticWorldState`, `semantic_task_rel`, `worldStateFromClosureMCS`, `finite_history_from_state`).

### Research Integration

From research-001.md:
- The core problem is the truth bridge gap between `truth_at` (quantifies over all histories/times) and finite model truth
- The old Metalogic's `semantic_weak_completeness` avoids this by defining truth directly on SemanticWorldState
- This approach is proven (no new sorries needed for the core completeness result)
- The proof uses contrapositive: not provable -> exists countermodel -> valid -> provable

## Goals & Non-Goals

**Goals**:
- Port `semantic_truth_at_v2` definition to Metalogic_v2
- Port `semantic_weak_completeness` theorem to Metalogic_v2
- Update `main_provable_iff_valid_v2` to route through the ported theorem
- Reduce sorry count in the completeness path
- Update documentation to reflect the new architecture

**Non-Goals**:
- Fix unrelated sorries (`closure_mcs_neg_complete`, `closure_mcs_implies_locally_consistent`)
- Prove the truth bridge lemma (`semantic_truth_implies_truth_at`) - this becomes deprecated
- Change the overall Metalogic_v2 directory structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Port introduces import conflicts | Medium | Low | Test each step with `lake build`; both use similar infrastructure |
| `semantic_truth_at_v2` dependencies missing | Medium | Low | Infrastructure already exists in Metalogic_v2 |
| Build errors from naming differences | Low | Medium | Careful adaptation of names; use lean_hover_info |
| `finite_history_from_state` has sorry | Low | Low | Acceptable - constant function placeholder works for completeness |

## Implementation Phases

### Phase 1: Add semantic_truth_at_v2 Definition [NOT STARTED]

**Goal**: Port the `semantic_truth_at_v2` definition from old Metalogic to Metalogic_v2's SemanticCanonicalModel.lean

**Tasks**:
- [ ] Read old Metalogic definition at line 3072 of FiniteCanonicalModel.lean
- [ ] Add `semantic_truth_at_v2` to SemanticCanonicalModel.lean after `semantic_truth_at` (around line 410)
- [ ] The definition uses `closure` membership and `toFiniteWorldState.models`
- [ ] Run `lake build Bimodal.Metalogic_v2` to verify

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Add definition

**Verification**:
- `lake build Bimodal.Metalogic_v2` succeeds without new errors
- Definition matches old Metalogic semantically

---

### Phase 2: Add semantic_truth_lemma_v2 [NOT STARTED]

**Goal**: Port the simplified truth lemma that connects membership to semantic truth

**Tasks**:
- [ ] Read old Metalogic theorem at lines 3156-3166 of FiniteCanonicalModel.lean
- [ ] Add `semantic_truth_lemma_v2` after `semantic_truth_at_v2` definition
- [ ] Proof is direct from definition (should be similar to old proof)
- [ ] Verify with `lake build`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Add theorem

**Verification**:
- `lake build Bimodal.Metalogic_v2` succeeds
- Theorem statement matches old Metalogic

---

### Phase 3: Port semantic_weak_completeness Theorem [NOT STARTED]

**Goal**: Port the main completeness theorem that avoids the truth bridge

**Tasks**:
- [ ] Read old Metalogic theorem at lines 3644-3713 of FiniteCanonicalModel.lean
- [ ] Add `semantic_weak_completeness` after the truth lemma
- [ ] Adapt to Metalogic_v2 naming:
  - `SetConsistent` -> same (already in Metalogic_v2)
  - `set_lindenbaum` -> same (already in Metalogic_v2)
  - `mcs_projection_is_closure_mcs` -> same (already in Metalogic_v2)
  - `worldStateFromClosureMCS` -> same (already in Metalogic_v2)
  - `finite_history_from_state` -> same (already in Metalogic_v2)
  - `SemanticWorldState.ofHistoryTime` -> same (already in Metalogic_v2)
- [ ] The proof structure follows: contrapositive, build countermodel, derive contradiction
- [ ] Verify with `lake build`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Add theorem

**Verification**:
- `lake build Bimodal.Metalogic_v2` succeeds
- Theorem compiles without additional sorries beyond inherited ones

---

### Phase 4: Update main_weak_completeness_v2 [NOT STARTED]

**Goal**: Rewrite `main_weak_completeness_v2` to use `semantic_weak_completeness`

**Tasks**:
- [ ] Examine current `main_weak_completeness_v2` at lines 597-656
- [ ] The key insight: `semantic_weak_completeness` gives `(forall w, semantic_truth_at_v2 ... phi) -> provable phi`
- [ ] Need to show: `valid phi -> (forall w, semantic_truth_at_v2 ... phi)`
- [ ] This requires showing validity in SemanticCanonicalModel implies finite model truth
- [ ] Alternative: use contrapositive chain directly
- [ ] If bridge is still needed, document clearly; if avoidable, remove sorry

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Modify theorem

**Verification**:
- `lake build Bimodal.Metalogic_v2` succeeds
- Ideally, sorry count decreases

---

### Phase 5: Update Documentation [NOT STARTED]

**Goal**: Update README.md and docstrings to reflect the new architecture

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic_v2/README.md`:
  - Document `semantic_weak_completeness` approach
  - Update sorry table (add new status, mark deprecated approaches)
  - Add section on architectural decision
- [ ] Add docstrings to new definitions/theorems explaining:
  - Why `semantic_truth_at_v2` avoids the bridge problem
  - How this connects to the representation theorem
- [ ] Mark `semantic_truth_implies_truth_at` as deprecated in its docstring
- [ ] Run final `lake build Bimodal.Metalogic_v2` to confirm everything compiles

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/README.md` - Update documentation
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Add/update docstrings

**Verification**:
- README accurately reflects current sorry state
- All docstrings are accurate and helpful

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic_v2` completes successfully after each phase
- [ ] No new sorries introduced (beyond inherited from existing infrastructure)
- [ ] `semantic_weak_completeness` compiles and matches old Metalogic semantically
- [ ] `main_provable_iff_valid_v2` still correctly states provability/validity equivalence
- [ ] README.md sorry table matches actual sorry count from `lake build`

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Updated with ported theorems
- `Theories/Bimodal/Metalogic_v2/README.md` - Updated documentation
- `specs/608_restructure_completeness_via_representation_theorem/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the port introduces unfixable issues:
1. Revert SemanticCanonicalModel.lean changes via `git checkout`
2. The existing sorry-based approach remains functional
3. Document blockers in research report for future investigation

The existing implementation with sorries remains valid - this refactoring aims to reduce sorries but doesn't break existing functionality if partial.
