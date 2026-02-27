# Research Report 001: Alternative Canonical Constructions and Cleanup Candidates

**Task**: 933 - research_alternative_canonical_construction
**Session**: sess_1772092346_98019a
**Date**: 2026-02-25
**Purpose**: Identify Boneyard candidates in Chain A, catalog cleanup opportunities, and research alternative canonical model constructions to resolve the F-formula persistence problem.

## 1. Executive Summary

The completeness proof chain has three remaining sorry locations:
1. `DovetailingChain.lean:1869` - `forward_F` (F-formula witness in linear chain)
2. `DovetailingChain.lean:1881` - `backward_P` (P-formula witness in linear chain)
3. `TemporalCoherentConstruction.lean:600` - `fully_saturated_bfmcs_exists_int` (combining temporal coherence + modal saturation)

The fundamental blocker is that the DovetailingChain (linear Int-indexed construction) cannot resolve F/P-formula obligations because F-formulas do not persist through GContent seeds. The CanonicalMCS approach (all-MCS domain) resolves forward_F and backward_P sorry-free but uses a non-total Preorder domain instead of Int. The central challenge is bridging between the sorry-free CanonicalMCS construction and the Int-indexed domain required by the completeness chain.

**Key finding**: The most promising path is to restructure completeness to use `D = CanonicalMCS` (Preorder) rather than `D = Int` (LinearOrderedAddCommGroup), sidestepping the DovetailingChain entirely. This requires a nontrivial but well-scoped redesign of the bmcs_truth_at and validity definitions.

## 2. Boneyard Candidates in Chain A

### 2.1 Already Moved to Boneyard (Task 931/932)

The following have already been moved to `Theories/Bimodal/Boneyard/`:

| Symbol/File | Boneyard Location | Reason |
|------------|-------------------|--------|
| `bmcs_truth_at_mcs` + 13 symbols | `Boneyard/Bundle/MCSMembershipCompleteness.lean` | Non-standard box semantics (MCS membership instead of recursive truth) |
| `ChainBundleBFMCS.lean` `_mcs` section | `Boneyard/Metalogic_v7/Bundle/ChainBundleBFMCS.lean` | Duplicate completeness chain using wrong validity notion |
| `singleFamilyBFMCS` | `Boneyard/Metalogic_v7/Bundle/SingleFamilyBFMCS.lean` | Single-family modal backward is unprovable |
| Constant witness families | `Boneyard/Metalogic_v7/Bundle/ConstantWitnessFamily_ModalSaturation.lean` | Constant families cannot satisfy forward_F/backward_P |
| `TemporalEvalSaturatedBundle` | `Boneyard/Metalogic_v7/Bundle/TemporalSaturationBundle.lean` | Temporal saturation of single MCS is impossible |
| Generic `temporal_coherent_family_exists` | `Boneyard/Metalogic_v7/Bundle/TemporalSaturationBundle.lean` | Only D=Int is instantiated |
| Polymorphic `fully_saturated_bfmcs_exists` | `Boneyard/Metalogic_v7/Bundle/TemporalSaturationBundle.lean` | Axiom in trusted kernel; replaced by sorry-backed theorem |

### 2.2 Remaining Boneyard Candidates

#### 2.2.1 Dead Code: `eval_bmcs_*` in BFMCSTruth.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean`
**Status**: Dead code. Zero external references. The corresponding `eval_bmcs_truth_lemma` was already removed in task 912.

Affected definitions (no longer referenced outside BFMCSTruth.lean itself):
- `bmcs_truth_eval` (line 219) - shorthand for truth at eval_family
- `bmcs_truth_eval_of_all` (line 225) - if true at all families, true at eval

These are NOT non-standard (they use correct recursive truth) but are unused helpers. **Recommendation**: Low priority cleanup; can be removed when touching the file for other reasons.

#### 2.2.2 Legacy CanonicalReachable FMCS in CanonicalFMCS.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` (lines 297-398)

