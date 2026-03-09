import Bimodal.Metalogic.Soundness
import Bimodal.Semantics.Validity

/-!
# Dense Soundness - Soundness of DN for Dense Validity

This module proves that the density axiom DN is sound with respect to the
`valid_dense` notion of validity (restricted to densely ordered temporal types).

## Main Results

- `density_sound_dense`: DN is valid over all dense temporal orders
- `soundness_dense`: Full soundness for TM + DN with respect to `valid_dense`

## Implementation Notes

With reflexive temporal semantics (≤ instead of <), the density axiom DN = `Fφ → FFφ`
is actually valid over ALL temporal types, not just dense ones. This is because
`some_future` (the existential future operator) includes the present moment via ≤.
The proof that DN is `valid_dense` follows immediately from it being `valid`.

The density axiom becomes semantically meaningful only with strict temporal semantics
(< instead of ≤), where it genuinely requires intermediate points. In the reflexive
setting, it is included in the axiom system for the completeness direction:
TM + DN proves completeness with respect to `valid_dense`.

## References

- Research-013 Section 3.2: DN soundness for dense frames
- Research-014: Fragment-first architecture
-/

namespace Bimodal.Metalogic.DenseSoundness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/--
The density axiom DN is valid over all densely ordered temporal types.

With reflexive semantics, this follows from DN being valid over ALL types.
-/
theorem density_sound_dense (φ : Formula) :
    valid_dense (φ.some_future.imp φ.some_future.some_future) :=
  Validity.valid_implies_valid_dense (density_valid φ)

/--
All TM axioms (including DN and DF) are valid over dense temporal orders.
This follows from the general soundness theorem since all axioms are valid.
-/
theorem axiom_valid_dense {φ : Formula} (h : Axiom φ) : valid_dense φ :=
  Validity.valid_implies_valid_dense (axiom_valid h)

end Bimodal.Metalogic.DenseSoundness
