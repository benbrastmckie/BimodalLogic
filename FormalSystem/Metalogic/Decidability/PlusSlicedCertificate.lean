/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Basic
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Frame
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Splice
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Position
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Live
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Canon
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Window
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixture
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Stable
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Tail
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.FixtureStable
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Timed
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixpoint
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Computed
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fold
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Unroll
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.LiveFix
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Bridge
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.HalfRun
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Check
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Sound
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Complete
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Embed
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.EmbedComplete
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Examples

/-!
# `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate` — the time-sliced L⁺ certificate

The certificate the L⁺ semantics actually has: a **time-sliced** bi-serial labelled graph presenting
a frame on the infinite carrier `ℤ × Fin n` with finite fibres.

## Why this subtree exists beside `PlusWitnessFamily/`

`PlusWitnessFamily/` is sound and stays. What it is not is **complete**:
`PlusWitnessFamily/Limits/NoCertificate.lean`'s `not_exists_plusCertifies_pumpTarget` exhibits a
ℤ-time non-validity that no family of that class certifies, under no hypothesis at all, and
`Limits/HopFree.lean` retires the hop-free producer separately. Neither failure is a missing bound;
both are structural, and the two that matter here are:

* **all-threads fulfilment.** (C2') is a demand about *every* thread of a finite, eventually
  periodic presentation, so every cycle reachable in the periodic region is a thread, and a target
  whose countermodels must contain a cycle with an exit under a pending eventuality is out of reach.
  This subtree replaces the demand with **fulfilment of live positions only**, computed as a
  fixpoint rather than demanded as a field, so a path that postpones an eventuality forever is
  simply a different, truthful, labelled path.
* **the finite carrier.** A certificate presenting a finite-carrier frame cannot certify `θ.neg`, a
  `⊡`-free ℤ-time non-validity the landed `Formula`-side family already certifies: no frame built
  by `FrameOver.ofStep` satisfies that formula's negation at any finite carrier. The carrier here
  is `ℤ × Fin n`: infinite, with finite fibres.

Absolute-time alignment also disappears, because a slice's own time is the only time there is:
there are no rows pinned to an absolute origin, so there is no period to align and no offset to
compute. `PlusWitnessFamily/Compression/Extract.lean`'s alignment half is retained and unused for
exactly that reason; see its header.

## Soundness is not at issue in either direction

`PlusSharingWitnessFamily.plusTruth_iff_mem` and `...plusRefutes_of_certifies` are untouched by this
subtree, and this subtree's own soundness direction targets the same unchanged export,
`PlusWitnessFamily.PlusRefutes Γ Del`. What is new is the completeness side.

## Submodules

- `PlusSlicedCertificate.Basic`: `PlusGraphPath`, `PlusSlice`, `PlusSlicedCertificate`, the
  three-segment readout with its decoding-region and periodicity lemmas, `exists_window_eq`,
  bi-seriality in both the `∀ t` and the window-decided form with `biSerial_iff_window` bridging
  them, and `onePointCertificate` — the finite-graph special case, exhibited rather than asserted
- `PlusSlicedCertificate.Frame`: the presented frame `G.frame h` on the **infinite** carrier
  `ℤ × Fin G.n` (its infinitude proved, not asserted), the model `G.model h`, the history space
  `mem_HF_iff_slicedPath` in both directions, `pathHistory`, and the shift-normalization pair
  `plusTruthAt_shiftBack` / `timeShift_offset_zero`
- `PlusSlicedCertificate.Splice`: the **Q5 factorization** — `histories_through_paste`,
  `truth_of_agree_of_type_eq` with its `paste` instance `label_splices_of_type_eq`, and
  `forall_forall_or_iff` — assembled into `stab_factors` and its `⊡`-shaped reading
  `not_stab_factors`. This is the justification for `live = fwdLive ∩ bwdLive`
- `PlusSlicedCertificate.Position`: the finite position space over one slice with its cardinality,
  the one-step position graph `succP` / `predP` with their adjointness, and
  `mem_succP_of_path` — the replacement for the plan's (false) `succP`-totality obligation; see
  that module's header for the counterexample
- `PlusSlicedCertificate.Live`: liveness as a property of the certificate's **own runs** —
  `LabRun`, the two halves `FwdLive` / `BwdLive` and their conjunction `Live`, the two propagation
  lemmas `untl_push` / `snce_push`, the label-level splice, and **both** directions of the
  characterization (`live_of_path`, `exists_path_of_live`, `live_iff`) at an arbitrary `t : ℤ`
- `PlusSlicedCertificate.Canon`: the **canonical labelling** of a step path — `canAt` by recursion
  on the formula, `canLab`, and `canRun`, by which **every** `G.edge`-path is a locally coherent,
  fulfilling `LabRun` on (C3b) alone. The uniqueness half (`canAt_iff_mem_lab`, `lab_eq_canLab`)
  says a fulfilling run's labelling is *forced* by its state path, and `live_iff_canLab` reads the
  live set off the edge-path space with nothing else in it and nothing missing. This is what the
  step "a history of the presented frame is an offset step path, hence a labelled path of `G`"
  actually requires: the true type cannot play the role, and that module's header records why
- `PlusSlicedCertificate.Fixture`: the window-width fixture — a bi-serial certificate of back
  period `1` in which one position is live at `-1` and occupied by no run at any time `≤ -2`,
  although the slice and the position set are literally the same at all those times
  (`live_not_determined_by_slice`). This is what rules out the single-period window and confirms
  the doubled lower endpoint, stated against the real endpoints by `Fixture.window_verdict`
- `PlusSlicedCertificate.Window`: the **combined** window — `NB` / `NF` / `NM` from the least common
  multiples of the certificate's and the target path's own segment lengths, the six compatibility
  facts, the doubled endpoints `winLo` / `winHi` with `winTimes`, and the fold `exists_win_eq` /
  `forall_iff_win` that reduces a `∀ t` claim over **both** `G.slice` and `G.target.decoded` to the
  window. `Basic.lean`'s `exists_window_eq` folds the slice sequence alone and cannot state this
- `PlusSlicedCertificate.Timed`: the **rolled** timed carrier `TPos := G.Pos × ℤ` with its finite
  vertex set `verts` (`TPos` is deliberately not a `Fintype`; the `Fintype` a fixpoint needs comes
  free from `verts`, confirmed by an `example`), and the wrapping `nextTime` / `prevTime` with their
  edge, membership and **faithfulness** lemmas — the wraps preserve the slice sequence, the target
  path's data and the position space alike. The fixpoints and the bridge to `Live` are not here yet
- `PlusSlicedCertificate.Fixpoint`: the **existential** fixpoint machinery the sliced side needs, at
  an arbitrary finite graph. `Nu.gfp` is the greatest fixpoint of an arbitrary deflating monotone
  contraction, stated at an arbitrary `F` rather than an arbitrary successor function because the
  eventuality-aware liveness fixpoint is a *nested* one. `EGFix.gfp` is the instance at "has a
  successor in the set" (an infinite walk exists) and `EUFix.lfp` the existential `E[g U e]` (some
  walk delivers), each with membership proved **equivalent** to the existence of the walk it
  describes, and `EUFix.lfp_mono_V` supplying what a nested outer contraction needs of its inner
  test. `AUFix` is the universal `A[g U e]` operator and is deliberately not used here; that
  module's header records why an existential outer fixpoint cannot consume a universal inner one
