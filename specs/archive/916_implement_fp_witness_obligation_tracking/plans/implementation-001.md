# Implementation Plan: Task #916

- **Task**: 916 - Implement F/P witness obligation tracking to close DovetailingChain sorries
- **Status**: [BLOCKED]
- **Effort**: 8 hours
- **Dependencies**: None
- **Research Inputs**: specs/916_implement_fp_witness_obligation_tracking/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This implementation closes the 4 remaining sorries in `DovetailingChain.lean` by replacing the current split half-chain architecture with a unified interleaved construction. The current construction builds forward and backward chains independently, sharing only M_0. This causes two cross-sign propagation failures (sorries 1-2) and lacks F/P witness scheduling (sorries 3-4). The solution unifies both chains into a single step-indexed construction where each step looks up its neighbor from previously computed MCSes, and augments seeds with witness formulas via Cantor-pairing enumeration.

### Research Integration

From research-001.md:
- Precise sorry goal states identified at lines 606, 617, 633, 640
- Cross-sign failures root cause: independent half-chain Lindenbaum extensions
- F/P witness failures: Lindenbaum adds F(psi) without placing witness psi
- Key lemmas available: `temporal_witness_seed_consistent`, `past_temporal_witness_seed_consistent`, `dovetail_neighbor_constructed`
- Approach A (direct resolution) recommended: resolve F/P at immediate next step
- Mathlib infrastructure: `Nat.pair`/`Nat.unpair`, `Encodable.ofCountable`

## Goals & Non-Goals

**Goals**:
- Close all 4 sorries in `DovetailingChain.lean` (lines 606, 617, 633, 640)
- Maintain the existing API: `buildDovetailingChainFamily`, `temporal_coherent_family_exists_theorem`
- Keep `temporal_coherent_family_exists_theorem` as a THEOREM (not axiom)
- Use proven infrastructure: `dovetailIndex`/`dovetailRank`, consistency lemmas

**Non-Goals**:
- Changing the `BFMCS` structure itself
- Optimizing compilation time (noncomputable is acceptable)
- Full canonical model construction (only temporal chain)
- Generalizing beyond Int-indexed chains

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Unified chain lookup complexity | H | M | Use `dovetailRank` for O(1) time-to-step conversion; store MCSes in function table |
| F-obligation persistence across steps | H | M | Approach A: resolve at immediate next step; consistency via `temporal_witness_seed_consistent` |
| Multiple witnesses needed at same step | M | L | Cantor pairing guarantees all obligations eventually processed |
| Proof term size explosion | M | M | Keep proofs tactic-style; use helper lemmas |
| Dependent step access in recursion | H | M | Use well-founded recursion on Nat with decreasing step index for lookups |

## Sorry Characterization

### Pre-existing Sorries
- 4 sorries in `DovetailingChain.lean`:
  - Line 606: `forward_G` when `t < 0` (cross-sign forward propagation)
  - Line 617: `backward_H` when `t >= 0` (cross-sign backward propagation)
  - Line 633: `buildDovetailingChainFamily_forward_F` (F-witness existence)
  - Line 640: `buildDovetailingChainFamily_backward_P` (P-witness existence)

### Expected Resolution
- Phase 2 resolves sorries 1-2 via unified interleaved chain with neighbor lookup
- Phase 3 resolves sorries 3-4 via F/P witness scheduling with Cantor enumeration
- Phase 4 integrates and proves final coherence properties

### New Sorries
- None expected. The unified construction with witness scheduling should close all gaps.

### Remaining Debt
After this implementation:
- 0 sorries expected in `DovetailingChain.lean`
- `temporal_coherent_family_exists_theorem` becomes fully proven
- Downstream completeness theorem no longer inherits sorry debt from temporal chain

## Implementation Phases

### Phase 1-2: GContent/HContent Duality (Sorries 1-2) [COMPLETED]

- **Dependencies:** None
- **Goal:** Prove cross-sign propagation for `forward_G` and `backward_H` using duality lemmas

