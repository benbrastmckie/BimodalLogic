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

Every witness is choice-dependent: each member frame's *Saturation* comes from
`TaskFrame.saturation_of_finite` through `FrameOver.ofStep_isRegular`, which costs
`Classical.choice`, and every statement about a law-history of such a frame inherits that cost.
`nomic_hierarchy`, `F1_static`, `F2_lawful` and the rest therefore measure at
`[propext, Classical.choice, Quot.sound]`. Of the underlying machinery only
`NomicFrame.stepPath_invariant` is choice-free; its forward-only companion is not, because
Mathlib's `Int.leInduction` is choice-dependent on this pin. `rmk:choice` does not cover the
nomic results, and nothing here advertises them as choice-free.
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

/-! ## Witness 2: *Lawful* but not *Static* -/

/-- The three-state carrier of witness 2: two "absorbing" states `a`, `b` and one state `e` from
which either can be reached. -/
inductive W3e | a | b | e
  deriving DecidableEq

instance : Nonempty W3e := ⟨W3e.a⟩

instance : Fintype W3e where
  elems := {W3e.a, W3e.b, W3e.e}
  complete := by intro x; cases x <;> simp

/--
Witness 2's one-step family: `R_a = {(a,a), (b,b), (e,a), (e,e)}`,
`R_b = {(a,a), (b,b), (e,b), (e,e)}`, and `R_e = R_a ∪ R_b`.

The shape to keep in mind: `a` and `b` are absorbing under every member, `e` is where the members
differ, and `R_e` is the only member that can leave `e` for either of the two absorbing states.
-/
def R2 (w : W3e) : W3e → W3e → Prop :=
  match w with
  | .a => fun p q => (p = .a ∧ q = .a) ∨ (p = .b ∧ q = .b) ∨ (p = .e ∧ (q = .a ∨ q = .e))
  | .b => fun p q => (p = .a ∧ q = .a) ∨ (p = .b ∧ q = .b) ∨ (p = .e ∧ (q = .b ∨ q = .e))
  | .e => fun p q => (p = .a ∧ q = .a) ∨ (p = .b ∧ q = .b) ∨
      (p = .e ∧ (q = .a ∨ q = .b ∨ q = .e))

/-- Every `R2 w` is reflexive, which carries both seriality obligations and the fact that a
constant path is a law-history at every world state. -/
theorem R2_refl (w p : W3e) : R2 w p p := by
  cases w <;> cases p <;> simp [R2]

/-- Every `R2 w` is total: `def:nomic-witnesses`' forward seriality obligation. -/
theorem R2_fwd : ∀ w p, ∃ q, R2 w p q := fun w p => ⟨p, R2_refl w p⟩

/-- Every `R2 w` is surjective: `def:nomic-witnesses`' backward seriality obligation. -/
theorem R2_bwd : ∀ w q, ∃ p, R2 w p q := fun w q => ⟨q, R2_refl w q⟩

/-- `R_a ⊆ R_e`. -/
theorem R2_a_le_e : ∀ p q, R2 W3e.a p q → R2 W3e.e p q := by
  intro p q h; cases p <;> cases q <;> simp_all [R2]

/-- `R_b ⊆ R_e`. -/
theorem R2_b_le_e : ∀ p q, R2 W3e.b p q → R2 W3e.e p q := by
  intro p q h; cases p <;> cases q <;> simp_all [R2]

/-- Being at `b` is a **two-sided** `R_a`-invariant: `R_a` neither enters nor leaves `b`. -/
theorem R2_a_b_invariant : ∀ p q, R2 W3e.a p q → (p = W3e.b ↔ q = W3e.b) := by
  intro p q h; cases p <;> cases q <;> simp_all [R2]

/-- Being at `a` is a **two-sided** `R_b`-invariant, by the mirror symmetry of the family. -/
theorem R2_b_a_invariant : ∀ p q, R2 W3e.b p q → (p = W3e.a ↔ q = W3e.a) := by
  intro p q h; cases p <;> cases q <;> simp_all [R2]

