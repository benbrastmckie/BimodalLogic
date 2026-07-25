/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.Decidability.Propositional.Kalmar
import Bimodal.Metalogic.Soundness
import Bimodal.Semantics.WorldHistory
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.Basic

/-!
# Decidable - Concrete Decidability for Propositional Formulas

This module provides `Decidable (|-! p)` for concrete formulas `p` whose skeleton is purely
propositional (`Formula.isPropositional p = true`, i.e. built only from `atom`/`bot`/`imp`).

The `true`-branch (`p` a tautology) uses `tautology_derivable` (`Kalmar.lean`) via the
round-trip reification lemma. The `false`-branch (`p` not a tautology) uses a *semantic*
falsity direction: a falsifying assignment `v` yields a countermodel on the trivial task
frame (`TaskFrame.trivial_frame`, `Semantics/WorldHistory.lean`), and the EXISTING semantic
soundness theorem (`Metalogic/Soundness.lean`) rules out `|-! p` in that case. This is
deliberately *not* the tableau decision procedure (`Metalogic/Decidability/DecisionProcedure`)
— that procedure is classical-only (`Classical.em`) and unverified for this purpose; this
module's niche is the kernel-checkable propositional reflection procedure, and the countermodel
argument here reuses only the already-verified, sorry-free semantic soundness theorem.
-/

namespace Bimodal.Metalogic.Decidability.Propositional

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/-! ## `isPropositional` and Reification -/

/-- `true` iff `φ` is built only from `atom`/`bot`/`imp` (no `box`/`untl`/`snce`). Called as
`isPropositional φ` (not dot notation — this is defined outside `Formula`'s home namespace
`Bimodal.Syntax`, so `φ.isPropositional` would not resolve). -/
def isPropositional : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => isPropositional φ && isPropositional ψ
  | .box _ => false
  | .untl _ _ => false
  | .snce _ _ => false

/-- Locate `a` in `atomList`, returning `0` if absent (junk value; only used when
membership is already established by the caller). -/
def findIdxAtom (a : Atom) : List Atom → Nat
  | [] => 0
  | b :: bs => if a = b then 0 else (findIdxAtom a bs) + 1

/-- Correctness of `findIdxAtom`: if `a` occurs in `atomList`, indexing the corresponding
`Formula.atom`-mapped list at `findIdxAtom a atomList` recovers `Formula.atom a`. -/
theorem findIdxAtom_correct (atomList : List Atom) (a : Atom) (h : a ∈ atomList) :
    (atomList.map Formula.atom).getD (findIdxAtom a atomList) Formula.bot = Formula.atom a := by
  induction atomList with
  | nil => cases h
  | cons b bs ih =>
      by_cases hab : a = b
      · subst hab
        simp [findIdxAtom]
      · have h' : a ∈ bs := by
          rcases List.mem_cons.mp h with h1 | h2
          · exact absurd h1 hab
          · exact h2
        simp only [findIdxAtom, if_neg hab, List.map_cons, List.getD_cons_succ]
        exact ih h'

