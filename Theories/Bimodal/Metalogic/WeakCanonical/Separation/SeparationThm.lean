import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.Eliminations
import Bimodal.Metalogic.WeakCanonical.Separation.DualEliminations
import Bimodal.Metalogic.WeakCanonical.Separation.FormulaOps
import Bimodal.Metalogic.WeakCanonical.Separation.Distributivity

/-!
# Separation Theorem (GHR94 Theorem 10.2.9)

The main separation theorem: every {U,S}-formula is equivalent to a
syntactically separated formula over integer time.

## Structure

The proof is consolidated in `Eliminations.lean` as `all_separable`.
This file provides the individual lemma statements from GHR94's
hierarchical proof structure (Lemmas 10.2.4-10.2.8) as corollaries.

## References

- GHR94, Lemmas 10.2.4-10.2.8, Theorem 10.2.9
- Research report Sections 4.4-4.9
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Lemma 10.2.4: Single S with Top-Level U(A,B) -/

/-- Lemma 10.2.4: If U only appears as the formula U(A,B) in S(C,F), where
    A,B are S/U-free and each appearance of U(A,B) in C,F is NOT under any S,
    then S(C,F) is separable.

    This follows directly from `all_separable`. -/
theorem single_S_with_U (C F A B : Formula)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.snce C F) :=
  all_separable _

/-! ## Lemma 10.2.5: Single U Formula -/

/-- Lemma 10.2.5: If A, B are S/U-free and the only U in D is U(A,B),
    then D is separable.

    This follows directly from `all_separable`. -/
theorem single_U_separable (A B D : Formula)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable D :=
  all_separable D

/-! ## Lemma 10.2.6: Multiple U Formulas -/

/-- Lemma 10.2.6: If the only appearances of U in D are as U(A_i, B_i)
    where each A_i, B_i is S/U-free, then D is separable.

    This follows directly from `all_separable`. -/
theorem multi_U_separable (D : Formula) :
    is_separable D :=
  all_separable D

/-! ## Lemma 10.2.7: No S within U -/

/-- Lemma 10.2.7: If D contains no S nested within a U, then D is separable.

    This follows directly from `all_separable`. -/
theorem no_S_within_U_separable (D : Formula)
    (_hD : no_S_nested_in_U D) :
    is_separable D :=
  all_separable D

/-! ## Lemma 10.2.8: General Case (Junction Depth) -/

/-- Lemma 10.2.8 (Main Separation Lemma): Every {U,S}-formula is
    syntactically separable over integer time.

    This is `all_separable` from Eliminations.lean. -/
theorem junction_depth_separable (D : Formula) :
    is_separable D :=
  all_separable D

/-! ## Theorem 10.2.9: Separation Theorem -/

/-- Theorem 10.2.9 (Separation Theorem): Each wff in the language with
    {U, S} is equivalent, over the integer flow of time, to a separated wff.

    This follows directly from junction_depth_separable. -/
theorem separation_theorem_int (phi : Formula) :
    is_separable phi :=
  junction_depth_separable phi

end Bimodal.Metalogic.WeakCanonical.Separation
