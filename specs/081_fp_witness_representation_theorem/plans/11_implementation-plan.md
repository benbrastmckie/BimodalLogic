# Implementation Plan: F/P Witness Representation Theorem (v11)

- **Task**: 81 - F/P Witness Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (uses only sorry-free infrastructure)
- **Research Inputs**: reports/11_team-research.md
- **Artifacts**: plans/11_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the sorry in `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237) which blocks `completeness_over_Int` and `discrete_completeness_fc`. Plan 10 attempted a simplified restricted seed approach but discovered that `targeted_restricted_seed_consistent` (SimplifiedChain.lean:195) is unprovable: non-G-liftable seed elements (deferralDisjunctions, p_step_blocking) prevent the G-lift argument. This plan uses the "Full MCS Witness -> DRM Restriction" strategy identified by team research: extend a DRM to a full MCS, apply the sorry-free `temporal_theory_witness_exists` to obtain a witness with target resolved and G-agreement, then restrict back to deferralClosure via `deferral_restricted_lindenbaum` to obtain a valid DRM successor.

### Research Integration

Report 11 (team-research.md, 4 teammates) provides:
- All four teammates agree the G-lift obstruction is structural and cannot be worked around
- Teammate C identifies `temporal_theory_witness_exists` (UltrafilterChain.lean:2212) as the key sorry-free building block
- Teammates A+C recommend: Full MCS Witness -> DRM Restriction, bypassing seed consistency entirely
- The key unresolved technical question: proving Succ properties of the DRM restriction (gap identified in research synthesis)
- Only 1 sorry blocks completeness: `bfmcs_from_mcs_temporally_coherent` at Completeness.lean:237

## Goals & Non-Goals

**Goals**:
- Close the sorry in `bfmcs_from_mcs_temporally_coherent` (or bypass it entirely)
- Make `completeness_over_Int` and `discrete_completeness_fc` sorry-free for the blocking sorry
- Build a sorry-free `RestrictedTemporallyCoherentFamily` using only existing sorry-free infrastructure
- Reuse existing infrastructure: `temporal_theory_witness_exists`, `deferral_restricted_lindenbaum`, `restricted_truth_lemma`, `restricted_ext_neg_excludes_phi`

**Non-Goals**:
- Fix `constrained_successor_seed_restricted_consistent` (SuccChainFMCS.lean:2082) -- bypassed
- Fix `targeted_restricted_seed_consistent` (SimplifiedChain.lean:195) -- bypassed
- Address `dense_completeness_fc` (separate issue, requires dense canonical model)
- Address fuel=0 base case sorries in bounded witness proofs (semantically unreachable)
- Remove existing sorry-bearing chain infrastructure (still useful as documentation)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DRM restriction of full MCS W loses g_content formulas | H | M | G-agree from `temporal_theory_witness_exists` gives G(a) in W. By temp_t_future: a in W. If a in deferralClosure, a in DRM restriction. Verify g_content(u) subset deferralClosure. |
| DRM restriction fails to satisfy p_step blocking | H | M | p_step_blocking requires neg(P(chi)) when P(chi) not in u. Since neg(P(chi)) is in u (by DRM maximality) and in deferralClosure, it is in the full MCS extension of u. G-agreement propagates it to W. DRM restriction inherits it. |
| DRM maximality of restriction not guaranteed | H | L | `deferral_restricted_lindenbaum` produces a maximal consistent set within deferralClosure from any consistent seed. The seed W intersected with deferralClosure is consistent (subset of consistent W). |
| Backward chain (P-direction) requires symmetric construction | M | M | The existing `past_theory_witness_exists` (UltrafilterChain.lean, sorry-free) provides the symmetric H-agree property. Mirror the forward construction. |
| `DeferralRestrictedSerialMCS` extension to full MCS lacks F_top/P_top propagation | M | L | F_top and P_top are theorems (derivable), so they are in every MCS. The extension from DRM to full MCS automatically contains them. |
| New file imports cause `lake build` regressions | L | L | Add imports incrementally; run `lake build` after each phase. |

## Implementation Phases

### Phase 1: MCS Witness Successor Construction [NOT STARTED]

**Goal**: Define the core construction that takes a DRM u with F(target) in u, extends to full MCS, applies `temporal_theory_witness_exists`, and restricts back to a DRM successor.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/MCSWitnessSuccessor.lean` with imports from `UltrafilterChain`, `RestrictedMCS`, `SuccChainFMCS`, `SuccExistence`
- [ ] Define `drm_extend_to_mcs`: Given DRM u over phi, extend to full MCS M via `set_lindenbaum` applied to u. Prove M is MCS, u subset M, and key properties preserved (F_top in M, P_top in M, F(target) in M when F(target) in u)
- [ ] Define `mcs_witness_seed`: Given full MCS W (from `temporal_theory_witness_exists`), define the DRM seed as `W ∩ deferralClosure(phi)`. Prove this is DeferralRestricted and consistent (subset of consistent W)
- [ ] Define `mcs_witness_successor_drm`: Apply `deferral_restricted_lindenbaum` to `W ∩ deferralClosure(phi)` to get a DRM
- [ ] Prove `mcs_witness_successor_is_drm`: The result is a DeferralRestrictedMCS
- [ ] Prove `mcs_witness_successor_has_target`: target is in the successor DRM (target in W, target in deferralClosure -> target in seed -> target in DRM)
- [ ] Prove `mcs_witness_successor_g_persistence`: g_content(u) subset successor. Strategy: For a in g_content(u), G(a) in u subset M. By G-agree: G(a) in W. By temp_t_future and W being MCS: a in W. By g_content_subset_deferralClosure: a in deferralClosure. So a in W intersect deferralClosure = seed subset successor.
- [ ] Prove `mcs_witness_successor_has_F_top`: F_top is in successor (F_top is derivable, hence in every DRM via `deferral_restricted_mcs_theorem_membership` or similar)
- [ ] Prove `mcs_witness_successor_has_P_top`: P_top is in successor (symmetric)
- [ ] Run `lake build` to verify no errors

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/MCSWitnessSuccessor.lean` (NEW, ~300 lines)

**Verification**:
- All theorems compile without sorry
- `mcs_witness_successor_g_persistence` and `mcs_witness_successor_has_target` are the critical lemmas

---

### Phase 2: Succ Relation Properties [NOT STARTED]

**Goal**: Prove the DRM successor from Phase 1 satisfies the full Succ relation properties needed for chain construction: deferralDisjunction persistence (weak f_step), p_step blocking, and box propagation.

**Tasks**:
- [ ] Prove `mcs_witness_successor_deferral_disjunction`: For each F(psi) in u, the deferralDisjunction psi v F(psi) is in the successor. Strategy: The disjunction is in u (by DRM properties), hence in M. G-liftability is not needed -- instead, the disjunction is in deferralClosure and in M subset of the Lindenbaum extension. Use DRM maximality: the disjunction is in deferralClosure and consistent with the seed (since it is in u, and u's formulas that are in deferralClosure are consistent with the seed). Actually: the disjunction is in u subset M, but we need it in W. We do NOT have u subset W. Alternative: prove from DRM maximality of the successor -- if neg(psi v F(psi)) is consistent with successor, that means neg(psi) and neg(F(psi)) = G(neg(psi)) are in successor. But G(neg(psi)) in successor means (by DRM closure in deferralClosure) neg(psi) in the immediate successor... This needs careful analysis.
- [ ] Alternative approach for weak f_step: Instead of propagating deferralDisjunctions directly, prove that F(psi) in u and F(psi) in deferralClosure implies either psi or F(psi) is in the successor. Use DRM negation completeness: either psi in successor or neg(psi) in successor. If neg(psi) in successor, then either F(psi) in successor or G(neg(psi)) in successor. If G(neg(psi)) in successor and successor extends g_content(u)... This requires careful case analysis.
- [ ] Prove `mcs_witness_successor_p_step_blocking`: neg(P(chi)) in u when P(chi) not in u. These are in u subset M. G-agreement gives G(neg(P(chi))) in... no, neg(P(chi)) is NOT G-liftable. Instead: neg(P(chi)) is in u, in deferralClosure, and the successor DRM is maximal within deferralClosure. We need neg(P(chi)) in the successor. Since neg(P(chi)) = H(neg(chi)) (by definition of P), and H(neg(chi)) in u subset M, by H-agreement... wait, we only have G-agreement from temporal_theory_witness_exists, not H-agreement. Alternative: prove from DRM maximality -- either neg(P(chi)) or P(chi) in successor. If P(chi) in successor, what contradiction arises?
- [ ] Prove `mcs_witness_successor_box_class_agree`: box_class_agree between u's MCS extension and successor's MCS extension. Strategy: `temporal_theory_witness_exists` gives box_class_agree(M, W). Since successor extends W restricted to deferralClosure, and Box formulas are in deferralClosure, box_class_agree transfers.
- [ ] Define `build_mcs_witness_successor`: Package the construction into a `DeferralRestrictedSerialMCS` with all required properties
- [ ] Run `lake build`

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/MCSWitnessSuccessor.lean` (append, ~250 lines)

