/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.MinusLanguageSoundness
import FormalSystem.Metalogic.BXCanonical
import FormalSystem.Metalogic.StrongCompleteness

/-!
# The TM⁻-completeness / forward-conservativity reduction

**Read `Metalogic/Conservativity.lean`'s module docstring first.** That module states, and
proves the tree must never state or `sorry`, the **forward-conservativity prohibition**:

```
theorem forward {fc} {φ} : ProofSystem.Derivable fc [] (tr φ) → MinusLanguage.Derivable fc [] φ
```

is refuted at `fc := .Base` and `fc := .ZTime`, and a `sorry`-ed proof of it would be an
unsound placeholder, not deferred debt.

**This module strengthens that prohibition by exposing a second phrasing of the forbidden
claim.** Given the tree's own `BXCanonical.completeness` (L completeness at `.Base`) and
`minusValid_iff_valid_tr` (the L⁻/L validity bridge), "TM⁻ is complete over task frames" and
"forward conservativity holds at `FrameClass.Base`" turn out to be *the same proposition* — a
two-line composition of results already in this tree, with **neither side asserted**. Nothing
here proves TM⁻-completeness, and nothing here proves forward conservativity; the point is that a
future dispatch attempting either one, in good faith, is thereby attempting the other, and is
covered by the same prohibition. No `sorry` occurs anywhere in this file, and neither
`TMMinusCompleteBase` nor `ForwardBase` (nor their `.ZTime` siblings) appears as the conclusion of
any `theorem` below — both are `def`s, referenced only as the *statement* being related, never
discharged.

## Where the backward direction does the work

`tmMinusCompleteBase_iff_forwardBase`'s **backward** direction (`ForwardBase → TMMinusCompleteBase`) is
where `BXCanonical.completeness` — TM's completeness over *all* task frames, `cor:tm-completeness`
row 1, machine-checked in this tree — actually does the work: it is the step that turns a
L⁻-valid formula into a `⊢[Base] tr φ` derivation, which `ForwardBase` then pulls back across the
translation. The **forward** direction (`TMMinusCompleteBase → ForwardBase`) is the easier composition,
routing `⊢[Base] tr φ` through TM's own soundness to `Valid (tr φ)`, then across
`minusValid_iff_valid_tr` to `MinusValid φ`.

## Main Definitions

- `TMMinusComplete fc` — "TM⁻ is complete over the frames of `fc`": every `fc`-L⁻-valid formula is
  TM⁻-derivable at `fc`. Unasserted, at every tag.
- `Forward fc` — the forward-conservativity statement at `fc`, literally `Conservativity.lean`'s
  forbidden `forward` theorem restricted to one frame class. Unasserted, at every tag.
- `TMMinusCompleteBase`, `TMMinusCompleteZTime`, `ForwardBase`, `ForwardZTime` — the two tags this
  module named before the generalization, retained as instantiations with their statements
  unchanged.

## Main Results

- `tmMinusComplete_iff_forward` — the two propositions are equivalent at any `fc` supplying a
  `WeakCompleteness fc` engine
- `tmMinusCompleteBase_iff_forwardBase`, `tmMinusCompleteZTime_iff_forwardZTime` — its two
  pre-existing instantiations
- `tmMinusCompleteDense_iff_forwardDense`, `tmMinusCompleteRTime_iff_forwardRTime` — two further
  rows the generalization yields for free

The **four-row status table** below is the canonical record of where each row stands, including
the two that are open; it is prose, not a declaration, and asserts none of the four propositions.

## The four-row status table

**This is the canonical location for the status of all four rows.** Each row asks the same
question — is TM⁻ (at that frame class) weakly complete for base-language validity over that class,
equivalently does forward conservativity hold there — and by `tmMinusComplete_iff_forward` the two
readings never come apart. Two rows are closed, two are not.

| Frame class | System | Status | Evidence |
|---|---|---|---|
| `.Base` | TM⁻ | **refuted** | `tmMinusCompleteBase_refuted` (`Conservativity/SpCountermodel.lean`), witnessed by `Sp` on the two-fibre `ℤ ⊕ ℝ` model |
| `.ZTime` | TM⁻_z | **refuted** | `tmMinusCompleteZTime_refuted` (`Conservativity/Z1Countermodel.lean`), witnessed by `Z1` on `ℚ ×ₗ ℤ` |
| `.Dense` | TM⁻_d | **open; expected complete, no obstruction found** | see below |
| `.RTime` | TM⁻_dc | **open; obstruction named** | see below |

