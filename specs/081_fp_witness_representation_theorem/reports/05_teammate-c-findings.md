# Teammate C Findings: Risk Analysis & Gap Mapping

## Part 1: Sorry-Free Infrastructure Map

### SuccChainFMCS.lean — Restricted Chain Results

| Theorem | Status | Location | Notes |
|---------|--------|----------|-------|
| `restricted_forward_chain_forward_F` | SORRY-FREE | :2930 | F(psi) in chain(n) -> psi in chain(n+1) for Nat-indexed forward chain |
| `restricted_backward_chain_backward_P` | SORRY-FREE | :5462 | P(psi) in chain(n) -> psi in chain(m) for m > n, Nat-indexed backward chain |
| `build_restricted_tc_family` | SORRY-FREE | :5866 | Packages forward_F + backward_P into `RestrictedTemporallyCoherentFamily` |
| `restricted_combined_bounded_witness` | SORRY (fuel=0) | :5544,:5386,:5740 | Three sorry in unreachable fuel=0 branches of fueled recursion |
| `g_content_union_brs_consistent` | SORRY | :1734 | Multi-BRS case; G-wrapping fails for boundary resolution set |
| `augmented_seed_consistent` | SORRY | :1763 | Depends on brs consistency |
| `constrained_successor_seed_restricted_consistent` | SORRY | :2082 | Same dependency chain |
| `restricted_chain_G_propagates` | SORRY | :116 | G^k nesting exceeds deferralClosure; NOT needed for truth lemma |
| `restricted_chain_H_step` | SORRY | :158 | H backward step; NOT needed for truth lemma |

### Key Finding: The fuel=0 sorries at lines 5386, 5544, 5740

These are in unreachable branches of fueled recursion (fuel starts at B*B+1). They are **technically sorry but semantically dead code**. If the fuel bound proof is correct (B*B+1 suffices), these branches never execute. However, Lean's type system doesn't know this -- the sorry still propagates to anything depending on these theorems.

**Impact**: `build_restricted_tc_family` depends on these through `restricted_combined_bounded_witness_fueled` and `restricted_combined_bounded_witness_P_fueled`. So `RestrictedTemporallyCoherentFamily` carries sorry from these fuel=0 branches.

### UltrafilterChain.lean — Bundle-Level Results

| Theorem | Status | Notes |
|---------|--------|-------|
| `construct_bfmcs_bundle` | SORRY-FREE | Builds BFMCS_Bundle with eval_family, modal saturation |
| `boxClassFamilies_modal_forward` | SORRY-FREE | Box coherence forward |
| `boxClassFamilies_modal_backward` | SORRY-FREE | Box coherence backward |
| `boxClassFamilies_bundle_forward_F` | SORRY-FREE | Bundle-level F witness (DIFFERENT family allowed) |
| `boxClassFamilies_bundle_backward_P` | SORRY-FREE | Bundle-level P witness (DIFFERENT family allowed) |
| `construct_bfmcs_bundle_temporally_coherent` | SORRY-FREE | Bundle-level temporal coherence |
| `bundle_forward_F` / `bundle_backward_P` | SORRY-FREE | Definitions allowing cross-family witnesses |

### ParametricTruthLemma.lean

| Theorem | Status | Notes |
|---------|--------|-------|
| `parametric_canonical_truth_lemma` | SORRY-FREE | Requires `h_tc : B.temporally_coherent` (FAMILY-level) |
| `parametric_shifted_truth_lemma` | SORRY-FREE | Same requirement |
| `parametric_box_persistent` | SORRY-FREE | Box phi persists to all times |

### RestrictedTruthLemma.lean

| Theorem | Status | Notes |
|---------|--------|-------|
| `restricted_truth_lemma` | SORRY-FREE | DRM membership <-> Lindenbaum extension membership for subformulaClosure |
| `restricted_truth_at_seed` | SORRY-FREE | Corollary at time 0 |
| `neg_consistent_gives_mcs_without_phi` | SORRY-FREE | Basic Lindenbaum result |
| `restricted_ext_neg_excludes_phi` | SORRY-FREE | Key completeness lemma |

### ParametricRepresentation.lean

| Theorem | Status | Notes |
|---------|--------|-------|
| `parametric_algebraic_representation_conditional` | SORRY-FREE | THE interface: takes `construct_bfmcs` function, produces countermodel |

## Part 2: Minimal Gap Analysis

### What `parametric_algebraic_representation_conditional` Requires

The signature (ParametricRepresentation.lean:252-257):
```lean
construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M ->
  Sigma' (B : BFMCS D) (h_tc : B.temporally_coherent)
         (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
         M = fam.mcs t
```

This requires: given ANY MCS M, produce a BFMCS where:
1. M appears as `fam.mcs t` for some family and time
2. The BFMCS is **family-level** temporally coherent (same-family forward_F and backward_P)

### The Exact Gap

**What exists**: `construct_bfmcs_bundle` produces a BFMCS with bundle-level coherence (cross-family F/P witnesses).

