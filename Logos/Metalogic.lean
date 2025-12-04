import Logos.Metalogic.Soundness
import Logos.Metalogic.Completeness
-- import Logos.Metalogic.Decidability  -- Future work

/-!
# Metalogic - Soundness and Completeness for TM

This module provides metalogical results for the bimodal logic TM.

## Main Modules

- `Soundness`: Soundness theorem (syntactic derivability implies semantic validity)
- `Completeness`: Completeness theorem (semantic validity implies syntactic derivability)
- `Decidability`: Decision procedures

## Main Results

- **Soundness**: `Γ ⊢ φ → Γ ⊨ φ` (derivability implies validity)
- **Weak Completeness**: `⊨ φ → ⊢ φ` (validity implies derivability from empty context)
- **Strong Completeness**: `Γ ⊨ φ → Γ ⊢ φ` (semantic consequence implies syntactic derivability)

## Implementation Notes

- Soundness is proven by induction on derivation structure
- Each axiom requires validity proof
- Each inference rule requires validity preservation proof
- Completeness uses canonical model construction (post-MVP)

## References

* [ARCHITECTURE.md](../../docs/ARCHITECTURE.md) - Metalogic specification
* [ProofSystem](../ProofSystem.lean) - Derivability relation
* [Semantics](../Semantics.lean) - Validity and semantic consequence
-/
