/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Sound

/-!
# Completeness Relative to Tail-Stable Sliced Models

The converse of `Sound.lean`. A sliced structure whose slice labelling is **semantically correct**
— whose `□`- and `⊡`-labels report the truth of their arguments in the frame the structure itself
presents — and which is bi-serial, tail-stable and carries a refuting path, admits a **box guess**
making the checker of `Check.lean` accept it, on the same carrier.

## What this theorem is, and what it is not

It is **completeness relative to tail-stable sliced models**. It says: within the class of sliced
structures that are bi-serial, tail-stable and semantically labelled, nothing is lost by the
checker — the one field a checker has to *guess* can always be guessed right.

It is **not** the finite model property, and nothing here bears on whether a ℤ-time non-validity
has such a countermodel at all. It is also **not** completeness relative to *finite* models: a
finite-carrier certificate cannot certify every ℤ-time non-validity the landed `Formula`-side
family already certifies — there is a `⊡`-free ℤ-time non-validity no finite-carrier certificate
reaches — so that statement would have been the wrong target. No slice-width bound and no period
bound is stated anywhere in this module, because none is proved. The full-L⁺ sliced finite model
property is **open**, and nothing here refutes it.

## Which clauses are constructed and which are carried, and why the split falls where it does

`Certifies` has nine conjuncts. Exactly two of them mention the box guess `bx`:
(C3b) `BoxLabelFaithful` and the box clause `BoxLiveFaithful`. The other seven mention `n`, `back`,
`mid`, `fwd`, `target` and `targetTime` only. That asymmetry is what makes this theorem possible at
all: changing `bx` changes **nothing** in the computed layer, because `bx` occurs nowhere in
`posAt`, `succP`, `liveT`, `liveAt`, `winTimes` or `TailStable` — it occurs only in
`PlusLocalCoherentSeqLab`, hence only in `LabRun` and in the *declarative* `Live`.

So the three semantic clauses — (C3b), the box clause and (C5) `StabFaithful` — are **constructed**
here from the semantic correctness of the labelling, in that order, and the four structural ones
are **carried** by hypotheses. The order is forced, and worth stating so it is not reshuffled:
`BoxLabelFaithful` is what the computed/declarative liveness bridge `mem_liveAt_iff_live` consumes,
and both of the other two read a live position's label, so (C3b) has to be in hand before either.

## Why the produced certificate keeps `G₀`'s target path, not a re-extracted one

Plan v9's Phase 19 asserts that `TailStable` "quantifies over `n`, `back`, `mid`, `fwd` and the
closure only", and would have the produced certificate re-extract its target path by a pigeonhole
on the paired carrier. **That assertion is false, and this module does not rely on it.**
`Window.lean`'s combined periods are
`NBnat = Nat.lcm back.length target.back.length` and `NFnat = Nat.lcm fwd.length target.fwd.length`,
with `NM = max nm target.nm`: the window depends on the target path's three **segment lengths**.
The window is what `winTimes` is cut from, `winTimes` is what the `liveT` fixpoint ranges over, and
`liveAt` is what `TailStable` is stated about. A target path with different periods therefore gives
a different window, a different computed live set and a **different** tail-stability demand, and
no period-independence theory exists in this subtree to transport one to the other.

The honest consequence is the one taken here: the countermodel's refuting path is part of the
structure handed in, and the produced certificate agrees with `G₀` on **six** fields — `n`, `back`,
`mid`, `fwd`, `target` and `targetTime` — rather than four. That is a *stronger* conclusion than
the four carrier equations the plan asks for, and `hstab` then transfers at every residue of both
periods at once, which is what the plan wanted the four equations to buy.

## Main definitions

- `PlusSlicedCertificate.SlabTrue` — the slice labelling is semantically correct at the two
  non-atomic state shapes. The atoms need no clause: the presented model's valuation **is** the
  slice labelling (`model_valuation`), so the `atom` case of the truth lemma is `Iff.rfl`
- `PlusSlicedCertificate.withBx` — the same structure with a different box guess
- `PlusSlicedCertificate.canonBx` — the canonical box guess, read off one slice label

## Main results

- `PlusSlicedCertificate.plusTruthAt_iff_canAt_of_slabTrue` — the truth lemma **with no checker
  clause as a hypothesis**: semantic correctness of the labelling alone suffices, because `canAt`'s
  `□` and `⊡` cases read the slice label and `SlabTrue` is exactly the statement that those labels
  are right. `Sound.lean`'s `plusTruthAt_iff_canAt` is the same conclusion from the *checker's*
  four clauses instead, and neither subsumes the other
- `PlusSlicedCertificate.boxLabelFaithful_of_slabTrue`, `...boxLiveFaithful_of_slabTrue`,
  `...stabFaithful_of_slabTrue` — the three semantic clauses of `Certifies`
- `PlusSlicedCertificate.exists_plusSlicedCertificate_of_tailStable_countermodel` — the headline
- `PlusSlicedCertificate.exists_certifying_of_tailStable_countermodel` — the same, with the six
  carrier equations spelled out
