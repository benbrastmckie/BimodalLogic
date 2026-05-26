import Bimodal.Metalogic.Soundness
import Bimodal.Semantics.Validity

/-!
# Discrete Soundness - Soundness of Discrete-Compatible Axioms

This module proves that all axioms with `minFrameClass ≤ FrameClass.Discrete` are
valid with respect to the `valid_discrete` notion of validity (restricted to temporal
types with `SuccOrder` and `PredOrder`).

## Main Results

- `discreteness_forward_sound_discrete`: DF is valid over all discrete temporal orders
- `axiom_discrete_valid`: All discrete-compatible axioms are valid over discrete orders

## Implementation Notes

With irreflexive temporal semantics (< instead of ≤), the discreteness axiom
DF = `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` requires SuccOrder to find the immediate successor.
The density axiom GGφ → Gφ has `minFrameClass = .Dense` which is incomparable with
`.Discrete`, so it is excluded by the `h.minFrameClass ≤ FrameClass.Discrete` constraint.

## References

- Research-013 Section 3.3: DF soundness for discrete frames
- Research-016: Irreflexive semantics feasibility
-/

namespace Bimodal.Metalogic.DiscreteSoundness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/--
The forward discreteness axiom DF is valid over all discrete temporal orders.
-/
theorem discreteness_forward_sound_discrete (φ : Formula) :
    valid_discrete (Formula.and (Formula.bot.neg.some_future)
      (Formula.and φ (Formula.all_past φ)) |>.imp
      (Formula.all_past φ).some_future) :=
  discreteness_forward_valid φ

/--
All axioms with `minFrameClass ≤ .Discrete` are valid over discrete temporal orders.
This re-exports `axiom_discrete_valid` from Soundness.lean.
-/
theorem axiom_discrete_valid' {φ : Formula} (h : Axiom φ)
    (h_fc : h.minFrameClass ≤ FrameClass.Discrete) :
    valid_discrete φ :=
  axiom_discrete_valid h h_fc

end Bimodal.Metalogic.DiscreteSoundness
