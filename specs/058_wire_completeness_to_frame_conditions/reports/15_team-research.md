# Research Report: Task #58 — GH-Intersection Detail, Vault Review, Category Theory

**Task**: Wire completeness to frame conditions
**Date**: 2026-03-25
**Mode**: Team Research (3 teammates, wave 2)
**Session**: sess_1774482618_5cbfdd
**Prior Report**: 11_team-research.md (G-theory propagation gap analysis)

## Summary

This report deepens the analysis of the G-theory propagation gap with three complementary angles: full mathematical detail of the GH-intersection approach, exhaustive review of 15+ past failed approaches in the archive, and abstract category-theoretic analysis.

**Convergent conclusion**: The GH-intersection approach is mathematically sound and partially resolves the gap, but a **sub-case (b) blocker** remains for F-obligations in the backward chain. The archive review reveals that the `G_theory_witness` approach (analogous to the successful `box_theory_witness`) is the most promising path to resolve this remaining gap.

## Key Findings

### 1. GH-Intersection: Full Mathematical Detail (Teammate A)

**What IS provable (all HIGH confidence)**:

| Component | Status | Proof Strategy |
|-----------|--------|----------------|
| `dual_temp_l`: G(a) ∧ H(a) → H(G(a)) | PROVABLE | Apply temporal duality to temp_l, extract via temp_t_future |
| GH_theory(M0) is H-liftable at backward(n) | PROVABLE | dual_temp_l gives H(G(a)) ∈ M0; H-theory propagation carries it through chain |
| Modified seed `{psi} ∪ H_theory(M) ∪ GH_theory(M0) ∪ box_theory(M)` consistent | PROVABLE | Standard H-lift argument extends because all GH_theory elements are H-liftable |
| forward_F sub-case (a): G(¬phi) ∉ M0 | RESOLVED | F(phi) ∈ M0 by MCS negation; forward chain resolves via dovetailing |

**What is BLOCKED**:

| Component | Status | Root Cause |
|-----------|--------|------------|
| forward_F sub-case (b): G(¬phi) ∈ M0, H(¬phi) ∉ M0 | BLOCKED | phi cannot be at time ≥ 0 (G(¬phi) prevents it) or at M0 (¬phi ∈ M0). Witness must be at backward(m) for m < n, but backward chain doesn't resolve F-obligations. |
| forward_G from forward_F | NOT DERIVABLE | Forward direction of truth lemma for G needs G-propagation through chain; cannot be derived from existential forward_F alone |

**Sub-case (b) semantic interpretation**: F(phi) at time -n means "phi will eventually be true", but G(¬phi) at time 0 means "¬phi forever from now on". So phi must hold at some time between -n and 0. The backward chain doesn't construct such witnesses.

### 2. Archive Vault Review: 15+ Failed Approaches (Teammate B)

**Exhaustive review of tasks 036, 048, 049, 053, 055, 056, 062, 063:**

| Approach Category | Plans Tried | Result |
|-------------------|-------------|--------|
| Restricted MCS chain (v1-v3) | 3 | FAILED: deferral disjunctions escape closureWithNeg |
| Restricted blocking (v4) | 1 | FAILED: same boundary escape |
| Fuel-based recursion (v5-v6) | 2 | FAILED: fuel bound weakens in persistence |
| Boundary resolution (v7-v12) | 6 | FAILED: consistency proofs circular or mathematically false |
| Algebraic STSA (v14) | 1 | PARTIAL: led to breakthrough v15 |
| Ultrafilter chain (v15) | 1 | **BREAKTHROUGH**: eliminated all modal sorries |

**Critical discoveries from archive**:

1. **`f_nesting_is_bounded` is mathematically FALSE**: Counterexample `{Fⁿ(p) | n ∈ ℕ}` is consistent. This killed ALL restricted chain approaches.

2. **Modal completeness is SOLVED**: The algebraic/ultrafilter approach via `box_theory_witness_consistent` eliminated all modal sorries. The infrastructure is sorry-free.

3. **The G_theory_witness approach** (task 055, plan v2): Proposed but never fully implemented. Key idea:
   - Define `G_theory_positive(M) = {ψ | G(ψ) ∈ M}`
   - Prove `{φ} ∪ G_theory_positive(M)` consistent when `F(φ) ∈ M`
   - Extend to MCS witness via Lindenbaum
   - This is the direct temporal analog of the successful `box_theory_witness`

4. **Cross-family temporal coherence**: The temporal witness doesn't need to be in the SAME Z-chain instance. If the witness is in another family with the same box-class, the BFMCS structure might accommodate it.

### 3. Category-Theoretic Analysis (Teammate C)

**Structural insights**:

1. **Functorial obstruction**: Forward chain F: ℕ → MCS and backward chain B: ℕᵒᵖ → MCS are well-defined partial functors, but cannot be glued into a functor ℤ → MCS because G_theory and H_theory propagate in opposite directions only.

2. **GH-intersection as stable subalgebra**: The "eternal formulas" where BOTH G(a) and H(a) are in M0 form a fixpoint of the G-H interaction. This is the UNIQUE subalgebra that propagates bidirectionally, confirmed algebraically via temp_l and its sigma-dual.

3. **Sheaf-theoretic obstruction**: The presheaf of MCSes over ℤ fails the sheaf condition at the origin (t = 0). There is a cohomological obstruction to gluing the forward and backward sections.

