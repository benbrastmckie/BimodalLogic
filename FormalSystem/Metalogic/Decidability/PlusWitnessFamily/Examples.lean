/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Decide

/-!
# Non-Vacuity of (C5), and the Deterministic Diagonal

(C5) `StabFaithful` is stated in `Predicates.lean` and decided in `Decide.lean`. Neither module
answers the two questions a reader asks next: does the condition ever *fail*, and does it say
anything the `box` clause does not already say? This module answers both, and it answers them
with a concrete family carrying literal label lists rather than with an existence claim.

## The two halves

`stabFamily` is the branching half. Two lassos share a world state at `u = 0` and are separate
everywhere else. The eventuality `Fp` is labelled on the main lasso at every time, including
`u = 0`, and nowhere on the second. (C5) then *forces* `⊡Fp` out of the main lasso's label at
`u = 0` — the one time where the shared class contains an index missing `Fp` — while leaving it
in at every other time. So on one family the condition both holds and separates `⊡Fp` from `Fp`:
it is neither vacuous nor a paraphrase of the `box` clause, which reads a single global Boolean
and cannot vary between `u = 0` and `u = 1`.

`stabFaithful_diagonal` is the degenerate half. When every `rep u` is the identity — the L⁺
analogue of `WitnessFamily.toSharing`, and the shape of the shipping deterministic device — the
`share`-classes are singletons and (C5) collapses to `⊡φ ↔ φ`. That is
`PlusDeterminism.stab_iff_of_deterministic` recovered inside the device, and it is why the
branching substrate is load-bearing rather than incidental: on the deterministic frame the
condition has nothing to say.

## Why the witness is concrete

Every label list below is written out, so `decidableStabFaithful` can be *run* on the family
rather than reasoned about. The `#guard` at the end of the module does exactly that at the
atom `p`, which is the check that (C5)'s decision procedure accepts a family the branching
structure makes non-trivial.

## Main Definitions

- `PlusSharingWitnessFamily.stabEvent` — the eventuality `Fp := ⊤ U p`, in guard-first order
- `PlusSharingWitnessFamily.stabFamily` — the two-lasso non-vacuity witness

## Main Results

- `PlusSharingWitnessFamily.stabFamily_separates` — (C5) holds on `stabFamily`, and separates
  `Fp` from `⊡Fp` at the main lasso's origin
- `PlusSharingWitnessFamily.stabFaithful_diagonal` — (C5) degenerates to `⊡φ ↔ φ` when every
  `rep u` is the identity
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage FormalSystem.Syntax

namespace PlusSharingWitnessFamily

/-! ## The deterministic diagonal

The degenerate half comes first because it needs nothing but (C5) itself. -/

/--
**The diagonal collapse.**

On the deterministic specialization — every `rep u` the identity, so `share u i j ↔ i = j` —
(C5) degenerates to `⊡φ ↔ φ`, recovering `PlusDeterminism.stab_iff_of_deterministic` inside
the device.

This is one half of non-vacuity: the branching substrate is what makes the condition bite. The
hypothesis is stated at `S.skeleton.share` rather than at `S.share` because the skeleton is
where the sharing structure actually lives; the two are definitionally the same relation.

Paper: — (a degeneracy observation about a formalization-native condition; the paper
states no such result)
-/
theorem stabFaithful_diagonal {Γ Del : PlusContext} (S : PlusSharingWitnessFamily Γ Del)
    (hdet : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.skeleton.share u i j ↔ i = j)
    (h : S.StabFaithful) (i : Fin S.lassos.length) (u : ℤ) (φ : PlusFormula)
    (hc : PlusFormula.stab φ ∈ plusClosureOf (Γ ++ Del)) :
    (PlusFormula.stab φ ∈ S.L i u ↔ φ ∈ S.L i u) := by
  rw [h i u φ hc]
  constructor
  · intro hall
    exact hall i (S.share_refl u i)
  · intro hφ j hij
    have hEq : i = j := (hdet u i j).mp hij
    exact hEq ▸ hφ

