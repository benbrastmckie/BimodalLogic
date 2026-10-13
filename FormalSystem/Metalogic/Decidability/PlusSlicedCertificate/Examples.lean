/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Embed
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Specialize
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples

/-!
# Non-Vacuity of the Time-Sliced Certificate Class

This module is the sliced class's **non-vacuity record**: an exhibited, closed-term inhabitant of
`PlusSlicedCertificate.Certifies` at a non-empty closure with a live `untl` obligation, proved by
the kernel's own evaluation of `decidableCertifies`. It exists because a condition set that is
only ever *satisfiable* certifies nothing: a vacuously satisfiable set of clauses type-checks
indefinitely, and the one defect this programme exists to remove — a clause that collapsed to a
triviality under a reflexive guard — survived undetected for exactly as long as no non-trivial
inhabitant had been written down.

## The vocabulary, and where it comes from

The words are those of Beer, Ben-David, Eisner and Rodeh, *Efficient Detection of Vacuity in
Temporal Model Checking* (Formal Methods in System Design 18(2), 2001). A formula is satisfied
**vacuously** in a model when some sub-formula does not *affect* it — when it could be replaced by
anything without changing the verdict; the propositional special case, a conditional whose
antecedent is never true, is **antecedent failure**; and an **interesting witness** is a model
that satisfies the formula non-vacuously. Their notion is post hoc and model-relative, so no
algorithm of theirs is ported here. What transfers is the criterion: a witness counts only if it
does not satisfy the condition for a degenerate reason.

Read at a certificate class, the degenerate reason is an empty closure. `Complete.lean`'s
`Probe.exists_certifying_triv` sits at the empty context, where every closure-guarded clause of
`Certifies` quantifies over nothing — it is the class's **antecedent failure**, useful for showing
the completeness headline's hypothesis set is consistent and for nothing else. The witness below
is the **interesting** one: `Embedded.evTarget` is `p U q`, so the closure carries an `untl`
obligation, the embedded lasso genuinely labels it and genuinely discharges it, and negating the
`untl` clause's body at that position would flip the verdict. That is the sense in which the
clause *affects* `Certifies` here and not at `triv`.

## The total-edge witness, and what it adds

`liveFamily_sliced_certifies` is a *self-loop* certificate: slice width `1`, so its edge relation
is the identity on a one-element slice, and its closure carries an `untl` obligation and nothing
modal. `TotalEdge.certA_certifies` is the sliced class's second interesting witness and differs
on all three axes at once. Its width is `2`, so the slice carries a genuine edge relation rather
than a loop; that relation is **total**, so every index of every slice sees every index of the
next; and its target is `PlusSharingWitnessFamily.targetA`, the `Pp → ⊡Pp` whose non-validity
`Incompleteness.lean`'s `not_plusValidZTime_stabSnce` pins, so the closure carries a `snce`
obligation under the `⊡` modality instead of an `untl` one. Reusing `targetA` rather than
minting a fresh target is deliberate: it ties this row to an already-pinned genuine ℤ-time
non-validity, so the row records coverage of a target the development independently knows is not
valid.

The slice labelling carries `Pp` and not merely the atom. That is not decoration: the sliced
class's non-vacuity bar reads the *slice labelling*, not the closure and not the target path's
labels, so a certificate whose slices label only atoms carries no clause kind on its inventory
row however rich its closure is.

## The sharing class, for the same reason

`SharingWitnessFamily.Certifies` had no closed-term inhabitant either: every certifying family in
the tree is a deterministic `WitnessFamily`. `Sharing/Specialize.lean`'s `certifies_toSharing`
lifts one in a single line, and the lifted witness is recorded beside the sliced one so that every
certifying predicate under `Decidability/` carries an exhibited interesting witness.

## Main Results

- `WitnessFamily.Embedded.liveFamily_sliced_certifies` — **the sliced class's interesting
  witness**: the embedded certificate of the live family certifies, by `decide`
