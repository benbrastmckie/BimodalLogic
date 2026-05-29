import Bimodal.Metalogic.WeakCanonical.PriorExpressiveness
import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures

/-!
# Reynolds No-Gaps Theorem and Archimedean One-Class Theorem

This file provides the key theorems needed to close the sorry sites in the
Reynolds completeness pipeline:

1. `one_class_archimedean`: In any discrete archimedean linear order with
   successor/predecessor, all points are contemporaneously equivalent.
   This does NOT require Prior-UZ/SZ -- the archimedean property suffices.

2. `no_gaps_discrete_archimedean`: The archimedean specialization of
   `no_gaps_discrete`. Since all points are equivalent, the premise
   (a ≁ b) is vacuously false.

## Mathematical Content

In an `IsSuccArchimedean` discrete linear order:
- Every closed interval [a,b] is finite (by `subinterval_finite_of_succ_archimedean`)
- Every finite structure is good (by `finite_structures_good`)
- Therefore every subinterval is good, hence every structure is very good
- Therefore all points are contemporaneously equivalent

This is a simpler proof than the full Reynolds Theorem 14 (which does not
require archimedean). The full Reynolds argument (Lemmas 6-13, model surgery)
proves the result for ALL discrete Prior structures, not just archimedean ones.
However, for the completeness pipeline, the chronicle structure IS archimedean
(`ChronicleAsPriorModel` bundles `domain_succ_archimedean`), so the archimedean
version suffices to close all sorry sites.

## References

- Reynolds 1994, Section 7, Theorem 14 (general version)
- Reynolds 1994, Section 8, Theorem 15 (one-class theorem)
- Doets 1989, Theorem 1.1 (finite structures are good)
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Archimedean Very-Good Theorem

In an archimedean discrete linear order, every structure is very good.
-/

/--
In a successor-archimedean discrete linear order, every subinterval is finite,
hence good. Therefore every structure is very good.
-/
theorem very_good_of_archimedean (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier]
    [IsSuccArchimedean M.carrier] :
    very_good sig k M := by
  intro a b hab
  -- The subinterval [a,b] is finite in an archimedean order
  haveI h_fin : Finite (M.subinterval sig a b).carrier :=
    subinterval_finite_of_succ_archimedean sig M a b hab
  haveI : Fintype (M.subinterval sig a b).carrier := Fintype.ofFinite _
  -- good requires k-equiv to a Z-interval; finite structures are good
  exact finite_structures_good sig k _

/--
**Archimedean One-Class Theorem**: In any discrete archimedean linear order
without endpoints, all points are contemporaneously equivalent.

This is a consequence of the fact that in archimedean orders, all subintervals
are finite, hence good, hence every structure is very good.

No Prior-UZ/SZ hypotheses are needed -- the archimedean property alone suffices.
-/
theorem one_class_archimedean (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier]
    [IsSuccArchimedean M.carrier] :
    ∀ (a b : M.carrier), contemp_equiv sig k M a b := by
  intro a b
  simp only [contemp_equiv, very_good]
  intro x y hxy
  -- x, y are in (M.subinterval sig (min a b) (max a b)).carrier
  -- Need: good sig k of the sub-subinterval
  -- By subinterval_of_subinterval_k_equiv, the sub-subinterval is k-equiv to
  -- M.subinterval sig x.val y.val
  have h_k_equiv := subinterval_of_subinterval_k_equiv sig k M (min a b) (max a b) x y
  -- M.subinterval sig x.val y.val is finite (archimedean)
  have hxy_val : x.val ≤ y.val := hxy
  haveI : Finite (M.subinterval sig x.val y.val).carrier :=
    subinterval_finite_of_succ_archimedean sig M x.val y.val hxy_val
  haveI : Fintype (M.subinterval sig x.val y.val).carrier := Fintype.ofFinite _
  -- Finite structures are good
  obtain ⟨Z, hZ⟩ := finite_structures_good sig k (M.subinterval sig x.val y.val)
  exact ⟨Z, h_k_equiv.trans hZ⟩

/--
**Archimedean No-Gaps Theorem**: Specialization of `no_gaps_discrete` for
archimedean orders. The premise ¬contemp_equiv a b is always false
(by `one_class_archimedean`), so the conclusion holds vacuously.

This version does NOT require Prior-UZ/SZ. It can be used in place of
`no_gaps_discrete` wherever the underlying order is archimedean.
-/
theorem no_gaps_discrete_archimedean (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [IsSuccArchimedean M.carrier]
    (a b : M.carrier) (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c) := by
  -- The premise is always false: all points are contemp_equiv in archimedean orders
  exact absurd (one_class_archimedean sig k M a b) h_diff_class

end Bimodal.Metalogic.WeakCanonical
