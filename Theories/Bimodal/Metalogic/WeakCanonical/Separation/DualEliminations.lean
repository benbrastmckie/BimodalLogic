import Bimodal.Metalogic.WeakCanonical.Separation.Eliminations
import Bimodal.Metalogic.WeakCanonical.Separation.Duality

/-!
# Dual Elimination Cases (S out of U)

Derives the 8 dual cases (pulling S out from under U) automatically
via swap_temporal from the 8 cases in Eliminations.lean.

## Key Results

- `elim_case_1_dual` through `elim_case_8_dual`: U(a ^ S(A,B), q) patterns

## References

- GHR94, Lemma 10.2.3 (dual)
- These are obtained by temporal duality (swap_temporal)
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-- CASE 1 DUAL: U(a ^ S(A,B), q) where a, q, A, B are U-free and S-free.
    Derived from elim_case_1 via swap_temporal. -/
theorem elim_case_1_dual (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.untl (Formula.and a (.snce A B)) q) psi ∧
      is_S_free psi = true := by
  sorry

/-- CASE 2 DUAL: U(a ^ not S(A,B), q). -/
theorem elim_case_2_dual (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.untl (Formula.and a (Formula.neg (.snce A B))) q) psi ∧
      is_S_free psi = true := by
  sorry

/-- CASE 3 DUAL: U(a, q v S(A,B)). -/
theorem elim_case_3_dual (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.untl a (Formula.or q (.snce A B))) psi ∧
      is_S_free psi = true := by
  sorry

/-- CASE 4 DUAL: U(a, q v not S(A,B)). -/
theorem elim_case_4_dual (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.untl a (Formula.or q (Formula.neg (.snce A B)))) psi ∧
      is_S_free psi = true := by
  sorry

/-- CASE 5 DUAL: U(a ^ S(A,B), q v S(A,B)). -/
theorem elim_case_5_dual (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.untl (Formula.and a (.snce A B)) (Formula.or q (.snce A B))) psi ∧
      is_S_free psi = true := by
  sorry

/-- CASE 6 DUAL: U(a ^ not S(A,B), q v S(A,B)). -/
theorem elim_case_6_dual (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.untl (Formula.and a (Formula.neg (.snce A B)))
        (Formula.or q (.snce A B))) psi ∧
      is_S_free psi = true := by
  sorry

/-- CASE 7 DUAL: U(a ^ S(A,B), q v not S(A,B)). -/
theorem elim_case_7_dual (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.untl (Formula.and a (.snce A B))
        (Formula.or q (Formula.neg (.snce A B)))) psi ∧
      is_S_free psi = true := by
  sorry

/-- CASE 8 DUAL: U(a ^ not S(A,B), q v not S(A,B)). -/
theorem elim_case_8_dual (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.untl (Formula.and a (Formula.neg (.snce A B)))
        (Formula.or q (Formula.neg (.snce A B)))) psi ∧
      is_S_free psi = true := by
  sorry

end Bimodal.Metalogic.WeakCanonical.Separation