Both closed rows are closed by a *dichotomy witness*: a schema valid over the class because the
class splits into two subclasses that H/G can tell apart, while no single derivation covers both.
That is the shape of argument the two open rows do not admit, which is the whole reason they are
open in the direction they are.

### `.Dense` — expected complete, unproved

**No obstruction is known, and both known witnesses provably fail to transfer.**
`Conservativity/DenseObstructionTransfer.lean` machine-checks both halves:

* `spDerivableDense` — the `.Base` witness `Sp` is a **theorem** of TM⁻_d (its right disjunct's
  inner formula is `Axiom.dn`), so it is not an underivable validity. `spDerivableRTime` says
  the same at `.RTime`.
* `not_minusValidDense_z1` — the `.ZTime` witness `Z1` is **not** dense-valid, refuted on the flow
  frame over ℚ, so it is not a validity of the class at all.

`FrameClass.Dense` does not split into two H/G-definable subclasses the way `.Base` (dense versus
least-positive durations) and `.ZTime` (Archimedean versus not) do, so no dichotomy witness of the
known shape is available. **This is evidence, not proof.** It rules out the two witnesses that
exist in this tree; it says nothing about some third witness.

**What a positive answer still needs**, at declaration granularity. The *transfer* half is already
closed: `not_minusValidIn_of_not_chainSat` (`Conservativity/ChainBundleTruth.lean`) turns a chain-model
refutation into a task-frame refutation at any tag the flow frame satisfies, with
`not_minusValidDense_of_not_chainSat` the ℚ instantiation, and the frame construction it consumes
(`multiFamTaskFrameGen`, `Metalogic/Algebraic/FlowFrame.lean`) was already generic. What is missing
is the *canonical model*, all of it on the base-language side:

1. a maximal-consistent-set layer over `MinusFormula`. `Metalogic/Core/`'s apparatus
   (`MaximalConsistent.lean`, `MCSProperties.lean`, `DeductionTheorem.lean`) is stated over
   `Formula` throughout and does not transfer;
2. canonicity for the eleven Base axioms plus `DN`;
3. bulldozing the canonical clusters into chains;
4. realization of each countable dense unbounded chain as ℚ, for which Mathlib's
   `Order.iso_of_countable_dense` is the off-the-shelf step.

Borrowing `Metalogic/BXCanonical/Chronicle/` instead is **not** an option, and the reason is worth
recording because it is not obvious: that machinery starts from a `SetMaximalConsistent` set of
`Formula`s, so using it would require "`{¬φ}` is TM⁻_d-consistent ⟹ `{tr ¬φ}` is TM_d-consistent",
which is the contrapositive of the very forward-conservativity statement being proved. The route
is circular, not merely inconvenient.

### `.RTime` — open, with the obstruction named

The temporal part of TM⁻_dc is the H/G logic of ℝ, and `Axiom.co` is the Dedekind axiom of that
literature: reading `S := {u | Hφ(u)}`, `CO`'s antecedent says the downward-closed `S` has no
maximum and its consequent says `S` is unbounded above — which is Dedekind completeness, and fails
on ℚ at `φ(w) :↔ w < √2`.

**The obstruction, at declaration granularity.** The abstract Doets layer in this tree is genuinely
reusable: `DoetsD1`/`DoetsD2` and `doets_theorem_dense`
(`Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean`) are stated over an arbitrary
`OrderedMonadicStructure` at an arbitrary signature, and their D1/D2 suppliers
(`no_gaps_dense_prior`, `reynolds_theorem5`, `Metalogic/WeakCanonical/DenseModelSurgery/`) are
abstract too. The gap is one level down: **every existing discharge of the semantic side conditions
those suppliers need consumes an axiom the base language cannot express.**
`chronicleMonadic_semanticPriorU` consumes `Axiom.prior_U_gap`, `chronicleMonadic_semanticPriorS`
consumes `Axiom.prior_S_gap`, and `chronicleMonadic_semanticSep` consumes `Axiom.sep` (all in
`Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean`); D1 needs the first two and D2 needs
all three. None of those three axioms is expressible in `MinusFormula`, which has six constructors —
`atom`, `bot`, `imp`, `box`, `allPast`, `allFuture` — and no `untl`, `snce`, `kPlus` or `kMinus`.

So the `.RTime` row reduces to: **discharge `SemanticPriorU`, `SemanticPriorS` and
`SemanticSepOpen` — or find weaker H/G-sufficient replacements for D1/D2 — on a base-language
canonical structure, from `CO` alone.** Nothing in this tree or in Mathlib bears on whether `CO`
suffices.

