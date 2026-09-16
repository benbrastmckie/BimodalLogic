/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame

/-!
# PartialHistory — the history layer of task semantics

This module defines the one history structure the semantics uses. A *partial history* is a
task-respecting function on a **nonempty** set of durations; a *world history* is a partial
history whose domain is **total**; and `WorldHistory` is the set of world histories. Truth,
validity and every consumer range over `PartialHistory F`, cut down to `H_F` either by an
`IsTotal` hypothesis or by the `WorldHistory` subtype. Convexity is a predicate
(`PartialHistory.IsConvex`), not a separate structure.

## Paper Specification Reference

The paper's body (sec:Construction) defines the tiers this module follows: "A \textit{world
history} is any partial history $\tau : X \to W$ whose domain is \textit{total}, so that $X = D$",
and writes $H_{\F}$ for "the set of all world histories defined over the task frame $\F$",
adding that "I will also refer to $H_{\F}$ as the set of \textit{possible worlds}."

**`def:world-history`** (the appendix definition), quoted verbatim from
`docs/reference/paper-definitions-of-record.md` (which is what this repository cites — never the
paper file directly, and never by line number):

> `A \textit{partial history} over a task frame $\F = \tuple{W, \D, \Rightarrow}$ is a function
> $\tau : X \to W$ on a nonempty set $X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for
> all times $x, y \in X$.`
>
> `A \textit{convex history} is any partial history whose domain $X$ is \textit{convex}, so that
> $y \in X$ whenever $x, z \in X$ and $x < y < z$.`
>
> `A \textit{possible world} is any convex history whose domain is total, so that $X = D$.`
>
> `A partial history $\sigma$ \textit{extends} $\tau$ just in case
> $\dom{\tau} \subseteq \dom{\sigma}$ and $\tau(x) = \sigma(x)$ for all $x \in \dom{\tau}$.`
>
> `The set of all possible worlds over $\F$ is denoted $H_{\F}$.`

**The appendix and the body denote the same set.** The appendix routes the top tier through
convex histories, the body does not; a total domain is trivially convex
(`PartialHistory.IsTotal.isConvex`), so "convex history with total domain" and "partial history
with total domain" pick out exactly the same histories. The Lean definition follows the body:

| Paper | Lean |
|-------|------|
| partial history | `PartialHistory F` |
| convex history | `τ : PartialHistory F` with `τ.IsConvex` |
| world history (possible world) | `τ : PartialHistory F` with `τ.IsTotal`; bundled as `WorldHistory` |
| `H_F` | `WorldHistory` |

There is deliberately no `ConvexHistory` structure and no `abbrev WorldHistory`: no proof consumes
convexity as a hypothesis, and `WorldHistory` is already the name of the top tier. The layering decision is
recorded in `docs/architecture/total-history-validity-decisions.md`, Decision B'.

## Two transcription decisions, both settled and recorded

Both are recorded in `docs/architecture/total-history-validity-decisions.md` (Decision B) so that
they are not re-litigated here or in the four-axiom frame alignment work.

1. **Nonemptiness is a field, not a side hypothesis.** The paper requires the domain `X` to be
   nonempty *for a partial history*. Carrying it as data is what makes the Extension Theorem's
   hypothesis a faithful transcription rather than an empty-case argument the paper never makes.
2. **`respects_task` is stated unconditionally** — "for all times `x, y ∈ X`", with no `s ≤ t`
   guard. This is the form the Fiber and Admissibility lemmas consume, both of which are stated
   with no sign proviso. The paper's **reflection convention** is the justification:
   `def:task-relation` extends the task relation to negative durations by
   `$w \Rightarrow_{-x} u \coloneq u \Rightarrow_{x} w$ for $x \geq 0$`, so the
   negative-difference instances of `$\tau(x) \Rightarrow_{y-x} \tau(y)$` are *covered by the
   reflection convention*, i.e. by `FrameOver.reflection`, and the unconditional statement is not a
   strengthening of the paper's requirement — it is the paper's requirement, read as written.
   (`def:world-history` formerly carried an inline `%` gloss saying exactly this, which this
   docstring used to block-quote; the paper has since deleted that gloss, and the convention it
   restated lives on at `def:task-relation`.)

   The guarded form is *derived* here as `respects_task_le`, and `PartialHistory.ofLe` is a smart
   constructor letting a site that already has a guarded proof discharge the unconditional field.

