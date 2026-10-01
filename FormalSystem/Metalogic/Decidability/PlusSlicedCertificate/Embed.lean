/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Complete
import FormalSystem.Metalogic.Decidability.WitnessFamily.Agreement

/-!
# The Landed L Witness Family Embeds into a Time-Sliced L⁺ Certificate

The construction half of the embedding: a `WitnessFamily [] [φ]` with `k` lassos becomes a
`PlusSlicedCertificate [] [ofFormula φ]` of slice width `k`, with edges `i → i` only. This module
lands the construction, its readout, and bi-seriality; the semantic clauses and the flagship are
the business of the sub-phase that follows.

## Why the self-loop edge relation is the right one, confirmed rather than assumed

Phase 20's Scope Hypothesis asks that the `WitnessFamily` structure's fields be read before the
edge relation is fixed. They were: `WitnessFamily` carries `bx`, `lassos` and `lassos_ne`, and
nothing else — there is **no** succession relation, no `trans` field and no cross-index datum of
any kind. Its four certification conditions (`LocalCoherentLab`, `FulfillingLab`, `BoxFaithful`,
`Target`) quantify over one lasso index at a time: `LocalCoherentLab` and `FulfillingLab` read
`W.L i` at a single `i`, `BoxFaithful` reads a universal quantifier over indices on its right-hand
side but relates no two of them, and `Target` reads lasso `0` alone. So the per-lasso structure
genuinely needs no cross-index edge, and `fun i j => decide (i = j)` is the construction's own
relation rather than a simplification of one.

## The periods are a construction, not a bound

`perB` and `perF` are **products** of the family's own segment lengths and `perM` is their
**sum**, mirroring `PlusWitnessFamily/Decide.lean`'s `perBack` / `perFwd` / `perMid` rather than
inventing a second computation. The only properties used are divisibility
(`back_length_dvd_perB`, `fwd_length_dvd_perF`), the sum bound (`mid_length_le_perM`) and
positivity. **No order is claimed for any of the three**: a product of the family's own periods is
a construction, and nothing below states an inequality bounding it.

## The combined window is the slice tails' own, deliberately

`Window.lean`'s combined periods are `NBnat = Nat.lcm back.length target.back.length` and
`NFnat = Nat.lcm fwd.length target.fwd.length`, with `NM = max nm target.nm`, so the embedded
certificate's **target path's** three segment lengths enter the window and through it `winTimes`,
the liveness fixpoint and the tail-stability demand. The target path here is therefore cut at
**exactly** the slice sequence's own three lengths (`perB`, `perM`, `perF`), which leaves
`NBnat = perB`, `NFnat = perF` and `NM = perM` — the smallest window this construction admits. A
coprime choice would multiply both residue counts and with them the proof obligation; the choice
made is recorded here because it is a design move and not a forced one. **No bound is claimed
either way.**

## Main definitions

- `Periodic.segBack` / `segMid` / `segFwd` — materializing an eventually periodic function as the
  three segments that decode back to it
- `WitnessFamily.perB` / `perF` / `perM` — the family's common periods and window offset
- `WitnessFamily.trLab` — a `Formula` label translated into an L⁺ label
- `WitnessFamily.embSlice` — one time slice of the embedded certificate
- `WitnessFamily.embTarget` — the embedded target path, the main lasso at its own index
- `WitnessFamily.sliced` — **the embedded certificate**

## Main results

- `Periodic.unrollOf_seg` — the three segments decode back to the function they were cut from
- `plusClosureOf_ofCtx` — the L⁺ closure of an embedded context is the image of the L closure;
  with it, `stab`-formulas are absent from an embedded closure entirely
- `WitnessFamily.sliced_slice`, `sliced_edge`, `sliced_slab`, `sliced_target_datum` — the readout
- `WitnessFamily.sliced_biSerial` — the embedded certificate is bi-serial

## Tags

plus-language · certificate · time-sliced · embedding · witness-family
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.PlusLanguage

/-! ## Materializing an eventually periodic function as three segments

The generic layer this embedding needs and the subtree does not yet have: `Periodic.unrollOf`
decodes three lists into a bi-infinite function, and what is wanted here is the other direction —
a function known to be eventually periodic, cut into three lists that decode back to it.
-/

namespace Periodic

section Segments

variable {α : Type*}

/-- The `pb` values of `f` on `[-pb, 0)`, in time order. -/
def segBack (pb : ℕ) (f : ℤ → α) : List α :=
  (List.range pb).map (fun j : ℕ => f ((j : ℤ) - (pb : ℤ)))

/-- The `m` values of `f` on `[0, m)`, in time order. -/
def segMid (m : ℕ) (f : ℤ → α) : List α :=
  (List.range m).map (fun j : ℕ => f (j : ℤ))

/-- The `pf` values of `f` on `[m, m + pf)`, in time order. -/
def segFwd (pf m : ℕ) (f : ℤ → α) : List α :=
  (List.range pf).map (fun j : ℕ => f ((m : ℤ) + (j : ℤ)))

@[simp] theorem segBack_length (pb : ℕ) (f : ℤ → α) : (segBack pb f).length = pb := by
  rw [segBack, List.length_map, List.length_range]

@[simp] theorem segMid_length (m : ℕ) (f : ℤ → α) : (segMid m f).length = m := by
  rw [segMid, List.length_map, List.length_range]

@[simp] theorem segFwd_length (pf m : ℕ) (f : ℤ → α) : (segFwd pf m f).length = pf := by
  rw [segFwd, List.length_map, List.length_range]

