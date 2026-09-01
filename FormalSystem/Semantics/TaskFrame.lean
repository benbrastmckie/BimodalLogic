/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Data.Fintype.Basic
import Mathlib.Algebra.Order.Group.Abs
import Mathlib.Data.Finset.Lattice.Fold
import Mathlib.Order.SuccPred.Basic
import Mathlib.Data.Set.Lattice
import Mathlib.Order.Minimal
import Mathlib.Data.Fintype.Powerset
import FormalSystem.Semantics.TemporalOrder

/-!
# TaskFrame — the frame fibration: `TemporalOrder`, `FrameOver`, and the total space

This module defines task frames, the fundamental semantic structures for bimodal logic TM.

## The fibration

`def:frame` reads a frame as `𝔉 = ⟨W, 𝔇, ⇒⟩`: a nonempty set of world states, **a temporal
order**, and a task relation. The temporal order is a *component*, on the same footing as the
other two. This module encodes that as a fibration, in three declarations:

| Lean | Paper | Role |
|------|-------|------|
| `TemporalOrder` (`Semantics/TemporalOrder.lean`) | `def:temporal-order` | the object `𝔇` — "a nontrivial totally ordered abelian group", reified |
| `FrameOver D` | frames at a fixed `𝔇` | the **fibre**; the sole declaration site of the six frame fields |
| `TaskFrame` | `𝔉 = ⟨W, 𝔇, ⇒⟩` | the **total space**, `Σ (D : TemporalOrder), FrameOver D` |

`FrameOver.toTaskFrame` is the inclusion of a fibre into the total space, and it is literally the
constructor: `⟨D, F⟩`. Structure eta makes the projection an identity rather than an isomorphism
up to transport — `⟨G.Duration, G.toFibre⟩ = G`, `(F.toTaskFrame).toFibre = F` and
`(F.toTaskFrame).Duration = D` all hold by `rfl`, pinned as `example`s at the end of this module.
`instCoeOutFrameOver` lets a fibre value be handed to `WorldHistory`, `TaskModel` and `TruthAt`,
which are stated over the total space.

**Why a component and not a type parameter.** A property of the temporal order alone cannot be
*predicated of a frame* while the order is an index; it can only be quantified at the carrier.
With `Duration` a field, `def:frame-properties`' Discrete / Dense / Complete are ordinary
predicates on a `TaskFrame`, through its `Duration` component, exactly as the paper states them.
Conversely the fibre is what makes "the frames over a fixed temporal order" sayable at all — a
propositional carrier equation cannot carry it, because the equation is a `Prop` while
`OfNat F.Duration 1` is data, so no numeral elaborates under it. `FrameOver intOrder` has both:
numerals elaborate, and the order is fixed.

`TaskFrame`'s flat surface is preserved: `F.WorldState`, `F.TaskRel`, `F.spherical` and the rest
are delegating accessors on the total space, `@[reducible]` where the value is data and
`theorem`s where it is a `Prop` (Lean refuses `@[reducible]` on a proof; proof irrelevance makes
that costless).

Where a frame's duration carrier is pinned to a bare `Type` by a neighbouring abstraction this
module does not own — `BFMCS` in the bundle layer, `FrameConditionFor` and `TemporalCarrier` in
the decidability bridge — the frame is written `FrameOver (TemporalOrder.of D)`. That is the
same fibre, named through `TemporalOrder.of`, and it is why that constructor is permanent.

## Paper Specification Reference

