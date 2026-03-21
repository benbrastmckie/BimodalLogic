# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P Witness Obligation Tracking
- **Status**: [PARTIAL]
- **Effort**: 35 hours (optimistic: 28h, pessimistic: 45h)
- **Dependencies**: None
- **Research Inputs**: specs/916_implement_fp_witness_obligation_tracking/reports/research-004.md (Phase 3 obstruction analysis)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Close the 2 remaining sorries in DovetailingChain.lean (forward_F and backward_P) using an omega^2 directed limit construction. This plan supersedes v003, which was blocked by a fundamental mathematical obstruction: the flat omega-indexed chain cannot guarantee F(psi) persists to its processing step because G(neg(psi)) can enter via Lindenbaum at any intermediate step. The omega^2 construction resolves this by running a full inner chain at each outer step, checking F-obligations against the outer MCS (where they are guaranteed present), and taking a directed limit of GContents.

### Research Integration

Key findings from research-004.md integrated into this plan:

1. **Flat chain obstruction confirmed**: F(psi) at step n may be killed by G(neg(psi)) entering at step n+1 before F(psi)'s processing step (Section 2.1-2.4)
2. **G(G(neg(psi))) and F(psi) can coexist**: In TM logic, these are consistent - G(neg(psi)) can enter via GContent without contradicting F(psi) (Section 1.3)
3. **F(psi) -> G(F(psi)) is NOT derivable**: F-formulas do not self-persist; no logical guarantee they reach their processing step (Section 1.3)
4. **Omega^2 inner chain is the solution**: Check F(psi) against OUTER MCS (where it is given), not inner predecessor (Section 5.6)
5. **Key new lemma needed**: "Directed union of GContents from inner chain is consistent" (Section 3.2)
6. **Existing 40+ lemmas reusable**: forward_temporal_witness_seed_consistent, coverage lemmas, cross-sign proofs all transfer (Section 7)

### Prior Work Preserved

Phases 1-2 of v003 are COMPLETED and contribute 40+ lemmas:
- `formulaEncodable`, `decodeFormula`, `encodeFormula`, `decodeFormula_encodeFormula`
- `ForwardTemporalWitnessSeed`, `forward_temporal_witness_seed_consistent`
- `witnessForwardChainMCS`, `witnessBackwardChainMCS`
- `witnessForwardChain_coverage_of_le`, `witnessBackwardChain_coverage_of_le`
- 15+ supporting lemmas for GContent extension, witness placement, G/H coherence, duality

## Goals & Non-Goals

**Goals**:
- Eliminate both remaining sorries in DovetailingChain.lean (forward_F, backward_P)
- Implement omega^2 inner chain with outer-MCS F-check pattern
- Prove directed consistency of inner chain GContent union
- Maintain compatibility with existing cross-sign propagation proofs (600+ lines)
- Reuse all 40+ Phase 1-2 lemmas from v003

**Non-Goals**:
- Modifying the BFMCS interface
- Restructuring downstream completeness theorems
- Implementing constructive Lindenbaum (boneyard approach - ruled out)
- Proving unconditional F-persistence (mathematically impossible)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Directed consistency lemma fails | HIGH | LOW | Proof sketch provided in research-004 Section 3.3; GContent is closed under derivation |
| Inner chain F-check against outer MCS breaks consistency | HIGH | LOW | Use generalized_forward_temporal_witness_seed_consistent with GContent subset condition |
| Limit MCS does not contain all witnesses | HIGH | MEDIUM | Prove witnesses enter GContent via 4-axiom; GContent propagates through limit |
| Context exhaustion during Phase 1-2 | MEDIUM | MEDIUM | Phases sized at 2-3h; handoff protocol in place |
| Downstream theorem breakage | LOW | LOW | Cross-sign proofs depend only on GContent extension; run `lake build` after each phase |

## Sorry Characterization

### Pre-existing Sorries
- `buildDovetailingChainFamily_forward_F` at line ~919 (forward_F sorry)
- `buildDovetailingChainFamily_backward_P` at line ~926 (backward_P sorry)

### Expected Resolution
- Phase 2 defines the omega^2 construction with directed limits
- Phase 3 proves forward_F using the construction
- Phase 4 proves backward_P symmetrically

### New Sorries
- None expected. The omega^2 approach is mathematically sound per research-004.

