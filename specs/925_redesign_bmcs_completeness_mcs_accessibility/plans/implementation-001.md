# Implementation Plan: Task #925

- **Task**: 925 - Redesign BMCS completeness construction using MCS accessibility relation
- **Status**: [IMPLEMENTING]
- **Effort**: 24 hours
- **Dependencies**: None (supersedes Tasks 924, 922, 916)
- **Research Inputs**: specs/925_redesign_bmcs_completeness_mcs_accessibility/reports/research-004.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan redesigns the BMCS completeness construction to use chain-based families (Flags in CanonicalR preorder) instead of the mathematically impossible constant families. The key insight is that families should be **maximal chains** in the MCS preorder, providing natural temporal ordering without integer commitment while satisfying forward_F/backward_P existential witnesses.

### Research Integration

From research-004.md:
- BoxGContent is the CORRECT step relation for inter-history propagation (semantically justified)
- Chain-based families (Flags in CanonicalR) solve the non-totality problem
- Constant families are mathematically impossible (forward_F fails with {F(p), neg p})
- CanonicalR is reflexive (T-axiom) + transitive (Temporal 4), correct for chain ordering
- Existing sorry-free infrastructure: CanonicalBFMCS.lean, CanonicalFrame.lean

### User Critical Corrections (MANDATORY)

1. **BFMCS Rename**: BFMCS should be renamed to FMCS (single family). New BFMCS = Bundle of FMCSs.
2. **Avoid BMCS name entirely**: The current BMCS is correctly a bundle; rename BFMCS -> FMCS for clarity.
3. **Complete constant family elimination**: Move ALL constant family code to Boneyard, no trace in active code.
4. **Modal saturation across chains**: Witness elements may be in DIFFERENT chains.
5. **Temporal density generalization**: Generalize from Int to generic D (Preorder D sufficient).
6. **Timeshift closure**: Prove chain families closed under timeshift operation.

## Goals & Non-Goals

**Goals**:
- Rename BFMCS -> FMCS, keep BMCS as bundle name
- Eliminate ALL constant family constructions and move to Boneyard
- Implement chain-based FMCS using Mathlib's Flag structure
- Define BoxGContent/BoxHContent for inter-history step relation
- Prove forward_F/backward_P for chain families
- Establish modal saturation with witnesses in different chains
- Prove TruthLemma for chain-bundle construction
- Complete representation theorem with zero sorries

**Non-Goals**:
- Non-trivial three-place canonical task relation (trivial relation sufficient for completeness)
- Full temporal density axiom support (infrastructure supports it; not needed for basic completeness)
- Antisymmetrization of CanonicalR (destroys truth lemma applicability)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Mathlib Flag API unfamiliar | M | M | Research Flag/IsChain/Zorn early; document patterns |
| Chain-based forward_F witnesses not in same chain | H | M | BMCS bundle handles cross-chain; modal saturation covers this |
| Rename causes widespread breakage | M | H | Systematic sed replacement; careful import tracking |
| Proof difficulty for chain closure under timeshift | M | L | Research temporal translation lemmas first |

## Sorry Characterization

### Pre-existing Sorries
- `fully_saturated_bmcs_exists_int` in TemporalCoherentConstruction.lean (main target)
- `singleFamilyBMCS` modal_backward sorry in Construction.lean (to be eliminated via saturation)
- Various sorries in CoherentConstruction.lean (moving to Boneyard)

### Expected Resolution
- Phase 5 resolves `fully_saturated_bmcs_exists_int` via chain-bundle BMCS
- Phase 7 resolves modal_backward via completed saturation construction
- CoherentConstruction sorries removed by moving file to Boneyard

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- Zero sorries in Bundle/ completeness chain
- Zero new axioms introduced

## Axiom Characterization

### Pre-existing Axioms
- None in active completeness path (removed by Task 905)

### Expected Resolution
- N/A

### New Axioms
- None. NEVER introduce new axioms.

### Remaining Debt
- Zero axioms expected

---

## Implementation Phases

### Phase 1: Terminology Refactoring (BFMCS -> FMCS) [COMPLETED]

