import Bimodal.Metalogic.WeakCanonical.StaviConnectives
import Bimodal.Metalogic.WeakCanonical.NormalForm

/-!
# Ehrenfeucht-Fraisse Games for Expressive Completeness (GHR93)

Custom EF game infrastructure for the GHR93 proof that {U,S,U',S'} is
expressively complete for ALL linear temporal structures (Theorem 9.3.1).

## Overview

GHR93 Section 8 defines a custom variant G_{n;r} of Ehrenfeucht-Fraisse
games played on linear temporal structures. These games have a two-round
structure: first n elements are selected by the standard EF protocol,
then one additional element is selected. The depth function f(n) governs
the quantifier depth of formulas that can be distinguished by n-round
games.

## Key Definitions

- `EFGame`: The custom G_{n;r} game type
- `EFWinning`: Winning condition for Duplicator
- `game_depth`: The depth function f(n) with bounds f(n+1) > (1+3f(n))*(2k_n)+1
- `left_formula` / `right_formula`: Gap detection formulas

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Section 8
- Task 155 plan: Phase 4 (Sub-stage 4B)
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax

/-! ## General Temporal Truth on OrderedMonadicStructure

To state expressive completeness for general linear orders (not just Z),
we need a version of temporal truth that works uniformly on any
OrderedMonadicStructure. This is exactly `temporal_truth` from Table.lean,
which already operates on arbitrary `OrderedMonadicStructure sig`.

The key difference from ExpressiveCompleteness.lean (which uses
`IntStructureFromSig` with carrier = Z) is that here the carrier
can be any linearly ordered type. -/

/-! ## Expressive Completeness Statement

The main theorem we want to prove: for any monadic signature sig,
any monadic sentence phi of quantifier depth ≤ k, and any linear
temporal structure M with atom map, there exists a temporal formula A
(using U, S, U', S') such that:

  stavi_temporal_truth M atomMap t A ↔ eval M (fun _ => t) phi

for all t in M.carrier.

This is GHR93 Theorem 9.3.1 (Theorem 4 in Reynolds).
-/

/-! ## Game Configuration

A game configuration records the current state of play: which elements
have been selected in each structure and the correspondence between them. -/

/--
A game position in the EF game between two ordered monadic structures.
Tracks the selected elements from each structure and their correspondence.
-/
structure EFPosition (sig : MonadicSignature) where
  /-- First structure -/
  M : OrderedMonadicStructure sig
  /-- Second structure -/
  N : OrderedMonadicStructure sig
  /-- Number of elements selected so far -/
  round : Nat
  /-- Selected elements from M -/
  selected_M : Fin round → M.carrier
  /-- Selected elements from N -/
  selected_N : Fin round → N.carrier

/--
Duplicator wins a position if:
1. Predicate agreement: for all predicates p and positions i,
   M.interp p (selected_M i) ↔ N.interp p (selected_N i)
2. Order agreement: for all positions i, j,
   selected_M i < selected_M j ↔ selected_N i < selected_N j
-/
def ef_duplicator_wins {sig : MonadicSignature} (pos : EFPosition sig) : Prop :=
  (∀ (p : sig.preds) (i : Fin pos.round),
    pos.M.interp p (pos.selected_M i) ↔ pos.N.interp p (pos.selected_N i)) ∧
  (∀ (i j : Fin pos.round),
    pos.selected_M i < pos.selected_M j ↔ pos.selected_N i < pos.selected_N j)

/-! ## Depth Function

The depth function f(n) from GHR93 Section 8. It governs the quantifier
depth of formulas distinguishable by n-round games. The key recurrence:

  f(0) = some base value
  f(n+1) > (1 + 3*f(n)) * (2*k_n) + 1

where k_n is the number of depth-f(n) normal forms.
-/

/--
The game depth function. For a given signature, computes the quantifier
depth needed for n rounds of the EF game.
-/
noncomputable def game_depth (sig : MonadicSignature) : Nat → Nat
  | 0 => 0
  | n + 1 =>
    let prev := game_depth sig n
    let k_n := Fintype.card (NormalForm sig prev 1)
    (1 + 3 * prev) * (2 * k_n) + 2

/--
game_depth at n+1 is at least 2 (useful lower bound).
-/
theorem game_depth_succ_ge_two (sig : MonadicSignature) (n : Nat) :
    2 ≤ game_depth sig (n + 1) := by
  simp only [game_depth]; omega

/-- NormalForm is nonempty for any signature, depth, and variable count. -/
private theorem normalForm_nonempty (sig : MonadicSignature) (k n : Nat) :
    Nonempty (NormalForm sig k n) := by
  induction k generalizing n with
  | zero =>
    -- NormalForm sig 0 n = AtomKind sig n → Bool
    exact ⟨fun _ => false⟩
  | succ k ih =>
    -- NormalForm sig (k+1) n = (AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)
    exact ⟨(fun _ => false, fun _ => false)⟩

/--
game_depth is strictly monotone: f(n) < f(n+1).
This follows from the recurrence f(n+1) = (1 + 3*f(n))*(2*k_n) + 2 ≥ f(n) + 2.
-/
theorem game_depth_strict_mono (sig : MonadicSignature) (n : Nat) :
    game_depth sig n < game_depth sig (n + 1) := by
  simp only [game_depth]
  haveI : Nonempty (NormalForm sig (game_depth sig n) 1) :=
    normalForm_nonempty sig _ _
  set kn := Fintype.card (NormalForm sig (game_depth sig n) 1)
  have h_k : 0 < kn := Fintype.card_pos
  set fn := game_depth sig n
  -- Goal: fn < (1 + 3 * fn) * (2 * kn) + 2
  -- Since kn ≥ 1: (1+3*fn)*(2*kn) ≥ (1+3*fn)*2 = 2+6*fn, so RHS ≥ 4+6*fn > fn
  have h1 : (1 + 3 * fn) * 2 ≤ (1 + 3 * fn) * (2 * kn) :=
    Nat.mul_le_mul_left _ (by omega)
  -- Need: fn < (1 + 3 * fn) * (2 * kn) + 2
  -- From h1: (1 + 3 * fn) * (2 * kn) ≥ (1 + 3 * fn) * 2 = 2 + 6 * fn
  -- So it suffices to show fn < 2 + 6 * fn + 2, i.e., 0 < 4 + 5 * fn, which holds
  -- omega needs the expanded form
  have h2 : 2 + 6 * fn = (1 + 3 * fn) * 2 := by omega
  omega

/--
game_depth is monotone: n ≤ m → f(n) ≤ f(m).
-/
theorem game_depth_mono (sig : MonadicSignature) {n m : Nat} (h : n ≤ m) :
    game_depth sig n ≤ game_depth sig m := by
  suffices ∀ d, game_depth sig n ≤ game_depth sig (n + d) by
    obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le h
    exact this d
  intro d; induction d with
  | zero => simp
  | succ d ih =>
    have h2 : game_depth sig (n + d) < game_depth sig (n + d + 1) :=
      game_depth_strict_mono sig _
    have h3 : n + d + 1 = n + (d + 1) := by omega
    rw [h3] at h2
    exact le_of_lt (lt_of_le_of_lt ih h2)

/-! ## n-Equivalence: StaviFormula Agreement at Bounded Depth

Two pointed structures (M, t) and (N, s) are n-equivalent if they agree
on all StaviFormulas of depth ≤ game_depth(n). This is the key semantic
relation connecting EF games to expressive completeness. -/

/--
Depth of a StaviFormula: counts nesting of temporal connectives.
For base formulas, uses `operator_depth`. For Stavi connectives (U'/S'),
adds 2 per nesting level (matching Until/Since depth).
-/
def stavi_depth : StaviFormula → Nat
  | .base φ => operator_depth φ
  | .stavi_untl A B => max (stavi_depth A) (stavi_depth B) + 2
  | .stavi_snce A B => max (stavi_depth A) (stavi_depth B) + 2
  | .neg φ => stavi_depth φ
  | .conj φ ψ => max (stavi_depth φ) (stavi_depth ψ)
  | .std_untl A B => max (stavi_depth A) (stavi_depth B) + 2
  | .std_snce A B => max (stavi_depth A) (stavi_depth B) + 2

/--
Two pointed structures (M, t) and (N, s) are n-equivalent if they agree
on all StaviFormulas of depth ≤ game_depth(n).

This is the key relation in the GHR93 proof: the main theorem shows that
n-equivalence is equivalent to Duplicator winning the n-round EF game.
-/
def stavi_n_equiv {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (n : Nat) (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (s : N.carrier) : Prop :=
  ∀ (A : StaviFormula), stavi_depth A ≤ game_depth sig n →
    (stavi_temporal_truth M atomMap t A ↔ stavi_temporal_truth N atomMap s A)

/--
n-equivalence is symmetric.
-/
theorem stavi_n_equiv_symm {sig : MonadicSignature} {atomMap : Formula → sig.preds}
    {n : Nat} {M : OrderedMonadicStructure sig} {t : M.carrier}
    {N : OrderedMonadicStructure sig} {s : N.carrier}
    (h : stavi_n_equiv atomMap n M t N s) :
    stavi_n_equiv atomMap n N s M t :=
  fun A hd => (h A hd).symm

/--
n-equivalence is monotone in n: if (M,t) and (N,s) are (n+1)-equivalent,
they are also n-equivalent.
-/
theorem stavi_n_equiv_mono {sig : MonadicSignature} {atomMap : Formula → sig.preds}
    {n m : Nat} (h_le : n ≤ m)
    {M : OrderedMonadicStructure sig} {t : M.carrier}
    {N : OrderedMonadicStructure sig} {s : N.carrier}
    (h : stavi_n_equiv atomMap m M t N s) :
    stavi_n_equiv atomMap n M t N s :=
  fun A hd => h A (le_trans hd (game_depth_mono sig h_le))

/-! ## Gaps and Extended Structures (GHR93 Definition 8.3)

A **gap** in a linearly ordered type T is a Dedekind cut with no supremum:
a non-empty downward-closed proper subset whose complement has no minimum.

The extended structure M_r adjoins r-definable gaps to M as new "points",
yielding a larger linearly ordered type. In discrete orders (with
IsSuccArchimedean), there are no gaps, so M_r = M.

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Definition 8.3
- Task 155 plan: Phase 4B, Task 4B.2
-/

/--
A gap in a linearly ordered type T is a Dedekind cut with no supremum.
Concretely, a gap consists of a subset `cut` of T satisfying:
1. `cut` is non-empty
2. `cut` is a proper subset (not all of T)
3. `cut` is downward-closed
4. `cut` has no supremum that belongs to `cut`
5. The complement of `cut` has no minimum

Gaps correspond to "holes" in the order: points where a new element
could be inserted to fill a Dedekind cut. In GHR93, gaps in M are
adjoined to form the extended structure M_r.
-/
structure Gap (T : Type) [LinearOrder T] where
  /-- The left side of the Dedekind cut -/
  cut : Set T
  /-- The cut is non-empty -/
  nonempty : cut.Nonempty
  /-- The cut is a proper subset (does not contain everything) -/
  proper : cut ≠ Set.univ
  /-- The cut is downward-closed: if x is in the cut and y ≤ x, then y is in the cut -/
  downward_closed : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut
  /-- The cut has no supremum that belongs to the cut -/
  no_sup : ¬∃ s, IsLUB cut s ∧ s ∈ cut
  /-- The complement of the cut has no minimum -/
  complement_no_min : ¬∃ m, m ∉ cut ∧ ∀ y, y ∉ cut → m ≤ y

/--
Two gaps with the same cut are equal. All fields other than `cut` are
Prop-valued, so they are equal by proof irrelevance.
-/
theorem gap_ext {T : Type} [LinearOrder T] (γ₁ γ₂ : Gap T)
    (h : γ₁.cut = γ₂.cut) : γ₁ = γ₂ := by
  cases γ₁; cases γ₂; simp at h; subst h; rfl

/--
Downward-closed subsets of a linear order are totally ordered by inclusion.
Given two gaps γ₁ and γ₂, either γ₁.cut ⊆ γ₂.cut or γ₂.cut ⊆ γ₁.cut.
-/
theorem gap_cuts_total {T : Type} [LinearOrder T] (γ₁ γ₂ : Gap T) :
    γ₁.cut ⊆ γ₂.cut ∨ γ₂.cut ⊆ γ₁.cut := by
  by_contra h; push_neg at h; obtain ⟨h1, h2⟩ := h
  obtain ⟨x, hx1, hx2⟩ := Set.not_subset.mp h1
  obtain ⟨y, hy2, hy1⟩ := Set.not_subset.mp h2
  -- x ∈ γ₁ \ γ₂ and y ∈ γ₂ \ γ₁
  rcases le_or_gt x y with hxy | hxy
  · -- x ≤ y, y ∈ γ₂, downward-closed → x ∈ γ₂. Contradiction.
    exact hx2 (γ₂.downward_closed y x hy2 hxy)
  · -- y < x, x ∈ γ₁, downward-closed → y ∈ γ₁. Contradiction.
    exact hy1 (γ₁.downward_closed x y hx1 (le_of_lt hxy))

/-! ### Gap Definability

An r-definable gap is a gap that can be "detected" by a temporal formula
of rank ≤ r. A gap is definable on the left by D if D holds throughout
some non-empty final segment of the cut and does NOT hold throughout any
non-empty initial segment of the complement. Dually for right-definability. -/

/--
A gap is definable on the left by a StaviFormula D:
D holds in a final segment of the cut (some t ∈ cut such that D holds
at all u ≥ t in the cut), and D does NOT hold in any initial segment
of the complement.
-/
def gap_definable_on_left {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (gamma : Gap M.carrier) (D : StaviFormula) : Prop :=
  (∃ t, t ∈ gamma.cut ∧ ∀ u, t ≤ u → u ∈ gamma.cut →
    stavi_temporal_truth M atomMap u D) ∧
  ¬(∃ t, t ∉ gamma.cut ∧ ∀ u, u ∉ gamma.cut → u ≤ t →
    stavi_temporal_truth M atomMap u D)

/--
A gap is definable on the right by a StaviFormula D:
D holds in an initial segment of the complement (some t ∉ cut such that D
holds at all u ≤ t not in the cut), and D does NOT hold in any final
segment of the cut.
-/
def gap_definable_on_right {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (gamma : Gap M.carrier) (D : StaviFormula) : Prop :=
  (∃ t, t ∉ gamma.cut ∧ ∀ u, u ∉ gamma.cut → u ≤ t →
    stavi_temporal_truth M atomMap u D) ∧
  ¬(∃ t, t ∈ gamma.cut ∧ ∀ u, t ≤ u → u ∈ gamma.cut →
    stavi_temporal_truth M atomMap u D)

/--
A gap is r-definable if it can be defined on the left or right by some
StaviFormula of depth ≤ r. (GHR93 Definition 8.3)
-/
def r_definable_gap {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (gamma : Gap M.carrier) (r : Nat) : Prop :=
  ∃ D : StaviFormula, stavi_depth D ≤ r ∧
    (gap_definable_on_left M atomMap gamma D ∨
     gap_definable_on_right M atomMap gamma D)

/-- The type of r-definable gaps of an ordered monadic structure M. -/
abbrev RDefinableGap {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (r : Nat) :=
  { g : Gap M.carrier // r_definable_gap M atomMap g r }

/-! ### Extended Carrier M_r

The extended carrier M_r consists of the original points of M plus
all r-definable gaps. The ordering interleaves gaps among points:
a point x is below a gap γ iff x belongs to γ's cut. -/

/--
Extended carrier M_r = M.carrier ⊕ (r-definable gaps of M).
This is the type underlying the extended structure of GHR93 Definition 8.3.
-/
def ExtendedCarrier {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (r : Nat) : Type :=
  M.carrier ⊕ RDefinableGap M atomMap r

/-- The ordering on the extended carrier: interleaves points and gaps.
A point x ≤ a gap γ iff x ∈ γ.cut. A gap γ ≤ a point x iff x ∉ γ.cut.
Between gaps, compare by cut inclusion. -/
private noncomputable def extendedLE {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat} :
    ExtendedCarrier M atomMap r → ExtendedCarrier M atomMap r → Prop
  | .inl x, .inl y => x ≤ y
  | .inl x, .inr g => x ∈ g.val.cut
  | .inr g, .inl x => x ∉ g.val.cut
  | .inr g₁, .inr g₂ => g₁.val.cut ⊆ g₂.val.cut

/--
The extended carrier M_r has a linear order that interleaves points and gaps.
Points are ordered as in M. A point x is below a gap γ iff x ∈ γ.cut.
Gaps are ordered by cut inclusion (which is total for downward-closed sets
in a linear order).
-/
noncomputable instance extendedLinearOrder {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat} :
    LinearOrder (ExtendedCarrier M atomMap r) where
  le := extendedLE
  lt := fun a b => extendedLE a b ∧ ¬extendedLE b a
  le_refl a := by
    cases a with
    | inl x => show x ≤ x; exact le_refl x
    | inr g => show g.val.cut ⊆ g.val.cut; exact Set.Subset.refl _
  le_trans a b c hab hbc := by
    match a, b, c with
    | .inl x, .inl y, .inl z =>
      exact le_trans (show x ≤ y from hab) (show y ≤ z from hbc)
    | .inl x, .inl y, .inr g =>
      exact g.val.downward_closed y x (show y ∈ g.val.cut from hbc)
        (show x ≤ y from hab)
    | .inl x, .inr g, .inl z =>
      show x ≤ z; by_contra h; push_neg at h
      exact (show z ∉ g.val.cut from hbc)
        (g.val.downward_closed x z (show x ∈ g.val.cut from hab) (le_of_lt h))
    | .inl x, .inr g, .inr g' =>
      exact (show g.val.cut ⊆ g'.val.cut from hbc) (show x ∈ g.val.cut from hab)
    | .inr g, .inl y, .inl z =>
      show z ∉ g.val.cut; intro hz
      exact (show y ∉ g.val.cut from hab)
        (g.val.downward_closed z y hz (show y ≤ z from hbc))
    | .inr g, .inl y, .inr g' =>
      show g.val.cut ⊆ g'.val.cut; intro x hx; by_contra hx'
      have hyx : y ≤ x := by
        by_contra h; push_neg at h
        exact hx' (g'.val.downward_closed y x (show y ∈ g'.val.cut from hbc) (le_of_lt h))
      exact (show y ∉ g.val.cut from hab) (g.val.downward_closed x y hx hyx)
    | .inr g, .inr g', .inl z =>
      show z ∉ g.val.cut; intro hz
      exact (show z ∉ g'.val.cut from hbc) ((show g.val.cut ⊆ g'.val.cut from hab) hz)
    | .inr g, .inr g', .inr g'' =>
      exact Set.Subset.trans (show g.val.cut ⊆ g'.val.cut from hab)
        (show g'.val.cut ⊆ g''.val.cut from hbc)
  le_antisymm a b hab hba := by
    match a, b with
    | .inl x, .inl y =>
      exact congrArg Sum.inl (le_antisymm (show x ≤ y from hab) (show y ≤ x from hba))
    | .inl x, .inr g =>
      exact absurd (show x ∈ g.val.cut from hab) (show x ∉ g.val.cut from hba)
    | .inr g, .inl x =>
      exact absurd (show x ∈ g.val.cut from hba) (show x ∉ g.val.cut from hab)
    | .inr g₁, .inr g₂ =>
      exact congrArg Sum.inr (Subtype.ext (gap_ext _ _
        (Set.Subset.antisymm (show g₁.val.cut ⊆ g₂.val.cut from hab)
                              (show g₂.val.cut ⊆ g₁.val.cut from hba))))
  le_total a b := by
    match a, b with
    | .inl x, .inl y =>
      rcases le_total x y with h | h
      · exact Or.inl (show extendedLE (.inl x) (.inl y) from h)
      · exact Or.inr (show extendedLE (.inl y) (.inl x) from h)
    | .inl x, .inr g =>
      rcases Classical.em (x ∈ g.val.cut) with h | h
      · exact Or.inl (show extendedLE (.inl x) (.inr g) from h)
      · exact Or.inr (show extendedLE (.inr g) (.inl x) from h)
    | .inr g, .inl x =>
      rcases Classical.em (x ∈ g.val.cut) with h | h
      · exact Or.inr (show extendedLE (.inl x) (.inr g) from h)
      · exact Or.inl (show extendedLE (.inr g) (.inl x) from h)
    | .inr g₁, .inr g₂ =>
      rcases gap_cuts_total g₁.val g₂.val with h | h
      · exact Or.inl (show extendedLE (.inr g₁) (.inr g₂) from h)
      · exact Or.inr (show extendedLE (.inr g₂) (.inr g₁) from h)
  toDecidableLE := Classical.decRel _
  toDecidableEq := Classical.typeDecidableEq _
  toDecidableLT := Classical.decRel _

/-! ### IsPoint and IsGap Predicates -/

/-- An element of the extended carrier is a point (from the original structure). -/
def IsPoint {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    (e : ExtendedCarrier M atomMap r) : Prop :=
  ∃ x : M.carrier, e = Sum.inl x

/-- An element of the extended carrier is a gap. -/
def IsGap {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    (e : ExtendedCarrier M atomMap r) : Prop :=
  ∃ g : RDefinableGap M atomMap r, e = Sum.inr g

/-- Every extended carrier element is either a point or a gap. -/
theorem isPoint_or_isGap {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    (e : ExtendedCarrier M atomMap r) : IsPoint e ∨ IsGap e := by
  cases e with
  | inl x => exact Or.inl ⟨x, rfl⟩
  | inr g => exact Or.inr ⟨g, rfl⟩

/-- Embed a point from M into the extended carrier. -/
def extendPoint {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat} (x : M.carrier) :
    ExtendedCarrier M atomMap r :=
  Sum.inl x

/-- The point embedding preserves order. -/
theorem extendPoint_le_iff {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat} (x y : M.carrier) :
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) x ≤
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) y ↔ x ≤ y := by
  constructor
  · intro h; exact h
  · intro h; exact h

/-- A point x is below a gap γ in the extended carrier iff x ∈ γ.cut. -/
theorem extendPoint_le_gap_iff {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat} (x : M.carrier)
    (g : RDefinableGap M atomMap r) :
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) x ≤ Sum.inr g ↔
    x ∈ g.val.cut := by
  constructor
  · intro h; exact h
  · intro h; exact h


/-! ### Discrete Orders Have No Gaps

In a succ-archimedean discrete order, gaps cannot exist. This means
M_r = M for discrete orders, which is the key simplification that makes
the discrete case of the Reynolds pipeline straightforward. -/

/--
In a discrete order with SuccOrder and NoMaxOrder, the cut of a gap is
closed under successor: if a ∈ cut, then succ(a) ∈ cut.

Proof: if succ(a) ∉ cut, then a is the LUB of the cut with a ∈ cut
(since any y > a satisfies y ≥ succ(a), so y ∉ cut by downward-closure).
This contradicts the gap condition no_sup.
-/
theorem gap_cut_succ_closed {T : Type} [LinearOrder T] [SuccOrder T] [NoMaxOrder T]
    (γ : Gap T) (a : T) (ha : a ∈ γ.cut) : Order.succ a ∈ γ.cut := by
  by_contra h
  apply γ.no_sup
  refine ⟨a, ?_, ha⟩
  constructor
  · -- a is upper bound of cut
    intro y hy
    by_contra hya; push_neg at hya
    exact h (γ.downward_closed y (Order.succ a) hy (Order.succ_le_of_lt hya))
  · -- a is least upper bound
    intro u hu; exact hu ha

/--
In a discrete order with PredOrder and NoMinOrder, the complement of a
gap's cut is closed under predecessor: if b ∉ cut, then pred(b) ∉ cut.

Proof: if pred(b) ∈ cut, then b is the minimum of the complement
(since any y < b satisfies y ≤ pred(b), so y ∈ cut by downward-closure).
This contradicts the gap condition complement_no_min.
-/
theorem gap_complement_pred_closed {T : Type} [LinearOrder T] [PredOrder T] [NoMinOrder T]
    (γ : Gap T) (b : T) (hb : b ∉ γ.cut) : Order.pred b ∉ γ.cut := by
  intro h
  apply γ.complement_no_min
  refine ⟨b, hb, ?_⟩
  intro y hy
  by_contra hby; push_neg at hby
  exact hy (γ.downward_closed (Order.pred b) y h (Order.le_pred_of_lt hby))

/--
In a succ-archimedean discrete order with SuccOrder, PredOrder, NoMaxOrder,
and NoMinOrder, there are no gaps.

The proof uses succ-archimedean reachability: given any a ∈ cut and b ∉ cut
with a < b, the succ chain a, succ(a), succ²(a), ... eventually reaches b.
Since `gap_cut_succ_closed` shows each step stays in the cut, we get b ∈ cut,
contradicting b ∉ cut.

This means M_r = M for discrete orders: the extended structure adds no new
elements, and the EF game reduces to the standard game on M.
-/
theorem discrete_no_gaps {T : Type} [LinearOrder T]
    [SuccOrder T] [PredOrder T] [NoMaxOrder T] [NoMinOrder T]
    [IsSuccArchimedean T] : IsEmpty (Gap T) := by
  constructor
  intro γ
  obtain ⟨a, ha⟩ := γ.nonempty
  -- The cut is proper, so there exists b ∉ cut
  have hne : ∃ b, b ∉ γ.cut := by
    by_contra h; push_neg at h
    exact γ.proper (Set.eq_univ_of_forall h)
  obtain ⟨b, hb⟩ := hne
  -- a < b since b ≤ a would put b in cut by downward-closure
  have hab : a < b := by
    rcases lt_or_ge a b with h | h
    · exact h
    · exact absurd (γ.downward_closed a b ha h) hb
  -- By IsSuccArchimedean, b = succ^n(a) for some n
  obtain ⟨n, hn⟩ := exists_succ_iterate_of_le (le_of_lt hab)
  -- By induction: succ^k(a) ∈ cut for all k
  have h_all : ∀ k, Order.succ^[k] a ∈ γ.cut := by
    intro k; induction k with
    | zero => exact ha
    | succ k ih => rw [Function.iterate_succ']; exact gap_cut_succ_closed γ _ ih
  -- In particular succ^n(a) = b ∈ cut, contradicting b ∉ cut
  rw [← hn] at hb
  exact hb (h_all n)

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

/-! ## Gap Detection Formulas (GHR93 Definition 8.5)

The `left_formula` and `right_formula` functions convert properties of gaps
into properties of actual points. Given a StaviFormula A (describing what
holds at a gap) and a StaviFormula D (the gap-defining formula), `left_formula A D`
produces a StaviFormula that, when evaluated at an actual point m, detects
whether there is a D-defined gap gamma > m where A^mu holds at gamma.

### Definition by structural induction on A:

```
left(p, D)         = bot                    (atoms are false at gaps)
left(neg A, D)     = U'(top, D) and neg left(A, D)
left(A and B, D)   = left(A, D) and left(B, D)
left(U(A,B), D)    = U'(B and U(A,B), D)
left(U'(A,B), D)   = U'(B and U'(A,B), D)
left(S(A,B), D)    = U(D and B and S(A,B) and U'(top, B and D) and neg U'(D, B and D), D)
left(S'(A,B), D)   = U(D and B and S'(A,B) and U'(top, B and D) and neg U'(D, B and D), D)
```

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Definition 8.5
- GHR93 Lemma 9: Gap detection correctness
- Task 155 plan: Phase 4B, Task 4B.4
-/

/-- Helper: left_formula for base (standard temporal) formulas.
    Structural recursion on Formula is straightforward since all Formula
    constructors have structurally smaller subterms.

    For the `.snce` case, the GHR93 definition produces `U(X, D)` where X
    contains Stavi connectives. We use `std_untl` to represent standard Until
    of StaviFormula arguments, avoiding the need for `flatten_stavi` (which
    maps U'/S' to bot, breaking the semantics for compound formulas). -/
noncomputable def left_formula_base (D : StaviFormula) : Formula → StaviFormula
  | .atom _ => .base .bot
  | .bot => .base .bot
  | .imp φ ψ =>
    -- A → B = ¬(A ∧ ¬B), so left(A→B, D) = left(¬(A ∧ ¬B), D)
    -- = U'(⊤, D) ∧ ¬left(A ∧ ¬B, D)
    -- = U'(⊤, D) ∧ ¬(left(A, D) ∧ left(¬B, D))
    -- = U'(⊤, D) ∧ ¬(left(A, D) ∧ (U'(⊤,D) ∧ ¬left(B, D)))
    .conj (.stavi_untl (.base Formula.top) D)
      (.neg (.conj (left_formula_base D φ)
        (.conj (.stavi_untl (.base Formula.top) D)
          (.neg (left_formula_base D ψ)))))
  | .box _ => .base .bot  -- box-subformulas are treated as atoms
  | .untl φ ψ =>
    -- left(U(A,B), D) = U'(B ∧ U(A,B), D)
    .stavi_untl (.conj (.base ψ) (.base (.untl φ ψ))) D
  | .snce φ ψ =>
    -- left(S(A,B), D) = U(D ∧ B ∧ S(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D), D)
    -- Uses std_untl to represent standard Until of StaviFormula arguments.
    let bD := .base ψ  -- B as StaviFormula
    let sAB := .base (.snce φ ψ)  -- S(A,B) as StaviFormula
    let bAndD := StaviFormula.conj bD D  -- B ∧ D
    let uPrimTopBD := StaviFormula.stavi_untl (.base Formula.top) bAndD  -- U'(⊤, B∧D)
    let negUPrimDBD := StaviFormula.neg (StaviFormula.stavi_untl D bAndD)  -- ¬U'(D, B∧D)
    let compound := StaviFormula.conj D
      (StaviFormula.conj bD
        (StaviFormula.conj sAB
          (StaviFormula.conj uPrimTopBD negUPrimDBD)))
    -- U(compound, D): standard Until of StaviFormula arguments
    .std_untl compound D

/--
Gap detection formula `left(A, D)` from GHR93 Definition 8.5.

Given a StaviFormula A (describing what should hold at a gap) and a
StaviFormula D (the gap-defining formula), `left_formula A D` produces
a StaviFormula that detects whether there is a D-defined gap gamma > m
where A^mu holds at gamma, with D holding on all points between m and gamma.

The definition is by structural induction on A, following GHR93 exactly
for all cases. For the S/S' cases, the result uses `std_untl` to encode
standard Until of Stavi-enriched subformulas (replacing the old
`flatten_stavi` approach which incorrectly mapped U'/S' to bot).
-/
noncomputable def left_formula : StaviFormula → StaviFormula → StaviFormula
  | .base φ, D => left_formula_base D φ
  | .neg A, D =>
    -- left(¬A, D) = U'(⊤, D) ∧ ¬left(A, D)
    .conj (.stavi_untl (.base Formula.top) D) (.neg (left_formula A D))
  | .conj A B, D =>
    -- left(A ∧ B, D) = left(A, D) ∧ left(B, D)
    .conj (left_formula A D) (left_formula B D)
  | .stavi_untl A B, D =>
    -- left(U'(A,B), D) = U'(B ∧ U'(A,B), D)
    .stavi_untl (.conj B (.stavi_untl A B)) D
  | .stavi_snce A B, D =>
    -- left(S'(A,B), D) = U(D ∧ B ∧ S'(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D), D)
    -- Same structure as the S case but with S' instead of S.
    let bAndD := StaviFormula.conj B D  -- B ∧ D
    let uPrimTopBD := StaviFormula.stavi_untl (.base Formula.top) bAndD  -- U'(⊤, B∧D)
    let negUPrimDBD := StaviFormula.neg (StaviFormula.stavi_untl D bAndD)  -- ¬U'(D, B∧D)
    let compound := StaviFormula.conj D
      (StaviFormula.conj B
        (StaviFormula.conj (.stavi_snce A B)
          (StaviFormula.conj uPrimTopBD negUPrimDBD)))
    -- Standard Until of StaviFormula arguments
    .std_untl compound D
  | .std_untl A B, D =>
    -- left(U(A,B), D) = U'(B ∧ U(A,B), D)
    .stavi_untl (.conj B (.std_untl A B)) D
  | .std_snce A B, D =>
    -- left(S(A,B), D) = U(D ∧ B ∧ S(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D), D)
    let bAndD := StaviFormula.conj B D
    let uPrimTopBD := StaviFormula.stavi_untl (.base Formula.top) bAndD
    let negUPrimDBD := StaviFormula.neg (StaviFormula.stavi_untl D bAndD)
    let compound := StaviFormula.conj D
      (StaviFormula.conj B
        (StaviFormula.conj (.std_snce A B)
          (StaviFormula.conj uPrimTopBD negUPrimDBD)))
    .std_untl compound D

/-- Helper: right_formula for base (standard temporal) formulas.
    Dual of left_formula_base: swaps U↔S and U'↔S' throughout. -/
noncomputable def right_formula_base (D : StaviFormula) : Formula → StaviFormula
  | .atom _ => .base .bot
  | .bot => .base .bot
  | .imp φ ψ =>
    -- right(A→B, D) = S'(⊤, D) ∧ ¬right(A ∧ ¬B, D)
    .conj (.stavi_snce (.base Formula.top) D)
      (.neg (.conj (right_formula_base D φ)
        (.conj (.stavi_snce (.base Formula.top) D)
          (.neg (right_formula_base D ψ)))))
  | .box _ => .base .bot
  | .untl φ ψ =>
    -- right(U(A,B), D) = S(D ∧ B ∧ U(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D), D)
    -- Uses std_snce to represent standard Since of StaviFormula arguments.
    let bD := .base ψ
    let uAB := .base (.untl φ ψ)
    let bAndD := StaviFormula.conj bD D
    let sPrimTopBD := StaviFormula.stavi_snce (.base Formula.top) bAndD
    let negSPrimDBD := StaviFormula.neg (StaviFormula.stavi_snce D bAndD)
    let compound := StaviFormula.conj D
      (StaviFormula.conj bD
        (StaviFormula.conj uAB
          (StaviFormula.conj sPrimTopBD negSPrimDBD)))
    .std_snce compound D
  | .snce φ ψ =>
    -- right(S(A,B), D) = S'(B ∧ S(A,B), D)
    .stavi_snce (.conj (.base ψ) (.base (.snce φ ψ))) D

/--
Gap detection formula `right(A, D)` from GHR93 Definition 8.5.

Dual of `left_formula`: detects whether there is a D-defined gap gamma < m
where A^mu holds at gamma, with D holding on all points between gamma and m.

Obtained from `left_formula` by swapping U↔S and U'↔S' throughout.
-/
noncomputable def right_formula : StaviFormula → StaviFormula → StaviFormula
  | .base φ, D => right_formula_base D φ
  | .neg A, D =>
    -- right(¬A, D) = S'(⊤, D) ∧ ¬right(A, D)
    .conj (.stavi_snce (.base Formula.top) D) (.neg (right_formula A D))
  | .conj A B, D =>
    -- right(A ∧ B, D) = right(A, D) ∧ right(B, D)
    .conj (right_formula A D) (right_formula B D)
  | .stavi_untl A B, D =>
    -- right(U'(A,B), D) = S(D ∧ B ∧ U'(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D), D)
    let bAndD := StaviFormula.conj B D
    let sPrimTopBD := StaviFormula.stavi_snce (.base Formula.top) bAndD
    let negSPrimDBD := StaviFormula.neg (StaviFormula.stavi_snce D bAndD)
    let compound := StaviFormula.conj D
      (StaviFormula.conj B
        (StaviFormula.conj (.stavi_untl A B)
          (StaviFormula.conj sPrimTopBD negSPrimDBD)))
    -- Standard Since of StaviFormula arguments
    .std_snce compound D
  | .stavi_snce A B, D =>
    -- right(S'(A,B), D) = S'(B ∧ S'(A,B), D)
    .stavi_snce (.conj B (.stavi_snce A B)) D
  | .std_untl A B, D =>
    -- right(U(A,B), D) = S(D ∧ B ∧ U(A,B) ∧ S'(⊤, B∧D) ∧ ¬S'(D, B∧D), D)
    let bAndD := StaviFormula.conj B D
    let sPrimTopBD := StaviFormula.stavi_snce (.base Formula.top) bAndD
    let negSPrimDBD := StaviFormula.neg (StaviFormula.stavi_snce D bAndD)
    let compound := StaviFormula.conj D
      (StaviFormula.conj B
        (StaviFormula.conj (.std_untl A B)
          (StaviFormula.conj sPrimTopBD negSPrimDBD)))
    .std_snce compound D
  | .std_snce A B, D =>
    -- right(S(A,B), D) = S'(B ∧ S(A,B), D)
    .stavi_snce (.conj B (.std_snce A B)) D

/-! ### Rank Bounds for Gap Detection Formulas -/

/-- The operator_depth of flatten_stavi A is bounded by stavi_depth A.
    This is crucial for the rank bounds of left_formula/right_formula
    in cases where flatten_stavi is used to encode standard Until/Since
    of Stavi-enriched subformulas. -/
private theorem operator_depth_flatten_stavi_le (A : StaviFormula) :
    operator_depth (flatten_stavi A) ≤ stavi_depth A := by
  induction A with
  | base φ =>
    simp [flatten_stavi, stavi_depth]
  | neg A ih =>
    simp only [flatten_stavi, stavi_depth, Formula.neg, operator_depth]
    omega
  | conj A B ihA ihB =>
    simp only [flatten_stavi, stavi_depth, Formula.and, Formula.neg, operator_depth]
    omega
  | stavi_untl A B ihA ihB =>
    simp only [flatten_stavi, stavi_depth, Formula.and, Formula.neg, operator_depth]
    omega
  | stavi_snce A B ihA ihB =>
    simp only [flatten_stavi, stavi_depth, Formula.and, Formula.neg, operator_depth]
    omega
  | std_untl A B ihA ihB =>
    simp only [flatten_stavi, stavi_depth, operator_depth]
    omega
  | std_snce A B ihA ihB =>
    simp only [flatten_stavi, stavi_depth, operator_depth]
    omega

/-- Helper: stavi_depth of left_formula_base is bounded.

    GHR93 claims rank(left(A,D)) ≤ max(rank(A), rank(D)) + 2 with rank counting
    each temporal connective as +1. Our `stavi_depth`/`operator_depth` counts +2
    per connective, so the corresponding bound is +4 in our encoding.

    The S/S' cases contain U'(...) subformulas inside a U(...) wrapper, giving
    two levels of temporal connective nesting beyond the max of the sub-depths. -/
private theorem stavi_depth_left_formula_base (D : StaviFormula) (φ : Formula) :
    stavi_depth (left_formula_base D φ) ≤ max (operator_depth φ) (stavi_depth D) + 4 := by
  induction φ with
  | atom _ =>
    simp [left_formula_base, stavi_depth, operator_depth]
  | bot =>
    simp [left_formula_base, stavi_depth, operator_depth]
  | imp φ ψ ih_φ ih_ψ =>
    simp only [left_formula_base, stavi_depth, operator_depth, Formula.top] at *
    omega
  | box _ =>
    simp [left_formula_base, stavi_depth, operator_depth]
  | untl φ ψ =>
    simp only [left_formula_base, stavi_depth, operator_depth]
    omega
  | snce φ ψ =>
    -- The snce case uses std_untl. stavi_depth of std_untl compound D =
    -- max (stavi_depth compound) (stavi_depth D) + 2. The compound contains
    -- U' subformulas giving +2, so total depth is bounded by
    -- max(operator_depth φ, operator_depth ψ, stavi_depth D) + 4.
    simp only [left_formula_base, stavi_depth, operator_depth, Formula.top]
    omega

/--
**Rank bound** (GHR93 Definition 8.5): The depth of left_formula(A, D) is
bounded by max(stavi_depth A, stavi_depth D) + 4.

GHR93 states the bound as max(rank(A), rank(D)) + 2 using a rank function
that counts +1 per temporal connective. Our `stavi_depth` counts +2 per
connective, so the corresponding bound is +4. The S/S' cases contain
U'(...) subformulas inside a U(...) wrapper, giving two levels of temporal
connective nesting beyond the max of the sub-depths.

This bound ensures that left_formula produces formulas within the rank
budget of the EF game.
-/
theorem stavi_depth_left_formula (A D : StaviFormula) :
    stavi_depth (left_formula A D) ≤ max (stavi_depth A) (stavi_depth D) + 4 := by
  induction A with
  | base φ =>
    simp only [left_formula, stavi_depth]
    have h := stavi_depth_left_formula_base D φ
    omega
  | neg A ih =>
    simp only [left_formula, stavi_depth, Formula.top, operator_depth] at *
    omega
  | conj A B ihA ihB =>
    simp only [left_formula, stavi_depth]
    omega
  | stavi_untl A B =>
    simp only [left_formula, stavi_depth]
    omega
  | stavi_snce A B =>
    -- left(S'(A,B), D) = std_untl compound D
    simp only [left_formula, stavi_depth, operator_depth, Formula.top]
    omega
  | std_untl A B =>
    -- left(U(A,B), D) = U'(B ∧ U(A,B), D)
    simp only [left_formula, stavi_depth]
    omega
  | std_snce A B =>
    -- left(S(A,B), D) = std_untl compound D
    simp only [left_formula, stavi_depth, operator_depth, Formula.top]
    omega

/--
**Rank bound** for right_formula: The depth of right_formula(A, D) is
bounded by max(stavi_depth A, stavi_depth D) + 4.

Symmetric to `stavi_depth_left_formula` by the U↔S, U'↔S' swap.
-/
theorem stavi_depth_right_formula (A D : StaviFormula) :
    stavi_depth (right_formula A D) ≤ max (stavi_depth A) (stavi_depth D) + 4 := by
  induction A with
  | base φ =>
    -- right_formula_base D φ is symmetric to left_formula_base D φ
    -- with U↔S and U'↔S' swapped. The depth analysis is identical.
    simp only [right_formula, stavi_depth]
    induction φ with
    | atom _ => simp [right_formula_base, stavi_depth, operator_depth]
    | bot => simp [right_formula_base, stavi_depth, operator_depth]
    | imp φ ψ ih_φ ih_ψ =>
      simp only [right_formula_base, stavi_depth, operator_depth, Formula.top] at *; omega
    | box _ => simp [right_formula_base, stavi_depth, operator_depth]
    | untl φ ψ =>
      -- right_formula_base now uses std_snce instead of flatten_stavi
      simp only [right_formula_base, stavi_depth, operator_depth, Formula.top]
      omega
    | snce φ ψ => simp only [right_formula_base, stavi_depth, operator_depth]; omega
  | neg A ih =>
    simp only [right_formula, stavi_depth, Formula.top, operator_depth] at *
    omega
  | conj A B ihA ihB =>
    simp only [right_formula, stavi_depth]
    omega
  | stavi_untl A B =>
    -- right(U'(A,B), D) = std_snce compound D
    simp only [right_formula, stavi_depth, operator_depth, Formula.top]
    omega
  | stavi_snce A B =>
    -- right(S'(A,B), D) = S'(B ∧ S'(A,B), D)
    simp only [right_formula, stavi_depth]
    omega
  | std_untl A B =>
    -- right(U(A,B), D) = std_snce compound D
    simp only [right_formula, stavi_depth, operator_depth, Formula.top]
    omega
  | std_snce A B =>
    -- right(S(A,B), D) = S'(B ∧ S(A,B), D)
    simp only [right_formula, stavi_depth]
    omega

/-! ### Mu-Relativized Truth at Actual Points

Key infrastructure lemma: at an actual point (extendPoint m), the mu-relativized
temporal truth agrees with standard temporal truth. This is because mu-points in
M_r are exactly the actual points from M, and the ordering among actual points in
M_r is the same as in M. -/

/-- extendPoint preserves strict order. -/
theorem extendPoint_lt_iff {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat} (x y : M.carrier) :
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) x <
    extendPoint (sig := sig) (atomMap := atomMap) (r := r) y ↔ x < y := by
  simp only [extendPoint]
  constructor
  · intro ⟨hle, hne⟩; exact lt_of_le_of_ne (show x ≤ y from hle) (fun h => hne (h ▸ le_refl y))
  · intro h; exact ⟨le_of_lt h, fun hyx => not_lt.mpr (show y ≤ x from hyx) h⟩

/-- For standard temporal formulas, mu-relativized truth at an actual point equals
    standard temporal truth. -/
theorem temporal_truth_mu_at_point {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (m : M.carrier) (φ : Formula) :
    temporal_truth_mu M atomMap r (extendPoint m) φ ↔
    temporal_truth M atomMap m φ := by
  induction φ generalizing m with
  | atom a =>
    simp only [temporal_truth_mu, temporal_truth, extendedStructure, extendPoint]
  | bot =>
    simp only [temporal_truth_mu, temporal_truth]
  | imp φ ψ ihφ ihψ =>
    simp only [temporal_truth_mu, temporal_truth]
    exact Iff.imp (ihφ m) (ihψ m)
  | box φ =>
    simp only [temporal_truth_mu, temporal_truth, extendedStructure, extendPoint]
  | untl φ ψ ihφ ihψ =>
    constructor
    · intro ⟨s, hms, hmu, hphi, hpsi⟩
      obtain ⟨s', rfl⟩ := hmu
      have hms' : m < s' := (extendPoint_lt_iff m s').mp hms
      exact ⟨s', hms', (ihφ s').mp hphi, fun u hmu' hus =>
        (ihψ u).mp (hpsi (extendPoint u) ((extendPoint_lt_iff m u).mpr hmu')
          ((extendPoint_lt_iff u s').mpr hus) ⟨u, rfl⟩)⟩
    · intro ⟨s, hms, hphi, hpsi⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff m s).mpr hms, ⟨s, rfl⟩,
        (ihφ s).mpr hphi, fun u hmu hus hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihψ u').mpr (hpsi u' ((extendPoint_lt_iff m u').mp hmu)
        ((extendPoint_lt_iff u' s).mp hus))
  | snce φ ψ ihφ ihψ =>
    constructor
    · intro ⟨s, hsm, hmu, hphi, hpsi⟩
      obtain ⟨s', rfl⟩ := hmu
      have hsm' : s' < m := (extendPoint_lt_iff s' m).mp hsm
      exact ⟨s', hsm', (ihφ s').mp hphi, fun u hsu hum =>
        (ihψ u).mp (hpsi (extendPoint u) ((extendPoint_lt_iff s' u).mpr hsu)
          ((extendPoint_lt_iff u m).mpr hum) ⟨u, rfl⟩)⟩
    · intro ⟨s, hsm, hphi, hpsi⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff s m).mpr hsm, ⟨s, rfl⟩,
        (ihφ s).mpr hphi, fun u hsu hum hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihψ u').mpr (hpsi u' ((extendPoint_lt_iff s u').mp hsu)
        ((extendPoint_lt_iff u' m).mp hum))

/-- For Stavi formulas, mu-relativized truth at an actual point equals
    standard temporal truth. -/
theorem stavi_truth_mu_at_point {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (m : M.carrier) (A : StaviFormula) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) A ↔
    stavi_temporal_truth M atomMap m A := by
  induction A generalizing m with
  | base φ =>
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    exact temporal_truth_mu_at_point m φ
  | neg A ih =>
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    exact Iff.not (ih m)
  | conj A B ihA ihB =>
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    exact Iff.and (ihA m) (ihB m)
  | stavi_untl A B ihA ihB =>
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    constructor
    · -- mp: mu-relativized → standard
      intro ⟨s, hms, h_body, ⟨u_fail, hmu_fail, hus_fail, hmu_fail_mu, hB_fail⟩,
             ⟨u_init, hmu_init, hus_init, hmu_init_mu, hB_init⟩⟩
      -- Get M.carrier representatives
      obtain ⟨uf, rfl⟩ := hmu_fail_mu
      obtain ⟨ui, rfl⟩ := hmu_init_mu
      -- We need s' : M.carrier with s' > m. The witness s might be a gap.
      -- Use a point in the complement of s's gap (if s is a gap), or s itself.
      -- For the bound, we need s' such that uf < s' and ui < s'.
      -- Key: s > extendPoint uf and s > extendPoint ui.
      -- Take s' : find a point in M.carrier above both uf and ui.
      -- Option: use s if it's a point, otherwise use complement element.
      -- Actually we can just pick a point above both witnesses.
      -- Since the body only needs to hold on (m, s'), we can pick s' > uf, ui.
      -- But we need s' > uf AND s' > ui. Without NoMaxOrder, just take max(uf, ui) + 1?
      -- Actually, we have s > extendPoint uf in ExtendedCarrier. If s is a gap g,
      -- then uf ∈ g.val.cut. Since g.val.cut ≠ univ (proper), ∃ s' ∉ g.val.cut.
      -- Such s' satisfies extendPoint s' > Sum.inr g > extendPoint uf, so s' > uf.
      -- Similarly s' > ui.
      -- If s is a point extendPoint s', then s' > uf and s' > ui directly.
      -- In either case, we get s' > max(uf, ui) > m.
      -- Let's handle both cases of s:
      rcases s with s' | g
      · -- s = extendPoint s'
        have hms' : m < s' := (extendPoint_lt_iff m s').mp hms
        refine ⟨s', hms', ?_, ?_, ?_⟩
        · -- Body: ∀ u ∈ (m, s'), disjunction
          intro u hmu hus'
          have h_disj := h_body (extendPoint u) ((extendPoint_lt_iff m u).mpr hmu)
            ((extendPoint_lt_iff u s').mpr hus') ⟨u, rfl⟩
          cases h_disj with
          | inl h =>
            left
            obtain ⟨v, huv, hv_mu, hBv⟩ := h
            obtain ⟨v', rfl⟩ := hv_mu
            exact ⟨v', (extendPoint_lt_iff u v').mp huv,
              fun w hmw hwv' => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff m w).mpr hmw) ((extendPoint_lt_iff w v').mpr hwv') ⟨w, rfl⟩)⟩
          | inr h =>
            right
            obtain ⟨hA, v', hmv', hv'u, hv'_mu, hBv'⟩ := h
            obtain ⟨v'', rfl⟩ := hv'_mu
            exact ⟨fun v huv hvs' => (ihA v).mp (hA (extendPoint v)
                ((extendPoint_lt_iff u v).mpr huv) ((extendPoint_lt_iff v s').mpr hvs') ⟨v, rfl⟩),
              v'', (extendPoint_lt_iff m v'').mp hmv', (extendPoint_lt_iff v'' u).mp hv'u,
              fun h => hBv' ((ihB v'').mpr h)⟩
        · -- Fail: ∃ u ∈ (m, s'), ¬B(u)
          exact ⟨uf, (extendPoint_lt_iff m uf).mp hmu_fail,
            (extendPoint_lt_iff uf s').mp hus_fail,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · -- Init: ∃ u ∈ (m, s'), B on (m, u)
          exact ⟨ui, (extendPoint_lt_iff m ui).mp hmu_init,
            (extendPoint_lt_iff ui s').mp hus_init,
            fun v hmv hvu => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff m v).mpr hmv) ((extendPoint_lt_iff v ui).mpr hvu) ⟨v, rfl⟩)⟩
      · -- s = Sum.inr g (a gap)
        -- uf, ui ∈ g.val.cut since extendPoint uf/ui < Sum.inr g
        have huf_cut : uf ∈ g.val.cut := (extendPoint_le_gap_iff uf g).mp (le_of_lt hus_fail)
        have hui_cut : ui ∈ g.val.cut := (extendPoint_le_gap_iff ui g).mp (le_of_lt hus_init)
        -- gap cut cofinal: every element has a larger one in the cut
        have gap_cut_cofinal : ∀ (x : M.carrier), x ∈ g.val.cut → ∃ y, y ∈ g.val.cut ∧ x < y := by
          intro x hx; by_contra h_all; push_neg at h_all
          exact g.val.no_sup ⟨x, ⟨h_all, fun b hb => hb hx⟩, hx⟩
        -- max(uf, ui) ∈ cut
        have hmax_cut : max uf ui ∈ g.val.cut := by
          rcases le_or_lt uf ui with h | h
          · simp [max_eq_right h]; exact hui_cut
          · simp [max_eq_left (le_of_lt h)]; exact huf_cut
        obtain ⟨y, hy_cut, hmax_y⟩ := gap_cut_cofinal (max uf ui) hmax_cut
        have huf_y : uf < y := lt_of_le_of_lt (le_max_left uf ui) hmax_y
        have hui_y : ui < y := lt_of_le_of_lt (le_max_right uf ui) hmax_y
        -- Use y as the bound in M.carrier
        have hm_y : m < y := lt_trans ((extendPoint_lt_iff m uf).mp hmu_fail) huf_y
        refine ⟨y, hm_y, ?_, ?_, ?_⟩
        · -- Body: ∀ u ∈ (m, y), disjunction
          intro u hmu huy
          -- u < y and y ∈ cut → u ∈ cut (downward_closed)
          have hu_cut : u ∈ g.val.cut := g.val.downward_closed y u hy_cut (le_of_lt huy)
          have hu_s : (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) < Sum.inr g :=
            lt_of_le_of_ne ((extendPoint_le_gap_iff u g).mpr hu_cut) (fun h => by cases h)
          have h_disj := h_body (extendPoint u)
            ((extendPoint_lt_iff m u).mpr hmu) hu_s (mu_holds_point u)
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, huv, hmu_v, hBv⟩ := h_cof
            obtain ⟨xv, rfl⟩ := hmu_v
            exact ⟨xv, (extendPoint_lt_iff u xv).mp huv,
              fun w hmw hwv => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff m w).mpr hmw) ((extendPoint_lt_iff w xv).mpr hwv) ⟨w, rfl⟩)⟩
          | inr h_take =>
            right
            obtain ⟨hA, v', hmv', hv'u, hmu_v', hBv'⟩ := h_take
            obtain ⟨xv', rfl⟩ := hmu_v'
            -- xv' < y because xv' < u < y... actually v' < u < s=gap.
            -- For A quantifier: ∀ v ∈ (u, s=gap) with mu → A. At M.carrier: ∀ v ∈ (u, y).
            -- v ∈ (u, y) → v ∈ cut → extendPoint v < Sum.inr g, so within (u, s).
            exact ⟨fun v huv hvy => by
                have hv_cut : v ∈ g.val.cut := g.val.downward_closed y v hy_cut (le_of_lt hvy)
                have hv_s : (extendPoint (sig := sig) (atomMap := atomMap) (r := r) v) < Sum.inr g :=
                  lt_of_le_of_ne ((extendPoint_le_gap_iff v g).mpr hv_cut) (fun h => by cases h)
                exact (ihA v).mp (hA (extendPoint v)
                  ((extendPoint_lt_iff u v).mpr huv) hv_s ⟨v, rfl⟩),
              xv', (extendPoint_lt_iff m xv').mp hmv',
                (extendPoint_lt_iff xv' u).mp hv'u,
                fun h => hBv' ((ihB xv').mpr h)⟩
        · -- Fail
          exact ⟨uf, (extendPoint_lt_iff m uf).mp hmu_fail, huf_y,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · -- Init
          exact ⟨ui, (extendPoint_lt_iff m ui).mp hmu_init, hui_y,
            fun v hmv hvu => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff m v).mpr hmv) ((extendPoint_lt_iff v ui).mpr hvu) ⟨v, rfl⟩)⟩
    · -- mpr: standard → mu-relativized
      intro ⟨s, hms, h_body, ⟨uf, hmuf, hufs, hBuf⟩, ⟨ui, hmui, huis, hBui⟩⟩
      -- Use extendPoint s as the witness (s is an actual point, NOT mu-restricted)
      refine ⟨extendPoint s, (extendPoint_lt_iff m s).mpr hms, ?_, ?_, ?_⟩
      · -- Body
        intro u hmu hus hmu_holds
        obtain ⟨u', rfl⟩ := hmu_holds
        have hmu' : m < u' := (extendPoint_lt_iff m u').mp hmu
        have hus' : u' < s := (extendPoint_lt_iff u' s).mp hus
        have h_disj := h_body u' hmu' hus'
        cases h_disj with
        | inl h =>
          left
          obtain ⟨v, huv, hBv⟩ := h
          exact ⟨extendPoint v, (extendPoint_lt_iff u' v).mpr huv, ⟨v, rfl⟩,
            fun w hmw hwv hw_mu => by
              obtain ⟨w', rfl⟩ := hw_mu
              exact (ihB w').mpr (hBv w' ((extendPoint_lt_iff m w').mp hmw)
                ((extendPoint_lt_iff w' v).mp hwv))⟩
        | inr h =>
          right
          obtain ⟨hA, v', hmv', hv'u, hBv'⟩ := h
          exact ⟨fun v huv hvs hv_mu => by
              obtain ⟨v', rfl⟩ := hv_mu
              exact (ihA v').mpr (hA v' ((extendPoint_lt_iff u' v').mp huv)
                ((extendPoint_lt_iff v' s).mp hvs)),
            extendPoint v', (extendPoint_lt_iff m v').mpr hmv',
              (extendPoint_lt_iff v' u').mpr hv'u, ⟨v', rfl⟩,
              fun h => hBv' ((ihB v').mp h)⟩
      · -- Fail
        exact ⟨extendPoint uf, (extendPoint_lt_iff m uf).mpr hmuf,
          (extendPoint_lt_iff uf s).mpr hufs, ⟨uf, rfl⟩,
          fun h => hBuf ((ihB uf).mp h)⟩
      · -- Init
        exact ⟨extendPoint ui, (extendPoint_lt_iff m ui).mpr hmui,
          (extendPoint_lt_iff ui s).mpr huis, ⟨ui, rfl⟩,
          fun v hmv hvu hv_mu => by
            obtain ⟨v', rfl⟩ := hv_mu
            exact (ihB v').mpr (hBui v' ((extendPoint_lt_iff m v').mp hmv)
              ((extendPoint_lt_iff v' ui).mp hvu))⟩
  | stavi_snce A B ihA ihB =>
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    constructor
    · -- mp: mu-relativized → standard (past dual)
      intro ⟨s, hsm, h_body, ⟨u_fail, hsu_fail, hum_fail, hmu_fail_mu, hB_fail⟩,
             ⟨u_init, hsu_init, hum_init, hmu_init_mu, hB_init⟩⟩
      obtain ⟨uf, rfl⟩ := hmu_fail_mu
      obtain ⟨ui, rfl⟩ := hmu_init_mu
      rcases s with s' | g
      · -- s = extendPoint s'
        have hs'm : s' < m := (extendPoint_lt_iff s' m).mp hsm
        refine ⟨s', hs'm, ?_, ?_, ?_⟩
        · intro u hsu hum
          have h_disj := h_body (extendPoint u) ((extendPoint_lt_iff s' u).mpr hsu)
            ((extendPoint_lt_iff u m).mpr hum) ⟨u, rfl⟩
          cases h_disj with
          | inl h =>
            left
            obtain ⟨v, hvu, hv_mu, hBv⟩ := h
            obtain ⟨v', rfl⟩ := hv_mu
            exact ⟨v', (extendPoint_lt_iff v' u).mp hvu,
              fun w hvw hwm => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff v' w).mpr hvw) ((extendPoint_lt_iff w m).mpr hwm) ⟨w, rfl⟩)⟩
          | inr h =>
            right
            obtain ⟨hA, v', huv', hv'm, hv'_mu, hBv'⟩ := h
            obtain ⟨v'', rfl⟩ := hv'_mu
            exact ⟨fun v hsv hvu => (ihA v).mp (hA (extendPoint v)
                ((extendPoint_lt_iff s' v).mpr hsv) ((extendPoint_lt_iff v u).mpr hvu) ⟨v, rfl⟩),
              v'', (extendPoint_lt_iff u v'').mp huv', (extendPoint_lt_iff v'' m).mp hv'm,
              fun h => hBv' ((ihB v'').mpr h)⟩
        · exact ⟨uf, (extendPoint_lt_iff s' uf).mp hsu_fail,
            (extendPoint_lt_iff uf m).mp hum_fail,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · exact ⟨ui, (extendPoint_lt_iff s' ui).mp hsu_init,
            (extendPoint_lt_iff ui m).mp hum_init,
            fun v huv hvm => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff ui v).mpr huv) ((extendPoint_lt_iff v m).mpr hvm) ⟨v, rfl⟩)⟩
      · -- s = Sum.inr g (gap) — find s' in complement below m
        -- uf, ui ∉ g.val.cut since Sum.inr g < extendPoint uf/ui
        have huf_not_cut : uf ∉ g.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff uf g).mpr h) hsu_fail
        have hui_not_cut : ui ∉ g.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff ui g).mpr h) hsu_init
        -- complement_no_min → ∃ z < uf/ui ∉ cut
        have compl_no_min := g.val.complement_no_min
        have ⟨z₁, hz₁_not_cut, hz₁_uf⟩ : ∃ z, z ∉ g.val.cut ∧ z < uf := by
          by_contra h_all; push_neg at h_all
          exact compl_no_min ⟨uf, huf_not_cut, fun y hy => h_all y hy⟩
        have ⟨z₂, hz₂_not_cut, hz₂_ui⟩ : ∃ z, z ∉ g.val.cut ∧ z < ui := by
          by_contra h_all; push_neg at h_all
          exact compl_no_min ⟨ui, hui_not_cut, fun y hy => h_all y hy⟩
        have hmin_not_cut : min z₁ z₂ ∉ g.val.cut := by
          rcases le_or_lt z₁ z₂ with h | h
          · simp [min_eq_left h]; exact hz₁_not_cut
          · simp [min_eq_right (le_of_lt h)]; exact hz₂_not_cut
        -- Use s' = min z₁ z₂
        have hs'm : min z₁ z₂ < m := by
          calc min z₁ z₂ ≤ z₁ := min_le_left z₁ z₂
            _ < uf := hz₁_uf
            _ < m := (extendPoint_lt_iff uf m).mp hum_fail
        refine ⟨min z₁ z₂, hs'm, ?_, ?_, ?_⟩
        · -- Body: ∀ u ∈ (min z₁ z₂, m), disjunction
          intro u hsu hum
          -- u > min z₁ z₂, min ∉ cut → u ∉ cut → Sum.inr g < extendPoint u
          have hu_not_cut : u ∉ g.val.cut := by
            intro hu_in
            exact hmin_not_cut (g.val.downward_closed u (min z₁ z₂) hu_in (le_of_lt hsu))
          have hu_above_g : @LT.lt (ExtendedCarrier M atomMap r)
              extendedLinearOrder.toLT (Sum.inr g) (Sum.inl u) :=
            ⟨hu_not_cut, fun h => hu_not_cut h⟩
          have h_disj := h_body (extendPoint u) hu_above_g
            ((extendPoint_lt_iff u m).mpr hum) (mu_holds_point u)
          cases h_disj with
          | inl h_cof =>
            left
            obtain ⟨v, hvu, hmu_v, hBv⟩ := h_cof
            obtain ⟨xv, rfl⟩ := hmu_v
            exact ⟨xv, (extendPoint_lt_iff xv u).mp hvu,
              fun w hvw hwm => (ihB w).mp (hBv (extendPoint w)
                ((extendPoint_lt_iff xv w).mpr hvw) ((extendPoint_lt_iff w m).mpr hwm) ⟨w, rfl⟩)⟩
          | inr h_take =>
            right
            obtain ⟨hA, v', huv', hv'm, hmu_v', hBv'⟩ := h_take
            obtain ⟨xv', rfl⟩ := hmu_v'
            exact ⟨fun v hsv hvu => by
                have hv_not_cut : v ∉ g.val.cut := by
                  intro hv_in
                  exact hmin_not_cut (g.val.downward_closed v (min z₁ z₂) hv_in (le_of_lt hsv))
                have hv_above_g : @LT.lt (ExtendedCarrier M atomMap r)
                    extendedLinearOrder.toLT (Sum.inr g) (Sum.inl v) :=
                  ⟨hv_not_cut, fun h => hv_not_cut h⟩
                exact (ihA v).mp (hA (extendPoint v) hv_above_g
                  ((extendPoint_lt_iff v u).mpr hvu) ⟨v, rfl⟩),
              xv', (extendPoint_lt_iff u xv').mp huv',
                (extendPoint_lt_iff xv' m).mp hv'm,
                fun h => hBv' ((ihB xv').mpr h)⟩
        · -- Fail
          exact ⟨uf, lt_of_le_of_lt (min_le_left z₁ z₂) hz₁_uf,
            (extendPoint_lt_iff uf m).mp hum_fail,
            fun h => hB_fail ((ihB uf).mpr h)⟩
        · -- Init
          exact ⟨ui, lt_of_le_of_lt (min_le_right z₁ z₂) hz₂_ui,
            (extendPoint_lt_iff ui m).mp hum_init,
            fun v hvu hvm => (ihB v).mp (hB_init (extendPoint v)
              ((extendPoint_lt_iff ui v).mpr hvu) ((extendPoint_lt_iff v m).mpr hvm) ⟨v, rfl⟩)⟩
    · -- mpr: standard → mu-relativized
      intro ⟨s, hsm, h_body, ⟨uf, hsuf, hufm, hBuf⟩, ⟨ui, hsui, huim, hBui⟩⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff s m).mpr hsm, ?_, ?_, ?_⟩
      · intro u hsu hum hmu_holds
        obtain ⟨u', rfl⟩ := hmu_holds
        have hsu' : s < u' := (extendPoint_lt_iff s u').mp hsu
        have hu'm : u' < m := (extendPoint_lt_iff u' m).mp hum
        have h_disj := h_body u' hsu' hu'm
        cases h_disj with
        | inl h =>
          left
          obtain ⟨v, hvu, hBv⟩ := h
          exact ⟨extendPoint v, (extendPoint_lt_iff v u').mpr hvu, ⟨v, rfl⟩,
            fun w hvw hwm hw_mu => by
              obtain ⟨w', rfl⟩ := hw_mu
              exact (ihB w').mpr (hBv w' ((extendPoint_lt_iff v w').mp hvw)
                ((extendPoint_lt_iff w' m).mp hwm))⟩
        | inr h =>
          right
          obtain ⟨hA, v', hu'v', hv'm, hBv'⟩ := h
          exact ⟨fun v hsv hvu hv_mu => by
              obtain ⟨v', rfl⟩ := hv_mu
              exact (ihA v').mpr (hA v' ((extendPoint_lt_iff s v').mp hsv)
                ((extendPoint_lt_iff v' u').mp hvu)),
            extendPoint v', (extendPoint_lt_iff u' v').mpr hu'v',
              (extendPoint_lt_iff v' m).mpr hv'm, ⟨v', rfl⟩,
              fun h => hBv' ((ihB v').mp h)⟩
      · exact ⟨extendPoint uf, (extendPoint_lt_iff s uf).mpr hsuf,
          (extendPoint_lt_iff uf m).mpr hufm, ⟨uf, rfl⟩,
          fun h => hBuf ((ihB uf).mp h)⟩
      · exact ⟨extendPoint ui, (extendPoint_lt_iff s ui).mpr hsui,
          (extendPoint_lt_iff ui m).mpr huim, ⟨ui, rfl⟩,
          fun v huv hvm hv_mu => by
            obtain ⟨v', rfl⟩ := hv_mu
            exact (ihB v').mpr (hBui v' ((extendPoint_lt_iff ui v').mp huv)
              ((extendPoint_lt_iff v' m).mp hvm))⟩
  | std_untl A B ihA ihB =>
    -- Standard Until at an actual point: same structure as temporal_truth_mu_at_point untl case
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    constructor
    · intro ⟨s, hms, hmu, hAs, hBu⟩
      obtain ⟨s', rfl⟩ := hmu
      have hms' : m < s' := (extendPoint_lt_iff m s').mp hms
      exact ⟨s', hms', (ihA s').mp hAs, fun u hmu' hus =>
        (ihB u).mp (hBu (extendPoint u) ((extendPoint_lt_iff m u).mpr hmu')
          ((extendPoint_lt_iff u s').mpr hus) ⟨u, rfl⟩)⟩
    · intro ⟨s, hms, hAs, hBu⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff m s).mpr hms, ⟨s, rfl⟩,
        (ihA s).mpr hAs, fun u hmu hus hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihB u').mpr (hBu u' ((extendPoint_lt_iff m u').mp hmu)
        ((extendPoint_lt_iff u' s).mp hus))
  | std_snce A B ihA ihB =>
    -- Standard Since at an actual point: same structure as temporal_truth_mu_at_point snce case
    simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
    constructor
    · intro ⟨s, hsm, hmu, hAs, hBu⟩
      obtain ⟨s', rfl⟩ := hmu
      have hsm' : s' < m := (extendPoint_lt_iff s' m).mp hsm
      exact ⟨s', hsm', (ihA s').mp hAs, fun u hsu hum =>
        (ihB u).mp (hBu (extendPoint u) ((extendPoint_lt_iff s' u).mpr hsu)
          ((extendPoint_lt_iff u m).mpr hum) ⟨u, rfl⟩)⟩
    · intro ⟨s, hsm, hAs, hBu⟩
      refine ⟨extendPoint s, (extendPoint_lt_iff s m).mpr hsm, ⟨s, rfl⟩,
        (ihA s).mpr hAs, fun u hsu hum hmu_holds => ?_⟩
      obtain ⟨u', rfl⟩ := hmu_holds
      exact (ihB u').mpr (hBu u' ((extendPoint_lt_iff s u').mp hsu)
        ((extendPoint_lt_iff u' m).mp hum))

/-! ### Gap Uniqueness for Lemma 9

Infrastructure for the gap detection correctness theorem. The key fact:
given D, m, there is at most one gap γ > m with gap_definable_on_left D
and D holding at all actual points between m and γ. This uses the
D-between condition to rule out multiple gaps.
-/

/-- Two gaps satisfying the Lemma 9 conditions for the same D and m must be equal.
    The key property: D holds at all actual points u with m < u and u ∈ γ.cut.
    If γ₁.cut ⊊ γ₂.cut, elements of γ₂.cut \ γ₁.cut are in γ₁.complement with D
    holding (by γ₂'s D-between condition), giving an initial segment of γ₁.complement
    where D holds, contradicting γ₁ being D-definable on the left. -/
theorem gap_detection_unique {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {γ₁ γ₂ : Gap M.carrier} {D : StaviFormula} {m : M.carrier}
    (h₁_def : gap_definable_on_left M atomMap γ₁ D)
    (h₂_def : gap_definable_on_left M atomMap γ₂ D)
    (h₁_bet : ∀ u : M.carrier, m < u → u ∈ γ₁.cut →
      stavi_temporal_truth M atomMap u D)
    (h₂_bet : ∀ u : M.carrier, m < u → u ∈ γ₂.cut →
      stavi_temporal_truth M atomMap u D)
    (hm₁ : m ∈ γ₁.cut)
    (hm₂ : m ∈ γ₂.cut) :
    γ₁ = γ₂ := by
  apply gap_ext
  by_contra hne
  -- WLOG γ₁.cut ⊊ γ₂.cut
  wlog h : ¬(γ₂.cut ⊆ γ₁.cut) with H
  · push_neg at hne
    rcases gap_cuts_total γ₁ γ₂ with hsub | hsub
    · exact h fun h' => hne (Set.Subset.antisymm hsub h')
    · exact H h₂_def h₁_def h₂_bet h₁_bet hm₂ hm₁ (Ne.symm hne)
        (fun h' => hne (Set.Subset.antisymm hsub h').symm)
  -- ∃ x ∈ γ₂.cut \ γ₁.cut
  obtain ⟨x, hx₂, hx₁⟩ := Set.not_subset.mp h
  -- γ₁ D-def-left: no initial segment of γ₁.complement has D
  obtain ⟨_, h_no_init⟩ := h₁_def
  -- Derive contradiction: D holds at an initial segment of γ₁.complement
  apply h_no_init
  -- Witness: x ∉ γ₁.cut, and D at all u ∉ γ₁.cut with u ≤ x
  refine ⟨x, hx₁, fun u hu_not_in hu_le => ?_⟩
  -- u ∉ γ₁.cut, so u > m (since m ∈ γ₁.cut and complement elements are above cut)
  have hmu : m < u := by
    by_contra h_not
    push_neg at h_not
    exact hu_not_in (γ₁.downward_closed m u hm₁ h_not)
  -- u ≤ x ∈ γ₂.cut, so u ∈ γ₂.cut by downward-closure
  have hu_in_2 : u ∈ γ₂.cut := γ₂.downward_closed x u hx₂ hu_le
  -- D(u) by the D-between condition for γ₂
  exact h₂_bet u hmu hu_in_2

/-! ### Core Gap Detection Helper: U'(X, D) at actual points

The fundamental connection between U'(X, D) evaluated at an actual point m
and the existence of a D-defined gap. This is the linchpin of Lemma 9:
all temporal cases of left_formula reduce to applications of this lemma.

**Forward direction** (U' → gap exists):
From U'(X, D)(m) with FO-table witness s, the gap γ is defined as the
boundary where D transitions from holding to failing in (m, s).
Gap cut = {x | ∀ u, m < u → u ≤ x → D(u)}.

**Backward direction** (gap → U'):
Given γ with gap conditions, choose s = some point in complement above γ
where ¬D holds. The FO table conditions follow from the gap axioms.
-/

/-- Core helper: U'(X, D) at an actual point m in M_r detects a D-defined
    gap γ > m where X holds at all complement points of γ below some bound,
    with D holding on all actual points between m and γ.
    This is the "engine" behind all temporal cases of Lemma 9.

    Note: The conclusion provides X at complement points (actual points above γ)
    rather than X^mu(γ), because atoms evaluate to False at gaps. Callers that
    need X^mu(γ) for temporal X can derive it from complement-point truth via
    the structure of temporal evaluation at gaps. -/
theorem stavi_untl_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (X D : StaviFormula) (hD : stavi_depth D ≤ r) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (.stavi_untl X D) ↔
    (∃ (γ : RDefinableGap M atomMap r) (s_bound : M.carrier),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m < Sum.inr γ ∧
      s_bound ∉ γ.val.cut ∧
      gap_definable_on_left M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      (∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
        stavi_temporal_truth M atomMap u X)) := by
  -- Convert LHS from mu-relativized at actual point to standard evaluation
  rw [stavi_truth_mu_at_point m (.stavi_untl X D)]
  simp only [stavi_temporal_truth]
  -- Now LHS is the FO table: ∃ s > m, conditions (1)(2)(3)
  -- RHS is: ∃ γ, m < γ ∧ gap_definable_on_left γ D ∧ D-between(m,γ) ∧ X^mu(γ)
  constructor
  · -- **Forward direction** (FO table → gap):
    intro ⟨s, hms, h_body, ⟨u_fail, hmu_fail, hus_fail, hD_fail⟩,
           ⟨u_init, hmu_init, hus_init, hD_init⟩⟩
    -- Define gap cut via D-cofinality: x ∈ cut iff at every u ∈ (m, x],
    -- ∃ v > u with D on all of (m, v). Ensures cut has no sup in itself.
    let cut : Set M.carrier :=
      {x | ∀ u, m < u → u ≤ x →
        ∃ v, u < v ∧ ∀ w, m < w → w < v → stavi_temporal_truth M atomMap w D}
    have hm_in_cut : m ∈ cut :=
      fun u hmu hum => absurd (lt_of_lt_of_le hmu hum) (lt_irrefl m)
    have hu_fail_not_cut : u_fail ∉ cut := by
      intro h; obtain ⟨v, hfv, hDv⟩ := h u_fail hmu_fail le_rfl
      exact hD_fail (hDv u_fail hmu_fail hfv)
    have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
      intro x hx; by_contra h; push_neg at h
      exact hu_fail_not_cut (fun u hmu huf => hx u hmu (le_trans huf h))
    have h_cut_lt_s : ∀ x ∈ cut, x < s :=
      fun x hx => lt_trans (h_cut_lt_uf x hx) hus_fail
    have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
      fun x y hx hyx u hmu huy => hx u hmu (le_trans huy hyx)
    have h_proper : cut ≠ Set.univ := by
      intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
    -- Key: condition (1) right disjunct fails when all points below u are cofinal
    have h_cofinal_propagate :
        ∀ u, m < u → u < s →
        (∀ w, m < w → w < u →
          ∃ v, w < v ∧ ∀ z, m < z → z < v → stavi_temporal_truth M atomMap z D) →
        ∃ v, u < v ∧ ∀ z, m < z → z < v → stavi_temporal_truth M atomMap z D := by
      intro u hmu hus h_below
      cases h_body u hmu hus with
      | inl h => exact h
      | inr h =>
        obtain ⟨_, v', hmv', hv'u, hDv'⟩ := h
        obtain ⟨v₂, hv'v₂, hDv₂⟩ := h_below v' hmv' hv'u
        exact absurd (hDv₂ v' hmv' hv'v₂) hDv'
    have hu_init_cut : u_init ∈ cut := by
      intro u hmu huu_init
      exact h_cofinal_propagate u hmu (lt_of_le_of_lt huu_init hus_init)
        (fun w hmw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
          fun z hmz hz_init => hD_init z hmz hz_init⟩)
    have h_D_at_cut : ∀ u, m < u → u ∈ cut → stavi_temporal_truth M atomMap u D := by
      intro u hmu hu_cut
      obtain ⟨v, huv, hDv⟩ := hu_cut u hmu le_rfl
      exact hDv u hmu huv
    -- Cut has no supremum in cut
    have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
      intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
      have hmp : m < p := lt_of_lt_of_le hmu_init (h_ub hu_init_cut)
      obtain ⟨v, hpv, hDv⟩ := hp_cut p hmp le_rfl
      have hvs : v < s := by
        by_contra h; push_neg at h
        exact hD_fail (hDv u_fail hmu_fail (lt_of_lt_of_le hus_fail h))
      have hv_cut : v ∈ cut := by
        intro u hmu huv
        rcases eq_or_lt_of_le huv with rfl | huv'
        · -- u = v (renamed), need cofinal at u
          exact h_cofinal_propagate u (lt_trans hmp hpv) hvs
            (fun w hmw hwu => ⟨u, hwu, hDv⟩)
        · exact ⟨v, huv', hDv⟩
      exact not_le.mpr hpv (h_ub hv_cut)
    -- Complement has no minimum
    have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
      intro ⟨b, hb_not, hb_min⟩
      have hmb : m < b := by
        by_contra h; push_neg at h; exact hb_not (h_dc m b hm_in_cut h)
      have hbs : b < s := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hus_fail
      have h_below_b : ∀ y, y < b → y ∈ cut := by
        intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
      cases h_body b hmb hbs with
      | inl h_cof =>
        exact hb_not (fun u hmu hub => by
          rcases eq_or_lt_of_le hub with rfl | hub'
          · exact h_cof
          · exact (h_below_b u hub') u hmu le_rfl)
      | inr h =>
        obtain ⟨_, v', hmv', hv'b, hDv'⟩ := h
        obtain ⟨v₂, hv'v₂, hDv₂⟩ := (h_below_b v' hv'b) v' hmv' le_rfl
        exact hDv' (hDv₂ v' hmv' hv'v₂)
    -- Construct the Gap
    let γ_gap : Gap M.carrier :=
      ⟨cut, ⟨m, hm_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
    -- gap_definable_on_left: D holds on final segment of cut (witness: m),
    -- and D does NOT hold on any initial segment of complement.
    have h_no_init_compl : ¬∃ t, t ∉ cut ∧
        ∀ u, u ∉ cut → u ≤ t → stavi_temporal_truth M atomMap u D := by
      intro ⟨t, ht_not, hDt⟩
      have hmt : m < t := by
        by_contra h; push_neg at h; exact ht_not (h_dc m t hm_in_cut h)
      have hts : t < s := by
        by_contra h; push_neg at h
        exact hD_fail (hDt u_fail hu_fail_not_cut (le_trans (le_of_lt hus_fail) h))
      -- Show t ∈ cut by showing cofinal at every u ∈ (m, t].
      -- For any u ∈ (m, t] with u < s, condition (1) right disjunct fails:
      -- any ¬D witness v' ∈ (m, u) has D(v') (from h_D_at_cut or hDt). So left holds.
      suffices t ∈ cut from ht_not this
      intro u hmu hut
      have hus : u < s := lt_of_le_of_lt hut hts
      exact h_cofinal_propagate u hmu hus (fun w hmw hwu => by
        have hws : w < s := lt_trans hwu hus
        exact h_cofinal_propagate w hmw hws (fun z hmz hzw => by
          have hzs : z < s := lt_trans hzw hws
          -- z ∈ (m, s). Right disjunct requires ¬D at v' ∈ (m, z).
          -- But v' < z < w < u ≤ t, so D(v') from cut or complement.
          cases h_body z hmz hzs with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hmv', hv'z, hDv'⟩ := h
            have : stavi_temporal_truth M atomMap v' D := by
              by_cases hv'_cut : v' ∈ cut
              · exact h_D_at_cut v' hmv' hv'_cut
              · exact hDt v' hv'_cut (le_trans (le_of_lt hv'z)
                  (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
            exact absurd this hDv'))
    have h_def_left : gap_definable_on_left M atomMap γ_gap D :=
      ⟨⟨u_init, hu_init_cut, fun u hmu hu_cut =>
        h_D_at_cut u (lt_of_lt_of_le hmu_init hmu) hu_cut⟩, h_no_init_compl⟩
    -- r-definability: D has depth ≤ r and defines the gap on the left
    have h_r_def : r_definable_gap M atomMap γ_gap r :=
      ⟨D, hD, Or.inl h_def_left⟩
    -- Package as RDefinableGap
    let γ_rdef : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
    refine ⟨γ_rdef, s, ?_, ?_, ?_, ?_, ?_⟩
    · -- extendPoint m < Sum.inr γ_rdef ↔ m ∈ cut (for point vs gap, < ↔ ∈ cut)
      constructor
      · exact hm_in_cut
      · intro h; exact h hm_in_cut
    · -- s ∉ cut: s is a complement point (cut points are all < s)
      intro hs_cut; exact not_lt.mpr le_rfl (h_cut_lt_s s hs_cut)
    · -- gap_definable_on_left M atomMap γ_rdef.val D
      exact h_def_left
    · -- D-between: ∀ u, m < u → u ∈ cut → D^mu(u)
      intro u hmu hu_cut
      exact (stavi_truth_mu_at_point u D).mpr
        (h_D_at_cut u hmu hu_cut)
    · -- X at complement points below s:
      -- For any complement point u < s, the right disjunct of condition (1)
      -- at a smaller complement point u₀ < u gives X at (u₀, s) ⊇ {u}.
      intro u hu_not_cut hus
      -- u ∉ cut, so m < u (complement points are above cut points, m ∈ cut)
      have hmu : m < u := by
        by_contra h; push_neg at h; exact hu_not_cut (h_dc m u hm_in_cut h)
      -- Since complement has no minimum, ∃ u₀ < u with u₀ ∉ cut
      have ⟨u₀, hu₀_not, hu₀u⟩ : ∃ u₀, u₀ ∉ cut ∧ u₀ < u := by
        by_contra h_all; push_neg at h_all
        exact h_comp_no_min ⟨u, hu_not_cut, fun y hy => h_all y hy⟩
      have hmu₀ : m < u₀ := by
        by_contra h; push_neg at h; exact hu₀_not (h_dc m u₀ hm_in_cut h)
      have hu₀s : u₀ < s := lt_trans hu₀u hus
      -- At complement point u₀: left disjunct would imply u₀ ∈ cut, so right holds
      have h_right_u₀ :
          (∀ v, u₀ < v → v < s → stavi_temporal_truth M atomMap v X) ∧
          ∃ v', m < v' ∧ v' < u₀ ∧ ¬stavi_temporal_truth M atomMap v' D := by
        cases h_body u₀ hmu₀ hu₀s with
        | inl h_left =>
          -- Left disjunct: ∃ v > u₀, D on (m, v). This implies u₀ ∈ cut.
          exfalso; apply hu₀_not
          obtain ⟨v, hu₀v, hDv⟩ := h_left
          intro u' hmu' hu'u₀
          exact ⟨v, lt_of_le_of_lt hu'u₀ hu₀v, hDv⟩
        | inr h_right => exact h_right
      -- From right disjunct at u₀: X at all points in (u₀, s), including u
      exact h_right_u₀.1 u hu₀u hus
  · -- **Backward direction** (gap → FO table):
    intro ⟨γ, s_bound, hm_lt_γ, hs_bound_not, h_def_left, h_D_bet, hX_compl⟩
    have hm_in_cut : m ∈ γ.val.cut :=
      (extendPoint_le_gap_iff m γ).mp (le_of_lt hm_lt_γ)
    obtain ⟨⟨t_cut, ht_in, ht_D_final⟩, h_no_init_seg⟩ := h_def_left
    -- Helper: from negation of initial segment condition, get ¬D witnesses
    have h_neg_init : ∀ t, t ∉ γ.val.cut →
        ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬stavi_temporal_truth M atomMap w D := by
      intro t ht; by_contra h_all; push_neg at h_all
      exact h_no_init_seg ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
    -- Helper: complement points are above all cut points (including m)
    have h_compl_gt_m : ∀ x, x ∉ γ.val.cut → m < x := by
      intro x hx; by_contra h; push_neg at h
      exact hx (γ.val.downward_closed m x hm_in_cut h)
    -- Complement is non-empty (cut is proper)
    have h_compl_ne : ∃ x, x ∉ γ.val.cut := by
      by_contra h_all; push_neg at h_all
      exact γ.val.proper (Set.eq_univ_iff_forall.mpr h_all)
    -- Use s_bound as s₀ (a complement point)
    refine ⟨s_bound, h_compl_gt_m s_bound hs_bound_not, ?_, ?_, ?_⟩
    · -- Condition (1): ∀ u ∈ (m, s_bound), disjunction
      intro u hmu hus
      by_cases hu_cut : u ∈ γ.val.cut
      · -- u ∈ cut: first disjunct — D cofinal above u
        left
        -- Since u ∈ cut and cut has no sup, ∃ y ∈ cut with y > u
        have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
          by_contra h_all; push_neg at h_all
          exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
        exact ⟨y, huy, fun w hmw hwy =>
          (stavi_truth_mu_at_point w D).mp
            (h_D_bet w hmw (γ.val.downward_closed y w hy_in (le_of_lt hwy)))⟩
      · -- u ∉ cut: second disjunct — X on (u, s_bound) and ¬D witness below u
        right
        refine ⟨?_, ?_⟩
        · -- ∀ v, u < v → v < s_bound → X(v)
          -- All points between two complement points are complement (upward-closed).
          -- hX_compl gives X at complement points below s_bound.
          intro v huv hvs
          -- v is between u (complement) and s_bound (complement), so v ∉ cut
          have hv_not : v ∉ γ.val.cut := by
            intro hv_in
            exact hu_cut (γ.val.downward_closed v u hv_in (le_of_lt huv))
          exact hX_compl v hv_not hvs
        · -- ∃ v', m < v' ∧ v' < u ∧ ¬D(v')
          -- complement_no_min gives y < u with y ∉ cut, then h_neg_init gives ¬D witness
          have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact ⟨w, h_compl_gt_m w hw_not, lt_of_le_of_lt hwy hyu, hDw⟩
    · -- Condition (2): ∃ u ∈ (m, s_bound), ¬D(u)
      -- complement_no_min: s_bound is not the minimum, so ∃ y < s_bound in complement
      have ⟨y, hy_not, hys⟩ : ∃ y, y ∉ γ.val.cut ∧ y < s_bound := by
        by_contra h_all; push_neg at h_all
        exact γ.val.complement_no_min ⟨s_bound, hs_bound_not, fun z hz => h_all z hz⟩
      -- h_neg_init gives ¬D witness at or below y
      obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
      exact ⟨w, h_compl_gt_m w hw_not, lt_of_le_of_lt hwy hys, hDw⟩
    · -- Condition (3): ∃ u ∈ (m, s_bound), D on (m, u)
      -- From no_sup: ∃ y ∈ cut with y > m
      have ⟨y, hy_in, hmy⟩ : ∃ y ∈ γ.val.cut, m < y := by
        by_contra h_all; push_neg at h_all
        exact γ.val.no_sup ⟨m, ⟨fun x hx => h_all x hx, fun b hb => hb hm_in_cut⟩, hm_in_cut⟩
      -- y < s_bound since y ∈ cut, s_bound ∉ cut, and cut is downward-closed
      have hys : y < s_bound := by
        by_contra h; push_neg at h
        exact hs_bound_not (γ.val.downward_closed y s_bound hy_in h)
      exact ⟨y, hmy, hys, fun v hmv hvy =>
        (stavi_truth_mu_at_point v D).mp
          (h_D_bet v hmv (γ.val.downward_closed y v hy_in (le_of_lt hvy)))⟩

-- std_untl_gap_detection: DELETED (provably false).
-- U(X,D) has no D-failure condition, so gap_definable_on_left fails for D = top.
-- Backward direction also fails: complement points have X but D fails near gap.
-- Affected cases in left/right_formula_gap_detection proved directly instead.

/-! ### Lemma 9: Gap Detection Correctness (GHR93)

The crucial bridge: `left_formula(A,D)` evaluated at an actual point m
detects whether there is a D-defined gap gamma > m where A^mu holds at gamma.

Precisely: for an actual point m in M, and a gap gamma in M_r:

  stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula A D) ↔
    ∃ (γ : RDefinableGap M atomMap r),
      extendPoint m < Sum.inr γ ∧
      gap_definable_on_left M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r (extendPoint u) D) ∧
      stavi_temporal_truth_mu M atomMap r (Sum.inr γ) A
-/

/--
**GHR93 Lemma 9** (Gap detection correctness, left direction):
left_formula(A, D) evaluated at an actual point m in M_r detects
whether A^mu holds at a gap gamma that is D-defined on the left,
with gamma > m and D holding at all actual points between m and gamma.

This is the core of the gap detection machinery: it converts a property
of a gap (A^mu holds there, gap is D-defined) into a temporal formula
evaluable at actual points.

NOTE: The full proof of Lemma 9 requires careful case analysis on the
structure of A, connecting the syntactic left_formula definition with
the semantic gap properties. The S/S' cases use `std_untl`/`std_snce`
constructors to correctly represent standard Until/Since of Stavi-enriched
subformulas. This is sorry'd pending the full game-theoretic proof in
Phase 4C.
-/
theorem left_formula_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (A D : StaviFormula) (hD : stavi_depth D ≤ r) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula A D) ↔
    (∃ (γ : RDefinableGap M atomMap r),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m < Sum.inr γ ∧
      gap_definable_on_left M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      stavi_temporal_truth_mu M atomMap r (Sum.inr γ) A) := by
  induction A generalizing m with
  | base φ =>
    -- left_formula (.base φ) D = left_formula_base D φ
    -- This case requires sub-induction on the Formula φ.
    -- All sub-cases reduce to the same pattern as the outer StaviFormula cases
    -- because left_formula_base maps atom/bot/box to .base .bot (both sides False)
    -- and imp/untl/snce to formulas that mirror the neg/conj/stavi_untl patterns.
    -- For now we handle this via a sub-induction on φ.
    simp only [left_formula]
    induction φ with
    | atom a =>
      -- left_formula_base D (atom a) = .base .bot
      simp only [left_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | bot =>
      -- left_formula_base D bot = .base .bot
      simp only [left_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | box f =>
      -- left_formula_base D (box f) = .base .bot
      simp only [left_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | imp f g ih_f ih_g =>
      -- left_formula_base D (f.imp g) = U'(⊤,D) ∧ ¬(left_base(f) ∧ (U'(⊤,D) ∧ ¬left_base(g)))
      -- The neg/conj outer cases handle this pattern using gap_detection_unique.
      -- imp = ¬(f ∧ ¬g), so (.base (f.imp g))^mu at γ = (f^mu → g^mu) at γ.
      -- Strategy: use the proved neg and conj outer-case patterns with gap uniqueness.
      constructor
      · -- Forward direction
        intro hLHS
        -- Unfold left_formula_base
        simp only [left_formula_base] at hLHS
        -- hLHS : stavi_temporal_truth_mu ... (.conj (.stavi_untl (.base top) D) (.neg (.conj (left_formula_base D f) (.conj (.stavi_untl (.base top) D) (.neg (left_formula_base D g))))))
        simp only [stavi_temporal_truth_mu] at hLHS
        obtain ⟨hU, hNeg⟩ := hLHS
        -- Extract gap from U'(⊤,D)(m)
        have hU' : stavi_temporal_truth_mu M atomMap r (extendPoint m)
            (.stavi_untl (.base Formula.top) D) := by
          simp only [stavi_temporal_truth_mu]; exact hU
        obtain ⟨γ, _s_bound, hγ_lt, _hs_not, hγ_def, hγ_bet, _⟩ :=
          (stavi_untl_gap_detection (.base Formula.top) D hD m).mp hU'
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        -- Need: (.base (f.imp g))^mu(γ) = temporal_truth_mu M atomMap r (Sum.inr γ) (f.imp g)
        simp only [stavi_temporal_truth_mu, temporal_truth_mu]
        intro hf_at_γ
        -- From f^mu(γ), by IH backward: left_formula_base D f at m
        have hLeft_f : stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula_base D f) :=
          ih_f.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hf_at_γ⟩
        -- From ¬(left_base(f) ∧ U'(⊤,D) ∧ ¬left_base(g)) and left_base(f) and U'(⊤,D): left_base(g)
        have hLeft_g : stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula_base D g) := by
          by_contra h
          exact hNeg ⟨hLeft_f, hU, h⟩
        -- From left_base(g), by IH forward: ∃ γ', ... ∧ g^mu(γ')
        obtain ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hg_at_γ'⟩ := ih_g.mp hLeft_g
        -- γ = γ' by gap_detection_unique
        have hm_in : m ∈ γ.val.cut :=
          (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
        have hm_in' : m ∈ γ'.val.cut :=
          (extendPoint_le_gap_iff m γ').mp (le_of_lt hγ'_lt)
        have hγ_bet_std : ∀ u, m < u → u ∈ γ.val.cut →
            stavi_temporal_truth M atomMap u D :=
          fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_in)
        have hγ'_bet_std : ∀ u, m < u → u ∈ γ'.val.cut →
            stavi_temporal_truth M atomMap u D :=
          fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ'_bet u hmu hu_in)
        have heq : γ.val = γ'.val :=
          gap_detection_unique hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_in hm_in'
        rw [Subtype.ext heq]
        exact hg_at_γ'
      · -- Backward direction
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hfg_at_γ⟩
        simp only [left_formula_base, stavi_temporal_truth_mu]
        constructor
        · -- U'(⊤,D)(m): from γ, construct stavi_untl_gap_detection
          have h_compl : ∃ x, x ∉ γ.val.cut := by
            by_contra h; push_neg at h; exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
          obtain ⟨s_b, hs_b⟩ := h_compl
          have hTop_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_b →
              stavi_temporal_truth M atomMap u (.base Formula.top) := by
            intro u _ _
            simp only [stavi_temporal_truth, temporal_truth, Formula.top]; exact id
          have := (stavi_untl_gap_detection (.base Formula.top) D hD m).mpr
            ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_compl⟩
          simp only [stavi_temporal_truth_mu] at this
          exact this
        · -- ¬(left_base(f) ∧ U'(⊤,D)(m) ∧ ¬left_base(g))
          intro ⟨hLf, _, hNLg⟩
          obtain ⟨γ₁, hγ₁_lt, hγ₁_def, hγ₁_bet, hf_at_γ₁⟩ := ih_f.mp hLf
          have hm_in : m ∈ γ.val.cut :=
            (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
          have hm_in₁ : m ∈ γ₁.val.cut :=
            (extendPoint_le_gap_iff m γ₁).mp (le_of_lt hγ₁_lt)
          have hγ_bet_std : ∀ u, m < u → u ∈ γ.val.cut →
              stavi_temporal_truth M atomMap u D :=
            fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_in)
          have hγ₁_bet_std : ∀ u, m < u → u ∈ γ₁.val.cut →
              stavi_temporal_truth M atomMap u D :=
            fun u hmu hu_in => (stavi_truth_mu_at_point u D).mp (hγ₁_bet u hmu hu_in)
          have heq : γ₁.val = γ.val :=
            gap_detection_unique hγ₁_def hγ_def hγ₁_bet_std hγ_bet_std hm_in₁ hm_in
          -- f → g at γ, so g^mu(γ)
          simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hfg_at_γ
          have hg_at_γ := hfg_at_γ ((Subtype.ext heq) ▸ hf_at_γ₁)
          exact hNLg (ih_g.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hg_at_γ⟩)
    | untl f g _ _ =>
      -- left_formula_base D (untl f g) = .stavi_untl (.conj (.base g) (.base (untl f g))) D
      -- This mirrors the stavi_untl outer case
      simp only [left_formula_base]
      rw [stavi_untl_gap_detection (.conj (.base g) (.base (.untl f g))) D hD m]
      constructor
      · -- Forward: complement-point truth of g ∧ U(f,g) → U(f,g)^mu at γ
        intro ⟨γ, s_bound, hγ_lt, hs_not, hγ_def, hγ_bet, hX_compl⟩
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        -- hX_compl: ∀ u ∉ γ.cut, u < s_bound → g(u) ∧ U(f,g)(u)
        -- Need: U(f,g)^mu at Sum.inr γ
        simp only [stavi_temporal_truth_mu, stavi_temporal_truth, temporal_truth_mu]
        -- U(f,g)^mu at γ: ∃ s > γ, mu_holds s ∧ f^mu(s) ∧ ∀ v ∈ (γ,s), mu_holds v → g^mu(v)
        -- Pick a complement point u₀ above γ where U(f,g) holds
        have ⟨u₀, hu₀_not, hu₀s⟩ : ∃ u₀, u₀ ∉ γ.val.cut ∧ u₀ < s_bound := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨s_bound, hs_not, fun z hz => h_all z hz⟩
        have hX_u₀ := hX_compl u₀ hu₀_not hu₀s
        simp only [stavi_temporal_truth, temporal_truth] at hX_u₀
        obtain ⟨hg_u₀, s₁, hu₀s₁, hf_s₁, hg_between⟩ := hX_u₀
        -- s₁ ∉ γ.cut (since u₀ ∉ γ.cut and u₀ < s₁, and cut is downward closed)
        have hs₁_not : s₁ ∉ γ.val.cut := by
          intro h; exact hu₀_not (γ.val.downward_closed s₁ u₀ h (le_of_lt hu₀s₁))
        refine ⟨extendPoint s₁, ⟨hs₁_not, hs₁_not⟩, ⟨s₁, rfl⟩,
          (temporal_truth_mu_at_point s₁ f).mpr hf_s₁, fun v hγv hvs hmu => ?_⟩
        obtain ⟨v₀, rfl⟩ := hmu
        have hv₀_not : v₀ ∉ γ.val.cut := by
          intro h; exact not_lt.mpr (show extendPoint v₀ ≤ Sum.inr γ from h) hγv
        have hv₀_s₁ : v₀ < s₁ := (extendPoint_lt_iff v₀ s₁).mp hvs
        apply (temporal_truth_mu_at_point v₀ g).mpr
        by_cases hv_u₀ : u₀ < v₀
        · exact hg_between v₀ hv_u₀ hv₀_s₁
        · push_neg at hv_u₀
          have hv₀_sb : v₀ < s_bound := lt_of_le_of_lt hv_u₀ hu₀s
          exact (hX_compl v₀ hv₀_not hv₀_sb).1
      · -- Backward: U(f,g)^mu at γ → complement-point truth of g ∧ U(f,g)
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
        simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hUA
        obtain ⟨s, hγs, hmu_s, hf_s, hg_mu⟩ := hUA
        obtain ⟨s₁, rfl⟩ := hmu_s
        have hs₁_not : s₁ ∉ γ.val.cut := by
          intro h; exact not_lt.mpr (show extendPoint s₁ ≤ Sum.inr γ from h) hγs
        refine ⟨γ, s₁, hγ_lt, hs₁_not, hγ_def, hγ_bet, fun u hu_not hu_s₁ => ?_⟩
        simp only [stavi_temporal_truth, temporal_truth]
        constructor
        · -- g(u): u is a complement point between γ and s₁
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT (Sum.inr γ) (extendPoint u) := by
            show u ∉ γ.val.cut ∧ ¬(u ∈ γ.val.cut); exact ⟨hu_not, hu_not⟩
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hγu ((extendPoint_lt_iff u s₁).mpr hu_s₁) ⟨u, rfl⟩)
        · -- U(f,g)(u): use s₁ as witness
          refine ⟨s₁, hu_s₁, (temporal_truth_mu_at_point s₁ f).mp hf_s, fun v huv hvs₁ => ?_⟩
          have hv_not : v ∉ γ.val.cut := by
            intro h; exact hu_not (γ.val.downward_closed v u h (le_of_lt huv))
          have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT (Sum.inr γ) (extendPoint v) := by
            show v ∉ γ.val.cut ∧ ¬(v ∈ γ.val.cut); exact ⟨hv_not, hv_not⟩
          exact (temporal_truth_mu_at_point v g).mp
            (hg_mu (extendPoint v) hγv ((extendPoint_lt_iff v s₁).mpr hvs₁) ⟨v, rfl⟩)
    | snce f g _ _ =>
      -- left_formula_base D (.snce f g) = .std_untl compound D where
      -- compound = D ∧ g ∧ S(f,g) ∧ U'(⊤, g∧D) ∧ ¬U'(D, g∧D)
      simp only [left_formula_base]
      rw [stavi_truth_mu_at_point m (.std_untl _ D)]
      simp only [stavi_temporal_truth]
      constructor
      · -- Forward: std_untl(compound, D)^mu(m) → gap conditions
        intro ⟨s, hms, hcompound_s, hD_bet⟩
        obtain ⟨hDs, hgs, hSnce_s, hU'_gD_s, hNotU'D_gD_s⟩ := hcompound_s
        obtain ⟨s₁, hss₁, h_body, h_fail, h_init⟩ := hU'_gD_s
        obtain ⟨u_fail, hsu_fail, hu_fail_s₁, hgD_fail⟩ := h_fail
        obtain ⟨u_init, hsu_init, hu_init_s₁, hgD_init⟩ := h_init
        -- Build B∧D-cofinal cut (mirrors stavi_untl_gap_detection)
        let gD : M.carrier → Prop := fun u =>
          temporal_truth M atomMap u g ∧ stavi_temporal_truth M atomMap u D
        let cut : Set M.carrier :=
          {x | ∀ u, s < u → u ≤ x → ∃ v, u < v ∧ ∀ w, s < w → w < v → gD w}
        have hs_in_cut : s ∈ cut :=
          fun u hsu hus => absurd (lt_of_lt_of_le hsu hus) (lt_irrefl s)
        have hu_fail_not_cut : u_fail ∉ cut := by
          intro h; obtain ⟨v, hfv, hgDv⟩ := h u_fail hsu_fail le_rfl
          exact hgD_fail (hgDv u_fail hsu_fail hfv)
        have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
          intro x hx; by_contra h; push_neg at h
          exact hu_fail_not_cut (fun u hsu huf => hx u hsu (le_trans huf h))
        have h_cut_lt_s₁ : ∀ x ∈ cut, x < s₁ :=
          fun x hx => lt_trans (h_cut_lt_uf x hx) hu_fail_s₁
        have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
          fun x y hx hyx u hsu huy => hx u hsu (le_trans huy hyx)
        have h_proper : cut ≠ Set.univ := by
          intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
        have h_cofinal_propagate :
            ∀ u, s < u → u < s₁ →
            (∀ w, s < w → w < u →
              ∃ v, w < v ∧ ∀ z, s < z → z < v → gD z) →
            ∃ v, u < v ∧ ∀ z, s < z → z < v → gD z := by
          intro u hsu hus₁ h_below
          cases h_body u hsu hus₁ with
          | inl h => exact h
          | inr h =>
            obtain ⟨_, v', hsv', hv'u, hgDv'⟩ := h
            obtain ⟨v₂, hv'v₂, hgDv₂⟩ := h_below v' hsv' hv'u
            exact absurd (hgDv₂ v' hsv' hv'v₂) hgDv'
        have hu_init_cut : u_init ∈ cut := by
          intro u hsu huu_init
          exact h_cofinal_propagate u hsu (lt_of_le_of_lt huu_init hu_init_s₁)
            (fun w hsw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
              fun z hsz hz_init => hgD_init z hsz hz_init⟩)
        have h_gD_at_cut : ∀ u, s < u → u ∈ cut → gD u := by
          intro u hsu hu_cut
          obtain ⟨v, huv, hgDv⟩ := hu_cut u hsu le_rfl
          exact hgDv u hsu huv
        have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
          intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
          have hsp : s < p := lt_of_lt_of_le hsu_init (h_ub hu_init_cut)
          obtain ⟨v, hpv, hgDv⟩ := hp_cut p hsp le_rfl
          have hvs₁ : v < s₁ := by
            by_contra h; push_neg at h
            exact hgD_fail (hgDv u_fail hsu_fail (lt_of_lt_of_le hu_fail_s₁ h))
          have hv_cut : v ∈ cut := by
            intro u hsu huv
            rcases eq_or_lt_of_le huv with rfl | huv'
            · exact h_cofinal_propagate u (lt_trans hsp hpv) hvs₁
                (fun w hsw hwu => ⟨u, hwu, hgDv⟩)
            · exact ⟨v, huv', hgDv⟩
          exact not_le.mpr hpv (h_ub hv_cut)
        have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
          intro ⟨b, hb_not, hb_min⟩
          have hsb : s < b := by
            by_contra h; push_neg at h; exact hb_not (h_dc s b hs_in_cut h)
          have hbs₁ : b < s₁ := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hu_fail_s₁
          have h_below_b : ∀ y, y < b → y ∈ cut := by
            intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
          cases h_body b hsb hbs₁ with
          | inl h_cof =>
            exact hb_not (fun u hsu hub => by
              rcases eq_or_lt_of_le hub with rfl | hub'
              · exact h_cof
              · exact (h_below_b u hub') u hsu le_rfl)
          | inr h =>
            obtain ⟨_, v', hsv', hv'b, hgDv'⟩ := h
            obtain ⟨v₂, hv'v₂, hgDv₂⟩ := (h_below_b v' hv'b) v' hsv' le_rfl
            exact hgDv' (hgDv₂ v' hsv' hv'v₂)
        -- Construct the Gap
        let γ_gap : Gap M.carrier :=
          ⟨cut, ⟨s, hs_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
        -- Show D-definable-on-left
        -- Part 1: D cofinal in cut (from gD cofinal → D cofinal)
        have h_D_cofinal_cut : ∃ t, t ∈ γ_gap.cut ∧
            ∀ u, t ≤ u → u ∈ γ_gap.cut → stavi_temporal_truth M atomMap u D :=
          ⟨u_init, hu_init_cut, fun u hu_le hu_cut =>
            (h_gD_at_cut u (lt_of_lt_of_le hsu_init hu_le) hu_cut).2⟩
        -- Part 2a: No initial complement segment with gD
        have h_no_init_compl_gD : ¬∃ t, t ∉ γ_gap.cut ∧
            ∀ u, u ∉ γ_gap.cut → u ≤ t → gD u := by
          intro ⟨t, ht_not, hgDt⟩
          have hst : s < t := by
            by_contra h; push_neg at h; exact ht_not (h_dc s t hs_in_cut h)
          have hts₁ : t < s₁ := by
            by_contra h; push_neg at h
            exact hgD_fail (hgDt u_fail hu_fail_not_cut (le_trans (le_of_lt hu_fail_s₁) h))
          suffices t ∈ cut from ht_not this
          intro u hsu hut
          exact h_cofinal_propagate u hsu (lt_of_le_of_lt hut hts₁)
            (fun w hsw hwu =>
              h_cofinal_propagate w hsw (lt_trans hwu (lt_of_le_of_lt hut hts₁))
                (fun z hsz hzw => by
                  cases h_body z hsz (lt_trans hzw (lt_trans hwu
                      (lt_of_le_of_lt hut hts₁))) with
                  | inl h => exact h
                  | inr h =>
                    obtain ⟨_, v', hsv', hv'z, hgDv'⟩ := h
                    have : gD v' := by
                      by_cases hv'_cut : v' ∈ cut
                      · exact h_gD_at_cut v' hsv' hv'_cut
                      · exact hgDt v' hv'_cut (le_trans (le_of_lt hv'z)
                          (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
                    exact absurd this hgDv'))
        -- D-failure: D fails somewhere in (s, s₁)
        have hD_fails : ∃ u_D, s < u_D ∧ u_D < s₁ ∧
            ¬stavi_temporal_truth M atomMap u_D D := by
          by_contra h_all_D; push_neg at h_all_D
          apply hNotU'D_gD_s
          exact ⟨s₁, hss₁,
            fun u hsu hus₁ => by
              cases h_body u hsu hus₁ with
              | inl h => left; exact h
              | inr h =>
                right
                exact ⟨fun v huv hvs₁ => h_all_D v (lt_trans hsu huv) hvs₁,
                       h.2⟩,
            ⟨u_fail, hsu_fail, hu_fail_s₁, hgD_fail⟩,
            ⟨u_init, hsu_init, hu_init_s₁, hgD_init⟩⟩
        obtain ⟨u_D, hsu_D, hu_D_s₁, hD_fail_D⟩ := hD_fails
        have hu_D_not_cut : u_D ∉ cut := by
          intro h; exact hD_fail_D (h_gD_at_cut u_D hsu_D h).2
        -- Complement points are > all cut points
        have h_compl_gt_cut : ∀ x, x ∉ cut → ∀ y, y ∈ cut → y < x := by
          intro x hx y hy; by_contra h; push_neg at h
          exact hx (h_dc y x hy h)
        -- Part 2b: No initial complement segment with D
        have h_no_init_compl_D : ¬∃ t, t ∉ γ_gap.cut ∧
            ∀ u, u ∉ γ_gap.cut → u ≤ t →
              stavi_temporal_truth M atomMap u D := by
          intro ⟨t, ht_not, hDt⟩
          have hst : s < t := h_compl_gt_cut t ht_not s hs_in_cut
          -- t < u_D (otherwise D(u_D) from hDt)
          have ht_uD : t < u_D := by
            by_contra h; push_neg at h
            exact hD_fail_D (hDt u_D hu_D_not_cut h)
          have hts₁ : t < s₁ := lt_trans ht_uD hu_D_s₁
          -- Construct U'(D, gD)(s) with bound t, contradicting hNotU'D_gD_s
          apply hNotU'D_gD_s
          refine ⟨t, hst, ?_, ?_, ?_⟩
          · -- Condition 1
            intro u hsu hut
            cases h_body u hsu (lt_trans hut hts₁) with
            | inl h => left; exact h
            | inr h =>
              right
              exact ⟨fun v huv hvt => by
                by_cases hv_cut : v ∈ cut
                · exact (h_gD_at_cut v (lt_trans hsu huv) hv_cut).2
                · exact hDt v hv_cut (le_of_lt hvt),
                h.2⟩
          · -- Condition 2: gD fails in (s, t)
            by_contra h_no_fail; push_neg at h_no_fail
            apply h_no_init_compl_gD
            -- All complement points ≤ t have gD? We need a complement point with ¬gD
            -- complement_no_min gives ∃ c < t with c ∉ cut
            obtain ⟨c, hc_not, hct⟩ : ∃ c, c ∉ cut ∧ c < t := by
              by_contra h; push_neg at h
              exact h_comp_no_min ⟨t, ht_not, fun y hy => h y hy⟩
            -- h_no_fail says: ∀ u, s < u → u < t → gD u (no gD failure in (s,t))
            -- c is complement, s < c < t, so gD(c) from h_no_fail
            have hsc : s < c := h_compl_gt_cut c hc_not s hs_in_cut
            have hgDc := h_no_fail c hsc hct
            -- But then c is complement with gD: initial complement has gD
            exact ⟨c, hc_not, fun u hu huc => by
              have hsu' : s < u := h_compl_gt_cut u hu s hs_in_cut
              have hut' : u < t := lt_of_le_of_lt huc hct
              exact h_no_fail u hsu' hut'⟩
          · -- Condition 3: gD initial in (s, t)
            have : u_init < t := h_compl_gt_cut t ht_not u_init hu_init_cut
            exact ⟨u_init, hsu_init, this, hgD_init⟩
        have h_def_left_D : gap_definable_on_left M atomMap γ_gap D :=
          ⟨h_D_cofinal_cut, h_no_init_compl_D⟩
        have h_r_def : r_definable_gap M atomMap γ_gap r :=
          ⟨D, hD, Or.inl h_def_left_D⟩
        let γ : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
        refine ⟨γ, ?_, ?_, ?_, ?_⟩
        · -- extendPoint m < Sum.inr γ: m ∈ cut
          have hm_in : m ∈ cut := h_dc s m hs_in_cut (le_of_lt hms)
          constructor
          · exact hm_in
          · intro h; exact h hm_in
        · exact h_def_left_D
        · -- D^mu at cut points above m
          intro u hmu hu_cut
          by_cases hsu : s < u
          · exact (stavi_truth_mu_at_point u D).mpr (h_gD_at_cut u hsu hu_cut).2
          · push_neg at hsu
            rcases eq_or_lt_of_le hsu with rfl | hus
            · exact (stavi_truth_mu_at_point u D).mpr hDs
            · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hmu hus)
        · -- S(f,g)^mu at γ: use witness from S(f,g)(s)
          simp only [temporal_truth] at hSnce_s
          obtain ⟨q, hqs, hf_q, hg_qs⟩ := hSnce_s
          have hq_cut : q ∈ cut := h_dc s q hs_in_cut (le_of_lt hqs)
          show temporal_truth_mu M atomMap r (Sum.inr γ) (f.snce g)
          exact ⟨extendPoint q, ⟨hq_cut, fun h => h hq_cut⟩, ⟨q, rfl⟩,
            (temporal_truth_mu_at_point q f).mpr hf_q,
            fun u hqu huγ hmu => by
              obtain ⟨p, rfl⟩ := hmu
              apply (temporal_truth_mu_at_point p g).mpr
              have hp_cut : p ∈ cut := huγ.1
              have hqp : q < p := (extendPoint_lt_iff q p).mp hqu
              by_cases hps : p ≤ s
              · rcases eq_or_lt_of_le hps with rfl | hps'
                · exact hgs
                · exact hg_qs p hqp hps'
              · push_neg at hps
                exact (h_gD_at_cut p hps hp_cut).1⟩
      · -- Backward: gap conditions → std_untl(compound, D)^mu(m)
        -- Given D-gap γ with S(f,g)^mu(γ), construct std_untl(compound, D)(m)
        -- where compound = D ∧ g ∧ S(f,g) ∧ U'(⊤, g∧D) ∧ ¬U'(D, g∧D)
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSnce_mu⟩
        -- S(f,g)^mu(γ): ∃ t < γ (mu-point), f^mu(t) ∧ g^mu on (t, γ)
        simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hSnce_mu
        obtain ⟨t_ext, ht_γ, ⟨t_pt, rfl⟩, hf_t, hg_mu⟩ := hSnce_mu
        -- t_pt is in the cut
        have ht_cut : t_pt ∈ γ.val.cut :=
          (extendPoint_le_gap_iff t_pt γ).mp (le_of_lt ht_γ)
        -- m is in the cut
        have hm_cut : m ∈ γ.val.cut :=
          (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
        -- Find a cut point s above both m and t_pt (cut has no sup)
        have ⟨s, hs_cut, hms, hts⟩ : ∃ s, s ∈ γ.val.cut ∧ m < s ∧ t_pt < s := by
          -- Cut has no sup, so there exist cut points above any cut member.
          -- We need one above both m and t_pt.
          -- First get one above m:
          have ⟨s₁, hs₁, hms₁⟩ : ∃ s₁ ∈ γ.val.cut, m < s₁ := by
            by_contra h; push_neg at h
            exact γ.val.no_sup ⟨m, ⟨h, fun _ hb => hb hm_cut⟩, hm_cut⟩
          -- Then get one above max(s₁, t_pt):
          have hmax_cut : max s₁ t_pt ∈ γ.val.cut := by
            rcases le_or_lt s₁ t_pt with h | h
            · simp [max_eq_right h]; exact ht_cut
            · simp [max_eq_left (le_of_lt h)]; exact hs₁
          have ⟨s₂, hs₂, hmax_s₂⟩ : ∃ s₂ ∈ γ.val.cut, max s₁ t_pt < s₂ := by
            by_contra h; push_neg at h
            exact γ.val.no_sup ⟨max s₁ t_pt, ⟨h, fun _ hb => hb hmax_cut⟩, hmax_cut⟩
          exact ⟨s₂, hs₂,
            lt_trans hms₁ (lt_of_le_of_lt (le_max_left s₁ t_pt) hmax_s₂),
            lt_of_le_of_lt (le_max_right s₁ t_pt) hmax_s₂⟩
        -- Properties at s (cut point above m and t_pt):
        -- D(s) from D-between
        have hDs : stavi_temporal_truth M atomMap s D :=
          (stavi_truth_mu_at_point s D).mp (hγ_bet s hms hs_cut)
        -- g(s) from S(f,g)^mu(γ): s is a cut point above t_pt
        have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t_pt) (extendPoint s) :=
          (extendPoint_lt_iff t_pt s).mpr hts
        have hγs' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint s) (Sum.inr γ) := by
          exact ⟨hs_cut, fun h => h hs_cut⟩
        have hgs : temporal_truth M atomMap s g :=
          (temporal_truth_mu_at_point s g).mp
            (hg_mu (extendPoint s) hγs hγs' ⟨s, rfl⟩)
        -- S(f,g)(s): witness t_pt with f(t_pt) and g on (t_pt, s)
        have hSnce_s : temporal_truth M atomMap s (f.snce g) := by
          simp only [temporal_truth]
          refine ⟨t_pt, hts, (temporal_truth_mu_at_point t_pt f).mp hf_t, fun u htu hus => ?_⟩
          have hu_cut : u ∈ γ.val.cut := γ.val.downward_closed s u hs_cut (le_of_lt hus)
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint t_pt) (extendPoint u) :=
            (extendPoint_lt_iff t_pt u).mpr htu
          have huγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint u) (Sum.inr γ) := ⟨hu_cut, fun h => h hu_cut⟩
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hγu huγ ⟨u, rfl⟩)
        -- D on (m, s): all points between m and s are cut points and have D
        have hD_bet_ms : ∀ u, m < u → u < s → stavi_temporal_truth M atomMap u D := by
          intro u hmu hus
          have hu_cut : u ∈ γ.val.cut := γ.val.downward_closed s u hs_cut (le_of_lt hus)
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_cut)
        -- Extract gap definability conditions
        obtain ⟨⟨t_D, ht_D_cut, hD_final⟩, h_no_init_D⟩ := hγ_def
        -- Helper: complement points > cut points
        have h_compl_gt : ∀ x, x ∉ γ.val.cut → ∀ y, y ∈ γ.val.cut → y < x := by
          intro x hx y hy; by_contra h; push_neg at h
          exact hx (γ.val.downward_closed y x hy h)
        -- Helper: ¬D witnesses at complement points
        have h_neg_init : ∀ t, t ∉ γ.val.cut →
            ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬stavi_temporal_truth M atomMap w D := by
          intro t ht; by_contra h_all; push_neg at h_all
          exact h_no_init_D ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
        -- Get a complement point for U'(⊤, g∧D) bound
        have ⟨c₀, hc₀_not⟩ : ∃ c₀, c₀ ∉ γ.val.cut := by
          by_contra h; push_neg at h
          exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
        have hsc₀ : s < c₀ := h_compl_gt c₀ hc₀_not s hs_cut
        -- g∧D at cut points above s
        have h_gD_cut : ∀ u, s < u → u ∈ γ.val.cut →
            temporal_truth M atomMap u g ∧ stavi_temporal_truth M atomMap u D := by
          intro u hsu hu_cut
          exact ⟨(temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u)
              ((extendPoint_lt_iff t_pt u).mpr (lt_trans hts hsu))
              ⟨hu_cut, fun h => h hu_cut⟩ ⟨u, rfl⟩),
            (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hms hsu) hu_cut)⟩
        refine ⟨s, hms, ⟨hDs, hgs, hSnce_s, ?_, ?_⟩, hD_bet_ms⟩
        · -- U'(⊤, g∧D)(s): bound c₀
          refine ⟨c₀, hsc₀, ?_, ?_, ?_⟩
          · -- Condition (1): body
            intro u hsu huc₀
            by_cases hu_cut : u ∈ γ.val.cut
            · -- u ∈ cut: left disjunct (gD cofinal)
              left
              have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
                by_contra h_all; push_neg at h_all
                exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
              exact ⟨y, huy, fun w hsw hwy =>
                h_gD_cut w hsw (γ.val.downward_closed y w hy_in (le_of_lt hwy))⟩
            · -- u ∉ cut: right disjunct (⊤ trivial + ¬gD witness)
              right
              refine ⟨fun v _ _ => by simp [temporal_truth, Formula.top], ?_⟩
              have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
                by_contra h_all; push_neg at h_all
                exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
              obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
              exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyu,
                fun ⟨_, hD'⟩ => hDw hD'⟩
          · -- Condition (2): ¬gD failure in (s, c₀)
            have ⟨y, hy_not, hyc₀⟩ : ∃ y, y ∉ γ.val.cut ∧ y < c₀ := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨c₀, hc₀_not, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyc₀,
              fun ⟨_, hD'⟩ => hDw hD'⟩
          · -- Condition (3): gD initial in (s, c₀)
            have ⟨y, hy_in, hsy⟩ : ∃ y ∈ γ.val.cut, s < y := by
              by_contra h_all; push_neg at h_all
              exact γ.val.no_sup ⟨s, ⟨fun x hx => h_all x hx, fun b hb => hb hs_cut⟩, hs_cut⟩
            exact ⟨y, hsy, h_compl_gt c₀ hc₀_not y hy_in, fun v hsv hvy =>
              h_gD_cut v hsv (γ.val.downward_closed y v hy_in (le_of_lt hvy))⟩
        · -- ¬U'(D, g∧D)(s): by contradiction using two-step D-transfer argument
          intro ⟨s₁, hss₁, h_body, h_fail, h_init⟩
          obtain ⟨u_fail, hsu_fail, huf_s₁, hgD_fail⟩ := h_fail
          have huf_not_cut : u_fail ∉ γ.val.cut := by
            intro h; exact hgD_fail (h_gD_cut u_fail hsu_fail h)
          -- Left disjunct fails at any complement point: ¬D below blocks gD on (s,v)
          have h_left_fails : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
              ¬(∃ v, u < v ∧ ∀ w, s < w → w < v →
                temporal_truth M atomMap w g ∧ stavi_temporal_truth M atomMap w D) := by
            intro u hsu _ hu_not ⟨v, huv, hgDv⟩
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨u, hu_not, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact hDw (hgDv w (h_compl_gt w hw_not s hs_cut)
              (lt_trans (lt_of_le_of_lt hwy hyu) huv)).2
          -- Two-step argument: D holds at ALL complement points in (s, s₁)
          have hD_all_compl : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
              stavi_temporal_truth M atomMap u D := by
            intro u hsu hus₁ hu_not
            -- Step 1: right branch at u gives v' ∈ (s, u) complement
            have h_right_u := (h_body u hsu hus₁).resolve_left
              (h_left_fails u hsu hus₁ hu_not)
            obtain ⟨_, v', hsv', hv'u, hgD_v'⟩ := h_right_u
            have hv'_not : v' ∉ γ.val.cut := by
              intro h; exact hgD_v' (h_gD_cut v' hsv' h)
            -- Step 2: right branch at v' gives D on (v', s₁)
            have hv'_s₁ : v' < s₁ := lt_trans hv'u hus₁
            have h_right_v' := (h_body v' hsv' hv'_s₁).resolve_left
              (h_left_fails v' hsv' hv'_s₁ hv'_not)
            -- D(u) from D on (v', s₁) since v' < u < s₁
            exact h_right_v'.1 u hv'u hus₁
          -- Contradiction: initial D-segment in complement violates gap condition (2)
          have ⟨t, ht_not, ht_uf⟩ : ∃ t, t ∉ γ.val.cut ∧ t < u_fail := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨u_fail, huf_not_cut, fun z hz => h_all z hz⟩
          apply h_no_init_D
          exact ⟨t, ht_not, fun u hu_not hut =>
            hD_all_compl u (h_compl_gt u hu_not s hs_cut)
              (lt_of_le_of_lt hut (lt_trans ht_uf huf_s₁)) hu_not⟩
  | neg A ih =>
    -- left_formula (.neg A) D = .conj (.stavi_untl (.base top) D) (.neg (left_formula A D))
    simp only [left_formula, stavi_temporal_truth_mu]
    constructor
    · -- Forward: U'(top, D)(m) ∧ ¬left(A,D)(m) → ∃ γ with ¬A^mu(γ)
      intro ⟨hU, hNot⟩
      -- Use stavi_untl_gap_detection to extract gap from U'(top, D)(m)
      -- First reconstruct the stavi_untl term from the expanded goal
      have hU' : stavi_temporal_truth_mu M atomMap r (extendPoint m)
          (.stavi_untl (.base Formula.top) D) := by
        simp only [stavi_temporal_truth_mu]; exact hU
      obtain ⟨γ, _s_bound, hγ_lt, _hs_not, hγ_def, hγ_bet, _⟩ :=
        (stavi_untl_gap_detection (.base Formula.top) D hD m).mp hU'
      -- From ¬left(A,D)(m), by IH we get ¬(∃ γ with A^mu(γ))
      -- But actually we get: ¬ left_formula(A,D)(m), so by IH: not (∃ γ, ... ∧ A^mu(γ))
      have hNot' : ¬(∃ (γ' : RDefinableGap M atomMap r),
          extendPoint m < Sum.inr γ' ∧
          gap_definable_on_left M atomMap γ'.val D ∧
          (∀ u, m < u → u ∈ γ'.val.cut → stavi_temporal_truth_mu M atomMap r (extendPoint u) D) ∧
          stavi_temporal_truth_mu M atomMap r (Sum.inr γ') A) := by
        rwa [← ih m]
      -- Therefore γ has ¬A^mu(γ)
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      intro hA_at_γ
      exact hNot' ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_at_γ⟩
    · -- Backward: ∃ γ with ¬A^mu(γ) → U'(top, D)(m) ∧ ¬left(A,D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hNot_A⟩
      constructor
      · -- U'(top, D)(m)
        -- Need s_bound ∉ cut. Get one from complement_no_min or properness.
        have h_compl : ∃ x, x ∉ γ.val.cut := by
          by_contra h; push_neg at h; exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
        obtain ⟨s_b, hs_b⟩ := h_compl
        -- top holds at all complement points (trivially)
        have hTop_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_b →
            stavi_temporal_truth M atomMap u (.base Formula.top) := by
          intro u _ _
          simp only [stavi_temporal_truth, temporal_truth, Formula.top]; exact id
        have := (stavi_untl_gap_detection (.base Formula.top) D hD m).mpr
          ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_compl⟩
        simp only [stavi_temporal_truth_mu] at this
        exact this
      · -- ¬left(A,D)(m)
        rw [ih m]
        intro ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hA_at_γ'⟩
        -- γ and γ' must be equal by gap_detection_unique
        have hm_in : m ∈ γ.val.cut :=
          (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
        have hm_in' : m ∈ γ'.val.cut :=
          (extendPoint_le_gap_iff m γ').mp (le_of_lt hγ'_lt)
        have hγ_bet_std : ∀ u, m < u → u ∈ γ.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hmu hu_in
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hmu hu_in)
        have hγ'_bet_std : ∀ u, m < u → u ∈ γ'.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hmu hu_in
          exact (stavi_truth_mu_at_point u D).mp (hγ'_bet u hmu hu_in)
        have heq : γ.val = γ'.val :=
          gap_detection_unique hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_in hm_in'
        have : γ = γ' := Subtype.ext heq
        rw [this] at hNot_A
        exact hNot_A hA_at_γ'
  | conj A B ihA ihB =>
    -- left_formula (.conj A B) D = .conj (left_formula A D) (left_formula B D)
    simp only [left_formula, stavi_temporal_truth_mu]
    constructor
    · -- Forward: left(A,D)(m) ∧ left(B,D)(m) → ∃ γ with (A ∧ B)^mu(γ)
      intro ⟨hA, hB⟩
      obtain ⟨γA, hγA_lt, hγA_def, hγA_bet, hγA_val⟩ := (ihA m).mp hA
      obtain ⟨γB, hγB_lt, hγB_def, hγB_bet, hγB_val⟩ := (ihB m).mp hB
      -- γA and γB must be equal by gap_detection_unique
      have hm_in_A : m ∈ γA.val.cut :=
        (extendPoint_le_gap_iff m γA).mp (le_of_lt hγA_lt)
      have hm_in_B : m ∈ γB.val.cut :=
        (extendPoint_le_gap_iff m γB).mp (le_of_lt hγB_lt)
      -- Convert D-between conditions to use stavi_temporal_truth
      have hγA_bet' : ∀ u, m < u → u ∈ γA.val.cut →
          stavi_temporal_truth M atomMap u D := by
        intro u hmu hu_in
        exact (stavi_truth_mu_at_point u D).mp (hγA_bet u hmu hu_in)
      have hγB_bet' : ∀ u, m < u → u ∈ γB.val.cut →
          stavi_temporal_truth M atomMap u D := by
        intro u hmu hu_in
        exact (stavi_truth_mu_at_point u D).mp (hγB_bet u hmu hu_in)
      have heq : γA.val = γB.val :=
        gap_detection_unique hγA_def hγB_def hγA_bet' hγB_bet' hm_in_A hm_in_B
      refine ⟨γA, hγA_lt, hγA_def, hγA_bet, ?_, ?_⟩
      · exact hγA_val
      · have : γA = γB := Subtype.ext heq
        rw [this]
        exact hγB_val
    · -- Backward: ∃ γ with (A ∧ B)^mu(γ) → left(A,D)(m) ∧ left(B,D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val, hB_val⟩
      exact ⟨(ihA m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val⟩,
             (ihB m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hB_val⟩⟩
  | stavi_untl A B _ _ =>
    -- left_formula (.stavi_untl A B) D = .stavi_untl (.conj B (.stavi_untl A B)) D
    -- Need: U'(B ∧ U'(A,B), D)(m) ↔ ∃ γ, ... ∧ U'(A,B)^mu(γ)
    simp only [left_formula]
    constructor
    · -- Forward: from U'(B ∧ U'(A,B), D)(m), get gap with (B ∧ U'(A,B)) at complement points
      -- Extract U'(A,B) at complement points, then construct U'(A,B)^mu(γ)
      intro h
      obtain ⟨γ, s_bound, hγ_lt, hs_not, hγ_def, hγ_bet, hX_compl⟩ :=
        (stavi_untl_gap_detection (.conj B (.stavi_untl A B)) D hD m).mp h
      -- Extract stavi_untl(A,B) and B at complement points below s_bound
      have hUA_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          stavi_temporal_truth M atomMap u (.stavi_untl A B) :=
        fun u hu hus => (hX_compl u hu hus).2
      have hB_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          stavi_temporal_truth M atomMap u B :=
        fun u hu hus => (hX_compl u hu hus).1
      -- Pick complement point u₁ < s_bound
      have ⟨u₁, hu₁_not, hu₁s⟩ : ∃ u₁, u₁ ∉ γ.val.cut ∧ u₁ < s_bound := by
        by_contra h_all; push_neg at h_all
        exact γ.val.complement_no_min ⟨s_bound, hs_not, fun z hz => h_all z hz⟩
      -- FO table of stavi_untl(A,B) at u₁
      have hUA_u₁ := hUA_compl u₁ hu₁_not hu₁s
      simp only [stavi_temporal_truth] at hUA_u₁
      obtain ⟨s₁, hu₁s₁, h_body₁, ⟨wf, hwf_u₁, hwf_s₁, hBwf⟩,
              ⟨wi, hwi_u₁, hwi_s₁, hBwi⟩⟩ := hUA_u₁
      -- s₁ ∉ cut (upward-closed complement: s₁ > u₁ ∉ cut)
      have hs₁_not : s₁ ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed s₁ u₁ h (le_of_lt hu₁s₁))
      -- wf ∉ cut (wf > u₁)
      have hwf_not : wf ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed wf u₁ h (le_of_lt hwf_u₁))
      -- wi ∉ cut (wi > u₁)
      have hwi_not : wi ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed wi u₁ h (le_of_lt hwi_u₁))
      -- Construct stavi_untl(A,B)^mu(Sum.inr γ):
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      -- Need: stavi_temporal_truth_mu M atomMap r (Sum.inr γ) (.stavi_untl A B)
      -- Use (stavi_truth_mu_at_point u₁ (.stavi_untl A B)).mpr to convert back
      -- Actually, construct directly in the mu-relativized form
      simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
      refine ⟨extendPoint s₁, ?_, ?_, ?_, ?_⟩
      · -- Sum.inr γ < extendPoint s₁: s₁ ∉ cut
        exact ⟨hs₁_not, hs₁_not⟩
      · -- Condition (1): ∀ mu-point u ∈ (γ, extendPoint s₁), FO body
        intro u hγu hus₁ hmu
        obtain ⟨u_pt, rfl⟩ := hmu
        -- u_pt ∉ cut (Sum.inr γ < extendPoint u_pt means u_pt ∉ cut)
        have hu_pt_not : u_pt ∉ γ.val.cut := by
          intro h; exact not_lt.mpr (show extendPoint u_pt ≤ Sum.inr γ from h) hγu
        -- u_pt < s₁ (extendPoint u_pt < extendPoint s₁)
        have hu_pt_s₁ : u_pt < s₁ := (extendPoint_lt_iff u_pt s₁).mp hus₁
        -- Case split: u_pt > u₁ (use inner FO table) or u_pt ≤ u₁ (B-cofinal)
        by_cases hu_pt_u₁ : u₁ < u_pt
        · -- u_pt > u₁: use h_body₁ at u_pt
          cases h_body₁ u_pt hu_pt_u₁ hu_pt_s₁ with
          | inl h_cof =>
            -- LEFT: ∃ v > u_pt, B on (u₁, v). Extend to B on (γ, v) using hB_compl.
            left
            obtain ⟨v, hu_pt_v, hBv⟩ := h_cof
            refine ⟨extendPoint v, (extendPoint_lt_iff u_pt v).mpr hu_pt_v, ⟨v, rfl⟩,
              fun w hγw hwv hmu_w => ?_⟩
            obtain ⟨w_pt, rfl⟩ := hmu_w
            have hw_pt_v : w_pt < v := (extendPoint_lt_iff w_pt v).mp hwv
            have hw_pt_not : w_pt ∉ γ.val.cut := by
              intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
            -- w_pt is a complement point. If w_pt > u₁, use hBv. If w_pt ≤ u₁, use hB_compl.
            by_cases hwu₁ : u₁ < w_pt
            · exact (stavi_truth_mu_at_point w_pt B).mpr (hBv w_pt hwu₁ hw_pt_v)
            · push_neg at hwu₁
              -- w_pt ≤ u₁. w_pt ∉ cut and w_pt < s_bound (w_pt < v < s₁, s₁ > u₁, u₁ < s_bound)
              -- Need w_pt < s_bound. w_pt ≤ u₁ < s_bound.
              have hw_sb : w_pt < s_bound := lt_of_le_of_lt hwu₁ hu₁s
              exact (stavi_truth_mu_at_point w_pt B).mpr (hB_compl w_pt hw_pt_not hw_sb)
          | inr h_right =>
            -- RIGHT: A on (u_pt, s₁) and ¬B witness v' ∈ (u₁, u_pt)
            right
            obtain ⟨hA_above, v', hmv', hv'u, hBv'⟩ := h_right
            refine ⟨fun v hv hvs hmu_v => ?_, ?_⟩
            · -- A^mu(v) for v mu-point in (u_pt, s₁)
              obtain ⟨v_pt, rfl⟩ := hmu_v
              exact (stavi_truth_mu_at_point v_pt A).mpr
                (hA_above v_pt ((extendPoint_lt_iff u_pt v_pt).mp hv)
                  ((extendPoint_lt_iff v_pt s₁).mp hvs))
            · -- ∃ v' mu-point ∈ (γ, u_pt) with ¬B^mu(v')
              refine ⟨extendPoint v', ?_, (extendPoint_lt_iff v' u_pt).mpr hv'u,
                ⟨v', rfl⟩, ?_⟩
              · -- Sum.inr γ < extendPoint v': v' > u₁ > γ (v' ∈ (u₁, u_pt))
                show v' ∉ γ.val.cut ∧ ¬(v' ∈ γ.val.cut)
                have hv'_not : v' ∉ γ.val.cut := by
                  intro h; exact hu₁_not (γ.val.downward_closed v' u₁ h (le_of_lt hmv'))
                exact ⟨hv'_not, hv'_not⟩
              · exact mt (stavi_truth_mu_at_point v' B).mp hBv'
        · -- u_pt ≤ u₁: B holds at u_pt (from hB_compl) and at all complement points below wi
          -- Use LEFT disjunct: B cofinal
          push_neg at hu_pt_u₁
          left
          -- Need ∃ v_mu > u_pt with B^mu on (γ, v_mu)
          -- Use v_mu = extendPoint wi (wi from inner FO table: B on (u₁, wi))
          refine ⟨extendPoint wi, (extendPoint_lt_iff u_pt wi).mpr (lt_of_le_of_lt hu_pt_u₁ hwi_u₁),
            ⟨wi, rfl⟩, fun w hγw hwwi hmu_w => ?_⟩
          obtain ⟨w_pt, rfl⟩ := hmu_w
          have hw_pt_not : w_pt ∉ γ.val.cut := by
            intro h; exact not_lt.mpr (show extendPoint w_pt ≤ Sum.inr γ from h) hγw
          have hw_pt_wi : w_pt < wi := (extendPoint_lt_iff w_pt wi).mp hwwi
          by_cases hwu₁ : u₁ < w_pt
          · -- w_pt > u₁: B at w_pt from hBwi (B on (u₁, wi))
            exact (stavi_truth_mu_at_point w_pt B).mpr (hBwi w_pt hwu₁ hw_pt_wi)
          · -- w_pt ≤ u₁: B at w_pt from hB_compl
            push_neg at hwu₁
            exact (stavi_truth_mu_at_point w_pt B).mpr
              (hB_compl w_pt hw_pt_not (lt_of_le_of_lt hwu₁ hu₁s))
      · -- Condition (2): ∃ mu-point in (γ, s') with ¬B^mu
        refine ⟨extendPoint wf, ?_, (extendPoint_lt_iff wf s₁).mpr hwf_s₁,
          ⟨wf, rfl⟩, mt (stavi_truth_mu_at_point wf B).mp hBwf⟩
        show wf ∉ γ.val.cut ∧ ¬(wf ∈ γ.val.cut)
        exact ⟨hwf_not, hwf_not⟩
      · -- Condition (3): ∃ mu-point in (γ, s') with B^mu initial
        -- Use u₁ as the initial segment witness: B holds at all complement points in (γ, u₁)
        -- because complement points below u₁ are below s_bound, so hB_compl applies.
        -- But we need the initial mu-point between γ and s₁ where B holds from γ to that point.
        -- Wait: we need ∃ u_init ∈ (γ, s'), B^mu on (γ, u_init). The interval (γ, u_init)
        -- should contain only complement points where B holds.
        -- Pick u₁ itself if B at all complement points below u₁.
        -- Actually, from hBwi: B on (u₁, wi). Combined with hB_compl for complement points
        -- below u₁, we can use wi as the initial segment bound: B on complement points in (γ, wi).
        -- But we need u_init to satisfy: u_init ∈ (γ, s') and B^mu on (γ, u_init).
        -- complement_no_min gives us complement points below u₁ where B holds.
        -- Use wi as u_init: B holds on all complement points in (γ, wi).
        refine ⟨extendPoint wi, ?_, (extendPoint_lt_iff wi s₁).mpr hwi_s₁,
          ⟨wi, rfl⟩, fun v hγv hvwi hmu_v => ?_⟩
        · show wi ∉ γ.val.cut ∧ ¬(wi ∈ γ.val.cut)
          exact ⟨hwi_not, hwi_not⟩
        · obtain ⟨v_pt, rfl⟩ := hmu_v
          have hv_pt_not : v_pt ∉ γ.val.cut := by
            intro h; exact not_lt.mpr (show extendPoint v_pt ≤ Sum.inr γ from h) hγv
          have hv_pt_wi : v_pt < wi := (extendPoint_lt_iff v_pt wi).mp hvwi
          by_cases hvu₁ : u₁ < v_pt
          · exact (stavi_truth_mu_at_point v_pt B).mpr (hBwi v_pt hvu₁ hv_pt_wi)
          · push_neg at hvu₁
            exact (stavi_truth_mu_at_point v_pt B).mpr
              (hB_compl v_pt hv_pt_not (lt_of_le_of_lt hvu₁ hu₁s))
    · -- Backward: from gap with U'(A,B)^mu(γ), construct U'(B ∧ U'(A,B), D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
      -- From U'(A,B)^mu(γ), extract complement-point truth of B ∧ U'(A,B)
      -- U'(A,B)^mu(γ) gives FO table at the gap with witnesses among complement points
      simp only [stavi_temporal_truth_mu] at hUA
      obtain ⟨s_ua, hγ_s_ua, h_body_ua, ⟨wf_ua, hγ_wf, hwf_s, hmu_wf, hBwf_ua⟩,
              ⟨wi_ua, hγ_wi, hwi_s, hmu_wi, hBwi_ua⟩⟩ := hUA
      -- Extract s_ua bound. All mu-points above γ are complement points.
      -- From the FO table, B and stavi_untl(A,B) hold at specific complement points.
      -- We need to provide (conj B (stavi_untl A B)) at complement points for .mpr
      -- Get a complement point as s_bound for .mpr
      obtain ⟨wf_pt, rfl⟩ := hmu_wf
      obtain ⟨wi_pt, rfl⟩ := hmu_wi
      have hwf_not : wf_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint wf_pt ≤ Sum.inr γ from h) hγ_wf
      have hwi_not : wi_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint wi_pt ≤ Sum.inr γ from h) hγ_wi
      -- Strategy: use stavi_untl_gap_detection.mpr.
      -- Pick s_bound as a complement point below BOTH wf_pt and wi_pt.
      -- This ensures:
      --   (a) B holds at complement points u < s_bound (from hBwi_ua, since u < wi_pt)
      --   (b) U'(A,B)(u) can be constructed with wf_pt as ¬B witness and wi_pt as B-initial,
      --       both in the interval (u, s_pt) where s_pt is a carrier bound above wf_pt and wi_pt.
      -- First, get a carrier bound s_pt from s_ua above both witnesses.
      have ⟨s_pt, hs_pt_wf, hs_pt_wi, hs_pt_s_ua⟩ :
          ∃ s_pt : M.carrier, wf_pt < s_pt ∧ wi_pt < s_pt ∧ extendPoint s_pt ≤ s_ua := by
        rcases s_ua with s₁ | g_ua
        · refine ⟨s₁, (extendPoint_lt_iff wf_pt s₁).mp hwf_s,
            (extendPoint_lt_iff wi_pt s₁).mp hwi_s, le_rfl⟩
        · have hwf_cut : wf_pt ∈ g_ua.val.cut :=
            (extendPoint_le_gap_iff wf_pt g_ua).mp (le_of_lt hwf_s)
          have hwi_cut : wi_pt ∈ g_ua.val.cut :=
            (extendPoint_le_gap_iff wi_pt g_ua).mp (le_of_lt hwi_s)
          have hmax_cut : max wf_pt wi_pt ∈ g_ua.val.cut := by
            rcases le_or_lt wf_pt wi_pt with h | h
            · simp [max_eq_right h]; exact hwi_cut
            · simp [max_eq_left (le_of_lt h)]; exact hwf_cut
          have ⟨y, hy_cut, hmax_y⟩ : ∃ y, y ∈ g_ua.val.cut ∧ max wf_pt wi_pt < y := by
            by_contra h_all; push_neg at h_all
            exact g_ua.val.no_sup ⟨max wf_pt wi_pt,
              ⟨h_all, fun b hb => hb hmax_cut⟩, hmax_cut⟩
          exact ⟨y, lt_of_le_of_lt (le_max_left _ _) hmax_y,
            lt_of_le_of_lt (le_max_right _ _) hmax_y,
            le_of_lt (lt_of_le_of_ne
              ((extendPoint_le_gap_iff y g_ua).mpr hy_cut) (fun h => by cases h))⟩
      -- Pick s_bound = min(wf_pt, wi_pt). Both ∉ γ.cut.
      let s_bound := min wf_pt wi_pt
      have hs_bound_not : s_bound ∉ γ.val.cut := by
        simp only [s_bound, min_def]; split
        · exact hwf_not
        · exact hwi_not
      -- Apply stavi_untl_gap_detection.mpr
      apply (stavi_untl_gap_detection (.conj B (.stavi_untl A B)) D hD m).mpr
      refine ⟨γ, s_bound, hγ_lt, hs_bound_not, hγ_def, hγ_bet, fun u hu_not hu_sb => ?_⟩
      -- u is a complement point with u < s_bound = min(wf_pt, wi_pt)
      -- So u < wf_pt AND u < wi_pt
      have hu_wf : u < wf_pt := lt_of_lt_of_le hu_sb (min_le_left wf_pt wi_pt)
      have hu_wi : u < wi_pt := lt_of_lt_of_le hu_sb (min_le_right wf_pt wi_pt)
      have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (Sum.inr γ) (extendPoint u) := by
        show u ∉ γ.val.cut ∧ ¬(u ∈ γ.val.cut); exact ⟨hu_not, hu_not⟩
      simp only [stavi_temporal_truth]
      constructor
      · -- B(u): from hBwi_ua, u is between γ and wi_pt
        exact (stavi_truth_mu_at_point u B).mp
          (hBwi_ua (extendPoint u) hγu ((extendPoint_lt_iff u wi_pt).mpr hu_wi) ⟨u, rfl⟩)
      · -- U'(A,B)(u): FO table at u with bound s_pt
        refine ⟨s_pt, lt_trans hu_wf hs_pt_wf, ?_, ?_, ?_⟩
        · -- Body: ∀ w ∈ (u, s_pt), disjunction
          intro w huw hws
          have hw_not : w ∉ γ.val.cut := by
            intro h; exact hu_not (γ.val.downward_closed w u h (le_of_lt huw))
          have hγw : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (Sum.inr γ) (extendPoint w) := by
            show w ∉ γ.val.cut ∧ ¬(w ∈ γ.val.cut); exact ⟨hw_not, hw_not⟩
          have hw_s_ua : extendPoint w < s_ua :=
            lt_of_lt_of_le ((extendPoint_lt_iff w s_pt).mpr hws) hs_pt_s_ua
          -- Apply mu-body at w
          have h_disj := h_body_ua (extendPoint w) hγw hw_s_ua ⟨w, rfl⟩
          cases h_disj with
          | inl h_cof =>
            -- Left: ∃ v mu-point > w, B^mu on (γ, v). Restrict to (u, v).
            left
            obtain ⟨v, hwv, hmu_v, hBv⟩ := h_cof
            obtain ⟨v_pt, rfl⟩ := hmu_v
            refine ⟨v_pt, (extendPoint_lt_iff w v_pt).mp hwv, fun z huz hzv => ?_⟩
            have hz_not : z ∉ γ.val.cut := by
              intro h; exact hu_not (γ.val.downward_closed z u h (le_of_lt huz))
            have hγz : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                (Sum.inr γ) (extendPoint z) := by
              show z ∉ γ.val.cut ∧ ¬(z ∈ γ.val.cut); exact ⟨hz_not, hz_not⟩
            exact (stavi_truth_mu_at_point z B).mp
              (hBv (extendPoint z) hγz ((extendPoint_lt_iff z v_pt).mpr hzv) ⟨z, rfl⟩)
          | inr h_take =>
            -- Right: A^mu on (w, s_ua), ¬B^mu at v' ∈ (γ, w)
            obtain ⟨hA_above, v', hγv', hv'w, hmu_v', hBv'_neg⟩ := h_take
            obtain ⟨v'_pt, rfl⟩ := hmu_v'
            -- v'_pt is in (γ, w). Since u < wf_pt ≤ min(wf_pt, wi_pt) and u < wi_pt,
            -- if v'_pt ≤ u then v'_pt < wi_pt, so B(v'_pt) from hBwi_ua.
            -- But ¬B(v'_pt) contradicts. So v'_pt > u.
            have hv'u : u < v'_pt := by
              by_contra h_neg; push_neg at h_neg
              have hv'_wi : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
                  (extendPoint v'_pt) (extendPoint wi_pt) :=
                (extendPoint_lt_iff v'_pt wi_pt).mpr (lt_of_le_of_lt h_neg hu_wi)
              exact hBv'_neg ((stavi_truth_mu_at_point v'_pt B).mpr
                ((stavi_truth_mu_at_point v'_pt B).mp
                  (hBwi_ua (extendPoint v'_pt) hγv' hv'_wi ⟨v'_pt, rfl⟩)))
            right
            refine ⟨fun v hwv hvs => ?_,
              v'_pt, hv'u, (extendPoint_lt_iff v'_pt w).mp hv'w,
              fun h => hBv'_neg ((stavi_truth_mu_at_point v'_pt B).mpr h)⟩
            have hv_not : v ∉ γ.val.cut := by
              intro h; exact hw_not (γ.val.downward_closed v w h (le_of_lt hwv))
            exact (stavi_truth_mu_at_point v A).mp
              (hA_above (extendPoint v) ((extendPoint_lt_iff w v).mpr hwv)
                (lt_of_lt_of_le ((extendPoint_lt_iff v s_pt).mpr hvs) hs_pt_s_ua)
                ⟨v, rfl⟩)
        · -- ¬B witness: wf_pt is in (u, s_pt) and ¬B(wf_pt)
          exact ⟨wf_pt, hu_wf, hs_pt_wf,
            fun h => hBwf_ua ((stavi_truth_mu_at_point wf_pt B).mpr h)⟩
        · -- B initial: wi_pt is in (u, s_pt) and B on (u, wi_pt)
          refine ⟨wi_pt, hu_wi, hs_pt_wi, fun v huv hvwi => ?_⟩
          have hv_not : v ∉ γ.val.cut := by
            intro h; exact hu_not (γ.val.downward_closed v u h (le_of_lt huv))
          have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (Sum.inr γ) (extendPoint v) := by
            show v ∉ γ.val.cut ∧ ¬(v ∈ γ.val.cut); exact ⟨hv_not, hv_not⟩
          exact (stavi_truth_mu_at_point v B).mp
            (hBwi_ua (extendPoint v) hγv ((extendPoint_lt_iff v wi_pt).mpr hvwi) ⟨v, rfl⟩)
  | stavi_snce A B _ _ =>
    -- left_formula (.stavi_snce A B) D = .std_untl compound D
    -- compound = D ∧ B ∧ S'(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D)
    -- Same compound decomposition as std_snce; S'(A,B) FO table differs from S(A,B)
    simp only [left_formula]
    rw [stavi_truth_mu_at_point m (.std_untl _ D)]
    simp only [stavi_temporal_truth]
    constructor
    · -- Forward: compound at s → gap with S'(A,B)^mu(γ)
      intro ⟨s, hms, ⟨hDs, hBs, hSnce_s, hU'_BD_s, hNotU'D_BD_s⟩, hD_bet⟩
      obtain ⟨s₁, hss₁, h_body, h_fail, h_init⟩ := hU'_BD_s
      obtain ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩ := h_fail
      obtain ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩ := h_init
      -- Gap construction (identical to std_snce: uses U'(⊤,B∧D) + ¬U'(D,B∧D))
      let bD : M.carrier → Prop := fun u =>
        stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D
      let cut : Set M.carrier :=
        {x | ∀ u, s < u → u ≤ x → ∃ v, u < v ∧ ∀ w, s < w → w < v → bD w}
      have hs_in_cut : s ∈ cut :=
        fun u hsu hus => absurd (lt_of_lt_of_le hsu hus) (lt_irrefl s)
      have hu_fail_not_cut : u_fail ∉ cut := by
        intro h; obtain ⟨v, hfv, hBDv⟩ := h u_fail hsu_fail le_rfl
        exact hBD_fail (hBDv u_fail hsu_fail hfv)
      have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
        intro x hx; by_contra h; push_neg at h
        exact hu_fail_not_cut (fun u hsu huf => hx u hsu (le_trans huf h))
      have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
        fun x y hx hyx u hsu huy => hx u hsu (le_trans huy hyx)
      have h_proper : cut ≠ Set.univ := by
        intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
      have h_cofinal_propagate :
          ∀ u, s < u → u < s₁ →
          (∀ w, s < w → w < u → ∃ v, w < v ∧ ∀ z, s < z → z < v → bD z) →
          ∃ v, u < v ∧ ∀ z, s < z → z < v → bD z := by
        intro u hsu hus₁ h_below
        cases h_body u hsu hus₁ with
        | inl h => exact h
        | inr h =>
          obtain ⟨_, v', hsv', hv'u, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := h_below v' hsv' hv'u
          exact absurd (hBDv₂ v' hsv' hv'v₂) hBDv'
      have hu_init_cut : u_init ∈ cut := by
        intro u hsu huu_init
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt huu_init hu_init_s₁)
          (fun w hsw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
            fun z hsz hz_init => hBD_init z hsz hz_init⟩)
      have h_bD_at_cut : ∀ u, s < u → u ∈ cut → bD u := by
        intro u hsu hu_cut
        obtain ⟨v, huv, hBDv⟩ := hu_cut u hsu le_rfl
        exact hBDv u hsu huv
      have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
        intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
        have hsp : s < p := lt_of_lt_of_le hsu_init (h_ub hu_init_cut)
        obtain ⟨v, hpv, hBDv⟩ := hp_cut p hsp le_rfl
        have hvs₁ : v < s₁ := by
          by_contra h; push_neg at h
          exact hBD_fail (hBDv u_fail hsu_fail (lt_of_lt_of_le hu_fail_s₁ h))
        exact not_le.mpr hpv (h_ub (show v ∈ cut from fun u hsu huv => by
          rcases eq_or_lt_of_le huv with rfl | huv'
          · exact h_cofinal_propagate u (lt_trans hsp hpv) hvs₁
              (fun w hsw hwu => ⟨u, hwu, hBDv⟩)
          · exact ⟨v, huv', hBDv⟩))
      have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
        intro ⟨b, hb_not, hb_min⟩
        have hsb : s < b := by
          by_contra h; push_neg at h; exact hb_not (h_dc s b hs_in_cut h)
        have hbs₁ : b < s₁ := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hu_fail_s₁
        have h_below_b : ∀ y, y < b → y ∈ cut := by
          intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
        cases h_body b hsb hbs₁ with
        | inl h_cof =>
          exact hb_not (fun u hsu hub => by
            rcases eq_or_lt_of_le hub with rfl | hub'
            · exact h_cof
            · exact (h_below_b u hub') u hsu le_rfl)
        | inr h =>
          obtain ⟨_, v', hsv', hv'b, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := (h_below_b v' hv'b) v' hsv' le_rfl
          exact hBDv' (hBDv₂ v' hsv' hv'v₂)
      let γ_gap : Gap M.carrier :=
        ⟨cut, ⟨s, hs_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
      have h_D_cofinal_cut : ∃ t, t ∈ γ_gap.cut ∧
          ∀ u, t ≤ u → u ∈ γ_gap.cut → stavi_temporal_truth M atomMap u D :=
        ⟨u_init, hu_init_cut, fun u hu_le hu_cut =>
          (h_bD_at_cut u (lt_of_lt_of_le hsu_init hu_le) hu_cut).2⟩
      have h_no_init_compl_bD : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → bD u := by
        intro ⟨t, ht_not, hBDt⟩
        have hst : s < t := by
          by_contra h; push_neg at h; exact ht_not (h_dc s t hs_in_cut h)
        have hts₁ : t < s₁ := by
          by_contra h; push_neg at h
          exact hBD_fail (hBDt u_fail hu_fail_not_cut (le_trans (le_of_lt hu_fail_s₁) h))
        suffices t ∈ cut from ht_not this
        intro u hsu hut
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt hut hts₁)
          (fun w hsw hwu =>
            h_cofinal_propagate w hsw (lt_trans hwu (lt_of_le_of_lt hut hts₁))
              (fun z hsz hzw => by
                cases h_body z hsz (lt_trans hzw (lt_trans hwu
                    (lt_of_le_of_lt hut hts₁))) with
                | inl h => exact h
                | inr h =>
                  obtain ⟨_, v', hsv', hv'z, hBDv'⟩ := h
                  have : bD v' := by
                    by_cases hv'_cut : v' ∈ cut
                    · exact h_bD_at_cut v' hsv' hv'_cut
                    · exact hBDt v' hv'_cut (le_trans (le_of_lt hv'z)
                        (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
                  exact absurd this hBDv'))
      have hD_fails : ∃ u_D, s < u_D ∧ u_D < s₁ ∧
          ¬stavi_temporal_truth M atomMap u_D D := by
        by_contra h_all_D; push_neg at h_all_D
        apply hNotU'D_BD_s
        exact ⟨s₁, hss₁,
          fun u hsu hus₁ => by
            cases h_body u hsu hus₁ with
            | inl h => left; exact h
            | inr h => right; exact ⟨fun v huv hvs₁ => h_all_D v (lt_trans hsu huv) hvs₁, h.2⟩,
          ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩,
          ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩⟩
      obtain ⟨u_D, hsu_D, hu_D_s₁, hD_fail_D⟩ := hD_fails
      have hu_D_not_cut : u_D ∉ cut := by
        intro h; exact hD_fail_D (h_bD_at_cut u_D hsu_D h).2
      have h_compl_gt_cut : ∀ x, x ∉ cut → ∀ y, y ∈ cut → y < x := by
        intro x hx y hy; by_contra h; push_neg at h; exact hx (h_dc y x hy h)
      have h_no_init_compl_D : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → stavi_temporal_truth M atomMap u D := by
        intro ⟨t, ht_not, hDt⟩
        have hst : s < t := h_compl_gt_cut t ht_not s hs_in_cut
        have ht_uD : t < u_D := by
          by_contra h; push_neg at h; exact hD_fail_D (hDt u_D hu_D_not_cut h)
        have hts₁ : t < s₁ := lt_trans ht_uD hu_D_s₁
        apply hNotU'D_BD_s
        refine ⟨t, hst, ?_, ?_, ?_⟩
        · intro u hsu hut
          cases h_body u hsu (lt_trans hut hts₁) with
          | inl h => left; exact h
          | inr h => right
                     exact ⟨fun v huv hvt => by
                       by_cases hv_cut : v ∈ cut
                       · exact (h_bD_at_cut v (lt_trans hsu huv) hv_cut).2
                       · exact hDt v hv_cut (le_of_lt hvt), h.2⟩
        · by_contra h_no_fail; push_neg at h_no_fail
          apply h_no_init_compl_bD
          obtain ⟨c, hc_not, hct⟩ : ∃ c, c ∉ cut ∧ c < t := by
            by_contra h; push_neg at h
            exact h_comp_no_min ⟨t, ht_not, fun y hy => h y hy⟩
          exact ⟨c, hc_not, fun u hu huc =>
            h_no_fail u (h_compl_gt_cut u hu s hs_in_cut) (lt_of_le_of_lt huc hct)⟩
        · exact ⟨u_init, hsu_init, h_compl_gt_cut t ht_not u_init hu_init_cut, hBD_init⟩
      have h_def_left_D : gap_definable_on_left M atomMap γ_gap D :=
        ⟨h_D_cofinal_cut, h_no_init_compl_D⟩
      let γ : RDefinableGap M atomMap r := ⟨γ_gap, ⟨D, hD, Or.inl h_def_left_D⟩⟩
      refine ⟨γ, ?_, ?_, ?_, ?_⟩
      · have hm_in : m ∈ cut := h_dc s m hs_in_cut (le_of_lt hms)
        exact ⟨hm_in, fun h => h hm_in⟩
      · exact h_def_left_D
      · intro u hmu hu_cut
        by_cases hsu : s < u
        · exact (stavi_truth_mu_at_point u D).mpr (h_bD_at_cut u hsu hu_cut).2
        · push_neg at hsu
          rcases eq_or_lt_of_le hsu with rfl | hus
          · exact (stavi_truth_mu_at_point u D).mpr hDs
          · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hmu hus)
      · -- S'(A,B)^mu(γ): from S'(A,B)(s) with B∧D at cut points above s
        obtain ⟨s₂, hs₂s, h_body_snce, ⟨uf_snce, hs₂_uf, huf_s, hBuf⟩,
                ⟨ui_snce, hs₂_ui, hui_s, hBui⟩⟩ := hSnce_s
        have hs₂_cut : s₂ ∈ cut := h_dc s s₂ hs_in_cut (le_of_lt hs₂s)
        have huf_cut : uf_snce ∈ cut := h_dc s uf_snce hs_in_cut (le_of_lt huf_s)
        have hui_cut : ui_snce ∈ cut := h_dc s ui_snce hs_in_cut (le_of_lt hui_s)
        simp only [stavi_temporal_truth_mu]
        refine ⟨extendPoint s₂, ⟨hs₂_cut, fun h => h hs₂_cut⟩, ?_, ?_, ?_⟩
        · -- Body: ∀ mu-point u ∈ (s₂, γ), body^mu(u)
          intro u hs₂u huγ hmu
          obtain ⟨u_pt, rfl⟩ := hmu
          have hu_cut : u_pt ∈ γ.val.cut :=
            (extendPoint_le_gap_iff u_pt γ).mp (le_of_lt huγ)
          have hs₂_upt : s₂ < u_pt := (extendPoint_lt_iff s₂ u_pt).mp hs₂u
          by_cases hups : u_pt < s
          · -- u_pt < s: use original body from S'(A,B)(s)
            cases h_body_snce u_pt hs₂_upt hups with
            | inl h_cof =>
              left
              obtain ⟨v, hvu, hBv⟩ := h_cof
              have hv_cut : v ∈ cut := h_dc s v hs_in_cut (le_of_lt (lt_trans hvu hups))
              refine ⟨extendPoint v, (extendPoint_lt_iff v u_pt).mpr hvu,
                ⟨v, rfl⟩, fun w hvw hwγ hmu_w => ?_⟩
              obtain ⟨w_pt, rfl⟩ := hmu_w
              have hw_cut : w_pt ∈ γ.val.cut :=
                (extendPoint_le_gap_iff w_pt γ).mp (le_of_lt hwγ)
              have hvw_pt : v < w_pt := (extendPoint_lt_iff v w_pt).mp hvw
              by_cases hwps : w_pt < s
              · exact (stavi_truth_mu_at_point w_pt B).mpr (hBv w_pt hvw_pt hwps)
              · push_neg at hwps
                rcases eq_or_lt_of_le hwps with rfl | hwps'
                · exact (stavi_truth_mu_at_point s B).mpr hBs
                · exact (stavi_truth_mu_at_point _ B).mpr (h_bD_at_cut _ hwps' hw_cut).1
            | inr h_right =>
              right
              obtain ⟨hA_above, v', hu_v', hv'_s, hBv'⟩ := h_right
              have hv'_cut : v' ∈ cut := h_dc s v' hs_in_cut (le_of_lt hv'_s)
              refine ⟨fun v hs₂v hvu hmu_v => ?_, ?_⟩
              · obtain ⟨v_pt, rfl⟩ := hmu_v
                exact (stavi_truth_mu_at_point v_pt A).mpr
                  (hA_above v_pt ((extendPoint_lt_iff s₂ v_pt).mp hs₂v)
                    ((extendPoint_lt_iff v_pt u_pt).mp hvu))
              · exact ⟨extendPoint v', (extendPoint_lt_iff u_pt v').mpr hu_v',
                  ⟨hv'_cut, fun h => h hv'_cut⟩, ⟨v', rfl⟩,
                  mt (stavi_truth_mu_at_point v' B).mp hBv'⟩
          · -- u_pt ≥ s: cut point above s, B cofinal from B∧D
            push_neg at hups
            left
            -- Use ui_snce (B-init witness) extended: B at all cut points above ui_snce
            -- since B on (ui_snce, s) from hBui + B at cut above s from h_bD_at_cut
            refine ⟨extendPoint ui_snce, (extendPoint_lt_iff ui_snce u_pt).mpr
              (lt_of_lt_of_le hui_s hups),
              ⟨ui_snce, rfl⟩, fun w huiw hwγ hmu_w => ?_⟩
            obtain ⟨w_pt, rfl⟩ := hmu_w
            have hw_cut : w_pt ∈ γ.val.cut :=
              (extendPoint_le_gap_iff w_pt γ).mp (le_of_lt hwγ)
            have hui_wpt : ui_snce < w_pt := (extendPoint_lt_iff ui_snce w_pt).mp huiw
            by_cases hwps : w_pt < s
            · exact (stavi_truth_mu_at_point w_pt B).mpr (hBui w_pt hui_wpt hwps)
            · push_neg at hwps
              rcases eq_or_lt_of_le hwps with rfl | hsw'
              · exact (stavi_truth_mu_at_point s B).mpr hBs
              · exact (stavi_truth_mu_at_point w_pt B).mpr (h_bD_at_cut w_pt hsw' hw_cut).1
        · -- Fail: ∃ mu-point in (s₂, γ) with ¬B^mu
          exact ⟨extendPoint uf_snce, (extendPoint_lt_iff s₂ uf_snce).mpr hs₂_uf,
            ⟨huf_cut, fun h => h huf_cut⟩, ⟨uf_snce, rfl⟩,
            mt (stavi_truth_mu_at_point uf_snce B).mp hBuf⟩
        · -- Init: ∃ mu-point in (s₂, γ) with B^mu on (init, γ)
          refine ⟨extendPoint ui_snce, (extendPoint_lt_iff s₂ ui_snce).mpr hs₂_ui,
            ⟨hui_cut, fun h => h hui_cut⟩, ⟨ui_snce, rfl⟩,
            fun v huiv hvγ hmu_v => ?_⟩
          obtain ⟨v_pt, rfl⟩ := hmu_v
          have hv_cut : v_pt ∈ γ.val.cut :=
            (extendPoint_le_gap_iff v_pt γ).mp (le_of_lt hvγ)
          have hui_vpt : ui_snce < v_pt := (extendPoint_lt_iff ui_snce v_pt).mp huiv
          by_cases hvps : v_pt < s
          · exact (stavi_truth_mu_at_point v_pt B).mpr (hBui v_pt hui_vpt hvps)
          · push_neg at hvps
            rcases eq_or_lt_of_le hvps with rfl | hvs
            · exact (stavi_truth_mu_at_point s B).mpr hBs
            · exact (stavi_truth_mu_at_point _ B).mpr (h_bD_at_cut _ hvs hv_cut).1
    · -- Backward: gap with S'(A,B)^mu(γ) → compound at m
      -- Same compound structure as std_snce backward but S'(A,B) FO table
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSnce_mu⟩
      -- Expand S'(A,B)^mu(γ): FO table with bound, body, fail, init for B
      simp only [stavi_temporal_truth_mu, stavi_temporal_truth] at hSnce_mu
      obtain ⟨s_bound_ext, hs_bound_γ, h_body_AB, ⟨uf_ext, hs_uf, huf_γ, hmu_uf, hBuf⟩,
              ⟨ui_ext, hs_ui, hui_γ, hmu_ui, hBui⟩⟩ := hSnce_mu
      obtain ⟨uf_pt, rfl⟩ := hmu_uf
      obtain ⟨ui_pt, rfl⟩ := hmu_ui
      have huf_cut : uf_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff uf_pt γ).mp (le_of_lt huf_γ)
      have hui_cut : ui_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff ui_pt γ).mp (le_of_lt hui_γ)
      have hm_cut : m ∈ γ.val.cut :=
        (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
      -- Find cut point s above m, uf_pt, ui_pt
      have ⟨s, hs_cut, hms, hufs, huis⟩ :
          ∃ s, s ∈ γ.val.cut ∧ m < s ∧ uf_pt < s ∧ ui_pt < s := by
        have hmax3_cut : max m (max uf_pt ui_pt) ∈ γ.val.cut := by
          rcases le_or_lt m (max uf_pt ui_pt) with h | h
          · simp [max_eq_right h]
            rcases le_or_lt uf_pt ui_pt with h' | h'
            · simp [max_eq_right h']; exact hui_cut
            · simp [max_eq_left (le_of_lt h')]; exact huf_cut
          · simp [max_eq_left (le_of_lt h)]; exact hm_cut
        have ⟨s₂, hs₂, hmax_s₂⟩ : ∃ s₂ ∈ γ.val.cut, max m (max uf_pt ui_pt) < s₂ := by
          by_contra h; push_neg at h
          exact γ.val.no_sup ⟨_, ⟨h, fun _ hb => hb hmax3_cut⟩, hmax3_cut⟩
        exact ⟨s₂, hs₂,
          lt_of_le_of_lt (le_max_left _ _) hmax_s₂,
          lt_of_le_of_lt (le_trans (le_max_left _ _) (le_max_right _ _)) hmax_s₂,
          lt_of_le_of_lt (le_trans (le_max_right _ _) (le_max_right _ _)) hmax_s₂⟩
      have hDs : stavi_temporal_truth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hms hs_cut)
      have hγs' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint s) (Sum.inr γ) := ⟨hs_cut, fun h => h hs_cut⟩
      have hBs : stavi_temporal_truth M atomMap s B :=
        (stavi_truth_mu_at_point s B).mp
          (hBui (extendPoint s) ((extendPoint_lt_iff ui_pt s).mpr huis) hγs' ⟨s, rfl⟩)
      have hD_bet_ms : ∀ u, m < u → u < s → stavi_temporal_truth M atomMap u D := by
        intro u hmu hus
        exact (stavi_truth_mu_at_point u D).mp
          (hγ_bet u hmu (γ.val.downward_closed s u hs_cut (le_of_lt hus)))
      -- S'(A,B)(s): construct via mu-form restriction from (s_bound, γ) to (s_bound, s)
      have hSnce_s : stavi_temporal_truth M atomMap s (.stavi_snce A B) := by
        rw [← stavi_truth_mu_at_point s (.stavi_snce A B)]
        simp only [stavi_temporal_truth_mu, stavi_temporal_truth]
        refine ⟨s_bound_ext, lt_trans hs_uf ((extendPoint_lt_iff uf_pt s).mpr hufs), ?_, ?_, ?_⟩
        · -- body: restrict from (s_bound, γ) to (s_bound, extendPoint s)
          intro u hsu hus hmu
          cases h_body_AB u hsu (lt_trans hus hγs') hmu with
          | inl h_left =>
            left; obtain ⟨v, hvu, hmu_v, hBv⟩ := h_left
            exact ⟨v, hvu, hmu_v, fun w hvw hws hmu_w =>
              hBv w hvw (lt_trans hws hγs') hmu_w⟩
          | inr h_right =>
            right; obtain ⟨hA, v', huv', hv'γ, hmu_v', hBv'⟩ := h_right
            have hv'_s : v' < extendPoint s := by
              by_contra h; push_neg at h
              exact hBv' (hBui v'
                (lt_of_lt_of_le ((extendPoint_lt_iff ui_pt s).mpr huis) h)
                hv'γ hmu_v')
            exact ⟨hA, v', huv', hv'_s, hmu_v', hBv'⟩
        · -- fail: uf_pt with ¬B
          exact ⟨extendPoint uf_pt, hs_uf,
            (extendPoint_lt_iff uf_pt s).mpr hufs, ⟨uf_pt, rfl⟩, hBuf⟩
        · -- init: ui_pt with B on (ui_pt, s), restricted from (ui_pt, γ)
          exact ⟨extendPoint ui_pt, hs_ui,
            (extendPoint_lt_iff ui_pt s).mpr huis, ⟨ui_pt, rfl⟩,
            fun v huiv hvs hmu_v =>
              hBui v huiv (lt_trans hvs hγs') hmu_v⟩
      -- Extract gap definability conditions (same as std_snce backward)
      obtain ⟨⟨t_D, ht_D_cut, hD_final⟩, h_no_init_D⟩ := hγ_def
      have h_compl_gt : ∀ x, x ∉ γ.val.cut → ∀ y, y ∈ γ.val.cut → y < x := by
        intro x hx y hy; by_contra h; push_neg at h
        exact hx (γ.val.downward_closed y x hy h)
      have h_neg_init : ∀ t, t ∉ γ.val.cut →
          ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬stavi_temporal_truth M atomMap w D := by
        intro t ht; by_contra h_all; push_neg at h_all
        exact h_no_init_D ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
      have ⟨c₀, hc₀_not⟩ : ∃ c₀, c₀ ∉ γ.val.cut := by
        by_contra h; push_neg at h
        exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
      have hsc₀ : s < c₀ := h_compl_gt c₀ hc₀_not s hs_cut
      have h_bD_cut : ∀ u, s < u → u ∈ γ.val.cut →
          stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D := by
        intro u hsu hu_cut
        exact ⟨(stavi_truth_mu_at_point u B).mp
          (hBui (extendPoint u)
            ((extendPoint_lt_iff ui_pt u).mpr (lt_trans huis hsu))
            ⟨hu_cut, fun h => h hu_cut⟩ ⟨u, rfl⟩),
          (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hms hsu) hu_cut)⟩
      -- Provide the S'(A,B)(s) part of the goal
      have hSnce_s_expanded : ∃ s_1 < s,
          (∀ u, s_1 < u → u < s →
            (∃ v < u, ∀ w, v < w → w < s → stavi_temporal_truth M atomMap w B) ∨
            (∀ v, s_1 < v → v < u → stavi_temporal_truth M atomMap v A) ∧
              ∃ v', u < v' ∧ v' < s ∧ ¬stavi_temporal_truth M atomMap v' B) ∧
          (∃ u, s_1 < u ∧ u < s ∧ ¬stavi_temporal_truth M atomMap u B) ∧
          ∃ u, s_1 < u ∧ u < s ∧
            ∀ v, u < v → v < s → stavi_temporal_truth M atomMap v B := by
        simp only [stavi_temporal_truth] at hSnce_s
        exact hSnce_s
      refine ⟨s, hms, ⟨hDs, hBs, hSnce_s_expanded, ?_, ?_⟩, hD_bet_ms⟩
      · -- U'(⊤, B∧D)(s): same as std_snce backward
        refine ⟨c₀, hsc₀, ?_, ?_, ?_⟩
        · intro u hsu huc₀
          by_cases hu_cut : u ∈ γ.val.cut
          · left
            have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
              by_contra h_all; push_neg at h_all
              exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
            exact ⟨y, huy, fun w hsw hwy =>
              h_bD_cut w hsw (γ.val.downward_closed y w hy_in (le_of_lt hwy))⟩
          · right
            refine ⟨fun v _ _ => by simp [temporal_truth, Formula.top], ?_⟩
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyu,
              fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_not, hyc₀⟩ : ∃ y, y ∉ γ.val.cut ∧ y < c₀ := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨c₀, hc₀_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyc₀,
            fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_in, hsy⟩ : ∃ y ∈ γ.val.cut, s < y := by
            by_contra h_all; push_neg at h_all
            exact γ.val.no_sup ⟨s, ⟨fun x hx => h_all x hx, fun b hb => hb hs_cut⟩, hs_cut⟩
          exact ⟨y, hsy, h_compl_gt c₀ hc₀_not y hy_in, fun v hsv hvy =>
            h_bD_cut v hsv (γ.val.downward_closed y v hy_in (le_of_lt hvy))⟩
      · -- ¬U'(D, B∧D)(s): same two-step D-transfer as std_snce backward
        intro ⟨s₁, hss₁, h_body, h_fail, h_init⟩
        obtain ⟨u_fail, hsu_fail, huf_s₁, hBD_fail⟩ := h_fail
        have huf_not_cut : u_fail ∉ γ.val.cut := by
          intro h; exact hBD_fail (h_bD_cut u_fail hsu_fail h)
        have h_left_fails : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            ¬(∃ v, u < v ∧ ∀ w, s < w → w < v →
              stavi_temporal_truth M atomMap w B ∧ stavi_temporal_truth M atomMap w D) := by
          intro u hsu _ hu_not ⟨v, huv, hBDv⟩
          have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨u, hu_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact hDw (hBDv w (h_compl_gt w hw_not s hs_cut)
            (lt_trans (lt_of_le_of_lt hwy hyu) huv)).2
        have hD_all_compl : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hsu hus₁ hu_not
          have h_right_u := (h_body u hsu hus₁).resolve_left
            (h_left_fails u hsu hus₁ hu_not)
          obtain ⟨_, v', hsv', hv'u, hBD_v'⟩ := h_right_u
          have hv'_not : v' ∉ γ.val.cut := by
            intro h; exact hBD_v' (h_bD_cut v' hsv' h)
          have h_right_v' := (h_body v' hsv' (lt_trans hv'u hus₁)).resolve_left
            (h_left_fails v' hsv' (lt_trans hv'u hus₁) hv'_not)
          exact h_right_v'.1 u hv'u hus₁
        have ⟨t, ht_not, ht_uf⟩ : ∃ t, t ∉ γ.val.cut ∧ t < u_fail := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨u_fail, huf_not_cut, fun z hz => h_all z hz⟩
        exact h_no_init_D
          ⟨t, ht_not, fun u hu_not hut =>
            hD_all_compl u (h_compl_gt u hu_not s hs_cut)
              (lt_of_le_of_lt hut (lt_trans ht_uf huf_s₁)) hu_not⟩
  | std_untl A B _ _ =>
    -- left_formula (.std_untl A B) D = .stavi_untl (.conj B (.std_untl A B)) D
    -- Same pattern as stavi_untl: U'(B ∧ U(A,B), D)(m) ↔ ∃ γ, ... ∧ U(A,B)^mu(γ)
    simp only [left_formula]
    constructor
    · -- Forward: from U'(B ∧ U(A,B), D)(m), get complement point truth, derive U(A,B)^mu(γ)
      intro h
      obtain ⟨γ, s_bound, hγ_lt, hs_not, hγ_def, hγ_bet, hX_compl⟩ :=
        (stavi_untl_gap_detection (.conj B (.std_untl A B)) D hD m).mp h
      -- hX_compl gives conj B (std_untl A B) at complement points
      -- Extract std_untl(A,B) at complement points and construct std_untl(A,B)^mu(γ)
      have hUA_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          stavi_temporal_truth M atomMap u (.std_untl A B) :=
        fun u hu hus => (hX_compl u hu hus).2
      -- std_untl(A,B)^mu(γ): ∃ mu-point s > γ, A^mu(s) ∧ ∀ mu-point u ∈ (γ,s), B^mu(u)
      -- Pick complement point u₁ < s_bound. std_untl(A,B)(u₁) gives ∃ s > u₁, A(s) ∧ B on (u₁, s).
      -- B at complement points below u₁ from hX_compl.
      have ⟨u₁, hu₁_not, hu₁s⟩ : ∃ u₁, u₁ ∉ γ.val.cut ∧ u₁ < s_bound := by
        by_contra h_all; push_neg at h_all
        exact γ.val.complement_no_min ⟨s_bound, hs_not, fun z hz => h_all z hz⟩
      have hB_compl : ∀ u : M.carrier, u ∉ γ.val.cut → u < s_bound →
          stavi_temporal_truth M atomMap u B :=
        fun u hu hus => (hX_compl u hu hus).1
      have hUA_u₁ := hUA_compl u₁ hu₁_not hu₁s
      -- std_untl(A,B)(u₁): ∃ s₁ > u₁, A(s₁) ∧ B on (u₁, s₁)
      simp only [stavi_temporal_truth] at hUA_u₁
      obtain ⟨s₁, hu₁s₁, hAs₁, hB_between⟩ := hUA_u₁
      -- Construct std_untl(A,B)^mu(γ)
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      simp only [stavi_temporal_truth_mu]
      -- Need: ∃ s > γ, mu_holds s ∧ A^mu(s) ∧ ∀ mu-pt u ∈ (γ,s), B^mu(u)
      have hs₁_not : s₁ ∉ γ.val.cut := by
        intro h; exact hu₁_not (γ.val.downward_closed s₁ u₁ h (le_of_lt hu₁s₁))
      refine ⟨extendPoint s₁, ⟨hs₁_not, hs₁_not⟩, ⟨s₁, rfl⟩,
        (stavi_truth_mu_at_point s₁ A).mpr hAs₁, fun u hγu hus hmu => ?_⟩
      obtain ⟨u_pt, rfl⟩ := hmu
      have hu_pt_not : u_pt ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint u_pt ≤ Sum.inr γ from h) hγu
      have hu_pt_s₁ : u_pt < s₁ := (extendPoint_lt_iff u_pt s₁).mp hus
      by_cases hu_u₁ : u₁ < u_pt
      · exact (stavi_truth_mu_at_point u_pt B).mpr (hB_between u_pt hu_u₁ hu_pt_s₁)
      · push_neg at hu_u₁
        exact (stavi_truth_mu_at_point u_pt B).mpr
          (hB_compl u_pt hu_pt_not (lt_of_le_of_lt hu_u₁ hu₁s))
    · -- Backward: from gap with U(A,B)^mu(γ), construct U'(B ∧ U(A,B), D)(m)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hUA⟩
      -- U(A,B)^mu(γ) = ∃ s > γ, mu_holds s ∧ A^mu(s) ∧ ∀ mu-pt u ∈ (γ,s), B^mu(u)
      simp only [stavi_temporal_truth_mu] at hUA
      obtain ⟨s_ua, hγ_s_ua, hmu_s, hA_s, hB_mu⟩ := hUA
      obtain ⟨s₁, rfl⟩ := hmu_s
      have hs₁_not : s₁ ∉ γ.val.cut := by
        intro h; exact not_lt.mpr (show extendPoint s₁ ≤ Sum.inr γ from h) hγ_s_ua
      -- Apply stavi_untl_gap_detection.mpr with s_bound = s₁
      -- Need: (B ∧ U(A,B)) at complement points u with u ∉ γ.cut and u < s₁
      apply (stavi_untl_gap_detection (.conj B (.std_untl A B)) D hD m).mpr
      refine ⟨γ, s₁, hγ_lt, hs₁_not, hγ_def, hγ_bet, fun u hu_not hu_s₁ => ?_⟩
      -- u is a complement point above γ with u < s₁
      -- Show B(u) ∧ U(A,B)(u)
      have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (Sum.inr γ) (extendPoint u) := by
        show u ∉ γ.val.cut ∧ ¬(u ∈ γ.val.cut); exact ⟨hu_not, hu_not⟩
      simp only [stavi_temporal_truth]
      constructor
      · -- B(u): from hB_mu, since γ < extendPoint u < extendPoint s₁
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u) hγu ((extendPoint_lt_iff u s₁).mpr hu_s₁) ⟨u, rfl⟩)
      · -- U(A,B)(u): ∃ s' > u, A(s') ∧ B on (u, s'). Pick s' = s₁.
        refine ⟨s₁, hu_s₁, (stavi_truth_mu_at_point s₁ A).mp hA_s, fun v huv hvs₁ => ?_⟩
        -- v is between u and s₁, both complement points, so v ∉ γ.cut
        have hv_not : v ∉ γ.val.cut := by
          intro h; exact hu_not (γ.val.downward_closed v u h (le_of_lt huv))
        have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (Sum.inr γ) (extendPoint v) := by
          show v ∉ γ.val.cut ∧ ¬(v ∈ γ.val.cut); exact ⟨hv_not, hv_not⟩
        exact (stavi_truth_mu_at_point v B).mp
          (hB_mu (extendPoint v) hγv ((extendPoint_lt_iff v s₁).mpr hvs₁) ⟨v, rfl⟩)
  | std_snce A B _ _ =>
    -- left_formula (.std_snce A B) D = .std_untl compound D
    -- compound = D ∧ B ∧ S(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D)
    -- Same compound decomposition as base.snce; S(A,B)^mu has simple structure
    simp only [left_formula]
    rw [stavi_truth_mu_at_point m (.std_untl _ D)]
    simp only [stavi_temporal_truth]
    constructor
    · -- Forward: compound at s → gap with S(A,B)^mu(γ)
      -- Identical compound decomposition as base.snce, only temporal part differs
      intro ⟨s, hms, ⟨hDs, hBs, ⟨q, hqs, hAq, hBqs⟩, hU'_BD_s, hNotU'D_BD_s⟩, hD_bet⟩
      obtain ⟨s₁, hss₁, h_body, h_fail, h_init⟩ := hU'_BD_s
      obtain ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩ := h_fail
      obtain ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩ := h_init
      let bD : M.carrier → Prop := fun u =>
        stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D
      let cut : Set M.carrier :=
        {x | ∀ u, s < u → u ≤ x → ∃ v, u < v ∧ ∀ w, s < w → w < v → bD w}
      have hs_in_cut : s ∈ cut :=
        fun u hsu hus => absurd (lt_of_lt_of_le hsu hus) (lt_irrefl s)
      have hu_fail_not_cut : u_fail ∉ cut := by
        intro h; obtain ⟨v, hfv, hBDv⟩ := h u_fail hsu_fail le_rfl
        exact hBD_fail (hBDv u_fail hsu_fail hfv)
      have h_cut_lt_uf : ∀ x ∈ cut, x < u_fail := by
        intro x hx; by_contra h; push_neg at h
        exact hu_fail_not_cut (fun u hsu huf => hx u hsu (le_trans huf h))
      have h_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
        fun x y hx hyx u hsu huy => hx u hsu (le_trans huy hyx)
      have h_proper : cut ≠ Set.univ := by
        intro h; exact hu_fail_not_cut (h ▸ Set.mem_univ u_fail)
      have h_cofinal_propagate :
          ∀ u, s < u → u < s₁ →
          (∀ w, s < w → w < u → ∃ v, w < v ∧ ∀ z, s < z → z < v → bD z) →
          ∃ v, u < v ∧ ∀ z, s < z → z < v → bD z := by
        intro u hsu hus₁ h_below
        cases h_body u hsu hus₁ with
        | inl h => exact h
        | inr h =>
          obtain ⟨_, v', hsv', hv'u, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := h_below v' hsv' hv'u
          exact absurd (hBDv₂ v' hsv' hv'v₂) hBDv'
      have hu_init_cut : u_init ∈ cut := by
        intro u hsu huu_init
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt huu_init hu_init_s₁)
          (fun w hsw hwu => ⟨u_init, lt_of_lt_of_le hwu huu_init,
            fun z hsz hz_init => hBD_init z hsz hz_init⟩)
      have h_bD_at_cut : ∀ u, s < u → u ∈ cut → bD u := by
        intro u hsu hu_cut
        obtain ⟨v, huv, hBDv⟩ := hu_cut u hsu le_rfl
        exact hBDv u hsu huv
      have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
        intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
        have hsp : s < p := lt_of_lt_of_le hsu_init (h_ub hu_init_cut)
        obtain ⟨v, hpv, hBDv⟩ := hp_cut p hsp le_rfl
        have hvs₁ : v < s₁ := by
          by_contra h; push_neg at h
          exact hBD_fail (hBDv u_fail hsu_fail (lt_of_lt_of_le hu_fail_s₁ h))
        exact not_le.mpr hpv (h_ub (show v ∈ cut from fun u hsu huv => by
          rcases eq_or_lt_of_le huv with rfl | huv'
          · exact h_cofinal_propagate u (lt_trans hsp hpv) hvs₁
              (fun w hsw hwu => ⟨u, hwu, hBDv⟩)
          · exact ⟨v, huv', hBDv⟩))
      have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
        intro ⟨b, hb_not, hb_min⟩
        have hsb : s < b := by
          by_contra h; push_neg at h; exact hb_not (h_dc s b hs_in_cut h)
        have hbs₁ : b < s₁ := lt_of_le_of_lt (hb_min u_fail hu_fail_not_cut) hu_fail_s₁
        have h_below_b : ∀ y, y < b → y ∈ cut := by
          intro y hyb; by_contra hy_not; exact not_lt.mpr (hb_min y hy_not) hyb
        cases h_body b hsb hbs₁ with
        | inl h_cof =>
          exact hb_not (fun u hsu hub => by
            rcases eq_or_lt_of_le hub with rfl | hub'
            · exact h_cof
            · exact (h_below_b u hub') u hsu le_rfl)
        | inr h =>
          obtain ⟨_, v', hsv', hv'b, hBDv'⟩ := h
          obtain ⟨v₂, hv'v₂, hBDv₂⟩ := (h_below_b v' hv'b) v' hsv' le_rfl
          exact hBDv' (hBDv₂ v' hsv' hv'v₂)
      let γ_gap : Gap M.carrier :=
        ⟨cut, ⟨s, hs_in_cut⟩, h_proper, h_dc, h_no_sup, h_comp_no_min⟩
      have h_D_cofinal_cut : ∃ t, t ∈ γ_gap.cut ∧
          ∀ u, t ≤ u → u ∈ γ_gap.cut → stavi_temporal_truth M atomMap u D :=
        ⟨u_init, hu_init_cut, fun u hu_le hu_cut =>
          (h_bD_at_cut u (lt_of_lt_of_le hsu_init hu_le) hu_cut).2⟩
      have h_no_init_compl_bD : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → bD u := by
        intro ⟨t, ht_not, hBDt⟩
        have hst : s < t := by
          by_contra h; push_neg at h; exact ht_not (h_dc s t hs_in_cut h)
        have hts₁ : t < s₁ := by
          by_contra h; push_neg at h
          exact hBD_fail (hBDt u_fail hu_fail_not_cut (le_trans (le_of_lt hu_fail_s₁) h))
        suffices t ∈ cut from ht_not this
        intro u hsu hut
        exact h_cofinal_propagate u hsu (lt_of_le_of_lt hut hts₁)
          (fun w hsw hwu =>
            h_cofinal_propagate w hsw (lt_trans hwu (lt_of_le_of_lt hut hts₁))
              (fun z hsz hzw => by
                cases h_body z hsz (lt_trans hzw (lt_trans hwu
                    (lt_of_le_of_lt hut hts₁))) with
                | inl h => exact h
                | inr h =>
                  obtain ⟨_, v', hsv', hv'z, hBDv'⟩ := h
                  have : bD v' := by
                    by_cases hv'_cut : v' ∈ cut
                    · exact h_bD_at_cut v' hsv' hv'_cut
                    · exact hBDt v' hv'_cut (le_trans (le_of_lt hv'z)
                        (le_trans (le_of_lt hzw) (le_trans (le_of_lt hwu) hut)))
                  exact absurd this hBDv'))
      have hD_fails : ∃ u_D, s < u_D ∧ u_D < s₁ ∧
          ¬stavi_temporal_truth M atomMap u_D D := by
        by_contra h_all_D; push_neg at h_all_D
        apply hNotU'D_BD_s
        exact ⟨s₁, hss₁,
          fun u hsu hus₁ => by
            cases h_body u hsu hus₁ with
            | inl h => left; exact h
            | inr h => right; exact ⟨fun v huv hvs₁ => h_all_D v (lt_trans hsu huv) hvs₁, h.2⟩,
          ⟨u_fail, hsu_fail, hu_fail_s₁, hBD_fail⟩,
          ⟨u_init, hsu_init, hu_init_s₁, hBD_init⟩⟩
      obtain ⟨u_D, hsu_D, hu_D_s₁, hD_fail_D⟩ := hD_fails
      have hu_D_not_cut : u_D ∉ cut := by
        intro h; exact hD_fail_D (h_bD_at_cut u_D hsu_D h).2
      have h_compl_gt_cut : ∀ x, x ∉ cut → ∀ y, y ∈ cut → y < x := by
        intro x hx y hy; by_contra h; push_neg at h; exact hx (h_dc y x hy h)
      have h_no_init_compl_D : ¬∃ t, t ∉ γ_gap.cut ∧
          ∀ u, u ∉ γ_gap.cut → u ≤ t → stavi_temporal_truth M atomMap u D := by
        intro ⟨t, ht_not, hDt⟩
        have hst : s < t := h_compl_gt_cut t ht_not s hs_in_cut
        have ht_uD : t < u_D := by
          by_contra h; push_neg at h; exact hD_fail_D (hDt u_D hu_D_not_cut h)
        have hts₁ : t < s₁ := lt_trans ht_uD hu_D_s₁
        apply hNotU'D_BD_s
        refine ⟨t, hst, ?_, ?_, ?_⟩
        · intro u hsu hut
          cases h_body u hsu (lt_trans hut hts₁) with
          | inl h => left; exact h
          | inr h => right
                     exact ⟨fun v huv hvt => by
                       by_cases hv_cut : v ∈ cut
                       · exact (h_bD_at_cut v (lt_trans hsu huv) hv_cut).2
                       · exact hDt v hv_cut (le_of_lt hvt), h.2⟩
        · by_contra h_no_fail; push_neg at h_no_fail
          apply h_no_init_compl_bD
          obtain ⟨c, hc_not, hct⟩ : ∃ c, c ∉ cut ∧ c < t := by
            by_contra h; push_neg at h
            exact h_comp_no_min ⟨t, ht_not, fun y hy => h y hy⟩
          exact ⟨c, hc_not, fun u hu huc =>
            h_no_fail u (h_compl_gt_cut u hu s hs_in_cut) (lt_of_le_of_lt huc hct)⟩
        · exact ⟨u_init, hsu_init, h_compl_gt_cut t ht_not u_init hu_init_cut, hBD_init⟩
      have h_def_left_D : gap_definable_on_left M atomMap γ_gap D :=
        ⟨h_D_cofinal_cut, h_no_init_compl_D⟩
      let γ : RDefinableGap M atomMap r := ⟨γ_gap, ⟨D, hD, Or.inl h_def_left_D⟩⟩
      refine ⟨γ, ?_, ?_, ?_, ?_⟩
      · have hm_in : m ∈ cut := h_dc s m hs_in_cut (le_of_lt hms)
        exact ⟨hm_in, fun h => h hm_in⟩
      · exact h_def_left_D
      · intro u hmu hu_cut
        by_cases hsu : s < u
        · exact (stavi_truth_mu_at_point u D).mpr (h_bD_at_cut u hsu hu_cut).2
        · push_neg at hsu
          rcases eq_or_lt_of_le hsu with rfl | hus
          · exact (stavi_truth_mu_at_point u D).mpr hDs
          · exact (stavi_truth_mu_at_point u D).mpr (hD_bet u hmu hus)
      · -- S(A,B)^mu(γ): from S(A,B)(s), same construction as base.snce
        have hq_cut : q ∈ cut := h_dc s q hs_in_cut (le_of_lt hqs)
        exact ⟨extendPoint q, ⟨hq_cut, fun h => h hq_cut⟩, ⟨q, rfl⟩,
          (stavi_truth_mu_at_point q A).mpr hAq,
          fun u hqu huγ hmu => by
            obtain ⟨p, rfl⟩ := hmu
            have hp_cut : p ∈ cut := huγ.1
            have hqp : q < p := (extendPoint_lt_iff q p).mp hqu
            by_cases hps : p ≤ s
            · rcases eq_or_lt_of_le hps with rfl | hps'
              · exact (stavi_truth_mu_at_point p B).mpr hBs
              · exact (stavi_truth_mu_at_point p B).mpr (hBqs p hqp hps')
            · push_neg at hps
              exact (stavi_truth_mu_at_point p B).mpr (h_bD_at_cut p hps hp_cut).1⟩
    · -- Backward: gap with S(A,B)^mu(γ) → compound at m
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSnce_mu⟩
      obtain ⟨t_ext, ht_γ, ⟨t_pt, rfl⟩, hA_t, hB_mu⟩ := hSnce_mu
      have ht_cut : t_pt ∈ γ.val.cut :=
        (extendPoint_le_gap_iff t_pt γ).mp (le_of_lt ht_γ)
      have hm_cut : m ∈ γ.val.cut :=
        (extendPoint_le_gap_iff m γ).mp (le_of_lt hγ_lt)
      have ⟨s, hs_cut, hms, hts⟩ : ∃ s, s ∈ γ.val.cut ∧ m < s ∧ t_pt < s := by
        have ⟨s₁, hs₁, hms₁⟩ : ∃ s₁ ∈ γ.val.cut, m < s₁ := by
          by_contra h; push_neg at h
          exact γ.val.no_sup ⟨m, ⟨h, fun _ hb => hb hm_cut⟩, hm_cut⟩
        have hmax_cut : max s₁ t_pt ∈ γ.val.cut := by
          rcases le_or_lt s₁ t_pt with h | h
          · simp [max_eq_right h]; exact ht_cut
          · simp [max_eq_left (le_of_lt h)]; exact hs₁
        have ⟨s₂, hs₂, hmax_s₂⟩ : ∃ s₂ ∈ γ.val.cut, max s₁ t_pt < s₂ := by
          by_contra h; push_neg at h
          exact γ.val.no_sup ⟨max s₁ t_pt, ⟨h, fun _ hb => hb hmax_cut⟩, hmax_cut⟩
        exact ⟨s₂, hs₂,
          lt_trans hms₁ (lt_of_le_of_lt (le_max_left s₁ t_pt) hmax_s₂),
          lt_of_le_of_lt (le_max_right s₁ t_pt) hmax_s₂⟩
      have hDs : stavi_temporal_truth M atomMap s D :=
        (stavi_truth_mu_at_point s D).mp (hγ_bet s hms hs_cut)
      have hγs : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint t_pt) (extendPoint s) :=
        (extendPoint_lt_iff t_pt s).mpr hts
      have hγs' : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
          (extendPoint s) (Sum.inr γ) := ⟨hs_cut, fun h => h hs_cut⟩
      have hBs : stavi_temporal_truth M atomMap s B :=
        (stavi_truth_mu_at_point s B).mp
          (hB_mu (extendPoint s) hγs hγs' ⟨s, rfl⟩)
      have hSnce_s : ∃ s_1 < s, stavi_temporal_truth M atomMap s_1 A ∧
          ∀ u, s_1 < u → u < s → stavi_temporal_truth M atomMap u B := by
        refine ⟨t_pt, hts, (stavi_truth_mu_at_point t_pt A).mp hA_t, fun u htu hus => ?_⟩
        have hu_cut : u ∈ γ.val.cut := γ.val.downward_closed s u hs_cut (le_of_lt hus)
        have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t_pt) (extendPoint u) :=
          (extendPoint_lt_iff t_pt u).mpr htu
        have huγ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint u) (Sum.inr γ) := ⟨hu_cut, fun h => h hu_cut⟩
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u) hγu huγ ⟨u, rfl⟩)
      have hD_bet_ms : ∀ u, m < u → u < s → stavi_temporal_truth M atomMap u D := by
        intro u hmu hus
        exact (stavi_truth_mu_at_point u D).mp
          (hγ_bet u hmu (γ.val.downward_closed s u hs_cut (le_of_lt hus)))
      obtain ⟨⟨t_D, ht_D_cut, hD_final⟩, h_no_init_D⟩ := hγ_def
      have h_compl_gt : ∀ x, x ∉ γ.val.cut → ∀ y, y ∈ γ.val.cut → y < x := by
        intro x hx y hy; by_contra h; push_neg at h
        exact hx (γ.val.downward_closed y x hy h)
      have h_neg_init : ∀ t, t ∉ γ.val.cut →
          ∃ w, w ∉ γ.val.cut ∧ w ≤ t ∧ ¬stavi_temporal_truth M atomMap w D := by
        intro t ht; by_contra h_all; push_neg at h_all
        exact h_no_init_D ⟨t, ht, fun w hw hwt => h_all w hw hwt⟩
      have ⟨c₀, hc₀_not⟩ : ∃ c₀, c₀ ∉ γ.val.cut := by
        by_contra h; push_neg at h
        exact γ.val.proper (Set.eq_univ_iff_forall.mpr h)
      have hsc₀ : s < c₀ := h_compl_gt c₀ hc₀_not s hs_cut
      have h_bD_cut : ∀ u, s < u → u ∈ γ.val.cut →
          stavi_temporal_truth M atomMap u B ∧ stavi_temporal_truth M atomMap u D := by
        intro u hsu hu_cut
        exact ⟨(stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u)
            ((extendPoint_lt_iff t_pt u).mpr (lt_trans hts hsu))
            ⟨hu_cut, fun h => h hu_cut⟩ ⟨u, rfl⟩),
          (stavi_truth_mu_at_point u D).mp (hγ_bet u (lt_trans hms hsu) hu_cut)⟩
      refine ⟨s, hms, ⟨hDs, hBs, hSnce_s, ?_, ?_⟩, hD_bet_ms⟩
      · -- U'(⊤, B∧D)(s): same as base.snce backward
        refine ⟨c₀, hsc₀, ?_, ?_, ?_⟩
        · intro u hsu huc₀
          by_cases hu_cut : u ∈ γ.val.cut
          · left
            have ⟨y, hy_in, huy⟩ : ∃ y ∈ γ.val.cut, u < y := by
              by_contra h_all; push_neg at h_all
              exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
            exact ⟨y, huy, fun w hsw hwy =>
              h_bD_cut w hsw (γ.val.downward_closed y w hy_in (le_of_lt hwy))⟩
          · right
            refine ⟨fun v _ _ => by simp [temporal_truth, Formula.top], ?_⟩
            have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
              by_contra h_all; push_neg at h_all
              exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
            obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
            exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyu,
              fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_not, hyc₀⟩ : ∃ y, y ∉ γ.val.cut ∧ y < c₀ := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨c₀, hc₀_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact ⟨w, h_compl_gt w hw_not s hs_cut, lt_of_le_of_lt hwy hyc₀,
            fun ⟨_, hD'⟩ => hDw hD'⟩
        · have ⟨y, hy_in, hsy⟩ : ∃ y ∈ γ.val.cut, s < y := by
            by_contra h_all; push_neg at h_all
            exact γ.val.no_sup ⟨s, ⟨fun x hx => h_all x hx, fun b hb => hb hs_cut⟩, hs_cut⟩
          exact ⟨y, hsy, h_compl_gt c₀ hc₀_not y hy_in, fun v hsv hvy =>
            h_bD_cut v hsv (γ.val.downward_closed y v hy_in (le_of_lt hvy))⟩
      · -- ¬U'(D, B∧D)(s): same two-step D-transfer as base.snce
        intro ⟨s₁, hss₁, h_body, h_fail, h_init⟩
        obtain ⟨u_fail, hsu_fail, huf_s₁, hBD_fail⟩ := h_fail
        have huf_not_cut : u_fail ∉ γ.val.cut := by
          intro h; exact hBD_fail (h_bD_cut u_fail hsu_fail h)
        have h_left_fails : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            ¬(∃ v, u < v ∧ ∀ w, s < w → w < v →
              stavi_temporal_truth M atomMap w B ∧ stavi_temporal_truth M atomMap w D) := by
          intro u hsu _ hu_not ⟨v, huv, hBDv⟩
          have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
            by_contra h_all; push_neg at h_all
            exact γ.val.complement_no_min ⟨u, hu_not, fun z hz => h_all z hz⟩
          obtain ⟨w, hw_not, hwy, hDw⟩ := h_neg_init y hy_not
          exact hDw (hBDv w (h_compl_gt w hw_not s hs_cut)
            (lt_trans (lt_of_le_of_lt hwy hyu) huv)).2
        have hD_all_compl : ∀ u, s < u → u < s₁ → u ∉ γ.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hsu hus₁ hu_not
          have h_right_u := (h_body u hsu hus₁).resolve_left
            (h_left_fails u hsu hus₁ hu_not)
          obtain ⟨_, v', hsv', hv'u, hBD_v'⟩ := h_right_u
          have hv'_not : v' ∉ γ.val.cut := by
            intro h; exact hBD_v' (h_bD_cut v' hsv' h)
          have h_right_v' := (h_body v' hsv' (lt_trans hv'u hus₁)).resolve_left
            (h_left_fails v' hsv' (lt_trans hv'u hus₁) hv'_not)
          exact h_right_v'.1 u hv'u hus₁
        have ⟨t, ht_not, ht_uf⟩ : ∃ t, t ∉ γ.val.cut ∧ t < u_fail := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨u_fail, huf_not_cut, fun z hz => h_all z hz⟩
        exact h_no_init_D ⟨t, ht_not, fun u hu_not hut =>
          hD_all_compl u (h_compl_gt u hu_not s hs_cut)
            (lt_of_le_of_lt hut (lt_trans ht_uf huf_s₁)) hu_not⟩

/-! ### GHR93 Lemma 9 (Gap detection correctness, right direction)

right_formula(A, D) evaluated at an actual point m in M_r detects
whether A^mu holds at a gap gamma that is D-defined on the right,
with gamma < m and D holding at all actual points between gamma and m.
-/

/-- Core helper for right: S'(X, D) at an actual point m detects a D-defined
    gap γ < m where X holds at cut points above some bound, with D holding at
    complement points between γ and m. Dual of stavi_untl_gap_detection.

    RHS uses "X at cut points above s_bound" rather than X^mu at the gap,
    matching the stavi_untl_gap_detection pattern. -/
theorem stavi_snce_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (X D : StaviFormula) (hD : stavi_depth D ≤ r) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (.stavi_snce X D) ↔
    (∃ (γ : RDefinableGap M atomMap r) (s_bound : M.carrier),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m > Sum.inr γ ∧
      s_bound ∈ γ.val.cut ∧
      gap_definable_on_right M atomMap γ.val D ∧
      (∀ u : M.carrier, u < m → u ∉ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      (∀ u : M.carrier, u ∈ γ.val.cut → s_bound < u →
        stavi_temporal_truth M atomMap u X)) := by
  -- Dual of stavi_untl_gap_detection: reverse direction, complement ↔ cut roles swapped
  rw [stavi_truth_mu_at_point m (.stavi_snce X D)]
  simp only [stavi_temporal_truth]
  -- LHS: ∃ s < m, body(1) ∧ (2) D fails somewhere ∧ (3) D holds on final segment
  constructor
  · -- **Forward direction** (FO table → gap):
    intro ⟨s, hsm, h_body, ⟨u_fail, hsu_fail, hum_fail, hD_fail⟩,
           ⟨u_init, hsu_init, hum_init, hD_init⟩⟩
    -- Dual cut: complement (= points where D is cofinal toward m from below)
    let compl : Set M.carrier :=
      {x | ∀ u, x ≤ u → u < m →
        ∃ v, v < u ∧ ∀ w, v < w → w < m → stavi_temporal_truth M atomMap w D}
    have hm_in_compl : m ∈ compl :=
      fun u hmu hum => absurd (lt_of_lt_of_le hum hmu) (lt_irrefl u)
    have hu_fail_not_compl : u_fail ∉ compl := by
      intro h; obtain ⟨v, hvu, hDv⟩ := h u_fail le_rfl hum_fail
      exact hD_fail (hDv u_fail hvu hum_fail)
    let cut : Set M.carrier := {x | x ∉ compl}
    -- Classical conversion: x ∉ cut ↔ x ∈ compl
    have h_not_cut_compl : ∀ x, x ∉ cut → x ∈ compl := fun x h => by
      by_contra hx; exact h hx
    have h_compl_not_cut : ∀ x, x ∈ compl → x ∉ cut := fun x hx h => h hx
    have huf_in_cut : u_fail ∈ cut := hu_fail_not_compl
    have hm_not_cut : m ∉ cut := h_compl_not_cut m hm_in_compl
    -- compl is upward-closed; cut is downward-closed
    have h_compl_up : ∀ x y, x ∈ compl → x ≤ y → y ∈ compl :=
      fun x y hx hxy u hyu hum => hx u (le_trans hxy hyu) hum
    have h_cut_dc : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut :=
      fun x y hx hyx hy => hx (h_compl_up y x hy hyx)
    -- All cut points < all compl points
    have h_cut_lt_compl : ∀ x ∈ cut, ∀ y ∈ compl, x < y := by
      intro x hx y hy; by_contra h; push_neg at h
      exact hx (h_compl_up y x hy h)
    have h_proper : cut ≠ Set.univ := by
      intro h; exact hm_not_cut (h ▸ Set.mem_univ m)
    -- Cofinal propagation (dual): body condition left ⟹ compl membership
    have h_cofinal_propagate :
        ∀ u, s < u → u < m →
        (∀ w, u < w → w < m →
          ∃ v, v < w ∧ ∀ z, v < z → z < m → stavi_temporal_truth M atomMap z D) →
        ∃ v, v < u ∧ ∀ z, v < z → z < m → stavi_temporal_truth M atomMap z D := by
      intro u hsu hum h_above
      cases h_body u hsu hum with
      | inl h => exact h
      | inr h =>
        obtain ⟨_, v', huv', hv'm, hDv'⟩ := h
        obtain ⟨v₂, hv₂v', hDv₂⟩ := h_above v' huv' hv'm
        exact absurd (hDv₂ v' hv₂v' hv'm) hDv'
    -- u_init ∈ compl: D on (u_init, m) and body LEFT at u_init
    have h_cofinal_u_init :
        ∃ v, v < u_init ∧ ∀ w, v < w → w < m → stavi_temporal_truth M atomMap w D := by
      cases h_body u_init hsu_init hum_init with
      | inl h => exact h
      | inr h =>
        obtain ⟨_, v', huv', hv'm, hDv'⟩ := h
        exact absurd (hD_init v' huv' hv'm) hDv'
    have hu_init_compl : u_init ∈ compl := by
      intro u huu_init hum
      rcases eq_or_lt_of_le huu_init with rfl | hlt
      · exact h_cofinal_u_init
      · exact ⟨u_init, hlt, fun w hw hwm => hD_init w hw hwm⟩
    -- D at compl points
    have h_D_at_compl : ∀ u, u ∈ compl → u < m →
        stavi_temporal_truth M atomMap u D := by
      intro u hu hum; obtain ⟨v, hvu, hDv⟩ := hu u le_rfl hum
      exact hDv u hvu hum
    -- No sup in cut
    have h_no_sup : ¬∃ p, IsLUB cut p ∧ p ∈ cut := by
      intro ⟨p, ⟨h_ub, _⟩, hp_cut⟩
      have hpm : p < m := h_cut_lt_compl p hp_cut m hm_in_compl
      have hps : s < p := by
        by_contra h; push_neg at h
        exact not_le.mpr (lt_of_le_of_lt h hsu_fail) (h_ub huf_in_cut)
      apply hp_cut
      intro u hpu hum
      rcases eq_or_lt_of_le hpu with rfl | hpu'
      · exact h_cofinal_propagate p hps hum (fun w hpw hwm => by
          have : w ∈ compl := by by_contra hw; exact not_le.mpr hpw (h_ub hw)
          exact this w le_rfl hwm)
      · have : u ∈ compl := by by_contra hu_cut; exact not_le.mpr hpu' (h_ub hu_cut)
        exact this u le_rfl hum
    -- Complement has no minimum
    have h_comp_no_min : ¬∃ b, b ∉ cut ∧ ∀ y, y ∉ cut → b ≤ y := by
      intro ⟨b, hb_compl, hb_min⟩
      have hbm : b < m := by
        rcases eq_or_lt_of_le (hb_min m (fun h => h hm_in_compl)) with rfl | h
        · exact absurd (hb_min u_init (fun h => h hu_init_compl)) (not_le.mpr hum_init)
        · exact h
      have hb_in_compl : b ∈ compl := h_not_cut_compl b hb_compl
      have hsb : s < b := by
        by_contra h; push_neg at h
        have hs_compl := h_compl_up b s hb_in_compl h
        obtain ⟨v, hvu, hDv⟩ := hs_compl u_fail (le_of_lt hsu_fail) hum_fail
        exact hD_fail (hDv u_fail hvu hum_fail)
      cases h_body b hsb hbm with
      | inl h_cof =>
        obtain ⟨v, hvb, hDv⟩ := h_cof
        by_cases hvs : s < v
        · have hvm : v < m := lt_trans hvb hbm
          cases h_body v hvs hvm with
          | inl h2 =>
            obtain ⟨v₂, hv₂v, hDv₂⟩ := h2
            have hv_compl : v ∈ compl := by
              intro u hvu hum
              rcases eq_or_lt_of_le hvu with rfl | hvu'
              · exact ⟨v₂, hv₂v, hDv₂⟩
              · exact ⟨v, hvu', hDv⟩
            exact absurd (hb_min v (h_compl_not_cut v hv_compl)) (not_le.mpr hvb)
          | inr h2 =>
            obtain ⟨_, v', hvv', hv'm, hDv'⟩ := h2
            exact absurd (hDv v' hvv' hv'm) hDv'
        · push_neg at hvs
          exact absurd (hDv u_fail (lt_of_le_of_lt hvs hsu_fail) hum_fail) hD_fail
      | inr h_right =>
        obtain ⟨_, v', hbv', hv'm, hDv'⟩ := h_right
        have hv'_not_compl : v' ∉ compl := by
          intro hv'; exact hDv' (h_D_at_compl v' hv' hv'm)
        exact not_lt.mpr (le_of_lt hbv') (h_cut_lt_compl v' hv'_not_compl b hb_in_compl)
    -- No final-cut segment with D
    have h_no_final_cut : ¬∃ t, t ∈ cut ∧ ∀ u, t ≤ u → u ∈ cut →
        stavi_temporal_truth M atomMap u D := by
      intro ⟨t, ht_cut, hDt⟩
      have htm : t < m := h_cut_lt_compl t ht_cut m hm_in_compl
      have hst : s < t := by
        by_contra h; push_neg at h
        exact hD_fail (hDt u_fail (le_trans h (le_of_lt hsu_fail)) huf_in_cut)
      apply ht_cut
      cases h_body t hst htm with
      | inl h =>
        intro u htu hum
        rcases eq_or_lt_of_le htu with rfl | htu'
        · exact h
        · obtain ⟨v, hvt, hDv⟩ := h
          exact ⟨t, htu', fun w htw hwm => by
            by_cases hw_cut : w ∈ cut
            · exact hDt w (le_of_lt htw) hw_cut
            · exact h_D_at_compl w (h_not_cut_compl w hw_cut) hwm⟩
      | inr h =>
        obtain ⟨_, v', htv', hv'm, hDv'⟩ := h
        by_cases hv'_cut : v' ∈ cut
        · exact absurd (hDt v' (le_of_lt htv') hv'_cut) hDv'
        · exact absurd (h_D_at_compl v' (h_not_cut_compl v' hv'_cut) hv'm) hDv'
    -- Initial complement segment has D
    have h_init_compl : ∃ t, t ∉ cut ∧ ∀ u, u ∉ cut → u ≤ t →
        stavi_temporal_truth M atomMap u D :=
      ⟨u_init, h_compl_not_cut u_init hu_init_compl,
        fun u hu huu => h_D_at_compl u (h_not_cut_compl u hu) (lt_of_le_of_lt huu hum_init)⟩
    -- Build Gap
    let γ_gap : Gap M.carrier :=
      ⟨cut, ⟨u_fail, huf_in_cut⟩, h_proper, h_cut_dc, h_no_sup, h_comp_no_min⟩
    have h_def_right : gap_definable_on_right M atomMap γ_gap D :=
      ⟨h_init_compl, h_no_final_cut⟩
    have h_r_def : r_definable_gap M atomMap γ_gap r :=
      ⟨D, hD, Or.inr h_def_right⟩
    let γ_rdef : RDefinableGap M atomMap r := ⟨γ_gap, h_r_def⟩
    -- X at cut points: from body right disjunct
    have h_X_at_cut : ∀ u : M.carrier, u ∈ cut → u_fail < u →
        stavi_temporal_truth M atomMap u X := by
      intro u hu_cut huf_u
      have hum : u < m := h_cut_lt_compl u hu_cut m hm_in_compl
      have hsu : s < u := lt_trans hsu_fail huf_u
      have ⟨z, hz_cut, huz⟩ : ∃ z ∈ cut, u < z := by
        by_contra h_all; push_neg at h_all
        exact h_no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
      have hzm : z < m := h_cut_lt_compl z hz_cut m hm_in_compl
      have hsz : s < z := lt_trans hsu huz
      have h_right_z : (∀ v, s < v → v < z → stavi_temporal_truth M atomMap v X) ∧
          ∃ v', z < v' ∧ v' < m ∧ ¬stavi_temporal_truth M atomMap v' D := by
        cases h_body z hsz hzm with
        | inl h_left =>
          exfalso; apply hz_cut
          obtain ⟨v, hvz, hDv⟩ := h_left
          intro w hzw hwm; exact ⟨v, lt_of_lt_of_le hvz hzw, hDv⟩
        | inr h_right => exact h_right
      exact h_right_z.1 u hsu huz
    refine ⟨γ_rdef, u_fail, ?_, huf_in_cut, h_def_right, ?_, ?_⟩
    · -- m > γ
      show m ∉ cut ∧ ¬(m ∈ cut); exact ⟨hm_not_cut, hm_not_cut⟩
    · -- D at complement points < m
      intro u hum hu_not
      exact (stavi_truth_mu_at_point u D).mpr (h_D_at_compl u (h_not_cut_compl u hu_not) hum)
    · -- X at cut points above u_fail
      exact fun u hu_cut huf_u => h_X_at_cut u hu_cut huf_u
  · -- **Backward direction** (gap → FO table):
    intro ⟨γ, s_bound, hm_gt_γ, hs_bound_in, h_def_right, h_D_bet, hX_cut⟩
    have hm_not_cut : m ∉ γ.val.cut := by
      intro h; exact not_lt.mpr (show extendPoint m ≤ Sum.inr γ from h) hm_gt_γ
    obtain ⟨⟨t_compl, ht_not_cut, ht_D_init⟩, h_no_final_cut⟩ := h_def_right
    have h_neg_final : ∀ t, t ∈ γ.val.cut →
        ∃ w, w ∈ γ.val.cut ∧ t ≤ w ∧ ¬stavi_temporal_truth M atomMap w D := by
      intro t ht; by_contra h_all; push_neg at h_all
      exact h_no_final_cut ⟨t, ht, fun w hwt hw_cut => h_all w hw_cut hwt⟩
    have h_cut_lt_m : ∀ x, x ∈ γ.val.cut → x < m := by
      intro x hx; by_contra h; push_neg at h
      exact hm_not_cut (γ.val.downward_closed x m hx h)
    -- Complement points above cut: for v ∉ cut, all cut < v
    have h_compl_gt_cut : ∀ v, v ∉ γ.val.cut → ∀ x, x ∈ γ.val.cut → x < v := by
      intro v hv x hx; by_contra h; push_neg at h
      exact hv (γ.val.downward_closed x v hx h)
    -- Use s_bound as s (s_bound ∈ cut, so s_bound < m)
    refine ⟨s_bound, h_cut_lt_m s_bound hs_bound_in, ?_, ?_, ?_⟩
    · -- Condition (1): ∀ u ∈ (s_bound, m), disjunction
      intro u hsu hum
      by_cases hu_cut : u ∈ γ.val.cut
      · -- u ∈ cut: RIGHT disjunct — X on (s_bound, u) and ¬D witness above u
        right
        refine ⟨fun v hsv hvu => ?_, ?_⟩
        · have hv_cut : v ∈ γ.val.cut := γ.val.downward_closed u v hu_cut (le_of_lt hvu)
          exact hX_cut v hv_cut hsv
        · have ⟨z, hz_cut, huz_strict⟩ : ∃ z ∈ γ.val.cut, u < z := by
            by_contra h_all; push_neg at h_all
            exact γ.val.no_sup ⟨u, ⟨fun x hx => h_all x hx, fun b hb => hb hu_cut⟩, hu_cut⟩
          obtain ⟨w₂, hw₂_cut, hz_w₂, hDw₂⟩ := h_neg_final z hz_cut
          exact ⟨w₂, lt_of_lt_of_le huz_strict hz_w₂, h_cut_lt_m w₂ hw₂_cut, hDw₂⟩
      · -- u ∉ cut: LEFT disjunct — D cofinal below u
        left
        have ⟨y, hy_not, hyu⟩ : ∃ y, y ∉ γ.val.cut ∧ y < u := by
          by_contra h_all; push_neg at h_all
          exact γ.val.complement_no_min ⟨u, hu_cut, fun z hz => h_all z hz⟩
        exact ⟨y, hyu, fun w hyw hwm => by
          have hw_not : w ∉ γ.val.cut := by
            intro h; exact hy_not (γ.val.downward_closed w y h (le_of_lt hyw))
          exact (stavi_truth_mu_at_point w D).mp (h_D_bet w hwm hw_not)⟩
    · -- Condition (2): ∃ u ∈ (s_bound, m), ¬D(u)
      have ⟨z, hz_cut, hsz⟩ : ∃ z ∈ γ.val.cut, s_bound < z := by
        by_contra h_all; push_neg at h_all
        exact γ.val.no_sup ⟨s_bound,
          ⟨h_all, fun b hb => hb hs_bound_in⟩, hs_bound_in⟩
      obtain ⟨w, hw_cut, hzw, hDw⟩ := h_neg_final z hz_cut
      exact ⟨w, lt_of_lt_of_le hsz hzw, h_cut_lt_m w hw_cut, hDw⟩
    · -- Condition (3): ∃ u ∈ (s_bound, m), D on (u, m)
      have ⟨y, hy_not, hym⟩ : ∃ y, y ∉ γ.val.cut ∧ y < m := by
        by_contra h_all; push_neg at h_all
        exact γ.val.complement_no_min ⟨m, hm_not_cut, fun z hz => h_all z hz⟩
      have hsy : s_bound < y := h_compl_gt_cut y hy_not s_bound hs_bound_in
      refine ⟨y, hsy, hym, fun v hyv hvm => by
        have hv_not : v ∉ γ.val.cut := by
          intro h; exact hy_not (γ.val.downward_closed v y h (le_of_lt hyv))
        exact (stavi_truth_mu_at_point v D).mp (h_D_bet v hvm hv_not)⟩

-- std_snce_gap_detection: DELETED (provably false, past dual of std_untl_gap_detection).
-- Same issue: S(X,D) has no D-failure condition. See std_untl_gap_detection comment above.

private theorem gap_detection_unique_right {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {γ₁ γ₂ : Gap M.carrier} {D : StaviFormula} {m : M.carrier}
    (h₁_def : gap_definable_on_right M atomMap γ₁ D)
    (h₂_def : gap_definable_on_right M atomMap γ₂ D)
    (h₁_bet : ∀ u : M.carrier, u < m → u ∉ γ₁.cut →
      stavi_temporal_truth M atomMap u D)
    (h₂_bet : ∀ u : M.carrier, u < m → u ∉ γ₂.cut →
      stavi_temporal_truth M atomMap u D)
    (hm₁ : m ∉ γ₁.cut)
    (hm₂ : m ∉ γ₂.cut) :
    γ₁ = γ₂ := by
  apply gap_ext
  by_contra hne
  wlog h : ¬(γ₁.cut ⊆ γ₂.cut) with H
  · push_neg at hne
    rcases gap_cuts_total γ₁ γ₂ with hsub | hsub
    · exact H h₂_def h₁_def h₂_bet h₁_bet hm₂ hm₁ (Ne.symm hne)
        (fun h' => hne (Set.Subset.antisymm hsub h'))
    · exact h (fun h' => hne (Set.Subset.antisymm h' hsub))
  obtain ⟨x, hx₁, hx₂⟩ := Set.not_subset.mp h
  obtain ⟨_, h_no_init⟩ := h₁_def
  apply h_no_init
  refine ⟨x, hx₁, fun u hxu hu_in₁ => ?_⟩
  have hu_not₂ : u ∉ γ₂.cut := by
    intro h'; exact hx₂ (γ₂.downward_closed u x h' hxu)
  have hum : u < m := by
    by_contra h_not; push_neg at h_not
    exact hm₁ (γ₁.downward_closed u m hu_in₁ h_not)
  exact h₂_bet u hum hu_not₂

theorem right_formula_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (A D : StaviFormula) (hD : stavi_depth D ≤ r) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (right_formula A D) ↔
    (∃ (γ : RDefinableGap M atomMap r),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m > Sum.inr γ ∧
      gap_definable_on_right M atomMap γ.val D ∧
      (∀ u : M.carrier, u < m → u ∉ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      stavi_temporal_truth_mu M atomMap r (Sum.inr γ) A) := by
  induction A generalizing m with
  | base φ =>
    simp only [right_formula]
    induction φ with
    | atom a =>
      simp only [right_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | bot =>
      simp only [right_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | box a =>
      simp only [right_formula_base, stavi_temporal_truth_mu, temporal_truth_mu]
      constructor
      · exact False.elim
      · intro ⟨γ, _, _, _, hA⟩; exact hA
    | imp f g ih_f ih_g =>
      -- right_formula_base D (.imp f g) = S'(⊤,D) ∧ ¬(right_base(f) ∧ S'(⊤,D) ∧ ¬right_base(g))
      -- Mirrors left base.imp with stavi_snce_gap_detection
      constructor
      · -- Forward direction
        intro hLHS
        simp only [right_formula_base] at hLHS
        simp only [stavi_temporal_truth_mu] at hLHS
        obtain ⟨hS, hNeg⟩ := hLHS
        have hS' : stavi_temporal_truth_mu M atomMap r (extendPoint m)
            (.stavi_snce (.base Formula.top) D) := by
          simp only [stavi_temporal_truth_mu]; exact hS
        obtain ⟨γ, _s_bound, hγ_lt, _hs_in, hγ_def, hγ_bet, _⟩ :=
          (stavi_snce_gap_detection (.base Formula.top) D hD m).mp hS'
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        simp only [stavi_temporal_truth_mu, temporal_truth_mu]
        intro hf_at_γ
        have hRight_f : stavi_temporal_truth_mu M atomMap r (extendPoint m) (right_formula_base D f) :=
          ih_f.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hf_at_γ⟩
        have hRight_g : stavi_temporal_truth_mu M atomMap r (extendPoint m) (right_formula_base D g) := by
          by_contra h
          exact hNeg ⟨hRight_f, hS, h⟩
        obtain ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hg_at_γ'⟩ := ih_g.mp hRight_g
        have hm_not : m ∉ γ.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
        have hm_not' : m ∉ γ'.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ').mpr h) hγ'_lt
        have hγ_bet_std : ∀ u, u < m → u ∉ γ.val.cut →
            stavi_temporal_truth M atomMap u D :=
          fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not)
        have hγ'_bet_std : ∀ u, u < m → u ∉ γ'.val.cut →
            stavi_temporal_truth M atomMap u D :=
          fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ'_bet u hum hu_not)
        have heq : γ.val = γ'.val :=
          gap_detection_unique_right hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_not hm_not'
        rw [Subtype.ext heq]
        exact hg_at_γ'
      · -- Backward direction
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hfg_at_γ⟩
        simp only [right_formula_base, stavi_temporal_truth_mu]
        constructor
        · -- S'(⊤,D)(m): from γ, construct stavi_snce_gap_detection
          have h_compl : ∃ x, x ∈ γ.val.cut := by
            obtain ⟨x, hx⟩ := γ.val.nonempty
            exact ⟨x, hx⟩
          obtain ⟨s_b, hs_b⟩ := h_compl
          have hTop_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_b < u →
              stavi_temporal_truth M atomMap u (.base Formula.top) := by
            intro u _ _
            simp only [stavi_temporal_truth, temporal_truth, Formula.top]; exact id
          have := (stavi_snce_gap_detection (.base Formula.top) D hD m).mpr
            ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_cut⟩
          simp only [stavi_temporal_truth_mu] at this
          exact this
        · -- ¬(right_base(f) ∧ S'(⊤,D)(m) ∧ ¬right_base(g))
          intro ⟨hRf, _, hNRg⟩
          obtain ⟨γ₁, hγ₁_lt, hγ₁_def, hγ₁_bet, hf_at_γ₁⟩ := ih_f.mp hRf
          have hm_not : m ∉ γ.val.cut := by
            intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
          have hm_not₁ : m ∉ γ₁.val.cut := by
            intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ₁).mpr h) hγ₁_lt
          have hγ_bet_std : ∀ u, u < m → u ∉ γ.val.cut →
              stavi_temporal_truth M atomMap u D :=
            fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not)
          have hγ₁_bet_std : ∀ u, u < m → u ∉ γ₁.val.cut →
              stavi_temporal_truth M atomMap u D :=
            fun u hum hu_not => (stavi_truth_mu_at_point u D).mp (hγ₁_bet u hum hu_not)
          have heq : γ₁.val = γ.val :=
            gap_detection_unique_right hγ₁_def hγ_def hγ₁_bet_std hγ_bet_std hm_not₁ hm_not
          simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hfg_at_γ
          have hg_at_γ := hfg_at_γ ((Subtype.ext heq) ▸ hf_at_γ₁)
          exact hNRg (ih_g.mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hg_at_γ⟩)
    | untl f g _ _ =>
      sorry
    | snce f g _ _ =>
      -- right_formula_base D (.snce f g) = S'(g ∧ S(f,g), D)
      -- Mirrors left base.untl with stavi_snce_gap_detection
      simp only [right_formula_base]
      rw [stavi_snce_gap_detection (.conj (.base g) (.base (.snce f g))) D hD m]
      constructor
      · -- Forward: cut-point truth of g ∧ S(f,g) → S(f,g)^mu at γ
        intro ⟨γ, s_bound, hγ_lt, hs_in, hγ_def, hγ_bet, hX_cut⟩
        refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
        simp only [stavi_temporal_truth_mu, stavi_temporal_truth, temporal_truth_mu]
        -- Need S(f,g)^mu at γ: ∃ s < γ (mu), f^mu(s) ∧ g^mu on (s, γ)
        -- Pick a cut point u₀ above s_bound
        have ⟨u₀, hu₀_in, hu₀s⟩ : ∃ u₀, u₀ ∈ γ.val.cut ∧ s_bound < u₀ := by
          by_contra h_all; push_neg at h_all
          exact γ.val.no_sup ⟨s_bound, ⟨fun z hz => h_all z hz, fun _ hb => hb hs_in⟩, hs_in⟩
        have hX_u₀ := hX_cut u₀ hu₀_in hu₀s
        simp only [stavi_temporal_truth, temporal_truth] at hX_u₀
        obtain ⟨hg_u₀, t₁, ht₁u₀, hf_t₁, hg_between⟩ := hX_u₀
        -- t₁ ∈ cut (since t₁ < u₀ and u₀ ∈ cut, cut is downward closed)
        have ht₁_in : t₁ ∈ γ.val.cut :=
          γ.val.downward_closed u₀ t₁ hu₀_in (le_of_lt ht₁u₀)
        -- Witness: s = extendPoint t₁
        refine ⟨extendPoint t₁, ⟨ht₁_in, fun h => h ht₁_in⟩, ⟨t₁, rfl⟩,
          (temporal_truth_mu_at_point t₁ f).mpr hf_t₁, fun v hvt₁ hvγ hmu => ?_⟩
        obtain ⟨v₀, rfl⟩ := hmu
        have hv₀_in : v₀ ∈ γ.val.cut :=
          (extendPoint_le_gap_iff v₀ γ).mp (le_of_lt hvγ)
        have hv₀_t₁ : t₁ < v₀ := (extendPoint_lt_iff t₁ v₀).mp hvt₁
        apply (temporal_truth_mu_at_point v₀ g).mpr
        by_cases hv_u₀ : v₀ < u₀
        · exact hg_between v₀ hv₀_t₁ hv_u₀
        · push_neg at hv_u₀
          have hv₀_sb : s_bound < v₀ := lt_of_lt_of_le hu₀s hv_u₀
          exact (hX_cut v₀ hv₀_in hv₀_sb).1
      · -- Backward: S(f,g)^mu at γ → cut-point truth of g ∧ S(f,g)
        intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSA⟩
        simp only [stavi_temporal_truth_mu, temporal_truth_mu] at hSA
        obtain ⟨s, hsγ, hmu_s, hf_s, hg_mu⟩ := hSA
        obtain ⟨t₁, rfl⟩ := hmu_s
        have ht₁_in : t₁ ∈ γ.val.cut :=
          (extendPoint_le_gap_iff t₁ γ).mp (le_of_lt hsγ)
        refine ⟨γ, t₁, hγ_lt, ht₁_in, hγ_def, hγ_bet, fun u hu_in hu_t₁ => ?_⟩
        simp only [stavi_temporal_truth, temporal_truth]
        constructor
        · -- g(u): u is a cut point between t₁ and γ
          have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint u) (Sum.inr γ) := by
            exact ⟨hu_in, fun h => h hu_in⟩
          have hut₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint t₁) (extendPoint u) :=
            (extendPoint_lt_iff t₁ u).mpr hu_t₁
          exact (temporal_truth_mu_at_point u g).mp
            (hg_mu (extendPoint u) hut₁ hγu ⟨u, rfl⟩)
        · -- S(f,g)(u): use t₁ as witness
          refine ⟨t₁, hu_t₁, (temporal_truth_mu_at_point t₁ f).mp hf_s, fun v htv hvu => ?_⟩
          have hv_in : v ∈ γ.val.cut := by
            exact γ.val.downward_closed u v hu_in (le_of_lt hvu)
          have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint v) (Sum.inr γ) := ⟨hv_in, fun h => h hv_in⟩
          have hvt₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
              (extendPoint t₁) (extendPoint v) :=
            (extendPoint_lt_iff t₁ v).mpr htv
          exact (temporal_truth_mu_at_point v g).mp
            (hg_mu (extendPoint v) hvt₁ hγv ⟨v, rfl⟩)
  | neg A ih =>
    simp only [right_formula, stavi_temporal_truth_mu]
    constructor
    · intro ⟨hS, hNot⟩
      have hS' : stavi_temporal_truth_mu M atomMap r (extendPoint m)
          (.stavi_snce (.base Formula.top) D) := by
        simp only [stavi_temporal_truth_mu]; exact hS
      obtain ⟨γ, _s_bound, hγ_lt, _hs_in, hγ_def, hγ_bet, _⟩ :=
        (stavi_snce_gap_detection (.base Formula.top) D hD m).mp hS'
      have hNot' : ¬(∃ (γ' : RDefinableGap M atomMap r),
          extendPoint m > Sum.inr γ' ∧
          gap_definable_on_right M atomMap γ'.val D ∧
          (∀ u, u < m → u ∉ γ'.val.cut → stavi_temporal_truth_mu M atomMap r (extendPoint u) D) ∧
          stavi_temporal_truth_mu M atomMap r (Sum.inr γ') A) := by
        rwa [← ih m]
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      intro hA_at_γ
      exact hNot' ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_at_γ⟩
    · intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hNot_A⟩
      constructor
      · have h_compl : ∃ x, x ∈ γ.val.cut := by
          obtain ⟨x, hx⟩ := γ.val.nonempty
          exact ⟨x, hx⟩
        obtain ⟨s_b, hs_b⟩ := h_compl
        have hTop_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_b < u →
            stavi_temporal_truth M atomMap u (.base Formula.top) := by
          intro u _ _
          simp only [stavi_temporal_truth, temporal_truth, Formula.top]; exact id
        have := (stavi_snce_gap_detection (.base Formula.top) D hD m).mpr
          ⟨γ, s_b, hγ_lt, hs_b, hγ_def, hγ_bet, hTop_cut⟩
        simp only [stavi_temporal_truth_mu] at this
        exact this
      · rw [ih m]
        intro ⟨γ', hγ'_lt, hγ'_def, hγ'_bet, hA_at_γ'⟩
        have hm_not : m ∉ γ.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ).mpr h) hγ_lt
        have hm_not' : m ∉ γ'.val.cut := by
          intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γ').mpr h) hγ'_lt
        have hγ_bet_std : ∀ u, u < m → u ∉ γ.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hum hu_not
          exact (stavi_truth_mu_at_point u D).mp (hγ_bet u hum hu_not)
        have hγ'_bet_std : ∀ u, u < m → u ∉ γ'.val.cut →
            stavi_temporal_truth M atomMap u D := by
          intro u hum hu_not
          exact (stavi_truth_mu_at_point u D).mp (hγ'_bet u hum hu_not)
        have heq : γ.val = γ'.val :=
          gap_detection_unique_right hγ_def hγ'_def hγ_bet_std hγ'_bet_std hm_not hm_not'
        have : γ = γ' := Subtype.ext heq
        rw [this] at hNot_A
        exact hNot_A hA_at_γ'
  | conj A B ihA ihB =>
    simp only [right_formula, stavi_temporal_truth_mu]
    constructor
    · intro ⟨hA, hB⟩
      obtain ⟨γA, hγA_lt, hγA_def, hγA_bet, hγA_val⟩ := (ihA m).mp hA
      obtain ⟨γB, hγB_lt, hγB_def, hγB_bet, hγB_val⟩ := (ihB m).mp hB
      have hm_not_A : m ∉ γA.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γA).mpr h) hγA_lt
      have hm_not_B : m ∉ γB.val.cut := by
        intro h; exact not_lt.mpr ((extendPoint_le_gap_iff m γB).mpr h) hγB_lt
      have hγA_bet' : ∀ u, u < m → u ∉ γA.val.cut →
          stavi_temporal_truth M atomMap u D := by
        intro u hum hu_not
        exact (stavi_truth_mu_at_point u D).mp (hγA_bet u hum hu_not)
      have hγB_bet' : ∀ u, u < m → u ∉ γB.val.cut →
          stavi_temporal_truth M atomMap u D := by
        intro u hum hu_not
        exact (stavi_truth_mu_at_point u D).mp (hγB_bet u hum hu_not)
      have heq : γA.val = γB.val :=
        gap_detection_unique_right hγA_def hγB_def hγA_bet' hγB_bet' hm_not_A hm_not_B
      refine ⟨γA, hγA_lt, hγA_def, hγA_bet, ?_, ?_⟩
      · exact hγA_val
      · have : γA = γB := Subtype.ext heq
        rw [this]
        exact hγB_val
    · intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val, hB_val⟩
      exact ⟨(ihA m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hA_val⟩,
             (ihB m).mpr ⟨γ, hγ_lt, hγ_def, hγ_bet, hB_val⟩⟩
  | stavi_untl A B _ _ =>
    sorry
  | stavi_snce A B _ _ =>
    -- right_formula (.stavi_snce A B) D = S'(B ∧ S'(A,B), D)
    -- Mirrors left's stavi_untl case with stavi_snce_gap_detection
    simp only [right_formula]
    constructor
    · intro h
      obtain ⟨γ, s_bound, hγ_lt, hs_in, hγ_def, hγ_bet, hX_cut⟩ :=
        (stavi_snce_gap_detection (.conj B (.stavi_snce A B)) D hD m).mp h
      have hSA_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_bound < u →
          stavi_temporal_truth M atomMap u (.stavi_snce A B) :=
        fun u hu hus => (hX_cut u hu hus).2
      have hB_cut : ∀ u : M.carrier, u ∈ γ.val.cut → s_bound < u →
          stavi_temporal_truth M atomMap u B :=
        fun u hu hus => (hX_cut u hu hus).1
      sorry
    · intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSA⟩
      sorry
  | std_untl A B _ _ =>
    sorry
  | std_snce A B _ _ =>
    -- right_formula (.std_snce A B) D = S'(B ∧ S(A,B), D)
    -- Same pattern as base.snce with S(A,B) instead of S(f,g)
    simp only [right_formula]
    rw [stavi_snce_gap_detection (.conj B (.std_snce A B)) D hD m]
    constructor
    · -- Forward: cut-point truth of B ∧ S(A,B) → S(A,B)^mu at γ
      intro ⟨γ, s_bound, hγ_lt, hs_in, hγ_def, hγ_bet, hX_cut⟩
      refine ⟨γ, hγ_lt, hγ_def, hγ_bet, ?_⟩
      simp only [stavi_temporal_truth_mu, stavi_temporal_truth, temporal_truth_mu]
      have ⟨u₀, hu₀_in, hu₀s⟩ : ∃ u₀, u₀ ∈ γ.val.cut ∧ s_bound < u₀ := by
        by_contra h_all; push_neg at h_all
        exact γ.val.no_sup ⟨s_bound, ⟨fun z hz => h_all z hz, fun _ hb => hb hs_in⟩, hs_in⟩
      have hX_u₀ := hX_cut u₀ hu₀_in hu₀s
      simp only [stavi_temporal_truth, temporal_truth] at hX_u₀
      obtain ⟨hB_u₀, t₁, ht₁u₀, hA_t₁, hB_between⟩ := hX_u₀
      have ht₁_in : t₁ ∈ γ.val.cut :=
        γ.val.downward_closed u₀ t₁ hu₀_in (le_of_lt ht₁u₀)
      refine ⟨extendPoint t₁, ⟨ht₁_in, fun h => h ht₁_in⟩, ⟨t₁, rfl⟩,
        (stavi_truth_mu_at_point t₁ A).mpr hA_t₁, fun v hvt₁ hvγ hmu => ?_⟩
      obtain ⟨v₀, rfl⟩ := hmu
      have hv₀_in : v₀ ∈ γ.val.cut :=
        (extendPoint_le_gap_iff v₀ γ).mp (le_of_lt hvγ)
      have hv₀_t₁ : t₁ < v₀ := (extendPoint_lt_iff t₁ v₀).mp hvt₁
      apply (stavi_truth_mu_at_point v₀ B).mpr
      by_cases hv_u₀ : v₀ < u₀
      · exact hB_between v₀ hv₀_t₁ hv_u₀
      · push_neg at hv_u₀
        have hv₀_sb : s_bound < v₀ := lt_of_lt_of_le hu₀s hv_u₀
        exact (hX_cut v₀ hv₀_in hv₀_sb).1
    · -- Backward: S(A,B)^mu at γ → cut-point truth of B ∧ S(A,B)
      intro ⟨γ, hγ_lt, hγ_def, hγ_bet, hSA⟩
      simp only [stavi_temporal_truth_mu] at hSA
      obtain ⟨s, hsγ, hmu_s, hA_s, hB_mu⟩ := hSA
      obtain ⟨t₁, rfl⟩ := hmu_s
      have ht₁_in : t₁ ∈ γ.val.cut :=
        (extendPoint_le_gap_iff t₁ γ).mp (le_of_lt hsγ)
      refine ⟨γ, t₁, hγ_lt, ht₁_in, hγ_def, hγ_bet, fun u hu_in hu_t₁ => ?_⟩
      simp only [stavi_temporal_truth]
      constructor
      · have hγu : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint u) (Sum.inr γ) := ⟨hu_in, fun h => h hu_in⟩
        have hut₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t₁) (extendPoint u) :=
          (extendPoint_lt_iff t₁ u).mpr hu_t₁
        exact (stavi_truth_mu_at_point u B).mp
          (hB_mu (extendPoint u) hut₁ hγu ⟨u, rfl⟩)
      · refine ⟨t₁, hu_t₁, (stavi_truth_mu_at_point t₁ A).mp hA_s, fun v htv hvu => ?_⟩
        have hv_in : v ∈ γ.val.cut :=
          γ.val.downward_closed u v hu_in (le_of_lt hvu)
        have hγv : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint v) (Sum.inr γ) := ⟨hv_in, fun h => h hv_in⟩
        have hvt₁ : @LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT
            (extendPoint t₁) (extendPoint v) :=
          (extendPoint_lt_iff t₁ v).mpr htv
        exact (stavi_truth_mu_at_point v B).mp
          (hB_mu (extendPoint v) hvt₁ hγv ⟨v, rfl⟩)

/-! ## Custom Game G_{n;r} (GHR93 Definition 8.7)

The custom game G_{n;r}(M, x y; N, x' y') is played on the extended
structures M_r and N_r between bounds x < y in M_r, x' < y' in N_r.

**Round 1 (bulk selection):** Spoiler chooses n elements a_1,...,a_n from
the closed interval [x,y] in M_r (these can be actual points OR gaps).
Duplicator responds with n elements a'_1,...,a'_n from [x',y'] in N_r.

**Round 2 (point challenge):** Spoiler chooses one actual point b' from
[x',y'] ∩ N (NOT a gap). Duplicator responds with actual point b from
[x,y] ∩ M.

**Winning condition:** Duplicator wins iff:
1. Same order type: the tuples (x, y, a_1..a_n, b) and (x', y', a'_1..a'_n, b')
   have the same relative ordering.
2. For each pair of corresponding elements (t, t'): gap↔gap status matches,
   and for all temporal formulas A of rank ≤ r, A^mu(t) ↔ A^mu(t').

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Definition 8.7
- Task 155 plan: Phase 4B, Task 4B.5
-/

/-- An element of the extended carrier M_r is in the closed interval [x, y]. -/
def inClosedInterval {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    (x y : ExtendedCarrier M atomMap r) (e : ExtendedCarrier M atomMap r) : Prop :=
  x ≤ e ∧ e ≤ y

/-- rank_embed preserves inClosedInterval. -/
theorem rank_embed_inClosedInterval {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r r' : Nat} (h : r ≤ r')
    (x y e : ExtendedCarrier M atomMap r) :
    inClosedInterval (rank_embed h x) (rank_embed h y) (rank_embed h e) ↔
    inClosedInterval x y e := by
  simp [inClosedInterval, rank_embed_le]

/-- Between two strictly ordered gaps (e₁ < e₂ where eᵢ = Sum.inr gᵢ), there exists
    an actual point between them. Since g₁.cut ⊊ g₂.cut, take q ∈ g₂.cut \ g₁.cut. -/
theorem point_between_strict_gaps {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {e₁ e₂ : ExtendedCarrier M atomMap r}
    {g₁ g₂ : RDefinableGap M atomMap r}
    (he₁ : e₁ = Sum.inr g₁) (he₂ : e₂ = Sum.inr g₂)
    (h : e₁ < e₂) :
    ∃ (p : M.carrier), inClosedInterval e₁ e₂
        (extendPoint (sig := sig) (atomMap := atomMap) (r := r) p) := by
  subst he₁; subst he₂
  have hnsub : ¬(g₂.val.cut ⊆ g₁.val.cut) := fun h' =>
    h.ne (le_antisymm h.le h')
  obtain ⟨q, hq₂, hq₁⟩ := Set.not_subset.mp hnsub
  exact ⟨q, show extendedLE (Sum.inr g₁) (Sum.inl q) from hq₁,
         show extendedLE (Sum.inl q) (Sum.inr g₂) from hq₂⟩

/-- If a gap g is strictly between endpoints a < Sum.inr g < b, and [a, b] contains
    an actual point, then both sub-intervals [a, Sum.inr g] and [Sum.inr g, b]
    contain actual points. -/
theorem gap_splits_interval_points {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {r : Nat}
    {g : RDefinableGap M atomMap r}
    {a b eg : ExtendedCarrier M atomMap r}
    (heg : eg = Sum.inr g)
    (hag : a < eg) (hgb : eg < b)
    (h_pt : ∃ (p : M.carrier), inClosedInterval a b (extendPoint p)) :
    (∃ (p : M.carrier), inClosedInterval a eg (extendPoint p)) ∧
    (∃ (p : M.carrier), inClosedInterval eg b (extendPoint p)) := by
  obtain ⟨p, hp_lo, hp_hi⟩ := h_pt
  rcases le_or_lt (extendPoint p) eg with h | h
  · -- p ≤ g: p witnesses [a, g], need point in [g, b]
    refine ⟨⟨p, hp_lo, h⟩, ?_⟩
    rcases isPoint_or_isGap b with ⟨b_pt, hb_pt⟩ | ⟨g_b, hg_b⟩
    · rw [hb_pt] at hgb ⊢
      exact ⟨b_pt, hgb.le, le_refl _⟩
    · rw [heg, hg_b] at hgb ⊢
      exact point_between_strict_gaps rfl rfl hgb
  · -- p > g: p witnesses [g, b], need point in [a, g]
    refine ⟨?_, ⟨p, h.le, hp_hi⟩⟩
    rcases isPoint_or_isGap a with ⟨a_pt, ha_pt⟩ | ⟨g_a, hg_a⟩
    · rw [ha_pt] at hag ⊢
      exact ⟨a_pt, le_refl _, hag.le⟩
    · rw [heg, hg_a] at hag ⊢
      exact point_between_strict_gaps rfl rfl hag

/-- The "all positions" tuple for the game: boundary elements x, y, the n
    selected elements a_i, and the challenge point b, collected as a
    function from Fin (n + 3) into ExtendedCarrier. The convention is:
    index 0 = x, index (n+1) = b, index (n+2) = y, indices 1..n = a_i.
    This representation makes order comparisons uniform. -/
noncomputable def game_tuple {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n : Nat}
    (x y : ExtendedCarrier M atomMap r) (a : Fin n → ExtendedCarrier M atomMap r)
    (b : M.carrier) : Fin (n + 3) → ExtendedCarrier M atomMap r :=
  fun i =>
    if h0 : i.val = 0 then x
    else if hn1 : i.val = n + 1 then extendPoint b
    else if hn2 : i.val = n + 2 then y
    else a ⟨i.val - 1, by omega⟩

/-- Order type agreement between two game tuples: for all pairs of indices,
    the order relation (lt, eq, gt) is the same. -/
def same_order_type {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (n : Nat)
    (tM : Fin (n + 3) → ExtendedCarrier M atomMap r)
    (tN : Fin (n + 3) → ExtendedCarrier N atomMap r) : Prop :=
  ∀ (i j : Fin (n + 3)),
    (tM i < tM j ↔ tN i < tN j) ∧
    (tM i = tM j ↔ tN i = tN j)

/-- Formula agreement at corresponding positions: for all StaviFormulas A
    of depth ≤ r, A^mu holds at tM(i) iff A^mu holds at tN(i). -/
def formula_agreement {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (n : Nat)
    (tM : Fin (n + 3) → ExtendedCarrier M atomMap r)
    (tN : Fin (n + 3) → ExtendedCarrier N atomMap r) : Prop :=
  ∀ (i : Fin (n + 3)) (A : StaviFormula), stavi_depth A ≤ r →
    (stavi_temporal_truth_mu M atomMap r (tM i) A ↔
     stavi_temporal_truth_mu N atomMap r (tN i) A)

/-- Gap/point status agreement: for all pairs of corresponding elements,
    one is a point iff the other is a point (and similarly for gaps). -/
def gap_point_agreement {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (n : Nat)
    (tM : Fin (n + 3) → ExtendedCarrier M atomMap r)
    (tN : Fin (n + 3) → ExtendedCarrier N atomMap r) : Prop :=
  ∀ (i : Fin (n + 3)),
    (IsPoint (tM i) ↔ IsPoint (tN i)) ∧
    (IsGap (tM i) ↔ IsGap (tN i))

/-- The winning condition for the game G_{n;r}: order type agreement,
    gap/point status agreement, and rank-r formula agreement at all
    corresponding positions in the game tuples. -/
def ghr93_winning_condition {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (n : Nat)
    (tM : Fin (n + 3) → ExtendedCarrier M atomMap r)
    (tN : Fin (n + 3) → ExtendedCarrier N atomMap r) : Prop :=
  same_order_type n tM tN ∧
  gap_point_agreement n tM tN ∧
  formula_agreement n tM tN

/-- **GHR93 Definition 8.7**: Duplicator has a winning strategy for the custom
    game G_{n;r}(M, x y; N, x' y').

    This encodes the game as a Prop: for all ways Spoiler can play, Duplicator
    has a response that satisfies the winning condition.

    The game has two rounds:
    - Round 1 (bulk selection): Spoiler picks n elements from [x,y]_r;
      Duplicator responds with n elements from [x',y']_r.
    - Round 2 (point challenge): Spoiler picks an actual point b' from [x',y'] ∩ N;
      Duplicator responds with an actual point b from [x,y] ∩ M.

    Duplicator wins iff the resulting tuples have the same order type,
    gap/point status agreement, and rank-r formula agreement. -/
def ghr93_duplicator_wins {sig : MonadicSignature}
    (M N : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (n r : Nat)
    (x y : ExtendedCarrier M atomMap r) (x' y' : ExtendedCarrier N atomMap r) : Prop :=
  -- For all ways Spoiler can pick n elements from [x,y]_r...
  ∀ (a : Fin n → ExtendedCarrier M atomMap r),
    (∀ i, inClosedInterval x y (a i)) →
    -- Duplicator can respond with n elements from [x',y']_r...
    ∃ (a' : Fin n → ExtendedCarrier N atomMap r),
      (∀ i, inClosedInterval x' y' (a' i)) ∧
      -- For all point challenges by Spoiler in [x',y'] ∩ N...
      ∀ (b' : N.carrier),
        inClosedInterval x' y' (extendPoint b') →
        -- Duplicator can respond with a point in [x,y] ∩ M...
        ∃ (b : M.carrier),
          inClosedInterval x y (extendPoint b) ∧
          -- ...such that the winning condition is satisfied
          ghr93_winning_condition n
            (game_tuple x y a b)
            (game_tuple x' y' a' b')

/-- When both endpoints of a sub-interval are the same gap, the backward game
    is vacuously won. Round 1 requires Spoiler to pick elements from [e_M, e_M],
    which forces all selections equal to e_M; Duplicator responds with e_N.
    Round 2 requires Spoiler to pick an actual M-point from [e_M, e_M], but
    e_M is a gap, so no actual point exists in the degenerate interval.
    The universal quantifier over the empty domain is vacuously true.

    This handles degenerate sub-intervals arising when the split point d
    equals a boundary (x' = d or d = y') and both are gaps. -/
theorem ghr93_duplicator_wins_degenerate_gap {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {e_N : ExtendedCarrier N atomMap r}
    {e_M : ExtendedCarrier M atomMap r}
    (h_gap_N : IsGap e_N) (h_gap_M : IsGap e_M)
    (h_form : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu N atomMap r e_N A ↔
       stavi_temporal_truth_mu M atomMap r e_M A))
    (h_gp : (IsPoint e_N ↔ IsPoint e_M) ∧ (IsGap e_N ↔ IsGap e_M)) :
    ghr93_duplicator_wins N M atomMap n r e_N e_N e_M e_M := by
  -- In ghr93_duplicator_wins N M ... e_N e_N e_M e_M:
  -- First structure = N, so x,y = e_N, a picks from N's ExtendedCarrier in [e_N,e_N]
  -- Second structure = M, so x',y' = e_M, responses in M's ExtendedCarrier in [e_M,e_M]
  -- Round 2: Spoiler picks b' : M.carrier from [e_M,e_M], which is impossible when e_M is a gap
  intro a ha
  -- All a(i) = e_N (forced by [e_N, e_N])
  have ha_eq : ∀ i, a i = e_N := fun i => le_antisymm (ha i).2 (ha i).1
  -- Respond with all e_M
  refine ⟨fun _ => e_M, fun _ => ⟨le_refl _, le_refl _⟩, ?_⟩
  -- Round 2: for all actual M-points b' in [e_M, e_M]...
  intro b' hb'
  -- e_M is a gap: e_M = Sum.inr g for some g
  obtain ⟨g_M, hg_M⟩ := h_gap_M
  -- inClosedInterval gives e_M ≤ extendPoint b' ≤ e_M, so extendPoint b' = e_M
  have h_eq : extendPoint (sig := sig) (atomMap := atomMap) (r := r) b' = e_M :=
    le_antisymm hb'.2 hb'.1
  -- But extendPoint b' = Sum.inl b' while e_M = Sum.inr g_M: contradiction
  exact absurd (h_eq.symm ▸ hg_M : extendPoint b' = Sum.inr g_M)
    (by simp [extendPoint])

/-! ### Lemma 10: Monotonicity of the Custom Game

GHR93 Lemma 10 states: if Duplicator wins G_{n;r}(M,xy; N,x'y'), then she
also wins G_{n';r'}(M,xy; N,x'y') for any n' <= n, r' <= r, provided x,y
are in M_{r'} and x',y' are in N_{r'}.

Since `ExtendedCarrier M atomMap r` depends on r as a type parameter,
rank monotonicity across different r values would require coercion maps
between M_r and M_{r'}. We formalize round monotonicity (n' <= n at the
same r), which is the version primarily used in Phase 4C (Theorem 6 and
Proposition 7). Full rank+round monotonicity can be added when needed
with the appropriate coercion infrastructure.

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Lemma 10
- Task 155 plan: Phase 4B, Task 4B.5
-/

/-- Helper: embedding from Fin (n'+3) to Fin (n+3) for round monotonicity.
    Maps 0 -> 0, i (1..n') -> i, n'+1 -> n+1, n'+2 -> n+2.
    This preserves game_tuple values between the n'-game and the padded n-game. -/
private def round_mono_emb (n n' : Nat) (hn : n' ≤ n) :
    Fin (n' + 3) → Fin (n + 3) := fun j =>
  if j.val = 0 then ⟨0, by omega⟩
  else if j.val ≤ n' then ⟨j.val, by omega⟩
  else if j.val = n' + 1 then ⟨n + 1, by omega⟩
  else ⟨n + 2, by omega⟩

/-- The game_tuple for the n'-game at index j equals the game_tuple for the
    padded n-game at the embedded index, for the M-side elements. -/
private theorem game_tuple_emb_eq_M {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n n' : Nat} (hn : n' ≤ n)
    (x y : ExtendedCarrier M atomMap r) (a : Fin n' → ExtendedCarrier M atomMap r)
    (b : M.carrier) (j : Fin (n' + 3)) :
    game_tuple x y a b j =
    game_tuple x y (fun i => if hi : i.val < n' then a ⟨i.val, hi⟩ else x) b
      (round_mono_emb n n' hn j) := by
  simp only [game_tuple, round_mono_emb]
  -- 4 cases for j: j=0, 1≤j≤n', j=n'+1, j=n'+2
  have hj_bound := j.isLt  -- j.val < n' + 3
  by_cases h0 : j.val = 0
  · -- j = 0: LHS = x (via dif_pos h0), RHS = x (emb gives ⟨0,_⟩, dif_pos)
    simp [h0]
  · by_cases h_n1 : j.val = n' + 1
    · -- j = n'+1: LHS = extendPoint b, RHS: emb gives ⟨n+1,_⟩ -> extendPoint b
      simp [h_n1]
    · by_cases h_n2 : j.val = n' + 2
      · -- j = n'+2: LHS = y, RHS: emb gives ⟨n+2,_⟩ -> y
        simp [h_n2]
      · -- 1 ≤ j ≤ n': LHS = a ⟨j-1,_⟩, RHS: emb gives ⟨j,_⟩ -> a_pad(j-1) = a(j-1)
        have hle : j.val ≤ n' := by omega
        simp [h0, hle, h_n1, h_n2]
        have : ¬(j.val = n + 1) := by omega
        have : ¬(j.val = n + 2) := by omega
        simp [*]
        have hlt : j.val - 1 < n' := by omega
        simp [hlt]

/-- The game_tuple for the n'-game at index j equals the game_tuple for the
    restricted n-game at the embedded index, for the N-side elements. -/
private theorem game_tuple_emb_eq_N {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n n' : Nat} (hn : n' ≤ n)
    (x' y' : ExtendedCarrier N atomMap r) (a'_full : Fin n → ExtendedCarrier N atomMap r)
    (b' : N.carrier) (j : Fin (n' + 3)) :
    game_tuple x' y' (fun i : Fin n' => a'_full ⟨i.val, Nat.lt_of_lt_of_le i.isLt hn⟩) b' j =
    game_tuple x' y' a'_full b' (round_mono_emb n n' hn j) := by
  simp only [game_tuple, round_mono_emb]
  have hj_bound := j.isLt
  by_cases h0 : j.val = 0
  · simp [h0]
  · by_cases h_n1 : j.val = n' + 1
    · simp [h_n1]
    · by_cases h_n2 : j.val = n' + 2
      · simp [h_n2]
      · have hle : j.val ≤ n' := by omega
        simp [h0, hle, h_n1, h_n2]
        have : ¬(j.val = n + 1) := by omega
        have : ¬(j.val = n + 2) := by omega
        simp [*]

theorem ghr93_duplicator_wins_round_mono {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n n' r : Nat} (hn : n' ≤ n)
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (h : ghr93_duplicator_wins M N atomMap n r x y x' y') :
    ghr93_duplicator_wins M N atomMap n' r x y x' y' := by
  -- Strategy: pad the n'-element selection to n elements using x,
  -- apply the n-element strategy, then restrict the response.
  unfold ghr93_duplicator_wins at h ⊢
  intro a ha
  -- Pad: embed n' elements into n positions, fill remaining with x
  let a_pad : Fin n → ExtendedCarrier M atomMap r := fun i =>
    if hi : i.val < n' then a ⟨i.val, hi⟩ else x
  have ha_pad : ∀ i, inClosedInterval x y (a_pad i) := by
    intro i; simp only [a_pad]; split
    · exact ha ⟨i.val, ‹_›⟩
    · exact ⟨le_refl x, hxy⟩
  -- Apply the n-round winning strategy
  obtain ⟨a'_full, ha'_full, hwin⟩ := h a_pad ha_pad
  -- Restrict the response to the first n' elements
  let a'_res : Fin n' → ExtendedCarrier N atomMap r := fun i =>
    a'_full ⟨i.val, Nat.lt_of_lt_of_le i.isLt hn⟩
  refine ⟨a'_res, ?_, ?_⟩
  -- Goal 1: a'_res elements are in [x', y']
  · intro i; exact ha'_full ⟨i.val, Nat.lt_of_lt_of_le i.isLt hn⟩
  -- Goal 2: winning condition transfers from n to n'
  · intro b' hb'
    obtain ⟨b, hb, hcond⟩ := hwin b' hb'
    refine ⟨b, hb, ?_⟩
    -- Transfer via the embedding: game_tuple values at embedded indices agree
    have h_eq_M := game_tuple_emb_eq_M hn x y a b
    have h_eq_N := game_tuple_emb_eq_N hn x' y' a'_full b'
    unfold ghr93_winning_condition at hcond ⊢
    obtain ⟨hord, hgp, hform⟩ := hcond
    refine ⟨?_, ?_, ?_⟩
    -- same_order_type: transfer via embedding
    · unfold same_order_type at hord ⊢
      intro i j
      rw [h_eq_M i, h_eq_M j, h_eq_N i, h_eq_N j]
      exact hord (round_mono_emb n n' hn i) (round_mono_emb n n' hn j)
    -- gap_point_agreement: transfer via embedding
    · unfold gap_point_agreement at hgp ⊢
      intro i
      rw [h_eq_M i, h_eq_N i]
      exact hgp (round_mono_emb n n' hn i)
    -- formula_agreement: transfer via embedding
    · unfold formula_agreement at hform ⊢
      intro i A hA
      rw [h_eq_M i, h_eq_N i]
      exact hform (round_mono_emb n n' hn i) A hA

/-! ## Strategy Restriction (GHR93 Theorem 6 Infrastructure)

Given that Duplicator wins the game G_{n+1;r} on the full interval [x,y] vs
[x',y'], and a split point c in [x,y], we can restrict the strategy to the
sub-interval [x,c] (resp. [c,y]) with n rounds. The theorem PRODUCES the
corresponding N-side split point d as the strategy's response to c.

### Design Note: d Produced vs d Given

The original formulation took d as a parameter (with type and gap/point
agreement hypotheses). Analysis showed this is unprovable without either
(a) the GHR93 infimum construction (requiring ConditionallyCompleteLattice
on ExtendedCarrier), or (b) a hypothesis tying d to the strategy's response.

The current formulation takes approach (b): d is defined as the strategy's
response to c in the canonical play (all selections = c). The key hypothesis
`h_d_consistent` requires that for ANY padded selection with c at the last
position, the strategy's response at that position equals d. This consistency
condition must be provided by the caller.

In the GHR93 paper, this consistency follows from defining d as an infimum.
In our formulation, the caller constructs d and proves consistency using the
specific properties of their construction (e.g., d = a_bwd(n) in
obtain_split_point_props).

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Theorem 6 proof
- Task 155 plan: Phase 4C, Task 4C.2
- Research report: specs/155.../reports/11_split-props-analysis.md, Section Q2
-/

/-- Helper: index embedding from the n-game (Fin (n+3)) to the (n+1)-game
    (Fin (n+4)) for strategy restriction (left version).

    Maps: 0 -> 0, 1..n -> 1..n, n+1 -> n+2, n+2 -> n+1.

    This preserves game_tuple values: at indices 0..n the elements are the
    same (x and a(0)..a(n-1)). At n+1 (challenge point b), the full game
    has b at n+2. At n+2 (boundary c/d), the full game has a_pad(n) = c
    at n+1 (and a'_full(n) = d at n+1 on the N-side). -/
private def restrict_emb_left (n : Nat) : Fin (n + 3) → Fin (n + 4) := fun i =>
  if i.val ≤ n then ⟨i.val, by omega⟩
  else if i.val = n + 1 then ⟨n + 2, by omega⟩
  else ⟨n + 1, by omega⟩ -- i = n + 2

/-- game_tuple values agree between the restricted n-game and the full
    (n+1)-game at embedded indices, for the M-side. -/
private theorem restrict_left_game_tuple_M {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n : Nat} {x y : ExtendedCarrier M atomMap r}
    {c : ExtendedCarrier M atomMap r}
    (a : Fin n → ExtendedCarrier M atomMap r) (b : M.carrier)
    (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r)
    (ha_pad_eq : ∀ i : Fin n, a_pad ⟨i.val, by omega⟩ = a i)
    (hc_last : a_pad ⟨n, by omega⟩ = c)
    (j : Fin (n + 3)) :
    game_tuple x c a b j = game_tuple x y a_pad b (restrict_emb_left n j) := by
  simp only [game_tuple, restrict_emb_left]
  have hj := j.isLt  -- j.val < n + 3
  by_cases h0 : j.val = 0
  · simp [h0]
  · by_cases h_le_n : j.val ≤ n
    · have : j.val ≠ n + 1 := by omega
      have : j.val ≠ n + 2 := by omega
      have : j.val ≠ n + 1 + 1 := by omega
      have : j.val ≠ n + 1 + 2 := by omega
      simp [*]
      exact (ha_pad_eq ⟨j.val - 1, by omega⟩).symm
    · by_cases h_n1 : j.val = n + 1
      · simp [*]
      · have h_n2 : j.val = n + 2 := by omega
        have : ¬(j.val ≤ n) := by omega
        simp [*]

/-- game_tuple values agree between the restricted n-game and the full
    (n+1)-game at embedded indices, for the N-side (when d = a'_full(n)). -/
private theorem restrict_left_game_tuple_N {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n : Nat} {x' y' : ExtendedCarrier N atomMap r}
    {d : ExtendedCarrier N atomMap r}
    (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r) (b' : N.carrier)
    (hd_eq : a'_full ⟨n, by omega⟩ = d)
    (j : Fin (n + 3)) :
    game_tuple x' d (fun i : Fin n => a'_full ⟨i.val, by omega⟩) b' j =
    game_tuple x' y' a'_full b' (restrict_emb_left n j) := by
  simp only [game_tuple, restrict_emb_left]
  have hj := j.isLt
  by_cases h0 : j.val = 0
  · simp [h0]
  · by_cases h_le_n : j.val ≤ n
    · have : j.val ≠ n + 1 := by omega
      have : j.val ≠ n + 2 := by omega
      have : j.val ≠ n + 1 + 1 := by omega
      have : j.val ≠ n + 1 + 2 := by omega
      simp [*]
    · by_cases h_n1 : j.val = n + 1
      · simp [*]
      · have h_n2 : j.val = n + 2 := by omega
        have : ¬(j.val ≤ n) := by omega
        simp [*]

/-- **Strategy restriction, left sub-interval**:
    If for every Spoiler selection from [x,y] ending with c at position n,
    there exists a Duplicator response in [x',y'] satisfying the winning
    condition AND whose n-th element equals d, then Duplicator wins G_{n;r}
    on [x,c] vs [x',d].

    The hypothesis `h_d_consistent` provides both the forward strategy
    response AND the d-consistency guarantee in existential form: for any
    padded selection ending with c, THERE EXISTS a response where the
    boundary element equals d. This is weaker than requiring ALL winning
    responses to have this property (which would need the full GHR93 Claim 1
    infimum argument).

    The consumer only needs ONE specific response with the d-consistency
    property, so the existential form suffices. -/
theorem ghr93_strategy_restrict_left {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
    (hxc : x ≤ c) (hcy : c ≤ y) (hx'd : x' ≤ d) (hdy' : d ≤ y')
    (hcd_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
    (h_d_consistent : ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a_pad i)) →
      a_pad ⟨n, by omega⟩ = c →
      ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
        (∀ i, inClosedInterval x' y' (a'_full i)) ∧
        (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
          ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
            ghr93_winning_condition (n + 1)
              (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
        a'_full ⟨n, by omega⟩ = d)
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p)) :
    ghr93_duplicator_wins M N atomMap n r x c x' d := by
  unfold ghr93_duplicator_wins at *
  intro a ha
  -- Pad: a_1,...,a_n from [x,c], plus c as element n+1
  let a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if hi : i.val < n then a ⟨i.val, hi⟩ else c
  have ha_pad : ∀ i, inClosedInterval x y (a_pad i) := by
    intro i; simp only [a_pad]
    split
    · obtain ⟨hlo, hhi⟩ := ha ⟨i.val, ‹_›⟩
      exact ⟨hlo, le_trans hhi hcy⟩
    · exact ⟨hxc, hcy⟩
  have hc_last : a_pad ⟨n, by omega⟩ = c := by
    simp [a_pad, show ¬(n < n) from by omega]
  have ha_pad_eq : ∀ i : Fin n, a_pad ⟨i.val, by omega⟩ = a i := by
    intro i; simp [a_pad, i.isLt]
  -- Apply d-consistency (existential form) to get response with a'_full(n) = d
  obtain ⟨a'_full, ha'_full, hwin_full, hd_eq⟩ := h_d_consistent a_pad ha_pad hc_last
  -- Extract the first n responses as our restricted response
  let a'_res : Fin n → ExtendedCarrier N atomMap r := fun i =>
    a'_full ⟨i.val, by omega⟩
  -- Response containment: a'_res(i) ≤ d for all i
  -- This now follows from same_order_type + hd_eq, using any b' witness.
  refine ⟨a'_res, ?_, ?_⟩
  · -- Show a'_res elements are in [x',d]
    intro i
    constructor
    · exact (ha'_full ⟨i.val, by omega⟩).1
    · -- Need: a'_full(i) ≤ d = a'_full(n)
      -- From same_order_type: a_pad(i) ≤ c = a_pad(n) implies a'_full(i) ≤ a'_full(n)
      -- This requires instantiating the winning condition with some b'.
      -- We prove it using any specific b' if one exists, or it's vacuously true.
      -- Since a_pad(i) = a(i) ∈ [x,c] and a_pad(n) = c:
      -- a_pad(i) ≤ c so in the (n+1)-game order, position i+1 ≤ position n+1.
      -- By same_order_type, a'_full(i) ≤ a'_full(n) = d.
      rw [← hd_eq]
      -- Need: a'_full ⟨i.val, _⟩ ≤ a'_full ⟨n, _⟩
      -- Use h_pt to get a witness point and instantiate the winning condition.
      obtain ⟨p, hp⟩ := h_pt
      obtain ⟨_, _, hcond_witness⟩ := hwin_full p hp
      obtain ⟨hord_w, _, _⟩ := hcond_witness
      -- same_order_type at game_tuple indices (i.val+1) and (n+1) in the (n+1)-game:
      -- game_tuple x y a_pad p ⟨i.val+1, _⟩ = a_pad ⟨i.val, _⟩ = a(i) ∈ [x,c]
      -- game_tuple x y a_pad p ⟨n+1, _⟩ = a_pad ⟨n, _⟩ = c
      -- Since a(i) ∈ [x,c], a_pad(i) ≤ c = a_pad(n), so ¬(a_pad(n) < a_pad(i)).
      -- By same_order_type: ¬(a'_full(n) < a'_full(i)), hence a'_full(i) ≤ a'_full(n).
      have hcmp := hord_w ⟨n + 1, by omega⟩ ⟨i.val + 1, by omega⟩
      simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
        show (i.val + 1 : Nat) ≠ 0 from by omega,
        show (n + 1 : Nat) ≠ (n + 1) + 1 from by omega,
        show (n + 1 : Nat) ≠ (n + 1) + 2 from by omega,
        show (i.val + 1 : Nat) ≠ (n + 1) + 1 from by omega,
        show (i.val + 1 : Nat) ≠ (n + 1) + 2 from by omega,
        show n + 1 - 1 = n from by omega,
        show i.val + 1 - 1 = i.val from by omega,
        dite_true, dite_false] at hcmp
      obtain ⟨hlt_iff, _⟩ := hcmp
      -- hlt_iff : a_pad ⟨n, _⟩ < a_pad ⟨i.val, _⟩ ↔ a'_full ⟨n, _⟩ < a'_full ⟨i.val, _⟩
      -- a_pad(i) = a(i) ∈ [x,c] so a_pad(i) ≤ c = a_pad(n), hence ¬(a_pad(n) < a_pad(i))
      have ha_pad_i_le : a_pad ⟨i.val, by omega⟩ ≤ a_pad ⟨n, by omega⟩ := by
        rw [hc_last]; rw [ha_pad_eq i]; exact (ha i).2
      exact not_lt.mp (fun h_lt => absurd (hlt_iff.mpr h_lt) (not_lt.mpr ha_pad_i_le))
  · -- Show the winning condition for Round 2
    intro b' hb'
    -- b' is an actual point in [x',d] ⊆ [x',y']
    have hb'_full : inClosedInterval x' y' (extendPoint b') :=
      ⟨hb'.1, le_trans hb'.2 hdy'⟩
    obtain ⟨b, hb_full, hcond_full⟩ := hwin_full b' hb'_full
    -- Show b is in [x,c]: from same_order_type, b' ≤ d = a'_full(n) and
    -- c = a_pad(n), so extendPoint b ≤ c.
    have hb_le_c : extendPoint (sig := sig) (atomMap := atomMap) (r := r) b ≤ c := by
      obtain ⟨hord_full, _, _⟩ := hcond_full
      -- same_order_type at (n+2, n+1) in the full game:
      -- game_tuple x y a_pad b at n+2 = extendPoint b
      -- game_tuple x y a_pad b at n+1 = a_pad(n) = c
      -- game_tuple x' y' a'_full b' at n+2 = extendPoint b'
      -- game_tuple x' y' a'_full b' at n+1 = a'_full(n) = d
      -- From hord_full: (extendPoint b < c ↔ extendPoint b' < d)
      --                 (extendPoint b = c ↔ extendPoint b' = d)
      -- Since b' ∈ [x', d], extendPoint b' ≤ d, so ¬(extendPoint b' > d).
      -- Therefore ¬(extendPoint b > c), i.e., extendPoint b ≤ c.
      unfold same_order_type at hord_full
      -- Get the comparison at indices (n+2, n+1) in the (n+1)-game
      -- In Fin (n+4): index n+2 is the b position, index n+1 is the c position
      have hcmp := hord_full ⟨n + 2, by omega⟩ ⟨n + 1, by omega⟩
      -- Simplify game_tuple at these indices
      simp only [game_tuple] at hcmp
      simp only [show (n + 2 : Nat) ≠ 0 from by omega,
                 show (n + 2 : Nat) = (n + 1) + 1 from by omega,
                 show (n + 2 : Nat) ≠ (n + 1) + 2 from by omega,
                 show (n + 1 : Nat) ≠ 0 from by omega,
                 show (n + 1 : Nat) = n + 1 from rfl,
                 dite_true, dite_false] at hcmp
      obtain ⟨hlt_iff, heq_iff⟩ := hcmp
      -- hlt_iff : extendPoint b < c ↔ extendPoint b' < d  (after rewriting a_pad(n) = c, a'_full(n) = d)
      -- Wait, a_pad(n) = c is established via hc_last, but game_tuple uses a_pad ⟨n+1-1, _⟩
      -- Use same_order_type at indices (n+1, n+2) in the (n+1)-game: c vs extendPoint b
      have hcmp := hord_full ⟨n + 1, by omega⟩ ⟨n + 2, by omega⟩
      simp only [game_tuple, show (n + 1 : Nat) ≠ 0 from by omega,
        show (n + 2 : Nat) ≠ 0 from by omega,
        show (n + 1 : Nat) ≠ n + 1 + 1 from by omega,
        show (n + 1 : Nat) ≠ n + 1 + 2 from by omega,
        show (n + 2 : Nat) = n + 1 + 1 from by omega,
        show n + 1 - 1 = n from by omega,
        dite_true, dite_false] at hcmp
      obtain ⟨hlt, _⟩ := hcmp
      -- hlt: a_pad(n) < extendPoint b ↔ a'_full(n) < extendPoint b'
      have hlt2 : c < extendPoint b ↔ d < extendPoint b' := by
        rwa [hc_last, hd_eq] at hlt
      have hb'_le_d := hb'.2
      -- extendPoint b' ≤ d, so ¬(d < extendPoint b'), so ¬(c < extendPoint b)
      exact not_lt.mp (fun h => absurd (hlt2.mp h) (not_lt.mpr hb'_le_d))
    refine ⟨b, ⟨hb_full.1, hb_le_c⟩, ?_⟩
    -- Transfer winning condition via the index embedding
    obtain ⟨hord_full, hgp_full, hform_full⟩ := hcond_full
    have h_eq_M := @restrict_left_game_tuple_M sig M atomMap r n x y c a b a_pad ha_pad_eq hc_last
    have h_eq_N := @restrict_left_game_tuple_N sig N atomMap r n x' y' d a'_full b' hd_eq
    exact ⟨
      -- same_order_type transfer
      fun i j => by rw [h_eq_M i, h_eq_M j, h_eq_N i, h_eq_N j];
                    exact hord_full (restrict_emb_left n i) (restrict_emb_left n j),
      -- gap_point_agreement transfer
      fun i => by rw [h_eq_M i, h_eq_N i];
                  exact hgp_full (restrict_emb_left n i),
      -- formula_agreement transfer
      fun i A hA => by rw [h_eq_M i, h_eq_N i];
                       exact hform_full (restrict_emb_left n i) A hA
    ⟩

/-- Helper: index embedding for the right strategy restriction.
    Maps: 0 -> 1 (c position in padded), 1..n -> 2..n+1 (shifted selections),
    n+1 -> n+2 (b position), n+2 -> n+3 (y boundary, stays). -/
private def restrict_emb_right (n : Nat) : Fin (n + 3) → Fin (n + 4) := fun i =>
  if i.val = 0 then ⟨1, by omega⟩
  else if i.val ≤ n then ⟨i.val + 1, by omega⟩
  else if i.val = n + 1 then ⟨n + 2, by omega⟩
  else ⟨n + 3, by omega⟩ -- i = n + 2 (y boundary)

/-- game_tuple values agree for the right restriction M-side:
    In the restricted game, index 0 = c, 1..n = a(0)..a(n-1), n+1 = b, n+2 = y.
    In the full game at embedded indices:
    emb(0) = 1 -> a_pad(0) = c, emb(1..n) = 2..n+1 -> a_pad(1..n) = a(0..n-1),
    emb(n+1) = n+2 -> b, emb(n+2) = n+3 -> y. -/
private theorem restrict_right_game_tuple_M {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n : Nat} {x y : ExtendedCarrier M atomMap r}
    {c : ExtendedCarrier M atomMap r}
    (a : Fin n → ExtendedCarrier M atomMap r) (b : M.carrier)
    (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r)
    (hc_first : a_pad ⟨0, by omega⟩ = c)
    (ha_pad_eq : ∀ i : Fin n, a_pad ⟨i.val + 1, by omega⟩ = a i)
    (j : Fin (n + 3)) :
    game_tuple c y a b j = game_tuple x y a_pad b (restrict_emb_right n j) := by
  simp only [game_tuple, restrict_emb_right]
  have hj := j.isLt
  by_cases h0 : j.val = 0
  · simp [h0]; exact hc_first.symm
  · by_cases h_le_n : j.val ≤ n
    · have : j.val ≠ n + 1 := by omega
      have : j.val ≠ n + 2 := by omega
      have : j.val + 1 ≠ 0 := by omega
      have : j.val + 1 ≠ (n + 1) + 1 := by omega
      have : j.val + 1 ≠ (n + 1) + 2 := by omega
      simp [*]
      have h := ha_pad_eq ⟨j.val - 1, by omega⟩
      simp only [show j.val - 1 + 1 = j.val from by omega] at h
      rw [← h]
    · by_cases h_n1 : j.val = n + 1
      · simp [*]
      · have h_n2 : j.val = n + 2 := by omega
        have : ¬(j.val ≤ n) := by omega
        simp [*]

/-- game_tuple values agree for the right restriction N-side (when d = a'_full(0)). -/
private theorem restrict_right_game_tuple_N {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    {n : Nat} {x' y' : ExtendedCarrier N atomMap r}
    {d : ExtendedCarrier N atomMap r}
    (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r) (b' : N.carrier)
    (hd_eq : a'_full ⟨0, by omega⟩ = d)
    (j : Fin (n + 3)) :
    game_tuple d y' (fun i : Fin n => a'_full ⟨i.val + 1, by omega⟩) b' j =
    game_tuple x' y' a'_full b' (restrict_emb_right n j) := by
  simp only [game_tuple, restrict_emb_right]
  have hj := j.isLt
  by_cases h0 : j.val = 0
  · simp [h0]; exact hd_eq.symm
  · by_cases h_le_n : j.val ≤ n
    · have : j.val ≠ n + 1 := by omega
      have : j.val ≠ n + 2 := by omega
      have : j.val + 1 ≠ 0 := by omega
      have : j.val + 1 ≠ (n + 1) + 1 := by omega
      have : j.val + 1 ≠ (n + 1) + 2 := by omega
      simp [*]
      congr 1; ext; simp [show j.val - 1 + 1 = j.val from by omega]
    · by_cases h_n1 : j.val = n + 1
      · simp [*]
      · have h_n2 : j.val = n + 2 := by omega
        have : ¬(j.val ≤ n) := by omega
        simp [*]

/-- **Strategy restriction, right sub-interval**:
    Dual of `ghr93_strategy_restrict_left`. For every Spoiler selection
    from [x,y] starting with c at position 0, there exists a Duplicator
    response in [x',y'] satisfying the winning condition AND whose 0-th
    element equals d, giving Duplicator a win on G_{n;r} on [c,y] vs [d,y'].

    Uses the existential form of d-consistency (same as the left variant). -/
theorem ghr93_strategy_restrict_right {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r} {d : ExtendedCarrier N atomMap r}
    (hxc : x ≤ c) (hcy : c ≤ y) (hx'd : x' ≤ d) (hdy' : d ≤ y')
    (hcd_type : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
    (h_d_consistent : ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a_pad i)) →
      a_pad ⟨0, by omega⟩ = c →
      ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
        (∀ i, inClosedInterval x' y' (a'_full i)) ∧
        (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
          ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
            ghr93_winning_condition (n + 1)
              (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
        a'_full ⟨0, by omega⟩ = d)
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p)) :
    ghr93_duplicator_wins M N atomMap n r c y d y' := by
  unfold ghr93_duplicator_wins at *
  intro a ha
  -- Pad: c as element 0, then a_1,...,a_n from [c,y]
  let a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r := fun i =>
    if hi : i.val = 0 then c else a ⟨i.val - 1, by omega⟩
  have ha_pad : ∀ i, inClosedInterval x y (a_pad i) := by
    intro i; simp only [a_pad]
    split
    · exact ⟨hxc, hcy⟩
    · obtain ⟨hlo, hhi⟩ := ha ⟨i.val - 1, by omega⟩
      exact ⟨le_trans hxc hlo, hhi⟩
  have hc_first : a_pad ⟨0, by omega⟩ = c := by
    simp [a_pad]
  have ha_pad_eq : ∀ i : Fin n, a_pad ⟨i.val + 1, by omega⟩ = a i := by
    intro i; simp [a_pad]
  -- Apply d-consistency (existential form) to get response with a'_full(0) = d
  obtain ⟨a'_full, ha'_full, hwin_full, hd_eq⟩ := h_d_consistent a_pad ha_pad hc_first
  -- Extract responses 1..n as our restricted response
  let a'_res : Fin n → ExtendedCarrier N atomMap r := fun i =>
    a'_full ⟨i.val + 1, by omega⟩
  refine ⟨a'_res, ?_, ?_⟩
  · intro i
    constructor
    · -- d ≤ a'_res i: d = a'_full(0) ≤ a'_full(i+1). From same_order_type:
      -- a_pad(0) = c ≤ a_pad(i+1) = a(i) (since a(i) ∈ [c, y])
      -- So a'_full(0) ≤ a'_full(i+1), i.e., d ≤ a'_res(i).
      rw [← hd_eq]
      -- Use h_pt to get a witness point and instantiate the winning condition.
      obtain ⟨p, hp⟩ := h_pt
      obtain ⟨_, _, hcond_witness⟩ := hwin_full p hp
      obtain ⟨hord_w, _, _⟩ := hcond_witness
      -- same_order_type at game_tuple indices 1 (= a_pad(0) = c) and i+2 (= a_pad(i+1) = a(i))
      -- in the (n+1)-round game. Since c ≤ a(i), ¬(a_pad(i+1) < a_pad(0)),
      -- hence ¬(a'_full(i+1) < a'_full(0)), so a'_full(0) ≤ a'_full(i+1).
      have hcmp := hord_w ⟨i.val + 2, by omega⟩ ⟨1, by omega⟩
      simp only [game_tuple, show (i.val + 2 : Nat) ≠ 0 from by omega,
        show (1 : Nat) ≠ 0 from by omega,
        show (i.val + 2 : Nat) ≠ (n + 1) + 1 from by omega,
        show (i.val + 2 : Nat) ≠ (n + 1) + 2 from by omega,
        show (1 : Nat) ≠ (n + 1) + 1 from by omega,
        show (1 : Nat) ≠ (n + 1) + 2 from by omega,
        show i.val + 2 - 1 = i.val + 1 from by omega,
        show 1 - 1 = 0 from by omega,
        dite_true, dite_false] at hcmp
      obtain ⟨hlt_iff, _⟩ := hcmp
      -- hlt_iff: a_pad ⟨i+1, _⟩ < a_pad ⟨0, _⟩ ↔ a'_full ⟨i+1, _⟩ < a'_full ⟨0, _⟩
      -- Since a_pad(0) = c ≤ a(i) = a_pad(i+1), ¬(a_pad(i+1) < a_pad(0))
      have ha_pad_0_le : a_pad ⟨0, by omega⟩ ≤ a_pad ⟨i.val + 1, by omega⟩ := by
        rw [hc_first]; rw [ha_pad_eq i]; exact (ha i).1
      exact not_lt.mp (fun h_lt => absurd (hlt_iff.mpr h_lt) (not_lt.mpr ha_pad_0_le))
    · exact (ha'_full ⟨i.val + 1, by omega⟩).2
  · intro b' hb'
    have hb'_full : inClosedInterval x' y' (extendPoint b') :=
      ⟨le_trans hx'd hb'.1, hb'.2⟩
    obtain ⟨b, hb_full, hcond_full⟩ := hwin_full b' hb'_full
    -- Show c ≤ extendPoint b
    have hc_le_b : c ≤ extendPoint (sig := sig) (atomMap := atomMap) (r := r) b := by
      obtain ⟨hord_full, _, _⟩ := hcond_full
      unfold same_order_type at hord_full
      -- Compare indices 1 (a_pad(0) = c) and n+2 (extendPoint b) in full game
      -- Full game: same_order_type at (1, n+2) gives
      --   a_pad(0) < extendPoint b ↔ a'_full(0) < extendPoint b'
      -- And d ≤ extendPoint b' (from hb'), so a'_full(0) = d ≤ extendPoint b'.
      -- So ¬(extendPoint b' < d) = ¬(extendPoint b' < a'_full(0)).
      -- Need to show ¬(extendPoint b < c) = ¬(extendPoint b < a_pad(0)).
      -- From hord_full at (n+2, 1): extendPoint b < a_pad(0) ↔ extendPoint b' < a'_full(0).
      -- a_pad(0) = c, a'_full(0) = d. b' ∈ [d, y'] so d ≤ extendPoint b'.
      -- So ¬(extendPoint b' < d), hence ¬(extendPoint b < c), hence c ≤ extendPoint b.
      have hcmp := hord_full ⟨n + 2, by omega⟩ ⟨1, by omega⟩
      simp only [game_tuple, show (n + 2 : Nat) ≠ 0 from by omega,
        show (1 : Nat) ≠ 0 from by omega,
        show (n + 2 : Nat) = n + 1 + 1 from by omega,
        show (1 : Nat) ≠ n + 1 + 1 from by omega,
        show (1 : Nat) ≠ n + 1 + 2 from by omega,
        show 1 - 1 = 0 from by omega,
        dite_true, dite_false] at hcmp
      obtain ⟨hlt, _⟩ := hcmp
      -- hlt : extendPoint b < a_pad(0) ↔ extendPoint b' < a'_full(0)
      have hlt2 : extendPoint b < c ↔ extendPoint b' < d := by
        rwa [hc_first, hd_eq] at hlt
      have hd_le_b' := hb'.1
      -- d ≤ extendPoint b', so ¬(extendPoint b' < d), so ¬(extendPoint b < c)
      exact not_lt.mp (fun h => absurd (hlt2.mp h) (not_lt.mpr hd_le_b'))
    refine ⟨b, ⟨hc_le_b, hb_full.2⟩, ?_⟩
    -- Transfer winning condition via the right index embedding
    obtain ⟨hord_full, hgp_full, hform_full⟩ := hcond_full
    have h_eq_M := @restrict_right_game_tuple_M sig M atomMap r n x y c a b a_pad hc_first ha_pad_eq
    have h_eq_N := @restrict_right_game_tuple_N sig N atomMap r n x' y' d a'_full b' hd_eq
    exact ⟨
      fun i j => by rw [h_eq_M i, h_eq_M j, h_eq_N i, h_eq_N j];
                    exact hord_full (restrict_emb_right n i) (restrict_emb_right n j),
      fun i => by rw [h_eq_M i, h_eq_N i];
                  exact hgp_full (restrict_emb_right n i),
      fun i A hA => by rw [h_eq_M i, h_eq_N i];
                       exact hform_full (restrict_emb_right n i) A hA
    ⟩


/-! ## Decomposition Formulas and Lemma 11 (GHR93 Definition 8.8)

An (n;r)-decomposition formula describes a "play" of the game G_{n;r}:
it specifies the rank-r types at each selected element, the gap/point
status of each element, and the types realized in each sub-interval
between adjacent elements.

Rather than defining decomposition formulas as syntactic FO formulas
(which would require a complex FO formula type with quantifiers), we
define the *semantic content* directly: two intervals (x,y) in M_r and
(x',y') in N_r agree on all decomposition formulas iff they agree on:

1. The rank-r types at the boundary elements x, y (resp. x', y')
2. The set of rank-r types realized in the interval (x, y) (resp. (x', y'))
3. For each pair of corresponding elements: gap/point status matches

This semantic characterization is equivalent to the syntactic definition
and is more natural to work with in Lean.

### References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Definition 8.8
- GHR93 Lemma 11
- Task 155 plan: Phase 4B, Task 4B.6
-/

/-- Semantic content of (n;r)-decomposition formula agreement.

    Two intervals agree on all (n;r)-decomposition formulas iff:
    (a) The rank-r types at boundary elements match.
    (b) For every n-element selection from [x,y]_r, there exists an
        n-element selection from [x',y']_r such that:
        - rank-r types agree at corresponding positions
        - gap/point status agrees at corresponding positions
        - the sets of types realized in each sub-interval agree
    (c) Symmetrically from N to M.

    This captures Definition 8.8 semantically: a decomposition formula
    exists y_1,...,y_n specifying types at each y_i and in each sub-interval,
    and agreement means all such specifications match. -/
def decomposition_agreement {sig : MonadicSignature}
    (M N : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (n r : Nat)
    (x y : ExtendedCarrier M atomMap r) (x' y' : ExtendedCarrier N atomMap r) : Prop :=
  -- Boundary type agreement
  rank_type M atomMap r x = rank_type N atomMap r x' ∧
  rank_type M atomMap r y = rank_type N atomMap r y' ∧
  -- Forward direction: for every selection from M, matching selection from N
  (∀ (a : Fin n → ExtendedCarrier M atomMap r),
    (∀ i, inClosedInterval x y (a i)) →
    ∃ (a' : Fin n → ExtendedCarrier N atomMap r),
      (∀ i, inClosedInterval x' y' (a' i)) ∧
      -- Types agree at each selected position
      (∀ i, rank_type M atomMap r (a i) = rank_type N atomMap r (a' i)) ∧
      -- Gap/point status agrees
      (∀ i, (IsPoint (a i) ↔ IsPoint (a' i)) ∧
            (IsGap (a i) ↔ IsGap (a' i))) ∧
      -- Same order type (relative ordering preserved)
      (∀ i j, (a i < a j ↔ a' i < a' j) ∧ (a i = a j ↔ a' i = a' j))) ∧
  -- Backward direction: for every selection from N, matching selection from M
  (∀ (a' : Fin n → ExtendedCarrier N atomMap r),
    (∀ i, inClosedInterval x' y' (a' i)) →
    ∃ (a : Fin n → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a i)) ∧
      (∀ i, rank_type M atomMap r (a i) = rank_type N atomMap r (a' i)) ∧
      (∀ i, (IsPoint (a i) ↔ IsPoint (a' i)) ∧
            (IsGap (a i) ↔ IsGap (a' i))) ∧
      (∀ i j, (a i < a j ↔ a' i < a' j) ∧ (a i = a j ↔ a' i = a' j)))

/-- **GHR93 Lemma 11** (Game ↔ decomposition agreement, forward direction):

    If Duplicator wins G_{n;r}(M, x y; N, x' y'), then M_r and N_r agree
    on all (n;r)-decomposition formulas evaluated at (x,y) and (x',y').

    Intuitively: Duplicator's winning strategy provides the matching
    selections required by decomposition agreement. The winning condition
    (order type + formula agreement) implies type equality and gap/point
    agreement at each position.

    The h_pt hypothesis (existence of a point in [x',y']) is needed to
    trigger Round 2 and extract the winning condition. The h_bwd hypothesis
    provides the backward game (N→M) for the decomposition's backward
    direction. -/
theorem ghr93_game_implies_decomposition {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h : ghr93_duplicator_wins M N atomMap n r x y x' y')
    (h_bwd : ghr93_duplicator_wins N M atomMap n r x' y' x y) :
    decomposition_agreement M N atomMap n r x y x' y' := by
  obtain ⟨p_N, hp_N⟩ := h_pt
  obtain ⟨p_M, hp_M⟩ := h_pt_M
  -- Helper: extract formula agreement from a game play
  -- Given a selection a and its response a', the winning condition gives
  -- formula_agreement at all indices. From this, we derive rank_type equality.
  have rank_type_from_win : ∀ (t : ExtendedCarrier M atomMap r)
      (t' : ExtendedCarrier N atomMap r),
      (∀ (A : StaviFormula), stavi_depth A ≤ r →
        (stavi_temporal_truth_mu M atomMap r t A ↔
         stavi_temporal_truth_mu N atomMap r t' A)) →
      rank_type M atomMap r t = rank_type N atomMap r t' := by
    intro t t' hform
    ext A
    simp only [rank_type, Set.mem_setOf_eq]
    constructor
    · intro ⟨hd, hA⟩; exact ⟨hd, (hform A hd).mp hA⟩
    · intro ⟨hd, hA⟩; exact ⟨hd, (hform A hd).mpr hA⟩
  -- Extract winning condition from forward game with a trivial selection
  -- and the point p_N as the Round 2 challenge.
  obtain ⟨a'_triv, _ha'_triv, hwin_triv⟩ :=
    h (fun _ : Fin n => x) (fun _ => ⟨le_refl _, le_trans hp_M.1 hp_M.2⟩)
  obtain ⟨b_triv, _hb_triv, hcond_triv⟩ := hwin_triv p_N hp_N
  obtain ⟨hord_triv, hgp_triv, hform_triv⟩ := hcond_triv
  -- Boundary type agreement: x/x' (index 0 in game_tuple)
  have htype_x : rank_type M atomMap r x = rank_type N atomMap r x' := by
    apply rank_type_from_win
    intro A hA
    exact hform_triv ⟨0, by omega⟩ A hA
  -- Boundary type agreement: y/y' (index n+2 in game_tuple)
  have htype_y : rank_type M atomMap r y = rank_type N atomMap r y' := by
    apply rank_type_from_win
    intro A hA
    have := hform_triv ⟨n + 2, by omega⟩ A hA
    simp only [game_tuple, show (n + 2) ≠ 0 from by omega,
      show ¬(n + 2 = n + 1) from by omega,
      show (n + 2) = n + 2 from rfl, dite_false, dite_true] at this
    exact this
  refine ⟨htype_x, htype_y, ?_, ?_⟩
  · -- Forward direction: for every selection from M, matching from N
    intro a ha
    obtain ⟨a', ha', hwin_fwd⟩ := h a ha
    obtain ⟨b_fwd, _hb_fwd, hcond_fwd⟩ := hwin_fwd p_N hp_N
    obtain ⟨hord_fwd, hgp_fwd, hform_fwd⟩ := hcond_fwd
    refine ⟨a', ha', ?_, ?_, ?_⟩
    · -- Type agreement at each selection
      intro i
      apply rank_type_from_win
      intro A hA
      -- Index in game_tuple: a(i) is at position 1+i.val
      have := hform_fwd ⟨1 + i.val, by omega⟩ A hA
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega] at this
      convert this using 2 <;> simp [Fin.ext_iff]
    · -- Gap/point agreement at each selection
      intro i
      have := hgp_fwd ⟨1 + i.val, by omega⟩
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega] at this
      convert this using 2 <;> simp [Fin.ext_iff]
    · -- Order preservation at each pair of selections
      intro i j
      have := hord_fwd ⟨1 + i.val, by omega⟩ ⟨1 + j.val, by omega⟩
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega,
        show 1 + j.val ≠ 0 from by omega,
        show ¬(1 + j.val = n + 1) from by omega,
        show ¬(1 + j.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega,
        show 1 + j.val - 1 = j.val from by omega] at this
      convert this using 2 <;> simp [Fin.ext_iff]
  · -- Backward direction: for every selection from N, matching from M
    intro a' ha'
    obtain ⟨a, ha, hwin_bwd⟩ := h_bwd a' ha'
    obtain ⟨b_bwd, _hb_bwd, hcond_bwd⟩ := hwin_bwd p_M hp_M
    obtain ⟨hord_bwd, hgp_bwd, hform_bwd⟩ := hcond_bwd
    refine ⟨a, ha, ?_, ?_, ?_⟩
    · -- Type agreement at each selection
      intro i
      apply rank_type_from_win
      intro A hA
      -- In the backward game (N→M), the game_tuple for N is the first argument
      -- and for M is the second. The formula_agreement gives:
      -- stavi_temporal_truth_mu N ... (tN i) A ↔ stavi_temporal_truth_mu M ... (tM i) A
      -- We need the reverse direction (M ↔ N), so swap the iff.
      have := hform_bwd ⟨1 + i.val, by omega⟩ A hA
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega] at this
      convert this.symm using 2 <;> simp [Fin.ext_iff]
    · -- Gap/point agreement at each selection
      intro i
      have := hgp_bwd ⟨1 + i.val, by omega⟩
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega] at this
      constructor
      · convert this.1.symm using 2 <;> simp [Fin.ext_iff]
      · convert this.2.symm using 2 <;> simp [Fin.ext_iff]
    · -- Order preservation at each pair of selections
      intro i j
      have := hord_bwd ⟨1 + i.val, by omega⟩ ⟨1 + j.val, by omega⟩
      simp only [game_tuple, show 1 + i.val ≠ 0 from by omega,
        show ¬(1 + i.val = n + 1) from by omega,
        show ¬(1 + i.val = n + 2) from by omega,
        show 1 + j.val ≠ 0 from by omega,
        show ¬(1 + j.val = n + 1) from by omega,
        show ¬(1 + j.val = n + 2) from by omega, dite_false,
        show 1 + i.val - 1 = i.val from by omega,
        show 1 + j.val - 1 = j.val from by omega] at this
      constructor
      · convert this.1.symm using 2 <;> simp [Fin.ext_iff]
      · convert this.2.symm using 2 <;> simp [Fin.ext_iff]

/-- **GHR93 Lemma 11** (Game ↔ decomposition agreement, backward direction):

    If M_r and N_r agree on all (n;r)-decomposition formulas at (x,y)/(x',y'),
    then Duplicator has a winning strategy for G_{n;r}(M, x y; N, x' y').

    Intuitively: decomposition agreement provides Duplicator with matching
    selections (from the forward condition). For the point challenge (Round 2),
    the type agreement ensures that any actual point in [x',y'] ∩ N has a
    type-matching actual point in [x,y] ∩ M.

    Sorry'd. The proof constructs Duplicator's strategy from the decomposition
    agreement. The Round 1 response uses the forward matching. For Round 2,
    we need to show that for any point b' in [x',y']∩N, there exists a
    type-matching point in [x,y]∩M. This uses the backward direction of
    decomposition_agreement applied at n+1 elements (including extendPoint b'). -/
theorem ghr93_decomposition_implies_game {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h : decomposition_agreement M N atomMap n r x y x' y') :
    ghr93_duplicator_wins M N atomMap n r x y x' y' := by
  sorry

/-- **GHR93 Lemma 11** (Game ↔ decomposition agreement, iff version):

    Duplicator has a winning strategy for G_{n;r}(M, x y; N, x' y') iff
    M_r and N_r agree on all (n;r)-decomposition formulas at (x,y)/(x',y').

    The h_pt hypotheses are needed for the game → decomposition direction
    (to trigger Round 2) and for the decomposition → game direction
    (to handle the point challenge). -/
theorem ghr93_game_iff_decomposition {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p))
    (h_pt_M : ∃ (p : M.carrier), inClosedInterval x y (extendPoint p))
    (h_bwd : ghr93_duplicator_wins N M atomMap n r x' y' x y) :
    ghr93_duplicator_wins M N atomMap n r x y x' y' ↔
    decomposition_agreement M N atomMap n r x y x' y' :=
  ⟨fun hg => ghr93_game_implies_decomposition h_pt h_pt_M hg h_bwd,
   fun hd => ghr93_decomposition_implies_game h_pt h_pt_M hd⟩

/-! ## Stavi Expressive Completeness

The main theorem: {U, S, U', S'} is expressively complete for ALL linear
temporal structures.

For any monadic FO sentence phi of quantifier depth ≤ k, there exists a
StaviFormula A such that for all ordered monadic structures M and points t:

  stavi_temporal_truth M atomMap t A ↔ eval M (fun _ => t) phi

### Proof Strategy (GHR93)

The proof uses the custom EF games to show that if two pointed structures
(M, t) and (N, s) agree on all StaviFormulas of a certain depth, then
Duplicator wins the corresponding EF game, hence they satisfy the same
FO sentences up to that depth. The four cases of the main induction
correspond to different structural configurations:

- Case I: The structures can be distinguished by atoms/order at the
  selected points → use base temporal formulas.
- Case II: There is a standard Until witness → use U.
- Case III: There is a standard Since witness → use S.
- Case IV: The structure has a gap → use U' or S'.

The full proof is ~1000-1500 lines and requires the game infrastructure
defined above. It is the single largest formalization effort in the
Reynolds pipeline.
-/

/-! ## Standard Translation for Stavi Formulas over muSig (GHR93 p.111)

The standard translation `stavi_table_mu` maps each `StaviFormula` to a
monadic FO formula `MonadicFormula (muSig sig) 1` whose quantifiers are
relativized to the mu predicate (`Sum.inr ()` in `muSig sig`). This is
the key bridge between `stavi_temporal_truth_mu` (semantic evaluation on
the extended structure) and the NormalForm finiteness theory.

### Design

- `liftSigFormula`: lifts `MonadicFormula sig n` to `MonadicFormula (muSig sig) n`
  by mapping predicates via `Sum.inl`.
- `muPred`: the mu predicate atom `atom (Sum.inr ()) i` in `muSig sig`.
- `stavi_table_mu`: the main translation.
- `stavi_table_mu_correct`: evaluating `stavi_table_mu` on `extendedStructureWithMu`
  is equivalent to `stavi_temporal_truth_mu`.
- `nf_determines_stavi_truth_via_mu`: the NF bridge used by `pigeonhole_definable_formula`.
-/

/-- Lift a monadic FO formula from signature `sig` to `muSig sig` by
    mapping each predicate `p` to `Sum.inl p`. -/
def liftSigFormula {sig : MonadicSignature} {n : Nat} :
    MonadicFormula sig n → MonadicFormula (muSig sig) n
  | .atom p i => .atom (.inl p) i
  | .lt i j => .lt i j
  | .not α => .not (liftSigFormula α)
  | .and α β => .and (liftSigFormula α) (liftSigFormula β)
  | .all α => .all (liftSigFormula α)
  | .ex α => .ex (liftSigFormula α)

/-- Lifting preserves quantifier depth. -/
theorem liftSigFormula_depth {sig : MonadicSignature} {n : Nat}
    (α : MonadicFormula sig n) :
    (liftSigFormula α).quantifier_depth = α.quantifier_depth := by
  induction α with
  | atom _ _ => rfl
  | lt _ _ => rfl
  | not _ ih => simp [liftSigFormula, MonadicFormula.quantifier_depth, ih]
  | and _ _ ihα ihβ => simp [liftSigFormula, MonadicFormula.quantifier_depth, ihα, ihβ]
  | all _ ih => simp [liftSigFormula, MonadicFormula.quantifier_depth, ih]
  | ex _ ih => simp [liftSigFormula, MonadicFormula.quantifier_depth, ih]

/-- Lifting preserves evaluation: evaluating a lifted formula on
    `extendedStructureWithMu` equals evaluating the original on
    `extendedStructure` (since `Sum.inl` predicates agree). -/
theorem liftSigFormula_eval {sig : MonadicSignature} {n : Nat}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (env : Fin n → (extendedStructureWithMu M atomMap r).carrier)
    (α : MonadicFormula sig n) :
    eval (extendedStructureWithMu M atomMap r) env (liftSigFormula α) ↔
    eval (extendedStructure M atomMap r) env α := by
  induction α with
  | atom p i => simp [liftSigFormula, eval, extendedStructureWithMu]
  | lt i j => simp [liftSigFormula, eval]
  | not α ih => simp only [liftSigFormula, eval]; exact (ih env).not
  | and α β ihα ihβ => simp only [liftSigFormula, eval]; exact (ihα env).and (ihβ env)
  | all α ih =>
    simp only [liftSigFormula, eval]
    exact forall_congr' fun x => ih (Fin.cons x env)
  | ex α ih =>
    simp only [liftSigFormula, eval]
    exact exists_congr fun x => ih (Fin.cons x env)

/-- Lifting preserves the lift (De Bruijn shift) operation. -/
theorem liftSigFormula_lift_comm {sig : MonadicSignature} {n : Nat}
    (α : MonadicFormula sig n) (c : Nat) :
    liftSigFormula (α.lift c) = (liftSigFormula α).lift c := by
  induction α generalizing c with
  | atom p i => simp [liftSigFormula, MonadicFormula.lift]
  | lt i j => simp [liftSigFormula, MonadicFormula.lift]
  | not α ih => simp [liftSigFormula, MonadicFormula.lift, ih]
  | and α β ihα ihβ => simp [liftSigFormula, MonadicFormula.lift, ihα, ihβ]
  | all α ih => simp [liftSigFormula, MonadicFormula.lift, ih]
  | ex α ih => simp [liftSigFormula, MonadicFormula.lift, ih]

/-- The mu predicate as a monadic formula: `atom (Sum.inr ()) i`.
    Applied to variable `i` in a formula with `n` free variables. -/
def muPred {sig : MonadicSignature} {n : Nat} (i : Fin n) :
    MonadicFormula (muSig sig) n :=
  .atom (.inr ()) i

/-- Mu-relativized existential: ∃x. mu(x) ∧ φ(x).
    Variable 0 is the bound variable, others shift up. -/
def muEx {sig : MonadicSignature} {n : Nat}
    (φ : MonadicFormula (muSig sig) (n + 1)) : MonadicFormula (muSig sig) n :=
  .ex (.and (muPred ⟨0, by omega⟩) φ)

/-- Mu-relativized universal: ∀x. mu(x) → φ(x).
    Encoded as ∀x. ¬(mu(x) ∧ ¬φ(x)). -/
def muAll {sig : MonadicSignature} {n : Nat}
    (φ : MonadicFormula (muSig sig) (n + 1)) : MonadicFormula (muSig sig) n :=
  .all (.not (.and (muPred ⟨0, by omega⟩) (.not φ)))

/-- GHR93 FO table for U'(A,B), mu-relativized, taking pre-lifted arguments.
    Arguments are the sub-formula translations at various De Bruijn depths.
    ∃s. t < s ∧ [body] ∧ [fail] ∧ [init] -/
private def stavi_untl_fo {sig : MonadicSignature}
    (cA4 : MonadicFormula (muSig sig) 4)
    (cB3 : MonadicFormula (muSig sig) 3)
    (cB4 : MonadicFormula (muSig sig) 4)
    (cB5 : MonadicFormula (muSig sig) 5) : MonadicFormula (muSig sig) 1 :=
  -- After ex: var 0 = s, var 1 = t
  MonadicFormula.ex (MonadicFormula.and
    (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- t < s
    (MonadicFormula.and
      -- (1) Body: ∀ u, ¬(guard(u) ∧ ¬D1(u) ∧ ¬D2(u))
      --    = ∀ u, guard(u) → D1(u) ∨ D2(u)
      (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
        (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨2, by omega⟩ ⟨0, by omega⟩)
                (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))
        (MonadicFormula.and
          (MonadicFormula.not (MonadicFormula.ex (MonadicFormula.and
            (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
              (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
                (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                  (MonadicFormula.and (MonadicFormula.lt ⟨4, by omega⟩ ⟨0, by omega⟩)
                        (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))
                (MonadicFormula.not cB5))))))))
          (MonadicFormula.not (MonadicFormula.and
            (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
              (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
                      (MonadicFormula.lt ⟨0, by omega⟩ ⟨2, by omega⟩)))
              (MonadicFormula.not cA4))))
            (MonadicFormula.ex (MonadicFormula.and
              (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
              (MonadicFormula.and (MonadicFormula.lt ⟨3, by omega⟩ ⟨0, by omega⟩)
                (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)
                  (MonadicFormula.not cB4)))))))))))
      (MonadicFormula.and
        -- (2) Fail
        (MonadicFormula.ex (MonadicFormula.and
          (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨2, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)
              (MonadicFormula.not cB3)))))
        -- (3) Init
        (MonadicFormula.ex (MonadicFormula.and
          (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨2, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)
              (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
                (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                  (MonadicFormula.and (MonadicFormula.lt ⟨3, by omega⟩ ⟨0, by omega⟩)
                        (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))
                (MonadicFormula.not cB4)))))))))))

/-- Past dual of stavi_untl_fo: S'(A,B), mu-relativized. -/
private def stavi_snce_fo {sig : MonadicSignature}
    (cA4 : MonadicFormula (muSig sig) 4)
    (cB3 : MonadicFormula (muSig sig) 3)
    (cB4 : MonadicFormula (muSig sig) 4)
    (cB5 : MonadicFormula (muSig sig) 5) : MonadicFormula (muSig sig) 1 :=
  MonadicFormula.ex (MonadicFormula.and
    (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)  -- s < t
    (MonadicFormula.and
      -- (1) Body: ∀ u, ¬(guard(u) ∧ ¬D1(u) ∧ ¬D2(u))
      --    = ∀ u, guard(u) → D1(u) ∨ D2(u) (past dual)
      (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
        (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
                (MonadicFormula.lt ⟨0, by omega⟩ ⟨2, by omega⟩)))
        (MonadicFormula.and
          (MonadicFormula.not (MonadicFormula.ex (MonadicFormula.and
            (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)
              (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
                (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                  (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
                        (MonadicFormula.lt ⟨0, by omega⟩ ⟨4, by omega⟩)))
                (MonadicFormula.not cB5))))))))
          (MonadicFormula.not (MonadicFormula.and
            (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
              (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                (MonadicFormula.and (MonadicFormula.lt ⟨2, by omega⟩ ⟨0, by omega⟩)
                      (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))
              (MonadicFormula.not cA4))))
            (MonadicFormula.ex (MonadicFormula.and
              (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
              (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
                (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨3, by omega⟩)
                  (MonadicFormula.not cB4)))))))))))
      (MonadicFormula.and
        -- (2) Fail
        (MonadicFormula.ex (MonadicFormula.and
          (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨2, by omega⟩)
              (MonadicFormula.not cB3)))))
        -- (3) Init
        (MonadicFormula.ex (MonadicFormula.and
          (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
          (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
            (MonadicFormula.and (MonadicFormula.lt ⟨0, by omega⟩ ⟨2, by omega⟩)
              (MonadicFormula.all (MonadicFormula.not (MonadicFormula.and
                (MonadicFormula.and (MonadicFormula.atom (.inr ()) ⟨0, by omega⟩)
                  (MonadicFormula.and (MonadicFormula.lt ⟨1, by omega⟩ ⟨0, by omega⟩)
                        (MonadicFormula.lt ⟨0, by omega⟩ ⟨3, by omega⟩)))
                (MonadicFormula.not cB4)))))))))))

/-- Mu-relativized table translation: translates a standard Formula to
    MonadicFormula (muSig sig) 1 with mu-relativized quantifiers in Until/Since.
    Atoms and box are translated via atomMap (lifted to muSig via Sum.inl).
    The temporal quantifiers (Until, Since) only range over mu-points. -/
def table_mu {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) : Formula → MonadicFormula (muSig sig) 1
  | .atom a => .atom (.inl (atomMap (.atom a))) ⟨0, by omega⟩
  | .bot => .lt ⟨0, by omega⟩ ⟨0, by omega⟩
  | .imp ψ₁ ψ₂ =>
    .not (.and (table_mu atomMap ψ₁) (.not (table_mu atomMap ψ₂)))
  | .box ψ => .atom (.inl (atomMap (.box ψ))) ⟨0, by omega⟩
  | .untl ψ₁ ψ₂ =>
    -- ∃s. mu(s) ∧ t < s ∧ C_ψ₁(s) ∧ ∀u. (mu(u) ∧ t < u ∧ u < s) → C_ψ₂(u)
    let c1 := table_mu atomMap ψ₁  -- 1 var
    let c2 := table_mu atomMap ψ₂
    let c1_2 := c1.lift 1          -- 2 vars: var 0 = s, var 1 = t
    let c2_3 := (c2.lift 1).lift 1 -- 3 vars: var 0 = u, var 1 = s, var 2 = t
    .ex (.and (.atom (.inr ()) ⟨0, by omega⟩)       -- mu(s)
      (.and (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)       -- t < s
        (.and c1_2                                    -- C_ψ₁(s)
          (.all (.not (.and
            (.and (.atom (.inr ()) ⟨0, by omega⟩)    -- mu(u)
              (.and (.lt ⟨2, by omega⟩ ⟨0, by omega⟩)  -- t < u
                    (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))  -- u < s
            (.not c2_3)))))))                          -- C_ψ₂(u)
  | .snce ψ₁ ψ₂ =>
    -- ∃s. mu(s) ∧ s < t ∧ C_ψ₁(s) ∧ ∀u. (mu(u) ∧ s < u ∧ u < t) → C_ψ₂(u)
    let c1 := table_mu atomMap ψ₁
    let c2 := table_mu atomMap ψ₂
    let c1_2 := c1.lift 1
    let c2_3 := (c2.lift 1).lift 1
    .ex (.and (.atom (.inr ()) ⟨0, by omega⟩)       -- mu(s)
      (.and (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)       -- s < t
        (.and c1_2                                    -- C_ψ₁(s)
          (.all (.not (.and
            (.and (.atom (.inr ()) ⟨0, by omega⟩)    -- mu(u)
              (.and (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- s < u
                    (.lt ⟨0, by omega⟩ ⟨2, by omega⟩)))  -- u < t
            (.not c2_3)))))))                          -- C_ψ₂(u)

/-- Standard translation of StaviFormula to monadic FO formula over muSig.
    Mu-relativized quantifiers use the mu predicate from muSig.

    Variable conventions (De Bruijn):
    - In MonadicFormula (muSig sig) 1: variable 0 = t (current time)
    - After ex: variable 0 = bound, variable 1 = t
    - After ex then all: variable 0 = inner, variable 1 = outer, variable 2 = t -/
noncomputable def stavi_table_mu {sig : MonadicSignature}
    (atomMap : Formula → sig.preds) : StaviFormula → MonadicFormula (muSig sig) 1
  | .base φ => table_mu atomMap φ
  | .neg A => .not (stavi_table_mu atomMap A)
  | .conj A B => .and (stavi_table_mu atomMap A) (stavi_table_mu atomMap B)
  | .std_untl A B =>
    -- ∃s. mu(s) ∧ t < s ∧ C_A(s) ∧ ∀u. (mu(u) ∧ t < u ∧ u < s) → C_B(u)
    let cA := stavi_table_mu atomMap A  -- MonadicFormula (muSig sig) 1
    let cB := stavi_table_mu atomMap B
    let cA2 := cA.lift 1                -- lifted to 2 vars: var 0 = s, var 1 = t
    let cB3 := (cB.lift 1).lift 1       -- lifted to 3 vars: var 0 = u, var 1 = s, var 2 = t
    .ex (.and (muPred ⟨0, by omega⟩)
      (.and (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- t < s
        (.and cA2                                -- C_A(s)
          (.all (.not (.and
            (.and (muPred ⟨0, by omega⟩)         -- mu(u)
              (.and (.lt ⟨2, by omega⟩ ⟨0, by omega⟩)  -- t < u
                    (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)))  -- u < s
            (.not cB3)))))))                     -- C_B(u)
  | .std_snce A B =>
    -- ∃s. mu(s) ∧ s < t ∧ C_A(s) ∧ ∀u. (mu(u) ∧ s < u ∧ u < t) → C_B(u)
    let cA := stavi_table_mu atomMap A
    let cB := stavi_table_mu atomMap B
    let cA2 := cA.lift 1
    let cB3 := (cB.lift 1).lift 1
    .ex (.and (muPred ⟨0, by omega⟩)
      (.and (.lt ⟨0, by omega⟩ ⟨1, by omega⟩)  -- s < t
        (.and cA2
          (.all (.not (.and
            (.and (muPred ⟨0, by omega⟩)
              (.and (.lt ⟨1, by omega⟩ ⟨0, by omega⟩)  -- s < u
                    (.lt ⟨0, by omega⟩ ⟨2, by omega⟩)))  -- u < t
            (.not cB3)))))))
  | .stavi_untl A B =>
    let cA := stavi_table_mu atomMap A
    let cB := stavi_table_mu atomMap B
    stavi_untl_fo (((cA.lift 1).lift 1).lift 1) ((cB.lift 1).lift 1)
      (((cB.lift 1).lift 1).lift 1) ((((cB.lift 1).lift 1).lift 1).lift 1)
  | .stavi_snce A B =>
    let cA := stavi_table_mu atomMap A
    let cB := stavi_table_mu atomMap B
    stavi_snce_fo (((cA.lift 1).lift 1).lift 1) ((cB.lift 1).lift 1)
      (((cB.lift 1).lift 1).lift 1) ((((cB.lift 1).lift 1).lift 1).lift 1)

/-- Correctness of table_mu: evaluating the mu-relativized table translation
    on extendedStructureWithMu gives temporal_truth_mu. -/
theorem table_mu_correct {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (t : ExtendedCarrier M atomMap r) (φ : Formula) :
    eval (extendedStructureWithMu M atomMap r) (fun _ => t)
      (table_mu atomMap φ) ↔
    temporal_truth_mu M atomMap r t φ := by
  induction φ generalizing t with
  | atom a =>
    simp [table_mu, eval, extendedStructureWithMu, temporal_truth_mu, extendedStructure]
  | bot =>
    simp [table_mu, eval, temporal_truth_mu, lt_irrefl]
  | imp ψ₁ ψ₂ ih₁ ih₂ =>
    simp only [table_mu, eval, temporal_truth_mu]
    constructor
    · intro h hψ₁; push_neg at h; exact (ih₂ t).mp (h ((ih₁ t).mpr hψ₁))
    · intro h ⟨hψ₁, hψ₂⟩; exact hψ₂ ((ih₂ t).mpr (h ((ih₁ t).mp hψ₁)))
  | box ψ =>
    simp [table_mu, eval, extendedStructureWithMu, temporal_truth_mu, extendedStructure]
  | untl ψ₁ ψ₂ ih₁ ih₂ =>
    -- table_mu (.untl ψ₁ ψ₂) = .ex (.and mu(s) (.and (t < s) (.and C_ψ₁(s) (∀u...))))
    -- temporal_truth_mu (.untl ψ₁ ψ₂) = ∃ s, t < s ∧ mu(s) ∧ T_ψ₁(s) ∧ ∀ u, t<u→u<s→mu(u)→T_ψ₂(u)
    -- The key lift lemma: evaluating a lifted formula under Fin.cons
    -- Key lift lemma: (α.lift 1) in env (Fin.cons s (fun _ => t)) = α in env (fun _ => s)
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    -- Double lift: ((α.lift 1).lift 1) in env (Fin.cons u (Fin.cons s (fun _ => t))) = α at (fun _ => u)
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    have lift1_iff : ∀ (s : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) ((table_mu atomMap ψ₁).lift 1) ↔
        temporal_truth_mu M atomMap r s ψ₁ := by
      intro s; rw [lift1_eq]; exact ih₁ s
    have lift2_iff : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((table_mu atomMap ψ₂).lift 1).lift 1) ↔
        temporal_truth_mu M atomMap r u ψ₂ := by
      intro s u; rw [lift2_eq]; exact ih₂ u
    simp only [table_mu, eval, temporal_truth_mu, extendedStructureWithMu, mu_holds]
    simp only [Fin.cons, Fin.cases]
    constructor
    · rintro ⟨s, hmu, hts, hA, hB⟩
      exact ⟨s, hts, hmu, (lift1_iff s).mp hA, fun u htu hus hmu_u => by
        have := hB u
        simp only [not_and, Classical.not_not] at this
        exact (lift2_iff s u).mp (this ⟨hmu_u, htu, hus⟩)⟩
    · rintro ⟨s, hts, hmu, hA, hB⟩
      refine ⟨s, hmu, hts, (lift1_iff s).mpr hA, fun u => ?_⟩
      intro ⟨⟨hmu_u, htu, hus⟩, heval⟩
      exact heval ((lift2_iff s u).mpr (hB u htu hus hmu_u))
  | snce ψ₁ ψ₂ ih₁ ih₂ =>
    -- Symmetric to untl case, with s < t instead of t < s
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    have lift1_iff : ∀ (s : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) ((table_mu atomMap ψ₁).lift 1) ↔
        temporal_truth_mu M atomMap r s ψ₁ := by
      intro s; rw [lift1_eq]; exact ih₁ s
    have lift2_iff : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((table_mu atomMap ψ₂).lift 1).lift 1) ↔
        temporal_truth_mu M atomMap r u ψ₂ := by
      intro s u; rw [lift2_eq]; exact ih₂ u
    simp only [table_mu, eval, temporal_truth_mu, extendedStructureWithMu, mu_holds]
    simp only [Fin.cons, Fin.cases]
    constructor
    · rintro ⟨s, hmu, hst, hA, hB⟩
      exact ⟨s, hst, hmu, (lift1_iff s).mp hA, fun u hsu hut hmu_u => by
        have := hB u
        simp only [not_and, Classical.not_not] at this
        exact (lift2_iff s u).mp (this ⟨hmu_u, hsu, hut⟩)⟩
    · rintro ⟨s, hst, hmu, hA, hB⟩
      refine ⟨s, hmu, hst, (lift1_iff s).mpr hA, fun u => ?_⟩
      intro ⟨⟨hmu_u, hsu, hut⟩, heval⟩
      exact heval ((lift2_iff s u).mpr (hB u hsu hut hmu_u))

/-- The FO quantifier depth of the stavi_table_mu translation.
    This bounds `(stavi_table_mu atomMap A).quantifier_depth` and accounts
    for the fact that stavi_untl/snce FO encodings use more quantifiers
    than the temporal operator depth (stavi_depth). -/
def stavi_fo_depth : StaviFormula → Nat
  | .base φ => operator_depth φ
  | .neg A => stavi_fo_depth A
  | .conj A B => max (stavi_fo_depth A) (stavi_fo_depth B)
  | .std_untl A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 2
  | .std_snce A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 2
  | .stavi_untl A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 4
  | .stavi_snce A B => max (stavi_fo_depth A) (stavi_fo_depth B) + 4

/-- stavi_fo_depth is always at least stavi_depth. -/
theorem stavi_depth_le_fo_depth (A : StaviFormula) :
    stavi_depth A ≤ stavi_fo_depth A := by
  induction A with
  | base φ => simp [stavi_depth, stavi_fo_depth]
  | neg A ih => simp [stavi_depth, stavi_fo_depth, ih]
  | conj A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | std_untl A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | std_snce A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | stavi_untl A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | stavi_snce A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega

/-- stavi_fo_depth is at most twice stavi_depth. This is because the only
    connectives where they differ are stavi_untl/stavi_snce, which add +4 to
    fo_depth vs +2 to depth. By induction, the gap is at most a factor of 2. -/
theorem stavi_fo_depth_le_twice_depth (A : StaviFormula) :
    stavi_fo_depth A ≤ 2 * stavi_depth A := by
  induction A with
  | base φ => simp [stavi_depth, stavi_fo_depth]; omega
  | neg A ih => simp [stavi_depth, stavi_fo_depth]; omega
  | conj A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | std_untl A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | std_snce A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | stavi_untl A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega
  | stavi_snce A B ihA ihB => simp [stavi_depth, stavi_fo_depth]; omega

/-- The quantifier depth of stavi_table_mu is bounded by stavi_fo_depth. -/
theorem stavi_table_mu_depth {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} (A : StaviFormula) :
    (stavi_table_mu atomMap A).quantifier_depth ≤ stavi_fo_depth A := by
  induction A with
  | base φ =>
    simp only [stavi_table_mu, stavi_fo_depth]
    induction φ with
    | atom a => simp [table_mu, MonadicFormula.quantifier_depth, operator_depth]
    | bot => simp [table_mu, MonadicFormula.quantifier_depth, operator_depth]
    | imp ψ1 ψ2 ih₁ ih₂ =>
      simp only [table_mu, MonadicFormula.quantifier_depth, operator_depth]
      exact Nat.max_le.mpr ⟨le_trans ih₁ (le_max_left _ _), le_trans ih₂ (le_max_right _ _)⟩
    | box ψ => simp [table_mu, MonadicFormula.quantifier_depth, operator_depth]
    | untl ψ1 ψ2 ih₁ ih₂ =>
      simp only [table_mu, MonadicFormula.quantifier_depth, operator_depth, lift_quantifier_depth]
      omega
    | snce ψ1 ψ2 ih₁ ih₂ =>
      simp only [table_mu, MonadicFormula.quantifier_depth, operator_depth, lift_quantifier_depth]
      omega
  | neg A ih =>
    simp only [stavi_table_mu, MonadicFormula.quantifier_depth, stavi_fo_depth]
    exact ih
  | conj A B ihA ihB =>
    simp only [stavi_table_mu, MonadicFormula.quantifier_depth, stavi_fo_depth]
    exact Nat.max_le.mpr ⟨le_trans ihA (le_max_left _ _), le_trans ihB (le_max_right _ _)⟩
  | std_untl A B ihA ihB =>
    simp only [stavi_table_mu, MonadicFormula.quantifier_depth, stavi_fo_depth,
      lift_quantifier_depth, muPred]
    omega
  | std_snce A B ihA ihB =>
    simp only [stavi_table_mu, MonadicFormula.quantifier_depth, stavi_fo_depth,
      lift_quantifier_depth, muPred]
    omega
  | stavi_untl A B ihA ihB =>
    simp only [stavi_table_mu, stavi_untl_fo, MonadicFormula.quantifier_depth,
      stavi_fo_depth, lift_quantifier_depth]
    omega
  | stavi_snce A B ihA ihB =>
    simp only [stavi_table_mu, stavi_snce_fo, MonadicFormula.quantifier_depth,
      stavi_fo_depth, lift_quantifier_depth]
    omega

/-- **Table Correctness for Stavi Formulas**: evaluating `stavi_table_mu A`
    on `extendedStructureWithMu` at a point t is equivalent to
    `stavi_temporal_truth_mu` at t.

    This is the key bridge: the FO translation faithfully represents the
    mu-relativized temporal semantics. -/
theorem stavi_table_mu_correct {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (t : ExtendedCarrier M atomMap r) (A : StaviFormula) :
    eval (extendedStructureWithMu M atomMap r) (fun _ => t)
      (stavi_table_mu atomMap A) ↔
    stavi_temporal_truth_mu M atomMap r t A := by
  induction A generalizing t with
  | base φ =>
    simp only [stavi_table_mu, stavi_temporal_truth_mu]
    exact table_mu_correct t φ
  | neg A ih =>
    simp only [stavi_table_mu, eval, stavi_temporal_truth_mu]
    exact (ih t).not
  | conj A B ihA ihB =>
    simp only [stavi_table_mu, eval, stavi_temporal_truth_mu]
    exact (ihA t).and (ihB t)
  | std_untl A B ihA ihB =>
    -- Same structure as table_mu_correct untl case
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    have lift1_iff : ∀ (s : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) ((stavi_table_mu atomMap A).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r s A := by
      intro s; rw [lift1_eq]; exact ihA s
    have lift2_iff : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    simp only [stavi_table_mu, eval, stavi_temporal_truth_mu, extendedStructureWithMu, mu_holds]
    simp only [Fin.cons, Fin.cases]
    constructor
    · rintro ⟨s, hmu, hts, hA, hB⟩
      exact ⟨s, hts, hmu, (lift1_iff s).mp hA, fun u htu hus hmu_u => by
        have := hB u
        simp only [not_and, Classical.not_not] at this
        exact (lift2_iff s u).mp (this ⟨hmu_u, htu, hus⟩)⟩
    · rintro ⟨s, hts, hmu, hA, hB⟩
      refine ⟨s, hmu, hts, (lift1_iff s).mpr hA, fun u => ?_⟩
      intro ⟨⟨hmu_u, htu, hus⟩, heval⟩
      exact heval ((lift2_iff s u).mpr (hB u htu hus hmu_u))
  | std_snce A B ihA ihB =>
    -- Same structure as table_mu_correct snce case
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    have lift1_iff : ∀ (s : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) ((stavi_table_mu atomMap A).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r s A := by
      intro s; rw [lift1_eq]; exact ihA s
    have lift2_iff : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    simp only [stavi_table_mu, eval, stavi_temporal_truth_mu, extendedStructureWithMu, mu_holds]
    simp only [Fin.cons, Fin.cases]
    constructor
    · rintro ⟨s, hmu, hst, hA, hB⟩
      exact ⟨s, hst, hmu, (lift1_iff s).mp hA, fun u hsu hut hmu_u => by
        have := hB u
        simp only [not_and, Classical.not_not] at this
        exact (lift2_iff s u).mp (this ⟨hmu_u, hsu, hut⟩)⟩
    · rintro ⟨s, hst, hmu, hA, hB⟩
      refine ⟨s, hmu, hst, (lift1_iff s).mpr hA, fun u => ?_⟩
      intro ⟨⟨hmu_u, hsu, hut⟩, heval⟩
      exact heval ((lift2_iff s u).mpr (hB u hsu hut hmu_u))
  | stavi_untl A B ihA ihB =>
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    -- Lift lemma level 2: strip two binders
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    -- Lift lemma level 3: strip three binders via composition
    have lift3_eq : ∀ (s u v : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))) (((α.lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => v) α := by
      intro s u v α
      -- Use insertEnv to peel off the second variable (u)
      have h1 : Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))) =
          insertEnv ⟨1, by omega⟩ u (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) ⟨1, by omega⟩ u ((α.lift 1).lift 1)]
      exact lift2_eq s v α
    -- Lift lemma level 4: strip four binders via composition
    have lift4_eq : ∀ (s u v w : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          ((((α.lift 1).lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => w) α := by
      intro s u v w α
      have h1 : Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) =
          insertEnv ⟨1, by omega⟩ v
            (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))))
        ⟨1, by omega⟩ v (((α.lift 1).lift 1).lift 1)]
      exact lift3_eq s u w α
    -- IH-based iff lemmas for A and B at each level
    have lift2_iffB : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    have lift3_iffA : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap A).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v A := by
      intro s u v; rw [lift3_eq]; exact ihA v
    have lift3_iffB : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v B := by
      intro s u v; rw [lift3_eq]; exact ihB v
    have lift4_iffB : ∀ (s u v w : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          (((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r w B := by
      intro s u v w; rw [lift4_eq]; exact ihB w
    -- Unfold FO encoding and semantic definition, then match structure
    simp only [stavi_table_mu, stavi_untl_fo, eval, stavi_temporal_truth_mu,
      extendedStructureWithMu, mu_holds]
    constructor
    · -- Forward: FO → semantic
      -- Fin.cons ⟨k, _⟩ reduces definitionally: ⟨0⟩=head, ⟨1⟩=next, etc.
      rintro ⟨s, hts, hbody, ⟨ufail, hmu_ufail, htuf, hufs, hnB_ufail⟩,
              ⟨uinit, hmu_uinit, htui, huis, hinit⟩⟩
      refine ⟨s, hts, ?_, ?_, ?_⟩
      · -- Main body: hbody u : ¬(guard ∧ ¬D1_fo ∧ ¬D2_fo)
        -- After FO fix: this is guard → D1_fo ∨ D2_fo (by De Morgan)
        intro u htu hus hmu_u
        -- Extract ¬(¬D1_fo ∧ ¬D2_fo) via contradiction
        have hbody' : ¬((¬_) ∧ ¬_) := fun ⟨hnd1, hnd2⟩ =>
          hbody u ⟨⟨hmu_u, htu, hus⟩, hnd1, hnd2⟩
        -- Convert to D1_fo ∨ D2_fo
        rcases not_and_or.mp hbody' with hd1 | hd2
        · -- Case: ¬¬D1_fo, so D1_fo holds (cofinal B-segment)
          left
          obtain ⟨v, hmu_v, huv, hwall⟩ := Classical.not_not.mp hd1
          exact ⟨v, huv, hmu_v, fun w htw hwv hmu_w => by
            have hw : ¬_ := fun hn => hwall w ⟨⟨hmu_w, htw, hwv⟩, hn⟩
            exact (lift4_iffB s u v w).mp (Classical.not_not.mp hw)⟩
        · -- Case: ¬¬D2_fo, so D2_fo holds (A on interval + B failure)
          right
          obtain ⟨hall, hexv⟩ := Classical.not_not.mp hd2
          constructor
          · intro v huv hvs hmu_v
            have hv : ¬_ := fun hn => hall v ⟨⟨hmu_v, huv, hvs⟩, hn⟩
            exact (lift3_iffA s u v).mp (Classical.not_not.mp hv)
          · obtain ⟨v', hmu_v', htv', hv'u, hnB⟩ := hexv
            exact ⟨v', htv', hv'u, hmu_v', fun hB => hnB ((lift3_iffB s u v').mpr hB)⟩
      · -- Fail: B fails somewhere
        exact ⟨ufail, htuf, hufs, hmu_ufail, fun hB => hnB_ufail ((lift2_iffB s ufail).mpr hB)⟩
      · -- Init: B holds initially
        refine ⟨uinit, htui, huis, hmu_uinit, fun v htv hvu hmu_v => ?_⟩
        have hv := fun hn => hinit v ⟨⟨hmu_v, htv, hvu⟩, hn⟩
        exact (lift3_iffB s uinit v).mp (Classical.not_not.mp hv)
    · -- Backward: semantic → FO
      rintro ⟨s, hts, hbody, ⟨ufail, htuf, hufs, hmu_ufail, hnB_ufail⟩,
              ⟨uinit, htui, huis, hmu_uinit, hinit⟩⟩
      refine ⟨s, hts, ?_, ?_, ?_⟩
      · -- Main body: encode as ∀ u, ¬(guard ∧ ¬(¬D1 ∧ ¬D2))
        intro u
        intro ⟨⟨hmu_u, htu, hus⟩, hn_disj⟩
        -- hn_disj : ¬(¬D1 ∧ ¬D2), but we need ¬body i.e. (¬D1 ∧ ¬D2) to derive False
        -- Actually hn_disj : ¬D1 ∧ ¬D2 (the double-negation is consumed by the outer ¬(guard ∧ _))
        obtain ⟨hn_d1, hn_d2⟩ := hn_disj
        rcases hbody u htu hus hmu_u with (⟨v, huv, hmu_v, hwall⟩ | ⟨hall, v', htv', hv'u, hmu_v', hnB⟩)
        · -- Disjunct 1 holds semantically, but hn_d1 says FO-D1 fails
          exact hn_d1 ⟨v, hmu_v, huv, fun w =>
            fun ⟨⟨hmu_w, htw, hwv⟩, hn_eval⟩ =>
              hn_eval ((lift4_iffB s u v w).mpr (hwall w htw hwv hmu_w))⟩
        · -- Disjunct 2 holds semantically, but hn_d2 says FO-D2 fails
          exact hn_d2 ⟨fun v =>
            fun ⟨⟨hmu_v, huv, hvs⟩, hn_eval⟩ =>
              hn_eval ((lift3_iffA s u v).mpr (hall v huv hvs hmu_v)),
            v', hmu_v', htv', hv'u, fun heval => hnB ((lift3_iffB s u v').mp heval)⟩
      · -- Fail
        exact ⟨ufail, hmu_ufail, htuf, hufs, fun heval => hnB_ufail ((lift2_iffB s ufail).mp heval)⟩
      · -- Init
        refine ⟨uinit, hmu_uinit, htui, huis, fun v => ?_⟩
        intro ⟨⟨hmu_v, htv, hvu⟩, hn_eval⟩
        exact hn_eval ((lift3_iffB s uinit v).mpr (hinit v htv hvu hmu_v))
  | stavi_snce A B ihA ihB =>
    -- Lift lemma level 1: strip one binder
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    -- Lift lemma level 2
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    -- Lift lemma level 3
    have lift3_eq : ∀ (s u v : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))) (((α.lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => v) α := by
      intro s u v α
      have h1 : Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))) =
          insertEnv ⟨1, by omega⟩ u (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) ⟨1, by omega⟩ u ((α.lift 1).lift 1)]
      exact lift2_eq s v α
    -- Lift lemma level 4
    have lift4_eq : ∀ (s u v w : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          ((((α.lift 1).lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => w) α := by
      intro s u v w α
      have h1 : Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) =
          insertEnv ⟨1, by omega⟩ v
            (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))))
        ⟨1, by omega⟩ v (((α.lift 1).lift 1).lift 1)]
      exact lift3_eq s u w α
    -- IH-based iff lemmas
    have lift2_iffB : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    have lift3_iffA : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap A).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v A := by
      intro s u v; rw [lift3_eq]; exact ihA v
    have lift3_iffB : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v B := by
      intro s u v; rw [lift3_eq]; exact ihB v
    have lift4_iffB : ∀ (s u v w : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          (((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r w B := by
      intro s u v w; rw [lift4_eq]; exact ihB w
    -- Unfold FO encoding and semantic definition
    simp only [stavi_table_mu, stavi_snce_fo, eval, stavi_temporal_truth_mu,
      extendedStructureWithMu, mu_holds]
    constructor
    · -- Forward: FO → semantic (past dual of stavi_untl)
      rintro ⟨s, hst, hbody, ⟨ufail, hmu_ufail, husf, huft, hnB_ufail⟩,
              ⟨uinit, hmu_uinit, husi, huit, hinit⟩⟩
      refine ⟨s, hst, ?_, ?_, ?_⟩
      · -- Main body
        intro u hsu hut hmu_u
        have hbody' : ¬(¬(∃ v, _ ∧ _ ∧ _) ∧ ¬(_ ∧ ∃ _, _)) :=
          fun hn => hbody u ⟨⟨hmu_u, hsu, hut⟩, hn⟩
        rcases not_and_or.mp hbody' with hd1 | hd2
        · -- Case: ¬¬D1, cofinal B-segment
          left
          obtain ⟨v, hmu_v, hvu, hwall⟩ := Classical.not_not.mp hd1
          exact ⟨v, hvu, hmu_v, fun w hvw hwt hmu_w => by
            have hw := fun hn => hwall w ⟨⟨hmu_w, hvw, hwt⟩, hn⟩
            exact (lift4_iffB s u v w).mp (Classical.not_not.mp hw)⟩
        · -- Case: ¬¬D2, A on interval + B failure
          right
          obtain ⟨hall, hexv⟩ := Classical.not_not.mp hd2
          constructor
          · intro v hsv hvu hmu_v
            have hv := fun hn => hall v ⟨⟨hmu_v, hsv, hvu⟩, hn⟩
            exact (lift3_iffA s u v).mp (Classical.not_not.mp hv)
          · obtain ⟨v', hmu_v', huv', hv't, hnB⟩ := hexv
            exact ⟨v', huv', hv't, hmu_v', fun hB => hnB ((lift3_iffB s u v').mpr hB)⟩
      · -- Fail
        exact ⟨ufail, husf, huft, hmu_ufail, fun hB => hnB_ufail ((lift2_iffB s ufail).mpr hB)⟩
      · -- Init
        refine ⟨uinit, husi, huit, hmu_uinit, fun v huv hvt hmu_v => ?_⟩
        have hv := fun hn => hinit v ⟨⟨hmu_v, huv, hvt⟩, hn⟩
        exact (lift3_iffB s uinit v).mp (Classical.not_not.mp hv)
    · -- Backward: semantic → FO
      rintro ⟨s, hst, hbody, ⟨ufail, husf, huft, hmu_ufail, hnB_ufail⟩,
              ⟨uinit, husi, huit, hmu_uinit, hinit⟩⟩
      refine ⟨s, hst, ?_, ?_, ?_⟩
      · -- Main body
        intro u
        intro ⟨⟨hmu_u, hsu, hut⟩, hn_disj⟩
        obtain ⟨hn_d1, hn_d2⟩ := hn_disj
        rcases hbody u hsu hut hmu_u with (⟨v, hvu, hmu_v, hwall⟩ | ⟨hall, v', huv', hv't, hmu_v', hnB⟩)
        · exact hn_d1 ⟨v, hmu_v, hvu, fun w =>
            fun ⟨⟨hmu_w, hvw, hwt⟩, hn_eval⟩ =>
              hn_eval ((lift4_iffB s u v w).mpr (hwall w hvw hwt hmu_w))⟩
        · exact hn_d2 ⟨fun v =>
            fun ⟨⟨hmu_v, hsv, hvu⟩, hn_eval⟩ =>
              hn_eval ((lift3_iffA s u v).mpr (hall v hsv hvu hmu_v)),
            v', hmu_v', huv', hv't, fun heval => hnB ((lift3_iffB s u v').mp heval)⟩
      · -- Fail
        exact ⟨ufail, hmu_ufail, husf, huft, fun heval => hnB_ufail ((lift2_iffB s ufail).mp heval)⟩
      · -- Init
        refine ⟨uinit, hmu_uinit, husi, huit, fun v => ?_⟩
        intro ⟨⟨hmu_v, huv, hvt⟩, hn_eval⟩
        exact hn_eval ((lift3_iffB s uinit v).mpr (hinit v huv hvt hmu_v))
/-! Stavi_untl/snce lift infrastructure preserved below for future reference.
    The lift lemmas (1-4) are correct; the propositional matching needs a
    tactic that handles Fin.cons reduction at depth 3+.

  | stavi_untl A B ihA ihB_PRESERVED =>
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    -- Lift lemma level 2: strip two binders
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    -- Lift lemma level 3: strip three binders via composition
    have lift3_eq : ∀ (s u v : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))) (((α.lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => v) α := by
      intro s u v α
      -- Use insertEnv to peel off the second variable (u)
      have h1 : Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))) =
          insertEnv ⟨1, by omega⟩ u (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) ⟨1, by omega⟩ u ((α.lift 1).lift 1)]
      exact lift2_eq s v α
    -- Lift lemma level 4: strip four binders via composition
    have lift4_eq : ∀ (s u v w : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          ((((α.lift 1).lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => w) α := by
      intro s u v w α
      have h1 : Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) =
          insertEnv ⟨1, by omega⟩ v
            (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))))
        ⟨1, by omega⟩ v (((α.lift 1).lift 1).lift 1)]
      exact lift3_eq s u w α
    -- IH-based iff lemmas for A and B at each level
    have lift2_iffB : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    have lift3_iffA : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap A).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v A := by
      intro s u v; rw [lift3_eq]; exact ihA v
    have lift3_iffB : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v B := by
      intro s u v; rw [lift3_eq]; exact ihB v
    have lift4_iffB : ∀ (s u v w : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          (((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r w B := by
      intro s u v w; rw [lift4_eq]; exact ihB w
    -- Now unfold. Do NOT reduce Fin.cons (causes Fin.induction terms).
    -- Instead, unfold eval+stavi_untl_fo to get Fin.cons-based goals, then
    -- match the structure using the lift iff lemmas. Fin.cons ⟨0,_⟩ = x,
    -- Fin.cons ⟨1,_⟩ = s, etc. are definitionally equal so Lean matches them.
    simp only [stavi_table_mu, stavi_untl_fo, eval, stavi_temporal_truth_mu,
      extendedStructureWithMu, mu_holds]
    constructor
    · -- Forward: FO → semantic
      rintro ⟨s, hts, hbody, ⟨ufail, hmu_ufail, htuf, hufs, hnB_ufail⟩,
              ⟨uinit, hmu_uinit, htui, huis, hinit⟩⟩
      refine ⟨s, hts, ?_, ?_, ?_⟩
      · -- Main body
        intro u htu hus hmu_u
        have hbody_u := hbody u
        simp only [not_and, Classical.not_not] at hbody_u
        have hguard : IsPoint u ∧ t < u ∧ u < s := ⟨hmu_u, htu, hus⟩
        rcases hbody_u hguard with ⟨disj1, disj2⟩ | ⟨hall, hexv⟩
        · -- Disjunct 1: ∃ v with B-cofinal
          left
          obtain ⟨v, hmu_v, huv, hwall⟩ := disj1
          exact ⟨v, huv, hmu_v, fun w htw hwv hmu_w => by
            have := hwall w
            simp only [not_and, Classical.not_not] at this
            exact (lift4_iffB s u v w).mp (this ⟨hmu_w, htw, hwv⟩)⟩
        · -- Disjunct 2: A on (u,s) ∧ B failed before u
          right
          constructor
          · intro v huv hvs hmu_v
            have := hall v
            simp only [not_and, Classical.not_not] at this
            exact (lift3_iffA s u v).mp (this ⟨hmu_v, huv, hvs⟩)
          · obtain ⟨v', hmu_v', htv', hv'u, hnB⟩ := hexv
            exact ⟨v', htv', hv'u, hmu_v', fun hB => hnB ((lift3_iffB s u v').mpr hB)⟩
      · -- Fail: B fails somewhere
        exact ⟨ufail, htuf, hufs, hmu_ufail, fun hB => hnB_ufail ((lift2_iffB s ufail).mpr hB)⟩
      · -- Init: B holds initially
        refine ⟨uinit, htui, huis, hmu_uinit, fun v htv hvu hmu_v => ?_⟩
        have := hinit v
        simp only [not_and, Classical.not_not] at this
        exact (lift3_iffB s uinit v).mp (this ⟨hmu_v, htv, hvu⟩)
    · -- Backward: semantic → FO
      rintro ⟨s, hts, hbody, ⟨ufail, htuf, hufs, hmu_ufail, hnB_ufail⟩,
              ⟨uinit, htui, huis, hmu_uinit, hinit⟩⟩
      refine ⟨s, hts, ?_, ?_, ?_⟩
      · -- Main body: encode as ∀ u, ¬(guard ∧ ¬(disj1 ∨ disj2))
        intro u
        simp only [not_and, Classical.not_not]
        rintro ⟨hmu_u, htu, hus⟩
        rcases hbody u htu hus hmu_u with (⟨v, huv, hmu_v, hwall⟩ | ⟨hall, v', htv', hv'u, hmu_v', hnB⟩)
        · -- Disjunct 1
          left
          exact ⟨v, hmu_v, huv, fun w => by
            simp only [not_and, Classical.not_not]
            rintro ⟨hmu_w, htw, hwv⟩
            exact (lift4_iffB s u v w).mpr (hwall w htw hwv hmu_w)⟩
        · -- Disjunct 2
          right
          constructor
          · intro v
            simp only [not_and, Classical.not_not]
            rintro ⟨hmu_v, huv, hvs⟩
            exact (lift3_iffA s u v).mpr (hall v huv hvs hmu_v)
          · exact ⟨v', hmu_v', htv', hv'u, fun heval => hnB ((lift3_iffB s u v').mp heval)⟩
      · -- Fail
        exact ⟨ufail, hmu_ufail, htuf, hufs, fun heval => hnB_ufail ((lift2_iffB s ufail).mp heval)⟩
      · -- Init
        refine ⟨uinit, hmu_uinit, htui, huis, fun v => ?_⟩
        simp only [not_and, Classical.not_not]
        rintro ⟨hmu_v, htv, hvu⟩
        exact (lift3_iffB s uinit v).mpr (hinit v htv hvu hmu_v)
  | stavi_snce A B ihA ihB =>
    -- Lift lemma level 1: strip one binder
    have lift1_eq : ∀ (s : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons s fun _ => t) (α.lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => s) α := by
      intro s α
      have h1 : Fin.cons s (fun (_ : Fin 1) => t) =
          insertEnv ⟨1, by omega⟩ t (fun (_ : Fin 1) => s) := by
        funext i; refine Fin.cases ?_ ?_ i <;> simp [Fin.cons, insertEnv]
      rw [h1]
      exact lift_eval (extendedStructureWithMu M atomMap r)
        (fun (_ : Fin 1) => s) ⟨1, by omega⟩ t α
    -- Lift lemma level 2
    have lift2_eq : ∀ (s u : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t)) ((α.lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => u) α := by
      intro s u α
      have h1 : Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)) =
          insertEnv ⟨1, by omega⟩ s (Fin.cons u (fun (_ : Fin 1) => t)) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> (try simp [insertEnv])
        refine Fin.cases ?_ ?_ j <;> simp
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons u (fun (_ : Fin 1) => t)) ⟨1, by omega⟩ s (α.lift 1)]
      exact lift1_eq u α
    -- Lift lemma level 3
    have lift3_eq : ∀ (s u v : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))) (((α.lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => v) α := by
      intro s u v α
      have h1 : Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))) =
          insertEnv ⟨1, by omega⟩ u (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons v (Fin.cons s (fun (_ : Fin 1) => t))) ⟨1, by omega⟩ u ((α.lift 1).lift 1)]
      exact lift2_eq s v α
    -- Lift lemma level 4
    have lift4_eq : ∀ (s u v w : (extendedStructureWithMu M atomMap r).carrier)
        (α : MonadicFormula (muSig sig) 1),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          ((((α.lift 1).lift 1).lift 1).lift 1) =
        eval (extendedStructureWithMu M atomMap r) (fun _ => w) α := by
      intro s u v w α
      have h1 : Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) =
          insertEnv ⟨1, by omega⟩ v
            (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t)))) := by
        funext i; refine Fin.cases ?_ (fun j => ?_) i <;> simp [Fin.cons, insertEnv]
        refine Fin.cases ?_ (fun k => ?_) j
        all_goals (first | rfl | simp [Fin.cons, insertEnv, Fin.val_succ] | omega)
      rw [h1, lift_eval (extendedStructureWithMu M atomMap r)
        (Fin.cons w (Fin.cons u (Fin.cons s (fun (_ : Fin 1) => t))))
        ⟨1, by omega⟩ v (((α.lift 1).lift 1).lift 1)]
      exact lift3_eq s u w α
    -- IH-based iff lemmas
    have lift2_iffB : ∀ (s u : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons u (Fin.cons s fun _ => t))
          (((stavi_table_mu atomMap B).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r u B := by
      intro s u; rw [lift2_eq]; exact ihB u
    have lift3_iffA : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap A).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v A := by
      intro s u v; rw [lift3_eq]; exact ihA v
    have lift3_iffB : ∀ (s u v : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t)))
          ((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r v B := by
      intro s u v; rw [lift3_eq]; exact ihB v
    have lift4_iffB : ∀ (s u v w : ExtendedCarrier M atomMap r),
        eval (extendedStructureWithMu M atomMap r)
          (Fin.cons w (Fin.cons v (Fin.cons u (Fin.cons s fun _ => t))))
          (((((stavi_table_mu atomMap B).lift 1).lift 1).lift 1).lift 1) ↔
        stavi_temporal_truth_mu M atomMap r w B := by
      intro s u v w; rw [lift4_eq]; exact ihB w
    -- Now unfold and reduce
    simp only [stavi_table_mu, stavi_snce_fo, eval, stavi_temporal_truth_mu,
      extendedStructureWithMu, mu_holds]
    simp only [Fin.cons, Fin.cases]
    constructor
    · -- Forward: FO → semantic
      rintro ⟨s, hst, hbody, ⟨ufail, hmu_ufail, husf, huft, hnB_ufail⟩,
              ⟨uinit, hmu_uinit, husi, huit, hinit⟩⟩
      refine ⟨s, hst, ?_, ?_, ?_⟩
      · -- Main body
        intro u hsu hut hmu_u
        have hbody_u := hbody u
        simp only [not_and, Classical.not_not] at hbody_u
        have hguard : IsPoint u ∧ s < u ∧ u < t := ⟨hmu_u, hsu, hut⟩
        rcases hbody_u hguard with ⟨disj1, disj2⟩ | ⟨hall, hexv⟩
        · -- Disjunct 1
          left
          obtain ⟨v, hmu_v, hvu, hwall⟩ := disj1
          exact ⟨v, hvu, hmu_v, fun w hvw hwt hmu_w => by
            have := hwall w
            simp only [not_and, Classical.not_not] at this
            exact (lift4_iffB s u v w).mp (this ⟨hmu_w, hvw, hwt⟩)⟩
        · -- Disjunct 2
          right
          constructor
          · intro v hsv hvu hmu_v
            have := hall v
            simp only [not_and, Classical.not_not] at this
            exact (lift3_iffA s u v).mp (this ⟨hmu_v, hsv, hvu⟩)
          · obtain ⟨v', hmu_v', huv', hv't, hnB⟩ := hexv
            exact ⟨v', huv', hv't, hmu_v', fun hB => hnB ((lift3_iffB s u v').mpr hB)⟩
      · -- Fail
        exact ⟨ufail, husf, huft, hmu_ufail, fun hB => hnB_ufail ((lift2_iffB s ufail).mpr hB)⟩
      · -- Init
        refine ⟨uinit, husi, huit, hmu_uinit, fun v huv hvt hmu_v => ?_⟩
        have := hinit v
        simp only [not_and, Classical.not_not] at this
        exact (lift3_iffB s uinit v).mp (this ⟨hmu_v, huv, hvt⟩)
    · -- Backward: semantic → FO
      rintro ⟨s, hst, hbody, ⟨ufail, husf, huft, hmu_ufail, hnB_ufail⟩,
              ⟨uinit, husi, huit, hmu_uinit, hinit⟩⟩
      refine ⟨s, hst, ?_, ?_, ?_⟩
      · -- Main body
        intro u
        simp only [not_and, Classical.not_not]
        rintro ⟨hmu_u, hsu, hut⟩
        rcases hbody u hsu hut hmu_u with (⟨v, hvu, hmu_v, hwall⟩ | ⟨hall, v', huv', hv't, hmu_v', hnB⟩)
        · -- Disjunct 1
          left
          exact ⟨v, hmu_v, hvu, fun w => by
            simp only [not_and, Classical.not_not]
            rintro ⟨hmu_w, hvw, hwt⟩
            exact (lift4_iffB s u v w).mpr (hwall w hvw hwt hmu_w)⟩
        · -- Disjunct 2
          right
          constructor
          · intro v
            simp only [not_and, Classical.not_not]
            rintro ⟨hmu_v, hsv, hvu⟩
            exact (lift3_iffA s u v).mpr (hall v hsv hvu hmu_v)
          · exact ⟨v', hmu_v', huv', hv't, fun heval => hnB ((lift3_iffB s u v').mp heval)⟩
      · -- Fail
        exact ⟨ufail, hmu_ufail, husf, huft, fun heval => hnB_ufail ((lift2_iffB s ufail).mp heval)⟩
      · -- Init
        refine ⟨uinit, hmu_uinit, husi, huit, fun v => ?_⟩
        simp only [not_and, Classical.not_not]
        rintro ⟨hmu_v, huv, hvt⟩
        exact (lift3_iffB s uinit v).mpr (hinit v huv hvt hmu_v)
-/

/--
**GHR93 Theorem 9.3.1 (Theorem 4)**: {U, S, U', S'} is expressively
complete for all linear temporal structures.

For any monadic FO formula psi with one free variable, there exists a
StaviFormula A such that for any ordered monadic structure M, atom map,
and point t:

  stavi_temporal_truth M atomMap t A ↔ eval M (fun _ => t) psi

NOTE: This is currently sorry'd. The full game-theoretic proof is
estimated at 1000-1500 lines across the four cases of the main
induction. See the plan for Phase 4 (Sub-stages 4B and 4C).
-/
noncomputable def stavi_expressive_completeness
    (sig : MonadicSignature) (atomMap : Formula → sig.preds)
    (psi : MonadicFormula sig 1) :
    { A : StaviFormula //
      ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t A ↔
        eval M (fun _ => t) psi } := by
  sorry


end Bimodal.Metalogic.WeakCanonical
