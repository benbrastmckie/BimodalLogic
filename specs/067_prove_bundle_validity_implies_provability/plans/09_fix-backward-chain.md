# Implementation Plan: Task #67 (Plan v9)

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [PARTIAL]
- **Effort**: 6 hours
- **Dependencies**: Report 23 (team research on F-persistence blockers)
- **Research Inputs**: specs/067_prove_bundle_validity_implies_provability/reports/23_team-research.md
- **Artifacts**: plans/09_fix-backward-chain.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Fix the two sorry sites in the backward chain construction (`constrained_predecessor_restricted_g_persistence_reverse` at line 3944 and `constrained_predecessor_restricted_f_step_forward` at line 4001) in SuccChainFMCS.lean. These block `constrained_predecessor_restricted_succ`, which is needed for full Z-chain coherence via `build_restricted_tc_family`. Once the backward chain is sorry-free, address the remaining fuel-exhaustion sorries in bounded witness lemmas and wire the restricted truth lemma to the completeness theorem.

### Research Integration

Key findings from Report 23:
1. The forward direction (`constrained_successor_restricted`) is sorry-free and produces valid Succ relations
2. The backward chain has two sorry sites preventing `constrained_predecessor_restricted_succ`
3. The predecessor seed is `h_content(u) ∪ pastDeferralDisjunctions(u) ∪ f_step_blocking_formulas_restricted(phi, u)`
4. The f_step_blocking_formulas_restricted contains `G(neg chi)` for chi in u where F(chi) not in u -- this is the key mechanism for both proofs
5. Family-level temporal coherence is mathematically required (bundle-level insufficient for truth lemma G backward case)

## Goals & Non-Goals

**Goals**:
- Prove `constrained_predecessor_restricted_g_persistence_reverse` (line 3944)
- Prove `constrained_predecessor_restricted_f_step_forward` (line 4001)
- Eliminate fuel-exhaustion sorries in bounded witness lemmas (lines 2913, 4341, 4499, 4695)
- Wire `RestrictedTemporallyCoherentFamily` through to completeness

