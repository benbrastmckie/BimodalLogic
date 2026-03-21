# Research Report: Task #925 (Round 2)

**Task**: Redesign BMCS completeness construction using MCS accessibility relation
**Date**: 2026-02-25
**Mode**: Team Research (2 teammates)
**Focus**: Corrected four constraints (BoxG/BoxH), seed-based unraveling vs canonical frame construction, TruthLemma for ALL families

## Summary

This research round re-examines the construction with the **corrected specification** of the four constraints involving `Box G` and `Box H` (not bare `G`/`H` or `Box`). The key findings are:

1. **BoxGContent is WEAKER than GContent** (not stronger) - this makes BoxGContent seeds less useful
2. **The C2 (backward) constraint is NOT automatically satisfied** by forward construction
3. **The constraints decompose into modal + temporal layers** - suggesting the existing architecture may be closer to correct than Round 1 suggested
4. **A fundamental tension exists** between the TruthLemma holding for ALL families and the constant witness family impossibility

## The Correct Four Constraints

The user's specification divides into:

### Definitional Constraints (defining w -> u):
| # | Constraint | Formal | Content Inclusion |
|---|------------|--------|-------------------|
| C1 | Forward | phi in u IF Box G phi in w | BoxGContent(w) ⊆ u |
| C2 | Backward | phi in w IF Box H phi in u | BoxHContent(u) ⊆ w |

### Saturation Constraints (existence):
| # | Constraint | Formal |
|---|------------|--------|
| C3 | Forward | neg Box G phi in w ⟹ ∃u: (w -> u) ∧ neg phi in u |
| C4 | Backward | neg Box H phi in u ⟹ ∃w: (w -> u) ∧ neg phi in w |

### New Required Definitions

```lean
BoxGContent(M) := {phi | Box(G phi) in M}  -- NOT equivalent to GContent or BoxContent
BoxHContent(M) := {phi | Box(H phi) in M}  -- NOT equivalent to HContent or BoxContent
```

## Key Findings

### Finding 1: BoxGContent ⊂ GContent (Strictly Weaker)

Both teammates independently established:

```
Box(G phi) in w
  → G phi in w         (by modal T: Box psi → psi)
  → phi in GContent(w)
```

Therefore: **BoxGContent(w) ⊆ GContent(w)**

The reverse does NOT hold: `G phi in w` does NOT imply `Box(G phi) in w` because there is no axiom deriving `G phi → Box(G phi)` in TM logic.

**Implication**: Using BoxGContent as a seed provides LESS information than the existing CanonicalR (which uses GContent). This is the WRONG direction for strengthening the construction.

### Finding 2: Accessibility Relation is Reflexive

**Claim**: For any MCS w, `w -> w` holds.

**Proof**:
- C1: BoxGContent(w) ⊆ w holds because Box(G phi) in w → G phi in w (modal T) → phi in w (temporal T)
- C2: BoxHContent(w) ⊆ w holds by symmetric argument

This ensures the task relation's **nullity** constraint.

### Finding 3: Accessibility Relation is NOT Transitive

**Problem** (from Teammate A): If `w -> u` and `u -> v`, we need BoxGContent(w) ⊆ v for `w -> v`.

From w -> u: Box(G phi) in w ⟹ phi in u
From u -> v: Box(G psi) in u ⟹ psi in v

To get phi in v, we need Box(G phi) in u. But we only have phi in u (not Box(G phi) in u).

Transitivity would require `phi → Box(G phi)` which is NOT a theorem.

**Resolution**: The task relation uses **compositionality through histories**, not transitivity of the base accessibility. A history `h: Int → MCS` connects consecutive MCSs via `->`, and `task_rel w d v` is defined by existence of a path, not by a single `->` step.

### Finding 4: C3 Seed Consistency IS Provable

**Claim**: If `neg(Box G phi) in w` and w is MCS, then `{neg phi} ∪ BoxGContent(w)` is consistent.

**Proof sketch** (Teammate A):
1. Suppose inconsistent: {neg phi, chi₁,...,chi_n} ⊢ ⊥ where Box(G chi_i) in w
2. By deduction theorem: {chi₁,...,chi_n} ⊢ phi
3. Apply **generalized BoxG K**: from {chi₁,...,chi_n} ⊢ phi, derive {Box(G chi₁),...,Box(G chi_n)} ⊢ Box(G phi)
4. By MCS closure: Box(G phi) in w
5. Contradicts neg(Box G phi) in w with MCS consistency

**The generalized BoxG K** follows from composing temporal K with modal K.

### Finding 5: The Critical C2 Gap

