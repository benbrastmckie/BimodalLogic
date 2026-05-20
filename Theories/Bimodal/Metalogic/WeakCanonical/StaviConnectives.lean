import Bimodal.Metalogic.WeakCanonical.Table

/-!
# Stavi Connectives: U'(A,B) and S'(A,B)

Defines the Stavi connective semantics U'(A,B) and S'(A,B) for the Reynolds
pipeline. These connectives detect "gap" behavior in linear temporal structures:
U'(A,B) holds when B is cofinal above t but the standard U(A,B) witness does
not exist (there is a gap rather than a point where the transition occurs).

## Key definitions

- `stavi_U_truth`: Semantic truth of U'(A,B) at time t on an ordered monadic structure
- `stavi_S_truth`: Semantic truth of S'(A,B) at time t (past-directed dual)
- `stavi_temporal_truth`: Extended temporal truth predicate with U' and S' cases
- `StaviFormula`: Extended formula type with U' and S' constructors

## Mathematical Content

The Stavi connectives were introduced by Stavi (unpublished) and formalized
in GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9. Reynolds (1994)
Section 4 uses them in the proof that {U,S} is expressively complete for
Prior structures (discrete linear orders satisfying Prior-UZ/SZ).

### Semantic Definition (GHR93, Section 9.2)

U'(A,B)(t) holds iff:
1. B is cofinal above t: ∀ s > t, ∃ r, t < r ∧ r ≤ s ∧ B(r)
2. Standard Until fails: ¬∃ s > t, A(s) ∧ ∀ r ∈ (t,s), B(r)

S'(A,B)(t) is the temporal dual (past direction).

### Key Property

In any Prior structure (discrete, Prior-UZ/SZ), U'(A,B) and S'(A,B) are
always false. This is because Prior-UZ forces the cofinal condition to
produce a standard Until witness, contradicting condition (2).

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Section 9.2
- Reynolds 1994, Section 4 (p.122-124)
- Task 155 plan: Phase 4 (Sub-stage 4A)
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Stavi Connective Semantics -/

/--
Semantic truth of the Stavi Until connective U'(A,B) at time t.

U'(A,B)(t) holds in an ordered monadic structure M iff:
1. B is cofinal above t: for every point s > t, there is a point r
   with t < r ≤ s where B holds.
2. The standard Until U(A,B) does NOT hold at t: there is no point s > t
   where A(s) holds with B holding throughout the open interval (t,s).

This captures the "gap" behavior: B accumulates toward a gap from below,
but there is no actual point serving as a standard Until witness.

In Prior structures, condition (1) combined with Prior-UZ implies the
existence of a standard Until witness, contradicting condition (2).
Hence U'(A,B) is always false in Prior structures.
-/
def stavi_U_truth {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier) (A B : Formula) : Prop :=
  -- (1) B is cofinal above t
  (∀ s : M.carrier, t < s → ∃ r : M.carrier, t < r ∧ r ≤ s ∧
    temporal_truth M atomMap r B) ∧
  -- (2) Standard U(A,B) does NOT hold at t
  ¬(∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s A ∧
    ∀ r : M.carrier, t < r → r < s → temporal_truth M atomMap r B)

/--
Semantic truth of the Stavi Since connective S'(A,B) at time t.

S'(A,B)(t) holds in an ordered monadic structure M iff:
1. B is cofinal below t: for every point s < t, there is a point r
   with s ≤ r < t where B holds.
2. The standard Since S(A,B) does NOT hold at t: there is no point s < t
   where A(s) holds with B holding throughout the open interval (s,t).

This is the past-directed dual of U'(A,B).
-/
def stavi_S_truth {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier) (A B : Formula) : Prop :=
  -- (1) B is cofinal below t
  (∀ s : M.carrier, s < t → ∃ r : M.carrier, s ≤ r ∧ r < t ∧
    temporal_truth M atomMap r B) ∧
  -- (2) Standard S(A,B) does NOT hold at t
  ¬(∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s A ∧
    ∀ r : M.carrier, s < r → r < t → temporal_truth M atomMap r B)

/-! ## Extended Formula Type with Stavi Connectives -/

/--
Extended temporal formula type that includes Stavi connectives U' and S'
in addition to the standard temporal formula constructors.

