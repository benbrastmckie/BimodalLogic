/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Truth

-- Lower semantic layer: must not reach the proof system (G-15). `FrameClassValidity.lean`
-- is the one documented seam that imports `ProofSystem.Axioms`; nothing below it may.
assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
  FormalSystem.ProofSystem.Derivable FormalSystem.ProofSystem.FrameClass

/-!
# TruthTransport - Transporting truth between task models

This module holds the model-to-model truth-transport layer that was factored out of
`Truth.lean`, so that module reads as one subject: the `TruthAt` recursion for `Formula`,
its clause lemmas, and its immediate corollaries. Nothing here defines or refines truth for
the primary language; everything here moves a truth value from one model-history-time triple
to another.

## Main Definitions

- `TruthCorr`: the data of a truth-preserving correspondence between two task models — a
  *relation* on histories together with atomic agreement and a possible-world-lifting
  condition, which is the shape the paper’s own time-shift argument uses
- `TimeShift.ShiftRel` / `TimeShift.shiftCorr`: the time-shift correspondence on a single
  model, packaged as a `TruthCorr`
- `TruthIso`: the bijective special case of `TruthCorr`, whose times reindex by an order
  isomorphism and whose world histories reindex by an equivalence
- `TruthAntiIso`: the order-reversing twin of `TruthIso`, which transports truth along
  `Formula.swapTemporal`

## Main Results

- `Truth.truthAt_of_truthCorr`: the single `induction φ` that discharges a `TruthCorr`
- `TimeShift.timeShift_preserves_truth`: truth is invariant under a time shift of the history
  and a matching shift of the evaluation time
- `Truth.box_const` / `Truth.box_time_const`: a boxed formula’s truth value is a constant of
  the model. These live here rather than beside the other `Truth` clause lemmas because their
  proofs consume `TimeShift.timeShift_preserves_truth`.
- `Truth.truthAt_of_truthIso` / `Truth.truthAt_of_truthAntiIso`: the corresponding transport
  results for the bijective and order-reversing packagings
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax

variable {F : TaskFrame}

/-! ## Truth correspondences — the generic relational transport

`TruthCorr` is the data of a truth-preserving correspondence between two task models, and
`Truth.truthAt_of_truthCorr` is the one `induction φ` that discharges it. This is the paper's own
proof shape. `lem:history-time-shift-preservation` — its `□` case in particular — never uses a
bijection between histories: it uses a *relation* between them (`def:time-shift-histories`),
atomic agreement on related pairs, and the existence of a related possible world in each
direction (`app:auto_existence`). `TruthCorr` asks for exactly those three things and nothing
more.

### Why a relation and not an `Equiv`

