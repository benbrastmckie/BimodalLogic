# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [PARTIAL]
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

### Phase 1: Define Omega^2 Chain Structure [COMPLETED]

- **Dependencies:** None
- **Goal:** Create the inner chain and outer chain definitions that enable witness placement in seeds

**Tasks**:
- [x] Define `witnessForwardChainMCS` - forward witness chain processing one F-formula per step
  - Step 0: Lindenbaum(base)
  - Step n+1: if decodeFormula(n) = some psi and F(psi) in chain(n), extend {psi} union GContent(chain(n)); else extend GContent(chain(n))
- [x] Define `witnessBackwardChainMCS` - symmetric backward witness chain for P-formulas
- [x] Prove consistency: `witnessForwardChainMCS_is_mcs` and `witnessBackwardChainMCS_is_mcs`
- [x] Set up formula enumeration using `Encodable.ofCountable` (`formulaEncodable`, `decodeFormula`, `encodeFormula`)
- [x] Prove `decodeFormula_encodeFormula` - surjectivity of the encoding
- [x] Prove GContent/HContent extension lemmas
- [x] Prove witness placement lemmas (key property for coverage argument)
- [x] Prove forward_G and backward_H coherence for witness chains
- [x] Prove cross-direction duality (GContent reverse, HContent reverse)
- [x] Define `ForwardTemporalWitnessSeed` and prove `forward_temporal_witness_seed_consistent` (to avoid circular import with TemporalCoherentConstruction.lean)

**Design Note**: The plan originally specified an `innerChainMCS`/`outerChain` two-level structure with Zorn limits. After analysis, a simpler flat omega-indexed chain (`witnessForwardChainMCS`) was adopted instead. Each step processes one formula via the Encodable enumeration, witnessing it if the F-obligation is present. This avoids the mutual recursion between inner and outer chains and the limit construction complexity. The `Nat.pairEquiv` bijection for omega^2 indexing was not needed since the flat chain naturally processes all formulas via the encoding surjectivity.

**Timing**: 10-15 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - add witness chain definitions

**Verification**:
- `lake build` succeeds (verified)
- New definitions type-check (verified)
- All 22 new lemmas/definitions compile without sorry

**Progress:**

**Session: 2026-02-20, sess_1771634621_f7a06b**
- Added: `formulaEncodable` - Encodable instance for Formula
- Added: `decodeFormula`, `encodeFormula` - formula enumeration functions
- Added: `decodeFormula_encodeFormula` - encoding surjectivity
- Added: `ForwardTemporalWitnessSeed` - forward analog of PastTemporalWitnessSeed
- Added: `forward_temporal_witness_seed_consistent` - consistency of forward witness seed
- Added: `witnessForwardChainMCS` - forward witness chain construction
- Added: `witnessBackwardChainMCS` - backward witness chain construction
- Added: 15 supporting lemmas (MCS, extension, witness placement, G/H coherence, duality)
- Completed: Phase 1 objectives (all definitions and basic properties)
- Sorries: 2 -> 2 (0 eliminated, 0 introduced - existing forward_F/backward_P sorries remain for Phase 3/5)

---

### Phase 2: Prove Inner Chain Properties [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Establish key lemmas about the inner chain behavior

**Tasks**:
- [x] Prove `witnessForwardChain_coverage` / `witnessBackwardChain_coverage`: witnessed formula psi enters MCS at encoding step + 1
- [x] Prove F-persistence and dichotomy lemmas: `witnessForwardChain_F_dichotomy`, `witnessForwardChain_F_persists_if_not_killed`, `witnessForwardChain_F_implies_G_neg_absent`
  - Key insight: F(psi) persists unless G(neg(psi)) enters; once G(neg(psi)) enters, it persists forever (4-axiom + GContent). Contrapositive: if F(psi) ∈ chain(n), then G(neg(psi)) was absent at ALL steps m ≤ n.
