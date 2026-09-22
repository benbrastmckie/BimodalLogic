import Mathlib.Topology.Separation.Basic
import Mathlib.Topology.Order
import FormalSystem.Semantics.TaskFrame

/-!
# Probe: over `ℤ`, `𝒯_F = 𝒩_F` is the partition topology of `⇒_0`

Over `D = ℤ` the smallest positive cone is `(w)_1 = Fib(w, 0)`, so:

* `nbhdTopology_isOpen_iff_int` — `O` is `𝒩_F`-open iff `O` is closed under `⇒_0`;
* `coneTopology_eq_nbhdTopology_int` — `𝒯_F = 𝒩_F` when `⇒_0` is an equivalence relation
  (reflexive, symmetric, and transitive via composition) and the reflection law holds;
* `limit_int_iff` — *Limit* is exactly `⇒_0 ⊆ id`;
* `discreteTopology_nbhdTopology_int_iff` — `𝒩_F` is discrete iff `⇒_0 ⊆ id` iff *Limit*.

The paper's two-state frame of `app:dense` (free at positive durations, `⇒_0 = id`) is an
instance: both topologies are discrete there.
-/

open Topology TopologicalSpace Set

set_option warn.classDefReducibility false

namespace FormalSystem.Semantics.TaskFrame

variable {W : Type}

