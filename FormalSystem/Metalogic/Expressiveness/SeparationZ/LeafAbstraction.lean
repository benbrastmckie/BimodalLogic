/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.Syntax
import FormalSystem.OpenLanguage
import FormalSystem.PlusLanguage.PlusIntTransfer
import Mathlib.Data.List.GetD

/-!
# The leaf-abstraction seam and the carrier bridge

This is the **one** interface between the abstract until/since development of this subtree and
`FormalSystem.PlusLanguage.PlusFormula`. It carries:

* `leaves`, the computable leaf table of an L⁺ formula — its atoms together with its *maximal*
  `□`- and `⊡`-subformulas, in deterministic traversal order and without duplicates;
* `abstr`, the abstraction of an L⁺ formula to a `USForm` reading each leaf off that table, and
  `toPlus`, the resubstitution along an arbitrary leaf assignment;
* the **roundtrip** `toPlus_abstr`, the **truth transfer** `usTruth_toPlus_iff` at `t : ℤ`, and
  the **purity transfer** `isPureFuture_toPlus` / `isPurePast_toPlus`;
* the **carrier bridge** `pointwise_ztime_of_pointwise_int`, which turns a pointwise equivalence
  over the single carrier `ℤ` into the shape `SeparationOver` asks for over every regular
  ℤ-time task frame.

## Why the leaves are both pure past and pure future

`PlusFormula.IsPurePast` and `PlusFormula.IsPureFuture` both take `□ψ` and `⊡ψ` as *leaf*
constructors for any `ψ`, and both take `atom p`. So every entry of `leaves φ` is
simultaneously past- and future-pure, and the semantic `PastDet`/`FutDet` that `SepClauses`
asks for comes free from the compiled `pastDet_of_isPurePast` / `futDet_of_isPureFuture`. This
is what makes a *syntactic* separation target sufficient.

## The carrier ascription

`pointwise_ztime_of_pointwise_int` routes through
`FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt`, whose own proof records that Lean
cannot invert `↑E ≟ ℤ` to recover `E := intOrder`. The hypothesis is therefore stated at
`FrameOver intOrder` explicitly, and every later phase consumes this one lemma rather than
re-deriving the transfer.

## Main Definitions

- `leaves`, `abstrWith`, `abstr`, `toPlus`
- `IsUOnly`, `IsSOnly`: the syntactic separation targets on `USForm`

## Main Results

- `toPlus_abstr`: the roundtrip
- `usTruth_toPlus_iff`: truth transfer at `t : ℤ`
- `isPureFuture_toPlus`, `isPurePast_toPlus`: purity transfer
- `leaves_isPure`, `leafVal_isPurePast`, `leafVal_isPureFuture`: every leaf is doubly pure
- `plusTruthAt_iff_iff`: the pointwise reading of `PlusTruthAt _ _ _ (φ.iff ψ)`
- `pointwise_ztime_of_pointwise_int`: the carrier bridge

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Chapter 10 §10.2
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage

/-! ## The leaf table -/

/--
The **leaf table** of an L⁺ formula: its atoms together with its maximal `□`- and
`⊡`-subformulas, in deterministic traversal order and without duplicates. "Maximal" means the
recursion does **not** descend into a `□` or `⊡` scope: the whole subformula is one leaf.
-/
def leaves : PlusFormula → List PlusFormula
  | .atom p => [.atom p]
  | .bot => []
  | .imp φ ψ => leaves φ ∪ leaves ψ
  | .box φ => [.box φ]
  | .stab φ => [.stab φ]
  | .untl ψ φ => leaves ψ ∪ leaves φ
  | .snce ψ φ => leaves ψ ∪ leaves φ

theorem leaves_nodup (φ : PlusFormula) : (leaves φ).Nodup := by
  induction φ with
  | atom p => exact List.nodup_singleton _
  | bot => exact List.nodup_nil
  | imp φ ψ _ ihψ => exact List.Nodup.union _ ihψ
  | box φ => exact List.nodup_singleton _
  | untl ψ φ _ ihφ => exact List.Nodup.union _ ihφ
  | snce ψ φ _ ihφ => exact List.Nodup.union _ ihφ
  | stab φ => exact List.nodup_singleton _

