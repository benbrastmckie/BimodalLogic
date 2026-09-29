/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Agreement

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
  transBack := transFullOf _ [id]
  transMid := transFullOf _ [fun _ => ⟨0, by simp⟩]
  transFwd := transFullOf _ [id]
  transBack_len := transFullOf_length _ _
  transMid_len := transFullOf_length _ _
  transFwd_len := transFullOf_length _ _
  trans_refl := transFullOf_refl _ _ _ _
  lift := liftable_of_transFullOf _ _ _ _ (by simp) (by simp)

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

/-! ## Family A: the `snce`-side certificate at non-trivial sharing

The separation the `trans` substrate exists to make expressible, exhibited. Two lassos that name
one world state from the origin on, yet whose succession relation is index-identity, so no thread
crosses between them. Under the pre-redesign (C1') that combination was impossible: the `snce`
clause quantified its predecessor over the whole `share`-class at `t`, which forced the two
indices to agree on every past-tense formula of the closure. Under the redesign the clause
quantifies over succession into `t`, which here is a singleton, and the two indices are free to
disagree.

What that buys is the target `Pp → ⊡Pp`. `Incompleteness.lean`'s `not_plusValidZTime_stabSnce`
says it is a genuine ℤ-time non-validity; before the redesign no six-condition family certified
any instance of it. `plusCertifies_stabSnce_example` is one.

The `lift` obligation is discharged by `liftable_of_constant_below`: below the origin every
`share`-class is a singleton, so a state path cannot move, and from the origin on every two
indices share, so the constant path at the value just below the origin tracks anything.
-/

section FamilyA

variable (p : Atom)

/-- `Pp := ⊤ S p`. -/
abbrev snceP : PlusFormula := PlusFormula.snce PlusFormula.top (.atom p)
/-- `⊡Pp`. -/
abbrev stabSnceP : PlusFormula := PlusFormula.stab (snceP p)
/-- The target `Pp → ⊡Pp`; definitionally `stabSnceTarget ⊤ (atom p)`. -/
abbrev targetA : PlusFormula := PlusFormula.imp (snceP p) (stabSnceP p)

/-- The closure of Family A's target. -/
abbrev closA : Finset PlusFormula := plusClosureOf (([] : PlusContext) ++ [targetA p])

/-- The closure of the target, enumerated. -/
theorem mem_closA (ψ : PlusFormula) :
    ψ ∈ closA p ↔ ψ = targetA p ∨ ψ = snceP p ∨ ψ = stabSnceP p ∨ ψ = PlusFormula.top ∨
      ψ = PlusFormula.bot ∨ ψ = PlusFormula.atom p := by
  rw [mem_plusClosureOf]
  simp only [List.nil_append, List.mem_singleton, exists_eq_left]
  rw [plusSubformulaClosure, List.mem_toFinset]
  simp only [PlusFormula.top, PlusFormula.subformulas, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false]
  tauto

theorem imp_mem_closA {a b : PlusFormula} (h : PlusFormula.imp a b ∈ closA p) :
    (a = snceP p ∧ b = stabSnceP p) ∨ (a = PlusFormula.bot ∧ b = PlusFormula.bot) := by
  rw [mem_closA] at h
  simp only [PlusFormula.top, PlusFormula.imp.injEq, reduceCtorEq, or_false] at h
  tauto

theorem snce_mem_closA {g e : PlusFormula} (h : PlusFormula.snce g e ∈ closA p) :
    g = PlusFormula.top ∧ e = PlusFormula.atom p := by
  rw [mem_closA] at h
  simp only [PlusFormula.top, PlusFormula.snce.injEq, reduceCtorEq, or_false, false_or] at h
  exact h

theorem untl_not_mem_closA {g e : PlusFormula} (h : PlusFormula.untl g e ∈ closA p) : False := by
  rw [mem_closA] at h
  simp only [PlusFormula.top, reduceCtorEq, or_false] at h

theorem box_not_mem_closA {χ : PlusFormula} (h : PlusFormula.box χ ∈ closA p) : False := by
  rw [mem_closA] at h
  simp only [PlusFormula.top, reduceCtorEq, or_false] at h

theorem stab_mem_closA {φ : PlusFormula} (h : PlusFormula.stab φ ∈ closA p) : φ = snceP p := by
  rw [mem_closA] at h
  simp only [PlusFormula.top, PlusFormula.stab.injEq, reduceCtorEq, or_false, false_or] at h
  exact h

/-- Lasso 0 off the origin, and lasso 1 on `[1, ∞)`: `{p, Pp, ⊡Pp, ⊤, T}`. -/
def a0b : Finset PlusFormula :=
  {PlusFormula.atom p, snceP p, stabSnceP p, PlusFormula.top, targetA p}
/-- Lasso 0 at the origin: `{p, Pp, ⊤}` — `⊡Pp` and hence the target absent. -/
def a0m : Finset PlusFormula := {PlusFormula.atom p, snceP p, PlusFormula.top}
/-- Lasso 1 on the negatives: `{⊤, T}`. -/
def a1b : Finset PlusFormula := {PlusFormula.top, targetA p}
/-- Lasso 1 at the origin: `{p, ⊤, T}` — `p` arrives, `Pp` not yet. -/
def a1m : Finset PlusFormula := {PlusFormula.atom p, PlusFormula.top, targetA p}

theorem a0b_sub : a0b p ⊆ closA p := by
  intro ψ h; rw [mem_closA]; simp only [a0b, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem a0m_sub : a0m p ⊆ closA p := by
  intro ψ h; rw [mem_closA]; simp only [a0m, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem a1b_sub : a1b p ⊆ closA p := by
  intro ψ h; rw [mem_closA]; simp only [a1b, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem a1m_sub : a1m p ⊆ closA p := by
  intro ψ h; rw [mem_closA]; simp only [a1m, Finset.mem_insert, Finset.mem_singleton] at h; tauto

/-- Lasso 0 of Family A. -/
def lassoA0 : PlusLabelledLasso (closA p) where
  back := [a0b p]
  mid := [a0m p]
  fwd := [a0b p]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl | rfl
    · exact a0b_sub p
    · exact a0m_sub p
    · exact a0b_sub p

/-- Lasso 1 of Family A. -/
def lassoA1 : PlusLabelledLasso (closA p) where
  back := [a1b p]
  mid := [a1m p]
  fwd := [a0b p]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl | rfl
    · exact a1b_sub p
    · exact a1m_sub p
    · exact a0b_sub p

/--
**Family A.** Separate on the negatives, one class on `[0, ∞)`, and succession is index-identity
throughout.
-/
def famA : PlusSharingWitnessFamily ([] : PlusContext) [targetA p] where
  bx := fun _ => false
  lassos := [lassoA0 p, lassoA1 p]
  lassos_ne := by simp
  repBack := [id]
  repMid := [fun _ => ⟨0, by simp⟩]
  repFwd := [fun _ => ⟨0, by simp⟩]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by
    intro f hf i
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hf
    rcases hf with rfl | rfl | rfl <;> rfl
  transBack := transIdOf _ [id]
  transMid := transIdOf _ [fun _ => ⟨0, by simp⟩]
  transFwd := transIdOf _ [fun _ => ⟨0, by simp⟩]
  transBack_len := transIdOf_length _ _
  transMid_len := transIdOf_length _ _
  transFwd_len := transIdOf_length _ _
  trans_refl := transIdOf_refl _ _ _ _
  lift := by
    refine liftable_of_constant_below _ _ _ _ _ _ _ 0 ?_ ?_ ?_
    · intro u hu i j h
      rw [shareOf, repOf_singletons, if_pos hu] at h
      exact h
    · intro u hu i j
      rw [shareOf, repOf_singletons, if_neg (not_lt.mpr hu)]
      split_ifs <;> rfl
    · intro u i
      rw [transMatOf_id]
      exact transId_refl _ _

@[simp] theorem famA_lassos_length : (famA p).lassos.length = 2 := rfl

theorem famA_zero_lt : 0 < (famA p).lassos.length :=
  (famA p).toPlusWitnessFamily.lassos_length_pos

theorem famA_one_lt : 1 < (famA p).lassos.length := by
  rw [famA_lassos_length]; omega

theorem famA_index_cases (i : Fin (famA p).lassos.length) : i.val = 0 ∨ i.val = 1 := by
  have h : i.val < 2 := i.isLt
  omega

/-- The labels, decoded. -/
theorem famA_L (i : Fin (famA p).lassos.length) (u : ℤ) :
    (famA p).L i u =
      if i.val = 0 then (if u < 0 then a0b p else if u = 0 then a0m p else a0b p)
      else (if u < 0 then a1b p else if u = 0 then a1m p else a0b p) := by
  have hget : (famA p).lassos.get i = if i.val = 0 then lassoA0 p else lassoA1 p := by
    rcases famA_index_cases p i with h | h
    · rw [if_pos h]
      have hi : i = ⟨0, famA_zero_lt p⟩ := Fin.ext h
      rw [hi]; rfl
    · rw [if_neg (by omega)]
      have hi : i = ⟨1, famA_one_lt p⟩ := Fin.ext h
      rw [hi]; rfl
  rw [PlusWitnessFamily.L, hget]
  rcases famA_index_cases p i with h | h
  · rw [if_pos h, if_pos h, PlusLabelledLasso.lab_def]
    exact unrollOf_singletons _ _ _ _ u
  · rw [if_neg (by omega), if_neg (by omega), PlusLabelledLasso.lab_def]
    exact unrollOf_singletons _ _ _ _ u

/-- The origin representative. -/
abbrev cA : Fin (famA p).lassos.length → Fin (famA p).lassos.length :=
  fun _ => ⟨0, famA_zero_lt p⟩

/-- The representative map: identity on the negatives, constant `0` from the origin on. -/
theorem famA_rep (u : ℤ) (i : Fin (famA p).lassos.length) :
    (famA p).rep u i = if u < 0 then i else ⟨0, famA_zero_lt p⟩ := by
  have hrep : (famA p).rep u = if u < 0 then id else if u = 0 then cA p else cA p :=
    repOf_singletons (famA p).lassos.length id (cA p) (cA p) u
  rw [hrep]
  split_ifs <;> rfl

theorem famA_share_neg {u : ℤ} (hu : u < 0) (i j : Fin (famA p).lassos.length) :
    (famA p).share u i j ↔ i = j := by
  rw [(famA p).share_def, famA_rep, famA_rep]
  simp [hu]

theorem famA_share_nonneg {u : ℤ} (hu : 0 ≤ u) (i j : Fin (famA p).lassos.length) :
    (famA p).share u i j := by
  rw [(famA p).share_def, famA_rep, famA_rep]
  simp [not_lt.mpr hu]

/-- The succession matrix decodes to the identity at every time. -/
theorem famA_transRaw (u : ℤ) :
    (famA p).transRaw u = transId (famA p).lassos.length :=
  transMatOf_id _ _ _ _ u

/--
**Succession in Family A is index-identity**, at every time, however much the indices share.
This is the whole point of the family: sharing is non-trivial from the origin on, and succession
is not.
-/
theorem famA_trans (u : ℤ) (i j : Fin (famA p).lassos.length) :
    (famA p).trans u i j ↔ i = j := by
  rw [(famA p).trans_def]
  constructor
  · rintro ⟨h, -⟩
    rw [famA_transRaw] at h
    exact transId_eq h
  · rintro rfl
    exact ⟨by rw [famA_transRaw]; exact transId_refl _ _, (famA p).share_refl _ _⟩

/-- Every thread of Family A is constant: succession never moves the index. -/
theorem famA_thread_const (θ : (famA p).Thread) (u v : ℤ) : θ.idx u = θ.idx v := by
  have hfwd : ∀ (n : ℕ) (w : ℤ), θ.idx (w + n) = θ.idx w := by
    intro n
    induction n with
    | zero => intro w; simp
    | succ n ih =>
      intro w
      have hs : θ.idx (w + n) = θ.idx (w + n + 1) :=
        (famA_trans p _ _ _).mp (Thread.step θ (w + n))
      rw [show w + ((n + 1 : ℕ) : ℤ) = w + n + 1 by omega, ← hs, ih w]
  rcases le_total u v with huv | huv
  · have := hfwd (v - u).toNat u
    rw [show u + (((v - u).toNat : ℕ) : ℤ) = v by omega] at this
    exact this.symm
  · have := hfwd (u - v).toNat v
    rw [show v + (((u - v).toNat : ℕ) : ℤ) = u by omega] at this
    exact this

/-- (C0) for Family A. -/
theorem famA_atomCoherent : (famA p).PlusAtomCoherent := by
  intro u i j hij q
  rcases lt_or_ge u 0 with hu | hu
  · rw [famA_share_neg p hu] at hij
    subst hij
    exact Iff.rfl
  · rw [famA_L, famA_L]
    rcases eq_or_lt_of_le hu with hu0 | hu0
    · subst hu0
      rcases famA_index_cases p i with hi | hi <;> rcases famA_index_cases p j with hj | hj <;>
        simp [hi, hj, a0m, a1m, PlusFormula.top]
    · rcases famA_index_cases p i with hi | hi <;> rcases famA_index_cases p j with hj | hj <;>
        simp [hi, hj, not_lt.mpr hu, hu0.ne', a0b]

/-- (C1') for Family A. -/
theorem famA_plusLocalCoherentShare : (famA p).PlusLocalCoherentShare := by
  intro i t
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · rw [famA_L]
    split_ifs <;> simp [a0b, a0m, a1b, a1m, PlusFormula.top]
  · intro a b hab
    rcases imp_mem_closA p hab with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · rw [famA_L]
      split_ifs <;> simp [a0b, a0m, a1b, a1m, PlusFormula.top]
    · rw [famA_L]
      split_ifs <;> simp [a0b, a0m, a1b, a1m, PlusFormula.top]
  · intro χ hχ
    exact (box_not_mem_closA p hχ).elim
  · intro j _ g e hge
    exact (untl_not_mem_closA p hge).elim
  · intro k hki g e hge
    obtain ⟨rfl, rfl⟩ := snce_mem_closA p hge
    rw [famA_trans] at hki
    subst hki
    rw [famA_L, famA_L]
    rcases famA_index_cases p k with hk | hk
    · simp only [hk, if_true]
      rcases lt_trichotomy t 0 with ht | ht | ht
      · simp [ht, show t - 1 < 0 by omega, a0b, PlusFormula.top]
      · subst ht
        simp [a0b, a0m, PlusFormula.top]
      · rcases eq_or_lt_of_le (show 1 ≤ t by omega) with ht1 | ht1
        · subst ht1
          simp [a0b, a0m, PlusFormula.top]
        · simp [not_lt.mpr ht.le, ht.ne', show ¬ t - 1 < 0 by omega,
            show t - 1 ≠ 0 by omega, a0b, PlusFormula.top]
    · simp only [hk, one_ne_zero, if_false]
      rcases lt_trichotomy t 0 with ht | ht | ht
      · simp [ht, show t - 1 < 0 by omega, a1b, PlusFormula.top]
      · subst ht
        simp [a1b, a1m, PlusFormula.top]
      · rcases eq_or_lt_of_le (show 1 ≤ t by omega) with ht1 | ht1
        · subst ht1
          simp [a0b, a1m, PlusFormula.top]
        · simp [not_lt.mpr ht.le, ht.ne', show ¬ t - 1 < 0 by omega,
            show t - 1 ≠ 0 by omega, a0b, PlusFormula.top]

/-- (C2') for Family A. -/
theorem famA_plusThreadFulfilling : (famA p).PlusThreadFulfilling := by
  refine ⟨fun i u g e hmem θ _ => ?_, fun i u g e hmem θ hθ => ?_⟩
  · exact (untl_not_mem_closA p ((famA p).subset_plusClosureOf i u hmem)).elim
  · obtain ⟨rfl, rfl⟩ := snce_mem_closA p ((famA p).subset_plusClosureOf i u hmem)
    have hconst : ∀ r, θ.idx r = i := fun r => (famA_thread_const p θ r u).trans hθ
    rcases famA_index_cases p i with hi | hi
    · refine ⟨u - 1, by omega, ?_, fun r h1 h2 => by omega⟩
      rw [hconst, famA_L]
      simp only [hi, if_true]
      split_ifs <;> simp [a0b, a0m]
    · have hu : 1 ≤ u := by
        rw [famA_L] at hmem
        simp only [hi, one_ne_zero, if_false] at hmem
        by_contra hlt
        rcases lt_or_ge u 0 with hu0 | hu0
        · simp [hu0, a1b, PlusFormula.top] at hmem
        · have hu0' : u = 0 := by omega
          simp [hu0', a1m, PlusFormula.top] at hmem
      refine ⟨0, by omega, ?_, fun r h1 h2 => ?_⟩
      · rw [hconst, famA_L]
        simp [hi, a1m]
      · rw [hconst, famA_L]
        simp only [hi, one_ne_zero, if_false]
        simp [not_lt.mpr h1.le, h1.ne', a0b]

/-- (C3) for Family A: vacuous, no `box` in the closure. -/
theorem famA_boxFaithful : (famA p).toPlusWitnessFamily.PlusBoxFaithful :=
  fun _χ hχ => (box_not_mem_closA p hχ).elim

/-- (C4) for Family A at `t = 0`. -/
theorem famA_target : (famA p).toPlusWitnessFamily.PlusTarget 0 := by
  refine ⟨fun γ hγ => (List.not_mem_nil hγ).elim, fun σ hσ => ?_⟩
  have hσ' : σ = targetA p := by simpa using hσ
  subst hσ'
  change targetA p ∉ (famA p).L (famA p).toPlusWitnessFamily.mainIdx 0
  rw [famA_L]
  simp [PlusWitnessFamily.mainIdx, a0m, PlusFormula.top]

/-- (C5) for Family A. -/
theorem famA_stabFaithful : (famA p).StabFaithful := by
  intro i u φ hc
  obtain rfl := stab_mem_closA p hc
  rcases lt_or_ge u 0 with hu | hu
  · have hright : (∀ j, (famA p).share u i j → snceP p ∈ (famA p).L j u) ↔
        snceP p ∈ (famA p).L i u := by
      constructor
      · intro h; exact h i ((famA_share_neg p hu i i).mpr rfl)
      · intro h j hij
        rw [famA_share_neg p hu] at hij
        exact hij ▸ h
    rw [hright, famA_L]
    rcases famA_index_cases p i with hi | hi
    · simp [hi, hu, a0b]
    · simp [hi, hu, a1b, PlusFormula.top]
  · rcases eq_or_lt_of_le hu with hu0 | hu0
    · subst hu0
      have hright : ¬ ∀ j, (famA p).share 0 i j → snceP p ∈ (famA p).L j 0 := by
        intro h
        have := h ⟨1, famA_one_lt p⟩ (famA_share_nonneg p le_rfl _ _)
        rw [famA_L] at this
        simp [a1m, PlusFormula.top] at this
      rw [famA_L]
      rcases famA_index_cases p i with hi | hi
      · simp only [hi, if_true, lt_irrefl, if_false]
        exact iff_of_false (by simp [a0m, PlusFormula.top]) hright
      · simp only [hi, one_ne_zero, if_false, lt_irrefl]
        exact iff_of_false (by simp [a1m, PlusFormula.top]) hright
    · have hright : ∀ j, (famA p).share u i j → snceP p ∈ (famA p).L j u := by
        intro j _
        rw [famA_L]
        rcases famA_index_cases p j with hj | hj <;>
          simp [hj, not_lt.mpr hu, hu0.ne', a0b]
      rw [famA_L]
      rcases famA_index_cases p i with hi | hi
      · simp only [hi, if_true, not_lt.mpr hu, hu0.ne', if_false]
        exact iff_of_true (by simp [a0b]) hright
      · simp only [hi, one_ne_zero, if_false, not_lt.mpr hu, hu0.ne']
        exact iff_of_true (by simp [a0b]) hright

/--
**Family A is a six-condition certificate for `Pp → ⊡Pp` at non-trivial sharing.**

The positive half of the redesign's evidence. Every condition of `PlusCertifies` holds at
`t = 0`, and `famA_share_nonneg` together with `famA_separates_snce` shows the sharing is not
degenerate: indices `0` and `1` name one state at the origin and disagree on `Pp` there.

Paper: — (a formalization-native construction; the paper states no such result)
-/
theorem plusCertifies_stabSnce_example : (famA p).PlusCertifies 0 :=
  ⟨famA_atomCoherent p, ⟨famA_plusLocalCoherentShare p, famA_plusThreadFulfilling p⟩,
    famA_boxFaithful p, famA_target p, famA_stabFaithful p⟩

/--
**The sharing is non-trivial, and the old congruence fails on it.** Indices `0` and `1` name one
world state at the origin, and exactly one of them carries `Pp` there.
-/
theorem famA_separates_snce :
    (famA p).share 0 ⟨0, famA_zero_lt p⟩ ⟨1, famA_one_lt p⟩ ∧
      snceP p ∈ (famA p).L ⟨0, famA_zero_lt p⟩ 0 ∧
      snceP p ∉ (famA p).L ⟨1, famA_one_lt p⟩ 0 := by
  refine ⟨famA_share_nonneg p le_rfl _ _, ?_, ?_⟩
  · rw [famA_L]; simp [a0m]
  · rw [famA_L]; simp [a1m, PlusFormula.top]

end FamilyA


/-! ## Family B: the `untl`-side certificate at non-trivial sharing

Family A's mirror image, closing the second temporal direction. Two lassos that name one world
state up to and including the origin and separate from time `1` on, with succession again
index-identity. The retired `untl_shift_share_congr` read the `untl` clause at `t - 1`, where
`share t i j` *is* `share ((t-1)+1) i j`, and recovered the same forced class agreement the
`snce` side had — which is why re-timing one clause to match the other was never a repair. Under
the redesign the clause reads succession out of `t - 1`, a singleton here, and the two indices
are free to disagree on the unfolding.

The `lift` obligation goes through `liftable_of_constant_above`, the cut at `1`: above it every
`share`-class is a singleton so a state path cannot move, and below it every two indices share.
-/

section FamilyB

variable (p : Atom)

/-- `Fp := ⊤ U p`. -/
abbrev untlP : PlusFormula := PlusFormula.untl PlusFormula.top (.atom p)
/-- `¬p`. -/
abbrev notP : PlusFormula := PlusFormula.imp (.atom p) .bot
/-- `¬p → ⊡Fp`, the target's consequent. -/
abbrev innerB : PlusFormula := PlusFormula.imp (notP p) (PlusFormula.stab (untlP p))
/-- The target `Fp → (¬p → ⊡Fp)`; definitionally `stabUntlTarget p`. -/
abbrev targetB : PlusFormula := PlusFormula.imp (untlP p) (innerB p)

/-- The closure of Family B's target. -/
abbrev closB : Finset PlusFormula := plusClosureOf (([] : PlusContext) ++ [targetB p])

/-- The closure of the target, enumerated. -/
theorem mem_closB (ψ : PlusFormula) :
    ψ ∈ closB p ↔ ψ = targetB p ∨ ψ = untlP p ∨ ψ = innerB p ∨ ψ = notP p ∨
      ψ = PlusFormula.stab (untlP p) ∨ ψ = PlusFormula.top ∨ ψ = PlusFormula.bot ∨
      ψ = PlusFormula.atom p := by
  rw [mem_plusClosureOf]
  simp only [List.nil_append, List.mem_singleton, exists_eq_left]
  rw [plusSubformulaClosure, List.mem_toFinset]
  simp only [PlusFormula.top, PlusFormula.subformulas, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false]
  tauto

theorem imp_mem_closB {a b : PlusFormula} (h : PlusFormula.imp a b ∈ closB p) :
    (a = untlP p ∧ b = innerB p) ∨ (a = notP p ∧ b = PlusFormula.stab (untlP p)) ∨
    (a = PlusFormula.atom p ∧ b = PlusFormula.bot) ∨
    (a = PlusFormula.bot ∧ b = PlusFormula.bot) := by
  rw [mem_closB] at h
  simp only [PlusFormula.top, PlusFormula.imp.injEq, reduceCtorEq, or_false] at h
  tauto

theorem untl_mem_closB {g e : PlusFormula} (h : PlusFormula.untl g e ∈ closB p) :
    g = PlusFormula.top ∧ e = PlusFormula.atom p := by
  rw [mem_closB] at h
  simp only [PlusFormula.top, PlusFormula.untl.injEq, reduceCtorEq, or_false, false_or] at h
  exact h

theorem snce_not_mem_closB {g e : PlusFormula} (h : PlusFormula.snce g e ∈ closB p) : False := by
  rw [mem_closB] at h
  simp only [PlusFormula.top, reduceCtorEq, or_false] at h

theorem box_not_mem_closB {χ : PlusFormula} (h : PlusFormula.box χ ∈ closB p) : False := by
  rw [mem_closB] at h
  simp only [PlusFormula.top, reduceCtorEq, or_false] at h

theorem stab_mem_closB {φ : PlusFormula} (h : PlusFormula.stab φ ∈ closB p) : φ = untlP p := by
  rw [mem_closB] at h
  simp only [PlusFormula.top, PlusFormula.stab.injEq, reduceCtorEq, or_false, false_or] at h
  exact h

/-- Lasso 0 on `(-∞, 0]`: `{Fp, ¬p, ⊤}`. -/
def b0n : Finset PlusFormula := {untlP p, notP p, PlusFormula.top}
/-- Lasso 0 on `[1, ∞)`: `{p, Fp, ⊡Fp, ¬p → ⊡Fp, U, ⊤}`. -/
def b0f : Finset PlusFormula :=
  {PlusFormula.atom p, untlP p, PlusFormula.stab (untlP p), innerB p, targetB p,
    PlusFormula.top}
/-- Lasso 1 everywhere: `{¬p, U, ⊤}`. -/
def b1 : Finset PlusFormula := {notP p, targetB p, PlusFormula.top}

theorem b0n_sub : b0n p ⊆ closB p := by
  intro ψ h; rw [mem_closB]; simp only [b0n, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem b0f_sub : b0f p ⊆ closB p := by
  intro ψ h; rw [mem_closB]; simp only [b0f, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem b1_sub : b1 p ⊆ closB p := by
  intro ψ h; rw [mem_closB]; simp only [b1, Finset.mem_insert, Finset.mem_singleton] at h; tauto

/-- Lasso 0 of Family B. -/
def lassoB0 : PlusLabelledLasso (closB p) where
  back := [b0n p]
  mid := [b0n p]
  fwd := [b0f p]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl | rfl
    · exact b0n_sub p
    · exact b0n_sub p
    · exact b0f_sub p

/-- Lasso 1 of Family B. -/
def lassoB1 : PlusLabelledLasso (closB p) where
  back := [b1 p]
  mid := [b1 p]
  fwd := [b1 p]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl | rfl <;> exact b1_sub p

/--
**Family B.** One class on `(-∞, 0]`, separate on `[1, ∞)`, and succession is index-identity
throughout.
-/
def famB : PlusSharingWitnessFamily ([] : PlusContext) [targetB p] where
  bx := fun _ => false
  lassos := [lassoB0 p, lassoB1 p]
  lassos_ne := by simp
  repBack := [fun _ => ⟨0, by simp⟩]
  repMid := [fun _ => ⟨0, by simp⟩]
  repFwd := [id]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by
    intro f hf i
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hf
    rcases hf with rfl | rfl | rfl <;> rfl
  transBack := transIdOf _ [fun _ => ⟨0, by simp⟩]
  transMid := transIdOf _ [fun _ => ⟨0, by simp⟩]
  transFwd := transIdOf _ [id]
  transBack_len := transIdOf_length _ _
  transMid_len := transIdOf_length _ _
  transFwd_len := transIdOf_length _ _
  trans_refl := transIdOf_refl _ _ _ _
  lift := by
    refine liftable_of_constant_above _ _ _ _ _ _ _ 1 ?_ ?_ ?_
    · intro u hu i j h
      rw [shareOf, repOf_singletons, if_neg (by omega), if_neg (by omega)] at h
      exact h
    · intro u hu i j
      rw [shareOf, repOf_singletons]
      split_ifs with h1 h2 <;> first | rfl | (exfalso; omega)
    · intro u i
      rw [transMatOf_id]
      exact transId_refl _ _

@[simp] theorem famB_lassos_length : (famB p).lassos.length = 2 := rfl

theorem famB_zero_lt : 0 < (famB p).lassos.length :=
  (famB p).toPlusWitnessFamily.lassos_length_pos

theorem famB_one_lt : 1 < (famB p).lassos.length := by
  rw [famB_lassos_length]; omega

theorem famB_index_cases (i : Fin (famB p).lassos.length) : i.val = 0 ∨ i.val = 1 := by
  have h : i.val < 2 := i.isLt
  omega

/-- The labels, decoded by the three-segment scheme. -/
theorem famB_L_raw (i : Fin (famB p).lassos.length) (u : ℤ) :
    (famB p).L i u =
      if i.val = 0 then (if u < 0 then b0n p else if u = 0 then b0n p else b0f p)
      else (if u < 0 then b1 p else if u = 0 then b1 p else b1 p) := by
  have hget : (famB p).lassos.get i = if i.val = 0 then lassoB0 p else lassoB1 p := by
    rcases famB_index_cases p i with h | h
    · rw [if_pos h]
      have hi : i = ⟨0, famB_zero_lt p⟩ := Fin.ext h
      rw [hi]; rfl
    · rw [if_neg (by omega)]
      have hi : i = ⟨1, famB_one_lt p⟩ := Fin.ext h
      rw [hi]; rfl
  rw [PlusWitnessFamily.L, hget]
  rcases famB_index_cases p i with h | h
  · rw [if_pos h, if_pos h, PlusLabelledLasso.lab_def]
    exact unrollOf_singletons _ _ _ _ u
  · rw [if_neg (by omega), if_neg (by omega), PlusLabelledLasso.lab_def]
    exact unrollOf_singletons _ _ _ _ u

/-- The labels, in the two-way form every consumer below uses. -/
theorem famB_L (i : Fin (famB p).lassos.length) (u : ℤ) :
    (famB p).L i u = if i.val = 0 then (if 0 < u then b0f p else b0n p) else b1 p := by
  rw [famB_L_raw]
  split_ifs <;> first | rfl | omega

/-- The pre-origin representative. -/
abbrev cB : Fin (famB p).lassos.length → Fin (famB p).lassos.length :=
  fun _ => ⟨0, famB_zero_lt p⟩

/-- The representative map: constant `0` up to the origin, identity after it. -/
theorem famB_rep (u : ℤ) (i : Fin (famB p).lassos.length) :
    (famB p).rep u i = if 0 < u then i else ⟨0, famB_zero_lt p⟩ := by
  have hrep : (famB p).rep u = if u < 0 then cB p else if u = 0 then cB p else id :=
    repOf_singletons (famB p).lassos.length (cB p) (cB p) id u
  rw [hrep]
  split_ifs <;> first | rfl | omega

theorem famB_share_pos {u : ℤ} (hu : 0 < u) (i j : Fin (famB p).lassos.length) :
    (famB p).share u i j ↔ i = j := by
  rw [(famB p).share_def, famB_rep, famB_rep]
  simp [hu]

theorem famB_share_nonpos {u : ℤ} (hu : u ≤ 0) (i j : Fin (famB p).lassos.length) :
    (famB p).share u i j := by
  rw [(famB p).share_def, famB_rep, famB_rep]
  simp [not_lt.mpr hu]

/-- The succession matrix decodes to the identity at every time. -/
theorem famB_transRaw (u : ℤ) :
    (famB p).transRaw u = transId (famB p).lassos.length :=
  transMatOf_id _ _ _ _ u

/-- **Succession in Family B is index-identity**, at every time. -/
theorem famB_trans (u : ℤ) (i j : Fin (famB p).lassos.length) :
    (famB p).trans u i j ↔ i = j := by
  rw [(famB p).trans_def]
  constructor
  · rintro ⟨h, -⟩
    rw [famB_transRaw] at h
    exact transId_eq h
  · rintro rfl
    exact ⟨by rw [famB_transRaw]; exact transId_refl _ _, (famB p).share_refl _ _⟩

/-- Every thread of Family B is constant. -/
theorem famB_thread_const (θ : (famB p).Thread) (u v : ℤ) : θ.idx u = θ.idx v := by
  have hfwd : ∀ (n : ℕ) (w : ℤ), θ.idx (w + n) = θ.idx w := by
    intro n
    induction n with
    | zero => intro w; simp
    | succ n ih =>
      intro w
      have hs : θ.idx (w + n) = θ.idx (w + n + 1) :=
        (famB_trans p _ _ _).mp (Thread.step θ (w + n))
      rw [show w + ((n + 1 : ℕ) : ℤ) = w + n + 1 by omega, ← hs, ih w]
  rcases le_total u v with huv | huv
  · have := hfwd (v - u).toNat u
    rw [show u + (((v - u).toNat : ℕ) : ℤ) = v by omega] at this
    exact this.symm
  · have := hfwd (u - v).toNat v
    rw [show v + (((u - v).toNat : ℕ) : ℤ) = u by omega] at this
    exact this

/-- (C0) for Family B. -/
theorem famB_atomCoherent : (famB p).PlusAtomCoherent := by
  intro u i j hij q
  rcases lt_or_ge 0 u with hu | hu
  · rw [famB_share_pos p hu] at hij
    subst hij
    exact Iff.rfl
  · rw [famB_L, famB_L]
    rcases famB_index_cases p i with hi | hi <;> rcases famB_index_cases p j with hj | hj <;>
      simp [hi, hj, not_lt.mpr hu, b0n, b1, PlusFormula.top]

/-- (C1') for Family B. -/
theorem famB_plusLocalCoherentShare : (famB p).PlusLocalCoherentShare := by
  intro i t
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · rw [famB_L]
    split_ifs <;> simp [b0n, b0f, b1, PlusFormula.top]
  · intro a b hab
    rcases imp_mem_closB p hab with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;>
      · rw [famB_L]
        split_ifs <;> simp [b0n, b0f, b1, PlusFormula.top]
  · intro χ hχ
    exact (box_not_mem_closB p hχ).elim
  · intro j hij g e hge
    obtain ⟨rfl, rfl⟩ := untl_mem_closB p hge
    rw [famB_trans] at hij
    subst hij
    rw [famB_L, famB_L]
    rcases famB_index_cases p i with hi | hi
    · simp only [hi, if_true]
      rcases lt_or_ge 0 t with ht | ht
      · simp [ht, show 0 < t + 1 by omega, b0f, PlusFormula.top]
      · rcases eq_or_lt_of_le ht with ht0 | ht0
        · subst ht0
          simp [b0n, b0f, PlusFormula.top]
        · simp [not_lt.mpr ht, show ¬ 0 < t + 1 by omega, b0n, PlusFormula.top]
    · simp only [hi, one_ne_zero, if_false]
      simp [b1, PlusFormula.top]
  · intro k _ g e hge
    exact (snce_not_mem_closB p hge).elim

/-- (C2') for Family B. -/
theorem famB_plusThreadFulfilling : (famB p).PlusThreadFulfilling := by
  refine ⟨fun i u g e hmem θ hθ => ?_, fun i u g e hmem θ _ => ?_⟩
  · obtain ⟨rfl, rfl⟩ := untl_mem_closB p ((famB p).subset_plusClosureOf i u hmem)
    have hconst : ∀ r, θ.idx r = i := fun r => (famB_thread_const p θ r u).trans hθ
    rcases famB_index_cases p i with hi | hi
    · refine ⟨(u.natAbs : ℤ) + 1, by omega, ?_, fun r _ _ => ?_⟩
      · rw [hconst, famB_L]
        simp only [hi, if_true]
        rw [if_pos (by omega)]
        simp [b0f]
      · rw [hconst, famB_L]
        simp only [hi, if_true]
        split_ifs <;> simp [b0n, b0f, PlusFormula.top]
    · exfalso
      rw [famB_L] at hmem
      simp only [hi, one_ne_zero, if_false] at hmem
      simp [b1, PlusFormula.top] at hmem
  · exact (snce_not_mem_closB p ((famB p).subset_plusClosureOf i u hmem)).elim

/-- (C3) for Family B: vacuous, no `box` in the closure. -/
theorem famB_boxFaithful : (famB p).toPlusWitnessFamily.PlusBoxFaithful :=
  fun _χ hχ => (box_not_mem_closB p hχ).elim

/-- (C4) for Family B at `t = 0`. -/
theorem famB_target : (famB p).toPlusWitnessFamily.PlusTarget 0 := by
  refine ⟨fun γ hγ => (List.not_mem_nil hγ).elim, fun σ hσ => ?_⟩
  have hσ' : σ = targetB p := by simpa using hσ
  subst hσ'
  change targetB p ∉ (famB p).L (famB p).toPlusWitnessFamily.mainIdx 0
  rw [famB_L]
  simp [PlusWitnessFamily.mainIdx, b0n, PlusFormula.top]

/-- (C5) for Family B. -/
theorem famB_stabFaithful : (famB p).StabFaithful := by
  intro i u φ hc
  obtain rfl := stab_mem_closB p hc
  rcases lt_or_ge 0 u with hu | hu
  · have hright : (∀ j, (famB p).share u i j → untlP p ∈ (famB p).L j u) ↔
        untlP p ∈ (famB p).L i u := by
      constructor
      · intro h; exact h i ((famB_share_pos p hu i i).mpr rfl)
      · intro h j hij
        rw [famB_share_pos p hu] at hij
        exact hij ▸ h
    rw [hright, famB_L]
    rcases famB_index_cases p i with hi | hi
    · simp [hi, hu, b0f]
    · simp [hi, b1, PlusFormula.top]
  · have hright : ¬ ∀ j, (famB p).share u i j → untlP p ∈ (famB p).L j u := by
      intro h
      have := h ⟨1, famB_one_lt p⟩ (famB_share_nonpos p hu _ _)
      rw [famB_L] at this
      simp [b1, PlusFormula.top] at this
    rw [famB_L]
    rcases famB_index_cases p i with hi | hi
    · simp only [hi, if_true, not_lt.mpr hu, if_false]
      exact iff_of_false (by simp [b0n, PlusFormula.top]) hright
    · simp only [hi, one_ne_zero, if_false]
      exact iff_of_false (by simp [b1, PlusFormula.top]) hright

/--
**Family B is a six-condition certificate for `Fp → (¬p → ⊡Fp)` at non-trivial sharing.**

The `untl`-side twin of `plusCertifies_stabSnce_example`, closing the second temporal direction.
`famB_separates_untl` shows the sharing is not degenerate: indices `0` and `1` name one state at
the origin and disagree on the one-step unfolding of `Fp` there.

Paper: — (a formalization-native construction; the paper states no such result)
-/
theorem plusCertifies_stabUntl_example : (famB p).PlusCertifies 0 :=
  ⟨famB_atomCoherent p, ⟨famB_plusLocalCoherentShare p, famB_plusThreadFulfilling p⟩,
    famB_boxFaithful p, famB_target p, famB_stabFaithful p⟩

/--
**The sharing is non-trivial, and the old shifted congruence fails on it.** Indices `0` and `1`
name one world state at the origin; the first carries `⊤` and `Fp` there and the second carries
neither `p` nor `Fp`, so they disagree on the unfolding `p ∨ (⊤ ∧ Fp)`.
-/
theorem famB_separates_untl :
    (famB p).share 0 ⟨0, famB_zero_lt p⟩ ⟨1, famB_one_lt p⟩ ∧
      (PlusFormula.top ∈ (famB p).L ⟨0, famB_zero_lt p⟩ 0 ∧
        untlP p ∈ (famB p).L ⟨0, famB_zero_lt p⟩ 0) ∧
      (PlusFormula.atom p ∉ (famB p).L ⟨1, famB_one_lt p⟩ 0 ∧
        untlP p ∉ (famB p).L ⟨1, famB_one_lt p⟩ 0) := by
  refine ⟨famB_share_nonpos p le_rfl _ _, ⟨?_, ?_⟩, ?_, ?_⟩
  · rw [famB_L]; simp [b0n, PlusFormula.top]
  · rw [famB_L]; simp [b0n]
  · rw [famB_L]; simp [b1, PlusFormula.top]
  · rw [famB_L]; simp [b1, PlusFormula.top]

end FamilyB

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
