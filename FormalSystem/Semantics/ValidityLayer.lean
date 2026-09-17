/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.PartialHistory
import FormalSystem.Semantics.FrameClassValidity

/-!
# The validity layer, written once over an abstract truth-at-a-point relation

The object-language tower carries four separate inductives — `Formula`, `MinusFormula`,
`PlusFormula`, `StarFormula` — and that separation is deliberate and permanent
(`FormalSystem/StarLanguage/README.md`, "Why the operators are not added to PlusFormula").
Separate *types*, however, do not require separate *validity layers*: `def:frame-validity` and
the binder-shape adapters over it say nothing about a formula beyond "it is true at the point
`(M, τ, x)`".

This module isolates exactly that much structure as the class `PointTruth`, and writes the
validity layer once against it. Each language keeps every name, statement and attribute it has
today; the per-language theorems become one-line delegations to the `Generic*` declarations
below.

## Main Definitions

- `PointTruth` — the class: one field, `sat`, the truth relation at a point
- `TaskFrame.GenericValidOn`, `GenericValidOnFrames`, `GenericValidIn`, `GenericValid` —
  `def:frame-validity` and the frame-predicate / frame-class / unconstrained validity notions,
  stated once

## Main Results

- `GenericValidOnFrames.mono`, `GenericValidIn.mono` — the two monotonicity lemmas
- `GenericValid.of_forall` / `.apply` / `.of_not` — the `.Base` binder-shape adapters, which
  discharge the vacuous `Sat .Base` argument

## Design Invariants — the extension contract

**Written from the four instantiations actually performed** (`Semantics/Validity.lean`,
`MinusValidity.lean`, `PlusValidity.lean`, `StarValidity.lean`), not aspirationally. Each claim
below cites the instance it is drawn from. See the corresponding section of
`Semantics/TruthClauses.lean` for the clause layer's half of the contract.

### What a fifth language must supply

Exactly one instance, with exactly one field:

```
instance : PointTruth MyFormula where
  sat M τ t φ := MyTruthAt M τ t φ
```

That is the whole obligation for the `(M, τ, t)` point shape; it is verbatim what L, L⁻ and L⁺
supply. A language whose truth recursion carries **extra per-point parameters** supplies the
universally closed form instead, as L⋆ does for its stored-time vector:

```
instance : PointTruth StarFormula where
  sat {F} M τ t φ := ∀ v : ℕ → F.Duration, StarTruthAt M τ t v φ
```

### The two obligations on an extra parameter

Both are needed only by the L⋆ instance; L, L⁻ and L⁺ discharge them vacuously, having no extra
parameter. They are stated as obligations rather than as observations because a fifth language
with an extra parameter must check them.

**O1 — innermost binder.** Every extra per-point parameter must be the *innermost* binder of the
language's own `ValidOn` and of every one of its adapters. `TaskFrame.StarValidOn` reads
`∀ M τ x v, …`, and as a `Pi` telescope that is literally `∀ M τ x, (∀ v, …)`; the `∀ v` of the
instance is therefore the same term, not a re-derivation. This is what makes the fold
*statement*-preserving rather than merely provably equivalent, and it is pinned by
`example : TaskFrame.StarValidOn F φ = TaskFrame.GenericValidOn F φ := rfl` in
`Tests/BimodalTest/Semantics/ValidityLayerTest.lean`. If a language puts the parameter anywhere
but innermost, the `rfl` fails and this layer does not apply to it.

