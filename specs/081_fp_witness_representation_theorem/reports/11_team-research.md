# Research Report: Task #81 — F/P Witness Blocker Analysis

**Task**: 81 — F/P Witness Representation Theorem
**Date**: 2026-04-01
**Mode**: Team Research (4 teammates)
**Session**: sess_1775066091_02e055

## Summary

All four teammates converge on the same fundamental mathematical obstruction: the G-lift consistency argument requires ALL seed elements to be G-liftable, but the Succ relation requires non-G-liftable elements (deferralDisjunctions, p_step_blocking). This obstruction affects every approach (A through G). However, a clear path forward emerges from combining insights across teammates: use the already sorry-free `temporal_theory_witness_exists` to construct a full MCS witness, then restrict it to deferralClosure to obtain a valid DRM successor. This bypasses the targeted seed consistency problem entirely.

## Key Findings

### The Fundamental Obstruction (All Teammates Agree)

The G-lift argument (used in `temporal_theory_witness_consistent` and `forward_temporal_witness_seed_consistent`) is the ONLY known proof technique for chain successor consistency. It requires every element in the derivation context to be G-liftable (i.e., G(x) ∈ u for each x in the context). The Succ relation demands seed elements that are NOT G-liftable:

- **deferralDisjunctions** (`ψ ∨ F(ψ)`): G-liftability requires `G(F(ψ)) ∈ u`, which is strictly stronger than `F(ψ) ∈ u`
- **p_step_blocking** (`H(¬χ)`): G-liftability requires `G(H(¬χ)) ∈ u`, equivalent to `always(¬χ)`, far stronger than `H(¬χ) ∈ u`

This obstruction is structural, not incidental — it cannot be worked around by clever case analysis.

### Option A: Targeted Seed (Teammate A)

**Verdict: The full targeted_restricted_seed_consistent is DEAD, but a reduced variant is viable.**

- The full seed `{target} ∪ g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking(u)` cannot be proven consistent via G-lift because of non-G-liftable components
- The "subset of consistent set" argument fails: `u ∪ {target}` is NOT consistent when `¬target ∈ u` (possible when `F(target) ∈ u`)
- The MCS extension approach, hybrid deduction-G-lift, and DRM G-lift all hit the same wall
- **However**: The reduced seed `{target} ∪ g_content(u)` IS provably consistent by direct analogy with `forward_temporal_witness_seed_consistent` (WitnessSeed.lean:79, sorry-free)
- **Recommended variant**: Prove consistency of reduced seed, extend to DRM via Lindenbaum, rely on DRM maximality to pick up deferralDisjunctions and p_step_blocking automatically

**Confidence**: LOW for full seed, MEDIUM-HIGH for reduced seed variant

### Option B: Filtered f_content (Teammate B)

**Verdict: REJECTED — adds complexity without solving the core problem.**

- Filtered f_content (`{ψ ∈ f_content(u) | ¬ψ ∉ f_content(u)}`) removes direct contradictory pairs
- Cross-component contradictions are ruled out by existing structural lemmas
- **But indirect contradictions remain**: a set without `{A, ¬A}` pairs can still derive ⊥
- The same cut/transfer metatheorem is needed whether using filtered or full f_content
- The simplified seed approach (already implemented) achieves the same forward_F via bounded F-nesting with TRIVIAL consistency
- Safe formulas get 1-step resolution vs up to `closure_F_bound` steps, but worst case is identical

**Confidence**: MEDIUM-HIGH that it's mathematically correct, but NOT RECOMMENDED due to unnecessary complexity

### Option C: Dovetailed Chain (Teammate C)

**Verdict: MOST PROMISING — use `temporal_theory_witness_exists` to build full MCS witnesses, then restrict to DRM.**

Key discoveries:
- `temporal_theory_witness_exists` (UltrafilterChain.lean:2212) is sorry-free and provides full MCS witnesses with G-agree and box_class_agree
- `DovetailedChain.lean` has 605 lines of sorry-free infrastructure: forward_step, forward_dovetailed chain, G-propagation, H-propagation, box_class_agree
- F-persistence is NOT needed for the DRM approach — bounded F-nesting within deferralClosure forces resolution
- The `restricted_truth_lemma` (line 291, sorry-free) handles evaluation for subformulaClosure formulas

**The breakthrough insight**: Use `temporal_theory_witness_exists` to construct a full MCS witness W containing the target with G-agree. Then restrict W to deferralClosure via `deferral_restricted_lindenbaum` or direct intersection to obtain a valid DRM successor. This entirely bypasses the need to prove targeted_restricted_seed_consistent.

**Confidence**: HIGH for overall approach, MEDIUM for bridging full MCS to DRM

### Option D: Alternatives E-G (Teammate D)

**Verdict: All alternatives REJECTED, but provided crucial sorry map.**

- **Alternative E** (direct semantic model): Does NOT avoid forward_F — the F-case in the truth lemma is the same problem
- **Alternative F** (FMP/compactness): FMP blocked by semantic mismatch (strict vs reflexive temporal operators, 2 sorries in TruthPreservation.lean). Ultraproduct impractical (~1000+ lines)
- **Alternative G** (direct sorry fix): Reduces to the same G-lift obstruction

