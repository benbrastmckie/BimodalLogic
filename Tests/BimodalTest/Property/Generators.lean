/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Int
import Bimodal.Syntax.Formula
import Bimodal.Syntax.Context
import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.TaskModel
import Plausible

/-!
# Property Test Generators

This module provides generators for property-based testing of Logos types.

## Main Definitions

- `Arbitrary Formula`: Size-controlled recursive generator for formulas
- `Shrinkable Formula`: Shrinking strategy for minimal counterexamples
- `Arbitrary Context`: Generator for contexts (automatic via List)
- `SampleableExt (TaskFrame Int)`: Generator for task frames with finite worlds

## Implementation Notes

- Formula generation uses size control to prevent infinite recursion
- Shrinking reduces formulas to simpler subformulas for better counterexamples
- TaskFrame generation reuses the library's `nat_frame` (satisfies all frame
  constraints by construction: `nullity_identity`, `forward_comp`, `converse`)
- All generators follow Plausible framework conventions

## API Drift Notes (Task 365)

The Plausible API changed since this file was written:
- `Gen.oneOf` now takes an `Array` (with a `0 < size` proof) rather than a `List`.
- `Gen.resize` now takes a `Nat → Nat` function rather than a `Nat`.
- `Gen.choose` now takes an explicit type + `lo ≤ hi` proof and returns a subtype.
- `Formula.atom` takes an `Atom` (not a `String`); use `Formula.atom_s` for a
  `String`-seeded atom.
- `SampleableExt` is derived from `Arbitrary` + `Shrinkable` + `Repr` via the
  `selfContained` default instance.

## References