/-- Reify a formula against a *fixed* atom list (no accumulator growth — the list is
determined once, up front, from the whole formula's `atoms` set). Non-propositional
subterms (`box`/`untl`/`snce`) are mapped arbitrarily (`PropForm.fls`); they never occur
under the `isPropositional = true` hypothesis used by the correctness lemma below. -/
def reifyWith (atomList : List Atom) : Formula → PropForm
  | .atom a => PropForm.var (findIdxAtom a atomList)
  | .bot => PropForm.fls
  | .imp φ ψ => PropForm.imp (reifyWith atomList φ) (reifyWith atomList ψ)
  | .box _ => PropForm.fls
  | .untl _ _ => PropForm.fls
  | .snce _ _ => PropForm.fls

/-- The schematic environment built from a fixed atom list: index `n` denotes the `n`-th
atom's `Formula.atom` reflection, defaulting to `⊥` beyond the list. -/
def envFromAtomList (atomList : List Atom) : Nat → Formula :=
  fun n => (atomList.map Formula.atom).getD n Formula.bot

/-- Computable, deduplicated list of atoms occurring in a formula (a `List`-valued analogue
of `Formula.atoms : Finset Atom` — used instead of `Formula.atoms.toList` because
`Finset.toList` is `noncomputable` in this Mathlib build, which would otherwise block kernel
`decide` on concrete `reify`-based tautology checks). -/
def formulaAtomsList : Formula → List Atom
  | .atom a => [a]
  | .bot => []
  | .imp φ ψ => (formulaAtomsList φ ++ formulaAtomsList ψ).dedup
  | .box φ => formulaAtomsList φ
  | .untl φ ψ => (formulaAtomsList φ ++ formulaAtomsList ψ).dedup
  | .snce φ ψ => (formulaAtomsList φ ++ formulaAtomsList ψ).dedup

theorem mem_formulaAtomsList_imp {φ ψ : Formula} {a : Atom} :
    a ∈ formulaAtomsList (φ.imp ψ) ↔ a ∈ formulaAtomsList φ ∨ a ∈ formulaAtomsList ψ := by
  simp [formulaAtomsList]

/-- Reification of `p`, pairing the reified `PropForm` skeleton with its environment, using
the computable `formulaAtomsList p` as the fixed atom list. Called as `reify p` (see
`isPropositional` docstring for the dot-notation-namespace note). Fully computable — kernel
`decide` reduces `(reify p).1.isTaut` for concrete `p`. -/
def reify (p : Formula) : PropForm × (Nat → Formula) :=
  (reifyWith (formulaAtomsList p) p, envFromAtomList (formulaAtomsList p))

/-- Round-trip correctness of `reifyWith` against any atom list covering `q`'s atoms:
denoting the reification recovers `q`, provided `q` is purely propositional. -/
theorem reifyWith_correct (atomList : List Atom) :
    ∀ q : Formula, isPropositional q = true → (∀ a, a ∈ formulaAtomsList q → a ∈ atomList) →
      (reifyWith atomList q).denote (envFromAtomList atomList) = q := by
  intro q
  induction q with
  | atom a =>
      intro _ hsub
      have ha : a ∈ atomList := hsub a (by simp [formulaAtomsList])
      show (PropForm.var (findIdxAtom a atomList)).denote (envFromAtomList atomList)
          = Formula.atom a
      rw [PropForm.denote_var]
      exact findIdxAtom_correct atomList a ha
  | bot => intro _ _; rfl
  | imp φ ψ ihφ ihψ =>
      intro hprop hsub
      have hpair : isPropositional φ = true ∧ isPropositional ψ = true := by
        simpa [isPropositional, Bool.and_eq_true_iff] using hprop
      have hφeq := ihφ hpair.1
        (fun a ha => hsub a (mem_formulaAtomsList_imp.mpr (Or.inl ha)))
      have hψeq := ihψ hpair.2
        (fun a ha => hsub a (mem_formulaAtomsList_imp.mpr (Or.inr ha)))
      simp [reifyWith, hφeq, hψeq]
  | box φ _ => intro hprop _; simp [isPropositional] at hprop
  | untl φ ψ _ _ => intro hprop _; simp [isPropositional] at hprop
  | snce φ ψ _ _ => intro hprop _; simp [isPropositional] at hprop

/-- Round-trip lemma for `reify`: denoting the reification of a purely propositional `p`
recovers `p`. -/
theorem reify_denote (p : Formula) (hp : isPropositional p = true) :
    (reify p).1.denote (reify p).2 = p :=
  reifyWith_correct (formulaAtomsList p) p hp (fun _ ha => ha)

/-! ## Trivial-Frame Countermodel -/

/-- The trivial task model over `Int`, with atom valuation determined by a `Nat`-indexed
`PropForm` assignment `v` composed with `findIdxAtom` against a fixed atom list. -/
noncomputable def trivialModel (v : Nat → Bool) (atomList : List Atom) :
    TaskModel (TaskFrame.trivial_frame (D := Int)) where
  valuation := fun _ a => v (findIdxAtom a atomList) = true

/-- The trivial-frame truth lemma: on the trivial model built from `v`/`atomList`, truth of a
purely propositional formula `q` at any time coincides with `PropForm.eval` of its
reification. Box/until/since cases are dismissed by `isPropositional`; the atom case reduces
via the trivial history's total domain. -/
theorem trivial_truth_iff (v : Nat → Bool) (atomList : List Atom) (t : Int) :
    ∀ q : Formula, isPropositional q = true →
      (Bimodal.Semantics.truth_at (trivialModel v atomList) Set.univ
          (WorldHistory.trivial (D := Int)) t q ↔ (reifyWith atomList q).eval v = true) := by
  intro q
  induction q with
  | atom a =>
      intro _
      simp [Bimodal.Semantics.truth_at, WorldHistory.trivial, trivialModel, reifyWith
        ]
  | bot =>
      intro _
      simp [Bimodal.Semantics.truth_at, reifyWith]
  | imp φ ψ ihφ ihψ =>
      intro hprop
      have hpair : isPropositional φ = true ∧ isPropositional ψ = true := by
        simpa [isPropositional, Bool.and_eq_true_iff] using hprop
      have hφ := ihφ hpair.1
      have hψ := ihψ hpair.2
      simp only [Bimodal.Semantics.truth_at, reifyWith, PropForm.eval]
      rw [hφ, hψ]
      cases (reifyWith atomList φ).eval v <;> cases (reifyWith atomList ψ).eval v <;> simp
  | box φ _ => intro hprop; simp [isPropositional] at hprop
  | untl φ ψ _ _ => intro hprop; simp [isPropositional] at hprop
  | snce φ ψ _ _ => intro hprop; simp [isPropositional] at hprop

/-- Completeness direction (contrapositive): if `p` is `|-!`-derivable and purely
propositional, its reification is a tautology. Proved by contradiction using the EXISTING
semantic soundness theorem (`Metalogic/Soundness.lean`), instantiated at the trivial-frame
countermodel from a falsifying assignment. -/
theorem derivable_tautology (p : Formula) (hp : isPropositional p = true)
    (h : |-! p) : (reify p).1.isTaut = true := by
  by_contra hcon
  obtain ⟨v, hv⟩ : ∃ v, (reifyWith (formulaAtomsList p) p).eval v = false := by
    have := (PropForm.isTaut_iff_forall_eval (reify p).1).not.mp hcon
    push_neg at this
    obtain ⟨v, hv⟩ := this
    exact ⟨v, Bool.not_eq_true _ |>.mp hv⟩
  have htruth_iff := trivial_truth_iff v (formulaAtomsList p) (0 : Int) p hp
  have hnot_truth : ¬ Bimodal.Semantics.truth_at (trivialModel v (formulaAtomsList p)) Set.univ
      (WorldHistory.trivial (D := Int)) (0 : Int) p := by
    rw [htruth_iff]
    simp [hv]
  obtain ⟨d⟩ := h
  have htruth := Bimodal.Metalogic.soundness [] p d Int
    (TaskFrame.trivial_frame (D := Int)) (trivialModel v (formulaAtomsList p)) Set.univ
    Bimodal.Semantics.Set.univ_shift_closed (WorldHistory.trivial (D := Int))
    (Set.mem_univ _) (0 : Int) (fun ψ hψ => absurd hψ List.not_mem_nil)
  exact hnot_truth htruth

/-- Concrete decidability of `|-! p` for purely propositional `p`: dispatches on
`(reify p).1.isTaut`, using `tautology_derivable` + the round-trip lemma for the `true`
branch and `derivable_tautology` (contrapositive) for the `false` branch. A
hypothesis-carrying `def`, not a typeclass instance (side-conditioned instances do not fire
reliably). -/
noncomputable def instDecidableDerivable (p : Formula) (hp : isPropositional p = true) :
    Decidable (|-! p) :=
  if h : (reify p).1.isTaut = true then
    isTrue (by
      have hd := tautology_derivable (reify p).1 h (reify p).2
      rwa [reify_denote p hp] at hd)
  else
    isFalse (fun hderiv => h (derivable_tautology p hp hderiv))

/-! ## Smoke Tests -/

private def pAtomEx : Formula := Formula.atom (Atom.mk_base "p")
private def qAtomEx : Formula := Formula.atom (Atom.mk_base "q")

/-- `instDecidableDerivable` decides the concrete tautology `p → p` as derivable. -/
example : |-! (pAtomEx.imp pAtomEx) := by
  have hp : isPropositional (pAtomEx.imp pAtomEx) = true := by decide
  have hd : |-! (pAtomEx.imp pAtomEx) := by
    have hraw := tautology_derivable (reify (pAtomEx.imp pAtomEx)).1 (by decide)
      (reify (pAtomEx.imp pAtomEx)).2
    rwa [reify_denote (pAtomEx.imp pAtomEx) hp] at hraw
  match instDecidableDerivable (pAtomEx.imp pAtomEx) hp with
  | isTrue h => exact h
  | isFalse hnd => exact absurd hd hnd

/-- `instDecidableDerivable` decides the concrete non-tautology `p → q` as underivable
(`isFalse`). -/
example : ¬ |-! (pAtomEx.imp qAtomEx) := by
  have hp : isPropositional (pAtomEx.imp qAtomEx) = true := by decide
  match instDecidableDerivable (pAtomEx.imp qAtomEx) hp with
  | isFalse hnd => exact hnd
  | isTrue hd =>
      have htaut := derivable_tautology (pAtomEx.imp qAtomEx) hp hd
      exact absurd htaut (by decide)

end Bimodal.Metalogic.Decidability.Propositional
