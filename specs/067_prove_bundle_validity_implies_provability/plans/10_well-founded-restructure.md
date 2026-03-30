# Implementation Plan: Task #67 (Plan v10)

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [IN PROGRESS]
- **Effort**: 10-14 hours
- **Dependencies**: Report 24 (fuel-exhaustion research)
- **Research Inputs**: specs/067_prove_bundle_validity_implies_provability/reports/24_fuel-exhaustion-research.md
- **Artifacts**: plans/10_well-founded-restructure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace fuel-based recursion with well-founded recursion on a proper termination measure for all four bounded witness lemmas. This eliminates the fuel=0 base case sorries entirely by removing the fuel parameter. The result is cleaner, more maintainable code that naturally expresses the mathematical termination argument.

### Previous Progress

**Phase 1 (COMPLETED)**: `constrained_predecessor_restricted_g_persistence_reverse` proven
**Phase 2 (COMPLETED)**: `constrained_predecessor_restricted_f_step_forward` proven via `f_step_blocking_alt_restricted`

### Research Integration

Key findings from Report 24:
1. Four sorry sites at lines 2913, 5527, 5685, 5881 in fuel=0 base cases
2. All semantically unreachable when initial fuel `B*B+1` is used
3. Fuel-invariant approaches have complications due to non-monotonic depth changes
4. Well-founded recursion is cleaner (8-12 hours) but requires significant restructuring
5. The measure `(total_chain_bound - positions_visited, depth_remaining)` captures termination

## Goals & Non-Goals

**Goals**:
- Restructure all four fueled lemmas to use well-founded recursion
- Eliminate the fuel parameter entirely from bounded witness lemmas
- Wire `RestrictedTemporallyCoherentFamily` through to completeness
- Achieve zero-debt in the restricted completeness path

**Non-Goals**:
- Fixing deprecated (non-restricted) sorry sites (lines 1659, 1688, 2005)
- Fixing Soundness.lean sorries (separate concern)
- Fixing SuccChainTruth.lean sorry (intentional documentation)
- Quick fuel-invariant patches (user prefers clean solution)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lean's termination checker rejects complex measure | H | M | Use manual `decreasing_by` with explicit proof |
| Int-indexed chains complicate the measure | M | M | Treat Int as offset from origin, bound by `B` in each direction |
| Non-monotonic depth changes confuse termination | M | L | Use lexicographic product with depth in second position |
| Restructure breaks dependent lemmas | M | L | Incremental refactor with `lake build` after each change |

## Implementation Phases

### Phase 1: Backward Chain Proofs [COMPLETED]

Already completed in plan v9 sessions:
- `constrained_predecessor_restricted_g_persistence_reverse` (line 3944)
- `constrained_predecessor_restricted_f_step_forward` (line 4001)

---

### Phase 2: Well-Founded Infrastructure [NOT STARTED]

**Goal**: Define the termination measure and prove it decreases for the recursive patterns used.

**Termination Measure**: For forward chain bounded witness at position `k` with depth `d`:
```lean
-- The measure is (B*B - k, d) with lexicographic ordering
-- B = closure_F_bound phi bounds both chain length and depth
termination_measure := (closure_F_bound phi * closure_F_bound phi - k, d)
```

For Int-indexed chains at position `n : Int` with depth `d`:
```lean
-- Map Int position to Nat distance from origin, bound by B
def int_position_bound (n : Int) (B : Nat) : Nat :=
  if n ≥ 0 then min n.toNat B else min n.natAbs B

termination_measure := (B * B - int_chain_steps_taken, d)
```

**Tasks**:
- [ ] Define `chain_termination_measure : Nat × Nat → Nat × Nat` for the lexicographic product
- [ ] Prove `chain_measure_lt_iff` characterizing when measure decreases
- [ ] Define `int_chain_termination_measure` for Int-indexed variants
- [ ] Create helper lemma proving depth resets don't increase lexicographic measure when position advances

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add termination infrastructure section

**Verification**:
- Infrastructure lemmas compile without sorry
- `lake build` passes

---

