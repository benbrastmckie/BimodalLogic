# Research Report: RestrictedTruthLemma Path to Bypass BFMCS

**Task**: 81 - F/P Witness Representation Theorem
**Researcher**: Teammate C
**Date**: 2026-04-02

## Executive Summary

The RestrictedTruthLemma path **cannot bypass** `bfmcs_from_mcs_temporally_coherent`. Both paths converge on the same fundamental blocker: proving F/P witness existence within a single family/chain. The RestrictedTruthLemma has its own sorry that is structurally identical to the BFMCS blocker. However, the FMP path (`fmp_contrapositive`) is genuinely sorry-free and provides weak completeness, making it the only viable bypass.

## 1. Detailed Analysis of RestrictedTruthLemma.lean

### What It Proves

**File**: `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`

The `restricted_truth_lemma` (line 291-303) proves:

```
psi in restricted_succ_chain_fam(phi, seed, n) <-> psi in restricted_chain_ext(phi, fam, n)
```

for all `psi in subformulaClosure(phi)`. This is an equivalence between membership in the DeferralRestrictedMCS chain and membership in the Lindenbaum extension of that chain.

**This is NOT the semantic truth lemma.** It says nothing about `truth_at`. It only relates two set-membership conditions. The actual semantic truth lemma (`shifted_truth_lemma` in `CanonicalConstruction.lean:652`) relates MCS membership to `truth_at` and requires `B.temporally_coherent`.

### The 2 Sorries (lines 116 and 158)

**Sorry 1** (`restricted_chain_G_propagates`, line 116): G(psi) at chain(n) implies psi at chain(m) for m >= n. The comment at lines 103-115 explains: propagating G across chain positions requires `G(G(psi))` in deferralClosure, which may exceed the closure bound. Marked sorry pending restructuring.

**Sorry 2** (`restricted_chain_H_step`, line 158): H(psi) at chain(n) implies psi at chain(n-1). The comment at lines 139-157 explains: the standard proof via `Succ_implies_h_content_reverse` requires full MCS properties, but DRMs only satisfy these for deferralClosure formulas.

**Crucially**: Both sorries are about G/H propagation, NOT about F/P witness existence. These are separate from the main blocker. However, they are needed for building a full FMCS from the restricted chain.

### The Completeness Bridge (lines 316-431)

The completeness strategy described at lines 325-337 outlines a 10-step proof that avoids building a full semantic model. It uses Lindenbaum extension at step 3 and relies on existing completeness infrastructure at step 8-9. **However**, step 8 ("Build canonical model from extended MCS") requires either:
- The BFMCS path (which needs `bfmcs_from_mcs_temporally_coherent`), or
- The SuccChain singleton-Omega path (which has a Box backward sorry)

The `neg_consistent_gives_mcs_without_phi` at line 420-431 is a basic Lindenbaum result -- it just proves existence of an MCS with neg(phi). It does NOT provide a model where phi is false.

## 2. SuccChainCompleteness.lean Analysis

**File**: `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean`

`succ_chain_completeness` (line 131-161) proves: not provable(phi) implies existence of a SerialMCS M0 where phi is false in the succ_chain_model.

**Sorry dependency**: `succ_chain_truth_forward` (used at line 153) depends on `succ_chain_truth_lemma` which has a sorry at `SuccChainTruth.lean:311` -- the Box backward case in singleton-Omega. The comment at lines 280-310 explains precisely why: singleton-Omega has no modal witnesses to falsify Box(phi) when it fails.

**This path has sorryAx**: The Box backward sorry makes this completeness theorem unsound. It proves completeness only for the succ_chain model's Omega (singleton), not for general validity.

## 3. The BFMCS Path (Completeness.lean)

**File**: `Theories/Bimodal/FrameConditions/Completeness.lean`

`bundle_validity_implies_provability` (lines 261-295) is structurally complete with one isolated sorry at `bfmcs_from_mcs_temporally_coherent` (line 231-237).

The sorry requires: for each family in `boxClassFamilies`, prove `forward_F` and `backward_P` at the family level. Per the documentation at lines 226-228, this reduces to proving `succ_chain_forward_F` for arbitrary SerialMCS.

## 4. Dependency Chain Analysis

### The Chain of Dependencies

```
bundle_validity_implies_provability (Completeness.lean:261)
  -> bfmcs_from_mcs_temporally_coherent (Completeness.lean:231) [SORRY]
    -> needs: Z_chain_forward_F for each SuccChainFMCS
      -> needs: succ_chain_forward_F
        -> needs: restricted_combined_bounded_witness_fueled (SuccChainFMCS.lean:5977)
          -> fuel=0 branch (SuccChainFMCS.lean:5991) [SORRY]
```

### The RestrictedTruthLemma Chain

