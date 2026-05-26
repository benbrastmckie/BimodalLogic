import Bimodal.Metalogic.WeakCanonical.EFGames.Defs

/-!
# Type Formulas and Mu-Relativized Truth

Type formulas and mu-relativized truth for rank-embedding transfer.
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Rank Embedding Infrastructure

When r ≤ r', every r-definable gap is also r'-definable (the defining formula
still has depth ≤ r ≤ r'). This gives an order-preserving embedding
`rank_embed : ExtendedCarrier M atomMap r → ExtendedCarrier M atomMap r'`
that is the identity on points and maps r-definable gaps to r'-definable gaps
(same underlying cut, weaker rank bound).

GHR93 Theorem 6 uses rank variation: the forward game uses rank r+4n while
the backward game uses rank r. The rank embedding mediates between these
two carrier types.

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Theorem 6
- Task 155 plan: Phase 4C prerequisite
-/

/-- If a gap is r-definable, then it is r'-definable for any r' ≥ r.
    The defining formula still has depth ≤ r ≤ r'. -/
theorem r_definable_gap_mono {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {g : Gap M.carrier} {r r' : Nat} (h : r ≤ r')
    (hg : r_definable_gap M atomMap g r) :
    r_definable_gap M atomMap g r' := by
  obtain ⟨D, hd, hdef⟩ := hg
  exact ⟨D, le_trans hd h, hdef⟩

/-- Embed an r-definable gap into the set of r'-definable gaps (r ≤ r').
    The underlying cut is unchanged; only the rank bound is weakened. -/
def rank_embed_gap {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') :
    RDefinableGap M atomMap r → RDefinableGap M atomMap r' :=
  fun g => ⟨g.val, r_definable_gap_mono h g.prop⟩

/-- Order-preserving embedding from ExtendedCarrier at rank r to rank r'
    (when r ≤ r'). Points map to themselves (id on M.carrier). Gaps map to
    the same gap with a weaker rank bound (rank_embed_gap). -/
def rank_embed {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') :
    ExtendedCarrier M atomMap r → ExtendedCarrier M atomMap r' :=
  Sum.map id (rank_embed_gap h)

/-- rank_embed maps points to points. -/
theorem rank_embed_point {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') (x : M.carrier) :
    rank_embed h (extendPoint x) =
    (extendPoint x : ExtendedCarrier M atomMap r') := by
  simp [rank_embed, extendPoint, Sum.map]

/-- rank_embed maps gaps to gaps. -/
theorem rank_embed_gap_eq {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') (g : RDefinableGap M atomMap r) :
    rank_embed h (Sum.inr g) =
    Sum.inr (rank_embed_gap h g) := by
  simp [rank_embed, Sum.map]

/-- rank_embed preserves the IsPoint predicate. -/
theorem rank_embed_isPoint {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') (e : ExtendedCarrier M atomMap r) :
    IsPoint (rank_embed h e) ↔ IsPoint e := by
  cases e with
  | inl x =>
    simp [rank_embed, Sum.map, IsPoint, extendPoint]
  | inr g =>
    simp [rank_embed, Sum.map, IsPoint]

/-- The underlying gap cut is preserved by rank_embed_gap. -/
theorem rank_embed_gap_cut {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') (g : RDefinableGap M atomMap r) :
    (rank_embed_gap h g).val.cut = g.val.cut := rfl

/-- rank_embed preserves ≤. Since the ordering on ExtendedCarrier is defined
    by M's order (for point-point), cut membership (for point-gap), and cut
    inclusion (for gap-gap), and rank_embed is id on points and preserves
    the cut of gaps, the ordering is trivially preserved. -/
theorem rank_embed_le {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') (a b : ExtendedCarrier M atomMap r) :
    rank_embed h a ≤ rank_embed h b ↔ a ≤ b := by
  cases a with
  | inl x =>
    cases b with
    | inl y =>
      simp [rank_embed, Sum.map, extendedLE]
      show x ≤ y ↔ x ≤ y
      exact Iff.rfl
    | inr g =>
      simp [rank_embed, Sum.map, extendedLE, rank_embed_gap]
      show x ∈ (rank_embed_gap h g).val.cut ↔ x ∈ g.val.cut
      rw [rank_embed_gap_cut]
  | inr g =>
    cases b with
    | inl y =>
      simp [rank_embed, Sum.map, extendedLE, rank_embed_gap]
      show y ∉ (rank_embed_gap h g).val.cut ↔ y ∉ g.val.cut
      rw [rank_embed_gap_cut]
    | inr g' =>
      simp [rank_embed, Sum.map, extendedLE, rank_embed_gap]
      show (rank_embed_gap h g).val.cut ⊆ (rank_embed_gap h g').val.cut ↔
           g.val.cut ⊆ g'.val.cut
      simp [rank_embed_gap_cut]

/-- rank_embed preserves <. -/
theorem rank_embed_lt {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') (a b : ExtendedCarrier M atomMap r) :
    rank_embed h a < rank_embed h b ↔ a < b := by
  simp only [lt_iff_le_not_le]
  constructor
  · intro ⟨hle, hnle⟩
    exact ⟨(rank_embed_le h a b).mp hle,
           fun hba => hnle ((rank_embed_le h b a).mpr hba)⟩
  · intro ⟨hle, hnle⟩
    exact ⟨(rank_embed_le h a b).mpr hle,
           fun hba => hnle ((rank_embed_le h b a).mp hba)⟩

/-- rank_embed is injective: if two rank-r elements map to the same rank-r'
    element, they are equal. This follows because rank_embed = Sum.map id f
    where f (rank_embed_gap) preserves the underlying Gap value. -/
theorem rank_embed_injective {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') (a b : ExtendedCarrier M atomMap r)
    (hab : rank_embed h a = rank_embed h b) : a = b := by
  have : Function.Injective (rank_embed h : ExtendedCarrier M atomMap r →
      ExtendedCarrier M atomMap r') := by
    rw [rank_embed, Sum.map_injective]
    exact ⟨Function.injective_id, fun ga gb heq => by
      simp [rank_embed_gap] at heq
      exact Subtype.ext heq⟩
  exact this hab

/-- Variant of rank_embed_injective: contrapositive form.
    If two rank-r elements are distinct, their rank-embeddings are distinct. -/
theorem rank_embed_ne {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') (a b : ExtendedCarrier M atomMap r)
    (hab : a ≠ b) : rank_embed h a ≠ rank_embed h b :=
  fun heq => hab (rank_embed_injective h a b heq)

/-! ## Relativized Formulas and Type Formulas (GHR93 Definitions 8.4, 8.8)

The extended structure M_r needs to become an OrderedMonadicStructure so that
temporal formulas can be evaluated on it. We define:

1. `extendedStructure` — M_r as an OrderedMonadicStructure (predicates at gaps are false)
2. `mu_holds` — the mu predicate distinguishing actual points from gaps
3. `stavi_temporal_truth_mu` — evaluation with temporal connectives relativized to mu-points
4. `rank_type` — the complete rank-r type at a position (GHR93 Def 8.8)
5. `interval_types` — types realized in an open interval (GHR93 Def 8.8)

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Definitions 8.4, 8.8
- Task 155 plan: Phase 4B, Task 4B.3
-/

/-- The extended structure M_r as an OrderedMonadicStructure.
    Predicates at gap positions are defined to be false (gaps have no intrinsic
    predicate values). Predicates at actual points inherit from M.
    The linear order is the interleaved order from `extendedLinearOrder`. -/
noncomputable def extendedStructure {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (r : Nat) :
    OrderedMonadicStructure sig where
  carrier := ExtendedCarrier M atomMap r
  interp := fun p e => match e with
    | .inl x => M.interp p x
    | .inr _ => False  -- gaps have no predicate values
  carrier_order := extendedLinearOrder

/-- Extended signature adding a mu predicate (GHR93 p.111: "h'(mu) = M").
    The new predicate `Sum.inr ()` distinguishes actual points from gaps. -/
def muSig (sig : MonadicSignature) : MonadicSignature where
  preds := sig.preds ⊕ Unit

/-- Extended structure with mu as an explicit predicate over `muSig sig`.
    At actual points (Sum.inl x): mu = true, sig predicates inherit from M.
    At gaps (Sum.inr g): mu = false, sig predicates = false. -/
noncomputable def extendedStructureWithMu {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (r : Nat) :
    OrderedMonadicStructure (muSig sig) where
  carrier := ExtendedCarrier M atomMap r
  interp := fun p e => match p with
    | .inl p' => (extendedStructure M atomMap r).interp p' e
    | .inr () => IsPoint e
  carrier_order := extendedLinearOrder

/-- The mu predicate: true at actual points, false at gaps.
    In GHR93: h'(mu) = M (the set of actual points in M_r). -/
def mu_holds {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    (e : ExtendedCarrier M atomMap r) : Prop :=
  IsPoint e

/-- A point of M is a mu-point in the extended structure. -/
theorem mu_holds_point {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat} (x : M.carrier) :
    mu_holds (extendPoint (sig := sig) (atomMap := atomMap) (r := r) x) := by
  exact ⟨x, rfl⟩

/-- A gap is not a mu-point. -/
theorem not_mu_holds_gap {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    (g : RDefinableGap M atomMap r) :
    ¬ mu_holds (Sum.inr g : ExtendedCarrier M atomMap r) := by
  intro ⟨x, hx⟩
  exact absurd hx Sum.inr_ne_inl

/-! ### Mu-Relativized Temporal Truth (GHR93 Definition 8.4)

For a StaviFormula A, the mu-relativized evaluation A^mu at a position t
in M_r restricts all temporal quantification to mu-points (actual points
from M). Concretely:

- At atoms: use the extended structure's interpretation (true at points, false at gaps)
- U^mu(A,B) at t: ∃ s > t with mu(s) ∧ A^mu(s), and ∀ u ∈ (t,s) with mu(u), B^mu(u)
- S^mu(A,B): dual (past direction)
- U'^mu(A,B) at t: B^mu cofinal above t restricted to mu-points, and ¬U^mu(A,B)
- S'^mu(A,B): dual
- neg, conj: standard
-/

/-- Mu-relativized temporal truth for standard temporal formulas (Formula).
    This is the φ^mu evaluation: atoms use the extended structure's
    interpretation (false at gaps), and temporal connectives (Until/Since)
    quantify only over mu-points (actual points from M).

    This function is used by `stavi_temporal_truth_mu` for the `.base φ`
    case, ensuring that ALL temporal connectives in A^mu are properly
    relativized to mu-points. -/
noncomputable def temporal_truth_mu {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (r : Nat)
    (t : ExtendedCarrier M atomMap r) : Formula → Prop
  | .atom a => (extendedStructure M atomMap r).interp (atomMap (.atom a)) t
  | .bot => False
  | .imp φ ψ => temporal_truth_mu M atomMap r t φ → temporal_truth_mu M atomMap r t ψ
  | .box φ => (extendedStructure M atomMap r).interp (atomMap (.box φ)) t
  | .untl φ ψ =>
    -- U^mu: quantify only over mu-points
    ∃ s : ExtendedCarrier M atomMap r, t < s ∧ mu_holds s ∧
      temporal_truth_mu M atomMap r s φ ∧
      ∀ u : ExtendedCarrier M atomMap r, t < u → u < s → mu_holds u →
        temporal_truth_mu M atomMap r u ψ
  | .snce φ ψ =>
    -- S^mu: quantify only over mu-points
    ∃ s : ExtendedCarrier M atomMap r, s < t ∧ mu_holds s ∧
      temporal_truth_mu M atomMap r s φ ∧
      ∀ u : ExtendedCarrier M atomMap r, s < u → u < t → mu_holds u →
        temporal_truth_mu M atomMap r u ψ

/-- Temporal truth in M_r with connectives relativized to mu-points.
    This is the A^mu evaluation from GHR93 Definition 8.4.

    All temporal connectives (Until, Since, Stavi Until, Stavi Since)
    quantify only over actual points (mu-points), not gaps. Atoms at
    actual points use M's interpretation; atoms at gaps evaluate to false
    (via the extendedStructure).

    For base formulas (.base φ), delegates to `temporal_truth_mu` which
    handles the mu-relativization of standard Until/Since. -/
noncomputable def stavi_temporal_truth_mu {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (r : Nat)
    (t : ExtendedCarrier M atomMap r) : StaviFormula → Prop
  | .base φ => temporal_truth_mu M atomMap r t φ
  | .stavi_untl A B =>
    -- U'^mu(A,B)(t): GHR93 FO table, mu-relativized.
    -- The witness s is NOT mu-restricted (it is a bound; the gap may not be a point).
    -- All other quantified points (u, v, w, v') ARE mu-restricted.
    ∃ s : ExtendedCarrier M atomMap r, t < s ∧
      -- (1) Main body
      (∀ u : ExtendedCarrier M atomMap r, t < u → u < s → mu_holds u →
        (∃ v : ExtendedCarrier M atomMap r, u < v ∧ mu_holds v ∧
          ∀ w : ExtendedCarrier M atomMap r, t < w → w < v → mu_holds w →
            stavi_temporal_truth_mu M atomMap r w B) ∨
        ((∀ v : ExtendedCarrier M atomMap r, u < v → v < s → mu_holds v →
            stavi_temporal_truth_mu M atomMap r v A) ∧
         ∃ v' : ExtendedCarrier M atomMap r, t < v' ∧ v' < u ∧ mu_holds v' ∧
            ¬ stavi_temporal_truth_mu M atomMap r v' B)) ∧
      -- (2) B fails somewhere (mu-restricted)
      (∃ u : ExtendedCarrier M atomMap r, t < u ∧ u < s ∧ mu_holds u ∧
        ¬ stavi_temporal_truth_mu M atomMap r u B) ∧
      -- (3) B holds initially (mu-restricted)
      (∃ u : ExtendedCarrier M atomMap r, t < u ∧ u < s ∧ mu_holds u ∧
        ∀ v : ExtendedCarrier M atomMap r, t < v → v < u → mu_holds v →
          stavi_temporal_truth_mu M atomMap r v B)
  | .stavi_snce A B =>
    -- S'^mu(A,B)(t): past dual of U'^mu, mu-relativized.
    -- The witness s is NOT mu-restricted.
    ∃ s : ExtendedCarrier M atomMap r, s < t ∧
      -- (1) Main body
      (∀ u : ExtendedCarrier M atomMap r, s < u → u < t → mu_holds u →
        (∃ v : ExtendedCarrier M atomMap r, v < u ∧ mu_holds v ∧
          ∀ w : ExtendedCarrier M atomMap r, v < w → w < t → mu_holds w →
            stavi_temporal_truth_mu M atomMap r w B) ∨
        ((∀ v : ExtendedCarrier M atomMap r, s < v → v < u → mu_holds v →
            stavi_temporal_truth_mu M atomMap r v A) ∧
         ∃ v' : ExtendedCarrier M atomMap r, u < v' ∧ v' < t ∧ mu_holds v' ∧
            ¬ stavi_temporal_truth_mu M atomMap r v' B)) ∧
      -- (2) B fails somewhere (mu-restricted)
      (∃ u : ExtendedCarrier M atomMap r, s < u ∧ u < t ∧ mu_holds u ∧
        ¬ stavi_temporal_truth_mu M atomMap r u B) ∧
      -- (3) B holds on final segment (mu-restricted)
      (∃ u : ExtendedCarrier M atomMap r, s < u ∧ u < t ∧ mu_holds u ∧
        ∀ v : ExtendedCarrier M atomMap r, u < v → v < t → mu_holds v →
          stavi_temporal_truth_mu M atomMap r v B)
  | .neg φ => ¬ stavi_temporal_truth_mu M atomMap r t φ
  | .conj φ ψ =>
    stavi_temporal_truth_mu M atomMap r t φ ∧ stavi_temporal_truth_mu M atomMap r t ψ
  | .std_untl A B =>
    -- Standard Until, mu-relativized: ∃ mu-point s > t, A(s) ∧ ∀ mu-point u ∈ (t,s), B(u)
    ∃ s : ExtendedCarrier M atomMap r, t < s ∧ mu_holds s ∧
      stavi_temporal_truth_mu M atomMap r s A ∧
      ∀ u : ExtendedCarrier M atomMap r, t < u → u < s → mu_holds u →
        stavi_temporal_truth_mu M atomMap r u B
  | .std_snce A B =>
    -- Standard Since, mu-relativized: ∃ mu-point s < t, A(s) ∧ ∀ mu-point u ∈ (s,t), B(u)
    ∃ s : ExtendedCarrier M atomMap r, s < t ∧ mu_holds s ∧
      stavi_temporal_truth_mu M atomMap r s A ∧
      ∀ u : ExtendedCarrier M atomMap r, s < u → u < t → mu_holds u →
        stavi_temporal_truth_mu M atomMap r u B

/-! ### Type Formulas (GHR93 Definition 8.8)

The rank-r type at position t is the set of all StaviFormulas of depth ≤ r
that are true at t in M_r under mu-relativization. Since there are finitely
many inequivalent formulas of each rank (by NormalForm finiteness), two
positions with the same rank_type satisfy exactly the same bounded-depth
formulas.

The interval type X_{(t,u)} describes the set of types realized by actual
points in the open interval (t, u). -/

/-- The rank-r type at position t: the set of all StaviFormulas of depth ≤ r
    that are true at t in M_r (under mu-relativization).

    This is X_t from GHR93 Definition 8.8. Two positions with the same
    rank_type are indistinguishable by formulas of depth ≤ r. -/
def rank_type {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (r : Nat)
    (t : ExtendedCarrier M atomMap r) : Set StaviFormula :=
  { A | stavi_depth A ≤ r ∧ stavi_temporal_truth_mu M atomMap r t A }

/-- The set of rank-r types realized in the open interval (t, u) by actual
    points. This is X_{(t,u)} from GHR93 Definition 8.8.

    Each element of the returned set is a complete rank-r type (a set of
    StaviFormulas) realized by some actual point v with t < v < u. -/
def interval_types {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (r : Nat)
    (t u : ExtendedCarrier M atomMap r) : Set (Set StaviFormula) :=
  { τ | ∃ v : ExtendedCarrier M atomMap r,
    mu_holds v ∧ t < v ∧ v < u ∧ rank_type M atomMap r v = τ }

/-- Two extended carrier elements with the same rank_type agree on all
    StaviFormulas of depth ≤ r. -/
theorem rank_type_eq_iff {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t u : ExtendedCarrier M atomMap r}
    (h : rank_type M atomMap r t = rank_type M atomMap r u)
    (A : StaviFormula) (hd : stavi_depth A ≤ r) :
    stavi_temporal_truth_mu M atomMap r t A ↔
    stavi_temporal_truth_mu M atomMap r u A := by
  constructor
  · intro hA
    have : A ∈ rank_type M atomMap r t := ⟨hd, hA⟩
    rw [h] at this
    exact this.2
  · intro hA
    have : A ∈ rank_type M atomMap r u := ⟨hd, hA⟩
    rw [← h] at this
    exact this.2

/-- If A has depth ≤ r, then A ∈ rank_type iff A^mu holds at t. -/
theorem mem_rank_type_iff {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} {A : StaviFormula}
    (hd : stavi_depth A ≤ r) :
    A ∈ rank_type M atomMap r t ↔ stavi_temporal_truth_mu M atomMap r t A := by
  simp only [rank_type, Set.mem_setOf_eq]
  exact ⟨fun ⟨_, h⟩ => h, fun h => ⟨hd, h⟩⟩

/-- The negation of a StaviFormula has the same depth. -/
theorem stavi_depth_neg (A : StaviFormula) :
    stavi_depth (.neg A) = stavi_depth A := by
  simp [stavi_depth]

/-- If A has depth ≤ r and ¬A^mu(t), then (.neg A) ∈ rank_type M atomMap r t. -/
theorem neg_mem_rank_type_of_not {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {t : ExtendedCarrier M atomMap r} {A : StaviFormula}
    (hd : stavi_depth A ≤ r)
    (hna : ¬ stavi_temporal_truth_mu M atomMap r t A) :
    StaviFormula.neg A ∈ rank_type M atomMap r t := by
  refine ⟨?_, ?_⟩
  · rw [stavi_depth_neg]; exact hd
  · exact hna

/-- rank_embed preserves the mu_holds predicate (which equals IsPoint). -/
theorem rank_embed_mu_holds {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') (e : ExtendedCarrier M atomMap r) :
    mu_holds (rank_embed h e) ↔ mu_holds e := by
  exact rank_embed_isPoint h e

/-! ### Rank Embedding: Formula Agreement Transfer

The key property: mu-relativized truth of formulas is preserved by
rank_embed. This works because rank_embed preserves:
- order (≤, <)
- mu-status (IsPoint / IsGap)
- predicate values at points (rank_embed is id on M.carrier)

The mu-relativized quantifiers only visit mu-points (actual points from
M.carrier), which are the same set regardless of rank. The extra gaps
in M_{r'} compared to M_r are invisible to mu-relativized evaluation.

For any mu-point s in M_{r'}, there exists a corresponding mu-point s_r
in M_r with rank_embed s_r = s (and conversely). Since mu-points are
exactly `extendPoint x` for `x : M.carrier`, and
`rank_embed (extendPoint x) = extendPoint x`, this is immediate. -/

/-- rank_embed preserves predicate values at points via the extended structure.
    At actual points, both carriers inherit from M. At gaps, both are False. -/
theorem rank_embed_interp {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r') (p : sig.preds)
    (e : ExtendedCarrier M atomMap r) :
    (extendedStructure M atomMap r').interp p (rank_embed h e) ↔
    (extendedStructure M atomMap r).interp p e := by
  cases e with
  | inl x => simp [rank_embed, Sum.map, extendedStructure]
  | inr g => simp [rank_embed, Sum.map, extendedStructure, rank_embed_gap]

/-- Mu-relativized temporal truth of standard formulas is preserved by
    rank_embed. The proof is by structural induction on the formula. -/
theorem rank_embed_temporal_truth_mu {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r')
    (e : ExtendedCarrier M atomMap r) (φ : Formula) :
    temporal_truth_mu M atomMap r' (rank_embed h e) φ ↔
    temporal_truth_mu M atomMap r e φ := by
  induction φ generalizing e with
  | atom a => exact rank_embed_interp h _ e
  | bot => simp [temporal_truth_mu]
  | imp φ ψ ihφ ihψ =>
    simp only [temporal_truth_mu]
    exact ⟨fun hf hφ => (ihψ e).mp (hf ((ihφ e).mpr hφ)),
           fun hf hφ => (ihψ e).mpr (hf ((ihφ e).mp hφ))⟩
  | box φ => exact rank_embed_interp h _ e
  | untl φ ψ ihφ ihψ =>
    simp only [temporal_truth_mu]; constructor
    · intro ⟨s, hlt, ⟨x, hx⟩, hφ, hψ⟩; subst hx
      refine ⟨Sum.inl x, (rank_embed_lt h _ _).mp hlt, ⟨x, rfl⟩, (ihφ _).mp hφ, ?_⟩
      intro u heu hux ⟨y, hy⟩; subst hy
      exact (ihψ _).mp (hψ (Sum.inl y)
        ((rank_embed_lt h _ _).mpr heu) ((rank_embed_lt h _ _).mpr hux) ⟨y, rfl⟩)
    · intro ⟨s, hlt, ⟨x, hx⟩, hφ, hψ⟩; subst hx
      refine ⟨Sum.inl x, (rank_embed_lt h _ _).mpr hlt, ⟨x, rfl⟩, (ihφ _).mpr hφ, ?_⟩
      intro u heu hux ⟨y, hy⟩; subst hy
      exact (ihψ _).mpr (hψ (Sum.inl y)
        ((rank_embed_lt h _ _).mp heu) ((rank_embed_lt h _ _).mp hux) ⟨y, rfl⟩)
  | snce φ ψ ihφ ihψ =>
    simp only [temporal_truth_mu]; constructor
    · intro ⟨s, hlt, ⟨x, hx⟩, hφ, hψ⟩; subst hx
      refine ⟨Sum.inl x, (rank_embed_lt h _ _).mp hlt, ⟨x, rfl⟩, (ihφ _).mp hφ, ?_⟩
      intro u hsu hut ⟨y, hy⟩; subst hy
      exact (ihψ _).mp (hψ (Sum.inl y)
        ((rank_embed_lt h _ _).mpr hsu) ((rank_embed_lt h _ _).mpr hut) ⟨y, rfl⟩)
    · intro ⟨s, hlt, ⟨x, hx⟩, hφ, hψ⟩; subst hx
      refine ⟨Sum.inl x, (rank_embed_lt h _ _).mpr hlt, ⟨x, rfl⟩, (ihφ _).mpr hφ, ?_⟩
      intro u hsu hut ⟨y, hy⟩; subst hy
      exact (ihψ _).mpr (hψ (Sum.inl y)
        ((rank_embed_lt h _ _).mp hsu) ((rank_embed_lt h _ _).mp hut) ⟨y, rfl⟩)

/-- extendPoint preserves strict order. Moved here for use in rank_embed proofs. -/
private theorem extendPoint_lt_iff' {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat} (x y : M.carrier) :
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) x <
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) y ↔ x < y := by
  simp only [extendPoint]
  constructor
  · intro ⟨hle, hne⟩; exact lt_of_le_of_ne (show x ≤ y from hle) (fun h => hne (h ▸ le_refl y))
  · intro h; exact ⟨le_of_lt h, fun hyx => not_lt.mpr (show y ≤ x from hyx) h⟩

/-- Mu-relativized truth of StaviFormulas is preserved by rank_embed.
    The proof is by structural induction on the StaviFormula. -/
theorem rank_embed_stavi_truth_mu {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r')
    (e : ExtendedCarrier M atomMap r) (A : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r' (rank_embed h e) A ↔
    stavi_temporal_truth_mu M atomMap r e A := by
  induction A generalizing e with
  | base φ =>
    simp only [stavi_temporal_truth_mu]
    exact rank_embed_temporal_truth_mu h e φ
  | neg A ihA =>
    simp only [stavi_temporal_truth_mu]
    exact not_congr (ihA e)
  | conj A B ihA ihB =>
    simp only [stavi_temporal_truth_mu]
    exact and_congr (ihA e) (ihB e)
  | stavi_untl A B ihA ihB =>
    -- GHR93 FO table: ∃ s, t < s ∧ (body) ∧ (fail) ∧ (init)
    -- rank_embed preserves order, mu-status, predicates → witnesses transfer
    simp only [stavi_temporal_truth_mu]; constructor
    · -- mp: r' → r. Mu-witnesses are extendPoints at both ranks. The bound s
      -- may be a gap at rank r' not present at rank r; handle by finding a
      -- point bound in the gap's cut.
      intro ⟨s, hts, h_body, ⟨u_fail, htu_fail, hus_fail, hmu_fail, hB_fail⟩,
             ⟨u_init, htu_init, hus_init, hmu_init, hB_init⟩⟩
      -- Extract the actual M.carrier points from mu-witnesses
      obtain ⟨xf, rfl⟩ := hmu_fail
      obtain ⟨xi, rfl⟩ := hmu_init
      -- Helper: in a gap's cut, every element has a larger element in the cut
      have gap_cut_cofinal : ∀ (g : RDefinableGap M atomMap r') (x : M.carrier),
          x ∈ g.val.cut → ∃ y, y ∈ g.val.cut ∧ x < y := by
        intro g x hx
        by_contra h_all
        push_neg at h_all
        -- x is an upper bound of cut, and x ∈ cut → IsLUB cut x
        have : IsLUB g.val.cut x := ⟨h_all, fun b hb => hb hx⟩
        exact g.val.no_sup ⟨x, this, hx⟩
      -- Choose the bound s_r at rank r
      -- Case split: s is a point or a gap
      rcases s with y | g
      · -- s = extendPoint y: use extendPoint y at rank r
        refine ⟨extendPoint y, (rank_embed_lt h e (extendPoint y)).mp hts, ?_, ?_, ?_⟩
        · -- Body
          intro u heu hus hmu_u
          obtain ⟨xu, rfl⟩ := hmu_u
          have h_disj := h_body (extendPoint xu)
            ((rank_embed_lt h e (extendPoint xu)).mpr heu)
            ((rank_embed_lt h (extendPoint xu) (extendPoint y)).mpr hus)
            (mu_holds_point xu)
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, huv, hmu_v, hBv⟩ := h_cof
            obtain ⟨xv, rfl⟩ := hmu_v
            exact ⟨extendPoint xv, (rank_embed_lt h (extendPoint xu) (extendPoint xv)).mp huv,
              mu_holds_point xv,
              fun w hew hwv hmu_w => by
                obtain ⟨xw, rfl⟩ := hmu_w
                exact (ihB _).mp (hBv (extendPoint xw)
                  ((rank_embed_lt h e (extendPoint xw)).mpr hew)
                  ((rank_embed_lt h (extendPoint xw) (extendPoint xv)).mpr hwv)
                  (mu_holds_point xw))⟩
          | inr h_take =>
            right
            obtain ⟨hA, v', hev', hv'u, hmu_v', hBv'⟩ := h_take
            obtain ⟨xv', rfl⟩ := hmu_v'
            exact ⟨fun v huv hvs hmu_v => by
                obtain ⟨xv, rfl⟩ := hmu_v
                exact (ihA _).mp (hA (extendPoint xv)
                  ((rank_embed_lt h (extendPoint xu) (extendPoint xv)).mpr huv)
                  ((rank_embed_lt h (extendPoint xv) (extendPoint y)).mpr hvs)
                  (mu_holds_point xv)),
              extendPoint xv', (rank_embed_lt h e (extendPoint xv')).mp hev',
                (rank_embed_lt h (extendPoint xv') (extendPoint xu)).mp hv'u,
                mu_holds_point xv',
                fun hBv'_r => hBv' ((ihB _).mpr hBv'_r)⟩
        · -- Fail
          exact ⟨extendPoint xf, (rank_embed_lt h e (extendPoint xf)).mp htu_fail,
            (rank_embed_lt h (extendPoint xf) (extendPoint y)).mp hus_fail,
            mu_holds_point xf,
            fun hB => hB_fail ((ihB _).mpr hB)⟩
        · -- Init
          exact ⟨extendPoint xi, (rank_embed_lt h e (extendPoint xi)).mp htu_init,
            (rank_embed_lt h (extendPoint xi) (extendPoint y)).mp hus_init,
            mu_holds_point xi,
            fun v hev hvu hmu_v => by
              obtain ⟨xv, rfl⟩ := hmu_v
              exact (ihB _).mp (hB_init (extendPoint xv)
                ((rank_embed_lt h e (extendPoint xv)).mpr hev)
                ((rank_embed_lt h (extendPoint xv) (extendPoint xi)).mpr hvu)
                (mu_holds_point xv))⟩
      · -- s = Sum.inr g (gap at rank r'): find a point bound in the gap's cut
        -- xf, xi ∈ g.val.cut since extendPoint xf/xi < Sum.inr g
        have hxf_cut : xf ∈ g.val.cut := (extendPoint_le_gap_iff xf g).mp (le_of_lt hus_fail)
        have hxi_cut : xi ∈ g.val.cut := (extendPoint_le_gap_iff xi g).mp (le_of_lt hus_init)
        -- max(xf, xi) ∈ cut
        have hmax_cut : max xf xi ∈ g.val.cut := by
          rcases le_or_lt xf xi with h | h
          · simp [max_eq_right h]; exact hxi_cut
          · simp [max_eq_left (le_of_lt h)]; exact hxf_cut
        -- Find y > max(xf, xi) in cut
        obtain ⟨y, hy_cut, hmax_y⟩ := gap_cut_cofinal g (max xf xi) hmax_cut
        have hxf_y : xf < y := lt_of_le_of_lt (le_max_left xf xi) hmax_y
        have hxi_y : xi < y := lt_of_le_of_lt (le_max_right xf xi) hmax_y
        -- Use extendPoint y at rank r as the bound
        -- e < extendPoint y: e < extendPoint xf < extendPoint y
        have he_y : e < extendPoint (sig := sig) (atomMap := atomMap) (r := r) y := by
          calc e < extendPoint xf := (rank_embed_lt h e (extendPoint xf)).mp htu_fail
            _ < extendPoint y := (extendPoint_lt_iff' xf y).mpr hxf_y
        refine ⟨extendPoint y, he_y, ?_, ?_, ?_⟩
        · -- Body: ∀ mu u ∈ (e, extendPoint y), disjunction
          intro u heu huy hmu_u
          obtain ⟨xu, rfl⟩ := hmu_u
          -- xu < y, so xu ∈ g.val.cut (downward-closed), so extendPoint xu < Sum.inr g at rank r'
          have hxu_cut : xu ∈ g.val.cut :=
            g.val.downward_closed y xu hy_cut (le_of_lt ((extendPoint_lt_iff' xu y).mp huy))
          have hxu_s : (extendPoint (sig := sig) (atomMap := atomMap) (r := r') xu) < Sum.inr g :=
            lt_of_le_of_ne ((extendPoint_le_gap_iff xu g).mpr hxu_cut)
              (fun h => by cases h)
          have h_disj := h_body (extendPoint xu)
            ((rank_embed_lt h e (extendPoint xu)).mpr heu) hxu_s (mu_holds_point xu)
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, huv, hmu_v, hBv⟩ := h_cof
            obtain ⟨xv, rfl⟩ := hmu_v
            exact ⟨extendPoint xv, (rank_embed_lt h (extendPoint xu) (extendPoint xv)).mp huv,
              mu_holds_point xv,
              fun w hew hwv hmu_w => by
                obtain ⟨xw, rfl⟩ := hmu_w
                exact (ihB _).mp (hBv (extendPoint xw)
                  ((rank_embed_lt h e (extendPoint xw)).mpr hew)
                  ((rank_embed_lt h (extendPoint xw) (extendPoint xv)).mpr hwv)
                  (mu_holds_point xw))⟩
          | inr h_take =>
            right
            obtain ⟨hA, v', hev', hv'u, hmu_v', hBv'⟩ := h_take
            obtain ⟨xv', rfl⟩ := hmu_v'
            exact ⟨fun v huv hvs hmu_v => by
                obtain ⟨xv, rfl⟩ := hmu_v
                -- xv < y at rank r, so xv ∈ g.val.cut, so extendPoint xv < Sum.inr g at rank r'
                have hxv_cut : xv ∈ g.val.cut :=
                  g.val.downward_closed y xv hy_cut
                    (le_of_lt ((extendPoint_lt_iff' xv y).mp hvs))
                have hxv_s : (extendPoint (sig := sig) (atomMap := atomMap) (r := r') xv) < Sum.inr g :=
                  lt_of_le_of_ne ((extendPoint_le_gap_iff xv g).mpr hxv_cut)
                    (fun h => by cases h)
                exact (ihA _).mp (hA (extendPoint xv)
                  ((rank_embed_lt h (extendPoint xu) (extendPoint xv)).mpr huv)
                  hxv_s (mu_holds_point xv)),
              extendPoint xv', (rank_embed_lt h e (extendPoint xv')).mp hev',
                (rank_embed_lt h (extendPoint xv') (extendPoint xu)).mp hv'u,
                mu_holds_point xv',
                fun hBv'_r => hBv' ((ihB _).mpr hBv'_r)⟩
        · -- Fail
          exact ⟨extendPoint xf, (rank_embed_lt h e (extendPoint xf)).mp htu_fail,
            (extendPoint_lt_iff' xf y).mpr hxf_y, mu_holds_point xf,
            fun hB => hB_fail ((ihB _).mpr hB)⟩
        · -- Init
          exact ⟨extendPoint xi, (rank_embed_lt h e (extendPoint xi)).mp htu_init,
            (extendPoint_lt_iff' xi y).mpr hxi_y, mu_holds_point xi,
            fun v hev hvu hmu_v => by
              obtain ⟨xv, rfl⟩ := hmu_v
              exact (ihB _).mp (hB_init (extendPoint xv)
                ((rank_embed_lt h e (extendPoint xv)).mpr hev)
                ((rank_embed_lt h (extendPoint xv) (extendPoint xi)).mpr hvu)
                (mu_holds_point xv))⟩
    · -- mpr: r → r'. Push witnesses through rank_embed.
      intro ⟨s, hes, h_body, ⟨u_fail, heu_fail, hus_fail, hmu_fail, hB_fail⟩,
             ⟨u_init, heu_init, hus_init, hmu_init, hB_init⟩⟩
      refine ⟨rank_embed h s, (rank_embed_lt h e s).mpr hes, ?_, ?_, ?_⟩
      · -- Body: ∀ mu u ∈ (rank_embed e, rank_embed s), disjunction
        intro u heu hus hmu_u
        -- u is a mu-point at rank r', so u = extendPoint x for some x
        obtain ⟨x, rfl⟩ := hmu_u
        -- rank_embed (extendPoint x) = extendPoint x, so extendPoint x is in range
        have heu_r : e < extendPoint x := (rank_embed_lt h e (extendPoint x)).mp heu
        have hus_r : extendPoint x < s := (rank_embed_lt h (extendPoint x) s).mp hus
        have h_disj := h_body (extendPoint x) heu_r hus_r (mu_holds_point x)
        cases h_disj with
        | inl h_cof =>
          left
          obtain ⟨v, huv, hmu_v, hBv⟩ := h_cof
          exact ⟨rank_embed h v, (rank_embed_lt h (extendPoint x) v).mpr huv,
            (rank_embed_mu_holds h v).mpr hmu_v,
            fun w hew hwv hmu_w => by
              obtain ⟨y, rfl⟩ := hmu_w
              exact (ihB _).mpr (hBv (extendPoint y)
                ((rank_embed_lt h e (extendPoint y)).mp hew)
                ((rank_embed_lt h (extendPoint y) v).mp hwv)
                (mu_holds_point y))⟩
        | inr h_take =>
          right
          obtain ⟨hA, v', hev', hv'u, hmu_v', hBv'⟩ := h_take
          exact ⟨fun v huv hvs hmu_v => by
              obtain ⟨y, rfl⟩ := hmu_v
              exact (ihA _).mpr (hA (extendPoint y)
                ((rank_embed_lt h (extendPoint x) (extendPoint y)).mp huv)
                ((rank_embed_lt h (extendPoint y) s).mp hvs)
                (mu_holds_point y)),
            rank_embed h v', (rank_embed_lt h e v').mpr hev',
              (rank_embed_lt h v' (extendPoint x)).mpr hv'u,
              (rank_embed_mu_holds h v').mpr hmu_v',
              fun hBv'_r' => hBv' ((ihB _).mp hBv'_r')⟩
      · -- Fail: ∃ mu u ∈ (rank_embed e, rank_embed s), ¬B(u)
        exact ⟨rank_embed h u_fail, (rank_embed_lt h e u_fail).mpr heu_fail,
          (rank_embed_lt h u_fail s).mpr hus_fail,
          (rank_embed_mu_holds h u_fail).mpr hmu_fail,
          fun hB => hB_fail ((ihB _).mp hB)⟩
      · -- Init: ∃ mu u ∈ (rank_embed e, rank_embed s), B on (e, u)
        exact ⟨rank_embed h u_init, (rank_embed_lt h e u_init).mpr heu_init,
          (rank_embed_lt h u_init s).mpr hus_init,
          (rank_embed_mu_holds h u_init).mpr hmu_init,
          fun v hev hvu hmu_v => by
            obtain ⟨y, rfl⟩ := hmu_v
            exact (ihB _).mpr (hB_init (extendPoint y)
              ((rank_embed_lt h e (extendPoint y)).mp hev)
              ((rank_embed_lt h (extendPoint y) u_init).mp hvu)
              (mu_holds_point y))⟩
  | stavi_snce A B ihA ihB =>
    -- Past dual of stavi_untl. All directions swapped (< → >, (t,s) → (s,t)).
    simp only [stavi_temporal_truth_mu]; constructor
    · -- mp: r' → r. Same strategy as stavi_untl mp.
      intro ⟨s, hst, h_body, ⟨u_fail, hsu_fail, hue_fail, hmu_fail, hB_fail⟩,
             ⟨u_init, hsu_init, hue_init, hmu_init, hB_init⟩⟩
      obtain ⟨xf, rfl⟩ := hmu_fail
      obtain ⟨xi, rfl⟩ := hmu_init
      -- Helper: gap cut cofinal (same as stavi_untl)
      have gap_cut_cofinal : ∀ (g : RDefinableGap M atomMap r') (x : M.carrier),
          x ∈ g.val.cut → ∃ y, y ∈ g.val.cut ∧ x < y := by
        intro g x hx
        by_contra h_all; push_neg at h_all
        exact g.val.no_sup ⟨x, ⟨h_all, fun b hb => hb hx⟩, hx⟩
      rcases s with y | g
      · -- s = extendPoint y (a point)
        refine ⟨extendPoint y, (rank_embed_lt h (extendPoint y) e).mp hst, ?_, ?_, ?_⟩
        · intro u hsu hue hmu_u
          obtain ⟨xu, rfl⟩ := hmu_u
          have h_disj := h_body (extendPoint xu)
            ((rank_embed_lt h (extendPoint y) (extendPoint xu)).mpr hsu)
            ((rank_embed_lt h (extendPoint xu) e).mpr hue) (mu_holds_point xu)
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, hvu, hmu_v, hBv⟩ := h_cof
            obtain ⟨xv, rfl⟩ := hmu_v
            exact ⟨extendPoint xv, (rank_embed_lt h (extendPoint xv) (extendPoint xu)).mp hvu,
              mu_holds_point xv,
              fun w hvw hwe hmu_w => by
                obtain ⟨xw, rfl⟩ := hmu_w
                exact (ihB _).mp (hBv (extendPoint xw)
                  ((rank_embed_lt h (extendPoint xv) (extendPoint xw)).mpr hvw)
                  ((rank_embed_lt h (extendPoint xw) e).mpr hwe)
                  (mu_holds_point xw))⟩
          | inr h_take =>
            right
            obtain ⟨hA, v', huv', hv'e, hmu_v', hBv'⟩ := h_take
            obtain ⟨xv', rfl⟩ := hmu_v'
            exact ⟨fun v hsv hvu hmu_v => by
                obtain ⟨xv, rfl⟩ := hmu_v
                exact (ihA _).mp (hA (extendPoint xv)
                  ((rank_embed_lt h (extendPoint y) (extendPoint xv)).mpr hsv)
                  ((rank_embed_lt h (extendPoint xv) (extendPoint xu)).mpr hvu)
                  (mu_holds_point xv)),
              extendPoint xv', (rank_embed_lt h (extendPoint xu) (extendPoint xv')).mp huv',
                (rank_embed_lt h (extendPoint xv') e).mp hv'e,
                mu_holds_point xv',
                fun hBv'_r => hBv' ((ihB _).mpr hBv'_r)⟩
        · exact ⟨extendPoint xf, (rank_embed_lt h (extendPoint y) (extendPoint xf)).mp hsu_fail,
            (rank_embed_lt h (extendPoint xf) e).mp hue_fail,
            mu_holds_point xf, fun hB => hB_fail ((ihB _).mpr hB)⟩
        · exact ⟨extendPoint xi, (rank_embed_lt h (extendPoint y) (extendPoint xi)).mp hsu_init,
            (rank_embed_lt h (extendPoint xi) e).mp hue_init,
            mu_holds_point xi,
            fun v hvu hve hmu_v => by
              obtain ⟨xv, rfl⟩ := hmu_v
              exact (ihB _).mp (hB_init (extendPoint xv)
                ((rank_embed_lt h (extendPoint xi) (extendPoint xv)).mpr hvu)
                ((rank_embed_lt h (extendPoint xv) e).mpr hve)
                (mu_holds_point xv))⟩
      · -- s = Sum.inr g (gap): find point bound in gap's complement (above gap)
        -- For S' (past), s < e means gap is BELOW e. Points in (s, e) have xf, xi ∉ g.val.cut.
        -- Actually, s < extendPoint xf means xf ∉ g.val.cut (gap is below xf).
        -- We need a bound below e. The gap g has complement with no minimum.
        -- xf, xi are NOT in the cut (since Sum.inr g < extendPoint xf/xi).
        -- We need s_r < extendPoint xf and s_r < extendPoint xi.
        -- Any point z with z ∉ g.val.cut works: extendPoint z > Sum.inr g.
        -- But we need z < xf and z < xi. Use complement_no_min:
        -- there exist points below xf/xi not in the cut... actually no.
        -- If Sum.inr g < extendPoint xf, then xf ∉ g.val.cut.
        -- The complement_no_min says the complement has no minimum.
        -- So there exists z ∉ g.val.cut with z < xf, and z < xi.
        -- Actually the right approach: the cut IS downward-closed.
        -- If xf ∉ g.val.cut, we need s_r at rank r with s_r < extendPoint xf.
        -- Since the gap g separates: all cut elements are < g < all non-cut elements.
        -- So if xf ∉ cut, then for any z ∈ cut, z < xf (by contrapositive of downward_closed).
        -- Wait, that's not right. downward_closed says: if x ∈ cut and y ≤ x then y ∈ cut.
        -- Contrapositive: if y ∉ cut, then for all x ≥ y, x ∉ cut.
        -- So: xf ∉ cut means for all z, if z ∈ cut then z < xf (not z ≤ xf, since if z = xf,
        -- then xf ∈ cut, contradiction). Actually if z ∈ cut and z ≥ xf, then
        -- xf ∈ cut by downward_closed. Contradiction. So z < xf.
        -- Similarly for xi.
        -- We need s_r at rank r such that s_r < e AND the mu-points in (s_r, e) at rank r
        -- are exactly (or a superset of) those in (Sum.inr g, rank_embed h e) at rank r'.
        -- For the body (universal quantifier), we need (s_r, e)_mu at rank r ⊆ (g, e)_mu at rank r'.
        -- This means: if s_r < extendPoint z < e at rank r, then Sum.inr g < extendPoint z < rank_embed h e.
        -- The second part: extendPoint z < rank_embed h e ↔ extendPoint z < e (rank_embed preserves).
        -- The first part: Sum.inr g < extendPoint z ↔ z ∉ g.val.cut.
        -- So we need: if s_r < extendPoint z at rank r, then z ∉ g.val.cut.
        -- Pick s_r = extendPoint w for some w ∈ g.val.cut. Then s_r < extendPoint z means w < z.
        -- But w ∈ cut doesn't guarantee z ∉ cut when z > w. We need the opposite.
        -- Actually: we need z ∉ cut to guarantee Sum.inr g < extendPoint z.
        -- Pick s_r such that (s_r, e)_mu ⊆ {z : M.carrier | z ∉ g.val.cut ∧ z < e_point}.
        -- For the existential witnesses: xf, xi ∉ g.val.cut. We need s_r < xf and s_r < xi.
        -- Use complement_no_min: the complement has no minimum. So for xf not in cut,
        -- there exists z < xf with z not in cut. Then extendPoint z > Sum.inr g.
        -- But we need s_r < BOTH xf and xi. If we find z₁ < xf with z₁ ∉ cut,
        -- and z₂ < xi with z₂ ∉ cut, take s_r = extendPoint (min z₁ z₂).
        -- min z₁ z₂ ∉ cut? min is one of z₁, z₂, both ∉ cut. So yes.
        -- And min z₁ z₂ < xf and < xi. Then (min z₁ z₂, e) ⊇ {xf, xi}.
        -- For the body: if min z₁ z₂ < z < e_point and z ∉ cut, then g < extendPoint z. Good.
        -- But what if z ∈ cut? Then extendPoint z ≤ Sum.inr g. And s_r = extendPoint (min z₁ z₂) > Sum.inr g
        -- (since min z₁ z₂ ∉ cut). So extendPoint z < s_r? Not necessarily.
        -- z ∈ cut and min z₁ z₂ ∉ cut means z < min z₁ z₂ (by downward_closed contrapositive).
        -- Wait: z ∈ cut and min z₁ z₂ ∉ cut. If z ≥ min z₁ z₂, then by downward_closed,
        -- min z₁ z₂ ∈ cut. Contradiction. So z < min z₁ z₂.
        -- Hence extendPoint z < extendPoint (min z₁ z₂) = s_r. So z is NOT in (s_r, e)!
        -- This means all mu-points in (s_r, e) have z ∉ cut, hence Sum.inr g < extendPoint z.
        --
        -- Summary: pick s_r = extendPoint (min z₁ z₂) where z₁ < xf, z₂ < xi, both ∉ cut.
        -- Key properties:
        -- - s_r < e: s_r < extendPoint xf < e (using hue_fail)
        -- - mu-points in (s_r, e) at rank r ↔ z ∉ g.val.cut ∧ z > min z₁ z₂
        --   and these satisfy Sum.inr g < extendPoint z at rank r'
        have hxf_not_cut : xf ∉ g.val.cut := by
          intro hxf_in
          have : (extendPoint xf : ExtendedCarrier M atomMap r') ≤ Sum.inr g :=
            (extendPoint_le_gap_iff xf g).mpr hxf_in
          exact not_lt.mpr this hsu_fail
        have hxi_not_cut : xi ∉ g.val.cut := by
          intro hxi_in
          have : (extendPoint xi : ExtendedCarrier M atomMap r') ≤ Sum.inr g :=
            (extendPoint_le_gap_iff xi g).mpr hxi_in
          exact not_lt.mpr this hsu_init
        -- complement_no_min gives us points below xf and xi not in cut
        have compl_no_min := g.val.complement_no_min
        -- There exist z₁ < xf and z₂ < xi with z₁, z₂ ∉ cut
        have ⟨z₁, hz₁_not_cut, hz₁_xf⟩ : ∃ z, z ∉ g.val.cut ∧ z < xf := by
          by_contra h_all; push_neg at h_all
          exact compl_no_min ⟨xf, hxf_not_cut, fun y hy => h_all y hy⟩
        have ⟨z₂, hz₂_not_cut, hz₂_xi⟩ : ∃ z, z ∉ g.val.cut ∧ z < xi := by
          by_contra h_all; push_neg at h_all
          exact compl_no_min ⟨xi, hxi_not_cut, fun y hy => h_all y hy⟩
        -- min z₁ z₂ ∉ cut
        have hmin_not_cut : min z₁ z₂ ∉ g.val.cut := by
          rcases le_or_lt z₁ z₂ with h | h
          · simp [min_eq_left h]; exact hz₁_not_cut
          · simp [min_eq_right (le_of_lt h)]; exact hz₂_not_cut
        -- Helper: z ∉ cut → Sum.inr g < extendPoint z at rank r'
        -- Inline helper: z ∉ cut → Sum.inr g < Sum.inl z
        -- (proved via lt_of_not_le since Sum.inl z ≤ Sum.inr g ↔ z ∈ cut)
        -- Use s_r = extendPoint (min z₁ z₂) at rank r
        have hs_r_e : (extendPoint (sig := sig) (atomMap := atomMap) (r := r) (min z₁ z₂)) < e := by
          calc extendPoint (min z₁ z₂) ≤ extendPoint z₁ :=
                show (min z₁ z₂ ≤ z₁ : Prop) from min_le_left z₁ z₂
            _ < extendPoint xf := (extendPoint_lt_iff' z₁ xf).mpr hz₁_xf
            _ < e := (rank_embed_lt h (extendPoint xf) e).mp hue_fail
        refine ⟨extendPoint (min z₁ z₂), hs_r_e, ?_, ?_, ?_⟩
        · -- Body
          intro u hsu hue hmu_u
          obtain ⟨xu, rfl⟩ := hmu_u
          -- xu > min z₁ z₂ and xu ∉ g.val.cut (since min z₁ z₂ ∉ cut and xu > min z₁ z₂)
          have hxu_not_cut : xu ∉ g.val.cut := by
            intro hxu_in
            -- xu ∈ cut, min z₁ z₂ ∉ cut. By downward_closed: xu ≤ min z₁ z₂ → min ∈ cut. Contra.
            -- So xu < min z₁ z₂? No, we know extendPoint (min z₁ z₂) < extendPoint xu.
            -- So min z₁ z₂ < xu. But xu ∈ cut and min z₁ z₂ ≤ xu (by min ≤ xu), so min ∈ cut.
            exact hmin_not_cut (g.val.downward_closed xu (min z₁ z₂) hxu_in
              (le_of_lt ((extendPoint_lt_iff' (min z₁ z₂) xu).mp hsu)))
          -- Sum.inr g < Sum.inl xu follows from hsu_fail (Sum.inr g < Sum.inl xf)
          -- and transitivity, if we knew extendPoint xf ≤ extendPoint xu.
          -- But simpler: reconstruct from scratch.
          -- Since this type class issue persists, define s' explicitly typed.
          have hxu_above_g : @LT.lt (ExtendedCarrier M atomMap r')
              extendedLinearOrder.toLT (Sum.inr g) (Sum.inl xu) :=
            ⟨hxu_not_cut, fun h => hxu_not_cut h⟩
          have h_disj := h_body (extendPoint xu)
            hxu_above_g ((rank_embed_lt h (extendPoint xu) e).mpr hue) (mu_holds_point xu)
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, hvu, hmu_v, hBv⟩ := h_cof
            obtain ⟨xv, rfl⟩ := hmu_v
            exact ⟨extendPoint xv, (rank_embed_lt h (extendPoint xv) (extendPoint xu)).mp hvu,
              mu_holds_point xv,
              fun w hvw hwe hmu_w => by
                obtain ⟨xw, rfl⟩ := hmu_w
                exact (ihB _).mp (hBv (extendPoint xw)
                  ((rank_embed_lt h (extendPoint xv) (extendPoint xw)).mpr hvw)
                  ((rank_embed_lt h (extendPoint xw) e).mpr hwe)
                  (mu_holds_point xw))⟩
          | inr h_take =>
            right
            obtain ⟨hA, v', huv', hv'e, hmu_v', hBv'⟩ := h_take
            obtain ⟨xv', rfl⟩ := hmu_v'
            exact ⟨fun v hsv hvu hmu_v => by
                obtain ⟨xv, rfl⟩ := hmu_v
                -- xv > min z₁ z₂ → xv ∉ cut → Sum.inr g < extendPoint xv
                have hxv_not_cut : xv ∉ g.val.cut := by
                  intro hxv_in
                  exact hmin_not_cut (g.val.downward_closed xv (min z₁ z₂) hxv_in
                    (le_of_lt ((extendPoint_lt_iff' (min z₁ z₂) xv).mp hsv)))
                have hxv_above_g : @LT.lt (ExtendedCarrier M atomMap r')
                    extendedLinearOrder.toLT (Sum.inr g) (Sum.inl xv) :=
                  ⟨hxv_not_cut, fun h => hxv_not_cut h⟩
                exact (ihA _).mp (hA (extendPoint xv)
                  hxv_above_g
                  ((rank_embed_lt h (extendPoint xv) (extendPoint xu)).mpr hvu)
                  (mu_holds_point xv)),
              extendPoint xv', (rank_embed_lt h (extendPoint xu) (extendPoint xv')).mp huv',
                (rank_embed_lt h (extendPoint xv') e).mp hv'e,
                mu_holds_point xv',
                fun hBv'_r => hBv' ((ihB _).mpr hBv'_r)⟩
        · -- Fail
          exact ⟨extendPoint xf,
            (extendPoint_lt_iff' (min z₁ z₂) xf).mpr (lt_of_le_of_lt (min_le_left z₁ z₂) hz₁_xf),
            (rank_embed_lt h (extendPoint xf) e).mp hue_fail,
            mu_holds_point xf, fun hB => hB_fail ((ihB _).mpr hB)⟩
        · -- Init
          exact ⟨extendPoint xi,
            (extendPoint_lt_iff' (min z₁ z₂) xi).mpr (lt_of_le_of_lt (min_le_right z₁ z₂) hz₂_xi),
            (rank_embed_lt h (extendPoint xi) e).mp hue_init,
            mu_holds_point xi,
            fun v hvu hve hmu_v => by
              obtain ⟨xv, rfl⟩ := hmu_v
              exact (ihB _).mp (hB_init (extendPoint xv)
                ((rank_embed_lt h (extendPoint xi) (extendPoint xv)).mpr hvu)
                ((rank_embed_lt h (extendPoint xv) e).mpr hve)
                (mu_holds_point xv))⟩
    · -- mpr: r → r'. Push witnesses through rank_embed.
      intro ⟨s, hse, h_body, ⟨u_fail, hsu_fail, hue_fail, hmu_fail, hB_fail⟩,
             ⟨u_init, hsu_init, hue_init, hmu_init, hB_init⟩⟩
      refine ⟨rank_embed h s, (rank_embed_lt h s e).mpr hse, ?_, ?_, ?_⟩
      · -- Body
        intro u hsu hue hmu_u
        obtain ⟨x, rfl⟩ := hmu_u
        have h_disj := h_body (extendPoint x)
          ((rank_embed_lt h s (extendPoint x)).mp hsu)
          ((rank_embed_lt h (extendPoint x) e).mp hue) (mu_holds_point x)
        cases h_disj with
        | inl h_cof =>
          left
          obtain ⟨v, hvu, hmu_v, hBv⟩ := h_cof
          exact ⟨rank_embed h v, (rank_embed_lt h v (extendPoint x)).mpr hvu,
            (rank_embed_mu_holds h v).mpr hmu_v,
            fun w hvw hwe hmu_w => by
              obtain ⟨y, rfl⟩ := hmu_w
              exact (ihB _).mpr (hBv (extendPoint y)
                ((rank_embed_lt h v (extendPoint y)).mp hvw)
                ((rank_embed_lt h (extendPoint y) e).mp hwe)
                (mu_holds_point y))⟩
        | inr h_take =>
          right
          obtain ⟨hA, v', huv', hv'e, hmu_v', hBv'⟩ := h_take
          exact ⟨fun v hsv hvu hmu_v => by
              obtain ⟨y, rfl⟩ := hmu_v
              exact (ihA _).mpr (hA (extendPoint y)
                ((rank_embed_lt h s (extendPoint y)).mp hsv)
                ((rank_embed_lt h (extendPoint y) (extendPoint x)).mp hvu)
                (mu_holds_point y)),
            rank_embed h v', (rank_embed_lt h (extendPoint x) v').mpr huv',
              (rank_embed_lt h v' e).mpr hv'e,
              (rank_embed_mu_holds h v').mpr hmu_v',
              fun hBv'_r' => hBv' ((ihB _).mp hBv'_r')⟩
      · -- Fail
        exact ⟨rank_embed h u_fail, (rank_embed_lt h s u_fail).mpr hsu_fail,
          (rank_embed_lt h u_fail e).mpr hue_fail,
          (rank_embed_mu_holds h u_fail).mpr hmu_fail,
          fun hB => hB_fail ((ihB _).mp hB)⟩
      · -- Init
        exact ⟨rank_embed h u_init, (rank_embed_lt h s u_init).mpr hsu_init,
          (rank_embed_lt h u_init e).mpr hue_init,
          (rank_embed_mu_holds h u_init).mpr hmu_init,
          fun v hvu hve hmu_v => by
            obtain ⟨y, rfl⟩ := hmu_v
            exact (ihB _).mpr (hB_init (extendPoint y)
              ((rank_embed_lt h u_init (extendPoint y)).mp hvu)
              ((rank_embed_lt h (extendPoint y) e).mp hve)
              (mu_holds_point y))⟩
  | std_untl A B ihA ihB =>
    -- Standard Until, mu-relativized. Witnesses are mu-points at both ranks.
    simp only [stavi_temporal_truth_mu]; constructor
    · -- mp: r' → r
      intro ⟨s, hts, hmu_s, hAs, hBu⟩
      obtain ⟨x, rfl⟩ := hmu_s
      refine ⟨Sum.inl x, (rank_embed_lt h e (extendPoint x)).mp hts, ⟨x, rfl⟩,
        (ihA _).mp hAs, fun u heu hux hmu_u => ?_⟩
      obtain ⟨y, rfl⟩ := hmu_u
      exact (ihB _).mp (hBu (Sum.inl y)
        ((rank_embed_lt h e (extendPoint y)).mpr heu)
        ((rank_embed_lt h (extendPoint y) (extendPoint x)).mpr hux)
        ⟨y, rfl⟩)
    · -- mpr: r → r'
      intro ⟨s, hts, hmu_s, hAs, hBu⟩
      obtain ⟨x, rfl⟩ := hmu_s
      refine ⟨Sum.inl x, (rank_embed_lt h e (extendPoint x)).mpr hts, ⟨x, rfl⟩,
        (ihA _).mpr hAs, fun u heu hux hmu_u => ?_⟩
      obtain ⟨y, rfl⟩ := hmu_u
      exact (ihB _).mpr (hBu (Sum.inl y)
        ((rank_embed_lt h e (extendPoint y)).mp heu)
        ((rank_embed_lt h (extendPoint y) (extendPoint x)).mp hux)
        ⟨y, rfl⟩)
  | std_snce A B ihA ihB =>
    -- Standard Since, mu-relativized. Dual of std_untl.
    simp only [stavi_temporal_truth_mu]; constructor
    · -- mp: r' → r
      intro ⟨s, hse, hmu_s, hAs, hBu⟩
      obtain ⟨x, rfl⟩ := hmu_s
      refine ⟨Sum.inl x, (rank_embed_lt h (extendPoint x) e).mp hse, ⟨x, rfl⟩,
        (ihA _).mp hAs, fun u hxu hue hmu_u => ?_⟩
      obtain ⟨y, rfl⟩ := hmu_u
      exact (ihB _).mp (hBu (Sum.inl y)
        ((rank_embed_lt h (extendPoint x) (extendPoint y)).mpr hxu)
        ((rank_embed_lt h (extendPoint y) e).mpr hue)
        ⟨y, rfl⟩)
    · -- mpr: r → r'
      intro ⟨s, hse, hmu_s, hAs, hBu⟩
      obtain ⟨x, rfl⟩ := hmu_s
      refine ⟨Sum.inl x, (rank_embed_lt h (extendPoint x) e).mpr hse, ⟨x, rfl⟩,
        (ihA _).mpr hAs, fun u hxu hue hmu_u => ?_⟩
      obtain ⟨y, rfl⟩ := hmu_u
      exact (ihB _).mpr (hBu (Sum.inl y)
        ((rank_embed_lt h (extendPoint x) (extendPoint y)).mp hxu)
        ((rank_embed_lt h (extendPoint y) e).mp hue)
        ⟨y, rfl⟩)


end Bimodal.Metalogic.WeakCanonical
