import Bimodal.Metalogic.WeakCanonical.StaviConnectives
import Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness

/-!
# Prior Expressiveness: {U,S} Expressive Completeness over Prior Structures

Reynolds 1994, Theorem 5 (pp.123-124): {U,S} is expressively complete for
Prior structures, i.e., linear orders satisfying Prior-UZ and Prior-SZ.

## Key Results

- `stavi_U_false_on_prior_UZ`: U'(A,B) is always false on structures satisfying Prior-UZ
- `stavi_S_false_on_prior_SZ`: S'(A,B) is always false on structures satisfying Prior-SZ
- `flatten_stavi_correct_prior`: flatten_stavi is semantically correct on Prior structures
- `US_expressively_complete_over_prior`: every monadic FO formula has a {U,S}-equivalent
  on any structure satisfying Prior-UZ and Prior-SZ

## Mathematical Content

The Stavi connectives U'(A,B) detect "gap" behavior in linear orders. The Prior-UZ
axiom (F(ψ) → U(ψ, ¬ψ): every future occurrence of ψ has a first occurrence)
excludes such gaps. Combined with the Stavi expressive completeness theorem
(GHR93 Theorem 9.3.1: {U,S,U',S'} is expressively complete for all linear orders),
this yields {U,S} expressiveness for Prior structures.

The proof that U'(A,B) is always false on Prior structures:
1. Assume U'(A,B)(t) holds with witness s, body, fail, init conditions.
2. From "fail": ∃u' ∈ (t,s) with ¬B(u'), so F(¬B) at t.
3. Apply Prior-UZ with ψ = B.neg to get the first ¬B point s₀ after t,
   with ¬¬B (hence B, classically) on all of (t,s₀).
4. s₀ ∈ (t,s) since s₀ ≤ u' < s.
5. Evaluate the body at s₀:
   - Disjunct 1 (B cofinal above s₀): needs ∃v > s₀ with B on (t,v).
     Since s₀ ∈ (t,v), this requires B(s₀), contradicting ¬B(s₀).
   - Disjunct 2 (¬B before s₀): needs ∃v' ∈ (t,s₀) with ¬B(v').
     But B holds on (t,s₀), so no such v' exists.
6. Both disjuncts fail, contradicting the body condition. QED.

## References

- Reynolds 1994, Theorem 5, pp.123-124 (p.459-462 in transcription)
- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Theorem 9.3.1
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Semantic Prior-UZ/SZ Hypotheses

The semantic form of Prior-UZ: if ψ holds somewhere above t, then there is a
FIRST occurrence of ψ above t, with ψ.neg holding everywhere between t and
that first occurrence.

These are the hypotheses passed to `no_gaps_discrete` and used throughout
the Reynolds pipeline.
-/

/-- Semantic Prior-UZ: every future occurrence of ψ has a first occurrence. -/
abbrev semantic_prior_UZ {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) : Prop :=
  ∀ (t : M.carrier) (ψ : Formula),
    (∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ) →
    ∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ ∧
      ∀ r : M.carrier, t < r → r < s → temporal_truth M atomMap r ψ.neg

/-- Semantic Prior-SZ: every past occurrence of ψ has a last occurrence. -/
abbrev semantic_prior_SZ {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) : Prop :=
  ∀ (t : M.carrier) (ψ : Formula),
    (∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ) →
    ∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ ∧
      ∀ r : M.carrier, s < r → r < t → temporal_truth M atomMap r ψ.neg

/-! ## Double Negation Bridge

temporal_truth of ψ.neg.neg (= ¬¬ψ at the Formula level) is ¬¬(temporal_truth ψ).
We need to bridge this to temporal_truth ψ using classical logic.
-/

/-- temporal_truth of ψ.neg is ¬temporal_truth ψ. -/
private theorem temporal_truth_neg_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (t : M.carrier) (ψ : Formula) :
    temporal_truth M atomMap t ψ.neg ↔ ¬ temporal_truth M atomMap t ψ := by
  simp only [Formula.neg, temporal_truth]

/-- temporal_truth of ψ.neg.neg is ¬¬temporal_truth ψ, which is temporal_truth ψ classically. -/
private theorem temporal_truth_neg_neg_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (t : M.carrier) (ψ : Formula) :
    temporal_truth M atomMap t ψ.neg.neg ↔ temporal_truth M atomMap t ψ := by
  rw [temporal_truth_neg_iff, temporal_truth_neg_iff, Classical.not_not]

/-! ## Stavi U' False on Prior-UZ Structures