The paper's proof consumes existence in both directions and never injectivity or round-trip
cancellation, so an equivalence would be strictly more data than the induction spends. A
`Prop`-valued `Rel` on world histories has no round trip to cancel, and every instance in the tree
(`TruthIso.toCorr`, `TimeShift.shiftCorr`, `IntTransfer`'s `alignedCorr`) is a pointwise
statement about `WorldHistory.state`, which is what lets each of them be derived from a single
induction.

`TruthIso` (below, after the time-shift section) is the bijective special case:
`TruthIso.toCorr` reads an equivalence `WorldHistory F ≃ WorldHistory F'` as the relation "`hist` sends the one to
the other", and `truthAt_of_truthIso` is `truthAt_of_truthCorr` at that instance.
-/

/--
**A truth correspondence between two task models.**

Field by field against the paper:
- `dur`: times reindex by an order isomorphism — order preservation is what `untl`/`snce` need.
- `Rel`: the correspondence relation on world histories — the relation of
  `def:time-shift-histories`.
- `atom`: the valuation agrees at the states of every related pair — the base case of
  `lem:history-time-shift-preservation`. It is quantified over every related pair, not one
  distinguished history, because the `□` case applies the induction hypothesis at a pair the
  caller did not choose.
- `fwd` / `bwd`: every possible world on either side is related to some possible world on the
  other — `app:auto_existence` in the two directions the `□` case of
  `lem:history-time-shift-preservation` uses.
-/
structure TruthCorr {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
  /-- Times reindex by an order isomorphism. -/
  dur : F.Duration ≃o F'.Duration
  /-- The correspondence relation on world histories. -/
  Rel : WorldHistory F → WorldHistory F' → Prop
  /-- The valuation agrees at the states of every related pair. -/
  atom : ∀ σ σ', Rel σ σ' → ∀ (t : F.Duration) (p : Atom),
    M.valuation (σ.state t) p ↔ M'.valuation (σ'.state (dur t)) p
  /-- Every world history of `F` is related to some world history of `F'`. -/
  fwd : ∀ σ : WorldHistory F, ∃ σ', Rel σ σ'
  /-- Every world history of `F'` is related to some world history of `F`. -/
  bwd : ∀ σ' : WorldHistory F', ∃ σ, Rel σ σ'

namespace Truth

/--
**The generic truth transport, relational form.**

One `induction φ` over `Formula`'s six constructors, discharging every transport a `TruthCorr`
can express. Every order-preserving truth transport in `Semantics/` is an instance of it
(`truthAt_of_truthIso`, `TimeShift.timeShift_preserves_truth`, `IntTransfer.truthAt_map`); the
only other generic induction is the time-reversal twin `truthAt_of_truthAntiIso`.

The body is the former `truthAt_of_truthIso` induction with `I.hist.surjective` in the `□` case
replaced by `I.bwd` (forward direction) and `I.fwd` (backward direction) — the two
halves of `app:auto_existence`. The `untl` and `snce` cases spend `dur`'s surjectivity on the
guard's bounded quantifier and `OrderIso.lt_iff_lt` in both directions on the bounds. Written
against the `truth_norm` characterisation lemmas (`imp_iff`, `box_iff`, `untl_iff`, `snce_iff`)
rather than `simp only [TruthAt]`, which is what keeps it short.
-/
theorem truthAt_of_truthCorr {F F' : TaskFrame} {M : TaskModel F} {M' : TaskModel F'}
    (I : TruthCorr M M') (φ : Formula) :
    ∀ (σ : WorldHistory F) (σ' : WorldHistory F'), I.Rel σ σ' →
      ∀ t : F.Duration, TruthAt M σ t φ ↔ TruthAt M' σ' (I.dur t) φ := by
  induction φ with
  | atom p => intro σ σ' h t; exact I.atom σ σ' h t p
  | bot => intro σ σ' _ t; exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
      intro σ σ' h t
      simp only [imp_iff]
      rw [ihφ σ σ' h t, ihψ σ σ' h t]
  | box φ ih =>
      intro σ σ' _ t
      simp only [box_iff]
      constructor
      · intro h ρ'
        obtain ⟨ρ, hR⟩ := I.bwd ρ'
        exact (ih ρ ρ' hR t).mp (h ρ)
      · intro h ρ
        obtain ⟨ρ', hR⟩ := I.fwd ρ
        exact (ih ρ ρ' hR t).mpr (h ρ')
  | untl ψ φ ihψ ihφ =>
      intro σ σ' h t
      simp only [untl_iff]
      constructor
      · rintro ⟨s, hts, hs, hmin⟩
        refine ⟨I.dur s, I.dur.lt_iff_lt.mpr hts, (ihφ σ σ' h s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := I.dur.surjective r'
        exact (ihψ σ σ' h r).mp (hmin r (I.dur.lt_iff_lt.mp h1) (I.dur.lt_iff_lt.mp h2))
      · rintro ⟨s', hts', hs', hmin'⟩
        obtain ⟨s, rfl⟩ := I.dur.surjective s'
        refine ⟨s, I.dur.lt_iff_lt.mp hts', (ihφ σ σ' h s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihψ σ σ' h r).mpr (hmin' (I.dur r) (I.dur.lt_iff_lt.mpr h1) (I.dur.lt_iff_lt.mpr h2))
  | snce ψ φ ihψ ihφ =>
      intro σ σ' h t
      simp only [snce_iff]
      constructor
      · rintro ⟨s, hst, hs, hmin⟩
        refine ⟨I.dur s, I.dur.lt_iff_lt.mpr hst, (ihφ σ σ' h s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := I.dur.surjective r'
        exact (ihψ σ σ' h r).mp (hmin r (I.dur.lt_iff_lt.mp h1) (I.dur.lt_iff_lt.mp h2))
      · rintro ⟨s', hst', hs', hmin'⟩
        obtain ⟨s, rfl⟩ := I.dur.surjective s'
        refine ⟨s, I.dur.lt_iff_lt.mp hst', (ihφ σ σ' h s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihψ σ σ' h r).mpr (hmin' (I.dur r) (I.dur.lt_iff_lt.mpr h1) (I.dur.lt_iff_lt.mpr h2))

end Truth

/-! ## Time-Shift Preservation

Truth is preserved under time shift: for a formula `φ`,
`TruthAt M σ y φ ↔ TruthAt M (timeShift σ (y - x)) x φ`. This is the semantic engine behind the
MF and TF axioms' validity.

The theorem is `Truth.truthAt_of_truthCorr` at the instance `shiftCorr`: `ShiftRel Δ` is the
relation of `def:time-shift-histories`, and `shiftCorr`'s `fwd`/`bwd` are `app:auto_existence`
("total since 𝔇 is a group", i.e. `WorldHistory.timeShift`). No six-case induction lives in this section; the one that
used to is the relational transport's, run once.
-/

namespace TimeShift

/--
Truth transport across equal histories.

When two histories are equal, truth is preserved.
-/
theorem truth_history_eq (M : TaskModel F)
    (τ₁ τ₂ : WorldHistory F) (t : F.Duration)
    (h_eq : τ₁ = τ₂) (φ : Formula) :
    TruthAt M τ₁ t φ ↔ TruthAt M τ₂ t φ := by
  cases h_eq
  rfl

/--
`ρ` is the `Δ`-shift of `ρ'`, pointwise: `ρ.state z = ρ'.state (z + Δ)` for every `z`. This is
the relation of `def:time-shift-histories` (`τ ≈ σ` with `τ(z) = σ(z + Δ)`).
-/
def ShiftRel (Δ : F.Duration) (ρ ρ' : WorldHistory F) : Prop :=
  ∀ z, ρ.state z = ρ'.state (z + Δ)

/-- `σ.timeShift Δ` is the `Δ`-shift of `σ`, definitionally. -/
theorem shiftRel_timeShift (Δ : F.Duration) (σ : WorldHistory F) :
    ShiftRel Δ (σ.timeShift Δ) σ :=
  fun _ => rfl

/-- `ρ` is the `Δ`-shift of `ρ.timeShift (-Δ)`. Not definitional: the right-hand side sits at
`z + Δ + -Δ`, so the state equation is transported along `add_neg_cancel_right`. -/
theorem shiftRel_timeShift_neg (Δ : F.Duration) (ρ : WorldHistory F) :
    ShiftRel Δ ρ (ρ.timeShift (-Δ)) :=
  fun z => (congrArg ρ.state (add_neg_cancel_right z Δ)).symm

/--
**Time shift is a truth correspondence** of `M` with itself: times reindex by `· + Δ`, histories
by `ShiftRel Δ`. `fwd` and `bwd` are `app:auto_existence` — every possible world has a shifted
possible world in each direction, `WorldHistory.timeShift` — and `atom` is the pointwise state
agreement at one time.

`dur` must be `OrderIso.addRight Δ` itself. A hand-built `{ toEquiv := Equiv.addRight Δ, … }`
elaborates, but leaves an unreduced `let` in `dur t` that blocks `rw` on `state` at every use
site of the transport.
-/
def shiftCorr (M : TaskModel F) (Δ : F.Duration) : TruthCorr M M where
  dur := OrderIso.addRight Δ
  Rel := ShiftRel Δ
  atom := by
    intro ρ ρ' h t p
    show M.valuation (ρ.state t) p ↔ M.valuation (ρ'.state (t + Δ)) p
    rw [h t]
  fwd := fun ρ => ⟨ρ.timeShift (-Δ), shiftRel_timeShift_neg Δ ρ⟩
  bwd := fun ρ' => ⟨ρ'.timeShift Δ, shiftRel_timeShift Δ ρ'⟩

/--
Time-shift preserves truth of formulas.

If σ is a history and Δ = y - x, then truth at (σ, y) equals truth at (timeShift σ Δ, x).

**Paper Reference**: `lem:history-time-shift-preservation`, stated as the paper states it, for a
possible world `σ ∈ H_F`.

**Proof**: `Truth.truthAt_of_truthCorr` at `shiftCorr M (y - x)` on the related pair
`(σ.timeShift (y - x), σ)`, then `x + (y - x) = y`. The final step is a `change` followed by
`rw [add_sub_cancel]`: `simpa` does not normalise `(OrderIso.addRight Δ) x` to `x + Δ`.

**Key Insight**: **no shift-closure hypothesis is required.** The box clause ranges over every
world history, and `WorldHistory.timeShift` lands in that range by construction — there is no
closure condition left to assume.
-/
theorem timeShift_preserves_truth (M : TaskModel F)
    (σ : WorldHistory F) (x y : F.Duration)
    (φ : Formula) :
    TruthAt M (σ.timeShift (y - x)) x φ ↔ TruthAt M σ y φ := by
  have h := Truth.truthAt_of_truthCorr (shiftCorr M (y - x)) φ (σ.timeShift (y - x)) σ
    (shiftRel_timeShift (y - x) σ) x
  change TruthAt M (σ.timeShift (y - x)) x φ ↔ TruthAt M σ (x + (y - x)) φ at h
  rw [add_sub_cancel] at h
  exact h

/--
Corollary: For any history σ at time y, there exists a history at time x
(namely, timeShift σ (y - x)) where the same formulas are true.

This is the key lemma for proving MF and TF axioms.
-/
theorem exists_shifted_history (M : TaskModel F)
    (σ : WorldHistory F) (x y : F.Duration)
    (φ : Formula) :
    TruthAt M σ y φ ↔
    TruthAt M (σ.timeShift (y - x)) x φ := by
  exact (timeShift_preserves_truth M σ x y φ).symm

end TimeShift

namespace Truth

/-!
## `□` is a model constant

The box clause quantifies over *all* world histories at a time. Under time-homogeneity of the task
relation that makes its truth value depend on neither the history nor the time — a boxed formula is
a fact about the model alone.

This block is placed after `TimeShift` rather than beside the other `Truth` clause lemmas because
its proof consumes `TimeShift.timeShift_preserves_truth`, which is declared there.
-/

/--
**A boxed formula's truth value is a constant of the model**: it depends on neither the history nor
the time.

Two very different reasons combine, and the docstring separates them deliberately so that neither
is over-engineered in the proof:

- **History-independence is definitional.** `def:BL-semantics`'s box clause is
  `∀ σ : WorldHistory F, TruthAt M σ t φ` — it simply does not mention `τ`. Nothing has to be
  proved.
- **Time-independence is the substantive half**, and it is exactly time-homogeneity: given a world
  history `ρ` at which `φ` is wanted at `s`, the `(s - t)`-shift of `ρ` is covered by the
  hypothesis at `t`, and `TimeShift.timeShift_preserves_truth` transports the result back.

This is what makes the box case of a finite-model truth lemma routine rather than the hardest
clause: the set of total histories over a finite carrier is still uncountable, but the box
*predicate* is constant on it, so a model has one finite set of box facts, computed once.
-/
theorem box_const (M : TaskModel F) (τ σ : WorldHistory F)
    (t s : F.Duration) (φ : Formula) :
    TruthAt M τ t φ.box ↔ TruthAt M σ s φ.box := by
  simp only [TruthAt]
  constructor
  · intro h ρ
    exact (TimeShift.timeShift_preserves_truth M ρ t s φ).mp (h (ρ.timeShift (s - t)))
  · intro h ρ
    exact (TimeShift.timeShift_preserves_truth M ρ s t φ).mp (h (ρ.timeShift (t - s)))

/-- The time-only specialization of `box_const`, at a fixed history. -/
theorem box_time_const (M : TaskModel F) (τ : WorldHistory F) (t s : F.Duration)
    (φ : Formula) : TruthAt M τ t φ.box ↔ TruthAt M τ s φ.box :=
  box_const M τ τ t s φ

end Truth

/-! ## Truth isomorphisms — the bijective special case

`TruthIso` is the bijective special case of `TruthCorr`: times reindex by an order isomorphism
and world histories reindex by an equivalence `WorldHistory F ≃ WorldHistory F'`. It is the packaging
`Independence/LoopingDuration.lean`'s duration reindexings naturally come in, and it is kept as a
structure in its own right for them. It is not a second induction: `TruthIso.toCorr` reads
`hist` as the relation "`hist` sends the one to the other", and `truthAt_of_truthIso` is
`truthAt_of_truthCorr` at that instance.

### Why `hist` is an equivalence

The paper needs existence in both directions (`app:auto_existence`): the `□` case of the
transport must produce, for an arbitrary possible world of `F'`, a possible world of `F` to feed
the hypothesis, and conversely. `TruthCorr.fwd`/`bwd` ask for exactly that, and an
`Equiv` supplies it — the map itself in one direction, `Equiv.surjective` in the other. Nothing
finer than the two existence facts is spent, which is why the relational `TruthCorr` is the
primitive and this structure the special case.

### Why `atom` is quantified over all histories

The `atom` field has to hold at every `τ : WorldHistory F`, not at one distinguished history, because the
`box` case applies the induction hypothesis at a history the caller did not choose. A per-history
atom hypothesis would not survive the box case — which is precisely why
`Correspondence/FwdRecPeriodicity.truthAt_add_hist_period` is **not** an instance of this
structure, nor of `TruthCorr`, and keeps its own induction; see its docstring.
-/

/--
**A truth isomorphism between two task models.**

`dur` reindexes times by an order isomorphism, `hist` reindexes world histories by an
equivalence, and `atom` says the two models agree on atomic truth under that reindexing. The
three together are exactly what `TruthIso.toCorr` needs to build a `TruthCorr`: `dur` is
passed through, `hist` and its surjectivity supply `fwd`/`bwd`, and `atom` supplies `atom`.
-/
structure TruthIso {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
  /-- Times reindex by an order isomorphism — order preservation is what `untl`/`snce` need. -/
  dur : F.Duration ≃o F'.Duration
  /-- World histories reindex by an **equivalence**; see the section note on why not a map. -/
  hist : WorldHistory F ≃ WorldHistory F'
  /-- Atomic truth agrees under the reindexing, at **every** world history. -/
  atom : ∀ (τ : WorldHistory F) (t : F.Duration) (p : Atom),
    M.valuation (τ.state t) p ↔ M'.valuation ((hist τ).state (dur t)) p

/--
**A `TruthIso` is a `TruthCorr`.** The relation is "`hist` sends the one world history to the
other": `Rel σ σ'` is `hist σ = σ'`. `fwd` is `hist` itself, `bwd` is `hist.surjective`, and
`atom` is the structure's `atom` field.
-/
def TruthIso.toCorr {F F' : TaskFrame} {M : TaskModel F} {M' : TaskModel F'}
    (I : TruthIso M M') : TruthCorr M M' where
  dur := I.dur
  Rel := fun σ σ' => I.hist σ = σ'
  atom := by
    rintro σ σ' rfl t p
    exact I.atom σ t p
  fwd := fun σ => ⟨I.hist σ, rfl⟩
  bwd := I.hist.surjective

namespace Truth

/--
**Truth transport along a `TruthIso`.**

`truthAt_of_truthCorr` at the instance `TruthIso.toCorr`: the related pair is
`(τ, I.hist τ)`, witnessed by `rfl`. The six-case induction lives in
`truthAt_of_truthCorr`; nothing is re-run here. Statement unchanged from the days it carried its
own induction, so every consumer (`Independence/LoopingDuration.lean`) is untouched.
-/
theorem truthAt_of_truthIso {F F' : TaskFrame} {M : TaskModel F} {M' : TaskModel F'}
    (I : TruthIso M M') (φ : Formula) (τ : WorldHistory F) (t : F.Duration) :
    TruthAt M τ t φ ↔ TruthAt M' (I.hist τ) (I.dur t) φ :=
  truthAt_of_truthCorr (TruthIso.toCorr I) φ τ (I.hist τ) rfl t

end Truth

/-! ## The anti-isomorphism twin

`TruthIso` transports truth along an *order-preserving* reindexing of time. A time **reversal**
is order-reversing, so it cannot be one — and the formula it transports to is not `φ` but
`φ.swapTemporal`, since reversing time exchanges `untl` with `snce`. `TruthAntiIso` is that
twin, and `truthAt_of_truthAntiIso` its generic lemma.

`Formula.swapTemporal` (`Syntax/Formula.lean`) fixes `atom` and `bot`, distributes through `imp`
and `box`, and exchanges `untl` with `snce` — exactly the six-case shape the twin's induction
needs, one clause per constructor with no residue.
-/

/--
**An anti-isomorphism between two task models**: `TruthIso` with time reversed.

`dur` is a bare `Equiv` plus an explicit reversal condition rather than an
`F.Duration ≃o (F'.Duration)ᵒᵈ`. The two carry the same content, and the `≃o`-into-the-dual
spelling would force every use site to insert `OrderDual.toDual`/`ofDual` round trips into
statements that are otherwise about the carrier itself.

`hist` and `atom` are unchanged from `TruthIso`, and for the same reasons: the `box` clause of
`TruthAt` is time-symmetric, so reversal does not touch it, and it still ranges over all total
histories — which is what forces `hist` to be an equivalence and `atom` to be quantified over
every history.
-/
structure TruthAntiIso {F F' : TaskFrame} (M : TaskModel F) (M' : TaskModel F') where
  /-- Times reindex by an equivalence... -/
  dur : F.Duration ≃ F'.Duration
  /-- ...which **reverses** the order. This is the whole difference from `TruthIso`. -/
  dur_rev : ∀ s t : F.Duration, dur s < dur t ↔ t < s
  /-- World histories reindex by an equivalence, exactly as in `TruthIso`. -/
  hist : WorldHistory F ≃ WorldHistory F'
  /-- Atomic truth agrees under the reindexing, at every world history. -/
  atom : ∀ (τ : WorldHistory F) (t : F.Duration) (p : Atom),
    M.valuation (τ.state t) p ↔ M'.valuation ((hist τ).state (dur t)) p

namespace Truth

/--
**The generic truth transport across an anti-isomorphism.**

The order-reversing twin of `truthAt_of_truthCorr` (at the `TruthIso` instance), concluding at
`φ.swapTemporal`. Its `atom`,
`bot`, `imp` and `box` cases are the same arguments, since `swapTemporal` is the identity on the
first two and structural on the second two; only `untl` and `snce` differ, and they differ by
exchanging places and reading every bound through `dur_rev` instead of `OrderIso.lt_iff_lt`.

Note on `swap_norm`: the plan for this work specified writing the body against that simp set.
`swap_norm` collects the eleven `Formula.swap_temporal_*` lemmas, which push `swapTemporal`
through the **derived** operators (`neg`, `diamond`, `someFuture`, `next`, …). A six-constructor
induction needs the *base* equations of `Formula.swapTemporal` instead, and those are not in the
set — nor should they be, since adding them would make `swap_norm` unfold the definition at every
call site. `simp only [Formula.swapTemporal, …]` is therefore what the base cases use; `swap_norm`
remains the right tool for a caller reasoning about a derived operator.
-/
theorem truthAt_of_truthAntiIso {F F' : TaskFrame} {M : TaskModel F} {M' : TaskModel F'}
    (I : TruthAntiIso M M') (φ : Formula) (τ : WorldHistory F) (t : F.Duration) :
    TruthAt M τ t φ ↔ TruthAt M' (I.hist τ) (I.dur t) φ.swapTemporal := by
  induction φ generalizing τ t with
  | atom p =>
      rw [Formula.swapTemporal]
      exact I.atom τ t p
  | bot => simp [Formula.swapTemporal]
  | imp φ ψ ihφ ihψ =>
      simp only [Formula.swapTemporal, imp_iff]
      rw [ihφ τ t, ihψ τ t]
  | box φ ih =>
      simp only [Formula.swapTemporal, box_iff]
      constructor
      · intro h σ'
        obtain ⟨τ', hτ'⟩ := I.hist.surjective σ'
        have key := (ih τ' t).mp (h τ')
        rw [hτ'] at key
        exact key
      · intro h σ
        exact (ih σ t).mpr (h (I.hist σ))
  | untl ψ φ ihψ ihφ =>
      simp only [Formula.swapTemporal, untl_iff, snce_iff]
      constructor
      · rintro ⟨s, hts, hs, hg⟩
        refine ⟨I.dur s, (I.dur_rev s t).mpr hts, (ihφ τ s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := I.dur.surjective r'
        exact (ihψ τ r).mp (hg r ((I.dur_rev r t).mp h2) ((I.dur_rev s r).mp h1))
      · rintro ⟨s', hs't, hs', hg'⟩
        obtain ⟨s, rfl⟩ := I.dur.surjective s'
        refine ⟨s, (I.dur_rev s t).mp hs't, (ihφ τ s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihψ τ r).mpr (hg' (I.dur r) ((I.dur_rev s r).mpr h2) ((I.dur_rev r t).mpr h1))
  | snce ψ φ ihψ ihφ =>
      simp only [Formula.swapTemporal, snce_iff, untl_iff]
      constructor
      · rintro ⟨s, hst, hs, hg⟩
        refine ⟨I.dur s, (I.dur_rev t s).mpr hst, (ihφ τ s).mp hs, ?_⟩
        intro r' h1 h2
        obtain ⟨r, rfl⟩ := I.dur.surjective r'
        exact (ihψ τ r).mp (hg r ((I.dur_rev r s).mp h2) ((I.dur_rev t r).mp h1))
      · rintro ⟨s', hts', hs', hg'⟩
        obtain ⟨s, rfl⟩ := I.dur.surjective s'
        refine ⟨s, (I.dur_rev t s).mp hts', (ihφ τ s).mpr hs', ?_⟩
        intro r h1 h2
        exact (ihψ τ r).mpr (hg' (I.dur r) ((I.dur_rev t r).mpr h2) ((I.dur_rev r s).mpr h1))

end Truth

end FormalSystem.Semantics
