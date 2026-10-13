/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Seam
import FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti
import FormalSystem.Metalogic.Decidability.RaySummary.Closure
import FormalSystem.Metalogic.Decidability.RaySummary.Trace
import FormalSystem.Metalogic.Decidability.RaySummary.Compose
import FormalSystem.Metalogic.Decidability.RaySummary.Transport
import FormalSystem.Metalogic.Decidability.RaySummary.Profile
import FormalSystem.Metalogic.Decidability.RaySummary.Periodic
import FormalSystem.Metalogic.Decidability.RaySummary.HitComplete
import FormalSystem.Metalogic.Decidability.RaySummary.Present
import FormalSystem.Metalogic.Decidability.RaySummary.HitOf
import FormalSystem.Metalogic.Decidability.RaySummary.StabCheck
import FormalSystem.Metalogic.Decidability.RaySummary.Realize
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

/-!
# `RaySummary` — the seam interface for `⊡` over the time axis

Aggregator for the decidability side's interface to the `k`-type summary substrate
(`FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`). It holds the seam interface and the
realizability device beside it. `Seam.lean` states the `⊡` bridge `plusStab_iff_seamSummary`
against the single-family hypothesis bundle `Presents`, and `SeamMulti.lean` characterizes that
bundle (it is inhabited iff the seam is `⊡`-decided, `exists_presents_iff`) and states the
hypothesis-free bridge `plusStab_iff_forall_hit` over the realized family triples `Hit` of a
two-letter trace. The five modules after them are the device that reads such triples off a
finite presentation: the closure alphabet and the trace of a history as its unique anchored
local run (`Closure`, `Trace`), composition on representatives (`Compose`), finite labelled
presentations with a computable path-type closure (`Present`), and the computable realized-triple
set `hitOf` with its characterization (`HitOf`). The per-model bridge `hit_eq_hitOf_of_presented`
(`Trace`) says a seam's `HitCl` IS `hitOf` under the explicit realization hypothesis
`Presented`. That hypothesis now has a NON-VACUOUS instance, and `Realize.lean` is where it is
built: `Presented` is discharged for a model constructed FROM a presentation
(`presented_modelOf`), at ONE seam, for `box`/`stab`-free `φ`, under the eleven-field
consistency bundle `Cons` — and the Hit-level equality follows in one line
(`hitCl_modelOf_eq_hitOf`). It is discharged for no model NOT so constructed, and the
`box`/`stab`-bearing fragment is assigned to the README's requirement (W), whose status is now
precise: the ANCHOR LAYER of (W) is landed (`AnchorLayer.lean` — closure types `tpOf`, cells
`cellAt`, the `box`/`stab` fixpoint equations, the finite object `AnchorCons` with
`anchorCons_anchorCells` for EVERY model and the bound `anchorCells_ncard_le`; the requirement's
"for every time" quantifier is dropped by the theorem `box_time_invariant`), and the RUN LAYER —
the `untl`/`snce` nesting, the lift from one seam to validity — is BLOCKED on three named
obligations recorded in the README's "(W): what landed and what did not", with the shape of
(S)'s construction refuted as its soundness half by the wired probe
`w-soundness-shape-refuted.lean`. Nothing in this cluster states `PlusValidZTime` in any form.
So `hitOf` is computable on presentations, `Hit` is never computed for a model outright, and
nothing here is a decision procedure: no decidability result is proved, no complexity bound is
claimed, everything is under `[F.IsRegular]` over the `ℤ` time axis where the seam's fibre is
used (the anchor layer needs no regularity), and the cited fixtures are forward-only (no
backward Bool-fixture bridge exists).
A conditional per-seam `⊡` decider exists under `Presented` (`StabCheck`: `stabCheckSig`,
`stabCheck_iff_of_presented`, `decidableStabOfPresented`), and `Presented` is refuted as a
completeness carrier by the wired probe `presented-not-complete.lean`
(`specs/evidence/seam-gluing-ray-product/`), so that decider is vacuous on model A and decides
nothing about `PlusValidZTime` — see the README's verdict.

## Modules

* `RaySummary.Seam` — `SeamSummary`, `Presents`, `plusStab_iff_seamSummary`.
* `RaySummary.SeamMulti` — `SeamDecided`, `exists_presents_iff`, the two-letter interface
  (`seamTrace`, `stabTarget`, `Hit`), the hypothesis-free bridge `plusStab_iff_forall_hit`, and
  `PresentsMulti` with its inhabitant `presentsMulti_seamTrace`.
