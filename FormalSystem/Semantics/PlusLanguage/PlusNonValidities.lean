/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusValidity
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred

/-!
# Non-validities of `⊡` on the permissive frame over ℤ

Machine-checked refutations of the candidate `⊡`/tense interaction principles that are **not**
axioms of TM⁺ (`PlusLanguage/Axioms.lean`). Every refutation lives on one countermodel: the
permissive frame `natFrame` over `ℤ` (`Semantics/TaskFrame.lean`), where every function
`ℤ → ℕ` is a total history, so `⟨τ⟩_t` is as large as it can be; the valuation makes every atom
true at world state `0` and nowhere else.

| Name | Refuted schema | What it shows |
|------|----------------|---------------|
| `refute_stab_box` | `⊡p → □⊡p` | `⊡` does not collapse into `□` |
| `refute_allFuture_stab` | `G⊡p → ⊡Gp` | the converse of GS fails, even for atoms |
| `refute_stab_allFuture_past` | `⊡GPp → G⊡Pp` | GS (`stab_allFuture_valid`) genuinely needs its pure-future side condition |
| `refute_determined` | `Fp → ⊡Fp` | *Determined* (paper line 1426) is refuted over a non-deterministic frame |
| `refute_somePast_stab` | `P⊡p → ⊡Pp` | `⟨τ⟩_t` is not closed towards the past |