- `PlusSlicedCertificate.Computed`: the four fixpoints instantiated at the timed graph —
  `fwdWalkable` / `bwdWalkable` (`EGFix.gfp` at `succT` / `predT`: an infinite walk exists) and
  `untlReach` / `snceReach` (`EUFix.lfp`: some walk delivers), each with **both** directions of its
  own graph-theoretic characterization. It does **not** claim any of the four equals `Live`; that
  equality is the bridge, and nothing here stands in for it
- `PlusSlicedCertificate.Fold`: the two folding relations `FoldF` / `FoldB` on times, with each
  wrap proved to be a fold (`foldF_nextTime` / `foldB_prevTime`) and folded times proved to carry
  the same slice, the same target datum, the same edge relation, the same position space and the
  same one-step position graph. Each relation carries the **residue** condition rather than the data
  agreement it implies, because only the residue survives a common step (`foldF_succ` /
  `foldB_pred`). This is what will let a graph walk be read as a ℤ-indexed run
- `PlusSlicedCertificate.Unroll`: a graph walk read as a ℤ-indexed half-run. `fwdWalk_foldF` /
  `bwdWalk_foldB` are the induction saying a walk's window time at step `k` is fold-equivalent to
  the genuine time, and everything else is that composed with one of `Fold`'s transports: the walk's
  positions are positions of the **genuine** slices and step along `succP` / `predP` at the
  **genuine** times, with `fwdWalkPos` / `bwdWalkPos` reading them off as functions of the time. It
  builds no `LabRun` and mentions no `Live`