/-! ## The branching non-vacuity witness

Two singleton-cycle lassos, one of which carries a distinguished label at the origin. The three
`Periodic` lemmas below are what make every decoded value on such a family a one-line `rw`. -/

section Periodic

variable {α : Type*} [Inhabited α]

/-- A one-element cycle is constant: `i % 1 = 0` at every index. -/
private theorem cyc_singleton (a : α) (i : ℤ) : Periodic.cyc [a] i = a := by
  simp [Periodic.cyc, Int.emod_one]

/-- A lasso whose two cycles are the same singleton and whose window is one position decodes to
the window's entry at the origin and to the cycle's entry everywhere else. -/
private theorem unrollOf_singleton_mid (a b : α) (t : ℤ) :
    Periodic.unrollOf [a] [b] [a] t = if t = 0 then b else a := by
  rcases lt_trichotomy t 0 with ht | ht | ht
  · rw [Periodic.unrollOf_neg _ _ _ ht, cyc_singleton, if_neg (by omega)]
  · subst ht
    rw [Periodic.unrollOf_mid _ _ _ le_rfl (by simp), if_pos rfl]
    simp
  · have hlen : ((([b] : List α).length : ℕ) : ℤ) = 1 := by simp
    rw [Periodic.unrollOf_fwd _ _ _ (by rw [hlen]; omega), cyc_singleton, if_neg (by omega)]

/-- The origin case of `unrollOf_singleton_mid`, in the form `rw` can use against a decoded
representative map. -/
private theorem unrollOf_singleton_mid_zero (a b : α) :
    Periodic.unrollOf [a] [b] [a] (0 : ℤ) = b := by
  rw [unrollOf_singleton_mid, if_pos rfl]

/-- The off-origin case of `unrollOf_singleton_mid`. -/
private theorem unrollOf_singleton_mid_ne (a b : α) {t : ℤ} (ht : t ≠ 0) :
    Periodic.unrollOf [a] [b] [a] t = a := by
  rw [unrollOf_singleton_mid, if_neg ht]

/-- A lasso whose two cycles are the same singleton and whose window is empty is constant. -/
private theorem unrollOf_singleton_nil (a : α) (t : ℤ) :
    Periodic.unrollOf [a] ([] : List α) [a] t = a := by
  rcases lt_or_ge t 0 with ht | ht
  · rw [Periodic.unrollOf_neg _ _ _ ht, cyc_singleton]
  · have hlen : (((([] : List α)).length : ℕ) : ℤ) = 0 := by simp
    rw [Periodic.unrollOf_fwd _ _ _ (by rw [hlen]; omega), cyc_singleton]

end Periodic

section Witness

variable (p : Atom)

/-- The eventuality `Fp := ⊤ U p`, written in the guard-first constructor order the certificate
layer uses throughout. -/
abbrev stabEvent : PlusFormula := PlusFormula.untl (.imp .bot .bot) (.atom p)

/-- The witness family's target closure: the closure of `⊡Fp` alone. -/
abbrev stabClosure : Finset PlusFormula :=
  plusClosureOf ([PlusFormula.stab (stabEvent p)] ++ ([] : PlusContext))

theorem stab_mem_stabClosure : PlusFormula.stab (stabEvent p) ∈ stabClosure p :=
  self_mem_plusClosureOf (by simp)

theorem event_mem_stabClosure : stabEvent p ∈ stabClosure p :=
  plusClosureOf_stab (stab_mem_stabClosure p)

theorem atom_mem_stabClosure : PlusFormula.atom p ∈ stabClosure p :=
  plusClosureOf_untl_left (event_mem_stabClosure p)

