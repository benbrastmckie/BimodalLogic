/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Nomic.Recovery

/-!
# The nomic accessibility relation and the uniformity theorem

The frame-level half of `thm:nomic-uniform`. `def:nomic-frame`'s closing sentence specifies the
accessibility relation for the nomic operator at the level of the *frame*: at a time `x`, it
relates a nomologically possible world `τ` to each law-history at the state `τ` occupies at `x`.
`thm:nomic-uniform` then says that six conditions on that relation are equivalent, and that under
them the relation is `H_F × H_F` — an equivalence relation.

No object language appears anywhere in this module. The six conditions are conditions on
`lawHist`/`HF` alone, which is why they live beside `lem:nomic-recovery` (the (5)⇔(6) step
consumes it) rather than in the language component that formalizes the operator itself. The
operator, its truth clause, and the two collapses this module's conditions license are in
`FormalSystem/NomicLanguage/`.

## The `x`-quantifier in conditions (1)-(3)

The paper states conditions (1)-(3) with the time quantifier readable "existentially or
universally". `TransAt`/`SymmAt`/`EuclAt` below are each stated at a **single** time `x`, the
existential reading, because that is the *stronger* hypothesis to discharge: each of
`uniform_of_transAt`, `uniform_of_symmAt` and `uniform_of_euclAt` takes the condition at one time
and returns *Uniform*. The universal reading then follows, since `transAt_of_pointUniform` and its
two siblings return the condition at **every** `x`. That round trip is exactly what licenses the
paper's remark, and `nomic_uniform` bundles it.

## Why condition (4) is weaker than *Uniform* as written

`PointUniform` quantifies only over *occupied* states — `F.lawHist (τ x) = F.HF` for `τ ∈ H_F` —
while `NomicFrame.Uniform` quantifies over every world state. So (5)⇒(4) is immediate, and
(4)⇒(1)(2)(3) is choice-free: it never needs `occurrence` to produce an occupant. The three
implications *into* (5) do need it, and are choice-bearing accordingly.

## Main Definitions

- `NomicFrame.accRel` — `def:nomic-frame`'s accessibility relation at a time
- `NomicFrame.TransAt`, `NomicFrame.SymmAt`, `NomicFrame.EuclAt` — conditions (1)-(3) at one time
- `NomicFrame.PointUniform` — condition (4)
- `NomicFrame.TransAtState` — the cut `rmk:nomic-uniform`'s per-**state** transitivity

## Main Results

- `NomicFrame.lawHist_subset_HF`, `NomicFrame.exists_mem_HF_eq`, `NomicFrame.lawHist_nonempty` —
  the three small facts the cluster lacked; the last is the content of seriality
- `NomicFrame.uniform_of_transAt`, `_symmAt`, `_euclAt` — (1)⇒(5), (2)⇒(5), (3)⇒(5)
- `NomicFrame.pointUniform_of_uniform` — (5)⇒(4)
- `NomicFrame.transAt_of_pointUniform`, `_symmAt_`, `_euclAt_` — (4)⇒(1)(2)(3), choice-free
- `NomicFrame.uniform_iff_taskRel_indep` — (5)⇔(6), through `lem:nomic-recovery`
- `NomicFrame.accRel_eq_of_uniform`, `NomicFrame.accRel_equivalence_of_uniform` — the
  `H_F × H_F` identification and its equivalence-relation consequence
- `NomicFrame.nomic_uniform` — `thm:nomic-uniform`, bundled
- `NomicFrame.transAtState_iff`, `NomicFrame.uniform_iff_forall_transAtState` — the cut remark

## Choice dependence, recorded honestly

Every result below that reaches `NomicFrame.occurrence` is a theorem of **ZFC**, not of ZF:
`lem:nomic-occurrence` runs through `thm:extension`, whose proof appeals to Zorn's lemma.
`rmk:choice` lists the paper's choice-free results and `lem:nomic-occurrence` is not among them,
so nothing here that takes `[F.IsRegular]` is advertised as choice-free. The three
`_of_pointUniform` directions take no regularity instance and consume no constraint; they are the
genuinely choice-free half of the cycle.

## References

* JPL paper `def:nomic-frame` — the accessibility relation of the closing sentence
* JPL paper `thm:nomic-uniform` — the six equivalent conditions and the collapse
* JPL paper `lem:nomic-occurrence`, `lem:nomic-recovery` — the two inputs
* `appendix_cut_material.tex`, "Transitivity of nomic accessibility" — the cut `rmk:nomic-uniform`,
  whose per-state transitivity is `TransAtState` below. Cut material, cited by file and header
  rather than as a paper anchor, exactly as `NomicFrame.static_iff_taskRel_eq` cites
  `thm:nomic-primitive`
