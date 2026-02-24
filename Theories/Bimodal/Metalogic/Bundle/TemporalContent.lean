import Bimodal.Syntax.Formula

/-!
# Temporal Content Definitions

Shared definitions for GContent and HContent used by both
`TemporalCoherentConstruction.lean` and `DovetailingChain.lean`.

Extracted to break an import cycle between those two modules.
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax

/--
GContent of an MCS: the set of all formulas phi where G phi appears in the MCS.

**Important**: GContent strips F-formulas. If F(psi) is in M, psi will NOT
appear in GContent(M) unless G(psi) is also in M. This means F-formulas do NOT
persist through GContent seeds in chain constructions. Resolution of F-obligations
requires a non-linear construction (e.g., omega-squared) rather than relying on
linear GContent propagation. See DovetailingChain.lean and Task 916 research for details.
-/
def GContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}

/--
HContent of an MCS: the set of all formulas phi where H phi appears in the MCS.

**Important**: HContent strips P-formulas. If P(psi) is in M, psi will NOT
appear in HContent(M) unless H(psi) is also in M. This means P-formulas do NOT
persist through HContent seeds in chain constructions. Symmetric to GContent.
-/
def HContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_past phi ∈ M}

end Bimodal.Metalogic.Bundle
