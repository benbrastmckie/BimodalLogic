# Implementation Plan: Task #55 (Revised v2)

- **Task**: 55 - Prove SuccChain Temporal Coherence Directly
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None (supersedes tasks 36, 37, 53)
- **Research Inputs**: reports/01_temporal-coherence-direct.md, reports/02_team-research.md, reports/02_teammate-a-findings.md, reports/02_teammate-b-findings.md, reports/02_teammate-c-findings.md
- **Artifacts**: plans/02_algebraic-temporal-coherence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Supersedes**: plans/01_temporal-coherence-implementation.md (restriction-based approach, HIGH RISK)

## Overview

Replace the sorry chain (`f_nesting_is_bounded` -> `f_nesting_boundary` -> `succ_chain_forward_F` -> `SuccChainTemporalCoherent`) with a direct algebraic proof using the **temporal theory witness** pattern. This approach adapts the proven `box_theory_witness_consistent` template from UltrafilterChain.lean to temporal operators G/H, proving temporal coherence existentially via Lindenbaum extension rather than constructively via F-iteration counting. The restriction-based approach from plan v1 is abandoned per unanimous team research recommendation (3 researchers, all HIGH confidence).

### Research Integration

- **Team synthesis (02_team-research.md)**: All 3 teammates converge on abandoning restriction-based approach; recommend temporal theory witness pattern
- **Teammate A**: Identified `box_theory_witness_consistent` (UltrafilterChain.lean:795-901) as the exact template; estimated ~180 lines new code
- **Teammate B**: Task 48 retrospective shows 15 failed plan versions for restriction approach; algebraic bypass was the breakthrough
- **Teammate C**: Risk matrix confirms 4 boundary sorries (lines 3072, 3104, 3118, 3189) are structurally unresolvable via restriction
- **Key axioms**: TF (`Box(phi) -> G(Box(phi))`), temp_future/modal_future, S5 structure

### Why This Supersedes Plan v1

Plan v1 attempted to fix boundary sorries in `DeferralRestrictedMCS` by proving `GG(neg(psi))` in `deferralClosure` when `FF(psi)` is. Task 48's 15-version history demonstrated this approach is fundamentally flawed: the closure boundary problem recurs at every level, and `restricted_single_step_forcing` is mathematically FALSE for boundary cases (see SuccChainFMCS.lean:3985-3986).

## Goals & Non-Goals

**Goals**:
- Define `G_theory(M)` and `H_theory(M)` analogous to `box_theory(M)`
- Prove `G_theory_witness_consistent`: `{phi} union G_theory(M)` is consistent when `F(phi) in M`
- Prove `H_theory_witness_consistent`: `{phi} union H_theory(M)` is consistent when `P(phi) in M`
- Extend to MCS witnesses via Lindenbaum (`temporal_theory_witness_exists`)
- Rewire `succ_chain_forward_F` and `succ_chain_backward_P` to use temporal witnesses
- Remove/deprecate false theorems: `f_nesting_is_bounded`, `p_nesting_is_bounded`

**Non-Goals**:
- Proving `f_nesting_is_bounded` for arbitrary MCS (mathematically impossible)
- Fixing boundary sorries in `DeferralRestrictedMCS` (abandoned approach)
- Restructuring the BFMCS/completeness architecture (already working via task 48)
- Modifying the Succ relation definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| G_theory_witness_consistent proof requires axioms beyond TF/temp_4 | Medium | Low | The box analog uses S5 negative introspection; temporal analog needs temp_4 (G -> GG) which is available as `Axiom.temp_4` |
| The "G-boxing" step (analogous to Box-lifting) fails for G operator | Medium | Low | G has K-distribution (`Axiom.temp_k_dist`) and necessitation (temporal_necessitation), same structure as Box |
| Rewiring `succ_chain_forward_F` changes the witness structure | Low | Medium | The new witness is an MCS from Lindenbaum extension; it satisfies the same existential `exists m > n, phi in mcs m` by constructing a new SuccChain from the witness |
| Past direction (H_theory) has different axiom structure | Low | Low | Structure is symmetric; `temp_a` (phi -> GP(phi)) and past-direction axioms mirror future |