theorem segBack_ne (f : ℤ → α) {pb : ℕ} (hpb : 0 < pb) : segBack pb f ≠ [] := by
  intro h
  have : (segBack pb f).length = 0 := by rw [h]; rfl
  rw [segBack_length] at this
  omega

theorem segFwd_ne (f : ℤ → α) {pf m : ℕ} (hpf : 0 < pf) : segFwd pf m f ≠ [] := by
  intro h
  have : (segFwd pf m f).length = 0 := by rw [h]; rfl
  rw [segFwd_length] at this
  omega

theorem mem_segBack (pb : ℕ) (f : ℤ → α) {x : α} (hx : x ∈ segBack pb f) :
    ∃ u : ℤ, x = f u := by
  rw [segBack, List.mem_map] at hx
  obtain ⟨j, -, rfl⟩ := hx
  exact ⟨_, rfl⟩

theorem mem_segMid (m : ℕ) (f : ℤ → α) {x : α} (hx : x ∈ segMid m f) : ∃ u : ℤ, x = f u := by
  rw [segMid, List.mem_map] at hx
  obtain ⟨j, -, rfl⟩ := hx
  exact ⟨_, rfl⟩

theorem mem_segFwd (pf m : ℕ) (f : ℤ → α) {x : α} (hx : x ∈ segFwd pf m f) :
    ∃ u : ℤ, x = f u := by
  rw [segFwd, List.mem_map] at hx
  obtain ⟨j, -, rfl⟩ := hx
  exact ⟨_, rfl⟩

/-- **Leftward periodicity by any multiple**, from the single-period hypothesis. -/
theorem periodic_back_mul {f : ℤ → α} {pb : ℕ}
    (hb : ∀ t : ℤ, t < 0 → f (t - (pb : ℤ)) = f t) :
    ∀ (k : ℕ) (t : ℤ), t < 0 → f (t - (k : ℤ) * (pb : ℤ)) = f t := by
  intro k
  induction k with
  | zero => intro t _; norm_num
  | succ j ih =>
    intro t ht
    have hpb : (0 : ℤ) ≤ (pb : ℤ) := Int.natCast_nonneg _
    have hj : (0 : ℤ) ≤ (j : ℤ) := Int.natCast_nonneg _
    have hlt : t - (j : ℤ) * (pb : ℤ) < 0 := by
      have : (0 : ℤ) ≤ (j : ℤ) * (pb : ℤ) := mul_nonneg hj hpb
      omega
    have hrw : t - ((j : ℕ) + 1 : ℤ) * (pb : ℤ) = (t - (j : ℤ) * (pb : ℤ)) - (pb : ℤ) := by ring
    have hcast : ((j + 1 : ℕ) : ℤ) = ((j : ℤ) + 1) := by push_cast; ring
    rw [hcast, hrw, hb _ hlt, ih t ht]

/-- **Rightward periodicity by any multiple**, from the single-period hypothesis. -/
theorem periodic_fwd_mul {f : ℤ → α} {pf m : ℕ}
    (hfw : ∀ t : ℤ, (m : ℤ) ≤ t → f (t + (pf : ℤ)) = f t) :
    ∀ (k : ℕ) (t : ℤ), (m : ℤ) ≤ t → f (t + (k : ℤ) * (pf : ℤ)) = f t := by
  intro k
  induction k with
  | zero => intro t _; norm_num
  | succ j ih =>
    intro t ht
    have hpf : (0 : ℤ) ≤ (pf : ℤ) := Int.natCast_nonneg _
    have hj : (0 : ℤ) ≤ (j : ℤ) := Int.natCast_nonneg _
    have hle : (m : ℤ) ≤ t + (j : ℤ) * (pf : ℤ) := by
      have : (0 : ℤ) ≤ (j : ℤ) * (pf : ℤ) := mul_nonneg hj hpf
      omega
    have hrw : t + ((j : ℕ) + 1 : ℤ) * (pf : ℤ) = (t + (j : ℤ) * (pf : ℤ)) + (pf : ℤ) := by ring
    have hcast : ((j + 1 : ℕ) : ℤ) = ((j : ℤ) + 1) := by push_cast; ring
    rw [hcast, hrw, hfw _ hle, ih t ht]

end Segments

section Decode

variable {α : Type*} [Inhabited α]

/-- Reading a `List.range`-map at an in-range index returns the mapped value. -/
theorem getD_range_map_of_lt {g : ℕ → α} {n i : ℕ} (h : i < n) :
    ((List.range n).map g).getD i default = g i := by
  have hlt : i < ((List.range n).map g).length := by simpa using h
  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hlt]
  simp

/--
**The three segments decode back to the function they were cut from.**