## Main Definitions

- `PartialHistory F` — the structure: `domain`, `nonempty_domain`, `states`, `respects_task`
- `PartialHistory.IsTotal` — the paper's totality predicate, `∀ t : D, τ.domain t`
- `PartialHistory.IsConvex` — the paper's convexity predicate on the domain
- `PartialHistory.Extends` — the paper's extension relation (domain inclusion + state agreement)
- `PartialHistory.ofLe` — smart constructor from a guarded task-respect proof
- `PartialHistory.timeShift` — time shift on partial histories
- `PartialHistory.ofTotal` — the total history of a bare state function
- `WorldHistory` — the paper's `H_F`, the world histories bundled as a subtype

## Main Results

- `PartialHistory.respects_task_le` — the guarded form, derived from the unconditional field
- `PartialHistory.total_nonempty` — totality implies the nonemptiness field is derivable
- `PartialHistory.IsTotal.isConvex` — a world history is convex
- `PartialHistory.isTotal_timeShift` / `isConvex_timeShift` — both predicates survive time shift

## Tags

partial-history · world-history · totality · convexity · def:world-history
-/

namespace FormalSystem.Semantics

/--
A **partial history** over a task frame `F`: a task-respecting state assignment on a nonempty
set of times, with **no** convexity requirement.

