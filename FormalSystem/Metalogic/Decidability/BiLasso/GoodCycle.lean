/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Realized
import FormalSystem.Metalogic.Decidability.FMP.Periodicity
import Mathlib.Data.Int.LeastGreatest

/-!
# Good Cycles, with an Explicit Length Bound

`BiLasso/Realized.lean` supplies a finite graph of pigeonhole data and the lemma that a walk of
coherent edges is locally coherent. What it does not supply is **fulfilment**: local coherence is
satisfied by the greatest fixpoint, in which an `untl` is passed forward forever and its event
never delivered. This module extracts cycles that *do* deliver, and — this is the point of the
whole file — bounds their length by a closed arithmetic expression in `P.card` and
`subformulaClosureCard φ`.

## Why an explicit bound is mandatory rather than nice

`check` calls `boundedAnnots P φ bx n` at a **computed** `n`. A merely existential `∃ n` supplies
no such `n`, so the decision procedure could not be written at all; a `Decidable` instance would
then be available only through `Classical.dec`, which would make `check` non-computing. So the
degeneralisation below is forced, not preferred.

## The degeneralisation, done as marks on a walk

A Büchi degeneralisation ordinarily enriches the state space with a `pending` counter. That route
was tried in the previous round and produced existence without a bound. This module keeps the
landed `(state, type)` datum unchanged and puts the degeneralisation in the *walk*:

- Every `untl g e` carried by the base datum `x` gets one **mark** — a position on the cycle where
  its event `e` is realised.
- Marks are supplied by the history itself: `typeAt_fulfillingSeq` (`SmallModel.lean`) says a
  genuine history discharges its own eventualities.
- The stretches *between* marks are shortened independently by
  `exists_lt_iter_of_card_le` (`FMP/Periodicity.lean`), each down to fewer than
  `Nat.card (PigeonState P φ)` steps. Shortening excises a loop between two positions carrying the
  *same* datum, so it moves no mark: the marks sit at segment endpoints, and endpoints are what
  the shortening preserves.

Only the untl-formulas of the **base** type need marking, and that is what `untl_propagates_to_end`
delivers: an `untl` carried at an interior position of a cycle either delivers its event before the
cycle ends, or is still carried at the cycle's endpoint — whose type is the base type. So the mark
count is capped at `subformulaClosureCard φ` *before* any loop is chosen. The same lemma supplies
`FulfillingSeq`'s interval guard for free: each undischarged step forces the guard at the next
position.

## The derived bound, and how it differs from the plan's estimate

The plan's Scope Hypothesis estimated `(k + 1) · N` with `k = subformulaClosureCard φ` and
`N = Nat.card (PigeonState P φ)`, on the assumption that the `m` marks could be laid out along a
single traversal in increasing time order, giving `m + 1` segments.

**The derived bound is `(2k + 1) · N`, and the plan's contingency for exactly this case is
followed: the consumer is kept in sync rather than the derivation bent to the estimate.** Laying
the marks out in a single increasing traversal requires *sorting* the `m` witness times, which the
construction avoids: each mark is obtained independently from the base datum and reached by an
out-and-back excursion `x ⟶ mark ⟶ x`, contributing **two** shortened segments rather than one.
Hence `2m` segments for the marks plus one base cycle, and `m ≤ k`. Nothing is lost — the bound is
a bound, and `Extraction.lean`'s `bound` reads this quantity off `cycleBound` rather than
restating it.

## Main Definitions

- `SeqStep` — the edge relation induced by an arbitrary datum sequence; `RealizedStep` is this at
  the history's own datum sequence, definitionally
- `untlEvent` / `snceEvent` — the event of an eventuality formula, as a partial function
- `cycleBound` — the closed arithmetic bound `(2k + 1) · P.card · 2^k`

## Main Results

- `untl_propagates_to_end` / `snce_propagates_to_start` — the interior-eventuality reduction
- `exists_recurring_datum` — some datum recurs at arbitrarily large (and arbitrarily small) times
- `exists_good_fwd_cycle` / `exists_good_bwd_cycle` — the two bounded good cycles
- `fulfilling_of_good_cycles` — two good cycles plus periodicity give `FulfillingSeq`

Argument order is **guard first** throughout: `Formula.untl g e` and `Formula.snce g e` have guard
`g` and event `e`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {P : IntPresentation} {φ : Formula} {bx : Formula → Bool}

/-! ## The interior-eventuality reduction -/

/--
**An undischarged `untl` survives to the end of the stretch, guard intact.**

If `Formula.untl g e` is carried at `t` and its event `e` appears nowhere in `(t, T]`, then the
obligation is still carried at `T` and the guard `g` holds at every position of `(t, T]`.

Two consequences, both used below:

1. **The mark count is capped before any loop is chosen.** An `untl` carried at an interior
   position of a cycle either delivers inside the cycle or is still carried at the cycle's
   endpoint, whose type is the base type. So only the untl-formulas of the *base* type need
   marking — at most `subformulaClosureCard φ` of them.
2. **`FulfillingSeq`'s interval guard is free.** Taking `T` to be one less than the *least*
   delivery position turns this lemma's guard conclusion into exactly the interval condition
   `FulfillingSeq` demands.

