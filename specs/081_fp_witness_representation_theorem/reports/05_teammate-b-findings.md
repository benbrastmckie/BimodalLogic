# Research Report: Task #81 — Teammate B (Alternative Mathematical Approaches)

**Task**: 81 - F/P Witness Representation Theorem
**Researcher**: Teammate B (Alternative Approaches)
**Date**: 2026-03-31
**Focus**: Alternative mathematical approaches to same-family forward_F/backward_P

---

## Executive Summary

After examining all four proposed alternative approaches against the actual codebase state, the **restricted completeness approach (Approach 2)** is the most viable path — not as a workaround, but as the mathematically correct solution. The restricted chain already has sorry-free `forward_F` via `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:2930). The gap is in wiring this to the parametric representation theorem, not in the mathematical content.

The compactness/ultraproduct approach (Approach 1) and modified Lindenbaum (Approach 4) both reduce to the same controlled-seeding problem already identified in Run 4. The bi-infinite chain approach (Approach 3) does not help because the blocker is F-persistence through Lindenbaum extensions, not chain directionality.

---

## Key Findings

1. **The restricted chain already has sorry-free forward_F**: `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:2930-2934) proves that if `F(psi) ∈ restricted_forward_chain phi M0 n`, then `psi ∈ restricted_forward_chain phi M0 (n+1)`. This is an immediate consequence of `restricted_forward_chain_F_resolves`, which follows from `constrained_successor_restricted_f_content_persistence`. The F-content is included in the seed and the consistency argument works because deferralClosure bounds the F-nesting depth.

2. **The restricted backward_P also works**: `build_restricted_tc_family` (SuccChainFMCS.lean:5866) packages both `forward_F` and `backward_P` into a `RestrictedTemporallyCoherentFamily`. The forward_F case delegates to `restricted_forward_chain_forward_F`; the backward_P delegates to `restricted_backward_chain_backward_P`.

3. **The real gap is the BFMCS bridge**: `parametric_algebraic_representation_conditional` requires a `construct_bfmcs` function that takes an **arbitrary MCS** and produces a temporally coherent BFMCS. The restricted chain only produces `RestrictedTemporallyCoherentFamily` from a `DeferralRestrictedSerialMCS` — a restricted MCS, not a full one. The bridge requires either (a) showing every full MCS extends to a restricted one, or (b) modifying the completeness proof to use restricted families directly.

4. **ultrafilter_F_resolution is proven but not yet connected**: UltrafilterChain.lean:947 proves that `F(a) ∈ U` implies `∃ V, R_G(U,V) ∧ a ∈ V` at the ultrafilter level. This resolves the F-witness problem algebraically. However, `UltrafilterChain_to_FMCS` only gives `forward_G` and `backward_H` — it does NOT give `forward_F` or `backward_P`. The ultrafilter chain construction does not track which F-obligations are resolved at which positions.

5. **The fundamental blocker is identical across approaches**: F-formulas are not G-liftable. `G(F(psi)) = G(neg(G(neg(psi))))` cannot be derived from `F(psi) ∈ M`. This is confirmed explicitly in DovetailedChain.lean:474-481. Any approach that uses Lindenbaum extension with `temporal_box_seed` (G-liftable formulas only) cannot preserve F-obligations through chain steps.

---

## Approach Analysis

### Approach 1: Compactness / Ultraproduct

**Feasibility**: Low incremental value.

The compactness approach (product topology on `∏_{t∈Z} Ultrafilter(LindenbaumAlg)`, Tychonoff, closed constraint sets, FIP) was analyzed in depth by Run 4 (report 04_team-research.md). The key finding: **the FIP proof requires the same controlled-seeding argument as the dovetailed construction**. The finite intersection property for F-constraints requires building finite chains that resolve F-obligations — exactly the same mathematical content as the direct construction.

The ultrafilter infrastructure (`ultrafilter_F_resolution`, `R_G_refl`, `R_G_trans`, `R_G_R_H_converse`) provides elegant algebraic tools, but translating these to a product-topology argument adds ~560-880 lines of topology setup that merely repackages the controlled-seeding argument.

**Verdict**: Not recommended. Same mathematical core as dovetailed, with topology overhead.

### Approach 2: Restricted Completeness via DeferralRestrictedMCS

**Feasibility**: HIGH — most infrastructure already exists.

**What exists**:
- `DeferralRestrictedSerialMCS` (SuccChainFMCS.lean:2391)
- `restricted_forward_chain_forward_F` — sorry-free (SuccChainFMCS.lean:2930)
- `restricted_backward_chain_backward_P` — referenced in `build_restricted_tc_family`
- `RestrictedTemporallyCoherentFamily` (SuccChainFMCS.lean:5847)
- `build_restricted_tc_family` (SuccChainFMCS.lean:5866)
- `build_restricted_serial_mcs_from_neg_consistent` (SuccChainFMCS.lean:2419)
- `RestrictedTruthLemma.lean` — partial, with 2 sorries in G/H propagation