/-- **`⊡Fp` is the only stability modal in the target closure.** This is what reduces (C5) on
the witness — a quantifier over every `φ` with `⊡φ` in the closure — to a single formula. -/
theorem stab_mem_stabClosure_iff (φ : PlusFormula) :
    PlusFormula.stab φ ∈ stabClosure p ↔ φ = stabEvent p := by
  constructor
  · intro h
    obtain ⟨χ, hχ, hmem⟩ := mem_plusClosureOf.mp h
    have hχ' : χ = PlusFormula.stab (stabEvent p) := by simpa using hχ
    subst hχ'
    have hlist : PlusFormula.stab φ ∈
        PlusFormula.subformulas (PlusFormula.stab (stabEvent p)) := by
      simpa [plusSubformulaClosure] using hmem
    simpa [PlusFormula.subformulas] using hlist
  · rintro rfl
    exact stab_mem_stabClosure p

/-- The main lasso's label away from the origin: `⊡Fp`, `Fp` and `p`. -/
def stabLabelOff : Finset PlusFormula :=
  {PlusFormula.stab (stabEvent p), stabEvent p, PlusFormula.atom p}

/-- The main lasso's label **at** the origin: `Fp` alone. `⊡Fp` is absent, and (C5) is what
forces its absence — the shared class at `u = 0` contains an index where `Fp` is not labelled. -/
def stabLabelOrigin : Finset PlusFormula := {stabEvent p}

theorem stabLabelOff_subset : stabLabelOff p ⊆ stabClosure p := by
  intro ψ hψ
  simp only [stabLabelOff, Finset.mem_insert, Finset.mem_singleton] at hψ
  rcases hψ with rfl | rfl | rfl
  · exact stab_mem_stabClosure p
  · exact event_mem_stabClosure p
  · exact atom_mem_stabClosure p

theorem stabLabelOrigin_subset : stabLabelOrigin p ⊆ stabClosure p := by
  intro ψ hψ
  rw [stabLabelOrigin, Finset.mem_singleton] at hψ
  exact hψ ▸ event_mem_stabClosure p

/-- The main lasso: singleton cycles carrying `stabLabelOff`, and a one-position window carrying
`stabLabelOrigin` at `t = 0`. -/
def stabLassoMain : PlusLabelledLasso (stabClosure p) where
  back := [stabLabelOff p]
  mid := [stabLabelOrigin p]
  fwd := [stabLabelOff p]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl | rfl
    · exact stabLabelOff_subset p
    · exact stabLabelOrigin_subset p
    · exact stabLabelOff_subset p

/-- The second lasso: empty labels everywhere, so neither `p` nor `Fp` is ever labelled on it. -/
def stabLassoAlt : PlusLabelledLasso (stabClosure p) where
  back := [∅]
  mid := []
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl
    · exact Finset.empty_subset _
    · exact Finset.empty_subset _

/--
**The two-lasso non-vacuity witness.**

Lassos `0` and `1` share a world state at `u = 0` — the representative window collapses both
indices onto `0` there — and are separate at every other time, where the representative map is
the identity. Lasso `0` carries `Fp` everywhere; lasso `1` carries nothing.
-/
def stabFamily : PlusSharingWitnessFamily [PlusFormula.stab (stabEvent p)] ([] : PlusContext) where
  bx := fun _ => false
  lassos := [stabLassoMain p, stabLassoAlt p]
  lassos_ne := by simp
  repBack := [id]
  repMid := [fun _ => ⟨0, by simp⟩]
  repFwd := [id]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by
    intro f hf i
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hf
    rcases hf with rfl | rfl | rfl <;> rfl

@[simp]
theorem stabFamily_lassos_length : (stabFamily p).lassos.length = 2 := rfl

theorem stabFamily_zero_lt : 0 < (stabFamily p).lassos.length :=
  (stabFamily p).toPlusWitnessFamily.lassos_length_pos

theorem stabFamily_one_lt : 1 < (stabFamily p).lassos.length := by
  rw [stabFamily_lassos_length]
  omega

