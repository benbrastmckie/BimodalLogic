# Research Report: Task #70 - Mathematical Foundations of Temporal Coherence

**Task**: 70 - Explore ultrafilter-based construction for temporal coherence
**Started**: 2026-03-30T00:00:00Z
**Completed**: 2026-03-30T00:00:00Z
**Language**: lean4 / math

---

## Key Findings

1. **The cross-direction coherence problem is architecturally fundamental, not incidental.** The FMCS structure requires same-family witnesses for both `forward_F` and `backward_P`, and the truth lemma requires these for the backward G/H induction. This cannot be sidestepped.

2. **The CoherentZChain construction is inherently asymmetric.** The forward chain (t >= 0) preserves G but not H; the backward chain (t < 0) preserves H but not G. Combining them produces an FMCS that fails to satisfy `forward_F` at negative times and `backward_H` at positive times.

3. **A mathematically correct single-family solution requires a seed construction that preserves BOTH G and H simultaneously.** Such a construction exists conceptually but requires a more sophisticated witness step than the current one-directional approach.

4. **The sorry-free alternative already exists: bundle-level coherence via `boxClassFamilies`.** The code already contains `construct_bfmcs_bundle` which is sorry-free and provides bundle-level temporal coherence. The only gap is that the parametric truth lemma requires family-level (same-family) coherence, not bundle-level.

5. **The gap between bundle-level and family-level coherence is real and documented in the codebase.** The comment at line 5144 explicitly identifies this as the remaining blocker.

6. **`omega_true_dovetailed_forward_F_resolution` has a proof gap (line 7696 sorry) that is NOT fixable by the ultrafilter approach without additional machinery.**

---

## Mathematical Analysis

### 1. What Temporal Coherence Actually Requires

The semantics defines:
- `G phi` (all_future phi): true at (tau, t) iff phi is true at (tau, s) for all s >= t
- `H phi` (all_past phi): true at (tau, t) iff phi is true at (tau, s) for all s <= t

The parametric truth lemma proves: `phi ∈ fam.mcs(t) ↔ truth_at ... (to_history fam) t phi`

The backward direction of the `G` case (the critical use case) requires:
```
∀ s ≥ t, phi ∈ fam.mcs(s)  →  G(phi) ∈ fam.mcs(t)
```

This is proved by contraposition using `temporal_backward_G`:
1. If `G(phi) ∉ fam.mcs(t)`, then `neg(G(phi)) ∈ fam.mcs(t)` (MCS completeness)
2. Therefore `F(neg phi) ∈ fam.mcs(t)` (temporal duality)
3. By `forward_F`: `∃ s >= t, neg(phi) ∈ fam.mcs(s)` — witness in the SAME family
4. But `phi ∈ fam.mcs(s)` (by hypothesis), contradiction

**Step 3 is the critical requirement.** The witness s must be in the SAME family fam, because the semantic hypothesis quantifies over the history `to_history(fam)`. A different family would use a different history, and truth at one history does not directly imply membership in another family.

Similarly for `H` and `backward_P`. Both directions together give `B.temporally_coherent`:
```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t φ, F(φ) ∈ fam.mcs(t) → ∃ s >= t, φ ∈ fam.mcs(s)) ∧
    (∀ t φ, P(φ) ∈ fam.mcs(t) → ∃ s <= t, φ ∈ fam.mcs(s))
```

### 2. Why the Current CoherentZChain Cannot Satisfy This

The `CoherentZChain` combines:
- For t >= 0: `omega_chain_F_preserving_forward M0 h_mcs0 t.toNat`
- For t < 0: `omega_chain_P_preserving_backward M0 h_mcs0 (-t).toNat`

The forward chain preserves the G-theory of M0 at all steps — formally:
- `FPreservingForwardChain.forward_G`: G(phi) at n implies phi at n' for n' >= n

The backward chain preserves the H-theory of M0 at all steps — formally:
- `PPreservingBackwardChain.backward_H`: H(phi) at n implies phi at n' for n' >= n (in Nat indices)

**The asymmetry problem:**

