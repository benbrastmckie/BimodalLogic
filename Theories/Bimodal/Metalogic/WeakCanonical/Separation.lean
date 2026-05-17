import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.FormulaOps
import Bimodal.Metalogic.WeakCanonical.Separation.IntHelpers
import Bimodal.Metalogic.WeakCanonical.Separation.Duality
import Bimodal.Metalogic.WeakCanonical.Separation.Distributivity
import Bimodal.Metalogic.WeakCanonical.Separation.NegationEquiv
import Bimodal.Metalogic.WeakCanonical.Separation.Eliminations

/-!
# Separation Module Hub

Imports all submodules of the separation theorem proof for {U,S} over integer time.

## Architecture

- `Defs.lean`: IntStructure, int_truth, purity predicates, separation predicates, measures
- `FormulaOps.lean`: Substitution, DNF/CNF signatures, freshness
- `IntHelpers.lean`: Integer-specific lemmas (finite intervals, witness constructions)

## References

- GHR94, Chapter 10, Section 10.2 (Separation Theorem)
- GHR94, Chapter 9, Section 9.3 (Separation implies Expressive Completeness)
-/