The proof is rightward ℤ-induction (`Int.rightInduction`, `BiLasso/Unfold.lean`) on the `untl`
clause of `LocalCoherentSeq`, which is a biconditional and therefore usable in this direction.
-/
theorem untl_propagates_to_end {lab : ℤ → Finset Formula} {st : ℤ → Fin P.card}
    (hco : LocalCoherentSeq P φ bx lab st) {g e : Formula}
    (hcl : Formula.untl g e ∈ subformulaClosure φ) {t : ℤ}
    (hmem : Formula.untl g e ∈ lab t) :
    ∀ T : ℤ, t ≤ T → (∀ s : ℤ, t < s → s ≤ T → e ∉ lab s) →
      Formula.untl g e ∈ lab T ∧ ∀ r : ℤ, t < r → r ≤ T → g ∈ lab r := by
  refine Int.rightInduction (t := t) (P := fun T =>
      (∀ s : ℤ, t < s → s ≤ T → e ∉ lab s) →
        Formula.untl g e ∈ lab T ∧ ∀ r : ℤ, t < r → r ≤ T → g ∈ lab r) ?_ ?_
  · exact fun _ => ⟨hmem, fun r h1 h2 => absurd h1 (by omega)⟩
  · intro u hu ih hno
    obtain ⟨hcarry, hguard⟩ := ih (fun s h1 h2 => hno s h1 (by omega))
    have hclause := (hco u).2.2.2.2.1 g e hcl
    have hne : e ∉ lab (u + 1) := hno (u + 1) (by omega) (by omega)
    rcases hclause.mp hcarry with h | ⟨hg, hc⟩
    · exact absurd h hne
    · refine ⟨hc, fun r h1 h2 => ?_⟩
      rcases (by omega : r ≤ u ∨ r = u + 1) with hr | rfl
      · exact hguard r h1 hr
      · exact hg

/--
**The leftward mirror**: an undischarged `snce` survives back to the start of the stretch.

Same statement with the two temporal directions exchanged, proved by leftward ℤ-induction
(`Int.leftInduction`) on the `snce` clause. Stated as its own theorem rather than derived by a
duality, because the tree has no `Formula` duality operation and inventing one for this single use
would be more machinery than the twelve lines it saves.
-/
theorem snce_propagates_to_start {lab : ℤ → Finset Formula} {st : ℤ → Fin P.card}
    (hco : LocalCoherentSeq P φ bx lab st) {g e : Formula}
    (hcl : Formula.snce g e ∈ subformulaClosure φ) {t : ℤ}
    (hmem : Formula.snce g e ∈ lab t) :
    ∀ T : ℤ, T ≤ t → (∀ s : ℤ, T ≤ s → s < t → e ∉ lab s) →
      Formula.snce g e ∈ lab T ∧ ∀ r : ℤ, T ≤ r → r < t → g ∈ lab r := by
  refine Int.leftInduction (t := t) (P := fun T =>
      (∀ s : ℤ, T ≤ s → s < t → e ∉ lab s) →
        Formula.snce g e ∈ lab T ∧ ∀ r : ℤ, T ≤ r → r < t → g ∈ lab r) ?_ ?_
  · exact fun _ => ⟨hmem, fun r h1 h2 => absurd h1 (by omega)⟩
  · intro u hu ih hno
    obtain ⟨hcarry, hguard⟩ := ih (fun s h1 h2 => hno s (by omega) h2)
    have hclause := (hco u).2.2.2.2.2 g e hcl
    have hne : e ∉ lab (u - 1) := hno (u - 1) (by omega) (by omega)
    rcases hclause.mp hcarry with h | ⟨hg, hc⟩
    · exact absurd h hne
    · refine ⟨hc, fun r h1 h2 => ?_⟩
      rcases (by omega : u ≤ r ∨ r = u - 1) with hr | rfl
      · exact hguard r hr h2
      · exact hg

/-! ## Walks in a datum sequence -/

/--
The edge relation induced by a datum sequence: `x` steps to `y` when some index carries `x` and
its successor carries `y`.

`RealizedStep P φ τ hτ` is `SeqStep (datum P φ τ hτ)` **definitionally** (`realizedStep_eq` below),
so every result proved here about `SeqStep` applies to the realised graph without transport. The
abstraction is what lets the backward cycle reuse the forward construction verbatim, at the
reversed sequence `fun u => datum … (-u)`.
-/
def SeqStep (d : ℤ → PigeonState P φ) : PigeonState P φ → PigeonState P φ → Prop :=
  fun x y => ∃ u : ℤ, d u = x ∧ d (u + 1) = y

theorem realizedStep_eq {τ : WorldHistory P.toTaskFrame} (hτ : τ.IsTotal) :
    RealizedStep P φ τ hτ = SeqStep (datum P φ τ hτ) := rfl

/-- A stretch of the datum sequence is an iterate of its edge relation. -/
theorem iter_seqStep (d : ℤ → PigeonState P φ) (a : ℤ) (n : ℕ) :
    iter (SeqStep d) n (d a) (d (a + (n : ℤ))) := by
  induction n with
  | zero => simp
  | succ n ih =>
    refine ⟨d (a + (n : ℤ)), ih, ⟨a + (n : ℤ), rfl, ?_⟩⟩
    congr 1
    omega