For `CoherentZChain_to_FMCS.forward_G` with t < 0, t' >= 0 (the cross-direction case):
- G(phi) is in the backward chain at negative t
- We need G(phi) to still hold at t' in the forward chain
- But G-preservation was never built into the backward chain construction

For `CoherentZChain_to_FMCS.backward_H` with t >= 0, t' < 0 (the other cross-direction):
- H(phi) is in the forward chain at non-negative t
- We need H(phi) to still hold at t' in the backward chain
- But H-preservation was never built into the forward chain construction

For `CoherentZChain_to_FMCS.backward_H` with both t, t' >= 0:
- H(phi) is in the forward chain at positive t, need it at positive t' <= t
- The forward chain only guarantees G-propagation, not H-propagation

**This is a fundamental architectural issue, not a corner case.** The construction was designed around one direction of propagation per chain direction.

### 3. Why CoherentZChain_forward_F at t < 0 Is Also Broken

For `CoherentZChain_forward_F` at t < 0:
- F(phi) is in the backward chain at negative time t
- The backward chain resolves P-obligations, not F-obligations
- F(phi) might resolve to phi at some positive time, but the backward chain does not track this

This sorry (line 7453) is also a fundamental gap: the backward chain was designed to find witnesses in the past, not the future.

### 4. The F-Resolution Gap in the Dovetailed Chain (Line 7696)

In `omega_true_dovetailed_forward_F_resolution`, the case where `F(phi)` vanishes before reaching step n0 requires showing that this cannot happen without phi becoming resolved. The comment identifies the issue:

> If F(phi) vanishes, it's because G(neg phi) entered the chain. The Lindenbaum extension can add G(neg phi) if it's consistent with the seed, even when F(phi) was present earlier.

This gap is real. The existing F-preserving construction only maintains G-formulas from the SEED M0, not from intermediate steps. If F(phi) is at step n but phi was not in M0, there is no guarantee that G(neg phi) is blocked from entering the chain at step n+1.

**This gap is independent of the cross-direction issue.** It exists purely within the forward chain and would need to be fixed even if the cross-direction problem were resolved.

### 5. The Bundle-Level vs. Family-Level Gap

The `construct_bfmcs_bundle` function is sorry-free and provides:
- `boxClassFamilies_bundle_forward_F`: F(phi) at (fam, t) → ∃ fam' in bundle, s > t, phi at (fam', s)
- `boxClassFamilies_bundle_backward_P`: P(phi) at (fam, t) → ∃ fam' in bundle, s < t, phi at (fam', s)

The witness fam' is a NEW family (a shifted SuccChainFMCS built from a temporal witness MCS), not the original fam. This is weaker than what the truth lemma needs.

The comment at line 5144 states this explicitly:
> Step 3 requires `B.temporally_coherent` (family-level forward_F/backward_P).
> The sorry-free bundle construction provides only bundle-level coherence.
> The gap between bundle-level and family-level coherence is the remaining blocker.

---

## Recommended Approach

**There are three viable paths forward, ordered by mathematical difficulty:**

### Path A: Modify the Truth Lemma to Use Bundle-Level Coherence (HIGHEST PRIORITY)

The truth lemma as written requires same-family witnesses. However, the standard completeness argument for temporal logics does NOT require same-family witnesses — it requires only that the canonical model satisfies the semantic clauses.

The key question is: **can we reformulate the truth lemma so that bundle-level witnesses suffice?**

For the backward G case, the proof is:
```
Assume G(phi) ∉ fam.mcs(t)
Then F(neg phi) ∈ fam.mcs(t)         [temporal duality]
Then ∃ fam', s > t, neg(phi) ∈ fam'.mcs(s)  [bundle_forward_F]
```

The current proof continues: "by hypothesis, phi is true at all s >= t along fam's history, so phi ∈ fam.mcs(s)." But now the witness is in fam' not fam.

**The obstacle is**: semantic truth in the backward G case says "phi is true at (to_history fam, s) for all s >= t." This is a statement about fam's history, not fam's history. We need phi ∈ fam'.mcs(s), which we cannot get from the truth hypothesis (which only gives phi ∈ fam.mcs(s)).