The following are explicitly marked "Legacy" in their docstrings:
- `canonicalReachableBFMCS_mcs` (line 303)
- `canonicalReachableBFMCS_is_mcs` (line 310)
- `canonicalReachableBFMCS_forward_G` (line 318)
- `canonicalReachableBFMCS_backward_H` (line 328)
- `canonicalReachableBFMCS` (line 340) - the FMCS construction
- `CanonicalReachable.instZero` (line 352)
- `canonicalReachableBFMCS_forward_F` (line 359)
- `canonicalReachableBFMCS_root_contains` (line 373)

Additionally, legacy quotient definitions:
- `canonicalBFMCS_mcs` (line 389) - quotient MCS accessor
- `CanonicalQuotient.instZero` (line 396) - quotient zero

**Recommendation**: These are superseded by the `canonicalMCS*` definitions (the all-MCS approach). They should be moved to Boneyard since the all-MCS approach is strictly superior (supports both forward_F AND backward_P sorry-free, while CanonicalReachable is blocked on backward_P). However, they are referenced by CanonicalQuotient.lean and CanonicalReachable.lean, so the entire CanonicalReachable/CanonicalQuotient stack would need to be assessed for active usage.

#### 2.2.3 CanonicalReachable.lean and CanonicalQuotient.lean

**Files**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean`

These form a complete chain: CanonicalReachable (total preorder via CanonicalR) -> CanonicalQuotient (LinearOrder via Antisymmetrization). This was the Task 922 approach to get a LinearOrder for Int embedding.

**Assessment**: The CanonicalReachable approach has a fundamental blocker: backward_P witnesses are not necessarily future-reachable from M_0. The all-MCS approach (`canonicalMCSBFMCS`) resolves this. However, the CanonicalQuotient provides a `LinearOrder`, which is needed if the goal is to embed into Int. These files represent the remnant of an approach that was partially superseded.

**Recommendation**: Move to Boneyard. They represent an intermediate approach that is no longer on the critical path. The import chain is:
- `CanonicalReachable.lean` imports `CanonicalFrame.lean` (keep), `CanonicalEmbedding.lean` (assess)
- `CanonicalQuotient.lean` imports `CanonicalReachable.lean`
- `CanonicalFMCS.lean` imports `CanonicalQuotient.lean` (for legacy defs only)

#### 2.2.4 CanonicalEmbedding.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean`

This file establishes the linear ordering on CanonicalReachable (total preorder) and provides infrastructure for embedding into Int. It is imported by `CanonicalReachable.lean` and `CanonicalFMCS.lean`.

**Assessment**: If CanonicalReachable is moved to Boneyard, this becomes orphaned as well (its primary consumer is gone). However, some results (like `canonical_reachable_linear` proving totality of CanonicalR within a CanonicalR-chain) may have independent value.

**Recommendation**: Move to Boneyard together with CanonicalReachable and CanonicalQuotient as a batch.

#### 2.2.5 DovetailingChain.lean - The F/P Sorry Section

**File**: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
**Lines**: The entire file (1909 lines) represents the dovetailing construction.

**Assessment**: This file is NOT a Boneyard candidate in its entirety -- it is actively used by `TemporalCoherentConstruction.lean` via `temporal_coherent_family_exists_theorem`. However, it has 2 sorries that are documented as fundamentally unresolvable within the linear chain approach. The file's docstring (line 1851-1864) explicitly lists 6 blocked approaches and points to omega-squared as the resolution path.

**Recommendation**: Do NOT move to Boneyard. Instead, the resolution path should replace the linear DovetailingChain with an alternative construction. See Section 4 below.

### 2.3 Standard vs. Non-Standard Validity Summary

After tasks 931 and 932, the standard validity chain is clean:

| Definition | File | Status |
|-----------|------|--------|
| `truth_at` | `Semantics/Truth.lean` | STANDARD - Kripke truth |
| `valid` | `Semantics/Validity.lean:71` | STANDARD - Universal validity |
| `bmcs_truth_at` | `Bundle/BFMCSTruth.lean:87` | LEGITIMATE - Henkin truth (recursive box) |
| `bmcs_valid` | `Bundle/BFMCSTruth.lean:107` | LEGITIMATE - BFMCS validity |
| `bmcs_truth_lemma` | `Bundle/TruthLemma.lean:260` | PROVEN - Sorry-free |

All non-standard definitions (`bmcs_truth_at_mcs`, `bmcs_valid_mcs`, etc.) are in the Boneyard.

## 3. Sorry Inventory and Dependency Analysis

### 3.1 Active Sorries in Bundle/

| # | File | Line | Symbol | Nature |
|---|------|------|--------|--------|
| 1 | `DovetailingChain.lean` | 1869 | `buildDovetailingChainFamily_forward_F` | F-formula witness in linear chain |
| 2 | `DovetailingChain.lean` | 1881 | `buildDovetailingChainFamily_backward_P` | P-formula witness in linear chain |
| 3 | `TemporalCoherentConstruction.lean` | 600 | `fully_saturated_bfmcs_exists_int` | Combining temporal coherence + modal saturation |

### 3.2 Dependency Chain

```
Completeness.lean (SORRY-FREE)
  bmcs_representation uses construct_saturated_bfmcs_int
    -> fully_saturated_bfmcs_exists_int (SORRY #3)
      -> Needs: temporal coherence + modal saturation

  bmcs_truth_lemma requires B.temporally_coherent
    -> construct_saturated_bfmcs_int_temporally_coherent
      -> fully_saturated_bfmcs_exists_int (SORRY #3)

The sorry #3 combines two requirements:
  (a) temporal coherence -> temporal_coherent_family_exists_Int
    -> temporal_coherent_family_exists_theorem (DovetailingChain)
      -> forward_F (SORRY #1), backward_P (SORRY #2)
  (b) modal saturation -> saturated_modal_backward (SORRY-FREE)
```

### 3.3 The Core Problem

The three sorries reduce to one fundamental problem:

**How to build a BFMCS indexed by Int (or another suitable type) that is simultaneously:**
1. **Temporally coherent**: Each family has forward_F and backward_P
2. **Modally saturated**: Every Diamond formula has a witness family

The difficulty is that:
- Temporal coherence for a single family requires F/P witnesses at different times (non-constant family)
- Modal saturation requires adding new witness families for Diamond formulas
- New witness families need to be temporally coherent too
- The current DovetailingChain produces a single temporally coherent family for the eval family, but constant witness families for Diamond witnesses cannot satisfy forward_F/backward_P

## 4. Alternative Canonical Constructions

### 4.1 Approach A: CanonicalMCS-Based Completeness (Most Promising)

**Idea**: Use `D = CanonicalMCS` (the type of all MCS with CanonicalR Preorder) as the temporal domain, instead of `D = Int`.

**What exists already**:
- `canonicalMCSBFMCS` (CanonicalFMCS.lean:158) - Sorry-free FMCS over all MCS
- `canonicalMCS_forward_F` (CanonicalFMCS.lean:196) - SORRY-FREE forward F
- `canonicalMCS_backward_P` (CanonicalFMCS.lean:214) - SORRY-FREE backward P
- `temporal_coherent_family_exists_CanonicalMCS` (CanonicalFMCS.lean:267) - SORRY-FREE existence

**What's needed**:
1. A `BFMCS CanonicalMCS` that is both temporally coherent and modally saturated
2. The `bmcs_truth_at` definition already works for any `D` with `Preorder D`
3. The `bmcs_truth_lemma` already works for any `D` with `Preorder D` and `Zero D`
4. Completeness.lean needs `BFMCS Int` -- this would need to be changed to `BFMCS CanonicalMCS`

