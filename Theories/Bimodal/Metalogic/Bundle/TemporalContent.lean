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
-/
def GContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_future phi ∈ M}

/--
HContent of an MCS: the set of all formulas phi where H phi appears in the MCS.
-/
def HContent (M : Set Formula) : Set Formula :=
  {phi | Formula.all_past phi ∈ M}

end Bimodal.Metalogic.Bundle