The converse of the three region lemmas: a function eventually periodic leftward with period `pb`,
eventually periodic rightward from `m` with period `pf`, is the `unrollOf` of its own three
segments. Proved region by region, with the two multiple-periodicity lemmas above doing the work
of getting from a residue representative back to the original time.
-/
theorem unrollOf_seg {f : ℤ → α} {pb pf m : ℕ} (hpb : 0 < pb) (hpf : 0 < pf)
    (hb : ∀ t : ℤ, t < 0 → f (t - (pb : ℤ)) = f t)
    (hfw : ∀ t : ℤ, (m : ℤ) ≤ t → f (t + (pf : ℤ)) = f t) (t : ℤ) :
    unrollOf (segBack pb f) (segMid m f) (segFwd pf m f) t = f t := by
  have hpbZ : (0 : ℤ) < (pb : ℤ) := by exact_mod_cast hpb
  have hpfZ : (0 : ℤ) < (pf : ℤ) := by exact_mod_cast hpf
  by_cases ht : t < 0
  · rw [unrollOf_neg _ _ _ ht, cyc, segBack_length]
    have h0 : (0 : ℤ) ≤ t % (pb : ℤ) := Int.emod_nonneg t (by omega)
    have h1 : t % (pb : ℤ) < (pb : ℤ) := Int.emod_lt_of_pos t hpbZ
    have hrn : ((t % (pb : ℤ)).toNat : ℤ) = t % (pb : ℤ) := Int.toNat_of_nonneg h0
    have hlt : (t % (pb : ℤ)).toNat < pb := by omega
    rw [segBack, getD_range_map_of_lt hlt, hrn]
    -- the representative is `t % pb - pb`, and `t` sits a whole number of periods to its left
    set r : ℤ := t % (pb : ℤ) with hr
    have hdiv : (pb : ℤ) * (t / (pb : ℤ)) + r = t := Int.mul_ediv_add_emod t (pb : ℤ)
    have hqneg : t / (pb : ℤ) ≤ -1 := by
      by_contra hcon
      have h2 : 0 ≤ t / (pb : ℤ) := by omega
      have h3 : 0 ≤ (pb : ℤ) * (t / (pb : ℤ)) := mul_nonneg (by omega) h2
      omega
    set q : ℤ := -(t / (pb : ℤ)) - 1 with hq
    have hq0 : 0 ≤ q := by omega
    have hqn : ((q.toNat : ℕ) : ℤ) = q := Int.toNat_of_nonneg hq0
    have hrlt : r - (pb : ℤ) < 0 := by omega
    have heq : (r - (pb : ℤ)) - (q.toNat : ℤ) * (pb : ℤ) = t := by
      rw [hqn, hq]
      have : (pb : ℤ) * (t / (pb : ℤ)) = t - r := by omega
      linarith [this]
    have := periodic_back_mul hb q.toNat (r - (pb : ℤ)) hrlt
    rw [heq] at this
    exact this.symm
  · have ht0 : (0 : ℤ) ≤ t := by omega
    by_cases htm : t < (m : ℤ)
    · rw [unrollOf_mid _ _ _ ht0 (by rw [segMid_length]; exact htm)]
      have hlt : t.toNat < m := by omega
      rw [segMid, getD_range_map_of_lt hlt, Int.toNat_of_nonneg ht0]
    · have htM : (m : ℤ) ≤ t := by omega
      rw [unrollOf_fwd _ _ _ (by rw [segMid_length]; exact htM), segMid_length, cyc, segFwd_length]
      have h0 : (0 : ℤ) ≤ (t - (m : ℤ)) % (pf : ℤ) := Int.emod_nonneg _ (by omega)
      have h1 : (t - (m : ℤ)) % (pf : ℤ) < (pf : ℤ) := Int.emod_lt_of_pos _ hpfZ
      have hrn : (((t - (m : ℤ)) % (pf : ℤ)).toNat : ℤ) = (t - (m : ℤ)) % (pf : ℤ) :=
        Int.toNat_of_nonneg h0
      have hlt : ((t - (m : ℤ)) % (pf : ℤ)).toNat < pf := by omega
      rw [segFwd, getD_range_map_of_lt hlt, hrn]
      set r : ℤ := (t - (m : ℤ)) % (pf : ℤ) with hr
      have hdiv : (pf : ℤ) * ((t - (m : ℤ)) / (pf : ℤ)) + r = t - (m : ℤ) :=
        Int.mul_ediv_add_emod (t - (m : ℤ)) (pf : ℤ)
      set q : ℤ := (t - (m : ℤ)) / (pf : ℤ) with hq
      have hq0 : 0 ≤ q := Int.ediv_nonneg (by omega) (by omega)
      have hqn : ((q.toNat : ℕ) : ℤ) = q := Int.toNat_of_nonneg hq0
      have hmle : (m : ℤ) ≤ (m : ℤ) + r := by omega
      have heq : ((m : ℤ) + r) + (q.toNat : ℤ) * (pf : ℤ) = t := by
        rw [hqn]
        linarith [hdiv]
      have := periodic_fwd_mul hfw q.toNat ((m : ℤ) + r) hmle
      rw [heq] at this
      exact this.symm

end Decode

end Periodic

/-! ## The L⁺ closure of an embedded context

`ofFormula` commutes with the subformula recursion constructor by constructor, so an embedded
context's L⁺ closure is the image of the base context's closure. Two consequences this embedding
runs on: a translated label is a closure subset, and **no `⊡`-formula is in an embedded closure at
all** — which is what makes every `stab`-guarded clause of the checker and of `SlabTrue` vacuous on
the image of `ofFormula`.
-/

namespace PlusFormula

/-- `ofFormula` commutes with the subformula list, constructor by constructor. -/
theorem subformulas_ofFormula (φ : Formula) :
    PlusFormula.subformulas (ofFormula φ) = (Formula.subformulas φ).map ofFormula := by
  induction φ with
  | atom a => rfl
  | bot => rfl
  | imp a b iha ihb =>
    simp only [ofFormula, PlusFormula.subformulas, Formula.subformulas, List.map_cons,
      List.map_append, iha, ihb]
  | box a iha =>
    simp only [ofFormula, PlusFormula.subformulas, Formula.subformulas, List.map_cons, iha]
  | untl a b iha ihb =>
    simp only [ofFormula, PlusFormula.subformulas, Formula.subformulas, List.map_cons,
      List.map_append, iha, ihb]
  | snce a b iha ihb =>
    simp only [ofFormula, PlusFormula.subformulas, Formula.subformulas, List.map_cons,
      List.map_append, iha, ihb]

end PlusFormula

