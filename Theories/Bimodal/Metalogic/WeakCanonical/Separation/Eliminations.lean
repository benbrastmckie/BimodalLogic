import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.NegationEquiv
import Bimodal.Metalogic.WeakCanonical.Separation.Distributivity

/-!
# Elimination Cases (GHR94 Lemma 10.2.3)

The eight elimination cases that form the core of the separation proof.
Each case eliminates a nested U from under an S, producing an equivalent
formula where U(A,B) appears only at top level (not under S).

## Key Results

- `elim_case_1`: S(a ^ U(A,B), q)
- `elim_case_2`: S(a ^ not U(A,B), q)
- `elim_case_3`: S(a, q v U(A,B))
- `elim_case_4`: S(a, q v not U(A,B))
- `elim_case_5`: S(a ^ U(A,B), q v U(A,B))
- `elim_case_6`: S(a ^ not U(A,B), q v U(A,B))
- `elim_case_7`: S(a ^ U(A,B), q v not U(A,B))
- `elim_case_8`: S(a ^ not U(A,B), q v not U(A,B))

## References

- GHR94, Lemma 10.2.3, pp. 572-580
- Research report Section 4.3
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Case 1: S(a ^ U(A,B), q)

The three disjuncts correspond to the U(A,B)-witness being:
- u > t (future): Then B holds from s to u, covering (s,t); plus B at t; plus U(A,B) at t.
- u = t (present): A at t; B held from s to t.
- u < t (past): A was true at some u in (s,t); B held from s to u.
-/

/-- CASE 1: S(a ^ U(A,B), q) where a, q, A, B are U-free and S-free.

    Equivalent to:
      [S(a, q) ^ S(a, B) ^ B ^ U(A,B)]     -- U-witness after t
      v [A ^ S(a, B) ^ S(a, q)]              -- U-witness AT t
      v S(A ^ q ^ S(a, B) ^ S(a, q), q)     -- U-witness before t

    The output formula has U(A,B) only at top level. -/
theorem elim_case_1 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (.untl A B)) q) psi ∧
      is_U_free psi = true := by
  sorry

/-! ## Case 5: S(a ^ U(A,B), q v U(A,B))

Split on whether the U-witness is in the past, present, or future of t.
-/

/-- CASE 5: S(a ^ U(A,B), q v U(A,B)) where a, q, A, B are U-free and S-free.

    This case is more complex than Case 1 because the guard also contains U(A,B).
    The key observation is that if U(A,B) holds at r (between s and t), then
    the guard is satisfied at r regardless of q.

    The output formula has U(A,B) only at top level. -/
theorem elim_case_5 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (.untl A B)) (Formula.or q (.untl A B))) psi ∧
      is_U_free psi = true := by
  sorry

/-! ## Case 2: S(a ^ not U(A,B), q) -/

/-- CASE 2: S(a ^ not U(A,B), q).
    Strategy: apply neg_until_equiv to rewrite not U(A,B), then reduce. -/
theorem elim_case_2 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (Formula.neg (.untl A B))) q) psi ∧
      is_U_free psi = true := by
  sorry

/-! ## Case 4: S(a, q v not U(A,B)) -/

/-- CASE 4: S(a, q v not U(A,B)).
    Strategy: direct semantic argument about the "safe zone". -/
theorem elim_case_4 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce a (Formula.or q (Formula.neg (.untl A B)))) psi ∧
      is_U_free psi = true := by
  sorry

/-! ## Case 3: S(a, q v U(A,B)) -/

/-- CASE 3: S(a, q v U(A,B)).
    Strategy: negate, use 10.2.2, apply Case 2. -/
theorem elim_case_3 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce a (Formula.or q (.untl A B))) psi ∧
      is_U_free psi = true := by
  sorry

/-! ## Case 6: S(a ^ not U(A,B), q v U(A,B)) -/

/-- CASE 6: S(a ^ not U(A,B), q v U(A,B)).
    Strategy: reduces to Cases 3, 5. -/
theorem elim_case_6 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (Formula.neg (.untl A B)))
        (Formula.or q (.untl A B))) psi ∧
      is_U_free psi = true := by
  sorry

/-! ## Case 7: S(a ^ U(A,B), q v not U(A,B)) -/

/-- CASE 7: S(a ^ U(A,B), q v not U(A,B)).
    Strategy: reduces to Cases 4, 8. -/
theorem elim_case_7 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (.untl A B))
        (Formula.or q (Formula.neg (.untl A B)))) psi ∧
      is_U_free psi = true := by
  sorry

/-! ## Case 8: S(a ^ not U(A,B), q v not U(A,B)) -/

/-- CASE 8: S(a ^ not U(A,B), q v not U(A,B)).
    Strategy: negate, reduce to Case 5. -/
theorem elim_case_8 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) :
    ∃ psi : Formula,
      int_equiv (.snce (Formula.and a (Formula.neg (.untl A B)))
        (Formula.or q (Formula.neg (.untl A B)))) psi ∧
      is_U_free psi = true := by
  sorry

end Bimodal.Metalogic.WeakCanonical.Separation
