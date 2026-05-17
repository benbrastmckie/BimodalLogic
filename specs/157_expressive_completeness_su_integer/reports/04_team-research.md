# Research Report: Task #157 -- Phase 6 Blocker Resolution

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-17
**Mode**: Team Research (4 teammates)
**Session**: sess_1779042202_561806
**Focus**: Resolve the circular dependency blocking axiom elimination in Phase 6

## Summary

The Phase 6 blocker -- a circular dependency between `all_separable`, temporal closure axioms, and Cases 5-8 -- is an **architectural artifact**, not a mathematical impossibility. All 4 teammates converge on the same resolution: prove `no_S_nested_in_U_separable` by strong induction on junction_depth using only Cases 1-4 plus `neg_until_equiv`, then derive all 4 temporal closure axioms as theorems. The GHR94 proof hierarchy (Lemmas 10.2.4-10.2.8) supports this approach; the circularity arose from implementing Cases 5-8 as standalone lemmas that shortcut to `all_separable`. A backup path exists via GHR94 Ch 10.3 Dedekind formulas that specialize correctly to Z (K+=K-=T, G+-=bot). Phase 7 is confirmed independent of Phase 6 and can proceed in parallel.

## Key Findings

### 1. The Circularity Is Architectural, Not Mathematical (All Teammates)

The circular dependency:
```
all_separable -> temporal closure axioms -> Cases 5-8 -> all_separable
```

arises because `case5_separable` through `case8_separable` (NormalForm.lean) are proved by `all_separable _` -- a direct shortcut that bypasses the actual GHR94 proof structure. Cases 5-8 do NOT logically require `all_separable`; they only USE it as their current proof method.

The GHR94 proof hierarchy handles Cases 5-8 within a junction-depth induction (Lemma 10.2.7), where these cases arise at LOWER junction_depth and are handled by the induction hypothesis -- not by standalone separated formulas.

### 2. No Correct Explicit Cases 5-8 Formulas Exist for Z in the Literature (Teammate A)

All 4 GHR94 dense-time formulas fail on Z due to vacuous B-guards on empty open intervals. No correction has been found, and finding correct explicit formulas is likely an open mathematical problem. However, this is NOT the correct path forward -- the junction-depth induction avoids needing them entirely.

### 3. The Key Theorem: `no_S_nested_in_U_separable` (All Teammates)

All teammates converge on the same missing theorem:
```lean
theorem no_S_nested_in_U_separable (phi : Formula)
    (h : no_S_nested_in_U phi) : is_separable phi
```

Once proved WITHOUT axioms, all 4 temporal closure axioms follow:
- **snce_separable**: separated args -> box-normalize -> `no_S_nested_in_U` -> separable
- **untl_separable**: by swap_temporal duality from snce_separable  
- **all_past_separable**: `all_past (separated phi)` has `no_S_nested_in_U` -> separable
- **all_future_separable**: by duality

The TemporalClosure.lean infrastructure (`replace_box_separated_no_S_nested`, `swap_no_U_nested_gives_no_S_nested`, `snce_of_boxfree_sep_jd_le_one`) is already in place to make these derivations work.

### 4. The `snce` Case Is Trivial; `all_past`/`all_future` Are Hard (Teammate C)

Teammate C's critical insight: `no_S_nested_in_U (snce C F)` requires both C and F to be U-free. U-free snce args make the formula already syntactically separated -- the snce case is TRIVIAL. The genuinely hard cases are `all_past` and `all_future`, which require temporal closure reasoning.

The `expand_temporal` infrastructure (Tasks 6.1-6.6) handles these: on Z, `all_past a ~ neg(snce (neg a) top)`. After expansion, the formula is in the restricted {atom, bot, imp, snce, untl, box} fragment where junction-depth induction works cleanly.

### 5. Dedekind Formulas Specialize Correctly to Z (Teammate D)

GHR94 Ch 10.3 Lemma 10.3.11 gives explicit separated formulas for Cases 5-8 over Dedekind-complete time. On Z:
- K+q = K-q = T (vacuous satisfaction from empty intervals at successor)  
- G+(B) = G-(B) = bot

These substitutions dramatically simplify the Dedekind formulas, producing a 3-disjunct Case 5 formula (one disjunct vanishes). This provides a concrete backup path (~200-350 LOC for Case 5) if the junction-depth induction proves difficult.

### 6. Phase 7 Is Independent of Phase 6 (Teammate C, confirmed by all)