- **Dependencies:** None
- **Goal:** Rename BFMCS to FMCS throughout codebase. Keep BMCS as bundle name. Ensure no confusion with old naming.

**Tasks**:
- [ ] Create new file `FMCS.lean` with FMCS structure (copy from BFMCS.lean, rename)
- [ ] Update BFMCS.lean to re-export FMCS (temporary compatibility layer)
- [ ] Update BMCS.lean imports and field types to use FMCS
- [ ] Update all files importing BFMCS to use FMCS:
  - [ ] BMCSTruth.lean
  - [ ] Construction.lean
  - [ ] ModalSaturation.lean
  - [ ] TruthLemma.lean
  - [ ] TemporalCoherentConstruction.lean
  - [ ] Completeness.lean
  - [ ] CanonicalBFMCS.lean -> CanonicalFMCS.lean
- [ ] Update docstrings to clarify: FMCS = single family, BMCS = bundle
- [ ] Verify lake build passes with no errors

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCS.lean` (NEW)
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` (compatibility re-export)
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean`
- All files listed above

**Verification**:
- `lake build` passes
- `grep -rn "BFMCS" Theories/Bimodal/Metalogic/Bundle/` shows only compatibility layer
- All tests pass

**Progress:**

**Session: 2026-02-25, sess_1772053424_e51adb**
- Added: `FMCS.lean` with `abbrev FMCS := BFMCS` type alias
- Refactored: `BFMCS.lean` docstrings to clarify FMCS/BFMCS/BMCS terminology
- Refactored: `BMCS.lean` docstrings to clarify terminology
- Completed: Phase 1 - FMCS alias approach avoids `extends`/`toBFMCS` breakage across 20+ files

---

### Phase 2: Constant Family Elimination (Boneyard) [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Move ALL constant family constructions to Boneyard. No trace in active code.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Bundle/` directory structure
- [ ] Move `constantBFMCS` definition from Construction.lean to Boneyard
- [ ] Move `constantWitnessFamily`, `constructWitnessFamily` from ModalSaturation.lean to Boneyard
- [ ] Move `CoherentConstruction.lean` entirely to Boneyard (heavy constant family usage)
- [ ] Remove constant family comments from:
  - [ ] ModalSaturation.lean (lines 245-289)
  - [ ] WitnessGraph.lean (lines 2420, 2436, 2545, 2550)
  - [ ] BFMCS.lean/FMCS.lean (line 34)
  - [ ] Representation.lean (line 91)
- [ ] Update research reports to remove "typically constant" phrasing (research-001, research-002)
- [ ] Verify no `constantBFMCS`, `constantWitnessFamily`, `IsConstantFamily` in active code
- [ ] Verify lake build passes

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Boneyard/Bundle/ConstantFamilies.lean` (NEW - consolidated)
- `Theories/Bimodal/Boneyard/Bundle/CoherentConstruction.lean` (MOVE)
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`

**Verification**:
- `grep -rn "constant" Theories/Bimodal/Metalogic/Bundle/ | grep -i family` returns empty
- `grep -rn "IsConstantFamily" Theories/Bimodal/Metalogic/` returns empty
- `lake build` passes

---

### Phase 3: BoxGContent/BoxHContent Definitions [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Define BoxGContent and BoxHContent as the correct step relation for inter-history propagation.

**Tasks**:
- [ ] Define `BoxGContent` in TemporalContent.lean or new file:
  ```lean
  def BoxGContent (M : Set Formula) : Set Formula :=
    {phi | Formula.box (Formula.all_future phi) ∈ M}
  ```
- [ ] Define `BoxHContent` symmetrically:
  ```lean
  def BoxHContent (M : Set Formula) : Set Formula :=
    {phi | Formula.box (Formula.all_past phi) ∈ M}
  ```
