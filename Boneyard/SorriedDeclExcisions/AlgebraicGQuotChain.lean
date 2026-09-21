import FormalSystem.ProofSystem
import FormalSystem.Metalogic.Core.MaximalConsistent
import FormalSystem.Theorems.Propositional.Connectives
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Perpetuity
import FormalSystem.Metalogic.Algebraic.BooleanStructure
import FormalSystem.Metalogic.Core.MCSProperties

/-!
# ARCHIVED (Boneyard) — never compiled.

Dead Algebraic G_quot closure: 5 declarations carrying 3 statement-position
sorries, with zero external call sites (every consumer of each declaration
below is itself a member of this closure).

From `Metalogic/Algebraic/LindenbaumQuotient.lean`:
- `provEquiv_all_future_congr` (2 sorries; sole consumer was `G_quot`)
- `G_quot` (consumers were exactly `G_monotone`, `sigma_quot_G_H`,
  `sigma_quot_H_G` — all in this closure)
- `sigma_quot_G_H` (sorry-free, 0 consumers)
- `sigma_quot_H_G` (sorry-free, 0 consumers)

From `Metalogic/Algebraic/InteriorOperators.lean`:
- `G_monotone` (1 sorry, 0 consumers)

The live keep-set remains in live code and is NOT part of this closure:
`H_quot`, `provEquiv_all_past_congr`, `H_monotone`, `sigma_quot`,
`sigma_quot_involution`, `sigma_quot_neg`, `sigma_quot_sup`, `sigma_quot_box`.
`BooleanStructure.lean` references none of the archived names.

Do not import from live code.
-/

#exit

/- ======================================================================
   Source: FormalSystem/Metalogic/Algebraic/LindenbaumQuotient.lean
   Original context: `namespace FormalSystem.Metalogic.Algebraic.LindenbaumQuotient`,
   `open FormalSystem.Syntax FormalSystem.ProofSystem`.
   ====================================================================== -/

/--
Provable equivalence respects all_future (G): `φ ≈ₚ ψ → Gφ ≈ₚ Gψ`.
-/
theorem provEquiv_all_future_congr {φ ψ : Formula} (h : φ ≈ₚ ψ) :
    φ.all_future ≈ₚ ψ.all_future := by
  unfold ProvEquiv Derives at *
  obtain ⟨⟨d_fwd⟩, ⟨d_bwd⟩⟩ := h
  constructor
  · have d_temp : DerivationTree FrameClass.Base [] (Formula.all_future (φ.imp ψ)) :=
      DerivationTree.temporal_necessitation (φ.imp ψ) d_fwd
    have d_k : DerivationTree FrameClass.Base [] ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) :=
      sorry -- temp_k_dist derivable from BX -- (sorry /- temp_k_dist removed in BX -/ φ ψ)
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_temp⟩
  · have d_temp : DerivationTree FrameClass.Base [] (Formula.all_future (ψ.imp φ)) :=
      DerivationTree.temporal_necessitation (ψ.imp φ) d_bwd
    have d_k : DerivationTree FrameClass.Base [] ((ψ.imp φ).all_future.imp (ψ.all_future.imp φ.all_future)) :=
      sorry -- temp_k_dist derivable from BX -- (sorry /- temp_k_dist removed in BX -/ ψ φ)
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_temp⟩

/--
Lifted all_future (G) on the Lindenbaum algebra.
-/
def G_quot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => toQuot φ.all_future)
    (fun _ _ h => Quotient.sound (provEquiv_all_future_congr h))

/--
Sigma swaps G and H: `σ(G a) = H(σ a)`.
-/
theorem sigma_quot_G_H (a : LindenbaumAlg) :
    sigma_quot (G_quot a) = H_quot (sigma_quot a) := by
  induction a using Quotient.ind
  rename_i φ
  show toQuot (φ.all_future.swap_temporal) = H_quot (toQuot φ.swap_temporal)
  simp only [Formula.swap_temporal_all_future]
  rfl

/--
Sigma swaps H and G: `σ(H a) = G(σ a)`.
-/
theorem sigma_quot_H_G (a : LindenbaumAlg) :
    sigma_quot (H_quot a) = G_quot (sigma_quot a) := by
  induction a using Quotient.ind
  rename_i φ
  show toQuot (φ.all_past.swap_temporal) = G_quot (toQuot φ.swap_temporal)
  simp only [Formula.swap_temporal_all_past]
  rfl

/- ======================================================================
   Source: FormalSystem/Metalogic/Algebraic/InteriorOperators.lean
   Original context: `namespace FormalSystem.Metalogic.Algebraic.InteriorOperators`,
   `open FormalSystem.Syntax FormalSystem.ProofSystem`,
   `open FormalSystem.Metalogic.Algebraic.LindenbaumQuotient`,
   `open FormalSystem.Metalogic.Algebraic.BooleanStructure`.
   ====================================================================== -/

/-!
## G Monotonicity (Valid Under Strict Semantics)
-/

/--
G is monotone: `φ ≤ ψ → Gφ ≤ Gψ`.

Uses K-distribution and temporal necessitation.
This property holds under both reflexive and strict semantics.
-/
theorem G_monotone (a b : LindenbaumAlg) (h : a ≤ b) : G_quot a ≤ G_quot b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  show Derives φ.all_future ψ.all_future
  have h' : Derives φ ψ := h
  obtain ⟨d⟩ := h'
  have d_temp : DerivationTree FrameClass.Base [] (Formula.all_future (φ.imp ψ)) :=
    DerivationTree.temporal_necessitation (φ.imp ψ) d
  have d_k : DerivationTree FrameClass.Base [] ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) :=
    sorry -- G(φ→ψ) → (Gφ→Gψ): needs derivation tree for temp_k_dist (BX3 + modus ponens under G)
  exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_temp⟩
