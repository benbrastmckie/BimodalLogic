import Bimodal.Metalogic.Bundle.BidirectionalReachable
import Mathlib.Order.Antisymmetrization
import Mathlib.Data.Countable.Defs

/-!
# Restricted Countable Fragment

This module defines a countable sub-fragment of the BidirectionalFragment by restricting
reachability to specific canonical Lindenbaum witnesses. While BidirectionalQuotient is
uncountable (research-018), this restricted fragment is countable because each step is
indexed by a formula from the countable type `Formula`.

## Strategy

`canonical_forward_F` and `canonical_backward_P` produce existential witnesses.
Using `Classical.choose`, we extract deterministic witness functions. Each witness
step is indexed by `Formula` (countable), so finite paths from the root form a
countable set, giving countability of the fragment.

## References

- Task 956 plan v5: K-Relational pipeline
- Research-018: BidirectionalQuotient uncountability
- Research-023: Complete K-Relational pipeline
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/-!
## Deterministic Canonical Witnesses

Extract deterministic witness functions from the existential results of
`canonical_forward_F` and `canonical_backward_P`.
-/

/--
The canonical forward witness world: given MCS `M` with `F(φ) ∈ M`,
the specific MCS chosen by `Classical.choose`.
-/
noncomputable def canonicalFWorld (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) : Set Formula :=
  (canonical_forward_F M h_mcs φ h_F).choose

theorem canonicalFWorld_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) :
    SetMaximalConsistent (canonicalFWorld M h_mcs φ h_F) :=
  (canonical_forward_F M h_mcs φ h_F).choose_spec.1

theorem canonicalFWorld_R (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) :
    CanonicalR M (canonicalFWorld M h_mcs φ h_F) :=
  (canonical_forward_F M h_mcs φ h_F).choose_spec.2.1

theorem canonicalFWorld_mem (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_F : Formula.some_future φ ∈ M) :
    φ ∈ canonicalFWorld M h_mcs φ h_F :=
  (canonical_forward_F M h_mcs φ h_F).choose_spec.2.2

/--
The canonical backward witness world: given MCS `M` with `P(φ) ∈ M`,
the specific MCS chosen by `Classical.choose`.
-/
noncomputable def canonicalPWorld (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_P : Formula.some_past φ ∈ M) : Set Formula :=
  (canonical_backward_P M h_mcs φ h_P).choose

theorem canonicalPWorld_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_P : Formula.some_past φ ∈ M) :
    SetMaximalConsistent (canonicalPWorld M h_mcs φ h_P) :=
  (canonical_backward_P M h_mcs φ h_P).choose_spec.1

theorem canonicalPWorld_Rpast (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_P : Formula.some_past φ ∈ M) :
    CanonicalR_past M (canonicalPWorld M h_mcs φ h_P) :=
  (canonical_backward_P M h_mcs φ h_P).choose_spec.2.1

theorem canonicalPWorld_mem (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_P : Formula.some_past φ ∈ M) :
    φ ∈ canonicalPWorld M h_mcs φ h_P :=
  (canonical_backward_P M h_mcs φ h_P).choose_spec.2.2

/-!
## Witness Reachability

Each step uses the SPECIFIC canonical witness from `canonicalFWorld` or `canonicalPWorld`.
The resulting MCS at each step is definitionally determined by the input MCS and formula.
-/

/--
`WitnessReachable M₀ h₀ M h` holds when `M` can be reached from `M₀` by a finite
sequence of canonical witness steps. Each forward step with formula `φ` produces
`canonicalFWorld M h φ h_F`, and each backward step produces `canonicalPWorld M h φ h_P`.
-/
inductive WitnessReachable (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) :
    (M : Set Formula) → SetMaximalConsistent M → Prop where
  | refl : WitnessReachable M₀ h₀ M₀ h₀
  | forward_step {M₁ : Set Formula} {h₁ : SetMaximalConsistent M₁}
      (h_reach : WitnessReachable M₀ h₀ M₁ h₁)
      (φ : Formula) (h_F : Formula.some_future φ ∈ M₁) :
      WitnessReachable M₀ h₀
        (canonicalFWorld M₁ h₁ φ h_F)
        (canonicalFWorld_mcs M₁ h₁ φ h_F)
  | backward_step {M₁ : Set Formula} {h₁ : SetMaximalConsistent M₁}
      (h_reach : WitnessReachable M₀ h₀ M₁ h₁)
      (φ : Formula) (h_P : Formula.some_past φ ∈ M₁) :
      WitnessReachable M₀ h₀
        (canonicalPWorld M₁ h₁ φ h_P)
        (canonicalPWorld_mcs M₁ h₁ φ h_P)

