import Bimodal.Metalogic.Soundness
import Bimodal.Semantics.Validity

/-!
# Dense Soundness - Soundness of Dense-Compatible Axioms

This module proves that all dense-compatible axioms (base axioms + density) are
valid with respect to the `valid_dense` notion of validity (restricted to densely
ordered temporal types).

## Main Results

- `density_sound_dense`: DN is valid over all dense temporal orders
- `axiom_valid_dense`: All dense-compatible axioms are valid over dense orders

## Implementation Notes

With irreflexive temporal semantics (< instead of ≤), the density axiom DN = `Fφ → FFφ`
genuinely requires intermediate points (DenselyOrdered). Base axioms are universally valid
and hence trivially valid on dense orders. The forward discreteness axiom DF is NOT valid
on dense orders and is excluded via `isDenseCompatible`.

## References

- Research-013 Section 3.2: DN soundness for dense frames
- Research-016: Irreflexive semantics feasibility
-/

namespace Bimodal.Metalogic.DenseSoundness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/--
The density axiom DN is valid over all densely ordered temporal types.
-/
theorem density_sound_dense (φ : Formula) :
    valid_dense (φ.some_future.imp φ.some_future.some_future) :=
  density_valid φ

/--
All dense-compatible TM axioms are valid over dense temporal orders.
This re-exports axiom_valid_dense from Soundness.lean.
-/
theorem axiom_dense_valid {φ : Formula} (h : Axiom φ) (h_dc : h.isDenseCompatible) :
    valid_dense φ :=
  axiom_valid_dense h h_dc

end Bimodal.Metalogic.DenseSoundness