Two things make this row harder than `.Dense` rather than merely later:

* `CO` is **not Sahlqvist**, so the canonicity argument sketched for `.Dense` above does not carry
  over, and a step-by-step or Dedekind-completion construction is needed instead.
* `sep` is named for **separability**. If ℝ is distinguished from other Dedekind-complete chains in
  the H/G language the way it appears to be in the U/S language, the `.RTime` verdict is
  **negative**, and the separating witness is a formula valid on ℝ but refuted on some
  Dedekind-complete non-separable dense unbounded chain. Nothing established here rules that out,
  so a refutation probe is the cheaper thing to try first, and
  `not_minusValidRTime_of_not_chainSat` is the interface such a probe would consume.

### What the prohibition does and does not forbid

`Metalogic/Conservativity.lean`'s standing prohibition is: **do not state a completeness or
forward-conservativity theorem for L⁻ ⊂ L and discharge it with `sorry`.** It is not a prohibition
on *proving* one. `forward` is refuted at `.Base` and `.ZTime`, so a `sorry` there would be an
unsound placeholder rather than deferred debt; at `.Dense` and `.RTime` the statements are simply
open, and a genuine proof of either would be welcome. What is forbidden at all four tags is
asserting one without a proof — and, equally, reading the `.Dense` row above as though the expected
answer had been established. It has not been. Every `TMMinusComplete` and `Forward` proposition in this
module is a `def`, referenced as a statement and never the conclusion of a theorem.

## References

* `FormalSystem/Metalogic/Conservativity.lean` — the forward-conservativity prohibition this
  module strengthens
* `FormalSystem/Metalogic/BXCanonical/Completeness.lean` — `completeness`, `completeness_ztime`
* `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` — `minusValid_iff_valid_tr`,
  `minusValidZTime_iff_validZTime_tr`
* `FormalSystem/Metalogic/Conservativity/SpCountermodel.lean`,
  `FormalSystem/Metalogic/Conservativity/Z1Countermodel.lean` — the two closed rows'
  refutations, `tmMinusCompleteBase_refuted` and `tmMinusCompleteZTime_refuted`
* `FormalSystem/Metalogic/Conservativity/DenseObstructionTransfer.lean` — `spDerivableDense`,
  `spDerivableRTime`, `not_minusValidDense_z1`: neither closed row's witness transfers
* `FormalSystem/Metalogic/Conservativity/ChainBundleTruth.lean` —
  `not_minusValidIn_of_not_chainSat` and its ℚ/ℝ instantiations, the transfer half of the
  canonical-model route
* `FormalSystem/Metalogic/WeakCanonical/RealModel/DoetsTheorem.lean`,
  `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` — the Doets layer
  and the L-only axiom consumption that is the `.RTime` row's named obstruction
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic.Conservativity

/-! ## The reduction, at any frame class

Both propositions and the equivalence between them, stated once and indexed by the `FrameClass`
tag. The four per-tag rows below are instantiations; before this collapse the `.Base` and
`.ZTime` rows were two hand-written copies of the same two-line composition, and the `.Dense`
and `.RTime` rows did not exist. -/

/--
**"TM⁻ is complete over the frames of `fc`."** Every `fc`-L⁻-valid formula is derivable in TM⁻ at
`fc`. **Unasserted** — this `def` states the proposition so it can be named and related to
`Forward` below; it is never the conclusion of a `theorem` in this tree, at any tag.
-/
def TMMinusComplete (fc : FrameClass) : Prop :=
  ∀ φ : MinusFormula, MinusValidIn fc φ → MinusLanguage.Derivable fc [] φ

/--
**"Forward conservativity holds at `fc`."** Literally the `forward` theorem
`Conservativity.lean`'s module docstring shows must never be stated or `sorry`-ed, restricted to
one tag. **Unasserted**, for the same reason.
-/
def Forward (fc : FrameClass) : Prop :=
  ∀ φ : MinusFormula, ProofSystem.Derivable fc [] (tr φ) → MinusLanguage.Derivable fc [] φ

/--
**The reduction, generically.** `TMMinusComplete fc` and `Forward fc` are the same proposition, given
a weak-completeness engine at `fc`.

Forward (`TMMinusComplete fc → Forward fc`): given `⊢[fc] tr φ`, `soundness_validIn`
(`Metalogic/Soundness.lean`) gives `ValidIn fc (tr φ)`, and `minusValidIn_iff_validIn_tr`
(`Metalogic/Conservativity/MinusLanguageSoundness.lean`) crosses to `MinusValidIn fc φ`; apply the hypothesis. This
direction does not use the engine.