**The gap**: The restricted truth lemma (RestrictedTruthLemma.lean) has two sorries:
1. `restricted_chain_G_propagates` at line ~116 — G propagation across multiple steps for restricted chain elements not in deferralClosure
2. `restricted_chain_H_step` at line ~158 — H-step property for restricted chain

**Why the gap is small**: The truth lemma only needs to hold for formulas in `subformulaClosure(phi)`. Since the restricted chain is built from `deferralClosure(phi)` and `subformulaClosure(phi) ⊆ deferralClosure(phi)`, every formula relevant to the truth lemma IS in the deferralClosure. The G-propagation sorry exists because the current proof doesn't use this restriction — it tries to prove propagation for ALL formulas, which fails outside deferralClosure.

**Path to completion**:
1. Add hypothesis `ψ ∈ deferralClosure(phi)` to `restricted_chain_G_propagates`
2. Use the fact that `G(ψ) ∈ deferralClosure(phi)` when `ψ ∈ deferralClosure(phi)` (closure under subformulas)
3. Since all chain elements are DeferralRestrictedMCS, G-propagation through restricted Lindenbaum extensions preserves membership for deferralClosure formulas
4. The truth lemma caller (completeness proof) always has `ψ ∈ subformulaClosure(phi) ⊆ deferralClosure(phi)`, so the added hypothesis is always satisfiable

**For the BFMCS bridge**, two sub-options:

**Option 2a**: Modify `parametric_algebraic_representation_conditional` to accept a `construct_restricted_bfmcs` that takes a formula phi and produces a temporally coherent BFMCS from a DeferralRestrictedSerialMCS. Since completeness starts from "phi not provable → neg(phi) consistent → build restricted MCS containing neg(phi)", this is natural.

**Option 2b**: Show that `DeferralRestrictedSerialMCS.extendToMCS` (SuccChainFMCS.lean:3108-3113) gives a full MCS that inherits temporal coherence from the restricted family. The extension is via Lindenbaum, so it preserves membership of all formulas in the restricted chain. The FMCS built from extended chain elements would have forward_F/backward_P inherited from the restricted chain (for deferralClosure formulas).

**Estimated effort**: 150-300 lines to close the two truth lemma sorries + wire through completeness. This is the lowest-effort path.

**Risks**: Medium-low. The mathematical argument is sound. The main risk is technical: ensuring that the restricted truth lemma with the deferralClosure hypothesis composes correctly with the parametric completeness infrastructure.

### Approach 3: Different Chain Architecture (Bi-infinite Single Chain)

**Feasibility**: Does not address the blocker.

The proposal is to build a single bi-infinite chain where every step satisfies `Succ`, getting both forward and backward coherence. The existing `succ_chain_fam` (SuccChainFMCS.lean) already does this — it combines forward and backward Nat-indexed chains into an Int-indexed family with `Succ` between adjacent elements.

