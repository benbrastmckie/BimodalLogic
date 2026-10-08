/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Set.Finite.Lattice
import Mathlib.Logic.Denumerable
import Mathlib.Data.Fintype.Pigeonhole

/-!
# Infinite Ramsey for pairs

**Infinite Ramsey's theorem for pairs**: every finite colouring of the increasing pairs of
natural numbers admits an infinite set on which the colour is constant — stated here with the
set given by a strictly monotone enumeration `g : ℕ → ℕ`
(`Nat.exists_strictMono_const_pair_colour`).

**Mathlib does not carry this at pin `v4.33.0-rc1`.** `Mathlib/Combinatorics/Hindman.lean` and
`Mathlib/Combinatorics/HalesJewett.lean` are the only files that mention the classical theorem,
and both only in passing (Hindman's theorem and the Hales–Jewett theorem are present; infinite
Ramsey for pairs is not), so the theorem is proved here from scratch.

## Main results

* `Nat.exists_strictMono_const_pair_colour` — infinite Ramsey for pairs, self-contained.

## The proof

Descending chain of infinite sets by `Exists.choose`: at each stage pick a least-available
point `a` and, by pigeonhole over the finite colour type, an infinite subset of the remaining
points on which `c a ·` is constant. The chosen points form a *pre-homogeneous* sequence (the
colour of a pair depends only on its first element); a second pigeonhole
(`Finite.exists_infinite_fiber`) picks the colour that occurs infinitely often, and the
corresponding positions are enumerated monotonically by `Nat.Subtype.ofNat`, which needs no
import beyond the three above. `Nat.nth` (`Mathlib.Data.Nat.Nth`, available in this project's
build) is an alternative enumerator that was not required.

## Naming

The name follows Mathlib's `exists_<witness-shape>_<property>` convention: the witness is a
`StrictMono` enumeration and the property is a constant pair colour. It lives in the `Nat`
namespace because the coloured pairs are pairs of naturals.

## References

* [K. Doets, *Completeness and Definability: Applications of the Ehrenfeucht Game in Second-Order
  and Intensional Logic*][doets1987], ch. 7 (pp. 89–93).
-/

namespace Nat

section Ramsey

variable {C : Type} [Finite C]

