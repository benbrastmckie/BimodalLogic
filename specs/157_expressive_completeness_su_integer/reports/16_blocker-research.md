# Research Report: Task #157 -- Blocker Analysis for Lemma 10.2.7 Induction Measure

**Task**: 157 -- Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-19
**Mode**: Deep-dive research, Round 16
**Focus**: Why `snce_depth_of_U` is the wrong induction measure for 10.2.7, and what to use instead

---

## 1. Diagnosis: Why `snce_depth_of_U` Fails

### 1.1 What `snce_depth_of_U` Actually Measures

`snce_depth_of_U` (Hierarchy.lean line 1281) is defined as:

```lean
def snce_depth_of_U : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (snce_depth_of_U a) (snce_depth_of_U b)
  | .box a => snce_depth_of_U a
  | .untl _ _ => 0        -- STOPS at U-nodes, returns 0
  | .snce a b =>
    if is_U_free a = true && is_U_free b = true then 0
    else 1 + max (snce_depth_of_U a) (snce_depth_of_U b)
```

This counts **S-layers above U**: the maximum number of `.snce` ancestors between the root and any `.untl` node. It does NOT descend into U-args (the `.untl _ _ => 0` clause cuts off recursion at U-nodes).

### 1.2 What GHR94 10.2.7 Actually Inducts On

GHR94 Lemma 10.2.7 says:

> *Proof.* By induction on the maximum depth n of nesting of Us beneath an S.

This is **U-layers below S** (equivalently, "U-nesting depth within the formula"): how many U-nesting levels are reachable from any position. The key operation in the inductive step is abstracting inner U's *within U-args* to reduce U-nesting depth.

### 1.3 Concrete Counterexample

Consider `S(U(a, U(x,y)), c)`:

| Measure | Value | After abstracting inner U | New value |
|---------|-------|---------------------------|-----------|
| `snce_depth_of_U` | 1 | `S(U(a, z), c)` | **1** (unchanged!) |
| GHR94's measure (U-nesting depth) | 2 | `S(U(a, z), c)` | **1** (decreased!) |