/-- The L⁺ closure of an embedded formula is the image of its base closure. -/
theorem plusSubformulaClosure_ofFormula (φ : Formula) :
    plusSubformulaClosure (ofFormula φ) = (subformulaClosure φ).image ofFormula := by
  rw [plusSubformulaClosure, subformulaClosure, PlusFormula.subformulas_ofFormula]
  ext x
  simp

/-- **The L⁺ closure of an embedded context is the image of the base closure.** -/
theorem plusClosureOf_ofCtx (S : Context) :
    plusClosureOf (ofCtx S) = (closureOf S).image ofFormula := by
  induction S with
  | nil => simp [plusClosureOf, closureOf]
  | cons a l ih =>
    simp only [plusClosureOf, closureOf, List.map_cons, List.foldr_cons]
    rw [show (List.map plusSubformulaClosure (ofCtx l)).foldr (· ∪ ·) ∅
        = plusClosureOf (ofCtx l) from rfl,
      show (List.map subformulaClosure l).foldr (· ∪ ·) ∅ = closureOf l from rfl,
      ih, plusSubformulaClosure_ofFormula, Finset.image_union]

/-- Membership transfers through the embedding, in both directions. -/
theorem mem_plusClosureOf_ofCtx {S : Context} {ψ : Formula} :
    ofFormula ψ ∈ plusClosureOf (ofCtx S) ↔ ψ ∈ closureOf S := by
  rw [plusClosureOf_ofCtx, Finset.mem_image]
  constructor
  · rintro ⟨χ, hχ, he⟩
    rw [← ofFormula_injective he]
    exact hχ
  · intro h
    exact ⟨ψ, h, rfl⟩

/-- Every member of an embedded closure is itself embedded. -/
theorem exists_ofFormula_of_mem_plusClosureOf_ofCtx {S : Context} {χ : PlusFormula}
    (h : χ ∈ plusClosureOf (ofCtx S)) : ∃ ψ : Formula, ofFormula ψ = χ ∧ ψ ∈ closureOf S := by
  rw [plusClosureOf_ofCtx, Finset.mem_image] at h
  obtain ⟨ψ, hψ, he⟩ := h
  exact ⟨ψ, he, hψ⟩

/-- **No `⊡`-formula lies in an embedded closure.** Nothing in the range of `ofFormula` is a
top-level `stab`, so every `stab`-guarded clause is vacuous on an embedded context. -/
theorem not_stab_mem_plusClosureOf_ofCtx {S : Context} (χ : PlusFormula) :
    PlusFormula.stab χ ∉ plusClosureOf (ofCtx S) := by
  intro h
  obtain ⟨ψ, he, -⟩ := exists_ofFormula_of_mem_plusClosureOf_ofCtx h
  exact ofFormula_ne_stab ψ χ he

/-! ## Slice equality -/

namespace PlusSlice

/-- Two slices with the same edge relation and the same labelling are equal; the subset field is a
`Prop` and carries no data. -/
theorem ext' {n : ℕ} {C : Finset PlusFormula} {s s' : PlusSlice n C}
    (he : s.edge = s'.edge) (hl : s.lab = s'.lab) : s = s' := by
  obtain ⟨e, l, hs⟩ := s
  obtain ⟨e', l', hs'⟩ := s'
  simp only at he hl
  subst he
  subst hl
  rfl

end PlusSlice

/-! ## The embedding -/

namespace WitnessFamily

variable {φ : Formula}

/-! ### The common periods -/