* `FormalSystem/Semantics/Nomic/Frame.lean` — `lawHist`, `HF`, the three properties, `occurrence`
* `FormalSystem/NomicLanguage/` — the operator whose logic these conditions govern

## Tags

nomic · uniformity · accessibility · law-histories
-/

namespace FormalSystem.Semantics

variable {D : TemporalOrder}

namespace NomicFrame

/-! ## Three small facts about `lawHist` and `HF` -/

/-- Every law-history set is contained in their union. -/
theorem lawHist_subset_HF (F : NomicFrame D) (w : F.World) : F.lawHist w ⊆ F.HF :=
  Set.subset_iUnion _ w

/--
Every world state is the state occupied at `x` by some nomologically possible world — the last
clause of `thm:nomic-uniform`'s (1)⇒(5) argument ("every `w'` is `τ'(x)` for some `τ' ∈ H_F`").

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`; see
this module's docstring.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem exists_mem_HF_eq (F : NomicFrame D) [F.IsRegular] (w : F.World) (x : ↑D) :
    ∃ τ ∈ F.HF, τ x = w := by
  obtain ⟨τ, hτ, hτx⟩ := F.occurrence w w x
  exact ⟨τ, F.lawHist_subset_HF w hτ, hτx⟩

/--
The law-histories at any state are nonempty — the content of **D** for the nomic operator, whose
validity form is `nomic_serial` in `FormalSystem/NomicLanguage/NomicValidity.lean`.

