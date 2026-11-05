/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Open.OpenSoundness
import FormalSystem.Metalogic.Conservativity.Plus.Forward

/-!
# Conservativity of the L^▷ proof system — unconditional, over TM and over TM⁺

Two rows, and **both are unconditional**. That is the one place this file differs structurally
from its L⋆ sibling, and the difference is worth naming before the statements.

## Why neither row is conditional, and why that is not an improvement in strength

`Conservativity/Star/Forward.lean` carries one unconditional row (over TM, through a
`WeakCompleteness` engine) and one *conditional* row over TM⁺,
`starConservative_of_plusComplete`, whose hypothesis is general TM⁺ completeness at `fc`. That
hypothesis is **false** at `.Base`: `Metalogic/Independence/PlusIncompleteness.lean` proves
`plus_incomplete_base` and `not_plus_complete_base`. **This file's TM⁺ row is not modelled on
that one**, and must not be read as the same result with the hypothesis discharged.

The TM⁺ row here is unconditional because it is **syntactic**, not semantic: `eraseOpen`
(`OpenLanguage/OpenErasure.lean`) maps an `OpenDerivationTree` to a `PlusDerivationTree` arm by
arm, through a 71-arm discharge table, and `eraseOpen_ofPlus` is its retraction on the image of
the embedding. No validity, no canonical model and no completeness engine enters at any point. It
takes no engine argument, and an engine parameter appearing on it would mean the syntactic route
had been abandoned.

## What this costs, and the guard it owes

Conservativity in this strength is a consequence of **the axiom choice**: the system is
deliberately weak on `▷`. Two concrete prices are recorded rather than hidden:

- The backward definability half `▷◁φ → ⊡φ` is *valid*
  (`OpenLanguage/OpenValidity.lean`'s `openValid_ofut_opast_imp_stab`) and is **not** an
  `OpenAxiom` constructor, precisely because its `eraseOpen` image is the *Determined* schema,
  which `PlusLanguage/PlusNonValidities.lean` refutes. Admitting it would make the discharge arm
  impossible and forfeit this row.
- Nothing stronger about `▷` is admitted than the schemata the discharge table can erase.

**And the strength of the result is class-split.** `▷` is L⁺-definable over integer and real time
and **not** definable over the base and dense classes
(`Metalogic/Expressiveness/OpenFutureElimination.lean` and its non-definability companion). So at
`.ZTime` and `.RTime` the TM⁺ row below records that a notational variant proves the same L⁺
theorems, which is unsurprising; at `.Base` and `.Dense` it records that a genuine extension of
TM⁺ proves no new L⁺ theorem, which is the substantive half. The one statement covers both
because the erasure argument never looks at the frame class.

## No completeness is claimed, for L^▷, at any class, in any form

**Every occurrence of "complete" below is either a `WeakCompleteness` engine for TM — the base
language, one layer down — or part of this guard.** Nothing here is evidence for completeness of
the L^▷ system.

The canonical-bundle obstruction one language down is untouched in both directions:
`plus_incomplete_base` stands exactly as proved; the Burgess-style limit-closure principle `blc`
stays a non-theorem; and an LC_n-style schema is still required in L^▷ exactly as it is in L⁺,
because `▷` and `◁` supply no closure principle for the canonical bundle. A row below that reads
`OpenDerivable fc [] (ofPlus (ofFormula φ)) ↔ Derivable fc [] φ` says that the L^▷ system proves
no new **L** theorem; it says nothing whatever about which L^▷ formulas it proves.

## Main Results

- `forward_open`, and the four instantiated rows — the unconditional forward direction over TM
- `openDerivable_ofFormula_iff` and its four rows — the L ⊂ L^▷ row, both directions
- `openDerivable_ofPlus_iff` — the L⁺ ⊂ L^▷ row, both directions, **unconditional and
  syntactic**: no engine argument

## References

* `FormalSystem/Metalogic/Conservativity/Star/Forward.lean` — the L⋆ sibling, whose TM⁺ row is
  conditional and whose hypothesis is false at `.Base`
* `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean` — `forward_plus`,
  `plusDerivable_ofFormula_iff`, the row structure mirrored here
* `FormalSystem/Metalogic/StrongCompleteness.lean` — the four `WeakCompleteness` engines for TM
* `FormalSystem/OpenLanguage/OpenErasure.lean` — `eraseOpen`, the discharge table,
  `plusDerivable_of_openDerivable` and `plusDerivable_openDerivable_iff`
* `FormalSystem/OpenLanguage/OpenDerivation.lean` — `openDerivable_of_plusDerivable`, the
  backward half

## Tags

conservativity · open-language · open-future · unconditional
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-! ## Row 1: the L^▷ system over TM, unconditional -/

/-- **Forward conservativity of the L^▷ system over TM**, at any class with a weak-completeness
engine for TM: L^▷ soundness, then the two truth-transfer bridges, then the engine. No TM⁺
completeness is used, and none is available at `.Base`. -/
theorem forward_open {fc : FrameClass} (engine : WeakCompleteness fc) (φ : Formula)
    (h : OpenDerivable fc [] (ofPlus (ofFormula φ))) : ProofSystem.Derivable fc [] φ :=
  engine φ ((plusValidIn_ofFormula_iff fc φ).mp
    ((openValidIn_ofPlus_iff fc (ofFormula φ)).mp (open_soundness_validIn h)))

/-- Forward conservativity at `.Base`, via `completeness_base`. -/
theorem forward_open_base (φ : Formula)
    (h : OpenDerivable FrameClass.Base [] (ofPlus (ofFormula φ))) :
    ProofSystem.Derivable FrameClass.Base [] φ :=
  forward_open completeness_base φ h

/-- Forward conservativity at `.Dense`, via `completeness_dense`. -/
theorem forward_open_dense (φ : Formula)
    (h : OpenDerivable FrameClass.Dense [] (ofPlus (ofFormula φ))) :
    ProofSystem.Derivable FrameClass.Dense [] φ :=
  forward_open completeness_dense φ h

/-- Forward conservativity at `.ZTime`, via `completeness_ztime`. -/
theorem forward_open_ztime (φ : Formula)
    (h : OpenDerivable FrameClass.ZTime [] (ofPlus (ofFormula φ))) :
    ProofSystem.Derivable FrameClass.ZTime [] φ :=
  forward_open completeness_ztime φ h

/-- Forward conservativity at `.RTime`, via `completeness_rtime`. -/
theorem forward_open_rtime (φ : Formula)
    (h : OpenDerivable FrameClass.RTime [] (ofPlus (ofFormula φ))) :
    ProofSystem.Derivable FrameClass.RTime [] φ :=
  forward_open completeness_rtime φ h

/-- **The L^▷ system is a conservative extension of TM**, both directions, at every class with an
engine: an L formula is an L^▷ theorem at its doubly-embedded form iff it is a TM theorem.
Backward by the two embeddings of derivations composed, forward by L^▷ soundness plus TM
completeness.

This says the L^▷ system proves no new **L** theorem. It is not a completeness claim for the
L^▷ system, which proves vastly more than the image of the embedding.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and supplies no
proof system over them) -/
theorem openDerivable_ofFormula_iff {fc : FrameClass} (engine : WeakCompleteness fc)
    (φ : Formula) :
    OpenDerivable fc [] (ofPlus (ofFormula φ)) ↔ ProofSystem.Derivable fc [] φ :=
  ⟨forward_open engine φ,
    fun h => (plusDerivable_openDerivable_iff (ofFormula φ)).mpr (plusDerivable_of_derivable h)⟩

/-- Conservativity over TM at `.Base`. -/
theorem openDerivable_ofFormula_iff_base (φ : Formula) :
    OpenDerivable FrameClass.Base [] (ofPlus (ofFormula φ)) ↔
      ProofSystem.Derivable FrameClass.Base [] φ :=
  openDerivable_ofFormula_iff completeness_base φ

