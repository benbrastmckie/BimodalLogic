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
   or term.
2. Four `#guard_msgs`-gated `#print axioms` blocks pinning the axiom profiles that matter.
   These are **build-breaking**: if any profile moves, this module stops compiling.
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

/-! ## The witnessing relation -/

/--
The witnessing task relation, on the finite carrier `Bool` over `D = Int`:
`R w d u` holds when `d = 0` and `w = u`, or when `d = 3` outright.

Its two fibers of interest are `Fib R w 0 = {w}` — the zero-duration fiber is the singleton on
its own source — and `Fib R w 3 = Set.univ` — every duration-3 step is permitted, from and to
anywhere. Those two shapes are the whole construction: `{true}`, `{false}`, and `Set.univ` are
all fibers of this single relation, so a family assembled out of them satisfies *Spherical*'s
`IsFiber R s ∨ IsSegment R s` side condition on the fiber disjunct alone, with no appeal to
segments and so no sign-of-endpoint bookkeeping.

The duration `3` is arbitrary among nonzero durations; only `3 ≠ 0` matters.
-/
def wlemRel : Bool → Int → Bool → Prop :=
  fun w d u => (d = 0 ∧ w = u) ∨ (d = 3)

/-- The zero-duration fiber of `wlemRel` is the singleton on its source. -/
theorem Fib_wlemRel_zero (w : Bool) : TaskFrame.Fib wlemRel w 0 = {w} := by
  ext u
  constructor
  · rintro (⟨-, h⟩ | h)
    · exact h.symm
    · exact absurd h (by decide)
  · rintro rfl
    exact Or.inl ⟨rfl, rfl⟩

/-- The duration-3 fiber of `wlemRel` is the whole carrier. -/
theorem Fib_wlemRel_three (w : Bool) : TaskFrame.Fib wlemRel w 3 = Set.univ := by
  ext u
  constructor
  · intro _
    exact trivial
  · intro _
    exact Or.inr rfl

/-! ## The family -/

/--
The family whose directedness encodes `P`: it always contains `Set.univ`, contains `{true}`
exactly when `P` holds, and contains `{false}` exactly when `P` fails.

The intersection of this family is therefore forced to `{true}` under `P` and to `{false}` under
`¬P`, so a *Spherical* witness for it must already have decided which side it is on — which is
precisely the content that weak excluded middle expresses.
-/
def wlemFamily (P : Prop) : Set (Set Bool) :=
  {s | (s = {true} ∧ P) ∨ (s = {false} ∧ ¬P) ∨ s = Set.univ}

theorem univ_mem_wlemFamily (P : Prop) : Set.univ ∈ wlemFamily P :=
  Or.inr (Or.inr rfl)

theorem singleton_true_mem_wlemFamily {P : Prop} (hP : P) :
    ({true} : Set Bool) ∈ wlemFamily P :=
  Or.inl ⟨rfl, hP⟩

theorem singleton_false_mem_wlemFamily {P : Prop} (hnP : ¬P) :
    ({false} : Set Bool) ∈ wlemFamily P :=
  Or.inr (Or.inl ⟨rfl, hnP⟩)

/--
`wlemFamily P` is directed, **constructively** — this is the step that has to stay choice-free
for the whole file to mean anything.

Nine cases, one per ordered pair of membership disjuncts. Seven are witnessed by the smaller of
the two sets. The two cross cases pair `{true}` (carrying `P`) with `{false}` (carrying `¬P`),
and discharge by `absurd` on the two hypotheses directly: no case split on `P` is performed or
needed, which is exactly why no classical principle is consumed here.
-/
theorem wlemFamily_directed (P : Prop) : TaskFrame.DirectedFamily (wlemFamily P) := by
  refine ⟨⟨Set.univ, univ_mem_wlemFamily P⟩, ?_⟩
  rintro S₁ (⟨rfl, h₁⟩ | ⟨rfl, h₁⟩ | rfl) S₂ (⟨rfl, h₂⟩ | ⟨rfl, h₂⟩ | rfl)
  -- {true}, {true}
  · exact ⟨{true}, singleton_true_mem_wlemFamily h₁, fun _ hx => ⟨hx, hx⟩⟩
  -- {true} with P, {false} with ¬P
  · exact absurd h₁ h₂
  -- {true}, univ
  · exact ⟨{true}, singleton_true_mem_wlemFamily h₁, fun _ hx => ⟨hx, trivial⟩⟩
  -- {false} with ¬P, {true} with P
  · exact absurd h₂ h₁
  -- {false}, {false}
  · exact ⟨{false}, singleton_false_mem_wlemFamily h₁, fun _ hx => ⟨hx, hx⟩⟩
  -- {false}, univ
  · exact ⟨{false}, singleton_false_mem_wlemFamily h₁, fun _ hx => ⟨hx, trivial⟩⟩
  -- univ, {true}
  · exact ⟨{true}, singleton_true_mem_wlemFamily h₂, fun _ hx => ⟨trivial, hx⟩⟩
  -- univ, {false}
  · exact ⟨{false}, singleton_false_mem_wlemFamily h₂, fun _ hx => ⟨trivial, hx⟩⟩
  -- univ, univ
  · exact ⟨Set.univ, univ_mem_wlemFamily P, fun _ _ => ⟨trivial, trivial⟩⟩