The 2 sorries in ExpressiveCompleteness.lean (lines ~667, ~685) are quantifier elimination cases (`.all` and `.ex`), completely independent of separation axioms. Phase 7 can proceed in parallel with Phase 6.

### 7. `abstract_untl_preserves_separated` Is Provable But Insufficient Alone (Teammate B)

Teammate B proved that `abstract_untl_preserves_separated` IS correct (~50 LOC) and the proof sketch is sound: in a separated formula, U-free snce/all_past args are untouched by abstract_untl (identity on U-free), so separation is preserved. However, this alone does not bypass Cases 5-8 because substituting back into snce args reintroduces U-under-S.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| Teammate A says ~580 LOC vs Teammate D says 400-600 LOC | Converge on 400-600 LOC: duality halves the work (prove one direction, derive the other via swap_temporal) |
| Teammate B says restricted subst_separable is primary vs others say WF induction | Resolved: Teammate B's own analysis showed the approach fails for Cases 5-8 (Example 3 correction). WF induction is primary. |
| Teammate C says `all_past`/`all_future` are the REAL hard cases vs others focus on snce | Resolved: both views are correct. The snce case of `no_S_nested_in_U_separable` is trivial. The temporal closure axioms for all_past/all_future are the real work, handled via expand_temporal + the WF induction on the expanded form. |

### Gaps Identified

1. **GHR94 Case 5 counterexample is NOT Lean-verified** (Teammate C): The counterexample in Eliminations.lean is in a comment, not a `#eval` or `example`. Should be formalized.
2. **`abstract_snce` not implemented** (Teammates A, C, D): The dual of `abstract_untl` is needed for Lemma 10.2.8's inductive step. ~100 LOC.
3. **Lean termination checker may need explicit annotations** (Teammates A, D): Strong induction via `Nat.strongRecOn` is recommended over `termination_by` to avoid Lean's structural recursion limitations.
4. **`multi_U_formula_separable` shortcuts to `all_separable`** (Teammate C): Hierarchy.lean line 545 needs to be replaced with the actual Lemma 10.2.6 proof.

### Recommendations

**Primary path** (HIGH confidence, ~400-600 LOC):

1. Prove `no_S_nested_in_U_separable` by strong induction on junction_depth:
   - Base (JD=0 after expand_temporal): `expanded_jd_zero_imp_separated` (already proved)
   - Step (JD=n+1): Use Cases 1-4 + `neg_until_equiv` to reduce. Cases 5-8 situations at JD=1 are handled by iterated Case 1-4 application + neg_until_equiv expansion, NOT by standalone Case 5-8 lemmas
2. Derive `no_U_nested_in_S_separable` via swap_temporal duality
3. Replace 8 axioms in SeparationThm.lean with theorems
4. Key new infrastructure: `abstract_snce` (~100 LOC), junction_depth decrease lemmas (~100 LOC)

**Secondary path** (backup, HIGH confidence, ~200-350 LOC per case):
- Specialize GHR94 Lemma 10.3.11 Dedekind formulas for Z by substituting K+=K-=T, G+-=bot
- Produces correct explicit Case 5 formula without density assumption
- More mechanical but higher LOC total across all 4 cases

**Immediate action** (both paths need):
- Implement `abstract_snce` (~100 LOC, dual of abstract_untl)
- Add `abstract_untl_identity_on_U_free` (~20 LOC, supports both approaches)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Cases 5-8 explicit formulas | completed | high | Confirmed no formulas exist; identified GHR94 hierarchy as correct path |
| B | Restricted subst_separable | completed | medium | Proved abstract_untl_preserves_separated correct; showed it insufficient alone |
| C | Critic / verification | completed | high | Identified snce case as trivial, all_past/all_future as real blocker; Phase 7 independence |
| D | Alternative proof strategies | completed | high | Found Dedekind formula specialization; confirmed neg_until_equiv as master key |

## References

- GHR94 Chapter 10.2-10.3 (literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md)
- Reynolds 1994 Section 6 (literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md)
- Previous reports: 01-03, 09-10 in specs/157_expressive_completeness_su_integer/reports/
- Phase 6 handoff: specs/157_expressive_completeness_su_integer/handoffs/phase-6-handoff-20260517.md
- Key Lean files: TemporalClosure.lean, SeparationThm.lean, Eliminations.lean, Hierarchy.lean, NormalForm.lean, Duality.lean, NegationEquiv.lean