- `PlusSlicedCertificate.Stable`: the one-**combined**-period transfer operators `ΦBack` / `ΦFwd`,
  built from the one-step `stepBack` / `stepFwd`, with monotonicity at each level, the two subset
  lemmas placing their images on the window's own endpoint slices, the soundness direction
  `fwdLive_subset_stepBack` / `bwdLive_subset_stepFwd` and its two-directional counterpart
  `live_subset_stepBack` / `live_subset_stepFwd`, and `TailStable` with `decidableTailStable` — a
  **residue-indexed** demand, one conjunct per residue of each period, with `tailStable_back` /
  `tailStable_fwd` recovering the single-equation conjuncts as its `r = 0` instances. `L₀` / `R₀`
  are read off `Bridge`'s equality, and the **forward** direction of the linchpin is here
  (`mem_L₀_of_live_tail`, the transfer's soundness iterated). `exists_tailStable_repr` is **not**
  here and is not anywhere: it is false, and `FixtureStable` proves it false
- `PlusSlicedCertificate.Tail`: the **reverse** direction of the linchpin, which needs a genuine run
  rather than an iterate — the three-region position families `tailPos` / `headPos` at an arbitrary
  reference time, built from a shifted reference run, a transfer chain and a second reference run,
  with `live_of_mem_L₀_tail` / `live_of_mem_R₀_head` as their headlines and
  `tailStable_iff_window` / `tailStable_iff_window_fwd` as the biconditionals they complete at every
  time down either periodic tail. `exists_win_live_eq` is the form a clause stated at a window time
  costs to transport to an arbitrary time: every time has a window representative carrying the same
  slice **and** the same live set
- `PlusSlicedCertificate.LiveFix`: the **eventuality-aware** liveness fixpoint — `fwdLiveT` /
  `bwdLiveT` / `liveT` as a nested `Nu.gfp` whose inner reachability is relativized to the set being
  contracted, both directions of its fixpoint characterization, and `exists_fwdLive_walk` /
  `exists_bwdLive_walk`: one infinite walk inside the fixpoint discharging every eventuality pending
  anywhere along it. Nothing here mentions `Live` — that is `Bridge`'s business
- `PlusSlicedCertificate.Bridge`: the equality `G.Live s p ↔ (p, s) ∈ G.liveT` at a **window time**,
  by the position-level splice `runOfWalks` of a forward and a backward walk, and the `Decidable`
  instance for liveness it yields. The completeness direction factors into halves and needs no box
  clause; the soundness direction does neither — it consumes both halves at once and needs (C3b)
  `BoxLabelFaithful`
- `PlusSlicedCertificate.Check`: the **decidable checker** — `Certifies` as nine clauses (three
  structural conjuncts off landed window biconditionals, then the target group), with
  `decidableCertifies` synthesized and each structural conjunct's instance confirmed in isolation.
  The existential side is stated on the position graph rather than on `PlusLocalCoherentSeqLab`,
  fulfilment is supplied by the computed live set rather than demanded of the target path, and the
  box clause is read on live positions rather than on the slice labelling; see that module's header
  for why each of those three is the only decidable form available. `forall_iff_win_succ` is the
  one-step-lookahead fold the `succP` clause needs and `Window.lean`'s `forall_iff_win` cannot give
- `PlusSlicedCertificate.Sound`: the **truth lemma** and the refutation interface it lands —
  `plusTruthAt_iff_canAt` relates truth in the presented model along an arbitrary edge path to
  `Canon`'s canonical membership predicate (not to a run's label, which would argue in a circle),
  and `plusRefutes_of_certifies` lands `PlusWitnessFamily.PlusRefutes Γ Del` **unchanged** — the
  same proposition the landed `PlusSharingWitnessFamily.plusRefutes_of_certifies` lands, beside it
  and not in place of it. The `□` case reads the box clause through `plusBox_const`, the `⊡` case
  reads (C5) at the window representative `Tail`'s `exists_win_live_eq` supplies, and `untl` /
  `snce` are a direct transfer because `canAt` takes the existential form of both
