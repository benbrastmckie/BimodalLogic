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
    -- U'^mu(A,B)(t): B^mu cofinal above t among mu-points, standard Until fails among mu-points
    (∀ s : ExtendedCarrier M atomMap r, t < s → mu_holds s →
      ∃ u : ExtendedCarrier M atomMap r, t < u ∧ u ≤ s ∧ mu_holds u ∧
        stavi_temporal_truth_mu M atomMap r u B) ∧
    ¬(∃ s : ExtendedCarrier M atomMap r, t < s ∧ mu_holds s ∧
      stavi_temporal_truth_mu M atomMap r s A ∧
      ∀ u : ExtendedCarrier M atomMap r, t < u → u < s → mu_holds u →
        stavi_temporal_truth_mu M atomMap r u B)
  | .stavi_snce A B =>
    -- S'^mu(A,B)(t): dual (past direction)
    (∀ s : ExtendedCarrier M atomMap r, s < t → mu_holds s →
      ∃ u : ExtendedCarrier M atomMap r, s ≤ u ∧ u < t ∧ mu_holds u ∧
        stavi_temporal_truth_mu M atomMap r u B) ∧
    ¬(∃ s : ExtendedCarrier M atomMap r, s < t ∧ mu_holds s ∧
      stavi_temporal_truth_mu M atomMap r s A ∧
      ∀ u : ExtendedCarrier M atomMap r, s < u → u < t → mu_holds u →
        stavi_temporal_truth_mu M atomMap r u B)
  | .neg φ => ¬ stavi_temporal_truth_mu M atomMap r t φ
  | .conj φ ψ =>
    stavi_temporal_truth_mu M atomMap r t φ ∧ stavi_temporal_truth_mu M atomMap r t ψ

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
    simp only [stavi_temporal_truth_mu]; constructor
    · intro ⟨hcof, hnU⟩; refine ⟨?_, ?_⟩
      · intro s hes ⟨x, hx⟩; subst hx
        obtain ⟨u, heu, hus, ⟨y, hy⟩, hB⟩ :=
          hcof (Sum.inl x) ((rank_embed_lt h _ _).mpr hes) ⟨x, rfl⟩; subst hy
        exact ⟨Sum.inl y, (rank_embed_lt h _ _).mp heu,
               (rank_embed_le h _ _).mp hus, ⟨y, rfl⟩, (ihB _).mp hB⟩
      · intro ⟨s, hes, ⟨x, hx⟩, hA, hψ⟩; subst hx
        exact hnU ⟨Sum.inl x, (rank_embed_lt h _ _).mpr hes, ⟨x, rfl⟩,
          (ihA _).mpr hA, fun u heu hux ⟨y, hy⟩ => by subst hy; exact (ihB _).mpr (hψ (Sum.inl y)
              ((rank_embed_lt h _ _).mp heu) ((rank_embed_lt h _ _).mp hux) ⟨y, rfl⟩)⟩
    · intro ⟨hcof, hnU⟩; refine ⟨?_, ?_⟩
      · intro s hes ⟨x, hx⟩; subst hx
        obtain ⟨u, heu, hus, ⟨y, hy⟩, hB⟩ :=
          hcof (Sum.inl x) ((rank_embed_lt h _ _).mp hes) ⟨x, rfl⟩; subst hy
        exact ⟨Sum.inl y, (rank_embed_lt h _ _).mpr heu,
               (rank_embed_le h _ _).mpr hus, ⟨y, rfl⟩, (ihB _).mpr hB⟩
      · intro ⟨s, hes, ⟨x, hx⟩, hA, hψ⟩; subst hx
        exact hnU ⟨Sum.inl x, (rank_embed_lt h _ _).mp hes, ⟨x, rfl⟩,
          (ihA _).mp hA, fun u hsu hux ⟨y, hy⟩ => by subst hy; exact (ihB _).mp (hψ (Sum.inl y)
              ((rank_embed_lt h _ _).mpr hsu) ((rank_embed_lt h _ _).mpr hux) ⟨y, rfl⟩)⟩
  | stavi_snce A B ihA ihB =>
    simp only [stavi_temporal_truth_mu]; constructor
    · intro ⟨hcof, hnS⟩; refine ⟨?_, ?_⟩
      · intro s hse ⟨x, hx⟩; subst hx
        obtain ⟨u, hsu, hue, ⟨y, hy⟩, hB⟩ :=
          hcof (Sum.inl x) ((rank_embed_lt h _ _).mpr hse) ⟨x, rfl⟩; subst hy
        exact ⟨Sum.inl y, (rank_embed_le h _ _).mp hsu,
               (rank_embed_lt h _ _).mp hue, ⟨y, rfl⟩, (ihB _).mp hB⟩
      · intro ⟨s, hse, ⟨x, hx⟩, hA, hψ⟩; subst hx
        exact hnS ⟨Sum.inl x, (rank_embed_lt h _ _).mpr hse, ⟨x, rfl⟩,
          (ihA _).mpr hA, fun u hsu hue ⟨y, hy⟩ => by subst hy; exact (ihB _).mpr (hψ (Sum.inl y)
              ((rank_embed_lt h _ _).mp hsu) ((rank_embed_lt h _ _).mp hue) ⟨y, rfl⟩)⟩
    · intro ⟨hcof, hnS⟩; refine ⟨?_, ?_⟩
      · intro s hse ⟨x, hx⟩; subst hx
        obtain ⟨u, hsu, hue, ⟨y, hy⟩, hB⟩ :=
          hcof (Sum.inl x) ((rank_embed_lt h _ _).mp hse) ⟨x, rfl⟩; subst hy
        exact ⟨Sum.inl y, (rank_embed_le h _ _).mpr hsu,
               (rank_embed_lt h _ _).mpr hue, ⟨y, rfl⟩, (ihB _).mpr hB⟩
      · intro ⟨s, hse, ⟨x, hx⟩, hA, hψ⟩; subst hx
        exact hnS ⟨Sum.inl x, (rank_embed_lt h _ _).mp hse, ⟨x, rfl⟩,
          (ihA _).mp hA, fun u hsu hue ⟨y, hy⟩ => by subst hy; exact (ihB _).mp (hψ (Sum.inl y)
              ((rank_embed_lt h _ _).mpr hsu) ((rank_embed_lt h _ _).mpr hue) ⟨y, rfl⟩)⟩

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
    contains Stavi connectives. Since StaviFormula has no "standard Until
    of StaviFormulas" constructor, we use `flatten_stavi` to convert the
    Stavi-enriched compound X and the guard D back to base Formulas, then
    wrap in `.base (.untl ...)`. This is syntactically correct; semantic
    correctness (connecting flatten_stavi with stavi_temporal_truth_mu) is
    established in Lemma 9. -/
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
    -- The compound X contains Stavi connectives, so we flatten to base Formula.
    let bD := .base ψ  -- B as StaviFormula
    let sAB := .base (.snce φ ψ)  -- S(A,B) as StaviFormula
    let bAndD := StaviFormula.conj bD D  -- B ∧ D
    let uPrimTopBD := StaviFormula.stavi_untl (.base Formula.top) bAndD  -- U'(⊤, B∧D)
    let negUPrimDBD := StaviFormula.neg (StaviFormula.stavi_untl D bAndD)  -- ¬U'(D, B∧D)
    let compound := StaviFormula.conj D
      (StaviFormula.conj bD
        (StaviFormula.conj sAB
          (StaviFormula.conj uPrimTopBD negUPrimDBD)))
    -- U(compound, D): standard Until of StaviFormulas, flattened to base
    .base (.untl (flatten_stavi compound) (flatten_stavi D))

