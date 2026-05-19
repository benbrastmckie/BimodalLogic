import Bimodal.Metalogic.WeakCanonical.Separation.Eliminations
import Bimodal.Metalogic.WeakCanonical.Separation.Duality
import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm

/-!
# Dual Elimination Cases (S out of U)

The 8 dual cases (pulling S out from under U) follow from the master
separability theorem `all_separable` combined with the duality principle.

Each theorem concludes `is_separable`, which follows directly from
`all_separable` (every formula is separable over integer time).

## References

- GHR94, Lemma 10.2.3 (dual)
- These are obtained by temporal duality (swap_temporal)
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-- CASE 1 DUAL: U(a ^ S(A,B), q) where a, q, A, B are U-free and S-free.
    Derived from elim_case_1 via swap_temporal. -/
theorem elim_case_1_dual (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.untl (Formula.and a (.snce A B)) q) :=
  all_separable _

/-- CASE 2 DUAL: U(a ^ not S(A,B), q). -/
theorem elim_case_2_dual (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.untl (Formula.and a (Formula.neg (.snce A B))) q) :=
  all_separable _

/-- CASE 3 DUAL: U(a, q v S(A,B)). -/
theorem elim_case_3_dual (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.untl a (Formula.or q (.snce A B))) :=
  all_separable _

/-- CASE 4 DUAL: U(a, q v not S(A,B)). -/
theorem elim_case_4_dual (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.untl a (Formula.or q (Formula.neg (.snce A B)))) :=
  all_separable _

/-- CASE 5 DUAL: U(a ^ S(A,B), q v S(A,B)). -/
theorem elim_case_5_dual (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.untl (Formula.and a (.snce A B)) (Formula.or q (.snce A B))) :=
  all_separable _

/-- CASE 6 DUAL: U(a ^ not S(A,B), q v S(A,B)). -/
theorem elim_case_6_dual (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.untl (Formula.and a (Formula.neg (.snce A B)))
      (Formula.or q (.snce A B))) :=
  all_separable _

/-- CASE 7 DUAL: U(a ^ S(A,B), q v not S(A,B)). -/
theorem elim_case_7_dual (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.untl (Formula.and a (.snce A B))
      (Formula.or q (Formula.neg (.snce A B)))) :=
  all_separable _

/-- CASE 8 DUAL: U(a ^ not S(A,B), q v not S(A,B)). -/
theorem elim_case_8_dual (a q A B : Formula)
    (_ha : is_U_free a = true) (_hq : is_U_free q = true)
    (_hA : is_U_free A = true) (_hB : is_U_free B = true)
    (_ha' : is_S_free a = true) (_hq' : is_S_free q = true)
    (_hA' : is_S_free A = true) (_hB' : is_S_free B = true) :
    is_separable (.untl (Formula.and a (Formula.neg (.snce A B)))
      (Formula.or q (Formula.neg (.snce A B)))) :=
  all_separable _

end Bimodal.Metalogic.WeakCanonical.Separation
