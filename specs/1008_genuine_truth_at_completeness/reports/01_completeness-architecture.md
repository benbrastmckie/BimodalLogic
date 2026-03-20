# Research Report: Task #1008

**Task**: Establish genuine truth_at completeness theorems for TM logic
**Date**: 2026-03-20
**Focus**: Architecture analysis and viable approaches for real completeness

## Summary

The TM logic is a bimodal system (S5 modality + linear tense over ordered abelian group D). Genuine completeness requires constructing a countermodel using `truth_at` over a `TaskFrame D` with convex `WorldHistory` structures. The parametric infrastructure (ParametricCanonicalTaskFrame, ParametricTruthLemma, ParametricRepresentation) is already sorry-free and correctly uses `truth_at` with `domain = True` (trivially convex). The core open problem is constructing a multi-family `BFMCS D` with both modal and temporal coherence for a concrete D.

## Findings

### What Is Already Sorry-Free and Uses truth_at

The parametric infrastructure is the legitimate foundation:

| Module | Key Definitions | Sorry-Free? |
|--------|----------------|-------------|
| ParametricCanonical.lean | `ParametricCanonicalTaskFrame D` — TaskFrame with WorldState = MCS, sign-based task relation | Yes |
| ParametricHistory.lean | `parametric_to_history` — FMCS D → WorldHistory with `domain = True` (trivially convex) | Yes |
| ParametricTruthLemma.lean | `parametric_canonical_truth_lemma` — `phi in fam.mcs t <-> truth_at ... t phi` | Yes |
| ParametricRepresentation.lean | `parametric_algebraic_representation_conditional` — given BFMCS D construction, proves countermodel | Yes |
| CanonicalFMCS.lean | `canonicalMCSBFMCS` — FMCS over CanonicalMCS with sorry-free F/P witnesses | Yes |

**Critical insight**: `parametric_to_history` uses `domain = True` (all of D), making convexity trivial. This completely sidesteps the convexity problem that killed the FlagBFMCS bridge.

### The Conditional Representation Theorem

The existing `parametric_algebraic_representation_conditional` has this shape:

```
Given: construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
         Σ' (B : BFMCS D) (h_tc : B.temporally_coherent)
            (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
            M = fam.mcs t

Proves: ¬provable φ → ¬valid φ   (i.e., valid φ → provable φ)
```

The entire completeness proof reduces to providing `construct_bfmcs` for a specific D.

### The Two Independent Blockers

#### Blocker 1: Temporal Coherence (forward_F / backward_P)

**The problem**: When building a linear chain of MCSs indexed by D = Int, Lindenbaum extension at position n+1 can introduce `G(~phi)`, which kills `F(phi)` at earlier positions. The F-witness MCS produced by `canonical_forward_F` is in the full CanonicalMCS space — not guaranteed to be any position in the constructed chain.

**What works**: The CanonicalFMCS construction over CanonicalMCS proves F/P trivially because every MCS is in the domain. But CanonicalMCS is a tree-like Preorder, not an ordered abelian group.

**Sorries**: IntBFMCS.lean lines 1175, 1177, 1199, 1213

#### Blocker 2: Modal Coherence (modal_backward)

**The problem**: A singleton BFMCS (one family) requires `phi in fam.mcs t → Box(phi) in fam.mcs t`, which degenerates to `phi → Box(phi)` — false in S5. Counterexample: `{Diamond(p), neg(p)}` is consistent.

**What works**: Multiple families are needed. The FlagBFMCS approach uses all Flags with Box-content saturation, achieving modal_backward. But it operates with `satisfies_at`, not `truth_at`.

**Sorries**: MultiFamilyBFMCS.lean line 287, IntFMCSTransfer.lean line 134, CanonicalEmbedding.lean line 231

### Viable Approaches

#### Approach A: D = Int with Universal Domain (Recommended Starting Point)

Use `D = Int` with WorldHistories having `domain = True` (full domain, trivially convex). The parametric infrastructure already supports this. The remaining challenge is constructing `BFMCS Int` with:

1. **Multiple FMCS families** — one per "modal world" (Box-equivalence class of MCSs)
2. **Each family indexed by Int** with `forward_G` / `backward_H` (G-content containment along the chain)
3. **Modal coherence** across families (modal_forward + modal_backward)
4. **Temporal coherence** within each family (forward_F / backward_P)

**Key advantage**: `domain = True` eliminates convexity concerns entirely. The truth lemma is already proven for this case.

**Key difficulty**: forward_F/backward_P for Int-indexed chains.

#### Approach B: Omega-Squared Construction

Build each Int-indexed FMCS family using an omega-squared (ω²) construction:

1. **Stage 0**: Start with seed MCS M₀ at position 0
2. **Stage n**: For each F-obligation `F(phi)` in any MCS at positions ≤ n:
   - Find the canonical F-witness MCS (guaranteed to exist by `canonical_forward_F`)
   - Insert it at the next available position
3. **Lindenbaum extension**: Only AFTER all required witnesses are placed, extend gaps via Lindenbaum

This ensures F-witnesses are placed before Lindenbaum can kill them. The construction is more complex but avoids the fundamental limitation of simple iterative extension.

**Consideration**: Only finitely many subformulas of the original formula are relevant, so the F-obligations are bounded.

#### Approach C: Transfer from CanonicalMCS via Order Embedding

