# Implementation Plan: Task #922 - Canonical Quotient Completeness Proof (v2)

- **Task**: 922 - strategy_study_fp_witness_completeness_blockers
- **Version**: 002
- **Created**: 2026-02-24
- **Status**: [PARTIAL]
- **Effort**: 16-24 hours (remaining: Phases 3-5)
- **Dependencies**: Task 923 (canonical_reachable_linear, COMPLETED 2026-02-24)
- **Research Inputs**: research-001.md, research-002.md, research-003.md (post-blocker analysis)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**v1 -> v2**: Phase 3 blocker (canonical_reachable_linear) resolved by task 923. This revision:
1. Updates Phase 3 with the definitive `orderIsoIntOfLinearSuccPredArch` approach from research-003
2. Preserves completed Phases 1-2 progress
3. Refines Phase 4 based on research-003's BFMCS construction analysis
4. Updates risks based on NoMaxOrder/NoMinOrder prerequisite identification

## Overview

This plan implements the **Canonical Quotient** approach for proving bimodal completeness with zero sorries. Phases 1-2 are COMPLETED. Phase 3's linearity blocker is now RESOLVED by task 923's proof of `canonical_reachable_linear`. The remaining work focuses on:
1. Embedding the reachable canonical fragment into Int via Mathlib's `orderIsoIntOfLinearSuccPredArch`
2. Constructing BFMCS Int using the OrderIso
3. Integrating with the completeness chain to eliminate sorries

### Research Integration

**From research-003** (post-blocker analysis):
- `canonical_reachable_linear` fully proven using compound-formula linearity with cross-propagation
- The definitive Int embedding path uses `orderIsoIntOfLinearSuccPredArch` (requires LinearOrder, SuccOrder, PredOrder, IsSuccArchimedean, NoMaxOrder, NoMinOrder, Nonempty)
- The strict-future-witness problem is solvable via OrderIso: canonical_forward_F gives witness at >= t, OrderIso guarantees distinct times map to distinct integers
- NoMaxOrder/NoMinOrder are key prerequisites requiring careful proof

## Goals & Non-Goals

**Goals**:
- Prove forward_F and backward_P for bimodal completeness with zero sorries
- Complete Phases 3-5 using the OrderIso approach
- Produce a sorry-free `fully_saturated_bmcs_exists_int` construction
- Achieve publication-quality completeness theorem

**Non-Goals**:
- Modify TruthLemma, BMCSTruth, or core Completeness modules
- Remove DovetailingChain sorries (they become dead code)
- Prove modal saturation constructively (existing axiom remains)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| NoMaxOrder proof difficulty | High | 25% | Use F(neg(q)) for q in M to guarantee strict successor; fallback to padding if needed |
| NoMinOrder proof difficulty | High | 25% | Symmetric to NoMaxOrder using P(neg(q)) |
| IsSuccArchimedean proof complexity | Medium | 30% | Follows from countability + linear order; alternative: direct enumeration |
| SuccOrder/PredOrder definition | Medium | 20% | Use well-founded linear order minimum for next element |
| TruthLemma all-family requirement | Medium | 30% | Audit TruthLemma; eval_family temporal coherence may suffice |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `DovetailingChain.lean`: `forward_F`, `backward_P` (become dead code)
- 1 sorry in `TemporalCoherentConstruction.lean`: `fully_saturated_bmcs_exists_int` (target)

### Expected Resolution
- Phase 4 replaces `fully_saturated_bmcs_exists_int` sorry with constructive proof
- DovetailingChain sorries become unreferenced (not in active dependency chain)
- Final sorry count in completeness chain: 0 (temporal components)

### New Sorries
- None permitted. Zero-sorry constraint is absolute.

---

## Implementation Phases

### Phase 1: Linearity Validation (Fail-Fast) [COMPLETED]

- **Dependencies:** None
- **Goal:** Determine whether the linearity schema is derivable from TM axioms.

**Progress:**

**Session: 2026-02-24, sess_1771960688_9a2e76**
- Added: `temp_linearity` axiom constructor to `Axiom` inductive type in `Axioms.lean`
- Added: `axiom_temp_linearity_valid` soundness proof in `SoundnessLemmas.lean`
- Added: `temp_linearity_valid` soundness proof in `Soundness.lean`
- Added: `axiom_swap_valid` case for `temp_linearity` in `SoundnessLemmas.lean`
- Added: `LinearityDerivedFacts.lean` with non-derivability analysis
- Completed: Phase 1 - linearity NOT derivable (3-point branching counterexample); temp_linearity axiom added
- Axioms: 16 -> 17

