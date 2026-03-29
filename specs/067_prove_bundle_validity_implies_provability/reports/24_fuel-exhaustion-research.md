# Phase 3 Blocker: Fuel-Exhaustion Sorries in Bounded Witness Lemmas

**Task**: 67
**Session**: sess_1774828197_5c3024
**Date**: 2026-03-29
**Focus**: Research elimination approaches for fuel=0 base case sorries

## Executive Summary

The four sorry sites in `SuccChainFMCS.lean` are all in fuel=0 base cases of recursive functions that use explicit fuel for termination. These cases are **semantically unreachable** when the functions are called with sufficient initial fuel (`B*B+1` where `B = closure_F_bound phi`). The research identifies three viable approaches with different trade-offs.

## Sorry Sites Analysis

### Location Summary

| Line | Function | Goal Type |
|------|----------|-----------|
| 2913 | `restricted_bounded_witness_wf` | `theta ∈ restricted_forward_chain phi M0 m` |
| 5527 | `restricted_backward_bounded_witness_fueled` | `theta ∈ restricted_backward_chain phi M0 m` |
| 5685 | `restricted_combined_bounded_witness_fueled` | `theta ∈ restricted_succ_chain_fam phi M0 m` |
| 5881 | `restricted_combined_bounded_witness_P_fueled` | `theta ∈ restricted_succ_chain_fam phi M0 m` |

### Recursion Structure

Each function follows the same pattern:

```lean
private theorem xxx_fueled (phi : Formula) ... (fuel : Nat) ... :
    ∃ m, ... ∧ theta ∈ chain m := by
  match fuel with
  | 0 =>
    -- SORRY HERE: fuel exhausted but need to produce witness
    match d with
    | 0 => exact absurd h_d_ge (by omega : ¬0 ≥ 1)
    | _ + 1 => exact ⟨..., by sorry⟩  -- <-- THE SORRY
  | fuel' + 1 =>
    -- Recursive case: uses fuel' in recursive call
    ...
    obtain ⟨m, h_m, h_in⟩ := xxx_fueled ... fuel' ...
    ...
termination_by fuel
```

### Wrapper Functions

Each fueled function has a wrapper that provides sufficient initial fuel:

```lean
theorem restricted_bounded_witness ... :
    ∃ m > k, theta ∈ restricted_forward_chain phi M0 m := by
  let B := closure_F_bound phi
  exact restricted_bounded_witness_wf phi M0 k theta d (B * B + 1) ...
```

The key invariant: with initial fuel `B*B+1`, the fuel=0 case is unreachable because:
1. Each recursive call consumes exactly 1 fuel
2. The total number of recursive calls is bounded by `B*B`
3. Initial fuel `B*B+1 > B*B` ensures we never hit fuel=0 while still having work to do

## Approach Analysis

### Approach 1: Fuel-Invariant Hypothesis (RECOMMENDED)

**Concept**: Add an explicit hypothesis `h_fuel_ge : fuel >= required_depth` that is maintained through recursion and proves the fuel=0 case impossible.

**Implementation**:

```lean
private theorem restricted_bounded_witness_fueled (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (fuel : Nat)
    (h_d_ge : d ≥ 1)
    (h_fuel_ge : fuel ≥ 1)  -- NEW: track that we have fuel
    (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k) :
    ∃ m : Nat, m > k ∧ theta ∈ restricted_forward_chain phi M0 m := by
  match fuel with
  | 0 => exact absurd h_fuel_ge (by omega : ¬0 ≥ 1)  -- Now provably unreachable!
  | fuel' + 1 =>
    -- Recursive case proceeds as before, passing (fuel' + 1) >= 1 proof
    ...
```

**Pros**:
- Minimal changes to existing proof structure
- Each sorry site becomes `exact absurd h_fuel_ge (by omega)`
- No need to restructure recursion or change termination arguments

**Cons**:
- Requires threading the `h_fuel_ge` hypothesis through all recursive calls
- May need to prove `fuel' ≥ 1` at each recursive call site (but `fuel' + 1 ≥ 1` is trivial)

**Wait**: This approach has a flaw. The `fuel' + 1` case recurses with `fuel'`, not `fuel' + 1`. If `fuel' = 0`, then the recursive call has `fuel = 0` with `h_fuel_ge : 0 ≥ 1`, which is false.

**Correction**: The invariant needs to be `fuel ≥ remaining_work`, where `remaining_work` decreases with each step. This is more complex to track.

### Approach 2: Well-Founded Recursion on Lexicographic Product (COMPLEX)

**Concept**: Replace fuel-based recursion with well-founded recursion on a lexicographic measure `(total_bound - k, d)` where:
- `total_bound - k` decreases when we move to chain position `k+1`
- `d` can reset but is bounded by `B`

**Implementation sketch**:

