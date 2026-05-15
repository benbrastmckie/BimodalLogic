# Research Report: Task #129

**Task**: weak_reflexive_completeness_conservative_extension
**Date**: 2026-05-14
**Mode**: Team Research (4 teammates)
**Session**: sess_1778805087_551a07

## Summary

Systematic audit of Task 129 after multiple cut-off implementation rounds. Four teammates independently examined: (A) actual Lean code vs. plan claims, (B) fidelity to Reynolds 1994, (C) gaps/dead code/mathematical errors, (D) strategic direction. All four converge on the same core assessment: the plan overstates completion, the build is currently broken, and the formalization contains a fundamental circularity that defeats the task's purpose.

## Key Findings

### 1. BUILD IS BROKEN (All 4 teammates confirm)

`NEquivalence.lean` (uncommitted changes) defines `ZStructure` and `ZStructure.toMonadic`, which are also defined in `IntegerModel.lean`. Since IntegerModel imports NEquivalence transitively via OrderedSum, Lean rejects the redefinitions. The plan's claim that "Phase 7: lake build passes (1644 jobs)" is false for the current working tree.

**Fix**: Keep `ZStructure` in NEquivalence.lean (where `KEquivalenceFramework` references it) and remove the duplicate from IntegerModel.lean. Move `ZStructure.toOrderedMonadic` to NEquivalence.lean if unique to IntegerModel.

### 2. `KEquivalenceFramework.z_model_exists` Is Circular (All 4 teammates confirm)

The `z_model_exists` field in `KEquivalenceFramework` directly axiomatizes: "Every countable discrete linear order without endpoints, satisfying Prior-UZ/SZ, is k-equivalent to a Z-structure." This IS Reynolds Theorem 15 — the very theorem the task is trying to prove. Including it as an axiom makes the entire pipeline circular. The framework was intended to axiomatize properties FROM Doets 1989, but `z_model_exists` axiomatizes the CONCLUSION of the proof built on those properties.

**Fix**: Remove `z_model_exists` from the typeclass. Theorem 15 must be proved from the other fields (sum_preservation, finite_types, etc.) and the gap-elimination argument.

### 3. `good` Uses Full Z Instead of Z-Interval (Teammate B, confirmed by D)

Reynolds defines "good" as k-equivalent to "an interval of the integers" — possibly finite ({a, ..., b}), half-infinite, or all of Z. The formalization's `ZStructure` forces `carrier := Z` (always the full integers). This makes `finite_structures_good` **mathematically false** for k >= 3: no finite structure with endpoints can be k-equivalent to endpoint-free Z.

This is a critical error because the entire one-class argument depends on finite subintervals being good. Reynolds's Lemma 16 specifically handles finite-to-finite-interval equivalence.

**Fix**: Replace `ZStructure` with a type allowing finite Z-intervals (e.g., `{n : Z // lo <= n /\ n <= hi}` carrier, or an order-isomorphism to some interval of Z).

### 4. Plan Massively Overstates Completion (Teammates A, C)

| Plan Claim | Reality |
|------------|---------|
| "Phase 7: lake build passes (1644 jobs)" | BUILD FAILS (duplicate ZStructure) |
| "one_class is sorry-free" | SORRY |
| "Gap-elimination lemmas are sorry-free" | Both SORRY |
| "doets_lemma_1_4 is sorry-free" | Only the `_finite` variant is sorry-free |
| "finite_structures_k_equiv_to_Z_interval is sorry-free" | SORRY |
| "No vacuous definitions remain" | `reflCanToMonadic` has `interp _ _ := True` |
| "KEquivalenceFramework has 5 fields" | Has 6 (includes circular `z_model_exists`) |

Phases 3-7 should all be marked **[PARTIAL]**, not [COMPLETED].

### 5. MonadicSentence Lacks Order Relation (Teammate B)

`MonadicSentence` has: `atom`, `not`, `and`, `forall`. It lacks the order relation `<`, which is the backbone of the monadic language over ordered structures. Without it, k-equivalence cannot express anything about the temporal order, making it semantically meaningless.

### 6. OrderedSum Returns Unordered Structure (Teammate B)

