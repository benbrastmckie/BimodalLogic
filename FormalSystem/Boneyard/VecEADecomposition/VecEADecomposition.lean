import FormalSystem.Metalogic.WeakCanonical.Kamp.NegationClosureProp42
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAClosure
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEATranslation
import FormalSystem.Metalogic.WeakCanonical.NormalForm

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Syntactic VBracketFormula Negation and Prop 4.3 Support

**QUARANTINED**: This file is dead code -- not imported by any
file on the critical path to `completeness_discrete`. The two remaining sorries
(`neg_bracket_syn_iff` soundness Case C, `neg_vecEA2_syn_iff`) are bypassed by
the NF-specific Prop 4.3 approach (KampPrior.lean + NfCharFormula.lean +
NegationClosure.lean master_induction). Do NOT attempt to prove them.

The Case C blocker is a genuine mathematical impossibility under open-interval
semantics: the prepended counter-pattern can hold simultaneously with bf.holds
because the tail negation lives on a different interval than bf.tail.

This file provides model-independent (syntactic) constructions needed for
Prop 4.3 (FO -> V-EA structural induction). The key components:

1. `neg_bracket_syn`: syntactic negation of BracketFormula -> VBracketFormula
2. `neg_bracket_syn_complete`: completeness over Prior (¬bf.holds → counter-pattern holds)
3. `nf_exist_as_monadic`: bridge between NF existence and MonadicFormula evaluation

## Status

**QUARANTINED**: Completeness is proved. Soundness of Case C
(prepended tail-negation disjuncts) is BLOCKED -- genuine impossibility under
open-interval semantics. Not on critical path; bypassed by plan v23.

## References

- Rabinovich 2014, Lemma 5.1, Prop 4.2, Prop 4.3
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Section 1: Syntactic BracketFormula Negation

For a BracketFormula bf with n witnesses, we construct a VBracketFormula
whose holds is equivalent to ¬bf.holds over Prior structures.

Construction by induction on n:
- n = 0: ¬(∀ y, β(y)) ≡ ∃ y, ¬β(y)
- n+1: case A (α₀ absent) ∨ case B (β₀ fails before α₀) ∨ case C (tail fails)

Case B uses a 1-witness BracketFormula with pointType = α₀.neg ∧ β₀.neg.
The conjunction ensures soundness: the witness y has both ¬α₀(y) AND ¬β₀(y),
so any bf-witness w(0) with α₀(w(0)) differs from y, forcing w(0) > y
(from the segment condition on (z0, y)), placing y in (z0, w(0)) where
β₀ must hold, contradicting ¬β₀(y). -/

/-- Syntactic negation of a BracketFormula. The resulting VBracketFormula
    is COMPLETE over Prior: ¬bf.holds → neg_bracket_syn.holds.
    Soundness (the reverse direction) is blocked for Case C; see
    `neg_bracket_syn_iff` documentation. -/
noncomputable def neg_bracket_syn {n : Nat} (bf : BracketFormula n) : VBracketFormula :=
  match n with
  | 0 =>
    ⟨[⟨1, BracketFormula.purePoint (bf.segmentTypes ⟨0, by omega⟩).neg⟩]⟩
  | n + 1 =>
    let α₀ := bf.pointTypes ⟨0, by omega⟩
    let β₀ := bf.segmentTypes ⟨0, by omega⟩
    let caseA : List (Σ m, BracketFormula m) :=
      [⟨0, BracketFormula.pureSeg α₀.neg⟩]
    let caseBbf : BracketFormula 1 :=
      { pointTypes := fun _ => α₀.neg.conj β₀.neg
        segmentTypes := fun i => if i.val = 0 then α₀.neg else TemporalPred.top }
    let caseB : List (Σ m, BracketFormula m) := [⟨1, caseBbf⟩]
    let tailNeg := neg_bracket_syn bf.tail
    let caseC : List (Σ m, BracketFormula m) :=
      tailNeg.disjuncts.map fun ⟨m, bf_neg⟩ =>
        ⟨m + 1, bf_neg.prepend β₀ α₀⟩
    ⟨caseA ++ caseB ++ caseC⟩

