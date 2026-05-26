import Bimodal.Metalogic.WeakCanonical.StaviConnectives
import Bimodal.Metalogic.WeakCanonical.NormalForm

/-!
# EF Game Foundations: Positions, N-Equivalence, Gap Structures

EF game foundations: positions, n-equivalence, gap structures, and rank embedding basics.
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
noncomputable def extendedLE {sig : MonadicSignature}
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

end Bimodal.Metalogic.WeakCanonical
