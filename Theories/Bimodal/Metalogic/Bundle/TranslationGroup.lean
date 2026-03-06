import Bimodal.Metalogic.Bundle.BidirectionalReachable
import Bimodal.Semantics.TaskFrame
import Mathlib.Algebra.Order.Group.End
import Mathlib.Algebra.Group.TypeTags.Basic

/-!
# Translation Group: D from Canonical Timeline

This module constructs the duration type D as the group of order-preserving
automorphisms of the canonical timeline T (the BidirectionalQuotient of MCSes),
viewed additively.

## Construction

Given a root MCS `M₀` and its bidirectional fragment:
- **T** = `BidirectionalQuotient M₀ h_mcs₀` (LinearOrder from BidirectionalReachable.lean)
- **D** = `Additive (T ≃o T)` (order automorphisms, written additively)
- **Group structure**: composition via `RelIso.instGroup` + `Additive`

## Action Convention

The action uses the INVERSE of the order automorphism:
  `d.apply w = (Additive.toMul d).symm w`

This is needed because `RelIso.instGroup` defines multiplication as
`f * g = g.trans f`, giving `(f * g)(x) = f(g(x))` (left-to-right composition).

With the inverse convention and TaskFrame's compositionality requirement
(`task_rel w d₁ u ∧ task_rel u d₂ v → task_rel w (d₁ + d₂) v`):
- `(toMul d₁).symm w = u` and `(toMul d₂).symm u = v`
- `(toMul(d₁ + d₂)).symm w = (toMul d₂).symm((toMul d₁).symm w)
   = (toMul d₂).symm(u) = v` ✓

## What This Module Proves (Sorry-Free)

1. D = `TranslationGroup` has `AddGroup` instance
2. Nullity: zero translation (identity) maps every point to itself
3. Compositionality: sequential translations compose via group addition
4. Action is injective in the point argument (from OrderIso)
5. Action preserves order (from OrderIso)
6. Inverse cancellation in both directions
7. Determinism and reversibility of the task relation

## What Requires Future Work

The following properties require non-trivial mathematical arguments about the
specific structure of the canonical timeline. They are NOT stated with sorry;
they are simply deferred to future tasks that must prove them before assembling
the full `TaskFrame (TranslationGroup M₀ h_mcs₀)`:

1. **AddCommGroup**: Requires Holder's theorem (freeness + order ⟹ abelian)
2. **LinearOrder on D**: Requires injectivity of eval-at-origin (freeness)
3. **IsOrderedAddMonoid**: Requires linear order + order compatibility
4. **AddTorsor D T**: Requires homogeneity (transitivity of action)

## References

- Task 956: Construct D as translation group from syntax
- research-005.md: Torsor-based construction analysis
- BidirectionalReachable.lean: T with LinearOrder
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/-!
## Section 1: Type Definitions
-/

