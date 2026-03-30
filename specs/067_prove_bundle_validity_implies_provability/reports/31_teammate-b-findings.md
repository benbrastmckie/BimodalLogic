# Alternative Approaches Analysis: Task 67

**Session**: Research (lean-research-agent)
**Date**: 2026-03-29
**Focus**: Non-fuel alternatives for proving termination in bounded witness lemmas

---

## Summary

Four sorry sites exist in `SuccChainFMCS.lean` (lines ~2909, ~5523, ~5681, ~5877), all in
`fuel=0` base cases of recursive bounded-witness lemmas. These cases are semantically
unreachable when called with initial fuel `B*B+1` where `B = closure_F_bound phi`, but
Lean cannot verify this without an explicit termination argument.

Multiple approaches have been tried and failed. This report evaluates fresh alternatives
beyond fuel, focusing on feasibility and zero-debt compliance.

---

## Root Cause Summary

All four functions have this structure:

```
private theorem xxx_fueled ... (fuel : Nat) ... :=
  match fuel with
  | 0 =>
    match d with
    | 0 => exact absurd h_d_ge (by omega)  -- OK
    | _ + 1 => exact ⟨..., by sorry⟩      -- THE SORRY: fuel exhausted, d >= 1
  | fuel' + 1 =>
    -- recursive case, calls xxx_fueled ... fuel' ...
termination_by fuel
```

The recursive case decreases `fuel` by 1 each step, but also resets depth `d`:
- Old depth: `n + 1`
- New depth after resolve: `d' + (n - 1)` where `d' >= 1`, potentially `>= n + 1`

This is why naive well-founded recursion on `(k, d)` fails: the second component can
increase when the first increases. The budget `B*B` bounds total work but is not tracked.

---

## Alternative 1: Nested Strong Induction (levels x depth)

