/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Nomic.ZTime

/-!
# `prop:nomic-hierarchy`: the three nomic properties are strictly ordered

*Uniform* implies both *Static* and *Lawful* (`NomicFrame.static_of_uniform`,
`NomicFrame.lawful_of_uniform`, in `Nomic/Frame.lean`), and nothing more holds: neither *Static*
nor *Lawful* implies the other, and the two together do not imply *Uniform*. This module carries
the three finite ℤ-time witnesses that separate them, each assembled from its one-step relation
family by `def:nomic-witnesses`' scheme (`NomicFrame.ofStepFamily`), and the per-witness
independence theorems, with `nomic_hierarchy` bundling their joint content.

Per-witness named theorems, not only a bundled existential, following
`Semantics/FrameConstraintIndependence.lean`'s house style: the separating content of each witness
should be citable on its own.

## The witnesses

- `F1` on `W3 = {a, b, c}`, with `R_a = R_b = Eq` and `R_c` swapping `a`/`b` and fixing `c`:
  *Static* but not *Lawful*
- `F3` on the same carrier, with `R_a = Eq` and `R_b = R_c = {(a,a)} ∪ ({b,c} × {b,c})`:
  *Static* and *Lawful* but not *Uniform*

## Why the relations are written as `match`es

Each family is defined by `match` on the world state with a shared catch-all branch — `| _ => Eq`
for `F1`, and the pair-disjunction branch for `F3` — so that the two coinciding members reduce to
the *same term*. The paper's `H_F^a = H_F^b` (witness 1) and `H_F^b = H_F^c` (witness 3) are then
`rfl`, not proofs: the frames `F.at a` and `F.at b` are literally the same record. Keeping that
shape is load-bearing, and `F1_lawHist_a_eq_b`/`F3_lawHist_b_eq_c` pin it.

The `Fintype` instances are hand-written (`elems := {a, b, c}`,
`complete := by intro x; cases x <;> simp`), which is the tree's house pattern — `deriving Fintype`
is used nowhere here — and `Finite` follows from them, as `ofStepFamily` requires.

## Choice dependence

Every witness is choice-dependent, at exactly one place: each member frame's *Saturation* comes
from `TaskFrame.saturation_of_finite` through `FrameOver.ofStep_isRegular`, which costs
`Classical.choice`. The separating arguments themselves are choice-free inductions
(`NomicFrame.stepPath_invariant` and its forward companion), so the cost is paid once per frame
and not again per theorem. `rmk:choice` does not cover the nomic results.
-/

namespace FormalSystem.Semantics

namespace NomicHierarchy

/-! ## The shared three-state carrier -/

/-- The three-state carrier of witnesses 1 and 3. -/
inductive W3 | a | b | c
  deriving DecidableEq

instance : Nonempty W3 := ⟨W3.a⟩

instance : Fintype W3 where
  elems := {W3.a, W3.b, W3.c}
  complete := by intro x; cases x <;> simp

/-! ## Witness 1: *Static* but not *Lawful* -/

/--
Witness 1's one-step family: `R_a = R_b` is the identity, while `R_c` swaps `a` and `b` and fixes
`c`.

Written as a `match` with a shared `| _ => Eq` branch, so that `R1 .a` and `R1 .b` are the same
term and `F1_lawHist_a_eq_b` holds by `rfl`.
-/
def R1 (w : W3) : W3 → W3 → Prop :=
  match w with
  | .c => fun p q => (p = .a ∧ q = .b) ∨ (p = .b ∧ q = .a) ∨ (p = .c ∧ q = .c)
  | _ => Eq

/-- Every `R1 w` is total: `def:nomic-witnesses`' forward seriality obligation. -/
theorem R1_fwd : ∀ w p, ∃ q, R1 w p q := by
  intro w p
  cases w with
  | a => exact ⟨p, rfl⟩
  | b => exact ⟨p, rfl⟩
  | c => cases p with
    | a => exact ⟨.b, Or.inl ⟨rfl, rfl⟩⟩
    | b => exact ⟨.a, Or.inr (Or.inl ⟨rfl, rfl⟩)⟩
    | c => exact ⟨.c, Or.inr (Or.inr ⟨rfl, rfl⟩)⟩

/-- Every `R1 w` is surjective: `def:nomic-witnesses`' backward seriality obligation. -/
theorem R1_bwd : ∀ w q, ∃ p, R1 w p q := by
  intro w q
  cases w with
  | a => exact ⟨q, rfl⟩
  | b => exact ⟨q, rfl⟩
  | c => cases q with
    | a => exact ⟨.b, Or.inr (Or.inl ⟨rfl, rfl⟩)⟩
    | b => exact ⟨.a, Or.inl ⟨rfl, rfl⟩⟩
    | c => exact ⟨.c, Or.inr (Or.inr ⟨rfl, rfl⟩)⟩