Reynolds 1994, Theorem 5 (U' case): In any structure satisfying semantic
Prior-UZ, U'(A,B) is always false.
-/

/--
**Reynolds Theorem 5 (U' case)**: U'(A,B) is always false on structures
satisfying semantic Prior-UZ.

The proof applies Prior-UZ with ψ = B.neg to find the first ¬B point s₀
after t, then derives a contradiction at s₀ from the U' body condition:
neither disjunct (B cofinal above s₀ / ¬B before s₀) can hold.
-/
theorem stavi_U_false_on_prior_UZ {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (t : M.carrier) (A B : Formula) :
    ¬ stavi_U_truth M atomMap t A B := by
  intro ⟨s, hts, h_body, h_fail, _h_init⟩
  -- From h_fail: ∃u' ∈ (t,s) with ¬B(u')
  obtain ⟨u', htu', hu's, hBu'⟩ := h_fail
  -- Apply Prior-UZ with ψ = B.neg to get first ¬B point s₀
  -- F(B.neg) at t: ∃s' > t with temporal_truth s' B.neg
  have h_F_negB : ∃ s' : M.carrier, t < s' ∧ temporal_truth M atomMap s' B.neg := by
    exact ⟨u', htu', (temporal_truth_neg_iff M atomMap u' B).mpr hBu'⟩
  obtain ⟨s₀, hts₀, h_negB_s₀, h_guard⟩ := h_prior_UZ t B.neg h_F_negB
  -- h_negB_s₀: temporal_truth s₀ B.neg, i.e., ¬B(s₀)
  have h_not_B_s₀ : ¬ temporal_truth M atomMap s₀ B :=
    (temporal_truth_neg_iff M atomMap s₀ B).mp h_negB_s₀
  -- h_guard: ∀r ∈ (t,s₀), temporal_truth r B.neg.neg, i.e., ¬¬B(r), i.e., B(r)
  have h_B_on_interval : ∀ r : M.carrier, t < r → r < s₀ →
      temporal_truth M atomMap r B := by
    intro r htr hrs₀
    exact (temporal_truth_neg_neg_iff M atomMap r B).mp (h_guard r htr hrs₀)
  -- s₀ < s: since s₀ is the first ¬B point and u' is a ¬B point in (t,s),
  -- s₀ ≤ u' < s. But s₀ might equal u'. In any case, s₀ ≤ u' because
  -- if s₀ > u', then u' ∈ (t,s₀), so B(u') by h_B_on_interval, contradiction.
  have h_s₀_le_u' : s₀ ≤ u' := by
    by_contra h
    push_neg at h
    -- u' ∈ (t, s₀), so B(u') by h_B_on_interval
    exact hBu' (h_B_on_interval u' htu' h)
  have h_s₀_lt_s : s₀ < s := lt_of_le_of_lt h_s₀_le_u' hu's
  -- Now evaluate the body at s₀ ∈ (t,s)
  have h_body_at_s₀ := h_body s₀ hts₀ h_s₀_lt_s
  -- Neither disjunct can hold:
  cases h_body_at_s₀ with
  | inl h_cofinal =>
    -- Disjunct 1: B cofinal above s₀, i.e., ∃v > s₀ with B on (t,v)
    obtain ⟨v, hs₀v, hBv⟩ := h_cofinal
    -- Since t < s₀ < v, s₀ ∈ (t,v), so B(s₀) by hBv. Contradicts ¬B(s₀).
    exact h_not_B_s₀ (hBv s₀ hts₀ hs₀v)
  | inr h_negB_before =>
    -- Disjunct 2: ¬B before s₀, i.e., ∃v' ∈ (t,s₀) with ¬B(v')
    obtain ⟨_, v', htv', hv's₀, hBv'⟩ := h_negB_before
    -- But B holds on (t,s₀) by h_B_on_interval. Contradiction.
    exact hBv' (h_B_on_interval v' htv' hv's₀)

/--
**Reynolds Theorem 5 (S' case)**: S'(A,B) is always false on structures
satisfying semantic Prior-SZ.

Mirror of `stavi_U_false_on_prior_UZ` in the past direction.
-/
theorem stavi_S_false_on_prior_SZ {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) (A B : Formula) :
    ¬ stavi_S_truth M atomMap t A B := by
  intro ⟨s, hst, h_body, h_fail, _h_init⟩
  -- From h_fail: ∃u' ∈ (s,t) with ¬B(u')
  obtain ⟨u', hsu', hu't, hBu'⟩ := h_fail
  -- Apply Prior-SZ with ψ = B.neg to get last ¬B point s₀
  have h_P_negB : ∃ s' : M.carrier, s' < t ∧ temporal_truth M atomMap s' B.neg := by
    exact ⟨u', hu't, (temporal_truth_neg_iff M atomMap u' B).mpr hBu'⟩
  obtain ⟨s₀, hs₀t, h_negB_s₀, h_guard⟩ := h_prior_SZ t B.neg h_P_negB
  have h_not_B_s₀ : ¬ temporal_truth M atomMap s₀ B :=
    (temporal_truth_neg_iff M atomMap s₀ B).mp h_negB_s₀
  have h_B_on_interval : ∀ r : M.carrier, s₀ < r → r < t →
      temporal_truth M atomMap r B := by
    intro r hs₀r hrt
    exact (temporal_truth_neg_neg_iff M atomMap r B).mp (h_guard r hs₀r hrt)
  -- s₀ ≥ u' (i.e., s < u' ≤ s₀): if s₀ < u', then u' ∈ (s₀, t), so B(u'), contradiction.
  have h_u'_le_s₀ : u' ≤ s₀ := by
    by_contra h
    push_neg at h
    exact hBu' (h_B_on_interval u' h hu't)
  have h_s_lt_s₀ : s < s₀ := lt_of_lt_of_le hsu' h_u'_le_s₀
  -- Evaluate the body at s₀ ∈ (s,t)
  have h_body_at_s₀ := h_body s₀ h_s_lt_s₀ hs₀t
  cases h_body_at_s₀ with
  | inl h_cofinal =>
    -- Disjunct 1: B cofinal below s₀, i.e., ∃v < s₀ with B on (v,t)
    obtain ⟨v, hvs₀, hBv⟩ := h_cofinal
    -- Since v < s₀ < t, s₀ ∈ (v,t), so B(s₀). Contradicts ¬B(s₀).
    exact h_not_B_s₀ (hBv s₀ hvs₀ hs₀t)
  | inr h_negB_after =>
    -- Disjunct 2: ¬B after s₀, i.e., ∃v' ∈ (s₀,t) with ¬B(v')
    obtain ⟨_, v', hs₀v', hv't, hBv'⟩ := h_negB_after
    -- But B holds on (s₀,t) by h_B_on_interval. Contradiction.
    exact hBv' (h_B_on_interval v' hs₀v' hv't)

