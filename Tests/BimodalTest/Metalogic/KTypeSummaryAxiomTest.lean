/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.KTypeSummary
import FormalSystem.Metalogic.WeakCanonical.GroupModel.RamseyFactorization

/-!
# Axiom-profile evidence for the `k`-type summary substrate

This module is **permanent evidence**, not a conventional test, on the pattern of
`PeriodicExtensionAxiomTest.lean`. The `KTypeSummary/` cluster is Büchi's complementation chain
transposed to monadic `k`-types over the `ℤ` time axis, and every headline theorem of that chain
is stated in the tree as proved on the **standard profile** `[propext, Classical.choice,
Quot.sound]` with no `sorryAx`. A claim of that shape kept only in prose rots the moment anyone
edits a proof; here each is pinned with `#guard_msgs` + `#print axioms`, so a red build is the
signal that a profile moved.

## What is pinned

| Row | Chain step | Guard |
|---|---|---|
| infinite Ramsey for pairs, the Ramsey ingredient | 4 | `Nat.exists_strictMono_const_pair_colour` |
| its in-tree alias | 4 | `infinite_ramsey_pairs` |
| the summary alphabet is finite | 2 | `kType_finite` |

Rows for the later steps are appended as their modules land.

## What this does **not** pin, and why

Nothing here measures a decidability result, because the cluster proves none: saturation is
proved for `k`-type-determined targets over coloured `ℤ`-blocks, and no reduction from a `⊡`
fibre condition to such a target exists in Lean anywhere. A green build of this file certifies
axiom profiles, not adequacy.

## When one of these guards fires

The expected block is updated **in the same commit as the change that moved it**, with the move
justified there — never on its own to turn a red build green. A profile that has grown an axiom
outside the standard three, or that reports `sorryAx`, is a regression to investigate, not an
expectation to rewrite.
-/

namespace BimodalTest.Metalogic

/-! ## Step 4's ingredient: infinite Ramsey for pairs

The `Classical.choice` here is genuine and expected: the proof builds a descending chain of
infinite sets by `Exists.choose` and picks the infinitely-often colour by a second pigeonhole.
-/

/-- info: 'Nat.exists_strictMono_const_pair_colour' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms Nat.exists_strictMono_const_pair_colour

/-- info: 'FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.infinite_ramsey_pairs

/-! ## Step 2: the summary alphabet is finite -/

/-- info: 'FormalSystem.Metalogic.WeakCanonical.kType_finite' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.WeakCanonical.kType_finite

end BimodalTest.Metalogic
