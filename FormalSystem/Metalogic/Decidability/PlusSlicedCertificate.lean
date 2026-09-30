/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Basic
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Frame
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Splice
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Position
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Live
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Window
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixture
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Stable
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Timed
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixpoint
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Computed
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fold
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Unroll

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
- `PlusSlicedCertificate.Frame`: the presented frame `G.frame h` on the **infinite** carrier
  `ℤ × Fin G.n` (its infinitude proved, not asserted), the model `G.model h`, the history space
  `mem_HF_iff_slicedPath` in both directions, `pathHistory`, and the shift-normalization pair
  `plusTruthAt_shiftBack` / `timeShift_offset_zero`
- `PlusSlicedCertificate.Splice`: the **Q5 factorization** — `histories_through_paste`,
  `truth_of_agree_of_type_eq` with its `paste` instance `label_splices_of_type_eq`, and
  `forall_forall_or_iff` — assembled into `stab_factors` and its `⊡`-shaped reading
  `not_stab_factors`. This is the justification for `live = fwdLive ∩ bwdLive`
- `PlusSlicedCertificate.Position`: the finite position space over one slice with its cardinality,
  the one-step position graph `succP` / `predP` with their adjointness, and
  `mem_succP_of_path` — the replacement for the plan's (false) `succP`-totality obligation; see
  that module's header for the counterexample
- `PlusSlicedCertificate.Live`: liveness as a property of the certificate's **own runs** —
  `LabRun`, the two halves `FwdLive` / `BwdLive` and their conjunction `Live`, the two propagation
  lemmas `untl_push` / `snce_push`, the label-level splice, and **both** directions of the
  characterization (`live_of_path`, `exists_path_of_live`, `live_iff`) at an arbitrary `t : ℤ`
- `PlusSlicedCertificate.Fixture`: the window-width fixture — a bi-serial certificate of back
  period `1` in which one position is live at `-1` and occupied by no run at any time `≤ -2`,
  although the slice and the position set are literally the same at all those times
  (`live_not_determined_by_slice`). This is what rules out the single-period window and confirms
  the doubled lower endpoint, stated against the real endpoints by `Fixture.window_verdict`
- `PlusSlicedCertificate.Window`: the **combined** window — `NB` / `NF` / `NM` from the least common
  multiples of the certificate's and the target path's own segment lengths, the six compatibility
  facts, the doubled endpoints `winLo` / `winHi` with `winTimes`, and the fold `exists_win_eq` /
  `forall_iff_win` that reduces a `∀ t` claim over **both** `G.slice` and `G.target.datum` to the
  window. `Basic.lean`'s `exists_window_eq` folds the slice sequence alone and cannot state this
- `PlusSlicedCertificate.Timed`: the **rolled** timed carrier `TPos := G.Pos × ℤ` with its finite
  vertex set `verts` (`TPos` is deliberately not a `Fintype`; the `Fintype` a fixpoint needs comes
  free from `verts`, confirmed by an `example`), and the wrapping `nextTime` / `prevTime` with their
  edge, membership and **faithfulness** lemmas — the wraps preserve the slice sequence, the target
  path's data and the position space alike. The fixpoints and the bridge to `Live` are not here yet
- `PlusSlicedCertificate.Fixpoint`: the **existential** fixpoint machinery the sliced side needs, at
  an arbitrary finite graph. `Nu.gfp` is the greatest fixpoint of an arbitrary deflating monotone
  contraction, stated at an arbitrary `F` rather than an arbitrary successor function because the
  eventuality-aware liveness fixpoint is a *nested* one. `EGFix.gfp` is the instance at "has a
  successor in the set" (an infinite walk exists) and `EUFix.lfp` the existential `E[g U e]` (some
  walk delivers), each with membership proved **equivalent** to the existence of the walk it
  describes, and `EUFix.lfp_mono_V` supplying what a nested outer contraction needs of its inner
  test. `AUFix` is the universal `A[g U e]` operator and is deliberately not used here; that
  module's header records why an existential outer fixpoint cannot consume a universal inner one
- `PlusSlicedCertificate.Computed`: the four fixpoints instantiated at the timed graph —
  `fwdWalkable` / `bwdWalkable` (`EGFix.gfp` at `succT` / `predT`: an infinite walk exists) and
  `untlReach` / `snceReach` (`EUFix.lfp`: some walk delivers), each with **both** directions of its
  own graph-theoretic characterization. It does **not** claim any of the four equals `Live`; that
  equality is the bridge, and nothing here stands in for it
- `PlusSlicedCertificate.Fold`: the two folding relations `FoldF` / `FoldB` on times, with each
  wrap proved to be a fold (`foldF_nextTime` / `foldB_prevTime`) and folded times proved to carry
  the same slice, the same target datum, the same edge relation, the same position space and the
  same one-step position graph. Each relation carries the **residue** condition rather than the data
  agreement it implies, because only the residue survives a common step (`foldF_succ` /
  `foldB_pred`). This is what will let a graph walk be read as a ℤ-indexed run
- `PlusSlicedCertificate.Unroll`: a graph walk read as a ℤ-indexed half-run. `fwdWalk_foldF` /
  `bwdWalk_foldB` are the induction saying a walk's window time at step `k` is fold-equivalent to
  the genuine time, and everything else is that composed with one of `Fold`'s transports: the walk's
  positions are positions of the **genuine** slices and step along `succP` / `predP` at the
  **genuine** times, with `fwdWalkPos` / `bwdWalkPos` reading them off as functions of the time. It
  builds no `LabRun` and mentions no `Live`
- `PlusSlicedCertificate.Stable`: the one-period transfer operators `Φ_back` / `Φ_fwd`, built from
  the one-step `stepBack` / `stepFwd`, with monotonicity at each level, the two subset lemmas
  placing their images on the doubled window's endpoint slices, and the soundness direction
  `fwdLive_subset_stepBack` / `bwdLive_subset_stepFwd`. `TailStable` and its bridges are **not**
  here: they depend on the computed liveness `Finset` that sub-phase 15.3 has yet to build

## Tags

plus-language · certificate · time-sliced · completeness
-/
