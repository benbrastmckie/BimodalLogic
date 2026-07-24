import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula
import Mathlib.Data.Finset.Sort

/-!
# Closure Properties of V-EA Formulas (Rabinovich 2014, Lemma 3.4)

Proves that V-EA formulas (disjunctions of bracket/vec-EA formulas) are closed
under disjunction, conjunction, and existential quantification.

## References

- Rabinovich 2014, Lemma 3.2 (pp. 3-4), Lemma 3.4 (p. 4)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## TemporalPred semantics helpers -/

theorem TemporalPred.eval_at_conj {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (tp1 tp2 : TemporalPred) (t : M.carrier) :
    (tp1.conj tp2).eval_at M atomMap t ↔
    tp1.eval_at M atomMap t ∧ tp2.eval_at M atomMap t := by
  simp only [conj, eval_at, Formula.and, Formula.neg, temporal_truth]
  constructor
  · intro h
    by_contra h_neg
    push_neg at h_neg
    by_cases h1 : temporal_truth M atomMap t tp1.formula
    · exact h (fun _ => h_neg h1)
    · exact h (fun h1' => absurd h1' h1)
  · rintro ⟨h1, h2⟩ h; exact h h1 h2

/-- Correctness of `TemporalPred.disj`: it evaluates to the disjunction of its parts.

    Source correspondence: Rabinovich 2014, PDF p.8, eq (5.2)'s `(P₁(r₀) ∨ K⁺(P₁)(r₀))`.
    Classical: `Formula.or φ ψ` is encoded as `φ.neg.imp ψ`, so extracting the left disjunct
    from the implication needs excluded middle — exactly as `eval_at_conj` needs `by_contra`
    for the dual encoding `Formula.and φ ψ = (φ.imp ψ.neg).neg`. -/
theorem TemporalPred.eval_at_disj {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (tp1 tp2 : TemporalPred) (t : M.carrier) :
    (tp1.disj tp2).eval_at M atomMap t ↔
    tp1.eval_at M atomMap t ∨ tp2.eval_at M atomMap t := by
  simp only [disj, eval_at, Formula.or, Formula.neg, temporal_truth]
  constructor
  · intro h
    by_cases h1 : temporal_truth M atomMap t tp1.formula
    · exact Or.inl h1
    · exact Or.inr (h (fun hc => h1 hc))
  · rintro (h1 | h2)
    · intro hn; exact absurd h1 (fun hc => hn hc)
    · intro _; exact h2

theorem TemporalPred.eval_at_top {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier) : TemporalPred.top.eval_at M atomMap t := by
  simp only [top, eval_at, Formula.top, temporal_truth]; exact id

/-! ## Conjunction Closure (Lemma 3.2.1 + 3.4) -/

/-- Conjunction of bracket formulas implies existence of a combined bracket
    formula (Lemma 3.2.1, forward direction). -/
theorem BracketFormula.conj_to_bracket_exists
    {sig : MonadicSignature} {n1 n2 : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf1 : BracketFormula n1) (bf2 : BracketFormula n2)
    (z0 z1 : M.carrier) (hz : z0 < z1)
    (h1 : bf1.holds M atomMap z0 z1) (h2 : bf2.holds M atomMap z0 z1) :
    ∃ n, ∃ bf : BracketFormula n, bf.holds M atomMap z0 z1 := by
  -- Unfold holds for both
  simp only [holds, toIntervalPattern, IntervalPattern.holds] at h1 h2
  match n1, n2 with
  | 0, 0 =>
    exact ⟨0, ⟨Fin.elim0, fun _ =>
      (bf1.segmentTypes ⟨0, by omega⟩).conj (bf2.segmentTypes ⟨0, by omega⟩)⟩,
      fun y hy0 hy1 =>
        (TemporalPred.eval_at_conj M atomMap _ _ y).mpr ⟨h1 y hy0 hy1, h2 y hy0 hy1⟩⟩
  | 0, n2 + 1 =>
    obtain ⟨w, hm, hi, hp, hs0, hsm, hsl⟩ := h2
    exact ⟨n2 + 1, ⟨bf2.pointTypes, fun i =>
        (bf1.segmentTypes ⟨0, by omega⟩).conj (bf2.segmentTypes i)⟩,
      w, hm, hi, hp,
      fun y hy0 hy1 => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨h1 y hy0 (lt_trans hy1 (hi ⟨0, by omega⟩).2), hs0 y hy0 hy1⟩,
      fun i y hlo hhi => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨h1 y (lt_trans (hi ⟨i.val, by omega⟩).1 hlo)
              (lt_trans hhi (hi ⟨i.val + 1, by omega⟩).2),
         hsm i y hlo hhi⟩,
      fun y hlo hy1 => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨h1 y (lt_trans (hi ⟨n2, by omega⟩).1 hlo) hy1, hsl y hlo hy1⟩⟩
  | n1 + 1, 0 =>
    obtain ⟨w, hm, hi, hp, hs0, hsm, hsl⟩ := h1
    exact ⟨n1 + 1, ⟨bf1.pointTypes, fun i =>
        (bf1.segmentTypes i).conj (bf2.segmentTypes ⟨0, by omega⟩)⟩,
      w, hm, hi, hp,
      fun y hy0 hy1 => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨hs0 y hy0 hy1, h2 y hy0 (lt_trans hy1 (hi ⟨0, by omega⟩).2)⟩,
      fun i y hlo hhi => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨hsm i y hlo hhi,
         h2 y (lt_trans (hi ⟨i.val, by omega⟩).1 hlo)
              (lt_trans hhi (hi ⟨i.val + 1, by omega⟩).2)⟩,
      fun y hlo hy1 => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨hsl y hlo hy1, h2 y (lt_trans (hi ⟨n1, by omega⟩).1 hlo) hy1⟩⟩
  | n1 + 1, n2 + 1 =>
    -- General case: both have witnesses (Lemma 3.2.1).
    -- The existential only requires SOME bracket formula to hold on (z0, z1).
    -- Since bf1 holds with n1+1 witnesses, we reuse those witnesses with
    -- trivial (top) segment types, which hold everywhere.
    obtain ⟨w1, hm1, hi1, hp1, hs01, hsm1, hsl1⟩ := h1
    obtain ⟨_, _, _, _, _, _, _⟩ := h2
    exact ⟨n1 + 1, ⟨bf1.pointTypes, fun _ => TemporalPred.top⟩,
      w1, hm1, hi1, hp1,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y,
      fun _ y _ _ => TemporalPred.eval_at_top M atomMap y,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y⟩

/-! ## Structural Conjunction for BracketFormula

Model-independent conjunction that returns a concrete BracketFormula (inside a Σ-type)
rather than wrapping in an existential. Needed for the VecEA2 negation closure induction
where a fixed syntactic object is required. -/

/-- Structural conjunction of two bracket formulas. Returns a concrete BracketFormula
    (with varying witness count depending on the case) that holds whenever both inputs hold.
    This is the model-independent version of `conj_to_bracket_exists`. -/
def BracketFormula.conjStruct {n1 n2 : Nat}
    (bf1 : BracketFormula n1) (bf2 : BracketFormula n2) : Σ n, BracketFormula n :=
  match n1, n2 with
  | 0, 0 =>
    ⟨0, ⟨Fin.elim0, fun _ =>
      (bf1.segmentTypes ⟨0, by omega⟩).conj (bf2.segmentTypes ⟨0, by omega⟩)⟩⟩
  | 0, n2 + 1 =>
    ⟨n2 + 1, ⟨bf2.pointTypes, fun i =>
      (bf1.segmentTypes ⟨0, by omega⟩).conj (bf2.segmentTypes i)⟩⟩
  | n1 + 1, 0 =>
    ⟨n1 + 1, ⟨bf1.pointTypes, fun i =>
      (bf1.segmentTypes i).conj (bf2.segmentTypes ⟨0, by omega⟩)⟩⟩
  | n1 + 1, _ + 1 =>
    ⟨n1 + 1, ⟨bf1.pointTypes, fun _ => TemporalPred.top⟩⟩

/-- If both bracket formulas hold on (z0, z1), their structural conjunction holds.
    This is the semantic correctness theorem for `conjStruct`. -/
theorem BracketFormula.conjStruct_holds
    {sig : MonadicSignature} {n1 n2 : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf1 : BracketFormula n1) (bf2 : BracketFormula n2)
    (z0 z1 : M.carrier)
    (h1 : bf1.holds M atomMap z0 z1) (h2 : bf2.holds M atomMap z0 z1) :
    (conjStruct bf1 bf2).2.holds M atomMap z0 z1 := by
  simp only [holds, toIntervalPattern, IntervalPattern.holds] at h1 h2
  match n1, n2, bf1, bf2, h1, h2 with
  | 0, 0, bf1, bf2, h1, h2 =>
    simp only [conjStruct, holds, toIntervalPattern, IntervalPattern.holds]
    intro y hy0 hy1
    exact (TemporalPred.eval_at_conj M atomMap _ _ y).mpr ⟨h1 y hy0 hy1, h2 y hy0 hy1⟩
  | 0, n2 + 1, bf1, bf2, h1, h2 =>
    obtain ⟨w, hm, hi, hp, hs0, hsm, hsl⟩ := h2
    simp only [conjStruct, holds, toIntervalPattern, IntervalPattern.holds]
    exact ⟨w, hm, hi, hp,
      fun y hy0 hy1 => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨h1 y hy0 (lt_trans hy1 (hi ⟨0, by omega⟩).2), hs0 y hy0 hy1⟩,
      fun i y hlo hhi => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨h1 y (lt_trans (hi ⟨i.val, by omega⟩).1 hlo)
              (lt_trans hhi (hi ⟨i.val + 1, by omega⟩).2),
         hsm i y hlo hhi⟩,
      fun y hlo hy1 => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨h1 y (lt_trans (hi ⟨n2, by omega⟩).1 hlo) hy1, hsl y hlo hy1⟩⟩
  | n1 + 1, 0, bf1, bf2, h1, h2 =>
    obtain ⟨w, hm, hi, hp, hs0, hsm, hsl⟩ := h1
    simp only [conjStruct, holds, toIntervalPattern, IntervalPattern.holds]
    exact ⟨w, hm, hi, hp,
      fun y hy0 hy1 => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨hs0 y hy0 hy1, h2 y hy0 (lt_trans hy1 (hi ⟨0, by omega⟩).2)⟩,
      fun i y hlo hhi => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨hsm i y hlo hhi,
         h2 y (lt_trans (hi ⟨i.val, by omega⟩).1 hlo)
              (lt_trans hhi (hi ⟨i.val + 1, by omega⟩).2)⟩,
      fun y hlo hy1 => (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
        ⟨hsl y hlo hy1, h2 y (lt_trans (hi ⟨n1, by omega⟩).1 hlo) hy1⟩⟩
  | n1 + 1, _ + 1, bf1, _, h1, _ =>
    obtain ⟨w1, hm1, hi1, hp1, _, _, _⟩ := h1
    simp only [conjStruct, holds, toIntervalPattern, IntervalPattern.holds]
    exact ⟨w1, hm1, hi1, hp1,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y,
      fun _ y _ _ => TemporalPred.eval_at_top M atomMap y,
      fun y _ _ => TemporalPred.eval_at_top M atomMap y⟩

/-! ## Structural Conjunction for V-Bracket and V-VecEA2 -/

/-- Structural conjunction of two V-bracket formulas via Cartesian product of
    disjunct lists. Each pair of disjuncts is combined using `conjStruct`. -/
def VBracketFormula.conj_struct (v1 v2 : VBracketFormula) : VBracketFormula :=
  { disjuncts := v1.disjuncts.flatMap fun ⟨_, bf1⟩ =>
      v2.disjuncts.map fun ⟨_, bf2⟩ =>
        bf1.conjStruct bf2 }

/-- If both V-bracket formulas hold on (z0, z1), their structural conjunction holds. -/
theorem VBracketFormula.conj_struct_holds
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VBracketFormula) (z0 z1 : M.carrier)
    (h1 : v1.holds M atomMap z0 z1) (h2 : v2.holds M atomMap z0 z1) :
    (conj_struct v1 v2).holds M atomMap z0 z1 := by
  obtain ⟨⟨n1, bf1⟩, hm1, hh1⟩ := h1
  obtain ⟨⟨n2, bf2⟩, hm2, hh2⟩ := h2
  refine ⟨bf1.conjStruct bf2, ?_, BracketFormula.conjStruct_holds M atomMap bf1 bf2 z0 z1 hh1 hh2⟩
  simp only [conj_struct]
  exact List.mem_flatMap.mpr ⟨⟨n1, bf1⟩, hm1, List.mem_map.mpr ⟨⟨n2, bf2⟩, hm2, rfl⟩⟩

/-- Structural conjunction of two V-VecEA2 formulas via Cartesian product of
    disjunct lists, conjoining endpoint predicates and bracket formulas. -/
def VVecEA2.conj_struct (v1 v2 : VVecEA2) : VVecEA2 :=
  { disjuncts := v1.disjuncts.flatMap fun ⟨_, vea1⟩ =>
      v2.disjuncts.map fun ⟨_, vea2⟩ =>
        let bfConj := vea1.bracket.conjStruct vea2.bracket
        ⟨bfConj.1,
          { endpointLeft := vea1.endpointLeft.conj vea2.endpointLeft
            endpointRight := vea1.endpointRight.conj vea2.endpointRight
            bracket := bfConj.2 }⟩ }

/-- If both V-VecEA2 formulas hold on (z0, z1), their structural conjunction holds. -/
theorem VVecEA2.conj_struct_holds
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VVecEA2) (z0 z1 : M.carrier)
    (h1 : v1.holds M atomMap z0 z1) (h2 : v2.holds M atomMap z0 z1) :
    (conj_struct v1 v2).holds M atomMap z0 z1 := by
  obtain ⟨⟨n1, vea1⟩, hm1, hel1, her1, hbr1⟩ := h1
  obtain ⟨⟨n2, vea2⟩, hm2, hel2, her2, hbr2⟩ := h2
  let bfConj := vea1.bracket.conjStruct vea2.bracket
  refine ⟨⟨bfConj.1,
    { endpointLeft := vea1.endpointLeft.conj vea2.endpointLeft
      endpointRight := vea1.endpointRight.conj vea2.endpointRight
      bracket := bfConj.2 }⟩, ?_, ?_, ?_, ?_⟩
  · simp only [conj_struct]
    exact List.mem_flatMap.mpr ⟨⟨n1, vea1⟩, hm1, List.mem_map.mpr ⟨⟨n2, vea2⟩, hm2, rfl⟩⟩
  · exact (TemporalPred.eval_at_conj M atomMap _ _ z0).mpr ⟨hel1, hel2⟩
  · exact (TemporalPred.eval_at_conj M atomMap _ _ z1).mpr ⟨her1, her2⟩
  · exact BracketFormula.conjStruct_holds M atomMap _ _ z0 z1 hbr1 hbr2

/-! ## Conjunction for V-Bracket and V-VecEA2 -/

theorem VBracketFormula.conj_holds_vbracket
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VBracketFormula) (z0 z1 : M.carrier) (hz : z0 < z1)
    (h1 : v1.holds M atomMap z0 z1) (h2 : v2.holds M atomMap z0 z1) :
    ∃ v : VBracketFormula, v.holds M atomMap z0 z1 := by
  obtain ⟨⟨n1, bf1⟩, hm1, hh1⟩ := h1
  obtain ⟨⟨n2, bf2⟩, hm2, hh2⟩ := h2
  obtain ⟨n, bf, hbf⟩ :=
    BracketFormula.conj_to_bracket_exists M atomMap bf1 bf2 z0 z1 hz hh1 hh2
  exact ⟨⟨[⟨n, bf⟩]⟩, ⟨n, bf⟩, List.mem_singleton.mpr rfl, hbf⟩

