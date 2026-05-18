# Analysis: Do Separated Formulas Contain all_past/all_future?

**Answer: YES — the hypothesis is FALSE.**

## Evidence

### 1. `is_syntactically_separated` allows `all_past`/`all_future`

`Defs.lean:148-149`:
```lean
| .all_past φ => is_U_free φ
| .all_future φ => is_S_free φ
```

A separated formula can contain `.all_past φ` (when φ is U-free) and `.all_future φ` (when φ is S-free).

### 2. Elimination cases explicitly construct `all_past`/`all_future`

- **Case 1** (`Eliminations.lean:372`): `psi_l` uses `.all_future (Formula.neg A)`
- **Case 2** (`Eliminations.lean:458,460`): constructs `.all_past (Formula.neg a)` in the separated witness
- **Case 2 variant** (`Eliminations.lean:515,517`): same

### 3. Consequence for the callback

The callback in `subst_in_separated_separable` receives `.snce c' d'` and `.all_past c'` where c, d came from a separated ψ. Since ψ can contain `all_past`/`all_future`, the callback formula does NOT necessarily have `has_no_allpast_allfuture`. Therefore `no_S_nested_in_U_separable_noax` (which requires `has_no_allpast_allfuture`) CANNOT be used directly as the callback.

### 4. Existing infrastructure

`subst_preserves_no_allpast_allfuture` (Hierarchy.lean:1167) IS proved but requires both ψ and r to satisfy the predicate. Since separated ψ fails this, it doesn't help.

### Implication

The circularity cannot be broken by assuming callback formulas lack `all_past`/`all_future`. The resolution must either:
- (a) Prove `no_S_nested_in_U_separable` WITHOUT the `has_no_allpast_allfuture` precondition, or
- (b) Refactor `is_syntactically_separated` to disallow `all_past`/`all_future`, then update Cases 1-4 to use S/U expansions instead