Backward (`Forward fc → TMMinusComplete fc`): given `MinusValidIn fc φ`, `minusValidIn_iff_validIn_tr` gives
`ValidIn fc (tr φ)`, and the **engine** turns that into `⊢[fc] tr φ`; apply the hypothesis. This
is where TM's completeness does the actual work, and it is the whole of the class-dependence —
the reason `WeakCompleteness fc` is the hypothesis rather than anything stronger.

**The module's prohibition discipline is preserved, not weakened.** The conclusion here is an
`Iff`, not either side of it: nothing below asserts `TMMinusComplete fc` and nothing asserts
`Forward fc`. What the generalization adds is that the equivalence now holds at all four tags
rather than two, so a future dispatch attempting either side at *any* class is thereby
attempting the other, and is covered by the same prohibition.
-/
theorem tmMinusComplete_iff_forward {fc : FrameClass} (engine : WeakCompleteness fc) :
    TMMinusComplete fc ↔ Forward fc := by
  constructor
  · intro hcomplete φ h
    exact hcomplete φ ((minusValidIn_iff_validIn_tr fc φ).mpr (h.elim soundness_validIn))
  · intro hforward φ hvalid
    exact hforward φ (engine (tr φ) ((minusValidIn_iff_validIn_tr fc φ).mp hvalid))

/-! ## `FrameClass.Base` -/

/--
**"TM⁻ is complete over task frames."** `TMMinusComplete` at `.Base`. `MinusValid` is `MinusValidIn .Base`
definitionally (`Semantics/MinusLanguage/MinusValidity.lean`), so the statement is unchanged by the
generalization. **Unasserted.**
-/
def TMMinusCompleteBase : Prop := TMMinusComplete FrameClass.Base

/--
**"Forward conservativity holds at `FrameClass.Base`."** `Forward` at `.Base`. **Unasserted**,
for the same reason.
-/
def ForwardBase : Prop := Forward FrameClass.Base

/-- **The reduction at `.Base`.** `tmMinusComplete_iff_forward` with `completeness_base`
(`Metalogic/StrongCompleteness.lean`) as the engine — that theorem is stated as a
`WeakCompleteness FrameClass.Base` witness, so it inhabits the hypothesis on the nose. -/
theorem tmMinusCompleteBase_iff_forwardBase : TMMinusCompleteBase ↔ ForwardBase :=
  tmMinusComplete_iff_forward completeness_base

/-! ## `FrameClass.ZTime` -/

/--
**"TM⁻_z is complete over `FrameClass.ZTime` task frames."** `TMMinusComplete` at `.ZTime`;
`MinusValidZTime` is `MinusValidIn .ZTime` definitionally. **Unasserted**, exactly as
`TMMinusCompleteBase`.
-/
def TMMinusCompleteZTime : Prop := TMMinusComplete FrameClass.ZTime

/--
**"Forward conservativity holds at `FrameClass.ZTime`."** `Forward` at `.ZTime`.
**Unasserted**, exactly as `ForwardBase`.
-/
def ForwardZTime : Prop := Forward FrameClass.ZTime

/-- **The `.ZTime` mirror**, with `completeness_ztime` as the engine. -/
theorem tmMinusCompleteZTime_iff_forwardZTime : TMMinusCompleteZTime ↔ ForwardZTime :=
  tmMinusComplete_iff_forward completeness_ztime

/-! ## The two rows the generalization yields

`FrameClass.Dense` and `FrameClass.RTime` carry weak-completeness engines of their own
(`completeness_dense` and `completeness_rtime`, the latter being Reynolds 1992 §9 Theorem 7 as
formalized in this tree), so the same equivalence holds at those tags. Neither row existed before
the collapse, and neither costs anything beyond naming it. Both sides remain **unasserted** at
both tags, exactly as at `.Base` and `.ZTime`. -/

/-- **The `.Dense` row.** `tmMinusComplete_iff_forward completeness_dense`. -/
theorem tmMinusCompleteDense_iff_forwardDense :
    TMMinusComplete FrameClass.Dense ↔ Forward FrameClass.Dense :=
  tmMinusComplete_iff_forward completeness_dense

/-- **The `.RTime` row.** `tmMinusComplete_iff_forward completeness_rtime`. -/
theorem tmMinusCompleteRTime_iff_forwardRTime :
    TMMinusComplete FrameClass.RTime ↔ Forward FrameClass.RTime :=
  tmMinusComplete_iff_forward completeness_rtime


end FormalSystem.Metalogic