---

### Phase 2: Canonical Frame Definition [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Define the canonical frame structure and prove forward_F/backward_P are trivial.

**Progress:**

**Session: 2026-02-24, sess_1771960688_9a2e76 (iteration 2)**
- Added: `CanonicalFrame.lean` with canonical frame definitions
- Added: `CanonicalR`, `CanonicalR_past`, `canonical_forward_G`, `canonical_backward_H`
- Added: `canonical_forward_F`, `canonical_backward_P`
- Added: `canonicalR_reflexive`, `canonicalR_past_reflexive`, `canonicalR_transitive`
- Completed: All 4 temporal properties proven, zero sorries, build succeeds

---

### Phase 3: Int Embedding via OrderIso [PARTIAL]

- **Dependencies:** Phase 1, Phase 2, Task 923 (canonical_reachable_linear)
- **Goal:** Define the reachable canonical fragment as a type and construct OrderIso to Int.
- **Estimated Effort:** 8-12 hours

**Approach** (from research-003 definitive path):

The Mathlib theorem `orderIsoIntOfLinearSuccPredArch` provides an `OrderIso` between a type and Int, requiring:
- `LinearOrder` - from canonical_reachable_linear
- `SuccOrder`, `PredOrder` - natural successors via linear order minimum
- `IsSuccArchimedean` - from countability (finite intervals)
- `NoMaxOrder`, `NoMinOrder` - from F/P witness existence
- `Nonempty` - root MCS

**Tasks**:
1. [x] Define `CanonicalReachable M_0` as a subtype of `Set Formula` for MCSes reachable from root M_0
2. [ ] Define `CanonicalReachableOrder` with CanonicalR-induced ordering
3. [ ] Prove `LinearOrder CanonicalReachable` (from canonical_reachable_linear)
4. [ ] Prove `Countable CanonicalReachable` (Formula is Countable, MCS determined by theory)
5. [ ] Prove `NoMaxOrder CanonicalReachable`:
   - For any MCS M, find formula phi such that F(phi) in M and phi NOT in M
   - Apply canonical_forward_F to get strict successor
   - Key insight: use F(neg(q)) for any q in M (since G(neg(neg(q))) = G(q) may not be in M)
6. [ ] Prove `NoMinOrder CanonicalReachable` (symmetric using backward_P)
7. [ ] Define `SuccOrder`/`PredOrder` using linear order well-founded minimum
8. [ ] Prove `IsSuccArchimedean`:
   - Any two elements have finitely many elements between them
   - Follows from Countable + LinearOrder (countable intervals are finite)
9. [ ] Apply `orderIsoIntOfLinearSuccPredArch` to obtain `canonicalOrderIso : CanonicalReachable M_0 ≃o Int`
10. [ ] Define `canonicalMCS : Int -> Set Formula` via `canonicalOrderIso.symm`

**BLOCKER IDENTIFIED**: The CanonicalR relation is a total PREORDER (reflexive, transitive,
connected), NOT a total ORDER. Antisymmetry (CanonicalR M1 M2 ∧ CanonicalR M2 M1 → M1 = M2)
is unproven and may require quotienting by the mutual-CanonicalR equivalence. This blocks
tasks 2-9 which assume a LinearOrder. See handoff for detailed analysis.

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean` (new) - subtype definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` - add OrderIso construction

**Verification**:
- `canonicalOrderIso` constructed without sorry
- `canonicalMCS` function defined
- `lake build` succeeds

**Progress:**

**Session: 2026-02-24, sess_1771969092_eaf615**
- Added: `CanonicalReachable` structure with `world`, `is_mcs`, `reachable` fields
- Added: `CanonicalReachable.root` - root MCS is in the reachable fragment
- Added: `CanonicalReachable.ext` - extensional equality
- Added: `canonical_reachable_comparable` - any two elements are CanonicalR-comparable
- Added: `canonical_forward_F_strict` - F(phi) with phi absent gives distinct successor
- Added: `canonical_backward_P_strict` - P(phi) with phi absent gives distinct predecessor
- Added: `gcontent_eq_of_mutual_R` - mutually CanonicalR MCSes share GContent
- Added: `canonical_F_neg_from_not_G`, `canonical_F_from_not_G_neg`, `canonical_G_or_F_neg` - temporal duality helpers
- Added: `forward_G_at_future`, `forward_F_via_G` - BFMCS forward_G helpers
- Added: `CanonicalReachable.successor` - successors of reachable elements are reachable
- Added: `conj_neg_derives_bot` - phi ∧ neg(phi) derives bot
- Added: `F_conj_neg_not_in_mcs` - F(phi ∧ neg(phi)) not in any MCS
- Completed: CanonicalReachable.lean builds with zero sorries, zero errors
- Identified: CanonicalR antisymmetry blocker prevents LinearOrder instance