**Paper Reference**: `def:world-history` (verbatim: "A \textit{partial history} over a task frame
$\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ on a nonempty set
$X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$.").

The paper's *convex history* is a partial history satisfying `IsConvex`, and its *world history*
is one satisfying `IsTotal`; neither is a separate structure.
-/
structure PartialHistory (F : TaskFrame) where
  /-- Domain predicate: which times are in the history, i.e. the paper's `X ⊆ D`. -/
  domain : F.Duration → Prop
  /--
  Nonemptiness of the domain, carried as **data** rather than as a side hypothesis.

  **Paper Reference**: `def:world-history` requires the domain to be "a nonempty set
  $X \subseteq D$". Carrying it as a field is what makes the Extension Theorem's hypothesis a
  faithful transcription; see this module's docstring, decision 1.
  -/
  nonempty_domain : ∃ t, domain t
  /-- State assignment: the paper's function `τ : X → W`. -/
  states : (t : F.Duration) → domain t → F.WorldState
  /--
  Task-respect, stated **unconditionally** — for *all* pairs of times in the domain, with no
  `s ≤ t` guard.

  **Paper Reference**: `def:world-history` (verbatim: "$\tau(x) \Rightarrow_{y-x} \tau(y)$ for all
  times $x, y \in X$"), together with the paper's own clarifying comment at that site: "Since the
  difference $y - x$ is negative whenever $y < x$, these instances are covered by the converse
  convention: $\tau(x) \Rightarrow_{y-x} \tau(y)$ then reads $\tau(y) \Rightarrow_{x-y} \tau(x)$."

  The unconditional form is what the Fiber and Admissibility lemmas consume — both are stated with
  no sign proviso. The guarded form is derived as `respects_task_le`; `ofLe` converts a guarded
  proof into this field.
  -/
  respects_task : ∀ (s t : F.Duration) (hs : domain s) (ht : domain t),
    F.TaskRel (states s hs) (t - s) (states t ht)

namespace PartialHistory

variable {F : TaskFrame}

/--
The guarded form of task-respect, **derived** from the unconditional field.

This is the shape `PartialHistory.respects_task` has historically carried. It is a projection, not a
weakening: the unconditional field simply ignores the `s ≤ t` hypothesis.
-/
theorem respects_task_le (τ : PartialHistory F) (s t : F.Duration) (hs : τ.domain s) (ht : τ.domain t)
    (_hst : s ≤ t) : F.TaskRel (τ.states s hs) (t - s) (τ.states t ht) :=
  τ.respects_task s t hs ht

/--
Smart constructor: build a `PartialHistory` from a **guarded** task-respect proof.

The unconditional `respects_task` field is discharged from the guarded proof plus
`FrameOver.reflection`: when `t < s`, the guarded proof gives `TaskRel (states t) (s - t) (states s)`,
and the reflection convention turns that into `TaskRel (states s) (-(s - t)) (states t)`, which is
`TaskRel (states s) (t - s) (states t)` by `neg_sub`.

**This is a proof-convenience constructor, not a compatibility shim.** It introduces no second
history type, no second validity notion, and no alias of any API surface — it is one
lemma-shaped constructor over the single `PartialHistory` structure, and it exists precisely
because the paper's own `%` comment at `def:world-history` says the negative-difference instances
are *covered by the reflection convention* rather than separately required.
-/
def ofLe (domain : F.Duration → Prop) (nonempty_domain : ∃ t, domain t)
    (states : (t : F.Duration) → domain t → F.WorldState)
    (respects_le : ∀ (s t : F.Duration) (hs : domain s) (ht : domain t),
      s ≤ t → F.TaskRel (states s hs) (t - s) (states t ht)) :
    PartialHistory F where
  domain := domain
  nonempty_domain := nonempty_domain
  states := states
  respects_task := by
    intro s t hs ht
    rcases le_total s t with hst | hts
    · exact respects_le s t hs ht hst
    · have h := respects_le t s ht hs hts
      have hc := (F.reflection (states t ht) (s - t) (states s hs)).mp h
      rwa [neg_sub] at hc

/--
The paper's **totality** predicate: `τ.IsTotal` says that `τ` is a *world history*.

**Paper Reference**: sec:Construction (verbatim: "A \textit{world history} is any partial history
$\tau : X \to W$ whose domain is \textit{total}, so that $X = D$."); the appendix
`def:world-history` phrases the same set as convex histories with total domain, which coincide
since a total domain is convex (`IsTotal.isConvex`).

Note that this is `∀ t, τ.domain t` — the domain *is* all of `D` — and is deliberately **not**
Mathlib's `IsMax` or any order-theoretic maximality predicate. Maximality under the extension
order appears only as an internal step en route to the Extension Theorem; totality is what
validity quantifies over. See `docs/architecture/total-history-validity-decisions.md`, Decision A.
-/
def IsTotal (τ : PartialHistory F) : Prop := ∀ t : F.Duration, τ.domain t

/--
The paper's **extension** relation on partial histories: `Extends σ τ` says that `σ` extends `τ`.

**Paper Reference**: `def:world-history` (verbatim: "A partial history $\sigma$ \textit{extends}
$\tau$ just in case $\dom{\tau} \subseteq \dom{\sigma}$ and $\tau(x) = \sigma(x)$ for all
$x \in \dom{\tau}$.").
-/
structure Extends (σ τ : PartialHistory F) : Prop where
  /-- Domain inclusion: `dom τ ⊆ dom σ`. -/
  subset : ∀ t, τ.domain t → σ.domain t
  /-- State agreement on the smaller domain: `τ(x) = σ(x)` for all `x ∈ dom τ`. -/
  agree : ∀ (t : F.Duration) (ht : τ.domain t), σ.states t (subset t ht) = τ.states t ht

/--
Totality implies the nonemptiness field is derivable, with `0 : D` as the witness.

This is why nonemptiness costs nothing at a total construction site, and why carrying it as a
field (this module's docstring, decision 1) is not a burden on the sites that matter.
-/
theorem total_nonempty (τ : PartialHistory F) (h : τ.IsTotal) : ∃ t : F.Duration, τ.domain t :=
  ⟨0, h 0⟩

/--
Standalone form of `total_nonempty`, usable at a **construction** site — where the structure does
not yet exist, so `total_nonempty` cannot be applied to it.

Typical use: a site with `domain := fun _ => True` discharges `nonempty_domain` by
`nonempty_of_total (fun _ => trivial)`, or directly by `⟨0, trivial⟩`.
-/
theorem nonempty_of_total {D : Type} [AddCommGroup D] [Nontrivial D] {dom : D → Prop}
    (h : ∀ t : D, dom t) : ∃ t : D, dom t :=
  ⟨0, h 0⟩

/-! ## Transport of states along equal times -/

/--
States are equal when the times are provably equal (dependent transport).

Needed because `states` is dependent on a domain proof, so `rw`-ing a time equality inside a
`states` application requires an explicit transport lemma.
-/
theorem states_eq_of_time_eq (τ : PartialHistory F) (t₁ t₂ : F.Duration) (h : t₁ = t₂)
    (h₁ : τ.domain t₁) (h₂ : τ.domain t₂) : τ.states t₁ h₁ = τ.states t₂ h₂ := by
  subst h; rfl

/-! ## Convexity -/

/--
The paper's **convexity** predicate on a partial history's domain: no temporal gaps.

**Paper Reference**: `def:world-history` (verbatim: "A \textit{convex history} is any partial
history whose domain $X$ is \textit{convex}, so that $y \in X$ whenever $x, z \in X$ and
$x < y < z$."). The predicate reads `≤` on both sides where the paper has `<`; the two are
equivalent, since the endpoints `x`, `z` are in the domain by hypothesis.

Convexity is kept as a predicate, not as a structure: no proof in the library consumes it as a
hypothesis, and every history that truth and validity range over is total, hence convex by
`IsTotal.isConvex`.
-/
def IsConvex (τ : PartialHistory F) : Prop :=
  ∀ (x z : F.Duration), τ.domain x → τ.domain z → ∀ (y : F.Duration), x ≤ y → y ≤ z → τ.domain y

/-- A total partial history is convex: every time is in its domain. -/
theorem IsTotal.isConvex {τ : PartialHistory F} (h : τ.IsTotal) : τ.IsConvex :=
  fun _ _ _ _ y _ _ => h y

/-! ## Time shift -/

/--
Time-shifted partial history: `(τ.timeShift Δ)` is `τ` viewed `Δ` later, i.e. its domain at `z`
is `τ`'s domain at `z + Δ`, and `(τ.timeShift Δ).states z = τ.states (z + Δ)`.

**Paper Reference**: `def:time-shift-histories` defines the relation `τ ≈ σ` between world
histories (`τ(z) = σ(z + y - x)` for all `z`), and `app:auto_existence` asserts that the shifted
world history exists. This construction is the Lean witness for that existence, stated on
**arbitrary** partial histories (nothing about the shift needs totality); `isTotal_timeShift`
below is the paper's "total since 𝔇 is a group". The relation itself, read on arbitrary histories,
is `TimeShift.ShiftRel` in `TruthTransport.lean`.

`nonempty_domain` transports by `t ↦ t - Δ`, and task-respect is preserved because the task
relation depends only on the duration `t - s`, which translation leaves unchanged.
-/
def timeShift (τ : PartialHistory F) (Δ : F.Duration) : PartialHistory F where
  domain := fun z => τ.domain (z + Δ)
  nonempty_domain := by
    obtain ⟨t, ht⟩ := τ.nonempty_domain
    refine ⟨t - Δ, ?_⟩
    rwa [sub_add_cancel]
  states := fun z hz => τ.states (z + Δ) hz
  respects_task := by
    intro s t hs ht
    have h_duration : (t + Δ) - (s + Δ) = t - s := by rw [add_sub_add_right_eq_sub]
    rw [← h_duration]
    exact τ.respects_task (s + Δ) (t + Δ) hs ht

@[simp]
theorem timeShift_domain (τ : PartialHistory F) (Δ z : F.Duration) :
    (τ.timeShift Δ).domain z ↔ τ.domain (z + Δ) := Iff.rfl

/--
Totality is preserved by time shift.

The proof is `fun t => h (t + Δ)`: the shifted domain at `t` *is* the original domain at
`t + Δ`, definitionally, so a total original domain gives a total shifted domain with no
side condition whatsoever. This is the lemma that carries the box case of time-shift
preservation of truth.
-/
theorem isTotal_timeShift {τ : PartialHistory F} (h : τ.IsTotal) (Δ : F.Duration) :
    (τ.timeShift Δ).IsTotal :=
  fun t => h (t + Δ)

/-- Convexity is preserved by time shift: translation is monotone. -/
theorem isConvex_timeShift {τ : PartialHistory F} (h : τ.IsConvex) (Δ : F.Duration) :
    (τ.timeShift Δ).IsConvex :=
  fun x z hx hz y hxy hyz =>
    h (x + Δ) (z + Δ) hx hz (y + Δ) (add_le_add_left hxy Δ) (add_le_add_left hyz Δ)

/-! ## Total histories from a bare state function -/

/--
**The total partial history determined by a bare state function.**

A *total* history's domain is all of `D`, so `nonempty_domain` carries no information and the
dependent `states` field collapses to a plain `f : F.Duration → F.WorldState`. The only genuine
obligation left is `respects_task`. This is that four-field skeleton, written once.

**Use `ofTotal` in preference to a literal `domain := fun _ => True` record.** Besides the line
saving, it is what makes `ofTotal_states` available, so `simp` closes the domain bridge that a
hand-written record forces each call site to open by hand.
-/
def ofTotal (F : TaskFrame) (f : F.Duration → F.WorldState)
    (h : ∀ s t : F.Duration, F.TaskRel (f s) (t - s) (f t)) : PartialHistory F where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  states := fun t _ => f t
  respects_task := fun s t _ _ => h s t

/-- `ofTotal` is total: its domain is all of `F.Duration` by construction. -/
theorem ofTotal_isTotal (F : TaskFrame) (f : F.Duration → F.WorldState)
    (h : ∀ s t : F.Duration, F.TaskRel (f s) (t - s) (f t)) : (ofTotal F f h).IsTotal :=
  fun _ => trivial

/--
**The domain bridge, as a simp lemma.**

`ofTotal`'s domain is all of `F.Duration`, so any domain obligation on it is `True`. Marking this
`@[simp]` is what lets a downstream `simp` discharge a domain side-goal that a hand-written
`domain := fun _ => True` record leaves it unable to see through.
`Decidability/Propositional/Decidable.lean`'s `trivial_truth_iff` is the worked demonstration.
-/
@[simp] theorem ofTotal_domain (F : TaskFrame) (f : F.Duration → F.WorldState)
    (h : ∀ s t : F.Duration, F.TaskRel (f s) (t - s) (f t)) (t : F.Duration) :
    (ofTotal F f h).domain t ↔ True := Iff.rfl

/--
**The load-bearing simp lemma of the construction.**

With `domain := fun _ => True` the domain proof carries no information, so reading `ofTotal`'s
state at *any* domain witness gives `f t` by `rfl`.
-/
@[simp] theorem ofTotal_states (F : TaskFrame) (f : F.Duration → F.WorldState)
    (h : ∀ s t : F.Duration, F.TaskRel (f s) (t - s) (f t)) (t : F.Duration)
    (ht : (ofTotal F f h).domain t) : (ofTotal F f h).states t ht = f t := rfl

/--
The constant total history of the trivial frame.

The trivial frame's task relation always holds, so the constant history respects it. Named
`trivialFrameHistory` rather than `trivial` so that it does not shadow the root `trivial` term
inside `namespace PartialHistory`.
-/
def trivialFrameHistory {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] : PartialHistory (FrameOver.trivialFrame (D := D)) :=
  ofTotal (FrameOver.trivialFrame (D := D)).toTaskFrame (fun _ => ())
    fun _ _ => FrameOver.trivialFrame_taskRel.mpr True.intro

end PartialHistory

/-! ## `H_F`: the world histories of a frame -/

/--
`WorldHistory F` — the paper's set `H_F` of all **world histories** (possible worlds) over a
frame, bundled as a type: the partial histories whose domain is total.

**Paper Reference**: sec:Construction defines a world history as a partial history whose domain
is total, `X = D`, and writes `H_F` for the set of them (the appendix `def:world-history` phrases
the same set as the *convex* histories with total domain; a total domain is trivially convex, so
the two readings denote the same set — see `PartialHistory.IsTotal.isConvex`).

`PartialHistory.IsTotal` stays the one defining predicate: this is its subtype, not a second
history structure, and `.val` / `.property` are the projections back to it. It is a `def` rather
than an `abbrev` so that `Subtype` instances and simp lemmas do not leak onto it; `state` below is
the non-dependent accessor that truth reads.
-/
def WorldHistory (F : TaskFrame) : Type _ :=
  {τ : PartialHistory F // τ.IsTotal}

namespace WorldHistory

variable {F : TaskFrame}

/-- A world history *is* a partial history: forget the totality proof. -/
instance : CoeOut (WorldHistory F) (PartialHistory F) := ⟨Subtype.val⟩

/--
The state of a world history at a time — the paper's `τ(x)`, read with no domain proof.

Totality supplies the domain witness, so the dependent `PartialHistory.states` collapses to a plain
function of the time. This is the simp normal form: `states_eq_state` rewrites every dependent
projection toward it.
-/
def state (τ : WorldHistory F) (t : F.Duration) : F.WorldState :=
  τ.val.states t (τ.property t)

/-- **Proof irrelevance of the domain witness**: the dependent projection at *any* witness is the
bundled `state`. -/
@[simp]
theorem states_eq_state (τ : WorldHistory F) (t : F.Duration) (h : τ.val.domain t) :
    τ.val.states t h = τ.state t := rfl

/-- Two world histories are equal when their underlying partial histories are. -/
@[ext]
theorem ext {τ σ : WorldHistory F} (h : τ.val = σ.val) : τ = σ :=
  Subtype.ext h

/-- The state of a world history at provably equal times. -/
theorem state_congr (τ : WorldHistory F) {s t : F.Duration} (h : s = t) :
    τ.state s = τ.state t := by
  subst h; rfl

/--
**The bundled form of `PartialHistory.ofTotal`**: the world history determined by a bare state
function.

`WorldHistory F`'s elements are exactly the total histories, and `ofTotal` builds nothing else, so
a construction that needs a world history need never assemble the subtype pair by hand.
-/
def ofTotal (F : TaskFrame) (f : F.Duration → F.WorldState)
    (h : ∀ s t : F.Duration, F.TaskRel (f s) (t - s) (f t)) : WorldHistory F :=
  ⟨PartialHistory.ofTotal F f h, PartialHistory.ofTotal_isTotal F f h⟩

@[simp]
theorem ofTotal_state (F : TaskFrame) (f : F.Duration → F.WorldState)
    (h : ∀ s t : F.Duration, F.TaskRel (f s) (t - s) (f t)) (t : F.Duration) :
    (ofTotal F f h).state t = f t := rfl

@[simp]
theorem ofTotal_val (F : TaskFrame) (f : F.Duration → F.WorldState)
    (h : ∀ s t : F.Duration, F.TaskRel (f s) (t - s) (f t)) :
    (ofTotal F f h).val = PartialHistory.ofTotal F f h := rfl

/-- Time shift lifted to world histories, through `PartialHistory.isTotal_timeShift`. -/
def timeShift (τ : WorldHistory F) (Δ : F.Duration) : WorldHistory F :=
  ⟨τ.val.timeShift Δ, PartialHistory.isTotal_timeShift τ.property Δ⟩

@[simp]
theorem timeShift_state (τ : WorldHistory F) (Δ t : F.Duration) :
    (τ.timeShift Δ).state t = τ.state (t + Δ) := rfl

@[simp]
theorem timeShift_val (τ : WorldHistory F) (Δ : F.Duration) :
    (τ.timeShift Δ).val = τ.val.timeShift Δ := rfl

end WorldHistory

end FormalSystem.Semantics