### Remaining Debt
After this implementation:
- 0 sorries expected in forward_F and backward_P
- All auxiliary lemmas should be sorry-free

## Axiom Characterization

### Pre-existing Axioms
- No axioms introduced by v003 Phases 1-2
- Task 916 targets sorry elimination, not axiom use

### Expected Resolution
- No axioms needed for omega^2 construction
- Directed consistency uses standard derivation closure of MCS

### New Axioms
- None. NEVER introduce axioms. All proofs use structural arguments.

### Remaining Debt
- No axiom debt from this task

## Implementation Phases

### Phase 1: Generalized Witness Seed Consistency [BLOCKED]

- **Dependencies:** None
- **Goal:** Prove the key lemma enabling F-check against outer MCS while placing witness in inner chain

**Tasks**:
- [ ] Prove `generalized_forward_temporal_witness_seed_consistent`:
  - Statement: If M and N are MCSes, `GContent(M) subset N`, and `F(psi) in M`, then `{psi} union GContent(N)` is consistent
  - Proof approach: From contradiction hypothesis, derive G(neg(psi)) in N via closure. Use T-axiom to get neg(psi) in N. Then show G(G(neg(psi))) NOT in M (contrapositive of T-axiom with F(psi) in M), hence G(neg(psi)) NOT in GContent(M). But G(neg(psi)) in N and G persists through GContent chain...
  - Alternative: Use the fact that if {psi} union GContent(N) is inconsistent, then G(neg(psi)) in N. But we're checking F(psi) in M (outer), not N (inner). Need to connect back via HContent duality.
- [ ] If direct proof fails, implement `F_preserving_seed`:
  - Definition: `{psi} union GContent(M) union {F(chi) : F(chi) in M, chi != psi}`
  - Prove this is consistent when F(psi) in M
  - Use this as inner chain seed instead of just `{psi} union GContent(innerChain(M, k))`
- [ ] Prove symmetric lemma for past direction: `generalized_past_temporal_witness_seed_consistent`

**Timing**: 3-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - add generalized consistency lemmas

**Verification**:
- `lake build` succeeds
- Lemma type-checks with no sorry
- Test: apply lemma to a simple case to verify it's usable

**Progress:**

**Session: 2026-02-20, sess_1771647336_8d3c43** (no progress - hard blocker)
- Attempted: Prove `generalized_forward_temporal_witness_seed_consistent`
- Result: **Lemma is mathematically false.** Independent analysis confirmed research-004 Section 3.3 finding (line 611).
- Counterexample construction: Given MCS M with `F(psi) in M` and `GContent(M) subset N`, the MCS N (built by Lindenbaum extension of GContent(M)) can contain `G(neg(psi))`. Then `neg(psi) in GContent(N)`, making `{psi} union GContent(N)` trivially inconsistent (contains both psi and neg(psi)). The key issue: `F(psi) in M` only prevents `G(neg(psi)) in M`, not `G(neg(psi)) in N`.
- This blocks ALL subsequent phases (2-5) since the omega^2 construction depends on this lemma.
- Research-004 itself identifies this at Section 3.3: "The generalized lemma does NOT hold as stated."
- No changes committed.

---

### Phase 2: Define Omega^2 Inner Chain with Directed Limit [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Define the inner chain that processes ALL formulas at each outer step, with limit via directed GContent union

**Tasks**:
- [ ] Define `omega2InnerChainMCS`:
  ```lean
  omega2InnerChainMCS (M : {S // SetMaximalConsistent S}) (k : Nat) :
      {S // SetMaximalConsistent S}
  | 0 => Lindenbaum(GContent(M.val))
  | k+1 =>
    let psi_k = decodeFormula(k)
    match psi_k with
    | none => Lindenbaum(GContent(omega2InnerChainMCS M k))
    | some psi =>
      if F(psi) in M.val then  -- CHECK AGAINST OUTER M
        Lindenbaum({psi} union GContent(omega2InnerChainMCS M k))
      else
        Lindenbaum(GContent(omega2InnerChainMCS M k))
  ```
- [ ] Prove `omega2InnerChain_is_mcs`: each step is an MCS
- [ ] Prove `omega2InnerChain_GContent_extends`: GContent(innerChain(k)) subset innerChain(k+1)
- [ ] Prove `omega2InnerChain_GContent_monotone`: k1 <= k2 implies GContent(innerChain(k1)) subset innerChain(k2)
- [ ] Define `omega2InnerChainGContentUnion`:
  ```lean
  omega2InnerChainGContentUnion (M : {S // SetMaximalConsistent S}) :=
    { phi | exists k, phi in GContent(omega2InnerChainMCS M k) }
  ```
