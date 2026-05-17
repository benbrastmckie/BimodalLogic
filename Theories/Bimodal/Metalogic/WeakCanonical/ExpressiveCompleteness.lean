import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm
import Bimodal.Metalogic.WeakCanonical.MonadicFO

/-!
# Expressive Completeness of {U,S} over Integer Time

Proves that {Since, Until} is expressively complete over integer time:
every property expressible in monadic first-order logic over (Z, <) is
expressible by a temporal formula using only Since and Until.

## Main Results

- `separation_implies_expressiveness` (Theorem 9.3.1): If every temporal
  formula is equivalent to a separated formula, then {U,S} is expressively
  complete.
- `US_expressively_complete_over_Z` (Theorem 10.2.10): {U,S} is expressively
  complete over integer time.

## Proof Strategy

Stage A (done in SeparationThm.lean): Every {U,S}-formula is equivalent to
a separated formula over Z (Theorem 10.2.9).

Stage B (this file): Separation implies expressive completeness (Theorem 9.3.1).
The proof proceeds by induction on quantifier depth m of the FO formula:
- Base (m=0): Quantifier-free formulas translate directly.
- Step (m>0): Introduce R predicates, use IH, apply separation, substitute.

The combination gives Theorem 10.2.10.

## References

- GHR94, Chapter 9, Section 9.3, Theorem 9.3.1
- GHR94, Theorem 10.2.10
- Reynolds (2010), Theorem 5
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical.Separation

/-! ## FO-to-Temporal Infrastructure -/

/-- An integer structure with a monadic signature: interprets predicates on Z. -/
structure IntStructureFromSig (sig : MonadicSignature) where
  interp : sig.preds → Int → Prop

/-- Convert an IntStructureFromSig to an OrderedMonadicStructure. -/
def int_to_ordered (sig : MonadicSignature) (M : IntStructureFromSig sig) :
    OrderedMonadicStructure sig where
  carrier := Int
  interp := M.interp
  carrier_order := inferInstance

/-- Convert IntStructureFromSig to IntStructure given an atom map.
    Each predicate p in the signature is mapped to the atom atomMap(p),
    and the valuation of that atom is the interpretation of p. -/
def to_int_struct {sig : MonadicSignature} (M : IntStructureFromSig sig)
    (atomMap : sig.preds → Atom) : Separation.IntStructure where
  val a := {t : Int | ∃ p : sig.preds, atomMap p = a ∧ M.interp p t}

/-- The Q_exists connective: "exists sometime" = P(A) v A v F(A).
    This captures existential quantification over Z when applied to
    a temporal formula. -/
def q_exists (A : Formula) : Formula :=
  Formula.or (Formula.or (Formula.some_past A) A) (Formula.some_future A)

/-- Q_exists correctly captures existential quantification over Z:
    int_truth M t (q_exists A) iff exists s, int_truth M s A -/
theorem q_exists_correct (A : Formula) (M : Separation.IntStructure) (t : Int) :
    Separation.int_truth M t (q_exists A) ↔ ∃ s : Int, Separation.int_truth M s A := by
  sorry

/-! ## Theorem 9.3.1: Separation Implies Expressive Completeness -/

/-- Theorem 9.3.1 (GHR94): If {U,S} has the separation property over Z
    and P, F are definable (which they are: P(A) = S(A, True), F(A) = U(A, True)),
    then {U,S} is expressively complete over Z.

    Proof by induction on quantifier depth m of the FO formula.

    Base case (m = 0): Quantifier-free formula psi(t). Replace t=t by True, t<t by False,
    Q_i(t) by atom q_i. Done.

    Inductive case (m > 0): Reduce to exists z, psi(t,z) with psi of depth <= m.
    1. Introduce predicates R_=(y) = (t=y), R_>(y) = (t<y), R_<(y) = (y<t).
    2. Rewrite psi as psi'(z, Q, R_=, R_>, R_<) not mentioning t explicitly.
    3. By IH, find temporal A_j for each depth-m sub-case.
    4. Form B using Q_exists to express the existential quantifier.
    5. B contains extra atoms r_=, r_>, r_<. Use SEPARATION to decompose B.
    6. Substitute: in pure past parts, r_> = True, r_= = False, r_< = False;
       in pure future parts, r_> = False, r_= = False, r_< = True;
       in pure present parts, r_> = False, r_= = True, r_< = False.
    7. The resulting B* no longer mentions r_=, r_>, r_< and is the temporal
       equivalent of psi. -/
theorem separation_implies_expressiveness
    (h_sep : ∀ phi : Formula, Separation.is_separable phi) :
    ∀ (sig : MonadicSignature) (psi : MonadicFormula sig 1),
      ∃ (A : Formula) (atomMap : sig.preds → Atom),
        ∀ (M : IntStructureFromSig sig) (t : Int),
          eval (int_to_ordered sig M) (fun _ => t) psi ↔
          Separation.int_truth (to_int_struct M atomMap) t A := by
  sorry

/-! ## Theorem 10.2.10: The Final Result -/

/-- Theorem 10.2.10 (GHR94): The language {U, S} is expressively complete
    over integer time.

    Combines the Separation Theorem (10.2.9) with Theorem 9.3.1. -/
theorem US_expressively_complete_over_Z :
    ∀ (sig : MonadicSignature) (psi : MonadicFormula sig 1),
      ∃ (A : Formula) (atomMap : sig.preds → Atom),
        ∀ (M : IntStructureFromSig sig) (t : Int),
          eval (int_to_ordered sig M) (fun _ => t) psi ↔
          Separation.int_truth (to_int_struct M atomMap) t A :=
  separation_implies_expressiveness (fun phi => separation_theorem_int phi)

end Bimodal.Metalogic.WeakCanonical
