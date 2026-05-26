import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm
import Bimodal.Metalogic.WeakCanonical.MonadicFO

/-!
# Quantifier Elimination and Atom Elimination for Expressive Completeness

Quantifier elimination and atom elimination for the FO-to-temporal translation.
This module provides the core infrastructure for translating monadic first-order
formulas over (Z, <) into temporal formulas using Since and Until.

## Contents

- FO-to-temporal infrastructure: `IntStructureFromSig`, `int_to_ordered`, `to_int_struct`
- The `q_exists` connective for existential quantification over Z
- Purity semantic lemmas: past-only and future-only formulas
- Substitution under purity
- Extended signature (`ExtPred`, `extSignature`) for quantifier elimination
- `reduceElimLast`: eliminates the last variable from a formula
- Quantifier depth preservation
- Semantic correctness of `reduceElimLast`
- Atom elimination infrastructure: `applySubsts`, `elimExtFromSep`, `quantElimFormula`
- Guard formula correctness
- Atom containment lemmas

## References

- GHR94, Chapter 9, Section 9.3
- Reynolds (2010), Theorem 5
-/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical.Separation

/-! ## FO-to-Temporal Infrastructure -/

/-- An integer structure with a monadic signature: interprets predicates on Z. -/
structure IntStructureFromSig (sig : MonadicSignature) where
  interp : sig.preds → Int → Prop

/-- Convert an IntStructureFromSig to an OrderedMonadicStructure. -/
def int_to_ordered (sig : MonadicSignature) (M : IntStructureFromSig sig) :
    OrderedMonadicStructure sig where
  carrier := Int
  interp := M.interp
  carrier_order := inferInstance

/-- Convert IntStructureFromSig to IntStructure given an atom map.
    Each predicate p in the signature is mapped to the atom atomMap(p),
    and the valuation of that atom is the interpretation of p. -/
def to_int_struct {sig : MonadicSignature} (M : IntStructureFromSig sig)
    (atomMap : sig.preds → Atom) : Separation.IntStructure where
  val a := {t : Int | ∃ p : sig.preds, atomMap p = a ∧ M.interp p t}

/-- The Q_exists connective: "exists sometime" = P(A) v A v F(A).
    This captures existential quantification over Z when applied to
    a temporal formula. -/
def q_exists (A : Formula) : Formula :=
  Formula.or (Formula.or (Formula.some_past A) A) (Formula.some_future A)

/-- Q_exists correctly captures existential quantification over Z:
    int_truth M t (q_exists A) iff exists s, int_truth M s A -/
theorem q_exists_correct (A : Formula) (M : Separation.IntStructure) (t : Int) :
    Separation.int_truth M t (q_exists A) ↔ ∃ s : Int, Separation.int_truth M s A := by
  -- q_exists A = or(or(some_past A, A), some_future A)
  -- some_past A = neg(all_past(neg A)) = (all_past(A → ⊥)) → ⊥
  -- some_future A = neg(all_future(neg A)) = (all_future(A → ⊥)) → ⊥
  -- or X Y = (X → ⊥) → Y
  -- Unfolding int_truth:
  -- int_truth of some_past A at t = (∀ s < t, int_truth M s A → False) → False
  --   = ¬(∀ s < t, ¬A(s)) = ∃ s < t, A(s) (classically)
  -- int_truth of some_future A at t = (∀ s, t < s → int_truth M s A → False) → False
  --   = ¬(∀ s > t, ¬A(s)) = ∃ s > t, A(s) (classically)
  -- q_exists A = or(or(some_past A, A), some_future A)
  -- Unfold at the semantic level and reason directly.
  constructor
  · -- (→): q_exists A at t → ∃ s, A(s)
    intro h
    by_contra h_none
    push_neg at h_none
    -- h_none : ∀ s, ¬ Separation.int_truth M s A
    -- q_exists A at t is: or(or(some_past A, A), some_future A)
    -- At the int_truth level (after encoding through imp/neg):
    -- int_truth of or X Y = (int_truth X → False) → int_truth Y
    -- int_truth of some_past A = (∀s<t, int_truth s A → False) → False
    -- int_truth of some_future A = (∀s, t<s → int_truth s A → False) → False
    -- We show the q_exists formula is False under h_none.
    -- or(or(sp, A), sf) where sp = some_past A, sf = some_future A
    -- Unfolding: ((sp → ⊥) → A(t)) → ⊥) → ((∀s>t, A(s) → ⊥) → ⊥)
    -- Under h_none: A(t) = False, A(s) = False for all s.
    -- sp = ((∀s<t, A(s)→⊥) → ⊥) = (True → ⊥) = ⊥  [since ∀s<t, ¬A(s) is true]
    -- or(sp, A) = (sp→⊥) → A(t) = (⊥→⊥) → ⊥ = True → ⊥ = ⊥
    -- ¬or(sp,A) = (⊥→⊥) = True
    -- sf = (∀s>t, A(s)→⊥) → ⊥ = True → ⊥ = ⊥
    -- q_exists = (¬or(sp,A)) → sf = True → ⊥ = ⊥
    -- So h : ⊥.
    -- Lean proof: step through the encoding.
    have hA_never : ∀ s : ℤ, ¬ Separation.int_truth M s A := h_none
    -- h has type: int_truth M t (q_exists A)
    -- After unfolding q_exists, or, neg, some_past, some_future in int_truth:
    show False
    simp only [q_exists, Formula.or, Formula.neg, Separation.int_truth_some_past,
               Separation.int_truth_some_future, Separation.int_truth] at h
    obtain ⟨s, _, hs⟩ := h (fun f => (hA_never t (f (fun ⟨s, _, hs⟩ => (hA_never s hs).elim))).elim)
    exact hA_never s hs

  · -- (←): ∃ s, A(s) → q_exists A at t
    intro ⟨s, hs⟩
    -- Case split: s < t, s = t, or s > t
    rcases lt_trichotomy s t with hst | hst | hst
    · -- s < t: some_past A holds
      -- q_exists = or(or(some_past A, A), some_future A)
      -- Show or(or(sp, A), sf): assume ¬or(sp, A), show sf
      -- Actually show or(sp, A) first: assume ¬sp, show A.
      -- ¬sp: ∀ s < t, ¬A(s). But A(s) holds with s < t. Contradiction.
      -- So or(sp, A) holds (via sp).
      -- Then or(or(sp, A), sf) holds (via the left disjunct).
      intro h_neg
      -- h_neg : ¬(or(some_past A, A)) = ((¬sp → A) → ⊥)
      -- We show some_future A, but we don't need to since h_neg is contradictory
      exfalso
      apply h_neg
      -- Need: ¬sp → A(t), i.e., (sp → ⊥) → A(t)
      -- sp = ((∀ s' < t, A(s') → ⊥) → ⊥)
      intro h_neg_sp
      -- h_neg_sp : sp → ⊥ = (((∀ s' < t, A(s') → ⊥) → ⊥) → ⊥)
      -- = ∀ s' < t, A(s') → ⊥ (by double negation of the inner)
      -- Actually: sp = (∀ s' < t, A(s') → ⊥) → ⊥
      -- h_neg_sp : sp → ⊥ = ((∀ s' < t, A(s') → ⊥) → ⊥) → ⊥
      -- This means: ∀ s' < t, A(s') → ⊥ (extracting from double neg)
      -- But we have A(s) with s < t. Contradiction!
      exfalso
      apply h_neg_sp
      simp only [Separation.int_truth_some_past]
      exact ⟨s, hst, hs⟩
    · -- s = t: A at t holds
      subst hst
      intro h_neg
      exfalso
      apply h_neg
      intro h_neg_sp
      exact hs
    · -- s > t: some_future A holds
      intro _h_neg
      -- Need: some_future A at t
      simp only [Separation.int_truth_some_future]
      exact ⟨s, hst, hs⟩

/-! ## Purity Semantic Lemmas

These lemmas establish that syntactic purity (is_past_only, is_future_only)
implies semantic purity: past-only formulas depend only on times < t,
and future-only formulas depend only on times > t. -/

/-- Syntactically past-only formulas are semantically pure-past:
    their truth at t depends only on the valuation at times ≤ t. -/
theorem past_only_is_pure_past {φ : Formula} (h : Separation.is_past_only φ = true) :
    ∀ (M₁ M₂ : Separation.IntStructure) (t : Int),
      (∀ (a : Bimodal.Syntax.Atom) (s : Int), s ≤ t → (s ∈ M₁.val a ↔ s ∈ M₂.val a)) →
      (Separation.int_truth M₁ t φ ↔ Separation.int_truth M₂ t φ) := by
  induction φ with
  | atom a =>
    intro M₁ M₂ t hagree
    simp only [Separation.int_truth]
    exact hagree a t (le_refl t)
  | bot =>
    intro _ _ _ _
    exact Iff.rfl
  | imp α β ihα ihβ =>
    simp only [Separation.is_past_only, Bool.and_eq_true] at h
    intro M₁ M₂ t hagree
    have hα_iff := ihα h.1 M₁ M₂ t hagree
    have hβ_iff := ihβ h.2 M₁ M₂ t hagree
    constructor
    · intro h12 hα2; exact hβ_iff.mp (h12 (hα_iff.mpr hα2))
    · intro h12 hα1; exact hβ_iff.mpr (h12 (hα_iff.mp hα1))
  | box _ =>
    intro _ _ _ _
    exact Iff.rfl
  | untl _ _ =>
    exact absurd h (by simp [Separation.is_past_only])
  | snce α β ihα ihβ =>
    simp only [Separation.is_past_only, Bool.and_eq_true] at h
    intro M₁ M₂ t hagree
    constructor
    · rintro ⟨s, hst, hα, hβ⟩
      exact ⟨s, hst,
        (ihα h.1 M₁ M₂ s (fun a r hrs => hagree a r (le_trans hrs (le_of_lt hst)))).mp hα,
        fun r hr1 hr2 =>
          (ihβ h.2 M₁ M₂ r (fun a u hur => hagree a u (le_trans hur (le_of_lt hr2)))).mp (hβ r hr1 hr2)⟩
    · rintro ⟨s, hst, hα, hβ⟩
      exact ⟨s, hst,
        (ihα h.1 M₁ M₂ s (fun a r hrs => hagree a r (le_trans hrs (le_of_lt hst)))).mpr hα,
        fun r hr1 hr2 =>
          (ihβ h.2 M₁ M₂ r (fun a u hur => hagree a u (le_trans hur (le_of_lt hr2)))).mpr (hβ r hr1 hr2)⟩

/-- Syntactically future-only formulas are semantically pure-future:
    their truth at t depends only on the valuation at times ≥ t. -/
theorem future_only_is_pure_future {φ : Formula} (h : Separation.is_future_only φ = true) :
    ∀ (M₁ M₂ : Separation.IntStructure) (t : Int),
      (∀ (a : Bimodal.Syntax.Atom) (s : Int), t ≤ s → (s ∈ M₁.val a ↔ s ∈ M₂.val a)) →
      (Separation.int_truth M₁ t φ ↔ Separation.int_truth M₂ t φ) := by
  induction φ with
  | atom a =>
    intro M₁ M₂ t hagree
    simp only [Separation.int_truth]
    exact hagree a t (le_refl t)
  | bot =>
    intro _ _ _ _
    exact Iff.rfl
  | imp α β ihα ihβ =>
    simp only [Separation.is_future_only, Bool.and_eq_true] at h
    intro M₁ M₂ t hagree
    have hα_iff := ihα h.1 M₁ M₂ t hagree
    have hβ_iff := ihβ h.2 M₁ M₂ t hagree
    constructor
    · intro h12 hα2; exact hβ_iff.mp (h12 (hα_iff.mpr hα2))
    · intro h12 hα1; exact hβ_iff.mpr (h12 (hα_iff.mp hα1))
  | box _ =>
    intro _ _ _ _
    exact Iff.rfl
  | untl α β ihα ihβ =>
    simp only [Separation.is_future_only, Bool.and_eq_true] at h
    intro M₁ M₂ t hagree
    constructor
    · rintro ⟨s, hts, hα, hβ⟩
      exact ⟨s, hts,
        (ihα h.1 M₁ M₂ s (fun a r hrs => hagree a r (le_trans (le_of_lt hts) hrs))).mp hα,
        fun r hr1 hr2 =>
          (ihβ h.2 M₁ M₂ r (fun a u hur => hagree a u (le_trans (le_of_lt hr1) hur))).mp (hβ r hr1 hr2)⟩
    · rintro ⟨s, hts, hα, hβ⟩
      exact ⟨s, hts,
        (ihα h.1 M₁ M₂ s (fun a r hrs => hagree a r (le_trans (le_of_lt hts) hrs))).mpr hα,
        fun r hr1 hr2 =>
          (ihβ h.2 M₁ M₂ r (fun a u hur => hagree a u (le_trans (le_of_lt hr1) hur))).mpr (hβ r hr1 hr2)⟩
  | snce _ _ =>
    exact absurd h (by simp [Separation.is_future_only])

