# Research Report: Task #93 — Forward_F Blocker Deep Analysis

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-13
**Mode**: Team Research (4 teammates)
**Session**: sess_1776093046_bee91a

## Summary

Four researchers investigated the forward_F blocker from complementary angles: biased Lindenbaum feasibility (A), canonical frame alternatives (B), critical analysis and gap identification (C), and literature/strategic horizons (D). The unanimous conclusion is that the **current dovetailed chain construction is fundamentally incompatible with forward_F**, and the most viable path forward is **restricted temporal coherence** combined with a modified chain construction.

## Key Findings

### 1. Biased Lindenbaum Is Not Viable (Teammate A, confirmed by C)

The biased Lindenbaum approach—extending the resolving seed `{σ} ∪ g_content(M)` to preferentially include F-formulas—does not solve the blocker.

**The single-F consistency claim is FALSE.** Teammate A provided a concrete counterexample:

> M contains F(p), F(q), G(p → G(¬q)).
> Resolving seed for p: {p} ∪ g_content(M) which includes (p → G(¬q)).
> From {p, p → G(¬q)}: derive G(¬q) = ¬F(q).
> Therefore {p} ∪ g_content(M) ∪ {F(q)} is inconsistent.

This is semantically valid: q holds BEFORE p (at s₂ < s₁), so F(q) at t and G(p → G(¬q)) at t are compatible, but resolving p kills F(q).

**The G-lifting argument does not extend.** The existing `forward_temporal_witness_seed_consistent` proof works because the contradiction involves the SAME formula under F and G(¬...). For a different F-formula F(ψ), the G-lift only gives G(σ → G(¬ψ)) ∈ M, which yields F(G(¬ψ)) via F(σ), but F(ψ) ∧ F(G(¬ψ)) is semantically consistent (second BX11 disjunct: F(ψ ∧ F(G(¬ψ)))).

**Zorn-based Lindenbaum is uncontrollable.** The existing `set_lindenbaum` uses `zorn_subset_nonempty`, and every MCS trivially satisfies the "biased" condition. The bias set has no effect.

**Confidence**: High (90%) that biased Lindenbaum alone is not viable.

### 2. Canonical Frame Approach Is Structurally Incompatible (Teammate B, C)

The canonical frame from `CanonicalFrame.lean` proves forward_F trivially (each F-obligation gets a fresh Lindenbaum witness). However:

- The parametric infrastructure requires `FMCS D` where D has `AddCommGroup + LinearOrder + IsOrderedAddMonoid`. A tree-shaped canonical frame violates `LinearOrder D`.
- Embedding the tree into a linear chain is the original problem we're trying to solve.
- Code rewrite estimated at 1000+ lines of core infrastructure (truth lemma, history, frame, representation).
- The SuccExistence.lean deferral seed (`g_content(u) ∪ {χ ∨ F(χ) | F(χ) ∈ u}`) offers an alternative approach to preserving F-obligations via resolve-or-defer semantics.

**Confidence**: Very Low (10%) for canonical frame as a viable path within current architecture.

### 3. Restricted Temporal Coherence Is the Most Promising Path (Teammates C, D)

`BFMCS.restricted_temporally_coherent root` (defined at TemporalCoherence.lean:295) only requires forward_F for formulas in `deferralClosure(root)`, which is FINITE.

**Key verification (Teammate C):** The truth lemma's induction only invokes forward_F on `neg(ψ)` where `ψ` is a subformula of root (via the G backward case). Since `neg(ψ) ∈ closureWithNeg(root) ⊆ deferralClosure(root)`, restricted coherence suffices.

**Advantages:**
- `deferralClosure(root)` is finite (bounded by ~4 × |subformulas(root)| + constant)
- Finite scope makes priority-based resolution schedules deterministic
- Full completeness theorem follows (restriction is per-formula, not global)
- Existing definitions in TemporalCoherence.lean can be reused

**Main gap:** No active restricted truth lemma exists. The Boneyard version is deprecated (strict semantics). A new bridge lemma or adapted truth lemma is needed (~200-400 lines).

**Confidence**: High (80%) for restricted temporal coherence as viable path.

