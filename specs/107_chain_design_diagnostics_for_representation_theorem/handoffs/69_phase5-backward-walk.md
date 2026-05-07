# Phase 5 Handoff: C5 Backward Walk Implementation

## Session
- ID: sess_1778114001_749277
- Date: 2026-05-06
- Task: 107 Phase 5 -- Fix C5 backward (Since) cases

## Summary of Work Done

### Completed

1. **Created `lemma_2_4_since_with_guard`** in PointInsertion.lean (~120 lines)
   - Since mirror of `lemma_2_4_with_guard` for backward direction
   - Uses enriched seed `{eta} U h_content(A) U {untl(xi, gamma) | gamma in A}`
   - Includes `since_witness_enriched_seed_consistent` proof
   - COMPILES SUCCESSFULLY

2. **Created `C5BackwardWalkResult` structure** in CounterexampleElimination.lean (~20 lines)
   - Mirror of `C5ForwardWalkResult` with reversed ordering
   - `witness_lt` instead of `witness_gt`
   - `new_point_before` instead of `new_point_after`

3. **Created `c5_backward_walk` function skeleton** (~300 lines)
   - Base case: uses `lemma_2_4_since_with_guard` (mirrors forward base case)
   - Recursive case (condition (i)): recurses at predecessor x''
   - Not-condition(i) case: splits at (x'', pt) with `ξ ∈ B''`
   - Termination: `(dom.filter (· < pt)).card`

4. **Strengthened backward `h_actual`** to use adjacent-pair guard:
   - Changed from `pc.ξ ∈ χ.g y pc.x` to `∀ a b, Adjacent χ.dom a b → y ≤ a → b ≤ pc.x → pc.ξ ∈ χ.g a b`

5. **Replaced Walk A + Walk B with single `c5_backward_walk` call** (~15 lines)
   - Old: ~350 lines of Walk A (w_min=min_old) + Walk B (split)
   - New: `let r := c5_backward_walk χ h_c0 h_c2' h_nubr3 pc.ξ pc.η pc.x ...`

6. **Strengthened `h_split_result` in not-condition(i)** to include `pc.ξ ∈ B''`
   - Added 8th component to existential
   - All sub-cases propagate `ξ ∈ B''` via `h_B_sub_B'' h_xi_g` or `lemma_2_7_since`

7. **Fixed not-actual backward case** to capture guard from `push_neg`

8. **Fixed `h_guard_implies_no_event_back`** to produce adjacent-pair guard witness

### Remaining: 12 Compile Errors

All errors are mechanical -- they involve `simp`/`subst`/ordering issues in the proof terms.

#### Error Group 1: `c5_backward_walk` split case c2' proof (~line 1590)
```
h_B''_max has type BurgessR3Maximal D B'' (χ.f b)
but is expected to have type BurgessR3Maximal D (if z = x'' ∧ False then B' else B'') (χ.f b)
```
**Fix**: The `simp` at line 1589 doesn't fully reduce the g' if-expression. After `subst hb_eq` (which replaces `pt` with `b`), need to explicitly show `g' z b = B''`. Use `show g' z b = B''` or `simp [g', show z ≠ x'' from ne_of_gt hx''_lt_z, show b ≠ z from ...]`.

#### Error Group 2: `c5_backward_walk` witness_guard (~lines 1634-1647)
```
hb_ne has type ¬b = pt but expected pt ≠ b
h_le_a has type z ≤ a but expected a ≤ z  
h_xi_B'' has type ξ ∈ B'' but expected ξ ∈ if z = x'' ∧ b = z then B' else B''
```
**Fix**: 
- The witness_guard in the split case needs to show `ξ ∈ g'(z, pt) = B''`. After `subst`, need to explicitly simp the g' if-expression to B''.
- Use `dsimp only [g']` + `simp only [show z ≠ x'' from ..., false_and, if_false, and_self, if_true]` to reduce to `B''`.
- For `hb_ne`: use `Ne.symm (ne_of_gt ...)` instead.

#### Error Group 3: n=0 case in `eliminate_potential_counterexample` (~lines 2345-2349)
```
unsolved goals / No goals to be solved
```
**Fix**: The `rcases` structure needs adjustment. The `· exact absurd rfl hb_ne_y; · exact h` on a single line may cause parsing issues. Split into separate lines.

#### Error Group 4: not-condition(i) witness_guard in `eliminate_potential_counterexample` (~lines 2637-2643)
```
h_le_a has type z ≤ a but expected a ≤ z
h_ξ_B'' has type pc.ξ ∈ B'' but expected pc.ξ ∈ if z = x'' ∧ pc.x = z then B' else B''
```
**Fix**: Same pattern as Group 2 -- need to explicitly simplify g' if-expression.

### Approach for Remaining Fixes

All remaining errors follow the same two patterns:

**Pattern A (if-expression reduction)**: After substitution, the g' function has unsimplified if-expressions like `if z = x'' ∧ b = z then B' else B''`. The fix is:
```lean
have h1 : z ≠ x'' := ne_of_gt hx''_lt_z  -- or similar
show ξ ∈ g' z b
simp only [g', h1, false_and, if_false, and_self, if_true]
exact h_xi_B''
```

**Pattern B (ordering direction)**: Some adjacency arguments have reversed ordering. The backward walk goes x'' < z < pt, so:
- Points ABOVE z are toward pt (right)
- Points BELOW z are toward x'' (left)
The guard condition checks `z ≤ a → b ≤ pt`, so the only valid pair is (z, pt).

### Files Modified

1. **PointInsertion.lean**: Added `since_witness_enriched_seed_consistent` and `lemma_2_4_since_with_guard` before `end` (~120 lines net)
2. **CounterexampleElimination.lean**: Major restructuring of backward C5 case (~3556 lines total, was 3312)

### Build Status

- PointInsertion.lean: COMPILES CLEAN
- CounterexampleElimination.lean: 12 errors remaining (all mechanical)

### Key Design Decision

The backward walk (`c5_backward_walk`) mirrors the forward walk exactly:
- Base case uses `lemma_2_4_since_with_guard` (new lemma)
- Recursive case composes guard at (x'', pt) + recursive guard below x''
- `new_point_before` field ensures adjacency composition works
- `have r := ...` (not `let r`) keeps WF elaborator happy

The condition (i) backward section was replaced from ~350 lines (Walk A + Walk B) to ~15 lines (single `c5_backward_walk` call), mirroring Phase 4's forward restructuring.
