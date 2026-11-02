/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient

/-!
# The rigid anchors of a ladder history, and the agreement of class-equivalent cells

## Why the agreement is proved on its own ground

The agreement of class-equivalent cells is proved HERE, at the history level, and not as a
corollary of the soundness and completeness obligations. The reason is a compiled circularity.
The `⊡` bit of a realized type is a datum of the cell at the point's own world state
(`stab_mem_tpOf_iff_cell`, below); the acceptance condition of the certificate layer collapses
the `⊡` bits across a counter class at every certified set; and the bi-infinity condition of
that layer forbids confining a certified set to one state's cell. So discharging the acceptance
condition on any set containing a realized item already REQUIRES the agreement, and deriving the
agreement from the certificate side would close a cycle. This module therefore mentions no
certificate object at all — not the certificate conditions, not the maximum certified subset, not
the closure-component type of the certificate layer, and not the consistency bundle — and the
certificate-freedom of its `import` list and of its statements is the mechanical form of that
claim. `CounterQuotient` is imported for `kappa` and `ParamsOk` only; neither is a certificate
condition.

## What a ladder history's counters are, and what they are not

The results below are the RIGID ANCHORS of a ladder history, and they are what any replacement
argument has to respect.

* `cntAt_sub_of_pend` and `not_pend_of_count`: inside a pending region the current deadline
  counts down by exactly one per step and the region's first idle position sits at distance
  EXACTLY `cntAt g u + 1`. The countdown is not an annotation on a walk; it is the distance to
  the end of the region, forced by `Count` alone.
* `cntAt_eq_of_obj_eq`: two ladder paths with the SAME object walk carry the SAME countdown at
  every position. This is the mechanical reason a replacement argument cannot keep the object
  walk fixed and move the counters: changing the countdown at a position REQUIRES changing the
  walk, by lengthening or shortening the pending region the position sits in. It is also why the
  positionwise statement shape is refuted (`no_positionwise_lift`, compiled in the gate table)
  and the pumping form is the licensed one.
* `nxtAt_drift_le`: the next-deadline register is `1`-Lipschitz along the path, so its value at
  one position constrains its value at another only up to the distance between them. This is the
  anchor the `n` coordinate of the counter quotient reads.

## The replacement, and what it buys

Because the walk is what has to move, the replacement is performed ON the walk: `spliceObj`
repeats a segment of the object walk once and `spliceCnt` is the countdown the repeated walk
forces. A pending region at least as long as the object count carries such a segment
(`exists_objCycle_of_card_le_cnt`), its length is an object pending-cycle length and so divides
`P + 1` under `(K1)` (`exists_pumpSeg_of_card_le_cnt`), and the surgery satisfies all three local
readings of `Count` unconditionally (`spliceCnt_idle`, `spliceCnt_pend_pend`,
`spliceCnt_pend_idle`). Its payoff is `spliced_at_region`: a second ladder path through the SAME
object state whose countdown is the original's plus the cycle length — exactly the move
`cntAt_eq_of_obj_eq` forbids on a fixed walk, with the residue coordinate of `kappa` unmoved.

The lift to a ladder path carries one SIDE CONDITION, and the condition is forced rather than an
artefact: a region start's countdown IS the deadline register's value at the idle position before
it (`cntAt_eq_nxtAt_of_idle_pend`) and the register is `1`-Lipschitz, so the region-start
countdowns of EVERY ladder path are pairwise compatible (`pinCompat_of_ladderPath`). Lengthening
one region raises that one pin and moves no earlier region start, so compatibility has to be
re-established. In the pending-forever-into-the-past regime there is no earlier region start at
all and the condition discharges outright (`exists_spliced_ladderPath_of_pend_past`); in the
other regime it is carried as a hypothesis by `exists_spliced_ladderPath`, and its discharge is
the cascade the parameter condition `(K2)` sizes, which is not landed here.

## The type layer: the bridge, and what a replacement argument owes

A replacement performed on the WALK has to be read as a statement about the CELL, and the two are
stated in different languages: the replacement layer speaks of functions `ℤ → LadderState Q pend`
stepping along `RladAdm`, the cell of `WorldHistory`s of `ladderFrameAdm`. The bridge is
`exists_hist_of_isLadderPath` and `exists_isLadderPath_of_hist` — the two layers are the same
object, by `ofSlicedStepFinBranch_mem_HF_iff` at a relation whose time argument `Rlad` ignores —
and `mem_cellAt_ladder_iff` is the agreement's own object in the replacement layer's language:
the closure types realized at a ladder state are exactly those the ladder paths through it
realize, with no offset left over.

With the bridge the open half becomes a clause-by-clause question, and two of the six families
are answered. The `□` letters transfer under EVERY replacement whatsoever, because their bit
quantifies over all histories and all times and so names no path (`box_mem_tpOf_transfer`); the
ATOMIC letters read the object walk at the position and nothing else, the ladder model's
valuation ignoring the time coordinate and both counters (`atom_mem_tpOf_ladder_iff`), so they
transfer whenever the object at the position is unmoved — which is what `spliceObj_eq_of_le` says
the splice arranges (`atom_mem_tpOf_transfer_of_objAt_eq`). `⊥` and `→` are structural. What is
left is exactly the two TEMPORAL letters, whose fixpoint readings on types are landed here
(`untl_mem_tpOf_iff`, `snce_mem_tpOf_iff`) because the anchor layer stops at the four non-temporal
ones, and the `⊡` letters, whose bits are by `stab_mem_tpOf_iff_cell` data of the very cells being
compared.

For the temporal pair the index maps are not enough, and this too is compiled rather than
asserted. The spliced walk is the original read along a RETRACTION of positions
(`spliceObj_eq_objAt_spliceIdx`), which retracts a monotone embedding (`spliceEmb_monotone`,
`spliceIdx_spliceEmb`) — so a temporal witness of the original transports forward. The retraction
itself is not monotone: at the seam it drops back by the block length (`spliceIdx_seam_lt`), so a
witness of `ψ U χ` found in the second copy of the pumped block retracts to a position that need
not be later than the position being evaluated, and `untl_mem_tpOf_iff`'s right-hand side is not
transported. Closing that gap takes a statement about truth at the positions the retraction folds
together, which is the model-level pumping lemma this module does not land.

## The truth-transport layer, half (i)

The transport of a realized type between two DISTINCT ladder states is the layer the agreement
needs and the repository did not have: the only other model-level transport moves along the TIME
axis at a FIXED world state (`tpOf_timeShift`, `cellAt_eq_cellAt`). Half (i) of it is landed here
and closes on its own ground, with no parameter, no splice and no cascade: two ladder paths with
the SAME object walk satisfy the same closure formulas at every position
(`truthAt_iff_of_objAt_eq_of_stabPinned`, with `tpOf_eq_of_objAt_eq_of_pinned` on types). The
counters are what differ, and the statement is the mechanical form of the claim that they are
invisible to every clause but `⊡`. It is not vacuous: `cntAt_eq_of_obj_eq` fixes the countdown
from the walk, but the next-deadline register only has to drift, so two ladder paths can share an
object walk and differ at every position in `n` (`exists_ladderPath_pair_nxtAt_ne`).

Half (i) is stated RELATIVE to a set of pinned `⊡` letters (`StabPinned`, with the depth function
`stabDepth` and its bound on a closure) rather than for the stab-free fragment alone, because the
stab-free statement is the one shape an induction on `⊡`-nesting depth cannot consume: that
induction's step needs the transport for the letters of depth at most `d` while proving it for
depth `d + 1`. The stab-free statement is the instance `L := fun _ => False`
(`tpOf_stabFree_eq_of_objAt_eq`).

## The atom-valuation closure agreement

Half (i)'s hypothesis — the SAME object walk — is strictly stronger than anything the cell-level
route can assume, because the whole point of the alternative-history construction below is that
the two walks DIFFER at the positions the relabelling moves. What the ladder model's valuation
reads at a position is `lab` of the object component there and nothing else
(`atom_mem_tpOf_ladder_iff`), so the hypothesis the `atom` clause consumes is POINTWISE AGREEMENT
OF `lab` — `∀ v p, lab (objAt g v) p = lab (objAt g' v) p` — and it is weaker than half (i)'s by
exactly the non-injectivity of `lab`: two distinct object states with the same atom row are
indistinguishable to every clause of `PlusTruthAt` but `⊡`. At that hypothesis the transport is
landed on the fragment the route decision names, stab-free AND box-free
(`truthAt_iff_of_lab_eq_of_stabBoxFree`, with `tpOf_stabBoxFree_eq_of_lab_eq` on closure types and
`StabBoxFree` the fragment predicate, which is `StabPinned`'s shape with the `box` arm tightened to
`False` and the pinned-letter parameter dropped). Half (i) itself is reused, not re-proved: its
three statements are untouched, and it is cited as the model for the induction's shape. **Stating
this transport with the object-walk-equality hypothesis would be half (i) under a new name and
would prove nothing new**, which is recorded in the declaration's own docstring so no later round
re-derives it.

The `box` arm WIDENS, and that is a compiled result rather than an assumption. The `box` clause of
`PlusTruthAt` quantifies over every history and every time of the model and so names no path at all
(`box_mem_tpOf_transfer` is its type-level reading), and the two compared histories live in the
SAME model — that lemma's only hypothesis beyond closure membership — so the `box` case of the
induction is literally `Iff.rfl`, no hypothesis of it fails, and `□` does not have to be excluded.
The widened form is `truthAt_iff_of_lab_eq_of_stabPinned`, stated at the pinned-letter parameter so
that an induction on `⊡`-nesting depth can consume it, with `tpOf_stabFree_eq_of_lab_eq` its
stab-free type-level instance; the stab-free fragment is the one a consumer of this layer reads.
`tpOf_eq_of_altWalkPath_of_lab_eq` is the instance over the construction below — a
pend-profile-preserving relabelling that leaves every atom row alone realizes the same stab-free
closure type as the original — and it is what the alternative-history prototype's own atom-level
agreement becomes: an instance of a HYPOTHESIS rather than a statement of its own.

What this layer does NOT do is transport a type across a change of the realized valuation. The
relabelling may move the object state at a position (`altWalkPath_not_vacuous`); what it may not
move is that state's atom row. So this is not a repair of half (ii), which is refuted rather than
open: the refuted statement is about the SPLICE, which lengthens a pending region and changes which
positions exist, and no hypothesis here constrains such a surgery.

## The alternative-history freedom, and what it does and does not give

Half (ii) is refuted: the fixed surgery chosen to preserve ADMISSIBILITY is type-blind, so no
statement here transports a realized type across a change of the object walk. The
alternative-history construction (`altWalkPath`) moves in the opposite direction and is untouched
by that refutation, because it asserts no type transport at all. It holds BOTH counters fixed and
relabels the WALK: a walk agreeing with the original's PEND PROFILE at every position carries the
original path's `cntAt` and `nxtAt` verbatim — every clause of `Rlad` but the `step` clause reads
the object only through `pend` — so only the `step` clause has to be rechecked
(`altWalkPath_isLadderPath`), and at every position the relabelling leaves alone the alternative
path is at the IDENTICAL ladder state, not merely a class-equivalent one
(`altWalkPath_eq_of_objAt_eq`, stated positionwise with no finiteness anywhere).

What it gives is that a ladder state has MORE histories through it than its own path's, and hence
that the cell at that state contains the types those histories realize
(`mem_cellAt_of_altWalkPath`). The relabellings are not all the identity — `altWalkPath_not_vacuous`
exhibits a ladder path, a pend-profile-preserving relabelling and a PENDING position at which the
two paths differ — so that corollary is not a restatement of `mem_cellAt_ladder_iff`.

What it does NOT give is any type-level comparison. No claim is made that the alternative history
realizes the same type as the original; in general it does not, and the point of the construction
is that it ENLARGES the cell rather than preserving a type. In particular it is not a repair of
half (ii), it is not a conditional, narrowed or raised-`Tc` restatement of it, and it supplies no
step of an induction over a closure. What it removes is the inference from the splice-type
refutation to a cell-level obstruction: a cell is the set of types realized by ALL histories
through a state, and the refutation compares two particular histories, so it decides nothing
about the others.

## The countdown rigidity of the atom-valuation agreement, and the obligation it leaves open

The atom-valuation agreement answers how two ladder paths can realize the same stab-free type. The
cell-level route needs more than that: it needs the second path to run through a ladder state whose
COUNTER PAIR differs. That is `AtomPreservingCountMove`, the construction the route names, and this
layer compiles how far it can reach.

`cntAt_eq_of_pend_eq` sharpens `cntAt_eq_of_obj_eq` to the hypothesis its own proof consumes: the
countdown is a function of the PEND PROFILE alone, so a replacement that moves a countdown must
move the pend profile, whether or not it moves the walk. `PendFactorsLab` names the condition under
which moving the pend profile means moving an atom row — that the pending bit is recoverable from
the atom row — and `pendFactorsLab_of_atom` shows it holds as soon as the labelling carries the
pending bit as one of its atoms, which the realization statement, quantifying over every
`lab : Q → Atom → Bool`, does not exclude. Under that condition the construction's two requirements
are jointly unsatisfiable (`cntAt_eq_of_lab_eq_of_pendFactorsLab`,
`atomPreservingCountMove_refuted`). The wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` exhibits such an
object with the parameter conditions discharged at the periodicity fixpoint's own outputs, a
populated `kappa`-collision at `c ≠ c'` (through `kappa_eq_of_shift`), and a ladder path through
EACH of the two ladder states — so the obligation is non-vacuous on both sides while the
construction is unavailable. The `n` half of the construction is free, by
`exists_ladderPath_pair_nxtAt_ne`; the obstruction is confined to the `c` coordinate.

`CellLEZeroConstOfKappaEq` is the obligation itself, stated as a schema and proved NOWHERE. It is
not refuted either, and the distinction is the whole content of this layer: a cell is a set of
TYPES over all histories through a state, and two ladder paths can realize the same closure type
without agreeing on a single atom row, so a construction that does not preserve the valuation
pointwise is left entirely open. No such construction is stated anywhere in the tree and none is
invented here.

## What this module does NOT hold

* **THE AGREEMENT ITSELF IS NOT LANDED.** The statement this module exists for — that the cell at
  a pending position is constant on the classes of the counter quotient, under the parameter
  conditions — is NOT proved here and is not assumed anywhere. Its depth-`0` cell-level half is
  STATED as the schema `CellLEZeroConstOfKappaEq` and proved nowhere; a schema is not a theorem and
  no result in this module or elsewhere discharges it. What landed is the rigid-anchor
  layer above, which any proof of it has to respect, and the cell-level reading of the `⊡` bit.
  Two obstructions are on the record for it, each a consequence of what IS compiled here. The
  first obstruction of the earlier record — that by `cntAt_eq_of_obj_eq` no replacement can keep
  the object walk and move the counters, so the argument must pump the walk itself — is DISCHARGED
  by the replacement layer above: the walk-level surgery exists, it is a ladder path, and it moves
  the countdown by a divisor of `P + 1`.
  What stands is, first, that pumping the walk preserves the realized type at the position only
  through a model-level periodicity statement about truth along a ladder path, and the only landed
  periodicity statement (the backward-reachability fixpoint of the certificate graph) is a
  statement about the certificate relation, whose bridge to truth along a ladder path is exactly
  the soundness and completeness obligations that READ the agreement — so that machinery cannot be
  reused here without closing a cycle, and a model-level pumping lemma has to be authored instead.
  Second, the `⊡` bit inside a realized type is by `stab_mem_tpOf_iff_cell` a datum of the cell
  being compared, so the agreement's own proof runs by induction on `⊡`-nesting depth whatever the
  phase order is; what the history-level route buys is that the stratification is at the MODEL
  level and needs no stratified certificate family.
* **No type preservation under the replacement.** Every statement of the REPLACEMENT layer is
  about admissibility — the spliced walk is a ladder path and its counters are what `Count` forces.
  Nothing says the spliced path realizes the same closure type at the position. What the type
  layer below lands is the STATEMENT layer for that claim and a clause-by-clause audit of what it
  owes: of the six clause families of a closure type, four are settled — `⊥` and `→` structurally,
  the `□` letters under every replacement whatsoever (`box_mem_tpOf_transfer`), and the atomic
  letters whenever the object at the position is unmoved (`atom_mem_tpOf_transfer_of_objAt_eq`,
  with `spliceObj_eq_of_le` supplying the hypothesis for the splice) — and two are OPEN: the two
  temporal letters and the `⊡` letters. `spliceIdx_seam_lt` compiles the reason the index maps
  alone do not settle the temporal pair.
* **No discharge of the pin side condition outside the pending-forever regime.** The cascade that
  would re-establish pin compatibility after a region is lengthened is not landed.
