/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Decide

/-!
# Bounded Enumeration of Annotated Bi-Lassos

`boundedAnnots` lists every annotated bi-lasso whose three segments are bounded by `n` and which
passes both decidable filters. It is the search space the decision procedure ranges over.

## Honest accounting of the size

The enumeration is `(P.card)^(3n)` raw state triples, and for each surviving lasso
`(2^k)^(|back| + |mid| + |fwd|)` label assignments with `k = subformulaClosureCard φ`. That is
`P.card · 2^k` choices *per position*, and it is astronomically impractical.

This is a **decidability** construction, not an algorithm. It establishes that satisfiability in
a presented ℤ-frame is decidable; it does not establish that it is feasibly decidable, and
nothing here should be read as a complexity claim. The `#eval` smoke tests below are deliberately
confined to a one-state presentation, a two-formula closure and `n = 1`, which is the size at
which the enumeration finishes instantly.

## Structure equality

Both completeness proofs finish by observing that a structure rebuilt from its own fields is the
structure: the data fields are literally the originals and the remaining fields are `Prop`s,
hence equal by proof irrelevance. No extensionality lemma is needed.

## Main Definitions

- `ListEnum.ofLen` / `ListEnum.upTo` — all lists of a given (or bounded) length over a universe
- `boundedBiLassos` — every coherent bi-lasso with segments bounded by `n`
- `boundedAnnots` — every locally coherent, fulfilling annotated bi-lasso with segments bounded
  by `n`

## Main Results

- `mem_boundedBiLassos` / `boundedBiLassos_sound` — completeness and soundness for lassos
- `mem_boundedAnnots` / `boundedAnnots_sound` — completeness and soundness for annotations
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

/-! ## Enumerating lists over a finite universe -/

namespace ListEnum

variable {α : Type*}

/-- Every list of exactly length `k` with entries drawn from `u`. -/
def ofLen (u : List α) : ℕ → List (List α)
  | 0 => [[]]
  | k + 1 => (ofLen u k).flatMap (fun l => u.map (fun a => a :: l))

/-- Every list of length at most `n` with entries drawn from `u`. -/
def upTo (u : List α) (n : ℕ) : List (List α) :=
  (List.range (n + 1)).flatMap (ofLen u)