- [ ] Prove `omega2InnerChainGContentUnion_consistent`:
  - Key lemma: the union forms a directed system under subset
  - Use derivation closure: if L subset union derives bot, then L is finite, hence L subset GContent(innerChain(k)) for some k, contradicting MCS consistency
- [ ] Define `omega2InnerChainLimit`:
  ```lean
  omega2InnerChainLimit (M : {S // SetMaximalConsistent S}) :=
    Lindenbaum(omega2InnerChainGContentUnion M)
  ```
- [ ] Prove `omega2InnerChainLimit_is_mcs`
- [ ] Prove `omega2InnerChainLimit_extends_GContent`: GContent(M) subset omega2InnerChainLimit(M)
- [ ] Symmetric definitions for backward direction using HContent and P-formulas

**Timing**: 6-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - add omega^2 definitions

**Verification**:
- `lake build` succeeds
- All definitions type-check
- No sorry in any definition or lemma
- Test: compute omega2InnerChainLimit on a trivial base case

---

### Phase 3: Prove Inner Chain Coverage and forward_F [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove that F(psi) in M implies psi in the limit, then close forward_F sorry

**Tasks**:
- [ ] Prove `omega2InnerChain_witness_placed`:
  - Statement: If F(psi) in M, then psi in omega2InnerChainMCS(M, encodeFormula(psi) + 1)
  - Proof: At step encodeFormula(psi)+1, the chain checks F(psi) in M (outer), which is true. Seed includes {psi}. Lindenbaum extension contains psi.