* **NO SPLICE INVARIANCE — half (ii) of the transport layer is REFUTED, not merely absent.** Half
  (i) transports a type between two paths with the SAME object walk. Pumping produces a path with
  a DIFFERENT object walk, and no statement here transports a type across that difference —
  because none is true. The wired probe
  `specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean` compiles the
  separating pair: one splice DUPLICATES the pumped block, so it adds one occurrence of every
  object state of that block to the walk's future, and a nested eventuality counts occurrences at
  unbounded distance. On a three-state object whose walk hits one letter exactly once,
  `⊤ U (p ∧ ⊤ U p)` is false along the original at every position and true along the spliced path,
  with every recorded hypothesis met — `l ∣ P + 1` through `(K1)` on a compiled object `2`-cycle,
  `ParamsOk` discharged at the periodicity fixpoint's own outputs, and `T_c ≤ |a - z|` at a
  position arbitrarily far below the splice point. The refutation survives the iterated surgery the
  residue coordinate of `kappa` needs. The index maps say where the uniform-claim induction breaks
  (`spliceObj_eq_objAt_spliceIdx`, `spliceIdx_seam_lt`: the retraction drops back by the block
  length at the seam); the probe says the statement itself is false. What is refuted is that the
  FIXED surgery, chosen to preserve ADMISSIBILITY, also preserves the realized TYPE: it is
  type-blind. A type-AWARE lengthening of the region is a different construction, stated nowhere in
  the tree, and the probe neither supplies nor refutes it.
* **No `⊡`-depth induction.** `stabDepth`, `StabPinned` and their bounds are the MEASURE and the
  hypothesis shape such an induction needs; the induction itself is not stated here, and neither
  is the agreement it would carry.
* **No certificate object.** See the first paragraph. `CounterQuotient` is imported for `kappa`
  and `ParamsOk`, which the agreement statement consumes; with that statement not yet landed, the
  import is the one the module's own route declares and nothing in the results above reads it.
* **No positionwise completeness clause.** Nothing here lifts a class-level chain positionwise;
  that statement shape is refuted for every finite counter quotient.
* **NO ATOM-PRESERVING COUNTER MOVE — the construction the cell-level route named is REFUTED, not
  merely absent.** `atomPreservingCountMove_refuted` compiles that no replacement preserving the
  atom row at every position can move a countdown, for every object whose pending bit is readable
  in the language. What is refuted is the CONSTRUCTION and not the obligation: see the section
  above for the difference, which is load-bearing and not a hedge.
* **No finite-fibre and no finite-width hypothesis.** `[Finite Q]` is on the OBJECT only, and the
  admissible carrier is infinite.
* **No decision procedure and no bound.** Every quantity named is a count.
-/

-- The module crosses the package-wide `longFile` limit (`lakefile.toml`, 1500): the rigid-anchor
-- layer, the replacement layer, the alternative-history construction, the truth-transport
-- half (i), the atom-valuation agreement and the countdown rigidity of that agreement are one
-- argument about ladder paths and stay in one module.
set_option linter.style.longFile 2400

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## The `⊡` bit of a realized type is a cell-level datum -/

section Stab

variable {F : FrameOver intOrder}

/-- **The `⊡` bit of a realized type IS a cell-level datum**: `stab_mem_tpOf_iff` read through
`cellAt`. A statement about `tpOf` and `cellAt` only, which is why it belongs beside the
agreement and not in the certificate layer. -/
theorem stab_mem_tpOf_iff_cell (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) {χ : PlusFormula}
    (h : PlusFormula.stab χ ∈ plusSubformulaClosure φ) :
    PlusFormula.stab χ ∈ tpOf M φ σ z ↔ ∀ T ∈ cellAt M φ (σ.state z) z, χ ∈ T := by
  rw [stab_mem_tpOf_iff M φ σ z h]
  constructor
  · rintro H T ⟨σ', hs', rfl⟩
    exact H σ' hs'.symm
  · intro H σ' hσ'
    exact H _ ⟨σ', hσ'.symm, rfl⟩

end Stab
/-! ## The temporal fixpoint readings of a closure type

The anchor layer lands the fixpoint equations of `⊥`, `→`, `□` and `⊡` on types and stops there.
A replacement argument needs the two TEMPORAL readings as well, because what it has to compare
across a replacement is the whole type and `U`/`S` are the two letters whose bit is a statement
about other positions of the SAME path. They are the clause lemmas `PlusTruth.untl_iff` and
`PlusTruth.snce_iff` with the closure projections that keep the guard and the event inside
`plusSubformulaClosure φ`; together with the four anchor-layer equations they are the local
coherence conditions the type sequence along a path satisfies. -/

section Temporal

variable {F : FrameOver intOrder}

/-- **The closure-wide `until` equation**: `ψ U χ` is in the closure type at `(σ, z)` iff `χ` is
in the closure type at some later time of the SAME history with `ψ` in the closure type at every
time strictly between. The one letter of the type whose bit is unbounded in the future. -/
theorem untl_mem_tpOf_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) {ψ χ : PlusFormula}
    (h : PlusFormula.untl ψ χ ∈ plusSubformulaClosure φ) :
    PlusFormula.untl ψ χ ∈ tpOf M φ σ z ↔
      ∃ s : ℤ, z < s ∧ χ ∈ tpOf M φ σ s ∧
        ∀ r : ℤ, z < r → r < s → ψ ∈ tpOf M φ σ r := by
  have hev : χ ∈ plusSubformulaClosure φ := plusClosure_untl_left φ χ ψ h
  have hgd : ψ ∈ plusSubformulaClosure φ := plusClosure_untl_right φ χ ψ h
  rw [mem_tpOf_iff, PlusTruth.untl_iff]
  constructor
  · rintro ⟨-, s, hs, hχs, hr⟩
    exact ⟨s, hs, (mem_tpOf_iff M φ σ s χ).mpr ⟨hev, hχs⟩,
      fun r h1 h2 => (mem_tpOf_iff M φ σ r ψ).mpr ⟨hgd, hr r h1 h2⟩⟩
  · rintro ⟨s, hs, hχs, hr⟩
    exact ⟨h, s, hs, ((mem_tpOf_iff M φ σ s χ).mp hχs).2,
      fun r h1 h2 => ((mem_tpOf_iff M φ σ r ψ).mp (hr r h1 h2)).2⟩

/-- **The closure-wide `since` equation**: the mirror of `untl_mem_tpOf_iff` into the past. The
one letter of the type whose bit is unbounded in the past, and the letter `(K4)`'s backward
exactness depth counts. -/
theorem snce_mem_tpOf_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) {ψ χ : PlusFormula}
    (h : PlusFormula.snce ψ χ ∈ plusSubformulaClosure φ) :
    PlusFormula.snce ψ χ ∈ tpOf M φ σ z ↔
      ∃ s : ℤ, s < z ∧ χ ∈ tpOf M φ σ s ∧
        ∀ r : ℤ, s < r → r < z → ψ ∈ tpOf M φ σ r := by
  have hev : χ ∈ plusSubformulaClosure φ := plusClosure_snce_left φ χ ψ h
  have hgd : ψ ∈ plusSubformulaClosure φ := plusClosure_snce_right φ χ ψ h
  rw [mem_tpOf_iff, PlusTruth.snce_iff]
  constructor
  · rintro ⟨-, s, hs, hχs, hr⟩
    exact ⟨s, hs, (mem_tpOf_iff M φ σ s χ).mpr ⟨hev, hχs⟩,
      fun r h1 h2 => (mem_tpOf_iff M φ σ r ψ).mpr ⟨hgd, hr r h1 h2⟩⟩
  · rintro ⟨s, hs, hχs, hr⟩
    exact ⟨h, s, hs, ((mem_tpOf_iff M φ σ s χ).mp hχs).2,
      fun r h1 h2 => ((mem_tpOf_iff M φ σ r ψ).mp (hr r h1 h2)).2⟩

/-- **THE `□` LETTERS OF A TYPE TRANSFER UNDER EVERY REPLACEMENT WHATSOEVER.** `box_mem_tpOf_iff`
read as a transfer statement rather than as a fixpoint equation: the right-hand side quantifies
over every history and every time, so it names no path at all and a `□`-letter's bit is the same
at any two points of the model. This is the one clause family of the type that a replacement
argument owes nothing for, and recording it is what isolates what such an argument DOES owe: the
two temporal letters and the `⊡` letters. -/
theorem box_mem_tpOf_transfer (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ σ' : WorldHistory F.toTaskFrame) (z z' : ℤ) {ψ : PlusFormula}
    (h : PlusFormula.box ψ ∈ plusSubformulaClosure φ) :
    PlusFormula.box ψ ∈ tpOf M φ σ z ↔ PlusFormula.box ψ ∈ tpOf M φ σ' z' := by
  rw [box_mem_tpOf_iff M φ σ z h, box_mem_tpOf_iff M φ σ' z' h]

end Temporal

/-! ## The `⊡`-nesting depth, and the pinned-letter parameter

The transport statements below are not stated for the stab-free fragment alone. They carry a
parameter `L : PlusFormula → Prop` — "these `⊡` letters are already known to transport" — and hold
for every formula all of whose `⊡` subformulas satisfy `L` (`StabPinned`). The stab-free statement
is the instance `L := fun _ => False`; the instance `L := (stabDepth · ≤ d)` is what an induction
on `⊡`-nesting depth consumes at its step, and stating the transport for the stab-free fragment
alone is the one shape such an induction cannot use.

`stabDepth` is `0` on `□ψ` whatever `ψ` is, and that is deliberate: the `box` clause of
`PlusTruthAt` carries no state constraint and no history argument on its right-hand side
(`box_mem_tpOf_transfer`), so a `□` letter's bit is the same proposition at both compared points
and the depth of its argument is irrelevant to transport. -/

section Pinned

/-- **The `⊡`-nesting depth of a formula**: `0` on the atomic arms and on `□` (whose clause is
path-independent), the `max` across the three binary arms, and one more than its argument's on
`⊡`. -/
def stabDepth : PlusFormula → ℕ
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (stabDepth a) (stabDepth b)
  | .box _ => 0
  | .untl a b => max (stabDepth a) (stabDepth b)
  | .snce a b => max (stabDepth a) (stabDepth b)
  | .stab a => stabDepth a + 1

/-- **Every `⊡` subformula of this formula is pinned by `L`.** The `box` arm is `True` for the
reason `stabDepth` is `0` there: the clause names no path. The `⊡` arm asks `L` of the LETTER
`⊡χ` itself and nothing of `χ`, which is what makes the induction below one case per clause. -/
def StabPinned (L : PlusFormula → Prop) : PlusFormula → Prop
  | .atom _ => True
  | .bot => True
  | .imp a b => StabPinned L a ∧ StabPinned L b
  | .box _ => True
  | .untl a b => StabPinned L a ∧ StabPinned L b
  | .snce a b => StabPinned L a ∧ StabPinned L b
  | .stab a => L (PlusFormula.stab a)

theorem stabDepth_stab (χ : PlusFormula) : stabDepth (PlusFormula.stab χ) = stabDepth χ + 1 := rfl

/-- **A `⊡` letter of depth at most `d + 1` has its argument at depth at most `d`**: the fact an
induction on `⊡`-nesting depth steps by. -/
theorem stabDepth_arg_le_of_le_succ {χ : PlusFormula} {d : ℕ}
    (h : stabDepth (PlusFormula.stab χ) ≤ d + 1) : stabDepth χ ≤ d := by
  rw [stabDepth_stab] at h
  omega

/-- **The depth is bounded on a closure by a `φ`-determined quantity**, so an induction on
`⊡`-nesting depth over `plusSubformulaClosure φ` terminates. -/
theorem stabDepth_le_sup (φ : PlusFormula) {ψ : PlusFormula}
    (h : ψ ∈ plusSubformulaClosure φ) :
    stabDepth ψ ≤ (plusSubformulaClosure φ).sup stabDepth :=
  Finset.le_sup h

/-- **A formula of depth at most `d` has every `⊡` letter of depth at most `d`.** The bridge from
the depth bound to the pinned-letter hypothesis the transport statements take. -/
theorem stabPinned_of_stabDepth_le (d : ℕ) :
    ∀ ψ : PlusFormula, stabDepth ψ ≤ d → StabPinned (fun χ => stabDepth χ ≤ d) ψ := by
  intro ψ
  induction ψ with
  | atom p => intro _; exact trivial
  | bot => intro _; exact trivial
  | imp a b iha ihb =>
      intro h
      exact ⟨iha (le_trans (le_max_left _ _) h), ihb (le_trans (le_max_right _ _) h)⟩
  | box a _ => intro _; exact trivial
  | untl a b iha ihb =>
      intro h
      exact ⟨iha (le_trans (le_max_left _ _) h), ihb (le_trans (le_max_right _ _) h)⟩
  | snce a b iha ihb =>
      intro h
      exact ⟨iha (le_trans (le_max_left _ _) h), ihb (le_trans (le_max_right _ _) h)⟩
  | stab a _ => intro h; exact h

/-- **A closure with no `⊡` member pins every one of its formulas at `L := fun _ => False`**, which
is the stab-free instance of the transport statements. The `⊡` arm is the only one with content:
a `⊡` letter inside a closure member is itself a closure member, so a closure with none at all
leaves the arm unreachable. -/
theorem stabPinned_false_of_mem_closure {φ : PlusFormula}
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) :
    ∀ ψ ∈ plusSubformulaClosure φ, StabPinned (fun _ => False) ψ := by
  intro ψ
  induction ψ with
  | atom p => intro _; exact trivial
  | bot => intro _; exact trivial
  | imp a b iha ihb =>
      intro hm
      exact ⟨iha (plusClosure_imp_left φ a b hm), ihb (plusClosure_imp_right φ a b hm)⟩
  | box a _ => intro _; exact trivial
  | untl a b iha ihb =>
      intro hm
      exact ⟨iha (plusClosure_untl_right φ b a hm), ihb (plusClosure_untl_left φ b a hm)⟩
  | snce a b iha ihb =>
      intro hm
      exact ⟨iha (plusClosure_snce_right φ b a hm), ihb (plusClosure_snce_left φ b a hm)⟩
  | stab a _ => intro hm; exact absurd hm (hno a)

/-! ### The narrow fragment of the atom-valuation transport

The transport below takes a hypothesis strictly weaker than half (i)'s — pointwise agreement of
`lab` rather than of the object walk — and the route decision names its fragment as stab-free AND
box-free. That fragment is stated as its OWN predicate rather than as `StabPinned` with a second
parameter: `StabPinned`'s `box` arm is `True` whatever its argument and so restricts nothing, and
a parameter over `□` letters would carry no information, because the narrow fragment asks nothing
of the letter inside a `□` — it excludes the letter outright. The cheaper shape is therefore a
predicate with the `box` arm tightened to `False` and no parameter at all; that is the choice this
module records.

The narrow reading is not the last word on the `box` arm: `truthAt_iff_of_lab_eq_of_stabPinned`
below widens it and `tpOf_stabFree_eq_of_lab_eq` is the widened type-level corollary. -/

/-- **The stab-free AND box-free fragment**: `False` on `⊡` and on `□`, structural elsewhere. It is
`StabPinned`'s shape with the `box` arm TIGHTENED and the pinned-letter parameter dropped; see the
section note above for why no parameter appears. -/
def StabBoxFree : PlusFormula → Prop
  | .atom _ => True
  | .bot => True
  | .imp a b => StabBoxFree a ∧ StabBoxFree b
  | .box _ => False
  | .untl a b => StabBoxFree a ∧ StabBoxFree b
  | .snce a b => StabBoxFree a ∧ StabBoxFree b
  | .stab _ => False

