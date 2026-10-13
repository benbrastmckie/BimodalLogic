/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Periodic
import FormalSystem.Metalogic.Decidability.RaySummary.Trace

/-!
# Requirement (C), the general row: `exists_hitPresented`

The completeness half of the run layer, for every regular `ℤ`-model: at every seam `(τ, t)`,
every formula `φ` and every depth `1 ≤ k`, a finite labelled presentation realizes exactly the
family triples of the seam's closure traces, with its number of states bounded by the count
`sizeBound φ k` exhibited in the statement.

**The gadget.** A bi-ultimately-periodic word `w^(ω*) · m · v^ω` is the trace of the unique
anchored run of a three-piece presentation (`GadgetState`: a `|w|`-cycle, a `|m|`-path and a
`|v|`-cycle, joined by one step each; `gadgetLab`, `gadgetStep`): the canonical run `gadgetRun`
reads the periodic colouring (`runTrace_gadgetRun`), and it is the only anchored run
(`isRun_gadget_iff`) — `now` holds at a unique state of the `m`-path, the run is
successor-deterministic from there on and predecessor-deterministic before it. So the gadget's
computable realized-triple set is the family-triple set of its periodic trace
(`hitOf_gadget_eq`), and a disjoint union of gadgets realizes the union of their sets
(`hitOf_sigma_eq`).

**The headline.** By `Periodic.lean`'s seam assembly `exists_periodic_subfamily`, every triple of
`HitCl M τ t φ k` is a triple of a bounded periodic colouring whose own triples all lie in
`HitCl`; one gadget per triple of `HitCl`, a disjoint union over the finite set `HitCl`, is the
presentation (`exists_hitPresented`).

## Main definitions and results

* `GadgetState`, `gadgetLab`, `gadgetStep`, `gadgetRun` — the three-piece presentation of a
  periodic word and its canonical run.
* `runTrace_gadgetRun`, `isRun_gadgetRun`, `isRun_gadget_iff` — the run reads the periodic
  colouring and is the unique anchored run.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

variable (sig : MonadicSignature)

/-! ## The three-piece gadget -/

section Gadget

/-- **The state type of the gadget** presenting `w^(ω*) · m · v^ω`: a `|w|`-cycle, a
`|m|`-path and a `|v|`-cycle. -/
abbrev GadgetState (w m v : List (sig.preds → Bool)) : Type :=
  Fin w.length ⊕ Fin m.length ⊕ Fin v.length

/-- The label of a gadget state: the letter at its index. -/
def gadgetLab (w m v : List (sig.preds → Bool)) : GadgetState sig w m v → sig.preds → Bool
  | .inl i => w[i]
  | .inr (.inl j) => m[j]
  | .inr (.inr l) => v[l]

/-- The step relation of the gadget: the `w`-cycle (every state to its cyclic successor; the
last state also to the first `m` state, or to the first `v` state when `m` is empty), the
`m`-path (each state to the next, the last to the first `v` state), and the `v`-cycle. Every
other pair is not a step. -/
def gadgetStep (w m v : List (sig.preds → Bool)) :
    GadgetState sig w m v → GadgetState sig w m v → Bool
  | .inl i, .inl i' => decide (i'.1 = (i.1 + 1) % w.length)
  | .inl i, .inr (.inl j) => decide (i.1 + 1 = w.length ∧ j.1 = 0)
  | .inl i, .inr (.inr l) => decide (i.1 + 1 = w.length ∧ m.length = 0 ∧ l.1 = 0)
  | .inr (.inl j), .inr (.inl j') => decide (j'.1 = j.1 + 1)
  | .inr (.inl j), .inr (.inr l) => decide (j.1 + 1 = m.length ∧ l.1 = 0)
  | .inr (.inr l), .inr (.inr l') => decide (l'.1 = (l.1 + 1) % v.length)
  | _, _ => false

