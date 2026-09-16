/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Star.StarSoundness
import FormalSystem.Metalogic.Conservativity.Plus.Forward

/-!
# Conservativity of TM⋆ — unconditional over TM, conditional over TM⁺

Two rows, at two different strengths, and the difference between them is not a gap in this
development but a **fact about which system has completeness engines**.

## Row 1 (unconditional): TM⋆ is a conservative extension of TM

For every L formula `φ` and every `fc ∈ {Base, Dense, ZTime, RTime}`:

```
TM⋆ ⊢⋆[fc] ofPlus (ofFormula φ)   ↔   TM ⊢[fc] φ          (starDerivable_ofFormula_iff)
```

Forward is TM⋆ soundness, then the truth-transfer bridge `starValidOnFrames_ofPlus`, then
`plusValidIn_ofFormula_iff`, then the TM completeness engine at `fc`:

```
TM⋆ ⊢⋆ ofPlus (ofFormula φ)  ⟹[star_soundness_validIn]     StarValidIn fc (ofPlus (ofFormula φ))
                             ⟹[starValidOnFrames_ofPlus]   PlusValidIn fc (ofFormula φ)
                             ⟹[plusValidIn_ofFormula_iff]  ValidIn fc φ
                             ⟹[WeakCompleteness fc]        TM ⊢ φ
```

Backward is `starDerivable_of_derivable` (`StarLanguage/Embedding.lean`). **No TM⁺ or TM⋆
completeness is used anywhere in this row.** Adding the time registers therefore proves no new
theorem of the base language, at any of the four classes.

## Row 2 (conditional, with an unconditional contrapositive): TM⋆ over TM⁺

The same composition one level up needs **TM⁺ completeness**, which is open at every class
(`Conservativity/Plus/README.md`). So the L⁺ ⊂ L⋆ row is stated as a proved conditional pair
rather than asserted or denied:

- `starConservative_of_plusComplete` — *if* TM⁺ is complete at `fc`, then TM⋆ proves no new L⁺
  theorem at `fc`;
- `plusIncomplete_of_starNonconservative` — its contrapositive, unconditional: **any separating
  witness for non-conservativity is, verbatim, a witness of TM⁺ incompleteness.**

The pair places the question *inside* the tree's own recorded open problem. That is a result, not
a shortfall: it says the L⁺-conservativity question cannot be settled either way without settling
TM⁺ completeness, so no amount of further work on TM⋆ alone will decide it.

## Why there is no syntactic route

Both syntactic translations one would reach for are closed by machine-checked refutations:

- **Naive register erasure** (delete every `↑ⁱ` and `↓ⁱ`) sends the `StarValid` formula
  `↑¹G↓¹p → p` (`storeG_recall_valid`) to `Gp → p`, which is refuted over `NF`
  (`refute_erasure`) — both in `Semantics/StarLanguage/StarNonValidities.lean`.
- **Register collapse** (identify every register with the time of evaluation) sends the rigidity
  schema `↓ⁱφ → G↓ⁱφ` to `φ → Gφ`, which is not a TM⁺ theorem — it is not even valid.

So conservativity over TM⁺ is a semantic question about the two logics, which is exactly why it
lands where it does.

## Main Results

- `forward_star`, and the four instantiated rows — the unconditional forward direction over TM
- `starDerivable_ofFormula_iff` and its four rows — **the headline, the L ⊂ L⋆ row**
- `starConservative_of_plusComplete` — the conditional L⁺ ⊂ L⋆ row
- `plusIncomplete_of_starNonconservative` — its unconditional contrapositive

## References

* `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean` — `forward_plus`,
  `plusDerivable_ofFormula_iff`, the row structure mirrored here
* `FormalSystem/Metalogic/StrongCompleteness.lean` — the four `WeakCompleteness` engines
* `FormalSystem/StarLanguage/Embedding.lean` — `starDerivable_of_derivable`, the backward half

## Tags

conservativity · star-language · store-recall · conditional-result
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.StarLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-! ## Row 1: TM⋆ over TM, unconditional -/