/-- **The narrow fragment restricts to a closure with no `⊡` and no `□` member.** The two arms with
content are `⊡` and `□`: such a letter inside a closure member is itself a closure member, so a
closure with none at all leaves both arms unreachable. The four structural arms are the landed
closure projections and no new closure lemma is authored. -/
theorem stabBoxFree_of_mem_closure {φ : PlusFormula}
    (hnos : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (hnob : ∀ χ : PlusFormula, PlusFormula.box χ ∉ plusSubformulaClosure φ) :
    ∀ ψ ∈ plusSubformulaClosure φ, StabBoxFree ψ := by
  intro ψ
  induction ψ with
  | atom p => intro _; exact trivial
  | bot => intro _; exact trivial
  | imp a b iha ihb =>
      intro hm
      exact ⟨iha (plusClosure_imp_left φ a b hm), ihb (plusClosure_imp_right φ a b hm)⟩
  | box a _ => intro hm; exact absurd hm (hnob a)
  | untl a b iha ihb =>
      intro hm
      exact ⟨iha (plusClosure_untl_right φ b a hm), ihb (plusClosure_untl_left φ b a hm)⟩
  | snce a b iha ihb =>
      intro hm
      exact ⟨iha (plusClosure_snce_right φ b a hm), ihb (plusClosure_snce_left φ b a hm)⟩
  | stab a _ => intro hm; exact absurd hm (hnos a)

end Pinned

/-! ## The components of a ladder path

A history of `ladderFrameAdm` is exactly an offset step path of `RladAdm`
(`ofSlicedStepFinBranch_mem_HF_iff`), and `RladAdm` ignores its time argument, so every statement
below is about a function `g : ℤ → LadderState Q pend` stepping along `RladAdm`. The three
accessors name the components `Rlad` constrains. -/

section Path

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- The object component of a ladder path at a position. -/
def objAt (g : ℤ → LadderState Q pend) (u : ℤ) : Q := (g u).1.1

/-- The current-deadline component of a ladder path at a position. -/
def cntAt (g : ℤ → LadderState Q pend) (u : ℤ) : ℕ := (g u).1.2.1

/-- The next-deadline component of a ladder path at a position. -/
def nxtAt (g : ℤ → LadderState Q pend) (u : ℤ) : ℕ := (g u).1.2.2

/-- A ladder path: a function stepping along `RladAdm` at every position. The time argument is
quantified away because `RladAdm` ignores it. -/
def IsLadderPath (step : Q → Q → Bool) (pend : Q → Bool) (g : ℤ → LadderState Q pend) : Prop :=
  ∀ u : ℤ, RladAdm step pend u (g u) (g (u + 1))

/-! ### The four readings of `Count` along a path -/

/-- The step relation of a ladder path, read at the three components. -/
theorem isLadderPath_components (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) :
    step (objAt g u) (objAt g (u + 1)) = true ∧
      (pend (objAt g u) = false → cntAt g u = 0) ∧
      Drift (nxtAt g u) (nxtAt g (u + 1)) ∧
      Count (pend (objAt g u)) (pend (objAt g (u + 1))) (cntAt g u) (nxtAt g u)
        (cntAt g (u + 1)) :=
  hg u

/-- The object walk of a ladder path steps along `step`. -/
theorem objAt_step (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (u : ℤ) :
    step (objAt g u) (objAt g (u + 1)) = true := (isLadderPath_components g hg u).1

/-- An idle position of a ladder path carries countdown `0`. -/
theorem cntAt_eq_zero_of_idle (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (h : pend (objAt g u) = false) : cntAt g u = 0 :=
  (isLadderPath_components g hg u).2.1 h

/-- **The next-deadline register is `1`-Lipschitz along the path.** Its value at one position
constrains its value at another only up to the distance between them; this is the anchor the
next-deadline coordinate of the counter quotient reads. -/
theorem nxtAt_drift (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (u : ℤ) :
    Drift (nxtAt g u) (nxtAt g (u + 1)) := (isLadderPath_components g hg u).2.2.1

/-- **Pending to pending**: the countdown decreases by exactly one. -/
theorem cntAt_succ_of_pend_pend (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (hx : pend (objAt g u) = true) (hy : pend (objAt g (u + 1)) = true) :
    cntAt g (u + 1) + 1 = cntAt g u := by
  have h := (isLadderPath_components g hg u).2.2.2
  simp only [Count, hx, hy, if_true] at h
  exact h

/-- **Pending to idle**: the countdown is exhausted at the region's last pending position, and
the idle position that follows carries `0`. -/
theorem cntAt_eq_zero_of_pend_idle (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (hx : pend (objAt g u) = true) (hy : pend (objAt g (u + 1)) = false) :
    cntAt g u = 0 ∧ cntAt g (u + 1) = 0 := by
  have h := (isLadderPath_components g hg u).2.2.2
  simp only [Count, hy, Bool.false_eq_true, if_false] at h
  exact ⟨h.2 hx, h.1⟩

/-- **Idle to pending**: the new region's countdown is the next-deadline register's value at the
transition. -/
theorem cntAt_eq_nxtAt_of_idle_pend (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (hx : pend (objAt g u) = false) (hy : pend (objAt g (u + 1)) = true) :
    cntAt g (u + 1) = nxtAt g u := by
  have h := (isLadderPath_components g hg u).2.2.2
  simp only [Count, hx, hy, if_true, Bool.false_eq_true, if_false] at h
  exact h

/-! ### The rigid pending region

`cntAt g u` is the distance from `u` to the LAST pending position of the region `u` sits in, so
the region's first idle position sits at distance exactly `cntAt g u + 1`. The countdown is
therefore not free data on a walk: it is read off the walk. -/

/-- **Inside a pending region the countdown is the distance to the region's end.** For every
`j ≤ cntAt g u`, the position `u + j` is pending and carries countdown `cntAt g u - j`. -/
theorem cntAt_sub_of_pend (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (hu : pend (objAt g u) = true) :
    ∀ j : ℕ, j ≤ cntAt g u →
      pend (objAt g (u + (j : ℤ))) = true ∧ cntAt g (u + (j : ℤ)) = cntAt g u - j := by
  intro j
  induction j with
  | zero => intro _; simpa using hu
  | succ j ih =>
    intro hj
    obtain ⟨hp, hc⟩ := ih (by omega)
    have hcast : u + ((j + 1 : ℕ) : ℤ) = u + (j : ℤ) + 1 := by push_cast; ring
    have hnext : pend (objAt g (u + (j : ℤ) + 1)) = true := by
      by_contra hne
      rw [Bool.not_eq_true] at hne
      have := (cntAt_eq_zero_of_pend_idle g hg (u + (j : ℤ)) hp hne).1
      omega
    have hstep := cntAt_succ_of_pend_pend g hg (u + (j : ℤ)) hp hnext
    rw [hcast]
    exact ⟨hnext, by omega⟩

/-- **The region's first idle position sits at distance exactly `cntAt g u + 1`.** At the
region's last pending position the countdown is `0`, and `Count true true` cannot produce a
successor countdown there, so the next position is idle. -/
theorem not_pend_of_count (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) (hu : pend (objAt g u) = true) :
    pend (objAt g (u + (cntAt g u : ℤ) + 1)) = false := by
  obtain ⟨hp, hc⟩ := cntAt_sub_of_pend g hg u hu (cntAt g u) le_rfl
  by_contra hne
  rw [Bool.not_eq_false] at hne
  have := cntAt_succ_of_pend_pend g hg (u + (cntAt g u : ℤ)) hp hne
  omega

/-- **THE RIGIDITY OF THE COUNTDOWN.** Two ladder paths with the same object walk carry the same
countdown at every position. The countdown is read off the walk — at an idle position it is `0`,
and at a pending position it is the distance to the region's last pending position — so a
replacement argument that changes a countdown MUST change the walk. This is the mechanical
content of the refutation of the positionwise statement shape. -/
theorem cntAt_eq_of_obj_eq (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g')
    (hobj : ∀ v : ℤ, objAt g v = objAt g' v) (u : ℤ) : cntAt g u = cntAt g' u := by
  by_cases hu : pend (objAt g u) = true
  · have hu' : pend (objAt g' u) = true := by rw [← hobj u]; exact hu
    by_contra hne
    rcases Nat.lt_or_ge (cntAt g u) (cntAt g' u) with hlt | hge
    · have h1 := not_pend_of_count g hg u hu
      have h2 := (cntAt_sub_of_pend g' hg' u hu' (cntAt g u + 1) (by omega)).1
      rw [show u + ((cntAt g u + 1 : ℕ) : ℤ) = u + (cntAt g u : ℤ) + 1 by push_cast; ring] at h2
      rw [hobj] at h1
      rw [h1] at h2
      simp at h2
    · have hlt' : cntAt g' u < cntAt g u := by omega
      have h1 := not_pend_of_count g' hg' u hu'
      have h2 := (cntAt_sub_of_pend g hg u hu (cntAt g' u + 1) (by omega)).1
      rw [show u + ((cntAt g' u + 1 : ℕ) : ℤ) = u + (cntAt g' u : ℤ) + 1 by push_cast; ring] at h2
      rw [hobj] at h2
      rw [h1] at h2
      simp at h2
  · rw [Bool.not_eq_true] at hu
    have hu' : pend (objAt g' u) = false := by rw [← hobj u]; exact hu
    rw [cntAt_eq_zero_of_idle g hg u hu, cntAt_eq_zero_of_idle g' hg' u hu']
/-- **THE COUNTDOWN IS A FUNCTION OF THE PEND PROFILE ALONE.** The sharpening of
`cntAt_eq_of_obj_eq` the cell-level route needs: two ladder paths whose objects agree on the
PENDING BIT at every position carry the same countdown at every position, whether or not the
object states themselves agree. The proof of `cntAt_eq_of_obj_eq` already reads its hypothesis
only through `pend`, and this is that proof at the hypothesis it actually consumes;
`cntAt_eq_of_obj_eq` is left exactly as it stands.

What this buys, and what it costs. It buys the sharpest form of the rigidity: a replacement that
moves a countdown must move the PEND PROFILE, not merely the walk. It costs the route the one
freedom the alternative-history construction supplies — `altWalkPath` relabels the walk at a FIXED
pend profile (`altWalkPath_isLadderPath` takes `hpend` as a hypothesis), so by this lemma every
alternative history carries the ORIGINAL countdown everywhere, and no amount of relabelling can
reach a ladder state whose countdown differs.

Paper: — (a statement about this frame scheme's counters, with no literature counterpart) -/
theorem cntAt_eq_of_pend_eq (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g')
    (hpend : ∀ v : ℤ, pend (objAt g v) = pend (objAt g' v)) (u : ℤ) :
    cntAt g u = cntAt g' u := by
  by_cases hu : pend (objAt g u) = true
  · have hu' : pend (objAt g' u) = true := by rw [← hpend u]; exact hu
    by_contra hne
    rcases Nat.lt_or_ge (cntAt g u) (cntAt g' u) with hlt | hge
    · have h1 := not_pend_of_count g hg u hu
      have h2 := (cntAt_sub_of_pend g' hg' u hu' (cntAt g u + 1) (by omega)).1
      rw [show u + ((cntAt g u + 1 : ℕ) : ℤ) = u + (cntAt g u : ℤ) + 1 by push_cast; ring] at h2
      rw [hpend] at h1
      rw [h1] at h2
      simp at h2
    · have hlt' : cntAt g' u < cntAt g u := by omega
      have h1 := not_pend_of_count g' hg' u hu'
      have h2 := (cntAt_sub_of_pend g hg u hu (cntAt g' u + 1) (by omega)).1
      rw [show u + ((cntAt g' u + 1 : ℕ) : ℤ) = u + (cntAt g' u : ℤ) + 1 by push_cast; ring] at h2
      rw [hpend] at h2
      rw [h1] at h2
      simp at h2
  · rw [Bool.not_eq_true] at hu
    have hu' : pend (objAt g' u) = false := by rw [← hpend u]; exact hu
    rw [cntAt_eq_zero_of_idle g hg u hu, cntAt_eq_zero_of_idle g' hg' u hu']

/-! ### The window the next-deadline register imposes, and the two regimes of a pending position

The next-deadline register is `1`-Lipschitz and a region's countdown at its START is that
register's value at the idle position before it. Those two facts together bound the countdown at
any pending position whose past contains an idle position — the window `c ≤ n + 1`. Its
contrapositive is the DICHOTOMY: a pending position whose countdown exceeds its next deadline by
two or more lies on a path that is pending at every earlier position. Both regimes are populated:
the second is the thirteenth wired probe's forward-only liveness witness
(`ladder-liveness-forward-only.lean`: an admissible path pending at every past time with its
countdown growing without bound into the past), and the gap coordinate of the counter quotient is
what separates them. -/

/-- **The next-deadline register is `1`-Lipschitz over any number of steps.** `Drift` iterated. -/
theorem nxtAt_lipschitz (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u : ℤ) : ∀ j : ℕ, ((nxtAt g u : ℤ) - (nxtAt g (u + (j : ℤ)))).natAbs ≤ j := by
  intro j
  induction j with
  | zero => simp
  | succ j ih =>
    have hd := nxtAt_drift g hg (u + (j : ℤ))
    rw [show u + ((j + 1 : ℕ) : ℤ) = u + (j : ℤ) + 1 by push_cast; ring]
    simp only [Drift] at hd
    omega

/-- **The countdown counts UP into the past inside a pending run**: if every position of
`[z - j, z]` is pending then the countdown at `z - j` is `cntAt g z + j`. The backward reading of
the rigid region. -/
theorem cntAt_add_of_pend_back (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) : ∀ j : ℕ, (∀ i : ℕ, i ≤ j → pend (objAt g (z - (i : ℤ))) = true) →
      cntAt g (z - (j : ℤ)) = cntAt g z + j := by
  intro j
  induction j with
  | zero => intro _; simp
  | succ j ih =>
    intro hp
    have ihv := ih (fun i hi => hp i (by omega))
    have h1 : pend (objAt g (z - ((j + 1 : ℕ) : ℤ))) = true := hp (j + 1) le_rfl
    have h2 : pend (objAt g (z - ((j + 1 : ℕ) : ℤ) + 1)) = true := by
      rw [show z - ((j + 1 : ℕ) : ℤ) + 1 = z - (j : ℤ) by push_cast; ring]
      exact hp j (by omega)
    have hstep := cntAt_succ_of_pend_pend g hg (z - ((j + 1 : ℕ) : ℤ)) h1 h2
    rw [show z - ((j + 1 : ℕ) : ℤ) + 1 = z - (j : ℤ) by push_cast; ring] at hstep
    omega

/-- **THE WINDOW.** If a pending position has ANY idle position in its past, its countdown is at
most its next deadline plus one. The region containing it then has a start, the start's countdown
is the next-deadline register's value at the idle position before it, and the register is
`1`-Lipschitz — so the countdown cannot outrun the deadline by more than the one step the
transition itself contributes. -/
theorem cntAt_le_nxtAt_succ_of_idle_past (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z p : ℤ) (hz : pend (objAt g z) = true)
    (hp : p ≤ z) (hpi : pend (objAt g p) = false) :
    cntAt g z ≤ nxtAt g z + 1 := by
  classical
  -- the least backward distance at which the path is idle
  have hex : ∃ j : ℕ, pend (objAt g (z - (j : ℤ))) = false :=
    ⟨(z - p).toNat, by rw [show z - ((z - p).toNat : ℤ) = p by omega]; exact hpi⟩
  set j₀ := Nat.find hex with hj₀
  have hfind : pend (objAt g (z - (j₀ : ℤ))) = false := Nat.find_spec hex
  have hlt : ∀ i : ℕ, i < j₀ → pend (objAt g (z - (i : ℤ))) = true := by
    intro i hi
    have := Nat.find_min hex (m := i) (by omega)
    rw [Bool.not_eq_false] at this
    exact this
  have hj₀pos : 0 < j₀ := by
    rcases Nat.eq_zero_or_pos j₀ with h | h
    · exfalso
      rw [h, show z - ((0 : ℕ) : ℤ) = z by push_cast; ring] at hfind
      exact Bool.false_ne_true (hfind.symm.trans hz)
    · exact h
  -- the region start sits at `z - (j₀ - 1)`
  set d := j₀ - 1 with hd
  have hdj : j₀ = d + 1 := by omega
  have hrun : ∀ i : ℕ, i ≤ d → pend (objAt g (z - (i : ℤ))) = true :=
    fun i hi => hlt i (by omega)
  have hcnt : cntAt g (z - (d : ℤ)) = cntAt g z + d := cntAt_add_of_pend_back g hg z d hrun
  -- the start's countdown is the register's value at the idle position before it
  have hstart : pend (objAt g (z - (j₀ : ℤ)) ) = false := hfind
  have hsucc : z - (j₀ : ℤ) + 1 = z - (d : ℤ) := by rw [hdj]; push_cast; ring
  have hpd : pend (objAt g (z - (j₀ : ℤ) + 1)) = true := by
    rw [hsucc]; exact hrun d le_rfl
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg (z - (j₀ : ℤ)) hstart hpd
  rw [hsucc] at hpin
  -- the register is `1`-Lipschitz from that idle position up to `z`
  have hlip := nxtAt_lipschitz g hg (z - (j₀ : ℤ)) j₀
  rw [show z - (j₀ : ℤ) + (j₀ : ℤ) = z by ring] at hlip
  omega

/-- **THE DICHOTOMY.** The contrapositive of the window: a pending position whose countdown
exceeds its next deadline by two or more lies on a path that is pending at EVERY earlier
position. Such paths exist — the thirteenth wired probe's witness is one — so this is a genuine
second regime and not a vacuous case, and the gap coordinate of the counter quotient is what
separates the two. -/
theorem pend_past_of_nxtAt_lt (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) (hz : pend (objAt g z) = true) (hgap : nxtAt g z + 2 ≤ cntAt g z) :
    ∀ p : ℤ, p ≤ z → pend (objAt g p) = true := by
  intro p hp
  by_contra hne
  rw [Bool.not_eq_true] at hne
  have := cntAt_le_nxtAt_succ_of_idle_past g hg z p hz hp hne
  omega

/-! ### What a class collision of the counter quotient actually says

The three lemmas below read a collision of the class map off its coordinates. The last is the one
that matters for the two regimes above: at `2 ≤ B` — which `(K4)` requires — a collision at a
FIXED next deadline cannot straddle the window and the pending-forever regime. It puts both
counter values on the same side, so a replacement argument may be given separately in the two
regimes and never has to carry a path from one into the other. This is the gap coordinate's own
content, and it is why `(K4)`'s `2 ≤ B` is not cosmetic. -/

/-- A collision of the class map, read coordinate by coordinate. -/
theorem kappa_eq_components (Tc Tn P B c n c' n' : ℕ)
    (h : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) :
    min c Tc = min c' Tc ∧ c % (P + 1) = c' % (P + 1) ∧
      min n Tn = min n' Tn ∧ n % (P + 1) = n' % (P + 1) ∧
      clipIdx B c n = clipIdx B c' n' := by
  simp only [kappa, Prod.mk.injEq, Fin.mk.injEq] at h
  exact ⟨h.1, h.2.1, h.2.2.1, h.2.2.2.1, h.2.2.2.2⟩

/-- **The clipped coordinate is an EXACT reading below its threshold.** A collision at the
clipped countdown coordinate either pins the two values equal or puts both at or above the
threshold — there is no third case, which is why the threshold separates the small countdowns
exactly and the pumping regime begins at `Tc`. -/
theorem eq_or_both_ge_of_min_eq (T a b : ℕ) (h : min a T = min b T) :
    a = b ∨ (T ≤ a ∧ T ≤ b) := by omega

/-- **THE GAP COORDINATE SEGREGATES THE TWO REGIMES.** At `2 ≤ B` a collision of the gap
coordinate at a fixed next deadline forces both countdowns into the SAME regime of
`cntAt_le_nxtAt_succ_of_idle_past`/`pend_past_of_nxtAt_lt`: either the larger one still lies
inside the window `c ≤ n`, or the smaller one already exceeds the deadline by two. A collision
straddling the two — one state reachable with an idle position in its past and the other only by
a path pending forever into the past — is therefore impossible, and that is what keeps the two
regimes from having to be related to each other. -/
theorem clipIdx_regime_of_eq (B c c' n : ℕ) (hB : 2 ≤ B) (hlt : c < c')
    (h : clipIdx B c n = clipIdx B c' n) : c' ≤ n ∨ n + 2 ≤ c := by
  unfold clipIdx at h
  split at h <;> split at h <;> omega

/-! ### The saturated segment of a long pending region

The replacement argument of the pumping form needs a segment it may repeat. Inside a pending
region the walk is forced to stay pending (`cntAt_sub_of_pend`), so a region at least as long as
the object count revisits an object state, and the segment between the two visits is a cycle of
the OBJECT's own pending graph. Its length is therefore one of the lengths `(K1)` requires to
divide `P + 1`, which is what puts a repeated segment in the same residue class mod `P`. -/

/-- **A repeated object state inside a pending region yields an object cycle.** The periodic
walk `k ↦ objAt g (u + i + (k % l))` steps along `step`, is pending throughout because the whole
segment lies inside the region, and closes up at `l` because the two visits agree. -/
theorem objCycleLens_of_segment [Fintype Q] (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (u : ℤ) (hu : pend (objAt g u) = true)
    (i l : ℕ) (hl : 0 < l) (hle : i + l ≤ cntAt g u)
    (hrep : objAt g (u + (i : ℤ)) = objAt g (u + (i : ℤ) + (l : ℤ)))
    (hcard : l ≤ Fintype.card Q) :
    l ∈ objCycleLens step pend := by
  refine ⟨hl, hcard, fun k => objAt g (u + (i : ℤ) + ((k % l : ℕ) : ℤ)), ?_, ?_, ?_⟩
  · intro k
    dsimp only
    have hmod : k % l < l := Nat.mod_lt _ hl
    have hs : (k + 1) % l = (k % l + 1) % l := (Nat.mod_add_mod k l 1).symm
    by_cases hlast : k % l + 1 = l
    · -- the wrap-around step: the segment's last position steps to the segment's first
      have hk1 : (k + 1) % l = 0 := by rw [hs, hlast, Nat.mod_self]
      have hstep := objAt_step g hg (u + (i : ℤ) + ((k % l : ℕ) : ℤ))
      have hcast : ((k % l : ℕ) : ℤ) + 1 = (l : ℤ) := by exact_mod_cast hlast
      rw [show u + (i : ℤ) + ((k % l : ℕ) : ℤ) + 1 = u + (i : ℤ) + (l : ℤ) by
        rw [← hcast]; ring] at hstep
      rw [hk1, Nat.cast_zero, add_zero, hrep]
      exact hstep
    · -- an interior step of the segment
      have hk1 : (k + 1) % l = k % l + 1 := by
        rw [hs, Nat.mod_eq_of_lt (by omega)]
      have hstep := objAt_step g hg (u + (i : ℤ) + ((k % l : ℕ) : ℤ))
      rw [hk1, show ((k % l + 1 : ℕ) : ℤ) = ((k % l : ℕ) : ℤ) + 1 by push_cast; ring,
        ← add_assoc]
      exact hstep
  · intro k
    dsimp only
    have hmod : k % l < l := Nat.mod_lt _ hl
    have hp := (cntAt_sub_of_pend g hg u hu (i + k % l) (by omega)).1
    rw [show u + ((i + k % l : ℕ) : ℤ) = u + (i : ℤ) + ((k % l : ℕ) : ℤ) by push_cast; ring] at hp
    exact hp
  · dsimp only
    rw [Nat.mod_self, Nat.zero_mod]

/-- **A pending region at least as long as the object count carries an object cycle.** The
pigeonhole on the `Fintype.card Q + 1` positions `u, …, u + Fintype.card Q`, all pending because
the region is that long, with the cycle exhibited as a periodic walk so that its length lands in
`objCycleLens`. -/
theorem exists_objCycle_of_card_le_cnt [Fintype Q] (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (u : ℤ) (hu : pend (objAt g u) = true)
    (hlen : Fintype.card Q ≤ cntAt g u) :
    ∃ i l : ℕ, 0 < l ∧ l ≤ Fintype.card Q ∧ i + l ≤ cntAt g u ∧
      objAt g (u + (i : ℤ)) = objAt g (u + (i : ℤ) + (l : ℤ)) ∧
      l ∈ objCycleLens step pend := by
  classical
  -- every position at distance at most `cntAt g u` is pending
  have hpend : ∀ j : ℕ, j ≤ cntAt g u → pend (objAt g (u + (j : ℤ))) = true :=
    fun j hj => (cntAt_sub_of_pend g hg u hu j hj).1
  -- the pigeonhole on one more position than the object has states
  have hcard : Fintype.card Q < Fintype.card (Fin (Fintype.card Q + 1)) := by
    simp
  obtain ⟨a, b, hab, hfe⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun k : Fin (Fintype.card Q + 1) =>
      objAt g (u + ((k : ℕ) : ℤ))) hcard
  -- orient the pair
  rcases lt_or_gt_of_ne (fun h : (a : ℕ) = (b : ℕ) => hab (Fin.ext h)) with hlt | hlt
  · refine ⟨(a : ℕ), (b : ℕ) - (a : ℕ), by omega, by omega, by
      have hb : (b : ℕ) ≤ Fintype.card Q := by omega
      omega, ?_, ?_⟩
    · rw [show u + ((a : ℕ) : ℤ) + (((b : ℕ) - (a : ℕ) : ℕ) : ℤ) = u + ((b : ℕ) : ℤ) by
        have : ((a : ℕ) : ℤ) ≤ ((b : ℕ) : ℤ) := by exact_mod_cast le_of_lt hlt
        push_cast [Nat.cast_sub (le_of_lt hlt)]
        ring]
      exact hfe
    · exact objCycleLens_of_segment g hg u hu (a : ℕ) ((b : ℕ) - (a : ℕ)) (by omega)
        (by have hb : (b : ℕ) ≤ Fintype.card Q := by omega
            omega)
        (by rw [show u + ((a : ℕ) : ℤ) + (((b : ℕ) - (a : ℕ) : ℕ) : ℤ) = u + ((b : ℕ) : ℤ) by
              push_cast [Nat.cast_sub (le_of_lt hlt)]
              ring]
            exact hfe)
        (by have hb : (b : ℕ) ≤ Fintype.card Q := by omega
            omega)
  · refine ⟨(b : ℕ), (a : ℕ) - (b : ℕ), by omega, by omega, by
      have ha : (a : ℕ) ≤ Fintype.card Q := by omega
      omega, ?_, ?_⟩
    · rw [show u + ((b : ℕ) : ℤ) + (((a : ℕ) - (b : ℕ) : ℕ) : ℤ) = u + ((a : ℕ) : ℤ) by
        push_cast [Nat.cast_sub (le_of_lt hlt)]
        ring]
      exact hfe.symm
    · exact objCycleLens_of_segment g hg u hu (b : ℕ) ((a : ℕ) - (b : ℕ)) (by omega)
        (by have ha : (a : ℕ) ≤ Fintype.card Q := by omega
            omega)
        (by rw [show u + ((b : ℕ) : ℤ) + (((a : ℕ) - (b : ℕ) : ℕ) : ℤ) = u + ((a : ℕ) : ℤ) by
              push_cast [Nat.cast_sub (le_of_lt hlt)]
              ring]
            exact hfe.symm)
        (by have ha : (a : ℕ) ≤ Fintype.card Q := by omega
            omega)

/-- **The cycle a long pending region carries divides `P + 1`.** `(K1)`'s object conjunct read
on the cycle `exists_objCycle_of_card_le_cnt` exhibits: this is what puts a repeated segment in
the same residue class mod `P`, and it is the only place the parameter conditions enter the
replacement construction. -/
theorem objCycle_dvd_succ_of_paramsOk [Fintype Q] (lab : Q → Atom → Bool) (φ : PlusFormula)
    {Tc Tn P B : ℕ} (hp : ParamsOk step pend lab φ Tc Tn P B)
    {l : ℕ} (hl : l ∈ objCycleLens step pend) : l ∣ (P + 1) :=
  hp.1.2.1 l hl

/-- **The pumping length of a long pending region.** `exists_objCycle_of_card_le_cnt` and
`objCycle_dvd_succ_of_paramsOk` composed: a region at least as long as the object count carries a
segment whose repetition changes the region's length by a divisor of `P + 1`, hence leaves the
residue coordinate of `kappa` fixed. -/
theorem exists_pumpSeg_of_card_le_cnt [Fintype Q] (lab : Q → Atom → Bool) (φ : PlusFormula)
    {Tc Tn P B : ℕ} (hp : ParamsOk step pend lab φ Tc Tn P B)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (u : ℤ)
    (hu : pend (objAt g u) = true) (hlen : Fintype.card Q ≤ cntAt g u) :
    ∃ i l : ℕ, 0 < l ∧ i + l ≤ cntAt g u ∧
      objAt g (u + (i : ℤ)) = objAt g (u + (i : ℤ) + (l : ℤ)) ∧ l ∣ (P + 1) := by
  obtain ⟨i, l, hl, _, hle, hrep, hmem⟩ := exists_objCycle_of_card_le_cnt g hg u hu hlen
  exact ⟨i, l, hl, hle, hrep, objCycle_dvd_succ_of_paramsOk lab φ hp hmem⟩

/-! ### The replacement: the segment repeated once

`spliceObj` repeats the segment `[a, a + l)` of the object walk once, and `spliceCnt` is the
countdown the repeated walk forces. The three local readings of `Count` hold unconditionally
(`spliceCnt_idle`, `spliceCnt_pend_pend`, `spliceCnt_pend_idle`): the surgery is locally
admissible wherever it is performed, and `spliceCnt_add_of_mem_region` is its payoff — the
countdown at a position of the spliced region is the original's plus `l`, EXACTLY, which is the
move `cntAt_eq_of_obj_eq` says cannot be made without changing the walk.

What is NOT unconditional is the deadline register. The region-start values of a ladder path are
PINNED (`cntAt_eq_nxtAt_of_idle_pend`) and the register is `1`-Lipschitz (`nxtAt_drift`), so the
pins of any ladder path are pairwise compatible — and lengthening one region by `l` while leaving
every earlier region start where it is raises that one pin by `l` without moving the pins it must
stay compatible with. The compatibility is therefore a genuine SIDE CONDITION on the surgery,
carried explicitly by `spliceLift_of_pinCompat` below rather than discharged here. -/

section Splice

variable (g : ℤ → LadderState Q pend) (a : ℤ) (l : ℕ)

/-- The object walk with the segment `[a, a + l)` repeated once: unchanged below `a + l`, and the
original read `l` positions earlier from `a + l` on. -/
def spliceObj : ℤ → Q :=
  fun v => objAt g (if v < a + (l : ℤ) then v else v - (l : ℤ))

/-- The countdown the spliced walk forces: raised by `l` inside the lengthened region, unchanged
in the regions that end before the splice point, and the original's `l` positions earlier from
`a + l` on. -/
def spliceCnt : ℤ → ℕ :=
  fun v => if v < a + (l : ℤ) then
      (if a ≤ v + (cntAt g v : ℤ) then cntAt g v + l else cntAt g v)
    else cntAt g (v - (l : ℤ))

variable {g a l}

theorem spliceObj_of_lt (v : ℤ) (h : v < a + (l : ℤ)) : spliceObj g a l v = objAt g v := by
  simp only [spliceObj, if_pos h]

theorem spliceObj_of_ge (v : ℤ) (h : a + (l : ℤ) ≤ v) :
    spliceObj g a l v = objAt g (v - (l : ℤ)) := by
  simp only [spliceObj, if_neg (by omega : ¬ v < a + (l : ℤ))]

theorem spliceCnt_of_lt (v : ℤ) (h : v < a + (l : ℤ)) :
    spliceCnt g a l v =
      (if a ≤ v + (cntAt g v : ℤ) then cntAt g v + l else cntAt g v) := by
  simp only [spliceCnt, if_pos h]

theorem spliceCnt_of_ge (v : ℤ) (h : a + (l : ℤ) ≤ v) :
    spliceCnt g a l v = cntAt g (v - (l : ℤ)) := by
  simp only [spliceCnt, if_neg (by omega : ¬ v < a + (l : ℤ))]

/-- Inside the spliced segment the original walk is pending and its countdown is the distance to
the region's end. The segment is `[a, a + l]`, which lies inside `a`'s region because
`l ≤ cntAt g a`. -/
theorem spliceSeg (hg : IsLadderPath step pend g) (hpa : pend (objAt g a) = true)
    (hcl : l ≤ cntAt g a)
    (v : ℤ) (h1 : a ≤ v) (h2 : v ≤ a + (l : ℤ)) :
    pend (objAt g v) = true ∧ (cntAt g v : ℤ) + (v - a) = (cntAt g a : ℤ) := by
  obtain ⟨hp, hc⟩ := cntAt_sub_of_pend g hg a hpa (v - a).toNat (by omega)
  rw [show a + (((v - a).toNat : ℕ) : ℤ) = v by omega] at hp hc
  exact ⟨hp, by omega⟩

/-- **The spliced walk steps along `step`.** The only new step is the wrap-around at `a + l`,
where the repeated segment closes up: `objAt g (a + l - 1)` steps to `objAt g (a + l)`, which is
`objAt g a` by the repetition hypothesis. -/
theorem spliceObj_step (hg : IsLadderPath step pend g)
    (hrep : objAt g a = objAt g (a + (l : ℤ))) (v : ℤ) :
    step (spliceObj g a l v) (spliceObj g a l (v + 1)) = true := by
  rcases lt_trichotomy (v + 1) (a + (l : ℤ)) with hv | hv | hv
  · rw [spliceObj_of_lt v (by omega), spliceObj_of_lt (v + 1) hv]
    exact objAt_step g hg v
  · rw [spliceObj_of_lt v (by omega), spliceObj_of_ge (v + 1) (by omega),
      show v + 1 - (l : ℤ) = a by omega, hrep]
    have h := objAt_step g hg v
    rw [show v + 1 = a + (l : ℤ) from hv] at h
    exact h
  · rw [spliceObj_of_ge v (by omega), spliceObj_of_ge (v + 1) (by omega),
      show v + 1 - (l : ℤ) = v - (l : ℤ) + 1 by ring]
    exact objAt_step g hg (v - (l : ℤ))

/-- **The spliced countdown is idle-zero**: the first local reading of `Count`. -/
theorem spliceCnt_idle (hg : IsLadderPath step pend g)
    (hpa : pend (objAt g a) = true) (hcl : l ≤ cntAt g a)
    (v : ℤ) (h : pend (spliceObj g a l v) = false) : spliceCnt g a l v = 0 := by
  rcases lt_or_ge v (a + (l : ℤ)) with hv | hv
  · rw [spliceObj_of_lt v hv] at h
    have hlt : v < a := by
      by_contra hge
      exact Bool.false_ne_true (h.symm.trans (spliceSeg hg hpa hcl v (by omega) (by omega)).1)
    have hz : cntAt g v = 0 := cntAt_eq_zero_of_idle g hg v h
    rw [spliceCnt_of_lt v hv, if_neg (by omega : ¬ a ≤ v + (cntAt g v : ℤ)), hz]
  · rw [spliceObj_of_ge v hv] at h
    rw [spliceCnt_of_ge v hv]
    exact cntAt_eq_zero_of_idle g hg _ h

/-- **The spliced countdown counts down inside a region**: the second local reading of `Count`.
The one new transition is at `a + l`, where the countdown resumes at `cntAt g a` — exactly one
more than the value `cntAt g (a + l - 1) + l` the repeated segment's last position carries. -/
theorem spliceCnt_pend_pend (hg : IsLadderPath step pend g) (hl : 0 < l)
    (hpa : pend (objAt g a) = true) (hcl : l ≤ cntAt g a)
    (v : ℤ) (hx : pend (spliceObj g a l v) = true) (hy : pend (spliceObj g a l (v + 1)) = true) :
    spliceCnt g a l (v + 1) + 1 = spliceCnt g a l v := by
  rcases lt_trichotomy (v + 1) (a + (l : ℤ)) with hv | hv | hv
  · rw [spliceObj_of_lt v (by omega)] at hx
    rw [spliceObj_of_lt (v + 1) hv] at hy
    have hstep := cntAt_succ_of_pend_pend g hg v hx hy
    rw [spliceCnt_of_lt v (by omega), spliceCnt_of_lt (v + 1) hv]
    by_cases hc : a ≤ v + (cntAt g v : ℤ)
    · rw [if_pos hc, if_pos (by omega : a ≤ v + 1 + (cntAt g (v + 1) : ℤ))]
      omega
    · rw [if_neg hc, if_neg (by omega : ¬ a ≤ v + 1 + (cntAt g (v + 1) : ℤ))]
      omega
  · have hva : v = a + (l : ℤ) - 1 := by omega
    have hseg := spliceSeg hg hpa hcl v (by omega) (by omega)
    rw [spliceCnt_of_lt v (by omega), spliceCnt_of_ge (v + 1) (by omega),
      show v + 1 - (l : ℤ) = a by omega, if_pos (by omega : a ≤ v + (cntAt g v : ℤ))]
    omega
  · rw [spliceObj_of_ge v (by omega)] at hx
    rw [spliceObj_of_ge (v + 1) (by omega)] at hy
    rw [show v + 1 - (l : ℤ) = v - (l : ℤ) + 1 by ring] at hy
    have hstep := cntAt_succ_of_pend_pend g hg (v - (l : ℤ)) hx hy
    rw [spliceCnt_of_ge v (by omega), spliceCnt_of_ge (v + 1) (by omega),
      show v + 1 - (l : ℤ) = v - (l : ℤ) + 1 by ring]
    exact hstep

/-- **The spliced countdown is exhausted at a region end**: the third local reading of `Count`.
The transition at `a + l` is never a region end, because the repeated segment's first position is
pending. -/
theorem spliceCnt_pend_idle (hg : IsLadderPath step pend g)
    (hpa : pend (objAt g a) = true) (hcl : l ≤ cntAt g a)
    (v : ℤ) (hx : pend (spliceObj g a l v) = true)
    (hy : pend (spliceObj g a l (v + 1)) = false) : spliceCnt g a l v = 0 := by
  rcases lt_trichotomy (v + 1) (a + (l : ℤ)) with hv | hv | hv
  · rw [spliceObj_of_lt v (by omega)] at hx
    rw [spliceObj_of_lt (v + 1) hv] at hy
    have hlt : v + 1 < a := by
      by_contra hge
      exact Bool.false_ne_true
        (hy.symm.trans (spliceSeg hg hpa hcl (v + 1) (by omega) (by omega)).1)
    have hz : cntAt g v = 0 := (cntAt_eq_zero_of_pend_idle g hg v hx hy).1
    rw [spliceCnt_of_lt v (by omega), if_neg (by omega : ¬ a ≤ v + (cntAt g v : ℤ)), hz]
  · exfalso
    rw [spliceObj_of_ge (v + 1) (by omega), show v + 1 - (l : ℤ) = a by omega] at hy
    exact Bool.false_ne_true (hy.symm.trans hpa)
  · rw [spliceObj_of_ge v (by omega)] at hx
    rw [spliceObj_of_ge (v + 1) (by omega), show v + 1 - (l : ℤ) = v - (l : ℤ) + 1 by ring] at hy
    rw [spliceCnt_of_ge v (by omega)]
    exact (cntAt_eq_zero_of_pend_idle g hg (v - (l : ℤ)) hx hy).1

/-- **THE PAYOFF OF THE SPLICE.** At a position of the lengthened region the spliced countdown is
the original's plus `l`, EXACTLY. This is the move `cntAt_eq_of_obj_eq` forbids on a fixed object
walk, and the reason the replacement has to be performed on the walk: the countdown coordinate of
`kappa` is shifted by exactly the cycle length, which `objCycle_dvd_succ_of_paramsOk` puts in
`P + 1`'s divisors, so the residue coordinate is unmoved. -/
theorem spliceCnt_add_of_mem_region (hl : 0 < l) (v : ℤ) (hv : v ≤ a)
    (hreg : a ≤ v + (cntAt g v : ℤ)) : spliceCnt g a l v = cntAt g v + l := by
  rw [spliceCnt_of_lt v (by omega), if_pos hreg]

/-- **The object of the splice is unmoved below the splice point**, so a position at or before
`a` keeps its object state while its countdown moves. -/
theorem spliceObj_eq_of_le (hl : 0 < l) (v : ℤ) (hv : v ≤ a) :
    spliceObj g a l v = objAt g v :=
  spliceObj_of_lt v (by omega)

end Splice

/-! ### The pins of a ladder path are pairwise compatible

The region-start countdowns of a ladder path are the deadline register's values at the idle
positions before them, and the register is `1`-Lipschitz, so they are pairwise compatible. This
is a NECESSARY condition on every ladder path, not a convenience of the lift lemma's shape, and
it is what makes the pin side condition of the splice a real obstruction rather than an artefact. -/

/-- **The deadline register is `1`-Lipschitz between any two positions**, in either order. -/
theorem nxtAt_lipschitz_two_sided (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (u v : ℤ) : ((nxtAt g u : ℤ) - nxtAt g v).natAbs ≤ (u - v).natAbs := by
  rcases le_total u v with h | h
  · have hlip := nxtAt_lipschitz g hg u (v - u).toNat
    rw [show u + (((v - u).toNat : ℕ) : ℤ) = v by omega] at hlip
    omega
  · have hlip := nxtAt_lipschitz g hg v (u - v).toNat
    rw [show v + (((u - v).toNat : ℕ) : ℤ) = u by omega] at hlip
    omega

/-- **THE PINS OF A LADDER PATH ARE PAIRWISE COMPATIBLE.** Two region starts carry countdowns
differing by at most the distance between them. The forced form of the lift lemma's own pin
hypothesis, proved here on an arbitrary ladder path. -/
theorem pinCompat_of_ladderPath (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (s v : ℤ) (hs0 : pend (objAt g s) = false) (hs1 : pend (objAt g (s + 1)) = true)
    (hv0 : pend (objAt g v) = false) (hv1 : pend (objAt g (v + 1)) = true) :
    ((cntAt g (s + 1) : ℤ) - cntAt g (v + 1)).natAbs ≤ (s - v).natAbs := by
  rw [cntAt_eq_nxtAt_of_idle_pend g hg s hs0 hs1, cntAt_eq_nxtAt_of_idle_pend g hg v hv0 hv1]
  exact nxtAt_lipschitz_two_sided g hg s v

/-! ### The lift of a walk to a ladder path, and the spliced path

`exists_rlad_hist_of_walk` (`RunLayer.lean`, Phase 7's promoted lift half) builds the deadline
register from the pins a walk already carries. `exists_ladderPath_of_walk` repackages it on the
admissible carrier, and `exists_spliced_ladderPath` applies it to the splice.

The two pin hypotheses are the surgery's SIDE CONDITION and are carried explicitly. They are not
an artefact of the lift lemma's shape: a region start's countdown IS the register's value at the
idle position before it (`cntAt_eq_nxtAt_of_idle_pend`) and the register is `1`-Lipschitz
(`nxtAt_drift`), so pairwise compatibility of the region-start countdowns is NECESSARY for any
ladder path whatsoever. Lengthening one region by `l` raises that one pin by `l` and moves no
earlier region start, so the condition is not automatic and the surgery is not free: the
preceding idle runs have to be lengthened with it, which is the cascade the parameter condition
`(K2)` sizes and which this phase does not land. -/

/-- **The lift of a walk with its forced countdown to a ladder path on the admissible carrier.**
`exists_rlad_hist_of_walk` with the admissibility proof read off the idle-zero clause. -/
theorem exists_ladderPath_of_walk (w : ℤ → Q) (c : ℤ → ℕ) (n₀ : ℕ)
    (hw : ∀ v, step (w v) (w (v + 1)) = true)
    (hidle : ∀ v, pend (w v) = false → c v = 0)
    (hpp : ∀ v, pend (w v) = true → pend (w (v + 1)) = true → c (v + 1) + 1 = c v)
    (hpi : ∀ v, pend (w v) = true → pend (w (v + 1)) = false → c v = 0)
    (hpins : ∀ s v, pend (w s) = false → pend (w (s + 1)) = true →
      pend (w v) = false → pend (w (v + 1)) = true →
      ((c (s + 1) : ℤ) - c (v + 1)).natAbs ≤ (s - v).natAbs)
    (hn₀ : ∀ v, pend (w v) = false → pend (w (v + 1)) = true →
      ((c (v + 1) : ℤ) - n₀).natAbs ≤ v.natAbs) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = w v) ∧ (∀ v, cntAt g' v = c v) := by
  obtain ⟨n, _, hR⟩ :=
    exists_rlad_hist_of_walk step pend 0 w c n₀ hw hidle hpp hpi hpins hn₀
  refine ⟨fun v => ⟨(w v, c v, n v), fun h => hidle v h⟩, fun v => hR v, fun _ => rfl,
    fun _ => rfl⟩

section Splice

variable {g : ℤ → LadderState Q pend} {a : ℤ} {l : ℕ}

/-- **THE ADMISSIBILITY HALF OF THE PUMPING REPLACEMENT.** Under the pin side condition the
spliced walk lifts to a ladder path whose object walk is the splice and whose countdown is the
spliced countdown. Nothing here says the realized TYPE is preserved: that is the model-level half
and it is not landed. -/
theorem exists_spliced_ladderPath (hg : IsLadderPath step pend g) (hl : 0 < l)
    (hpa : pend (objAt g a) = true) (hcl : l ≤ cntAt g a)
    (hrep : objAt g a = objAt g (a + (l : ℤ))) (n₀ : ℕ)
    (hpins : ∀ s v, pend (spliceObj g a l s) = false → pend (spliceObj g a l (s + 1)) = true →
      pend (spliceObj g a l v) = false → pend (spliceObj g a l (v + 1)) = true →
      ((spliceCnt g a l (s + 1) : ℤ) - spliceCnt g a l (v + 1)).natAbs ≤ (s - v).natAbs)
    (hn₀ : ∀ v, pend (spliceObj g a l v) = false → pend (spliceObj g a l (v + 1)) = true →
      ((spliceCnt g a l (v + 1) : ℤ) - n₀).natAbs ≤ v.natAbs) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = spliceObj g a l v) ∧ (∀ v, cntAt g' v = spliceCnt g a l v) :=
  exists_ladderPath_of_walk (spliceObj g a l) (spliceCnt g a l) n₀
    (spliceObj_step hg hrep) (spliceCnt_idle hg hpa hcl)
    (spliceCnt_pend_pend hg hl hpa hcl) (spliceCnt_pend_idle hg hpa hcl) hpins hn₀

/-- **The spliced path moves the countdown at a position of the region by exactly the cycle
length, and leaves its object state alone.** The conjunction `exists_spliced_ladderPath` buys at
the position the agreement compares: a second ladder path through the SAME object state with the
countdown shifted by `l`. Its residue mod `P + 1` is unmoved whenever `l ∣ P + 1`, which
`objCycle_dvd_succ_of_paramsOk` supplies. -/
theorem spliced_at_region {g' : ℤ → LadderState Q pend} (hl : 0 < l)
    (hobj : ∀ v, objAt g' v = spliceObj g a l v) (hcnt : ∀ v, cntAt g' v = spliceCnt g a l v)
    (v : ℤ) (hv : v ≤ a) (hreg : a ≤ v + (cntAt g v : ℤ)) :
    objAt g' v = objAt g v ∧ cntAt g' v = cntAt g v + l := by
  refine ⟨?_, ?_⟩
  · rw [hobj v, spliceObj_eq_of_le hl v hv]
  · rw [hcnt v, spliceCnt_add_of_mem_region hl v hv hreg]

/-! ### The pending-forever regime discharges the side condition

In the second regime of the dichotomy — the path is pending at every position at or before the
splice point, the regime `pend_past_of_nxtAt_lt` populates and `clipIdx_regime_of_eq` keeps a
class collision inside — the spliced walk has NO region start below `a + l`, and every region
start above it is the original's own start displaced by exactly `l`. The pins therefore keep the
original's compatibility, which `pinCompat_of_ladderPath` supplies, and the surgery is admissible
with no side condition at all. -/

/-- Below the splice point a pending-forever past leaves the spliced walk pending throughout: at
or before `a` by the regime hypothesis, and inside the repeated segment because the segment lies
inside the region. -/
theorem spliceObj_pend_of_lt_of_pend_past
    (hg : IsLadderPath step pend g) (hcl : l ≤ cntAt g a)
    (hpast : ∀ p : ℤ, p ≤ a → pend (objAt g p) = true)
    (s : ℤ) (hs : s < a + (l : ℤ)) : pend (spliceObj g a l s) = true := by
  rw [spliceObj_of_lt s hs]
  rcases le_total s a with h | h
  · exact hpast s h
  · exact (spliceSeg hg (hpast a le_rfl) hcl s h (by omega)).1

/-- **THE ADMISSIBILITY HALF, UNCONDITIONAL IN THE PENDING-FOREVER REGIME.** No pin side
condition: the spliced walk's region starts are exactly the original's, displaced by `l`, so
`pinCompat_of_ladderPath` on the original discharges both pin hypotheses, with the deadline
register's own value `l` positions before the origin as the base pin. -/
theorem exists_spliced_ladderPath_of_pend_past
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hpast : ∀ p : ℤ, p ≤ a → pend (objAt g p) = true)
    (hrep : objAt g a = objAt g (a + (l : ℤ))) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = spliceObj g a l v) ∧ (∀ v, cntAt g' v = spliceCnt g a l v) := by
  -- every region start of the spliced walk sits at or above `a + l`
  have hstart : ∀ s : ℤ, pend (spliceObj g a l s) = false → a + (l : ℤ) ≤ s := by
    intro s hs
    by_contra hlt
    exact Bool.false_ne_true
      (hs.symm.trans (spliceObj_pend_of_lt_of_pend_past hg hcl hpast s (by omega)))
  -- and is the original's own region start, displaced by `l`
  have hpull : ∀ s : ℤ, pend (spliceObj g a l s) = false →
      pend (spliceObj g a l (s + 1)) = true →
      pend (objAt g (s - (l : ℤ))) = false ∧ pend (objAt g (s - (l : ℤ) + 1)) = true ∧
        spliceCnt g a l (s + 1) = cntAt g (s - (l : ℤ) + 1) := by
    intro s h0 h1
    have hge := hstart s h0
    rw [spliceObj_of_ge s hge] at h0
    rw [spliceObj_of_ge (s + 1) (by omega), show s + 1 - (l : ℤ) = s - (l : ℤ) + 1 by ring] at h1
    refine ⟨h0, h1, ?_⟩
    rw [spliceCnt_of_ge (s + 1) (by omega), show s + 1 - (l : ℤ) = s - (l : ℤ) + 1 by ring]
  refine exists_spliced_ladderPath hg hl (hpast a le_rfl) hcl hrep (nxtAt g (-(l : ℤ)))
    (fun s v hs0 hs1 hv0 hv1 => ?_) (fun v hv0 hv1 => ?_)
  · obtain ⟨hs0', hs1', hsc⟩ := hpull s hs0 hs1
    obtain ⟨hv0', hv1', hvc⟩ := hpull v hv0 hv1
    rw [hsc, hvc]
    have := pinCompat_of_ladderPath g hg (s - (l : ℤ)) (v - (l : ℤ)) hs0' hs1' hv0' hv1'
    rw [show s - (l : ℤ) - (v - (l : ℤ)) = s - v by ring] at this
    exact this
  · obtain ⟨hv0', hv1', hvc⟩ := hpull v hv0 hv1
    rw [hvc, cntAt_eq_nxtAt_of_idle_pend g hg (v - (l : ℤ)) hv0' hv1']
    have := nxtAt_lipschitz_two_sided g hg (v - (l : ℤ)) (-(l : ℤ))
    rw [show v - (l : ℤ) - -(l : ℤ) = v by ring] at this
    exact this

end Splice

/-! ### The alternative history: a pend-profile-preserving relabelling of the walk

The replacement layer above moves the COUNTDOWN, which forces the walk to move with it
(`cntAt_eq_of_obj_eq`) and makes the realized type move too — that is what the splice refutation
says. The construction below moves in the opposite direction: it moves the WALK while holding
BOTH counters fixed. Every clause of `Rlad` except the `step` clause reads the object only
through `pend`, so a walk agreeing with the original's PEND PROFILE at every position carries the
original path's `cntAt` AND `nxtAt` verbatim, and only the `step` clause has to be rechecked.

The payoff is not another replacement: it is that a ladder state has MORE histories through it
than its own path's. At every position the relabelling leaves alone, the alternative path is at
the IDENTICAL ladder state — not merely a class-equivalent one — so the cell at that state
contains the type the alternative history realizes. That is strictly more than the cell's own
path gives, and it is the freedom the pumping route had no analogue of.

Nothing here is a type-transport statement. No claim is made that the alternative history
realizes the SAME type as the original — in general it does not, and that is the point: the
construction enlarges the cell rather than preserving a type. -/

/-- **The alternative path**: the original path's two counters carried on a different object
walk. The admissibility side condition transports through the pend equality alone — the
hypothesis `hpend` is exactly what the carrier's `Adm` clause reads. -/
def altWalkPath (g : ℤ → LadderState Q pend) (w' : ℤ → Q)
    (hpend : ∀ v, pend (w' v) = pend (objAt g v)) (v : ℤ) : LadderState Q pend :=
  ⟨(w' v, cntAt g v, nxtAt g v), by
    intro hfalse
    exact (g v).2 ((hpend v).symm.trans hfalse)⟩

/-- The object component of the alternative path is the new walk. -/
theorem objAt_altWalkPath (g : ℤ → LadderState Q pend) (w' : ℤ → Q)
    (hpend : ∀ v, pend (w' v) = pend (objAt g v)) (v : ℤ) :
    objAt (altWalkPath g w' hpend) v = w' v := rfl

/-- The current-deadline component of the alternative path is the ORIGINAL's, verbatim. -/
theorem cntAt_altWalkPath (g : ℤ → LadderState Q pend) (w' : ℤ → Q)
    (hpend : ∀ v, pend (w' v) = pend (objAt g v)) (v : ℤ) :
    cntAt (altWalkPath g w' hpend) v = cntAt g v := rfl

/-- The next-deadline component of the alternative path is the ORIGINAL's, verbatim. -/
theorem nxtAt_altWalkPath (g : ℤ → LadderState Q pend) (w' : ℤ → Q)
    (hpend : ∀ v, pend (w' v) = pend (objAt g v)) (v : ℤ) :
    nxtAt (altWalkPath g w' hpend) v = nxtAt g v := rfl

/-- **The alternative walk IS a ladder path**, with the original's counters. The `step` clause is
the hypothesis `hstep`; the idle-zero clause, `Drift` and `Count` all transfer through the pend
equality with the original's own `cntAt` and `nxtAt`. No splice, no parameter, no divisibility
and no `ParamsOk` enters. -/
theorem altWalkPath_isLadderPath (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (w' : ℤ → Q)
    (hpend : ∀ v, pend (w' v) = pend (objAt g v))
    (hstep : ∀ v, step (w' v) (w' (v + 1)) = true) :
    IsLadderPath step pend (altWalkPath g w' hpend) := by
  intro u
  obtain ⟨-, h2, h3, h4⟩ := hg u
  refine ⟨hstep u, ?_, h3, ?_⟩
  · intro hfalse
    exact h2 ((hpend u).symm.trans hfalse)
  · change Count (pend (w' u)) (pend (w' (u + 1))) (cntAt g u) (nxtAt g u) (cntAt g (u + 1))
    rw [hpend u, hpend (u + 1)]
    exact h4

/-- **And it passes through the ORIGINAL state** at every position the relabelling leaves alone:
the IDENTICAL ladder state, not merely a class-equivalent one, because all three components
agree there. Stated POSITIONWISE on the hypothesis `w' v = objAt g v` — no finiteness, no
"off a finite set" and no cardinality side condition enters the statement. -/
theorem altWalkPath_eq_of_objAt_eq (g : ℤ → LadderState Q pend) (w' : ℤ → Q)
    (hpend : ∀ v, pend (w' v) = pend (objAt g v)) (v : ℤ) (hv : w' v = objAt g v) :
    altWalkPath g w' hpend v = g v := by
  apply Subtype.ext
  change (w' v, cntAt g v, nxtAt g v) = (g v).1
  rw [hv]
  rfl

end Path

/-! ### The alternative-history construction is NOT vacuous

The construction above is only worth the name if a pend-profile-preserving relabelling can differ
from the identity, which needs an object with two distinct states carrying the same `pend` bit
and a ladder path through one of them. The fixture below exhibits one, and exhibits it at a
PENDING position rather than an idle one, so the witness is not confined to the degenerate regime
where every counter is pinned to `0`: three states, `0` and `1` pending and `2` idle, with a walk
pending on `(-∞, 0]` and idle from `1` on, whose countdown `Count` forces to be the distance to
the region's end. The relabelling moves position `0` from the `0`-state to the `1`-state — both
pending — and so leaves the whole counter structure untouched. -/

section AltNonVacuous

/-- The witness object: three states, `0` and `1` pending, `2` idle. -/
abbrev AltQ : Type := Fin 3

/-- The witness pending predicate: `0` and `1` pending, `2` idle. -/
def altPend : AltQ → Bool := fun q => decide (q.val < 2)

/-- The witness step relation: every step permitted, so the `step` clause never obstructs. -/
def altStep : AltQ → AltQ → Bool := fun _ _ => true

/-- The witness walk: pending on `(-∞, 0]`, idle from `1` on. -/
def altW : ℤ → AltQ := fun v => if 1 ≤ v then 2 else 0

/-- The countdown `Count` forces on `altW`: the distance to the region's end. -/
def altC : ℤ → ℕ := fun v => (-v).toNat

/-- The witness relabelling: `altW` with position `0` moved from the `0`-state to the `1`-state.
Both are pending, so the pend profile is untouched. -/
def altW' : ℤ → AltQ := fun v => if 1 ≤ v then 2 else if v = 0 then 1 else 0

theorem altStep_true (x y : AltQ) : altStep x y = true := rfl

theorem altPend_altW_of_le (v : ℤ) (h : v ≤ 0) : altPend (altW v) = true := by
  have : altW v = 0 := by simp only [altW, if_neg (show ¬ (1 : ℤ) ≤ v by omega)]
  rw [this]; decide

theorem altPend_altW_of_ge (v : ℤ) (h : 1 ≤ v) : altPend (altW v) = false := by
  have : altW v = 2 := by simp only [altW, if_pos h]
  rw [this]; decide

theorem le_zero_of_altPend_altW (v : ℤ) (h : altPend (altW v) = true) : v ≤ 0 := by
  by_contra hc
  exact Bool.false_ne_true ((altPend_altW_of_ge v (by omega)).symm.trans h)

/-- The witness walk has NO region start: it is pending into the past forever, so both pin
hypotheses of `exists_ladderPath_of_walk` discharge vacuously. -/
theorem altNoRegionStart (s : ℤ) (h0 : altPend (altW s) = false)
    (h1 : altPend (altW (s + 1)) = true) : False := by
  have h := le_zero_of_altPend_altW (s + 1) h1
  exact Bool.false_ne_true (h0.symm.trans (altPend_altW_of_le s (by omega)))

theorem altW'_zero : altW' 0 = 1 := by
  simp only [altW', if_neg (show ¬ (1 : ℤ) ≤ (0 : ℤ) by omega), if_pos]

theorem altW_zero : altW 0 = 0 := by
  simp only [altW, if_neg (show ¬ (1 : ℤ) ≤ (0 : ℤ) by omega)]

/-- **The relabelling preserves the pend profile at every position**, which is the one hypothesis
`altWalkPath` consumes. -/
theorem altPend_altW' (v : ℤ) : altPend (altW' v) = altPend (altW v) := by
  by_cases h1 : (1 : ℤ) ≤ v
  · simp only [altW', altW, if_pos h1]
  · by_cases h0 : v = 0
    · subst h0; rw [altW'_zero, altW_zero]; decide
    · simp only [altW', altW, if_neg h1, if_neg h0]

/-- The witness ladder path, through `exists_ladderPath_of_walk` with both pin hypotheses
discharged by `altNoRegionStart`. -/
theorem exists_altLadderPath :
    ∃ g : ℤ → LadderState AltQ altPend, IsLadderPath altStep altPend g ∧
      (∀ v, objAt g v = altW v) ∧ (∀ v, cntAt g v = altC v) := by
  refine exists_ladderPath_of_walk altW altC 0 (fun v => altStep_true _ _) ?_ ?_ ?_
    (fun s v hs0 hs1 _ _ => absurd (altNoRegionStart s hs0 hs1) not_false)
    (fun v hv0 hv1 => absurd (altNoRegionStart v hv0 hv1) not_false)
  · intro v h
    have : ¬ v ≤ 0 := fun hv => Bool.false_ne_true (h.symm.trans (altPend_altW_of_le v hv))
    simp only [altC]; omega
  · intro v h h'
    have hv := le_zero_of_altPend_altW v h
    have hv' := le_zero_of_altPend_altW (v + 1) h'
    simp only [altC]; omega
  · intro v h h'
    have hv := le_zero_of_altPend_altW v h
    have hv' : ¬ (v + 1 ≤ 0) := fun hc =>
      Bool.false_ne_true (h'.symm.trans (altPend_altW_of_le (v + 1) hc))
    have hz : v = 0 := by omega
    simp only [altC, hz]; norm_num

/-- **`altWalkPath` IS NOT ALWAYS THE ORIGINAL PATH.** At the witness object there is a ladder
path, a pend-profile-preserving relabelling of its walk satisfying the `step` clause, and a
PENDING position at which the alternative path and the original differ. So
`mem_cellAt_of_altWalkPath` is not a restatement of `mem_cellAt_ladder_iff`: it names histories
the original path does not supply. -/
theorem altWalkPath_not_vacuous :
    ∃ (g : ℤ → LadderState AltQ altPend)
      (hpend : ∀ v, altPend (altW' v) = altPend (objAt g v)),
      IsLadderPath altStep altPend g ∧
      (∀ v, altStep (altW' v) (altW' (v + 1)) = true) ∧
      altPend (objAt g 0) = true ∧
      altWalkPath g altW' hpend 0 ≠ g 0 := by
  obtain ⟨g, hg, hobj, -⟩ := exists_altLadderPath
  have hpend : ∀ v, altPend (altW' v) = altPend (objAt g v) := by
    intro v; rw [hobj v]; exact altPend_altW' v
  refine ⟨g, hpend, hg, fun v => altStep_true _ _, ?_, ?_⟩
  · rw [hobj 0, altW_zero]; decide
  · intro heq
    have h1 : altW' 0 = objAt g 0 :=
      congrArg (fun x : LadderState AltQ altPend => x.1.1) heq
    rw [hobj 0, altW'_zero, altW_zero] at h1
    exact absurd h1 (by decide)

end AltNonVacuous

/-! ## The index maps of the splice, and where they stop working

The splice is a surgery on positions as well as on the walk, and the two maps below are what a
type-level argument would have to quantify over. `spliceIdx` is the RETRACTION — the spliced
path's position `v` carries the original's object at `spliceIdx a l v` — and `spliceEmb` is the
order EMBEDDING in the other direction, which `spliceIdx` retracts.

`spliceEmb` is monotone, so a temporal witness of the ORIGINAL transports along it. `spliceIdx`
is not: at the seam it drops back by `l` (`spliceIdx_seam_lt`), which is the mechanical reason the
index maps ALONE cannot carry a temporal letter of the spliced path back to the original at a
position inside the pumped block. A witness of `ψ U χ` found in the second copy retracts to a
position that may lie BEFORE the position being evaluated, so the retracted witness is not a
witness. This is the precise form of the model-level obstruction the module's header records: what
is missing is not an index map but a statement about truth along the path at the positions the
retraction folds together. -/

section SpliceIdx

variable {Q : Type} {pend : Q → Bool}

/-- **The retraction of the splice on positions**: a position below the splice point is the
original's own, and a position at or above it is the original's `l` earlier. -/
def spliceIdx (a : ℤ) (l : ℕ) (v : ℤ) : ℤ := if v < a + (l : ℤ) then v else v - (l : ℤ)

theorem spliceIdx_of_lt (a : ℤ) (l : ℕ) (v : ℤ) (h : v < a + (l : ℤ)) :
    spliceIdx a l v = v := by
  simp only [spliceIdx, if_pos h]

theorem spliceIdx_of_ge (a : ℤ) (l : ℕ) (v : ℤ) (h : a + (l : ℤ) ≤ v) :
    spliceIdx a l v = v - (l : ℤ) := by
  simp only [spliceIdx, if_neg (by omega : ¬ v < a + (l : ℤ))]

/-- **The spliced walk is the original read along the retraction**, which is the single statement
`spliceObj_of_lt` and `spliceObj_of_ge` make between them. -/
theorem spliceObj_eq_objAt_spliceIdx (g : ℤ → LadderState Q pend) (a : ℤ) (l : ℕ) (v : ℤ) :
    spliceObj g a l v = objAt g (spliceIdx a l v) := by
  rcases lt_or_ge v (a + (l : ℤ)) with h | h
  · rw [spliceObj_of_lt v h, spliceIdx_of_lt a l v h]
  · rw [spliceObj_of_ge v h, spliceIdx_of_ge a l v h]

/-- **The order embedding of the splice on positions**: the original's position `v` sits at `v`
below the splice and at `v + l` from the splice point on. -/
def spliceEmb (a : ℤ) (l : ℕ) (v : ℤ) : ℤ := if v < a then v else v + (l : ℤ)

/-- **The embedding is monotone.** This is the direction that works: a temporal witness of the
original transports along it, because the order of positions is preserved. -/
theorem spliceEmb_monotone (a : ℤ) (l : ℕ) : Monotone (spliceEmb a l) := by
  intro u v huv
  simp only [spliceEmb]
  split <;> split <;> omega

/-- **The retraction retracts the embedding.** So the original's positions are exactly the
positions the retraction hits, and nothing of the original is lost by the surgery. -/
theorem spliceIdx_spliceEmb (a : ℤ) (l : ℕ) (v : ℤ) : spliceIdx a l (spliceEmb a l v) = v := by
  simp only [spliceIdx, spliceEmb]
  split <;> split <;> omega

/-- **THE RETRACTION DROPS BACK AT THE SEAM**, whenever the pumped block has length at least two:
the spliced position `a + l` retracts to `a` while its own predecessor `a + l - 1` retracts to
`a + l - 1`, which is strictly later. Compiled here because it is the mechanical reason the index
maps alone do not carry a temporal letter across the block: a witness found in the second copy of
the block retracts to a position that need not be later than the position being evaluated, so the
retracted witness is not a witness and `untl_mem_tpOf_iff`'s right-hand side is not transported.
Nothing weaker than a statement about truth at the folded positions closes that gap. -/
theorem spliceIdx_seam_lt (a : ℤ) (l : ℕ) (hl : 2 ≤ l) :
    spliceIdx a l (a + (l : ℤ)) < spliceIdx a l (a + (l : ℤ) - 1) := by
  rw [spliceIdx_of_ge a l (a + (l : ℤ)) le_rfl,
    spliceIdx_of_lt a l (a + (l : ℤ) - 1) (by omega)]
  have : (2 : ℤ) ≤ (l : ℤ) := by exact_mod_cast hl
  omega

end SpliceIdx

/-! ## The ladder paths ARE the world histories of the ladder frame

Everything above the `Stab` section is about a function `g : ℤ → LadderState Q pend` stepping
along `RladAdm`; everything about a realized TYPE is about a `WorldHistory` of `ladderFrameAdm`.
The two layers are the same object, and the bridge below is what lets a replacement performed on
the WALK be read as a statement about the CELL — the object the agreement compares. It is the
history-space characterization `ofSlicedStepFinBranch_mem_HF_iff` at `RladAdm`, whose time
argument `Rlad` ignores, so the offset a history carries is invisible to the step condition and a
ladder path is an offset step path at EVERY offset.

The bridge also says what a replacement argument owes and what it does not, clause family by
clause family. `⊥` and `→` are structural (`bot_not_mem_tpOf`, `imp_mem_tpOf_iff`); the `□`
letters transfer under every replacement whatsoever (`box_mem_tpOf_transfer`); the ATOMIC letters
read the object walk at the position and nothing else (`atom_mem_tpOf_ladder_iff`), so they
transfer whenever the replacement leaves the object at the position alone — which
`spliceObj_eq_of_le` says the splice does (`atom_mem_tpOf_transfer_of_objAt_eq`). What is left
open is exactly two clause families: the two TEMPORAL letters, whose bits are statements about
unboundedly distant positions of the same path (`untl_mem_tpOf_iff`, `snce_mem_tpOf_iff`), and
the `⊡` letters, whose bits are by `stab_mem_tpOf_iff_cell` data of the very cells being
compared. -/

section Hist

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

omit [Finite Q] [Nonempty Q] in
/-- **The offset is invisible to the step condition.** `Rlad` ignores its time argument, so an
offset step path of `RladAdm` at one offset is one at every offset, and both readings are the
ladder path condition. -/
theorem isSlicedStepPath_iff_isLadderPath (k : ℤ) (g : ℤ → LadderState Q pend) :
    IsSlicedStepPath (RladAdm step pend) k g ↔ IsLadderPath step pend g := Iff.rfl

/-- **Every ladder path IS a world history of the ladder frame**, at the offset `0`: its state at
every time is the path's value there, with the frame's own time coordinate alongside. This is the
direction a replacement argument consumes — the spliced walk is a ladder path
(`exists_spliced_ladderPath_of_pend_past`), hence a history, hence a witness for the cell. -/
theorem exists_hist_of_isLadderPath
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) :
    ∃ τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
      ∀ t : ℤ, τ.state t = (t, g t) := by
  obtain ⟨τ, hτ⟩ :=
    (ofSlicedStepFinBranch_mem_HF_iff (RladAdm step pend) (RladAdm_fwd step pend)
        (RladAdm_bwd step pend) fwd bwd (fun t => (t, g t))).mpr
      ⟨0, g, (isSlicedStepPath_iff_isLadderPath 0 g).mpr hg, by funext t; simp⟩
  refine ⟨τ, fun t => ?_⟩
  have h : τ.path t = (t, g t) := by rw [hτ]
  exact h

/-- **Every world history of the ladder frame IS a ladder path**, up to the offset its origin
carries: `τ.state t = (t + k, g t)` for a ladder path `g`. This is the direction a replacement
argument consumes to get its hands on a walk in the first place. -/
theorem exists_isLadderPath_of_hist
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) :
    ∃ (k : ℤ) (g : ℤ → LadderState Q pend), IsLadderPath step pend g ∧
      ∀ t : ℤ, τ.state t = (t + k, g t) := by
  obtain ⟨k, g, hg, hpath⟩ :=
    (ofSlicedStepFinBranch_mem_HF_iff (RladAdm step pend) (RladAdm_fwd step pend)
        (RladAdm_bwd step pend) fwd bwd τ.path).mp ⟨τ, rfl⟩
  refine ⟨k, g, (isSlicedStepPath_iff_isLadderPath k g).mp hg, fun t => ?_⟩
  have h : τ.path t = (t + k, g t) := by rw [hpath]
  exact h

/-- **The cell of a ladder state, read on ladder paths.** The closure types realized at a ladder
state are exactly those realized at it by the LADDER PATHS through it, with no offset left over:
a history through a world state whose time coordinate is `z` carries offset `0`. This is the
agreement's own object translated into the language the replacement layer speaks — a replacement
that produces a ladder path through the other state realizing the same type is exactly what the
agreement asks for, and nothing else is. -/
theorem mem_cellAt_ladder_iff
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (x : LadderState Q pend) (z : ℤ)
    (T : Finset PlusFormula) :
    T ∈ cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) z ↔
      ∃ (g : ℤ → LadderState Q pend)
        (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        IsLadderPath step pend g ∧ g z = x ∧ (∀ t : ℤ, τ.state t = (t, g t)) ∧
        tpOf (ladderModel step pend fwd bwd lab) φ τ z = T := by
  constructor
  · rintro ⟨τ, hs, rfl⟩
    obtain ⟨k, g, hg, hp⟩ := exists_isLadderPath_of_hist fwd bwd τ
    have hz : ((z, x) : (ladderFrameAdm step pend fwd bwd).WorldState) = (z + k, g z) :=
      hs.symm.trans (hp z)
    have hk : k = 0 := by
      have := congrArg Prod.fst hz
      simp only at this
      omega
    subst hk
    refine ⟨g, τ, hg, ?_, fun t => ?_, rfl⟩
    · have := congrArg Prod.snd hz
      simpa using this.symm
    · rw [hp t, add_zero]
  · rintro ⟨g, τ, -, hgz, hτ, hT⟩
    exact ⟨τ, by rw [hτ z, hgz], hT⟩

/-- **The ATOMIC letters of a realized type read the object walk at the position and nothing
else.** The ladder model's valuation ignores the time coordinate and both counters, so an atomic
letter's bit is `lab` at the object the path carries there — whatever offset the history has. -/
theorem atom_mem_tpOf_ladder_iff
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {k : ℤ} {g : ℤ → LadderState Q pend}
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (z : ℤ) (p : Atom) :
    PlusFormula.atom p ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ z ↔
      PlusFormula.atom p ∈ plusSubformulaClosure φ ∧ lab (objAt g z) p = true := by
  rw [mem_tpOf_iff, PlusTruth.atom_iff, hτ z]
  exact Iff.rfl

/-- **The atomic letters transfer whenever the object at the position does.** With
`box_mem_tpOf_transfer` this is the whole of what a replacement argument gets for free: the splice
leaves the object at a position of the lengthened region alone (`spliceObj_eq_of_le`), so the
atomic bits of the two compared types already agree. What is owed is therefore exactly two clause
families — the two temporal letters and the `⊡` letters. -/
theorem atom_mem_tpOf_transfer_of_objAt_eq
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (τ τ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (hτ' : ∀ t : ℤ, τ'.state t = (t + k', g' t))
    (z : ℤ) (hobj : objAt g z = objAt g' z) (p : Atom) :
    PlusFormula.atom p ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ z ↔
      PlusFormula.atom p ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ' z := by
  rw [atom_mem_tpOf_ladder_iff fwd bwd lab φ τ hτ z p,
    atom_mem_tpOf_ladder_iff fwd bwd lab φ τ' hτ' z p, hobj]

/-! ### Half (i): object-trace locality

The transport of a realized type between two DISTINCT ladder states, in the one case where it
closes on its own ground: the two paths have the SAME object walk. No parameter, no splice and no
cascade enters, and the proof is one case per clause of `PlusTruthAt`. The counters are what
differ, and the statement is the mechanical form of the claim that they are invisible to every
clause but `⊡`: the valuation reads the object component only, `□` names no path at all, `⊥` and
`→` are structural, and `U`/`S` quantify over the time axis of the same history, so each of them
is settled by the induction hypothesis at the other positions. The `⊡` clause is the only one
that reads the world STATE, and it is carried by the pinned-letter hypothesis rather than proved
here.

Half (i) is not vacuous: `cntAt_eq_of_obj_eq` fixes the countdown from the walk, but the
next-deadline register only drifts (`nxtAt_drift`), so two ladder paths with one object walk can
differ at every position in `n` — `exists_ladderPath_pair_nxtAt_ne` exhibits such a pair whenever
the object has an idle self-loop. -/

/-- **HALF (i), OBJECT-TRACE LOCALITY, at the pinned-letter parameter.** Two ladder paths with the
same object walk satisfy the same closure formulas at every position, for every formula whose `⊡`
letters are pinned by `L`. One case per clause: the atomic one reads the object walk, `⊥` and `→`
are structural, `□` is literally the same proposition on both sides because its clause names no
history, `U` and `S` are the induction hypothesis at the other positions, and `⊡` is the pinned
hypothesis. -/
theorem truthAt_iff_of_objAt_eq_of_stabPinned
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (L : PlusFormula → Prop)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hobj : ∀ v : ℤ, objAt g v = objAt g' v)
    (hL : ∀ χ : PlusFormula, L (PlusFormula.stab χ) → ∀ v : ℤ,
      (PlusTruthAt (ladderModel step pend fwd bwd lab) σ v (PlusFormula.stab χ) ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) σ' v (PlusFormula.stab χ))) :
    ∀ ψ : PlusFormula, StabPinned L ψ → ∀ z : ℤ,
      (PlusTruthAt (ladderModel step pend fwd bwd lab) σ z ψ ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) σ' z ψ) := by
  intro ψ
  induction ψ with
  | atom p =>
      intro _ z
      rw [PlusTruth.atom_iff, PlusTruth.atom_iff, hσ z, hσ' z]
      change lab (objAt g z) p = true ↔ lab (objAt g' z) p = true
      rw [hobj z]
  | bot => intro _ z; exact Iff.rfl
  | imp a b iha ihb => intro h z; exact imp_congr (iha h.1 z) (ihb h.2 z)
  | box a _ => intro _ z; exact Iff.rfl
  | untl a b iha ihb =>
      intro h z
      rw [PlusTruth.untl_iff, PlusTruth.untl_iff]
      constructor
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mp he, fun r h1 h2 => (iha h.1 r).mp (hgd r h1 h2)⟩
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mpr he, fun r h1 h2 => (iha h.1 r).mpr (hgd r h1 h2)⟩
  | snce a b iha ihb =>
      intro h z
      rw [PlusTruth.snce_iff, PlusTruth.snce_iff]
      constructor
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mp he, fun r h1 h2 => (iha h.1 r).mp (hgd r h1 h2)⟩
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mpr he, fun r h1 h2 => (iha h.1 r).mpr (hgd r h1 h2)⟩
  | stab a _ => intro h z; exact hL a h z

/-- **Half (i) on closure TYPES**: the realized types of two ladder paths with the same object walk
coincide at every position, whenever every member of the closure has its `⊡` letters pinned. -/
theorem tpOf_eq_of_objAt_eq_of_pinned
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (L : PlusFormula → Prop)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hobj : ∀ v : ℤ, objAt g v = objAt g' v)
    (hL : ∀ χ : PlusFormula, L (PlusFormula.stab χ) → ∀ v : ℤ,
      (PlusTruthAt (ladderModel step pend fwd bwd lab) σ v (PlusFormula.stab χ) ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) σ' v (PlusFormula.stab χ)))
    (hcl : ∀ ψ ∈ plusSubformulaClosure φ, StabPinned L ψ) (z : ℤ) :
    tpOf (ladderModel step pend fwd bwd lab) φ σ z
      = tpOf (ladderModel step pend fwd bwd lab) φ σ' z := by
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  exact and_congr_right fun hmem =>
    truthAt_iff_of_objAt_eq_of_stabPinned fwd bwd lab L σ σ' hσ hσ' hobj hL ψ (hcl ψ hmem) z

/-- **The stab-free instance of half (i)**: when the closure carries no `⊡` letter at all, the
pinned-letter hypothesis is vacuous and the realized types of two ladder paths with the same
object walk simply coincide. -/
theorem tpOf_stabFree_eq_of_objAt_eq
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hobj : ∀ v : ℤ, objAt g v = objAt g' v)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) (z : ℤ) :
    tpOf (ladderModel step pend fwd bwd lab) φ σ z
      = tpOf (ladderModel step pend fwd bwd lab) φ σ' z :=
  tpOf_eq_of_objAt_eq_of_pinned fwd bwd lab φ (fun _ => False) σ σ' hσ hσ' hobj
    (fun _ h => absurd h (fun h => h)) (stabPinned_false_of_mem_closure hno) z

omit [Finite Q] [Nonempty Q] in
/-- **HALF (i) IS NOT VACUOUS.** Whenever the object has an idle state with a self-loop, the
constant walk at it lifts to a ladder path for EVERY value of the next-deadline register: the
countdown is pinned to `0` by the idle clause of `Count` and the register only has to `Drift`,
which a constant does. So two ladder paths can share an object walk — hence, by
`cntAt_eq_of_obj_eq`, their whole countdown — and still differ at every position in `n`, which is
exactly the pair half (i) transports between. -/
theorem exists_ladderPath_pair_nxtAt_ne (q : Q) (hq : pend q = false) (hs : step q q = true)
    {n n' : ℕ} (hn : n ≠ n') :
    ∃ g g' : ℤ → LadderState Q pend, IsLadderPath step pend g ∧ IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g v = objAt g' v) ∧ ∀ v : ℤ, nxtAt g v ≠ nxtAt g' v := by
  refine ⟨fun _ => ⟨(q, 0, n), fun _ => rfl⟩, fun _ => ⟨(q, 0, n'), fun _ => rfl⟩,
    fun u => ⟨hs, fun _ => rfl, Or.inl rfl, ?_⟩, fun u => ⟨hs, fun _ => rfl, Or.inl rfl, ?_⟩,
    fun _ => rfl, fun _ => hn⟩
  · simp [Count, hq]
  · simp [Count, hq]

/-- **THE CELL CONTAINS THE TYPES OF THE ALTERNATIVE HISTORIES.** At every position the
relabelling leaves alone, the alternative path is at the IDENTICAL ladder state, so the type it
realizes there belongs to the cell at the ORIGINAL state. The general form of what the
alternative-history prototype exhibited at its fixture: the cell at a ladder state contains the
type realized by every pend-profile-preserving relabelling of every path through it, and so is in
general strictly larger than the type its own history realizes (`altWalkPath_not_vacuous` is the
compiled witness that the relabellings are not all the identity).

This is what makes the cell-level reading of the agreement weaker than a pointwise type equality
along a chosen pair of paths — and so untouched by the splice-type refutation, which compares two
particular histories and says nothing about the other histories through either state. -/
theorem mem_cellAt_of_altWalkPath
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (w' : ℤ → Q) (hpend : ∀ v, pend (w' v) = pend (objAt g v))
    (hstep : ∀ v, step (w' v) (w' (v + 1)) = true)
    (z : ℤ) (hz : w' z = objAt g z) :
    ∃ τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
      (∀ t : ℤ, τ.state t = (t, altWalkPath g w' hpend t)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ τ z
        ∈ cellAt (ladderModel step pend fwd bwd lab) φ
            ((z, g z) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  have halt : IsLadderPath step pend (altWalkPath g w' hpend) :=
    altWalkPath_isLadderPath g hg w' hpend hstep
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwd bwd (altWalkPath g w' hpend) halt
  refine ⟨τ, hτ, ?_⟩
  exact (mem_cellAt_ladder_iff fwd bwd lab φ (g z) z _).mpr
    ⟨altWalkPath g w' hpend, τ, halt, altWalkPath_eq_of_objAt_eq g w' hpend z hz, hτ, rfl⟩

/-! ### The atom-valuation closure agreement

Half (i) transports a realized type between two ladder paths with the SAME OBJECT WALK. That
hypothesis is strictly stronger than anything the cell-level route can assume: the whole point of
the alternative-history construction is that the two walks DIFFER at the positions the relabelling
moves. What the ladder model's valuation actually reads at a position is `lab` of the object
component there and nothing else (`atom_mem_tpOf_ladder_iff`), so the hypothesis the `atom` clause
consumes is POINTWISE AGREEMENT OF `lab`, not of the object state:

  `∀ v : ℤ, ∀ p : Atom, lab (objAt g v) p = lab (objAt g' v) p`

and it is weaker than half (i)'s exactly to the extent that `lab` is not injective — two distinct
object states with the same atom row are indistinguishable to every clause of `PlusTruthAt` but
`⊡`. **Stating the transport with the object-walk-equality hypothesis would be half (i) under a new
name and would prove nothing new**; that is recorded here so no later round re-derives it. Half (i)
itself is reused below, not re-proved, and its three statements are untouched.

The `box` arm WIDENS, and this is a result rather than an assumption. The `box` clause of
`PlusTruthAt` quantifies over every history and every time of the model and so names no path at
all — `box_mem_tpOf_transfer` is its type-level reading, and the two compared histories here live
in the SAME model `ladderModel step pend fwd bwd lab`, which is that lemma's only hypothesis
besides closure membership. So the `box` case of the induction is literally `Iff.rfl`, exactly as
it is in half (i), and the fragment does not have to exclude `□`. The narrow, stab-free AND
box-free form the route decision names is landed as `truthAt_iff_of_lab_eq_of_stabBoxFree` with
`StabBoxFree`; the widened form is `truthAt_iff_of_lab_eq_of_stabPinned`, stated at the
pinned-letter parameter so that an induction on `⊡`-nesting depth can consume it, with
`tpOf_stabFree_eq_of_lab_eq` its stab-free type-level instance. Phase 11.5's fragment is the
widened one. -/

/-- **THE ATOM-VALUATION CLOSURE AGREEMENT, NARROW FRAGMENT.** Two ladder paths whose object walks
carry the SAME ATOM ROW at every position satisfy the same stab-free, box-free closure formulas at
every position. One case per clause: `atom` is the hypothesis read through the ladder model's
valuation, `⊥` and `→` are structural, `U` and `S` are the induction hypothesis at the other
positions of the same history, and `□` and `⊡` are excluded by `StabBoxFree`.

The hypothesis is POINTWISE `lab` AGREEMENT, not object-walk equality: the latter is the landed
half (i) (`truthAt_iff_of_objAt_eq_of_stabPinned`), which is cited as the model for this
induction's shape and is neither re-proved nor altered. -/
theorem truthAt_iff_of_lab_eq_of_stabBoxFree
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hlab : ∀ (v : ℤ) (p : Atom), lab (objAt g v) p = lab (objAt g' v) p) :
    ∀ ψ : PlusFormula, StabBoxFree ψ → ∀ z : ℤ,
      (PlusTruthAt (ladderModel step pend fwd bwd lab) σ z ψ ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) σ' z ψ) := by
  intro ψ
  induction ψ with
  | atom p =>
      intro _ z
      rw [PlusTruth.atom_iff, PlusTruth.atom_iff, hσ z, hσ' z]
      change lab (objAt g z) p = true ↔ lab (objAt g' z) p = true
      rw [hlab z p]
  | bot => intro _ z; exact Iff.rfl
  | imp a b iha ihb => intro h z; exact imp_congr (iha h.1 z) (ihb h.2 z)
  | box a _ => intro h _; exact absurd h (fun h => h)
  | untl a b iha ihb =>
      intro h z
      rw [PlusTruth.untl_iff, PlusTruth.untl_iff]
      constructor
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mp he, fun r h1 h2 => (iha h.1 r).mp (hgd r h1 h2)⟩
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mpr he, fun r h1 h2 => (iha h.1 r).mpr (hgd r h1 h2)⟩
  | snce a b iha ihb =>
      intro h z
      rw [PlusTruth.snce_iff, PlusTruth.snce_iff]
      constructor
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mp he, fun r h1 h2 => (iha h.1 r).mp (hgd r h1 h2)⟩
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mpr he, fun r h1 h2 => (iha h.1 r).mpr (hgd r h1 h2)⟩
  | stab a _ => intro h _; exact absurd h (fun h => h)

/-- **THE ATOM-VALUATION CLOSURE AGREEMENT ON CLOSURE TYPES, NARROW FRAGMENT.** The realized types
of two ladder paths with the same atom row at every position coincide at every position, whenever
every member of the closure is stab-free and box-free. -/
theorem tpOf_stabBoxFree_eq_of_lab_eq
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hlab : ∀ (v : ℤ) (p : Atom), lab (objAt g v) p = lab (objAt g' v) p)
    (hcl : ∀ ψ ∈ plusSubformulaClosure φ, StabBoxFree ψ) (z : ℤ) :
    tpOf (ladderModel step pend fwd bwd lab) φ σ z
      = tpOf (ladderModel step pend fwd bwd lab) φ σ' z := by
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  exact and_congr_right fun hmem =>
    truthAt_iff_of_lab_eq_of_stabBoxFree fwd bwd lab σ σ' hσ hσ' hlab ψ (hcl ψ hmem) z

/-- **THE `box` ARM WIDENS: the atom-valuation agreement at the pinned-letter parameter.** The same
transport with `□` ADMITTED and the `⊡` letters carried by the pinned-letter hypothesis, which is
the shape an induction on `⊡`-nesting depth consumes. The `box` case is `Iff.rfl`: its clause
quantifies over all histories and all times of the model (`box_mem_tpOf_transfer` is the type-level
reading), the two compared histories live in the same model, and that is the lemma's only
hypothesis beyond closure membership — so no hypothesis of it fails here and nothing has to be
excluded. This is the answer to the question the route decision left open, and it is a compiled
answer rather than an assumption. -/
theorem truthAt_iff_of_lab_eq_of_stabPinned
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (L : PlusFormula → Prop)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hlab : ∀ (v : ℤ) (p : Atom), lab (objAt g v) p = lab (objAt g' v) p)
    (hL : ∀ χ : PlusFormula, L (PlusFormula.stab χ) → ∀ v : ℤ,
      (PlusTruthAt (ladderModel step pend fwd bwd lab) σ v (PlusFormula.stab χ) ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) σ' v (PlusFormula.stab χ))) :
    ∀ ψ : PlusFormula, StabPinned L ψ → ∀ z : ℤ,
      (PlusTruthAt (ladderModel step pend fwd bwd lab) σ z ψ ↔
        PlusTruthAt (ladderModel step pend fwd bwd lab) σ' z ψ) := by
  intro ψ
  induction ψ with
  | atom p =>
      intro _ z
      rw [PlusTruth.atom_iff, PlusTruth.atom_iff, hσ z, hσ' z]
      change lab (objAt g z) p = true ↔ lab (objAt g' z) p = true
      rw [hlab z p]
  | bot => intro _ z; exact Iff.rfl
  | imp a b iha ihb => intro h z; exact imp_congr (iha h.1 z) (ihb h.2 z)
  | box a _ => intro _ z; exact Iff.rfl
  | untl a b iha ihb =>
      intro h z
      rw [PlusTruth.untl_iff, PlusTruth.untl_iff]
      constructor
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mp he, fun r h1 h2 => (iha h.1 r).mp (hgd r h1 h2)⟩
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mpr he, fun r h1 h2 => (iha h.1 r).mpr (hgd r h1 h2)⟩
  | snce a b iha ihb =>
      intro h z
      rw [PlusTruth.snce_iff, PlusTruth.snce_iff]
      constructor
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mp he, fun r h1 h2 => (iha h.1 r).mp (hgd r h1 h2)⟩
      · rintro ⟨s, hs, he, hgd⟩
        exact ⟨s, hs, (ihb h.2 s).mpr he, fun r h1 h2 => (iha h.1 r).mpr (hgd r h1 h2)⟩
  | stab a _ => intro h z; exact hL a h z

/-- **THE WIDENED COROLLARY: the stab-free atom-valuation agreement on closure types.** With the
`box` arm widened, the fragment Phase 11.5 consumes is STAB-FREE and nothing more: when the closure
carries no `⊡` letter the pinned-letter hypothesis is vacuous and two ladder paths with the same
atom row at every position realize the same closure type at every position, `□` letters
included. -/
theorem tpOf_stabFree_eq_of_lab_eq
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    {k k' : ℤ} {g g' : ℤ → LadderState Q pend}
    (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t)) (hσ' : ∀ t : ℤ, σ'.state t = (t + k', g' t))
    (hlab : ∀ (v : ℤ) (p : Atom), lab (objAt g v) p = lab (objAt g' v) p)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) (z : ℤ) :
    tpOf (ladderModel step pend fwd bwd lab) φ σ z
      = tpOf (ladderModel step pend fwd bwd lab) φ σ' z := by
  ext ψ
  rw [mem_tpOf_iff, mem_tpOf_iff]
  exact and_congr_right fun hmem =>
    truthAt_iff_of_lab_eq_of_stabPinned fwd bwd lab (fun _ => False) σ σ' hσ hσ' hlab
      (fun _ h => absurd h (fun h => h)) ψ (stabPinned_false_of_mem_closure hno ψ hmem) z

/-- **THE INSTANCE THE ALTERNATIVE-HISTORY PROTOTYPE PREDICTED, GENERALISED AWAY FROM THE FIXTURE.**
A pend-profile-preserving relabelling of a ladder path that leaves every ATOM ROW alone realizes the
SAME stab-free closure type as the original at every position. The prototype's compiled
`alt_atoms_eq_spliced_atoms` — one atom, one fixture, the alternative and the spliced path hitting
the `p`-state at exactly the same positions — becomes an instance of this statement's HYPOTHESIS
rather than a statement of its own.

This is the one place the alternative-history construction and the truth-transport layer meet, and
it is worth saying exactly how far it reaches. The relabelling may move the object state at a
position (`altWalkPath_not_vacuous`); what it may not move is that state's atom row. So this is not
a type transport across a change of the realized valuation, and it is not a repair of half (ii):
the refuted statement is about the SPLICE, which lengthens a pending region and changes which
positions exist, and no hypothesis here constrains such a surgery. -/
theorem tpOf_eq_of_altWalkPath_of_lab_eq
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (w' : ℤ → Q) (hpend : ∀ v, pend (w' v) = pend (objAt g v))
    (hstep : ∀ v, step (w' v) (w' (v + 1)) = true)
    (hlab : ∀ (v : ℤ) (p : Atom), lab (w' v) p = lab (objAt g v) p)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t)) (z : ℤ) :
    ∃ τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
      (∀ t : ℤ, τ.state t = (t, altWalkPath g w' hpend t)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ τ z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  have halt : IsLadderPath step pend (altWalkPath g w' hpend) :=
    altWalkPath_isLadderPath g hg w' hpend hstep
  obtain ⟨τ, hτ⟩ := exists_hist_of_isLadderPath fwd bwd (altWalkPath g w' hpend) halt
  refine ⟨τ, hτ, ?_⟩
  refine tpOf_stabFree_eq_of_lab_eq fwd bwd lab φ (k := 0) (k' := 0) τ σ
    (fun t => by simpa using hτ t) (fun t => by simpa using hσ t) ?_ hno z
  intro v p
  rw [objAt_altWalkPath]
  exact hlab v p

end Hist

/-! ## The construction the cell-level route names, and the rigidity it meets

The cell-level agreement asks, for a `kappa`-collision between `(c, n)` and `(c', n')`, that the
stab-free part of the cell at `⟨(q, c, n), _⟩` equal the stab-free part of the cell at
`⟨(q, c', n'), _⟩`. Read through `mem_cellAt_ladder_iff`, the inclusion asks for a LADDER PATH
through the second state realizing the type a given path through the first realizes; and the one
landed way to make two ladder paths realize the same stab-free type is `tpOf_stabFree_eq_of_lab_eq`,
whose hypothesis is pointwise agreement of the ATOM ROW. So the construction the route names is:

  given a ladder path `g` and a target counter pair `(c', n')`, produce a ladder path `g'` with
  `objAt g' z = objAt g z`, `cntAt g' z = c'`, `nxtAt g' z = n'`, and the SAME atom row as `g` at
  every position.

That is `AtomPreservingCountMove` below. Its `n` half is free: the next-deadline register only has
to `Drift`, and `exists_ladderPath_pair_nxtAt_ne` already compiles two ladder paths sharing an
object walk and differing in `n` at every position. Its `c` half is where the two requirements
meet, and they meet BADLY. `cntAt_eq_of_pend_eq` says the countdown is a function of the pend
profile alone, so moving `c` means moving the pend profile; and `PendFactorsLab` below names the
condition under which moving the pend profile means moving some atom row — namely that the pending
bit is recoverable from the atom row, which `pendFactorsLab_of_atom` shows happens as soon as the
labelling carries the pending bit as one of its atoms. Under that condition the two requirements
are jointly unsatisfiable: `atomPreservingCountMove_refuted`.

**What this refutes and what it does not.** It refutes the CONSTRUCTION, for every object whose
pending bit is readable in the language — and the realization statement quantifies over every
labelling, so such objects are not excluded by anything. It does NOT refute
`CellLEZeroConstOfKappaEq`: a cell is a set of TYPES, and two ladder paths can realize the same
closure type without agreeing on a single atom row, so the obligation can be met by a construction
that does not preserve the valuation pointwise. No such construction is stated anywhere in the
tree, and none is invented here. -/

section Rigid

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **The pending bit factors through the atom row.** Two object states with the same atom row
carry the same pending bit. This is a condition on the PAIR `(pend, lab)` and on nothing else, and
it is what turns `cntAt_eq_of_pend_eq`'s pend-profile rigidity into a rigidity of the atom-valuation
transport itself.

Paper: — (a condition on this frame scheme's labelling, with no literature counterpart) -/
def PendFactorsLab (pend : Q → Bool) (lab : Q → Atom → Bool) : Prop :=
  ∀ q q' : Q, (∀ p : Atom, lab q p = lab q' p) → pend q = pend q'

/-- **The condition holds as soon as the labelling carries the pending bit as one of its atoms.**
There is nothing exotic about such a labelling: the realization statement quantifies over every
`lab : Q → Atom → Bool`, so a labelling one of whose atoms IS the pending bit is admitted by the
statement exactly as any other is. -/
theorem pendFactorsLab_of_atom (lab : Q → Atom → Bool) (p : Atom)
    (h : ∀ q : Q, pend q = lab q p) : PendFactorsLab pend lab :=
  fun q q' hrow => by rw [h q, h q', hrow p]

/-- **THE ATOM-VALUATION TRANSPORT IS COUNTDOWN-RIGID.** When the pending bit factors through the
atom row, two ladder paths with the same atom row at every position carry the same countdown at
every position. The atom-valuation agreement of the preceding section therefore reaches only ladder
states whose countdown is already the original one, and the freedom it buys over half (i) — which
is real, `altWalkPath_not_vacuous` — is freedom in the OBJECT STATE at a position, never in the
counter. -/
theorem cntAt_eq_of_lab_eq_of_pendFactorsLab (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g')
    (hlab : ∀ (v : ℤ) (p : Atom), lab (objAt g v) p = lab (objAt g' v) p) (u : ℤ) :
    cntAt g u = cntAt g' u :=
  cntAt_eq_of_pend_eq g g' hg hg' (fun v => hfac _ _ (fun p => hlab v p)) u

/-- **THE CONSTRUCTION THE CELL-LEVEL ROUTE NAMES**, as a schema so that its refutation is a
theorem about a named object rather than a remark. Every ladder path can be replaced, at a chosen
position, by one through the same object state with ANY admissible counter pair there, preserving
the atom row at every position. Nothing is assumed about how the replacement is built. -/
def AtomPreservingCountMove (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) : Prop :=
  ∀ (g : ℤ → LadderState Q pend) (z : ℤ) (c' n' : ℕ), IsLadderPath step pend g →
    c' ∈ Adm pend (objAt g z) →
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = c' ∧ nxtAt g' z = n' ∧
      ∀ (v : ℤ) (p : Atom), lab (objAt g' v) p = lab (objAt g v) p

/-- **THE CONSTRUCTION IS REFUTED whenever the pending bit factors through the atom row**, at
every ladder path and every admissible target countdown that differs from the path's own. The
`c` coordinate is the whole of the obstruction: the hypothesis names a target countdown `c'`
different from `cntAt g z`, and the conclusion of the schema would hand back a path whose atom row
agrees with `g`'s everywhere and whose countdown at `z` is `c'`, which
`cntAt_eq_of_lab_eq_of_pendFactorsLab` forbids. -/
theorem atomPreservingCountMove_refuted (lab : Q → Atom → Bool)
    (hfac : PendFactorsLab pend lab)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) (c' : ℕ)
    (hadm : c' ∈ Adm pend (objAt g z)) (hne : cntAt g z ≠ c') :
    ¬ AtomPreservingCountMove step pend lab := by
  intro hmove
  obtain ⟨g', hg', _, hc, _, hlab⟩ := hmove g z c' 0 hg hadm
  exact hne (((cntAt_eq_of_lab_eq_of_pendFactorsLab lab hfac g' g hg' hg hlab z).symm.trans hc))

end Rigid

/-! ## The obligation of the cell-level agreement, stated and not proved

The deliverable the route names is `cellLE_zero_const_of_kappa_eq`: the depth-`0` half of the
agreement, at the level of the CELL. It is stated here as the schema below and it is NOT proved;
the theorem name is reserved for its proof and is claimed by nothing in this module.

**Which of the route's landed inputs the statement's own shape commits to.** It commits to (d), the
collision readings of `kappa` (`kappa_eq_components`, `eq_or_both_ge_of_min_eq`,
`clipIdx_regime_of_eq`), which is what the hypothesis `kappa … (c, n) = kappa … (c', n')` is read
through, and to the parameter conditions `ParamsOk`, without which the statement is FALSE
(`ladder-unconstrained-parameter-refutation.lean`). It commits to the stab-free fragment of
(b) — the closure carrying no `⊡` letter is the hypothesis, exactly as `tpOf_stabFree_eq_of_lab_eq`
carries it — and so is the depth-`0` statement rather than the whole agreement. It does NOT commit
to (a) or to (c): no relabelling and no splice appears in it, and it is an equality of SETS of
types over ALL histories through the two states, never a transport along a chosen pair of paths.
That is what keeps it clear of `Probe761S`, which separates two particular histories
(`AltHistory.chiS_in_cell_at_original_state` compiles that the separating formula does not separate
the CELLS at the refutation's own witness position), and clear of `no_positionwise_lift`, which
refutes the positionwise lift shape.

**The construction is the open part, and it is open in a specific way.** The one construction the
route named is refuted above for every object whose pending bit is readable in the language; the
wired probe `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`
exhibits such an object with the parameter conditions discharged at the periodicity fixpoint's own
outputs, a populated collision at `c ≠ c'`, and a ladder path through EACH of the two states — so
the obligation is non-vacuous on both sides while the construction is unavailable. What is left
open is a construction that preserves the realized TYPE without preserving the valuation
pointwise. -/

section Obligation

variable {Q : Type} [Fintype Q] [Nonempty Q]

/-- **The collision family is populated, uniformly in the parameters.** Shifting both counters by
a common multiple of `P + 1` leaves every one of `kappa`'s five coordinates alone, once both
counters are at or above their own thresholds: the two clipped coordinates are pinned at the
threshold, the two residues are unmoved by a multiple of the modulus, and the gap is unmoved by a
COMMON shift. So `kappa`-collisions with `c ≠ c'` exist at every parameter tuple whatsoever, and
the agreement's hypothesis is never vacuous. -/
theorem kappa_eq_of_shift (Tc Tn P B c n m : ℕ) (hc : Tc ≤ c) (hn : Tn ≤ n) :
    kappa Tc Tn P B (c + m * (P + 1), n + m * (P + 1)) = kappa Tc Tn P B (c, n) := by
  have hcm : (c + m * (P + 1)) % (P + 1) = c % (P + 1) := by
    simp [Nat.add_mul_mod_self_right]
  have hnm : (n + m * (P + 1)) % (P + 1) = n % (P + 1) := by
    simp [Nat.add_mul_mod_self_right]
  have hclip : clipIdx B (c + m * (P + 1)) (n + m * (P + 1)) = clipIdx B c n := by
    unfold clipIdx; split <;> split <;> omega
  simp only [kappa, Prod.mk.injEq, Fin.mk.injEq]
  refine ⟨by omega, hcm, by omega, hnm, hclip⟩

/-- **THE OBLIGATION OF THE DEPTH-`0` CELL-LEVEL AGREEMENT**, stated as a schema and proved
nowhere. Under the parameter conditions, for a `kappa`-collision between two admissible counter
pairs at the same object state, and for a closure carrying no `⊡` letter, the cells of the ladder
model at the two ladder states are EQUAL. The `ℤ` component of the world state is invisible to
`cellAt` and is written all the same, as the record requires.

This is the statement `cellLE_zero_const_of_kappa_eq` would carry. It is a definition and not a
theorem precisely because the construction it needs is not identified: see the section docstring
above for what is refuted, what is open, and why the two are different. -/
def CellLEZeroConstOfKappaEq (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (z : ℤ),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
        = cellAt (ladderModel step pend fwd bwd lab) φ
            ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z

end Obligation


end FormalSystem.Metalogic.Decidability.RaySummary
