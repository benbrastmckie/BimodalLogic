/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame

/-!
# PartialHistory — the paper's partial-history layer

This module lands the layer the JPL paper puts *below* convex histories: a partial history is a
task-respecting function on a **nonempty** subset of the duration type, with **no** convexity
requirement. `ConvexHistory` is the convex special case (see `FormalSystem/Semantics/ConvexHistory.lean`).

## Paper Specification Reference

**`def:world-history`**, quoted verbatim from `docs/reference/paper-definitions-of-record.md` (which is what
this repository cites — never the paper file directly, and never by line number):

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

The paper's three tiers are therefore *partial history* -> *convex history* -> *possible world*,
and "history" is the generic term for all three wherever the distinction is immaterial. The tier
this module defines is the first; the middle tier is `ConvexHistory` and the top tier is
`TaskFrame.HF`. The name this repository previously gave the middle tier was one tier too high,
which is exactly what the `ConvexHistory` rename corrects. The `def:world-history` label id
survives only for cross-reference stability across the paper's own `\ref` sites.

## Two transcription decisions, both settled and recorded

Both are recorded in `docs/architecture/total-history-validity-decisions.md` (Decision B) so that
they are not re-litigated here or in the four-axiom frame alignment work.

1. **Nonemptiness is a field, not a side hypothesis.** The paper requires the domain `X` to be
   nonempty *for a partial history*. Carrying it as data is what makes the Extension Theorem's
   hypothesis a faithful transcription rather than an empty-case argument the paper never makes.
2. **`respects_task` is stated unconditionally** — "for all times `x, y ∈ X`", with no `s ≤ t`
   guard. This is the form the Fiber and Admissibility lemmas consume, both of which are stated
   with no sign proviso. The paper's **converse convention** is the justification:
   `def:task-relation` extends the task relation to negative durations by
   `$w \Rightarrow_{-x} u \coloneq u \Rightarrow_{x} w$ for $x \geq 0$`, so the
   negative-difference instances of `$\tau(x) \Rightarrow_{y-x} \tau(y)$` are *covered by the
   converse convention*, i.e. by `FrameOver.converse`, and the unconditional statement is not a
   strengthening of the paper's requirement — it is the paper's requirement, read as written.
   (`def:world-history` formerly carried an inline `%` gloss saying exactly this, which this
   docstring used to block-quote; the paper has since deleted that gloss, and the convention it
   restated lives on at `def:task-relation`.)

   The guarded form is *derived* here as `respects_task_le`, and `PartialHistory.ofLe` is a smart
   constructor letting a site that already has a guarded proof discharge the unconditional field.

## Main Definitions

- `PartialHistory F` — the structure: `domain`, `nonempty_domain`, `states`, `respects_task`
- `PartialHistory.IsTotal` — the paper's totality predicate, `∀ t : D, τ.domain t`
- `PartialHistory.Extends` — the paper's extension relation (domain inclusion + state agreement)
- `PartialHistory.ofLe` — smart constructor from a guarded task-respect proof

## Main Results

- `PartialHistory.respects_task_le` — the guarded form, derived from the unconditional field
- `PartialHistory.total_nonempty` — totality implies the nonemptiness field is derivable

## Implementation Notes

- Nothing imports this module yet; it is self-contained new material. `ConvexHistory` is re-based
  onto it in a subsequent step.
- The type-parameter discipline (`D` with `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`)
  matches `ConvexHistory` exactly, so the re-basing is a structural change only.

## Tags

partial-history · convex-history · convexity
-/

namespace FormalSystem.Semantics

/--
A **partial history** over a task frame `F`: a task-respecting state assignment on a nonempty
set of times, with **no** convexity requirement.

**Paper Reference**: `def:world-history` (verbatim: "A \textit{partial history} over a task frame
$\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ on a nonempty set
$X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$.").

The paper's `\textit{convex history}` is the **convex** special case of this structure; see
`FormalSystem.Semantics.ConvexHistory`.
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

This is the shape `ConvexHistory.respects_task` has historically carried. It is a projection, not a
weakening: the unconditional field simply ignores the `s ≤ t` hypothesis.
-/
theorem respects_task_le (τ : PartialHistory F) (s t : F.Duration) (hs : τ.domain s) (ht : τ.domain t)
    (_hst : s ≤ t) : F.TaskRel (τ.states s hs) (t - s) (τ.states t ht) :=
  τ.respects_task s t hs ht

/--
Smart constructor: build a `PartialHistory` from a **guarded** task-respect proof.

The unconditional `respects_task` field is discharged from the guarded proof plus
`FrameOver.converse`: when `t < s`, the guarded proof gives `TaskRel (states t) (s - t) (states s)`,
and the converse convention turns that into `TaskRel (states s) (-(s - t)) (states t)`, which is
`TaskRel (states s) (t - s) (states t)` by `neg_sub`.

**This is a proof-convenience constructor, not a compatibility shim.** It introduces no second
history type, no second validity notion, and no alias of any API surface — it is one
lemma-shaped constructor over the single `PartialHistory` structure, and it exists precisely
because the paper's own `%` comment at `def:world-history` says the negative-difference instances
are *covered by the converse convention* rather than separately required.
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
      have hc := (F.converse (states t ht) (s - t) (states s hs)).mp h
      rwa [neg_sub] at hc

/--
The paper's **totality** predicate.

**Paper Reference**: `def:world-history` (verbatim: "A \textit{possible world} is any convex
history whose domain is total, so that $X = D$.").

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

end PartialHistory

end FormalSystem.Semantics
