/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.OrderedSum
import Mathlib.Order.SuccPred.Basic

/-!
# Block decomposition of a countable discrete unbounded structure

Doets 1987, ch. 3 (pp. 36-57, condensations and ordered sums) and ch. 7 step 9 (p. 91): a
countable monadic structure whose flow of time is discrete (`SuccOrder`/`PredOrder`) and
unbounded in both directions (`NoMaxOrder`/`NoMinOrder`) decomposes as an ordered sum of
coloured copies of `ℤ`. The finite-succ-distance equivalence has convex classes; under
`Succ`/`Pred` and unboundedness every class is order-isomorphic to `ℤ` (no `ω`, `ω*` or finite
blocks can occur); and the quotient of classes is a countable linear order `I` indexing the
sum. Predicates are transported to per-block colourings `ℤ → Prop`.

This is the first stage of the companion-lemma chain that ends in
`GroupModel/GroupableCompanion.lean`: the decomposition produced here is inflated per block
(`GroupModel/RamseyFactorization.lean`) and reassembled over a condensation of `ℚ`
(`GroupModel/GroupableCompanion.lean`) into a structure on the full carrier `ℚ ×ₗ ℤ` in the
sense of `GroupModel/GoodGroupable.lean`.

## Main definitions

* A discrete-order toolkit for `Order.succ`/`Order.pred` iterates: interval decomposition
  (`exists_succ_iterate_of_le_of_le`), strict monotonicity in the iterate count, and exactness
  of `pred`/`succ` round trips on unbounded orders.
* `SuccReach` — the finite-succ-distance ("same block") equivalence.
* `BlockQuot` — the linearly ordered quotient of blocks (template:
  `IsConvexEquiv.ClassQuot`/`classLt` in `RealModel/DoetsTheorem.lean`, transcribed for the
  discrete relation).
* `zPoint` — the `ℤ`-action `z ↦ succ^[z] x` (with `pred` for negative `z`) enumerating a
  block.
* `zFiber` — a monadic structure on `ℤ` from a colouring; the summand shape of the
  decomposition.

## Main result

* `blockDecomposition` — `M ≃o Σ_{i ∈ I} (ℤ, cᵢ)` with predicates transported, for a countable
  nonempty index order `I`.

## References

- Doets 1987, ch. 3, pp. 36-57; ch. 7 step 9, p. 91.
- `literature/Doets_1989_Monadic_Pi11_Theories.md` (Lemmas 1.4/1.5 environment).
-/

namespace FormalSystem.Metalogic.WeakCanonical

open Order

/-! ## Discrete-order toolkit: `succ` iterates -/

section SuccToolkit

variable {α : Type} [LinearOrder α] [SuccOrder α]

/-- Iterated `succ` cannot descend: a target strictly below the base is never reached. -/
theorem succ_iterate_ne_of_gt {x y : α} (h : y < x) (n : ℕ) : succ^[n] x ≠ y :=
  fun he => absurd (he ▸ Order.le_succ_iterate n x) (not_le.mpr h)

/-- **Interval decomposition**: any point of `[x, succ^[n] x]` is an iterate of `x`.
This is the convexity engine for blocks and the bridging lemma for distance bookkeeping. -/
theorem exists_succ_iterate_of_le_of_le :
    ∀ (n : ℕ) (x y : α), x ≤ y → y ≤ succ^[n] x → ∃ p, p ≤ n ∧ succ^[p] x = y := by
  intro n
  induction n with
  | zero =>
    intro x y hxy hyx
    exact ⟨0, le_refl 0, le_antisymm hxy (by simpa using hyx)⟩
  | succ n ih =>
    intro x y hxy hyx
    rcases eq_or_lt_of_le hxy with rfl | hlt
    · exact ⟨0, by omega, by simp⟩
    · have h1 : Order.succ x ≤ y := Order.succ_le_of_lt hlt
      have h2 : y ≤ succ^[n] (Order.succ x) := by
        rwa [← Function.iterate_succ_apply]
      obtain ⟨p, hp, hpe⟩ := ih (Order.succ x) y h1 h2
      exact ⟨p + 1, by omega, by rwa [Function.iterate_succ_apply]⟩

