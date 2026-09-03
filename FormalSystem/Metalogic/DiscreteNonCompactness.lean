/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.StrongCompleteness

/-!
# Non-compactness of the `FrameClass.Discrete` consequence relation

This module discharges the informal argument recorded in `Metalogic/StrongCompleteness.lean`'s
module docstring: the set-based semantic consequence relation for `FrameClass.Discrete` is **not
compact**, so genuine strong completeness is unavailable for that class.

## The witness

Fix an atom `p`. The premise set is

  `archWitness p = {F p} ∪ {¬Xⁿ p : n ∈ ℕ}`

where `X φ = Formula.next φ = Formula.untl Formula.bot φ` is the next-step operator (the `untl`
constructor is **guard-first**: `next φ` is `untl (guard := ⊥) (event := φ)`).

* **Every finite subset is satisfiable.** A finite list `L` of members mentions only finitely
  many `Xⁿ`, so a threshold `N` bounds them all; over `ℤ` place `p` strictly beyond `N` and
  evaluate at `0`. Then `F p` holds (the witness sits at `N + 1`) and every `¬Xⁿ p` in `L` holds
  because `n ≤ N`.
* **The whole set is unsatisfiable.** Over any Archimedean discrete carrier, an `F p` witness
  `s > t` is reachable from `t` in finitely many successor steps — this is exactly where
  `IsSuccArchimedean` does its work — so `Xⁿ⁺¹ p` holds at `t` for that `n`, contradicting the
  corresponding `¬Xⁿ⁺¹ p`.

Together these refute `CompactDiscrete` (`discrete_consequence_not_compact`) and, by way of
`soundness_discrete`, `StrongCompletenessDiscrete` itself
(`strongCompletenessDiscrete_refuted`). Both statements are declared in
`Metalogic/SetConsequence.lean`.

## Note on `truthAt_next_iff` / `truthAt_next_iterate`

These two lemmas are pure semantics with no completeness content, and are the first semantic
characterisation of `Formula.next` anywhere in this development. Their natural eventual home is
the `Truth` namespace of `FormalSystem/Semantics/Truth.lean`, beside `some_future_iff`,
`future_iff` and `past_iff`; the needed `SuccOrder`/`NoMaxOrder` are already in scope there. They
are kept here for now because `Truth.lean` sits near the root of the import graph and this module
is their only consumer — promotion is the right move once a second consumer appears.

They are deliberately **not** `@[simp]`: were they promoted upstream, a simp-normal `next`
rewrite would fire inside the proof-theoretic reasoning in `Theorems/DiscreteUnfolding.lean`.
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

variable {F : TaskFrame}

/-! ## The next-step truth lemmas -/

/-- **Semantic characterisation of `Formula.next`.** On a discrete order with no maximum,
    `X φ` holds at `t` exactly when `φ` holds at `Order.succ t`.

    Unfolding the `untl` clause of `TruthAt`, `TruthAt t (next φ)` reads
    `∃ s > t, φ(s) ∧ ∀ r ∈ (t, s), ⊥` — the empty-gap condition forces `s = Order.succ t`. -/
theorem truthAt_next_iff [SuccOrder F.Duration] [NoMaxOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.next φ) ↔ TruthAt M τ (Order.succ t) φ := by
  constructor
  · rintro ⟨s, hts, hs, hgap⟩
    have h1 : Order.succ t ≤ s := Order.succ_le_of_lt hts
    rcases lt_or_eq_of_le h1 with h | h
    · exact absurd (hgap (Order.succ t) (Order.lt_succ t) h) not_false
    · exact h ▸ hs
  · intro h
    exact ⟨Order.succ t, Order.lt_succ t, h, fun r hr hrs =>
      absurd hr (not_lt.mpr (Order.le_of_lt_succ hrs))⟩

