# Implementation Plan: Task #458 - Extend canonical_history to Full Domain (v003)

- **Task**: 458 - Extend canonical_history from singleton domain to full domain
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Priority**: High
- **Dependencies**: Task 448 (singleton domain MVP - COMPLETED)
- **Research Inputs**:
  - .claude/specs/458_extend_canonical_history_full_domain/reports/research-001.md
  - .claude/specs/458_extend_canonical_history_full_domain/reports/research-002.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements Strategy C from research-002.md: indexed chains with explicit composition. The approach builds on proven infrastructure (`future_formula_persistence`, `past_formula_persistence`, `canonical_nullity`) and addresses the coherence problem by constructing states as sequential chains rather than independent Classical.choose calls.

**Key insight**: By building chains step-by-step where each state is chosen relative to its predecessor, compositionality becomes guaranteed by construction. The critical blocker is `chain_step_pos` which requires a cardinality argument to prove two-element order types differ from one-element order types.

### Research Integration

From research-002.md:
- **Strategy C identified as HIGH VIABILITY** - builds on existing proven infrastructure
- **Duration type is abstract** - not isomorphic to Z, uses `chain_step` as discrete unit
- **Proven lemmas available**: `future_formula_persistence`, `past_formula_persistence`, `canonical_nullity`
- **Critical blockers**: `chain_step_pos` (cardinality proof), seed consistency lemmas

## Goals & Non-Goals

**Goals**:
- Prove `chain_step_pos` using cardinality argument
- Implement forward chain using `forward_extension` with proven persistence lemmas
- Implement backward chain (mirror construction)
- Combine into unified `canonical_states` function
- Complete `respects_task` proof using chain coherence
- Reduce sorry count in Completeness.lean

**Non-Goals**:
- Full continuous domain coverage (accept discrete coverage at chain_step multiples)
- General compositionality proof (bypass via chain construction)
- Truth lemma completion (separate task 449)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `chain_step_pos` cardinality proof complex | High | Low | Order types of different cardinalities cannot be bijective |
| `forward_seed_consistent` has sorry | High | Medium | May need axiom strengthening; attempt proof first |
| `backward_seed_consistent` has sorry | High | Medium | Mirror of forward case; handle similarly |
| Compositionality sorries block chain total | Medium | Medium | Use specialized `chain_compose` for positive-positive case only |
| Duration abstraction causes type issues | Medium | Low | Use `nsmul` for chain_step multiples |

## Implementation Phases

### Phase 1: Prove chain_step_pos [NOT STARTED]

**Goal**: Prove that `chain_step > 0` using cardinality argument to show two-element order types differ from one-element.

**Tasks**:
- [ ] Locate `chain_step_pos` sorry at line ~2696 of Completeness.lean
- [ ] Understand `chain_step_pd` construction (two singleton concatenation)
- [ ] Prove helper lemma: order types with different cardinalities cannot be equivalent
- [ ] Apply cardinality argument: two-element segment differs from one-element segment
- [ ] Complete `chain_step_pos` proof removing sorry

**Approach**:
The chain_step_pd is defined as:
```lean
noncomputable def chain_step_pd : PositiveDuration :=
  PositiveDuration.add [[mkSingletonSigma someWorldState]] [[mkSingletonSigma someWorldState]]
```

This represents concatenating two singleton order types, giving a two-element total order. The zero element represents a one-element order type. Since order-type equivalence requires bijection, and bijection preserves cardinality, two elements cannot biject to one element.

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Lines ~2686-2696

**Timing**: 2 hours

**Verification**:
- [ ] `chain_step_pos` compiles without sorry
- [ ] Cardinality argument is sound and complete
- [ ] `lake build` succeeds for Completeness.lean

---

### Phase 2: Implement Forward Chain with Proven Lemmas [NOT STARTED]

**Goal**: Define `canonical_forward_chain` building states forward from origin, leveraging `future_formula_persistence` which is PROVEN.

**Tasks**:
- [ ] Define `canonical_forward_chain : CanonicalWorldState -> N -> CanonicalWorldState`
  ```lean
  noncomputable def canonical_forward_chain (S : CanonicalWorldState) : N -> CanonicalWorldState
  | 0 => S
  | n + 1 =>
      let Sn := canonical_forward_chain S n
      Classical.choose (forward_extension Sn chain_step chain_step_pos)
  ```
- [ ] Prove `forward_chain_consecutive`: step relation holds by `Classical.choose_spec`
  ```lean
  lemma forward_chain_consecutive (S : CanonicalWorldState) (n : N) :
      canonical_task_rel (canonical_forward_chain S n) chain_step (canonical_forward_chain S (n + 1))
  ```
