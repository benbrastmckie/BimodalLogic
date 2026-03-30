# Implementation Plan: Bulldozing via Seeded F-Content

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 4-8 hours
- **Dependencies**: None (replaces fuel approach from Plans v1-v12)
- **Research Inputs**: reports/37_team-research.md
- **Artifacts**: plans/13_bulldozing-f-persistence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Plan Version**: 13

## Overview

This plan implements the **bulldozing via seeded F-content** approach to close the two remaining sorries at lines 3006 and 3037 in SuccChainFMCS.lean. The fuel approach (Plans v1-v12) is a confirmed dead end because F-obligations can be DESTROYED by Lindenbaum extension. The solution is minimal: add `f_content u` to the seed definition, which forces F-persistence by construction and enables a cascade proof that all F-obligations resolve within B steps.

### Research Integration

From **Report 37 (Team Research - Bulldozing vs Construction Alternatives)**:
- **Root Cause**: F-obligations can be destroyed when Lindenbaum adds `G(neg psi)`
- **Solution**: Add `f_content(u)` to `constrained_successor_seed_restricted` (one line change)
- **Why it works**: With `F(psi)` in seed, MCS consistency prevents adding `G(neg psi)`
- **Result**: F-persistence by construction; combined with BRS, all depths resolve within B steps
- **Consistency**: `f_content(u) ⊆ u` and u is consistent, so extended seed stays consistent

## Goals & Non-Goals

**Goals**:
- Add `f_content u` to the seed definition in SuccExistence.lean
- Prove seed consistency for the extended seed
- Prove F-persistence theorem for the restricted chain
- Prove `boundary_implies_k_lt_B` using F-persistence + BRS cascade
- Close sorries at lines 3006 and 3037 with the new lemma

**Non-Goals**:
- Implementing alternative approaches (fairness counter, well-founded, explicit fair sequence)
- Removing the fuel parameter entirely (it may still be useful for termination structure)
- Changing the Lindenbaum construction or MCS properties

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency proof harder than expected | M | L | `f_content(u) ⊆ u` by definition; existing consistency proof adapts directly |
| Downstream lemma breakage | M | L | Adding to seed is monotonic; existing subset proofs preserved |
| BRS cascade proof complexity | M | M | Break into depth-specific lemmas; use induction on B-k |
| DRM preservation proof needed | L | L | `f_content(u) ⊆ deferralClosure(phi)` follows from DRM property of u |

## Implementation Phases

### Phase 1: Add f_content to Seed Definition [COMPLETED]

**Goal**: Modify `constrained_successor_seed_restricted` to include `f_content u`

**Tasks**:
- [ ] Edit SuccExistence.lean line 351-352 to add `∪ f_content u` to the seed definition
- [ ] Update the membership lemma `mem_constrained_successor_seed_restricted_iff` to include the new disjunct
- [ ] Add `f_content_subset_constrained_successor_seed_restricted` lemma
- [ ] Run `lake build Theories.Bimodal.Metalogic.Bundle.SuccExistence` to check for breakage

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — seed definition (~line 351)

**Verification**:
- Seed definition includes 5 components: g_content, deferralDisjunctions, p_step_blocking, boundary_resolution_set, f_content
- Membership lemma reflects all 5 components
- Subset lemma compiles

---

### Phase 2: Prove Seed Consistency for Extended Seed [COMPLETED]

**Goal**: Prove `constrained_successor_seed_restricted_consistent` still holds with f_content

