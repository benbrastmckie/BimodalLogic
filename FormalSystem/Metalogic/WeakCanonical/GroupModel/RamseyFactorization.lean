/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.GroupModel.MonoDiscrete
import FormalSystem.Metalogic.WeakCanonical.GroupModel.GoodGroupable
import Mathlib.Data.Set.Finite.Lattice
import Mathlib.Logic.Denumerable
import Mathlib.Data.Fintype.Pigeonhole

/-!
# Ramsey factorization and per-block inflation

The inflation step of the companion-lemma chain (Doets 1987 ch. 7 read with the
non-Archimedean target; see `GroupModel/BlockDecomposition.lean` for the chain overview):
every coloured `ℤ`-block absorbs a suitably coloured copy of `ℚ ×ₗ ℤ` appended at either end,
invisibly at depth `k`.

The route is Ramseyan factorization. Infinite Ramsey for pairs — **absent from Mathlib at
this pin** (Hindman and Hales–Jewett are present; the classical infinite Ramsey theorem is
not) — is proved from scratch here (`infinite_ramsey_pairs`). Colouring increasing pairs of
positions by the depth-`k` type of the enclosed segment then splits the block into a
bi-infinite sequence of segments: `ω*`-many of one type `τ⁻` below, a single middle segment,
and `ω`-many of one type `τ⁺` above. Appending a copy of `ℚ ×ₗ ℤ` coloured periodically by
the word of one `τ⁺`-segment adds `ℚ ×ₗ ζ`-many further `τ⁺`-summands; the mixing lemma
(`kEquiv_orderedSum_of_kEquiv_colour`) reduces the whole comparison to a `≡ₖ` fact about the
`k`-type-coloured index orders `ζ` and `ζ ⊕ₗ (ℚ ×ₗ ζ)`, which the threshold machinery of
`GroupModel/MonoDiscrete.lean` closes: the colourings are constant on each side of a single
pinned anchor, and matched points agree on their region relative to any anchor pair carried
by the invariant.

## Main results

* `infinite_ramsey_pairs` — infinite Ramsey for pairs, self-contained.
* `backForth_of_monoInv_pred` — the threshold master induction with an abstract
  predicate-agreement provider, generalizing `backForth_of_monoInv` beyond constant
  predicates: any predicate whose truth value is determined by the position of a point
  relative to a list of pinned anchor pairs is transported by the invariant.
* `kEquiv_colourStructure_anchored` — coloured index orders that are constant on each side
  of one anchor (and agree at it) are `≡ₖ` for every `k`.
* `inflate_right`, `inflate_left` — per-block inflation: a coloured `ℤ`-block is `≡ₖ` itself
  with a suitably coloured `ℚ ×ₗ ℤ` appended above (resp. below), at the same depth `k`.

## References

- Doets 1987, ch. 1 (1.0.2/1.0.3, pp. 1-22) and ch. 7 (pp. 89-93).
- `literature/Doets_1989_Monadic_Pi11_Theories.md`.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open Order

/-! ## Infinite Ramsey for pairs

Transcribed from the compiled feasibility probe: descending chain of infinite sets by
`Exists.choose`, pre-homogeneous sequence, pigeonhole (`Finite.exists_infinite_fiber`), and
monotone enumeration by `Nat.Subtype.ofNat` (`Mathlib.Data.Nat.Nth` is not in this project's
built cache, so `Nat.nth` is deliberately not used).
-/

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
theorem infinite_ramsey_pairs (c : ℕ → ℕ → C) :
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

/-! ## Successor and predecessor structure on the lexicographic carriers -/

