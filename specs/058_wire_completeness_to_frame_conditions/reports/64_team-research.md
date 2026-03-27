# Research Report: Task #58 — Blocker Analysis & Path Forward Comparison

**Task**: 58 - wire_completeness_to_frame_conditions
**Date**: 2026-03-27
**Session**: sess_1774628958_89784c
**Mode**: Team Research (2 teammates, math domain)

## Summary

Both teammates converge on a clear conclusion: **Option A (restricted construction) is the only viable path, and the blocker is fixable**. The `boundary_resolution_set` definition has a genuine flaw allowing chi and neg(chi) to coexist, but adding a mutual exclusion condition (Fix A1) resolves it. Option B (direct BFMCS_Bundle to TaskModel via forward-only truth lemma) is definitively ruled out — the imp case creates an unavoidable backward IH dependency on G/H subformulas that requires family-level temporal coherence.

## Key Findings

### 1. The Blocker Is Real and Confirmed (Teammate A, High Confidence)

The `boundary_resolution_set` definition at SuccExistence.lean:284-286 allows both chi AND chi.neg to be in BRS simultaneously:
- For chi ∈ BRS: F(chi) ∈ u ∧ FF(chi) ∉ deferralClosure
- For chi.neg ∈ BRS: F(chi.neg) ∈ u ∧ FF(chi.neg) ∉ deferralClosure
- These are fully independent (both F(chi) and F(¬chi) can hold in temporal logic)
- The seed therefore can contain {chi, ¬chi}, which is inconsistent

The helper lemma `neg_not_in_boundary_resolution_set` (SuccChainFMCS.lean:1412) has a sorry and is unprovable with the current definition. The file itself documents all failed proof paths at lines 1371-1409.

### 2. Fix A1: Mutual Exclusion Condition (Teammate A, Medium-High Confidence)