* [Plausible Documentation](https://github.com/leanprover-community/plausible)
* [Property Testing Guide](../../../docs/Development/PROPERTY_TESTING_GUIDE.md)
-/

namespace BimodalTest.Property.Generators

open Bimodal.Syntax
open Bimodal.Semantics
open Plausible

/-! ## Formula Generators -/

/--
Recursive, size-controlled generator for `Formula`.

Generates formulas recursively with size control to ensure termination.
At size 0, generates only atoms and bot. At larger sizes, generates
compound formulas with reduced size for subformulas.

This prevents infinite recursion and ensures a good distribution of
formula sizes in property tests.
-/
partial def genFormula : Gen Formula := Gen.sized fun size =>
  if size ≤ 0 then
    -- Base case: only atoms and bot
    Gen.oneOfWithDefault (pure Formula.bot) [
      Formula.atom_s <$> (Arbitrary.arbitrary : Gen String)
    ]
  else
    -- Recursive case: all constructors with reduced size
    let subsize := size / 2
    Gen.oneOfWithDefault (pure Formula.bot) [
      Formula.atom_s <$> (Arbitrary.arbitrary : Gen String),
      Formula.imp <$> Gen.resize (fun _ => subsize) genFormula
                  <*> Gen.resize (fun _ => subsize) genFormula,
      Formula.box <$> Gen.resize (fun _ => size - 1) genFormula,
      Formula.all_past <$> Gen.resize (fun _ => size - 1) genFormula,
      Formula.all_future <$> Gen.resize (fun _ => size - 1) genFormula
    ]

/--
Arbitrary instance for Formula with size-controlled generation.
-/
instance : Arbitrary Formula := ⟨genFormula⟩

/--
Shrinkable instance for Formula.

Shrinks formulas to simpler subformulas for better counterexample reporting.
- Atoms and bot don't shrink (already minimal)
- Compound formulas shrink to their immediate subformulas
- Subformulas are also recursively shrunk

This helps Plausible find minimal counterexamples when properties fail.

Note: matches only on the real `Formula` constructors (`atom`, `bot`, `imp`,
`box`, `untl`, `snce`). `all_past`/`all_future` are derived operators, not
constructors, so they cannot appear as match patterns.
-/
partial def shrinkFormula : Formula → List Formula
  | Formula.atom _ => []
  | Formula.bot => []
  | Formula.imp p q =>
      [p, q] ++
      (shrinkFormula p).map (Formula.imp · q) ++
      (shrinkFormula q).map (Formula.imp p ·)
  | Formula.box p =>
      [p] ++ (shrinkFormula p).map Formula.box
  | Formula.untl p q =>
      [p, q] ++
      (shrinkFormula p).map (Formula.untl · q) ++
      (shrinkFormula q).map (Formula.untl p ·)
  | Formula.snce p q =>
      [p, q] ++
      (shrinkFormula p).map (Formula.snce · q) ++
      (shrinkFormula q).map (Formula.snce p ·)

instance : Shrinkable Formula := ⟨shrinkFormula⟩

/-! ## Context Generators -/

-- Note: Arbitrary instance for Context (List Formula) is automatic

/-! ## TaskFrame Generators -/

/--
Generate a small natural number (0-4) for world count.

Used to create finite task frames with a reasonable number of worlds.
-/
def genSmallNat : Gen Nat := do
  let n ← Gen.choose Nat 0 4 (by omega)
  return n.val

/--
SampleableExt instance for TaskFrame with integer time.

Reuses the library's `nat_frame`, which satisfies all frame constraints
(`nullity_identity`, `forward_comp`, `converse`) by construction. This is a
simple generator suitable for basic property testing.
-/
instance : SampleableExt (TaskFrame Int) where
  proxy := Unit
  interp _ := TaskFrame.nat_frame (D := Int)

/-! ## TaskModel Generators (QUARANTINED — Task 365)

NOTE (Task 365): The `SampleableExt (TaskModel …)` instance and the
`TaskModel`-valued generators below were quarantined. They relied on a
`TaskModelProxy` proxy type that lacks the `Repr`/`Shrinkable` instances the
current `SampleableExt` class requires, and on the removed `T`-parameter form of
`TaskFrame.nat_frame` and a `String`-typed valuation. No `Testable` consumer in
the imported test suite quantifies over `TaskModel`, so these are not needed for
the green build. They are commented out (never `sorry`-ed) to keep the module
importable. Restoring them is tracked as a follow-up (see task summary).

structure TaskModelProxy where
  frameProxy : Unit
  valuationSeed : Nat

instance : SampleableExt (TaskModel (TaskFrame.nat_frame (D := Int))) where
  proxy := TaskModelProxy
  interp p :=
    { valuation := fun w s =>
        (Nat.mix (Nat.mix p.valuationSeed w) s.base.length) % 2 = 0 }
  sample := ⟨do
    let seed ← Gen.choose Nat 0 1000 (by omega)
    return ⟨(), seed.val⟩⟩

def genAllFalseModel : Gen (TaskModel (TaskFrame.nat_frame (D := Int))) :=
  pure { valuation := fun _ _ => False }

def genAllTrueModel : Gen (TaskModel (TaskFrame.nat_frame (D := Int))) :=
  pure { valuation := fun _ _ => True }

def genModelWithPattern (pattern : Nat → Atom → Bool) :
    Gen (TaskModel (TaskFrame.nat_frame (D := Int))) :=
  pure { valuation := fun w s => pattern w s }
-/

/-! ## Helper Functions -/

/--
Generate a formula of specific complexity.

Useful for testing properties that depend on formula size.
-/
def genFormulaOfSize (n : Nat) : Gen Formula :=
  Gen.resize (fun _ => n) genFormula

/--
Generate a non-empty context.

Useful for testing properties that require at least one assumption.
-/
def genNonEmptyContext : Gen Context := do
  let φ ← genFormula
  let Γ ← (Arbitrary.arbitrary : Gen Context)
  return φ :: Γ

/--
Generate a simple atomic formula.

Useful for testing base cases.
-/
def genAtom : Gen Formula := do
  let s ← (Arbitrary.arbitrary : Gen String)
  return Formula.atom_s s

/--
Generate a propositional formula (no modal/temporal operators).

Useful for testing propositional logic properties.
-/
partial def genPropFormula : Gen Formula := Gen.sized fun size =>
  if size ≤ 0 then
    Gen.oneOfWithDefault (pure Formula.bot) [
      Formula.atom_s <$> (Arbitrary.arbitrary : Gen String)
    ]
  else
    let subsize := size / 2
    Gen.oneOfWithDefault (pure Formula.bot) [
      Formula.atom_s <$> (Arbitrary.arbitrary : Gen String),
      Formula.imp <$> Gen.resize (fun _ => subsize) genPropFormula
                  <*> Gen.resize (fun _ => subsize) genPropFormula
    ]

end BimodalTest.Property.Generators
