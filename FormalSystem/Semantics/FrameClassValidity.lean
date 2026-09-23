/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.FrameProperty
import FormalSystem.ProofSystem.Axioms

/-!
# The semantic interpretation of `FrameClass`

The proof side is parameterized by `ProofSystem.FrameClass` throughout: `Derivable fc`,
`DerivationTree fc`, `DerivationTree.lift` along `fc₁ ≤ fc₂`, and `Axiom.minFrameClass` as the
declared single source of truth for which axioms a derivation at `fc` may use. This module gives
that tag its semantic reading — a predicate on *frames* — so that the semantic side can be indexed
by the same tag instead of by a hand-maintained binder list.

## Main Definitions

- `FrameClass.Sat : FrameClass → TaskFrame → Prop` — the interpretation of record
- `FrameClass.Sat.anti` — `Sat` is antitone in the `FrameClass` order

Validity itself is not defined here; it is `Semantics.ValidIn` in
`FormalSystem/Semantics/Validity.lean`, which is downstream of this module. See "Module placement"
below.

## The interpretation of record

Every tag carries `TaskFrame.IsRegular` — the four `def:frame` constraints — because `FrameOver`
is the **general** frame structure and the constraints are frame conditions on it
(`Semantics/TaskFrame.lean`, "General frames and the regular class"). The paper's frames *are*
the regular ones, so the class each tag denotes is unchanged; what changed is that the regularity
is now written down here rather than being true by construction of the type.

* `.Base` — `Sat`: `TaskFrame.IsRegular`; Anchor: — (`def:logical-consequence`'s own class:
  unconstrained beyond `def:frame` itself)
* `.Dense` — `Sat`: `IsRegular ∧ TaskFrame.IsDense`; Anchor: `def:frame-properties`, Dense clause
* `.ZTime` — `Sat`: `IsRegular ∧ TaskFrame.IsZTime`; Anchor: `def:BX-z` (narrowing to ℤ-time)
* `.RTime` — `Sat`: `IsRegular ∧ TaskFrame.IsRTime`; Anchor: `def:frame-properties` Complete +
  Dense; `cor:tm-completeness`'s TM_r clause

Two of these are the *narrowed* member of a split pair, and deliberately so — interpreting
`.ZTime` by the bare `TaskFrame.IsDiscrete`, or `.RTime` by the bare `TaskFrame.IsComplete`,
would widen the frame class a soundness theorem at that tag ranges over.
`Semantics/FrameProperty.lean` records both splits and the paper sentences that force them.

`.RTime` is the paper's TM_r class, the `ℝ`-time row of `cor:tm-completeness`: dense and
Dedekind-complete, hence exactly the real flow `ℝ` up to order-and-group isomorphism.
`TaskFrame.IsRTime`'s definition site gives the argument in full.

## Module placement, and the one import seam it introduces

This is the **only** module under `FormalSystem/Semantics/` that imports anything from
`FormalSystem/ProofSystem/`, and the seam is confined here on purpose: `Sat` is the single point
at which a proof-side tag acquires a semantic meaning, so it is the single point at which the two
layers need to meet.

**Acyclicity, verified rather than assumed.** `FormalSystem/ProofSystem/Axioms.lean` imports only
`FormalSystem.Syntax.Formula`, and no file anywhere under `FormalSystem/ProofSystem/` imports
`FormalSystem.Semantics` or any of its submodules, so this edge closes no cycle.

`Sat` is about frames alone and needs no validity notion, so it lives here; the validity layer
built on it (`ValidOnFrames`, `ValidIn`, and the monotonicity and migration lemmas) is declared
in `Semantics/Validity.lean`, which imports this module. Two alternatives were considered and
rejected — relocating `inductive FrameClass` into a shared low-level module, and relocating the
four class-restricted predicates into this module. Both are recorded, with their costs, in
`docs/architecture/ADR-008-frameclass-validity-seam.md`.

## References

* `FormalSystem/Semantics/FrameProperty.lean` — the frame predicates `Sat` interprets into
* `FormalSystem/Semantics/Validity.lean` — `ValidOnFrames`, `ValidIn`, and the class-restricted
  predicates
* `FormalSystem/ProofSystem/Axioms.lean` — `FrameClass`, its `PartialOrder`, and
  `Axiom.minFrameClass`

## Tags

frame-class · validity · seam · base · dense · ztime · rtime

## Recorded namespace exception

This file sits under `Semantics/` but declares `namespace FormalSystem.ProofSystem`, so
`measure-refactor-partitions.py namespace-audit` classifies it `unrelated`. That is recorded, not
an oversight.

The namespace is the correct one: every declaration here extends `ProofSystem.FrameClass`, and
`FrameClass.Sat` is reached by dot notation on a `ProofSystem.FrameClass` value. Generalized field
notation resolves against the *type's* namespace and ignores `open`, so declaring these in
`FormalSystem.Semantics` would break `fc.Sat` at every call site. The module's placement under
`Semantics/` is equally deliberate — see "Module placement" below — which is exactly why path and
namespace cannot agree here.
-/

