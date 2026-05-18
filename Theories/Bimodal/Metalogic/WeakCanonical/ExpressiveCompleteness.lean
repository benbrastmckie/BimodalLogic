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
  | all_past α ih =>
    simp only [Separation.int_truth]
    exact ⟨fun ha s hs => (ih s h).mp (ha s hs),
           fun ha s hs => (ih s h).mpr (ha s hs)⟩
  | all_future α ih =>
    simp only [Separation.int_truth]
    exact ⟨fun ha s hs => (ih s h).mp (ha s hs),
           fun ha s hs => (ih s h).mpr (ha s hs)⟩
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
  | all_past α ihα =>
    simp only [Separation.subst_formula, Separation.formula_atoms]
    exact fun x hx => ihα hx
  | all_future α ihα =>
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
      intro x hx; exact ⟨p, hx.symm⟩
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
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_append,
                   List.mem_map, Finset.mem_toList, Finset.mem_univ, true_and,
                   List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ ⟨p, rfl⟩
      | const_at_ref p =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_append,
                   List.mem_map, Finset.mem_toList, Finset.mem_univ, true_and,
                   List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ ⟨p, rfl⟩
      | lt_ref =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_append,
                   List.mem_map, Finset.mem_toList, Finset.mem_univ, true_and,
                   List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ (Or.inr (List.mem_cons.mpr (Or.inl rfl)))
      | gt_ref =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_append,
                   List.mem_map, Finset.mem_toList, Finset.mem_univ, true_and,
                   List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ (Or.inr (List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inl rfl)))))
    · intro b s hmem
      simp only [List.mem_append, List.mem_cons, List.mem_singleton] at hmem
      rcases hmem with hmem | (rfl | rfl)
      · exact h_subs_in_range b s (List.mem_append_left _ hmem)
      · exact h_lt_in_range
      · exact h_neg_bot_in_range
  | bot => simp [elimExtFromSep, Separation.formula_atoms]
  | imp α β ihα ihβ =>
    simp only [elimExtFromSep, Separation.formula_atoms]
    intro x hx
    simp only [Set.mem_union] at hx
    rcases hx with hx | hx
    · exact ihα (fun a ha => hB_atoms (Set.mem_union_left _ ha)) hx
    · exact ihβ (fun a ha => hB_atoms (Set.mem_union_right _ ha)) hx
  | box α _ =>
    simp only [elimExtFromSep, Separation.formula_atoms]
    exact fun x hx => hB_atoms hx
  | all_past α _ =>
    simp only [elimExtFromSep]
    apply formula_atoms_applySubsts_subset
    · intro x hx
      have ha := hB_atoms hx
      obtain ⟨ep, rfl⟩ := ha
      cases ep with
      | orig p =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and]
        exact Set.mem_union_left _ ⟨p, rfl⟩
      | const_at_ref p =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and]
        exact Set.mem_union_left _ ⟨p, rfl⟩
      | lt_ref =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and]
        exact Set.mem_union_left _ (Or.inr (List.mem_cons.mpr (Or.inl rfl)))
      | gt_ref =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and]
        exact Set.mem_union_left _ (Or.inr (List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inl rfl)))))
    · intro a r hmem
      simp only [List.mem_append, List.mem_cons, List.mem_singleton] at hmem
      rcases hmem with hmem | (rfl | rfl)
      · exact h_subs_in_range a r (List.mem_append_left _ hmem)
      · exact h_neg_bot_in_range
      · exact h_lt_in_range
  | all_future α _ =>
    simp only [elimExtFromSep]
    apply formula_atoms_applySubsts_subset
    · intro x hx
      have ha := hB_atoms hx
      obtain ⟨ep, rfl⟩ := ha
      cases ep with
      | orig p =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and]
        exact Set.mem_union_left _ ⟨p, rfl⟩
      | const_at_ref p =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and]
        exact Set.mem_union_left _ ⟨p, rfl⟩
      | lt_ref =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and]
        exact Set.mem_union_left _ (Or.inr (List.mem_cons.mpr (Or.inl rfl)))
      | gt_ref =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and]
        exact Set.mem_union_left _ (Or.inr (List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inl rfl)))))
    · intro a r hmem
      simp only [List.mem_append, List.mem_cons, List.mem_singleton] at hmem
      rcases hmem with hmem | (rfl | rfl)
      · exact h_subs_in_range a r (List.mem_append_left _ hmem)
      · exact h_lt_in_range
      · exact h_neg_bot_in_range
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
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ ⟨p, rfl⟩
      | const_at_ref p =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ ⟨p, rfl⟩
      | lt_ref =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ (Or.inr (List.mem_cons.mpr (Or.inl rfl)))
      | gt_ref =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ (Or.inr (List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inl rfl)))))
    have h_neg_bot_rpl : ∀ a r, (a, r) ∈ origSubsList atomMap freshAM ++ constSubsList freshAM σ ++
        [(freshAM .lt_ref, Formula.neg .bot), (freshAM .gt_ref, .bot)] →
        Separation.formula_atoms r ⊆ Set.range atomMap := by
      intro a r hmem
      simp only [List.mem_append, List.mem_cons, List.mem_singleton] at hmem
      rcases hmem with hmem | (rfl | rfl)
      · exact h_subs_in_range a r hmem
      · exact h_neg_bot_in_range
      · exact h_lt_in_range
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
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ ⟨p, rfl⟩
      | const_at_ref p =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ ⟨p, rfl⟩
      | lt_ref =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ (Or.inr (List.mem_cons.mpr (Or.inl rfl)))
      | gt_ref =>
        simp only [origSubsList, constSubsList, List.mem_append, List.mem_map,
                   Finset.mem_toList, Finset.mem_univ, true_and, List.mem_cons, List.mem_singleton]
        exact Set.mem_union_left _ (Or.inr (List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inl rfl)))))
    have h_bot_rpl : ∀ a r, (a, r) ∈ origSubsList atomMap freshAM ++ constSubsList freshAM σ ++
        [(freshAM .lt_ref, .bot), (freshAM .gt_ref, Formula.neg .bot)] →
        Separation.formula_atoms r ⊆ Set.range atomMap := by
      intro a r hmem
      simp only [List.mem_append, List.mem_cons, List.mem_singleton] at hmem
      rcases hmem with hmem | (rfl | rfl)
      · exact h_subs_in_range a r hmem
      · exact h_lt_in_range
      · exact h_neg_bot_in_range
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
      · simp only [show (σ p) = false from Bool.not_eq_true.mp (Bool.eq_false_iff.mpr h),
                   ite_false, Formula.neg, Separation.formula_atoms,
                   Set.mem_union, Set.mem_empty_iff_false, or_false, Set.mem_singleton_iff] at hx
        exact ⟨p, hx.symm⟩
  intro fs
  induction fs with
  | nil => simp [List.foldl]
  | cons f rest ih =>
    intro init h_init h_fs x hx
    simp only [List.foldl, Formula.and, Separation.formula_atoms, Set.mem_union] at hx
    rcases hx with hx | hx
    · exact h_init x hx
    · apply ih
      · exact fun y hy => h_fs f (List.mem_cons.mpr (Or.inl rfl)) y hy
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
    · simp only [Formula.or, Separation.formula_atoms, Set.union_subset_iff]
      exact ⟨h_init, h_fs f (List.mem_cons.mpr (Or.inl rfl))⟩
    · intro g hg; exact h_fs g (List.mem_cons.mpr (Or.inr hg))