**Key insight**: With D = CanonicalMCS, EVERY FMCS is the identity mapping (canonicalMCSBFMCS). So a BFMCS over CanonicalMCS would have `families = {canonicalMCSBFMCS}` (a singleton!). The modal coherence conditions become:
- `modal_forward`: Box phi in canonicalMCSBFMCS.mcs t = t.world implies phi in canonicalMCSBFMCS.mcs t' = t'.world for all t'
- `modal_backward`: phi in t'.world for all t' implies Box phi in t.world

These are exactly the S5 modal coherence conditions on CanonicalMCS, which are established by the Box/Diamond MCS properties.

**Estimated effort**: Medium. Requires:
1. Constructing a `BFMCS CanonicalMCS` with the singleton family and proving modal coherence
2. Proving temporal coherence of canonicalMCSBFMCS (already done: `temporal_coherent_family_exists_CanonicalMCS`)
3. Modifying `Completeness.lean` to use `BFMCS CanonicalMCS` instead of `BFMCS Int`
4. Modifying or extending `Validity.lean`'s `valid` definition to quantify over Preorder domains (or proving that BFMCS-validity over CanonicalMCS implies standard validity)

**Critical question**: The standard `valid` definition in Validity.lean quantifies over `LinearOrderedAddCommGroup D` and uses `TaskFrame D` / `TaskModel F` / `WorldHistory F`. The BFMCS completeness proves derivability iff `bmcs_valid`, not iff `valid`. The bridge between `bmcs_valid` and `valid` is the soundness theorem (separate). If `bmcs_valid_CanonicalMCS` replaces `bmcs_valid_Int`, the bridge to standard validity remains unchanged in logical structure.

**Risk**: CanonicalMCS is a Preorder, not a LinearOrderedAddCommGroup. The standard validity requires the latter. But completeness only needs to show that bmcs_valid implies derivable, which it does via contraposition. The direction that needs D = specific type is the representation theorem: "if consistent, then satisfiable in some BFMCS". Using CanonicalMCS here is fine because we just need SOME model.

### 4.2 Approach B: Flag-Based BFMCS (Variant of Approach A)

**Idea**: Use `ChainFMCSDomain flag` (elements of a maximal chain/Flag in CanonicalMCS) as the temporal domain.

**What exists already**:
- `chainFMCS flag` (ChainFMCS.lean:615) - Sorry-free FMCS over a Flag
- `chainFMCS_forward_G`, `chainFMCS_backward_H` - Sorry-free
- `chainFMCS_forward_F_in_CanonicalMCS`, `chainFMCS_backward_P_in_CanonicalMCS` - Witnesses exist in CanonicalMCS but NOT necessarily in the same Flag
- `chainFMCS_pairwise_comparable` - Total order within a Flag

**Advantage over Approach A**: The domain is a total order (all elements comparable), which is closer to Int semantics.

**Disadvantage**: F/P witnesses may leave the Flag. The forward_F witness from `canonical_forward_F` is a general CanonicalMCS element, not necessarily in the same Flag. So `forward_F` for `chainFMCS` would require showing the witness is in the Flag, which is NOT guaranteed.

**Assessment**: This approach encounters the same fundamental problem as the DovetailingChain -- witnesses may not be in the chosen total order. It is NOT recommended.

### 4.3 Approach C: Omega-Squared Construction

**Idea**: Build an Int-indexed chain using an omega-squared (omega x omega) enumeration that processes F-obligations immediately when they appear, before Lindenbaum extension can introduce conflicting G(neg(psi)) formulas.

**Status**: Mentioned in DovetailingChain.lean docstring as the resolution path. No implementation exists yet.

**How it works**:
1. At each step n of the dovetailing construction, after building M_t:
   - Enumerate all F-obligations in M_t: {F(psi_1), F(psi_2), ...}
   - For each F(psi_i), immediately place psi_i at a fresh future time index
   - The key is that psi_i is placed BEFORE any Lindenbaum extension at that time