/-! ## Substitution under Purity

When a properly separated formula is decomposed, atoms in past-only parts
can be substituted based on the fact that those parts only evaluate at past times,
and atoms in future-only parts can be substituted based on future evaluation. -/

/-- In a past-only formula, substituting an atom whose truth at times ≤ t matches
    a replacement formula preserves truth at t. -/
theorem past_only_subst_correct {φ : Formula} (hpo : Separation.is_past_only φ = true)
    (target : Bimodal.Syntax.Atom) (replacement : Formula)
    (M : Separation.IntStructure) (t : Int)
    (h_match : ∀ s : Int, s ≤ t →
      (Separation.int_truth M s replacement ↔ s ∈ M.val target)) :
    Separation.int_truth M t (Separation.subst_formula φ target replacement) ↔
    Separation.int_truth M t φ := by
  rw [Separation.subst_correctness]
  apply past_only_is_pure_past hpo
  intro a s hst
  simp only [Separation.IntStructure.withAtom]
  split
  · next heq => subst heq; simp only [Set.mem_setOf_eq]; exact h_match s hst
  · exact Iff.rfl

/-- In a future-only formula, substituting an atom whose truth at times ≥ t matches
    a replacement formula preserves truth at t. -/
theorem future_only_subst_correct {φ : Formula} (hfo : Separation.is_future_only φ = true)
    (target : Bimodal.Syntax.Atom) (replacement : Formula)
    (M : Separation.IntStructure) (t : Int)
    (h_match : ∀ s : Int, t ≤ s →
      (Separation.int_truth M s replacement ↔ s ∈ M.val target)) :
    Separation.int_truth M t (Separation.subst_formula φ target replacement) ↔
    Separation.int_truth M t φ := by
  rw [Separation.subst_correctness]
  apply future_only_is_pure_future hfo
  intro a s hts
  simp only [Separation.IntStructure.withAtom]
  split
  · next heq => subst heq; simp only [Set.mem_setOf_eq]; exact h_match s hts
  · exact Iff.rfl

/-! ## Theorem 9.3.1: Separation Implies Expressive Completeness -/

/-- Helper: Every element of `Fin 1` is `⟨0, _⟩`. -/
private theorem fin1_eq_zero (i : Fin 1) : i = ⟨0, Nat.zero_lt_one⟩ :=
  Fin.ext (Nat.lt_one_iff.mp i.isLt)

/-- Helper: `Fin.cons t Fin.elim0 = fun _ => t` for environments over Fin 1. -/
private theorem env_fin1_cons {α : Type} (t : α) :
    (Fin.cons t Fin.elim0 : Fin 1 → α) = (fun _ => t) := by
  funext i; rw [fin1_eq_zero i]; rfl

/-! ### Extended Signature for Quantifier Elimination

When translating `∃z. α(z, t)` from FO to temporal logic, we replace the
two-variable formula with a one-variable formula over an extended signature.
The extended signature adds predicates that encode the ordering between the
quantified variable z and the reference time t, plus predicates for "P holds
at the reference time t" (which is constant relative to z). -/

/-- Extended predicate type: adds order-relation predicates and
    constant-at-reference predicates to the original signature. -/
inductive ExtPred (sig : MonadicSignature) where
  /-- Original predicate from sig -/
  | orig (p : sig.preds) : ExtPred sig
  /-- "P holds at reference time t" (constant predicate) -/
  | const_at_ref (p : sig.preds) : ExtPred sig
  /-- z < t: quantified variable is before reference time -/
  | lt_ref : ExtPred sig
  /-- t < z: reference time is before quantified variable -/
  | gt_ref : ExtPred sig
  deriving DecidableEq

instance {sig : MonadicSignature} : Fintype (ExtPred sig) where
  elems := (Finset.univ.map ⟨ExtPred.orig, fun _ _ h => by cases h; rfl⟩) ∪
    (Finset.univ.map ⟨ExtPred.const_at_ref, fun _ _ h => by cases h; rfl⟩) ∪
    {ExtPred.lt_ref, ExtPred.gt_ref}
  complete := by
    intro x
    cases x with
    | orig p => simp [Finset.mem_union, Finset.mem_map]
    | const_at_ref p => simp [Finset.mem_union, Finset.mem_map]
    | lt_ref => simp [Finset.mem_union]
    | gt_ref => simp [Finset.mem_union]

/-- The extended monadic signature. -/
def extSignature (sig : MonadicSignature) : MonadicSignature where
  preds := ExtPred sig

/-! ### Quantifier Elimination Reduction

The `reduce` function translates a formula with 2 free variables to one with
1 free variable over the extended signature, by replacing references to
variable 1 (the reference time t) with extended predicates. We specialize
to the case n=1 (from 2 to 1 variables) which is the only case needed
for Theorem 9.3.1. -/

/-- False in MonadicFormula with at least 1 free variable: x_0 < x_0 -/
private def monadicFalse (sig : MonadicSignature) (n : Nat) (h : 0 < n) :
    MonadicFormula sig n :=
  MonadicFormula.lt (Fin.mk 0 h) (Fin.mk 0 h)

/-- monadicFalse evaluates to False in any ordered structure. -/
private theorem monadicFalse_eval {sig : MonadicSignature} {n : Nat} (h : 0 < n)
    (M : OrderedMonadicStructure sig) (env : Fin n -> M.carrier) :
    eval M env (monadicFalse sig n h) = False := by
  simp [monadicFalse, eval]

/-- General reduction: eliminate the LAST variable (index n) from a formula with (n+1) variables.
    The last variable represents the reference time t. References to it are replaced by
    extended predicates (const_at_ref for atoms, lt_ref/gt_ref for order comparisons).
    This is well-founded by structural recursion on MonadicFormula. -/
noncomputable def reduceElimLast {sig : MonadicSignature} :
    (n : Nat) -> MonadicFormula sig (n + 1) -> MonadicFormula (extSignature sig) n
  | n, .atom p i =>
    if h : i.val < n then
      .atom (.orig p) (Fin.mk i.val h)
    else
      -- i.val = n: references the last variable (t)
      match n with
      | 0 => .all (monadicFalse (extSignature sig) 1 Nat.zero_lt_one) -- dummy sentence
      | Nat.succ m => .atom (.const_at_ref p) (Fin.mk 0 (Nat.zero_lt_succ m))
  | n, .lt i j =>
    if hi : i.val < n then
      if hj : j.val < n then
        .lt (Fin.mk i.val hi) (Fin.mk j.val hj)
      else
        -- i < n, j = n: var_i < t
        match n with
        | 0 => .all (monadicFalse (extSignature sig) 1 Nat.zero_lt_one)
        | Nat.succ m => .atom .lt_ref (Fin.mk i.val (by omega : i.val < m + 1))
    else
      if hj : j.val < n then
        -- i = n, j < n: t < var_j
        match n with
        | 0 => .all (monadicFalse (extSignature sig) 1 Nat.zero_lt_one)
        | Nat.succ m => .atom .gt_ref (Fin.mk j.val (by omega : j.val < m + 1))
      else
        -- i = n, j = n: t < t = False
        match n with
        | 0 => .all (monadicFalse (extSignature sig) 1 Nat.zero_lt_one)
        | Nat.succ m => monadicFalse (extSignature sig) (m + 1) (Nat.zero_lt_succ m)
  | n, .not beta => .not (reduceElimLast n beta)
  | n, .and beta gamma => .and (reduceElimLast n beta) (reduceElimLast n gamma)
  | n, .all beta => .all (reduceElimLast (n + 1) beta)
  | n, .ex beta => .ex (reduceElimLast (n + 1) beta)

/-! ### Quantifier Depth Preservation

The `reduceElimLast` operation preserves quantifier depth (for n ≥ 1),
which is needed for the well-founded induction in the quantifier case. -/

/-- reduceElimLast preserves quantifier depth for n ≥ 1. -/
noncomputable def qdepth_reduceElimLast_le {sig : MonadicSignature} :
    (n : Nat) → (hn : 0 < n) → (alpha : MonadicFormula sig (n + 1)) →
    (reduceElimLast n alpha).quantifier_depth ≤ alpha.quantifier_depth
  | _, _, .not beta => by
    simp only [reduceElimLast, MonadicFormula.quantifier_depth]
    exact qdepth_reduceElimLast_le _ (by assumption) beta
  | _, _, .and a b => by
    simp only [reduceElimLast, MonadicFormula.quantifier_depth]
    exact Nat.max_le.mpr ⟨le_max_of_le_left (qdepth_reduceElimLast_le _ (by assumption) a),
                           le_max_of_le_right (qdepth_reduceElimLast_le _ (by assumption) b)⟩
  | _, _, .all beta => by
    simp only [reduceElimLast, MonadicFormula.quantifier_depth]
    exact Nat.add_le_add_right (qdepth_reduceElimLast_le _ (by omega) beta) 1
  | _, _, .ex beta => by
    simp only [reduceElimLast, MonadicFormula.quantifier_depth]
    exact Nat.add_le_add_right (qdepth_reduceElimLast_le _ (by omega) beta) 1
  | n, hn, .atom _ _ => by
    simp only [reduceElimLast, MonadicFormula.quantifier_depth]
    split
    · exact Nat.zero_le _
    · match n, hn with
      | Nat.succ _, _ => exact Nat.zero_le _
  | n, hn, .lt _ _ => by
    simp only [reduceElimLast, MonadicFormula.quantifier_depth]
    split
    · split
      · exact Nat.zero_le _
      · match n, hn with | Nat.succ _, _ => exact Nat.zero_le _
    · split
      · match n, hn with | Nat.succ _, _ => exact Nat.zero_le _
      · match n, hn with | Nat.succ _, _ => exact Nat.zero_le _

/-! ### Extended IntStructure

Given a base model M over sig and a reference time t, we construct the
extended model over extSignature sig that interprets the extended predicates. -/

/-- The extended integer structure: interprets ExtPred based on a base model
    and reference time. Used in the semantic correctness proof for reduceElimLast.
    - `orig p` at time z = base model's P at z
    - `const_at_ref p` at time z = base model's P at reference time t (constant in z)
    - `lt_ref` at time z = (z < t)
    - `gt_ref` at time z = (t < z) -/
noncomputable def extIntStruct {sig : MonadicSignature}
    (M : IntStructureFromSig sig) (t_ref : Int) :
    IntStructureFromSig (extSignature sig) where
  interp ep z := match ep with
    | .orig p => M.interp p z
    | .const_at_ref p => M.interp p t_ref
    | .lt_ref => z < t_ref
    | .gt_ref => t_ref < z

/-- Atom map for the extended signature that extends the original atomMap.
    Critical property: extAtomMap atomMap (.orig p) = atomMap p, so that
    atoms for original predicates need no substitution after elimination. -/
noncomputable def extAtomMap {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) : (extSignature sig).preds → Atom
  | .orig p => atomMap p
  | .const_at_ref p => Atom.mk_fresh "const_ref" (Fintype.equivFin sig.preds p).val
  | .lt_ref => Atom.mk_fresh "lt_ref" 0
  | .gt_ref => Atom.mk_fresh "gt_ref" 0

/-! ### Semantic Correctness of reduceElimLast

The `reduceElimLast_correct` family proves that reducing the last variable from a
formula preserves its semantics: evaluating the original formula with the last env
slot set to `t` equals evaluating the reduced formula in the extended model
`extIntStruct M t`. This is the key lemma for the quantifier elimination step. -/

/-- Append a value at the last position of an environment.
    `appendLast env t : Fin (n+1) → Int` maps `i ↦ env i` if `i < n`, and `n ↦ t`. -/
private def appendLast {n : Nat} (env : Fin n → Int) (t : Int) : Fin (n + 1) → Int :=
  fun i => if h : i.val < n then env ⟨i.val, h⟩ else t

/-- Fin.cons commutes with appendLast: putting x first and t last is
    the same as appendLast with the extended env. -/
