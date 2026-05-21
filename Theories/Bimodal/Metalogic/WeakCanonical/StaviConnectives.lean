import Bimodal.Metalogic.WeakCanonical.Table

/-!
# Stavi Connectives: U'(A,B) and S'(A,B)

Defines the Stavi connective semantics U'(A,B) and S'(A,B) for the Reynolds
pipeline. These connectives detect "gap" behavior in linear temporal structures:
U'(A,B) holds when there is a gap in the truth of B above t, with A holding
beyond the gap and B holding on an initial segment before the gap.

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

### Semantic Definition (GHR93, Section 3, p. 95 — First-Order Table)

U'(p,q)(t) holds iff there exists s > t such that:
1. For all u in (t,s): either q is cofinal above u (i.e., exists v > u
   with q on (t,v)), or A holds on (u,s) and q has already failed before u.
2. q fails somewhere in (t,s): exists u in (t,s) with not q(u).
3. q holds on an initial segment: exists u in (t,s) with q on (t,u).

S'(A,B)(t) is the temporal dual (past direction).

### Key Property

In any discrete linear order (Z), U'(A,B) is always false. Proof:
the first point u0 where q fails cannot satisfy either disjunct in (1),
because Disjunct 1 needs q beyond u0 (but q(u0) = false), and Disjunct 2
needs a not-q witness before u0 (contradicting minimality).

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Section 3 (p. 95)
- BdRV 2002, Definition 7.11 (gap-based picture)
- Reynolds 1994, Section 4 (p.122-124)
- Task 155 plan: Phase 0 (U'/S' Semantics Fix)
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## Stavi Connective Semantics -/

/--
Semantic truth of the Stavi Until connective U'(A,B) at time t.

From GHR93 Section 3 (p. 95), the first-order translation table.

U'(A,B)(t) holds iff there exists s > t such that:
1. **Main body**: For all u in (t,s), either:
   - B is cofinal above u: exists v > u with B on (t,v), OR
   - A holds on (u,s) and B has failed before u: exists v' in (t,u) with not B(v')
2. **B fails somewhere**: exists u in (t,s) with not B(u)
3. **B holds initially**: exists u in (t,s) with B on (t,u)

This captures "gap" behavior: B holds on an initial segment (3),
then fails at a transition point (2), while the overall interval (t,s)
satisfies the gap-detection body (1).

In discrete orders (Z), U'(A,B) is ALWAYS FALSE: the first point
where B fails cannot satisfy either disjunct in (1).
-/
def stavi_U_truth {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier) (A B : Formula) : Prop :=
  ∃ s : M.carrier, t < s ∧
    -- (1) Main body: for all u in (t,s), disjunction holds
    (∀ u : M.carrier, t < u → u < s →
      -- Disjunct 1: B cofinal above u (exists v > u with B on (t,v))
      (∃ v : M.carrier, u < v ∧ ∀ w : M.carrier, t < w → w < v →
        temporal_truth M atomMap w B) ∨
      -- Disjunct 2: A on (u,s) and B failed before u
      ((∀ v : M.carrier, u < v → v < s → temporal_truth M atomMap v A) ∧
       ∃ v' : M.carrier, t < v' ∧ v' < u ∧ ¬ temporal_truth M atomMap v' B)) ∧
    -- (2) B fails somewhere in (t,s)
    (∃ u : M.carrier, t < u ∧ u < s ∧ ¬ temporal_truth M atomMap u B) ∧
    -- (3) B holds on some initial segment in (t,s)
    (∃ u : M.carrier, t < u ∧ u < s ∧
      ∀ v : M.carrier, t < v → v < u → temporal_truth M atomMap v B)

/--
Semantic truth of the Stavi Since connective S'(A,B) at time t.

Past-directed dual of U'(A,B), from the GHR93 first-order table.

S'(A,B)(t) holds iff there exists s < t such that:
1. For all u in (s,t), either:
   - B is cofinal below u: exists v < u with B on (v,t), OR
   - A holds on (s,u) and B has failed after u: exists v' in (u,t) with not B(v')
