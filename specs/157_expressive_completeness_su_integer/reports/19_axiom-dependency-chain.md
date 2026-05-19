# Axiom Dependency Chain for `all_formulas_separable`

## 1. The 9 Axioms in SeparationThm.lean

**`is_separable` temporal closure (4 axioms):**
1. `all_past_separable` (line 89)
2. `all_future_separable` (line 93)
3. `untl_separable` (line 97)
4. `snce_separable` (line 101)

**`is_properly_separable` temporal closure (4 axioms):**
5. `all_past_properly_separable` (line 220)
6. `all_future_properly_separable` (line 225)
7. `untl_properly_separable` (line 230)
8. `snce_properly_separable` (line 236)

**Atom preservation (1 axiom):**
9. `proper_separation_preserves_atoms` (line 276)

## 2. lean_verify Results

| Theorem | Custom Axioms | Axiom-Free? |
|---------|--------------|-------------|
| `all_separable` (SeparationThm) | `snce_separable`, `untl_separable` | NO |
| `all_properly_separable` | `snce_properly_separable`, `untl_properly_separable` | NO |
| `all_formulas_separable` (Hierarchy) | `snce_separable`, `untl_separable` | NO |
| `all_formulas_separable_aux` | `snce_separable`, `untl_separable` | NO |
| `no_S_nested_in_U_separable_direct` | `snce_separable`, `untl_separable` | NO |
| `lemma_10_2_6_self_contained` | `snce_separable`, `untl_separable` | NO |
| `single_U_formula_separable_noax` | `snce_separable`, `untl_separable` | NO |
| `no_S_nested_in_U_separable_param` | (none) | YES |
| `no_S_nested_in_U_separable_param_jd` | (none) | YES |
| `subst_in_separated_separable` | (none) | YES |
| `subst_in_separated_separable_typed` | (none) | YES |
| `subst_in_separated_separable_depth` | (none) | YES |
| `snce_single_U_depth_one_separable` | (none) | YES |
| `single_U_formula_separable` (old) | `snce_separable` | NO |
| `multi_U_formula_separable` | `snce_separable`, `untl_separable` | NO |

**Key observation**: Only `snce_separable` and `untl_separable` propagate into Hierarchy.lean. The other 7 axioms are confined to SeparationThm.lean itself.

## 3. Complete Dependency Graph

```
all_formulas_separable
  └─ all_formulas_separable_aux
       ├─ [snce case] no_S_nested_in_U_separable_direct  ──────── AXIOM LEAK
       └─ [untl case] no_S_nested_in_U_separable_direct  ──────── AXIOM LEAK

no_S_nested_in_U_separable_direct
  ├─ [depth <= 1] lemma_10_2_6_self_contained  ─────────────────── AXIOM LEAK
  └─ [depth >= 2, non-U-free args] all_separable (line 2447)  ─── AXIOM LEAK (path A)

lemma_10_2_6_self_contained
  └─ subst_in_separated_separable_typed (CLEAN)
       └─ callback: single_U_formula_separable_noax  ──────────── AXIOM LEAK

single_U_formula_separable_noax
  ├─ [depth 0: U-free snce] direct (CLEAN)
  ├─ [depth 1] snce_single_U_depth_one_separable (CLEAN)
  └─ [depth >= 2] no_S_nested_in_U_separable_param + all_separable callback ── AXIOM LEAK (path B)
```

### The Two Axiom Leak Paths

**Path A** -- `no_S_nested_in_U_separable_direct` line 2447:
```
no_S_nested_in_U_separable_direct
  -> [depth >= 2, non-U-free extracted args]
  -> subst_in_separated_separable with callback (fun chi _ => all_separable chi)
```

**Path B** -- `single_U_formula_separable_noax` line 2172-2174:
```
single_U_formula_separable_noax
  -> [snce case, snce_depth_of_U >= 2]
  -> IH on children (CLEAN)
  -> box-normalize (CLEAN)
  -> no_S_nested_in_U_separable_param with callback (fun zeta _ => all_separable zeta)
```

## 4. Circular Dependency Analysis

**Is there a circular dependency?**

The call chain is:
```
all_formulas_separable_aux
  -> no_S_nested_in_U_separable_direct
       -> lemma_10_2_6_self_contained
            -> single_U_formula_separable_noax
                 -> [depth >= 2] no_S_nested_in_U_separable_param + all_separable
```

