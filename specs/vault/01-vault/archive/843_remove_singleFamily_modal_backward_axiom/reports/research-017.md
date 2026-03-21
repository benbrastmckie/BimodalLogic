# Research Report: Task #843 (Round 17)

**Task**: Remove singleFamily_modal_backward_axiom
**Date**: 2026-02-10
**Focus**: Architectural redesign analysis for cross-sign temporal propagation and cross-task evaluation with task 865 recommendations

## Summary

This report analyzes the Phase 1 blocking issue (cross-sign temporal propagation) from plan v007, evaluates potential architectural redesigns, and assesses interactions with task 865's canonical task frame recommendations. The key finding is that the current two-chain architecture (forward from 0, backward from 0) is fundamentally incompatible with cross-sign G/H propagation due to the one-directional nature of Lindenbaum extension. Three architectural alternatives are evaluated: (1) unified interleaved chain, (2) global Zorn approach, and (3) deferral with explicit sorry acceptance. The report also finds that task 865's research-004 recommendations remain valid and do not require modification based on task 843's discoveries.

## 1. Current Architecture Analysis

### 1.1 DovetailingChain.lean Structure

The current implementation in `DovetailingChain.lean` uses a **two-chain meeting at shared base** architecture:

```
Backward chain:  ... <- M_{-2} <- M_{-1} <- M_0 (shared base)
Forward chain:   M_0 (shared base) -> M_1 -> M_2 -> ...
```

Key characteristics:
- `dovetailForwardChainMCS`: Step 0 = shared base, Step n+1 extends GContent(M_n)
- `dovetailBackwardChainMCS`: Step 0 = shared base, Step n+1 extends HContent(M_n)
- Both chains share the exact same MCS at index 0 via `sharedBaseMCS`
- Chain unification via `dovetailChainSet`: non-negative uses forward, negative uses backward

### 1.2 What Works (Same-Sign Propagation)

The implementation **successfully proves** same-sign propagation:

1. **`dovetailChainSet_forward_G_nonneg`**: For 0 <= t < t', G phi in M_t implies phi in M_{t'}
   - Proof: Forward chain propagates GContent, so G(G phi) = G phi in GContent(M_t) is included in M_{t+1}

2. **`dovetailChainSet_backward_H_nonpos`**: For t' < t <= 0, H phi in M_t implies phi in M_{t'}
   - Proof: Backward chain propagates HContent, so H(H phi) = H phi in HContent(M_t) is included in M_{t-1}

### 1.3 Why Cross-Sign Propagation Fails

The blocking issue is **cross-sign propagation**:
- `forward_G` when t < 0 < t': Need G phi in M_t (negative) to imply phi in M_{t'} (positive)
- `backward_H` when t' < 0 < t: Need H phi in M_t (positive) to imply phi in M_{t'} (negative)

**Root cause**: Lindenbaum extension is **one-directional**. The construction proceeds:
- Forward: M_0 -> M_1 -> M_2 -> ... (each extends GContent of previous)
- Backward: M_0 -> M_{-1} -> M_{-2} -> ... (each extends HContent of previous)

For G phi in M_{-2} to reach M_1:
1. G phi in M_{-2} does NOT propagate to M_{-1} (backward chain propagates HContent, not GContent)
2. Even if G phi were in M_0 (the shared base), the backward chain construction doesn't inherit from it
3. The shared base M_0 is constructed ONCE; later backward steps don't see what the forward chain adds

**The fundamental issue**: The two-chain construction is inherently **asymmetric by direction**. GContent flows forward-only, HContent flows backward-only. Cross-sign transfer requires GContent to somehow cross the 0-boundary, but the construction order prevents this.

## 2. Architectural Alternatives

### 2.1 Alternative A: Unified Interleaved Chain

**Concept**: Build a single chain indexed by integers, where each step includes BOTH GContent from the previous time AND HContent from the next time.

**Construction sketch**:
```lean
-- Seed for M_t includes:
-- (1) GContent(M_{t-1}) if t > min_constructed
-- (2) HContent(M_{t+1}) if t < max_constructed
-- (3) Base context at time 0
```

**Problems**:
1. **Chicken-and-egg**: To include HContent(M_{t+1}) in the seed for M_t, we need M_{t+1} to already exist. But M_{t+1} may need GContent(M_t).
2. **Interleaving order**: Could dovetail: M_0, M_1, M_{-1}, M_2, M_{-2}, ... At each step, both directions are built, so GContent can propagate.
3. **Proof complexity**: The interleaved construction is significantly more complex. Proving forward_G requires tracking that G-formulas were included in seeds at the right times.

**Estimated effort**: 15-20 hours
**Risk**: MEDIUM-HIGH (complex construction, subtle proof obligations)

### 2.2 Alternative B: Global Zorn Approach

**Concept**: Instead of constructing the chain step-by-step, use Zorn's lemma to find a maximal family satisfying the coherence conditions.

