/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.EFGames.TypeFormulas
import FormalSystem.Metalogic.WeakCanonical.EFGames.StaviCompleteness

/-!
# Characteristic Formulas: X_t and Interval Type Formula A

Independent construction of the characteristic formula X_t (GHR93 Definition 8.8)
and the interval type formula A = X_{(t,u)} without using `nf_characterizable_by_stavi`
from StaviCompleteness.lean. This avoids putting the bridge lemma sorry onto the
`completeness_discrete` critical path.

## Mathematical Background

GHR93 Definition 8.8: For each position t in M_r, define X_t as a StaviFormula
of depth ≤ r such that X_t(u) holds iff u has the same rank-r type as t. This
exists because there are finitely many distinct rank-r types (by NormalForm
finiteness), so a finite conjunction of separating formulas of depth ≤ r
distinguishes each type from all others.

The interval type formula A = X_{(t,u)} is the disjunction of X_v for all
mu-points v in the open interval (t, u). A(w) holds iff w has the same rank-r
type as some mu-point in (t, u).

## Construction Strategy

We use `Classical.choose` on the existence of characteristic formulas. The
existence proof relies on:
1. `RankType` being determined by StaviFormulas of depth ≤ r
2. For distinct rank_types, a separating formula of depth ≤ r exists (by definition)
3. Finite conjunction of depth-≤r formulas has depth ≤ r (max of conjuncts)

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Definition 8.8
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax

/-! ## Boolean Formula Combinators

Public versions of disjunction/conjunction list combinators for StaviFormulas.
These are needed because StaviCompleteness.lean's versions are `private`. -/

/-- Disjunction of two StaviFormulas: A ∨ B = ¬(¬A ∧ ¬B). -/
def sfDisj (A B : StaviFormula) : StaviFormula :=
  .neg (.conj (.neg A) (.neg B))

/-- Disjunction of a list of StaviFormulas.
    Empty list maps to ⊥ (= base bot). -/
def sfDisjList : List StaviFormula → StaviFormula
  | [] => .base .bot
  | [a] => a
  | a :: as => sfDisj a (sfDisjList as)

/-- Conjunction of a list of StaviFormulas.
    Empty list maps to ¬⊥ (= ⊤). -/
def sfConjList : List StaviFormula → StaviFormula
  | [] => .neg (.base .bot)
  | [a] => a
  | a :: as => .conj a (sfConjList as)

/-- staviDepth of sfDisj is max of operands. -/
theorem stavi_depth_sf_disj (A B : StaviFormula) :
    staviDepth (sfDisj A B) = max (staviDepth A) (staviDepth B) := by
  simp [sfDisj, staviDepth]

/-- staviDepth of sfConjList is bounded by the max depth in the list. -/
theorem stavi_depth_sf_conjList (l : List StaviFormula) (r : Nat)
    (h : ∀ A ∈ l, staviDepth A ≤ r) :
    staviDepth (sfConjList l) ≤ r := by
  match l with
  | [] =>
    simp [sfConjList, staviDepth, operatorDepth]
  | [a] =>
    simp only [sfConjList]
    exact h a (by simp)
  | a :: b :: rest =>
    simp only [sfConjList, staviDepth]
    apply Nat.max_le.mpr
    exact ⟨h a (by simp),
           stavi_depth_sf_conjList (b :: rest) r
             (fun A hA => h A (List.mem_cons_of_mem a hA))⟩

/-- staviDepth of sfDisjList is bounded by the max depth in the list. -/
theorem stavi_depth_sf_disjList (l : List StaviFormula) (r : Nat)
    (h : ∀ A ∈ l, staviDepth A ≤ r) :
    staviDepth (sfDisjList l) ≤ r := by
  match l with
  | [] =>
    simp [sfDisjList, staviDepth, operatorDepth]
  | [a] =>
    simp only [sfDisjList]
    exact h a (by simp)
  | a :: b :: rest =>
    simp only [sfDisjList, stavi_depth_sf_disj]
    apply Nat.max_le.mpr
    exact ⟨h a (by simp),
           stavi_depth_sf_disjList (b :: rest) r
             (fun A hA => h A (List.mem_cons_of_mem a hA))⟩

/-! ## Mu-Relativized Truth Semantics for Combinators -/

