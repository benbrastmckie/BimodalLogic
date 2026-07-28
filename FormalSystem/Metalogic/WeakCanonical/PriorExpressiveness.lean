/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.StaviConnectives
import FormalSystem.Metalogic.WeakCanonical.EFGames.StaviCompleteness
import FormalSystem.Metalogic.WeakCanonical.PriorDefs
import FormalSystem.Metalogic.WeakCanonical.Kamp.KampPrior

/-!
# Prior Expressiveness: {U,S} Expressive Completeness over Prior Structures

{U,S} is expressively complete for Prior structures, i.e., linear orders
satisfying Prior-UZ and Prior-SZ.

## Key Results

- `stavi_U_false_on_prior_UZ`: U'(A,B) is always false on structures satisfying Prior-UZ
- `stavi_S_false_on_prior_SZ`: S'(A,B) is always false on structures satisfying Prior-SZ
- `flatten_stavi_correct_prior`: flattenStavi is semantically correct on Prior structures
- `uSExpressivelyCompleteOverPrior`: every monadic FO formula has a {U,S}-equivalent
  on any structure satisfying Prior-UZ and Prior-SZ

## Proof Method

`uSExpressivelyCompleteOverPrior` uses `kampPriorExpressiveCompleteness`
(Kamp/Rabinovich 2014 relativized to Prior structures), which bypasses the
sorry-tainted `stavi_expressive_completeness` chain entirely.

The Stavi connective falsity results (`stavi_U_false_on_prior_UZ` etc.) and
`flatten_stavi_correct_prior` remain proved and documented, but are no longer
on the critical path for `uSExpressivelyCompleteOverPrior`.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem"
- Reynolds 1994, Theorem 5, p.123
- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Theorem 9.3.1
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax

/-! ## Semantic Prior-UZ/SZ Hypotheses

The definitions `SemanticPriorUZ` and `SemanticPriorSZ` are in
`PriorDefs.lean` (to break the import cycle with `KampPrior.lean`).
Re-exported here via the import for backward compatibility.
-/

/-! ## Double Negation Bridge

TemporalTruth of ψ.neg.neg (= ¬¬ψ at the Formula level) is ¬¬(TemporalTruth ψ).
We need to bridge this to TemporalTruth ψ using classical logic.
-/

/-- TemporalTruth of ψ.neg is ¬TemporalTruth ψ. -/
private theorem temporal_truth_neg_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (t : M.carrier) (ψ : Formula) :
    TemporalTruth M atomMap t ψ.neg ↔ ¬ TemporalTruth M atomMap t ψ := by
  simp only [Formula.neg, TemporalTruth]

