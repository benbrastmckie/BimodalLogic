/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Deterministic.Validity

/-!
# `⊡`-erasure and the semantic collapse over the deterministic frames

`erasePlus` deletes every occurrence of the stability modal from an L⁺ formula, landing in L.
Over a **deterministic** frame the deletion is truth-preserving at every world history and time
(`plusTruthAt_erasePlus_of_deterministic`), so L⁺-validity over the deterministic frames of a
class reduces to L-validity over the same frames — which is what lets the four TM completeness
engines be reached from an L⁺ hypothesis (`Metalogic/Deterministic/Completeness.lean`).

## Main Definitions

- `erasePlus : PlusFormula → Formula` — `erasePlus (.stab φ) = erasePlus φ`, every other
  constructor mapped to its L namesake

## Main Results

- `erasePlus_ofFormula` — `erasePlus` is a retraction of the embedding `ofFormula`
- `erasePlus_swapTemporal` — erasure commutes with temporal duality (`⊡` is fixed by it)
- `plusTruthAt_erasePlus_of_deterministic` — the pointwise collapse
- `validDetIn_erasePlus_of_plusValidDetIn` and its converse — the validity-level corollary, at
  every frame class

## Why the pointwise lemma quantifies over histories and times

The `box` clause of `PlusTruthAt` quantifies over the frame's world histories, and the induction
hypothesis is needed there at a **different** history; the `untl`/`snce` clauses need it at a
different time on the *same* history. So the statement has to be universally quantified over
world histories and times.

## What this does not say

The collapse is the `⊡ = identity` special case. It says nothing about frames that merely
*validate* the *Determined* schema without being deterministic (`DeterminedValid`,
`Metalogic/Deterministic/Validity.lean`) — on those, `⊡` need not be pointwise trivial, only
logically so. The bridge between the two is the coincidence corollary, not this module.

## References

* JPL paper `app:deterministic`, `lem:deterministic-singleton`
* `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` — `stab_iff_of_deterministic`, consumed here

## Tags

determinism · erasure · plus-language · stability-modal · app:deterministic
-/

namespace FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage
open FormalSystem.Semantics

/-! ## The erasure -/

/-- Deletion of every `stab` occurrence: the six L constructors go to their `Formula` namesakes
and `⊡φ` goes to the erasure of `φ`. -/
def erasePlus : PlusFormula → Formula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (erasePlus φ) (erasePlus ψ)
  | .box φ => .box (erasePlus φ)
  | .untl ψ φ => .untl (erasePlus ψ) (erasePlus φ)
  | .snce ψ φ => .snce (erasePlus ψ) (erasePlus φ)
  | .stab φ => erasePlus φ

