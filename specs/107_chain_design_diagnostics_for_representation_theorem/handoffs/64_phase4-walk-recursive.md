# Phase 4 Handoff: Recursive Walk Helper Needed

## Status: PARTIAL (3 of 8 forward C5 tasks fixed)

## Session: sess_1778114001_749277

## Changes Made in This Session

### Fixed Not-Condition(i) Splitting (Error 4, Plan Task 4.7)

**File**: CounterexampleElimination.lean

1. **Added `pc.ξ ∈ B'` to h_split_result** (line ~1285-1293): Changed the existential return type from 7 components to 8 by adding `pc.ξ ∈ B'`.

2. **Updated all 6 sub-cases** of h_split_result to provide `pc.ξ ∈ B'`:
   - Case 1 (lemma_2_6 + xi in g): `h_B_sub_B'2 h_xi_g` (g subset B' applied to xi in g)
   - Case 2 (lemma_2_7, xi not in g): `h_xi_B'3` from lemma_2_7 strengthened return
   - Case 3 (lemma_2_8, xi in g): `h_B_sub_B'5 h_xi_g`
   - Case 4 (lemma_2_7 with conj, xi in g): `h_B_sub_B'6 h_xi_g`
   - Case 5 (lemma_2_7, xi not in g): `h_xi_B'4` from lemma_2_7 strengthened return
   - Case 6 (eta.neg not in g): Added `by_cases h_xi_g6` sub-split:
     - xi in g: use lemma_2_6 + g subset B'
     - xi not in g: use lemma_2_7 instead of lemma_2_6

3. **Extracted `h_ξ_B'`** from h_split_prop (line ~1377) for use in guard proof.

4. **Wrote guard proof in c5_forward_witness** (line ~1502): Proves the only adjacent pair (a,b) with pc.x <= a and b <= z in `insert z chi.dom` is (pc.x, z). Shows a = pc.x (old adj pair contradiction) and b = z (midpoint constraint), then `g'(pc.x, z) = B'` and `xi in B'`.

### Build Status After Fix

- 9 errors remain (was 10 before): 3 forward C5 (971, 1044, 1223) + 6 backward C5
- Error at line ~1456 (not-condition(i) splitting) is FIXED
- No sorries introduced

## Remaining Forward C5 Errors (3)

### Error 1: Walk A (line 971) - u_max = max_old

The witness is `y` (fresh beyond max_old). Guard at `(max_old, y)` available via `lemma_2_4_with_guard` (`xi in B_l24`). BUT guard at OLD adj pairs between pc.x and max_old requires the walk guard invariant which the current code cannot prove.

**Sub-cases**:
- `pc.x = max_old`: Only adj pair from pc.x to y is (max_old, y). Guard trivially follows from lemma_2_4_with_guard. (Easy - 15 lines)
- `pc.x < max_old`: Requires recursive walk. Guard at intermediate pairs not derivable.

### Error 2: Walk B eta-shortcut (line 1044) - u_max < max_old, eta in f(u_next)

Returns chi unchanged with u_next as witness. But needs guard at ALL adj pairs from pc.x to u_next. The code only knows xi in g(pc.x, x') from condition (i). No guard for pairs beyond x'.

**Must be removed.** The shortcut is incompatible with the guard requirement. Per research report: always fall through to splitting (or recursion) when condition (i) fails at (u_max, u_next).

### Error 3: Walk B splitting (line 1223) - u_max < max_old, split at (u_max, u_next)

Witness is z (midpoint of u_max, u_next). Guard at (u_max, z) available from splitting (xi in B' from strengthened lemma_2_7/2_8). BUT guard at OLD adj pairs from pc.x to u_max has the same problem as Walk A.

## Required Restructuring: Recursive Walk Helper

### Design

Replace the entire condition (i) branch (Walk A + Walk B, ~450 lines, lines 867-1319) with a call to a recursive helper:

```lean
/-- Recursive walk for C5 forward guard.
    Burgess 2.10 induction: at each step, either condition (i) holds (recurse)
    or it fails (split). Termination: number of domain points after start decreases. -/
private noncomputable def c5_forward_walk
    (chi : Chronicle) (h_c0 : chi.c0) (h_c2' : chi.c2')
    (xi eta : Formula) (start : Rat) 
    (h_start_mem : start in chi.dom)
    (h_until : Formula.untl xi eta in chi.f start)
    (h_no_wit : no_witness_from_start_with_guard)
    (h_nubr3 : NoUnivBurgessR3)
    (n : Nat) (hn : n = (chi.dom.filter (· > start)).card) :
    WalkResult chi xi eta start
```

### Base Case (n = 0: start = max_old)

Use `lemma_2_4_with_guard` to get witness y beyond max_old. Guard at single pair (max_old, y) from xi in B_l24.

### Recursive Step (n > 0: start < max_old)

1. Find x' = successor of start in dom
2. Get BurgessR3Maximal for (start, x') from c2'
3. Check condition (i) at (start, x'): conj in f(x') AND xi in g(start, x')
   - **Condition (i) holds**: 
     - Prove eta not in f(x') from h_no_wit (see "Key Deduction" below)
     - Derive h_no_wit at x' (by guard composition argument)
     - Recurse: c5_forward_walk chi ... x' ... (n-1)
     - Compose: guard at (start, x') from condition (i) + recursive guard from x'
   - **Condition (i) fails**:
     - Apply not-condition(i) splitting at (start, x') -- same h_split_result logic
     - Get witness z = midpoint(start, x') with guard xi in B' at (start, z)

### Key Deduction: eta not in f(x') when condition (i) holds

From h_no_wit at start: no y in dom with y > start AND eta in f(y) AND full guard from start to y.

Test y = x': x' > start, x' in dom. Guard from start to x': only adj pair is (start, x'), and xi in g(start, x') from condition (i). So IF eta in f(x'), x' would be a witness. But h_no_wit says no witness exists. Therefore eta not in f(x').

### Key Deduction: h_no_wit at x' from h_no_wit at start

If there were a witness y > x' with guard from x' to y, then y > start, eta in f(y), and guard from start to y = guard at (start, x') + guard from x' to y. The first comes from condition (i). So y would be a witness from start, contradicting h_no_wit.

### Termination

`(chi.dom.filter (· > x')).card < (chi.dom.filter (· > start)).card` because x' is in the second set but not the first (x' > start but x' is NOT > x').

### WalkResult Type

```lean
structure WalkResult (chi : Chronicle) (xi eta : Formula) (start : Rat) where
  val : Chronicle
  dom_sub : chi.dom ⊆ val.dom
  c0 : val.c0
  c2' : val.c2'
  f_agrees : ∀ x in chi.dom, val.f x = chi.f x
  g_agrees : ∀ a b, a in chi.dom → b in chi.dom → val.g a b = chi.g a b
  witness : ∃ y in val.dom, start < y ∧ eta in val.f y ∧
    ∀ a b, Adjacent val.dom a b → start ≤ a → b ≤ y → xi in val.g a b
  g_sub_f_insert : ...
  g_sub_g_new : ...  
  dom_new_unique : ...
```

### Implementation Attempt Notes

An attempt was made to implement the recursive helper using `Nat.strongRecOn` in a `by` tactic proof. Key findings:

1. **`set n` + `induction` doesn't work**: `set n := ...` creates a local def, and `induction n using Nat.strongRecOn` expects the goal to be `∀ n, P n`. The variables don't scope correctly after `revert` + `induction`.

2. **Better approach**: Use `termination_by` on a `noncomputable def`, or use `WellFounded.fix` as a term. The function should be defined as:
   ```lean
   private noncomputable def c5_forward_walk ... : C5ForwardWalkResult χ ξ η start :=
     ... -- term-mode with WellFounded.fix or match/if with termination_by
   termination_by (χ.dom.filter (· > start)).card
   ```

3. **Adjacency lemma needed**: The condition (i) recursive case requires proving that new points from the recursion are strictly greater than x' (the starting point of the recursion). This follows from: the recursion at x' inserts points either beyond max_old (base case) or between pairs after x' (recursive splitting). Formally, need a `new_point_gt` field in C5ForwardWalkResult or a side lemma.

4. **Base case code is mostly written**: The ~120 lines for start = max_old (lemma_2_4_with_guard, chronicle construction, guard proof) compiled successfully before being reverted.

5. **Guard composition is straightforward**: Once the recursive result provides guard from x' to y, prepending (start, x') guard from condition (i) is a simple case split in the Adjacent argument.

### Estimated Effort

- Define C5ForwardWalkResult structure: ~15 lines
- Base case (start = max_old): ~80 lines (verified compiles)
- Recursive step condition (i): ~50 lines (h_no_wit derivation + recurse + guard composition)
- Recursive step not-condition(i): ~120 lines (splitting logic, same as Task 4.7 pattern)
- Termination proof: ~10 lines (Finset.card decrease)
- `new_point_gt` field or side lemma: ~15 lines
- Replace condition (i) branch with helper call: ~20 lines (delete ~450 lines)
- **Total**: ~310 lines new, -450 lines deleted = ~140 net reduction
- **Estimated time**: 4-6 hours

## Backward (Since) Mirrors (6 errors)

Same restructuring needed for Since direction. After forward is complete, mirror all changes. Estimated additional 3-4 hours.

## Plan Task Status Updates

- [x] Task 4.1: Fix not-actual case (DONE in prior session)
- [x] Task 4.2: Fix n=0 case (DONE in prior session)
- [ ] Task 4.3: Fix Walk A, pc.x = max_old (easy sub-case of Walk A)
- [ ] Task 4.4: RESTRUCTURE Walk A, pc.x < max_old (recursive helper)
- [ ] Task 4.5: REMOVE Walk B eta-shortcut (absorbed into recursive helper)
- [ ] Task 4.6: Fix Walk B splitting (absorbed into recursive helper)
- [x] Task 4.7: Fix not-condition(i) splitting (DONE this session)
- [ ] Task 4.8: Run lake build to verify

## Key Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — main target
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — lemma_2_4_with_guard, lemma_2_7, lemma_2_8
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` — Adjacent, BurgessR3Maximal