4. **Stone duality limitation**: G and H are NOT Boolean algebra homomorphisms (they don't preserve complement). Unlike Box which has S5 negative introspection (Box(a)ᶜ ≤ Box(Box(a)ᶜ)), G lacks this property entirely. This explains why G_theory only includes positive formulas.

5. **Recommended construction**: Build BFMCS as a limit of a diagram rather than a linear chain, using the GH-intersection as the "core" that propagates universally.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| A says sub-case (b) is blocking; B suggests G_theory_witness approach might resolve it | These are COMPATIBLE: sub-case (b) is blocking for the current GH-intersection approach, but the G_theory_witness approach from the archive (never fully implemented) could resolve it by providing temporal witnesses directly |
| B mentions cross-family temporal coherence; C (wave 1) ruled out bundle-level coherence | These address DIFFERENT things. Bundle-level coherence (C wave 1) breaks the truth lemma because G quantifies over same history. Cross-family witnesses (B) work IF the witness is still within the same family's timeline, just constructed differently. |

### The Converged Strategy

Three-part implementation path:

**Part 1: GH-Intersection Core (provable, 4-6h)**
- Prove `dual_temp_l`
- Prove modified seed consistency
- Build modified backward chain with `OmegaBackwardInvariant_GH`
- This resolves forward_F sub-case (a) and provides eternal formula propagation
- Eliminates 2 of the 5 sorries (the "eternal" crossing cases)

**Part 2: G_theory_witness (the archive insight, 4-6h)**
- Prove `G_theory_positive_witness_consistent`: `{φ} ∪ G_theory_positive(M)` consistent when F(φ) ∈ M
  - This is the SAME pattern as `temporal_theory_witness_consistent` but may need additional care
  - The finite inconsistency argument: if inconsistent, get finite L ⊢ ⊥ from {φ} ∪ G_theory_positive; G-lift to G(¬φ) ∈ M; contradicts F(φ) ∈ M
- This provides temporal witnesses that preserve the FULL G_theory, not just the eternal part
- Use these witnesses to resolve F-obligations anywhere in the Z-chain

**Part 3: Wire to Completeness (2-3h)**
- Once both temporal directions have complete witness resolution
- Construct sorry-free `construct_bfmcs_omega`
- Eliminate the 3 target sorries in Completeness.lean

### Critical Realization

**The G_theory_witness approach IS essentially `temporal_theory_witness_exists`**, which we already have! The current `temporal_theory_witness_exists` already proves:
```
F(phi) ∈ M → ∃ W. phi ∈ W ∧ G_theory(M) ⊆ W ∧ box_class_agree(M, W)
```

The problem isn't the WITNESS THEOREM — it's the CHAIN CONSTRUCTION. The backward chain uses `past_theory_witness_exists` (H-preserving) instead of `temporal_theory_witness_exists` (G-preserving). To resolve F-obligations in the backward chain, we need to interleave calls to `temporal_theory_witness_exists` within the backward chain.

**The key question**: Can we resolve F-obligations in the backward chain WITHOUT causing G/H oscillation?

**Proposed answer**: Yes, if we use a COMBINED seed:
```
{psi_n (P-target)} ∪ {phi_n (F-target)} ∪ H_theory(M) ∪ G_theory(M0) ∪ box_theory(M)
```
This resolves BOTH P and F obligations at each step. The consistency proof needs to show this combined seed is consistent, which requires being able to BOTH H-lift (for P-target) and G-lift (for F-target).

**But**: We showed in wave 1 that H and G lifting are incompatible for the full seed. However, with GH_theory(M0) providing the eternal core, perhaps a weaker combined seed IS consistent.

### Effort Estimate

| Component | Hours | Risk |
|-----------|-------|------|
| Part 1: GH-intersection core | 4-6 | LOW (all steps proven feasible) |
| Part 2: Combined seed approach | 4-6 | MEDIUM (seed consistency is key unknown) |
| Part 3: Wire to completeness | 2-3 | LOW (if Parts 1-2 succeed) |
| **Total** | **10-15** | |

### Gaps Remaining

1. **Combined seed consistency**: Can `{P-target} ∪ {F-target} ∪ H_theory(M) ∪ GH_theory(M0) ∪ box_theory(M)` be proven consistent? This is the crux of Part 2.

2. **G/H oscillation avoidance**: If combined seed works, need to verify the invariant tracks both theories without oscillation.

3. **Sub-case (b) resolution**: If combined seed doesn't work, sub-case (b) remains open and may require a fundamentally different architecture.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A (gh-detail) | GH-intersection full math detail | completed | HIGH |
| B (vault-review) | Archive review of 15+ past attempts | completed | HIGH |
| C (category-theory) | Category-theoretic structural analysis | completed | HIGH |

## References

### Teammate Reports
- `specs/058_wire_completeness_to_frame_conditions/reports/15_teammate-a-findings.md` — Full GH-intersection proof detail
- `specs/058_wire_completeness_to_frame_conditions/reports/15_teammate-b-findings.md` — Archive vault comprehensive review
- `specs/058_wire_completeness_to_frame_conditions/reports/15_teammate-c-findings.md` — Category-theoretic analysis

### Key Archive Files
- `specs/archive/048_prove_succ_chain_fam_bounded_f_depth/reports/30_algebraic-stsa-path.md` — Algebraic breakthrough
- `specs/archive/048_prove_succ_chain_fam_bounded_f_depth/plans/15_ultrafilter-chain.md` — Ultrafilter chain plan (v15)
- `specs/archive/055_prove_succchain_temporal_coherence_directly/plans/02_algebraic-temporal-coherence.md` — Algebraic temporal coherence approach
- `specs/archive/055_prove_succchain_temporal_coherence_directly/reports/02_team-research.md` — Temporal coherence team research

### Key Source Files
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` — All witness theorems and chain construction
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` — STSA structure, sigma involution, temp_l
- `Theories/Bimodal/ProofSystem/Axioms.lean` — TM axiom definitions