**Verification**:
- All Succ properties are sorry-free
- The weak f_step (resolve-or-defer) is proven for the new construction
- If any Succ property is unprovable, document the gap and evaluate fallback

---

### Phase 3: Forward Chain with Strong F-Resolution [NOT STARTED]

**Goal**: Build the forward chain by iterating the MCS witness successor, and prove forward_F using the strong property that each targeted step resolves exactly one F-obligation.

**Tasks**:
- [ ] Define `mcsWitnessForwardChainAt`: Recursive construction of DeferralRestrictedSerialMCS. At each step n, identify the "next" F-obligation to resolve using a fair scheduling scheme (e.g., based on `deferralClosure` enumeration or Nat.unpair). Apply `build_mcs_witness_successor` with target = the selected obligation.
- [ ] Define `mcs_witness_forward_chain phi M0 n := (mcsWitnessForwardChainAt phi M0 n).world`
- [ ] Prove `mcs_witness_forward_chain_is_drm`: Each element is a DRM
- [ ] Prove `mcs_witness_forward_chain_g_persistence`: g_content(chain(n)) subset chain(n+1). From `mcs_witness_successor_g_persistence`.
- [ ] Prove `mcs_witness_forward_chain_forward_F`: For F(psi) in chain(n), there exists m > n with psi in chain(m). Strategy: The fair scheduling guarantees every F-obligation is eventually targeted. When targeted at step k, psi in chain(k+1) by `mcs_witness_successor_has_target`. The bounded F-nesting within deferralClosure ensures the scheduling is well-founded. Alternative (simpler): use the dovetailing approach from DovetailedChain.lean -- enumerate all F-obligations in chain(0) and resolve them round-robin. New obligations introduced by resolution are bounded by deferralClosure finiteness.
- [ ] Alternative forward_F proof via bounded nesting: Since each chain element is a DRM, F-nesting is bounded by `closure_F_bound phi`. Use `f_nesting_is_bounded_restricted` to find the boundary depth. At each step, either the obligation is the target (resolved) or it defers. With fair scheduling, it must eventually be targeted.
- [ ] Run `lake build`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/MCSWitnessChain.lean` (NEW, ~300 lines)

**Verification**:
- `mcs_witness_forward_chain_forward_F` is sorry-free
- Fair scheduling terminates (Lean accepts the termination proof)

---

### Phase 4: Backward Chain and Backward P [NOT STARTED]

**Goal**: Build the symmetric backward chain using `past_theory_witness_exists` and prove backward_P coherence.

**Tasks**:
- [ ] Define `mcs_witness_predecessor_drm`: Symmetric to Phase 1, using `past_theory_witness_exists` instead of `temporal_theory_witness_exists`. This gives W with target in W, H-agree (H(a) in M -> H(a) in W), and box_class_agree.
- [ ] Prove predecessor properties symmetric to Phase 2: h_content persistence (from H-agree), P-step weak resolution, f_step blocking
- [ ] Define `mcsWitnessBackwardChainAt` and `mcs_witness_backward_chain`
- [ ] Prove `mcs_witness_backward_chain_backward_P`: For P(psi) in backward_chain(n), there exists m > n with psi in backward_chain(m). Uses bounded P-nesting + fair scheduling, symmetric to forward_F.
- [ ] Run `lake build`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/MCSWitnessChain.lean` (append, ~300 lines)

