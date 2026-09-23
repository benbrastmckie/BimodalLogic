/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import Mathlib.Topology.Separation.Basic
import Mathlib.Topology.Order
import Mathlib.Topology.Order.Basic
import Mathlib.Topology.MetricSpace.Basic

/-!
# The state topology of a task frame: `𝒩_F`, `𝒯_F`, and *Limit* as T1

A task frame's cones `(w)_x` (`def:task-relation`, *Cone* clause) carry two natural topologies on
the state space:

* `TaskFrame.coneTopology R` — the paper's `𝒯_F` (`def:task-topology`), the topology *generated*
  by the cones as a subbasis: verbatim, "the result of closing $B_\F$ under arbitrary union and
  finite intersection";
* `TaskFrame.nbhdTopology R` — `𝒩_F`, the cone-*neighbourhood* topology: `O` is open exactly when
  every `w ∈ O` has some positive cone `(w)_x ⊆ O`.

The headline result is `TaskFrame.t1Space_nbhdTopology_iff_limit`: `𝒩_F` is T1 **if and only if**
the relation satisfies *Limit*, with no other frame constraint consumed in either direction. That
is a biconditional about a *general* frame — it is the result this whole layer exists for, and it
cannot even be stated while the four constraints are fields of the frame structure, because then
no frame violates *Limit*. See `Semantics/TaskFrame.lean`'s header section "General frames and
the regular class".

## Which topology gets the instance, and why exactly one

`𝒩_F` is the `TopologicalSpace` instance on `FrameOver.WorldState` (`FrameOver.stateTopology`).
`𝒯_F` is a plain `def` (`FrameOver.coneTop`) with **no** instance, deliberately: two instances on
the same state space would make every separation goal depend on how the carrier happened to be
spelled. `𝒯_F` is finer than `𝒩_F` whenever states loop at duration zero
(`TaskFrame.coneTopology_le_nbhdTopology`), so the paper's `app:topology-t1` and `app:topology-r0`
are still available for it, as theorems taking the topology explicitly.

`𝒩_F` was chosen over `𝒯_F` for the instance because it needs no frame constraint at all to be a
topology and it is the one that characterises *Limit* exactly; `𝒯_F` is T1 under *Limit* but the
converse needs a further hypothesis (`TaskFrame.limit_of_t1Space_coneTopology`), and the
four-state funnel of `Semantics/StateTopology/Counterexamples.lean` is the witness that the gap
is real.

## Import weight: this module is a leaf

`Semantics.lean` deliberately does **not** import this module, and neither does anything else
under `FormalSystem/` — the generated library root reaches it directly. `Mathlib.Topology.*`
brings order and completeness instances with it, and routing them through the `Semantics`
aggregator would put them in scope for every downstream module, which is exactly the import-weight
failure `Semantics.lean` already records for `TimeIndexedSharpness`. Import this module by name
where its results are wanted. For the same reason, history continuity below takes the order
topology on the duration carrier as an explicit **binder**, never a global instance: a global one
would collide at `intOrder`, `ℚ` and `ℝ`.

## Main definitions

- `TaskFrame.coneTopology` — `𝒯_F`, the cone subbasis topology (`def:task-topology`)
- `TaskFrame.nbhdTopology` — `𝒩_F`, the cone neighbourhood topology
- `TaskFrame.coneFilter` — the filter of sets containing a positive cone at a state
- `TaskFrame.IsHistory` — a total history over a bare relation (`def:world-history` at `X = D`)
- `TaskFrame.Triangle` — the mixed-sign shortcut condition under which `𝒯_F = 𝒩_F`
- `TaskFrame.QuickFwd`, `TaskFrame.NoOneWay` — instantaneous reachability and its symmetry
- `FrameOver.stateTopology` — `𝒩_F` as the state space's `TopologicalSpace` instance
- `FrameOver.coneTop` — `𝒯_F` at a frame, a plain `def` with no instance

## Main results

- `TaskFrame.t1Space_nbhdTopology_iff_limit` — `𝒩_F` is T1 iff *Limit*
- `FrameOver.t1Space_iff_limit` — the same, at a general frame
- `FrameOver.instT1SpaceOfRegular` — a regular frame's state space is T1 (hence R0, free from
  Mathlib's `T1Space → R0Space`)
- `TaskFrame.t1Space_coneTopology_of_limit`, `TaskFrame.r0Space_coneTopology_of_limit` —
  `app:topology-t1` and `app:topology-r0` for `𝒯_F`
- `TaskFrame.limit_of_t1Space_coneTopology` — the converse of `app:topology-t1`, under *NoOneWay*
- `TaskFrame.continuous_nbhdTopology_of_history` — every history is `𝒩_F`-continuous,
  unconditionally
- `TaskFrame.nbhdTopology_eq_real` — a frame over `ℝ` whose cones are Euclidean balls has the
  usual topology, the bridge lemma that keeps a real carrier's two topologies from being confused

## References

- JPL paper `def:task-topology`, `app:topology-t1`, `app:topology-r0`
-/