**Recommended fix**: Add `Formula.some_future chi.neg ∉ u` to BRS definition:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.some_future chi.neg ∉ u}   -- NEW: mutual exclusion
```

**Why this preserves BRS purpose**: When F(chi) ∈ u and F(¬chi) ∈ u simultaneously, BOTH "eventually chi" and "eventually not-chi" hold. In this case, we should NOT force chi into the successor — the Lindenbaum extension (maximality) should determine chi's status. The deferralDisjunction `chi ∨ F(chi) ∈ u` (in the seed from F(chi) ∈ u) ensures the F-obligation is still handled.

**Impact on downstream proofs**: After Fix A1:
- `neg_not_in_boundary_resolution_set` becomes a 3-line proof by contradiction
- `constrained_successor_seed_restricted_consistent` can proceed via: non-BRS part ⊆ u (proven), BRS elements have no contradictory pairs (by mutual exclusion)
- F-witness propagation: when chi is excluded from BRS (because F(¬chi) ∈ u), the deferralDisjunction ensures `chi ∨ F(chi)` is in the seed, so the Lindenbaum extension produces either chi or F(chi)

### 3. Option B Is NOT Viable (Teammate B, High Confidence)

Report 61's Option B ("forward-only truth lemma for BFMCS_Bundle") fails because:

1. **The imp case backward IH blocker**: The forward direction of `neg(φ) ∈ M → ¬truth_at ... φ` (where `neg(φ) = φ.imp bot`) requires: if `truth_at ... φ`, then `φ ∈ M` (backward direction for φ). When φ contains G/H subformulas, this backward direction requires family-level temporal coherence.

2. **The G/H backward case fundamental barrier**: `G(ψ) ∈ fam.mcs t ← ∀ s ≥ t, truth_at ... ψ` requires contradicting with a ¬ψ-witness in the SAME family. BFMCS_Bundle's `bundle_forward_F` gives witnesses in ANY family, not necessarily the same one. Since truth_at for non-box formulas depends on the specific history, different-family witnesses don't produce contradictions.

3. **No known workaround**: Report 50 correctly identified this as an inherent structural barrier. Teammate B confirms it cannot be worked around with "forward-only" arguments because the completeness proof itself (via negation) forces the backward direction.

4. **Option B-Prime** (new bundle G/H backward strategy) would require a mathematical breakthrough — very high risk, not recommended.

### 4. Option A Is the Only Path (Both Teammates, High Confidence)

The restricted construction (family-level coherence within subformulaClosure(φ)) is the correct approach:
- RestrictedTemporallyCoherentFamily provides family-level F/P coherence
- FMCS provides forward_G/backward_H within each family
- The biconditional restricted_truth_lemma can be used for completeness
- Only the seed consistency proof blocks this path, and Fix A1 addresses it

## Synthesis

### Conflicts Resolved

**One conflict identified and resolved**:

Teammate B initially states "Option B (forward-only truth lemma for BFMCS_Bundle) is the correct path" in finding #1, but then through detailed analysis concludes "NOT directly feasible" and "Option A remains the most promising path." This internal revision within Teammate B's analysis resolved naturally — the initial claim was made before the imp-case backward IH blocker was fully analyzed. The final conclusion is consistent with Teammate A's finding.

### Gaps Identified

1. **Fix A1 downstream verification**: After modifying `boundary_resolution_set`, we need to verify that ALL downstream lemmas that depend on BRS membership still hold. Key ones:
   - `boundary_resolution_set_subset_constrained_successor_seed_restricted`
   - `mem_constrained_successor_seed_restricted_iff`
   - All lemmas in SuccChainFMCS.lean that reference BRS

2. **F-witness propagation with Fix A1**: When both F(chi) ∈ u and F(¬chi) ∈ u, chi is excluded from BRS. Need to formally verify that the deferralDisjunction mechanism ensures the restricted chain still has F-witnesses for chi.

3. **Consistency proof strategy**: Even with mutual exclusion, the seed has BRS elements NOT in u. The full consistency proof still needs a formal argument showing no finite L ⊆ seed derives ⊥. Teammate A sketches this (replace BRS elements with F(chi) ∈ u) but the formal details need working out.

### Recommendations

1. **Implement Fix A1** on `boundary_resolution_set` (SuccExistence.lean:284-286)
2. **Propagate the definition change** through all downstream lemmas
3. **Complete `constrained_successor_seed_restricted_consistent`** using the mutual-exclusion-enabled neg-exclusion argument
4. **Also fix `augmented_seed_consistent`** (SuccChainFMCS.lean:1480) — reduces to the above
5. **Do NOT pursue Option B** in any form
6. **Do NOT revert to `chi ∈ u` condition** (Fix A3) — defeats BRS purpose

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Blocker analysis & Option A fixes | completed | high |
| B | Option B feasibility analysis | completed | high |

## Approaches Definitively Ruled Out (Updated)

| Approach | Why Blocked | Reference |
|----------|-------------|-----------|
| Forward-only truth lemma (BFMCS_Bundle) | imp case backward IH needs G/H family-level coherence | Teammate B, reports 17, 50 |
| Option B-Prime (new bundle G/H strategy) | Requires mathematical breakthrough; very high risk | Teammate B |
| Bundle-level as truth lemma input | G backward needs same-family witness | Reports 45, 50, Teammate B |
| Omega-enumeration for arbitrary MCS | Doesn't exist, never implemented | Report 60 |
| Fix A3 (add chi ∈ u to BRS) | Defeats BRS purpose — makes it vacuous | Teammate A |

## File References

| File | Key Lines | Content |
|------|-----------|---------|
| SuccExistence.lean | 284-286 | `boundary_resolution_set` definition (FIX HERE) |
| SuccExistence.lean | 261-264 | Original chi ∈ u design comment |
| SuccChainFMCS.lean | 1371-1409 | Commentary documenting failed proof paths |
| SuccChainFMCS.lean | 1412-1435 | `neg_not_in_boundary_resolution_set` (sorry, unprovable) |
| SuccChainFMCS.lean | 1507-1543 | `constrained_successor_seed_restricted_consistent` (root sorry) |
| SuccChainFMCS.lean | 1480 | `augmented_seed_consistent` (sorry, reduces to above) |
| CanonicalConstruction.lean | 492-628 | `canonical_truth_lemma` (shows backward G/H needs coherence) |
| ParametricTruthLemma.lean | 325-458 | `parametric_shifted_truth_lemma` (requires `temporally_coherent`) |
| UltrafilterChain.lean | 2758-2877 | BFMCS_Bundle (sorry-free, but bundle-level only) |
| Completeness.lean | 186-214 | `bundle_validity_implies_provability` (target sorry) |
