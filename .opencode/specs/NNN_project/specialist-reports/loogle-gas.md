# Loogle Search Results: "gas"

**Search Query**: `"gas"`  
**Date**: 2025-12-21  
**Total Matches Found**: 37  
**Search Type**: Name pattern search  
**Heartbeats**: 1  

## Executive Summary

The Loogle search for "gas" found 37 declarations across three major LEAN libraries (Std, Lean, Mathlib). Notably, **none of these results are related to gas-based recursion patterns** commonly used for termination proofs. Instead, all matches contain "gas" as a substring within longer identifiers related to:

1. **Assignment operations** in SAT solving (BVDecide)
2. **Debug assertions** in the Lean compiler
3. **Boolean algebra/ring isomorphisms** in Mathlib

This indicates that LEAN 4's standard libraries do not use "gas" terminology for recursion fuel/bounds, likely preferring terms like "fuel", "depth", "bound", or "limit" instead.

---

## Match Categories

### Category 1: Assignment Operations (Std.Tactic.BVDecide) - 20 matches

These functions manage variable assignments in SAT solving and bit-vector decision procedures. The "gas" substring appears in "Assignment" and related function names.

#### Core Assignment Functions

1. **`Std.Tactic.BVDecide.BVExpr.Assignment.toAIGAssignment`**
   - **Type**: `(assign : Std.Tactic.BVDecide.BVExpr.Assignment) : Std.Tactic.BVDecide.BVBit → Bool`
   - **Module**: `Std.Tactic.BVDecide.Bitblast.BVExpr.Circuit.Lemmas.Basic`
   - **Library**: Std
   - **Purpose**: Converts BVExpr assignments to AIG (And-Inverter Graph) assignments

2. **`Std.Tactic.BVDecide.BVExpr.Assignment.toAIGAssignment_apply`**
   - **Type**: `(assign : Std.Tactic.BVDecide.BVExpr.Assignment) (bit : Std.Tactic.BVDecide.BVBit) : assign.toAIGAssignment bit = (assign.get bit.var).bv.getLsbD ↑bit.idx`
   - **Module**: `Std.Tactic.BVDecide.Bitblast.BVExpr.Circuit.Lemmas.Basic`
   - **Library**: Std
   - **Purpose**: Correctness lemma for toAIGAssignment

3. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.addNegAssignment`**
   - **Type**: `(oldAssignment : Std.Tactic.BVDecide.LRAT.Internal.Assignment) : Std.Tactic.BVDecide.LRAT.Internal.Assignment`
   - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
   - **Library**: Std
   - **Documentation**: "Updates the old assignment of `l` to reflect the fact that `(l, false)` is now part of the formula."

4. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.hasNegAssignment`**
   - **Type**: `(assignment : Std.Tactic.BVDecide.LRAT.Internal.Assignment) : Bool`
   - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
   - **Library**: Std
   - **Purpose**: Checks if an assignment has a negative assignment

5. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.removeNegAssignment`**
   - **Type**: `(oldAssignment : Std.Tactic.BVDecide.LRAT.Internal.Assignment) : Std.Tactic.BVDecide.LRAT.Internal.Assignment`
   - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
   - **Library**: Std
   - **Documentation**: "Updates the old assignment of `l` to reflect the fact that `(l, false)` is no longer part of the formula."

#### Assignment Equation Lemmas

6. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.addNegAssignment.eq_1`**
   - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.pos.addNegAssignment = Std.Tactic.BVDecide.LRAT.Internal.Assignment.both`
   - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
   - **Library**: Std

7. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.addNegAssignment.eq_2`**
   - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.neg.addNegAssignment = Std.Tactic.BVDecide.LRAT.Internal.Assignment.neg`
   - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
   - **Library**: Std

8. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.addNegAssignment.eq_3`**
   - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.both.addNegAssignment = Std.Tactic.BVDecide.LRAT.Internal.Assignment.both`
   - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
   - **Library**: Std

9. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.addNegAssignment.eq_4`**
   - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.unassigned.addNegAssignment = Std.Tactic.BVDecide.LRAT.Internal.Assignment.neg`
   - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
   - **Library**: Std

10. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.hasNegAssignment.eq_1`**
    - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.pos.hasNegAssignment = false`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
    - **Library**: Std

11. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.hasNegAssignment.eq_2`**
    - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.neg.hasNegAssignment = true`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
    - **Library**: Std

12. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.hasNegAssignment.eq_3`**
    - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.both.hasNegAssignment = true`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
    - **Library**: Std

13. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.hasNegAssignment.eq_4`**
    - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.unassigned.hasNegAssignment = false`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
    - **Library**: Std

14. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.removeNegAssignment.eq_1`**
    - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.pos.removeNegAssignment = Std.Tactic.BVDecide.LRAT.Internal.Assignment.pos`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
    - **Library**: Std

15. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.removeNegAssignment.eq_2`**
    - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.neg.removeNegAssignment = Std.Tactic.BVDecide.LRAT.Internal.Assignment.unassigned`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
    - **Library**: Std

16. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.removeNegAssignment.eq_3`**
    - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.both.removeNegAssignment = Std.Tactic.BVDecide.LRAT.Internal.Assignment.pos`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
    - **Library**: Std

17. **`Std.Tactic.BVDecide.LRAT.Internal.Assignment.removeNegAssignment.eq_4`**
    - **Type**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment.unassigned.removeNegAssignment = Std.Tactic.BVDecide.LRAT.Internal.Assignment.unassigned`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Assignment`
    - **Library**: Std

#### Assignment Invariants

18. **`Std.Tactic.BVDecide.LRAT.Internal.DefaultFormula.StrongAssignmentsInvariant`**
    - **Type**: `{n : ℕ} (f : Std.Tactic.BVDecide.LRAT.Internal.DefaultFormula n) : Prop`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Formula.Lemmas`
    - **Library**: Std
    - **Documentation**: "This invariant states that if the `assignments` field of a default formula `f` indicates that `f` contains an assignment `b` at index `i`, then the unit literal `(i, b)` must be included in `f`. Default formulas are expected to satisfy this invariant at all times except during intermediate stages of unit propagation (during which, default formulas are only expected to satisfy the more lenient `AssignmentsInvariant` defined below)."

