/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Orbit

/-!
# Axiom-profile evidence for effective periodic extension

This module is **permanent evidence**, not a conventional test. The docstring of
`FormalSystem.Metalogic.Decidability.IntPresentation.extend_periodic` makes a precise claim about
where `Classical.choice` enters that result and where it does not, and a claim of that shape kept
only in prose rots the moment anyone edits a proof. Every sentence of it that is mechanically
checkable is checked here.

## What is claimed, and which guard checks it

| Claim | Guard |
|---|---|
| The successor selection is choice-free | `succOf`, `succOf_step`, `predOf`, `predOf_step` |
| The time-shift that places a lasso is choice-free | `isStepPath_shift` |
| The certificate's **data** is choice-free | `windowBack`, `windowMid`, `windowFwd`, `windowPath` |
| The pigeonhole is choice-free too | `exists_dup_lt`, `orbit_repeat`, `orbit_repeat_pred` |
| The theorem as a whole is choice-carrying | `extend_periodic`, `extend_periodic_of_icc` |

The last row is deliberately *not* a defect being recorded as acceptable. It is the measurement
the docstring quotes verbatim, pinned so that the quotation cannot silently drift out of date.

## The successor selection runs

Choice-freedom of a proof is weaker than computability of a definition: a definition can be
`[propext, Quot.sound]` and still be stuck behind an irreducible `Classical.dec`. The `#eval`
blocks at the end close that gap by *running* the selection and the three segment lists on a
concrete presentation.

## When one of these guards fires

A red build here means an axiom profile moved. The expected block is updated **in the same commit
as the change that moved it**, with the move justified in that commit — never on its own to turn
a red build green. In particular, a guard in the first three rows that has grown
`Classical.choice` is a regression to investigate, not an expectation to rewrite: it would mean
the computable half of this construction has been contaminated by the classical half, and the
`extend_periodic` docstring's central distinction would no longer hold. Conversely, a profile in
the last row that *shrinks* is a welcome improvement — update the block and the docstring's ON
CHOICE section in the same commit, and do not turn the shrinkage into a constructivity claim the
measurement does not support.
-/

namespace BimodalTest.Metalogic

open FormalSystem.Metalogic.Decidability

/-! ## The choice-free half: successor selection

`succOf` picks the first state in `List.finRange P.card` that the current state steps to.
Seriality (`IntPresentation.fwd` / `IntPresentation.bwd`) is consumed only to refute the `none`
branch — an elimination of `∃` into `False`, which costs nothing. If any of these four grows
`Classical.choice`, the definition has been re-routed away from `List.find?`, and
`extend_periodic`'s claim that "the successor selection is not one of the two sources" is false.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.succOf' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.succOf

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.succOf_step' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.succOf_step

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.predOf' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.predOf

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.predOf_step' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.predOf_step

/-! ## The choice-free half: placement

The origin offset that lets a window sit at arbitrary absolute times costs nothing at all. This
matters for the honesty of the accounting: it means the `Classical.choice` on the placed decoding
is inherited entirely from the frozen decoding lemmas it wraps, and none of it was introduced by
adding the origin.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.isStepPath_shift' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.isStepPath_shift

/-! ## The choice-free half: the certificate's data

A certificate is three lists and an integer. Those lists — and the intended path they decode to —
are choice-free. What carries `Classical.choice` is the *proof* that the lists cohere, not the
lists. That distinction is the whole content of calling this result effective, so it is pinned
rather than asserted.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.windowBack' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.windowBack

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.windowMid' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.windowMid

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.windowFwd' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.windowFwd

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.windowPath' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.windowPath

/-! ## The pigeonhole, which is choice-free by construction

Every route to pigeonhole in Mathlib carries `Classical.choice`, `Finset.card_le_card` included,
because `Finset.card` sits on `Multiset` / `Quot` machinery that pulls it in at the base. That is
an **API fact, not a proved logical obstruction** — pigeonhole over a carrier with decidable
equality is constructively valid — so it is avoidable, and `exists_dup_lt` avoids it, by deleting
a value from the codomain and inducting. `orbit_repeat` and `orbit_repeat_pred` inherit the
result.