**Approach (revised from original plan):**
Instead of building a unified chain, we prove that the existing split chains have implicit cross-sign propagation via GContent/HContent duality: if `GContent(M) ⊆ M'` (by construction), then `HContent(M') ⊆ M` (by duality). This allows G to propagate backward toward M_0 and H to propagate forward toward M_0, enabling cross-sign bridging through the shared base.

**Tasks completed**:
- [x] Prove `past_temp_a`: derived φ → H(F(φ)) from temp_a via temporal duality
- [x] Prove `GContent_subset_implies_HContent_reverse`: if GContent(M) ⊆ M', then HContent(M') ⊆ M
- [x] Prove `HContent_subset_implies_GContent_reverse`: symmetric duality lemma
- [x] Prove `dovetailBackwardChainMCS_GContent_reverse`: G propagates toward 0 in backward chain
- [x] Prove `dovetailForwardChainMCS_HContent_reverse`: H propagates toward 0 in forward chain
- [x] Prove `dovetailBackwardChain_forward_G`: forward_G within backward chain (toward 0)
- [x] Prove `dovetailForwardChain_backward_H`: backward_H within forward chain (toward 0)
- [x] Prove `dovetailChainSet_forward_G_neg`: cross-sign forward_G for negative t
- [x] Prove `dovetailChainSet_backward_H_nonneg`: cross-sign backward_H for non-negative t
- [x] Update `buildDovetailingChainFamily.forward_G` and `backward_H` to use new lemmas

**Timing**: ~1.5 hours (faster than planned due to elegant duality approach)

**Files modified**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Added duality lemmas and cross-sign proofs

**Verification**:
- [x] Sorries at lines 606 and 617 eliminated (cross-sign propagation)
- [x] `lake build Bimodal.Metalogic.Bundle.DovetailingChain` succeeds
- [x] `forward_G` and `backward_H` fields fully proven without sorry

**Progress:**

**Session: 2026-02-20, sess_1771618766_cea3b9**
- Added: `past_temp_a` - derived past analog of temp_a axiom
- Added: `GContent_subset_implies_HContent_reverse`, `HContent_subset_implies_GContent_reverse` - duality lemmas
- Added: `dovetailBackwardChainMCS_GContent_reverse`, `dovetailForwardChainMCS_HContent_reverse` - cross-chain propagation
- Added: `dovetailBackwardChain_forward_G`, `dovetailForwardChain_backward_H` - single-chain cross-sign
- Added: `dovetailChainSet_forward_G_neg`, `dovetailChainSet_backward_H_nonneg` - Int-indexed cross-sign
- Fixed: `buildDovetailingChainFamily` forward_G and backward_H proofs
- Sorries: 4 -> 2 (2 eliminated: cross-sign forward_G and backward_H)

---

### Phase 3: F/P Witness Scheduling (Sorries 3-4) [BLOCKED]

- **Dependencies:** Phase 2
- **Goal:** Add F/P witness formula scheduling via Cantor-pairing enumeration, eliminating forward_F and backward_P sorries

**Tasks**:
- [ ] Import `Mathlib.Data.Nat.Pairing` for `Nat.pair`/`Nat.unpair`
- [ ] Import `Mathlib.Logic.Encodable.Basic` for formula encoding
- [ ] Define `decodeObligationPair : Nat -> Option (Int x Formula)` using `Nat.unpair` and `Encodable.decode`
- [ ] Define `witnessForStep : (step : Nat) -> (chain_so_far : Nat -> Set Formula) -> Option Formula`
  - Decode step to (time_enc, formula_enc)
  - Check if F(decoded_formula) is in chain at decoded_time
  - If time < current time being built, return decoded_formula
- [ ] Define `augmentedSeed : (step : Nat) -> (base_seed : Set Formula) -> (witness : Option Formula) -> Set Formula`
  - Union base_seed with witness if present
