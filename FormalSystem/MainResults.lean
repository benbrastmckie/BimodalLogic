/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic
import FormalSystem.Semantics

/-!
# Main Results

One page listing the headline metatheory of the bimodal logic TM, with the kernel's own
axiom audit beside each result. This module proves nothing: every name below is proved in
the module named beside it, and this file restates the list so that a reader — or the
generated API documentation — has a single entry point instead of a directory tour.

## How to read this page

Each section names its results, says in one line what they claim, and then runs two kernel
commands over each of them:

* `#check` resolves the name and prints its type. A rename or a deletion anywhere in the
  tree breaks this file's build, so the list cannot silently go stale.
* `#print axioms` prints the declaration's axiom dependencies. The build log carries the
  verbatim output; the expected output is not transcribed here by hand.

## The axiom contract

Every declaration on this page reports

```
depends on axioms: [propext, Classical.choice, Quot.sound]
```

with exactly one exception, recorded here rather than rounded up:
`FormalSystem.Semantics.galoisClosed_mod` reports `[propext]` alone, because it is
`Order.isExtent_lowerPolar` applied to the model relation and needs neither choice nor
quotients. A *smaller* dependency set is not a regression.

`sorryAx` appears nowhere. That is asserted structurally, by content, in
`scripts/check-module-invariants.sh`'s C3 inventory, not by reading this page.

**Why the expected output is not written out here.** Two of this repository's modules used
to carry hand-transcribed `#print axioms` output beside their theorems, and that transcript
drifted out of step with the declarations it claimed to report. The axiom sets are instead
pinned by exact string equality against a frozen baseline in
`scripts/check-module-invariants.sh` — C2 pins four flagship declarations, C14 pins the rest,
202 in all — and every name on this page is in that pinned set. The C21 check asserts exactly
that closure property: no name may appear on this page unless one of the two baselines pins
its axiom set. So the guarantee this page offers is machine-checked in three independent
places (the `#check`, the baseline, and C21), and in none of them by prose.

## Scope

The four frame classes are `Base` (all task frames), `Dense`, `ZTime` (discrete) and `RTime`
(dense Dedekind-complete). Results are grouped by what they claim, not by which module
proves them.

## Tags

main-results · soundness · completeness · compactness · decidability · navigation
-/

/-! ## Soundness

Derivability implies truth, at each of the four frame classes. `soundness` is the `Base`
member of the family; there is no separate `soundness_base`.

* `FormalSystem.Metalogic.soundness` — `Γ ⊢ φ` and every member of `Γ` true at a
  configuration implies `φ` true there, over arbitrary task frames.
* `FormalSystem.Metalogic.soundness_dense` — the same, with `[DenselyOrdered F.Duration]`.
* `FormalSystem.Metalogic.soundness_ztime` — the same, over the discrete instance bundle.
* `FormalSystem.Metalogic.soundness_rtime` — the same, over dense frames with least upper
  bounds for bounded nonempty sets.

Proved in `FormalSystem.Metalogic.Soundness`.
-/

#check @FormalSystem.Metalogic.soundness
#check @FormalSystem.Metalogic.soundness_dense
#check @FormalSystem.Metalogic.soundness_ztime
#check @FormalSystem.Metalogic.soundness_rtime

#print axioms FormalSystem.Metalogic.soundness
#print axioms FormalSystem.Metalogic.soundness_dense
#print axioms FormalSystem.Metalogic.soundness_ztime
#print axioms FormalSystem.Metalogic.soundness_rtime

/-! ## Weak completeness

Validity over a frame class implies derivability from the empty context. All four are
unconditional: the engine parameter of the class-generic reduction is instantiated, not left
as a hypothesis.

* `FormalSystem.Metalogic.completeness_base` — `WeakCompleteness FrameClass.Base`.
* `FormalSystem.Metalogic.completeness_dense` — `WeakCompleteness FrameClass.Dense`.
* `FormalSystem.Metalogic.completeness_ztime` — `WeakCompleteness FrameClass.ZTime`.
* `FormalSystem.Metalogic.completeness_rtime` — `WeakCompleteness FrameClass.RTime`.

Proved in `FormalSystem.Metalogic.StrongCompleteness`, over the canonical-model engines of
`FormalSystem.Metalogic.BXCanonical`.
-/

#check @FormalSystem.Metalogic.completeness_base
#check @FormalSystem.Metalogic.completeness_dense
#check @FormalSystem.Metalogic.completeness_ztime
#check @FormalSystem.Metalogic.completeness_rtime

#print axioms FormalSystem.Metalogic.completeness_base
#print axioms FormalSystem.Metalogic.completeness_dense
#print axioms FormalSystem.Metalogic.completeness_ztime
#print axioms FormalSystem.Metalogic.completeness_rtime

/-! ## Consequence completeness

The list-context form: semantic consequence from a finite context implies derivability from
that context. Obtained from weak completeness through the semantic deduction theorem, so the
four members track the four weak-completeness members exactly.

