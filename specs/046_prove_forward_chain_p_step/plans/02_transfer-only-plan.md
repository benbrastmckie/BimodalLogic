# Implementation Plan: Task #46 (v2 - Transfer Only)

- **Task**: 46 - prove_forward_chain_p_step
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Dependencies**: Task 45 (research completed), CanonicalFMCS.lean sorry-free infrastructure
- **Research Inputs**: specs/046_prove_forward_chain_p_step/reports/02_team-research.md
- **Artifacts**: plans/02_transfer-only-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Revision Notes

**v2 replaces v1**: The v1 plan included an axiom fallback (Phase 2b) which was incorrectly used by the implementation agent. Axioms are never acceptable. This revised plan eliminates the axiom option entirely and focuses exclusively on the transfer-based proof approach.

## Overview

Fill the sorry at SuccChainFMCS.lean:350 for the forward chain p-step case using the canonical model transfer pattern. The research conclusively shows that `canonical_backward_P` infrastructure is sorry-free and the transfer pattern (demonstrated by `transfer_backward_P` in FMCSTransfer.lean) is the correct approach.

**Constraint**: No axioms may be introduced. The proof must be structural, using existing sorry-free infrastructure.

### Research Integration

Key findings from 02_team-research.md:
- `canonical_backward_P` (CanonicalFrame.lean:170) is sorry-free
- `canonicalMCS_backward_P` (CanonicalFMCS.lean:271) wraps it for CanonicalMCS domain
- `transfer_backward_P` (FMCSTransfer.lean:305) demonstrates the transfer pattern
- Bidirectional chain construction is impossible (Lindenbaum circularity)

### Transfer Pattern (from FMCSTransfer.lean:305)

The proven `transfer_backward_P` follows this pattern:
1. P(phi) ∈ transferredMCS T d → P(phi) ∈ canonicalMCS_mcs (T.retract d)
2. `canonical_backward_P` → witness W with ExistsTask_past and phi ∈ W
3. Create CanonicalMCS element w from W
4. ExistsTask_past → w < retract d (by lt_of_canonicalR_past)
5. T.embed w gives the target element, T.retract_left_inverse proves membership

## Goals & Non-Goals

**Goals**:
- Fill the sorry at SuccChainFMCS.lean:350 using the transfer pattern
- Ensure `lake build` succeeds with no sorries in succ_chain_fam_p_step
- Ensure `succ_chain_backward_P` compiles successfully
- No new axioms introduced

**Non-Goals**:
- Adding any axioms (explicitly forbidden)
- Proving p-step directly from the successor construction (impossible per research)
- Modifying the Succ relation definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Surjectivity proof complex (witness in chain image) | H | M | Use FMCSTransfer pattern which avoids surjectivity via embed/retract |
| Type mismatches in transfer | M | L | Follow FMCSTransfer.lean exactly as template |
| forward_chain not an FMCSTransfer domain | H | M | Build lightweight adapter or prove p-step directly via canonical_backward_P |

## Implementation Phases

### Phase 1: Understand the Transfer Infrastructure [NOT STARTED]

**Goal**: Map the existing FMCSTransfer pattern to the forward_chain context

**Tasks**:
- [ ] Read `FMCSTransfer.lean` fully — understand the `FMCSTransfer D` structure and what it requires
- [ ] Read `transfer_backward_P` proof (line 305) in detail — trace each step
- [ ] Determine if `succ_chain_fam` can serve as an `FMCSTransfer` domain (does it have embed/retract/order?)
- [ ] If not directly applicable: identify what minimal adapter is needed
- [ ] Check whether `canonical_backward_P` can be applied directly to forward_chain elements (they ARE MCSs)

**Key insight to verify**: Each `forward_chain M0 k` is an MCS (by construction). So `canonical_backward_P` can be applied directly to any `forward_chain M0 (k+1)` element.

