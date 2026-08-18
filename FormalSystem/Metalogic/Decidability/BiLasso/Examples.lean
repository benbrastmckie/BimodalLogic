/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Annotation

/-!
# Non-Vacuity Witnesses for `LocalCoherent` and `Fulfilling`

`LocalCoherent`, `Fulfilling` and `BoxOracleSound` are `Prop`-valued conjunctions of conditional
clauses. Such a definition can be accidentally vacuous in two different ways, and both are fatal
in the same way a `sorry` is:

1. **Nothing satisfies it**, so every theorem with it as a hypothesis is empty.
2. **Everything satisfies it** — in particular, `LocalCoherent` might silently imply
   `Fulfilling`, collapsing the greatest-fixpoint / least-fixpoint distinction that the entire
   annotated-lasso design exists to make.

This module rules out both, with two hand-built annotated lassos:

- `posAnnot` satisfies `LocalCoherent` **and** `Fulfilling` — so neither predicate is empty.
- `negAnnot` satisfies `LocalCoherent` but **not** `Fulfilling` — so `Fulfilling` carries real
  content and is not implied by local coherence.

`negAnnot` is the concrete form of the greatest-vs-least fixpoint gap. It carries the eventuality
`p U q` at every position of a loop on which `q` never holds: the guard `p` survives forever, so
every local clause is satisfied by passing the obligation forward one more step, and the
obligation is never discharged. A decision procedure that checked only local coherence would
accept it and be wrong.

Both witnesses use a **one-state self-looping presentation** with a constant path, which makes
the labels literally constant in time. That is deliberate: the point being made is about the
predicates, and a constant witness makes the argument checkable by inspection rather than
burying it in periodic-decoding arithmetic.

## Argument order

Guard first throughout: `Formula.untl g e` has guard `g` and event `e`, matching
`Semantics/Truth.lean`. `negAnnot` carries `Formula.untl (atom p) (atom q)` — guard `p`, event
`q` — and it is the **event** `q` that is never delivered.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

namespace BiLassoExamples

/-! ## The presentation and the underlying lasso -/

/-- The atom that is true at the single state. -/
def pA : Atom := Atom.mkBase "p"

/-- The atom that is false at the single state — the event that is never delivered. -/
def qA : Atom := Atom.mkBase "q"

theorem qA_ne_pA : ¬ (qA = pA) := by decide

/--
A one-state presentation with a self-loop, in which `p` holds and `q` does not.

Bi-seriality is immediate from the self-loop. The valuation ignores the state, since there is
only one — which is exactly what makes the annotation's labels constant and the witnesses below
checkable by hand.
-/
def loopPresentation : IntPresentation where
  card := 1
  card_pos := by omega
  step := fun _ _ => true
  val := fun a _ => a == pA
  fwd := fun w => ⟨w, rfl⟩
  bwd := fun w => ⟨w, rfl⟩

/-- The constant bi-infinite path on the single state. Both cycles are the singleton `[0]`; the
window `mid` is empty, so the origin already sits on the forward cycle. -/
def loopLasso : BiLasso loopPresentation where
  back := [0]
  mid := []
  fwd := [0]
  back_ne := by simp
  fwd_ne := by simp
  coherent := by decide

/-! ## The labels are constant in time

Both witnesses present a single label repeated on both cycles with an empty window, so the
decoded label sequence is that one label at every integer. The proof is the only place any
`emod` arithmetic appears in this file.
-/

/-- An annotation whose two cycles carry the same singleton label list and whose window is empty
has that label at every time. -/
theorem label_const {φ : Formula} (A : Annot loopPresentation φ) (L : Finset Formula)
    (hb : A.backLab = [L]) (hm : A.midLab = []) (hf : A.fwdLab = [L]) (t : ℤ) :
    A.label t = L := by
  rw [Annot.label_def, Periodic.unrollOf]
  rcases lt_or_ge t 0 with ht | ht
  · rw [if_pos ht, Periodic.cyc, hb]
    simp [Int.emod_one]
  · rw [if_neg (not_lt.mpr ht), hm]
    simp only [List.length_nil, Nat.cast_zero]
    rw [if_neg (not_lt.mpr ht), Periodic.cyc, hf]
    simp [Int.emod_one]

/-! ## Positive witness: locally coherent and fulfilling

