# Team Research Report: Task 67 - Restricted Truth Lemma Infrastructure

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-28
**Mode**: Team Research (2 teammates)
**Session**: sess_1774742732_81e3b3
**Focus**: Restricted truth lemma infrastructure - exact Lean signatures, proof patterns, dependencies

## Summary

Two complementary investigations converge on a clear picture of the sorry gap and two viable paths forward. The restricted coherence infrastructure is **structurally complete** in SuccChainFMCS.lean — proof bodies are sorry-free, with gaps only in Lean termination proofs and seed consistency. The completeness wiring requires bridging family-level vs bundle-level temporal coherence.

## Key Findings

### 1. The Exact Sorry Gap (Teammate B)

The sorry at `Completeness.lean:204` needs to construct a `TaskFrame Int` / `TaskModel` / `WorldHistory` from a `BFMCS_Bundle` where `phi` is semantically false, then specialize `h_valid : valid_over Int phi` to get a contradiction.

The bridge is `parametric_canonical_truth_lemma` (ParametricTruthLemma.lean:207-351):
```lean
theorem parametric_canonical_truth_lemma
    (B : BFMCS D) (h_tc : B.temporally_coherent)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi ∈ fam.mcs t ↔ truth_at (ParametricCanonicalTaskModel D) (ParametricCanonicalOmega B)
      (parametric_to_history fam) t phi
```

**Blocker**: This requires `h_tc : B.temporally_coherent` (family-level forward_F/backward_P), but `construct_bfmcs_bundle` only provides `BundleTemporallyCoherent` (bundle-level).

### 2. Restricted Infrastructure Status (Teammate A)

The DRM-based restricted coherence infrastructure is nearly complete:

| Component | Status | Location |
|-----------|--------|----------|
| `deferral_restricted_mcs_F_bounded` | SORRY-FREE | RestrictedMCS.lean:1090 |
| `deferral_restricted_mcs_P_bounded` | SORRY-FREE | RestrictedMCS.lean:1168 |
| `restricted_forward_chain_forward_F` (body) | SORRY-FREE | SuccChainFMCS.lean:2921 |
| `restricted_backward_chain_backward_P` (body) | SORRY-FREE | SuccChainFMCS.lean:4262 |
| `build_restricted_tc_family` (body) | SORRY-FREE | SuccChainFMCS.lean:4643 |
| `restricted_truth_lemma` (F/P cases) | SORRY-FREE | RestrictedTruthLemma.lean:268 |
| `RestrictedTemporallyCoherentFamily` | Clean structure | SuccChainFMCS.lean:4624 |

**Sorry categories** (4 types):
1. **Termination proofs** (4 `decreasing_by sorry`): `restricted_bounded_witness`, `restricted_backward_bounded_witness`, `restricted_combined_bounded_witness`, `restricted_combined_bounded_witness_P` — bodies complete, need lexicographic measure on (d, k)
2. **Seed consistency** (3 sorries): `constrained_successor_seed_restricted_consistent` multi-BRS case — needs cut-elimination argument
3. **G/H propagation** (3 sorries): `restricted_chain_G_propagates`, `restricted_chain_H_step` — needed for G/H truth lemma cases
4. **Backward chain construction** (~3 sorries): predecessor existence

### 3. Why Same-Family Matters (Both)

The backward G case proof requires:
```
G(psi) ∉ fam.mcs(t) → F(¬psi) ∈ fam.mcs(t)           [temporal duality]
                     → ¬psi ∈ fam.mcs(s) for s > t     [forward_F — MUST BE SAME FAMILY]
                     → truth(psi) at s along tau        [semantic hypothesis]
                     → psi ∈ fam.mcs(s)                 [backward IH]
                     → contradiction                     [psi and ¬psi in consistent set]
```
Step 3 must be same-family because `tau = parametric_to_history(fam)` evaluates truth using `fam.mcs(s)`.

## Two Solution Paths

### Path A: Restricted Truth Lemma (DRM-based) — ~300-400 lines new code

Use `deferralClosure(phi)` restriction: the truth lemma only invokes forward_F/backward_P on formulas whose F-nesting is bounded by `closure_F_bound(phi)`.

