# WellFounded.fix for c5_forward_walk: Feasibility Assessment

## Problem Summary

The `c5_forward_walk` function (line 683 of `CounterexampleElimination.lean`) performs well-founded recursion on `(χ.dom.filter (fun v => v > pt)).card`. The current `termination_by`/`decreasing_by` approach fails because the WF elaborator duplicates let-bindings with daggers when the recursive result `r` is used inside a proof closure (`witness_guard`, lines 924-949).

### Root Cause Analysis

The `decreasing_by` block generates **3 goals** (confirmed via `lean_goal`):

1. **Goal 1** (direct recursive call): Closable by `h_term` after `simp_all only [gt_iff_lt]`. The goal mentions `{v ∈ χ.dom | pt < v}.min'` which is definitionally equal to `x'`.

2. **Goal 2** (from `witness_guard` proof, caller frame): Has **two sets of variables** -- `pt✝` (outer/caller) and `pt` (inner/callee, rebound by the WF elaborator). The goal is:
   ```
   ⊢ {v ∈ χ.dom | T_succ.min' hT_ne < v}.card < {v ∈ χ.dom | pt✝ < v}.card
   ```
   The available `h_term✝` hypothesis talks about `x'✝` and `pt✝`, but `T_succ` is from the callee's frame (bound to a potentially different `pt`). These are **propositionally but not definitionally equal**, so neither `exact h_term✝` nor `assumption` works. Moreover, `h_term✝` is inaccessible (dagger name).

3. **Goal 3** (from `witness_guard` proof, another duplication): Similar structure, closable by `simp_all`.

Currently: `all_goals (first | exact h_term | sorry)` leaves goal 2 with a `sorry`.

### Why Standard Workarounds Fail

- **`assumption`**: Tries all hypotheses but fails because types don't definitionally unify (`pt` vs `pt✝` are distinct local constants).
- **`simp_all`**: Normalizes `>` to `<` but cannot bridge the variable identity gap.
- **`convert h_term using N`**: Could theoretically work but `h_term` (non-daggered) references the callee's `pt`, while the goal references `pt✝`. The daggered `h_term✝` is inaccessible.
- **Restructuring proof order**: Moving `witness_guard` proof to a `have` before the structure literal doesn't help -- the WF elaborator still processes the recursive call `have r := c5_forward_walk ...` and creates the duplicated context whenever `r` appears in downstream proofs.

## WellFounded.fix API

```lean
@WellFounded.fix : {α : Sort u} → {C : α → Sort v} → {r : α → α → Prop}
  → WellFounded r → ((x : α) → ((y : α) → r y x → C y) → C x) → (x : α) → C x
```

Key points:
- `α` = the type we recurse on (a bundle of changing arguments)
- `C` = the return type, indexed by `α`
- `r` = the well-founded relation
- The `F` parameter takes `x : α` and `rec : (y : α) → r y x → C y`
- The `rec` function IS the recursive call -- you provide the termination proof inline
- **No `termination_by`/`decreasing_by` needed at all**

### Tactic Mode Confirmed Working

```lean
noncomputable def testFix : Nat → Nat :=
  WellFounded.fix Nat.lt_wfRel.wf fun n rec => by
    -- Full tactic mode works inside WellFounded.fix!
    exact if h : n = 0 then 1
    else rec (n - 1) (Nat.sub_lt (Nat.pos_of_ne_zero h) Nat.one_pos) + 1
```

This compiles and evaluates correctly. The `by` block has full access to tactic mode.

## Concrete Implementation Plan

### Step 1: Define the Argument Bundle

The function has:
- **Fixed arguments**: `χ`, `h_c0`, `h_c2'`, `h_nubr3`, `ξ`, `η`
- **Varying arguments**: `pt`, `h_start_mem`, `h_until_start`, `h_no_wit`

```lean
-- Bundle type (implicit, inline)
-- Args := (pt : Rat) ×' (pt ∈ χ.dom) ×' (untl ξ η ∈ χ.f pt) ×' (¬∃ ...)
```

### Step 2: Define Measure and WF Proof

```lean
private noncomputable def c5_forward_walk
    (χ : Chronicle) (h_c0 : χ.c0) (h_c2' : χ.c2')
    (h_nubr3 : NoUnivBurgessR3)
    (ξ η : Formula) (pt : Rat)
    (h_start_mem : pt ∈ χ.dom)
    (h_until_start : Formula.untl ξ η ∈ χ.f pt)
    (h_no_wit : ¬∃ y ∈ χ.dom, pt < y ∧ η ∈ χ.f y ∧
      (∀ a b, Adjacent χ.dom a b → pt ≤ a → b ≤ y → ξ ∈ χ.g a b)) :
    C5ForwardWalkResult χ ξ η pt :=
  let Args := (p : Rat) ×' (p ∈ χ.dom) ×' (Formula.untl ξ η ∈ χ.f p) ×'
    (¬∃ y ∈ χ.dom, p < y ∧ η ∈ χ.f y ∧
      (∀ a b, Adjacent χ.dom a b → p ≤ a → b ≤ y → ξ ∈ χ.g a b))
  let measure : Args → Nat := fun ⟨p, _, _, _⟩ => (χ.dom.filter (· > p)).card
  let wf : WellFounded (InvImage (· < ·) measure) := InvImage.wf measure Nat.lt_wfRel.wf
  (WellFounded.fix wf fun ⟨pt, h_start_mem, h_until_start, h_no_wit⟩ rec => by
    -- ENTIRE existing tactic body goes here, unchanged except for the recursive call
    -- ...
  ) ⟨pt, h_start_mem, h_until_start, h_no_wit⟩
```