/-- Conservativity over TM at `.Dense`. -/
theorem openDerivable_ofFormula_iff_dense (φ : Formula) :
    OpenDerivable FrameClass.Dense [] (ofPlus (ofFormula φ)) ↔
      ProofSystem.Derivable FrameClass.Dense [] φ :=
  openDerivable_ofFormula_iff completeness_dense φ

/-- Conservativity over TM at `.ZTime`. -/
theorem openDerivable_ofFormula_iff_ztime (φ : Formula) :
    OpenDerivable FrameClass.ZTime [] (ofPlus (ofFormula φ)) ↔
      ProofSystem.Derivable FrameClass.ZTime [] φ :=
  openDerivable_ofFormula_iff completeness_ztime φ

/-- Conservativity over TM at `.RTime`. -/
theorem openDerivable_ofFormula_iff_rtime (φ : Formula) :
    OpenDerivable FrameClass.RTime [] (ofPlus (ofFormula φ)) ↔
      ProofSystem.Derivable FrameClass.RTime [] φ :=
  openDerivable_ofFormula_iff completeness_rtime φ

/-! ## Row 2: the L^▷ system over TM⁺, unconditional and syntactic -/

/-- **The L⁺ ⊂ L^▷ row, both directions, unconditional.** On the image of `ofPlus` the two
systems prove exactly the same formulas. The statement takes **no engine argument and no
completeness hypothesis**: backward is `openDerivable_of_plusDerivable`, forward is
`plusDerivable_of_openDerivable` composed with the retraction `eraseOpen_ofPlus`, and both are
constructions on derivation trees.

This is the public row of this directory; the proof is
`OpenLanguage/OpenErasure.lean`'s `plusDerivable_openDerivable_iff`, re-exported here beside the
TM rows so that both of the task's conservativity directions are readable in one place.

**Contrast with `starConservative_of_plusComplete`** deliberately: that row's hypothesis is
general TM⁺ completeness at `fc`, which is false at `.Base` by `plus_incomplete_base`. This row
has no such hypothesis because it never passes through validity.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and supplies no
proof system over them) -/
theorem openDerivable_ofPlus_iff {fc : FrameClass} (φ : PlusFormula) :
    OpenDerivable fc [] (ofPlus φ) ↔ PlusDerivable fc [] φ :=
  plusDerivable_openDerivable_iff φ

/-! ### Acceptance checks -/

/-- The TM⁺ row at `.Base`, with the engine slot visibly absent. -/
example (φ : PlusFormula) :
    OpenDerivable FrameClass.Base [] (ofPlus φ) ↔ PlusDerivable FrameClass.Base [] φ :=
  openDerivable_ofPlus_iff φ

/-- The TM⁺ row at `.RTime`, likewise. -/
example (φ : PlusFormula) :
    OpenDerivable FrameClass.RTime [] (ofPlus φ) ↔ PlusDerivable FrameClass.RTime [] φ :=
  openDerivable_ofPlus_iff φ

/-- A restricted-modal theorem is **not** in the image of either row: `▷φ → φ` is an L^▷ theorem
whose `eraseOpen` image is `φ → φ`, so the TM⁺ row carries it to a TM⁺ theorem about a different
formula. The two rows constrain the embedded fragment only, which is the point of the guard
above. -/
example (φ : OpenFormula) :
    PlusDerivable FrameClass.Base [] (eraseOpen ((OpenFormula.ofut φ).imp φ)) := by
  have h : OpenDerivable FrameClass.Base [] ((OpenFormula.ofut φ).imp φ) :=
    ⟨.axiom [] _ (OpenAxiom.ofut_t φ) le_rfl⟩
  have h' := plusDerivable_of_openDerivable h
  rwa [List.map_nil] at h'

end FormalSystem.Metalogic.Conservativity