- [x] Prove `witnessForwardChainMCS_GContent_extends_le` / `witnessBackwardChainMCS_HContent_extends_le`: GContent/HContent monotone through multiple steps
- [x] Prove `witnessForwardChainMCS_extends_base_GContent` / `witnessBackwardChainMCS_extends_base_HContent`: each chain step extends base GContent/HContent
- [x] Prove `witnessForwardChain_coverage_of_le` / `witnessBackwardChain_coverage_of_le`: KEY LEMMA - if F(psi) ∈ chain(n) and encodeFormula(psi) ≤ n, then psi ∈ chain(encodeFormula(psi)+1)

**Design Note**: The plan originally specified `innerChain_F_persists` as a lemma showing F(psi) unconditionally persists. Analysis revealed `F(psi) → G(F(psi))` is NOT derivable in TM logic, so unconditional F-persistence is not provable. Instead, we proved the stronger `coverage_of_le` lemma which combines the contrapositive of G-persistence with the coverage argument: if F(psi) is still alive at step n, it MUST have been alive at all earlier steps (including the encoding index), so the witness fires. This is strictly more useful than unconditional F-persistence for Phase 3.

**Timing**: 8-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - add lemmas

**Verification**:
- All 18 new lemmas compile without sorry (verified via `lake build`)
- `witnessForwardChain_coverage_of_le` is the critical milestone for Phase 3

**Progress:**

**Session: 2026-02-20, sess_1771634621_f7a06b**
- Added: `witnessForwardChainMCS_GContent_extends_le` - multi-step GContent monotonicity (forward)
- Added: `witnessBackwardChainMCS_HContent_extends_le` - multi-step HContent monotonicity (backward)
- Added: `witnessForwardChain_coverage` + `witnessBackwardChain_coverage` - encoding-step coverage
- Added: `witnessForwardChainMCS_extends_base_GContent` + `witnessBackwardChainMCS_extends_base_HContent` - base extension
- Added: `witnessForwardChain_F_dichotomy` + `witnessBackwardChain_P_dichotomy` - F/P dichotomy via MCS completeness
- Added: `witnessForwardChain_G_neg_persists` + `witnessBackwardChain_H_neg_persists` - G(neg)/H(neg) persistence
- Added: `witnessForwardChain_F_persists_if_not_killed` + `witnessBackwardChain_P_persists_if_not_killed` - conditional F/P persistence
- Added: `witnessForwardChain_F_persists` + `witnessBackwardChain_P_persists` - F/P persistence with initial condition
- Added: `witnessForwardChain_F_implies_G_neg_absent` + `witnessBackwardChain_P_implies_H_neg_absent` - contrapositive of G/H persistence
- Added: `witnessForwardChain_coverage_of_le` + `witnessBackwardChain_coverage_of_le` - coverage with persistence (KEY lemma)
- Completed: Phase 2 objectives (18 lemmas, all sorry-free)
- Sorries: 2 -> 2 (0 eliminated, 0 introduced - existing forward_F/backward_P sorries remain for Phase 3/5)

---

### Phase 3: Prove Coverage Argument (forward_F) [PARTIAL]

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

**Progress:**

**Session: 2026-02-20, sess_1771634621_f7a06b** (partial)
- Refactored: `dovetailForwardChainMCS` to include witness placement (matches `witnessForwardChainMCS` body)
- Refactored: `dovetailBackwardChainMCS` to include witness placement (matches `witnessBackwardChainMCS` body)
- Refactored: `witnessForwardChainMCS`/`witnessBackwardChainMCS` as aliases for dovetail chains
- Moved: formula enumeration definitions before chain definitions (required for witness placement)
- Fixed: all proofs that unfold chain definitions (GContent_extends, HContent_extends, witness_placed, zero_extends)
- Verified: `lake build` succeeds with same 2 sorries as before
- Attempted: Direct proof of forward_F using coverage_of_le
- Result: BLOCKED - flat chain construction is mathematically insufficient for forward_F
- Analysis: The flat chain processes each formula exactly once (at step encodeFormula(psi)+1). When encodeFormula(psi) < t, psi is placed at a step before t and does not persist. When encodeFormula(psi) > t, F(psi) may not persist to step encodeFormula(psi) because G(neg(psi)) can enter via GContent at any intermediate step.
- Handoff: specs/916_implement_fp_witness_obligation_tracking/handoffs/phase-3-handoff-20260220.md
- Sorries: 2 -> 2 (0 eliminated)

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