/-- TemporalTruth of ψ.neg.neg is ¬¬TemporalTruth ψ, which is TemporalTruth ψ classically. -/
private theorem temporal_truth_neg_neg_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (t : M.carrier) (ψ : Formula) :
    TemporalTruth M atomMap t ψ.neg.neg ↔ TemporalTruth M atomMap t ψ := by
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
theorem stavi_U_false_on_prior_UZ {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : SemanticPriorUZ M atomMap)
    (t : M.carrier) (A B : Formula) :
    ¬ StaviUTruth M atomMap t A B := by
  intro ⟨s, hts, h_body, h_fail, _h_init⟩
  -- From h_fail: ∃u' ∈ (t,s) with ¬B(u')
  obtain ⟨u', htu', hu's, hBu'⟩ := h_fail
  -- Apply Prior-UZ with ψ = B.neg to get first ¬B point s₀
  -- F(B.neg) at t: ∃s' > t with TemporalTruth s' B.neg
  have h_F_negB : ∃ s' : M.carrier, t < s' ∧ TemporalTruth M atomMap s' B.neg := by
    exact ⟨u', htu', (temporal_truth_neg_iff M atomMap u' B).mpr hBu'⟩
  obtain ⟨s₀, hts₀, h_negB_s₀, h_guard⟩ := h_prior_UZ t B.neg h_F_negB
  -- h_negB_s₀: TemporalTruth s₀ B.neg, i.e., ¬B(s₀)
  have h_not_B_s₀ : ¬ TemporalTruth M atomMap s₀ B :=
    (temporal_truth_neg_iff M atomMap s₀ B).mp h_negB_s₀
  -- h_guard: ∀r ∈ (t,s₀), TemporalTruth r B.neg.neg, i.e., ¬¬B(r), i.e., B(r)
  have h_B_on_interval : ∀ r : M.carrier, t < r → r < s₀ →
      TemporalTruth M atomMap r B := by
    intro r htr hrs₀
    exact (temporal_truth_neg_neg_iff M atomMap r B).mp (h_guard r htr hrs₀)
  -- s₀ < s: since s₀ is the first ¬B point and u' is a ¬B point in (t,s),
  -- s₀ ≤ u' < s. But s₀ might equal u'. In any case, s₀ ≤ u' because
  -- if s₀ > u', then u' ∈ (t,s₀), so B(u') by h_B_on_interval, contradiction.
  have h_s₀_le_u' : s₀ ≤ u' := by
    by_contra h
    push Not at h
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
theorem stavi_S_false_on_prior_SZ {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_prior_SZ : SemanticPriorSZ M atomMap)
    (t : M.carrier) (A B : Formula) :
    ¬ StaviSTruth M atomMap t A B := by
  intro ⟨s, hst, h_body, h_fail, _h_init⟩
  -- From h_fail: ∃u' ∈ (s,t) with ¬B(u')
  obtain ⟨u', hsu', hu't, hBu'⟩ := h_fail
  -- Apply Prior-SZ with ψ = B.neg to get last ¬B point s₀
  have h_P_negB : ∃ s' : M.carrier, s' < t ∧ TemporalTruth M atomMap s' B.neg := by
    exact ⟨u', hu't, (temporal_truth_neg_iff M atomMap u' B).mpr hBu'⟩
  obtain ⟨s₀, hs₀t, h_negB_s₀, h_guard⟩ := h_prior_SZ t B.neg h_P_negB
  have h_not_B_s₀ : ¬ TemporalTruth M atomMap s₀ B :=
    (temporal_truth_neg_iff M atomMap s₀ B).mp h_negB_s₀
  have h_B_on_interval : ∀ r : M.carrier, s₀ < r → r < t →
      TemporalTruth M atomMap r B := by
    intro r hs₀r hrt
    exact (temporal_truth_neg_neg_iff M atomMap r B).mp (h_guard r hs₀r hrt)
  -- s₀ ≥ u' (i.e., s < u' ≤ s₀): if s₀ < u', then u' ∈ (s₀, t), so B(u'), contradiction.
  have h_u'_le_s₀ : u' ≤ s₀ := by
    by_contra h
    push Not at h
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

The StaviTemporalTruth version (operating on StaviFormula instead of
just Formula arguments to StaviUTruth/StaviSTruth).
-/

/-! ## flatten_stavi_correct_prior: Correctness Without IsSuccArchimedean

Reynolds Theorem 5 (full): In any Prior structure (satisfying Prior-UZ and Prior-SZ),
flattenStavi is semantically correct. This extends flatten_stavi_correct from
discrete-with-IsSuccArchimedean to general Prior structures.
-/

/--
**Reynolds Theorem 5 (full form)**: In any linear order satisfying semantic
Prior-UZ and Prior-SZ, `flattenStavi` preserves truth:
`StaviTemporalTruth M atomMap t sf ↔ TemporalTruth M atomMap t (flattenStavi sf)`.

This means {U,S} is expressively complete for Prior structures: any StaviFormula
(and hence any monadic FO formula) has a {U,S}-equivalent.

Unlike `flatten_stavi_correct` which requires `IsSuccArchimedean`/`IsPredArchimedean`,
this version uses the semantic Prior-UZ/SZ hypotheses instead. The proof is by
structural induction on sf. The U'/S' cases use Prior-UZ/SZ to derive contradiction
(both sides are false). All other cases are identical to `flatten_stavi_correct`.

Reference: Reynolds 1994, Theorem 5, p.123.
-/
theorem flatten_stavi_correct_prior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : SemanticPriorUZ M atomMap)
    (h_prior_SZ : SemanticPriorSZ M atomMap)
    (t : M.carrier) (sf : StaviFormula) :
    StaviTemporalTruth M atomMap t sf ↔
    TemporalTruth M atomMap t (flattenStavi sf) := by
  induction sf generalizing t with
  | base φ =>
    simp [StaviTemporalTruth, flattenStavi]
  | neg φ ih =>
    simp only [StaviTemporalTruth, flattenStavi]
    rw [temporal_truth_neg]
    exact not_congr (ih t)
  | conj φ ψ ihφ ihψ =>
    simp only [StaviTemporalTruth, flattenStavi]
    rw [temporal_truth_and]
    exact and_congr (ihφ t) (ihψ t)
  | stavi_untl A B ihA ihB =>
    -- flattenStavi (.stavi_untl A B) = .bot
    -- Need: StaviTemporalTruth U'(A,B) ↔ TemporalTruth .bot ↔ False
    simp only [flattenStavi, TemporalTruth]
    constructor
    · -- Forward: U'(A,B) → False
      -- Use the same argument as stavi_U_false_on_prior_UZ, but with
      -- StaviTemporalTruth instead of TemporalTruth.
      intro ⟨s, hts, h_body, h_fail, _h_init⟩
      -- From h_fail: ∃u' ∈ (t,s) with ¬StaviTemporalTruth u' B
      obtain ⟨u', htu', hu's, hBu'⟩ := h_fail
      -- Convert to TemporalTruth via ihB: ¬TemporalTruth u' (flattenStavi B)
      have h_not_B_flat : ¬ TemporalTruth M atomMap u' (flattenStavi B) :=
        fun h => hBu' ((ihB u').mpr h)
      -- Apply Prior-UZ with ψ = (flattenStavi B).neg
      have h_F_negB : ∃ s' : M.carrier, t < s' ∧
          TemporalTruth M atomMap s' (flattenStavi B).neg := by
        exact ⟨u', htu', (temporal_truth_neg_iff M atomMap u' _).mpr h_not_B_flat⟩
      obtain ⟨s₀, hts₀, h_negB_s₀, h_guard⟩ :=
        h_prior_UZ t (flattenStavi B).neg h_F_negB
      -- s₀ is the first point where ¬(flattenStavi B) holds, with
      -- ¬¬(flattenStavi B) (= flattenStavi B classically) on (t,s₀)
      have h_not_B_s₀ : ¬ StaviTemporalTruth M atomMap s₀ B := by
        intro hB
        have := (ihB s₀).mp hB
        exact ((temporal_truth_neg_iff M atomMap s₀ _).mp h_negB_s₀) this
      have h_B_on_interval : ∀ r : M.carrier, t < r → r < s₀ →
          StaviTemporalTruth M atomMap r B := by
        intro r htr hrs₀
        have h_nn := h_guard r htr hrs₀
        have h_flat := (temporal_truth_neg_neg_iff M atomMap r _).mp h_nn
        exact (ihB r).mpr h_flat
      -- s₀ ≤ u' (otherwise u' ∈ (t,s₀) gives B(u'), contradiction)
      have h_s₀_le_u' : s₀ ≤ u' := by
        by_contra h
        push Not at h
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
    · -- Backward: False → StaviTemporalTruth (vacuous)
      exact False.elim
  | stavi_snce A B ihA ihB =>
    -- flattenStavi (.stavi_snce A B) = .bot (S' always false on Prior-SZ)
    simp only [flattenStavi, TemporalTruth]
    constructor
    · -- Forward: S'(A,B) → False (dual of U' case using Prior-SZ)
      intro ⟨s, hst, h_body, h_fail, _h_init⟩
      obtain ⟨u', hsu', hu't, hBu'⟩ := h_fail
      have h_not_B_flat : ¬ TemporalTruth M atomMap u' (flattenStavi B) :=
        fun h => hBu' ((ihB u').mpr h)
      have h_P_negB : ∃ s' : M.carrier, s' < t ∧
          TemporalTruth M atomMap s' (flattenStavi B).neg := by
        exact ⟨u', hu't, (temporal_truth_neg_iff M atomMap u' _).mpr h_not_B_flat⟩
      obtain ⟨s₀, hs₀t, h_negB_s₀, h_guard⟩ :=
        h_prior_SZ t (flattenStavi B).neg h_P_negB
      have h_not_B_s₀ : ¬ StaviTemporalTruth M atomMap s₀ B := by
        intro hB
        exact ((temporal_truth_neg_iff M atomMap s₀ _).mp h_negB_s₀) ((ihB s₀).mp hB)
      have h_B_on_interval : ∀ r : M.carrier, s₀ < r → r < t →
          StaviTemporalTruth M atomMap r B := by
        intro r hs₀r hrt
        exact (ihB r).mpr ((temporal_truth_neg_neg_iff M atomMap r _).mp
          (h_guard r hs₀r hrt))
      have h_u'_le_s₀ : u' ≤ s₀ := by
        by_contra h
        push Not at h
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
    simp only [StaviTemporalTruth, flattenStavi, TemporalTruth]
    constructor
    · intro ⟨s, hts, hAs, hBu⟩
      exact ⟨s, hts, (ihA s).mp hAs, fun u htu hus => (ihB u).mp (hBu u htu hus)⟩
    · intro ⟨s, hts, hAs, hBu⟩
      exact ⟨s, hts, (ihA s).mpr hAs, fun u htu hus => (ihB u).mpr (hBu u htu hus)⟩
  | std_snce A B ihA ihB =>
    simp only [StaviTemporalTruth, flattenStavi, TemporalTruth]
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
**{U,S} Expressive Completeness over Prior Structures**:
Given any monadic FO formula ψ with one free variable, there exists a
temporal formula A (using only U and S) such that A is semantically
equivalent to ψ on any structure satisfying Prior-UZ and Prior-SZ.

The proof uses Kamp/Rabinovich 2014's composition-based method,
relativized from Dedekind completeness to `SemanticPriorUZ/SZ`.
This bypasses the Stavi sorry chain (GHR93 Theorem 9.3.1) entirely:
the sole consumer of `stavi_expressive_completeness` was this theorem,
and it now uses `kampPriorExpressiveCompleteness` instead.

References:
- Rabinovich 2014, "A Proof of Kamp's Theorem", Sections 3-5
- Reynolds 1994, Theorem 5, p.123
-/
noncomputable def uSExpressivelyCompleteOverPrior
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_prior_UZ : SemanticPriorUZ M atomMap)
        (_h_prior_SZ : SemanticPriorSZ M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) psi ↔
        TemporalTruth M atomMap t A } :=
  -- Direct application of Kamp/Rabinovich 2014 (relativized to Prior structures)
  Kamp.kampPriorExpressiveCompleteness atomMap h_surj psi

end FormalSystem.Metalogic.WeakCanonical