/--
**Any iterate shortens to one of length below the carrier's cardinality**, between the same
endpoints.

Repeated application of `exists_lt_iter_of_card_le` (`FMP/Periodicity.lean`). The fuel parameter
`k` is an artefact of doing the strong induction by ordinary recursion; `exists_iter_lt_card` below
is the form every call site uses.
-/
theorem exists_iter_lt_card_aux {W : Type} [Finite W] [Nonempty W] (R : W → W → Prop) :
    ∀ (k n : ℕ), n ≤ k → ∀ w u : W, iter R n w u → ∃ m, m < Nat.card W ∧ iter R m w u := by
  intro k
  induction k with
  | zero =>
    intro n hn w u h
    have hn0 : n = 0 := by omega
    subst hn0
    exact ⟨0, Nat.card_pos, h⟩
  | succ k ih =>
    intro n hn w u h
    rcases lt_or_ge n (Nat.card W) with hlt | hge
    · exact ⟨n, hlt, h⟩
    · obtain ⟨m, hm, hmiter⟩ := exists_lt_iter_of_card_le R h hge
      exact ih m (by omega) w u hmiter

theorem exists_iter_lt_card {W : Type} [Finite W] [Nonempty W] (R : W → W → Prop) {n : ℕ}
    {w u : W} (h : iter R n w u) : ∃ m, m < Nat.card W ∧ iter R m w u :=
  exists_iter_lt_card_aux R n n le_rfl w u h

/-! ### Concatenating walks -/

/-- Concatenation of two walks: `p` on `[0, L]`, then `q` shifted to start at `L`. -/
def joinPath (p q : ℕ → PigeonState P φ) (L : ℕ) : ℕ → PigeonState P φ :=
  fun j => if j ≤ L then p j else q (j - L)

theorem joinPath_left (p q : ℕ → PigeonState P φ) {L j : ℕ} (h : j ≤ L) :
    joinPath p q L j = p j := if_pos h

theorem joinPath_right (p q : ℕ → PigeonState P φ) (L : ℕ) (hpq : p L = q 0) (i : ℕ) :
    joinPath p q L (L + i) = q i := by
  rcases Nat.eq_zero_or_pos i with rfl | hi
  · simp [joinPath, hpq]
  · have hnot : ¬ (L + i ≤ L) := by omega
    have hsub : L + i - L = i := by omega
    simp only [joinPath, if_neg hnot, hsub]

