/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Lean

/-!
# Truth-layer normalization simp attributes

Declares the two dedicated simp sets that the truth layer tags its characterization lemmas with:
`truth_norm` for the `TruthAt` equations and the `Truth.*_iff` family in
`FormalSystem/Semantics/Truth.lean`, and `swap_norm` for the eleven `Formula.swap_temporal_*`
lemmas in `FormalSystem/Syntax/Formula.lean`.

**Why this is a separate module.** `register_simp_attr` expands to an `initialize` block plus a
`syntax` declaration (`Lean/Meta/Tactic/Simp/RegisterCommand.lean`), and neither the attribute
nor the simp-set identifier it introduces is usable in the compilation unit that declares it —
tagging a lemma `@[truth_norm]` in the same file fails with `Unknown attribute [truth_norm]`, and
`simp only [truth_norm]` with `Unknown identifier truth_norm`. The declarations therefore have to
live upstream of every use site, which is what this module is for.

**Why this is a *second* declaration module rather than an extension of the first.**
`FormalSystem/Automation/NormalizationAttr.lean` documents the identical compilation-unit
constraint and closes its docstring with the instruction "It must not acquire any other content."
This module honours that instruction as written instead of amending it: the two truth-layer sets
get their own sibling, and `NormalizationAttr.lean` keeps hosting exactly the two normalization
sets it was written for. The same invariant applies here — **attribute and simp-set declarations
only**, no lemmas and no definitions.

**Why these sets exist at all.** `truth_norm` gives the truth layer an on-demand handle on the
whole characterization family, so a proof can open the normal form with `simp only [truth_norm]`
(or the `truth_simp` macro below) without naming ten lemmas. `swap_norm` collects the
`swap_temporal_*` family, only four of which carry `@[simp]`, so the complete eleven-lemma family
is reachable as one set at every use site.
-/

/-- Simp set for the truth-layer characterization lemmas of
`FormalSystem/Semantics/Truth.lean`: the `TruthAt` defining equations together with every
`Truth.*_iff` lemma (`neg_iff`, `and_iff`, `or_iff`, `imp_iff`, `box_iff`, `diamond_iff`,
`untl_iff`, `snce_iff`, `always_iff`, `future_iff`, `past_iff`, …). Rewrites a `TruthAt`-headed
goal about a compound formula into the corresponding meta-level connective. Use as
`simp only [truth_norm]`, or via the `truth_simp` macro. -/
register_simp_attr truth_norm

/-- Simp set for the eleven `Formula.swap_temporal_*` lemmas of
`FormalSystem/Syntax/Formula.lean`, which push `Formula.swapTemporal` through the connectives.
Four of the eleven also carry `@[simp]`; this set makes the whole family reachable at once. Use
as `simp only [swap_norm]`. -/
register_simp_attr swap_norm

/-- `truth_simp` opens the truth-layer normal form: shorthand for `simp only [truth_norm]`,
optionally at a location (`truth_simp at h`). -/
macro "truth_simp" loc?:(Lean.Parser.Tactic.location)? : tactic =>
  `(tactic| simp only [truth_norm] $(loc?)?)
