# Implementation Plan: Restricted Coherence Refactoring for Canonical Completeness

- **Task**: 81 - F/P Witness Representation Theorem
- **Status**: [IMPLEMENTING]
- **Effort**: 20-25 hours
- **Dependencies**: None (FMP sorries deferred to task 82)
- **Research Inputs**: reports/19_fmp-vs-canonical-completeness.md, reports/20_team-research.md, reports/18_team-research.md, summaries/17_execution-summary.md
- **Artifacts**: plans/20_restricted-coherence-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the sole remaining canonical completeness sorry (`bfmcs_from_mcs_temporally_coherent` in Completeness.lean:237) by refactoring the type system from full temporal coherence to restricted temporal coherence. The current `TemporalCoherentFamily` quantifies `forward_F` and `backward_P` over ALL formulas, but the truth lemma only invokes these properties on subformulas of the root formula -- all of which lie within `deferralClosure`. The restricted chain infrastructure (`build_restricted_tc_family`) already provides sorry-free forward_F/backward_P within `deferralClosure`. The refactoring weakens the type to match actual usage, making the sorry closable with existing infrastructure. FMP TruthPreservation sorries are explicitly deferred to task 82.

### Research Integration

Report 20 (team research, 4 teammates) provides the key architectural insight: the sorry is in the CONSTRUCTION of temporally coherent families, not in the truth lemma proof itself. Teammate A's restricted coherence proposal resolves this by weakening `TemporalCoherentFamily.forward_F` from quantifying over all phi to quantifying over `phi in deferralClosure(root)`. Teammate B confirms the restricted construction is sorry-free. Teammate D's critique (truth lemma already done; sorry is in construction) is addressed by the type refactoring. Report 19 confirms simultaneous induction on formula complexity resolves the Imp-case circularity. Summary 17 documents prior failed approaches (fuel exhaustion, modified backward chain).

## Goals & Non-Goals

**Goals**:
- Define `modal_temporal_depth` function for formula complexity measure
- Refactor `TemporalCoherentFamily` to use restricted temporal coherence (forward_F/backward_P within `deferralClosure` only)
- Adapt `ParametricTruthLemma` to work with restricted coherence hypothesis
- Bridge restricted chain construction to refactored BFMCS temporal coherence
- Close the sorry in `bfmcs_from_mcs_temporally_coherent`
- Verify `lake build` clean with zero new sorries

**Non-Goals**:
- Closing FMP TruthPreservation sorries (deferred to task 82)
- Closing fuel=0 sorries in SuccChainFMCS (semantically unreachable, independent)
- Removing dead code in SuccChainFMCS
- Extension results (density, discreteness) beyond basic completeness
- Changing the proof system or semantics of TM

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| G/H propagation across time steps requires `G(G(chi))` in deferralClosure | H | L | Truth lemma's forward G case applies g_persistence one step at a time via structural induction on chi, never requiring G(G(chi)); verify with decision gate in Phase 2 |
| Imp-case backward direction needs forward_F for sub-formulas at same depth | H | M | Simultaneous induction on formula complexity ensures forward_F at depth k is available when proving Imp at depth k+1; the restricted coherence only needs subformulas which are strictly smaller |
| Refactoring TemporalCoherentFamily breaks existing sorry-free theorems | H | M | Introduce a new `RestrictedCoherentBFMCS` type alongside existing types rather than modifying them; existing code continues to work; new completeness path uses new types |
| Bridge from restricted DRM chain to full MCS families fails | H | M | Use existing `restricted_chain_subset_extended` (sorry-free) for embedding; if full bridge is intractable, prove a restricted completeness theorem directly |
| Lean termination checker rejects depth induction | M | L | Use well-founded recursion on `Formula.sizeOf` which Lean already handles; alternatively use `Finset.strongInduction` on subformula closure |
| Scope creep into FMP or extension work | M | L | Strict scope boundary: only canonical completeness; FMP is task 82 |

## Implementation Phases

### Phase 1: Formula Depth Infrastructure [COMPLETED]

- **Goal:** Define the `modal_temporal_depth` function and prove key properties needed for the simultaneous induction argument. This is the foundational measure that enables the restricted coherence proof.

