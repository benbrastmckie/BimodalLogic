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