2. The omega-squared encoding processes (time, formula_index) pairs

**Risk assessment**: This is the approach documented in the codebase (Task 916 plan v012). It addresses the specific technical blocker (F-formulas not persisting through GContent seeds) but adds significant complexity to the already-large DovetailingChain.lean (1909 lines).

**Estimated effort**: High. The DovetailingChain is already complex; adding omega-squared enumeration would roughly double the proof effort. The consistency arguments become more intricate because the seed at each time depends on ALL prior F-obligations, not just GContent.

### 4.4 Approach D: Direct CanonicalMCS BFMCS Construction (Recommended)

**Idea**: This is the concrete implementation of Approach A. Build a BFMCS over CanonicalMCS as follows:

```
Structure:
  families = {canonicalMCSBFMCS}  (singleton set containing the identity FMCS)
  eval_family = canonicalMCSBFMCS

Modal coherence:
  modal_forward: Box phi in canonicalMCSBFMCS.mcs w (= w.world) for some w
    implies phi in canonicalMCSBFMCS.mcs w' (= w'.world) for all w'
    This holds by S5 axiom 5 + temporal perpetuity (Box phi -> H(Box phi) and Box phi -> G(Box phi))
    combined with CanonicalR definition.

  modal_backward: phi in w'.world for all w' implies Box phi in w.world
    This requires proving that if phi is in EVERY MCS, then Box phi is in every MCS.
    This follows from the K axiom + necessitation: if phi is a theorem (in every MCS),
    then Box phi is a theorem (in every MCS).

    BUT WAIT: the quantification is over ALL CanonicalMCS elements, i.e., ALL MCS.
    If phi is in every MCS, that means phi is derivable (by Lindenbaum completeness).
    Then Box phi is derivable by necessitation. So Box phi is in every MCS.
```

**Critical issue with singleton BFMCS**: The BFMCS modal_backward condition requires: "if phi is in ALL families' MCSes at time t, then Box phi is in each family's MCS at time t." With a singleton family, this becomes: "if phi is in canonicalMCSBFMCS.mcs t = t.world, then Box phi is in t.world." This is `phi in MCS => Box phi in MCS`, which is EXACTLY the old `singleFamily_modal_backward_axiom` that was proven FALSE and removed in Task 905.

**Resolution**: The singleton approach does NOT work for modal_backward. We need MULTIPLE families in the BFMCS.

### 4.5 Approach E: CanonicalMCS Multi-Family BFMCS (Revised)

**Idea**: Use CanonicalMCS as the temporal domain, but with MULTIPLE families. Each Diamond(psi) obligation in an MCS gets a witness family.

**Construction**:
1. Start with `canonicalMCSBFMCS` as the eval family
2. For each Diamond(psi) formula in any family's MCS at any time t:
   - The witness MCS W = Lindenbaum({psi} union BoxContent(t.world)) exists by `modal_witness_seed_consistent`
   - Create a witness FMCS over CanonicalMCS using W at time t and the identity mapping elsewhere
   - BUT: this witness FMCS must be temporally coherent too

**The core difficulty persists**: Witness families need to be temporally coherent. With D = CanonicalMCS, a witness FMCS could be defined as:
- `mcs(w) = w.world` for w != special_point
- `mcs(special_point) = W` (the Diamond witness MCS)

But this breaks the FMCS requirement that `mcs(w)` must be maximal consistent FOR ALL w, and the forward_G/backward_H conditions would fail at the boundary between W and the identity mapping.

**Alternative**: Use `canonicalMCSBFMCS` for ALL families, but with a DIFFERENT evaluation point for each witness family. I.e., all families are the same FMCS (identity mapping on CanonicalMCS), but the bundle contains multiple references to it at different evaluation roots.

