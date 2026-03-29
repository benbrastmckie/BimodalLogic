# Research Report: Fair Scheduling Approach for Task #67

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-29
**Focus**: Fair scheduling / dovetailing for F-obligation resolution
**Session**: sess_1774803065_3e4319

## Executive Summary

This report provides detailed analysis of the fair scheduling (dovetailing) approach for eliminating the sorry in `bundle_validity_implies_provability`. The approach replaces the current greedy F_top-only resolution with round-robin resolution of ALL F-obligations.

**Key Finding**: The fair scheduling approach is tractable and provides a cleaner termination argument than well-founded recursion restructuring. The main work involves defining a new chain construction that enumerates F-obligations via `Nat.pair`/`Nat.unpair` and maintains a resolved-set invariant.

## 1. Current Architecture Analysis

### 1.1 The Blocker Location

The sorry chain is:
1. `bundle_validity_implies_provability` (Completeness.lean:250)
2. depends on `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:220) - **SORRY HERE**
3. which requires `Z_chain_forward_F` (UltrafilterChain.lean:2424) - **SORRY HERE**

### 1.2 Why Z_chain_forward_F Has Sorry

The current `omega_chain_forward` construction (UltrafilterChain.lean:2027-2045) only resolves `F_top` at each step:

```lean
noncomputable def omega_chain_forward_with_inv
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Nat → { W : Set Formula // OmegaForwardInvariant M0 W }
  | 0 => ⟨M0, ...⟩
  | n + 1 =>
    let prev := omega_chain_forward_with_inv M0 h_mcs0 n
    let h_F_top : F_top ∈ M_n := SetMaximalConsistent.contains_F_top inv_n.is_mcs
    let witness := omega_step_forward M_n inv_n.is_mcs (Formula.neg Formula.bot) h_F_top
    ⟨witness.val, ...⟩
```

**Problem**: If `F(phi)` for arbitrary `phi` is in `Z_chain(t)`, there is no guarantee that `phi` will appear at any future position in the same chain.

### 1.3 The Restricted Chain (SuccChainFMCS.lean) IS Sorry-Free

The `restricted_forward_chain` construction IS sorry-free:

- `restricted_forward_chain_forward_F` (line 3048-3056) proves: for any `F(psi)` in the restricted chain at position `n`, there exists `m > n` with `psi` in the chain at position `m`.
- The underlying `restricted_bounded_witness_wf` (line 2884-2946) uses well-founded recursion with explicit `remaining_steps` parameter.

**Key Insight**: The restricted chain already solves the F-resolution problem within `deferralClosure(phi)`. The gap is connecting this to `Z_chain` in `UltrafilterChain.lean`.

## 2. Fair Scheduling Approach

### 2.1 Core Idea

Replace the greedy `F_top`-only construction with round-robin resolution using Cantor pairing:

```
At step n:
  let (time_index, obligation_index) = Nat.unpair n
  resolve the obligation_index-th F-obligation that exists at time_index
```

This guarantees every F-obligation is eventually resolved by fairness of the enumeration.

### 2.2 Mathlib Infrastructure

The Cantor pairing function is available in `Mathlib.Data.Nat.Pairing`:

| Function | Type | Description |
|----------|------|-------------|
| `Nat.pair` | `Nat → Nat → Nat` | Cantor pairing function |
| `Nat.unpair` | `Nat → Nat × Nat` | Inverse of Nat.pair |
| `Nat.pairEquiv` | `Nat × Nat ≃ Nat` | Bijection proof |
| `Nat.pair_unpair` | `∀ n, pair (unpair n).1 (unpair n).2 = n` | Roundtrip |
| `Nat.unpair_pair` | `∀ a b, unpair (pair a b) = (a, b)` | Roundtrip |

**Import Required**: `import Mathlib.Data.Nat.Pairing`

### 2.3 Proposed Definitions

```lean
/-- Enumerate F-obligations from an MCS at a given time in the chain -/
noncomputable def enumerateFObligations (chain : Nat → Set Formula) (t : Nat) :
    Nat → Option Formula :=
  -- For a finite chain restricted to deferralClosure, f_content is finite
  -- Use Finset.toList ordering on {phi | F(phi) ∈ chain(t)}
  fun i =>
    let F_set := (chain t).fContentFinset  -- Need to define for restricted chains
    if h : i < F_set.card then some (F_set.toList.get ⟨i, by simp [h]⟩) else none

/-- Track which (time, obligation_index) pairs have been resolved -/
structure FairChainState where
  /-- The chain values at each time -/
  chain : Nat → Set Formula
  /-- Set of resolved (time, obligation_index) pairs -/
  resolved : Finset (Nat × Nat)
  /-- Invariant: every resolved obligation has a witness -/
  resolved_has_witness : ∀ p ∈ resolved,
    ∀ phi, enumerateFObligations chain p.1 p.2 = some phi →
    ∃ t' > p.1, phi ∈ chain t'

/-- Fair scheduling chain construction -/
noncomputable def omega_chain_dovetailed
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) : Nat → Set Formula
  | 0 => M0
  | n + 1 =>
    let current := omega_chain_dovetailed M0 h_mcs0 n
    let (time_idx, obl_idx) := Nat.unpair n
    match enumerateFObligations (omega_chain_dovetailed M0 h_mcs0) time_idx obl_idx with
    | none =>
        -- No obligation at this index, just extend via F_top
        omega_step_forward current (chain_mcs n) (neg bot) (chain_has_F_top n)
    | some phi =>
        if h : F phi ∈ current ∧ phi_not_yet_resolved then
          -- Resolve this specific F-obligation
          omega_step_forward current (chain_mcs n) phi h.1
        else
          -- Already resolved or not present, extend via F_top
          omega_step_forward current (chain_mcs n) (neg bot) (chain_has_F_top n)
