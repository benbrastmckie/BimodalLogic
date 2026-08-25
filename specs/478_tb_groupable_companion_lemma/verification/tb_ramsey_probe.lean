/-
T-B research probe 2: infinite Ramsey theorem for pairs.

Mathlib (at this pin) has Hindman and Hales-Jewett but NOT the classical infinite
Ramsey theorem for pairs, which the tail-absorption step of the companion lemma
needs (Ramseyan factorization of an ω-word into idempotent-type segments).
This probe proves it from scratch to retire the feasibility risk.
-/
import Mathlib.Data.Set.Finite.Basic
import Mathlib.Data.Set.Finite.Lattice
import Mathlib.Logic.Denumerable
import Mathlib.Data.Fintype.Pigeonhole
import Mathlib.Order.Basic

namespace TBRamseyProbe

variable {C : Type} [Finite C]

/-- One refinement step: from an infinite `S ⊆ ℕ`, extract a base point `a ∈ S`,
a color `d`, and an infinite `S' ⊆ S` above `a` on which `c a ·` is constantly `d`. -/
private theorem step_exists (c : ℕ → ℕ → C) (S : Set ℕ) (hS : S.Infinite) :
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

/-- The refinement step packaged as a function (choice). -/
private noncomputable def next (c : ℕ → ℕ → C) (S : {S : Set ℕ // S.Infinite}) :
    ℕ × C × {S : Set ℕ // S.Infinite} :=
  let h := step_exists c S.1 S.2
  ⟨h.choose, h.choose_spec.choose,
    ⟨h.choose_spec.choose_spec.choose, h.choose_spec.choose_spec.choose_spec.1⟩⟩

private theorem next_spec (c : ℕ → ℕ → C) (S : {S : Set ℕ // S.Infinite}) :
    (next c S).1 ∈ S.1 ∧ (next c S).2.2.1 ⊆ S.1 ∧
      ∀ x ∈ (next c S).2.2.1, (next c S).1 < x ∧ c (next c S).1 x = (next c S).2.1 := by
  have h := (step_exists c S.1 S.2).choose_spec.choose_spec.choose_spec
  exact ⟨h.2.1, h.2.2.1, h.2.2.2⟩

/-- The descending chain of infinite sets. -/
private noncomputable def chain (c : ℕ → ℕ → C) : ℕ → {S : Set ℕ // S.Infinite}
  | 0 => ⟨Set.univ, Set.infinite_univ⟩
  | n + 1 => (next c (chain c n)).2.2

/-- The pre-homogeneous sequence and its colors. -/
private noncomputable def seq (c : ℕ → ℕ → C) (n : ℕ) : ℕ := (next c (chain c n)).1

private noncomputable def col (c : ℕ → ℕ → C) (n : ℕ) : C := (next c (chain c n)).2.1

private theorem chain_succ_subset (c : ℕ → ℕ → C) (n : ℕ) :
    (chain c (n + 1)).1 ⊆ (chain c n).1 :=
  (next_spec c (chain c n)).2.1

private theorem chain_antitone (c : ℕ → ℕ → C) {m n : ℕ} (h : m ≤ n) :
    (chain c n).1 ⊆ (chain c m).1 := by
  induction n with
  | zero => cases Nat.le_zero.mp h; exact fun x hx => hx
  | succ n ih =>
    rcases Nat.lt_or_ge m (n + 1) with hlt | hge
    · exact fun x hx => ih (Nat.lt_succ_iff.mp hlt) (chain_succ_subset c n hx)
    · cases Nat.le_antisymm h hge; exact fun x hx => hx

private theorem seq_mem (c : ℕ → ℕ → C) (n : ℕ) : seq c n ∈ (chain c n).1 :=
  (next_spec c (chain c n)).1

private theorem mem_succ_prop (c : ℕ → ℕ → C) (n : ℕ) :
    ∀ x ∈ (chain c (n + 1)).1, seq c n < x ∧ c (seq c n) x = col c n :=
  (next_spec c (chain c n)).2.2

/-- The key pre-homogeneity: for `m < n`, the pair `(seq m, seq n)` has color `col m`. -/
private theorem seq_pair_col (c : ℕ → ℕ → C) {m n : ℕ} (h : m < n) :
    seq c m < seq c n ∧ c (seq c m) (seq c n) = col c m := by
  have h_mem : seq c n ∈ (chain c (m + 1)).1 :=
    chain_antitone c (Nat.succ_le_of_lt h) (seq_mem c n)
  exact mem_succ_prop c m _ h_mem

/-- **Infinite Ramsey for pairs**: every finite coloring of increasing pairs of
naturals admits a strictly monotone subsequence on which the color is constant. -/
theorem infinite_ramsey_pairs (c : ℕ → ℕ → C) :
    ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, ∀ i j : ℕ, i < j → c (g i) (g j) = τ := by
  -- pigeonhole on the colors of the pre-homogeneous sequence
  obtain ⟨τ, hτ⟩ := Finite.exists_infinite_fiber (col c)
  classical
  haveI h_inf : Infinite (setOf fun n => col c n = τ) := by
    refine Infinite.of_injective (fun x : (col c ⁻¹' {τ}) => (⟨x.1, ?_⟩ : setOf fun n => col c n = τ)) ?_
    · exact x.2
    · intro a b hab
      exact Subtype.ext (congrArg Subtype.val hab)
  let e : ℕ → (setOf fun n => col c n = τ) := Nat.Subtype.ofNat _
  have he_mono : StrictMono fun i => (e i : ℕ) := by
    apply strictMono_nat_of_lt_succ
    intro n
    exact Nat.Subtype.lt_succ_self (e n)
  have h_seq_mono : StrictMono (seq c) :=
    strictMono_nat_of_lt_succ fun n => (seq_pair_col c (Nat.lt_succ_self n)).1
  refine ⟨fun i => seq c (e i : ℕ), h_seq_mono.comp he_mono, τ, ?_⟩
  intro i j hij
  have h_lt : (e i : ℕ) < (e j : ℕ) := he_mono hij
  have h_col : col c (e i : ℕ) = τ := (e i).property
  rw [(seq_pair_col c h_lt).2, h_col]

#print axioms infinite_ramsey_pairs

end TBRamseyProbe