**Verification**:
- `mcs_witness_backward_chain_backward_P` is sorry-free
- Backward construction mirrors forward construction

---

### Phase 5: Combined Chain and TC Family [NOT STARTED]

**Goal**: Combine forward/backward chains into an Int-indexed chain, prove box_class_agree propagation, and build a `RestrictedTemporallyCoherentFamily`.

**Tasks**:
- [ ] Define `mcs_witness_succ_chain_fam`: Int-indexed chain combining forward (non-negative) and backward (negative) chains, matching the signature of `restricted_succ_chain_fam`
- [ ] Prove `mcs_witness_succ_chain_fam_is_drm`, `mcs_witness_succ_chain_fam_zero`
- [ ] Prove box propagation through the chain: Box(a) in chain(0) -> Box(a) in chain(n) for all n. Strategy: Box(a) -> G(Box(a)) derivable (axiom modal_4 + modal_future). G(Box(a)) in chain(0) means Box(a) in g_content(chain(0)) subset chain(1). Iterate forward. For backward: Box(a) -> H(Box(a)) derivable (axiom modal_4_past + modal_past). Iterate backward.
- [ ] Prove neg(Box(a)) propagation: neg(Box(a)) -> G(neg(Box(a))) derivable (S5 axiom 5 + modal_future). Symmetric argument.
- [ ] Build `mcs_witness_tc_family`:
  ```
  noncomputable def build_mcs_witness_tc_family (phi : Formula)
      (seed : DeferralRestrictedSerialMCS phi) : RestrictedTemporallyCoherentFamily phi
  ```
  The `forward_F` field uses `mcs_witness_forward_chain_forward_F` for non-negative indices and the backward chain's forward F property for negative indices. The `backward_P` field is symmetric.