- `PlusSlicedCertificate.Complete`: the **converse** — `SlabTrue` (the slice labelling reports the
  truth of its own `□`- and `⊡`-arguments; the atoms need no clause, since the presented model's
  valuation *is* the labelling), the truth lemma from that alone with no checker clause as a
  hypothesis, and the three semantic clauses of `Certifies` constructed from it in the one order
  their dependencies permit — (C3b) first, because the computed/declarative liveness bridge consumes
  it, then (C5) and the box clause. `exists_plusSlicedCertificate_of_tailStable_countermodel` is the
  headline: a bi-serial, tail-stable, semantically labelled structure carrying a refuting path
  admits a box guess the checker accepts, on the same carrier. The produced certificate agrees with
  the given one on **six** fields rather than four, and that is forced rather than generous — the
  combined window is a least common multiple of the certificate's *and the target path's* own
  segment lengths, so a re-extracted target path with different periods would change the window, the
  computed live set and the tail-stability demand together. `Probe.exists_certifying_triv` exhibits
  a certificate meeting every hypothesis, so the statement is not empty
- `PlusSlicedCertificate.Embed`: the **construction** half of the embedding of the landed
  `Formula`-side witness family — `Periodic.segBack` / `segMid` / `segFwd` materialize an eventually
  periodic function as the three segments that decode back to it, `plusClosureOf_ofCtx` identifies
  an embedded context's L⁺ closure with the image of the base closure (whence **no `⊡`-formula is
  in an embedded closure at all**, so (C5) and `SlabTrue`'s second clause are vacuous there), and
  `WitnessFamily.sliced` is the certificate itself: slice width the lasso count, edges `i → i`
  only, the slice sequence and the target path cut at the family's common periods so that the
  combined window collapses to those same periods. `sliced_biSerial` is proved; the tail-stability
  demand is **evaluated** at two embedded certificates — `Embedded.emptyFamily_tailStable` and
  `Embedded.liveFamily_tailStable`, with `..._not_tailStableRaw` showing the liveness filter is
  load-bearing there — and is **not** claimed in general
- `PlusSlicedCertificate.EmbedComplete`: the **semantic** half of the same embedding. A truth lemma
  for the embedded model that stands on the family's own four certification conditions and on
  nothing the certificate has yet to establish — `Sound.lean`'s own truth lemma cannot serve,
  because it takes as hypotheses exactly what an embedded certificate is trying to establish. The
  self-loop edge relation is what makes a direct induction cheap: every history of the embedded
  frame has a **constant** index (`sliced_history_const`), so the `□` clause collapses to a
  quantifier over one index and one offset, which is what `BoxFaithful` reports.
  `sliced_target_lab_eq_canLab` and `sliced_slabTrue` are two of the four hypotheses of the
  completeness headline

## The closing record: what this subtree proves, and what it does not

### What the certificate class is

A `PlusSlicedCertificate Γ Del` is a **time-sliced** bi-serial labelled graph: a slice width `n`, a
three-segment eventually periodic sequence of slices (`back`, `mid`, `fwd`), a per-time edge
relation over `Fin n`, a per-time slice labelling, a box guess `bx`, and a target path with its own
three segments and its own target time. `Certifies` is the decidable condition the checker accepts
it under, and `decidableCertifies` is synthesized from the clauses rather than postulated.

### The carrier is infinite, with finite fibres, and that is forced

`G.frame h` presents a frame on `ℤ × Fin G.n`. The carrier is **infinite** — proved here, not
asserted — and its time fibres are finite, of size `G.n`. This is not a convenience. A certificate
whose presented frame has a **finite carrier** cannot certify a `⊡`-free ℤ-time non-validity that
the landed `Formula`-side witness family already certifies, so a finite-carrier certificate class
is incomplete for a fragment in which the `Formula`-side route is complete. The infinite carrier
with finite fibres is the weakest shape that escapes that obstruction while keeping every
per-time object a `Finset`, which is what keeps the checker decidable.

Restricting the language to the CTL-like fragment does **not** rescue the finite-carrier shape: the
`⊡`-free non-validity that defeats it already lies inside that fragment, so the sliced shape is
needed there too. Whether the fragment has a finite model property of its own is a separate,
research-first question, and this subtree neither answers it nor assumes an answer.

### What is proved

* **Soundness.** `Sound.plusRefutes_of_certifies`: an accepted certificate produces
  `PlusWitnessFamily.PlusRefutes Γ Del`, the **unchanged** export the landed
  `PlusSharingWitnessFamily.plusRefutes_of_certifies` lands. Nothing about soundness is at issue in
  this subtree, in either direction, and the landed sharing-family interface is untouched.
