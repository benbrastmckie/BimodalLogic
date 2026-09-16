/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusNonValidities
import FormalSystem.Semantics.StarLanguage.StarValidity

/-!
# `app:deterministic-future`, negative half — `sent:det` refuted over `NF`

`sent:det` is invalid over some non-deterministic task frame. The manuscript's own proof says
"by the same non-deterministic task frame `F'` and countermodel presented in
`app:deterministic`"; in this tree that countermodel is `NF = FrameOver.natFrame (D := ℤ)` with
`natHist`, `natModel`, and the history pair `τ = const 0` / `σ = fun s => if s ≤ 0 then 0 else 1`
that `refute_determined` (`Semantics/PlusLanguage/PlusNonValidities.lean`) already uses.

Reusing it is the fidelity-preserving choice, not a shortcut: the manuscript explicitly reuses
its own earlier countermodel, and this module reuses the tree's transcription of that
countermodel. Building a second two-state frame from scratch would duplicate it.

## The witnesses line up with the manuscript's `w₀`/`w₁`

`natModel`'s valuation is `n = 0`, so `|p| = {0}`. At `x = 0` and `y = 1`:

* `τ(0) = 0 = σ(0)`, so `σ ∈ ⟨τ⟩₀` — the manuscript's `σ(0) = w₀ = τ(0)`;
* `τ(1) = 0 ∈ |p|`, so `τ` itself refutes the `⊡↓²¬p` disjunct;
* `σ(1) = 1 ∉ |p|`, so `σ` refutes the `⊡↓²p` disjunct.

Both disjuncts of `settledDisj` therefore fail at `(τ, 0, v[0/v₁][1/v₂])`, and `sentDet_unfold`
carries the failure back to `sent:det` itself — exactly the manuscript's pair of witnesses.

## Main Results

- `refute_sentDet` — `app:deterministic-future`, negative half
- `refute_modal_future` — MF (`□φ → □Gφ`) is **not** valid over `StarFormula`
- `storeG_recall_valid` / `refute_erasure` — the pair that closes the naive-erasure route to a
  conservativity translation

## Why MF and the erasure pair are recorded here

Two design facts about TM⋆ (`FormalSystem/StarLanguage/Axioms.lean`) are negative, and a reader
who reaches for either move deserves to find a theorem rather than nothing.

**MF is the sole `timeShift` consumer in the TM schema block.** Its L/L⁺ soundness proof
(`Metalogic/Soundness.lean`, `modal_future_valid`) reaches `φ` at a later time by shifting the
quantified history. The L⋆ restatement `starTruthAt_timeShift` (`Semantics/StarLanguage/StarTruth.lean`)
shifts the **stored-time vector with the history** — it must, since `↓ⁱ` evaluates at a time in
the unshifted frame of reference — so the shift argument delivers `φ` at a shifted vector, never
at the original one. `refute_modal_future` shows the gap is real and not an artefact of the
proof: MF fails over `NF` already at `φ := ↓¹p → p`, whose `□`-antecedent is valid on *every*
frame and model. This is why `StarAxiom.modal_future` is the one TM⋆ schema carrying a side
condition its `PlusAxiom` mirror does not: it is declared at every `RecallFree` (`↓ⁱ`-free)
formula, a fragment that excludes this witness and is nevertheless strictly wider than the
`ofPlus` image, since `↑¹p` is `RecallFree` and is not embedded (`ofPlus_ne_timeStore`).

**Register erasure is not a conservativity translation.** The obvious syntactic route from L⋆ to
L⁺ — delete every `↑ⁱ` and `↓ⁱ` — does not preserve validity in either useful direction:
`storeG_recall_valid` exhibits a `StarValid` formula, `↑¹G↓¹p → p`, whose erasure `Gp → p` is
refuted by `refute_erasure` over `NF`. So conservativity of TM⋆ over TM⁺ cannot be obtained by
translating formulas back down; it is obtained semantically
(`Metalogic/Conservativity/Star/Forward.lean`), and only conditionally at the L⁺ level.