- **Tasks:**
  - [ ] Define `modal_temporal_depth : Formula -> Nat` in a new section of `SubformulaClosure.lean` or a new file `FormulaDepth.lean`:
    - `atom p` => 0
    - `bot` => 0
    - `imp psi chi` => `max (modal_temporal_depth psi) (modal_temporal_depth chi)` (imp does NOT increase depth)
    - `box psi` => `modal_temporal_depth psi + 1`
    - `all_future psi` => `modal_temporal_depth psi + 1`
    - `all_past psi` => `modal_temporal_depth psi + 1`
  - [ ] Prove `subformula_depth_le`: for psi a subformula of phi, `modal_temporal_depth psi <= modal_temporal_depth phi`
  - [ ] Prove `imp_subformula_depth_lt`: for `psi.imp chi`, both psi and chi have depth `<= modal_temporal_depth (psi.imp chi)`, and for the G/H backward case, the relevant subformulas have strictly smaller depth
  - [ ] Prove `temporal_subformula_depth_lt`: for `G(psi)` or `H(psi)`, `modal_temporal_depth psi < modal_temporal_depth (G(psi))`
  - [ ] Prove `deferralClosure_contains_subformulas_at_depth`: all subformulas of phi at depth <= k are in `deferralClosure(phi)` (or verify this follows from existing `subformulaClosure_subset_deferralClosure`)
  - [ ] `lake build` to verify no regressions

- **Timing:** 2-3 hours

- **Files to modify:**
  - `Theories/Bimodal/Syntax/SubformulaClosure.lean` -- add depth function and properties (or new file `FormulaDepth.lean`)

- **Verification:**
  - `lake build` succeeds
  - All new lemmas type-check without sorry
  - Existing theorems unaffected

---

### Phase 2: Decision Gate -- G/H Single-Step Sufficiency [COMPLETED]

- **Goal:** Verify that the truth lemma's forward G case only needs single-step g_persistence (not iterated `G(G(chi))` propagation). This resolves the key remaining concern from Report 20 (Teammate B's bridge gap) before committing to the full refactoring.

