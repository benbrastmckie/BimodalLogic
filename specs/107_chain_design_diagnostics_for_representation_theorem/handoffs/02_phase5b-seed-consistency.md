# Handoff: Phase 5b -- Seed Consistency for lemma_2_6_splitting

## Status

Phase 5b is PARTIALLY complete. The structural proof of `lemma_2_6_splitting` is done -- all steps after seed consistency are implemented and type-check. The single remaining sorry is `splitting_seed_consistent` in `PointInsertion.lean`.

## What Was Done

1. **Axiom constructors** (separation_until, separation_since): Already added to `Axioms.lean` in a previous session. Lines 175-190.

2. **Soundness proofs**: Already added to `Soundness.lean` and `SoundnessLemmas.lean` in a previous session. All compile sorry-free.

3. **lemma_2_6_splitting proof structure** (new this session): Lines 304-338 of `PointInsertion.lean`. The proof body is complete modulo `splitting_seed_consistent`:
   - Step 1: Invoke splitting_seed_consistent
   - Step 2: Derive h_content(C) <= A by duality (g_content_subset_implies_h_content_reverse)
   - Step 3: Lindenbaum extend seed to MCS D
   - Step 4: Extract beta.neg in D, g_content(A) <= D, h_content(C) <= D from seed inclusion
   - Step 5: Derive g_content(D) <= C from h_content(C) <= D by duality
   - Step 6: BurgessR3Maximal(A, B', D) via burgessR3Maximal_from_g_content_sub
   - Step 7: BurgessR3Maximal(D, B'', C) via burgessR3Maximal_from_g_content_sub
   All steps type-check with `lake build` succeeding.

4. **Fixed noncomputable annotation**: Removed spurious `noncomputable` from `theorem` declaration (Lean 4 error: "theorem subsumes noncomputable").

## What Remains: splitting_seed_consistent

### Goal

```lean
SetConsistent ({beta.neg} ∪ g_content A ∪ h_content C)
```

Given: `BurgessR3Maximal A B C`, `beta ∉ B`, `g_content A ⊆ C`, and MCS A and C.

### Why This Is Hard

Under **irreflexive semantics** (open guard), several approaches that would work under reflexive semantics FAIL:

1. **g_content(A) ⊆ B is NOT guaranteed**: Under reflexive semantics, G(phi) -> phi (modal T), so g_content elements are derivable at intermediate times. Under irreflexive, G(phi) at time t means phi at all t' > t (strictly), NOT at t itself. So g_content(A) need not be in B.

2. **h_content(C) ⊆ B is NOT guaranteed**: Mirror of above.

3. **Bidirectional seed elements live in DIFFERENT MCSes**: g_content(A) ⊆ C (elements in C), h_content(C) ⊆ A (by duality, elements in A). Under irreflexive semantics, neither set is necessarily in both A and C. So the seed elements can't be collapsed into a single MCS for a direct consistency argument.

4. **G and H lifting don't commute**: From L ⊢ bot, generalized temporal K gives G(L) ⊢ G(bot) (useful when L ⊆ g_content(A), giving G-elements in A). But if L has both g_content and h_content elements, we can't lift ALL of L through G (h_content elements have H-lifts in C, not G-lifts in A) or ALL through H.

### Most Promising Proof Strategy

The proof should follow **Burgess 1982 Lemma 2.6**, adapted for the content-based BurgessR3Maximal.

**Step 1: Maximality failure**. From beta not in B and BurgessR3Maximal:
- If {beta} ∪ B is inconsistent: beta.neg ∈ B (by DCS property).
- If {beta} ∪ B is consistent: DC({beta} ∪ B) violates burgessR3 by BurgessR3Maximal_extension_fails. By negation of dc_delta_B_burgessR3 conditions, there exist beta0 ∈ B, gamma0 ∈ C with ¬untl(beta0 ∧ beta, gamma0) ∈ A (or Since analog in C).

**Step 2: Apply A4a (separation_until)**. From untl(beta0, gamma0) ∈ A (burgessR3) and ¬untl(beta0 ∧ beta, gamma0) ∈ A (failure witness):
separation_until(gamma0, beta0, beta0 ∧ beta): untl(beta0, beta0 ∧ ¬(beta0 ∧ beta)) ∈ A.
By right_mono_until with the tautology (beta0 ∧ ¬(beta0 ∧ beta)) → ¬beta: untl(beta0, ¬beta) ∈ A.

**Step 3: Enrichment**. From untl(beta0, ¬beta) ∈ A and alpha ∈ A:
By A3a (enrichment_until): alpha ∧ untl(beta0, ¬beta) → untl(beta0, ¬beta ∧ snce(beta0, alpha)).
So F(¬beta ∧ snce(beta0, alpha)) ∈ A for all alpha ∈ A.

**Step 4: Guard enrichment with g_content**. From G(g_i) ∈ A for g_i ∈ g_content(A):
The Until event can be enriched with g_i using right_mono_until and the tautology-derived G(event → event ∧ g_i) from G(g_i).

**Step 5: Combine**. The enriched seed `{¬beta ∧ snce(beta0, alpha) : alpha ∈ A} ∪ g_content(A)` is consistent by forward_temporal_witness_seed_consistent (since F of each conjunction is in A). Any finite L ⊆ full seed is derivable from a suitable enriched conjunction plus g_content(A), hence consistent.

**Step 6: h_content(C) inclusion**. h_content(C) ⊆ A by duality. Each h_j ∈ A can be folded into the alpha parameter of the enrichment (set alpha = alpha0 ∧ h_1 ∧ ... ∧ h_k). The snce(beta0, alpha) in the enriched seed then derives snce(beta0, h_j) by right_mono_since, which gives P(h_j) in D. However, P(h_j) does NOT give h_j (irreflexive semantics). The missing step is showing that h_j actually lands in D from the enrichment.

### Open Question

The gap between P(h_j) ∈ D and h_j ∈ D requires either:
(a) A more sophisticated enrichment that places h_j directly in the event (not just via snce), OR
(b) A different seed construction that includes the Burgess D0 terms (B, untl, snce) alongside g_content/h_content, with the consistency argument adapted to handle all components simultaneously.

### Key Infrastructure Available

- `BurgessR3Maximal_extension_fails`: maximality gives violation of burgessR3 for extensions
- `dc_delta_B_burgessR3`: conditions under which DC({delta} ∪ B) satisfies burgessR3
- `dc_delta_B_controlled`: elements of DC({delta} ∪ B) are in B or have form (beta0 ∧ delta) → phi
- `dcs_neg_union_consistent`: beta ∉ B (DCS) implies {beta.neg} ∪ B consistent
- `forward_temporal_witness_seed_consistent`: F(psi) ∈ MCS M implies {psi} ∪ g_content(M) consistent
- `past_temporal_witness_seed_consistent`: P(psi) ∈ MCS M implies {psi} ∪ h_content(M) consistent
- `enriched_resolving_seed_consistent`: F(psi ∧ alpha) ∈ M implies {psi, alpha} ∪ g_content(M) consistent
- `separation_until` / `separation_since`: BX14/BX14' axiom constructors (A4a/A4b)
- `enrichment_until` / `enrichment_since`: BX13/BX13' axiom constructors (A3a/A3b)

### Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`: Added `splitting_seed_consistent` (sorry), `lemma_2_6_splitting` (complete modulo sorry). Fixed noncomputable annotation.

## Recommendation

Run `/revise 107` to update the plan with the analysis above. The key decision is whether to:
(A) Complete the Burgess-style proof for splitting_seed_consistent (estimated 4-6 hours of careful axiom manipulation).
(B) Restructure to avoid the bidirectional seed (requires fundamental rethinking of the g_content approach).
(C) Add an intermediate lemma that directly relates BurgessR3Maximal to g_content/h_content containment.