theorem length_of_mem_ofLen {u : List α} : ∀ {k : ℕ} {l : List α}, l ∈ ofLen u k → l.length = k := by
  intro k
  induction k with
  | zero => intro l hl; simp only [ofLen, List.mem_singleton] at hl; simp [hl]
  | succ k ih =>
    intro l hl
    simp only [ofLen, List.mem_flatMap, List.mem_map] at hl
    obtain ⟨l', hl', a, _, rfl⟩ := hl
    simp [ih hl']

theorem mem_ofLen {u : List α} : ∀ (l : List α), (∀ a ∈ l, a ∈ u) → l ∈ ofLen u l.length := by
  intro l
  induction l with
  | nil => intro _; simp [ofLen]
  | cons a l ih =>
    intro hmem
    simp only [List.length_cons, ofLen, List.mem_flatMap, List.mem_map]
    exact ⟨l, ih (fun b hb => hmem b (List.mem_cons_of_mem a hb)),
      a, hmem a (List.mem_cons_self ..), rfl⟩

theorem mem_upTo {u : List α} {l : List α} {n : ℕ} (hlen : l.length ≤ n)
    (hmem : ∀ a ∈ l, a ∈ u) : l ∈ upTo u n := by
  simp only [upTo, List.mem_flatMap]
  exact ⟨l.length, List.mem_range.mpr (by omega), mem_ofLen l hmem⟩

theorem length_of_mem_upTo {u : List α} {l : List α} {n : ℕ} (h : l ∈ upTo u n) :
    l.length ≤ n := by
  simp only [upTo, List.mem_flatMap] at h
  obtain ⟨k, hk, hl⟩ := h
  rw [length_of_mem_ofLen hl]
  exact Nat.lt_succ_iff.mp (List.mem_range.mp hk)

end ListEnum

/-! ## Enumerating bi-lassos -/

variable {P : IntPresentation} {φ : Formula} {bx : Formula → Bool}

/-- A raw candidate: three segment lists, before any condition is imposed. -/
abbrev RawLasso (P : IntPresentation) :=
  List (Fin P.card) × List (Fin P.card) × List (Fin P.card)

/-- Every raw triple with all three segments bounded by `n`. -/
def rawLassos (P : IntPresentation) (n : ℕ) : List (RawLasso P) :=
  (ListEnum.upTo (List.finRange P.card) n).flatMap (fun b =>
    (ListEnum.upTo (List.finRange P.card) n).flatMap (fun m =>
      (ListEnum.upTo (List.finRange P.card) n).map (fun f => (b, m, f))))

theorem mem_rawLassos {n : ℕ} {t : RawLasso P}
    (hb : t.1.length ≤ n) (hm : t.2.1.length ≤ n) (hf : t.2.2.length ≤ n) :
    t ∈ rawLassos P n := by
  obtain ⟨b, m, f⟩ := t
  simp only [rawLassos, List.mem_flatMap, List.mem_map]
  exact ⟨b, ListEnum.mem_upTo hb (fun a _ => List.mem_finRange a),
    m, ListEnum.mem_upTo hm (fun a _ => List.mem_finRange a),
    f, ListEnum.mem_upTo hf (fun a _ => List.mem_finRange a), rfl⟩

theorem length_of_mem_rawLassos {n : ℕ} {t : RawLasso P} (h : t ∈ rawLassos P n) :
    t.1.length ≤ n ∧ t.2.1.length ≤ n ∧ t.2.2.length ≤ n := by
  obtain ⟨b, m, f⟩ := t
  simp only [rawLassos, List.mem_flatMap, List.mem_map] at h
  obtain ⟨b', hb', m', hm', f', hf', heq⟩ := h
  cases heq
  exact ⟨ListEnum.length_of_mem_upTo hb', ListEnum.length_of_mem_upTo hm',
    ListEnum.length_of_mem_upTo hf'⟩

/-- The `BiLasso` structure's own three conditions, as a decidable predicate on a raw triple. -/
def IsLasso (P : IntPresentation) (t : RawLasso P) : Prop :=
  t.1 ≠ [] ∧ t.2.2 ≠ [] ∧
    ∀ i : Fin (t.1.length + 1 + t.2.1.length + t.2.2.length),
      P.step (BiLasso.unrollOf P t.1 t.2.1 t.2.2 (BiLasso.windowTime P t.1 i))
        (BiLasso.unrollOf P t.1 t.2.1 t.2.2 (BiLasso.windowTime P t.1 i + 1)) = true

instance instDecidableIsLasso (P : IntPresentation) : DecidablePred (IsLasso P) := by
  intro t
  dsimp only [IsLasso]
  infer_instance

/-- **Every coherent bi-lasso with segments bounded by `n`.** -/
def boundedBiLassos (P : IntPresentation) (n : ℕ) : List (BiLasso P) :=
  (rawLassos P n).filterMap (fun t =>
    if h : IsLasso P t then some ⟨t.1, t.2.1, t.2.2, h.1, h.2.1, h.2.2⟩ else none)

/-- **Completeness.** Every bi-lasso whose segments are bounded by `n` is enumerated. -/
theorem mem_boundedBiLassos {n : ℕ} (L : BiLasso P)
    (hb : L.back.length ≤ n) (hm : L.mid.length ≤ n) (hf : L.fwd.length ≤ n) :
    L ∈ boundedBiLassos P n := by
  have hraw : (L.back, L.mid, L.fwd) ∈ rawLassos P n := mem_rawLassos hb hm hf
  have hcond : IsLasso P (L.back, L.mid, L.fwd) := ⟨L.back_ne, L.fwd_ne, L.coherent⟩
  simp only [boundedBiLassos, List.mem_filterMap]
  exact ⟨(L.back, L.mid, L.fwd), hraw, by rw [dif_pos hcond]⟩

/-- **Soundness.** Every enumerated bi-lasso has segments bounded by `n`. Nothing else needs
proving: membership in the list is membership in `BiLasso P`, so coherence is carried by the
type. -/
theorem boundedBiLassos_sound {n : ℕ} {L : BiLasso P} (h : L ∈ boundedBiLassos P n) :
    L.back.length ≤ n ∧ L.mid.length ≤ n ∧ L.fwd.length ≤ n := by
  simp only [boundedBiLassos, List.mem_filterMap] at h
  obtain ⟨t, ht, heq⟩ := h
  by_cases hc : IsLasso P t
  · rw [dif_pos hc] at heq
    obtain ⟨hb, hm, hf⟩ := length_of_mem_rawLassos ht
    cases heq
    exact ⟨hb, hm, hf⟩
  · rw [dif_neg hc] at heq
    exact absurd heq (by simp)

/-! ## Enumerating annotations over a fixed lasso -/

/-- A raw candidate annotation: three label lists. -/
abbrev RawLabels := List (Finset Formula) × List (Finset Formula) × List (Finset Formula)

/--
Every subset of the closure, computably.

`Finset.powerset` is fine mathematically but its `toList` is noncomputable, which would make the
whole enumeration noncomputable and defeat the purpose. Sublists of the closure's underlying
list give the same collection of `Finset`s and compute.
-/
def closureSubsets (φ : Formula) : List (Finset Formula) :=
  ((Formula.subformulas φ).sublists).map List.toFinset

theorem closureSubsets_sub {φ : Formula} {X : Finset Formula} (h : X ∈ closureSubsets φ) :
    X ⊆ subformulaClosure φ := by
  obtain ⟨l, hl, rfl⟩ := List.mem_map.mp h
  intro a ha
  simp only [subformulaClosure, List.mem_toFinset] at ha ⊢
  exact (List.mem_sublists.mp hl).subset ha

theorem mem_closureSubsets {φ : Formula} {X : Finset Formula} (h : X ⊆ subformulaClosure φ) :
    X ∈ closureSubsets φ := by
  refine List.mem_map.mpr ⟨(Formula.subformulas φ).filter (fun a => decide (a ∈ X)), ?_, ?_⟩
  · exact List.mem_sublists.mpr List.filter_sublist
  · ext a
    simp only [subformulaClosure, List.mem_toFinset, List.mem_filter, decide_eq_true_eq]
    constructor
    · exact fun hx => hx.2
    · intro hx
      exact ⟨List.mem_toFinset.mp (h hx), hx⟩

/-- Every raw label triple with the three given lengths, drawn from the closure's subsets. -/
def rawLabels (φ : Formula) (kb km kf : ℕ) : List RawLabels :=
  (ListEnum.ofLen (closureSubsets φ) kb).flatMap (fun b =>
    (ListEnum.ofLen (closureSubsets φ) km).flatMap (fun m =>
      (ListEnum.ofLen (closureSubsets φ) kf).map (fun f => (b, m, f))))

theorem mem_rawLabels {φ : Formula} {t : RawLabels}
    (hsub : ∀ X ∈ t.1 ++ t.2.1 ++ t.2.2, X ⊆ subformulaClosure φ) :
    t ∈ rawLabels φ t.1.length t.2.1.length t.2.2.length := by
  obtain ⟨b, m, f⟩ := t
  have huniv : ∀ (l : List (Finset Formula)), (∀ X ∈ l, X ⊆ subformulaClosure φ) →
      ∀ X ∈ l, X ∈ closureSubsets φ := by
    intro l hl X hX
    exact mem_closureSubsets (hl X hX)
  simp only [rawLabels, List.mem_flatMap, List.mem_map]
  refine ⟨b, ListEnum.mem_ofLen b (huniv b (fun X hX => hsub X (by simp [hX])) ),
    m, ListEnum.mem_ofLen m (huniv m (fun X hX => hsub X (by simp [hX]))),
    f, ListEnum.mem_ofLen f (huniv f (fun X hX => hsub X (by simp [hX]))), rfl⟩

theorem mem_rawLabels_spec {φ : Formula} {kb km kf : ℕ} {t : RawLabels}
    (h : t ∈ rawLabels φ kb km kf) :
    t.1.length = kb ∧ t.2.1.length = km ∧ t.2.2.length = kf ∧
      ∀ X ∈ t.1 ++ t.2.1 ++ t.2.2, X ⊆ subformulaClosure φ := by
  obtain ⟨b, m, f⟩ := t
  simp only [rawLabels, List.mem_flatMap, List.mem_map] at h
  obtain ⟨b', hb', m', hm', f', hf', heq⟩ := h
  cases heq
  have huniv : ∀ (l : List (Finset Formula)) (k : ℕ),
      l ∈ ListEnum.ofLen (closureSubsets φ) k →
      ∀ X ∈ l, X ⊆ subformulaClosure φ := by
    intro l k hl X hX
    -- membership in the universe is exactly the subset condition
    clear hb' hm' hf'
    induction k generalizing l with
    | zero => simp only [ListEnum.ofLen, List.mem_singleton] at hl; subst hl; simp at hX
    | succ k ih =>
      simp only [ListEnum.ofLen, List.mem_flatMap, List.mem_map] at hl
      obtain ⟨l', hl', a, ha, rfl⟩ := hl
      rcases List.mem_cons.mp hX with rfl | hX'
      · exact closureSubsets_sub ha
      · exact ih l' hl' hX'
  refine ⟨ListEnum.length_of_mem_ofLen hb', ListEnum.length_of_mem_ofLen hm',
    ListEnum.length_of_mem_ofLen hf', fun X hX => ?_⟩
  rcases List.mem_append.mp hX with hX | hX
  · rcases List.mem_append.mp hX with hX | hX
    · exact huniv b _ hb' X hX
    · exact huniv m _ hm' X hX
  · exact huniv f _ hf' X hX

/-- Every locally coherent, fulfilling annotation over a **fixed** lasso. -/
def annotsOf (P : IntPresentation) (φ : Formula) (bx : Formula → Bool) (L : BiLasso P) :
    List (Annot P φ) :=
  (rawLabels φ L.back.length L.mid.length L.fwd.length).filterMap (fun t =>
    if h : t.1.length = L.back.length ∧ t.2.1.length = L.mid.length ∧
        t.2.2.length = L.fwd.length ∧ ∀ X ∈ t.1 ++ t.2.1 ++ t.2.2, X ⊆ subformulaClosure φ then
      let A : Annot P φ := ⟨L, t.1, t.2.1, t.2.2, h.1, h.2.1, h.2.2.1, h.2.2.2⟩
      if LocalCoherent P φ bx A ∧ Fulfilling P φ A then some A else none
    else none)

theorem mem_annotsOf (A : Annot P φ)
    (hloc : LocalCoherent P φ bx A) (hful : Fulfilling P φ A) :
    A ∈ annotsOf P φ bx A.lasso := by
  have hsub := A.label_sub
  have hraw : (A.backLab, A.midLab, A.fwdLab) ∈
      rawLabels φ A.lasso.back.length A.lasso.mid.length A.lasso.fwd.length := by
    have := mem_rawLabels (φ := φ) (t := (A.backLab, A.midLab, A.fwdLab)) hsub
    rwa [A.backLab_length, A.midLab_length, A.fwdLab_length] at this
  have hcond : (A.backLab.length = A.lasso.back.length ∧
      A.midLab.length = A.lasso.mid.length ∧ A.fwdLab.length = A.lasso.fwd.length ∧
      ∀ X ∈ A.backLab ++ A.midLab ++ A.fwdLab, X ⊆ subformulaClosure φ) :=
    ⟨A.backLab_length, A.midLab_length, A.fwdLab_length, hsub⟩
  simp only [annotsOf, List.mem_filterMap]
  refine ⟨(A.backLab, A.midLab, A.fwdLab), hraw, ?_⟩
  rw [dif_pos hcond, if_pos ⟨hloc, hful⟩]

theorem annotsOf_sound {L : BiLasso P} {A : Annot P φ} (h : A ∈ annotsOf P φ bx L) :
    A.lasso = L ∧ LocalCoherent P φ bx A ∧ Fulfilling P φ A := by
  simp only [annotsOf, List.mem_filterMap] at h
  obtain ⟨t, _, heq⟩ := h
  by_cases hc : t.1.length = L.back.length ∧ t.2.1.length = L.mid.length ∧
      t.2.2.length = L.fwd.length ∧ ∀ X ∈ t.1 ++ t.2.1 ++ t.2.2, X ⊆ subformulaClosure φ
  · rw [dif_pos hc] at heq
    by_cases hf : LocalCoherent P φ bx ⟨L, t.1, t.2.1, t.2.2, hc.1, hc.2.1, hc.2.2.1, hc.2.2.2⟩ ∧
        Fulfilling P φ ⟨L, t.1, t.2.1, t.2.2, hc.1, hc.2.1, hc.2.2.1, hc.2.2.2⟩
    · rw [if_pos hf] at heq
      cases heq
      exact ⟨rfl, hf.1, hf.2⟩
    · rw [if_neg hf] at heq
      exact absurd heq (by simp)
  · rw [dif_neg hc] at heq
    exact absurd heq (by simp)

/-! ## The full enumeration -/

/-- **Every locally coherent, fulfilling annotated bi-lasso with segments bounded by `n`.** -/
def boundedAnnots (P : IntPresentation) (φ : Formula) (bx : Formula → Bool) (n : ℕ) :
    List (Annot P φ) :=
  (boundedBiLassos P n).flatMap (annotsOf P φ bx)

/-- **Completeness of the annotated enumeration.** -/
theorem mem_boundedAnnots {n : ℕ} (A : Annot P φ)
    (hb : A.lasso.back.length ≤ n) (hm : A.lasso.mid.length ≤ n) (hf : A.lasso.fwd.length ≤ n)
    (hloc : LocalCoherent P φ bx A) (hful : Fulfilling P φ A) :
    A ∈ boundedAnnots P φ bx n := by
  simp only [boundedAnnots, List.mem_flatMap]
  exact ⟨A.lasso, mem_boundedBiLassos A.lasso hb hm hf, mem_annotsOf A hloc hful⟩

/-- **Soundness of the annotated enumeration.** Everything listed genuinely passes both filters
and has segments bounded by `n`. -/
theorem boundedAnnots_sound {n : ℕ} {A : Annot P φ} (h : A ∈ boundedAnnots P φ bx n) :
    LocalCoherent P φ bx A ∧ Fulfilling P φ A ∧
      A.lasso.back.length ≤ n ∧ A.lasso.mid.length ≤ n ∧ A.lasso.fwd.length ≤ n := by
  simp only [boundedAnnots, List.mem_flatMap] at h
  obtain ⟨L, hL, hA⟩ := h
  obtain ⟨hlas, hloc, hful⟩ := annotsOf_sound hA
  obtain ⟨hb, hm, hf⟩ := boundedBiLassos_sound hL
  rw [← hlas] at hb hm hf
  exact ⟨hloc, hful, hb, hm, hf⟩

end FormalSystem.Metalogic.Decidability
