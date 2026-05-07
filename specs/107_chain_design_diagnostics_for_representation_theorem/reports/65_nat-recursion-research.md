# Nat Structural Recursion for c5_forward_walk: Feasibility Assessment

**Task**: 107
**Date**: 2026-05-06
**Scope**: Evaluate restructuring `c5_forward_walk` to use Nat structural recursion instead of `termination_by`/`decreasing_by`

## Current Status: Sorry Already Eliminated

The sorry in `c5_forward_walk`'s `decreasing_by` block has been **already closed** (commit `3ae921437`). The fix was changing the recursive call from `let r` to `have r`, which makes the result opaque and prevents the WF elaborator from duplicating let-bindings with daggers (`pt†` vs `pt`). The current `decreasing_by` block (lines 1171-1176) closes successfully with:

```lean
decreasing_by
  all_goals simp_all only [gt_iff_lt]
  all_goals exact h_term
```

Verified: `lean_goal` at line 1176 shows `goals_after: []` (proof complete). No sorry remains in the file.

## Nat Recursion Pattern: Feasibility Analysis

### Pattern Description

Replace the current WF recursion:
```lean
private noncomputable def c5_forward_walk (χ : Chronicle) ... (pt : Rat) ... :
    C5ForwardWalkResult χ ξ η pt := by
  ...
  have r := c5_forward_walk χ h_c0 h_c2' h_nubr3 ξ η x' hx'_dom h_untl_x' h_no_wit_x'
  ...
termination_by (χ.dom.filter (fun v => v > pt)).card
decreasing_by ...
```

With Nat structural recursion:
```lean
private noncomputable def c5_forward_walk (χ : Chronicle) ... (pt : Rat) ...
    (n : Nat) (hn : (χ.dom.filter (· > pt)).card ≤ n) :
    C5ForwardWalkResult χ ξ η pt := by
  induction n generalizing pt with
  | zero => -- base: no points after pt (filter empty)
  | succ m ih => -- find x', show card(filter(> x')) ≤ m, call ih
```

### Verified: Pattern Works in Lean 4

Tested with standalone snippets confirming:

1. **`induction n generalizing pt` works correctly**: Lean properly generalizes `pt` and all pt-dependent hypotheses (`h_start_mem`, `h_until_start`, `h_no_wit`, `hn`) while keeping `χ`, `h_c0`, `h_c2'`, `h_nubr3`, `ξ`, `η` fixed.

2. **IH has the right shape**:
   ```
   ih : ∀ (pt : Rat), pt ∈ χ.dom → untl ξ η ∈ χ.f pt → ¬∃ ... →
        (χ.dom.filter (· > pt)).card ≤ m → C5ForwardWalkResult χ ξ η pt
   ```

3. **Return type parametrized by `pt` is compatible**: `ih x' ...` gives `C5ForwardWalkResult χ ξ η x'`, which the existing composition code (lines 914-955) already transforms to `C5ForwardWalkResult χ ξ η pt`.

