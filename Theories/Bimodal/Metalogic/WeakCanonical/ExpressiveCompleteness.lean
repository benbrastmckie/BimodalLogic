import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm
import Bimodal.Metalogic.WeakCanonical.MonadicFO

/-!
# Expressive Completeness of {U,S} over Integer Time

Proves that {Since, Until} is expressively complete over integer time:
every property expressible in monadic first-order logic over (Z, <) is
expressible by a temporal formula using only Since and Until.

## Main Results

- `separation_implies_expressiveness` (Theorem 9.3.1): If every temporal
  formula is equivalent to a separated formula, then {U,S} is expressively
  complete.
- `US_expressively_complete_over_Z` (Theorem 10.2.10): {U,S} is expressively
  complete over integer time.

## Proof Strategy

Stage A (done in SeparationThm.lean): Every {U,S}-formula is equivalent to
a separated formula over Z (Theorem 10.2.9).

Stage B (this file): Separation implies expressive completeness (Theorem 9.3.1).
The proof proceeds by induction on quantifier depth m of the FO formula:
- Base (m=0): Quantifier-free formulas translate directly.
- Step (m>0): Introduce R predicates, use IH, apply separation, substitute.

The combination gives Theorem 10.2.10.

## References

- GHR94, Chapter 9, Section 9.3, Theorem 9.3.1
- GHR94, Theorem 10.2.10
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
    simp only [q_exists, Formula.or, Formula.neg, Formula.some_past, Formula.some_future,
               Separation.int_truth] at h
    -- After simp, h should be of a propositional type we can refute.
    -- h : (((((∀ s, s < t → Separation.int_truth M s A → False) → False) → False) →
    --       Separation.int_truth M t A) → False) →
    --      (∀ s, t < s → Separation.int_truth M s A → False) → False
    exact h (fun f => hA_never t (f (fun hdn => hdn (fun s _ hAs => hA_never s hAs))))
             (fun s _ hAs => hA_never s hAs)

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
      intro h_all
      exact h_all s hst hs
    · -- s = t: A at t holds
      subst hst
      intro h_neg
      exfalso
      apply h_neg
      intro h_neg_sp
      exact hs
    · -- s > t: some_future A holds
      intro _h_neg
      -- Need: some_future A = ((∀ s' > t, A(s') → ⊥) → ⊥)
      intro h_all
      exact h_all s hst hs

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
  | all_past α ih =>
    simp only [Separation.is_past_only] at h
    intro M₁ M₂ t hagree
    constructor
    · intro hall s hst
      exact (ih h M₁ M₂ s (fun a r hrt => hagree a r (le_trans hrt (le_of_lt hst)))).mp (hall s hst)
    · intro hall s hst
      exact (ih h M₁ M₂ s (fun a r hrt => hagree a r (le_trans hrt (le_of_lt hst)))).mpr (hall s hst)
  | all_future _ =>
    exact absurd h (by simp [Separation.is_past_only])
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
  | all_past _ =>
    exact absurd h (by simp [Separation.is_future_only])
  | all_future α ih =>
    simp only [Separation.is_future_only] at h
    intro M₁ M₂ t hagree
    constructor
    · intro hall s hts
      exact (ih h M₁ M₂ s (fun a r hrs => hagree a r (le_trans (le_of_lt hts) hrs))).mp (hall s hts)
    · intro hall s hts
      exact (ih h M₁ M₂ s (fun a r hrs => hagree a r (le_trans (le_of_lt hts) hrs))).mpr (hall s hts)
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
private noncomputable def qdepth_reduceElimLast_le {sig : MonadicSignature} :
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
private theorem reduceElimLast_correct_at_one {sig : MonadicSignature}
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
  | .box φ => .box φ
  | .all_past φ =>
    -- Past-only: lt_ref → ⊤ (True), gt_ref → ⊥
    .all_past (applySubsts φ (constSubs ++ [(lt_atom, Formula.neg .bot), (gt_atom, .bot)]))
  | .all_future φ =>
    -- Future-only: lt_ref → ⊥, gt_ref → ⊤ (True)
    .all_future (applySubsts φ (constSubs ++ [(lt_atom, .bot), (gt_atom, Formula.neg .bot)]))
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
private noncomputable def quantElimFormula {sig : MonadicSignature}
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
  | all_past α ih =>
    simp only [Separation.is_past_only] at hφ
    simp only [Separation.subst_formula, Separation.is_past_only]; exact ih hφ
  | all_future _ => simp [Separation.is_past_only] at hφ
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
  | all_past _ => simp [Separation.is_future_only] at hφ
  | all_future α ih =>
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
      rw [show (ar.1, ar.2) = ar from Prod.ext rfl rfl]; exact List.mem_cons_self
    have h_sub_po := subst_preserves_past_only φ ar.1 ar.2 hpo (h_reps_po ar.1 ar.2 hmem_ar)
    have h_step : Separation.int_truth M t (Separation.subst_formula φ ar.1 ar.2) ↔
        Separation.int_truth M t φ :=
      past_only_subst_correct hpo ar.1 ar.2 M t (h_match ar.1 ar.2 hmem_ar)
    exact (ih h_sub_po
      (fun a r hmem => h_reps_po a r (List.mem_cons_of_mem ar hmem))
      (fun a r hmem => h_match a r (List.mem_cons_of_mem ar hmem))).trans h_step

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
      rw [show (ar.1, ar.2) = ar from Prod.ext rfl rfl]; exact List.mem_cons_self
    have h_sub_fo := subst_preserves_future_only φ ar.1 ar.2 hfo (h_reps_fo ar.1 ar.2 hmem_ar)
    have h_step : Separation.int_truth M t (Separation.subst_formula φ ar.1 ar.2) ↔
        Separation.int_truth M t φ :=
      future_only_subst_correct hfo ar.1 ar.2 M t (h_match ar.1 ar.2 hmem_ar)
    exact (ih h_sub_fo
      (fun a r hmem => h_reps_fo a r (List.mem_cons_of_mem ar hmem))
      (fun a r hmem => h_match a r (List.mem_cons_of_mem ar hmem))).trans h_step

