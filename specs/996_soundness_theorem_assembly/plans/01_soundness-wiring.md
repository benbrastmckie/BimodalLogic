# Implementation Plan: Task #996 - Soundness Theorem Assembly

- **Task**: 996 - Wire the 6 remaining sorries in Soundness.lean using proven component theorems
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/996_soundness_theorem_assembly/reports/01_soundness-wiring.md
- **Artifacts**: plans/01_soundness-wiring.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Wire the 6 remaining sorries in `Theories/Bimodal/Metalogic/Soundness.lean` (lines 565, 569, 572, 575, 595, 598) using proven component theorems. The research identified that the current soundness theorem quantifies over ALL temporal types D without frame constraints, but extension axioms require specific frame properties (DenselyOrdered for density, SuccOrder for discreteness). The resolution creates frame-class-restricted soundness theorems (`soundness_dense`, `soundness_discrete`) that use existing proofs from DenseSoundness, DiscreteSoundness, SoundnessLemmas, and IRRSoundness.

### Research Integration

- Report: `reports/01_soundness-wiring.md`
- Key findings: 6 sorries require frame constraints; all component proofs exist; temporal_duality needs derivation-indexed proof; IRR limited to domain times

## Goals and Non-Goals

**Goals**:
- Resolve all 6 sorries in Soundness.lean
- Create `soundness_dense` theorem with [DenselyOrdered D] [Nontrivial D] constraints
- Create `soundness_discrete` theorem with [SuccOrder D] [PredOrder D] [Nontrivial D] constraints
- Properly integrate temporal_duality soundness using axiom_swap_valid from SoundnessLemmas
- Document IRR limitation (requires h_dom : tau.domain t)

**Non-Goals**:
- Removing the monomorphic soundness theorem (keep it with sorries as documentation)
- Proving IRR soundness for non-domain times
- Creating a single unified soundness theorem that works for all frame classes

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Temporal duality case complexity | H | M | Use derivation induction pattern from axiom_swap_valid in SoundnessLemmas |
| IRR domain restriction propagates | M | H | Add h_dom hypothesis to frame-specific theorems, document limitation |
| Universe level mismatches | M | M | Use explicit type parameters as done in SoundnessLemmas |
| Dense axiom case in discrete soundness | L | L | DerivationTree.is_dense_compatible predicate eliminates invalid cases |

## Implementation Phases

### Phase 1: Create soundness_dense theorem scaffold [NOT STARTED]

**Goal**: Create the `soundness_dense` theorem structure with frame constraints and wire base axiom cases

**Tasks**:
- [ ] Add `soundness_dense` theorem with signature: `[DenselyOrdered D] [Nontrivial D]` constraints
- [ ] Copy structure from existing `soundness` theorem
- [ ] Wire all base axiom cases (prop_k through temp_linearity) - these are identical to current soundness
- [ ] Wire density axiom case using `density_valid`
- [ ] Wire seriality_future case using NoMaxOrder inference (DenselyOrdered + Nontrivial)
- [ ] Wire seriality_past case using NoMinOrder inference (DenselyOrdered + Nontrivial)
- [ ] Build to verify no errors

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Add soundness_dense theorem

**Verification**:
- `lake build Bimodal.Metalogic.Soundness` completes with no new errors
- density, seriality_future, seriality_past cases have no sorry

---

### Phase 2: Wire temporal_duality case in soundness_dense [NOT STARTED]

**Goal**: Complete the temporal_duality case using derivation-indexed proof

**Tasks**:
- [ ] Study axiom_swap_valid in SoundnessLemmas to understand the swap validity pattern
- [ ] Implement temporal_duality case by induction on the derivation d'
- [ ] For axiom case: use axiom_swap_valid (requires h_dc : h.isDenseCompatible)
- [ ] For rule cases: use mp_preserves_swap_valid, modal_k_preserves_swap_valid, temporal_k_preserves_swap_valid
- [ ] Handle the discreteness_forward axiom case (should be unreachable with isDenseCompatible filter)
- [ ] Build to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Complete temporal_duality case

**Verification**:
- temporal_duality case compiles without sorry
- Build succeeds

---

### Phase 3: Wire IRR case in soundness_dense [NOT STARTED]

**Goal**: Complete the IRR case with domain restriction

**Tasks**:
- [ ] Add h_dom hypothesis to soundness_dense signature: `(h_dom : tau.domain t)`
- [ ] Wire IRR case using irr_sound_dense_at_domain from IRRSoundness
- [ ] Verify that premise (ih) properly converts to valid_dense format
- [ ] Add documentation comment explaining the domain restriction
- [ ] Build to verify

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Complete IRR case, add h_dom

**Verification**:
- IRR case compiles without sorry
- soundness_dense theorem fully proven (no sorries)
- Build succeeds

---

### Phase 4: Create soundness_discrete theorem [NOT STARTED]

**Goal**: Create parallel soundness theorem for discrete frames

**Tasks**:
- [ ] Add `soundness_discrete` theorem with signature: `[SuccOrder D] [PredOrder D] [Nontrivial D]` constraints
- [ ] Copy structure from soundness_dense
- [ ] Wire discreteness_forward case using discreteness_forward_valid
- [ ] Wire seriality_future case using Order.lt_succ from SuccOrder
- [ ] Wire seriality_past case using Order.pred_lt from PredOrder
- [ ] For density case: mark as absurd (discreteness_forward in derivation means no density axiom used)
- [ ] Handle temporal_duality and IRR cases (same pattern as soundness_dense but for discrete frames)
- [ ] Build to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Add soundness_discrete theorem

**Verification**:
- soundness_discrete theorem fully proven (no sorries)
- Build succeeds

---

### Phase 5: Update documentation and final verification [NOT STARTED]

**Goal**: Document the frame-class-restricted soundness approach and verify full build

**Tasks**:
- [ ] Update module docstring to describe soundness_dense and soundness_discrete
- [ ] Add comments explaining why general soundness has sorries (frame class incompatibility)
- [ ] Verify the original soundness theorem still exists (with sorries) for reference
- [ ] Run full lake build to ensure no regressions
- [ ] Update Soundness.lean header comments to reflect completed status

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Documentation updates

**Verification**:
- `lake build` succeeds with no errors
- Documentation accurately reflects implementation
- Both soundness_dense and soundness_discrete are fully proven

---

## Testing and Validation

- [ ] `lake build Bimodal.Metalogic.Soundness` succeeds with no errors
- [ ] `lake build` (full project) succeeds
- [ ] soundness_dense has zero sorries
- [ ] soundness_discrete has zero sorries
- [ ] Original soundness theorem preserved (with sorries) for documentation purposes

## Artifacts and Outputs

- `Theories/Bimodal/Metalogic/Soundness.lean` - Updated with soundness_dense, soundness_discrete
- `specs/996_soundness_theorem_assembly/summaries/01_soundness-wiring-summary.md` - Implementation summary

## Rollback/Contingency

If the temporal_duality or IRR cases prove more complex than expected:
1. Commit partial progress (phases 1-3 or 1-4)
2. Mark remaining cases with detailed sorry comments explaining the gap
3. Create follow-up task for the remaining work
4. The existing soundness theorem remains unchanged as reference
