# Research Report: Task #72

**Task**: Wire completeness through fully coherent BFMCS construction
**Date**: 2026-03-31
**Mode**: Team Research (2 teammates)

## Summary

Two research teammates investigated the problem of wiring a sorry-free BFMCS construction into the completeness theorem. The core blocker is a **type mismatch**: the completeness pathway (`parametric_algebraic_representation_conditional`) requires `BFMCS D` with `BFMCS.temporally_coherent` (same-family F/P witnesses), while the only sorry-free construction (`construct_bfmcs_bundle`) produces `BFMCS_Bundle` (cross-family F/P witnesses). Three viable paths forward were identified, with the **restricted family path** being the most conservative and the **dovetailed chain** being the highest payoff.

## Key Findings

### The Core Blocker: Bundle-Level vs Family-Level Coherence

Both teammates independently confirmed the same structural blocker:

- **Required**: `BFMCS.temporally_coherent` (TemporalCoherence.lean:218) — for each family, F(phi) at time t has a witness phi at s >= t **in the same family**
- **Available**: `BFMCS_Bundle.bundle_forward_F` (UltrafilterChain.lean:5633) — F(phi) at time t has a witness phi at s > t **in any family** of the bundle
- **Gap**: Family-level is strictly stronger than bundle-level. Cannot coerce.
- **Documented**: UltrafilterChain.lean:5754-5781 explicitly identifies this gap.

### What Is Sorry-Free

| Component | File | Lines | Status |
|-----------|------|-------|--------|
| `construct_bfmcs_bundle` | UltrafilterChain.lean | 5728-5739 | **Sorry-free** |
| `boxClassFamilies_bundle_forward_F` | UltrafilterChain.lean | 5518-5556 | **Sorry-free** |
| `boxClassFamilies_bundle_backward_P` | UltrafilterChain.lean | 5563-5600 | **Sorry-free** |
| `Z_chain_forward_G` / `backward_H` | UltrafilterChain.lean | ~5200-5300 | **Sorry-free** |
| `OmegaFMCS` (forward_G/backward_H only) | UltrafilterChain.lean | 5294-5306 | **Sorry-free** |
| `restricted_forward_chain_forward_F` | SuccChainFMCS.lean | 2930-2934 | **Sorry-free** |
| `resolving_witness` | UltrafilterChain.lean | 5971 | **Sorry-free** |

### What Has Sorries

| Component | File | Lines | Blocker |
|-----------|------|-------|---------|
| `Z_chain_forward_F` | UltrafilterChain.lean | 5330-5352 | Hard case: F(phi) unresolved |
| `Z_chain_backward_P` | UltrafilterChain.lean | 5360-5369 | Hard case: P(phi) unresolved |
| `restricted_backward_chain_backward_P` | SuccChainFMCS.lean | 5386, 5740 | Fuel=0 "unreachable" branches |
| `RestrictedTruthLemma` G-propagation | RestrictedTruthLemma.lean | 116 | Pending |
| `RestrictedTruthLemma` H-step | RestrictedTruthLemma.lean | 158 | Pending |
| FMP: `mcs_all_future_closure` | TruthPreservation.lean | 256-281 | Semantic mismatch |
| `construct_bfmcs` (deprecated) | UltrafilterChain.lean | 4760-4767 | Entire body is sorry |

### Dead Ends Confirmed

1. **FMP path**: `semantic_weak_completeness` does NOT exist as a theorem. The FMP infrastructure has its own sorries (`mcs_all_future_closure`, `mcs_all_past_closure`) due to strict temporal semantics. Not a bypass.
2. **Chain-level F-persistence**: Mathematically false (counterexample from task 69). Cannot be fixed.
3. **Bidirectional seed**: BLOCKED — H_theory elements not G-liftable (task 70 finding).

### Primary Approach (from Teammate A)

**Strategy A: Complete Z_chain_forward_F via Dovetailed Construction**

The dovetailed chain infrastructure is partially built:
- `omega_chain_resolving_at_1` (line 6055) resolves one obligation — sorry-free
- `resolving_witness` (line 5971) — sorry-free
- `omega_chain_dovetailed_forward` (line 6268) — defined but incomplete (uses F_top unconditionally instead of scheduling)

The approach:
1. At step n = Nat.unpair(t, k), resolve the k-th F-obligation in chain(t)
2. Use `resolving_witness` to build chain(n+1)
3. Surjectivity of `Nat.unpair` ensures all obligations eventually resolved
4. Package as singleton `BFMCS Int` with proven `temporally_coherent`

**Challenge**: Circular dependency — chain(n+1) depends on chain(t) for t <= n. May require mutual recursion or WellFounded argument.

**Payoff**: Produces a true `BFMCS Int` satisfying `parametric_algebraic_representation_conditional` directly. Closes Z_chain_forward_F and Z_chain_backward_P.

### Alternative Approaches (from Teammate B)

**Option A: Restricted Family Path (Most Conservative)**