`OrderedSum` is defined as a `MonadicStructure` (no order), not an `OrderedMonadicStructure`. The Sigma carrier has no lexicographic order. Doets Lemma 1.4 requires the ordered sum to carry the lexicographic order.

### 7. Doets Lemma 1.5 Incorrectly Stated (Teammate B)

`doets_lemma_1_5` claims ANY two ordered sums are k-equivalent unconditionally. This is trivially false. The correct statement requires matching type distributions between the two indexed families.

### 8. Table Translation Completely Vacuous (Teammates A, C, D)

- `table` body is sorry
- `table_correctness` conclusion is `True` (proves nothing)
- `Formula.complexity` sets Until/Since to 0 (mathematically incorrect)
- Missing functions: `mkSigFrom` and `mkAtomMap` don't exist anywhere

### 9. Dead Code From Multiple Rounds (Teammate C)

- `canonical_model_is_good` (deprecated, 0 callers)
- `reflCanR_linear` (confirmed dead, 0 callers)
- `reflCanToMonadic` (vacuous body, 0 callers)
- `table_correctness` with `True` conclusion

## Sorry Census

17-18 sorries across target files (teammates differ slightly on count due to classification of deprecated theorems). Classified by dependency tier:

### Tier 1: Deep Blockers (require new mathematical content)

| # | File | Declaration | Issue |
|---|------|-------------|-------|
| 1 | NEquivalence | `k_type_of` | Requires FO satisfaction relation |
| 2 | NEquivalence | `ktype_finite` | Requires monadic sentence enumeration |
| 3 | Table | `table` | Requires full table translation |

### Tier 2: Blocked by Tier 1

| # | File | Declaration | Blocked By |
|---|------|-------------|------------|
| 4 | NEquivalence | `k_equiv_monotone` | `k_type_of` |
| 5 | OrderedSum | `doets_lemma_1_4` | No KEquivalenceFramework instance |
| 6 | OrderedSum | `finite_structures_k_equiv_to_Z_interval` | `k_type_of` + `doets_lemma_1_4` |
| 7 | IntegerModel | `finite_structures_good` | `finite_structures_k_equiv_to_Z_interval` |
| 8 | Table | `table_depth_bound` | `table` |

### Tier 3: Blocked by Tier 2

| # | File | Declaration | Blocked By |
|---|------|-------------|------------|
| 9 | IntegerModel | `contemp_equiv_is_equiv` | `finite_structures_good` + Lemma 1.4 |
| 10 | IntegerModel | `no_gaps_discrete` | `contemp_equiv_is_equiv` |
| 11 | IntegerModel | `no_boundary_at_successor` | `finite_structures_good` |
| 12 | IntegerModel | `one_class` | 9 + 10 + 11 |
| 13 | IntegerModel | `very_good_implies_good` | Cofinal sequence + Lemma 1.4 |
| 14 | IntegerModel | `chronicle_is_good` | 12 + 13 |

### Tier 4: Should Remove

| # | File | Declaration | Reason |
|---|------|-------------|--------|
| 15 | IntegerModel | `canonical_model_is_good` (2 sorries) | Deprecated, 0 callers |
| 16 | Table | `table_correctness` | Conclusion is `True` |
| 17 | OrderedSum | `doets_lemma_1_5` | Deferred, not needed for discrete case |

## Synthesis

### Conflicts Resolved

1. **Sorry count (A: 18, B: 15, C: 17, D: 18)**: Discrepancy due to counting deprecated `canonical_model_is_good` (2 sorries) and `table_correctness` (vacuous). Actual count in target files: **17 substantive sorries** plus 3 that should be removed (deprecated/vacuous).

2. **`contemp_equiv` correctness (B: faithful, C: deviates)**: B says the `min/max` formulation is faithful; C says it deviates by not handling `a = b` explicitly. **Resolution**: Mathematically equivalent — when `a = b`, `subinterval a a` is singleton, and `very_good` of singleton requires all sub-subintervals to be good, which reduces to the singleton itself being good. However, C correctly notes this proof path is BLOCKED by `finite_structures_good`, whereas Reynolds's explicit `a = b` case is trivially reflexive. **Recommendation**: Add explicit `a = b` case to `contemp_equiv` to match Reynolds literally and avoid the blocked proof path.

