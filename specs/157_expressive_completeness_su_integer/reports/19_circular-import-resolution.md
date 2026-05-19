# Research Report: Circular Import Resolution Between Hierarchy.lean and SeparationThm.lean

**Task**: 157 -- Expressive Completeness of {S,U} over Integer Time
**Focus**: Phase 5 circular import resolution
**Date**: 2026-05-19

---

## 1. Full Import Graph of the Separation Module

### Direct Imports

```
Defs.lean          <- (leaf: imports Formula, Mathlib Int)
IntHelpers.lean    <- Defs
FormulaOps.lean    <- Defs
Distributivity.lean <- Defs
Duality.lean       <- Defs
NegationEquiv.lean <- Defs, Duality, IntHelpers
Eliminations.lean  <- Defs, NegationEquiv, Distributivity, IntHelpers
TemporalClosure.lean <- Defs, Duality
DedekindZ.lean     <- Defs, Eliminations, NegationEquiv, SeparationThm
NormalForm.lean    <- Eliminations, Distributivity, SeparationThm, DedekindZ
DualEliminations.lean <- Eliminations, Duality, SeparationThm
SeparationThm.lean <- Defs, Eliminations, FormulaOps, Distributivity, Duality
Hierarchy.lean     <- NormalForm, SeparationThm, TemporalClosure, DedekindZ
```

### The Circular Dependency

```
Hierarchy.lean --imports--> SeparationThm.lean
    (uses: snce_separable, all_separable)

SeparationThm.lean --CANNOT import--> Hierarchy.lean
    (would create: SeparationThm -> Hierarchy -> SeparationThm cycle)
```

Phase 5 needs SeparationThm.lean to import Hierarchy.lean (to replace axioms with theorems using `all_formulas_separable`). This requires first removing Hierarchy.lean's import of SeparationThm.lean.

---

## 2. Every Use of SeparationThm Declarations in Hierarchy.lean

### Uses of `snce_separable` (axiom from SeparationThm.lean)

| Line | Context | Code |
|------|---------|------|
| 187 | `single_U_formula_separable` snce case | `exact snce_separable psi1 psi2 (ih1 h_single.1) (ih2 h_single.2)` |
| 212 | `snce_single_U_top_level_separable` | `exact snce_separable C F (single_U_formula_separable ...) (single_U_formula_separable ...)` |

### Uses of `all_separable` (theorem in SeparationThm.lean, depends on axioms)

| Line | Context | Code |
|------|---------|------|
| 764 | `multi_U_formula_separable` body | `all_separable phi` |
| 2066 | `no_S_nested_in_U_separable_noax` body | `no_S_nested_in_U_separable_param phi hns hexp (fun chi _ => all_separable chi)` |
| 2174 | `single_U_formula_separable_noax` depth >= 2 case | `all_separable zeta` (as callback to `no_S_nested_in_U_separable_param`) |
| 2447 | `no_S_nested_in_U_separable_direct` non-U-free args else branch | `all_separable chi` (as callback to `subst_in_separated_separable`) |

### Summary: 6 code sites total (2 `snce_separable` + 4 `all_separable`)

---

## 3. Which Uses Can Be Eliminated and How

### Category A: Dead Code (can be deleted entirely)

These theorems are not called by any other code (verified via grep):

1. **`single_U_formula_separable`** (line 170) -- Uses `snce_separable` at line 187. Superseded by `single_U_formula_separable_noax` (line 2120). Dead code.

2. **`snce_single_U_top_level_separable`** (line 204) -- Uses `snce_separable` at line 212. Not referenced anywhere. Dead code.

3. **`single_U_neg_separable`** (line 223), **`single_U_disj_separable`** (line 229), **`single_U_conj_separable`** (line 239) -- Use `single_U_formula_separable`. Not referenced. Dead code.

4. **`multi_U_formula_separable`** (line 762) -- Uses `all_separable` at line 764. Referenced only by `two_U_types_separable` (line 768) and its own corollaries, none of which are used downstream. Dead code chain.

5. **`no_S_nested_in_U_separable_noax`** (line 2062) -- Uses `all_separable` at line 2066. Not referenced anywhere. Dead code.

**Eliminating Category A removes 4 of the 6 code sites.**

### Category B: Live Code Requiring Rewrite