/-- Every entry of a leaf table is simultaneously pure past and pure future. -/
theorem leaves_isPure (φ : PlusFormula) :
    ∀ x ∈ leaves φ, PlusFormula.IsPurePast x ∧ PlusFormula.IsPureFuture x := by
  induction φ with
  | atom p =>
    intro x hx
    simp only [leaves, List.mem_singleton] at hx
    exact hx ▸ ⟨PlusFormula.IsPurePast.atom p, PlusFormula.IsPureFuture.atom p⟩
  | bot => intro x hx; exact absurd hx (List.not_mem_nil)
  | imp φ ψ ihφ ihψ =>
    intro x hx
    rcases List.mem_union_iff.mp hx with h | h
    · exact ihφ x h
    · exact ihψ x h
  | box φ _ =>
    intro x hx
    simp only [leaves, List.mem_singleton] at hx
    exact hx ▸ ⟨PlusFormula.IsPurePast.box φ, PlusFormula.IsPureFuture.box φ⟩
  | untl ψ φ ihψ ihφ =>
    intro x hx
    rcases List.mem_union_iff.mp hx with h | h
    · exact ihψ x h
    · exact ihφ x h
  | snce ψ φ ihψ ihφ =>
    intro x hx
    rcases List.mem_union_iff.mp hx with h | h
    · exact ihψ x h
    · exact ihφ x h
  | stab φ _ =>
    intro x hx
    simp only [leaves, List.mem_singleton] at hx
    exact hx ▸ ⟨PlusFormula.IsPurePast.stab φ, PlusFormula.IsPureFuture.stab φ⟩

/-- The leaf assignment a formula's own table induces: index `i` reads the `i`-th entry, with
`⊥` outside the range. -/
def leafVal (φ : PlusFormula) : ℕ → PlusFormula := fun i => (leaves φ).getD i .bot

theorem leafVal_isPurePast (φ : PlusFormula) (i : ℕ) :
    PlusFormula.IsPurePast (leafVal φ i) := by
  rw [leafVal]
  by_cases h : i < (leaves φ).length
  · rw [List.getD_eq_getElem _ _ h]
    exact (leaves_isPure φ _ (List.getElem_mem h)).1
  · rw [List.getD_eq_default _ _ (by omega)]
    exact PlusFormula.IsPurePast.bot

theorem leafVal_isPureFuture (φ : PlusFormula) (i : ℕ) :
    PlusFormula.IsPureFuture (leafVal φ i) := by
  rw [leafVal]
  by_cases h : i < (leaves φ).length
  · rw [List.getD_eq_getElem _ _ h]
    exact (leaves_isPure φ _ (List.getElem_mem h)).2
  · rw [List.getD_eq_default _ _ (by omega)]
    exact PlusFormula.IsPureFuture.bot

/-- Reading back an entry at its own index. -/
theorem leafVal_idxOf {φ x : PlusFormula} (hx : x ∈ leaves φ) :
    leafVal φ ((leaves φ).idxOf x) = x := by
  rw [leafVal, List.getD_eq_getElem?_getD, List.getElem?_idxOf hx]
  rfl

/-! ## Abstraction and resubstitution -/

/-- Abstraction of an L⁺ formula against a fixed leaf table: each atom and each maximal
`□`/`⊡` subformula becomes the `USForm` leaf at its index in `L`. -/
def abstrWith (L : List PlusFormula) : PlusFormula → USForm
  | .atom p => .leaf (L.idxOf (.atom p))
  | .bot => .bot
  | .imp φ ψ => .imp (abstrWith L φ) (abstrWith L ψ)
  | .box φ => .leaf (L.idxOf (.box φ))
  | .stab φ => .leaf (L.idxOf (.stab φ))
  | .untl ψ φ => .untl (abstrWith L ψ) (abstrWith L φ)
  | .snce ψ φ => .snce (abstrWith L ψ) (abstrWith L φ)

