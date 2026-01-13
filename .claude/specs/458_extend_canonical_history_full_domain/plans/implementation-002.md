# Implementation Plan: Task #458 - Extend canonical_history to Full Domain (v002)

- **Task**: 458 - Extend canonical_history from singleton domain to full domain
- **Version**: 002
- **Created**: 2026-01-12
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Priority**: High
- **Dependencies**: Task 448 (Build canonical_history - singleton domain MVP - COMPLETED)
- **Research Inputs**: .claude/specs/458_extend_canonical_history_full_domain/reports/research-001.md
- **Previous Plan**: implementation-001.md (PARTIAL - blocked by coherence problem)
- **Type**: lean
- **Lean Intent**: true

## Revision Rationale

The previous plan (v001) used independent `Classical.choose` calls for each time point:
- `canonical_states S t` chose witnesses independently for t > 0 and t < 0
- This led to a **coherence problem**: states at s > 0 and t > 0 were chosen independently and may not lie on the same timeline
- Cases (s>0, t>0) and (s<0, t<0) in `respects_task` could not be proven

**New Approach**: Build states as a **chain from 0** using a single sequence of choices, ensuring coherence by construction.

## Overview

Instead of choosing states independently at each time, we build a **canonical chain** starting from S at time 0:
1. Define a sequence of states extending forward: `S_0 = S`, `S_{n+1}` chosen via `forward_extension S_n`
2. Define a sequence of states extending backward: `S_{-1}` chosen via `backward_extension S`, etc.
3. Use these sequences to define `canonical_states` with guaranteed compositionality

The key insight: if `S_1` is chosen to satisfy `canonical_task_rel S 1 S_1`, and `S_2` is chosen to satisfy `canonical_task_rel S_1 1 S_2`, then by compositionality `canonical_task_rel S 2 S_2` holds automatically.

## Goals & Non-Goals

**Goals**:
- Redesign `canonical_states` to use chain construction from 0
- Eliminate coherence problem by construction
- Complete `respects_task` proof for all cases
- Ensure compositionality follows from construction, not from proving Classical.choose witnesses compose

**Non-Goals**:
- Proving general compositionality (we bypass this by construction)
- Supporting continuous time (we use integer steps, interpolating with compositionality)
- Full truth lemma (separate task 449)

## Chain Construction Design

### Integer-Indexed Chain

Define states at integer times first, then extend to all durations:

```lean
/-- States at positive integer times, built forward from S -/
noncomputable def canonical_forward_chain (S : CanonicalWorldState) : ℕ → CanonicalWorldState
| 0 => S
| n + 1 => Classical.choose (forward_extension (canonical_forward_chain S n) 1 one_pos)

/-- States at negative integer times, built backward from S -/
noncomputable def canonical_backward_chain (S : CanonicalWorldState) : ℕ → CanonicalWorldState
| 0 => S
| n + 1 => Classical.choose (backward_extension (canonical_backward_chain S n) 1 one_pos)

/-- States at all integer times -/
noncomputable def canonical_states_int (S : CanonicalWorldState) (n : ℤ) : CanonicalWorldState :=
  if hn : 0 ≤ n then
    canonical_forward_chain S n.toNat
  else
    canonical_backward_chain S (-n).toNat
```

### Chain Coherence Lemmas

The chain construction guarantees:

```lean
/-- Forward chain maintains task relation with step 1 -/
lemma canonical_forward_chain_step (S : CanonicalWorldState) (n : ℕ) :
    canonical_task_rel (canonical_forward_chain S n) 1 (canonical_forward_chain S (n + 1))

/-- Forward chain composes: S relates to S_n with duration n -/
lemma canonical_forward_chain_total (S : CanonicalWorldState) (n : ℕ) :
    canonical_task_rel S n (canonical_forward_chain S n)

/-- Backward chain maintains task relation with step 1 -/
lemma canonical_backward_chain_step (S : CanonicalWorldState) (n : ℕ) :
    canonical_task_rel (canonical_backward_chain S (n + 1)) 1 (canonical_backward_chain S n)

/-- Backward chain composes: S_{-n} relates to S with duration n -/
lemma canonical_backward_chain_total (S : CanonicalWorldState) (n : ℕ) :
    canonical_task_rel (canonical_backward_chain S n) n S
```