- **Tasks:**
  - [ ] Trace the forward G case in `parametric_canonical_truth_lemma` (ParametricTruthLemma.lean:312-332): confirm that `forward_G` is invoked on `psi`, where the truth lemma is being proved for `G(psi)`, and that `psi` is a strict subformula
  - [ ] Trace the backward G case (line 320-332): confirm that `temporal_backward_G` invokes `forward_F` on `neg(psi)`, and `neg(psi)` is in `subformulaClosure(G(psi))` which is in `deferralClosure`
  - [ ] Verify that at no point does the truth lemma require `forward_F` or `forward_G` for `G(psi)` itself (only for `psi` and `neg(psi)`)
  - [ ] Write a brief analysis comment in the plan confirming or refuting single-step sufficiency
  - [ ] If single-step is INSUFFICIENT: pivot to augmenting `deferralClosure` with bounded G/H-iterations (Teammate B's proposed fix from Report 20)

- **Timing:** 1-2 hours

- **Files to modify:**
  - None (analysis only; update this plan with findings)

- **Verification:**
  - Clear written confirmation that the forward G case uses `forward_G` on `psi` (not `G(psi)`) and backward G uses `forward_F` on `neg(psi)` (which is in deferralClosure)

---

### Phase 3: Define Restricted Coherence Types [NOT STARTED]

- **Goal:** Define the restricted coherence variant of `BFMCS.temporally_coherent` that only requires forward_F/backward_P for formulas within `deferralClosure` of a root formula. This is the core type refactoring.

- **Tasks:**
  - [ ] Define `BFMCS.restricted_temporally_coherent` (or `RestrictedCoherentBFMCS`) in a new file or section of `TemporalCoherence.lean`:
    ```
    def BFMCS.restricted_temporally_coherent (B : BFMCS D) (root : Formula) : Prop :=
      forall fam in B.families,
        (forall t, forall phi in deferralClosure root,
          F(phi) in fam.mcs t -> exists s >= t, phi in fam.mcs s) /\
        (forall t, forall phi in deferralClosure root,
          P(phi) in fam.mcs t -> exists s <= t, phi in fam.mcs s)
    ```
  - [ ] Define `RestrictedTemporalCoherentFamily` variant that restricts forward_F/backward_P to deferralClosure:
    ```
    structure RestrictedTemporalCoherentFamily' (D : Type*) [Preorder D] [Zero D]
        (root : Formula) extends FMCS D where
      forward_F : forall t, forall phi,
        phi in deferralClosure root ->
        F(phi) in mcs t -> exists s >= t, phi in mcs s
      backward_P : forall t, forall phi,
        phi in deferralClosure root ->
        P(phi) in mcs t -> exists s <= t, phi in mcs s
    ```
  - [ ] Prove `restricted_temporal_backward_G`: analog of `temporal_backward_G` using restricted forward_F. The proof works because the contrapositive argument invokes forward_F on `neg(psi)`, and when `G(psi)` is a subformula of root, `neg(psi)` is in `deferralClosure(root)`.
    ```
    theorem restricted_temporal_backward_G (fam : RestrictedTemporalCoherentFamily' D root)
        (t : D) (phi : Formula)
        (h_phi_dc : phi.neg in deferralClosure root)
        (h_all : forall s >= t, phi in fam.mcs s) :
        G(phi) in fam.mcs t
    ```
  - [ ] Prove symmetric `restricted_temporal_backward_H` for the H case
  - [ ] `lake build` to verify

- **Timing:** 4-5 hours

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` -- add restricted variants
  - Possibly a new file `Theories/Bimodal/Metalogic/Bundle/RestrictedCoherence.lean` if TemporalCoherence.lean becomes too large

- **Verification:**
  - `lake build` succeeds
  - New types and backward lemmas are sorry-free
  - Existing `TemporalCoherentFamily` and `temporal_backward_G/H` are untouched

---

### Phase 4: Adapt Truth Lemma for Restricted Coherence [NOT STARTED]

- **Goal:** Prove a restricted version of `parametric_canonical_truth_lemma` that takes `B.restricted_temporally_coherent root` instead of `B.temporally_coherent`, where root is the formula being evaluated. This is the central proof effort.

- **Tasks:**
  - [ ] Define `restricted_parametric_canonical_truth_lemma` with signature:
    ```
    theorem restricted_parametric_canonical_truth_lemma
        (B : BFMCS D) (root : Formula)
        (h_tc : B.restricted_temporally_coherent root)
        (fam : FMCS D) (hfam : fam in B.families)
        (t : D) (phi : Formula)
        (h_sub : phi in subformulaClosure root) :
        phi in fam.mcs t <-> truth_at ... t phi
    ```
  - [ ] Prove by structural induction on phi (same cases as existing truth lemma):
    - **atom**: identical to existing (no temporal coherence needed)
    - **bot**: identical to existing
    - **imp**: identical structure; the IH gives the result for psi and chi which are subformulas of root (inherited from `h_sub`)
    - **box**: identical to existing (uses modal coherence only); subformula property passes through since `psi` is a subformula of `box(psi)` which is a subformula of root
    - **all_future (G)**: forward direction unchanged (uses `forward_G` from FMCS, no temporal coherence); backward direction uses `restricted_temporal_backward_G` with the hypothesis that `neg(psi)` is in `deferralClosure(root)` -- proved from `psi in subformulaClosure(root)` implies `neg(psi) in closureWithNeg(root) subset deferralClosure(root)`
    - **all_past (H)**: symmetric to G case
  - [ ] Prove `restricted_shifted_truth_lemma` wrapper analogous to `shifted_truth_lemma` but using restricted coherence
  - [ ] `lake build` to verify

- **Timing:** 5-7 hours

- **Files to modify:**
  - New file `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` (preferred to avoid modifying the existing sorry-free ParametricTruthLemma.lean)
  - `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` -- add import

- **Verification:**
  - `lake build` succeeds
  - The restricted truth lemma is sorry-free
  - Existing `parametric_canonical_truth_lemma` is untouched
  - Key check: the G/H backward cases successfully invoke `restricted_temporal_backward_G/H` with the deferralClosure membership proof

---

### Phase 5: Bridge Restricted Chain to BFMCS Restricted Coherence [NOT STARTED]

- **Goal:** Prove that the BFMCS built from `construct_bfmcs_bundle` satisfies `restricted_temporally_coherent` for any root formula. This connects the sorry-free restricted chain infrastructure to the completeness theorem.

- **Tasks:**
  - [ ] Understand how `boxClassFamilies` builds each family: each family is a `shifted_fmcs (SuccChainFMCS S) delta` for some `SerialMCS S` in the same box class as M0
  - [ ] For each such family, prove restricted forward_F:
    - Given `F(phi) in shifted_fmcs.mcs(t)` with `phi in deferralClosure(root)`, need to find `s >= t` with `phi in shifted_fmcs.mcs(s)`
    - Approach: The SuccChainFMCS is built from a SerialMCS S. Build `RestrictedTemporallyCoherentFamily` from the DeferralRestrictedSerialMCS derived from S (using `build_restricted_tc_family`). The restricted chain's forward_F gives a witness within the DRM chain. Use `restricted_chain_subset_extended` to lift the witness to the full MCS chain.
  - [ ] Key bridge lemma: `restricted_tc_forward_F_lifts_to_succ_chain`:
    ```
    theorem restricted_tc_forward_F_lifts_to_succ_chain
        (S : SerialMCS) (phi root : Formula)
        (h_phi_dc : phi in deferralClosure root)
        (t : Int) (h_F : F(phi) in SuccChainFMCS_mcs S t) :
        exists s >= t, phi in SuccChainFMCS_mcs S s
    ```
  - [ ] Prove symmetric backward_P bridge lemma
  - [ ] Prove `bfmcs_restricted_temporally_coherent`:
    ```
    theorem bfmcs_restricted_temporally_coherent (M : Set Formula) (h_mcs : SetMaximalConsistent M) (root : Formula) :
        (bundle_to_bfmcs (construct_bfmcs_bundle M h_mcs)).restricted_temporally_coherent root
    ```
  - [ ] `lake build` to verify

- **Timing:** 4-6 hours

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- add bridge lemmas connecting restricted chain to SuccChainFMCS families
  - Possibly `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- add lemmas showing restricted chain properties lift through shifting

- **Verification:**
  - `lake build` succeeds
  - `bfmcs_restricted_temporally_coherent` is sorry-free
  - The bridge from `build_restricted_tc_family` to `boxClassFamilies` is complete

---

### Phase 6: Wire to Completeness and Close Sorry [NOT STARTED]

- **Goal:** Replace the sorry in `bfmcs_from_mcs_temporally_coherent` (or bypass it) by wiring the restricted coherence path through to the completeness theorem.

- **Tasks:**
  - [ ] Option A (preferred): Modify `bundle_validity_implies_provability` to use `restricted_shifted_truth_lemma` instead of `shifted_truth_lemma`:
    - The root formula is `phi` (the formula being proved)
    - Use `bfmcs_restricted_temporally_coherent M h_mcs phi` for the coherence hypothesis
    - The restricted truth lemma applies since we evaluate `phi` which is in `subformulaClosure(phi)`
  - [ ] Option B (if A requires too many changes): Prove `bfmcs_from_mcs_temporally_coherent` by showing full temporal coherence follows from restricted coherence for every possible root:
    - For any `F(psi) in fam.mcs(t)`, set `root = F(psi)` and use restricted coherence for that root
    - `psi in deferralClosure(F(psi))` follows from subformula closure properties
    - This upgrades restricted coherence to full coherence
  - [ ] Close or replace the sorry at Completeness.lean:237
  - [ ] Verify the entire completeness chain is sorry-free:
    - `bundle_validity_implies_provability` -> `restricted_shifted_truth_lemma` -> `bfmcs_restricted_temporally_coherent` -> `build_restricted_tc_family` (all sorry-free)
  - [ ] `lake build` to verify clean build

- **Timing:** 2-3 hours

- **Files to modify:**
  - `Theories/Bimodal/FrameConditions/Completeness.lean` -- modify or add completeness theorem using restricted path
  - Possibly add `import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma`

- **Verification:**
  - `lake build` succeeds
  - `grep -rn sorry Theories/Bimodal/FrameConditions/Completeness.lean` shows zero sorries (or only the original sorry in `bfmcs_from_mcs_temporally_coherent` if using Option A bypass, with a new sorry-free completeness theorem alongside)
  - `completeness_over_Int` or its restricted variant is sorry-free

---

### Phase 7: Cleanup and Verification [NOT STARTED]

- **Goal:** Clean build, verify sorry counts, and ensure no regressions.

- **Tasks:**
  - [ ] Run `lake clean && lake build` for full rebuild
  - [ ] Count sorries: `grep -rn sorry Theories/Bimodal/` and compare against pre-implementation count
  - [ ] Verify no new sorries introduced
  - [ ] Verify the completeness theorem chain is fully sorry-free
  - [ ] Add documentation comments to new files explaining the restricted coherence architecture
  - [ ] Remove any temporary scaffolding or debug code
  - [ ] Create execution summary

- **Timing:** 2-3 hours

- **Files to modify:**
  - Various -- documentation and cleanup only
  - `specs/081_fp_witness_representation_theorem/summaries/20_restricted-coherence-summary.md` -- execution summary

- **Verification:**
  - `lake build` succeeds from clean state
  - Sorry count in `Theories/Bimodal/FrameConditions/Completeness.lean` reduced by at least 1 (the main sorry)
  - All pre-existing sorry-free theorems remain sorry-free
  - New code has comprehensive docstrings

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] `grep -rn sorry Theories/Bimodal/FrameConditions/Completeness.lean` shows no sorry in the completeness theorem chain
- [ ] `grep -rn sorry` across new files shows zero sorries
- [ ] The restricted truth lemma produces a bidirectional iff for all formulas in `subformulaClosure(root)`
- [ ] The bridge from `build_restricted_tc_family` to `bfmcs_restricted_temporally_coherent` is fully sorry-free
- [ ] Existing sorry-free infrastructure (soundness, FMP, boxClassFamilies_modal_forward/backward) remains unbroken
- [ ] Lean 4 elaboration completes within reasonable time (no timeout on any single file)