## Implementation Phases

### Phase 1: Define Temporal Theory and Prove Witness Consistency [NOT STARTED]

**Goal**: Define `G_theory(M)` analogous to `box_theory(M)` and prove `{phi} union G_theory(M)` is consistent when `F(phi) in M`.

**Tasks**:
- [ ] Define `G_theory (M : Set Formula) : Set Formula` as `{G(a) | G(a) in M} union {neg(G(a)) | G(a) not in M}` (exact parallel to `box_theory`)
- [ ] Prove `G_theory_subset_mcs`: all elements of `G_theory(M)` are in M when M is MCS (uses negation completeness)
- [ ] Prove `G_box_of_G_theory`: for all `x in G_theory(M)`, `G(x) in M` (the "G-boxing" property)
  - For `G(a) in G_theory`: need `G(G(a)) in M`, follows from `Axiom.temp_4` (G(a) -> G(G(a)))
  - For `neg(G(a)) in G_theory`: need `G(neg(G(a))) in M`, follows from temporal 5-like principle. Key question: does the system have `neg(G(a)) -> G(neg(G(a)))`? This follows from `neg(G(a)) = F(neg(a))` and `F(neg(a)) -> G(F(neg(a)))` which is NOT a standard axiom. Alternative: use the seriality/linearity axioms to derive this, or restructure the seed differently.
  - **CRITICAL CHECK**: Verify whether temporal negative introspection holds. If not, restructure the G_theory definition to only include the positive part `{G(a) | G(a) in M}` and use a different argument for the witness.
- [ ] Prove `G_theory_witness_consistent`: If `F(phi) in M` (MCS), then `{phi} union G_theory(M)` is consistent
  - Proof follows `box_theory_witness_consistent` template: assume inconsistency, apply deduction theorem to get derivation of neg(phi) from G_theory context, G-lift to get G(neg(phi)) in M, contradict F(phi) = neg(G(neg(phi))) in M
- [ ] Define `H_theory` symmetrically and prove `H_theory_witness_consistent` for P(phi)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add temporal theory definitions and witness consistency proofs (alongside existing `box_theory`)

**Verification**:
- `lake build` succeeds
- `G_theory_witness_consistent` and `H_theory_witness_consistent` compile without sorry

**Key risk point**: The G-boxing property for negative elements (`neg(G(a)) -> G(neg(G(a)))`) requires verification. If temporal negative introspection does not hold in this system, the G_theory definition must be simplified to only positive elements, and the witness consistency proof restructured. The box analog works because S5 has axiom 5 (negative introspection: `neg(Box(a)) -> Box(neg(Box(a)))`). The temporal logic may lack this.

**Fallback for Phase 1**: If G-boxing fails for the full `G_theory`, define a simpler seed:
- `G_theory_positive(M) = {G(a) | G(a) in M}`
- Prove consistency of `{phi} union G_theory_positive(M)` when `F(phi) in M`
- This is sufficient because: assume `{phi} union {G(a) | G(a) in M}` is inconsistent, then finite subset `G(a1), ..., G(an) |- neg(phi)`, by temporal necessitation + K-distribution: `G(a1), ..., G(an) |- G(neg(phi))`, all premises are in M, so `G(neg(phi)) in M`, but `F(phi) = neg(G(neg(phi))) in M`, contradiction.

---

### Phase 2: Extend to MCS Witnesses [NOT STARTED]

**Goal**: Use Lindenbaum's lemma to extend consistent sets to full MCS witnesses for temporal accessibility.

**Tasks**:
- [ ] Prove `G_theory_witness_exists`: If `F(phi) in M` (MCS), then exists MCS W with `phi in W` and `G_theory_agree M W` (i.e., for all psi, `G(psi) in M <-> G(psi) in W`)
  - Use `set_lindenbaum` to extend `{phi} union G_theory(M)` to MCS W
  - Prove `G_theory_agree` from W containing G_theory(M) (exactly as `box_theory_witness_exists` proves `box_class_agree`)