* `RaySummary.Closure` — the closure alphabet `clSig`, the local run conditions `LocalRun`,
  the anchors `Anchored`, and the signature-generic bridge `plusStab_iff_forall_hitSig`.
* `RaySummary.Trace` — the trace `clTrace` of a history over the closure alphabet, its
  soundness (`clTrace_localRun`, `clTrace_anchored`) and uniqueness
  (`eq_clTrace_of_localRun_anchored`, `clTrace_unique`); the realized set over the closure
  alphabet (`HitCl`, `plusStab_iff_forall_hitCl`, `hitCl_eq_iUnion`); and the realization
  hypothesis `Presented` with the per-model bridge under it (`presented_localRun`,
  `hit_eq_hitOf_of_presented`, `plusStab_iff_forall_hitOf_of_presented`).
* `RaySummary.Compose` — label-list segments (`listSeg`, `labels`,
  `kTypeOf_segZ_eq_listSeg`) and composition on representatives
  (`kTypeOf_listSeg_append_congr`).
* `RaySummary.Transport` — transport of a family triple along the deletion of a constant run:
  the keystone `segZ_const_of_kTypeOf_eq_replicate` (a segment with the `k`-type of a nonempty
  constant block is a nonempty constant block, `k ≥ 1`), the deletion colouring `deleteRun`, and
  the cut surgery `inFamily_of_shrink_run` with its `familyTriples` form
  `familyTriples_subset_deleteRun` — shrink direction only, under an explicit single-segment
  containment hypothesis; no `↔`, no re-cutting, and `m₀ + p ≤ Nat.card (KType sig k)` is a
  count of depth-`k` types and nothing else.
* `RaySummary.Profile` — the σ-star profile of a finite word (`starProfile`, `profile`,
  `cutProfile`, the finite type `Profile`): the summary that composes under concatenation where
  bare `k`-types do not under star (the cut-pair obstruction), with the star languages
  `StarZero`/`StarPlus`/`PrefixStar` read off it (`starPlus_iff_profile`,
  `prefixStar_iff_profile`) at `k ≥ 1`; `Nat.card (Profile sig k)` is a count of profiles and
  nothing else.
* `RaySummary.Periodic` — periodic transport: the bi-ultimately-periodic colouring
  `periodicColouring` (`w^(ω*) · m · v^ω`, letter read-outs `labels_periodicColouring_*`), its
  one-sided forms `fwdPeriodic`/`bwdPeriodic`, the tail type sets `FwdTypes`/`BwdTypes` of a
  colouring read from a seam time with their tail congruences, and the one-sided transports
  `exists_periodic_fwd`/`exists_periodic_bwd` (Ramsey over the profile, bounded representatives)
  assembled through the seam into `exists_periodic_subfamily`; every length bound is a count of
  pairs of profiles.
* `RaySummary.Present` — finite labelled presentations with their runs (`IsRun`,
  `runTrace`), the computable path-type closure (`pathTypes`, `pathTypesNow`,
  `mem_pathTypes_iff`, `mem_pathTypesNow_iff`) and liveness (`fwdLive`, `bwdLive`,
  `fwdLive_iff`, `bwdLive_iff`).
* `RaySummary.HitOf` — the computable realized-triple set of a presentation (`hitOf`), read
  through liveness over disjoint segments (`fwdLiveSep`, `bwdLiveSep`; `Present`'s
  `fwdLive`/`bwdLive` are retained but not consumed), and its membership characterization
  against the family triples of the presentation's runs (`mem_hitOf_iff`).
* `RaySummary.StabCheck` — the `now`-free step graphs (`fwdNowFree`, `bwdNowFree`), the
  states on anchored runs by liveness (`OnRun`, `onRun_iff_live`), the presentation-level
  decider of the run-level `⊡` condition (`stabCheckSig`, `stabCheckSig_iff`), and its closure
  instance under `Presented` (`stabCheck_iff_of_presented`, `decidableStabOfPresented`),
  vacuous on model A where `Presented` is refuted.
