# Teammate B: Omega-Enumeration Construction Analysis

## Key Findings

### Omega-Enumeration Status

**The omega-enumeration construction is documentation only - no implementation exists.**

The deprecated `boxClassFamilies_temporally_coherent` (line 1815) and `construct_bfmcs`
(line 1856) in `UltrafilterChain.lean` reference `omegaClassFamilies_temporally_coherent` and
`construct_bfmcs_omega` respectively as their replacements. However, these replacement
identifiers do not exist anywhere in the codebase. They appear only in deprecation
notice strings - not as actual definitions.

A new construction _does_ exist in UltrafilterChain.lean (lines 1865-2981), but it is not
called `omegaClassFamilies`. Instead it is the `BFMCS_Bundle` approach using `Z_chain`,
`OmegaFMCS`, and `construct_bfmcs_bundle`. This is a fundamentally different approach
(bundle-level coherence) rather than the omega-enumeration family-level approach that was
originally advertised as the replacement.

**What was built (lines 1865-2981)**:
- `omega_chain_forward` / `omega_chain_backward`: Nat-indexed chains using
  `temporal_theory_witness_exists` for each step (sorry-free)
- `Z_chain`: Combined Int-indexed chain (sorry-free definition)
- `Z_chain_forward_G` / `Z_chain_backward_H`: FMCS coherence - **3 sorries present**
  (lines 2347, 2369, 2383)
- `Z_chain_forward_F` / `Z_chain_backward_P`: Temporal coherence - **2 sorries present**
  (lines 2485, 2494)
- `OmegaFMCS`: Wraps Z_chain as FMCS - depends on the sorried lemmas
- `BFMCS_Bundle`: Alternative structure with bundle-level (not family-level) coherence
- `construct_bfmcs_bundle`: **FULLY SORRY-FREE** - builds bundle from any MCS

### The Actual Gap

The `shifted_truth_lemma` (CanonicalConstruction.lean:648) requires `B.temporally_coherent`
which is **family-level** coherence:
```lean
(∀ t φ, some_future φ ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s)  -- SAME fam
```

The `construct_bfmcs_bundle` provides only **bundle-level** coherence:
```lean
(∀ fam ∈ families, ∀ φ t, some_future φ ∈ fam.mcs t →
  ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s)  -- ANY fam'
```

The `shifted_truth_lemma` backward G/H cases use `temporal_backward_G`/`temporal_backward_H`
(lines 745-772), which require a `TemporalCoherentFamily` with family-level coherence. The
bundle-level version cannot substitute here because the contradiction argument requires:
"neg(phi) in `fam.mcs s`" (same family), not "neg(phi) in some `fam'.mcs s`" (any family).

### Implementation Gap

**For omega-enumeration (family-level coherence) via `OmegaFMCS`**:

The 5 sorries in the Z_chain development represent the actual gaps:

1. `Z_chain_forward_G` crossing case (line 2347): When `t < 0 <= t'`, G-formulas do not
   propagate from the backward chain to the forward chain. The backward chain only preserves
   H-theory, not G-theory. This is a fundamental design gap - the two chains are independent.

2. `Z_chain_forward_G` pure backward case (line 2369): G-formulas do not propagate "forward"
   within the backward chain itself (since backward chain steps preserve H, not G).

3. `Z_chain_backward_H` symmetric (line 2383): Same issues for H-theory in forward direction.

4. `Z_chain_forward_F` (line 2485): Even with a witness W obtained from
   `temporal_theory_witness_exists`, there is no guarantee phi appears in the Z_chain at any
   future time. The chain only resolves F_top at each step, not arbitrary F-obligations.

5. `Z_chain_backward_P` (line 2494): Symmetric.

**Root cause of forward_F failure**: The current `omega_chain_forward` resolves F(neg bot)
(= F_top) at every step, but does not enumerate arbitrary F-obligations. The promised
"dovetailing" strategy (resolve F-obligation n at step 2n, P-obligation n at step 2n+1)
was never implemented. The data structures `F_obligations`, `P_obligations`, `F_inner`,
`P_inner` (lines 1921-1948) exist as definitions but are never used in the chain construction.

**Effort to fix Z_chain**: Very high (estimated 8-15 hours):
- Must redesign `omega_chain_forward` to use actual dovetailing
- Requires an enumeration of formulas (countability of formulas)
- Must prove the dovetailing satisfies F/P coherence
- The crossing case (t < 0 to t >= 0) may require proving G-theory propagates through
  the boundary, which requires the backward chain to also preserve G-theory (requires
  redesign of backward chain invariant)

### Alternative Paths

**Path A (VIABLE, currently done): Bundle-level completeness via `construct_bfmcs_bundle`**

The `bundle_validity_implies_provability` in `Completeness.lean:186` is the actual blocker.
The proof almost works - it calls `bundle_completeness_contradiction` (sorry-free) which
establishes that if neg(phi) is consistent, not all MCSes contain phi. The remaining sorry
(line 214) is the semantic glue: connecting the bundle model to `valid_over Int phi`.

The argument chain that needs to be formalized:
1. valid_over Int phi = forall TaskFrame, TaskModel, Omega (ShiftClosed), tau in Omega, t. truth_at t phi
2. Instantiate with CanonicalTaskModel from BFMCS_Bundle M
3. Instantiate Omega = ShiftClosedCanonicalOmega
4. By shifted_truth_lemma BACKWARD: truth_at 0 phi -> phi in eval_family.mcs 0 = M
5. Contradiction with neg(phi) in M

