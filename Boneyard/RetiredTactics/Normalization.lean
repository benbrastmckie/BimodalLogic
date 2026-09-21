/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Normalization

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.
Do not import from live code.
-/

#exit

/-!
# Retired: the normalization tactic macros

Seven tactic wrappers lifted out of `FormalSystem/Automation/Normalization.lean`. Each was a
one-line `simp only` over a simp set that is still live there, and none of the seven had a
single invocation outside that file's own round-trip examples. See
[`README.md`](README.md) for the per-tactic measurement.

This is an EXCERPT, not a module that was archived whole: `Normalization.lean` itself is still
live, still carries the 21 unfold lemmas, the 10 fold lemmas, `EnrichedFormula`, `foldFormula`
and the serialization layer. Only the wrappers left. To resurrect one, paste it back into that
module -- do not restore this file as a module.

Nothing under `Boneyard/` is compiled, and this file is not reachable from `lakefile.lean`'s
`FormalSystem` root.

## Tags

retired · normalization · tactics · simp-sets
-/

namespace FormalSystem.Automation.Normalization

section NormTactics

/--
Full normalization to primitives: unfolds all 15 derived operators.
Reduces any formula to a combination of `atom`, `bot`, `imp`, `box`, `untl`, `snce`.
-/
macro "modalNorm" : tactic =>
  `(tactic| simp only [formula_unfold])

/-- Propositional normalization only: unfolds neg, top, and, or. -/
macro "propNorm" : tactic =>
  `(tactic| simp only [neg_unfold, top_unfold, and_unfold, or_unfold])

/-- Modal operator normalization only: unfolds diamond. -/
macro "modalOpNorm" : tactic =>
  `(tactic| simp only [diamond_unfold])

/-- Temporal normalization only: unfolds next, prev, someFuture, somePast,
    allFuture, allPast, weakFuture, weakPast, always, sometimes. -/
macro "temporalNorm" : tactic =>
  `(tactic| simp only [
    next_unfold, prev_unfold,
    some_future_unfold, some_past_unfold,
    all_future_unfold, all_past_unfold,
    weak_future_unfold, weak_past_unfold,
    always_unfold, sometimes_unfold])

/-- Normalize at a specific hypothesis. -/
syntax "modalNormAt" ident : tactic
macro_rules
  | `(tactic| modalNormAt $h) =>
    `(tactic| (simp only [formula_unfold] at $h:ident))

/-- Normalize all hypotheses and the goal. -/
macro "modalNormAll" : tactic =>
  `(tactic| simp only [formula_unfold] at *)

end NormTactics

section FoldTactics

/-- Fold primitives back to derived operators where unambiguous.
    Uses the `← _unfold` pattern to reverse unfold lemmas. -/
macro "modalFold" : tactic =>
  `(tactic| simp only [
    ← neg_unfold, ← top_unfold, ← next_unfold, ← prev_unfold,
    ← and_unfold, ← diamond_unfold,
    ← some_future_unfold, ← some_past_unfold,
    ← all_future_unfold, ← all_past_unfold,
    ← weak_future_unfold, ← weak_past_unfold,
    ← always_unfold, ← sometimes_unfold,
    ← strong_release_unfold, ← strong_trigger_unfold])

end FoldTactics

end FormalSystem.Automation.Normalization