private theorem cons_appendLast {n : Nat} (x t : Int) (env : Fin n → Int) :
    Fin.cons x (appendLast env t) = appendLast (Fin.cons x env) t := by
  funext ⟨i, hi⟩
  cases i with
  | zero => simp [Fin.cons, appendLast]
  | succ j =>
    simp only [Fin.cons, appendLast]
    split
    · simp [appendLast, show j < n from by omega]
    · rename_i h1; simp [appendLast, show ¬(j < n) from by omega]

/-- appendLast for a singleton env equals Fin.cons. -/
private theorem appendLast_singleton (z t : Int) :
    appendLast (fun _ : Fin 1 => z) t = Fin.cons z (fun _ => t) := by
  funext ⟨i, hi⟩
  simp only [appendLast, Fin.cons]
  cases i with
  | zero => simp
  | succ j => simp [show ¬(j + 1 < 1) from by omega]

/-- Semantic correctness of `reduceElimLast` for n = m+1 ≥ 1.
    Evaluating `alpha : MonadicFormula sig (m+1+1)` with the last env slot
    holding `t` equals evaluating `reduceElimLast (m+1) alpha` in the extended
    model `extIntStruct M t`. -/
private noncomputable def reduceElimLast_correct_succ {sig : MonadicSignature} :
    (m : Nat) → (alpha : MonadicFormula sig (m + 1 + 1)) →
    ∀ (M : IntStructureFromSig sig) (env : Fin (m+1) → Int) (t : Int),
    eval (int_to_ordered sig M) (appendLast env t) alpha ↔
    eval (int_to_ordered (extSignature sig) (extIntStruct M t)) env (reduceElimLast (m+1) alpha)
  | m, .not beta => fun M env t => by
    simp only [eval, reduceElimLast]
    exact not_congr (reduceElimLast_correct_succ m beta M env t)
  | m, .and a b => fun M env t => by
    simp only [eval, reduceElimLast]
    exact and_congr (reduceElimLast_correct_succ m a M env t)
                    (reduceElimLast_correct_succ m b M env t)
  | m, .all beta => fun M env t => by
    simp only [eval, reduceElimLast]
    constructor
    · intro h x
      have ih := reduceElimLast_correct_succ (m+1) beta M (Fin.cons x env) t
      rw [← cons_appendLast] at ih
      exact ih.mp (h x)
    · intro h x
      have ih := reduceElimLast_correct_succ (m+1) beta M (Fin.cons x env) t
      rw [← cons_appendLast] at ih
      exact ih.mpr (h x)
  | m, .ex beta => fun M env t => by
    simp only [eval, reduceElimLast]
    constructor
    · rintro ⟨x, hx⟩
      have ih := reduceElimLast_correct_succ (m+1) beta M (Fin.cons x env) t
      rw [← cons_appendLast] at ih
      exact ⟨x, ih.mp hx⟩
    · rintro ⟨x, hx⟩
      have ih := reduceElimLast_correct_succ (m+1) beta M (Fin.cons x env) t
      rw [← cons_appendLast] at ih
      exact ⟨x, ih.mpr hx⟩
  | m, .atom p i => fun M env t => by
    simp only [eval, reduceElimLast]
    split
    · rename_i h
      simp only [eval, int_to_ordered, extIntStruct]
      show M.interp p (appendLast env t i) ↔ M.interp p (env ⟨i.val, h⟩)
      simp [appendLast, h]
    · rename_i h
      simp only [eval, int_to_ordered, extIntStruct]
      show M.interp p (appendLast env t i) ↔ M.interp p t
      simp [appendLast, h]
  | m, .lt i j => fun M env t => by
    simp only [eval, reduceElimLast]
    split
    · rename_i hi
      split
      · rename_i hj
        simp only [eval, int_to_ordered]
        show appendLast env t i < appendLast env t j ↔ env ⟨i.val, hi⟩ < env ⟨j.val, hj⟩
        simp [appendLast, hi, hj]
      · rename_i hj
        simp only [eval, int_to_ordered, extIntStruct]
        show appendLast env t i < appendLast env t j ↔ env ⟨i.val, by omega⟩ < t
        simp [appendLast, hi, hj]
    · rename_i hi
      split
      · rename_i hj
        simp only [eval, int_to_ordered, extIntStruct]
        show appendLast env t i < appendLast env t j ↔ t < env ⟨j.val, by omega⟩
        simp [appendLast, hi, hj]
      · rename_i hj
        simp only [int_to_ordered]
        constructor
        · intro hlt; simp [appendLast, hi, hj] at hlt
        · intro hlt; exact absurd hlt (lt_irrefl _)

/-- Specialized correctness for the main use case: `alpha : MonadicFormula sig 2`,
    env = `Fin.cons z (fun _ => t)`, result in `MonadicFormula (extSignature sig) 1`. -/
theorem reduceElimLast_correct_at_one {sig : MonadicSignature}
    (alpha : MonadicFormula sig 2) (M : IntStructureFromSig sig) (z t : Int) :
    eval (int_to_ordered sig M) (Fin.cons z (fun _ => t)) alpha ↔
    eval (int_to_ordered (extSignature sig) (extIntStruct M t))
      (fun _ => z) (reduceElimLast 1 alpha) := by
  have h := reduceElimLast_correct_succ 0 alpha M (fun _ => z) t
  rwa [appendLast_singleton] at h

/-! ### Atom Elimination Infrastructure

When translating from the extended signature back to the original, we need to
eliminate the extended atoms (const_at_ref, lt_ref, gt_ref). For a properly
separated formula, this is done by level-aware substitution:
- Present level: lt_ref → ⊥, gt_ref → ⊥
- Past-only subformulas: lt_ref → ¬⊥ (True), gt_ref → ⊥
- Future-only subformulas: lt_ref → ⊥, gt_ref → ¬⊥ (True)
- const_at_ref atoms: case-split over all truth assignments -/

/-- Apply a list of (atom, formula) substitutions sequentially. -/
private noncomputable def applySubsts (φ : Formula) : List (Atom × Formula) → Formula
  | [] => φ
  | (a, r) :: rest => applySubsts (Separation.subst_formula φ a r) rest

/-- Level-aware elimination of extended atoms from a properly separated formula.
    Walks the separated structure, applying different substitutions at each level:
    - Present level (boolean combinations): lt→⊥, gt→⊥, const→per σ
    - Past temporal subformulas: lt→⊤, gt→⊥, const→per σ
    - Future temporal subformulas: lt→⊥, gt→⊤, const→per σ -/
private noncomputable def elimExtFromSep
    (constSubs : List (Atom × Formula))
    (lt_atom gt_atom : Atom) : Formula → Formula
  | .atom a =>
    -- Present level substitution
    applySubsts (.atom a) (constSubs ++ [(lt_atom, .bot), (gt_atom, .bot)])
  | .bot => .bot
  | .imp φ ψ => .imp (elimExtFromSep constSubs lt_atom gt_atom φ)
                      (elimExtFromSep constSubs lt_atom gt_atom ψ)
  | .box φ => .box (elimExtFromSep constSubs lt_atom gt_atom φ)
  | .snce φ ψ =>
    -- Past-only args
    .snce (applySubsts φ (constSubs ++ [(lt_atom, Formula.neg .bot), (gt_atom, .bot)]))
          (applySubsts ψ (constSubs ++ [(lt_atom, Formula.neg .bot), (gt_atom, .bot)]))
  | .untl φ ψ =>
    -- Future-only args
    .untl (applySubsts φ (constSubs ++ [(lt_atom, .bot), (gt_atom, Formula.neg .bot)]))
          (applySubsts ψ (constSubs ++ [(lt_atom, .bot), (gt_atom, Formula.neg .bot)]))