/-- Being at `a` is **forward**-propagated by `R_e`: `a` is absorbing. It is *not* a two-sided
invariant, since `R_e` enters `a` from `e` — which is why `stepPath_forward_invariant` exists. -/
theorem R2_e_a_forward : ∀ p q, R2 W3e.e p q → p = W3e.a → q = W3e.a := by
  intro p q h hp; cases p <;> cases q <;> simp_all [R2]

/-- Being at `b` is **forward**-propagated by `R_e`, by the mirror symmetry of the family. -/
theorem R2_e_b_forward : ∀ p q, R2 W3e.e p q → p = W3e.b → q = W3e.b := by
  intro p q h hp; cases p <;> cases q <;> simp_all [R2]

/-- The `R_e`-pairs mentioning no `b` are exactly `(a,a)`, `(e,a)`, `(e,e)`, all of them
`R_a`-pairs. -/
theorem R2_e_sub_a_of_ne_b : ∀ p q, R2 W3e.e p q → p ≠ W3e.b → q ≠ W3e.b →
    R2 W3e.a p q := by
  intro p q h hp hq; cases p <;> cases q <;> simp_all [R2]

/-- The `R_e`-pairs mentioning no `a` are exactly `(b,b)`, `(e,b)`, `(e,e)`, all of them
`R_b`-pairs. -/
theorem R2_e_sub_b_of_ne_a : ∀ p q, R2 W3e.e p q → p ≠ W3e.a → q ≠ W3e.a →
    R2 W3e.b p q := by
  intro p q h hp hq; cases p <;> cases q <;> simp_all [R2]

/-- Witness 2 of `prop:nomic-hierarchy`: a *Lawful* nomic frame over ℤ that is not *Static*. -/
def F2 : NomicFrame intOrder := NomicFrame.ofStepFamily R2 R2_fwd R2_bwd

/-- A constant path is a law-history at **every** world state, by reflexivity of each `R2 w`. -/
theorem F2_mem_of_const {τ : ℤ → W3e} (h : ∀ n : ℤ, τ n = τ 0) (w : W3e) :
    τ ∈ F2.lawHist w := by
  refine (NomicFrame.mem_lawHist_ofStepFamily_iff w τ).mpr fun n => ?_
  have hstep : τ (n + 1) = τ n := by rw [h (n + 1), h n]
  rw [hstep]
  exact R2_refl w (τ n)

/-- `H_F^a ⊆ H_F^e`, since `R_a ⊆ R_e`. -/
theorem F2_lawHist_a_subset_e : F2.lawHist W3e.a ⊆ F2.lawHist W3e.e :=
  NomicFrame.lawHist_mono_of_le R2_a_le_e

/-- `H_F^b ⊆ H_F^e`, since `R_b ⊆ R_e`. -/
theorem F2_lawHist_b_subset_e : F2.lawHist W3e.b ⊆ F2.lawHist W3e.e :=
  NomicFrame.lawHist_mono_of_le R2_b_le_e

/-- Along a law-history at `a`, being at `b` is a two-sided invariant. -/
theorem F2_b_invariant_of_mem_a {τ : ℤ → W3e} (h : τ ∈ F2.lawHist W3e.a) (n : ℤ) :
    (τ n = W3e.b ↔ τ 0 = W3e.b) := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3e.a τ).mp h
  refine NomicFrame.stepPath_invariant hstep
    (P := fun u => (u = W3e.b ↔ τ 0 = W3e.b)) ?_ 0 Iff.rfl n
  intro p q hpq
  rw [R2_a_b_invariant p q hpq]

/-- Along a law-history at `b`, being at `a` is a two-sided invariant. -/
theorem F2_a_invariant_of_mem_b {τ : ℤ → W3e} (h : τ ∈ F2.lawHist W3e.b) (n : ℤ) :
    (τ n = W3e.a ↔ τ 0 = W3e.a) := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3e.b τ).mp h
  refine NomicFrame.stepPath_invariant hstep
    (P := fun u => (u = W3e.a ↔ τ 0 = W3e.a)) ?_ 0 Iff.rfl n
  intro p q hpq
  rw [R2_b_a_invariant p q hpq]