This extends `Bimodal.Syntax.Formula` with two new constructors for the
Stavi connectives. Used in the GHR93 expressive completeness theorem
where {U, S, U', S'} is shown to be expressively complete for all
linear temporal structures.
-/
inductive StaviFormula : Type where
  /-- Standard temporal formula (atom, bot, imp, box, untl, snce) -/
  | base (φ : Formula) : StaviFormula
  /-- Stavi Until: U'(A, B) -/
  | stavi_untl (A B : StaviFormula) : StaviFormula
  /-- Stavi Since: S'(A, B) -/
  | stavi_snce (A B : StaviFormula) : StaviFormula
  /-- Negation -/
  | neg (φ : StaviFormula) : StaviFormula
  /-- Conjunction -/
  | conj (φ ψ : StaviFormula) : StaviFormula

/--
Semantic truth of extended Stavi formulas on an ordered monadic structure.

Extends `temporal_truth` with cases for Stavi Until and Stavi Since.
Base formulas are evaluated via the standard `temporal_truth`.
-/
def stavi_temporal_truth {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier) : StaviFormula → Prop
  | .base φ => temporal_truth M atomMap t φ
  | .stavi_untl A B =>
    -- (1) B cofinal above t
    (∀ s : M.carrier, t < s → ∃ r : M.carrier, t < r ∧ r ≤ s ∧
      stavi_temporal_truth M atomMap r B) ∧
    -- (2) Standard U fails (A witnesses for stavi B)
    ¬(∃ s : M.carrier, t < s ∧ stavi_temporal_truth M atomMap s A ∧
      ∀ r : M.carrier, t < r → r < s → stavi_temporal_truth M atomMap r B)
  | .stavi_snce A B =>
    -- (1) B cofinal below t
    (∀ s : M.carrier, s < t → ∃ r : M.carrier, s ≤ r ∧ r < t ∧
      stavi_temporal_truth M atomMap r B) ∧
    -- (2) Standard S fails
    ¬(∃ s : M.carrier, s < t ∧ stavi_temporal_truth M atomMap s A ∧
      ∀ r : M.carrier, s < r → r < t → stavi_temporal_truth M atomMap r B)
  | .neg φ => ¬ stavi_temporal_truth M atomMap t φ
  | .conj φ ψ =>
    stavi_temporal_truth M atomMap t φ ∧ stavi_temporal_truth M atomMap t ψ

/-! ## First-Order Table for Stavi Connectives

The monadic first-order equivalents of U'(p,q) and S'(p,q). These
are the FO formulas that define the Stavi connective semantics.

U'(p,q) corresponds to:
  ∀s(t < s → ∃r(t < r ∧ r ≤ s ∧ q(r))) ∧
  ¬∃s(t < s ∧ p(s) ∧ ∀r(t < r ∧ r < s → q(r)))

The second conjunct is just ¬table(U(p,q)).
-/

/--
First-order formula for "q is cofinal above t" with one free variable t.
∀s > t, ∃r, t < r ∧ r ≤ s ∧ q(r)

In MonadicFormula sig 1 (var 0 = t):
After ∀ (var 0 = s, var 1 = t):
  s > t: lt 1 0  (t < s)
  ∃r (var 0 = r, var 1 = s, var 2 = t):
    t < r: lt 2 0
    r ≤ s: not(lt 1 0), i.e., ¬(s < r) which is r ≤ s
    q(r): lift of table for q applied to var 0