**Steps**:
1. Define `RestrictedTemporalCoherence` predicate for BFMCS over deferralClosure(phi)
2. Prove SuccChainFMCS families satisfy it (via existing `build_restricted_tc_family`)
3. Prove restricted truth lemma: like `parametric_canonical_truth_lemma` but takes RTC instead of full TC
4. Wire to completeness

**Advantage**: Most infrastructure already exists
**Risk**: Requires filling termination sorries (Priority 1) and seed consistency (Priority 2)

### Path B: Prove SuccChainFMCS Has Family-Level Coherence — ~100-200 lines new code

Observe: `construct_bfmcs_bundle` builds families as `shifted_fmcs(SuccChainFMCS(W), k)`. In a SuccChainFMCS, f_content propagation ensures `F(phi) ∈ mcs(t) → phi ∈ mcs(t+1) ∨ F(phi) ∈ mcs(t+1)`. If this always terminates, SuccChainFMCS has family-level forward_F.

**Steps**:
1. Prove `succ_chain_fam_forward_F : F(phi) ∈ succ_chain_fam M0 n → ∃ m > n, phi ∈ succ_chain_fam M0 m`
2. Prove `succ_chain_fam_backward_P` (symmetric)
3. Prove `construct_bfmcs_bundle` satisfies `B.temporally_coherent`
4. Apply existing `parametric_canonical_truth_lemma` directly

**Advantage**: Simpler, reuses existing truth lemma, fewer new definitions
**Risk**: The forward_F termination argument for arbitrary formulas in full MCS chains may require the SAME DRM bounds (F-nesting is unbounded in full MCS). If so, this path reduces to Path A.

## Synthesis

### Conflict Resolution

Teammate A emphasizes that **full MCS chains cannot guarantee forward_F for arbitrary formulas** (F-nesting unbounded). Teammate B suggests SuccChainFMCS might have family-level coherence because the serial construction forces F-content resolution.

**Resolution**: Both are partially correct. The serial construction does propagate F-content forward, but **termination is not guaranteed for arbitrary formulas** without the DRM bound. For a formula `F^n(p)` with large `n`, the chain propagates `F^n(p) → F^{n-1}(p) → ... → p`, which terminates after `n` steps. But for unbounded `n` (not in any finite closure), the "there exists a witness" claim requires showing every F-chain terminates — which IS true in a serial chain (each step strictly decreases the F-depth by 1), but proving this in Lean requires the same kind of bounded induction that the restricted approach uses.

**Bottom line**: Path B likely reduces to Path A in practice. The DRM restriction is what makes termination provable.

### Recommended Approach

**Path A (Restricted Truth Lemma)** with this priority ordering:

1. **Fill termination sorries** (4 `decreasing_by sorry`): Use lexicographic measure `(closure_F_bound phi - current_depth, chain_position)` or `Nat.find` with well-founded recursion. These are the cleanest wins — bodies are complete.

2. **Fill G/H propagation sorries** (3 in RestrictedTruthLemma.lean): `restricted_chain_G_propagates` and `restricted_chain_H_step` are needed for the full restricted truth lemma to cover G/H cases.

3. **Define restricted BFMCS coherence**: A `BFMCS` version that takes `RestrictedTemporalCoherence` instead of full `temporally_coherent`, and adapt `parametric_canonical_truth_lemma` to use it.

4. **Wire to completeness**: Apply restricted truth lemma in `bundle_validity_implies_provability`.

5. **Seed consistency** (if blocking): The multi-BRS case in `constrained_successor_seed_restricted_consistent`.

### Gaps Identified

1. No existing theorem connects `RestrictedTemporallyCoherentFamily` to `BFMCS.temporally_coherent` or a restricted variant thereof
2. `parametric_canonical_truth_lemma` needs adaptation to accept restricted coherence
3. The G/H propagation sorries are on the critical path (needed for backward G case)
4. Backward chain construction sorries may block backward_P

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Restricted coherence signatures & proof patterns | completed | high |
| B | Completeness wiring & gap analysis | completed | high |

## Critical Path Summary

```
termination sorries (4) → G/H propagation (3) → restricted BFMCS coherence → restricted truth lemma adaptation → completeness wiring
```

Estimated new code: ~300-400 lines (aligned with prior analysis).
