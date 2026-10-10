/-
Probe 750 (requirement (W)'s run layer, phase 1 — the frame-scheme design verdict,
gate-compiled): **the deadline ladder has two-sided finite branching for EVERY finite object
and an infinite slice, so Probe746's positive half applies to it unchanged; and the
bounded-deadline encoding has a finite carrier, which is the shape `not_finite_width_fmp`
refutes.** This file is the machine-checked record of the design decision recorded in the
RaySummary README under "(W): what landed and what did not": obligation (i)'s frame scheme is
thread-indexed unfolding in its general form — the deadline ladder — and not a bounded-deadline
encoding.

**What this probe establishes.** The library's `RaySummary/RunLayer.lean` carries the ladder:
states `(q, c, n)` over a finite object `(Q, step, pend)`, with the current deadline `c`
counting down deterministically while pending and sitting at `0` while idle, and the next
deadline `n` drifting by at most one per step at EVERY step, so that no state ever chooses a
deadline. The headlines below are one-line corollaries of the library theorems, stated under
the probe's own names so that a future API change is tracked here rather than silently
inherited: `ladder_fwd` and `ladder_bwd` (two-sided finite branching, `Rlad_fwd`/`Rlad_bwd`),
`ladder_slice_infinite` (the slice `Q × ℕ × ℕ` is infinite, `Rlad_slice_infinite`), and
`ladder_isRegular` (the frame `ladderFrame` the library builds from the ladder through the
finitely branching sliced constructor is regular, `ladderFrame_isRegular` — whose `Saturation`
comes from `saturation_of_finBranch` with no `[Finite W]` on the carrier). Probe746's
`fib_finite_of_finBranch` therefore applies to the ladder with no change, and the regularity
part of obligation (i) goes through.

**What this probe refutes: the capped variant.** The bounded-deadline encoding — the same two
counters with a fixed cap `N` on each — has the carrier `Q × Fin (N + 1) × Fin (N + 1)`, which is
FINITE for every finite `Q` and every `N` (`capped_carrier_finite`). A sliced frame on a finite
slice is `ofSlicedStep`'s shape, and every finite-width `ofSlicedStep` model validates the
`ℤ`-time non-validity `Φ.neg` (`not_finite_width_fmp`,
`PlusSlicedCertificate/Limits/NoFiniteWidth.lean`; concretely `Probe747.modelOf_incomplete`), so
a capped ladder cannot be the run layer's frame scheme. The other bounded variant — a deadline
chosen freshly at a state — is Probe746's `Rok`/`Rbad` shape, refuted there
(`Rok_fwd_infinite`, `Rbad_bwd_infinite`): the unbounded nondeterministic choice is
infinite-branching on whichever side it fires. The ladder avoids both by carrying the counter
from `-∞` and letting it drift, which is the `Node` thread-unfolding shape of
`Limits/NoFiniteWidth.lean` in its general, many-region form.

**What this probe does NOT say.** Nothing about realization: no ladder state is claimed to
realize any closure type, nothing is said about `HitPresented` (which holds on model A,
`Probe745.hitPresented_modelA`, and is the only Hit-level positive anywhere), and no model is
constructed — that is the run layer's phase 2, whose first lemma (stabilization of realized type
sets in the deadline counter) is unproved. Nothing about `⊡(Pp)`: forward-only, no backward
Bool-fixture bridge. Seriality is NOT established: `ladderFrame` takes `fwd`/`bwd` as hypotheses
on the object, exactly as `ofSlicedStep` does. `Decidable (PlusValidZTime φ)` is NOT stated in
any form, nothing here mentions `PlusValidZTime`, and no complexity bound, upper or lower, is
claimed. `Semantics/SlicedFrame.lean`, `b2b-frame-constructor-branching.lean` and
`w-soundness-shape-refuted.lean` are untouched; this probe cites the library and re-proves
nothing.

Every declaration carries `[propext, Classical.choice, Quot.sound]` or a subset (the
`#print axioms` foot).

Compile: `lake env lean specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean`
-/
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer

namespace Probe750

open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability.RaySummary

/-- **Forward branching is finite** for every finite object: the library's `Rlad_fwd`. -/
theorem ladder_fwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    FwdFinBranch (Rlad step pend) :=
  Rlad_fwd step pend

/-- **Backward branching is finite** for every finite object: the library's `Rlad_bwd`. This
is the side `Rbad` fails, and the "no early discharge with leftover" clause of `Count` is
what keeps it finite. -/
theorem ladder_bwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    BwdFinBranch (Rlad step pend) :=
  Rlad_bwd step pend

/-- **The slice is infinite** whenever the object is inhabited: the library's
`Rlad_slice_infinite`. This is the width `not_finite_width_fmp` forces. -/
theorem ladder_slice_infinite {Q : Type} [Nonempty Q] : ¬ Finite (Q × ℕ × ℕ) :=
  Rlad_slice_infinite

/-- **The ladder frame is regular**: the library's `ladderFrame_isRegular`, with `Saturation`
from two-sided finite branching alone and no `[Finite W]` on the carrier `ℤ × (Q × ℕ × ℕ)`. -/
theorem ladder_isRegular {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, Rlad step pend t x y) (bwd : ∀ t x, ∃ y, Rlad step pend (t - 1) y x) :
    (ladderFrame step pend fwd bwd).IsRegular :=
  ladderFrame_isRegular step pend fwd bwd

/-- **The capped variant has a finite carrier.** The bounded-deadline encoding caps both counters
at `N`, so its slice is `Q × Fin (N + 1) × Fin (N + 1)` — finite for every finite `Q` and every
`N`. A sliced frame on a finite slice is `ofSlicedStep`'s finite-width shape, and every
finite-width `ofSlicedStep` model validates the `ℤ`-time non-validity `Φ.neg`
(`not_finite_width_fmp`; `Probe747.modelOf_incomplete`), so this is the shape the run layer's
frame scheme must not have. -/
theorem capped_carrier_finite (Q : Type) [Finite Q] (N : ℕ) :
    Finite (Q × Fin (N + 1) × Fin (N + 1)) :=
  inferInstance

end Probe750

#print axioms Probe750.ladder_fwd
#print axioms Probe750.ladder_bwd
#print axioms Probe750.ladder_slice_infinite
#print axioms Probe750.ladder_isRegular
#print axioms Probe750.capped_carrier_finite
