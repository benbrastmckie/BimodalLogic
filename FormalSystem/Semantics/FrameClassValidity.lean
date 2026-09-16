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

| Constructor | `Sat` | Anchor |
|-------------|-------|--------|
| `.Base` | `True` | — (unconstrained: `def:logical-consequence`'s own class) |
| `.Dense` | `TaskFrame.IsDense` | `def:frame-properties`, Dense clause |
| `.ZTime` | `TaskFrame.IsZTime` | `def:BX-z` (narrowing to ℤ-time) |
| `.RTime` | `TaskFrame.IsRTime` | `def:frame-properties` Complete + Dense; `cor:tm-completeness`'s TM_r clause |

Two of these are the *narrowed* member of a split pair, and deliberately so — interpreting
`.ZTime` by the bare `TaskFrame.IsDiscrete`, or `.RTime` by the bare `TaskFrame.IsComplete`,
would widen the frame class a soundness theorem at that tag ranges over. `Semantics/FrameProperty.lean`
records both splits and the paper sentences that force them.

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

* [FrameProperty.lean](FrameProperty.lean) — the frame predicates `Sat` interprets into
* [Validity.lean](Validity.lean) — `ValidOnFrames`, `ValidIn`, and the class-restricted predicates
* [Axioms.lean](../ProofSystem/Axioms.lean) — `FrameClass`, its `PartialOrder`, and
  `Axiom.minFrameClass`

## Tags

frame-class · validity · seam · base · dense · ztime · rtime
-/

namespace FormalSystem.ProofSystem

open FormalSystem.Semantics

/--
The semantic interpretation of a `FrameClass` tag: the frames that class consists of.

This is the definition that makes `Semantics.ValidIn` possible — with it, a class-restricted
validity predicate reads its frame constraint off the tag instead of inlining a binder list, which
is what keeps the constraint and the tag from drifting apart.

Per-constructor anchors:

* `.Base ↦ True`. The unconstrained class: `def:logical-consequence` quantifies over all models
  with no frame-side restriction, and `Axiom.minFrameClass` sends 37 of the 45 axiom constructors
  here.
* `.Dense ↦ TaskFrame.IsDense`. `def:frame-properties`' Dense clause. `Axiom.density` (`GGφ → Gφ`)
  and `Axiom.dense_indicator` (`¬(⊥ U ⊤)`) carry `.Dense`.
* `.ZTime ↦ TaskFrame.IsZTime`, **not** `TaskFrame.IsDiscrete`. `def:BX-z`'s closing
  sentence narrows the discrete class over which BX_z and TM_z are sound and complete to exactly
  the frames over ℤ-time — `UZ` and `Z1` fail over every discrete order that is not Archimedean —
  and it is that narrowed class `Axiom.prior_UZ`, `Axiom.prior_SZ` and `Axiom.z1` are sound over.
  Interpreting `.ZTime` by the bare Discrete clause would silently widen the class under
  `soundness_ztime`.
* `.RTime ↦ TaskFrame.IsRTime`, **not** `TaskFrame.IsComplete`. `FrameClass.RTime` sits
  strictly above `FrameClass.Dense`, so `density` and `dense_indicator` are admissible in a
  `.RTime` derivation, and both are false on `ℤ` — which satisfies the bare Complete clause.
  The dense-and-complete narrowing is what `cor:tm-completeness`'s TM_r clause names — its
  `ℝ`-time row — and what keeps soundness at this tag from being refutable.

## Reducibility is load-bearing

`Sat` carries `@[reducible]` deliberately. Lean registers a hypothesis in the local instance
cache only if `isClass?` can see a class head after whnf at *reducible* transparency, so a single
non-reducible `def` anywhere in the chain
`Sat .Dense F ⇝ TaskFrame.IsDense F ⇝ DenselyOrdered ↑F.Duration` blocks registration outright —
`Sat` sits *above* `IsDense` in that chain, so making `IsDense` an `abbrev` alone is not enough.
Both links must be reducible together. Removing this attribute silently regresses every
`sat_intro`/`Sat`-hypothesis site from "instance found" to "instance not found", with no error at
this declaration.
-/
@[reducible]
def FrameClass.Sat : FrameClass → TaskFrame → Prop
  | .Base, _ => True
  | .Dense, F => F.IsDense
  | .ZTime, F => F.IsZTime
  | .RTime, F => F.IsRTime

/--
`sat_intro h` normalises a `FrameClass.Sat fc F` hypothesis named `h` into whatever the tag
`fc` actually needs, uniformly across all four tags, so that no call site has to write a
positional `@`-application or a tag-specific destructuring pattern.

Per tag, with `Sat` reducible (see the docstring above):

* `.Base` — `Sat .Base F` is `True`; nothing to do, the `skip` branch fires.
* `.Dense` — `Sat .Dense F` is `TaskFrame.IsDense F` is `DenselyOrdered ↑F.Duration`, and the
  whole reducible chain exists so that `intro h` alone already registers `h` in the local
  instance cache. The `skip` branch fires and `exists_between` is available.
* `.ZTime` — `Sat .ZTime F` is `TaskFrame.IsZTime F`, a four-component
  existential; `obtain ⟨_, _, _, _⟩` lands `SuccOrder`, `PredOrder`, `IsSuccArchimedean` and
  `IsPredArchimedean` in the instance cache.
* `.RTime` — `Sat .RTime F` is `TaskFrame.IsRTime F`, i.e. `IsDense F ∧ IsComplete F`;
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

**Where to write it, and where not to.** At `.ZTime` and `.RTime` it does real work and is
required. At `.Base` and `.Dense` it reduces to `skip` — the frame condition is either `True` or
already an instance the moment it is `intro`ed — and `linter.unusedTactic` reports
`'sat_intro h' tactic does nothing` at `.Dense`. The convention adopted across this development is
therefore to **omit `sat_intro` at `.Base` and `.Dense` sites** rather than to silence the linter
locally; writing it there buys nothing and costs a warning. It is still safe to write at a
*generic* `fc`, where it degrades to `skip`.
-/
macro "sat_intro " h:ident : tactic =>
  `(tactic|
    first
      | obtain ⟨_, _, _, _⟩ := $h
      | obtain ⟨_, $h:ident⟩ := $h
      | skip)

/--
`Sat` is **antitone** in the `FrameClass` order: a larger class tag denotes a *more constrained*
collection of frames, so climbing the order shrinks the frame class.

This is the single place in the development where that order-direction reasoning is carried out.
Everything downstream — `Semantics.ValidIn.mono`, and the set-consequence monotonicity lemma in
`Metalogic/SetConsequence.lean` — is a corollary, which is what makes semantic monotonicity point
in the same direction as `DerivationTree.lift` without either lemma restating the argument.

The proof is a 16-case split. Four cases are reflexivity, one is the `Dense ≤ RTime` projection
`TaskFrame.isDense_of_isRTime`, four are `Sat .Base = True`, and the remaining seven have an
absurd order hypothesis discharged by `decide` against `FrameClass`'s `DecidableRel` instance.
-/
theorem FrameClass.Sat.anti {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂) {F : TaskFrame} :
    fc₂.Sat F → fc₁.Sat F := by
  cases fc₁ <;> cases fc₂ <;>
    first
      | exact fun _ => trivial
      | exact id
      | exact TaskFrame.isDense_of_isRTime
      | exact absurd h (by decide)

end FormalSystem.ProofSystem
