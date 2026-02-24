import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms

/-!
# Linearity Derived Facts

This module documents the linearity analysis for TM logic and provides
derived consequences of the `temp_linearity` axiom.

## Non-Derivability of Linearity from Original TM Axioms

**Theorem (informal)**: The linearity schema
  `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)`
is NOT derivable from the original 16 TM axioms (prop_k, prop_s, ex_falso, peirce,
modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist, temp_k_dist, temp_4,
temp_a, temp_l, temp_t_future, temp_t_past, modal_future, temp_future).

**Counterexample**: Consider the frame with 3 points {0, 1a, 1b} where:
- The temporal relation is: 0 R 0, 1a R 1a, 1b R 1b, 0 R 1a, 0 R 1b
  (but NOT 1a R 1b or 1b R 1a)
- The S5 modal accessibility is universal (all 3 points see each other)

This frame is:
- Reflexive (satisfying temp_t_future, temp_t_past)
- Transitive (satisfying temp_4)
- Connected via temp_a: for any point x and y > x, P(phi) holds at y
  if phi holds at x (with x as the past witness)
- Satisfies temp_l: "always phi" at a point means phi at all 3 points,
  which trivially gives G(H(phi))
- Satisfies all S5 modal axioms and modal-temporal interaction axioms
- But is NOT linearly ordered: 1a and 1b are incomparable

The linearity schema fails in this frame: at point 0, let phi be true only at 1a
and psi be true only at 1b. Then F(phi) and F(psi) hold at 0, but:
- F(phi and psi) fails (phi and psi are never simultaneously true)
- F(phi and F(psi)) fails (at 1a, F(psi) fails since psi is not at 1a or later)
- F(F(phi) and psi) fails (at 1b, F(phi) fails since phi is not at 1b or later)

## Resolution: temp_linearity Axiom (Task 922)

The `temp_linearity` axiom was added to the Axiom inductive type to enforce linearity
of the temporal order. This is sound for the intended linear integer time semantics
(proven in SoundnessLemmas.lean and Soundness.lean).

**Technical debt**: This axiom extends the TM system. Remediation options:
1. Derive from existing axioms (currently believed impossible based on counterexample)
2. Document as a permanent axiom of TM for linear time completeness
3. The axiom is standard in tense logics of linear orders (Kt.Li, see Goldblatt 1992)

## Past Linearity via Temporal Duality

The past version of linearity:
  `P(phi) and P(psi) -> P(phi and psi) or P(phi and P(psi)) or P(P(phi) and psi)`
is derivable from `temp_linearity` via the temporal duality rule (swap_temporal).
This is handled automatically by `DerivationTree.temporal_duality`.

## References

- Task 922 research-001.md: Meta-analysis identifying linearity gap
- Task 922 research-002.md: Detailed linearity analysis, revised confidence
- Goldblatt 1992, *Logics of Time and Computation*
- Blackburn, de Rijke, Venema 2001, *Modal Logic*
-/

namespace Bimodal.ProofSystem

open Bimodal.Syntax

/--
The temporal linearity axiom as a derivation from the empty context.

This provides a convenient way to use the linearity axiom in proofs.
-/
noncomputable def temp_linearity_derivation (φ ψ : Formula) :
    [] ⊢ (Formula.and (Formula.some_future φ) (Formula.some_future ψ) |>.imp
      (Formula.or (Formula.some_future (Formula.and φ ψ))
        (Formula.or (Formula.some_future (Formula.and φ (Formula.some_future ψ)))
          (Formula.some_future (Formula.and (Formula.some_future φ) ψ))))) :=
  DerivationTree.axiom [] _ (Axiom.temp_linearity φ ψ)

end Bimodal.ProofSystem