/-- sfDisj has standard disjunction semantics under mu-relativized truth. -/
theorem sf_disj_truth_mu {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} (A B : StaviFormula) :
    StaviTemporalTruthMu M atomMap r t (sfDisj A B) ↔
    (StaviTemporalTruthMu M atomMap r t A ∨
     StaviTemporalTruthMu M atomMap r t B) := by
  simp [sfDisj, StaviTemporalTruthMu]
  tauto

/-- sfConjList has conjunction semantics under mu-relativized truth. -/
theorem sf_conjList_truth_mu {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} (l : List StaviFormula) :
    StaviTemporalTruthMu M atomMap r t (sfConjList l) ↔
    ∀ A ∈ l, StaviTemporalTruthMu M atomMap r t A := by
  match l with
  | [] =>
    simp [sfConjList, StaviTemporalTruthMu, TemporalTruthMu]
  | [a] =>
    simp only [sfConjList]
    constructor
    · intro ha A hA; simp only [List.mem_cons, List.not_mem_nil, or_false] at hA; rw [hA]; exact ha
    · intro h; exact h a (by simp)
  | a :: b :: rest =>
    simp only [sfConjList, StaviTemporalTruthMu]
    rw [sf_conjList_truth_mu (b :: rest)]
    constructor
    · intro ⟨ha, hrest⟩ A hA
      simp only [List.mem_cons] at hA
      rcases hA with rfl | hA
      · exact ha
      · exact hrest A (List.mem_cons.mpr hA)
    · intro h
      exact ⟨h a (by simp), fun A hA => h A (List.mem_cons_of_mem a hA)⟩

/-- sfDisjList has disjunction semantics under mu-relativized truth. -/
theorem sf_disjList_truth_mu {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} (l : List StaviFormula) :
    StaviTemporalTruthMu M atomMap r t (sfDisjList l) ↔
    ∃ A ∈ l, StaviTemporalTruthMu M atomMap r t A := by
  match l with
  | [] =>
    simp [sfDisjList, StaviTemporalTruthMu, TemporalTruthMu]
  | [a] =>
    simp only [sfDisjList]
    constructor
    · intro ha; exact ⟨a, by simp, ha⟩
    · intro ⟨A, hA, hAt⟩
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hA; subst hA; exact hAt
  | a :: b :: rest =>
    simp only [sfDisjList]
    rw [sf_disj_truth_mu, sf_disjList_truth_mu (b :: rest)]
    constructor
    · intro h; rcases h with ha | ⟨A, hA, hAt⟩
      · exact ⟨a, by simp, ha⟩
      · exact ⟨A, List.mem_cons_of_mem a hA, hAt⟩
    · intro ⟨A, hA, hAt⟩
      simp only [List.mem_cons] at hA; rcases hA with rfl | hA
      · exact Or.inl hAt
      · exact Or.inr ⟨A, List.mem_cons.mpr hA, hAt⟩

/-! ## Rank Type Separation

For two positions with different rank_types, a separating formula of depth ≤ r
exists. This is immediate from the definition of RankType. -/

/-- For two positions with different rank_types, there exists a StaviFormula
    of depth ≤ r that holds at one but not the other. -/
theorem rank_type_separator {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t u : ExtendedCarrier M atomMap r}
    (h : RankType M atomMap r t ≠ RankType M atomMap r u) :
    ∃ A : StaviFormula, staviDepth A ≤ r ∧
      StaviTemporalTruthMu M atomMap r t A ∧
      ¬ StaviTemporalTruthMu M atomMap r u A := by
  -- rank_types differ → ∃ A in one but not the other
  rw [Ne, Set.ext_iff] at h; push Not at h
  obtain ⟨A, hA⟩ := h
  simp only [RankType, Set.mem_setOf_eq] at hA
  -- hA : (depth A ≤ r ∧ A^mu(t)) ∧ ¬(depth A ≤ r ∧ A^mu(u)) ∨
  --       ¬(depth A ≤ r ∧ A^mu(t)) ∧ (depth A ≤ r ∧ A^mu(u))
  rcases hA with ⟨⟨hd, ht⟩, hu⟩ | ⟨hnt, ⟨hd, hu⟩⟩
  · -- A ∈ RankType(t) but A ∉ RankType(u)
    push Not at hu
    exact ⟨A, hd, ht, hu hd⟩
  · -- A ∉ RankType(t) but A ∈ RankType(u)
    push Not at hnt
    -- (.neg A) holds at t (since ¬A^mu(t)) and fails at u (since A^mu(u))
    exact ⟨.neg A, by rw [stavi_depth_neg]; exact hd, hnt hd, fun h => h hu⟩