### Extending to All Durations

For non-integer durations, we interpolate using compositionality:

```lean
/-- Full domain states function -/
noncomputable def canonical_states (S : CanonicalWorldState) (t : Duration) : CanonicalWorldState :=
  canonical_states_int S ⌊t⌋  -- Floor of t gives integer index
```

**Note**: This approach assumes Duration has a floor function or is integer-valued. If Duration is ℤ (as in the current code), this simplifies to direct indexing. If Duration is more general (ℚ, ℝ), we need to decide on interpolation strategy.

**Simplification**: Since `CanonicalTime` is `Duration` which appears to be `ℤ`-like in structure, we can directly use integer indexing.

## Implementation Phases

### Phase 1: Verify Duration Structure [COMPLETED]

**Goal**: Confirm the structure of `Duration`/`CanonicalTime` and determine chain indexing strategy.

**Tasks**:
- [ ] Check `Duration` definition in WorldHistory.lean or imports
- [ ] Verify `Duration` has integer embedding or is isomorphic to ℤ
- [ ] Decide: use ℤ indexing directly, or use ℕ with sign separation

**Timing**: 1 hour

**Files to examine**:
- `Theories/Bimodal/WorldHistory.lean` - Duration definition
- `Theories/Bimodal/Metalogic/Completeness.lean` - Current Duration usage

**Verification**:
- [ ] Understand Duration's relationship to ℤ
- [ ] Confirm forward_extension/backward_extension exist and work with unit duration

---

### Phase 2: Implement Forward Chain [IN PROGRESS]

**Goal**: Define `canonical_forward_chain` and prove its key properties.

**Tasks**:
- [ ] Define `canonical_forward_chain : CanonicalWorldState → ℕ → CanonicalWorldState`
- [ ] Prove `canonical_forward_chain_step`: step relation holds
- [ ] Prove `canonical_forward_chain_total`: composition from S to S_n
  - Use induction on n
  - Base case: `canonical_nullity` (task_rel S 0 S)
  - Inductive case: `canonical_compositionality` to compose relations

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean`

**Verification**:
- [ ] `canonical_forward_chain` definition compiles
- [ ] Both step and total lemmas compile without sorry
- [ ] Chain property: `canonical_task_rel S n (canonical_forward_chain S n)` proven

---

### Phase 3: Implement Backward Chain [NOT STARTED]

**Goal**: Define `canonical_backward_chain` and prove its key properties.

**Tasks**:
- [ ] Define `canonical_backward_chain : CanonicalWorldState → ℕ → CanonicalWorldState`
- [ ] Prove `canonical_backward_chain_step`: step relation holds (backward direction)
- [ ] Prove `canonical_backward_chain_total`: composition from S_{-n} to S
  - Note: The relation goes FROM backward state TO origin

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean`

**Verification**:
- [ ] `canonical_backward_chain` definition compiles
- [ ] Both step and total lemmas compile without sorry
- [ ] Chain property: `canonical_task_rel (canonical_backward_chain S n) n S` proven

---

### Phase 4: Implement Integer States [NOT STARTED]

**Goal**: Combine forward and backward chains into `canonical_states_int`.

**Tasks**:
- [ ] Define `canonical_states_int : CanonicalWorldState → ℤ → CanonicalWorldState`
  - Positive integers: use forward chain
  - Negative integers: use backward chain
  - Zero: return S
- [ ] Prove key lemmas:
  - `canonical_states_int_zero`: `canonical_states_int S 0 = S`
  - `canonical_states_int_pos`: For n > 0, `canonical_task_rel S n (canonical_states_int S n)`
  - `canonical_states_int_neg`: For n < 0, `canonical_task_rel (canonical_states_int S n) (-n) S`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean`

**Verification**:
- [ ] `canonical_states_int` definition compiles
- [ ] All three key lemmas compile without sorry
- [ ] Sign handling correct at boundary (0)

---

### Phase 5: Replace canonical_states and canonical_history [NOT STARTED]

**Goal**: Replace the old independent-choice construction with the chain-based one.

**Tasks**:
- [ ] Replace `canonical_states` definition with chain-based version
- [ ] Update `canonical_states_zero`, `canonical_states_forward`, `canonical_states_backward` lemmas
- [ ] Complete `respects_task` proof:
  - For s ≤ t, both integers: use chain composition
  - Key insight: all states lie on the same chain, so composition is guaranteed
- [ ] Remove old sorry placeholders

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean`

