/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.MinusLanguage.MinusTruth
import FormalSystem.Semantics.ValidityLayer
import FormalSystem.Semantics.Validity

/-!
# L⁻ validity — the base-language mirrors of `Semantics/Validity.lean`

Validity and semantic consequence for the tense-primitive base language L⁻, stated against the
native `MinusTruthAt` of `Semantics/MinusLanguage/MinusTruth.lean`.

Each predicate here is a **binder-for-binder mirror** of its counterpart in
`Semantics/Validity.lean`: `MinusValid` of `Valid`, `MinusValidDense` of `ValidDense`,
`MinusValidZTime` of `ValidZTime`, `MinusValidRTime` of `ValidRTime`, and
`MinusSemanticConsequence` of `SemanticConsequence`. Nothing changes but `Formula ↦ MinusFormula` and
`TruthAt ↦ MinusTruthAt`; in particular the histories quantified over are the **total** ones
(`τ.IsTotal`, the predicate form of `H_F`), matching `def:logical-consequence`, and `Type` rather
than `Type*` is used throughout for the same universe reason recorded on `Valid`.

## The RTime asymmetry — read this before adding a `MinusValidComplete`

There is deliberately **no** density-free `MinusValidComplete`, and the soundness theorem for
`FrameClass.RTime` targets `MinusValidRTime`. A density-free target would be
**refutable**, and on the L⁻ side one axiom suffices to refute it:

- `(MinusLanguage.Axiom.dn φ).minFrameClass = FrameClass.Dense` and
  `FrameClass.Dense ≤ FrameClass.RTime` (pinned by an `example` in
  `FormalSystem/MinusLanguage/Axioms.lean`), so `dn` — the density axiom `GGφ → Gφ` — is
  admissible in any `FrameClass.RTime` L⁻ derivation.
- `dn` is false on `ℤ`: take `φ` true exactly at the times `≥ t + 2`. Then `GGφ` holds at `t`
  while `Gφ` fails at `t`, because `t + 1` is strictly future and `φ` is false there.