-- `nbhdTopology`, `coneTopology` and `FrameOver.coneTop` are `def`s whose result type is the
-- class `TopologicalSpace`, which `warn.classDefReducibility` reports. Silenced at module scope
-- rather than by tagging them `@[instance_reducible]`: making the topology instance-reducible
-- changes how eagerly unification unfolds it, which would interact badly with the real-carrier
-- keying hazard the bridge lemmas at the end of this module exist to manage.
set_option warn.classDefReducibility false

open Topology TopologicalSpace Set Filter

namespace FormalSystem.Semantics.TaskFrame

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
variable {W : Type}

omit [Nontrivial D] in
/-- With `R w 0 w`, every positive cone at `w` contains `w` — the `⊇` half of the paper's
*Limit* equation, which `TaskFrame.Limit` does not transcribe because it is `lem:nullity`. -/
theorem mem_cone_self {R : W → D → W → Prop} {w : W} (h0 : R w 0 w) {x : D} (hx : 0 < x) :
    w ∈ cone R w x :=
  ⟨0, by rw [abs_zero]; exact hx, h0⟩

/-! ## The two topologies -/

/--
`𝒯_F` (`def:task-topology`): the topology generated by the positive cones as a **subbasis**.

Recorded source (`def:task-topology`, verbatim): "the result of closing $B_\F$ under arbitrary
union and finite intersection".

A plain `def`, never an instance — see this module's header, "Which topology gets the instance".
-/
def coneTopology (R : W → D → W → Prop) : TopologicalSpace W :=
  generateFrom {s | ∃ w x, 0 < x ∧ s = cone R w x}

/--
`𝒩_F`: the cone **neighbourhood** topology. `O` is open exactly when every `w ∈ O` has some
positive cone `(w)_x ⊆ O`.

This is a topology with no frame constraint assumed — only `[Nontrivial D]`, so that a positive
radius exists at all (`TaskFrame.exists_pos_of_nontrivial`). It is the one that characterises
*Limit* exactly (`t1Space_nbhdTopology_iff_limit`), and the one `FrameOver.stateTopology`
installs as the state space's instance.
-/
def nbhdTopology (R : W → D → W → Prop) : TopologicalSpace W where
  IsOpen O := ∀ w ∈ O, ∃ x, 0 < x ∧ cone R w x ⊆ O
  isOpen_univ := fun _ _ =>
    let ⟨x, hx⟩ := exists_pos_of_nontrivial (D := D); ⟨x, hx, subset_univ _⟩
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

/-- Unfolding lemma for `𝒩_F`-openness, stated so that no consumer unfolds the structure
instance directly. -/
theorem nbhdTopology_isOpen_iff (R : W → D → W → Prop) {O : Set W} :
    IsOpen[nbhdTopology R] O ↔ ∀ w ∈ O, ∃ x, 0 < x ∧ cone R w x ⊆ O :=
  Iff.rfl

/-- The closed sets of `𝒩_F` are exactly the sets closed under arbitrarily short tasks: if `w`
reaches `C` within every positive radius, then `w ∈ C`. -/
theorem nbhdTopology_isClosed_iff (R : W → D → W → Prop) (C : Set W) :
    IsClosed[nbhdTopology R] C ↔
      ∀ w, (∀ x, 0 < x → (cone R w x ∩ C).Nonempty) → w ∈ C := by
  letI := nbhdTopology R
  rw [← isOpen_compl_iff, nbhdTopology_isOpen_iff]
  constructor
  · intro h w hw
    by_contra hwC
    obtain ⟨x, hx, hc⟩ := h w hwC
    obtain ⟨u, hu, huC⟩ := hw x hx
    exact hc hu huC
  · intro h w hw
    by_contra hne
    push Not at hne
    apply hw
    apply h
    intro x hx
    obtain ⟨u, hu, huC⟩ := Set.not_subset.mp (hne x hx)
    exact ⟨u, hu, by simpa using huC⟩

/-- **`𝒩_F` is discrete iff every state has a dwell time**: some `x > 0` with `(w)_x ⊆ {w}`
(equality follows under `R w 0 w`). A *uniform* dwell time over a dense Archimedean order forces
the static frame (`Semantics/Correspondence/Rigidity.lean`); the pointwise condition here does
not. -/
theorem discreteTopology_nbhdTopology_iff (R : W → D → W → Prop) :
    @DiscreteTopology W (nbhdTopology R) ↔ ∀ w, ∃ x, 0 < x ∧ cone R w x ⊆ {w} := by
  letI := nbhdTopology R
  rw [discreteTopology_iff_isOpen_singleton]
  simp only [nbhdTopology_isOpen_iff, Set.mem_singleton_iff, forall_eq]

/-! ## *Limit* is exactly T1 for `𝒩_F` -/

/--
**`𝒩_F` is T1 if and only if the relation satisfies *Limit*.**