/-- Witness 1 of `prop:nomic-hierarchy`: a *Static* nomic frame over ℤ that is not *Lawful*. -/
def F1 : NomicFrame intOrder := NomicFrame.ofStepFamily R1 R1_fwd R1_bwd

/-- `F1`'s `a`-th and `b`-th members are the same frame, so their law-histories coincide — the
paper's `H_F^a = H_F^b`, free by the `match` shape rather than proved. -/
theorem F1_lawHist_a_eq_b : F1.lawHist W3.a = F1.lawHist W3.b := rfl

/-- The definitional pin promised by `NomicFrame.ofStepFamily_at`, at a concrete carrier. -/
example : F1.at W3.a = FrameOver.ofStep (R1 W3.a) (R1_fwd W3.a) (R1_bwd W3.a) := rfl

/-- A law-history at `a` is constant: `R_a` is the identity, so `fun u => u = τ 0` is a two-sided
step-invariant. -/
theorem F1_const_of_mem_a {τ : ℤ → W3} (h : τ ∈ F1.lawHist W3.a) (n : ℤ) : τ n = τ 0 := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3.a τ).mp h
  exact NomicFrame.stepPath_invariant hstep
    (P := fun u => u = τ 0) (fun p q hpq => by subst hpq; exact Iff.rfl) 0 rfl n

/-- Along a law-history at `c`, being at `c` is a two-sided invariant: `R_c` fixes `c` and keeps
`{a, b}` to itself. -/
theorem F1_c_invariant {τ : ℤ → W3} (h : τ ∈ F1.lawHist W3.c) (n : ℤ) :
    (τ n = W3.c ↔ τ 0 = W3.c) := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3.c τ).mp h
  refine NomicFrame.stepPath_invariant hstep
    (P := fun u => (u = W3.c ↔ τ 0 = W3.c)) ?_ 0 Iff.rfl n
  intro p q hpq
  rcases hpq with ⟨hp, hq⟩ | ⟨hp, hq⟩ | ⟨hp, hq⟩ <;> subst hp <;> subst hq <;> simp

/--
Witness 1 is *Static*: along every nomologically possible world, the states occupied at any two
times determine the same law-histories.

A law-history at `a` or `b` is constant, so the two states *are* the same state. A law-history at
`c` either stays at `c` throughout or avoids `c` throughout (`F1_c_invariant`); in the first case
the states coincide again, and in the second they both lie in `{a, b}`, whose law-histories agree
by `F1_lawHist_a_eq_b`.
-/
theorem F1_static : F1.Static := by
  intro τ hτ x y
  obtain ⟨w, hw⟩ := Set.mem_iUnion.mp hτ
  cases w with
  | a => rw [F1_const_of_mem_a hw x, F1_const_of_mem_a hw y]
  | b =>
    have hw' : τ ∈ F1.lawHist W3.a := F1_lawHist_a_eq_b ▸ hw
    rw [F1_const_of_mem_a hw' x, F1_const_of_mem_a hw' y]
  | c =>
    by_cases h0 : τ 0 = W3.c
    · rw [(F1_c_invariant hw x).mpr h0, (F1_c_invariant hw y).mpr h0]
    · have hx : τ x ≠ W3.c := fun hc => h0 ((F1_c_invariant hw x).mp hc)
      have hy : τ y ≠ W3.c := fun hc => h0 ((F1_c_invariant hw y).mp hc)
      cases hxv : τ x <;> cases hyv : τ y <;>
        first
          | rfl
          | exact F1_lawHist_a_eq_b
          | exact F1_lawHist_a_eq_b.symm
          | exact absurd hxv hx
          | exact absurd hyv hy

/-- The alternating path: `a` at even times, `b` at odd times. -/
def alt : ℤ → W3 := fun n => if n % 2 = 0 then W3.a else W3.b

/-- The alternating path is a law-history at `c`: each of its steps is an `R_c`-swap. -/
theorem alt_mem_c : alt ∈ F1.lawHist W3.c := by
  refine (NomicFrame.mem_lawHist_ofStepFamily_iff W3.c alt).mpr ?_
  intro n
  by_cases h : n % 2 = 0
  · have h1 : (n + 1) % 2 ≠ 0 := by omega
    exact Or.inl ⟨by simp [alt, h], by simp [alt, h1]⟩
  · have h1 : (n + 1) % 2 = 0 := by omega
    exact Or.inr (Or.inl ⟨by simp [alt, h], by simp [alt, h1]⟩)

/--
Witness 1 is **not** *Lawful*, so *Static* does not imply *Lawful* — the first gap of
`prop:nomic-hierarchy`.

