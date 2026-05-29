import Bimodal.Metalogic.WeakCanonical.EFGames.TypeFormulas
import Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness

/-!
# Characteristic Formulas: X_t and Interval Type Formula A

Independent construction of the characteristic formula X_t (GHR93 Definition 8.8)
and the interval type formula A = X_{(t,u)} without using `nf_characterizable_by_stavi`
from StaviCompleteness.lean. This avoids putting the bridge lemma sorry onto the
bx_completeness critical path.

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
1. `rank_type` being determined by StaviFormulas of depth ≤ r
2. For distinct rank_types, a separating formula of depth ≤ r exists (by definition)
3. Finite conjunction of depth-≤r formulas has depth ≤ r (max of conjuncts)

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Definition 8.8
- Task 155 plan v43: Phase 2
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Boolean Formula Combinators

Public versions of disjunction/conjunction list combinators for StaviFormulas.
These are needed because StaviCompleteness.lean's versions are `private`. -/

/-- Disjunction of two StaviFormulas: A ∨ B = ¬(¬A ∧ ¬B). -/
def sf_disj (A B : StaviFormula) : StaviFormula :=
  .neg (.conj (.neg A) (.neg B))

/-- Disjunction of a list of StaviFormulas.
    Empty list maps to ⊥ (= base bot). -/
def sf_disjList : List StaviFormula → StaviFormula
  | [] => .base .bot
  | [a] => a
  | a :: as => sf_disj a (sf_disjList as)

/-- Conjunction of a list of StaviFormulas.
    Empty list maps to ¬⊥ (= ⊤). -/
def sf_conjList : List StaviFormula → StaviFormula
  | [] => .neg (.base .bot)
  | [a] => a
  | a :: as => .conj a (sf_conjList as)

/-- stavi_depth of sf_disj is max of operands. -/
theorem stavi_depth_sf_disj (A B : StaviFormula) :
    stavi_depth (sf_disj A B) = max (stavi_depth A) (stavi_depth B) := by
  simp [sf_disj, stavi_depth]

/-- stavi_depth of sf_conjList is bounded by the max depth in the list. -/
theorem stavi_depth_sf_conjList (l : List StaviFormula) (r : Nat)
    (h : ∀ A ∈ l, stavi_depth A ≤ r) :
    stavi_depth (sf_conjList l) ≤ r := by
  match l with
  | [] =>
    simp [sf_conjList, stavi_depth, operator_depth]
  | [a] =>
    simp only [sf_conjList]
    exact h a (by simp)
  | a :: b :: rest =>
    simp only [sf_conjList, stavi_depth]
    apply Nat.max_le.mpr
    exact ⟨h a (by simp),
           stavi_depth_sf_conjList (b :: rest) r
             (fun A hA => h A (List.mem_cons_of_mem a hA))⟩

/-- stavi_depth of sf_disjList is bounded by the max depth in the list. -/
theorem stavi_depth_sf_disjList (l : List StaviFormula) (r : Nat)
    (h : ∀ A ∈ l, stavi_depth A ≤ r) :
    stavi_depth (sf_disjList l) ≤ r := by
  match l with
  | [] =>
    simp [sf_disjList, stavi_depth, operator_depth]
  | [a] =>
    simp only [sf_disjList]
    exact h a (by simp)
  | a :: b :: rest =>
    simp only [sf_disjList, stavi_depth_sf_disj]
    apply Nat.max_le.mpr
    exact ⟨h a (by simp),
           stavi_depth_sf_disjList (b :: rest) r
             (fun A hA => h A (List.mem_cons_of_mem a hA))⟩

/-! ## Mu-Relativized Truth Semantics for Combinators -/

