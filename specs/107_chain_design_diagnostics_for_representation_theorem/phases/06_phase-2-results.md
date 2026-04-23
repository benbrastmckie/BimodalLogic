# Phase 2 Results: Burgess Chronicle Type and r-Relation (Lemmas 2.2-2.3)

## Status: PARTIAL (1 sorry)

## Files Created

### `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean`
- **SetDeductivelyClosed**: DCS definition (consistent + closed under derivation)
- **mcs_is_dcs**: Every MCS is a DCS (sorry-free)
- **dcs_contains_theorems**: DCS contains all theorems (sorry-free)
- **dcs_modus_ponens**: Modus ponens in DCS (sorry-free)
- **dcs_conj_closed**: DCS closed under conjunction (sorry-free)
- **Adjacent**: Adjacency predicate for domain points
- **rRelation / rRelationSince**: The r-relation for Until/Since
- **rMaximal / rMaximalSince**: R-maximality definitions
- **Chronicle**: Core data structure (f, g, dom)
- **Chronicle.c0-c5'**: All chronicle conditions
- **ValidChronicle**: Structure with all conditions
- **rRelation_subset**: r-relation monotone under superset (sorry-free)
- **rRelation_of_superset_mcs**: r(A,B) when A subset B (MCS B) (sorry-free)
- **rRelationSince_of_superset_mcs**: Since version (sorry-free)

### `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean`
- **until_guard_consistent** (Lemma 2.2): **SORRY** -- see below
- **until_disjunction_in_mcs**: gamma U delta in A -> gamma v delta in A (sorry-free)
- **until_implies_F_in_mcs**: gamma U delta in A -> F(delta) in A (sorry-free)
- **until_self_accum_in_mcs**: gamma U delta in A -> (gamma ^ (gamma U delta)) U delta in A (sorry-free)
- **since_disjunction_in_mcs**: Since version of disjunction (sorry-free)
- **since_implies_P_in_mcs**: Since version of eventuality (sorry-free)
- **rRelation_guard_continues'**: r(A,B) + delta not in B -> gamma in B (sorry-free)
- **rRelation_of_subset_mcs**: r(A,B) when A subset B (sorry-free)
- **deductiveClosure**: Definition (sorry-free)
- **subset_deductiveClosure**: S subset deductiveClosure(S) (sorry-free)
- **deductiveClosure_closed**: Closure under derivation (sorry-free)
- **deductiveClosure_consistent**: Preserves consistency (sorry-free)
- **deductiveClosure_is_dcs**: Deductive closure is a DCS (sorry-free)
- **rMaximal_extension_exists**: R-maximal DCS exists via Zorn (sorry-free)
- **rMaximalSince_extension_exists**: Since version (sorry-free)

## Sorry Analysis

### `until_guard_consistent` (Lemma 2.2)

**Claim**: If gamma U delta in MCS A, then {gamma} is consistent.

**Issue**: Under strict (irreflexive) semantics, BX9 only gives gamma v delta from gamma U delta, not gamma alone. The original Burgess proof uses reflexive Until semantics where gamma U delta semantically implies gamma (since the guard includes the current time). Under strict semantics, the current axiom system does not provide a derivation of gamma from gamma U delta.

**Impact**: This sorry is NOT blocking for the chronicle construction. The r-relation infrastructure (which is the main purpose of Phase 2) is fully sorry-free. The guard consistency is only needed as a stepping stone in Lemma 2.4 (Phase 3), where the actual seed consistency for extending g_content is established using `forward_temporal_witness_seed_consistent` from the existing codebase (which requires F(psi) in M, not {gamma} consistent).

**Possible Resolutions**:
1. Add a derived axiom gamma U delta -> gamma (sound under half-open guard semantics where t in [t,s))
2. Use the existing BX9 (gamma U delta -> gamma v delta) and handle both cases in downstream lemmas
3. Drop Lemma 2.2 entirely if downstream uses can be restructured

## Build Verification

- `lake build` succeeds (949 jobs)
- No errors in new files
- No new axioms introduced
- All chronicle types and r-relation lemmas compile
- Zorn's lemma application for R-maximal existence fully proved

## Summary

Phase 2 is substantially complete. The Chronicle data structure, DCS definition, r-relation, R-maximality, and the Zorn's lemma existence proof for R-maximal extensions are all sorry-free. The only sorry is Lemma 2.2 (`until_guard_consistent`), which is a non-blocking technical issue specific to strict semantics.