/-- The witness has exactly two indices, so every quantifier over them is a two-case split. -/
theorem stabFamily_index_cases (i : Fin (stabFamily p).lassos.length) :
    i.val = 0 ∨ i.val = 1 := by
  have h : i.val < 2 := i.isLt
  omega

/-- **The witness's labels, decoded.** Lasso `0` carries `stabLabelOrigin` at the origin and
`stabLabelOff` elsewhere; lasso `1` carries nothing anywhere. -/
theorem stabFamily_L (i : Fin (stabFamily p).lassos.length) (u : ℤ) :
    (stabFamily p).L i u =
      if i.val = 0 then (if u = 0 then stabLabelOrigin p else stabLabelOff p) else ∅ := by
  have hget : (stabFamily p).lassos.get i
      = if i.val = 0 then stabLassoMain p else stabLassoAlt p := by
    rcases stabFamily_index_cases p i with h | h
    · rw [if_pos h]
      have hi : i = ⟨0, stabFamily_zero_lt p⟩ := Fin.ext h
      rw [hi]
      rfl
    · rw [if_neg (by omega)]
      have hi : i = ⟨1, stabFamily_one_lt p⟩ := Fin.ext h
      rw [hi]
      rfl
  rw [PlusWitnessFamily.L, hget]
  rcases stabFamily_index_cases p i with h | h
  · rw [if_pos h, if_pos h, PlusLabelledLasso.lab_def]
    exact unrollOf_singleton_mid _ _ u
  · rw [if_neg (by omega), if_neg (by omega), PlusLabelledLasso.lab_def]
    exact unrollOf_singleton_nil _ u

/-- **The witness's representative map at the origin** sends every index to `0`. -/
theorem stabFamily_rep_zero (i : Fin (stabFamily p).lassos.length) :
    ((stabFamily p).rep 0 i).val = 0 := by
  have hrep : (stabFamily p).rep 0
      = fun _ => (⟨0, stabFamily_zero_lt p⟩ : Fin (stabFamily p).lassos.length) :=
    @unrollOf_singleton_mid_zero _ (repIdInhabited (stabFamily p).lassos.length)
      id (fun _ => ⟨0, stabFamily_zero_lt p⟩)
  rw [hrep]

/-- **The witness's representative map away from the origin** is the identity. -/
theorem stabFamily_rep_ne {u : ℤ} (hu : u ≠ 0) (i : Fin (stabFamily p).lassos.length) :
    (stabFamily p).rep u i = i := by
  have hrep : (stabFamily p).rep u = id :=
    @unrollOf_singleton_mid_ne _ (repIdInhabited (stabFamily p).lassos.length)
      id (fun _ => ⟨0, stabFamily_zero_lt p⟩) u hu
  rw [hrep]
  rfl

/-- At the origin every pair of indices names the same world state: this is the branching. -/
theorem stabFamily_share_zero (i j : Fin (stabFamily p).lassos.length) :
    (stabFamily p).share 0 i j := by
  rw [(stabFamily p).share_def]
  exact Fin.ext (by rw [stabFamily_rep_zero, stabFamily_rep_zero])

/-- Away from the origin the sharing relation is equality. -/
theorem stabFamily_share_ne {u : ℤ} (hu : u ≠ 0) (i j : Fin (stabFamily p).lassos.length) :
    (stabFamily p).share u i j ↔ i = j := by
  rw [(stabFamily p).share_def, stabFamily_rep_ne p hu, stabFamily_rep_ne p hu]

/-- `⊡Fp` is in no label of the witness. It is kept out at the origin because (C5) forces it
out, and elsewhere only on lasso `1`, which carries nothing. -/
theorem stab_not_mem_stabLabelOrigin : PlusFormula.stab (stabEvent p) ∉ stabLabelOrigin p := by
  simp [stabLabelOrigin]

theorem stab_mem_stabLabelOff : PlusFormula.stab (stabEvent p) ∈ stabLabelOff p := by
  simp [stabLabelOff]

theorem event_mem_stabLabelOff : stabEvent p ∈ stabLabelOff p := by
  simp [stabLabelOff]

