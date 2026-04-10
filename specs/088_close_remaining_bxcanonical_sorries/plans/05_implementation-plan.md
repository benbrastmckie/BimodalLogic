# Implementation Plan: Close CanonicalEmbedding:418 Sorry (v5)

- **Task**: 88 - Close remaining BXCanonical sorries (NARROWED: CanonicalEmbedding:418 only)
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None
- **Research Inputs**: reports/05_team-research.md
- **Artifacts**: plans/05_implementation-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the single sorry at CanonicalEmbedding.lean:418 in `usf_completeness` (Until/Since-free fragment completeness for BX logic). The sorry is in the `imp` case B: given MCS `w` with `psi in w`, `chi not in w`, and `valid(psi.imp chi)`, derive `False`. Plan v4's two-point WorldHistory approach is definitively blocked (backward G bridge is mathematically impossible on finite histories -- confirmed by round 5 team research with 0% confidence revision). This plan uses a USF-specialized truth lemma from the Bundle architecture that drops Until/Since coherence (vacuously satisfied for USF) and closes the remaining family-level temporal coherence gap (`succ_chain_restricted_forward_F`). Definition of done: `usf_completeness` type-checks without sorry and `lake build` succeeds.

### Research Integration

Round 5 team research (4 teammates) confirms: (1) the two-point approach is mathematically impossible (not just engineering difficulty), (2) the theorem IS true (axiom system is complete for USF), (3) the Bundle architecture has a sorry-free truth lemma for {atom, bot, imp, box, G, H} cases, but requires `temporally_coherent` (family-level forward_F/backward_P) which has a sorry in `succ_chain_restricted_forward_F`. The research identified three approaches: Bundle reuse (primary), proof-theoretic reduction (secondary), and large D model (fallback). This plan follows the Bundle reuse approach but accounts for the temporal coherence gap that the research under-analyzed.

### Prior Plan Reference

Plan v4 was based on the two-point WorldHistory approach, which round 5 research definitively debunked. Key lessons: (1) the backward truth bridge for G on finite histories is a mathematical impossibility, not an engineering gap; (2) the constant-history collapse (G collapses to identity) is fundamental to the BXCanonical architecture; (3) the 6h effort estimate was reasonable for the approach, but the approach itself was wrong. This plan takes a fundamentally different direction.

### Roadmap Alignment

No ROAD_MAP.md found. Closing this sorry yields `usf_completeness`: the first verified formalization of S5+G/H fragment completeness in Lean 4.

## Goals & Non-Goals

**Goals**:
- Close CanonicalEmbedding.lean:418 sorry for `usf_completeness`
- Create a USF-specialized truth lemma that drops Until/Since coherence requirements
- Close `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` sorries for family-level temporal coherence within the restricted deferralClosure scope
- Wire the USF truth lemma with temporal coherence to produce a countermodel for the imp case B
- `lake build` succeeds with `usf_completeness` sorry-free

**Non-Goals**:
- Closing Frame.lean sorries (task 89 -- Until/Since eventuality resolution)
- Closing Completeness.lean:160 sorry (task 89)
- Closing the FULL temporal coherence sorry (only need restricted version for USF)
- Modifying the axiom system (BX1-BX12 are fixed)
- General-purpose completeness theorem (only USF fragment)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `succ_chain_restricted_forward_F` may be harder than expected -- F-nesting in deferralClosure may not resolve in SuccChain | H | M | If blocked: try proof-theoretic reduction (Phase 3 alternative) where well-founded induction on temporal depth peels G/H from the consequent, reducing to `fragment_completeness` for the base case |
| USF truth lemma may need additional infrastructure beyond simple case elimination | M | L | The structural induction proof is identical to `canonical_truth_lemma` minus untl/snce cases -- mechanical change |
| Wiring the restricted temporal coherence with the Bundle construction may hit universe or import issues | M | L | The existing `restricted_shifted_truth_lemma` already handles the restricted case; adapt its pattern |
| The "restricted" scope (deferralClosure) may not cover all subformulas needed for USF truth lemma | M | L | For USF formulas, deferralClosure(root) contains all subformulas plus their negations -- sufficient because G/H backward only need neg(psi) for subformulas psi |
| SuccChainFMCS forward_F resolution may require new Succ relation properties not yet proven | H | M | The constrained_successor construction already includes f_step (f_content propagation); the key is showing this terminates within bounded F-nesting |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases are sequential: each builds on the previous.

---

### Phase 1: Create USF Truth Lemma Variant [NOT STARTED]

