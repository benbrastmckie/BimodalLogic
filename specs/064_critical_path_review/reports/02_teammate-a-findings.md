# Teammate A: Strategy C -- Restricted Chain + sigma-Duality Dovetailing

## Key Findings

1. **sigma-duality infrastructure is complete and sorry-free**: The `sigma_quot` operation in LindenbaumQuotient.lean implements temporal duality on the Lindenbaum algebra with proven properties: involution (`sigma_quot_involution`), G/H swap (`sigma_quot_G_H`, `sigma_quot_H_G`), box commutativity (`sigma_quot_box`), and Boolean operation preservation.

2. **The restricted forward chain is sorry-free**: `restricted_forward_chain` in SuccChainFMCS.lean provides F-coherent chains for `DeferralRestrictedMCS` with proven `restricted_forward_chain_forward_F` theorem.

3. **Backward chain requires symmetric construction, NOT direct sigma application**: The backward chain cannot be built by simply applying sigma to formula sets. Instead, it requires a symmetric `constrained_predecessor_restricted` construction that mirrors the successor construction but uses h_content and pastDeferralDisjunctions.

4. **The dovetailing join point is mathematically clean**: Both forward and backward chains start from the same M0, so they meet at position 0 without consistency issues.

5. **The main gap is `constrained_predecessor_restricted`**: This is an engineering task (symmetric to the existing `constrained_successor_restricted`), not a mathematical obstacle.

## Technical Analysis

### sigma-Duality at Formula Level

**Definition** (Formula.lean:390-396):
```lean
def swap_temporal : Formula -> Formula
  | atom s => atom s
  | bot => bot
  | imp phi psi => imp phi.swap_temporal psi.swap_temporal
  | box phi => box phi.swap_temporal
  | all_past phi => all_future phi.swap_temporal
  | all_future phi => all_past phi.swap_temporal
```

**Key properties**:
- `swap_temporal_involution`: sigma^2 = id (proven)
- `swap_temporal_neg`: sigma(neg phi) = neg(sigma phi) (proven)
- `swap_temporal_diamond`: sigma(diamond phi) = diamond(sigma phi) (proven)

**Derived operators under sigma**:
- sigma(G phi) = H(sigma phi) [swaps all_future to all_past]
- sigma(H phi) = G(sigma phi) [swaps all_past to all_future]
- sigma(F phi) = P(sigma phi) [derived: F = neg . G . neg]
- sigma(P phi) = F(sigma phi) [derived: P = neg . H . neg]

**Lifted to quotient** (LindenbaumQuotient.lean:371-438):
```lean
def sigma_quot : LindenbaumAlg -> LindenbaumAlg :=
  Quotient.lift (fun phi => toQuot phi.swap_temporal)
    (fun _ _ h => Quotient.sound (provEquiv_swap_temporal_congr h))
```

### Applying sigma to MCS Sets

**Question**: If M is an MCS, is sigma(M) := {sigma(phi) : phi in M} also an MCS?

**Analysis**: Yes, sigma(M) is an MCS because:
1. **Consistency**: If sigma(M) were inconsistent, there would exist phi_1, ..., phi_n in M with sigma(phi_1), ..., sigma(phi_n) deriving bot. By temporal_duality inference rule, sigma preserves derivability, so phi_1, ..., phi_n would derive bot (applying sigma^-1 = sigma), contradicting M's consistency.

2. **Maximality**: For any formula psi, either psi or neg(psi) is in M. Applying sigma: either sigma(psi) or sigma(neg psi) = neg(sigma psi) is in sigma(M).

3. **Derivation closure**: If sigma(M) derives psi, then by temporal_duality rule (if |- A then |- sigma(A)), M derives sigma(psi), so sigma(psi) in M implies psi in sigma(M).

**Key theorem** (not yet formalized but provable):
```
If M is F-coherent, then sigma(M) is P-coherent.
```