The problem is NOT chain directionality. The existing chain already has:
- `forward_G` ✓ (from Succ's g_persistence)
- `backward_H` ✓ (from g_content/h_content duality via `g_content_subset_implies_h_content_reverse`)

What's missing is `forward_F` and `backward_P`, which require resolving existential witnesses within the same chain. Whether the chain is unidirectional or bidirectional, the F-persistence problem is identical: Lindenbaum extensions can kill F-obligations.

**Verdict**: Does not help. The chain architecture is not the problem; the seeding strategy is.

### Approach 4: Modified Lindenbaum with F-Preservation

**Feasibility**: This IS the controlled-seeding approach.

The proposal to enumerate formulas and prefer choices that preserve F-obligations is exactly what the "controlled seeding" strategy does (Run 4, report 04_team-research.md). At each Lindenbaum step, when deciding `phi` vs `neg(phi)`, include all pending F-obligations in the seed to prevent their negation from being added.

The challenge: proving consistency of the expanded seed `G_theory(M) ∪ box_theory(M) ∪ {phi_resolved} ∪ {F(psi_i) | pending}`. Since F-formulas are not G-liftable, the standard `temporal_theory_witness_consistent` argument does not directly apply to the F-blocker formulas.

However, a subtlety makes this work: all F-blockers `F(psi_i)` are **already in M** (by the F-persistence invariant). So the seed is a subset of `M ∪ {phi_resolved}`, and `M ∪ {phi_resolved}` is consistent when `F(phi_resolved) ∈ M` (since `neg(phi_resolved) → G(neg(phi_resolved))` would contradict `F(phi_resolved)`... but this argument needs G-lifting of `neg(phi_resolved)`, which IS available for a single formula via the standard witness consistency proof).

Wait — the seed includes `phi_resolved` (single formula, consistent by existing argument) AND multiple F-blockers. The F-blockers are already in M, so `seed ⊆ M ∪ {phi_resolved}`. But `M ∪ {phi_resolved}` might be inconsistent (if `neg(phi_resolved) ∈ M`). The existing `temporal_theory_witness_consistent` handles this for `G_theory(M) ∪ {phi_resolved}`, not for `M ∪ {phi_resolved}`.

So the controlled seeding consistency argument needs: `G_theory(M) ∪ box_theory(M) ∪ f_content(M) ∪ {phi_resolved}` is consistent. The `f_content(M)` elements are NOT in `G_theory(M)` and are NOT G-liftable. This remains the fundamental obstacle for the modified Lindenbaum / controlled seeding approach on arbitrary MCS.

**Key insight**: This is exactly WHY the restricted approach works — in DeferralRestrictedMCS, the f_content IS bounded and can be included in the seed because all F-formulas are within deferralClosure, which has finite F-nesting depth. The "modified Lindenbaum" IS the restricted chain construction.

**Verdict**: Reduces to Approach 2 (restricted completeness) for the case where it works.

---

## Recommended Approach

### Primary: Approach 2 — Restricted Completeness (Option 2a)

**Justification**:

1. **Most infrastructure exists**: `restricted_forward_chain_forward_F` is sorry-free. `build_restricted_tc_family` packages everything. `build_restricted_serial_mcs_from_neg_consistent` provides the entry point from completeness.

2. **Smallest gap**: Two sorries in RestrictedTruthLemma.lean, both closable by adding deferralClosure membership hypotheses (which are always satisfied by the completeness proof caller).

3. **Mathematically correct**: The restricted approach is not a hack — it's the standard subformula-closure technique used in canonical model completeness proofs (cf. Blackburn-de Rijke-Venema "Modal Logic", §4.2). Working within the subformula closure of the target formula is the standard approach.

4. **Avoids the arbitrary-MCS F-persistence problem entirely**: By restricting to deferralClosure, F-nesting is bounded, f_content can be included in seeds, and the consistency argument goes through. This is not a limitation — for completeness, we only ever need to evaluate the target formula phi, which is in its own subformulaClosure.

5. **No new mathematical machinery needed**: Unlike the dovetailed construction (which needs new controlled-seeding infrastructure, fair scheduling, obligation tracking) or compactness (which needs topology setup), the restricted approach uses only existing infrastructure with minor wiring changes.

### Implementation Sketch

```
Step 1: Fix restricted_chain_G_propagates in RestrictedTruthLemma.lean
  - Add ψ ∈ deferralClosure(phi) hypothesis
  - Prove G-propagation for deferralClosure formulas through restricted chain
  - ~40-60 lines

Step 2: Fix restricted_chain_H_step in RestrictedTruthLemma.lean
  - Symmetric to Step 1 for H direction
  - ~40-60 lines

Step 3: Build restricted_construct_bfmcs
  - From DeferralRestrictedSerialMCS, build BFMCS via:
    a. Use build_restricted_tc_family for temporal coherence
    b. Convert restricted chain to FMCS via Lindenbaum extension
    c. Package into BFMCS with temporal_coherent proof
  - ~100-150 lines

Step 4: Wire to completeness
  - Modify completeness proof to use restricted path:
    a. From "phi not provable" → neg(phi) consistent
    b. build_restricted_serial_mcs_from_neg_consistent gives DRM with neg(phi)
    c. restricted_construct_bfmcs gives temporally coherent BFMCS
    d. Apply restricted truth lemma (with deferralClosure hypothesis)
  - ~50-80 lines
```

**Total estimated new code**: 230-350 lines
**Risk**: Medium-low

### Fallback: Dovetailed Construction with Controlled Seeding

If the restricted approach hits unexpected obstacles (e.g., the Lindenbaum extension from DRM to MCS doesn't preserve temporal coherence in a way compatible with the parametric truth lemma), the dovetailed construction from Run 4 provides the arbitrary-MCS solution at higher cost (~660-1030 lines).

---

## Confidence Level

**High (85%)** for the restricted completeness approach.

The mathematical argument is sound: subformula-closure completeness is the textbook technique, the restricted chain already has sorry-free forward_F, and the two remaining sorries in the truth lemma are closable with straightforward hypothesis strengthening. The main uncertainty is in the technical wiring (Step 3), where the Lindenbaum extension from DRM to full MCS must preserve enough structure for the parametric truth lemma.

**Medium (60%)** for the dovetailed construction as fallback.

The controlled-seeding argument is mathematically correct but has significant formalization complexity (obligation tracking, cross-zero handling, multiple invariant maintenance).