On `refute_determined`: this module lands only the refutation over a non-deterministic frame
(the second half of the paper's `app:deterministic` correspondence theorem, in the `natFrame` shape); validity of the *Determined*
schema over deterministic frames is **not** formalized here, and no claim about the class of
frames validating it is made.

On `refute_allFuture_stab` / `refute_stab_allFuture_past`: GS (`Semantics/PlusLanguage/PlusPasting.lean`,
`stab_allFuture_valid`) is `⊡Gφ → G⊡φ` for **pure-future** `φ`. The second refutation shows the
restriction is necessary — with `φ := Pp` the pasted history keeps `τ`'s past, not the
witness's, and `Pp` flips — and the first shows the converse direction is simply wrong.

`refute_somePast_stab` is the `⊡`-analogue of the single tense/modal interaction axiom of
T×W / Ockhamist logic (Kamp's AK12 in Thomason 1984 §4; Reynolds 2003's HN), and it fails here
because `⟨τ⟩_t` is defined by a same-time condition, with no backward closure.

## Provenance

Transcription of Part D of the compiled stability-modal probes recorded with the research on the
`⊡` axiomatization; proofs unchanged.

## References

* JPL paper line 1426 (*Determined*), `app:deterministic` (whose second half is the non-deterministic refutation)
* `FormalSystem/Semantics/TaskFrame.lean` — `natFrame`

## Tags

plus-language · refutation · stability-modal · upper-bound
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open PlusTruth

/-- The permissive frame over `ℤ`: every function `ℤ → ℕ` is a total history. -/
abbrev NF : TaskFrame := FrameOver.natFrame (D := ℤ)

/-- Any function `ℤ → ℕ` as a total history of `NF`. -/
def natHist (f : ℤ → ℕ) : PartialHistory NF :=
  PartialHistory.ofTotal NF f (fun s t => by
    refine (FrameOver.natFrame_rel_iff _ _ _).mpr ?_
    by_cases h : t - s = 0
    · right
      have : t = s := sub_eq_zero.mp h
      subst this; rfl
    · left; exact h)

theorem natHist_isTotal (f : ℤ → ℕ) : (natHist f).IsTotal := PartialHistory.ofTotal_isTotal _ _ _

/-- Every atom is true at world state `0` and nowhere else. -/
def natModel : TaskModel NF where
  valuation := fun (n : ℕ) _ => n = 0

/-- `⊡p → □⊡p` is refuted: `⊡` does not collapse into `□`. -/
theorem refute_stab_box (p : Atom) :
    ¬ PlusValid (.imp (.stab (.atom p)) (.box (.stab (.atom p)))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) (natHist_isTotal _) 0
  have h1 : PlusTruthAt natModel (natHist fun _ => 0) 0 (.stab (.atom p)) := by
    intro σ hσ hs
    exact ⟨hσ 0, (hs trivial (hσ 0)).symm⟩
  have h2 := hv h1 (natHist fun _ => 1) (natHist_isTotal _) (natHist fun _ => 1)
    (natHist_isTotal _) (fun _ _ => rfl)
  rw [atom_iff] at h2
  obtain ⟨_, h4⟩ := h2
  have h5 : (1 : ℕ) = 0 := h4
  exact one_ne_zero h5

/-- `G⊡p → ⊡Gp` is refuted: the converse of GS fails even for atoms. -/
theorem refute_allFuture_stab (p : Atom) :
    ¬ PlusValid (.imp (allFuture (.stab (.atom p))) (.stab (allFuture (.atom p)))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) (natHist_isTotal _) 0
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0 (allFuture (.stab (.atom p))) := by
    rw [allFuture_iff]
    intro y _ ρ hρ hs
    exact ⟨hρ y, (hs trivial (hρ y)).symm⟩
  have hB := hv hA (natHist fun s => if s = 1 then 1 else 0) (natHist_isTotal _)
    (fun _ _ => by show (0 : ℕ) = (if (0 : ℤ) = 1 then 1 else 0); simp)
  rw [allFuture_iff] at hB
  have hat := hB (1 : ℤ) (one_pos : (0 : ℤ) < 1)
  rw [atom_iff] at hat
  obtain ⟨_, v⟩ := hat
  have v' : (if (1 : ℤ) = 1 then (1 : ℕ) else 0) = 0 := v
  simp at v'

/-- `⊡GPp → G⊡Pp` is refuted: GS genuinely needs its pure-future side condition. -/
theorem refute_stab_allFuture_past (p : Atom) :
    ¬ PlusValid (.imp (.stab (allFuture (somePast (.atom p))))
        (allFuture (.stab (somePast (.atom p))))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) (natHist_isTotal _) 0
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0
      (.stab (allFuture (somePast (.atom p)))) := by
    intro σ hσ hs
    rw [allFuture_iff]
    intro y hy
    rw [somePast_iff]
    exact ⟨0, hy, hσ 0, (hs trivial (hσ 0)).symm⟩
  have hB := hv hA
  rw [allFuture_iff] at hB
  have hC := hB (1 : ℤ) (one_pos : (0 : ℤ) < 1) (natHist fun s => if s = 1 then 0 else 1)
    (natHist_isTotal _)
    (fun _ _ => by show (0 : ℕ) = (if (1 : ℤ) = 1 then 0 else 1); simp)
  rw [somePast_iff] at hC
  obtain ⟨s, hs1, hat⟩ := hC
  rw [atom_iff] at hat
  obtain ⟨_, v⟩ := hat
  have hs1' : (s : ℤ) < 1 := hs1
  have v' : (if (s : ℤ) = 1 then (0 : ℕ) else 1) = 0 := v
  rw [if_neg (fun h => by rw [h] at hs1'; exact lt_irrefl _ hs1')] at v'
  exact one_ne_zero v'

/--
*Determined* `Fp → ⊡Fp` is refuted over a non-deterministic frame: the **negative half** of
`app:deterministic`, in the `natFrame` shape.

The positive half **is** formalized, in `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` — see
`determined_of_deterministic`, which shows the schema valid on every frame satisfying
`TaskFrame.Deterministic` (`Semantics/FrameProperty.lean`). The two halves are the two sides of
`app:deterministic` and cite each other; neither statement claims the other's converse, and in
fact the converse of the positive half is false (a non-deterministic frame validating the schema
is exhibited under `Metalogic/Independence/`).

Two things the refutation depends on, recorded because both are easy to lose:

* **The refuting instance is `Fp`, not an atom.** At an atom the schema `p → ⊡p` holds on *every*
  frame (`stab_of_stateLocal` at `stateLocal_atom`, `Semantics/PlusLanguage/PlusStateLocal.lean`): an atom's
  truth depends on the world state alone, which is exactly what `⊡` quantifies over. More is
  true — `Fp` is refutable precisely *because* it lies outside the state-locality fragment
  (`not_isPlusStateLocal_someFuture`), and every formula inside it satisfies the schema. So no uniform-substitution argument is
  available here — a schema can be frame-valid at its atomic instances and refutable at a
  genuinely temporal one, and it is. Every refutation in this family must exhibit a temporal
  formula.
* **`NF`'s discreteness is a genuine hypothesis**, carried by `natFrame`'s `[SuccOrder D]` and
  `[NoMaxOrder D]` binders, not a convenience of the presentation. In a *dense* order the cone
  around a state is all of `W` and the frame's *Limit* field fails outright, so this particular
  witness does not survive relaxing the carrier.
-/
theorem refute_determined (p : Atom) :
    ¬ PlusValid (.imp (someFuture (.atom p)) (.stab (someFuture (.atom p)))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) (natHist_isTotal _) 0
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0 (someFuture (.atom p)) := by
    rw [someFuture_iff]; exact ⟨(1 : ℤ), (one_pos : (0 : ℤ) < 1), trivial, (rfl : (0 : ℕ) = 0)⟩
  have hB := hv hA (natHist fun s => if s ≤ 0 then 0 else 1) (natHist_isTotal _)
    (fun _ _ => by show (0 : ℕ) = (if (0 : ℤ) ≤ 0 then 0 else 1); simp)
  rw [someFuture_iff] at hB
  obtain ⟨s, hs, hat⟩ := hB
  rw [atom_iff] at hat
  obtain ⟨_, v⟩ := hat
  have hs' : (0 : ℤ) < s := hs
  have v' : (if (s : ℤ) ≤ 0 then (0 : ℕ) else 1) = 0 := v
  rw [if_neg (not_le.mpr hs')] at v'
  exact one_ne_zero v'

/-- `P⊡p → ⊡Pp` is refuted: `⟨τ⟩_t` is not closed towards the past. This is the `⊡`-analogue of
the single tense/modal interaction axiom of T×W / Ockhamist logic (Kamp's AK12 in Thomason
1984 §4, Reynolds 2003's HN). -/
theorem refute_somePast_stab (p : Atom) :
    ¬ PlusValid (.imp (somePast (.stab (.atom p))) (.stab (somePast (.atom p)))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) (natHist_isTotal _) 0
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0 (somePast (.stab (.atom p))) := by
    rw [somePast_iff]
    refine ⟨(-1 : ℤ), (by decide : (-1 : ℤ) < 0), ?_⟩
    intro ρ hρ hs
    exact ⟨hρ (-1), (hs trivial (hρ (-1))).symm⟩
  have hB := hv hA (natHist fun s => if s < 0 then 1 else 0) (natHist_isTotal _)
    (fun _ _ => by show (0 : ℕ) = (if (0 : ℤ) < 0 then 1 else 0); simp)
  rw [somePast_iff] at hB
  obtain ⟨s, hs, hat⟩ := hB
  rw [atom_iff] at hat
  obtain ⟨_, v⟩ := hat
  have hs' : (s : ℤ) < 0 := hs
  have v' : (if (s : ℤ) < 0 then (1 : ℕ) else 0) = 0 := v
  rw [if_pos hs'] at v'
  exact one_ne_zero v'

end FormalSystem.Semantics
