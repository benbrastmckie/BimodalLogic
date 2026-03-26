# Backward Chain Infrastructure Analysis

**Teammate**: C (Math Research Agent)
**Task**: 58 - Wire completeness to frame conditions
**Focus**: Backward chain infrastructure requirements
**Date**: 2026-03-26

## Executive Summary

The backward chain construction is mathematically symmetric to the forward chain, but requires implementing several missing components. The key insight is that the forward chain's infrastructure is complete and sorry-free, providing a template for the backward direction. However, there is an **alternative approach** that could avoid the backward chain entirely by exploiting the temporal symmetry axioms.

## Key Findings

### 1. Structure of `constrained_successor_restricted`

The forward chain's constrained successor is built from four components (SuccExistence.lean:337):

```lean
def constrained_successor_seed_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u ∪ boundary_resolution_set phi u
```

**Component Analysis**:

| Component | Definition | Purpose |
|-----------|------------|---------|
| `g_content u` | `{phi \| all_future phi in u}` | G-persistence: formulas that must persist to future |
| `deferralDisjunctions u` | `{psi or F(psi) \| F(psi) in u}` | F-step deferral: resolve or defer F-obligations |
| `p_step_blocking_formulas_restricted phi u` | `{H(neg chi) \| P(chi) in dc, P(chi) not_in u, chi not_in u}` | Block spurious P-formulas in successor |
| `boundary_resolution_set phi u` | `{chi \| F(chi) in u, FF(chi) not_in dc}` | Force resolution at boundary |

### 2. Symmetric Construction for `constrained_predecessor_restricted`

The backward chain requires the symmetric seed:

```lean
def constrained_predecessor_seed_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  h_content u ∪ pastDeferralDisjunctions u ∪ f_step_blocking_formulas_restricted phi u ∪ past_boundary_resolution_set phi u
```

**Symmetric Component Mapping**:

| Forward Component | Backward Component | Definition |
|-------------------|-------------------|------------|
| `g_content` | `h_content` | `{phi \| all_past phi in u}` (already exists at TemporalContent.lean:56) |
| `deferralDisjunctions` | `pastDeferralDisjunctions` | `{psi or P(psi) \| P(psi) in u}` (already exists at SuccExistence.lean:628) |
| `p_step_blocking_formulas_restricted` | `f_step_blocking_formulas_restricted` | **MISSING**: `{G(neg chi) \| F(chi) in dc, F(chi) not_in u, chi not_in u}` |
| `boundary_resolution_set` | `past_boundary_resolution_set` | **MISSING**: `{chi \| P(chi) in u, PP(chi) not_in dc}` |

### 3. The h_content / g_content Asymmetry

**Question**: Is the backward direction structurally harder?

**Answer**: No, the mathematics is perfectly symmetric. The asymmetry is only in implementation state:

- **G formulas** require F-witnesses (forward direction): `restricted_forward_chain_forward_F` is proven
- **H formulas** require P-witnesses (backward direction): symmetric theorem needed

The temporal axioms are fully symmetric:
- `temp_t_future`: `G(phi) -> phi` (reflexivity)
- `temp_t_past`: `H(phi) -> phi` (reflexivity)
- `temp_4`: `G(phi) -> G(G(phi))` (transitivity forward)
- There should be a symmetric `H(phi) -> H(H(phi))` (transitivity backward)
- `temp_a`: `phi -> G(P(phi))` (temporal connectedness)

The T-axioms (SuccExistence.lean:767-769) show the seed-subset-u argument works identically:
```lean
-- g_content(u) ⊆ u via T-axiom (Gφ → φ)
have h_T : [] ⊢ (Formula.all_future χ).imp χ :=
  DerivationTree.axiom [] _ (Axiom.temp_t_future χ)
```

For backward chain:
```lean
-- h_content(u) ⊆ u via T-axiom (Hφ → φ)
have h_T : [] ⊢ (Formula.all_past χ).imp χ :=
  DerivationTree.axiom [] _ (Axiom.temp_t_past χ)
```

### 4. `f_step_blocking_formulas_restricted` Analysis

The unrestricted version already exists (SuccExistence.lean:642):

```lean
def f_step_blocking_formulas (u : Set Formula) : Set Formula :=
  {ψ | ∃ φ : Formula, Formula.some_future φ ∉ u ∧ φ ∉ u ∧
    ψ = Formula.all_future (Formula.neg φ)}
```

