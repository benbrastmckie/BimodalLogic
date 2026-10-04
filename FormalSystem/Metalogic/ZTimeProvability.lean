/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.BXCanonical.Completeness
import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly

/-!
# `Decidable (Derivable FrameClass.ZTime [] φ)`

Decidability of ℤ-time *provability*, as a corollary of decidability of ℤ-time *validity*.

Three landed results compose. `Soundness.lean`'s `soundness_ztime_valid` takes a
`DerivationTree FrameClass.ZTime [] φ` to `ValidZTime φ`. `BXCanonical/Completeness.lean`'s
`derivable_of_validZTime` runs the converse. And
`Decidability/WitnessFamily/Compression/Assembly.lean`'s `Compression.decidableValidZTime` decides
the right-hand side. Together the first two give a
biconditional, and `decidable_of_iff` transports the decision procedure across it.

## The `Nonempty` step

`Derivable fc Γ p` is *literally* `Nonempty (DerivationTree fc Γ p)` (`ProofSystem/Derivable.lean`),
so the soundness leg is not a direct application: it needs a `Nonempty` elimination first. The
target is a `Prop`, so that elimination introduces no choice — `Nonempty.elim` into a `Prop` is the
recursor, not `Classical.choice`.

## Scope — read the qualifiers

This result is stated at **frame class `FrameClass.ZTime`**, for the object language **`Formula`,
which carries no stability operator** (the box-dot `⊡` belongs to `PlusFormula`, and its
decidability is a separate and open question), and with **empty premises** (`[]`). Nothing here
says anything about `Base`, `Dense` or `RTime` provability, about non-empty premise sets, or about
L⁺.

## What this closes, and what it does not

`Decidable (Derivable fc [] φ)` at all four frame classes was to arrive with the verified tableau
spine: the row `` `Provable.lean` | Track B: `Decidable (Derivable fc [] φ)` and the completeness
corollaries | not built `` in `Decidability/Verified/README.md` is that unbuilt deliverable. This
module closes the **ℤ-time case of it without the spine**, by a route the spine has nothing to do
with. The `fc`-parameterized statement that row names is *not* supplied here, and the other three
frame classes — `Base`, `Dense`, `RTime` — remain owed by the spine's completeness direction; see
the Status section of `Decidability.lean`, which records the four-frame-class `Decidable (⊨ φ)`
instances as open, and the section "`validity_decidable` / `validity_has_decision_procedure` —
Retired as vacuous" in `Decidability/Correctness.lean` for what a decidability claim at this level
has to avoid being.

## No complexity claim

See the header of `Decidability/WitnessFamily/Compression/Assembly.lean` for the cost statement and
its literature source. Nothing in this module restates or improves on any bound, and `Decidable` is
the whole deliverable.
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics

/--
**ℤ-time provability coincides with ℤ-time validity.**

Soundness and completeness at `FrameClass.ZTime`, empty premises, packaged as one biconditional.
Forward is `soundness_ztime_valid` after a `Nonempty` elimination (`Derivable` is `Nonempty` of
the derivation-tree type); backward is `BXCanonical.derivable_of_validZTime`.

Kept as its own `theorem` rather than inlined into `decidableDerivableZTime`, so the decision
procedure's body stays a plain `decidable_of_iff` application.

Paper: — (formalization-native; the paper's decidability corollary is commented out and carries no
live label, and states nothing about the witness-family route)
-/
theorem derivable_iff_validZTime (φ : Formula) :
    Derivable FrameClass.ZTime [] φ ↔ ValidZTime φ :=
  ⟨fun h => h.elim (fun d => soundness_ztime_valid d),
   BXCanonical.derivable_of_validZTime φ⟩

/--
**Decidability of ℤ-time provability.**

`Derivable FrameClass.ZTime [] φ` is decidable: `derivable_iff_validZTime` reduces it to
`ValidZTime φ`, which `Decidability.Compression.decidableValidZTime` decides via the
witness-family certificate route.

Qualifiers, all three load-bearing: frame class **`FrameClass.ZTime`**; the object language is
**`Formula`**, which has **no stability operator**; premises are **empty** (`[]`).

This closes decidability of provability over ℤ — one of the four frame-class deliverables the
verified tableau spine was to supply — **without the spine**. The other three (`Base`, `Dense`,
`RTime`) remain owed by the spine's completeness direction; see this module's header for the three
anchors that record the gap.

A `def` and not an `instance`, matching `Compression.decidableValidZTime` and the bilasso
assembly's family procedure: a global `Decidable (Derivable FrameClass.ZTime [] φ)` instance would
change instance resolution repository-wide and could slow or loop elaboration in modules that have
nothing to do with this one. Callers that want it can `letI` it locally.

See this module's header for the complexity pointer; no bound is claimed here.

Paper: — (formalization-native; the paper's decidability corollary is commented out and carries no
live label, and states nothing about the witness-family route)
-/
def decidableDerivableZTime (φ : Formula) :
    Decidable (Derivable FrameClass.ZTime [] φ) :=
  letI := Decidability.Compression.decidableValidZTime φ
  decidable_of_iff (ValidZTime φ) (derivable_iff_validZTime φ).symm

/-!
## Axiom audit

Both declarations above measure as `[propext, Classical.choice, Quot.sound]`, which is the
repository's standard classical triple and the same value the three composed inputs carry. The
values are pinned by the C14 matched pair in `scripts/check-module-invariants.sh`, which asserts
them on every build-backed gate run; no live `#print axioms` directive is kept here.
-/

end FormalSystem.Metalogic