`all_separable` is defined in SeparationThm.lean, NOT in Hierarchy.lean. It depends on
the `snce_separable` and `untl_separable` axioms. It does NOT call back into
`all_formulas_separable_aux` or any Hierarchy.lean function.

**There is NO circular dependency in the call graph.** The chain terminates at the
SeparationThm axioms. The issue is linear: the Hierarchy.lean proof chain uses
`all_separable` (axiom-backed) as a fallback callback in two places, when ideally
it would use axiom-free alternatives.

## 5. Minimum Set of Changes

### Both Path A AND Path B must be fixed.

**Path A alone is NOT sufficient.** Even if `no_S_nested_in_U_separable_direct` is
fixed at line 2447, the dependency still flows through:
```
all_formulas_separable_aux -> no_S_nested_in_U_separable_direct
  -> lemma_10_2_6_self_contained -> single_U_formula_separable_noax
  -> [depth >= 2] all_separable  (PATH B)
```

**Path B alone is NOT sufficient.** Even if `single_U_formula_separable_noax` is
fixed, the dependency still flows through:
```
no_S_nested_in_U_separable_direct -> [depth >= 2, non-U-free args]
  -> all_separable  (PATH A)
```

### Required Changes (both needed):

**Change 1: Fix `single_U_formula_separable_noax` depth >= 2 case (line 2172-2174)**

Current code:
```lean
have h_sep : is_separable (.snce C'' F'') :=
  no_S_nested_in_U_separable_param (.snce C'' F'') hns
    (has_no_allpast_allfuture_true _) (fun ζ _hns_ζ =>
      all_separable ζ)
```

The callback `fun ζ _hns_ζ => all_separable ζ` is the leak. The callback formula
has `no_S_nested_in_U` and comes from back-substitution into separated formula
snce-branches. The question is: can we provide an axiom-free callback?

**Option**: Use `no_S_nested_in_U_separable_direct` as callback (if it were
axiom-free). But that creates a mutual dependency:
`single_U_formula_separable_noax` -> `no_S_nested_in_U_separable_direct` ->
`lemma_10_2_6_self_contained` -> `single_U_formula_separable_noax`. This IS
a circular dependency at the Lean level and would not compile.

**Better option**: The callback formulas at depth >= 2 have `no_S_nested_in_U` AND
the box-normalized snce node `.snce C'' F''` has `junction_depth <= 1` (by
`snce_of_boxfree_sep_jd_le_one`). Use `no_S_nested_in_U_separable_param_jd`
(which is axiom-free) with a callback that handles JD <= 1 formulas.
But the inner callback of `no_S_nested_in_U_separable_param_jd` requires
`junction_depth chi <= 1 -> is_separable chi`, which in turn needs... what?

Actually, the callback formulas from `subst_in_separated_separable_jd` have
JD <= 1. At JD = 0, formulas are directly separated. At JD = 1, we need
the full separation machinery again. This is where `all_formulas_separable_aux`
would need to be available -- but that would be circular.

**Key insight**: At depth >= 2 in `single_U_formula_separable_noax`, the IH
on children C, F produces separated C', F'. After box-normalizing to C'', F'',
we get `.snce C'' F''` with `no_S_nested_in_U` AND `U_nesting_depth <= 1`
(since C'', F'' are box-free separated, their U-args are S-free, and by
the has_single_U_type constraint, args are also U-free).

So `lemma_10_2_6_self_contained` could handle `.snce C'' F''` directly
(it requires `no_S_nested_in_U` and `U_nesting_depth <= 1`).

But `lemma_10_2_6_self_contained` calls `single_U_formula_separable_noax` --
creating a loop.

**Resolution**: The depth >= 2 case must establish that `.snce C'' F''`
has STRICTLY SMALLER `snce_depth_of_U` than the original `.snce C F`, allowing
the outer strong induction to handle it. Alternatively, the `lemma_10_2_6_self_contained`
call from within `single_U_formula_separable_noax` would need to be on a formula
with strictly smaller measure, which it is (U_nesting_depth <= 1 at the callback level).

**The fundamental fix**: Merge the induction schemes. Instead of separate theorems
calling each other, build a single well-founded induction on a combined measure
(e.g., `(junction_depth, U_nesting_depth, count_U_subformulas, snce_depth_of_U)`).

**Change 2: Fix `no_S_nested_in_U_separable_direct` non-U-free args case (line 2444-2447)**