## References

* JPL paper `app:deterministic-future` (negative half), `app:deterministic`, `sent:det`
* `FormalSystem/Semantics/PlusLanguage/PlusNonValidities.lean` — `NF`, `natHist`, `natModel`,
  `refute_determined`
* `FormalSystem/Semantics/StarLanguage/StarDeterminism.lean` — the positive half

## Tags

star-language · non-validity · determinism · app:deterministic-future
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage

/--
**`app:deterministic-future`, negative half.** `sent:det` is refuted over the non-deterministic
frame `NF` — the same frame and countermodel `app:deterministic`'s negative half
(`refute_determined`) uses.

The refuting instance is a bare atom, which is *not* a weakening: unlike *Determined*, whose
atomic instances are frame-valid everywhere (`stab_of_stateLocal`), `sent:det` has genuine
content at an atom because `↓²` moves evaluation to a *different time*, where the present world
state no longer determines the atom's value. That is precisely the discrimination the time
registers buy, and it is why no uniform-substitution argument is needed — or available — here.
-/
theorem refute_sentDet (p : Atom) :
    ¬ NF.StarValidOn (sentDet (ofPlus (PlusFormula.atom p))) := by
  refine not_starValidOn_sentDet natModel (natHist fun _ => 0) (natHist_isTotal _)
    (0 : ℤ) (1 : ℤ) (one_pos : (0 : ℤ) < 1)
    (natHist fun _ => 0) (natHist fun s => if s ≤ 0 then 0 else 1)
    (natHist_isTotal _) (natHist_isTotal _) (SameStateAt.refl _ _)
    (fun _ _ => by show (0 : ℕ) = (if (0 : ℤ) ≤ 0 then 0 else 1); simp) ?_ ?_
  · -- `τ` itself satisfies `p` at time `1`: `τ(1) = 0` and `|p| = {0}`.
    exact fun _ => ⟨trivial, (rfl : (0 : ℕ) = 0)⟩
  · -- `σ` fails `p` at time `1`: `σ(1) = 1 ∉ |p|`.
    rintro _ ⟨_, hval⟩
    have hval' : (if (1 : ℤ) ≤ 0 then (0 : ℕ) else 1) = 0 := hval
    simp at hval'

/-- The same refutation at the level of unrestricted L⋆ validity: `sent:det` is not valid. -/
theorem not_starValid_sentDet (p : Atom) :
    ¬ StarValid (sentDet (ofPlus (PlusFormula.atom p))) :=
  fun h => refute_sentDet p (h NF trivial)

/-! ## MF is not an L⋆ schema -/

/-- The formula MF fails at: `↓¹p → p`. Its `□`-form is valid on every frame and model — `↓¹`
and the bare atom are read at the same time when register `1` holds the time of evaluation — so
the refutation below needs no special antecedent. -/
def mfWitness (p : Atom) : StarFormula := .imp (.timeRecall 1 (.atom p)) (.atom p)

/--
**MF (`□φ → □Gφ`) is not valid over `StarFormula`.**

Refuted over `NF` at `φ := ↓¹p → p`, at `x = 0` with every register holding `0`. The antecedent
`□(↓¹p → p)` holds outright: with register `1` set to the time of evaluation, `↓¹p` and `p` are
read at the same point, so the implication is a tautology in every history. The consequent fails
at the history `σ = (s ↦ if s ≤ 0 then 0 else 1)` and the future time `s = 1`: there `↓¹p` still
reads time `0`, where `σ` has state `0 ∈ |p|`, while `p` reads time `1`, where `σ` has state
`1 ∉ |p|`.