/-- **Forward conservativity of TM⋆ over TM**, at any class with a weak-completeness engine:
TM⋆ soundness, then the two truth-transfer bridges, then the engine. No TM⁺ completeness is
used. -/
theorem forward_star {fc : FrameClass} (engine : WeakCompleteness fc) (φ : Formula)
    (h : StarDerivable fc [] (ofPlus (ofFormula φ))) : ProofSystem.Derivable fc [] φ :=
  engine φ ((plusValidIn_ofFormula_iff fc φ).mp
    ((starValidOnFrames_ofPlus fc.Sat (ofFormula φ)).mp (star_soundness_validIn h)))

/-- Forward conservativity at `.Base`, via `completeness_base`. -/
theorem forward_star_base (φ : Formula)
    (h : StarDerivable FrameClass.Base [] (ofPlus (ofFormula φ))) :
    ProofSystem.Derivable FrameClass.Base [] φ :=
  forward_star completeness_base φ h

/-- Forward conservativity at `.Dense`, via `completeness_dense`. -/
theorem forward_star_dense (φ : Formula)
    (h : StarDerivable FrameClass.Dense [] (ofPlus (ofFormula φ))) :
    ProofSystem.Derivable FrameClass.Dense [] φ :=
  forward_star completeness_dense φ h

/-- Forward conservativity at `.ZTime`, via `completeness_ztime`. -/
theorem forward_star_ztime (φ : Formula)
    (h : StarDerivable FrameClass.ZTime [] (ofPlus (ofFormula φ))) :
    ProofSystem.Derivable FrameClass.ZTime [] φ :=
  forward_star completeness_ztime φ h

/-- Forward conservativity at `.RTime`, via `completeness_rtime`. -/
theorem forward_star_rtime (φ : Formula)
    (h : StarDerivable FrameClass.RTime [] (ofPlus (ofFormula φ))) :
    ProofSystem.Derivable FrameClass.RTime [] φ :=
  forward_star completeness_rtime φ h

/-- **TM⋆ is a conservative extension of TM**, both directions, at every class with an engine:
an L formula is a TM⋆ theorem at its doubly-embedded form iff it is a TM theorem. Backward by the
embedding of derivations, forward by soundness plus TM completeness.

Paper: — (formalization-native; the manuscript supplies no proof system for `\BL^\star`)
-/
theorem starDerivable_ofFormula_iff {fc : FrameClass} (engine : WeakCompleteness fc)
    (φ : Formula) :
    StarDerivable fc [] (ofPlus (ofFormula φ)) ↔ ProofSystem.Derivable fc [] φ :=
  ⟨forward_star engine φ, fun h => starDerivable_of_derivable h⟩

/-- Conservativity over TM at `.Base`. -/
theorem starDerivable_ofFormula_iff_base (φ : Formula) :
    StarDerivable FrameClass.Base [] (ofPlus (ofFormula φ)) ↔
      ProofSystem.Derivable FrameClass.Base [] φ :=
  starDerivable_ofFormula_iff completeness_base φ

/-- Conservativity over TM at `.Dense`. -/
theorem starDerivable_ofFormula_iff_dense (φ : Formula) :
    StarDerivable FrameClass.Dense [] (ofPlus (ofFormula φ)) ↔
      ProofSystem.Derivable FrameClass.Dense [] φ :=
  starDerivable_ofFormula_iff completeness_dense φ

/-- Conservativity over TM at `.ZTime`. -/
theorem starDerivable_ofFormula_iff_ztime (φ : Formula) :
    StarDerivable FrameClass.ZTime [] (ofPlus (ofFormula φ)) ↔
      ProofSystem.Derivable FrameClass.ZTime [] φ :=
  starDerivable_ofFormula_iff completeness_ztime φ

/-- Conservativity over TM at `.RTime`. -/
theorem starDerivable_ofFormula_iff_rtime (φ : Formula) :
    StarDerivable FrameClass.RTime [] (ofPlus (ofFormula φ)) ↔
      ProofSystem.Derivable FrameClass.RTime [] φ :=
  starDerivable_ofFormula_iff completeness_rtime φ

/-! ## Row 2: TM⋆ over TM⁺, conditional -/