- `ℤ` satisfies every binder of a density-free `MinusValidComplete` — it is Dedekind-complete
  (Mathlib's `ConditionallyCompleteLinearOrder ℤ`) — so the refutation lands.

Adding `[DenselyOrdered D]` deletes exactly the `ℤ` branch of the Hölder dichotomy and nothing
else (`Semantics/DurationClassification.lean`). This is the L⁻-native form of the argument
`Semantics/Validity.lean` records for `ValidComplete` on the L side; note that L's version
additionally leans on `Axiom.dense_indicator` (`¬(⊥ U ⊤)`), which has no L⁻ counterpart at all
since L⁻ has no `untl`. Do not "simplify" the target.

## Main Definitions

- `MinusValid`, `MinusSemanticConsequence` — validity and consequence over the `FrameClass.Base` binder
  set
- `MinusValidDense`, `MinusValidZTime`, `MinusValidRTime` — the three extension binder sets

## Main Results

- `MinusValidity.minusValid_implies_minusValidDense`, `…_minusValidZTime`, `…_minusValidRTime` — the
  inclusion lemmas mirroring `Validity.valid_implies_valid_dense` and its siblings
- `MinusValidity.minusValid_iff_empty_consequence` — validity is consequence from the empty context

## References

* JPL paper `\S sub:Logic` — `def:BL-semantics`, `def:logical-consequence`
* `FormalSystem/Semantics/Validity.lean` — the L predicates these mirror
* `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` — the soundness theorems targeting these

## Tags

validity · base-language · frame-class
-/

namespace FormalSystem.Semantics

open FormalSystem.MinusLanguage

/--
Semantic consequence in the base language: `φ` is true at every model, **total** history and time
at which every formula of `Γ` is true.

Binder-for-binder mirror of `Semantics.SemanticConsequence`.
-/
def MinusSemanticConsequence (Γ : MinusLanguage.Context) (φ : MinusFormula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F)
    (τ : PartialHistory F) (_ : τ.IsTotal) (t : F.Duration),
    (∀ ψ ∈ Γ, MinusTruthAt M τ t ψ) →
    MinusTruthAt M τ t φ

/-! ## `FrameClass`-indexed validity for the base language

The same two-layer shape `Semantics/Validity.lean` gives the full language, mirrored here against
`MinusTruthAt`. L needs its own predicates because it has its own truth recursion — `MinusTruthAt` is
defined natively on `MinusFormula`'s six constructors per `def:BL-semantics`, not via `untl`/`snce` —
but it shares one and the same `FrameClass.Sat`, so the frame classes the two languages are
indexed by are literally the same classes and not two parallel copies. -/

/-- L⁻'s instance of the abstract point-truth class of `Semantics/ValidityLayer.lean`: truth at
the point `(M, τ, t)` is `MinusTruthAt`. Every validity-layer theorem below delegates to the
generic one through this single field. -/
instance : PointTruth MinusFormula where
  sat M τ t φ := MinusTruthAt M τ t φ

/--
`def:frame-validity` for the base language: `φ` is **valid over the frame `F`** iff it is true at
every model over `F`, every possible world `τ ∈ H_F`, and every time `x ∈ D`.

The L⁻ mirror of `TaskFrame.ValidOn`, and in fact the more literal reading of the anchor, whose
text is stated for "a well-formed sentence `φ` of `L⁻`". `TaskFrame.ValidOn` is the same clause
applied to the full language's `Formula`. Both render the bundled `H_F` as `TaskFrame.HF`.
-/
def TaskFrame.MinusValidOn (F : TaskFrame) (φ : MinusFormula) : Prop :=
  ∀ (M : TaskModel F) (τ : TaskFrame.HF F) (x : F.Duration), MinusTruthAt M τ.val x φ

/-- `φ` is valid on every frame satisfying `P`. The L⁻ mirror of `Semantics.ValidOnFrames`, and
for the same reason: indexing the primitive by a bare frame predicate rather than by a
`FrameClass` tag is what lets one monotonicity lemma serve every bridge. -/
def MinusValidOnFrames (P : TaskFrame → Prop) (φ : MinusFormula) : Prop :=
  ∀ F : TaskFrame, P F → F.MinusValidOn φ

/-- `cor:tm-completeness`'s class-restricted consequence `⊨_C` for the base language. The L⁻
mirror of `Semantics.ValidIn`, over the same `FrameClass.Sat`. -/
def MinusValidIn (fc : ProofSystem.FrameClass) (φ : MinusFormula) : Prop :=
  MinusValidOnFrames fc.Sat φ

/--
A base-language formula is **valid** if it is true in all models, at all times, at every
**total** history, for every temporal type `D` satisfying the ordered-group binder set.

Binder-for-binder mirror of `Semantics.Valid`; see `def:logical-consequence`, whose "possible
worlds tau in H_F" are the total histories that `τ.IsTotal` picks out.

Uses `Type` (not `Type*`) to avoid universe-level issues in proofs, as `Valid` does.

**`MinusValid` is `MinusValidIn` at the unconstrained class**, exactly as `Valid` is `ValidIn .Base`:
`Sat FrameClass.Base` is `True`, so the tag attaches no frame condition. The pre-abbreviation
binder shape is reachable through `MinusValid.of_forall_total` / `MinusValid.apply` below.
-/
def MinusValid (φ : MinusFormula) : Prop :=
  MinusValidIn ProofSystem.FrameClass.Base φ

/-- Introduce `MinusValid` from its pre-abbreviation binder shape; the `Sat .Base` argument (`True`)
is discharged here rather than at each call site. The L⁻ mirror of `Valid.of_forall_total`. -/
theorem MinusValid.of_forall_total {φ : MinusFormula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : PartialHistory F),
           τ.IsTotal → ∀ t : F.Duration, MinusTruthAt M τ t φ) :
    MinusValid φ :=
  GenericValid.of_forall_total (L := MinusFormula) (φ := φ) h

/-- Eliminate `MinusValid` into its pre-abbreviation binder shape. The L⁻ mirror of `Valid.apply`. -/
theorem MinusValid.apply {φ : MinusFormula} (h : MinusValid φ) (F : TaskFrame) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (t : F.Duration) : MinusTruthAt M τ t φ :=
  GenericValid.apply (L := MinusFormula) (φ := φ) h F M τ hτ t