**Construction sketch**:
```lean
-- Define: CoherentPartialFamily is a partial function Int -> Set Formula where:
-- (1) Each defined value is an MCS
-- (2) forward_G holds for defined times
-- (3) backward_H holds for defined times
-- (4) Contains the base context at time 0

-- Prove: CoherentPartialFamily is closed under unions of chains (Zorn's condition)
-- Conclude: Maximal CoherentPartialFamily exists

-- Prove: Maximal family is total (defined for all Int)
-- Key lemma: If not total, can extend to t+1 (using GContent consistency) or t-1 (using HContent consistency)
```

**Problems**:
1. **Zorn in Lean 4**: Requires `Classical.choice` and careful handling of partial functions
2. **Totality argument**: Must prove the maximal family is total, which requires proving GContent/HContent extensions are always possible
3. **Cross-sign still problematic**: Zorn doesn't automatically ensure G-formulas propagate across 0. The maximal family might have G phi in M_{-1} but not in M_1 if no chain condition forces it.

**Key insight**: Zorn only gives a maximal element satisfying the explicit conditions. If cross-sign propagation isn't part of the definition, Zorn won't provide it.

**Estimated effort**: 20-30 hours
**Risk**: HIGH (may not solve the problem; Zorn complexity)

### 2.3 Alternative C: Deferral with Sorry Technical Debt

**Concept**: Accept the 4 sorries as documented technical debt, since the critical goal (replacing FALSE axiom with CORRECT axiom) is already complete via Phase 4.

**Current state after plan v007 Phase 4**:
- FALSE axiom `singleFamily_modal_backward_axiom` is DEPRECATED
- CORRECT axiom `fully_saturated_bmcs_exists` is in use
- Completeness chain depends on CORRECT axiom (mathematically sound)
- 4 sorries remain in DovetailingChain.lean (cross-sign + F/P witnesses)

**Technical debt characterization** (per proof-debt-policy.md):
- **Category**: Construction assumptions (tolerated during development)
- **Transitive impact**: `temporal_coherent_family_exists_theorem` inherits the 4 sorries
- **Publication status**: Blocks transitive sorry-freedom; requires resolution before publication

**Estimated effort**: 0 hours (no implementation work)
**Risk**: LOW (but maintains technical debt)

## 3. Cross-Task Analysis: Task 865 Recommendations

### 3.1 Task 865 Research-004 Summary

Task 865's research-004 recommends **Construction B2 (Family-Indexed)** for the canonical task frame bridge:
- WorldState = (family, time) pairs
- task_rel = same family + time arithmetic
- Trivial compositionality/nullity proofs
- Clean world history characterization

Key findings from task 865:
1. The BMCS construction (task 843) and TaskFrame bridge (task 865) are **architecturally independent**
2. Task 865 CONSUMES the BMCS; it does not help construct it
3. The box case resolution uses MF/TF axioms + offset handling, NOT properties from the BMCS construction

### 3.2 Do Task 843 Findings Require Changes to Task 865 Recommendations?

**Question**: Does the discovery that Phase 1 cross-sign propagation is blocked require changes to task 865's recommendations?

**Answer**: NO. Task 865's recommendations remain valid because:

1. **Layer separation**: Task 865 operates at Layer 2 (TaskFrame bridge), which takes a BMCS as input. The internal construction details of the BMCS (including how temporal coherence is achieved) are opaque to Layer 2.

2. **Axiom independence**: Task 865's Construction B2 works with ANY valid BMCS, whether constructed with or without axioms. The `fully_saturated_bmcs_exists` axiom (task 843's new correct axiom) provides exactly what task 865 needs.

3. **Box case resolution**: Task 865's box case uses MF/TF axioms to propagate box formulas across time, NOT the BMCS's forward_G/backward_H properties. The cross-sign propagation issue in task 843 is about temporal operators (G/H), not modal operators (Box).

4. **No cross-pollination needed**: The blocking issues in task 843 are specific to the temporal chain construction. Task 865's TruthLemma for the box case is about modal propagation, which is handled by the BMCS modal coherence conditions (`modal_forward`, `modal_backward`), not by temporal coherence.

### 3.3 Potential Synergy Opportunity (Not Required)

One potential synergy (NOT required, but could simplify both tasks):

**Unified canonical model construction**: If task 843 succeeds in building the full canonical model (Phase 5 of plan v007), it would:
- Prove `fully_saturated_bmcs_exists` as a theorem (eliminating the axiom)
- Provide a BMCS where ALL MCS are families (universal accessibility)
- Make task 865's modal propagation trivial (since all families have the same box content)

However, this is a long-term goal (25-35 hours estimated) and is NOT a dependency for task 865's current scope.

## 4. Recommendations

### 4.1 For Task 843 Phase 1 (Temporal Sorries)

**Recommended approach**: Alternative C (Deferral) for now, with potential for Alternative A (Interleaved) as a follow-up task.

