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
| `.Discrete` | `TaskFrame.IsSuccArchDiscrete` | `def:TMplus-f` (Hölder narrowing to ℤ-time) |
| `.Dedekind` | `TaskFrame.IsDedekind` | `def:frame-properties` Complete + Dense; `cor:tm-completeness`'s TM⁺_c clause |

Two of these are the *narrowed* member of a split pair, and deliberately so — interpreting
`.Discrete` by the bare `TaskFrame.IsDiscrete`, or `.Dedekind` by the bare `TaskFrame.IsComplete`,
would widen the frame class a soundness theorem at that tag ranges over. `Semantics/FrameProperty.lean`
records both splits and the paper sentences that force them.

**Naming deviation of record.** `def:frame-properties` calls the dense-and-complete class
**Complete**; this tree calls it `Dedekind`, in `FrameClass.Dedekind`, `TaskFrame.IsDedekind` and
`ValidDedekindDense` alike. That divergence from the definition of record is deliberate — "complete"
is already load-bearing here for *proof-theoretic* completeness — and is recorded in full at
`TaskFrame.IsDedekind`'s definition site.

## Module placement, and the one import seam it introduces

This is the **only** module under `FormalSystem/Semantics/` that imports anything from
`FormalSystem/ProofSystem/`, and the seam is confined here on purpose: `Sat` is the single point
at which a proof-side tag acquires a semantic meaning, so it is the single point at which the two
layers need to meet.

**Acyclicity, verified rather than assumed.** `FormalSystem/ProofSystem/Axioms.lean` imports only
`FormalSystem.Syntax.Formula`, and no file anywhere under `FormalSystem/ProofSystem/` imports
`FormalSystem.Semantics` or any of its submodules. So the `Semantics → ProofSystem.Axioms` edge
added here closes no cycle. Relocating `inductive FrameClass` into a shared low-level module would
remove the seam entirely, but would move a namespace carrying ~45 axiom constructors along with
every `DerivationTree`/`Derivable` signature that names them; that is deliberately out of scope.

**Why `Sat` lives here and `ValidIn` does not.** `ValidIn` is defined through `TaskFrame.ValidOn`
(`def:frame-validity`), which is declared in `Semantics/Validity.lean`; and `Validity.lean`'s own
class-restricted predicates (`ValidDense`, `ValidDiscrete`, `ValidDedekind`, `ValidDedekindDense`)
are in turn defined as instances of `ValidIn`/`ValidOnFrames`. Those two facts cannot both be
satisfied with `ValidIn` downstream of `Validity.lean`. Of the two acceptable resolutions, this
tree takes the second: `Sat` — which is about frames alone and needs no validity notion — stays in
this module, and the validity layer built on it (`ValidOnFrames`, `ValidIn`, and the monotonicity
and migration lemmas) is declared in `Semantics/Validity.lean`, which imports this module. The
alternative, relocating the four class-restricted predicates into this module and re-exporting,
would have forced a new import line into every one of the ~27 files that consume them today for no
gain in layering.

## References

* [FrameProperty.lean](FrameProperty.lean) — the frame predicates `Sat` interprets into
* [Validity.lean](Validity.lean) — `ValidOnFrames`, `ValidIn`, and the class-restricted predicates
* [Axioms.lean](../ProofSystem/Axioms.lean) — `FrameClass`, its `PartialOrder`, and
  `Axiom.minFrameClass`
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
* `.Discrete ↦ TaskFrame.IsSuccArchDiscrete`, **not** `TaskFrame.IsDiscrete`. `def:TMplus-f`'s
  closing sentence states that "the successor-Archimedean discrete class to which BX_f and TM⁺_f
  are sound and complete is exactly ℤ-time", and it is that narrowed class `Axiom.prior_UZ`,
  `Axiom.prior_SZ` and `Axiom.z1` are sound over. Interpreting `.Discrete` by the bare Discrete
  clause would silently widen the class under `soundness_discrete`.
* `.Dedekind ↦ TaskFrame.IsDedekind`, **not** `TaskFrame.IsComplete`. `FrameClass.Dedekind` sits
  strictly above `FrameClass.Dense`, so `density` and `dense_indicator` are admissible in a
  `.Dedekind` derivation, and both are false on `ℤ` — which satisfies the bare Complete clause.
  The dense-and-complete narrowing is what `cor:tm-completeness`'s TM⁺_c clause names and what
  keeps soundness at this tag from being refutable. See the naming deviation recorded at
  `TaskFrame.IsDedekind`: the paper calls this property Complete, this tree calls it Dedekind.

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
  | .Discrete, F => F.IsSuccArchDiscrete
  | .Dedekind, F => F.IsDedekind

/--
`Sat` is **antitone** in the `FrameClass` order: a larger class tag denotes a *more constrained*
collection of frames, so climbing the order shrinks the frame class.

This is the single place in the development where that order-direction reasoning is carried out.
Everything downstream — `Semantics.ValidIn.mono`, and the set-consequence monotonicity lemma in
`Metalogic/SetConsequence.lean` — is a corollary, which is what makes semantic monotonicity point
in the same direction as `DerivationTree.lift` without either lemma restating the argument.

The proof is a 16-case split. Four cases are reflexivity, one is the `Dense ≤ Dedekind` projection
`TaskFrame.isDense_of_isDedekind`, four are `Sat .Base = True`, and the remaining seven have an
absurd order hypothesis discharged by `decide` against `FrameClass`'s `DecidableRel` instance.
-/
theorem FrameClass.Sat.anti {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂) {F : TaskFrame} :
    fc₂.Sat F → fc₁.Sat F := by
  cases fc₁ <;> cases fc₂ <;>
    first
      | exact fun _ => trivial
      | exact id
      | exact TaskFrame.isDense_of_isDedekind
      | exact absurd h (by decide)

end FormalSystem.ProofSystem