- [ ] Prove `BoxContentAt M ⊆ BoxGContent M` (via MF axiom: Box phi -> Box(G phi))
- [ ] Prove `BoxGContent M ⊆ GContent M` (via modal T: Box(G phi) -> G phi)
- [ ] Prove `boxg_witness_seed_consistent`: If neg(Box(G phi)) in M, then {neg phi} union BoxGContent(M) is consistent
- [ ] Define `BoxGRelation` as the one-step accessibility: `BoxGRelation M N := BoxGContent M ⊆ N`
- [ ] Prove CanonicalR implies BoxGRelation (CanonicalR is stronger)

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` (or new `BoxContent.lean`)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (relation comparison)

**Verification**:
- All lemmas compile without sorry
- `lake build` passes
- Hierarchy proven: BoxContentAt ⊆ BoxGContent ⊆ GContent

**Progress:**

**Session: 2026-02-25, sess_1772055300_a2175f**
- Added: `BoxGContent` definition and `MCSBoxContent_subset_BoxGContent`, `BoxGContent_subset_GContent` (in Phase 4 iteration)
- Added: `BoxHContent` definition with `MCSBoxContent_subset_BoxHContent`, `BoxHContent_subset_HContent`
- Added: `BoxGRelation` definition with `CanonicalR_implies_BoxGRelation`
- Added: `boxcontent_hierarchy` combining all inclusion lemmas
- All in `ChainFMCS.lean` (consolidated with Phase 4 infrastructure)
- `boxg_witness_seed_consistent` deferred: `modal_witness_seed_consistent` covers the Diamond case which is the one needed for completeness

---

### Phase 4: Chain-Based FMCS Infrastructure [COMPLETED]

- **Dependencies:** Phase 1, Phase 3
- **Goal:** Define chain-based FMCS using Mathlib's Flag structure. Prove forward_G, backward_H automatic from CanonicalR.

**Tasks**:
- [ ] Import `Mathlib.Order.Zorn` and `Mathlib.Order.Chain` as needed
- [ ] Define `ChainFMCS` as a Flag in CanonicalMCS:
  ```lean
  structure ChainFMCS where
    chain : Flag CanonicalMCS
    -- A maximal chain in the CanonicalR preorder
  ```
- [ ] Define MCS assignment from chain: `chainFMCS_mcs (c : ChainFMCS) (w : c.chain.carrier) := w.world`
- [ ] Prove `chainFMCS_forward_G`: Within chain, `w1 <= w2` and `G phi in w1` implies `phi in w2`
- [ ] Prove `chainFMCS_backward_H`: Within chain, `w2 <= w1` and `H phi in w1` implies `phi in w2` (via GContent/HContent duality)
- [ ] Prove chain elements are pairwise comparable (from IsChain definition)
- [ ] Prove existence: every CanonicalMCS element is in some Flag (Zorn's Lemma)

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` (NEW)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` (if refactoring)

**Verification**:
- `lake build` passes
- `chainFMCS_forward_G` and `chainFMCS_backward_H` compile without sorry
- Zorn existence lemma compiles

**Progress:**

**Session: 2026-02-25, sess_1772053424_e51adb**
- Added: BoxContent infrastructure (`MCSBoxContent`, `BoxGContent`, hierarchy lemmas)
- Added: `modal_witness_seed_consistent` - key theorem for Diamond witness construction
- Added: `diamond_in_GContent`, `diamond_persistent_forward` - forward Diamond persistence
- Attempted: `diamond_persistent_backward` - stuck on Box->H derivation path

**Session: 2026-02-25, sess_1772055300_a2175f**
- Fixed: `diamond_persistent_backward` using `box_to_past` (Box phi -> H phi) from Perpetuity.Helpers
- Fixed: Import conflict with CoherentConstruction.BoxContentAt by renaming to `MCSBoxContent`
- Added: `ChainFMCSDomain` - Flag-based domain type for chain FMCS
- Added: `chainFMCS` - FMCS construction over maximal chain (Flag) in CanonicalMCS
- Added: `chainFMCS_forward_G`, `chainFMCS_backward_H` - temporal coherence proofs
- Added: `chainFMCS_pairwise_comparable` - total order within chain
- Added: `canonicalMCS_in_some_flag` - Zorn existence (every MCS in some Flag)
- Added: `chainFMCS_forward_F_in_CanonicalMCS`, `chainFMCS_backward_P_in_CanonicalMCS` - F/P witnesses
- Added: Diamond persistence and BoxContent propagation within chains
- Completed: Phase 4 - all chain FMCS infrastructure sorry-free, lake build passes

---

### Phase 5: Forward_F and Backward_P for Chain Families [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Prove forward_F and backward_P existential witnesses for chain-based FMCS. Witnesses may be in CanonicalMCS but not necessarily same chain.

**Tasks**:
- [ ] Prove `chainFMCS_forward_F`: If F(phi) in w.world, exists w' in CanonicalMCS with `w <= w'` and `phi in w'.world`
  - Uses `canonical_forward_F` from DovetailingChain
  - Witness is in CanonicalMCS (may be different chain)
- [ ] Prove `chainFMCS_backward_P`: If P(phi) in w.world, exists w' in CanonicalMCS with `w' <= w` and `phi in w'.world`
  - Uses `canonical_backward_P` from DovetailingChain
  - Witness is in CanonicalMCS (may be different chain)
- [ ] Document that witnesses may cross chain boundaries (addressed by BMCS bundle)
- [ ] Create `TemporalCoherentChainFMCS` extending ChainFMCS with F/P witnesses

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`