MF is therefore carried in TM⋆ by `StarAxiom.modal_future`, at every `↓ⁱ`-free formula and no
further. This witness is precisely a formula outside that fragment. -/
theorem refute_modal_future (p : Atom) :
    ¬ NF.StarValidOn
      ((StarFormula.box (mfWitness p)).imp
        (StarFormula.box (StarFormula.allFuture (mfWitness p)))) := by
  intro h
  have hv := h.apply_total natModel (natHist fun _ => 0) (natHist_isTotal _) (0 : ℤ)
    (fun _ => (0 : ℤ))
  have hA : StarTruthAt natModel (natHist fun _ => 0) (0 : ℤ) (fun _ => (0 : ℤ))
      (StarFormula.box (mfWitness p)) := by
    intro σ _ hrec
    exact hrec
  have hB := hv hA (natHist fun s => if s ≤ 0 then 0 else 1) (natHist_isTotal _)
  rw [StarTruth.allFuture_iff] at hB
  have hC := hB (1 : ℤ) (one_pos : (0 : ℤ) < 1)
  have hp0 : StarTruthAt natModel (natHist fun s => if s ≤ 0 then 0 else 1)
      ((fun _ => (0 : ℤ)) 1) (fun _ => (0 : ℤ)) (StarFormula.atom p) :=
    ⟨trivial, by show (if (0 : ℤ) ≤ 0 then (0 : ℕ) else 1) = 0; simp⟩
  obtain ⟨_, hval⟩ := hC hp0
  have hval' : (if (1 : ℤ) ≤ 0 then (0 : ℕ) else 1) = 0 := hval
  simp at hval'

/-! ## Register erasure is not a translation -/

/--
**Half one of the erasure refutation**: `↑¹G↓¹p → p` is `StarValid`.

`↑¹` writes the time of evaluation into register `1`; `G↓¹p` then asserts `p` at *that* time
once for every strictly later time, and the frame is serial forward (`exists_gt`), so one
instance suffices to return `p` at the point of evaluation. The atom clause of `StarTruthAt`
does not read the register vector, which is what lets the conclusion be stated at the original
vector. -/
theorem storeG_recall_valid (p : Atom) :
    StarValid ((StarFormula.timeStore 1
      (StarFormula.allFuture (.timeRecall 1 (.atom p)))).imp (.atom p)) := by
  refine StarValid.of_forall_total ?_
  intro F M τ _hτ x v h
  rw [StarTruth.timeStore_iff, StarTruth.allFuture_iff] at h
  obtain ⟨y, hy⟩ := exists_gt x
  have hx := h y hy
  rw [StarTruth.timeRecall_iff, Function.update_self] at hx
  rw [StarTruth.atom_iff] at hx ⊢
  exact hx

/--
**Half two**: the register erasure of `↑¹G↓¹p → p` — namely `Gp → p` — is not valid.

Refuted over `NF` at `τ = (s ↦ if s ≤ 0 then 1 else 0)` and `x = 0`: every strictly later time
has state `0 ∈ |p|`, while time `0` itself has state `1 ∉ |p|`.

Together with `storeG_recall_valid` this closes the naive-erasure route to a conservativity
translation: erasure sends a validity to a non-validity, so it cannot be soundness-preserving in
the direction a translation argument would need. -/
theorem refute_erasure (p : Atom) :
    ¬ StarValid ((StarFormula.allFuture (.atom p)).imp (.atom p)) := by
  intro h
  have hv := h.apply NF natModel (natHist fun s => if s ≤ 0 then 1 else 0)
    (natHist_isTotal _) (0 : ℤ) (fun _ => (0 : ℤ))
  have hA : StarTruthAt natModel (natHist fun s => if s ≤ 0 then 1 else 0) (0 : ℤ)
      (fun _ => (0 : ℤ)) (StarFormula.allFuture (.atom p)) := by
    rw [StarTruth.allFuture_iff]
    intro s hs
    exact ⟨trivial, by
      show (if s ≤ 0 then (1 : ℕ) else 0) = 0
      rw [if_neg (not_le.mpr hs)]⟩
  obtain ⟨_, hval⟩ := hv hA
  have hval' : (if (0 : ℤ) ≤ 0 then (1 : ℕ) else 0) = 0 := hval
  simp at hval'

end FormalSystem.Semantics
