# Report 19: Innermost U-Extraction for Depth >= 2

**Task**: 157 -- Expressive Completeness SU Integer
**Focus**: How to extract an innermost `.untl X Y` with U-free args from a formula with `U_nesting_depth >= 2`

## 1. How `extract_U_type` Works and Why It Doesn't Suffice

**Location**: Hierarchy.lean lines 1198-1209

`extract_U_type` descends through `.imp`, `.box`, `.snce` following the first non-U-free branch, and returns `(a, b)` at the first `.untl a b` it reaches:

```lean
| .untl a b, _, _ => (a, b)
```

It never descends INTO `.untl` args. This is fine when `U_nesting_depth <= 1` (all U-args are U-free), but at depth >= 2, the first `.untl a b` found may have `a` or `b` containing further `.untl` nodes. The args are NOT U-free.

**Consequence in `no_S_nested_in_U_separable_direct`** (line 2432): The proof splits on `is_U_free AB.1 = true /\ is_U_free AB.2 = true`. The U-free branch uses `subst_in_separated_separable_depth` with the depth IH. The non-U-free branch falls back to `all_separable` (line 2447) -- the axiom we need to eliminate.

**Root cause**: `extract_U_type` finds an outermost surface `.untl`, not an innermost nested one.

## 2. Proposed `extract_innermost_U_type` Design

### Signature

```lean
private noncomputable def extract_innermost_U_type :
    (phi : Formula) -> (is_U_free phi = false) ->
    no_S_nested_in_U phi -> (Formula x Formula)
```

### Algorithm

The key difference from `extract_U_type`: at `.untl a b`, instead of returning `(a, b)` immediately, check if `a` or `b` still contains `.untl`. If yes, recurse into the non-U-free child. Only return `(a, b)` when both `a` and `b` are U-free.

```lean
| .imp c d, h, hns =>
    if hc : is_U_free c = false then extract_innermost_U_type c hc hns.1
    else extract_innermost_U_type d (...) hns.2
| .box c, h, hns => extract_innermost_U_type c (...) hns
| .untl a b, _, hns =>
    if is_U_free a = false then extract_innermost_U_type a (...) hns_arg
    else if is_U_free b = false then extract_innermost_U_type b (...) hns_arg
    else (a, b)  -- both U-free: this is the innermost
| .snce c d, h, hns =>
    if hc : is_U_free c = false then extract_innermost_U_type c hc hns.1
    else extract_innermost_U_type d (...) hns.2
```

**Termination**: Each recursive call goes to a strict structural subterm (`.untl a b` -> `a` or `b`; `.imp c d` -> `c` or `d`; etc.). Lean's structural recursion handles this.

**Critical subtlety for `.untl a b` case**: When recursing into `a` (which is an arg of `.untl a b`), we need `no_S_nested_in_U a`. But `no_S_nested_in_U (.untl a b)` gives us `is_S_free a = true /\ is_S_free b = true`, NOT `no_S_nested_in_U a`. We need `no_S_nested_in_U a` to recurse. This holds because S-free implies no_S_nested_in_U (trivially: a formula with no S certainly has no S nested in U). This requires a lemma:

```lean
theorem S_free_implies_no_S_nested (phi : Formula)
    (h : is_S_free phi = true) : no_S_nested_in_U phi
```

This should be a straightforward structural induction (S-free means no `.snce` anywhere, so `no_S_nested_in_U` is vacuously true at `.untl` nodes and propagates through everything else).

### Required Properties

**Property 1: U-free args**
```lean
theorem extract_innermost_U_type_U_free (phi : Formula)
    (h : is_U_free phi = false) (hns : no_S_nested_in_U phi) :
    is_U_free (extract_innermost_U_type phi h hns).1 = true /\
    is_U_free (extract_innermost_U_type phi h hns).2 = true
```

This follows by construction: the function only returns `(a, b)` when both are U-free.