CanonicalFMCS over CanonicalMCS has sorry-free F/P. If we can:

1. Find an order-embedding `e : CanonicalMCS → Int` (or Rat)
2. Transfer the FMCS structure along this embedding
3. Prove the transferred structure satisfies temporal coherence

Then we get a sorry-free `BFMCS Int` (or Rat). The challenge: the CanonicalMCS ordering is a Preorder (not even a partial order without the antisymmetry proof). Individual Flags (maximal chains) ARE linearly ordered and countable, so they embed into Rat by Cantor's theorem. But:

- The embedding image is scattered (not convex in Rat) — however, with `domain = True` this doesn't matter
- The embedding needs to preserve the temporal coherence properties through the transfer

**Key question**: Can `parametric_to_history` be applied to a chain embedded in Rat, using `domain = True`?

#### Approach D: Separate Base / Dense / Discrete

Different approaches may work for different cases:

| Variant | D | Additional Challenge |
|---------|---|---------------------|
| Base | Int (any LOAG) | Just need multi-family BFMCS Int |
| Dense | Rat | Need density witnesses between chain positions |
| Discrete | Int | Need SuccOrder/PredOrder instances (Task 974) |

The base case may be simplest: use `D = Int` and avoid density/discreteness complications. Dense and discrete cases add axiom-specific obligations.

### The Modal Dimension: Multi-Family Construction

For S5 modal logic, the BFMCS needs enough families for modal saturation:

- **modal_forward** (easy): `Box(phi) in fam.mcs t → phi in fam'.mcs t` for all families fam'. Uses S5 T-axiom.
- **modal_backward** (hard): `(∀ fam' ∈ B, phi ∈ fam'.mcs t) → Box(phi) ∈ fam.mcs t`. Requires multiple families.

**Standard approach**: For each MCS M at time t, the "modal equivalence class" consists of all MCSs sharing Box-content with M. The families in BFMCS should sample ALL such equivalence classes. Then modal_backward follows by: if `phi` is in every family's MCS at t, and every Box-equivalence class is represented, then `Box(phi)` must be in M (otherwise `Diamond(~phi)` is in M, which gives an MCS where `~phi` holds — but `phi` is in that family's MCS at t, contradiction).

This standard argument works at the MCS level. The challenge is making it work simultaneously with the temporal chain construction.

### Current Sorry Count in Relevant Infrastructure

| File | Sorries | Nature |
|------|---------|--------|
| IntBFMCS.lean | 4 | forward_F/backward_P for Int chains (fundamental) |
| MultiFamilyBFMCS.lean | 2 | modal_backward for singleton (fundamental for singletons) |
| IntFMCSTransfer.lean | 1 | modal_backward (same blocker) |
| CanonicalEmbedding.lean | 5 | Rat FMCS F/P + modal_backward + root |
| CanonicalQuot.lean | 3 | System consistency + Formula countability (solvable) |
| AlgebraicBaseCompleteness.lean | 2 | Deprecated wiring |

### Relationship to Existing Tasks

| Task | Status | Relationship to 1008 |
|------|--------|---------------------|
| 997 | IMPLEMENTING | Base completeness — blocked on same BFMCS construction; approach should be informed by 1008 |
| 988 | RESEARCHING | Dense completeness — blocked on same blockers; 12 plan versions exhausted |
| 989 | RESEARCHING | Discrete completeness — blocked on Task 974 (SuccOrder) + same BFMCS construction |
| 1006 | RESEARCHED | Replaced by 1007+1008; was trying to bridge satisfies_at to truth_at |

Task 1008 provides the unified architectural direction. Tasks 997/988/989 track the individual completeness legs and should adopt whatever approach 1008 identifies.

## Recommendations

1. **Start with base completeness (D = Int)** — it has the fewest complications (no density/discreteness axioms)
2. **Focus on the multi-family BFMCS construction** — this is the single blocking problem
3. **Use `domain = True` WorldHistories** — convexity is trivially satisfied, leveraging existing parametric infrastructure
4. **Investigate the omega-squared construction** (Approach B) as the most promising resolution of the F/P blocker
5. **Consider whether the CanonicalMCS → Int transfer** (Approach C) can be made to work with the PartialOrder instance from FlagBFMCSRatBundle (to be extracted before archival in Task 1007)

## Key Questions for Planning

1. Can an omega-squared construction avoid the Lindenbaum extension problem for F-witnesses?
2. Is there a way to construct multi-family BFMCS Int directly, rather than transferring from CanonicalMCS?
3. Can the modal saturation and temporal saturation be done independently and then combined?
4. Should the approach use a finite subformula set to bound the construction, or work with the full formula language?

## References

- Burgess (1984), "Basic Tense Logic" — step-by-step construction for linear temporal completeness
- Goldblatt (1992), "Logics of Time and Computation" — bulldozing technique for canonical models
- Blackburn, de Rijke, Venema (2001), "Modal Logic" — canonical models for multimodal logics
- Existing codebase: ParametricCanonical.lean, ParametricTruthLemma.lean, ParametricRepresentation.lean

## Next Steps

After Task 1007 archives the satisfies_at infrastructure, proceed to `/plan 1008` to design the multi-family BFMCS construction. The plan should address both the temporal (F/P) and modal (multi-family) challenges simultaneously.