/-- **The one monotonicity lemma for L**: `MinusValidOnFrames` is antitone in its frame predicate.
The L⁻ mirror of `Semantics.ValidOnFrames.mono`. -/
theorem MinusValidOnFrames.mono {P Q : TaskFrame → Prop} {φ : MinusFormula} (h : ∀ F, Q F → P F)
    (hP : MinusValidOnFrames P φ) : MinusValidOnFrames Q φ :=
  GenericValidOnFrames.mono (L := MinusFormula) (φ := φ) h hP

/-- L validity is monotone in the `FrameClass` order, pointing the same direction as
`MinusLanguage.DerivationTree.lift`. The L⁻ mirror of `Semantics.ValidIn.mono`. -/
theorem MinusValidIn.mono {fc₁ fc₂ : ProofSystem.FrameClass} {φ : MinusFormula} (h : fc₁ ≤ fc₂)
    (hv : MinusValidIn fc₁ φ) : MinusValidIn fc₂ φ :=
  GenericValidIn.mono (L := MinusFormula) (φ := φ) h hv

/-! ### Binder-shape adapters for the generic layer

The L⁻ mirrors of `Semantics.ValidOnFrames.of_forall_total` / `.apply_total` and their
`FrameClass`-tagged forms. `MinusValidOnFrames` is stated over the bundled `(τ : TaskFrame.HF F)`;
every proof that consumes or produces it works with the unbundled pair
`(τ : PartialHistory F) (hτ : τ.IsTotal)`. The two spellings are not definitionally equal, so these
four are the shape adapters, exactly as on the full-language side: a goal site becomes
`refine MinusValidIn.of_forall_total ?_; intro F hF M τ hτ t`, and a hypothesis site becomes
`h.apply_total F hF M τ hτ t`.

Unlike the per-class `.of_forall`/`.apply` pairs further down, these are generic in the frame
predicate, which is what lets one pair serve every class at once. -/

/-- Introduce `MinusValidOnFrames` from the unbundled `(τ : PartialHistory F) (hτ : τ.IsTotal)` shape.
The L⁻ mirror of `Semantics.ValidOnFrames.of_forall_total`. -/
theorem MinusValidOnFrames.of_forall_total {P : TaskFrame → Prop} {φ : MinusFormula}
    (h : ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F) (τ : PartialHistory F),
           τ.IsTotal → ∀ t : F.Duration, MinusTruthAt M τ t φ) :
    MinusValidOnFrames P φ :=
  GenericValidOnFrames.of_forall_total (L := MinusFormula) (φ := φ) h

/-- Eliminate `MinusValidOnFrames` into the unbundled `(τ : PartialHistory F) (hτ : τ.IsTotal)` shape.
The L⁻ mirror of `Semantics.ValidOnFrames.apply_total`. -/
theorem MinusValidOnFrames.apply_total {P : TaskFrame → Prop} {φ : MinusFormula}
    (h : MinusValidOnFrames P φ) (F : TaskFrame) (hF : P F) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (t : F.Duration) : MinusTruthAt M τ t φ :=
  GenericValidOnFrames.apply_total (L := MinusFormula) (φ := φ) h F hF M τ hτ t

/-- `MinusValidOnFrames.of_forall_total` at a `FrameClass` tag. The L⁻ mirror of
`Semantics.ValidIn.of_forall_total`. -/
theorem MinusValidIn.of_forall_total {fc : ProofSystem.FrameClass} {φ : MinusFormula}
    (h : ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : PartialHistory F),
           τ.IsTotal → ∀ t : F.Duration, MinusTruthAt M τ t φ) :
    MinusValidIn fc φ :=
  GenericValidIn.of_forall_total (L := MinusFormula) (φ := φ) h