/--
**The separating fact about `R_e`**: no `R_e`-path visits both `a` and `b`.

Forward from `a` only `a` is reachable and forward from `b` only `b` is, so a path visiting both
would have to visit the later of the two states twice over, as two different states. This is
`stepPath_forward_invariant` at `P u := (u = a)` and at `P u := (u = b)`, and it is exactly where
the forward-only invariant earns its place: neither predicate is two-sided under `R_e`.
-/
theorem F2_no_b_or_no_a_of_mem_e {τ : ℤ → W3e} (h : τ ∈ F2.lawHist W3e.e) :
    (∀ n : ℤ, τ n ≠ W3e.b) ∨ (∀ n : ℤ, τ n ≠ W3e.a) := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3e.e τ).mp h
  by_cases hb : ∃ n : ℤ, τ n = W3e.b
  · obtain ⟨n₁, h₁⟩ := hb
    refine Or.inr fun n₀ h₀ => ?_
    rcases le_total n₀ n₁ with hle | hle
    · have : τ n₁ = W3e.a :=
        NomicFrame.stepPath_forward_invariant hstep
          (P := fun u => u = W3e.a) (fun p q hpq hp => R2_e_a_forward p q hpq hp) h₀ n₁ hle
      rw [h₁] at this
      exact absurd this (by simp)
    · have : τ n₀ = W3e.b :=
        NomicFrame.stepPath_forward_invariant hstep
          (P := fun u => u = W3e.b) (fun p q hpq hp => R2_e_b_forward p q hpq hp) h₁ n₀ hle
      rw [h₀] at this
      exact absurd this (by simp)
  · exact Or.inl (not_exists.mp hb)

/-- A law-history at `e` that never visits `b` is a law-history at `a`: all of its steps are
`R_e`-pairs mentioning no `b`, and those are `R_a`-pairs. -/
theorem F2_mem_a_of_mem_e_of_no_b {τ : ℤ → W3e} (h : τ ∈ F2.lawHist W3e.e)
    (hb : ∀ n : ℤ, τ n ≠ W3e.b) : τ ∈ F2.lawHist W3e.a := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3e.e τ).mp h
  refine (NomicFrame.mem_lawHist_ofStepFamily_iff W3e.a τ).mpr fun n => ?_
  exact R2_e_sub_a_of_ne_b _ _ (hstep n) (hb n) (hb (n + 1))

/-- A law-history at `e` that never visits `a` is a law-history at `b`, by the mirror argument. -/
theorem F2_mem_b_of_mem_e_of_no_a {τ : ℤ → W3e} (h : τ ∈ F2.lawHist W3e.e)
    (ha : ∀ n : ℤ, τ n ≠ W3e.a) : τ ∈ F2.lawHist W3e.b := by
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3e.e τ).mp h
  refine (NomicFrame.mem_lawHist_ofStepFamily_iff W3e.b τ).mpr fun n => ?_
  exact R2_e_sub_b_of_ne_a _ _ (hstep n) (ha n) (ha (n + 1))

/--
Witness 2 is *Lawful* — the heaviest proof of `prop:nomic-hierarchy`, and the one the paper's
appendix states without working out.

Three cases, on which law-history set the world came from.

- `τ ∈ H_F^a`: being at `b` is a two-sided `R_a`-invariant, so either `τ` is constantly `b` — in
  which case it lies in *every* `H_F^w` by reflexivity — or it never visits `b`, so each `τ x` is
  `a` or `e`, and `H_F^a ⊆ H_F^e` by `lawHist_mono_of_le`.