For `snce_depth_of_U`: The `.snce` node sees `is_U_free` is false (there's a U below), so returns `1 + max(snce_depth_of_U(U(a, U(x,y))), snce_depth_of_U(c)) = 1 + max(0, 0) = 1`. After abstraction: `1 + max(snce_depth_of_U(U(a, z)), snce_depth_of_U(c)) = 1 + max(0, 0) = 1`. No change because `.untl _ _ => 0` means the measure cannot see inside U-args.

For GHR94's measure: The original has 2 levels of U-nesting (U within U-args). After replacing inner `U(x,y)` with atom `z`, there is only 1 level. Strict decrease.

### 1.4 Root Cause

`snce_depth_of_U` was designed for Lemma 10.2.5 (induction on S-nesting above a fixed U(A,B)), NOT for Lemma 10.2.7 (induction on U-nesting depth beneath S). The plan at round 15 incorrectly proposed using `snce_depth_of_U` as the measure for 10.2.7 with `abstract_inner_U` to reduce it. This combination is unsound: `abstract_inner_U` reduces U-nesting inside U-args, but `snce_depth_of_U` cannot see inside U-args.

### 1.5 The Existing `U_depth_under_S` -- Almost Right But Wrong

Defs.lean already defines `U_depth_under_S`:

```lean
def U_depth_under_S : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp phi psi => max (U_depth_under_S phi) (U_depth_under_S psi)
  | .box phi => U_depth_under_S phi
  | .untl phi psi => 1 + max (U_depth_under_S phi) (U_depth_under_S psi)
  | .snce _ _ => 0  -- S resets the counter
```

This counts "U-nesting depth without any intervening S". The `.snce _ _ => 0` clause resets the counter at S-nodes. This measure is useful for a different purpose (counting U-layers between consecutive S-layers), but it is NOT what GHR94 10.2.7 needs either, because:

- For `S(U(a, U(x,y)), c)`: `U_depth_under_S = 0` (the S resets the counter immediately)
- We need a measure that looks INSIDE the formula overall, not one that resets at S.

`U_depth_under_S` measures "U-nesting reachable without crossing an S boundary". GHR94's 10.2.7 measure is "maximum U-nesting depth anywhere in the formula (crossing S is fine, crossing U increments)".

---

## 2. The Correct Measure: `U_nesting_depth`

### 2.1 Definition

GHR94's "maximum depth n of nesting of Us beneath an S" translates to a measure that counts U-nesting levels visible from any S-position. More precisely, for a formula with `no_S_nested_in_U`, this is the maximum depth of U-chains.

The simplest correct measure counts how many U-nesting levels exist:

```lean
/-- Maximum depth of U-nesting chains in a formula.
    Counts how many levels of `.untl` are nested within `.untl`-args.
    This is GHR94's "depth of nesting of Us beneath an S" for 10.2.7. -/
def U_nesting_depth : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (U_nesting_depth a) (U_nesting_depth b)
  | .box a => U_nesting_depth a
  | .untl a b => 1 + max (U_nesting_depth a) (U_nesting_depth b)
  | .snce a b => max (U_nesting_depth a) (U_nesting_depth b)
```

Note: This is essentially the user's proposed `U_layers` measure. The key difference from `U_depth_under_S` is that `.snce` passes through (takes max) instead of resetting to 0.

### 2.2 Verification on the Counterexample

For `S(U(a, U(x,y)), c)`:
- `U_nesting_depth = max(U_nesting_depth(U(a, U(x,y))), U_nesting_depth(c))`
- `= max(1 + max(0, 1 + max(0, 0)), 0) = max(2, 0) = 2`

After abstracting inner U: `S(U(a, z), c)`:
- `U_nesting_depth = max(1 + max(0, 0), 0) = 1`

Strict decrease from 2 to 1. Correct.

### 2.3 Relationship to GHR94

GHR94 says "depth n of nesting of Us beneath an S" in the context of `no_S_nested_in_U` formulas. For such formulas, every `.untl` has S-free args, meaning S-nodes appear only OUTSIDE U-nodes. So "nesting of Us beneath an S" is equivalent to "maximum U-chain depth anywhere in the formula" (because S never interrupts U-chains when `no_S_nested_in_U` holds). Our `U_nesting_depth` measures exactly this.

Specifically:
- `U_nesting_depth = 0` means U-free (no U at all). This is trivially separable.
- `U_nesting_depth = 1` means all U-args are U-free (boolean). This is Lemma 10.2.6.
- `U_nesting_depth >= 2` means some U-args contain U-nodes. `abstract_inner_U` reduces to `U_nesting_depth <= 1`.

### 2.4 Why `snce_depth_of_U` Still Has a Role

`snce_depth_of_U` is the correct measure for Lemma 10.2.5 (single-U-type, induction on S-nesting above U(A,B)). It should be kept for that purpose. It simply should NOT be used as the measure for 10.2.7.

---

## 3. Analysis of Approach A vs Approach B

### Approach A: New Measure (`U_nesting_depth`) + `abstract_inner_U`

**Strategy**: Define `U_nesting_depth`, define `abstract_inner_U` to replace inner U-subformulas in U-args with fresh atoms, prove strict decrease, then induct.

**Proof structure**:
1. Strong induction on `U_nesting_depth phi` for formulas with `no_S_nested_in_U phi`.
2. Base case (`U_nesting_depth <= 1`): Use existing `no_S_nested_in_U_separable_param` (which handles formulas where all U-args are S-free and U-free, i.e., boolean). The key insight: when `U_nesting_depth <= 1`, all U-args are U-free, so `no_S_nested_in_U` + `U_nesting_depth <= 1` means we have Lemma 10.2.6's precondition.
3. Inductive case (`U_nesting_depth >= 2`):
   a. Apply `abstract_inner_U` to flatten U-args to boolean.
   b. Result has `U_nesting_depth <= 1`, apply 10.2.6 to get separated form E'.
   c. Back-substitute inner U's into E'.
   d. The pure-past parts now contain inner U's at `U_nesting_depth < original`.
   e. Apply IH.

**Key lemmas needed**:
1. `U_nesting_depth` definition (~10 LOC)
2. `U_nesting_depth_zero_iff_U_free`: `U_nesting_depth phi = 0 <-> is_U_free phi = true` (~20 LOC)
3. `abstract_inner_U` function + basic properties (~150 LOC)
4. `abstract_inner_U_reduces_depth`: `U_nesting_depth phi >= 2 -> U_nesting_depth (abstract_inner_U phi) <= 1` (~40 LOC)
5. `abstract_inner_U_roundtrip`: semantic equivalence after back-substitution (~50 LOC)
6. `back_subst_U_nesting_depth_lt`: inner U's in back-substituted pure-past parts have `U_nesting_depth < original` (~60 LOC)
7. `no_S_nested_in_U_separable_direct`: the main 10.2.7 theorem (~80 LOC)

**Pros**:
- Faithful to GHR94
- Clean induction: the measure directly captures what the abstraction operation reduces
- Modular: `U_nesting_depth` is independent of `snce_depth_of_U`

**Cons**:
- Requires defining and proving properties of `abstract_inner_U` (~200+ LOC)
- The `back_subst_U_nesting_depth_lt` lemma is the most subtle piece
- New measure means new monotonicity/base-case infrastructure

### Approach B: Single-U-Type Callback (No New Measure)

**Strategy**: Observe that in `subst_in_separated_separable`, the `.snce c d` case invokes the callback on `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d were U-free. If A, B are also U-free (boolean), then the substituted formula has single U-type U(A,B), so `single_U_formula_separable` applies directly.

**Analysis**:

This works ONLY when U-args are already boolean (U-free). This is exactly the `U_nesting_depth <= 1` case. When U-args contain more U-nodes (the general case with `U_nesting_depth >= 2`), Approach B cannot handle it because `A` is not U-free -- it contains inner U-nodes, so the callback formula does NOT have single U-type.

In other words, Approach B handles the base case but not the inductive case. It is a partial solution.

**Pros**:
- No new measure or `abstract_inner_U` needed for the base case
- Simple and clean for `U_nesting_depth = 1`

**Cons**:
- Does NOT handle `U_nesting_depth >= 2` (the general case)
- Cannot eliminate `abstract_inner_U` entirely -- we still need it for depth >= 2

### Verdict

**Approach A is correct and necessary.** Approach B is a useful optimization for the base case but does not solve the general problem. The recommended strategy combines both:

- Use Approach B's insight for the base case (`U_nesting_depth <= 1`): callback formulas from `subst_in_separated_separable` have single U-type when U-args are boolean, so `single_U_formula_separable` serves as a self-contained callback without circularity.
- Use Approach A for the inductive case (`U_nesting_depth >= 2`): `abstract_inner_U` reduces to the base case.

---

## 4. Recommended Approach

### 4.1 New Measure: `U_nesting_depth`

Define in Defs.lean (or Hierarchy.lean):

```lean
def U_nesting_depth : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (U_nesting_depth a) (U_nesting_depth b)
  | .box a => U_nesting_depth a
  | .untl a b => 1 + max (U_nesting_depth a) (U_nesting_depth b)
  | .snce a b => max (U_nesting_depth a) (U_nesting_depth b)
```

### 4.2 Base Case: `U_nesting_depth <= 1`

When `U_nesting_depth phi <= 1` and `no_S_nested_in_U phi`, all U-args are U-free AND S-free (boolean). This is exactly the precondition of Lemma 10.2.6.

The existing `no_S_nested_in_U_separable_param` proves this case, but it uses a callback. The callback formulas from `subst_in_separated_separable` at depth <= 1 satisfy `has_single_U_type` (because the substituted U(A,B) has boolean args, and c, d were U-free). So `single_U_formula_separable` works as a self-contained callback:

```lean
theorem no_S_nested_in_U_depth_le_one_separable (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (hd : U_nesting_depth phi <= 1) :
    is_separable phi :=
  no_S_nested_in_U_separable_param phi hns (has_no_allpast_allfuture_true phi)
    (fun chi hns_chi => 
      -- chi is a callback formula: .snce (subst c p (.untl A B)) (subst d p (.untl A B))
      -- where c, d are U-free and A, B are S-free and U-free (since U_nesting_depth <= 1)
      -- So chi has single U-type U(A,B), and single_U_formula_separable applies
      -- This needs a lemma connecting U_nesting_depth <= 1 + callback to single_U_type
      ...)
```

Actually, more precisely: `no_S_nested_in_U_separable_param` does strong induction on `count_U_subformulas`, not on `U_nesting_depth`. The callback receives a formula with `no_S_nested_in_U`. At `U_nesting_depth <= 1`, the callback formula's U-args are boolean. But the callback formula itself may have multiple U-types, not a single one.

The cleaner approach: use `no_S_nested_in_U_separable_param` as-is with `all_separable` for the callback at depth <= 1, then replace `all_separable` with a self-contained proof once 10.2.7 is available.

OR: directly observe that when `U_nesting_depth phi <= 1`, the existing `snce_depth_zero_no_S_nested_separated` applies when `snce_depth_of_U = 0`, and `no_S_nested_in_U_separable_param` (with `all_separable` callback or a simple depth-0 callback) handles `snce_depth_of_U >= 1`.

**Simpler base case strategy**: When `U_nesting_depth phi <= 1`, apply `no_S_nested_in_U_separable_param_jd` with a callback that invokes the depth-0 base case `snce_depth_zero_no_S_nested_separated`. The callback formulas have `no_S_nested_in_U` and `junction_depth <= 1`. At `U_nesting_depth <= 1`, callback formulas also have `U_nesting_depth <= 1`. Callback's callbacks will have `U_nesting_depth <= 1` again (since U-args stay boolean through substitution). Eventually the `count_U_subformulas` induction terminates.

Actually, the cleanest path: **The existing `no_S_nested_in_U_separable_param` already handles the depth-0 case correctly** (as proved by `snce_depth_zero_no_S_nested_separated`). The problem is only at depth >= 1 when the callback fires. At `U_nesting_depth <= 1`, the callback produces formulas with `no_S_nested_in_U` and these callback formulas ALSO have `U_nesting_depth <= 1` (because substituting U(A,B) with boolean A,B into U-free positions cannot increase U-nesting beyond 1). So `no_S_nested_in_U_separable_param` can use ITSELF as callback at depth <= 1 via the `count_U_subformulas` strong induction.

Wait -- that is exactly what the existing code does. The issue is that the callback from `subst_in_separated_separable` produces a `.snce` formula, and that `.snce` formula is passed to the callback as a NEW formula to separate. The existing `no_S_nested_in_U_separable_param` then re-invokes itself on this callback formula with a smaller `count_U_subformulas`. This works because `abstract_untl` strictly decreases `count_U_subformulas`.

So the issue is not the base case at all -- the existing `no_S_nested_in_U_separable_param` IS self-contained for the `U_nesting_depth <= 1` case (it uses `count_U_subformulas` strong induction internally). The problem is that this theorem takes a CALLBACK parameter, and the CALLER needs to provide it.

Let me re-examine. The current code has:

```lean
theorem no_S_nested_in_U_separable_param (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (hexp : has_no_allpast_allfuture phi = true)
    (callback : forall (chi : Formula), no_S_nested_in_U chi -> is_separable chi) :
    is_separable phi
```

This theorem is parameterized by a callback that handles arbitrary `no_S_nested_in_U` formulas. It uses `count_U_subformulas` internally. But its callback parameter accepts ANY `no_S_nested_in_U` formula, not just those with decreased measure.

For 10.2.7, we need to provide a callback that proves `is_separable chi` for arbitrary `no_S_nested_in_U chi`. That is EXACTLY Lemma 10.2.7 itself. So we need:

```lean
theorem no_S_nested_in_U_separable_direct (phi : Formula)
    (hns : no_S_nested_in_U phi) :
    is_separable phi
```

And the proof should use `U_nesting_depth` strong induction. At depth 0, phi is U-free and trivially separable. At depth 1, use `no_S_nested_in_U_separable_param` with a callback that only receives depth-0 formulas (which are handled by the base case). At depth >= 2, use `abstract_inner_U` to reduce to depth 1.

But wait: at depth 1, what does the callback receive? The callback in `no_S_nested_in_U_separable_param` receives formulas from `subst_in_separated_separable`, which are `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free and A, B are S-free. Since we're at depth 1, A and B are also U-free (because `U_nesting_depth phi <= 1` and `.untl A B` has `U_nesting_depth = 1 + max(...)`, so `max(U_nesting_depth A, U_nesting_depth B) = 0`, meaning A, B are U-free).

So the callback formula is `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d, A, B are all U-free. The U-nesting depth of `subst c p (.untl A B)` is at most 1 (substituting `.untl A B` with U-free A, B into U-free c introduces at most one U-layer). So the callback formula has `U_nesting_depth <= 1`.

But that's the same depth, not strictly less. We need the callback to be at a STRICTLY smaller depth for the induction to work.

However, `no_S_nested_in_U_separable_param` uses `count_U_subformulas` as its internal induction measure, not `U_nesting_depth`. The callback is external. For 10.2.7, we use `U_nesting_depth` as the OUTER induction, and `no_S_nested_in_U_separable_param` as the inner tool (with its own `count_U_subformulas` induction).

The key insight is: at `U_nesting_depth = 1`, the callback from `no_S_nested_in_U_separable_param` produces formulas that also have `U_nesting_depth <= 1`. But we can verify these callback formulas have `snce_depth_of_U = 0` (because the `.snce` wraps U-free arguments after substitution, and the U(A,B) substituted in has U-free args). Wait, no: `snce_depth_of_U` of the callback formula `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` is `1 + max(snce_depth_of_U (subst c p (.untl A B)), snce_depth_of_U (subst d p (.untl A B)))`. Since `subst c p (.untl A B)` can contain `.untl A B` nodes (from the substitution), `is_U_free` is false, so the `.snce` adds 1. And `snce_depth_of_U (subst c p (.untl A B)) = 0` because `.untl _ _ => 0` and the substituted U(A,B) has U-free args. So `snce_depth_of_U` of the callback = 1.

This is the SAME depth-1 problem identified in round 14-15. The callback at depth 1 has `snce_depth_of_U = 1`, not 0.

OK, so the crux is: **at `U_nesting_depth = 1`, we need a self-contained proof.** Let me think about this differently.

At `U_nesting_depth = 1`, all U-args are U-free. So the formula satisfies the precondition of Lemma 10.2.6: "the only appearances of U in D are in the form U(Ai, Bi) where each Ai, Bi is built without S or U." The existing `no_S_nested_in_U_separable_param` handles this via `count_U_subformulas` induction + callback.

But the callback produces `.snce` formulas that ALSO have `no_S_nested_in_U` and `U_nesting_depth <= 1`. These callback formulas need to be separated too, and they satisfy the same preconditions. So we can USE `no_S_nested_in_U_separable_param` recursively for the callback:

```lean
-- Self-contained 10.2.6:
theorem lemma_10_2_6 (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (h_depth : U_nesting_depth phi <= 1) :
    is_separable phi :=
  no_S_nested_in_U_separable_param phi hns (has_no_allpast_allfuture_true phi)
    (fun chi hns_chi =>
      -- chi has no_S_nested_in_U and U_nesting_depth <= 1
      -- We can prove this by showing the callback preserves U_nesting_depth <= 1
      -- Then recursively apply lemma_10_2_6
      lemma_10_2_6 chi hns_chi ...)
```

But this is circular! `lemma_10_2_6` calls `no_S_nested_in_U_separable_param` which calls the callback which calls `lemma_10_2_6`.

The trick is that `no_S_nested_in_U_separable_param` internally uses `count_U_subformulas` strong induction. Each internal recursive call decreases `count_U_subformulas`. The callback is called on formulas with fewer U-subformulas? No -- the callback receives formulas constructed by `subst_in_separated_separable`, which can have MORE U-subformulas than the original (substituting an atom with `.untl A B` adds a U-subformula in every position where the atom occurred).

Wait, let me re-read `no_S_nested_in_U_separable_param` more carefully. It uses `count_U_subformulas` strong induction on `phi`, not on the callback formula. The callback is a FREE parameter -- it is not constrained to decrease any measure. The callback is invoked zero or more times on formulas DIFFERENT from `phi`. The internal `count_U_subformulas` induction only governs `phi` itself being decomposed into fewer U-subformulas.

So the question is: can we define a TOTAL callback that handles ALL `no_S_nested_in_U` formulas with `U_nesting_depth <= 1`?

YES -- but only if we have an independent proof that such formulas are separable. And that independent proof IS Lemma 10.2.6.

The circularity is real if we try to make `lemma_10_2_6` self-referential through the callback. The solution is to make the callback NOT call `lemma_10_2_6`, but instead use a different strategy.

**The resolution**: Use `no_S_nested_in_U_separable_param` in a DIFFERENT way. Instead of passing a callback that invokes 10.2.6 recursively, we observe that the callback formulas at depth <= 1 have a special structure that allows direct handling.

Specifically, callback formulas from `subst_in_separated_separable` are of the form `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free and A, B are S-free AND U-free (at depth <= 1). The substituted formula `subst c p (.untl A B)` contains U(A,B) in the positions where atom p occurred in c. Since c was U-free, these are the ONLY U-nodes. And since A, B are S-free and U-free (boolean), the formula `subst c p (.untl A B)` has single U-type U(A,B) with S-free args.

Therefore the callback formula `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` has single U-type U(A,B) with S-free args. By `single_U_formula_separable`, it is separable.

**THIS IS THE KEY INSIGHT FOR THE SELF-CONTAINED BASE CASE.**

So the self-contained 10.2.6 is:

```lean
-- For depth <= 1, the callback to no_S_nested_in_U_separable_param
-- can use single_U_formula_separable because callback formulas have single U-type.
theorem lemma_10_2_6_self_contained (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (h_depth : U_nesting_depth phi <= 1) :
    is_separable phi :=
  no_S_nested_in_U_separable_param phi hns (has_no_allpast_allfuture_true phi)
    (fun chi hns_chi =>
      -- chi has no_S_nested_in_U, and we need to show is_separable chi
      -- chi = .snce (subst c p (.untl A B)) (subst d p (.untl A B))
      -- where c, d U-free, A, B S-free and U-free (from depth <= 1)
      -- So chi has single U-type U(A,B), apply single_U_formula_separable
      ...)
```

But wait -- `no_S_nested_in_U_separable_param` extracts `U(A,B)` via `extract_U_type`, which finds the FIRST U-subformula. The A, B it finds have `is_S_free A = true` and `is_S_free B = true` (from `no_S_nested_in_U`). At `U_nesting_depth <= 1`, A and B are also U-free. But the callback receives a formula where a DIFFERENT U(A,B) might have been substituted (the one extracted by `extract_U_type`). The callback formula has single U-type for THAT specific U(A,B).

Actually, looking more carefully at `no_S_nested_in_U_separable_param`: it picks one `U(A,B)` via `extract_U_type`, abstracts it via `abstract_untl`, gets a separated form, then substitutes back. The callback formula from `subst_in_separated_separable` receives `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where A, B are the specific pair extracted. And at depth <= 1, these A, B are U-free. And c, d are U-free (from the `.snce` branch of the separated form). So the callback formula indeed has single U-type U(A,B).

**But there's a subtlety**: the callback formula may also have OTHER U-types that were already in the original formula (since `abstract_untl` only replaces one specific U(A,B)). After substitution, the callback formula contains BOTH the re-substituted U(A,B) AND any other U-types that were in c or d. But c and d were U-free (they come from the `.snce` branch of a syntactically separated formula). So there are NO other U-types in c and d. The only U in the callback formula is the re-substituted U(A,B).

Therefore, the callback formula truly has single U-type U(A,B) with S-free, U-free args, and `single_U_formula_separable` applies.

**This means the depth-1 case IS self-contained without `abstract_inner_U`.**

### 4.3 Inductive Case: `U_nesting_depth >= 2`

Apply `abstract_inner_U` to replace inner U-subformulas in U-args with fresh atoms. This reduces `U_nesting_depth` to at most 1. Apply the self-contained depth-1 case to separate the modified formula. Back-substitute inner U's. The pure-past parts now have `U_nesting_depth < original`. Apply IH.

### 4.4 Complete Proof Sketch

```lean
theorem no_S_nested_in_U_separable_direct (phi : Formula)
    (hns : no_S_nested_in_U phi) :
    is_separable phi := by
  -- Strong induction on U_nesting_depth phi
  induction h : U_nesting_depth phi using Nat.strongRecOn generalizing phi with
  | ind n ih =>
  -- Case n = 0: phi is U-free, hence syntactically separated
  · if h0 : n = 0 then
      ... -- U_nesting_depth = 0 implies U-free implies separated
    -- Case n = 1: use no_S_nested_in_U_separable_param with self-contained callback
    else if h1 : n = 1 then
      exact no_S_nested_in_U_separable_param phi hns (has_no_allpast_allfuture_true phi)
        (fun chi hns_chi =>
          -- chi has single U-type U(A,B) with S-free, U-free A, B
          -- Apply single_U_formula_separable chi A B ...
          ...)
    -- Case n >= 2: abstract inner U's, reduce to depth 1, back-substitute, IH
    else
      ... -- abstract_inner_U reduces to depth <= 1
          -- apply depth-1 case
          -- back-substitute: parts have depth < n
          -- apply ih on parts
```

---

## 5. List of Specific New Lemmas Needed

### 5.1 Measure Definition and Basic Properties

| Lemma | Purpose | Est. LOC |
|-------|---------|----------|
| `U_nesting_depth` | Definition of the correct measure | 10 |
| `U_nesting_depth_zero_iff_U_free` | `U_nesting_depth phi = 0 <-> is_U_free phi = true` | 25 |
| `U_nesting_depth_le_one_U_args_U_free` | `U_nesting_depth phi <= 1 -> no_S_nested_in_U phi -> all U-args are U-free` | 30 |

### 5.2 Self-Contained Depth-1 Case (Approach B insight)

| Lemma | Purpose | Est. LOC |
|-------|---------|----------|
| `callback_has_single_U_type` | Callback formulas from `subst_in_separated_separable` have single U-type when U-args are boolean | 50 |
| `lemma_10_2_6_self_contained` | `no_S_nested_in_U phi -> U_nesting_depth phi <= 1 -> is_separable phi` using `single_U_formula_separable` as callback | 60 |

### 5.3 `abstract_inner_U` and Properties (for depth >= 2)

| Lemma | Purpose | Est. LOC |
|-------|---------|----------|
| `abstract_inner_U` | Replace inner U-subformulas in U-args with fresh atoms | 70 |
| `abstract_inner_U_preserves_no_S_nested` | Abstraction preserves `no_S_nested_in_U` | 30 |
| `abstract_inner_U_reduces_depth` | `U_nesting_depth phi >= 2 -> U_nesting_depth (abstract phi) <= 1` | 40 |
| `abstract_inner_U_roundtrip` | Back-substitution recovers equivalent formula | 50 |
| `back_subst_U_nesting_depth_lt` | Pure-past parts after back-subst have `U_nesting_depth < original` | 60 |

### 5.4 Main Theorem

| Lemma | Purpose | Est. LOC |
|-------|---------|----------|
| `no_S_nested_in_U_separable_direct` | GHR94 Lemma 10.2.7 via `U_nesting_depth` induction | 100 |

**Total estimated new LOC: ~525**

---

## 6. Does `abstract_inner_U` Still Need to Be Defined?

**Yes**, but only for the `U_nesting_depth >= 2` case. For `U_nesting_depth <= 1`, the proof is self-contained using `single_U_formula_separable` as callback.

However, if the codebase only ever encounters formulas with `U_nesting_depth <= 1` in practice (e.g., if the hierarchy theorem at the `all_formulas_separable_aux` level always reduces to this case via junction-depth induction), then `abstract_inner_U` might not be strictly needed for the FULL separation theorem. Let me check.

In `all_formulas_separable_aux`, the `.snce` case:
1. Recursively separates sub-formulas a, b
2. Box-normalizes to get `chi_a`, `chi_b` (separated, box-free)
3. Builds `.snce chi_a chi_b` which has `no_S_nested_in_U` and `JD <= 1`
4. Calls `no_S_nested_in_U_separable_param_jd` on it

What is `U_nesting_depth (.snce chi_a chi_b)`? Since `chi_a` and `chi_b` are syntactically separated (box-free), their `.untl` nodes have S-free args and their `.snce` nodes have U-free args. But they can have arbitrarily deep U-nesting within the `.untl` branches.

For example, if the original formula was `S(U(a, U(x, y)), b)`, then `chi_a` could be something like `.untl A (.untl X Y)` (not literally, but conceptually the separated form could have nested U-nodes in the S-free parts). So `U_nesting_depth (.snce chi_a chi_b)` could be >= 2.

Therefore, **`abstract_inner_U` IS needed** for the general case. The hierarchy theorem produces formulas with `no_S_nested_in_U` and arbitrary `U_nesting_depth`.

---

## 7. Does `no_S_nested_in_U_separable_param` Need Modification?

**No.** The existing `no_S_nested_in_U_separable_param` works correctly as a parameterized tool. The change is in how it is CALLED:

- Currently called with `callback = fun chi _ => all_separable chi` (axiom-dependent)
- Should be called with `callback = fun chi hns_chi => ...` using the depth-1 self-contained proof

The `_jd` variant (`no_S_nested_in_U_separable_param_jd`) also does not need modification.

---

## 8. Minimal Change from Current Plan

The current plan (v15) proposes:
1. Define `abstract_inner_U` (Task 3.3-3.7)
2. Use `snce_depth_of_U` as the induction measure for 10.2.7 (Task 4.1)

**Required changes to the plan**:

1. **Replace `snce_depth_of_U` with `U_nesting_depth`** as the induction measure for 10.2.7. Add `U_nesting_depth` definition and basic properties (new Task 3.0, ~35 LOC).

2. **Add self-contained depth-1 case** (new Task 3.1b, ~110 LOC). This is the key insight: `single_U_formula_separable` serves as a callback for `no_S_nested_in_U_separable_param` when `U_nesting_depth <= 1`, making the depth-1 case self-contained WITHOUT axioms.

3. **Keep `abstract_inner_U`** (Tasks 3.3-3.7) but modify Task 3.7 to prove `back_subst_U_nesting_depth_lt` using the new measure instead of `snce_depth_of_U`.

4. **Modify Task 4.1** (`no_S_nested_in_U_separable_direct`): Use `U_nesting_depth` strong induction with three cases:
   - n = 0: U-free, trivially separated
   - n = 1: self-contained via `lemma_10_2_6_self_contained`
   - n >= 2: `abstract_inner_U` + depth-1 case + back-subst + IH

5. **No changes needed to** `no_S_nested_in_U_separable_param`, `subst_in_separated_separable`, `all_formulas_separable_aux`, or any Phase 1-2 work.

---

## 9. Summary

| Finding | Impact |
|---------|--------|
| `snce_depth_of_U` is wrong for 10.2.7 (measures S-above-U, not U-nesting-depth) | **BLOCKER** for Phase 3 Task 3.7 and Phase 4 |
| `U_depth_under_S` (existing in Defs.lean) is also wrong (resets at S-nodes) | Cannot use existing measure |
| New `U_nesting_depth` measure needed (~10 LOC definition) | Correct measure for 10.2.7 |
| Depth-1 case is self-contained via `single_U_formula_separable` callback | Eliminates depth-1 circularity |
| `abstract_inner_U` still needed for depth >= 2 | Plan Tasks 3.3-3.7 still required |
| Existing `no_S_nested_in_U_separable_param` needs no modification | Minimal disruption to codebase |
| Total new LOC: ~525 (vs plan's ~480-600 estimate, roughly consistent) | Plan estimate was reasonable |