---

### Phase 4: BFMCS Int Construction [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Assemble BFMCS Int satisfying TemporalCoherentFamily interface.
- **Estimated Effort:** 4-6 hours

**Tasks**:
1. [ ] Define `canonicalBFMCS : (root : Set Formula) -> SetMaximalConsistent root -> BFMCS Int`
   - `mcs := canonicalMCS` from Phase 3
   - All positions are MCS (by construction from canonical frame)
2. [ ] Prove `forward_G` property:
   - If G(phi) in mcs(t) and t < s, then phi in mcs(s)
   - Use canonicalR_transitive + canonical_forward_G
3. [ ] Prove `backward_H` property (symmetric)
4. [ ] Prove `forward_F` property:
   - If F(phi) in mcs(t), then exists s > t with phi in mcs(s)
   - Apply canonical_forward_F to get witness W with CanonicalR(mcs(t), W)
   - W = mcs(s) for some s via OrderIso
   - If s > t: done. If s = t (W = mcs(t)): phi in mcs(t), use s = t+1 and padding argument
   - Key: OrderIso guarantees distinct canonical MCSes map to distinct integers
5. [ ] Prove `backward_P` property (symmetric)
6. [ ] Wire into `temporal_coherent_family_exists_Int`:
   - Replace sorry with `canonicalBFMCS` construction
   - Verify interface compatibility

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean` (new) - BFMCS construction
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - replace sorry

**Verification**:
- `canonicalBFMCS` satisfies BFMCS structure requirements
- `temporal_coherent_family_exists_Int` proven without sorry
- `lake build` succeeds

---

### Phase 5: Integration and Verification [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Verify full completeness proof works end-to-end with zero sorries.
- **Estimated Effort:** 2-4 hours

**Tasks**:
1. [ ] Run `lake build` and verify no errors
2. [ ] Verify `Completeness.lean` compiles with new BFMCS construction
3. [ ] Run `lean_verify` on completeness theorem to check axiom dependencies
4. [ ] Audit TruthLemma.lean for temporal coherence requirements:
   - Confirm eval_family temporal coherence suffices
   - Document if modal witness families need temporal coherence
5. [ ] Document remaining technical debt:
   - DovetailingChain sorries (inert, not in dependency chain)
   - Modal saturation axiom (separate concern)
6. [ ] Update proof architecture documentation if needed

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - verify compiles
- `docs/` - update architecture if needed

**Verification**:
- `lake build` succeeds with 0 errors
- Completeness theorem proven without sorries in active dependency chain
- `lean_verify` shows expected axiom dependencies (temp_linearity, saturated_extension_exists)

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase completion
- [ ] No sorries introduced in new files
- [ ] `Completeness.lean` compiles and works with new BFMCS construction
- [ ] `lean_verify` on completeness theorem shows clean axiom dependencies
- [ ] forward_F/backward_P are proven (not sorry'd) in final construction

## Artifacts & Outputs

- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` (Phase 1, DONE)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (Phase 2, DONE)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` (Phase 2-3, partial)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean` (Phase 3, new)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean` (Phase 4, new)
- `specs/922_strategy_study_fp_witness_completeness_blockers/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

1. **Phase 3 NoMaxOrder/NoMinOrder failure**: Use OrderEmbedding instead of OrderIso; pad Int range with copies of boundary MCSes

2. **Phase 3 IsSuccArchimedean failure**: Construct enumeration manually using countability (back-and-forth argument)

3. **Phase 4 strict-future-witness failure**: If OrderIso approach fails, consider generalizing BFMCS to accept non-Int ordered type (significant refactor)

4. **Phase 5 TruthLemma all-family requirement**: Restructure proof or prove constant families satisfy temporal coherence for temporally-saturated base MCSes

## Critical Success Factors

1. **NoMaxOrder/NoMinOrder proofs must succeed**: These are prerequisites for `orderIsoIntOfLinearSuccPredArch`. Allocated special attention in Phase 3.

2. **Zero sorries in new code**: Absolute constraint. Every phase produces sorry-free Lean code.

3. **OrderIso preserves temporal semantics**: The key correctness requirement is that canonical_forward_F witnesses map to strictly greater integers when W != mcs(t).

4. **Preserve existing interface**: TemporalCoherentFamily interface unchanged. Only internal construction changes.