- [ ] Prove `augmentedSeed_consistent`: uses `temporal_witness_seed_consistent` when witness is from F-obligation, `past_temporal_witness_seed_consistent` when from P-obligation
- [ ] Modify `buildUnifiedChain` to use `augmentedSeed` instead of plain GContent/HContent seed
- [ ] Prove `unified_forward_F`:
  - Given F(psi) in M_t, need to find s > t with psi in M_s
  - Key: the pair (t, psi) is encoded as some natural number n via `Nat.pair`
  - At step `dovetailRank s` where s = dovetailIndex(step for witnessing), if decoded pair matches (t, psi), psi is added to seed
  - By surjectivity of `Nat.unpair`, all (time, formula) pairs eventually enumerated
- [ ] Prove `unified_backward_P`: symmetric argument for P-obligations using `past_temporal_witness_seed_consistent`
- [ ] Update `buildDovetailingChainFamily_forward_F` to use `unified_forward_F`
- [ ] Update `buildDovetailingChainFamily_backward_P` to use `unified_backward_P`

**Timing**: 2.5 hours (original estimate; blocked due to fundamental difficulty)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Add witness enumeration, augment seed

**Verification**:
- Sorries at lines 919 and 926 eliminated
- `lake build Bimodal.Metalogic.Bundle.DovetailingChain` succeeds
- `buildDovetailingChainFamily_forward_F` and `buildDovetailingChainFamily_backward_P` compile without sorry

**Progress:**

**Session: 2026-02-20, sess_1771626129_c718ce** (no progress on code; deep analysis completed)
- Attempted: Multiple approaches to close forward_F and backward_P sorries
- Result: BLOCKED - all approaches encounter a fundamental F-formula persistence problem

**Detailed Analysis of Blocker:**

The core problem: `F(psi) in M_t` does NOT guarantee `F(psi) in M_{t+1}` (F-formulas do not auto-propagate via GContent since `F(psi) -> G(F(psi))` is NOT derivable). Since the Lindenbaum extension is non-deterministic (via Zorn/Classical.choice), `G(neg psi)` can enter `M_{t+1}` even when `F(psi) in M_t`, permanently killing the F-obligation.

**Approaches Investigated:**

1. **Simple formula enumeration (one witness per step)**: At step n+1, add decode(n) to seed if F(decode(n)) in M_n. FAILS because F(psi) may vanish before psi's enumeration step k = encode(psi).

2. **Cantor pairing on (time, formula)**: Enumerate (s, psi) pairs, check F(psi) in M_s. FAILS because seed consistency requires F(psi) in M_{t-1} (immediate predecessor), not in M_s.

3. **Multi-witness seed (all F-witnesses at once)**: Add ALL {psi | F(psi) in M_n} to seed. FAILS because F(p) and F(neg p) can both be in M_n, but {p, neg p} is inconsistent.

4. **F-formula propagation in seed**: Include {F(chi) | F(chi) in M_n} in the seed for M_{n+1}. FGSeed(M) subset M is consistent. BUT adding a witness psi_n to FGSeed may be inconsistent: if G(psi_n -> G(neg chi)) in M_n, then {psi_n} union FGSeed(M_n) derives G(neg chi), contradicting F(chi).

5. **Prove persistence by contradiction**: Assume psi not in any M_s for s > m. Try to derive G(neg psi) in M_m from "neg psi at all future times". This is the temporal_backward_G property, which REQUIRES forward_F (circular).

6. **Subset-of-M argument**: FGSeed(M) = GContent(M) union {F(chi) | F(chi) in M} is subset of M, hence consistent. Adding one witness psi_n (via TemporalWitnessSeed) plus F-formulas may be inconsistent due to conditional G-formulas in GContent.

**Key Proven Facts:**
- `GContent(M) union {F(psi)}` IS consistent when F(psi) in M (since GContent(M) union {F(psi)} subset M)
- `{psi} union GContent(M)` IS consistent when F(psi) in M (`temporal_witness_seed_consistent`)
- `{psi} union GContent(M) union {F(chi)}` may be INCONSISTENT (counterexample: G(psi -> G(neg chi)) in M)
- Multi-witness `{psi_1,...,psi_k} union GContent(M)` may be INCONSISTENT (counterexample: F(p) and F(neg p) both in M)

