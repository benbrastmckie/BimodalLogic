# Implementation Summary: Task 961 (Iteration 3)

## Session: 2026-03-13, sess_1773630722_e9f5a4

## Overview

Partial implementation of DenselyOrdered, NoMaxOrder, and NoMinOrder for TimelineQuot using the strict density infrastructure from task 962.

## Key Changes

### DenseTimeline.lean
- **Added**: `dense_timeline_has_strict_intermediate` theorem
  - When source is reflexive, returns an intermediate that is strict from target
  - Uses `densityIntermediateMCS_strict_from_target` from task 962
  - This is the key lemma enabling quotient-level density proofs

### CantorApplication.lean
- **Restructured**: `strict_intermediate_exists` proof to use strict density
  - Added bounded iteration (4 levels) using `dense_timeline_has_strict_intermediate`
  - Each iteration checks if new intermediate breaks equivalence with source
  - Key insight: if c2 is not equivalent to c1, and c1 ~ p, then c2 is not equivalent to p
  - This follows from T4 transitivity via `canonicalR_T4_chain`

- **Expanded**: `c ~ q` branch with full iteration structure
  - Similar pattern: iterate density, check equivalence
  - Uses T4 chain to derive strictness from source when intermediate breaks equivalence with previous

## Remaining Sorries (8 total)

All sorries are "termination" cases where the bounded iteration has not found a strict intermediate:

1. **Line 304**: `strict_intermediate_exists` - c1 ~ c2 ~ c3 ~ c4 ~ p case
2. **Line 419**: `strict_intermediate_exists` - nested c ~ q branch termination
3. **Line 509**: `strict_intermediate_exists` - deeper nested termination
4. **Line 573**: `strict_intermediate_exists` - f ~ e ~ q, p not reflexive branch
5. **Line 734**: `NoMaxOrder` - p reflexive, all futures equivalent
6. **Line 793**: `NoMinOrder` - symmetric to NoMaxOrder

## Mathematical Analysis

The remaining sorries all require proving that the iteration terminates. The key argument:

1. Each density intermediate is constructed using a distinguishing formula delta
2. The intermediate contains NOT(delta) where G(delta) is in the target
3. If all intermediates are equivalent to the source, they all contain accumulated constraints
4. By formula finiteness, this chain cannot be infinite
5. Therefore, some intermediate must break equivalence

This is a wellfoundedness argument on the formula set. Formalizing it requires either:
- A metric on MCS sets that decreases at each step
- An explicit bound based on formula complexity
- A non-constructive argument using cardinality

## Build Status

- `lake build` passes with 3 sorry warnings (for the 3 declarations containing sorries)
- No new axioms introduced
- All added lemmas compile successfully

## Next Steps

1. **Option A**: Prove termination via formula wellfoundedness
   - Define a measure on MCS based on formula constraints
   - Show each strict density step decreases this measure

2. **Option B**: Use non-constructive existence
   - Prove that IF no strict intermediate exists, the quotient collapses
   - Derive contradiction from density of the preorder

3. **Option C**: Add a lemma about timeline structure
   - Show that the dense timeline has at least two distinct quotient classes
   - Use this to bootstrap the NoMaxOrder/NoMinOrder proofs

## Files Modified

- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` (added 37 lines)
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` (significant restructure)