6. **`single_U_formula_separable_noax`** (line 2120, `all_separable` at line 2174) -- Called by `lemma_10_2_6_self_contained` (line 2232). This is on the critical path. The depth >= 2 snce case uses `all_separable` as a callback to `no_S_nested_in_U_separable_param`. **Resolution**: Replace `all_separable zeta` with `no_S_nested_in_U_separable_direct (.snce C'' F'') hns` -- but this creates a mutual dependency since `no_S_nested_in_U_separable_direct` calls `lemma_10_2_6_self_contained` which calls `single_U_formula_separable_noax`. See Section 4 for analysis.

7. **`no_S_nested_in_U_separable_direct`** (line 2386, `all_separable` at line 2447) -- Called by `all_formulas_separable_aux` (lines 2649, 2675). Critical path. The non-U-free args else branch uses `all_separable`. **Resolution**: This is the main rewrite target of Phase 4 Task 4.2. See Section 5.

---

## 4. Can We Avoid Creating a New File?

**YES. No new file is needed.** The resolution is to remove the SeparationThm import from Hierarchy.lean by eliminating all uses of its declarations.

### Strategy: Remove SeparationThm Import from Hierarchy.lean

**Step 1**: Delete dead code (Category A above). This removes 4 of 6 code sites.

**Step 2**: Fix `single_U_formula_separable_noax` depth >= 2 case (line 2174). The current code:
```lean
have h_sep : is_separable (.snce C'' F'') :=
  no_S_nested_in_U_separable_param (.snce C'' F'') hns
    (has_no_allpast_allfuture_true _) (fun zeta _hns_zeta =>
      all_separable zeta)
```
Replace with:
```lean
have h_sep : is_separable (.snce C'' F'') :=
  no_S_nested_in_U_separable_direct (.snce C'' F'') hns
```
This works because `no_S_nested_in_U_separable_direct` takes any formula with `no_S_nested_in_U` and proves it separable -- it is strictly more general than the callback pattern. The call is NOT circular because `no_S_nested_in_U_separable_direct` is defined AFTER `single_U_formula_separable_noax` in the same file, and `single_U_formula_separable_noax` will call `no_S_nested_in_U_separable_direct` only after `no_S_nested_in_U_separable_direct` itself is defined.

**WAIT -- there IS a problem**: `no_S_nested_in_U_separable_direct` is defined at line 2386, which is AFTER `single_U_formula_separable_noax` at line 2120. Lean 4 requires forward references to be handled via mutual blocks. `single_U_formula_separable_noax` cannot call `no_S_nested_in_U_separable_direct` unless reordered or placed in a `mutual` block.

**However**, `no_S_nested_in_U_separable_direct` calls `lemma_10_2_6_self_contained` (line 2398), which calls `single_U_formula_separable_noax`. So there IS a genuine mutual dependency:
```
single_U_formula_separable_noax (depth >= 2) -> needs a "separability oracle"
lemma_10_2_6_self_contained -> calls single_U_formula_separable_noax
no_S_nested_in_U_separable_direct -> calls lemma_10_2_6_self_contained
all_formulas_separable_aux -> calls no_S_nested_in_U_separable_direct
```

**Resolution for the mutual dependency**: The depth >= 2 case of `single_U_formula_separable_noax` does the following:
1. IH on children C, F (by `snce_depth_of_U` induction -- strictly smaller)
2. Gets separated C', F'
3. Box-normalizes to C'', F''
4. Observes `.snce C'' F''` has `no_S_nested_in_U`
5. Needs to prove `.snce C'' F''` is separable

The callback at step 5 currently uses `all_separable`. The key insight: `.snce C'' F''` has `no_S_nested_in_U`, and after box-normalization, it has `has_no_allpast_allfuture`. So `no_S_nested_in_U_separable_param` with a suitable callback would work. But we need a callback that does not use `all_separable`.

**BEST APPROACH**: Instead of trying to call `no_S_nested_in_U_separable_direct` from `single_U_formula_separable_noax`, restructure by making `single_U_formula_separable_noax` ALSO take a callback parameter:
```lean
theorem single_U_formula_separable_param (phi A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
    (h_single : has_single_U_type phi A B)
    (oracle : forall chi, no_S_nested_in_U chi -> is_separable chi) :
    is_separable phi
```
Then `lemma_10_2_6_self_contained` takes the same callback and passes it through. Then `no_S_nested_in_U_separable_direct` passes itself (or its IH) as the callback.