/-- Guard formula for assignment σ: conjunction of (if σ p then atom(p) else ¬atom(p)). -/
private noncomputable def guardFormula {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (σ : sig.preds → Bool) : Formula :=
  ((Finset.univ : Finset sig.preds).toList.map fun p =>
    if σ p then Formula.atom (atomMap p) else Formula.neg (Formula.atom (atomMap p))
  ).foldl Formula.and (Formula.neg Formula.bot)

/-- Build the orig atom substitution list: maps each freshAM(.orig p) → Formula.atom(atomMap p). -/
private noncomputable def origSubsList {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (extAM : (extSignature sig).preds → Atom) :
    List (Atom × Formula) :=
  (Finset.univ : Finset sig.preds).toList.map fun p =>
    (extAM (.orig p), Formula.atom (atomMap p))

/-- Build the const_at_ref substitution list for a given assignment σ. -/
private noncomputable def constSubsList {sig : MonadicSignature}
    (extAM : (extSignature sig).preds → Atom) (σ : sig.preds → Bool) :
    List (Atom × Formula) :=
  (Finset.univ : Finset sig.preds).toList.map fun p =>
    (extAM (.const_at_ref p), if σ p then Formula.neg .bot else .bot)

/-- Build the full quantifier elimination formula:
    ∨_σ (guard_σ ∧ elimExtFromSep_σ(B_sep))
    where elimExtFromSep handles orig + const + lt/gt substitutions. -/
noncomputable def quantElimFormula {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (extAM : (extSignature sig).preds → Atom)
    (B_sep : Formula) : Formula :=
  let lt_atom := extAM .lt_ref
  let gt_atom := extAM .gt_ref
  let origSubs := origSubsList atomMap extAM
  let assignments := (Finset.univ : Finset (sig.preds → Bool)).toList
  let branches := assignments.map fun σ =>
    Formula.and (guardFormula atomMap σ)
                (elimExtFromSep (origSubs ++ constSubsList extAM σ) lt_atom gt_atom B_sep)
  match branches with
  | [] => .bot
  | [b] => b
  | b :: bs => bs.foldl Formula.or b

/-! ### Quantifier Elimination Correctness

The key correctness theorem: for a properly separated formula B evaluated in the
extended model, the quantElimFormula produces an equivalent formula in the original
model. The proof uses the purity lemmas (past_only_is_pure_past, future_only_is_pure_future)
to justify the level-aware substitution. -/

/-- subst_formula preserves is_past_only when the replacement is past-only. -/
private theorem subst_preserves_past_only (φ : Formula) (target : Atom) (r : Formula)
    (hφ : Separation.is_past_only φ = true) (hr : Separation.is_past_only r = true) :
    Separation.is_past_only (Separation.subst_formula φ target r) = true := by
  induction φ with
  | atom a => simp only [Separation.subst_formula]; split <;> [exact hr; rfl]
  | bot => rfl
  | imp α β ihα ihβ =>
    simp only [Separation.is_past_only, Bool.and_eq_true] at hφ
    simp only [Separation.subst_formula, Separation.is_past_only, Bool.and_eq_true]
    exact ⟨ihα hφ.1, ihβ hφ.2⟩
  | box α ih =>
    simp only [Separation.is_past_only] at hφ
    simp only [Separation.subst_formula, Separation.is_past_only]; exact ih hφ
  | untl _ _ => simp [Separation.is_past_only] at hφ
  | snce α β ihα ihβ =>
    simp only [Separation.is_past_only, Bool.and_eq_true] at hφ
    simp only [Separation.subst_formula, Separation.is_past_only, Bool.and_eq_true]
    exact ⟨ihα hφ.1, ihβ hφ.2⟩

/-- subst_formula preserves is_future_only when the replacement is future-only. -/
private theorem subst_preserves_future_only (φ : Formula) (target : Atom) (r : Formula)
    (hφ : Separation.is_future_only φ = true) (hr : Separation.is_future_only r = true) :
    Separation.is_future_only (Separation.subst_formula φ target r) = true := by
  induction φ with
  | atom a => simp only [Separation.subst_formula]; split <;> [exact hr; rfl]
  | bot => rfl
  | imp α β ihα ihβ =>
    simp only [Separation.is_future_only, Bool.and_eq_true] at hφ
    simp only [Separation.subst_formula, Separation.is_future_only, Bool.and_eq_true]
    exact ⟨ihα hφ.1, ihβ hφ.2⟩
  | box α ih =>
    simp only [Separation.is_future_only] at hφ
    simp only [Separation.subst_formula, Separation.is_future_only]; exact ih hφ
  | untl α β ihα ihβ =>
    simp only [Separation.is_future_only, Bool.and_eq_true] at hφ
    simp only [Separation.subst_formula, Separation.is_future_only, Bool.and_eq_true]
    exact ⟨ihα hφ.1, ihβ hφ.2⟩
  | snce _ _ => simp [Separation.is_future_only] at hφ

private theorem applySubsts_past_correct {φ : Formula}
    (hpo : Separation.is_past_only φ = true)
    (subs : List (Atom × Formula)) (M : Separation.IntStructure) (t : Int)
    (h_reps_po : ∀ (a : Atom) (r : Formula), (a, r) ∈ subs → Separation.is_past_only r = true)
    (h_match : ∀ (a : Atom) (r : Formula), (a, r) ∈ subs →
      ∀ s : Int, s ≤ t → (Separation.int_truth M s r ↔ s ∈ M.val a)) :
    Separation.int_truth M t (applySubsts φ subs) ↔ Separation.int_truth M t φ := by
  induction subs generalizing φ with
  | nil => exact Iff.rfl
  | cons ar rest ih =>
    simp only [applySubsts]
    have hmem_ar : (ar.1, ar.2) ∈ (ar :: rest) := by
      rw [show (ar.1, ar.2) = ar from Prod.ext rfl rfl]; exact List.mem_cons.mpr (Or.inl rfl)
    have h_sub_po := subst_preserves_past_only φ ar.1 ar.2 hpo (h_reps_po ar.1 ar.2 hmem_ar)
    have h_step : Separation.int_truth M t (Separation.subst_formula φ ar.1 ar.2) ↔
        Separation.int_truth M t φ :=
      past_only_subst_correct hpo ar.1 ar.2 M t (h_match ar.1 ar.2 hmem_ar)
    exact (ih h_sub_po
      (fun a r hmem => h_reps_po a r (List.mem_cons.mpr (Or.inr hmem)))
      (fun a r hmem => h_match a r (List.mem_cons.mpr (Or.inr hmem)))).trans h_step

/-- Correctness of applySubsts for a future-only formula. -/
private theorem applySubsts_future_correct {φ : Formula}
    (hfo : Separation.is_future_only φ = true)
    (subs : List (Atom × Formula)) (M : Separation.IntStructure) (t : Int)
    (h_reps_fo : ∀ (a : Atom) (r : Formula), (a, r) ∈ subs → Separation.is_future_only r = true)
    (h_match : ∀ (a : Atom) (r : Formula), (a, r) ∈ subs →
      ∀ s : Int, t ≤ s → (Separation.int_truth M s r ↔ s ∈ M.val a)) :
    Separation.int_truth M t (applySubsts φ subs) ↔ Separation.int_truth M t φ := by
  induction subs generalizing φ with
  | nil => exact Iff.rfl
  | cons ar rest ih =>
    simp only [applySubsts]
    have hmem_ar : (ar.1, ar.2) ∈ (ar :: rest) := by
      rw [show (ar.1, ar.2) = ar from Prod.ext rfl rfl]; exact List.mem_cons.mpr (Or.inl rfl)
    have h_sub_fo := subst_preserves_future_only φ ar.1 ar.2 hfo (h_reps_fo ar.1 ar.2 hmem_ar)
    have h_step : Separation.int_truth M t (Separation.subst_formula φ ar.1 ar.2) ↔
        Separation.int_truth M t φ :=
      future_only_subst_correct hfo ar.1 ar.2 M t (h_match ar.1 ar.2 hmem_ar)
    exact (ih h_sub_fo
      (fun a r hmem => h_reps_fo a r (List.mem_cons.mpr (Or.inr hmem)))
      (fun a r hmem => h_match a r (List.mem_cons.mpr (Or.inr hmem)))).trans h_step

/-! ### Atom Membership in Extended Model

Key lemma: membership in `(to_int_struct (extIntStruct M t) freshAM).val (freshAM ep)` at
time `z` equals exactly `(extIntStruct M t).interp ep z`, because `freshAM` is injective. -/

/-- Membership in the extended model at a fresh atom: because freshAM is injective,
    `z ∈ (to_int_struct (extIntStruct M t) freshAM).val (freshAM ep)` iff
    `(extIntStruct M t).interp ep z`. -/
private theorem to_int_struct_mem_freshAM {sig : MonadicSignature}
    (M : IntStructureFromSig sig) (t : Int)
    (freshAM : (extSignature sig).preds → Atom)
    (freshAM_inj : Function.Injective freshAM)
    (ep : ExtPred sig) (z : Int) :
    z ∈ (to_int_struct (extIntStruct M t) freshAM).val (freshAM ep) ↔
    (extIntStruct M t).interp ep z := by
  simp only [to_int_struct, Set.mem_setOf_eq]
  constructor
  · rintro ⟨ep', heq, hinterp⟩
    exact freshAM_inj heq ▸ hinterp
  · intro h
    exact ⟨ep, rfl, h⟩

/-- Membership in `to_int_struct M atomMap` at `atomMap p` when `atomMap` is injective. -/
private theorem to_int_struct_mem_atomMap {sig : MonadicSignature}
    (M : IntStructureFromSig sig)
    (atomMap : sig.preds → Atom)
    (hinj : Function.Injective atomMap)
    (p : sig.preds) (z : Int) :
    z ∈ (to_int_struct M atomMap).val (atomMap p) ↔ M.interp p z := by
  simp only [to_int_struct, Set.mem_setOf_eq]
  constructor
  · rintro ⟨q, hq, hi⟩; exact hinj hq ▸ hi
  · intro h; exact ⟨p, rfl, h⟩

/-! ### Guard Formula Correctness -/

/-- Helper: int_truth of a foldl-and list. -/
private theorem int_truth_foldl_and (M : Separation.IntStructure) (t : Int)
    (init : Formula) (fs : List Formula) :
    Separation.int_truth M t (fs.foldl Formula.and init) ↔
    Separation.int_truth M t init ∧ ∀ f ∈ fs, Separation.int_truth M t f := by
  induction fs generalizing init with
  | nil => simp [List.foldl]
  | cons f rest ih =>
    simp only [List.foldl]
    rw [ih, Separation.int_truth_and_iff]
    constructor
    · rintro ⟨⟨hi, hf⟩, hrest⟩
      exact ⟨hi, fun g hg => by
        rcases List.mem_cons.mp hg with rfl | hmem
        · exact hf
        · exact hrest g hmem⟩
    · rintro ⟨hi, hall⟩
      exact ⟨⟨hi, hall f (List.mem_cons.mpr (Or.inl rfl))⟩,
             fun g hg => hall g (List.mem_cons.mpr (Or.inr hg))⟩

/-- The guard formula correctly captures assignment matching (requires atomMap injective). -/
private theorem guardFormula_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom)
    (hinj : Function.Injective atomMap)
    (σ : sig.preds → Bool)
    (M : IntStructureFromSig sig)
    (t : Int) :
    Separation.int_truth (to_int_struct M atomMap) t (guardFormula atomMap σ) ↔
    (∀ p : sig.preds, σ p = true ↔ M.interp p t) := by
  unfold guardFormula
  rw [int_truth_foldl_and]
  constructor
  · rintro ⟨_, hall⟩ p
    have hmem : (if σ p then Formula.atom (atomMap p)
                 else Formula.neg (Formula.atom (atomMap p))) ∈
        ((Finset.univ : Finset sig.preds).toList.map fun p =>
          if σ p then Formula.atom (atomMap p)
          else Formula.neg (Formula.atom (atomMap p))) :=
      List.mem_map.mpr ⟨p, Finset.mem_toList.mpr (Finset.mem_univ p), rfl⟩
    have hf := hall _ hmem
    by_cases hσ : σ p = true
    · simp only [hσ, ite_true, Separation.int_truth] at hf
      exact ⟨fun _ => (to_int_struct_mem_atomMap M atomMap hinj p t).mp hf,
             fun _ => hσ⟩
    · simp only [show (σ p = true) = False from propext ⟨hσ, False.elim⟩, ite_false,
                 Separation.int_truth, Formula.neg] at hf
      exact ⟨fun habs => absurd habs hσ,
             fun hinterp => absurd ((to_int_struct_mem_atomMap M atomMap hinj p t).mpr hinterp) hf⟩
  · intro hall
    constructor
    · exact fun h => h
    · intro f hf
      simp only [List.mem_map] at hf
      obtain ⟨p, _, rfl⟩ := hf
      by_cases hσ : σ p = true
      · simp only [hσ, ite_true, Separation.int_truth]
        exact (to_int_struct_mem_atomMap M atomMap hinj p t).mpr ((hall p).mp hσ)
      · simp only [show (σ p = true) = False from propext ⟨hσ, False.elim⟩, ite_false,
                   Separation.int_truth, Formula.neg]
        intro hmem
        exact absurd ((hall p).mpr ((to_int_struct_mem_atomMap M atomMap hinj p t).mp hmem)) hσ

/-! ### atom_elim_correct: Model Transfer via Quantifier Elimination

The core challenge: show that truth of B_sep in M_ext (extended model with freshAM atoms)
equals truth of quantElimFormula in M_orig (original model with atomMap atoms).

The proof is monolithic: by structural induction on B_sep and classical reasoning
over the quantElimFormula disjunction. The key insight is that the quantElimFormula
disjunction over σ has exactly one true branch (the one matching the model at t),
and for that branch, the elimExtFromSep substitutions correctly transfer truth. -/

/-- Truth of a formula depends only on atoms that appear in it. -/
private theorem int_truth_depends_on_atoms (φ : Formula)
    (M₁ M₂ : Separation.IntStructure) (t : ℤ)
    (h : ∀ a ∈ Separation.formula_atoms φ, ∀ z : ℤ, (z ∈ M₁.val a ↔ z ∈ M₂.val a)) :
    Separation.int_truth M₁ t φ ↔ Separation.int_truth M₂ t φ := by
  induction φ generalizing t with
  | atom a =>
    simp only [Separation.int_truth]
    exact h a (Set.mem_singleton a) t
  | bot => exact Iff.rfl
  | imp α β ihα ihβ =>
    simp only [Separation.int_truth]
    exact imp_congr
      (ihα t (fun a ha' z => h a (Set.mem_union_left _ ha') z))
      (ihβ t (fun a ha' z => h a (Set.mem_union_right _ ha') z))
  | box _ _ =>
    simp only [Separation.int_truth]
  | untl α β ihα ihβ =>
    simp only [Separation.int_truth]
    constructor
    · rintro ⟨s, hs, hα, hβ⟩
      exact ⟨s, hs,
        (ihα s (fun a ha' z => h a (Set.mem_union_left _ ha') z)).mp hα,
        fun r hr1 hr2 => (ihβ r (fun a ha' z => h a (Set.mem_union_right _ ha') z)).mp (hβ r hr1 hr2)⟩
    · rintro ⟨s, hs, hα, hβ⟩
      exact ⟨s, hs,
        (ihα s (fun a ha' z => h a (Set.mem_union_left _ ha') z)).mpr hα,
        fun r hr1 hr2 => (ihβ r (fun a ha' z => h a (Set.mem_union_right _ ha') z)).mpr (hβ r hr1 hr2)⟩
  | snce α β ihα ihβ =>
    simp only [Separation.int_truth]
    constructor
    · rintro ⟨s, hs, hα, hβ⟩
      exact ⟨s, hs,
        (ihα s (fun a ha' z => h a (Set.mem_union_left _ ha') z)).mp hα,
        fun r hr1 hr2 => (ihβ r (fun a ha' z => h a (Set.mem_union_right _ ha') z)).mp (hβ r hr1 hr2)⟩
    · rintro ⟨s, hs, hα, hβ⟩
      exact ⟨s, hs,
        (ihα s (fun a ha' z => h a (Set.mem_union_left _ ha') z)).mpr hα,
        fun r hr1 hr2 => (ihβ r (fun a ha' z => h a (Set.mem_union_right _ ha') z)).mpr (hβ r hr1 hr2)⟩

/-! ### Atom Containment Lemmas -/

/-- Substituting `r` for `target` in `φ` can only introduce atoms from `r` or
    atoms from `φ` other than `target`. -/