However: **if the bundle has a single time-index structure where different families share time** (which they do — all families are indexed by Int), and if "bundle-level truth" is the right notion, perhaps a different formulation of the semantic model works.

**Deeper issue**: The semantic model uses `to_history fam` as the world history. Different families produce different histories. The box modality quantifies over ALL histories in Omega (all families). But the temporal modality is intrinsic to a SINGLE history.

This means: **truth of G(phi) at (fam, t) semantically means phi holds along fam's history at all future times** — it is genuinely a statement about a single history, and same-family witnesses are mathematically necessary.

**Conclusion for Path A**: The truth lemma CANNOT be reformulated to use bundle-level witnesses for temporal operators. The standard mathematical argument requires same-family witnesses. This is not a Lean formalization artifact — it is intrinsic to the semantics.

### Path B: Build a Genuinely Temporally Coherent Single-Family Construction

A single FMCS satisfying BOTH `forward_F` and `backward_P` requires:

**Design principle**: Start with MCS M0. Build an Int-indexed chain where:
- Forward direction resolves F-obligations (finds witnesses for F(phi) in the future)
- Backward direction resolves P-obligations (finds witnesses for P(phi) in the past)
- **Crucially**: Both directions simultaneously preserve BOTH G and H theories

The challenge is that preserving both G and H simultaneously is more constrained. A seed construction at each step must include:
- The current G-theory (for forward propagation)
- The current H-theory (for backward propagation)
- The formula to be resolved (F or P)

The existing `f_preserving_seed` and `p_preserving_seed` constructions handle these separately. A combined seed would be:
```
combined_seed(M, phi) = {phi} ∪ G_theory(M) ∪ H_theory(M) ∪ F_unresolved(M) ∪ P_unresolved(M)
```

But this is problematic: including both G and H theories from M ensures propagation, but the consistency of this combined seed is significantly harder to prove.

**The critical obstacle**: The `temporal_theory_witness_exists` lemma (used by `boxClassFamilies_bundle_forward_F`) constructs a witness that preserves G-theory but NOT H-theory. A symmetric construction would give H-preservation but not G-preservation. Getting both simultaneously requires a new lemma — one that builds an MCS preserving both the G-theory and H-theory of the current MCS.

**Mathematical question**: Given MCS M with G(phi) ∈ M and H(psi) ∈ M for all phi in G-theory, psi in H-theory, is the set `{phi} ∪ G_theory(M) ∪ H_theory(M)` consistent?

**Analysis**: G-theory(M) consists of formulas `phi` such that `G(phi) ∈ M`. H-theory(M) consists of formulas `psi` such that `H(psi) ∈ M`. By the T-axioms (G(phi) → phi and H(psi) → psi), all these formulas are themselves in M. So `G_theory(M) ∪ H_theory(M) ⊆ M`. Therefore `{phi} ∪ G_theory(M) ∪ H_theory(M)` is consistent as a subset of the consistent seed `{phi} ∪ M` (which is consistent when phi is compatible with M, e.g., when F(phi) ∈ M).

This analysis shows **Path B is mathematically feasible**. The combined seed is consistent when F(phi) ∈ M, and Lindenbaum's lemma extends it to a full MCS. But we need to also verify:
1. The MCS W obtained by Lindenbaum preserves G-theory: G(phi) ∈ M → G(phi) ∈ W
2. The MCS W also preserves H-theory: H(psi) ∈ M → H(psi) ∈ W
3. These properties are maintained inductively through the chain

Point 2 is the novel requirement. In the current construction, only G-preservation is established. Proving H-preservation of the forward witness W would require:
- Include H(psi) for all psi in H-theory(M) in the seed
- Show the extended Lindenbaum MCS still contains these H(psi) formulas
- The key consistency check: does adding `F(phi) ∪ G_theory ∪ H_theory` to the seed remain consistent?

**Risk**: The Lindenbaum construction can add arbitrary formulas during extension. When constructing the forward witness for F(phi), the Lindenbaum extension might add neg(H(psi)) which contradicts H-preservation. This would need to be blocked by explicitly including H(psi) in the initial seed.

