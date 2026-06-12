import Bimodal.Metalogic.WeakCanonical.Kamp.NegationClosureProp42
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAClosure
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEATranslation
import Bimodal.Metalogic.WeakCanonical.NormalForm

/-!
# Syntactic VBracketFormula Negation and Prop 4.3 Support

This file provides model-independent (syntactic) constructions needed for
Prop 4.3 (FO -> V-EA structural induction). The key components:

1. `neg_bracket_syn`: syntactic negation of BracketFormula -> VBracketFormula
2. `neg_vecEA2_syn`: syntactic negation of VecEA2 -> VVecEA2
3. `nf_exist_as_monadic`: bridge between NF existence and MonadicFormula evaluation

## References

- Rabinovich 2014, Lemma 5.1, Prop 4.2, Prop 4.3
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Section 1: Syntactic BracketFormula Negation

For a BracketFormula bf with n witnesses, we construct a VBracketFormula
whose holds is equivalent to ¬bf.holds over Prior structures.

Construction by induction on n:
- n = 0: ¬(∀ y, β(y)) ≡ ∃ y, ¬β(y)
- n+1: case A (α₀ absent) ∨ case B (β₀ fails before α₀) ∨ case C (tail fails) -/

/-- Syntactic negation of a BracketFormula. The resulting VBracketFormula
    holds iff ¬bf.holds over Prior structures (soundness + completeness). -/
noncomputable def neg_bracket_syn {n : Nat} (bf : BracketFormula n) : VBracketFormula :=
  match n with
  | 0 =>
    -- ¬(∀ y ∈ (z0,z1), β₀(y)) = ∃ y ∈ (z0,z1), ¬β₀(y)
    ⟨[⟨1, BracketFormula.purePoint (bf.segmentTypes ⟨0, by omega⟩).neg⟩]⟩
  | n + 1 =>
    let α₀ := bf.pointTypes ⟨0, by omega⟩
    let β₀ := bf.segmentTypes ⟨0, by omega⟩
    -- Case A: α₀ never occurs in (z0, z1) → pureSeg α₀.neg
    let caseA : List (Σ m, BracketFormula m) :=
      [⟨0, BracketFormula.pureSeg α₀.neg⟩]
    -- Case B: β₀ fails before any α₀ → 2 witnesses (y: ¬β₀, x: α₀)
    -- with seg(z0,y) = α₀.neg (no α₀ before y)
    let caseBbf : BracketFormula 2 :=
      { pointTypes := fun i => if i.val = 0 then β₀.neg else α₀
        segmentTypes := fun i => if i.val = 0 then α₀.neg else TemporalPred.top }
    let caseB : List (Σ m, BracketFormula m) := [⟨2, caseBbf⟩]
    -- Case C: α₀ + β₀ hold, but tail fails on (r₀, z1)
    -- Prepend each tail-negation disjunct with (β₀, α₀)
    let tailNeg := neg_bracket_syn bf.tail
    let caseC : List (Σ m, BracketFormula m) :=
      tailNeg.disjuncts.map fun ⟨m, bf_neg⟩ =>
        ⟨m + 1, bf_neg.prepend β₀ α₀⟩
    ⟨caseA ++ caseB ++ caseC⟩

/-- Direct holds proof for BracketFormula.prepend: if the tail holds and
    the witness/segment conditions are met, prepend holds. -/
theorem BracketFormula.prepend_holds_direct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {k : Nat} (bf : BracketFormula k) (segLeft ptType : TemporalPred)
    (z0 z1 r0 : M.carrier) (hr0_above : z0 < r0) (hr0_below : r0 < z1)
    (hPt : ptType.eval_at M atomMap r0)
    (hSeg : ∀ y : M.carrier, z0 < y → y < r0 → segLeft.eval_at M atomMap y)
    (h_tail : bf.holds M atomMap r0 z1) :
    (bf.prepend segLeft ptType).holds M atomMap z0 z1 := by
  -- Use bracket_prepend_holds which proves ∃ bf', bf'.holds
  -- The bf' constructed there is structurally the same as bf.prepend
  -- We need to show (bf.prepend segLeft ptType).holds directly
  -- Delegate to the existing infrastructure
  sorry

