import Bimodal.Metalogic.Soundness
import Bimodal.Semantics.Validity

/-!
# Discrete Soundness - Soundness of DF for Discrete Validity

This module proves that the forward discreteness axiom DF is sound with respect
to the `valid_discrete` notion of validity (restricted to temporal types with
`SuccOrder` and `PredOrder`).

## Main Results

- `discreteness_forward_sound_discrete`: DF is valid over all discrete temporal orders
- `axiom_valid_discrete`: All TM axioms are valid over discrete orders

## Implementation Notes

With reflexive temporal semantics (≤ instead of <), the discreteness axiom
DF = `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` is actually valid over ALL temporal types.
The proof that DF is `valid_discrete` follows immediately from it being `valid`.

## References

- Research-013 Section 3.3: DF soundness for discrete frames
-/

namespace Bimodal.Metalogic.DiscreteSoundness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/--
The forward discreteness axiom DF is valid over all discrete temporal orders.

With reflexive semantics, this follows from DF being valid over ALL types.
-/
theorem discreteness_forward_sound_discrete (φ : Formula) :
    valid_discrete (Formula.and (Formula.bot.neg.some_future)
      (Formula.and φ (Formula.all_past φ)) |>.imp
      (Formula.all_past φ).some_future) :=
  Validity.valid_implies_valid_discrete (discreteness_forward_valid φ)

/--
All TM axioms (including DN and DF) are valid over discrete temporal orders.
-/
theorem axiom_valid_discrete {φ : Formula} (h : Axiom φ) : valid_discrete φ :=
  Validity.valid_implies_valid_discrete (axiom_valid h)

end Bimodal.Metalogic.DiscreteSoundness