- [ ] Prove `forward_chain_total` by induction using compositionality
  ```lean
  lemma forward_chain_total (S : CanonicalWorldState) (n : N) :
      canonical_task_rel S (n * chain_step) (canonical_forward_chain S n)
  ```
  - Base case: `canonical_nullity S` (PROVEN)
  - Inductive case: compose using `canonical_compositionality` for positive-positive case
- [ ] If compositionality has sorries for positive-positive case, implement specialized `chain_compose` lemma

**Key insight**: The positive-positive case of compositionality should work because:
- Modal transfer composes (proven)
- Future transfer uses `future_formula_persistence` (PROVEN)
- Past transfer is vacuously true (both durations positive)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean`

**Timing**: 2 hours

**Verification**:
- [ ] `canonical_forward_chain` definition compiles
- [ ] `forward_chain_consecutive` compiles without sorry
- [ ] `forward_chain_total` compiles without sorry
- [ ] Chain property proven for all n

---

### Phase 3: Implement Backward Chain [NOT STARTED]

**Goal**: Define `canonical_backward_chain` building states backward from origin, using `past_formula_persistence` (PROVEN).

**Tasks**:
- [ ] Define `canonical_backward_chain : CanonicalWorldState -> N -> CanonicalWorldState`
  ```lean
  noncomputable def canonical_backward_chain (S : CanonicalWorldState) : N -> CanonicalWorldState
  | 0 => S
  | n + 1 =>
      let Sn := canonical_backward_chain S n
      Classical.choose (backward_extension Sn chain_step chain_step_pos)
  ```
  Note: backward_extension gives T such that `canonical_task_rel T chain_step Sn`
- [ ] Prove `backward_chain_consecutive`: step relation holds
  ```lean
  lemma backward_chain_consecutive (S : CanonicalWorldState) (n : N) :
      canonical_task_rel (canonical_backward_chain S (n + 1)) chain_step (canonical_backward_chain S n)
  ```
- [ ] Prove `backward_chain_total` by induction
  ```lean
  lemma backward_chain_total (S : CanonicalWorldState) (n : N) :
      canonical_task_rel (canonical_backward_chain S n) (n * chain_step) S
  ```
  - Uses `past_formula_persistence` for the negative-negative compositionality case

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean`

**Timing**: 2 hours

**Verification**:
- [ ] `canonical_backward_chain` definition compiles
- [ ] `backward_chain_consecutive` compiles without sorry
- [ ] `backward_chain_total` compiles without sorry
- [ ] Backward chain mirrors forward chain structure

---

### Phase 4: Combine into Unified canonical_states [NOT STARTED]

**Goal**: Replace the independent Classical.choose construction with chain-based construction covering positive and negative time indices.

**Tasks**:
- [ ] Define helper to combine chains:
  ```lean
  noncomputable def canonical_states (S : CanonicalWorldState) (t : CanonicalTime) : CanonicalWorldState :=
    if h : t = 0 then S
    else if ht : (0 : CanonicalTime) < t then
      -- Find n such that t = n * chain_step (or nearest)
      canonical_forward_chain S (quotient_by_chain_step t ht)
    else
      -- t < 0, find n such that -t = n * chain_step
      canonical_backward_chain S (quotient_by_chain_step (-t) (neg_pos_of_neg (lt_of_not_ge (not_le_of_lt ht))))
  ```
- [ ] Handle Duration abstraction: define `quotient_by_chain_step` or simplify if Duration allows
- [ ] Prove key lemmas:
  - `canonical_states_zero`: `canonical_states S 0 = S`
  - `canonical_states_positive`: For `t > 0`, `canonical_task_rel S t (canonical_states S t)`
  - `canonical_states_negative`: For `t < 0`, `canonical_task_rel (canonical_states S t) (-t) S`

**Alternative (simpler)**: If Duration structure is complex, accept discrete coverage:
```lean
-- Domain is multiples of chain_step only
def canonical_domain : Set CanonicalTime :=
  { t | exists n : Z, t = n * chain_step }
```

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace lines ~2638-2665

**Timing**: 2 hours

**Verification**:
- [ ] `canonical_states` definition compiles
- [ ] Zero, positive, negative lemmas compile without sorry
- [ ] Chain coherence preserved

---

### Phase 5: Complete respects_task Proof [NOT STARTED]

**Goal**: Prove `respects_task` using chain coherence - the key property that blocked v001 and v002.

