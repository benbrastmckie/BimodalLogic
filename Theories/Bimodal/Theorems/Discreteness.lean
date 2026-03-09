import Bimodal.ProofSystem.Derivation

/-!
# Discreteness - DP Derived from DF via Temporal Duality

This module derives the backward discreteness axiom (DP) from the forward
discreteness axiom (DF) using the temporal_duality inference rule.

## Main Results

- `discreteness_past`: `⊢ (P⊤ ∧ φ ∧ Gφ) → P(Gφ)` derived from DF via temporal_duality

## Derivation Strategy

1. Instantiate DF at `swap_temporal(φ)`:
   `⊢ (F⊤ ∧ swap(φ) ∧ H(swap(φ))) → F(H(swap(φ)))`
2. Apply temporal_duality to swap all_past ↔ all_future:
   `⊢ (P⊤ ∧ swap(swap(φ)) ∧ G(swap(swap(φ)))) → P(G(swap(swap(φ))))`
3. By swap_temporal_involution (swap is an involution), swap(swap(φ)) = φ:
   `⊢ (P⊤ ∧ φ ∧ Gφ) → P(Gφ)`

## References

- Research-013 Section 3.3: DP derivable from DF via temporal_duality
- `Bimodal.ProofSystem.Axioms`: DF axiom definition
- `Bimodal.Syntax.Formula.swap_temporal_involution`: swap is involutive
-/

namespace Bimodal.Theorems.Discreteness

open Bimodal.Syntax
open Bimodal.ProofSystem

/--
The backward discreteness axiom (DP) is derivable from the forward discreteness
axiom (DF) via the temporal_duality inference rule.

DP: `(P⊤ ∧ φ ∧ Gφ) → P(Gφ)`

This states: if there is a strict past time (P⊤), and φ holds now and at all
future times (Gφ), then there exists a past time where Gφ holds.

The proof instantiates DF at `swap_temporal(φ)` and applies temporal_duality,
using the fact that swap_temporal is an involution to simplify back to φ.
-/
def discreteness_past (φ : Formula) :
    ⊢ (Formula.and (Formula.bot.neg.some_past)
      (Formula.and φ (Formula.all_future φ)) |>.imp
      (Formula.all_future φ).some_past) := by
  -- Step 1: DF at swap_temporal(φ)
  have h_df : ⊢ (Formula.and (Formula.bot.neg.some_future)
    (Formula.and φ.swap_temporal (Formula.all_past φ.swap_temporal)) |>.imp
    (Formula.all_past φ.swap_temporal).some_future) :=
    DerivationTree.axiom [] _ (Axiom.discreteness_forward φ.swap_temporal)
  -- Step 2: Apply temporal_duality
  have h_swap := DerivationTree.temporal_duality _ h_df
  -- Step 3: The result of swapping should be DP at swap(swap(φ)) = DP at φ
  -- We need to show that the swapped formula equals the target formula.
  -- swap_temporal(DF(swap φ)) should equal DP(φ) by involution.
  have h_eq : (Formula.and (Formula.bot.neg.some_future)
    (Formula.and φ.swap_temporal (Formula.all_past φ.swap_temporal)) |>.imp
    (Formula.all_past φ.swap_temporal).some_future).swap_past_future =
    (Formula.and (Formula.bot.neg.some_past)
      (Formula.and φ (Formula.all_future φ)) |>.imp
      (Formula.all_future φ).some_past) := by
    simp [Formula.swap_temporal, Formula.swap_past_future, Formula.and, Formula.neg,
          Formula.some_future, Formula.some_past, Formula.imp,
          Formula.swap_temporal_involution]
  rw [h_eq] at h_swap
  exact h_swap

end Bimodal.Theorems.Discreteness