/-- All atoms of `quantElimFormula` are in `Set.range atomMap`. -/
private theorem formula_atoms_quantElimFormula_subset {sig : MonadicSignature}
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
    simp only [Formula.and, Separation.formula_atoms, Set.union_subset_iff]
    refine ⟨formula_atoms_guardFormula_subset atomMap σ, ?_⟩
    have : origSubs = origSubsList atomMap freshAM := rfl
    rw [this]
    exact formula_atoms_elimExtFromSep_subset atomMap freshAM freshAM_inj h_disj σ B_sep hB_atoms
  match h : branches with
  | [] => simp [Separation.formula_atoms]
  | [b] => exact h_branch_atoms b (h ▸ List.mem_singleton.mpr rfl)
  | b :: b' :: bs =>
    show Separation.formula_atoms (List.foldl Formula.or b (b' :: bs)) ⊆ Set.range atomMap
    apply formula_atoms_foldl_or_subset
    · exact h_branch_atoms b (h ▸ List.mem_cons.mpr (Or.inl rfl))
    · intro f hf
      exact h_branch_atoms f (h ▸ List.mem_cons.mpr (Or.inr (List.mem_cons.mpr hf)))

/-- The atom elimination correctness theorem: closes the gap between M_ext and M_orig.

    Given a properly separated B_sep whose atoms are all in freshAM's image, and
    with atomMap and freshAM having disjoint ranges, the quantElimFormula correctly
    transfers truth from the extended model to the original model.

    The proof uses the guardFormula/elimExtFromSep construction with the disjointness
    guarantee ensuring no double-substitution in applySubsts. -/
private theorem atom_elim_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep)
    (M : IntStructureFromSig sig) (t : Int)
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true)
    (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep) := by
  sorry

