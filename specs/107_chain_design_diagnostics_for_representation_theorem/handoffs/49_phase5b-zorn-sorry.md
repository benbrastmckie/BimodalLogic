# Handoff: Phase 5b Zorn Inconsistent Case Sorry

**Session**: sess_1777488003_629971
**Date**: 2026-04-29
**Phase**: 5b-i (COMPLETED), 5b-ii (PARTIAL)

## What Was Done

### Phase 5b-i: Split DCS Definition + Update BurgessR3Maximal (COMPLETED)

1. Added `ClosedUnderDerivation` predicate to ChronicleTypes.lean (line 68)
2. Refactored `SetDeductivelyClosed` to use `ClosedUnderDerivation`: `SetConsistent S /\ ClosedUnderDerivation S`
3. Updated `BurgessR3Maximal` maximality clause to quantify over `ClosedUnderDerivation` sets
4. Fixed `BurgessR3Maximal_extension_fails` in PointInsertion.lean (`.2` -> `.2` still works, `.2.2` accepts `ClosedUnderDerivation`)
5. Added sorry for Zorn inconsistent case in `burgessR3Maximal_extension_exists` (RRelation.lean:772)
6. `lake build` succeeds

### Phase 5b-ii: Close Inconsistent Case (PARTIAL)

Implemented and proved sorry-free:
- `set_univ_closed_under_derivation` (trivial)
- `ex_falso_from_assumption`: `[] |- phi -> (phi.neg -> psi)` for any psi
- `G_ex_falso_strengthen`: `G(phi.neg -> psi) in A` from `G(phi) in A`
- `H_ex_falso_strengthen`: `H(psi.neg -> chi) in C` from `H(psi) in C`
- `neg_mem_of_inconsistent_union`: `phi.neg in B` from `not SetConsistent ({phi} union B)` and `SetDeductivelyClosed B`
- `dcs_ssubset_univ`: `B subset_strict Set.univ` when B is consistent DCS
- `burgessR3_univ_of_inconsistent_ext`: `burgessR3(A, Set.univ, C)` from phi.neg in B, G(phi) in A, burgessR3(A, B, C)
- **g_content_sub_B_of_BurgessR3Maximal**: CLOSED (both cases, sorry-free)
- **h_content_sub_B_of_BurgessR3Maximal**: CLOSED (both cases, sorry-free)
- splitting_seed_consistent: was already sorry-free (depends on g_content_sub_B, h_content_sub_B)

## Remaining Sorry

### RRelation.lean:772 -- Zorn Inconsistent ClosedUnderDerivation Case

**Location**: `burgessR3Maximal_extension_exists`, after the Zorn construction
**Goal state**:
```
hD_cons : not SetConsistent D
hD_cud : ClosedUnderDerivation D
hBD : B strict_subset D
hD_r3 : burgessR3 A D C
hB_dcs : SetDeductivelyClosed B
|- False
```

**Analysis**: D is inconsistent and ClosedUnderDerivation, so D = Set.univ. We have burgessR3(A, Set.univ, C). Need: this is impossible.

burgessR3(A, Set.univ, C) means: for ALL beta, for all gamma in C: untl(beta, gamma) in A; and for ALL beta, for all alpha in A: snce(beta, alpha) in C.

I attempted several proof strategies:
1. **BX7 (linearity)**: Taking phi1 = gamma, phi2 = gamma.neg yields untl(gamma, bot) or untl(bot, gamma). untl(gamma, bot) gives F(bot) in A -- contradiction! But untl(bot, gamma) is satisfiable on non-dense frames (immediate successors). So BX7 only rules out one disjunct.
2. **BX13 (enrichment)**: Produces increasingly complex Until/Since formulas but never bot.
3. **Semantic argument**: untl(bot, gamma) is satisfiable on discrete (non-dense) frames where the immediate successor exists.

**Conclusion**: neg-burgessR3(A, Set.univ, C) CANNOT be proved in TM = S5 + LTL without density axioms. On discrete frames, a model exists where all untl(psi, gamma) hold (immediate successor witnesses).

### Impact

- `burgessR3Maximal_extension_exists` has sorryAx (NEW)
- `burgessR3Maximal_exists_from_seed` inherits sorryAx (NEW)
- `burgessR3Maximal_from_g_content_sub` inherits sorryAx (NEW)
- `lemma_2_6_splitting` inherits sorryAx (UNCHANGED -- was already sorryAx from g_content_sub_B sorry)
- `g_content_sub_B_of_BurgessR3Maximal` is sorry-free (IMPROVED -- was sorry)
- `h_content_sub_B_of_BurgessR3Maximal` is sorry-free (IMPROVED -- was sorry)

Net sorry change in modified files: -2 + 1 = -1 (improvement)

## Possible Resolutions

1. **Revert BurgessR3Maximal to SetDeductivelyClosed maximality**: Removes the Zorn sorry but re-introduces g_content_sub_B sorry. The MCS case of the inconsistent argument is genuinely blocked without density.

2. **Add hypothesis to burgessR3Maximal_extension_exists**: Require `not burgessR3 A Set.univ C` as a precondition. Then callers must discharge this. At `burgessR3Maximal_from_g_content_sub`, this might be provable from `g_content(A) subset C` + additional properties. Needs investigation.

3. **Prove at call sites**: Instead of fixing burgessR3Maximal_extension_exists in general, prove BurgessR3Maximal existence directly at each call site with the additional hypotheses available there (g_content(A) subset C, specific seed structure).

4. **Accept the sorry**: The sorry does not introduce NEW sorryAx damage (lemma_2_6_splitting already had sorryAx). The sorry is more localized than before (1 sorry replacing 2).

5. **Density axiom approach**: If the axiom system were restricted to dense orders, untl(bot, gamma) would be unsatisfiable and the proof would close. But TM covers all linear orders.

## Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- ClosedUnderDerivation, SetDeductivelyClosed refactor, BurgessR3Maximal update
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- 8 new helper theorems, 2 sorry sites closed
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- Zorn proof updated with consistent/inconsistent split (1 sorry)