/-! ## Stavi Extended Truth False on Prior Structures

The stavi_temporal_truth version (operating on StaviFormula instead of
just Formula arguments to stavi_U_truth/stavi_S_truth).
-/

/-! ## flatten_stavi_correct_prior: Correctness Without IsSuccArchimedean

Reynolds Theorem 5 (full): In any Prior structure (satisfying Prior-UZ and Prior-SZ),
flatten_stavi is semantically correct. This extends flatten_stavi_correct from
discrete-with-IsSuccArchimedean to general Prior structures.
-/

/--
**Reynolds Theorem 5 (full form)**: In any linear order satisfying semantic
Prior-UZ and Prior-SZ, `flatten_stavi` preserves truth:
`stavi_temporal_truth M atomMap t sf ↔ temporal_truth M atomMap t (flatten_stavi sf)`.

This means {U,S} is expressively complete for Prior structures: any StaviFormula
(and hence any monadic FO formula) has a {U,S}-equivalent.

Unlike `flatten_stavi_correct` which requires `IsSuccArchimedean`/`IsPredArchimedean`,
this version uses the semantic Prior-UZ/SZ hypotheses instead. The proof is by
structural induction on sf. The U'/S' cases use Prior-UZ/SZ to derive contradiction
(both sides are false). All other cases are identical to `flatten_stavi_correct`.