**Implementation estimate**: Implementing Path B would require:
1. New `temporal_theory_witness_both_directions`: builds MCS preserving both G and H theories
2. Modified chain step that uses this bidirectional witness
3. Proof that the resulting chain satisfies both `forward_F` and `backward_P`
4. Estimated effort: 15-25 hours of proof work

### Path C: Use the Restricted Family Approach (ALREADY IN CODEBASE)

The codebase contains `RestrictedTemporallyCoherentFamily` in SuccChainFMCS.lean (around line 5805). This structure provides both `forward_F` and `backward_P` for MCS restricted to a `deferralClosure` — which is a finite subset of formulas determined by the formula phi being proved.

The restriction to deferralClosure is necessary because F-nesting is unbounded in the general case (the deleted false theorems at lines 3104-3109 attempted to prove bounded F-nesting, which is false for arbitrary MCS).

**For completeness**, one approach is:
1. Given formula phi not provable from empty context
2. Build Lindenbaum MCS M containing neg(phi)
3. M is restricted to at most the formulas in the language of phi (by the compactness of the proof system)
4. Apply `RestrictedTemporallyCoherentFamily` to get a temporally coherent family for this restricted MCS
5. Apply the parametric truth lemma

However, the `RestrictedTemporallyCoherentFamily` requires a `DeferralRestrictedSerialMCS` as its seed — a special MCS whose F-obligations stay within `deferralClosure(phi)`. Whether an arbitrary MCS for negation of phi can be converted into such a form needs investigation.

---

## Evidence from Codebase

### Evidence that cross-direction coherence is necessary

From `ParametricTruthLemma.lean`, lines 320-332:
```lean
· -- Backward: forall s ≥ t, truth tau s psi -> G psi in MCS
  intro h_all
  obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
  let tcf : TemporalCoherentFamily D := { toFMCS := fam, forward_F := h_forward_F, ... }
  have h_all_mcs : ∀ s : D, t ≤ s → psi ∈ fam.mcs s := ...
  exact temporal_backward_G tcf t psi h_all_mcs
```

The `forward_F` must give witnesses in `fam` (not a different family), because `h_all_mcs` talks about `fam.mcs s`.

### Evidence that bundle-level is insufficient

From `UltrafilterChain.lean`, line 5144:
```
The gap between bundle-level and family-level coherence is the remaining blocker.
```

### Evidence that cross-direction sorry is fundamental

From `UltrafilterChain.lean`, lines 7377-7380:
```lean
· -- t < 0 but t' >= 0: need to show G persists from backward chain to forward chain
  sorry
· -- Both t < 0 and t' < 0
  -- Use P-preserving chain's H propagation (but need G propagation for backward chain)
  sorry
```

The comment "but need G propagation for backward chain" correctly diagnoses the issue: the backward chain was built to propagate H, not G.

### Evidence that the bidirectional seed approach is consistent

From the analysis of `temporal_theory_witness_exists` (used in `boxClassFamilies_bundle_forward_F`):
- Input: MCS M with F(phi) ∈ M
- Output: MCS W with phi ∈ W, G-theory of M preserved, box-class of M preserved
- The key consistency of the seed `{phi} ∪ G_theory(M) ∪ box_theory(M)` is proven

For a bidirectional version:
- Input: MCS M with F(phi) ∈ M
- Proposed output: MCS W with phi ∈ W, BOTH G-theory and H-theory of M preserved
- The consistency of `{phi} ∪ G_theory(M) ∪ H_theory(M)` follows because:
  - G_theory(M) ⊆ M (by T-axiom)
  - H_theory(M) ⊆ M (by T-past-axiom)
  - phi is compatible with M when F(phi) ∈ M (standard temporal witness argument)
  - Therefore `{phi} ∪ G_theory(M) ∪ H_theory(M) ⊆ {phi} ∪ M`, which is consistent

This confirms **Path B is mathematically sound**.

---

## Confidence Level