* `RaySummary.Realize` — requirement (S), the soundness half: the decidable per-edge
  consistency conditions on a finite labelled presentation (`UCoh`, `deferGraph`, `ULive`,
  `SCoh`, `bwdDeferGraph`, `SLive`) and the two theorems forcing `LocalRun`'s eventuality
  clauses from them (`untl_iff_of_UCoh_ULive`, `snce_iff_of_SCoh_SLive`, the latter proved
  outright and not transported); the scope predicate `PlusFormula.BoxStabFree` with the
  closure-vacuity lemmas it buys (`not_box_mem_plusSubformulaClosure`,
  `not_stab_mem_plusSubformulaClosure`); the ELEVEN-field bundle `Cons` with `cons_localRun`
  (ten fields mirror a `LocalRun` field or a frame law; the eleventh, `nowUnique`, was derived
  from the realization theorem's own obligation); the constructed model `frameOf` / `modelOf`
  with its regularity instance and the explicit record that its carrier is infinite
  (`frameOf_isRegular`, `frameOf_not_finite_worldState`); and the realization theorem
  `presented_modelOf` with its Hit-level corollary `hitCl_modelOf_eq_hitOf`. Scope: ONE seam,
  `box`/`stab`-free `φ`, `[Fintype Q]` on the PRESENTATION only. Nothing there states
  `Decidable (PlusValidZTime φ)`.
* `RaySummary.AnchorLayer` — the anchor layer of requirement (W): closure types read off a
  model (`tpOf`, `mem_tpOf_iff`, `tpOf_timeShift`), the per-state cells (`cellAt`,
  `cellAt_eq_cellAt`), the four fixpoint equations a closure type satisfies by the truth
  clauses alone (`bot_not_mem_tpOf`, `imp_mem_tpOf_iff`, `box_mem_tpOf_iff` — one global bit,
  `stab_mem_tpOf_iff` — one bit per cell), the finite object `AnchorCons` on a set of cells with
  its completeness theorem for EVERY model (`anchorCons_anchorCells`, no presentation, no
  finiteness, no regularity hypothesis), `anchorCells_finite` and the cardinality bound
  `anchorCells_ncard_le` (`≤ 2 ^ (2 ^ |cl φ|)`, a count of cells and not a complexity bound),
  and the `Finset` twin `AnchorConsFin` with `decidableAnchorConsFin` (decidable on a concrete
  finite object, never about a model) and the bridge `anchorConsFin_iff`. No `[F.IsRegular]`,
  no `untl`/`snce` equation (the run layer, blocked), nothing about `PlusValidZTime`.
* `RaySummary.RunLayer` — the run layer's frame scheme, the regularity part of its first
  obligation: the branching core transcribed from the wired probe
  `b2b-frame-constructor-branching.lean` (`FwdFinBranch`, `BwdFinBranch`, `iterS_fwd_finite`,
  `iterS_bwd_finite`, `fib_finite_of_finBranch`, `saturation_of_finBranch`), the parallel
  constructor `ofSlicedStepFinBranch` (`ofSlicedStep`'s body with `[Finite W]` replaced by
  two-sided finite branching in its one `Saturation` slot; `SlicedFrame.lean` untouched) with
  its regularity instance, step lemma, infinite-carrier record and history characterization
  (`ofSlicedStepFinBranch_mem_HF_iff`), and the deadline ladder `Rlad` (`Drift`, `Count`) with
  two-sided finite branching for EVERY finite object (`Rlad_fwd`, `Rlad_bwd`), an infinite
  slice (`Rlad_slice_infinite`), and the frame `ladderFrame` it yields (`ladderFrame_isRegular`,
  `ladderFrame_step`); seriality is the object's own `fwd`/`bwd` hypotheses; depth `k = 1`.
  No `[F.IsRegular]`-free claim about validity, nothing about `PlusValidZTime`, no realization
  theorem (the run layer's phase 2, open).
* `RaySummary.LadderModel` — the admissible ladder carrier beside `ladderFrame`: the record
  that `ladderFrame`'s own seriality hypotheses are unsatisfiable (`no_fwd` for every object,
  `no_bwd_of_idle` for every object with an idle state — the frame has no instances), the
  admissibility set `Adm` (`{c | pend q = false → c = 0}`, a restriction of the CARRIER), the
  carrier `LadderState` with `ladderState_nonempty`, the restricted relation `RladAdm` with
  two-sided finite branching for EVERY finite object (`RladAdm_fwd`, `RladAdm_bwd`, pulled
  back along `Subtype.val`), the frame `ladderFrameAdm` with `ladderFrameAdm_isRegular`, and
  the model `ladderModel` whose valuation reads the object component only. `[Finite Q]` on
  the OBJECT only; the slice `LadderState Q pend` is infinite; `RunLayer.lean` untouched. No
  realization theorem (the run layer's phase 2, open — its stabilization statement in the
  counter pair is refuted by the wired probe `ladder-cell-refutation.lean`), no index of a
  ladder cell claimed, nothing about `HitPresented`, nothing about `PlusValidZTime`, no
  complexity bound.
-/
