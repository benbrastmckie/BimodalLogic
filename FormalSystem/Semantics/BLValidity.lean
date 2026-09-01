/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.BLTruth
import FormalSystem.Semantics.Validity

/-!
# BL validity — the base-language mirrors of `Semantics/Validity.lean`

Validity and semantic consequence for the tense-primitive base language BL, stated against the
native `BLTruthAt` of `Semantics/BLTruth.lean`.

Each predicate here is a **binder-for-binder mirror** of its counterpart in
`Semantics/Validity.lean`: `BLValid` of `valid`, `BLValidDense` of `ValidDense`,
`BLValidDiscrete` of `ValidDiscrete`, `BLValidDedekindDense` of `ValidDedekindDense`, and
`BLSemanticConsequence` of `SemanticConsequence`. Nothing changes but `Formula ↦ BLFormula` and
`TruthAt ↦ BLTruthAt`; in particular the histories quantified over are the **total** ones
(`τ.IsTotal`, the predicate form of `H_F`), matching `def:logical-consequence`, and `Type` rather
than `Type*` is used throughout for the same universe reason recorded on `valid`.

## The Dedekind asymmetry — read this before adding a `BLValidDedekind`

There is deliberately **no** density-free `BLValidDedekind`, and the soundness theorem for
`FrameClass.Dedekind` targets `BLValidDedekindDense`. A density-free target would be
**refutable**, and on the BL side one axiom suffices to refute it:

- `(BaseLanguage.Axiom.dn φ).minFrameClass = FrameClass.Dense` and
  `FrameClass.Dense ≤ FrameClass.Dedekind` (pinned by an `example` in
  `FormalSystem/BaseLanguage/Axioms.lean`), so `dn` — the density axiom `GGφ → Gφ` — is
  admissible in any `FrameClass.Dedekind` BL derivation.
- `dn` is false on `ℤ`: take `φ` true exactly at the times `≥ t + 2`. Then `GGφ` holds at `t`
  while `Gφ` fails at `t`, because `t + 1` is strictly future and `φ` is false there.