private theorem formula_atoms_subst_formula (φ : Formula) (target : Atom) (r : Formula) :
    Separation.formula_atoms (Separation.subst_formula φ target r) ⊆
    (Separation.formula_atoms φ \ {target}) ∪ Separation.formula_atoms r := by
  induction φ with
  | atom a =>
    simp only [Separation.subst_formula]
    split
    · next h =>
      subst h
      intro x hx
      exact Set.mem_union_right _ hx
    · next h =>
      intro x hx
      simp only [Separation.formula_atoms, Set.mem_singleton_iff] at hx
      subst hx
      exact Set.mem_union_left _ ⟨Set.mem_singleton _, h⟩
  | bot => simp [Separation.formula_atoms, Separation.subst_formula]
  | imp α β ihα ihβ =>
    simp only [Separation.subst_formula, Separation.formula_atoms]
    intro x hx
    simp only [Set.mem_union] at hx
    rcases hx with hx | hx
    · rcases ihα hx with h | h
      · exact Set.mem_union_left _ ⟨Set.mem_union_left _ h.1, h.2⟩
      · exact Set.mem_union_right _ h
    · rcases ihβ hx with h | h
      · exact Set.mem_union_left _ ⟨Set.mem_union_right _ h.1, h.2⟩
      · exact Set.mem_union_right _ h
  | box α ihα =>
    simp only [Separation.subst_formula, Separation.formula_atoms]
    exact fun x hx => ihα hx
  | snce α β ihα ihβ =>
    simp only [Separation.subst_formula, Separation.formula_atoms]
    intro x hx
    simp only [Set.mem_union] at hx
    rcases hx with hx | hx
    · rcases ihα hx with h | h
      · exact Set.mem_union_left _ ⟨Set.mem_union_left _ h.1, h.2⟩
      · exact Set.mem_union_right _ h
    · rcases ihβ hx with h | h
      · exact Set.mem_union_left _ ⟨Set.mem_union_right _ h.1, h.2⟩
      · exact Set.mem_union_right _ h
  | untl α β ihα ihβ =>
    simp only [Separation.subst_formula, Separation.formula_atoms]
    intro x hx
    simp only [Set.mem_union] at hx
    rcases hx with hx | hx
    · rcases ihα hx with h | h
      · exact Set.mem_union_left _ ⟨Set.mem_union_left _ h.1, h.2⟩
      · exact Set.mem_union_right _ h
    · rcases ihβ hx with h | h
      · exact Set.mem_union_left _ ⟨Set.mem_union_right _ h.1, h.2⟩
      · exact Set.mem_union_right _ h

/-- Applying a substitution list keeps atoms within `S` when the initial atoms are
    covered by substituted targets or `S`, and all replacements have atoms in `S`. -/