**Property 2: S-free args**
```lean
theorem extract_innermost_U_type_S_free (phi : Formula)
    (h : is_U_free phi = false) (hns : no_S_nested_in_U phi) :
    is_S_free (extract_innermost_U_type phi h hns).1 = true /\
    is_S_free (extract_innermost_U_type phi h hns).2 = true
```

Follows from `no_S_nested_in_U`: at every `.untl a b` node, args are S-free. The function only reaches `.untl a b` by going through (possibly nested) `.untl` nodes, each of which has S-free args by `no_S_nested_in_U`.

**Property 3: Surface containment**
```lean
theorem extract_innermost_U_type_contains_surface (phi : Formula)
    (h : is_U_free phi = false) (hns : no_S_nested_in_U phi) :
    contains_untl_surface phi
      (extract_innermost_U_type phi h hns).1
      (extract_innermost_U_type phi h hns).2
```

**Wait -- this is NOT true with the current `contains_untl_surface`**. The predicate `contains_untl_surface` (line 1070) does NOT recurse into `.untl` args:

```lean
| .untl c d, A, B => c = A /\ d = B
```

If the innermost `.untl X Y` is nested inside another `.untl a b`, then `contains_untl_surface phi X Y` is FALSE (because the surface-level predicate only matches the OUTER `.untl`, requiring its args to be X and Y).

**This is the key design decision**: We need either (a) a new predicate `contains_untl_deep` that recurses into `.untl` args, or (b) to show that `abstract_untl` still works correctly even when the `.untl X Y` is nested.

Examining `abstract_untl` (line 276-285): It DOES recurse into `.untl` args (the non-matching case). So `abstract_untl phi X Y p` will find and replace a nested `.untl X Y` even when it's inside another `.untl`'s args. The abstraction works.

But we need a strict decrease proof for `count_U_subformulas`. The existing `abstract_untl_count_lt_of_contains_surface` requires `contains_untl_surface` (which fails for nested `.untl`). We need a generalized version.

## 3. Strict Decrease Proof Strategy

### Strategy A: Prove strict decrease of `U_nesting_depth` directly

When we abstract an innermost `.untl X Y` (U-free args, depth 1) that is nested inside another `.untl a b`'s args:

- Before: `U_nesting_depth (.untl a b) = 1 + max(depth(a), depth(b)) >= 2`
- The `.untl X Y` contributes depth 1 to either `a` or `b`
- After abstracting: the inner `.untl X Y` becomes atom `p` (depth 0)
- New: `U_nesting_depth (.untl a' b') = 1 + max(depth(a'), depth(b'))`
- `depth(a') <= depth(a)` by `abstract_untl_U_nesting_depth_le`
- If `.untl X Y` was in `a`: `depth(a') < depth(a)` (strict) because the `.untl X Y` node that contributed depth >= 1 to `a` is now atom `p` with depth 0

**Key lemma needed**:
```lean
theorem abstract_untl_U_nesting_depth_lt_of_contains
    (phi X Y : Formula) (p : Atom)
    (h_uf_X : is_U_free X = true) (h_uf_Y : is_U_free Y = true)
    (h_not_eq : phi != .untl X Y)  -- phi itself isn't .untl X Y
    (h_contains : contains_untl_deep phi X Y)
    (h_depth_ge : U_nesting_depth phi >= 2) :
    U_nesting_depth (abstract_untl phi X Y p) < U_nesting_depth phi
```

where `contains_untl_deep` is a new predicate that recurses through ALL constructors including `.untl` args.

**Difficulty**: Medium-High. The argument is clear but the induction structure is tricky because `U_nesting_depth` takes the `max` of branches, and we need to reason about which branch achieves the maximum.

### Strategy B: Use `count_U_subformulas` decrease (existing infrastructure)