**What's needed**: Family-level coherence (same-family F/P witnesses).

**Why bundle doesn't suffice**: The truth lemma's backward G case (ParametricTruthLemma.lean:322) requires:
```
F(psi) in fam.mcs t -> exists s >= t, psi in fam.mcs s  [SAME fam]
```
Bundle coherence only gives:
```
F(psi) in fam.mcs t -> exists fam' in B.families, exists s > t, psi in fam'.mcs s  [DIFFERENT fam' allowed]
```

### Option Analysis

#### Option A: Full Same-Family forward_F for Arbitrary MCS

**What it is**: The dovetailed construction approach from Plan 04. Build an omega chain from arbitrary MCS M0 that resolves ALL F-obligations within the same chain.

**Mathematical risk**: HIGH. Two fundamental blockers discovered:
1. **H-Blocker G-Lift Problem**: When seeding the successor step with H-blockers (neg(H(chi))), these cannot be G-lifted. `neg(H(chi)) in M` does NOT imply `G(neg(H(chi))) in M`.
2. **F-Persistence Problem**: Even without H-blockers, Lindenbaum extension can freely add G(neg(psi)), permanently killing pending F(psi) obligations. No known way to control Lindenbaum's choices.

**Implementation risk**: VERY HIGH. Would require a custom Lindenbaum construction that deliberately preserves F-obligations -- fundamentally different from the existing Zorn-based `set_lindenbaum`.

**Status**: 605 lines of DovetailedChain.lean, entirely comments/dead ends, zero sorry-free theorems.

#### Option B: Restricted Completeness via RestrictedTemporallyCoherentFamily

**What it is**: Use the existing restricted chain construction that works within `deferralClosure(phi)`, where F/P-nesting IS bounded.

**What exists**:
- `RestrictedTemporallyCoherentFamily` with forward_F and backward_P (SuccChainFMCS.lean:5847)
- `restricted_truth_lemma` establishing DRM <-> extension equivalence (RestrictedTruthLemma.lean:291)
- `restricted_ext_neg_excludes_phi` -- key completeness lemma (RestrictedTruthLemma.lean:381)

**What's missing**: A bridge from `RestrictedTemporallyCoherentFamily` to `BFMCS.temporally_coherent`. The restricted construction gives an Int-indexed chain of DeferralRestrictedMCS (DRM), not full MCS. To use `parametric_algebraic_representation_conditional`, we need:
1. Convert DRM chain to FMCS (requires Lindenbaum extension at each position)
2. Prove the extended FMCS has same-family forward_F/backward_P
3. Build a BFMCS around it with modal saturation

**The sub-gap**: Step 2 is the hard part. Lindenbaum extensions of adjacent DRMs are INDEPENDENT -- there's no guarantee that `lindenbaumMCS(DRM_n)` and `lindenbaumMCS(DRM_{n+1})` satisfy Succ. The restricted chain has Succ at the DRM level, but Lindenbaum destroys this structure.

**Mathematical risk**: MEDIUM. The restricted truth lemma already proves the key equivalence (DRM membership <-> extension membership for closure formulas). A direct completeness argument that avoids converting to BFMCS might work.

**Implementation risk**: MEDIUM. Three fuel=0 sorries need resolution (likely fixable by restructuring the recursion).

#### Option C: Bundle-Level forward_F (Different Family Allowed)

**What it is**: Use `construct_bfmcs_bundle` which already has sorry-free bundle-level temporal coherence.

**Status**: ALREADY EXISTS AND IS SORRY-FREE.

**Why it doesn't work**: Bundle-level coherence is semantically wrong for TM task semantics. The truth lemma requires same-family witnesses. This is documented extensively in:
- ParametricTruthLemma.lean:41-51 (contrapositive argument binds to specific family)
- UltrafilterChain.lean:3192-3212 (semantic warning)
- RestrictedTruthLemma.lean:400-408 (correction note)
- Boneyard/BundleTemporalCoherence/README.md

**Mathematical risk**: N/A -- proven insufficient.

#### Option D: Direct Restricted Completeness (Bypass BFMCS)

**What it is**: Instead of fitting into `parametric_algebraic_representation_conditional`, prove completeness directly from the restricted construction.

**Strategy**:
1. If phi is not provable, neg(phi) is consistent
2. Build `RestrictedTemporallyCoherentFamily` over phi from {neg(phi)}
3. neg(phi) in restricted_chain(0)
4. By `restricted_ext_neg_excludes_phi`: phi NOT in extended MCS at time 0
5. Build a task model directly from the restricted chain (NOT from BFMCS)
6. Prove phi is false in this model

**What's needed**: A truth lemma that works directly on the restricted chain + Lindenbaum extensions, WITHOUT requiring full BFMCS infrastructure.

**Key insight**: The restricted truth lemma (RestrictedTruthLemma.lean:291) already proves:
```
psi in DRM(n) <-> psi in lindenbaumMCS(DRM(n))  [for psi in subformulaClosure(phi)]
```