- `τ ∈ H_F^b`: the mirror argument.
- `τ ∈ H_F^e`: by `F2_no_b_or_no_a_of_mem_e` the world misses `a` throughout or misses `b`
  throughout. Missing `b`, all of its steps are `R_a`-pairs, so it lies in `H_F^a`, and each
  `τ x` is then `a` or `e`, both of which it is a law-history at. Missing `a`, the mirror.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem F2_lawful : F2.Lawful := by
  intro τ hτ x
  obtain ⟨v, hv⟩ := Set.mem_iUnion.mp hτ
  cases v with
  | a =>
    by_cases h0 : τ 0 = W3e.b
    · have hconst : ∀ n : ℤ, τ n = τ 0 := by
        intro n
        rw [(F2_b_invariant_of_mem_a hv n).mpr h0, h0]
      exact F2_mem_of_const hconst (τ x)
    · have hx : τ x ≠ W3e.b := fun hc => h0 ((F2_b_invariant_of_mem_a hv x).mp hc)
      cases hxv : τ x with
      | a => exact hv
      | b => exact absurd hxv hx
      | e => exact F2_lawHist_a_subset_e hv
  | b =>
    by_cases h0 : τ 0 = W3e.a
    · have hconst : ∀ n : ℤ, τ n = τ 0 := by
        intro n
        rw [(F2_a_invariant_of_mem_b hv n).mpr h0, h0]
      exact F2_mem_of_const hconst (τ x)
    · have hx : τ x ≠ W3e.a := fun hc => h0 ((F2_a_invariant_of_mem_b hv x).mp hc)
      cases hxv : τ x with
      | a => exact absurd hxv hx
      | b => exact hv
      | e => exact F2_lawHist_b_subset_e hv
  | e =>
    rcases F2_no_b_or_no_a_of_mem_e hv with hnb | hna
    · have hmem : τ ∈ F2.lawHist W3e.a := F2_mem_a_of_mem_e_of_no_b hv hnb
      cases hxv : τ x with
      | a => exact hmem
      | b => exact absurd hxv (hnb x)
      | e => exact hv
    · have hmem : τ ∈ F2.lawHist W3e.b := F2_mem_b_of_mem_e_of_no_a hv hna
      cases hxv : τ x with
      | a => exact absurd hxv (hna x)
      | b => exact hmem
      | e => exact hv

/-- The world that sits at `e` up to time `0` and at `a` afterwards. -/
def sigA : ℤ → W3e := fun n => if n ≤ 0 then W3e.e else W3e.a

/-- The world that sits at `e` up to time `0` and at `b` afterwards. -/
def sigB : ℤ → W3e := fun n => if n ≤ 0 then W3e.e else W3e.b

/-- `σ_a` is a law-history at `a`: its one step out of `e` is the `R_a`-pair `(e, a)`. -/
theorem sigA_mem_a : sigA ∈ F2.lawHist W3e.a := by
  refine (NomicFrame.mem_lawHist_ofStepFamily_iff W3e.a sigA).mpr fun n => ?_
  rcases lt_trichotomy n 0 with hn | hn | hn
  · have h1 : n ≤ 0 := by omega
    have h2 : n + 1 ≤ 0 := by omega
    simp [sigA, h1, h2, R2]
  · subst hn
    simp [sigA, R2]
  · have h1 : ¬ (n ≤ 0) := by omega
    have h2 : ¬ (n + 1 ≤ 0) := by omega
    simp [sigA, h1, h2, R2]

/-- `σ_b` is a law-history at `b`: its one step out of `e` is the `R_b`-pair `(e, b)`. -/
theorem sigB_mem_b : sigB ∈ F2.lawHist W3e.b := by
  refine (NomicFrame.mem_lawHist_ofStepFamily_iff W3e.b sigB).mpr fun n => ?_
  rcases lt_trichotomy n 0 with hn | hn | hn
  · have h1 : n ≤ 0 := by omega
    have h2 : n + 1 ≤ 0 := by omega
    simp [sigB, h1, h2, R2]
  · subst hn
    simp [sigB, R2]
  · have h1 : ¬ (n ≤ 0) := by omega
    have h2 : ¬ (n + 1 ≤ 0) := by omega
    simp [sigB, h1, h2, R2]