The current proof already has a `count_U_subformulas` inner induction. The issue is that `contains_untl_surface` doesn't work for nested `.untl`. But `count_U_subformulas` counts `.untl` at the surface only (not recursing into `.untl` args). So abstracting a nested `.untl X Y` does NOT decrease `count_U_subformulas` of the top formula.

Wait, let me re-examine. `count_U_subformulas` (line 365-371):
```lean
| .untl _ _ => 1  -- does NOT recurse
```

`abstract_untl phi X Y p` on the outer `.untl a b` (where `a != X || b != Y`): it recurses into args and replaces inner `.untl X Y`. The outer `.untl` remains but its args change. The count of the outer `.untl` is still 1, so `count_U_subformulas` of the whole formula doesn't change through this outer `.untl`.

So `count_U_subformulas` does NOT detect the removal of a nested `.untl`. This strategy doesn't directly work.

### Strategy C: Use a deeper count measure

Define `total_untl_count` that counts ALL `.untl` nodes including nested ones:
```lean
def total_untl_count : Formula -> Nat
| .atom _ => 0
| .bot => 0
| .imp a b => total_untl_count a + total_untl_count b
| .box a => total_untl_count a
| .untl a b => 1 + total_untl_count a + total_untl_count b
| .snce a b => total_untl_count a + total_untl_count b
```

Then `abstract_untl phi X Y p` strictly reduces `total_untl_count` when `phi` contains `.untl X Y` at any depth. This gives a decreasing measure for the inner induction.

But we still need `U_nesting_depth` to decrease for the outer IH dispatch (deciding whether to use `lemma_10_2_6_self_contained` or recurse). The approach would be: use `total_untl_count` as the well-founded measure instead of `count_U_subformulas`.

### Strategy D (Recommended): Restructure to avoid strict decrease

The simplest approach is to restructure `no_S_nested_in_U_separable_direct` so the depth >= 2 case ALWAYS extracts a U-free `.untl` and thus NEVER hits the `all_separable` fallback:

1. Replace `extract_U_type` with `extract_innermost_U_type` in the proof
2. The innermost extraction ALWAYS returns U-free args (by construction)
3. The `by_cases hAB_uf` split always takes the U-free branch
4. The non-U-free branch becomes dead code (can be removed)

**For this to work**, we need `contains_untl_surface phi X Y` to hold (required by `abstract_untl_count_lt_of_contains_surface` for count decrease in the inner induction).

**Problem**: The innermost `.untl X Y` may NOT satisfy `contains_untl_surface phi X Y` (surface containment). It's nested inside another `.untl`.

**Solution**: Define a new `contains_untl_anywhere` predicate:
```lean
def contains_untl_anywhere : Formula -> Formula -> Formula -> Prop
| .atom _, _, _ => False
| .bot, _, _ => False
| .imp c d, A, B => contains_untl_anywhere c A B \/ contains_untl_anywhere d A B
| .box c, A, B => contains_untl_anywhere c A B
| .untl c d, A, B => (c = A /\ d = B) \/
    contains_untl_anywhere c A B \/ contains_untl_anywhere d A B
| .snce c d, A, B => contains_untl_anywhere c A B \/ contains_untl_anywhere d A B
```

Then prove:
```lean
theorem abstract_untl_total_count_lt_of_contains_anywhere
    (phi A B : Formula) (p : Atom)
    (h : contains_untl_anywhere phi A B) :
    total_untl_count (abstract_untl phi A B p) < total_untl_count phi
```

And use `total_untl_count` as the inner induction measure instead of `count_U_subformulas`.

## 4. Does `no_S_nested_in_U` Give S-Free Args for Innermost `.untl`?

**Yes.** `no_S_nested_in_U (.untl a b)` requires `is_S_free a = true /\ is_S_free b = true`. So every `.untl` node in a formula satisfying `no_S_nested_in_U` has S-free args.

