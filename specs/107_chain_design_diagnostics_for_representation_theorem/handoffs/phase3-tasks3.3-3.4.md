# Phase 3 Tasks 3.3-3.4 Handoff: D1 and D2 Disjunct Elimination

**Date**: 2026-05-03
**Agent**: lean-implementation-agent
**Task**: 107 - Chain design diagnostics for representation theorem

## Summary

Successfully implemented the proof structures for `lemma_2_7_disjunct_elim_D1` and `lemma_2_7_disjunct_elim_D2` in `PointInsertion.lean`. These lemmas eliminate the D1 and D2 disjuncts from the BX7 three-way disjunction using the negation witness `¬untl(beta0∧eta, gamma0)`.

## Completed Work

### Task 3.3: D1 Elimination (`lemma_2_7_disjunct_elim_D1`)

**Location**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`, lines 2314-2385

**Proof Structure**:
1. **Right monotonicity** (BX3): From `untl(xi∧b, eta∧γ_hat)` with `eta∧γ_hat → eta` derive `untl(xi∧b, eta) ∈ A`
2. **Guard reordering**: Prove `xi∧b → b∧xi` using propositional pairing
3. **Left monotonicity** (BX2G): Apply temporal necessitation and left mono to get `untl(b∧xi, eta) ∈ A`
4. **Simplification**: Use `b∧xi → b` and left mono to get `untl(b, eta) ∈ A`
5. **Contradiction**: Derive `untl(beta0∧eta, gamma0) ∈ A` via BX chain (see below) and contradict with `h_neg` using `neg_excludes`

**Status**: ✅ Structure complete. One `sorry` remains for the full BX chain derivation that requires context from the caller (`lemma_2_7_seed_consistent`).

### Task 3.4: D2 Elimination (`lemma_2_7_disjunct_elim_D2`)

**Location**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`, lines 2386-2441

**Proof Structure**:
1. **Right monotonicity**: From `untl(xi∧b, eta∧b)` with `eta∧b → eta` derive `untl(xi∧b, eta) ∈ A`
2. **Left monotonicity**: Same chain as D1 to get `untl(b, eta) ∈ A`
3. **Contradiction**: Same approach as D1

**Status**: ✅ Structure complete. One `sorry` remains for full BX chain derivation.

## Key Lemmas Used

- `right_mono_until_mcs`: BX3 (right monotonicity) at MCS level
- `theorem_in_mcs` with `DerivationTree.temporal_necessitation`: For G(φ) ∈ A
- `Axiom.left_mono_until_G`: BX2G for left monotonicity under G
- `SetMaximalConsistent.implication_property`: Apply implications in MCS
- `SetMaximalConsistent.neg_excludes`: Derive contradiction from φ ∈ A and ¬φ ∈ A
- `self_accum_until_mcs`: BX5 self-accumulation
- Propositional lemmas: `lce_imp`, `rce_imp`, `pairing` from Bimodal.Theorems

## Remaining Work

### Inner BX Chain Derivation

Both D1 and D2 elimination have a `sorry` in the proof of:
```lean
have h_contra : Formula.untl (Formula.and beta0 eta) gamma0 ∈ A := by
  sorry  -- Requires full BX7 chain context from caller
```

**Why this requires caller context**:
The derivation of `untl(beta0∧eta, gamma0)` from `untl(b, eta)` requires:
1. The relationship between `b` and `beta0` (both in B via `burgessR3Maximal`)
2. The relationship between `eta` and `gamma0` (both in C)
3. The full BX7 chain structure including `h_until : untl(xi, eta) ∈ A`
4. BX13 enrichment with Since formulas from the seed

These connections are only available in the context of `lemma_2_7_seed_consistent` where:
- `h_r3m : BurgessR3Maximal A B C` provides the B-C relationships
- `h_until : Formula.untl xi eta ∈ A` provides the temporal context
- The seed components (B, xi, Until formulas, Since formulas) are all available

### Next Steps for Task 3.5

To complete the inner derivations:

1. **In `lemma_2_7_seed_consistent`**:
   - Extract the neg-until witness (beta0, gamma0) using `lemma_2_7_neg_untl_exists`
   - Apply BX5 self-accumulation to both `untl(xi, eta)` and `untl(b, γ_hat)`
   - Apply `linear_until_mcs` to get D1∨D2∨D3 ∈ A
   - Eliminate D1 and D2 using the newly implemented lemmas
   - Use surviving D3 with BX13 enrichment and BX10 to prove consistency

2. **For the inner `sorry`**:
   - Use `burgessR3Maximal` properties to relate `untl(b, eta)` to `untl(beta0, gamma0)`
   - Use BX13 enrichment to add `eta` to the guard
   - Use transitivity-like properties of Until in the BX system

## Verification

```bash
$ lake build
Build completed successfully (1097 jobs).
```

## Related Files

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - Main implementation
- `specs/107_chain_design_diagnostics_for_representation_theorem/plans/53_implementation-plan.md` - Updated plan

## References

- Burgess 1982, p.372 - Lemma 2.7 and the BX7 three-way disjunction
- BX Axiom Reference in Axioms.lean - BX2, BX3, BX5, BX7

## Dependencies

- Task 3.5 (`lemma_2_7_seed_consistent`) depends on Tasks 3.3 and 3.4
- The inner `sorry` in D1/D2 elimination will be filled when Task 3.5 is implemented