```

### 2.4 Why This Works

**Fairness Guarantee**: For any `F(phi)` at time `t`:
1. If `F(phi) ∈ chain(t)`, then `phi ∈ f_content(chain(t))`
2. Since `f_content` restricted to `deferralClosure` is finite, `phi` has some index `i`
3. By Cantor pairing, `(t, i)` is enumerated at step `n = Nat.pair t i`
4. At step `n`, we resolve this specific obligation
5. Therefore `phi ∈ chain(n+1)` or some later time

**Termination**: Each step either:
- Resolves a new F-obligation (finite progress through the obligation set)
- Extends via F_top (always valid by seriality)

## 3. Alternative: Leverage Existing Restricted Chain

### 3.1 Key Observation

The restricted chain construction in `SuccChainFMCS.lean` already has sorry-free F-resolution:

```lean
theorem restricted_forward_chain_forward_F (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 n) :
    ∃ m : Nat, n < m ∧ psi ∈ restricted_forward_chain phi M0 m
```

### 3.2 Proposed Approach: Wire Restricted Chain to Z_chain

Instead of building a new dovetailed `omega_chain`, we can:

1. Define `Z_chain_restricted` as the Lindenbaum extension of `restricted_forward_chain`
2. Prove `Z_chain_restricted_forward_F` by lifting `restricted_forward_chain_forward_F`
3. Use `Z_chain_restricted` in the completeness proof

**Key Lemma Needed**:
```lean
-- The Lindenbaum extension preserves membership for deferralClosure formulas
theorem lindenbaum_extension_preserves_deferralClosure
    (phi psi : Formula) (M : Set Formula)
    (h_drm : DeferralRestrictedMCS phi M)
    (h_psi_dc : psi ∈ deferralClosure phi)
    (ext : Set Formula)
    (h_ext_mcs : SetMaximalConsistent ext)
    (h_ext_superset : M ⊆ ext) :
    psi ∈ M ↔ psi ∈ ext