/--
Gap detection formula `left(A, D)` from GHR93 Definition 8.5.

Given a StaviFormula A (describing what should hold at a gap) and a
StaviFormula D (the gap-defining formula), `left_formula A D` produces
a StaviFormula that detects whether there is a D-defined gap gamma > m
where A^mu holds at gamma, with D holding on all points between m and gamma.

The definition is by structural induction on A, following GHR93 exactly
for all cases. For the `.stavi_snce` case (and the `.base (.snce ...)` case),
the result uses `flatten_stavi` to encode standard Until of Stavi-enriched
subformulas as a base Formula.
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
    -- Standard Until of StaviFormulas, flattened to base Formula
    .base (.untl (flatten_stavi compound) (flatten_stavi D))

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
    -- Dual: S case in right corresponds to U case in left for Since subformulas
    let bD := .base ψ
    let uAB := .base (.untl φ ψ)
    let bAndD := StaviFormula.conj bD D
    let sPrimTopBD := StaviFormula.stavi_snce (.base Formula.top) bAndD
    let negSPrimDBD := StaviFormula.neg (StaviFormula.stavi_snce D bAndD)
    let compound := StaviFormula.conj D
      (StaviFormula.conj bD
        (StaviFormula.conj uAB
          (StaviFormula.conj sPrimTopBD negSPrimDBD)))
    .base (.snce (flatten_stavi compound) (flatten_stavi D))
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
    .base (.snce (flatten_stavi compound) (flatten_stavi D))
  | .stavi_snce A B, D =>
    -- right(S'(A,B), D) = S'(B ∧ S'(A,B), D)
    .stavi_snce (.conj B (.stavi_snce A B)) D

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
    -- The snce case uses flatten_stavi. The bound follows from
    -- operator_depth_flatten_stavi_le applied to the compound and D,
    -- combined with the fact that stavi_depth of the compound is bounded
    -- by max(operator_depth φ, operator_depth ψ) + 2 and stavi_depth D.
    -- The resulting max arithmetic is within the bound.
    simp only [left_formula_base, stavi_depth, operator_depth, Formula.top]
    have h1 := operator_depth_flatten_stavi_le D
    have h2 := operator_depth_flatten_stavi_le
      (D.conj ((StaviFormula.base ψ).conj ((StaviFormula.base (φ.snce ψ)).conj
        (((StaviFormula.base (Formula.bot.imp Formula.bot)).stavi_untl
          ((StaviFormula.base ψ).conj D)).conj
        (D.stavi_untl ((StaviFormula.base ψ).conj D)).neg))))
    simp only [stavi_depth, operator_depth] at h2
    -- The RHS of h2 simplifies: the nested max expressions collapse
    -- to max(operator_depth φ)(max(operator_depth ψ)(stavi_depth D)) + 2
    have key : max (stavi_depth D) (max (operator_depth ψ) (max (max (operator_depth φ) (operator_depth ψ) + 2) (max (max (max 0 0) (max (operator_depth ψ) (stavi_depth D)) + 2) (max (stavi_depth D) (max (operator_depth ψ) (stavi_depth D)) + 2)))) ≤ max (max (operator_depth φ) (operator_depth ψ) + 2) (stavi_depth D) + 2 := by omega
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
    -- left(S'(A,B), D) = .base (.untl (flatten compound) (flatten D))
    -- stavi_depth = max (op_depth (flatten compound)) (op_depth (flatten D)) + 2
    -- compound = D ∧ B ∧ S'(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D)
    -- stavi_depth compound ≤ max(stavi_depth A)(max(stavi_depth B)(stavi_depth D)) + 2
    -- op_depth (flatten compound) ≤ stavi_depth compound (by operator_depth_flatten_stavi_le)
    simp only [left_formula, stavi_depth, operator_depth, Formula.top]
    have hD := operator_depth_flatten_stavi_le D
    have hC := operator_depth_flatten_stavi_le
      (StaviFormula.conj D (StaviFormula.conj B (StaviFormula.conj (StaviFormula.stavi_snce A B)
        (StaviFormula.conj (StaviFormula.stavi_untl (StaviFormula.base (Formula.bot.imp Formula.bot)) (StaviFormula.conj B D))
          (StaviFormula.neg (StaviFormula.stavi_untl D (StaviFormula.conj B D)))))))
    simp only [stavi_depth, operator_depth] at hC
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
      simp only [right_formula_base, stavi_depth, operator_depth, Formula.top]
      have hD := operator_depth_flatten_stavi_le D
      have hC := operator_depth_flatten_stavi_le
        (StaviFormula.conj D (StaviFormula.conj (StaviFormula.base ψ)
          (StaviFormula.conj (StaviFormula.base (φ.untl ψ))
            (StaviFormula.conj
              (StaviFormula.stavi_snce (StaviFormula.base (Formula.bot.imp Formula.bot))
                (StaviFormula.conj (StaviFormula.base ψ) D))
              (StaviFormula.neg (StaviFormula.stavi_snce D
                (StaviFormula.conj (StaviFormula.base ψ) D)))))))
      simp only [stavi_depth, operator_depth] at hC
      have key : max (stavi_depth D) (max (operator_depth ψ)
        (max (max (operator_depth φ) (operator_depth ψ) + 2)
          (max (max (max 0 0) (max (operator_depth ψ) (stavi_depth D)) + 2)
            (max (stavi_depth D) (max (operator_depth ψ) (stavi_depth D)) + 2)))) ≤
        max (max (operator_depth φ) (operator_depth ψ) + 2) (stavi_depth D) + 2 := by omega
      omega
    | snce φ ψ => simp only [right_formula_base, stavi_depth, operator_depth]; omega
  | neg A ih =>
    simp only [right_formula, stavi_depth, Formula.top, operator_depth] at *
    omega
  | conj A B ihA ihB =>
    simp only [right_formula, stavi_depth]
    omega
  | stavi_untl A B =>
    -- right(U'(A,B), D) = S(compound, D) via flatten
    simp only [right_formula, stavi_depth, operator_depth, Formula.top]
    have hD := operator_depth_flatten_stavi_le D
    have hC := operator_depth_flatten_stavi_le
      (StaviFormula.conj D (StaviFormula.conj B (StaviFormula.conj (StaviFormula.stavi_untl A B)
        (StaviFormula.conj (StaviFormula.stavi_snce (StaviFormula.base (Formula.bot.imp Formula.bot)) (StaviFormula.conj B D))
          (StaviFormula.neg (StaviFormula.stavi_snce D (StaviFormula.conj B D)))))))
    simp only [stavi_depth, operator_depth] at hC
    omega
  | stavi_snce A B =>
    -- right(S'(A,B), D) = S'(B ∧ S'(A,B), D)
    simp only [right_formula, stavi_depth]
    omega

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
the semantic gap properties. The S/S' cases are particularly complex
due to the flatten_stavi encoding. This is sorry'd pending the full
game-theoretic proof in Phase 4C.
-/
theorem left_formula_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (A D : StaviFormula) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula A D) ↔
    (∃ (γ : RDefinableGap M atomMap r),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m < Sum.inr γ ∧
      gap_definable_on_left M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      stavi_temporal_truth_mu M atomMap r (Sum.inr γ) A) := by
  sorry

/--
**GHR93 Lemma 9** (Gap detection correctness, right direction):
right_formula(A, D) evaluated at an actual point m in M_r detects
whether A^mu holds at a gap gamma that is D-defined on the right,
with gamma < m and D holding at all actual points between gamma and m.
-/
theorem right_formula_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (A D : StaviFormula) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (right_formula A D) ↔
    (∃ (γ : RDefinableGap M atomMap r),
      extendPoint (sig := sig) (atomMap := atomMap) (r := r) m > Sum.inr γ ∧
      gap_definable_on_right M atomMap γ.val D ∧
      (∀ u : M.carrier, u < m → u ∉ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) D) ∧
      stavi_temporal_truth_mu M atomMap r (Sum.inr γ) A) := by
  sorry

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

    NOTE: Sorry'd. The proof requires showing that the game's winning
    condition (order type + rank-r formula agreement) implies rank_type
    equality at each position, which needs that formula agreement at all
    depths ≤ r determines the rank_type. This is used in Phase 4C. -/
theorem ghr93_game_implies_decomposition {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h : ghr93_duplicator_wins M N atomMap n r x y x' y') :
    decomposition_agreement M N atomMap n r x y x' y' := by
  sorry

/-- **GHR93 Lemma 11** (Game ↔ decomposition agreement, backward direction):

    If M_r and N_r agree on all (n;r)-decomposition formulas at (x,y)/(x',y'),
    then Duplicator has a winning strategy for G_{n;r}(M, x y; N, x' y').

    Intuitively: decomposition agreement provides Duplicator with matching
    selections (from the forward condition). For the point challenge (Round 2),
    the type agreement ensures that any actual point in [x',y'] ∩ N has a
    type-matching actual point in [x,y] ∩ M.

    NOTE: Sorry'd. The proof constructs Duplicator's strategy from the
    decomposition agreement: use the forward matching for Round 1, then
    use the type information to handle Round 2. This is used in Phase 4C. -/
theorem ghr93_decomposition_implies_game {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r}
    (h : decomposition_agreement M N atomMap n r x y x' y') :
    ghr93_duplicator_wins M N atomMap n r x y x' y' := by
  sorry

/-- **GHR93 Lemma 11** (Game ↔ decomposition agreement, iff version):

    Duplicator has a winning strategy for G_{n;r}(M, x y; N, x' y') iff
    M_r and N_r agree on all (n;r)-decomposition formulas at (x,y)/(x',y').

    This is the key bridge between the game-theoretic perspective (strategies)
    and the formula-theoretic perspective (decomposition formulas). -/
theorem ghr93_game_iff_decomposition {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {n r : Nat}
    {x y : ExtendedCarrier M atomMap r} {x' y' : ExtendedCarrier N atomMap r} :
    ghr93_duplicator_wins M N atomMap n r x y x' y' ↔
    decomposition_agreement M N atomMap n r x y x' y' :=
  ⟨ghr93_game_implies_decomposition, ghr93_decomposition_implies_game⟩

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
