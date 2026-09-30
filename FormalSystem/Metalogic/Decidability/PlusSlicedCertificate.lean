/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Basic
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Frame

/-!
# `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate` — the time-sliced L⁺ certificate

The certificate the L⁺ semantics actually has: a **time-sliced** bi-serial labelled graph presenting
a frame on the infinite carrier `ℤ × Fin n` with finite fibres.

## Why this subtree exists beside `PlusWitnessFamily/`

`PlusWitnessFamily/` is sound and stays. What it is not is **complete**:
`PlusWitnessFamily/Limits/NoCertificate.lean`'s `not_exists_plusCertifies_pumpTarget` exhibits a
ℤ-time non-validity that no family of that class certifies, under no hypothesis at all, and
`Limits/HopFree.lean` retires the hop-free producer separately. Neither failure is a missing bound;
both are structural, and the two that matter here are:

* **all-threads fulfilment.** (C2') is a demand about *every* thread of a finite, eventually
  periodic presentation, so every cycle reachable in the periodic region is a thread, and a target
  whose countermodels must contain a cycle with an exit under a pending eventuality is out of reach.
  This subtree replaces the demand with **fulfilment of live positions only**, computed as a
  fixpoint rather than demanded as a field, so a path that postpones an eventuality forever is
  simply a different, truthful, labelled path.
* **the finite carrier.** A certificate presenting a finite-carrier frame cannot certify `θ.neg`, a
  `⊡`-free ℤ-time non-validity the landed `Formula`-side family already certifies
  (`Probe706.no_ofStep_sat`). The carrier here is `ℤ × Fin n`: infinite, with finite fibres.

Absolute-time alignment also disappears, because a slice's own time is the only time there is:
there are no rows pinned to an absolute origin, so there is no period to align and no offset to
compute. `PlusWitnessFamily/Compression/Extract.lean`'s alignment half is retained and unused for
exactly that reason; see its header.

## Soundness is not at issue in either direction

`PlusSharingWitnessFamily.plusTruth_iff_mem` and `...plusRefutes_of_certifies` are untouched by this
subtree, and this subtree's own soundness direction targets the same unchanged export,
`PlusWitnessFamily.PlusRefutes Γ Del`. What is new is the completeness side.

## Submodules

- `PlusSlicedCertificate.Basic`: `PlusGraphPath`, `PlusSlice`, `PlusSlicedCertificate`, the
  three-segment readout with its decoding-region and periodicity lemmas, `exists_window_eq`,
  bi-seriality in both the `∀ t` and the window-decided form with `biSerial_iff_window` bridging
  them, and `onePointCertificate` — the finite-graph special case, exhibited rather than asserted

## Tags

plus-language · certificate · time-sliced · completeness
-/