/-- `succ (q, z) = (q, z + 1)`: within a fiber, `ℤ`-steps are covering steps of `ℚ ×ₗ ℤ`. -/
noncomputable instance : SuccOrder (ℚ ×ₗ ℤ) :=
  SuccOrder.ofSuccLeIff (fun x => toLex ((ofLex x).1, (ofLex x).2 + 1)) (by
    intro a b
    rw [Prod.Lex.le_iff, Prod.Lex.lt_iff]
    simp only [ofLex_toLex]
    constructor
    · rintro (h | ⟨h1, h2⟩)
      · exact Or.inl h
      · exact Or.inr ⟨h1, by omega⟩
    · rintro (h | ⟨h1, h2⟩)
      · exact Or.inl h
      · exact Or.inr ⟨h1, by omega⟩)

/-- `pred (q, z) = (q, z - 1)`. -/
noncomputable instance : PredOrder (ℚ ×ₗ ℤ) :=
  PredOrder.ofPredLeIff (fun x => toLex ((ofLex x).1, (ofLex x).2 - 1)) (by
    intro a b
    rw [Prod.Lex.le_iff, Prod.Lex.lt_iff]
    simp only [ofLex_toLex]
    constructor
    · rintro (h | ⟨h1, h2⟩)
      · exact Or.inl h
      · exact Or.inr ⟨h1, by omega⟩
    · rintro (h | ⟨h1, h2⟩)
      · exact Or.inl h
      · exact Or.inr ⟨h1, by omega⟩)