**O2 — inert threading.** The extra parameter must be threaded unchanged through every *shared*
operator clause. L⋆ satisfies this for `imp`/`box`/`untl`/`snce`/`stab`; its two register
operators `timeStore`/`timeRecall` do **not** thread `v` unchanged, which is exactly why nothing
about them is instantiated (see `TruthClauses.lean`'s contract). O2 constrains the shared core
only — a language is free to have operators that manipulate the parameter, provided they stay
outside the shared clause classes.

### What the instance buys — the inherited names

All nine, for that one field:

- `TaskFrame.GenericValidOn`, `GenericValidOnFrames`, `GenericValidIn`, `GenericValid`
- `GenericValidOnFrames.mono`, `GenericValidIn.mono`
- `GenericValid.of_forall`, `GenericValid.apply`, `GenericValid.of_not`

Every history quantifier ranges over the bundled `WorldHistory F`, so the frame-predicate and
frame-class notions need no binder-shape adapters at all: a goal is opened by `intro F hF M τ x`
and a hypothesis is applied as `h F hF M τ x`. Only the `.Base` forms keep adapters, because they
discharge the vacuous `Sat .Base` argument. A fifth language pays one instance and inherits the
lot.

### What is NOT inherited — the honest boundary

One criterion decides it: this class abstracts the truth *relation*, not the inductive *type*, so
it exposes **no recursor**. Anything provable only by `induction φ` stays per-language. In the
landed tree that is:

- time shift — `timeShift_preserves_truth`, `plusTruthAt_timeShift`, `starTruthAt_timeShift`
  (whose *statement*, uniquely, differs between languages: it shifts the vector alongside the
  history)
- truth congruence — `truth_congr_ext`, `star_truth_congr_ext`
- state locality — `stab_state_only`, the `PlusStateLocal`/`StarStateLocal` families
- the embedding bridges — `plusTruthAt_ofFormula`, `starTruthAt_ofPlus`, `starValidOn_ofPlus`,
  `starValidOnFrames_ofPlus`

Two further families sit outside for a second reason, and are likewise not defects:
`MinusFrameTruth` (a frame notion that is not a `TaskFrame`, and this class is `TaskFrame`-pointed)
and `Metalogic/Independence/CoarsenedModels.lean`'s `CTruth.*`.

### Naming and reducibility invariants

**No bare namesake.** The generic notions are top-level in `FormalSystem.Semantics` under a
`Generic` prefix, mirroring the tree's own `Minus`/`Plus`/`Star` convention. A bare `Valid`,
`ValidIn` or `ValidOnFrames` in a namespace nested under `FormalSystem.Semantics` would reproduce
the outer-shadows-inner ambiguity that `check-module-invariants.sh` C23 exists to prevent, and
must not be introduced — including by writing the dot-qualified form to evade the walker.

**No `abbrev` promotion.** Each language's four validity `def`s keep their bodies and their
reducibility. Only the *theorem* bodies delegate. Promoting `Valid` to an `abbrev`, or replacing
its body with a call to `GenericValid`, would change `unfold`/`simp` behaviour at every one of its
~787 occurrences; the delegation is deliberately confined to proof-irrelevant declarations, which
is why no downstream file needed editing.

**If you find yourself wanting a bridge lemma** between a per-language notion and its generic
counterpart, a statement has moved: the two are definitionally equal, and the fix is to restore
that, not to add an elimination API.

## References

* `FormalSystem/Semantics/Validity.lean` — the L instantiation, and the source of every
  statement below
* `FormalSystem/Semantics/TruthClauses.lean` — the clause layer over the same idea
* `docs/user-guide/architecture.md` — validity specification

## Tags

validity · abstraction · typeclass · def:frame-validity · extension-contract
-/

namespace FormalSystem.Semantics

/--
Truth of an object-language formula at a **point** `(M, τ, x)` of a task frame: a model over the
frame, a possible world, and a time.

This is the whole of what the validity layer needs from a language. It is a relation, not a
recursion: the class carries no constructors and no recursor, so it abstracts `def:frame-validity`
and its adapters without touching the separation between the four formula inductives.

**The `∀`-closure convention.** A language whose truth recursion evaluates at a point with extra
parameters — L⋆'s stored-time vector, say — supplies the universally closed relation
`fun M τ t φ => ∀ e, MyTruthAt M τ t e φ`. That is not a weakening: the extra parameter is the
*innermost* binder of every one of that language's own validity definitions, and a `Pi` telescope
`∀ M τ x v, P` is literally `∀ M τ x, (∀ v, P)`, so the closure changes no statement.
-/
class PointTruth (L : Type) where
  /-- `sat M τ x φ` — the formula `φ` is true at the point `(M, τ, x)`. -/
  sat : ∀ {F : TaskFrame}, TaskModel F → WorldHistory F → F.Duration → L → Prop

variable {L : Type} [PointTruth L]

/-! ### The validity notions -/

/-- `def:frame-validity`, stated once: `φ` is valid over the frame `F` iff it is true at every
model over `F`, every possible world `τ ∈ H_F`, and every time `x`.

The history quantifier is `WorldHistory F`, exactly as every per-language `ValidOn` in the tree
writes it. -/
def TaskFrame.GenericValidOn (F : TaskFrame) (φ : L) : Prop :=
  ∀ (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration), PointTruth.sat M τ x φ

/-- `φ` is valid on every frame satisfying the predicate `P`. The frame-predicate-indexed
primitive that every class-restricted validity notion is an instance of. -/
def GenericValidOnFrames (P : TaskFrame → Prop) (φ : L) : Prop :=
  ∀ F : TaskFrame, P F → TaskFrame.GenericValidOn F φ

/-- `φ` is valid on every frame in the class the tag `fc` denotes: `GenericValidOnFrames` at
`fc.Sat`, where each tag's interpretation is recorded once. -/
def GenericValidIn (fc : ProofSystem.FrameClass) (φ : L) : Prop :=
  GenericValidOnFrames fc.Sat φ

/-- `φ` is valid: `GenericValidIn` at the unconstrained class. `Sat FrameClass.Base` is `True`,
so this quantifies over every task frame with no frame condition attached. -/
def GenericValid (φ : L) : Prop :=
  GenericValidIn ProofSystem.FrameClass.Base φ

/-! ### Monotonicity -/

/-- **The one monotonicity lemma.** `GenericValidOnFrames` is antitone in its frame predicate:
shrinking the class of frames quantified over can only preserve validity. -/
theorem GenericValidOnFrames.mono {P Q : TaskFrame → Prop} {φ : L} (h : ∀ F, Q F → P F)
    (hP : GenericValidOnFrames P φ) : GenericValidOnFrames Q φ :=
  fun F hF => hP F (h F hF)

/-- Validity is monotone in the `FrameClass` order, because `FrameClass.Sat` is antitone: a
larger tag denotes a more constrained collection of frames. -/
theorem GenericValidIn.mono {fc₁ fc₂ : ProofSystem.FrameClass} {φ : L} (h : fc₁ ≤ fc₂)
    (hv : GenericValidIn fc₁ φ) : GenericValidIn fc₂ φ :=
  GenericValidOnFrames.mono (fun _ => ProofSystem.FrameClass.Sat.anti h) hv

/-! ### The `.Base` binder-shape adapters

`GenericValid` is `GenericValidIn` at the unconstrained class, whose frame condition
`Sat .Base` is `True`. These three discharge that vacuous argument so that no call site has to
bind it. The frame-predicate and frame-class notions need no adapters: their quantifiers already
range over `WorldHistory F`, so `intro` and application open them directly. -/

/-- Introduce `GenericValid` from its explicit binder shape; the `Sat .Base` argument (`True`) is
discharged here rather than at each call site. -/
theorem GenericValid.of_forall {φ : L}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration),
      PointTruth.sat M τ x φ) :
    GenericValid φ :=
  fun F _ M τ x => h F M τ x

/-- Eliminate `GenericValid` into its explicit binder shape; the `Sat .Base` argument is
discharged here, not at the call site. -/
theorem GenericValid.apply {φ : L} (h : GenericValid φ) (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (x : F.Duration) : PointTruth.sat M τ x φ :=
  h F trivial M τ x

/-- The contrapositive of `GenericValid.of_forall`, in the shape a countermodel extraction wants:
from a failure of validity it hands back a failure of the explicit ∀-statement, which `push Not`
takes apart. Proved by the plain term `fun hc => h (… hc)` — no classical tactic — so that a
delegating wrapper's axiom set is exactly its original's. -/
theorem GenericValid.of_not {φ : L} (h : ¬ GenericValid φ) :
    ¬ ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration),
        PointTruth.sat M τ x φ :=
  fun hc => h (GenericValid.of_forall hc)

end FormalSystem.Semantics
