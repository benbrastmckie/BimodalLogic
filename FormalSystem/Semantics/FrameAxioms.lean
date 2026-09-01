/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PartialHistory
import Mathlib.Data.Set.Lattice

/-!
# The derived nullity lemma, and the constraints imposed on a new duration

This module derives `lem:nullity` from *Seriality* and *Limit*, transcribes `def:constraints`,
and proves the fiber/segment classification lemmas that `def:constraints` supports.

## Where the axiom predicates live

*Spherical*, *Seriality*, and the interpolation half of *Compositionality* are `Prop`-valued
predicates over a **bare task relation** `R : W → D → W → Prop`, and are declared in
`Semantics/TaskFrame.lean` **above** the `ParamTaskFrame` structure — a structure field's type may
only mention earlier declarations, so that is where they must live for the fields to cite them.
This module consumes them.

## The fields, and the invariant they were held to

`ParamTaskFrame` now carries all four of `def:frame`'s axioms: `comp` (the full biconditional
*Compositionality*, as `TaskFrame.Compositional TaskRel`), `serial`, `limit`, and `spherical`.
The hard invariant recorded in `specs/decisions/total-history-validity-decisions.md` (the
four-axiom frame-alignment decision) was met: `ParamTaskFrame.spherical` is *definitionally*
`Spherical TaskRel`, `ParamTaskFrame.serial` is definitionally `Serial TaskRel`, and the
interpolation half of biconditional *Compositionality* is available as `ParamTaskFrame.interpolates`,
definitionally `Interpolates TaskRel`. Discharging a downstream hypothesis is therefore a
mechanical substitution (`F.spherical`, `F.serial`, `F.interpolates`) with zero restatement; a
field whose statement differed would make the results that consume these predicates stop
typechecking, and that compilation failure *is* the acceptance test.

The bare-relation form is retained alongside the fields on purpose: results that need only one
axiom take exactly that axiom as an explicit hypothesis, and remain applicable to a relation
that is not (yet) packaged as a frame.

*Spherical* in particular must be literally the hypothesis the Step Lemma's proof consumes at the
sole application site the paper names, never an inert structure field.

## Paper Specification Reference

Anchors below are `\label` keys into `specs/paper-definitions-of-record.md`, which — not the
paper source — is the citation source of record.

- *Compositionality* (`def:frame#Compositionality`, verbatim): "$w \Rightarrow_{x + y} v$ if and
  only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$."
- *Seriality* (`def:frame#Seriality`, verbatim): "$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for
  some $u, v \in W$."
- *Limit* (`def:frame#Limit`, verbatim): "$\bigcap\limits_{x > 0} (w)_x = \set{w}$."
- *Spherical* (`def:frame#Spherical`, verbatim): "$\bigcap \mathcal{S} \neq \emptyset$ for any
  $\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments."
- `def:directed`, the `$\supseteq$` clause (verbatim): "\item[\bf $\mathbf{\supseteq}$-Directed:]
  just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever
  $S_1, S_2 \in \mathcal{S}$." The paper split `def:directed` into a `$\supseteq$-Directed` and a
  `$\subseteq$-Directed` clause; *Spherical*, and hence `DirectedFamily`, consumes the
  `$\supseteq$` half only. The enclosing definition still opens "A nonempty family of sets
  $\mathcal{S}$ is:", which is where the family's own nonemptiness comes from."
- `lem:nullity` (verbatim): "$w \Rightarrow_0 w$ for every world state $w \in W$ in every task
  frame $\F = \tuple{W, \D, \Rightarrow}$."
- `def:constraints` (verbatim): "For a partial history $\tau : X \to W$ over a task frame $\F$
  and duration $z \in D \setminus X$, the \textit{constraints on $z$} are the segments
  $[\tau(t), \tau(s)]_{z-t}^{s-z}$ for times $t,s \in X$ where $t < z < s$ when both
  $t,s \in X$, and the fibers $\fib{\tau(t), z - t}$ for $t \in X$ otherwise."

The `Fib` / `Seg` / `DirectedFamily` / `IsFiber` / `IsSegment` apparatus these statements are
built from lives in `TaskFrame.lean`, transcribed there from `def:task-relation` and
`def:directed`.

## Main Definitions

- `TaskFrame.Spherical` — the *Spherical* axiom over a bare relation
- `TaskFrame.Serial` — the *Seriality* axiom over a bare relation
- `TaskFrame.Interpolates` — the interpolation (left-to-right) half of *Compositionality*
- `PartialHistory.IsPaired` — the "otherwise" side condition of `def:constraints`
- `PartialHistory.Constraints` — `def:constraints`, the constraints imposed on a new duration

## Main Results

- `ParamTaskFrame.nullity_of_serial_limit` — `lem:nullity`, DERIVED (not an axiom) from *Seriality* at
  `x = 0` plus *Limit*, choice-free

## Implementation Notes