**Non-Goals**:
- Fixing the deprecated (non-restricted) sorry sites (lines 1659, 1688, 2005)
- Fixing the Soundness.lean sorries (separate concern)
- Fixing the SuccChainTruth.lean sorry (intentional documentation of bundling necessity)
- Proving the general G-propagation and H-step sorries in RestrictedTruthLemma.lean (not needed for completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| g_persistence_reverse proof requires axiom not available in DRM | H | M | Fall back to adding G-blocking formulas to predecessor seed, or prove via contrapositive using consistency |
| f_step_forward case (chi not in u, F(chi) not in u) is unprovable with current seed | H | M | Add additional blocking formulas to seed, or prove the case is impossible within deferralClosure |
| Fuel-exhaustion sorries are fundamentally incomplete (not just fuel issues) | M | L | These are genuinely unreachable with sufficient fuel; prove by adding termination measure argument |
| RestrictedTruthLemma completeness bridge needs more infrastructure | M | M | The bridge already exists (neg_consistent_gives_mcs_without_phi); may need wiring only |

## Implementation Phases

### Phase 1: Prove g_persistence_reverse (line 3944) [PARTIAL]

**Goal**: Prove that `G(chi) in predecessor implies chi in u` for the restricted constrained predecessor.

**Strategy**: The proof needs to show that any G(chi) appearing in v (the Lindenbaum extension of the predecessor seed) must have chi in u. Two approaches:

**Approach A (Contrapositive)**: If chi not in u, show G(chi) not in v.
- chi not in u and chi in deferralClosure: by DRM maximality, insert chi u is inconsistent
- This means u derives neg(chi) within deferralClosure
- We need to show v also derives neg(chi), making G(chi) inconsistent with v
- Key: h_content(u) is in the seed. If H(neg(chi)) in u, then neg(chi) in h_content(u) in seed in v
- But we need neg(chi) in v directly, not via H

**Approach B (f_step_blocking argument)**: The seed contains G(neg(xi)) for xi in u where F(xi) not in u. If chi not in u, we need to show this blocks G(chi).
- If chi not in u but chi in deferralClosure, then neg(chi) is "derivable" from u
- Show that the seed forces neg(G(chi)) = F(neg(chi)) via maximality of v within deferralClosure

**Approach C (Seed augmentation)**: If neither A nor B works, modify `constrained_predecessor_seed_restricted` to include g_content_blocking formulas that directly prevent unwanted G formulas. This would require re-proving seed consistency and subset-of-deferralClosure.

**Tasks**:
- [ ] Analyze the exact goal state at line 3944 using `lean_goal`
- [ ] Attempt contrapositive proof: chi not in u implies G(chi) not in v
- [ ] If contrapositive fails, attempt f_step_blocking argument
- [ ] If both fail, augment the seed with g_content_blocking formulas
- [ ] Verify `lake build` passes

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Replace sorry at line 3944

**Verification**:
- `lean_goal` at the sorry position shows no remaining goals
- `lake build` passes
- `constrained_predecessor_restricted_succ` compiles (depends on this)

---

### Phase 2: Prove f_step_forward (line 4001) [NOT STARTED]

**Goal**: Prove the remaining sorry in `constrained_predecessor_restricted_f_step_forward` -- the case where chi not in u AND F(chi) not in u, but F(chi) appears in v.

**Strategy**: Show that when chi not in u and F(chi) not in u, F(chi) cannot be in v (the predecessor).

The key mechanism: The f_step_blocking_formulas_restricted adds G(neg(xi)) to the seed for xi in u where F(xi) not in u. But this doesn't directly block F(chi) when chi not in u.

**Approach A (Impossibility within deferralClosure)**: If chi not in u and F(chi) not in u, and both are in deferralClosure, show that F(chi) being in v contradicts v's construction.
- By DRM maximality of u: insert chi u is inconsistent and insert F(chi) u is inconsistent
- u derives neg(chi) and neg(F(chi)) = G(neg(chi))
- G(neg(chi)) derivable from u means... H(G(neg(chi))) should be derivable from u by some axiom?
- If the seed contains enough of u's consequences, G(neg(chi)) propagates to v

**Approach B (Show F(chi) not in deferralClosure in this case)**: If chi not in u, perhaps F(chi) not being in deferralClosure makes the case vacuous.

**Approach C (Seed augmentation)**: Add explicit F-blocking formulas for the chi-not-in-u case.

**Tasks**:
- [ ] Analyze the exact goal state at line 4001 using `lean_goal`
- [ ] Determine if the case (chi not in u, F(chi) not in u, F(chi) in v) is possible
- [ ] If possible, identify what seed augmentation prevents it
- [ ] If impossible, construct the contradiction proof
- [ ] Verify `lake build` passes

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Replace sorry at line 4001

**Verification**:
- `lean_goal` at the sorry position shows no remaining goals
- `lake build` passes
- `constrained_predecessor_restricted_succ` is fully sorry-free

---

### Phase 3: Fix fuel-exhaustion sorries [NOT STARTED]

**Goal**: Eliminate the four remaining fuel-exhaustion sorries at lines 2913, 4341, 4499, and 4695.

**Strategy**: These sorries all occur in fuel=0 base cases of recursion. They are semantically unreachable because the initial fuel (B*B+1 where B = closure_F_bound phi) always exceeds the required depth. Two approaches:

**Approach A (Prove unreachability)**: Add a hypothesis tracking that fuel >= required_depth, and show fuel=0 implies contradiction. This requires threading an additional invariant through the recursion.

**Approach B (Omega argument)**: Show that the fuel decreases by at least 1 per recursion step, and the initial fuel exceeds the maximum possible depth (bounded by deferralClosure finiteness).

**Approach C (Restructure recursion)**: Replace the fuel-based recursion with well-founded recursion on the depth d, eliminating the fuel parameter entirely.

**Tasks**:
- [ ] Assess whether restructuring to well-founded recursion is feasible
- [ ] If feasible, refactor `restricted_bounded_witness_fueled` (line ~2870) to use `termination_by d`
- [ ] Similarly refactor `restricted_backward_bounded_witness_fueled` (line ~4327)
- [ ] Similarly refactor `restricted_combined_bounded_witness_fueled` (line ~4485)
- [ ] Similarly refactor `restricted_combined_bounded_witness_P_fueled` (line ~4676)
- [ ] Verify `lake build` passes

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Refactor four fueled lemmas

**Verification**:
- All four sorry sites eliminated
- `lake build` passes
- `build_restricted_tc_family` is fully sorry-free

---

### Phase 4: Wire to completeness [NOT STARTED]

**Goal**: Connect the sorry-free `RestrictedTemporallyCoherentFamily` through to a completeness theorem.

**Strategy**: The RestrictedTruthLemma.lean already has:
1. `restricted_truth_lemma` -- DRM membership iff extended chain membership for subformulas
2. `neg_consistent_gives_mcs_without_phi` -- From consistent neg(phi), get MCS without phi
3. The completeness bridge section (lines 316-346)

What's needed: Wire from `build_restricted_tc_family` (which becomes sorry-free after Phases 1-3) through the restricted truth lemma to the final `bundle_validity_implies_provability` theorem.

**Tasks**:
- [ ] Verify `build_restricted_tc_family` is sorry-free after Phases 1-3
- [ ] Check if `restricted_truth_lemma` needs temporal coherence (it shouldn't -- it only uses DRM subset/maximality)
- [ ] Verify `neg_consistent_gives_mcs_without_phi` connects to the existing BFMCS bundle construction
- [ ] Wire the completeness argument: not-provable -> consistent neg(phi) -> DRM seed -> RestrictedTemporallyCoherentFamily -> extended MCS without phi -> canonical model falsifying phi -> not valid
- [ ] If additional glue lemmas are needed, prove them
- [ ] Verify `lake build` passes

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` - Add completeness wiring if needed
- Possibly `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Update completeness theorem

**Verification**:
- `bundle_validity_implies_provability` compiles (possibly still with sorryAx from other paths)
- The restricted completeness path is identified as sorry-free via `#print axioms`
- `lake build` passes

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] `lean_goal` confirms no remaining goals at each former sorry site
- [ ] `#print axioms build_restricted_tc_family` shows no sorryAx after Phase 3
- [ ] `#print axioms restricted_truth_lemma` shows no sorryAx
- [ ] The critical path from `neg_consistent_gives_mcs_without_phi` to completeness is sorry-free

## Artifacts & Outputs

- Modified `SuccChainFMCS.lean` with proven backward chain properties
- Modified `RestrictedTruthLemma.lean` with completeness wiring (if needed)
- Implementation summary documenting the proof strategies used

## Rollback/Contingency

If the backward chain sorries prove fundamentally unprovable with the current seed construction:
1. Augment `constrained_predecessor_seed_restricted` with additional blocking formulas
2. Re-prove seed consistency and deferralClosure containment
3. The forward chain analogs provide a template for the augmentation pattern

If fuel-exhaustion refactoring breaks termination checking:
1. Keep the fuel-based approach
2. Add an explicit fuel-tracking invariant instead
3. The sorry is in a semantically unreachable branch, so it doesn't affect correctness of the main path

## Sorry Inventory

### Critical Path (this plan addresses these)
| Line | Theorem | Status |
|------|---------|--------|
| 3944 | `constrained_predecessor_restricted_g_persistence_reverse` | Phase 1 |
| 4001 | `constrained_predecessor_restricted_f_step_forward` | Phase 2 |
| 2913 | `restricted_bounded_witness_fueled` (fuel=0) | Phase 3 |
| 4341 | `restricted_backward_bounded_witness_fueled` (fuel=0) | Phase 3 |
| 4499 | `restricted_combined_bounded_witness_fueled` (fuel=0) | Phase 3 |
| 4695 | `restricted_combined_bounded_witness_P_fueled` (fuel=0) | Phase 3 |

### Non-critical (not addressed by this plan)
| Line | Theorem | Reason |
|------|---------|--------|
| 1659 | `g_content_union_brs_consistent` | Deprecated path (multi-BRS case) |
| 1688 | `augmented_seed_consistent` | Deprecated path |
| 2005 | `constrained_successor_seed_restricted_consistent` (multi-BRS) | Deprecated path |
| RestrictedTruthLemma:116 | `restricted_chain_G_propagates` | Not needed for completeness |
| RestrictedTruthLemma:158 | `restricted_chain_H_step` | Not needed for completeness |
