# Phase 4 Handoff: Junction-Depth Hierarchy

## Session
- Session ID: sess_1779084016_ff70c0
- Timestamp: 2026-05-18T08:30:00Z

## Current State

### Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (736 lines, compiles clean)
  - Phase 1 complete: K+/K-/Gamma triviality, Q-lemma (axiom-free)
  - case3_equiv_Z_general complete (axiom-free)
  - Cases 5-8: all_separable bootstrap (will be replaced by hierarchy)

### Build Status
- `lake build` passes with zero errors
- No sorries in DedekindZ.lean
- Existing axioms in SeparationThm.lean unchanged

### Key Discovery
The Round 3 approach (snce_event_eval_pos/neg + replace_untl_with_top) was UNSOUND:
- `replace_untl_with_top_correct` is false when the formula contains temporal operators
  evaluating U(A,B) at different time points (e.g., S(a^U,q) inside the event formula)
- All Cases 5-8 "non-circular" proofs from Round 3 were reverted to bootstrap
- The correct path is: prove hierarchy first, then replace all_separable everywhere

## What Needs to Be Done: Phase 4

### Task 4.2: `no_S_nested_in_U_separable` (~150 LOC)

**Location**: Hierarchy.lean, after line 1054

**Signature**:
```lean
theorem no_S_nested_in_U_separable (phi : Formula)
    (hexp : has_no_allpast_allfuture phi = true)
    (h : no_S_nested_in_U phi) :
    is_separable phi
```

**Strategy**: Induction on U_depth_under_S phi.
- Base (depth 0): formula is U-free -> syntactically separated -> separable
- Step (depth n+1): Find a U(A,B) node. Abstract it to atom p using abstract_untl.
  The abstracted formula has lower U_depth_under_S. By IH, it's separable:
  exists psi (syntactically separated) with int_equiv (abstract_untl phi A B p) psi.
  Need: subst_formula psi p (.untl A B) is syntactically separated.
  Then: int_equiv phi (subst_formula psi p (.untl A B)) by composing abstract_untl_equiv.

**MISSING LEMMA**: `subst_formula_preserves_separated`
```lean
theorem subst_formula_preserves_separated (psi : Formula) (p : Atom) (A B : Formula)
    (hsep : is_syntactically_separated psi = true)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true) :
    is_syntactically_separated (subst_formula psi p (.untl A B)) = true
```
Proof: By induction on psi. At atom p: subst gives .untl A B, which is separated
when A, B are S-free. At other atoms: identity. At imp: recurse. At untl: the args
are S-free (from separated); substituting into S-free formula doesn't introduce snce
(atom p can't be inside untl args in a separated formula because untl args are S-free,
and p is just an atom).

**ALSO MISSING**: `abstract_untl_decreases_U_depth_under_S` -- showing that abstracting
a U node strictly decreases U_depth_under_S when no_S_nested_in_U holds.

**ALSO MISSING**: `subst_formula_correct` -- semantic correctness of substitution:
```lean
theorem subst_formula_correct (phi : Formula) (p : Atom) (repl : Formula) :
    ∀ M : IntStructure, ∀ t : ℤ,
    int_truth M t (subst_formula phi p repl) ↔
    int_truth (subst_model M p repl) t phi
```
Or similar. This may already exist -- check `abstract_untl_correct`.

### Task 4.3: `junction_depth_separable_aux` (~200 LOC)

**Signature**:
```lean
theorem junction_depth_separable_aux (phi : Formula)
    (hexp : has_no_allpast_allfuture phi = true) :
    is_separable phi
```

**Strategy**: Strong induction on junction_depth phi.
- Base (jd 0): expanded_jd_zero_imp_separated -> separable
- Step (jd n+1):
  - If no_S_nested_in_U: use no_S_nested_in_U_separable (Task 4.2)
  - If S nested in U: find snce node inside untl argument. Use abstract_snce to
    replace it with fresh atom. Junction_depth strictly decreases
    (abstract_snce_inside_untl_jd_lt exists). Apply IH. Substitute back.
  - If U nested in S: symmetric, use abstract_untl.

**KEY**: This does NOT use Cases 5-8 or any temporal closure axioms.

### Task 4.4: `all_formulas_separable` (~15 LOC)

Compose: expand_temporal_equiv + junction_depth_separable_aux + is_separable_of_equiv.

### Task 4.5: Wire multi_U_formula_separable (~5 LOC)

Replace `all_separable phi` with `all_formulas_separable phi`.

## Existing Infrastructure in Hierarchy.lean (1054 lines)

Available tools:
- abstract_untl + abstract_untl_correct, abstract_untl_equiv
- abstract_untl_preserves_S_free, abstract_untl_preserves_no_S_nested
- abstract_untl_makes_U_free, abstract_untl_count_le
- abstract_snce + abstract_snce_correct
- abstract_snce_preserves_U_free, abstract_snce_preserves_S_free
- abstract_snce_preserves_no_U_nested, abstract_snce_makes_S_free
- junction_depth / junction_depth_U / junction_depth_S bounds
- abstract_snce_inside_untl_jd_lt (junction_depth strictly decreases)
- single_U_formula_separable (uses axioms - needs replacement)
- multi_U_formula_separable (uses all_separable - needs replacement)
- untl_s_free_separable (axiom-free!)
- expanded_jd_zero_imp_separated (in TemporalClosure.lean)
- separated_imp_separable (in NormalForm.lean)

Missing tools:
- subst_formula_preserves_separated
- abstract_untl_decreases_U_depth_under_S (for no_S_nested case)
- The actual hierarchy induction proofs

## Priority Order
1. Task 4.2 (no_S_nested_in_U_separable) - depends on subst_formula_preserves_separated
2. Task 4.3 (junction_depth_separable_aux) - depends on Task 4.2
3. Task 4.4 (all_formulas_separable) - wrapper
4. Task 4.5 (wire multi_U) - mechanical
5. Phase 5 (replace axioms) - uses all_formulas_separable
6. Update Cases 5-8 to use all_formulas_separable instead of all_separable
