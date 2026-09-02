/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.StrongCompleteness
import FormalSystem.Semantics.ShiftSet

/-!
# Non-compactness of the `FrameClass.Dedekind` consequence relation

The Dedekind sibling of `Metalogic/DiscreteNonCompactness.lean`: the set-based semantic
consequence relation for `FrameClass.Dedekind` is **not compact**, so genuine strong
completeness is unavailable for that class too. This settles the fourth and last row of the
`FrameClass` table, whose statements are named in `Metalogic/SetConsequence.lean`
(`CompactDedekind`, `StrongCompletenessDedekind`, `SatisfiableDedekindSet`).

## Why `archWitness` does not port

`DiscreteNonCompactness.lean`'s witness `archWitness p = {F p} ∪ {¬Xⁿ p : n ∈ ℕ}` is built from
`Formula.next φ = Formula.untl ⊥ φ`, and its unsatisfiability half turns on `[SuccOrder]` plus
`[IsSuccArchimedean]`: an `F p` witness `s > t` is reached from `t` in finitely many successor
steps.

Neither half survives here, and the failure is not a matter of finding a different proof. On a
densely ordered carrier `TruthAt M τ t (Formula.next φ)` asks for an `s > t` with nothing
strictly between `t` and `s`; density supplies such a point for no `t` at all, so `Xⁿ p` is
vacuously false everywhere and the witness degenerates. Nor can the `[SuccOrder]` route be
restored: a densely ordered type with no maximum admits no `SuccOrder`. A genuinely new witness
is therefore required, and only the *file shape* of the Discrete module — finitely-satisfiable
half, then unsatisfiable half — carries over.

## The witness

Fix an atom `q`, and abbreviate `Xq φ = untl ¬q (q ∧ φ)` (`qNext`): "at the next `q`-point,
`φ`". The premise set (`dedWitness`) is

  `{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤ : n ∈ ℕ}`

whose three parts read:

* `qGap q = G(⊤ S ¬q)` — every future point has a non-`q` point immediately before it, i.e. the
  `q`-points are *isolated from below*. This is what a supremum of `q`-points cannot satisfy.
* `qBound q = F(G ¬q)` — the `q`-points are bounded above.
* `qAlpha q n = Xqⁿ⊤` — there is a chain of at least `n` successive `q`-points into the future.