- **No `ParamTaskFrame` structure field is added or changed here.** Everything is stated over a bare
  relation or over an existing frame's `TaskRel`.
- **Fibers and segments are two separate classes.** A "fibers and segments" hypothesis is always
  the disjunction `IsFiber R s ∨ IsSegment R s`. The retired device by which a one-sided fiber
  counted among the segments must not reappear.
- **Directedness is its own definition** (`def:directed`, transcribed as
  `TaskFrame.DirectedFamily`), including the nonemptiness of the *family*; the nonemptiness of
  its *members* is a separate conjunct in `Spherical`, exactly as the paper phrases it.
- **`Limit` is deliberately not given a name here.** It is used only as a hypothesis of
  `nullity_of_serial_limit`, in the literal transcribed shape
  `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w`, which is precisely the conclusion of
  `ParamTaskFrame.limit_of_succOrder` and `ParamTaskFrame.limit_of_shift`. Keeping the raw shape lets those
  two existing discharge helpers be passed directly.
- Segments are written in the paper's bracket form `[w, v]_x^y` only; the retired `\Seg`
  function-application notation is gone from the paper preamble and must not be reintroduced.
-/

namespace FormalSystem.Semantics

namespace ParamTaskFrame

open TaskFrame

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-!
## Where `Spherical` / `Serial` / `Interpolates` live

The three axiom predicates this module was originally written to host —
`TaskFrame.Spherical`, `TaskFrame.Serial`, `TaskFrame.Interpolates` — now live in
`FormalSystem/Semantics/TaskFrame.lean`, beside the `Fib` / `cone` / `Seg` / `DirectedFamily` /
`IsFiber` / `IsSegment` apparatus they are built from. Their fully qualified names, statements,
and namespace are unchanged (`FormalSystem.Semantics.ParamTaskFrame.{Spherical,Serial,Interpolates}`),
so every consumer of this module sees them exactly as before.

The relocation is forced by the invariant recorded above: the `ParamTaskFrame` structure must be able
to carry these predicates as fields *definitionally*, and a structure field's type can only
mention declarations that precede it. A predicate declared in a module that imports
`TaskFrame.lean` can never be a `ParamTaskFrame` field. Hosting them beside the apparatus is what
makes the fields statable without restating anything.
-/

/--
`lem:nullity`: every world state loops at duration zero.

Recorded source (`lem:nullity`, verbatim): "$w \Rightarrow_0 w$ for every world state $w \in W$
in every task frame $\F = \tuple{W, \D, \Rightarrow}$."

**Nullity is DERIVED, not an axiom.** `def:frame` has exactly four axioms — *Compositionality*,
*Seriality*, *Limit*, *Spherical* — and Nullity is not among them. This theorem is the
derivation, from *Seriality* at `x = 0` plus *Limit*, and it is **choice-free**, in contrast with
the Extension Theorem's appeal to Zorn's lemma.

The argument is the paper's: *Seriality* at `x = 0` supplies some `u` with `w ⇒₀ u`; since
`|0| < x` for every `x > 0`, that `u` lies in the cone `(w)_x` at every positive radius, so
*Limit* forces `u = w`.

The *Limit* hypothesis is taken in the literal transcribed shape
`∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w`, which is exactly what
`ParamTaskFrame.limit_of_succOrder` and `ParamTaskFrame.limit_of_shift` conclude, so either may be passed
directly.