The formula is `p U p` — guard `p`, event `p`. Its subformula closure is `{p U p, p}`. The label
carries both. The eventuality is discharged immediately at the next position, since `p` holds
everywhere, and the guard obligation on the empty open interval `(t, t+1)` is vacuous.
-/

/-- `p U p`: guard `p`, event `p`. -/
def φPos : Formula := Formula.untl (Formula.atom pA) (Formula.atom pA)

/-- The subformula closure of `p U p`, computed. -/
theorem mem_closure_φPos (ψ : Formula) :
    ψ ∈ subformulaClosure φPos ↔ ψ = φPos ∨ ψ = Formula.atom pA := by
  simp [subformulaClosure, φPos, Formula.subformulas]

/-- The label carried at every position of `posAnnot`. -/
def posLabel : Finset Formula := {Formula.atom pA, φPos}

theorem mem_posLabel_iff (ψ : Formula) :
    ψ ∈ posLabel ↔ ψ = Formula.atom pA ∨ ψ = φPos := by
  simp [posLabel]

/-- The positive witness: the constant loop annotated with `{p, p U p}` everywhere. -/
def posAnnot : Annot loopPresentation φPos where
  lasso := loopLasso
  backLab := [posLabel]
  midLab := []
  fwdLab := [posLabel]
  backLab_length := rfl
  midLab_length := rfl
  fwdLab_length := rfl
  label_sub := by
    intro L hL
    simp only [List.singleton_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hL
    have hLeq : L = posLabel := by rcases hL with h | h <;> exact h
    subst hLeq
    intro ψ hψ
    rw [mem_closure_φPos]
    rcases (mem_posLabel_iff ψ).mp hψ with h | h
    · exact Or.inr h
    · exact Or.inl h

theorem posAnnot_label (t : ℤ) : posAnnot.label t = posLabel :=
  label_const posAnnot posLabel rfl rfl rfl t

/-- `p` is in the positive label. -/
theorem atom_mem_posLabel : Formula.atom pA ∈ posLabel := by simp [posLabel]

/-- `p U p` is in the positive label. -/
theorem untl_mem_posLabel : φPos ∈ posLabel := by simp [posLabel]

/-- Closure membership pins an `untl` in the closure of `p U p` to `p U p` itself, fixing both
its guard and its event to `p`. -/
theorem untl_in_closure_φPos {g e : Formula} (h : Formula.untl g e ∈ subformulaClosure φPos) :
    g = Formula.atom pA ∧ e = Formula.atom pA := by
  rcases (mem_closure_φPos _).mp h with h | h
  · simp only [φPos, Formula.untl.injEq] at h
    exact ⟨h.1, h.2⟩
  · simp at h

/--
**The positive witness is locally coherent**, relative to the everywhere-false box oracle (there
is no box in the closure, so the box clause is vacuous).
-/
theorem posAnnot_localCoherent :
    LocalCoherent loopPresentation φPos (fun _ => false) posAnnot := by
  intro t
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- atom clause: the only atom in the closure is `p`, and `p` holds at the single state
    intro p hp
    have hpeq : p = pA := by
      rcases (mem_closure_φPos _).mp hp with h | h
      · simp [φPos] at h
      · simpa using h
    subst hpeq
    rw [posAnnot_label]
    have hval : loopPresentation.val pA (posAnnot.lasso.unroll t) = true := by
      simp [loopPresentation]
    rw [hval]
    simp [atom_mem_posLabel]
  · -- `⊥` is not in the label
    rw [posAnnot_label]
    simp [posLabel, φPos]
  · -- no implication is in the closure
    intro a b hab
    exact absurd ((mem_closure_φPos _).mp hab) (by simp [φPos])
  · -- no box is in the closure
    intro χ hχ
    exact absurd ((mem_closure_φPos _).mp hχ) (by simp [φPos])
  · -- the `untl` clause: the event `p` already holds at `t + 1`, so the left disjunct fires
    intro g e hge
    obtain ⟨hg, he⟩ := untl_in_closure_φPos hge
    subst hg; subst he
    rw [posAnnot_label, posAnnot_label]
    constructor
    · intro _
      exact Or.inl atom_mem_posLabel
    · intro _
      exact untl_mem_posLabel
  · -- no `snce` is in the closure
    intro g e hge
    exact absurd ((mem_closure_φPos _).mp hge) (by simp [φPos])

/--
**The positive witness is fulfilling.**

The only eventuality any label carries is `p U p`, and its event `p` holds at every position, so
`s = t + 1` witnesses it with a vacuous guard obligation. No `snce` formula appears in any label,
so the backward half is vacuous.
-/
theorem posAnnot_fulfilling : Fulfilling loopPresentation φPos posAnnot := by
  constructor
  · intro t g e hmem
    rw [posAnnot_label] at hmem
    rcases (mem_posLabel_iff _).mp hmem with h | h
    · simp at h
    · have he : e = Formula.atom pA := by
        simp only [φPos, Formula.untl.injEq] at h
        exact h.2
      refine ⟨t + 1, by omega, ?_, fun r hr1 hr2 => absurd (show False by omega) not_false⟩
      rw [posAnnot_label, he]
      exact atom_mem_posLabel
  · intro t g e hmem
    rw [posAnnot_label] at hmem
    rcases (mem_posLabel_iff _).mp hmem with h | h
    · simp at h
    · simp [φPos] at h

/-! ## Negative witness: locally coherent but not fulfilling

The formula is `p U q` — guard `p`, event `q`. On the one-state loop `p` holds everywhere and
`q` holds nowhere. The label carries `{p, p U q}`.

Local coherence holds: the `untl` clause asks only that `p U q` at `t` be matched by "`q` at
`t+1`, or `p` at `t+1` together with `p U q` at `t+1`", and the second disjunct is satisfied at
every position. Fulfilment fails: the event `q` is in no label at all, so no witness exists at
any distance. This is the eventuality postponed forever around the forward loop.
-/

/-- `p U q`: guard `p`, event `q`. -/
def φNeg : Formula := Formula.untl (Formula.atom pA) (Formula.atom qA)

/-- The subformula closure of `p U q`, computed. -/
theorem mem_closure_φNeg (ψ : Formula) :
    ψ ∈ subformulaClosure φNeg ↔
      ψ = φNeg ∨ ψ = Formula.atom qA ∨ ψ = Formula.atom pA := by
  simp [subformulaClosure, φNeg, Formula.subformulas]

/-- The label carried at every position of `negAnnot`. Note it does **not** contain `q`. -/
def negLabel : Finset Formula := {Formula.atom pA, φNeg}

theorem mem_negLabel_iff (ψ : Formula) :
    ψ ∈ negLabel ↔ ψ = Formula.atom pA ∨ ψ = φNeg := by
  simp [negLabel]

/-- The negative witness: the constant loop annotated with `{p, p U q}` everywhere. -/
def negAnnot : Annot loopPresentation φNeg where
  lasso := loopLasso
  backLab := [negLabel]
  midLab := []
  fwdLab := [negLabel]
  backLab_length := rfl
  midLab_length := rfl
  fwdLab_length := rfl
  label_sub := by
    intro L hL
    simp only [List.singleton_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hL
    have hLeq : L = negLabel := by rcases hL with h | h <;> exact h
    subst hLeq
    intro ψ hψ
    rw [mem_closure_φNeg]
    rcases (mem_negLabel_iff ψ).mp hψ with h | h
    · exact Or.inr (Or.inr h)
    · exact Or.inl h

theorem negAnnot_label (t : ℤ) : negAnnot.label t = negLabel :=
  label_const negAnnot negLabel rfl rfl rfl t

/-- `p` is in the negative label. -/
theorem atom_p_mem_negLabel : Formula.atom pA ∈ negLabel := by simp [negLabel]

/-- `p U q` is in the negative label. -/
theorem untl_mem_negLabel : φNeg ∈ negLabel := by simp [negLabel]

/-- `q` is **not** in the negative label — the fact that defeats fulfilment. -/
theorem atom_q_not_mem_negLabel : Formula.atom qA ∉ negLabel := by
  simp [negLabel, φNeg, qA_ne_pA]

/-- Closure membership pins an `untl` in the closure of `p U q` to `p U q` itself. -/
theorem untl_in_closure_φNeg {g e : Formula} (h : Formula.untl g e ∈ subformulaClosure φNeg) :
    g = Formula.atom pA ∧ e = Formula.atom qA := by
  rcases (mem_closure_φNeg _).mp h with h | h | h
  · simp only [φNeg, Formula.untl.injEq] at h
    exact ⟨h.1, h.2⟩
  · simp at h
  · simp at h

/-- **The negative witness is locally coherent.** -/
theorem negAnnot_localCoherent :
    LocalCoherent loopPresentation φNeg (fun _ => false) negAnnot := by
  intro t
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- atom clause: `p` is in the label and true; `q` is out of the label and false
    intro p hp
    rw [negAnnot_label]
    have hp' : p = pA ∨ p = qA := by
      rcases (mem_closure_φNeg _).mp hp with h | h | h
      · simp [φNeg] at h
      · exact Or.inr (by simpa using h)
      · exact Or.inl (by simpa using h)
    rcases hp' with h | h <;> subst h
    · have hval : loopPresentation.val pA (negAnnot.lasso.unroll t) = true := by
        simp [loopPresentation]
      rw [hval]
      simp [atom_p_mem_negLabel]
    · have hval : loopPresentation.val qA (negAnnot.lasso.unroll t) = false := by
        simp only [loopPresentation]
        simp [qA_ne_pA]
      rw [hval]
      simp [atom_q_not_mem_negLabel]
  · rw [negAnnot_label]
    simp [negLabel, φNeg]
  · intro a b hab
    exact absurd ((mem_closure_φNeg _).mp hab) (by simp [φNeg])
  · intro χ hχ
    exact absurd ((mem_closure_φNeg _).mp hχ) (by simp [φNeg])
  · -- the `untl` clause: satisfied by the *right* disjunct — guard `p` holds and the obligation
    -- is passed forward. This is exactly the postponement that fulfilment forbids.
    intro g e hge
    obtain ⟨hg, he⟩ := untl_in_closure_φNeg hge
    subst hg; subst he
    rw [negAnnot_label, negAnnot_label]
    constructor
    · intro _
      exact Or.inr ⟨atom_p_mem_negLabel, untl_mem_negLabel⟩
    · intro _
      exact untl_mem_negLabel
  · intro g e hge
    exact absurd ((mem_closure_φNeg _).mp hge) (by simp [φNeg])

/--
**The negative witness is NOT fulfilling** — the eventuality `p U q` is carried at every
position and its event `q` is in no label, so no witness exists at any distance.

This is the theorem that proves `Fulfilling` is not implied by `LocalCoherent`, and hence that
the annotated-lasso decision layer cannot be simplified to a purely local condition.
-/
theorem negAnnot_not_fulfilling : ¬ Fulfilling loopPresentation φNeg negAnnot := by
  intro hful
  obtain ⟨hu, _⟩ := hful
  obtain ⟨s, _, hs, _⟩ := hu 0 (Formula.atom pA) (Formula.atom qA)
    (by rw [negAnnot_label]; exact untl_mem_negLabel)
  rw [negAnnot_label] at hs
  exact atom_q_not_mem_negLabel hs

/--
**`Fulfilling` is strictly stronger than `LocalCoherent`.**

The two witnesses together: local coherence does not imply fulfilment, so the global condition
is doing real work and no purely local decision procedure is correct for this layer.
-/
theorem fulfilling_not_implied_by_localCoherent :
    ∃ (φ : Formula) (A : Annot loopPresentation φ),
      LocalCoherent loopPresentation φ (fun _ => false) A ∧ ¬ Fulfilling loopPresentation φ A :=
  ⟨φNeg, negAnnot, negAnnot_localCoherent, negAnnot_not_fulfilling⟩

/--
**`BoxOracleSound` is not an unconditional predicate either.**

The everywhere-`false` oracle used above is convenient for the two annotation witnesses — the
closures involved contain no box — but it is *not* a sound oracle, because it reports `false`
for the tautology `⊥ → ⊥`, which holds along every history. So `BoxOracleSound` genuinely
constrains its argument and is not satisfied by an arbitrary `Formula → Bool`.
-/
theorem boxOracle_false_not_sound : ¬ BoxOracleSound loopPresentation (fun _ => false) := by
  intro h
  have htaut := (h (Formula.imp Formula.bot Formula.bot)).mpr (fun _ _ hb => hb)
  simp at htaut

end BiLassoExamples

end FormalSystem.Metalogic.Decidability