- [ ] Handle the cross-chain case: F(psi) at a negative index requires resolution in the forward direction. Since the backward chain at position -(k+1) is a DRM, and F(psi) in it, the forward chain from that DRM resolves F(psi). Similarly for P(psi) at a non-negative index.
- [ ] Run `lake build`

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/MCSWitnessChain.lean` (append, ~350 lines)

**Verification**:
- `build_mcs_witness_tc_family` produces a sorry-free `RestrictedTemporallyCoherentFamily`
- Box propagation is sorry-free
- Cross-chain F/P resolution handles the Int.negSucc/Int.ofNat boundary

---

### Phase 6: Completeness Wiring [NOT STARTED]

**Goal**: Wire the MCS witness TC family into the completeness proof, closing the blocking sorry in `bfmcs_from_mcs_temporally_coherent`.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/MCSWitnessCompleteness.lean`
- [ ] Define `mcs_witness_completeness`: The main completeness theorem using the MCS witness approach.
  Proof outline:
  1. By contradiction: assume phi not provable
  2. `not_provable_implies_neg_consistent` gives SetConsistent {neg(phi)}
  3. `build_restricted_serial_mcs_from_neg_consistent` gives DeferralRestrictedSerialMCS with neg(phi)
  4. `build_mcs_witness_tc_family` gives RestrictedTemporallyCoherentFamily
  5. `restricted_ext_neg_excludes_phi` (RestrictedTruthLemma.lean:381) gives phi not in ext(0)
  6. ext(0) is a full MCS (by `restricted_chain_ext_is_mcs`)
  7. Build canonical BFMCS_Bundle from ext(0) via `construct_bfmcs_bundle`
  8. Apply `shifted_truth_lemma` using `bfmcs_from_mcs_temporally_coherent` -- but now we can FILL this sorry by showing the TC family provides the needed coherence
  9. Validity gives truth(phi) at canonical model, by truth lemma backward: phi in ext(0). Contradiction.