- `PlusSlicedCertificate.plusRefutes_of_tailStable_countermodel` — soundness and completeness meet
  on the unchanged `PlusWitnessFamily.PlusRefutes Γ Del` interface
- `PlusSlicedCertificate.Probe.exists_certifying_triv` — the hypothesis set is **satisfiable**,
  exhibited at a concrete certificate rather than argued for. See that section's header for what the
  witness does and does not show

## Tags

plus-language · certificate · time-sliced · completeness · relative
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage
open FormalSystem.Semantics

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## Semantic correctness of the slice labelling -/

/--
**The slice labelling is semantically correct at the state shapes.**

Two clauses, one per non-atomic state shape:

* `□χ` is labelled at a carrier element exactly when `χ` is true at **every** history and **every**
  time. The time-and-history-free right-hand side is not a strengthening: by `plusBox_const` the
  truth of `□χ` is independent of both, so "true everywhere" is the only thing a `□`-label can
  report.
* `⊡χ` is labelled at `(t, w)` exactly when `χ` is true at `t` along every history passing through
  `(t, w)` at `t`. Here the time genuinely matters — the comparison class is the histories agreeing
  at `t`, whose first component *is* `t` — so no shift normalizes it away.

**No atom clause is needed.** `Frame.lean`'s `model_valuation` makes the presented model's valuation
the slice labelling by definition, so atoms are correct by construction rather than by demand.
-/
def SlabTrue (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) : Prop :=
  (∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
      ∀ (t : ℤ) (w : Fin G.n),
        (PlusFormula.box χ ∈ G.slab t w ↔
          ∀ (σ : WorldHistory (G.frame h).toTaskFrame) (u : ℤ),
            PlusTruthAt (G.model h) σ u χ))
    ∧ (∀ χ : PlusFormula, PlusFormula.stab χ ∈ plusClosureOf (Γ ++ Del) →
      ∀ (t : ℤ) (w : Fin G.n),
        (PlusFormula.stab χ ∈ G.slab t w ↔
          ∀ σ : WorldHistory (G.frame h).toTaskFrame,
            σ.state t = ((t, w) : ℤ × Fin G.n) → PlusTruthAt (G.model h) σ t χ))

/-! ## Replacing the box guess, and nothing else

The one field this theorem produces. `withBx` is a structure update on `bx` alone, so every
projection other than `bx` is `rfl`-equal to `G`'s, and every notion defined from those projections
— the slice sequence, the frame, the model, the position space, the window, the computed live sets,
`TailStable`, `TargetPathPos`, `Target` — is definitionally unchanged. That is what the six
equations of `exists_certifying_of_tailStable_countermodel` record.
-/

/-- **The same structure with a different box guess.**