* `FormalSystem.Metalogic.consequence_completeness_base`
* `FormalSystem.Metalogic.consequence_completeness_dense`
* `FormalSystem.Metalogic.consequence_completeness_ztime`
* `FormalSystem.Metalogic.consequence_completeness_rtime`

Proved in `FormalSystem.Metalogic.StrongCompleteness`.
-/

#check @FormalSystem.Metalogic.consequence_completeness_base
#check @FormalSystem.Metalogic.consequence_completeness_dense
#check @FormalSystem.Metalogic.consequence_completeness_ztime
#check @FormalSystem.Metalogic.consequence_completeness_rtime

#print axioms FormalSystem.Metalogic.consequence_completeness_base
#print axioms FormalSystem.Metalogic.consequence_completeness_dense
#print axioms FormalSystem.Metalogic.consequence_completeness_ztime
#print axioms FormalSystem.Metalogic.consequence_completeness_rtime

/-! ## Strong completeness and compactness

The set-context form, for arbitrary `Γ : Set Formula`. These hold at `Base` and `Dense`
only; the `ZTime` and `RTime` cases are refuted in the next section, and that asymmetry is
the substantive content of this pair of sections.

* `FormalSystem.Metalogic.compactBase`, `FormalSystem.Metalogic.compactDense` — every
  finitely satisfiable set is satisfiable.
* `FormalSystem.Metalogic.strongCompletenessBase`,
  `FormalSystem.Metalogic.strongCompletenessDense` — `Γ ⊨ φ → Γ ⊢ φ` for arbitrary `Γ`,
  obtained from compactness and the corresponding weak-completeness engine.

Proved in `FormalSystem.Metalogic.Compactness`.
-/

#check @FormalSystem.Metalogic.compactBase
#check @FormalSystem.Metalogic.compactDense
#check @FormalSystem.Metalogic.strongCompletenessBase
#check @FormalSystem.Metalogic.strongCompletenessDense

#print axioms FormalSystem.Metalogic.compactBase
#print axioms FormalSystem.Metalogic.compactDense
#print axioms FormalSystem.Metalogic.strongCompletenessBase
#print axioms FormalSystem.Metalogic.strongCompletenessDense

/-! ## The non-compactness refutations

Compactness and strong completeness *fail* at the two classes whose frames carry an
Archimedean or a Dedekind condition. These are refutations, not open questions: each is a
`¬` statement discharged by an explicit witness set.

* `FormalSystem.Metalogic.notCompactZTime` and
  `FormalSystem.Metalogic.notStrongCompletenessZTime` — the discrete case, refuted by the
  Archimedean witness family, in `FormalSystem.Metalogic.DiscreteNonCompactness`.
* `FormalSystem.Metalogic.notCompactRTime` and
  `FormalSystem.Metalogic.notStrongCompletenessRTime` — the Dedekind case, refuted by the
  gap witness family, in `FormalSystem.Metalogic.DedekindNonCompactness`.

Together with the section above, these four are why the completeness table has strong
completeness at two classes and weak completeness at four.
-/

#check @FormalSystem.Metalogic.notCompactZTime
#check @FormalSystem.Metalogic.notStrongCompletenessZTime
#check @FormalSystem.Metalogic.notCompactRTime
#check @FormalSystem.Metalogic.notStrongCompletenessRTime

#print axioms FormalSystem.Metalogic.notCompactZTime
#print axioms FormalSystem.Metalogic.notStrongCompletenessZTime
#print axioms FormalSystem.Metalogic.notCompactRTime
#print axioms FormalSystem.Metalogic.notStrongCompletenessRTime

/-! ## Galois closure of the correspondence

The frame-class/formula-set Galois connection, and the closure results that let a class be
recognized by a single indicator formula.

* `FormalSystem.Semantics.galoisClosed_mod` — every model class `Mod S` is Galois-closed.
  This is the one declaration on the page with a strictly smaller axiom set, `[propext]`.
* `FormalSystem.Semantics.galoisClosed_of_indicator` — a class with an indicator formula is
  Galois-closed.
* `FormalSystem.Semantics.galoisClosed_sat_dense` — the dense class is Galois-closed, by its
  density indicator.
* `FormalSystem.Semantics.galoisClosed_isDiscrete` — the discrete class is Galois-closed, by
  its next-top indicator.

Proved in `FormalSystem.Semantics.Correspondence.Galois` and
`FormalSystem.Semantics.Correspondence.Indicator`.
-/

#check @FormalSystem.Semantics.galoisClosed_mod
#check @FormalSystem.Semantics.galoisClosed_of_indicator
#check @FormalSystem.Semantics.galoisClosed_sat_dense
#check @FormalSystem.Semantics.galoisClosed_isDiscrete

#print axioms FormalSystem.Semantics.galoisClosed_mod
#print axioms FormalSystem.Semantics.galoisClosed_of_indicator
#print axioms FormalSystem.Semantics.galoisClosed_sat_dense
#print axioms FormalSystem.Semantics.galoisClosed_isDiscrete

