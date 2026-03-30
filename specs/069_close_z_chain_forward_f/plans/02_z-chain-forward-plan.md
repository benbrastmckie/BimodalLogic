# Implementation Plan: Close Z_chain_forward_F via Dovetailed Construction

- **Task**: 69 - close_z_chain_forward_f
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None (research complete)
- **Research Inputs**: specs/069_close_z_chain_forward_f/reports/01_z-chain-forward-research.md
- **Artifacts**: plans/02_z-chain-forward-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Parent Task**: 58 (Wire completeness to FrameConditions)

## Overview

Close the `Z_chain_forward_F` theorem in UltrafilterChain.lean by proving F-resolution for the true dovetailed omega construction. The existing `omega_chain_true_dovetailed_forward` infrastructure (lines 3818-3897) already provides MCS preservation, box class agreement, G-theory propagation, and resolution of selected formulas. The missing piece is connecting fairness (via Nat.unpair/Nat.pair) to eventual F-resolution.

### Research Integration

Key findings from research report:
- 7 sorries traced to Z_chain_forward_F blocking completeness
- G-theory preservation invariant enables F-persistence argument
- Proof strategy: F(phi) persists until n0 = Nat.pair t (encode phi), then resolved at n0+1

## Goals & Non-Goals

**Goals**:
- Prove `omega_true_dovetailed_forward_F_resolution`: F(phi) at t implies phi at some s > t
- Replace sorries in `omega_forward_F_bounded_persistence` and `Z_chain_forward_F`
- Achieve zero sorries in the forward direction path

**Non-Goals**:
- Proving backward direction (Z_chain_backward_P) - can use bundle-level coherence
- Changing the dovetailed construction itself (already complete)
- Proving family-level temporal coherence (bundle-level suffices for completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F-persistence proof gap | H | M | Use G-theory preservation invariant: G(neg(phi)) not in M0 implies not in any chain(n) |
| Nat.pair bounds complexity | M | L | Use Mathlib's Nat.left_le_pair lemma directly |
| Induction termination issues | M | M | Use strong induction on n with explicit bound n0 = Nat.pair t (encode phi) |
| MCP tool timeouts | L | L | Use lake build for verification between phases |

## Implementation Phases

### Phase 1: F-Persistence Lemma [NOT STARTED]

**Goal**: Prove that F(phi) persists in the dovetailed chain until resolved

**Tasks**:
- [ ] Define `omega_true_dovetailed_F_persistence` lemma
- [ ] Prove: F(phi) in chain(n) and phi not in chain(n) implies F(phi) in chain(n+1) OR phi in chain(n+1)
- [ ] Key argument: G(neg(phi)) not spontaneously added because G-theory is preserved from M0, and if G(neg(phi)) were in M0 then F(phi) = neg(G(neg(phi))) couldn't be in M0 (contradiction)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (after line 3897)

**Verification**:
- [ ] `lake build` succeeds
- [ ] New lemma typechecks without sorry

### Phase 2: Fairness Lemma and Resolution Bound [NOT STARTED]

**Goal**: Prove fairness of Cantor pairing and establish resolution bound

**Tasks**:
- [ ] Prove `dovetail_fairness`: For any k : Nat, infinitely many n exist with (Nat.unpair n).2 = k
- [ ] Prove bound lemma: For F(phi) at step t, define n0 = Nat.pair t (encode phi), then n0 >= t
- [ ] Use `Nat.left_le_pair` from Mathlib for bound

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (after Phase 1 additions)

**Verification**:
- [ ] `lake build` succeeds
- [ ] Fairness lemma proves without sorry

### Phase 3: Main F-Resolution Theorem [NOT STARTED]

**Goal**: Prove the key F-resolution theorem for dovetailed chain

**Tasks**:
- [ ] State `omega_true_dovetailed_forward_F_resolution`
- [ ] Implement proof using bounded induction from t to n0
- [ ] Case 1: F(phi) persists until n0, then resolved at n0+1 (by `omega_chain_true_dovetailed_forward_resolves`)
- [ ] Case 2: F(phi) resolved before n0, done

**Timing**: 1.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (after Phase 2 additions)

**Verification**:
- [ ] `lake build` succeeds
- [ ] Main resolution theorem proves without sorry

### Phase 4: Connect to Z_chain [NOT STARTED]

**Goal**: Wire dovetailed F-resolution to close Z_chain_forward_F

**Tasks**:
- [ ] Replace sorry in `omega_forward_F_bounded_persistence` (line 3611)
- [ ] Two options:
  - Option A: Show omega_chain_forward equivalent to omega_chain_true_dovetailed_forward
  - Option B: Update `Z_chain` to use true dovetailed construction (cleaner)
- [ ] Replace sorry in `Z_chain_forward_F` (line 2486) and `Z_chain_forward_F'` (line 3666)
- [ ] Handle backward direction: use bundle-level argument or show F(phi) in backward chain resolves via forward chain

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 2486, 3593, 3611, 3666)

**Verification**:
- [ ] `lake build` succeeds with zero sorries in temporal coherence path
- [ ] grep for "sorry" in file shows no remaining sorries in Z_chain_forward_F chain

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `grep -n "sorry" UltrafilterChain.lean` shows reduction in sorry count
- [ ] Type-check F-resolution theorem with explicit goal inspection via `lean_goal`
- [ ] Verify completeness proof path: Z_chain_forward_F -> bfmcs_from_mcs_temporally_coherent -> bundle_validity_implies_provability -> completeness_over_Int

## Artifacts & Outputs

- plans/02_z-chain-forward-plan.md (this file)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- summaries/03_z-chain-forward-summary.md (post-implementation)

## Rollback/Contingency

If implementation fails:
1. Git stash changes
2. Preserve partial progress with TODO comments at sorry locations
3. Consider bundle-level temporal coherence as fallback (uses witness existence at bundle level rather than chain level)
4. Document specific proof gap for future work