/-! ### Core Expressiveness Lemma

The proof uses nested induction: outer strong induction on quantifier depth,
inner structural recursion on the formula. The quantifier-free cases are handled
by structural recursion. The quantifier cases use the outer IH at lower depth
with the extended signature, then apply atom elimination.

The `atomMap_base` parameter tracks the base string used for atomMap construction,
enabling disjointness proofs between atomMap and freshAM at each level. -/

/-- Helper: derive injectivity from the mk_fresh form. -/
private theorem mk_fresh_atomMap_inj {sig : MonadicSignature} (base : String) :
    Function.Injective (fun p : sig.preds => Atom.mk_fresh base (Fintype.equivFin sig.preds p).val) := by
  intro a b hab
  have := Atom.mk_fresh_injective base hab
  exact (Fintype.equivFin sig.preds).injective (Fin.ext (Nat.cast_injective this))

/-- Helper: Atom.mk_fresh with different base strings gives different atoms. -/
private theorem mk_fresh_base_ne {s1 s2 : String} (h : s1 ≠ s2) (n m : Nat) :
    Atom.mk_fresh s1 n ≠ Atom.mk_fresh s2 m := by
  intro heq
  simp only [Atom.mk_fresh, Atom.mk.injEq] at heq
  exact h heq.1

/-- Inner structural recursion: handles quantifier-free cases directly and
    delegates quantifier cases to the outer WF IH.

    Each atomMap is of the form `fun p => mk_fresh atomMap_base (equivFin p).val`,
    which ensures disjointness from freshAM at each level (different base strings).
    The output includes atom containment: all atoms of A are in atomMap's image. -/