namespace FormalSystem.ProofSystem

open FormalSystem.Semantics

/--
The semantic interpretation of a `FrameClass` tag: the frames that class consists of.

This is the definition that makes `Semantics.ValidIn` possible — with it, a class-restricted
validity predicate reads its frame constraint off the tag instead of inlining a binder list, which
is what keeps the constraint and the tag from drifting apart.

Per-constructor anchors:

* `.Base ↦ TaskFrame.IsRegular`. The unconstrained class: `def:logical-consequence` quantifies
  over all models with no frame-side restriction *beyond `def:frame`'s own four constraints*, and
  `Axiom.minFrameClass` sends 23 of the 29 axiom constructors here. **This is the lever that keeps
  `Valid`'s meaning fixed** across the general/regular split: `FrameOver` no longer carries the
  constraints as fields, so `∀ F : TaskFrame` alone would quantify over frames that violate them
  and every soundness theorem would become false. Writing the constraints here, at the one point
  where a tag acquires its semantic meaning, leaves `Valid`, `ValidIn` and `ValidOnFrames`
  denoting exactly the collections they always denoted.
* `.Dense ↦ IsRegular ∧ TaskFrame.IsDense`. `def:frame-properties`' Dense clause, conjoined with
  regularity. `Axiom.density` (`GGφ → Gφ`) and `Axiom.dense_indicator` (`¬(⊥ U ⊤)`) carry `.Dense`.
  The tag keeps the paper's name, not `QTime`; see `FrameClass` for why.
* `.ZTime ↦ IsRegular ∧ TaskFrame.IsZTime`, **not** `TaskFrame.IsDiscrete`. `def:BX-z`'s closing
  sentence narrows the discrete class over which BX_z and TM_z are sound and complete to exactly
  the frames over ℤ-time — `UZ` and `Z1` fail over every discrete order that is not Archimedean —
  and it is that narrowed class `Axiom.prior_UZ`, `DerivedAxioms.priorSZ` and `Axiom.z1` are sound
  over. Interpreting `.ZTime` by the bare Discrete clause would silently widen the class under
  `soundness_ztime`.
* `.RTime ↦ IsRegular ∧ TaskFrame.IsRTime`, **not** `TaskFrame.IsComplete`. `FrameClass.RTime` sits
  strictly above `FrameClass.Dense`, so `density` and `dense_indicator` are admissible in a
  `.RTime` derivation, and both are false on `ℤ` — which satisfies the bare Complete clause.
  The dense-and-complete narrowing is what `cor:tm-completeness`'s TM_r clause names — its
  `ℝ`-time row — and what keeps soundness at this tag from being refutable.

## Reducibility is load-bearing

`Sat` carries `@[reducible]` deliberately. Lean registers a hypothesis in the local instance
cache only if `isClass?` can see a class head after whnf at *reducible* transparency, so a single
non-reducible `def` anywhere in the chain
`Sat .Base F ⇝ TaskFrame.IsRegular F ⇝ FrameOver.IsRegular F.toFibre` blocks registration
outright — `Sat` sits *above* `IsRegular` in that chain, and `TaskFrame.IsRegular` is an `abbrev`
for the same reason. Both links must be reducible together. Removing this attribute silently
regresses every `sat_intro`/`Sat`-hypothesis site from "instance found" to "instance not found",
with no error at this declaration.

At `.Base` this is the whole mechanism: a bare `intro h` on a `Sat .Base F` hypothesis registers
`F.IsRegular` in the local instance cache, so `F.comp`, `F.serial`, `F.limit` and `F.saturation`
elaborate at the site with nothing written. At the three constrained tags the value is a
conjunction rather than a class, so `sat_intro` is **required** there and is no longer optional at
`.Dense`; it strips the regularity conjunct (which the `obtain` registers) and leaves the caller's
`h` bound to the tag's own frame condition, exactly the shape a bare `intro h` used to produce.
-/
@[reducible]
def FrameClass.Sat : FrameClass → TaskFrame → Prop
  | .Base, F => F.IsRegular
  | .Dense, F => F.IsRegular ∧ F.IsDense
  | .ZTime, F => F.IsRegular ∧ F.IsZTime
  | .RTime, F => F.IsRegular ∧ F.IsRTime

/--
`sat_intro h` normalises a `FrameClass.Sat fc F` hypothesis named `h` into whatever the tag
`fc` actually needs, uniformly across all four tags, so that no call site has to write a
positional `@`-application or a tag-specific destructuring pattern.

The macro is two nested `first` blocks. The outer one strips the regularity conjunct, guarded by
the type ascription `($h : _ ∧ _)`: at `.Base` the value is the *class* `TaskFrame.IsRegular`,
not a conjunction, the ascription fails, and the whole macro degrades to `skip`. The guard is
load-bearing — without it, `obtain` would happily destructure `IsRegular`'s own four fields and
*remove* the frame's regularity instance from the context. The inner block is then the pre-split
macro verbatim, acting on exactly the hypothesis shape a bare `intro h` used to produce.