**Timing**: 45 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` — full transfer infrastructure
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean:170` — canonical_backward_P signature
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean:271` — canonicalMCS_backward_P
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — forward_chain construction, the sorry

**Verification**:
- Document the exact path from P(phi) ∈ forward_chain(k+1) to the goal
- Identify all lemmas needed

---

### Phase 2: Implement Transfer-Based Proof [NOT STARTED]

**Goal**: Use canonical_backward_P to prove forward_chain p-step without axioms

**Approach A — Direct canonical_backward_P** (preferred if applicable):

Since `forward_chain M0 (k+1)` is an MCS, if P(phi) ∈ forward_chain(k+1):
1. Apply `canonical_backward_P` to get witness W with phi ∈ W and ExistsTask_past between forward_chain(k+1) and W
2. Show that the Succ relationship between forward_chain(k) and forward_chain(k+1) combined with ExistsTask_past implies the p-step condition
3. Connect: either phi ∈ forward_chain(k) or P(phi) ∈ forward_chain(k)

**Approach B — FMCSTransfer adapter** (if approach A doesn't work directly):

1. Build an `FMCSTransfer ℤ` (or `FMCSTransfer ℕ`) structure for the succ_chain
2. Define `retract : ℤ → CanonicalMCS` as `⟨succ_chain_fam M0 n, is_mcs_proof⟩`
3. Define `embed : CanonicalMCS → ℤ` (requires choice or construction)
4. Prove required FMCSTransfer axioms
5. Apply `transfer_backward_P` directly

**Tasks**:
- [ ] Try Approach A first — apply canonical_backward_P directly
- [ ] If A works: prove the connection from ExistsTask_past witness to p-step condition
- [ ] If A doesn't work: implement Approach B (FMCSTransfer adapter)
- [ ] Fill the sorry at SuccChainFMCS.lean:350
- [ ] Add any necessary helper lemmas in SuccChainFMCS.lean

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — add helper lemmas and fill sorry

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds
- No sorries in forward chain case of succ_chain_fam_p_step
- No new axioms (verify with `lean_verify` or grep for `axiom`)

---

### Phase 3: Integration Verification [NOT STARTED]

**Goal**: Ensure the fix integrates correctly with dependent theorems

**Tasks**:
- [ ] Run full `lake build` to check all dependent files compile
- [ ] Verify `succ_chain_backward_P` compiles (uses succ_chain_fam_p_step)
- [ ] Grep for any new `sorry` or `axiom` introduced — must be zero
- [ ] Verify FMCS coherence theorems still work

**Timing**: 20 minutes

**Files to check**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — verify no sorries
- Files that import SuccChainFMCS.lean

**Verification**:
- `lake build` succeeds
- `grep -rn "sorry\|axiom" Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` shows no new entries
- All dependent theorems compile

---

### Phase 4: Documentation and Cleanup [NOT STARTED]

**Goal**: Document the transfer approach and clean up

**Tasks**:
- [ ] Update docstring for `succ_chain_fam_p_step` explaining the transfer proof approach
- [ ] Remove stale comments about "pending infrastructure" or "temporal duality"
- [ ] Add references to canonical_backward_P and the transfer pattern
- [ ] Remove any debug/temporary code

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- Documentation accurately reflects the transfer-based implementation
- No stale TODO comments remain

## Testing & Validation

- [ ] `lake build` succeeds with zero sorries in succ_chain_fam_p_step
- [ ] `succ_chain_backward_P` compiles successfully
- [ ] No new sorries introduced elsewhere
- [ ] No new axioms introduced (CRITICAL)
- [ ] Full `lake build` completes without errors

## Artifacts & Outputs

- `specs/046_prove_forward_chain_p_step/plans/02_transfer-only-plan.md` (this file)
- `specs/046_prove_forward_chain_p_step/summaries/01_implementation-summary.md` (upon completion)
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

## Rollback/Contingency

If the transfer approach encounters a genuine mathematical obstacle:
1. Document the specific obstacle with full detail
2. Return as BLOCKED with the obstacle description
3. Do NOT fall back to axioms — report the blocker for further research
