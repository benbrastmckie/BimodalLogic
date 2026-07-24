import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-!
# EA-Formula Negation Closure (Rabinovich 2014, Section 5)

Proves that negations of bracket formulas are V-EA on Prior structures:

1. **Lemma 5.3**: Negation of "exists n ordered points with P_i at each"
   is V-EA. The all-betas-True base case.

2. **Corollary 5.4** (F-chain infrastructure): the F-chain construction and
   `bracket_implies_fChainPred`, consumed by `EANegationFix/OnBuilder.lean` and
   `EANegationClosure.lean`.

This file is sorry-free. The retired backward-direction material (the sorried
`neg_bracket_is_vbracket` / `neg_partialBracketExist_is_vbracket` pair with their
support closure) lives in `Boneyard/EANegationVBracketBackward.lean`: it is
unprovable at the `BracketFormula` level and superseded by `VVecEA2.negFix_iff`
(`EANegationFix/VecEANegFix.lean`) and the closure lemmas in
`EANegationClosure.lean`.

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

-- The backward-direction theorems neg_bracket_is_vbracket and
-- neg_partialBracketExist_is_vbracket (with their support closure) were retired to
-- Boneyard/EANegationVBracketBackward.lean: unprovable at the BracketFormula level;
-- superseded by VVecEA2.negFix_iff (EANegationFix/VecEANegFix.lean) and the closure
-- lemmas in EANegationClosure.lean.

end Bimodal.Metalogic.WeakCanonical.Kamp