/-- `MinusValidOnFrames.apply_total` at a `FrameClass` tag. The L⁻ mirror of
`Semantics.ValidIn.apply_total`. -/
theorem MinusValidIn.apply_total {fc : ProofSystem.FrameClass} {φ : MinusFormula}
    (h : MinusValidIn fc φ) (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (t : F.Duration) : MinusTruthAt M τ t φ :=
  GenericValidIn.apply_total (L := MinusFormula) (φ := φ) h F hF M τ hτ t

/--
Validity over **dense** temporal orders, capturing the frame condition for L⁻'s density axiom
`dn` (`GGφ → Gφ`).

Binder-for-binder mirror of `Semantics.ValidDense`, and like it now an abbreviation: the frame
constraint is `FrameClass.Sat .Dense`, i.e. `TaskFrame.IsDense`. The binder shape this definition
used to have is recovered by the generic `MinusValidIn.of_forall_total` /
`MinusValidIn.apply_total`; the density witness reaches typeclass resolution
directly, because `FrameClass.Sat` is `@[reducible]` and `TaskFrame.IsDense` is an `abbrev`.
-/
def MinusValidDense (φ : MinusFormula) : Prop := MinusValidIn ProofSystem.FrameClass.Dense φ

/--
Validity over **discrete** temporal orders: `MinusValid` with successor and predecessor structure
added to the binder list, capturing the frame condition for L⁻'s discreteness axioms.

Binder-for-binder mirror of `Semantics.ValidZTime`, and like it now an abbreviation: the frame
constraint is `FrameClass.Sat .ZTime`, i.e. `TaskFrame.IsZTime` — `def:BX-z`'s
narrowing to ℤ-time (`prop:archimedean`). The binder shape this definition used to have is recovered by the generic `MinusValidIn.of_forall_total` /
`MinusValidIn.apply_total` followed by
`sat_intro`, which destructures the `IsZTime` existential into the four instances.
-/
def MinusValidZTime (φ : MinusFormula) : Prop := MinusValidIn ProofSystem.FrameClass.ZTime φ

/--
**`MinusValidZTime` with the two Archimedean binders dropped.**

Mirrors `MinusValidZTime`'s pre-abbreviation four-instance binder shape exactly, minus
`[IsSuccArchimedean F.Duration]` and `[IsPredArchimedean F.Duration]`. Unlike `MinusValidZTime`,
this is stated directly in the pre-abbreviation shape rather than as an abbreviation over
`MinusValidIn`: there is no `FrameClass.Sat` variant bundling `SuccOrder`+`PredOrder` alone
(`TaskFrame.IsZTime` bundles all four), so no `.of_forall`/`.apply` pair is needed —
a value of this type already **is** the binder-shape statement.

**Why this exists.** `Metalogic/Conservativity/MinusLanguageSoundness.lean`'s `minus_soundness_ztime_succ` is the
single prerequisite CEF was missing (report §6.1): a discrete L⁻ soundness theorem that does not
assume Archimedean structure, so it applies to the non-Archimedean carrier `ℚ ×ₗ ℤ`
(`Semantics/LexCarrier.lean`) that `Metalogic/Conservativity/Z1Countermodel.lean`'s countermodel is built over.
-/
def MinusValidZTimeSucc (φ : MinusFormula) : Prop :=
  ∀ (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration] (M : TaskModel F)
    (τ : PartialHistory F), τ.IsTotal → ∀ t : F.Duration, MinusTruthAt M τ t φ

/-- `MinusValid` weakens to `MinusValidZTimeSucc`, mirroring `MinusValidity.minusValid_implies_minusValidZTime`
and its dense/RTime siblings.

**Documented exception to the transfer-theorem collapse.** Its three siblings are corollaries of
`MinusValidIn.mono`, and every L⁻/L equivalence in `Metalogic/Conservativity/MinusLanguageSoundness.lean` is a
corollary of `minusValidIn_iff_validIn_tr`. This one is neither, and cannot be made either:
`MinusValidZTimeSucc` is **not** any `MinusValidIn fc` — no `FrameClass.Sat` variant bundles just
`SuccOrder` + `PredOrder` without the two Archimedean conditions, which is exactly the weakening
`minus_soundness_ztime_succ` needs for the non-Archimedean carrier `ℚ ×ₗ ℤ`. Adding such a tag to
`FrameClass` to make this a corollary would widen the proof side's class lattice to serve a
semantic convenience. Leave it as a direct lambda. -/
theorem MinusValidity.minusValid_implies_minusValidZTimeSucc {φ : MinusFormula} (h : MinusValid φ) :
    MinusValidZTimeSucc φ :=
  fun F _ _ M τ hτ t => h.apply F M τ hτ t

/--
Validity over **dense Dedekind-complete** temporal orders: the least-upper-bound hypothesis
together with `[DenselyOrdered D]`.

Binder-for-binder mirror of `Semantics.ValidRTime`, and **this — not a density-free
`MinusValidComplete` — is the target of the `FrameClass.RTime` soundness theorem.** The module
docstring above gives the L⁻-native refutation of the density-free form: `Axiom.dn` is admissible
at `FrameClass.RTime` and is false on `ℤ`, which satisfies every remaining binder. There is
deliberately no `MinusValidComplete` in this file.

Now an abbreviation: the frame constraint is `FrameClass.Sat .RTime`, i.e.
`TaskFrame.IsRTime`. The binder shape this definition used to have is recovered by the generic `MinusValidIn.of_forall_total` /
`MinusValidIn.apply_total` followed by
`sat_intro`, which splits `IsRTime` into the density instance and the least-upper-bound
hypothesis.
-/
def MinusValidRTime (φ : MinusFormula) : Prop := MinusValidIn ProofSystem.FrameClass.RTime φ

namespace MinusValidity

/-! ### Inclusion lemmas

All three are now corollaries of the single `MinusValidIn.mono`, routed through
`minusValid_iff_minusValidIn_base` and `FrameClass.base_le`. Before the indexing they were three
hand-written binder-discarding lambdas.

Two members of the L family have no mirror here, both for the same reason: they mention
`ValidComplete`, whose L⁻ counterpart is deliberately not defined (see the module docstring).
Those are `Validity.valid_implies_validComplete` and
`Validity.validRTime_of_validComplete`. -/

/-- `MinusValid` is `MinusValidIn` at the unconstrained class: `Sat .Base` is `True`. The L⁻ mirror of
`Validity.valid_iff_validIn_base`. -/
theorem minusValid_iff_minusValidIn_base (φ : MinusFormula) :
    MinusValid φ ↔ MinusValidIn ProofSystem.FrameClass.Base φ := Iff.rfl

/-- Validity implies validity over dense orders. -/
theorem minusValid_implies_minusValidDense {φ : MinusFormula} (h : MinusValid φ) : MinusValidDense φ :=
  MinusValidIn.mono (ProofSystem.FrameClass.base_le _) ((minusValid_iff_minusValidIn_base φ).mp h)

/-- Validity implies validity over discrete orders. -/
theorem minusValid_implies_minusValidZTime {φ : MinusFormula} (h : MinusValid φ) : MinusValidZTime φ :=
  MinusValidIn.mono (ProofSystem.FrameClass.base_le _) ((minusValid_iff_minusValidIn_base φ).mp h)

/-- Validity implies validity over dense Dedekind-complete orders. -/
theorem minusValid_implies_minusValidRTime {φ : MinusFormula} (h : MinusValid φ) :
    MinusValidRTime φ :=
  MinusValidIn.mono (ProofSystem.FrameClass.base_le _) ((minusValid_iff_minusValidIn_base φ).mp h)

/-- Validity is consequence from the empty context. Mirrors
`Validity.valid_iff_empty_consequence`.

**Documented exception to the transfer-theorem collapse.** `MinusSemanticConsequence` is an
orthogonal `Prop` shape, not a `MinusValidIn` at any tag: it takes the history `τ` unbundled, carries
no `FrameClass` index, and mentions no `tr`. So neither
`minusValidOnFrames_iff_validOnFrames_tr` nor `minusValidIn_iff_validIn_tr`
(`Metalogic/Conservativity/MinusLanguageSoundness.lean`) can prove it, and this two-branch script stays. -/
theorem minusValid_iff_empty_consequence (φ : MinusFormula) :
    MinusValid φ ↔ MinusSemanticConsequence [] φ := by
  constructor
  · intro h F M τ hτ t _
    exact h.apply F M τ hτ t
  · intro h
    refine MinusValid.of_forall_total ?_
    intro F M τ hτ t
    exact h F M τ hτ t (by intro ψ hψ; exact absurd hψ List.not_mem_nil)

end MinusValidity

end FormalSystem.Semantics
