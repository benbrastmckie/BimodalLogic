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

/-!
# TaskFrame - Task Frame Structure for TM Semantics

This module defines task frames, the fundamental semantic structures for bimodal logic TM.

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
  directed family $\mathcal{S}$ of nonempty fibers and segments."

Nullity is NOT an axiom. The paper's `lem:nullity` (verbatim: "$w \Rightarrow_0 w$ for every
world state $w \in W$ in every frame $\F = \tuple{W, \D, \Rightarrow}$.") is DERIVED,
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
- `forward_comp` is the `←` (composition) HALF of the paper's biconditional *Compositionality*;
  the `→` (interpolation) direction is a known gap that lands with the structure change.
- `nullity_identity` is an iff, strictly STRONGER than the paper's derived `lem:nullity`
  (reflexivity only). Its final form is an open design question — see the field's docstring.
- Reflection (`nullity`) and backward composition (`backward_comp`) are **derived** here,
  matching `lem:nullity`'s derived status in the paper.
- Mixed-sign composition is not so much prohibited as **inexpressible at the primitive level**,
  since primitive durations are nonnegative.
- The ordered additive group structure provides the required abelian group with total order.

**Known gaps relative to the paper** (stated plainly rather than silently repaired):
- The paper requires `W` nonempty (`def:task-relation`); the structure carries no
  `Nonempty WorldState` field.
- The paper requires `D` nontrivial (`def:temporal-order`); `[Nontrivial D]` is not among the
  structure's binders, though `valid`/`SemanticConsequence` (Semantics/Validity.lean) already
  carry it — the gap is exactly and only at structure level.
- *Seriality* (`def:frame#Seriality`) is absent from the structure.
- *Limit* (`def:frame#Limit`) is absent from the structure. Its transcription against the
  extended relation is `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w`; the `⊇`
  half of the paper's equality is `nullity` plus cone membership and needs no field. The two
  reusable discharge routes are `limit_of_succOrder` and `limit_of_shift` below.
- The interpolation (`→`) direction of *Compositionality* (`def:frame#Compositionality`) is
  absent; only the `←` half is carried, as `forward_comp`.
- *Spherical* (`def:frame#Spherical`) is absent from the structure. The apparatus that makes it
  statable — `Fib`, `cone`, `Seg`, `DirectedFamily`, `IsFiber`, `IsSegment` — is defined below
  and awaits consumption by the structure change.

## Main Definitions

- `TaskFrame D`: Structure with world states, times of type `D`, task relation, and constraints
- `TaskFrame.nullity_identity`: Zero duration iff identity (`TaskRel w 0 u ↔ w = u`) —
  stronger than the paper's derived `lem:nullity`; open design question, see its docstring
- `TaskFrame.forward_comp`: the `←` (composition) half of the paper's biconditional
  *Compositionality* (`0 ≤ x`, `0 ≤ y`)
- `TaskFrame.converse`: The definitional converse convention (`TaskRel w d u ↔ TaskRel u (-d) w`)
- `TaskFrame.nullity`: Derived reflexivity theorem (`TaskRel w 0 w`, matching `lem:nullity`)
- `TaskFrame.Fib`, `TaskFrame.cone`, `TaskFrame.Seg`, `TaskFrame.DirectedFamily`,
  `TaskFrame.IsFiber`, `TaskFrame.IsSegment`: the `def:task-relation` / `def:directed`
  apparatus over a bare relation