- [ ] Alternative wiring (simpler): Replace `completeness_over_Int` to call `mcs_witness_completeness` directly, bypassing `bfmcs_from_mcs_temporally_coherent` entirely:
  ```lean
  theorem completeness_over_Int {phi : Formula} :
      CompletenessOverIntStatement phi := by
    intro h_valid
    exact mcs_witness_completeness phi h_valid
  ```
- [ ] Fill the sorry in `bfmcs_from_mcs_temporally_coherent` if possible, or leave it with a note that `completeness_over_Int` no longer depends on it
- [ ] Run `lake build` to verify full project compiles
- [ ] Use `lean_verify` on `completeness_over_Int` to confirm no sorry dependencies

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/MCSWitnessCompleteness.lean` (NEW, ~200 lines)
- `Theories/Bimodal/FrameConditions/Completeness.lean` (modify ~10 lines: wire completeness_over_Int)

**Verification**:
- `mcs_witness_completeness` is sorry-free
- `completeness_over_Int` is sorry-free
- `discrete_completeness_fc` is sorry-free (delegates to completeness_over_Int)
- `lake build` succeeds across the full project

## Testing & Validation

- [ ] `lake build` succeeds with no new sorries in new files
- [ ] `lean_verify` on `mcs_witness_completeness` confirms no sorry axioms
- [ ] `lean_verify` on `completeness_over_Int` confirms the blocking sorry is closed
- [ ] `lean_verify` on `discrete_completeness_fc` confirms sorry-free
- [ ] Each phase's theorems compile independently (incremental verification)
- [ ] The MCS witness successor g_persistence uses only `temporal_theory_witness_exists` (no new sorry)
- [ ] Forward_F proof terminates (Lean accepts termination argument)
- [ ] Box propagation uses only sorry-free derived theorems
- [ ] Cross-chain F/P resolution at the Nat/negSucc boundary is verified

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/MCSWitnessSuccessor.lean` -- MCS witness successor construction and Succ properties (~550 lines)
- `Theories/Bimodal/Metalogic/Bundle/MCSWitnessChain.lean` -- Forward/backward chains, combined chain, TC family (~950 lines)
- `Theories/Bimodal/Metalogic/Algebraic/MCSWitnessCompleteness.lean` -- Completeness theorem (~200 lines)
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- Modified to wire completeness_over_Int (~10 lines changed)
- `specs/081_fp_witness_representation_theorem/summaries/11_execution-summary.md` -- Execution summary

## Rollback/Contingency

- All new code is in new files (`MCSWitnessSuccessor.lean`, `MCSWitnessChain.lean`, `MCSWitnessCompleteness.lean`), so rollback is simply deleting these files and reverting the small change to `Completeness.lean`.
- If Phase 2 (Succ properties) reveals that some property is unprovable for the DRM restriction:
  - Fallback A: Use the "reduced seed" variant from Teammate A -- `{target} union g_content(u)` is provably consistent, extend to DRM via Lindenbaum, rely on DRM maximality for other properties
  - Fallback B: Combine the MCS witness approach with the existing `constrained_successor_restricted` by replacing only the consistency argument (use `temporal_theory_witness_exists` to prove the full seed is consistent)
- If the cross-chain F/P resolution (Phase 5) is harder than expected, build separate RestrictedTemporallyCoherentFamily instances for forward and backward, then combine at the BFMCS level.
- Git tags before each phase enable granular rollback.