No other frame constraint is consumed in either direction; `[Nontrivial D]` is used only so that
`𝒩_F` is a topology at all. This is the biconditional the general-frame refactor exists to make
statable: `Limit` is a hypothesis *about* the relation, not a field of a structure, so both
directions are about frames that may or may not satisfy it.
-/
theorem t1Space_nbhdTopology_iff_limit (R : W → D → W → Prop) :
    @T1Space W (nbhdTopology R) ↔ Limit R := by
  letI := nbhdTopology R
  constructor
  · intro h w u hwu
    haveI := h
    by_contra hne
    have hopen : IsOpen ({u}ᶜ : Set W) := isOpen_compl_singleton
    obtain ⟨x, hx, hc⟩ := hopen w (fun h => hne (Set.mem_singleton_iff.mp h).symm)
    exact hc (hwu x hx) rfl
  · intro hlim
    refine ⟨fun u => ?_⟩
    rw [← isOpen_compl_iff]
    intro w hw
    have hnot : ¬ ∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u :=
      fun hh => hw (Set.mem_singleton_iff.mpr (hlim w u hh).symm)
    push Not at hnot
    obtain ⟨x, hx, hnx⟩ := hnot
    refine ⟨x, hx, fun v hv hvu => ?_⟩
    obtain ⟨y, hy, hR⟩ := hv
    rw [Set.mem_singleton_iff] at hvu
    subst hvu
    exact hnx y hy hR