/-- `erasePlus` is a retraction of the embedding `ofFormula`: erasing an L formula's image
returns it unchanged. -/
@[simp] theorem erasePlus_ofFormula (φ : Formula) : erasePlus (ofFormula φ) = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [ofFormula, erasePlus, ih1, ih2]
  | box _ ih => simp only [ofFormula, erasePlus, ih]
  | untl _ _ ih1 ih2 => simp only [ofFormula, erasePlus, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [ofFormula, erasePlus, ih1, ih2]

/-- Erasure commutes with temporal duality: `swapTemporal` fixes `⊡` on the L⁺ side and the six
L constructors are exchanged in the same pattern on both sides. -/
theorem erasePlus_swapTemporal (φ : PlusFormula) :
    erasePlus φ.swapTemporal = (erasePlus φ).swapTemporal := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 =>
    simp only [PlusFormula.swapTemporal, erasePlus, Formula.swapTemporal, ih1, ih2]
  | box _ ih => simp only [PlusFormula.swapTemporal, erasePlus, Formula.swapTemporal, ih]
  | untl _ _ ih1 ih2 =>
    simp only [PlusFormula.swapTemporal, erasePlus, Formula.swapTemporal, ih1, ih2]
  | snce _ _ ih1 ih2 =>
    simp only [PlusFormula.swapTemporal, erasePlus, Formula.swapTemporal, ih1, ih2]
  | stab _ ih => simp only [PlusFormula.swapTemporal, erasePlus, ih]

/-! ### Push-through pins for the derived operators

Every L⁺ derived operator carries `Formula`'s right-hand side verbatim
(`PlusLanguage/Formula.lean`), so `erasePlus` commutes with each of them definitionally. These
pins are the contract the collapse derivation (`Metalogic/Deterministic/Collapse.lean`) relies
on. -/

example : erasePlus PlusFormula.top = Formula.top := rfl
example (φ : PlusFormula) : erasePlus φ.neg = (erasePlus φ).neg := rfl
example (φ ψ : PlusFormula) : erasePlus (φ.and ψ) = (erasePlus φ).and (erasePlus ψ) := rfl
example (φ ψ : PlusFormula) : erasePlus (φ.or ψ) = (erasePlus φ).or (erasePlus ψ) := rfl
example (φ : PlusFormula) :
    erasePlus (PlusFormula.someFuture φ) = Formula.someFuture (erasePlus φ) := rfl
example (φ : PlusFormula) :
    erasePlus (PlusFormula.allFuture φ) = Formula.allFuture (erasePlus φ) := rfl
example (φ : PlusFormula) : erasePlus (PlusFormula.dstab φ) = (erasePlus φ).neg.neg := rfl

/-! ## The pointwise collapse -/

variable {F : TaskFrame}

/--
**The pointwise collapse.** Over a deterministic frame, an L⁺ formula and its erasure hold at
exactly the same world histories and times.

By induction on `φ`, generalizing the history and the time. The `box` case needs the hypothesis
at another history — hence the history binder is carried inside the statement rather than
fixed outside it — and the `untl`/`snce` cases need it at another time. The `stab` case is 536's
`stab_iff_of_deterministic` followed by the induction hypothesis; nothing here re-derives the
collapse.
-/
theorem plusTruthAt_erasePlus_of_deterministic (hD : F.Deterministic) (M : TaskModel F)
    (φ : PlusFormula) :
    ∀ (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t φ ↔ TruthAt M τ t (erasePlus φ) := by
  induction φ with
  | atom p => intro τ t; exact Iff.rfl
  | bot => intro τ t; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro τ t; exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih =>
    intro τ t
    exact forall_congr' fun σ => ih σ t
  | untl ψ φ ihψ ihφ =>
    intro τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | snce ψ φ ihψ ihφ =>
    intro τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | stab φ ih =>
    intro τ t
    exact (stab_iff_of_deterministic hD M τ t φ).trans (ih τ t)

/-! ## The validity-level corollary -/

/-- L⁺-validity over the deterministic frames of `fc` gives L-validity of the erasure over the
same frames. -/
theorem validDetIn_erasePlus_of_plusValidDetIn {fc : FrameClass} {φ : PlusFormula}
    (h : PlusValidDetIn fc φ) : ValidDetIn fc (erasePlus φ) :=
  ValidDetIn.of_forall fun F hF hD M τ t =>
    (plusTruthAt_erasePlus_of_deterministic hD M φ τ t).mp
      (PlusValidDetIn.apply h F hF hD M τ t)

/-- The converse: L-validity of the erasure over the deterministic frames of `fc` gives
L⁺-validity of the original over the same frames. -/
theorem plusValidDetIn_of_validDetIn_erasePlus {fc : FrameClass} {φ : PlusFormula}
    (h : ValidDetIn fc (erasePlus φ)) : PlusValidDetIn fc φ :=
  PlusValidDetIn.of_forall fun F hF hD M τ t =>
    (plusTruthAt_erasePlus_of_deterministic hD M φ τ t).mpr
      (ValidDetIn.apply h F hF hD M τ t)

/-- The two directions packaged: over the deterministic frames of any class, an L⁺ formula and
its erasure are equivalid. -/
theorem plusValidDetIn_iff_validDetIn_erasePlus (fc : FrameClass) (φ : PlusFormula) :
    PlusValidDetIn fc φ ↔ ValidDetIn fc (erasePlus φ) :=
  ⟨validDetIn_erasePlus_of_plusValidDetIn, plusValidDetIn_of_validDetIn_erasePlus⟩

end FormalSystem.Metalogic.Deterministic