**Problem**: When constructing forward witness u for C3:
- Seed = {neg phi} ∪ BoxGContent(w)
- Lindenbaum extension gives u with C1 satisfied: BoxGContent(w) ⊆ u ✓
- BUT C2 requires: BoxHContent(u) ⊆ w
- The Lindenbaum extension can add arbitrary Box(H psi) formulas!

**This is a critical obstruction**: The forward construction does NOT guarantee the backward constraint.

### Finding 6: Decomposition of BoxG into Modal + Temporal Layers

**Key Insight** (Teammate A):
```
BoxG phi = Box(G phi)
        = Box layer applied to G layer
```

The BMCS architecture already separates:
- **Modal layer**: modal_forward, modal_backward (Box formulas across families)
- **Temporal layer**: forward_G, backward_H (G/H formulas across times)

The BoxG constraint naturally decomposes:
- `Box(G phi) in fam.mcs(t)`
- ⟹ (by modal_forward) `G phi in fam'.mcs(t)` for all fam'
- ⟹ (by forward_G) `phi in fam'.mcs(s)` for all fam' and s ≥ t

This suggests the existing two-layer architecture (BMCS + BFMCS) is **structurally correct**. The challenge is making non-constant families work.

### Finding 7: TruthLemma for ALL Families Requires Temporal Coherence for ALL Families

The user's correction states: **TruthLemma must hold for ALL families**, not just the eval family.

For the G case (backward direction), the proof uses:
1. If G phi NOT in fam.mcs(t), then F(neg phi) in fam.mcs(t)
2. By forward_F: exists s ≥ t with neg phi in fam.mcs(s)
3. Contradiction with phi true at all s ≥ t

This requires **every family** to have forward_F and backward_P.

**The fundamental tension**:
- Witness families for modal saturation are typically constant
- Constant families CANNOT satisfy forward_F/backward_P (proven in research-005 for task 924)
- Non-constant witness families face Lindenbaum uncontrollability

## Conflict Analysis

### Disagreement: Teammate B vs User Correction

Teammate B continues to recommend the "restructured truth predicate" approach from Round 1, where:
- TruthLemma only needs to hold for the eval family
- Witness families only need syntactic membership

However, the user explicitly stated this is WRONG: TruthLemma must hold for ALL families.

### Analysis of the Conflict

The restructured truth predicate changes the Box case from:
```lean
| .box phi => ∀ fam' ∈ B.families, bmcs_truth_at B fam' t phi  -- recursive
```
to:
```lean
| .box phi => ∀ fam' ∈ B.families, phi ∈ fam'.mcs t  -- syntactic
```

If the TruthLemma must hold for ALL families, then for the Box case:
- Forward: Box phi in fam.mcs(t) ⟹ (by modal_forward) phi in fam'.mcs(t) for all fam'
- Backward: phi in fam'.mcs(t) for all fam' ⟹ (by modal_backward) Box phi in fam.mcs(t)

Both directions use MCS membership (syntactic), not recursive truth. So the restructured truth predicate IS EQUIVALENT to the original when applied to BMCS with modal_forward/backward.

**The real question**: Does proving `phi ∈ fam'.mcs(t)` for all fam' require the IH `phi ∈ fam'.mcs(t) ↔ bmcs_truth_at fam' t phi`?

For the Box case: NO. We directly use modal_forward/backward which relate MCS membership across families.

For the G case in witness families: YES. The backward direction (phi true at all future times ⟹ G phi in MCS) requires contraposition using F-witnesses.

**Conclusion**: The tension is real. If TruthLemma must hold for ALL families including witness families, those witness families need forward_F, which constant families cannot provide.

## Synthesis: The Path Forward

### The Core Problem (Restated)

