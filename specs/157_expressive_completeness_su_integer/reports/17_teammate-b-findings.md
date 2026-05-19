# Teammate B Findings: Lean 4 Implementation Patterns

**Task**: 157
**Date**: 2026-05-19
**Teammate**: B (Lean 4 Implementation Patterns)
**Artifact**: 17

## Key Findings

### 1. Nested Strong Induction: Existing Pattern Is Sufficient

The codebase already uses `Nat.strongRecOn` at three sites in Hierarchy.lean (lines 1640, 1807, 1862). The pattern for `no_S_nested_in_U_separable_direct` needs an **outer** strong induction on `U_nesting_depth` that calls into **existing** functions (`no_S_nested_in_U_separable_param` or `no_S_nested_in_U_separable_param_jd`) which each have their own inner `Nat.strongRecOn` on `count_U_subformulas`.

**This nesting is not a problem in Lean 4.** Since `no_S_nested_in_U_separable_param` is already a fully defined theorem (not a mutually recursive definition), calling it from within a `Nat.strongRecOn` block is no different from calling any other theorem. There is no termination obligation to discharge — the outer induction only needs `U_nesting_depth` to decrease, and the inner function is a completed proof.

**Concrete pattern (from existing code at line 1862)**:
```lean
theorem no_S_nested_in_U_separable_direct (phi : Formula)
    (hns : no_S_nested_in_U phi) :
    is_separable phi := by
  -- Strong induction on U_nesting_depth
  induction h : U_nesting_depth phi using Nat.strongRecOn generalizing phi with
  | ind n ih =>
    -- Case 0: U-free
    by_cases huf : is_U_free phi = true
    · exact separated_imp_separable phi (...)
    · -- Case depth ≤ 1: use lemma_10_2_6_self_contained
      by_cases hle : n ≤ 1
      · exact lemma_10_2_6_self_contained phi hns (h ▸ hle)
      · -- Case depth ≥ 2: abstract inner U's, separate, back-substitute, apply IH
        ...
        -- IH call: ih (U_nesting_depth part') (h ▸ h_depth_lt) part' hns_part' rfl
```

The `generalizing phi` clause is critical — it universally quantifies `phi` inside the induction so you can apply the IH to different formulas.

### 2. `abstract_inner_U`: Pure Traversal with Accumulator

The `abstract_inner_U` function needs to traverse U-args and collect inner `.untl` sub-formulas into a mapping. The **recommended Lean 4 pattern** is a pure function with an accumulator, mirroring the existing `abstract_untl` (line 276) which already uses `DecidableEq Formula` (derived on `Formula` at line 85 of Formula.lean: `deriving Repr, DecidableEq, BEq, Hashable, Countable`).

**Key implementation detail**: `Formula` already has `DecidableEq` (derived), so `if c = A ∧ d = B then ...` works directly. This is proven by the existing `abstract_untl` which uses exactly this pattern at line 283.

**Fresh atom generation**: The project has `fresh_atom` (FormulaOps.lean:192) and `fresh_atoms` (FormulaOps.lean:200) infrastructure. For `abstract_inner_U`, use `fresh_atoms` to generate `n` fresh atoms at once:

```lean
-- Generate fresh atoms for all inner U-subformulas
let inner_us := collect_inner_untl phi  -- List (Formula × Formula)
let n := inner_us.length
let atoms := fresh_atoms phi n
let mapping := inner_us.zip atoms |>.map fun ((a, b), p) => (a, b, p)
```