Per tag, with `Sat` reducible (see the docstring above):

* `.Base` — `Sat .Base F` is `TaskFrame.IsRegular F`, a class; `intro h` has already registered
  it, the ascription guard fails, and the `skip` branch fires. Nothing to do.
* `.Dense` — `Sat .Dense F` is `IsRegular F ∧ TaskFrame.IsDense F`. The outer `obtain` registers
  regularity and rebinds `h` to `DenselyOrdered ↑F.Duration`, which the reducible chain then
  registers as well, so `exists_between` is available.
* `.ZTime` — after the strip, `h` is `TaskFrame.IsZTime F`, a four-component existential;
  `obtain ⟨_, _, _, _⟩` lands `SuccOrder`, `PredOrder`, `IsSuccArchimedean` and
  `IsPredArchimedean` in the instance cache.
* `.RTime` — after the strip, `h` is `TaskFrame.IsRTime F`, i.e. `IsDense F ∧ IsComplete F`;
  `obtain ⟨_, h⟩` registers the density instance and rebinds the *completeness* conjunct under
  the caller's own name `h`, so it stays reachable under the spelling the caller wrote.

**Two constraints on this macro, both load-bearing.**

1. It must destructure with `obtain`, and must **never** re-introduce an instance with
   `have`/`haveI`/`letI` in the `.ZTime` case. `IsSuccArchimedean α [Preorder α] [SuccOrder α]`
   is *indexed by* the `SuccOrder` instance, so a fresh opaque local introduced by `haveI` shadows
   the obtained `SuccOrder` witness and the `IsSuccArchimedean` hypothesis then mentions a
   different instance than the goal does — unification fails, with an error that points nowhere
   near the cause. This is the mechanism behind the "use `@`, never `haveI`" warnings recorded in
   `Semantics/Validity.lean`.
2. There is deliberately no `clear $h` alternative. `clear` succeeds on *any* unused hypothesis,
   so a `clear` branch would fire at `.ZTime`/`.RTime` whenever the preceding branches were
   reordered or failed, silently discarding the frame condition instead of using it.

The caller's `h` is passed back explicitly (rather than the macro inventing a name) because macro
hygiene would otherwise make a macro-introduced binder inaccessible at the call site.

**Where to write it, and where not to.** At `.Dense`, `.ZTime` and `.RTime` it does real work and
is **required**: the `Sat` value is a conjunction, so a bare `intro h` leaves `h` bound to the
pair rather than to the frame condition. (This is a change from the pre-split convention, which
recorded `.Dense` as a site where the macro was a no-op and should be omitted. It is a no-op no
longer.) At `.Base` it still reduces to `skip` — `intro h` has already registered the frame's
regularity — and `linter.unusedTactic` reports `'sat_intro h' tactic does nothing` there, so
**omit it at `.Base` sites** rather than silencing the linter locally. It remains safe to write at
a *generic* `fc`, where it degrades to `skip`.
-/
macro "sat_intro " h:ident : tactic =>
  `(tactic|
    first
      | (obtain ⟨_, $h:ident⟩ := ($h : _ ∧ _);
         first
           | obtain ⟨_, _, _, _⟩ := $h
           | obtain ⟨_, $h:ident⟩ := $h
           | skip)
      | skip)

/--
**Every frame class consists of regular frames.** Each tag's `Sat` value carries
`TaskFrame.IsRegular`, at `.Base` as the whole value and at the three constrained tags as the
first conjunct; this projects it out uniformly, so a consumer holding an anonymous `fc.Sat F`
hypothesis at an unknown tag can register the frame's regularity with `haveI`.
-/
theorem FrameClass.Sat.isRegular {fc : FrameClass} {F : TaskFrame} (h : fc.Sat F) :
    F.IsRegular := by
  cases fc <;> first | exact h | exact h.1

/--
`Sat` is **antitone** in the `FrameClass` order: a larger class tag denotes a *more constrained*
collection of frames, so climbing the order shrinks the frame class.

This is the single place in the development where that order-direction reasoning is carried out.
Everything downstream — `Semantics.ValidIn.mono`, and the set-consequence monotonicity lemma in
`Metalogic/SetConsequence.lean` — is a corollary, which is what makes semantic monotonicity point
in the same direction as `DerivationTree.lift` without either lemma restating the argument.

The proof is a 16-case split. Four cases are reflexivity, one is the `Dense ≤ RTime` projection
`TaskFrame.isDense_of_isRTime` on the tag's own conjunct, four project the shared regularity
conjunct out at `.Base`, and the remaining seven have an absurd order hypothesis discharged by
`decide` against `FrameClass`'s `DecidableRel` instance.
-/
theorem FrameClass.Sat.anti {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂) {F : TaskFrame} :
    fc₂.Sat F → fc₁.Sat F := by
  cases fc₁ <;> cases fc₂ <;>
    first
      | exact id
      | exact And.left
      | exact fun hs => ⟨hs.1, TaskFrame.isDense_of_isRTime hs.2⟩
      | exact absurd h (by decide)

end FormalSystem.ProofSystem
