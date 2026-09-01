/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.BLSchemaValidity
import FormalSystem.Metalogic.BaseLanguageSoundness
import FormalSystem.Metalogic.BXCanonical

/-!
# The `(Sp)` witness — validity, and the TM⁺ half of CEB

`(Sp) := □(DF φ) ∨ □(DN ψ)` — the *reconstruction* (not the source's formula; see the
Provenance section below) of the CEB witness `Conservativity.lean`'s module docstring names.
This module proves `BLValid (Sp φ ψ)` from `duration_dense_or_least_pos`'s dichotomy composed
with `Semantics/BLSchemaValidity.lean`'s Lemmas B and C, then derives
`⊢[Base] tr (Sp φ ψ)` from `BXCanonical.completeness` — the CEB analogue of `Conservativity.lean`'s
`z1_translate`, obtained without the source's TMP-NB/M5 derivation (report §4.1, §6.2 closing
paragraph).

## What this does **not** do

CEB's failing half — no instance of `(Sp)` is a TM-theorem — is an explicit Non-Goal of this
task (report §6.2: `BLTruthAt`/`bl_soundness` are `TaskFrame`-bound and TM⁺ is *unsound* on the
two-fibre class, so the composition route this module uses is unavailable for the failing
half). Nothing here claims or approaches that half.

## The un-boxed sharpening (report §4.2)

The *un-boxed* `DF φ ∨ DN ψ` is valid on every strict linear order whatsoever — `□` is what
turns the dichotomy from a property of one history's local order into a frame-uniform one (a
single shared `Duration` on which the whole frame's dichotomy is decided once). `blValid_df_or_dn`
below proves this un-boxed claim directly, since it costs nothing beyond dropping the `.box`/
`box_iff` step from `blValid_sp`'s own proof.

## Provenance

`(Sp)` is a *reconstruction*, not the source's formula: `thm:ConservativeExtension` was deleted
from the paper at `b07ceb31`; see `Conservativity.lean`'s "Provenance of the source claim"
section, which is the authority on that history.

## Main Definitions

- `Sp` — `□(DF φ) ∨ □(DN ψ)`, the boxed dichotomy witness

## Main Results

- `blValid_df_or_dn` — the un-boxed sharpening: `DF φ ∨ DN ψ` is valid on every task frame
- `blValid_sp` — `BLValid (Sp φ ψ)`
- `sp_translate` — `⊢[Base] tr (Sp φ ψ)`, the CEB witness's TM⁺ half

## References

* `specs/495_determine_tm_completeness_status_over_task_frames/reports/01_tm-completeness-status.md`
  §4.1, §4.2, §6.2
* `FormalSystem/Metalogic/Conservativity.lean` — the CEB/CEF refutation record and the forward
  prohibition this module never approaches
* `FormalSystem/Semantics/BLSchemaValidity.lean` — the DF/DN semantic lemmas
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.BaseLanguage
open FormalSystem.Semantics

/--
**The `(Sp)` witness**: `□(DF φ) ∨ □(DN ψ)`, reusing the exact `Axiom.df`/`Axiom.dn` formula
shapes pinned in `Semantics/BLSchemaValidity.lean` (which are themselves pinned to
`BaseLanguage/Axioms.lean`'s own definitions).
-/
def Sp (φ ψ : BLFormula) : BLFormula :=
  (((φ.allPast.and φ).and BLFormula.top.someFuture).imp φ.allPast.someFuture).box.or
    ((ψ.allFuture.allFuture.imp ψ.allFuture).box)

/--
**The un-boxed sharpening (report §4.2).** `DF φ ∨ DN ψ` — without the `□` — is true at every
model, history and time, on *every* task frame whatsoever: `Sp`'s dichotomy is decided once by
the frame's own `Duration` (via `duration_dense_or_least_pos`), before any modal quantification.
What `□` in `Sp` detects is therefore modal rigidity, not a temporal property — a structure
refuting `(Sp)` must be one where *different histories* see differently-shaped time (the
two-fibre countermodel report §6.2 names as CEB's missing piece, out of scope here).
-/
theorem blValid_df_or_dn (φ ψ : BLFormula) :
    BLValid
      ((((φ.allPast.and φ).and BLFormula.top.someFuture).imp φ.allPast.someFuture).or
        (ψ.allFuture.allFuture.imp ψ.allFuture)) := by
  refine BLValid.of_forall_total ?_
  intro F M τ _hτ t
  rcases duration_dense_or_least_pos (D := F.Duration) with hdense | ⟨d, hd⟩
  · exact (BLTruth.or_iff _ _).mpr (Or.inr (@dn_valid_of_denselyOrdered F hdense M τ t ψ))
  · exact (BLTruth.or_iff _ _).mpr (Or.inl (df_valid_of_isLeast_pos hd M τ t φ))

/--
**`BLValid (Sp φ ψ)`.** Case-split on `duration_dense_or_least_pos F.Duration`: the
least-positive branch gives the left disjunct at every history via `df_valid_of_isLeast_pos`,
the dense branch gives the right via `dn_valid_of_denselyOrdered`.

The `□` is discharged by the frame carrying **one shared** `Duration`, which is what makes the
dichotomy a property of the frame rather than of a history: `duration_dense_or_least_pos` is
applied once, to `F.Duration`, before the `∀ σ, σ.IsTotal → …` quantification of `box_iff`.
-/
theorem blValid_sp (φ ψ : BLFormula) : BLValid (Sp φ ψ) := by
  refine BLValid.of_forall_total ?_
  intro F M τ _hτ t
  rcases duration_dense_or_least_pos (D := F.Duration) with hdense | ⟨d, hd⟩
  · refine (BLTruth.or_iff _ _).mpr (Or.inr ?_)
    rw [BLTruth.box_iff]
    intro σ _hσ
    exact @dn_valid_of_denselyOrdered F hdense M σ t ψ
  · refine (BLTruth.or_iff _ _).mpr (Or.inl ?_)
    rw [BLTruth.box_iff]
    intro σ _hσ
    exact df_valid_of_isLeast_pos hd M σ t φ

/--
**`⊢[Base] tr (Sp φ ψ)`** — the CEB witness's TM⁺ half, the analogue of
`Conservativity.z1_translate`. Derived from `blValid_sp` via `blValid_iff_valid_tr` then
`BXCanonical.completeness`, with **no appeal to the source's TMP-NB/M5 derivation** — the route
here is purely the completeness composition.
-/
theorem sp_translate (φ ψ : BLFormula) :
    ProofSystem.Derivable FrameClass.Base [] (tr (Sp φ ψ)) :=
  BXCanonical.completeness (tr (Sp φ ψ)) ((blValid_iff_valid_tr (Sp φ ψ)).mp (blValid_sp φ ψ))

end FormalSystem.Metalogic