**Verification**:
- [ ] `canonical_history` compiles without sorry
- [ ] `respects_task` proof complete for all cases
- [ ] No coherence issues (all states on same chain)

---

### Phase 6: Verification and Cleanup [NOT STARTED]

**Goal**: Verify the implementation and clean up.

**Tasks**:
- [ ] Run `lake build` on Completeness.lean
- [ ] Verify `canonical_model` still works
- [ ] Update documentation comments
- [ ] Remove any unused code from v001 approach
- [ ] Verify truth_lemma compatibility

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean`

**Verification**:
- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] Sorry count reduced from previous version
- [ ] Documentation accurate

---

## Key Insight: Why Chain Construction Solves Coherence

**Previous approach** (v001):
```
S at 0 --forward_extension--> T₁ at 1 (independently chosen)
S at 0 --forward_extension--> T₂ at 2 (independently chosen)
Problem: T₁ and T₂ may not satisfy canonical_task_rel T₁ 1 T₂
```

**New approach** (v002):
```
S at 0 --forward_extension--> S₁ at 1 (chosen from S)
S₁ at 1 --forward_extension--> S₂ at 2 (chosen from S₁)
Guarantee: canonical_task_rel S₁ 1 S₂ by construction!
```

By building the chain step-by-step, each successive state is chosen to be task-related to its predecessor. Compositionality then gives us the relation between any two states on the chain.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Duration not integer-like | High | Low | Check Duration definition first; adapt indexing if needed |
| Compositionality still has sorries | Medium | Medium | Chain construction may need only modal compositionality (likely complete) |
| Forward/backward extension missing | High | Low | These should exist from v001; verify first |
| Induction on chains complex | Medium | Medium | Use well-documented induction with clear invariants |

## Dependencies

### Existing Infrastructure (from v001)
- `forward_extension`: ∃ T, canonical_task_rel S d T (d > 0) - EXISTS, may have sorry
- `backward_extension`: ∃ T, canonical_task_rel T d S (d > 0) - EXISTS, may have sorry
- `canonical_compositionality`: task_rel composes - EXISTS, may have partial sorries
- `canonical_nullity`: task_rel S 0 S - COMPLETE

### Required for Chain
- Only need compositionality for consecutive chain elements (both positive duration)
- Modal compositionality case should be complete
- Temporal compositionality sorries may not block chain construction if all steps are positive

## Testing & Validation

- [ ] `canonical_forward_chain` definition type-checks
- [ ] `canonical_backward_chain` definition type-checks
- [ ] `canonical_states_int` definition type-checks
- [ ] Chain step lemmas compile without sorry
- [ ] Chain total lemmas compile without sorry
- [ ] `canonical_history.respects_task` compiles without sorry
- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] Sorry count in Completeness.lean reduced

## Success Criteria

1. **Primary**: `canonical_history` with full domain compiles without sorry in `respects_task`
2. **Secondary**: Chain construction is clean and well-documented
3. **Tertiary**: No increase in sorry count elsewhere; ideally decrease

## Key Code References

| Component | Current Location | Purpose |
|-----------|-----------------|---------|
| `canonical_states` (v001) | Lines 2638-2665 | To be replaced |
| `canonical_history` (v001) | Lines 2745-2862 | To be updated |
| `forward_extension` | Lines ~2440-2470 | Used for chain steps |
| `backward_extension` | Lines ~2510-2545 | Used for chain steps |
| `canonical_compositionality` | Lines 2076-2131 | Used for chain totals |
| `canonical_nullity` | Lines ~2056-2070 | Base case |