-- linter.hashCommand: this `#guard` runs the compiled step relation on the two-letter toy gadget
-- `Fin 1 ⊕ Fin 1 ⊕ Fin 1` (`w = [false]`, `m = [true]`, `v = [false]` as constant letters),
-- documenting the step table: the `w`-cycle's one state steps to itself and to the `m`-path
-- (not to the `v`-cycle, since `m` is nonempty), the `m`-path's one state steps to the `v`-cycle
-- only, the `v`-cycle's one state steps to itself only. Declaration-scoped.
set_option linter.hashCommand false in
open FormalSystem.Metalogic.Decidability.RaySummary (twoLetter) in
#guard
  let w : List (twoLetter.preds → Bool) := [fun _ => false]
  let m : List (twoLetter.preds → Bool) := [fun _ => true]
  let v : List (twoLetter.preds → Bool) := [fun _ => false]
  let a : GadgetState twoLetter w m v := .inl ⟨0, by decide⟩
  let b : GadgetState twoLetter w m v := .inr (.inl ⟨0, by decide⟩)
  let c : GadgetState twoLetter w m v := .inr (.inr ⟨0, by decide⟩)
  gadgetStep twoLetter w m v a a && gadgetStep twoLetter w m v a b &&
    !gadgetStep twoLetter w m v a c && !gadgetStep twoLetter w m v b a &&
    !gadgetStep twoLetter w m v b b && gadgetStep twoLetter w m v b c &&
    !gadgetStep twoLetter w m v c a && !gadgetStep twoLetter w m v c b &&
    gadgetStep twoLetter w m v c c

variable {sig}
variable {w m v : List (sig.preds → Bool)}

/-- Residues modulo a positive length are valid indices. -/
theorem toNat_emod_lt {z : ℤ} {L : ℕ} (hL : 0 < L) : (z % L).toNat < L := by
  have h1 := Int.emod_nonneg z (by omega : (L : ℤ) ≠ 0)
  have h2 := Int.emod_lt_of_pos z (by omega : (0 : ℤ) < L)
  omega

/-- The cyclic successor of a residue. -/
theorem toNat_emod_succ {z : ℤ} {L : ℕ} (hL : 0 < L) :
    ((z + 1) % L).toNat = ((z % L).toNat + 1) % L := by
  have h1 := Int.emod_nonneg z (by omega : (L : ℤ) ≠ 0)
  have h : (z + 1) % L = (((z % L).toNat + 1 : ℕ) : ℤ) % L := by
    rw [← Int.emod_add_emod]
    push_cast
    rw [Int.toNat_of_nonneg h1]
  rw [h, ← Int.natCast_emod, Int.toNat_natCast]

/-- Residues of a positive length one apart: `(i₁ + 1) % L = (i₂ + 1) % L` forces `i₁ = i₂`
below `L`. -/
theorem succ_mod_inj {L i₁ i₂ : ℕ} (h₁ : i₁ < L) (h₂ : i₂ < L)
    (h : (i₁ + 1) % L = (i₂ + 1) % L) : i₁ = i₂ := by
  rcases Nat.lt_or_ge (i₁ + 1) L with ha | ha <;> rcases Nat.lt_or_ge (i₂ + 1) L with hb | hb
  · rw [Nat.mod_eq_of_lt ha, Nat.mod_eq_of_lt hb] at h
    omega
  · rw [Nat.mod_eq_of_lt ha, show i₂ + 1 = L by omega, Nat.mod_self] at h
    omega
  · rw [Nat.mod_eq_of_lt hb, show i₁ + 1 = L by omega, Nat.mod_self] at h
    omega
  · omega

/-- **The canonical run** of the gadget reading `periodicColouring w m v b`: the `w`-cycle
before `b`, the `m`-path on `[b, b + |m|)`, the `v`-cycle from `b + |m|` on. -/
def gadgetRun (hw : w ≠ []) (hv : v ≠ []) (b : ℤ) (z : ℤ) : GadgetState sig w m v :=
  if hz : z < b then .inl ⟨((z - b) % w.length).toNat,
    toNat_emod_lt (List.length_pos_iff.mpr hw)⟩
  else if hz' : z < b + m.length then .inr (.inl ⟨(z - b).toNat, by omega⟩)
  else .inr (.inr ⟨((z - b - m.length) % v.length).toNat,
    toNat_emod_lt (List.length_pos_iff.mpr hv)⟩)

theorem gadgetRun_of_lt (hw : w ≠ []) (hv : v ≠ []) (b : ℤ) {z : ℤ} (hz : z < b) :
    gadgetRun hw hv b z = (.inl ⟨((z - b) % w.length).toNat,
      toNat_emod_lt (List.length_pos_iff.mpr hw)⟩ : GadgetState sig w m v) := by
  unfold gadgetRun
  rw [dif_pos hz]