BUT: families is a `Set (FMCS D)`, so the same FMCS appears only once in the set. The BFMCS structure does not distinguish different "evaluation points" within a family.

### 4.6 Approach F: CanonicalMCS with Inherent Modal Saturation (Most Promising Path)

**Key insight**: With D = CanonicalMCS and the identity FMCS, the box case of the truth lemma becomes:

```
bmcs_truth_at B fam t (box phi)
  = forall fam' in B.families, bmcs_truth_at B fam' t phi
```

If `B.families = {canonicalMCSBFMCS}` (singleton), this simplifies to:
```
bmcs_truth_at B canonicalMCSBFMCS t (box phi)
  = bmcs_truth_at B canonicalMCSBFMCS t phi
```

This makes box phi equivalent to phi, which is wrong.

**The multi-family approach requires different families**. Since FMCS D maps each time t to an MCS, two FMCS instances are different if they assign different MCS to some time point. With D = CanonicalMCS, we could have:
- `fam_1.mcs(w) = w.world` (identity)
- `fam_2.mcs(w) = sigma(w).world` for some permutation sigma

But this doesn't naturally arise from the completeness construction.

**Revised key insight**: The problem is that with D = CanonicalMCS, there is essentially only one natural FMCS (the identity), which forces a singleton bundle. This makes modal backward fail.

### 4.7 Approach G: Quotient of CanonicalMCS with Modal Equivalence Classes

**Idea**: Define an equivalence relation on CanonicalMCS that collapses modally equivalent MCS, then use the quotient as the temporal domain while tracking modal "worlds" separately.

This is essentially the standard canonical model approach for S5 temporal logic:
- **Worlds** = equivalence classes under modal equivalence (~_box: M ~ N iff BoxContent(M) = BoxContent(N))
- **Times** = elements within each equivalence class, ordered by CanonicalR
- **BFMCS families** = one family per equivalence class

**Construction**:
1. For each modal equivalence class C, define `fam_C.mcs(t) = t.world` for t in C
2. This gives multiple families (one per class)
3. Modal forward: Box phi in fam_C.mcs(t) implies phi in fam_C'.mcs(t) for all C'
   - This requires: Box phi in t.world implies phi in t'.world for t' in different class
   - By S5: Box phi in any MCS implies phi in all MCS
   - Wait, that's too strong -- Box phi doesn't hold in ALL MCS

**Problem**: The equivalence classes under BoxContent equality are indeed different families, but the inter-family modal coherence (modal_forward) requires: if Box phi is in t.world (in class C), then phi is in all t'.world for t' in class C'. This is exactly what CanonicalR provides (GContent subset), but only for comparable elements.

**Assessment**: This approach essentially reconstructs the full canonical model theory. It might work but requires substantial new infrastructure. Not recommended as a short path.

### 4.8 Summary of Approaches

| Approach | Sorries Eliminated | Effort | Risk | Recommended? |
|----------|-------------------|--------|------|--------------|
| A: CanonicalMCS domain | All 3 | Medium | Modal backward fails for singleton | **NO** (singleton issue) |
| B: Flag-based | 0 (F/P witnesses escape) | Medium | Same blocker as DovetailingChain | NO |
| C: Omega-squared | 2 (DovetailingChain) | High | Technically sound but complex | MAYBE |
| D: Singleton CanonicalMCS BFMCS | Attempted | Low | modal_backward is FALSE | NO |
| E: Multi-family CanonicalMCS | Potentially all 3 | High | Witness family coherence | MAYBE |
| F: Inherent modal saturation | Attempted | N/A | Singleton forces box=identity | NO |
| G: Modal equivalence quotient | Potentially all 3 | Very High | Major new infrastructure | NO |

## 5. Recommended Path Forward

### 5.1 Best Option: Restructure for CanonicalMCS with Chain-Based Families

The most promising path combines insights from Approaches A and B with the existing ChainFMCS infrastructure:

1. **Use `D = CanonicalMCS` (Preorder)** as the temporal domain
2. **Each family is a chain-based FMCS** (`chainFMCS flag` for some Flag in CanonicalMCS)
3. **The bundle consists of multiple chains** (one per Flag needed for modal saturation)
4. **Modal forward/backward** follows from BoxContent propagation across chains

**Why this might work**:
- Each chainFMCS has sorry-free forward_G and backward_H
- Forward_F and backward_P are available at the CanonicalMCS level (witnesses exist as CanonicalMCS elements)
- The chain (Flag) provides a total order within each family
- Multiple Flags provide the inter-family structure needed for modal saturation

**The remaining challenge**: Forward_F/backward_P witnesses for a chainFMCS(flag) may not be in the same Flag. This means the FMCS-level forward_F is not directly available within a single chain. However, `BFMCS.temporally_coherent` only requires forward_F and backward_P at the FMCS level -- and if D = CanonicalMCS with identity mapping, then forward_F follows from `canonical_forward_F` which IS sorry-free.

**WAIT**: If each family is a chainFMCS, it maps each `ChainFMCSDomain flag` element to an MCS. But the BFMCS requires all families to have the same domain D. So if D = CanonicalMCS, then each family maps ALL CanonicalMCS elements to MCS. A chainFMCS only naturally maps elements within a Flag. We'd need to extend it to all of CanonicalMCS.

**Resolution**: Use `canonicalMCSBFMCS` (the identity FMCS on all CanonicalMCS) as EVERY family. Since `families : Set (FMCS D)` and all families are the same, we have a singleton again. Back to the modal backward problem.

### 5.2 Revised Best Option: Fix fully_saturated_bfmcs_exists_int Directly

Given the analysis above, the most pragmatic path is to fix sorry #3 (`fully_saturated_bfmcs_exists_int`) directly by combining:

1. **Temporal coherence**: Use DovetailingChain for the eval family (2 sorries but works structurally)
2. **Modal saturation**: Use `modal_witness_seed_consistent` + Lindenbaum for witness families
3. **Witness family temporal coherence**: Each witness family uses its OWN DovetailingChain construction

**Concretely**:
- For the eval family: build via DovetailingChain (has forward_F/backward_P sorries)
- For each Diamond(psi) witness: start a new DovetailingChain from the witness MCS W = Lindenbaum({psi} union BoxContent(eval.mcs t))
- Each witness family's DovetailingChain independently satisfies forward_G, backward_H, and (with sorries) forward_F, backward_P

**This reduces sorry #3 to sorries #1 and #2**: If DovetailingChain's forward_F and backward_P were sorry-free, then fully_saturated_bfmcs_exists_int would be provable.

### 5.3 The Omega-Squared Path (For Resolving Sorries #1 and #2)

The documented resolution path for sorries #1 and #2 is the omega-squared construction:

1. Process each time step t via dovetailing (as now)
2. At each step, ALSO enumerate F-obligations at previously-built times
3. Place F-witnesses at fresh future indices BEFORE Lindenbaum extension
4. This prevents Lindenbaum from introducing G(neg(psi)) that would block F(psi)

**Prerequisite**: `temporal_witness_seed_consistent` (PROVEN) ensures {psi} union GContent(M) is consistent.

**Complexity**: The omega-squared enumeration is well-understood mathematically but significantly increases proof complexity in Lean.

## 6. Other Cleanup Candidates Outside Chain A

### 6.1 Dead Boneyard References in Existing Code

Several files reference archived constructions in their docstrings:
- `DovetailingChain.lean` line 76: references `TemporalChain.lean` (already in Boneyard)
- `Construction.lean`: multiple `REMOVED` sections referencing task 932 archival

These are documentation artifacts, not code issues. Low priority.

### 6.2 CanonicalReachable/CanonicalQuotient Stack