- [ ] Prove `H_theory_witness_exists` symmetrically for P(phi)
- [ ] Prove `temporal_witness_preserves_box_class`: The temporal witness W has `box_class_agree M W`
  - This follows from TF axiom: `Box(a) in M -> G(Box(a)) in M -> Box(a) in G_theory(M) -> Box(a) in W`
  - And for the reverse: `Box(a) in W -> ... ` (needs careful argument; may need to include box_theory in the seed)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add witness existence theorems

**Verification**:
- `lake build` succeeds
- `G_theory_witness_exists` and `H_theory_witness_exists` compile without sorry
- Box-class preservation verified

**Design decision**: The temporal witness W must be in the same box class as M (needed for the BFMCS construction). This requires that the seed `{phi} union G_theory(M)` also determines the box class. Options:
1. Include `box_theory(M)` in the seed: `{phi} union G_theory(M) union box_theory(M)` -- ensures both temporal and modal agreement
2. Derive box-class agreement from G_theory agreement + TF axiom -- cleaner but requires proof

---

### Phase 3: Rewire succ_chain_forward_F and backward_P [NOT STARTED]

**Goal**: Replace the sorry-dependent `succ_chain_forward_F` with a proof using temporal theory witnesses.

**Tasks**:
- [ ] Prove `succ_chain_forward_F_direct`: If `F(phi) in succ_chain_fam M0 n`, then exists `m > n` with `phi in succ_chain_fam M0 m`
  - Proof strategy: `F(phi) in succ_chain_fam M0 n` means `F(phi)` is in a specific MCS. Apply `G_theory_witness_exists` to get MCS W with `phi in W` and temporal theory agreement. Then use the SuccChain construction: W is an MCS, so `MCS_to_SerialMCS W` gives a SerialMCS, and `succ_chain_fam (MCS_to_SerialMCS W) 0 = W`, so `phi in succ_chain_fam (MCS_to_SerialMCS W) 0`.
  - **Key subtlety**: The witness W lives in a DIFFERENT SuccChain than M0's chain. We need to show the witness is in M0's chain at some position m > n. This requires one of:
    (a) Showing W = succ_chain_fam M0 (n+1) (the actual successor) -- unlikely since Lindenbaum is non-constructive
    (b) Using the constrained_successor construction: the successor of succ_chain_fam M0 n already satisfies Succ, and by the deferral disjunction, phi OR F(phi) is in the seed. We don't need the temporal witness for THIS step -- we need it to guarantee EVENTUAL resolution.
    (c) The temporal witness argument shows phi WILL appear, but the actual SuccChain construction already handles this via deferral disjunctions.
- [ ] **Alternative rewiring**: Instead of replacing `succ_chain_forward_F` directly, rewire `boxClassFamilies_temporally_coherent` to bypass `SuccChainTemporalCoherent` entirely
  - Prove temporal coherence for boxClassFamilies directly using temporal theory witnesses
  - The key: for `F(phi) in fam.mcs t` where fam is a shifted SuccChainFMCS, find a DIFFERENT family in boxClassFamilies that contains phi at some time s > t
  - This avoids needing the witness in the SAME chain -- it can be in any family in the bundle
- [ ] Prove `succ_chain_backward_P_direct` symmetrically (or rewire backward_P similarly)
- [ ] Update `SuccChainTemporalCoherent` to use the new proofs (or mark deprecated)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Replace `succ_chain_forward_F` or add `_direct` version
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Rewire `boxClassFamilies_temporally_coherent`

**Verification**:
- `lake build` succeeds
- `SuccChainTemporalCoherent` (or its replacement) compiles without sorry
- `boxClassFamilies_temporally_coherent` compiles without sorry
- `construct_bfmcs` remains sorry-free at the top level

**Critical design choice**: The BFMCS temporal coherence property requires that for `F(phi) in fam.mcs t`, there exists `s > t` with `phi in fam.mcs s` -- in the SAME family. This means the witness must be in the same SuccChain. Two approaches:

*Approach A (within-chain)*: Prove that the SuccChain construction itself guarantees eventual resolution of F-obligations. This is the original `succ_chain_forward_F` goal. The temporal witness gives us an MCS W where phi holds and G-theory agrees. We need to show this W is reachable along the chain. The constrained_successor construction uses deferral disjunctions (`psi OR F(psi)` for each `F(psi) in u`), which guarantees each F-obligation is either resolved or deferred at each step. Combined with the finite set of formulas in the G-theory seed, this should give eventual resolution.

*Approach B (bundle-level)*: Redefine temporal coherence for BFMCS to allow the witness in ANY family (not just the same one). This changes the semantics but may be sufficient for the truth lemma. However, the current `TemporalCoherentFamily` structure requires within-family witnesses, and changing this would require refactoring TemporalCoherence.lean.

**Recommendation**: Pursue Approach A first. If the within-chain argument is too complex, fall back to Approach B.

---

### Phase 4: Cleanup and Deprecation [NOT STARTED]

**Goal**: Remove false/deprecated theorems and clean up the codebase.

**Tasks**:
- [ ] Mark `f_nesting_is_bounded` as deprecated with comment explaining it is mathematically FALSE
- [ ] Mark `p_nesting_is_bounded` as deprecated (symmetric)
- [ ] Mark `f_nesting_boundary` as deprecated (depends on false theorem)
- [ ] Mark `p_nesting_boundary` as deprecated (symmetric)
- [ ] If `succ_chain_forward_F` was replaced (not rewired): mark old version deprecated
- [ ] Remove or mark deprecated the 4 boundary-case restricted chain sorries (lines 3072, 3104, 3118, 3189) if no longer on the critical path
- [ ] Add documentation comments explaining the algebraic approach
- [ ] Run full `lake build` to verify no regressions
- [ ] Run tests if available (`lake build Tests.BimodalTest`)

**Timing**: 0.5 hours (reduced from plan v1 since no boundary fixes needed)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Deprecation annotations
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Documentation

**Verification**:
- `lake build` succeeds
- Deprecated theorems have clear annotations
- No new sorries introduced
- `#print axioms succ_chain_completeness` shows no sorryAx (or shows only intentional axioms)

## Testing & Validation

- [ ] `lake build` succeeds with no new sorries
- [ ] `G_theory_witness_consistent` compiles without sorry
- [ ] `H_theory_witness_consistent` compiles without sorry
- [ ] `boxClassFamilies_temporally_coherent` no longer transitively depends on `f_nesting_is_bounded`
- [ ] `construct_bfmcs` and `succ_chain_completeness` remain functional
- [ ] `#print axioms construct_bfmcs` does not include sorryAx from the f_nesting chain
- [ ] `f_nesting_is_bounded` and `p_nesting_is_bounded` are marked deprecated or removed

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - G_theory, H_theory definitions; witness consistency and existence theorems; rewired temporal coherence
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Deprecated false theorems, possibly replaced succ_chain_forward_F

## Rollback/Contingency

**If Phase 1 G-boxing fails** (temporal negative introspection unavailable):
- Use simplified seed `{phi} union {G(a) | G(a) in M}` (positive G_theory only)
- The consistency proof simplifies: finite context of G-formulas, G-lift to get G(neg(phi)), contradicts F(phi) in M
- This is actually SIMPLER than the full G_theory approach and may be preferable

**If Phase 3 within-chain argument fails** (witness not reachable along same chain):
- Restructure BFMCS temporal coherence to allow cross-family witnesses
- This requires refactoring TemporalCoherence.lean but is mathematically sound
- The truth lemma uses temporal coherence for the G-backward direction; cross-family witnesses suffice for this

**If entire algebraic approach fails**:
- Revisit the finite horizon argument (Teammate C's alternative)
- This bounds the witness by `t + |deferralClosure(psi)|` using F-iteration containment within deferralClosure
- Higher risk than algebraic approach but does not require temporal theory infrastructure

**Git safety**: Create feature branch `task-55-algebraic-temporal` before starting implementation. Preserve all existing theorems until replacements are verified.