- [ ] Prove `omega2InnerChain_witness_in_GContent`:
  - Statement: If psi in innerChain(k), then G(psi) in innerChain(k') for some k' > k (via 4-axiom propagation)
  - Alternative: Show psi enters GContent via different path if needed
- [ ] Prove `omega2InnerChainLimit_contains_witnesses`:
  - Statement: If F(psi) in M, then psi in omega2InnerChainLimit(M)
  - Proof: psi in innerChain(encodeFormula(psi)+1). By 4-axiom, G(psi) in innerChain(...). Hence psi in GContentUnion. Lindenbaum preserves it.
  - Alternative: Direct argument that innerChain(k) subset limit for all k via GContent propagation
- [ ] Define `omega2OuterChainMCS`:
  ```lean
  omega2OuterChainMCS (base : Set Formula) (h : SetConsistent base) : Nat -> {S // SetMaximalConsistent S}
  | 0 => Lindenbaum(base)
  | n+1 => omega2InnerChainLimit(omega2OuterChainMCS base h n)
  ```
- [ ] Prove `omega2OuterChain_forward_F`:
  - Statement: If F(psi) in omega2OuterChainMCS(n), then exists m > n, psi in omega2OuterChainMCS(m)
  - Proof: Take m = n+1. By definition, omega2OuterChainMCS(n+1) = omega2InnerChainLimit(omega2OuterChainMCS(n)). By `omega2InnerChainLimit_contains_witnesses`, psi in limit.
- [ ] Refactor `buildDovetailingChainFamily` to use omega2OuterChainMCS for forward direction
- [ ] Replace sorry at forward_F with proof using `omega2OuterChain_forward_F`
- [ ] Verify `buildDovetailingChainFamily_forward_F` compiles without sorry

**Timing**: 8-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - prove forward_F

**Verification**:
- forward_F sorry eliminated
- `lake build` succeeds
- `#print axioms buildDovetailingChainFamily_forward_F` shows no unexpected axioms

---

### Phase 4: Prove backward_P (Symmetric Construction) [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove backward_P using symmetric omega^2 construction for past direction

**Tasks**:
- [ ] Define `omega2InnerChainMCS_past` - mirror using HContent and P-check
- [ ] Define `omega2InnerChainHContentUnion_past` - union of HContents
- [ ] Prove `omega2InnerChainHContentUnion_consistent_past`
- [ ] Define `omega2InnerChainLimit_past`
- [ ] Prove `omega2InnerChain_past_witness_placed`: If P(psi) in M, then psi in inner chain at encoding step
- [ ] Prove `omega2InnerChainLimit_past_contains_witnesses`
- [ ] Define `omega2OuterChainMCS_past` using HContent limits for backward direction
- [ ] Prove `omega2OuterChain_backward_P`:
  - Statement: If P(psi) in omega2OuterChainMCS_past(n), then exists m > n, psi in omega2OuterChainMCS_past(m)
- [ ] Refactor `buildDovetailingChainFamily` to use omega2OuterChainMCS_past for backward direction
- [ ] Replace sorry at backward_P with proof
- [ ] Verify `buildDovetailingChainFamily_backward_P` compiles without sorry

**Timing**: 6-8 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - prove backward_P

**Verification**:
- backward_P sorry eliminated
- `lake build` succeeds
- Both forward_F and backward_P sorries resolved
- `#print axioms buildDovetailingChainFamily_backward_P` shows no unexpected axioms

---

### Phase 5: Integration and Cross-Sign Verification [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Verify omega^2 construction integrates with existing BFMCS infrastructure

**Tasks**:
- [ ] Verify `buildDovetailingChainFamily` forward_G still holds with omega^2 outer chain
- [ ] Verify `buildDovetailingChainFamily` backward_H still holds with omega^2 outer chain
- [ ] Verify cross-sign propagation lemmas (GContent_subset_implies_HContent_reverse, etc.) still work
- [ ] Verify `dovetailFamily_theorem` compiles without modification
- [ ] Run full `lake build` to catch any regressions
- [ ] Create implementation summary

**Timing**: 3-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - verify integration
- `specs/916_implement_fp_witness_obligation_tracking/summaries/implementation-summary-{DATE}.md` - create summary

**Verification**:
- Full `lake build` succeeds
- No new sorries introduced
- Repository sorry count decreased by 2
- `#print axioms dovetailFamily_theorem` shows expected dependencies

---

## Testing & Validation

- [ ] `lake build` succeeds with zero new sorries in DovetailingChain.lean
- [ ] `#print axioms buildDovetailingChainFamily_forward_F` shows no unexpected axioms
- [ ] `#print axioms buildDovetailingChainFamily_backward_P` shows no unexpected axioms
- [ ] `#print axioms omega2OuterChain_forward_F` shows only standard axioms (propext, Quot.sound, Classical.choice)
- [ ] Cross-sign propagation lemmas unchanged (grep for forward_G, backward_H)
- [ ] `dovetailFamily_theorem` compiles without modification
- [ ] Repository sorry count: `Theories/` sorries should decrease by 2

## Artifacts & Outputs

- `plans/implementation-004.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Final: `summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If omega^2 directed limit approach fails:
1. Preserve all work in a git branch `task-916-omega2-directed-limit-attempt`
2. Document the specific failure in handoff artifact
3. Consider Option 2 from research-004: Accept sorry debt (document obstruction precisely)
4. Do not delete working cross-sign proofs (forward_G, backward_H)

If Phase 1 generalized consistency lemma fails:
1. Try F-preserving seed approach (include all F-formulas in seed)
2. If that fails, document specific counterexample
3. May need ordinal-indexed chain as ultimate fallback

If context exhaustion occurs mid-phase:
1. Write handoff per standard protocol
2. Successor reads handoff and continues from checkpoint
3. Progress tracked in phase Progress subsection

## Reuse of Existing v003 Phase 1-2 Lemmas

The following 40+ lemmas from v003 Phases 1-2 transfer directly to the omega^2 construction:

| Existing Lemma | Reuse in Omega^2 |
|----------------|------------------|
| `forward_temporal_witness_seed_consistent` | Used for inner chain step consistency |
| `past_temporal_witness_seed_consistent` | Used for backward inner chain |
| `dovetail_GContent_consistent` | Used for inner chain base step |
| `GContent_subset_implies_HContent_reverse` | Used for cross-sign propagation |
| `HContent_subset_implies_GContent_reverse` | Used for cross-sign propagation |
| `formulaEncodable` | Used for inner chain formula enumeration |
| `decodeFormula_encodeFormula` | Used for coverage argument |
| `witnessForwardChain_coverage` | Pattern adapted for inner chain |
| `witnessForwardChain_F_dichotomy` | Used within inner chain MCSes |
| `witnessForwardChain_G_neg_persists` | Used for G-persistence in inner chain |
| All cross-sign G/H proofs (600+ lines) | Unchanged - depend only on GContent extension |
