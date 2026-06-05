import Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula
import Bimodal.Metalogic.WeakCanonical.EFGames.GapDetection
import Bimodal.Metalogic.WeakCanonical.EFGames.Decomposition

/-!
# NF-Game Bridge: Helper Lemmas

Bridge lemmas connecting the NormalForm world (nf_characteristic, nf_eval_nf,
interval_nf_types on M.carrier) with the EF game world (rank_type,
stavi_temporal_truth_mu, decomposition_agreement on ExtendedCarrier).

## Architecture

The Stavi completeness proof needs: 2-var depth-k NFs are determined by
1-var NFs + ordering + interval types. The direct NF induction approach
FAILS at the sub-interval splitting problem (5 sessions confirmed).

The correct path (GHR93) goes THROUGH the EF game:

1. NF hypotheses → decomposition_agreement (Bridge A)
2. decomposition_agreement → ghr93_duplicator_wins (already sorry-free!)
3. ghr93_duplicator_wins → NF agreement (Bridge B)

This file provides helper lemmas for the bridge. The full bridge
implementation requires ~300-400 additional lines connecting NF types
on M.carrier with rank_type/formula_agreement on ExtendedCarrier.

## Why the Direct Approach Fails

The sorries in `nf_2var_existential_transfer` (StaviCompleteness.lean
lines 2347, 2429) need 4-var existential transfer at depth j' for the
3-point configuration (u,x,t)/(u',x',t'). Zone matching finds u' with
matching 1-var NF and orderings. But the 4-var NF requires sub-interval
types for ALL pairs in the 3-point config, including (w,u) and (u,x).
These sub-interval types are NOT determined by the interval types of (x,t):
a type realized in (x,t) might appear only in (u,t) but not in (x,u).

The game solves this because its compositional structure (Composition.lean)
splits intervals while maintaining the game invariant at each sub-interval.

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Lemma 11
- Task 155: literature-interval-splitting report (Section 5)
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## NF Agreement Helpers

Lemmas connecting depth-k 1-var NF agreement to predicate agreement,
StaviFormula agreement, and depth-j agreement (for j ≤ k). -/

/-- If x and x' have the same depth-k 1-var NF, then for every depth-k NF nf_k,
    x satisfies nf_k iff x' satisfies nf_k. -/
theorem nf_agreement_from_nf_char_eq {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k : Nat} {x : M.carrier} {x' : M'.carrier}
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x'))
    (nf_k : NormalForm sig k 1) :
    nf_eval_nf M k 1 (fun _ => x) nf_k ↔
    nf_eval_nf M' k 1 (fun _ => x') nf_k :=
  nf_agreement_from_shared_nf M (fun _ => x) M' (fun _ => x')
    (nf_characteristic M k 1 (fun _ => x))
    (nf_characteristic_satisfies M k 1 (fun _ => x))
    (h_nf ▸ nf_characteristic_satisfies M' k 1 (fun _ => x'))
    nf_k

/-- NF agreement at char_k level: if x and x' have the same depth-k 1-var NF,
    and char_k correctly characterizes depth-k NFs, then for every nf_k,
    char_k nf_k has the same truth at x and x'. -/
theorem nf_char_eq_implies_stavi_char_agree {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds}
    {k : Nat} {x : M.carrier} {x' : M'.carrier}
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (N : OrderedMonadicStructure sig) (t : N.carrier),
        stavi_temporal_truth N atomMap t (char_k nf_k) ↔
        nf_eval_nf N k 1 (fun _ => t) nf_k)
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x'))
    (nf_k : NormalForm sig k 1) :
    stavi_temporal_truth M atomMap x (char_k nf_k) ↔
    stavi_temporal_truth M' atomMap x' (char_k nf_k) := by
  rw [char_k_correct nf_k M x, char_k_correct nf_k M' x']
  exact nf_agreement_from_nf_char_eq h_nf nf_k

/-- Predicate agreement at a single point follows from 1-var NF agreement. -/
theorem pred_agree_from_nf_char {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k : Nat} {x : M.carrier} {x' : M'.carrier}
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x'))
    (p : sig.preds) :
    M.interp p x ↔ M'.interp p x' :=
  atom_agreement_from_nf M (fun _ => x) M' (fun _ => x')
    (nf_agreement_from_nf_char_eq h_nf) (.pred p 0)

/-- Depth-k 1-var NF agreement implies depth-j 1-var NF agreement for j ≤ k. -/
theorem nf_char_depth_le {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k j : Nat} (hj : j ≤ k)
    {a : M.carrier} {a' : M'.carrier}
    (h : nf_characteristic M k 1 (fun _ => a) =
         nf_characteristic M' k 1 (fun _ => a')) :
    nf_characteristic M j 1 (fun _ => a) =
    nf_characteristic M' j 1 (fun _ => a') := by
  have h_agree_j : ∀ nf_j : NormalForm sig j 1,
      nf_eval_nf M j 1 (fun _ => a) nf_j ↔
      nf_eval_nf M' j 1 (fun _ => a') nf_j :=
    nf_agreement_monotone j k 1 hj M (fun _ => a) M' (fun _ => a')
      (nf_agreement_from_nf_char_eq h)
  apply nf_eval_unique M' j 1 (fun _ => a')
  · exact (h_agree_j _).mp (nf_characteristic_satisfies M j 1 (fun _ => a))
  · exact nf_characteristic_satisfies M' j 1 (fun _ => a')

/-! ## Depth-0 NF Transfer

At depth 0, NFs are purely atomic (predicate + ordering assignments).
The n-variable version is provable from pointwise NF agreement + orderings. -/

/-- At depth 0, n-variable NF equality follows from atom agreement alone. -/
theorem nvar_nf_eq_depth_zero {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    (n : Nat)
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_atoms : ∀ a : AtomKind sig n, atom_eval M env_M a ↔ atom_eval M' env_M' a) :
    nf_characteristic M 0 n env_M = nf_characteristic M' 0 n env_M' := by
  apply nf_eval_unique M' 0 n env_M'
  · intro a
    exact ⟨fun ha => ((nf_characteristic_satisfies M 0 n env_M) a).mp ((h_atoms a).mpr ha),
           fun ha => (h_atoms a).mp (((nf_characteristic_satisfies M 0 n env_M) a).mpr ha)⟩
  · exact nf_characteristic_satisfies M' 0 n env_M'

/-- Atom agreement at n variables from pointwise 1-var NF agreement and orderings. -/
theorem atom_agree_from_pointwise_nf {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k n : Nat}
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_nf_points : ∀ i : Fin n,
      nf_characteristic M k 1 (fun _ => env_M i) =
      nf_characteristic M' k 1 (fun _ => env_M' i))
    (h_order : ∀ i j : Fin n,
      (env_M i < env_M j ↔ env_M' i < env_M' j))
    (a : AtomKind sig n) :
    atom_eval M env_M a ↔ atom_eval M' env_M' a := by
  cases a with
  | pred p i =>
    simp only [atom_eval]
    exact pred_agree_from_nf_char (h_nf_points i) p
  | order i j _ =>
    simp only [atom_eval]
    exact h_order i j