-- Restated verbatim from `NbhdTopology.lean`, specialised to `D = ℤ` (kept standalone).
def Limit' (R : W → ℤ → W → Prop) : Prop :=
  ∀ w u, (∀ x : ℤ, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w

def coneTopology' (R : W → ℤ → W → Prop) : TopologicalSpace W :=
  generateFrom {s | ∃ w x, 0 < x ∧ s = cone R w x}

def nbhdTopology' (R : W → ℤ → W → Prop) : TopologicalSpace W where
  IsOpen O := ∀ w ∈ O, ∃ x : ℤ, 0 < x ∧ cone R w x ⊆ O
  isOpen_univ := fun _ _ => ⟨1, one_pos, subset_univ _⟩
  isOpen_inter := fun _ _ h₁ h₂ w hw => by
    obtain ⟨x₁, hx₁, hc₁⟩ := h₁ w hw.1
    obtain ⟨x₂, hx₂, hc₂⟩ := h₂ w hw.2
    exact ⟨min x₁ x₂, lt_min hx₁ hx₂,
      subset_inter ((cone_mono R w (min_le_left _ _)).trans hc₁)
        ((cone_mono R w (min_le_right _ _)).trans hc₂)⟩
  isOpen_sUnion := fun S hS w hw => by
    obtain ⟨O, hO, hwO⟩ := mem_sUnion.mp hw
    obtain ⟨x, hx, hc⟩ := hS O hO w hwO
    exact ⟨x, hx, hc.trans (subset_sUnion_of_mem hO)⟩

theorem mem_cone_self' {R : W → ℤ → W → Prop} {w : W} (h0 : R w 0 w) {x : ℤ} (hx : 0 < x) :
    w ∈ cone R w x :=
  ⟨0, by rw [abs_zero]; exact hx, h0⟩

theorem coneTopology_le_nbhdTopology' (R : W → ℤ → W → Prop) (h0 : ∀ w, R w 0 w) :
    coneTopology' R ≤ nbhdTopology' R := by
  rw [TopologicalSpace.le_def]
  intro O hO
  have hO' : O = ⋃₀ {c | (∃ w x, 0 < x ∧ c = cone R w x) ∧ c ⊆ O} := by
    ext v
    constructor
    · intro hv
      obtain ⟨x, hx, hc⟩ := hO v hv
      exact ⟨cone R v x, ⟨⟨v, x, hx, rfl⟩, hc⟩, mem_cone_self' (h0 v) hx⟩
    · rintro ⟨c, ⟨_, hcO⟩, hvc⟩
      exact hcO hvc
  rw [hO']
  letI := coneTopology' R
  exact isOpen_sUnion fun c hc => isOpen_generateFrom_of_mem hc.1

/-! ## The radius-one cone is the zero fibre -/

/-- Over `ℤ`, `(w)_1 = Fib(w, 0)`: the only `|y| < 1` is `y = 0`. -/
theorem cone_int_one (R : W → ℤ → W → Prop) (w : W) : cone R w 1 = {u | R w 0 u} := by
  ext u
  simp only [mem_cone, Int.abs_lt_one_iff, Set.mem_setOf_eq]
  constructor
  · rintro ⟨y, rfl, h⟩; exact h
  · intro h; exact ⟨0, rfl, h⟩

/-- Over `ℤ`, `O` is `𝒩_F`-open iff it is closed under `⇒_0`. -/
theorem nbhdTopology_isOpen_iff_int (R : W → ℤ → W → Prop) {O : Set W} :
    IsOpen[nbhdTopology' R] O ↔ ∀ w ∈ O, ∀ u, R w 0 u → u ∈ O := by
  change (∀ w ∈ O, ∃ x : ℤ, 0 < x ∧ cone R w x ⊆ O) ↔ _
  constructor
  · intro h w hw u hu
    obtain ⟨x, hx, hc⟩ := h w hw
    apply hc
    apply cone_mono R w (show (1 : ℤ) ≤ x by omega)
    rw [cone_int_one]
    exact hu
  · intro h w hw
    refine ⟨1, one_pos, ?_⟩
    rw [cone_int_one]
    exact fun u hu => h w hw u hu

/-- **Over `ℤ`, `𝒯_F = 𝒩_F`** — the partition topology of `⇒_0` — provided `⇒_0` is
reflexive, symmetric, composes, and the reflection law holds. -/
theorem coneTopology_eq_nbhdTopology_int (R : W → ℤ → W → Prop)
    (h0 : ∀ w, R w 0 w) (hsymm : ∀ w u, R w 0 u → R u 0 w)
    (hcomp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → R w x u → R u y v → R w (x + y) v)
    (hrefl : ∀ w d u, R w d u → R u (-d) w) :
    coneTopology' R = nbhdTopology' R := by
  refine le_antisymm (coneTopology_le_nbhdTopology' R h0) ?_
  rw [coneTopology', le_generateFrom_iff_subset_isOpen]
  rintro s ⟨w, n, _, rfl⟩
  change IsOpen[nbhdTopology' R] _
  rw [nbhdTopology_isOpen_iff_int]
  rintro u ⟨y, hy, hR⟩ v hv
  rw [mem_Fib] at hR
  refine ⟨y, hy, ?_⟩
  rw [mem_Fib]
  rcases le_or_gt 0 y with hy0 | hy0
  · simpa using hcomp w u v y 0 hy0 le_rfl hR hv
  · have h1 : R u (-y) w := hrefl _ _ _ hR
    have h2 : R v (0 + -y) w := hcomp v u w 0 (-y) le_rfl (neg_nonneg.mpr hy0.le) (hsymm _ _ hv) h1
    simpa using hrefl _ _ _ h2

/-- Over `ℤ`, *Limit* is exactly `⇒_0 ⊆ id`. -/
theorem limit_int_iff (R : W → ℤ → W → Prop) : Limit' R ↔ ∀ w u, R w 0 u → u = w := by
  constructor
  · intro hlim w u h0u
    exact hlim w u fun x hx => ⟨0, by rw [abs_zero]; exact hx, h0u⟩
  · intro h w u hwu
    obtain ⟨y, hy, hR⟩ := hwu 1 one_pos
    rw [Int.abs_lt_one_iff] at hy
    subst hy
    exact h w u hR

/-- Over `ℤ`, `𝒩_F` is discrete iff `⇒_0 ⊆ id` iff *Limit*. -/
theorem discreteTopology_nbhdTopology_int_iff (R : W → ℤ → W → Prop) :
    @DiscreteTopology W (nbhdTopology' R) ↔ ∀ w u, R w 0 u → u = w := by
  letI := nbhdTopology' R
  rw [discreteTopology_iff_isOpen_singleton]
  simp only [nbhdTopology_isOpen_iff_int, Set.mem_singleton_iff, forall_eq]

/-! ## Axiom audit: every headline theorem uses only `propext`, `Classical.choice`, `Quot.sound` -/

#print axioms nbhdTopology_isOpen_iff_int
#print axioms coneTopology_eq_nbhdTopology_int
#print axioms limit_int_iff
#print axioms discreteTopology_nbhdTopology_int_iff

end FormalSystem.Semantics.TaskFrame