The restricted version needs:

```lean
def f_step_blocking_formulas_restricted (phi : Formula) (u : Set Formula) : Set Formula :=
  {ψ | ∃ χ : Formula, Formula.some_future χ ∈ deferralClosure phi ∧
                       Formula.some_future χ ∉ u ∧
                       χ ∉ u ∧
                       ψ = Formula.all_future (Formula.neg χ)}
```

**Key Property**: Every blocking formula `G(neg chi)` is already in u because:
- `F(chi) not_in u` implies `neg(F(chi)) in u` (MCS negation completeness)
- `neg(F(chi)) = neg(neg(G(neg(chi)))) = G(neg(chi))` (by definition of F)
- So `G(neg(chi)) in u` by double negation elimination

This mirrors exactly the `p_step_blocking_formulas_subset_u` theorem at SuccChainFMCS.lean:1082.

### 5. Alternative: Avoiding Backward Chain via Temporal Swap

**Key Observation**: Formula.lean defines `swap_temporal`:

```lean
def swap_temporal : Formula → Formula
  | atom n => atom n
  | bot => bot
  | imp φ ψ => imp φ.swap_temporal ψ.swap_temporal
  | box φ => box φ.swap_temporal
  | all_past φ => all_future φ.swap_temporal
  | all_future φ => all_past φ.swap_temporal
```

With the property `swap_temporal_involutive`: `swap(swap(phi)) = phi`.

**Alternative Strategy**: Instead of implementing backward chain infrastructure, we could:

1. Define a "time-reversed" model from the forward chain
2. Use `swap_temporal` to convert P-requirements to F-requirements
3. Apply the existing forward chain infrastructure
4. Convert back via `swap_temporal_involutive`

This would require proving:
- `truth_at M t (swap_temporal phi) <-> truth_at (reverse_time M) t phi`
- `MCS_property u <-> MCS_property (swap_formulas u)`

**Risk Assessment**: This approach is mathematically elegant but may require significant new infrastructure for "time reversal" of models. The direct symmetric implementation is more predictable.

## Recommended Approach

**Primary Recommendation**: Implement the symmetric backward chain directly.

**Rationale**:
1. All required components have direct symmetric counterparts
2. The forward chain provides a proven template
3. The mathematics is well-understood (temporal symmetry is exact)
4. Implementation effort is bounded and predictable

**Implementation Order**:

1. **Define missing components** (~100 LOC):
   - `f_step_blocking_formulas_restricted` (symmetric to `p_step_blocking_formulas_restricted`)
   - `past_boundary_resolution_set` (symmetric to `boundary_resolution_set`)

2. **Define `constrained_predecessor_seed_restricted`** (~20 LOC):
   - Combine: `h_content ∪ pastDeferralDisjunctions ∪ f_step_blocking_formulas_restricted ∪ past_boundary_resolution_set`

3. **Prove seed consistency** (~200 LOC):
   - Mirror `constrained_successor_seed_restricted_consistent`
   - Use symmetric T-axiom `H(phi) -> phi`

4. **Define `constrained_predecessor_restricted`** (~50 LOC):
   - Via `deferral_restricted_lindenbaum` on the restricted seed

5. **Build `restricted_backward_chain`** (~200 LOC):
   - Mirror `restricted_forward_chain` structure
   - Prove `restricted_backward_chain_backward_P` (symmetric to `restricted_forward_chain_forward_F`)

6. **Combine into `DeferralRestrictedFMCS`** (~100 LOC):
   - Dovetail forward and backward chains
   - Prove both F-coherence and P-coherence

**Total Estimated Effort**: ~700 LOC, mostly mechanical symmetry with forward chain.

## Confidence Level

**High Confidence** for the symmetric construction approach:
- The mathematics is well-understood (temporal logic symmetry)
- All forward chain components have proven, working implementations
- The restricted seed consistency proof pattern is established
- No fundamental mathematical obstacles identified

**Medium Confidence** for the temporal swap alternative:
- Theoretically sound but requires new model-theoretic infrastructure
- May uncover unexpected complications with model reversal
- Higher risk, potentially higher reward (would eliminate need for backward chain entirely)

## References

Key files examined:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Seed definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Forward chain implementation
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - g_content/h_content definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean` - swap_temporal definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` - Temporal axioms (T-axioms)