/--
The canonical timeline: the antisymmetrized bidirectional fragment.
This type has `LinearOrder` from `instLinearOrderBidirectionalQuotient`.
-/
abbrev CanonicalTimeline (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :=
  BidirectionalQuotient M₀ h_mcs₀

/--
The translation group D: order-preserving automorphisms of the canonical timeline,
written additively.

- Elements: order isomorphisms `T ≃o T`
- Addition: composition (via `RelIso.instGroup`: `f * g = g.trans f`)
- Zero: identity automorphism
- Negation: inverse automorphism (`f⁻¹ = f.symm`)
-/
abbrev TranslationGroup (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :=
  Additive (CanonicalTimeline M₀ h_mcs₀ ≃o CanonicalTimeline M₀ h_mcs₀)

/-- D has AddGroup from RelIso.instGroup + Additive. -/
noncomputable instance instAddGroupTranslationGroup :
    AddGroup (TranslationGroup M₀ h_mcs₀) :=
  Additive.addGroup

/-!
## Section 2: Group Action of D on T

The action uses the INVERSE (symm) of the order automorphism to ensure
TaskFrame compositionality without requiring commutativity.
-/

/--
Apply a translation (order automorphism, inverted) to a timeline point.

Uses the inverse convention: `d.apply w = (Additive.toMul d).symm w`.
This ensures compositionality: `(d₁ + d₂).apply w = d₂.apply(d₁.apply w)`.
-/
noncomputable def TranslationGroup.apply
    (d : TranslationGroup M₀ h_mcs₀) (w : CanonicalTimeline M₀ h_mcs₀) :
    CanonicalTimeline M₀ h_mcs₀ :=
  (Additive.toMul d).symm w

/--
The zero translation acts as the identity.
-/
@[simp]
theorem TranslationGroup.apply_zero (w : CanonicalTimeline M₀ h_mcs₀) :
    TranslationGroup.apply 0 w = w := rfl

/--
Composition of translations: applying `d₁ + d₂` equals applying `d₁` then `d₂`.

This follows from `(toMul(d₁ + d₂)).symm = (toMul d₂).symm ∘ (toMul d₁).symm`,
which holds because `mul` on `RelIso` is `g.trans f` and `symm` reverses `trans`.
-/
@[simp]
theorem TranslationGroup.apply_add
    (d₁ d₂ : TranslationGroup M₀ h_mcs₀) (w : CanonicalTimeline M₀ h_mcs₀) :
    TranslationGroup.apply (d₁ + d₂) w =
    TranslationGroup.apply d₂ (TranslationGroup.apply d₁ w) := rfl

/--
Applying the negation (inverse) of a translation reverses the action (left).
-/
@[simp]
theorem TranslationGroup.apply_neg_cancel_left
    (d : TranslationGroup M₀ h_mcs₀) (w : CanonicalTimeline M₀ h_mcs₀) :
    TranslationGroup.apply (-d) (TranslationGroup.apply d w) = w := by
  unfold TranslationGroup.apply
  have : (Additive.toMul (-d)) = (Additive.toMul d).symm := rfl
  rw [this]; simp

/--
Applying a translation then its inverse recovers the original point (right).
-/
@[simp]
theorem TranslationGroup.apply_neg_cancel_right
    (d : TranslationGroup M₀ h_mcs₀) (w : CanonicalTimeline M₀ h_mcs₀) :
    TranslationGroup.apply d (TranslationGroup.apply (-d) w) = w := by
  unfold TranslationGroup.apply
  have : (Additive.toMul (-d)) = (Additive.toMul d).symm := rfl
  rw [this]; simp

/--
Translation action is injective in the point argument:
if `d.apply w₁ = d.apply w₂` then `w₁ = w₂`.
-/
theorem TranslationGroup.apply_injective
    (d : TranslationGroup M₀ h_mcs₀) :
    Function.Injective (TranslationGroup.apply d) :=
  (Additive.toMul d).symm.injective

/--
Translation action preserves order: `w₁ ≤ w₂ → d.apply w₁ ≤ d.apply w₂`.
-/
theorem TranslationGroup.apply_monotone
    (d : TranslationGroup M₀ h_mcs₀) :
    Monotone (TranslationGroup.apply d) :=
  (Additive.toMul d).symm.monotone

/-!
## Section 3: Evaluation at Origin
-/

/--
The origin of the canonical timeline: the equivalence class of the root MCS.
-/
noncomputable def CanonicalTimeline.origin :
    CanonicalTimeline M₀ h_mcs₀ :=
  BidirectionalFragment.root.toQuotient

/--
Evaluate a translation at the origin point.
-/
noncomputable def TranslationGroup.evalAtOrigin
    (origin : CanonicalTimeline M₀ h_mcs₀)
    (d : TranslationGroup M₀ h_mcs₀) :
    CanonicalTimeline M₀ h_mcs₀ :=
  d.apply origin

/-!
## Section 4: Task Relation and TaskFrame Properties

The task relation `torsor_task_rel w d w'` holds when `d.apply w = w'`.
This is deterministic (unlike the old `fun _ _ _ => True`) and encodes
actual temporal displacement via order automorphisms.
-/

/--
The torsor-based task relation: `d` takes `w` to `w'` iff
`(Additive.toMul d).symm w = w'`.
-/
def torsor_task_rel
    (w : CanonicalTimeline M₀ h_mcs₀)
    (d : TranslationGroup M₀ h_mcs₀)
    (w' : CanonicalTimeline M₀ h_mcs₀) : Prop :=
  TranslationGroup.apply d w = w'

/--
Nullity: the zero translation maps every point to itself.
-/
theorem torsor_task_rel_nullity
    (w : CanonicalTimeline M₀ h_mcs₀) :
    torsor_task_rel w 0 w :=
  TranslationGroup.apply_zero w

/--
Compositionality: if `d₁` takes `w` to `u` and `d₂` takes `u` to `v`,
then `d₁ + d₂` takes `w` to `v`.
-/
theorem torsor_task_rel_compositionality
    (w u v : CanonicalTimeline M₀ h_mcs₀)
    (d₁ d₂ : TranslationGroup M₀ h_mcs₀)
    (h₁ : torsor_task_rel w d₁ u)
    (h₂ : torsor_task_rel u d₂ v) :
    torsor_task_rel w (d₁ + d₂) v := by
  unfold torsor_task_rel at *
  rw [TranslationGroup.apply_add, h₁, h₂]

/--
Determinism: the task relation is functional in the output.
-/
theorem torsor_task_rel_deterministic
    (w : CanonicalTimeline M₀ h_mcs₀)
    (d : TranslationGroup M₀ h_mcs₀)
    (w₁ w₂ : CanonicalTimeline M₀ h_mcs₀)
    (h₁ : torsor_task_rel w d w₁) (h₂ : torsor_task_rel w d w₂) :
    w₁ = w₂ := by
  unfold torsor_task_rel at *
  rw [← h₁, ← h₂]

/--
Reversibility: if `d` takes `w` to `w'`, then `-d` takes `w'` back to `w`.
-/
theorem torsor_task_rel_reversible
    (w w' : CanonicalTimeline M₀ h_mcs₀)
    (d : TranslationGroup M₀ h_mcs₀)
    (h : torsor_task_rel w d w') :
    torsor_task_rel w' (-d) w := by
  unfold torsor_task_rel at *
  rw [← h]
  exact TranslationGroup.apply_neg_cancel_left d w

/-!
## Summary

### Proven (sorry-free):
- `instAddGroupTranslationGroup`: D has `AddGroup` structure
- `TranslationGroup.apply_zero`: identity action
- `TranslationGroup.apply_add`: composition = sequential application
- `TranslationGroup.apply_neg_cancel_left/right`: inverse cancellation
- `TranslationGroup.apply_injective`: injectivity (from OrderIso)
- `TranslationGroup.apply_monotone`: order-preservation (from OrderIso)
- `torsor_task_rel_nullity`: TaskFrame nullity
- `torsor_task_rel_compositionality`: TaskFrame compositionality
- `torsor_task_rel_deterministic`: task relation is functional
- `torsor_task_rel_reversible`: negative duration reverses transition

### Deferred (future tasks):
- `AddCommGroup D`: Holder's theorem (freeness + ordered action ⟹ abelian)
- `LinearOrder D`: eval-at-origin injectivity (freeness/rigidity of action)
- `IsOrderedAddMonoid D`: linear order + order compatibility with addition
- `TaskFrame D`: assembly from above three + nullity/compositionality
- `AddTorsor D T`: homogeneity (transitivity: ∀ a b, ∃ d, d.apply a = b)
-/

end Bimodal.Metalogic.Bundle