### Phase 3: Refactor Forward Bounded Witness [NOT STARTED]

**Goal**: Convert `restricted_bounded_witness_fueled` (line ~2870) from fuel-based to well-founded recursion.

**Strategy**:

1. **Remove fuel parameter**: The function signature changes from:
   ```lean
   private theorem restricted_bounded_witness_fueled (phi : Formula)
       (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula)
       (d : Nat) (fuel : Nat) ...
   ```
   to:
   ```lean
   private theorem restricted_bounded_witness_wf (phi : Formula)
       (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula)
       (d : Nat) ...
   termination_by (closure_F_bound phi * closure_F_bound phi - k, d)
   ```

2. **Handle recursive calls**: When the recursion moves to `k+1` with new depth `d'`:
   - Measure goes from `(B*B - k, d)` to `(B*B - (k+1), d')`
   - First component strictly decreases: `B*B - k > B*B - (k+1)`
   - Second component can be anything (depth can reset)
   - Lexicographic: strictly less

3. **Handle depth-only recursion**: When staying at `k` but decreasing `d`:
   - Measure goes from `(B*B - k, d)` to `(B*B - k, d-1)`
   - First component same, second strictly decreases
   - Lexicographic: strictly less

4. **Prove termination**: Use `decreasing_by` block:
   ```lean
   decreasing_by
     simp_wf
     left  -- First component strictly decreases
     omega
   ```
   or
   ```lean
   decreasing_by
     simp_wf
     right  -- Same first component, second decreases
     constructor <;> omega
   ```

**Tasks**:
- [ ] Copy `restricted_bounded_witness_fueled` to new `restricted_bounded_witness_wf` version
- [ ] Remove fuel parameter and add `termination_by` clause
- [ ] Identify all recursive call sites and add appropriate `decreasing_by` proofs
- [ ] Update wrapper lemma `restricted_bounded_witness` to call new version
- [ ] Delete old fueled version once new version works
- [ ] Verify `lake build` passes

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Refactor bounded witness

**Verification**:
- Line 2913 sorry eliminated (function restructured)
- `restricted_bounded_witness` compiles and calls the new WF version
- `lake build` passes

---

### Phase 4: Refactor Backward Bounded Witness [NOT STARTED]

**Goal**: Convert `restricted_backward_bounded_witness_fueled` (line ~5480) from fuel-based to well-founded recursion.

**Strategy**: Same approach as Phase 3, but for the backward chain:
- Position `k` increases (moving backward in time semantically)
- Depth `d` decreases within each position exploration
- Measure: `(B*B - k, d)` still works

**Tasks**:
- [ ] Create `restricted_backward_bounded_witness_wf` without fuel parameter
- [ ] Add `termination_by (closure_F_bound phi * closure_F_bound phi - k, d)`
- [ ] Add `decreasing_by` proofs at each recursive call
- [ ] Update wrapper and delete old fueled version
- [ ] Verify `lake build` passes

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Refactor backward bounded witness

**Verification**:
- Line 5527 sorry eliminated (function restructured)
- `lake build` passes

---

### Phase 5: Refactor Combined Bounded Witnesses [NOT STARTED]

**Goal**: Convert both Int-indexed combined bounded witness lemmas:
- `restricted_combined_bounded_witness_fueled` (line ~5640)
- `restricted_combined_bounded_witness_P_fueled` (line ~5830)

**Strategy**: Int-indexed positions complicate the measure. Options:

**Option A (Translate to Nat)**: Define step counter that tracks total positions visited:
```lean
-- Track steps from origin, bounded by B
def combined_chain_steps (origin n : Int) : Nat :=
  (n - origin).natAbs  -- Positions visited from starting point

termination_by (closure_F_bound phi * closure_F_bound phi - steps_from_origin, d)
```

**Option B (Symmetric bounds)**: Since Int chains extend both directions:
```lean
-- n ranges from some n_min to n_max, both within B of 0
-- Total range <= 2*B, so use 2*B*B as upper bound
termination_by (2 * closure_F_bound phi * closure_F_bound phi - chain_extent, d)
```

