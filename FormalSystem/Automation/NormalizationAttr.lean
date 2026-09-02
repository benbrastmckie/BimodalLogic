/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Lean

/-!
# Normalization simp attributes

Declares the two dedicated simp sets that `FormalSystem/Automation/Normalization.lean` tags its
unfold and fold lemmas with.

**Why this is a separate module.** `register_simp_attr` expands to an `initialize` block plus a
`syntax` declaration (`Lean/Meta/Tactic/Simp/RegisterCommand.lean`), and neither the attribute
nor the simp-set identifier it introduces is usable in the compilation unit that declares it —
tagging a lemma `@[formula_unfold]` in the same file fails with `Unknown attribute
[formula_unfold]`, and `simp only [formula_unfold]` with `Unknown identifier formula_unfold`.
The declarations therefore have to live upstream of every use site, which is what this module is
for. It must not acquire any other content.

**Why the lemmas are not in the default simp set.** The unfold and fold families are exact `rfl`
inverses of each other (`neg_unfold : φ.neg = φ.imp bot` against `neg_fold : φ.imp bot = neg φ`).
With both families tagged `@[simp]`, plain `simp` rewrote in a cycle and any `Formula` goal died
with `maximum recursion depth has been reached`. Moving them into these two named sets ends the
cycle without losing the lemmas: `simp only [formula_unfold]` and `simp only [formula_fold]` each
reach one family on demand.
-/

/-- Simp set for the derived-operator **unfold** lemmas of
`FormalSystem/Automation/Normalization.lean`: rewrites a derived operator (`neg`, `top`, `and`,
`diamond`, `someFuture`, …) to its primitive expansion in terms of `atom`, `bot`, `imp`, `box`,
`untl`, `snce`. Use as `simp only [formula_unfold]`. -/
register_simp_attr formula_unfold

/-- Simp set for the derived-operator **fold** lemmas of
`FormalSystem/Automation/Normalization.lean`, the `rfl` inverses of the `formula_unfold` family.
Use as `simp only [formula_fold]`. Note this family is a strict subset of the unfold family: six
operators (`weakFuture`, `weakPast`, `always`, `sometimes`, `strongRelease`, `strongTrigger`)
have an unfold lemma but no fold lemma, which is why `modalFold` reverses the unfold lemmas
rather than using this set. -/
register_simp_attr formula_fold