-/
noncomputable def cofinal_above_fo (sig : MonadicSignature)
    (atomMap : Formula → sig.preds) (q : Formula) :
    MonadicFormula sig 1 :=
  .all  -- ∀s
    (.not (.and
      (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- t < s →
      (.not (.ex  -- ∃r
        (.and (.and
          (.lt ⟨2, by omega⟩ ⟨0, by omega⟩)  -- t < r
          (.not (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)))  -- r ≤ s (¬(s < r))
        (((table sig atomMap q).lift 1).lift 1))))))  -- q(r)

/--
First-order formula for the Stavi Until U'(p,q)(t):
cofinal_above q ∧ ¬table(U(p,q))

This is `MonadicFormula sig 1` with one free variable t.
-/
noncomputable def stavi_U_fo (sig : MonadicSignature)
    (atomMap : Formula → sig.preds) (p q : Formula) :
    MonadicFormula sig 1 :=
  .and (cofinal_above_fo sig atomMap q)
       (.not (table sig atomMap (.untl p q)))

/--
First-order formula for "q is cofinal below t":
∀s < t, ∃r, s ≤ r ∧ r < t ∧ q(r)

In MonadicFormula sig 1 (var 0 = t):
After ∀ (var 0 = s, var 1 = t):
  s < t: lt 0 1
  ∃r (var 0 = r, var 1 = s, var 2 = t):
    s ≤ r: not(lt 0 1), i.e., ¬(r < s) which is s ≤ r
    r < t: lt 0 2
    q(r): lift of table for q applied to var 0
-/
noncomputable def cofinal_below_fo (sig : MonadicSignature)
    (atomMap : Formula → sig.preds) (q : Formula) :
    MonadicFormula sig 1 :=
  .all  -- ∀s
    (.not (.and
      (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)  -- s < t →
      (.not (.ex  -- ∃r
        (.and (.and
          (.not (.lt ⟨0, by omega⟩ ⟨1, by omega⟩))  -- s ≤ r (¬(r < s))
          (.lt ⟨0, by omega⟩ ⟨2, by omega⟩))  -- r < t
        (((table sig atomMap q).lift 1).lift 1))))))  -- q(r)

/--
First-order formula for the Stavi Since S'(p,q)(t):
cofinal_below q ∧ ¬table(S(p,q))
-/
noncomputable def stavi_S_fo (sig : MonadicSignature)
    (atomMap : Formula → sig.preds) (p q : Formula) :
    MonadicFormula sig 1 :=
  .and (cofinal_below_fo sig atomMap q)
       (.not (table sig atomMap (.snce p q)))


/-! ## Stavi Connectives in Discrete Orders (Phase 5)

In a discrete order (SuccOrder + PredOrder), the Stavi connectives have
equivalent standard temporal formulas. The key simplification:

- B cofinal above t ↔ B(succ(t))
  Proof: For any s > t, succ(t) ≤ s, so taking r = succ(t) satisfies
  t < r ≤ s. Conversely, cofinality at s = succ(t) forces B(succ(t)).

- B cofinal below t ↔ B(pred(t))
  Dual argument.

Therefore:
- U'(A,B)(t) ↔ B(succ(t)) ∧ ¬U(A,B)(t)
- S'(A,B)(t) ↔ B(pred(t)) ∧ ¬S(A,B)(t)

And B(succ(t)) = U(B, ⊥)(t) (Until with empty guard means the witness
is succ(t)). Similarly B(pred(t)) = S(B, ⊥)(t).

This means U' and S' are definable using just U and S in discrete orders,
giving Reynolds Theorem 5: {U,S} is expressively complete for Prior
structures (discrete orders with Prior-UZ/SZ).
-/

/--
In a discrete order (SuccOrder), B cofinal above t is equivalent to
B holding at succ(t).
-/
theorem cofinal_above_iff_succ {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (atomMap : Formula → sig.preds) (t : M.carrier) (B : Formula) :
    (∀ s : M.carrier, t < s → ∃ r : M.carrier, t < r ∧ r ≤ s ∧
      temporal_truth M atomMap r B) ↔
    temporal_truth M atomMap (Order.succ t) B := by
  constructor
  · -- cofinal → B(succ(t))
    intro h_cofinal
    have h_succ_gt : t < Order.succ t := Order.lt_succ t
    obtain ⟨r, htr, hrs, hBr⟩ := h_cofinal (Order.succ t) h_succ_gt
    -- r satisfies t < r ≤ succ(t), so r = succ(t)
    have h_eq : r = Order.succ t :=
      le_antisymm hrs (SuccOrder.succ_le_of_lt htr)
    exact h_eq ▸ hBr
  · -- B(succ(t)) → cofinal
    intro hB_succ s hts
    exact ⟨Order.succ t, Order.lt_succ t, SuccOrder.succ_le_of_lt hts, hB_succ⟩

/--
In a discrete order (PredOrder), B cofinal below t is equivalent to
B holding at pred(t).
-/
theorem cofinal_below_iff_pred {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    [PredOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds) (t : M.carrier) (B : Formula) :
    (∀ s : M.carrier, s < t → ∃ r : M.carrier, s ≤ r ∧ r < t ∧
      temporal_truth M atomMap r B) ↔
    temporal_truth M atomMap (Order.pred t) B := by
  constructor
  · -- cofinal → B(pred(t))
    intro h_cofinal
    have h_pred_lt : Order.pred t < t := Order.pred_lt t
    obtain ⟨r, hsr, hrt, hBr⟩ := h_cofinal (Order.pred t) h_pred_lt
    have h_eq : r = Order.pred t :=
      le_antisymm (PredOrder.le_pred_of_lt hrt) hsr
    exact h_eq ▸ hBr
  · -- B(pred(t)) → cofinal
    intro hB_pred s hst
    exact ⟨Order.pred t, PredOrder.le_pred_of_lt hst, Order.pred_lt t, hB_pred⟩

/--
In a discrete order, U(B, ⊥)(t) is equivalent to B(succ(t)).

U(B, ⊥)(t) = ∃ s > t, B(s) ∧ ∀ r ∈ (t,s), ⊥
            = ∃ s > t, B(s) ∧ (t,s) = ∅
            = B(succ(t))   (since (t, succ(t)) is empty in discrete order)
-/
theorem until_bot_iff_succ {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (atomMap : Formula → sig.preds) (t : M.carrier) (B : Formula) :
    temporal_truth M atomMap t (.untl B .bot) ↔
    temporal_truth M atomMap (Order.succ t) B := by
  simp only [temporal_truth]
  constructor
  · rintro ⟨s, hts, hBs, hguard⟩
    -- The guard ⊥ forces (t,s) to be empty, so s = succ(t)
    have h_succ_le : Order.succ t ≤ s := SuccOrder.succ_le_of_lt hts
    have h_eq : s = Order.succ t := by
      by_contra h_ne
      have h_lt : Order.succ t < s := lt_of_le_of_ne h_succ_le (Ne.symm h_ne)
      exact hguard (Order.succ t) (Order.lt_succ t) h_lt
    exact h_eq ▸ hBs
  · intro hB_succ
    exact ⟨Order.succ t, Order.lt_succ t, hB_succ,
      fun r htr hrs => absurd (SuccOrder.succ_le_of_lt htr) (not_le.mpr hrs)⟩

/--
In a discrete order, S(B, ⊥)(t) is equivalent to B(pred(t)).
Dual of `until_bot_iff_succ`.
-/
theorem since_bot_iff_pred {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    [PredOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds) (t : M.carrier) (B : Formula) :
    temporal_truth M atomMap t (.snce B .bot) ↔
    temporal_truth M atomMap (Order.pred t) B := by
  simp only [temporal_truth]
  constructor
  · rintro ⟨s, hst, hBs, hguard⟩
    have h_le_pred : s ≤ Order.pred t := PredOrder.le_pred_of_lt hst
    have h_eq : s = Order.pred t := by
      by_contra h_ne
      have h_lt : s < Order.pred t := lt_of_le_of_ne h_le_pred h_ne
      exact hguard (Order.pred t) h_lt (Order.pred_lt t)
    exact h_eq ▸ hBs
  · intro hB_pred
    exact ⟨Order.pred t, Order.pred_lt t, hB_pred,
      fun r hrs hrt => absurd (PredOrder.le_pred_of_lt hrt) (not_le.mpr hrs)⟩

/--
In a discrete order, the Stavi Until U'(A,B)(t) is equivalent to
U(B, ⊥)(t) ∧ ¬U(A,B)(t), i.e., B(succ(t)) ∧ ¬U(A,B)(t).

This means U' is definable using just U in discrete orders.
-/
theorem stavi_U_discrete_equiv {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (atomMap : Formula → sig.preds) (t : M.carrier) (A B : Formula) :
    stavi_U_truth M atomMap t A B ↔
    temporal_truth M atomMap t (Formula.untl B Formula.bot) ∧
    ¬ temporal_truth M atomMap t (Formula.untl A B) := by
  simp only [stavi_U_truth]
  constructor
  · rintro ⟨h_cofinal, h_not_until⟩
    exact ⟨(until_bot_iff_succ M atomMap t B).mpr
      ((cofinal_above_iff_succ M atomMap t B).mp h_cofinal), h_not_until⟩
  · rintro ⟨h_next_B, h_not_until⟩
    exact ⟨(cofinal_above_iff_succ M atomMap t B).mpr
      ((until_bot_iff_succ M atomMap t B).mp h_next_B), h_not_until⟩

/--
In a discrete order, the Stavi Since S'(A,B)(t) is equivalent to
S(B, ⊥)(t) ∧ ¬S(A,B)(t), i.e., B(pred(t)) ∧ ¬S(A,B)(t).

This means S' is definable using just S in discrete orders.
-/
theorem stavi_S_discrete_equiv {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    [PredOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds) (t : M.carrier) (A B : Formula) :
    stavi_S_truth M atomMap t A B ↔
    temporal_truth M atomMap t (Formula.snce B Formula.bot) ∧
    ¬ temporal_truth M atomMap t (Formula.snce A B) := by
  simp only [stavi_S_truth]
  constructor
  · rintro ⟨h_cofinal, h_not_since⟩
    exact ⟨(since_bot_iff_pred M atomMap t B).mpr
      ((cofinal_below_iff_pred M atomMap t B).mp h_cofinal), h_not_since⟩
  · rintro ⟨h_prev_B, h_not_since⟩
    exact ⟨(cofinal_below_iff_pred M atomMap t B).mpr
      ((since_bot_iff_pred M atomMap t B).mp h_prev_B), h_not_since⟩

/--
Convert a StaviFormula to a standard temporal Formula in a discrete order.

In a discrete order (SuccOrder + PredOrder), every StaviFormula has an
equivalent standard temporal formula because:
- U'(A,B) = U(B, ⊥) ∧ ¬U(A,B) = U(flatten B, ⊥) ∧ (U(flatten A, flatten B) → ⊥)
- S'(A,B) = S(B, ⊥) ∧ ¬S(A,B) = similar

The conversion is structural: base formulas are unchanged, negation and
conjunction are standard, and U'/S' are replaced by their temporal equivalents.
-/
noncomputable def flatten_stavi : StaviFormula → Formula
  | .base φ => φ
  | .neg φ => (flatten_stavi φ).neg
  | .conj φ ψ => Formula.and (flatten_stavi φ) (flatten_stavi ψ)
  | .stavi_untl A B =>
    -- U'(A,B) = U(flatten B, ⊥) ∧ ¬U(flatten A, flatten B)
    Formula.and (Formula.untl (flatten_stavi B) Formula.bot)
                ((Formula.untl (flatten_stavi A) (flatten_stavi B)).neg)
  | .stavi_snce A B =>
    -- S'(A,B) = S(flatten B, ⊥) ∧ ¬S(flatten A, flatten B)
    Formula.and (Formula.snce (flatten_stavi B) Formula.bot)
                ((Formula.snce (flatten_stavi A) (flatten_stavi B)).neg)

/-! ## Helper Lemmas: temporal_truth of derived operators -/

/-- temporal_truth of Formula.neg is negation of temporal_truth. -/
theorem temporal_truth_neg {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (t : M.carrier) (φ : Formula) :
    temporal_truth M atomMap t φ.neg ↔ ¬ temporal_truth M atomMap t φ := by
  simp only [Formula.neg, temporal_truth]

/-- temporal_truth of Formula.and is conjunction of temporal_truth. -/
theorem temporal_truth_and {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (t : M.carrier) (φ ψ : Formula) :
    temporal_truth M atomMap t (Formula.and φ ψ) ↔
    temporal_truth M atomMap t φ ∧ temporal_truth M atomMap t ψ := by
  simp only [Formula.and, Formula.neg, temporal_truth]
  constructor
  · intro h
    by_contra h_neg
    push_neg at h_neg
    by_cases hφ : temporal_truth M atomMap t φ
    · exact h (fun _ => h_neg hφ)
    · exact h (fun hφ' => absurd hφ' hφ)
  · rintro ⟨hφ, hψ⟩ h
    exact h hφ hψ

/--
**Reynolds Theorem 5 (discrete case)**: In a discrete order, `flatten_stavi`
is semantically correct: the flattened formula has the same truth value as
the original StaviFormula at every point.

This means {U,S} is expressively complete for discrete linear orders:
any StaviFormula (and hence any monadic FO formula, via Theorem 4) has
a {U,S}-equivalent.
-/
theorem flatten_stavi_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds) (t : M.carrier) (sf : StaviFormula) :
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
    show _ ↔ temporal_truth M atomMap t
      (Formula.and (Formula.untl (flatten_stavi B) Formula.bot)
                   ((Formula.untl (flatten_stavi A) (flatten_stavi B)).neg))
    rw [temporal_truth_and, temporal_truth_neg]
    simp only [stavi_temporal_truth]
    constructor
    · rintro ⟨h_cofinal, h_not_until⟩
      refine ⟨?_, ?_⟩
      · -- B cofinal above t (stavi version) → U(flatten B, ⊥)
        rw [until_bot_iff_succ]
        have : stavi_temporal_truth M atomMap (Order.succ t) B := by
          have ⟨r, htr, hrs, hBr⟩ := h_cofinal (Order.succ t) (Order.lt_succ t)
          have h_eq : r = Order.succ t := le_antisymm hrs (SuccOrder.succ_le_of_lt htr)
          exact h_eq ▸ hBr
        exact (ihB _).mp this
      · -- ¬stavi Until → ¬U(flatten A, flatten B)
        simp only [temporal_truth]
        intro ⟨s, hts, hAs, hBguard⟩
        exact h_not_until ⟨s, hts, (ihA s).mpr hAs,
          fun r htr hrs => (ihB r).mpr (hBguard r htr hrs)⟩
    · rintro ⟨h_next, h_not_until⟩
      refine ⟨?_, ?_⟩
      · -- U(flatten B, ⊥) → B cofinal (stavi version)
        rw [until_bot_iff_succ] at h_next
        intro s hts
        exact ⟨Order.succ t, Order.lt_succ t, SuccOrder.succ_le_of_lt hts,
          (ihB _).mpr h_next⟩
      · -- ¬U(flatten A, flatten B) → ¬stavi exists
        simp only [temporal_truth] at h_not_until
        intro ⟨s, hts, hAs, hBguard⟩
        exact h_not_until ⟨s, hts, (ihA s).mp hAs,
          fun r htr hrs => (ihB r).mp (hBguard r htr hrs)⟩
  | stavi_snce A B ihA ihB =>
    show _ ↔ temporal_truth M atomMap t
      (Formula.and (Formula.snce (flatten_stavi B) Formula.bot)
                   ((Formula.snce (flatten_stavi A) (flatten_stavi B)).neg))
    rw [temporal_truth_and, temporal_truth_neg]
    simp only [stavi_temporal_truth]
    constructor
    · rintro ⟨h_cofinal, h_not_since⟩
      refine ⟨?_, ?_⟩
      · rw [since_bot_iff_pred]
        have : stavi_temporal_truth M atomMap (Order.pred t) B := by
          have ⟨r, hsr, hrt, hBr⟩ := h_cofinal (Order.pred t) (Order.pred_lt t)
          have h_eq : r = Order.pred t := le_antisymm (PredOrder.le_pred_of_lt hrt) hsr
          exact h_eq ▸ hBr
        exact (ihB _).mp this
      · simp only [temporal_truth]
        intro ⟨s, hst, hAs, hBguard⟩
        exact h_not_since ⟨s, hst, (ihA s).mpr hAs,
          fun r hsr hrt => (ihB r).mpr (hBguard r hsr hrt)⟩
    · rintro ⟨h_prev, h_not_since⟩
      refine ⟨?_, ?_⟩
      · rw [since_bot_iff_pred] at h_prev
        intro s hst
        exact ⟨Order.pred t, PredOrder.le_pred_of_lt hst, Order.pred_lt t,
          (ihB _).mpr h_prev⟩
      · simp only [temporal_truth] at h_not_since
        intro ⟨s, hst, hAs, hBguard⟩
        exact h_not_since ⟨s, hst, (ihA s).mp hAs,
          fun r hsr hrt => (ihB r).mp (hBguard r hsr hrt)⟩

end Bimodal.Metalogic.WeakCanonical