private theorem formula_atoms_applySubsts_subset (φ : Formula) (subs : List (Atom × Formula))
    (S : Set Atom)
    (h_covered : Separation.formula_atoms φ ⊆ {a | ∃ r, (a, r) ∈ subs} ∪ S)
    (h_replacements : ∀ a r, (a, r) ∈ subs → Separation.formula_atoms r ⊆ S) :
    Separation.formula_atoms (applySubsts φ subs) ⊆ S := by
  induction subs generalizing φ with
  | nil =>
    simp only [applySubsts]
    intro x hx
    rcases h_covered hx with ⟨_, habs⟩ | h
    · simp at habs
    · exact h
  | cons ar rest ih =>
    obtain ⟨a, r⟩ := ar
    simp only [applySubsts]
    apply ih
    · intro x hx
      rcases formula_atoms_subst_formula φ a r hx with ⟨hφ, hne⟩ | hr
      · rcases h_covered hφ with ⟨r', hmem⟩ | hS
        · rw [List.mem_cons] at hmem
          rcases hmem with heq | hmem
          · -- (x, r') = (a, r): means x = a, contradicting hne
            have : x = a := (Prod.mk.inj heq).1
            exact absurd (Set.mem_singleton_iff.mpr this) hne
          · exact Set.mem_union_left _ ⟨r', hmem⟩
        · exact Set.mem_union_right _ hS
      · exact Set.mem_union_right _ (h_replacements a r (List.mem_cons.mpr (Or.inl rfl)) hr)
    · intro b s hmem
      exact h_replacements b s (List.mem_cons.mpr (Or.inr hmem))

/-- All atoms of `elimExtFromSep` are in `Set.range atomMap` when the source atoms
    are in `Set.range freshAM` and atomMap/freshAM have disjoint ranges. -/
private theorem formula_atoms_elimExtFromSep_subset {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (freshAM : (extSignature sig).preds → Atom)
    (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ p ep, atomMap p ≠ freshAM ep)
    (σ : sig.preds → Bool)
    (B_sep : Formula)
    (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
    Separation.formula_atoms
      (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                      (freshAM .lt_ref) (freshAM .gt_ref) B_sep) ⊆
    Set.range atomMap := by
  have h_subs_in_range : ∀ a r, (a, r) ∈ origSubsList atomMap freshAM ++ constSubsList freshAM σ →
      Separation.formula_atoms r ⊆ Set.range atomMap := by
    intro a r hmem
    simp only [origSubsList, constSubsList, List.mem_append, List.mem_map, Finset.mem_toList,
               Finset.mem_univ, true_and] at hmem
    rcases hmem with ⟨p, heq⟩ | ⟨p, heq⟩
    · obtain ⟨_, hrfl⟩ := Prod.mk.inj heq
      rw [← hrfl]
      simp [Separation.formula_atoms]
    · obtain ⟨_, hrfl⟩ := Prod.mk.inj heq
      rw [← hrfl]
      by_cases h : σ p = true
      · simp [h, Separation.formula_atoms, Formula.neg]
      · simp [h, Separation.formula_atoms]
  have h_lt_in_range : Separation.formula_atoms (.bot : Formula) ⊆ Set.range atomMap := by
    simp [Separation.formula_atoms]
  have h_neg_bot_in_range : Separation.formula_atoms (Formula.neg .bot : Formula) ⊆ Set.range atomMap := by
    simp [Separation.formula_atoms, Formula.neg]
  induction B_sep with
  | atom a =>
    simp only [elimExtFromSep]
    apply formula_atoms_applySubsts_subset
    · intro x hx
      simp only [Separation.formula_atoms, Set.mem_singleton_iff] at hx
      have ha : x ∈ Set.range freshAM := by
        apply hB_atoms; simp [Separation.formula_atoms, hx]
      obtain ⟨ep, rfl⟩ := ha
      cases ep with
      | orig p =>
        apply Set.mem_union_left
        refine ⟨Formula.atom (atomMap p), ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inl (Or.inl ⟨p, rfl⟩)
      | const_at_ref p =>
        apply Set.mem_union_left
        refine ⟨if σ p = true then Formula.bot.neg else Formula.bot, ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inl (Or.inr ⟨p, rfl⟩)
      | lt_ref =>
        apply Set.mem_union_left
        refine ⟨Formula.bot, ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inr (Or.inl trivial)
      | gt_ref =>
        apply Set.mem_union_left
        refine ⟨Formula.bot, ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inr (Or.inr (Or.inl trivial))
    · intro b s hmem
      simp only [List.mem_append, List.mem_cons, List.mem_nil_iff] at hmem
      rcases hmem with (hmem | hmem) | (heq | heq | hmem)
      · exact h_subs_in_range b s (List.mem_append_left _ hmem)
      · exact h_subs_in_range b s (List.mem_append_right _ hmem)
      · obtain ⟨-, rfl⟩ := Prod.mk.inj heq; exact h_lt_in_range
      · obtain ⟨-, rfl⟩ := Prod.mk.inj heq; exact h_lt_in_range
      · exact absurd hmem (by simp)
  | bot => simp [elimExtFromSep, Separation.formula_atoms]
  | imp α β ihα ihβ =>
    simp only [elimExtFromSep, Separation.formula_atoms]
    intro x hx
    simp only [Set.mem_union] at hx
    rcases hx with hx | hx
    · exact ihα (fun a ha => hB_atoms (Set.mem_union_left _ ha)) hx
    · exact ihβ (fun a ha => hB_atoms (Set.mem_union_right _ ha)) hx
  | box α ihα =>
    simp only [elimExtFromSep, Separation.formula_atoms]
    exact ihα (by simp only [Separation.formula_atoms] at hB_atoms; exact hB_atoms)
  | snce α β ihα ihβ =>
    simp only [elimExtFromSep, Separation.formula_atoms]
    have mk_covered_past : ∀ (φ : Formula), Separation.formula_atoms φ ⊆ Set.range freshAM →
        Separation.formula_atoms φ ⊆
          {a | ∃ r, (a, r) ∈ origSubsList atomMap freshAM ++ constSubsList freshAM σ ++
              [(freshAM .lt_ref, Formula.neg .bot), (freshAM .gt_ref, .bot)]} ∪ Set.range atomMap := by
      intro φ hφ x hx
      obtain ⟨ep, rfl⟩ := hφ hx
      cases ep with
      | orig p =>
        apply Set.mem_union_left
        refine ⟨Formula.atom (atomMap p), ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inl (Or.inl ⟨p, rfl⟩)
      | const_at_ref p =>
        apply Set.mem_union_left
        refine ⟨if σ p = true then Formula.bot.neg else Formula.bot, ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inl (Or.inr ⟨p, rfl⟩)
      | lt_ref =>
        apply Set.mem_union_left
        refine ⟨Formula.bot.neg, ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inr (Or.inl trivial)
      | gt_ref =>
        apply Set.mem_union_left
        refine ⟨Formula.bot, ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inr (Or.inr (Or.inl trivial))
    have h_neg_bot_rpl : ∀ a r, (a, r) ∈ origSubsList atomMap freshAM ++ constSubsList freshAM σ ++
        [(freshAM .lt_ref, Formula.neg .bot), (freshAM .gt_ref, .bot)] →
        Separation.formula_atoms r ⊆ Set.range atomMap := by
      intro a r hmem
      simp only [List.mem_append, List.mem_cons, List.mem_singleton] at hmem
      rcases hmem with (hmem | hmem) | (heq | heq | hmem)
      · exact h_subs_in_range a r (List.mem_append_left _ hmem)
      · exact h_subs_in_range a r (List.mem_append_right _ hmem)
      · obtain ⟨-, rfl⟩ := Prod.mk.inj heq; exact h_neg_bot_in_range
      · obtain ⟨-, rfl⟩ := Prod.mk.inj heq; exact h_lt_in_range
      · simp at hmem
    intro x hx
    simp only [Set.mem_union] at hx
    rcases hx with hx | hx
    · exact formula_atoms_applySubsts_subset α _ _ (mk_covered_past α (fun a ha => hB_atoms (Set.mem_union_left _ ha))) h_neg_bot_rpl hx
    · exact formula_atoms_applySubsts_subset β _ _ (mk_covered_past β (fun a ha => hB_atoms (Set.mem_union_right _ ha))) h_neg_bot_rpl hx
  | untl α β ihα ihβ =>
    simp only [elimExtFromSep, Separation.formula_atoms]
    have mk_covered_fut : ∀ (φ : Formula), Separation.formula_atoms φ ⊆ Set.range freshAM →
        Separation.formula_atoms φ ⊆
          {a | ∃ r, (a, r) ∈ origSubsList atomMap freshAM ++ constSubsList freshAM σ ++
              [(freshAM .lt_ref, .bot), (freshAM .gt_ref, Formula.neg .bot)]} ∪ Set.range atomMap := by
      intro φ hφ x hx
      obtain ⟨ep, rfl⟩ := hφ hx
      cases ep with
      | orig p =>
        apply Set.mem_union_left
        refine ⟨Formula.atom (atomMap p), ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inl (Or.inl ⟨p, rfl⟩)
      | const_at_ref p =>
        apply Set.mem_union_left
        refine ⟨if σ p = true then Formula.bot.neg else Formula.bot, ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inl (Or.inr ⟨p, rfl⟩)
      | lt_ref =>
        apply Set.mem_union_left
        refine ⟨Formula.bot, ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inr (Or.inl trivial)
      | gt_ref =>
        apply Set.mem_union_left
        refine ⟨Formula.bot.neg, ?_⟩
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_nil_iff]
        exact Or.inr (Or.inr (Or.inl trivial))
    have h_bot_rpl : ∀ a r, (a, r) ∈ origSubsList atomMap freshAM ++ constSubsList freshAM σ ++
        [(freshAM .lt_ref, .bot), (freshAM .gt_ref, Formula.neg .bot)] →
        Separation.formula_atoms r ⊆ Set.range atomMap := by
      intro a r hmem
      simp only [List.mem_append, List.mem_cons, List.mem_singleton] at hmem
      rcases hmem with (hmem | hmem) | (heq | heq | hmem)
      · exact h_subs_in_range a r (List.mem_append_left _ hmem)
      · exact h_subs_in_range a r (List.mem_append_right _ hmem)
      · obtain ⟨-, rfl⟩ := Prod.mk.inj heq; exact h_lt_in_range
      · obtain ⟨-, rfl⟩ := Prod.mk.inj heq; exact h_neg_bot_in_range
      · simp at hmem
    intro x hx
    simp only [Set.mem_union] at hx
    rcases hx with hx | hx
    · exact formula_atoms_applySubsts_subset α _ _ (mk_covered_fut α (fun a ha => hB_atoms (Set.mem_union_left _ ha))) h_bot_rpl hx
    · exact formula_atoms_applySubsts_subset β _ _ (mk_covered_fut β (fun a ha => hB_atoms (Set.mem_union_right _ ha))) h_bot_rpl hx

/-- Atoms of a guardFormula are in Set.range atomMap. -/
private theorem formula_atoms_guardFormula_subset {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (σ : sig.preds → Bool) :
    Separation.formula_atoms (guardFormula atomMap σ) ⊆ Set.range atomMap := by
  simp only [guardFormula]
  suffices h : ∀ (fs : List Formula) (init : Formula),
      (∀ x, x ∈ Separation.formula_atoms init → x ∈ Set.range atomMap) →
      (∀ f ∈ fs, ∀ x, x ∈ Separation.formula_atoms f → x ∈ Set.range atomMap) →
      ∀ x, x ∈ Separation.formula_atoms (fs.foldl Formula.and init) → x ∈ Set.range atomMap by
    apply h
    · simp [Separation.formula_atoms, Formula.neg]
    · intro f hf x hx
      simp only [List.mem_map] at hf
      obtain ⟨p, _, rfl⟩ := hf
      by_cases h : σ p
      · simp only [h, ite_true, Separation.formula_atoms, Set.mem_singleton_iff] at hx
        exact ⟨p, hx.symm⟩
      · simp only [h, Formula.neg, Separation.formula_atoms] at hx
        rcases hx with hx | hx
        · exact ⟨p, hx.symm⟩
        · exact absurd hx (Set.notMem_empty _)
  intro fs
  induction fs with
  | nil => simp [List.foldl]
  | cons f rest ih =>
    intro init h_init h_fs x hx
    simp only [List.foldl] at hx
    apply ih (init.and f)
    · intro y hy
      simp only [Formula.and, Formula.neg, Separation.formula_atoms, Set.mem_union,
                 Set.mem_empty_iff_false, or_false] at hy
      rcases hy with hy | hy
      · exact h_init y hy
      · exact h_fs f (List.mem_cons.mpr (Or.inl rfl)) y hy
    · exact fun g hg y hy => h_fs g (List.mem_cons.mpr (Or.inr hg)) y hy
    · exact hx

/-- Helper: atoms of a foldl-or are contained in union of branch atoms. -/
private theorem formula_atoms_foldl_or_subset (fs : List Formula) (init : Formula)
    (S : Set Atom)
    (h_init : Separation.formula_atoms init ⊆ S)
    (h_fs : ∀ f ∈ fs, Separation.formula_atoms f ⊆ S) :
    Separation.formula_atoms (fs.foldl Formula.or init) ⊆ S := by
  induction fs generalizing init with
  | nil => simpa [List.foldl]
  | cons f rest ih =>
    simp only [List.foldl]
    apply ih
    · simp only [Formula.or, Formula.neg, Separation.formula_atoms, Set.union_subset_iff,
                 Set.empty_subset, and_true]
      exact ⟨h_init, h_fs f (List.mem_cons.mpr (Or.inl rfl))⟩
    · intro g hg; exact h_fs g (List.mem_cons.mpr (Or.inr hg))

/-- Truth of a foldl-or formula: true iff init is true or some formula in the list is true. -/
private theorem int_truth_foldl_or (M : Separation.IntStructure) (t : Int)
    (init : Formula) (fs : List Formula) :
    Separation.int_truth M t (fs.foldl Formula.or init) ↔
    Separation.int_truth M t init ∨ ∃ f ∈ fs, Separation.int_truth M t f := by
  induction fs generalizing init with
  | nil => simp [List.foldl]
  | cons f rest ih =>
    simp only [List.foldl]
    rw [ih, Separation.int_truth_or_iff]
    constructor
    · rintro (h | ⟨g, hg, hgt⟩)
      · rcases h with h | h
        · exact Or.inl h
        · exact Or.inr ⟨f, List.mem_cons.mpr (Or.inl rfl), h⟩
      · exact Or.inr ⟨g, List.mem_cons.mpr (Or.inr hg), hgt⟩
    · rintro (h | ⟨g, hg, hgt⟩)
      · exact Or.inl (Or.inl h)
      · rcases List.mem_cons.mp hg with rfl | hg'
        · exact Or.inl (Or.inr hgt)
        · exact Or.inr ⟨g, hg', hgt⟩

/-- All atoms of `quantElimFormula` are in `Set.range atomMap`. -/
theorem formula_atoms_quantElimFormula_subset {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (freshAM : (extSignature sig).preds → Atom)
    (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ p ep, atomMap p ≠ freshAM ep)
    (B_sep : Formula)
    (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
    Separation.formula_atoms (quantElimFormula atomMap freshAM B_sep) ⊆ Set.range atomMap := by
  simp only [quantElimFormula]
  set lt_atom := freshAM .lt_ref
  set gt_atom := freshAM .gt_ref
  set origSubs := origSubsList atomMap freshAM
  set assignments := (Finset.univ : Finset (sig.preds → Bool)).toList
  set branches := assignments.map fun σ =>
    Formula.and (guardFormula atomMap σ)
                (elimExtFromSep (origSubs ++ constSubsList freshAM σ) lt_atom gt_atom B_sep)
  have h_branch_atoms : ∀ b ∈ branches, Separation.formula_atoms b ⊆ Set.range atomMap := by
    intro b hb
    simp only [branches, List.mem_map] at hb
    obtain ⟨σ, _, rfl⟩ := hb
    simp only [Formula.and, Formula.neg, Separation.formula_atoms, Set.union_subset_iff,
               Set.empty_subset, and_true]
    refine ⟨formula_atoms_guardFormula_subset atomMap σ, ?_⟩
    have : origSubs = origSubsList atomMap freshAM := rfl
    rw [this]
    exact formula_atoms_elimExtFromSep_subset atomMap freshAM freshAM_inj h_disj σ B_sep hB_atoms
  match h : branches with
  | [] => simp [Separation.formula_atoms]
  | [b] =>
    show Separation.formula_atoms b ⊆ Set.range atomMap
    exact h_branch_atoms b (by simp)
  | b :: b' :: bs =>
    show Separation.formula_atoms (List.foldl Formula.or b (b' :: bs)) ⊆ Set.range atomMap
    apply formula_atoms_foldl_or_subset
    · exact h_branch_atoms b (List.mem_cons.mpr (Or.inl rfl))
    · intro f hf
      exact h_branch_atoms f (List.mem_cons.mpr (Or.inr hf))

/-- Applying substitutions where no substitution's atom appears in φ leaves φ unchanged. -/
private theorem applySubsts_no_effect (φ : Formula) (subs : List (Atom × Formula))
    (h : ∀ a r, (a, r) ∈ subs → a ∉ Separation.formula_atoms φ) :
    applySubsts φ subs = φ := by
  induction subs generalizing φ with
  | nil => simp [applySubsts]
  | cons (a, r) rest ih =>
    simp only [applySubsts]
    have hna : a ∉ Separation.formula_atoms φ :=
      h a r (List.mem_cons.mpr (Or.inl rfl))
    have h_subst_unchanged : Separation.subst_formula φ a r = φ := by
      induction φ with
      | atom b =>
        simp only [Separation.subst_formula, Separation.formula_atoms, Set.mem_singleton_iff] at *
        simp [Ne.symm hna]
      | bot => rfl
      | imp α β ihα ihβ =>
        simp only [Separation.formula_atoms, Set.mem_union] at hna
        simp only [Separation.subst_formula]
        congr 1
        · exact ihα (fun h => hna (Or.inl h))
        · exact ihβ (fun h => hna (Or.inr h))
      | box α ihα =>
        simp only [Separation.formula_atoms] at hna
        simp [Separation.subst_formula, ihα hna]
      | untl α β ihα ihβ =>
        simp only [Separation.formula_atoms, Set.mem_union] at hna
        simp only [Separation.subst_formula]
        congr 1
        · exact ihα (fun h => hna (Or.inl h))
        · exact ihβ (fun h => hna (Or.inr h))
      | snce α β ihα ihβ =>
        simp only [Separation.formula_atoms, Set.mem_union] at hna
        simp only [Separation.subst_formula]
        congr 1
        · exact ihα (fun h => hna (Or.inl h))
        · exact ihβ (fun h => hna (Or.inr h))
    rw [h_subst_unchanged]
    exact ih φ (fun a' r' hmem => h a' r' (List.mem_cons.mpr (Or.inr hmem)))

/-- Applying substitutions to a single atom: finds replacement and applies rest to it. -/
private theorem applySubsts_atom_found (a : Atom) (r : Formula)
    (rest : List (Atom × Formula))
    (h_no_rest : ∀ a' r', (a', r') ∈ rest → a' ∉ Separation.formula_atoms r) :
    applySubsts (.atom a) ((a, r) :: rest) = r := by
  simp only [applySubsts, Separation.subst_formula, if_pos (rfl)]
  exact applySubsts_no_effect r rest h_no_rest

/-- Applying substitutions to a single atom, skipping a non-matching head. -/
private theorem applySubsts_atom_skip (a a' : Atom) (r' : Formula)
    (rest : List (Atom × Formula)) (hne : a ≠ a') :
    applySubsts (.atom a) ((a', r') :: rest) = applySubsts (.atom a) rest := by
  simp only [applySubsts, Separation.subst_formula, if_neg (Ne.symm hne)]

/-- When atom a has a matching entry in subs and no subsequent key appears in the replacement,
    applySubsts (.atom a) subs reduces to the replacement. -/
private theorem applySubsts_atom_with_match (a : Atom) (r : Formula)
    (subs : List (Atom × Formula))
    (h_mem : (a, r) ∈ subs)
    (h_no_further : ∀ a' r', (a', r') ∈ subs → a' ∉ Separation.formula_atoms r) :
    applySubsts (.atom a) subs = r := by
  induction subs with
  | nil => exact absurd h_mem (List.not_mem_nil _)
  | cons (a', r') rest ih =>
    simp only [applySubsts]
    by_cases ha : a' = a
    · simp only [ha, Separation.subst_formula, if_pos rfl]
      apply applySubsts_no_effect
      intro b rr hmem_rr
      exact h_no_further b rr (List.mem_cons.mpr (Or.inr hmem_rr))
    · simp only [Separation.subst_formula, if_neg (Ne.symm ha)]
      apply ih
      · rcases List.mem_cons.mp h_mem with ⟨h⟩ | hmem_rest
        · exact absurd (Prod.mk.inj h).1 (Ne.symm ha)
        · exact hmem_rest
      · intro b rr hmem_rr
        exact h_no_further b rr (List.mem_cons.mpr (Or.inr hmem_rr))

/-- The atom elimination correctness theorem: closes the gap between M_ext and M_orig.

    Given a properly separated B_sep whose atoms are all in freshAM's image, and
    with atomMap and freshAM having disjoint ranges, the quantElimFormula correctly
    transfers truth from the extended model to the original model.

    The proof uses the guardFormula/elimExtFromSep construction with the disjointness
    guarantee ensuring no double-substitution in applySubsts. -/
-- Helper: truth of branches list (used in atom_elim_correct for quantElimFormula)
private theorem int_truth_branches_iff (M : Separation.IntStructure) (t : Int)
    (branches : List Formula) :
    (match branches with
     | [] => Separation.int_truth M t .bot
     | [b] => Separation.int_truth M t b
     | b :: bs => Separation.int_truth M t (bs.foldl Formula.or b)) ↔
    ∃ branch ∈ branches, Separation.int_truth M t branch := by
  match branches with
  | [] => simp [Separation.int_truth]
  | [b] => simp
  | b :: b' :: bs =>
    show Separation.int_truth M t ((b' :: bs).foldl Formula.or b) ↔
      ∃ branch ∈ b :: b' :: bs, Separation.int_truth M t branch
    rw [int_truth_foldl_or]
    simp only [List.mem_cons]
    constructor
    · rintro (h | ⟨g, hg, hg_t⟩)
      · exact ⟨b, Or.inl rfl, h⟩
      · exact ⟨g, Or.inr hg, hg_t⟩
    · rintro ⟨g, hg | hg, hg_t⟩
      · exact Or.inl (hg ▸ hg_t)
      · exact Or.inr ⟨g, hg, hg_t⟩

theorem atom_elim_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep)
    (M : IntStructureFromSig sig) (t : Int)
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true)
    (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep) := by
  -- Setup models
  let M_ext := to_int_struct (extIntStruct M t) freshAM
  let M_orig := to_int_struct M atomMap
  -- Blended model: agrees with M_ext on freshAM atoms, M_orig on atomMap atoms
  let M_blend : Separation.IntStructure := ⟨fun a => M_ext.val a ∪ M_orig.val a⟩
  -- σ₀: the actual assignment of M at t (using classical decidability)
  let σ₀ : sig.preds → Bool := fun p => @decide (M.interp p t) (Classical.dec _)
  have hσ₀ : ∀ p, σ₀ p = true ↔ M.interp p t := fun p => by
    simp only [σ₀, @decide_eq_true_eq _ (Classical.dec _)]
  -- M_blend agrees with M_ext on freshAM atoms
  have hF1 : ∀ (ep : ExtPred sig) (z : Int),
      z ∈ M_blend.val (freshAM ep) ↔ z ∈ M_ext.val (freshAM ep) := by
    intro ep z
    simp only [M_blend, M_ext, M_orig, Set.mem_union, to_int_struct, Set.mem_setOf_eq]
    constructor
    · rintro (h | ⟨p, hpe, _⟩)
      · exact h
      · exact absurd hpe (h_disj p ep)
    · exact Or.inl
  -- M_blend agrees with M_orig on atomMap atoms
  have hF2 : ∀ (p : sig.preds) (z : Int),
      z ∈ M_blend.val (atomMap p) ↔ z ∈ M_orig.val (atomMap p) := by
    intro p z
    simp only [M_blend, M_ext, M_orig, Set.mem_union, to_int_struct, Set.mem_setOf_eq]
    constructor
    · rintro (⟨ep, hepa, _⟩ | h)
      · exact absurd hepa.symm (h_disj p ep)
      · exact h
    · exact Or.inr
  -- Transfer B_sep truth: M_ext ↔ M_blend
  have h_ext_blend : Separation.int_truth M_ext t B_sep ↔ Separation.int_truth M_blend t B_sep := by
    apply int_truth_depends_on_atoms
    intro a ha z
    obtain ⟨ep, rfl⟩ := hB_atoms ha
    exact (hF1 ep z).symm
  -- Transfer quantElimFormula: M_blend ↔ M_orig
  have h_blend_orig :
      Separation.int_truth M_blend t (quantElimFormula atomMap freshAM B_sep) ↔
      Separation.int_truth M_orig t (quantElimFormula atomMap freshAM B_sep) := by
    apply int_truth_depends_on_atoms
    intro a ha z
    obtain ⟨p, rfl⟩ := formula_atoms_quantElimFormula_subset
        atomMap freshAM freshAM_inj (fun p ep => h_disj p ep) B_sep hB_atoms ha
    exact hF2 p z
  rw [h_ext_blend]
  change Separation.int_truth M_blend t B_sep ↔
    Separation.int_truth M_orig t (quantElimFormula atomMap freshAM B_sep)
  rw [← h_blend_orig]
  -- Now prove: M_blend truth of B_sep ↔ M_blend truth of quantElimFormula
  -- Unfold quantElimFormula
  simp only [quantElimFormula]
  set lt_atom := freshAM .lt_ref
  set gt_atom := freshAM .gt_ref
  set origSubs := origSubsList atomMap freshAM
  set assignments := (Finset.univ : Finset (sig.preds → Bool)).toList
  set branches := assignments.map fun σ =>
    Formula.and (guardFormula atomMap σ)
                (elimExtFromSep (origSubs ++ constSubsList freshAM σ) lt_atom gt_atom B_sep)
  -- Reduce to existence over branches
  rw [int_truth_branches_iff]
  -- σ₀ is in assignments
  have hσ₀_mem : σ₀ ∈ assignments := by
    simp [assignments, Finset.mem_toList, Finset.mem_univ]
  -- σ₀'s branch is in branches
  have hbranch_mem : (Formula.and (guardFormula atomMap σ₀)
      (elimExtFromSep (origSubs ++ constSubsList freshAM σ₀) lt_atom gt_atom B_sep)) ∈ branches := by
    exact List.mem_map.mpr ⟨σ₀, hσ₀_mem, rfl⟩
  -- Helper: h_match for applySubsts_past_correct on M_blend at time s ≤ some_val ≤ t
  -- For past substitutions subs_past = origSubs ++ constSubs_σ₀ ++ [(lt_atom, ¬⊥), (gt_atom, ⊥)]
  -- The h_match condition in M_blend: ∀ r ≤ s_bound, int_truth M_blend r r_formula ↔ r ∈ M_blend.val a
  have past_match : ∀ (a : Atom) (r : Formula),
      (a, r) ∈ origSubs ++ constSubsList freshAM σ₀ ++
        [(lt_atom, Formula.neg .bot), (gt_atom, .bot)] →
      ∀ s_bound : Int, s_bound < t →
      ∀ r_val : Int, r_val ≤ s_bound →
      (Separation.int_truth M_blend r_val r ↔ r_val ∈ M_blend.val a) := by
    intro a r hmem s_bound hs_bound r_val hr_val
    simp only [origSubs, origSubsList, constSubsList, List.mem_append, List.mem_map,
               Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons,
               List.mem_singleton, Prod.mk.injEq] at hmem
    rcases hmem with (⟨p, rfl, rfl⟩ | ⟨p, rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · -- (freshAM (.orig p), atom(atomMap p)): M_blend agrees on both
      simp only [Separation.int_truth]
      rw [hF1 (.orig p) r_val, hF2 p r_val]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj (.orig p) r_val,
                 M_orig, to_int_struct_mem_atomMap M atomMap hinj p r_val]
      simp [extIntStruct]
    · -- (freshAM (.const_at_ref p), if σ₀ p then ¬⊥ else ⊥)
      rw [hF1 (.const_at_ref p) r_val]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj (.const_at_ref p) r_val,
                 extIntStruct]
      by_cases hsp : σ₀ p = true
      · simp only [hsp, ite_true, Separation.int_truth, Formula.neg]
        constructor
        · intro; exact (hσ₀ p).mp hsp
        · intro; trivial
      · simp only [show σ₀ p = false from Bool.not_eq_true.mp (Bool.eq_false_iff.mpr hsp),
                   ite_false, Separation.int_truth]
        constructor
        · intro h; exact h.elim
        · intro h; exact absurd ((hσ₀ p).mpr h) hsp
    · -- (lt_atom, ¬⊥): True ↔ r_val ∈ M_blend.val lt_atom
      rw [hF1 .lt_ref r_val]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj .lt_ref r_val,
                 extIntStruct, Separation.int_truth, Formula.neg]
      exact ⟨fun _ => lt_of_le_of_lt hr_val hs_bound, fun _ => trivial⟩
    · -- (gt_atom, ⊥): False ↔ r_val ∈ M_blend.val gt_atom
      rw [hF1 .gt_ref r_val]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj .gt_ref r_val,
                 extIntStruct, Separation.int_truth]
      exact ⟨False.elim, fun h => absurd (lt_of_le_of_lt hr_val hs_bound) (not_lt.mpr h.le)⟩
  -- Future match for future substitutions
  have future_match : ∀ (a : Atom) (r : Formula),
      (a, r) ∈ origSubs ++ constSubsList freshAM σ₀ ++
        [(.bot : Formula).neg, Formula.neg .bot].zip [gt_atom, lt_atom] →
      True := trivial
  -- Actually build future_match properly
  have fut_match : ∀ (a : Atom) (r : Formula),
      (a, r) ∈ origSubs ++ constSubsList freshAM σ₀ ++
        [(lt_atom, .bot), (gt_atom, Formula.neg .bot)] →
      ∀ s_bound : Int, t < s_bound →
      ∀ r_val : Int, s_bound ≤ r_val →
      (Separation.int_truth M_blend r_val r ↔ r_val ∈ M_blend.val a) := by
    intro a r hmem s_bound hs_bound r_val hr_val
    simp only [origSubs, origSubsList, constSubsList, List.mem_append, List.mem_map,
               Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons,
               List.mem_singleton, Prod.mk.injEq] at hmem
    rcases hmem with (⟨p, rfl, rfl⟩ | ⟨p, rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · -- orig: same as past case
      simp only [Separation.int_truth]
      rw [hF1 (.orig p) r_val, hF2 p r_val]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj (.orig p) r_val,
                 M_orig, to_int_struct_mem_atomMap M atomMap hinj p r_val]
      simp [extIntStruct]
    · -- const_at_ref: same as past case
      rw [hF1 (.const_at_ref p) r_val]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj (.const_at_ref p) r_val,
                 extIntStruct]
      by_cases hsp : σ₀ p = true
      · simp only [hsp, ite_true, Separation.int_truth, Formula.neg]
        exact ⟨fun _ => (hσ₀ p).mp hsp, fun _ => trivial⟩
      · simp only [show σ₀ p = false from Bool.not_eq_true.mp (Bool.eq_false_iff.mpr hsp),
                   ite_false, Separation.int_truth]
        exact ⟨False.elim, fun h => absurd ((hσ₀ p).mpr h) hsp⟩
    · -- (lt_atom, ⊥): False ↔ r_val ∈ M_blend.val lt_atom = r_val < t
      rw [hF1 .lt_ref r_val]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj .lt_ref r_val,
                 extIntStruct, Separation.int_truth]
      exact ⟨False.elim, fun h => absurd h (not_lt.mpr (le_of_lt (lt_of_lt_of_le hs_bound hr_val)))⟩
    · -- (gt_atom, ¬⊥): True ↔ r_val ∈ M_blend.val gt_atom = t < r_val
      rw [hF1 .gt_ref r_val]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj .gt_ref r_val,
                 extIntStruct, Separation.int_truth, Formula.neg]
      exact ⟨fun _ => lt_of_lt_of_le hs_bound hr_val, fun _ => trivial⟩
  -- Present-level match for atom case
  have pres_match : ∀ (a : Atom) (r : Formula),
      (a, r) ∈ origSubs ++ constSubsList freshAM σ₀ ++
        [(lt_atom, .bot), (gt_atom, .bot)] →
      (Separation.int_truth M_blend t r ↔ t ∈ M_blend.val a) := by
    intro a r hmem
    simp only [origSubs, origSubsList, constSubsList, List.mem_append, List.mem_map,
               Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons,
               List.mem_singleton, Prod.mk.injEq] at hmem
    rcases hmem with (⟨p, rfl, rfl⟩ | ⟨p, rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · simp only [Separation.int_truth]
      rw [hF1 (.orig p) t, hF2 p t]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj (.orig p) t,
                 M_orig, to_int_struct_mem_atomMap M atomMap hinj p t]
      simp [extIntStruct]
    · rw [hF1 (.const_at_ref p) t]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj (.const_at_ref p) t,
                 extIntStruct]
      by_cases hsp : σ₀ p = true
      · simp only [hsp, ite_true, Separation.int_truth, Formula.neg]
        exact ⟨fun _ => (hσ₀ p).mp hsp, fun _ => trivial⟩
      · simp only [show σ₀ p = false from Bool.not_eq_true.mp (Bool.eq_false_iff.mpr hsp),
                   ite_false, Separation.int_truth]
        exact ⟨False.elim, fun h => absurd ((hσ₀ p).mpr h) hsp⟩
    · rw [hF1 .lt_ref t]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj .lt_ref t,
                 extIntStruct, Separation.int_truth]
      exact ⟨False.elim, fun h => absurd h (lt_irrefl t)⟩
    · rw [hF1 .gt_ref t]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj .gt_ref t,
                 extIntStruct, Separation.int_truth]
      exact ⟨False.elim, fun h => absurd h (lt_irrefl t)⟩
  -- is_past_only/future_only of replacement formulas in subs
  have past_reps_po : ∀ (a : Atom) (r : Formula),
      (a, r) ∈ origSubs ++ constSubsList freshAM σ₀ ++
        [(lt_atom, Formula.neg .bot), (gt_atom, .bot)] →
      Separation.is_past_only r = true := by
    intro a r hmem
    simp only [origSubs, origSubsList, constSubsList, List.mem_append, List.mem_map,
               Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons,
               List.mem_singleton, Prod.mk.injEq] at hmem
    rcases hmem with (⟨_, _, rfl⟩ | ⟨p, _, rfl⟩ | ⟨_, rfl⟩ | ⟨_, rfl⟩)
    · simp [Separation.is_past_only]
    · by_cases h : σ₀ p = true <;> simp [h, Separation.is_past_only, Formula.neg]
    · simp [Separation.is_past_only, Formula.neg]
    · simp [Separation.is_past_only]
  have fut_reps_fo : ∀ (a : Atom) (r : Formula),
      (a, r) ∈ origSubs ++ constSubsList freshAM σ₀ ++
        [(lt_atom, .bot), (gt_atom, Formula.neg .bot)] →
      Separation.is_future_only r = true := by
    intro a r hmem
    simp only [origSubs, origSubsList, constSubsList, List.mem_append, List.mem_map,
               Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons,
               List.mem_singleton, Prod.mk.injEq] at hmem
    rcases hmem with (⟨_, _, rfl⟩ | ⟨p, _, rfl⟩ | ⟨_, rfl⟩ | ⟨_, rfl⟩)
    · simp [Separation.is_future_only]
    · by_cases h : σ₀ p = true <;> simp [h, Separation.is_future_only, Formula.neg]
    · simp [Separation.is_future_only]
    · simp [Separation.is_future_only, Formula.neg]
  -- Key body correctness: B_sep truth in M_blend ↔ elimExtFromSep body truth in M_blend
  -- Proved by structural induction on B_sep
  have body_correct : Separation.int_truth M_blend t B_sep ↔
      Separation.int_truth M_blend t
        (elimExtFromSep (origSubs ++ constSubsList freshAM σ₀) lt_atom gt_atom B_sep) := by
    induction B_sep with
    | atom a =>
      simp only [Separation.is_properly_separated] at hB_sep
      obtain ⟨ep, rfl⟩ := hB_atoms (Set.mem_singleton a)
      simp only [elimExtFromSep, Separation.int_truth]
      -- applySubsts (.atom (freshAM ep)) (origSubs ++ constSubs ++ [(lt,⊥),(gt,⊥)])
      -- The result is the replacement for freshAM ep
      -- Use pres_match to identify which substitution applies
      rw [show applySubsts (.atom (freshAM ep))
              (origSubs ++ constSubsList freshAM σ₀ ++ [(lt_atom, .bot), (gt_atom, .bot)]) =
          let subs := origSubs ++ constSubsList freshAM σ₀ ++ [(lt_atom, .bot), (gt_atom, .bot)]
          applySubsts (.atom (freshAM ep)) subs from rfl]
      -- Use past_only_subst_correct (actually simpler: direct computation)
      -- The atom freshAM ep gets replaced by the corresponding formula
      -- We need: int_truth M_blend t (applySubsts (.atom (freshAM ep)) subs) ↔ t ∈ M_blend.val (freshAM ep)
      -- i.e., ↔ (extIntStruct M t).interp ep t (via hF1)
      rw [hF1 ep t]
      simp only [M_ext, to_int_struct_mem_freshAM M t freshAM freshAM_inj ep t, extIntStruct]
      -- Now prove: int_truth M_blend t (applySubsts (.atom (freshAM ep)) subs) ↔ (extIntStruct M t).interp ep t
      -- The left side depends on which ep we have
      cases ep with
      | orig p =>
        have h_rw : applySubsts (.atom (freshAM (.orig p)))
            (origSubs ++ constSubsList freshAM σ₀ ++ [(lt_atom, .bot), (gt_atom, .bot)]) =
            .atom (atomMap p) := by
          apply applySubsts_atom_with_match
          · apply List.mem_append.mpr; left; apply List.mem_append.mpr; left
            simp only [origSubs, origSubsList, List.mem_map, Finset.mem_toList,
                       Finset.mem_univ, true_and, Prod.mk.injEq]
            exact ⟨p, rfl, rfl⟩
          · intro a' _ hmem' ha'
            simp only [Separation.formula_atoms, Set.mem_singleton_iff] at ha'
            subst ha'
            simp only [origSubs, origSubsList, constSubsList, List.mem_append, List.mem_map,
                       Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons,
                       List.mem_singleton, Prod.mk.injEq] at hmem'
            rcases hmem' with (⟨q, rfl, _⟩ | ⟨q, rfl, _⟩ | ⟨rfl, _⟩ | ⟨rfl, _⟩)
            · exact h_disj p (.orig q)
            · exact h_disj p (.const_at_ref q)
            · exact h_disj p .lt_ref
            · exact h_disj p .gt_ref
        rw [h_rw]
        simp only [Separation.int_truth]
        rw [hF2 p t]
        simp only [M_orig, to_int_struct_mem_atomMap M atomMap hinj p t]
      | const_at_ref p =>
        have h_rw : applySubsts (.atom (freshAM (.const_at_ref p)))
            (origSubs ++ constSubsList freshAM σ₀ ++ [(lt_atom, .bot), (gt_atom, .bot)]) =
            if σ₀ p then Formula.neg .bot else .bot := by
          apply applySubsts_atom_with_match
          · apply List.mem_append.mpr; left; apply List.mem_append.mpr; right
            simp only [constSubsList, List.mem_map, Finset.mem_toList,
                       Finset.mem_univ, true_and, Prod.mk.injEq]
            exact ⟨p, rfl, rfl⟩
          · intro a' r' _ ha'
            by_cases hsp : σ₀ p = true
            · simp only [hsp, ite_true, Separation.formula_atoms, Set.mem_empty_iff_false] at ha'
            · simp only [show σ₀ p = false from Bool.not_eq_true.mp (Bool.eq_false_iff.mpr hsp),
                         ite_false, Separation.formula_atoms, Set.mem_empty_iff_false] at ha'
        rw [h_rw]
        by_cases hsp : σ₀ p = true
        · simp only [hsp, ite_true, Separation.int_truth, Formula.neg]
          exact ⟨fun _ => (hσ₀ p).mp hsp, fun _ => trivial⟩
        · simp only [show σ₀ p = false from Bool.not_eq_true.mp (Bool.eq_false_iff.mpr hsp),
                     ite_false, Separation.int_truth]
          exact ⟨False.elim, fun h => absurd ((hσ₀ p).mpr h) hsp⟩
      | lt_ref =>
        have h_rw : applySubsts (.atom (freshAM .lt_ref))
            (origSubs ++ constSubsList freshAM σ₀ ++ [(lt_atom, .bot), (gt_atom, .bot)]) =
            .bot := by
          apply applySubsts_atom_with_match
          · apply List.mem_append.mpr; right
            simp [lt_atom]
          · intro _ _ _ ha'
            simp [Separation.formula_atoms] at ha'
        rw [h_rw]
        simp only [Separation.int_truth]
        exact ⟨False.elim, fun h => absurd h (lt_irrefl t)⟩
      | gt_ref =>
        have h_rw : applySubsts (.atom (freshAM .gt_ref))
            (origSubs ++ constSubsList freshAM σ₀ ++ [(lt_atom, .bot), (gt_atom, .bot)]) =
            .bot := by
          apply applySubsts_atom_with_match
          · apply List.mem_append.mpr; right
            simp [gt_atom]
          · intro _ _ _ ha'
            simp [Separation.formula_atoms] at ha'
        rw [h_rw]
        simp only [Separation.int_truth]
        exact ⟨False.elim, fun h => absurd h (lt_irrefl t)⟩
    | bot => simp [elimExtFromSep, Separation.int_truth]
    | imp α β ihα ihβ =>
      simp only [Separation.is_properly_separated, Bool.and_eq_true] at hB_sep
      simp only [elimExtFromSep, Separation.int_truth]
      exact imp_congr
        (ihα hB_sep.1 (fun a ha => hB_atoms (Set.mem_union_left _ ha)))
        (ihβ hB_sep.2 (fun a ha => hB_atoms (Set.mem_union_right _ ha)))
    | box φ _ =>
      simp [elimExtFromSep, Separation.int_truth]
    | snce α β ihα ihβ =>
      simp only [Separation.is_properly_separated, Bool.and_eq_true] at hB_sep
      simp only [elimExtFromSep, Separation.int_truth]
      constructor
      · rintro ⟨s, hs, hα, hβ⟩
        have α_po : Separation.is_past_only α = true := hB_sep.1
        have β_po : Separation.is_past_only β = true := hB_sep.2
        refine ⟨s, hs, ?_, fun r hr1 hr2 => ?_⟩
        · rw [← applySubsts_past_correct α_po _ M_blend s past_reps_po
                (fun a r hmem r_val hr_val => past_match a r hmem s hs r_val hr_val)]
          exact hα
        · rw [← applySubsts_past_correct β_po _ M_blend r past_reps_po
                (fun a r' hmem r_val hr_val => past_match a r' hmem r hr2 r_val hr_val)]
          exact hβ r hr1 hr2
      · rintro ⟨s, hs, hα, hβ⟩
        have α_po : Separation.is_past_only α = true := hB_sep.1
        have β_po : Separation.is_past_only β = true := hB_sep.2
        refine ⟨s, hs, ?_, fun r hr1 hr2 => ?_⟩
        · rw [← applySubsts_past_correct α_po _ M_blend s past_reps_po
                (fun a r' hmem r_val hr_val => past_match a r' hmem s hs r_val hr_val)] at hα
          exact hα
        · rw [← applySubsts_past_correct β_po _ M_blend r past_reps_po
                (fun a r' hmem r_val hr_val => past_match a r' hmem r hr2 r_val hr_val)] at hβ
          exact hβ r hr1 hr2
    | untl α β ihα ihβ =>
      simp only [Separation.is_properly_separated, Bool.and_eq_true] at hB_sep
      simp only [elimExtFromSep, Separation.int_truth]
      constructor
      · rintro ⟨s, hs, hα, hβ⟩
        have α_fo : Separation.is_future_only α = true := hB_sep.1
        have β_fo : Separation.is_future_only β = true := hB_sep.2
        refine ⟨s, hs, ?_, fun r hr1 hr2 => ?_⟩
        · rw [← applySubsts_future_correct α_fo _ M_blend s fut_reps_fo
                (fun a r hmem r_val hr_val => fut_match a r hmem s hs r_val hr_val)]
          exact hα
        · rw [← applySubsts_future_correct β_fo _ M_blend r fut_reps_fo
                (fun a r' hmem r_val hr_val => fut_match a r' hmem r hr1 r_val hr_val)]
          exact hβ r hr1 hr2
      · rintro ⟨s, hs, hα, hβ⟩
        have α_fo : Separation.is_future_only α = true := hB_sep.1
        have β_fo : Separation.is_future_only β = true := hB_sep.2
        refine ⟨s, hs, ?_, fun r hr1 hr2 => ?_⟩
        · rw [← applySubsts_future_correct α_fo _ M_blend s fut_reps_fo
                (fun a r' hmem r_val hr_val => fut_match a r' hmem s hs r_val hr_val)] at hα
          exact hα
        · rw [← applySubsts_future_correct β_fo _ M_blend r fut_reps_fo
                (fun a r' hmem r_val hr_val => fut_match a r' hmem r hr1 r_val hr_val)] at hβ
          exact hβ r hr1 hr2
  -- Main equivalence using body_correct and guardFormula_correct
  constructor
  · -- (→): B_sep true → quantElimFormula true
    intro h_Bsep
    refine ⟨_, hbranch_mem, ?_⟩
    rw [Separation.int_truth_and_iff]
    constructor
    · -- guard σ₀ is true
      rw [guardFormula_correct atomMap hinj σ₀ M t]
      exact hσ₀
    · -- body is true: use body_correct
      exact body_correct.mp h_Bsep
  · -- (←): quantElimFormula true → B_sep true
    rintro ⟨branch, h_branch_mem, h_branch_true⟩
    simp only [branches, List.mem_map] at h_branch_mem
    obtain ⟨σ, _, rfl⟩ := h_branch_mem
    rw [Separation.int_truth_and_iff] at h_branch_true
    obtain ⟨h_guard, h_body⟩ := h_branch_true
    -- guard true means σ = σ₀
    rw [guardFormula_correct atomMap hinj σ M t] at h_guard
    have hσ_eq : σ = σ₀ := by
      funext p
      have h1 := h_guard p
      have h2 := hσ₀ p
      rcases Bool.dichotomy (σ p) with hs | hs <;>
        rcases Bool.dichotomy (σ₀ p) with hs0 | hs0 <;> simp_all
    subst hσ_eq
    exact body_correct.mpr h_body

end Bimodal.Metalogic.WeakCanonical