/-- Abstraction against the formula's own leaf table. -/
def abstr (φ : PlusFormula) : USForm := abstrWith (leaves φ) φ

/-- Resubstitution: send the `USForm` leaf `i` to `g i` and every other constructor to its
`PlusFormula` namesake. -/
def toPlus (g : ℕ → PlusFormula) : USForm → PlusFormula
  | .leaf i => g i
  | .bot => .bot
  | .imp φ ψ => .imp (toPlus g φ) (toPlus g ψ)
  | .untl ψ φ => .untl (toPlus g ψ) (toPlus g φ)
  | .snce ψ φ => .snce (toPlus g ψ) (toPlus g φ)

/-- **The roundtrip**, in the generality the induction needs: resubstituting along any leaf
assignment that reads each entry of `φ`'s own table back correctly recovers `φ`. -/
theorem toPlus_abstrWith {g : ℕ → PlusFormula} {L : List PlusFormula} :
    ∀ φ : PlusFormula, (∀ x ∈ leaves φ, g (L.idxOf x) = x) → toPlus g (abstrWith L φ) = φ := by
  intro φ
  induction φ with
  | atom p =>
    intro h
    exact h (.atom p) (List.mem_singleton_self _)
  | bot => intro _; rfl
  | imp φ ψ ihφ ihψ =>
    intro h
    rw [abstrWith, toPlus,
      ihφ (fun x hx => h x (List.mem_union_iff.mpr (Or.inl hx))),
      ihψ (fun x hx => h x (List.mem_union_iff.mpr (Or.inr hx)))]
  | box φ _ =>
    intro h
    exact h (.box φ) (List.mem_singleton_self _)
  | untl ψ φ ihψ ihφ =>
    intro h
    rw [abstrWith, toPlus,
      ihψ (fun x hx => h x (List.mem_union_iff.mpr (Or.inl hx))),
      ihφ (fun x hx => h x (List.mem_union_iff.mpr (Or.inr hx)))]
  | snce ψ φ ihψ ihφ =>
    intro h
    rw [abstrWith, toPlus,
      ihψ (fun x hx => h x (List.mem_union_iff.mpr (Or.inl hx))),
      ihφ (fun x hx => h x (List.mem_union_iff.mpr (Or.inr hx)))]
  | stab φ _ =>
    intro h
    exact h (.stab φ) (List.mem_singleton_self _)

/-- **The roundtrip**: abstracting an L⁺ formula and resubstituting its own leaf table recovers
it on the nose. -/
theorem toPlus_abstr (φ : PlusFormula) : toPlus (leafVal φ) (abstr φ) = φ :=
  toPlus_abstrWith φ fun _ hx => leafVal_idxOf hx

/-! ## The syntactic separation targets -/

/-- `ψ` contains no `snce`: GHR's "pure-future" shape at the `USForm` level. -/
inductive IsUOnly : USForm → Prop
  /-- Every leaf is `untl`-only. -/
  | leaf (i : ℕ) : IsUOnly (.leaf i)
  /-- Bottom is `untl`-only. -/
  | bot : IsUOnly .bot
  /-- `imp` preserves `untl`-onlyness. -/
  | imp {φ ψ : USForm} : IsUOnly φ → IsUOnly ψ → IsUOnly (.imp φ ψ)
  /-- `untl` preserves `untl`-onlyness. -/
  | untl {ψ φ : USForm} : IsUOnly ψ → IsUOnly φ → IsUOnly (USForm.untl ψ φ)

/-- `ψ` contains no `untl`: GHR's "pure-past" shape at the `USForm` level. -/
inductive IsSOnly : USForm → Prop
  /-- Every leaf is `snce`-only. -/
  | leaf (i : ℕ) : IsSOnly (.leaf i)
  /-- Bottom is `snce`-only. -/
  | bot : IsSOnly .bot
  /-- `imp` preserves `snce`-onlyness. -/
  | imp {φ ψ : USForm} : IsSOnly φ → IsSOnly ψ → IsSOnly (.imp φ ψ)
  /-- `snce` preserves `snce`-onlyness. -/
  | snce {ψ φ : USForm} : IsSOnly ψ → IsSOnly φ → IsSOnly (USForm.snce ψ φ)