**Proof sketch**:
- F-coherence: F(phi) in M implies exists future witness for phi
- Apply sigma: sigma(F(phi)) = P(sigma(phi)) in sigma(M)
- The witness property transforms correspondingly
- Hence sigma(M) is P-coherent

### Backward Chain Construction via sigma

**Approach 1: Direct sigma application (REJECTED)**

The naive approach would be:
```
backward_chain(n) := sigma(forward_chain(n))
```

**Problem**: This doesn't preserve the `DeferralRestrictedMCS` property. The deferralClosure is NOT sigma-invariant in general:
- deferralClosure(phi) contains {chi or F(chi) : F(chi) in closureWithNeg(phi)}
- sigma(deferralClosure(phi)) contains {sigma(chi) or P(sigma(chi)) : ...}
- This is NOT the same as deferralClosure(phi) unless phi is sigma-symmetric

**Approach 2: Symmetric construction (CORRECT)**

The restricted backward chain requires a symmetric construction:

1. **h_content**: {phi : H(phi) in u} (dual to g_content)
2. **pastDeferralDisjunctions**: {chi or P(chi) : P(chi) in u} (dual to deferralDisjunctions)
3. **predecessor_deferral_seed**: h_content(u) union pastDeferralDisjunctions(u)
4. **constrained_predecessor_restricted**: Build predecessor within deferralClosure

**Key insight**: The deferralClosure already includes BOTH forward and backward deferral disjunctions:
```
deferralClosure(phi) = closureWithNeg(phi)
                     union {chi or F(chi) : F(chi) in closureWithNeg(phi)}
                     union {chi or P(chi) : P(chi) in closureWithNeg(phi)}
```

This means the backward construction can use the SAME deferralClosure as the forward construction.

### Dovetailing Algorithm

**Input**: DeferralRestrictedSerialMCS phi M0 (contains both F_top and P_top)

**Construction**:
```
// Forward chain (sorry-free, exists)
fwd : Nat -> DeferralRestrictedMCS phi
fwd(0) = M0
fwd(n+1) = constrained_successor_restricted(phi, fwd(n))

// Backward chain (needs constrained_predecessor_restricted)
bwd : Nat -> DeferralRestrictedMCS phi
bwd(0) = M0
bwd(n+1) = constrained_predecessor_restricted(phi, bwd(n))

// Combined FMCS over Z
combined : Int -> DeferralRestrictedMCS phi
combined(n) = if n >= 0 then fwd(n) else bwd(-n)
```

**Join consistency**: Both fwd(0) = M0 = bwd(0), so the chains meet exactly at M0.

**Temporal coherence**:
- Forward F-coherence: `restricted_forward_chain_forward_F` (proven)
- Backward P-coherence: symmetric theorem for backward chain (needs proof)

### RestrictedMCS Preservation

**Question**: Does constrained_predecessor_restricted preserve DeferralRestrictedMCS?

**Analysis**: Yes, by the symmetric structure of the construction:

1. **h_content stays in closure**: If H(phi) in u and u subset deferralClosure, then phi in h_content(u). By closureWithNeg closure under subformulas, phi in deferralClosure.

2. **pastDeferralDisjunctions stay in closure**: By definition, {chi or P(chi) : P(chi) in closureWithNeg} subset deferralClosure.

3. **Lindenbaum extension within closure**: The deferral-restricted Lindenbaum lemma (`deferral_restricted_lindenbaum`) extends a consistent seed to a DeferralRestrictedMCS, staying within deferralClosure.

**Key existing infrastructure**:
- `h_content_subset_deferralClosure` (proven in SuccChainFMCS.lean)
- `predecessor_deferral_seed` (defined in SuccExistence.lean)
- `predecessor_from_deferral_seed_mcs` (proven for general MCS)

The restricted version needs to use `deferral_restricted_lindenbaum` instead of general Lindenbaum.

## Proof Structure

### Required New Theorems