Marked `@[reducible]` deliberately. Every notion of this subtree whose definition reads the carrier
fields has to be compared across `withBx` at *`rw`'s* transparency, not only at `exact`'s, and at
semireducible transparency `Finset (G.withBx bx).Pos` and `Finset G.Pos` are not the same type — so
a rewrite inside a tail-stability conjunct fails to typecheck its own motive. Reducibility is the
cheapest fix and costs nothing: the body is a structure update on one field. -/
@[reducible] def withBx (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    PlusSlicedCertificate Γ Del :=
  { G with bx := bx }

@[simp] theorem withBx_n (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).n = G.n := rfl

@[simp] theorem withBx_back (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).back = G.back := rfl

@[simp] theorem withBx_mid (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).mid = G.mid := rfl

@[simp] theorem withBx_fwd (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).fwd = G.fwd := rfl

@[simp] theorem withBx_target (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).target = G.target := rfl

@[simp] theorem withBx_targetTime (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).targetTime = G.targetTime := rfl

@[simp] theorem withBx_bx (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).bx = bx := rfl

@[simp] theorem withBx_slab (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool)
    (t : ℤ) (w : Fin G.n) : (G.withBx bx).slab t w = G.slab t w := rfl

/-! ### What a changed box guess does and does not move

Almost every notion this subtree defines is `rfl`-equal across `withBx`, because `bx` occurs
nowhere in it. Exactly two are **not**, and both for the same reason: they are defined by recursion
on an argument that is a *variable* at the point of use, so the recursor cannot iota-reduce and the
two applications are not definitionally equal however far they are unfolded.

* `iterBack` / `iterFwd` recurse on the iterate count, which `TailStable` instantiates at `NBnat` /
  `NFnat` — not a literal.
* `canAt` recurses on the formula, which `canLab` quantifies over inside its filter.

Each of the two costs one short induction, and `TailStable` and `canLab` then transfer through them.
Nothing else in this module needs a transfer lemma: `BiSerial`, `SlabTrue`, `edge`, `winTimes`,
`posAt`, `liveAt`, `liveT`, `model` and `stepHistory` all go across by `rfl`.
-/

@[simp] theorem withBx_posAt (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) (s : ℤ) :
    (G.withBx bx).posAt s = G.posAt s := rfl

@[simp] theorem withBx_winTimes (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).winTimes = G.winTimes := rfl

@[simp] theorem withBx_liveAt (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) (s : ℤ) :
    (G.withBx bx).liveAt s = G.liveAt s := rfl

@[simp] theorem withBx_fwdLiveAt (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool)
    (s : ℤ) : (G.withBx bx).fwdLiveAt s = G.fwdLiveAt s := rfl

@[simp] theorem withBx_stepBack (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool)
    (t : ℤ) (X : Finset G.Pos) : (G.withBx bx).stepBack t X = G.stepBack t X := rfl

@[simp] theorem withBx_stepFwd (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool)
    (t : ℤ) (X : Finset G.Pos) : (G.withBx bx).stepFwd t X = G.stepFwd t X := rfl

/-- **The backward iterate transfers**, by induction on the iterate count. -/
theorem withBx_iterBack (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) (t : ℤ)
    (X : Finset G.Pos) : ∀ j : ℕ, (G.withBx bx).iterBack t X j = G.iterBack t X j := by
  intro j
  induction j with
  | zero => rfl
  | succ k ih =>
    rw [iterBack_succ, iterBack_succ, ih]
    rfl

/-- **The forward iterate transfers**, by the mirror induction. -/
theorem withBx_iterFwd (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) (t : ℤ)
    (X : Finset G.Pos) : ∀ j : ℕ, (G.withBx bx).iterFwd t X j = G.iterFwd t X j := by
  intro j
  induction j with
  | zero => rfl
  | succ k ih =>
    rw [iterFwd_succ, iterFwd_succ, ih]
    rfl

/-- **Tail-stability transfers.** The demand reads the carrier fields and the iterates only, and a
changed box guess moves neither. -/
theorem withBx_tailStable (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool) :
    (G.withBx bx).TailStable ↔ G.TailStable := by
  constructor
  · rintro ⟨h1, h2⟩
    refine ⟨fun r hr => ?_, fun r hr => ?_⟩
    · have hr' := h1 r hr
      rwa [G.withBx_iterBack bx] at hr'
    · have hr' := h2 r hr
      rwa [G.withBx_iterFwd bx] at hr'
  · rintro ⟨h1, h2⟩
    refine ⟨fun r hr => ?_, fun r hr => ?_⟩
    · have hr' := h1 r hr
      rwa [← G.withBx_iterBack bx] at hr'
    · have hr' := h2 r hr
      rwa [← G.withBx_iterFwd bx] at hr'

/-- **The canonical membership predicate transfers**, by induction on the formula. The `□` and `⊡`
cases read the slice labelling, which `withBx` leaves alone. -/
theorem withBx_canAt (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool)
    (g : ℤ → Fin G.n) :
    ∀ (ψ : PlusFormula) (t : ℤ), ((G.withBx bx).canAt g ψ t ↔ G.canAt g ψ t) := by
  intro ψ
  induction ψ with
  | atom a => intro t; exact Iff.rfl
  | bot => intro t; exact Iff.rfl
  | imp a b iha ihb =>
    intro t
    rw [canAt_imp, canAt_imp]
    exact Iff.imp (iha t) (ihb t)
  | box χ _ => intro t; exact Iff.rfl
  | stab χ _ => intro t; exact Iff.rfl
  | untl a b iha ihb =>
    intro t
    rw [canAt_untl, canAt_untl]
    constructor
    · rintro ⟨s, h1, h2, h3⟩
      exact ⟨s, h1, (ihb s).mp h2, fun r hr1 hr2 => (iha r).mp (h3 r hr1 hr2)⟩
    · rintro ⟨s, h1, h2, h3⟩
      exact ⟨s, h1, (ihb s).mpr h2, fun r hr1 hr2 => (iha r).mpr (h3 r hr1 hr2)⟩
  | snce a b iha ihb =>
    intro t
    rw [canAt_snce, canAt_snce]
    constructor
    · rintro ⟨s, h1, h2, h3⟩
      exact ⟨s, h1, (ihb s).mp h2, fun r hr1 hr2 => (iha r).mp (h3 r hr1 hr2)⟩
    · rintro ⟨s, h1, h2, h3⟩
      exact ⟨s, h1, (ihb s).mpr h2, fun r hr1 hr2 => (iha r).mpr (h3 r hr1 hr2)⟩

/-- **The canonical label transfers**, from `withBx_canAt`. -/
theorem withBx_canLab (G : PlusSlicedCertificate Γ Del) (bx : PlusFormula → Bool)
    (g : ℤ → Fin G.n) (t : ℤ) : (G.withBx bx).canLab g t = G.canLab g t := by
  ext ψ
  rw [mem_canLab, mem_canLab]
  exact and_congr_right (fun _ => G.withBx_canAt bx g ψ t)

/--
**The canonical box guess.** Read off the `□`-labels of one slice, at one state.

Any carrier element would do, and that is the point: under `SlabTrue` the `□`-content of the slice
labelling is the same at every carrier element, because the right-hand side of `SlabTrue`'s first
clause mentions neither the time nor the state. Reading it at `(0, 0)` keeps the guess
**computable** — it is a `Finset` membership — which a semantic definition would not be.
-/
def canonBx (G : PlusSlicedCertificate Γ Del) : PlusFormula → Bool :=
  fun χ => decide (PlusFormula.box χ ∈ G.slab 0 ⟨0, G.n_pos⟩)

theorem canonBx_eq_true (G : PlusSlicedCertificate Γ Del) (χ : PlusFormula) :
    G.canonBx χ = true ↔ PlusFormula.box χ ∈ G.slab 0 ⟨0, G.n_pos⟩ := by
  simp only [canonBx, decide_eq_true_eq]

/-! ## (C3b): the box-label clause

The first of the three semantic clauses, and the one the other two consume: `mem_liveAt_iff_live`
takes it, so no clause that reads a live position's label can be proved before it.
-/

/--
**(C3b) `BoxLabelFaithful`, from semantic correctness.**

The hypothesis `hbx` says the guess agrees with the `□`-content of the slice at `(0, 0)`; under
`SlabTrue` that content is the same at every carrier element, so the clause follows at every `t`
and `w` at once.
-/
theorem boxLabelFaithful_of_slabTrue (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (hst : G.SlabTrue h)
    (hbx : ∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
      (G.bx χ = true ↔ PlusFormula.box χ ∈ G.slab 0 ⟨0, G.n_pos⟩)) :
    G.BoxLabelFaithful := by
  intro χ hχ t w
  rw [hbx χ hχ, hst.1 χ hχ t w, hst.1 χ hχ 0 ⟨0, G.n_pos⟩]

/-! ## The truth lemma from semantic correctness

`Sound.lean` proves the same conclusion from the checker's four clauses, because there the slice
labelling is unconstrained data and the clauses are all there is. Here the labelling is *given* to
be correct, so the `□` and `⊡` cases are one rewrite each and no checker clause is consumed at all.
Both versions are needed and neither subsumes the other: soundness has the clauses and must reach
truth; completeness has truth and must reach the clauses.
-/

/--
**The truth lemma, from semantic correctness of the labelling alone.**

No `BoxLabelFaithful`, no `BoxLiveFaithful`, no `StabFaithful` and no `TailStable`. The `□` case is
`SlabTrue`'s first clause plus `plusBox_const`, the `⊡` case is its second clause, the `atom` case
is `model_valuation`, and `untl` / `snce` are a direct transfer because `canAt` takes the
existential form of both.
-/
theorem plusTruthAt_iff_canAt_of_slabTrue (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (hst : G.SlabTrue h) :
    ∀ ψ : PlusFormula, ψ ∈ plusClosureOf (Γ ++ Del) →
      ∀ (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) (t : ℤ),
        PlusTruthAt (G.model h) (G.stepHistory h g hg) t ψ ↔ G.canAt g ψ t := by
  intro ψ
  induction ψ with
  | atom a => intro _ g hg t; exact Iff.rfl
  | bot => intro _ g hg t; exact Iff.rfl
  | imp a b iha ihb =>
    intro hmem g hg t
    rw [show PlusTruthAt (G.model h) (G.stepHistory h g hg) t (PlusFormula.imp a b)
        = (PlusTruthAt (G.model h) (G.stepHistory h g hg) t a →
            PlusTruthAt (G.model h) (G.stepHistory h g hg) t b) from rfl,
      G.canAt_imp g a b t]
    exact Iff.imp (iha (plusClosureOf_imp_left hmem) g hg t)
      (ihb (plusClosureOf_imp_right hmem) g hg t)
  | box χ _ =>
    intro hmem g hg t
    rw [G.canAt_box g χ t, hst.1 χ hmem t (g t)]
    constructor
    · intro hall σ u
      have h1 : PlusTruthAt (G.model h) (G.stepHistory h g hg) t (PlusFormula.box χ) := hall
      exact (plusBox_const (G.model h) (G.stepHistory h g hg) σ t u χ).mp h1 σ
    · intro hall
      change ∀ σ : WorldHistory (G.frame h).toTaskFrame, PlusTruthAt (G.model h) σ t χ
      intro σ
      exact hall σ t
  | stab χ _ =>
    intro hmem g hg t
    rw [G.canAt_stab g χ t, hst.2 χ hmem t (g t)]
    constructor
    · intro hall σ hσ
      exact hall σ ((G.stepHistory_state h g hg t).trans hσ.symm)
    · intro hall
      change ∀ σ : WorldHistory (G.frame h).toTaskFrame,
        (G.stepHistory h g hg).state t = σ.state t → PlusTruthAt (G.model h) σ t χ
      intro σ hσ
      exact hall σ (hσ.symm.trans (G.stepHistory_state h g hg t))
  | untl a b iha ihb =>
    intro hmem g hg t
    have hac : a ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_untl_right hmem
    have hbc : b ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_untl_left hmem
    rw [G.canAt_untl g a b t]
    constructor
    · rintro ⟨s, hts, hbs, hguard⟩
      exact ⟨s, hts, (ihb hbc g hg s).mp hbs,
        fun r hr1 hr2 => (iha hac g hg r).mp (hguard r hr1 hr2)⟩
    · rintro ⟨s, hts, hbs, hguard⟩
      exact ⟨s, hts, (ihb hbc g hg s).mpr hbs,
        fun r hr1 hr2 => (iha hac g hg r).mpr (hguard r hr1 hr2)⟩
  | snce a b iha ihb =>
    intro hmem g hg t
    have hac : a ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_snce_right hmem
    have hbc : b ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_snce_left hmem
    rw [G.canAt_snce g a b t]
    constructor
    · rintro ⟨s, hst', hbs, hguard⟩
      exact ⟨s, hst', (ihb hbc g hg s).mp hbs,
        fun r hr1 hr2 => (iha hac g hg r).mp (hguard r hr1 hr2)⟩
    · rintro ⟨s, hst', hbs, hguard⟩
      exact ⟨s, hst', (ihb hbc g hg s).mpr hbs,
        fun r hr1 hr2 => (iha hac g hg r).mpr (hguard r hr1 hr2)⟩

/-! ## (C5) and the box clause

Both read a live position's label, and both get it the same way: `exists_path_canLab_of_live` turns
a live position into a genuine `G.edge`-path whose canonical label **is** that position's label —
`Canon.lean`'s uniqueness half — and the truth lemma above then reads the canonical label as truth.
-/

/--
**(C5) `StabFaithful`, from semantic correctness.**

`→` is the universal side: a live position over `w` is some edge path's position, that path's
history passes through `(t, w)`, so the `⊡`-label's semantic content applies to it. `←` is the
existential side, and it is where the dropped `witness` field is paid for: an arbitrary history
through `(t, w)` is a *shifted* edge path, the shift is forced to `0` by the time component, and
the path's own canonical position is live at `t` because `t` is a window time.
-/
theorem stabFaithful_of_slabTrue (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (hst : G.SlabTrue h) (hbox : G.BoxLabelFaithful) : G.StabFaithful := by
  intro t ht w χ hχ
  have hχ' : χ ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_stab hχ
  rw [hst.2 χ hχ t w]
  constructor
  · intro hall p hp hfst
    obtain ⟨g, hg, h1, h2⟩ := G.exists_path_canLab_of_live (G.live_of_mem_liveAt hbox ht hp)
    have hgt : g t = w := by rw [← h1, hfst]
    have hσ : ((t, g t) : ℤ × Fin G.n) = ((t, w) : ℤ × Fin G.n) := by rw [hgt]
    have hcan := (G.plusTruthAt_iff_canAt_of_slabTrue h hst χ hχ' g hg t).mp
      (hall (G.stepHistory h g hg) hσ)
    rw [h2]
    exact (G.mem_canLab g).mpr ⟨hχ', hcan⟩
  · intro hlive σ hσ
    obtain ⟨k, g, hg, hoff, hσeq⟩ := G.exists_stepHistory h σ
    have he : ((t + k, g (t + k)) : ℤ × Fin G.n) = ((t, w) : ℤ × Fin G.n) := by
      rw [← hoff t]; exact hσ
    have hk : k = 0 := by
      have h1 := congrArg Prod.fst he
      simp only at h1
      omega
    subst hk
    have hgt : g t = w := by
      have h2 := congrArg Prod.snd he
      simp only at h2
      rwa [add_zero] at h2
    rw [G.plusTruthAt_shiftBack h σ χ t 0, hσeq, add_zero,
      G.plusTruthAt_iff_canAt_of_slabTrue h hst χ hχ' g hg t]
    have hmem := G.mem_liveAt_of_live ht (G.live_canRun_pair hbox g hg t)
    exact ((G.mem_canLab g).mp (hlive _ hmem hgt)).2

/--
**The box clause `BoxLiveFaithful`, from semantic correctness.**

`TailStable` is consumed here and nowhere else in this module, through `exists_win_live_eq`: the
clause is stated at window times, the `←` direction has to supply truth at an **arbitrary** time,
and the transport between the two is exactly what the residue-indexed tail-stability demand buys.
-/
theorem boxLiveFaithful_of_slabTrue (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (hst : G.SlabTrue h) (hbox : G.BoxLabelFaithful) (hTS : G.TailStable) :
    G.BoxLiveFaithful := by
  intro χ hχ
  have hχ' : χ ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_box hχ
  rw [← hbox χ hχ 0 ⟨0, G.n_pos⟩, hst.1 χ hχ 0 ⟨0, G.n_pos⟩]
  constructor
  · intro hall t ht p hp
    obtain ⟨g, hg, -, h2⟩ := G.exists_path_canLab_of_live (G.live_of_mem_liveAt hbox ht hp)
    rw [h2]
    exact (G.mem_canLab g).mpr ⟨hχ',
      (G.plusTruthAt_iff_canAt_of_slabTrue h hst χ hχ' g hg t).mp (hall _ t)⟩
  · intro hlive σ u
    obtain ⟨k, g, hg, -, hσeq⟩ := G.exists_stepHistory h σ
    rw [G.plusTruthAt_shiftBack h σ χ u k, hσeq,
      G.plusTruthAt_iff_canAt_of_slabTrue h hst χ hχ' g hg (u + k)]
    obtain ⟨s, hs, -, hliveiff⟩ := G.exists_win_live_eq hbox hTS (u + k)
    have hp : G.Live s ((g (u + k),
        ⟨G.canLab g (u + k), Finset.mem_powerset.mpr (G.canLab_subset g (u + k))⟩) : G.Pos) :=
      (hliveiff _).mp (G.live_canRun_pair hbox g hg (u + k))
    exact ((G.mem_canLab g).mp (hlive s hs _ (G.mem_liveAt_of_live hs hp))).2

/-! ## The target group

Three of the four target clauses come from the refuting path, and all three go through the same
identification: the target path's position **is** the canonical run's position, because the target
path's labels are the canonical ones.
-/

/-- **The target path's position is the canonical run's position**, at every time. -/
theorem targetPos_eq_canRun_pos (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hedge : ∀ t : ℤ, G.edge t (G.target.st t) (G.target.st (t + 1)) = true)
    (hcan : ∀ t : ℤ, G.target.lab t = G.canLab G.target.st t) (t : ℤ) :
    G.targetPos t = (G.canRun hbox G.target.st hedge).pos t :=
  Prod.ext rfl (Subtype.ext (hcan t))

/-- **The existential side's structural clause**, from the target path being a canonically
labelled `G.edge`-path. -/
theorem targetPathPos_of_canLab (G : PlusSlicedCertificate Γ Del) (hbox : G.BoxLabelFaithful)
    (hedge : ∀ t : ℤ, G.edge t (G.target.st t) (G.target.st (t + 1)) = true)
    (hcan : ∀ t : ℤ, G.target.lab t = G.canLab G.target.st t) :
    G.TargetPathPos := by
  intro t
  rw [G.targetPos_eq_canRun_pos hbox hedge hcan t,
    G.targetPos_eq_canRun_pos hbox hedge hcan (t + 1)]
  exact ⟨(G.canRun hbox G.target.st hedge).pos_mem_posAt t,
    (G.canRun hbox G.target.st hedge).pos_mem_succP t⟩

/-- **Clause 6**: the target path's position at the target time is live. This is what replaces the
dropped `witness` field, and the canonical run is the witness. -/
theorem targetPos_mem_liveAt_of_canLab (G : PlusSlicedCertificate Γ Del)
    (hbox : G.BoxLabelFaithful)
    (hedge : ∀ t : ℤ, G.edge t (G.target.st t) (G.target.st (t + 1)) = true)
    (hcan : ∀ t : ℤ, G.target.lab t = G.canLab G.target.st t)
    (htt : G.targetTime ∈ G.winTimes) :
    G.targetPos G.targetTime ∈ G.liveAt G.targetTime := by
  rw [G.targetPos_eq_canRun_pos hbox hedge hcan G.targetTime]
  exact G.mem_liveAt_of_live htt (G.live_canRun hbox G.target.st hedge G.targetTime)

/-- **(C4) `Target`**, from the semantic refutation at the target time. -/
theorem target_of_refutes (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) (hst : G.SlabTrue h)
    (hedge : ∀ t : ℤ, G.edge t (G.target.st t) (G.target.st (t + 1)) = true)
    (hcan : ∀ t : ℤ, G.target.lab t = G.canLab G.target.st t)
    (hprem : ∀ γ ∈ Γ, PlusTruthAt (G.model h) (G.stepHistory h G.target.st hedge)
      G.targetTime γ)
    (hconc : ∀ s ∈ Del, ¬ PlusTruthAt (G.model h) (G.stepHistory h G.target.st hedge)
      G.targetTime s) :
    G.Target := by
  constructor
  · intro γ hγ
    rw [hcan G.targetTime]
    exact (G.mem_canLab G.target.st).mpr ⟨plusPremise_mem_closure hγ,
      (G.plusTruthAt_iff_canAt_of_slabTrue h hst γ (plusPremise_mem_closure hγ)
        G.target.st hedge G.targetTime).mp (hprem γ hγ)⟩
  · intro s hs hmem
    rw [hcan G.targetTime] at hmem
    exact hconc s hs ((G.plusTruthAt_iff_canAt_of_slabTrue h hst s
      (plusConclusion_mem_closure hs) G.target.st hedge G.targetTime).mpr
      ((G.mem_canLab G.target.st).mp hmem).2)

/-! ## The headline -/

/--
**Completeness relative to tail-stable sliced models.**

A bi-serial, tail-stable sliced structure whose slice labelling is semantically correct and whose
target path is a canonically labelled `G.edge`-path refuting the target at a window time admits a
box guess making the checker accept — on the same carrier, with the same target path and the same
target time.

No hypothesis bounds `G₀.n`, `|G₀.back|`, `|G₀.mid|` or `|G₀.fwd|`. The structure is arbitrary in
the class; a bound would be a different and weaker theorem.
-/
theorem exists_plusSlicedCertificate_of_tailStable_countermodel
    (G₀ : PlusSlicedCertificate Γ Del) (hser : G₀.BiSerial) (hTS : G₀.TailStable)
    (hst : G₀.SlabTrue hser)
    (hedge : ∀ t : ℤ, G₀.edge t (G₀.target.st t) (G₀.target.st (t + 1)) = true)
    (hcan : ∀ t : ℤ, G₀.target.lab t = G₀.canLab G₀.target.st t)
    (htt : G₀.targetTime ∈ G₀.winTimes)
    (hprem : ∀ γ ∈ Γ, PlusTruthAt (G₀.model hser)
      (G₀.stepHistory hser G₀.target.st hedge) G₀.targetTime γ)
    (hconc : ∀ s ∈ Del, ¬ PlusTruthAt (G₀.model hser)
      (G₀.stepHistory hser G₀.target.st hedge) G₀.targetTime s) :
    ∃ bx : PlusFormula → Bool, (G₀.withBx bx).Certifies := by
  refine ⟨G₀.canonBx, ?_⟩
  have hser' : (G₀.withBx G₀.canonBx).BiSerial := hser
  have hst' : (G₀.withBx G₀.canonBx).SlabTrue hser' := hst
  have hbox : (G₀.withBx G₀.canonBx).BoxLabelFaithful :=
    boxLabelFaithful_of_slabTrue _ hser' hst' (fun χ _ => G₀.canonBx_eq_true χ)
  have hTS' : (G₀.withBx G₀.canonBx).TailStable := (G₀.withBx_tailStable G₀.canonBx).mpr hTS
  have hedge' : ∀ t : ℤ, (G₀.withBx G₀.canonBx).edge t ((G₀.withBx G₀.canonBx).target.st t)
      ((G₀.withBx G₀.canonBx).target.st (t + 1)) = true := hedge
  have hcan' : ∀ t : ℤ, (G₀.withBx G₀.canonBx).target.lab t
      = (G₀.withBx G₀.canonBx).canLab (G₀.withBx G₀.canonBx).target.st t := by
    intro t
    rw [G₀.withBx_canLab G₀.canonBx (G₀.withBx G₀.canonBx).target.st t]
    exact hcan t
  refine ⟨hser', hTS', hbox, htt,
    targetPathPos_of_canLab _ hbox hedge' hcan',
    targetPos_mem_liveAt_of_canLab _ hbox hedge' hcan' htt,
    stabFaithful_of_slabTrue _ hser' hst' hbox,
    boxLiveFaithful_of_slabTrue _ hser' hst' hbox hTS',
    target_of_refutes _ hser' hst' hedge' hcan' hprem hconc⟩

/--
**The headline, with the carrier equations spelled out.**

Six of them, not four: the produced certificate agrees with `G₀` on `n`, `back`, `mid`, `fwd`,
`target` **and** `targetTime`. The last two are needed and not a bonus — `Window.lean`'s combined
periods are least common multiples of the certificate's *and the target path's* own segment
lengths, so a target path with different periods would give a different window, a different
computed live set and a different tail-stability demand, and `hstab` would not transfer. See this
module's header.

The `HEq`s are an artifact of the dependency `back : List (PlusSlice n _)`: with `n` equal only
propositionally the two list types are not syntactically one, although here they are definitionally
equal and every equation is `rfl`.
-/
theorem exists_certifying_of_tailStable_countermodel
    (G₀ : PlusSlicedCertificate Γ Del) (hser : G₀.BiSerial) (hTS : G₀.TailStable)
    (hst : G₀.SlabTrue hser)
    (hedge : ∀ t : ℤ, G₀.edge t (G₀.target.st t) (G₀.target.st (t + 1)) = true)
    (hcan : ∀ t : ℤ, G₀.target.lab t = G₀.canLab G₀.target.st t)
    (htt : G₀.targetTime ∈ G₀.winTimes)
    (hprem : ∀ γ ∈ Γ, PlusTruthAt (G₀.model hser)
      (G₀.stepHistory hser G₀.target.st hedge) G₀.targetTime γ)
    (hconc : ∀ s ∈ Del, ¬ PlusTruthAt (G₀.model hser)
      (G₀.stepHistory hser G₀.target.st hedge) G₀.targetTime s) :
    ∃ G : PlusSlicedCertificate Γ Del,
      G.n = G₀.n ∧ HEq G.back G₀.back ∧ HEq G.mid G₀.mid ∧ HEq G.fwd G₀.fwd ∧
        HEq G.target G₀.target ∧ G.targetTime = G₀.targetTime ∧ G.Certifies := by
  obtain ⟨bx, hc⟩ := G₀.exists_plusSlicedCertificate_of_tailStable_countermodel hser hTS hst
    hedge hcan htt hprem hconc
  exact ⟨G₀.withBx bx, rfl, HEq.rfl, HEq.rfl, HEq.rfl, HEq.rfl, rfl, hc⟩

/--
**The refutation interface, closing the loop.**

The certificate this theorem produces is accepted, so `Sound.lean`'s `plusRefutes_of_certifies`
applies to it: a countermodel in this class really does yield `PlusWitnessFamily.PlusRefutes Γ Del`,
the same unchanged export the landed sharing-family producer lands. Soundness and completeness meet
on one interface and neither is weakened to do so.
-/
theorem plusRefutes_of_tailStable_countermodel
    (G₀ : PlusSlicedCertificate Γ Del) (hser : G₀.BiSerial) (hTS : G₀.TailStable)
    (hst : G₀.SlabTrue hser)
    (hedge : ∀ t : ℤ, G₀.edge t (G₀.target.st t) (G₀.target.st (t + 1)) = true)
    (hcan : ∀ t : ℤ, G₀.target.lab t = G₀.canLab G₀.target.st t)
    (htt : G₀.targetTime ∈ G₀.winTimes)
    (hprem : ∀ γ ∈ Γ, PlusTruthAt (G₀.model hser)
      (G₀.stepHistory hser G₀.target.st hedge) G₀.targetTime γ)
    (hconc : ∀ s ∈ Del, ¬ PlusTruthAt (G₀.model hser)
      (G₀.stepHistory hser G₀.target.st hedge) G₀.targetTime s) :
    PlusWitnessFamily.PlusRefutes Γ Del := by
  obtain ⟨bx, hc⟩ := G₀.exists_plusSlicedCertificate_of_tailStable_countermodel hser hTS hst
    hedge hcan htt hprem hconc
  exact (G₀.withBx bx).plusRefutes_of_certifies hc

/-! ## The hypothesis set is satisfiable

A completeness theorem with eight hypotheses invites one question before any other: **are they
jointly satisfiable?** They are, and the witness is exhibited rather than asserted — `Check.lean`'s
`Probe.triv`, the one-slice certificate at the empty context, meets every one of them, and the
headline applied to it returns a box guess making the checker accept.

**What this shows and what it does not.** It shows the hypothesis set is consistent: no two
hypotheses here contradict each other, which is the way a theorem of this shape is most likely to be
empty. It does **not** show the class is interesting — at the empty context every closure-guarded
clause is vacuous and the refuted sequent is the empty one. A non-degenerate instance is a separate
piece of work, and the embedding of the landed `Formula`-side witness family is where it belongs.
-/

namespace Probe

/-- `triv`'s slice sequence is constant, by `slice_onePointCertificate`. -/
theorem triv_slice (t : ℤ) : triv.slice t = slice1 :=
  slice_onePointCertificate [] [] Nat.one_pos slice1 (fun _ => false) path1 0 t

/-- Every edge of `triv` holds: the one slice's edge relation is constantly `true`. -/
theorem triv_edge (t : ℤ) (w u : Fin triv.n) : triv.edge t w u = true := by
  have he : triv.edge t w u = (triv.slice t).edge w u := rfl
  rw [he, triv_slice]
  rfl

/-- The constant target path's label is empty at every time, because every decoded datum is a member
of its own data and both of its non-empty segments carry `∅`. -/
theorem path1_lab (t : ℤ) : path1.lab t = ∅ := by
  have h := path1.datum_mem t
  have hd : path1.datum t = ((∅ : Finset PlusFormula), (0 : Fin 1)) := by
    rcases List.mem_append.mp h with h | h
    · rcases List.mem_append.mp h with h | h
      · exact List.mem_singleton.mp h
      · exact absurd h (by simp [path1])
    · exact List.mem_singleton.mp h
  rw [PlusGraphPath.lab, hd]

/-- Every canonical label of `triv` is empty, because the empty context's closure is empty. -/
theorem triv_canLab (g : ℤ → Fin triv.n) (t : ℤ) : triv.canLab g t = ∅ := by
  refine Finset.eq_empty_iff_forall_notMem.mpr (fun ψ hψ => ?_)
  have hm := ((triv.mem_canLab g).mp hψ).1
  rw [closure_empty] at hm
  exact absurd hm (Finset.notMem_empty ψ)

/-- `triv`'s slice labelling is semantically correct, vacuously: both clauses of `SlabTrue` are
guarded by membership in the empty context's closure, which is empty. -/
theorem triv_slabTrue (h : triv.BiSerial) : triv.SlabTrue h := by
  constructor
  · intro χ hχ
    rw [closure_empty] at hχ
    exact absurd hχ (Finset.notMem_empty _)
  · intro χ hχ
    rw [closure_empty] at hχ
    exact absurd hχ (Finset.notMem_empty _)

/-- **The hypothesis set of the headline is satisfiable.** Every hypothesis is discharged at `triv`,
three of them by the kernel's own evaluation of the checker's `Decidable` instances. -/
theorem exists_certifying_triv : ∃ bx : PlusFormula → Bool, (triv.withBx bx).Certifies :=
  triv.exists_plusSlicedCertificate_of_tailStable_countermodel
    (by decide) (by decide) (triv_slabTrue (by decide))
    (fun t => triv_edge t _ _)
    (fun t => by rw [triv_canLab]; exact path1_lab t)
    (by decide)
    (fun γ hγ => by simp at hγ)
    (fun s hs => by simp at hs)

end Probe

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
