import Bimodal.Metalogic.Bundle.RestrictedFragment
import Bimodal.Semantics.TaskFrame
import Mathlib.Algebra.Order.Ring.Rat

/-!
# Temporal Domain: Product Construction RestrictedQuotient × Q

This module defines the temporal domain for the canonical model as
`RestrictedQuotient × Q` (product of MCS quotient with rationals).

## Strategy (Bulldozing)

The G-closed MCS blocker prevented proving `NoMaxOrder` on `RestrictedQuotient`
directly. The product construction sidesteps this: even if `RestrictedQuotient`
is a singleton `{[M₀]}`, the product `{[M₀]} × Q ≅ Q` has all required
order-theoretic properties inherited from Q.

Truth at `([M], q)` depends ONLY on M (the MCS quotient class), not on q.
This preserves all logical properties while providing the temporal structure.

## Key Definitions

- `TemporalDomain`: `RestrictedQuotient M₀ h_mcs₀ × Q`
- `CanonicalProductFrame`: TaskFrame with D = Q and task_rel based on rational displacement
- `CanonicalProductModel`: TaskModel with valuation depending only on MCS component
- `CanonicalProductHistory`: WorldHistory for each MCS class
- `ShiftClosedProductOmega`: Shift-closed set of histories for completeness

## References

- Task 956 plan v7: Product domain construction
- Research-025: Product domain solution
- Segerberg 1971, Blackburn et al. 2001: Standard bulldozing technique
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem
open Bimodal.Semantics

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/-!
## Section 1: The Product Domain Type
-/

/--
The temporal domain: product of the restricted quotient with rationals.

Each element is a pair `([M], q)` where:
- `[M]` is an equivalence class in RestrictedQuotient (an MCS up to preorder equivalence)
- `q` is a rational number representing the "time coordinate"

