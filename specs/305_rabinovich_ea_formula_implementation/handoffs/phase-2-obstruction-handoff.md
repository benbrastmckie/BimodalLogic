# Handoff: Task 305 Phase 2 Obstruction Analysis

## Immediate Next Action

Research and implement one of the four resolution paths for the arity growth obstruction (see below).

## Current State

- Phase 0: COMPLETED (bypass archival)
- Phase 1: PARTIAL (base case sorry-free, succ case genuine obstruction, not critical)
- Phase 2: BLOCKED (arity growth obstruction)
- Phase 3: NOT STARTED (depends on Phase 2)
- Phase 4: NOT STARTED (depends on Phase 3)
- Sorry count: 1 critical (KampPrior.lean:131), 3 non-critical
- Build: passes with warning

## Key Decisions

### Analysis of the sorry at KampPrior.lean

The sorry is in the `succ k` case of `nf_characterizable_temporal_prior`. The goal is to produce a temporal `Formula` characterizing a depth-(k+1) arity-1 NF on Prior structures.

The proof decomposes the NF into atoms + quantifier map. The atom part is handled by `nf_depth0_char_formula`. The quantifier part requires converting `exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf` to a temporal formula for each `sub_nf : NormalForm sig k 2`.

### The Circular Dependency

Via `nf_to_formula_correct`, the existential equals `eval M (fun _ => t) (.ex (nf_to_formula sub_nf))`, a `MonadicFormula sig 1` with quantifier depth <= k+1. This is the SAME depth being constructed. The IH provides depth-k arity-1 formulas, but the existential has depth k+1.

### Four Resolution Paths

**(a) Rabinovich Prop 4.3 (V-EA structural induction)**
- Convert `MonadicFormula sig 2` to VVecEA2 by structural induction
- The `ex` case introduces `MonadicFormula sig 3`, needing arity-3 V-EA
- Requirement: general `VecEA_n` infrastructure for arbitrary arity
- Estimated effort: 500+ lines of new infrastructure
- Files: new `VecEAGeneral.lean` + modify `FOToVEA.lean`

**(b) Fix Stavi backward sorry**
- `nf_exist_sf_guarded_backward` at StaviCompleteness.lean:2873 is sorry
- Combined with `flatten_stavi_correct_prior` (PriorExpressiveness.lean, sorry-free), this would give the conversion
- The backward sorry needs the GHR93 bridge lemma (`nf_2var_from_interval_data`)
- Estimated effort: 300-500 lines (bridge lemma implementation)

**(c) Z-completeness transfer**
- Use `US_expressively_complete_over_Z` (sorry-free) to get temporal formula on Z
- Show every depth-k arity-1 NF is realizable on some Z-structure
- Then transfer: same formula works on all Prior structures
- Requirement: NF realizability theorem
- Estimated effort: 200-400 lines

**(d) Alternative proof structure**
- Prove `kamp_prior_expressive_completeness` directly by structural induction on `MonadicFormula sig 1`, bypassing NF depth induction
- The `ex` case still needs arity-2 to temporal conversion
- Blocked by same arity tower unless VVecEA2 mutual induction is used
- Estimated effort: similar to (a)

### Recommendation

Path (c) (Z-transfer) appears most tractable. The key theorem needed is:

```lean
theorem nf_realizable_on_Z (k n : Nat) (nf : NormalForm sig k n) :
    exists (Z : ZStructure sig) (env : Fin n -> Int),
      nf_eval_nf (Z.toOrdered sig) k n env nf
```

This should be provable by induction on k, using the fact that Z-structures can have arbitrary predicate interpretations and the integers have the density/separation properties needed.

## Sorry Inventory

1. **KampPrior.lean:131** -- CRITICAL PATH TARGET. `nf_characterizable_temporal_prior` succ case. Blocked by arity growth obstruction.
2. **EndpointNegation.lean:160** -- Not critical. Genuine obstruction (same class as EANegation.lean:1084).
3. **EANegation.lean:1084** -- Permanent impossibility. Interior witnesses prevent model-independent biconditional.
4. **EANegation.lean:1235** -- Permanent impossibility. Same class as 1084.

## Files Modified

- `KampPrior.lean` -- added NfToVecEA import, cleaned up comments, documented obstruction
- `plans/24_faithful-restructure.md` -- Phase 2 marked [BLOCKED] with detailed blocker

## References

- NfToVecEA.lean: `nf_2var_exist_depth0_tl` (sorry-free depth-0 existential to temporal)
- StaviCompleteness.lean: `nf_2var_existence_characterizable`, `nf_exist_sf_guarded_backward` (sorry)
- PriorExpressiveness.lean: `flatten_stavi_correct_prior` (sorry-free Stavi to temporal on Prior)
- ExpressiveCompleteness/Theorem.lean: `US_expressively_complete_over_Z` (sorry-free Z-completeness)
- NormalForm.lean: `nf_to_formula`, `nf_to_formula_correct` (sorry-free NF to MonadicFormula)
- Table.lean: `table_correctness` (sorry-free Formula to MonadicFormula)