The restricted chain has forward_F sorry-free. Remaining work:
1. Prove "unreachable" sorry branches in `restricted_backward_bounded_witness_fueled` (fuel=0 case with fuel = B*B+1)
2. Prove G-propagation sorry in RestrictedTruthLemma.lean:116
3. Prove H-step sorry in RestrictedTruthLemma.lean:158
4. Wire `RestrictedTruthLemma.restricted_truth_lemma` into completeness

**Advantage**: Conservative, builds on mostly-proven infrastructure.
**Risk**: The "unreachable" claim may be hard to formalize; RestrictedTruthLemma sorries are of unknown difficulty.

**Option B: Bundle Truth Lemma (Cleanest Long-Term)**

Write a new truth lemma for `BFMCS_Bundle` with bundle-level semantics:
- Redefine truth of G(psi) using bundle semantics (witness in any family)
- Requires new `TaskModel` and `truth_at` definitions
- The backward G case works if the semantic hypothesis uses bundle semantics

**Advantage**: Uses the only sorry-free construction directly.
**Risk**: Deepest structural change — new truth lemma, new task model, new representation theorem variant.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate B | Resolution |
|----------|-----------|-----------|------------|
| Recommended primary path | Dovetailed chain (Strategy A) | Restricted family (Option A) | Both are viable; dovetailed has higher payoff but higher risk. Restricted is more conservative. |
| FMP viability | Not analyzed in depth | Confirmed dead | FMP path ruled out by Teammate B analysis |

The teammates agree on the problem diagnosis and differ only on which solution path to recommend. This is a judgment call about risk tolerance.

### Gaps Identified

1. **Dovetailed chain circularity**: No analysis of whether `WellFounded` or `Nat.rec` can handle the chain(t) reference for t <= n
2. **RestrictedTruthLemma sorry difficulty**: Lines 116 and 158 are unexplored — unknown if they're trivial or deep blockers
3. **Restricted backward P fuel argument**: Whether the fuel=0 branches can be proven unreachable via a termination metric
4. **Task 73/77 findings**: May contain relevant analysis not yet incorporated

### Recommendations

**Recommended strategy ordering** (risk-adjusted):

1. **First**: Investigate the restricted family path (Option A) — count and assess the remaining sorries. If they're closeable, this is the fastest path.
2. **Second**: If restricted path is blocked, complete the dovetailed chain (Strategy A) — higher complexity but solves the problem from first principles.
3. **Last resort**: Bundle truth lemma (Option B) — only if both above paths fail, as it requires the deepest refactoring.

**Implementation plan should start with**: A detailed sorry audit of the restricted family path (RestrictedTruthLemma.lean + restricted_backward_bounded_witness_fueled) to determine feasibility before committing to a path.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary wiring approaches | completed | high (diagnosis), medium (strategy A) |
| B | Alternative paths & prior art | completed | high (FMP dead, bundle gap), medium (restricted path) |

## References

### Sorry-Free Bundle Construction
- UltrafilterChain.lean:5518-5556 — `boxClassFamilies_bundle_forward_F`
- UltrafilterChain.lean:5563-5600 — `boxClassFamilies_bundle_backward_P`
- UltrafilterChain.lean:5728-5739 — `construct_bfmcs_bundle`

### Key Type Signatures
- ParametricRepresentation.lean:252 — `parametric_algebraic_representation_conditional` callback signature
- TemporalCoherence.lean:218 — `BFMCS.temporally_coherent` definition

### Dovetailed Infrastructure
- UltrafilterChain.lean:5971 — `resolving_witness` (sorry-free)
- UltrafilterChain.lean:6055 — `omega_chain_resolving_at_1` (sorry-free)
- UltrafilterChain.lean:6268 — `omega_chain_dovetailed_forward` (incomplete)

### Restricted Family Infrastructure
- SuccChainFMCS.lean:2930-2934 — `restricted_forward_chain_forward_F` (sorry-free)
- SuccChainFMCS.lean:5386,5740 — backward P sorry branches
- RestrictedTruthLemma.lean:116,158 — G-propagation and H-step sorries

### Dead Ends
- Task 69 report 17: Counterexample proving chain-level F-persistence is false
- Task 70 summary 07: Bidirectional seed blocked (H_theory not G-liftable)
- TruthPreservation.lean:256-281: FMP path has own sorries

---

## Errata (2026-03-31)

**CORRECTION**: The bundle-level temporal coherence approach analyzed in this report
is semantically WRONG for TM task semantics. TM temporal operators (G, H, F, P) quantify
over times in the SAME world history, not over different histories as bundle-level
coherence allows. See `reports/06_semantic-correction.md` for full analysis.

The correct approach uses SuccChainFMCS with family-level temporal coherence.

Key semantic distinction:
- **Bundle-level**: F(phi) at (fam, t) -> witness at (fam', s) where fam' != fam allowed
- **TM requires**: F(phi) at (fam, t) -> witness at (fam, s) in the SAME family

See also: `ROADMAP.md:158-160` (identifies bundle as "dead end")