theorem gadgetRun_of_mid (hw : w ≠ []) (hv : v ≠ []) (b : ℤ) {z : ℤ} (h₁ : b ≤ z)
    (h₂ : z < b + m.length) :
    gadgetRun hw hv b z = (.inr (.inl ⟨(z - b).toNat, by omega⟩) : GadgetState sig w m v) := by
  unfold gadgetRun
  rw [dif_neg (not_lt.mpr h₁), dif_pos h₂]

theorem gadgetRun_of_ge (hw : w ≠ []) (hv : v ≠ []) (b : ℤ) {z : ℤ} (h : b + m.length ≤ z) :
    gadgetRun hw hv b z = (.inr (.inr ⟨((z - b - m.length) % v.length).toNat,
      toNat_emod_lt (List.length_pos_iff.mpr hv)⟩) : GadgetState sig w m v) := by
  unfold gadgetRun
  rw [dif_neg (not_lt.mpr (by omega : b ≤ z)), dif_neg (not_lt.mpr h)]

theorem getD_eq_getElem_of_lt {L : Type} [Inhabited L] (l : List L) {i : ℕ}
    (hi : i < l.length) : l.getD i default = l[i] := by
  rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem hi]
  rfl

/-- **The label of the canonical run is the periodic letter.** -/
theorem gadgetLab_gadgetRun (hw : w ≠ []) (hv : v ≠ []) (b z : ℤ) :
    gadgetLab sig w m v (gadgetRun hw hv b z) = periodicLetter sig w m v b z := by
  by_cases hz : z < b
  · rw [gadgetRun_of_lt hw hv b hz, periodicLetter_of_lt _ _ _ _ hz, gadgetLab,
      getD_eq_getElem_of_lt _ (toNat_emod_lt (List.length_pos_iff.mpr hw))]
    simp only [Fin.getElem_fin]
  · by_cases hz' : z < b + m.length
    · rw [gadgetRun_of_mid hw hv b (by omega) hz', periodicLetter_of_mid _ _ _ _ (by omega) hz',
        gadgetLab, getD_eq_getElem_of_lt _ (by omega)]
      simp only [Fin.getElem_fin]
    · rw [gadgetRun_of_ge hw hv b (by omega), periodicLetter_of_ge _ _ _ _ (by omega), gadgetLab,
        getD_eq_getElem_of_lt _ (toNat_emod_lt (List.length_pos_iff.mpr hv))]
      simp only [Fin.getElem_fin]

/-- **The trace of the canonical run is the periodic colouring.** -/
theorem runTrace_gadgetRun (hw : w ≠ []) (hv : v ≠ []) (b : ℤ) :
    runTrace (gadgetLab sig w m v) (gadgetRun hw hv b) = periodicColouring sig w m v b := by
  funext p z
  simp only [runTrace, periodicColouring, gadgetLab_gadgetRun]

/-- Every gadget label is a periodic letter: a `w` state at a time before `b`, an `m` state at
its time in `[b, b + |m|)`, a `v` state at a time from `b + |m|` on. -/
theorem gadgetLab_inl (hw : w ≠ []) (b : ℤ) (i : Fin w.length) :
    gadgetLab sig w m v (.inl i) = periodicLetter sig w m v b (b - w.length + i) := by
  have hL := List.length_pos_iff.mpr hw
  rw [periodicLetter_of_lt _ _ _ _ (by omega),
    show b - (w.length : ℤ) + i - b = (i : ℤ) - 1 * w.length by ring, Int.sub_mul_emod_self_right,
    Int.emod_eq_of_lt (by omega) (by omega), Int.toNat_natCast, getD_eq_getElem_of_lt _ i.2]
  rfl

theorem gadgetLab_inr_inl (b : ℤ) (j : Fin m.length) :
    gadgetLab sig w m v (.inr (.inl j)) = periodicLetter sig w m v b (b + j) := by
  rw [periodicLetter_of_mid _ _ _ _ (by omega) (by omega),
    show (b + (j : ℤ) - b).toNat = j by omega, getD_eq_getElem_of_lt _ j.2]
  rfl