/--
Every member of `wlemFamily P` is a nonempty fiber of `wlemRel`, constructively. The two
singletons are zero-duration fibers and `Set.univ` is the duration-3 fiber, so the `IsFiber`
disjunct always fires and `IsSegment` is never needed.
-/
theorem wlemFamily_fiber_nonempty (P : Prop) :
    ∀ s ∈ wlemFamily P,
      (TaskFrame.IsFiber wlemRel s ∨ TaskFrame.IsSegment wlemRel s) ∧ s.Nonempty := by
  rintro s (⟨rfl, -⟩ | ⟨rfl, -⟩ | rfl)
  · exact ⟨Or.inl ⟨true, 0, (Fib_wlemRel_zero true).symm⟩, ⟨true, rfl⟩⟩
  · exact ⟨Or.inl ⟨false, 0, (Fib_wlemRel_zero false).symm⟩, ⟨false, rfl⟩⟩
  · exact ⟨Or.inl ⟨true, 3, (Fib_wlemRel_three true).symm⟩, ⟨true, trivial⟩⟩

/-! ## The obstruction -/

/--
**Weak excluded middle follows from *Spherical* on a finite carrier.**

Given only `TaskFrame.Spherical wlemRel` — *Spherical* for one fixed relation on the
two-element carrier `Bool` over `D = Int` — this derives `¬¬P ∨ ¬P` for an arbitrary `P`, using
no classical tactic or term. Its own axiom profile is exactly `[propext, Quot.sound]`, pinned by
a `#guard_msgs` block below.

**Why this theorem exists.** `TaskFrame.spherical_of_finite` transcribes the paper corollary
`cor:spherical-finite`, which calls itself *choice-free*, yet the Lean proof depends on
`Classical.choice`. That gap invites a future reader to treat "make `spherical_of_finite`
choice-free" as an open piece of work and go hunting for a better proof. **The hunt is provably
futile, and this theorem is the proof of that.** A `Classical.choice`-free proof of
`spherical_of_finite` would instantiate at `wlemRel` to give `Spherical wlemRel` from
`[propext, Quot.sound]` at worst; feeding that here would yield weak excluded middle for every
`P` in Lean's intuitionistic core, where it is not derivable. So no such proof exists. The
acceptance criterion "prove it choice-free" is not unattempted — it is unsatisfiable, and nothing
about `spherical_of_finite` needs fixing.

None of this contradicts the paper. The paper's "choice-free" means *no axiom of choice, given
classical logic* — a ZF-versus-ZFC claim. Lean's `Classical.choice` is the single axiom yielding
both excluded middle (via Diaconescu) and AC, so `#print axioms` cannot express the paper's
distinction in either direction. What survives transcription intact is the absence of **Zorn**;
see "The no-Zorn claim" below.

**The argument.** `wlemFamily P` contains `Set.univ` always, `{true}` exactly under `P`, and
`{false}` exactly under `¬P`; it is directed and all its members are nonempty fibers of
`wlemRel`. *Spherical* hands back a point `b : Bool` of the intersection. Case on `b`: if
`b = true` then `P` cannot fail, since `¬P` would put `{false}` in the family and force
`true = false`; if `b = false` then `P` cannot hold, symmetrically. Deciding which of the two
sets the witness lies in is what the classical step in `spherical_of_finite` is buying.
-/
theorem wlem_of_spherical (hSph : TaskFrame.Spherical wlemRel) (P : Prop) : ¬¬P ∨ ¬P := by
  obtain ⟨b, hb⟩ := hSph (wlemFamily P) (wlemFamily_directed P) (wlemFamily_fiber_nonempty P)
  have hb' : ∀ t ∈ wlemFamily P, b ∈ t := Set.mem_sInter.mp hb
  cases b with
  | true =>
      refine Or.inl fun hnP => ?_
      have h : (true : Bool) ∈ ({false} : Set Bool) :=
        hb' _ (singleton_false_mem_wlemFamily hnP)
      exact absurd (Set.mem_singleton_iff.mp h) (by decide)
  | false =>
      refine Or.inr fun hP => ?_
      have h : (false : Bool) ∈ ({true} : Set Bool) :=
        hb' _ (singleton_true_mem_wlemFamily hP)
      exact absurd (Set.mem_singleton_iff.mp h) (by decide)

/-! ## The axiom-profile guards

Each block below is **build-breaking**: `#guard_msgs` compares the `#print axioms` info message
against the expected text character for character, and a mismatch fails elaboration of this
module. Every expected string was measured from this toolchain, not transcribed from prose.

Read the "When one of these guards fires" note in this file's module docstring before editing any
expected block.

### The constructive core

The constructive core of the finite-carrier discharge depends on **no axioms at all** — not even
`propext`. This is the part of `cor:spherical-finite`'s choice-free claim that survives
transcription into Lean intact, and the guard below is what keeps it surviving: the lemma is
deliberately separated from `spherical_of_finite` so that the classical step is isolated in the
*production* of a `⊆`-minimal member and nowhere else. A profile appearing here at all means the
separation has leaked.
-/