**Resolution Paths (for future implementation):**

A. **Constructive formula-by-formula Lindenbaum**: Define Lindenbaum that processes formulas in a fixed order, ensuring F(chi) is processed BEFORE G(neg chi). With a metatheorem that non-G context formulas don't affect G-derivability, this guarantees F-persistence. ESTIMATED EFFORT: 15-20 hours (new Lindenbaum + metatheorem).

B. **Modified chain with priority witness scheduling**: At each step, resolve the OLDEST unresolved F-obligation. Use a constructive Lindenbaum to ensure no other F-obligations are killed. ESTIMATED EFFORT: 12-15 hours (requires path A infrastructure).

C. **Direct semantic argument**: Build a model directly from MCS properties without explicit chain construction. Use compactness or ultrafilter arguments. ESTIMATED EFFORT: 20+ hours (requires significant new infrastructure).

D. **Accept sorry debt**: Leave forward_F and backward_P as sorries. The temporal_coherent_family_exists_theorem is still a THEOREM (not axiom), just sorry-backed. The completeness proof flows through. EFFORT: 0 hours (status quo).

**Recommendation**: Path A is the most promising. The key new lemma needed is a "G-derivability independence" metatheorem: `{non-G-formulas} union GContent(M) |- G(alpha)` iff `GContent(M) |- G(alpha)`. This can likely be proven by induction on the derivation tree. Once this is established, the formula-by-formula Lindenbaum gives full control over F-persistence, and the proof of forward_F follows the standard textbook argument.

---

### Phase 4: Final Integration and Cleanup [BLOCKED]

- **Dependencies:** Phase 3
- **Goal:** Verify all sorries eliminated, clean up deprecated code, verify downstream theorems compile

**Tasks**:
- [ ] Run `grep -n "sorry" DovetailingChain.lean` to confirm 0 sorries remain
- [ ] Remove deprecated `dovetailForwardChainMCS` and `dovetailBackwardChainMCS` if no longer needed (or mark as deprecated)
- [ ] Remove deprecated lemmas for separate chains if superseded by unified chain lemmas
- [ ] Verify `temporal_coherent_family_exists_theorem` compiles without sorry
- [ ] Verify `TemporalCoherentConstruction.lean` compiles (depends on DovetailingChain)
- [ ] Run `lake build` on full project to catch any downstream breaks
- [ ] Run `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/*.lean` to check sorry count delta
- [ ] Add documentation comments to new unified chain definitions

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Cleanup and documentation

**Verification**:
- `lake build` succeeds with no errors
- Sorry count reduced by 4 in DovetailingChain.lean
- `#check Bimodal.Metalogic.Bundle.temporal_coherent_family_exists_theorem` shows no sorry warning

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.DovetailingChain` compiles without error
- [ ] `lake build` full project succeeds
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` returns 0
- [ ] `#print axioms temporal_coherent_family_exists_theorem` shows only standard axioms (propext, Classical.choice, Quot.sound)
- [ ] Verify via MCP `lean_verify` tool that theorem is sound

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (modified) - Unified chain with F/P witness scheduling
- `specs/916_implement_fp_witness_obligation_tracking/plans/implementation-001.md` (this file)
- `specs/916_implement_fp_witness_obligation_tracking/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the unified chain approach proves too complex:
1. Preserve existing split half-chain code (do not delete prematurely)
2. Partial progress: Phase 2 alone provides value (cross-sign fix) even without Phase 3
3. Alternative for Phase 3: Instead of full Cantor enumeration, try "direct resolution" where each MCS explicitly includes witnesses for F-formulas in its immediate predecessor
4. If Encodable issues arise with Formula, use direct induction on formula structure rather than abstract encoding
5. Git revert to pre-implementation state if fundamental design flaw discovered
