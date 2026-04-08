# Research Report: Task #84 — Root Cause Analysis and Path Forward

**Task**: 84 — Establish Until/Since Coherence for Bundle Completeness
**Date**: 2026-04-08
**Mode**: Team Research (3 teammates)
**Session**: sess_1775675670_a7c71d

## Summary

Three teammates investigated the blockers from complementary angles: (A) root cause analysis of the G-lift failure and enriched seed consistency, (B) assessment of alternative approaches from task 83 and literature, (C) concrete new construction strategies. All three independently converged on the same conclusion: **the forward direction of `until_since_coherent` is blocked by a fundamental incompatibility between Lindenbaum extension freedom and Until formula persistence, identical to the `forward_F` blocker**. The enriched seed approach cannot be rescued. The mathematically correct path forward is to close backward Until/Since immediately and precisely scope the forward sorry.

## Key Findings

### 1. The Enriched Seed Approach Is Fundamentally Blocked (ALL teammates, 95% confidence)

The three-way seed `{target} ∪ g_content(w) ∪ {active Untils}` consistency CANNOT be proved:

- **G-lift argument fails**: The proof at `UltrafilterChain.lean:2272-2299` extracts target by deduction, then G-lifts ALL remaining premises. Until formulas lack `G(φ U ψ) ∈ M`, so they cannot participate in the G-lift. Partial G-lifting is impossible — `generalized_temporal_k` is a global context operation. (Teammate A)

- **Subset-of-MCS argument fails for target inclusion**: While `g_content(w) ∪ {active Untils} ⊆ w` (all elements in the MCS) and thus consistent alone, adding `{target}` breaks this: the deduction theorem gives `neg(target) ∈ w`, which is COMPATIBLE with `F(target) ∈ w` (target false now but true in future). So no contradiction arises. (Teammate A, rigorous analysis with concrete counterexample)

- **Multi-target generalization fails**: For multiple targets `{target₁,...,targetₖ}`, the deduction gives `G(¬(target₁ ∧ ... ∧ targetₖ)) ∈ M`, but we only have `F(targetᵢ) ∈ M` individually. Since `F(a) ∧ F(b) ⊬ F(a ∧ b)` in temporal logic, multi-target consistency is unproven. (Teammate C)

### 2. All Alternative Approaches Converge on the Same Blocker (Teammate B, 95% confidence)

| Approach | Mechanism | Why It Fails |
|----------|-----------|-------------|
| Enriched seed | Include Untils in Lindenbaum seed | Not G-liftable (Finding 1) |
| Bilateral tuples | Demand/supply pairing | Repackaging of quasimodel; same G-lift gap |
| Quasimodels (GHR 1994) | Constraint-satisfaction graph | Linearization breaks Until persistence through detours |
| Pull-before-push / F-reduction | BX10: (φ U ψ) → F(ψ), then forward_F | forward_F itself depends on Until persistence (circular) |
| Constant chain (x_content) | Deterministic under BX (X(α) ↔ α) | Chain is constant; forward Until trivially unsatisfiable when ψ ∉ M |
| BX4 propagation | α → G(P(α)) propagates P-information | P(φ U ψ) ∈ chain(n+1) gives past witness, not current truth |
| Negation unfolding | ¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ))) | INVALID by countermodel (task 83) |

### 3. Bundle-Level Coherence Is Blocked by Truth Lemma Structure (Teammate C, CONFIRMED)

An initially promising idea: weaken `until_since_coherent` to allow cross-family witnesses (using sorry-free `bundle_forward_F` at DovetailedChain.lean:1422-1437). However, Teammate C **verified directly** that:

- `Truth.lean:128`: Semantic Until evaluates along a SINGLE history (same family)
- `ParametricTruthLemma.lean:365-380`: The truth lemma's Until case uses `h_fwd_U t φ ψ h_U` which requires `ψ ∈ fam.mcs s` in the SAME family

The per-family requirement is baked into the semantics of Until, not just the coherence predicate. Changing this would require redefining the logic's semantics — not viable.

### 4. The Root Cause Is Lindenbaum Freedom vs. Persistence (ALL teammates)

The fundamental incompatibility:

1. **Lindenbaum extension freedom**: Each chain step `chain(n+1)` is a Lindenbaum extension of a seed. The extension can freely add `¬(φ U ψ)`, killing Until persistence.

2. **Seed constraint**: Only G-liftable elements can be in the seed (for the consistency proof). Until formulas are NOT G-liftable: `(φ U ψ) ∈ M` does not imply `G(φ U ψ) ∈ M`.

3. **Derivability gap**: `(φ U ψ)` is not derivable from `g_content(M)` alone. The unfolding `(φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))` works within a single MCS but does not transfer across Lindenbaum steps.

This is the SAME obstacle as `forward_F`: converting meta-level knowledge ("¬ψ at all future chain positions") to object-level `G(¬ψ) ∈ chain(t)` requires `temporal_backward_G`, which takes `forward_F` as a hypothesis — circular.

### 5. Backward Until/Since IS Closable (Teammates A and C, verified)

The backward directions (conjuncts 2 and 4) are fully proved in `UntilSinceCoherence.lean`, parameterized on step transfer. Six sorry-free theorems:
- `backward_until_reflexive`, `backward_since_reflexive` (base case)
- `backward_until_from_step`, `backward_since_from_step` (inductive, parameterized)
- `backward_until_coherent`, `backward_since_coherent` (BFMCS assembly)

The step transfer hypothesis requires chain-specific infrastructure that is NOT available from current constructions (g_content goes forward, h_content requires H-wrapped formulas). However, the parameterized proofs are correct and reusable.

