import Bimodal.Syntax.Formula

/-!
# Temporal Content Definitions

Shared definitions for g_content and h_content used by both
`TemporalCoherentConstruction.lean` and `DovetailingChain.lean`.

Extracted to break an import cycle between those two modules.
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax

/--
g_content of an MCS: the set of all formulas phi where G phi appears in the MCS.

**Important**: g_content strips F-formulas. If F(psi) is in M, psi will NOT
appear in g_content(M) unless G(psi) is also in M. This means F-formulas do NOT
persist through g_content seeds in chain constructions. Resolution of F-obligations
requires a non-linear construction (e.g., omega-squared) rather than relying on
linear g_content propagation. See DovetailingChain.lean and Task 916 research for details.
-/
def g_content (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}

/--
h_content of an MCS: the set of all formulas phi where H phi appears in the MCS.

**Important**: h_content strips P-formulas. If P(psi) is in M, psi will NOT
appear in h_content(M) unless H(psi) is also in M. This means P-formulas do NOT
persist through h_content seeds in chain constructions. Symmetric to g_content.
-/
def h_content (M : Set Formula) : Set Formula :=
  {phi | Formula.all_past phi ∈ M}

end Bimodal.Metalogic.Bundle
