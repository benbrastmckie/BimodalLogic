/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.MinusLanguage.MinusSchemaValidity
import FormalSystem.Metalogic.Conservativity.MinusLanguageSoundness
import FormalSystem.Metalogic.BXCanonical

/-!
# The `(Sp)` witness — validity, and the TM half of CEB

`(Sp) := □(DF φ) ∨ □(DN ψ)` — the *reconstruction* (not the source's formula; see the
Provenance section below) of the CEB witness `Conservativity.lean`'s module docstring names.
This module proves `MinusValid (Sp φ ψ)` from `duration_dense_or_least_pos`'s dichotomy composed
with `Semantics/MinusLanguage/MinusSchemaValidity.lean`'s Lemmas B and C, then derives
`⊢[Base] tr (Sp φ ψ)` from `BXCanonical.completeness` — the CEB analogue of `Conservativity.lean`'s
`z1_translate`, obtained without the source's TMP-NB/M5 derivation (report §4.1, §6.2 closing
paragraph).

## What this does **not** do

CEB's failing half — the schema `(Sp)` is not a TM⁻-theorem — is out of scope *here* and is not
claimed or approached by anything in this module: `MinusTruthAt`/`minus_soundness` are
`TaskFrame`-bound and TM is *unsound* on the two-fibre class, so the composition route this
module uses is unavailable for that half (report §6.2).

It is, however, no longer an open claim. It is discharged in
`FormalSystem/Metalogic/Conservativity/SpCountermodel.lean`, which builds the native
(`TaskFrame`-free) semantics of `FormalSystem/Semantics/MinusLanguage/MinusFrame.lean`, proves L⁻ soundness for TM⁻
directly against it, and refutes the atomic instance on the disjoint sum `ℤ ⊕ ℝ` —
`not_derivable_sp`, and its corollary `tmMinusCompleteBase_refuted : ¬ TMMinusCompleteBase`. Note the claim
there is **schema-level**: `□(DF ⊤)` holds on every `MinusFrame`, so `Sp ⊤ ψ` is *not* refuted, and
the universally quantified reading is false.

## The un-boxed sharpening (report §4.2)

The *un-boxed* `DF φ ∨ DN ψ` is valid on every strict linear order whatsoever — `□` is what
turns the dichotomy from a property of one history's local order into a frame-uniform one (a
single shared `Duration` on which the whole frame's dichotomy is decided once). `minusValid_df_or_dn`
below proves this un-boxed claim directly, since it costs nothing beyond dropping the `.box`/
`box_iff` step from `minusValid_sp`'s own proof.

## Provenance

`(Sp)` is a *reconstruction*, not the source's formula: `thm:ConservativeExtension` was deleted
from the paper at `b07ceb31`; see `Conservativity.lean`'s "Provenance of the source claim"
section, which is the authority on that history.

## Main Definitions

- `Sp` — `□(DF φ) ∨ □(DN ψ)`, the boxed dichotomy witness

## Main Results

- `minusValid_df_or_dn` — the un-boxed sharpening: `DF φ ∨ DN ψ` is valid on every task frame
- `minusValid_sp` — `MinusValid (Sp φ ψ)`
- `sp_translate` — `⊢[Base] tr (Sp φ ψ)`, the CEB witness's TM half

## References

* The TM⁻-completeness status report (`01_tm-completeness-status.md`),
  §4.1, §4.2, §6.2
* `FormalSystem/Metalogic/Conservativity.lean` — the CEB/CEF refutation record and the forward
  prohibition this module never approaches
* `FormalSystem/Metalogic/Conservativity/SpCountermodel.lean` — CEB's failing half, discharged
  over the native `MinusFrame` semantics
* `FormalSystem/Semantics/MinusLanguage/MinusSchemaValidity.lean` — the DF/DN semantic lemmas
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.Semantics

