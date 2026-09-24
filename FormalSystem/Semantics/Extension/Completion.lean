/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Int.LeastGreatest
import Mathlib.Data.Rat.Denumerable
import Mathlib.Order.SuccPred.Archimedean
import FormalSystem.Semantics.Extension.Step
import FormalSystem.Semantics.FrameProperty
import FormalSystem.Semantics.PartialHistoryOrder

/-!
# *Completion* — the derived condition `thm:extension` actually consumes

`def:frame`'s *Saturation* is eliminated at exactly one site in the whole development,
`lem:step` (`FormalSystem.Semantics.PartialHistory.step`). This module isolates the condition that
site actually needs, shows *Saturation* implies it, and shows it is **equivalent** to the one-point
extension property — so it is exactly as strong as `thm:extension` requires, and no stronger.

The condition, stated over a bare relation and with no reference to histories:

> *Completion.* `⋂_{t ∈ X} Fib(w_t, z - t) ≠ ∅` for every nonempty `X ⊆ D`, every coherent
> family `{w_t}_{t ∈ X} ⊆ W` (`w_s ⇒_{t - s} w_t` for all `s, t ∈ X`), and every `z ∈ D`.

That condition is declared **as a bare-relation predicate**, `TaskFrame.Completion`
(`Semantics/TaskFrame.lean`), beside `Saturation`, `Serial`, `Compositional` and `Limit`: it
mentions the state set `W`, the duration type `D` and the task relation, and nothing else — no
`Fib`, no fiber/segment classification, no notion of history. It is sited there so that it can be
*compared* with the constraints in their own vocabulary, not because it is one of them: it is the
**derived** condition the extension chain consumes, and `def:frame`'s fourth constraint is
*Saturation*. See "Why *Completion* is a derived condition" below.

A coherent family indexed by a nonempty `X` **is** a partial history (`def:world-history`), so the
`PartialHistory`-shaped form `Completion` and the relation-shaped form `CoherentCompletion` — the
latter *definitionally* `TaskFrame.Completion F.TaskRel` — are interchangeable;
`completion_iff_coherentCompletion` bridges them, and `coherentCompletion_iff_rel` names the
definitional identity. Both bridges are recognition lemmas carrying **zero** frame constraints, so
the `PartialHistory` form is a recognition of the bare condition, never a definitional dependency
of it on histories.

## What this module establishes

* `coherentCompletion_iff_rel` — the frame-level spelling of the condition **is**
  `TaskFrame.Completion F.TaskRel`, by `Iff.rfl`.
* `completion_of_onePointExtension` — the extension property gives *Completion*, at **no** frame
  constraint whatever.
* `onePointExtension_of_completion` — *Completion* plus *Seriality* plus *Limit* gives the
  one-point extension property, with **no** *Saturation* and **no** *Compositionality*.
* `completion_iff_onePointExtension` — hence the two are the same condition at any frame
  satisfying *Seriality* and *Limit*.
* `completion_of_isRegular` — *Saturation* (through the existing `lem:step`) gives *Completion*.
  This is the sole route by which *Saturation* enters.
* `completion_of_finite_domain` — the **finitary** form of *Completion*, from *Compositionality*
  and *Seriality* over any temporal order; with `RationalTwoOrigins.not_rel_completion` it shows
  the infinitary quantifier is essential.
* `extension_of_completion` — *Completion* plus *Seriality* plus *Limit* gives `thm:extension` in
  full, through the existing Zorn scaffolding (`exists_maximal_extension`), which is itself
  constraint-free. This is where the minimality is recorded.
* `HasCofinalNest` / `sInter_constraints_nonempty_of_nestSaturation` — the nest condition `S₁`
  (`TaskFrame.NestSaturation`) plus a cofinal nest inside `Constraints τ z` gives what `lem:step`
  consumes. Stated as a property of the constraint family: the frame-level `S₁ → Saturation` is
  **not** available and must never be stated.
* `hasCofinalNest_of_countable` / `sInter_constraints_nonempty_of_countable` — over any history
  with countably many times, hence over both `ℤ`-time and `ℚ`-time, `S₁` buys exactly what `S₁ᵈ`
  buys at `lem:step`. **The directedness of `def:frame`'s fourth constraint is therefore not
  forced**; it is kept on the naturalness criterion, and this is the sharpness result recording
  the fact.

## Discrete time: *Saturation* is redundant over `def:BX-z`'s ℤ-time

`lem:step`'s own recorded closing remark — "When the family has a `⊆`-least member, that member
already contains a candidate and *Saturation* is not needed" — is turned into a theorem in the
second half of this module. `HasNearest` names **when** the constraint family has a `⊆`-least
member: exactly when the history's domain has a nearest time on each side of the new time `z`.
`completion_of_hasNearest` then derives *Completion* from *Compositionality* and *Seriality*
alone — and, because it excludes `z ∈ dom τ` first, with **no *Limit*** either. `hasNearest_int`
and `hasNearest_of_succPred` supply the order-side hypothesis, and `extension_of_hasNearest` and
`extension_of_isZTime` close `thm:extension` over ℤ-time with **no** *Saturation*.

## The infinitary quantifier in *Completion* is essential

The argument consumes its nearest-times hypothesis at exactly one set and one target, so the
hypothesis is stated pointwise as `NearestAt` and `completion_of_hasNearest` is one line of
`completion_of_nearest_at`. That weakening buys the finitary case outright: a **finite** domain
has a nearest time on each side of any target in any linear order at all
(`nearestAt_of_finite`), so `completion_of_finite_domain` gives the *Completion* conclusion from
*Compositionality* and *Seriality* over **any** temporal order.

Pair that with `StateTopology.RationalTwoOrigins.not_rel_completion`: a relation that satisfies
*Compositionality* and **fails** *Completion*. Hence **no condition implied by *Compositionality*
can be equivalent to *Completion***, and in particular no finitary form and no two-point form can
be — the two-point case for `s ≤ z ≤ t` is `TaskFrame.Interpolates`, which is one half of
*Compositionality* itself. The infinitary quantifier carries all of the completeness content, and
there is no finite axiomatisation of *Completion* to be had.

## The converse is **false**: *Completion* is a strict weakening of *Saturation*

*Saturation* implies *Completion* (`completion_of_isRegular`, through `lem:step`). The converse
`Completion → Saturation` was once open; it is now **settled negatively**, by a machine-checked
separating frame. `StateTopology.SeparatingFrame.srel` — unit-speed drift on `ℚ` over `ℤ`-time,
`w ⇒ₓ v` iff `|v - w| ≤ |x|` — satisfies *Seriality*, *Compositionality*, *Limit* and
*Completion* (`SeparatingFrame.srel_completion`) while **failing** *Saturation*
(`SeparatingFrame.not_srel_saturation`). So *Completion* is a **strict** weakening of
*Saturation*, unconditionally.