/-- Corollary: depth-0 n-var NF equality from pointwise data. -/
theorem nvar_nf_eq_depth_zero_from_pointwise {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {k n : Nat}
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_nf_points : ∀ i : Fin n,
      nf_characteristic M k 1 (fun _ => env_M i) =
      nf_characteristic M' k 1 (fun _ => env_M' i))
    (h_order : ∀ i j : Fin n,
      (env_M i < env_M j ↔ env_M' i < env_M' j)) :
    nf_characteristic M 0 n env_M = nf_characteristic M' 0 n env_M' :=
  nvar_nf_eq_depth_zero n env_M env_M'
    (atom_agree_from_pointwise_nf env_M env_M' h_nf_points h_order)


/-! ## Discrete Order: No Gaps Infrastructure

For discrete orders (IsSuccArchimedean with SuccOrder/PredOrder/NoMaxOrder/NoMinOrder),
`discrete_no_gaps` proves `IsEmpty (Gap M.carrier)`. This means:
- `RDefinableGap M atomMap r` is empty (subtype of empty type)
- `ExtendedCarrier M atomMap r` collapses to `M.carrier` (no `Sum.inr` elements)
- `mu_holds` is trivially true for all elements (all are actual points)
- `stavi_temporal_truth_mu` reduces to `stavi_temporal_truth` at all points

These lemmas build the foundation for the discrete game bypass strategy. -/

/-- If `Gap M.carrier` is empty, then `RDefinableGap M atomMap r` is empty. -/
theorem rdefinable_gap_empty_of_no_gaps {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (h : IsEmpty (Gap M.carrier)) :
    IsEmpty (RDefinableGap M atomMap r) :=
  ⟨fun ⟨g, _⟩ => h.elim g⟩

/-- In a discrete order, every element of ExtendedCarrier is an actual point. -/
theorem discrete_extended_is_point {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (h_no_gaps : IsEmpty (Gap M.carrier))
    (e : ExtendedCarrier M atomMap r) :
    ∃ x : M.carrier, extendPoint x = e := by
  cases e with
  | inl x => exact ⟨x, rfl⟩
  | inr g => exact ((rdefinable_gap_empty_of_no_gaps h_no_gaps).false g).elim

/-- In a discrete order, extendPoint is surjective onto ExtendedCarrier. -/
theorem discrete_extendPoint_surj {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (h_no_gaps : IsEmpty (Gap M.carrier)) :
    Function.Surjective (extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := r)) :=
  discrete_extended_is_point h_no_gaps

/-- In a discrete order, mu_holds is true for all elements of ExtendedCarrier. -/
theorem discrete_mu_trivial {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (h_no_gaps : IsEmpty (Gap M.carrier))
    (e : ExtendedCarrier M atomMap r) :
    mu_holds e := by
  obtain ⟨x, rfl⟩ := discrete_extended_is_point h_no_gaps e
  exact mu_holds_point x

/-- In a discrete order, every element of ExtendedCarrier is IsPoint. -/
theorem discrete_extended_isPoint {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (h_no_gaps : IsEmpty (Gap M.carrier))
    (e : ExtendedCarrier M atomMap r) :
    IsPoint e := by
  obtain ⟨x, rfl⟩ := discrete_extended_is_point h_no_gaps e
  exact ⟨x, rfl⟩

/-- In a discrete order, no element of ExtendedCarrier is IsGap. -/
theorem discrete_extended_not_isGap {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (h_no_gaps : IsEmpty (Gap M.carrier))
    (e : ExtendedCarrier M atomMap r) :
    ¬ IsGap e := by
  obtain ⟨x, rfl⟩ := discrete_extended_is_point h_no_gaps e
  intro ⟨g, hg⟩
  exact absurd hg Sum.inl_ne_inr

/-- In a discrete order, inClosedInterval on ExtendedCarrier reduces to order on M.carrier. -/
theorem discrete_inClosedInterval_iff {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (x y z : M.carrier) :
    inClosedInterval (extendPoint (sig := sig) (atomMap := atomMap) (r := r) x)
      (extendPoint y) (extendPoint z) ↔ x ≤ z ∧ z ≤ y := by
  simp only [inClosedInterval]
  constructor
  · intro ⟨h1, h2⟩; exact ⟨h1, h2⟩
  · intro ⟨h1, h2⟩; exact ⟨h1, h2⟩

/-- In a discrete order, strict ordering on ExtendedCarrier reduces to M.carrier ordering.
    This is a public version of the private extendPoint_lt_iff' in TypeFormulas.lean. -/
theorem discrete_extendPoint_lt_iff {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (x y : M.carrier) :
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) x <
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) y ↔ x < y := by
  constructor
  · intro h
    -- ExtendedCarrier lt for Sum.inl: reduces to lt on M.carrier
    have h_le : (extendPoint x : ExtendedCarrier M atomMap r) ≤ extendPoint y := le_of_lt h
    have h_ne : (extendPoint x : ExtendedCarrier M atomMap r) ≠ extendPoint y := ne_of_lt h
    -- Both extendedLE (.inl x) (.inl y) and extendedLE (.inl y) (.inl x) reduce to ≤ on M.carrier
    exact lt_of_le_of_ne (show x ≤ y from h_le) (fun heq => h_ne (show (extendPoint x : ExtendedCarrier M atomMap r) = extendPoint y from congrArg Sum.inl heq))
  · intro h
    show @LT.lt (ExtendedCarrier M atomMap r) _ (Sum.inl x) (Sum.inl y)
    exact @lt_of_lt_of_le (ExtendedCarrier M atomMap r) _ (Sum.inl x) (Sum.inl y) (Sum.inl y)
      ⟨show extendedLE (Sum.inl x) (Sum.inl y) from le_of_lt h,
       fun hyx => not_lt.mpr (show y ≤ x from hyx) h⟩
      (le_refl _)

/-! ## Discrete Bridge: NF on sig → NF on muSig

For discrete orders (no gaps), the extended carrier collapses to M.carrier.
This section proves that NF agreement on `sig` at actual points transfers to
NF agreement on `muSig sig` at `extendedStructureWithMu`, which in turn
gives `nf_profile` agreement, `rank_type` agreement, and ultimately
`decomposition_agreement` at rank k/2.

### Mathematical Key

For discrete M: `ExtendedCarrier M atomMap r = M.carrier` (no gaps).
`extendedStructureWithMu` adds a trivially-true mu predicate.
NF agreement on `sig` lifts to NF agreement on `muSig sig` because:
1. sig-predicate atoms agree (from NF hypothesis)
2. mu-predicate atoms agree (both true at actual points)
3. order atoms agree (extendPoint preserves order)
4. quantifiers over ExtendedCarrier reduce to M.carrier (no gaps)
5. existential transfer on muSig follows from transfer on sig + IH
-/

/-- Atom agreement on muSig from atom agreement on sig: at actual points,
    sig predicates agree by hypothesis and mu is trivially true. -/
private theorem discrete_muSig_atom_agree {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {n : Nat}
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_atoms : ∀ a : AtomKind sig n, atom_eval M env_M a ↔ atom_eval M' env_M' a)
    (a : AtomKind (muSig sig) n) :
    atom_eval (extendedStructureWithMu M atomMap r)
      (fun i => extendPoint (env_M i)) a ↔
    atom_eval (extendedStructureWithMu M' atomMap r)
      (fun i => extendPoint (env_M' i)) a := by
  cases a with
  | pred p i =>
    simp only [atom_eval, extendedStructureWithMu]
    cases p with
    | inl p' =>
      simp only [extendedStructure, extendPoint]
      exact h_atoms (.pred p' i)
    | inr u =>
      simp only [extendPoint, IsPoint]
      exact ⟨fun _ => ⟨env_M' i, rfl⟩, fun _ => ⟨env_M i, rfl⟩⟩
  | order i j hij =>
    simp only [atom_eval]
    constructor
    · intro h
      exact (discrete_extendPoint_lt_iff (env_M' i) (env_M' j)).mpr
        ((h_atoms (.order i j hij)).mp
          ((discrete_extendPoint_lt_iff (env_M i) (env_M j)).mp h))
    · intro h
      exact (discrete_extendPoint_lt_iff (env_M i) (env_M j)).mpr
        ((h_atoms (.order i j hij)).mpr
          ((discrete_extendPoint_lt_iff (env_M' i) (env_M' j)).mp h))

/-- For discrete orders, NF agreement on sig at depth d implies NF agreement on
    muSig at depth d on the extended structures (at actual-point environments).

    By induction on d:
    - d=0: atom agreement on muSig from atom agreement on sig + mu trivially true.
    - d+1: atoms as above. Quantifier transfer: the quantifier part of the sig-NF
      gives existential transfer on M.carrier. For discrete orders, ExtendedCarrier
      = M.carrier, so this transfers to ExtendedCarrier. By IH, the matched
      environments give muSig NF agreement at depth d. -/
theorem discrete_muSig_nf_agree {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat}
    (h_no_gaps_M : IsEmpty (Gap M.carrier))
    (h_no_gaps_M' : IsEmpty (Gap M'.carrier)) :
    ∀ (d n : Nat)
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_nf_agree : ∀ nf : NormalForm sig d n,
      nf_eval_nf M d n env_M nf ↔ nf_eval_nf M' d n env_M' nf),
    ∀ (nf_mu : NormalForm (muSig sig) d n),
      nf_eval_nf (extendedStructureWithMu M atomMap r) d n
        (fun i => extendPoint (env_M i)) nf_mu ↔
      nf_eval_nf (extendedStructureWithMu M' atomMap r) d n
        (fun i => extendPoint (env_M' i)) nf_mu := by
  intro d
  induction d with
  | zero =>
    -- Depth 0: just atom agreement
    intro n env_M env_M' h_nf_agree nf_mu
    simp only [nf_eval_nf]
    have h_atom_sig := atom_agreement_from_nf M env_M M' env_M' h_nf_agree
    constructor
    · intro hM a
      exact (discrete_muSig_atom_agree env_M env_M' h_atom_sig a).symm.trans (hM a)
    · intro hM' a
      exact (discrete_muSig_atom_agree env_M env_M' h_atom_sig a).trans (hM' a)
  | succ d ih =>
    intro n env_M env_M' h_nf_agree nf_mu
    have h_atom_sig := atom_agreement_from_nf M env_M M' env_M' h_nf_agree
    constructor
    · -- M → M'
      intro ⟨hM_atoms, hM_quant⟩
      constructor
      · -- Atom part: muSig atoms agree
        intro a
        exact (discrete_muSig_atom_agree env_M env_M' h_atom_sig a).symm.trans (hM_atoms a)
      · -- Quantifier part: existential transfer on muSig NFs at depth d
        intro sub_nf_mu
        rw [← hM_quant sub_nf_mu]
        -- Need: (∃ e : ExtCarr_M, nf_eval_nf (extMu M) d (n+1) (e :: ext_env_M) sub_nf_mu) ↔
        --       (∃ e' : ExtCarr_M', nf_eval_nf (extMu M') d (n+1) (e' :: ext_env_M') sub_nf_mu)
        -- For discrete orders, e = extendPoint y, e' = extendPoint y'.
        -- Helper: extract quantifier transfer from depth-(d+1) NF agreement
        have h_quant_transfer : ∀ (nf_sub : NormalForm sig d (n + 1)),
            (∃ y : M.carrier, nf_eval_nf M d (n + 1) (Fin.cons y env_M) nf_sub) ↔
            (∃ y' : M'.carrier, nf_eval_nf M' d (n + 1) (Fin.cons y' env_M') nf_sub) := by
          intro nf_sub
          have hM_sat := nf_characteristic_satisfies M (d + 1) n env_M
          have hM'_sat := (h_nf_agree (nf_characteristic M (d + 1) n env_M)).mp hM_sat
          obtain ⟨_, hM_q⟩ := hM_sat
          obtain ⟨_, hM'_q⟩ := hM'_sat
          exact (hM_q nf_sub).trans (hM'_q nf_sub).symm
        -- Helper: env rewriting
        have h_env_cons : ∀ (y : M.carrier),
            (fun (i : Fin (n + 1)) => extendPoint (sig := sig) (M := M)
              (atomMap := atomMap) (r := r) ((Fin.cons y env_M : Fin (n + 1) → M.carrier) i)) =
            Fin.cons (extendPoint y) (fun i => extendPoint (env_M i)) := by
          intro y; funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons]
        have h_env_cons' : ∀ (y' : M'.carrier),
            (fun (i : Fin (n + 1)) => extendPoint (sig := sig) (M := M')
              (atomMap := atomMap) (r := r) ((Fin.cons y' env_M' : Fin (n + 1) → M'.carrier) i)) =
            Fin.cons (extendPoint y') (fun i => extendPoint (env_M' i)) := by
          intro y'; funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons]
        -- After rw [← hM_quant]:
        -- goal is (∃ e' : ExtCarr_M', ..._M' ...) ↔ (∃ e : ExtCarr_M, ..._M ...)
        constructor
        · -- Forward: M' → M
          rintro ⟨e', he'⟩
          obtain ⟨y', rfl⟩ := discrete_extended_is_point h_no_gaps_M'
            (show ExtendedCarrier M' atomMap r from e')
          let nf_y' := nf_characteristic M' d (n + 1) (Fin.cons y' env_M')
          have h_nf_y' := nf_characteristic_satisfies M' d (n + 1) (Fin.cons y' env_M')
          obtain ⟨y, h_nf_y⟩ := (h_quant_transfer nf_y').mpr ⟨y', h_nf_y'⟩
          have h_nf_d := nf_agreement_from_shared_nf M (Fin.cons y env_M)
            M' (Fin.cons y' env_M') nf_y' h_nf_y h_nf_y'
          have h_mu_nf := ih (n + 1) (Fin.cons y env_M) (Fin.cons y' env_M') h_nf_d sub_nf_mu
          rw [h_env_cons] at h_mu_nf; rw [h_env_cons'] at h_mu_nf
          exact ⟨extendPoint y, h_mu_nf.mpr he'⟩
        · -- Backward: M → M'
          rintro ⟨e, he⟩
          obtain ⟨y, rfl⟩ := discrete_extended_is_point h_no_gaps_M
            (show ExtendedCarrier M atomMap r from e)
          let nf_y := nf_characteristic M d (n + 1) (Fin.cons y env_M)
          have h_nf_y := nf_characteristic_satisfies M d (n + 1) (Fin.cons y env_M)
          obtain ⟨y', h_nf_y'⟩ := (h_quant_transfer nf_y).mp ⟨y, h_nf_y⟩
          have h_nf_d := nf_agreement_from_shared_nf M (Fin.cons y env_M)
            M' (Fin.cons y' env_M') nf_y h_nf_y h_nf_y'
          have h_mu_nf := ih (n + 1) (Fin.cons y env_M) (Fin.cons y' env_M') h_nf_d sub_nf_mu
          rw [h_env_cons] at h_mu_nf; rw [h_env_cons'] at h_mu_nf
          exact ⟨extendPoint y', h_mu_nf.mp he⟩
    · -- M' → M: symmetric
      intro ⟨hM'_atoms, hM'_quant⟩
      constructor
      · intro a
        exact (discrete_muSig_atom_agree env_M env_M' h_atom_sig a).trans (hM'_atoms a)
      · intro sub_nf_mu
        rw [← hM'_quant sub_nf_mu]
        have h_quant_transfer : ∀ (nf_sub : NormalForm sig d (n + 1)),
            (∃ y : M.carrier, nf_eval_nf M d (n + 1) (Fin.cons y env_M) nf_sub) ↔
            (∃ y' : M'.carrier, nf_eval_nf M' d (n + 1) (Fin.cons y' env_M') nf_sub) := by
          intro nf_sub
          have hM_sat := nf_characteristic_satisfies M (d + 1) n env_M
          have hM'_sat := (h_nf_agree (nf_characteristic M (d + 1) n env_M)).mp hM_sat
          obtain ⟨_, hM_q⟩ := hM_sat
          obtain ⟨_, hM'_q⟩ := hM'_sat
          exact (hM_q nf_sub).trans (hM'_q nf_sub).symm
        have h_env_cons2 : ∀ (y : M.carrier),
            (fun (i : Fin (n + 1)) => extendPoint (sig := sig) (M := M)
              (atomMap := atomMap) (r := r) ((Fin.cons y env_M : Fin (n + 1) → M.carrier) i)) =
            Fin.cons (extendPoint y) (fun i => extendPoint (env_M i)) := by
          intro y; funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons]
        have h_env_cons2' : ∀ (y' : M'.carrier),
            (fun (i : Fin (n + 1)) => extendPoint (sig := sig) (M := M')
              (atomMap := atomMap) (r := r) ((Fin.cons y' env_M' : Fin (n + 1) → M'.carrier) i)) =
            Fin.cons (extendPoint y') (fun i => extendPoint (env_M' i)) := by
          intro y'; funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons]
        constructor
        · -- Forward: M → M'
          rintro ⟨e, he⟩
          obtain ⟨y, rfl⟩ := discrete_extended_is_point h_no_gaps_M
            (show ExtendedCarrier M atomMap r from e)
          let nf_y := nf_characteristic M d (n + 1) (Fin.cons y env_M)
          have h_nf_y := nf_characteristic_satisfies M d (n + 1) (Fin.cons y env_M)
          obtain ⟨y', h_nf_y'⟩ := (h_quant_transfer nf_y).mp ⟨y, h_nf_y⟩
          have h_nf_d := nf_agreement_from_shared_nf M (Fin.cons y env_M)
            M' (Fin.cons y' env_M') nf_y h_nf_y h_nf_y'
          have h_mu_nf := ih (n + 1) (Fin.cons y env_M) (Fin.cons y' env_M') h_nf_d sub_nf_mu
          rw [h_env_cons2] at h_mu_nf; rw [h_env_cons2'] at h_mu_nf
          exact ⟨extendPoint y', h_mu_nf.mp he⟩
        · -- Backward: M' → M
          rintro ⟨e', he'⟩
          obtain ⟨y', rfl⟩ := discrete_extended_is_point h_no_gaps_M'
            (show ExtendedCarrier M' atomMap r from e')
          let nf_y' := nf_characteristic M' d (n + 1) (Fin.cons y' env_M')
          have h_nf_y' := nf_characteristic_satisfies M' d (n + 1) (Fin.cons y' env_M')
          obtain ⟨y, h_nf_y⟩ := (h_quant_transfer nf_y').mpr ⟨y', h_nf_y'⟩
          have h_nf_d := nf_agreement_from_shared_nf M (Fin.cons y env_M)
            M' (Fin.cons y' env_M') nf_y' h_nf_y h_nf_y'
          have h_mu_nf := ih (n + 1) (Fin.cons y env_M) (Fin.cons y' env_M') h_nf_d sub_nf_mu
          rw [h_env_cons2] at h_mu_nf; rw [h_env_cons2'] at h_mu_nf
          exact ⟨extendPoint y, h_mu_nf.mpr he'⟩

/-- For discrete orders, depth-d NF agreement on sig implies nf_profile
    agreement at depth d (= NF on muSig at depth d on extendedStructureWithMu). -/
theorem discrete_nf_profile_at_depth {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r d : Nat}
    (h_no_gaps_M : IsEmpty (Gap M.carrier))
    (h_no_gaps_M' : IsEmpty (Gap M'.carrier))
    {x : M.carrier} {x' : M'.carrier}
    (h_nf_agree : ∀ nf : NormalForm sig d 1,
      nf_eval_nf M d 1 (fun _ => x) nf ↔
      nf_eval_nf M' d 1 (fun _ => x') nf) :
    nf_characteristic (extendedStructureWithMu M atomMap r) d 1
      (fun _ => extendPoint x) =
    nf_characteristic (extendedStructureWithMu M' atomMap r) d 1
      (fun _ => extendPoint x') := by
  have h_mu_nf := discrete_muSig_nf_agree (atomMap := atomMap) (r := r)
    h_no_gaps_M h_no_gaps_M' d 1
    (fun _ => x) (fun _ => x') h_nf_agree
  apply nf_eval_unique (extendedStructureWithMu M' atomMap r) d 1
    (fun _ => extendPoint x')
  · exact h_mu_nf (nf_characteristic (extendedStructureWithMu M atomMap r) d 1
      (fun _ => extendPoint x)) |>.mp
      (nf_characteristic_satisfies (extendedStructureWithMu M atomMap r) d 1
        (fun _ => extendPoint x))
  · exact nf_characteristic_satisfies (extendedStructureWithMu M' atomMap r) d 1
      (fun _ => extendPoint x')

/-- For discrete orders, depth-k NF agreement on sig implies nf_profile
    agreement at the half-rank (= NF on muSig at depth 2*(k/2)). -/
theorem discrete_nf_profile_agree {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder M'.carrier] [PredOrder M'.carrier] [NoMaxOrder M'.carrier]
    [NoMinOrder M'.carrier] [IsSuccArchimedean M'.carrier]
    {x : M.carrier} {x' : M'.carrier}
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x')) :
    nf_profile (sig := sig) (atomMap := atomMap) (r := k / 2)
      (extendPoint x) =
    nf_profile (sig := sig) (atomMap := atomMap) (r := k / 2)
      (extendPoint x') := by
  -- nf_profile = nf_characteristic (extendedStructureWithMu) (2 * (k/2)) 1
  unfold nf_profile
  -- Need NF agreement on sig at depth 2*(k/2). Since 2*(k/2) ≤ k, use monotonicity.
  have h_depth_le : 2 * (k / 2) ≤ k := by omega
  have h_nf_agree : ∀ nf : NormalForm sig (2 * (k / 2)) 1,
      nf_eval_nf M (2 * (k / 2)) 1 (fun _ => x) nf ↔
      nf_eval_nf M' (2 * (k / 2)) 1 (fun _ => x') nf := by
    intro nf
    exact nf_agreement_monotone (2 * (k / 2)) k 1 h_depth_le M (fun _ => x) M' (fun _ => x')
      (nf_agreement_from_nf_char_eq h_nf) nf
  exact discrete_nf_profile_at_depth (discrete_no_gaps) (discrete_no_gaps) h_nf_agree

/-- For discrete orders, depth-k NF agreement on sig implies rank_type
    agreement at rank k/2. -/
theorem discrete_rank_type_agree {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder M'.carrier] [PredOrder M'.carrier] [NoMaxOrder M'.carrier]
    [NoMinOrder M'.carrier] [IsSuccArchimedean M'.carrier]
    {x : M.carrier} {x' : M'.carrier}
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x')) :
    rank_type M atomMap (k / 2) (extendPoint x) =
    rank_type M' atomMap (k / 2) (extendPoint x') := by
  -- rank_type is determined by nf_profile (nf_profile_determines_rank_type)
  -- But nf_profile_determines_rank_type works within a single structure.
  -- We need a cross-structure version.
  -- Same nf_profile → same rank_type. The proof: rank_type is determined by
  -- which StaviFormulas of depth ≤ r hold. By nf_profile_determines_stavi_truth,
  -- same nf_profile → same stavi_truth for all A with depth ≤ r.
  -- So we need to show: for all A with stavi_depth A ≤ k/2,
  -- stavi_temporal_truth_mu M atomMap (k/2) (extendPoint x) A ↔
  -- stavi_temporal_truth_mu M' atomMap (k/2) (extendPoint x') A
  -- This follows from FO agreement on muSig at depth 2*(k/2).
  ext A
  simp only [rank_type, Set.mem_setOf_eq]
  constructor
  · intro ⟨hd, hA⟩
    refine ⟨hd, ?_⟩
    -- stavi_temporal_truth_mu is determined by stavi_table_mu_correct
    rw [← stavi_table_mu_correct (extendPoint x) A] at hA
    rw [← stavi_table_mu_correct (extendPoint x') A]
    -- Now need: eval on muSig agrees
    have h_nf_profile := discrete_nf_profile_agree (atomMap := atomMap) h_nf
    -- nf_profile agreement at depth 2*(k/2) gives FO agreement at depth ≤ 2*(k/2)
    have h_fo_depth : (stavi_table_mu atomMap A).quantifier_depth ≤ 2 * (k / 2) :=
      le_trans (stavi_table_mu_depth A)
        (le_trans (stavi_fo_depth_le_twice_depth A) (Nat.mul_le_mul_left 2 hd))
    -- From nf_profile equality, derive NF agreement on muSig at depth 2*(k/2)
    have h_mu_nf_agree : ∀ nf : NormalForm (muSig sig) (2 * (k / 2)) 1,
        nf_eval_nf (extendedStructureWithMu M atomMap (k / 2)) (2 * (k / 2)) 1
          (fun _ => extendPoint x) nf ↔
        nf_eval_nf (extendedStructureWithMu M' atomMap (k / 2)) (2 * (k / 2)) 1
          (fun _ => extendPoint x') nf := by
      intro nf
      exact nf_agreement_from_shared_nf
        (extendedStructureWithMu M atomMap (k / 2)) (fun _ => extendPoint x)
        (extendedStructureWithMu M' atomMap (k / 2)) (fun _ => extendPoint x')
        (nf_profile (extendPoint x))
        (nf_characteristic_satisfies _ _ _ _)
        (h_nf_profile ▸ nf_characteristic_satisfies _ _ _ _)
        nf
    exact (doets_lemma_1_1 (2 * (k / 2)) 1 (stavi_table_mu atomMap A) h_fo_depth
      (extendedStructureWithMu M atomMap (k / 2))
      (extendedStructureWithMu M' atomMap (k / 2))
      (fun _ => extendPoint x) (fun _ => extendPoint x')
      h_mu_nf_agree).mp hA
  · intro ⟨hd, hA⟩
    refine ⟨hd, ?_⟩
    rw [← stavi_table_mu_correct (extendPoint x') A] at hA
    rw [← stavi_table_mu_correct (extendPoint x) A]
    have h_nf_profile := discrete_nf_profile_agree (atomMap := atomMap) h_nf
    have h_fo_depth : (stavi_table_mu atomMap A).quantifier_depth ≤ 2 * (k / 2) :=
      le_trans (stavi_table_mu_depth A)
        (le_trans (stavi_fo_depth_le_twice_depth A) (Nat.mul_le_mul_left 2 hd))
    have h_mu_nf_agree : ∀ nf : NormalForm (muSig sig) (2 * (k / 2)) 1,
        nf_eval_nf (extendedStructureWithMu M atomMap (k / 2)) (2 * (k / 2)) 1
          (fun _ => extendPoint x) nf ↔
        nf_eval_nf (extendedStructureWithMu M' atomMap (k / 2)) (2 * (k / 2)) 1
          (fun _ => extendPoint x') nf := by
      intro nf
      exact nf_agreement_from_shared_nf
        (extendedStructureWithMu M atomMap (k / 2)) (fun _ => extendPoint x)
        (extendedStructureWithMu M' atomMap (k / 2)) (fun _ => extendPoint x')
        (nf_profile (extendPoint x))
        (nf_characteristic_satisfies _ _ _ _)
        (h_nf_profile ▸ nf_characteristic_satisfies _ _ _ _)
        nf
    exact (doets_lemma_1_1 (2 * (k / 2)) 1 (stavi_table_mu atomMap A) h_fo_depth
      (extendedStructureWithMu M atomMap (k / 2))
      (extendedStructureWithMu M' atomMap (k / 2))
      (fun _ => extendPoint x) (fun _ => extendPoint x')
      h_mu_nf_agree).mpr hA

/-! ## Discrete: Eval Equivalence Between M and Extended Structures

For discrete orders, the extended carrier collapses to M.carrier (no gaps).
This section proves that eval on M at actual-point environments is equivalent
to eval on the extended structures at extendPoint environments.
These equivalences are needed for Bridge B: converting formula_agreement
on extended structures back to eval agreement on the original structures. -/

/-- For discrete orders, evaluating a sig formula on M at an actual-point
    environment is equivalent to evaluating its lift on extendedStructure
    at the extendPoint environment.

    This is because for discrete orders, ExtendedCarrier = M.carrier (no gaps),
    so quantifiers range over the same domain. -/
theorem discrete_eval_lift_equiv {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat}
    (h_no_gaps : IsEmpty (Gap M.carrier))
    {n : Nat} (env_M : Fin n → M.carrier)
    (phi : MonadicFormula sig n) :
    eval M env_M phi ↔
    eval (extendedStructure M atomMap r)
      (fun i => extendPoint (env_M i)) phi := by
  induction phi with
  | atom p i =>
    simp only [eval, extendedStructure, extendPoint]
  | lt i j =>
    simp only [eval]
    exact (discrete_extendPoint_lt_iff (env_M i) (env_M j)).symm
  | not α ih =>
    simp only [eval]; exact (ih env_M).not
  | and α β ihα ihβ =>
    simp only [eval]; exact (ihα env_M).and (ihβ env_M)
  | all α ih =>
    simp only [eval]
    constructor
    · intro h e
      obtain ⟨y, rfl⟩ := discrete_extended_is_point h_no_gaps e
      have h1 := ih (Fin.cons y env_M)
      have h_env : (fun i => extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := r)
            ((Fin.cons y env_M : Fin _ → M.carrier) i)) =
          Fin.cons (extendPoint y) (fun i => extendPoint (env_M i)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons]
      rw [h_env] at h1
      exact h1.mp (h y)
    · intro h y
      have h1 := ih (Fin.cons y env_M)
      have h_env : (fun i => extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := r)
            ((Fin.cons y env_M : Fin _ → M.carrier) i)) =
          Fin.cons (extendPoint y) (fun i => extendPoint (env_M i)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons]
      rw [h_env] at h1
      exact h1.mpr (h (extendPoint y))
  | ex α ih =>
    simp only [eval]
    constructor
    · rintro ⟨y, hy⟩
      have h1 := ih (Fin.cons y env_M)
      have h_env : (fun i => extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := r)
            ((Fin.cons y env_M : Fin _ → M.carrier) i)) =
          Fin.cons (extendPoint y) (fun i => extendPoint (env_M i)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons]
      rw [h_env] at h1
      exact ⟨extendPoint y, h1.mp hy⟩
    · rintro ⟨e, he⟩
      obtain ⟨y, rfl⟩ := discrete_extended_is_point h_no_gaps e
      have h1 := ih (Fin.cons y env_M)
      have h_env : (fun i => extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := r)
            ((Fin.cons y env_M : Fin _ → M.carrier) i)) =
          Fin.cons (extendPoint y) (fun i => extendPoint (env_M i)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons]
      rw [h_env] at h1
      exact ⟨y, h1.mpr he⟩

/-- For discrete orders, eval on M equals eval on extendedStructureWithMu
    via liftSigFormula at actual-point environments. Combines
    `discrete_eval_lift_equiv` with `liftSigFormula_eval`. -/
theorem discrete_eval_muSig_equiv {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r n : Nat}
    (h_no_gaps : IsEmpty (Gap M.carrier))
    (env_M : Fin n → M.carrier)
    (phi : MonadicFormula sig n) :
    eval M env_M phi ↔
    eval (extendedStructureWithMu M atomMap r)
      (fun i => extendPoint (env_M i)) (liftSigFormula phi) := by
  rw [liftSigFormula_eval]
  exact discrete_eval_lift_equiv h_no_gaps env_M phi

/-! ## Existential Transfer from NF Agreement

General fact: n-var NF agreement at depth d+1 implies (n+1)-var
existential transfer at depth d. This follows directly from the
quantifier part of the characteristic NF at depth d+1.

This is the key lemma enabling the inductive structure of the
Stavi completeness proof. -/

/-- (n+1)-var existential transfer on sig at depth d follows from n-var
    sig NF agreement at depth d+1. This is a GENERAL fact (not discrete-specific):
    the quantifier part of the depth-(d+1) characteristic NF directly encodes
    the existential transfer at depth d.

    This is the key lemma for the inductive step: once we have NF agreement
    at depth d+1 for an n-var environment, we get existential transfer at
    depth d for all (n+1)-var NF extensions. -/
theorem existential_transfer_from_nf {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    {d n : Nat}
    (env_M : Fin n → M.carrier) (env_M' : Fin n → M'.carrier)
    (h_sig_nf : ∀ nf : NormalForm sig (d + 1) n,
      nf_eval_nf M (d + 1) n env_M nf ↔
      nf_eval_nf M' (d + 1) n env_M' nf) :
    ∀ chi : NormalForm sig d (n + 1),
      (∃ w, nf_eval_nf M d (n + 1) (Fin.cons w env_M) chi) ↔
      (∃ w', nf_eval_nf M' d (n + 1) (Fin.cons w' env_M') chi) := by
  intro chi
  -- The characteristic NF at depth d+1 encodes the existential transfer:
  -- its quantifier part says (∃ x, nf_eval at depth d) ↔ (bool assignment = true)
  have h_sig_char := nf_characteristic_satisfies M (d + 1) n env_M
  have h_sig_M'_sat := (h_sig_nf (nf_characteristic M (d + 1) n env_M)).mp h_sig_char
  obtain ⟨_, h_sig_quant_M⟩ := h_sig_char
  obtain ⟨_, h_sig_quant_M'⟩ := h_sig_M'_sat
  -- Chain: (∃ x, ..._M) ↔ (quant_assgn chi = true) ↔ (∃ x', ..._M')
  exact (h_sig_quant_M chi).trans (h_sig_quant_M' chi).symm

/-! ## Discrete: Formula Agreement from NF

For discrete orders, rank_type agreement at rank k/2 follows from depth-k
1-var NF agreement (via `discrete_rank_type_agree`). Since rank_type is
exactly the set of StaviFormulas of depth ≤ r that hold, rank_type equality
implies stavi_temporal_truth_mu agreement for all formulas of depth ≤ r.
This gives us the formula_agreement component of `ghr93_winning_condition`. -/

/-- For discrete orders, two points with matching depth-k 1-var NFs agree on
    all StaviFormulas of depth ≤ k/2 (formula agreement at rank k/2). -/
theorem discrete_formula_agree_from_nf {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder M'.carrier] [PredOrder M'.carrier] [NoMaxOrder M'.carrier]
    [NoMinOrder M'.carrier] [IsSuccArchimedean M'.carrier]
    {x : M.carrier} {x' : M'.carrier}
    (h_nf : nf_characteristic M k 1 (fun _ => x) =
            nf_characteristic M' k 1 (fun _ => x'))
    (A : StaviFormula) (hA : stavi_depth A ≤ k / 2) :
    stavi_temporal_truth_mu M atomMap (k / 2) (extendPoint x) A ↔
    stavi_temporal_truth_mu M' atomMap (k / 2) (extendPoint x') A := by
  have h_rt := discrete_rank_type_agree (atomMap := atomMap) h_nf
  -- rank_type equality at k/2 means: for all A with stavi_depth A ≤ k/2,
  -- A ∈ rank_type M ↔ A ∈ rank_type M'
  have h_mem : ∀ B : StaviFormula, stavi_depth B ≤ k / 2 →
      (stavi_temporal_truth_mu M atomMap (k / 2) (extendPoint x) B ↔
       stavi_temporal_truth_mu M' atomMap (k / 2) (extendPoint x') B) := by
    intro B hB
    have h1 : B ∈ rank_type M atomMap (k / 2) (extendPoint x) ↔
              B ∈ rank_type M' atomMap (k / 2) (extendPoint x') := by
      rw [h_rt]
    simp only [rank_type, Set.mem_setOf_eq] at h1
    exact ⟨fun hM => (h1.mp ⟨hB, hM⟩).2, fun hM' => (h1.mpr ⟨hB, hM'⟩).2⟩
  exact h_mem A hA

/-- For discrete orders, gap/point agreement is trivial: all elements of
    ExtendedCarrier are actual points (no gaps). -/
theorem discrete_gap_point_trivial {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat}
    (h_no_gaps_M : IsEmpty (Gap M.carrier))
    (h_no_gaps_M' : IsEmpty (Gap M'.carrier))
    (x : M.carrier) (x' : M'.carrier) :
    (IsPoint (extendPoint (sig := sig) (M := M) (atomMap := atomMap)
      (r := r) x) ↔
     IsPoint (extendPoint (sig := sig) (M := M') (atomMap := atomMap)
      (r := r) x')) ∧
    (IsGap (extendPoint (sig := sig) (M := M) (atomMap := atomMap)
      (r := r) x) ↔
     IsGap (extendPoint (sig := sig) (M := M') (atomMap := atomMap)
      (r := r) x')) :=
  ⟨⟨fun _ => ⟨x', rfl⟩, fun _ => ⟨x, rfl⟩⟩,
   ⟨fun h => absurd h (discrete_extended_not_isGap h_no_gaps_M (extendPoint x)),
    fun h => absurd h (discrete_extended_not_isGap h_no_gaps_M' (extendPoint x'))⟩⟩

/-! ## Discrete: Game at Rank k/2 for n=0

For discrete orders, we build `ghr93_duplicator_wins` at rank k/2 with
n=0 selections directly from the hypotheses of `nf_2var_existential_transfer`.

The game with n=0 has:
- Round 1: vacuous (no selections)
- Round 2: for any actual b' in [x',t'], find b in [x,t] with the 3-position
  winning condition at (x, b, t) / (x', b', t').

The key lemma: zone_match_witness provides b with matching 1-var NF and
orderings. For discrete orders, `discrete_rank_type_agree` +
`discrete_formula_agree_from_nf` convert the NF match to formula_agreement.
`discrete_gap_point_trivial` handles gap/point status. -/

/-- For discrete orders, winning condition at the 3-element game tuple
    (x, b, t) / (x', b', t') follows from pairwise depth-k 1-var NF
    agreement and ordering agreement. The n=0 game_tuple has indices:
    0→x, 1→extendPoint(b), 2→t. -/
theorem discrete_winning_condition_0 {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder M'.carrier] [PredOrder M'.carrier] [NoMaxOrder M'.carrier]
    [NoMinOrder M'.carrier] [IsSuccArchimedean M'.carrier]
    {x t : M.carrier} {x' t' : M'.carrier} {b : M.carrier} {b' : M'.carrier}
    (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
              nf_characteristic M' k 1 (fun _ => x'))
    (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
              nf_characteristic M' k 1 (fun _ => t'))
    (h_nf_b : nf_characteristic M k 1 (fun _ => b) =
              nf_characteristic M' k 1 (fun _ => b'))
    (h_xb : (extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) x <
             extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) b ↔
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) x' <
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) b') ∧
            (extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) x =
             extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) b ↔
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) x' =
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) b'))
    (h_xt : (extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) x <
             extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) t ↔
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) x' <
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) t') ∧
            (extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) x =
             extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) t ↔
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) x' =
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) t'))
    (h_bt : (extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) b <
             extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) t ↔
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) b' <
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) t') ∧
            (extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) b =
             extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) t ↔
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) b' =
             extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) t'))
    (a : Fin 0 → ExtendedCarrier M atomMap (k / 2))
    (a' : Fin 0 → ExtendedCarrier M' atomMap (k / 2)) :
    ghr93_winning_condition 0
      (game_tuple (extendPoint x) (extendPoint t) a b)
      (game_tuple (extendPoint x') (extendPoint t') a' b') := by
  -- Abbreviations for game_tuple rewriting
  set tM := game_tuple (extendPoint x) (extendPoint t) a b with tM_def
  set tN := game_tuple (extendPoint x') (extendPoint t') a' b' with tN_def
  -- Key game_tuple equalities for the 3-element tuple (n=0: indices 0,1,2)
  have tM0 : tM ⟨0, by omega⟩ = extendPoint x := game_tuple_zero_eq _ _ _ _
  have tM1 : tM ⟨1, by omega⟩ = extendPoint b := game_tuple_b_eq _ _ _ _
  have tM2 : tM ⟨2, by omega⟩ = extendPoint t := game_tuple_y_eq _ _ _ _
  have tN0 : tN ⟨0, by omega⟩ = extendPoint x' := game_tuple_zero_eq _ _ _ _
  have tN1 : tN ⟨1, by omega⟩ = extendPoint b' := game_tuple_b_eq _ _ _ _
  have tN2 : tN ⟨2, by omega⟩ = extendPoint t' := game_tuple_y_eq _ _ _ _
  refine ⟨?_, ?_, ?_⟩
  · -- same_order_type: all pairs (i,j) from {0,1,2}
    intro ⟨i, hi⟩ ⟨j, hj⟩
    rw [tM_def, tN_def]
    -- Helper to reverse order iffs on ExtendedCarrier
    have reverse_ord :
        ∀ {a b : ExtendedCarrier M atomMap (k / 2)} {a' b' : ExtendedCarrier M' atomMap (k / 2)},
        (a < b ↔ a' < b') ∧ (a = b ↔ a' = b') →
        (b < a ↔ b' < a') ∧ (b = a ↔ b' = a') := by
      intro a b a' b' ⟨hlt, heq⟩
      constructor
      · constructor
        · intro hba
          rcases lt_trichotomy a' b' with h1 | h1 | h1
          · exact absurd (hlt.mpr h1) (not_lt.mpr (le_of_lt hba))
          · exact absurd hba (not_lt.mpr (le_of_eq (heq.mpr h1)))
          · exact h1
        · intro hb'a'
          rcases lt_trichotomy a b with h1 | h1 | h1
          · exact absurd (hlt.mp h1) (not_lt.mpr (le_of_lt hb'a'))
          · exact absurd hb'a' (not_lt.mpr (le_of_eq (heq.mp h1)))
          · exact h1
      · exact ⟨fun h' => (heq.mp h'.symm).symm, fun h' => (heq.mpr h'.symm).symm⟩
    match i, hi, j, hj with
    | 0, _, 0, _ => rw [game_tuple_zero_eq, game_tuple_zero_eq]; exact ⟨iff_of_false (lt_irrefl _) (lt_irrefl _), iff_of_true rfl rfl⟩
    | 0, _, 1, _ => rw [game_tuple_zero_eq, game_tuple_b_eq, game_tuple_zero_eq, game_tuple_b_eq]; exact h_xb
    | 0, _, 2, _ => rw [game_tuple_zero_eq, game_tuple_y_eq, game_tuple_zero_eq, game_tuple_y_eq]; exact h_xt
    | 1, _, 0, _ => rw [game_tuple_b_eq, game_tuple_zero_eq, game_tuple_b_eq, game_tuple_zero_eq]; exact reverse_ord h_xb
    | 1, _, 1, _ => rw [game_tuple_b_eq, game_tuple_b_eq]; exact ⟨iff_of_false (lt_irrefl _) (lt_irrefl _), iff_of_true rfl rfl⟩
    | 1, _, 2, _ => rw [game_tuple_b_eq, game_tuple_y_eq, game_tuple_b_eq, game_tuple_y_eq]; exact h_bt
    | 2, _, 0, _ => rw [game_tuple_y_eq, game_tuple_zero_eq, game_tuple_y_eq, game_tuple_zero_eq]; exact reverse_ord h_xt
    | 2, _, 1, _ => rw [game_tuple_y_eq, game_tuple_b_eq, game_tuple_y_eq, game_tuple_b_eq]; exact reverse_ord h_bt
    | 2, _, 2, _ => rw [game_tuple_y_eq, game_tuple_y_eq]; exact ⟨iff_of_false (lt_irrefl _) (lt_irrefl _), iff_of_true rfl rfl⟩
  · -- gap_point_agreement: all points are actual
    intro ⟨i, hi⟩
    rw [tM_def, tN_def]
    match i, hi with
    | 0, _ => rw [game_tuple_zero_eq, game_tuple_zero_eq]
              exact discrete_gap_point_trivial discrete_no_gaps discrete_no_gaps _ _
    | 1, _ => rw [game_tuple_b_eq, game_tuple_b_eq]
              exact discrete_gap_point_trivial discrete_no_gaps discrete_no_gaps _ _
    | 2, _ => rw [game_tuple_y_eq, game_tuple_y_eq]
              exact discrete_gap_point_trivial discrete_no_gaps discrete_no_gaps _ _
  · -- formula_agreement: stavi_truth_mu agrees at all positions
    intro ⟨i, hi⟩ A hA
    rw [tM_def, tN_def]
    match i, hi with
    | 0, _ => rw [game_tuple_zero_eq]; exact discrete_formula_agree_from_nf h_nf_x A hA
    | 1, _ => rw [game_tuple_b_eq]; exact discrete_formula_agree_from_nf h_nf_b A hA
    | 2, _ => rw [game_tuple_y_eq]; exact discrete_formula_agree_from_nf h_nf_t A hA

/-! ## Discrete: Master Bridge A — NF Hypotheses to decomposition_agreement

For discrete orders, convert the hypotheses of `nf_2var_existential_transfer`
(1-var NF agreement at depth k, ordering, interval/above/below type agreement)
into `decomposition_agreement` at rank k/2 with n=0.

This is the "Bridge A" theorem: NF world → EF game world. Combined with the
existing `ghr93_decomposition_implies_game` (Bridge B forward direction),
this opens the path to the discrete game bypass strategy.

### Construction

1. Boundary type agreement: `discrete_rank_type_agree` gives rank-r types at
   x/x' and t/t' from their depth-k 1-var NF equality.

2. Forward direction (M→M'): for n=0, the only nontrivial condition is the
   point challenge. Given b' in [x',t'] on M', we use `zone_match_witness`
   (symmetric direction) to find b in M with matching 1-var NF and orderings,
   then `discrete_winning_condition_0` gives the full winning condition for
   the 3-element tuple (x,b,t)/(x',b',t').

3. Backward direction (M'→M): symmetric, using `zone_match_witness` directly.

The key insight: `zone_match_witness` already handles ALL zone cases
(below, above, interval, equality) without requiring sub-interval splitting,
because the discrete order has no gaps and the interval types determine
where each point lives. -/

/-- Convert a pair of `<` iffs between two linear orders (M, M') into the
    `(<,)` and `(=,)` iff pair needed by `discrete_winning_condition_0`,
    lifted to ExtendedCarrier via `discrete_extendPoint_lt_iff`. -/
private theorem extendPair_iff {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat}
    (a b : M.carrier) (a' b' : M'.carrier)
    (h_ab_lt : (a < b ↔ a' < b')) (h_ba_lt : (b < a ↔ b' < a')) :
    ((extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) a <
      extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) b) ↔
     (extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) a' <
      extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) b')) ∧
    ((extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) a =
      extendPoint (sig := sig) (M := M) (atomMap := atomMap) (r := k / 2) b) ↔
     (extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) a' =
      extendPoint (sig := sig) (M := M') (atomMap := atomMap) (r := k / 2) b')) := by
  constructor
  · -- `<` direction: reduce to M.carrier via discrete_extendPoint_lt_iff
    calc
      (extendPoint a < extendPoint b) ↔ (a < b) := discrete_extendPoint_lt_iff a b
      _ ↔ (a' < b') := h_ab_lt
      _ ↔ (extendPoint a' < extendPoint b') := (discrete_extendPoint_lt_iff a' b').symm
  · -- `=` direction: derive from `<` iffs via trichotomy
    constructor
    · intro h
      have h_eq : a = b := Sum.inl_injective h
      subst h_eq
      rcases lt_trichotomy a' b' with hlt | heq | hgt
      · have : a < a := h_ab_lt.mpr hlt
        exact absurd this (lt_irrefl _)
      · exact congrArg Sum.inl heq
      · have : a < a := h_ba_lt.mpr hgt
        exact absurd this (lt_irrefl _)
    · intro h
      have h_eq : a' = b' := Sum.inl_injective h
      subst h_eq
      rcases lt_trichotomy a b with hlt | heq | hgt
      · have : a' < a' := h_ab_lt.mp hlt
        exact absurd this (lt_irrefl _)
      · exact congrArg Sum.inl heq
      · have : a' < a' := h_ba_lt.mp hgt
        exact absurd this (lt_irrefl _)

/-- **Bridge A**: For discrete orders, the hypotheses of `nf_2var_existential_transfer`
    imply `decomposition_agreement` at rank floor(k/2) with n=0 selections.

    This is the master theorem connecting the NF-based bridge hypotheses
    to the EF game world. Combined with `ghr93_decomposition_implies_game`,
    this provides Duplicator's winning strategy at rank k/2, which through
    Bridge B (Phase 2) yields the existential transfer at depth k. -/
theorem discrete_nf_to_decomposition_agreement {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {k : Nat}
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
    [SuccOrder M'.carrier] [PredOrder M'.carrier] [NoMaxOrder M'.carrier]
    [NoMinOrder M'.carrier] [IsSuccArchimedean M'.carrier]
    (x t : M.carrier) (x' t' : M'.carrier)
    (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
              nf_characteristic M' k 1 (fun _ => x'))
    (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
              nf_characteristic M' k 1 (fun _ => t'))
    (h_order_xt : (x < t ↔ x' < t') ∧ (t < x ↔ t' < x'))
    (h_interval_above : t < x →
      interval_nf_types M k t x = interval_nf_types M' k t' x')
    (h_interval_below : x < t →
      interval_nf_types M k x t = interval_nf_types M' k x' t')
    (h_above_max : (fun nf_u => ∃ u, (max x t < u) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
                   (fun nf_u => ∃ u, (max x' t' < u) ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u))
    (h_below_min : (fun nf_u => ∃ u, (u < min x t) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) =
                   (fun nf_u => ∃ u, (u < min x' t') ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u)) :
    decomposition_agreement M M' atomMap 0 (k / 2)
      (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t') := by
  set r := k / 2
  let epX : ExtendedCarrier M atomMap r := extendPoint (atomMap := atomMap) (r := r) x
  let epT : ExtendedCarrier M atomMap r := extendPoint (atomMap := atomMap) (r := r) t
  let epX' : ExtendedCarrier M' atomMap r := extendPoint (atomMap := atomMap) (r := r) x'
  let epT' : ExtendedCarrier M' atomMap r := extendPoint (atomMap := atomMap) (r := r) t'
  -- Boundary type agreement via discrete_rank_type_agree
  have h_type_x : rank_type M atomMap r (extendPoint (atomMap := atomMap) (r := r) x) =
      rank_type M' atomMap r (extendPoint (atomMap := atomMap) (r := r) x') :=
    discrete_rank_type_agree (atomMap := atomMap) h_nf_x
  have h_type_t : rank_type M atomMap r (extendPoint (atomMap := atomMap) (r := r) t) =
      rank_type M' atomMap r (extendPoint (atomMap := atomMap) (r := r) t') :=
    discrete_rank_type_agree (atomMap := atomMap) h_nf_t
  -- Ordering pair for x/t: needed for the winning condition
  have h_xt_pair : ((extendPoint (atomMap := atomMap) (r := r) x : ExtendedCarrier M atomMap r) <
                     extendPoint (atomMap := atomMap) (r := r) t ↔
                     (extendPoint (atomMap := atomMap) (r := r) x' : ExtendedCarrier M' atomMap r) <
                     extendPoint (atomMap := atomMap) (r := r) t') ∧
                   ((extendPoint (atomMap := atomMap) (r := r) x : ExtendedCarrier M atomMap r) =
                     extendPoint (atomMap := atomMap) (r := r) t ↔
                     (extendPoint (atomMap := atomMap) (r := r) x' : ExtendedCarrier M' atomMap r) =
                     extendPoint (atomMap := atomMap) (r := r) t') :=
    extendPair_iff x t x' t' h_order_xt.1 h_order_xt.2
  -- Symmetric hypotheses for M'→M direction (needed for forward point challenge)
  have h_nf_x' : nf_characteristic M' k 1 (fun _ => x') =
                 nf_characteristic M k 1 (fun _ => x) := h_nf_x.symm
  have h_nf_t' : nf_characteristic M' k 1 (fun _ => t') =
                 nf_characteristic M k 1 (fun _ => t) := h_nf_t.symm
  have h_order_xt' : (x' < t' ↔ x < t) ∧ (t' < x' ↔ t < x) :=
    ⟨h_order_xt.1.symm, h_order_xt.2.symm⟩
  have h_interval_above' : t' < x' → interval_nf_types M' k t' x' = interval_nf_types M k t x :=
    fun h' => (h_interval_above (h_order_xt.2.mpr h')).symm
  have h_interval_below' : x' < t' → interval_nf_types M' k x' t' = interval_nf_types M k x t :=
    fun h' => (h_interval_below (h_order_xt.1.mpr h')).symm
  have h_above_max' : (fun nf_u => ∃ u, (max x' t' < u) ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u) =
                      (fun nf_u => ∃ u, (max x t < u) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) :=
    h_above_max.symm
  have h_below_min' : (fun nf_u => ∃ u, (u < min x' t') ∧ nf_eval_nf M' k 1 (fun _ => u) nf_u) =
                      (fun nf_u => ∃ u, (u < min x t) ∧ nf_eval_nf M k 1 (fun _ => u) nf_u) :=
    h_below_min.symm
  -- Helper: from zone_match_witness ordering + inClosedInterval on M', derive inClosedInterval on M
  have h_zone_to_inClosed (b' : M'.carrier) (b : M.carrier)
      (hb' : inClosedInterval (r := r) (extendPoint (atomMap := atomMap) (r := r) x')
               (extendPoint (atomMap := atomMap) (r := r) t')
               (extendPoint (atomMap := atomMap) (r := r) b'))
      (h_zone_bx : (b < x ↔ b' < x')) (h_zone_xb : (x < b ↔ x' < b'))
      (h_zone_bt : (b < t ↔ b' < t')) (h_zone_tb : (t < b ↔ t' < b')) :
      inClosedInterval (r := r) (extendPoint (atomMap := atomMap) (r := r) x)
        (extendPoint (atomMap := atomMap) (r := r) t)
        (extendPoint (atomMap := atomMap) (r := r) b) := by
    have hx'b' := (discrete_inClosedInterval_iff (sig := sig) x' t' b').mp hb' |>.1
    have hb't' := (discrete_inClosedInterval_iff (sig := sig) x' t' b').mp hb' |>.2
    have hx_le_b : x ≤ b := by
      by_contra h
      have : b < x := lt_of_not_ge h
      exact not_lt.mpr hx'b' (h_zone_bx.mp this)
    have hb_le_t : b ≤ t := by
      by_contra h
      have : t < b := lt_of_not_ge h
      exact not_lt.mpr hb't' (h_zone_tb.mp this)
    rw [discrete_inClosedInterval_iff]
    exact ⟨hx_le_b, hb_le_t⟩
  -- Forward (M→M')
  refine ⟨h_type_x, h_type_t, ?_, ?_⟩
  · -- Forward direction: for every a:Fin 0→ExtCarr_M, find a':Fin 0→ExtCarr_M'
    intro a ha
    -- a is trivial (Fin 0); a' similarly
    let a' : Fin 0 → ExtendedCarrier M' atomMap r := fun i => i.elim0
    have ha'_in : ∀ i, inClosedInterval (r := r)
        (extendPoint (atomMap := atomMap) (r := r) x')
        (extendPoint (atomMap := atomMap) (r := r) t') (a' i) :=
      fun i => i.elim0
    have htypes : ∀ i, rank_type M atomMap r (a i) = rank_type M' atomMap r (a' i) :=
      fun i => i.elim0
    have hgp : ∀ i, (IsPoint (a i) ↔ IsPoint (a' i)) ∧ (IsGap (a i) ↔ IsGap (a' i)) :=
      fun i => i.elim0
    have hord : ∀ i j, (a i < a j ↔ a' i < a' j) ∧ (a i = a j ↔ a' i = a' j) :=
      fun i j => i.elim0
    -- Point challenge: given b' in [x',t'] on M', find b in [x,t] on M
    have hpt : ∀ (b' : M'.carrier), inClosedInterval (r := r)
        (extendPoint (atomMap := atomMap) (r := r) x')
        (extendPoint (atomMap := atomMap) (r := r) t')
        (extendPoint (atomMap := atomMap) (r := r) b') →
        ∃ (b : M.carrier), inClosedInterval (r := r)
          (extendPoint (atomMap := atomMap) (r := r) x)
          (extendPoint (atomMap := atomMap) (r := r) t)
          (extendPoint (atomMap := atomMap) (r := r) b) ∧
          ghr93_winning_condition 0
            (game_tuple (r := r) epX epT a b) (game_tuple (r := r) epX' epT' a' b') := by
      intro b' hb'
      -- Use zone_match_witness in M'→M direction to find matching b
      obtain ⟨b, h_nf_b', h_bx, h_xb, h_bt, h_tb⟩ :=
        zone_match_witness k x' t' x t b' h_nf_x' h_nf_t' h_order_xt'
          h_interval_above' h_interval_below' h_above_max' h_below_min'
      have h_nf_b : nf_characteristic M k 1 (fun _ => b) = nf_characteristic M' k 1 (fun _ => b') := by
        simpa using h_nf_b'.symm
      have h_xb_pair := extendPair_iff (k := k) (atomMap := atomMap) x b x' b' h_xb.symm h_bx.symm
      have h_bt_pair := extendPair_iff (k := k) (atomMap := atomMap) b t b' t' h_bt.symm h_tb.symm
      -- b is in the interval [x,t]
      have h_in_closed : inClosedInterval (r := r)
          (extendPoint (atomMap := atomMap) (r := r) x)
          (extendPoint (atomMap := atomMap) (r := r) t)
          (extendPoint (atomMap := atomMap) (r := r) b) :=
        h_zone_to_inClosed b' b hb' h_bx.symm h_xb.symm h_bt.symm h_tb.symm
      -- Apply discrete_winning_condition_0 with all pairwise conditions
      have h_win := discrete_winning_condition_0 (atomMap := atomMap) h_nf_x h_nf_t h_nf_b
        h_xb_pair h_xt_pair h_bt_pair a a'
      exact ⟨b, h_in_closed, h_win⟩
    exact ⟨a', ha'_in, htypes, hgp, hord, hpt⟩
  · -- Backward direction (M'→M): symmetric, use zone_match_witness in M→M' direction
    intro a' ha'
    let a : Fin 0 → ExtendedCarrier M atomMap r := fun i => i.elim0
    have ha_in : ∀ i, inClosedInterval (r := r)
        (extendPoint (atomMap := atomMap) (r := r) x)
        (extendPoint (atomMap := atomMap) (r := r) t) (a i) :=
      fun i => i.elim0
    have htypes : ∀ i, rank_type M atomMap r (a i) = rank_type M' atomMap r (a' i) :=
      fun i => i.elim0
    have hgp : ∀ i, (IsPoint (a i) ↔ IsPoint (a' i)) ∧ (IsGap (a i) ↔ IsGap (a' i)) :=
      fun i => i.elim0
    have hord : ∀ i j, (a i < a j ↔ a' i < a' j) ∧ (a i = a j ↔ a' i = a' j) :=
      fun i j => i.elim0
    have hpt : ∀ (b : M.carrier), inClosedInterval (r := r)
        (extendPoint (atomMap := atomMap) (r := r) x)
        (extendPoint (atomMap := atomMap) (r := r) t)
        (extendPoint (atomMap := atomMap) (r := r) b) →
        ∃ (b' : M'.carrier), inClosedInterval (r := r)
          (extendPoint (atomMap := atomMap) (r := r) x')
          (extendPoint (atomMap := atomMap) (r := r) t')
          (extendPoint (atomMap := atomMap) (r := r) b') ∧
          ghr93_winning_condition 0
            (game_tuple (r := r) epX epT a b) (game_tuple (r := r) epX' epT' a' b') := by
      intro b hb
      -- Use zone_match_witness in M→M' direction to find matching b'
      obtain ⟨b', h_nf_b, h_bx, h_xb, h_bt, h_tb⟩ :=
        zone_match_witness k x t x' t' b h_nf_x h_nf_t h_order_xt
          h_interval_above h_interval_below h_above_max h_below_min
      -- Ordering pairs for (x,b), (b,t)
      have h_xb_pair := extendPair_iff (k := k) (atomMap := atomMap) x b x' b' h_xb h_bx
      have h_bt_pair := extendPair_iff (k := k) (atomMap := atomMap) b t b' t' h_bt h_tb
      -- b' is in the interval [x',t']
      have h_in_closed' : inClosedInterval (r := r)
          (extendPoint (atomMap := atomMap) (r := r) x')
          (extendPoint (atomMap := atomMap) (r := r) t')
          (extendPoint (atomMap := atomMap) (r := r) b') := by
        have hx_le_b' : x' ≤ b' := by
          by_contra h
          have : b' < x' := lt_of_not_ge h
          have hbx := (discrete_inClosedInterval_iff (sig := sig) x t b).mp hb |>.1
          exact not_lt.mpr hbx (h_bx.mpr this)
        have hb'_le_t' : b' ≤ t' := by
          by_contra h
          have : t' < b' := lt_of_not_ge h
          have hbt := (discrete_inClosedInterval_iff (sig := sig) x t b).mp hb |>.2
          exact not_lt.mpr hbt (h_tb.mpr this)
        rw [discrete_inClosedInterval_iff]; exact ⟨hx_le_b', hb'_le_t'⟩
      -- Apply discrete_winning_condition_0
      have h_win := discrete_winning_condition_0 (atomMap := atomMap) h_nf_x h_nf_t h_nf_b
        h_xb_pair h_xt_pair h_bt_pair a a'
      exact ⟨b', h_in_closed', h_win⟩
    exact ⟨a, ha_in, htypes, hgp, hord, hpt⟩

end Bimodal.Metalogic.WeakCanonical