2. B fails somewhere in (s,t)
3. B holds on some final segment in (s,t): exists u in (s,t) with B on (u,t)
-/
def stavi_S_truth {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier) (A B : Formula) : Prop :=
  ∃ s : M.carrier, s < t ∧
    -- (1) Main body: for all u in (s,t), disjunction holds
    (∀ u : M.carrier, s < u → u < t →
      -- Disjunct 1: B cofinal below u (exists v < u with B on (v,t))
      (∃ v : M.carrier, v < u ∧ ∀ w : M.carrier, v < w → w < t →
        temporal_truth M atomMap w B) ∨
      -- Disjunct 2: A on (s,u) and B failed after u
      ((∀ v : M.carrier, s < v → v < u → temporal_truth M atomMap v A) ∧
       ∃ v' : M.carrier, u < v' ∧ v' < t ∧ ¬ temporal_truth M atomMap v' B)) ∧
    -- (2) B fails somewhere in (s,t)
    (∃ u : M.carrier, s < u ∧ u < t ∧ ¬ temporal_truth M atomMap u B) ∧
    -- (3) B holds on some final segment in (s,t)
    (∃ u : M.carrier, s < u ∧ u < t ∧
      ∀ v : M.carrier, u < v → v < t → temporal_truth M atomMap v B)

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
    -- GHR93 FO table for U'(A,B)(t)
    ∃ s : M.carrier, t < s ∧
      -- (1) Main body
      (∀ u : M.carrier, t < u → u < s →
        (∃ v : M.carrier, u < v ∧ ∀ w : M.carrier, t < w → w < v →
          stavi_temporal_truth M atomMap w B) ∨
        ((∀ v : M.carrier, u < v → v < s → stavi_temporal_truth M atomMap v A) ∧
         ∃ v' : M.carrier, t < v' ∧ v' < u ∧ ¬ stavi_temporal_truth M atomMap v' B)) ∧
      -- (2) B fails somewhere
      (∃ u : M.carrier, t < u ∧ u < s ∧ ¬ stavi_temporal_truth M atomMap u B) ∧
      -- (3) B holds initially
      (∃ u : M.carrier, t < u ∧ u < s ∧
        ∀ v : M.carrier, t < v → v < u → stavi_temporal_truth M atomMap v B)
  | .stavi_snce A B =>
    -- GHR93 FO table for S'(A,B)(t) — past dual
    ∃ s : M.carrier, s < t ∧
      -- (1) Main body
      (∀ u : M.carrier, s < u → u < t →
        (∃ v : M.carrier, v < u ∧ ∀ w : M.carrier, v < w → w < t →
          stavi_temporal_truth M atomMap w B) ∨
        ((∀ v : M.carrier, s < v → v < u → stavi_temporal_truth M atomMap v A) ∧
         ∃ v' : M.carrier, u < v' ∧ v' < t ∧ ¬ stavi_temporal_truth M atomMap v' B)) ∧
      -- (2) B fails somewhere
      (∃ u : M.carrier, s < u ∧ u < t ∧ ¬ stavi_temporal_truth M atomMap u B) ∧
      -- (3) B holds on final segment
      (∃ u : M.carrier, s < u ∧ u < t ∧
        ∀ v : M.carrier, u < v → v < t → stavi_temporal_truth M atomMap v B)
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


/-! ## Stavi Connectives in Discrete Orders (Phase 0 / Phase 5)

In a discrete order (SuccOrder + PredOrder), the Stavi connectives U'(A,B)
and S'(A,B) are ALWAYS FALSE. This is because the GHR93 FO table definition
requires a gap-like structure, but discrete orders have no Dedekind gaps.

### Proof sketch (U' always false on Z):
Suppose U'(A,B)(t) holds with witness s > t. Conjunct (2) gives a point
u0 in (t,s) where B fails. Take u0 to be the SMALLEST such point.
Evaluate Conjunct (1) at u0:
- Disjunct 1 needs v > u0 with B on (t,v). But u0 is in (t,v) for any
  v > u0, and B(u0) = false. Contradiction.
- Disjunct 2 needs v' in (t,u0) with not-B(v'). But by minimality of u0,
  B holds on all of (t,u0). If u0 = succ(t), (t,u0) is empty.
  Either way, no such v' exists. Contradiction.

Both disjuncts fail, contradicting Conjunct (1). QED.

Since U' and S' are always false, the flattening maps them to ⊥,
and {U,S} is expressively complete for discrete linear orders.

### Cofinal lemmas (retained for other uses):
- B cofinal above t ↔ B(succ(t))
- B cofinal below t ↔ B(pred(t))
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
In a discrete order with IsSuccArchimedean, the GHR93 FO table body forces
P to hold at every point in (t,s).

