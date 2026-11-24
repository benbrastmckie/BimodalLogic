/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.PlusLanguage.Derivation

/-!
# Node count of a derivation

`DerivationTree.height` and `PlusDerivationTree.height` measure the depth of a derivation. Depth
alone is a weak measure of a derivation's size: a wide tree and a spindly one can share it, and a
single `modus_ponens` whose two subderivations are of very different sizes reports the larger of
the two and forgets the smaller. The diagnostics schema asks every stage that builds a derivation
to report its **size** as well as its height, and that measure is defined here.

Both measures stay computable and are read by `#eval` on closed instances, exactly as `height`
is. Nothing in this module is used in a proof; it exists to be evaluated.

## Why this is filed here rather than beside `height`

`height` lives in `FormalSystem/ProofSystem/Derivation.lean` and the natural reading is that
`size` belongs next to it. It is filed in `BimodalLib/Diagnostics/` instead, and the reason is
that this is a *diagnostic* rather than part of the proof system's API: its only consumer is the
library pipeline's record schema, which works at the `BimodalLib` layer, and no derivation-level
result needs it. Siting it here also keeps `FormalSystem/`'s generated inventories — the tracked
line counts in `typst/generated/status.typ`, the per-file inventory rows in the directory
READMEs, and the live-lines totals in `README.md` — unmoved by a measure that proves nothing.

The cost of the choice is conceptual: a measure of a core type is declared outside the core. It
is accepted because the measure is observational, and the alternative buys nothing a diagnostic
needs.

## Consequence for the record schema

A `size` or a `height` can only be evaluated on a **closed** derivation — one with no free schema
variables and no hypothesis in its context. A proof-mode script whose statement is schematic (the
usual case for an acceptance fixture, which abstracts over `A B C : Formula`) has no closed
instance to evaluate, so `derivation_size` and `derivation_height` are nullable in a record whose
mirror is schematic rather than closed. That is a property of the measure, not a gap in the
emitter.
-/

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalLib.Diagnostics

/-! ### TM -/

/--
Computable node count of a derivation: the number of rule applications in the tree, counting
every constructor once.

- Base cases (`axiom`, `assumption`): 1
- Unary rules (`necessitation`, `temporal_necessitation`, `time_reflection`, `weakening`):
  `1 + size` of the subderivation
- Binary rule (`modus_ponens`): `1 + size d1 + size d2`, i.e. the **sum** of both
  subderivations, which is exactly where this measure separates from `height`'s `max`

Mirrors the shape of `DerivationTree.height`, with `max` replaced by `+` at the binary rule.
-/
def derivationSize {fc : FrameClass} {Γ : Context} {φ : Formula} :
    DerivationTree fc Γ φ → Nat
  | .axiom _ _ _ _ => 1
  | .assumption _ _ _ => 1
  | .modus_ponens _ _ _ d1 d2 => 1 + derivationSize d1 + derivationSize d2
  | .necessitation _ d => 1 + derivationSize d
  | .temporal_necessitation _ d => 1 + derivationSize d
  | .time_reflection _ d => 1 + derivationSize d
  | .weakening _ _ _ d _ => 1 + derivationSize d

/-! ### TM⁺ -/

/--
Computable node count of a `PlusDerivationTree`, the TM⁺ mirror of `derivationSize`. The two
inductive families have the same constructor shape, so the two measures agree constructor for
constructor.
-/
def plusDerivationSize {fc : FrameClass} {Γ : FormalSystem.PlusLanguage.PlusContext}
    {φ : FormalSystem.PlusLanguage.PlusFormula} :
    FormalSystem.PlusLanguage.PlusDerivationTree fc Γ φ → Nat
  | .axiom _ _ _ _ => 1
  | .assumption _ _ _ => 1
  | .modus_ponens _ _ _ d1 d2 => 1 + plusDerivationSize d1 + plusDerivationSize d2
  | .necessitation _ d => 1 + plusDerivationSize d
  | .temporal_necessitation _ d => 1 + plusDerivationSize d
  | .time_reflection _ d => 1 + plusDerivationSize d
  | .weakening _ _ _ d _ => 1 + plusDerivationSize d

/-! ### The relation to `height`

The two measures are ordered: a derivation has at least as many nodes as it has levels, with
equality exactly on a tree that branches nowhere. The emitters report both, so a record can be
read for shape (`size` well above `height` means a wide tree) and not only for scale.
-/

/-- A derivation's node count is never below its height. -/
theorem height_le_derivationSize {fc : FrameClass} {Γ : Context} {φ : Formula}
    (d : DerivationTree fc Γ φ) : d.height ≤ derivationSize d := by
  induction d with
  | «axiom» _ _ _ _ => simp [DerivationTree.height, derivationSize]
  | assumption _ _ _ => simp [DerivationTree.height, derivationSize]
  | modus_ponens _ _ _ _ _ ih1 ih2 =>
      simp only [DerivationTree.height, derivationSize]
      omega
  | necessitation _ _ ih => simp only [DerivationTree.height, derivationSize]; omega
  | temporal_necessitation _ _ ih => simp only [DerivationTree.height, derivationSize]; omega
  | time_reflection _ _ ih => simp only [DerivationTree.height, derivationSize]; omega
  | weakening _ _ _ _ _ ih => simp only [DerivationTree.height, derivationSize]; omega

/-- The TM⁺ mirror of `height_le_derivationSize`. -/
theorem height_le_plusDerivationSize {fc : FrameClass}
    {Γ : FormalSystem.PlusLanguage.PlusContext} {φ : FormalSystem.PlusLanguage.PlusFormula}
    (d : FormalSystem.PlusLanguage.PlusDerivationTree fc Γ φ) :
    d.height ≤ plusDerivationSize d := by
  induction d with
  | «axiom» _ _ _ _ =>
      simp [FormalSystem.PlusLanguage.PlusDerivationTree.height, plusDerivationSize]
  | assumption _ _ _ =>
      simp [FormalSystem.PlusLanguage.PlusDerivationTree.height, plusDerivationSize]
  | modus_ponens _ _ _ _ _ ih1 ih2 =>
      simp only [FormalSystem.PlusLanguage.PlusDerivationTree.height, plusDerivationSize]
      omega
  | necessitation _ _ ih =>
      simp only [FormalSystem.PlusLanguage.PlusDerivationTree.height, plusDerivationSize]; omega
  | temporal_necessitation _ _ ih =>
      simp only [FormalSystem.PlusLanguage.PlusDerivationTree.height, plusDerivationSize]; omega
  | time_reflection _ _ ih =>
      simp only [FormalSystem.PlusLanguage.PlusDerivationTree.height, plusDerivationSize]; omega
  | weakening _ _ _ _ _ ih =>
      simp only [FormalSystem.PlusLanguage.PlusDerivationTree.height, plusDerivationSize]; omega

end BimodalLib.Diagnostics