**Description**: Replace the single fuel parameter with nested induction:
- Outer induction on `levels_remaining : Nat` (number of F's still to peel off)
- Inner induction on `defers_at_current_level : Nat` (bounded by B)

At each **resolve** step: outer count decreases (one F peeled), inner resets freely.
At each **defer** step: inner count decreases, outer unchanged.

```lean
-- Proof structure
private theorem restricted_bounded_witness_nested (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (levels_remaining : Nat)  -- outer bound: remaining F-levels to peel
    (h_d_ge : d ≥ 1)
    (h_d_le : d ≤ levels_remaining)  -- d bounded by levels_remaining
    ...
    -- inner induction via recursion on d when level doesn't change
termination_by (levels_remaining, d)
decreasing_by
  -- resolve case: (levels_remaining, d) -> (levels_remaining - 1, d')
  -- since levels_remaining decreases strictly, this is lex-less
  simp_wf; left; omega
  -- defer case: (levels_remaining, d) -> (levels_remaining, d' + k) where d' + k < d
  -- if d'+k < d, then lex-less (same first component, smaller second)
  simp_wf; right; constructor <;> omega
```

**The key invariant**: Need `d ≤ levels_remaining` maintained through recursion.
- Initially: `levels_remaining = d` (exact match)
- After resolve to `k+1` with new boundary `d'`: call with `levels_remaining' = levels_remaining - 1`, `d'' = d' + (n-1)`, need `d'' ≤ levels_remaining'`
  - `d'' = d' + (n-1) ≤ (B-1) + (n-1) ≤ B + n - 2`
  - `levels_remaining' = levels_remaining - 1`
  - **Problem**: If `d' = B-1` and `n = levels_remaining`, then `d'' = B-1 + levels_remaining - 1 >> levels_remaining - 1`
  - The invariant `d ≤ levels_remaining` is NOT preserved

**Verdict**: This approach doesn't work without a fundamentally different invariant.

- **Effort**: 4-6 hours
- **Feasibility**: low (invariant breaks)
- **Pros**: Conceptually clean, Lean's lexicographic termination handles it if invariant holds
- **Cons**: Invariant `d ≤ levels` not preserved through recursion due to depth reset

---

## Alternative 2: Induction on Total Formula Complexity Budget

**Description**: Use a single `budget : Nat` parameter where:
- `budget` tracks total remaining complexity, not just recursion count
- Decrease by `d` (current depth) at each recursive call

The total initial budget would be `B * B` since:
- Each recursive step processes depth `d >= 1`
- Depth bounded by `B` at each chain position
- Chain positions bounded by `B`
- Total: `B * B` steps max

```lean
private theorem restricted_bounded_witness_budgeted (phi : Formula)
    ... (budget : Nat)
    (h_budget : budget ≥ d)  -- invariant: budget >= current depth
    ...
termination_by budget
```

**At each recursive step**:
- Resolve: old depth `n+1`, new depth `d' + (n-1)`. Budget decreases by 1 minimum.
  But new budget must be `>= d' + (n-1)`. With `budget' = budget - 1`:
  - Need: `budget - 1 >= d' + (n-1)`, i.e., `budget >= d' + n`
  - But `d' <= B-1` and `n <= B`, so `d' + n <= 2B - 1`, not `<= budget - 1`
  - **This doesn't work either**: budget decreases by 1 but new depth can be large

**Revised**: Use `budget = closure_F_bound phi * closure_F_bound phi` and decrease by `d` at each step.

```lean
-- Decrease by d (the current depth contribution) at each recursive call
-- After resolve: consume 'n+1' (old depth) and start with d' + (n-1) for new position
-- Total consumed: n+1 + (d' + n - 1) + ... bounded by B*B
```

But tracking this requires knowing the actual decrease formula, which requires proving
`d' ≤ B - 1` (true by DRM bound), then the total decrease per "chain position visit" is:
`sum of d values` = `B` per position, `B` positions = `B*B` total.

**Feasibility Note**: This would require proving the intermediate budget bound at each call
site, which is essentially as hard as the fuel-sufficient invariant (Report 24, Approach 1).

- **Effort**: 6-10 hours
- **Feasibility**: medium (with effort)
- **Pros**: Clean termination argument, no unreachable cases
- **Cons**: Requires threading complex invariant; essentially the same approach as fuel-sufficient

---

## Alternative 3: Structural Coinduction / Acc-based Recursion

**Description**: Use Lean's `WellFounded.fix` / `Acc.intro` directly with an
explicit accessibility proof, bypassing `termination_by`.

The idea is to prove `Acc (lexOrd) (k, d)` for all reachable `(k, d)` pairs:

```lean
-- Define the ordering on (chain_pos, depth) pairs
def witness_order (phi : Formula) : (Nat × Nat) → (Nat × Nat) → Prop :=
  fun (k', d') (k, d) =>
    k' < k ∨ (k' = k ∧ d' < d)

-- Prove it's well-founded (it's the standard lex order on Nat × Nat)
theorem witness_order_wf (phi : Formula) : WellFounded (witness_order phi) :=
  WellFounded.prod_lex Nat.lt_wfRel.wf Nat.lt_wfRel.wf

-- Use it directly
private theorem restricted_bounded_witness_acc (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (h_acc : Acc (witness_order phi) (k, d))  -- explicit accessibility
    (h_d_ge : d ≥ 1) ... :
    ∃ m > k, theta ∈ restricted_forward_chain phi M0 m := by
  induction h_acc with
  | intro (k, d) h_acc IH =>
    ...
    -- In resolve case with new (k+1, d' + n - 1):
    -- Need: witness_order phi (k+1, d' + n - 1) (k, d)
    -- This means k+1 > k OR (k+1 = k AND ...) -> first branch: k < k+1 ✓
    -- So Acc holds for (k+1, d' + n - 1) too (by downward closure)
    -- Apply IH
    apply IH (k+1, d' + n - 1) _
    · left; omega  -- k < k+1
    · ...
```

**Why this works**: The accessibility proof for `(k, d)` in the lex order on `Nat × Nat`
exists for all pairs (since the lex order on `Nat × Nat` is well-founded). When we
recurse with `(k+1, d')`, we have `k+1 > k`, so `(k+1, d')` is LESS than `(k, d)` in
the lex ordering (first component is LARGER, but lex ordering uses SMALLER for accessibility).

Wait — this reveals the confusion. Standard lex ordering has `(a', b') < (a, b)` when
`a' < a` OR (`a' = a` AND `b' < b`). So for the recursive call to move to `(k+1, d')`,
we need `(k+1, d') < (k, d)`, which requires `k+1 < k` — FALSE.

**Correct interpretation**: The "progress" is that we're moving to a LARGER position.
The accessibility must be for the REVERSE direction. We need to prove the theorem holds
for all `(k, d)` above (or equal to) some starting point. Upward accessibility.

For upward induction: use `Nat.Up.WF` or `Nat.upRel` from Mathlib. This handles
induction where the variable INCREASES up to a bound.

```lean
-- Use upward well-founded relation
-- termination_by (B*B - k, d) where B*B is the absolute bound
```

This is EXACTLY the approach in Plan v10 (Phase 2), which is currently blocked.

- **Effort**: 6-8 hours
- **Feasibility**: medium
- **Pros**: Standard mathematical pattern; no fuel needed
- **Cons**: Plan v10 shows this approach is blocked because `d` can increase when `k` increases

---

## Alternative 4: Prove Total Steps Bounded, Then Use Fuel with Invariant

**Description**: Instead of restructuring the recursion, add a single invariant that
directly refutes the `fuel=0` case:

```lean
-- Key theorem: if called with sufficient fuel, fuel=0 is never reached
-- before the witness is found.
lemma bounded_witness_fuel_always_positive (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d fuel : Nat)
    (h_d_ge : d ≥ 1)
    (h_d_lt : d < closure_F_bound phi)  -- DRM bound
    (h_fuel : fuel > (closure_F_bound phi - k) * closure_F_bound phi)
    ...
    (h_fuel_pos : fuel > 0) := by
  -- Prove by induction on the recursion structure
  -- Each step decreases (closure_F_bound phi - k) * closure_F_bound phi + d
  ...
```

The **key invariant**: `fuel > (B - k) * B` where `B = closure_F_bound phi` and `k` is
the current chain position. This invariant:
- Holds initially: `fuel = B*B+1 > (B - 0) * B = B*B` ✓
- After a forward step to `k+1` with new depth `d' + (n-1)`:
  - New fuel: `fuel - 1`
  - New bound: `(B - (k+1)) * B`
  - Need: `fuel - 1 > (B - k - 1) * B`
  - Since `fuel > (B - k) * B = (B - k - 1) * B + B`, we have `fuel >= (B - k - 1) * B + B + 1`
  - So `fuel - 1 >= (B - k - 1) * B + B >= (B - k - 1) * B + 1 > (B - k - 1) * B` ✓

**This invariant WORKS!** The invariant `fuel > (B - k) * B` is:
1. Initially satisfied: `B*B+1 > (B - 0)*B = B*B`
2. Preserved under forward steps: proved above
3. Implies `fuel > 0` when `k < B`: `fuel > (B-k)*B >= B > 0`

The `fuel=0` case needs: given `fuel = 0`, derive `False` from the invariant.
- From `fuel = 0` and `fuel > (B - k) * B`: `0 > (B - k) * B`
- This is false for `k <= B` (positive product), so we need `k > B` — which contradicts DRM depth bounds

**BUT**: The invariant also requires `k < B` to work. If `k >= B`, then `(B-k)*B = 0` (Nat subtraction), and `fuel > 0` doesn't follow. However:
- If `k >= B`, then by the DRM closure bound, no F-nesting formulas remain, so `d = 0`, contradicting `h_d_ge : d >= 1`
- This would make the fuel=0/d+1 case impossible via a different argument

**Implementation**: Add `h_inv : fuel > (closure_F_bound phi - k) * closure_F_bound phi` to the
fueled function signature. Prove it implies `fuel > 0`. The fuel=0 branch becomes:
```lean
| 0 =>
  | 0 => exact absurd h_d_ge (by omega)
  | n + 1 =>
    -- Use h_inv to derive contradiction
    have h_pos : fuel > 0 := Nat.lt_of_lt_of_le h_inv (by omega)
    exact absurd rfl (Nat.not_eq_zero_of_lt h_pos)
    -- OR: have h_contra : 0 > (closure_F_bound phi - k) * closure_F_bound phi := h_inv
    --     exact absurd h_contra (by omega)  -- 0 > 0 is false when k < B
```

- **Effort**: 3-5 hours
- **Feasibility**: high (invariant works algebraically)
- **Pros**: Minimal restructuring; just adds one hypothesis to each fueled function; clean proof; works with existing recursion structure
- **Cons**: Need to prove invariant preserved at each recursive call (4 different functions × 2 recursive cases each); requires `k < closure_F_bound phi` side condition

---

## Alternative 5: Accept Semantically Sound Sorries (Explicitly Rejected)

**Description**: Document these 4 sorries as unreachable base cases, verify via
`#print axioms` that they do not contaminate the completeness path.

**Why Rejected**:
- Violates zero-debt completion gate
- `#print axioms bundle_validity_implies_provability` would show `sorryAx`
- Any future refactor might accidentally call the fueled functions with fuel=0

**Confidence**: Low — explicitly prohibited.

---

## Alternative 6: Non-Constructive Existence via Classical Reasoning

**Description**: Avoid the recursive construction entirely. Instead:
1. Prove the existence claim non-constructively: "the set of positions containing `theta`
   is unbounded above `k`"
2. Use `Nat.find` or classical choice to extract the witness

```lean
theorem restricted_bounded_witness (phi : Formula) ... :
    ∃ m > k, theta ∈ restricted_forward_chain phi M0 m := by
  -- Define the set of positions containing theta
  let S := {m : Nat | theta ∈ restricted_forward_chain phi M0 m}
  -- Prove S is infinite (non-constructive, uses DRM properties)
  have h_infinite : ∀ n, ∃ m ≥ n, m ∈ S := by
    intro n
    -- By DRM, for any n, theta eventually appears after n
    -- This follows from the F-iteration and DRM saturation properties
    ...
  obtain ⟨m, h_m_ge, h_m_in⟩ := h_infinite (k + 1)
  exact ⟨m, by omega, h_m_in⟩
```

**Why this might work**: The DRM properties guarantee that F-obligations are eventually
satisfied. We never need to construct the exact chain step where theta appears — we just
need existence. The recursive structure is only needed to BUILD the witness constructively,
but Lean's `Classical.choice` allows non-constructive existence.

**The bottleneck**: Proving `h_infinite` still requires the same termination argument, just
packaged differently. The DRM saturation is a property of the construction, so we still need
to trace through the chain to show theta eventually appears.

Unless... we can use an infinite pigeonhole / König's lemma argument: the F-nesting depth
is bounded, the chain is infinite, so by a counting argument, theta must appear.

**However**: The restricted chain construction is itself recursive, and its properties are
proved recursively. The bottleneck is in the chain construction properties, not in this
theorem.

- **Effort**: 8-12 hours
- **Feasibility**: low (moves the problem, doesn't solve it)
- **Pros**: No fuel parameter
- **Cons**: Need same termination argument at a deeper level

---

## Recommended Path

**Alternative 4 (Fuel Invariant `fuel > (B-k)*B`)** is the recommended approach.

### Why Alternative 4 Wins

1. **Mathematically correct**: The invariant `fuel > (closure_F_bound phi - k) * closure_F_bound phi`
   is algebraically valid and preserved at each recursive call.

2. **Minimal restructuring**: Keep the existing recursive proof structure. Only add:
   - One hypothesis `h_inv` to each of the 4 fueled functions
   - One call-site proof in each recursive case (that the invariant is preserved)
   - Change each `sorry` to a `contradiction` or `omega` using `h_inv`

3. **Clean proof for the wrapper**: The wrapper calls with `fuel = B*B+1`, and:
   ```lean
   h_inv : B*B+1 > (B - 0) * B  -- i.e., B*B+1 > B*B, true by omega
   ```

4. **No new mathematical content**: The invariant is purely arithmetic; it follows from
   standard `omega` reasoning about Nat subtraction.

5. **Each sorry site becomes 2-3 lines**: Instead of `by sorry`, write:
   ```lean
   | n + 1 =>
     exfalso
     have h_k_lt : k < closure_F_bound phi := by
       -- d >= 1 and d < B means we haven't exhausted the chain
       exact Nat.lt_of_le_of_lt (Nat.zero_le k) ...
     exact Nat.not_lt.mpr (Nat.zero_le _) h_inv
   ```

### Implementation Sketch for Alternative 4

**Step 1**: Add invariant hypothesis to `restricted_bounded_witness_wf`:
```lean
private theorem restricted_bounded_witness_wf (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (remaining_steps : Nat)
    (h_d_ge : d ≥ 1)
    (h_inv : remaining_steps > (closure_F_bound phi - k) * closure_F_bound phi)
    (h_iter_in : ...)
    (h_iter_not : ...) :
    ∃ m > k, theta ∈ restricted_forward_chain phi M0 m
```

**Step 2**: Eliminate sorries at `remaining_steps = 0`:
```lean
| 0 =>
  | 0 => exact absurd h_d_ge (by omega)
  | n + 1 =>
    -- h_inv : 0 > (closure_F_bound phi - k) * closure_F_bound phi
    -- Since d = n+1 >= 1 and d < B (from h_d_lt), k < B
    -- So (B - k) * B >= B > 0, but 0 > something >= 0 is False
    exact absurd h_inv (by
      have := restricted_forward_chain_depth_bounded ...
      omega)  -- 0 > positive * positive is False
```

**Step 3**: Maintain invariant in recursive calls:
```lean
| remaining' + 1 =>
  ...
  -- Recursive call at (k+1) with remaining':
  -- Need: remaining' > (B - (k+1)) * B
  -- From h_inv: remaining'+1 > (B-k)*B = (B-k-1)*B + B
  -- So: remaining' >= (B-k-1)*B + B - 1 >= (B-k-1)*B + 1 > (B-k-1)*B
  have h_inv' : remaining' > (closure_F_bound phi - (k + 1)) * closure_F_bound phi := by
    omega  -- after unfolding Nat.sub arithmetic
  exact restricted_bounded_witness_wf phi M0 (k+1) theta (d' + n) remaining'
    h_new_depth_ge h_inv' ...
```

**Note on Nat subtraction**: The arithmetic `(B - k - 1) * B = (B - (k+1)) * B` requires
careful handling of Nat subtraction when `k+1 > B`. However, when `k+1 > B`, the value
is 0, so `remaining' > 0` is still needed — which follows from `h_inv` and `B*B+1 > 0`.

**Step 4**: Update wrapper:
```lean
theorem restricted_bounded_witness ... :=
  let B := closure_F_bound phi
  have h_inv : B * B + 1 > (B - 0) * closure_F_bound phi := by simp; omega
  exact restricted_bounded_witness_wf phi M0 k theta d (B * B + 1)
    h_d_ge h_inv h_iter_in h_iter_not
```

### Alternative 4 for the Int-indexed variants

For `restricted_combined_bounded_witness_fueled` (Int-indexed), the invariant needs
adjustment. Position `n : Int` can be negative. Use `n.natAbs` or offset from origin:

```lean
-- For Int position n, define effective chain consumption
def chain_consumption (n : Int) (B : Nat) : Nat :=
  min n.natAbs B  -- bounded by B

-- Invariant: fuel > (B - chain_consumption n B) * B
```

The recursion moves from `n` to `n+1`, so `n.natAbs` changes by at most 1, and the
budget analysis is the same as for Nat positions.

---

## Confidence Level

**Medium-High** overall.

- The arithmetic invariant in Alternative 4 is correct (provable by `omega` with the right
  hypotheses about `d < B` and `k < B`).
- The main uncertainty is whether Lean's `omega` tactic handles the Nat subtraction
  arithmetic needed for the invariant preservation proof at each recursive call.
- The Int-indexed variants add complexity but are structurally similar.
- Estimated effort: 4-6 hours for all four functions.

### Risk Factors

1. **Nat subtraction edge cases**: `(B - k - 1) * B` vs `(B - (k+1)) * B` when `k >= B`
   requires careful case analysis. The tactic `omega` may need explicit case splits on
   `k < B`.

2. **Int-indexed chain positions**: The two combined-chain functions use `n : Int`, which
   complicates the `(B - k)` computation. Need to use `n.toNat` or `n.natAbs` with a
   proof that `n` is in range.

3. **Backward chain functions**: `restricted_backward_bounded_witness_fueled` uses `k : Nat`
   as a backward index, so the invariant structure is the same as the forward case.

4. **`restricted_combined_bounded_witness_P_fueled` goal structure**: This function proves
   `theta ∈ chain(n-1)` (not just `∃ m > n`), which may require slight adjustment to the
   invariant. The recursion structure is the same.

---

## Evidence from Prior Attempts

Prior attempts that provide useful evidence:

1. **Plan v10 (summaries/12_well-founded-summary.md)**: Attempted lexicographic `(k, d)`
   measure directly. Failed because `d` increases when `k` increases. The invariant approach
   sidesteps this by not relying on `d` decreasing.

2. **Report 24 (fuel-exhaustion research)**: Identified the fuel-invariant approach as
   promising but noted the invariant `fuel >= closure_F_bound phi` is insufficient. The
   correct invariant is `fuel > (B - k) * B`, which is stronger and preserved.

3. **Handoff 01 (termination analysis)**: Correctly identified Option A (fuel-based) as
   the recommended approach. The current blocking was from using `fuel > 0` (too weak) or
   `fuel >= B` (also too weak). The fix is the quadratic invariant `fuel > (B-k) * B`.
