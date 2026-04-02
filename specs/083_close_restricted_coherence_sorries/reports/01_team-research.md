# Research Report: Task #83

**Task**: Close Restricted Coherence Sorries
**Date**: 2026-04-02
**Mode**: Team Research (2 teammates)
**Session**: sess_1743623400_r83m

## Summary

Team investigation reveals that of the 4 target sorries, only 2 are genuine blockers -- the UltrafilterChain.lean sorries (`succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P`). The RestrictedTruthLemma sorries are dead code. The fundamental obstacle is the **G-lift gap**: every chain construction approach fails to guarantee F-obligation resolution because Lindenbaum extensions can introduce G(neg(phi)) before the scheduler resolves F(phi). Both teammates converge on **bypassing the existing sorries** rather than filling them in, via a restructured completeness proof that uses only restricted temporal coherence.

## Key Findings

### 1. Sorry Decomposition: 2 Real + 2 Dead Code

Both teammates independently confirmed:

| Sorry | Location | Status | Impact |
|-------|----------|--------|--------|
| `succ_chain_restricted_forward_F` | UltrafilterChain.lean:3762 | **REAL BLOCKER** | Blocks completeness |
| `succ_chain_restricted_backward_P` | UltrafilterChain.lean:3772 | **REAL BLOCKER** | Blocks completeness |
| `restricted_chain_G_propagates` | RestrictedTruthLemma.lean:116 | Dead code (0 refs) | None |
| `restricted_chain_H_step` | RestrictedTruthLemma.lean:158 | Dead code (0 refs) | None |

**Confidence**: HIGH (85%+). Both teammates verified via grep that the RestrictedTruthLemma sorries have zero references.

### 2. Exact Goal States (from Teammate A)

**Sorry 1** (`succ_chain_restricted_forward_F`):
```lean
S : SerialMCS
root : Formula
n : Int
psi : Formula
h_dc : psi ∈ deferralClosure root
h_F : psi.some_future ∈ succ_chain_fam S n
⊢ ∃ m, n ≤ m ∧ psi ∈ succ_chain_fam S m
```

**Sorry 2** (`succ_chain_restricted_backward_P`):
```lean
S : SerialMCS
root : Formula
n : Int
psi : Formula
h_dc : psi ∈ deferralClosure root
h_P : psi.some_past ∈ succ_chain_fam S n
⊢ ∃ m ≤ n, psi ∈ succ_chain_fam S m
```

Both operate on the **full MCS chain** (`succ_chain_fam`), not the restricted DRM chain. This is the core difficulty: restricted coherence exists at the DRM level but must be lifted to full MCS level.

### 3. The G-Lift Gap is the Universal Bottleneck

Every approach attempted hits the same wall (confirmed by both teammates):

| Approach | Why It Fails |
|----------|-------------|
| Full MCS chain with weak f_step | No mechanism to force F-resolution; perpetual deferral possible |
| Restricted chain with f_content in seed | Seed provably inconsistent (`constrained_successor_seed_restricted_consistent` marked FALSE) |
| Simplified chain with targeted seed | G-lift gap: non-G-liftable elements in seed break the technique |
| Dovetailed fair scheduling | F-formulas don't persist through Lindenbaum extensions |
| Forward-only truth lemma | Implication case requires backward direction |
| Bundle-level coherence | Truth lemma inherently bidirectional |

### 4. deferralClosure is Finite but Finiteness Alone is Insufficient

- `deferralClosure(phi)` is a `Finset Formula` (union of closureWithNeg, deferralDisjunctionSet, backwardDeferralSet, serialityFormulas)
- It bounds F-nesting depth at a single time point
- But across time, F-obligations can be perpetually deferred even within bounded closure (the deferral disjunction `psi ∨ F(psi)` lets Lindenbaum always pick `F(psi)`)

### 5. Dovetailed Chain Documented as Fundamentally Blocked

DovetailedChain.lean (605 lines, 0 sorries in proofs) contains extensive design analysis (lines 287-605) documenting why F-persistence through Lindenbaum extensions fails. Key quote (line 587): "THIS APPROACH FUNDAMENTALLY DOESN'T WORK for same-family forward_F with Lindenbaum-based chains."

### 6. Prior Art Confirms Structural Mismatch

Standard canonical completeness (Goldblatt, BdRV) uses flat MCS sets where forward_F is trivial. TM task semantics requires linear families (timelines), making this genuinely harder. No standard reference provides a direct solution. The closest approach (Gabbay/Hodkinson/Reynolds fair scheduling) works for simpler logics without the S5 modal interaction that creates the G-liftability problem.

## Synthesis

### Conflicts Resolved

**Conflict 1: Is `build_restricted_tc_family` sorry-free?**

- Teammate A claims it depends on the FALSE `constrained_successor_seed_restricted_consistent`
- Teammate B claims it is sorry-free at SuccChainFMCS.lean:6313

**Resolution**: This requires verification during implementation. Teammate A traced a dependency chain: `build_restricted_tc_family` -> `restricted_forward_chain_F_resolves` -> `constrained_successor_restricted_f_content_persistence` -> `constrained_successor_restricted` -> `constrained_successor_seed_restricted_consistent` (FALSE). If this chain is accurate, the restricted infrastructure is also unsound and Teammate B's "90% sorry-free" claim is overstated. **Action item**: Verify this dependency chain with `lean_verify` or careful manual tracing during planning.

**Conflict 2: Recommended approach**

- Teammate A recommends: New chain construction using only `{target} ∪ g_content(M)` as seed with fair scheduling
- Teammate B recommends: Direct restricted completeness bypassing UltrafilterChain sorries via truth lemma restructuring

