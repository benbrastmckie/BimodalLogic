# Teammate B Findings: Alternative Approaches -- Duality and Encoding Strategies

## Key Findings

### 1. Duality as Proof Halver: Strong Infrastructure, Incomplete for DualEliminations

**Result**: The duality infrastructure is COMPLETE and PROVEN for the "separable implies swap is separable" direction. However, it CANNOT directly prove the DualEliminations.lean sorries.

**Evidence**:

`Duality.lean` provides a fully proven toolkit:
- `swap_temporal_int_truth`: Truth of swap(phi) in M at t iff truth of phi in M.reverse at -t (lines 52-124)
- `dual_equiv`: If phi equiv psi, then swap(phi) equiv swap(psi) (line 129)
- `dual_U_free_iff_S_free`: is_U_free(swap phi) = is_S_free(phi) (line 141)
- `dual_S_free_iff_U_free`: is_S_free(swap phi) = is_U_free(phi) (line 154)
- `dual_separated`: is_syntactically_separated(swap phi) = is_syntactically_separated(phi) (line 167)
- `dual_separable`: is_separable phi implies is_separable swap(phi) (line 189)

**The gap**: DualEliminations.lean requires proving `is_S_free psi = true` (an S-FREE equivalent), not merely `is_syntactically_separated psi = true` (a SEPARATED equivalent). The duality approach gives:
1. Start with `elim_case_N` (primary case): proves `exists psi, int_equiv (snce ...) psi AND is_syntactically_separated psi`
2. swap gives: `exists psi', int_equiv (untl ...) psi' AND is_syntactically_separated psi'`

But `is_syntactically_separated` is NOT `is_S_free`. A separated formula may contain BOTH snce and untl at top level. The DualEliminations need `is_S_free` -- the formula must have NO snce at all.

**Workaround identified**: The dual eliminations could be proved if we had a stronger primary case result: "the separated equivalent is actually U-free" (not just separated). For Cases 1-4, examining the explicit `case1_psi` formula (lines 69-73 of Eliminations.lean):
```lean
Formula.or (Formula.or
  (Formula.and (Formula.and (Formula.and (.snce a q) (.snce a B)) B) (.untl A B))
  (Formula.and (Formula.and A (.snce a B)) (.snce a q)))
  (.snce (Formula.and (Formula.and (Formula.and A q) (.snce a B)) (.snce a q)) q)
```
This formula contains BOTH snce and untl -- it is NOT U-free. So swapping it gives a formula that is NOT S-free. This confirms the impossibility of the naive duality approach for DualEliminations.