/-- sf_disj has standard disjunction semantics under mu-relativized truth. -/
theorem sf_disj_truth_mu {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} (A B : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r t (sf_disj A B) ↔
    (stavi_temporal_truth_mu M atomMap r t A ∨
     stavi_temporal_truth_mu M atomMap r t B) := by
  simp [sf_disj, stavi_temporal_truth_mu]
  tauto

/-- sf_conjList has conjunction semantics under mu-relativized truth. -/
theorem sf_conjList_truth_mu {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} (l : List StaviFormula) :
    stavi_temporal_truth_mu M atomMap r t (sf_conjList l) ↔
    ∀ A ∈ l, stavi_temporal_truth_mu M atomMap r t A := by
  match l with
  | [] =>
    simp [sf_conjList, stavi_temporal_truth_mu, temporal_truth_mu]
  | [a] =>
    simp only [sf_conjList]
    constructor
    · intro ha A hA; simp at hA; rw [hA]; exact ha
    · intro h; exact h a (by simp)
  | a :: b :: rest =>
    simp only [sf_conjList, stavi_temporal_truth_mu]
    rw [sf_conjList_truth_mu (b :: rest)]
    constructor
    · intro ⟨ha, hrest⟩ A hA
      simp only [List.mem_cons] at hA
      rcases hA with rfl | hA
      · exact ha
      · exact hrest A (List.mem_cons.mpr hA)
    · intro h
      exact ⟨h a (by simp), fun A hA => h A (List.mem_cons_of_mem a hA)⟩

/-- sf_disjList has disjunction semantics under mu-relativized truth. -/
theorem sf_disjList_truth_mu {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} (l : List StaviFormula) :
    stavi_temporal_truth_mu M atomMap r t (sf_disjList l) ↔
    ∃ A ∈ l, stavi_temporal_truth_mu M atomMap r t A := by
  match l with
  | [] =>
    simp [sf_disjList, stavi_temporal_truth_mu, temporal_truth_mu]
  | [a] =>
    simp only [sf_disjList]
    constructor
    · intro ha; exact ⟨a, by simp, ha⟩
    · intro ⟨A, hA, hAt⟩
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hA; subst hA; exact hAt
  | a :: b :: rest =>
    simp only [sf_disjList]
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
exists. This is immediate from the definition of rank_type. -/

/-- For two positions with different rank_types, there exists a StaviFormula
    of depth ≤ r that holds at one but not the other. -/
theorem rank_type_separator {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t u : ExtendedCarrier M atomMap r}
    (h : rank_type M atomMap r t ≠ rank_type M atomMap r u) :
    ∃ A : StaviFormula, stavi_depth A ≤ r ∧
      stavi_temporal_truth_mu M atomMap r t A ∧
      ¬ stavi_temporal_truth_mu M atomMap r u A := by
  -- rank_types differ → ∃ A in one but not the other
  rw [Ne, Set.ext_iff] at h; push_neg at h
  obtain ⟨A, hA⟩ := h
  simp only [rank_type, Set.mem_setOf_eq] at hA
  -- hA : (depth A ≤ r ∧ A^mu(t)) ∧ ¬(depth A ≤ r ∧ A^mu(u)) ∨
  --       ¬(depth A ≤ r ∧ A^mu(t)) ∧ (depth A ≤ r ∧ A^mu(u))
  rcases hA with ⟨⟨hd, ht⟩, hu⟩ | ⟨hnt, ⟨hd, hu⟩⟩
  · -- A ∈ rank_type(t) but A ∉ rank_type(u)
    push_neg at hu
    exact ⟨A, hd, ht, hu hd⟩
  · -- A ∉ rank_type(t) but A ∈ rank_type(u)
    push_neg at hnt
    -- (.neg A) holds at t (since ¬A^mu(t)) and fails at u (since A^mu(u))
    exact ⟨.neg A, by rw [stavi_depth_neg]; exact hd, hnt hd, fun h => h hu⟩

/-! ## NF Profile Determines Rank Type

Two positions with the same NormalForm characteristic on the mu-extended
structure at depth 2*r have the same rank_type. This is the key finiteness
step: since NormalForm (muSig sig) (2*r) 1 is Fintype, there are at most
finitely many distinct rank_types. -/

/-- The NF profile of a position: its NormalForm characteristic on
    the mu-extended structure at depth 2*r. -/
noncomputable abbrev nf_profile {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (t : ExtendedCarrier M atomMap r) :
    NormalForm (muSig sig) (2 * r) 1 :=
  nf_characteristic (extendedStructureWithMu M atomMap r) (2 * r) 1 (fun _ => t)

/-- Same NF profile implies same mu-relativized truth for all depth-≤r
    StaviFormulas. Proof chain:
    1. same nf_characteristic → same nf_eval_nf on all NFs
    2. → same eval on all depth-≤2*r MonadicFormula (muSig sig) 1
    3. → in particular on stavi_table_mu A (depth ≤ 2*r when stavi_depth A ≤ r)
    4. → same stavi_temporal_truth_mu (by stavi_table_mu_correct) -/
theorem nf_profile_determines_stavi_truth {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    (h_same : nf_profile t = nf_profile u)
    (A : StaviFormula) (hA : stavi_depth A ≤ r) :
    stavi_temporal_truth_mu M atomMap r t A ↔
    stavi_temporal_truth_mu M atomMap r u A := by
  -- Step 1: NF agreement on all depth-(2*r) NFs
  have h_t_nf := nf_characteristic_satisfies
    (extendedStructureWithMu M atomMap r) (2 * r) 1 (fun _ => t)
  have h_u_nf := nf_characteristic_satisfies
    (extendedStructureWithMu M atomMap r) (2 * r) 1 (fun _ => u)
  have h_u_nf_as_t : nf_eval_nf (extendedStructureWithMu M atomMap r) (2 * r) 1
      (fun _ => u) (nf_profile t) := h_same ▸ h_u_nf
  have h_nf_agree := nf_agreement_from_shared_nf
    (extendedStructureWithMu M atomMap r) (fun _ => t)
    (extendedStructureWithMu M atomMap r) (fun _ => u)
    (nf_profile t) h_t_nf h_u_nf_as_t
  -- Step 2: FO depth bound for the mu-translation of A
  have hA_fo : (stavi_table_mu atomMap A).quantifier_depth ≤ 2 * r :=
    le_trans (stavi_table_mu_depth A)
      (le_trans (stavi_fo_depth_le_twice_depth A) (Nat.mul_le_mul_left 2 hA))
  -- Step 3: Agreement on stavi_table_mu A via doets_lemma_1_1
  have h_eval_agree := doets_lemma_1_1 (2 * r) 1 (stavi_table_mu atomMap A) hA_fo
    (extendedStructureWithMu M atomMap r) (extendedStructureWithMu M atomMap r)
    (fun _ => t) (fun _ => u) h_nf_agree
  -- Step 4: Bridge from eval to stavi_temporal_truth_mu
  exact (stavi_table_mu_correct t A).symm.trans
    (h_eval_agree.trans (stavi_table_mu_correct u A))

/-- Same NF profile implies same rank_type. -/
theorem nf_profile_determines_rank_type {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    (h_same : nf_profile t = nf_profile u) :
    rank_type M atomMap r t = rank_type M atomMap r u := by
  ext A
  simp only [rank_type, Set.mem_setOf_eq]
  constructor
  · intro ⟨hd, hA⟩
    exact ⟨hd, (nf_profile_determines_stavi_truth h_same A hd).mp hA⟩
  · intro ⟨hd, hA⟩
    exact ⟨hd, (nf_profile_determines_stavi_truth h_same A hd).mpr hA⟩

/-- Contrapositive: different rank_types imply different NF profiles. -/
theorem rank_type_ne_of_nf_profile_ne {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    (h : rank_type M atomMap r t ≠ rank_type M atomMap r u) :
    nf_profile t ≠ nf_profile u :=
  fun h_eq => h (nf_profile_determines_rank_type h_eq)

/-! ## Characteristic Formula X_t (GHR93 Definition 8.8)

For each position t in M_r, X_t is a StaviFormula of depth ≤ r such that
X_t(u) holds iff u has the same rank-r type as t. -/

/-- There exists a StaviFormula of depth ≤ r characterizing the rank-r type at t.

    Proof strategy: enumerate all NF profiles in the Fintype
    NormalForm (muSig sig) (2*r) 1. For each profile, if there exists a position
    with that profile and different rank_type from t, use rank_type_separator
    to get a depth-≤r formula holding at t but not at that position. The
    conjunction over all profiles characterizes rank_type(t).

    The finiteness of NF profiles (Fintype on NormalForm) is the key ingredient:
    same NF profile implies same rank_type (nf_profile_determines_rank_type),
    so the number of distinct rank_types is bounded by |NormalForm (muSig sig) (2*r) 1|. -/
theorem x_t_formula_exists {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (r : Nat) (t : ExtendedCarrier M atomMap r) :
    ∃ A : StaviFormula, stavi_depth A ≤ r ∧
      ∀ (u : ExtendedCarrier M atomMap r),
        stavi_temporal_truth_mu M atomMap r u A ↔
        rank_type M atomMap r u = rank_type M atomMap r t := by
  -- For each NF profile v, build a separator if there exists a position with that
  -- profile and different rank_type. Otherwise use trivially-true ¬⊥.
  -- We prove this as a chain of existence claims.
  --
  -- Step 1: For each v : NormalForm (muSig sig) (2*r) 1, produce a depth-≤r formula
  -- that holds at t, and if nf_profile(u) = v with rank_type(u) ≠ rank_type(t),
  -- fails at u.
  have sep_exists : ∀ v : NormalForm (muSig sig) (2 * r) 1,
      ∃ A : StaviFormula, stavi_depth A ≤ r ∧
        stavi_temporal_truth_mu M atomMap r t A ∧
        ∀ u : ExtendedCarrier M atomMap r,
          nf_profile u = v → rank_type M atomMap r u ≠ rank_type M atomMap r t →
          ¬ stavi_temporal_truth_mu M atomMap r u A := by
    intro v
    by_cases h_ex : ∃ w : ExtendedCarrier M atomMap r,
        nf_profile w = v ∧ rank_type M atomMap r w ≠ rank_type M atomMap r t
    · -- There is a position with this profile and different rank_type: use separator
      obtain ⟨w, hw_prof, hw_ne⟩ := h_ex
      obtain ⟨A, hd, ht, hnw⟩ := rank_type_separator hw_ne.symm
      -- A holds at t and fails at w. Any u with same NF profile as w has same
      -- rank_type as w (by nf_profile_determines_rank_type), so A fails at u too.
      exact ⟨A, hd, ht, fun u hu_prof _ => by
        have h_same : rank_type M atomMap r u = rank_type M atomMap r w :=
          nf_profile_determines_rank_type (hu_prof.trans hw_prof.symm)
        intro h_holds
        exact hnw ((rank_type_eq_iff h_same _ hd).mp h_holds)⟩
    · -- No such position: .neg (.base .bot) is trivially true
      push_neg at h_ex
      exact ⟨.neg (.base .bot), by simp [stavi_depth, operator_depth],
        by simp [stavi_temporal_truth_mu, temporal_truth_mu],
        fun u hu hu_ne => absurd (h_ex u hu) hu_ne⟩
  -- Step 2: Choose separators for all NF profiles and take the conjunction
  let sep : NormalForm (muSig sig) (2 * r) 1 → StaviFormula :=
    fun v => Classical.choose (sep_exists v)
  have sep_spec : ∀ v, stavi_depth (sep v) ≤ r ∧
      stavi_temporal_truth_mu M atomMap r t (sep v) ∧
      ∀ u, nf_profile u = v → rank_type M atomMap r u ≠ rank_type M atomMap r t →
        ¬ stavi_temporal_truth_mu M atomMap r u (sep v) :=
    fun v => Classical.choose_spec (sep_exists v)
  let all_nfs := (Fintype.elems (α := NormalForm (muSig sig) (2 * r) 1)).val.toList
  let formula := sf_conjList (all_nfs.map sep)
  refine ⟨formula, ?_, ?_⟩
  · -- Depth bound: all conjuncts have depth ≤ r
    apply stavi_depth_sf_conjList
    intro A hA
    simp only [List.mem_map] at hA
    obtain ⟨v, _, rfl⟩ := hA
    exact (sep_spec v).1
  · -- Correctness: formula holds at u iff rank_type(u) = rank_type(t)
    intro u
    rw [sf_conjList_truth_mu]
    constructor
    · -- Forward: if conjunction holds at u, then rank_type(u) = rank_type(t)
      intro h_conj
      by_contra h_ne
      -- nf_profile(u) is in all_nfs (Fintype.elems is complete)
      have h_in : sep (nf_profile u) ∈ all_nfs.map sep := by
        apply List.mem_map_of_mem
        exact Multiset.mem_toList.mpr (Fintype.complete _)
      -- The separator for nf_profile(u) holds at u (from the conjunction)
      have h_holds := h_conj _ h_in
      -- But it should fail at u (by sep_spec)
      exact (sep_spec (nf_profile u)).2.2 u rfl h_ne h_holds
    · -- Backward: if rank_type(u) = rank_type(t), then conjunction holds at u
      intro h_eq A hA
      simp only [List.mem_map] at hA
      obtain ⟨v, _, rfl⟩ := hA
      -- sep v holds at t (by sep_spec), and rank_type(u) = rank_type(t),
      -- so sep v holds at u (by rank_type_eq_iff)
      exact (rank_type_eq_iff h_eq.symm _ (sep_spec v).1).mp (sep_spec v).2.1

/-- The characteristic formula X_t: a single StaviFormula of depth ≤ r
    characterizing the rank-r type at position t.

    Properties (see x_t_depth and x_t_correct):
    - stavi_depth (x_t_formula ...) ≤ r
    - stavi_temporal_truth_mu ... u (x_t_formula ... t) ↔ rank_type ... u = rank_type ... t -/
noncomputable def x_t_formula {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (r : Nat) (t : ExtendedCarrier M atomMap r) : StaviFormula :=
  Classical.choose (x_t_formula_exists M atomMap r t)

/-- The characteristic formula has depth at most r. -/
theorem x_t_depth {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t : ExtendedCarrier M atomMap r} :
    stavi_depth (x_t_formula M atomMap r t) ≤ r :=
  (Classical.choose_spec (x_t_formula_exists M atomMap r t)).1

/-- The characteristic formula correctly identifies positions with the same rank_type. -/
theorem x_t_correct {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t : ExtendedCarrier M atomMap r}
    (u : ExtendedCarrier M atomMap r) :
    stavi_temporal_truth_mu M atomMap r u (x_t_formula M atomMap r t) ↔
    rank_type M atomMap r u = rank_type M atomMap r t :=
  (Classical.choose_spec (x_t_formula_exists M atomMap r t)).2 u

/-- The characteristic formula holds at its defining position. -/
theorem x_t_self {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t : ExtendedCarrier M atomMap r} :
    stavi_temporal_truth_mu M atomMap r t (x_t_formula M atomMap r t) :=
  (x_t_correct t).mpr rfl

/-- If the characteristic formula holds at u, then u and t agree on all
    depth-≤r StaviFormulas. -/
theorem x_t_implies_agreement {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    (h : stavi_temporal_truth_mu M atomMap r u (x_t_formula M atomMap r t))
    (A : StaviFormula) (hd : stavi_depth A ≤ r) :
    stavi_temporal_truth_mu M atomMap r u A ↔
    stavi_temporal_truth_mu M atomMap r t A :=
  rank_type_eq_iff ((x_t_correct u).mp h) A hd

/-! ## Interval Type Formula A = X_{(t,u)} (GHR93 Definition 8.8)

The interval type formula A characterizes the types realized by mu-points
in the open interval (t, u). A(w) holds iff w has the same rank-r type as
some mu-point in (t, u). -/

/-- Existence of the interval type formula. Same finiteness argument
    as x_t_formula_exists, applied to the finite set of types in (t, u). -/
theorem x_interval_formula_exists {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (r : Nat) (t u : ExtendedCarrier M atomMap r) :
    ∃ A : StaviFormula, stavi_depth A ≤ r ∧
      ∀ (w : ExtendedCarrier M atomMap r),
        stavi_temporal_truth_mu M atomMap r w A ↔
        ∃ v : ExtendedCarrier M atomMap r,
          mu_holds v ∧ t < v ∧ v < u ∧
          rank_type M atomMap r w = rank_type M atomMap r v := by
  -- For each NF profile v, if there exists a mu-point in (t, u) with that profile,
  -- include the x_t_formula for a representative. Take the disjunction.
  have disjunct_exists : ∀ v : NormalForm (muSig sig) (2 * r) 1,
      ∃ A : StaviFormula, stavi_depth A ≤ r ∧
        ∀ w : ExtendedCarrier M atomMap r,
          stavi_temporal_truth_mu M atomMap r w A ↔
          (∃ p : ExtendedCarrier M atomMap r,
            mu_holds p ∧ t < p ∧ p < u ∧ nf_profile p = v ∧
            rank_type M atomMap r w = rank_type M atomMap r p) := by
    intro v
    by_cases h_ex : ∃ p : ExtendedCarrier M atomMap r,
        mu_holds p ∧ t < p ∧ p < u ∧ nf_profile p = v
    · -- A mu-point with this profile exists in (t, u): use x_t_formula
      obtain ⟨p, hp_mu, htp, hpu, hp_prof⟩ := h_ex
      obtain ⟨A, hd, hcorr⟩ := x_t_formula_exists M atomMap r p
      refine ⟨A, hd, fun w => ?_⟩
      rw [hcorr w]
      constructor
      · intro h_eq
        exact ⟨p, hp_mu, htp, hpu, hp_prof, h_eq⟩
      · intro ⟨p', hp'_mu, htp', hp'u, hp'_prof, h_eq⟩
        -- p and p' have the same NF profile, hence same rank_type
        have h_same : rank_type M atomMap r p = rank_type M atomMap r p' :=
          nf_profile_determines_rank_type (hp_prof.trans hp'_prof.symm)
        rw [h_eq, h_same]
    · -- No mu-point with this profile in (t, u): use ⊥
      push_neg at h_ex
      exact ⟨.base .bot, by simp [stavi_depth, operator_depth],
        fun w => ⟨fun h => absurd h (by simp [stavi_temporal_truth_mu, temporal_truth_mu]),
                  fun ⟨p, hp_mu, htp, hpu, hp_prof, _⟩ =>
                    absurd hp_prof (h_ex p hp_mu htp hpu)⟩⟩
  -- Choose disjuncts for each NF profile
  let disj : NormalForm (muSig sig) (2 * r) 1 → StaviFormula :=
    fun v => Classical.choose (disjunct_exists v)
  have disj_spec : ∀ v, stavi_depth (disj v) ≤ r ∧
      ∀ w, stavi_temporal_truth_mu M atomMap r w (disj v) ↔
        (∃ p, mu_holds p ∧ t < p ∧ p < u ∧ nf_profile p = v ∧
          rank_type M atomMap r w = rank_type M atomMap r p) :=
    fun v => Classical.choose_spec (disjunct_exists v)
  let all_nfs := (Fintype.elems (α := NormalForm (muSig sig) (2 * r) 1)).val.toList
  let formula := sf_disjList (all_nfs.map disj)
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
    · -- Forward: some disjunct holds at w → ∃ v in interval with matching rank_type
      intro ⟨A, hA, hAw⟩
      simp only [List.mem_map] at hA
      obtain ⟨v, _, rfl⟩ := hA
      obtain ⟨p, hp_mu, htp, hpu, _, h_eq⟩ := (disj_spec v).2 w |>.mp hAw
      exact ⟨p, hp_mu, htp, hpu, h_eq⟩
    · -- Backward: ∃ v in interval → some disjunct holds at w
      intro ⟨v, hv_mu, htv, hvu, h_eq⟩
      -- nf_profile(v) is in all_nfs
      have h_in : disj (nf_profile v) ∈ all_nfs.map disj := by
        apply List.mem_map_of_mem
        exact Multiset.mem_toList.mpr (Fintype.complete _)
      exact ⟨disj (nf_profile v), h_in,
        (disj_spec (nf_profile v)).2 w |>.mpr ⟨v, hv_mu, htv, hvu, rfl, h_eq⟩⟩

/-- The interval type formula A = X_{(t,u)}: a StaviFormula of depth ≤ r
    that holds at w iff w has the same rank-r type as some mu-point
    in the open interval (t, u). -/
noncomputable def x_interval_formula {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (r : Nat) (t u : ExtendedCarrier M atomMap r) : StaviFormula :=
  Classical.choose (x_interval_formula_exists M atomMap r t u)

/-- The interval type formula has depth at most r. -/
theorem x_interval_depth {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r} :
    stavi_depth (x_interval_formula M atomMap r t u) ≤ r :=
  (Classical.choose_spec (x_interval_formula_exists M atomMap r t u)).1

/-- The interval type formula correctly identifies types realized in (t, u). -/
theorem x_interval_correct {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    (w : ExtendedCarrier M atomMap r) :
    stavi_temporal_truth_mu M atomMap r w (x_interval_formula M atomMap r t u) ↔
    ∃ v : ExtendedCarrier M atomMap r,
      mu_holds v ∧ t < v ∧ v < u ∧
      rank_type M atomMap r w = rank_type M atomMap r v :=
  (Classical.choose_spec (x_interval_formula_exists M atomMap r t u)).2 w

/-- Every mu-point in (t, u) satisfies the interval type formula. -/
theorem x_interval_self {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t u : ExtendedCarrier M atomMap r}
    {v : ExtendedCarrier M atomMap r}
    (hmu : mu_holds v) (htv : t < v) (hvu : v < u) :
    stavi_temporal_truth_mu M atomMap r v (x_interval_formula M atomMap r t u) :=
  (x_interval_correct v).mpr ⟨v, hmu, htv, hvu, rfl⟩

/-! ## Until Formula U(B, A) with Depth Bound -/

/-- Until formula U(B, A) as a StaviFormula. -/
def sf_untl (B A : StaviFormula) : StaviFormula :=
  .std_untl B A

/-- The depth of U(B, A) = max(depth B, depth A) + 2. -/
theorem sf_untl_depth (B A : StaviFormula) :
    stavi_depth (sf_untl B A) = max (stavi_depth B) (stavi_depth A) + 2 := by
  simp [sf_untl, stavi_depth]

/-- Since formula S(B, A) as a StaviFormula. -/
def sf_snce (B A : StaviFormula) : StaviFormula :=
  .std_snce B A

/-- The depth of S(B, A) = max(depth B, depth A) + 2. -/
theorem sf_snce_depth (B A : StaviFormula) :
    stavi_depth (sf_snce B A) = max (stavi_depth B) (stavi_depth A) + 2 := by
  simp [sf_snce, stavi_depth]

/-- U(B, A) depth bound when both B and A have depth ≤ r. -/
theorem sf_untl_depth_bound {B A : StaviFormula} {r : Nat}
    (hB : stavi_depth B ≤ r) (hA : stavi_depth A ≤ r) :
    stavi_depth (sf_untl B A) ≤ r + 2 := by
  rw [sf_untl_depth]; omega

/-- Mu-relativized truth of U(B, A). -/
theorem sf_untl_truth_mu {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} (B A : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r t (sf_untl B A) ↔
    ∃ s : ExtendedCarrier M atomMap r, t < s ∧ mu_holds s ∧
      stavi_temporal_truth_mu M atomMap r s B ∧
      ∀ w : ExtendedCarrier M atomMap r, t < w → w < s → mu_holds w →
        stavi_temporal_truth_mu M atomMap r w A := by
  simp [sf_untl, stavi_temporal_truth_mu]

/-- Mu-relativized truth of S(B, A). -/
theorem sf_snce_truth_mu {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} (B A : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r t (sf_snce B A) ↔
    ∃ s : ExtendedCarrier M atomMap r, s < t ∧ mu_holds s ∧
      stavi_temporal_truth_mu M atomMap r s B ∧
      ∀ w : ExtendedCarrier M atomMap r, s < w → w < t → mu_holds w →
        stavi_temporal_truth_mu M atomMap r w A := by
  simp [sf_snce, stavi_temporal_truth_mu]

/-! ## Key Derived Properties for Case II -/

/-- U(X_t, X_{(s,t)}) holds at s in N when t witnesses it.
    This is GHR93 Case II Step 3. -/
theorem untl_type_holds_at_witness {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {s t : ExtendedCarrier M atomMap r}
    (hmu_t : mu_holds t) (hst : s < t) :
    stavi_temporal_truth_mu M atomMap r s
      (sf_untl (x_t_formula M atomMap r t) (x_interval_formula M atomMap r s t)) := by
  rw [sf_untl_truth_mu]
  exact ⟨t, hst, hmu_t, x_t_self, fun w hsw hwt hmu_w =>
    x_interval_self hmu_w hsw hwt⟩

/-- The depth of U(X_t, X_{(s,t)}) is at most r + 2. -/
theorem untl_type_depth {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {s t : ExtendedCarrier M atomMap r} :
    stavi_depth (sf_untl (x_t_formula M atomMap r t)
      (x_interval_formula M atomMap r s t)) ≤ r + 2 :=
  sf_untl_depth_bound x_t_depth x_interval_depth

/-- U(X_t, X_{(s,t)}) has depth ≤ r + 4 (needed for tau transfer at rank r+4). -/
theorem untl_type_depth_le_r_plus_4 {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {s t : ExtendedCarrier M atomMap r} :
    stavi_depth (sf_untl (x_t_formula M atomMap r t)
      (x_interval_formula M atomMap r s t)) ≤ r + 4 := by
  calc stavi_depth (sf_untl (x_t_formula M atomMap r t)
      (x_interval_formula M atomMap r s t)) ≤ r + 2 := untl_type_depth
    _ ≤ r + 4 := by omega

/-- Extracting the Until witness. -/
theorem untl_extract_witness {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t : ExtendedCarrier M atomMap r}
    {B A : StaviFormula}
    (h : stavi_temporal_truth_mu M atomMap r t (sf_untl B A)) :
    ∃ z : ExtendedCarrier M atomMap r, t < z ∧ mu_holds z ∧
      stavi_temporal_truth_mu M atomMap r z B ∧
      ∀ w : ExtendedCarrier M atomMap r, t < w → w < z → mu_holds w →
        stavi_temporal_truth_mu M atomMap r w A :=
  (sf_untl_truth_mu B A).mp h

/-- **Bounded Until witness lemma** (GHR93 supremum approach, Teammate D Solution B).

    If U(B, A)(t) holds and there exists a B-satisfying mu-point in (t, bound],
    then there exists a valid Until witness in (t, bound]. This resolves the
    containment problem: untl_extract_witness returns a witness in the FULL
    ExtendedCarrier, but this lemma restricts it to (t, bound].

    Proof: Let z_canon be the canonical Until witness (from U(B,A)(t)) and
    z_b be the given B-point in (t, bound]. Case split on z_b vs z_canon:
    - If z_b ≤ z_canon: (t, z_b) ⊆ (t, z_canon), so A holds on (t, z_b).
      Combined with B(z_b) and mu_holds(z_b), z_b is a valid bounded witness.
    - If z_b > z_canon: t < z_canon < z_b ≤ bound, so z_canon ∈ (t, bound].
      z_canon already has B(z_canon), mu_holds(z_canon), and A on (t, z_canon).
      So z_canon is itself a valid bounded witness. -/
theorem untl_witness_bounded {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {t bound : ExtendedCarrier M atomMap r}
    {B A : StaviFormula}
    (h_untl : stavi_temporal_truth_mu M atomMap r t (sf_untl B A))
    (h_bound : ∃ z_b : ExtendedCarrier M atomMap r, t < z_b ∧ z_b ≤ bound ∧
      mu_holds z_b ∧ stavi_temporal_truth_mu M atomMap r z_b B) :
    ∃ z : ExtendedCarrier M atomMap r, t < z ∧ z ≤ bound ∧ mu_holds z ∧
      stavi_temporal_truth_mu M atomMap r z B ∧
      ∀ w : ExtendedCarrier M atomMap r, t < w → w < z → mu_holds w →
        stavi_temporal_truth_mu M atomMap r w A := by
  obtain ⟨z_b, htz_b, hz_b_bound, hmu_z_b, hB_z_b⟩ := h_bound
  obtain ⟨z_canon, htz_c, hmu_z_c, hB_z_c, hA_canon⟩ := untl_extract_witness h_untl
  rcases le_or_gt z_b z_canon with h_le | h_gt
  · -- Case 1: z_b ≤ z_canon. z_b works because (t, z_b) ⊆ (t, z_canon).
    exact ⟨z_b, htz_b, hz_b_bound, hmu_z_b, hB_z_b,
      fun w htw hwz hmu_w => hA_canon w htw (lt_of_lt_of_le hwz h_le) hmu_w⟩
  · -- Case 2: z_b > z_canon. z_canon is in (t, bound] and works directly.
    exact ⟨z_canon, htz_c, le_trans (le_of_lt h_gt) hz_b_bound, hmu_z_c, hB_z_c, hA_canon⟩

/-- Transfer formula truth through rank_embed: if a StaviFormula has depth ≤ r,
    its mu-relativized truth is preserved by rank_embed. This is a convenient
    specialization of rank_embed_stavi_truth_mu. -/
theorem formula_transfer_rank_embed {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r')
    (t : ExtendedCarrier M atomMap r) (A : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r' (rank_embed h t) A ↔
    stavi_temporal_truth_mu M atomMap r t A :=
  rank_embed_stavi_truth_mu h t A

end Bimodal.Metalogic.WeakCanonical