When `extract_innermost_U_type` descends into `.untl a b`'s args, it needs `no_S_nested_in_U a` (or `b`) to recurse. As noted above, `is_S_free a = true` implies `no_S_nested_in_U a` (S-free formulas trivially have no S nested in U). The helper lemma `S_free_implies_no_S_nested` bridges this.

So the innermost `.untl X Y` found will have both U-free AND S-free args, which is exactly what `subst_in_separated_separable_depth` requires.

## 5. Recommended Implementation Plan

### Phase 4.2a: Definitions and Helper Lemmas (~60 LOC)

1. **`S_free_implies_no_S_nested`** (~15 LOC): Structural induction proving S-free implies no_S_nested_in_U. Simple.

2. **`contains_untl_anywhere`** (~10 LOC): Predicate that recurses into `.untl` args unlike `contains_untl_surface`.

3. **`total_untl_count`** (~10 LOC): Deep `.untl` count that recurses into `.untl` args.

4. **`extract_innermost_U_type`** (~25 LOC): The function itself, following the algorithm in Section 2.

### Phase 4.2b: Properties of `extract_innermost_U_type` (~60 LOC)

1. **`extract_innermost_U_type_U_free`** (~15 LOC): Args are U-free. By construction.
2. **`extract_innermost_U_type_S_free`** (~15 LOC): Args are S-free. From `no_S_nested_in_U`.
3. **`extract_innermost_U_type_contains_anywhere`** (~15 LOC): The pair occurs in the formula (deep containment).
4. **`abstract_untl_total_count_lt_of_contains_anywhere`** (~15 LOC): `total_untl_count` strictly decreases.

### Phase 4.2c: Rewrite `no_S_nested_in_U_separable_direct` (~80 LOC)

Replace the inner induction measure from `count_U_subformulas` to `total_untl_count`. Replace `extract_U_type` with `extract_innermost_U_type`. Remove the `by_cases hAB_uf` split -- the innermost extraction always gives U-free args. Eliminate the `all_separable` fallback entirely.

### Total Estimated LOC: ~200 (new definitions + properties + rewritten proof)

### Complexity Assessment

- `S_free_implies_no_S_nested`: Low -- standard structural induction
- `extract_innermost_U_type`: Medium -- needs careful handling of the `.untl` case to pass `no_S_nested_in_U` through S-free args
- Properties (U-free, S-free, containment): Low-Medium -- follow construction
- `abstract_untl_total_count_lt_of_contains_anywhere`: Medium -- structural induction, `.untl` case needs care with the match/non-match split
- Main proof rewrite: Medium -- structurally similar to existing proof but uses different extraction and measure

**Main risk**: The `abstract_untl` strict decrease for `total_untl_count` at the `.untl` case requires reasoning about whether `psi1 = A /\ psi2 = B` holds. In the matching case, a `.untl` is removed (replaced by atom, count goes from `1 + ... ` to `0`). In the non-matching case, the `.untl` remains but abstraction recurses into its args, so if `contains_untl_anywhere` holds for a child, the count still strictly decreases.

## 6. Alternative: Keep `count_U_subformulas` Inner Induction

An alternative that avoids introducing `total_untl_count` and `contains_untl_anywhere`:

At depth >= 2, use the OUTER `U_nesting_depth` IH directly (not the inner count IH). The key:
1. `extract_innermost_U_type` returns U-free `.untl X Y`
2. `abstract_untl phi X Y p` has `U_nesting_depth` strictly less (Strategy A from Section 3)
3. Apply the outer depth IH directly: `ih_depth (U_nesting_depth phi - 1) (...) phi' (...) hns'`
4. No need for inner count induction at all in the depth >= 2 case

This simplifies the proof structure but requires the strict `U_nesting_depth` decrease lemma (Strategy A), which is the hardest part.

**Recommendation**: Try Strategy A first (direct `U_nesting_depth` strict decrease). If it proves too difficult after 2 hours, fall back to Strategy D (`total_untl_count` measure).
