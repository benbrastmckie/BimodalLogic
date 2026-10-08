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
import FormalSystem.Metalogic.Decidability.RaySummary.Present
import FormalSystem.Metalogic.Decidability.RaySummary.HitOf

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
`Presented`, which is discharged for no non-trivial model here: constructing a regular model from
a presentation is a successor record. So `hitOf` is computable on presentations and `Hit` is
never computed for a model outright; no decision procedure is built, no decidability result is
proved, no complexity bound is claimed, everything is under `[F.IsRegular]` over the `ℤ` time
axis, and the cited fixtures are forward-only (no backward Bool-fixture bridge exists).

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
* `RaySummary.Present` — finite labelled presentations with their runs (`IsRun`,
  `runTrace`), the computable path-type closure (`pathTypes`, `pathTypesNow`,
  `mem_pathTypes_iff`, `mem_pathTypesNow_iff`) and liveness (`fwdLive`, `bwdLive`,
  `fwdLive_iff`, `bwdLive_iff`).
* `RaySummary.HitOf` — the computable realized-triple set of a presentation (`hitOf`), read
  through liveness over disjoint segments (`fwdLiveSep`, `bwdLiveSep`; `Present`'s
  `fwdLive`/`bwdLive` are retained but not consumed), and its membership characterization
  against the family triples of the presentation's runs (`mem_hitOf_iff`).
-/