theorem IsUOnly.top : IsUOnly USForm.top := IsUOnly.imp IsUOnly.bot IsUOnly.bot

theorem IsSOnly.top : IsSOnly USForm.top := IsSOnly.imp IsSOnly.bot IsSOnly.bot

theorem IsUOnly.neg {φ : USForm} (h : IsUOnly φ) : IsUOnly φ.neg := IsUOnly.imp h IsUOnly.bot

theorem IsSOnly.neg {φ : USForm} (h : IsSOnly φ) : IsSOnly φ.neg := IsSOnly.imp h IsSOnly.bot

theorem IsUOnly.and {φ ψ : USForm} (hφ : IsUOnly φ) (hψ : IsUOnly ψ) : IsUOnly (φ.and ψ) :=
  (IsUOnly.imp hφ hψ.neg).neg

theorem IsSOnly.and {φ ψ : USForm} (hφ : IsSOnly φ) (hψ : IsSOnly ψ) : IsSOnly (φ.and ψ) :=
  (IsSOnly.imp hφ hψ.neg).neg

theorem IsUOnly.or {φ ψ : USForm} (hφ : IsUOnly φ) (hψ : IsUOnly ψ) : IsUOnly (φ.or ψ) :=
  IsUOnly.imp hφ.neg hψ

theorem IsSOnly.or {φ ψ : USForm} (hφ : IsSOnly φ) (hψ : IsSOnly ψ) : IsSOnly (φ.or ψ) :=
  IsSOnly.imp hφ.neg hψ

theorem IsUOnly.someFuture {φ : USForm} (h : IsUOnly φ) : IsUOnly (USForm.someFuture φ) :=
  IsUOnly.untl IsUOnly.top h

theorem IsUOnly.allFuture {φ : USForm} (h : IsUOnly φ) : IsUOnly (USForm.allFuture φ) :=
  (IsUOnly.someFuture h.neg).neg

theorem IsSOnly.somePast {φ : USForm} (h : IsSOnly φ) : IsSOnly (USForm.somePast φ) :=
  IsSOnly.snce IsSOnly.top h

theorem IsSOnly.allPast {φ : USForm} (h : IsSOnly φ) : IsSOnly (USForm.allPast φ) :=
  (IsSOnly.somePast h.neg).neg

/-- `swap` exchanges the two separation targets. -/
theorem IsUOnly.swap {φ : USForm} (h : IsUOnly φ) : IsSOnly φ.swap := by
  induction h with
  | leaf i => exact IsSOnly.leaf i
  | bot => exact IsSOnly.bot
  | imp _ _ ihφ ihψ => exact IsSOnly.imp ihφ ihψ
  | untl _ _ ihψ ihφ => exact IsSOnly.snce ihψ ihφ

/-- `swap` exchanges the two separation targets, the mirror of `IsUOnly.swap`. -/
theorem IsSOnly.swap {φ : USForm} (h : IsSOnly φ) : IsUOnly φ.swap := by
  induction h with
  | leaf i => exact IsUOnly.leaf i
  | bot => exact IsUOnly.bot
  | imp _ _ ihφ ihψ => exact IsUOnly.imp ihφ ihψ
  | snce _ _ ihψ ihφ => exact IsUOnly.untl ihψ ihφ

/-! ## Purity transfer -/

/-- **Purity transfer, future side**: resubstituting pure-future leaves into an `untl`-only
`USForm` yields a syntactically pure-future L⁺ formula. -/
theorem isPureFuture_toPlus {g : ℕ → PlusFormula}
    (hg : ∀ i, PlusFormula.IsPureFuture (g i)) {ψ : USForm} (h : IsUOnly ψ) :
    PlusFormula.IsPureFuture (toPlus g ψ) := by
  induction h with
  | leaf i => exact hg i
  | bot => exact PlusFormula.IsPureFuture.bot
  | imp _ _ ihφ ihψ => exact PlusFormula.IsPureFuture.imp ihφ ihψ
  | untl _ _ ihψ ihφ => exact PlusFormula.IsPureFuture.untl ihψ ihφ