end SuccToolkit

section SuccNoMax

variable {α : Type} [LinearOrder α] [SuccOrder α] [NoMaxOrder α]

/-- On an order with no maximum, a positive number of `succ` steps moves strictly up. -/
theorem lt_succ_iterate_of_pos (x : α) {n : ℕ} (hn : 0 < n) : x < succ^[n] x := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  rw [Function.iterate_succ_apply']
  exact lt_of_le_of_lt (Order.le_succ_iterate m x) (Order.lt_succ _)

/-- `succ` iterates from a fixed base are strictly monotone in the iterate count. -/
theorem succ_iterate_lt_succ_iterate (x : α) {m n : ℕ} (h : m < n) :
    succ^[m] x < succ^[n] x := by
  have hn : n = (n - m) + m := by omega
  rw [hn, Function.iterate_add_apply]
  exact lt_succ_iterate_of_pos _ (by omega)

/-- The iterate count reaching a fixed target from a fixed base is unique. -/
theorem succ_iterate_count_inj (x : α) {m n : ℕ}
    (h : succ^[m] x = succ^[n] x) : m = n := by
  rcases lt_trichotomy m n with hlt | he | hgt
  · exact absurd h (ne_of_lt (succ_iterate_lt_succ_iterate x hlt))
  · exact he
  · exact absurd h.symm (ne_of_lt (succ_iterate_lt_succ_iterate x hgt))

/-- Each `succ` iterate is injective on an order with no maximum. -/
theorem succ_iterate_injective (n : ℕ) : Function.Injective (succ^[n] : α → α) :=
  (Order.succ_strictMono.iterate n).injective

/-- `pred` exactly undoes `succ` iterates when there is no maximum. -/
theorem pred_iterate_succ_iterate [PredOrder α] (x : α) (n : ℕ) :
    pred^[n] (succ^[n] x) = x :=
  Order.pred_succ_iterate_of_not_isMax x n (not_isMax _)

end SuccNoMax

section PredNoMin

variable {α : Type} [LinearOrder α] [PredOrder α] [NoMinOrder α]

/-- On an order with no minimum, a positive number of `pred` steps moves strictly down. -/
theorem pred_iterate_lt_of_pos (x : α) {n : ℕ} (hn : 0 < n) : pred^[n] x < x := by
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  rw [Function.iterate_succ_apply']
  exact lt_of_lt_of_le (Order.pred_lt _) (Order.pred_iterate_le m x)

/-- `pred` iterates from a fixed base are strictly antitone in the iterate count. -/
theorem pred_iterate_lt_pred_iterate (x : α) {m n : ℕ} (h : m < n) :
    pred^[n] x < pred^[m] x := by
  have hn : n = (n - m) + m := by omega
  rw [hn, Function.iterate_add_apply]
  exact pred_iterate_lt_of_pos _ (by omega)

/-- `succ` exactly undoes `pred` iterates when there is no minimum. -/
theorem succ_iterate_pred_iterate [SuccOrder α] (x : α) (n : ℕ) :
    succ^[n] (pred^[n] x) = x :=
  Order.succ_pred_iterate_of_not_isMin x n (not_isMin _)

end PredNoMin

/-! ## The block equivalence -/

section Blocks

variable {α : Type} [LinearOrder α] [SuccOrder α] [NoMaxOrder α]

/-- **Finite succ-distance**: `y` is finitely many `succ` steps above `x`, or vice versa.
The classes of this relation are the blocks of the decomposition. -/
def SuccReach (x y : α) : Prop := ∃ n : ℕ, succ^[n] x = y ∨ succ^[n] y = x

omit [NoMaxOrder α] in
theorem SuccReach.refl (x : α) : SuccReach x x := ⟨0, Or.inl rfl⟩

omit [NoMaxOrder α] in
theorem SuccReach.symm {x y : α} (h : SuccReach x y) : SuccReach y x := by
  obtain ⟨n, hn | hn⟩ := h
  · exact ⟨n, Or.inr hn⟩
  · exact ⟨n, Or.inl hn⟩

theorem SuccReach.trans {x y z : α} (hxy : SuccReach x y) (hyz : SuccReach y z) :
    SuccReach x z := by
  obtain ⟨n, hn | hn⟩ := hxy <;> obtain ⟨m, hm | hm⟩ := hyz
  · -- `succ^[n] x = y`, `succ^[m] y = z`
    exact ⟨m + n, Or.inl (by rw [Function.iterate_add_apply, hn, hm])⟩
  · -- `succ^[n] x = y`, `succ^[m] z = y`
    rcases (lt_or_ge n m).symm with hle | hlt
    · refine ⟨n - m, Or.inl ?_⟩
      have hsplit : succ^[m] (succ^[n - m] x) = succ^[m] z := by
        rw [← Function.iterate_add_apply, show m + (n - m) = n by omega, hn, hm]
      exact succ_iterate_injective m hsplit
    · refine ⟨m - n, Or.inr ?_⟩
      have hsplit : succ^[n] (succ^[m - n] z) = succ^[n] x := by
        rw [← Function.iterate_add_apply, show n + (m - n) = m by omega, hm, hn]
      exact succ_iterate_injective n hsplit
  · -- `succ^[n] y = x`, `succ^[m] y = z`
    rcases (lt_or_ge n m).symm with hle | hlt
    · refine ⟨n - m, Or.inr ?_⟩
      calc succ^[n - m] z = succ^[n - m] (succ^[m] y) := by rw [hm]
        _ = x := by rw [← Function.iterate_add_apply, show n - m + m = n by omega]; exact hn
    · refine ⟨m - n, Or.inl ?_⟩
      calc succ^[m - n] x = succ^[m - n] (succ^[n] y) := by rw [hn]
        _ = z := by rw [← Function.iterate_add_apply, show m - n + n = m by omega]; exact hm
  · -- `succ^[n] y = x`, `succ^[m] z = y`
    exact ⟨n + m, Or.inr (by rw [Function.iterate_add_apply, hm, hn])⟩

theorem succReach_equivalence : Equivalence (SuccReach (α := α)) :=
  ⟨SuccReach.refl, SuccReach.symm, SuccReach.trans⟩

omit [NoMaxOrder α] in
/-- **Convexity of blocks**: a point between two block-mates is in the block. -/
theorem succReach_convex {a b c : α} (hab : a ≤ b) (hbc : b ≤ c) (h : SuccReach a c) :
    SuccReach a b := by
  obtain ⟨n, hn | hn⟩ := h
  · obtain ⟨p, _, hp⟩ := exists_succ_iterate_of_le_of_le n a b hab (hn ▸ hbc)
    exact ⟨p, Or.inl hp⟩
  · have hca : c ≤ a := hn ▸ Order.le_succ_iterate n c
    have hac : a = c := le_antisymm (hab.trans hbc) hca
    have hb : b = a := le_antisymm (hac ▸ hbc) hab
    exact ⟨0, Or.inl (by simpa using hb.symm)⟩

/-- **`a`'s block lies strictly below `b`'s** — the relation the block quotient is ordered by,
before it is known to descend. -/
def blockLtPt (a b : α) : Prop := a < b ∧ ¬ SuccReach a b

/-- **`blockLtPt` is `SuccReach`-invariant in both arguments**: two distinct blocks are totally
separated, not merely separated at chosen representatives. Convexity rules out interleaving. -/
theorem blockLtPt_congr {a a' b b' : α}
    (ha : SuccReach a a') (hb : SuccReach b b')
    (hlt : blockLtPt a b) : blockLtPt a' b' := by
  obtain ⟨hab, hnab⟩ := hlt
  have hna'b' : ¬ SuccReach a' b' := fun hc =>
    hnab (ha.trans (hc.trans hb.symm))
  refine ⟨?_, hna'b'⟩
  rcases lt_trichotomy a' b' with hlt' | heq' | hgt'
  · exact hlt'
  · exact absurd (heq' ▸ SuccReach.refl a') hna'b'
  · -- `b' < a'` is impossible: it forces `a`'s and `b`'s blocks to meet.
    exfalso
    rcases lt_or_ge a b' with hab' | hb'a
    · -- `a < b' < a'` with `a ~ a'`, so `a ~ b'` by convexity.
      have hab'' : SuccReach a b' :=
        succReach_convex (le_of_lt hab') (le_of_lt hgt') ha
      exact hnab (hab''.trans hb.symm)
    · -- `b' ≤ a < b` with `b' ~ b`, so `b' ~ a` by convexity.
      have hb'a' : SuccReach b' a :=
        succReach_convex hb'a (le_of_lt hab) hb.symm
      exact hnab ((hb'a'.symm).trans hb.symm)

/-- Total separation of distinct blocks, extracted from `blockLtPt_congr`. -/
theorem lt_of_blockLtPt {a b a' b' : α} (h : blockLtPt a b)
    (ha : SuccReach a a') (hb : SuccReach b b') : a' < b' :=
  (blockLtPt_congr ha hb h).1

end Blocks

/-! ## The block quotient as a linear order -/

section BlockQuot

variable (α : Type) [LinearOrder α] [SuccOrder α] [NoMaxOrder α]

/-- The setoid of blocks. -/
def blockSetoid : Setoid α where
  r := SuccReach
  iseqv := succReach_equivalence

/-- **The block quotient** — the type of blocks of `α`. -/
abbrev BlockQuot : Type := Quotient (blockSetoid α)

variable {α}

/-- The block of a point. -/
abbrev blockMk (x : α) : BlockQuot α := Quotient.mk (blockSetoid α) x

theorem blockMk_eq_blockMk_iff {a b : α} : blockMk a = blockMk b ↔ SuccReach a b :=
  Quotient.eq

/-- The strict order on blocks, descended from `blockLtPt` by `blockLtPt_congr`. -/
def blockLt : BlockQuot α → BlockQuot α → Prop :=
  Quotient.lift₂ blockLtPt fun _ _ _ _ ha hb =>
    propext ⟨fun hh => blockLtPt_congr ha hb hh,
      fun hh => blockLtPt_congr ha.symm hb.symm hh⟩

@[simp] theorem blockLt_blockMk {a b : α} :
    blockLt (blockMk a) (blockMk b) ↔ blockLtPt a b := Iff.rfl

theorem blockLt_irrefl (A : BlockQuot α) : ¬ blockLt A A :=
  Quotient.inductionOn A fun a hh => absurd hh.1 (lt_irrefl a)

theorem blockLt_trans {A B C : BlockQuot α} :
    blockLt A B → blockLt B C → blockLt A C := by
  refine Quotient.inductionOn₃ A B C fun a b c hab hbc => ?_
  obtain ⟨hab₁, hab₂⟩ := hab
  obtain ⟨hbc₁, _⟩ := hbc
  exact ⟨lt_trans hab₁ hbc₁,
    fun hac => hab₂ (succReach_convex (le_of_lt hab₁) (le_of_lt hbc₁) hac)⟩

theorem blockLt_trichotomous (A B : BlockQuot α) :
    blockLt A B ∨ A = B ∨ blockLt B A := by
  refine Quotient.inductionOn₂ A B fun a b => ?_
  by_cases hab : SuccReach a b
  · exact Or.inr (Or.inl (Quotient.sound hab))
  · rcases lt_trichotomy a b with hlt | heq | hgt
    · exact Or.inl ⟨hlt, hab⟩
    · exact absurd (heq ▸ SuccReach.refl a) hab
    · exact Or.inr (Or.inr ⟨hgt, fun hc => hab hc.symm⟩)

open scoped Classical in
/-- **The block quotient is a linear order.** `blockLt` is irreflexive, transitive and
trichotomous, so this is `linearOrderOfSTO` and nothing more. -/
noncomputable instance instLinearOrderBlockQuot : LinearOrder (BlockQuot α) :=
  letI : IsTrans (BlockQuot α) blockLt := ⟨fun _ _ _ => blockLt_trans⟩
  letI : IsIrrefl (BlockQuot α) blockLt := ⟨blockLt_irrefl⟩
  letI : IsTrichotomous (BlockQuot α) blockLt := ⟨fun a b hab hba => by
    rcases blockLt_trichotomous a b with hc | hc | hc
    · exact absurd hc hab
    · exact hc
    · exact absurd hc hba⟩
  letI : IsStrictOrder (BlockQuot α) blockLt := {}
  letI : IsStrictTotalOrder (BlockQuot α) blockLt := {}
  letI : DecidableRel (blockLt (α := α)) := fun _ _ => Classical.dec _
  linearOrderOfSTO blockLt

theorem blockMk_lt_blockMk {a b : α} :
    blockMk a < blockMk b ↔ blockLtPt a b := Iff.rfl

end BlockQuot

/-! ## The `ℤ`-action enumerating a block -/

section ZPoint

variable {α : Type} [LinearOrder α] [SuccOrder α] [PredOrder α]
  [NoMaxOrder α] [NoMinOrder α]

/-- The point `z` steps from `x`: `succ` iterates for `z ≥ 0`, `pred` iterates for `z < 0`. -/
noncomputable def zPoint (x : α) (z : ℤ) : α :=
  if 0 ≤ z then succ^[z.toNat] x else pred^[(-z).toNat] x

omit [NoMaxOrder α] [NoMinOrder α] in
@[simp] theorem zPoint_natCast (x : α) (n : ℕ) : zPoint x (n : ℤ) = succ^[n] x := by
  simp [zPoint]

omit [NoMaxOrder α] [NoMinOrder α] in
@[simp] theorem zPoint_zero (x : α) : zPoint x 0 = x := by simp [zPoint]

omit [NoMaxOrder α] [NoMinOrder α] in
theorem zPoint_neg_natCast (x : α) (n : ℕ) (hn : 0 < n) :
    zPoint x (-(n : ℤ)) = pred^[n] x := by
  have h : ¬ (0 : ℤ) ≤ -(n : ℤ) := by omega
  rw [zPoint, if_neg h]
  have h2 : (- -(n : ℤ)).toNat = n := by omega
  rw [h2]

/-- The `ℤ`-enumeration of a block is strictly monotone. -/
theorem zPoint_strictMono (x : α) : StrictMono (zPoint x) := by
  intro z w hzw
  by_cases hz : 0 ≤ z
  · have hw : 0 ≤ w := le_trans hz (le_of_lt hzw)
    simp only [zPoint, if_pos hz, if_pos hw]
    exact succ_iterate_lt_succ_iterate x (by omega)
  · by_cases hw : 0 ≤ w
    · simp only [zPoint, if_neg hz, if_pos hw]
      calc pred^[(-z).toNat] x < x := pred_iterate_lt_of_pos x (by omega)
        _ ≤ succ^[w.toNat] x := Order.le_succ_iterate _ x
    · simp only [zPoint, if_neg hz, if_neg hw]
      exact pred_iterate_lt_pred_iterate x (by omega)

omit [NoMaxOrder α] in
/-- Every `zPoint` stays in the base point's block. -/
theorem succReach_zPoint (x : α) (z : ℤ) : SuccReach x (zPoint x z) := by
  by_cases hz : 0 ≤ z
  · exact ⟨z.toNat, Or.inl (by simp [zPoint, hz])⟩
  · refine ⟨(-z).toNat, Or.inr ?_⟩
    simp only [zPoint, if_neg hz]
    exact succ_iterate_pred_iterate x _

omit [NoMinOrder α] in
/-- Every block-mate of `x` is a `zPoint` of `x`. -/
theorem exists_zPoint_of_succReach {x y : α} (h : SuccReach x y) :
    ∃ z : ℤ, zPoint x z = y := by
  obtain ⟨n, hn | hn⟩ := h
  · exact ⟨(n : ℤ), by simpa using hn⟩
  · rcases Nat.eq_zero_or_pos n with rfl | hpos
    · exact ⟨0, by simpa using hn.symm⟩
    · refine ⟨-(n : ℤ), ?_⟩
      rw [zPoint_neg_natCast x n hpos, ← hn, pred_iterate_succ_iterate]

end ZPoint

/-! ## The summand shape and the decomposition -/

/-- A monadic structure on `ℤ` from a colouring — the summand shape of the decomposition and
of the target-side reassembly over `ℚ ×ₗ ℤ`. -/
def zFiber (sig : MonadicSignature) (c : sig.preds → ℤ → Prop) :
    OrderedMonadicStructure sig where
  carrier := ℤ
  interp := fun p z => c p z
  carrierOrder := inferInstance

/--
**Block decomposition** (Doets 1987 ch. 7 step 9, p. 91, at a discrete unbounded flow): a
countable discrete unbounded-both-ways monadic structure is order-isomorphic, predicates
transported, to an ordered sum of coloured copies of `ℤ` over a countable nonempty index
order.
-/
theorem blockDecomposition (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (M : OrderedMonadicStructure sig) [Countable M.carrier]
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [Nonempty M.carrier] :
    ∃ (I : Type) (_ : LinearOrder I) (_ : Countable I) (_ : Nonempty I)
      (c : I → sig.preds → ℤ → Prop),
      ∃ f : M.carrier ≃o (orderedSum sig I (fun i => zFiber sig (c i))).carrier,
        ∀ (p : sig.preds) (x : M.carrier), M.interp p x ↔ c (f x).1 p (f x).2 := by
  classical
  refine ⟨BlockQuot M.carrier, inferInstance, inferInstance,
    ⟨blockMk (Classical.arbitrary M.carrier)⟩, ?_⟩
  -- The colouring reads predicates along the `ℤ`-enumeration based at the class
  -- representative.
  refine ⟨fun i p z => M.interp p (zPoint i.out z), ?_⟩
  -- The reassembly map from the sum to `M`.
  set c : BlockQuot M.carrier → sig.preds → ℤ → Prop :=
    fun i p z => M.interp p (zPoint i.out z) with hc
  set g : (orderedSum sig (BlockQuot M.carrier)
      (fun i => zFiber sig (c i))).carrier → M.carrier :=
    fun s => zPoint s.1.out s.2 with hg
  have hmono : StrictMono g := by
    intro s t hst
    have h : Sigma.Lex (· < ·) (fun _ => (· < ·)) s t := hst
    cases h with
    | left a b hij =>
      -- Distinct blocks: total separation.
      rename_i i j
      have hlt : blockLtPt (i.out) (j.out) := by
        have h1 : blockMk (i.out) < blockMk (j.out) := by
          rw [show blockMk i.out = i from Quotient.out_eq i,
            show blockMk j.out = j from Quotient.out_eq j]
          exact hij
        exact (blockMk_lt_blockMk).mp h1
      exact lt_of_blockLtPt hlt (succReach_zPoint _ _) (succReach_zPoint _ _)
    | right a b hab =>
      exact zPoint_strictMono _ hab
  have hsurj : Function.Surjective g := by
    intro x
    have hreach : SuccReach ((blockMk x).out) x :=
      Quotient.exact (Quotient.out_eq (blockMk x))
    obtain ⟨z, hz⟩ := exists_zPoint_of_succReach hreach
    exact ⟨⟨blockMk x, z⟩, hz⟩
  refine ⟨(StrictMono.orderIsoOfSurjective g hmono hsurj).symm, ?_⟩
  intro p x
  set s := (StrictMono.orderIsoOfSurjective g hmono hsurj).symm x with hs
  have hx : g s = x :=
    StrictMono.orderIsoOfSurjective_self_symm_apply g hmono hsurj x
  -- The colouring at the image point evaluates `M.interp` at `g (f x) = x`.
  show M.interp p x ↔ M.interp p (zPoint s.1.out s.2)
  rw [show zPoint s.1.out s.2 = x from hx]

end FormalSystem.Metalogic.WeakCanonical