- `TaskFrame.Spherical`, `TaskFrame.Serial`, `TaskFrame.Interpolates`: three of `def:frame`'s
  four axioms as predicates over a bare relation, hosted here so that they can become
  `TaskFrame` fields *definitionally* (a field's type may only mention earlier declarations).
  *Limit* is deliberately unnamed and used in its literal transcribed shape

## Main Results

- `TaskFrame.limit_of_succOrder`: *Limit* is automatic over a discrete duration
  type (`[SuccOrder D] [NoMaxOrder D]`)
- `TaskFrame.limit_of_shift`: *Limit* is automatic for deterministic-shift frames
  over any nontrivial duration type, dense included
- `TaskFrame.exists_uniform_radius_of_finite`: on a finite carrier, *Limit* upgrades to a
  uniform positive radius around each state
- Example task frames for testing and demonstrations (polymorphic over time type)

## Implementation Notes

- Type parameter `D` represents temporal duration with ordered additive group structure
- Task relation `TaskRel w x u` means: world state `u` is reachable from `w` by task
  of duration `x`
- Nullity: zero-duration task is identity, stated as an iff (open design question against the
  paper's reflexivity-only `lem:nullity`)
- Compositionality: currently only the `←` (composition) half on the positive cone; the paper's
  axiom is a biconditional whose interpolation direction is not yet carried
- Typeclass parameter convention: `(D : Type*)` explicit, ordered group instances implicit

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
declared **before** the `TaskFrame` structure, not after it. That ordering is load bearing: a
structure field's type may only mention declarations that precede it, so these are the
declarations the structure's axiom fields are stated from. Everything here is over a bare
relation `R : W → D → W → Prop`, so nothing in this block depends on the structure.
-/

namespace TaskFrame

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
### Fiber, cone, segment, and directed-family apparatus

The supporting apparatus of the paper's frame definition (`def:frame`), stated — like the Limit
discharge helpers above — against a bare relation `R : W → D → W → Prop` rather than a
`TaskFrame` field, so the definitions apply verbatim to a frame's `TaskRel` whether or not the
corresponding axioms are carried as structure data. This apparatus is what makes the paper's
*Spherical* axiom ("`⋂ 𝒮 ≠ ∅` for any directed family `𝒮` of nonempty fibers and segments")
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
A directed family of sets.

Recorded source (`def:directed`, verbatim): "A nonempty family of sets $\mathcal{S}$ is
\textit{directed} just in case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever
$S_1, S_2 \in \mathcal{S}$."

The nonemptiness of the family is part of the definition (a directed family is a *nonempty*
family); the nonemptiness of its *members* is a separate hypothesis wherever *Spherical*-shaped
statements need it.
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

**These predicates are the sole form in which the axioms are available.** When the `TaskFrame`
structure grows the corresponding fields, `TaskFrame.spherical` must be *definitionally*
`Spherical TaskRel`, `TaskFrame.serial` definitionally `Serial TaskRel`, and the interpolation
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
predicate declared in a module that *imports* this one could never become a `TaskFrame` field.
-/

/--
The *Spherical* axiom, over a bare task relation.

Recorded source (`def:frame#Spherical`, verbatim): "$\bigcap \mathcal{S} \neq \emptyset$ for any
directed family $\mathcal{S}$ of nonempty fibers and segments."

Three points of the transcription, each load bearing:

1. *Directed* is `def:directed`, transcribed as `DirectedFamily` — a definition in its own right,
   which already carries the nonemptiness of the family `S`.
2. "Nonempty fibers and segments" is a condition on each *member*: it is both a class condition
   (`IsFiber R s ∨ IsSegment R s`) and a nonemptiness condition (`s.Nonempty`). Fibers and
   segments are **two separate classes**; a one-sided fiber does not count as a segment.
3. "$\bigcap \mathcal{S} \neq \emptyset$" is `(⋂₀ S).Nonempty`.

This predicate is the sole form in which *Spherical* is available: it is what the Step Lemma's
proof consumes at the one application site the paper names, and what a future `TaskFrame`
spherical field must be definitionally equal to.
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
`TaskFrame.forward_comp`. This definition is the missing left-to-right direction: a task of
duration `x + y` can be *interpolated* at every intermediate point. The full biconditional axiom
is therefore `forward_comp ∧ Interpolates`.

As with `Serial`, the `0 ≤ x`, `0 ≤ y` provisos are `def:frame`'s blanket condition on its axiom
list, carried as explicit hypotheses.
-/
def Interpolates {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ w v x y, 0 ≤ x → 0 ≤ y → R w (x + y) v → ∃ u, R w x u ∧ R u y v

end TaskFrame

/--
Task frame for bimodal logic TM.

A task frame consists of:
- A type of world states
- A type `D` of temporal durations with ordered additive group structure
- A task relation connecting world states via timed tasks
- Nullity identity: zero-duration task iff identity (w = u)
- Forward compositionality: tasks compose on the positive cone
- Converse: the definitional converse convention, `TaskRel w d u ↔ TaskRel u (-d) w`

The task relation `TaskRel w x u` means: starting from world state `w`,
executing a task of duration `x` can result in world state `u`.

**Type Parameters**:
- `D`: Temporal duration type with totally ordered abelian group structure

**Paper Alignment**: The paper's `def:frame` carries exactly FOUR axioms — *Compositionality*
(a biconditional), *Seriality*, *Limit*, *Spherical* — and no Nullity axiom (`lem:nullity` is
derived, reflexivity only). This structure currently carries the converse convention
(`converse`), the `←` half of *Compositionality* (`forward_comp`), and an iff-form
zero-duration law (`nullity_identity`) that is strictly stronger than the paper's derived
`lem:nullity`. See the module docstring's "Known gaps" list for everything absent.

**Axiomatization Notes**:
The paper's own presentation (`def:task-relation`) takes the primitive task relation to live on
the positive cone `D⁺ = {x : 0 ≤ x}` and extends it to negative durations by the converse
convention. This structure is that presentation: the two-sided `TaskRel` is the *extended*
relation, `converse` is the convention that defines it from the primitive one, and
`forward_comp`'s `0 ≤ x`, `0 ≤ y` hypotheses confine composition to the primitive domain.

The paper's *Compositionality* (`def:frame#Compositionality`, verbatim: "$w \Rightarrow_{x + y}
v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$") is a
BICONDITIONAL: its right-to-left (composition) direction is `forward_comp`, and its
left-to-right (interpolation) direction is a known gap that lands with the structure change.

*Reflection* and backward composition are derived rather than postulated here (`nullity`,
`backward_comp`), matching `lem:nullity`'s derived status in the paper, and mixed-sign
composition is not prohibited but inexpressible at the primitive level, since primitive
durations are nonnegative.
-/
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- Type of world states -/
  WorldState : Type
  /-- Task relation: `TaskRel w x u` means u is reachable from w by task of duration x -/
  TaskRel : WorldState → D → WorldState → Prop
  /--
  Nullity identity constraint: zero-duration task relates exactly identical states.

  For any world states `w` and `u`, `TaskRel w 0 u` holds iff `w = u`.
  This is stronger than just reflexivity: it says zero duration means no change.

  **Strictly stronger than the paper — OPEN DESIGN QUESTION.** The paper has no Nullity axiom:
  `lem:nullity` (verbatim: "$w \Rightarrow_0 w$ for every world state $w \in W$ in every frame
  $\F = \tuple{W, \D, \Rightarrow}$.") is DERIVED, choice-free, from *Seriality* at `x = 0`
  plus *Limit*, and asserts reflexivity only. This field's iff form additionally asserts
  injectivity-at-zero. Three live options: (a) demote it to a derived lemma proved from
  Seriality + Limit once those land; (b) keep the iff as a deliberate, documented
  strengthening; (c) keep reflexivity derived and drop injectivity-at-zero. The choice is
  joint with the consequence-refactor work and is deliberately NOT settled by this module;
  the field stays as-is until that joint decision lands.
  -/
  nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u
  /--
  Compositionality on the positive cone: tasks compose for non-negative durations.

  If task of duration `x ≥ 0` takes `w` to `u`, and task of duration `y ≥ 0` takes `u` to `v`,
  then task of duration `x + y` takes `w` to `v`.

  **This is the `←` (composition) HALF of the paper's biconditional.**
  `def:frame#Compositionality` (verbatim: "$w \Rightarrow_{x + y} v$ if and only if
  $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$") is an iff whose
  right-to-left direction is this field and whose left-to-right (interpolation) direction is a
  known gap that lands with the structure change. The `0 ≤ x`, `0 ≤ y` hypotheses are how the
  paper's positive-cone domain restriction is expressed against the two-sided extended
  relation. Composition over negative durations is derived (`backward_comp`); mixed-sign
  composition is inexpressible at the primitive level rather than prohibited.
  -/
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → TaskRel w x u → TaskRel u y v → TaskRel w (x + y) v
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

namespace TaskFrame

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Derived nullity: zero-duration task is reflexive.

This follows from `nullity_identity`: `TaskRel w 0 w` iff `w = w`, and `w = w` is trivial.
-/
theorem nullity (F : TaskFrame D) (w : F.WorldState) : F.TaskRel w 0 w :=
  F.nullity_identity w w |>.mpr rfl

/--
Derived backward compositionality: tasks compose in the backward direction.

From `forward_comp` and `converse`, we can derive compositionality for non-positive durations.
If `TaskRel w x u` with `x ≤ 0` and `TaskRel u y v` with `y ≤ 0`,
then `TaskRel w (x + y) v`.
-/
theorem backward_comp (F : TaskFrame D) (w u v : F.WorldState) (x y : D)
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

/-!
### Limit discharge helpers

The paper's *Limit* axiom (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x =
\set{w}$") transcribes against the extended relation as

```
∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w
```

The two theorems below are the two reusable ways to discharge that obligation. They are stated
against a bare relation `R : W → D → W → Prop` rather than against a `TaskFrame` field, so they
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

Every live `TaskFrame` construction in this library whose relation is *not* a deterministic
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
directed family $\mathcal{S}$ of nonempty fibers and segments") on a subsingleton carrier: every
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

/--
Simple unit-based task frame for testing.

World states are Unit (trivial), task relation is always true.
This is the simplest possible task frame, polymorphic over temporal type `D`.
-/
def trivialFrame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    TaskFrame D where
  WorldState := Unit
  TaskRel := fun _ _ _ => True
  nullity_identity := fun _ _ => ⟨fun _ => Subsingleton.elim _ _, fun _ => trivial⟩
  forward_comp := fun _ _ _ _ _ _ _ _ _ => trivial
  converse := fun _ _ _ => ⟨fun _ => trivial, fun _ => trivial⟩

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
directed family $\mathcal{S}$ of nonempty fibers and segments") for `trivialFrame`: its carrier
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
-/
def staticFrame (W : Type) {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    TaskFrame D where
  WorldState := W
  TaskRel := fun w _ u => w = u
  nullity_identity := fun _ _ => Iff.rfl
  forward_comp := fun _ _ _ _ _ _ _ h1 h2 => h1.trans h2
  converse := fun _ _ _ => ⟨Eq.symm, Eq.symm⟩

/-! #### `staticFrame` discharges `def:frame`'s four axioms (equality class, Helper C) -/

/--
The static frame's relation is the equality class: `TaskRel w x u` holds exactly when `w = u`,
at every duration. This is the class-membership witness Helper C's lemmas consume.
-/
theorem staticFrame_rel_iff (W : Type) :
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
theorem staticFrame_serial (W : Type) : Serial (staticFrame W (D := D)).TaskRel :=
  serial_of_eq (staticFrame_rel_iff W)

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `staticFrame`: interpolate through `w` itself. -/
theorem staticFrame_interpolates (W : Type) : Interpolates (staticFrame W (D := D)).TaskRel :=
  interpolates_of_eq (staticFrame_rel_iff W)

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`staticFrame`, in the literal transcribed shape: only `w` is reachable from `w` at all. -/
theorem staticFrame_limit [Nontrivial D] (W : Type) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ (staticFrame W (D := D)).TaskRel w y u) → u = w :=
  limit_of_eq (staticFrame_rel_iff W)

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
directed family $\mathcal{S}$ of nonempty fibers and segments") for `staticFrame`: every nonempty
fiber and segment is the same singleton along a directed family. -/
theorem staticFrame_spherical (W : Type) : Spherical (staticFrame W (D := D)).TaskRel :=
  spherical_of_eq (staticFrame_rel_iff W)

/--
Natural number based task frame.

World states are natural numbers. Task relation: `TaskRel w d u` holds iff
either `d ≠ 0` (any transition for non-zero duration) or `w = u` (identity for zero duration).
This satisfies nullity_identity while remaining permissive.
Polymorphic over temporal type `D`.
-/
def natFrame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    TaskFrame D where
  WorldState := Nat
  TaskRel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h
      cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h
      right; exact h
  forward_comp := fun w u v x y hx hy h1 h2 => by
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
theorem natFrame_rel_iff :
    ∀ w d u, (natFrame (D := D)).TaskRel w d u ↔ (d ≠ 0 ∨ w = u) := fun _ _ _ => Iff.rfl

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `natFrame`, via the `w = u` disjunct. -/
theorem natFrame_serial : Serial (natFrame (D := D)).TaskRel :=
  serial_of_permissive natFrame_rel_iff

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `natFrame`. -/
theorem natFrame_interpolates : Interpolates (natFrame (D := D)).TaskRel :=
  interpolates_of_permissive natFrame_rel_iff

/--
*Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for `natFrame`,
in the literal transcribed shape — **over a discrete duration type only**.

`[SuccOrder D] [NoMaxOrder D]` is carried by this lemma rather than by `natFrame` itself, and the
restriction is not an artifact: over a dense `D` the permissive relation puts every state in
every cone of every other state, and *Limit* fails outright. When the frame structure grows the
*Limit* field, `natFrame`'s own binders must acquire these two instances; the only declaration
that propagation reaches is `WorldHistory.universalNatFrame`, which is itself polymorphic in `D`
and has no consumers of its own. Every other reference to `natFrame` in the library and test
suite elaborates at `Int`, which carries both instances.
-/
theorem natFrame_limit [SuccOrder D] [NoMaxOrder D] :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ (natFrame (D := D)).TaskRel w y u) → u = w :=
  limit_of_permissive natFrame_rel_iff

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
directed family $\mathcal{S}$ of nonempty fibers and segments") for `natFrame`: every nonempty
fiber and segment is the whole carrier or a singleton, and a directed family cannot contain two
distinct singletons. No restriction on `D` is needed. -/
theorem natFrame_spherical : Spherical (natFrame (D := D)).TaskRel :=
  spherical_of_permissive natFrame_rel_iff

end TaskFrame

/-!
# Finite Task Frames and Models

This section extends task frames with explicit finiteness constraints.
These structures bundle the finiteness property for convenience in stating
the Finite Model Property for TM logic.
-/

open TaskFrame

/--
A task frame with finitely many world states.

This structure extends the basic `TaskFrame` with an explicit proof
that the set of world states is finite. This is useful for stating
the Finite Model Property and related results.

**Type Parameters**:
- `D`: Temporal duration type with ordered additive group structure

**Usage**: Used to package finite model constructions like `SemanticCanonicalFrame`
into a standard format for the Finite Model Property.
-/
structure FiniteTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    extends TaskFrame D where
  /-- Proof that the set of world states is finite -/
  finite_world : Finite WorldState

namespace FiniteTaskFrame

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Coercion from a finite task frame to its underlying task frame.
This allows seamless use of existing definitions and theorems.
-/
instance : Coe (FiniteTaskFrame D) (TaskFrame D) where
  coe F := F.toTaskFrame

end FiniteTaskFrame

end FormalSystem.Semantics