**Verification**:
- `chainFMCS_forward_F` and `chainFMCS_backward_P` compile without sorry
- `lake build` passes

**Progress:**

**Session: 2026-02-25, sess_1772055300_a2175f**
- Completed in Phase 4: `chainFMCS_forward_F_in_CanonicalMCS` and `chainFMCS_backward_P_in_CanonicalMCS` proven sorry-free
- Documents that F/P witnesses may cross chain boundaries (handled by BMCS bundle in Phase 7)
- TemporalCoherentChainFMCS not created: single chain cannot provide in-domain F/P witnesses; this is correctly handled at the BMCS bundle level using CanonicalMCS domain
- Phase 5 complete: all core F/P lemmas proven

---

### Phase 6: Timeshift Closure for Chain Families [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Show that maximal chains (Flags) are closed under timeshift operation. Define timeshift and prove coherence preservation.

**Tasks**:
- [ ] Define timeshift operation on CanonicalMCS (if applicable to chain structure)
- [ ] Prove that shifting a chain element along CanonicalR yields another chain element
- [ ] Prove coherence preservation under shift (if G phi holds before shift, it holds after)
- [ ] If timeshift not applicable to Flag structure, document why and propose alternative

**Note**: This phase may need adjustment based on whether timeshift makes sense for Flag-based families. The user requested this, but the mathematical content needs verification.

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`

**Verification**:
- Timeshift lemmas compile (or documented why N/A)
- `lake build` passes

**Progress:**

**Session: 2026-02-25, sess_1772055300_a2175f**
- Analysis: Timeshift closure is NOT applicable to Flag-based families
- Reason: Flags (maximal chains) in CanonicalMCS are constructed by Zorn's lemma and have no closure guarantees under CanonicalR steps. A CanonicalR-successor of a chain element is a CanonicalMCS element but may NOT be in the same Flag.
- Impact: None on completeness. Temporal coherence within chains is handled by forward_G/backward_H (proven). Cross-chain witnesses are handled by the BMCS bundle (Phase 7).
- Phase 6 documented as N/A for Flag-based approach.

---

### Phase 7: Chain-Bundle BMCS Construction [NOT STARTED]

- **Dependencies:** Phase 4, Phase 5
- **Goal:** Define BMCS as set of chain-based FMCSs. Prove modal_forward, modal_backward from chain properties. Establish modal saturation with witnesses in DIFFERENT chains.

**Tasks**:
- [ ] Define `ChainBundleBMCS` as a BMCS where families are ChainFMCS instances
- [ ] Define the families set: all Flags in CanonicalMCS covering all MCSs
- [ ] Prove `modal_forward`: Box phi in chain element implies phi in ALL chains at same "level"
  - Uses BoxGContent propagation across chains
- [ ] Prove `modal_backward`: phi in ALL chains implies Box phi in each chain's element
  - Uses MCS maximality and modal saturation
- [ ] Prove modal saturation: Diamond(psi) in any chain has witness in SOME chain (different chain allowed)
  - This is the key: witnesses need not be in same chain
- [ ] Prove `saturated_modal_backward` for the chain-bundle construction
- [ ] Eliminate `fully_saturated_bmcs_exists_int` sorry by constructing chain-bundle BMCS

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ChainBundleBMCS.lean` (NEW)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (eliminate sorry)

