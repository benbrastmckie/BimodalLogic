# Implementation Plan: Task #997 - Wire Algebraic Base Completeness

- **Task**: 997 - Wire algebraic base completeness via validity bridge
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Task 995 (FMCS domain transfer - provides order-embedding CanonicalMCS to Int)
- **Research Inputs**:
  - specs/997_wire_algebraic_base_completeness/reports/03_validity-unification.md
  - specs/997_wire_algebraic_base_completeness/reports/02_post-flagbfmcs-analysis.md
- **Artifacts**: plans/02_validity-bridge-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

This plan addresses the architectural gap between FlagBFMCS completeness (`satisfies_at`) and the canonical validity definition (`valid` in Validity.lean). The research identified that there is ONE canonical validity definition, but `satisfies_at` (FlagBFMCS) is not connected to `truth_at` (TaskFrame). We will prove a bridge lemma via Int-embedding, enabling `algebraic_base_completeness` to use the sorry-free FlagBFMCS infrastructure.

### Research Integration

Key findings from research reports:
1. **One validity definition**: `valid` in `Bimodal.Semantics.Validity` is THE canonical definition
2. **satisfies_at is internal**: NOT a competing validity, just the canonical model satisfaction relation
3. **Gap**: No bridge connects `satisfies_at` to `truth_at`
4. **Type obstacle**: CanonicalMCS lacks AddCommGroup, preventing direct TaskFrame instantiation
5. **Solution path**: Use Int-embedding from task 995 to construct TaskFrame Int

## Goals & Non-Goals

**Goals**:
- Connect FlagBFMCS `satisfies_at` to the canonical `valid` predicate
- Fill the 2 sorries in `AlgebraicBaseCompleteness.lean`
- Achieve `valid phi -> Nonempty (DerivationTree [] phi)` using FlagBFMCS infrastructure
- Maintain one canonical validity definition (no new `valid_flagbfmcs`)

**Non-Goals**:
- Eliminating `satisfies_at` entirely (it serves its purpose as canonical model construction)
- Generalizing `valid` to weaken AddCommGroup requirement (would break soundness proofs)
- Resolving the dovetailing chain sorries in IntBFMCS (separate task 1004)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 995 FMCS transfer not ready | H | M | Check task 995 status; may need to implement minimal transfer |
| Int-embedding introduces new sorries | M | L | Bridge only needs order-preserving map, not full bijection |
| Truth lemma mismatch | M | M | Prove correspondence lemma for modal and temporal cases separately |
| Performance issues with Set.univ flags | L | L | allFlagsBFMCS already uses Set.univ; structure is proven |

## Implementation Phases

### Phase 1: Create Validity Bridge Module [COMPLETED]

**Goal**: Create new file `FlagBFMCSValidityBridge.lean` with the core bridge infrastructure

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean`
- [ ] Import FlagBFMCSCompleteness, Validity, IntFMCSTransfer
- [ ] Define `FlagBFMCS.toTaskFrame_Int`: Construct TaskFrame Int from FlagBFMCS
- [ ] Define `FlagBFMCS.toTaskModel_Int`: Construct TaskModel from FlagBFMCS
- [ ] Define `parametric_to_history_flagbfmcs`: Map FlagBFMCS positions to WorldHistory

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean` (new file)

**Verification**:
- File compiles with `lake build Bimodal.Metalogic.Bundle.FlagBFMCSValidityBridge`
- Core definitions have correct types

---

### Phase 2: Prove Satisfaction-to-Truth Bridge Lemma [PARTIAL]

**Goal**: Prove the key lemma connecting `satisfies_at` to `truth_at`

**Tasks**:
- [ ] Prove `satisfies_at_implies_truth_at`: Forward direction of bridge
  - Atom case: Direct (both use MCS membership)
  - Bot case: Direct (both false)
  - Imp case: By induction
  - Box case: Use modal accessibility correspondence
  - G/H cases: Use temporal ordering correspondence via Int-embedding