/-- Direct holds proof for BracketFormula.prepend. -/
theorem BracketFormula.prepend_holds_direct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {k : Nat} (bf : BracketFormula k) (segLeft ptType : TemporalPred)
    (z0 z1 r0 : M.carrier) (hr0_above : z0 < r0) (hr0_below : r0 < z1)
    (hPt : ptType.eval_at M atomMap r0)
    (hSeg : ∀ y : M.carrier, z0 < y → y < r0 → segLeft.eval_at M atomMap y)
    (h_tail : bf.holds M atomMap r0 z1) :
    (bf.prepend segLeft ptType).holds M atomMap z0 z1 := by
  show (BracketFormula.prepend segLeft ptType bf).toIntervalPattern.holds M atomMap z0 z1
  simp only [BracketFormula.prepend, BracketFormula.toIntervalPattern]
  simp only [IntervalPattern.holds]
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds] at h_tail
  match k with
  | 0 =>
    refine ⟨fun _ => r0, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro i j hij; exact absurd hij (by omega)
    · intro _; exact ⟨hr0_above, hr0_below⟩
    · intro ⟨i, hi⟩
      have : i = 0 := by omega
      subst this; simp only [dite_true]; exact hPt
    · intro y hy0 hy1; simp only [dite_true]; exact hSeg y hy0 hy1
    · intro ⟨i, hi⟩; exact absurd hi (by omega)
    · intro y hy0 hy1
      simp only [show (0 : Nat) + 1 ≠ 0 from by omega, dite_false,
                  show (0 : Nat) + 1 - 1 = 0 from by omega]
      exact h_tail y hy0 hy1
  | k' + 1 =>
    obtain ⟨w, hm, hbnd, hpt, hseg0, hseg_mid, hseg_last⟩ := h_tail
    refine ⟨fun ⟨i, _⟩ => if i = 0 then r0 else w ⟨i - 1, by omega⟩, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro ⟨i, hi⟩ ⟨j, hj⟩ hij
      simp only [Fin.lt_def] at hij
      by_cases hi0 : i = 0
      · subst hi0; simp only [ite_true, if_neg (show j ≠ 0 from by omega)]
        exact lt_of_lt_of_le (hbnd ⟨0, by omega⟩).1
          (by rcases Nat.eq_or_lt_of_le (show 1 ≤ j from by omega) with h | h
              · subst h; simp
              · exact le_of_lt (hm ⟨0, by omega⟩ ⟨j - 1, by omega⟩
                  (by simp [Fin.lt_def]; omega)))
      · simp only [if_neg hi0, if_neg (show j ≠ 0 from by omega)]
        exact hm ⟨i - 1, by omega⟩ ⟨j - 1, by omega⟩ (by simp [Fin.lt_def]; omega)
    · intro ⟨i, hi⟩
      by_cases hi0 : i = 0
      · subst hi0; simp [ite_true]; exact ⟨hr0_above, hr0_below⟩
      · simp only [if_neg hi0]
        refine ⟨lt_trans hr0_above (lt_of_lt_of_le (hbnd ⟨0, by omega⟩).1 ?_),
               (hbnd ⟨i - 1, by omega⟩).2⟩
        rcases Nat.eq_or_lt_of_le (show 1 ≤ i from by omega) with h | h
        · subst h; simp
        · exact le_of_lt (hm ⟨0, by omega⟩ ⟨i - 1, by omega⟩
            (by simp [Fin.lt_def]; omega))
    · intro ⟨i, hi⟩
      by_cases hi0 : i = 0
      · subst hi0; simp [ite_true, hPt]
      · simp only [dif_neg hi0, if_neg hi0]; exact hpt ⟨i - 1, by omega⟩
    · intro y hy0 hy1; simp; exact hSeg y hy0 hy1
    · intro ⟨i, hi⟩ y hy_lo hy_hi
      simp only [show i + 1 ≠ 0 from by omega, dite_false]
      by_cases hi0 : i = 0
      · subst hi0
        simp only [ite_true] at hy_lo
        simp only [show (1 : Nat) ≠ 0 from by omega, ite_false] at hy_hi
        exact hseg0 y hy_lo hy_hi
      · simp only [if_neg hi0] at hy_lo
        simp only [if_neg (show i + 1 ≠ 0 from by omega)] at hy_hi
        simp only [show i + 1 - 1 = i from by omega]
        have hlo' : w ⟨(⟨i - 1, by omega⟩ : Fin k').val, by omega⟩ < y := hy_lo
        have hhi' : y < w ⟨(⟨i - 1, by omega⟩ : Fin k').val + 1, by omega⟩ := by
          convert hy_hi using 2; ext; simp; omega
        have := hseg_mid ⟨i - 1, by omega⟩ y hlo' hhi'
        simp at this; convert this using 2; ext; simp; omega
    · intro y hy0 hy1
      simp only [show k' + 1 + 1 ≠ 0 from by omega, ite_false,
                  show k' + 1 + 1 - 1 = k' + 1 from by omega]
      simp only [show k' + 1 ≠ 0 from by omega, ite_false] at hy0
      exact hseg_last y hy0 hy1

/-! ## Section 2: Completeness of Syntactic Negation -/

/-- Completeness: over Prior, if ¬bf.holds, then some counter-pattern of
    neg_bracket_syn holds. -/
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
    simp only [BracketFormula.holds, BracketFormula.toIntervalPattern,
               IntervalPattern.holds] at h_neg
    push_neg at h_neg
    obtain ⟨y, hy0, hy1, h_neg_y⟩ := h_neg
    simp only [neg_bracket_syn]
    exact ⟨⟨1, BracketFormula.purePoint (bf.segmentTypes ⟨0, by omega⟩).neg⟩,
           List.mem_singleton.mpr rfl,
           (BracketFormula.purePoint_holds M atomMap _ z0 z1).mpr
             ⟨y, hy0, hy1, (TemporalPred.eval_at_neg M atomMap _ y).mpr h_neg_y⟩⟩
  | succ n ih =>
    intro bf z0 z1 h_lt h_neg
    simp only [neg_bracket_syn]
    by_cases h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
        (bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap x
    · obtain ⟨r0, hr0_above, hr0_below, hPr0, h_neg_before⟩ :=
        first_occurrence_prior_strict M atomMap h_UZ
          (bf.pointTypes ⟨0, by omega⟩) z0 z1 h_lt h_exists
      by_cases h_seg : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y
      · -- Case C: tail fails
        have h_tail_neg : ¬bf.tail.holds M atomMap r0 z1 := by
          intro h_tail
          exact h_neg (bracket_tail_satisfiable M atomMap bf z0 z1 r0
            hr0_above hr0_below hPr0 h_seg h_tail)
        obtain ⟨⟨m, bf_neg⟩, h_mem, h_holds⟩ := ih bf.tail r0 z1 hr0_below h_tail_neg
        have h_prepend := BracketFormula.prepend_holds_direct M atomMap bf_neg
          (bf.segmentTypes ⟨0, by omega⟩) (bf.pointTypes ⟨0, by omega⟩)
          z0 z1 r0 hr0_above hr0_below hPr0 h_seg h_holds
        -- Show the prepended formula is in the disjuncts
        refine ⟨⟨m + 1, BracketFormula.prepend (bf.segmentTypes ⟨0, by omega⟩)
            (bf.pointTypes ⟨0, by omega⟩) bf_neg⟩, ?_, h_prepend⟩
        simp only [neg_bracket_syn, List.mem_append, List.mem_map, List.mem_singleton,
                   List.mem_cons]
        right
        exact ⟨⟨m, bf_neg⟩, h_mem, rfl⟩
      · -- Case B: β₀ fails before first α₀
        push_neg at h_seg
        obtain ⟨y, hy0, hy1, h_neg_y⟩ := h_seg
        have h_neg_alpha_y : ¬(bf.pointTypes ⟨0, by omega⟩).eval_at M atomMap y :=
          h_neg_before y hy0 hy1
        let caseBbf' : BracketFormula 1 :=
          { pointTypes := fun _ =>
              (bf.pointTypes ⟨0, by omega⟩).neg.conj (bf.segmentTypes ⟨0, by omega⟩).neg
            segmentTypes := fun i =>
              if i.val = 0 then (bf.pointTypes ⟨0, by omega⟩).neg else TemporalPred.top }
        refine ⟨⟨1, caseBbf'⟩,
          List.mem_append_left _ (List.mem_append_right _ (List.mem_singleton.mpr rfl)), ?_⟩
        simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
        refine ⟨fun _ => y, ?_, ?_, ?_, ?_, ?_, ?_⟩
        · intro i j hij; exact absurd hij (by omega)
        · intro _; exact ⟨hy0, lt_trans hy1 hr0_below⟩
        · intro ⟨i, hi⟩
          have hi0 : i = 0 := by omega
          subst hi0
          show (caseBbf'.pointTypes ⟨0, by omega⟩).eval_at M atomMap y
          simp only [caseBbf']
          exact (TemporalPred.eval_at_conj M atomMap _ _ y).mpr
            ⟨(TemporalPred.eval_at_neg M atomMap _ y).mpr h_neg_alpha_y,
             (TemporalPred.eval_at_neg M atomMap _ y).mpr h_neg_y⟩
        · intro y' hy'0 hy'1
          show (caseBbf'.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y'
          simp only [caseBbf', show (0 : Nat) = 0 from rfl, ite_true]
          exact (TemporalPred.eval_at_neg M atomMap _ y').mpr
            (h_neg_before y' hy'0 (lt_trans hy'1 hy1))
        · intro ⟨i, hi⟩; exact absurd hi (by omega)
        · intro y' _ _
          show (caseBbf'.segmentTypes ⟨1, by omega⟩).eval_at M atomMap y'
          simp only [caseBbf', show (1 : Nat) ≠ 0 from by omega, ite_false]
          exact TemporalPred.eval_at_top M atomMap y'
    · push_neg at h_exists
      refine ⟨⟨0, BracketFormula.pureSeg (bf.pointTypes ⟨0, by omega⟩).neg⟩,
              List.mem_append_left _ (List.mem_append_left _ (List.mem_singleton.mpr rfl)),
              ?_⟩
      rw [BracketFormula.pureSeg_holds]
      intro y hy0 hy1
      exact (TemporalPred.eval_at_neg M atomMap _ y).mpr (h_exists y hy0 hy1)

/-! ## Section 3: neg_bracket_syn_iff (BLOCKED)

**BLOCKER** (Phase 5a):
- **What failed**: Soundness of neg_bracket_syn, specifically Case C (prepended
  tail-negation disjuncts). The construction produces `bf_tail_neg.prepend β₀ α₀`
  which can hold on (z0, z1) simultaneously with bf.holds, because the tail-negation
  sub-pattern lives on interval (r, z1) where r is the prepend's first witness,
  which may differ from bf's first witness w(0). The IH gives ¬bf.tail on (r, z1),
  but bf.holds only gives bf.tail on (w(0), z1).
- **What was tried**: (1) Two-witness caseB with [β₀.neg, α₀] -- soundness fails
  when witnesses coincide at endpoint. (2) One-witness caseB with α₀.neg ∧ β₀.neg --
  soundness works for cases A and B. (3) Adding α₀.neg to Case C segment -- doesn't
  fix the interval mismatch. (4) Over Prior, first-occurrence argument -- fails because
  bf.tail.holds on (w(0), z1) doesn't imply bf.tail.holds on (r, z1) when r < w(0)
  (wider first segment may violate tail's segmentTypes(0)).
- **Why it's stuck**: BracketFormula.holds uses open intervals, so bracket constraints
  cannot force two witnesses (one from bf, one from neg) to coincide. The tail
  negation operates on a potentially different interval than bf's tail.
- **What is needed**: Either (a) a proof that bf.tail.holds on (w(0), z1) implies
  bf.tail.holds on (r, z1) for any r ≤ w(0) with appropriate segment conditions
  (FALSE in general -- wider interval is harder), or (b) a fundamentally different
  construction for Case C soundness, or (c) a compactness/finiteness argument to
  lift the semantic neg_2var_vec_ea to a uniform version, or (d) rewrite Prop 4.3
  to use the semantic negation directly with a model-dependent VVecEA2.
- **Prohibited workarounds**: Do NOT use sorry, def X := True, or any vacuous placeholder.

The completeness direction and the bridge lemma `nf_exist_as_monadic` are sorry-free. -/

/-- BLOCKED: Correctness biconditional for neg_bracket_syn over Prior.
    Completeness (← direction) is proved. Soundness (→ direction) is blocked
    for Case C. See BLOCKER documentation above. -/
theorem neg_bracket_syn_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (neg_bracket_syn bf).holds M atomMap z0 z1 ↔ ¬bf.holds M atomMap z0 z1 := by
  constructor
  · sorry  -- Soundness: BLOCKED for Case C, see documentation
  · exact neg_bracket_syn_complete M atomMap h_UZ bf z0 z1 h_lt

/-! ## Section 4: VecEA2 / VVecEA2 Negation -/

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

/-- BLOCKED: Correctness of neg_vecEA2_syn over Prior.
    Depends on neg_bracket_syn_iff which is blocked for soundness. -/
theorem neg_vecEA2_syn_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    {n : Nat} (vea : VecEA2 n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (neg_vecEA2_syn vea).holds M atomMap z0 z1 ↔
    ¬vea.holds M atomMap z0 z1 := by
  sorry

/-! ## Section 5: Bridge Lemmas -/

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

end FormalSystem.Metalogic.WeakCanonical.Kamp
