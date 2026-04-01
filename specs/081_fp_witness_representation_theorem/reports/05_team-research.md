# Research Report: Task #81 — Team Research Run 5

**Task**: 81 - F/P Witness Representation Theorem
**Date**: 2026-03-31
**Mode**: Team Research (4 teammates)
**Focus**: Analyze plan 04 failures, find a clean systematic approach that works
**Session**: sess_1775012439_2677c6

## Summary

All 4 teammates converge on a single conclusion: **the restricted completeness path via `DeferralRestrictedSerialMCS` is the correct and only viable approach**. The unrestricted dovetailed construction from plan 04 is fundamentally blocked by the F-liftability problem, which all teammates independently confirmed is a genuine mathematical impossibility (not a formalization gap). The restricted construction already has sorry-free `forward_F` and `backward_P` — the only remaining blocker is a single sorry in the seed consistency proof (`constrained_successor_seed_restricted_consistent` at SuccChainFMCS.lean:2082).

## Key Findings

### 1. Plan 04 Failure Analysis: Three Blockers Are Mathematically Fundamental

All teammates confirmed:

**H-blocker G-lift problem**: `neg(H(chi)) ∈ M` does NOT imply `G(neg(H(chi))) ∈ M`. There is no axiom that G-lifts arbitrary formulas. The controlled seed consistency proof in plan 04 required this step and cannot work.