**Critical sorry map**: Only 1 sorry blocks `completeness_over_Int`: `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237). Everything else in `bundle_validity_implies_provability` is sorry-free. The restricted truth lemma (line 291) is sorry-free and does NOT depend on the 2 sorries at lines 116 and 158.

**Confidence**: HIGH for sorry analysis, LOW-MEDIUM for any single approach

## Synthesis

### Conflicts Resolved

1. **F-persistence necessity**: Teammates A and D emphasize that F-persistence fails for Lindenbaum chains (DovetailedChain.lean:587 conclusion). Teammate C counters that F-persistence is NOT NEEDED for DRM chains because bounded F-nesting forces resolution. **Resolution**: Both are correct. F-persistence fails for full MCS chains (unbounded), but is unnecessary for DRM chains (bounded deferralClosure). The DRM path does not require F-persistence.

2. **Viability of Option A**: Teammate A rates it LOW, Teammate D rates it as "most promising." **Resolution**: They agree when qualified — the FULL targeted seed is dead, but the REDUCED seed `{target} ∪ g_content(u)` is viable. The disagreement is about the downstream DRM extension step, where Teammate C's "construct full MCS then restrict" approach may resolve it.

3. **DovetailedChain.lean conclusion**: Teammate D cites "THIS APPROACH FUNDAMENTALLY DOESN'T WORK" from line 587. Teammate C argues the conclusion applies to full MCS forward_F only, not to the DRM bounded approach. **Resolution**: The DovetailedChain conclusion is specific to full MCS same-family forward_F with Lindenbaum chains. The DRM approach circumvents this via bounded nesting.

### Gaps Identified

1. **The "construct full MCS, then restrict to DRM" step**: Nobody has verified that W ∩ deferralClosure (or the DRM restriction of W) satisfies Succ properties. Specifically: does the restricted set maintain g_content persistence, p_step blocking, and the F/P temporal content properties?

2. **The Succ properties of a DRM built from `{target} ∪ g_content(u)`**: If we extend this seed to a DRM via `deferral_restricted_lindenbaum`, does the resulting DRM automatically satisfy the full Succ relation with the parent u?

3. **Whether `deferral_restricted_lindenbaum` applied to a set that is consistent within deferralClosure automatically yields a DRM with the right Succ properties**: This is the core technical question that no teammate fully resolved.

### The Recommended Path Forward

**Strategy: Full MCS Witness → DRM Restriction (combining Teammates A and C)**

1. Given DRM u with F(target) ∈ u, extend u to full MCS M via Lindenbaum
2. Apply `temporal_theory_witness_exists` to M and target → get full MCS W with:
   - target ∈ W (F-obligation resolved)
   - G-agree: G(a) ∈ M → G(a) ∈ W
   - box_class_agree(M, W)
3. Define successor_drm = `deferral_restricted_lindenbaum` applied to `W ∩ deferralClosure(phi)` (or the seed derived from W's closure-restricted formulas)
4. Prove Succ(u, successor_drm):
   - g_content(u) ⊆ successor_drm: From G-agree, G(a) ∈ M → a ∈ g_content(M) → since successor_drm extends W's formulas in closure, a should be in successor_drm
   - p_step: From DRM maximality within deferralClosure
   - target ∈ successor_drm: From target ∈ W and DRM extension
5. Build chain using this construction, one targeted step per F-obligation
6. Prove forward_F via bounded F-nesting (no F-persistence needed)
7. Prove completeness via `restricted_truth_lemma` (sorry-free)

**Key advantage**: This approach uses ONLY sorry-free infrastructure (`temporal_theory_witness_exists`, `forward_temporal_witness_seed_consistent`, `deferral_restricted_lindenbaum`, `restricted_truth_lemma`). No existing sorry needs to be closed.

**Key risk**: Step 4 (Succ properties of the DRM restriction) is unverified. This is the single technical question that needs resolution before committing to implementation.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A | Targeted seed consistency | completed | Low (full) / Med-High (reduced) | Reduced seed `{target} ∪ g_content(u)` IS provably consistent |
| B | Filtered f_content | completed | Medium-High | Rejected: same metatheorem needed, no benefit over simplified seed |
| C | Dovetailed chain | completed | High (DRM) / Med (bridge) | Full MCS witness → DRM restriction bypasses seed consistency |
| D | Alternatives + sorry map | completed | Low-Medium | Only 1 sorry blocks completeness; all alternatives E-G rejected |

## References

- `WitnessSeed.lean:79` — `forward_temporal_witness_seed_consistent` (sorry-free)
- `UltrafilterChain.lean:2212` — `temporal_theory_witness_exists` (sorry-free)
- `DovetailedChain.lean` — Sorry-free forward/backward chain infrastructure
- `RestrictedTruthLemma.lean:291` — `restricted_truth_lemma` (sorry-free)
- `RestrictedMCS.lean` — `deferral_restricted_lindenbaum` (sorry-free)
- `SuccChainFMCS.lean:2082` — The blocked sorry (`constrained_successor_seed_restricted_consistent`)
- `FrameConditions/Completeness.lean:237` — The sole blocking sorry (`bfmcs_from_mcs_temporally_coherent`)
- `SimplifiedChain.lean:195` — `targeted_restricted_seed_consistent` sorry (from Phase 1 implementation)