**However**, the simpler approach (recommended by the plan's fallback at Phase 3, Task 3.9) is to abstract **one inner U at a time** iteratively. This avoids the need for `List.foldl` roundtrip proofs entirely:

```lean
-- Iterative single-U abstraction (simpler, plan fallback)
-- Step 1: Find one inner .untl X Y in U-args
-- Step 2: Replace it with fresh atom p using abstract_untl
-- Step 3: Separate the result (depth now reduced)
-- Step 4: Back-substitute p → .untl X Y
-- Step 5: Apply IH to impure parts
-- Repeat until no inner U's remain
```

This works because `abstract_untl` already exists with a complete roundtrip proof (`abstract_subst_roundtrip`, line 291). Each iteration reduces `U_nesting_depth` by at least 1 (by removing one nesting layer), so the strong induction on `U_nesting_depth` handles termination.

### 3. Multi-Substitution Roundtrip: Use Iterative Single-Subst

The project already has `multi_subst` (FormulaOps.lean:225) defined via `List.foldl`. However, proving a `foldl`-based roundtrip is tricky because substitutions can interfere.

**Recommended approach**: Don't use `multi_subst` for the roundtrip. Instead, use iterative single-substitution with the existing `abstract_subst_roundtrip` theorem. The proof structure is:

```lean
-- For each inner U(Xij, Yij) abstracted to atom zij:
-- 1. abstract_untl phi Xij Yij zij produces phi'
-- 2. abstract_subst_roundtrip says: subst_formula phi' zij (.untl Xij Yij) = phi
-- 3. abstract_untl_equiv says: int_equiv phi (subst_formula phi' zij (.untl Xij Yij))
```

For the depth ≥ 2 case, the proof should:
1. Pick ONE inner `.untl X Y` in a U-arg (using `extract_U_type` or similar)
2. Abstract it with `abstract_untl`
3. The result has `U_nesting_depth` strictly less (by 1)
4. Apply the IH at the lower depth
5. Back-substitute using `abstract_subst_roundtrip`

**Freshness/non-interference**: The existing `fresh_atom_not_in` theorem (FormulaOps.lean:196) guarantees the fresh atom doesn't appear in the original formula. Since `abstract_untl` only introduces the fresh atom at positions where it replaces `.untl X Y`, and back-substitution replaces exactly those positions, there is no interference. This is exactly the proof of `abstract_subst_roundtrip` (line 291).

### 4. Callback Threading: The Depth ≤ 1 Case

`no_S_nested_in_U_separable_param` takes callback type:
```lean
callback : ∀ (χ : Formula), no_S_nested_in_U χ → is_separable χ
```

At depth ≤ 1, we want to provide `single_U_formula_separable` as callback. The challenge: the callback receives `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` and we need to show `has_single_U_type`.

**The threading works because**:
- `c, d` are U-free (from separated form `ψ`'s `is_syntactically_separated`)
- A, B are U-free (from `U_nesting_depth_le_one_untl_args_U_free`)
- A, B are S-free (from `no_S_nested_in_U` at the `.untl` position)
- `subst_formula c p (.untl A B)` with U-free `c` gives `has_single_U_type` for A, B (every U comes from the substitution)

**But `single_U_formula_separable` itself uses `snce_separable` axiom!** So even if we can prove callback formulas have single U-type, we can't use the existing `single_U_formula_separable` as-is. We need either:

(a) A new axiom-free version of `single_U_formula_separable` that handles `.snce` via `snce_depth_of_U` induction + Cases 1-8, OR

(b) A self-contained callback that doesn't go through `single_U_formula_separable` at all.

### 5. The `.snce` Case: `snce_depth_of_U` Induction + Existing Cases 1-8

The GHR94 approach for 10.2.5 is to induct on `snce_depth_of_U` (the "maximum number k of nested Ss above any U(A,B)"):

- **Depth 0**: Already syntactically separated. The theorem `snce_depth_zero_single_U_separated` (line 1390) proves this.
- **Depth k+1**: Apply Lemma 10.2.4 to the most deeply nested S(C,F) containing U(A,B), reducing depth by 1.

The existing infrastructure supports this:

1. **`snce_depth_of_U`** (line 1281): Already defined and has monotonicity lemmas.
2. **`snce_depth_zero_single_U_separated`** (line 1390): Base case (depth 0).
3. **`lemma_10_2_4`** (NormalForm.lean:346): All 8 cases are proved axiom-free. Takes U-free, S-free `a, q, A, B`.
4. **`replace_untl`** (line 1514): Replaces U(A,B) with constant `r`, producing U-free formulas.
5. **`replace_untl_U_free`** (line 1524): Proves the result is U-free.

**The key missing piece**: A theorem that applies Lemma 10.2.4 at the **innermost** `.snce` containing U(A,B), reducing `snce_depth_of_U` by 1. This requires:

```lean
/-- Axiom-free version of single_U_formula_separable.
    Uses snce_depth_of_U induction: at each .snce, apply Lemma 10.2.4
    to reduce S-nesting above U(A,B). -/
theorem single_U_formula_separable_noax (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable φ := by
  induction h : snce_depth_of_U φ using Nat.strongRecOn generalizing φ with
  | ind n ih =>
    by_cases hdepth : snce_depth_of_U φ = 0
    · -- Base: depth 0 → syntactically separated
      exact separated_imp_separable φ
        (snce_depth_zero_single_U_separated φ A B hA_sf hB_sf h_single
          (has_no_allpast_allfuture_true φ) hdepth)
    · -- Inductive: depth k+1
      -- Need to handle each constructor
      induction φ with
      | atom _ => simp [snce_depth_of_U] at hdepth
      | bot => simp [snce_depth_of_U] at hdepth
      | imp a b _ _ =>
        -- imp: both sub-formulas have snce_depth ≤ n, use IH
        ...
      | box a _ =>
        -- box: trivially separated
        exact ⟨.box a, rfl, int_equiv_refl _⟩
      | untl a b _ _ =>
        -- untl: has_single_U_type forces a = A, b = B; S-free → separated
        have ⟨ha, hb⟩ := h_single; subst ha; subst hb
        exact untl_s_free_separable hA_sf hB_sf
      | snce c d _ _ =>
        -- THIS IS THE KEY CASE
        -- c, d have has_single_U_type
        -- Apply replace_untl to get C' = c[U(A,B) := ⊤], which is U-free
        -- Then .snce c d ≡ .snce (C' ∧ U(A,B)) d ∨ .snce (C' ∧ ¬U(A,B)) d
        -- (event-splitting)
        -- Each branch matches Cases 1-8 with U-free/S-free arguments
        -- Result is separable with snce_depth reduced
        ...
```

**The `.snce` case challenge**: The `replace_untl` technique gives us `C' = replace_untl c A B ⊤` which is U-free. Then:
- `c ≡ (C' ∧ U(A,B)) ∨ (C' ∧ ¬U(A,B))` (by case analysis on U(A,B))
- `.snce c d ≡ .snce (C' ∧ U(A,B)) d ∨ .snce (C' ∧ ¬U(A,B)) d`

But `d` might still contain U(A,B). We need to decompose `d` similarly. This is where the full 8-case decomposition applies.

**However**, the existing `lemma_10_2_4` requires `a, q` to be **atoms** (or at least U-free AND S-free formulas). After `replace_untl`, the event `C'` is U-free but might not be S-free (c could have `.snce` inside it at the same level). 

**Critical insight**: At the **innermost** `.snce c d` containing U(A,B) — i.e., where `snce_depth_of_U (.snce c d) ≥ 1` but `snce_depth_of_U c = 0` and `snce_depth_of_U d = 0` — the sub-formulas c and d have depth 0 meaning all `.snce` inside c and d have U-free children. So `replace_untl c A B ⊤` is both U-free and S-free (since c has `has_single_U_type` and depth 0 means no S above U in c). Wait — S-freeness of `replace_untl c A B ⊤` requires c itself to be S-free, which is NOT guaranteed.

**Correction**: At depth 0, `.snce` children are U-free. At depth 1 (the innermost S containing U), `c` and `d` have `snce_depth_of_U = 0` which means c and d's `.snce` nodes all have U-free children. But c and d CAN have `.snce` nodes — they just don't have U below those nodes. So `replace_untl c A B r` replaces U(A,B) in c with r. In c, U(A,B) appears only under the current `.snce` (not under deeper `.snce` nodes since those are U-free). After replacement, c becomes U-free but NOT necessarily S-free.

This means we CANNOT directly use `lemma_10_2_4` which requires `a` and `q` to be S-free. **The existing Cases 1-8 require S-free `a` and `q`**.

**Resolution**: The `subst_in_separated_separable` approach sidesteps this. Instead of applying Cases 1-8 directly at the `.snce` node, we use the callback mechanism: abstract one U-type, get a separated form, substitute back. The callback receives `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free (from separated). After substitution, `subst c p (.untl A B)` has single U-type and `snce_depth_of_U = 0` (since c was U-free, the only U comes from substitution, and c has no `.snce` above U — the U was placed at atom positions).

Wait, that's not right either. c was U-free from the separated form, but c CAN have `.snce` nodes. After substituting p → U(A,B), the `.snce` nodes in c now have U(A,B) below them. So `snce_depth_of_U (subst c p (.untl A B))` could be > 0.

**The actual resolution**: Use `no_S_nested_in_U_separable_param` which does `count_U_subformulas` induction. The callback receives formulas with `no_S_nested_in_U`. For the callback at depth ≤ 1, we need to prove that the callback formula itself is separable WITHOUT using `snce_separable`. The approach:

1. Callback formula has `no_S_nested_in_U` (proven at line 1791-1794)
2. Callback formula has `has_single_U_type` for some A, B (because c, d are U-free, substitution creates single U-type) — provable via `subst_U_free_gives_single_U_type` (Task 3.4)
3. A, B are S-free (from `no_S_nested_in_U` at the `.untl` position) and U-free (from `U_nesting_depth ≤ 1`)
4. The callback formula has `snce_depth_of_U` that can be reduced via Cases 1-8

So the correct approach is: write a NEW version `single_U_formula_separable_noax` that uses `snce_depth_of_U` induction at the `.snce` case. At depth 0, it's already separated. At depth k+1, apply `no_S_nested_in_U_separable_param` recursively — but this is where it gets circular!

**The actual non-circular approach**: At the `.snce ψ₁ ψ₂` case with single U-type U(A,B) and S-free, U-free A, B:
1. By IH on structural sub-formula, ψ₁ and ψ₂ are separable (they have strictly smaller `sizeOf`)
2. Get separated equivalents ψ₁' ≡ ψ₁ and ψ₂' ≡ ψ₂  
3. `.snce ψ₁ ψ₂ ≡ .snce ψ₁' ψ₂'`
4. ψ₁', ψ₂' are separated: U-free branches + S-free branches
5. Substitute p → U(A,B) back: this is what `subst_in_separated_separable` does
6. The callback in `subst_in_separated_separable` receives formulas with `no_S_nested_in_U` AND `snce_depth_of_U` strictly less than the original `.snce ψ₁ ψ₂` (because we applied IH to strict sub-formulas)

**This is the right approach**: Combined structural + `snce_depth_of_U` induction.

### 6. Existing Infrastructure Summary

| Component | Location | Status | Notes |
|-----------|----------|--------|-------|
| `DecidableEq Formula` | Formula.lean:85 | ✅ derived | Enables `if c = A ∧ d = B` |
| `fresh_atom` / `fresh_atoms` | FormulaOps.lean:192-216 | ✅ complete | Generates n fresh atoms with disjointness |
| `abstract_untl` | Hierarchy.lean:276 | ✅ complete | Single U-type abstraction |
| `abstract_subst_roundtrip` | Hierarchy.lean:291 | ✅ complete | Syntactic roundtrip |
| `abstract_untl_equiv` | Hierarchy.lean:371 | ✅ complete | Semantic roundtrip |
| `subst_formula` | FormulaOps.lean:30 | ✅ complete | Basic substitution |
| `subst_correctness` | FormulaOps.lean:49 | ✅ complete | Semantic correctness |
| `multi_subst` | FormulaOps.lean:225 | ✅ complete | Sequential multi-substitution |
| `Nat.strongRecOn` | Lean core | ✅ available | Pattern at line 1640, 1807, 1862 |
| `replace_untl` | Hierarchy.lean:1514 | ✅ complete | Replace U(A,B) with constant |
| `replace_untl_U_free` | Hierarchy.lean:1524 | ✅ complete | U-freeness preservation |
| `snce_depth_of_U` | Hierarchy.lean:1281 | ✅ complete | S-nesting-above-U measure |
| `U_nesting_depth` | Hierarchy.lean:1425 | ✅ complete | U-nesting-below-S measure |
| `snce_depth_zero_single_U_separated` | Hierarchy.lean:1390 | ✅ complete | Base case for 10.2.5 |
| `snce_depth_zero_no_S_nested_separated` | Hierarchy.lean:1356 | ✅ complete | Base case for 10.2.7 |
| `lemma_10_2_4` (all 8 cases) | NormalForm.lean:346 | ✅ complete | Axiom-free Cases 1-8 |
| `no_S_nested_in_U_separable_param` | Hierarchy.lean:1634 | ✅ complete | Parameterized by callback |
| `no_S_nested_in_U_separable_param_jd` | Hierarchy.lean:1801 | ✅ complete | JD-bounded callback |
| `subst_in_separated_separable` | Hierarchy.lean:1144 | ✅ complete | Callback at `.snce` case |
| `subst_in_separated_separable_jd` | Hierarchy.lean:1765 | ✅ complete | JD-bounded version |
| `callback_jd_le_one` | Hierarchy.lean:1722 | ✅ complete | Callback JD bound |
| `WellFounded.prod_lex` | Mathlib | ✅ available | Lexicographic WF (if needed) |

## Recommended Approach

### For the depth ≤ 1 self-contained case (Tasks 3.4-3.5):

1. **Prove `callback_has_single_U_type`** (Task 3.4): Straightforward structural induction on U-free `c`. Every `.untl` in `subst_formula c p (.untl A B)` comes from the substitution, hence is exactly U(A,B). The key helper `subst_U_free_gives_single_U_type` follows directly.

2. **Write `single_U_formula_separable_noax`**: A new version of `single_U_formula_separable` that handles `.snce` via `snce_depth_of_U` induction + existing Cases 1-8. This is the CORE new code needed.

3. **Connect via `lemma_10_2_6_self_contained`** (Task 3.5): Use `no_S_nested_in_U_separable_param` with callback = `single_U_formula_separable_noax`. This works because at depth ≤ 1, callback formulas have single U-type with U-free/S-free args.

### For the depth ≥ 2 case (Tasks 3.6-3.11):

**Use the iterative single-U abstraction approach** (plan fallback):

1. At `U_nesting_depth ≥ 2`, find ONE inner `.untl X Y` nested inside a U-arg
2. Abstract it with `abstract_untl` (already exists, complete with roundtrip)
3. The result has `U_nesting_depth` strictly less (by at least 1)
4. Apply the IH at the lower depth
5. Back-substitute and apply IH to impure parts

This avoids the complex `abstract_inner_U` function with multi-substitution. Each step uses the existing `abstract_untl` + `abstract_subst_roundtrip` infrastructure.

### For `all_formulas_separable_aux` rewrite (Phase 5):

Replace the `all_separable ζ` fallback at n=1 with `no_S_nested_in_U_separable_direct`. Since `no_S_nested_in_U_separable_direct` is fully self-contained (no axioms), this eliminates the axiom dependency entirely.

## Evidence/Examples

### Pattern: `Nat.strongRecOn` with `generalizing` (from Hierarchy.lean:1640)
```lean
theorem no_S_nested_in_U_separable_param (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (hexp : has_no_allpast_allfuture phi = true)
    (callback : ∀ (χ : Formula), no_S_nested_in_U χ → is_separable χ) :
    is_separable phi := by
  induction h : count_U_subformulas phi using Nat.strongRecOn generalizing phi with
  | ind n ih =>
  by_cases huf : is_U_free phi = true
  · exact separated_imp_separable phi (restricted_u_free_separated phi hexp huf)
  · ...
    have hcount_lt : count_U_subformulas phi' < count_U_subformulas phi := ...
    have h_phi'_sep : is_separable phi' := by
      exact ih (count_U_subformulas phi') (h ▸ hcount_lt) phi' hns' hexp' rfl
```

### Pattern: Fresh atom generation (from FormulaOps.lean:192)
```lean
noncomputable def fresh_atom (phi : Formula) : Atom :=
  (exists_atom_not_in_finset phi.atoms).choose

theorem fresh_atom_not_in (phi : Formula) : fresh_atom phi ∉ phi.atoms :=
  (exists_atom_not_in_finset phi.atoms).choose_spec
```

### Pattern: Single-substitution roundtrip (from Hierarchy.lean:291)
```lean
theorem abstract_subst_roundtrip (phi A B : Formula) (p : Atom)
    (hfresh : ¬ (p ∈ phi.atoms)) :
    subst_formula (abstract_untl phi A B p) p (.untl A B) = phi
```

### Lexicographic well-founded recursion (Mathlib, if needed)
```lean
-- Available via: import Mathlib.Order.RelClasses
theorem WellFounded.prod_lex {ra : α → α → Prop} {rb : β → β → Prop}
    (ha : WellFounded ra) (hb : WellFounded rb) :
    WellFounded (Prod.Lex ra rb)

-- Usage in Lean 4 with termination_by:
def foo (n m : Nat) : ... :=
  ...
  termination_by (n, m)
  decreasing_by
    · left; omega  -- n decreased
    · right; omega -- n same, m decreased
```

## Confidence Level

**High** for findings 1-4 (nested induction, fresh atoms, roundtrip, callback threading) — these are based on patterns already working in the codebase.

**Medium** for finding 5 (the `.snce` case in `single_U_formula_separable_noax`) — the approach is mathematically sound but the interaction between `snce_depth_of_U` induction and the existing `lemma_10_2_4` preconditions (requiring S-free `a, q`) needs careful verification. The callback formulas from `subst_in_separated_separable` may not satisfy S-free preconditions directly, requiring an intermediate step through `replace_untl` or a generalized version of Cases 1-8.

**High** for the iterative single-U abstraction approach for depth ≥ 2 — it reuses existing infrastructure completely and avoids the complexity of multi-substitution.
