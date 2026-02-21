# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [NOT STARTED]
- **Effort**: 45 hours (optimistic: 33h, pessimistic: 58h)
- **Dependencies**: None
- **Research Inputs**: specs/916_implement_fp_witness_obligation_tracking/reports/research-003.md (team synthesis)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Close the 2 remaining sorries in DovetailingChain.lean (forward_F at line 919, backward_P at line 926) using an Omega^2 Inner Construction approach. Based on team research (3 teammates), this approach is mathematically sound and aligns with standard textbook techniques (Goldblatt 1992, Blackburn et al. 2001).

### Research Integration

Key findings from research-003.md integrated into this plan:

1. **Approaches A, B, C, G ruled out** - Each has fatal mathematical blockers
2. **Omega^2 inner construction** is the viable path - matches textbook techniques
3. **Core lemma**: `temporal_witness_seed_consistent` is the foundation
4. **F-persistence gap**: `F(psi) -> G(F(psi))` is NOT derivable, so F-formulas do not self-persist
5. **Solution**: Place witnesses in the seed (the ONLY way to control MCS contents)

## Goals & Non-Goals

**Goals**:
- Eliminate both remaining sorries in DovetailingChain.lean (lines 919, 926)
- Prove forward_F and backward_P for the dovetailing chain
- Maintain compatibility with existing cross-sign propagation proofs (600+ lines)
- Use proven infrastructure: `temporal_witness_seed_consistent`, `past_temporal_witness_seed_consistent`

**Non-Goals**:
- Modifying the BFMCS interface
- Restructuring downstream completeness theorems
- Proving constructive Lindenbaum (boneyard approach - ruled out)
- Building canonical model (duplicates infrastructure - ruled out)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inner chain witness accumulation fails | HIGH | MEDIUM | F-persistence through GContent-based seeds is proven; use immediate predecessor only |
| Limit MCS construction complexity | MEDIUM | MEDIUM | Use Zorn on directed system of inner MCSes |
| Coverage argument is too complex | HIGH | HIGH | Use Encodable surjectivity + immediate predecessor check; dovetailing handles enumeration |
| Downstream theorem breakage | MEDIUM | LOW | Cross-sign proofs depend only on GContent extension; run `lake build` after each phase |
| Context exhaustion during implementation | LOW | MEDIUM | Write handoffs per existing protocol; phases are sized for context limits |

## Sorry Characterization

### Pre-existing Sorries
- `buildDovetailingChainFamily_forward_F` at line 919 (forward_F sorry)
- `buildDovetailingChainFamily_backward_P` at line 926 (backward_P sorry)

### Expected Resolution
- Phase 3 resolves forward_F sorry via coverage argument over omega^2 inner chain
- Phase 5 resolves backward_P sorry symmetrically using past direction

### New Sorries
- None expected. If proof complexity requires temporary sorry, will document with remediation timeline in handoff.

### Remaining Debt
After this implementation:
- 0 sorries expected in `forward_F` and `backward_P`
- Remaining sorries (if any) will be in auxiliary omega^2 chain lemmas with clear resolution path

## Implementation Phases

### Phase 1: Define Omega^2 Chain Structure [NOT STARTED]

- **Dependencies:** None
- **Goal:** Create the inner chain and outer chain definitions that enable witness placement in seeds

**Tasks**:
- [ ] Define `innerChainMCS` - inner chain at each time point t
  - Base case: `innerChainMCS t 0 = Lindenbaum(GContent(outerChain (t-1)))`
  - Inductive: `innerChainMCS t (k+1)` uses `{psi_k} ∪ GContent(innerChainMCS t k)` if `F(psi_k) ∈ innerChainMCS t k`
- [ ] Define `outerChain` - takes limit of inner chain at each time via Zorn
- [ ] Prove `innerChainMCS_consistent`: each inner MCS is consistent
- [ ] Set up formula enumeration using `Encodable.ofCountable`
- [ ] Define the index bijection using `Nat.pairEquiv` for omega^2 indexing

**Timing**: 10-15 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - add inner chain definitions

**Verification**:
- `lake build` succeeds
- New definitions type-check
- `#check innerChainMCS` shows expected type signature

---

### Phase 2: Prove Inner Chain Properties [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Establish key lemmas about the inner chain behavior

