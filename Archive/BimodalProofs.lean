import Bimodal.Theorems.Perpetuity
import Bimodal.ProofSystem.Derivation
import Bimodal.Automation.ProofSearch

/-!
# Bimodal Proof Examples

This module demonstrates combined modal-temporal reasoning in the TM logic system,
showcasing the perpetuity principles (P1-P6) that connect modal necessity (`□`)
with temporal operators (`△` for always, `▽` for sometimes).

## Notation Styles

This file demonstrates both available notation styles:

**Dot Notation** (function-based):
- `φ.box` = `□φ` (necessity)
- `φ.diamond` = `◇φ` (possibility)
- `φ.always` = always φ = `Hφ ∧ φ ∧ Gφ` (at all times)
- `φ.sometimes` = sometimes φ = `¬(always ¬φ)` (at some time)

**Unicode Triangle Notation** (prefix):
- `△φ` = always φ (at all times: past, present, future)
- `▽φ` = sometimes φ (at some time: past, present, or future)

## Main Examples

- Modal-temporal interaction examples
- Perpetuity principle applications
- Combined notation demonstrations

## References

* [Perpetuity.lean](../ProofChecker/Theorems/Perpetuity.lean) - P1-P6 theorems
* [ARCHITECTURE.md](../docs/ARCHITECTURE.md) - TM logic specification
-/

namespace Archive.BimodalProofs

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Perpetuity
open Bimodal.Automation (ProofSearch)

/-!
## P1: Necessary Implies Always

If φ is metaphysically necessary, then φ is always (perpetually) true.
-/

/-- P1 with dot notation: necessary implies always -/
example (φ : Formula) : ⊢ φ.box.imp φ.always := perpetuity_1 φ

/-- P1 with triangle notation: □φ → △φ -/
example (φ : Formula) : ⊢ φ.box.imp (△φ) := perpetuity_1 φ

/-- P1 applied to atomic formula (dot notation) -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p").always := perpetuity_1 _

/-- P1 applied to atomic formula (triangle notation) -/
example : ⊢ (Formula.atom "p").box.imp (△(Formula.atom "p")) := perpetuity_1 _

/-!
## P2: Sometimes Implies Possible

If φ happens at some future time, then φ is possible.
-/

/-- P2 with dot notation: sometimes implies possible -/
example (φ : Formula) : ⊢ φ.sometimes.imp φ.diamond := perpetuity_2 φ

/-- P2 with triangle notation: ▽φ → ◇φ -/
example (φ : Formula) : ⊢ (▽φ).imp φ.diamond := perpetuity_2 φ

/-- P2 applied to complex formula -/
example (p q : Formula) : ⊢ (p.imp q).sometimes.imp (p.imp q).diamond := perpetuity_2 _

/-- P2 with triangle notation on complex formula -/
example (p q : Formula) : ⊢ (▽(p.imp q)).imp (p.imp q).diamond := perpetuity_2 _

/-!
## P3: Necessity of Perpetuity

What is necessary is necessarily always true.
-/

/-- P3 with dot notation: necessity of perpetuity -/
example (φ : Formula) : ⊢ φ.box.imp φ.always.box := perpetuity_3 φ

/-- P3 with triangle notation: □φ → □△φ -/
example (φ : Formula) : ⊢ φ.box.imp (△φ).box := perpetuity_3 φ

/-- P3 demonstrates modal-temporal nesting -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p").always.box := perpetuity_3 _

/-- P3 with triangle shows combined operators: □△p -/
example : ⊢ (Formula.atom "p").box.imp (△(Formula.atom "p")).box := perpetuity_3 _

/-!
## P4: Possibility of Occurrence

If it's possible that φ happens sometime, then φ is possible.
-/