Note this asserts **reflexivity only**, which is all `lem:nullity` asserts. The
`ParamTaskFrame.nullity_identity` field is an iff, and its other half — injectivity-at-zero,
`R w 0 u → u = w` — follows from the `limit` hypothesis **alone**, by instantiating the cone
witness at `y := 0`. So the field is derivable from `serial` + `limit` together and is *not* a
strengthening of the paper; see that field's own docstring in `TaskFrame.lean` for both
derivations. Nothing here strengthens or weakens the field, and nothing here depends on it.
-/
theorem nullity_of_serial_limit {W : Type} {R : W → D → W → Prop}
    (hSer : Serial R)
    (hLim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
    (w : W) : R w 0 w := by
  obtain ⟨u, hu⟩ := (hSer w 0 le_rfl).1
  have huw : u = w := hLim w u fun x hx => ⟨0, by simpa using hx, hu⟩
  exact huw ▸ hu

end ParamTaskFrame

namespace PartialHistory

variable {F : TaskFrame}

/--
The time `t` is *paired* about the duration `z`: some other time in the domain lies on the
opposite side of `z`, so that the two sandwich `z`.

This is the side condition behind `def:constraints`'s "otherwise": a time `t ∈ X` contributes a
*fiber* precisely when it is **not** paired, since when it is paired the constraint it imposes is
already carried by a segment (the segment `[τ(t), τ(s)]_{z-t}^{s-z}` is the intersection of the
fiber conditions at `t` and at `s`).

Both disjuncts are needed because `t` may lie on either side of `z`; `z ∉ X` is what makes the
two disjuncts exhaustive at every `t ∈ X`.

Observation, recorded but not needed here: this collapses globally. If `X` has times both below
and above `z` then *every* `t ∈ X` is paired and `Constraints τ z` consists of segments only; if
`X` lies entirely on one side of `z` then no `t` is paired and `Constraints τ z` consists of
fibers only.
-/
def IsPaired (τ : PartialHistory F) (z t : F.Duration) : Prop :=
  (t < z ∧ ∃ s, τ.domain s ∧ z < s) ∨ (z < t ∧ ∃ s, τ.domain s ∧ s < z)

/--
`def:constraints`: the constraints imposed on a new duration `z` by a partial history `τ`.

Recorded source (`def:constraints`, verbatim): "For a partial history $\tau : X \to W$ over a
frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the
\textit{constraints imposed on $z$} are the segments $[\tau(t), \tau(s)]_{z-t}^{s-z}$ for times
$t,s \in X$ where $t < z < s$, and the fibers $\Fib(\tau(t), z - t)$ for $t \in X$ otherwise."

The two clauses are the two disjuncts, in the paper's order:

- **Segments**, for every pair of domain times `t < z < s`, written in the bracket form
  `[τ(t), τ(s)]_{z-t}^{s-z}` — i.e. `Seg F.TaskRel (τ t) (τ s) (z - t) (s - z)`. Both offsets
  `z - t` and `s - z` are positive here, so each such member genuinely satisfies `IsSegment`.
- **Fibers**, `Fib(τ(t), z - t)`, for every domain time `t` that is *not* paired about `z` — the
  paper's "otherwise", transcribed as `¬ IsPaired τ z t`.

`z ∉ dom τ` (the paper's `z ∈ D \ X`) is **not** carried in this definition's type; it is a
hypothesis at the use sites that need it, matching how the `x, y ≥ 0` segment proviso is carried
by `IsSegment` rather than by `Seg`.
-/
def Constraints (τ : PartialHistory F) (z : F.Duration) : Set (Set F.WorldState) :=
  {c | (∃ (t s : F.Duration) (ht : τ.domain t) (hs : τ.domain s), t < z ∧ z < s ∧
          c = TaskFrame.Seg F.TaskRel (τ.states t ht) (τ.states s hs) (z - t) (s - z))
     ∨ (∃ (t : F.Duration) (ht : τ.domain t), ¬ IsPaired τ z t ∧
          c = TaskFrame.Fib F.TaskRel (τ.states t ht) (z - t))}

/-- Membership in `Constraints`, unfolded: a set is a constraint on `z` exactly when it is one of
the two clauses of `def:constraints`. -/
theorem mem_Constraints {τ : PartialHistory F} {z : F.Duration} {c : Set F.WorldState} :
    c ∈ Constraints τ z ↔
      (∃ (t s : F.Duration) (ht : τ.domain t) (hs : τ.domain s), t < z ∧ z < s ∧
          c = TaskFrame.Seg F.TaskRel (τ.states t ht) (τ.states s hs) (z - t) (s - z))
     ∨ (∃ (t : F.Duration) (ht : τ.domain t), ¬ IsPaired τ z t ∧
          c = TaskFrame.Fib F.TaskRel (τ.states t ht) (z - t)) := Iff.rfl

/-- Every segment member of `Constraints τ z` is a segment in the sense of `IsSegment`: the
paper's `x, y ≥ 0` proviso is met because `t < z < s`. -/
theorem isSegment_of_mem_Constraints_left {τ : PartialHistory F} {z t s : F.Duration}
    (ht : τ.domain t) (hs : τ.domain s) (htz : t < z) (hzs : z < s) :
    TaskFrame.IsSegment F.TaskRel
      (TaskFrame.Seg F.TaskRel (τ.states t ht) (τ.states s hs) (z - t) (s - z)) :=
  ⟨τ.states t ht, τ.states s hs, z - t, s - z, le_of_lt (sub_pos.mpr htz),
    le_of_lt (sub_pos.mpr hzs), rfl⟩

/-- Every member of `Constraints τ z` is a fiber or a segment — the disjunction the *Spherical*
axiom ranges over. The two classes stay separate. -/
theorem isFiber_or_isSegment_of_mem_Constraints {τ : PartialHistory F} {z : F.Duration}
    {c : Set F.WorldState} (hc : c ∈ Constraints τ z) :
    TaskFrame.IsFiber F.TaskRel c ∨ TaskFrame.IsSegment F.TaskRel c := by
  rcases hc with ⟨t, s, ht, hs, htz, hzs, rfl⟩ | ⟨t, ht, _, rfl⟩
  · exact Or.inr (isSegment_of_mem_Constraints_left ht hs htz hzs)
  · exact Or.inl ⟨τ.states t ht, z - t, rfl⟩

end PartialHistory

end FormalSystem.Semantics