**Resolution**: These are complementary, not conflicting. Both agree the existing sorry locations should be bypassed rather than filled. The difference is:
- Teammate A's approach constructs a new chain with proven F-resolution
- Teammate B's approach restructures the truth lemma to need less from the chain

The most promising strategy combines both: **use a chain construction that provides single-step F-resolution (like Teammate A's `{target} ∪ g_content(M)` seed) and restructure the truth lemma to only require single-step coherence properties (Teammate B's insight that the truth lemma only recurses on subformulas, which are all in the closure)**.

### Gaps Identified

1. **`build_restricted_tc_family` soundness**: Critical to verify whether it depends on the FALSE theorem. If unsound, the "90% sorry-free" restricted infrastructure claim collapses.

2. **Truth lemma G-propagation dependency**: Both teammates note that the truth lemma for G(chi) at time t needs chi at all future times. Does it need this syntactically (G-propagation through the chain) or can it use semantic reasoning (IH + frame properties)? Teammate B's analysis (from Report 20) suggests the latter may work but this is unverified.

3. **Backward direction (P-resolution)**: Most analysis focuses on forward_F. The backward_P sorry is symmetric but the backward chain construction may have different properties. Needs explicit analysis.

4. **Constrained Lindenbaum consistency**: If the primary approach fails, Approach 4 (constrained Lindenbaum extension preserving G-theory) requires a new consistency proof for `restricted_chain(n+1) ∪ g_content(ext(n))`. No existing lemma covers this.

### Recommendations

#### Primary Strategy: Restructured Restricted Completeness

**Confidence**: MEDIUM (55-65%)

1. **Verify `build_restricted_tc_family` dependency chain** -- determine if the restricted infrastructure is sound
2. **If sound**: Adapt the parametric truth lemma to use only restricted coherence (single-step G/H for closure formulas, F/P resolution for closure formulas)
3. **If unsound**: Build a new chain using `{target} ∪ g_content(M)` seed (sorry-free consistency from `forward_temporal_witness_seed_consistent`) with fair scheduling across the finite deferralClosure

#### Fallback Strategy: Constrained Lindenbaum Extension

**Confidence**: MEDIUM (40-55%)

Build Lindenbaum extensions that preserve G-theory between adjacent time points. Requires new consistency argument but is mathematically sound.

#### Key Sorry-Free Building Blocks

| Lemma | Location | What It Provides |
|-------|----------|-----------------|
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean:79 | `{psi} ∪ g_content(M)` consistent when `F(psi) ∈ M` |
| `temporal_theory_witness_exists` | UltrafilterChain.lean:2212 | Existence of witness MCS |
| `restricted_truth_lemma` | RestrictedTruthLemma.lean:291 | DRM <-> ext equivalence for closure formulas |
| `simplified_restricted_seed_consistent` | SimplifiedChain.lean:78 | Simplified seed (without f_content) is consistent |
| `restricted_chain_G_step` | RestrictedTruthLemma.lean:71-78 | Single-step G-persistence (sorry-free) |

#### Approaches Definitively Eliminated

| Approach | Reason | Evidence |
|----------|--------|----------|
| Fill in existing sorries directly | The full MCS chain has no F-resolution mechanism | Teammate A analysis |
| Include f_content in seed | Provably inconsistent | `constrained_successor_seed_restricted_consistent` = FALSE |
| Dovetailed fair scheduling | F-persistence fails through Lindenbaum | DovetailedChain.lean:587 |
| Ultrafilter compactness | Too much categorical overhead (25-40h) | Teammate B analysis |
| Konig on DRM space | Already done by existing infrastructure | Teammate B analysis |
| Bundle-level coherence | Truth lemma is bidirectional | Task 81 research |

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary mathematical analysis (sorry states, chain structure, G-lift gap) | completed | high |
| B | Alternative approaches, prior art, Mathlib infrastructure | completed | medium |

### Teammate A Highlights
- Exact goal states via `lean_goal` at all 4 sorry locations
- Identified `constrained_successor_seed_restricted_consistent` as FALSE (critical finding)
- Traced complete dependency chain showing restricted infrastructure may be unsound
- Identified the "one remaining path": pure g_content seed + fair scheduling

### Teammate B Highlights
- 5 alternative approaches analyzed (3 eliminated, 2 viable)
- Prior art survey confirming structural mismatch with standard completeness
- Mathlib lemma inventory (ultrafilter_compact, Konig, pigeonhole)
- Identified that truth lemma may only need single-step G-propagation (from Report 20)

## References

### Codebase Files
- `Theories/Bimodal/Metalogic/Completeness/UltrafilterChain.lean` -- main sorry locations
- `Theories/Bimodal/Metalogic/Completeness/RestrictedTruthLemma.lean` -- dead code sorries
- `Theories/Bimodal/Metalogic/Completeness/SuccChainFMCS.lean` -- chain construction, FALSE theorem
- `Theories/Bimodal/Metalogic/Completeness/DovetailedChain.lean` -- documented failure analysis
- `Theories/Bimodal/Metalogic/Completeness/SimplifiedChain.lean` -- targeted seed approach
- `Theories/Bimodal/Metalogic/Completeness/WitnessSeed.lean` -- sorry-free consistency lemma
- `Theories/Bimodal/Metalogic/Completeness/SubformulaClosure.lean` -- deferralClosure definition

### Prior Task Research
- Task 81 reports (specs/081_fp_witness_representation_theorem/reports/) -- F/P witness problem analysis
- Task 64 reports -- critical path review and algebraic analysis

### Literature
- Goldblatt 1992 -- standard canonical model completeness
- Blackburn/de Rijke/Venema 2001 -- modal logic handbook
- Gabbay/Hodkinson/Reynolds 1994 -- temporal logic fair scheduling
- Gabbay/Kurucz/Wolter/Zakharyaschev 2003 -- many-dimensional modal logics