**Tasks**:
- [ ] Choose approach for Int-indexed termination measure
- [ ] Create `restricted_combined_bounded_witness_wf` without fuel
- [ ] Create `restricted_combined_bounded_witness_P_wf` without fuel
- [ ] Add appropriate `termination_by` and `decreasing_by`
- [ ] Update wrappers and delete old fueled versions
- [ ] Verify `lake build` passes

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Refactor combined bounded witnesses

**Verification**:
- Lines 5685 and 5881 sorries eliminated (functions restructured)
- `lake build` passes

---

### Phase 6: Wire to Completeness [NOT STARTED]

**Goal**: Connect the now sorry-free `RestrictedTemporallyCoherentFamily` through to completeness.

**Strategy**: With all four bounded witness lemmas sorry-free:
1. `build_restricted_tc_family` should be sorry-free
2. `restricted_truth_lemma` uses DRM properties, not fuel lemmas directly
3. Wire from `neg_consistent_gives_mcs_without_phi` to final completeness

**Tasks**:
- [ ] Verify `#print axioms build_restricted_tc_family` shows no sorryAx
- [ ] Verify `#print axioms restricted_truth_lemma` shows no sorryAx
- [ ] Check completeness bridge in RestrictedTruthLemma.lean (lines 316-346)
- [ ] Wire if needed, or confirm existing wiring is sufficient
- [ ] Verify `lake build` passes

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` (if wiring needed)
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` (if wiring needed)

**Verification**:
- `#print axioms bundle_validity_implies_provability` pathway via restricted lemmas is sorry-free
- `lake build` passes

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] Termination checker accepts all well-founded recursions
- [ ] `#print axioms restricted_bounded_witness` shows no sorryAx after Phase 3
- [ ] `#print axioms restricted_backward_bounded_witness` shows no sorryAx after Phase 4
- [ ] `#print axioms restricted_combined_bounded_witness` shows no sorryAx after Phase 5
- [ ] `#print axioms build_restricted_tc_family` shows no sorryAx after Phase 5
- [ ] The completeness path is fully sorry-free after Phase 6

## Artifacts & Outputs

- Modified `SuccChainFMCS.lean` with well-founded recursion for all bounded witnesses
- Clean termination proofs using lexicographic measures
- Implementation summary documenting the restructuring approach

## Rollback/Contingency

If well-founded recursion proves too complex for Lean's termination checker:
1. Fall back to fuel-sufficient invariant approach (Report 24, Approach 1)
2. Thread `h_fuel_ge : fuel >= remaining_work` through recursion
3. Less elegant but more straightforward to implement

If Int-indexed chains resist the termination measure:
1. Convert to Nat-indexed with offset tracking
2. Or use manual `termination_by` with explicit `Rel` instance

## Sorry Inventory After This Plan

### Eliminated by This Plan
| Line | Theorem | Phase |
|------|---------|-------|
| 2913 | `restricted_bounded_witness_fueled` | Phase 3 (restructured away) |
| 5527 | `restricted_backward_bounded_witness_fueled` | Phase 4 (restructured away) |
| 5685 | `restricted_combined_bounded_witness_fueled` | Phase 5 (restructured away) |
| 5881 | `restricted_combined_bounded_witness_P_fueled` | Phase 5 (restructured away) |

### Already Eliminated (Plan v9)
| Line | Theorem | Status |
|------|---------|--------|
| 3944 | `constrained_predecessor_restricted_g_persistence_reverse` | COMPLETED |
| 4001 | `constrained_predecessor_restricted_f_step_forward` | COMPLETED |

### Non-critical (not addressed)
| Line | Theorem | Reason |
|------|---------|--------|
| 1659 | `g_content_union_brs_consistent` | Deprecated path |
| 1688 | `augmented_seed_consistent` | Deprecated path |
| 2005 | `constrained_successor_seed_restricted_consistent` (multi-BRS) | Deprecated path |
| RestrictedTruthLemma:116 | `restricted_chain_G_propagates` | Not needed for completeness |
| RestrictedTruthLemma:158 | `restricted_chain_H_step` | Not needed for completeness |