### 4. Literature Uses Tree-Shaped Frames, Not Linear Chains (Teammate D)

Standard tense logic completeness proofs (Goldblatt 1992, Burgess 1984, Venema 1993, Gabbay-Hodkinson-Reynolds 1994) do NOT use fixed Int-indexed chains. They use:
- The full canonical frame (tree of all MCS, F-witness trivially proved)
- Step-by-step growing linear orders (inserting witness points at each stage)

The current `int_chain` approach is non-standard and encounters the persistence problem precisely because it forces a fixed linear chain to satisfy obligations that require tree-branching.

The reflexive/strict tension (F allows s = t but coherence demands s > t) is NOT the root cause. The root cause is inter-obligation interference in Lindenbaum extensions.

### 5. Until/Since Coherence Is a Separate Blocker (Teammate C)

Gap 3 from Teammate C: `bx_bfmcs_buc` and `bx_bfmcs_fuc` (Until/Since coherence) have independent sorries. None of the three proposed approaches directly address these. They require either:
- A step-transfer property for the chain (for backward Until)
- An eventuality extraction argument (for forward Until)

These may become tractable once the chain construction is resolved, but should be tracked separately.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate C | Resolution |
|----------|-----------|-----------|------------|
| Single-F consistency | FALSE (counterexample) | TRUE (G-lift argument) | **A is correct.** C's G-lift argument has an error: it only gives G(σ → G(¬ψ)) ∈ M, not G(¬ψ) ∈ M. The implication doesn't yield the consequent without G(σ). |
| Enriched seed always consistent? (Gap 5) | Not investigated | "counterexample may be unsound" | **The counterexample IS sound.** C's semantic argument contained an error (assumed F(χ) at s₁ implies χ at s₃ > s₁, but under reflexive semantics F(χ) at s₁ can be false if χ only at s₂ < s₁). |
| Approach recommendation | Restricted coherence or canonical frame | Combined 1+3 (restricted + biased) | **Restricted coherence is the primary path.** Since single-F biased Lindenbaum is unsound, the combined approach doesn't add value over restricted coherence alone. |

### Gaps Remaining

1. **No active restricted truth lemma** — Must be written or bridged (~200-400 lines)
2. **Until/Since coherence** — Independent blocker, not addressed by any proposed approach
3. **Priority schedule design** — With restricted coherence, how exactly to schedule resolutions over the finite set
4. **Step-transfer property** — Needed for backward Until coherence (`backward_until_from_step` requires a chain-level step transfer)

### Recommendations

**Primary path: Restricted Temporal Coherence (Approach 3)**

1. Write a restricted truth lemma (or bridge lemma) showing that `restricted_temporally_coherent root` suffices for evaluating formulas in `subformulaClosure(root)`
2. Modify the chain construction to use a formula-specific schedule over `deferralClosure(root)` instead of the generic Denumerable schedule
3. Prove forward_F for the FINITE set of formulas in `deferralClosure(root)` using a deterministic resolution order informed by BX11 (temporal linearity)
4. Update `bx_construct_bfmcs` and `bx_countermodel` to use restricted coherence
5. Adapt the representation theorem to accept restricted coherence

**Estimated effort**: 400-600 lines of new code, primarily:
- Restricted truth lemma bridge (~200 lines)
- Modified chain construction for finite formula set (~150 lines)
- Updated bridge/countermodel wiring (~50 lines)
- Forward Until/Since coherence (~100-200 lines)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Biased Lindenbaum | completed | High |
| B | Canonical Frame / Alternatives | completed | Medium |
| C | Critic | completed | High |
| D | Literature / Horizons | completed | High |

## References

- Goldblatt 1992, *Logics of Time and Computation* — tree-shaped canonical frames
- Burgess 1984, *Basic Tense Logic* — Until induction axioms
- Xu 1988, *Completeness for Until-Since on Linear Orders*
- Venema 1993 — temporal logic completeness with canonical frames
- Gabbay, Hodkinson, Reynolds 1994 — comprehensive temporal logic foundations
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean:295` — restricted_temporally_coherent
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean:133` — canonical_forward_F (trivial proof)
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` — backward_until_from_step
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — deferral seed construction