private theorem ramsey_step_exists (c : ℕ → ℕ → C) (S : Set ℕ) (hS : S.Infinite) :
    ∃ (a : ℕ) (d : C) (S' : Set ℕ),
      S'.Infinite ∧ a ∈ S ∧ S' ⊆ S ∧ ∀ x ∈ S', a < x ∧ c a x = d := by
  obtain ⟨a, haS⟩ := hS.nonempty
  have hT : ({x ∈ S | a < x}).Infinite := by
    have h_eq : {x ∈ S | a < x} = S \ {x | x ≤ a} := by
      ext x; simp [not_le]
    rw [h_eq]
    exact hS.sdiff (Set.finite_le_nat a)
  have h_pigeon : ∃ d : C, {x ∈ {x ∈ S | a < x} | c a x = d}.Infinite := by
    by_contra h
    have h' : ∀ d : C, {x ∈ {x ∈ S | a < x} | c a x = d}.Finite := by
      intro d
      rcases Set.finite_or_infinite {x ∈ {x ∈ S | a < x} | c a x = d} with hf | hi
      · exact hf
      · exact absurd ⟨d, hi⟩ h
    have h_cover : {x ∈ S | a < x} ⊆ ⋃ d : C, {x ∈ {x ∈ S | a < x} | c a x = d} := by
      intro x hx
      exact Set.mem_iUnion.mpr ⟨c a x, hx, rfl⟩
    exact hT (Set.Finite.subset (Set.finite_iUnion h') h_cover)
  obtain ⟨d, hd⟩ := h_pigeon
  exact ⟨a, d, _, hd, haS, fun x hx => hx.1.1, fun x hx => ⟨hx.1.2, hx.2⟩⟩

private noncomputable def ramseyNext (c : ℕ → ℕ → C) (S : {S : Set ℕ // S.Infinite}) :
    ℕ × C × {S : Set ℕ // S.Infinite} :=
  let h := ramsey_step_exists c S.1 S.2
  ⟨h.choose, h.choose_spec.choose,
    ⟨h.choose_spec.choose_spec.choose, h.choose_spec.choose_spec.choose_spec.1⟩⟩

private theorem ramseyNext_spec (c : ℕ → ℕ → C) (S : {S : Set ℕ // S.Infinite}) :
    (ramseyNext c S).1 ∈ S.1 ∧ (ramseyNext c S).2.2.1 ⊆ S.1 ∧
      ∀ x ∈ (ramseyNext c S).2.2.1,
        (ramseyNext c S).1 < x ∧ c (ramseyNext c S).1 x = (ramseyNext c S).2.1 := by
  have h := (ramsey_step_exists c S.1 S.2).choose_spec.choose_spec.choose_spec
  exact ⟨h.2.1, h.2.2.1, h.2.2.2⟩

private noncomputable def ramseyChain (c : ℕ → ℕ → C) : ℕ → {S : Set ℕ // S.Infinite}
  | 0 => ⟨Set.univ, Set.infinite_univ⟩
  | n + 1 => (ramseyNext c (ramseyChain c n)).2.2

private noncomputable def ramseySeq (c : ℕ → ℕ → C) (n : ℕ) : ℕ :=
  (ramseyNext c (ramseyChain c n)).1

private noncomputable def ramseyCol (c : ℕ → ℕ → C) (n : ℕ) : C :=
  (ramseyNext c (ramseyChain c n)).2.1

private theorem ramseyChain_succ_subset (c : ℕ → ℕ → C) (n : ℕ) :
    (ramseyChain c (n + 1)).1 ⊆ (ramseyChain c n).1 :=
  (ramseyNext_spec c (ramseyChain c n)).2.1

private theorem ramseyChain_antitone (c : ℕ → ℕ → C) {m n : ℕ} (h : m ≤ n) :
    (ramseyChain c n).1 ⊆ (ramseyChain c m).1 := by
  induction n with
  | zero => cases Nat.le_zero.mp h; exact fun x hx => hx
  | succ n ih =>
    rcases Nat.lt_or_ge m (n + 1) with hlt | hge
    · exact fun x hx => ih (Nat.lt_succ_iff.mp hlt) (ramseyChain_succ_subset c n hx)
    · cases Nat.le_antisymm h hge; exact fun x hx => hx

private theorem ramseySeq_mem (c : ℕ → ℕ → C) (n : ℕ) :
    ramseySeq c n ∈ (ramseyChain c n).1 :=
  (ramseyNext_spec c (ramseyChain c n)).1

private theorem ramsey_mem_succ_prop (c : ℕ → ℕ → C) (n : ℕ) :
    ∀ x ∈ (ramseyChain c (n + 1)).1,
      ramseySeq c n < x ∧ c (ramseySeq c n) x = ramseyCol c n :=
  (ramseyNext_spec c (ramseyChain c n)).2.2

private theorem ramseySeq_pair_col (c : ℕ → ℕ → C) {m n : ℕ} (h : m < n) :
    ramseySeq c m < ramseySeq c n ∧
      c (ramseySeq c m) (ramseySeq c n) = ramseyCol c m := by
  have h_mem : ramseySeq c n ∈ (ramseyChain c (m + 1)).1 :=
    ramseyChain_antitone c (Nat.succ_le_of_lt h) (ramseySeq_mem c n)
  exact ramsey_mem_succ_prop c m _ h_mem

/-- **Infinite Ramsey for pairs**: every finite colouring of increasing pairs of naturals
admits a strictly monotone subsequence on which the colour is constant. -/
theorem exists_strictMono_const_pair_colour (c : ℕ → ℕ → C) :
    ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, ∀ i j : ℕ, i < j → c (g i) (g j) = τ := by
  obtain ⟨τ, hτ⟩ := Finite.exists_infinite_fiber (ramseyCol c)
  classical
  haveI h_inf : Infinite (setOf fun n => ramseyCol c n = τ) := by
    refine Infinite.of_injective
      (fun x : (ramseyCol c ⁻¹' {τ}) =>
        (⟨x.1, ?_⟩ : setOf fun n => ramseyCol c n = τ)) ?_
    · exact x.2
    · intro a b hab
      exact Subtype.ext (congrArg Subtype.val hab)
  let e : ℕ → (setOf fun n => ramseyCol c n = τ) := Nat.Subtype.ofNat _
  have he_mono : StrictMono fun i => (e i : ℕ) := by
    apply strictMono_nat_of_lt_succ
    intro n
    exact Nat.Subtype.lt_succ_self (e n)
  have h_seq_mono : StrictMono (ramseySeq c) :=
    strictMono_nat_of_lt_succ fun n => (ramseySeq_pair_col c (Nat.lt_succ_self n)).1
  refine ⟨fun i => ramseySeq c (e i : ℕ), h_seq_mono.comp he_mono, τ, ?_⟩
  intro i j hij
  have h_lt : (e i : ℕ) < (e j : ℕ) := he_mono hij
  have h_col : ramseyCol c (e i : ℕ) = τ := (e i).property
  rw [(ramseySeq_pair_col c h_lt).2, h_col]

end Ramsey

end Nat