/-- **Purity transfer, past side**, the mirror of `isPureFuture_toPlus`. -/
theorem isPurePast_toPlus {g : ℕ → PlusFormula}
    (hg : ∀ i, PlusFormula.IsPurePast (g i)) {ψ : USForm} (h : IsSOnly ψ) :
    PlusFormula.IsPurePast (toPlus g ψ) := by
  induction h with
  | leaf i => exact hg i
  | bot => exact PlusFormula.IsPurePast.bot
  | imp _ _ ihφ ihψ => exact PlusFormula.IsPurePast.imp ihφ ihψ
  | snce _ _ ihψ ihφ => exact PlusFormula.IsPurePast.snce ihψ ihφ

/-! ## Truth transfer at `t : ℤ` -/

/--
**Truth transfer.** Over a frame whose duration carrier is `ℤ`, `usTruth` at the leaf valuation
induced by a leaf assignment `g` is `PlusTruthAt` of the resubstituted formula. The carrier is
ascribed at `↑intOrder` in the binder, not at `ℤ`.
-/
theorem usTruth_toPlus_iff {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (g : ℕ → PlusFormula) :
    ∀ (ψ : USForm) (t : ℤ),
      usTruth (fun i s => PlusTruthAt M τ s (g i)) t ψ ↔ PlusTruthAt M τ t (toPlus g ψ) := by
  intro ψ
  induction ψ with
  | leaf i => intro t; exact Iff.rfl
  | bot => intro t; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro t; exact Iff.imp (ihφ t) (ihψ t)
  | untl ψ φ ihψ ihφ =>
    intro t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ihψ r)
  | snce ψ φ ihψ ihφ =>
    intro t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ihψ r)

/-! ## The carrier bridge -/

/-- The pointwise reading of a biconditional's L⁺ truth. -/
theorem plusTruthAt_iff_iff {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ ψ : PlusFormula) :
    PlusTruthAt M τ t (φ.iff ψ) ↔ (PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t ψ) := by
  rw [PlusFormula.iff, PlusTruth.and_iff, PlusTruth.imp_iff, PlusTruth.imp_iff]
  exact ⟨fun h => ⟨h.1, h.2⟩, fun h => ⟨h.mp, h.mpr⟩⟩

/--
**The carrier bridge.** A pointwise equivalence over the single carrier `ℤ` upgrades to the
pointwise equivalence over every regular ℤ-time task frame that `SeparationOver` asks for.

The route is `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` applied to
`φ.iff ψ`: validity of the biconditional *is* the pointwise equivalence, in both directions, so
the carrier normalization of L⁺ validity transports the pointwise statement unchanged.
-/
theorem pointwise_ztime_of_pointwise_int {φ ψ : PlusFormula}
    (h : ∀ (F : FrameOver intOrder), F.IsRegular → ∀ (M : TaskModel F.toTaskFrame)
      (τ : WorldHistory F.toTaskFrame) (t : ℤ),
        PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t ψ) (F : TaskFrame) (hreg : F.IsRegular)
    (hz : F.IsZTime) (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t ψ := by
  have hint : PlusValidInt (φ.iff ψ) := by
    intro G hG M' τ' t'
    exact (plusTruthAt_iff_iff M' τ' t' φ ψ).mpr (h G hG M' τ' t')
  have hz' : PlusValidZTime (φ.iff ψ) := (plusValidZTime_iff_plusValidInt _).mpr hint
  exact (plusTruthAt_iff_iff M τ t φ ψ).mp (hz' F ⟨hreg, hz⟩ M τ t)

end FormalSystem.Metalogic.Expressiveness.SeparationZ