**EVEN SIMPLER**: Since `no_S_nested_in_U_separable_direct` already has a well-founded structure (strong induction on `U_nesting_depth`), and the problematic call in `single_U_formula_separable_noax` at depth >= 2 produces a formula with `no_S_nested_in_U`, the callback formulas at that site could be handled by the OUTER induction of `no_S_nested_in_U_separable_direct` directly -- IF we inline `single_U_formula_separable_noax` and `lemma_10_2_6_self_contained` into the body of `no_S_nested_in_U_separable_direct` as nested inductions.

**SIMPLEST APPROACH**: Rewrite `no_S_nested_in_U_separable_direct` so its depth >= 2 case does NOT call `lemma_10_2_6_self_contained`. Instead, it uses the same inner `count_U_subformulas` induction at ALL depths (not just depth >= 2). Then `single_U_formula_separable_noax` becomes dead code too. The current structure at line 2397-2398 already has this pattern: depth <= 1 delegates to `lemma_10_2_6_self_contained`, depth >= 2 uses its own inner count induction. If the depth >= 2 inner count induction's back-substitution step (line 2432) is fixed to NOT need `all_separable`, the whole chain is axiom-free.

**Step 3**: Fix `no_S_nested_in_U_separable_direct` non-U-free args branch (line 2441-2447). See Section 6.

**Step 4**: Once all `all_separable`/`snce_separable` references are removed from code, delete the import line.

**Step 5**: SeparationThm.lean adds `import Hierarchy` and replaces axioms with theorems.

---

## 5. Proposed Resolution with Minimum Code Changes

### Phase 5 Task 5.2: The Import Reversal

**Minimum change sequence**:

1. **Delete dead code** (~10 theorems, ~100 lines):
   - `single_U_formula_separable` (line 170-187)
   - `snce_single_U_top_level_separable` (line 204-214)
   - `single_U_neg_separable` (line 223-227)
   - `single_U_disj_separable` (line 229-236)
   - `single_U_conj_separable` (line 239-245)
   - `multi_U_formula_separable` (line 762-764)
   - `two_U_types_separable` (line 768-770)
   - `multi_U_neg_separable` (line 778-780)
   - `multi_U_or_separable` (line 784-786)
   - `multi_U_and_separable` (line 790-792)
   - `no_S_nested_in_U_separable_noax` (line 2062-2066)

2. **Fix `single_U_formula_separable_noax` depth >= 2** (line 2171-2174): Replace `all_separable zeta` callback with a parameterized callback. Two options:

   **Option A** (thread callback): Change `single_U_formula_separable_noax` to accept a callback parameter `(oracle : forall chi, no_S_nested_in_U chi -> is_separable chi)` and pass it through. Then `lemma_10_2_6_self_contained` also takes the callback. Then `no_S_nested_in_U_separable_direct` supplies its own IH as the callback.

   **Option B** (restructure no_S_nested_in_U_separable_direct): Rewrite `no_S_nested_in_U_separable_direct` to handle the depth <= 1 case INLINE rather than delegating to `lemma_10_2_6_self_contained`. This breaks the mutual dependency but requires duplicating some logic.

   **Recommended: Option A**. It preserves the modular structure and is straightforward.

3. **Fix `no_S_nested_in_U_separable_direct` non-U-free branch** (line 2441-2447): After Option A is applied, the callback chain flows naturally: `no_S_nested_in_U_separable_direct` passes its IH to `lemma_10_2_6_self_contained` which passes it to `single_U_formula_separable_noax`. No `all_separable` needed.

   For the non-U-free args branch specifically: the plan already documents that Phase 4 Task 4.2 will rewrite this entire function. The non-U-free branch will either be eliminated (by ensuring `extract_U_type` finds U-free args at depth >= 2) or handled via the callback approach.

4. **Remove import**: Delete `import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm` from Hierarchy.lean.

5. **Also remove SeparationThm import from**: NormalForm.lean (unused), DedekindZ.lean (unused). Only DualEliminations.lean actually uses `all_separable` but it can import Hierarchy.lean instead (which will export `all_formulas_separable`).

6. **Reverse the import in SeparationThm.lean**: Add `import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy` and replace axioms.

---

## 6. The `single_U_formula_separable_noax` Depth >= 2 Case (Line 2174)

The depth >= 2 case at line 2156-2175 does the following:
1. IH produces `hC_sep : is_separable C` and `hF_sep : is_separable F`
2. Gets separated witnesses C', F'
3. Box-normalizes to C'', F''
4. Proves `no_S_nested_in_U (.snce C'' F'')`
5. Calls `no_S_nested_in_U_separable_param (.snce C'' F'') hns (has_no_allpast_allfuture_true _) (fun zeta _ => all_separable zeta)`

