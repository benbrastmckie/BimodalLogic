# Phase 3 Handoff: Lemma 2.7 with BX7 Chain

**Status**: Partial Completion - 1 of 5 sorry sites fully implemented

## Completed Work

### 1. `linear_until_mcs` (FULLY IMPLEMENTED)
- **Location**: Line ~2254 in PointInsertion.lean
- **Proof**: Complete implementation using BX7 (linear_until) axiom
- **Approach**: 
  - Uses `conj_mcs` to establish conjunction of the two Until formulas in A
  - Applies `Axiom.linear_until` via DerivationTree.axiom
  - Uses implication property of MCS to derive the three-way disjunction

## Remaining Work

### 2. `lemma_2_7_neg_untl_exists` (PARTIAL - sorry at line 2320)
- **Purpose**: Extract neg-until witness from maximality
- **Proof Structure**: Complete proof by contradiction framework
- **Remaining Issue**: The consistency proof for `{eta} ∪ B` needs completion
- **Key Components**:
  - Contradiction setup via `by_contra` and `push_neg`
  - Framework for showing DC({eta} ∪ B) satisfies burgessR3
  - Application of `BurgessR3Maximal_extension_fails` for final contradiction

### 3. `lemma_2_7_disjunct_elim_D1` (PARTIAL - sorry at line 2393)
- **Purpose**: Eliminate D1 disjunct using neg-until witness
- **Status**: Has proof sketch with sorry
- **Needed**: Monotonicity argument showing D1 implies the negated until formula

### 4. `lemma_2_7_disjunct_elim_D2` (PARTIAL - sorry at line 2404)
- **Purpose**: Eliminate D2 disjunct using neg-until witness
- **Status**: Has sorry placeholder
- **Needed**: Similar monotonicity chain as D1

### 5. `lemma_2_7_seed_consistent` (PARTIAL - sorry at line 2426)
- **Purpose**: Main theorem proving consistency of Lemma 2.7 seed
- **Status**: Sorry placeholder
- **Needed**: Full BX5+BX7+BX13+BX10 chain per Burgess 1982 p.372:
  1. Extract neg-until witness from h_eta_not_B
  2. BX5 on U(xi, eta) → U(xi∧U(xi,eta), eta)
  3. BX5 on U(b, γ_hat) → U(b∧U(b,γ_hat), γ_hat)
  4. BX7 linear_until → three-way disjunction
  5. Eliminate D1, D2 using neg-until witness
  6. D3 survives with enriched guard
  7. BX13 enrichment + BX10 → F(event) proves consistency

## Build Status

```
Build completed successfully (785 jobs).
```

Remaining warnings:
- 5 sorry declarations in Phase 3 lemmas
- 1 pre-existing sorry in burgess_D0_finite_subset_consistent (line 1814)

## Key Lemmas and Axioms Used

**BX Axioms**:
- `Axiom.linear_until` (BX7): Three-way disjunction
- `Axiom.self_accum_until` (BX5): Self-accumulation
- `Axiom.separation_until` (BX14): Separation
- `Axiom.enrichment_until` (BX13): Enrichment
- `Axiom.until_F` (BX10): Until implies F

**Helper Lemmas**:
- `conj_mcs`: Conjunction in MCS
- `SetMaximalConsistent.negation_complete`: Negation completeness
- `SetMaximalConsistent.implication_property`: Implication property
- `separation_until_mcs`: BX14 at MCS level
- `enrichment_until_mcs`: BX13 at MCS level
- `self_accum_until_mcs`: BX5 at MCS level
- `dc_delta_B_burgessR3`: Extension of B by delta preserves burgessR3
- `BurgessR3Maximal_extension_fails`: Maximality prevents consistent extensions

## Recommended Next Steps

1. **Complete `lemma_2_7_neg_untl_exists`**:
   - Implement the consistency proof for `{eta} ∪ B`
   - Use `neg_mem_of_inconsistent_union` and DCS properties

2. **Implement D1/D2 Elimination**:
   - Use `separation_until_mcs` with correct type matching
   - Apply monotonicity via `untl_left_mono_thm` or `right_mono_until_mcs`
   - Derive contradiction with neg-until witness

3. **Complete `lemma_2_7_seed_consistent`**:
   - Orchestrate the full BX5+BX7+BX13+BX10 chain
   - Use helper lemmas for each step
   - Apply D1/D2 elimination lemmas
   - Conclude with BX10 for eventuality

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - Added implementation for `linear_until_mcs`
  - Added proof frameworks for remaining 4 sorry sites
  - Fixed Formula.top references (using Formula.neg Formula.bot)

## References

- Burgess 1982: "Basic tense logic", Section 2, Lemma 2.7
- BX axiom system in `Theories/Bimodal/ProofSystem/Axioms.lean`