```
restricted_tc_family_to_fmcs (CanonicalConstruction.lean:838)
  -> forward_G: SORRY (CanonicalConstruction.lean:889)
  -> backward_H: SORRY (CanonicalConstruction.lean:893)
    (independent Lindenbaum extensions don't preserve G/H propagation)

restricted_truth_lemma (RestrictedTruthLemma.lean:291)
  -> restricted_chain_G_propagates [SORRY at line 116]
  -> restricted_chain_H_step [SORRY at line 158]
    (G/H propagation across chain positions)
```

### The SuccChainCompleteness Chain

```
succ_chain_completeness (SuccChainCompleteness.lean:131)
  -> succ_chain_truth_forward (SuccChainTruth.lean:365)
    -> succ_chain_truth_lemma (SuccChainTruth.lean)
      -> Box backward case [SORRY at SuccChainTruth.lean:311]
        (singleton-Omega cannot prove Box backward)
```

### The FMP Chain

```
fmp_contrapositive (FMP.lean:206) [SORRY-FREE]
  -> mcs_finite_model_property (FMP.lean:193) [SORRY-FREE]
    -> filtered_model_falsifies (FMP.lean:139) [SORRY-FREE]
      -> exists_mcs_with_negation (FMP.lean:57) [SORRY-FREE]

TruthPreservation.lean:
  -> mcs_all_future_closure [SORRY at line 263] (G reflexivity under strict semantics)
  -> mcs_all_past_closure [SORRY at line 281] (H reflexivity under strict semantics)
```

## 5. Can RestrictedTruthLemma Bypass bfmcs_from_mcs_temporally_coherent?

**No.** Here is the rigorous argument:

### Why Not

The `shifted_truth_lemma` (CanonicalConstruction.lean:652-778) is the only theorem that connects MCS membership to `truth_at`. It requires `h_tc : B.temporally_coherent` as a hypothesis. Specifically:

- **G backward case** (line 749): `obtain <forward_F, backward_P> := h_tc fam hfam`
- **H backward case** (line 768): same destructuring

Without `B.temporally_coherent`, the backward direction of the truth lemma for temporal operators fails. The completeness proof at `bundle_validity_implies_provability` uses the backward direction at line 292:

```lean
have h_phi_in_M : phi in B.eval_family.mcs 0 :=
  (shifted_truth_lemma B h_tc phi B.eval_family B.eval_family_mem 0).mpr h_true
```

### The RestrictedTruthLemma Alternative Route

The RestrictedTruthLemma proves DRM membership <-> extended MCS membership. To turn this into a completeness proof, you would need:

1. Build a semantic model from the extended MCS chain
2. Prove truth_at in that model equals membership
3. Show validity fails in that model

Step 2 requires EITHER:
- A full FMCS with forward_G/backward_H (sorry at CanonicalConstruction.lean:889,893 -- independent Lindenbaum extensions break this)
- Family-level temporal coherence (same blocker as bfmcs_from_mcs_temporally_coherent)

The `restricted_tc_family_to_fmcs` (CanonicalConstruction.lean:838-893) attempts exactly this but has 2 sorries for forward_G and backward_H because independent Lindenbaum extensions at each position don't preserve G/H propagation across time steps.

### The Core Insight

All completeness paths converge on the same fundamental requirement: connecting syntactic membership to semantic truth for temporal operators. This always requires temporal coherence (F/P witnesses within the same family) for the backward direction of the truth lemma.

The restricted chain DOES provide F/P coherence within the DRM (via `build_restricted_tc_family` which is sorry-free for the forward_F/backward_P of the DRM chain). But extending to full MCS via Lindenbaum breaks this coherence for arbitrary formulas. The `restricted_truth_lemma` only proves DRM<->extended equivalence for subformulaClosure formulas, which is necessary but not sufficient for the full truth lemma.

## 6. The Real Sorry Architecture

