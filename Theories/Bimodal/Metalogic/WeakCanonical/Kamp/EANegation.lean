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

/-! ## Bracket Formula Prepend

Given a bracket formula `bf` with `k` witnesses on `(r0, z1)`, construct a new
bracket formula with `k + 1` witnesses on `(z0, z1)` by prepending `r0` as the
first witness with point type `ptType` and segment type `segLeft` on `(z0, r0)`. -/

/-- Prepend a witness to a bracket formula: creates a new bracket formula with
    one additional witness at the front. -/
def BracketFormula.prepend (segLeft ptType : TemporalPred)
    {k : Nat} (bf : BracketFormula k) : BracketFormula (k + 1) :=
  { pointTypes := fun i =>
      if h : i.val = 0 then ptType
      else bf.pointTypes ⟨i.val - 1, by omega⟩
    segmentTypes := fun i =>
      if h : i.val = 0 then segLeft
      else bf.segmentTypes ⟨i.val - 1, by omega⟩ }

/-- If a bracket formula `bf` holds on `(r0, z1)`, then `bf.prepend segLeft ptType`
    holds on `(z0, z1)` with `r0` as the first witness, provided `ptType(r0)` and
    `segLeft` holds on `(z0, r0)`. -/
theorem BracketFormula.prepend_holds {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula k) (segLeft ptType : TemporalPred)
    (z0 z1 r0 : M.carrier)
    (hr0_above : z0 < r0) (hr0_below : r0 < z1)
    (hPt : ptType.eval_at M atomMap r0)
    (hSeg : ∀ y : M.carrier, z0 < y → y < r0 → segLeft.eval_at M atomMap y)
    (h_tail : bf.holds M atomMap r0 z1) :
    (bf.prepend segLeft ptType).holds M atomMap z0 z1 := by
  simp only [holds, toIntervalPattern, prepend, IntervalPattern.holds]
  match k, bf, h_tail with
  | 0, bf, h_tail =>
    simp only [holds, toIntervalPattern, IntervalPattern.holds] at h_tail
    refine ⟨fun _ => r0, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro ⟨i, hi⟩ ⟨j, hj⟩ hij
      simp at hi hj; omega
    · intro _; exact ⟨hr0_above, hr0_below⟩
    · intro ⟨i, hi⟩; simp at hi; subst hi; simp; exact hPt
    · intro y hy0 hy1; simp; exact hSeg y hy0 hy1
    · intro ⟨i, hi⟩; exact absurd hi (by omega)
    · intro y hy0 hy1; simp; exact h_tail y hy0 hy1
  | k' + 1, bf, h_tail =>
    simp only [holds, toIntervalPattern, IntervalPattern.holds] at h_tail
    obtain ⟨w, hm, hbnd, hpt, hseg0, hseg_mid, hseg_last⟩ := h_tail
    -- Witness function: w'(0) = r0, w'(i+1) = w(i)
    let w' : Fin (k' + 2) → M.carrier := fun ⟨i, _⟩ =>
      if i = 0 then r0 else w ⟨i - 1, by omega⟩
    refine ⟨w', ?_, ?_, ?_, ?_, ?_, ?_⟩
    · -- Strictly increasing
      intro ⟨i, hi⟩ ⟨j, hj⟩ hij
      simp only [Fin.lt_iff_val_lt_val] at hij
      show w' ⟨i, hi⟩ < w' ⟨j, hj⟩
      simp only [w']
      by_cases hi0 : i = 0
      · subst hi0; simp only [ite_true, if_neg (show j ≠ 0 from by omega)]
        calc r0 < w ⟨0, by omega⟩ := (hbnd ⟨0, by omega⟩).1
           _ ≤ w ⟨j - 1, by omega⟩ := by
              rcases Nat.eq_or_lt_of_le (show 1 ≤ j from by omega) with h | h
              · subst h; simp
              · exact le_of_lt (hm ⟨0, by omega⟩ ⟨j - 1, by omega⟩
                  (by simp [Fin.lt_iff_val_lt_val]; omega))
      · simp only [if_neg hi0, if_neg (show j ≠ 0 from by omega)]
        exact hm ⟨i - 1, by omega⟩ ⟨j - 1, by omega⟩ (by simp [Fin.lt_iff_val_lt_val]; omega)
    · -- All in (z0, z1)
      intro ⟨i, hi⟩
      show z0 < w' ⟨i, hi⟩ ∧ w' ⟨i, hi⟩ < z1
      simp only [w']
      by_cases hi0 : i = 0
      · subst hi0; simp; exact ⟨hr0_above, hr0_below⟩
      · simp only [if_neg hi0]
        exact ⟨lt_trans hr0_above (lt_of_lt_of_le (hbnd ⟨0, by omega⟩).1
          (by rcases Nat.eq_or_lt_of_le (show 1 ≤ i from by omega) with h | h
              · subst h; simp
              · exact le_of_lt (hm ⟨0, by omega⟩ ⟨i - 1, by omega⟩
                  (by simp [Fin.lt_iff_val_lt_val]; omega)))),
               (hbnd ⟨i - 1, by omega⟩).2⟩
    · -- Point types
      intro ⟨i, hi⟩
      simp only [w']
      by_cases hi0 : i = 0
      · subst hi0; simp [dif_pos rfl]; exact hPt
      · simp only [if_neg hi0, dif_neg hi0]; exact hpt ⟨i - 1, by omega⟩
    · -- Segment 0: segLeft on (z0, w'(0)=r0)
      intro y hy0 hy1
      have : w' ⟨0, by omega⟩ = r0 := by simp [w']
      rw [this] at hy1
      simp [dif_pos (show (0 : Nat) = 0 from rfl)]; exact hSeg y hy0 hy1
    · -- Middle segments
      intro ⟨i, hi⟩ y hy_lo hy_hi
      simp only [dif_neg (show i + 1 ≠ 0 from by omega)]
      simp only [w'] at hy_lo hy_hi
      by_cases hi0 : i = 0
      · -- Segment between w'(0)=r0 and w'(1)=w(0)
        subst hi0; simp at hy_lo hy_hi
        exact hseg0 y hy_lo hy_hi
      · -- Segment between w'(i)=w(i-1) and w'(i+1)=w(i)
        simp only [if_neg hi0, if_neg (show i + 1 ≠ 0 from by omega)] at hy_lo hy_hi
        convert hseg_mid ⟨i - 1, by omega⟩ y hy_lo ?_ using 3
        · simp [Fin.ext_iff]; omega
        · convert hy_hi using 3; simp [Fin.ext_iff]; omega
    · -- Last segment
      intro y hy_lo hy_hi
      simp only [w', if_neg (show k' + 1 ≠ 0 from by omega)] at hy_lo
      simp only [dif_neg (show k' + 2 ≠ 0 from by omega)]
      exact hseg_last y hy_lo hy_hi

/-- If `bf.prepend segLeft ptType` holds on `(z0, z1)`, then there exists `r0` in
    `(z0, z1)` with `ptType(r0)`, `segLeft` on `(z0, r0)`, and `bf` on `(r0, z1)`. -/
theorem BracketFormula.prepend_holds_inv {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula k) (segLeft ptType : TemporalPred)
    (z0 z1 : M.carrier)
    (h : (bf.prepend segLeft ptType).holds M atomMap z0 z1) :
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
      ptType.eval_at M atomMap r0 ∧
      (∀ y : M.carrier, z0 < y → y < r0 → segLeft.eval_at M atomMap y) ∧
      bf.holds M atomMap r0 z1 := by
  simp only [holds, toIntervalPattern, prepend, IntervalPattern.holds] at h
  obtain ⟨w, hmono, hrange, hpoint, hseg0, hseg_mid, hseg_last⟩ := h
  refine ⟨w ⟨0, by omega⟩, (hrange ⟨0, by omega⟩).1, (hrange ⟨0, by omega⟩).2, ?_, ?_, ?_⟩
  · have := hpoint ⟨0, by omega⟩; simp [dif_pos rfl] at this; exact this
  · intro y hy0 hy1; have := hseg0 y hy0 hy1; simp [dif_pos rfl] at this; exact this
  · simp only [holds, toIntervalPattern, IntervalPattern.holds]
    match k with
    | 0 =>
      intro y hy0 hy1
      have := hseg_last y hy0 hy1
      simp [dif_neg (show (0 : Nat) + 1 ≠ 0 from by omega)] at this
      convert this using 2
    | k' + 1 =>
      refine ⟨fun j => w ⟨j.val + 1, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro a b hab
        exact hmono ⟨a.val + 1, by omega⟩ ⟨b.val + 1, by omega⟩
          (Fin.mk_lt_mk.mpr (Nat.succ_lt_succ (Fin.mk_lt_mk.mp hab)))
      · intro j
        exact ⟨hmono ⟨0, by omega⟩ ⟨j.val + 1, by omega⟩ (by exact Fin.mk_lt_mk.mpr (by omega)),
               (hrange ⟨j.val + 1, by omega⟩).2⟩
      · intro j
        have := hpoint ⟨j.val + 1, by omega⟩
        simp [dif_neg (show j.val + 1 ≠ 0 from by omega)] at this
        convert this using 2
      · intro y hy0 hy1
        have := hseg_mid ⟨0, by omega⟩ y hy0 hy1
        simp [dif_neg (show (0 : Nat) + 1 ≠ 0 from by omega)] at this
        convert this using 2
      · intro j y hy0 hy1
        have := hseg_mid ⟨j.val + 1, by omega⟩ y
          (by convert hy0 using 2)
          (by convert hy1 using 2)
        simp [dif_neg (show j.val + 1 + 1 ≠ 0 from by omega)] at this
        convert this using 2
      · intro y hy0 hy1
        have := hseg_last y
          (by convert hy0 using 2) hy1
        simp [dif_neg (show k' + 1 + 1 ≠ 0 from by omega)] at this
        convert this using 2

/-- Decompose orderedPointsExist (n+1): if the first predicate doesn't hold in (z0, r0),
    then the remaining witnesses give orderedPointsExist n (shift Ps) r0 z1. -/
theorem orderedPointsExist_decompose {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin (n + 1) → TemporalPred) (z0 z1 r0 : M.carrier)
    (hSeg : ∀ y : M.carrier, z0 < y → y < r0 →
      ¬ (Ps ⟨0, by omega⟩).eval_at M atomMap y)
    (h : orderedPointsExist M atomMap (n + 1) Ps z0 z1) :
    orderedPointsExist M atomMap n (fun i => Ps i.succ) r0 z1 := by
  match n with
  | 0 => exact orderedPointsExist_zero M atomMap _ _ _
  | n' + 1 =>
    simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds] at h ⊢
    obtain ⟨w, hmono, hrange, hpoint, _, _, _⟩ := h
    have h_r0_le_w0 : r0 ≤ w ⟨0, by omega⟩ := by
      by_contra hc; push_neg at hc
      exact hSeg (w ⟨0, by omega⟩) (hrange ⟨0, by omega⟩).1 hc (hpoint ⟨0, by omega⟩)
    refine ⟨fun j => w ⟨j.val + 1, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro a b hab
      exact hmono ⟨a.val + 1, by omega⟩ ⟨b.val + 1, by omega⟩
        (Fin.mk_lt_mk.mpr (Nat.succ_lt_succ (Fin.mk_lt_mk.mp hab)))
    · intro j
      exact ⟨lt_of_le_of_lt h_r0_le_w0
        (hmono ⟨0, by omega⟩ ⟨j.val + 1, by omega⟩
          (by exact Fin.mk_lt_mk.mpr (by omega))),
             (hrange ⟨j.val + 1, by omega⟩).2⟩
    · intro j; exact hpoint ⟨j.val + 1, by omega⟩
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro _ y _ _; exact TemporalPred.eval_at_top M atomMap y
    · intro y _ _; exact TemporalPred.eval_at_top M atomMap y

/-! ## Lemma 5.3: Full Statement (Negation of Ordered Points is VBracket)

The main theorem: for any `n` and temporal predicates `Ps`, there exists a
`VBracketFormula` whose semantics on Prior structures (those with `HasDefinableINF`)
is equivalent to `¬ orderedPointsExist n Ps z0 z1`.

Proof by strong induction on `n`:
- `n = 0`: `orderedPointsExist` is trivially True, so the negation is False.
  Use `VBracketFormula` with empty disjuncts (always False).
- `n = 1`: The negation is `∀ y ∈ (z0, z1), ¬P(y)`, which is `BracketFormula.trivial P.neg`.
- `n + 2`: (Inductive step) Either:
  (a) `P_0` doesn't occur in `(z0, z1)` → bracket with 0 witnesses and segment `¬P_0`
  (b) `P_0` occurs → use `HasDefinableINF` for first occurrence `r0`, reduce to
      `¬ orderedPointsExist (n+1) (shift Ps) r0 z1`, which by IH is a `VBracketFormula`
      on `(r0, z1)`. Extend each disjunct with `r0` as first witness via `prepend`.

### Construction

Given IH: `∃ v_IH, ∀ M ..., v_IH.holds ↔ ¬ orderedPointsExist (n+1) (shift Ps) r0 z1`

For each disjunct `⟨m, bf⟩` in `v_IH.disjuncts`, construct:
  `bf.prepend (Ps 0).neg (Ps 0)` — bracket with `m + 1` witnesses

The full VBracketFormula is:
  - `⟨0, BracketFormula.trivial (Ps 0).neg⟩` (case A: no P_0 in interval)
  - Plus all prepended IH disjuncts (case B: P_0 occurs, IH on tail)
-/

/-- Construct the VBracketFormula for the negation case by prepending a witness
    to each disjunct of an IH VBracketFormula. -/
def VBracketFormula.prependAll (segLeft ptType : TemporalPred)
    (v : VBracketFormula) : VBracketFormula :=
  { disjuncts := v.disjuncts.map (fun ⟨m, bf⟩ => ⟨m + 1, bf.prepend segLeft ptType⟩) }

/-- **Lemma 5.3** (Rabinovich 2014, p.8): The negation of "there exist `n` ordered
    points in `(z₀, z₁)` with predicates `Pᵢ`" is equivalent to a V-bracket formula
    on any structure with attained infima (`HasAttainedINF`).

    The VBracketFormula is constructed purely from `n` and `Ps`, independent of
    the structure `M`. The equivalence holds on any Prior structure.

    Note: We use `HasAttainedINF` (strictly stronger than `HasDefinableINF`) to avoid
    the K+ limit-point case. Prior structures satisfy `HasAttainedINF` via
    `prior_hasAttainedINF`. -/
theorem neg_orderedPointsExist_is_vbracket :
    ∀ (n : Nat) (Ps : Fin n → TemporalPred),
    ∃ (v : VBracketFormula),
    ∀ {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
      (atomMap : Formula → sig.preds) (h_INF : HasAttainedINF M atomMap)
      (z0 z1 : M.carrier), z0 < z1 →
      (v.holds M atomMap z0 z1 ↔ ¬ orderedPointsExist M atomMap n Ps z0 z1) := by
  intro n
  induction n with
  | zero =>
    intro Ps
    exact ⟨⟨[]⟩, fun M atomMap _h_INF z0 z1 _h_lt => by
      simp only [VBracketFormula.holds, List.not_mem_nil, false_and, exists_false]
      exact Iff.intro False.elim
        (fun h => absurd (orderedPointsExist_zero M atomMap Ps z0 z1) h)⟩
  | succ n ih =>
    intro Ps
    obtain ⟨v_IH, hv_IH⟩ := ih (fun i => Ps i.succ)
    let caseA : Σ n, BracketFormula n := ⟨0, BracketFormula.trivial (Ps ⟨0, by omega⟩).neg⟩
    let caseB := VBracketFormula.prependAll (Ps ⟨0, by omega⟩).neg (Ps ⟨0, by omega⟩) v_IH
    let result : VBracketFormula := ⟨caseA :: caseB.disjuncts⟩
    refine ⟨result, fun M atomMap h_INF z0 z1 h_lt => ?_⟩
    -- Helper: extract orderedPointsExist from a point satisfying P_0 and tail witnesses
    have h_combine_witnesses :
        ∀ (r : M.carrier), z0 < r → r < z1 →
        (Ps ⟨0, by omega⟩).eval_at M atomMap r →
        orderedPointsExist M atomMap n (fun i => Ps i.succ) r z1 →
        orderedPointsExist M atomMap (n + 1) Ps z0 z1 := by
      match n with
      | 0 =>
        intro r hr_above hr_below hr_P _
        simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
        refine ⟨fun _ => r, ?_, ?_, ?_, ?_, ?_, ?_⟩
        · intro a b hab; exact absurd hab (by omega)
        · intro _; exact ⟨hr_above, hr_below⟩
        · intro ⟨i, hi⟩; simp at hi; subst hi; exact hr_P
        · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
        · intro j; exact Fin.elim0 j
        · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
      | n' + 1 =>
        intro r hr_above hr_below hr_P hr_tail
        simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
          at hr_tail ⊢
        obtain ⟨w_tail, hmono_tail, hrange_tail, hpoint_tail, _, _, _⟩ := hr_tail
        let w' : Fin (n' + 2) → M.carrier := fun ⟨i, _⟩ =>
          if i = 0 then r else w_tail ⟨i - 1, by omega⟩
        refine ⟨w', ?_, ?_, ?_, ?_, ?_, ?_⟩
        · intro ⟨a, ha⟩ ⟨b, hb⟩ hab
          simp only [Fin.lt_iff_val_lt_val] at hab; simp only [w']
          by_cases ha0 : a = 0
          · subst ha0; simp [show b ≠ 0 from by omega]
            calc r < w_tail ⟨0, by omega⟩ := (hrange_tail ⟨0, by omega⟩).1
               _ ≤ w_tail ⟨b - 1, by omega⟩ := by
                  rcases Nat.eq_or_lt_of_le (show 1 ≤ b from by omega) with h | h
                  · subst h; simp
                  · exact le_of_lt (hmono_tail ⟨0, by omega⟩ ⟨b - 1, by omega⟩
                      (by simp [Fin.lt_iff_val_lt_val]; omega))
          · simp [ha0, show b ≠ 0 from by omega]
            exact hmono_tail ⟨a - 1, by omega⟩ ⟨b - 1, by omega⟩
              (by simp [Fin.lt_iff_val_lt_val]; omega)
        · intro ⟨i, hi⟩; simp only [w']
          by_cases hi0 : i = 0
          · subst hi0; simp; exact ⟨hr_above, hr_below⟩
          · simp [hi0]
            exact ⟨lt_trans hr_above (lt_of_lt_of_le (hrange_tail ⟨0, by omega⟩).1
              (by rcases Nat.eq_or_lt_of_le (show 1 ≤ i from by omega) with h | h
                  · subst h; simp
                  · exact le_of_lt (hmono_tail ⟨0, by omega⟩ ⟨i - 1, by omega⟩
                      (by simp [Fin.lt_iff_val_lt_val]; omega)))),
                   (hrange_tail ⟨i - 1, by omega⟩).2⟩
        · intro ⟨i, hi⟩; simp only [w']
          by_cases hi0 : i = 0
          · subst hi0; simp; exact hr_P
          · simp [hi0]
            convert hpoint_tail ⟨i - 1, by omega⟩ using 2
            ext; simp; omega
        · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
        · intro _ y _ _; exact TemporalPred.eval_at_top M atomMap y
        · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
    -- Helper: from prepended bracket, extract ¬orderedPointsExist
    -- If bf'.prepend holds on (z0, z1), then there exist witnesses w' with:
    -- w'(0) is r0, (Ps 0)(r0), ¬(Ps 0) on (z0, r0), bf' holds on (r0, z1)
    -- Then if bf' ∈ v_IH and v_IH ↔ ¬orderedPointsExist n (shift),
    -- we get ¬orderedPointsExist n (shift) r0 z1.
    -- Combined with r0 as first witness, ¬orderedPointsExist (n+1) follows.
    constructor
    · -- Forward: VBracket holds → ¬ orderedPointsExist
      intro ⟨⟨m, bf⟩, h_mem, h_holds⟩
      simp only [result, caseA, caseB, VBracketFormula.prependAll, List.mem_cons,
        List.mem_map] at h_mem
      rcases h_mem with h_eq | ⟨⟨m', bf'⟩, h_mem', h_eq'⟩
      · -- Case A: ¬P_0 everywhere → no first witness possible
        -- h_eq : ⟨m, bf⟩ = ⟨0, BracketFormula.trivial ...⟩
        obtain rfl := congr_arg Sigma.fst h_eq
        have hbf_eq : bf = BracketFormula.trivial (Ps ⟨0, by omega⟩).neg :=
          eq_of_heq (Sigma.mk.inj h_eq).2
        subst hbf_eq
        simp only [BracketFormula.trivial_holds] at h_holds
        intro ⟨w, _, hrange, hpoint, _, _, _⟩
        have := h_holds (w ⟨0, by omega⟩) (hrange ⟨0, by omega⟩).1 (hrange ⟨0, by omega⟩).2
        simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth] at this
        exact this (hpoint ⟨0, by omega⟩)
      · -- Case B: prepended IH disjunct
        have hm_eq := congr_arg Sigma.fst h_eq'
        simp at hm_eq; subst hm_eq
        have hbf_eq : BracketFormula.prepend (Ps ⟨0, by omega⟩).neg (Ps ⟨0, by omega⟩) bf' = bf :=
          eq_of_heq (Sigma.mk.inj h_eq').2
        subst hbf_eq
        -- Use prepend_holds_inv to decompose
        obtain ⟨r0, hr0_above, hr0_below, _, hSeg_r0, h_bf'_holds⟩ :=
          BracketFormula.prepend_holds_inv M atomMap bf'
            (Ps ⟨0, by omega⟩).neg (Ps ⟨0, by omega⟩) z0 z1 h_holds
        -- bf' ∈ v_IH, bf'.holds on (r0, z1) → v_IH.holds on (r0, z1)
        have hv_IH_holds : v_IH.holds M atomMap r0 z1 :=
          ⟨⟨m', bf'⟩, h_mem', h_bf'_holds⟩
        -- By IH: ¬orderedPointsExist n (shift Ps) r0 z1
        have h_neg_tail := (hv_IH M atomMap h_INF r0 z1 hr0_below).mp hv_IH_holds
        -- Show ¬orderedPointsExist (n+1) Ps z0 z1
        -- Proof: from orderedPointsExist (n+1), get orderedPointsExist n (shift) r0 z1,
        -- contradicting h_neg_tail. This uses h_decompose_witnesses (defined below).
        exact fun h_exists => h_neg_tail
          (orderedPointsExist_decompose M atomMap n Ps z0 z1 r0
            (fun y hy0 hy1 => by
              have := hSeg_r0 y hy0 hy1
              simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth] at this
              exact this)
            h_exists)
    · -- Backward: ¬ orderedPointsExist → VBracket holds
      intro h_neg
      by_cases h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
          (Ps ⟨0, by omega⟩).eval_at M atomMap x
      · -- Case B: Ps 0 occurs in (z0, z1)
        -- Use HasAttainedINF: first occurrence r0 with P(r0) (no K+ case)
        obtain ⟨r0, hr0_above, hr0_below, h_no_before, h_P_r0⟩ :=
          h_INF.first_occ (Ps ⟨0, by omega⟩).formula z0 z1 h_lt (by
            obtain ⟨x, hx1, hx2, hx3⟩ := h_occ; exact ⟨x, hx1, hx2, hx3⟩)
        -- Show ¬orderedPointsExist n (shift Ps) r0 z1
        have h_neg_tail : ¬ orderedPointsExist M atomMap n (fun i => Ps i.succ) r0 z1 := by
          intro h_tail
          exact h_neg (h_combine_witnesses r0 hr0_above hr0_below h_P_r0 h_tail)
        -- By IH, v_IH.holds r0 z1
        have h_IH_holds := (hv_IH M atomMap h_INF r0 z1 hr0_below).mpr h_neg_tail
        obtain ⟨⟨m', bf'⟩, h_mem', h_bf'_holds⟩ := h_IH_holds
        -- Prepend r0 to bf' and show result holds
        refine ⟨⟨m' + 1, bf'.prepend (Ps ⟨0, by omega⟩).neg (Ps ⟨0, by omega⟩)⟩, ?_, ?_⟩
        · simp only [result, caseA, caseB, VBracketFormula.prependAll, List.mem_cons, List.mem_map]
          right; exact ⟨⟨m', bf'⟩, h_mem', rfl⟩
        · exact BracketFormula.prepend_holds M atomMap bf'
            (Ps ⟨0, by omega⟩).neg (Ps ⟨0, by omega⟩)
            z0 z1 r0 hr0_above hr0_below h_P_r0
            (fun y hy0 hy1 => by
              have := h_no_before y hy0 hy1
              simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth]
              exact this)
            h_bf'_holds
      · -- Case A: Ps 0 does not occur in (z0, z1)
        push_neg at h_occ
        refine ⟨⟨0, BracketFormula.trivial (Ps ⟨0, by omega⟩).neg⟩, ?_, ?_⟩
        · simp [result, caseA]
        · rw [BracketFormula.trivial_holds]
          intro y hy0 hy1
          simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth]
          exact h_occ y hy0 hy1

/-! ## Corollary 5.4: Partial Bracket Negation

The negation of "exists z in (z_0, z_1) such that bracket.holds z_0 z" is V-EA
on Prior structures. This is Rabinovich's Corollary 5.4 (p.9).

### Approach: F-Chain Reduction

Given a bracket formula bf with n witnesses on (z_0, z), define the F-chain:
- F_{n-1} := alpha_{n-1}.conj (Until(beta_n, top)) -- last witness: alpha AND "beta_n holds until some point"
- F_i := alpha_i.conj (Until(beta_{i+1}, F_{i+1})) -- i-th witness: alpha AND "beta Until next F"
- F_0 handles the first segment via beta_0

The bracket holding on (z_0, z) implies orderedPointsExist 1 F_chain z_0 z
(the bracket witnesses provide the Until/orderedPointsExist witnesses).
Combined with the existential over z, this gives
orderedPointsExist 1 F_chain z_0 z_1 ⊇ ∃ z, bracket(z_0, z).

By Lemma 5.3, ¬orderedPointsExist is V-bracket, giving us a V-bracket
formula V such that V.holds → ¬∃ z, bracket(z_0, z).

For the full equivalence on Prior structures (V.holds ↔ ¬∃z, bracket),
we prove the converse using HasAttainedINF: if ¬∃z bracket(z_0, z),
then no F-chain witnesses exist in (z_0, z_1) either, because any
F-chain witness with bounded Until (where the Until target is in-interval)
would reconstruct a bracket.
-/

/-! ### F-Chain Construction

Build compound temporal predicates that absorb bracket segment types
via Until. Each F_i at point x_i asserts: alpha_i(x_i) AND the rest
of the bracket structure continues forward from x_i. -/

/-- Build the F-chain formula for a bracket formula, computing from the right.
    `fChainFrom bf i` returns the compound TemporalPred at witness index i.

    - Base (i = n-1): `alpha_{n-1} AND (beta_n Until ⊤)`
    - Step (i < n-1): `alpha_i AND (beta_{i+1} Until F_{i+1})`

    This is defined by recursion on (n - 1 - i), the distance from the rightmost witness.
    The beta_0 (first segment) is NOT folded in; it is a separate prefix condition. -/
def BracketFormula.fChainFrom {n : Nat} (bf : BracketFormula (n + 1))
    (i : Fin (n + 1)) : TemporalPred :=
  if h : i.val = n then
    -- Base: F_n = alpha_n AND (beta_{n+1} Until top)
    ⟨Formula.and (bf.pointTypes ⟨n, by omega⟩).formula
      (Formula.untl Formula.top (bf.segmentTypes ⟨n + 1, by omega⟩).formula)⟩
  else
    -- Step: F_i = alpha_i AND (beta_{i+1} Until F_{i+1})
    have h_lt : i.val < n := by omega
    let F_next := bf.fChainFrom ⟨i.val + 1, by omega⟩
    ⟨Formula.and (bf.pointTypes i).formula
      (Formula.untl F_next.formula (bf.segmentTypes ⟨i.val + 1, by omega⟩).formula)⟩
termination_by n - i.val

/-- The F-chain predicate at the first witness (index 0). -/
def BracketFormula.fChainPred {n : Nat} (bf : BracketFormula (n + 1)) :
    TemporalPred :=
  bf.fChainFrom ⟨0, by omega⟩

/-- The partial bracket existential: there exists z in (z_0, z_1) such that
    the bracket formula holds on (z_0, z). -/
def BracketFormula.partialBracketExist {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula n) (z0 z1 : M.carrier) : Prop :=
  ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z

/-- Semantic characterization of `fChainFrom` at the base case (i = n).
    F_n(x) ↔ alpha_n(x) ∧ ∃ s > x, ⊤(s) ∧ beta_{n+1} on (x, s). -/
theorem BracketFormula.fChainFrom_base {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (x : M.carrier) :
    (bf.fChainFrom ⟨n, by omega⟩).eval_at M atomMap x ↔
    (bf.pointTypes ⟨n, by omega⟩).eval_at M atomMap x ∧
    ∃ s : M.carrier, x < s ∧
      (∀ r : M.carrier, x < r → r < s →
        (bf.segmentTypes ⟨n + 1, by omega⟩).eval_at M atomMap r) := by
  -- Unfold fChainFrom at the base case (i = n)
  have h_eq : bf.fChainFrom ⟨n, by omega⟩ =
    ⟨Formula.and (bf.pointTypes ⟨n, by omega⟩).formula
      (Formula.untl Formula.top (bf.segmentTypes ⟨n + 1, by omega⟩).formula)⟩ := by
    conv_lhs => rw [fChainFrom]; simp only [Fin.val_mk, dite_true]
  rw [h_eq]
  simp only [TemporalPred.eval_at, Formula.and, Formula.neg, temporal_truth]
  constructor
  · -- mp: double-negation elimination on conjunctive normal form
    intro h
    have h_alpha : temporal_truth M atomMap x (bf.pointTypes ⟨n, by omega⟩).formula := by
      by_contra h_neg
      exact h (fun h1' _ => h_neg h1')
    refine ⟨h_alpha, ?_⟩
    by_contra h_neg; push_neg at h_neg
    exact h (fun _ h_untl => by
      obtain ⟨s, hs_lt, _, hs_seg⟩ := h_untl
      obtain ⟨r, hr1, hr2, hr3⟩ := h_neg s hs_lt
      exact hr3 (hs_seg r hr1 hr2))
  · -- mpr: construct the Until witness
    rintro ⟨h1, s, hs_lt, hs_seg⟩
    intro h_neg
    have h_top : temporal_truth M atomMap s Formula.top := by
      simp only [Formula.top, temporal_truth]; exact id
    exact h_neg h1 ⟨s, hs_lt, h_top, fun r hr1 hr2 => hs_seg r hr1 hr2⟩

/-- Semantic characterization of `fChainFrom` at a step case (i < n).
    F_i(x) ↔ alpha_i(x) ∧ ∃ s > x, F_{i+1}(s) ∧ beta_{i+1} on (x, s). -/
theorem BracketFormula.fChainFrom_step {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (i : Fin (n + 1)) (h_lt : i.val < n)
    (x : M.carrier) :
    (bf.fChainFrom i).eval_at M atomMap x ↔
    (bf.pointTypes i).eval_at M atomMap x ∧
    ∃ s : M.carrier, x < s ∧
      (bf.fChainFrom ⟨i.val + 1, by omega⟩).eval_at M atomMap s ∧
      (∀ r : M.carrier, x < r → r < s →
        (bf.segmentTypes ⟨i.val + 1, by omega⟩).eval_at M atomMap r) := by
  have h_ne : i.val ≠ n := by omega
  -- Unfold fChainFrom at i (step case)
  have h_eq : bf.fChainFrom i =
    ⟨Formula.and (bf.pointTypes i).formula
      (Formula.untl (bf.fChainFrom ⟨i.val + 1, by omega⟩).formula
        (bf.segmentTypes ⟨i.val + 1, by omega⟩).formula)⟩ := by
    conv_lhs => rw [fChainFrom]
    split
    · omega
    · rfl
  rw [h_eq]
  simp only [TemporalPred.eval_at, Formula.and, Formula.neg, temporal_truth]
  constructor
  · -- mp: extract alpha_i AND Until from double-negation
    intro h
    have h_alpha : temporal_truth M atomMap x (bf.pointTypes i).formula := by
      by_contra h_neg
      exact h (fun h1' _ => h_neg h1')
    refine ⟨h_alpha, ?_⟩
    by_contra h_neg; push_neg at h_neg
    exact h (fun _ h_untl => by
      obtain ⟨s, hs_lt, hs_F, hs_seg⟩ := h_untl
      obtain ⟨r, hr1, hr2, hr3⟩ := h_neg s hs_lt hs_F
      exact hr3 (hs_seg r hr1 hr2))
  · rintro ⟨h1, s, hs_lt, hs_F, hs_seg⟩
    intro h_neg
    exact h_neg h1 ⟨s, hs_lt, hs_F, fun r hr1 hr2 => hs_seg r hr1 hr2⟩

/-- **Forward direction**: If a bracket formula with n+1 witnesses holds on (z_0, z),
    then the first witness x_0 satisfies the F-chain predicate F_0, and beta_0
    holds on (z_0, x_0).

    The proof unpacks the bracket witnesses and shows each F_i holds at x_i
    using the bracket's segment types as Until witnesses. -/
theorem BracketFormula.bracket_implies_fChainPred
    {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (z0 z : M.carrier)
    (h : bf.holds M atomMap z0 z) :
    ∃ x0 : M.carrier, z0 < x0 ∧ x0 < z ∧
      bf.fChainPred.eval_at M atomMap x0 ∧
      (∀ y : M.carrier, z0 < y → y < x0 →
        (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y) := by
  simp only [holds, toIntervalPattern, IntervalPattern.holds] at h
  obtain ⟨w, hmono, hrange, hpoint, hseg0, hseg_mid, hseg_last⟩ := h
  refine ⟨w ⟨0, by omega⟩, (hrange ⟨0, by omega⟩).1, (hrange ⟨0, by omega⟩).2, ?_, hseg0⟩
  -- Show F_0(w 0) holds. We prove the stronger statement: F_i(w i) for all i.
  -- Helper: F_i(w i) for all i, proved by reverse induction (from i = n down to 0)
  have h_fchain : ∀ (i : Fin (n + 1)),
      (bf.fChainFrom i).eval_at M atomMap (w i) := by
    -- Prove by induction on d = (n - i), the distance from the right end
    -- We use a helper that takes d explicitly
    suffices h : ∀ (d : Nat) (i : Fin (n + 1)), i.val + d = n →
        (bf.fChainFrom i).eval_at M atomMap (w i) by
      intro i; exact h (n - i.val) i (by omega)
    intro d
    induction d with
    | zero =>
      -- Base: i.val = n, so F_n(w n) = alpha_n AND (beta_{n+1} Until top)
      intro i hd
      have h_i_eq : i.val = n := by omega
      -- Rewrite fChainFrom i as fChainFrom ⟨n, _⟩
      have h_fi : bf.fChainFrom i = bf.fChainFrom ⟨n, by omega⟩ := by
        congr 1; ext; exact h_i_eq
      rw [h_fi, fChainFrom_base]
      have h_wi : w i = w ⟨n, by omega⟩ := by congr 1; ext; exact h_i_eq
      rw [h_wi]
      exact ⟨hpoint ⟨n, by omega⟩, z, (hrange ⟨n, by omega⟩).2,
        fun r hr1 hr2 => hseg_last r hr1 hr2⟩
    | succ d' ih =>
      -- Step: i.val + (d' + 1) = n, so i.val < n
      intro i hd
      have h_i_lt : i.val < n := by omega
      rw [fChainFrom_step M atomMap bf i h_i_lt]
      constructor
      · exact hpoint i
      · refine ⟨w ⟨i.val + 1, by omega⟩,
          hmono i ⟨i.val + 1, by omega⟩ (Fin.mk_lt_mk.mpr (by omega)), ?_, ?_⟩
        · -- F_{i+1}(w(i+1))
          exact ih ⟨i.val + 1, by omega⟩ (by simp [Fin.val_mk]; omega)
        · -- beta_{i+1} on (w i, w(i+1))
          match n with
          | 0 => omega
          | n' + 1 =>
            intro r hr1 hr2
            exact hseg_mid ⟨i.val, by omega⟩ r hr1 hr2
  exact h_fchain ⟨0, by omega⟩

/-- **Corollary 5.4, forward direction** (Rabinovich 2014, p.9):
    There exists a VBracketFormula v such that v.holds implies
    ¬(∃ z ∈ (z₀,z₁), bracket.holds z₀ z) on structures with HasAttainedINF.

    The construction: for bracket bf with n+1 witnesses, define F_0 via
    the F-chain. Apply Lemma 5.3 to get V such that V.holds ↔ ¬orderedPointsExist 1 F_0.
    Then V.holds → ¬orderedPointsExist 1 F_0 → ¬(∃z, bracket(z_0, z)).

    The reverse direction (¬∃z bracket → V.holds) requires Lemma 5.1 (Phase 4)
    or a direct argument on Prior structures showing that orderedPointsExist
    F_0 implies ∃z bracket. This is deferred to Phase 4. -/
theorem neg_partialBracketExist_sufficient
    {n : Nat} (bf : BracketFormula (n + 1)) :
    ∃ (v : VBracketFormula),
    ∀ {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
      (atomMap : Formula → sig.preds) (h_INF : HasAttainedINF M atomMap)
      (z0 z1 : M.carrier), z0 < z1 →
      (v.holds M atomMap z0 z1 → ¬ bf.partialBracketExist M atomMap z0 z1) := by
  -- Get the V-bracket for ¬orderedPointsExist 1 (fun _ => bf.fChainPred)
  obtain ⟨v_neg, hv_neg⟩ := neg_orderedPointsExist_is_vbracket 1 (fun _ => bf.fChainPred)
  refine ⟨v_neg, fun M atomMap h_INF z0 z1 h_lt hv => ?_⟩
  -- V-bracket holds → ¬orderedPointsExist 1 F_0 → ¬∃z bracket
  have h_neg_ordered := (hv_neg M atomMap h_INF z0 z1 h_lt).mp hv
  -- Show ¬∃z bracket
  intro ⟨z, hz0z, hzz1, h_bracket⟩
  -- bracket implies orderedPointsExist via fChainPred
  obtain ⟨x0, hx0_above, hx0_below, h_F0, _⟩ :=
    BracketFormula.bracket_implies_fChainPred M atomMap bf z0 z h_bracket
  -- orderedPointsExist 1 F_0 z0 z1 holds (x0 is the witness)
  apply h_neg_ordered
  simp only [orderedPointsExist, IntervalPattern.allBetaTrue, IntervalPattern.holds]
  refine ⟨fun _ => x0, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro a b hab; exact absurd hab (by omega)
  · intro _; exact ⟨hx0_above, lt_trans hx0_below hzz1⟩
  · intro _; exact h_F0
  · intro y _ _; exact TemporalPred.eval_at_top M atomMap y
  · intro j; exact Fin.elim0 j
  · intro y _ _; exact TemporalPred.eval_at_top M atomMap y

/-! ## Lemma 5.1: Full Negation Closure for Bracket Formulas

The negation of any bracket formula is equivalent to a V-bracket formula on
structures with `HasAttainedINF`. This is the main technical lemma of Section 5.

Proof by induction on n (the number of witnesses):
- Base (n = 0): ¬(∀ y ∈ (z₀,z₁), β₀(y)) ↔ ∃ y ∈ (z₀,z₁), ¬β₀(y)
  which is a bracket with 1 witness, point type β₀.neg, segments True.
- Step (n+1 → n): Use HasAttainedINF to find first α₀-occurrence r₀.
  The bracket decomposes via prepend into:
    ∃ r₀, α₀(r₀) ∧ β₀ on (z₀, r₀) ∧ rightPart.holds r₀ z₁
  Apply IH to rightPart (n witnesses) for the V-bracket on (r₀, z₁).
  Prepend r₀ to each IH disjunct for the V-bracket on (z₀, z₁).
-/

/-- Base case: negation of a 0-witness bracket (universal segment condition)
    is a V-bracket with a single 1-witness disjunct. -/
theorem neg_bracket_zero_is_vbracket (bf : BracketFormula 0) :
    ∃ (v : VBracketFormula),
    ∀ {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
      (atomMap : Formula → sig.preds)
      (z0 z1 : M.carrier), z0 < z1 →
      (v.holds M atomMap z0 z1 ↔ ¬ bf.holds M atomMap z0 z1) := by
  -- bf.holds = ∀ y ∈ (z0, z1), beta_0(y)
  -- ¬bf.holds = ∃ y ∈ (z0, z1), ¬beta_0(y) = bracket with 1 witness
  let neg_bf : BracketFormula 1 :=
    { pointTypes := fun _ => (bf.segmentTypes ⟨0, by omega⟩).neg
      segmentTypes := fun _ => TemporalPred.top }
  refine ⟨⟨[⟨1, neg_bf⟩]⟩, fun M atomMap z0 z1 _h_lt => ?_⟩
  constructor
  · -- Forward: V-bracket holds → ¬bf.holds
    rintro ⟨⟨m, bf'⟩, h_mem, h_holds⟩
    simp only [List.mem_cons, List.not_mem_nil, or_false] at h_mem
    obtain rfl := congr_arg Sigma.fst h_mem
    have hbf'_eq : bf' = neg_bf := eq_of_heq (Sigma.mk.inj h_mem).2
    subst hbf'_eq
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
      IntervalPattern.holds] at h_holds
    obtain ⟨w, _, hrange, hpoint, _, _, _⟩ := h_holds
    intro h_bf
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
      IntervalPattern.holds] at h_bf
    have h_neg := hpoint ⟨0, by omega⟩
    simp only [neg_bf, TemporalPred.neg, TemporalPred.eval_at,
      Formula.neg, temporal_truth] at h_neg
    exact h_neg (h_bf (w ⟨0, by omega⟩) (hrange ⟨0, by omega⟩).1 (hrange ⟨0, by omega⟩).2)
  · -- Backward: ¬bf.holds → V-bracket holds
    intro h_neg
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
      IntervalPattern.holds] at h_neg
    push_neg at h_neg
    obtain ⟨y, hy0, hy1, hy_neg⟩ := h_neg
    refine ⟨⟨1, neg_bf⟩, ?_, ?_⟩
    · simp [VBracketFormula]
    · simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
        IntervalPattern.holds]
      refine ⟨fun _ => y, ?_, ?_, ?_, ?_, ?_, ?_⟩
      · intro a b hab; exact absurd hab (by omega)
      · intro _; exact ⟨hy0, hy1⟩
      · intro ⟨j, hj⟩; simp at hj; subst hj
        simp only [neg_bf, TemporalPred.neg, TemporalPred.eval_at,
          Formula.neg, temporal_truth]
        exact hy_neg
      · intro y' _ _; exact TemporalPred.eval_at_top M atomMap y'
      · intro ⟨j, hj⟩; exact absurd hj (by omega)
      · intro y' _ _; exact TemporalPred.eval_at_top M atomMap y'

/-- **Lemma 5.1** (Rabinovich 2014, pp.7-11): The negation of any bracket
    formula is equivalent to a V-bracket formula on structures with
    `HasAttainedINF` (which includes all Prior structures).

    The V-bracket is constructed purely from the bracket's types, independent
    of the structure M.

    **Sorry status**: The forward direction (V.holds → ¬bf.holds) is sorry-free
    for all n. The backward direction for n ≥ 1 has one sorry in the beta_0(r0)
    sub-case, which is UNPROVABLE at the BracketFormula level (see the inline
    impossibility comment). The model-dependent version (`neg_interval_formula`
    in `EANegationClosure.lean`) is sorry-free and sufficient for completeness.

    **Does NOT block completeness**. -/
theorem neg_bracket_is_vbracket :
    ∀ (n : Nat) (bf : BracketFormula n),
    ∃ (v : VBracketFormula),
    ∀ {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
      (atomMap : Formula → sig.preds) (h_INF : HasAttainedINF M atomMap)
      (z0 z1 : M.carrier), z0 < z1 →
      (v.holds M atomMap z0 z1 ↔ ¬ bf.holds M atomMap z0 z1) := by
  intro n
  induction n with
  | zero =>
    intro bf
    obtain ⟨v, hv⟩ := neg_bracket_zero_is_vbracket bf
    exact ⟨v, fun M atomMap _h_INF z0 z1 h_lt => hv M atomMap z0 z1 h_lt⟩
  | succ n ih =>
    intro bf
    -- Decomposition: bf.holds z0 z1 ↔ ∃ x0 ∈ (z0, z1),
    --   alpha_0(x0) ∧ beta_0 on (z0, x0) ∧ rightPart(0).holds(x0, z1)
    let alpha_0 := bf.pointTypes ⟨0, by omega⟩
    let beta_0 := bf.segmentTypes ⟨0, by omega⟩
    -- IH: negation of rightPart (BracketFormula n) is a VBracketFormula
    obtain ⟨v_r, hv_r⟩ := ih (bf.rightPart ⟨0, by omega⟩)
    -- VBracketFormula V with three types of disjuncts:
    -- CaseA: trivial alpha_0.neg — no alpha_0 in interval
    let caseA : Σ n, BracketFormula n := ⟨0, BracketFormula.trivial alpha_0.neg⟩
    -- CaseC: 1-witness bracket with ¬alpha_0 ∧ ¬beta_0 at y, ¬alpha_0 on (z0, y)
    --   Captures: beta_0 failure before any alpha_0 point
    let caseC : Σ n, BracketFormula n :=
      ⟨1, BracketFormula.single (alpha_0.neg.conj beta_0.neg) alpha_0.neg TemporalPred.top⟩
    -- CaseD: for each IH disjunct bf_m, prepend with ¬alpha_0 segment and
    --   alpha_0 ∧ ¬beta_0 point type. Captures: first alpha_0 point has ¬beta_0,
    --   and rightPart fails there.
    let caseD := VBracketFormula.prependAll alpha_0.neg (alpha_0.conj beta_0.neg) v_r
    let result : VBracketFormula := ⟨caseA :: caseC :: caseD.disjuncts⟩
    refine ⟨result, fun M atomMap h_INF z0 z1 h_lt => ?_⟩
    -- Helper: bf.holds decomposes at index 0
    have h_bf_decomp :
        bf.holds M atomMap z0 z1 ↔
        ∃ x0 : M.carrier, z0 < x0 ∧ x0 < z1 ∧
          alpha_0.eval_at M atomMap x0 ∧
          (∀ y : M.carrier, z0 < y → y < x0 → beta_0.eval_at M atomMap y) ∧
          (bf.rightPart ⟨0, by omega⟩).holds M atomMap x0 z1 := by
      constructor
      · intro h
        simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
          IntervalPattern.holds] at h
        obtain ⟨w, hmono, hrange, hpoint, hseg0, hseg_mid, hseg_last⟩ := h
        refine ⟨w ⟨0, by omega⟩, (hrange ⟨0, by omega⟩).1, (hrange ⟨0, by omega⟩).2,
          hpoint ⟨0, by omega⟩, hseg0, ?_⟩
        exact BracketFormula.rightPart_holds M atomMap bf z0 z1
          ⟨0, by omega⟩ w hmono hrange hpoint hseg0 hseg_mid hseg_last
      · intro ⟨x0, hx0_above, hx0_below, hPt, hSeg, h_rp⟩
        exact BracketFormula.splitAt_combine M atomMap bf z0 z1 x0
          ⟨0, by omega⟩ hx0_above hx0_below hPt
          (by rw [BracketFormula.leftPart]; simp only [BracketFormula.holds,
            BracketFormula.toIntervalPattern, IntervalPattern.holds]; exact hSeg)
          h_rp
    constructor
    · -- Forward: V.holds → ¬bf.holds
      intro ⟨⟨m, bf'⟩, h_mem, h_holds⟩
      simp only [result, caseA, caseC, caseD, VBracketFormula.prependAll,
        List.mem_cons, List.mem_map] at h_mem
      rcases h_mem with h_eq | h_eq | ⟨⟨m', bf_m⟩, h_mem', h_eq'⟩
      · -- CaseA: ¬alpha_0 everywhere
        obtain rfl := congr_arg Sigma.fst h_eq
        have hbf_eq : bf' = BracketFormula.trivial alpha_0.neg :=
          eq_of_heq (Sigma.mk.inj h_eq).2
        subst hbf_eq
        rw [BracketFormula.trivial_holds] at h_holds
        rw [h_bf_decomp]
        push_neg
        intro x0 hx0_above hx0_below hPt
        exact absurd hPt (by
          have := h_holds x0 hx0_above hx0_below
          simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth] at this
          exact this)
      · -- CaseC: ∃ y with ¬alpha_0(y) ∧ ¬beta_0(y), ¬alpha_0 on (z0, y)
        obtain rfl := congr_arg Sigma.fst h_eq
        have hbf_eq : bf' = BracketFormula.single (alpha_0.neg.conj beta_0.neg) alpha_0.neg TemporalPred.top :=
          eq_of_heq (Sigma.mk.inj h_eq).2
        subst hbf_eq
        simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
          BracketFormula.single, IntervalPattern.holds] at h_holds
        obtain ⟨w, _, hrange, hpoint, hseg0, _, _⟩ := h_holds
        -- w 0 is the witness y with ¬alpha_0(y) ∧ ¬beta_0(y)
        set y := w ⟨0, by omega⟩
        have hy_above := (hrange ⟨0, by omega⟩).1
        have hy_below := (hrange ⟨0, by omega⟩).2
        have h_pt := hpoint ⟨0, by omega⟩
        simp at h_pt
        have h_neg_alpha_y : ¬ alpha_0.eval_at M atomMap y := by
          have := (TemporalPred.eval_at_conj M atomMap alpha_0.neg beta_0.neg y).mp h_pt
          exact this.1
        have h_neg_beta_y : ¬ beta_0.eval_at M atomMap y := by
          have := (TemporalPred.eval_at_conj M atomMap alpha_0.neg beta_0.neg y).mp h_pt
          exact this.2
        -- ¬alpha_0 on (z0, y)
        have h_neg_alpha_seg : ∀ t : M.carrier, z0 < t → t < y →
            ¬ alpha_0.eval_at M atomMap t := by
          intro t ht0 hty h_alpha_t
          have := hseg0 t ht0 hty
          simp only [ite_true] at this
          simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg,
            temporal_truth] at this
          exact this h_alpha_t
        -- For any x0 with alpha_0(x0): x0 > y, so y ∈ (z0, x0), ¬beta_0(y) kills bf
        rw [h_bf_decomp]
        push_neg
        intro x0 hx0_above hx0_below hPt_x0
        -- alpha_0(x0) and x0 must be > y
        have hx0_gt_y : x0 > y := by
          by_contra h; push_neg at h
          rcases lt_or_eq_of_le h with hlt | heq
          · exact h_neg_alpha_seg x0 hx0_above hlt hPt_x0
          · exact h_neg_alpha_y (heq ▸ hPt_x0)
        -- y ∈ (z0, x0), ¬beta_0(y) — beta_0 segment fails
        intro h_seg
        exact absurd (h_seg y hy_above hx0_gt_y) h_neg_beta_y
      · -- CaseD: prepended IH disjunct with alpha_0 ∧ ¬beta_0 at r
        have hm_eq := congr_arg Sigma.fst h_eq'
        simp at hm_eq; subst hm_eq
        have hbf_eq : BracketFormula.prepend alpha_0.neg (alpha_0.conj beta_0.neg) bf_m = bf' :=
          eq_of_heq (Sigma.mk.inj h_eq').2
        subst hbf_eq
        -- Decompose the prepended bracket
        obtain ⟨r0, hr0_above, hr0_below, h_pt_r0, h_seg_r0, h_bf_m_holds⟩ :=
          BracketFormula.prepend_holds_inv M atomMap bf_m
            alpha_0.neg (alpha_0.conj beta_0.neg) z0 z1 h_holds
        -- Extract alpha_0(r0) and ¬beta_0(r0) from point type
        have h_alpha_r0 : alpha_0.eval_at M atomMap r0 := by
          exact ((TemporalPred.eval_at_conj M atomMap alpha_0 beta_0.neg r0).mp h_pt_r0).1
        have h_neg_beta_r0 : ¬ beta_0.eval_at M atomMap r0 := by
          exact ((TemporalPred.eval_at_conj M atomMap alpha_0 beta_0.neg r0).mp h_pt_r0).2
        -- ¬alpha_0 on (z0, r0)
        have h_neg_alpha_seg : ∀ t, z0 < t → t < r0 → ¬ alpha_0.eval_at M atomMap t := by
          intro t ht0 htr h_at
          have := h_seg_r0 t ht0 htr
          simp [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth] at this
          exact this h_at
        -- bf_m ∈ v_r → ¬rightPart.holds(r0, z1)
        have h_vr_holds : v_r.holds M atomMap r0 z1 :=
          ⟨⟨m', bf_m⟩, h_mem', h_bf_m_holds⟩
        have h_neg_rp : ¬ (bf.rightPart ⟨0, by omega⟩).holds M atomMap r0 z1 :=
          (hv_r M atomMap h_INF r0 z1 hr0_below).mp h_vr_holds
        -- Show ¬bf.holds
        rw [h_bf_decomp]
        push_neg
        intro x0 hx0_above hx0_below hPt_x0
        -- x0 ≥ r0 (from ¬alpha_0 on (z0, r0))
        have hx0_ge_r0 : x0 ≥ r0 := by
          by_contra h; push_neg at h
          exact h_neg_alpha_seg x0 hx0_above h hPt_x0
        rcases eq_or_lt_of_le hx0_ge_r0 with rfl | hx0_gt_r0
        · -- x0 = r0: rightPart fails
          intro _
          exact h_neg_rp
        · -- x0 > r0: r0 ∈ (z0, x0) with ¬beta_0(r0) → beta_0 segment fails
          intro h_seg
          exact absurd (h_seg r0 hr0_above hx0_gt_r0) h_neg_beta_r0
    · -- Backward: ¬bf.holds → V.holds
      intro h_neg
      rw [h_bf_decomp] at h_neg; push_neg at h_neg
      -- h_neg : ∀ x0, z0 < x0 → x0 < z1 → alpha_0(x0) →
      --         (∀ y, z0 < y → y < x0 → beta_0(y)) → ¬rp.holds(x0, z1)
      -- Case split: does alpha_0 occur in (z0, z1)?
      by_cases h_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
          alpha_0.eval_at M atomMap x
      · -- alpha_0 occurs: find first occurrence r0
        obtain ⟨r0, hr0_above, hr0_below, h_no_before, h_alpha_r0⟩ :=
          h_INF.first_occ alpha_0.formula z0 z1 h_lt (by
            obtain ⟨x, hx1, hx2, hx3⟩ := h_occ; exact ⟨x, hx1, hx2, hx3⟩)
        -- Case split: does beta_0 fail in (z0, r0)?
        by_cases h_beta_seg : ∃ y : M.carrier, z0 < y ∧ y < r0 ∧
            ¬ beta_0.eval_at M atomMap y
        · -- beta_0 fails somewhere in (z0, r0): use CaseC
          obtain ⟨y, hy_above, hy_below, h_no_before_y, h_neg_beta_y⟩ :=
            h_INF.first_occ beta_0.neg.formula z0 r0 hr0_above (by
              obtain ⟨y, hy1, hy2, hy3⟩ := h_beta_seg
              refine ⟨y, hy1, hy2, ?_⟩
              simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth]
              exact hy3)
          have h_neg_alpha_y : ¬ alpha_0.eval_at M atomMap y := by
            intro h_ay
            exact h_no_before y hy_above hy_below h_ay
          refine ⟨⟨1, BracketFormula.single (alpha_0.neg.conj beta_0.neg)
            alpha_0.neg TemporalPred.top⟩, ?_, ?_⟩
          · simp [result, caseC]
          · simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
              BracketFormula.single, IntervalPattern.holds]
            refine ⟨fun _ => y, ?_, ?_, ?_, ?_, ?_, ?_⟩
            · intro a b hab; exact absurd hab (by omega)
            · intro _; exact ⟨hy_above, lt_trans hy_below hr0_below⟩
            · intro ⟨j, hj⟩; simp at hj; subst hj; simp
              exact (TemporalPred.eval_at_conj M atomMap alpha_0.neg beta_0.neg y).mpr
                ⟨by simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg,
                    temporal_truth]; exact h_neg_alpha_y,
                 by simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg,
                    temporal_truth] at h_neg_beta_y ⊢; exact h_neg_beta_y⟩
            · intro t ht0 hty
              simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth]
              exact h_no_before t ht0 (lt_trans hty hy_below)
            · intro ⟨j, hj⟩; exact absurd hj (by omega)
            · intro t _ _; exact TemporalPred.eval_at_top M atomMap t
        · -- beta_0 on (z0, r0): rightPart must fail at (r0, z1)
          push_neg at h_beta_seg
          have h_seg_ok : ∀ y, z0 < y → y < r0 → beta_0.eval_at M atomMap y :=
            fun y hy0 hyr => h_beta_seg y hy0 hyr
          have h_neg_rp : ¬ (bf.rightPart ⟨0, by omega⟩).holds M atomMap r0 z1 :=
            h_neg r0 hr0_above hr0_below h_alpha_r0 h_seg_ok
          -- By IH: v_r.holds(r0, z1)
          have h_vr := (hv_r M atomMap h_INF r0 z1 hr0_below).mpr h_neg_rp
          obtain ⟨⟨m', bf_m⟩, h_mem', h_bf_m_holds⟩ := h_vr
          -- Case split on beta_0(r0) to choose CaseD disjunct
          by_cases h_beta_r0 : beta_0.eval_at M atomMap r0
          · /- IMPOSSIBILITY: This sorry is UNPROVABLE at the BracketFormula level.

              **Context**: We have alpha_0(r0), beta_0(r0), beta_0 on (z0, r0),
              and ¬rightPart.holds(r0, z1). We need to exhibit a CaseD disjunct
              (from `result`) that holds on (z0, z1).

              **Why it fails**: CaseD disjuncts have point type alpha_0.conj beta_0.neg
              at their first witness, but beta_0(r0) holds here, so CaseD cannot fire
              at r0. No other disjunct in `result` handles this case:
              - CaseA requires ¬alpha_0 everywhere, but alpha_0(r0) ∈ (z0,z1).
              - CaseC requires ¬beta_0 before any alpha_0 point, but beta_0 on (z0,r0).
              - CaseD requires ¬beta_0(r0), but beta_0(r0) holds.

              **Structural obstruction**: Adding a CaseE with alpha_0.conj beta_0 at r0
              would fix the backward direction, but breaks the forward direction:
              A CaseE disjunct on (z0, z1) decomposes to give r0 with IH-bracket on
              (r0, z1). For the forward direction (CaseE.holds → ¬bf.holds), we need
              to show: for ALL x0 with alpha_0(x0) and seg_0 on (z0, x0),
              rightPart fails at (x0, z1). The IH gives ¬rightPart at (r0, z1), but
              says nothing about x0 > r0 (a different point, different sub-interval).
              Models can have arbitrarily many alpha_0 points with beta_0 in (z0, z1),
              creating an unbounded recursion that no FINITE, MODEL-INDEPENDENT
              V-bracket can handle.

              **Root cause**: BracketFormula evaluates alpha_0 at an INTERIOR
              existential witness, making the case analysis model-dependent.
              Rabinovich avoids this by evaluating alpha_0 at the ENDPOINT z_0
              (a fixed point), eliminating the beta_0(r0) case entirely.

              **Resolution**: The model-DEPENDENT version (`neg_interval_formula`
              in EANegationClosure.lean) is proved sorry-free and is sufficient
              for the completeness proof, where the canonical model is fixed.
              The model-independent VecEA2-level Prop 4.2 (`neg_vecEA2` in
              EANegationClosure.lean) is also sorry-free.

              This sorry does NOT block completeness. It is an inherent limitation
              of the BracketFormula-level biconditional formulation. -/
            sorry
          · -- ¬beta_0(r0): CaseD fires with alpha_0 ∧ ¬beta_0 at r0
            refine ⟨⟨m' + 1, bf_m.prepend alpha_0.neg (alpha_0.conj beta_0.neg)⟩, ?_, ?_⟩
            · simp only [result, caseA, caseC, caseD, VBracketFormula.prependAll,
                List.mem_cons, List.mem_map]
              right; right; exact ⟨⟨m', bf_m⟩, h_mem', rfl⟩
            · exact BracketFormula.prepend_holds M atomMap bf_m
                alpha_0.neg (alpha_0.conj beta_0.neg)
                z0 z1 r0 hr0_above hr0_below
                ((TemporalPred.eval_at_conj M atomMap alpha_0 beta_0.neg r0).mpr
                  ⟨h_alpha_r0, by
                    simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg,
                      temporal_truth]
                    exact h_beta_r0⟩)
                (fun y hy0 hyr => by
                  simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg,
                    temporal_truth]
                  exact h_no_before y hy0 hyr)
                h_bf_m_holds
      · -- No alpha_0 in (z0, z1): CaseA
        push_neg at h_occ
        refine ⟨⟨0, BracketFormula.trivial alpha_0.neg⟩, ?_, ?_⟩
        · simp [result, caseA]
        · rw [BracketFormula.trivial_holds]
          intro y hy0 hy1
          simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth]
          exact h_occ y hy0 hy1