The BMCS completeness proof requires:
1. **Temporal coherence for ALL families** (forward_F, backward_P for TruthLemma G/H cases)
2. **Modal saturation** (witness families for Diamond formulas)
3. **Non-constant witness families** (to satisfy #1)
4. **Controllable construction** (Lindenbaum extensions that satisfy both C1 and C2)

The existing approaches fail at different points:
- DovetailingChain: Fails #1 (sorries in forward_F, backward_P)
- CanonicalMCS: Achieves #1 for ONE family, but modal saturation (#2) adds constant families failing #1
- CoherentBundle: Achieves #2 with constant families, but constant families fail #1

### What the BoxG/BoxH Constraints Suggest

The corrected constraints point toward:
1. **BoxGContent/BoxHContent as the correct content definitions** for inter-MCS accessibility
2. **The C2 gap as the critical obstacle** to forward witness construction
3. **Histories as sequences of MCSs** connected by the `->` relation
4. **Multi-family construction** where each family is a non-constant history

### Possible Resolution Paths

**Path A: Joint Bidirectional Lindenbaum**
- Construct witness u for C3 with BOTH C1 and C2 constraints
- Seed must include: {neg phi} ∪ BoxGContent(w) ∪ {psi | Box(H psi) in u ⟹ psi in w}
- This is circular (u is what we're constructing)
- May require simultaneous construction of w-u pairs

**Path B: Separate Forward/Backward Relations**
- Define `w →_G u` using only C1
- Define `w →_H u` using only C2
- Histories respect both: `h(t) →_G h(t+1)` AND `h(t) →_H h(t+1)`
- Saturation constraints give witnesses for each separately
- Challenge: ensuring BOTH hold for constructed histories

**Path C: The BoxG/BoxH Decomposition**
- Use the insight that BoxG = Box ∘ G
- Keep existing BFMCS for temporal (G/H) with GContent
- Keep existing BMCS modal coherence with BoxContent
- The BoxG constraints emerge from composition
- Focus on making non-constant witness families temporally coherent

**Path D: Restrict Families to Canonical Histories**
- All families are histories through CanonicalMCS
- Each history `h: Int → CanonicalMCS` satisfies h(t) -> h(t+1)
- Modal saturation: instead of adding constant families, add NEW histories passing through witness MCSs
- This gives non-constant witness families that inherit temporal coherence

## Recommendations

### Primary Recommendation: Investigate Path D

The most promising direction is constructing **non-constant witness families** as histories through CanonicalMCS:

1. **Domain**: CanonicalMCS (all MCSs with CanonicalR preorder)
2. **Eval family**: `canonicalMCSBFMCS` using identity mapping
3. **Witness families**: For Diamond(psi) in fam.mcs(t), construct a NEW HISTORY `h'` where:
   - h'(t) is an MCS containing psi and satisfying C1/C2 with fam.mcs(t-1) and fam.mcs(t+1)
   - h' extends forward/backward from h'(t) as a CanonicalR chain
   - h' is a temporally coherent non-constant family

**Challenge**: Ensuring h'(t) can be constructed to satisfy all constraints simultaneously.

### Secondary Recommendation: Revisit the C2 Constraint

The C2 gap suggests examining whether:
1. C2 is essential (can the TruthLemma work without it?)
2. C2 can be achieved through a different construction technique
3. The backward saturation (C4) naturally provides C2 for certain families

### What NOT to Pursue

1. **Constant witness families** - proven impossible for temporal coherence
2. **BoxGContent seeds as an improvement** - BoxGContent is weaker than GContent
3. **The Big Seed approach** - still faces fundamental conflicts
4. **Restricting TruthLemma to eval family** - user has indicated this is wrong

## Teammate Contributions

| Teammate | Angle | Key Contribution |
|----------|-------|------------------|
| A | Canonical frame construction | BoxGContent ⊂ GContent, C2 gap identified, reflexivity proven, generalized BoxG K, decomposition insight |
| B | Seed-based unraveling | Confirmed BoxGContent weaker, structural temporal-modal conflict, constraint (3) requires F-witness in witness family |

## Confidence Level

**MODERATE (60%)** for Path D (non-constant witness families as histories)
- The approach is mathematically sound in principle
- Critical unresolved issue: simultaneous satisfaction of C1 + C2 for constructed MCSs

**LOW (30%)** for seed-based approaches
- BoxGContent provides less, not more
- The C2 gap is a fundamental obstruction

**Uncertainty factors**:
- The C2 constraint satisfaction mechanism is unclear
- Joint bidirectional Lindenbaum extension is non-standard
- The interplay between multiple non-constant families is complex

## Open Questions

1. **Can C1 and C2 be satisfied simultaneously for constructed witness MCSs?**
2. **Is there a "bidirectional Lindenbaum" technique that builds w and u together?**
3. **Can the CanonicalR infrastructure be extended to build non-constant witness families?**
4. **Does the BoxG decomposition provide a clear construction path?**
5. **What is the minimum set of families needed for completeness?**

## References

- `Theories/Bimodal/Semantics/TaskFrame.lean` - Frame structure with task_rel, nullity, compositionality
- `Theories/Bimodal/Semantics/WorldHistory.lean` - Histories as functions from time to world state
- `Theories/Bimodal/Semantics/Truth.lean` - Truth evaluation (Box over families, G/H over times)
- `Theories/Bimodal/ProofSystem/Axioms.lean` - MF, TF, T-axioms for Box/G/H
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - CanonicalR uses GContent
- `Theories/Bimodal/Metalogic/Bundle/CanonicalBFMCS.lean` - Sorry-free forward_F, backward_P
- `specs/924_prove_fully_saturated_bmcs_exists_modal_temporal/reports/research-005.md` - Constant family impossibility proof