The alternating path is a law-history at `c`, hence lies in `H_F`, and it occupies `a` at time `0`.
*Lawful* would therefore place it in `H_F^a`, where every history is constant — contradicting its
step from `a` to `b`.
-/
theorem F1_not_lawful : ¬ F1.Lawful := by
  intro h
  have hmem : alt ∈ F1.HF := Set.mem_iUnion.mpr ⟨W3.c, alt_mem_c⟩
  have h0 : alt 0 = W3.a := by simp [alt]
  have hla : alt ∈ F1.lawHist W3.a := by
    have := h alt hmem 0
    rwa [h0] at this
  have h1 := F1_const_of_mem_a hla 1
  rw [h0] at h1
  simp [alt] at h1

/-! ## Witness 3: *Static* and *Lawful* but not *Uniform* -/

/--
Witness 3's one-step family: `R_a` is the identity, while `R_b = R_c` fixes `a` and lets `b` and
`c` go to each other freely — `{(a,a)} ∪ ({b,c} × {b,c})`, written as "either both ends are `a` or
neither is".

Written as a `match` with a shared catch-all branch, so that `R3 .b` and `R3 .c` are the same term
and `F3_lawHist_b_eq_c` holds by `rfl`. Structurally the mirror of `R1`: there the two coinciding
members were the identity ones, here they are the permissive ones.
-/
def R3 (w : W3) : W3 → W3 → Prop :=
  match w with
  | .a => Eq
  | _ => fun p q => (p = .a ∧ q = .a) ∨ (p ≠ .a ∧ q ≠ .a)

/-- Every `R3 w` is reflexive. This carries both seriality obligations *and* the fact that a
constant path is a law-history at every world state. -/
theorem R3_refl (w p : W3) : R3 w p p := by
  cases w <;> cases p <;>
    first
      | rfl
      | exact Or.inl ⟨rfl, rfl⟩
      | exact Or.inr ⟨by decide, by decide⟩

/-- Every `R3 w` is total: `def:nomic-witnesses`' forward seriality obligation. -/
theorem R3_fwd : ∀ w p, ∃ q, R3 w p q := fun w p => ⟨p, R3_refl w p⟩

/-- Every `R3 w` is surjective: `def:nomic-witnesses`' backward seriality obligation. -/
theorem R3_bwd : ∀ w q, ∃ p, R3 w p q := fun w q => ⟨q, R3_refl w q⟩

/-- Witness 3 of `prop:nomic-hierarchy`: a *Static* and *Lawful* nomic frame over ℤ that is not
*Uniform*. -/
def F3 : NomicFrame intOrder := NomicFrame.ofStepFamily R3 R3_fwd R3_bwd

/-- `F3`'s `b`-th and `c`-th members are the same frame, so their law-histories coincide — free by
the `match` shape, as in witness 1. -/
theorem F3_lawHist_b_eq_c : F3.lawHist W3.b = F3.lawHist W3.c := rfl

/-- A constant path is a law-history at **every** world state, by reflexivity of each `R3 w`. -/
theorem F3_mem_of_const {τ : ℤ → W3} (h : ∀ n : ℤ, τ n = τ 0) (w : W3) :
    τ ∈ F3.lawHist w := by
  refine (NomicFrame.mem_lawHist_ofStepFamily_iff w τ).mpr fun n => ?_
  have hstep : τ (n + 1) = τ n := by rw [h (n + 1), h n]
  rw [hstep]
  exact R3_refl w (τ n)

/-- A law-history at `a` is constant: `R_a` is the identity, exactly as in witness 1. -/
theorem F3_const_of_mem_a {τ : ℤ → W3} (h : τ ∈ F3.lawHist W3.a) (n : ℤ) : τ n = τ 0 := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3.a τ).mp h
  exact NomicFrame.stepPath_invariant hstep
    (P := fun u => u = τ 0) (fun p q hpq => by subst hpq; exact Iff.rfl) 0 rfl n

/-- Along a law-history at `b` (hence at `c`), being at `a` is a two-sided invariant: `R_b` fixes
`a` and keeps `{b, c}` to itself. -/
theorem F3_a_invariant {τ : ℤ → W3} (h : τ ∈ F3.lawHist W3.b) (n : ℤ) :
    (τ n = W3.a ↔ τ 0 = W3.a) := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3.b τ).mp h
  refine NomicFrame.stepPath_invariant hstep
    (P := fun u => (u = W3.a ↔ τ 0 = W3.a)) ?_ 0 Iff.rfl n
  intro p q hpq
  rcases hpq with ⟨hp, hq⟩ | ⟨hp, hq⟩
  · rw [hp, hq]
  · simp [hp, hq]