Reference: Reynolds 1994, Theorem 5, pp.123-124.
-/
theorem flatten_stavi_correct_prior {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier) (sf : StaviFormula) :
    stavi_temporal_truth M atomMap t sf ↔
    temporal_truth M atomMap t (flatten_stavi sf) := by
  induction sf generalizing t with
  | base φ =>
    simp [stavi_temporal_truth, flatten_stavi]
  | neg φ ih =>
    simp only [stavi_temporal_truth, flatten_stavi]
    rw [temporal_truth_neg]
    exact not_congr (ih t)
  | conj φ ψ ihφ ihψ =>
    simp only [stavi_temporal_truth, flatten_stavi]
    rw [temporal_truth_and]
    exact and_congr (ihφ t) (ihψ t)
  | stavi_untl A B ihA ihB =>
    -- flatten_stavi (.stavi_untl A B) = .bot
    -- Need: stavi_temporal_truth U'(A,B) ↔ temporal_truth .bot ↔ False
    simp only [flatten_stavi, temporal_truth]
    constructor
    · -- Forward: U'(A,B) → False
      -- Use the same argument as stavi_U_false_on_prior_UZ, but with
      -- stavi_temporal_truth instead of temporal_truth.
      intro ⟨s, hts, h_body, h_fail, _h_init⟩
      -- From h_fail: ∃u' ∈ (t,s) with ¬stavi_temporal_truth u' B
      obtain ⟨u', htu', hu's, hBu'⟩ := h_fail
      -- Convert to temporal_truth via ihB: ¬temporal_truth u' (flatten_stavi B)
      have h_not_B_flat : ¬ temporal_truth M atomMap u' (flatten_stavi B) :=
        fun h => hBu' ((ihB u').mpr h)
      -- Apply Prior-UZ with ψ = (flatten_stavi B).neg
      have h_F_negB : ∃ s' : M.carrier, t < s' ∧
          temporal_truth M atomMap s' (flatten_stavi B).neg := by
        exact ⟨u', htu', (temporal_truth_neg_iff M atomMap u' _).mpr h_not_B_flat⟩
      obtain ⟨s₀, hts₀, h_negB_s₀, h_guard⟩ :=
        h_prior_UZ t (flatten_stavi B).neg h_F_negB
      -- s₀ is the first point where ¬(flatten_stavi B) holds, with
      -- ¬¬(flatten_stavi B) (= flatten_stavi B classically) on (t,s₀)
      have h_not_B_s₀ : ¬ stavi_temporal_truth M atomMap s₀ B := by
        intro hB
        have := (ihB s₀).mp hB
        exact ((temporal_truth_neg_iff M atomMap s₀ _).mp h_negB_s₀) this
      have h_B_on_interval : ∀ r : M.carrier, t < r → r < s₀ →
          stavi_temporal_truth M atomMap r B := by
        intro r htr hrs₀
        have h_nn := h_guard r htr hrs₀
        have h_flat := (temporal_truth_neg_neg_iff M atomMap r _).mp h_nn
        exact (ihB r).mpr h_flat
      -- s₀ ≤ u' (otherwise u' ∈ (t,s₀) gives B(u'), contradiction)
      have h_s₀_le_u' : s₀ ≤ u' := by
        by_contra h
        push_neg at h
        exact hBu' ((ihB u').mpr ((temporal_truth_neg_neg_iff M atomMap u' _).mp
          (h_guard u' htu' h)))
      have h_s₀_lt_s : s₀ < s := lt_of_le_of_lt h_s₀_le_u' hu's
      -- Evaluate body at s₀
      have h_body_at_s₀ := h_body s₀ hts₀ h_s₀_lt_s
      cases h_body_at_s₀ with
      | inl h_cofinal =>
        obtain ⟨v, hs₀v, hBv⟩ := h_cofinal
        exact h_not_B_s₀ (hBv s₀ hts₀ hs₀v)
      | inr h_negB_before =>
        obtain ⟨_, v', htv', hv's₀, hBv'⟩ := h_negB_before
        exact hBv' (h_B_on_interval v' htv' hv's₀)
    · -- Backward: False → stavi_temporal_truth (vacuous)
      exact False.elim
  | stavi_snce A B ihA ihB =>
    -- flatten_stavi (.stavi_snce A B) = .bot (S' always false on Prior-SZ)
    simp only [flatten_stavi, temporal_truth]
    constructor
    · -- Forward: S'(A,B) → False (dual of U' case using Prior-SZ)
      intro ⟨s, hst, h_body, h_fail, _h_init⟩
      obtain ⟨u', hsu', hu't, hBu'⟩ := h_fail
      have h_not_B_flat : ¬ temporal_truth M atomMap u' (flatten_stavi B) :=
        fun h => hBu' ((ihB u').mpr h)
      have h_P_negB : ∃ s' : M.carrier, s' < t ∧
          temporal_truth M atomMap s' (flatten_stavi B).neg := by
        exact ⟨u', hu't, (temporal_truth_neg_iff M atomMap u' _).mpr h_not_B_flat⟩
      obtain ⟨s₀, hs₀t, h_negB_s₀, h_guard⟩ :=
        h_prior_SZ t (flatten_stavi B).neg h_P_negB
      have h_not_B_s₀ : ¬ stavi_temporal_truth M atomMap s₀ B := by
        intro hB
        exact ((temporal_truth_neg_iff M atomMap s₀ _).mp h_negB_s₀) ((ihB s₀).mp hB)
      have h_B_on_interval : ∀ r : M.carrier, s₀ < r → r < t →
          stavi_temporal_truth M atomMap r B := by
        intro r hs₀r hrt
        exact (ihB r).mpr ((temporal_truth_neg_neg_iff M atomMap r _).mp
          (h_guard r hs₀r hrt))
      have h_u'_le_s₀ : u' ≤ s₀ := by
        by_contra h
        push_neg at h
        exact hBu' ((ihB u').mpr ((temporal_truth_neg_neg_iff M atomMap u' _).mp
          (h_guard u' h hu't)))
      have h_s_lt_s₀ : s < s₀ := lt_of_lt_of_le hsu' h_u'_le_s₀
      have h_body_at_s₀ := h_body s₀ h_s_lt_s₀ hs₀t
      cases h_body_at_s₀ with
      | inl h_cofinal =>
        obtain ⟨v, hvs₀, hBv⟩ := h_cofinal
        exact h_not_B_s₀ (hBv s₀ hvs₀ hs₀t)
      | inr h_negB_after =>
        obtain ⟨_, v', hs₀v', hv't, hBv'⟩ := h_negB_after
        exact hBv' (h_B_on_interval v' hs₀v' hv't)
    · exact False.elim
  | std_untl A B ihA ihB =>
    simp only [stavi_temporal_truth, flatten_stavi, temporal_truth]
    constructor
    · intro ⟨s, hts, hAs, hBu⟩
      exact ⟨s, hts, (ihA s).mp hAs, fun u htu hus => (ihB u).mp (hBu u htu hus)⟩
    · intro ⟨s, hts, hAs, hBu⟩
      exact ⟨s, hts, (ihA s).mpr hAs, fun u htu hus => (ihB u).mpr (hBu u htu hus)⟩
  | std_snce A B ihA ihB =>
    simp only [stavi_temporal_truth, flatten_stavi, temporal_truth]
    constructor
    · intro ⟨s, hst, hAs, hBu⟩
      exact ⟨s, hst, (ihA s).mp hAs, fun u hsu hut => (ihB u).mp (hBu u hsu hut)⟩
    · intro ⟨s, hst, hAs, hBu⟩
      exact ⟨s, hst, (ihA s).mpr hAs, fun u hsu hut => (ihB u).mpr (hBu u hsu hut)⟩

