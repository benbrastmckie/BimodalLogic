import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.FormulaOps
import Bimodal.Metalogic.WeakCanonical.Separation.IntHelpers
import Bimodal.Metalogic.WeakCanonical.Separation.Duality
import Bimodal.Metalogic.WeakCanonical.Separation.Distributivity
import Bimodal.Metalogic.WeakCanonical.Separation.NegationEquiv
import Bimodal.Metalogic.WeakCanonical.Separation.Eliminations
import Bimodal.Metalogic.WeakCanonical.Separation.NormalForm
import Bimodal.Metalogic.WeakCanonical.Separation.DualEliminations
import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy.HierarchyDefs
import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy.HierarchyInduction
import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy.HierarchyCompletion
import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm

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