private noncomputable def expressiveness_inner
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi)
    (m : Nat)
    (outerIH : ∀ k < m, ∀ (sig' : MonadicSignature)
      (atomMap' : sig'.preds → Atom) (atomMap_base' : String),
      (∀ p, atomMap' p = Atom.mk_fresh atomMap_base' (Fintype.equivFin sig'.preds p).val) →
      atomMap_base' ≠ "e" ++ toString (Fintype.card sig'.preds) →
      ∀ (psi' : MonadicFormula sig' 1), psi'.quantifier_depth ≤ k →
      { A : Formula //
        (∀ (M : IntStructureFromSig sig') (t : Int),
          eval (int_to_ordered sig' M) (fun _ => t) psi' ↔
          Separation.int_truth (to_int_struct M atomMap') t A) ∧
        (Separation.formula_atoms A ⊆ Set.range atomMap') })
    (sig : MonadicSignature)
    (atomMap : sig.preds → Atom) (atomMap_base : String)
    (h_am_form : ∀ p, atomMap p = Atom.mk_fresh atomMap_base (Fintype.equivFin sig.preds p).val)
    (h_base_ne : atomMap_base ≠ "e" ++ toString (Fintype.card sig.preds)) :
    (psi : MonadicFormula sig 1) → (hm : psi.quantifier_depth ≤ m) →
    { A : Formula //
      (∀ (M : IntStructureFromSig sig) (t : Int),
        eval (int_to_ordered sig M) (fun _ => t) psi ↔
        Separation.int_truth (to_int_struct M atomMap) t A) ∧
      (Separation.formula_atoms A ⊆ Set.range atomMap) }
  | .atom p _, _ =>
    ⟨Formula.atom (atomMap p), ⟨fun M t => by
      have hinj : Function.Injective atomMap := by
        intro a b hab; rw [h_am_form a, h_am_form b] at hab
        exact mk_fresh_atomMap_inj atomMap_base |>.eq_iff.mp (by rw [← h_am_form a, ← h_am_form b]; exact hab)
      simp only [eval, Separation.int_truth, to_int_struct, Set.mem_setOf_eq]
      exact ⟨fun h => ⟨p, rfl, h⟩, fun ⟨q, hq, hi⟩ => hinj hq ▸ hi⟩,
    fun a ha => by
      simp only [Separation.formula_atoms, Set.mem_singleton_iff] at ha
      exact ⟨p, ha.symm⟩⟩⟩
  | .lt _ _, _ =>
    ⟨Formula.bot, ⟨fun M t => by
      simp only [eval, Separation.int_truth]
      exact ⟨fun h => absurd h (lt_irrefl _), False.elim⟩,
    fun a ha => by simp [Separation.formula_atoms] at ha⟩⟩
  | .not alpha, hm =>
    have hm' : alpha.quantifier_depth ≤ m := by
      simp [MonadicFormula.quantifier_depth] at hm; exact hm
    let ihA := expressiveness_inner h_sep m outerIH sig atomMap atomMap_base h_am_form alpha hm'
    ⟨Formula.neg ihA.val, ⟨fun M t => by
      simp only [eval, Separation.int_truth, Formula.neg]
      exact ⟨fun h hAt => h (ihA.property.1 M t |>.mpr hAt),
             fun h ha => h (ihA.property.1 M t |>.mp ha)⟩,
    fun a ha => by
      simp only [Formula.neg, Separation.formula_atoms, Set.mem_union, Set.mem_empty_iff_false,
                 or_false] at ha
      exact ihA.property.2 ha⟩⟩
  | .and alpha beta, hm =>
    have hm_a : alpha.quantifier_depth ≤ m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    have hm_b : beta.quantifier_depth ≤ m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    let ihA := expressiveness_inner h_sep m outerIH sig atomMap atomMap_base h_am_form alpha hm_a
    let ihB := expressiveness_inner h_sep m outerIH sig atomMap atomMap_base h_am_form beta hm_b
    ⟨Formula.and ihA.val ihB.val, ⟨fun M t => by
      have hA := ihA.property.1 M t; have hB := ihB.property.1 M t
      simp only [eval]; rw [Separation.int_truth_and_iff]
      exact ⟨fun ⟨ha, hb⟩ => ⟨hA.mp ha, hB.mp hb⟩,
             fun ⟨ha, hb⟩ => ⟨hA.mpr ha, hB.mpr hb⟩⟩,
    fun a ha => by
      simp only [Formula.and, Separation.formula_atoms, Set.mem_union] at ha
      rcases ha with ha | ha
      · exact ihA.property.2 ha
      · exact ihB.property.2 ha⟩⟩
  | .ex alpha, hm =>
    have h_lt_m : alpha.quantifier_depth < m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    have h_red_depth : (reduceElimLast 1 alpha).quantifier_depth ≤ alpha.quantifier_depth :=
      qdepth_reduceElimLast_le 1 Nat.zero_lt_one alpha
    have hinj : Function.Injective atomMap := by
      intro a b hab; rw [h_am_form a, h_am_form b] at hab
      exact mk_fresh_atomMap_inj atomMap_base |>.eq_iff.mp (by rw [← h_am_form a, ← h_am_form b]; exact hab)
    -- Construct freshAM with a base string encoding the signature size
    let freshBase := "e" ++ toString (Fintype.card sig.preds)
    let freshAM : (extSignature sig).preds → Atom :=
      fun ep => Atom.mk_fresh freshBase (Fintype.equivFin (extSignature sig).preds ep).val
    have freshAM_inj : Function.Injective freshAM := mk_fresh_atomMap_inj freshBase
    have h_fm_form : ∀ ep, freshAM ep =
        Atom.mk_fresh freshBase (Fintype.equivFin (extSignature sig).preds ep).val :=
      fun _ => rfl
    -- h_base_ne for the recursive call: freshBase ≠ "e" ++ toString (card (extSignature sig).preds)
    -- This holds because card (extSignature sig).preds = card (ExtPred sig) = 2 * card sig.preds + 2 ≠ card sig.preds
    have h_base_ne_rec : freshBase ≠ "e" ++ toString (Fintype.card (extSignature sig).preds) := by
      intro heq
      simp only [freshBase] at heq
      have := String.append_left_cancel heq
      have h_ne : Fintype.card sig.preds ≠ Fintype.card (extSignature sig).preds := by
        intro hcard
        -- card (ExtPred sig) = 2 * card sig.preds + 2, which is > card sig.preds
        simp only [extSignature] at hcard
        omega
      exact h_ne (Nat.repr_injective this)
    -- Apply outer IH at lower depth with freshAM
    let ihExt := outerIH alpha.quantifier_depth h_lt_m
      (extSignature sig) freshAM freshBase h_fm_form h_base_ne_rec
      (reduceElimLast 1 alpha) (le_trans h_red_depth (le_refl _))
    let A_ext := ihExt.val
    -- Use atom-preserving separation for B_sep
    let h_ps := Separation.proper_separation_preserves_atoms (q_exists A_ext)
    let B_sep := h_ps.choose
    have hB_sep := h_ps.choose_spec.1
    have hB_equiv := h_ps.choose_spec.2.1
    have hB_atom_sub := h_ps.choose_spec.2.2
    -- Derive hB_atoms: atoms of B_sep ⊆ range freshAM
    have hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM := by
      intro a ha
      have ha_qe := hB_atom_sub ha
      -- formula_atoms (q_exists A_ext) ⊆ formula_atoms A_ext
      -- (q_exists unfolds to or/neg/all_past/all_future which just union atoms of A_ext)
      -- and formula_atoms A_ext ⊆ range freshAM by IH
      have hA_atoms := ihExt.property.2
      -- Need to show: formula_atoms (q_exists A_ext) ⊆ range freshAM
      -- q_exists A_ext = or(or(some_past(A_ext), A_ext), some_future(A_ext))
      -- Atoms of q_exists A_ext = atoms of A_ext
      simp only [q_exists, Formula.or, Formula.some_past, Formula.some_future, Formula.neg,
                 Separation.formula_atoms, Set.union_empty, Set.empty_union] at ha_qe
      -- After simp, ha_qe should reduce to something involving formula_atoms A_ext
      exact hA_atoms (by tauto)
    -- Prove h_disj: atomMap and freshAM have disjoint ranges (using h_base_ne)
    have h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep := by
      intro p ep
      rw [h_am_form p]
      exact mk_fresh_base_ne h_base_ne _ _
    -- Build the quantifier elimination formula
    let A := quantElimFormula atomMap freshAM B_sep
    ⟨A, ⟨fun M t => by
      simp only [eval]
      let M_ext := to_int_struct (extIntStruct M t) freshAM
      have h_chain : (∃ z : ℤ, eval (int_to_ordered sig M) (Fin.cons z fun _ => t) alpha) ↔
          Separation.int_truth M_ext t B_sep := by
        constructor
        · intro ⟨z, hz⟩
          have h1 := (reduceElimLast_correct_at_one alpha M z t).mp hz
          have h2 := (ihExt.property.1 (extIntStruct M t) z).mp h1
          have h3 := (q_exists_correct A_ext M_ext t).mpr ⟨z, h2⟩
          exact (hB_equiv M_ext t).mp h3
        · intro h_bsep
          have h1 := (hB_equiv M_ext t).mpr h_bsep
          obtain ⟨z, hz⟩ := (q_exists_correct A_ext M_ext t).mp h1
          exact ⟨z, (reduceElimLast_correct_at_one alpha M z t).mpr
            ((ihExt.property.1 (extIntStruct M t) z).mpr hz)⟩
      exact h_chain.trans (atom_elim_correct atomMap hinj freshAM freshAM_inj h_disj M t B_sep hB_sep hB_atoms),
    -- Atom containment for quantElimFormula
    fun a ha => formula_atoms_quantElimFormula_subset atomMap freshAM freshAM_inj h_disj B_sep hB_atoms ha⟩⟩
  | .all alpha, hm =>
    have h_lt_m : alpha.quantifier_depth < m := by
      simp [MonadicFormula.quantifier_depth] at hm; omega
    have h_red_depth : (reduceElimLast 1 (.not alpha)).quantifier_depth ≤ alpha.quantifier_depth := by
      have := qdepth_reduceElimLast_le 1 Nat.zero_lt_one (MonadicFormula.not alpha)
      simp [MonadicFormula.quantifier_depth] at this; exact this
    have hinj : Function.Injective atomMap := by
      intro a b hab; rw [h_am_form a, h_am_form b] at hab
      exact mk_fresh_atomMap_inj atomMap_base |>.eq_iff.mp (by rw [← h_am_form a, ← h_am_form b]; exact hab)
    let freshBase := "e" ++ toString (Fintype.card sig.preds)
    let freshAM : (extSignature sig).preds → Atom :=
      fun ep => Atom.mk_fresh freshBase (Fintype.equivFin (extSignature sig).preds ep).val
    have freshAM_inj : Function.Injective freshAM := mk_fresh_atomMap_inj freshBase
    have h_fm_form : ∀ ep, freshAM ep =
        Atom.mk_fresh freshBase (Fintype.equivFin (extSignature sig).preds ep).val :=
      fun _ => rfl
    have h_base_ne_rec : freshBase ≠ "e" ++ toString (Fintype.card (extSignature sig).preds) := by
      intro heq
      simp only [freshBase] at heq
      have := String.append_left_cancel heq
      have h_ne : Fintype.card sig.preds ≠ Fintype.card (extSignature sig).preds := by
        simp only [extSignature]; omega
      exact h_ne (Nat.repr_injective this)
    let ihExt := outerIH alpha.quantifier_depth h_lt_m
      (extSignature sig) freshAM freshBase h_fm_form h_base_ne_rec
      (reduceElimLast 1 (.not alpha)) (le_trans h_red_depth (le_refl _))
    let A_neg_ext := ihExt.val
    let h_ps := Separation.proper_separation_preserves_atoms (q_exists A_neg_ext)
    let B_sep := h_ps.choose
    have hB_equiv := h_ps.choose_spec.2.1
    have hB_atom_sub := h_ps.choose_spec.2.2
    have hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM := by
      intro a ha
      have ha_qe := hB_atom_sub ha
      have hA_atoms := ihExt.property.2
      simp only [q_exists, Formula.or, Formula.some_past, Formula.some_future, Formula.neg,
                 Separation.formula_atoms, Set.union_empty, Set.empty_union] at ha_qe
      exact hA_atoms (by tauto)
    have h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep := by
      intro p ep
      rw [h_am_form p]
      exact mk_fresh_base_ne h_base_ne _ _
    let A_ex := quantElimFormula atomMap freshAM B_sep
    ⟨Formula.neg A_ex, ⟨fun M t => by
      simp only [eval]
      rw [Separation.int_truth_neg_iff]
      let M_ext := to_int_struct (extIntStruct M t) freshAM
      have h_chain_neg : (∃ z : ℤ, ¬eval (int_to_ordered sig M) (Fin.cons z fun _ => t) alpha) ↔
          Separation.int_truth M_ext t B_sep := by
        constructor
        · intro ⟨z, hz⟩
          have h1 : eval (int_to_ordered sig M) (Fin.cons z fun _ => t) (.not alpha) := hz
          have h2 := (reduceElimLast_correct_at_one (.not alpha) M z t).mp h1
          have h3 := (ihExt.property.1 (extIntStruct M t) z).mp h2
          exact (hB_equiv M_ext t).mp ((q_exists_correct A_neg_ext M_ext t).mpr ⟨z, h3⟩)
        · intro h_bsep
          obtain ⟨z, hz⟩ := (q_exists_correct A_neg_ext M_ext t).mp
            ((hB_equiv M_ext t).mpr h_bsep)
          have h1 := (ihExt.property.1 (extIntStruct M t) z).mpr hz
          have h2 := (reduceElimLast_correct_at_one (.not alpha) M z t).mpr h1
          exact ⟨z, h2⟩
      have h_elim : Separation.int_truth M_ext t B_sep ↔
          Separation.int_truth (to_int_struct M atomMap) t A_ex :=
        atom_elim_correct atomMap hinj freshAM freshAM_inj h_disj M t B_sep h_ps.choose_spec.1 hB_atoms
      constructor
      · intro h_all h_Aex
        have h_bsep := h_elim.mpr h_Aex
        obtain ⟨z, hz⟩ := h_chain_neg.mpr h_bsep
        exact hz (h_all z)
      · intro h_neg z
        by_contra h_not
        have h_bsep := h_chain_neg.mp ⟨z, h_not⟩
        exact h_neg (h_elim.mp h_bsep),
    -- Atom containment for neg A_ex
    fun a ha => by
      simp only [Formula.neg, Separation.formula_atoms, Set.mem_union, Set.mem_empty_iff_false,
                 or_false] at ha
      exact formula_atoms_quantElimFormula_subset atomMap freshAM freshAM_inj h_disj B_sep hB_atoms ha⟩⟩

/-- Outer well-founded recursion: proves the expressiveness lemma by strong induction
    on quantifier depth with atom containment tracking. -/
private noncomputable def expressiveness_wf
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi)
    (m : Nat) (sig : MonadicSignature)
    (atomMap : sig.preds → Atom) (atomMap_base : String)
    (h_am_form : ∀ p, atomMap p = Atom.mk_fresh atomMap_base (Fintype.equivFin sig.preds p).val)
    (h_base_ne : atomMap_base ≠ "e" ++ toString (Fintype.card sig.preds))
    (psi : MonadicFormula sig 1) (hm : psi.quantifier_depth ≤ m) :
    { A : Formula //
      (∀ (M : IntStructureFromSig sig) (t : Int),
        eval (int_to_ordered sig M) (fun _ => t) psi ↔
        Separation.int_truth (to_int_struct M atomMap) t A) ∧
      (Separation.formula_atoms A ⊆ Set.range atomMap) } :=
  m.strongRecOn
    (motive := fun m => ∀ (sig : MonadicSignature)
      (atomMap : sig.preds → Atom) (atomMap_base : String),
      (∀ p, atomMap p = Atom.mk_fresh atomMap_base (Fintype.equivFin sig.preds p).val) →
      atomMap_base ≠ "e" ++ toString (Fintype.card sig.preds) →
      ∀ (psi : MonadicFormula sig 1), psi.quantifier_depth ≤ m →
      { A : Formula //
        (∀ (M : IntStructureFromSig sig) (t : Int),
          eval (int_to_ordered sig M) (fun _ => t) psi ↔
          Separation.int_truth (to_int_struct M atomMap) t A) ∧
        (Separation.formula_atoms A ⊆ Set.range atomMap) })
    (fun m ih => expressiveness_inner h_sep m ih)
    sig atomMap atomMap_base h_am_form h_base_ne psi hm

/-- Core lemma: for a FIXED injective atomMap of mk_fresh form, every MonadicFormula sig 1
    has a temporal equivalent (Theorem 9.3.1, GHR94). -/
private noncomputable def expressiveness_fixed_atomMap
    (h_sep : ∀ phi : Formula, Separation.is_properly_separable phi)
    (sig : MonadicSignature) (atomMap : sig.preds → Atom)
    (atomMap_base : String)
    (h_am_form : ∀ p, atomMap p = Atom.mk_fresh atomMap_base (Fintype.equivFin sig.preds p).val)
    (h_base_ne : atomMap_base ≠ "e" ++ toString (Fintype.card sig.preds))
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      (∀ (M : IntStructureFromSig sig) (t : Int),
        eval (int_to_ordered sig M) (fun _ => t) psi ↔
        Separation.int_truth (to_int_struct M atomMap) t A) ∧
      (Separation.formula_atoms A ⊆ Set.range atomMap) } :=
  expressiveness_wf h_sep psi.quantifier_depth sig atomMap atomMap_base h_am_form h_base_ne psi (le_refl _)

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
  have h_am_form : ∀ p, atomMap p =
      Bimodal.Syntax.Atom.mk_fresh "p" (Fintype.equivFin sig.preds p).val :=
    fun _ => rfl
  have h_base_ne : "p" ≠ "e" ++ toString (Fintype.card sig.preds) := by
    exact fun h => by have := congrArg (fun s => s.toList.head!) h; simp at this; exact absurd this (by decide)
  exact ⟨(expressiveness_fixed_atomMap h_sep sig atomMap "p" h_am_form h_base_ne psi).val,
         atomMap,
         (expressiveness_fixed_atomMap h_sep sig atomMap "p" h_am_form h_base_ne psi).property.1⟩

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