**Phase 1: Symmetric seed construction** (~200 lines)
```lean
-- Mirror of constrained_successor_seed_restricted
def constrained_predecessor_seed_restricted (phi : Formula)
    (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) : Set Formula :=
  h_content u ∪ pastDeferralDisjunctions u

theorem constrained_predecessor_seed_restricted_consistent
    (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_P_top : P_top in u) :
    SetConsistent (constrained_predecessor_seed_restricted phi u h_drm)

theorem constrained_predecessor_seed_restricted_subset_deferralClosure
    (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) :
    constrained_predecessor_seed_restricted phi u h_drm subset deferralClosure phi
```

**Phase 2: Restricted predecessor construction** (~150 lines)
```lean
noncomputable def constrained_predecessor_restricted
    (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_P_top : P_top in u) : Set Formula :=
  deferral_restricted_lindenbaum phi
    (constrained_predecessor_seed_restricted phi u h_drm)
    (constrained_predecessor_seed_restricted_consistent ...)
    (constrained_predecessor_seed_restricted_subset_deferralClosure ...)

theorem constrained_predecessor_restricted_is_mcs ...
theorem constrained_predecessor_restricted_succ ...  -- Succ(predecessor, u)
theorem constrained_predecessor_restricted_f_step ... -- f_content flows forward
```

**Phase 3: Backward chain and P-coherence** (~200 lines)
```lean
structure RestrictedBackwardChainElement (phi : Formula) where
  world : Set Formula
  is_drm : DeferralRestrictedMCS phi world
  has_P_top : P_top in world

noncomputable def restricted_backward_chain
    (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) : Set Formula

theorem restricted_backward_chain_backward_P
    (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
    (n : Nat) (psi : Formula)
    (h_P : Formula.some_past psi in restricted_backward_chain phi M0 n) :
    exists m : Nat, n < m and psi in restricted_backward_chain phi M0 m
```

**Phase 4: Dovetailing into FMCS** (~150 lines)
```lean
noncomputable def restricted_succ_chain_fam
    (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi) : FMCS Int where
  mcs := fun t => if t >= 0 then restricted_forward_chain phi M0 t.toNat
                  else restricted_backward_chain phi M0 (-t).toNat
  is_mcs := ...  -- Extend to full MCS via Lindenbaum

theorem restricted_succ_chain_fam_forward_F ...
theorem restricted_succ_chain_fam_backward_P ...
theorem restricted_succ_chain_fam_temporally_coherent ...
```

**Phase 5: Wiring to construct_bfmcs** (~100 lines)
```lean
-- Use the restricted chain in boxClassFamilies construction
-- This replaces the deprecated SuccChainTemporalCoherent
```

### Estimated Complexity

| Component | Lines | Difficulty | Dependencies |
|-----------|-------|------------|--------------|
| constrained_predecessor_seed_restricted | 80 | Low | Symmetric to existing |
| Seed consistency proof | 120 | Medium | h_content properties |
| constrained_predecessor_restricted | 50 | Low | deferral_restricted_lindenbaum |
| Predecessor properties | 100 | Medium | Mirror of successor proofs |
| restricted_backward_chain | 80 | Low | Symmetric to forward |
| backward_P theorem | 150 | Medium | Uses P-nesting bounds |
| Dovetailing | 100 | Low | Index arithmetic |
| Wiring to construct_bfmcs | 100 | Medium | Integration |
| **Total** | **~780** | Medium | |

## Mathematical Gaps or Risks

### Risk 1: P-nesting boundedness within DeferralRestrictedMCS

**Status**: Already proven (`p_nesting_is_bounded_restricted`, `p_nesting_boundary_restricted`)

**Evidence**: Lines 763-793 in SuccChainFMCS.lean prove P-nesting bounds for RestrictedMCS using the same technique as F-nesting bounds.

### Risk 2: h_content closure properties

**Status**: Partially proven (`h_content_subset_deferralClosure` exists)