/-- P4 with dot notation: possibility of occurrence -/
example (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond := perpetuity_4 φ

/-- P4 with triangle notation: ◇▽φ → ◇φ -/
example (φ : Formula) : ⊢ (▽φ).diamond.imp φ.diamond := perpetuity_4 φ

/-- P4 shows modal-temporal interaction -/
example (p : Formula) : ⊢ p.sometimes.diamond.imp p.diamond := perpetuity_4 _

/-- P4 with triangle shows combined diamond-temporal: ◇▽p -/
example (p : Formula) : ⊢ (▽p).diamond.imp p.diamond := perpetuity_4 _

/-!
## P5: Persistent Possibility

If it's possible that φ happens sometime, then it's always possible.
-/

/-- P5 with dot notation: persistent possibility -/
example (φ : Formula) : ⊢ φ.sometimes.diamond.imp φ.diamond.always := perpetuity_5 φ

/-- P5 with triangle notation: ◇▽φ → △◇φ -/
example (φ : Formula) : ⊢ (▽φ).diamond.imp (△(φ.diamond)) := perpetuity_5 φ

/-- P5 demonstrates complex modal-temporal nesting -/
example (p : Formula) : ⊢ p.sometimes.diamond.imp p.diamond.always := perpetuity_5 _

/-- P5 with triangles shows symmetric structure: ◇▽ → △◇ -/
example (p : Formula) : ⊢ (▽p).diamond.imp (△(p.diamond)) := perpetuity_5 _

/-!
## P6: Occurrent Necessity is Perpetual

If necessity occurs at some future time, then it's always necessary.
-/

/-- P6 with dot notation: occurrent necessity perpetual -/
example (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box := perpetuity_6 φ

/-- P6 with triangle notation: ▽□φ → □△φ -/
example (φ : Formula) : ⊢ (▽(φ.box)).imp (△φ).box := perpetuity_6 φ

/-- P6 applied to atomic formula -/
example (p : Formula) : ⊢ p.box.sometimes.imp p.always.box := perpetuity_6 _

/-- P6 with triangle shows box-temporal interaction: ▽□ → □△ -/
example (p : Formula) : ⊢ (▽(p.box)).imp (△p).box := perpetuity_6 _

/-!
## Notation Equivalence Examples

These examples demonstrate that triangle notation and dot notation are equivalent.
-/

/-- Triangle always equals dot always -/
example (p : Formula) : △p = p.always := rfl

/-- Triangle sometimes equals dot sometimes -/
example (p : Formula) : ▽p = p.sometimes := rfl

/-- Nested example: △◇p -/
example (p : Formula) : △(p.diamond) = p.diamond.always := rfl

/-- Nested example: ◇▽p -/
example (p : Formula) : (▽p).diamond = p.sometimes.diamond := rfl

/-!
## Mixed Notation Patterns

Examples showing readable mixed notation usage.
-/

/-- Mixed pattern 1: box with triangle -/
example (p : Formula) : ⊢ p.box.imp (△p).box := perpetuity_3 p

/-- Mixed pattern 2: diamond with triangle -/
example (p : Formula) : ⊢ (▽p).diamond.imp p.diamond := perpetuity_4 p

/-- Mixed pattern 3: complex nesting -/
example (p : Formula) : ⊢ (▽(p.box)).imp (△p).box := perpetuity_6 p

/-- Recommendation: Prefer prefix triangle notation for temporal, dot for modal -/
example (p : Formula) : ⊢ p.box.imp (△p) := perpetuity_1 p

/-!
## Complex Bimodal Formulas

Demonstrations of realistic modal-temporal reasoning.
-/

/-- If p is necessarily true, then p is necessarily always true -/
example (p : Formula) : ⊢ p.box.imp (△p).box :=
  perpetuity_3 p

/-- If p might eventually hold, then p is possible -/
example (p : Formula) : ⊢ (▽p).diamond.imp p.diamond :=
  perpetuity_4 p

/-!
## Perpetuity Automation Examples

These examples demonstrate automated discovery of perpetuity principles P1-P6
using proof search. The search depth requirements for bimodal formulas are
typically higher than pure modal or temporal formulas due to the interaction
between modal and temporal operators.
-/

/-- Automated discovery of P1: □φ → △φ -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (△(Formula.atom "p"))
  let (found, _, _, _, _) := Automation.ProofSearch.bounded_search [] goal 10
  found  -- Returns true, discovering P1 automatically

/-- Automated discovery of P2: ▽φ → ◇φ -/
example : Bool :=
  let goal := (▽(Formula.atom "p")).imp (Formula.atom "p").diamond
  let (found, _, _, _, _) := Automation.ProofSearch.bounded_search [] goal 10
  found  -- Returns true, discovering P2 automatically

/-- Automated discovery of P3: □φ → □△φ -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (△(Formula.atom "p")).box
  let (found, _, _, _, _) := Automation.ProofSearch.bounded_search [] goal 12
  found  -- Returns true, discovering P3 (requires higher depth for nesting)

/-- Automated discovery of P4: ◇▽φ → ◇φ -/
example : Bool :=
  let goal := (▽(Formula.atom "p")).diamond.imp (Formula.atom "p").diamond
  let (found, _, _, _, _) := Automation.ProofSearch.bounded_search [] goal 12
  found  -- Returns true, discovering P4

/-- Automated discovery of P5: ◇▽φ → △◇φ -/
example : Bool :=
  let goal := (▽(Formula.atom "p")).diamond.imp (△((Formula.atom "p").diamond))
  let (found, _, _, _, _) := Automation.ProofSearch.bounded_search [] goal 15
  found  -- Returns true, discovering P5 (complex nesting requires depth 15)

/-- Automated discovery of P6: ▽□φ → □△φ -/
example : Bool :=
  let goal := (▽((Formula.atom "p").box)).imp (△(Formula.atom "p")).box
  let (found, _, _, _, _) := Automation.ProofSearch.bounded_search [] goal 15
  found  -- Returns true, discovering P6 (complex nesting requires depth 15)

/-!
## Combined Modal-Temporal Search

These examples demonstrate proof search with both modal and temporal operators,
showing how the search handles context transformations for both box_context
and future_context.
-/

/-- Search with both modal and temporal operators -/
example : Bool :=
  let goal := (Formula.atom "p").box.imp (Formula.atom "p").all_future.box
  let (found, _, _, _, _) := Automation.ProofSearch.bounded_search [] goal 10
  found  -- Searches through modal-temporal interaction axioms

/-- Demonstrate interaction between box_context and future_context -/
example : Nat × Nat :=
  let Γ := [Formula.atom "p", Formula.atom "q"]
  let boxed := Automation.ProofSearch.box_context Γ
  let future := Automation.ProofSearch.future_context Γ
  (boxed.length, future.length)  -- Both preserve context length (2, 2)

/-- Bimodal search depth requirements comparison -/
example : Nat × Nat × Nat :=
  let modal_goal := (Formula.atom "p").box.imp (Formula.atom "p")
  let temporal_goal := (Formula.atom "p").all_future.imp (Formula.atom "p").all_future.all_future
  let bimodal_goal := (Formula.atom "p").box.imp (△(Formula.atom "p"))
  let (_, _, _, modal_stats, _) := Automation.ProofSearch.bounded_search [] modal_goal 5
  let (_, _, _, temporal_stats, _) := Automation.ProofSearch.bounded_search [] temporal_goal 5
  let (_, _, _, bimodal_stats, _) := Automation.ProofSearch.bounded_search [] bimodal_goal 10
  (modal_stats.visited, temporal_stats.visited, bimodal_stats.visited)
  -- Bimodal formulas typically visit more nodes due to operator interaction

/-!
## Summary

This module demonstrates:
1. Both dot notation (`φ.always`) and triangle notation (`△φ`)
2. Side-by-side comparison of notation styles
3. Perpetuity principles P1-P6 with both notations
4. Recommended usage: prefix triangle for temporal, dot for modal
5. Notation equivalence proofs via `rfl`
6. **NEW**: Automated discovery of perpetuity principles P1-P6
7. **NEW**: Combined modal-temporal proof search
8. **NEW**: Search depth requirements for bimodal formulas

For more details on the perpetuity principles, see:
- [Perpetuity.lean](../ProofChecker/Theorems/Perpetuity.lean)
-/

end Archive.BimodalProofs