theorem gadgetLab_inr_inr (hv : v ≠ []) (b : ℤ) (l : Fin v.length) :
    gadgetLab sig w m v (.inr (.inr l)) = periodicLetter sig w m v b (b + m.length + l) := by
  have hL := List.length_pos_iff.mpr hv
  rw [periodicLetter_of_ge _ _ _ _ (by omega),
    show b + (m.length : ℤ) + l - b - m.length = (l : ℤ) by ring,
    Int.emod_eq_of_lt (by omega) (by omega), Int.toNat_natCast, getD_eq_getElem_of_lt _ l.2]
  rfl

/-- `now` holds exactly at `t` only if `t` lies in the `m` part: the `w` and `v` letters
repeat. -/
theorem mid_of_now_unique (hw : w ≠ []) (hv : v ≠ []) {b t : ℤ} {now : sig.preds}
    (hnow : ∀ z, periodicColouring sig w m v b now z ↔ z = t) : b ≤ t ∧ t < b + m.length := by
  have hL := List.length_pos_iff.mpr hw
  have hLv := List.length_pos_iff.mpr hv
  by_contra hcon
  rw [not_and_or, not_le, not_lt] at hcon
  rcases hcon with ht | ht
  · have h1 : periodicColouring sig w m v b now (t - w.length) := by
      rw [periodicColouring_iff, periodicLetter_of_lt _ _ _ _ (by omega),
        show t - (w.length : ℤ) - b = (t - b) - 1 * w.length by ring,
        Int.sub_mul_emod_self_right, ← periodicLetter_of_lt _ _ _ _ ht, ← periodicColouring_iff]
      exact (hnow t).mpr rfl
    have := (hnow _).mp h1
    omega
  · have h1 : periodicColouring sig w m v b now (t + v.length) := by
      rw [periodicColouring_iff, periodicLetter_of_ge _ _ _ _ (by omega),
        show t + (v.length : ℤ) - b - m.length = (t - b - m.length) + (v.length : ℤ) * 1 by ring,
        Int.add_mul_emod_self_left, ← periodicLetter_of_ge _ _ _ _ ht, ← periodicColouring_iff]
      exact (hnow t).mpr rfl
    have := (hnow _).mp h1
    omega

/-- **The canonical run is an anchored run of the gadget**: steps inside each piece by its
chain, across the two joins by the joining steps, and `now` exactly at `t`. -/
theorem isRun_gadgetRun (hw : w ≠ []) (hv : v ≠ []) (b : ℤ) {now : sig.preds} {t : ℤ}
    (hnow : ∀ z, periodicColouring sig w m v b now z ↔ z = t) :
    IsRun (gadgetLab sig w m v) (gadgetStep sig w m v) now t (gadgetRun hw hv b) := by
  have hL := List.length_pos_iff.mpr hw
  have hLv := List.length_pos_iff.mpr hv
  refine ⟨fun z => ?_, fun z => ?_⟩
  · by_cases h1 : z + 1 < b
    · rw [gadgetRun_of_lt hw hv b (by omega), gadgetRun_of_lt hw hv b h1]
      simp only [gadgetStep, decide_eq_true_iff]
      rw [show z + 1 - b = (z - b) + 1 by ring]
      exact toNat_emod_succ hL
    · by_cases h2 : z < b
      · have hzb : z - b = -(((0 : ℕ) : ℤ) + 1) := by omega
        have hidx : ((z - b) % w.length).toNat = w.length - 1 := by
          rw [hzb, toNat_neg_succ_emod 0 _ hL, Nat.zero_mod, Nat.sub_zero]
        rw [gadgetRun_of_lt hw hv b h2]
        by_cases hm : 0 < m.length
        · rw [gadgetRun_of_mid hw hv b (by omega) (by omega)]
          simp only [gadgetStep, decide_eq_true_iff, hidx]
          omega
        · rw [gadgetRun_of_ge hw hv b (by omega)]
          simp only [gadgetStep, decide_eq_true_iff, hidx]
          refine ⟨by omega, by omega, ?_⟩
          rw [show z + 1 - b - (m.length : ℤ) = 0 by omega, Int.zero_emod]
          rfl
      · by_cases h3 : z + 1 < b + m.length
        · rw [gadgetRun_of_mid hw hv b (by omega) (by omega),
            gadgetRun_of_mid hw hv b (by omega) h3]
          simp only [gadgetStep, decide_eq_true_iff]
          omega
        · by_cases h4 : z < b + m.length
          · rw [gadgetRun_of_mid hw hv b (by omega) h4, gadgetRun_of_ge hw hv b (by omega)]
            simp only [gadgetStep, decide_eq_true_iff]
            refine ⟨by omega, ?_⟩
            rw [show z + 1 - b - (m.length : ℤ) = 0 by omega, Int.zero_emod]
            rfl
          · rw [gadgetRun_of_ge hw hv b (by omega), gadgetRun_of_ge hw hv b (by omega)]
            simp only [gadgetStep, decide_eq_true_iff]
            rw [show z + 1 - b - (m.length : ℤ) = (z - b - m.length) + 1 by ring]
            exact toNat_emod_succ hLv
  · rw [gadgetLab_gadgetRun]
    exact hnow z