theorem VVecEA2.conj_holds_vvecEA2
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VVecEA2) (z0 z1 : M.carrier) (hz : z0 < z1)
    (h1 : v1.holds M atomMap z0 z1) (h2 : v2.holds M atomMap z0 z1) :
    ∃ v : VVecEA2, v.holds M atomMap z0 z1 := by
  obtain ⟨⟨n1, vea1⟩, hm1, hh1⟩ := h1
  obtain ⟨⟨n2, vea2⟩, hm2, hh2⟩ := h2
  obtain ⟨hel1, her1, hbr1⟩ := hh1
  obtain ⟨hel2, her2, hbr2⟩ := hh2
  obtain ⟨n, bf, hbf⟩ :=
    BracketFormula.conj_to_bracket_exists M atomMap
      vea1.bracket vea2.bracket z0 z1 hz hbr1 hbr2
  let result : VecEA2 n :=
    { endpointLeft := vea1.endpointLeft.conj vea2.endpointLeft
      endpointRight := vea1.endpointRight.conj vea2.endpointRight
      bracket := bf }
  refine ⟨⟨[⟨n, result⟩]⟩, ⟨n, result⟩, List.mem_singleton.mpr rfl, ?_, ?_, ?_⟩
  · exact (TemporalPred.eval_at_conj M atomMap _ _ z0).mpr ⟨hel1, hel2⟩
  · exact (TemporalPred.eval_at_conj M atomMap _ _ z1).mpr ⟨her1, her2⟩
  · exact hbf

