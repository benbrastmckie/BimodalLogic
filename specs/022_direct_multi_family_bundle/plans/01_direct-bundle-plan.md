# Implementation Plan: Task #22

- **Task**: 22 - direct_multi_family_bundle
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (task 15 modal saturation infrastructure is already in place)
- **Research Inputs**: specs/022_direct_multi_family_bundle/reports/01_multi-family-research.md, specs/022_direct_multi_family_bundle/reports/02_naming-conventions.md
- **Artifacts**: plans/01_direct-bundle-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the bridge/wrapper pattern in `ClosedFlagIntBFMCS.lean` with a direct multi-family construction where bundle families correspond directly to all `discreteClosedMCS` members. This eliminates 3 modal coverage sorries by ensuring families = closed MCS members by construction, making modal coherence provable via the existing sorry-free `discreteMCS_modal_backward` theorem. The F/P sorries remain as documented blockers from the Int chain dovetailing gap.

### Research Integration

Key findings from the research reports:

1. **Root Cause**: The bridge pattern constructs families independently of `discreteClosedMCS`, then asserts membership. Lindenbaum extensions at chain steps produce arbitrary MCS, not necessarily in the closed set.

2. **Solution**: Index families directly by `discreteClosedMCS` members. Each closed MCS W gives a family via `intFMCS_from_root W`, ensuring coverage by construction.

3. **Naming Conventions**: Use `w/u/v` for world states (MCS), `t/s` for time indices. Avoid `W` as a value variable (reserve for types). Maintain clear separation of MCS (WHAT) from time indices (WHEN).

4. **Sorry Elimination Strategy**:
   - Sorry 1 (modal_backward coverage): Eliminated by construction - families cover discreteClosedMCS
   - Sorry 2 (modal_forward cross-family): Eliminated by saturation property
   - Sorry 3 (chain membership t!=0): N/A - no longer assert chain stays in closed set

## Goals & Non-Goals

**Goals**:
- Eliminate the 3 modal coverage sorries in ClosedFlagIntBFMCS.lean
- Create a direct multi-family BFMCS indexed by `discreteClosedMCS` members
- Maintain compatibility with `AlgebraicBaseCompleteness.lean` interface
- Apply proper naming conventions (w/u/v for MCS, t/s for time)

**Non-Goals**:
- Resolving the F/P dovetailing sorries (out of scope - these are documented blockers)
- Changing the CanonicalMCS or Int domain structures
- Modifying `discreteMCS_modal_backward` or saturation infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type-level complexity with indexed families | M | M | Start with simple structure, use existing FMCS Int infrastructure |
| Cardinality concerns (uncountable discreteClosedMCS) | L | L | Use set-theoretic construction with Choice; avoid enumeration |
| Breaking AlgebraicBaseCompleteness | H | L | Maintain same interface signature; test incrementally |
| Complexity in modal_forward saturation proof | M | M | Leverage existing `discreteMCS_modal_forward` + closed set saturation |

## Implementation Phases

### Phase 1: Define Direct Family Structure [COMPLETED]

**Goal**: Create the `DirectClosedFamily` structure that wraps an FMCS Int with a closed MCS root.

**Tasks**:
- [ ] Create new file `DirectMultiFamilyBFMCS.lean`
- [ ] Define `DirectClosedFamily` structure with root MCS and constraint
- [ ] Define `intFMCS_from_root` constructor (or reference existing one)
- [ ] Prove `root_at_zero` property: `(intFMCS_from_root w).mcs 0 = w.world`
- [ ] Add proper docstrings following naming conventions

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` (NEW) - Direct family structure

**Verification**:
- File compiles with `lake build`
- Structure correctly constrains root to `discreteClosedMCS`
- No new sorries introduced

---

### Phase 2: Construct Direct BFMCS Bundle [COMPLETED]

**Goal**: Build the BFMCS Int where families are exactly the projection of DirectClosedFamily roots.

**Tasks**:
- [ ] Define `directMultiFamilyBFMCS` construction
- [ ] Prove `nonempty` using M0 root membership
- [ ] Prove `eval_family` and `eval_family_mem`
- [ ] Leave `modal_forward` and `modal_backward` as sorries initially

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` - Add BFMCS construction

**Verification**:
- BFMCS structure compiles
- Nonempty and eval_family proofs complete
- Structure uses families indexed by discreteClosedMCS

---

### Phase 3: Prove Modal Forward (Saturation) [IN PROGRESS]

**Goal**: Prove `modal_forward` using closed set saturation property.

**Tasks**:
- [ ] Formulate coverage lemma: families cover discreteClosedMCS at each time t
- [ ] Prove modal_forward via: Box phi in any MCS implies phi in that MCS (T-axiom), and by saturation phi in all MCS
- [ ] Connect FMCS-level statement to MCS-level `discreteMCS_modal_forward`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` - Add modal_forward proof

**Verification**:
- No sorry in `modal_forward` proof
- Proof uses existing `discreteMCS_modal_forward` or saturation lemmas
- Coverage argument is sound

---

### Phase 4: Prove Modal Backward (Coverage) [NOT STARTED]

**Goal**: Prove `modal_backward` using direct coverage of discreteClosedMCS.

**Tasks**:
- [ ] Prove coverage lemma: phi in all families at t implies phi in all W in discreteClosedMCS
- [ ] Apply `discreteMCS_modal_backward` which is already sorry-free
- [ ] Connect FMCS-level result back to BFMCS constraint

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` - Add modal_backward proof

**Verification**:
- No sorry in `modal_backward` proof
- Proof uses existing `discreteMCS_modal_backward`
- The 3 original coverage sorries are eliminated

---

### Phase 5: Integration and Deprecation [NOT STARTED]

**Goal**: Wire new construction to AlgebraicBaseCompleteness and deprecate old bridge pattern.

**Tasks**:
- [ ] Define `construct_bfmcs_from_mcs_Int_v4` using new direct construction
- [ ] Update `AlgebraicBaseCompleteness.lean` to use v4 (or keep v3 reference updated)
- [ ] Add deprecation notice to `ClosedFlagIntBFMCS.lean` (mark as superseded)
- [ ] Verify `lake build` succeeds for full project
- [ ] Document sorry inventory in new file (F/P remain)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` - Add v4 construction function
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` - Update import/reference
- `Theories/Bimodal/Metalogic/Bundle/ClosedFlagIntBFMCS.lean` - Add deprecation notice

**Verification**:
- `lake build` succeeds
- `algebraic_base_completeness` theorem still compiles
- Old 3 coverage sorries no longer present in active code path
- F/P sorries properly documented as remaining blockers

## Testing & Validation

- [ ] `lake build` passes for all modified files
- [ ] `lean_goal` shows no unexpected errors at key proof points
- [ ] Sorry count decreased by 3 (modal coverage sorries eliminated)
- [ ] F/P sorries remain documented but not increased
- [ ] Naming conventions applied consistently (w/u/v for MCS, t/s for time)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` - New direct construction (main deliverable)
- Updated `AlgebraicBaseCompleteness.lean` - Uses new construction
- Deprecated `ClosedFlagIntBFMCS.lean` - Marked as superseded

## Rollback/Contingency

If the direct construction approach fails:
1. Keep `ClosedFlagIntBFMCS.lean` as primary (current state)
2. Move new file to Boneyard with analysis notes
3. Document why direct indexing didn't work as expected
4. Consider alternative: shifted families `{ shiftedFamily W s | W in discreteClosedMCS, s : Int }` as noted in research

The existing completeness theorem remains functional with documented sorries, so rollback preserves current functionality.
