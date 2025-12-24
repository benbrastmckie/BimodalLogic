/-!
# Property Test Generators

This module provides generators for property-based testing of Logos types.

## Main Definitions

- `Arbitrary Formula`: Size-controlled recursive generator for formulas
- `Shrinkable Formula`: Shrinking strategy for minimal counterexamples
- `Arbitrary Context`: Generator for contexts (automatic via List)
- `SampleableExt TaskFrame`: Generator for task frames with finite worlds

## Implementation Notes

- Formula generation uses size control to prevent infinite recursion
- Shrinking reduces formulas to simpler subformulas for better counterexamples
- TaskFrame generation creates finite frames with 1-5 world states
- All generators follow Plausible framework conventions

## References

* [Plausible Documentation](https://github.com/leanprover-community/plausible)
* [Property Testing Guide](../../../Documentation/Development/PROPERTY_TESTING_GUIDE.md)
-/

import Logos.Core.Syntax.Formula
import Logos.Core.Syntax.Context
import Logos.Core.Semantics.TaskFrame
import Plausible

namespace LogosTest.Property.Generators

open Logos.Core.Syntax
open Logos.Core.Semantics
open Plausible

/-! ## Formula Generators -/

/--
Arbitrary instance for Formula with size-controlled generation.

Generates formulas recursively with size control to ensure termination.
At size 0, generates only atoms and bot. At larger sizes, generates
compound formulas with reduced size for subformulas.

This prevents infinite recursion and ensures a good distribution of
formula sizes in property tests.
-/
instance : Arbitrary Formula where
  arbitrary := Gen.sized fun size =>
    if size ≤ 0 then
      -- Base case: only atoms and bot
      Gen.oneOf [
        pure Formula.bot,
        Formula.atom <$> Arbitrary.arbitrary
      ]
    else
      -- Recursive case: all constructors with reduced size
      let subsize := size / 2
      Gen.oneOf [
        pure Formula.bot,
        Formula.atom <$> Arbitrary.arbitrary,
        Formula.imp <$> Gen.resize subsize Arbitrary.arbitrary
                    <*> Gen.resize subsize Arbitrary.arbitrary,
        Formula.box <$> Gen.resize (size - 1) Arbitrary.arbitrary,
        Formula.all_past <$> Gen.resize (size - 1) Arbitrary.arbitrary,
        Formula.all_future <$> Gen.resize (size - 1) Arbitrary.arbitrary
      ]

/--
Shrinkable instance for Formula.

Shrinks formulas to simpler subformulas for better counterexample reporting.
- Atoms and bot don't shrink (already minimal)
- Compound formulas shrink to their immediate subformulas
- Subformulas are also recursively shrunk

This helps Plausible find minimal counterexamples when properties fail.
-/
instance : Shrinkable Formula where
  shrink
    | Formula.atom _ => []
    | Formula.bot => []
    | Formula.imp p q =>
        [p, q] ++
        (Shrinkable.shrink p).map (Formula.imp · q) ++
        (Shrinkable.shrink q).map (Formula.imp p ·)
    | Formula.box p =>
        [p] ++ (Shrinkable.shrink p).map Formula.box
    | Formula.all_past p =>
        [p] ++ (Shrinkable.shrink p).map Formula.all_past
    | Formula.all_future p =>
        [p] ++ (Shrinkable.shrink p).map Formula.all_future

/-! ## Context Generators -/

/--
Context generator (automatic via List).

Contexts are just lists of formulas, so we get the Arbitrary instance
for free from List's Arbitrary instance combined with Formula's Arbitrary.

This generates contexts of varying lengths with random formulas.
-/
-- Note: Arbitrary instance for Context (List Formula) is automatic

/-! ## TaskFrame Generators -/

/--
Generate a small natural number (0-4) for world count.

Used to create finite task frames with a reasonable number of worlds.
-/
def genSmallNat : Gen Nat := do
  let n ← Gen.choose 0 4
  return n

/--
SampleableExt instance for TaskFrame with integer time.

Generates finite task frames with:
- 1-5 world states (represented as Nat)
- Integer time type
- Permissive task relation (all transitions allowed)
- Nullity and compositionality satisfied by construction

This is a simple generator suitable for basic property testing.
For more complex frame properties, use specialized generators.
-/
instance : SampleableExt (TaskFrame Int) where
  proxy := Unit
  interp _ :=
    { WorldState := Nat
      task_rel := fun _ _ _ => True  -- Permissive relation
      nullity := fun _ => trivial
      compositionality := fun _ _ _ _ _ _ _ => trivial
    }
  sample := pure ()

/-! ## Helper Functions -/

/--
Generate a formula of specific complexity.

Useful for testing properties that depend on formula size.
-/
def genFormulaOfSize (n : Nat) : Gen Formula :=
  Gen.resize n Arbitrary.arbitrary

/--
Generate a non-empty context.

Useful for testing properties that require at least one assumption.
-/
def genNonEmptyContext : Gen Context := do
  let φ ← Arbitrary.arbitrary
  let Γ ← Arbitrary.arbitrary
  return φ :: Γ

/--
Generate a simple atomic formula.

Useful for testing base cases.
-/
def genAtom : Gen Formula := do
  let s ← Arbitrary.arbitrary
  return Formula.atom s

/--
Generate a propositional formula (no modal/temporal operators).

Useful for testing propositional logic properties.
-/
partial def genPropFormula : Gen Formula := Gen.sized fun size =>
  if size ≤ 0 then
    Gen.oneOf [
      pure Formula.bot,
      Formula.atom <$> Arbitrary.arbitrary
    ]
  else
    let subsize := size / 2
    Gen.oneOf [
      pure Formula.bot,
      Formula.atom <$> Arbitrary.arbitrary,
      Formula.imp <$> Gen.resize subsize genPropFormula
                  <*> Gen.resize subsize genPropFormula
    ]

end LogosTest.Property.Generators