**Goal**: Write `usf_shifted_truth_lemma` that proves `phi in fam.mcs t <-> truth_at ... phi` for USF formulas, requiring only `restricted_temporally_coherent` (not `backward/forward_until_since_coherent`).

**Tasks**:
- [ ] In `CanonicalConstruction.lean` (or a new file `USFTruthLemma.lean`), define `usf_shifted_truth_lemma` by adapting `restricted_shifted_truth_lemma`:
  - Same signature but replace `h_buc : B.backward_until_since_coherent` and `h_fuc : B.forward_until_since_coherent` with `h_usf : untilSinceFree phi`
  - Import `untilSinceFree` from `CanonicalEmbedding.lean` (or move the predicate to a shared location)
  - atom/bot/imp/box/G/H cases: identical to `restricted_shifted_truth_lemma`
  - untl/snce cases: `exact absurd h_usf id` (or use structural impossibility from `untilSinceFree`)
- [ ] Verify the subformulaClosure propagation: `untilSinceFree (psi.imp chi)` implies `untilSinceFree psi` and `untilSinceFree chi`, etc. These are needed for the recursive IH calls.
- [ ] Ensure the `restricted_temporally_coherent` hypothesis threads through correctly (the G/H backward cases use `restricted_temporal_backward_G/H_strict` which need forward_F/backward_P only for formulas in deferralClosure)
- [ ] `lake build` with the new lemma (may have sorry in temporal coherence dependency -- that's OK for this phase)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (or new USFTruthLemma.lean) -- Add USF truth lemma variant
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- Move `untilSinceFree` to shared location if needed

**Verification**:
- `usf_shifted_truth_lemma` type-checks (with downstream sorry acceptable)
- `lake build` succeeds

---

### Phase 2: Close Restricted Temporal Coherence Sorry [NOT STARTED]

**Goal**: Prove `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` -- the key remaining sorries for family-level temporal coherence within deferralClosure scope.

**Tasks**:
- [ ] Analyze the SuccChainFMCS construction in `SuccChainFMCS.lean` to understand how F(psi) propagates:
  - The Succ relation has `f_step`: `f_content(chain(n)) subseteq chain(n+1) union f_content(chain(n+1))`
  - `F(psi) in chain(n)` means `neg(G(neg psi)) in chain(n)`, i.e., `G(neg psi) not in chain(n)`
  - The chain construction uses `constrained_successor_seed` which includes f_content in the seed
- [ ] For `psi in deferralClosure(root)`: establish that the F-nesting depth is bounded by `max_F_depth_in_closure` (already defined in the codebase)
- [ ] Prove forward_F resolution by induction on F-depth within deferralClosure:
  - Base: psi has no F-nesting in deferralClosure -> F(psi) in chain(n) -> by f_step, either psi in chain(n+1) (done) or F(psi) in chain(n+1) (recurse with decreased depth bound)
  - Step: use bounded F-depth to show termination
- [ ] If the bounded-depth approach fails: try alternative argument using the fact that `constrained_successor_seed_restricted` includes all formulas in deferralClosure, so the successor MCS is forced to resolve the F-witness within bounded steps
- [ ] Prove `succ_chain_restricted_backward_P` symmetrically (using h_content and P instead of f_content and F)

**Timing**: 5 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- Close the two sorry stubs at `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P`
- Possibly `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- Add helper lemmas about F-nesting bounds if needed

**Verification**:
- Both sorry stubs closed
- `lake build` succeeds
- No new sorries introduced

---

### Phase 3: Wire USF Completeness via Bundle Countermodel [NOT STARTED]

**Goal**: Use the USF truth lemma and temporal coherence to construct a countermodel that closes the sorry at CanonicalEmbedding.lean:418.

**Tasks**:
- [ ] Build the completeness wiring: given MCS w with `psi in w`, `chi not in w`, `valid(psi.imp chi)`, `untilSinceFree (psi.imp chi)`:
  1. Construct BFMCS B from w using `construct_bfmcs_bundle w.formulas w.is_mcs` (sorry-free)
  2. Get eval_family fam with `fam.mcs 0 = w.formulas` (from `construct_bfmcs_bundle_eval_at_zero`)
  3. Prove `B.restricted_temporally_coherent (psi.imp chi)` using Phase 2's closed sorries
  4. Apply `usf_shifted_truth_lemma` to get bidirectional bridge for psi and chi
  5. Forward bridge: `psi in fam.mcs 0 -> truth_at psi` (from `psi in w`)
  6. Validity: `truth_at (psi.imp chi)` (from `valid(psi.imp chi)` instantiated at this model)
  7. Modus ponens: `truth_at chi`
  8. Backward bridge: `chi in fam.mcs 0 = w.formulas`
  9. Contradiction with `chi not in w`
- [ ] Handle the Omega shift-closure requirement: `ShiftClosedCanonicalOmega B` is shift-closed (already proved as `shiftClosedCanonicalOmega_is_shift_closed`)
- [ ] Handle the to_history membership: `to_history fam in ShiftClosedCanonicalOmega B` (follows from eval_family_mem via canonicalOmega_subset_shiftClosed)
- [ ] Package as a helper lemma `usf_imp_case_b` that can be called from the sorry site
- [ ] If BXCanonical's `BXPoint` and Bundle's `CanonicalWorldState` are different types, handle the type conversion (BXPoint wraps an MCS, CanonicalWorldState wraps an MCS -- may need an explicit conversion or shared abstraction)

**Timing**: 3 hours

**Depends on**: Phase 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- Add helper lemma and imports, prepare for sorry closure

**Verification**:
- Helper lemma `usf_imp_case_b` type-checks without sorry
- `lake build` succeeds
- The lemma provides exactly the `False` needed at the sorry site

---

### Phase 4: Close the Sorry and Verify [NOT STARTED]

**Goal**: Replace the sorry at line 418 with the constructed proof and verify the full build.

**Tasks**:
- [ ] Replace `sorry` at CanonicalEmbedding.lean:418 with call to `usf_imp_case_b` (or inline the proof if the helper is simple enough)
- [ ] Verify `usf_completeness` type-checks without sorry
- [ ] Run `lake build` to confirm no regressions
- [ ] Run `grep -rn sorry CanonicalEmbedding.lean` to confirm zero remaining sorries
- [ ] Check that existing sorry-free results are unmodified: `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs`, `fragment_completeness`, `fragment_truth_iff`
- [ ] Verify no new axioms were added beyond BX1-BX12

**Timing**: 2 hours

**Depends on**: Phase 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- Replace sorry with proof

**Verification**:
- `usf_completeness` type-checks without sorry
- `lake build` succeeds with no errors
- `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` returns zero Lean sorry instances
- No new axioms added

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` returns zero sorry instances
- [ ] `usf_completeness` type-checks without sorry
- [ ] No new axioms added beyond BX1-BX12
- [ ] Existing sorry-free results in TruthLemma.lean (`G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs`) remain unmodified
- [ ] `fragment_completeness` still works (no regressions)
- [ ] The USF truth lemma does NOT depend on `backward_until_since_coherent` or `forward_until_since_coherent`
- [ ] The sorry count in `UltrafilterChain.lean` decreases by 2 (the restricted forward_F and backward_P)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- sorry at line 418 closed
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (or new file) -- USF truth lemma variant
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- 2 sorries closed (restricted temporal coherence)
- `specs/088_close_remaining_bxcanonical_sorries/plans/05_implementation-plan.md` -- This plan

## Rollback/Contingency

**Phase-level rollback**: All modifications are additive (new lemmas) except the sorry replacement in Phase 4. Revert Phase 4 with `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean`.

**If Phase 2 is blocked** (succ_chain_restricted_forward_F proves harder than expected):

**Alternative approach -- Proof-theoretic reduction (12h)**:
1. Restructure `usf_completeness` to use well-founded induction on `(temporal_depth_consequent, sizeOf)` instead of structural induction
2. G case: `valid(psi -> G(alpha))` -> `valid(P(psi) -> alpha)` -> by IH: `deriv P(psi) -> alpha` -> lift via connect_future + temporal_necessitation + K-distribution
3. H case: symmetric via connect_past + past_necessitation + past_k_dist
4. box case: `valid(psi -> box(alpha))` -> `valid(diamond(psi) -> alpha)` -> by IH + modal_b
5. Base case (consequent temporal-free): split on `valid(chi)` -- if valid, IH gives derivation; if not valid, `fragment_completeness` for temporal-free chi gives the contradiction
6. Key risk: base case "neither valid" sub-case may require a separate semantic argument

**Fallback -- Large D model (20-40h)**:
Instantiate `valid` with D = free abelian group on BXPoint (large enough for surjective history). Heavy Mathlib plumbing but mathematically clean.

**Partial completion**: Phase 1 alone has moderate value (reusable USF truth lemma). Phase 2 alone has high value (closes 2 sorries in the Bundle architecture). Phases 1+2 without 3+4 leave the sorry in CanonicalEmbedding but improve the overall sorry count.