```lean
private theorem restricted_bounded_witness_wf (phi : Formula) ... :
    ∃ m > k, theta ∈ restricted_forward_chain phi M0 m := by
  have h_d_lt : d < closure_F_bound phi := restricted_forward_chain_depth_bounded ...
  -- Use well-founded recursion with termination_by (B*B - k, d)
  ...
termination_by (closure_F_bound phi * closure_F_bound phi - k, d)
```

**Pros**:
- No fuel parameter needed
- Mathematically cleaner
- No unreachable base cases

**Cons**:
- Significant restructuring of proof
- Need to prove the measure decreases at each recursive call
- The measure involves `k` which changes non-monotonically in some variants (Int-indexed chains)
- Lean's `termination_by` may struggle with complex measures

**Challenge**: The recursion has a non-obvious pattern:
- `k` increases by 1 each step (good)
- `d` is reset to `d' + (n - 1)` or `d' + n` which can be larger than original `d`
- But `d < B` always holds, so total steps bounded by `B * (number of k increases)`

### Approach 3: External Unreachability Proof (CLEANEST FOR ZERO-DEBT)

**Concept**: Prove once, externally, that the fuel=0 case is unreachable given the initial fuel, then use `False.elim` in the sorry sites.

**Implementation**:

```lean
-- External lemma proving unreachability
lemma bounded_witness_fuel_sufficient (phi : Formula) (M0 : ...) (k d fuel : Nat)
    (h_init : fuel ≥ closure_F_bound phi * closure_F_bound phi + 1)
    (h_call : -- describes valid call context) :
    fuel > 0 := by
  -- Complex invariant tracking argument
  sorry  -- This becomes the single sorry to eliminate

-- Then in the fueled function:
  | 0 =>
    -- Use the unreachability lemma
    have h_false : False := by
      have h_pos : 0 > 0 := bounded_witness_fuel_sufficient phi M0 k d 0 ...
      exact Nat.lt_irrefl 0 h_pos
    exact False.elim h_false
```

**Pros**:
- Consolidates all sorry elimination into one lemma
- Keeps the main proof structure intact
- Clear separation of termination argument from main logic

**Cons**:
- The unreachability lemma itself needs a complex invariant argument
- May need to instrument the recursive call structure to track remaining work

### Approach 4: Accept Sorries as Semantically Sound (NOT RECOMMENDED)

**Concept**: Document that these sorries are unreachable and verify via `#print axioms` that they don't affect the completeness path.

**Why Not Recommended**:
- Violates zero-debt policy
- Even if unreachable from intended call sites, the fueled functions themselves export a sorry
- Any theorem depending on these lemmas inherits `sorryAx`

## Feasibility Assessment

### Recommended Approach: Hybrid of 1 and 3

**Strategy**:
1. Add a `h_fuel_pos : fuel > 0` hypothesis to each fueled function
2. In the fuel=0 branch, derive contradiction from `h_fuel_pos`
3. Update wrapper functions to provide `by omega` proof that `B*B+1 > 0`

**Implementation**:

```lean
private theorem restricted_backward_bounded_witness_fueled (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (fuel : Nat)
    (h_d_ge : d ≥ 1)
    (h_fuel_pos : fuel > 0)  -- NEW
    (h_iter_in : iter_P d theta ∈ restricted_backward_chain phi M0 k)
    (h_iter_not : iter_P (d + 1) theta ∉ restricted_backward_chain phi M0 k) :
    ∃ m : Nat, m > k ∧ theta ∈ restricted_backward_chain phi M0 m := by
  match fuel with
  | 0 => exact absurd h_fuel_pos (by omega : ¬0 > 0)
  | fuel' + 1 =>
    -- Recursive calls need (fuel' + 1 > 0), which is trivially true
    -- BUT we also need to handle the case where recursive call has fuel' = 0
    -- In that case, the recursive call needs proof that fuel' > 0...
```

**Wait - this still has the same problem**. The recursive call uses `fuel'`, and if `fuel' = 0`, we need `fuel' > 0` which is false.

### Revised Understanding

The actual solution requires tracking that `fuel ≥ remaining_work` where `remaining_work` is the actual amount of work remaining. Let me reconsider.

**Key Insight**: The bound `B*B` comes from:
- At most `B` chain positions can be visited (because chain stabilizes)
- At each position, depth is bounded by `B`
- Total recursive steps ≤ `B * B`

But proving this requires tracking the relationship between current position `k`, initial position `k_init`, and the number of recursions.

### Final Recommendation: Structural Refactoring

The cleanest solution is to restructure the recursion to use well-founded recursion on a measure that naturally captures termination:

**Measure**: `termination_by (total_chain_bound - k, closure_F_bound phi - steps_at_current_k)`

But this requires significant refactoring.

**Alternative**: Keep fuel but add a strengthened precondition:

```lean
private theorem restricted_bounded_witness_fueled (phi : Formula)
    ... (fuel : Nat)
    (h_fuel_sufficient : fuel ≥ closure_F_bound phi) -- Sufficient for one chain position
    ...
```

Then at each recursive call:
- If resolved (n = 0), no recursion needed
- If recursion needed, prove new fuel is still sufficient

This requires proving that `fuel' ≥ closure_F_bound phi - 1` implies sufficient fuel for the recursive call, which tracks properly.

## Estimated Effort

| Approach | Complexity | Time | Risk |
|----------|------------|------|------|
| Fuel-pos hypothesis (buggy) | Low | 2h | High (doesn't work) |
| Fuel-sufficient invariant | Medium | 4-6h | Medium |
| Well-founded restructure | High | 8-12h | Low |
| Accept sorries | None | 0h | Violates policy |

## Conclusion

**Recommended Approach**: Fuel-sufficient invariant tracking

1. Add hypothesis `h_fuel_ge : fuel ≥ closure_F_bound phi` to fueled functions
2. In recursive calls, prove that `fuel' + 1 ≥ closure_F_bound phi` implies `fuel' ≥ closure_F_bound phi - 1` which is enough for one more recursion
3. The base fuel is `B*B+1` which is `>= B`, so the invariant holds initially
4. Each recursion consumes 1 fuel but the bound `B` on depth ensures we find the witness before running out

**Actually**, looking more carefully: the issue is that the recursive call's new depth `d'` can be up to `B-1`, so we need fuel for up to `B` more calls at the new chain position. The `B*B` bound accounts for this: `B` positions times `B` depth explorations each.

The invariant should be: `fuel ≥ (B - k_visited) * B + depth_remaining`

This is getting complex. For Phase 3, I recommend:

1. **Immediate fix**: Mark these 4 sorries as "unreachable base cases" with a single consolidated TODO
2. **Zero-debt compliance**: Create a sub-task to properly eliminate these sorries via invariant tracking
3. **Verification**: Use `#print axioms` to confirm the main completeness theorems don't depend on these

## Impact on Completeness Path

To verify impact, check axiom dependencies:

```lean
#print axioms bundle_validity_implies_provability
```

If this doesn't include `sorryAx`, the completeness path is sorry-free.

If it does, these sorries are blocking and must be eliminated.

## Appendix: Goal States at Sorry Sites

### Line 2913 (`restricted_bounded_witness_wf`)
```
case neg
phi : Formula
M0 : DeferralRestrictedSerialMCS phi
k : Nat
theta : Formula
d remaining_steps n : Nat
h_d_ge : n + 1 >= 1
h_iter_in : (iter_F n theta).some_future ∈ restricted_forward_chain phi M0 k
h_iter_not : iter_F (n + 1 + 1) theta ∉ restricted_forward_chain phi M0 k
h_d_lt : n + 1 < closure_F_bound phi
h_resolved : iter_F n theta ∈ restricted_forward_chain phi M0 (k + 1)
hn : ¬n = 0
⊢ ∃ m > k, theta ∈ restricted_forward_chain phi M0 m
```

### Line 5527 (`restricted_backward_bounded_witness_fueled`)
```
phi : Formula
M0 : DeferralRestrictedSerialMCS phi
k : Nat
theta : Formula
d fuel n : Nat
h_d_ge : n + 1 >= 1
h_iter_in : iter_P (n + 1) theta ∈ restricted_backward_chain phi M0 k
h_iter_not : iter_P (n + 1 + 1) theta ∉ restricted_backward_chain phi M0 k
⊢ ∃ m > k, theta ∈ restricted_backward_chain phi M0 m
```

### Line 5685 (`restricted_combined_bounded_witness_fueled`)
```
phi : Formula
M0 : DeferralRestrictedSerialMCS phi
n : Int
theta : Formula
d fuel n' : Nat
h_d_ge : n' + 1 >= 1
h_iter_in : iter_F (n' + 1) theta ∈ restricted_succ_chain_fam phi M0 n
h_iter_not : iter_F (n' + 1 + 1) theta ∉ restricted_succ_chain_fam phi M0 n
⊢ ∃ m > n, theta ∈ restricted_succ_chain_fam phi M0 m
```

### Line 5881 (`restricted_combined_bounded_witness_P_fueled`)
```
phi : Formula
M0 : DeferralRestrictedSerialMCS phi
n : Int
theta : Formula
d fuel d' : Nat
h_d_ge : d' + 1 >= 1
h_iter_in : iter_P (d' + 1) theta ∈ restricted_succ_chain_fam phi M0 n
h_iter_not : iter_P (d' + 1 + 1) theta ∉ restricted_succ_chain_fam phi M0 n
⊢ theta ∈ restricted_succ_chain_fam phi M0 (n - 1)
```

Note: Line 5881 has a slightly different goal structure - it needs the witness at `n - 1` specifically, not just some `m < n`.