**F-persistence problem**: Lindenbaum extensions can freely add `G(neg(psi))` when it is consistent with the seed, permanently killing `F(psi)`. Since `G(neg(psi))` is NOT in `temporal_box_seed(M)` (it's not G-liftable), there's nothing in the seed preventing Lindenbaum from adding it.

**Cross-zero forward_G problem**: The backward chain can introduce G-formulas via Lindenbaum that weren't in M_0, violating forward_G. Including infinite G-blocker sets creates consistency proof complexity that cannot be resolved.

**Root cause** (Teammate C): Plan 04 conflated "F(psi) ∈ M" with "F(psi) can be G-lifted". The G-lift consistency argument from `temporal_theory_witness_consistent` ONLY works for formulas `x` where `G(x) ∈ M`. For F-formulas, `G(F(psi)) = G(neg(G(neg(psi))))` is NOT derivable from `F(psi) ∈ M`. This was confirmed by Teammate D using a concrete LTL countermodel: F(p) at time 0 does not imply G(F(p)) at time 0 when p holds only at time 1.

**All alternative unrestricted approaches reduce to the same blocker** (Teammates B, D):
- Compactness via product topology: same controlled-seeding at its core
- Modified Lindenbaum: IS the restricted construction for the cases where it works
- Bi-infinite chain: doesn't help (problem is seeding, not directionality)
- Ultrafilter-level: ultrafilter_F_resolution exists but isn't connected to chain-level F-persistence

### 2. The Restricted Construction Already Works (Modulo One Sorry)

**What exists (sorry-free)**:
| Theorem | File:Line | Status |
|---------|-----------|--------|
| `restricted_forward_chain_forward_F` | SuccChainFMCS:2930 | SORRY-FREE |
| `restricted_backward_chain_backward_P` | SuccChainFMCS:5462 | SORRY-FREE |
| `build_restricted_tc_family` | SuccChainFMCS:5866 | SORRY-FREE |
| `restricted_truth_lemma` | RestrictedTruthLemma:291 | SORRY-FREE |
| `restricted_ext_neg_excludes_phi` | RestrictedTruthLemma:381 | SORRY-FREE |
| `constrained_successor_restricted_f_content_persistence` | SuccChainFMCS:2153 | SORRY-FREE |

**The single critical sorry**: `constrained_successor_seed_restricted_consistent` at SuccChainFMCS.lean:2082. This is the consistency proof for the restricted seed, which includes `f_content(u)` (the key innovation enabling one-step F-resolution).

**Three fuel=0 sorries** (lines 5386, 5544, 5740): In semantically unreachable branches of fueled recursion. Need either a fuel-sufficiency proof or restructuring to well-founded recursion.

### 3. Why The Restricted Construction Avoids All Three Blockers

**No H-blocker G-lift**: The restricted seed uses `p_step_blocking_formulas_restricted(phi, u)` — these are `H(neg(psi))` formulas that are provably in `u` (SuccExistence:162-171). No G-lifting needed.

**No F-persistence problem**: `f_content(u)` is directly in the seed. Every F-obligation resolves in exactly ONE step. Lindenbaum cannot add `G(neg(psi))` because psi is already in the seed. Witness is always `n + 1`:
```lean
theorem restricted_forward_chain_forward_F ... :=
  ⟨n + 1, by omega, restricted_forward_chain_F_resolves phi M0 n psi h_F⟩
```

**No cross-zero problem**: The `RestrictedTemporallyCoherentFamily` builds separate forward and backward Nat-indexed chains joined at M_0. Cross-direction coherence (forward_G backward, backward_H forward) follows from g_content/h_content duality (`g_content_subset_implies_h_content_reverse`) — the same sorry-free technique already used in the unrestricted SuccChainFMCS.

### 4. Completeness Only Needs Restricted Families

The completeness argument (all teammates agree):
1. phi not provable → neg(phi) consistent
2. Build `DeferralRestrictedSerialMCS` over `deferralClosure(phi)` containing neg(phi) (via `build_restricted_serial_mcs_from_neg_consistent`, line 2419)
3. Build `RestrictedTemporallyCoherentFamily` via `build_restricted_tc_family`
4. Apply `restricted_truth_lemma` — DRM membership ↔ Lindenbaum extension membership for `subformulaClosure(phi)` formulas
5. Since neg(phi) ∈ DRM at time 0, phi is NOT in the Lindenbaum-extended MCS at time 0 (`restricted_ext_neg_excludes_phi`)
6. Wire through to completeness via the parametric representation framework

This is the standard subformula-closure technique from modal logic completeness proofs (Blackburn-de Rijke-Venema §4.2). Working within the finite deferralClosure is mathematically correct, not a hack.

### 5. The Consistency Sorry: Analysis and Proof Strategy

The seed `constrained_successor_seed_restricted phi u` contains 5 components:
```
g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_restricted(phi, u)
             ∪ boundary_resolution_set(phi, u) ∪ f_content(u)
```

Components 1-3 are provably ⊆ u (hence consistent). The problematic components are:
- **f_content(u)**: psi where F(psi) ∈ u. These psi may NOT be in u.
- **boundary_resolution_set**: chi where F(chi) ∈ u but FF(chi) ∉ deferralClosure and F(chi.neg) ∉ u. These chi may NOT be in u.

**Teammate D's key insight**: For BRS elements chi where F(chi.neg) IS in deferralClosure: by DRM negation completeness, since F(chi.neg) ∉ u, we get G(chi) ∈ u, so chi ∈ g_content(u) — the BRS element is redundant. The hard case is when F(chi.neg) ∉ deferralClosure.

**Proof strategies identified**:
1. **Teammate A**: Substitution lemma via excluded middle — replace non-u elements with negations, reducing count by strong induction
2. **Teammate D**: Case analysis on F(chi.neg) ∈ deferralClosure — when yes, BRS redundant; when no, restricted-derivability argument (neg(chi) can't be derived from seed within deferralClosure)
3. **Teammate B**: Hypothesis strengthening — add deferralClosure membership preconditions to make seed ⊆ u for relevant formulas

## Synthesis

### Conflicts Resolved

**Conflict 1**: Teammates A and D disagreed on whether the consistency sorry is "narrow" (A) vs. "non-trivial" (D). Resolution: it is mathematically correct but requires non-trivial Lean formalization. The proof strategy is identified but the derivation-tree manipulation in Lean is technically demanding.

**Conflict 2**: Teammate C rated Option B at 40% success while B rated it at 85%. Resolution: The discrepancy is about what counts as "success." C included the BFMCS bridge (converting restricted families to the full parametric framework), which IS harder. B focused only on filling the restricted construction's sorries, which is more tractable. The recommended approach acknowledges both tiers.

### Gaps Identified

1. **The consistency sorry** (SuccChainFMCS:2082) — the single mathematical gap
2. **Fuel=0 sorries** (3 locations) — structural, not mathematical
3. **BFMCS bridge** — wiring restricted families into the parametric completeness infrastructure. Two sub-options:
   - **Option A** (lower risk): Modify `parametric_algebraic_representation_conditional` to accept restricted BFMCS
   - **Option B** (cleaner): Build full BFMCS using boxClassFamilies for modal saturation + restricted chains for temporal coherence

### Recommendations

**Primary path**: Fill the consistency sorry + fuel=0 sorries, then wire through to completeness. Estimated effort: 6-10 hours.

**Fallback**: If the consistency sorry proves harder than expected, investigate whether the truth lemma can be satisfied WITHOUT the strong f_content inclusion — using only deferralDisjunctions (weak f_step) combined with the bounded nesting depth of deferralClosure to show that SOME resolution step exists within the bounded depth.

**Abandon**: The unrestricted dovetailed construction from plan 04. It is fundamentally blocked and no amount of engineering can circumvent the F-liftability impossibility.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Constrained successor analysis | completed | HIGH — restricted path is correct |
| B | Alternative approaches | completed | HIGH (85%) — restricted best path |
| C | Risk analysis / gap mapping | completed | MEDIUM (40%) — BFMCS bridge is uncertain |
| D | Devil's advocate / gap-free plan | completed | HIGH on restricted, LOW on unrestricted |

## References

- SuccChainFMCS.lean — restricted chain infrastructure (forward_F, backward_P, build_restricted_tc_family)
- SuccExistence.lean — constrained_successor_seed (restricted and unrestricted), consistency proofs
- SuccRelation.lean — Succ relation definition (g_content, f_step)
- RestrictedTruthLemma.lean — restricted truth lemma and completeness wiring
- ParametricRepresentation.lean — parametric_algebraic_representation_conditional interface
- ParametricTruthLemma.lean — how forward_F/backward_P are used in truth lemma
- DovetailedChain.lean — 605 lines documenting why unrestricted approaches fail
- UltrafilterChain.lean — bundle-level F/P (cross-family, insufficient for completeness)
- Blackburn, de Rijke, Venema. "Modal Logic" §4.2 — subformula-closure completeness technique
