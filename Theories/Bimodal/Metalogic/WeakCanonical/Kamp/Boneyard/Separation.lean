/-
================================================================================
ARCHIVED — BIT-ROTTED DEAD CODE (Kamp Boneyard). MOVE-not-delete; never empty.
================================================================================

This is the abandoned GHR separation / expressive-completeness ALTERNATIVE. It is
EXCLUDED FROM THE BUILD (outside the Bimodal.lean import closure — uncompiled) and does
NOT COMPILE. A `grep -c sorry == 0` on this file is MEANINGLESS: uncompiled code trivially
has no sorry. This is NOT sorry-free, verified, or reusable code.

It is OFF the faithful Rabinovich path (Def 4.1, PDF p.5). Do NOT consume or reuse it for
the k>=2 E[Sigma] re-architecture.

Key declarations: (directory aggregator for the bit-rotted GHR separation cluster)
-/
import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.FormulaOps
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.IntHelpers
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.Duality
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.Distributivity
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.NegationEquiv
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.Eliminations
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.NormalForm
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.DualEliminations
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.Hierarchy.HierarchyDefs
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.Hierarchy.HierarchyInduction
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.Hierarchy.HierarchyCompletion
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.Separation.SeparationThm

/-!
# Separation Module Hub

Imports all submodules of the separation theorem proof for {U,S} over integer time.

## Architecture

- `Defs.lean`: IntStructure, int_truth, purity predicates, separation predicates, measures
- `FormulaOps.lean`: Substitution, DNF/CNF signatures, freshness
- `IntHelpers.lean`: Integer-specific lemmas (finite intervals, witness constructions)
- `Duality.lean`: Temporal duality (swap_temporal preserves int_truth)
- `Distributivity.lean`: Lemma 10.2.1 (U/S distribute over boolean ops)
- `NegationEquiv.lean`: Lemma 10.2.2 (negation of U/S over Z)
- `Eliminations.lean`: Lemma 10.2.3 (8 elimination cases)
- `NormalForm.lean`: Lemma 10.2.4 (normal form reduction to 8 cases)
- `Hierarchy.lean`: Lemma 10.2.5 (single-U elimination via structural induction)
- `DualEliminations.lean`: Dual of Lemma 10.2.3 (S out of U)
- `SeparationThm.lean`: Lemmas 10.2.5-10.2.8 and Theorem 10.2.9

## References

- GHR94, Chapter 10, Section 10.2 (Separation Theorem)
- GHR94, Chapter 9, Section 9.3 (Separation implies Expressive Completeness)
-/
