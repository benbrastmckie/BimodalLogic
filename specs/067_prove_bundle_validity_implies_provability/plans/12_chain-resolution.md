# Implementation Plan: Task #67 (Plan v12)

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 5-7 hours
- **Dependencies**: Report 34 (team research: construction-level gap analysis)
- **Research Inputs**: specs/067_prove_bundle_validity_implies_provability/reports/34_team-research.md
- **Artifacts**: plans/12_chain-resolution.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Resolve the `k >= B` blocker (lines 3006, 3037) by proving that the boundary condition `iter_F d theta in chain(k)` with `iter_F (d+1) theta not in chain(k)` **implies** `k < B`. This is a semantic property that must hold because:

1. After step B, the chain stabilizes (all F-resolutions complete at max depth)
2. A formula cannot have an "active boundary" in a stabilized chain
3. Therefore, any active boundary implies we haven't reached stabilization, i.e., `k < B`

This approach directly proves the chain stabilization lemma that Teammate A identified as missing, rather than trying to bypass it.

### Why This Approach (from Team Research)

The research identified that the current construction allows indefinite deferral at sub-maximal depths. However, the key insight is: **we don't need to prove that deferral eventually stops globally** - we only need to prove that **at positions k >= B, there are no active boundaries**.

The boundary condition requires:
- `iter_F d theta in chain(k)` (formula with d F-prefixes exists)
- `iter_F (d+1) theta not in chain(k)` (formula with d+1 F-prefixes doesn't exist)

For k >= B, the chain has had B steps to resolve all F-nesting levels. The `boundary_resolution_set` forces resolution at depth B-1 (max depth). Once max-depth formulas are resolved, their immediate parents become max-depth and get resolved in the next step, cascading down.

### Previous Progress (from Plan v11)

- Phase 1 partially completed: fuel=0 sorry eliminated, but k>=B case introduced two new sorries
- The new sorries are at lines 3006 and 3037, both in the `k >= B` branch
- The current code has `exfalso` but lacks the stabilization lemma

## Goals & Non-Goals

**Goals**:
- Prove `boundary_implies_k_lt_B`: When boundary condition holds, `k < B`
- Use this lemma to close the two sorries at lines 3006 and 3037
- Apply same approach to Phase 2-4 sorries if they have similar structure
- Achieve sorry-free completeness path

**Non-Goals**:
- Proving fairness for all F-resolutions (only proving stabilization at boundaries)
- Restructuring the chain construction (the construction is adequate)
- Eliminating deprecated sorries (lines 1659, 1688, 2005)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stabilization lemma requires properties not in current API | H | M | Add properties to `restricted_forward_chain` incrementally |
| Cascade argument is harder than expected | M | M | Split into per-depth lemmas: B-1 first, then B-2, etc. |
| `boundary_resolution_set` semantics unclear | M | L | Read existing proofs carefully; use lean_goal to explore |
| Phases 2-4 have different structure | L | M | Adapt approach; same principle should apply |

## Implementation Phases

### Phase 1: Prove Boundary Stabilization Lemma [BLOCKED]

**Goal**: Prove that boundary conditions imply `k < B`.

**Target**: New lemma `boundary_implies_k_lt_B` in SuccChainFMCS.lean

**Tasks**:
- [ ] Study `boundary_resolution_set` and how it forces max-depth resolution
- [ ] Prove `max_depth_resolved_after_B`: At k >= B, all formulas at depth B-1 are resolved
- [ ] Prove `cascade_resolution`: If depth d+1 formulas are resolved, depth d boundaries clear
- [ ] Combine to prove `boundary_implies_k_lt_B`:
  ```lean
  theorem boundary_implies_k_lt_B (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
      (h_d_ge : d >= 1)
      (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
      (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k) :
      k < closure_F_bound phi := by
    -- Proof: If k >= B, all F-boundaries have been resolved
    -- Having an active boundary contradicts this
    sorry
  ```

**Key insight**: The boundary condition is incompatible with stabilization because:
- At k >= B, all max-depth formulas (depth B-1) have been resolved
- Resolution cascades downward: resolving depth d+1 clears depth d boundaries
- After B steps, all boundaries are cleared

**Timing**: 2 hours

**Verification**:
- New lemma compiles with `lake build`
- Lemma applies to the exact hypotheses available in `restricted_bounded_witness_wf`

---

### Phase 2: Apply to Forward Bounded Witness [NOT STARTED]

**Goal**: Close the two sorries at lines 3006 and 3037 using the stabilization lemma.

**Target**: `restricted_bounded_witness_wf` in SuccChainFMCS.lean, lines 3006 and 3037

**Tasks**:
- [ ] At line 3006 (first k >= B branch):
  ```lean
  -- Current: sorry
  -- Replace with:
  have h_k_lt := boundary_implies_k_lt_B phi M0 k theta (n+1) (by omega) h_iter_in h_iter_not
  exact Nat.not_lt.mpr hk h_k_lt
  ```
- [ ] At line 3037 (second k >= B branch):
  ```lean
  -- Current: sorry
  -- Replace with:
  -- Need to reconstruct boundary condition for F(iter_F n theta)
  have h_k_lt := boundary_implies_k_lt_B phi M0 k (iter_F n theta) d' h_d'_ge h_d'_in h_d'_not
  exact Nat.not_lt.mpr hk h_k_lt
  ```
- [ ] Verify both cases close with `lake build`

**Challenge**: The second sorry (line 3037) involves `F(iter_F n theta)` rather than `theta` directly. Need to verify the boundary condition is formulated correctly.

**Timing**: 1.5 hours

**Verification**:
- Lines 3006 and 3037 sorries eliminated
- `lake build` passes
- `#print axioms restricted_bounded_witness` shows no sorryAx

---

### Phase 3: Apply to Backward Bounded Witness [NOT STARTED]

**Goal**: Apply the same approach to eliminate the backward chain sorry.

**Target**: `restricted_backward_bounded_witness_fueled` (line ~5610)

**Tasks**:
- [ ] Locate the sorry in the backward bounded witness
- [ ] Determine if the same `k >= B` pattern exists
- [ ] Either:
  - Apply `boundary_implies_k_lt_B` directly if applicable
  - Or create `backward_boundary_implies_k_lt_B` variant
- [ ] Close the sorry

**Expected structure**: The backward chain should have the same stabilization property, just with `G` instead of `F`. May need a symmetric lemma.

**Timing**: 1 hour

**Verification**:
- Line 5610 sorry eliminated
- `lake build` passes

---

### Phase 4: Apply to Combined Witnesses [NOT STARTED]

**Goal**: Apply to the Int-indexed combined witnesses (forward and backward/P).

**Targets**:
- `restricted_combined_bounded_witness_fueled` (line ~5768)
- `restricted_combined_bounded_witness_P_fueled` (line ~5964)

**Tasks**:
- [ ] Examine the Int-indexed structure
- [ ] Determine how position relates to chain step count
- [ ] Apply boundary stabilization with appropriate conversion
- [ ] Close both sorries

**Int-indexed adjustment**: Position `n : Int` tracks offset from origin. The stabilization argument should still apply because the CHAIN step count (not position) determines stabilization.

**Timing**: 1.5 hours

**Verification**:
- Lines 5768 and 5964 sorries eliminated
- `lake build` passes

---

### Phase 5: Verification & Axiom Check [NOT STARTED]

**Goal**: Verify the entire completeness path is sorry-free.

**Tasks**:
- [ ] `#print axioms restricted_bounded_witness`
- [ ] `#print axioms restricted_backward_bounded_witness`
- [ ] `#print axioms restricted_combined_bounded_witness`
- [ ] `#print axioms restricted_combined_bounded_witness_P`
- [ ] `#print axioms build_restricted_tc_family`
- [ ] `#print axioms bundle_validity_implies_provability`
- [ ] Document any remaining sorry dependencies

**Timing**: 0.5 hours

**Verification**:
- All axiom checks show no sorryAx
- `lake build` clean
- Completeness path fully proved

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] Phase 1: `boundary_implies_k_lt_B` lemma proven
- [ ] Phase 2: Lines 3006, 3037 sorries eliminated
- [ ] Phase 3: Line 5610 sorry eliminated
- [ ] Phase 4: Lines 5768, 5964 sorries eliminated
- [ ] Phase 5: `#print axioms bundle_validity_implies_provability` shows no sorryAx