- `ℤ` satisfies every binder of a density-free `BLValidDedekind` — it is Dedekind-complete
  (Mathlib's `ConditionallyCompleteLinearOrder ℤ`) — so the refutation lands.

Adding `[DenselyOrdered D]` deletes exactly the `ℤ` branch of the Hölder dichotomy and nothing
else (`Semantics/DurationClassification.lean`). This is the BL-native form of the argument
`Semantics/Validity.lean` records for `ValidDedekind` on the BL⁺ side; note that BL⁺'s version
additionally leans on `Axiom.dense_indicator` (`¬(⊥ U ⊤)`), which has no BL counterpart at all
since BL has no `untl`. Do not "simplify" the target.

## Main Definitions

- `BLValid`, `BLSemanticConsequence` — validity and consequence over the `FrameClass.Base` binder
  set
- `BLValidDense`, `BLValidDiscrete`, `BLValidDedekindDense` — the three extension binder sets

## Main Results

- `BLValidity.blValid_implies_blValidDense`, `…_blValidDiscrete`, `…_blValidDedekindDense` — the
  inclusion lemmas mirroring `Validity.valid_implies_valid_dense` and its siblings
- `BLValidity.blValid_iff_empty_consequence` — validity is consequence from the empty context

## References

* JPL paper `\S sub:Logic` — `def:BL-semantics`, `def:logical-consequence`
* `FormalSystem/Semantics/Validity.lean` — the BL⁺ predicates these mirror
* `FormalSystem/Metalogic/BaseLanguageSoundness.lean` — the soundness theorems targeting these
-/

namespace FormalSystem.Semantics

open FormalSystem.BaseLanguage

/--
Semantic consequence in the base language: `φ` is true at every model, **total** history and time
at which every formula of `Γ` is true.

Binder-for-binder mirror of `Semantics.SemanticConsequence`.
-/
def BLSemanticConsequence (Γ : BaseLanguage.Context) (φ : BLFormula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    (∀ ψ ∈ Γ, BLTruthAt M τ t ψ) →
    BLTruthAt M τ t φ

/-! ## `FrameClass`-indexed validity for the base language

The same two-layer shape `Semantics/Validity.lean` gives the full language, mirrored here against
`BLTruthAt`. BL⁺ needs its own predicates because it has its own truth recursion — `BLTruthAt` is
defined natively on `BLFormula`'s six constructors per `def:BL-semantics`, not via `untl`/`snce` —
but it shares one and the same `FrameClass.Sat`, so the frame classes the two languages are
indexed by are literally the same classes and not two parallel copies. -/

/--
`def:frame-validity` for the base language: `φ` is **valid over the frame `F`** iff it is true at
every model over `F`, every possible world `τ ∈ H_F`, and every time `x ∈ D`.

The BL mirror of `TaskFrame.ValidOn`, and in fact the more literal reading of the anchor, whose
text is stated for "a well-formed sentence `φ` of `BL`". `TaskFrame.ValidOn` is the same clause
applied to the full language's `Formula`. Both render the bundled `H_F` as `TaskFrame.HF`.
-/
def TaskFrame.BLValidOn (F : TaskFrame) (φ : BLFormula) : Prop :=
  ∀ (M : TaskModel F) (τ : TaskFrame.HF F) (x : F.Duration), BLTruthAt M τ.val x φ

/-- `φ` is valid on every frame satisfying `P`. The BL mirror of `Semantics.ValidOnFrames`, and
for the same reason: indexing the primitive by a bare frame predicate rather than by a
`FrameClass` tag is what lets one monotonicity lemma serve every bridge. -/
def BLValidOnFrames (P : TaskFrame → Prop) (φ : BLFormula) : Prop :=
  ∀ F : TaskFrame, P F → F.BLValidOn φ

/-- `cor:tm-completeness`'s class-restricted consequence `⊨_C` for the base language. The BL
mirror of `Semantics.ValidIn`, over the same `FrameClass.Sat`. -/
def BLValidIn (fc : ProofSystem.FrameClass) (φ : BLFormula) : Prop :=
  BLValidOnFrames fc.Sat φ

/--
A base-language formula is **valid** if it is true in all models, at all times, at every
**total** history, for every temporal type `D` satisfying the ordered-group binder set.

Binder-for-binder mirror of `Semantics.valid`; see `def:logical-consequence`, whose "possible
worlds tau in H_F" are the total histories that `τ.IsTotal` picks out.

Uses `Type` (not `Type*`) to avoid universe-level issues in proofs, as `valid` does.

**`BLValid` is `BLValidIn` at the unconstrained class**, exactly as `valid` is `ValidIn .Base`:
`Sat FrameClass.Base` is `True`, so the tag attaches no frame condition. The pre-abbreviation
binder shape is reachable through `BLValid.of_forall_total` / `BLValid.apply` below.
-/
def BLValid (φ : BLFormula) : Prop :=
  BLValidIn ProofSystem.FrameClass.Base φ

/-- Introduce `BLValid` from its pre-abbreviation binder shape; the `Sat .Base` argument (`True`)
is discharged here rather than at each call site. The BL mirror of `valid.of_forall_total`. -/
theorem BLValid.of_forall_total {φ : BLFormula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F),
           τ.IsTotal → ∀ t : F.Duration, BLTruthAt M τ t φ) :
    BLValid φ :=
  fun F _ M τ t => h F M τ.val τ.property t

/-- Eliminate `BLValid` into its pre-abbreviation binder shape. The BL mirror of `valid.apply`. -/
theorem BLValid.apply {φ : BLFormula} (h : BLValid φ) (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) : BLTruthAt M τ t φ :=
  h F trivial M ⟨τ, hτ⟩ t

/-- **The one monotonicity lemma for BL⁺**: `BLValidOnFrames` is antitone in its frame predicate.
The BL mirror of `Semantics.ValidOnFrames.mono`. -/
theorem BLValidOnFrames.mono {P Q : TaskFrame → Prop} {φ : BLFormula} (h : ∀ F, Q F → P F)
    (hP : BLValidOnFrames P φ) : BLValidOnFrames Q φ :=
  fun F hF => hP F (h F hF)

/-- BL⁺ validity is monotone in the `FrameClass` order, pointing the same direction as
`BaseLanguage.DerivationTree.lift`. The BL mirror of `Semantics.ValidIn.mono`. -/
theorem BLValidIn.mono {fc₁ fc₂ : ProofSystem.FrameClass} {φ : BLFormula} (h : fc₁ ≤ fc₂)
    (hv : BLValidIn fc₁ φ) : BLValidIn fc₂ φ :=
  BLValidOnFrames.mono (fun _ => ProofSystem.FrameClass.Sat.anti h) hv

/--
Validity over **dense** temporal orders, capturing the frame condition for BL's density axiom
`dn` (`GGφ → Gφ`).

Binder-for-binder mirror of `Semantics.ValidDense`, and like it now an abbreviation: the frame
constraint is `FrameClass.Sat .Dense`, i.e. `TaskFrame.IsDense`. The binder shape this definition
used to have is recovered by `BLValidDense.of_forall` / `BLValidDense.apply`.
-/
def BLValidDense (φ : BLFormula) : Prop := BLValidIn ProofSystem.FrameClass.Dense φ

/-- Introduce `BLValidDense` from the pre-abbreviation binder shape, with the density witness
restored to the local context as an instance. -/
theorem BLValidDense.of_forall {φ : BLFormula}
    (h : ∀ (F : TaskFrame) [DenselyOrdered F.Duration] (M : TaskModel F)
           (τ : WorldHistory F), τ.IsTotal → ∀ t : F.Duration, BLTruthAt M τ t φ) :
    BLValidDense φ :=
  fun F hF M τ t => @h F hF M τ.val τ.property t

/-- Eliminate `BLValidDense` into the pre-abbreviation binder shape. -/
theorem BLValidDense.apply {φ : BLFormula} (h : BLValidDense φ) (F : TaskFrame)
    [inst : DenselyOrdered F.Duration] (M : TaskModel F) (τ : WorldHistory F)
    (hτ : τ.IsTotal) (t : F.Duration) : BLTruthAt M τ t φ :=
  h F inst M ⟨τ, hτ⟩ t

/--
Validity over **discrete** temporal orders: `BLValid` with successor and predecessor structure
added to the binder list, capturing the frame condition for BL's discreteness axioms.

Binder-for-binder mirror of `Semantics.ValidDiscrete`, and like it now an abbreviation: the frame
constraint is `FrameClass.Sat .Discrete`, i.e. `TaskFrame.IsSuccArchDiscrete` — `def:TMplus-f`'s
Hölder narrowing to ℤ-time. The binder shape this definition used to have is recovered by
`BLValidDiscrete.of_forall` / `BLValidDiscrete.apply`.
-/
def BLValidDiscrete (φ : BLFormula) : Prop := BLValidIn ProofSystem.FrameClass.Discrete φ

/-- Introduce `BLValidDiscrete` from the pre-abbreviation four-instance binder shape. The
existential `TaskFrame.IsSuccArchDiscrete` is destructured with `obtain` and its witnesses passed
positionally with `@`, never through `haveI`. -/
theorem BLValidDiscrete.of_forall {φ : BLFormula}
    (h : ∀ (F : TaskFrame) [SuccOrder F.Duration] [PredOrder F.Duration]
           [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] (M : TaskModel F)
           (τ : WorldHistory F), τ.IsTotal → ∀ t : F.Duration, BLTruthAt M τ t φ) :
    BLValidDiscrete φ := by
  intro F hF M τ t
  obtain ⟨so, po, hsa, hpa⟩ := hF
  exact @h F so po hsa hpa M τ.val τ.property t

/-- Eliminate `BLValidDiscrete` into the pre-abbreviation binder shape. -/
theorem BLValidDiscrete.apply {φ : BLFormula} (h : BLValidDiscrete φ) (F : TaskFrame)
    [so : SuccOrder F.Duration] [po : PredOrder F.Duration]
    [hsa : IsSuccArchimedean F.Duration] [hpa : IsPredArchimedean F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) :
    BLTruthAt M τ t φ :=
  h F ⟨so, po, hsa, hpa⟩ M ⟨τ, hτ⟩ t

/--
Validity over **dense Dedekind-complete** temporal orders: the least-upper-bound hypothesis
together with `[DenselyOrdered D]`.

Binder-for-binder mirror of `Semantics.ValidDedekindDense`, and **this — not a density-free
`BLValidDedekind` — is the target of the `FrameClass.Dedekind` soundness theorem.** The module
docstring above gives the BL-native refutation of the density-free form: `Axiom.dn` is admissible
at `FrameClass.Dedekind` and is false on `ℤ`, which satisfies every remaining binder. There is
deliberately no `BLValidDedekind` in this file.

Now an abbreviation: the frame constraint is `FrameClass.Sat .Dedekind`, i.e.
`TaskFrame.IsDedekind`. The binder shape this definition used to have is recovered by
`BLValidDedekindDense.of_forall` / `BLValidDedekindDense.apply`.
-/
def BLValidDedekindDense (φ : BLFormula) : Prop := BLValidIn ProofSystem.FrameClass.Dedekind φ

/-- Introduce `BLValidDedekindDense` from the pre-abbreviation binder shape. -/
theorem BLValidDedekindDense.of_forall {φ : BLFormula}
    (h : ∀ (F : TaskFrame) [DenselyOrdered F.Duration],
           (∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) →
           ∀ (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal →
             ∀ t : F.Duration, BLTruthAt M τ t φ) :
    BLValidDedekindDense φ :=
  fun F hF M τ t => @h F hF.1 hF.2 M τ.val τ.property t

/-- Eliminate `BLValidDedekindDense` into the pre-abbreviation binder shape. -/
theorem BLValidDedekindDense.apply {φ : BLFormula} (h : BLValidDedekindDense φ) (F : TaskFrame)
    [inst : DenselyOrdered F.Duration]
    (hlub : ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (M : TaskModel F) (τ : WorldHistory F) (hτ : τ.IsTotal) (t : F.Duration) :
    BLTruthAt M τ t φ :=
  h F ⟨inst, hlub⟩ M ⟨τ, hτ⟩ t

namespace BLValidity

/-! ### Inclusion lemmas

All three are now corollaries of the single `BLValidIn.mono`, routed through
`blValid_iff_blValidIn_base` and `FrameClass.base_le`. Before the indexing they were three
hand-written binder-discarding lambdas.

Two members of the BL⁺ family have no mirror here, both for the same reason: they mention
`ValidDedekind`, whose BL counterpart is deliberately not defined (see the module docstring).
Those are `Validity.valid_implies_validDedekind` and
`Validity.validDedekindDense_of_validDedekind`. -/

/-- `BLValid` is `BLValidIn` at the unconstrained class: `Sat .Base` is `True`. The BL mirror of
`Validity.valid_iff_validIn_base`. -/
theorem blValid_iff_blValidIn_base (φ : BLFormula) :
    BLValid φ ↔ BLValidIn ProofSystem.FrameClass.Base φ := Iff.rfl

/-- Validity implies validity over dense orders. -/
theorem blValid_implies_blValidDense {φ : BLFormula} (h : BLValid φ) : BLValidDense φ :=
  BLValidIn.mono (ProofSystem.FrameClass.base_le _) ((blValid_iff_blValidIn_base φ).mp h)

/-- Validity implies validity over discrete orders. -/
theorem blValid_implies_blValidDiscrete {φ : BLFormula} (h : BLValid φ) : BLValidDiscrete φ :=
  BLValidIn.mono (ProofSystem.FrameClass.base_le _) ((blValid_iff_blValidIn_base φ).mp h)

/-- Validity implies validity over dense Dedekind-complete orders. -/
theorem blValid_implies_blValidDedekindDense {φ : BLFormula} (h : BLValid φ) :
    BLValidDedekindDense φ :=
  BLValidIn.mono (ProofSystem.FrameClass.base_le _) ((blValid_iff_blValidIn_base φ).mp h)

/-- Validity is consequence from the empty context. Mirrors
`Validity.valid_iff_empty_consequence`. -/
theorem blValid_iff_empty_consequence (φ : BLFormula) :
    BLValid φ ↔ BLSemanticConsequence [] φ := by
  constructor
  · intro h F M τ hτ t _
    exact h.apply F M τ hτ t
  · intro h
    refine BLValid.of_forall_total ?_
    intro F M τ hτ t
    exact h F M τ hτ t (by intro ψ hψ; exact absurd hψ List.not_mem_nil)

end BLValidity

end FormalSystem.Semantics