/-! ## NF Profile Determines Rank Type

Two positions with the same NormalForm characteristic on the mu-extended
structure at depth 2*r have the same RankType. This is the key finiteness
step: since NormalForm (muSig sig) (2*r) 1 is Fintype, there are at most
finitely many distinct rank_types. -/

/-- The NF profile of a position: its NormalForm characteristic on
    the mu-extended structure at depth 2*r. -/
noncomputable abbrev nfProfile {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (t : ExtendedCarrier M atomMap r) :
    NormalForm (muSig sig) (2 * r) 1 :=
  nfCharacteristic (extendedStructureWithMu M atomMap r) (2 * r) 1 (fun _ => t)

/-- Same NF profile implies same mu-relativized truth for all depth-≤r
    StaviFormulas. Proof chain:
    1. same nfCharacteristic → same NfEvalNf on all NFs
    2. → same eval on all depth-≤2*r MonadicFormula (muSig sig) 1
    3. → in particular on staviTableMu A (depth ≤ 2*r when staviDepth A ≤ r)
    4. → same StaviTemporalTruthMu (by stavi_table_mu_correct) -/
theorem nf_profile_determines_stavi_truth {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    (h_same : nfProfile t = nfProfile u)
    (A : StaviFormula) (hA : staviDepth A ≤ r) :
    StaviTemporalTruthMu M atomMap r t A ↔
    StaviTemporalTruthMu M atomMap r u A := by
  -- Step 1: NF agreement on all depth-(2*r) NFs
  have h_t_nf := nf_characteristic_satisfies
    (extendedStructureWithMu M atomMap r) (2 * r) 1 (fun _ => t)
  have h_u_nf := nf_characteristic_satisfies
    (extendedStructureWithMu M atomMap r) (2 * r) 1 (fun _ => u)
  have h_u_nf_as_t : NfEvalNf (extendedStructureWithMu M atomMap r) (2 * r) 1
      (fun _ => u) (nfProfile t) := h_same ▸ h_u_nf
  have h_nf_agree := nf_agreement_from_shared_nf
    (extendedStructureWithMu M atomMap r) (fun _ => t)
    (extendedStructureWithMu M atomMap r) (fun _ => u)
    (nfProfile t) h_t_nf h_u_nf_as_t
  -- Step 2: FO depth bound for the mu-translation of A
  have hA_fo : (staviTableMu atomMap A).quantifierDepth ≤ 2 * r :=
    le_trans (stavi_table_mu_depth A)
      (le_trans (stavi_fo_depth_le_twice_depth A) (Nat.mul_le_mul_left 2 hA))
  -- Step 3: Agreement on staviTableMu A via doets_lemma_1_1
  have h_eval_agree := doets_lemma_1_1 (2 * r) 1 (staviTableMu atomMap A) hA_fo
    (extendedStructureWithMu M atomMap r) (extendedStructureWithMu M atomMap r)
    (fun _ => t) (fun _ => u) h_nf_agree
  -- Step 4: Bridge from eval to StaviTemporalTruthMu
  exact (stavi_table_mu_correct t A).symm.trans
    (h_eval_agree.trans (stavi_table_mu_correct u A))

/-- Same NF profile implies same RankType. -/
theorem nf_profile_determines_rank_type {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    (h_same : nfProfile t = nfProfile u) :
    RankType M atomMap r t = RankType M atomMap r u := by
  ext A
  simp only [RankType, Set.mem_setOf_eq]
  constructor
  · intro ⟨hd, hA⟩
    exact ⟨hd, (nf_profile_determines_stavi_truth h_same A hd).mp hA⟩
  · intro ⟨hd, hA⟩
    exact ⟨hd, (nf_profile_determines_stavi_truth h_same A hd).mpr hA⟩

/-- Contrapositive: different rank_types imply different NF profiles. -/
theorem rank_type_ne_of_nf_profile_ne {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    (h : RankType M atomMap r t ≠ RankType M atomMap r u) :
    nfProfile t ≠ nfProfile u :=
  fun h_eq => h (nf_profile_determines_rank_type h_eq)

/-! ## Characteristic Formula X_t (GHR93 Definition 8.8)

For each position t in M_r, X_t is a StaviFormula of depth ≤ r such that
X_t(u) holds iff u has the same rank-r type as t. -/

/-- There exists a StaviFormula of depth ≤ r characterizing the rank-r type at t.

    Proof strategy: enumerate all NF profiles in the Fintype
    NormalForm (muSig sig) (2*r) 1. For each profile, if there exists a position
    with that profile and different RankType from t, use rank_type_separator
    to get a depth-≤r formula holding at t but not at that position. The
    conjunction over all profiles characterizes RankType(t).

    The finiteness of NF profiles (Fintype on NormalForm) is the key ingredient:
    same NF profile implies same RankType (nf_profile_determines_rank_type),
    so the number of distinct rank_types is bounded by |NormalForm (muSig sig) (2*r) 1|. -/
theorem x_t_formula_exists {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (r : Nat) (t : ExtendedCarrier M atomMap r) :
    ∃ A : StaviFormula, staviDepth A ≤ r ∧
      ∀ (u : ExtendedCarrier M atomMap r),
        StaviTemporalTruthMu M atomMap r u A ↔
        RankType M atomMap r u = RankType M atomMap r t := by
  -- For each NF profile v, build a separator if there exists a position with that
  -- profile and different RankType. Otherwise use trivially-true ¬⊥.
  -- We prove this as a chain of existence claims.
  --
  -- Step 1: For each v : NormalForm (muSig sig) (2*r) 1, produce a depth-≤r formula
  -- that holds at t, and if nfProfile(u) = v with RankType(u) ≠ RankType(t),
  -- fails at u.
  have sep_exists : ∀ v : NormalForm (muSig sig) (2 * r) 1,
      ∃ A : StaviFormula, staviDepth A ≤ r ∧
        StaviTemporalTruthMu M atomMap r t A ∧
        ∀ u : ExtendedCarrier M atomMap r,
          nfProfile u = v → RankType M atomMap r u ≠ RankType M atomMap r t →
          ¬ StaviTemporalTruthMu M atomMap r u A := by
    intro v
    by_cases h_ex : ∃ w : ExtendedCarrier M atomMap r,
        nfProfile w = v ∧ RankType M atomMap r w ≠ RankType M atomMap r t
    · -- There is a position with this profile and different RankType: use separator
      obtain ⟨w, hw_prof, hw_ne⟩ := h_ex
      obtain ⟨A, hd, ht, hnw⟩ := rank_type_separator hw_ne.symm
      -- A holds at t and fails at w. Any u with same NF profile as w has same
      -- RankType as w (by nf_profile_determines_rank_type), so A fails at u too.
      exact ⟨A, hd, ht, fun u hu_prof _ => by
        have h_same : RankType M atomMap r u = RankType M atomMap r w :=
          nf_profile_determines_rank_type (hu_prof.trans hw_prof.symm)
        intro h_holds
        exact hnw ((rank_type_eq_iff h_same _ hd).mp h_holds)⟩
    · -- No such position: .neg (.base .bot) is trivially true
      push Not at h_ex
      exact ⟨.neg (.base .bot), by simp [staviDepth, operatorDepth],
        by simp [StaviTemporalTruthMu, TemporalTruthMu],
        fun u hu hu_ne => absurd (h_ex u hu) hu_ne⟩
  -- Step 2: Choose separators for all NF profiles and take the conjunction
  let sep : NormalForm (muSig sig) (2 * r) 1 → StaviFormula :=
    fun v => Classical.choose (sep_exists v)
  have sep_spec : ∀ v, staviDepth (sep v) ≤ r ∧
      StaviTemporalTruthMu M atomMap r t (sep v) ∧
      ∀ u, nfProfile u = v → RankType M atomMap r u ≠ RankType M atomMap r t →
        ¬ StaviTemporalTruthMu M atomMap r u (sep v) :=
    fun v => Classical.choose_spec (sep_exists v)
  let all_nfs := (Fintype.elems (α := NormalForm (muSig sig) (2 * r) 1)).val.toList
  let formula := sfConjList (all_nfs.map sep)
  refine ⟨formula, ?_, ?_⟩
  · -- Depth bound: all conjuncts have depth ≤ r
    apply stavi_depth_sf_conjList
    intro A hA
    simp only [List.mem_map] at hA
    obtain ⟨v, _, rfl⟩ := hA
    exact (sep_spec v).1
  · -- Correctness: formula holds at u iff RankType(u) = RankType(t)
    intro u
    rw [sf_conjList_truth_mu]
    constructor
    · -- Forward: if conjunction holds at u, then RankType(u) = RankType(t)
      intro h_conj
      by_contra h_ne
      -- nfProfile(u) is in all_nfs (Fintype.elems is complete)
      have h_in : sep (nfProfile u) ∈ all_nfs.map sep := by
        apply List.mem_map_of_mem
        exact Multiset.mem_toList.mpr (Fintype.complete _)
      -- The separator for nfProfile(u) holds at u (from the conjunction)
      have h_holds := h_conj _ h_in
      -- But it should fail at u (by sep_spec)
      exact (sep_spec (nfProfile u)).2.2 u rfl h_ne h_holds
    · -- Backward: if RankType(u) = RankType(t), then conjunction holds at u
      intro h_eq A hA
      simp only [List.mem_map] at hA
      obtain ⟨v, _, rfl⟩ := hA
      -- sep v holds at t (by sep_spec), and RankType(u) = RankType(t),
      -- so sep v holds at u (by rank_type_eq_iff)
      exact (rank_type_eq_iff h_eq.symm _ (sep_spec v).1).mp (sep_spec v).2.1

/-- The characteristic formula X_t: a single StaviFormula of depth ≤ r
    characterizing the rank-r type at position t.

    Properties (see x_t_depth and x_t_correct):
    - staviDepth (xTFormula ...) ≤ r
    - StaviTemporalTruthMu ... u (xTFormula ... t) ↔ RankType ... u = RankType ... t -/
noncomputable def xTFormula {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (r : Nat) (t : ExtendedCarrier M atomMap r) : StaviFormula :=
  Classical.choose (x_t_formula_exists M atomMap r t)

/-- The characteristic formula has depth at most r. -/
theorem x_t_depth {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t : ExtendedCarrier M atomMap r} :
    staviDepth (xTFormula M atomMap r t) ≤ r :=
  (Classical.choose_spec (x_t_formula_exists M atomMap r t)).1

/-- The characteristic formula correctly identifies positions with the same RankType. -/
theorem x_t_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t : ExtendedCarrier M atomMap r}
    (u : ExtendedCarrier M atomMap r) :
    StaviTemporalTruthMu M atomMap r u (xTFormula M atomMap r t) ↔
    RankType M atomMap r u = RankType M atomMap r t :=
  (Classical.choose_spec (x_t_formula_exists M atomMap r t)).2 u

/-- The characteristic formula holds at its defining position. -/
theorem x_t_self {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t : ExtendedCarrier M atomMap r} :
    StaviTemporalTruthMu M atomMap r t (xTFormula M atomMap r t) :=
  (x_t_correct t).mpr rfl

/-- If the characteristic formula holds at u, then u and t agree on all
    depth-≤r StaviFormulas. -/
theorem x_t_implies_agreement {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    (h : StaviTemporalTruthMu M atomMap r u (xTFormula M atomMap r t))
    (A : StaviFormula) (hd : staviDepth A ≤ r) :
    StaviTemporalTruthMu M atomMap r u A ↔
    StaviTemporalTruthMu M atomMap r t A :=
  rank_type_eq_iff ((x_t_correct u).mp h) A hd

/-! ## Interval Type Formula A = X_{(t,u)} (GHR93 Definition 8.8)

The interval type formula A characterizes the types realized by mu-points
in the open interval (t, u). A(w) holds iff w has the same rank-r type as
some mu-point in (t, u). -/

/-- Existence of the interval type formula. Same finiteness argument
    as x_t_formula_exists, applied to the finite set of types in (t, u). -/
theorem x_interval_formula_exists {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (r : Nat) (t u : ExtendedCarrier M atomMap r) :
    ∃ A : StaviFormula, staviDepth A ≤ r ∧
      ∀ (w : ExtendedCarrier M atomMap r),
        StaviTemporalTruthMu M atomMap r w A ↔
        ∃ v : ExtendedCarrier M atomMap r,
          MuHolds v ∧ t < v ∧ v < u ∧
          RankType M atomMap r w = RankType M atomMap r v := by
  -- For each NF profile v, if there exists a mu-point in (t, u) with that profile,
  -- include the xTFormula for a representative. Take the disjunction.
  have disjunct_exists : ∀ v : NormalForm (muSig sig) (2 * r) 1,
      ∃ A : StaviFormula, staviDepth A ≤ r ∧
        ∀ w : ExtendedCarrier M atomMap r,
          StaviTemporalTruthMu M atomMap r w A ↔
          (∃ p : ExtendedCarrier M atomMap r,
            MuHolds p ∧ t < p ∧ p < u ∧ nfProfile p = v ∧
            RankType M atomMap r w = RankType M atomMap r p) := by
    intro v
    by_cases h_ex : ∃ p : ExtendedCarrier M atomMap r,
        MuHolds p ∧ t < p ∧ p < u ∧ nfProfile p = v
    · -- A mu-point with this profile exists in (t, u): use xTFormula
      obtain ⟨p, hp_mu, htp, hpu, hp_prof⟩ := h_ex
      obtain ⟨A, hd, hcorr⟩ := x_t_formula_exists M atomMap r p
      refine ⟨A, hd, fun w => ?_⟩
      rw [hcorr w]
      constructor
      · intro h_eq
        exact ⟨p, hp_mu, htp, hpu, hp_prof, h_eq⟩
      · intro ⟨p', hp'_mu, htp', hp'u, hp'_prof, h_eq⟩
        -- p and p' have the same NF profile, hence same RankType
        have h_same : RankType M atomMap r p = RankType M atomMap r p' :=
          nf_profile_determines_rank_type (hp_prof.trans hp'_prof.symm)
        rw [h_eq, h_same]
    · -- No mu-point with this profile in (t, u): use ⊥
      push Not at h_ex
      exact ⟨.base .bot, by simp [staviDepth, operatorDepth],
        fun w => ⟨fun h => absurd h (by simp [StaviTemporalTruthMu, TemporalTruthMu]),
                  fun ⟨p, hp_mu, htp, hpu, hp_prof, _⟩ =>
                    absurd hp_prof (h_ex p hp_mu htp hpu)⟩⟩
  -- Choose disjuncts for each NF profile
  let disj : NormalForm (muSig sig) (2 * r) 1 → StaviFormula :=
    fun v => Classical.choose (disjunct_exists v)
  have disj_spec : ∀ v, staviDepth (disj v) ≤ r ∧
      ∀ w, StaviTemporalTruthMu M atomMap r w (disj v) ↔
        (∃ p, MuHolds p ∧ t < p ∧ p < u ∧ nfProfile p = v ∧
          RankType M atomMap r w = RankType M atomMap r p) :=
    fun v => Classical.choose_spec (disjunct_exists v)
  let all_nfs := (Fintype.elems (α := NormalForm (muSig sig) (2 * r) 1)).val.toList
  let formula := sfDisjList (all_nfs.map disj)
  refine ⟨formula, ?_, ?_⟩
  · -- Depth bound
    apply stavi_depth_sf_disjList
    intro A hA
    simp only [List.mem_map] at hA
    obtain ⟨v, _, rfl⟩ := hA
    exact (disj_spec v).1
  · -- Correctness
    intro w
    rw [sf_disjList_truth_mu]
    constructor
    · -- Forward: some disjunct holds at w → ∃ v in interval with matching RankType
      intro ⟨A, hA, hAw⟩
      simp only [List.mem_map] at hA
      obtain ⟨v, _, rfl⟩ := hA
      obtain ⟨p, hp_mu, htp, hpu, _, h_eq⟩ := (disj_spec v).2 w |>.mp hAw
      exact ⟨p, hp_mu, htp, hpu, h_eq⟩
    · -- Backward: ∃ v in interval → some disjunct holds at w
      intro ⟨v, hv_mu, htv, hvu, h_eq⟩
      -- nfProfile(v) is in all_nfs
      have h_in : disj (nfProfile v) ∈ all_nfs.map disj := by
        apply List.mem_map_of_mem
        exact Multiset.mem_toList.mpr (Fintype.complete _)
      exact ⟨disj (nfProfile v), h_in,
        (disj_spec (nfProfile v)).2 w |>.mpr ⟨v, hv_mu, htv, hvu, rfl, h_eq⟩⟩

/-- The interval type formula A = X_{(t,u)}: a StaviFormula of depth ≤ r
    that holds at w iff w has the same rank-r type as some mu-point
    in the open interval (t, u). -/
noncomputable def xIntervalFormula {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (r : Nat) (t u : ExtendedCarrier M atomMap r) : StaviFormula :=
  Classical.choose (x_interval_formula_exists M atomMap r t u)

/-- The interval type formula has depth at most r. -/
theorem x_interval_depth {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r} :
    staviDepth (xIntervalFormula M atomMap r t u) ≤ r :=
  (Classical.choose_spec (x_interval_formula_exists M atomMap r t u)).1

/-- The interval type formula correctly identifies types realized in (t, u). -/
theorem x_interval_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    (w : ExtendedCarrier M atomMap r) :
    StaviTemporalTruthMu M atomMap r w (xIntervalFormula M atomMap r t u) ↔
    ∃ v : ExtendedCarrier M atomMap r,
      MuHolds v ∧ t < v ∧ v < u ∧
      RankType M atomMap r w = RankType M atomMap r v :=
  (Classical.choose_spec (x_interval_formula_exists M atomMap r t u)).2 w

/-- Every mu-point in (t, u) satisfies the interval type formula. -/
theorem x_interval_self {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    {v : ExtendedCarrier M atomMap r}
    (hmu : MuHolds v) (htv : t < v) (hvu : v < u) :
    StaviTemporalTruthMu M atomMap r v (xIntervalFormula M atomMap r t u) :=
  (x_interval_correct v).mpr ⟨v, hmu, htv, hvu, rfl⟩

/-! ## Until Formula U(B, A) with Depth Bound -/

/-- Until formula U(B, A) as a StaviFormula. -/
def sfUntl (B A : StaviFormula) : StaviFormula :=
  .std_untl B A

/-- The depth of U(B, A) = max(depth B, depth A) + 2. -/
theorem sf_untl_depth (B A : StaviFormula) :
    staviDepth (sfUntl B A) = max (staviDepth B) (staviDepth A) + 2 := by
  simp [sfUntl, staviDepth]

/-- Since formula S(B, A) as a StaviFormula. -/
def sfSnce (B A : StaviFormula) : StaviFormula :=
  .std_snce B A

/-- The depth of S(B, A) = max(depth B, depth A) + 2. -/
theorem sf_snce_depth (B A : StaviFormula) :
    staviDepth (sfSnce B A) = max (staviDepth B) (staviDepth A) + 2 := by
  simp [sfSnce, staviDepth]

/-- U(B, A) depth bound when both B and A have depth ≤ r. -/
theorem sf_untl_depth_bound {B A : StaviFormula} {r : Nat}
    (hB : staviDepth B ≤ r) (hA : staviDepth A ≤ r) :
    staviDepth (sfUntl B A) ≤ r + 2 := by
  rw [sf_untl_depth]; omega

/-- Mu-relativized truth of U(B, A). -/
theorem sf_untl_truth_mu {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} (B A : StaviFormula) :
    StaviTemporalTruthMu M atomMap r t (sfUntl B A) ↔
    ∃ s : ExtendedCarrier M atomMap r, t < s ∧ MuHolds s ∧
      StaviTemporalTruthMu M atomMap r s B ∧
      ∀ w : ExtendedCarrier M atomMap r, t < w → w < s → MuHolds w →
        StaviTemporalTruthMu M atomMap r w A := by
  simp [sfUntl, StaviTemporalTruthMu]

/-- Mu-relativized truth of S(B, A). -/
theorem sf_snce_truth_mu {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} (B A : StaviFormula) :
    StaviTemporalTruthMu M atomMap r t (sfSnce B A) ↔
    ∃ s : ExtendedCarrier M atomMap r, s < t ∧ MuHolds s ∧
      StaviTemporalTruthMu M atomMap r s B ∧
      ∀ w : ExtendedCarrier M atomMap r, s < w → w < t → MuHolds w →
        StaviTemporalTruthMu M atomMap r w A := by
  simp [sfSnce, StaviTemporalTruthMu]

/-! ## Key Derived Properties for Case II -/

/-- U(X_t, X_{(s,t)}) holds at s in N when t witnesses it.
    This is GHR93 Case II Step 3. -/
theorem untl_type_holds_at_witness {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {s t : ExtendedCarrier M atomMap r}
    (hmu_t : MuHolds t) (hst : s < t) :
    StaviTemporalTruthMu M atomMap r s
      (sfUntl (xTFormula M atomMap r t) (xIntervalFormula M atomMap r s t)) := by
  rw [sf_untl_truth_mu]
  exact ⟨t, hst, hmu_t, x_t_self, fun w hsw hwt hmu_w =>
    x_interval_self hmu_w hsw hwt⟩

/-- The depth of U(X_t, X_{(s,t)}) is at most r + 2. -/
theorem untl_type_depth {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {s t : ExtendedCarrier M atomMap r} :
    staviDepth (sfUntl (xTFormula M atomMap r t)
      (xIntervalFormula M atomMap r s t)) ≤ r + 2 :=
  sf_untl_depth_bound x_t_depth x_interval_depth

/-- U(X_t, X_{(s,t)}) has depth ≤ r + 4 (needed for tau transfer at rank r+4). -/
theorem untl_type_depth_le_r_plus_4 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {s t : ExtendedCarrier M atomMap r} :
    staviDepth (sfUntl (xTFormula M atomMap r t)
      (xIntervalFormula M atomMap r s t)) ≤ r + 4 := by
  calc staviDepth (sfUntl (xTFormula M atomMap r t)
      (xIntervalFormula M atomMap r s t)) ≤ r + 2 := untl_type_depth
    _ ≤ r + 4 := by omega

/-- Extracting the Until witness. -/
theorem untl_extract_witness {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t : ExtendedCarrier M atomMap r}
    {B A : StaviFormula}
    (h : StaviTemporalTruthMu M atomMap r t (sfUntl B A)) :
    ∃ z : ExtendedCarrier M atomMap r, t < z ∧ MuHolds z ∧
      StaviTemporalTruthMu M atomMap r z B ∧
      ∀ w : ExtendedCarrier M atomMap r, t < w → w < z → MuHolds w →
        StaviTemporalTruthMu M atomMap r w A :=
  (sf_untl_truth_mu B A).mp h

/-- **Bounded Until witness lemma** (GHR93 supremum approach, Teammate D Solution B).

    If U(B, A)(t) holds and there exists a B-satisfying mu-point in (t, bound],
    then there exists a valid Until witness in (t, bound]. This resolves the
    containment problem: untl_extract_witness returns a witness in the FULL
    ExtendedCarrier, but this lemma restricts it to (t, bound].

    Proof: Let z_canon be the canonical Until witness (from U(B,A)(t)) and
    z_b be the given B-point in (t, bound]. Case split on z_b vs z_canon:
    - If z_b ≤ z_canon: (t, z_b) ⊆ (t, z_canon), so A holds on (t, z_b).
      Combined with B(z_b) and MuHolds(z_b), z_b is a valid bounded witness.
    - If z_b > z_canon: t < z_canon < z_b ≤ bound, so z_canon ∈ (t, bound].
      z_canon already has B(z_canon), MuHolds(z_canon), and A on (t, z_canon).
      So z_canon is itself a valid bounded witness. -/
theorem untl_witness_bounded {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t bound : ExtendedCarrier M atomMap r}
    {B A : StaviFormula}
    (h_untl : StaviTemporalTruthMu M atomMap r t (sfUntl B A))
    (h_bound : ∃ z_b : ExtendedCarrier M atomMap r, t < z_b ∧ z_b ≤ bound ∧
      MuHolds z_b ∧ StaviTemporalTruthMu M atomMap r z_b B) :
    ∃ z : ExtendedCarrier M atomMap r, t < z ∧ z ≤ bound ∧ MuHolds z ∧
      StaviTemporalTruthMu M atomMap r z B ∧
      ∀ w : ExtendedCarrier M atomMap r, t < w → w < z → MuHolds w →
        StaviTemporalTruthMu M atomMap r w A := by
  obtain ⟨z_b, htz_b, hz_b_bound, hmu_z_b, hB_z_b⟩ := h_bound
  obtain ⟨z_canon, htz_c, hmu_z_c, hB_z_c, hA_canon⟩ := untl_extract_witness h_untl
  rcases le_or_gt z_b z_canon with h_le | h_gt
  · -- Case 1: z_b ≤ z_canon. z_b works because (t, z_b) ⊆ (t, z_canon).
    exact ⟨z_b, htz_b, hz_b_bound, hmu_z_b, hB_z_b,
      fun w htw hwz hmu_w => hA_canon w htw (lt_of_lt_of_le hwz h_le) hmu_w⟩
  · -- Case 2: z_b > z_canon. z_canon is in (t, bound] and works directly.
    exact ⟨z_canon, htz_c, le_trans (le_of_lt h_gt) hz_b_bound, hmu_z_c, hB_z_c, hA_canon⟩

/-- Transfer formula truth through rankEmbed: if a StaviFormula has depth ≤ r,
    its mu-relativized truth is preserved by rankEmbed. This is a convenient
    specialization of rank_embed_stavi_truth_mu. -/
theorem formula_transfer_rank_embed {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r')
    (t : ExtendedCarrier M atomMap r) (A : StaviFormula) :
    StaviTemporalTruthMu M atomMap r' (rankEmbed h t) A ↔
    StaviTemporalTruthMu M atomMap r t A :=
  rank_embed_stavi_truth_mu h t A

end FormalSystem.Metalogic.WeakCanonical