/-- **`𝒯_F` is finer than `𝒩_F`** (in Mathlib's order, `coneTopology R ≤ nbhdTopology R`), given
only that every state loops at duration zero: an `𝒩_F`-open set is the union of the cones it
contains. The two topologies are therefore comparable, not incomparable. -/
theorem coneTopology_le_nbhdTopology (R : W → D → W → Prop) (h0 : ∀ w, R w 0 w) :
    coneTopology R ≤ nbhdTopology R := by
  rw [TopologicalSpace.le_def]
  intro O hO
  have hO' : O = ⋃₀ {c | (∃ w x, 0 < x ∧ c = cone R w x) ∧ c ⊆ O} := by
    ext v
    constructor
    · intro hv
      obtain ⟨x, hx, hc⟩ := hO v hv
      exact ⟨cone R v x, ⟨⟨v, x, hx, rfl⟩, hc⟩, mem_cone_self (h0 v) hx⟩
    · rintro ⟨c, ⟨_, hcO⟩, hvc⟩
      exact hcO hvc
  rw [hO']
  letI := coneTopology R
  exact isOpen_sUnion fun c hc => isOpen_generateFrom_of_mem hc.1

/-- **`app:topology-t1`**: `𝒯_F` is T1, from *Limit* and `R w 0 w`. The paper's own proof also
consumes the reflection convention; this route does not, since T1 is inherited by finer topologies
and `𝒩_F` is already T1 under *Limit*. -/
theorem t1Space_coneTopology_of_limit (R : W → D → W → Prop) (h0 : ∀ w, R w 0 w)
    (hlim : Limit R) : @T1Space W (coneTopology R) :=
  t1Space_antitone (coneTopology_le_nbhdTopology R h0)
    ((t1Space_nbhdTopology_iff_limit R).mpr hlim)

/-- `𝒩_F` is R0 under *Limit*, since T1 implies R0. -/
theorem r0Space_nbhdTopology_of_limit (R : W → D → W → Prop) (hlim : Limit R) :
    @R0Space W (nbhdTopology R) := by
  letI := nbhdTopology R
  haveI := (t1Space_nbhdTopology_iff_limit R).mpr hlim
  infer_instance

/-- **`app:topology-r0`**: `𝒯_F` is R0 under *Limit* and `R w 0 w`. -/
theorem r0Space_coneTopology_of_limit (R : W → D → W → Prop) (h0 : ∀ w, R w 0 w)
    (hlim : Limit R) : @R0Space W (coneTopology R) := by
  letI := coneTopology R
  haveI := t1Space_coneTopology_of_limit R h0 hlim
  infer_instance

/-- The paper's **equality** form of *Limit*, `⋂_{x>0} (w)_x = {w}`, is `𝒩_F` T1 together with
the `⊇` half `w ∈ (w)_x`; the `⊇` half follows from `R w 0 w` (`lem:nullity`). This is why
`TaskFrame.Limit` transcribes only the `⊆` inclusion. -/
theorem limit_eq_iff (R : W → D → W → Prop) :
    (∀ w, ⋂ x > (0 : D), cone R w x = {w}) ↔
      (@T1Space W (nbhdTopology R) ∧ ∀ w x, 0 < x → w ∈ cone R w x) := by
  rw [t1Space_nbhdTopology_iff_limit]
  constructor
  · intro h
    refine ⟨fun w u hu => ?_, fun w x hx => ?_⟩
    · have : u ∈ ⋂ x > (0 : D), cone R w x := by
        simp only [Set.mem_iInter]; exact fun x hx => hu x hx
      rw [h w] at this
      exact this
    · have : w ∈ ⋂ x > (0 : D), cone R w x := by rw [h w]; rfl
      simp only [Set.mem_iInter] at this
      exact this x hx
  · rintro ⟨hlim, hself⟩ w
    ext u
    simp only [Set.mem_iInter, Set.mem_singleton_iff]
    constructor
    · intro hu; exact hlim w u fun x hx => hu x hx
    · rintro rfl; exact fun x hx => hself u x hx

/-- **`app:topology-t1` exactly as the revised appendix states it**: the paper's EQUALITY form of
*Limit*, `⋂_{x>0} (w)_x = {w}`, holds if and only if `𝒩_F` is T1 — under *Seriality* alone.

`t1Space_nbhdTopology_iff_limit` is the sharper statement: it consumes **no** frame constraint at
all, not even *Seriality*. It is about the `⊆` half of *Limit*, which is what `TaskFrame.Limit`
transcribes. *Seriality* is what upgrades that half to the paper's equality, by way of
`lem:nullity` (`TaskFrame.nullity_of_serial_limit`). A manuscript that prefers to state the
equality form can cite this; one willing to state the `⊆` form gets a stronger theorem for free.

Paper: `app:topology-t1`
-/
theorem t1Space_nbhdTopology_iff_iInter_cone_of_serial (R : W → D → W → Prop) (hs : Serial R) :
    (∀ w, ⋂ x > (0 : D), cone R w x = {w}) ↔ @T1Space W (nbhdTopology R) := by
  rw [limit_eq_iff]
  constructor
  · exact fun h => h.1
  · intro h
    refine ⟨h, fun w x hx => ?_⟩
    exact mem_cone_self (nullity_of_serial_limit hs ((t1Space_nbhdTopology_iff_limit R).mp h) w) hx

/-! ## What `𝒩_F` is: a neighbourhood system, with the cones as a filter base -/

/-- The cone filter at `w`: the sets containing some positive cone at `w`. -/
def coneFilter (R : W → D → W → Prop) (w : W) : Filter W :=
  ⨅ x ∈ {x : D | 0 < x}, 𝓟 (cone R w x)

/-- The cones at `w` form a filter base: they are nested in the radius (`cone_mono`). -/
theorem isBasis_cone (R : W → D → W → Prop) (w : W) :
    Filter.IsBasis (fun x : D => 0 < x) (fun x => cone R w x) :=
  ⟨exists_pos_of_nontrivial, fun {x₁ x₂} hx₁ hx₂ =>
    ⟨min x₁ x₂, lt_min hx₁ hx₂,
      subset_inter (cone_mono R w (min_le_left _ _)) (cone_mono R w (min_le_right _ _))⟩⟩

/-- Membership in the cone filter, unfolded. -/
theorem mem_coneFilter (R : W → D → W → Prop) (w : W) {s : Set W} :
    s ∈ coneFilter R w ↔ ∃ x, 0 < x ∧ cone R w x ⊆ s := by
  unfold coneFilter
  rw [Filter.mem_biInf_of_directed]
  · simp only [Set.mem_setOf_eq, Filter.mem_principal]
  · rintro x hx y hy
    exact ⟨min x y, lt_min hx hy, principal_mono.mpr (cone_mono R w (min_le_left _ _)),
      principal_mono.mpr (cone_mono R w (min_le_right _ _))⟩
  · exact let ⟨x, hx⟩ := exists_pos_of_nontrivial (D := D); ⟨x, hx⟩

/-- `𝒩_F` is `TopologicalSpace.mkOfNhds` of the cone filters. -/
theorem nbhdTopology_eq_mkOfNhds (R : W → D → W → Prop) :
    nbhdTopology R = TopologicalSpace.mkOfNhds (coneFilter R) := by
  apply TopologicalSpace.ext
  funext O
  apply propext
  rw [nbhdTopology_isOpen_iff]
  change _ ↔ ∀ w ∈ O, O ∈ coneFilter R w
  simp only [mem_coneFilter]

/-- In `𝒩_F` every neighbourhood of `w` contains a cone at `w`. -/
theorem coneFilter_le_nhds (R : W → D → W → Prop) (w : W) :
    coneFilter R w ≤ @nhds W (nbhdTopology R) w := by
  letI := nbhdTopology R
  rw [le_nhds_iff]
  intro s hws hs
  rw [mem_coneFilter]
  exact hs w hws

/-- `𝒩_F` is the **finest** topology in which every neighbourhood of `w` contains a cone at `w`.
Not "the finest in which the cones are neighbourhoods" — that would be the discrete topology, and
the cones need not be `𝒩_F`-neighbourhoods at all (the four-state funnel is the witness). -/
theorem nbhdTopology_le_of_coneFilter_le_nhds (R : W → D → W → Prop) (t : TopologicalSpace W)
    (h : ∀ w, coneFilter R w ≤ @nhds W t w) : nbhdTopology R ≤ t := by
  rw [TopologicalSpace.le_def]
  intro O hO w hw
  letI := t
  have := (h w) (hO.mem_nhds hw)
  rwa [mem_coneFilter] at this

/-! ## Histories are `𝒩_F`-continuous

The order topology on the duration carrier is an explicit **binder** in this section, never a
global instance: a global one would collide with Mathlib's own at `ℚ` and `ℝ` and with the
`intOrder` carrier, which is exactly the diamond this module is a leaf to avoid. -/

/-- A total history over a bare relation: `def:world-history` with `X = D`. -/
def IsHistory (R : W → D → W → Prop) (τ : D → W) : Prop :=
  ∀ x y, R (τ x) (y - x) (τ y)

/-- **Every history is continuous** from the order topology on `D` to `𝒩_F` — unconditionally,
with no frame constraint consumed. -/
theorem continuous_nbhdTopology_of_history [TopologicalSpace D] [OrderTopology D]
    (R : W → D → W → Prop) {τ : D → W} (hτ : IsHistory R τ) :
    @Continuous D W _ (nbhdTopology R) τ := by
  letI := nbhdTopology R
  rw [continuous_def]
  intro O hO
  rw [isOpen_iff_forall_mem_open]
  intro z hz
  obtain ⟨x, hx, hc⟩ := hO (τ z) hz
  refine ⟨Set.Ioo (z - x) (z + x), fun y hy => hc ⟨y - z, ?_, hτ z y⟩, isOpen_Ioo,
    sub_lt_self z hx, lt_add_of_pos_right z hx⟩
  exact abs_sub_lt_iff.mpr ⟨sub_lt_iff_lt_add'.mpr hy.2, sub_lt_comm.mp hy.1⟩

/-- **`𝒩_F` is contained in the final topology** of all histories (order topology on `D`): the
final topology is finer, i.e. `⨆ coinduced ≤ nbhdTopology`. -/
theorem finalTopology_le_nbhdTopology [TopologicalSpace D] [OrderTopology D]
    (R : W → D → W → Prop) :
    (⨆ τ : {τ : D → W // IsHistory R τ}, coinduced τ.1 ‹TopologicalSpace D›) ≤
      nbhdTopology R :=
  iSup_le fun τ => continuous_iff_coinduced_le.mp (continuous_nbhdTopology_of_history R τ.2)

/-! ## When are the cones `𝒩_F`-open? The triangle (mixed-sign) condition -/

/-- A triangle condition: any two-step path can be shortcut by a single task no longer than the
sum of the two. Same-sign composition gives it with `t = y + z`; what it adds is the mixed-sign
case, which `def:frame`'s *Compositionality* leaves inexpressible at the primitive level.
Deterministic (group-action) frames and the metric frames satisfy it. -/
def Triangle (R : W → D → W → Prop) : Prop :=
  ∀ w u v y z, R w y u → R u z v → ∃ t, |t| ≤ |y| + |z| ∧ R w t v

/-- Under the triangle condition every cone is `𝒩_F`-open. -/
theorem isOpen_cone_of_triangle {R : W → D → W → Prop} (hT : Triangle R) (w : W) (x : D) :
    IsOpen[nbhdTopology R] (cone R w x) := by
  rintro u ⟨y, hy, hR⟩
  refine ⟨x - |y|, sub_pos.mpr hy, ?_⟩
  rintro v ⟨z, hz, hR'⟩
  obtain ⟨t, ht, hRt⟩ := hT w u v y z hR hR'
  exact ⟨t, lt_of_le_of_lt ht (lt_sub_iff_add_lt'.mp hz), hRt⟩

/-- Under the triangle condition and `R w 0 w`, the two topologies coincide: `𝒯_F = 𝒩_F`. -/
theorem coneTopology_eq_nbhdTopology_of_triangle {R : W → D → W → Prop} (h0 : ∀ w, R w 0 w)
    (hT : Triangle R) : coneTopology R = nbhdTopology R := by
  refine le_antisymm (coneTopology_le_nbhdTopology R h0) ?_
  rw [coneTopology, le_generateFrom_iff_subset_isOpen]
  rintro s ⟨w, x, _, rfl⟩
  exact isOpen_cone_of_triangle hT w x

/-- With `R w 0 w`, the two topologies coincide exactly when the cones are `𝒩_F`-open. -/
theorem coneTopology_eq_nbhdTopology_iff {R : W → D → W → Prop} (h0 : ∀ w, R w 0 w) :
    coneTopology R = nbhdTopology R ↔
      ∀ w x, 0 < x → IsOpen[nbhdTopology R] (cone R w x) := by
  constructor
  · intro h w x hx
    rw [← h]
    exact isOpen_generateFrom_of_mem ⟨w, x, hx, rfl⟩
  · intro h
    refine le_antisymm (coneTopology_le_nbhdTopology R h0) ?_
    rw [coneTopology, le_generateFrom_iff_subset_isOpen]
    rintro s ⟨w, x, hx, rfl⟩
    exact h w x hx

/-! ## The converse of `app:topology-t1`, under "no one-way instantaneous pairs" -/

/-- `u` is forward-instantaneously reachable from `w`: `w ⇒_y u` for arbitrarily small `y ≥ 0`. -/
def QuickFwd (R : W → D → W → Prop) (w u : W) : Prop :=
  ∀ x, 0 < x → ∃ y, 0 ≤ y ∧ y < x ∧ R w y u

/-- No one-way instantaneous pairs: forward-instantaneous reachability is symmetric. -/
def NoOneWay (R : W → D → W → Prop) : Prop :=
  ∀ w u, QuickFwd R w u → QuickFwd R u w

omit [Nontrivial D] in
/-- **The gap between `𝒯_F`-T1 and *Limit* is exactly the one-way instantaneous pairs**: given
the reflection convention, the composition half of *Compositionality*, and *NoOneWay*, `𝒯_F`
being T1 implies *Limit*. Contrapositively, every frame with `𝒯_F` T1 and *Limit* failing
contains a one-way instantaneous pair — as the four-state funnel does. -/
theorem limit_of_t1Space_coneTopology {R : W → D → W → Prop}
    (hrefl : ∀ w d u, R w d u → R u (-d) w)
    (hcomp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → R w x u → R u y v → R w (x + y) v)
    (hno : NoOneWay R) (hT1 : @T1Space W (coneTopology R)) : Limit R := by
  intro w u hwu
  -- Step 1: `w` and `u` are forward-instantaneous in at least one direction, hence in both.
  have hq : QuickFwd R w u ∨ QuickFwd R u w := by
    by_contra h
    rw [not_or] at h
    obtain ⟨h1, h2⟩ := h
    unfold QuickFwd at h1 h2
    push Not at h1 h2
    obtain ⟨x₀, hx₀, h1⟩ := h1
    obtain ⟨x₁, hx₁, h2⟩ := h2
    obtain ⟨y, hy, hR⟩ := hwu (min x₀ x₁) (lt_min hx₀ hx₁)
    rcases le_or_gt 0 y with hy0 | hy0
    · rw [abs_of_nonneg hy0] at hy
      exact h1 y hy0 (lt_of_lt_of_le hy (min_le_left _ _)) hR
    · rw [abs_of_neg hy0] at hy
      exact h2 (-y) (neg_nonneg.mpr hy0.le) (lt_of_lt_of_le hy (min_le_right _ _))
        (hrefl _ _ _ hR)
  have hq2 : QuickFwd R w u ∧ QuickFwd R u w := by
    rcases hq with h | h
    · exact ⟨h, hno w u h⟩
    · exact ⟨hno u w h, h⟩
  -- Step 2: every cone containing `w` contains `u`.
  have key : ∀ v x, 0 < x → w ∈ cone R v x → u ∈ cone R v x := by
    rintro v x hx ⟨y, hy, hR⟩
    rcases le_or_gt 0 y with hy0 | hy0
    · rw [abs_of_nonneg hy0] at hy
      obtain ⟨y', hy'0, hy', hR'⟩ := hq2.1 (x - y) (sub_pos.mpr hy)
      refine ⟨y + y', ?_, hcomp _ _ _ _ _ hy0 hy'0 hR hR'⟩
      rw [abs_of_nonneg (add_nonneg hy0 hy'0)]
      exact lt_sub_iff_add_lt'.mp hy'
    · have hR1 : R w (-y) v := hrefl _ _ _ hR
      have hxy : 0 < x + y := by
        have := (abs_lt.mp hy).1
        rw [neg_lt] at this
        exact neg_lt_iff_pos_add.mp this
      obtain ⟨y', hy'0, hy', hR'⟩ := hq2.2 (x + y) hxy
      have hc := hcomp _ _ _ _ _ hy'0 (neg_nonneg.mpr hy0.le) hR' hR1
      refine ⟨-(y' + -y), ?_, hrefl _ _ _ hc⟩
      rw [abs_neg, abs_of_nonneg (add_nonneg hy'0 (neg_nonneg.mpr hy0.le)), ← sub_eq_add_neg]
      exact sub_lt_iff_lt_add.mpr hy'
  -- Step 3: every `𝒯_F`-open set containing `w` contains `u`.
  have hgen : ∀ O, GenerateOpen {s | ∃ v x, 0 < x ∧ s = cone R v x} O → w ∈ O → u ∈ O := by
    intro O hO
    induction hO with
    | basic s hs => obtain ⟨v, x, hx, rfl⟩ := hs; exact key v x hx
    | univ => intro; trivial
    | inter s t _ _ ihs iht => intro h; exact ⟨ihs h.1, iht h.2⟩
    | sUnion S _ ih => rintro ⟨s, hs, hws⟩; exact ⟨s, hs, ih s hs hws⟩
  -- Step 4: T1 for `𝒯_F` makes `{u}ᶜ` open, and it contains `w` unless `u = w`.
  by_contra hne
  letI := coneTopology R
  haveI := hT1
  have hopen : IsOpen ({u}ᶜ : Set W) := isOpen_compl_singleton
  exact hgen _ hopen (fun h => hne (Set.mem_singleton_iff.mp h).symm) rfl

/-! ## The real-carrier bridge

At a frame whose state type is `ℝ`, Mathlib's own `TopologicalSpace ℝ` and this module's
`FrameOver.stateTopology` both exist, and which one a goal picks up depends on how the carrier is
spelled. These lemmas are the bridge that keeps the two from being confused: when the cones are
Euclidean balls the two topologies are propositionally **equal**, so the ambiguity is harmless as
long as it is discharged explicitly. Never spell a frame carrier as the bare Mathlib type inside
a topological statement; go through these. -/

/-- If every positive cone of a relation on `ℝ` is a Euclidean ball of radius `c · x`, then `𝒩_F`
**is** the usual topology on `ℝ`. -/
theorem nbhdTopology_eq_real (R : ℝ → ℝ → ℝ → Prop) {c : ℝ} (hc : 0 < c)
    (hcone : ∀ r x, 0 < x → cone R r x = Metric.ball r (c * x)) :
    nbhdTopology R = (inferInstance : TopologicalSpace ℝ) := by
  apply TopologicalSpace.ext
  funext O
  apply propext
  rw [Metric.isOpen_iff]
  change (∀ w ∈ O, ∃ x : ℝ, 0 < x ∧ cone R w x ⊆ O) ↔ _
  constructor
  · intro h r hr
    obtain ⟨x, hx, hs⟩ := h r hr
    exact ⟨c * x, mul_pos hc hx, by rw [← hcone r x hx]; exact hs⟩
  · intro h r hr
    obtain ⟨ε, hε, hb⟩ := h r hr
    have hε' : 0 < ε / c := div_pos hε hc
    refine ⟨ε / c, hε', ?_⟩
    rw [hcone r _ hε', mul_div_cancel₀ ε hc.ne']
    exact hb

/-- If every positive cone is a Euclidean ball and every state loops at zero, then `𝒯_F = 𝒩_F` on
a real carrier: the cones are themselves open. -/
theorem coneTopology_eq_nbhdTopology_real (R : ℝ → ℝ → ℝ → Prop) (h0 : ∀ r, R r 0 r) {c : ℝ}
    (hc : 0 < c) (hcone : ∀ r x, 0 < x → cone R r x = Metric.ball r (c * x)) :
    coneTopology R = nbhdTopology R := by
  refine le_antisymm (coneTopology_le_nbhdTopology R h0) ?_
  rw [coneTopology, le_generateFrom_iff_subset_isOpen]
  rintro s ⟨w, x, hx, rfl⟩
  rw [nbhdTopology_eq_real R hc hcone, hcone w x hx]
  exact (Metric.isOpen_ball : IsOpen (Metric.ball w (c * x)))

/-- The usual topology on `ℝ` is not discrete: `{0}` is not open. Used to say that a real-carrier
frame's state topology, although T1, has no dwell time. -/
theorem not_discreteTopology_real : ¬ DiscreteTopology ℝ := by
  intro h
  have h0 := (discreteTopology_iff_isOpen_singleton.mp h) 0
  rw [Metric.isOpen_iff] at h0
  obtain ⟨ε, hε, hb⟩ := h0 0 rfl
  have hmem : ε / 2 ∈ Metric.ball (0 : ℝ) ε := by
    rw [Metric.mem_ball, Real.dist_eq, sub_zero, abs_of_pos (by linarith)]
    linarith
  have := hb hmem
  rw [Set.mem_singleton_iff] at this
  linarith

end FormalSystem.Semantics.TaskFrame

namespace FormalSystem.Semantics

namespace FrameOver

variable {D : TemporalOrder}

/--
**The state topology of a task frame**: `𝒩_F`, the cone-neighbourhood topology, as the
`TopologicalSpace` instance on a **general** frame's state space.

The instance is on the general frame, not on the regular class, because `𝒩_F` needs no frame
constraint to be a topology — that is precisely what makes `t1Space_iff_limit` a biconditional
about an arbitrary frame rather than a theorem about frames that satisfy *Limit* by construction.

This is the **only** `TopologicalSpace` instance on a state space in this development. `coneTop`
(`𝒯_F`) is a plain `def`; see this module's header.
-/
instance stateTopology (F : FrameOver D) : TopologicalSpace F.WorldState :=
  TaskFrame.nbhdTopology F.TaskRel

/-- **The replacement `def:task-topology`, at a frame**: a set is open exactly when it contains a
positive cone around each of its members.

Stated so that no consumer has to unfold `stateTopology`. This one clause is what the revised
definition replaces the paper's Basic Opens + closure pair with; `TaskFrame.nbhdTopology_isOpen_iff`
is the same fact over a bare relation.

Paper: `def:task-topology`
-/
theorem isOpen_iff (F : FrameOver D) {O : Set F.WorldState} :
    IsOpen O ↔ ∀ w ∈ O, ∃ x, 0 < x ∧ TaskFrame.cone F.TaskRel w x ⊆ O :=
  Iff.rfl

/--
**`𝒩_F` is T1 exactly when the frame satisfies *Limit*** — at a general frame.

This is the result the general/regular split exists for. While the four constraints were fields
of `FrameOver`, the right-hand side was true of every frame by construction and the biconditional
had no content; as a constraint on a general frame it is a genuine characterisation, and the
four-state funnel (`Semantics/StateTopology/Counterexamples.lean`) is a frame at which the
left-hand side of the `𝒯_F` analogue holds while the right-hand side fails.

The paper states the `𝒯_F` direction; this is the `𝒩_F` biconditional.

Paper: `app:topology-t1`
-/
theorem t1Space_iff_limit (F : FrameOver D) :
    T1Space F.WorldState ↔ TaskFrame.Limit F.TaskRel :=
  TaskFrame.t1Space_nbhdTopology_iff_limit F.TaskRel

/--
**A regular frame's state space is T1**, by `t1Space_iff_limit` at the class's *Limit* field.

`R0Space` follows free from Mathlib's `T1Space → R0Space` instance; `r0Space_stateTopology`
below states it under its own name, so that `app:topology-r0` has a declaration a citation can
reach rather than only an inferred instance.
-/
instance instT1SpaceOfRegular (F : FrameOver D) [F.IsRegular] : T1Space F.WorldState :=
  (t1Space_iff_limit F).mpr F.limit

/-- **`app:topology-r0` for the state topology**, named.

Under the revised `def:task-topology` the label is about `𝒩_F`, so a citation needs a
declaration about `𝒩_F` — `r0Space_coneTop` below covers the superseded subbasis topology
instead. The proof is Mathlib's `T1Space → R0Space`, routed through
`TaskFrame.r0Space_nbhdTopology_of_limit`; this declaration is also what pins the "free from T1"
claim in `instT1SpaceOfRegular`'s docstring, replacing the anonymous `example` that used to do so,
which no citation could name.

Paper: `app:topology-r0`
-/
theorem r0Space_stateTopology (F : FrameOver D) [F.IsRegular] :
    R0Space F.WorldState :=
  TaskFrame.r0Space_nbhdTopology_of_limit F.TaskRel F.limit

/-- **The paper's equality form of *Limit* at a regular frame**: `⋂_{x>0} (w)_x = {w}`.

`FrameOver.IsRegular` carries *Limit* in the `⊆` form that `TaskFrame.Limit` transcribes; the
`⊇` half is `lem:nullity`, available at a regular frame as `F.nullity`. The two together are the
equation as `def:frame#Limit` displays it.

Paper: `def:frame#Limit`
-/
theorem iInter_cone_eq_singleton (F : FrameOver D) [F.IsRegular] (w : F.WorldState) :
    ⋂ x > (0 : (↑D : Type)), TaskFrame.cone F.TaskRel w x = {w} :=
  (TaskFrame.limit_eq_iff F.TaskRel).mpr
    ⟨(t1Space_iff_limit F).mpr F.limit,
      fun w _x hx => TaskFrame.mem_cone_self (F.nullity w) hx⟩ w

/--
**`𝒯_F` at a frame** (`def:task-topology`): the topology generated by the cones as a subbasis.

A plain `def`, with **no** instance, so that a state space carries exactly one `TopologicalSpace`.
Two instances would make every separation goal depend on how the carrier was spelled, and `𝒯_F`
is the one whose relationship to *Limit* is not a biconditional
(`TaskFrame.limit_of_t1Space_coneTopology` needs *NoOneWay* on top of T1). Use it explicitly,
as `@T1Space F.WorldState F.coneTop` and the like.
-/
def coneTop (F : FrameOver D) : TopologicalSpace F.WorldState :=
  TaskFrame.coneTopology F.TaskRel

/-- `𝒯_F` is finer than the state topology at any frame whose states loop at duration zero —
in particular at any regular frame, by `lem:nullity`. -/
theorem coneTop_le_stateTopology (F : FrameOver D) [F.IsRegular] :
    F.coneTop ≤ stateTopology F :=
  TaskFrame.coneTopology_le_nbhdTopology F.TaskRel F.nullity

/-- **`app:topology-t1`** at a regular frame: `𝒯_F` is T1. -/
theorem t1Space_coneTop (F : FrameOver D) [F.IsRegular] :
    @T1Space F.WorldState F.coneTop :=
  TaskFrame.t1Space_coneTopology_of_limit F.TaskRel F.nullity F.limit

/-- **`app:topology-r0`** at a regular frame: `𝒯_F` is R0. -/
theorem r0Space_coneTop (F : FrameOver D) [F.IsRegular] :
    @R0Space F.WorldState F.coneTop :=
  TaskFrame.r0Space_coneTopology_of_limit F.TaskRel F.nullity F.limit

/-- **Every world history is continuous** into the state topology, from the order topology on the
duration carrier. The order topology is an explicit binder, never a global instance. -/
theorem continuous_of_history (F : FrameOver D) [TopologicalSpace (↑D : Type)]
    [OrderTopology (↑D : Type)] {τ : (↑D : Type) → F.WorldState}
    (hτ : TaskFrame.IsHistory F.TaskRel τ) : Continuous τ :=
  TaskFrame.continuous_nbhdTopology_of_history F.TaskRel hτ

end FrameOver

end FormalSystem.Semantics