## Artifacts & Outputs

- `plans/20_restricted-coherence-plan.md` (this file)
- `Theories/Bimodal/Syntax/FormulaDepth.lean` (or additions to SubformulaClosure.lean) -- depth function
- `Theories/Bimodal/Metalogic/Bundle/RestrictedCoherence.lean` (or additions to TemporalCoherence.lean) -- restricted types
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` -- restricted truth lemma
- Modifications to `UltrafilterChain.lean` -- bridge lemmas
- Modifications to `Completeness.lean` -- sorry closed
- `summaries/20_restricted-coherence-summary.md` -- execution summary

## Rollback/Contingency

1. **Phase 2 decision gate fails** (G/H requires `G(G(chi))`): Augment `deferralClosure` to include bounded G/H-iterations per Teammate B's proposal. Since deferralClosure is already finite, adding `G^k(psi)` for bounded k maintains finiteness. Estimated additional effort: 3-4 hours.

2. **Bridge (Phase 5) fails** -- restricted chain does not lift to SuccChainFMCS: Fall back to Option B in Phase 6 -- prove full temporal coherence from per-formula restricted coherence. Each F(psi) invocation sets root=F(psi) and uses the restricted chain for that specific root.

3. **Restricted truth lemma (Phase 4) hits unexpected issue**: The existing `parametric_canonical_truth_lemma` is sorry-free given temporal coherence. If the restricted variant has structural issues, consider weakening the full coherence type to match by adding a `root` parameter rather than creating a wholly new type.

4. **Full rollback**: All new code is in NEW files (RestrictedCoherence.lean, RestrictedParametricTruthLemma.lean, FormulaDepth.lean). Deleting these files and reverting any modifications to existing files restores the pre-implementation state. Git: `git checkout main -- Theories/Bimodal/`.

5. **Scope reduction**: If the full 7-phase plan exceeds budget, Phase 6 Option A (modify completeness to use restricted path) is the minimum viable result. Phases 1-5 plus Phase 6 Option A gives a sorry-free completeness theorem even if cleanup (Phase 7) is deferred.