theorem joinPath_steps {d : ℤ → PigeonState P φ} (p q : ℕ → PigeonState P φ) (L L' : ℕ)
    (hpq : p L = q 0)
    (hp : ∀ j, j < L → SeqStep d (p j) (p (j + 1)))
    (hq : ∀ j, j < L' → SeqStep d (q j) (q (j + 1))) :
    ∀ j, j < L + L' → SeqStep d (joinPath p q L j) (joinPath p q L (j + 1)) := by
  intro j hj
  rcases lt_or_ge j L with h | h
  · rw [joinPath_left p q (le_of_lt h), joinPath_left p q (by omega : j + 1 ≤ L)]
    exact hp j h
  · obtain ⟨i, rfl⟩ : ∃ i, j = L + i := ⟨j - L, by omega⟩
    rw [joinPath_right p q L hpq i, show L + i + 1 = L + (i + 1) by omega,
      joinPath_right p q L hpq (i + 1)]
    exact hq i (by omega)

/-! ## Recurrence -/

/--
**Some datum recurs at arbitrarily large indices.**

Pure finiteness: if every datum had a last occurrence, the finitely many last occurrences would
have an upper bound, and the datum at that bound would occur after its own last occurrence.
-/
theorem exists_recurring_datum (d : ℤ → PigeonState P φ) :
    ∃ x : PigeonState P φ, ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x := by
  classical
  by_contra hcon
  push Not at hcon
  choose f hf using hcon
  have hne : (Finset.univ : Finset (PigeonState P φ)).Nonempty := Finset.univ_nonempty
  have hle : f (d (Finset.univ.sup' hne f)) ≤ Finset.univ.sup' hne f :=
    Finset.le_sup' f (Finset.mem_univ _)
  exact hf _ _ hle rfl

/-! ## Good cycles -/

/-- The event of an `untl`-formula, as a partial function. -/
def untlEvent : Formula → Option Formula
  | Formula.untl _ e => some e
  | _ => none

/-- The event of a `snce`-formula, as a partial function. -/
def snceEvent : Formula → Option Formula
  | Formula.snce _ e => some e
  | _ => none

@[simp] theorem untlEvent_untl (g e : Formula) : untlEvent (Formula.untl g e) = some e := rfl
@[simp] theorem snceEvent_snce (g e : Formula) : snceEvent (Formula.snce g e) = some e := rfl

/--
**The explicit cycle bound**: `(2k + 1) · P.card · 2^k` with `k = subformulaClosureCard φ`.

A closed arithmetic expression in the presentation's size and the closure's size — not an
existentially quantified `n`. `Extraction.lean`'s `bound` is defined from this, so the derived
quantity and its consumer cannot drift apart.
-/
def cycleBound (P : IntPresentation) (φ : Formula) : ℕ :=
  (2 * subformulaClosureCard φ + 1) * (P.card * 2 ^ subformulaClosureCard φ)

theorem cycleBound_eq (P : IntPresentation) (φ : Formula) :
    cycleBound P φ = (2 * subformulaClosureCard φ + 1) * Nat.card (PigeonState P φ) := by
  rw [cycleBound, natCard_pigeonState]

/--
A cycle through a recurring datum, with no marks: length at least one and at most one full residue
system.

The first step is taken from the history directly and only the *return* leg is shortened, which is
what keeps the length positive. A cycle shortened as a whole could collapse to length zero — the
excision of the entire loop — and a zero-length cycle discharges nothing and cannot serve as a
bi-lasso segment, since `BiLasso.back_ne` and `BiLasso.fwd_ne` forbid empty cycles.
-/
theorem exists_base_cycle (d : ℤ → PigeonState P φ) (x : PigeonState P φ)
    (hrec : ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x) :
    ∃ (L : ℕ) (p : ℕ → PigeonState P φ),
      1 ≤ L ∧ L ≤ Nat.card (PigeonState P φ) ∧ p 0 = x ∧ p L = x ∧
      ∀ j, j < L → SeqStep d (p j) (p (j + 1)) := by
  obtain ⟨u₀, -, hu₀⟩ := hrec 0
  obtain ⟨u₁, hu₁le, hu₁⟩ := hrec (u₀ + 1)
  have hit : iter (SeqStep d) (u₁ - (u₀ + 1)).toNat (d (u₀ + 1)) x := by
    have h := iter_seqStep d (u₀ + 1) (u₁ - (u₀ + 1)).toNat
    rwa [show u₀ + 1 + (((u₁ - (u₀ + 1)).toNat : ℕ) : ℤ) = u₁ by omega, hu₁] at h
  obtain ⟨b, hb, hbiter⟩ := exists_iter_lt_card (SeqStep d) hit
  obtain ⟨pb, hpb0, hpbb, hpbst⟩ := exists_path_of_iter (SeqStep d) b _ _ hbiter
  refine ⟨b + 1, fun j => if j = 0 then x else pb (j - 1), by omega, by omega, by simp, ?_, ?_⟩
  · simpa using hpbb
  · intro j hj
    rcases Nat.eq_zero_or_pos j with rfl | hjpos
    · simp only [hpb0]
      exact ⟨u₀, hu₀, rfl⟩
    · have h1 : ¬ j = 0 := by omega
      have h2 : ¬ j + 1 = 0 := by omega
      simp only [if_neg h1, if_neg h2]
      have hstep := hpbst (j - 1) (by omega)
      rwa [show j - 1 + 1 = j + 1 - 1 by omega] at hstep

/-- An `untlEvent` witness identifies its formula as an `untl` with that event. -/
theorem untlEvent_eq_some : ∀ {f e : Formula}, untlEvent f = some e → ∃ g, f = Formula.untl g e
  | Formula.untl g _, _, rfl => ⟨g, rfl⟩

/-- A `snceEvent` witness identifies its formula as a `snce` with that event. -/
theorem snceEvent_eq_some : ∀ {f e : Formula}, snceEvent f = some e → ∃ g, f = Formula.snce g e
  | Formula.snce g _, _, rfl => ⟨g, rfl⟩

/--
**The good-cycle construction, at an arbitrary datum sequence.**

Given a datum `x` that recurs at arbitrarily large indices, and a sequence that discharges its own
eventualities, this produces a cycle through `x` of length between `1` and `cycleBound P φ` whose
positions realise the event of every eventuality carried by `x`.

The construction is an induction over the *type* of `x` as a `Finset`, starting from
`exists_base_cycle` and appending, for each formula with an event, an out-and-back excursion
`x ⟶ mark ⟶ x` whose two legs are separately shortened. Two facts make it work:

- **The excursion is available**: the sequence's own fulfilment supplies a later index carrying the
  event, and recurrence supplies a still later index carrying `x` again.
- **Shortening cannot destroy a mark**: the mark sits at the junction of the two legs, and
  `exists_iter_lt_card` preserves endpoints.

Formulas with no event contribute nothing and reuse the cycle built so far; the bound is stated
per-formula, so unused budget is simply not spent.

The statement is generic in the sequence so that the backward cycle can instantiate it at
`fun u => datum … (-u)` rather than duplicating two hundred lines with the temporal direction
flipped.
-/
theorem exists_good_cycle_of_seq (d : ℤ → PigeonState P φ) (ev : Formula → Option Formula)
    (x : PigeonState P φ)
    (hrec : ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ d u = x)
    (hful : ∀ (u : ℤ) (f e : Formula), f ∈ typeOf (d u) → ev f = some e →
        ∃ s : ℤ, u < s ∧ e ∈ typeOf (d s)) :
    ∃ (L : ℕ) (p : ℕ → PigeonState P φ),
      1 ≤ L ∧ L ≤ cycleBound P φ ∧ p 0 = x ∧ p L = x ∧
      (∀ j, j < L → SeqStep d (p j) (p (j + 1))) ∧
      (∀ f e : Formula, f ∈ typeOf x → ev f = some e →
        ∃ j, j < L ∧ e ∈ typeOf (p (j + 1))) := by
  classical
  have hkey : ∀ S : Finset Formula, S ⊆ typeOf x →
      ∃ (L : ℕ) (p : ℕ → PigeonState P φ),
        1 ≤ L ∧ L ≤ (2 * S.card + 1) * Nat.card (PigeonState P φ) ∧ p 0 = x ∧ p L = x ∧
        (∀ j, j < L → SeqStep d (p j) (p (j + 1))) ∧
        (∀ f e : Formula, f ∈ S → ev f = some e →
          ∃ j, j < L ∧ e ∈ typeOf (p (j + 1))) := by
    intro S
    induction S using Finset.induction_on with
    | empty =>
      intro _
      obtain ⟨L, p, h1, h2, h3, h4, h5⟩ := exists_base_cycle d x hrec
      refine ⟨L, p, h1, ?_, h3, h4, h5, ?_⟩
      · simpa using h2
      · intro f e hf _
        exact absurd hf (Finset.notMem_empty f)
    | @insert f S hf ih =>
      intro hsub
      obtain ⟨L', p', h1, h2, h3, h4, h5, h6⟩ :=
        ih (fun y hy => hsub (Finset.mem_insert_of_mem hy))
      rw [Finset.card_insert_of_notMem hf]
      cases hev : ev f with
      | none =>
        refine ⟨L', p', h1, le_trans h2 (Nat.mul_le_mul (by omega) (le_refl _)), h3, h4, h5, ?_⟩
        intro f' e hf' hev'
        rcases Finset.mem_insert.mp hf' with rfl | hf'S
        · rw [hev] at hev'
          exact absurd hev' (by simp)
        · exact h6 f' e hf'S hev'
      | some e =>
        obtain ⟨u₀, -, hu₀⟩ := hrec 0
        have hfx : f ∈ typeOf (d u₀) := by
          rw [hu₀]; exact hsub (Finset.mem_insert_self f S)
        obtain ⟨s, hs, hes⟩ := hful u₀ f e hfx hev
        obtain ⟨u₁, hu₁le, hu₁⟩ := hrec (s + 1)
        have hitA : iter (SeqStep d) (s - u₀).toNat x (d s) := by
          have h := iter_seqStep d u₀ (s - u₀).toNat
          rw [hu₀] at h
          rwa [show u₀ + (((s - u₀).toNat : ℕ) : ℤ) = s by omega] at h
        obtain ⟨a, ha, haiter⟩ := exists_iter_lt_card (SeqStep d) hitA
        have hitB : iter (SeqStep d) (u₁ - s).toNat (d s) x := by
          have h := iter_seqStep d s (u₁ - s).toNat
          rwa [show s + (((u₁ - s).toNat : ℕ) : ℤ) = u₁ by omega, hu₁] at h
        obtain ⟨b, hb, hbiter⟩ := exists_iter_lt_card (SeqStep d) hitB
        obtain ⟨pa, hpa0, hpaa, hpast⟩ := exists_path_of_iter (SeqStep d) a _ _ haiter
        obtain ⟨pb, hpb0, hpbb, hpbst⟩ := exists_path_of_iter (SeqStep d) b _ _ hbiter
        have hseam : pa a = pb 0 := by rw [hpaa, hpb0]
        -- the excursion `x ⟶ d s ⟶ x`, as one walk of length `a + b`
        have hq0 : joinPath pa pb a 0 = x := by rw [joinPath_left pa pb (Nat.zero_le a), hpa0]
        have hqa : joinPath pa pb a a = d s := by rw [joinPath_left pa pb (le_refl a), hpaa]
        have hqab : joinPath pa pb a (a + b) = x := by
          rw [joinPath_right pa pb a hseam b, hpbb]
        have hqst := joinPath_steps pa pb a b hseam hpast hpbst
        have hp'q : p' L' = joinPath pa pb a 0 := by rw [h4, hq0]
        refine ⟨L' + (a + b), joinPath p' (joinPath pa pb a) L', by omega, ?_, ?_, ?_, ?_, ?_⟩
        · obtain ⟨A, hA⟩ : ∃ A, (2 * S.card + 1) * Nat.card (PigeonState P φ) = A := ⟨_, rfl⟩
          have harith : (2 * (S.card + 1) + 1) * Nat.card (PigeonState P φ)
              = A + 2 * Nat.card (PigeonState P φ) := by
            rw [← hA, show 2 * (S.card + 1) + 1 = (2 * S.card + 1) + 2 by omega, Nat.add_mul]
          rw [hA] at h2
          rw [harith]
          omega
        · rw [joinPath_left p' _ (Nat.zero_le L'), h3]
        · rw [joinPath_right p' _ L' hp'q (a + b), hqab]
        · exact joinPath_steps p' _ L' (a + b) hp'q h5 hqst
        · intro f' e' hf' hev'
          rcases Finset.mem_insert.mp hf' with rfl | hf'S
          · -- the newly marked formula: its event sits at the junction of the two legs
            have hee : e' = e := by rw [hev] at hev'; exact (Option.some.injEq _ _ ▸ hev').symm
            subst hee
            refine ⟨L' + a - 1, by omega, ?_⟩
            rw [show L' + a - 1 + 1 = L' + a by omega, joinPath_right p' _ L' hp'q a, hqa]
            exact hes
          · -- an older mark: it lives in the prefix, which the join leaves untouched
            obtain ⟨j, hj, hjmem⟩ := h6 f' e' hf'S hev'
            exact ⟨j, by omega, by rwa [joinPath_left p' _ (by omega : j + 1 ≤ L')]⟩
  obtain ⟨L, p, h1, h2, h3, h4, h5, h6⟩ := hkey (typeOf x) (Finset.Subset.refl _)
  refine ⟨L, p, h1, ?_, h3, h4, h5, h6⟩
  rw [cycleBound_eq]
  refine le_trans h2 (Nat.mul_le_mul ?_ (le_refl _))
  have hc : (typeOf x).card ≤ subformulaClosureCard φ :=
    Finset.card_le_card (typeOf_subset x)
  omega

/-! ### The two instantiations -/

/--
**A good forward cycle**: a cycle through a forward-recurring datum, of length at most
`cycleBound P φ`, on which every `untl` carried by the base datum has its event realised.

`RealizedStep` is `SeqStep` at the history's own datum sequence definitionally, so this is
`exists_good_cycle_of_seq` with the fulfilment obligation discharged by `typeAt_fulfillingSeq`
(`SmallModel.lean`) — the observation that a *genuine* history discharges its own eventualities
for free.
-/
theorem exists_good_fwd_cycle {τ : WorldHistory P.toTaskFrame} (hτ : τ.IsTotal)
    (x : PigeonState P φ) (hrec : ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ datum P φ τ hτ u = x) :
    ∃ (L : ℕ) (p : ℕ → PigeonState P φ),
      1 ≤ L ∧ L ≤ cycleBound P φ ∧ p 0 = x ∧ p L = x ∧
      (∀ j, j < L → RealizedStep P φ τ hτ (p j) (p (j + 1))) ∧
      (∀ g e : Formula, Formula.untl g e ∈ typeOf x →
        ∃ j, j < L ∧ e ∈ typeOf (p (j + 1))) := by
  have hful : ∀ (u : ℤ) (f e : Formula), f ∈ typeOf (datum P φ τ hτ u) →
      untlEvent f = some e → ∃ s : ℤ, u < s ∧ e ∈ typeOf (datum P φ τ hτ s) := by
    intro u f e hfm hev
    obtain ⟨g, rfl⟩ := untlEvent_eq_some hev
    rw [datum_type] at hfm
    obtain ⟨s, hs, hes, -⟩ := (typeAt_fulfillingSeq (P := P) (φ := φ) τ).1 u g e hfm
    exact ⟨s, hs, by rwa [datum_type]⟩
  obtain ⟨L, p, h1, h2, h3, h4, h5, h6⟩ :=
    exists_good_cycle_of_seq (datum P φ τ hτ) untlEvent x hrec hful
  exact ⟨L, p, h1, h2, h3, h4, h5, fun g e hge => h6 _ e hge rfl⟩

/--
**A good backward cycle**, indexed by distance into the past.

`q 0` is the base datum, `q (j + 1)` sits one step *earlier* in time than `q j`, and every step is
a realised edge read in the forward direction — `RealizedStep (q (j + 1)) (q j)`. That is the form
the assembly needs, since a bi-lasso's `back` segment is still a forward walk in time; only the
search for `snce` witnesses runs leftward.

Obtained from `exists_good_cycle_of_seq` at the reversed datum sequence `fun u => datum … (-u)`,
which is exactly the mirror the plan prescribes.
-/
theorem exists_good_bwd_cycle {τ : WorldHistory P.toTaskFrame} (hτ : τ.IsTotal)
    (x : PigeonState P φ) (hrec : ∀ N : ℤ, ∃ u : ℤ, N ≤ u ∧ datum P φ τ hτ (-u) = x) :
    ∃ (L : ℕ) (q : ℕ → PigeonState P φ),
      1 ≤ L ∧ L ≤ cycleBound P φ ∧ q 0 = x ∧ q L = x ∧
      (∀ j, j < L → RealizedStep P φ τ hτ (q (j + 1)) (q j)) ∧
      (∀ g e : Formula, Formula.snce g e ∈ typeOf x →
        ∃ j, j < L ∧ e ∈ typeOf (q (j + 1))) := by
  have hful : ∀ (u : ℤ) (f e : Formula), f ∈ typeOf (datum P φ τ hτ (-u)) →
      snceEvent f = some e → ∃ s : ℤ, u < s ∧ e ∈ typeOf (datum P φ τ hτ (-s)) := by
    intro u f e hfm hev
    obtain ⟨g, rfl⟩ := snceEvent_eq_some hev
    rw [datum_type] at hfm
    obtain ⟨s, hs, hes, -⟩ := (typeAt_fulfillingSeq (P := P) (φ := φ) τ).2 (-u) g e hfm
    refine ⟨-s, by omega, ?_⟩
    rw [datum_type, show -(-s) = s by omega]
    exact hes
  obtain ⟨L, q, h1, h2, h3, h4, h5, h6⟩ :=
    exists_good_cycle_of_seq (fun u => datum P φ τ hτ (-u)) snceEvent x hrec hful
  refine ⟨L, q, h1, h2, h3, h4, fun j hj => ?_, fun g e hge => h6 _ e hge rfl⟩
  obtain ⟨u, hu1, hu2⟩ := h5 j hj
  simp only at hu1 hu2
  refine ⟨-u - 1, ?_, ?_⟩
  · rw [← hu2]; congr 1; omega
  · rw [← hu1]; congr 1; omega

/-! ## From good cycles to fulfilment -/

/-- Iterated rightward periodicity: the shift by any multiple of `nf` fixes labels at or past
`nm`. -/
theorem lab_add_mul_nf {lab : ℤ → Finset Formula} {nm nf : ℤ} (hnf : 0 < nf)
    (hperf : ∀ t : ℤ, nm ≤ t → lab (t + nf) = lab t) :
    ∀ (j : ℕ) (u : ℤ), nm ≤ u → lab (u + (j : ℤ) * nf) = lab u := by
  intro j
  induction j with
  | zero => intro u _; simp
  | succ j ih =>
    intro u hu
    have hjnf : (0 : ℤ) ≤ (j : ℤ) * nf :=
      mul_nonneg (Int.natCast_nonneg j) (le_of_lt hnf)
    have hcast : ((j + 1 : ℕ) : ℤ) = (j : ℤ) + 1 := by omega
    have hexp : ((j : ℤ) + 1) * nf = (j : ℤ) * nf + nf := by rw [add_mul, one_mul]
    rw [hcast, hexp, ← add_assoc, hperf (u + (j : ℤ) * nf) (by omega)]
    exact ih u hu

/-- Iterated leftward periodicity: the shift by any multiple of `nb` fixes labels strictly left of
the origin. -/
theorem lab_sub_mul_nb {lab : ℤ → Finset Formula} {nb : ℤ} (hnb : 0 < nb)
    (hperb : ∀ t : ℤ, t < 0 → lab (t - nb) = lab t) :
    ∀ (j : ℕ) (u : ℤ), u < 0 → lab (u - (j : ℤ) * nb) = lab u := by
  intro j
  induction j with
  | zero => intro u _; simp
  | succ j ih =>
    intro u hu
    have hjnb : (0 : ℤ) ≤ (j : ℤ) * nb :=
      mul_nonneg (Int.natCast_nonneg j) (le_of_lt hnb)
    have hcast : ((j + 1 : ℕ) : ℤ) = (j : ℤ) + 1 := by omega
    have hexp : ((j : ℤ) + 1) * nb = (j : ℤ) * nb + nb := by rw [add_mul, one_mul]
    rw [hcast, hexp, ← sub_sub, hperb (u - (j : ℤ) * nb) (by omega)]
    exact ih u hu

/--
**Two good cycles and periodicity give fulfilment.**

The hypotheses are exactly what the assembly produces: a locally coherent label sequence whose
labels are closure subsets, periodic with period `nb` strictly left of the origin and with period
`nf` at or past `nm`, whose forward cycle discharges every `untl` carried at `nm` somewhere in
`(nm, nm + nf]`, and whose backward cycle discharges every `snce` carried at `-1` somewhere in
`[-1 - nb, -1)`.

The argument, in the `untl` direction (the `snce` direction is its mirror), has two steps and both
are needed:

1. **Some delivery exists.** Suppose none did. Then `untl_propagates_to_end` carries the
   obligation arbitrarily far right; in particular to `nm + A` for a shift `A` that is a multiple
   of `nf` large enough to reach past `t`. Periodicity identifies that label with `lab nm`, where
   the good cycle supplies a delivery at some `s₀ ∈ (nm, nm + nf]`; shifting that delivery back by
   the same `A` lands it strictly right of `t` — contradiction. **This is where the cycle's
   goodness is spent**, and it is the only place it is needed.
2. **The interval guard is free.** Take `s` to be the *least* delivery strictly right of `t`
   (`Int.exists_least_of_bdd`; the set is bounded below by `t` and nonempty by step 1). Then no
   delivery occurs in `(t, s)`, so `untl_propagates_to_end` run to `s - 1` returns exactly the
   guard `FulfillingSeq` demands.

This is the prescribed sequence-level propagation route, not the sanctioned window-collapse
fallback: the collapse (`Decide.lean`'s `fulfilling_iff_window`) is stated for an `Annot`, whereas
the assembly needs the conclusion at bare sequences, before any `Annot` exists.
-/
theorem fulfilling_of_good_cycles {lab : ℤ → Finset Formula} {st : ℤ → Fin P.card}
    (hco : LocalCoherentSeq P φ bx lab st)
    (hsub : ∀ t : ℤ, lab t ⊆ subformulaClosure φ)
    {nb nf nm : ℤ} (hnb : 0 < nb) (hnf : 0 < nf)
    (hperb : ∀ t : ℤ, t < 0 → lab (t - nb) = lab t)
    (hperf : ∀ t : ℤ, nm ≤ t → lab (t + nf) = lab t)
    (hgoodf : ∀ g e : Formula, Formula.untl g e ∈ lab nm →
        ∃ s : ℤ, nm < s ∧ s ≤ nm + nf ∧ e ∈ lab s)
    (hgoodb : ∀ g e : Formula, Formula.snce g e ∈ lab (-1) →
        ∃ s : ℤ, -1 - nb ≤ s ∧ s < -1 ∧ e ∈ lab s) :
    FulfillingSeq lab := by
  have hfw := lab_add_mul_nf (lab := lab) (nm := nm) hnf hperf
  have hbw := lab_sub_mul_nb (lab := lab) (nb := nb) hnb hperb
  constructor
  · -- the `untl` half
    intro t g e hmem
    have hcl : Formula.untl g e ∈ subformulaClosure φ := hsub t hmem
    have hex : ∃ s : ℤ, t < s ∧ e ∈ lab s := by
      by_contra hcon
      have hno : ∀ s : ℤ, t < s → e ∉ lab s := fun s h1 h2 => hcon ⟨s, h1, h2⟩
      obtain ⟨A, hAnn, hAt, hAper⟩ :
          ∃ A : ℤ, 0 ≤ A ∧ t ≤ nm + A ∧ ∀ u : ℤ, nm ≤ u → lab (u + A) = lab u := by
        refine ⟨(((t - nm).toNat : ℕ) : ℤ) * nf, ?_, ?_, fun u hu => hfw _ u hu⟩
        · exact mul_nonneg (Int.natCast_nonneg _) (le_of_lt hnf)
        · have h1 : (((t - nm).toNat : ℕ) : ℤ) ≤ (((t - nm).toNat : ℕ) : ℤ) * nf :=
            le_mul_of_one_le_right (Int.natCast_nonneg _) (by omega)
          omega
      obtain ⟨hcarry, -⟩ :=
        untl_propagates_to_end hco hcl hmem (nm + A) hAt (fun s h1 _ => hno s h1)
      rw [hAper nm (le_refl nm)] at hcarry
      obtain ⟨s₀, hs₀1, hs₀2, hs₀3⟩ := hgoodf g e hcarry
      refine hno (s₀ + A) (by omega) ?_
      rw [hAper s₀ (by omega)]
      exact hs₀3
    obtain ⟨s, ⟨hts, hes⟩, hmin⟩ :=
      Int.exists_least_of_bdd (P := fun z => t < z ∧ e ∈ lab z)
        ⟨t, fun z hz => le_of_lt hz.1⟩ (by obtain ⟨s, h1, h2⟩ := hex; exact ⟨s, h1, h2⟩)
    refine ⟨s, hts, hes, fun r hr1 hr2 => ?_⟩
    obtain ⟨-, hguard⟩ :=
      untl_propagates_to_end hco hcl hmem (s - 1) (by omega)
        (fun z h1 h2 hz => by have := hmin z ⟨h1, hz⟩; omega)
    exact hguard r hr1 (by omega)
  · -- the `snce` half
    intro t g e hmem
    have hcl : Formula.snce g e ∈ subformulaClosure φ := hsub t hmem
    have hex : ∃ s : ℤ, s < t ∧ e ∈ lab s := by
      by_contra hcon
      have hno : ∀ s : ℤ, s < t → e ∉ lab s := fun s h1 h2 => hcon ⟨s, h1, h2⟩
      obtain ⟨A, hAnn, hAt, hAper⟩ :
          ∃ A : ℤ, 0 ≤ A ∧ -1 - A ≤ t ∧ ∀ u : ℤ, u < 0 → lab (u - A) = lab u := by
        refine ⟨(((-1 - t).toNat : ℕ) : ℤ) * nb, ?_, ?_, fun u hu => hbw _ u hu⟩
        · exact mul_nonneg (Int.natCast_nonneg _) (le_of_lt hnb)
        · have h1 : (((-1 - t).toNat : ℕ) : ℤ) ≤ (((-1 - t).toNat : ℕ) : ℤ) * nb :=
            le_mul_of_one_le_right (Int.natCast_nonneg _) (by omega)
          omega
      obtain ⟨hcarry, -⟩ :=
        snce_propagates_to_start hco hcl hmem (-1 - A) hAt (fun s _ h2 => hno s h2)
      rw [hAper (-1) (by omega)] at hcarry
      obtain ⟨s₀, hs₀1, hs₀2, hs₀3⟩ := hgoodb g e hcarry
      refine hno (s₀ - A) (by omega) ?_
      rw [hAper s₀ (by omega)]
      exact hs₀3
    obtain ⟨s, ⟨hst, hes⟩, hmax⟩ :=
      Int.exists_greatest_of_bdd (P := fun z => z < t ∧ e ∈ lab z)
        ⟨t, fun z hz => le_of_lt hz.1⟩ (by obtain ⟨s, h1, h2⟩ := hex; exact ⟨s, h1, h2⟩)
    refine ⟨s, hst, hes, fun r hr1 hr2 => ?_⟩
    obtain ⟨-, hguard⟩ :=
      snce_propagates_to_start hco hcl hmem (s + 1) (by omega)
        (fun z h1 h2 hz => by have := hmax z ⟨h2, hz⟩; omega)
    exact hguard r (by omega) hr2

end FormalSystem.Metalogic.Decidability
