import Bimodal.Metalogic.Soundness
import Bimodal.Semantics.Validity

/-!
# Dense Soundness - Soundness of Dense-Compatible Axioms

This module proves that all axioms with `minFrameClass ≤ FrameClass.Dense` are
valid with respect to the `valid_dense` notion of validity (restricted to densely
ordered temporal types).

## Main Results

- `density_sound_dense`: The density axiom (GGφ → Gφ) is valid over all dense temporal orders
- `axiom_dense_valid`: All dense-compatible axioms are valid over dense orders

## Implementation Notes

With irreflexive temporal semantics (< instead of ≤), the density axiom GGφ → Gφ
genuinely requires intermediate points (DenselyOrdered). Base axioms are universally valid
and hence trivially valid on dense frames. Discrete-specific axioms (prior_UZ, prior_SZ, z1)
have `minFrameClass = .Discrete` which is incomparable with `.Dense`, so they are excluded
by the `h.minFrameClass ≤ FrameClass.Dense` constraint.

## References

- Research-013 Section 3.2: DN soundness for dense frames
- Research-016: Irreflexive semantics feasibility
-/

namespace Bimodal.Metalogic.DenseSoundness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/--
The density axiom GGφ → Gφ is valid over all densely ordered temporal types.
-/
theorem density_sound_dense (φ : Formula) :
    valid_dense ((φ.all_future.all_future).imp φ.all_future) :=
  density_valid φ

/--
All axioms with `minFrameClass ≤ .Dense` are valid over dense temporal orders.
This re-exports `axiom_dense_valid` from Soundness.lean.
-/
theorem axiom_dense_valid' {φ : Formula} (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Dense) :
    valid_dense φ :=
  axiom_dense_valid h h_fc

end Bimodal.Metalogic.DenseSoundness
