/-!
# Archived Orphan Code from FMP/Closure.lean

This file contains theorems that were removed from the active FMP module because
they are never used in the completeness proof chain and contain unresolved sorries.

## Contents

- `diamond_in_closureWithNeg_of_box`: An attempt to show that diamond formulas
  are in closureWithNeg when the corresponding box formula is in closure.
  The lemma is not provable as stated because `Box(neg psi)` may not be a
  subformula even when `Box psi` is.

## Why Archived

The `fmp_weak_completeness` theorem is **sorry-free** and does not depend on
this lemma. Archiving this code ensures:
1. The FMP module has no sorries in the active completeness chain
2. This attempted approach is preserved for reference
3. Future work can revisit if needed

## Date Archived

2026-02-04

## Original Location

`Theories/Bimodal/Metalogic/FMP/Closure.lean`, lines 719-728

-/

import Bimodal.Metalogic.FMP.Closure

namespace Bimodal.Metalogic.FMP.Boneyard

open Bimodal.Syntax Bimodal.Metalogic.FMP

/--
Diamond psi = neg(Box(neg psi)) membership in closureWithNeg.

**Status**: NOT PROVABLE as stated.

The issue is that `Box(neg psi)` is not necessarily a subformula of phi
even when `Box psi` is. The diamond formula `neg(Box(neg psi))` requires
`Box(neg psi)` to be in closure, which is not guaranteed.

**Usage**: This lemma was never used in the completeness proof chain.
The FMP approach bypasses this issue entirely by working directly with
MCS projections.
-/
theorem diamond_in_closureWithNeg_of_box (phi psi : Formula)
    (h : Formula.box psi ∈ closure phi) :
    Formula.neg (Formula.box (Formula.neg psi)) ∈ closureWithNeg phi := by
  -- We have Box psi in closure phi
  -- By subformula property, psi in closure phi
  -- So psi.neg in closureWithNeg phi
  -- And Box(psi.neg) needs to be in closureWithNeg... but it may not be!
  -- Actually, this lemma is not generally true.
  -- The diamond formula may not be a subformula of phi.
  sorry

end Bimodal.Metalogic.FMP.Boneyard