`occurrence w w x` supplies the witness: the state `w` itself occurs at `x` along some law-history
at `w`.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`; see
this module's docstring.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem lawHist_nonempty (F : NomicFrame D) [F.IsRegular] (w : F.World) (x : ↑D) :
    (F.lawHist w).Nonempty := by
  obtain ⟨τ, hτ, _⟩ := F.occurrence w w x
  exact ⟨τ, hτ⟩

/-! ## The accessibility relation and conditions (1)-(4) -/

/--
`def:nomic-frame`'s accessibility relation at the time `x`: it relates `τ` to each `σ` in the
law-histories at the state `τ` occupies at `x`.

This is the frame-level content of the Nomic truth clause — `M, τ, x ⊨ ◈φ` iff `φ` holds at
`(σ, x)` for every `σ` accessible from `τ` at `x` — stated with no object language in sight.
-/
def accRel (F : NomicFrame D) (x : ↑D) (τ σ : ↑D → F.World) : Prop := σ ∈ F.lawHist (τ x)

/--
Condition (1) of `thm:nomic-uniform`, *Transitivity*: `accRel` is transitive at the time `x`,
among the nomologically possible worlds.

Stated at a **single** `x` — the existential reading of the paper's quantifier, which is the
stronger hypothesis. `transAt_of_pointUniform` returns it at every `x`, which is what licenses
reading the quantifier either way; see this module's docstring.
-/
def TransAt (F : NomicFrame D) (x : ↑D) : Prop :=
  ∀ τ ∈ F.HF, ∀ σ ∈ F.HF, ∀ ρ ∈ F.HF, F.accRel x τ σ → F.accRel x σ ρ → F.accRel x τ ρ

/--
Condition (2) of `thm:nomic-uniform`, *Symmetry*: `accRel` is symmetric at the time `x`, among the
nomologically possible worlds.

Stated at a single `x`, the existential reading; `symmAt_of_pointUniform` returns it at every `x`.
-/
def SymmAt (F : NomicFrame D) (x : ↑D) : Prop :=
  ∀ τ ∈ F.HF, ∀ σ ∈ F.HF, F.accRel x τ σ → F.accRel x σ τ

/--
Condition (3) of `thm:nomic-uniform`, the *Euclidean* condition: at the time `x`, any two worlds
accessible from one nomologically possible world are accessible from each other.

Stated at a single `x`, the existential reading; `euclAt_of_pointUniform` returns it at every `x`.
-/
def EuclAt (F : NomicFrame D) (x : ↑D) : Prop :=
  ∀ τ ∈ F.HF, ∀ σ ∈ F.HF, ∀ ρ ∈ F.HF, F.accRel x τ σ → F.accRel x τ ρ → F.accRel x σ ρ

/--
Condition (4) of `thm:nomic-uniform`: `H_F^{τ(x)} = H_F` for every nomologically possible `τ` and
every time `x`.

Weaker than `NomicFrame.Uniform` as written, which quantifies over *every* world state rather than
only the occupied ones — which is why (5)⇒(4) is immediate and (4)⇒(1)(2)(3) is choice-free. See
this module's docstring.
-/
def PointUniform (F : NomicFrame D) : Prop := ∀ τ ∈ F.HF, ∀ x : ↑D, F.lawHist (τ x) = F.HF

/-! ## The cycle of implications -/

/--
(1)⇒(5): transitivity at one time forces nomological uniformity.

The paper's argument verbatim. With `w := τ x` for an arbitrary `τ ∈ H_F`, `lem:nomic-occurrence`
gives `σ ∈ H_F^w` with `σ x = u` for an arbitrary state `u`; transitivity carries every
`ρ ∈ H_F^u = H_F^{σ(x)}` into `H_F^{τ(x)} = H_F^w`, so `H_F^u ⊆ H_F^w` for every `u`, whence
`H_F ⊆ H_F^w ⊆ H_F`. Every state is some `τ' x` by `exists_mem_HF_eq`, so the identification is
uniform.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`; see
this module's docstring.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem uniform_of_transAt (F : NomicFrame D) [F.IsRegular] {x : ↑D} (h : F.TransAt x) :
    F.Uniform := by
  -- First: `F.lawHist (τ x) = F.HF` for every `τ ∈ F.HF`.
  have key : ∀ τ ∈ F.HF, F.lawHist (τ x) = F.HF := by
    intro τ hτ
    refine Set.Subset.antisymm (F.lawHist_subset_HF _) ?_
    intro ρ hρ
    obtain ⟨u, hu⟩ := Set.mem_iUnion.mp hρ
    obtain ⟨σ, hσ, hσx⟩ := F.occurrence (τ x) u x
    have hσHF : σ ∈ F.HF := F.lawHist_subset_HF _ hσ
    exact h τ hτ σ hσHF ρ hρ hσ (by rw [accRel, hσx]; exact hu)
  -- Then: every state is occupied, so the identification is uniform.
  intro w
  obtain ⟨τ, hτ, hτx⟩ := F.exists_mem_HF_eq w x
  rw [← hτx]
  exact key τ hτ

/--
(2)⇒(5): symmetry at one time forces nomological uniformity.

The same `w, τ, u, σ` construction as (1)⇒(5): symmetry gives `τ ∈ H_F^{σ(x)} = H_F^u`, and since
`τ ∈ H_F` and `u` were arbitrary, `H_F ⊆ H_F^u` for every `u`.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem uniform_of_symmAt (F : NomicFrame D) [F.IsRegular] {x : ↑D} (h : F.SymmAt x) :
    F.Uniform := by
  intro u
  refine Set.Subset.antisymm (F.lawHist_subset_HF u) ?_
  intro τ hτ
  obtain ⟨σ, hσ, hσx⟩ := F.occurrence (τ x) u x
  have hσHF : σ ∈ F.HF := F.lawHist_subset_HF _ hσ
  have := h τ hτ σ hσHF hσ
  rw [accRel, hσx] at this
  exact this

/--
(3)⇒(5): the Euclidean condition at one time forces nomological uniformity.

The same construction again: both `σ` and any `ρ ∈ H_F^w` lie in `H_F^{τ(x)}`, so the Euclidean
condition gives `ρ ∈ H_F^{σ(x)} = H_F^u`, whence `H_F^w ⊆ H_F^u` for all `w, u` and all the
law-history sets coincide with their union.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem uniform_of_euclAt (F : NomicFrame D) [F.IsRegular] {x : ↑D} (h : F.EuclAt x) :
    F.Uniform := by
  -- `H_F^w ⊆ H_F^u` for every pair of states.
  have key : ∀ w u : F.World, F.lawHist w ⊆ F.lawHist u := by
    intro w u ρ hρ
    obtain ⟨τ, hτ, hτx⟩ := F.exists_mem_HF_eq w x
    obtain ⟨σ, hσ, hσx⟩ := F.occurrence w u x
    have hσHF : σ ∈ F.HF := F.lawHist_subset_HF _ hσ
    have hρHF : ρ ∈ F.HF := F.lawHist_subset_HF _ hρ
    have hτσ : F.accRel x τ σ := by rw [accRel, hτx]; exact hσ
    have hτρ : F.accRel x τ ρ := by rw [accRel, hτx]; exact hρ
    have := h τ hτ σ hσHF ρ hρHF hτσ hτρ
    rw [accRel, hσx] at this
    exact this
  intro w
  refine Set.Subset.antisymm (F.lawHist_subset_HF w) ?_
  intro ρ hρ
  obtain ⟨u, hu⟩ := Set.mem_iUnion.mp hρ
  exact key u w hu

/-- (5)⇒(4): immediate, since *Uniform* quantifies over every world state and (4) only over the
occupied ones. -/
theorem pointUniform_of_uniform {F : NomicFrame D} (h : F.Uniform) : F.PointUniform :=
  fun τ _ x => h (τ x)

/--
(4)⇒(1), at every time — which is what licenses reading the paper's `x`-quantifier universally.

**Choice-free**: it takes no regularity instance, never reaches `occurrence`, and measures at
`[propext]`. It consumes no constraint, so it carries no constraints-consumed marker.
-/
theorem transAt_of_pointUniform {F : NomicFrame D} (h : F.PointUniform) (x : ↑D) :
    F.TransAt x := by
  intro τ hτ _ _ ρ hρ _ _
  rw [accRel, h τ hτ x]
  exact hρ

/--
(4)⇒(2), at every time. **Choice-free**, exactly as `transAt_of_pointUniform` is; no constraint
consumed.
-/
theorem symmAt_of_pointUniform {F : NomicFrame D} (h : F.PointUniform) (x : ↑D) :
    F.SymmAt x := by
  intro τ hτ σ hσ _
  rw [accRel, h σ hσ x]
  exact hτ

/--
(4)⇒(3), at every time. **Choice-free**, exactly as `transAt_of_pointUniform` is; no constraint
consumed.
-/
theorem euclAt_of_pointUniform {F : NomicFrame D} (h : F.PointUniform) (x : ↑D) :
    F.EuclAt x := by
  intro _ _ σ hσ ρ hρ _ _
  rw [accRel, h σ hσ x]
  exact hρ

/--
(5)⇔(6): *Uniform* holds exactly when the relativized task relation is independent of the world
state — in which case the nomic frame is itself a task frame.

Both legs go through `lem:nomic-recovery` (`lawHist_eq_iff_taskRel_eq`). The `mpr` leg transports
along the recovered equation with `▸` rather than `rw`, for the carrier-boundary reason
`Semantics/Nomic/ZTime.lean` records.

**Choice dependence, recorded honestly.** A theorem of ZFC: `lem:nomic-recovery`'s forward
direction runs the two-point partial history through `thm:extension`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem uniform_iff_taskRel_indep (F : NomicFrame D) [F.IsRegular] :
    F.Uniform ↔ ∀ w u : F.World, F.TaskRel w = F.TaskRel u := by
  constructor
  · intro h w u
    exact (F.lawHist_eq_iff_taskRel_eq w u).mp (by rw [h w, h u])
  · intro h w
    refine Set.Subset.antisymm (F.lawHist_subset_HF w) ?_
    intro τ hτ
    obtain ⟨u, hu⟩ := Set.mem_iUnion.mp hτ
    exact (F.lawHist_eq_iff_taskRel_eq u w).mpr (h u w) ▸ hu

/-! ## The `H_F × H_F` identification -/

/-- Under uniformity the accessibility relation at every time is `H_F × H_F`: it relates `τ` to
exactly the nomologically possible worlds, whatever `τ` is. -/
theorem accRel_eq_of_uniform (F : NomicFrame D) (h : F.Uniform) (x : ↑D) :
    ∀ τ σ : ↑D → F.World, F.accRel x τ σ ↔ σ ∈ F.HF := by
  intro τ σ
  rw [accRel, h (τ x)]

/--
Under uniformity the accessibility relation restricted to `H_F` is an equivalence relation:
reflexive on `H_F`, symmetric there, and transitive outright.

This is the frame-level reason every **S5** schema holds for the nomic operator on a uniform
frame, and `thm:nomic-uniform`'s closing sentence says so. Transitivity needs no membership
hypothesis at all, since `accRel x σ ρ` already delivers `ρ ∈ H_F`.
-/
theorem accRel_equivalence_of_uniform (F : NomicFrame D) (h : F.Uniform) (x : ↑D) :
    (∀ τ ∈ F.HF, F.accRel x τ τ) ∧
      (∀ τ σ, τ ∈ F.HF → σ ∈ F.HF → F.accRel x τ σ → F.accRel x σ τ) ∧
      (∀ τ σ ρ, F.accRel x τ σ → F.accRel x σ ρ → F.accRel x τ ρ) := by
  refine ⟨fun τ hτ => (F.accRel_eq_of_uniform h x τ τ).mpr hτ, ?_, ?_⟩
  · intro τ σ hτ _ _
    exact (F.accRel_eq_of_uniform h x σ τ).mpr hτ
  · intro τ σ ρ _ h2
    exact (F.accRel_eq_of_uniform h x τ ρ).mpr ((F.accRel_eq_of_uniform h x σ ρ).mp h2)

/--
`thm:nomic-uniform`, bundled: conditions (1)-(6) are equivalent, at every time.

The five biconditionals are assembled from the cycle above, in `nomic_hierarchy`'s bundling style.
The accompanying `H_F × H_F` identification is `accRel_eq_of_uniform` with
`accRel_equivalence_of_uniform`, and the `◈φ ↔ □φ` collapse is
`FormalSystem.NomicLanguage.nomic_iff_box_of_uniform`.

**Choice dependence, recorded honestly.** A theorem of ZFC: three of the five legs run through
`lem:nomic-occurrence` and one through `lem:nomic-recovery`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem nomic_uniform (F : NomicFrame D) [F.IsRegular] (x : ↑D) :
    (F.TransAt x ↔ F.Uniform) ∧ (F.SymmAt x ↔ F.Uniform) ∧ (F.EuclAt x ↔ F.Uniform) ∧
      (F.PointUniform ↔ F.Uniform) ∧
      ((∀ w u : F.World, F.TaskRel w = F.TaskRel u) ↔ F.Uniform) :=
  ⟨⟨fun h => F.uniform_of_transAt h,
      fun h => transAt_of_pointUniform (pointUniform_of_uniform h) x⟩,
    ⟨fun h => F.uniform_of_symmAt h,
      fun h => symmAt_of_pointUniform (pointUniform_of_uniform h) x⟩,
    ⟨fun h => F.uniform_of_euclAt h,
      fun h => euclAt_of_pointUniform (pointUniform_of_uniform h) x⟩,
    ⟨fun h => F.uniform_of_transAt (transAt_of_pointUniform h x), pointUniform_of_uniform⟩,
    ⟨(F.uniform_iff_taskRel_indep).mpr, (F.uniform_iff_taskRel_indep).mp⟩⟩

/-! ## The cut remark's side lemma: per-state transitivity

The cut `rmk:nomic-uniform` (`appendix_cut_material.tex`, "Transitivity of nomic accessibility")
specifies transitivity at a world **state** rather than at a time: a different notion from
condition (1), which is per-time. It is cited here by file and header, not as a paper anchor —
the material is cut, so `scripts/check-paper-definitions.sh --resolve` structurally cannot read
it, exactly as for `thm:nomic-primitive` at `NomicFrame.static_iff_taskRel_eq`. -/

/--
The cut `rmk:nomic-uniform`'s per-**state** transitivity at `w`: every law-history set determined
by a state occupied along a law-history at `w` is contained in `H_F^w`.
-/
def TransAtState (F : NomicFrame D) (w : F.World) : Prop :=
  ∀ σ ∈ F.lawHist w, ∀ x : ↑D, F.lawHist (σ x) ⊆ F.lawHist w

/--
Per-state transitivity at `w` is containment of **every** law-history set in `H_F^w`.

The forward leg is the remark's own step: every world state `u` is the state `σ x` of some
`σ ∈ H_F^w`, by `lem:nomic-occurrence` at the time `0`.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem transAtState_iff (F : NomicFrame D) [F.IsRegular] (w : F.World) :
    F.TransAtState w ↔ ∀ u : F.World, F.lawHist u ⊆ F.lawHist w := by
  constructor
  · intro h u
    obtain ⟨σ, hσ, hσ0⟩ := F.occurrence w u (0 : ↑D)
    have := h σ hσ (0 : ↑D)
    rw [hσ0] at this
    exact this
  · intro h σ _ x
    exact h (σ x)

/--
Per-state transitivity at every world state is nomological uniformity — the remark's closing
observation, that each `H_F^w` is then identical with the union `H_F`.

**Choice dependence, recorded honestly.** A theorem of ZFC through `lem:nomic-occurrence`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem uniform_iff_forall_transAtState (F : NomicFrame D) [F.IsRegular] :
    (∀ w : F.World, F.TransAtState w) ↔ F.Uniform := by
  constructor
  · intro h w
    refine Set.Subset.antisymm (F.lawHist_subset_HF w) ?_
    intro τ hτ
    obtain ⟨u, hu⟩ := Set.mem_iUnion.mp hτ
    exact (F.transAtState_iff w).mp (h w) u hu
  · intro h w σ _ x
    rw [h (σ x), h w]

end NomicFrame

end FormalSystem.Semantics