/-- `σ_b` is **not** a law-history at `a`: its step at time `0` would need the `R_a`-pair
`(e, b)`, which the relation does not contain. -/
theorem sigB_not_mem_a : sigB ∉ F2.lawHist W3e.a := by
  intro h
  have hstep := (NomicFrame.mem_lawHist_ofStepFamily_iff W3e.a sigB).mp h 0
  simp [sigB, R2] at hstep

/--
Witness 2 is **not** *Static*, so *Lawful* does not imply *Static* — the second gap of
`prop:nomic-hierarchy`.

`σ_a` is a law-history at `a`, hence nomologically possible, and it occupies `e` at time `0` and
`a` at time `1`. *Static* would therefore equate `H_F^e` with `H_F^a`. But `σ_b` lies in `H_F^b`,
hence in `H_F^e`, and not in `H_F^a` — its step out of `e` goes to `b`, which `R_a` forbids.
-/
theorem F2_not_static : ¬ F2.Static := by
  intro h
  have hmem : sigA ∈ F2.HF := Set.mem_iUnion.mpr ⟨W3e.a, sigA_mem_a⟩
  -- `sigA 0` and `sigA 1` reduce to `e` and `a`, so this is the equation of the two sets.
  have heq : F2.lawHist W3e.e = F2.lawHist W3e.a := h sigA hmem 0 1
  exact sigB_not_mem_a ((Set.ext_iff.mp heq sigB).mp (F2_lawHist_b_subset_e sigB_mem_b))

end NomicHierarchy

/--
`prop:nomic-hierarchy`, bundled: *Static* does not imply *Lawful*, *Lawful* does not imply
*Static*, and *Static* together with *Lawful* does not imply *Uniform*.

With `NomicFrame.static_of_uniform` and `NomicFrame.lawful_of_uniform` (in `Nomic/Frame.lean`),
this is the whole of the proposition: *Uniform* is strictly strongest, and *Static* and *Lawful*
are independent of each other. Each existential bundles its witness's regularity instance, so the
statement asserts that the separating frames really are nomic frames in the sense of
`def:nomic-frame` and not merely relation families.

The three witnesses and their per-witness independence theorems live in
`FormalSystem.Semantics.NomicHierarchy`; this theorem only collects them.

**Choice dependence, recorded honestly.** Choice-dependent, at one place per witness: each member
frame's *Saturation* comes from `TaskFrame.saturation_of_finite` through
`FrameOver.ofStep_isRegular`. `rmk:choice` does not cover the nomic results.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem nomic_hierarchy :
    (∃ F : NomicFrame intOrder, ∃ _ : F.IsRegular, F.Static ∧ ¬ F.Lawful) ∧
    (∃ F : NomicFrame intOrder, ∃ _ : F.IsRegular, F.Lawful ∧ ¬ F.Static) ∧
    (∃ F : NomicFrame intOrder, ∃ _ : F.IsRegular, F.Static ∧ F.Lawful ∧ ¬ F.Uniform) :=
  ⟨⟨NomicHierarchy.F1,
      NomicFrame.ofStepFamily_isRegular NomicHierarchy.R1 NomicHierarchy.R1_fwd
        NomicHierarchy.R1_bwd,
      NomicHierarchy.F1_static, NomicHierarchy.F1_not_lawful⟩,
    ⟨NomicHierarchy.F2,
      NomicFrame.ofStepFamily_isRegular NomicHierarchy.R2 NomicHierarchy.R2_fwd
        NomicHierarchy.R2_bwd,
      NomicHierarchy.F2_lawful, NomicHierarchy.F2_not_static⟩,
    ⟨NomicHierarchy.F3,
      NomicFrame.ofStepFamily_isRegular NomicHierarchy.R3 NomicHierarchy.R3_fwd
        NomicHierarchy.R3_bwd,
      NomicHierarchy.F3_static, NomicHierarchy.F3_lawful, NomicHierarchy.F3_not_uniform⟩⟩

end FormalSystem.Semantics