### Step 3: Replace Recursive Call

**Current** (line 912):
```lean
have r := c5_forward_walk χ h_c0 h_c2' h_nubr3 ξ η x' hx'_dom h_untl_x' h_no_wit_x'
```

**New**:
```lean
have r := rec ⟨x', hx'_dom, h_untl_x', h_no_wit_x'⟩ h_term
```

Where `h_term` is the existing proof that `(χ.dom.filter (· > x')).card < (χ.dom.filter (· > pt)).card`. This proof already exists at line 901-910 and stays unchanged.

### Step 4: Remove termination_by/decreasing_by

Delete lines 1170-1181 entirely.

## Changes Summary

| Component | Action | Lines |
|-----------|--------|-------|
| Function signature | Unchanged | 683-691 |
| WellFounded.fix wrapper | Add ~8 lines | New, around line 691 |
| Base case (pt = max) | Unchanged | 699-831 |
| Recursive call site | Change 1 line | 912 |
| Structure literal with witness_guard | Unchanged | 914-955 |
| Not-condition-(i) branch | Unchanged | 956-1169 |
| termination_by/decreasing_by | Delete | 1170-1181 |
| Closing parenthesis + bundle application | Add 1 line | New, after body |

**Total**: ~10 lines changed/added, ~12 lines deleted, ~480 lines of tactic proof unchanged.

## Pros and Cons

### Pros
1. **Eliminates the sorry** -- the WF elaborator duplication bug is completely bypassed
2. **Minimal diff** -- only ~10 lines of actual code change; the 480-line tactic body stays intact
3. **Clean API** -- external callers see no change; the function signature is identical
4. **Explicit termination proof** -- `h_term` is provided inline at the call site, no elaborator magic
5. **Future-proof** -- this pattern is robust against Lean version changes that might affect the WF elaborator
6. **Tactic mode preserved** -- the `by` block inside `WellFounded.fix` supports full tactic mode

### Cons
1. **Slightly unconventional** -- most Lean 4 code uses `termination_by`/`decreasing_by` rather than explicit `WellFounded.fix`
2. **PSigma bundle** -- the argument packing adds a small indirection; destructuring at the top of the body is required
3. **Unfolding lemma** -- if anyone needs `c5_forward_walk` to unfold for equational reasoning, `WellFounded.fix_eq` must be used manually instead of the auto-generated `c5_forward_walk.eq_1` etc.
4. **Slightly harder to modify** -- adding new varying arguments requires updating the bundle type

### Risk Assessment
- **Low risk**: The pattern is well-established in Lean 4 core (`WellFounded.fix` is what `termination_by` compiles to internally)
- **No sorry**: This approach produces zero sorries
- **Build impact**: None; `c5_forward_walk` is `private`, so no downstream API changes

## Alternative Approaches Considered

### Alternative 1: Fix decreasing_by with `convert`/`congr`
Could theoretically bridge the `pt` vs `pt✝` gap, but:
- Daggered hypotheses are inaccessible by name
- Would require knowing the exact elaborator-generated goal structure
- Brittle: any change to the function body could change the goal numbering

### Alternative 2: Restructure to avoid proof closure nesting
Extract `witness_guard` proof to a `have` before the structure literal. Tested on a toy example but:
- The WF elaborator may still enter the `have` proof since `r` appears there
- Not guaranteed to fix the real issue
- Requires understanding exactly which proof closures trigger duplication

### Alternative 3: Use `Nat.strongRecOn` 
Works for simple cases but:
- Motive is indexed by Nat, not by `pt`, making the connection awkward
- Would require threading `pt` separately from the recursion structure
- More boilerplate than `WellFounded.fix`

## Estimated Effort

- **Implementation**: 30-60 minutes for a careful developer
- **Testing**: `lake build` should be sufficient; no new test infrastructure needed
- **Review**: Low complexity; the diff is small and the pattern is standard

## Recommendation

**Use `WellFounded.fix`**. It is the cleanest, most reliable, and lowest-risk approach to eliminating the sorry in `decreasing_by`. The implementation is mechanical (10 lines changed), preserves the entire existing proof body, and completely bypasses the WF elaborator bug.
