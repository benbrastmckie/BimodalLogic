# Implementation Summary: Establish until_since_coherent

- **Task**: 84 - Establish Until/Since Coherence for Bundle Completeness
- **Status**: PARTIAL
- **Session**: sess_1775660340_1ebebb
- **Plan**: plans/02_until-since-coherent.md

## Results

### Phase 1: Foundation (COMPLETED)

Proved key infrastructure lemmas and closed 3 sorry sites in SuccExistence.lean:

1. **`g_content_subset_mcs`** (SuccRelation.lean): `g_content(u) ⊆ u` for any MCS u under BX1.
   - Proof: `G(φ) → φ` (BX1 axiom) + MCS derivation closure
   - Impact: De-risks the enriched seed consistency argument

2. **`h_content_subset_mcs`** (SuccRelation.lean): `h_content(u) ⊆ u` for any MCS u under BX1'.
   - Proof: `H(φ) → φ` (BX1' axiom) + MCS derivation closure
   - Impact: Symmetric dual for Since direction

3. **`or_until_in_mcs`** (SuccRelation.lean): `(ψ ∨ (φ ∧ (φ U ψ))) ∈ M → (φ U ψ) ∈ M`.
   - Proof: Case split on ψ/¬ψ in MCS + BX8 + conjunction elimination
   - Impact: Replaces removed `until_intro` axiom under reflexive semantics

4. **`or_since_in_mcs`** (SuccRelation.lean): `(ψ ∨ (φ ∧ (φ S ψ))) ∈ M → (φ S ψ) ∈ M`.
   - Proof: Temporal dual of `or_until_in_mcs`
   - Impact: Replaces removed `since_intro` axiom under reflexive semantics

5. **Closed sorry sites in SuccExistence.lean** (3 sorries removed):
   - `constrained_successor_seed_consistent` (line 476): g_content ⊆ u via BX1
   - `successor_deferral_seed_consistent_axiom` (line 784): g_content ⊆ u via BX1
   - `predecessor_deferral_seed_consistent_axiom` (line 860): h_content ⊆ u via BX1'

### Phases 2-4: Forward/Backward Until/Since (BLOCKED)

**Root Cause Analysis**: Deep analysis of all three chain constructions confirmed that
`until_since_coherent` cannot be closed with the current architecture:

- **Forward Until**: Requires intra-family forward_F witness (F(ψ) ∈ fam.mcs t → ∃ s > t, ψ ∈ fam.mcs s). This is sorry in ALL chain constructions (DovetailedChain, UltrafilterChain, DeterministicFMCS). The X-vs-G mismatch prevents Until formulas from propagating through g_content seeds.

- **Backward Until**: Requires backward propagation of Until formulas through the chain. The only construction with this capability (DeterministicFMCS in Boneyard) has additional sorry dependencies (y_det, x_det, y_k_dist removed in BX refactor). Our new `or_until_in_mcs` replaces `until_intro` but x_content linkage sorries remain.

- **Forward/Backward Since**: Symmetric blockers to Until.

### Phase 5: Testing and Cleanup (PARTIAL)

- Full `lake build` passes with no errors and no new sorries
- Documentation updated for all modified theorems
- Stale "KNOWN FALSE under strict semantics" comments corrected

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` | +4 new theorems (or_until_in_mcs, or_since_in_mcs, g_content_subset_mcs, h_content_subset_mcs) |
| `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` | -3 sorries (g_content/h_content subset proofs via BX1/BX1') |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | Documentation updates only |

## Sorry Inventory

### Sorries Removed (3)
- SuccExistence.lean:476 (`constrained_successor_seed_consistent`)
- SuccExistence.lean:784 (`successor_deferral_seed_consistent_axiom`)
- SuccExistence.lean:860 (`predecessor_deferral_seed_consistent_axiom`)

### Sorries Remaining (3 target sites unchanged)
- Completeness.lean:322 (`bundle_validity_implies_provability`, h_uc)
- Completeness.lean:356 (`restricted_bundle_validity_implies_provability`, h_uc)
- Completeness.lean:450 (`dovetailed_bundle_validity_implies_provability`, h_uc)

### What Would Unblock the Remaining Sorries

1. **New chain construction**: Build an omega-chain that provides BOTH g_content propagation AND x_content propagation (Until formula persistence). This would enable both forward and backward Until.

2. **DeterministicFMCS repair**: Close the y_det/x_det/y_k_dist sorries in the Boneyard DeterministicFMCS, then derive forward_F/backward_P for that construction. The backward Until is already proved there modulo these sorries.

3. **Definition split (last resort)**: Split `until_since_coherent` into forward-only and backward components, restructure the truth lemma to handle each direction separately.
