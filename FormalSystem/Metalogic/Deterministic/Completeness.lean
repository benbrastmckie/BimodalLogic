/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Deterministic.Collapse
import FormalSystem.Metalogic.Deterministic.Engines
import FormalSystem.Metalogic.Deterministic.Soundness

/-!
# Deterministic completeness of TM⁺ + *Determined*, and the coincidence corollary

**TM⁺ + *Determined* is complete over the deterministic frames**, at each of the four frame
classes: if `φ` is valid on every deterministic frame of the class, it is a theorem of the
extended system. With soundness over the *Determined*-valid frames
(`Metalogic/Deterministic/Soundness.lean`) this gives the manuscript-facing corollary
`logicDeterministicEqDeterminedValid`: the logic of the deterministic frames and the logic of the
frames validating *Determined* **coincide**, and both are axiomatized by TM⁺ + *Determined*.

## The proof in one line per step

For a `PlusFormula φ` valid over the deterministic frames of `fc`:

1. `validDetIn_erasePlus_of_plusValidDetIn` — the **semantic** collapse: `erasePlus φ` is L-valid
   over the same frames (`Erasure.lean`).
2. `derivable_of_validDet*` — the narrowed **engine**: hence `erasePlus φ` is a TM theorem at
   `fc` (`Engines.lean`), because every countermodel the engine builds is deterministic.
3. `detDerivable_of_derivable_erasePlus` — the **syntactic** collapse: hence `φ` itself is an
   extended-system theorem (`Collapse.lean`).

Nothing in this chain is available for the *general* (nondeterministic) case, and step 2 is
exactly where it fails: the engines' canonical frames are deterministic, so they cannot refute a
formula that only a nondeterministic frame refutes.

## Axiomatizing without defining

*Determined* does **not** define the deterministic frames — no L⁺ formula set does
(`deterministic_not_plusDefinable`), and the drift frame `F°` validates every instance without
being deterministic (`determinedValid_not_deterministic`). What the results below say is the
weaker, true, and usable thing: the *logics* of the two classes coincide, and TM⁺ + *Determined*
axiomatizes both. Read `logicDeterministicEqDeterminedValid` as a statement about validity, never
about frames.

## Scope

**General (nondeterministic) TM⁺ completeness is not stated here, at any class, and is not
discharged with `sorry` anywhere in this tree.** It is open. The nearest results in the
literature are Reynolds (2003) on until/since completeness over the reals and Zanardo (1991) on
branching-time logics with an Ockhamist reading; neither settles the bundled all-histories
semantics this development uses.

## Main Results

- `detCompletenessBase`, `detCompletenessDense`, `detCompletenessZTime`, `detCompletenessRTime`
- `logicDeterministicEqDeterminedValid` — the coincidence, uniformly in the frame class
- `detCompletenessBetween` — the transfer to every class between the deterministic frames and
  the *Determined*-valid frames
- `detDerivable_ofFormula_iff` — **TM⁺ + *Determined* is conservative over TM**: the
  deterministic-completeness transfer back to the L level

## References

* JPL paper `app:deterministic`, `cor:no-characterization`, `cor:tm-completeness`
* `FormalSystem/Metalogic/Deterministic/Engines.lean` — the narrowed engines

## Tags

completeness · determinism · plus-language · stability-modal · app:deterministic
-/

namespace FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage
open FormalSystem.Semantics

/-! ## The four completeness rows -/

/-- **Deterministic completeness at `.Base`.**

Paper: `app:deterministic`
-/
theorem detCompletenessBase (φ : PlusFormula) (h : PlusValidDetIn FrameClass.Base φ) :
    DetDerivable FrameClass.Base [] φ :=
  detDerivable_of_derivable_erasePlus
    (derivable_of_validDetBase (erasePlus φ) (validDetIn_erasePlus_of_plusValidDetIn h))

/-- **Deterministic completeness at `.Dense`.**

Paper: `app:deterministic`
-/
theorem detCompletenessDense (φ : PlusFormula) (h : PlusValidDetIn FrameClass.Dense φ) :
    DetDerivable FrameClass.Dense [] φ :=
  detDerivable_of_derivable_erasePlus
    (derivable_of_validDetDense (erasePlus φ) (validDetIn_erasePlus_of_plusValidDetIn h))

/-- **Deterministic completeness at `.ZTime`.**

Paper: `app:deterministic`
-/
theorem detCompletenessZTime (φ : PlusFormula) (h : PlusValidDetIn FrameClass.ZTime φ) :
    DetDerivable FrameClass.ZTime [] φ :=
  detDerivable_of_derivable_erasePlus
    (derivable_of_validDetZTime (erasePlus φ) (validDetIn_erasePlus_of_plusValidDetIn h))

/-- **Deterministic completeness at `.RTime`.**

Paper: `app:deterministic`
-/
theorem detCompletenessRTime (φ : PlusFormula) (h : PlusValidDetIn FrameClass.RTime φ) :
    DetDerivable FrameClass.RTime [] φ :=
  detDerivable_of_derivable_erasePlus
    (derivable_of_validDetRTime (erasePlus φ) (validDetIn_erasePlus_of_plusValidDetIn h))

/-- The four rows as one statement, by cases on the frame-class tag: `FrameClass` has exactly the
four constructors, so no class is left out. -/
theorem detCompleteness (fc : FrameClass) (φ : PlusFormula) (h : PlusValidDetIn fc φ) :
    DetDerivable fc [] φ := by
  cases fc with
  | Base => exact detCompletenessBase φ h
  | Dense => exact detCompletenessDense φ h
  | ZTime => exact detCompletenessZTime φ h
  | RTime => exact detCompletenessRTime φ h