Current code:
```lean
have h_subst_sep : is_separable (subst_formula psi p (.untl AB.1 AB.2)) :=
  subst_in_separated_separable psi p AB.1 AB.2
    hAB_sf.1 hAB_sf.2 hpsi_sep
    (fun χ hns_χ => all_separable χ)
```

This path is reached when `U_nesting_depth >= 2` AND the extracted U-type has
non-U-free args. The callback formula has `no_S_nested_in_U`. The fix would
use the outer `U_nesting_depth` IH: callback formulas from back-substitution
have `U_nesting_depth` bounded by the args of the extracted U-type, which are
strictly inside the original formula's U-nesting structure.

**However**, `subst_in_separated_separable` does not provide `U_nesting_depth`
bounds on its callback formulas. A variant `subst_in_separated_separable_depth`
exists but requires U-free A, B -- which is exactly the case this branch does NOT
have.

**The fix**: Create a new variant of `subst_in_separated_separable` that bounds
callback formula `U_nesting_depth` by `max(U_nesting_depth A, U_nesting_depth B) + 1`
(or similar), even when A, B are not U-free. Then the outer `ih_depth` can handle
the callback because `U_nesting_depth(callback) < U_nesting_depth(original)`.

## 6. Is There a Simpler Path?

**Observation**: The non-U-free args case at line 2432 can potentially be eliminated
entirely. If `extract_U_type` is modified to always find an INNERMOST U-type
(one with U-free args), then `is_U_free AB.1 = true` and `is_U_free AB.2 = true`
always hold, and the non-U-free branch is dead code.

At `U_nesting_depth >= 2`, the formula has nested U operators. The current
`extract_U_type` may return an outer U whose args contain inner U's. If instead
it recurses into U-args to find the innermost U (leaf in the U-nesting tree),
those args would be U-free by definition.

**This would eliminate Path A entirely**, leaving only Path B to fix.

## 7. Recommended Execution Order

### Phase 1: Eliminate Path A (no_S_nested_in_U_separable_direct)
1. Modify `extract_U_type` to always find innermost U-type (U-free args)
2. Prove `extract_U_type` returns U-free args unconditionally
3. Delete the `by_cases hAB_uf` branch split (lines 2432-2448)
4. Use `subst_in_separated_separable_depth` unconditionally (it requires U-free args)
5. The outer `ih_depth` handles callback formulas (U_nesting_depth <= 1 < d)

### Phase 2: Eliminate Path B (single_U_formula_separable_noax)
1. At depth >= 2, after IH on children produces separated C', F':
   - Box-normalize to C'', F''
   - `.snce C'' F''` has `no_S_nested_in_U` AND `U_nesting_depth <= 1`
   - Use `subst_in_separated_separable_depth` (requires U-free A, B -- YES, they are
     U-free by the `has_single_U_type` constraint with U-free A, B hypothesis)
   - Callback formulas have `U_nesting_depth <= 1`, handle via `lemma_10_2_6_self_contained`
   - BUT this creates `single_U_formula_separable_noax` -> `lemma_10_2_6_self_contained`
     -> `single_U_formula_separable_noax` loop
2. **Resolution**: Inline `lemma_10_2_6_self_contained` logic into
   `single_U_formula_separable_noax` depth >= 2, using the SAME induction variable
   (add `count_U_subformulas` as inner induction within the `snce_depth_of_U` outer
   induction). The callback invokes `single_U_formula_separable_noax` recursively
   at strictly smaller `snce_depth_of_U` (the box-normalized snce node has
   `snce_depth_of_U = 0` since C'', F'' are separated/box-free).

### Phase 3: Verify
- Run `lean_verify` on `all_formulas_separable` -- should show no custom axioms
- Run `lake build` to confirm everything compiles

### Estimated Difficulty
- Phase 1: Medium (modify `extract_U_type`, adjust proofs of its properties)
- Phase 2: Hard (restructure nested induction in `single_U_formula_separable_noax`)
- Phase 3: Trivial (verification only)

## 8. Summary

- **9 axioms** exist in SeparationThm.lean
- Only **2 axioms** (`snce_separable`, `untl_separable`) leak into Hierarchy.lean
- The leak occurs via **2 independent paths** (both must be fixed)
- **No circular dependency** exists in the current code
- Fixing Path A alone does NOT suffice; fixing Path B alone does NOT suffice
- The recommended approach: modify `extract_U_type` for Path A (simpler),
  then restructure the induction in `single_U_formula_separable_noax` for Path B (harder)
