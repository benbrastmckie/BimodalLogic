# Phase 3 Handoff: Task 202

## Session
sess_1780325631_z4lda

## Current State
Phase 3 is PARTIAL. Substantial infrastructure has been built inside `gap_prior_UZ_contradiction`:

### Completed Infrastructure (all sorry-free, compiling)
1. **Surgery model N**: `classA` subtype + `N : OrderedMonadicStructure sig` defined
2. **Class convexity**: `class_convex` proved -- if `a ~M x` and `a ~M z` and `x <= y <= z` then `a ~M y`
3. **Succ/pred closure in N**: `h_N_succ`, `h_N_pred` proved
4. **NoMax/NoMin for N**: `h_N_no_max`, `h_N_no_min` proved
5. **Single class in N**: `h_N_one_class` -- all points in N are contemp_equiv_M
6. **Very good subintervals**: `h_N_very_good` -- all M-subintervals within class(a) are good

### Remaining Work (two sorry sites)

#### Sorry 1: Class Spread (Reynolds Lemma 9.1)
```lean
have class_spread : ∀ (A : Formula) (s : M.carrier),
    temporal_truth M atomMap s A →
    ∀ (t : M.carrier), ∃ (t' : M.carrier),
      contemp_equiv sig k M t t' ∧ temporal_truth M atomMap t' A := by
  sorry
```

**Approach**: Construct MonadicFormula sig 1 encoding "∃ y ~M x, A(y)" and apply `invariant_formula_constant`.

**Blocker**: Encoding `contemp_equiv(x, y)` as a MonadicFormula sig 2. The formula is:
```
∀ a b, (x ≤ a ∨ y ≤ a) → a ≤ b → (b ≤ x ∨ b ≤ y) → good(a, b)
```
where `good(a, b)` uses `good_formula_relativized`. The main difficulty is De Bruijn index manipulation -- `good_formula_relativized` has `var 0 = lo, var 1 = hi`, but in the ∀a∀b context `var 0 = b, var 1 = a`. A variable swap is needed.

**Recommended approach**: Use the "existential rebinding" trick:
```
∃ hi, ∃ lo, lo = a ∧ hi = b ∧ good_rel(lo, hi)
```
After binding in order `∃ hi ∃ lo` (sig 4 → sig 6):
- var 0 = lo, var 1 = hi, var 2 = b, var 3 = a, var 4 = x, var 5 = y
- good_formula_relativized lifted to sig 6 has var 0 = lo, var 1 = hi (correct order!)
- lo = a: `leq(0, 3) ∧ leq(3, 0)`
- hi = b: `leq(1, 2) ∧ leq(2, 1)`

Once `good_swapped : MonadicFormula sig 4` is constructed with correctness proof, build:
1. `contemp_eq_formula : MonadicFormula sig 2` using `good_swapped` inside `∀a∀b` with two conjuncts for x≤y and y≤x cases
2. `spread_formula : MonadicFormula sig 1` = `.ex (.and contemp_eq_body (table sig atomMap A).lift 1)`
3. Prove spread_formula is contemp_equiv-invariant (semantic argument, not formula-level)
4. Apply `invariant_formula_constant` to get constant, derive contradiction

**Estimated**: ~80-120 lines

#### Sorry 2: Truth Preservation + Final Contradiction
```lean
-- Truth preservation: ∀ A t∈I, temporal_truth M t A ↔ temporal_truth N t_N A
-- Uses class_spread for Until forward case (s ∉ I)
-- Final: R true in N (truth pres) but right_gap_class_formula false on N → contradiction
sorry
```

**Approach**: Structural induction on Formula. Cases:
- atom/bot/imp/box: immediate (predicates inherited)
- Until forward (s ∈ I): convexity + IH
- Until forward (s ∉ I): class_spread gives φ at some s' ∈ I, ψ at all r ∈ I between t and s'
- Until backward: all witnesses in I ⊂ M, convexity
- Since: dual

Then: truth_pres gives N ⊨ R(t). gap_formula_R_correct on N gives right_gap_class_formula_N(t). But N is very_good (all subintervals good), so right_gap_class_formula is False on N. Contradiction.

**Key requirement**: N must be shown to be a Prior structure (for gap_formula_R_correct).
- Prior-UZ on N: any counterexample in N transfers to M via truth_pres (backward), contradicting h_prior_UZ.
- Prior-SZ on N: similarly.

**Estimated**: ~100-150 lines

## Key Decisions Made
1. N = single class restriction (not orderedSum, not Z+Z)
2. Class spread via MonadicFormula encoding + invariant_formula_constant (not EF games)
3. Truth preservation by structural induction (not semantic k-equiv argument)
4. "Existential rebinding" trick for variable swap in MonadicFormula construction

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
  - Lines ~1154-1310: New infrastructure inside gap_prior_UZ_contradiction
  - Two sorry sites remaining (class_spread and truth_pres+contradiction)

## Next Action
Implement class spread: construct `good_swapped`, `contemp_eq_formula`, `spread_formula`, prove class_spread. Then implement truth preservation and final contradiction.