**Rationale**:
1. Phase 4 (the critical goal) is COMPLETE - the FALSE axiom has been replaced with a CORRECT one
2. The 4 temporal sorries are documented technical debt, not mathematical errors
3. The interleaved construction (Alternative A) is significant effort (15-20h) with medium-high risk
4. The Zorn approach (Alternative B) may not even solve the problem

**Concrete actions**:
1. Document the sorries as "Construction assumptions (tolerated during development)" in SORRY_REGISTRY.md
2. Create a separate task for the interleaved chain construction if/when temporal sorry resolution becomes a priority
3. Proceed with task 843 Phases 2-3 (BoxContent symmetry, generalized diamond consistency) which are independent of Phase 1

### 4.2 For Task 865 (No Changes)

**Recommendation**: No changes to task 865 research-004 recommendations.

Task 865 can proceed with Construction B2 as designed. The blocking issues in task 843 do not affect task 865's implementation path.

### 4.3 For Plan v007 Updates

The plan v007 Phase 1 status should be updated to reflect:
- [PARTIAL] status with clear documentation of what's blocked
- Contingency "accept sorry markers" has been exercised per plan rollback instructions
- Phase 4 completion means the critical goal is achieved

## 5. Detailed Technical Analysis

### 5.1 Why Sharing the Base MCS is Insufficient

The `chains_share_base` lemma proves:
```lean
(dovetailForwardChainMCS base h_base_cons 0).val =
(dovetailBackwardChainMCS base h_base_cons 0).val
```

This ensures both chains have the SAME MCS at index 0. However, this is insufficient for cross-sign propagation because:

1. **Construction order matters**: The forward chain M_1 is built AFTER M_0, extending GContent(M_0). But M_0 was constructed via Lindenbaum from the base context, NOT from backward chain content.

2. **G-formulas don't flow backward**: If G phi is in M_{-1} (added during backward chain extension), it is NOT in M_0 (which was constructed first). Therefore, G phi cannot reach M_1.

3. **The shared base is "frozen"**: Once M_0 is constructed, it cannot be modified. Subsequent backward chain steps add MCS's M_{-1}, M_{-2}, ... but they don't update M_0.

### 5.2 What Would Fix Cross-Sign Propagation

For G phi in M_t (t < 0) to imply phi in M_{t'} (t' > 0), we need:

**Option 1: Bidirectional content inclusion at time 0**
- M_0 must include GContent(M_{-1}) AND be included in GContent seed for M_1
- This creates a cycle: M_0 depends on M_{-1}, but M_{-1} depends on M_0

**Option 2: Global consistency argument**
- Prove: If G phi is in ANY MCS in the chain, then phi is in all later MCS's
- This requires proving that the chain as a whole has a "global G-consistency" property
- The current construction proves this per-chain-segment but not globally

**Option 3: Interleaved construction with bidirectional seeds**
- Build M_0, then M_1 with seed GContent(M_0), then M_{-1} with seed HContent(M_0)
- But now M_2 seed = GContent(M_1)... where does M_{-1} come in?
- Need: at each step, include content from both directions

The interleaved approach is the most promising but requires careful engineering.

## 6. Sorry Characterization (Per Policy)

### 6.1 Current Sorries in DovetailingChain.lean

| Location | Category | Reason | Remediation | Transitive Impact |
|----------|----------|--------|-------------|-------------------|
| `forward_G` cross-sign (line ~418) | Construction assumption | Two-chain architecture cannot support cross-sign | Interleaved chain construction | `buildDovetailingChainFamily` |
| `backward_H` cross-sign (line ~429) | Construction assumption | Symmetric to forward_G | Interleaved chain construction | `buildDovetailingChainFamily` |
| `forward_F` (line ~445) | Development placeholder | Dovetailing enumeration not implemented | Nat.pair/unpair with Encodable | `buildDovetailingChainFamily` |
| `backward_P` (line ~452) | Development placeholder | Symmetric to forward_F | Nat.pair/unpair with Encodable | `buildDovetailingChainFamily` |

### 6.2 Transitive Inheritance

All 4 sorries propagate to:
- `buildDovetailingChainFamily`
- `temporal_coherent_family_exists_theorem`
- (Transitively) any theorem using the temporal coherent family

**Publication status**: These sorries block transitive sorry-freedom. Resolution required before publication without explicit disclosure.

## 7. References

### Task 843 Artifacts
- DovetailingChain.lean: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Plan v007: `specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-007.md`
- Implementation summary: `specs/843_remove_singleFamily_modal_backward_axiom/summaries/implementation-summary-20260210.md`
- Research-016: `specs/843_remove_singleFamily_modal_backward_axiom/reports/research-016.md`

### Task 865 Artifacts
- Research-004: `specs/865_canonical_task_frame_bimodal_completeness/reports/research-004.md`

### Policy Documents
- Proof debt policy: `.claude/context/project/lean4/standards/proof-debt-policy.md`