- `WitnessFamily.Embedded.liveFamily_toSharing_certifies` — the sharing class's interesting
  witness, lifted from `liveFamily_certifies`
- `PlusSlicedCertificate.TotalEdge.certA_certifies` — **the sliced class's total-edge witness**:
  a width-`2` certificate whose edge relation is total, at the `snce`-kind closure of
  `Pp → ⊡Pp`, proved by `decide`

## Tags

plus-language · certificate · time-sliced · non-vacuity · interesting witness
-/

namespace FormalSystem.Metalogic.Decidability

namespace WitnessFamily

namespace Embedded

/-- **The sliced class's interesting witness.** The embedded certificate of `liveFamily` — slice
width `1`, six window times, target `p U q` at time `-1` — satisfies all nine clauses of
`Certifies`, at a closure that carries an `untl` obligation the lasso discharges. Compare
`Probe.exists_certifying_triv`, the class's antecedent failure at the empty closure. -/
theorem liveFamily_sliced_certifies : (liveFamily.sliced (-1)).Certifies := by decide

/-- **The sharing class's interesting witness**, lifted from the deterministic one: the
branching bundle at the diagonal is inhabited at the same closure and the same time. -/
theorem liveFamily_toSharing_certifies : liveFamily.toSharing.Certifies (-1) :=
  certifies_toSharing _ liveFamily_certifies

end Embedded

end WitnessFamily

namespace PlusSlicedCertificate

/-! ## The total-edge witness

Every declaration here is a **closed term**. A parameterized `certA` could be proved by nothing
the kernel evaluates, and the inventory's interest expression — which is elaborated against the
built library, not against a section variable — could not name it.
-/

namespace TotalEdge

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

/-- The witness's atom. -/
def atomP : Atom := Atom.mkBase "p"

/-- **The one slice, used at both ends.** Width `2`; the edge relation is total, so every index
sees every index; and the labelling carries `Pp` beside the atom at index `1`, which is what puts
a `snce`-kind formula in every slab this certificate has. -/
def sliceA : PlusSlice 2 (closA atomP) where
  edge := fun _ _ => true
  lab := fun w => if w = 1 then {PlusFormula.atom atomP, snceP atomP} else ∅
  lab_sub := by
    intro w
    split_ifs
    · intro ψ h
      rw [mem_closA]
      simp only [Finset.mem_insert, Finset.mem_singleton] at h
      tauto
    · exact Finset.empty_subset _

/-- The target path: one backward and one forward labelled step. -/
def pathA : PlusGraphPath 2 (closA atomP) where
  back := [({PlusFormula.atom atomP, PlusFormula.top, snceP atomP}, 1)]
  mid := []
  fwd := [({PlusFormula.top, snceP atomP}, 0)]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl
    · intro ψ h
      rw [mem_closA]
      simp only [Finset.mem_insert, Finset.mem_singleton] at h
      tauto
    · intro ψ h
      rw [mem_closA]
      simp only [Finset.mem_insert, Finset.mem_singleton] at h
      tauto

/-- **The width-2 total-edge certificate** at the target `Pp → ⊡Pp`. -/
def certA : PlusSlicedCertificate ([] : PlusContext) [targetA atomP] where
  n := 2
  n_pos := by norm_num
  back := [sliceA]
  mid := []
  fwd := [sliceA]
  back_ne := List.cons_ne_nil _ _
  fwd_ne := List.cons_ne_nil _ _
  bx := fun _ => false
  target := pathA
  targetTime := 0

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 2000000 in
-- The kernel evaluates `decidableCertifies` at 16 timed positions over four window times, and
-- the `snce` liveness fixpoint inside it is the expensive part. The cap is deliberately an
-- explicit finite number rather than `0`: a regression past it must fail the build, not slow it.
/-- **The sliced class's total-edge witness**: a certificate of width above `1`, whose edge
relation is total rather than a self-loop, at a `snce`-kind closure carrying the `⊡` modality. -/
theorem certA_certifies : certA.Certifies := by decide

end TotalEdge

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