/-! ## Expressive completeness

Kamp's theorem in the Prior-structure form: over structures satisfying the Prior conditions,
every monadic first-order formula in one free variable has a temporal equivalent.

* `FormalSystem.Metalogic.Expressiveness.Kamp.kampPriorExpressiveCompleteness` — the
  constructive core, returning the temporal formula together with its correctness proof.
* `FormalSystem.Metalogic.Expressiveness.uSExpressivelyCompleteOverPrior` — the
  `{U, S}`-expressive-completeness statement built on it.

Both are `noncomputable def`s returning a subtype, not `theorem`s: the temporal formula is
extracted, not merely asserted to exist. Proved in
`FormalSystem.Metalogic.Expressiveness.Kamp.KampPrior` and
`FormalSystem.Metalogic.Expressiveness.PriorExpressiveness`.
-/

#check @FormalSystem.Metalogic.Expressiveness.Kamp.kampPriorExpressiveCompleteness
#check @FormalSystem.Metalogic.Expressiveness.uSExpressivelyCompleteOverPrior

#print axioms FormalSystem.Metalogic.Expressiveness.Kamp.kampPriorExpressiveCompleteness
#print axioms FormalSystem.Metalogic.Expressiveness.uSExpressivelyCompleteOverPrior

/-! ## Decidability

The soundness half of the decision procedure: if the procedure returns a valid verdict, the
formula really is valid. This is the bridge that makes the tableau machinery usable as
evidence rather than as a heuristic.

* `FormalSystem.Metalogic.Decidability.sound_of_isValid` — `r.isValid = true → ⊨ φ`.

Proved in `FormalSystem.Metalogic.Decidability.Correctness`.
-/

#check @FormalSystem.Metalogic.Decidability.sound_of_isValid

#print axioms FormalSystem.Metalogic.Decidability.sound_of_isValid

/-! ## Frame-class sharpness of the `.ZTime` axioms

`Axiom.minFrameClass` tags each axiom with the smallest frame class at which it is meant to be
valid, and `axiom_validIn_min` proves only the upper half of that claim: the axiom really is valid
at its own tag. For the two axioms tagged `.ZTime` — `Axiom.prior_UZ` and `Axiom.z1` — the lower
half is proved here too, and in fact strengthened to an exhaustive characterization: their atomic
instances are valid at `.ZTime` and at no other frame class. The refutations are frame-level, on
the translation frame over a densely ordered duration group, so what is refuted is discreteness
rather than the Archimedean property.

The statements are atomic rather than schematic by necessity: `Axiom.prior_UZ ⊥` has an
unsatisfiable antecedent and so is valid everywhere, which would make the `∀ φ` form false.

* `FormalSystem.Metalogic.Independence.prior_UZ_minFrameClass_sharp` — `prior_UZ` is valid at no
  frame class strictly below `.ZTime`.
* `FormalSystem.Metalogic.Independence.z1_minFrameClass_sharp` — the `z1` counterpart.
* `FormalSystem.Metalogic.Independence.not_derivable_base_prior_UZ` — `prior_UZ`'s atomic instance
  is not derivable from the `.Base` axioms, through soundness.
* `FormalSystem.Metalogic.Independence.not_derivable_base_z1` — the `z1` counterpart.
* `FormalSystem.Metalogic.Independence.prior_UZ_validIn_iff_ztime` — `ValidIn fc φ ↔ fc = .ZTime`,
  the full characterization, covering `.Dense` and `.RTime` as well, which are incomparable with
  `.ZTime` rather than below it.
* `FormalSystem.Metalogic.Independence.z1_validIn_iff_ztime` — the `z1` counterpart.

Proved in `FormalSystem.Metalogic.Independence.ZTimeSharpness`.
-/

#check @FormalSystem.Metalogic.Independence.prior_UZ_minFrameClass_sharp
#check @FormalSystem.Metalogic.Independence.z1_minFrameClass_sharp
#check @FormalSystem.Metalogic.Independence.not_derivable_base_prior_UZ
#check @FormalSystem.Metalogic.Independence.not_derivable_base_z1
#check @FormalSystem.Metalogic.Independence.prior_UZ_validIn_iff_ztime
#check @FormalSystem.Metalogic.Independence.z1_validIn_iff_ztime

#print axioms FormalSystem.Metalogic.Independence.prior_UZ_minFrameClass_sharp
#print axioms FormalSystem.Metalogic.Independence.z1_minFrameClass_sharp
#print axioms FormalSystem.Metalogic.Independence.not_derivable_base_prior_UZ
#print axioms FormalSystem.Metalogic.Independence.not_derivable_base_z1
#print axioms FormalSystem.Metalogic.Independence.prior_UZ_validIn_iff_ztime
#print axioms FormalSystem.Metalogic.Independence.z1_validIn_iff_ztime