**Task Frames (`def:frame`)**:
The JPL paper "The Perpetuity Calculus of Agency" defines a frame (verbatim: "A \textit{frame}
is any $\F = \tuple{W, \D, \Rightarrow}$ where $W$ is a nonempty set of world states, $\D$ is
a temporal order, and $\Rightarrow$ is a task relation satisfying the following for
$x, y \geq 0$") with exactly FOUR axioms:
- *Compositionality* (`def:frame#Compositionality`, verbatim): "$w \Rightarrow_{x + y} v$ if
  and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$." — a
  BICONDITIONAL: right-to-left is composition, left-to-right is interpolation, and both
  directions are load-bearing.
- *Seriality* (`def:frame#Seriality`, verbatim): "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
  for some $u, v \in W$."
- *Limit* (`def:frame#Limit`, verbatim): "$\bigcap\limits_{x > 0} (w)_x = \set{w}$."
- *Spherical* (`def:frame#Spherical`, verbatim): "$\bigcap \mathcal{S} \neq \emptyset$ for any
  $\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments."

Nullity is NOT an axiom. The paper's `lem:nullity` (verbatim: "$w \Rightarrow_0 w$ for every
world state $w \in W$ in every task frame $\F = \tuple{W, \D, \Rightarrow}$.") is DERIVED,
choice-free, from *Seriality* at `x = 0` plus *Limit*, and asserts reflexivity only.

The supporting apparatus — nonempty `W`, the positive-cone primitive relation, the converse
convention, fiber, cone, and segment (`def:task-relation`), and the directed family
(`def:directed`) — is transcribed in this module's "Fiber, cone, segment, and directed-family
apparatus" section. The temporal order is `def:temporal-order` (verbatim: "A \textit{temporal
order} is a nontrivial totally ordered abelian group $\D = \tuple{D, +, 0, \leq}$ with
\textit{positive cone} $D^+ \coloneq \set{x \in D : x \geq 0}$.").

**ProofChecker Implementation**:
This implementation generalizes the time group to any type `D` with an
ordered additive commutative group structure, which provides:
- Additive abelian group structure (zero, addition, inverse)
- Total linear order (≤ relation)
- Order compatibility with addition

This allows for various temporal structures:
- `Int`: Discrete integer time (standard temporal logic)
- `Rat`: Dense rational time (for fine-grained temporal reasoning)
- `Real`: Continuous real time (for physical systems)
- Custom bounded or modular time structures

**Alignment status relative to the four-axiom `def:frame`**:
- The two-sided `TaskRel` together with the `converse` field **is** the paper's extended
  relation over a primitive relation living on the positive cone. `converse` packages
  `def:task-relation`'s definitional converse convention as structure data; it is not an extra
  temporal-symmetry axiom.
- `comp` **is** the paper's biconditional *Compositionality*, carried whole. Its `←`
  (composition) half is projected back out as the derived `forward_comp`, whose statement is
  unchanged from when it was a field; its `→` (interpolation) half is projected out as
  `interpolates`, definitionally `Interpolates TaskRel`.
- `serial`, `limit`, and `spherical` carry the paper's other three axioms, each stated by
  citation of the corresponding bare-relation predicate (or, for *Limit*, its literal
  transcribed shape) rather than restated inline.
- `nullity_identity` is an iff, strictly STRONGER than the paper's derived `lem:nullity`
  (reflexivity only). Its final form is an open design question — see the field's docstring.
- Reflection (`nullity`) and backward composition (`backward_comp`) are **derived** here,
  matching `lem:nullity`'s derived status in the paper.
- Mixed-sign composition is not so much prohibited as **inexpressible at the primitive level**,
  since primitive durations are nonnegative.
- The ordered additive group structure provides the required abelian group with total order.

**Known gaps relative to the paper**: none of the structural ones remain. The two that stood
here are now closed, and are recorded as closed rather than deleted, since both were long-lived:

- `W` nonempty (`def:frame`, verbatim: "$W$ is a nonempty set of world states";
  `def:task-relation`) is the `nonempty` field, discharged at every frame in the tree. Its
  immediate payoff is that `TaskFrame.not_validOn_bot` (Semantics/Validity.lean) is now the bare
  `¬ F.ValidOn ⊥`, with no world state taken as an argument.
- `D` nontrivial (`def:temporal-order`) is `[Nontrivial D]`, now among the structure's own
  binders and inherited by `FiniteFrameOver`. `valid` and `SemanticConsequence`
  (Semantics/Validity.lean) already carried it and still do — they bind `D` themselves, so
  theirs is not made redundant by the structure's; what the structure's binder removes is the
  possibility of writing a frame over a trivial duration order at all.

All four of `def:frame`'s axioms are now carried by the structure, so the former entries here
for *Seriality*, *Limit*, *Spherical*, and the interpolation direction of *Compositionality*
are retired rather than restated: they are the `serial`, `limit`, `spherical`, and `comp`
fields. The apparatus that makes *Spherical* statable — `Fib`, `cone`, `Seg`,
`DirectedFamily`, `IsFiber`, `IsSegment` — is defined below the module header and above the
structure, and is consumed by it. *Limit*'s transcription against the extended relation is
`∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w`; the `⊇` half of the paper's
equality is `nullity` plus cone membership and needs no field, and the two reusable discharge
routes are `limit_of_succOrder` and `limit_of_shift` below.

## Main Definitions

- `FrameOver D`: the fibre over a temporal order — world states, task relation, and the six
  frame axioms; the sole declaration site of the axioms
- `TaskFrame`: the total space, `Σ (D : TemporalOrder), FrameOver D`, with `Duration` and
  `toFibre` as its two fields
- `FrameOver.nullity_identity`: Zero duration iff identity (`TaskRel w 0 u ↔ w = u`) —
  stronger than the paper's derived `lem:nullity`; open design question, see its docstring
- `FrameOver.comp`: the paper's biconditional *Compositionality* (`0 ≤ x`, `0 ≤ y`), stated as
  `TaskFrame.Compositional TaskRel`
- `FrameOver.serial`, `FrameOver.limit`, `FrameOver.spherical`: *Seriality*, *Limit*, and
  *Spherical*, stated as `TaskFrame.Serial TaskRel`, *Limit*'s literal transcribed shape, and
  `TaskFrame.Spherical TaskRel`
- `FrameOver.forward_comp`: the `←` (composition) half of `comp`, derived; its statement is
  verbatim that of the former field of the same name
- `FrameOver.interpolates`: the `→` (interpolation) half of `comp`, derived, definitionally
  `TaskFrame.Interpolates TaskRel`
- `FrameOver.converse`: The definitional converse convention (`TaskRel w d u ↔ TaskRel u (-d) w`)
- `FrameOver.nullity`: Derived reflexivity theorem (`TaskRel w 0 w`, matching `lem:nullity`)
- `TaskFrame.Fib`, `TaskFrame.cone`, `TaskFrame.Seg`, `TaskFrame.DirectedFamily`,
  `TaskFrame.IsFiber`, `TaskFrame.IsSegment`: the `def:task-relation` / `def:directed`
  apparatus over a bare relation
- `TaskFrame.Spherical`, `TaskFrame.Serial`, `TaskFrame.Interpolates`,
  `TaskFrame.Compositional`: `def:frame`'s axioms as predicates over a bare relation, hosted
  above the structure so that its fields cite them *definitionally* (a field's type may only
  mention earlier declarations). *Limit* is deliberately unnamed and used in its literal
  transcribed shape

## Main Results

- `TaskFrame.limit_of_succOrder`: *Limit* is automatic over a discrete duration
  type (`[SuccOrder D] [NoMaxOrder D]`)
- `TaskFrame.limit_of_shift`: *Limit* is automatic for deterministic-shift frames
  over any nontrivial duration type, dense included
- `TaskFrame.exists_uniform_radius_of_finite`: on a finite carrier, *Limit* upgrades to a
  uniform positive radius around each state
- Example task frames for testing and demonstrations (polymorphic over time type)

## Implementation Notes

- `(D : TemporalOrder)` is one binder, not a carrier plus four algebraic instance binders; the
  four `def:temporal-order` components are `D`'s own fields, re-exported as instances, so `↑D`
  carries them with no ceremony
- Task relation `TaskRel w x u` means: world state `u` is reachable from `w` by task
  of duration `x`
- Nullity: zero-duration task is identity, stated as an iff (open design question against the
  paper's reflexivity-only `lem:nullity`)
- Compositionality is carried whole, as the paper's biconditional on the positive cone; its two
  halves are the derived `FrameOver.forward_comp` and `FrameOver.interpolates`
- Genuine side conditions on the carrier — `[SuccOrder ↑D]`, `[DenselyOrdered ↑D]`,
  `[Archimedean ↑D]` — remain ordinary instance binders. Only `def:temporal-order`'s own four
  components stopped being binders
- `omega` reads the *syntactic* type of a hypothesis and does not see through the `TemporalOrder`
  carrier coercion, so arithmetic-carrying binders at the `ℤ` fibre are written `(d : ℤ)`, and
  where a hypothesis is produced by a frame field's own type the recovery form is an explicit
  restatement (`@LT.lt ℤ _ a b`), never a `▸` cast

## References

* [architecture.md](../../../docs/user-guide/architecture.md) - Task semantics specification
* JPL Paper anchors `def:frame` (with sub-anchors `def:frame#Compositionality`,
  `def:frame#Seriality`, `def:frame#Limit`, `def:frame#Spherical`), `def:task-relation`,
  `def:directed`, `def:temporal-order`, and `lem:nullity` — cited by `\label` anchor with
  verbatim quotes above, never by raw line number
-/

namespace FormalSystem.Semantics

/-!
## The `def:frame` apparatus and axiom predicates

The fiber/cone/segment/directed-family apparatus and three of `def:frame`'s four axioms are
declared **before** the frame structure, not after it. That ordering is load bearing: a
structure field's type may only mention declarations that precede it, so these are the
declarations the structure's axiom fields are stated from. Everything here is over a bare
relation `R : W → D → W → Prop`, so nothing in this block depends on the structure.
-/

namespace TaskFrame

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-!
### Fiber, cone, segment, and directed-family apparatus

The supporting apparatus of the paper's frame definition (`def:frame`), stated — like the Limit
discharge helpers above — against a bare relation `R : W → D → W → Prop` rather than a
`FrameOver` field, so the definitions apply verbatim to a frame's `TaskRel` whether or not the
corresponding axioms are carried as structure data. This apparatus is what makes the paper's
*Spherical* axiom ("`⋂ 𝒮 ≠ ∅` for any `⊇`-directed family `𝒮` of nonempty fibers and segments")
statable at all.

Recorded source, `def:task-relation` (verbatim):
- *Fiber:* `\Fib(w, x) \coloneq \set{u \in W : w \Rightarrow_x u}`.
- *Cone:* `(w)_x \coloneq \bigcup\limits_{\vert{y} < x} \Fib(w, y)` where `x > 0`.
- *Segment:* `[w, v]_x^y \coloneq \Fib(w, x) \cap \Fib(v, -y)` where `x, y \geq 0`.

Recorded source, `def:directed` (verbatim): "A nonempty family of sets $\mathcal{S}$ is
\textit{directed} just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever
$S_1, S_2 \in \mathcal{S}$."

Fibers and segments are TWO separate classes of sets (`IsFiber`, `IsSegment`): a one-sided
fiber does not count as a segment, and a "fibers and segments" hypothesis is always the
disjunction `IsFiber s ∨ IsSegment s`, never a single merged class.
-/

/--
Fiber of `w` at duration `x` under the relation `R`.

Recorded source (`def:task-relation`, *Fiber* clause, verbatim):
"`\Fib(w, x) \coloneq \set{u \in W : w \Rightarrow_x u}`."

`Fib R w x` is the set of states reachable from `w` by a task of duration exactly `x`; by the
converse convention, negative-duration fibers run the relation backwards. The paper defines
fibers for every duration `x ∈ D`, so no sign proviso is carried here.
-/
def Fib {W : Type} (R : W → D → W → Prop) (w : W) (x : D) : Set W := {u | R w x u}

omit [AddCommGroup D] [LinearOrder D] in
@[simp]
theorem mem_Fib {W : Type} {R : W → D → W → Prop} {w u : W} {x : D} :
    u ∈ Fib R w x ↔ R w x u := Iff.rfl

/--
Cone of radius `x` around `w` under the relation `R`.

Recorded source (`def:task-relation`, *Cone* clause, verbatim):
"`(w)_x \coloneq \bigcup\limits_{\vert{y} < x} \Fib(w, y)` where `x > 0`."

The paper's proviso `x > 0` is carried at use sites rather than in the type: for `x ≤ 0` no
duration `y` satisfies `|y| < x`, so the cone is empty and the definition is harmless outside
the intended domain. Membership `u ∈ cone R w x` unfolds to exactly the witness shape the Limit
discharge helpers above consume (`∃ y, |y| < x ∧ R w y u`), so the paper's *Limit* axiom
`⋂_{x > 0} (w)_x = {w}` transcribes as
`∀ w u, (∀ x, 0 < x → u ∈ cone R w x) → u = w` (the `⊇` half being reflexivity plus cone
membership at every radius).
-/
def cone {W : Type} (R : W → D → W → Prop) (w : W) (x : D) : Set W :=
  {u | ∃ y, |y| < x ∧ u ∈ Fib R w y}

omit [IsOrderedAddMonoid D] in
@[simp]
theorem mem_cone {W : Type} {R : W → D → W → Prop} {w u : W} {x : D} :
    u ∈ cone R w x ↔ ∃ y, |y| < x ∧ R w y u := Iff.rfl

omit [IsOrderedAddMonoid D] in
/-- Cones are monotone in the radius. Free sanity lemma for the apparatus; no discharge
obligation rides on it. -/
theorem cone_mono {W : Type} (R : W → D → W → Prop) (w : W) {x₁ x₂ : D} (h : x₁ ≤ x₂) :
    cone R w x₁ ⊆ cone R w x₂ :=
  fun _ ⟨y, hy, hR⟩ => ⟨y, lt_of_lt_of_le hy h, hR⟩

/--
Segment between `w` and `v` at forward offset `x` and backward offset `y`, written `[w, v]_x^y`
in the paper's bracket form.

Recorded source (`def:task-relation`, *Segment* clause, verbatim):
"`[w, v]_x^y \coloneq \Fib(w, x) \cap \Fib(v, -y)` where `x, y \geq 0`."

The bracket form is the notation of record; the paper's retired `\Seg` function-application
notation is deleted from its preamble and must not be reintroduced. The proviso `x, y ≥ 0` is
carried by `IsSegment` below rather than in this definition's type.
-/
def Seg {W : Type} (R : W → D → W → Prop) (w v : W) (x y : D) : Set W :=
  Fib R w x ∩ Fib R v (-y)

omit [LinearOrder D] [IsOrderedAddMonoid D] in
@[simp]
theorem mem_Seg {W : Type} {R : W → D → W → Prop} {w v u : W} {x y : D} :
    u ∈ Seg R w v x y ↔ R w x u ∧ R v (-y) u := Iff.rfl

/--
A `⊇`-directed family of sets.

Recorded source (`def:directed`, the `$\supseteq$` clause, verbatim):
"\item[\bf $\mathbf{\supseteq}$-Directed:] just in case $S \subseteq S_1 \cap S_2$ for some
$S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$."

**The paper splits `def:directed` in two.** Its enclosing sentence reads "A nonempty family of
sets $\mathcal{S}$ is:", followed by a `$\supseteq$-Directed` clause and a
`$\subseteq$-Directed` clause (`$S_1, S_2 \subseteq S$ for some $S \in \mathcal{S}$`). This
definition transcribes the **`$\supseteq$` clause only**, because that is the one *Spherical*
consumes. An earlier revision quoted an undifferentiated "\textit{directed}", from before the
split; the mathematics is unchanged but the unqualified word is now ambiguous and must not be
reintroduced.

The nonemptiness of the family is part of the definition (it comes from the enclosing "A nonempty
family of sets"); the nonemptiness of its *members* is a separate hypothesis wherever
*Spherical*-shaped statements need it.
-/
def DirectedFamily {W : Type} (S : Set (Set W)) : Prop :=
  S.Nonempty ∧ ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂

/--
`s` is a fiber of the relation `R`: one of the two separate classes of sets the *Spherical*
axiom (`def:frame`) ranges over. Fibers exist at every duration `x ∈ D`, matching
`def:task-relation`'s proviso-free *Fiber* clause.
-/
def IsFiber {W : Type} (R : W → D → W → Prop) (s : Set W) : Prop :=
  ∃ w x, s = Fib R w x

/--
`s` is a segment of the relation `R` with nonnegative endpoint offsets, per
`def:task-relation`'s *Segment* clause ("where `x, y ≥ 0`"): the second of the two separate
classes of sets the *Spherical* axiom (`def:frame`) ranges over. A one-sided fiber does not
count as a segment — the two classes are kept separate, and a "fibers and segments" hypothesis
is the disjunction `IsFiber R s ∨ IsSegment R s`.
-/
def IsSegment {W : Type} (R : W → D → W → Prop) (s : Set W) : Prop :=
  ∃ w v x y, 0 ≤ x ∧ 0 ≤ y ∧ s = Seg R w v x y

/-!
## The frame axioms in bare-relation form

`def:frame`'s four axioms, stated as `Prop`-valued predicates over a bare task relation
`R : W → D → W → Prop`. Three of them live here — *Spherical*, *Seriality*, and the
interpolation half of *Compositionality*; *Limit* is deliberately left unnamed and used in its
literal transcribed shape (see the discharge helpers `limit_of_succOrder` and `limit_of_shift`
above).

**These predicates are the sole form in which the axioms are available.** Where the `FrameOver`
structure carries the corresponding fields, `FrameOver.spherical` must be *definitionally*
`Spherical TaskRel`, `FrameOver.serial` definitionally `Serial TaskRel`, and the interpolation
half of biconditional *Compositionality* definitionally `Interpolates TaskRel`, **all as defined
here**. Discharging a downstream hypothesis is then a mechanical substitution (`F.spherical`,
`F.serial`, `F.interpolates`) with zero restatement. If a field lands whose statement differs,
the results that consume these predicates stop typechecking — and that compilation failure *is*
the acceptance test. That invariant is recorded in
`specs/decisions/total-history-validity-decisions.md` (the four-axiom frame-alignment decision).

*Spherical* in particular must be literally the hypothesis the Step Lemma's proof consumes at the
sole application site the paper names, never an inert structure field.

They are hosted in this module, rather than beside `Constraints` in `FrameAxioms.lean`, for a
structural reason: a structure field's type may only mention declarations that precede it, so a
predicate declared in a module that *imports* this one could never become a `FrameOver` field.
-/

/--
The *Spherical* axiom, over a bare task relation.

Recorded source (`def:frame#Spherical`, verbatim): "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments."

**Where this sits in the ball-space hierarchy.** The paper attaches a footnote to this axiom
(quoted from `def:frame`): the nonempty fibers and segments form a *ball space* on `W` in the
sense of Ćmiel, Kuhlmann and Kuhlmann, and *Spherical* is the **downward-directed-intersection
condition $\mathbf{S}_1^d$** of that hierarchy — "the nest condition $\mathbf{S}_1$ with a
$\supseteq$-directed system of balls in place of a nest". It is therefore **strictly stronger**
than the standard *spherically complete* condition, which is $\mathbf{S}_1$ itself. The name
"Spherical" is not a synonym for "spherically complete"; reading it as one understates the axiom.

Three points of the transcription, each load bearing:

1. *Directed* is `def:directed`, transcribed as `DirectedFamily`. The paper split `def:directed`
   into a `$\supseteq$-Directed` and a `$\subseteq$-Directed` clause; *Spherical* consumes the
   `$\supseteq$` half — "$S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever
   $S_1, S_2 \in \mathcal{S}$" — which is what `DirectedFamily` transcribes, and which already
   carries the nonemptiness of the family `S`.
2. "Nonempty fibers and segments" is a condition on each *member*: it is both a class condition
   (`IsFiber R s ∨ IsSegment R s`) and a nonemptiness condition (`s.Nonempty`). Fibers and
   segments are **two separate classes**; a one-sided fiber does not count as a segment.
3. "$\bigcap \mathcal{S} \neq \emptyset$" is `(⋂₀ S).Nonempty`.

This predicate is the sole form in which *Spherical* is available: it is what the Step Lemma's
proof consumes at the one application site the paper names, and what the `FrameOver`
spherical field is definitionally equal to.
-/
def Spherical {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ S : Set (Set W), DirectedFamily S →
    (∀ s ∈ S, (IsFiber R s ∨ IsSegment R s) ∧ s.Nonempty) → (⋂₀ S).Nonempty

/--
The *Seriality* axiom, over a bare task relation.

Recorded source (`def:frame#Seriality`, verbatim): "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$."

The `0 ≤ x` proviso is `def:frame`'s own blanket condition on its axiom list (verbatim: "a task
relation satisfying the following for $x, y \geq 0$"), carried here as an explicit hypothesis
rather than in the type. Both conjuncts are stated: every state has an `x`-successor *and* an
`x`-predecessor.
-/
def Serial {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ (w : W) (x : D), 0 ≤ x → (∃ u, R w x u) ∧ (∃ v, R v x w)

/--
The interpolation half of *Compositionality*, over a bare task relation.

Recorded source (`def:frame#Compositionality`, verbatim): "$w \Rightarrow_{x + y} v$ if and only
if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$."

*Compositionality* is a **biconditional**, and both directions are load bearing. The
right-to-left direction — composition — is already the existing structure field
`FrameOver.forward_comp`. This definition is the missing left-to-right direction: a task of
duration `x + y` can be *interpolated* at every intermediate point. The full biconditional axiom
is therefore `forward_comp ∧ Interpolates`.

As with `Serial`, the `0 ≤ x`, `0 ≤ y` provisos are `def:frame`'s blanket condition on its axiom
list, carried as explicit hypotheses.
-/
def Interpolates {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ w v x y, 0 ≤ x → 0 ≤ y → R w (x + y) v → ∃ u, R w x u ∧ R u y v

/--
The *Compositionality* axiom in full, over a bare task relation.

Recorded source (`def:frame#Compositionality`, verbatim): "$w \Rightarrow_{x + y} v$ if and only
if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$."

This is the **biconditional**, both of whose directions are load bearing. It is the paper's axiom
itself rather than either half: unfolded, it is

```
∀ w v x y, 0 ≤ x → 0 ≤ y → (R w (x + y) v ↔ ∃ u, R w x u ∧ R u y v)
```

and its two halves are `Interpolates R` (the `→` direction, above) and the composition law that
`FrameOver.forward_comp` records (the `←` direction). Naming the conjunction as a predicate — in
the same style as `Serial` and `Spherical` — is what lets the `FrameOver` `comp` field be stated
by *citation* rather than by restating the shape inline, and lets `comp_of` assemble it from the
two halves without higher-order unification against an applied relation.

The `0 ≤ x`, `0 ≤ y` provisos are `def:frame`'s blanket condition on its axiom list.
-/
def Compositional {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ w v x y, 0 ≤ x → 0 ≤ y → (R w (x + y) v ↔ ∃ u, R w x u ∧ R u y v)

/--
Assemble the biconditional *Compositionality* axiom from its two halves: the interpolation
direction (`Interpolates`, the `→`) and the composition direction (the `←`, which is the shape
`FrameOver.forward_comp` has).

This is the citation route every construction site uses: a site supplies whichever
`Interpolates` proof its relation class already has, together with the composition proof it
already carried as its `forward_comp` field value, and gets the paper's biconditional.
-/
theorem comp_of {W : Type} {R : W → D → W → Prop} (hint : Interpolates R)
    (hfwd : ∀ w u v x y, 0 ≤ x → 0 ≤ y → R w x u → R u y v → R w (x + y) v) :
    Compositional R :=
  fun w v x y hx hy =>
    ⟨hint w v x y hx hy, fun ⟨u, h1, h2⟩ => hfwd w u v x y hx hy h1 h2⟩

/-- The composition (`←`) half of `Compositional`: the shape `FrameOver.forward_comp` records. -/
theorem forward_of_comp {W : Type} {R : W → D → W → Prop} (h : Compositional R) :
    ∀ w u v x y, 0 ≤ x → 0 ≤ y → R w x u → R u y v → R w (x + y) v :=
  fun w u v x y hx hy h1 h2 => (h w v x y hx hy).mpr ⟨u, h1, h2⟩

/-- The interpolation (`→`) half of `Compositional`, as the predicate of record. -/
theorem interpolates_of_comp {W : Type} {R : W → D → W → Prop} (h : Compositional R) :
    Interpolates R :=
  fun w v x y hx hy hR => (h w v x y hx hy).mp hR

end TaskFrame

/--
**The fibre of the frame fibration**: task frames over a *fixed* temporal order `D`.

`FrameOver D` is the sole declaration site of the frame axioms in this development. The total
space `TaskFrame` below is `Σ (D : TemporalOrder), FrameOver D` — it *has* a `FrameOver` rather
than restating one — so every axiom exists exactly once and the inclusion of a fibre into the
total space is the constructor `⟨D, F⟩`, not a transport.

A frame over `D` consists of:
- a type of world states,
- a task relation connecting world states via timed tasks of duration `x : ↑D`,
- nullity identity: a zero-duration task is the identity (`w = u`),
- compositionality: tasks compose, and interpolate, on the positive cone,
- the converse convention, `TaskRel w d u ↔ TaskRel u (-d) w`,
- seriality, limit and sphericality.

The task relation `TaskRel w x u` means: starting from world state `w`, executing a task of
duration `x` can result in world state `u`.

**Why the fibre is primitive.** "The task frames over a fixed duration type" is how the entire ℤ
layer of this development is stated, and it is not expressible against a frame that carries its
duration as an opaque field: `(F : TaskFrame) (h : F.Duration = ℤ)` cannot supply
`OfNat F.Duration 1`, because `h` is a `Prop` and the numeral is data. Indexing by a
`TemporalOrder` says the same thing with the numerals intact.

**Paper Alignment**: The paper's `def:frame` carries exactly FOUR axioms — *Compositionality*
(a biconditional), *Seriality*, *Limit*, *Spherical* — and no Nullity axiom (`lem:nullity` is
derived, reflexivity only). This structure carries **all four**, as `comp`, `serial`, `limit`,
and `spherical`, each by citation of a bare-relation predicate rather than by inline
restatement. It additionally carries the converse convention (`converse`) and an iff-form
zero-duration law (`nullity_identity`) that is strictly stronger than the paper's derived
`lem:nullity`. What remains absent is structural rather than axiomatic — see the module
docstring's "Known gaps" list.

**Axiomatization Notes**:
The paper's own presentation (`def:task-relation`) takes the primitive task relation to live on
the positive cone `D⁺ = {x : 0 ≤ x}` and extends it to negative durations by the converse
convention. This structure is that presentation: the two-sided `TaskRel` is the *extended*
relation, `converse` is the convention that defines it from the primitive one, and
`forward_comp`'s `0 ≤ x`, `0 ≤ y` hypotheses confine composition to the primitive domain.

The paper's *Compositionality* (`def:frame#Compositionality`, verbatim: "$w \Rightarrow_{x + y}
v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$") is a
BICONDITIONAL, and the `comp` field carries it whole: its right-to-left (composition) direction
is projected out as `forward_comp` and its left-to-right (interpolation) direction as
`interpolates`.

*Reflection* and backward composition are derived rather than postulated here (`nullity`,
`backward_comp`), matching `lem:nullity`'s derived status in the paper, and mixed-sign
composition is not prohibited but inexpressible at the primitive level, since primitive
durations are nonnegative.
-/
structure FrameOver (D : TemporalOrder) where
  /-- Type of world states -/
  WorldState : Type
  /--
  **The world-state type is nonempty.**

  `def:temporal-order` and `def:task-relation` both read `W` as a nonempty set of world states:
  *Seriality* quantifies existentially over `W` at every duration, and `cor:occurrence` builds a
  total history through a *given* world state. A frame with an empty carrier satisfies every one
  of the four axioms vacuously while validating `⊥`, which is exactly what
  `Semantics/Validity.lean`'s `not_validOn_bot` has to rule out — it did so by taking a
  world state as an extra argument precisely because this field was absent.

  Carried as a field rather than as an instance binder on the structure: instance binders on
  `FrameOver` would have to be supplied at every mention of the type, whereas a field is
  discharged once per frame at its construction site and read off as `F.worldNonempty`
  thereafter. It is instance-implicit and re-exported below, so `Nonempty F.WorldState` is
  also available to synthesis.
  -/
  [worldNonempty : Nonempty WorldState]
  /-- Task relation: `TaskRel w x u` means u is reachable from w by task of duration x -/
  TaskRel : WorldState → D → WorldState → Prop
  /--
  Nullity identity constraint: zero-duration task relates exactly identical states.

  For any world states `w` and `u`, `TaskRel w 0 u` holds iff `w = u`.
  This is stronger than just reflexivity: it says zero duration means no change.

  **Not a strengthening — this field is DERIVABLE, and the frame class is extensionally
  exactly the paper's.** An earlier revision of this docstring called the field "strictly
  stronger than the paper" and left the keep-or-demote choice open as a design question. That
  was wrong on the mathematics. Both halves of the `↔` follow from the other fields:

  * **Reflexivity** (`w = u → TaskRel w 0 u`) is `lem:nullity`, derived choice-free from
    *Seriality* at `x = 0` plus *Limit*. It is already proved in this tree as
    `TaskFrame.nullity_of_serial_limit` (`Semantics/FrameAxioms.lean`).
  * **Injectivity-at-zero** (`TaskRel w 0 u → w = u`) follows from the `limit` field **alone**,
    by instantiating its cone witness at `y := 0`: for every `x > 0` we have `|0| < x` and
    `TaskRel w 0 u`, so `limit` forces `u = w`. *Seriality* is not needed for this half.

  Verbatim, `lem:nullity` reads: "$w \Rightarrow_0 w$ for every world state $w \in W$ in every
  task frame $\F = \tuple{W, \D, \Rightarrow}$." It asserts reflexivity only, which is why
  the second bullet is the part that had to be checked separately.

  Both derivations typecheck against this module's own predicates:

  ```lean
  theorem inj_at_zero_of_limit {W : Type} {R : W → D → W → Prop}
      (hLim : ∀ w u, (∀ x : D, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
      (w u : W) (h : R w 0 u) : u = w :=
    hLim w u fun x hx => ⟨0, by simpa using hx, h⟩

  theorem nullity_iff_of_serial_limit {W : Type} {R : W → D → W → Prop}
      (hSer : TaskFrame.Serial R)
      (hLim : ∀ w u, (∀ x : D, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
      (w u : W) : R w 0 u ↔ w = u :=
    ⟨fun h => (inj_at_zero_of_limit hLim w u h).symm,
     fun h => h ▸ TaskFrame.nullity_of_serial_limit hSer hLim w⟩
  ```

  **Consequences.** The Lean frame class
  `{nullity_identity, comp, converse, serial, limit, spherical}` and the paper's four `def:frame`
  axioms plus nonempty `W` plus the converse convention are **inter-derivable**: the Lean class
  adds no content the paper lacks, and imposes no constraint the paper does not. In particular
  the `⊇` half of *Limit*'s `⋂_{x>0}(w)_x = {w}` — that `w` itself lies in every positive cone —
  is exactly reflexivity-at-zero, so it is supplied by the first bullet rather than assumed.

  **The field is kept.** With derivability settled, deleting it versus retaining it is an
  *ergonomic* call, not a mathematical one — deletion would break every construction site that
  currently discharges it directly. It is retained here as documented redundancy for construction
  ergonomics. The deletion question is an owner decision and is recorded as such in this task's
  author memo; it is not settled by this module either way.
  -/
  nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u
  /--
  **The paper's *Compositionality* axiom, in full** (`def:frame#Compositionality`, verbatim:
  "$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
  $u \in W$").

  Stated by citation as `TaskFrame.Compositional TaskRel`, never restated inline. Unfolded it is

  ```
  ∀ w v x y, 0 ≤ x → 0 ≤ y → (TaskRel w (x + y) v ↔ ∃ u, TaskRel w x u ∧ TaskRel u y v)
  ```

  Both directions are load bearing. Its `←` (composition) half is projected back out as the
  derived `FrameOver.forward_comp`, which keeps its former statement verbatim, so every consumer
  of the old field is untouched; its `→` (interpolation) half is projected out as
  `FrameOver.interpolates`, definitionally `TaskFrame.Interpolates TaskRel`.

  The `0 ≤ x`, `0 ≤ y` hypotheses are how the paper's positive-cone domain restriction is
  expressed against the two-sided extended relation. Composition over negative durations is
  derived (`backward_comp`); mixed-sign composition is inexpressible at the primitive level
  rather than prohibited.
  -/
  comp : TaskFrame.Compositional TaskRel
  /--
  The paper's **definitional converse convention**, packaged as structure data.

  `TaskRel w d u` holds iff `TaskRel u (-d) w` holds.

  This is *not* a substantive temporal-symmetry axiom. The paper's primitive task relation
  lives on the positive cone `D⁺ = {x : 0 ≤ x}` and is extended to negative durations by the
  converse convention (`def:task-relation`, verbatim: "extended to negative durations by the
  \textit{converse convention} $w \Rightarrow_{-x} u \coloneq u \Rightarrow_{x} w$ for
  $x \geq 0$"). A two-sided
  Lean relation cannot carry that stipulation in its type, so it is carried as this field: the
  pair (two-sided `TaskRel`, `converse`) is precisely the paper's *extended* relation over a
  primitive relation on `D⁺`, and it constrains the negative half of `TaskRel` to be exactly
  the reflection of the positive half rather than adding independent content.
  -/
  converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w
  /--
  **The paper's *Seriality* axiom** (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and
  $v \Rightarrow_x w$ for some $u, v \in W$"), stated by citation as
  `TaskFrame.Serial TaskRel` — the bare-relation predicate of record, never restated inline.
  Every state has an `x`-successor and an `x`-predecessor at every `x ≥ 0`.
  -/
  serial : TaskFrame.Serial TaskRel
  /--
  **The paper's *Limit* axiom** (`def:frame#Limit`, verbatim:
  "$\bigcap\limits_{x > 0} (w)_x = \set{w}$"), in the literal transcribed shape: if `u` lies in
  every positive cone of `w`, then `u` is `w`.

  This is exactly what `TaskFrame.limit_of_succOrder`, `TaskFrame.limit_of_shift`, and the
  class helpers conclude, and exactly what `TaskFrame.nullity_of_serial_limit`
  (`Semantics/FrameAxioms.lean`) consumes to derive `lem:nullity`.
  -/
  limit : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w
  /--
  **The paper's *Spherical* axiom** (`def:frame#Spherical`, verbatim:
  "$\bigcap \mathcal{S} \neq \emptyset$ for any $\supseteq$-directed family $\mathcal{S}$ of
  nonempty fibers
  and segments"), stated by citation as `TaskFrame.Spherical TaskRel` — the bare-relation
  predicate of record, never restated inline.

  This field is the one the Step Lemma consumes (`Semantics/Extension/Step.lean`), which is why
  it must be *literally* `TaskFrame.Spherical`: a restatement, however equivalent, would make
  that consumption fail to typecheck. Fibers and segments stay two separate classes.
  -/
  spherical : TaskFrame.Spherical TaskRel

attribute [instance] FrameOver.worldNonempty

/--
**A frame over a fixed temporal order, with finitely many world states.**

The fibre-level counterpart of `FiniteTaskFrame`. Finiteness is a property of the world-state
carrier alone, so it is carried here rather than at the total space, and `FiniteTaskFrame` reads
it off through its own fibre.
-/
structure FiniteFrameOver (D : TemporalOrder) extends FrameOver D where
  /-- The set of world states is finite. -/
  finite_world : Finite WorldState

namespace FrameOver

open TaskFrame

variable {D : TemporalOrder}

/--
**Composition on the positive cone — the `←` projection of the `comp` field.**

If a task of duration `x ≥ 0` takes `w` to `u`, and a task of duration `y ≥ 0` takes `u` to `v`,
then a task of duration `x + y` takes `w` to `v`.

This was a structure field in its own right until the `comp` field landed carrying the paper's
full biconditional (`def:frame#Compositionality`). Its statement here is that former field's,
verbatim, so every consumer applies it exactly as before; only its status changed, from
postulate to projection.
-/
theorem forward_comp (F : FrameOver D) (w u v : F.WorldState) (x y : ↑D)
    (hx : 0 ≤ x) (hy : 0 ≤ y) (h1 : F.TaskRel w x u) (h2 : F.TaskRel u y v) :
    F.TaskRel w (x + y) v :=
  forward_of_comp F.comp w u v x y hx hy h1 h2

/--
**Interpolation — the `→` projection of the `comp` field**, as the bare-relation predicate of
record (`def:frame#Compositionality`'s left-to-right direction).

Definitionally `Interpolates F.TaskRel`: `example (F : FrameOver D) : Interpolates F.TaskRel :=
F.interpolates` elaborates. This is the form the Step Lemma chain consumes.
-/
theorem interpolates (F : FrameOver D) : Interpolates F.TaskRel :=
  interpolates_of_comp F.comp

/--
Derived nullity: zero-duration task is reflexive.

This follows from `nullity_identity`: `TaskRel w 0 w` iff `w = w`, and `w = w` is trivial.
-/
theorem nullity (F : FrameOver D) (w : F.WorldState) : F.TaskRel w 0 w :=
  F.nullity_identity w w |>.mpr rfl

/--
Derived backward compositionality: tasks compose in the backward direction.

From `forward_comp` and `converse`, we can derive compositionality for non-positive durations.
If `TaskRel w x u` with `x ≤ 0` and `TaskRel u y v` with `y ≤ 0`,
then `TaskRel w (x + y) v`.
-/
theorem backward_comp (F : FrameOver D) (w u v : F.WorldState) (x y : ↑D)
    (hx : x ≤ 0) (hy : y ≤ 0)
    (h1 : F.TaskRel w x u) (h2 : F.TaskRel u y v) :
    F.TaskRel w (x + y) v := by
  -- Use converse to flip directions, then forward_comp, then converse back
  -- TaskRel w x u <-> TaskRel u (-x) w, where -x >= 0
  -- TaskRel u y v <-> TaskRel v (-y) u, where -y >= 0
  have h1' : F.TaskRel u (-x) w := F.converse w x u |>.mp h1
  have h2' : F.TaskRel v (-y) u := F.converse u y v |>.mp h2
  have hx' : 0 ≤ -x := neg_nonneg.mpr hx
  have hy' : 0 ≤ -y := neg_nonneg.mpr hy
  -- forward_comp v u w (-y) (-x): TaskRel v (-y) u -> TaskRel u (-x) w -> TaskRel v (-y + -x) w
  have h3 : F.TaskRel v ((-y) + (-x)) w := F.forward_comp v u w (-y) (-x) hy' hx' h2' h1'
  -- Now use converse: TaskRel v (-(x+y)) w <-> TaskRel w (x+y) v
  have h4 : -y + -x = -(x + y) := by simp [neg_add_rev, add_comm]
  rw [h4] at h3
  exact F.converse w (x + y) v |>.mpr h3

end FrameOver

/-! ## Bare-relation discharge helpers

Everything below is stated against a bare relation `R : W → D → W → Prop` over an ambient
carrier, never against a frame field, so it applies to any relation whether or not a frame
carries it. That is why it belongs in `TaskFrame` beside the bare-relation predicates of record
(`Serial`, `Interpolates`, `Spherical`) rather than in the fibre namespace.
-/

namespace TaskFrame

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-!
### Limit discharge helpers

The paper's *Limit* axiom (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x =
\set{w}$") transcribes against the extended relation as

```
∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w
```

The two theorems below are the two reusable ways to discharge that obligation. They are stated
against a bare relation `R : W → D → W → Prop` rather than against a `FrameOver` field, so they
apply verbatim to a frame's `TaskRel` whether or not the axiom is carried as structure data.
(An earlier paper wave folded Nullity into this axiom's name; the paper's current name is
simply *Limit*, and the helpers are named accordingly.)
-/

/--
*Limit* holds automatically over a duration type with a successor operation.

Over a `SuccOrder`, `Order.succ 0` is a positive duration with nothing strictly between it and
`0` in absolute value, so the hypothesis at `x = Order.succ 0` already forces the witness
duration to be `0`, and iff-Nullity closes the goal. This discharges every frame whose duration
type is discrete (`Int` in particular).

`NoMaxOrder D` is what makes `0 < Order.succ 0` available; it is *not* an extra burden in
practice, because `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`
already implies it by instance search. The repo's standard discrete binder bundle
(`[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]`, used
throughout `SoundnessLemmas/FrameClassVariants.lean`) therefore subsumes both hypotheses, and no
frame carrying that bundle needs any new hypothesis to apply this lemma. `IsSuccArchimedean` is
not used.
-/
theorem limit_of_succOrder [SuccOrder D] [NoMaxOrder D]
    {W : Type} {R : W → D → W → Prop} (hnull : ∀ w u, R w 0 u ↔ w = u) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w := by
  intro w u h
  obtain ⟨y, hy, hR⟩ := h (Order.succ 0) (Order.lt_succ 0)
  have h1 : |y| ≤ 0 := Order.lt_succ_iff.mp hy
  have h2 : y = 0 := abs_eq_zero.mp (le_antisymm h1 (abs_nonneg y))
  subst h2
  exact ((hnull w u).mp hR).symm

/--
*Limit* holds for any deterministic-shift frame, over *any* duration type — dense included.

A frame is a *deterministic shift* when the duration of a transition is recoverable from its
endpoints, via a position function `pos : W → D` with `R w y u → pos u = pos w + y`. The witness
duration supplied by the *Limit* hypothesis is then the *same* `pos u - pos w` for every
radius `x`, so `|pos u - pos w| < x` for all `x > 0` and the shift must be `0`; `hzero` then
closes the goal.

`[Nontrivial D]` is genuinely required and is not an artifact of the proof: over a trivial
duration group no positive `x` exists, the hypothesis is vacuous, and the conclusion fails (take
`R := fun _ _ _ => False` on a two-element carrier). The paper independently mandates a
nontrivial totally ordered abelian group for exactly this reason.

This is the shape of every flow-style frame — carriers of the form `Index × D` whose relation
advances the second component by the duration — so it is the discharge route for the bundled
flow frames as well as the multi-family bridge frames.
-/
theorem limit_of_shift [Nontrivial D] {W : Type} (pos : W → D)
    {R : W → D → W → Prop}
    (hshift : ∀ w y u, R w y u → pos u = pos w + y)
    (hzero : ∀ w u, R w 0 u → u = w) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w := by
  intro w u h
  -- A nontrivial ordered group has a positive element.
  obtain ⟨x₀, hx₀⟩ : ∃ x : D, 0 < x := by
    obtain ⟨a, ha⟩ := exists_ne (0 : D)
    rcases lt_or_gt_of_ne ha with hlt | hgt
    · exact ⟨-a, neg_pos.mpr hlt⟩
    · exact ⟨a, hgt⟩
  obtain ⟨y₀, _, hR₀⟩ := h x₀ hx₀
  have hy₀ : pos u = pos w + y₀ := hshift w y₀ u hR₀
  -- Every witness duration equals `y₀`, since all of them are `pos u - pos w`.
  have key : ∀ x : D, 0 < x → |y₀| < x := by
    intro x hx
    obtain ⟨y, hy, hR⟩ := h x hx
    have hyy : pos u = pos w + y := hshift w y u hR
    have : y = y₀ := by
      have := hy₀.symm.trans hyy
      exact (add_right_injective (pos w) this).symm
    rwa [this] at hy
  -- Hence `|y₀|` is below every positive duration, so it is `0`.
  have hle : |y₀| ≤ 0 := not_lt.mp fun hpos => lt_irrefl _ (key _ hpos)
  have hzero' : y₀ = 0 := abs_eq_zero.mp (le_antisymm hle (abs_nonneg y₀))
  subst hzero'
  exact hzero w u hR₀

/--
On a finite carrier, *Limit* upgrades to a *uniform* positive radius around each state.

*Limit* is a pointwise limit statement: for each `u ≠ w` there is *some* radius below
which `u` is unreachable from `w`. When the carrier is finite, taking the minimum of those
radii over the carrier turns this into a single positive `x` that works for every `u` at once:
nothing but `w` is reachable from `w` within `x`.

**Consequence.** A finite frame satisfying *Limit* over a densely ordered duration type is
temporally *rigid*: a world history through `w` at time `t` is constant on `(t - x, t + x)`, so
over a dense duration domain histories are locally constant. That is the correct content of the
axiom, not a defect — but it means the filtration and FMP frames cannot remain
dense-polymorphic once *Limit* is carried as a frame axiom. The move of FMP to `ℤ` is
therefore forced by the axiom rather than being a convenience.

**Status.** This is the deliberate substitute for the paper's cone-topology T1 result
(`app:topology-r0`). Formalizing that result requires first building the cone topology — `(w)_x`
as a basis, a proof that it *is* a basis, a `TopologicalSpace` instance — and no topology exists
anywhere in this library; the infrastructure, not the one-line proof, is the cost. This lemma
gives a machine-checked consequence of *Limit* in the same cost bracket, is topology-free,
and has direct bearing on the finite-model constructions.
-/
theorem exists_uniform_radius_of_finite [Nontrivial D] {W : Type} [Fintype W]
    (R : W → D → W → Prop)
    (hlim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
    (w : W) : ∃ x : D, 0 < x ∧ ∀ u y, |y| < x → R w y u → u = w := by
  classical
  -- A nontrivial ordered group has a positive element, used as the radius at `u = w`.
  obtain ⟨x₀, hx₀⟩ : ∃ x : D, 0 < x := by
    obtain ⟨a, ha⟩ := exists_ne (0 : D)
    rcases lt_or_gt_of_ne ha with hlt | hgt
    · exact ⟨-a, neg_pos.mpr hlt⟩
    · exact ⟨a, hgt⟩
  -- Pointwise: each `u` has its own radius, from the contrapositive of *Limit*.
  have hrad : ∀ u : W, ∃ x : D, 0 < x ∧ ∀ y, |y| < x → R w y u → u = w := by
    intro u
    by_cases huw : u = w
    · exact ⟨x₀, hx₀, fun _ _ _ => huw⟩
    · have hne : ¬ ∀ x : D, 0 < x → ∃ y, |y| < x ∧ R w y u := fun hh => huw (hlim w u hh)
      push Not at hne
      obtain ⟨x, hx, hnx⟩ := hne
      exact ⟨x, hx, fun y hy hR => absurd hR (hnx y hy)⟩
  -- Uniform: take the minimum of the pointwise radii over the finite carrier.
  have huniv : (Finset.univ : Finset W).Nonempty := ⟨w, Finset.mem_univ w⟩
  let f : W → D := fun u => (hrad u).choose
  refine ⟨Finset.univ.inf' huniv f, ?_, ?_⟩
  · rw [Finset.lt_inf'_iff]
    exact fun u _ => (hrad u).choose_spec.1
  · intro u y hy hR
    have hle : Finset.univ.inf' huniv f ≤ f u := Finset.inf'_le f (Finset.mem_univ u)
    exact (hrad u).choose_spec.2 y (lt_of_lt_of_le hy hle) hR

/-!
## Reusable axiom-class discharge helpers

Every live frame construction in this library whose relation is *not* a deterministic
shift falls into one of three relation classes, and each class discharges `def:frame`'s four
axioms once and for all:

- **total** — `R w x u` for all `w`, `x`, `u`, on a `Subsingleton` carrier (`trivialFrame`,
  `intTimeFrame`, `genericTimeFrame`);
- **permissive** — `R w d u ↔ (d ≠ 0 ∨ w = u)` (`natFrame`, `intNatFrame`, `genericNatFrame`,
  and the test frames);
- **equality** — `R w d u ↔ w = u` (`staticFrame`).

The fourth class, deterministic shift, is already served by `limit_of_shift` above.

Each helper takes the class membership as an `Iff` hypothesis rather than matching a literal
lambda, so a site discharges it with `fun _ _ _ => Iff.rfl` and no defeq-unfolding risk. Every
conclusion is *syntactically* `Serial R` / `Interpolates R` / `Spherical R`, or the literal
transcribed *Limit* shape `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w` that
`limit_of_succOrder` and `limit_of_shift` conclude and `nullity_of_serial_limit` consumes — never
a restatement.
-/

/--
A nontrivial totally ordered abelian group has a positive element.

The paper mandates a nontrivial duration group (`def:frame`), and this is the one consequence of
that mandate the *Limit* arguments actually use: without a positive radius the *Limit* hypothesis
is vacuous and the axiom is unprovable.
-/
theorem exists_pos_of_nontrivial [Nontrivial D] : ∃ x : D, 0 < x := by
  obtain ⟨a, ha⟩ := exists_ne (0 : D)
  rcases lt_or_gt_of_ne ha with hlt | hgt
  · exact ⟨-a, neg_pos.mpr hlt⟩
  · exact ⟨a, hgt⟩

/--
The *Spherical* core argument for every relation whose nonempty fibers and segments are each
either the whole carrier or a singleton.

Recorded source (`def:directed`, verbatim): "A nonempty family of sets $\mathcal{S}$ is
\textit{directed} just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever
$S_1, S_2 \in \mathcal{S}$."

If some member is a singleton `{a}`, directedness forces `a` into every other member: the
witness `S' ⊆ {a} ∩ t` is nonempty, so its point is both `a` and a point of `t`. If no member is
a singleton, every member is the whole carrier and any point of any member serves. This is the
`⊆`-least-member argument `lem:step`'s closing remark uses, isolated so that the permissive and
equality classes can both cite it.
-/
theorem sInter_nonempty_of_directed_of_univ_or_singleton {W : Type} {S : Set (Set W)}
    (hdir : DirectedFamily S) (hne : ∀ s ∈ S, s.Nonempty)
    (hcls : ∀ s ∈ S, s = Set.univ ∨ ∃ a, s = {a}) : (⋂₀ S).Nonempty := by
  classical
  obtain ⟨s₀, hs₀⟩ := hdir.1
  by_cases hsing : ∃ s ∈ S, ∃ a : W, s = {a}
  · obtain ⟨s, hsS, a, rfl⟩ := hsing
    refine ⟨a, ?_⟩
    intro t ht
    obtain ⟨S', hS'S, hsub⟩ := hdir.2 _ hsS _ ht
    obtain ⟨c, hc⟩ := hne S' hS'S
    have hc' := hsub hc
    have hca : c = a := hc'.1
    rw [← hca]
    exact hc'.2
  · obtain ⟨a, ha⟩ := hne s₀ hs₀
    refine ⟨a, ?_⟩
    intro t ht
    rcases hcls t ht with hu | ⟨b, hb⟩
    · rw [hu]; exact Set.mem_univ a
    · exact absurd ⟨t, ht, b, hb⟩ hsing

/--
The *Spherical* core argument for a directed family that has a `⊆`-minimal member: **the paper's
actual mathematical content, in fully constructive form**.

Recorded source (`cor:spherical-finite`, via `specs/paper-definitions-of-record.md`, verbatim:
"Every task frame $\F = \tuple{W, \D, \Rightarrow}$ with finite $W$ satisfies \textit{Spherical},
choice-free."), whose argument is: directedness upgrades a `⊆`-minimal member to a `⊆`-*least*
member, and a least member is both nonempty and equal to the intersection.

Given a minimal `Sstar` and any other member `T`, directedness supplies `S' ∈ S` with
`S' ⊆ Sstar ∩ T`. Then `S' ⊆ Sstar`, so minimality forces `Sstar ⊆ S'`, and composing gives
`Sstar ⊆ T`. So `Sstar` is contained in every member, and any of its points — it is nonempty by
hypothesis — lies in `⋂₀ S`.

**This lemma depends on no axioms at all** (not even `propext`), which is the sense in which the
paper's choice-free claim survives transcription. The classical content of `cor:spherical-finite`
lives entirely in *producing* the minimal member from finiteness, which is what
`spherical_of_finite` below adds on top. Separating the two is deliberate: it puts the
constructive core on the record independently of the classical step, and it makes the lemma
reusable at any carrier where a minimal member is available by other means.

The companion `sInter_nonempty_of_directed_of_univ_or_singleton` above serves the disjoint case
where every member is the whole carrier or a singleton; neither subsumes the other.
-/
theorem sInter_nonempty_of_directed_of_minimal {W : Type} {S : Set (Set W)}
    (hd : ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂)
    (hne : ∀ s ∈ S, s.Nonempty)
    {Sstar : Set W} (hStarMem : Sstar ∈ S)
    (hStarMin : ∀ ⦃T⦄, T ∈ S → T ⊆ Sstar → Sstar ⊆ T) :
    (⋂₀ S).Nonempty := by
  have hsub : ∀ T ∈ S, Sstar ⊆ T := by
    intro T hT
    obtain ⟨S', hS'mem, hS'sub⟩ := hd Sstar hStarMem T hT
    have h1 : S' ⊆ Sstar := fun x hx => (hS'sub hx).1
    have h2 : Sstar ⊆ S' := hStarMin hS'mem h1
    exact fun x hx => (hS'sub (h2 hx)).2
  obtain ⟨x, hx⟩ := hne Sstar hStarMem
  exact ⟨x, fun T hT => hsub T hT hx⟩

omit [IsOrderedAddMonoid D] in
/--
**Every relation on a finite carrier satisfies *Spherical***.

Recorded source (`cor:spherical-finite`, via `specs/paper-definitions-of-record.md`, verbatim:
"Every task frame $\F = \tuple{W, \D, \Rightarrow}$ with finite $W$ satisfies \textit{Spherical},
choice-free."). Since `Set W` is well-founded under `<` when `W` is finite, a directed family has
a `⊆`-minimal member; `sInter_nonempty_of_directed_of_minimal` above then closes the goal.

**Indifferent to the kind of member.** The proof consumes only *finiteness*, *directedness*, and
*member nonemptiness*; the `IsFiber R s ∨ IsSegment R s` disjunct is never used. That matches the
paper's own `%% CHANGE (sigma-elim)` remark that the finite-`W` argument does not care whether a
member is a fiber or a segment.

**Obstruction note — why this lemma is not, and cannot be, `Classical.choice`-free.**
The paper's "choice-free" is a claim about **ZF vs ZFC**: the argument does not need the axiom of
choice, *given classical logic*. Lean's `Classical.choice` is a different object — the single
axiom from which Lean derives **both** excluded middle (via Diaconescu) and AC — so
`#print axioms` has no vocabulary in which to state the paper's distinction. Worse, the
`Classical.choice`-free version is not merely hard but **impossible**: weak excluded middle
(`¬¬P ∨ ¬P`) is derivable from `Spherical R` at the finite carrier `Bool` over `D = Int`, using
`R w d u := (d = 0 ∧ w = u) ∨ (d = 3)`, from `[propext, Quot.sound]` alone. A choice-free proof of
this lemma would therefore prove WLEM in Lean's intuitionistic core, where it is not derivable.
This is a mismatch between the paper's metatheory and Lean's axiom accounting, not a defect in
either. What *is* preserved, and what the corollary is actually for, is the absence of **Zorn**:
this proof does not route through `PartialHistory.exists_maximal_extension`, in deliberate
contrast with `thm:extension`, which does.

**Do not re-derive the existing class helpers from this lemma.** `spherical_of_subsingleton`
depends on exactly `[propext]`; routing it (or `spherical_of_permissive`, or `spherical_of_eq`)
through this lemma would regress it to `Classical.choice` and propagate that regression to the
three `Unit`-carriered universal frames that consume it. This lemma is an **additional** route for
relations of arbitrary shape — the case no existing helper covers, since each of those constrains
the relation's shape — never a consolidation of them.
-/
theorem spherical_of_finite {W : Type} [Finite W] (R : W → D → W → Prop) :
    Spherical R := by
  intro S hdir hmem
  obtain ⟨hne, hd⟩ := hdir
  obtain ⟨Sstar, hStarMem, hStarMin⟩ :=
    exists_minimal_of_wellFoundedLT (α := Set W) (fun s => s ∈ S) hne
  exact sInter_nonempty_of_directed_of_minimal hd (fun s hs => (hmem s hs).2) hStarMem hStarMin

/-! ### Helper A — the total class on a subsingleton carrier -/

omit [IsOrderedAddMonoid D] in
/--
*Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for
some $u, v \in W$") for a total relation: the state itself witnesses both conjuncts.
-/
theorem serial_of_total {W : Type} {R : W → D → W → Prop} (htot : ∀ w x u, R w x u) :
    Serial R := fun w _ _ => ⟨⟨w, htot _ _ _⟩, ⟨w, htot _ _ _⟩⟩

omit [IsOrderedAddMonoid D] in
/--
The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for a total relation: interpolate through the source state.
-/
theorem interpolates_of_total {W : Type} {R : W → D → W → Prop} (htot : ∀ w x u, R w x u) :
    Interpolates R := fun w _ _ _ _ _ _ => ⟨w, htot _ _ _, htot _ _ _⟩

omit [IsOrderedAddMonoid D] in
/--
*Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") on a
subsingleton carrier: there is nothing for `u` to be other than `w`. Stated in the literal
transcribed shape, so it is interchangeable with `limit_of_succOrder` and `limit_of_shift`.
-/
theorem limit_of_subsingleton {W : Type} [Subsingleton W] {R : W → D → W → Prop} :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w :=
  fun _ _ _ => Subsingleton.elim _ _

omit [IsOrderedAddMonoid D] in
/--
*Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") on a subsingleton
carrier: every
nonempty subset is the whole carrier, so the intersection of a nonempty family of nonempty sets
is nonempty. Independent of the relation.
-/
theorem spherical_of_subsingleton {W : Type} [Subsingleton W] {R : W → D → W → Prop} :
    Spherical R := by
  intro S hdir hmem
  obtain ⟨s₀, hs₀⟩ := hdir.1
  obtain ⟨a, ha⟩ := (hmem s₀ hs₀).2
  refine ⟨a, ?_⟩
  intro t ht
  obtain ⟨b, hb⟩ := (hmem t ht).2
  rw [Subsingleton.elim a b]
  exact hb

/-! ### Helper B — the permissive class `R w d u ↔ (d ≠ 0 ∨ w = u)` -/

omit [LinearOrder D] [IsOrderedAddMonoid D] in
/-- Zero-duration fibers of a permissive relation are singletons. -/
theorem Fib_permissive_zero {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) (w : W) : Fib R w 0 = {w} := by
  ext u; simp [Fib, hR, eq_comm]

omit [LinearOrder D] [IsOrderedAddMonoid D] in
/-- Nonzero-duration fibers of a permissive relation are the whole carrier. -/
theorem Fib_permissive_ne {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) (w : W) {x : D} (hx : x ≠ 0) :
    Fib R w x = Set.univ := by
  ext u; simp [Fib, hR, hx]

omit [IsOrderedAddMonoid D] in
/--
*Seriality* for a permissive relation: the state itself is both an `x`-successor and an
`x`-predecessor at every duration, via the `w = u` disjunct.
-/
theorem serial_of_permissive {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) : Serial R := fun w x _ =>
  ⟨⟨w, (hR w x w).mpr (Or.inr rfl)⟩, ⟨w, (hR w x w).mpr (Or.inr rfl)⟩⟩

omit [IsOrderedAddMonoid D] in
/--
The interpolation half of *Compositionality* for a permissive relation.

Interpolate through `w` when `y ≠ 0` (the second leg is then free) and through `v` when `y = 0`
(the first leg is then free, because `0 ≤ x`, `0 ≤ y` and `x + y ≠ 0` force `x ≠ 0`). When the
hypothesis came from the `w = v` disjunct, `w` serves for both legs.
-/
theorem interpolates_of_permissive {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) : Interpolates R := by
  intro w v x y _ _ h
  rcases (hR w (x + y) v).mp h with hxy | hwv
  · by_cases hy : y = 0
    · refine ⟨v, (hR w x v).mpr (Or.inl ?_), (hR v y v).mpr (Or.inr rfl)⟩
      intro hx0
      exact hxy (by rw [hx0, hy, add_zero])
    · exact ⟨w, (hR w x w).mpr (Or.inr rfl), (hR w y v).mpr (Or.inl hy)⟩
  · exact ⟨w, (hR w x w).mpr (Or.inr rfl), (hR w y v).mpr (Or.inr hwv)⟩

/--
*Limit* for a permissive relation over a discrete duration type.

A permissive relation satisfies iff-Nullity (`R w 0 u ↔ w = u`), so `limit_of_succOrder`
applies verbatim. The `[SuccOrder D] [NoMaxOrder D]` restriction is not removable: over a dense
`D` every state lies in every cone of every other state (pick any `y ≠ 0` with `|y| < x`), and
*Limit* fails outright.
-/
theorem limit_of_permissive [SuccOrder D] [NoMaxOrder D] {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w :=
  limit_of_succOrder (fun w u => by rw [hR]; simp)

omit [IsOrderedAddMonoid D] in
/--
Every nonempty fiber or segment of a permissive relation is the whole carrier or a singleton.

Fibers are the carrier at nonzero duration and a singleton at zero. A segment
`[w, v]_x^y = \Fib(w, x) ∩ \Fib(v, -y)` is therefore an intersection of two such sets; when both
offsets vanish the two singletons must coincide for the segment to be nonempty.
-/
theorem univ_or_singleton_of_permissive {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) {s : Set W}
    (hcls : IsFiber R s ∨ IsSegment R s) (hne : s.Nonempty) :
    s = Set.univ ∨ ∃ a, s = {a} := by
  rcases hcls with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
  · by_cases hx : x = 0
    · subst hx; exact Or.inr ⟨w, Fib_permissive_zero hR w⟩
    · exact Or.inl (Fib_permissive_ne hR w hx)
  · by_cases hx : x = 0
    · by_cases hy : y = 0
      · subst hx; subst hy
        obtain ⟨c, hc⟩ := hne
        rw [mem_Seg] at hc
        have hwc : w = c := by
          have := (hR w 0 c).mp hc.1; simpa using this
        have hvc : v = c := by
          have := (hR v (-0) c).mp hc.2; simpa using this
        refine Or.inr ⟨c, ?_⟩
        rw [Seg, neg_zero, hwc, hvc, Fib_permissive_zero hR c, Set.inter_self]
      · subst hx
        refine Or.inr ⟨w, ?_⟩
        rw [Seg, Fib_permissive_zero hR w,
          Fib_permissive_ne hR v (by simpa using hy), Set.inter_univ]
    · by_cases hy : y = 0
      · subst hy
        refine Or.inr ⟨v, ?_⟩
        rw [Seg, Fib_permissive_ne hR w hx, neg_zero, Fib_permissive_zero hR v,
          Set.univ_inter]
      · exact Or.inl (by
          rw [Seg, Fib_permissive_ne hR w hx, Fib_permissive_ne hR v (by simpa using hy),
            Set.inter_self])

omit [IsOrderedAddMonoid D] in
/--
*Spherical* for a permissive relation: its nonempty fibers and segments are each the whole
carrier or a singleton, so the directed-family argument
`sInter_nonempty_of_directed_of_univ_or_singleton` applies. No restriction on `D` is needed.
-/
theorem spherical_of_permissive {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ (d ≠ 0 ∨ w = u)) : Spherical R := by
  intro S hdir hmem
  exact sInter_nonempty_of_directed_of_univ_or_singleton hdir (fun s hs => (hmem s hs).2)
    (fun s hs => univ_or_singleton_of_permissive hR (hmem s hs).1 (hmem s hs).2)

/-! ### Helper C — the equality class `R w d u ↔ w = u` -/

omit [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] in
/-- Every fiber of an equality relation is the singleton of its base point. -/
theorem Fib_eq_singleton {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ w = u) (w : W) (x : D) : Fib R w x = {w} := by
  ext u; simp [Fib, hR, eq_comm]

omit [IsOrderedAddMonoid D] in
/-- *Seriality* for an equality relation: the state is its own successor and predecessor. -/
theorem serial_of_eq {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ w = u) : Serial R := fun w x _ =>
  ⟨⟨w, (hR w x w).mpr rfl⟩, ⟨w, (hR w x w).mpr rfl⟩⟩

omit [IsOrderedAddMonoid D] in
/--
The interpolation half of *Compositionality* for an equality relation: interpolate through the
source state, which is the target state.
-/
theorem interpolates_of_eq {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ w = u) : Interpolates R := by
  intro w v x y _ _ h
  exact ⟨w, (hR w x w).mpr rfl, (hR w y v).mpr ((hR w (x + y) v).mp h)⟩

/--
*Limit* for an equality relation: nothing but `w` is reachable from `w` at any duration, so a
single positive radius already forces `u = w`. `[Nontrivial D]` is what supplies that radius, and
is not removable — over a trivial duration group the *Limit* hypothesis is vacuous.
-/
theorem limit_of_eq [Nontrivial D] {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ w = u) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w := by
  intro w u h
  obtain ⟨x₀, hx₀⟩ := exists_pos_of_nontrivial (D := D)
  obtain ⟨y, _, hR'⟩ := h x₀ hx₀
  exact ((hR w y u).mp hR').symm

omit [IsOrderedAddMonoid D] in
/--
*Spherical* for an equality relation: every fiber is a singleton and every segment is an
intersection of two singletons, so every nonempty member of a directed family is a singleton and
`sInter_nonempty_of_directed_of_univ_or_singleton` applies.
-/
theorem spherical_of_eq {W : Type} {R : W → D → W → Prop}
    (hR : ∀ w d u, R w d u ↔ w = u) : Spherical R := by
  intro S hdir hmem
  refine sInter_nonempty_of_directed_of_univ_or_singleton hdir (fun s hs => (hmem s hs).2)
    (fun s hs => ?_)
  obtain ⟨hcl, hne⟩ := hmem s hs
  rcases hcl with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
  · exact Or.inr ⟨w, Fib_eq_singleton hR w x⟩
  · obtain ⟨c, hc⟩ := hne
    rw [mem_Seg] at hc
    have hwc : w = c := (hR w x c).mp hc.1
    have hvc : v = c := (hR v (-y) c).mp hc.2
    refine Or.inr ⟨c, ?_⟩
    rw [Seg, hwc, hvc, Fib_eq_singleton hR c x, Fib_eq_singleton hR c (-y), Set.inter_self]

end TaskFrame

/-! ## Frame constants

Three small frames used throughout the tree and the test suite, each a value of the fibre over
the temporal order of an ambient carrier `D`. They live in `FrameOver` so that dot notation on
a fibre-typed frame reaches them.
-/

namespace FrameOver

open TaskFrame

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/--
Simple unit-based task frame for testing.

World states are Unit (trivial), task relation is always true.
This is the simplest possible task frame, polymorphic over temporal type `D`.
-/
def trivialFrame {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] :
    FrameOver (TemporalOrder.of D) where
  WorldState := Unit
  worldNonempty := inferInstanceAs (Nonempty Unit)
  TaskRel := fun _ _ _ => True
  nullity_identity := fun _ _ => ⟨fun _ => Subsingleton.elim _ _, fun _ => trivial⟩
  comp := comp_of (interpolates_of_total fun _ _ _ => trivial) fun _ _ _ _ _ _ _ _ _ => trivial
  converse := fun _ _ _ => ⟨fun _ => trivial, fun _ => trivial⟩
  serial := serial_of_total fun _ _ _ => trivial
  limit := limit_of_subsingleton
  spherical := spherical_of_subsingleton

/-! #### `trivialFrame` discharges `def:frame`'s four axioms (total class, Helper A) -/

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `trivialFrame`: its relation is total. -/
theorem trivialFrame_serial : Serial (trivialFrame (D := D)).TaskRel :=
  serial_of_total fun _ _ _ => trivial

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `trivialFrame`: its relation is total. -/
theorem trivialFrame_interpolates : Interpolates (trivialFrame (D := D)).TaskRel :=
  interpolates_of_total fun _ _ _ => trivial

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`trivialFrame`, in the literal transcribed shape: its carrier is `Unit`. -/
theorem trivialFrame_limit :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ (trivialFrame (D := D)).TaskRel w y u) → u = w := by
  haveI : Subsingleton (trivialFrame (D := D)).WorldState := inferInstanceAs (Subsingleton Unit)
  exact limit_of_subsingleton

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") for `trivialFrame`:
its carrier
is `Unit`, so every nonempty subset is the whole carrier. -/
theorem trivialFrame_spherical : Spherical (trivialFrame (D := D)).TaskRel := by
  haveI : Subsingleton (trivialFrame (D := D)).WorldState := inferInstanceAs (Subsingleton Unit)
  exact spherical_of_subsingleton

/--
Static task frame: every world state is related to itself, and only itself, at every duration.

World states can be any type. `TaskRel w x u` holds iff `w = u`, for every duration `x`:
nothing ever changes, at any timescale. Polymorphic over both world state type and temporal
type.

This frame replaces the former zero-duration-only identity frame
(`TaskRel := fun w x u => w = u ∧ x = 0`), which violated the paper's *Seriality* axiom
(`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some
$u, v \in W$") over every nontrivial duration type: at any `x > 0` no successor existed. The
static relation satisfies all four recorded axioms of `def:frame` — *Compositionality* in both
directions (interpolate through `w` itself), *Seriality* (`staticFrame_serial` below),
*Limit* (only `w` is reachable from `w` at all), and *Spherical* (every nonempty fiber and
segment is the same singleton along a directed family) — as well as every field of the current
structure.

The `[Nontrivial D]` binder is carried because `staticFrame_limit` requires it: over a trivial
duration type `0 < x` is unsatisfiable, so *Limit*'s hypothesis is vacuous and the conclusion
`u = w` cannot be reached. Every reference to this frame elaborates at `Int`, which supplies the
instance.
-/
def staticFrame (W : Type) [Nonempty W] {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    FrameOver (TemporalOrder.of D) where
  WorldState := W
  worldNonempty := inferInstance
  TaskRel := fun w _ u => w = u
  nullity_identity := fun _ _ => Iff.rfl
  comp := comp_of (interpolates_of_eq fun _ _ _ => Iff.rfl) fun _ _ _ _ _ _ _ h1 h2 => h1.trans h2
  converse := fun _ _ _ => ⟨Eq.symm, Eq.symm⟩
  serial := serial_of_eq fun _ _ _ => Iff.rfl
  limit := limit_of_eq fun _ _ _ => Iff.rfl
  spherical := spherical_of_eq fun _ _ _ => Iff.rfl

/-! #### `staticFrame` discharges `def:frame`'s four axioms (equality class, Helper C) -/

/--
The static frame's relation is the equality class: `TaskRel w x u` holds exactly when `w = u`,
at every duration. This is the class-membership witness Helper C's lemmas consume.
-/
theorem staticFrame_rel_iff [Nontrivial D] (W : Type) [Nonempty W] :
    ∀ w d u, (staticFrame W (D := D)).TaskRel w d u ↔ w = u := fun _ _ _ => Iff.rfl

/--
The static frame satisfies the paper's *Seriality* axiom (`def:frame#Seriality`, verbatim:
"$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$"): at every duration the
state itself is both a successor and a predecessor.

Stated as `Serial` — the bare-relation predicate of record — rather than as an unfolded
conjunction, so that it is citable verbatim for the frame's *Seriality* field. The paper's
`x ≥ 0` proviso is `Serial`'s own hypothesis and is simply unused here, since the witness works
at every duration.
-/
theorem staticFrame_serial [Nontrivial D] (W : Type) [Nonempty W] :
    Serial (staticFrame W (D := D)).TaskRel :=
  serial_of_eq (staticFrame_rel_iff W)

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `staticFrame`: interpolate through `w` itself. -/
theorem staticFrame_interpolates [Nontrivial D] (W : Type) [Nonempty W] :
    Interpolates (staticFrame W (D := D)).TaskRel :=
  interpolates_of_eq (staticFrame_rel_iff W)

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`staticFrame`, in the literal transcribed shape: only `w` is reachable from `w` at all. -/
theorem staticFrame_limit [Nontrivial D] (W : Type) [Nonempty W] :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ (staticFrame W (D := D)).TaskRel w y u) → u = w :=
  limit_of_eq (staticFrame_rel_iff W)

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") for `staticFrame`:
every nonempty
fiber and segment is the same singleton along a directed family. -/
theorem staticFrame_spherical [Nontrivial D] (W : Type) [Nonempty W] :
    Spherical (staticFrame W (D := D)).TaskRel :=
  spherical_of_eq (staticFrame_rel_iff W)

/--
Natural number based task frame.

World states are natural numbers. Task relation: `TaskRel w d u` holds iff
either `d ≠ 0` (any transition for non-zero duration) or `w = u` (identity for zero duration).
This satisfies nullity_identity while remaining permissive.
Polymorphic over temporal type `D`.

The `[SuccOrder D] [NoMaxOrder D]` binders are carried because `natFrame_limit` requires them:
over a dense `D` the permissive relation puts every state in every cone of every other state and
*Limit* (`def:frame#Limit`) fails outright. Every reference to this frame outside
`WorldHistory.universalNatFrame` elaborates at `Int`, which supplies both instances.
-/
def natFrame {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [SuccOrder D] [NoMaxOrder D] :
    FrameOver (TemporalOrder.of D) where
  WorldState := Nat
  worldNonempty := inferInstanceAs (Nonempty Nat)
  TaskRel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h
      cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h
      right; exact h
  comp := comp_of (interpolates_of_permissive fun _ _ _ => Iff.rfl)
    fun w u v x y hx hy h1 h2 => by
      -- Need: x + y ≠ 0 ∨ w = v
      -- Key fact: if 0 ≤ x and 0 ≤ y and x + y = 0, then x = 0 and y = 0
      cases h1 with
      | inl hxne =>
        -- x ≠ 0 but 0 ≤ x, so x > 0. If x + y = 0 then y = -x < 0, contradicting 0 ≤ y
        left
        intro heq
        -- From x + y = 0: y = -x
        have hy_eq : y = -x := (neg_eq_of_add_eq_zero_right heq).symm
        have h1 : 0 ≤ -x := hy_eq ▸ hy
        have h2 : x ≤ 0 := neg_nonneg.mp h1
        have h3 : x = 0 := le_antisymm h2 hx
        exact hxne h3
      | inr hw =>
        cases h2 with
        | inl hyne =>
          left
          intro heq
          -- From x + y = 0: x = -y
          have hx_eq : x = -y := (neg_eq_of_add_eq_zero_left heq).symm
          have h1 : 0 ≤ -y := hx_eq ▸ hx
          have h2 : y ≤ 0 := neg_nonneg.mp h1
          have h3 : y = 0 := le_antisymm h2 hy
          exact hyne h3
        | inr hu => right; exact hw.trans hu
  serial := serial_of_permissive fun _ _ _ => Iff.rfl
  limit := limit_of_permissive fun _ _ _ => Iff.rfl
  spherical := spherical_of_permissive fun _ _ _ => Iff.rfl
  converse := fun w d u => by
    constructor
    · intro h
      cases h with
      | inl hd => left; simp [hd]
      | inr heq => right; exact heq.symm
    · intro h
      cases h with
      | inl hnd => left; simp only [ne_eq, neg_eq_zero] at hnd; exact hnd
      | inr heq => right; exact heq.symm

/-! #### `natFrame` discharges `def:frame`'s four axioms (permissive class, Helper B) -/

/--
The natural-number frame's relation is the permissive class: `TaskRel w d u` holds exactly when
`d ≠ 0` or `w = u`. This is the class-membership witness Helper B's lemmas consume.
-/
theorem natFrame_rel_iff [SuccOrder D] [NoMaxOrder D] :
    ∀ w d u, (natFrame (D := D)).TaskRel w d u ↔ (d ≠ 0 ∨ w = u) := fun _ _ _ => Iff.rfl

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `natFrame`, via the `w = u` disjunct. -/
theorem natFrame_serial [SuccOrder D] [NoMaxOrder D] : Serial (natFrame (D := D)).TaskRel :=
  serial_of_permissive natFrame_rel_iff

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `natFrame`. -/
theorem natFrame_interpolates [SuccOrder D] [NoMaxOrder D] :
    Interpolates (natFrame (D := D)).TaskRel :=
  interpolates_of_permissive natFrame_rel_iff

/--
*Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for `natFrame`,
in the literal transcribed shape — **over a discrete duration type only**.

`[SuccOrder D] [NoMaxOrder D]` is carried by this lemma rather than by `natFrame` itself, and the
restriction is not an artifact: over a dense `D` the permissive relation puts every state in
every cone of every other state, and *Limit* fails outright. `natFrame` itself now carries these
two instances, so that this lemma discharges the frame's *Limit* field; the only declaration that
propagation reached is `WorldHistory.universalNatFrame`, which is itself polymorphic in `D` and
has no consumers of its own. Every other reference to `natFrame` in the library and test suite
elaborates at `Int`, which carries both instances.
-/
theorem natFrame_limit [SuccOrder D] [NoMaxOrder D] :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ (natFrame (D := D)).TaskRel w y u) → u = w :=
  limit_of_permissive natFrame_rel_iff

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") for `natFrame`:
every nonempty
fiber and segment is the whole carrier or a singleton, and a directed family cannot contain two
distinct singletons. No restriction on `D` is needed. -/
theorem natFrame_spherical [SuccOrder D] [NoMaxOrder D] :
    Spherical (natFrame (D := D)).TaskRel :=
  spherical_of_permissive natFrame_rel_iff

end FrameOver

/-!
# Finite Task Frames and Models

This section extends task frames with explicit finiteness constraints.
These structures bundle the finiteness property for convenience in stating
the Finite Model Property for TM logic.
-/

open FrameOver TaskFrame

namespace FiniteFrameOver

variable {D : TemporalOrder}

/--
A finite fibre is a fibre: the parent projection, as a coercion, so that every definition and
theorem stated over `FrameOver` applies to a `FiniteFrameOver` with no restatement.
-/
instance : Coe (FiniteFrameOver D) (FrameOver D) where
  coe F := F.toFrameOver

end FiniteFrameOver

/-!
# The bundled frame

`def:frame` reads a task frame as `F = ⟨W, 𝔇, ⇒⟩`: the temporal order is a *component* of the
frame, on the same footing as the world-state carrier and the task relation. `TaskFrame` carries
it as the field `Duration`, so the encoding unfolds exactly as the paper writes it, and
`FrameOver D` above is the fibre over a fixed such component.

The consequence that motivates the shape: a property of the temporal order alone cannot be
predicated of a frame while the order is an *index*, so density, discreteness and Dedekind
completeness would have to be quantified at the carrier rather than asserted of the frame. With
`Duration` a field they are ordinary predicates on a `TaskFrame` — `def:frame-properties` reads
as the paper states it.

The transitional aliases and bridge definitions that carried the migration have been removed;
`FrameOver.toTaskFrame` and `instCoeOutFrameOver` are their permanent replacements.
-/

/--
**A task frame** `F = ⟨W, D, ⇒⟩` (`def:frame`), with the temporal order carried as the field
`Duration`.

The algebra of `Duration` — abelian group, linear order, order-compatible addition,
nontriviality: `def:temporal-order`'s "nontrivial totally ordered abelian group" — is carried
as instance-implicit *fields* rather than as instance binders on the structure, for the reason
already recorded for `worldNonempty`: a binder must be supplied at every mention of the type,
whereas a field is discharged once per frame at its construction site.

Instance-implicit fields are in scope for the types of later fields, so the four axiom fields
still cite the bare-relation predicates of record *definitionally* — see the definitional-content
`example`s at the end of this module, which are what keep the frame and the Step Lemma chain
from drifting apart.
-/
structure TaskFrame where
  /-- The temporal order: the type of task durations (`def:temporal-order`). -/
  Duration : TemporalOrder
  /-- The frame's world states, task relation and axioms, over that temporal order. -/
  toFibre : FrameOver Duration

/--
A bundled task frame with finitely many world states — the total space of the *finite* fibration.
-/
structure FiniteTaskFrame where
  /-- The temporal order (`def:temporal-order`). -/
  Duration : TemporalOrder
  /-- The finite fibre over that temporal order. -/
  toFibre : FiniteFrameOver Duration

namespace FrameOver

/--
**The canonical inclusion of a fibre into the total space.**

This is the constructor. `FrameOver D → TaskFrame` needs no coercion, no transport and no
universe crossing: a frame over `D` *is* the second component of a total-space frame whose first
component is `D`, and `(F.toTaskFrame).toFibre = F`, `(F.toTaskFrame).Duration = D` and
`⟨G.Duration, G.toFibre⟩ = G` all hold by `rfl`.
-/
@[reducible] def toTaskFrame {D : TemporalOrder} (F : FrameOver D) : TaskFrame := ⟨D, F⟩

end FrameOver

/--
**A fibre value is usable wherever the total space is expected**, via the inclusion.

`WorldHistory`, `TaskModel` and `TruthAt` are stated over `TaskFrame`, so every fibre-typed frame
has to reach the total space to be used with them. Writing `.toTaskFrame` at each such site would
be pure noise: the inclusion is the constructor and carries no content.

This was introduced as the permanent replacement for the migration's transitional `CoeOut`, and the
reason that one can be deleted without a per-site campaign. It also covers the case that
instance no longer can: for an *abstract* `(D : TemporalOrder)`, matching
a `FrameOver ⟨?E⟩`-shaped instance against `FrameOver D` needs structure eta on `D` at
reducible transparency, which instance resolution does not perform. Both coercions produce the
same term — `⟨D, F⟩` — so which one fires is never observable.
-/
instance instCoeOutFrameOver {D : TemporalOrder} : CoeOut (FrameOver D) TaskFrame :=
  ⟨FrameOver.toTaskFrame⟩

namespace FiniteFrameOver

/-- The inclusion of a finite fibre into the finite total space — again the constructor. -/
@[reducible] def toFiniteTaskFrame {D : TemporalOrder} (F : FiniteFrameOver D) :
    FiniteTaskFrame := ⟨D, F⟩

end FiniteFrameOver

namespace TaskFrame

/-!
### The flat surface, preserved

`TaskFrame`'s fields are `Duration` and `toFibre`, but every consumer in the tree writes
`F.WorldState`, `F.TaskRel w d u` and `F.spherical`. Generalized field notation resolves by the
head constant of `F`'s type and never consults a coercion, so those spellings are kept alive as
**delegating accessors** rather than by asking several hundred sites to write `F.toFibre.…`.

The data accessors are `@[reducible]`, which is what keeps `F.WorldState` transparent to
unification and to instance synthesis. The Prop-valued ones are `theorem`s: Lean rejects
`@[reducible]` on a proof, and by proof irrelevance nothing is lost — what a consumer needs is
that the *declared type* is literally the recorded bare-relation predicate at `F.TaskRel`, which
it is, so the Step Lemma's consumption of `F.spherical` stays definitional at both levels.
-/

/-- The frame's type of world states. -/
@[reducible] def WorldState (F : TaskFrame) : Type := F.toFibre.WorldState

/-- The world-state type is nonempty (`def:task-relation` reads `W` as a nonempty set). -/
instance worldNonempty (F : TaskFrame) : Nonempty F.WorldState := F.toFibre.worldNonempty

/-- Task relation: `TaskRel w x u` means `u` is reachable from `w` by a task of duration `x`. -/
@[reducible] def TaskRel (F : TaskFrame) : F.WorldState → F.Duration → F.WorldState → Prop :=
  F.toFibre.TaskRel

/-- Zero-duration tasks relate exactly identical states (`lem:nullity` plus its
injectivity-at-zero converse). -/
theorem nullity_identity (F : TaskFrame) : ∀ w u, F.TaskRel w 0 u ↔ w = u :=
  F.toFibre.nullity_identity

/-- *Compositionality* (`def:frame#Compositionality`), whole, by citation. -/
theorem comp (F : TaskFrame) : TaskFrame.Compositional F.TaskRel := F.toFibre.comp

/-- The definitional converse convention (`def:task-relation`). -/
theorem converse (F : TaskFrame) : ∀ w d u, F.TaskRel w d u ↔ F.TaskRel u (-d) w :=
  F.toFibre.converse

/-- *Seriality* (`def:frame#Seriality`), by citation. -/
theorem serial (F : TaskFrame) : TaskFrame.Serial F.TaskRel := F.toFibre.serial

/-- *Limit* (`def:frame#Limit`), in the literal transcribed shape. -/
theorem limit (F : TaskFrame) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ F.TaskRel w y u) → u = w := F.toFibre.limit

/-- *Spherical* (`def:frame#Spherical`), by citation. This is the field the Step Lemma consumes,
which is why it must be literally the recorded predicate. -/
theorem spherical (F : TaskFrame) : TaskFrame.Spherical F.TaskRel := F.toFibre.spherical

end TaskFrame

namespace FiniteTaskFrame

/-- A finite total-space frame is a total-space frame. -/
@[reducible] def toTaskFrame (F : FiniteTaskFrame) : TaskFrame := ⟨F.Duration, F.toFibre.toFrameOver⟩

/-- The frame's type of world states. -/
@[reducible] def WorldState (F : FiniteTaskFrame) : Type := F.toFibre.toFrameOver.WorldState

/-- The task relation. -/
@[reducible] def TaskRel (F : FiniteTaskFrame) : F.WorldState → F.Duration → F.WorldState → Prop :=
  F.toFibre.toFrameOver.TaskRel

/-- The set of world states is finite. -/
theorem finite_world (F : FiniteTaskFrame) : Finite F.WorldState := F.toFibre.finite_world

end FiniteTaskFrame

namespace TaskFrame

/-!
### The derived frame API, bundled

The four results below are the bundled-frame spellings of `FrameOver.forward_comp`,
`.interpolates`, `.nullity` and `.backward_comp`. Each has the same proof and the same content;
they exist separately only because generalized field notation resolves `F.forward_comp` through
the head constant of `F`'s type, which the `CoeOut` above does not reach.
-/

/-- **Composition on the positive cone — the `←` projection of the `comp` field.** -/
theorem forward_comp (F : TaskFrame) (w u v : F.WorldState) (x y : F.Duration)
    (hx : 0 ≤ x) (hy : 0 ≤ y) (h1 : F.TaskRel w x u) (h2 : F.TaskRel u y v) :
    F.TaskRel w (x + y) v :=
  TaskFrame.forward_of_comp F.comp w u v x y hx hy h1 h2

/-- **Interpolation — the `→` projection of the `comp` field**, as the bare-relation predicate
of record. -/
theorem interpolates (F : TaskFrame) : TaskFrame.Interpolates F.TaskRel :=
  TaskFrame.interpolates_of_comp F.comp

/-- Derived nullity: the zero-duration task is reflexive (`lem:nullity`). -/
theorem nullity (F : TaskFrame) (w : F.WorldState) : F.TaskRel w 0 w :=
  F.nullity_identity w w |>.mpr rfl

/-- Derived backward compositionality, from `forward_comp` and `converse`. -/
theorem backward_comp (F : TaskFrame) (w u v : F.WorldState) (x y : F.Duration)
    (hx : x ≤ 0) (hy : y ≤ 0)
    (h1 : F.TaskRel w x u) (h2 : F.TaskRel u y v) :
    F.TaskRel w (x + y) v := by
  have h1' : F.TaskRel u (-x) w := F.converse w x u |>.mp h1
  have h2' : F.TaskRel v (-y) u := F.converse u y v |>.mp h2
  have hx' : 0 ≤ -x := neg_nonneg.mpr hx
  have hy' : 0 ≤ -y := neg_nonneg.mpr hy
  have h3 : F.TaskRel v ((-y) + (-x)) w := F.forward_comp v u w (-y) (-x) hy' hx' h2' h1'
  have h4 : -y + -x = -(x + y) := by simp [neg_add_rev, add_comm]
  rw [h4] at h3
  exact F.converse w (x + y) v |>.mpr h3

end TaskFrame

section BridgeChecks

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

-- The inclusion is a definitional isomorphism: both round trips are `rfl` by structure eta.
example (F : TaskFrame) : F.toFibre.toTaskFrame = F := rfl
example {E : TemporalOrder} (F : FrameOver E) : F.toTaskFrame.toFibre = F := rfl
example {E : TemporalOrder} (F : FrameOver E) : F.toTaskFrame.Duration = E := rfl

-- The exported algebra on a bundled frame's `Duration`.
example (F : TaskFrame) (x y : F.Duration) : x + y = y + x := add_comm x y
example (F : TaskFrame) (x y : F.Duration) : x ≤ y ∨ y ≤ x := le_total x y
example (F : TaskFrame) : ∃ x y : F.Duration, x ≠ y := exists_pair_ne F.Duration
example (F : TaskFrame) : Nonempty F.WorldState := inferInstance

end BridgeChecks

/-! ## The total-space identity

`TaskFrame` is `Σ (D : TemporalOrder), FrameOver D`, and structure eta makes that an identity
rather than an isomorphism-up-to-transport: the pair of a frame's two projections *is* the frame,
by `rfl`. The inclusion of a fibre is the constructor, so its round-trip facts are `rfl` too.
This is what replaces v01's `CoeOut` device, and it is why there is no shim ledger in this
refactor.
-/

section TotalSpaceIdentity

example (F : TaskFrame) : (⟨F.Duration, F.toFibre⟩ : TaskFrame) = F := rfl

example {D : TemporalOrder} (F : FrameOver D) : (FrameOver.toTaskFrame F).Duration = D := rfl
example {D : TemporalOrder} (F : FrameOver D) : (FrameOver.toTaskFrame F).toFibre = F := rfl
example {D : TemporalOrder} (F : FrameOver D) :
    (FrameOver.toTaskFrame F).WorldState = F.WorldState := rfl
example {D : TemporalOrder} (F : FrameOver D) :
    (FrameOver.toTaskFrame F).TaskRel = F.TaskRel := rfl

/-- The flat accessors are the fibre's fields, definitionally -- which is what keeps the already
migrated files' spellings (`F.WorldState`, `F.TaskRel w d u`, `F.spherical`) meaning exactly what
they meant before. -/
example (F : TaskFrame) : F.WorldState = F.toFibre.WorldState := rfl
example (F : TaskFrame) : F.TaskRel = F.toFibre.TaskRel := rfl

/-- A finite total-space frame forgets to a total-space frame by the same constructor. -/
example (F : FiniteTaskFrame) : F.toTaskFrame.Duration = F.Duration := rfl
example (F : FiniteTaskFrame) : F.toTaskFrame.WorldState = F.WorldState := rfl

end TotalSpaceIdentity

/-! ## The definitional-content checks, bundled form

The same check as the parameterized one at the end of this module: each axiom field of the
bundled `TaskFrame` is *literally* the recorded bare-relation predicate, so the Step Lemma's
consumption of `spherical` stays definitional.
-/

section BundledDefinitionalContent

example (F : TaskFrame) : TaskFrame.Serial F.TaskRel := F.serial

example (F : TaskFrame) : TaskFrame.Spherical F.TaskRel := F.spherical

example (F : TaskFrame) : TaskFrame.Compositional F.TaskRel := F.comp

example (F : TaskFrame) : TaskFrame.Interpolates F.TaskRel :=
  TaskFrame.interpolates_of_comp F.comp

example (F : TaskFrame) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ F.TaskRel w y u) → u = w := F.limit

example (F : FiniteTaskFrame) : TaskFrame.Spherical F.TaskRel := by
  haveI := F.finite_world
  exact TaskFrame.spherical_of_finite F.TaskRel

end BundledDefinitionalContent


/-! ## The definitional-content checks

The Cross-Task Acceptance Criterion for the four axiom fields is that each is *literally* the
recorded bare-relation predicate, never an equivalent restatement — because the Step Lemma
(`Semantics/Extension/Step.lean`) consumes the predicates, and an inert field that merely
implied them would let the frame and the chain drift apart silently.

These four `example`s are that check, mechanized: each elaborates by `rfl` alone, and would fail
the moment a field's statement were restated rather than cited.
-/

section DefinitionalContent

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

example {E : TemporalOrder} (F : FrameOver E) : TaskFrame.Serial F.TaskRel := F.serial

example {E : TemporalOrder} (F : FrameOver E) : TaskFrame.Spherical F.TaskRel := F.spherical

example {E : TemporalOrder} (F : FrameOver E) : TaskFrame.Compositional F.TaskRel := F.comp

example {E : TemporalOrder} (F : FrameOver E) : TaskFrame.Interpolates F.TaskRel := F.interpolates

example {E : TemporalOrder} (F : FrameOver E) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ F.TaskRel w y u) → u = w := F.limit

/--
`TaskFrame.spherical_of_finite` applies to a bundled `FiniteFrameOver` — the shape every finite
construction actually has. `finite_world` is a plain *field*, not an instance, so the `haveI` is
required at every such use site; that is what this check pins.
-/
example {E : TemporalOrder} (F : FiniteFrameOver E) : TaskFrame.Spherical F.TaskRel := by
  haveI := F.finite_world
  exact TaskFrame.spherical_of_finite F.TaskRel

end DefinitionalContent

/-! ## The fibre's definitional content

The same check at `FrameOver`, which is the sole declaration site of the frame axioms: each axiom
field is *literally* the recorded bare-relation predicate, and a frame written over an ambient
carrier through `TemporalOrder.of` is the same fibre — definitionally, not by a coercion.
-/

section FibreDefinitionalContent

variable {D : TemporalOrder}

example (F : FrameOver D) : TaskFrame.Serial F.TaskRel := F.serial
example (F : FrameOver D) : TaskFrame.Spherical F.TaskRel := F.spherical
example (F : FrameOver D) : TaskFrame.Compositional F.TaskRel := F.comp
example (F : FrameOver D) : TaskFrame.Interpolates F.TaskRel :=
  TaskFrame.interpolates_of_comp F.comp
example (F : FrameOver D) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ F.TaskRel w y u) → u = w := F.limit
example (F : FrameOver D) : Nonempty F.WorldState := inferInstance

/-- An ambient carrier and its four algebra binders name a fibre through `TemporalOrder.of`, and
that is the only spelling a frame over an ambient carrier now needs. -/
example (E : Type) [AddCommGroup E] [LinearOrder E] [IsOrderedAddMonoid E] [Nontrivial E] :
    (↑(TemporalOrder.of E) : Type) = E := rfl

/-- At the integers the fibre is `FrameOver intOrder`, and numerals elaborate at it. -/
example : TemporalOrder.of ℤ = intOrder := rfl
example (F : FrameOver intOrder) (w u : F.WorldState) : Prop := F.TaskRel w 1 u

/-- `FiniteFrameOver` sits over `FrameOver` by its parent projection. -/
example (F : FiniteFrameOver D) : FrameOver D := F.toFrameOver

end FibreDefinitionalContent

end FormalSystem.Semantics