/-! ## The coincidence corollary -/

/--
**The logic of the deterministic frames and the logic of the *Determined*-valid frames
coincide**, at every frame class, and both are axiomatized by TM⁺ + *Determined*.

(⇐) is the class inclusion: the deterministic frames are among the *Determined*-valid ones
(`deterministic_determinedValid`), so validity over the larger class is the stronger claim.
(⇒) is the composition of completeness over the smaller class with soundness over the larger
one — which is exactly the pair of theorems this subtree proves, and exactly why soundness was
stated at the larger class in the first place.

**This is not a characterization of determinism.** The two classes are genuinely different: `F°`
is *Determined*-valid and not deterministic (`determinedValid_not_deterministic`), and no L⁺
formula set defines the deterministic frames at all (`deterministic_not_plusDefinable`). The
sentence that survives is the one stated here — the two classes have the same **logic** — and it
is the one the manuscript can use.

Paper: `app:deterministic`
-/
theorem logicDeterministicEqDeterminedValid (fc : FrameClass) (φ : PlusFormula) :
    PlusValidDetIn fc φ ↔ PlusValidDeterminedIn fc φ :=
  ⟨fun h => detSoundness (detCompleteness fc φ h), PlusValidDetIn.of_determined⟩

/--
**The transfer to intermediate classes.** Any frame predicate `P` sandwiched between the
deterministic frames of `fc` and the *Determined*-valid frames of `fc` has the same logic as
both, and TM⁺ + *Determined* is sound and complete over it.

The `Determined`-valid frames of the class are the largest such `P`, and the deterministic ones
the smallest; every class in between — including any obtained by adding further conditions no L⁺
formula can express — is covered.
-/
theorem detCompletenessBetween (fc : FrameClass) (P : TaskFrame → Prop)
    (hlo : ∀ F, DetSat fc F → P F) (hhi : ∀ F, P F → DeterminedSat fc F) (φ : PlusFormula) :
    PlusValidOnFrames P φ ↔ DetDerivable fc [] φ := by
  constructor
  · intro h
    exact detCompleteness fc φ (PlusValidOnFrames.mono hlo h)
  · intro h
    exact PlusValidOnFrames.mono hhi (detSoundness h)

/-- The logic of any such intermediate class is the logic of the deterministic frames. -/
theorem logicBetweenEqDeterministic (fc : FrameClass) (P : TaskFrame → Prop)
    (hlo : ∀ F, DetSat fc F → P F) (hhi : ∀ F, P F → DeterminedSat fc F) (φ : PlusFormula) :
    PlusValidOnFrames P φ ↔ PlusValidDetIn fc φ :=
  (detCompletenessBetween fc P hlo hhi φ).trans
    ⟨fun h => PlusValidDetIn.of_determined (detSoundness h), detCompleteness fc φ⟩

/-! ## The `⊡ = identity` special case

Every nondeterministic TM⁺ completeness result — task-external, and open — must specialize to the
theorems above when the frame is deterministic, because on such a frame `⊡` is pointwise the
identity (`Semantics/PlusLanguage/PlusDeterminism.lean`, `stab_iff_of_deterministic`) and *Determined* is
frame-valid. The row below records that specialization concretely: over the deterministic frames,
L⁺-validity of `φ` and L-validity of its erasure are the same condition. -/

/-- The `⊡ = identity` row: over the deterministic frames of any class, TM⁺ + *Determined*
derives exactly the formulas whose erasures TM derives. -/
theorem detDerivable_iff_derivable_erasePlus (fc : FrameClass) (φ : PlusFormula) :
    DetDerivable fc [] φ ↔ ProofSystem.Derivable fc [] (erasePlus φ) := by
  constructor
  · intro h
    exact derivable_of_validDet fc (erasePlus φ)
      (validDetIn_erasePlus_of_plusValidDetIn (PlusValidDetIn.of_determined (detSoundness h)))
  · intro h
    exact detDerivable_of_derivable_erasePlus h

/-! ## The transfer back to the L level -/

/--
**TM⁺ + *Determined* is a conservative extension of TM.** An L formula is a theorem of the
extended system exactly when it is a TM theorem, at every frame class.

This is the deterministic-completeness result read back at the L level, and it is a genuine
addition rather than a restatement of `plusDerivable_ofFormula_iff`: the extended system carries
a schema that TM⁺ does not, so conservativity over TM does not follow from TM⁺'s. It is
`detDerivable_iff_derivable_erasePlus` at `φ := ofFormula ψ`, where the erasure is the identity
(`erasePlus_ofFormula`).

Paper: — (formalization-native; TM⁺ + *Determined* is the ⊡-only fragment's extension, for which
the paper supplies no logic)
-/
theorem detDerivable_ofFormula_iff (fc : FrameClass) (φ : Formula) :
    DetDerivable fc [] (ofFormula φ) ↔ ProofSystem.Derivable fc [] φ := by
  have h := detDerivable_iff_derivable_erasePlus fc (ofFormula φ)
  rwa [erasePlus_ofFormula] at h

/-! ## Axiom audit

All declarations in this subtree are `sorryAx`-free and depend on no axiom beyond the ambient
three. The five termini `detCompletenessBase`, `detCompletenessDense`, `detCompletenessZTime`,
`detCompletenessRTime` and `logicDeterministicEqDeterminedValid` are pinned to exactly that set by
the C14 axiom baseline in `scripts/check-module-invariants.sh`.
-/

end FormalSystem.Metalogic.Deterministic
