# Implementation Summary: Task #571

**Completed**: 2026-01-18
**Session**: sess_1768772984_e64cb4
**Status**: PARTIAL (2 of 3 theorems proven, 1 blocked)

## Summary

Partially implemented MCS infrastructure for the syntactic completeness approach. Successfully proved `closure_mcs_negation_complete` and `worldStateFromClosureMCS_models_iff`. Additionally proved `closure_mcs_imp_closed` which was needed as a helper. The third theorem `closure_mcs_implies_locally_consistent` is architecturally blocked due to temporal semantics mismatch.

## Changes Made

### Theorems Proven

1. **`closure_mcs_negation_complete`** (lines 669-795)
   - Proves that for any formula in the closure, either it or its negation is in the closure MCS
   - Uses by_contra approach with case analysis
   - Leverages deduction theorem to derive contradiction from assuming both are absent

2. **`closure_mcs_imp_closed`** (lines 796-890)
   - Helper lemma: if an implication and its antecedent are in the closure MCS, the consequent is too
   - Uses cut/substitution pattern via deduction theorem
   - Essential for downstream proofs

3. **`worldStateFromClosureMCS_models_iff`** (lines 1264-1281)
   - Proves that formula membership in closure MCS equals truth in the derived world state
   - Uses `Classical.propDecidable` instance for decide lemmas
   - Definitional unfolding proof

### Theorems Blocked

4. **`closure_mcs_implies_locally_consistent`** (line 1252 - sorry with documentation)
   - **Blocked by architectural mismatch**: `IsLocallyConsistent` requires temporal reflexivity axioms (Hpsi -> psi, Gpsi -> psi), but the TM logic uses strict past/future semantics (forall s < t, forall s > t), making these NOT valid theorems
   - Detailed documentation added explaining the limitation
   - The semantic approach (`semantic_weak_completeness`) bypasses this issue entirely

### Supporting Changes

- Made `cons_filter_neq_perm` public in Completeness.lean (was private)
- Made `derivation_exchange` public in Completeness.lean (was private)

## Files Modified

- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
  - Proved `closure_mcs_negation_complete` (~125 lines)
  - Proved `closure_mcs_imp_closed` (~95 lines)
  - Proved `worldStateFromClosureMCS_models_iff` (~20 lines)
  - Documented `closure_mcs_implies_locally_consistent` as architecturally blocked

- `Theories/Bimodal/Metalogic/Completeness.lean`
  - Made `cons_filter_neq_perm` public
  - Made `derivation_exchange` public

## Verification

- `lake build`: SUCCESS (976 jobs)
- All three target lines verified:
  - Line 669: `closure_mcs_negation_complete` - PROVEN
  - Line 1048 (now ~1234): `closure_mcs_implies_locally_consistent` - BLOCKED (sorry with documentation)
  - Line 1067 (now ~1281): `worldStateFromClosureMCS_models_iff` - PROVEN

## Architectural Findings

The syntactic approach in FiniteCanonicalModel.lean has a fundamental issue:

1. `IsLocallyConsistent` (conditions 4-5) requires temporal reflexivity: if Hpsi holds, then psi holds; if Gpsi holds, then psi holds
2. The TM logic uses **strict** temporal semantics: H is "for all past times" (strictly before), G is "for all future times" (strictly after)
3. These semantics do NOT validate reflexivity axioms
4. Therefore `closure_mcs_implies_locally_consistent` cannot be proven without changing either:
   - The axiom system (add reflexivity)
   - The `IsLocallyConsistent` definition (weaken conditions 4-5)
   - The completeness approach (use semantic approach instead)

**Recommendation**: The semantic approach (`semantic_weak_completeness`) is already fully proven and bypasses this issue. Consider deprecating the syntactic approach or addressing the architectural mismatch in a separate task.

## Impact on Downstream Tasks

- **Task 566 (Semantic Embedding)**: Still blocked by `closure_mcs_implies_locally_consistent`
- **Tasks 572, 573**: Depend on this infrastructure; may need to pivot to semantic approach

## Notes

- The proofs developed here demonstrate correct MCS property handling
- The blocking issue is architectural, not a proof gap
- Significant time saved by discovering the semantic approach already exists