/-- Successors on a lexicographic sum whose left part is unbounded above: the successor
never crosses the seam. -/
instance Sum.Lex.succOrder {α β : Type} [LinearOrder α] [LinearOrder β]
    [SuccOrder α] [NoMaxOrder α] [SuccOrder β] [NoMaxOrder β] :
    SuccOrder (α ⊕ₗ β) :=
  SuccOrder.ofSuccLeIff
    (fun x => match x with
      | Sum.inl a => toLex (Sum.inl (Order.succ a))
      | Sum.inr b => toLex (Sum.inr (Order.succ b)))
    (by
      intro x y
      match x, y with
      | Sum.inl a, Sum.inl a' =>
        show toLex (Sum.inl (Order.succ a)) ≤ toLex (Sum.inl a') ↔
          toLex (Sum.inl a) < toLex (Sum.inl a')
        rw [Sum.Lex.inl_le_inl_iff, Sum.Lex.inl_lt_inl_iff, Order.succ_le_iff]
      | Sum.inl a, Sum.inr b' =>
        show toLex (Sum.inl (Order.succ a)) ≤ toLex (Sum.inr b') ↔
          toLex (Sum.inl a) < toLex (Sum.inr b')
        exact iff_of_true (Sum.Lex.inl_le_inr _ _) (Sum.Lex.inl_lt_inr _ _)
      | Sum.inr b, Sum.inl a' =>
        show toLex (Sum.inr (Order.succ b)) ≤ toLex (Sum.inl a') ↔
          toLex (Sum.inr b) < toLex (Sum.inl a')
        exact iff_of_false Sum.Lex.not_inr_le_inl Sum.Lex.not_inr_lt_inl
      | Sum.inr b, Sum.inr b' =>
        show toLex (Sum.inr (Order.succ b)) ≤ toLex (Sum.inr b') ↔
          toLex (Sum.inr b) < toLex (Sum.inr b')
        rw [Sum.Lex.inr_le_inr_iff, Sum.Lex.inr_lt_inr_iff, Order.succ_le_iff])

/-- Predecessors on a lexicographic sum whose right part is unbounded below: the
predecessor never crosses the seam. -/
instance Sum.Lex.predOrder {α β : Type} [LinearOrder α] [LinearOrder β]
    [PredOrder α] [NoMinOrder α] [PredOrder β] [NoMinOrder β] :
    PredOrder (α ⊕ₗ β) :=
  PredOrder.ofPredLeIff
    (fun x => match x with
      | Sum.inl a => toLex (Sum.inl (Order.pred a))
      | Sum.inr b => toLex (Sum.inr (Order.pred b)))
    (by
      intro x y
      match x, y with
      | Sum.inl a, Sum.inl a' =>
        show toLex (Sum.inl a') ≤ toLex (Sum.inl (Order.pred a)) ↔
          toLex (Sum.inl a') < toLex (Sum.inl a)
        rw [Sum.Lex.inl_le_inl_iff, Sum.Lex.inl_lt_inl_iff, Order.le_pred_iff]
      | Sum.inl a, Sum.inr b' =>
        show toLex (Sum.inr b') ≤ toLex (Sum.inl (Order.pred a)) ↔
          toLex (Sum.inr b') < toLex (Sum.inl a)
        exact iff_of_false Sum.Lex.not_inr_le_inl Sum.Lex.not_inr_lt_inl
      | Sum.inr b, Sum.inl a' =>
        show toLex (Sum.inl a') ≤ toLex (Sum.inr (Order.pred b)) ↔
          toLex (Sum.inl a') < toLex (Sum.inr b)
        exact iff_of_true (Sum.Lex.inl_le_inr _ _) (Sum.Lex.inl_lt_inr _ _)
      | Sum.inr b, Sum.inr b' =>
        show toLex (Sum.inr b') ≤ toLex (Sum.inr (Order.pred b)) ↔
          toLex (Sum.inr b') < toLex (Sum.inr b)
        rw [Sum.Lex.inr_le_inr_iff, Sum.Lex.inr_lt_inr_iff, Order.le_pred_iff])

/-! ## The threshold master with an abstract predicate-agreement provider -/

section AnchoredMaster

variable {sig : MonadicSignature} {M N : OrderedMonadicStructure sig}
variable [SuccOrder M.carrier] [SuccOrder N.carrier]

/--
**The threshold master induction, predicate-generalized.** Instead of requiring every
predicate to be constant on both structures, take any provider `hpred` that, from the
invariant on any pair list extending the pinned anchors `pairs₀`, derives predicate
agreement at matched pairs. Anchor-region predicates (constant on each side of an anchor,
with matching values at it) are the intended instances: the invariant transports order and
equality relative to every anchor pair, which determines the region.

This generalizes `backForth_of_monoInv` (`GroupModel/MonoDiscrete.lean`); the answering
steps are shared with it verbatim.
-/
theorem backForth_of_monoInv_pred [NoMaxOrder M.carrier] [NoMaxOrder N.carrier]
    [PredOrder M.carrier] [PredOrder N.carrier]
    [Nonempty M.carrier] [Nonempty N.carrier]
    (pairs₀ : List (M.carrier × N.carrier))
    (hpred : ∀ (d : ℕ) (pairs : List (M.carrier × N.carrier)), pairs₀ ⊆ pairs →
      MonoInv M N d pairs → ∀ (p : sig.preds) (q : M.carrier × N.carrier), q ∈ pairs →
        (M.interp p q.1 ↔ N.interp p q.2)) :
    ∀ (d : ℕ) (pairs : List (M.carrier × N.carrier)), pairs₀ ⊆ pairs →
      ((∃ p₀ ∈ pairs, (∀ x, p₀.1 ≤ x) ∧ (∀ y, p₀.2 ≤ y)) ∨
        (NoMinOrder M.carrier ∧ NoMinOrder N.carrier)) →
      ∀ (n : ℕ) (eM : Fin n → M.carrier) (eN : Fin n → N.carrier),
        (∀ i, (eM i, eN i) ∈ pairs) → MonoInv M N d pairs →
        BackForth sig d n M N eM eN := by
  intro d
  induction d with
  | zero => intro _ _ _ _ _ _ _ _; trivial
  | succ d ih =>
    intro pairs hsub hbot n eM eN hmem hinv
    have hmem' : ∀ (a : M.carrier) (b : N.carrier),
        ∀ i : Fin (n + 1),
          ((Fin.cons a eM : Fin (n + 1) → M.carrier) i,
            (Fin.cons b eN : Fin (n + 1) → N.carrier) i) ∈ (a, b) :: pairs := by
      intro a b i
      cases i using Fin.cases with
      | zero => simp only [Fin.cons_zero]; exact List.mem_cons_self ..
      | succ j => simp only [Fin.cons_succ]; exact List.mem_cons_of_mem _ (hmem j)
    have hsub' : ∀ (a : M.carrier) (b : N.carrier), pairs₀ ⊆ (a, b) :: pairs :=
      fun _ _ _ hx => List.mem_cons_of_mem _ (hsub hx)
    have hbot' : ∀ (a : M.carrier) (b : N.carrier),
        (∃ p₀ ∈ (a, b) :: pairs, (∀ x, p₀.1 ≤ x) ∧ (∀ y, p₀.2 ≤ y)) ∨
          (NoMinOrder M.carrier ∧ NoMinOrder N.carrier) := by
      intro a b
      rcases hbot with ⟨p₀, hp₀, h1, h2⟩ | h
      · exact Or.inl ⟨p₀, List.mem_cons_of_mem _ hp₀, h1, h2⟩
      · exact Or.inr h
    have hatoms : ∀ (a : M.carrier) (b : N.carrier),
        MonoInv M N d ((a, b) :: pairs) →
        ∀ ak : AtomKind sig (n + 1),
          AtomEval M (Fin.cons a eM) ak ↔ AtomEval N (Fin.cons b eN) ak := by
      intro a b hstep ak
      cases ak with
      | pred p i =>
        exact hpred d ((a, b) :: pairs) (hsub' a b) hstep p _ (hmem' a b i)
      | order i j hne =>
        exact hstep.order_iff (hmem' a b i) (hmem' a b j)
    constructor
    · intro b
      obtain ⟨a, hstep⟩ := monoInv_step hbot hinv b
      exact ⟨a, hatoms a b hstep,
        ih ((a, b) :: pairs) (hsub' a b) (hbot' a b) (n + 1) _ _ (hmem' a b) hstep⟩
    · intro a
      have hbotSwap : (∃ p₀ ∈ pairs.map Prod.swap, (∀ x, p₀.1 ≤ x) ∧ (∀ y, p₀.2 ≤ y)) ∨
          (NoMinOrder N.carrier ∧ NoMinOrder M.carrier) := by
        rcases hbot with ⟨p₀, hp₀, h1, h2⟩ | ⟨h1, h2⟩
        · exact Or.inl ⟨p₀.swap, List.mem_map_of_mem hp₀, h2, h1⟩
        · exact Or.inr ⟨h2, h1⟩
      obtain ⟨b, hstep'⟩ := monoInv_step (M := N) (N := M) hbotSwap (monoInv_swap hinv) a
      have hstep : MonoInv M N d ((a, b) :: pairs) := monoInv_of_swap hstep'
      exact ⟨b, hatoms a b hstep,
        ih ((a, b) :: pairs) (hsub' a b) (hbot' a b) (n + 1) _ _ (hmem' a b) hstep⟩

end AnchoredMaster

/-- **Anchored coloured-order completeness**: two coloured index orders, each constant on
both sides of a single pinned anchor with matching colours (`α` below, `β` at, `γ` above),
are `≡ₖ` at every depth. This is the exact coloured-order obligation left by the mixing
lemma after Ramsey factorization: `ζ` versus `ζ ⊕ₗ (ℚ ×ₗ ζ)` (or its mirror image), with
`τ⁻`-segments below the pinned middle segment and `τ⁺`-segments above. -/
theorem kEquiv_colourStructure_anchored {ι : Type} (k : ℕ) {α β γ : ι}
    (I J : Type) [LinearOrder I] [SuccOrder I] [PredOrder I]
    [NoMaxOrder I] [NoMinOrder I]
    [LinearOrder J] [SuccOrder J] [PredOrder J] [NoMaxOrder J] [NoMinOrder J]
    (aI : I) (aJ : J) {cI : I → ι} {cJ : J → ι}
    (hIlt : ∀ i, i < aI → cI i = α) (hIeq : cI aI = β) (hIgt : ∀ i, aI < i → cI i = γ)
    (hJlt : ∀ j, j < aJ → cJ j = α) (hJeq : cJ aJ = β) (hJgt : ∀ j, aJ < j → cJ j = γ) :
    KEquiv (colourSig ι) k (colourStructure I cI) (colourStructure J cJ) := by
  haveI : SuccOrder (colourStructure I cI).carrier := inferInstanceAs (SuccOrder I)
  haveI : PredOrder (colourStructure I cI).carrier := inferInstanceAs (PredOrder I)
  haveI : NoMaxOrder (colourStructure I cI).carrier := inferInstanceAs (NoMaxOrder I)
  haveI : NoMinOrder (colourStructure I cI).carrier := inferInstanceAs (NoMinOrder I)
  haveI : Nonempty (colourStructure I cI).carrier := ⟨aI⟩
  haveI : SuccOrder (colourStructure J cJ).carrier := inferInstanceAs (SuccOrder J)
  haveI : PredOrder (colourStructure J cJ).carrier := inferInstanceAs (PredOrder J)
  haveI : NoMaxOrder (colourStructure J cJ).carrier := inferInstanceAs (NoMaxOrder J)
  haveI : NoMinOrder (colourStructure J cJ).carrier := inferInstanceAs (NoMinOrder J)
  haveI : Nonempty (colourStructure J cJ).carrier := ⟨aJ⟩
  refine (kEquiv_iff_backForth k _ _).mpr ?_
  refine backForth_of_monoInv_pred [(aI, aJ)] ?_ k [(aI, aJ)]
    (List.Subset.refl _)
    (Or.inr ⟨inferInstanceAs (NoMinOrder I), inferInstanceAs (NoMinOrder J)⟩)
    0 Fin.elim0 Fin.elim0 (fun i => i.elim0) ?_
  · -- the predicate-agreement provider
    intro d pairs hsub hinv z q hq
    have hanchor : ((aI, aJ) :
        (colourStructure I cI).carrier × (colourStructure J cJ).carrier) ∈ pairs :=
      hsub (List.mem_cons_self ..)
    have horder : q.1 < aI ↔ q.2 < aJ := hinv.order_iff hq hanchor
    have heq : (aI = q.1) ↔ (aJ = q.2) :=
      hinv.dist_iff hanchor hq (m := 0) (pow_pos (by norm_num) d)
    show cI q.1 = z ↔ cJ q.2 = z
    rcases lt_trichotomy q.1 aI with hlt | hqe | hgt
    · rw [hIlt _ hlt, hJlt _ (horder.mp hlt)]
    · have h2 : aJ = q.2 := heq.mp hqe.symm
      rw [(congrArg cI hqe).trans hIeq, (congrArg cJ h2.symm).trans hJeq]
    · have hJgt' : aJ < q.2 := by
        rcases lt_trichotomy q.2 aJ with h1 | h1 | h1
        · exact absurd (horder.mpr h1) (not_lt.mpr hgt.le)
        · exact absurd (heq.mpr h1.symm).symm (ne_of_gt hgt)
        · exact h1
      rw [hIgt _ hgt, hJgt _ hJgt']
  · -- the singleton anchor list satisfies the invariant
    intro p hp q hq
    rcases List.mem_cons.mp hp with rfl | hp'
    swap
    · simp at hp'
    rcases List.mem_cons.mp hq with rfl | hq'
    swap
    · simp at hq'
    refine ⟨iff_of_false (lt_irrefl _) (lt_irrefl _), fun m _ => ?_⟩
    exact (succ_iterate_eq_self_iff ((aI, aJ) :
        (colourStructure I cI).carrier × (colourStructure J cJ).carrier).1 m).trans
      (succ_iterate_eq_self_iff ((aI, aJ) :
        (colourStructure I cI).carrier × (colourStructure J cJ).carrier).2 m).symm

end FormalSystem.Metalogic.WeakCanonical