/-! ## Section 2: Correctness of Syntactic Negation -/

/-- Soundness: if any counter-pattern of neg_bracket_syn holds, then ¬bf.holds. -/
theorem neg_bracket_syn_sound {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_neg : (neg_bracket_syn bf).holds M atomMap z0 z1) :
    ¬bf.holds M atomMap z0 z1 := by
  sorry

/-- Completeness: over Prior, if ¬bf.holds, then some counter-pattern holds. -/
theorem neg_bracket_syn_complete {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap) :
    ∀ {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier), z0 < z1 →
    ¬bf.holds M atomMap z0 z1 →
    (neg_bracket_syn bf).holds M atomMap z0 z1 := by
  intro n
  induction n with
  | zero =>
    intro bf z0 z1 h_lt h_neg
    -- ¬(∀ y ∈ (z0,z1), β₀(y)) gives ∃ y, ¬β₀(y)
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
               IntervalPattern.holds] at h_neg
    push_neg at h_neg
    obtain ⟨y, hy0, hy1, h_neg_y⟩ := h_neg
    -- The counter-pattern purePoint(β₀.neg) holds with witness y
    simp only [neg_bracket_syn]
    exact ⟨⟨1, BracketFormula.purePoint (bf.segmentTypes ⟨0, by omega⟩).neg⟩,
           List.mem_singleton.mpr rfl,
           (BracketFormula.purePoint_holds M atomMap _ z0 z1).mpr
             ⟨y, hy0, hy1, (TemporalPred.eval_at_neg M atomMap _ y).mpr h_neg_y⟩⟩
  | succ n ih =>
    intro bf z0 z1 h_lt h_neg
    simp only [neg_bracket_syn]
    -- Three cases depending on whether α₀ occurs and β₀ holds
    by_cases h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
        (bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap x
    · -- α₀ occurs in (z0, z1)
      -- Use Prior-UZ to get first occurrence
      obtain ⟨r0, hr0_above, hr0_below, hPr0, h_neg_before⟩ :=
        first_occurrence_prior_strict M atomMap h_UZ
          (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
      by_cases h_seg : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y
      · -- Case C: α₀ + β₀ hold, but tail fails on (r0, z1)
        have h_tail_neg : ¬bf.tail.holds M atomMap r0 z1 := by
          intro h_tail
          exact h_neg (bracket_tail_satisfiable M atomMap bf z0 z1 r0
            hr0_above hr0_below hPr0 h_seg h_tail)
        -- By IH, tail negation counter-pattern holds
        obtain ⟨⟨m, bf_neg⟩, h_mem, h_holds⟩ := ih bf.tail r0 z1 hr0_below h_tail_neg
        -- Prepend r0 with α₀ and β₀ segment → case C counter-pattern
        obtain ⟨bf', h_bf'⟩ := BracketFormula.bracket_prepend_holds M atomMap bf_neg
          (bf.segmentTypes ⟨0, by omega⟩) (bf.pointTypes ⟨0, by omega⟩)
          z0 z1 r0 hr0_above hr0_below hPr0 h_seg h_holds
        -- bf' holds on (z0, z1), and it's the prepend of bf_neg
        -- We need to show bf'.holds is witnessed by some disjunct of caseC
        -- bf_neg.prepend β₀ α₀ is in caseC (it's the map of bf_neg from tailNeg)
        -- But bf' from bracket_prepend_holds may differ from bf_neg.prepend β₀ α₀
        sorry
      · -- Case B: β₀ fails before first α₀ occurrence
        push_neg at h_seg
        obtain ⟨y, hy0, hy1, h_neg_y⟩ := h_seg
        -- y is in (z0, r0), ¬β₀(y), and α₀.neg on (z0, y) (since r0 is first α₀)
        -- The 2-witness counter-pattern holds
        sorry
    · -- Case A: α₀ never occurs
      push_neg at h_exists
      -- pureSeg α₀.neg holds
      refine ⟨⟨0, BracketFormula.pureSeg (bf.pointTypes ⟨0, by omega⟩).neg⟩,
              List.mem_append_left _ (List.mem_append_left _ (List.mem_singleton.mpr rfl)),
              ?_⟩
      rw [BracketFormula.pureSeg_holds]
      intro y hy0 hy1
      exact (TemporalPred.eval_at_neg M atomMap _ y).mpr (h_exists y hy0 hy1)

/-- Uniform negation: neg_bracket_syn gives the correct negation over Prior. -/
theorem neg_bracket_syn_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (neg_bracket_syn bf).holds M atomMap z0 z1 ↔ ¬bf.holds M atomMap z0 z1 :=
  ⟨neg_bracket_syn_sound M atomMap bf z0 z1 h_lt,
   neg_bracket_syn_complete M atomMap h_UZ bf z0 z1 h_lt⟩

/-! ## Section 3: Uniform VecEA2 / VVecEA2 Negation -/

/-- Syntactic negation of a single VecEA2: ¬(L ∧ R ∧ bracket) via de Morgan. -/
noncomputable def neg_vecEA2_syn {n : Nat} (vea : VecEA2 n) : VVecEA2 :=
  let negL : VVecEA2 :=
    ⟨[⟨0, { endpointLeft := vea.endpointLeft.neg
            endpointRight := TemporalPred.top
            bracket := BracketFormula.pureSeg TemporalPred.top }⟩]⟩
  let negR : VVecEA2 :=
    ⟨[⟨0, { endpointLeft := TemporalPred.top
            endpointRight := vea.endpointRight.neg
            bracket := BracketFormula.pureSeg TemporalPred.top }⟩]⟩
  let negBkt : VVecEA2 :=
    (neg_bracket_syn vea.bracket).toVVecEA2WithEndpoints
      vea.endpointLeft vea.endpointRight
  negL.disj (negR.disj negBkt)

/-- Correctness of neg_vecEA2_syn over Prior. -/
theorem neg_vecEA2_syn_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    {n : Nat} (vea : VecEA2 n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (neg_vecEA2_syn vea).holds M atomMap z0 z1 ↔
    ¬vea.holds M atomMap z0 z1 := by
  sorry

/-- Syntactic conjunction-negation for VVecEA2 lists:
    Given a list of VecEA2 disjuncts, construct VVecEA2 for the conjunction
    of their negations.

    Uses: ∧ᵢ ¬dᵢ = ∧ᵢ (neg_vecEA2_syn dᵢ).holds

    This folds the conjunction using VVecEA2.conj semantically, but
    since each neg_vecEA2_syn dᵢ is fixed syntactically, the result
    is uniform. However, the semantic conjunction may produce model-dependent
    VVecEA2's. We handle this by iteratively conjoining syntactic VVecEA2's.

    For now, we provide this as an existential (classical choice). -/
noncomputable def neg_vvecEA2_syn_existential
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (v : VVecEA2) : VVecEA2 := by
  -- The syntactic conjunction of negated disjuncts is complex.
  -- We use classical choice: since for EACH model the semantic conjunction
  -- works, and the result is a FINITE disjunction over VVecEA2 patterns,
  -- we can classically choose a VVecEA2 that works for the "worst case."
  --
  -- Actually, we build the conjunction SYNTACTICALLY by distributing
  -- the disjunctions within each neg_vecEA2_syn over the conjunction.
  --
  -- For now, placeholder:
  exact ⟨[]⟩  -- Will be replaced with actual construction

/-! ## Section 4: Bridge Lemmas -/

/-- The truth of `∃ x, nf_eval_nf M k 2 (x,t) sub_nf` is equivalent to
    `eval M (fun _ => t) (.ex (nf_to_formula sub_nf))`. -/
theorem nf_exist_as_monadic
    {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig k 2) (t : M.carrier) :
    (∃ x : M.carrier, nf_eval_nf M k (1 + 1)
      (Fin.cons x (fun _ : Fin 1 => t)) sub_nf) ↔
    eval M (fun (_ : Fin 1) => t) (.ex (nf_to_formula sub_nf)) := by
  simp only [eval]
  exact ⟨fun ⟨x, hx⟩ => ⟨x, (nf_to_formula_correct M _ sub_nf).mpr hx⟩,
         fun ⟨x, hx⟩ => ⟨x, (nf_to_formula_correct M _ sub_nf).mp hx⟩⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