```

This follows from DeferralRestrictedMCS maximality: if `psi ∈ deferralClosure phi` and `psi ∉ M`, then `{psi} ∪ M` is inconsistent, contradicting `ext ⊇ M ∪ {psi}` being consistent.

### 3.3 Comparison

| Approach | Complexity | Code Changes | Termination Proof |
|----------|------------|--------------|-------------------|
| New Dovetailed Chain | Medium | UltrafilterChain.lean ~200 lines | Cantor pairing fairness |
| Wire Restricted Chain | Lower | Bridge lemmas ~50 lines | Already done (restricted_bounded_witness_wf) |

**Recommendation**: The "Wire Restricted Chain" approach is simpler because termination is already proven. The main work is the bridge lemma connecting restricted chain membership to full MCS membership.

## 4. Concrete Implementation Steps

### 4.1 Option A: Fair Scheduling (Full Dovetailing)

**Phase B1: Define Fair Scheduling Infrastructure** (3-4 hours)
1. Import `Mathlib.Data.Nat.Pairing`
2. Define `f_content_deferralClosure : Finset Formula` for restricted chains
3. Define `enumerateFObligations` using Finset.toList
4. Define `FairChainInvariant` structure

**Phase B2: Build Dovetailed Chain** (4-6 hours)
1. Define `omega_chain_dovetailed` with round-robin resolution
2. Prove invariant preservation through each step
3. Prove G-theory and box-class preservation
4. Prove `omega_chain_dovetailed_forward_F` via fairness

**Phase B3: Wire to Completeness** (2-3 hours)
1. Update `Z_chain` to use dovetailed construction
2. Prove `Z_chain_forward_F` using dovetailed chain
3. Complete `bfmcs_from_mcs_temporally_coherent`
4. Verify `bundle_validity_implies_provability` compiles without sorry

### 4.2 Option B: Wire Restricted Chain (Recommended)

**Phase R1: Lindenbaum Bridge Lemmas** (2-3 hours)
1. Prove `lindenbaum_extension_preserves_deferralClosure`
2. Prove `DeferralRestrictedSerialMCS.extendToMCS_transfer_back`:
   ```lean
   psi ∈ deferralClosure phi → psi ∈ M.extendToMCS → psi ∈ M.world
   ```
3. These lemmas exist partially in SuccChainFMCS.lean (lines 3136-3146)

**Phase R2: Lifted Chain Construction** (2-3 hours)
1. Define `restricted_Z_chain` as `n ↦ (restricted_forward_chain M0 n).extendToMCS`
2. Prove `restricted_Z_chain_mcs`: each point is a full MCS
3. Prove `restricted_Z_chain_box_class`: box-class agrees with M0
4. Prove `restricted_Z_chain_G_theory`: G-formulas propagate

**Phase R3: Forward_F via Transfer** (2-3 hours)
1. Prove `restricted_Z_chain_forward_F`:
   - Given: `F(psi) ∈ restricted_Z_chain t`
   - By transfer-back (if `F(psi) ∈ deferralClosure phi`): `F(psi) ∈ restricted_forward_chain t`
   - By `restricted_forward_chain_forward_F`: `∃ m > t, psi ∈ restricted_forward_chain m`
   - By extension: `psi ∈ restricted_Z_chain m`

**Phase R4: Complete bfmcs_from_mcs_temporally_coherent** (1-2 hours)
1. Wire `restricted_Z_chain_forward_F` to `bfmcs_from_mcs_temporally_coherent`
2. Similarly for backward_P (symmetric construction)
3. Verify completeness theorem compiles without sorry

## 5. Critical Dependencies

### 5.1 What Already Exists (Sorry-Free)

| Component | Location | Status |
|-----------|----------|--------|
| `restricted_forward_chain` | SuccChainFMCS.lean:2617 | Sorry-free |
| `restricted_forward_chain_forward_F` | SuccChainFMCS.lean:3048 | Sorry-free |
| `restricted_bounded_witness_wf` | SuccChainFMCS.lean:2884 | Sorry-free |
| `DeferralRestrictedSerialMCS.extendToMCS` | SuccChainFMCS.lean:3097 | Sorry-free |
| `extendToMCS_extends` (M ⊆ ext) | SuccChainFMCS.lean:3114 | Sorry-free |
| `deferralClosure` (finite) | SubformulaClosure.lean:695 | Sorry-free |
| `F_top_mem_deferralClosure` | SubformulaClosure.lean:744 | Sorry-free |

### 5.2 What Needs to Be Built

| Component | Required For | Approach |
|-----------|--------------|----------|
| Transfer-back lemma | Connecting restricted to full | DRM maximality argument |
| Backward chain construction | P-obligations | Symmetric to forward |
| `bfmcs_from_mcs_temporally_coherent` | Final theorem | Wire forward_F + backward_P |

## 6. Technical Details

### 6.1 The Transfer-Back Argument

For DeferralRestrictedMCS `M` with extension `ext`:

```
Given: psi ∈ deferralClosure phi, psi ∈ ext
Goal: psi ∈ M

Proof by contradiction:
- Suppose psi ∉ M
- By DRM maximality: {psi} ∪ M is inconsistent with deferralClosure phi
- But ext ⊇ M ∪ {psi} and ext is consistent
- Contradiction (any consistent extension would be inconsistent)
```

This is partially stated at SuccChainFMCS.lean:3136-3146:
> "if psi ∈ deferralClosure and psi ∉ M, then insert psi M is inconsistent.
> But ext(M) ⊇ M ∪ {psi} is consistent, so psi ∉ M leads to contradiction."

### 6.2 Finiteness of F-Obligations

For `deferralClosure phi`:
- `deferralClosure phi` is a `Finset Formula` (always finite)
- `f_content (deferralClosure phi)` = `{psi | F(psi) ∈ deferralClosure phi}` is also finite
- Enumeration via `Finset.toList` is well-defined

### 6.3 Backward Chain (P-Obligations)

The backward construction is symmetric:
- `restricted_backward_chain` (needs to be built, structure at SuccChainFMCS.lean:3073-3083)
- Uses `constrained_predecessor_restricted` (noted as required at line 3061-3070)
- Follows the same pattern as forward chain

## 7. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Transfer-back lemma harder than expected | Low | Medium | Argument is already sketched in code |
| Backward chain needs significant work | Medium | Medium | Structure exists, follow forward pattern |
| Box-class agreement through extension | Low | Low | Already proven for forward direction |
| Integration with existing BFMCS | Low | Low | Clean interface via bundle_to_bfmcs |

## 8. Recommendations

1. **Primary Approach**: Wire Restricted Chain (Option B)
   - Lower complexity, termination already proven
   - Main work: transfer-back lemma + backward chain

2. **Fallback**: Fair Scheduling (Option A)
   - Only if backward chain construction proves difficult
   - More mathematically principled but higher implementation cost

3. **Immediate Next Steps**:
   - Prove `lindenbaum_extension_preserves_deferralClosure`
   - Build backward restricted chain (follow forward pattern)
   - Wire both directions to `bfmcs_from_mcs_temporally_coherent`

## 9. References

- Plan 06: specs/067_prove_bundle_validity_implies_provability/plans/06_well-founded-recursion.md
- Team Research 20: specs/067_prove_bundle_validity_implies_provability/reports/20_team-research.md
- SuccChainFMCS.lean: Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean
- UltrafilterChain.lean: Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean
- Completeness.lean: Theories/Bimodal/FrameConditions/Completeness.lean
- Segerberg 1970 "bulldozing" technique (referenced in Plan 06)
