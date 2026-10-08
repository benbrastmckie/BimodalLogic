/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Seam

/-!
# `RaySummary` — the seam interface for `⊡` over the time axis

Aggregator for the decidability side's interface to the `k`-type summary substrate
(`FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`). It holds the seam interface only: the
`⊡` bridge `plusStab_iff_seamSummary` connecting the keystone `plusStab_iff_omega` to a seam
summary, stated against the hypothesis bundle `Presents` and discharging nothing. No decision
procedure is built here, no decidability result is proved, and no complexity bound is claimed.

## Modules

* `RaySummary.Seam` — `SeamSummary`, `Presents`, `plusStab_iff_seamSummary`.
-/