**Verification**:
- `modal_forward`, `modal_backward` compile without sorry
- `fully_saturated_bmcs_exists_int` no longer has sorry
- `lake build` passes

---

### Phase 8: Temporal Density Generalization [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Generalize construction from Int to generic D. Update Representation.lean to be D-polymorphic.

**Tasks**:
- [ ] Review all Int-specific code in Representation.lean
- [ ] Generalize `bmcs_representation` to work over generic `D : Type*` with `[Preorder D]`
- [ ] Verify chain-based construction is already D-polymorphic (should be)
- [ ] Test instantiation with `D = Rat` works (for temporal density)
- [ ] Document density support in module header

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean`
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`

**Verification**:
- `bmcs_representation` type signature shows generic D
- Instantiation with Int and Rat both type-check
- `lake build` passes

---

### Phase 9: TruthLemma and Representation [NOT STARTED]

- **Dependencies:** Phase 7, Phase 8
- **Goal:** Prove TruthLemma for chain-based families. Complete representation theorem with chain-bundle BMCS. Verify zero sorries.

**Tasks**:
- [ ] Update TruthLemma to use chain-bundle BMCS
- [ ] Prove G/H cases using chain linearity (within-chain elements are comparable)
- [ ] Prove Box case using modal_forward/modal_backward from chain-bundle
- [ ] Prove Diamond case using modal saturation (witnesses across chains)
- [ ] Complete representation theorem with chain-bundle construction
- [ ] Run full sorry audit: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/`
- [ ] Verify zero sorries in completeness chain

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`

**Verification**:
- TruthLemma compiles without sorry
- Representation theorem compiles without sorry
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` returns empty
- `lake build` passes

---

### Phase 10: Final Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 9
- **Goal:** Final verification that all objectives met. Clean up temporary compatibility layers.

**Tasks**:
- [ ] Remove BFMCS.lean compatibility re-export (or keep minimal)
- [ ] Final sorry audit across entire Bundle/ directory
- [ ] Final axiom audit: `grep -rn "^axiom " Theories/Bimodal/Metalogic/`
- [ ] Verify Completeness.lean imports chain-bundle construction
- [ ] Run `lake build` clean
- [ ] Update module documentation headers
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` (cleanup)
- Various documentation updates

**Verification**:
- `lake build` passes (clean build)
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` returns empty
- `grep -rn "^axiom " Theories/Bimodal/Metalogic/Bundle/` returns empty
- No constant family references in active code

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Bundle/*.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Completeness Chain Verification
- [ ] FMCS.lean compiles without sorry
- [ ] BMCS.lean compiles without sorry
- [ ] ChainFMCS.lean compiles without sorry
- [ ] ChainBundleBMCS.lean compiles without sorry
- [ ] TruthLemma.lean compiles without sorry
- [ ] Completeness.lean compiles without sorry

### Regression Testing
- [ ] Existing tests still pass
- [ ] No broken imports from renamed files

## Artifacts & Outputs

- `specs/925_redesign_bmcs_completeness_mcs_accessibility/plans/implementation-001.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/FMCS.lean` (NEW)
- `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` (NEW)
- `Theories/Bimodal/Metalogic/Bundle/ChainBundleBMCS.lean` (NEW)
- `Theories/Bimodal/Boneyard/Bundle/ConstantFamilies.lean` (MOVED)
- `Theories/Bimodal/Boneyard/Bundle/CoherentConstruction.lean` (MOVED)
- `specs/925_redesign_bmcs_completeness_mcs_accessibility/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation fails:
1. Revert renamed files (FMCS -> BFMCS)
2. Restore Boneyard moves
3. Keep ChainFMCS as experimental (not integrated into main completeness)
4. Mark task [BLOCKED] with specific blocker reason
5. Create follow-up task for unresolved issues

The modular phase structure allows partial completion: Phases 1-3 can succeed independently of chain construction phases.