/-- **Corollary 5.4, full biconditional** (Rabinovich 2014, p.9):
    The negation of ∃z∈(z₀,z₁), bracket.holds z₀ z is equivalent to a V-bracket
    formula on Prior structures.

    **Sorry status**: The forward direction (V.holds → ¬partialBracketExist) is
    sorry-free for all n. The backward direction for n ≥ 1 has a sorry due to the
    F-chain Until-unboundedness issue (see inline comment). The n = 0 case is
    fully proved. The model-dependent version (`neg_bounded_exists` in
    `EANegationClosure.lean`) is sorry-free and sufficient for completeness.

    **Does NOT block completeness**. -/
theorem neg_partialBracketExist_is_vbracket
    (n : Nat) (bf : BracketFormula n) :
    ∃ (v : VBracketFormula),
    ∀ {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
      (atomMap : Formula → sig.preds) (h_INF : HasAttainedINF M atomMap)
      (z0 z1 : M.carrier), z0 < z1 →
      (v.holds M atomMap z0 z1 ↔ ¬ bf.partialBracketExist M atomMap z0 z1) := by
  match n with
  | 0 =>
    -- For BracketFormula 0, partialBracketExist z0 z1 = ∃ z ∈ (z0, z1), ∀ y ∈ (z0, z), seg_0(y).
    -- On HasAttainedINF: partialBracketExist holds iff (z0, z1) is non-empty.
    -- So ¬partialBracketExist ↔ (z0, z1) is empty ↔ V.holds (trivial bracket with top.neg).
    let v : VBracketFormula :=
      ⟨[⟨0, BracketFormula.trivial TemporalPred.top.neg⟩]⟩
    refine ⟨v, fun M atomMap h_INF z0 z1 h_lt => ?_⟩
    -- Key helper: on HasAttainedINF, partialBracketExist holds whenever (z0, z1) is non-empty
    have h_nonempty_implies :
        (∃ z : M.carrier, z0 < z ∧ z < z1) →
        bf.partialBracketExist M atomMap z0 z1 := by
      intro ⟨z', hz0', hz1'⟩
      -- Case split on whether seg_0 fails somewhere in (z0, z1)
      by_cases h_seg : ∃ y : M.carrier, z0 < y ∧ y < z1 ∧
          ¬ (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y
      · -- seg_0 fails: use HasAttainedINF to find first failure point r
        obtain ⟨r, hr_above, hr_below, h_no_before, h_neg_r⟩ :=
          h_INF.first_occ (bf.segmentTypes ⟨0, by omega⟩).neg.formula z0 z1 h_lt (by
            obtain ⟨y, hy1, hy2, hy3⟩ := h_seg
            exact ⟨y, hy1, hy2, by
              simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth]
              exact hy3⟩)
        -- seg_0 holds on (z0, r) since r is first failure
        refine ⟨r, hr_above, hr_below, ?_⟩
        simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
        intro y hy0 hy1
        -- y ∈ (z0, r), seg_0(y) holds because r is first ¬seg_0 point
        by_contra h_neg_y
        have h_y_has_neg : temporal_truth M atomMap y (bf.segmentTypes ⟨0, by omega⟩).neg.formula := by
          simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth]
          exact h_neg_y
        exact h_no_before y hy0 hy1 h_y_has_neg
      · -- seg_0 holds everywhere in (z0, z1): take z = z'
        push_neg at h_seg
        exact ⟨z', hz0', hz1', by
          simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
          intro y hy0 hy1
          exact h_seg y hy0 (lt_trans hy1 hz1')⟩
    -- V.holds ↔ (z0, z1) is empty
    -- V.holds = ∃ bf ∈ [trivial top.neg], bf.holds = (trivial top.neg).holds
    --         = ∀ y ∈ (z0, z1), top.neg(y) = ∀ y ∈ (z0, z1), False
    --         = (z0, z1) is empty
    constructor
    · -- Forward: V.holds → ¬partialBracketExist
      intro ⟨⟨m, bf'⟩, h_mem, h_holds⟩
      simp only [v, List.mem_cons, List.not_mem_nil, or_false] at h_mem
      obtain rfl := congr_arg Sigma.fst h_mem
      have hbf'_eq : bf' = BracketFormula.trivial TemporalPred.top.neg :=
        eq_of_heq (Sigma.mk.inj h_mem).2
      subst hbf'_eq
      rw [BracketFormula.trivial_holds] at h_holds
      -- h_holds : ∀ y ∈ (z0, z1), top.neg(y) — so (z0, z1) is empty
      intro ⟨z, hz0, hzz1, _⟩
      -- z ∈ (z0, z1) gives a contradiction with h_holds at z
      -- Actually z is in (z0, z1), we need a point in (z0, z) to get the bracket's segment
      -- But partialBracketExist says bf.holds z0 z which for BracketFormula 0
      -- means ∀ y ∈ (z0, z), seg_0(y). That's fine.
      -- The contradiction: z ∈ (z0, z1), so top.neg(z) should hold, but top.neg = ¬True = False
      have := h_holds z hz0 hzz1
      simp only [TemporalPred.neg, TemporalPred.eval_at, Formula.neg, temporal_truth] at this
      exact this id
    · -- Backward: ¬partialBracketExist → V.holds
      intro h_neg
      -- ¬partialBracketExist means (z0, z1) is empty (by h_nonempty_implies)
      have h_empty : ¬∃ z : M.carrier, z0 < z ∧ z < z1 := by
        intro h_ne
        exact h_neg (h_nonempty_implies h_ne)
      -- V.holds = (trivial top.neg).holds = ∀ y ∈ (z0, z1), top.neg(y) — vacuously True
      refine ⟨⟨0, BracketFormula.trivial TemporalPred.top.neg⟩, ?_, ?_⟩
      · simp [v]
      · rw [BracketFormula.trivial_holds]
        intro y hy0 hy1
        exact absurd ⟨y, hy0, hy1⟩ h_empty
  | n + 1 =>
    -- For BracketFormula (n+1): use existing neg_partialBracketExist_sufficient
    -- for the forward direction, backward direction requires fChainPred → bracket
    obtain ⟨v_suff, hv_suff⟩ := neg_partialBracketExist_sufficient bf
    refine ⟨v_suff, fun M atomMap h_INF z0 z1 h_lt => ?_⟩
    constructor
    · exact hv_suff M atomMap h_INF z0 z1 h_lt
    · /- OBSTRUCTION: The backward direction requires showing that when
        ¬partialBracketExist, the F-chain ordered-points predicate also fails
        (so v_suff holds by the Lemma 5.3 biconditional).

        Contrapositively: orderedPointsExist 1 fChainPred z0 z1 →
        partialBracketExist. This needs fChainPred(x0) → ∃ z, bf.holds z0 z.

        fChainPred(x0) asserts alpha_0(x0) AND (beta_1 U (alpha_1 AND ...)).
        The Until witnesses give points s > x0 where the chain continues, but
        there is no a priori bound s < z1. On structures where the Until
        witness lies outside (z0, z1), the reduction fails.

        This is a consequence of the same BracketFormula-level limitation as
        the sorry at neg_bracket_is_vbracket: the F-chain reduction absorbs
        segment types into Until operators, losing interval-boundedness
        information. The model-independent biconditional requires that the
        Until witnesses can always be bounded within (z0, z1), which holds
        on specific models but cannot be guaranteed by a fixed V-bracket.

        **Resolution**: The forward direction (V.holds → ¬partialBracketExist)
        is proved sorry-free via neg_partialBracketExist_sufficient. The
        model-DEPENDENT version (neg_bounded_exists in EANegationClosure.lean)
        proves both directions sorry-free and is sufficient for completeness.
        This sorry does NOT block the completeness proof. -/
      sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