/-- **The conditional L⁺ ⊂ L⋆ row.** If TM⁺ is complete at `fc`, then TM⋆ proves no new L⁺
theorem at `fc`: TM⋆ soundness sends the derivation to `StarValidIn fc (ofPlus φ)`,
`starValidOnFrames_ofPlus` reads that as `PlusValidIn fc φ`, and completeness returns a TM⁺
derivation.

The hypothesis is exactly general TM⁺ completeness at `fc`, which is open at every class.

Paper: — (formalization-native; the manuscript supplies no proof system for `\BL^\star`)
-/
theorem starConservative_of_plusComplete {fc : FrameClass}
    (hcomplete : ∀ ψ : PlusFormula, PlusValidIn fc ψ → PlusDerivable fc [] ψ) (φ : PlusFormula)
    (h : StarDerivable fc [] (ofPlus φ)) : PlusDerivable fc [] φ :=
  hcomplete φ ((starValidOnFrames_ofPlus fc.Sat φ).mp (star_soundness_validIn h))

/-- **The unconditional contrapositive.** Any separating witness for non-conservativity of TM⋆
over TM⁺ — an L⁺ formula whose embedding is a TM⋆ theorem while the formula itself is not a TM⁺
theorem — is, verbatim, a witness that TM⁺ is incomplete at that class.

This is why the L⁺ row above is stated as a conditional pair rather than asserted or denied: the
conservativity question is *equivalent modulo TM⋆ soundness* to the tree's own recorded open
problem, so it cannot be settled without settling that one.

Paper: — (formalization-native; the manuscript supplies no proof system for `\BL^\star`)
-/
theorem plusIncomplete_of_starNonconservative {fc : FrameClass} (φ : PlusFormula)
    (hd : StarDerivable fc [] (ofPlus φ)) (hnd : ¬ PlusDerivable fc [] φ) :
    ¬ (∀ ψ : PlusFormula, PlusValidIn fc ψ → PlusDerivable fc [] ψ) :=
  fun hcomplete => hnd (starConservative_of_plusComplete hcomplete φ hd)

/-! ## The axiom set widened, and the rows did not move

TM⋆'s schemata used to reach the TM⁺ block only at `ofPlus` instances, through a single
embedding constructor. They are now declared directly over `StarFormula`
(`StarLanguage/Axioms.lean`), so TM⋆ proves strictly more at register-carrying formulas than it
did — for instance `□↑¹p → □G↑¹p` and `⊡ψ` from `ψ` at arbitrary `ψ`
(`StarLanguage/Derivation.lean` pins both).

**Neither row above moves, and that is a fact about the proofs, not an accident.** Both rows are
established *semantically*: every direction runs through TM⋆ soundness and the truth-transfer
bridge `starValidOnFrames_ofPlus`, and neither ever pattern-matches `StarAxiom`. Soundness is
maintained because every new schema is proved valid at its own minimum frame class
(`starAxiom_validIn_min`), so widening a *sound* axiom set cannot disturb a forward direction.
The backward direction consumes `StarDerivationTree.ofPlusTree`, which now routes through
`StarAxiom.ofPlusAxiom` under the frame-class guarantee `StarAxiom.minFrameClass_ofPlusAxiom`.

Conservativity is a statement about **embedded** formulas, and the widening is entirely outside
that image: `↑¹p` is not an `ofPlus` image (`ofPlus_ne_timeStore`). So TM⋆ became strictly
stronger at register-carrying formulas while proving no new theorem of L or of L⁺. -/

/-! ### Acceptance check -/

example (φ : Formula) :
    StarDerivable FrameClass.Base [] (ofPlus (ofFormula φ)) ↔
      ProofSystem.Derivable FrameClass.Base [] φ :=
  starDerivable_ofFormula_iff completeness_base φ

/-- The conditional L⁺ row, re-checked against the widened axiom set: the hypothesis is still
general TM⁺ completeness, and nothing about the new schemata enters the statement. -/
example {fc : FrameClass}
    (hcomplete : ∀ ψ : PlusFormula, PlusValidIn fc ψ → PlusDerivable fc [] ψ) (φ : PlusFormula)
    (h : StarDerivable fc [] (ofPlus φ)) : PlusDerivable fc [] φ :=
  starConservative_of_plusComplete hcomplete φ h

end FormalSystem.Metalogic.Conservativity