**High confidence** in the following claims:
- The cross-direction coherence problem is fundamental and cannot be avoided in the standard proof approach
- The truth lemma requires same-family witnesses (not an artifact of the current formalization)
- The `construct_bfmcs_bundle` is sorry-free and provides bundle-level coherence
- The CoherentZChain approach cannot be fixed without a fundamentally different chain construction
- A bidirectional seed construction (Path B) is mathematically consistent

**Medium confidence** in:
- Path B being implementable in ~15-25 hours (complexity of consistency proof may be higher)
- The `RestrictedTemporallyCoherentFamily` approach being applicable to the general completeness case

**Lower confidence** in:
- Whether the `omega_true_dovetailed_forward_F_resolution` sorry (line 7696) is fixable within the current dovetailed framework — the gap appears fundamental

---

## Summary of Recommendations

1. **Abandon the CoherentZChain path.** It cannot provide same-family coherence without a complete redesign. The 6 existing sorries at lines 7377, 7380, 7392, 7394, 7453, 7469 are all consequences of the asymmetric chain design.

2. **Pursue Path B: Bidirectional temporal witness construction.** This is mathematically sound. The key new lemma needed is:
   ```
   theorem temporal_theory_witness_bidirectional (M : Set Formula)
       (h_mcs : SetMaximalConsistent M) (phi : Formula) (h_F : F(phi) ∈ M) :
       ∃ W : Set Formula, SetMaximalConsistent W ∧ phi ∈ W ∧
         (∀ psi, G(psi) ∈ M → G(psi) ∈ W) ∧  -- G-preservation
         (∀ psi, H(psi) ∈ M → H(psi) ∈ W) ∧  -- H-preservation (NEW)
         box_class_agree M W
   ```

3. **Consider whether the restricted family approach (Path C) is sufficient for completeness.** The `DeferralRestrictedSerialMCS` and `RestrictedTemporallyCoherentFamily` already provide the needed structures. The question is whether every proof-theoretically appropriate MCS can be put in this form.

4. **Do not attempt to modify the truth lemma.** The requirement for same-family witnesses is mathematically inherent to the semantics, not an artifact of the current proof structure.

---

## Appendix: Key Source Locations

| Theorem/Definition | File | Lines | Status |
|---|---|---|---|
| `truth_at` (G and H semantics) | `Semantics/Truth.lean` | 118-125 | Sorry-free |
| `BFMCS.temporally_coherent` | `Bundle/TemporalCoherence.lean` | 218-221 | Definition |
| `parametric_canonical_truth_lemma` | `Algebraic/ParametricTruthLemma.lean` | 207-353 | Sorry-free |
| `temporal_backward_G` | `Bundle/TemporalCoherence.lean` | 165-178 | Sorry-free |
| `construct_bfmcs_bundle` | `Algebraic/UltrafilterChain.lean` | 5094-5105 | Sorry-free |
| `boxClassFamilies_bundle_forward_F` | `Algebraic/UltrafilterChain.lean` | 4884-4922 | Sorry-free |
| `CoherentZChain_to_FMCS.forward_G` | `Algebraic/UltrafilterChain.lean` | 7344-7380 | 2 sorries |
| `CoherentZChain_to_FMCS.backward_H` | `Algebraic/UltrafilterChain.lean` | 7381-7419 | 2 sorries |
| `CoherentZChain_forward_F` | `Algebraic/UltrafilterChain.lean` | 7429-7453 | 1 sorry |
| `CoherentZChain_backward_P` | `Algebraic/UltrafilterChain.lean` | 7462-7469 | 1 sorry |
| `omega_true_dovetailed_forward_F_resolution` | `Algebraic/UltrafilterChain.lean` | 7660-7696 | 1 sorry |
| `RestrictedTemporallyCoherentFamily` | `Bundle/SuccChainFMCS.lean` | 5805+ | Exists, sorry status unclear |
| `temporal_theory_witness_exists` | `Algebraic/UltrafilterChain.lean` | ~4880 | Appears sorry-free |
| Bundle coherence gap analysis | `Algebraic/UltrafilterChain.lean` | 5120-5147 | (comment) |