4. **`≤` variant (not `=`) is recommended**: With `n = card`, `omega` cannot derive `m = card(filter(> x'))` from `m+1 = card(filter(> pt))` and `card(filter(> x')) < card(filter(> pt))` (the gap could be > 1 in principle, though here it's always exactly 1). Using `card ≤ n` instead, `omega` easily derives `card(filter(> x')) ≤ m` from `card(filter(> x')) < card(filter(> pt))` and `card(filter(> pt)) ≤ m+1`.

5. **Base case (n=0)**: When `card = 0`, the filter is empty so no points exist after `pt`. Combined with `pt ∈ dom`, this means `pt = max(dom)`. This is exactly the existing base case at line 698 (`by_cases h_eq_max : pt = max_old`).

### Key Proof Obligation in Succ Case

The critical step remains the same as the current code:

```lean
have h_card_lt : (χ.dom.filter (· > x')).card < (χ.dom.filter (· > pt)).card := by
  apply Finset.card_lt_card
  -- filter(> x') ⊂ filter(> pt) since x' ∈ filter(> pt) \ filter(> x')
```

This proof already exists at lines 901-910 and would be reused verbatim. The new step is just `omega` to derive `card ≤ m` from `card < card(filter(> pt)) ≤ m+1`.

### Call Site Impact

One call site at line 1400:
```lean
let r := c5_forward_walk χ h_c0 h_c2' h_nubr3 pc.ξ pc.η pc.x h_mem h_until h_no_wit
```

Would become:
```lean
let r := c5_forward_walk χ h_c0 h_c2' h_nubr3 pc.ξ pc.η pc.x h_mem h_until h_no_wit
    (χ.dom.filter (· > pc.x)).card le_rfl
```

Minimal impact: add the card value and `le_rfl` proof.

## Comparison: Nat Pattern vs Current WF Approach

| Criterion | Current WF (have r) | Nat Structural Recursion |
|-----------|---------------------|--------------------------|
| **Sorry-free** | Yes (already fixed) | Yes (verified) |
| **Lines of code** | ~490 lines (683-1176) | ~500 lines (slightly more) |
| **Robustness** | Fragile: `have` vs `let` matters for WF elaborator | Robust: no WF elaborator involvement |
| **Future maintenance** | Risk: touching the recursive call or nearby code could re-trigger dagger issue | Safe: Nat recursion is structural, no elaborator surprises |
| **Readability** | Natural recursive call syntax | Extra `n`/`hn` parameters, but clear pattern |
| **Call sites** | No extra params | Need `card` + `le_rfl` at each call |
| **Lean version dependence** | WF elaborator behavior could change across versions | Nat recursion is foundational, stable |
| **Compilation speed** | WF elaboration can be slow | Structural recursion is faster to check |
| **Mathlib precedent** | WF recursion is standard in Mathlib | Nat fuel pattern is folklore, not canonical |

## Pros of Nat Pattern

1. **Eliminates WF elaborator fragility**: The `have` vs `let` distinction is subtle and undocumented. Future refactoring could accidentally reintroduce the dagger issue.
2. **Faster compilation**: Structural recursion avoids WF elaboration overhead.
3. **Simpler termination proofs**: No `decreasing_by` block needed at all. The `omega` call in the succ case is trivial.
4. **Predictable behavior**: No risk of the WF elaborator generating unexpected goals.

## Cons of Nat Pattern

1. **Already working**: The current code has no sorry. This would be pure refactoring.
2. **Extra parameters**: Adds `(n : Nat) (hn : ... ≤ n)` to the signature, slightly noisier.
3. **Not idiomatic Mathlib**: Mathlib prefers `termination_by` for WF recursion. Using the Nat pattern deviates from community conventions.
4. **Refactoring risk**: The function is 490 lines of working proof. Any change risks introducing new bugs.
5. **Call site changes**: Each caller needs updated to pass the extra arguments.

## Recommendation

**Do not refactor**: The sorry has already been eliminated. The `have r` fix is minimal, documented in a comment (lines 1172-1174), and working. The Nat pattern would be a defensive refactor that trades one kind of fragility (WF elaborator) for another (non-standard calling convention). The risk-to-benefit ratio does not justify the change.

**When Nat pattern IS recommended**: If a future WF function encounters the dagger issue and the `have` trick does not work (e.g., because the recursive call appears in a position where `have` cannot be used), the Nat structural recursion pattern is a proven fallback. The pattern sketch in this report provides a ready template.

## Estimated Effort (if refactoring were undertaken)

- **Signature change**: 30 minutes (add `n`, `hn`, change def header to `induction n generalizing pt`)
- **Base case**: 30 minutes (merge the `n=0` case with the existing `pt = max_old` case, need to prove `pt = max_old` from `card = 0`)
- **Succ case**: 2 hours (restructure the case split, `by_cases hT_empty` for when card is 0 even though n > 0, pass `omega`-derived bound to IH)
- **Call site**: 15 minutes (add `card` and `le_rfl`)
- **Remove termination_by/decreasing_by**: 5 minutes
- **Testing**: 1 hour (full build, check all downstream)
- **Total**: ~4 hours

## Code Sketch (for reference)

```lean
private noncomputable def c5_forward_walk
    (χ : Chronicle) (h_c0 : χ.c0) (h_c2' : χ.c2')
    (h_nubr3 : NoUnivBurgessR3)
    (ξ η : Formula) (pt : Rat)
    (h_start_mem : pt ∈ χ.dom)
    (h_until_start : Formula.untl ξ η ∈ χ.f pt)
    (h_no_wit : ¬∃ y ∈ χ.dom, pt < y ∧ η ∈ χ.f y ∧
      (∀ a b, Adjacent χ.dom a b → pt ≤ a → b ≤ y → ξ ∈ χ.g a b))
    (n : Nat) (hn : (χ.dom.filter (· > pt)).card ≤ n) :
    C5ForwardWalkResult χ ξ η pt := by
  induction n generalizing pt with
  | zero =>
    -- card ≤ 0 means filter is empty, so pt = max(dom)
    have h_dom_ne : χ.dom.Nonempty := ⟨pt, h_start_mem⟩
    have h_eq_max : pt = χ.dom.max' h_dom_ne := by
      have h_filter_empty : χ.dom.filter (· > pt) = ∅ := by
        rwa [Finset.card_eq_zero] at hn  -- card ≤ 0 → card = 0 → empty
      ... -- existing base case proof (lines 699-831)
  | succ m ih =>
    have h_dom_ne : χ.dom.Nonempty := ⟨pt, h_start_mem⟩
    set max_old := χ.dom.max' h_dom_ne
    by_cases h_eq_max : pt = max_old
    · -- pt = max: same base case (filter is empty even with n > 0)
      ... -- existing base case proof
    · -- pt < max: find successor x'
      ... -- existing recursive case setup (lines 832-910)
      -- Key change: use ih instead of c5_forward_walk
      have h_card_lt : (χ.dom.filter (· > x')).card < (χ.dom.filter (· > pt)).card := by
        ... -- existing proof (lines 901-910)
      have r := ih x' hx'_dom h_untl_x' h_no_wit_x' (by omega)
      ... -- existing composition (lines 914-955)
      -- Not-condition(i) case: no recursion, same as current
      ... -- existing splitting case (lines 956-1169)
-- NO termination_by needed!
```