/--
**The `(Sp)` witness**: `□(DF φ) ∨ □(DN ψ)`, reusing the exact `Axiom.df`/`Axiom.dn` formula
shapes pinned in `Semantics/MinusLanguage/MinusSchemaValidity.lean` (which are themselves pinned to
`MinusLanguage/Axioms.lean`'s own definitions).
-/
def Sp (φ ψ : MinusFormula) : MinusFormula :=
  (((φ.allPast.and φ).and MinusFormula.top.someFuture).imp φ.allPast.someFuture).box.or
    ((ψ.allFuture.allFuture.imp ψ.allFuture).box)

/--
**The un-boxed sharpening (report §4.2).** `DF φ ∨ DN ψ` — without the `□` — is true at every
model, history and time, on *every* task frame whatsoever: `Sp`'s dichotomy is decided once by
the frame's own `Duration` (via `duration_dense_or_least_pos`), before any modal quantification.
What `□` in `Sp` detects is therefore modal rigidity, not a temporal property — a structure
refuting `(Sp)` must be one where *different histories* see differently-shaped time (the
two-fibre countermodel report §6.2 names as CEB's missing piece, out of scope here).
-/
theorem minusValid_df_or_dn (φ ψ : MinusFormula) :
    MinusValid
      ((((φ.allPast.and φ).and MinusFormula.top.someFuture).imp φ.allPast.someFuture).or
        (ψ.allFuture.allFuture.imp ψ.allFuture)) := by
  refine MinusValid.of_forall_total ?_
  intro F M τ _hτ t
  rcases duration_dense_or_least_pos (D := F.Duration) with hdense | ⟨d, hd⟩
  · exact (MinusTruth.or_iff _ _).mpr (Or.inr (@dn_valid_of_denselyOrdered F hdense M τ t ψ))
  · exact (MinusTruth.or_iff _ _).mpr (Or.inl (df_valid_of_isLeast_pos hd M τ t φ))

/--
**`MinusValid (Sp φ ψ)`.** Case-split on `duration_dense_or_least_pos F.Duration`: the
least-positive branch gives the left disjunct at every history via `df_valid_of_isLeast_pos`,
the dense branch gives the right via `dn_valid_of_denselyOrdered`.

The `□` is discharged by the frame carrying **one shared** `Duration`, which is what makes the
dichotomy a property of the frame rather than of a history: `duration_dense_or_least_pos` is
applied once, to `F.Duration`, before the `∀ σ, σ.IsTotal → …` quantification of `box_iff`.
-/
theorem minusValid_sp (φ ψ : MinusFormula) : MinusValid (Sp φ ψ) := by
  refine MinusValid.of_forall_total ?_
  intro F M τ _hτ t
  rcases duration_dense_or_least_pos (D := F.Duration) with hdense | ⟨d, hd⟩
  · refine (MinusTruth.or_iff _ _).mpr (Or.inr ?_)
    rw [MinusTruth.box_iff]
    intro σ _hσ
    exact @dn_valid_of_denselyOrdered F hdense M σ t ψ
  · refine (MinusTruth.or_iff _ _).mpr (Or.inl ?_)
    rw [MinusTruth.box_iff]
    intro σ _hσ
    exact df_valid_of_isLeast_pos hd M σ t φ

/--
**`⊢[Base] tr (Sp φ ψ)`** — the CEB witness's TM half, the analogue of
`Conservativity.z1_translate`. Derived from `minusValid_sp` via `minusValid_iff_valid_tr` then
`BXCanonical.completeness`, with **no appeal to the source's TMP-NB/M5 derivation** — the route
here is purely the completeness composition.
-/
theorem sp_translate (φ ψ : MinusFormula) :
    ProofSystem.Derivable FrameClass.Base [] (tr (Sp φ ψ)) :=
  BXCanonical.completeness (tr (Sp φ ψ)) ((minusValid_iff_valid_tr (Sp φ ψ)).mp (minusValid_sp φ ψ))

end FormalSystem.Metalogic