**Conclusion**: DualEliminations.lean is dead code (as noted in the plan's non-goals). The duality infrastructure is valuable but for a DIFFERENT purpose: halving the temporal closure proof. Specifically, `untl_separable` can be derived from `snce_separable` via duality (or vice versa), and `all_future_separable` from `all_past_separable`.

### 2. swap_temporal Preserves junction_depth

**Result**: By inspection of the definitions, `swap_temporal` swaps `untl <-> snce` and `all_past <-> all_future`, while the `junction_depth` mutually recursive definition treats `snce` children via `junction_depth_S` and `untl` children via `junction_depth_U` (with +1 crossover at the alternation point). Under swap, the roles of `junction_depth_U` and `junction_depth_S` exchange, but the overall `junction_depth` is preserved.

This means: if we prove `snce_separable` for formulas with junction_depth <= k, we automatically get `untl_separable` for junction_depth <= k via `swap_temporal`. This genuinely HALVES the Phase 6 proof burden.

**Specific mechanism**:
```
junction_depth (.snce phi psi) = max (junction_depth_S phi) (junction_depth_S psi)
junction_depth (.untl phi psi) = max (junction_depth_U phi) (junction_depth_U psi)
```
After swap: `.snce phi psi` becomes `.untl (swap phi) (swap psi)`, and the junction_depth_U/S roles flip. The overall max remains the same.

### 3. G/H Encoding as Derived Operators: NOT Directly Useful

**Result**: While it is semantically true that `H(phi) <-> neg S(neg phi, top)` over integer time (provable via `since_top_is_past` in IntHelpers.lean + negation), this equivalence does NOT solve the base case problem for temporal closure.

**Analysis**: The base case issue is:
- `all_past(phi')` where phi' is syntactically separated (may contain untl)
- We need to show `all_past(phi')` is separable
- If phi' has untl subterms, then `all_past(phi')` is NOT syntactically separated (is_syntactically_separated requires is_U_free under all_past)

Encoding `all_past(phi')` as `neg(snce(neg phi', top))`:
- This gives a `neg(snce(...))` formula, which is syntactically just `imp (snce (neg phi') (imp bot bot)) bot`
- To show this is separable, we still need to show `snce(neg phi', top)` is separable
- Since neg phi' may contain untl, this is exactly the `snce_separable` problem again

So the encoding doesn't break any circularity -- it just re-routes `all_past_separable` through `snce_separable` (which is already how the axiom-based proof works). The encoding is a notational convenience, not a proof shortcut.

**However**, the encoding IS useful for understanding why the proper separation axioms `all_past_properly_separable` etc. can be derived from `snce_properly_separable` + `untl_properly_separable`. This suggests the 8 proper separability axioms could be reduced to 2.

### 4. Non-Constructive Existence for Phase 7: Viable but Complex

**Result**: The Phase 7 quantifier case cannot be solved non-constructively because the goal type `is_separable` already IS an existential proposition (`exists psi, ...`). The problem is constructing the separated formula, not proving its existence abstractly. `Classical.choice` doesn't help because we need a specific `Formula` value.

However, there IS a viable non-constructive element: the case-split over `Fintype (sig.preds -> Bool)` can use `Fintype.choose` or similar to select the matching branch. The mathematical argument is:
- For each sigma : sig.preds -> Bool, construct a candidate formula
- Prove exactly one sigma matches the model at time t
- The disjunction of all candidates (guarded by their sigma-match) gives the result

This is fully constructive in the temporal formula sense (we build an explicit Formula), but uses `Classical.em` for the case analysis over finitely many booleans. This is fine for Lean's `Prop`-level.

### 5. Composition Approach for Phase 7: Partially Viable

**Result**: If `all_separable` is available (with axioms), we already KNOW the separated formula exists for any input. The Phase 7 challenge is different: it's about connecting the first-order translation back to temporal formulas, not about proving separability per se.

The composition insight: if `phi : MonadicFormula sig 1` and `env = [t]`:
1. By IH at `extSignature` with quantifier depth decreased: get temporal formula B equivalent to reduceElimLast
2. By `all_properly_separable`: get properly separated B' equivalent to B
3. By proper separation structure: B' is a boolean combination of past-only (under snce/all_past) and future-only (under untl/all_future) parts
4. Substitute extended atoms back: in past-only parts, lt_ref = True, gt_ref = False; in future-only parts, lt_ref = False, gt_ref = True; at present, both False
5. For const_at_ref: iterate over all sigma and form the guarded disjunction

The key insight from the existing code: `past_only_subst_correct` and `future_only_subst_correct` are already proved. The remaining work is purely mechanical: (a) the case-split assembly, (b) the level-aware substitution function, (c) the assembly into a single Formula.

## Recommended Approach

### For Phase 6: Duality-Halved Junction-Depth Induction

The BEST approach for Phase 6 combines:

1. **Prove only `snce_separable` + `all_past_separable` directly** (the "S-direction")
2. **Derive `untl_separable` + `all_future_separable` via swap_temporal** (the "U-direction" for free)

This halves the proof burden from 4 temporal closure proofs to 2.

**Specific mechanism for `untl_separable`**:
```lean
theorem untl_separable_from_dual (phi psi : Formula) 
    (h1 : is_separable phi) (h2 : is_separable psi) :
    is_separable (.untl phi psi) := by
  -- swap(untl phi psi) = snce (swap phi) (swap psi)
  -- swap preserves separability (dual_separable)
  have hs1 := dual_separable phi h1  -- is_separable (swap phi)
  have hs2 := dual_separable psi h2  -- is_separable (swap psi)
  -- Apply snce_separable to the swapped versions
  have hsnce := snce_separable (phi.swap_temporal) (psi.swap_temporal) hs1 hs2
  -- hsnce : is_separable (.snce (swap phi) (swap psi))
  -- But .snce (swap phi) (swap psi) = swap (.untl phi psi)
  -- So swap(swap(untl phi psi)) = untl phi psi is separable
  -- Use dual_separable on hsnce + involution
  have hswap : is_separable (.untl phi psi).swap_temporal := hsnce
  exact dual_separable _ hswap  -- swap of separable is separable, and swap(swap) = id
```

Wait -- this has a subtlety: `dual_separable` proves `is_separable (swap phi)` from `is_separable phi`. We need the reverse: from `is_separable (swap(untl phi psi))` conclude `is_separable (untl phi psi)`. But `swap(untl phi psi) = snce (swap phi) (swap psi)`, and after proving that's separable, we need `is_separable (swap(snce (swap phi) (swap psi)))` = `is_separable (untl phi psi)`. This works because `dual_separable` applied to the snce result gives separability of `swap(snce ...) = untl (swap(swap phi)) (swap(swap psi)) = untl phi psi` by involution.

So the chain is:
```
snce_separable(swap phi, swap psi) --> is_separable(.snce (swap phi) (swap psi))
dual_separable --> is_separable(swap(.snce (swap phi) (swap psi)))
                 = is_separable(.untl (swap(swap phi)) (swap(swap psi)))
                 = is_separable(.untl phi psi)  [by involution]
```

This WORKS. Similarly `all_future_separable` from `all_past_separable` using swap.

### For Phase 6 Core: Well-Founded on (has_nesting, junction_depth)

The remaining core of Phase 6 is proving `snce_separable` and `all_past_separable` without axioms. The approach:

1. Use a well-founded measure: lexicographic `(junction_depth, formula_size)` on the properly separated witness
2. Given separated phi', psi' (witnesses from `is_separable phi`, `is_separable psi`):
   - Box-normalize to get phi'', psi'' (still separated, now satisfy no_S_nested_in_U)
   - Form `.snce phi'' psi''` -- this has no_S_nested_in_U (already proved in TemporalClosure.lean)
   - Need: `no_S_nested_in_U psi --> is_separable psi` (the key lemma)
3. For `no_S_nested_in_U psi --> is_separable psi`:
   - If psi is U-free: need to show it's separable. For `all_future(snce p q)`: this requires proving the S-under-G case is separable, which needs the DUAL (U-under-H) to already be proved. This is where the mutual recursion lives.
   - The resolution: use junction_depth induction. `snce(phi'', psi'')` with separated phi'', psi'' has junction_depth <= 1 (proved: `snce_of_boxfree_sep_jd_le_one`). So we only need the base case at junction_depth 0 and the step from 0 to 1.

### For Phase 7: Case-Split Assembly with Existing Infrastructure

The recommended approach follows the plan's item (e) -- case-split over `Fintype (sig.preds -> Bool)`. Key observations:
- `past_only_subst_correct` and `future_only_subst_correct` handle lt_ref/gt_ref
- The const_at_ref case requires the sigma-guarded disjunction
- This is ~500 LOC of mechanical formalization work with no mathematical gaps

## Evidence/Examples

### Duality Proof Chain (Working)
From `Duality.lean` line 189-194:
```lean
theorem dual_separable (phi : Formula) (h : is_separable phi) :
    is_separable phi.swap_temporal := by
  obtain ⟨psi, hsep, hequiv⟩ := h
  refine ⟨psi.swap_temporal, ?_, dual_equiv phi psi hequiv⟩
  rw [dual_separated]
  exact hsep
```

### Junction Depth Bound (Critical for Phase 6)
From `TemporalClosure.lean` line 515-518:
```lean
theorem snce_of_boxfree_sep_jd_le_one (phi psi : Formula)
    (h1 : is_syntactically_separated phi = true)
    (h2 : is_syntactically_separated psi = true) :
    junction_depth (.snce (replace_box_with_top phi) (replace_box_with_top psi)) ≤ 1
```

### swap_temporal Involution (Enables Duality Halving)
From `Formula.lean` line 438:
```lean
theorem swap_temporal_involution (phi : Formula) :
  phi.swap_temporal.swap_temporal = phi
```

### DualEliminations Gap Analysis (Blocking Factor)
From `DualEliminations.lean` lines 58-67 (Case 1 Dual comment):
```
-- is_S_free(swap(psi')) = is_U_free(psi').
-- We'd need psi' to be U-free, but psi' is only guaranteed
-- to be separated (may have U at top level).
-- So this approach gives separated but not S-free.
```

## Confidence Level

**Phase 6 (Duality as proof halver)**: HIGH confidence (90%). The infrastructure is fully proven, the mechanism is sound, and it genuinely halves the work. The remaining challenge is the mutual induction core (snce_separable at junction_depth <= 1), which is bounded and well-understood.

**Phase 6 (Full axiom elimination)**: MEDIUM confidence (55%). The junction_depth <= 1 bound is proven, and the strategy is mathematically correct. But the formalization effort is still estimated at 600-800 LOC of complex mutual induction proof, with risk of unexpected Lean 4 termination/well-foundedness issues.

**Phase 7 (Case-split approach)**: HIGH confidence (85%). The mathematical argument is fully understood, infrastructure is in place (subst_correct, purity lemmas), and the gap is purely mechanical. No conceptual blockers remain.

**DualEliminations.lean (S-free via duality)**: LOW confidence (15%). Cannot be proved without either (a) proving a STRONGER primary case that gives U-free witnesses, or (b) proving them directly using the same techniques as the primary cases but with U/S roles swapped. The plan correctly identifies this as dead code.