/-- A member of a list of naturals divides its product. -/
private theorem dvd_prod_of_mem {l : List ℕ} {a : ℕ} (h : a ∈ l) : a ∣ l.prod := by
  induction l with
  | nil => cases h
  | cons b t ih =>
    rw [List.prod_cons]
    rcases List.mem_cons.mp h with rfl | h'
    · exact Dvd.intro _ rfl
    · exact Dvd.dvd.mul_left (ih h') b

/-- A list of positive naturals has a positive product. -/
private theorem prod_pos_of_mem {l : List ℕ} (h : ∀ a ∈ l, 0 < a) : 0 < l.prod := by
  induction l with
  | nil => exact Nat.one_pos
  | cons b t ih =>
    rw [List.prod_cons]
    exact Nat.mul_pos (h b List.mem_cons_self) (ih fun a ha => h a (List.mem_cons_of_mem _ ha))

/-- A member of a list of naturals is at most its sum. -/
private theorem le_sum_of_mem {l : List ℕ} {a : ℕ} (h : a ∈ l) : a ≤ l.sum := by
  induction l with
  | nil => cases h
  | cons b t ih =>
    rw [List.sum_cons]
    rcases List.mem_cons.mp h with rfl | h'
    · exact Nat.le_add_right _ _
    · exact le_trans (ih h') (Nat.le_add_left _ _)

variable {Γ Del : Context}

/-- **The common backward period**: the product of the lassos' own backward periods, mirroring
`PlusSharingWitnessFamily.perBack`. No order is claimed for it. -/
def perB (W : WitnessFamily Γ Del) : ℕ := (W.lassos.map (fun Λ => Λ.back.length)).prod

/-- **The common forward period**, the rightward mirror. -/
def perF (W : WitnessFamily Γ Del) : ℕ := (W.lassos.map (fun Λ => Λ.fwd.length)).prod

/-- **The common window offset**: the sum of the lassos' window lengths, so that at or past it
every lasso is in its periodic region. -/
def perM (W : WitnessFamily Γ Del) : ℕ := (W.lassos.map (fun Λ => Λ.mid.length)).sum

/-- A lasso's index names a member of the family's lasso list. -/
theorem get_mem (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) :
    W.lassos.get i ∈ W.lassos := by
  rw [List.get_eq_getElem]
  exact List.getElem_mem i.isLt

theorem perB_pos (W : WitnessFamily Γ Del) : 0 < W.perB := by
  refine prod_pos_of_mem (fun a ha => ?_)
  rw [List.mem_map] at ha
  obtain ⟨Λ, -, rfl⟩ := ha
  exact Nat.pos_of_ne_zero fun h => Λ.back_ne (List.eq_nil_of_length_eq_zero h)

theorem perF_pos (W : WitnessFamily Γ Del) : 0 < W.perF := by
  refine prod_pos_of_mem (fun a ha => ?_)
  rw [List.mem_map] at ha
  obtain ⟨Λ, -, rfl⟩ := ha
  exact Nat.pos_of_ne_zero fun h => Λ.fwd_ne (List.eq_nil_of_length_eq_zero h)

theorem back_length_dvd_perB (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) :
    (W.lassos.get i).back.length ∣ W.perB :=
  dvd_prod_of_mem (List.mem_map_of_mem (W.get_mem i))

theorem fwd_length_dvd_perF (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) :
    (W.lassos.get i).fwd.length ∣ W.perF :=
  dvd_prod_of_mem (List.mem_map_of_mem (W.get_mem i))

theorem mid_length_le_perM (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) :
    (W.lassos.get i).mid.length ≤ W.perM :=
  le_sum_of_mem (List.mem_map_of_mem (W.get_mem i))

/-! ### Periodicity of a lasso's labels by any multiple -/

/-- **Leftward periodicity by any multiple of the backward period.** -/
theorem lab_sub_dvd {C : Finset Formula} (Λ : LabelledLasso C) {p : ℕ}
    (hp : Λ.back.length ∣ p) {t : ℤ} (ht : t < 0) : Λ.lab (t - (p : ℤ)) = Λ.lab t := by
  obtain ⟨c, hc⟩ := hp
  subst hc
  have hb : ∀ u : ℤ, u < 0 → Λ.lab (u - (Λ.back.length : ℤ)) = Λ.lab u :=
    fun u hu => Λ.lab_sub_back_length hu
  have := Periodic.periodic_back_mul (f := Λ.lab) hb c t ht
  rw [show ((Λ.back.length * c : ℕ) : ℤ) = (c : ℤ) * (Λ.back.length : ℤ) from by push_cast; ring]
  exact this

/-- **Rightward periodicity by any multiple of the forward period.** -/
theorem lab_add_dvd {C : Finset Formula} (Λ : LabelledLasso C) {p : ℕ}
    (hp : Λ.fwd.length ∣ p) {t : ℤ} (ht : Λ.nm ≤ t) : Λ.lab (t + (p : ℤ)) = Λ.lab t := by
  obtain ⟨c, hc⟩ := hp
  subst hc
  have hf : ∀ u : ℤ, (Λ.mid.length : ℤ) ≤ u → Λ.lab (u + (Λ.fwd.length : ℤ)) = Λ.lab u :=
    fun u hu => Λ.lab_add_fwd_length hu
  have := Periodic.periodic_fwd_mul (f := Λ.lab) hf c t ht
  rw [show ((Λ.fwd.length * c : ℕ) : ℤ) = (c : ℤ) * (Λ.fwd.length : ℤ) from by push_cast; ring]
  exact this

theorem lab_sub_perB (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) {t : ℤ} (ht : t < 0) :
    W.L i (t - (W.perB : ℤ)) = W.L i t :=
  lab_sub_dvd _ (W.back_length_dvd_perB i) ht

theorem lab_add_perF (W : WitnessFamily Γ Del) (i : Fin W.lassos.length) {t : ℤ}
    (ht : (W.perM : ℤ) ≤ t) : W.L i (t + (W.perF : ℤ)) = W.L i t := by
  refine lab_add_dvd _ (W.fwd_length_dvd_perF i) ?_
  have := W.mid_length_le_perM i
  have h1 : ((W.lassos.get i).mid.length : ℤ) ≤ (W.perM : ℤ) := by exact_mod_cast this
  exact le_trans h1 ht

/-! ### The translated label -/

/-- A base-language label, translated into an L⁺ label. -/
def trLab (X : Finset Formula) : Finset PlusFormula := X.image ofFormula

@[simp] theorem mem_trLab {X : Finset Formula} {ψ : Formula} :
    ofFormula ψ ∈ trLab X ↔ ψ ∈ X := by
  rw [trLab, Finset.mem_image]
  constructor
  · rintro ⟨χ, hχ, he⟩
    rw [← ofFormula_injective he]
    exact hχ
  · intro h
    exact ⟨ψ, h, rfl⟩

theorem trLab_subset {S : Context} {X : Finset Formula} (h : X ⊆ closureOf S) :
    trLab X ⊆ plusClosureOf (ofCtx S) := by
  rw [trLab, plusClosureOf_ofCtx]
  exact Finset.image_subset_image h

/-! ### The embedded slice, the embedded target path, and the certificate -/

/-- The closure the embedded certificate is stated against. -/
abbrev embClosure (φ : Formula) : Finset PlusFormula :=
  plusClosureOf (([] : PlusContext) ++ [ofFormula φ])

theorem embClosure_eq (φ : Formula) :
    embClosure φ = plusClosureOf (ofCtx (([] : Context) ++ [φ])) := rfl

/--
**One time slice of the embedded certificate.**

Edges are `i → i` only — the construction's own relation, confirmed against the `WitnessFamily`
field list in this module's header — and the labelling at index `i` is the translated label of
lasso `i` at that time.
-/
def embSlice (W : WitnessFamily ([] : Context) [φ]) (t : ℤ) :
    PlusSlice W.lassos.length (embClosure φ) where
  edge := fun i j => decide (i = j)
  lab := fun i => trLab (W.L i t)
  lab_sub := fun i => trLab_subset (W.subset_closureOf i t)

@[simp] theorem embSlice_edge (W : WitnessFamily ([] : Context) [φ]) (t : ℤ)
    (i j : Fin W.lassos.length) : (embSlice W t).edge i j = decide (i = j) := rfl

@[simp] theorem embSlice_lab (W : WitnessFamily ([] : Context) [φ]) (t : ℤ)
    (i : Fin W.lassos.length) : (embSlice W t).lab i = trLab (W.L i t) := rfl

theorem embSlice_sub_perB (W : WitnessFamily ([] : Context) [φ]) {t : ℤ} (ht : t < 0) :
    embSlice W (t - (W.perB : ℤ)) = embSlice W t := by
  refine PlusSlice.ext' rfl ?_
  funext i
  rw [embSlice_lab, embSlice_lab, W.lab_sub_perB i ht]

theorem embSlice_add_perF (W : WitnessFamily ([] : Context) [φ]) {t : ℤ}
    (ht : (W.perM : ℤ) ≤ t) : embSlice W (t + (W.perF : ℤ)) = embSlice W t := by
  refine PlusSlice.ext' rfl ?_
  funext i
  rw [embSlice_lab, embSlice_lab, W.lab_add_perF i ht]

/-- The embedded target path's datum at a time: the main lasso's translated label, at the main
lasso's own index. -/
def embTargetFun (W : WitnessFamily ([] : Context) [φ]) (t : ℤ) :
    Finset PlusFormula × Fin W.lassos.length :=
  (trLab (W.main t), W.mainIdx)

theorem embTargetFun_sub_perB (W : WitnessFamily ([] : Context) [φ]) {t : ℤ} (ht : t < 0) :
    embTargetFun W (t - (W.perB : ℤ)) = embTargetFun W t := by
  rw [embTargetFun, embTargetFun, show W.main = W.L W.mainIdx from rfl,
    W.lab_sub_perB W.mainIdx ht]

theorem embTargetFun_add_perF (W : WitnessFamily ([] : Context) [φ]) {t : ℤ}
    (ht : (W.perM : ℤ) ≤ t) : embTargetFun W (t + (W.perF : ℤ)) = embTargetFun W t := by
  rw [embTargetFun, embTargetFun, show W.main = W.L W.mainIdx from rfl,
    W.lab_add_perF W.mainIdx ht]

/--
**The embedded target path.**

Cut at exactly the slice sequence's own three lengths, so that `Window.lean`'s combined periods
come out at `perB` / `perF` / `perM` rather than at a multiple of them. See this module's header.
-/
def embTarget (W : WitnessFamily ([] : Context) [φ]) :
    PlusGraphPath W.lassos.length (embClosure φ) where
  back := Periodic.segBack W.perB (embTargetFun W)
  mid := Periodic.segMid W.perM (embTargetFun W)
  fwd := Periodic.segFwd W.perF W.perM (embTargetFun W)
  back_ne := Periodic.segBack_ne _ W.perB_pos
  fwd_ne := Periodic.segFwd_ne _ W.perF_pos
  label_sub := by
    intro X hX
    have hu : ∃ u : ℤ, X = embTargetFun W u := by
      rw [List.mem_append, List.mem_append] at hX
      rcases hX with (hX | hX) | hX
      · exact Periodic.mem_segBack _ _ hX
      · exact Periodic.mem_segMid _ _ hX
      · exact Periodic.mem_segFwd _ _ _ hX
    obtain ⟨u, rfl⟩ := hu
    exact trLab_subset (W.subset_closureOf W.mainIdx u)

/--
**The embedded certificate.**

Slice width `k`, the family's lasso count; the slice sequence and the target path cut at the
common periods; the box guess left at the constant `false`, because `Complete.lean`'s
`exists_plusSlicedCertificate_of_tailStable_countermodel` re-chooses it and no notion this
construction has to establish reads it — `canAt`, and hence `canLab`, read the slice labelling.
-/
def sliced (W : WitnessFamily ([] : Context) [φ]) (targetTime : ℤ) :
    PlusSlicedCertificate ([] : PlusContext) [ofFormula φ] where
  n := W.lassos.length
  n_pos := W.lassos_length_pos
  back := Periodic.segBack W.perB (embSlice W)
  mid := Periodic.segMid W.perM (embSlice W)
  fwd := Periodic.segFwd W.perF W.perM (embSlice W)
  back_ne := Periodic.segBack_ne _ W.perB_pos
  fwd_ne := Periodic.segFwd_ne _ W.perF_pos
  bx := fun _ => false
  target := embTarget W
  targetTime := targetTime

@[simp] theorem sliced_n (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.sliced tt).n = W.lassos.length := rfl

@[simp] theorem sliced_targetTime (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.sliced tt).targetTime = tt := rfl

/-! ### The readout -/

/-- **The decoded slice sequence is the embedded slice at that time.** -/
theorem sliced_slice (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) (t : ℤ) :
    (W.sliced tt).slice t = embSlice W t :=
  Periodic.unrollOf_seg W.perB_pos W.perF_pos
    (fun _u hu => W.embSlice_sub_perB hu) (fun _u hu => W.embSlice_add_perF hu) t

/-- **Every edge of the embedded certificate is a self-loop.** -/
theorem sliced_edge (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) (t : ℤ)
    (i j : Fin (W.sliced tt).n) : (W.sliced tt).edge t i j = decide (i = j) := by
  rw [PlusSlicedCertificate.edge, W.sliced_slice tt t]
  rfl

/-- **The decoded slice labelling is the translated lasso label.** -/
theorem sliced_slab (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) (t : ℤ)
    (i : Fin (W.sliced tt).n) : (W.sliced tt).slab t i = trLab (W.L i t) := by
  rw [PlusSlicedCertificate.slab, W.sliced_slice tt t]
  rfl

/-- **The decoded target datum is the main lasso's translated label at its own index.** -/
theorem sliced_target_datum (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) (t : ℤ) :
    (W.sliced tt).target.datum t = embTargetFun W t :=
  @Periodic.unrollOf_seg _ (embTarget W).inh _ _ _ _ W.perB_pos W.perF_pos
    (fun _u hu => W.embTargetFun_sub_perB hu) (fun _u hu => W.embTargetFun_add_perF hu) t

theorem sliced_target_lab (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) (t : ℤ) :
    (W.sliced tt).target.lab t = trLab (W.main t) := by
  rw [PlusGraphPath.lab, W.sliced_target_datum tt t]
  rfl

theorem sliced_target_st (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) (t : ℤ) :
    (W.sliced tt).target.st t = W.mainIdx := by
  rw [PlusGraphPath.st, W.sliced_target_datum tt t]
  rfl

/-! ### The combined window is the slice tails' own

`Window.lean`'s `NBnat` is `Nat.lcm` of the slice sequence's own backward period with the target
path's. The embedded target path is cut at the slice sequence's own three lengths, so both
arguments are equal and the `lcm` collapses — which is what keeps the residue count of the
tail-stability demand at `perB` and `perF` rather than at a multiple of them.
-/

theorem sliced_NBnat (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.sliced tt).NBnat = W.perB := by
  rw [PlusSlicedCertificate.NBnat]
  simp only [sliced, embTarget, Periodic.segBack_length]
  exact Nat.lcm_self _

theorem sliced_NFnat (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.sliced tt).NFnat = W.perF := by
  rw [PlusSlicedCertificate.NFnat]
  simp only [sliced, embTarget, Periodic.segFwd_length]
  exact Nat.lcm_self _

theorem sliced_NM (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.sliced tt).NM = (W.perM : ℤ) := by
  rw [PlusSlicedCertificate.NM]
  simp only [sliced, embTarget, PlusSlicedCertificate.nm, PlusGraphPath.nm,
    Periodic.segMid_length]
  exact max_self _

/-! ### Bi-seriality -/

/-- **The embedded certificate is bi-serial.** Each `i → i` self-loop is its own forward and its
own backward successor, at every time and at every index. -/
theorem sliced_biSerial (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.sliced tt).BiSerial := by
  intro t
  constructor
  · intro w
    refine ⟨w, ?_⟩
    have := W.sliced_edge tt t w w
    rw [PlusSlicedCertificate.edge] at this
    rw [this]
    exact decide_eq_true rfl
  · intro u
    refine ⟨u, ?_⟩
    have := W.sliced_edge tt t u u
    rw [PlusSlicedCertificate.edge] at this
    rw [this]
    exact decide_eq_true rfl

/-! ### The window, and the two clause groups that are vacuous on an embedded context -/

theorem sliced_winLo (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.sliced tt).winLo = -2 * (W.perB : ℤ) := by
  rw [PlusSlicedCertificate.winLo, PlusSlicedCertificate.NB, W.sliced_NBnat tt]

theorem sliced_winHi (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.sliced tt).winHi = (W.perM : ℤ) + 2 * (W.perF : ℤ) := by
  rw [PlusSlicedCertificate.winHi, PlusSlicedCertificate.NF, W.sliced_NFnat tt, W.sliced_NM tt]

/-- **Membership in the embedded certificate's window**, in terms of the family's own periods. -/
theorem sliced_mem_winTimes (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) {u : ℤ}
    (h1 : -2 * (W.perB : ℤ) ≤ u) (h2 : u < (W.perM : ℤ) + 2 * (W.perF : ℤ)) :
    u ∈ (W.sliced tt).winTimes := by
  rw [PlusSlicedCertificate.mem_winTimes, W.sliced_winLo tt, W.sliced_winHi tt]
  exact ⟨h1, h2⟩

/-- **No `⊡`-formula lies in the embedded certificate's closure.** -/
theorem sliced_not_stab_mem (φ : Formula) (χ : PlusFormula) :
    PlusFormula.stab χ ∉ plusClosureOf (([] : PlusContext) ++ [ofFormula φ]) :=
  not_stab_mem_plusClosureOf_ofCtx (S := ([] : Context) ++ [φ]) χ

/--
**(C5) `StabFaithful` holds vacuously at an embedded certificate.**

Its clause is guarded by `⊡χ ∈ plusClosureOf (Γ ++ Del)`, and an embedded context's closure is the
image of a base closure, which contains no `⊡`-formula at all. The same vacuity discharges the
second clause of `Complete.lean`'s `SlabTrue`, which carries the identical guard — so the only
semantic clause left to establish on this route is the `□` one.
-/
theorem sliced_stabFaithful (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.sliced tt).StabFaithful := by
  intro t _ w χ hχ
  exact absurd hχ (sliced_not_stab_mem φ χ)

/-- **The embedded target path is a `G.edge`-path**: the hypothesis `hedge` of the completeness
headline, discharged by the self-loop at the main lasso's own index. -/
theorem sliced_target_edge (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) (t : ℤ) :
    (W.sliced tt).edge t ((W.sliced tt).target.st t) ((W.sliced tt).target.st (t + 1)) = true := by
  rw [W.sliced_edge tt t, W.sliced_target_st tt t, W.sliced_target_st tt (t + 1)]
  simp

end WitnessFamily

/-! ## The tail-stability demand, evaluated at two embedded certificates

Phase 20's principal risk is the forward conjunct of `Stable.lean`'s `TailStable`: it is a
**conjecture** at the embedding rather than a corollary of the construction, because `Φ_fwd` is a
reachability transfer and the one-step clauses leave an arriving label's `untl`-membership
unconstrained. `FixtureStable.lean` proves the **raw** demand `Φ_fwd R₀ = R₀` false at a named
certificate over a whole re-presentation family, which is why the landed demand carries a liveness
filter.

The two certificates below settle, by the kernel's own evaluation rather than by argument, that the
landed demand is **met** at an embedded certificate while the raw one is **not**. What that shows
and what it does not:

* It shows the conjecture is **not refuted** at the embedding, and that the liveness filter is
  **load-bearing** here — `not_tailStableRaw` fails at the same certificate where `tailStable`
  holds, so the filtered demand is doing exactly the work it was repaired to do.
* It does **not** show `TailStable` holds at *every* embedded certificate. These are two
  certificates, of eight and twelve timed vertices; the general statement is still open and is not
  claimed anywhere below.

The second family is a certifying one — its four `WitnessFamily` conditions are evaluated here too —
and its lasso genuinely carries an eventuality and genuinely discharges it, so the demand is tested
against a live `untl` obligation rather than against an empty closure.
-/

namespace WitnessFamily

namespace Embedded

open FormalSystem.Syntax

/-! ### A minimal embedded certificate: an `untl` closure with empty labels -/

private def pA : Atom := Atom.mkBase "p"
private def qA : Atom := Atom.mkBase "q"

/-- The guard of the probe eventuality. -/
def evGuard : Formula := Formula.atom pA

/-- The event of the probe eventuality. -/
def evEvent : Formula := Formula.atom qA

/-- The smallest target whose closure carries an `untl` obligation at all. -/
def evTarget : Formula := Formula.untl evGuard evEvent

/-- The empty-labelled lasso: locally coherent, vacuously fulfilling, and refuting `evTarget`
everywhere. -/
def emptyLasso : LabelledLasso (closureOf (([] : Context) ++ [evTarget])) where
  back := [∅]
  mid := []
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    have hE : X = ∅ := by
      rcases List.mem_append.mp hX with h | h
      · rcases List.mem_append.mp h with h | h
        · exact List.mem_singleton.mp h
        · simp at h
      · exact List.mem_singleton.mp h
    subst hE
    exact Finset.empty_subset _

/-- The one-lasso family over `emptyLasso`. -/
def emptyFamily : WitnessFamily ([] : Context) [evTarget] where
  bx := fun _ => false
  lassos := [emptyLasso]
  lassos_ne := by simp

/-- **The embedded certificate of the empty-labelled family is tail-stable.** -/
theorem emptyFamily_tailStable : (emptyFamily.sliced 0).TailStable := by decide

/-- **The raw demand fails at the same certificate.** This is what makes the liveness filter
load-bearing on this route rather than a convenience. -/
theorem emptyFamily_not_tailStableRaw : ¬ (emptyFamily.sliced 0).TailStableRaw := by decide

/-! ### A certifying embedded certificate whose lasso carries a live eventuality -/

theorem evTarget_mem : evTarget ∈ closureOf (([] : Context) ++ [evTarget]) :=
  self_mem_closureOf (by simp)

theorem evEvent_mem : evEvent ∈ closureOf (([] : Context) ++ [evTarget]) :=
  closureOf_untl_left evTarget_mem

/-- A lasso that really carries the eventuality and really discharges it: `p U q` at time `0`,
`q` at time `1`, empty elsewhere. -/
def liveLasso : LabelledLasso (closureOf (([] : Context) ++ [evTarget])) where
  back := [∅]
  mid := [{evTarget}, {evEvent}]
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    have hE : X = ∅ ∨ X = {evTarget} ∨ X = {evEvent} := by
      rcases List.mem_append.mp hX with h | h
      · rcases List.mem_append.mp h with h | h
        · exact Or.inl (List.mem_singleton.mp h)
        · rcases List.mem_cons.mp h with rfl | h
          · exact Or.inr (Or.inl rfl)
          · exact Or.inr (Or.inr (List.mem_singleton.mp h))
      · exact Or.inl (List.mem_singleton.mp h)
    rcases hE with rfl | rfl | rfl
    · exact Finset.empty_subset _
    · exact Finset.singleton_subset_iff.mpr evTarget_mem
    · exact Finset.singleton_subset_iff.mpr evEvent_mem

/-- The one-lasso family over `liveLasso`. -/
def liveFamily : WitnessFamily ([] : Context) [evTarget] where
  bx := fun _ => false
  lassos := [liveLasso]
  lassos_ne := by simp

theorem liveFamily_certifies : liveFamily.Certifies (-1) := by decide

/-- **The embedded certificate of the certifying family is tail-stable**, at twelve timed vertices
and with a live `untl` obligation in play. -/
theorem liveFamily_tailStable : (liveFamily.sliced (-1)).TailStable := by decide

/-- **The raw demand fails there too.** -/
theorem liveFamily_not_tailStableRaw : ¬ (liveFamily.sliced (-1)).TailStableRaw := by decide

end Embedded

end WitnessFamily

end FormalSystem.Metalogic.Decidability