**Tasks**:
- [ ] Prove `innerChain_witness_in`: witnessed formula psi enters the MCS at inner step k+1
- [ ] Prove `innerChain_F_persists`: F(psi) persists when psi is witnessed
  - Key insight: After adding psi to seed, F(psi) remains in MCS via GContent extension
- [ ] Prove `innerChain_monotone_GContent`: GContent is monotone through inner chain
- [ ] Prove `innerChain_extends_base`: each inner MCS extends the base GContent

**Timing**: 8-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - add lemmas

**Verification**:
- All lemmas compile without sorry
- `innerChain_F_persists` is the critical milestone - must complete before Phase 3

---

### Phase 3: Prove Coverage Argument (forward_F) [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove that every F(psi) in M_t has psi witnessed at some s > t

**Tasks**:
- [ ] Prove formula enumeration is surjective via `Encodable.encode_decode`
- [ ] Prove inner chain eventually processes every formula (dovetailing argument)
- [ ] Prove main coverage lemma: for any F(psi) in outerChain(t), exists s > t with psi in outerChain(s)
  - Uses: immediate predecessor witnessing from `temporal_witness_seed_consistent`
  - Uses: enumeration dovetailing ensures psi_k is processed at some inner step
- [ ] Replace sorry at line 919 with proof using coverage lemma
- [ ] Verify `buildDovetailingChainFamily_forward_F` compiles

**Timing**: 10-18 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - prove forward_F

**Verification**:
- Line 919 sorry eliminated
- `lake build` succeeds
- `#print axioms buildDovetailingChainFamily_forward_F` shows no axioms beyond standard

---

### Phase 4: Integrate with BFMCS [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Connect omega^2 chain construction with existing BFMCS infrastructure

**Tasks**:
- [ ] Adapt `buildDovetailingChainFamily` to use new omega^2 chain internally
- [ ] Verify downstream theorems still compile unchanged
- [ ] Verify cross-sign propagation lemmas (forward_G, backward_H) remain valid
- [ ] Verify `dovetailFamily_theorem` still works
- [ ] Run full `lake build` to catch any regressions

**Timing**: 5-8 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - refactor BFMCS connection
- Potentially other files if imports break (verify with `lake build`)

**Verification**:
- Full `lake build` succeeds
- No new sorries introduced
- `#print axioms dovetailFamily_theorem` shows expected dependencies

---

### Phase 5: Backward_P (Symmetric Construction) [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Prove backward_P symmetrically using past direction

**Tasks**:
- [ ] Define `innerChainMCS_past` - mirror of inner chain for past direction
  - Uses `HContent` instead of `GContent`
  - Uses `past_temporal_witness_seed_consistent` instead of `temporal_witness_seed_consistent`
- [ ] Prove symmetric inner chain properties for past direction
- [ ] Prove coverage argument for P-formulas (mirror of forward_F)
- [ ] Replace sorry at line 926 with proof
- [ ] Verify `buildDovetailingChainFamily_backward_P` compiles

**Timing**: 3-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - prove backward_P

**Verification**:
- Line 926 sorry eliminated
- `lake build` succeeds
- Both forward_F and backward_P sorries resolved

---

## Testing & Validation

- [ ] `lake build` succeeds with zero new sorries in DovetailingChain.lean
- [ ] `#print axioms buildDovetailingChainFamily_forward_F` shows no unexpected axioms
- [ ] `#print axioms buildDovetailingChainFamily_backward_P` shows no unexpected axioms
- [ ] Cross-sign propagation lemmas unchanged (grep for forward_G, backward_H)
- [ ] `dovetailFamily_theorem` compiles without modification
- [ ] Repository sorry count: `Theories/` sorries should decrease by 2

## Artifacts & Outputs

- `plans/implementation-003.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Final: `summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If omega^2 approach fails at any phase:
1. Preserve all work in a git branch `task-916-omega2-attempt`
2. Document the specific failure in handoff artifact
3. Consider alternative: ordinal-indexed chain (mentioned in research as fallback)
4. Do not delete working cross-sign proofs (forward_G, backward_H)

If context exhaustion occurs mid-phase:
1. Write handoff per standard protocol
2. Successor reads handoff and continues from checkpoint
3. Progress tracked in phase Progress subsection