/--
Every WitnessReachable MCS is BidirectionalReachable.
-/
theorem WitnessReachable.toBidirectionalReachable
    {M : Set Formula} {h_mcs : SetMaximalConsistent M}
    (h : WitnessReachable M₀ h_mcs₀ M h_mcs) :
    BidirectionalReachable M₀ h_mcs₀ M h_mcs := by
  induction h with
  | refl => exact BidirectionalReachable.refl
  | forward_step _ φ h_F ih =>
    exact ih.step_forward (canonicalFWorld_R _ _ φ h_F)
  | @backward_step M₁ h₁ _ φ h_P ih =>
    have h_Rpast := canonicalPWorld_Rpast M₁ h₁ φ h_P
    exact ih.step_backward
      (HContent_subset_implies_GContent_reverse M₁ _ h₁ (canonicalPWorld_mcs M₁ h₁ φ h_P) h_Rpast)

/-!
## The Restricted Fragment Type
-/

/--
A restricted fragment element: an MCS reachable from root via specific canonical witnesses.
-/
structure RestrictedFragment (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
  reachable : WitnessReachable M₀ h_mcs₀ world is_mcs

theorem RestrictedFragment.ext {a b : RestrictedFragment M₀ h_mcs₀}
    (h : a.world = b.world) : a = b := by
  cases a; cases b; simp only [mk.injEq] at *; exact h

def RestrictedFragment.root : RestrictedFragment M₀ h_mcs₀ where
  world := M₀
  is_mcs := h_mcs₀
  reachable := WitnessReachable.refl

instance : Nonempty (RestrictedFragment M₀ h_mcs₀) := ⟨RestrictedFragment.root⟩

def RestrictedFragment.toBidirectionalFragment (a : RestrictedFragment M₀ h_mcs₀) :
    BidirectionalFragment M₀ h_mcs₀ where
  world := a.world
  is_mcs := a.is_mcs
  reachable := a.reachable.toBidirectionalReachable

/-!
## Fragment Closure Properties
-/

theorem forward_F_stays_in_restricted_fragment
    (a : RestrictedFragment M₀ h_mcs₀)
    (φ : Formula) (h_F : Formula.some_future φ ∈ a.world) :
    ∃ (s : RestrictedFragment M₀ h_mcs₀),
      CanonicalR a.world s.world ∧ φ ∈ s.world :=
  ⟨⟨canonicalFWorld a.world a.is_mcs φ h_F,
    canonicalFWorld_mcs a.world a.is_mcs φ h_F,
    WitnessReachable.forward_step a.reachable φ h_F⟩,
   canonicalFWorld_R a.world a.is_mcs φ h_F,
   canonicalFWorld_mem a.world a.is_mcs φ h_F⟩

theorem backward_P_stays_in_restricted_fragment
    (a : RestrictedFragment M₀ h_mcs₀)
    (φ : Formula) (h_P : Formula.some_past φ ∈ a.world) :
    ∃ (s : RestrictedFragment M₀ h_mcs₀),
      CanonicalR_past a.world s.world ∧ φ ∈ s.world :=
  ⟨⟨canonicalPWorld a.world a.is_mcs φ h_P,
    canonicalPWorld_mcs a.world a.is_mcs φ h_P,
    WitnessReachable.backward_step a.reachable φ h_P⟩,
   canonicalPWorld_Rpast a.world a.is_mcs φ h_P,
   canonicalPWorld_mem a.world a.is_mcs φ h_P⟩

/-!
## Preorder and Totality
-/

noncomputable instance : Preorder (RestrictedFragment M₀ h_mcs₀) where
  le a b := a = b ∨ CanonicalR a.world b.world
  le_refl a := Or.inl rfl
  le_trans a b c hab hbc := by
    rcases hab with rfl | hab
    · exact hbc
    · rcases hbc with rfl | hbc
      · exact Or.inr hab
      · exact Or.inr (canonicalR_transitive a.world b.world c.world a.is_mcs hab hbc)

theorem RestrictedFragment.le_of_canonicalR
    (a b : RestrictedFragment M₀ h_mcs₀)
    (h : CanonicalR a.world b.world) : a ≤ b :=
  Or.inr h

theorem RestrictedFragment.canonicalR_of_lt
    (a b : RestrictedFragment M₀ h_mcs₀) (h : a < b) :
    CanonicalR a.world b.world := by
  rcases h.1 with rfl | h_R
  · exact absurd (Or.inl rfl : a ≤ a) h.2
  · exact h_R

theorem restricted_totally_ordered
    (a b : RestrictedFragment M₀ h_mcs₀) :
    CanonicalR a.world b.world ∨ CanonicalR b.world a.world ∨ a.world = b.world :=
  bidirectional_totally_ordered a.toBidirectionalFragment b.toBidirectionalFragment

theorem restricted_le_total
    (a b : RestrictedFragment M₀ h_mcs₀) : a ≤ b ∨ b ≤ a := by
  rcases restricted_totally_ordered a b with h | h | h
  · exact Or.inl (RestrictedFragment.le_of_canonicalR a b h)
  · exact Or.inr (RestrictedFragment.le_of_canonicalR b a h)
  · exact Or.inl (RestrictedFragment.ext h ▸ le_refl a)

noncomputable instance : IsTotal (RestrictedFragment M₀ h_mcs₀) (· ≤ ·) where
  total := restricted_le_total

/-!
## RestrictedQuotient with LinearOrder
-/

abbrev RestrictedQuotient (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :=
  Antisymmetrization (RestrictedFragment M₀ h_mcs₀) (· ≤ ·)

noncomputable instance instLinearOrderRestrictedQuotient :
    LinearOrder (RestrictedQuotient M₀ h_mcs₀) where
  le_total := by
    intro a b
    induction a using Quotient.ind with
    | _ a =>
      induction b using Quotient.ind with
      | _ b => exact restricted_le_total a b
  toDecidableLE := Classical.decRel _

def RestrictedFragment.toQuotient (a : RestrictedFragment M₀ h_mcs₀) :
    RestrictedQuotient M₀ h_mcs₀ :=
  toAntisymmetrization (· ≤ ·) a

/-!
## Countability

Every restricted fragment element is reachable by a finite path of canonical witness
steps from the root. Each step is indexed by `(Bool × Formula)` where Bool encodes
direction (forward/backward) and Formula is the justifying formula. Since
`List (Bool × Formula)` is countable, and path execution is a surjection onto the
restricted fragment, the fragment is countable.
-/

attribute [local instance] Classical.propDecidable

/--
A bundled MCS: world + proof of MCS.
-/
structure MCSBundle where
  world : Set Formula
  is_mcs : SetMaximalConsistent world

/--
Execute a single path step from an MCS.
-/
noncomputable def stepExecute (dir : Bool) (φ : Formula) (m : MCSBundle) : MCSBundle :=
  match dir with
  | true =>
    if h_F : Formula.some_future φ ∈ m.world then
      ⟨canonicalFWorld m.world m.is_mcs φ h_F, canonicalFWorld_mcs m.world m.is_mcs φ h_F⟩
    else
      m
  | false =>
    if h_P : Formula.some_past φ ∈ m.world then
      ⟨canonicalPWorld m.world m.is_mcs φ h_P, canonicalPWorld_mcs m.world m.is_mcs φ h_P⟩
    else
      m

/--
Execute a path of (direction, formula) steps from a given MCS.
Invalid steps are skipped.
-/
noncomputable def pathExecute : List (Bool × Formula) → MCSBundle → MCSBundle
  | [], m => m
  | (dir, φ) :: rest, m => pathExecute rest (stepExecute dir φ m)

/--
Path execution preserves WitnessReachability.
-/
private theorem stepExecute_reachable (dir : Bool) (φ : Formula) (m : MCSBundle)
    (h_reach : WitnessReachable M₀ h_mcs₀ m.world m.is_mcs) :
    WitnessReachable M₀ h_mcs₀
      (stepExecute dir φ m).world
      (stepExecute dir φ m).is_mcs := by
  cases dir with
  | true =>
    simp only [stepExecute]
    split
    · exact WitnessReachable.forward_step h_reach φ ‹_›
    · exact h_reach
  | false =>
    simp only [stepExecute]
    split
    · exact WitnessReachable.backward_step h_reach φ ‹_›
    · exact h_reach

theorem pathExecute_reachable (path : List (Bool × Formula)) (m : MCSBundle)
    (h_reach : WitnessReachable M₀ h_mcs₀ m.world m.is_mcs) :
    WitnessReachable M₀ h_mcs₀
      (pathExecute path m).world
      (pathExecute path m).is_mcs := by
  induction path generalizing m with
  | nil => exact h_reach
  | cons step rest ih =>
    obtain ⟨dir, φ⟩ := step
    simp only [pathExecute]
    exact ih _ (stepExecute_reachable dir φ m h_reach)

/--
Every restricted fragment element has a path from root that reaches it.
-/
-- Helper: pathExecute distributes over append
theorem pathExecute_append (p1 p2 : List (Bool × Formula)) (m : MCSBundle) :
    pathExecute (p1 ++ p2) m = pathExecute p2 (pathExecute p1 m) := by
  induction p1 generalizing m with
  | nil => simp [pathExecute]
  | cons step rest ih =>
    obtain ⟨dir, φ⟩ := step
    simp only [List.cons_append, pathExecute]
    exact ih _

/--
Root MCS as a bundle.
-/
def rootBundle (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) : MCSBundle where
  world := M₀
  is_mcs := h_mcs₀

theorem restricted_surjection (a : RestrictedFragment M₀ h_mcs₀) :
    ∃ (path : List (Bool × Formula)),
      (pathExecute path (rootBundle M₀ h_mcs₀)).world = a.world := by
  obtain ⟨world, is_mcs, reachable⟩ := a
  induction reachable with
  | refl => exact ⟨[], rfl⟩
  | @forward_step M₁ h₁ _ φ h_F ih =>
    obtain ⟨path, h_eq⟩ := ih
    refine ⟨path ++ [(true, φ)], ?_⟩
    rw [pathExecute_append]
    -- m = pathExecute path (rootBundle M₀ h_mcs₀), m.world = M₁
    -- Need: (pathExecute [(true, φ)] m).world = canonicalFWorld M₁ h₁ φ h_F
    -- Rewrite M₁ in terms of m.world using h_eq
    have h_eq' : M₁ = (pathExecute path (rootBundle M₀ h_mcs₀)).world := h_eq.symm
    subst h_eq'
    -- Now h₁ and the m's is_mcs are both proofs of the same prop, so they're equal
    simp only [pathExecute, stepExecute]
    rw [dif_pos h_F]
  | @backward_step M₁ h₁ _ φ h_P ih =>
    obtain ⟨path, h_eq⟩ := ih
    refine ⟨path ++ [(false, φ)], ?_⟩
    rw [pathExecute_append]
    have h_eq' : M₁ = (pathExecute path (rootBundle M₀ h_mcs₀)).world := h_eq.symm
    subst h_eq'
    simp only [pathExecute, stepExecute]
    rw [dif_pos h_P]

/--
Map a path to a restricted fragment element.
-/
noncomputable def pathToFragment (path : List (Bool × Formula)) :
    RestrictedFragment M₀ h_mcs₀ :=
  let result := pathExecute path (rootBundle M₀ h_mcs₀)
  ⟨result.world, result.is_mcs,
   pathExecute_reachable path (rootBundle M₀ h_mcs₀) WitnessReachable.refl⟩

/--
The restricted fragment is countable.
-/
noncomputable instance instCountableRestrictedFragment :
    Countable (RestrictedFragment M₀ h_mcs₀) := by
  apply Function.Surjective.countable (f := pathToFragment (M₀ := M₀) (h_mcs₀ := h_mcs₀))
  intro a
  obtain ⟨path, h_eq⟩ := restricted_surjection a
  exact ⟨path, RestrictedFragment.ext (by simp only [pathToFragment]; exact h_eq)⟩

noncomputable instance instCountableRestrictedQuotient :
    Countable (RestrictedQuotient M₀ h_mcs₀) :=
  Quotient.countable

instance instNonemptyRestrictedQuotient :
    Nonempty (RestrictedQuotient M₀ h_mcs₀) :=
  ⟨RestrictedFragment.root.toQuotient⟩

/-!
## No Endpoints: NoMaxOrder and NoMinOrder

Every MCS has `F(¬⊥) ∈ M` (from `mcs_has_F_top`) and `P(¬⊥) ∈ M` (from `mcs_has_P_top`).
This gives strict successors and predecessors via canonical witnesses.
-/

/--
Helper: If `CanonicalR a.world s.world` and `GContent(a) ⊄ a.world`,
then `s` is strictly greater than `a` in the preorder (not just `≤`).

When `GContent(a) ⊄ a.world`, there exists `ψ` with `G(ψ) ∈ a.world` and `ψ ∉ a.world`.
By temp_4, `G(G(ψ)) ∈ a.world`, so `G(ψ) ∈ s.world` (via CanonicalR).
If `CanonicalR s a`, then `ψ ∈ a.world` (from `G(ψ) ∈ GContent(s) ⊆ a`), contradiction.
If `s = a`, then `CanonicalR a a` means `GContent(a) ⊆ a`, contradicting hypothesis.
-/
private theorem no_max_helper_irrefl
    (a s : RestrictedFragment M₀ h_mcs₀)
    (h_R : CanonicalR a.world s.world)
    (h_not_refl : ¬(GContent a.world ⊆ a.world))
    : ¬(s ≤ a) := by
  have h_exists := Set.not_subset.mp h_not_refl
  obtain ⟨ψ, h_Gψ_a, h_ψ_not_a⟩ := h_exists
  have h_T4 : [] ⊢ (Formula.all_future ψ).imp (Formula.all_future (Formula.all_future ψ)) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 ψ)
  have h_GGψ_a : Formula.all_future (Formula.all_future ψ) ∈ a.world :=
    set_mcs_implication_property a.is_mcs (theorem_in_mcs a.is_mcs h_T4) h_Gψ_a
  have h_Gψ_s : Formula.all_future ψ ∈ s.world := h_R h_GGψ_a
  intro h_le
  rcases h_le with rfl | h_R_sa
  · exact h_not_refl h_R
  · exact h_ψ_not_a (h_R_sa h_Gψ_s)

/--
NoMaxOrder on RestrictedQuotient: every element has a strict successor.

**Status**: BLOCKED. The irreflexive case (GContent(a) ⊄ a) is proven via
`no_max_helper_irrefl`. The reflexive case (GContent(a) ⊆ a) is an open problem:
when an MCS is G-closed, its canonical F-witnesses may return the same MCS,
producing a singleton quotient where NoMaxOrder fails.

**Analysis**: An MCS with `GContent(M) = M` (phi ∈ M ↔ G(phi) ∈ M) is
syntactically consistent with all axioms (seriality, density, linearity, etc.)
but semantically unsatisfiable in irreflexive frames (vacuous truth of G at
a maximum point conflicts with seriality F(neg bot)). The canonical model
construction needs a BULLDOZING step or step-by-step construction to eliminate
such reflexive points and guarantee strict successors.
-/
noncomputable instance instNoMaxOrderRestrictedQuotient :
    NoMaxOrder (RestrictedQuotient M₀ h_mcs₀) where
  exists_gt := by
    intro q
    induction q using Quotient.ind with
    | _ a =>
      -- seriality_future axiom gives F(¬⊥) ∈ a.world
      have h_F : Formula.some_future (Formula.neg Formula.bot) ∈ a.world :=
        theorem_in_mcs a.is_mcs (DerivationTree.axiom [] _ Axiom.seriality_future)
      obtain ⟨s, h_R_as, _⟩ := forward_F_stays_in_restricted_fragment a _ h_F
      by_cases h_refl : GContent a.world ⊆ a.world
      · -- BLOCKED: reflexive case (GContent(a) ⊆ a)
        -- When GContent(a) ⊆ a, the F-witness may be equivalent to a in the quotient.
        -- Needs bulldozing construction (v007 product domain) to resolve.
        sorry
      · exact ⟨s.toQuotient,
          (toAntisymmetrization_lt_toAntisymmetrization_iff).mpr
            ⟨Or.inr h_R_as, no_max_helper_irrefl a s h_R_as h_refl⟩⟩

/--
Past-direction helper: If `CanonicalR_past a.world s.world` and `HContent(a) ⊄ a.world`,
then `a` is strictly greater than `s` in the preorder.

When `HContent(a) ⊄ a.world`, there exists `ψ` with `H(ψ) ∈ a.world` and `ψ ∉ a.world`.
By temp_4_past, `H(H(ψ)) ∈ a.world`, so `H(ψ) ∈ HContent(a) ⊆ s.world`.
By duality (CanonicalR_past a s implies CanonicalR via HContent_subset_implies_GContent_reverse):
`GContent(s) ⊆ a`. So `s ≤ a`.
If `a = s`: `CanonicalR_past a a` means `HContent(a) ⊆ a`, contradicting hypothesis.
If `CanonicalR a s` (GContent(a) ⊆ s): by GContent_subset_implies_HContent_reverse,
`HContent(s) ⊆ a`. H(ψ) ∈ s gives `ψ ∈ HContent(s) ⊆ a`, contradicting `ψ ∉ a`.
-/
private theorem no_min_helper_irrefl
    (a s : RestrictedFragment M₀ h_mcs₀)
    (h_Rpast : CanonicalR_past a.world s.world)
    (h_not_refl : ¬(HContent a.world ⊆ a.world))
    : s ≤ a ∧ ¬(a ≤ s) := by
  have h_exists := Set.not_subset.mp h_not_refl
  obtain ⟨ψ, h_Hψ_a, h_ψ_not_a⟩ := h_exists
  -- H(ψ) ∈ a means ψ ∈ HContent(a) means H(ψ) ∈ a.world
  -- By temp_4_past: H(H(ψ)) ∈ a, so H(ψ) ∈ HContent(a) ⊆ s
  have h_HHψ_a : (Formula.all_past ψ).all_past ∈ a.world :=
    set_mcs_all_past_all_past a.is_mcs h_Hψ_a
  have h_Hψ_s : Formula.all_past ψ ∈ s.world := h_Rpast h_HHψ_a
  -- By duality: CanonicalR_past a s gives CanonicalR s a (GContent(s) ⊆ a)
  have h_R_sa : CanonicalR s.world a.world :=
    HContent_subset_implies_GContent_reverse a.world s.world a.is_mcs s.is_mcs h_Rpast
  constructor
  · -- s ≤ a
    exact Or.inr h_R_sa
  · -- ¬(a ≤ s)
    intro h_le
    rcases h_le with rfl | h_R_as
    · -- a = s: HContent(a) ⊆ a contradicts h_not_refl
      exact h_not_refl h_Rpast
    · -- CanonicalR a s (GContent(a) ⊆ s):
      -- By GContent_subset_implies_HContent_reverse: HContent(s) ⊆ a
      have h_Hcont_s_sub_a : HContent s.world ⊆ a.world :=
        GContent_subset_implies_HContent_reverse a.world s.world a.is_mcs s.is_mcs h_R_as
      -- H(ψ) ∈ s gives ψ ∈ HContent(s) ⊆ a
      exact h_ψ_not_a (h_Hcont_s_sub_a h_Hψ_s)

/--
NoMinOrder on RestrictedQuotient: every element has a strict predecessor.
Symmetric to NoMaxOrder. Same blocker applies for H-closed MCSes.
-/
noncomputable instance instNoMinOrderRestrictedQuotient :
    NoMinOrder (RestrictedQuotient M₀ h_mcs₀) where
  exists_lt := by
    intro q
    induction q using Quotient.ind with
    | _ a =>
      -- seriality_past axiom gives P(¬⊥) ∈ a.world
      have h_P : Formula.some_past (Formula.neg Formula.bot) ∈ a.world :=
        theorem_in_mcs a.is_mcs (DerivationTree.axiom [] _ Axiom.seriality_past)
      obtain ⟨s, h_Rpast_as, _⟩ := backward_P_stays_in_restricted_fragment a _ h_P
      by_cases h_refl : HContent a.world ⊆ a.world
      · -- BLOCKED: reflexive case (HContent(a) ⊆ a)
        -- Needs bulldozing construction (v007 product domain) to resolve.
        sorry
      · -- Irreflexive case: predecessor s is strictly less
        obtain ⟨h_le, h_not_le⟩ := no_min_helper_irrefl a s h_Rpast_as h_refl
        exact ⟨s.toQuotient,
          (toAntisymmetrization_lt_toAntisymmetrization_iff).mpr ⟨h_le, h_not_le⟩⟩

end Bimodal.Metalogic.Bundle