**Tasks**:
- [ ] Verify `f_content(u) ⊆ u` lemma exists or prove it
- [ ] Adapt `constrained_successor_seed_restricted_consistent` proof to handle the new f_content case
- [ ] The key insight: since `f_content(u) ⊆ u` and u is consistent, adding f_content to the seed preserves consistency
- [ ] Run `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — consistency proof (~line 1715)

**Verification**:
- `constrained_successor_seed_restricted_consistent` compiles without sorry
- Downstream uses of seed consistency still work

---

### Phase 3: Prove F-Persistence Theorem [COMPLETED]

**Goal**: Prove that F-formulas persist through the chain construction

**Tasks**:
- [ ] Define `constrained_successor_restricted_f_persistence` theorem:
  ```lean
  theorem constrained_successor_restricted_f_persistence (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (psi : Formula)
      (h : Formula.some_future psi ∈ M0.world) :
      Formula.some_future psi ∈ (constrained_successor_restricted phi M0).world
  ```
- [ ] Prove by showing: F(psi) ∈ seed ⊆ successor (since f_content now in seed)
- [ ] Extend to chain: `restricted_forward_chain_f_persistence`:
  ```lean
  theorem restricted_forward_chain_f_persistence (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
      (h : Formula.some_future psi ∈ restricted_forward_chain phi M0 0) :
      Formula.some_future psi ∈ restricted_forward_chain phi M0 k ∨
      psi ∈ restricted_forward_chain phi M0 k
  ```
- [ ] Run `lake build` to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — new theorems (~line 2100 area)

**Verification**:
- F-persistence theorem compiles
- Chain F-persistence theorem compiles
- Lean axiom check passes

---

### Phase 4: Prove boundary_implies_k_lt_B [PARTIAL]

**Goal**: Prove that if `F(iter_F n theta) ∈ chain(k)` with boundary condition, then `k < B`

**Tasks**:
- [ ] Define `boundary_implies_k_lt_B` theorem:
  ```lean
  theorem boundary_implies_k_lt_B (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (k n : Nat) (theta : Formula)
      (h_iter_in : iter_F (n + 1) theta ∈ restricted_forward_chain phi M0 k)
      (h_iter_not : iter_F (n + 2) theta ∉ restricted_forward_chain phi M0 k)
      (h_n : n + 1 < closure_F_bound phi) :
      k < closure_F_bound phi
  ```
- [ ] Prove using F-persistence + BRS cascade:
  - F-persistence ensures: F(psi) ∈ chain(0) → F(psi) ∈ chain(j) for all j until resolved
  - BRS ensures: at depth B-1, F-formula gets resolved (not deferred)
  - Cascade: depth d formula resolves by step B-d at latest
  - Therefore: if k >= B, all F-formulas would be resolved, contradicting boundary condition
- [ ] May need helper lemmas for the cascade induction
- [ ] Run `lake build` to verify

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — new theorem (~line 2850 area)

**Verification**:
- `boundary_implies_k_lt_B` compiles without sorry
- Cascade reasoning is sound

---

### Phase 5: Close Sorries at Lines 3006 and 3037 [COMPLETED]

**Goal**: Replace the sorries with actual proofs using `boundary_implies_k_lt_B`

**Tasks**:
- [ ] At line 3006: replace `sorry` with:
  ```lean
  exact absurd (boundary_implies_k_lt_B phi M0 k n theta h_iter_in h_iter_not h_n_bound) (Nat.not_lt.mpr hk)
  ```
  (adjust variable names as needed from context)
- [ ] At line 3037: apply similar pattern
- [ ] Ensure both branches of the by_cases are closed
- [ ] Run `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — lines 3006 and 3037

**Verification**:
- No sorries remain in `restricted_bounded_witness_wf`
- Full file compiles without errors

---

### Phase 6: Verification and Axiom Check [COMPLETED]

**Goal**: Verify the complete proof chain is sound and axiom-free

**Tasks**:
- [ ] Run `lake build` on the full project
- [ ] Use `lean_verify` MCP tool to check for axiom usage
- [ ] Verify no sorry remains in the completeness proof chain
- [ ] Check that `bundle_validity_implies_provability` (if it exists) compiles
- [ ] Document any remaining work needed

**Timing**: 30 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- Any file importing these

**Verification**:
- `lake build` succeeds
- Axiom check shows only expected axioms (propext, Classical, etc.)
- No sorry in completeness chain

## Testing & Validation

- [ ] `lake build` succeeds for all modified files
- [ ] `lean_verify` shows no unexpected axioms in new theorems
- [ ] `restricted_bounded_witness_wf` has no sorries
- [ ] F-persistence theorem statement matches expected semantics
- [ ] Cascade reasoning covers all depths 0 to B-1

## Artifacts & Outputs

- `plans/13_bulldozing-f-persistence.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Summary file upon completion: `summaries/13_bulldozing-summary.md`

## Rollback/Contingency

If the bulldozing approach fails:
1. Revert changes to seed definition (restore original 4-component union)
2. Revert consistency proof changes
3. Consider Alternative A2 from Report 37: Strengthen BRS to all depths (5-8h, moderate risk)
4. Document failure mode in a new research report

Note: Git commits should be made after each successful phase to enable partial rollback.