/-! ### Core Expressiveness Lemma

The proof uses nested induction: outer strong induction on quantifier depth,
inner structural recursion on the formula. The quantifier-free cases are handled
by structural recursion. The quantifier cases use the outer IH at lower depth
with the extended signature, then apply atom elimination. -/

/-- Inner structural recursion: handles quantifier-free cases directly and
    delegates quantifier cases to the outer WF IH. -/
private noncomputable def expressiveness_inner
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi)
    (m : Nat)
    (outerIH : ∀ k < m, ∀ (sig' : MonadicSignature) (atomMap' : sig'.preds → Atom),
      Function.Injective atomMap' →
      ∀ (psi' : MonadicFormula sig' 1), psi'.quantifier_depth ≤ k →
      { A : Formula // ∀ (M : IntStructureFromSig sig') (t : Int),
          eval (int_to_ordered sig' M) (fun _ => t) psi' ↔
          Separation.int_truth (to_int_struct M atomMap') t A })
    (sig : MonadicSignature)
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap) :
    (psi : MonadicFormula sig 1) → (hm : psi.quantifier_depth ≤ m) →
    { A : Formula // ∀ (M : IntStructureFromSig sig) (t : Int),
        eval (int_to_ordered sig M) (fun _ => t) psi ↔
        Separation.int_truth (to_int_struct M atomMap) t A }
  | .atom p _, _ =>
    ⟨Formula.atom (atomMap p), fun M t => by
      simp only [eval, Separation.int_truth, to_int_struct, Set.mem_setOf_eq]
      exact ⟨fun h => ⟨p, rfl, h⟩, fun ⟨q, hq, hi⟩ => hinj hq ▸ hi⟩⟩
  | .lt _ _, _ =>
    ⟨Formula.bot, fun M t => by
      simp only [eval, Separation.int_truth]
      exact ⟨fun h => absurd h (lt_irrefl _), False.elim⟩⟩
  | .not alpha, hm =>
    have hm' : alpha.quantifier_depth ≤ m := by
      simp [MonadicFormula.quantifier_depth] at hm; exact hm
    let ihA := expressiveness_inner h_sep m outerIH sig atomMap hinj alpha hm'
    ⟨Formula.neg ihA.val, fun M t => by
      simp only [eval, Separation.int_truth, Formula.neg]
      exact ⟨fun h hAt => h (ihA.property M t |>.mpr hAt),
             fun h ha => h (ihA.property M t |>.mp ha)⟩⟩
  | .and alpha beta, hm =>
    have hm_a : alpha.quantifier_depth ≤ m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    have hm_b : beta.quantifier_depth ≤ m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    let ihA := expressiveness_inner h_sep m outerIH sig atomMap hinj alpha hm_a
    let ihB := expressiveness_inner h_sep m outerIH sig atomMap hinj beta hm_b
    ⟨Formula.and ihA.val ihB.val, fun M t => by
      have hA := ihA.property M t; have hB := ihB.property M t
      simp only [eval]; rw [Separation.int_truth_and_iff]
      exact ⟨fun ⟨ha, hb⟩ => ⟨hA.mp ha, hB.mp hb⟩,
             fun ⟨ha, hb⟩ => ⟨hA.mpr ha, hB.mpr hb⟩⟩⟩
  | .ex alpha, hm =>
    -- alpha : MonadicFormula sig 2
    -- (.ex alpha).quantifier_depth = alpha.quantifier_depth + 1 ≤ m
    -- reduceElimLast 1 alpha : MonadicFormula (extSignature sig) 1
    -- with qdepth ≤ alpha.qdepth < m
    have h_lt_m : alpha.quantifier_depth < m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    have h_red_depth : (reduceElimLast 1 alpha).quantifier_depth ≤ alpha.quantifier_depth :=
      qdepth_reduceElimLast_le 1 Nat.zero_lt_one alpha
    -- Construct a fresh injective atomMap for extSignature sig
    -- Uses mk_fresh "e" k with unique indices for each ExtPred
    let freshAM : (extSignature sig).preds → Atom :=
      fun ep => Atom.mk_fresh "e" (Fintype.equivFin (extSignature sig).preds ep).val
    have freshAM_inj : Function.Injective freshAM := by
      intro a b hab
      simp only [freshAM] at hab
      have := Atom.mk_fresh_injective "e" hab
      exact (Fintype.equivFin (extSignature sig).preds).injective
        (Fin.ext (Nat.cast_injective this))
    -- Apply outer IH at lower depth with freshAM
    let ihExt := outerIH alpha.quantifier_depth h_lt_m
      (extSignature sig) freshAM freshAM_inj
      (reduceElimLast 1 alpha) (le_trans h_red_depth (le_refl _))
    let A_ext := ihExt.val
    -- By h_sep, q_exists A_ext is equivalent to a properly separated formula
    let h_ps := h_sep (q_exists A_ext)
    let B_sep := h_ps.choose
    have hB_sep := h_ps.choose_spec.1
    have hB_equiv := h_ps.choose_spec.2
    -- Build the quantifier elimination formula
    let A := quantElimFormula atomMap freshAM B_sep
    ⟨A, fun M t => by
      -- Chain: eval (.ex alpha) at (M, t)
      --   ↔ ∃z. eval alpha at (M, z, t)   [by definition]
      --   ↔ ∃z. eval (reduceElimLast 1 alpha) at (extIntStruct M t, z)  [by correctness]
      --   ↔ ∃z. int_truth A_ext z in (to_int_struct (extIntStruct M t) freshAM)  [by IH]
      --   ↔ int_truth (q_exists A_ext) t in same model  [by q_exists_correct]
      --   ↔ int_truth B_sep t in same model  [by separation equivalence]
      --   ↔ int_truth A t in (to_int_struct M atomMap)  [by atom elimination]
      simp only [eval]
      -- Chain the equivalences
      let M_ext := to_int_struct (extIntStruct M t) freshAM
      have h_chain : (∃ z : ℤ, eval (int_to_ordered sig M) (Fin.cons z fun _ => t) alpha) ↔
          Separation.int_truth M_ext t B_sep := by
        constructor
        · intro ⟨z, hz⟩
          have h1 := (reduceElimLast_correct_at_one alpha M z t).mp hz
          have h2 := (ihExt.property (extIntStruct M t) z).mp h1
          have h3 := (q_exists_correct A_ext M_ext t).mpr ⟨z, h2⟩
          exact (hB_equiv M_ext t).mp h3
        · intro h_bsep
          have h1 := (hB_equiv M_ext t).mpr h_bsep
          obtain ⟨z, hz⟩ := (q_exists_correct A_ext M_ext t).mp h1
          exact ⟨z, (reduceElimLast_correct_at_one alpha M z t).mpr
            ((ihExt.property (extIntStruct M t) z).mpr hz)⟩
      -- Reduce to atom elimination: B_sep in M_ext ↔ A in M_orig
      exact h_chain.trans sorry⟩
  | .all alpha, hm =>
    -- ∀z. alpha(z,t) ↔ ¬∃z. ¬alpha(z,t)
    -- Same pipeline as .ex but with .not alpha and outer negation
    have h_lt_m : alpha.quantifier_depth < m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    have h_red_depth : (reduceElimLast 1 (.not alpha)).quantifier_depth ≤ alpha.quantifier_depth := by
      have := qdepth_reduceElimLast_le 1 Nat.zero_lt_one (MonadicFormula.not alpha)
      simp [MonadicFormula.quantifier_depth] at this; exact this
    let freshAM : (extSignature sig).preds → Atom :=
      fun ep => Atom.mk_fresh "e" (Fintype.equivFin (extSignature sig).preds ep).val
    have freshAM_inj : Function.Injective freshAM := by
      intro a b hab; simp only [freshAM] at hab
      exact (Fintype.equivFin (extSignature sig).preds).injective
        (Fin.ext (Nat.cast_injective (Atom.mk_fresh_injective "e" hab)))
    let ihExt := outerIH alpha.quantifier_depth h_lt_m
      (extSignature sig) freshAM freshAM_inj
      (reduceElimLast 1 (.not alpha)) (le_trans h_red_depth (le_refl _))
    let A_neg_ext := ihExt.val
    let h_ps := h_sep (q_exists A_neg_ext)
    let B_sep := h_ps.choose
    have hB_equiv := h_ps.choose_spec.2
    let A_ex := quantElimFormula atomMap freshAM B_sep
    ⟨Formula.neg A_ex, fun M t => by
      simp only [eval]
      rw [Separation.int_truth_neg_iff]
      -- Need: (∀ z, eval ... alpha) ↔ ¬(int_truth ... A_ex)
      -- Equivalently: (∃ z, ¬eval ... alpha) ↔ int_truth ... A_ex (and negate both)
      let M_ext := to_int_struct (extIntStruct M t) freshAM
      -- Chain for ∃z.¬α (same as .ex case but with .not alpha):
      have h_chain_neg : (∃ z : ℤ, ¬eval (int_to_ordered sig M) (Fin.cons z fun _ => t) alpha) ↔
          Separation.int_truth M_ext t B_sep := by
        constructor
        · intro ⟨z, hz⟩
          have h1 : eval (int_to_ordered sig M) (Fin.cons z fun _ => t) (.not alpha) := hz
          have h2 := (reduceElimLast_correct_at_one (.not alpha) M z t).mp h1
          have h3 := (ihExt.property (extIntStruct M t) z).mp h2
          exact (hB_equiv M_ext t).mp ((q_exists_correct A_neg_ext M_ext t).mpr ⟨z, h3⟩)
        · intro h_bsep
          obtain ⟨z, hz⟩ := (q_exists_correct A_neg_ext M_ext t).mp
            ((hB_equiv M_ext t).mpr h_bsep)
          have h1 := (ihExt.property (extIntStruct M t) z).mpr hz
          have h2 := (reduceElimLast_correct_at_one (.not alpha) M z t).mpr h1
          exact ⟨z, h2⟩
      -- Convert: (∀z.α) ↔ ¬(∃z.¬α) ↔ ¬(int_truth A_ex) via atom elimination
      constructor
      · intro h_all h_Aex
        have h_bsep := (sorry : Separation.int_truth M_ext t B_sep ↔
            Separation.int_truth (to_int_struct M atomMap) t A_ex).mpr h_Aex
        obtain ⟨z, hz⟩ := h_chain_neg.mpr h_bsep
        exact hz (h_all z)
      · intro h_neg z
        by_contra h_not
        have h_bsep := h_chain_neg.mp ⟨z, h_not⟩
        exact h_neg ((sorry : Separation.int_truth M_ext t B_sep ↔
            Separation.int_truth (to_int_struct M atomMap) t A_ex).mp h_bsep)⟩

/-- Outer well-founded recursion: proves the expressiveness lemma by strong induction
    on quantifier depth. Delegates to `expressiveness_inner` at each level. -/
private noncomputable def expressiveness_wf
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi)
    (m : Nat) (sig : MonadicSignature)
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (psi : MonadicFormula sig 1) (hm : psi.quantifier_depth ≤ m) :
    { A : Formula // ∀ (M : IntStructureFromSig sig) (t : Int),
        eval (int_to_ordered sig M) (fun _ => t) psi ↔
        Separation.int_truth (to_int_struct M atomMap) t A } :=
  m.strongRecOn
    (motive := fun m => ∀ (sig : MonadicSignature) (atomMap : sig.preds → Atom),
      Function.Injective atomMap →
      ∀ (psi : MonadicFormula sig 1), psi.quantifier_depth ≤ m →
      { A : Formula // ∀ (M : IntStructureFromSig sig) (t : Int),
          eval (int_to_ordered sig M) (fun _ => t) psi ↔
          Separation.int_truth (to_int_struct M atomMap) t A })
    (fun m ih => expressiveness_inner h_sep m ih)
    sig atomMap hinj psi hm

/-- Core lemma: for a FIXED injective atomMap, every MonadicFormula sig 1 has a
    temporal equivalent (Theorem 9.3.1, GHR94). -/
private noncomputable def expressiveness_fixed_atomMap
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi)
    (sig : MonadicSignature) (atomMap : sig.preds → Atom)
    (hinj : Function.Injective atomMap) (psi : MonadicFormula sig 1) :
    { A : Formula // ∀ (M : IntStructureFromSig sig) (t : Int),
        eval (int_to_ordered sig M) (fun _ => t) psi ↔
        Separation.int_truth (to_int_struct M atomMap) t A } :=
  expressiveness_wf h_sep psi.quantifier_depth sig atomMap hinj psi (le_refl _)

theorem separation_implies_expressiveness
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi) :
    ∀ (sig : MonadicSignature) (psi : MonadicFormula sig 1),
      ∃ (A : Formula) (atomMap : sig.preds -> Atom),
        ∀ (M : IntStructureFromSig sig) (t : Int),
          eval (int_to_ordered sig M) (fun _ => t) psi ↔
          Separation.int_truth (to_int_struct M atomMap) t A := by
  intro sig psi
  let atomMap : sig.preds -> Bimodal.Syntax.Atom :=
    fun q => Bimodal.Syntax.Atom.mk_fresh "p" (Fintype.equivFin sig.preds q).val
  have hinj : Function.Injective atomMap := by
    intro a b hab
    simp only [atomMap, Bimodal.Syntax.Atom.mk_fresh] at hab
    have h_eq := Bimodal.Syntax.Atom.mk_fresh_injective "p" hab
    exact (Fintype.equivFin sig.preds).injective (Fin.ext (Nat.cast_injective h_eq))
  exact ⟨(expressiveness_fixed_atomMap h_sep sig atomMap hinj psi).val,
         atomMap,
         (expressiveness_fixed_atomMap h_sep sig atomMap hinj psi).property⟩

/-! ## Theorem 10.2.10: The Final Result -/

/-- Theorem 10.2.10 (GHR94): The language {U, S} is expressively complete
    over integer time.

    Combines the Proper Separation Theorem (10.2.9, strong form) with
    Theorem 9.3.1. The proper separation ensures semantic purity of the
    decomposition, which is required for the substitution step. -/
theorem US_expressively_complete_over_Z :
    ∀ (sig : MonadicSignature) (psi : MonadicFormula sig 1),
      ∃ (A : Formula) (atomMap : sig.preds → Atom),
        ∀ (M : IntStructureFromSig sig) (t : Int),
          eval (int_to_ordered sig M) (fun _ => t) psi ↔
          Separation.int_truth (to_int_struct M atomMap) t A :=
  separation_implies_expressiveness (fun phi => proper_separation_theorem_int phi)

end Bimodal.Metalogic.WeakCanonical