The mechanism is worth stating, because it is what the whole comparison turns on. *Completion*'s
quantifier is indexed by **times**, so it collapses wherever the temporal order has nearest times
— which is exactly the `completion_of_hasNearest` argument, and exactly why the separating frame
satisfies it. *Saturation*'s quantifier is indexed by **balls** (fibres and segments, ordered by
inclusion and by nothing else), which no discreteness of the duration order reaches; so a
`⊇`-directed family of them can shrink onto a Dedekind cut of the carrier however discrete the
durations are.

## Why *Completion* is a **derived condition** and not `def:frame`'s fourth constraint

*Completion* is stated at the primitives level — `TaskFrame.Completion` mentions `W`, `D` and `⇒`
and nothing the theory builds from them — and that is what makes the comparison with *Saturation*
meaningful at all. It is **not** what makes *Completion* a candidate constraint, and the
comparison's verdict, under the criterion that a frame constraint must be a property of the
structure `⟨W, D, ⇒⟩` *as such*, is that *Completion* loses:

- **Its hypothesis clause is `def:world-history`'s clause verbatim.** "A family `{w_t}` on a
  nonempty `X ⊆ D` with `w_s ⇒_{t-s} w_t`" **is** a partial history;
  `completion_iff_coherentCompletion` below is the machine-checked identification. Stating it
  `Fib`-free removes the *word* "history", not the aboutness — so the bare form is a disguise
  rather than a cure. The test is what a condition is *about*, not what vocabulary it is
  written in.
- **It is an axiom in the shape of its own theorem.** `completion_iff_onePointExtension` makes
  *Completion* provably equivalent, under *Seriality* and *Limit*, to "the construction
  `thm:extension` performs succeeds". A definition may not assume the success of the construction
  a theorem about it is supposed to establish.
- **It forward-references.** `def:frame` precedes `def:world-history`; *Completion* looks forward
  to it.

*Saturation* looks **backward** instead, to `def:task-relation`: `Fib R w x = {u | R w x u}` and
`Seg R w v x y = Fib R w x ∩ Fib R v (-y)` are the relation repackaged as subsets, not new
constructions — a difference in kind from a function on a subset of times. Read that way,
*Saturation* says the geometry `⇒` induces on `W`, whose balls are the fibers and segments, has
no gaps: any consistently shrinking system of balls contains an actual state.

So the settled architecture, which this module and `Extension/Step.lean` now describe rather than
propose, is:

1. **`def:frame` carries *Saturation*.** `FrameOver.IsRegular`'s `saturation` field is the
   operative constraint and stays that way; the manuscript already says *Saturation*, so tree and
   paper agree and no manuscript pass is pending.
2. **`completion_of_isRegular` *derives* *Completion*** in the bare form, immediately before the
   sole elimination site `lem:step`.
3. **`extension_of_completion` takes *Completion* as an explicit hypothesis**, so the minimality
   is recorded where minimality belongs — in a theorem's hypotheses, not in a definition. It
   already elaborates with **no `[F.IsRegular]` instance binder**, which is the machine-checked
   form of exactly that claim.

Nothing here is pending on anything else landing.

## Remark: *Saturation* is strictly stronger than *Completion*

The strictness is a **sharpness result about a definition worth keeping**, not a case for
replacing it. *Saturation* implies *Completion* (`completion_of_isRegular`, through `lem:step`);
the converse is **false**, witnessed by `StateTopology.SeparatingFrame.srel` —
`W = ℚ`, `D = ℤ`, `w ⇒ₓ v` iff `|v - w| ≤ |x|` — which satisfies *Seriality*, *Compositionality*,
*Limit* and *Completion* (`SeparatingFrame.srel_completion`) while failing *Saturation*
(`SeparatingFrame.not_srel_saturation`).

**The ball-space footnote, attached here.** `def:frame`'s *Saturation* clause is the
`⇒`-directed form `S₁ᵈ` of the Ćmiel–Kuhlmann–Kuhlmann ball-space hierarchy, over the ball space
of nonempty fibers and segments; the standard nest condition `S₁` is `TaskFrame.NestSaturation`,
and `TaskFrame.nestSaturation_of_saturation` machine-checks the footnote's `S₁ᵈ → S₁`. The
directedness is **not forced**: over any history with countably many times — hence over both
`ℤ`-time and `ℚ`-time — `S₁` buys exactly what `S₁ᵈ` buys at `lem:step`
(`sInter_constraints_nonempty_of_countable`, in this module). It is kept because it is the form
the no-gaps reading of the induced geometry takes when stated about the geometry rather than
about one construction's index set. The separating frame fails `S₁` too
(`SeparatingFrame.not_srel_nestSaturation`), so neither existing witness separates the two forms,
and the sharpness result above is about `S₁` as much as about `S₁ᵈ`.

## References

* JPL paper `lem:step`, `lem:admissible`, `lem:constraint`, `thm:extension`, `cor:occurrence`,
  `def:frame` (its *Seriality*, *Limit*, *Compositionality* and *Saturation* clauses), `def:BX-z`

## Tags

completion · saturation · extension · one-point-extension · discrete-time · lem:step
-/

namespace FormalSystem.Semantics

open TaskFrame

namespace PartialHistory

variable {F : TaskFrame}

/-! ## The two forms of *Completion* -/

/--
*Completion*, in `PartialHistory` form: every partial history admits a state consistent with all
of its own times at any prescribed further time `z`.

This is literally `(⋂₀ Constraints τ z).Nonempty` after `PartialHistory.fibers` has rewritten
constraint membership as the fiber conditions; the segment class of `def:frame`'s *Saturation*
disappears, because a constraint segment is the intersection of its two endpoint fiber conditions
(`seg_eq_inter_fib`).
-/
def Completion (F : TaskFrame) : Prop :=
  ∀ (τ : PartialHistory F) (z : F.Duration),
    ∃ u : F.WorldState, ∀ (t : F.Duration) (ht : τ.domain t),
      F.TaskRel (τ.states t ht) (z - t) u

/--
*Completion*, in bare-relation form at a frame: no notion of history is used, only a coherent
family.

This is **definitionally** `TaskFrame.Completion F.TaskRel` — the bare-relation predicate of
record, which lives beside `Saturation`, `Serial`, `Compositional` and `Limit` in
`Semantics/TaskFrame.lean`, in the primitives `W`, `D` and `⇒` alone. Stating it in that
vocabulary is what makes it comparable with the constraints; it is **not** a proposal that it
become one. `def:frame`'s fourth constraint is *Saturation*, and `completion_of_isRegular`
derives this condition from it. This name is retained as the frame-level spelling; use
`coherentCompletion_iff_rel` to move between the two by name.
-/
def CoherentCompletion (F : TaskFrame) : Prop :=
  TaskFrame.Completion F.TaskRel

/-- The frame-level spelling **is** the bare-relation predicate of record, definitionally. -/
theorem coherentCompletion_iff_rel : CoherentCompletion F ↔ TaskFrame.Completion F.TaskRel :=
  Iff.rfl