/-- info: 'FormalSystem.Semantics.TaskFrame.sInter_nonempty_of_directed_of_minimal' does not depend on any axioms -/
#guard_msgs in
#print axioms FormalSystem.Semantics.TaskFrame.sInter_nonempty_of_directed_of_minimal

/-! ### The full discharge

The full finite-carrier discharge costs exactly `Classical.choice` and nothing more exotic.

Both directions of this guard carry information. If the profile ever **grows** past these three,
something new and unaccounted-for entered the proof. If it ever **shrinks** — specifically, if
`Classical.choice` disappears — that is not a win to celebrate but a contradiction to
investigate, because `wlem_of_spherical` above shows such a proof would derive weak excluded
middle in Lean's intuitionistic core. Suspect a change in what `Spherical` *means* before
believing the profile.
-/

/-- info: 'FormalSystem.Semantics.TaskFrame.spherical_of_finite' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.TaskFrame.spherical_of_finite

/-! ### The tripwire

`spherical_of_subsingleton` is choice-free at `[propext]`, and must stay that way.

`spherical_of_finite` discharges *Spherical* for an arbitrary relation on any finite carrier, so
it subsumes this helper's statement — which makes "simplify by routing the subsingleton case
through the general lemma" a tempting and entirely wrong consolidation. It would regress this
helper from `[propext]` to `[propext, Classical.choice, Quot.sound]`, and propagate that
regression to the three `Unit`-carriered universal frames that consume it (`trivialFrame`,
`intTimeFrame`, `genericTimeFrame`). `TaskFrame.spherical_of_finite`'s own docstring records the
prohibition in prose; this guard is what enforces it mechanically. If this block fails with
`Classical.choice` in the actual output, the correct response is to revert the consolidation, not
to update this expected text.

The two other shape-constrained helpers, `spherical_of_permissive` and `spherical_of_eq`, are
**already** classical at `[propext, Classical.choice, Quot.sound]` and are deliberately not
guarded here: there is no choice-freedom left in them to protect.
-/

/-- info: 'FormalSystem.Semantics.TaskFrame.spherical_of_subsingleton' depends on axioms: [propext] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.TaskFrame.spherical_of_subsingleton

/-! ### The obstruction itself

`wlem_of_spherical` must stay constructive, or it proves nothing.

It is evidence that a choice-free `spherical_of_finite` is impossible only if its *own*
derivation is choice-free. A version carrying `Classical.choice` would derive weak excluded
middle from classical logic, which is trivially true and says nothing whatever about
`spherical_of_finite`. This guard is therefore load-bearing for the entire argument of this file.
-/

/-- info: 'BimodalTest.Semantics.wlem_of_spherical' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms wlem_of_spherical

/-! ## The no-Zorn claim

`cor:spherical-finite`'s substantive surviving content is that the finite-carrier discharge does
**not** route through Zorn's lemma — in deliberate contrast with `thm:extension`, whose own
recorded footnote says "The proof appeals to Zorn's lemma, and so the derivation of
\textit{Occurrence} ... is a theorem of ZFC, in contrast with the derivation of the zero loops in
\textbf{\ref{lem:nullity}} and the derivation of \textit{Spherical} for finite $W$ in
\textbf{\ref{cor:spherical-finite}}, both of which are choice-free", and so names exactly this
corollary as one of its two choice-free contrasts. (The footnote's earlier wording, "appeals to
Zorn's lemma and hence to the axiom of choice", is no longer the paper's text.)

**This claim is not, and cannot be, expressed by any block above.** `#print axioms` reports
`Classical.choice`, and Zorn's lemma is a theorem derived from `Classical.choice`, not an axiom
in its own right — it never appears in a profile. There is no honest axiom-based test for "no
Zorn", so none is fabricated here.

The evidence is the **import graph**, which is a stronger guarantee than a profile check anyway
because it is structural rather than observational:

- `FormalSystem/Semantics/TaskFrame.lean`, which declares both
  `sInter_nonempty_of_directed_of_minimal` and `spherical_of_finite`, imports **no**
  `FormalSystem.*` module whatsoever — its import list is eight Mathlib modules and nothing else
  — and does not import `Mathlib.Order.Zorn`.
- `PartialHistory.exists_maximal_extension`, the Zorn appeal in this development, lives in
  `FormalSystem/Semantics/PartialHistoryOrder.lean`, which is the module that imports
  `Mathlib.Order.Zorn`.
- That module imports `FormalSystem.Semantics.PartialHistory`, which sits **downstream** of
  `TaskFrame.lean`. The dependency therefore runs `TaskFrame ← PartialHistory ←
  PartialHistoryOrder`, so a dependency of `spherical_of_finite` on `exists_maximal_extension`
  would require an import cycle. It is not merely absent; it is unconstructible.

The self-enforcing part is that Lean rejects import cycles outright. Any future edit that gave
`TaskFrame.lean` access to the extension chain would have to add the import, and would fail to
compile. That is the guard, and it needs no expected-output block.
-/

end BimodalTest.Semantics