But for a full countermodel, we need truth evaluation in a TaskModel, which requires:
- A set of world histories (Omega)
- Truth evaluation at each history/time
- Box quantifies over all histories in Omega
- G/H quantify over times in the same history

The restricted chain gives ONE history. For Box, we need multiple histories (modal saturation). This brings us back to needing a BFMCS-like structure.

**Mathematical risk**: MEDIUM-HIGH. Modal saturation is the hard part -- we need box-class agreement across families, and each family needs same-family temporal coherence.

**Implementation risk**: HIGH. Would require building significant new infrastructure parallel to the existing BFMCS framework.

## Part 3: Risk Matrix

| Option | Math Risk | Impl Risk | Existing Code | New Code Needed | Confidence |
|--------|-----------|-----------|---------------|-----------------|------------|
| A: Full dovetailed | VERY HIGH | VERY HIGH | 605 LOC (dead) | Custom Lindenbaum | 5% success |
| B: Restricted->BFMCS | MEDIUM | MEDIUM | ~3000 LOC restricted chain | Bridge + fuel fixes | 40% success |
| C: Bundle-level | N/A | N/A | Complete | None | 0% (wrong semantics) |
| D: Direct restricted | MEDIUM-HIGH | HIGH | RestrictedTruthLemma | New completeness path | 30% success |

## Part 4: Post-Mortem on Plan 04

### What Went Wrong

**1. The H-Blocker G-Lift Problem was foreseeable.**
The plan assumed (line 141): "the F-blockers are F(psi_i) = neg(G(neg(psi_i))) formulas. If the seed is inconsistent... Each F(psi_i) is in M, so we can separate the derivation."

This assumes elements can be G-lifted for the consistency proof. But F(psi) = neg(G(neg(psi))) is NOT G-liftable -- there is no axiom G(neg(G(neg(psi)))) ↔ neg(G(neg(psi))). The plan conflated "F(psi) is in M" with "F(psi) can be G-lifted."

Research Run 2 (report 02) correctly identified same-family as required but didn't analyze the G-lifting limitation. Research Run 4 (report 04) designed the controlled seeding without verifying the consistency proof.

**2. F-Persistence was a known open problem.**
Task #69 report 17 had already proven that F-preserving seeds cannot be shown consistent. The plan acknowledged this history (SuccChainFMCS.lean:1029-1039) but believed the dovetailed/fair-scheduling approach would circumvent it. It didn't -- the fundamental issue is the same: you cannot prevent Lindenbaum from adding G(neg(psi)) without controlling Lindenbaum's choices.

**3. The plan was too ambitious for the mathematical state.**
Four research rounds converged on "dovetailed construction is the right approach" without any of them producing a complete consistency proof sketch. The plan assumed the consistency proof would follow the pattern of `temporal_theory_witness_consistent`, but that theorem only handles g_content + box_content -- NOT arbitrary F-blockers or H-blockers.

### Root Cause

The fundamental issue is that **arbitrary MCS can contain infinitely nested F-obligations** (F(p), F(F(p)), ...) that are all consistent. Any successor construction must either:
- Resolve all of them (requires unbounded chain extension, handled by restricted approach within deferralClosure)
- Preserve them for later resolution (requires controlling Lindenbaum, not currently possible)

The restricted approach works precisely because deferralClosure bounds the nesting depth. The arbitrary MCS approach fails because there's no such bound.

## Part 5: Recommended Path Forward

### Recommendation: Option B with Strategic Simplification

The most promising path is to fix the fuel=0 sorries in the restricted chain and then bridge to BFMCS. Specifically:

**Step 1**: Fix the 3 fuel=0 sorries (lines 5386, 5544, 5740). These are in unreachable branches. Options:
- Prove the fuel bound is sufficient (show recursion depth <= B*B)
- Restructure using well-founded recursion instead of fuel parameter
- Use `Nat.strongRecOn` or similar

**Step 2**: Bridge `RestrictedTemporallyCoherentFamily` to `BFMCS.temporally_coherent`. The key insight that hasn't been explored: instead of independently Lindenbaum-extending each DRM position, use the **same Lindenbaum enumeration** for all positions. This would preserve the Succ structure through extensions.

Alternatively, build a "restricted BFMCS" that uses `boxClassFamilies` for modal saturation but uses the restricted chain (not arbitrary SuccChainFMCS) for each family. Each family would be a restricted chain extended to full MCS, with temporal coherence proven at the DRM level and then transferred via the transfer-back property (SuccChainFMCS.lean:3039).

**Step 3**: Wire to `parametric_algebraic_representation_conditional`.

### Confidence Level

**Overall confidence in completing task 81**: 35-45%.

The restricted chain approach is mathematically sound and mostly implemented. The remaining gap (bridging to BFMCS) is significant but not fundamentally blocked -- unlike the dovetailed approach, there's no known mathematical impossibility. The main risk is Lean formalization complexity.

The fuel=0 sorries are likely fixable (estimated 2-4 hours). The BFMCS bridge is the unknown (estimated 8-16 hours if feasible, could be blocked by new obstacles).