/-- **The unique `now` state** is the `m` state at `t - b`: a `w` or `v` state's letter is read
at a time other than `t`. -/
theorem eq_gadgetRun_of_lab_now (hw : w ≠ []) (hv : v ≠ []) {b t : ℤ} {now : sig.preds}
    (hnow : ∀ z, periodicColouring sig w m v b now z ↔ z = t) (q : GadgetState sig w m v)
    (hq : gadgetLab sig w m v q now = true) : q = gadgetRun hw hv b t := by
  obtain ⟨hbt, htb⟩ := mid_of_now_unique hw hv hnow
  rw [gadgetRun_of_mid hw hv b hbt htb]
  rcases q with i | j | l
  · exfalso
    rw [gadgetLab_inl hw b i] at hq
    have := (hnow _).mp hq
    omega
  · rw [gadgetLab_inr_inl b j] at hq
    have := (hnow _).mp hq
    congr 2
    exact Fin.ext (by change j.1 = (t - b).toNat; omega)
  · exfalso
    rw [gadgetLab_inr_inr hv b l] at hq
    have := (hnow _).mp hq
    omega

/-- **Successor-determinism on the `m` and `v` states.** -/
theorem gadgetStep_inr_unique (q q₁ q₂ : GadgetState sig w m v) (hq : ∀ i, q ≠ .inl i)
    (h₁ : gadgetStep sig w m v q q₁ = true) (h₂ : gadgetStep sig w m v q q₂ = true) :
    q₁ = q₂ := by
  rcases q with i | j | l
  · exact absurd rfl (hq i)
  · rcases q₁ with i₁ | j₁ | l₁
    · simp [gadgetStep] at h₁
    · rcases q₂ with i₂ | j₂ | l₂
      · simp [gadgetStep] at h₂
      · simp only [gadgetStep, decide_eq_true_iff] at h₁ h₂
        congr 2
        exact Fin.ext (by omega)
      · simp only [gadgetStep, decide_eq_true_iff] at h₁ h₂
        have := j₁.2
        omega
    · rcases q₂ with i₂ | j₂ | l₂
      · simp [gadgetStep] at h₂
      · simp only [gadgetStep, decide_eq_true_iff] at h₁ h₂
        have := j₂.2
        omega
      · simp only [gadgetStep, decide_eq_true_iff] at h₁ h₂
        congr 2
        exact Fin.ext (by omega)
  · rcases q₁ with i₁ | j₁ | l₁ <;> rcases q₂ with i₂ | j₂ | l₂ <;>
      simp only [gadgetStep, decide_eq_true_iff, Bool.false_eq_true] at h₁ h₂
    congr 2
    exact Fin.ext (by omega)

/-- **Predecessor-determinism on the `w` and `m` states.** -/
theorem gadgetStep_pred_unique (q₁ q₂ q : GadgetState sig w m v) (hq : ∀ l, q ≠ .inr (.inr l))
    (h₁ : gadgetStep sig w m v q₁ q = true) (h₂ : gadgetStep sig w m v q₂ q = true) :
    q₁ = q₂ := by
  rcases q with i | j | l
  · rcases q₁ with i₁ | j₁ | l₁ <;> rcases q₂ with i₂ | j₂ | l₂ <;>
      simp only [gadgetStep, decide_eq_true_iff, Bool.false_eq_true] at h₁ h₂
    congr 1
    exact Fin.ext (succ_mod_inj i₁.2 i₂.2 (h₁.symm.trans h₂))
  · rcases q₁ with i₁ | j₁ | l₁
    · rcases q₂ with i₂ | j₂ | l₂
      · simp only [gadgetStep, decide_eq_true_iff] at h₁ h₂
        congr 1
        exact Fin.ext (by omega)
      · simp only [gadgetStep, decide_eq_true_iff] at h₁ h₂
        omega
      · simp [gadgetStep] at h₂
    · rcases q₂ with i₂ | j₂ | l₂
      · simp only [gadgetStep, decide_eq_true_iff] at h₁ h₂
        omega
      · simp only [gadgetStep, decide_eq_true_iff] at h₁ h₂
        congr 2
        exact Fin.ext (by omega)
      · simp [gadgetStep] at h₂
    · simp [gadgetStep] at h₁
  · exact absurd rfl (hq l)

