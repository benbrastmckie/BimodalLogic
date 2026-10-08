/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Seam
import FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti
import FormalSystem.Metalogic.Decidability.RaySummary.Closure
import FormalSystem.Metalogic.Decidability.RaySummary.Trace

/-!
# `RaySummary` — the seam interface for `⊡` over the time axis

Aggregator for the decidability side's interface to the `k`-type summary substrate
(`FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`). It holds the seam interface only, in two
modules: `Seam.lean` states the `⊡` bridge `plusStab_iff_seamSummary` against the single-family
hypothesis bundle `Presents`, and `SeamMulti.lean` characterizes that bundle (it is inhabited iff
the seam is `⊡`-decided, `exists_presents_iff`) and states the hypothesis-free bridge
`plusStab_iff_forall_hit` over the realized family triples `Hit` of a two-letter trace — with
`Hit` named as not computed. No decision procedure is built here, no decidability result is
proved, and no complexity bound is claimed.

## Modules

* `RaySummary.Seam` — `SeamSummary`, `Presents`, `plusStab_iff_seamSummary`.
* `RaySummary.SeamMulti` — `SeamDecided`, `exists_presents_iff`, the two-letter interface
  (`seamTrace`, `stabTarget`, `Hit`), the hypothesis-free bridge `plusStab_iff_forall_hit`, and
  `PresentsMulti` with its inhabitant `presentsMulti_seamTrace`.
-/
