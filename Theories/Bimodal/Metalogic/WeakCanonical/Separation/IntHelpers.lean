import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Mathlib.Data.Int.Interval

/-!
# Integer-Specific Helper Lemmas for Separation

Provides integer-arithmetic lemmas needed by the separation proof:
- Finite intervals in Z
- Well-ordering arguments for finding first failure points
- Direct witness constructions for Until/Since

## References

- GHR94, Chapter 10.2: These lemmas support the key Z-dependent steps
  (particularly Lemma 10.2.2, the negation equivalence)
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Finite Interval Properties -/

/-- In Z, bounded open intervals (t, s) with t < s are finite. -/
theorem Int.Ioo_finite' (t s : Int) (_h : t < s) :
    Set.Finite (Set.Ioo t s) :=
  Set.Finite.ofFinset (Finset.Ioo t s) (fun x => by simp [Finset.mem_Ioo, Set.mem_Ioo])

/-- In Z, the interval (t, t+1) is empty (discreteness). -/
theorem Int.Ioo_succ_empty (t : Int) :
    Set.Ioo t (t + 1) = ∅ := by
  ext x; simp [Set.mem_Ioo]; omega

/-- In Z, if t < s then t + 1 is the least element greater than t. -/
theorem Int.succ_least (t s : Int) (h : t < s) : t + 1 ≤ s := by omega

/-- In Z, every non-empty set bounded below has an infimum (well-ordering).
    If P holds for some n > t, then there is a least such n.
    This is the KEY INTEGER-SPECIFIC lemma used in Lemma 10.2.2. -/
theorem Int.exists_least_above {P : Int → Prop} {t : Int}
    (hex : ∃ n, t < n ∧ P n) [DecidablePred P] :
    ∃ m, t < m ∧ P m ∧ ∀ k, t < k → k < m → ¬P k := by
  sorry

/-- Dual: If P holds for some n < t, then there is a greatest such n. -/
theorem Int.exists_greatest_below {P : Int → Prop} {t : Int}
    (hex : ∃ n, n < t ∧ P n) [DecidablePred P] :
    ∃ m, m < t ∧ P m ∧ ∀ k, m < k → k < t → ¬P k := by
  sorry

/-- Non-decidable version: If P holds for some n > t, there is a least such n.
    Uses classical logic and well-ordering of Nat. -/
theorem Int.exists_least_above' {P : Int → Prop} {t : Int}
    (hex : ∃ n, t < n ∧ P n) :
    ∃ m, t < m ∧ P m ∧ ∀ k, t < k → k < m → ¬P k := by
  sorry

/-! ## Direct Witness Constructions -/

/-- Key property: In Z with t < s, if phi holds at s and psi holds on (t,s),
    then U(phi, psi) holds at t. This is just the existential witness. -/
theorem until_witness_construction (M : IntStructure) (t s : Int) (hts : t < s)
    (phi psi : Formula) (hphi : int_truth M s phi)
    (hpsi : ∀ r : Int, t < r → r < s → int_truth M r psi) :
    int_truth M t (.untl phi psi) :=
  ⟨s, hts, hphi, hpsi⟩

/-- Dual: In Z with s < t, if phi holds at s and psi holds on (s,t),
    then S(phi, psi) holds at t. -/
theorem since_witness_construction (M : IntStructure) (t s : Int) (hst : s < t)
    (phi psi : Formula) (hphi : int_truth M s phi)
    (hpsi : ∀ r : Int, s < r → r < t → int_truth M r psi) :
    int_truth M t (.snce phi psi) :=
  ⟨s, hst, hphi, hpsi⟩

/-! ## Top/True Equivalences -/

/-- The formula neg bot (i.e., bot -> bot) is always true in int_truth. -/
theorem neg_bot_true (M : IntStructure) (t : Int) :
    int_truth M t (Formula.neg .bot) := by
  show int_truth M t (.imp .bot .bot)
  simp [int_truth]

/-- In Z, S(a, neg bot) iff some_past a.
    S(a, True) means: there exists s < t with a(s), and True holds trivially on (s,t). -/
theorem since_top_is_past (a : Formula) :
    int_equiv (.snce a (Formula.neg .bot)) (Formula.some_past a) := by
  sorry

/-- In Z, U(a, neg bot) iff some_future a.
    U(a, True) means: there exists s > t with a(s), and True holds trivially on (t,s). -/
theorem until_top_is_future (a : Formula) :
    int_equiv (.untl a (Formula.neg .bot)) (Formula.some_future a) := by
  sorry

end Bimodal.Metalogic.WeakCanonical.Separation
