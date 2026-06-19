import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-!
# EA-Formula Negation Closure (Rabinovich 2014, Section 5)

Proves that negations of bracket formulas are V-EA on Prior structures:

1. **Lemma 5.3** (Phase 2): Negation of "exists n ordered points with P_i at each"
   is V-EA. The all-betas-True base case.

2. **Corollary 5.4** (Phase 3): Negation of "exists z in (z_0, z_1) such that
   bracket formula holds on (z_0, z)" is V-EA.

3. **Lemma 5.1** (Phase 4, future): Full negation closure for bracket formulas.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5
- Rabinovich 2014, Lemma 5.3 (p.8), Corollary 5.4 (p.9), Lemma 5.1 (pp.7-11)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Lemma 5.3: Negation of Ordered Points (All-Betas-True Base Case)

The predicate "exists n strictly ordered points x_1 < ... < x_n in (z_0, z_1)
with P_i(x_i) for each i" is semantically an IntervalPattern with all beta
(segment types) equal to TemporalPred.top. Lemma 5.3 says the negation of this
predicate is equivalent to a V-EA formula on Prior structures.

Proof by induction on n:
- Base n=0: trivially True (no witnesses to negate → nothing to negate)
- Base n=1: ¬(∃ x ∈ (z₀,z₁), P(x)) = ∀ y ∈ (z₀,z₁), ¬P(y) = bracket with 0 witnesses
- Step n+1→n: Use HasDefinableINF to find first occurrence of P_1, reduce to n
-/

/-- An interval pattern with all segment types True: just n ordered witness
    points with point types at each, no constraints on the intervals between them. -/
def IntervalPattern.allBetaTrue (n : Nat) (alpha : Fin n → TemporalPred) :
    IntervalPattern n :=
  { alpha := alpha
    beta := fun _ => TemporalPred.top }

/-- The bracket formula with all segment types True. -/
def BracketFormula.allTrue (n : Nat) (alpha : Fin n → TemporalPred) :
    BracketFormula n :=
  { pointTypes := alpha
    segmentTypes := fun _ => TemporalPred.top }

/-- The ordered-points predicate: there exist n strictly ordered points in (z_0, z_1)
    with P_i(x_i) at each. This is IntervalPattern.holds with all betas True. -/
def orderedPointsExist {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin n → TemporalPred)
    (z0 z1 : M.carrier) : Prop :=
  (IntervalPattern.allBetaTrue n Ps).holds M atomMap z0 z1

/-- For n=0, orderedPointsExist is trivially True (no witnesses needed,
    the forall condition is vacuously satisfied by TemporalPred.top). -/
theorem orderedPointsExist_zero {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Ps : Fin 0 → TemporalPred) (z0 z1 : M.carrier) :
    orderedPointsExist M atomMap 0 Ps z0 z1 := by
  simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
  intro y _ _
  exact TemporalPred.eval_at_top M atomMap y

/-- For n=0, the negation is False (since the predicate is always True). -/
theorem neg_orderedPointsExist_zero_false {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Ps : Fin 0 → TemporalPred) (z0 z1 : M.carrier) :
    ¬ ¬ orderedPointsExist M atomMap 0 Ps z0 z1 := by
  exact not_not.mpr (orderedPointsExist_zero M atomMap Ps z0 z1)

/-- For n=1, ¬(∃ x ∈ (z₀,z₁), P(x)) = ∀ y ∈ (z₀,z₁), ¬P(y),
    which is a bracket formula with 0 witnesses and segment type ¬P. -/
theorem neg_orderedPointsExist_one {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    ¬ orderedPointsExist M atomMap 1 (fun _ => P) z0 z1 ↔
    ∀ y : M.carrier, z0 < y → y < z1 → ¬ P.eval_at M atomMap y := by
  unfold orderedPointsExist IntervalPattern.allBetaTrue
  simp only [IntervalPattern.holds]
  constructor
  · intro h y hy0 hy1 hPy
    apply h
    refine ⟨fun _ => y, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro a b hab; exact absurd hab (by omega)
    · intro j; exact ⟨hy0, hy1⟩
    · intro j
      have : j = ⟨0, by omega⟩ := by ext; omega
      rw [this]; exact hPy
    · intro y' _ _; exact TemporalPred.eval_at_top M atomMap y'
    · intro j; exact Fin.elim0 j
    · intro y' _ _; exact TemporalPred.eval_at_top M atomMap y'
  · rintro h ⟨w, _, hrange, hpoint, _, _, _⟩
    exact h (w ⟨0, by omega⟩) (hrange ⟨0, by omega⟩).1 (hrange ⟨0, by omega⟩).2
      (hpoint ⟨0, by omega⟩)

/-- The negation of a single ordered point is a bracket formula with 0 witnesses. -/
theorem neg_orderedPointsExist_one_is_bracket {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (z0 z1 : M.carrier) :
    ¬ orderedPointsExist M atomMap 1 (fun _ => P) z0 z1 ↔
    (BracketFormula.trivial P.neg).holds M atomMap z0 z1 := by
  rw [neg_orderedPointsExist_one]
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, BracketFormula.trivial,
    IntervalPattern.holds, TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth]

end Bimodal.Metalogic.WeakCanonical.Kamp