theorem gadgetRun_ne_inl (hw : w ≠ []) (hv : v ≠ []) (b : ℤ) {z : ℤ} (hz : b ≤ z) :
    ∀ i, gadgetRun hw hv b z ≠ (.inl i : GadgetState sig w m v) := by
  intro i h
  by_cases hz' : z < b + m.length
  · rw [gadgetRun_of_mid hw hv b hz hz'] at h
    cases h
  · rw [gadgetRun_of_ge hw hv b (by omega)] at h
    cases h

theorem gadgetRun_ne_inr_inr (hw : w ≠ []) (hv : v ≠ []) (b : ℤ) {z : ℤ}
    (hz : z < b + m.length) :
    ∀ l, gadgetRun hw hv b z ≠ (.inr (.inr l) : GadgetState sig w m v) := by
  intro l h
  by_cases hz' : z < b
  · rw [gadgetRun_of_lt hw hv b hz'] at h
    cases h
  · rw [gadgetRun_of_mid hw hv b (by omega) hz] at h
    cases h

/-- **The canonical run is the unique anchored run of the gadget.** From the unique `now`
state at `t`, successor-determinism fixes the run after `t` and predecessor-determinism fixes
it before `t`. -/
theorem isRun_gadget_iff (hw : w ≠ []) (hv : v ≠ []) (b : ℤ) {now : sig.preds} {t : ℤ}
    (hnow : ∀ z, periodicColouring sig w m v b now z ↔ z = t)
    (ρ : ℤ → GadgetState sig w m v) :
    IsRun (gadgetLab sig w m v) (gadgetStep sig w m v) now t ρ ↔ ρ = gadgetRun hw hv b := by
  constructor
  · rintro ⟨hstep, hρ⟩
    obtain ⟨hbt, htb⟩ := mid_of_now_unique hw hv hnow
    have hcan := isRun_gadgetRun hw hv b hnow
    have ht : ρ t = gadgetRun hw hv b t :=
      eq_gadgetRun_of_lab_now hw hv hnow (ρ t) ((hρ t).mpr rfl)
    have hfwd : ∀ n : ℕ, ρ (t + n) = gadgetRun hw hv b (t + n) := by
      intro n
      induction n with
      | zero => simpa using ht
      | succ n ih =>
        have h1 := hstep (t + n)
        have h2 := hcan.1 (t + n)
        rw [ih] at h1
        rw [show t + ((n + 1 : ℕ) : ℤ) = t + n + 1 by push_cast; ring]
        exact gadgetStep_inr_unique _ _ _ (gadgetRun_ne_inl hw hv b (by omega)) h1 h2
    have hbwd : ∀ n : ℕ, ρ (t - n) = gadgetRun hw hv b (t - n) := by
      intro n
      induction n with
      | zero => simpa using ht
      | succ n ih =>
        have h1 := hstep (t - ((n + 1 : ℕ) : ℤ))
        have h2 := hcan.1 (t - ((n + 1 : ℕ) : ℤ))
        rw [show t - ((n + 1 : ℕ) : ℤ) + 1 = t - n by push_cast; ring] at h1 h2
        rw [ih] at h1
        exact gadgetStep_pred_unique _ _ _ (gadgetRun_ne_inr_inr hw hv b (by omega)) h1 h2
    funext z
    by_cases h : t ≤ z
    · have := hfwd (z - t).toNat
      rwa [show t + ((z - t).toNat : ℤ) = z by omega] at this
    · have := hbwd (t - z).toNat
      rwa [show t - ((t - z).toNat : ℤ) = z by omega] at this
  · rintro rfl
    exact isRun_gadgetRun hw hv b hnow

end Gadget

end FormalSystem.Metalogic.WeakCanonical
