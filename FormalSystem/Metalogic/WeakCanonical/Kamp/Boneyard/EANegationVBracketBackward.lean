import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAFormula
import FormalSystem.Metalogic.WeakCanonical.Kamp.PriorINF
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAClosure

/-! ARCHIVED (Boneyard) — never compiled. Retired backward-direction negation-closure
material from EANegation.lean: the backward direction is unprovable at the
`BracketFormula` level (see the preserved impossibility note inside
`neg_bracket_is_vbracket` below). Superseded by the sorry-free `VVecEA2.negFix_iff`
(`EANegationFix/VecEANegFix.lean`) and the model-dependent closure lemmas in
`EANegationClosure.lean`. Rabinovich provenance labels ("Lemma 5.1 (Rabinovich 2014,
pp.7-11)", "Corollary 5.4") are preserved verbatim. Do not import from live code.

Moved verbatim from EANegation.lean: the warm-up trio
`neg_orderedPointsExist_zero_false`, `neg_orderedPointsExist_one`,
`neg_orderedPointsExist_one_is_bracket`; the support closure
`BracketFormula.partialBracketExist`, `neg_partialBracketExist_sufficient`,
`neg_bracket_zero_is_vbracket`; and the two sorried backward-direction theorems
`neg_bracket_is_vbracket` and `neg_partialBracketExist_is_vbracket`. -/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

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

/-- The partial bracket existential: there exists z in (z_0, z_1) such that
    the bracket formula holds on (z_0, z). -/
def BracketFormula.partialBracketExist {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula n) (z0 z1 : M.carrier) : Prop :=
  ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z

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

              (Confirmed by report 18, Section 4: "The B.1 Backward Gap: A
              Fundamental Interval Mismatch".)

              NOTE: The B.2 case has been FIXED. `neg_b2_bracket_formula_disjoint`
              (in EANegationClosure.lean) proves the B.2 backward direction
              sorry-free. Only this B.1 case remains unprovable.

              **Context**: We have alpha_0(r0), beta_0(r0), beta_0 on (z0, r0),
              and ¬rightPart.holds(r0, z1). We need to exhibit a CaseD disjunct
              (from `result`) that holds on (z0, z1).

              **Why it fails**: CaseD disjuncts have point type alpha_0.conj beta_0.neg
              at their first witness, but beta_0(r0) holds here, so CaseD cannot fire
              at r0. No other disjunct in `result` handles this case:
              - CaseA requires ¬alpha_0 everywhere, but alpha_0(r0) ∈ (z0,z1).
              - CaseC requires ¬beta_0 before any alpha_0 point, but beta_0 on (z0,r0).
              - CaseD requires ¬beta_0(r0), but beta_0(r0) holds.

              **Structural reason (existential vs universal mismatch)**: V-bracket
              formulas are existentially quantified -- they assert the existence of
              witness points. The backward direction requires universal quantification
              over ALL possible bracket witness arrangements, which vary per model.
              Specifically: the IH gives ¬rightPart on one specific sub-interval
              (r0, z1), but the bracket witness w_0 could be > r0, giving a different
              sub-interval (w_0, z1). The monotonicity property needed -- "if the
              negation V-bracket holds on (r0, z1), it holds on (w_0, z1) for all
              w_0 >= r0" -- is FALSE in general (report 18, Section 4.3).

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
    · /- IMPOSSIBILITY: The backward direction of the Corollary 5.4
        biconditional is UNPROVABLE at the BracketFormula level.

        (Confirmed by report 18, Section 10: "Corollary 5.4 Model-Independent
        Biconditional: Provability Analysis". Section 10.3 concludes: "The
        Corollary 5.4 biconditional at BracketFormula level is also unprovable
        with the interior-witness convention.")

        **What is needed**: ¬partialBracketExist → V.holds, i.e., when no
        bracket witness exists in (z0, z1), the F-chain ordered-points
        predicate also fails (so v_suff holds by the Lemma 5.3 biconditional).

        Contrapositively: orderedPointsExist 1 fChainPred z0 z1 →
        partialBracketExist. This needs fChainPred(x0) → ∃ z, bf.holds z0 z.

        **Structural reason (same existential vs universal mismatch as B.1)**:
        The bounded existential's witness determines the sub-interval for the
        recursive bracket, and different witnesses give different intervals.
        Specifically: fChainPred(x0) asserts alpha_0(x0) AND (beta_1 U
        (alpha_1 AND ...)). The Until witnesses give points s > x0 where the
        chain continues, but there is no a priori bound s < z1. On structures
        where the Until witness lies outside (z0, z1), the reduction fails.
        The F-chain Until-unboundedness is a special case of the existential
        vs universal quantification mismatch identified in B.1: the F-chain
        reduction absorbs segment types into Until operators, losing
        interval-boundedness information that varies per model.

        **Resolution**: The forward direction (V.holds → ¬partialBracketExist)
        is proved sorry-free via neg_partialBracketExist_sufficient. The
        model-DEPENDENT version (neg_bounded_exists in EANegationClosure.lean)
        proves both directions sorry-free and is sufficient for completeness.
        This sorry does NOT block the completeness proof. -/
      sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