- [ ] Prove `truth_at_implies_satisfies_at`: Backward direction (may be weaker)
- [ ] Combine into `satisfies_at_iff_truth_at_at_embedding` (or one-direction if sufficient)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean`

**Verification**:
- Bridge lemma typechecks
- `lean_goal` shows no unexpected proof obligations

---

### Phase 3: Wire to AlgebraicBaseCompleteness [BLOCKED]

**Goal**: Fill the sorries in AlgebraicBaseCompleteness.lean using the bridge

**Tasks**:
- [ ] Update imports in `AlgebraicBaseCompleteness.lean` to include `FlagBFMCSValidityBridge`
- [ ] Replace `construct_bfmcs_from_mcs_Int` usage with FlagBFMCS construction
- [ ] Use `allFlagsBFMCS` (sorry-free, temporally complete)
- [ ] Apply bridge lemma to connect FlagBFMCS satisfaction to validity falsification
- [ ] Verify `algebraic_base_completeness` theorem compiles with no new sorries

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.AlgebraicBaseCompleteness` succeeds
- No new sorries introduced (may inherit existing ones from IntBFMCS)

---

### Phase 4: Verify and Document [COMPLETED]

**Goal**: Ensure proof compiles, document sorry status, update lakefile if needed

**Tasks**:
- [ ] Run `lake build` to verify full project compiles
- [ ] Document any remaining sorries (should only be in IntBFMCS dovetailing)
- [ ] Add module-level docstring explaining the bridge architecture
- [ ] Update lakefile if new file added (likely automatic)

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean` (documentation)
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` (documentation)

**Verification**:
- `lake build` succeeds
- `grep -r "sorry" Theories/Bimodal/Metalogic/` shows expected pattern

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.FlagBFMCSValidityBridge` compiles
- [ ] `lake build Bimodal.Metalogic.Algebraic.AlgebraicBaseCompleteness` compiles
- [ ] `lake build` full project succeeds
- [ ] `algebraic_base_completeness` theorem has no sorries in its direct proof
- [ ] New sorries (if any) are documented and localized to IntBFMCS infrastructure

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean` (new file)
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` (modified)
- `specs/997_wire_algebraic_base_completeness/summaries/03_validity-bridge-summary.md` (on completion)

## Rollback/Contingency

If the bridge approach fails (e.g., Int-embedding introduces intractable sorries):

1. **Fallback A**: Accept two completeness statements
   - Keep `FlagBFMCS_completeness` (sorry-free, relative to `satisfies_at`)
   - Document that `algebraic_base_completeness` requires additional infrastructure (task 1004)

2. **Fallback B**: Define intermediate validity
   - Create `valid_over_CanonicalMCS` that doesn't require AddCommGroup
   - Prove `valid_over_CanonicalMCS phi <-> valid phi` (harder but possible)

3. **Preserve progress**: Git commit at end of each phase to enable rollback

## Technical Notes

### Key Type Constraints

The `valid` definition requires `D : Type` with:
- `AddCommGroup D`
- `LinearOrder D`
- `IsOrderedAddMonoid D`

CanonicalMCS has only:
- `Preorder CanonicalMCS` (via g_content inclusion)

Therefore, we MUST use Int (or another domain with group structure) as the bridge.

### Order-Embedding Strategy

Task 995's FMCS transfer provides an order-embedding `e : CanonicalMCS -> Int` that:
- Preserves temporal ordering: `M < M' -> e(M) < e(M')`
- Maps FlagBFMCS positions to Int-indexed positions

This is sufficient for the bridge lemma, even without a full bijection.

### Existing Infrastructure to Leverage

- `allFlagsBFMCS M0`: FlagBFMCS with flags = Set.univ (temporally complete)
- `satisfies_at_iff_mem`: Truth lemma for FlagBFMCS
- `FlagBFMCS_completeness_set`: Consistent set implies satisfiable in FlagBFMCS
- `ParametricCanonicalTaskFrame Int`: TaskFrame infrastructure for Int
- `construct_bfmcs_from_mcs_Int`: Int-indexed BFMCS construction (has sorries for F/P)