/-- The two forms are the same condition: a coherent family on a nonempty index set *is* a
partial history. -/
theorem completion_iff_coherentCompletion : Completion F ↔ CoherentCompletion F := by
  constructor
  · intro h X hX w hw z
    exact h ⟨X, hX, w, hw⟩ z
  · intro h τ z
    exact h τ.domain τ.nonempty_domain τ.states τ.respects_task z

/-! ## The one-point extension property -/

/-- The conclusion of `lem:step`, read as a property of the frame rather than as a lemma. -/
def OnePointExtension (F : TaskFrame) : Prop :=
  ∀ (τ : PartialHistory F) (z : F.Duration), ∃ σ : PartialHistory F, Extends σ τ ∧ σ.domain z

/-! ## `OnePointExtension → Completion`, with no constraint at all -/

/--
The extension property yields *Completion* **unconditionally** — no frame constraint is used.

The witness is the extending history's own state at `z`, and coherence is that history's
`respects_task` field.
-/
theorem completion_of_onePointExtension (h : OnePointExtension F) : Completion F := by
  intro τ z
  obtain ⟨σ, hext, hσz⟩ := h τ z
  refine ⟨σ.states z hσz, fun t ht => ?_⟩
  have := σ.respects_task t z (hext.subset t ht) hσz
  rwa [hext.agree t ht] at this

/-! ## `Completion → OnePointExtension`, from *Seriality* and *Limit* only -/

/--
*Completion* plus *Seriality* plus *Limit* gives the one-point extension property.