Truth at `([M], q)` will depend only on `[M]`, not on `q`.
-/
abbrev TemporalDomain (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :=
  RestrictedQuotient M₀ h_mcs₀ × ℚ

instance instNonemptyTemporalDomain :
    Nonempty (TemporalDomain M₀ h_mcs₀) :=
  ⟨⟨RestrictedFragment.root.toQuotient, 0⟩⟩

/-!
## Section 2: Canonical TaskFrame with D = Q

The task relation `canonical_task_rel w d u` holds when `u.2 - w.2 = d`,
i.e., the rational coordinates differ by exactly `d`. The MCS components
are unconstrained (any MCS pair works).
-/

/--
The canonical task relation on the product domain.
`canonical_task_rel w d u` holds when `u.2 - w.2 = d`.

This means: a task of duration `d` shifts the rational coordinate by `d`,
while the MCS component can change freely.
-/
def canonical_task_rel
    (w : TemporalDomain M₀ h_mcs₀) (d : ℚ) (u : TemporalDomain M₀ h_mcs₀) : Prop :=
  u.2 - w.2 = d

/--
Nullity: zero-duration task preserves the rational coordinate.
-/
theorem canonical_task_rel_nullity
    (w : TemporalDomain M₀ h_mcs₀) :
    canonical_task_rel w 0 w := by
  simp [canonical_task_rel]

/--
Compositionality: sequential tasks compose with additive duration.
If `u.2 - w.2 = d₁` and `v.2 - u.2 = d₂`, then `v.2 - w.2 = d₁ + d₂`.
-/
theorem canonical_task_rel_compositionality
    (w u v : TemporalDomain M₀ h_mcs₀) (d₁ d₂ : ℚ)
    (h₁ : canonical_task_rel w d₁ u)
    (h₂ : canonical_task_rel u d₂ v) :
    canonical_task_rel w (d₁ + d₂) v := by
  simp only [canonical_task_rel] at *
  rw [← h₁, ← h₂]
  simp

/--
The canonical task frame with D = Q.

- WorldState: `TemporalDomain M₀ h_mcs₀ = RestrictedQuotient × Q`
- task_rel: rational coordinate displacement
- Nullity: `q - q = 0`
- Compositionality: `(q₂ - q₁) + (q₃ - q₂) = q₃ - q₁`
-/
noncomputable def CanonicalProductFrame (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    TaskFrame ℚ where
  WorldState := TemporalDomain M₀ h_mcs₀
  task_rel := canonical_task_rel
  nullity := canonical_task_rel_nullity
  compositionality := fun w u v d₁ d₂ h₁ h₂ =>
    canonical_task_rel_compositionality w u v d₁ d₂ h₁ h₂

/-!
## Section 3: Canonical Model and Valuation

Truth at `([M], q)` depends only on M. We use `ofAntisymmetrization` to get
a representative from the quotient class.
-/

/--
Get a representative RestrictedFragment element from a quotient class.
-/
noncomputable def quotientRepresentative
    (q : RestrictedQuotient M₀ h_mcs₀) : RestrictedFragment M₀ h_mcs₀ :=
  ofAntisymmetrization (· ≤ ·) q

/--
The canonical valuation: atom `p` is true at `([M], q)` iff `p ∈ M.world`.
Truth depends only on the MCS component, not the rational coordinate.
-/
noncomputable def canonical_product_valuation
    (w : (CanonicalProductFrame M₀ h_mcs₀).WorldState)
    (p : String) : Prop :=
  Formula.atom p ∈ (quotientRepresentative w.1).world

/--
The canonical product model.
-/
noncomputable def CanonicalProductModel (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    TaskModel (CanonicalProductFrame M₀ h_mcs₀) where
  valuation := canonical_product_valuation

/-!
## Section 4: World Histories

A canonical history `τ : Q → TemporalDomain` maps each time `t` to `(m, t)`
for a fixed MCS class `m`. The rational coordinate IS the time.
-/

/--
Canonical history for a fixed MCS class: `τ(t) = (m, t)`.
The rational coordinate tracks time directly.
-/
noncomputable def CanonicalProductHistory
    (m : RestrictedQuotient M₀ h_mcs₀) :
    WorldHistory (CanonicalProductFrame M₀ h_mcs₀) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => (m, t)
  respects_task := fun s t _ _ _ => by
    show canonical_task_rel (m, s) (t - s) (m, t)
    simp [canonical_task_rel]

/--
The set of canonical product histories: one for each quotient class.
-/
noncomputable def CanonicalProductOmega (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    Set (WorldHistory (CanonicalProductFrame M₀ h_mcs₀)) :=
  { τ | ∃ m : RestrictedQuotient M₀ h_mcs₀, τ = CanonicalProductHistory m }

/--
Every canonical product history is in CanonicalProductOmega.
-/
theorem CanonicalProductHistory_mem_omega
    (m : RestrictedQuotient M₀ h_mcs₀) :
    CanonicalProductHistory m ∈ CanonicalProductOmega M₀ h_mcs₀ :=
  ⟨m, rfl⟩

/-!
## Section 5: Shift-Closed Omega

For the completeness proof, we need a shift-closed set of histories.
-/

/--
Shift-closed product Omega: all time-shifts of canonical product histories.
-/
noncomputable def ShiftClosedProductOmega (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    Set (WorldHistory (CanonicalProductFrame M₀ h_mcs₀)) :=
  { σ | ∃ (m : RestrictedQuotient M₀ h_mcs₀) (delta : ℚ),
    σ = WorldHistory.time_shift (CanonicalProductHistory m) delta }

/--
ShiftClosedProductOmega is shift-closed.
-/
theorem ShiftClosedProductOmega_is_shift_closed
    (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    ShiftClosed (ShiftClosedProductOmega M₀ h_mcs₀) := by
  intro σ h_mem Δ'
  obtain ⟨m, delta, h_eq⟩ := h_mem
  refine ⟨m, delta + Δ', ?_⟩
  subst h_eq
  simp only [WorldHistory.time_shift, CanonicalProductHistory]
  congr 1
  funext t ht
  simp only [Prod.mk.injEq]
  exact ⟨trivial, by rw [add_assoc, add_comm Δ' delta]⟩

/--
CanonicalProductOmega ⊆ ShiftClosedProductOmega (via delta = 0).
-/
theorem CanonicalProductOmega_subset_shiftClosed
    (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    CanonicalProductOmega M₀ h_mcs₀ ⊆ ShiftClosedProductOmega M₀ h_mcs₀ := by
  intro σ h_mem
  obtain ⟨m, h_eq⟩ := h_mem
  refine ⟨m, 0, ?_⟩
  subst h_eq
  simp only [WorldHistory.time_shift, CanonicalProductHistory]
  congr 1
  funext t ht
  simp only [add_zero]

end Bimodal.Metalogic.Bundle
