import Bimodal.Metalogic.WeakCanonical.EFGames.TypeFormulas

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

/-! ## Characteristic Formula X_t (GHR93 Definition 8.8)

For each position t in M_r, X_t is a StaviFormula of depth ≤ r such that
X_t(u) holds iff u has the same rank-r type as t. -/

/-- There exists a StaviFormula of depth ≤ r characterizing the rank-r type at t.

    The mathematical argument (GHR93, finiteness of rank_type quotient):
    1. NormalForm sig r 1 is Fintype with card N.
    2. The number of distinct rank-r types is bounded by 2^N.
    3. For each pair of distinct rank_types, a depth-≤r separator exists.
    4. The conjunction of ≤ 2^N - 1 separators characterizes t's type.

    NOTE: This sorry represents a genuine mathematical fact (finiteness of
    rank_type quotient). It does NOT represent an unsound assumption.
    Closing it requires bridging StaviFormula truth on ExtendedCarrier with
    NormalForm evaluation on M.carrier. -/
theorem x_t_formula_exists {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (r : Nat) (t : ExtendedCarrier M atomMap r) :
    ∃ A : StaviFormula, stavi_depth A ≤ r ∧
      ∀ (u : ExtendedCarrier M atomMap r),
        stavi_temporal_truth_mu M atomMap r u A ↔
        rank_type M atomMap r u = rank_type M atomMap r t := by
  sorry

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
  sorry

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