/-- Every law-history of `F3` is one at `a` or one at `b`, since `H_F^c = H_F^b`. -/
theorem F3_mem_a_or_b {τ : ℤ → W3} (h : τ ∈ F3.HF) :
    τ ∈ F3.lawHist W3.a ∨ τ ∈ F3.lawHist W3.b := by
  obtain ⟨w, hw⟩ := Set.mem_iUnion.mp h
  cases w with
  | a => exact Or.inl hw
  | b => exact Or.inr hw
  | c => exact Or.inr hw

/--
Witness 3 is *Static*.

A law-history at `a` is constant, so the states occupied at any two times *are* the same state.
A law-history at `b` either sits at `a` throughout (`F3_a_invariant`, again the same state at both
times) or avoids `a` throughout, in which case both states lie in `{b, c}`, whose law-histories
agree by `F3_lawHist_b_eq_c`.
-/
theorem F3_static : F3.Static := by
  intro τ hτ x y
  rcases F3_mem_a_or_b hτ with hb | hb
  · rw [F3_const_of_mem_a hb x, F3_const_of_mem_a hb y]
  · by_cases h0 : τ 0 = W3.a
    · rw [(F3_a_invariant hb x).mpr h0, (F3_a_invariant hb y).mpr h0]
    · have hx : τ x ≠ W3.a := fun hc => h0 ((F3_a_invariant hb x).mp hc)
      have hy : τ y ≠ W3.a := fun hc => h0 ((F3_a_invariant hb y).mp hc)
      cases hxv : τ x <;> cases hyv : τ y <;>
        first
          | rfl
          | exact F3_lawHist_b_eq_c
          | exact F3_lawHist_b_eq_c.symm
          | exact absurd hxv hx
          | exact absurd hyv hy

/--
Witness 3 is *Lawful*.

A law-history at `a` is constant and so lies in every `H_F^w` (`F3_mem_of_const`). A law-history
at `b` that sits at `a` is likewise constant; one that avoids `a` occupies only `b` and `c` at
every time, and it is already a law-history at both of those, since `H_F^b = H_F^c`.
-/
theorem F3_lawful : F3.Lawful := by
  intro τ hτ x
  rcases F3_mem_a_or_b hτ with hb | hb
  · exact F3_mem_of_const (F3_const_of_mem_a hb) (τ x)
  · by_cases h0 : τ 0 = W3.a
    · have hconst : ∀ n : ℤ, τ n = τ 0 := by
        intro n
        rw [(F3_a_invariant hb n).mpr h0, h0]
      exact F3_mem_of_const hconst (τ x)
    · have hx : τ x ≠ W3.a := fun hc => h0 ((F3_a_invariant hb x).mp hc)
      cases hxv : τ x with
      | a => exact absurd hxv hx
      | b => exact hb
      | c => exact hb

/-- The alternating `b`/`c` path: `b` at even times, `c` at odd times. -/
def altBC : ℤ → W3 := fun n => if n % 2 = 0 then W3.b else W3.c

/-- The alternating `b`/`c` path is a law-history at `b`: it never visits `a`. -/
theorem altBC_mem_b : altBC ∈ F3.lawHist W3.b := by
  refine (NomicFrame.mem_lawHist_ofStepFamily_iff W3.b altBC).mpr fun n => ?_
  refine Or.inr ⟨?_, ?_⟩
  · by_cases h : n % 2 = 0 <;> simp [altBC, h]
  · by_cases h : (n + 1) % 2 = 0 <;> simp [altBC, h]

/--
Witness 3 is **not** *Uniform*, so *Static* and *Lawful* together do not imply *Uniform* — the
third gap of `prop:nomic-hierarchy`.

The alternating `b`/`c` path lies in `H_F^b`, hence in `H_F`, but not in `H_F^a`, where every
history is constant. *Uniform* would equate the two.
-/
theorem F3_not_uniform : ¬ F3.Uniform := by
  intro h
  have hmem : altBC ∈ F3.HF := Set.mem_iUnion.mpr ⟨W3.b, altBC_mem_b⟩
  -- `rw [h W3.a]` is refused here: the membership's binder is `↑intOrder → F3.World` while
  -- `altBC` is a `ℤ → W3`, so the rewrite is not type-correct at `implicit` transparency. Going
  -- through `Set.ext_iff` closes the same step up to defeq -- the `SlicedFrame.lean` pattern.
  have hla : altBC ∈ F3.lawHist W3.a := (Set.ext_iff.mp (h W3.a) altBC).mpr hmem
  have h01 := F3_const_of_mem_a hla 1
  simp [altBC] at h01

end NomicHierarchy

end FormalSystem.Semantics