## Artifacts & Outputs

- Modified `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`:
  - New lemma `boundary_implies_k_lt_B`
  - Fixed `restricted_bounded_witness_wf`
  - Fixed backward and combined bounded witnesses
- Implementation summary documenting the stabilization approach

## Rollback/Contingency

If the stabilization lemma is harder than expected:

1. **Per-depth induction**: Instead of proving stabilization for all depths at once, prove for depth B-1 first, then B-2, working down.

2. **Strengthen initial fuel**: If cascade is complex, use Option D (add `k < B` hypothesis) as fallback. This is less elegant but works.

3. **Partial stabilization**: Prove stabilization only for the specific `theta` values that appear in bounded witness calls, not for all formulas.

## Technical Notes

### Why `k >= B` Cannot Have Active Boundaries

The `boundary_resolution_set` mechanism ensures:
1. At each step, if `F(F(chi)) not in deferralClosure phi`, the boundary is forced
2. `deferralClosure phi` has bounded F-nesting (max depth B-1)
3. After B steps, formulas at all F-nesting depths have been through the boundary check

The cascade works because:
- Step B: All depth B-1 formulas resolved (forced by boundary_resolution_set)
- Step B-1: All depth B-2 boundaries cleared (their successors are now resolved)
- ... continuing down to depth 0

An "active boundary" at k >= B would require a formula that escaped all B boundary checks, which contradicts the construction.

### Difference from Research Option C

This approach is a **hybrid**: it proves the stabilization lemma (like the research recommended against) but does so via the boundary mechanism rather than trying to prove eventual fairness. The key difference is:

- Research Option C: Transfer properties from Z-chain to restricted chain
- This plan: Prove restricted chain HAS the needed property via boundary_resolution_set

The boundary_resolution_set is already in the construction - we're just proving it does what we need.