| Sorry Location | What It Blocks | Fundamental Issue |
|---|---|---|
| `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237) | BFMCS completeness | Family-level F/P in BFMCS bundle |
| `restricted_combined_bounded_witness_fueled` fuel=0 (SuccChainFMCS.lean:5991) | F/P witness in restricted chain | Proving fuel=0 unreachable |
| `restricted_tc_family_to_fmcs` forward_G (CanonicalConstruction.lean:889) | RestrictedTruthLemma completeness | Independent Lindenbaum extensions |
| `restricted_tc_family_to_fmcs` backward_H (CanonicalConstruction.lean:893) | RestrictedTruthLemma completeness | Independent Lindenbaum extensions |
| `restricted_chain_G_propagates` (RestrictedTruthLemma.lean:116) | G-propagation in DRM chain | G-nesting exceeds deferralClosure |
| `restricted_chain_H_step` (RestrictedTruthLemma.lean:158) | H-step in DRM chain | h_content_reverse needs full MCS |
| `succ_chain_truth_lemma` Box backward (SuccChainTruth.lean:311) | SuccChain completeness | Singleton-Omega has no modal witnesses |
| `mcs_all_future_closure` (TruthPreservation.lean:263) | FMP truth preservation | G reflexivity invalid under strict semantics |
| `mcs_all_past_closure` (TruthPreservation.lean:281) | FMP truth preservation | H reflexivity invalid under strict semantics |

## 7. FMP Path Comparison

### fmp_contrapositive (FMP.lean:206) -- SORRY-FREE

This theorem IS sorry-free. It proves:

```
(forall S : ClosureMCSBundle phi, phi in S.carrier) -> Nonempty (DerivationTree [] phi)
```

This is weak completeness: if phi is a member of every closure MCS, then phi is provable.

**What it gives**: Completeness relative to closure MCS membership, NOT relative to semantic validity (truth_at in task frames).

**What it does NOT give**: The bridge from `valid_over D phi` (semantic validity in all task frames) to `phi in every closure MCS`. This bridge requires the truth preservation lemma, which has the 2 TruthPreservation.lean sorries.

### TruthPreservation Sorries -- Semantic, Not Syntactic

The 2 sorries in TruthPreservation.lean (lines 263, 281) are about strict vs. reflexive temporal semantics:
- `mcs_all_future_closure`: G(psi) in S does NOT imply psi in S under strict semantics
- `mcs_all_past_closure`: H(psi) in S does NOT imply psi in S under strict semantics

These are NOT the same as the F/P witness blocker. They're about whether TM uses reflexive or strict G/H semantics. If TM uses reflexive semantics (G means "at all times >= t"), then G(psi) -> psi is an axiom and these are trivially provable. If strict (G means "at all times > t"), they're genuinely false.

**This is a design decision, not a proof difficulty.** If the project uses reflexive temporal semantics (which the comments in CanonicalConstruction.lean:742 suggest: "Under reflexive semantics, G quantifies over s >= t"), then these 2 sorries are closable.

### Difficulty Comparison

| Path | Sorries to Close | Difficulty |
|---|---|---|
| BFMCS (`bfmcs_from_mcs_temporally_coherent`) | 1 (via fuel=0 unreachability in SuccChainFMCS.lean:5991) | **HARD** -- proving semantic unreachability of fuel exhaustion |
| RestrictedTruthLemma completeness | 4 (2 in RestrictedTruthLemma + 2 in CanonicalConstruction) | **HARDER** -- 4 sorries, each non-trivial |
| SuccChainCompleteness | 1 (Box backward in singleton-Omega) | **IMPOSSIBLE** -- mathematically false |
| FMP + TruthPreservation | 2 (G/H reflexivity) | **EASIEST** -- closable if TM uses reflexive G/H semantics |

## 8. Recommended Strategy

### Primary: Close the FMP Path

If TM bimodal logic uses reflexive temporal semantics (G = "all times >= t"), close the 2 TruthPreservation sorries:
1. `mcs_all_future_closure` (line 263): Replace sorry with proof using the T-axiom for G (temp_t_future: G(psi) -> psi)
2. `mcs_all_past_closure` (line 281): Replace sorry with proof using the T-axiom for H (temp_t_past: H(psi) -> psi)

Then `fmp_contrapositive` + truth preservation gives a complete FMP-based completeness theorem.

**However**: fmp_contrapositive gives completeness relative to closure MCS membership, not semantic validity. A bridge lemma from `valid_over D phi` to `phi in every ClosureMCSBundle` is still needed. This bridge is what the FMP path was designed for, but it requires a filtered task model construction that doesn't currently exist.

### Secondary: Close the BFMCS Path

The single sorry in `bfmcs_from_mcs_temporally_coherent` reduces to the fuel=0 case at `SuccChainFMCS.lean:5991`. This requires proving that with fuel = B*B+1 (where B = closure_F_bound), the fuel=0 branch is unreachable. This is a bounded combinatorial argument about F-nesting depth in deferralClosure.

### Do NOT Pursue: RestrictedTruthLemma Bypass

The RestrictedTruthLemma path has MORE sorries than the BFMCS path (4 vs 1) and each sorry represents a genuine mathematical gap (not just a proof gap). The restricted chain cannot be extended to full MCS while preserving temporal coherence.

## 9. Confidence Assessment

**Confidence: HIGH** that RestrictedTruthLemma cannot bypass bfmcs_from_mcs_temporally_coherent.

**Justification**:
- Read all 4 source files thoroughly with line-by-line analysis
- Traced the complete dependency chain for all 3 completeness paths
- Identified the exact sorry locations and their mathematical causes
- The argument is structural: shifted_truth_lemma requires B.temporally_coherent, which is precisely what bfmcs_from_mcs_temporally_coherent provides
- The RestrictedTruthLemma path introduces 4 additional sorries without eliminating the original blocker
- The FMP path is the only genuinely sorry-free alternative, but gives weaker completeness (MCS membership, not semantic validity)
