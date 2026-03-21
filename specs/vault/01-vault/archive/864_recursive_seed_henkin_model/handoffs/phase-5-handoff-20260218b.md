# Phase 5 Handoff: Task #864 (Iteration 2)

**Session**: sess_1771434699_fa2b5b
**Date**: 2026-02-18
**Status**: Build errors encountered, needs infrastructure fixes

## Progress This Session (Iteration 2)

1. Added helper lemma `mem_addFormula_getFormulas_same_implies` (line ~3539) - partially complete
2. Attempted detailed atom case proof in `processWorkItem_preserves_closure`
3. Discovered infrastructure gaps blocking completion

## Blocking Issues Identified

### Issue 1: List.mem_tail_iff does not exist

The proof attempts to use `List.mem_tail_iff` which doesn't exist in Mathlib.

**What's needed**: A lemma showing:
```lean
lemma List.mem_tail_of_mem_ne_head (l : List α) (x : α) (h_head : l ≠ [])
    (h_mem : x ∈ l) (h_ne : x ≠ l.head h_head) : x ∈ l.tail
```

Or alternatively, work with `List.mem_cons` characterization.

### Issue 2: Helper lemma singleton case incomplete

The `mem_addFormula_getFormulas_same_implies` lemma has a sorry in the `none` branch.
The issue is proving `List.find? p [newEntry] = some newEntry` where the predicate involves
`newEntry`'s fields matching `famIdx` and `timeIdx`.

**Location**: Line ~3560-3568

### Issue 3: Theorem design flaw

`processWorkItem_preserves_closure` may need an additional hypothesis `h_item_head : state.worklist = item :: _` to properly reason about tail membership. Currently, `item` is arbitrary and not necessarily related to `state.worklist`.

However, this may be mitigated if we can prove that when the pending work item `w` has a different formula than `item`, then `w ≠ item` hence `w ∈ tail`.

## Immediate Next Action

1. First, add a helper lemma for proving membership in singleton list find?:
   ```lean
   lemma find?_singleton_some (p : α → Bool) (x : α) (h : p x = true) :
       [x].find? p = some x
   ```

2. Fix the `mem_addFormula_getFormulas_same_implies` lemma's none case

3. For the tail membership issue, add:
   ```lean
   lemma mem_tail_of_mem_of_ne {α : Type*} {l : List α} {x : α}
       (h_mem : x ∈ l) (h_ne : ∀ a, l = a :: l.tail → x ≠ a) : x ∈ l.tail
   ```

4. Then use the fact that `item.formula ≠ Formula.box psi` (since `item.formula = atom s`) to show `w ≠ item` hence `w ∈ tail`

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
**Build Status**: Failing with errors

**Key errors**:
- Line 3587: unsolved goals in helper lemma
- Line 7525+: Multiple errors from `List.mem_tail_iff` usage
- Various type mismatch errors

## Key Decisions Made

1. **Proof approach for atom case**: Show that adding an atom doesn't introduce new Box/G/H formulas, so any such formula in the new seed must have been in the original seed. Then use the original invariant.

2. **For pending work item disjunct**: When the invariant says "w ∈ worklist with w ∉ processed", we need to show w is still in the tail after processing. Since `item.formula ≠ w.formula`, we have `w ≠ item`, so `w ∈ tail`.

## What NOT to Try

1. **Don't use List.mem_tail_iff** - it doesn't exist
2. **Don't try native_decide** for newEntry predicate - has free variables

## Critical Context

**WorklistClosureInvariant structure** (for reference):
- Box closure: For Box psi at (f,t), either closed (psi at all f' with hasPosition f' t) OR pending work item
- G closure: For G psi at (f,t), either closed (psi at all t' > t) OR pending work item
- H closure: For H psi at (f,t), either closed (psi at all t' < t) OR pending work item

**Key helper lemmas that exist**:
- `addFormula_preserves_hasPosition`
- `addFormula_preserves_mem_getFormulas_same`
- `addFormula_preserves_getFormulas_diff_fam`
- `addFormula_preserves_getFormulas_diff_time`
- `foldl_addFormula_adds_at_family`
- `mem_familyIndices_of_hasPosition`

## References

- **Plan**: specs/864_recursive_seed_henkin_model/plans/implementation-005.md
- **Previous handoff**: specs/864_recursive_seed_henkin_model/handoffs/phase-5-handoff-20260218.md
- **Research**: specs/864_recursive_seed_henkin_model/reports/research-007.md

## Remaining Work After Fixing Infrastructure

After fixing the helper lemmas, need to complete:
1. Atom case full proof
2. Bot case (similar to atom)
3. Box/G/H positive cases (key cases using foldl_addFormula_adds_at_family)
4. Box/G/H negative cases
5. Implication cases
