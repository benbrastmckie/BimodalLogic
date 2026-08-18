/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Basic
import FormalSystem.Metalogic.Decidability.BiLasso.Unfold
import FormalSystem.Metalogic.Decidability.BiLasso.Periodic
import FormalSystem.Metalogic.Decidability.BiLasso.Annotation
import FormalSystem.Metalogic.Decidability.BiLasso.TruthLemma
import FormalSystem.Metalogic.Decidability.BiLasso.Decide
import FormalSystem.Metalogic.Decidability.BiLasso.Enumerate
import FormalSystem.Metalogic.Decidability.BiLasso.Examples
import FormalSystem.Metalogic.Decidability.BiLasso.SmallModel
import FormalSystem.Metalogic.Decidability.BiLasso.Realized
import FormalSystem.Metalogic.Decidability.BiLasso.GoodCycle
import FormalSystem.Metalogic.Decidability.BiLasso.Extraction
import FormalSystem.Metalogic.Decidability.BiLasso.BoxOracle
import FormalSystem.Metalogic.Decidability.BiLasso.Check

/-!
# FormalSystem.Metalogic.Decidability.BiLasso — the Bi-Lasso Decision Layer

Satisfiability of a formula at a state of a *presented* ℤ-frame, decided by bounded enumeration
of annotated bi-lassos. The entry point is `check` (`Check.lean`); everything else builds up to
it.

## What this layer decides, and what it does not

`check P w φ` answers a question about **one** finite presentation `P`: is there a total world
history of `P`'s frame that passes through state `w` and satisfies `φ` at some time? It does not
decide the logic — nothing here quantifies over frames — and it makes no efficiency claim. The
enumeration bound is a closed arithmetic expression, and it is astronomically large.

## Submodules

- `Basic`: the `BiLasso` datatype — a `back` cycle, a `mid` window and a `fwd` cycle — its
  `unroll` to a bi-infinite path over `ℤ`, and `coherent`. The origin is *pinned*: `back` repeats
  strictly left of `0`, `mid` occupies `[0, |mid|)`, `fwd` repeats at or past `|mid|`
- `Unfold`: the exact ℤ one-step unfolding of `TruthAt` for the temporal connectives
- `Periodic`: generic periodic decoding, independent of the bi-lasso shape
- `Annotation`: `Annot`, a bi-lasso labelled with a subformula set at each position, together
  with `LocalCoherent`, `Fulfilling` and `BoxOracleSound` — the three conditions a labelling must
  meet to decode to a genuine history
- `TruthLemma`: `truth_along_annot` and `truth_along_annot_at` — a coherent, fulfilling
  annotation's label at a position is exactly truth in the decoded history at that time
- `Decide`: decidability of `LocalCoherent` and `Fulfilling`, via the coherence window
  `[cohWindowLo, cohWindowHi)` that collapses the two ℤ-indexed conditions to finite checks
- `Enumerate`: `boundedBiLassos` and `boundedAnnots`, the bounded enumerations, with
  `boundedAnnots_sound` and `mem_boundedAnnots` for the two directions of membership
- `Examples`: the non-vacuity witnesses — a positive and a negative annotation on the one-state
  loop, hand-proved and `#guard`-evaluated, plus the enumeration counts
- `SmallModel`: the type sequence of a genuine history, the groundwork the extraction stands on
- `Realized`: the realised-datum graph — `PigeonState` with its exact cardinality,
  `RealizedStep`, `CoherentEdge` — and `localCoherentSeq_of_edges`, the splice lemma
- `GoodCycle`: the eventuality-propagation lemmas, `exists_recurring_datum`, and bounded good
  forward and backward cycles with the explicit closed bound `cycleBound`
- `Extraction`: `bound`, and `exists_annot_of_truth` — the small-model theorem in its windowed
  shape: a satisfying history yields an enumerated annotation carrying `φ` at some window position
- `BoxOracle`: `boxOracle`, a concrete `Formula → Bool` defined by strong recursion on
  `modalDepth`, with `boxOracle_sound`. This is what breaks the annotation ↔ oracle circularity
- `Check`: `SatAtState` (the specification), `checkAt`, `check`, `check_correct`, the `Decidable`
  instance, and the discrimination theorems

## Not re-exported here

`Extend`, `Successor`, `Orbit` and `Agreement` sit in the same directory but belong to the
effective-periodic-extension work, not to this decision layer. They are deliberately absent from
this aggregator, and their build wiring is that work's to own.

## This aggregator is not itself imported

Nothing in the Lake build graph imports this module, so `lake build` does not compile it or the
layer beneath it. That is deliberate while the effective-periodic-extension work is in flight
above the same directory: registering this module in `Decidability.lean` would mean two
concurrent lines of work editing one aggregator. The layer is compile-checked in the meantime by
the C6 rot guard in `scripts/check-module-invariants.sh`, which builds each manifested
unreachable module in isolation; this module is listed there alongside its submodules. Wiring the
layer in means adding one import to `Decidability.lean` and deleting the corresponding manifest
lines — C6 fails if a manifest entry names a module that has become reachable, so the two edits
must happen together.
-/