19. **`Std.Tactic.BVDecide.LRAT.Internal.DefaultFormula.assignmentsInvariant_of_strongAssignmentsInvariant`**
    - **Type**: `{n : ℕ} (f : Std.Tactic.BVDecide.LRAT.Internal.DefaultFormula n) : f.StrongAssignmentsInvariant → f.AssignmentsInvariant`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Formula.Lemmas`
    - **Library**: Std

20. **`Std.Tactic.BVDecide.LRAT.Internal.DefaultFormula.deleteOne_preserves_strongAssignmentsInvariant`**
    - **Type**: `{n : ℕ} (f : Std.Tactic.BVDecide.LRAT.Internal.DefaultFormula n) (id : ℕ) : f.StrongAssignmentsInvariant → (f.deleteOne id).StrongAssignmentsInvariant`
    - **Module**: `Std.Tactic.BVDecide.LRAT.Internal.Formula.Lemmas`
    - **Library**: Std

---

### Category 2: Debug Assertions (Lean) - 9 matches

These declarations relate to debug assertions in the Lean compiler and parser. The "gas" substring appears in "warningAsError" and "debugAssert".

21. **`Lean.warningAsError`**
    - **Type**: `Lean.Option Bool`
    - **Module**: `Lean.Log`
    - **Library**: Lean
    - **Documentation**: "If `warningAsError` is set to `true`, then warning messages are treated as errors."

22. **`Lean.Parser.Term.debugAssert`**
    - **Type**: `Lean.Parser.Parser`
    - **Module**: `Lean.Parser.Term`
    - **Library**: Lean
    - **Documentation**: "`debug_assert! cond` panics if `cond` evaluates to `false` and the executing code has been built with debug assertions enabled (see the `debugAssertions` option)."

23. **`Lean.Parser.Term.debugAssert.formatter`**
    - **Type**: `Lean.PrettyPrinter.Formatter`
    - **Module**: `Lean.Parser.Term`
    - **Library**: Lean

24. **`Lean.Parser.Term.debugAssert.parenthesizer`**
    - **Type**: `Lean.PrettyPrinter.Parenthesizer`
    - **Module**: `Lean.Parser.Term`
    - **Library**: Lean

25. **`Lean.Parser.Term.doDebugAssert`**
    - **Type**: `Lean.Parser.Parser`
    - **Module**: `Lean.Parser.Do`
    - **Library**: Lean
    - **Documentation**: "`debug_assert! cond` panics if `cond` evaluates to `false` and the executing code has been built with debug assertions enabled (see the `debugAssertions` option)."

26. **`Lean.Parser.Term.doDebugAssert.formatter`**
    - **Type**: `Lean.PrettyPrinter.Formatter`
    - **Module**: `Lean.Parser.Do`
    - **Library**: Lean

27. **`Lean.Parser.Term.doDebugAssert.parenthesizer`**
    - **Type**: `Lean.PrettyPrinter.Parenthesizer`
    - **Module**: `Lean.Parser.Do`
    - **Library**: Lean

28. **`Lean.Elab.Term.elabDebugAssert`**
    - **Type**: `Lean.Elab.Term.TermElab`
    - **Module**: `Lean.Elab.BuiltinNotation`
    - **Library**: Lean

29. **`Lean.Elab.Term.debugAssertions`**
    - **Type**: `Lean.Option Bool`
    - **Module**: `Lean.Elab.BuiltinNotation`
    - **Library**: Lean

---

### Category 3: Boolean Algebra/Ring Isomorphisms (Mathlib) - 8 matches

These declarations define isomorphisms between Boolean algebras and Boolean rings. The "gas" substring appears in "AsBoolRing" and "AsBoolAlg".

30. **`instBooleanRingAsBoolRing`**
    - **Type**: `{α : Type u_1} [BooleanAlgebra α] : BooleanRing (AsBoolRing α)`
    - **Module**: `Mathlib.Algebra.Ring.BooleanRing`
    - **Library**: Mathlib

31. **`instNonUnitalCommRingAsBoolRingOfGeneralizedBooleanAlgebra`**
    - **Type**: `{α : Type u_1} [GeneralizedBooleanAlgebra α] : NonUnitalCommRing (AsBoolRing α)`
    - **Module**: `Mathlib.Algebra.Ring.BooleanRing`
    - **Library**: Mathlib

32. **`OrderIso.asBoolAlgAsBoolRing`**
    - **Type**: `(α : Type u_4) [BooleanAlgebra α] : AsBoolAlg (AsBoolRing α) ≃o α`
    - **Module**: `Mathlib.Algebra.Ring.BooleanRing`
    - **Library**: Mathlib
    - **Documentation**: "Order isomorphism between `α` considered as a Boolean ring considered as a Boolean algebra and `α`."

33. **`RingEquiv.asBoolRingAsBoolAlg`**
    - **Type**: `(α : Type u_4) [BooleanRing α] : AsBoolRing (AsBoolAlg α) ≃+* α`
    - **Module**: `Mathlib.Algebra.Ring.BooleanRing`
    - **Library**: Mathlib
    - **Documentation**: "Ring isomorphism between `α` considered as a Boolean algebra considered as a Boolean ring and `α`."

34. **`OrderIso.asBoolAlgAsBoolRing_apply`**
    - **Type**: `(α : Type u_4) [BooleanAlgebra α] (a✝ : AsBoolAlg (AsBoolRing α)) : (OrderIso.asBoolAlgAsBoolRing α) a✝ = ofBoolRing (ofBoolAlg a✝)`
    - **Module**: `Mathlib.Algebra.Ring.BooleanRing`
    - **Library**: Mathlib

35. **`OrderIso.asBoolAlgAsBoolRing_symm_apply`**
    - **Type**: `(α : Type u_4) [BooleanAlgebra α] (a✝ : α) : (RelIso.symm (OrderIso.asBoolAlgAsBoolRing α)) a✝ = toBoolAlg (toBoolRing a✝)`
    - **Module**: `Mathlib.Algebra.Ring.BooleanRing`
    - **Library**: Mathlib

36. **`RingEquiv.asBoolRingAsBoolAlg_apply`**
    - **Type**: `(α : Type u_4) [BooleanRing α] (a✝ : AsBoolRing (AsBoolAlg α)) : (RingEquiv.asBoolRingAsBoolAlg α) a✝ = ofBoolAlg (ofBoolRing a✝)`
    - **Module**: `Mathlib.Algebra.Ring.BooleanRing`
    - **Library**: Mathlib

37. **`RingEquiv.asBoolRingAsBoolAlg_symm_apply`**
    - **Type**: `(α : Type u_4) [BooleanRing α] (a✝ : α) : (RingEquiv.asBoolRingAsBoolAlg α).symm a✝ = toBoolRing (toBoolAlg a✝)`
    - **Module**: `Mathlib.Algebra.Ring.BooleanRing`
    - **Library**: Mathlib

---

## Analysis: Relevance to Gas-Based Recursion

### Key Finding: No Gas-Based Recursion Patterns Found

**None of the 37 matches are related to gas-based recursion or termination proofs.** The term "gas" does not appear to be used in LEAN 4's standard libraries for recursion fuel or bounds.

### Alternative Terminology in LEAN 4

Based on previous Loogle searches documented in this repository, LEAN 4 uses different terminology for recursion control:

1. **`fuel`** - Explicit recursion fuel parameter
2. **`depth`** - Depth-limited recursion
3. **`bound`** - Bounded computation
4. **`limit`** - Computation limits
5. **`iter`** - Iteration with bounds

### Why "gas" Appears in Results

The "gas" substring appears in these contexts:
- **"Assignment"** → contains "gas"
- **"warningAsError"** → contains "gas"  
- **"debugAssert"** → contains "gas"
- **"AsBoolRing"** → contains "gas"
- **"AsBoolAlg"** → contains "gas"

These are all coincidental substring matches, not semantic matches for gas-based recursion.

---

## Recommendations

### For Gas-Based Recursion Research

If you're looking for gas-based recursion patterns in LEAN 4, consider searching for:

1. **`fuel`** - More common term for recursion fuel
2. **`depth`** - Depth-limited recursion patterns
3. **`bound`** - Bounded computation patterns
4. **Type signatures** like `Nat → α → Option α` (fuel-based functions)
5. **Module paths** in `Std.Data.HashMap`, `Std.Data.RBTree` for cache implementations

### Related Searches Already Completed

Based on the specialist-reports directory, the following related searches have been completed:
- `loogle-fuel-search.md` - Fuel-based recursion
- `loogle-depth-search.md` - Depth-limited functions
- `loogle-bounded.md` - Bounded computation
- `loogle-iterate.md` - Iteration patterns
- `loogle-limit-search.md` - Limit-based functions

### Conclusion

The term "gas" is not used in LEAN 4's standard libraries for recursion control. The 37 matches found are all coincidental substring matches in unrelated domains (SAT solving, compiler infrastructure, Boolean algebra). For recursion termination patterns, use alternative search terms like "fuel", "depth", "bound", or "limit".

---

## Raw Search Results (JSON)

```json
{
  "query": "\"gas\"",
  "total_matches": 37,
  "header": "Found 37 declarations whose name contains \"gas\".",
  "heartbeats": 1,
  "libraries": {
    "Std": 20,
    "Lean": 9,
    "Mathlib": 8
  }
}
```

---

**Report Generated**: 2025-12-21  
**Loogle API Version**: Current  
**Search Execution Time**: 1 heartbeat  