**Gap**: Need to verify that h_content properties mirror g_content properties exactly. This is expected due to the symmetric structure of the TM axiom system (temporal_duality rule).

### Risk 3: Transfer-back property for backward chain

**Status**: Forward version proven (`restricted_forward_chain_transfer_back`)

**Gap**: Need symmetric proof for backward chain. Expected to follow the same pattern using DeferralRestrictedMCS maximality.

### Risk 4: Dovetailing index consistency

**Status**: Low risk

**Analysis**: The join at M0 is exact (both chains start from M0). The only subtlety is converting between Nat indices and Int indices, which is straightforward arithmetic.

### Risk 5: Integration with construct_bfmcs

**Status**: Medium risk

**Analysis**: The current `boxClassFamilies` construction uses `SuccChainFMCS` which wraps the (deprecated) temporal coherent chain. We need to either:
1. Create a new `RestrictedSuccChainFMCS` that wraps the restricted chain, or
2. Prove that the restricted chain can be extended to a full SerialMCS (using `DeferralRestrictedSerialMCS.toSerialMCS`) and the temporal coherence properties transfer.

Option 2 is already partially supported by the existing `DeferralRestrictedSerialMCS.extendToMCS_*` theorems.

## Confidence Level

**HIGH** with the following justifications:

1. **Complete symmetry**: The backward construction mirrors the forward construction exactly. Every theorem proven for the forward direction has a symmetric counterpart for the backward direction. The temporal_duality inference rule guarantees this symmetry at the proof level.

2. **Infrastructure exists**: All the building blocks are in place:
   - h_content (defined in TemporalContent.lean)
   - pastDeferralDisjunctions (defined in SuccExistence.lean)
   - predecessor_deferral_seed (defined in SuccExistence.lean)
   - deferral_restricted_lindenbaum (defined in RestrictedMCS.lean)
   - P-nesting boundedness (proven in SuccChainFMCS.lean)

3. **No mathematical obstacles**: Unlike the original SuccChain approach which failed due to the FALSE `f_nesting_is_bounded` theorem, the restricted approach works because F/P-nesting IS bounded within deferralClosure. This is a mathematical FACT, not an assumption.

4. **Clean join point**: The dovetailing at M0 introduces no new consistency concerns because M0 is shared by construction.

5. **Tested pattern**: The `constrained_successor_restricted` construction is already working and sorry-free. The predecessor version is a mechanical mirror.

## References

| File | Lines | Key Content |
|------|-------|-------------|
| `Theories/Bimodal/Syntax/Formula.lean` | 379-412 | `swap_temporal` definition and involution |
| `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` | 371-438 | `sigma_quot` and its properties |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | 2025-2250 | `restricted_forward_chain` and F-coherence |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | 2252-2276 | Backward chain structure and requirements |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | 2454-2458 | Open items list |
| `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` | 587-693 | Predecessor deferral seed definition |
| `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` | 999-1182 | `predecessor_exists` and P-step |
| `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` | 1-200 | `DeferralRestrictedMCS` and properties |
| `Theories/Bimodal/Syntax/SubformulaClosure.lean` | 592-690 | `deferralClosure` definition |
| `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` | 1785-1878 | `construct_bfmcs` (deprecated, target for fix) |

## Summary

Strategy C is the **shortest and most concrete path** to sorry-free completeness. The mathematical foundation is solid (bounded F/P-nesting within deferralClosure), the infrastructure is 80% complete (forward chain is done, backward is symmetric), and the dovetailing construction is mathematically clean. The estimated effort is ~780 lines of new code, mostly mechanical mirroring of existing proofs.

The sigma-duality automorphism provides theoretical backing for why the backward construction must work: it transforms F-coherent chains into P-coherent chains at the algebraic level. However, the implementation uses direct symmetric construction rather than applying sigma to formula sets, because this preserves the DeferralRestrictedMCS property more naturally.