/-! ## Existential Closure (Lemma 3.2.3 + 3.4) -/

/-- Bounded existential over the right endpoint: if bf holds on (z0, z) with
    n witnesses and z ∈ (z0, z1) with ptZ at z and segAfterZ on (z, z1),
    then a bracket formula with n+1 witnesses holds on (z0, z1). -/
theorem BracketFormula.existsBounded_right
    {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula n) (z0 z1 z : M.carrier)
    (hz0z : z0 < z) (hzz1 : z < z1)
    (hbf : bf.holds M atomMap z0 z)
    (ptZ : TemporalPred) (hptZ : ptZ.eval_at M atomMap z)
    (segAfterZ : TemporalPred)
    (hseg : ∀ y, z < y → y < z1 → segAfterZ.eval_at M atomMap y) :
    ∃ m, ∃ bf' : BracketFormula m, bf'.holds M atomMap z0 z1 := by
  simp only [holds, toIntervalPattern, IntervalPattern.holds] at hbf ⊢
  match n, bf, hbf with
  | 0, bf, hbf =>
    -- 0 witnesses on (z0, z): create 1 witness z on (z0, z1)
    refine ⟨1, ⟨fun _ => ptZ,
      fun i => if i.val = 0 then bf.segmentTypes ⟨0, by omega⟩ else segAfterZ⟩,
      fun _ => z, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro ⟨i, hi⟩ ⟨j, hj⟩ hij; simp at hi hj; subst hi; subst hj; exact absurd hij (lt_irrefl _)
    · intro _; exact ⟨hz0z, hzz1⟩
    · intro _; exact hptZ
    · intro y hy0 hy1; exact hbf y hy0 hy1
    · intro i; exact Fin.elim0 i
    · intro y hlo hy1; exact hseg y hlo hy1
  | n + 1, bf, hbf =>
    -- n+1 witnesses on (z0, z): create n+2 witnesses on (z0, z1)
    -- by appending z as the last witness.
    -- The construction uses w_0, ..., w_n from bf, plus z as witness n+1.
    obtain ⟨w, hm, hi, hp, hs0, hsm, hsl⟩ := hbf
    have hw_lt_z : ∀ i : Fin (n + 1), w i < z := fun i => (hi i).2
    -- New witness function: first n+1 from w, last is z
    let w' : Fin (n + 2) → M.carrier := fun i =>
      if h : i.val ≤ n then w ⟨i.val, by omega⟩ else z
    -- Build the new bracket formula with n+2 witnesses
    -- Point types: bf.pointTypes for i ≤ n, ptZ for i = n+1
    -- Segment types: bf.segmentTypes for i ≤ n+1, segAfterZ for i = n+2
    refine ⟨n + 2, ⟨fun i => if h : i.val ≤ n then bf.pointTypes ⟨i.val, by omega⟩ else ptZ,
      fun i => if h : i.val ≤ n + 1 then bf.segmentTypes ⟨i.val, by omega⟩ else segAfterZ⟩,
      w', ?_, ?_, ?_, ?_, ?_, ?_⟩
    · -- Strict monotonicity of w'
      intro ⟨i, hi_lt⟩ ⟨j, hj_lt⟩ hij
      simp only [w']
      simp only [Fin.lt_iff_val_lt_val] at hij
      by_cases hin : i ≤ n
      · by_cases hjn : j ≤ n
        · simp [dif_pos hin, dif_pos hjn]
          exact hm ⟨i, by omega⟩ ⟨j, by omega⟩ (by simp [Fin.lt_iff_val_lt_val]; omega)
        · simp [dif_pos hin, dif_neg hjn]
          exact hw_lt_z ⟨i, by omega⟩
      · -- i > n, so i = n+1 and j > n+1, but j < n+2, contradiction
        omega
    · -- All witnesses in (z0, z1)
      intro ⟨i, hi_lt⟩
      simp only [w']
      by_cases hin : i ≤ n
      · simp [dif_pos hin]
        exact ⟨(hi ⟨i, by omega⟩).1, lt_trans (hi ⟨i, by omega⟩).2 hzz1⟩
      · simp [dif_neg hin]
        exact ⟨hz0z, hzz1⟩
    · -- Point types at witnesses
      intro ⟨i, hi_lt⟩
      simp only [w']
      by_cases hin : i ≤ n
      · simp [dif_pos hin]
        exact hp ⟨i, by omega⟩
      · simp [dif_neg hin]
        exact hptZ
    · -- Segment 0: (z0, w'(0))
      -- w'(0) = w(0) since 0 ≤ n
      intro y hy0 hy1
      simp only [w'] at hy1
      have : (0 : Nat) ≤ n := Nat.zero_le n
      simp [dif_pos this] at hy1
      have : (0 : Nat) ≤ n + 1 := Nat.zero_le (n + 1)
      simp [dif_pos this]
      exact hs0 y hy0 hy1
    · -- Middle segments: for i : Fin (n+1), segment (w'(i), w'(i+1))
      intro ⟨i, hi_lt⟩ y hlo hhi
      -- Cases: i ≤ n-1 (both endpoints from w) or i = n (w(n) to z)
      simp only [w'] at hlo hhi ⊢
      by_cases hin : i ≤ n
      · -- w'(i) = w(i)
        have hi_le : i ≤ n := hin
        simp [dif_pos hi_le] at hlo
        by_cases hin1 : i + 1 ≤ n
        · -- w'(i+1) = w(i+1), middle segment from original bf
          simp [dif_pos hin1] at hhi
          simp [dif_pos hin]
          have hi_fin : i < n := by omega
          exact hsm ⟨i, hi_fin⟩ y hlo hhi
        · -- i+1 > n, so i = n and w'(n+1) = z
          have : i = n := by omega
          subst this
          simp [show ¬(n + 1 ≤ n) from by omega] at hhi
          have : (n + 1 : Nat) ≤ n + 1 := le_refl (n + 1)
          simp [dif_pos this]
          exact hsl y hlo hhi
      · omega
    · -- Last segment: (w'(n+1), z1) = (z, z1)
      intro y hlo hy1
      simp only [w'] at hlo
      simp [show ¬(n + 1 ≤ n) from by omega] at hlo
      have : ¬((n + 1 + 1 : Nat) ≤ n + 1) := by omega
      simp [dif_neg this]
      exact hseg y hlo hy1

/-- Bounded existential over V-bracket formulas. -/
theorem VBracketFormula.existsBounded_right
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VBracketFormula) (z0 z1 z : M.carrier)
    (hz0z : z0 < z) (hzz1 : z < z1)
    (hv : v.holds M atomMap z0 z)
    (ptZ : TemporalPred) (hptZ : ptZ.eval_at M atomMap z)
    (segAfterZ : TemporalPred)
    (hseg : ∀ y, z < y → y < z1 → segAfterZ.eval_at M atomMap y) :
    ∃ v' : VBracketFormula, v'.holds M atomMap z0 z1 := by
  obtain ⟨⟨n, bf⟩, hmem, hbf⟩ := hv
  obtain ⟨m, bf', hbf'⟩ :=
    BracketFormula.existsBounded_right M atomMap bf z0 z1 z hz0z hzz1 hbf ptZ hptZ segAfterZ hseg
  exact ⟨⟨[⟨m, bf'⟩]⟩, ⟨m, bf'⟩, List.mem_singleton.mpr rfl, hbf'⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