As detailed in Section 2.2.3-2.2.4, the CanonicalReachable -> CanonicalQuotient -> CanonicalFMCS (legacy section) chain represents an intermediate approach. The active code path goes through `canonicalMCSBFMCS` (all-MCS domain) instead. The legacy definitions are still imported but not used by the active completeness chain.

**Recommendation**: Move CanonicalReachable.lean, CanonicalQuotient.lean, CanonicalEmbedding.lean, and the legacy section of CanonicalFMCS.lean to Boneyard as a batch. Keep the active CanonicalMCS/canonicalMCSBFMCS definitions.

### 6.3 DovetailingChain Length and Complexity

DovetailingChain.lean is 1909 lines. Much of it is auxiliary infrastructure (dovetailing index functions, seed construction helpers) that could be refactored into separate files. This is not a correctness issue but affects maintainability.

## 7. Files Examined

| File | Path | Lines | Role |
|------|------|-------|------|
| Validity.lean | `Theories/Bimodal/Semantics/Validity.lean` | 217 | Standard validity definitions |
| BFMCSTruth.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` | 334 | BFMCS truth definition |
| BFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` | 269 | BFMCS structure |
| FMCSDef.lean | `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` | 219 | FMCS structure |
| FMCS.lean | `Theories/Bimodal/Metalogic/Bundle/FMCS.lean` | 23 | Re-export |
| TruthLemma.lean | `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` | 488 | Truth lemma (sorry-free) |
| Completeness.lean | `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` | 476 | Completeness theorems (sorry-free) |
| ModalSaturation.lean | `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` | 544 | Modal saturation infrastructure |
| DovetailingChain.lean | `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` | 1909 | Linear chain construction (2 sorries) |
| TemporalCoherentConstruction.lean | `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` | 658 | Temporal coherence + combined existence (1 sorry) |
| Construction.lean | `Theories/Bimodal/Metalogic/Bundle/Construction.lean` | 199 | Primitives (sorry-free) |
| CanonicalFrame.lean | `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` | 100+ | Canonical relations |
| CanonicalFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` | 399 | All-MCS FMCS (sorry-free) |
| CanonicalQuotient.lean | `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean` | 100+ | Quotient construction |
| CanonicalReachable.lean | `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean` | 80+ | Reachable fragment |
| ChainFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` | 730 | Flag-based FMCS |
| TemporalContent.lean | `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` | 38 | GContent/HContent |
| Task 931 research-001 | `specs/931_*/reports/research-001.md` | 338 | Prior cleanup analysis |

## 8. Conclusions

1. **Boneyard cleanup from tasks 931/932 is mostly complete.** The non-standard `_mcs` definitions are in Boneyard. Remaining candidates are the legacy CanonicalReachable/CanonicalQuotient stack and dead eval_bmcs_* definitions.

2. **The fundamental blocker is combining temporal coherence with modal saturation.** No single approach elegantly resolves both simultaneously. The existing codebase has sorry-free temporal coherence for CanonicalMCS (non-Int) and sorry-free modal saturation, but combining them for Int remains open.

3. **The most viable paths are**:
   - (Short-term) Fix `fully_saturated_bfmcs_exists_int` by using DovetailingChain per-family, accepting the 2 forward_F/backward_P sorries as inherited debt
   - (Medium-term) Implement omega-squared construction to eliminate the 2 DovetailingChain sorries
   - (Longer-term) Explore whether the completeness chain can be restructured to avoid Int entirely, using CanonicalMCS Preorder domain

4. **Recommended immediate actions**:
   - Move CanonicalReachable.lean, CanonicalQuotient.lean, CanonicalEmbedding.lean + legacy CanonicalFMCS section to Boneyard
   - Remove dead eval_bmcs_* code from BFMCSTruth.lean
   - Attempt to prove `fully_saturated_bfmcs_exists_int` by constructing a DovetailingChain for each witness family (inheriting the 2 sorries rather than adding a 3rd)
