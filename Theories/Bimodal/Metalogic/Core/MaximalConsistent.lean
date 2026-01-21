import Bimodal.Boneyard.Metalogic_v2.Core.MaximalConsistent

/-!
# Maximal Consistent Sets for Universal Parametric Canonical Model

This module re-exports the essential MCS theory from the Boneyard infrastructure
and adds any additional lemmas needed for the universal parametric approach.

## Re-exported Definitions

From `Bimodal.Boneyard.Metalogic_v2.Core`:
- `SetConsistent`: Set-based consistency
- `SetMaximalConsistent`: Set-based maximal consistency
- `set_lindenbaum`: Lindenbaum's lemma
- `maximal_negation_complete`: MCS negation completeness
- `maximal_consistent_closed`: MCS deductive closure
- `theorem_in_mcs`: Theorems in every MCS

## Additional Lemmas

This module may add lemmas specifically needed for the universal canonical model
construction, particularly around formula membership in MCS.
-/

namespace Bimodal.Metalogic.Core

-- Re-export essential definitions
open Bimodal.Metalogic_v2.Core in
export Bimodal.Metalogic_v2.Core (
  Consistent
  MaximalConsistent
  SetConsistent
  SetMaximalConsistent
  ConsistentExtensions
  ConsistentSupersets
  contextToSet
  usedFormulas
  set_lindenbaum
  consistent_implies_set_consistent
  consistent_chain_union
  finite_list_in_chain_member
  inconsistent_derives_bot
  derives_neg_from_inconsistent_extension
  derives_bot_from_phi_neg_phi
  maximal_extends_inconsistent
  set_mcs_finite_subset_consistent
  maximal_consistent_closed
  maximal_negation_complete
  theorem_in_mcs
  base_mem_consistent_extensions
  self_mem_consistent_supersets
  usedFormulas_subset
  derivation_uses_finite_context
)

end Bimodal.Metalogic.Core