/-! ## {U,S} Expressive Completeness over Prior Structures

Compose `stavi_expressive_completeness` (GHR93 Theorem 9.3.1: every monadic FO
formula has a StaviFormula equivalent) with `flatten_stavi_correct_prior`
(every StaviFormula has a {U,S}-equivalent on Prior structures) to get:
every monadic FO formula has a {U,S}-equivalent on Prior structures.
-/

/--
**Reynolds Theorem 5 (composition)**: {U,S} is expressively complete over
Prior structures. Given any monadic FO formula ψ with one free variable,
there exists a temporal formula A (using only U and S) such that A is
semantically equivalent to ψ on any structure satisfying Prior-UZ and Prior-SZ.

The proof composes:
1. `stavi_expressive_completeness` (GHR93 9.3.1): ψ ↔ stavi_temporal_truth sf
2. `flatten_stavi_correct_prior` (Theorem 5): stavi_temporal_truth sf ↔ temporal_truth (flatten_stavi sf)

Reference: Reynolds 1994, Theorem 5, pp.123-124.
-/
noncomputable def US_expressively_complete_over_prior
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_prior_UZ : semantic_prior_UZ M atomMap)
        (_h_prior_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) psi ↔
        temporal_truth M atomMap t A } := by
  -- Step 1: Get StaviFormula equivalent from GHR93 Theorem 9.3.1
  obtain ⟨sf, h_sf⟩ := stavi_expressive_completeness sig atomMap h_surj psi
  -- Step 2: Flatten to standard temporal formula
  exact ⟨flatten_stavi sf, fun M h_UZ h_SZ t => by
    constructor
    · intro h_psi
      exact (flatten_stavi_correct_prior M atomMap h_UZ h_SZ t sf).mp
        ((h_sf M t).mpr h_psi)
    · intro h_flat
      exact (h_sf M t).mp
        ((flatten_stavi_correct_prior M atomMap h_UZ h_SZ t sf).mpr h_flat)⟩

end Bimodal.Metalogic.WeakCanonical