**Why the `{αₙ}` family is infinite, and load-bearing.** The single formula `G(q → F q)` ("every
`q`-point has a later one") would make `{F q, G(q → F q), F(G ¬q), G(⊤ S ¬q)}` unsatisfiable
over Dedekind-complete frames in four formulas. That set is *useless for a compactness
refutation*: it is finite, and compactness may simply hand back the whole of it. Replacing that
one formula with the ω-family of finite chain assertions `{αₙ}` is exactly what makes every
*finite* subset Dedekind-satisfiable while the whole set is not. This is the design decision
most easily lost on re-derivation.

The `Formula.and` inside `qNext` is likewise necessary: weakening `Xq φ` to `untl ¬q φ` lets the
intermediate witness point be a non-`q`-point, so `α₂` collapses to `α₁` and nested untils stop
counting.

## The two halves

* **Every finite subset is satisfiable** (`dedWitness_finitely_satisfiable`). A finite list `L`
  mentions only finitely many `αₙ`, so `N = (L.map qDepth).sum` bounds every index appearing in
  it. Over `ℝ` — built as a `ShiftSet` (`rShift`) — put `q` true exactly at the integers
  `1, …, N` and evaluate at `0`. Then `qGap` holds (integers are isolated), `qBound` holds (`q`
  fails above `N + 1`), and `αₙ` holds for every `n ≤ N` (walk `0 → 1 → ⋯ → n`).
* **The whole set is unsatisfiable** (`dedWitness_core`, `dedWitness_not_satisfiable`). The
  `αₙ` family lets one build a strictly increasing sequence of `q`-points; `qBound` bounds it;
  Dedekind completeness supplies a supremum `z`; and `qGap` at `z` demands a non-`q` interval
  immediately below `z`, which the sequence's own points violate.

**Generality of the unsatisfiable half.** `dedWitness_core` takes `hlub : F.IsComplete` and no
density binder at all: density is never used. So the witness is unsatisfiable over *every*
Dedekind-complete frame, `ℤ` included — the headline `dedWitness_not_satisfiable` merely states
that general fact at `SatisfiableDedekindSet`, where the compactness refutation consumes it.
Density is needed only for the *finite*-satisfiability half, and only because
`FrameClass.Dedekind` requires it of the witnessing frame.

Together these refute `CompactDedekind` (`dedekind_consequence_not_compact`) and, by way of
`soundness_dedekind`, `StrongCompletenessDedekind` itself
(`strongCompletenessDedekind_refuted`).

**No conflict with `compactDense`.** `Metalogic/Compactness.lean` proves compactness for
`FrameClass.Dense`, which forces `dedWitness q` to be satisfiable over *some* dense frame. That
frame is necessarily gappy — think `q` true at a sequence of rationals increasing to an
irrational — which is consistent precisely because the argument above exploits completeness, not
density.

## Relation to Reynolds 1992

Reynolds 1992 §9 Theorem 7 is a *weak* completeness result for this class and remains correctly
cited as such. This module does not contradict it; it explains why only the weak form is
available.
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

/-! ## The witness vocabulary -/

/-- `Xq φ` — "at the next `q`-point, `φ`": `untl` with guard `¬q` and event `q ∧ φ`. The `untl`
constructor is **guard-first**, so this is `untl (guard := ¬q) (event := q ∧ φ)`.

The `q ∧ _` conjunct is not decoration. Dropping it — using `untl ¬q φ` — lets the intermediate
witness point be a non-`q`-point, and then `qAlpha q 2` collapses into `qAlpha q 1`: nested
applications stop counting `q`-points. -/
def qNext (q : Atom) (φ : Formula) : Formula :=
  Formula.untl (Formula.atom q).neg (Formula.and (Formula.atom q) φ)

/-- `αₙ = Xqⁿ⊤` — "there is a chain of at least `n` successive `q`-points into the future".
The ω-family `{αₙ : n ∈ ℕ}` is the load-bearing part of the witness: see the module docstring on
why a single `G(q → F q)` will not do. -/
def qAlpha (q : Atom) (n : ℕ) : Formula := (qNext q)^[n] Formula.top

/-- `G(⊤ S ¬q)` — every future point is immediately preceded by a `¬q` interval, i.e. the
`q`-points are isolated from below. This is the clause a supremum of `q`-points cannot
satisfy. -/
def qGap (q : Atom) : Formula := (Formula.snce (Formula.atom q).neg Formula.top).allFuture

/-- `F(G ¬q)` — the `q`-points are bounded above. -/
def qBound (q : Atom) : Formula := ((Formula.atom q).neg.allFuture).someFuture

/-- The non-compactness witness for `FrameClass.Dedekind`:
`{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤ : n ∈ ℕ}`. Finitely satisfiable over `ℝ`
(`dedWitness_finitely_satisfiable`), unsatisfiable over every Dedekind-complete frame
(`dedWitness_core`). -/
def dedWitness (q : Atom) : Set Formula :=
  {qGap q, qBound q} ∪ {ψ | ∃ n : ℕ, ψ = qAlpha q n}

/-- Structural depth of nested `qNext` applications, used to bound the indices appearing in a
finite sublist of `dedWitness`. The pattern is the `imp`-normal form of
`untl _ (q ∧ φ)` — `Formula.and A B` unfolds to `imp (imp A (imp B bot)) bot` — which is why the
match looks the way it does. Mirrors `nextDepth` in `Metalogic/DiscreteNonCompactness.lean`. -/
def qDepth : Formula → ℕ
  | Formula.untl _ (Formula.imp (Formula.imp _ (Formula.imp φ Formula.bot)) Formula.bot) =>
      qDepth φ + 1
  | _ => 0

/-- `qDepth` reads back the index of an `αₙ`: the extractor the finite-satisfiability bound
needs. -/
theorem qDepth_qAlpha (q : Atom) (n : ℕ) : qDepth (qAlpha q n) = n := by
  induction n with
  | zero => simp [qAlpha, qDepth, Formula.top]
  | succ k ih =>
      rw [qAlpha, Function.iterate_succ_apply']
      simp only [qNext, Formula.and, Formula.neg, qDepth]
      exact congrArg (· + 1) ih

variable {F : TaskFrame}

/-! ## Semantic characterisation of the witness formulas -/

/-- Unfolding lemma for `Formula.and`. `Semantics/Truth.lean` supplies none, and an identical
`truth_and_iff` exists at `Semantics/Correspondence/DurationFrames.lean:299`; importing that
module here would be legal but would widen this file's import closure for three lines, so the
local copy is kept deliberately. -/
theorem truth_and_iff' (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (A B : Formula) :
    TruthAt M τ t (A.and B) ↔ (TruthAt M τ t A ∧ TruthAt M τ t B) := by
  constructor
  · intro h; by_contra hn; exact h fun ha hb => hn ⟨ha, hb⟩
  · rintro ⟨ha, hb⟩ h; exact h ha hb

/-- `Xq φ` holds at `t` exactly when some later point `s` is a `q`-point satisfying `φ` with no
`q`-point strictly between `t` and `s` — i.e. `s` is *the next* `q`-point. The uniqueness this
gap clause provides is what the chain construction in `dedWitness_core` runs on. -/
theorem truthAt_qNext_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (q : Atom) (φ : Formula) :
    TruthAt M τ t (qNext q φ) ↔ ∃ s, t < s ∧ TruthAt M τ s (Formula.atom q) ∧
      TruthAt M τ s φ ∧ ∀ r, t < r → r < s → ¬ TruthAt M τ r (Formula.atom q) := by
  constructor
  · rintro ⟨s, hts, hs, hgap⟩
    obtain ⟨h1, h2⟩ := (truth_and_iff' M τ s _ _).mp hs
    exact ⟨s, hts, h1, h2, fun r h1' h2' hq => hgap r h1' h2' hq⟩
  · rintro ⟨s, hts, hq, hφ, hgap⟩
    exact ⟨s, hts, (truth_and_iff' M τ s _ _).mpr ⟨hq, hφ⟩, fun r h1 h2 hqr => hgap r h1 h2 hqr⟩

/-- `qGap q` at `t`: every later `s` has a `¬q` interval `(u, s)` immediately below it. -/
theorem truthAt_qGap (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (q : Atom)
    (h : TruthAt M τ t (qGap q)) :
    ∀ s, t < s → ∃ u, u < s ∧ ∀ r, u < r → r < s → ¬ TruthAt M τ r (Formula.atom q) := by
  intro s hts
  obtain ⟨u, hus, _, hgap⟩ := (Truth.future_iff _).mp h s hts
  exact ⟨u, hus, fun r h1 h2 hq => hgap r h1 h2 hq⟩

/-- `qBound q` at `t`: some later `x` has no `q`-point above it. -/
theorem truthAt_qBound (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (q : Atom)
    (h : TruthAt M τ t (qBound q)) :
    ∃ x, t < x ∧ ∀ y, x < y → ¬ TruthAt M τ y (Formula.atom q) := by
  obtain ⟨x, htx, hx⟩ := (Truth.some_future_iff _).mp h
  exact ⟨x, htx, fun y hy hq => (Truth.future_iff _).mp hx y hy hq⟩

/-! ## Unsatisfiability: only Dedekind completeness is used

`TaskFrame.IsComplete` is `∀ s, s.Nonempty → BddAbove s → ∃ x, IsLUB s x` on the nose
(`Semantics/FrameProperty.lean`), so the named binder below and its unfolded form are the same
hypothesis; the `example` records that. -/

private example (F : TaskFrame) :
    F.IsComplete = (∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) := rfl

/-- **The witness has no model over any Dedekind-complete frame.** Stated at
`TaskFrame.IsComplete` with **no density binder**: density is never invoked, so this covers `ℤ`
as well as `ℝ`-like carriers, and `FrameClass.Dedekind`'s density requirement plays no part
here.

The argument. `qAlpha q (n+1)` at `a` supplies *the* next `q`-point `s > a`, and — by the
trichotomy step `hss`, which uses the gap clauses of two `qNext` unfoldings against each other —
that same `s` satisfies every `qAlpha q n`. So the invariant "satisfies every `αₙ`" propagates
along a chain `ch : ℕ → F.Duration` of strictly increasing `q`-points. `qBound` bounds that
chain, completeness supplies a least upper bound `z`, and `qGap` at `z` demands a `¬q` interval
`(u, z)`; but `z` is a *least* upper bound, so some `ch n` lies in `(u, z]`, and `ch n ≠ z`
because `ch (n+1) ≤ z` is strictly above it. That `ch n` is a `q`-point in the interval the gap
clause forbids. -/
theorem dedWitness_core (q : Atom) (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (hlub : F.IsComplete)
    (h : ∀ ψ ∈ dedWitness q, TruthAt M τ t ψ) : False := by
  classical
  have hgap := truthAt_qGap M τ t q (h _ (by simp [dedWitness]))
  obtain ⟨x, htx, hx⟩ := truthAt_qBound M τ t q (h _ (by simp [dedWitness]))
  have halpha : ∀ n, TruthAt M τ t (qAlpha q n) := fun n => h _ (by right; exact ⟨n, rfl⟩)
  have step : ∀ a : F.Duration, (∀ n, TruthAt M τ a (qAlpha q n)) →
      ∃ s, a < s ∧ TruthAt M τ s (Formula.atom q) ∧ (∀ n, TruthAt M τ s (qAlpha q n)) := by
    intro a ha
    have h1 : TruthAt M τ a (qNext q (qAlpha q 0)) := by
      have := ha 1; rwa [qAlpha, Function.iterate_succ_apply'] at this
    obtain ⟨s, hs1, hs2, -, hs4⟩ := (truthAt_qNext_iff M τ a q _).mp h1
    refine ⟨s, hs1, hs2, ?_⟩
    intro n
    have hn : TruthAt M τ a (qNext q (qAlpha q n)) := by
      have := ha (n+1); rwa [qAlpha, Function.iterate_succ_apply'] at this
    obtain ⟨s', hs1', hs2', hs3', hs4'⟩ := (truthAt_qNext_iff M τ a q _).mp hn
    have hss : s' = s := by
      rcases lt_trichotomy s' s with hlt | heq | hgt
      · exact absurd hs2' (hs4 s' hs1' hlt)
      · exact heq
      · exact absurd hs2 (hs4' s hs1 hgt)
    exact hss ▸ hs3'
  set Inv : F.Duration → Prop := fun a => ∀ n, TruthAt M τ a (qAlpha q n) with hInv
  let f : {a : F.Duration // Inv a} → {a : F.Duration // Inv a} := fun a =>
    ⟨(step a.1 a.2).choose, (step a.1 a.2).choose_spec.2.2⟩
  let c : ℕ → {a : F.Duration // Inv a} := fun n => f^[n] ⟨t, halpha⟩
  have hc : ∀ n, (c n).1 < (c (n+1)).1 ∧ TruthAt M τ (c (n+1)).1 (Formula.atom q) := by
    intro n
    have hcc : c (n+1) = f (c n) := by simp only [c, Function.iterate_succ_apply']
    rw [hcc]
    exact ⟨(step (c n).1 (c n).2).choose_spec.1, (step (c n).1 (c n).2).choose_spec.2.1⟩
  set ch : ℕ → F.Duration := fun n => (c (n+1)).1 with hch
  have hmono : StrictMono ch := strictMono_nat_of_lt_succ (fun n => (hc (n+1)).1)
  have hQ : ∀ n, TruthAt M τ (ch n) (Formula.atom q) := fun n => (hc n).2
  have hbdd : BddAbove (Set.range ch) := by
    refine ⟨x, ?_⟩
    rintro y ⟨n, rfl⟩
    by_contra hlt
    exact hx (ch n) (lt_of_not_ge hlt) (hQ n)
  obtain ⟨z, hz⟩ := hlub (Set.range ch) ⟨ch 0, ⟨0, rfl⟩⟩ hbdd
  have htz : t < z := lt_of_lt_of_le (hc 0).1 (hz.1 ⟨0, rfl⟩)
  obtain ⟨u, huz, hu⟩ := hgap z htz
  obtain ⟨y, ⟨n, rfl⟩, huy, hyz⟩ := hz.exists_between huz
  have hne : ch n ≠ z := by
    intro heq
    have hub : ch (n+1) ≤ z := hz.1 ⟨n+1, rfl⟩
    exact absurd (heq ▸ hmono (Nat.lt_succ_self n)) (not_lt.mpr hub)
  exact hu (ch n) huy (lt_of_le_of_ne hyz hne) (hQ n)

/-- **The witness is not `FrameClass.Dedekind`-satisfiable.** `dedWitness_core` at the Dedekind
class: the `Sat .Dedekind` slot is `IsDense ∧ IsComplete`, and only its second component is
used. -/
theorem dedWitness_not_satisfiable (q : Atom) :
    ¬ SatisfiableDedekindSet (dedWitness q) := by
  rintro ⟨F, ⟨-, hlub⟩, M, τ, hτ, t, h⟩
  exact dedWitness_core q M τ t hlub h

/-! ## The `ℝ` model for finite satisfiability

`natFrame` is unavailable here — it carries `[SuccOrder]` and `[NoMaxOrder]`, which `ℝ` cannot
supply — and `FrameOver.staticFrame` is unusable for a different reason: its task relation forces
constant-state histories, so no atom can change truth value along the timeline, which this
witness requires. The working route is `Semantics/ShiftSet.lean`, which discharges all of
`FrameOver`'s fields for any `D`-action.

`Mathlib.Data.Real.Basic` is **not** imported explicitly: `Semantics/ShiftSet.lean` already
pulls `Mathlib.Data.Real.*`, so the line would be redundant. -/

/-- The temporal order `ℝ`. **The `@[reducible]` is load-bearing**: without it
`DenselyOrdered (rShift q N).frame.Duration` fails to synthesize and `(0 : (rShift q N).Carrier)`
fails to elaborate. This is the same reducibility discipline `Semantics/TemporalOrder.lean`
documents for `intOrder`. -/
@[reducible] noncomputable def realOrder : TemporalOrder := ⟨ℝ⟩

/-- The shift set on `ℝ` translated by itself, with `q` true exactly at the integers `1, …, N`
and every other atom false everywhere. `@[reducible]` for the same reason as `realOrder`.

The `sep` field is the paper's *Limit* clause: given that `u` is within every positive distance
of `w`, instantiate at `x = |u - w|` — the returned `y` must be `u - w`, giving the
contradiction `|u - w| < |u - w|`. -/
@[reducible] noncomputable def rShift (q : Atom) (N : ℕ) : ShiftSet realOrder where
  Carrier := ℝ
  carrier_nonempty := ⟨0⟩
  sh := fun w d => w + d
  sh_zero := by intro w; simp
  sh_add := by intro w a b; exact add_assoc w a b
  sep := by
    intro w u h
    by_contra hne
    have hpos : (0:ℝ) < |u - w| := abs_pos.mpr (sub_ne_zero.mpr hne)
    obtain ⟨y, hy, hu⟩ := h (|u - w|) hpos
    have hy' : y = u - w := by rw [hu]; ring
    rw [hy'] at hy
    exact lt_irrefl _ hy
  A := fun p x => p = q ∧ ∃ k : ℤ, (k:ℝ) = x ∧ 1 ≤ k ∧ k ≤ (N:ℤ)

/-- The task model induced by `rShift`. -/
noncomputable def rM (q : Atom) (N : ℕ) : TaskModel (rShift q N).frame := (rShift q N).model

/-- The orbit through `0`, as a `WorldHistory`. -/
noncomputable def rH (q : Atom) (N : ℕ) : WorldHistory (rShift q N).frame := (rShift q N).hist 0

/-- Atom truth along the orbit through `0`, via `ShiftSet.forward_repr`. -/
theorem rTruth_atom (q : Atom) (N : ℕ) (t : ℝ) :
    TruthAt (rM q N) (rH q N) t (Formula.atom q) ↔ ∃ k : ℤ, (k:ℝ) = t ∧ 1 ≤ k ∧ k ≤ (N:ℤ) := by
  rw [rM, rH, ShiftSet.forward_repr]
  simp [ShiftSet.ShiftTruth]

/-- `qGap q` holds at `0` in the `ℝ` model: the `q`-points are integers, hence isolated from
below — `(⌈s⌉ - 1, s)` contains no integer for any `s`. -/
theorem rTruth_gap (q : Atom) (N : ℕ) : TruthAt (rM q N) (rH q N) 0 (qGap q) := by
  rw [qGap, Truth.future_iff]
  intro s _
  refine ⟨((⌈s⌉ : ℤ) : ℝ) - 1, by linarith [Int.ceil_lt_add_one s], id, ?_⟩
  rintro r hr hrs hq
  obtain ⟨k, rfl, -, -⟩ := (rTruth_atom q N _).mp hq
  have hr' : ((⌈s⌉ : ℤ) : ℝ) - 1 < ((k : ℤ) : ℝ) := hr
  have h1 : k < ⌈s⌉ := Int.lt_ceil.mpr hrs
  have h2 : (⌈s⌉ : ℤ) - 1 < k := by exact_mod_cast hr'
  omega

/-- `qBound q` holds at `0` in the `ℝ` model: nothing above `N + 1` is a `q`-point. -/
theorem rTruth_bound (q : Atom) (N : ℕ) : TruthAt (rM q N) (rH q N) 0 (qBound q) := by
  rw [qBound, Truth.some_future_iff]
  refine ⟨(N : ℝ) + 1, by positivity, ?_⟩
  rw [Truth.future_iff]
  intro y hy hq
  obtain ⟨k, rfl, -, hk⟩ := (rTruth_atom q N _).mp hq
  have h1 : ((k : ℤ) : ℝ) ≤ ((N : ℤ) : ℝ) := by exact_mod_cast hk
  have h2 : ((N : ℤ) : ℝ) = (N : ℝ) := by push_cast; ring
  have hy' : (N : ℝ) + 1 < ((k : ℤ) : ℝ) := hy
  rw [h2] at h1
  linarith

/-- `qAlpha q n` holds at any integer `k ≥ 0` with `k + n ≤ N`: walk `k → k+1 → ⋯ → k+n`, each
step landing on the *next* `q`-point because no integer lies strictly between consecutive
integers.

`F.Duration.carrier` is `ℝ` only up to reducible unfolding and `norm_cast` does not see through
it, so each order hypothesis is restated as an explicit `ℝ` statement before `exact_mod_cast`. -/
theorem rTruth_alpha (q : Atom) (N : ℕ) :
    ∀ (n : ℕ) (k : ℤ), 0 ≤ k → k + (n : ℤ) ≤ (N : ℤ) →
      TruthAt (rM q N) (rH q N) ((k : ℝ)) (qAlpha q n) := by
  intro n
  induction n with
  | zero => intro k _ _; exact id
  | succ m ih =>
      intro k hk hkN
      rw [qAlpha, Function.iterate_succ_apply']
      refine (truthAt_qNext_iff _ _ _ q _).mpr ⟨((k : ℝ) + 1), by linarith, ?_, ?_, ?_⟩
      · exact (rTruth_atom q N _).mpr
          ⟨k + 1, by push_cast; ring, by omega, by push_cast at hkN; omega⟩
      · have hih := ih (k + 1) (by omega) (by push_cast at hkN; omega)
        rw [show ((k + 1 : ℤ) : ℝ) = (k : ℝ) + 1 by push_cast; ring] at hih
        exact hih
      · rintro r hr hrs hq
        obtain ⟨j, rfl, -, -⟩ := (rTruth_atom q N _).mp hq
        have hr' : ((k : ℤ) : ℝ) < ((j : ℤ) : ℝ) := hr
        have hrs' : ((j : ℤ) : ℝ) < ((k : ℤ) : ℝ) + 1 := hrs
        have h1 : k < j := by exact_mod_cast hr'
        have h3 : j < k + 1 := by
          have hc : ((j : ℤ) : ℝ) < ((k + 1 : ℤ) : ℝ) := by push_cast; linarith
          exact_mod_cast hc
        omega

/-- **Every finite sublist of the witness is `FrameClass.Dedekind`-satisfiable.** The bound
`N = (L.map qDepth).sum` dominates every index `n` with `qAlpha q n ∈ L`, because `qDepth` reads
that index back off the formula (`qDepth_qAlpha`) and a single summand is at most the sum. The
model is `ℝ` with `q` at the integers `1, …, N`, evaluated at `0`.

This is the half that needs density, and it needs it only because `FrameClass.Dedekind` demands
it of the witnessing frame; the unsatisfiable half (`dedWitness_core`) uses completeness alone.

Note that a *finite* unsatisfiable set would refute nothing about compactness — compactness may
hand back the whole of any finite premise set. That is precisely why `dedWitness` carries the
infinite family `{αₙ}` rather than the single formula `G(q → F q)`. -/
theorem dedWitness_finitely_satisfiable (q : Atom) (L : List Formula)
    (hL : ∀ ψ ∈ L, ψ ∈ dedWitness q) : SatisfiableDedekindSet {ψ | ψ ∈ L} := by
  classical
  set N : ℕ := (L.map qDepth).sum with hNdef
  refine SatisfiableSet.dedekind_of_forall (rShift q N).frame
    (fun _ hne hbd => Real.exists_isLUB hne hbd) (rM q N) (rH q N)
    (ShiftSet.hist_isTotal _ _) 0 ?_
  intro ψ hψ
  have hmem := hL ψ hψ
  simp only [dedWitness, Set.mem_union, Set.mem_insert_iff, Set.mem_singleton_iff,
    Set.mem_setOf_eq] at hmem
  rcases hmem with (rfl | rfl) | ⟨n, rfl⟩
  · exact rTruth_gap q N
  · exact rTruth_bound q N
  · have hn_le : n ≤ N := by
      have hmm : qDepth (qAlpha q n) ∈ L.map qDepth := List.mem_map_of_mem hψ
      have hle := List.single_le_sum (fun _ _ => Nat.zero_le _) _ hmm
      rwa [qDepth_qAlpha] at hle
    have := rTruth_alpha q N n 0 le_rfl (by omega)
    simpa using this

end FormalSystem.Metalogic