### 6. The Completeness Proof's Until Case Uses Backward Coherence (Teammate B)

Critical structural observation: the completeness proof works by contrapositive. It takes validity → truth (semantic) → MCS membership (via truth lemma backward direction). The truth lemma's backward direction for Until uses BACKWARD Until coherence (conjunct 2): given semantic witnesses, derive `(φ U ψ) ∈ fam.mcs t`. This is the direction that IS available.

The forward direction of the truth lemma for Until uses FORWARD Until coherence (conjunct 1): given `(φ U ψ) ∈ fam.mcs t`, find semantic witnesses. This direction is needed for the forward truth lemma, which is used in the G-case backward direction (via temporal_backward_G → forward_F chain).

## Synthesis

### Conflicts Resolved

1. **Interleaved chain steps (Teammate A) vs. fundamental blocking (all)**:
   Teammate A proposed interleaving Until-resolution steps with F-resolution steps. However, they also identified that this approach requires F(ψ) to persist to the scheduling step, which fails for the same reason as Until persistence. Resolution: the interleaving idea is mathematically sound in concept but hits the SAME F-persistence blocker in practice. Confirmed by Teammate C's Strategy 3 analysis.

2. **Predicate split impact (Teammates B and C)**:
   Teammate B initially suggested splitting might allow closing sorry sites. Teammate C verified the truth lemma structure and confirmed: the full truth lemma (bidirectional iff) requires both forward and backward coherence. The completeness proof uses the backward direction (semantic → syntactic), which uses backward Until coherence. However, the G-case in the truth lemma creates an indirect dependency on forward coherence via forward_F. Resolution: splitting the predicate clarifies the dependency structure but does NOT close any Completeness.lean sorry site by itself — those need the full `until_since_coherent` because the truth lemma takes it as a single parameter.

3. **Bundle-level workaround viability**:
   Teammates A and B did not investigate this path. Teammate C investigated and CONFIRMED it is blocked by Truth.lean:128 and ParametricTruthLemma.lean:365-380. Resolution: definitively ruled out.

### Gaps Remaining

1. **Forward Until/Since coherence**: This is the precise gap. It requires a mechanism to ensure `ψ` eventually appears in the SAME family chain, which in turn requires either Until persistence through Lindenbaum steps (blocked) or a fundamentally new chain construction.

2. **The forward_F / temporal_backward_G circularity**: This is the deeper structural issue. Forward_F, forward_Until, and temporal_backward_G are all mutually dependent. Breaking any one of these would likely break the others. The restricted chain path (SuccChainFMCS) has sorry-free restricted_forward_F, but `until_since_coherent` quantifies over ALL formulas, not just the deferral closure.

3. **Whether a restricted `until_since_coherent` could work**: If forward Until coherence were restricted to formulas in the deferral closure, the restricted chain's forward_F might suffice. This has not been explored.

### Recommendations

**Immediate (85% confidence, ~200-300 LOC)**:
1. Split `until_since_coherent` into `backward_until_since_coherent` (conjuncts 2,4) and `forward_until_since_coherent` (conjuncts 1,3)
2. Refactor the truth lemma to accept these separately
3. Provide backward coherence for all three construction paths
4. Leave forward coherence as a precisely scoped sorry
5. This narrows the sorry surface and makes the dependency structure explicit

**Medium-term research directions**:
1. **Restricted forward Until**: Investigate whether restricting forward Until to the deferral closure allows using the restricted chain's sorry-free forward_F
2. **Simultaneous well-founded induction**: Prove forward_F and forward_Until simultaneously by induction on formula complexity or subformula depth
3. **Quasimodel replacement**: Replace the Lindenbaum chain construction entirely with a constraint-satisfaction approach (~2000 LOC, 50% confidence)

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|-----------------|
| A | G-lift root cause analysis | completed | Rigorous proof that enriched seed consistency fails: G-lift is incompatible with subset-of-MCS argument; neg(target)/F(target) coexistence kills the hybrid approach |
| B | Alternative approaches review | completed | Comprehensive assessment of 5 alternatives showing all converge on same blocker; structural observation about truth lemma using backward coherence |
| C | New construction strategies | completed | Verified 5 concrete strategies against codebase; confirmed bundle-level approach blocked by Truth.lean semantics; multi-target seed fails due to F(a)∧F(b) ⊬ F(a∧b) |

## References

- `UltrafilterChain.lean:2272-2299` — `temporal_theory_witness_with_g_consistent` (G-lift argument)
- `UntilSinceCoherence.lean` — Backward Until/Since parameterized proofs (6 sorry-free theorems)
- `TemporalCoherence.lean:466-479` — `until_since_coherent` definition (per-family, 4 conjuncts)
- `TemporalDerived.lean:385-484` — `x_implies_id`, `until_intro`, `or_until_imp`, etc.
- `DovetailedChain.lean:1422-1437` — Bundle-level `forward_F` (sorry-free but cross-family)
- `DovetailedChain.lean:1296-1307` — Per-family `DovetailedFMCS_forward_F` (sorry, same blocker)
- `Truth.lean:128` — Semantic Until evaluation (single history)
- `ParametricTruthLemma.lean:365-380` — Truth lemma Until case (same-family witnesses)
- `SuccChainFMCS.lean:2033` — `targeted_g_content_seed_consistent` (restricted chain infrastructure)
- `SuccExistence.lean:456-498` — `constrained_successor_seed_consistent` (subset-of-MCS pattern)
- Task 83 reports 24, 28, 38 — Prior analysis of quasimodels, forward_F blocker, enriched seeds
- Task 84 reports 01-03 — Prior synthesis, team research, implementation summary