These three guards are the load-bearing ones for that claim. A profile here that has grown
`Classical.choice` means the direct construction has been replaced by a library call, or that a
`==` comparison has crept back in: at `Fin`, `==` resolves through a `LawfulBEq` route whose
`beq_iff_eq` and `eq_of_beq` are *themselves* choice-carrying with the full library in scope,
which is why `exists_dup_lt` spells its comparison as `Nat.beq` on the underlying values.

Note what this does **not** do: it does not make `extend_periodic` choice-free, because that
theorem's conclusion routes through decoding lemmas in a module held byte-stable. See the two
blocks below.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.exists_dup_lt' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.exists_dup_lt

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.orbit_repeat' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.orbit_repeat

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.orbit_repeat_pred' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.orbit_repeat_pred

/-! ## The theorem as measured

These two blocks are the literal strings quoted in the `extend_periodic` docstring. They exist so
that the quotation is checked rather than trusted.

Two sources remain, both incidental library facts rather than anything about frames, finiteness,
or time: `BiLasso.length_pos_int`'s numeric-coercion step, which reaches this theorem through the
decoding lemmas and lives in a module held byte-stable, and Mathlib's `List.getD` indexing
lemmas, which every segment-readout lemma is stated in terms of. Both look as scrubbable in
principle as the pigeonhole turned out to be; neither is scrubbable from here, and no claim
either way is made.
-/

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.extend_periodic' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.extend_periodic

/-- info: 'FormalSystem.Metalogic.Decidability.IntPresentation.extend_periodic_of_icc' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.extend_periodic_of_icc

/-! ## The selection and the segments run

Measured on `flipPresentation`, the two-state cycle `0 ⇄ 1`. The first match in `List.finRange 2`
out of state `0` is state `1`, and conversely; the segment lists of a window are then plain data
a model checker could serialise.
-/

/-- info: 1 -/
#guard_msgs in
#eval flipPresentation.succOf 0

/-- info: 0 -/
#guard_msgs in
#eval flipPresentation.predOf 1

/-- info: [1, 0, 1, 0] -/
#guard_msgs in
#eval flipPresentation.windowMid [0, 1] 1 1

/-- info: [0, 1] -/
#guard_msgs in
#eval flipPresentation.windowFwd [0, 1] 0 2

/-! ## The no-Zorn record

The claim that this construction avoids Zorn's lemma **cannot** be expressed by any block above.
`#print axioms` reports `Classical.choice`; Zorn's lemma is a theorem derived from it, not an
axiom in its own right, so it never appears in a profile. No axiom-based test for "no Zorn" is
honest, and none is fabricated here.

The evidence is the **import graph**, which is structural rather than observational and therefore
the stronger guarantee. `FormalSystem.Semantics.Extension.Extension` is where
`PartialHistory.exists_maximal_extension` lives, and it is imported by none of
`BiLasso/Extend.lean`, `BiLasso/Successor.lean`, or `BiLasso/Orbit.lean`. Those modules reach
`PartialHistory` and `Extends` through `FormalSystem/Semantics/PartialHistory.lean`, which carries
no Zorn route at all. The `example` below is the mechanical form of that observation: it
elaborates only because this module's environment can name `extend_periodic` while the extension
theorem plays no part in producing it.
-/

example (P : IntPresentation) (win : List (Fin P.card)) (hne : win ≠ [])
    (hadj : ∀ k : ℕ, k + 1 < win.length →
      P.step (win.getD k default) (win.getD (k + 1) default) = true) (origin : ℤ) :
    ∃ _L : FormalSystem.Metalogic.Decidability.PlacedBiLasso P, True := by
  obtain ⟨L, _⟩ := P.extend_periodic win hne hadj origin
  exact ⟨L, trivial⟩

end BimodalTest.Metalogic
