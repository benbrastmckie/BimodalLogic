# Handoff: Task 107 Phase 3 Implementation (Session sess_1777270939_a91a7c)

## Session Context
- **Session ID**: sess_1777270939_a91a7c
- **Agent**: lean-implementation-agent
- **Plan**: specs/107_.../plans/31_implementation-plan.md (v18)
- **Phase 3**: PARTIAL (infrastructure built, seed construction blocked)
- **Status**: Partial progress -- key algebraic lemmas proved, limit_g corrected, seed gap identified

## Completed Work

### 1. BurgessR3 Guard Algebra (RRelation.lean, sorry-free)

Four new sorry-free lemmas proving algebraic closure properties of burgessR3 in the guard position:

- **`untl_conj_guard`**: If untl(beta1, gamma) and untl(beta2, gamma) are in MCS A, then untl(beta1 AND beta2, gamma) is in A. Uses BX7 (linear_until) + BX3 (right_mono_until). Three-way disjunction case analysis on BX7 output, with BX3 converting each disjunct to the target.

- **`snce_conj_guard`**: Mirror for Since direction. Uses BX7' (linear_since) + BX3' (right_mono_since).

- **`untl_left_mono_thm`**: If derivation_tree [] (beta1 -> beta2) and untl(beta1, gamma) in A, then untl(beta2, gamma) in A. Uses BX2 (left_mono_until) with temporal necessitation.

- **`snce_left_mono_thm`**: Mirror for Since direction. Uses BX2' (left_mono_since) with past necessitation.

These are building blocks for proving that deductive closure preserves burgessR3.

### 2. Correct limit_g Definition (ChronicleConstruction.lean, sorry-free)

Replaced the PLACEHOLDER `limit_g` (which used `deductiveClosure(g_content(limit_f(x)))` and ignored y) with the CORRECT definition:

```
limit_g(x, y) = g_n(x, y) for the first n where both x, y in dom(n)
```

This is well-defined because `omega_chain_g_agrees_le` ensures g-values are immutable once set. Added `limit_g_eq` theorem proving well-definedness.

Removed `limit_c1_at_domain` (was based on old placeholder, not used anywhere).

### 3. burgessR3Maximal_exists (RRelation.lean, WITH SORRY)

Added the seedless existence theorem:
```
theorem burgessR3Maximal_exists (A C : Set Formula)
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C) :
    ∃ B, BurgessR3Maximal A B C
```

This has a sorry. The root issue is the SEED CONSTRUCTION for `burgessR3Maximal_extension_exists`.

## Key Discovery: The Seed Construction Problem

### The Problem

`burgessR3Maximal_extension_exists` requires a DCS seed S with `burgessR3(A, S, C)`. No general construction of such a seed exists because:

1. **Empty set**: Vacuously satisfies burgessR3 but is NOT a DCS (missing theorems).

2. **Set of theorems** (deductiveClosure({})): IS a DCS. Does NOT satisfy burgessR3 in general. For theorem beta = top and gamma in C: untl(top, gamma) in A iff F(gamma) in A, which is NOT guaranteed for all gamma in C.

3. **Kernel set K** = {beta | burgessR(A, beta, C) AND burgessRSince(C, beta, A)}: Satisfies burgessR3 by construction. K subset A (proved via until_guard). Consistent. But NOT necessarily a DCS. And deductiveClosure(K) may NOT satisfy burgessR3 when K = empty (same issue as case 2).

4. **When K non-empty**: deductiveClosure(K) satisfies burgessR3 via the BX7+BX2 guard algebra (untl_conj_guard + untl_left_mono_thm). This was the breakthrough insight. But the nil case (theorems derivable from empty premises) remains problematic.

5. **Lindenbaum-with-side-condition**: Adding formulas one by one, preserving consistency + burgessR3, gives a maximal consistent set with burgessR3. But this set is NOT a DCS when theorems don't satisfy burgessR3 (which they don't in general).

### Root Cause

Under strict (irreflexive) temporal semantics, `G(beta) in A` does NOT imply `beta in A` (no T axiom). So `untl(beta, gamma) in A` (which semantically requires beta at the current point) is not guaranteed just from beta being a theorem.

In Burgess's original paper (reflexive semantics), theorems DO satisfy the Burgess r-relation because `G(beta) -> beta` holds, giving `beta -> (beta U gamma)` semantically.

### Resolution Path

The seedless existence theorem is NOT needed in full generality. The chronicle construction only needs BurgessR3Maximal in two specific contexts:

1. **C5 elimination** (adding endpoint): g_content(A) subset C. In this case, one can potentially construct a seed using the structure of C (which has g_content(A) subset C and P(U(xi,eta)) in C from lemma_2_4).

2. **C4 splitting** (inserting between): BurgessR3Maximal(A, B, C) already exists, and splitting is handled by `burgessR3_absorption` (already sorry-free).

The successor session should:
- Prove BurgessR3Maximal existence for the C5-specific case (where g_content(A) subset C)
- OR prove `G(beta) AND F(gamma) -> untl(beta, gamma)` which would unlock the general case
- OR use an alternative architecture that avoids the seed issue entirely

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- 4 sorry-free lemmas + 1 sorry theorem
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- correct limit_g definition + limit_g_eq

## Sorry Sites (5 total, +1 from session)

| File | Line | Description | Status |
|------|------|-------------|--------|
| RRelation.lean | 1151 | burgessR3Maximal_exists (seed gap) | NEW |
| CounterexampleElimination.lean | 332 | C4 hard case (Until) | Existing |
| CounterexampleElimination.lean | 448 | C4' hard case (Since) | Existing |
| ChronicleToCountermodel.lean | 615 | restricted_fuc Until | Existing |
| ChronicleToCountermodel.lean | 619 | restricted_fuc Since | Existing |

## Build Status

`lake build` succeeds. No regressions. 5 sorry sites (4 existing + 1 new).

## Recommended Next Steps

1. **Prove BurgessR3Maximal for C5-specific case**: When g_content(A) subset C, construct a seed using the additional structure available from lemma_2_4.

2. **Alternatively, prove G(beta) AND F(gamma) -> untl(beta, gamma)**: This would make ALL theorems satisfy burgessR for arbitrary C (since G(beta) is trivially true for theorems, and F(gamma) holds for gamma in any non-empty domain). This would unlock the general seedless existence.

3. **Then implement g-value population in elimination functions**: Once BurgessR3Maximal exists (for the right cases), modify each elimination function to construct proper g-values for new adjacent pairs.

4. **Phase 4A (C4 hard case)**: Can proceed in parallel once g-values exist, since `burgessR3_gamma_not_in_B` and `dcs_neg_insert_consistent` are already sorry-free.