The PROBLEM: step 4 requires `B.temporally_coherent` (family-level), which `BFMCS_Bundle`
does not provide.

**Path B (VIABLE): Restricted construction path (recommended by spawn analysis)**

`RestrictedTemporallyCoherentFamily` (SuccChainFMCS.lean:4191) provides FAMILY-LEVEL
coherence for formulas in `subformulaClosure(phi)`. This is:
- forward_F: F(psi) at n -> exists m > n, psi at m (SAME chain, SAME family)
- backward_P: P(psi) at n -> exists m < n, psi at m (SAME chain, SAME family)

The `restricted_truth_lemma` (RestrictedTruthLemma.lean:268) proves the biconditional for
formulas in subformulaClosure. However, there are 3 sorries in RestrictedTruthLemma.lean
(lines 106, 115, 135) for G/H propagation steps within the DRM (Deferral Restricted MCS).

The path to completeness would be:
1. Fix 3 sorries in RestrictedTruthLemma.lean (G/H propagation within DRM chains)
2. Build TaskModel/TaskFrame from RestrictedTemporallyCoherentFamily
3. Show validity implies phi in MCS via truth lemma backward direction

**Path C (VIABLE): Syntactic completeness bypass**

The `succ_chain_completeness` theorem (SuccChainCompleteness.lean:131) is sorry-free via
the FORWARD direction of the truth lemma only. However it depends on `sorryAx` due to the
Box backward case in `succ_chain_truth_forward`. The comment in SuccChainCompleteness.lean
says "for sorry-free completeness, use `semantic_weak_completeness`" (FMP path).

### Recommendation

**The omega-enumeration construction as originally described does not exist.** The name
`omegaClassFamilies_temporally_coherent` appears only in deprecation strings, never as a
definition.

**The actual state of the codebase**:
1. `construct_bfmcs_bundle` is fully sorry-free and provides bundle-level coherence
2. The 3 sorries in `Completeness.lean` remain because connecting bundle-level coherence to
   `shifted_truth_lemma` (which requires family-level) has an unbridgeable gap
3. The restricted construction path is the most viable route

**Concrete next step**: Fix the 3 sorries in `RestrictedTruthLemma.lean` (lines 106, 115, 135).
These are G/H propagation within DRM chains. The G_step sorry (line 106) is annotated
"complex - for now defer to the main proof" - it requires showing G(psi) implies psi
propagates through multiple DRM steps. The math is sound (DRMs are closed under derivation
within deferralClosure), but the induction proof needs careful bookkeeping.

**Estimated effort for restricted path**: 4-6 hours:
- 1-2 hours: Fix RestrictedTruthLemma.lean sorries (G/H propagation within DRM)
- 1-2 hours: Build TaskModel from RestrictedTemporallyCoherentFamily
- 1-2 hours: Wire to FrameConditions/Completeness.lean sorries

## Evidence

| File | Lines | Significance |
|------|-------|--------------|
| `UltrafilterChain.lean` | 1811, 1815, 1821, 1856 | Deprecation notices referencing non-existent `omegaClassFamilies_temporally_coherent` and `construct_bfmcs_omega` |
| `UltrafilterChain.lean` | 1865-2495 | Omega-enumeration section: Z_chain construction with 5 sorries |
| `UltrafilterChain.lean` | 1921-1948 | `F_obligations`, `P_obligations` defined but never used in chain construction |
| `UltrafilterChain.lean` | 2027-2052 | `omega_chain_forward` resolves F_top only, NOT arbitrary F-obligations |
| `UltrafilterChain.lean` | 2340-2370 | Z_chain_forward_G: 2 sorries for G-theory crossing and backward-chain cases |
| `UltrafilterChain.lean` | 2424-2494 | Z_chain_forward_F, Z_chain_backward_P: 2 sorries - witness W not placed in Z_chain |
| `UltrafilterChain.lean` | 2853-2877 | `construct_bfmcs_bundle`: **FULLY SORRY-FREE** |
| `FrameConditions/Completeness.lean` | 186-214 | `bundle_validity_implies_provability`: sorry on semantic glue |
| `FrameConditions/Completeness.lean` | 115-120, 158-163 | `dense_completeness_fc`, `discrete_completeness_fc`: sorry |
| `Bundle/CanonicalConstruction.lean` | 648-652 | `shifted_truth_lemma`: requires `B.temporally_coherent` (family-level) |
| `Bundle/CanonicalConstruction.lean` | 745-754 | G backward case: uses `temporal_backward_G` requiring SAME family F-witnesses |
| `Bundle/SuccChainFMCS.lean` | 4191-4202 | `RestrictedTemporallyCoherentFamily`: provides FAMILY-LEVEL coherence (valid) |
| `Algebraic/RestrictedTruthLemma.lean` | 106, 115, 135 | 3 sorries for G/H propagation within DRM chains |

## Confidence Level

**high** - All findings are based on direct code inspection. The absence of
`omegaClassFamilies` and `construct_bfmcs_omega` was confirmed by codebase-wide search.
The sorry locations were directly inspected. The `shifted_truth_lemma` coherence requirement
was read directly from its signature and proof.