**No *Saturation*, and no *Compositionality*.** This is the `lem:admissible` argument run from the
*Completion* witness — the state `lem:step` obtains by eliminating *Saturation*, here taken as a
hypothesis instead: the four pair-cases of `AdjoinRespects`
are `τ`'s own task-respect, the *Completion* fiber condition, that same condition through the
reflection law (`FrameOver.reflection_of_limit`, which costs *Limit* alone), and `lem:nullity`
(`TaskFrame.nullity_of_serial_limit`) at the new time.
-/
theorem onePointExtension_of_completion (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (hC : Completion F) : OnePointExtension F := by
  intro τ z
  by_cases hz : τ.domain z
  · exact ⟨τ, ⟨fun _ ht => ht, fun _ _ => rfl⟩, hz⟩
  obtain ⟨u, hu⟩ := hC τ z
  have hadm : AdjoinRespects τ z u := by
    intro s t hs ht
    by_cases hsd : τ.domain s <;> by_cases htd : τ.domain t
    · rw [adjoinFun_of_domain τ u hsd, adjoinFun_of_domain τ u htd]
      exact τ.respects_task s t hsd htd
    · obtain rfl : z = t := (Or.resolve_left ht htd).symm
      rw [adjoinFun_of_domain τ u hsd, adjoinFun_of_not_domain τ u htd]
      exact hu s hsd
    · obtain rfl : z = s := (Or.resolve_left hs hsd).symm
      rw [adjoinFun_of_not_domain τ u hsd, adjoinFun_of_domain τ u htd]
      have hconv :=
        (F.toFibre.reflection_of_limit hlim (τ.states t htd) (z - t) u).mp (hu t htd)
      rwa [neg_sub] at hconv
    · obtain rfl : z = s := (Or.resolve_left hs hsd).symm
      obtain rfl : z = t := (Or.resolve_left ht htd).symm
      rw [adjoinFun_of_not_domain τ u hsd, sub_self]
      exact TaskFrame.nullity_of_serial_limit hser hlim u
  exact ⟨adjoin τ z u hadm, adjoin_extends τ z u hadm, adjoin_domain_self τ z u hadm⟩

/-- The equivalence, at any frame satisfying *Seriality* and *Limit*: *Completion* **is** the
one-point extension property. 
Paper: — (the equivalence is the audit's own; the manuscript has no anchor for it)
-/
theorem completion_iff_onePointExtension (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) : Completion F ↔ OnePointExtension F :=
  ⟨onePointExtension_of_completion hser hlim, completion_of_onePointExtension⟩

/-! ## *Saturation* implies *Completion* -/

/--
*Saturation* gives *Completion*, through the existing `lem:step`.

**This is where *Saturation* enters, and it enters nowhere else.** The proof routes through
`PartialHistory.step`, which is the sole site in the development where *Saturation* is eliminated
into a conclusion that does not itself mention *Saturation*; everything downstream of this lemma
consumes `Completion` instead.

The consumption list is the full bundle, through `step`: *Completion* being weaker than
*Saturation* is a fact about what this condition NEEDS, and the term as it stands reaches all
four fields.

Constraints consumed: Compositionality, Seriality, Limit, Saturation

Paper: `lem:step`
-/
theorem completion_of_isRegular [F.IsRegular] : Completion F :=
  completion_of_onePointExtension (fun τ z => step F τ z)

/-! ## `thm:extension` from *Completion* -/

/--
`thm:extension` in full, from *Completion* — the derived condition — rather than from
`def:frame`'s *Saturation* directly.

**This signature is where the minimality is recorded**, and recording it here rather than in
`def:frame` is the point: a theorem's hypotheses are where a tight hypothesis belongs, and a
definition is where a natural closure condition belongs. *Saturation* is strictly stronger than
what this theorem needs (see the module docstring's strictness remark), and that is a sharpness
fact about `def:frame`, not a defect in it.

The Zorn scaffolding (`exists_maximal_extension`, `Semantics/PartialHistoryOrder.lean`) carries no
frame constraint, so the only inputs are *Completion*, *Seriality* and *Limit*.

**Orthogonality certificate.** This declaration elaborates with **no** `[F.IsRegular]` instance
binder at all. That is the machine-checked form of the claim that the Zorn layer and `def:frame`'s
four constraints meet only at `extension`: the order-theoretic half of the extension theorem is
constraint-free, and every constraint the theorem consumes is visible in this signature.

Paper: `thm:extension`
-/
theorem extension_of_completion (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (hC : Completion F) (τ : PartialHistory F) :
    ∃ σ : WorldHistory F, Extends σ.val τ := by
  obtain ⟨μ, hle, hmax⟩ := exists_maximal_extension τ
  have htot : μ.IsTotal := by
    intro z
    obtain ⟨σ, hext, hσz⟩ := onePointExtension_of_completion hser hlim hC μ z
    exact (le_def.mp (hmax (le_def.mpr hext))).subset z hσz
  exact ⟨⟨μ, htot⟩, le_def.mp hle⟩

/-! ## Discrete time: nearest times, and the redundancy of *Saturation* -/

/--
**Nearest times, at one set and one target.** The pointwise form: if `X` has a member at or below
`z` then it has a greatest such, and dually above.

This is the form the argument actually consumes — `completion_of_hasNearest` uses its
`HasNearest` hypothesis at exactly one set and one target — and splitting it out is what lets the
finitary case be discharged (`nearestAt_of_finite`) without any property of the order at all.

Paper: — (a hypothesis-shaping device of the audit's; the manuscript has no anchor for it)
-/
def NearestAt {D : Type} [LinearOrder D] (X : D → Prop) (z : D) : Prop :=
  ((∃ t, X t ∧ t ≤ z) → ∃ t, X t ∧ t ≤ z ∧ ∀ t', X t' → t' ≤ z → t' ≤ t) ∧
  ((∃ t, X t ∧ z ≤ t) → ∃ t, X t ∧ z ≤ t ∧ ∀ t', X t' → z ≤ t' → t ≤ t')

/--
**Nearest times.** Every nonempty one-sided part of a subset of `D` has a nearest member.

This is a property of the linear order `D` **alone**, with no reference to any frame. `ℤ` has it
(`hasNearest_int`), and so does every successor/predecessor-Archimedean order
(`hasNearest_of_succPred`); `ℚ` and `ℝ` do not.

Definitionally `NearestAt` at every set and every target, so the two are interchangeable and the
existing discharge proofs below are unaffected by the split.
-/
def HasNearest (D : Type) [LinearOrder D] : Prop :=
  ∀ (X : D → Prop) (z : D), NearestAt X z

/-- `ℤ` has nearest times: a set of integers bounded above has a greatest element, and dually. -/
theorem hasNearest_int : HasNearest ℤ := by
  intro X z
  constructor
  · rintro ⟨t₀, ht₀, hle⟩
    obtain ⟨b, hb, hmax⟩ :=
      Int.exists_greatest_of_bdd (P := fun t => X t ∧ t ≤ z) ⟨z, fun t ht => ht.2⟩ ⟨t₀, ht₀, hle⟩
    exact ⟨b, hb.1, hb.2, fun t' h1 h2 => hmax t' ⟨h1, h2⟩⟩
  · rintro ⟨t₀, ht₀, hge⟩
    obtain ⟨b, hb, hmin⟩ :=
      Int.exists_least_of_bdd (P := fun t => X t ∧ z ≤ t) ⟨z, fun t ht => ht.2⟩ ⟨t₀, ht₀, hge⟩
    exact ⟨b, hb.1, hb.2, fun t' h1 h2 => hmin t' ⟨h1, h2⟩⟩

/--
**Every discrete temporal order has nearest times.**

This is `HasNearest` at the successor/predecessor-Archimedean orders — exactly the class
`TaskFrame.IsZTime` (`Semantics/FrameProperty.lean`) picks out, which is `def:BX-z`'s ℤ-time.
`hasNearest_int` is the concrete instance.
-/
theorem hasNearest_of_succPred (D : Type) [LinearOrder D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] : HasNearest D := by
  intro X z
  constructor
  · rintro ⟨t₀, ht₀, hle⟩
    obtain ⟨b, hbmem, hbub⟩ :=
      BddAbove.exists_isGreatest_of_nonempty (S := {t | X t ∧ t ≤ z})
        ⟨z, fun t ht => ht.2⟩ ⟨t₀, ht₀, hle⟩
    exact ⟨b, hbmem.1, hbmem.2, fun t' h1 h2 => hbub ⟨h1, h2⟩⟩
  · rintro ⟨t₀, ht₀, hge⟩
    obtain ⟨b, hbmem, hblb⟩ :=
      BddBelow.exists_isLeast_of_nonempty (S := {t | X t ∧ z ≤ t})
        ⟨z, fun t ht => ht.2⟩ ⟨t₀, ht₀, hge⟩
    exact ⟨b, hbmem.1, hbmem.2, fun t' h1 h2 => hblb ⟨h1, h2⟩⟩

/--
The *Completion* conclusion at **one** history and **one** target time, from a nearest time on
each side of that target, given *Compositionality* and *Seriality*.

This is `completion_of_hasNearest` weakened to the single instance of the nearest-times
hypothesis its proof actually consumes; `completion_of_hasNearest` is now one line of it, and
`completion_of_finite_domain` is the other consumer.

**No *Saturation*, and — this is the sharp part — no *Limit* either.** This is `lem:step`'s own
recorded closing remark made precise: the `⊆`-least constraint is the one imposed by the nearest
domain time on each side, and *Compositionality* shows every other constraint contains it.

*Limit* drops out because the proof **excludes `z ∈ dom τ` first** (that case is discharged by
`τ`'s own state at `z`) and therefore never reaches `FrameOver.reflection` at duration zero: every
reflection it performs is at a provably nonzero duration, where the reflection law is definitional
(`TaskFrame.reflect_reflection_of_ne`). This is the one *Limit*-free route through the extension
chain in the whole tree; `Extension/Constraint.lean`'s `constraint` and `nonempty_fib_of_serial`
do **not** take it, and their docstrings record that.

Paper: `lem:step`
-/
theorem completion_of_nearest_at (τ : PartialHistory F) (z : F.Duration)
    (hN : NearestAt τ.domain z) (hcomp : TaskFrame.Compositional F.TaskRel)
    (hser : TaskFrame.Serial F.TaskRel) :
    ∃ u : F.WorldState, ∀ (t : F.Duration) (ht : τ.domain t),
      F.TaskRel (τ.states t ht) (z - t) u := by
  have hfwd := TaskFrame.forward_of_comp hcomp
  have hint := TaskFrame.interpolates_of_comp hcomp
  by_cases hzd : τ.domain z
  · -- `z` is already a domain time: its own state is the witness.
    exact ⟨τ.states z hzd, fun t ht => τ.respects_task t z ht hzd⟩
  -- Reflection at a nonzero duration is definitional; `z ∉ dom τ` keeps every duration nonzero.
  have hrefl : ∀ (t : F.Duration) (ht : τ.domain t) (u : F.WorldState),
      F.TaskRel u (t - z) (τ.states t ht) → F.TaskRel (τ.states t ht) (z - t) u := by
    intro t ht u h
    have hne : t - z ≠ 0 := sub_ne_zero_of_ne (fun hEq => hzd (hEq ▸ ht))
    have := (TaskFrame.reflect_reflection_of_ne (P := F.toFibre.PosRel) hne).mp h
    rwa [neg_sub] at this
  obtain ⟨hlow, hhigh⟩ := hN
  by_cases hbelow : ∃ t, τ.domain t ∧ t ≤ z
  · obtain ⟨tm, htm, htmz, htmax⟩ := hlow hbelow
    by_cases habove : ∃ t, τ.domain t ∧ z ≤ t
    · -- Two-sided: the straddling segment is the `⊆`-least constraint; interpolation fills it.
      obtain ⟨tp, htp, hztp, htmin⟩ := hhigh habove
      have hspan : F.TaskRel (τ.states tm htm) ((z - tm) + (tp - z)) (τ.states tp htp) := by
        have hsum : (z - tm) + (tp - z) = tp - tm := by abel
        rw [hsum]
        exact τ.respects_task tm tp htm htp
      obtain ⟨u, hu₁, hu₂⟩ :=
        hint (τ.states tm htm) (τ.states tp htp) (z - tm) (tp - z)
          (sub_nonneg.mpr htmz) (sub_nonneg.mpr hztp) hspan
      refine ⟨u, fun t ht => ?_⟩
      rcases le_total t z with htz | hzt
      · -- below: compose `τ(t) ⇒_{tm - t} τ(tm)` with `τ(tm) ⇒_{z - tm} u`
        have h1 := τ.respects_task t tm ht htm
        have := hfwd (τ.states t ht) (τ.states tm htm) u (tm - t) (z - tm)
          (sub_nonneg.mpr (htmax t ht htz)) (sub_nonneg.mpr htmz) h1 hu₁
        have hsum : (tm - t) + (z - tm) = z - t := by abel
        rwa [hsum] at this
      · -- above: compose `u ⇒_{tp - z} τ(tp)` with `τ(tp) ⇒_{t - tp} τ(t)`, then reflect
        have h1 := τ.respects_task tp t htp ht
        have := hfwd u (τ.states tp htp) (τ.states t ht) (tp - z) (t - tp)
          (sub_nonneg.mpr hztp) (sub_nonneg.mpr (htmin t ht hzt)) hu₂ h1
        have hsum : (tp - z) + (t - tp) = t - z := by abel
        rw [hsum] at this
        exact hrefl t ht u this
    · -- Domain entirely at or below `z`: *Seriality* supplies a successor of the nearest time.
      obtain ⟨u, hu⟩ := (hser (τ.states tm htm) (z - tm) (sub_nonneg.mpr htmz)).1
      refine ⟨u, fun t ht => ?_⟩
      have htz : t ≤ z := le_of_not_ge fun h => habove ⟨t, ht, h⟩
      have h1 := τ.respects_task t tm ht htm
      have := hfwd (τ.states t ht) (τ.states tm htm) u (tm - t) (z - tm)
        (sub_nonneg.mpr (htmax t ht htz)) (sub_nonneg.mpr htmz) h1 hu
      have hsum : (tm - t) + (z - tm) = z - t := by abel
      rwa [hsum] at this
  · -- Domain entirely at or above `z`: *Seriality* supplies a predecessor of the nearest time.
    have habove : ∃ t, τ.domain t ∧ z ≤ t := by
      obtain ⟨t, ht⟩ := τ.nonempty_domain
      exact ⟨t, ht, le_of_not_ge fun h => hbelow ⟨t, ht, h⟩⟩
    obtain ⟨tp, htp, hztp, htmin⟩ := hhigh habove
    obtain ⟨u, hu⟩ := (hser (τ.states tp htp) (tp - z) (sub_nonneg.mpr hztp)).2
    refine ⟨u, fun t ht => ?_⟩
    have hzt : z ≤ t := le_of_not_ge fun h => hbelow ⟨t, ht, h⟩
    have h1 := τ.respects_task tp t htp ht
    have := hfwd u (τ.states tp htp) (τ.states t ht) (tp - z) (t - tp)
      (sub_nonneg.mpr hztp) (sub_nonneg.mpr (htmin t ht hzt)) hu h1
    have hsum : (tp - z) + (t - tp) = t - z := by abel
    rw [hsum] at this
    exact hrefl t ht u this

/--
*Completion* holds as soon as the temporal order has nearest times, given *Compositionality* and
*Seriality*.

**No *Saturation*, and no *Limit*.** One line of `completion_of_nearest_at`, which carries the
argument; the statement is unchanged from when the argument lived here.

Paper: `lem:step`
-/
theorem completion_of_hasNearest (hN : HasNearest F.Duration)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel) :
    Completion F :=
  fun τ z => completion_of_nearest_at τ z (hN τ.domain z) hcomp hser

/-! ### The finitary case: no property of the order at all -/

/--
**A finite set has a nearest member on each side of any target**, in any linear order.

No discreteness, no completeness, no Archimedean hypothesis: finiteness alone. This is what makes
the finitary form of *Completion* a consequence of *Compositionality* and *Seriality*, which is
in turn what shows *Completion*'s infinitary quantifier is essential.

Paper: — (the finitary reduction is the audit's own; the manuscript has no anchor for it)
-/
theorem nearestAt_of_finite {D : Type} [LinearOrder D] {X : D → Prop}
    (hfin : {t | X t}.Finite) (z : D) : NearestAt X z := by
  constructor
  · rintro ⟨t₀, ht₀, hle⟩
    have hs : {t | X t ∧ t ≤ z}.Finite := hfin.subset (fun t ht => ht.1)
    obtain ⟨a, ha⟩ := hs.exists_maximal ⟨t₀, ht₀, hle⟩
    exact ⟨a, ha.prop.1, ha.prop.2, fun t' h1 h2 => le_of_not_gt fun hgt =>
      absurd (ha.le_of_ge (y := t') ⟨h1, h2⟩ hgt.le) (not_le_of_gt hgt)⟩
  · rintro ⟨t₀, ht₀, hge⟩
    have hs : {t | X t ∧ z ≤ t}.Finite := hfin.subset (fun t ht => ht.1)
    obtain ⟨a, ha⟩ := hs.exists_minimal ⟨t₀, ht₀, hge⟩
    exact ⟨a, ha.prop.1, ha.prop.2, fun t' h1 h2 => le_of_not_gt fun hgt =>
      absurd (ha.le_of_le (y := t') ⟨h1, h2⟩ hgt.le) (not_le_of_gt hgt)⟩

/--
**Finitary *Completion*** — the *Completion* conclusion at a history with a **finite** domain,
from *Compositionality* and *Seriality* alone, over **any** temporal order.

Together with `StateTopology.RationalTwoOrigins.not_rel_completion` — a relation satisfying
*Compositionality* and failing *Completion* — this shows that **no condition implied by
*Compositionality* can be equivalent to *Completion***, and in particular that no finitary or
two-point form of *Completion* can be. The infinitary quantifier carries all of the completeness
content.

Paper: `lem:step`
-/
theorem completion_of_finite_domain (τ : PartialHistory F)
    (hfin : {t : F.Duration | τ.domain t}.Finite) (z : F.Duration)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel) :
    ∃ u : F.WorldState, ∀ (t : F.Duration) (ht : τ.domain t),
      F.TaskRel (τ.states t ht) (z - t) u :=
  completion_of_nearest_at τ z (nearestAt_of_finite hfin z) hcomp hser

/--
Over a temporal order with nearest times, the one-point extension property — and hence
`thm:extension` — follows from *Compositionality*, *Seriality* and *Limit*, with
**no *Saturation***.
-/
theorem extension_of_hasNearest (hN : HasNearest F.Duration)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (τ : PartialHistory F) :
    ∃ σ : WorldHistory F, Extends σ.val τ :=
  extension_of_completion hser hlim (completion_of_hasNearest hN hcomp hser) τ

/--
**The headline, at the tree's own discreteness predicate.**

Over ℤ-time (`TaskFrame.IsZTime`, which is `def:BX-z`'s class), `thm:extension` holds from
*Compositionality*, *Seriality* and *Limit* alone: **`def:frame`'s *Saturation* is redundant
there.**

**The job *Saturation* is left with.** It is needed only over temporal orders where a subset of
times can approach a time without reaching a nearest one — that is, only over **dense** time. Two
further classes discharge it outright rather than assuming it: `TaskFrame.saturation_of_finite`
(`cor:saturation-finite`, a finite carrier) and `TaskFrame.saturation_of_deterministic` (a
deterministic relation). And `Extension/PeriodicExtension.lean` confirms the discrete-time point
from the constructive side independently, building a doubly ultimately periodic total history over
ℤ-time with a finite carrier and no appeal to Zorn's lemma at all.

Paper: `def:BX-z`
-/
theorem extension_of_isZTime (hZ : F.IsZTime)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (τ : PartialHistory F) :
    ∃ σ : WorldHistory F, Extends σ.val τ := by
  obtain ⟨hsucc, hpred, harch₁, harch₂⟩ := hZ
  exact extension_of_hasNearest
    (@hasNearest_of_succPred F.Duration _ hsucc hpred harch₁ harch₂) hcomp hser hlim τ

/-! ## The nest condition and `lem:step` -/

/--
`Constraints τ z` contains a nonempty `⊆`-chain that refines every member — the one-line
instantiation of `Order.HasCofinalNest` at this one constraint family.

This is the exact indexing property that makes the nest form `S₁` as strong as the directed form
`S₁ᵈ` **at one history and one target**. It is a property of the constraint family, never of the
frame — which is precisely why the general form (`Order.HasCofinalNest`, in
`ForMathlib/Order/BallSpace.lean`) is upstreamable and this instantiation is not, and why a
condition of this shape belongs on a theorem rather than in `def:frame`.

Demanding that the chain itself be nonempty costs nothing here: `nonempty_Constraints` needs no
frame constraint at all, only the history's own `τ.nonempty_domain` field, so a nonempty chain is
always available inside a nonempty family.

Paper: — (the manuscript has no anchor for the nest reduction; recorded here as `NearestAt` in
this same module is, as the pointwise property the argument actually consumes)
-/
def HasCofinalNest (τ : PartialHistory F) (z : F.Duration) : Prop :=
  Order.HasCofinalNest (Constraints τ z)

/--
**The reduction, instantiated.** `S₁`, a cofinal nest, and nonempty members give exactly what
`lem:step` consumes: a state common to every constraint on `z`.

The proof is an application of `Order.sInter_nonempty_of_sphericallyComplete`, routed through
`TaskFrame.nestSaturation_iff_sphericallyComplete` (which is `Iff.rfl`) and discharging that
lemma's ball obligation with `isFiber_or_isSegment_of_mem_Constraints`. The argument itself is
order theory and lives upstream; nothing of it is transcribed here.

**Shape rule, standing.** This is stated as a property of `Constraints τ z`, and any future
extension of it must be too: **never state a frame-level `S₁ → Saturation`.** That implication is
not available — a `⊇`-directed family of balls need not reduce to a nest, since a maximal chain
in a directed poset need not be cofinal — so the nest condition buys the directed condition's
conclusion only at a family that is *indexed* well enough, which is what `HasCofinalNest`
records and what `hasCofinalNest_of_countable` below discharges.

**No `[F.IsRegular]` binder here or anywhere below it in this section.** The member-nonemptiness
hypothesis is explicit precisely so that the caller supplies it from *Seriality*,
*Compositionality* and *Limit* — what `constraint` actually uses — rather than from an instance
that would drag *Saturation* back in and make the result vacuous.

Paper: — (the manuscript has no anchor for the nest reduction)
-/
theorem sInter_constraints_nonempty_of_nestSaturation
    (hS1 : TaskFrame.NestSaturation F.TaskRel) (τ : PartialHistory F) (z : F.Duration)
    (hne : ∀ c ∈ Constraints τ z, c.Nonempty) (hcof : HasCofinalNest τ z) :
    (⋂₀ Constraints τ z).Nonempty :=
  Order.sInter_nonempty_of_sphericallyComplete
    (TaskFrame.nestSaturation_iff_sphericallyComplete.mp hS1)
    (fun _ hc => isFiber_or_isSegment_of_mem_Constraints hc) hne hcof

/-! ### The carrier discharge: a countable domain has a cofinal nest -/

/--
**The carrier discharge.** A history with countably many times has a cofinal nest of constraints.

No hypothesis on `D` at all — countability is a property of *the history's own domain*, stated
directly, in the idiom this module already uses for `NearestAt`. That is deliberate: the
alternative route through `Archimedean D` is not available, because Mathlib carries no Hölder
embedding with which to discharge it, and a condition on `D` smuggled into the frame is the wrong
shape besides. Every subset of `ℤ` and of `ℚ` is countable, so the hypothesis is free at both
carriers this development instantiates (see the two `example`s below).

**The regimes, as measured.** The plan for this result predicted two, on the strength of
`IsPaired`'s recorded global collapse; the proof has **three**, and the extra one is the
collapse's own stated side condition rather than a defect in it. `IsPaired`'s docstring records
the collapse only for `z ∉ X` — "`z ∉ X` is what makes the two disjuncts exhaustive at every
`t ∈ X`" — and `def:constraints` carries `z ∈ D \ X` in its statement, but Lean's `Constraints`
deliberately does not, siting that proviso at the use sites instead. So the degenerate case is
live here and has to be discharged:

- **`z` is itself a domain time.** Then `z` is not paired with anything (neither disjunct of
  `IsPaired` can hold at `t = z`), so `Fib(τ(z), 0)` is a constraint, and it is contained in every
  other one: in a fiber by whichever monotonicity lemma the side of `z` selects, and in a segment
  because a segment is the intersection of its two endpoint fibers. The singleton `{Fib(τ(z), 0)}`
  is therefore already a cofinal nest. No countability, no construction.
- **One-sided domain** (`z ∉ X`, and `X` has no time on one side of `z`). No `t ∈ X` is paired, so
  `Constraints τ z` is fibers only, and `fib_subset_fib_of_compositional` (all times below `z`) or
  its primed mirror (all times above) makes the whole family a chain. Take `C = Constraints τ z`;
  cofinality is `c' = c`. Still no countability, and still no construction — the two sides are one
  regime discharged by the two mirror lemmas, not two regimes.
- **Straddling domain** (`z ∉ X`, and `X` has times on both sides). Every `t ∈ X` is paired, so
  `Constraints τ z` is segments only, indexed by `A × Bᵒᵖ` with `A = X ∩ (-∞, z)` and
  `B = X ∩ (z, ∞)`. **This is the only regime that uses `hcount`**: enumerate `A` and `B` as
  `a, b : ℕ → D`, form the running extrema `A'(n) = max_{i ≤ n} a(i)` and `B'(n) = min_{i ≤ n}
  b(i)` — each is one of the enumerated values, hence again a domain time on the right side of
  `z` — and take `C = {Seg(τ(A' n), τ(B' n), z - A' n, B' n - z) | n : ℕ}`. Chain-ness is
  `seg_subset_seg_of_compositional` against `A'` monotone and `B'` antitone; cofinality is: given
  `(t, s)`, pick `n` past both of their indices. The two-dimensional index is collapsed to one
  dimension by the diagonal, which is exactly why a nest suffices here.

All three regimes discharge the same `Order.IsNest` obligation, so the split is over the
*construction* of `C`, never over the shape of the conclusion.

**The boundary of the result.** `ℝ`-time histories may have uncountable domains, and the `ℝ` case
needs a separate order-separability argument which is **not** attempted here. This does **not**
settle `S₁ → S₁ᵈ`: a genuine failure of `HasCofinalNest` needs mismatched one-sided cofinal
characters, hence a non-archimedean `D` of uncountable coinitiality, which is a recorded non-goal.

Paper: — (the manuscript has no anchor for the nest reduction)
-/
theorem hasCofinalNest_of_countable (hcomp : TaskFrame.Compositional F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel)
    (τ : PartialHistory F) (z : F.Duration)
    (hcount : {t : F.Duration | τ.domain t}.Countable) : HasCofinalNest τ z := by
  by_cases hz : τ.domain z
  · -- `z` is itself a domain time: its own zero-duration fiber is already a cofinal nest.
    have key : ∀ (t : F.Duration) (ht : τ.domain t),
        TaskFrame.Fib F.TaskRel (τ.states z hz) (z - z)
          ⊆ TaskFrame.Fib F.TaskRel (τ.states t ht) (z - t) := by
      intro t ht
      rcases le_total t z with h | h
      · exact fib_subset_fib_of_compositional hcomp ht hz h le_rfl
      · exact fib_subset_fib_of_compositional' hcomp hlim ht hz h le_rfl
    refine ⟨{TaskFrame.Fib F.TaskRel (τ.states z hz) (z - z)}, ?_, ⟨⟨_, rfl⟩, ?_⟩, ?_⟩
    · rintro c rfl
      exact mem_Constraints.mpr (Or.inr ⟨z, hz, by
        rintro (⟨h, -⟩ | ⟨h, -⟩) <;> exact absurd h (lt_irrefl z), rfl⟩)
    · exact Set.Subsingleton.isChain Set.subsingleton_singleton
    · rintro c (⟨t, s, ht, hs, htz, hzs, rfl⟩ | ⟨t, ht, -, rfl⟩)
      · exact ⟨_, rfl, by rw [seg_eq_inter_fib]; exact Set.subset_inter (key t ht) (key s hs)⟩
      · exact ⟨_, rfl, key t ht⟩
  · by_cases hB : ∃ s, τ.domain s ∧ z < s
    · by_cases hA : ∃ t, τ.domain t ∧ t < z
      · -- Straddling domain: segments only, diagonalised through the running extrema.
        have hrange : ∀ n : ℕ, (Finset.range (n + 1)).Nonempty := fun n =>
          Finset.nonempty_range_iff.mpr (Nat.succ_ne_zero n)
        obtain ⟨t₀, ht₀, ht₀z⟩ := hA
        obtain ⟨s₀, hs₀, hzs₀⟩ := hB
        obtain ⟨a, ha⟩ := (hcount.mono (fun t (h : τ.domain t ∧ t < z) => h.1)).exists_eq_range
            ⟨t₀, ht₀, ht₀z⟩
        obtain ⟨b, hb⟩ := (hcount.mono (fun t (h : τ.domain t ∧ z < t) => h.1)).exists_eq_range
            ⟨s₀, hs₀, hzs₀⟩
        have haA : ∀ i, τ.domain (a i) ∧ a i < z := fun i => by
          have : a i ∈ {t : F.Duration | τ.domain t ∧ t < z} := by rw [ha]; exact ⟨i, rfl⟩
          exact this
        have hbB : ∀ i, τ.domain (b i) ∧ z < b i := fun i => by
          have : b i ∈ {t : F.Duration | τ.domain t ∧ z < t} := by rw [hb]; exact ⟨i, rfl⟩
          exact this
        obtain ⟨A', hA'dom, hA'lt, hA'mono, hA'ge⟩ :
            ∃ A' : ℕ → F.Duration, (∀ n, τ.domain (A' n)) ∧ (∀ n, A' n < z) ∧
              (∀ n m, n ≤ m → A' n ≤ A' m) ∧ (∀ i n, i ≤ n → a i ≤ A' n) := by
          refine ⟨fun n => (Finset.range (n + 1)).sup' (hrange n) a, ?_, ?_, ?_, ?_⟩
          · intro n
            dsimp only
            obtain ⟨i, -, hi⟩ := Finset.exists_mem_eq_sup' (hrange n) a
            rw [hi]; exact (haA i).1
          · intro n
            dsimp only
            obtain ⟨i, -, hi⟩ := Finset.exists_mem_eq_sup' (hrange n) a
            rw [hi]; exact (haA i).2
          · intro n m hnm
            dsimp only
            exact Finset.sup'_mono a (Finset.range_mono (Nat.succ_le_succ hnm)) _
          · intro i n hin
            dsimp only
            exact Finset.le_sup' a (Finset.mem_range.mpr (Nat.lt_succ_of_le hin))
        obtain ⟨B', hB'dom, hB'gt, hB'anti, hB'le⟩ :
            ∃ B' : ℕ → F.Duration, (∀ n, τ.domain (B' n)) ∧ (∀ n, z < B' n) ∧
              (∀ n m, n ≤ m → B' m ≤ B' n) ∧ (∀ i n, i ≤ n → B' n ≤ b i) := by
          refine ⟨fun n => (Finset.range (n + 1)).inf' (hrange n) b, ?_, ?_, ?_, ?_⟩
          · intro n
            dsimp only
            obtain ⟨i, -, hi⟩ := Finset.exists_mem_eq_inf' (hrange n) b
            rw [hi]; exact (hbB i).1
          · intro n
            dsimp only
            obtain ⟨i, -, hi⟩ := Finset.exists_mem_eq_inf' (hrange n) b
            rw [hi]; exact (hbB i).2
          · intro n m hnm
            dsimp only
            exact Finset.inf'_mono b (Finset.range_mono (Nat.succ_le_succ hnm)) _
          · intro i n hin
            dsimp only
            exact Finset.inf'_le b (Finset.mem_range.mpr (Nat.lt_succ_of_le hin))
        refine ⟨Set.range (fun n => TaskFrame.Seg F.TaskRel (τ.states (A' n) (hA'dom n))
            (τ.states (B' n) (hB'dom n)) (z - A' n) (B' n - z)), ?_, ⟨⟨_, ⟨0, rfl⟩⟩, ?_⟩, ?_⟩
        · rintro c ⟨n, rfl⟩
          exact mem_Constraints.mpr
            (Or.inl ⟨A' n, B' n, hA'dom n, hB'dom n, hA'lt n, hB'gt n, rfl⟩)
        · rintro c₁ ⟨n, rfl⟩ c₂ ⟨m, rfl⟩ -
          rcases le_total n m with h | h
          · exact Or.inr (seg_subset_seg_of_compositional hcomp hlim (hA'dom n) (hB'dom n)
              (hA'dom m) (hB'dom m) (hA'mono n m h) (le_of_lt (hA'lt m)) (le_of_lt (hB'gt m))
              (hB'anti n m h))
          · exact Or.inl (seg_subset_seg_of_compositional hcomp hlim (hA'dom m) (hB'dom m)
              (hA'dom n) (hB'dom n) (hA'mono m n h) (le_of_lt (hA'lt n)) (le_of_lt (hB'gt n))
              (hB'anti m n h))
        · rintro c (⟨t, s, ht, hs, htz, hzs, rfl⟩ | ⟨t, ht, hnp, rfl⟩)
          · have hta : t ∈ Set.range a := by rw [← ha]; exact ⟨ht, htz⟩
            have hsb : s ∈ Set.range b := by rw [← hb]; exact ⟨hs, hzs⟩
            obtain ⟨i, rfl⟩ := hta
            obtain ⟨j, rfl⟩ := hsb
            refine ⟨_, ⟨max i j, rfl⟩, ?_⟩
            exact seg_subset_seg_of_compositional hcomp hlim ht hs (hA'dom _) (hB'dom _)
              (hA'ge i _ (le_max_left i j)) (le_of_lt (hA'lt _)) (le_of_lt (hB'gt _))
              (hB'le j _ (le_max_right i j))
          · exfalso
            refine hnp ?_
            rcases lt_trichotomy t z with h | h | h
            · exact Or.inl ⟨h, ⟨s₀, hs₀, hzs₀⟩⟩
            · exact absurd (h ▸ ht) hz
            · exact Or.inr ⟨h, ⟨t₀, ht₀, ht₀z⟩⟩
      · -- One-sided domain, all of it above `z`: fibers only, a chain by the primed lemma.
        have hmem : ∀ c ∈ Constraints τ z, ∃ (t : F.Duration) (ht : τ.domain t), z ≤ t ∧
            c = TaskFrame.Fib F.TaskRel (τ.states t ht) (z - t) := by
          rintro c (⟨t, s, ht, hs, htz, hzs, rfl⟩ | ⟨t, ht, -, rfl⟩)
          · exact absurd ⟨t, ht, htz⟩ hA
          · refine ⟨t, ht, ?_, rfl⟩
            rcases lt_trichotomy t z with h | h | h
            · exact absurd ⟨t, ht, h⟩ hA
            · exact absurd (h ▸ ht) hz
            · exact le_of_lt h
        refine ⟨Constraints τ z, subset_rfl, ⟨nonempty_Constraints τ z, ?_⟩,
          fun c hc => ⟨c, hc, subset_rfl⟩⟩
        rintro c₁ h₁ c₂ h₂ -
        obtain ⟨t₁, ht₁, hzt₁, rfl⟩ := hmem c₁ h₁
        obtain ⟨t₂, ht₂, hzt₂, rfl⟩ := hmem c₂ h₂
        rcases le_total t₁ t₂ with h | h
        · exact Or.inl (fib_subset_fib_of_compositional' hcomp hlim ht₂ ht₁ h hzt₁)
        · exact Or.inr (fib_subset_fib_of_compositional' hcomp hlim ht₁ ht₂ h hzt₂)
    · -- One-sided domain, all of it below `z`: fibers only, a chain by the unprimed lemma.
      have hmem : ∀ c ∈ Constraints τ z, ∃ (t : F.Duration) (ht : τ.domain t), t ≤ z ∧
          c = TaskFrame.Fib F.TaskRel (τ.states t ht) (z - t) := by
        rintro c (⟨t, s, ht, hs, htz, hzs, rfl⟩ | ⟨t, ht, -, rfl⟩)
        · exact absurd ⟨s, hs, hzs⟩ hB
        · refine ⟨t, ht, ?_, rfl⟩
          rcases lt_trichotomy t z with h | h | h
          · exact le_of_lt h
          · exact absurd (h ▸ ht) hz
          · exact absurd ⟨t, ht, h⟩ hB
      refine ⟨Constraints τ z, subset_rfl, ⟨nonempty_Constraints τ z, ?_⟩,
        fun c hc => ⟨c, hc, subset_rfl⟩⟩
      rintro c₁ h₁ c₂ h₂ -
      obtain ⟨t₁, ht₁, ht₁z, rfl⟩ := hmem c₁ h₁
      obtain ⟨t₂, ht₂, ht₂z, rfl⟩ := hmem c₂ h₂
      rcases le_total t₁ t₂ with h | h
      · exact Or.inr (fib_subset_fib_of_compositional hcomp ht₁ ht₂ h ht₂z)
      · exact Or.inl (fib_subset_fib_of_compositional hcomp ht₂ ht₁ h ht₁z)

/--
**The headline.** Over any history with countably many times — automatic for `ℤ`-time and
`ℚ`-time, since every subset of `ℤ` or of `ℚ` is countable — the nest condition `S₁` buys exactly
what `S₁ᵈ` buys at `lem:step`.

So the answer to "is the `⇒`-directed form forced?" is **no, not over any carrier this development
instantiates**. The directedness of `def:frame`'s fourth constraint is therefore *not* a tightness
requirement that the extension theorem extracts; it is kept on the naturalness criterion — the
geometry `⇒` induces on `W` has no gaps, and a `⊇`-directed system of balls is the form that
condition takes when it is stated about the geometry rather than about one construction's index
set. This theorem is the sharpness result that records the fact, not a case for weakening
`def:frame`.

What it does **not** say: nothing here establishes `S₁ → S₁ᵈ` at the frame level. That implication
is false in the shape one would first try to state it, and the counterexample space for it lives
over non-archimedean carriers of uncountable coinitiality, outside this development.

Paper: — (the manuscript has no anchor for the nest reduction)
-/
theorem sInter_constraints_nonempty_of_countable
    (hS1 : TaskFrame.NestSaturation F.TaskRel) (hcomp : TaskFrame.Compositional F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel)
    (τ : PartialHistory F) (z : F.Duration)
    (hne : ∀ c ∈ Constraints τ z, c.Nonempty)
    (hcount : {t : F.Duration | τ.domain t}.Countable) :
    (⋂₀ Constraints τ z).Nonempty :=
  sInter_constraints_nonempty_of_nestSaturation hS1 τ z hne
    (hasCofinalNest_of_countable hcomp hlim τ z hcount)

/-- Acceptance test: the countability hypothesis is free over `ℤ`-time, since every subset of `ℤ`
is countable. -/
example (X : Set ℤ) : X.Countable := X.to_countable

/-- Acceptance test: the countability hypothesis is free over `ℚ`-time too, so both instantiated
carriers are covered with no hypothesis on `D` at all. -/
example (X : Set ℚ) : X.Countable := X.to_countable

end PartialHistory

end FormalSystem.Semantics