Proof by strong induction on the succ-iterate index n: P(succ^n(succ(t))).
Disjunct 1 directly gives P(u). Disjunct 2 gives ¬P(v') for some v' < u
with v' > t, contradicting the strong IH since v' = succ^j(succ(t)) with j < n.
-/
private theorem fo_table_body_forces_P {α : Type*} [Preorder α]
    [SuccOrder α] [NoMaxOrder α] [IsSuccArchimedean α]
    {P : α → Prop} {t s : α} (_hts : t < s)
    (h_body : ∀ u : α, t < u → u < s →
      (∃ v : α, u < v ∧ ∀ w : α, t < w → w < v → P w) ∨
      (∃ v' : α, t < v' ∧ v' < u ∧ ¬ P v'))
    (h_fail : ∃ u : α, t < u ∧ u < s ∧ ¬ P u) : False := by
  -- It suffices to show P holds everywhere in (t,s), contradicting h_fail.
  suffices h_all : ∀ u, t < u → u < s → P u by
    obtain ⟨u0, htu0, hu0s, hPu0⟩ := h_fail
    exact hPu0 (h_all u0 htu0 hu0s)
  -- Prove by strong induction on the succ-iterate index
  intro u htu hus
  have hle : Order.succ t ≤ u := SuccOrder.succ_le_of_lt htu
  obtain ⟨n, rfl⟩ := IsSuccArchimedean.exists_succ_iterate_of_le hle
  clear hle htu
  -- Strong induction on n
  induction n using Nat.strongRecOn with
  | _ n ih =>
    have htu : t < (Order.succ)^[n] (Order.succ t) :=
      lt_of_lt_of_le (Order.lt_succ t)
        (Function.id_le_iterate_of_id_le (fun (x : α) => Order.le_succ x) n (Order.succ t))
    have h_disj := h_body _ htu hus
    cases h_disj with
    | inl h =>
      -- Disjunct 1: ∃ v > u, P on (t,v). Since t < u < v, P(u).
      obtain ⟨v, huv, hPv⟩ := h
      exact hPv _ htu huv
    | inr h =>
      -- Disjunct 2: ∃ v' in (t, u) with ¬P(v'). Contradicts IH.
      exfalso
      obtain ⟨v', htv', hv'u, hPv'⟩ := h
      have hv'_le : Order.succ t ≤ v' := SuccOrder.succ_le_of_lt htv'
      obtain ⟨j, rfl⟩ := IsSuccArchimedean.exists_succ_iterate_of_le hv'_le
      have hjs : (Order.succ)^[j] (Order.succ t) < s := lt_trans hv'u hus
      have hj_lt_n : j < n := by
        by_contra h_ge
        push_neg at h_ge
        -- succ is monotone on iterates, so n ≤ j implies succ^n ≤ succ^j
        have h_mono := Function.monotone_iterate_of_id_le
          (fun (x : α) => Order.le_succ x)
        have h_le : (Order.succ)^[n] (Order.succ t) ≤
            (Order.succ)^[j] (Order.succ t) := h_mono h_ge (Order.succ t)
        exact absurd (lt_of_lt_of_le hv'u h_le) (lt_irrefl _)
      exact hPv' (ih j hj_lt_n hjs)

/--
Past-directed dual of `fo_table_body_forces_P`.
In a discrete order with IsPredArchimedean, the S' FO table body forces
P to hold at every point in (s,t).
-/
private theorem fo_table_body_forces_P_past {α : Type*} [Preorder α]
    [PredOrder α] [NoMinOrder α] [IsPredArchimedean α]
    {P : α → Prop} {s t : α} (_hst : s < t)
    (h_body : ∀ u : α, s < u → u < t →
      (∃ v : α, v < u ∧ ∀ w : α, v < w → w < t → P w) ∨
      (∃ v' : α, u < v' ∧ v' < t ∧ ¬ P v'))
    (h_fail : ∃ u : α, s < u ∧ u < t ∧ ¬ P u) : False := by
  suffices h_all : ∀ u, s < u → u < t → P u by
    obtain ⟨u0, hsu0, hu0t, hPu0⟩ := h_fail
    exact hPu0 (h_all u0 hsu0 hu0t)
  intro u hsu hut
  have hle : u ≤ Order.pred t := PredOrder.le_pred_of_lt hut
  obtain ⟨n, rfl⟩ := IsPredArchimedean.exists_pred_iterate_of_le hle
  clear hle hut
  induction n using Nat.strongRecOn with
  | _ n ih =>
    have h_anti := Function.antitone_iterate_of_le_id (fun (x : α) => Order.pred_le x)
    have hut : (Order.pred)^[n] (Order.pred t) < t := by
      calc (Order.pred)^[n] (Order.pred t)
        ≤ (Order.pred)^[0] (Order.pred t) := h_anti (Nat.zero_le n) (Order.pred t)
        _ = Order.pred t := by simp
        _ < t := Order.pred_lt t
    have h_disj := h_body _ hsu hut
    cases h_disj with
    | inl h =>
      -- Disjunct 1: ∃ v < u, P on (v, t). Since v < u < t, P(u).
      obtain ⟨v, hvu, hPv⟩ := h
      exact hPv _ hvu hut
    | inr h =>
      -- Disjunct 2: ∃ v' in (u, t) with ¬P(v'). Contradicts IH.
      exfalso
      obtain ⟨v', huv', hv't, hPv'⟩ := h
      have hv'_le : v' ≤ Order.pred t := PredOrder.le_pred_of_lt hv't
      obtain ⟨j, rfl⟩ := IsPredArchimedean.exists_pred_iterate_of_le hv'_le
      have hjs : s < (Order.pred)^[j] (Order.pred t) := lt_trans hsu huv'
      have hj_lt_n : j < n := by
        by_contra h_ge
        push_neg at h_ge
        -- pred is antitone on iterates: n ≤ j implies pred^[j] ≤ pred^[n]
        have h_le : (Order.pred)^[j] (Order.pred t) ≤
            (Order.pred)^[n] (Order.pred t) :=
          Function.antitone_iterate_of_le_id
            (fun (x : α) => Order.pred_le x) h_ge (Order.pred t)
        exact absurd (lt_of_lt_of_le huv' h_le) (lt_irrefl _)
      exact hPv' (ih j hj_lt_n hjs)

/--
Convert a StaviFormula to a standard temporal Formula in a discrete order.

In a discrete order (SuccOrder + PredOrder), every StaviFormula has an
equivalent standard temporal formula because U'(A,B) and S'(A,B) are
ALWAYS FALSE on discrete orders (no Dedekind gaps exist). Therefore
the flattening maps both to ⊥.

The conversion is structural: base formulas are unchanged, negation and
conjunction are standard, and U'/S' are replaced by ⊥.
-/
noncomputable def flatten_stavi : StaviFormula → Formula
  | .base φ => φ
  | .neg φ => (flatten_stavi φ).neg
  | .conj φ ψ => Formula.and (flatten_stavi φ) (flatten_stavi ψ)
  | .stavi_untl _A _B =>
    -- U'(A,B) is always false on discrete orders, so flatten to ⊥
    Formula.bot
  | .stavi_snce _A _B =>
    -- S'(A,B) is always false on discrete orders, so flatten to ⊥
    Formula.bot

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

Requires `IsSuccArchimedean` and `IsPredArchimedean` for well-founded
descent on bounded intervals (proving U'/S' always false on discrete orders).
-/
theorem flatten_stavi_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [IsSuccArchimedean M.carrier] [IsPredArchimedean M.carrier]
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
    -- flatten_stavi (.stavi_untl A B) = .bot
    -- Need: (FO table exists ...) <-> temporal_truth t .bot = (FO table) <-> False
    simp only [flatten_stavi, temporal_truth]
    constructor
    · -- Forward: FO table → False (U' always false on discrete orders)
      simp only [stavi_temporal_truth]
      intro ⟨s, hts, h_body, h_fail, _⟩
      -- Convert stavi body to P-body using IHs, then apply fo_table_body_forces_P
      exact fo_table_body_forces_P hts
        (fun u htu hus => by
          have := h_body u htu hus
          cases this with
          | inl h =>
            left
            obtain ⟨v, huv, hBv⟩ := h
            exact ⟨v, huv, fun w htw hwv => (ihB w).mp (hBv w htw hwv)⟩
          | inr h =>
            right
            obtain ⟨_, v', htv', hvu, hBv'⟩ := h
            exact ⟨v', htv', hvu, fun h => hBv' ((ihB v').mpr h)⟩)
        (by
          obtain ⟨u, htu, hus, hBu⟩ := h_fail
          exact ⟨u, htu, hus, fun h => hBu ((ihB u).mpr h)⟩)
    · -- Backward: False → FO table (vacuous)
      exact False.elim
  | stavi_snce A B ihA ihB =>
    -- flatten_stavi (.stavi_snce A B) = .bot (S' always false on discrete)
    simp only [flatten_stavi, temporal_truth]
    constructor
    · -- Forward: S' FO table → False (dual of U' case)
      simp only [stavi_temporal_truth]
      intro ⟨s, hst, h_body, h_fail, _⟩
      exact fo_table_body_forces_P_past hst
        (fun u hsu hut => by
          have := h_body u hsu hut
          cases this with
          | inl h =>
            left
            obtain ⟨v, hvu, hBv⟩ := h
            exact ⟨v, hvu, fun w hvw hwt => (ihB w).mp (hBv w hvw hwt)⟩
          | inr h =>
            right
            obtain ⟨_, v', huv', hv't, hBv'⟩ := h
            exact ⟨v', huv', hv't, fun h => hBv' ((ihB v').mpr h)⟩)
        (by
          obtain ⟨u, hsu, hut, hBu⟩ := h_fail
          exact ⟨u, hsu, hut, fun h => hBu ((ihB u).mpr h)⟩)
    · -- Backward: False → S' FO table (vacuous)
      exact False.elim

end Bimodal.Metalogic.WeakCanonical