/-- Iterated form of `truthAt_next_iff`: `Xⁿ φ` at `t` is `φ` at the `n`-th successor of `t`. -/
theorem truthAt_next_iterate [SuccOrder F.Duration] [NoMaxOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) :
    ∀ (n : ℕ) (t : F.Duration) (φ : Formula),
      TruthAt M τ t (Formula.next^[n] φ) ↔ TruthAt M τ (Order.succ^[n] t) φ := by
  intro n
  induction n with
  | zero => intro t φ; simp
  | succ k ih =>
    intro t φ
    -- The two rewrites are asymmetric on purpose: unprimed peels the *outermost* `next` off the
    -- formula side, primed peels the *innermost* `succ` off the time side. Using the same
    -- orientation on both sides leaves a type mismatch at the `exact`.
    rw [Function.iterate_succ_apply, ih, Function.iterate_succ_apply']
    exact truthAt_next_iff M τ _ φ

/-! ## The witness set and its index function -/

/-- The non-compactness witness set for the atom `p`:

      `{F p} ∪ {¬Xⁿ p : n ∈ ℕ}`

    Every finite subset is satisfiable over `ℤ` (`archWitness_finitely_satisfiable`); the whole
    set is satisfiable over no Archimedean discrete carrier (`archWitness_not_satisfiable`). -/
def archWitness (p : Atom) : Set Formula :=
  {(Formula.atom p).someFuture} ∪ {ψ | ∃ n : ℕ, ψ = (Formula.next^[n] (Formula.atom p)).neg}

/-- **Membership in `archWitness`, unfolded once and for all.** The set is a singleton unioned
with a `setOf`, so every membership goal against it used to be discharged by the same
`simp only [archWitness, Set.mem_union, Set.mem_singleton_iff, Set.mem_setOf_eq]` incantation,
written out at each site. Tagging the unfolding `@[simp]` retires the incantation: a plain
`simp` now both introduces and eliminates membership. The Dedekind module carries the
corresponding `mem_dedWitness_iff`. -/
@[simp] theorem mem_archWitness_iff {p : Atom} {ψ : Formula} :
    ψ ∈ archWitness p ↔ ψ = (Formula.atom p).someFuture ∨
      ∃ n : ℕ, ψ = (Formula.next^[n] (Formula.atom p)).neg := by
  simp only [archWitness, Set.mem_union, Set.mem_singleton_iff, Set.mem_setOf_eq]

/-- Number of leading `Formula.next` layers of a formula.

    The first equation matches `Formula.untl Formula.bot φ` — **guard-first**, matching
    `Formula.next`'s definition (`Syntax/Formula.lean`). Written with the arguments swapped it
    would silently never fire and the function would be constantly `0`. -/
def nextDepth : Formula → ℕ
  | Formula.untl Formula.bot φ => nextDepth φ + 1
  | _ => 0

/-- The index `n` recovered from a witness element `¬Xⁿ p` (which is `Formula.imp (Xⁿ p) ⊥`).

    **Why this exists.** `archWitness_finitely_satisfiable` receives an arbitrary
    `L : List Formula` whose members lie in `archWitness p`, and must produce a *single*
    threshold beyond which to place `p`. Membership only supplies `∃ n, ψ = ¬Xⁿ p` element by
    element; `witIdx` turns that existential into a computable index, so the threshold can be
    taken as a sum (hence an upper bound) over `L`.

    `Formula.complexity` (`Syntax/Formula.lean`) is **not** usable for this. It is pattern-aware
    — it special-cases the `always` / `sometimes` / `weakFuture` / `weakPast` expansions and
    charges them overhead — so it is not a monotone structural size and yields no usable bound. -/
def witIdx : Formula → ℕ
  | Formula.imp χ Formula.bot => nextDepth χ
  | _ => 0

theorem nextDepth_next_iterate (p : Atom) (n : ℕ) :
    nextDepth (Formula.next^[n] (Formula.atom p)) = n := by
  induction n with
  | zero => simp [nextDepth]
  | succ k ih => rw [Function.iterate_succ_apply']; simp [Formula.next, nextDepth, ih]

theorem witIdx_neg_next_iterate (p : Atom) (n : ℕ) :
    witIdx ((Formula.next^[n] (Formula.atom p)).neg) = n := by
  simp [Formula.neg, witIdx, nextDepth_next_iterate]

/-! ## The `ℤ` model witnessing finite satisfiability

`FrameOver.natFrame` (`Semantics/TaskFrame.lean`) is the right frame off the shelf: its relation
`TaskRel w d u := d ≠ 0 ∨ w = u` is permissive, so an **arbitrary** state function respects it —
which is exactly what the non-constant history below needs. `WorldHistory.universalNatFrame` is
constant-state and so cannot separate the times; `staticFrame` is worse still, its relation
forcing constant histories outright.
-/

/-- The history over `ℤ` whose world-state flips from `0` to `1` strictly after `N`. -/
def zHistory (N : ℤ) : WorldHistory (FrameOver.natFrame (D := ℤ)) where
  domain := fun _ => True
  nonempty_domain := ⟨0, True.intro⟩
  convex := fun _ _ _ _ _ _ _ => True.intro
  -- `FrameOver.natFrame.WorldState` does not reduce far enough for numeral elaboration, so the
  -- `ite` *body* carries the ascription. Ascribing an existing fvar instead does not work.
  states := fun t _ => (if N < t then 1 else 0 : Nat)
  respects_task := by
    intro s t _ _
    rcases eq_or_ne t s with rfl | hne
    · right; rfl
    · left; exact sub_ne_zero.mpr hne

/-- The model over `natFrame` whose only true atom-condition is "the world-state is `1`".

    The **lambda binder** carries the `Nat` annotation; `fun w _ => (w : Nat) = 1` does not
    elaborate, since ascribing an existing fvar does not retarget numeral elaboration. -/
def zModel : TaskModel (FrameOver.natFrame (D := ℤ)) where
  valuation := fun (w : Nat) _ => w = 1

theorem zHistory_total (N : ℤ) : (zHistory N).IsTotal := fun _ => True.intro

@[simp] theorem zTruth_atom (N : ℤ) (p : Atom) (t : ℤ) :
    TruthAt zModel (zHistory N) t (Formula.atom p) ↔ N < t := by
  constructor
  · rintro ⟨_, h⟩
    simp only [zModel, zHistory] at h
    by_contra hc
    simp [hc] at h
  · intro h
    exact ⟨True.intro, by simp only [zModel, zHistory]; simp [h]⟩

theorem succ_iterate_zero_int (n : ℕ) : Order.succ^[n] (0:ℤ) = (n : ℤ) := by
  induction n with
  | zero => simp
  | succ k ih => rw [Function.iterate_succ_apply', ih]; simp [Order.succ_eq_add_one]

/-! ## The three acceptance theorems -/

/-- **Every finite subset of `archWitness p` is satisfiable.** Over `ℤ`, place `p` strictly
    beyond `N = (L.map witIdx).sum` — an upper bound for every index occurring in `L` — and
    evaluate at `0`.

    `List.single_le_sum (fun _ _ => Nat.zero_le _)` supplies `witIdx ψ ≤ N` directly; no `foldr
    max` helper and no auxiliary lemma is needed. -/
theorem archWitness_finitely_satisfiable (p : Atom) (L : List Formula)
    (hL : ∀ ψ ∈ L, ψ ∈ archWitness p) : SatisfiableDiscreteSet {ψ | ψ ∈ L} := by
  classical
  refine SatisfiableSet.of_forall (fc := FrameClass.Discrete) (FrameOver.natFrame (D := ℤ))
    (TaskFrame.isSuccArchDiscrete_of_instances _) zModel
    (zHistory ((L.map witIdx).sum : ℕ)) (zHistory_total _) 0 ?_
  set N : ℕ := (L.map witIdx).sum with hNdef
  intro ψ hψ
  have hmem := hL ψ hψ
  simp only [mem_archWitness_iff] at hmem
  rcases hmem with rfl | ⟨n, rfl⟩
  · -- `F p` : place the witness at `N + 1`
    refine ⟨(N : ℤ) + 1, by positivity, ?_, fun r _ _ => id⟩
    exact (zTruth_atom _ p _).mpr (by omega)
  · -- `¬ Xⁿ p`, with `n ≤ N`
    have hn_le : n ≤ N := by
      have : witIdx ((Formula.next^[n] (Formula.atom p)).neg) ∈ L.map witIdx :=
        List.mem_map_of_mem hψ
      have hle := List.single_le_sum (fun _ _ => Nat.zero_le _) _ this
      rwa [witIdx_neg_next_iterate] at hle
    intro hcon
    have := (truthAt_next_iterate zModel (zHistory (N:ℤ)) n 0 (Formula.atom p)).mp hcon
    rw [succ_iterate_zero_int] at this
    have := (zTruth_atom _ p _).mp this
    omega

/-- **`archWitness p` is satisfiable over no Archimedean discrete carrier.** The `F p` witness
    `s > t` is reachable from `t` in finitely many successor steps — this is exactly where
    `IsSuccArchimedean` does its work, via
    `(Order.succ_le_of_lt hts).exists_succ_iterate`, the idiom already used throughout
    `SoundnessLemmas/FrameClassVariants.lean`. That contradicts the corresponding `¬Xⁿ⁺¹ p`.

    The existential is destructured with **bare `_` instance binders** so that synthesis recovers
    the originals. Naming them and re-installing with `haveI` would drop the value and break
    definitional equality with the instances baked into `F`'s and `M`'s types. -/
theorem archWitness_not_satisfiable (p : Atom) : ¬ SatisfiableDiscreteSet (archWitness p) := by
  rintro ⟨F, ⟨_, _, _, _⟩, M, τ, hτ, t, h⟩
  haveI : NoMaxOrder F.Duration := inferInstance
  have hF : TruthAt M τ t ((Formula.atom p).someFuture) := by
    apply h; simp
  obtain ⟨s, hts, hs, -⟩ := hF
  obtain ⟨n, hn⟩ := (Order.succ_le_of_lt hts).exists_succ_iterate
  have hs' : TruthAt M τ (Order.succ^[n + 1] t) (Formula.atom p) := by
    rw [Function.iterate_succ_apply, hn]; exact hs
  have hX : TruthAt M τ t (Formula.next^[n + 1] (Formula.atom p)) :=
    (truthAt_next_iterate M τ (n + 1) t _).mpr hs'
  have hneg : TruthAt M τ t ((Formula.next^[n+1] (Formula.atom p)).neg) := by
    -- Not `simp`: it rewrites `next^[n+1] φ` to `next^[n] φ.next` inside the goal *and* under
    -- the existential binder in a way that leaves the two sides unmatched, so the witness must
    -- be supplied by hand here. `mem_archWitness_iff` still supplies the unfolding.
    exact h _ (mem_archWitness_iff.mpr (Or.inr ⟨n + 1, rfl⟩))
  exact hneg hX

/-- **The `FrameClass.Discrete` consequence relation is not compact.**

`not_compact_of_witness` (`Metalogic/StrongCompleteness.lean`) at `archWitness ⟨"p", none⟩`. The
two halves it consumes are the two acceptance theorems directly above: `archWitness` is finitely
satisfiable over `ℤ`, and satisfiable over no Archimedean discrete carrier at all.

The argument the skeleton runs — `archWitness p ⊨ ⊥` holds vacuously, compactness hands back a
finite `L` with `L.foldr imp ⊥` Discrete-valid, and `truthAt_foldr_imp` contradicts that against
a Discrete model of the same `L` — used to be written out here in full, and again in
`Metalogic/DedekindNonCompactness.lean` with a different witness. It is now written once. -/
theorem discrete_consequence_not_compact : ¬ CompactDiscrete :=
  not_compact_of_witness (archWitness_finitely_satisfiable ⟨"p", none⟩)
    (archWitness_not_satisfiable ⟨"p", none⟩)

/-! ## Strong completeness for `FrameClass.Discrete` is refuted -/

/-- **Strong completeness fails for `FrameClass.Discrete`.**

`not_strongCompleteness_of_witness` at the same witness, on the same two acceptance theorems.

**This proof no longer mentions `soundness_discrete`.** The skeleton routes through
`compact_of_strongCompleteness`, whose soundness step is the class-generic `soundness_validIn`;
the per-class soundness corollary is no longer on the refutation path. With it went the
bare-instance-binder `rintro ⟨F, ⟨_,_,_,_⟩, M, τ, hτ, t, hsat⟩` discipline this proof used to
need, since it no longer destructures a `SatisfiableDiscreteSet` witness itself —
`archWitness_not_satisfiable` above still does, and still documents the discipline.

This is the theorem behind the module docstring claim in `Metalogic/StrongCompleteness.lean`
that only weak completeness is available for this class. -/
theorem strongCompletenessDiscrete_refuted : ¬ StrongCompletenessDiscrete :=
  not_strongCompleteness_of_witness (archWitness_finitely_satisfiable ⟨"p", none⟩)
    (archWitness_not_satisfiable ⟨"p", none⟩)

#print axioms truthAt_next_iff
#print axioms truthAt_next_iterate
#print axioms archWitness_finitely_satisfiable
#print axioms archWitness_not_satisfiable
#print axioms discrete_consequence_not_compact
#print axioms strongCompletenessDiscrete_refuted

/-! ## Axiom Audit

```
#print axioms truthAt_next_iff
-- depends on: [propext, Classical.choice, Quot.sound]
#print axioms truthAt_next_iterate
-- depends on: [propext, Classical.choice, Quot.sound]
#print axioms archWitness_finitely_satisfiable
-- depends on: [propext, Classical.choice, Quot.sound]
#print axioms archWitness_not_satisfiable
-- depends on: [propext, Classical.choice, Quot.sound]
#print axioms discrete_consequence_not_compact
-- depends on: [propext, Classical.choice, Quot.sound]
#print axioms strongCompletenessDiscrete_refuted
-- depends on: [propext, Classical.choice, Quot.sound]
```

**`sorryAx`-free throughout.** Every declaration in this module carries exactly the three
standard classical axioms, the identical set already carried by `completeness_dense`,
`completeness_discrete` and `consequence_completeness_dedekind`. No new axiom is introduced and
no obligation is deferred.

### Axiom classification

* `propext` — propositional extensionality, entering through `simp`/`omega` normalisation.
* `Classical.choice` — via the `classical` tactic and Mathlib's order-theoretic lemmas
  (`Order.succ_le_of_lt`, `IsSuccArchimedean.exists_succ_iterate`).
* `Quot.sound` — quotient soundness, entering through Mathlib's `List` and `Int` API.

None of the three is avoidable in this development, and none is specific to this module.
-/

end FormalSystem.Metalogic
