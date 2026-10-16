/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Completeness
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.SoundnessLemmas.FrameClassVariants

/-!
# Z1 Recovered Through the ZTime Completeness Engine

Z1, which the paper no longer lists as an axiom of TM_z but marks a derived theorem of it inside
`def:BX-z`, is a *theorem* of the primitive system, obtained here through the ZTime completeness
engine rather than by a hand derivation:

* `z1Derivable` / `z1Thm` — Z1, `G(Gφ → φ) → (FGφ → Gφ)`, at `FrameClass.ZTime`, from
  `BXCanonical.derivable_of_validZTime` applied to the soundness lemma
  `SoundnessLemmas.z1_valid`. `z1Thm` packages the `Derivable` proof as a term
  (`Classical.choice`) for consumers that need a `DerivationTree`.

## Non-circularity

The route is sound only if the engines do not themselves appeal to the schema being recovered.
That was measured at planning time and is confirmed mechanically by the full build of the
reduced tree (the demoted constructors no longer exist, so any hidden use would fail to
elaborate):

* the ZTime engine (`derivable_of_validZTime`, `BXCanonical/Completeness.lean`) reaches the
  `Axiom` inductive only through `Axiom.prior_UZ`.

The engine is sorryAx-free with axioms exactly `propext`, `Classical.choice`, `Quot.sound`,
which is therefore the axiom profile of every declaration below.
-/

namespace FormalSystem.Metalogic.CompletenessDerived

open FormalSystem.Syntax
open FormalSystem.ProofSystem

/-- Z1 (`G(Gφ → φ) → (FGφ → Gφ)`) is derivable at `FrameClass.ZTime`: it is valid on every
Z-time frame (`SoundnessLemmas.z1_valid`), and the ZTime engine is complete.

Paper: `def:BX-z`
-/
theorem z1Derivable (φ : Formula) :
    Derivable FrameClass.ZTime []
      ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) :=
  BXCanonical.derivable_of_validZTime _ (SoundnessLemmas.z1_valid φ)

/-- Z1 as a term, for consumers that need a `DerivationTree` rather than a `Derivable` proof.
Noncomputable: it chooses a tree from `z1Derivable` with `Classical.choice`.

Paper: `def:BX-z`
-/
noncomputable def z1Thm (φ : Formula) :
    ⊢[FrameClass.ZTime]
      ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) :=
  Classical.choice (z1Derivable φ)

end FormalSystem.Metalogic.CompletenessDerived
