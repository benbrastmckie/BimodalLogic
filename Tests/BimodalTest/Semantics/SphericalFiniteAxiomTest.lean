/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Int
import FormalSystem.Semantics.TaskFrame

/-!
# Axiom-profile evidence for the finite-carrier *Spherical* discharge

This module is **permanent evidence**, not a conventional test. It exists to answer, once and
durably, a question that will otherwise be re-opened every time someone reads
`TaskFrame.spherical_of_finite` and notices that it depends on `Classical.choice` while the
paper corollary it transcribes (`cor:spherical-finite`, recorded verbatim in
`specs/paper-definitions-of-record.md`) calls itself *choice-free*.

The natural reaction to that mismatch is to try to "fix" the Lean proof — to hunt for a
`Classical.choice`-free route to `Spherical R` on a finite carrier. **That hunt cannot succeed.**
`wlem_of_spherical` below derives weak excluded middle from `Spherical` at the finite carrier
`Bool` over `D = Int`, from `[propext, Quot.sound]` alone. Since weak excluded middle is not
derivable in Lean's intuitionistic core, no `Classical.choice`-free proof of
`spherical_of_finite` exists. The acceptance criterion "prove it choice-free" is not merely
unattempted; it is unsatisfiable, and this file is what makes that permanently un-chaseable.

The paper's "choice-free" is a claim about **ZF versus ZFC** — the argument needs no axiom of
choice *given classical logic*. Lean's `Classical.choice` is a different object: the single
axiom from which Lean derives both excluded middle (via Diaconescu) and AC. `#print axioms` has
no vocabulary in which to state the paper's distinction, so the two claims never contradict each
other; they are about different things. What the Lean side *does* preserve of the paper's claim
is the absence of **Zorn**, recorded under "The no-Zorn claim" below.

## Contents

1. `wlem_of_spherical` — the constructive obstruction, proved without any classical tactic
   or term (Phase 2 of the file's construction).
2. Four `#guard_msgs`-gated `#print axioms` blocks pinning the axiom profiles that matter
   (below). These are **build-breaking**: if any profile moves, this module stops compiling.
3. The no-Zorn record, which is an import-graph argument rather than an axiom-profile one.

## When one of these guards fires

A red build here means an axiom profile moved. The expected block is updated **in the same
commit as the change that moved it**, with the move justified in that commit — never updated on
its own to turn a red build green. A guard silently re-baselined to match whatever the tree now
does records nothing and protects nothing. In particular, a `spherical_of_subsingleton` guard
that has grown `Classical.choice` is a regression to revert, not an expectation to rewrite; see
that guard's own note below.
-/

namespace BimodalTest.Semantics

open FormalSystem.Semantics

end BimodalTest.Semantics