theorem event_mem_stabLabelOrigin : stabEvent p ∈ stabLabelOrigin p := by
  simp [stabLabelOrigin]

/-- **(C5) holds on the witness.** -/
theorem stabFamily_stabFaithful : (stabFamily p).StabFaithful := by
  intro i u φ hc
  rw [stab_mem_stabClosure_iff] at hc
  subst hc
  rcases eq_or_ne u 0 with rfl | hu
  · -- At the origin every index shares, and lasso `1` never carries `Fp`, so both sides fail.
    have hright : ¬ ∀ j : Fin (stabFamily p).lassos.length,
        (stabFamily p).share 0 i j → stabEvent p ∈ (stabFamily p).L j 0 := by
      intro hall
      have h1 := hall ⟨1, stabFamily_one_lt p⟩ (stabFamily_share_zero p i _)
      rw [stabFamily_L] at h1
      simp at h1
    rw [stabFamily_L]
    rcases stabFamily_index_cases p i with h | h
    · rw [if_pos h, if_pos rfl]
      exact iff_of_false (stab_not_mem_stabLabelOrigin p) hright
    · rw [if_neg (by omega)]
      exact iff_of_false (by simp) hright
  · -- Away from the origin sharing is equality, so (C5) reads `⊡Fp ∈ L i u ↔ Fp ∈ L i u`.
    have hright : (∀ j : Fin (stabFamily p).lassos.length,
        (stabFamily p).share u i j → stabEvent p ∈ (stabFamily p).L j u)
        ↔ stabEvent p ∈ (stabFamily p).L i u := by
      constructor
      · intro hall
        exact hall i ((stabFamily_share_ne p hu i i).mpr rfl)
      · intro hi j hij
        exact ((stabFamily_share_ne p hu i j).mp hij) ▸ hi
    rw [hright, stabFamily_L]
    rcases stabFamily_index_cases p i with h | h
    · rw [if_pos h, if_neg hu]
      exact iff_of_true (stab_mem_stabLabelOff p) (event_mem_stabLabelOff p)
    · rw [if_neg (by omega)]
      simp

/--
**(C5) is not vacuous and not box-shaped.**

On `stabFamily` the eventuality `Fp` is labelled at the main lasso's origin where `⊡Fp` is not,
so the condition is strictly stronger than the `box` clause — which reads one global Boolean and
therefore cannot distinguish `u = 0` from `u = 1` — and is not satisfied trivially.

Paper: — (a non-vacuity witness for a formalization-native condition; the paper states
no such family)
-/
theorem stabFamily_separates :
    (stabFamily p).StabFaithful ∧
      stabEvent p ∈ (stabFamily p).L (stabFamily p).toPlusWitnessFamily.mainIdx 0 ∧
      PlusFormula.stab (stabEvent p) ∉
        (stabFamily p).L (stabFamily p).toPlusWitnessFamily.mainIdx 0 := by
  have hmain : (stabFamily p).L (stabFamily p).toPlusWitnessFamily.mainIdx 0
      = stabLabelOrigin p := by
    rw [stabFamily_L]
    rfl
  refine ⟨stabFamily_stabFaithful p, ?_, ?_⟩
  · rw [hmain]; exact event_mem_stabLabelOrigin p
  · rw [hmain]; exact stab_not_mem_stabLabelOrigin p

end Witness

/-! ## The witness is accepted by computation

`stabFamily` is concrete, so `decidableStabFaithful` can be run on it rather than reasoned
about. This is the same check the smoke test in `Decide.lean` makes, on the family where the
branching actually does something. -/

section Computed

open FormalSystem.Syntax

/-- The atom the computed check runs at. -/
private def guardAtom : Atom := Atom.mkBase "p"

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
set_option linter.hashCommand false in
#guard @Decidable.decide _
  (PlusSharingWitnessFamily.decidableStabFaithful (stabFamily guardAtom))

end Computed

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