The callback at step 5 receives formulas `zeta` with `no_S_nested_in_U zeta`. It needs to prove `is_separable zeta`. Currently uses `all_separable`.

**Can the callback be `no_S_nested_in_U_separable_direct`?** Yes, if the forward reference issue is resolved. With Option A (callback threading), we don't need a forward reference: the callback is passed in from outside.

**What about replacing with `no_S_nested_in_U_separable_param` recursively?** This would work if we had a suitable termination argument. The callback formulas from `subst_in_separated_separable` are `.snce` nodes created by substituting `.untl A B` (S-free, U-free args in the single-U-type case) into U-free positions of a separated formula. These have `has_single_U_type` with U-free, S-free A, B. So `single_U_formula_separable_noax` can handle them -- but that's the very function we're inside. The recursion terminates because `snce_depth_of_U` strictly decreases (from the outer strong induction), not because of anything about the callback.

**Key realization**: The mutual callback dependency can be broken cleanly with the callback parameter approach (Option A), because the termination measure for each function is different:
- `single_U_formula_separable_noax`: terminates by `snce_depth_of_U` induction
- `lemma_10_2_6_self_contained`: terminates by `count_U_subformulas` induction
- `no_S_nested_in_U_separable_direct`: terminates by `U_nesting_depth` induction

Each uses its own well-founded measure, and the callback is "opaque" -- it just needs to be correct, not to participate in the termination argument.

---

## 7. Other Files That Import SeparationThm

| File | Uses from SeparationThm | Can Import Change? |
|------|------------------------|--------------------|
| NormalForm.lean | NONE (verified by grep) | Remove import; unnecessary |
| DedekindZ.lean | NONE (only comment reference) | Remove import; unnecessary |
| DualEliminations.lean | `all_separable` (8 uses) | Change to import Hierarchy.lean; use `all_formulas_separable` instead |
| SeparationThm.lean | (defines the declarations) | Will import Hierarchy.lean after reversal |

---

## 8. `no_S_nested_in_U_separable_noax` (Line 2062)

**Dead code.** Defined at line 2062-2066. Not referenced by any other function. It was an intermediate stepping stone. Can be deleted.

---

## 9. Risk Assessment

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Callback threading (Option A) requires signature changes to 3 functions | Medium | High (it WILL require changes) | The changes are mechanical: add callback parameter, pass through |
| Forward declaration issues in Lean 4 | Low | Low | Option A avoids forward references entirely |
| NormalForm.lean/DedekindZ.lean break when SeparationThm import removed | Low | Low | Verified they don't use any SeparationThm declarations |
| DualEliminations.lean breaks | Low | High (it WILL need fixing) | Simple: change import to Hierarchy.lean, replace `all_separable` with `all_formulas_separable` |
| `single_U_formula_separable_noax` callback threading introduces new type errors | Medium | Medium | The callback type `(forall chi, no_S_nested_in_U chi -> is_separable chi)` matches what `subst_in_separated_separable` already expects |
| Phase 4 Task 4.2 rewrite of `no_S_nested_in_U_separable_direct` makes this analysis moot | Low | Medium | Even with the rewrite, the callback approach (Option A) is the same strategy -- the rewrite just changes the induction structure, not the callback flow |

---

## 10. Summary of Proposed Resolution

**No new file needed.** The circular import is resolved by:

1. Deleting ~11 dead theorems from Hierarchy.lean (removes 4 of 6 axiom-dependent code sites)
2. Threading a callback parameter through `single_U_formula_separable_noax` and `lemma_10_2_6_self_contained` (fixes the 5th site)
3. Rewriting `no_S_nested_in_U_separable_direct` per Phase 4 Task 4.2 with its own callback handling (fixes the 6th site)
4. Removing `import SeparationThm` from Hierarchy.lean, NormalForm.lean, DedekindZ.lean
5. Changing DualEliminations.lean to import Hierarchy.lean instead of SeparationThm.lean
6. Adding `import Hierarchy` to SeparationThm.lean and replacing 9 axioms with theorems

The dependency graph after resolution:
```
Hierarchy.lean  (no SeparationThm import)
    |
    v
SeparationThm.lean  (imports Hierarchy)
    |
    v
DualEliminations.lean  (imports Hierarchy instead of SeparationThm)
```
