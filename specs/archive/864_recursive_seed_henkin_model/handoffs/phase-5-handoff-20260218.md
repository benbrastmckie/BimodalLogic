# Phase 5 Handoff: Task #864

**Session**: sess_1771434699_fa2b5b
**Date**: 2026-02-18
**Status**: Partial progress on Phase 5 closure proofs

## Progress This Session

1. Added key helper `mem_familyIndices_of_hasPosition` (line 399)
2. Completed G/H branches in `processWorklistAux_preserves_closure`
3. Expanded `processWorkItem_preserves_closure` with complete formula case structure

## Immediate Next Action

Fill in the individual case proofs in `processWorkItem_preserves_closure` (lines 7393-7417).

The proof should match on `item.formula` structure (not `classifyFormula` result) and show:
1. For `Formula.box psi`: psi is added to ALL families via foldl, so left disjunct of invariant (closure satisfied)
2. For `Formula.all_future psi`: psi added to all future times, so left disjunct
3. For `Formula.all_past psi`: psi added to all past times, so left disjunct
4. For other cases (atomic, bot, imp, neg): no new Box/G/H added, existing invariants preserved

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
**Line**: 7376 (sorry for `processWorkItem_preserves_closure`)

**Goal state** at line 7376:
```lean
item : WorkItem
state : WorklistState
h_inv : WorklistClosureInvariant state
⊢ match processWorkItem item state with
  | (newWork, state') =>
    WorklistClosureInvariant
      { seed := state'.seed, worklist := newWork ++ state.worklist.tail, processed := state'.processed }
```

## Key Decisions Made

1. **Match on formula structure, not classifyFormula**: Following pattern from `processWorkItem_newWork_complexity_lt` (line 6691), match on `item.formula` then use `simp [classifyFormula]` to simplify.

2. **Use foldl_addFormula_adds_at_family**: For boxPositive case, this lemma (line 3506) proves that if famIdx is in the family list, then formula is added at that family.

3. **Use mem_familyIndices_of_hasPosition**: Added helper (line 399) proving `hasPosition f t => f ∈ familyIndices`. This connects the invariant's `hasPosition` condition to the `familyIndices` used in foldl.

## What NOT to Try

1. **Don't match on classifyFormula result**: The match equation isn't exposed for reasoning. Match on formula structure instead.

2. **Don't try to prove fuel sufficiency first**: The `sorry` at line 7390 for fuel=0 case is secondary. Focus on `processWorkItem_preserves_closure` first.

## Critical Context

**WorklistClosureInvariant structure**:
```lean
def WorklistClosureInvariant (state : WorklistState) : Prop :=
  -- For Box psi in seed: either psi at all families OR pending work item
  (∀ f t psi, Formula.box psi ∈ state.seed.getFormulas f t →
    (∀ f', state.seed.hasPosition f' t → psi ∈ state.seed.getFormulas f' t) ∨
    (∃ w ∈ state.worklist, w.formula = Formula.box psi ∧ w.famIdx = f ∧ w.timeIdx = t ∧ w ∉ state.processed)) ∧
  -- Similar for G/H
  ...
```

**processWorkItem boxPositive case** (line 6524-6532):
```lean
| .boxPositive psi =>
  let seed1 := state.seed.addFormula item.famIdx item.timeIdx (Formula.box psi) .universal_target
  let familyIndices := seed1.familyIndices
  let newWork := familyIndices.map (fun f => ⟨psi, f, item.timeIdx⟩)
  let seed2 := familyIndices.foldl (fun s f =>
      s.addFormula f item.timeIdx psi .universal_target) seed1
  (newWork, { state with seed := seed2 })
```

**Key insight**: After foldl, `psi` is at ALL families in `seed1.familyIndices`. Any position (f', t) with `hasPosition f' t` has `f' ∈ familyIndices` (by `mem_familyIndices_of_hasPosition`), so `psi ∈ getFormulas f' t`.

## References

- **Plan**: specs/864_recursive_seed_henkin_model/plans/implementation-005.md
- **Summary**: specs/864_recursive_seed_henkin_model/summaries/implementation-summary-20260217.md
- **Research**: specs/864_recursive_seed_henkin_model/reports/research-007.md

## Remaining Sorries After This Handoff

- Line 7376: `processWorkItem_preserves_closure` (KEY - this session's target)
- Line 7390: `processWorklistAux_preserves_closure` fuel=0 case
- Line 7442: `processWorklistAux_preserves_closure` uses processWorkItem_preserves_closure