**Tasks**:
- [ ] Prove `respects_task` for canonical_history:
  ```lean
  respects_task := fun s t hs ht hst =>
    -- Need: canonical_task_rel (states s) (t - s) (states t)
    -- By chain construction, both s and t lie on the same chain from S
    -- The relation follows from chain_total lemmas and compositionality
  ```
- [ ] Handle cases:
  - Case s = 0, t >= 0: Use `forward_chain_total`
  - Case s = 0, t <= 0: Use `backward_chain_total`
  - Case s > 0, t > 0: Both on forward chain, use compositionality
  - Case s < 0, t < 0: Both on backward chain, use compositionality
  - Case s < 0, t > 0: Compose backward_chain_total and forward_chain_total through 0
  - Case s < 0, t = 0: Use `backward_chain_total`
  - Case s > 0, t < 0: Impossible since s <= t
- [ ] Key insight: all cases reduce to composing chain_total lemmas

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Lines ~2745-2862

**Timing**: 1.5 hours

**Verification**:
- [ ] `respects_task` compiles without sorry
- [ ] All cases handled explicitly
- [ ] No coherence issues (all states on same chain)

---

### Phase 6: Verification and Cleanup [NOT STARTED]

**Goal**: Verify the implementation compiles, document changes, and clean up.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.Completeness` and fix any issues
- [ ] Count sorries before and after - target net reduction
- [ ] Update documentation comments for chain construction
- [ ] Remove dead code from v001 approach if any
- [ ] Verify `canonical_model` and `truth_lemma` still compile (may have new sorries from other causes)
- [ ] Document any remaining blockers for future tasks

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean`

**Timing**: 0.5 hours

**Verification**:
- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] Sorry count documented (before/after)
- [ ] Documentation accurate and complete

---

## Testing & Validation

- [ ] Phase 1: `chain_step_pos` compiles without sorry
- [ ] Phase 2: Forward chain lemmas compile without sorry
- [ ] Phase 3: Backward chain lemmas compile without sorry
- [ ] Phase 4: `canonical_states` with chain construction compiles
- [ ] Phase 5: `respects_task` compiles without sorry
- [ ] Phase 6: Full `lake build` succeeds

## Artifacts & Outputs

- plans/implementation-003.md (this file)
- Modified: `Theories/Bimodal/Metalogic/Completeness.lean`
- summaries/implementation-summary-YYYYMMDD.md (on completion)

## Rollback/Contingency

If chain construction encounters unexpected blockers:

1. **If chain_step_pos blocks**: Investigate alternative step definitions; may need to strengthen PositiveDuration construction
2. **If forward_extension has unresolvable sorries**: Fall back to assuming it as an axiom temporarily and document the gap
3. **If compositionality for positive-positive case blocks**: Implement specialized `chain_compose` that avoids the general compositionality proof
4. **If full domain is too complex**: Accept discrete domain coverage at chain_step multiples as a valid intermediate result

**Recovery**: Previous plan versions (v001, v002) preserved in plans/ directory for reference.

## Key Differences from v002

| Aspect | v002 | v003 |
|--------|------|------|
| Critical blocker | Assumed chains exist | Addresses `chain_step_pos` first |
| Duration handling | Assumed integer-like | Uses abstract `chain_step` as unit |
| Compositionality | General case | Specialized for positive-positive |
| Proven infrastructure | Not referenced | Builds on `future_formula_persistence`, `past_formula_persistence` |
| Research basis | research-001.md only | Integrates research-002.md Strategy C |

## Code References

| Component | Location | Status | Notes |
|-----------|----------|--------|-------|
| `chain_step` | Lines ~2671-2676 | Exists | Needs `chain_step_pos` proof |
| `chain_step_pos` | Lines ~2686-2696 | HAS SORRY | Phase 1 target |
| `forward_extension` | Lines ~2422-2463 | Has sorry in seed | Usable via Classical.choose |
| `backward_extension` | Lines ~2519-2544 | HAS SORRY | Usable via Classical.choose |
| `future_formula_persistence` | Lines 2077-2090 | PROVEN | Key for forward chain |
| `past_formula_persistence` | Lines 2103-2116 | PROVEN | Key for backward chain |
| `canonical_nullity` | Lines 2036-2057 | PROVEN | Base case for induction |
| `canonical_compositionality` | Lines 2140-2316 | Partial sorries | Modal case complete |
| `canonical_states` (v001) | Lines 2638-2665 | Has coherence problem | To be replaced |
| `canonical_history` | Lines 2745-2862 | Has sorries | To be updated |