* **Relative completeness.** `Complete.exists_plusSlicedCertificate_of_tailStable_countermodel`: a
  bi-serial, tail-stable, semantically labelled structure carrying a canonically labelled refuting
  path at a window time admits a box guess the checker accepts, on the same carrier, with the same
  target path and the same target time. No hypothesis bounds the slice width or any segment length.
* **The embedding.** `WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`:
  every ℤ-time non-validity of an embedded `Formula` admits an accepted sliced certificate, so the
  class is non-vacuous on `⊡`-free targets and at least as strong there as the landed L class.

### What is refuted, and what is open

* The **finite-carrier** finite model property for this certificate shape is **refuted**: see the
  carrier paragraph above. That refutation is unconditional.
* The **sliced** finite model property is **OPEN, not refuted**. No module here states it, implies
  it, or treats it as settled either way, and nothing above bears on it. It is a separate piece of
  work.
* The expected slice width is doubly exponential in the target. That is a **research finding**
  recorded as such and is **not** a theorem of this tree: no slice-width bound, no tail-period
  bound and no complexity claim is proved anywhere in this subtree, and none should be read into it.

### The condition set as it actually stands: nine conjuncts

Read off the landed `Check.Certifies`, and not four or five as earlier drafts of this record said:

1. `BiSerial` — every time has an outgoing and an incoming edge (structural).
2. `TailStable` — the residue-indexed, liveness-filtered tail transfer equation (structural).
3. (C3b) `BoxLabelFaithful` — the box guess agrees with the slice labelling on state shapes.
4. `BoxLiveFaithful` — the box clause, read on **live** positions.
5. `G.targetTime ∈ G.winTimes`.
6. `TargetPathPos`.
7. `G.targetPos G.targetTime ∈ G.liveAt G.targetTime`.
8. (C4) `Target` — the premises and the negated conclusions at the target time.
9. (C5) `StabFaithful` — the stability-modal clause.

Two things this list corrects, each with its reason. (C3) `BoxFaithful` is **not** a conjunct:
`AgreesOnState` pins the slice labelling to a position's label only on the state shapes, so for a
`χ` of any other shape `χ ∈ G.slab t w` is unconstrained data and the demand would be about the
wrong object. `BoxFaithful` therefore stays in `Basic.lean`, unweakened and unused by `Certifies`,
and the clause carried instead is `BoxLiveFaithful`, on live positions. And clauses 5-7 are
target-group side conditions: `G.targetTime ∈ G.winTimes` is forced by the computed live set
existing only at window times, and narrows the class not at all.

**What (C3b) costs.** It narrows the class only away from certificates whose slice labelling
contradicts their own box guess — and away from no certificate a countermodel presents, since
`Complete.lean` constructs the guess from the labelling.

**What `TailStable` costs, stated plainly.** The forward conjunct is **liveness-filtered**
(`ΦFwd R₀ ∩ R₀fwd = R₀`), and the backward conjunct carries the mirror filter
(`ΦBack L₀ ∩ L₀bwd = L₀`): one filter per obligation direction, so reachable-but-dead positions are
filtered out rather than required to be live. The demand is **residue-indexed** — a bounded
quantifier over each period's residues, which is what the `⊡` clause of the truth lemma requires —
with the `r = 0` instances recovering the single-equation conjuncts verbatim. It therefore narrows
the class to structures whose liveness wraps faithfully at **every** residue, and deciding it costs
`G.NBnat + G.NFnat` `Φ` applications rather than two, each over a live-position set that is itself a
fixpoint. The narrowing is **not** harmless: `FixtureStable.not_tailStable_cert` exhibits a
certificate the demand rejects. The both-filtered demand is **not** a theorem — `TailStable` is a
field of `Certifies`, a per-certificate demand — because the backward conjunct fails in two
independent ways and only one is filterable: a `⊆` failure (junk positions; a filter removes them)
and a `⊇` failure (a pre-period, repaired by absorption and by **no** filter). `Position.lean`'s
header records that dichotomy.

### Where the asymmetry really lies

There is no claim anywhere here that `mem_fwdLiveT_of_fwdLive_fold` has no backward counterpart; it
has one, `Bridge.mem_bwdLiveT_of_bwdLive_fold`. What is one-directional is the **forward filter**,
and for a stated reason: `FoldB` relates two negative times, so it does not reach the right tail at
all, and on the right tail only the forward readout is available. `Bridge.lean` states exactly that.


## Tags

plus-language · certificate · time-sliced · completeness
-/