3. **Doets Lemma 1.5 needed? (D: no, C: yes for Lemma 16)**: D says the discrete case bypasses 1.5 entirely. C argues Lemma 16 (very good → good) needs it for the cofinal sequence composition. **Resolution**: Both partially right. The discrete one-class argument doesn't need 1.5, but `chronicle_is_good` needs to recombine finite good subintervals into the full structure. Doets 1.4 (finite ordered sums) suffices for this — apply it pairwise/iteratively. 1.5 (countable ordered sums with matching type distributions) is not needed.

### Gaps Identified

1. **FO satisfaction relation**: The single biggest gap. Without it, `k_type_of`, `k_equiv`, and everything downstream are hollow. Teammate D estimates ~100 lines for finite structures.

2. **Z-interval structures**: `ZStructure` needs to allow finite intervals. Current definition blocks `finite_structures_good`.

3. **Order in MonadicSentence**: The `<` relation must be part of the monadic language for k-equivalence to be meaningful over ordered structures.

4. **Table translation**: On the critical path for Transfer.lean but substantial work (full Reynolds Section 4 content).

5. **Missing utility functions**: `mkSigFrom`, `mkAtomMap` referenced in Transfer.lean but don't exist.

### Recommendations

**Phase 1: Fix structural errors (estimated 2-4 hours)**
1. Fix build: remove duplicate `ZStructure` from IntegerModel.lean
2. Remove `z_model_exists` from `KEquivalenceFramework` (circular)
3. Fix `good` definition to allow Z-intervals (not just full Z)
4. Add `<` to `MonadicSentence` (or encode order structurally)
5. Fix `OrderedSum` to return `OrderedMonadicStructure`
6. Fix `doets_lemma_1_5` type signature (add matching hypothesis)
7. Add explicit `a = b` case to `contemp_equiv`
8. Delete dead code: `canonical_model_is_good`, `reflCanToMonadic`, vacuous `table_correctness`
9. Fix `Formula.complexity` for Until/Since

**Phase 2: Core mathematical content (estimated 15-25 hours)**
1. Define FO satisfaction relation for finite monadic structures (~100 lines)
2. Prove `finite_structures_good` (finite structure → good, using FO satisfaction)
3. Prove `no_boundary_at_successor` (2-element case + finite_structures_good)
4. Prove `contemp_equiv_is_equiv` (transitivity via Lemma 1.4 for n=2)
5. Prove `no_gaps_discrete` (discrete supremum + contemp_equiv_is_equiv)
6. Prove `one_class` (Reynolds's 4-line argument)
7. Prove `chronicle_is_good` (one_class + cofinal sequence + pairwise Lemma 1.4)

**Phase 3: Integration (estimated 5-10 hours)**
1. Define `table` translation (Reynolds Section 4)
2. Define `mkSigFrom`, `mkAtomMap`
3. Prove `table_correctness` with correct type signature
4. Wire Transfer.lean to use Reynolds pipeline
5. Verify `#print axioms bx_completeness` shows no `succ_cofinal`

**Phase 4: Plan corrections**
1. Mark phases 3-7 as [PARTIAL] in the plan
2. Update sorry counts and completion claims
3. Update state.json `completion_summary`

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Code vs. Plan Audit | completed | HIGH |
| B | Reynolds 1994 Fidelity | completed | HIGH |
| C | Critic (gaps/errors) | completed | HIGH |
| D | Strategic Direction | completed | HIGH |

## References

- Reynolds 1994, "Axiomatising U and S over Integer Time" — Theorem 15, Lemma 16, Theorem 18
- Doets 1989, "Monadic Pi-1-1 Theories" — Lemmas 1.1, 1.4, 1.5
- Individual teammate reports:
  - `specs/129_weak_reflexive_completeness_conservative_extension/reports/09_teammate-a-findings.md`
  - `specs/129_weak_reflexive_completeness_conservative_extension/reports/09_teammate-b-findings.md`
  - `specs/129_weak_reflexive_completeness_conservative_extension/reports/09_teammate-c-findings.md`
  - `specs/129_weak_reflexive_completeness_conservative_extension/reports/09_teammate-d-findings.md`
