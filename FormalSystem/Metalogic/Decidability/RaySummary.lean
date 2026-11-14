/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.Seam
import FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti
import FormalSystem.Metalogic.Decidability.RaySummary.Closure
import FormalSystem.Metalogic.Decidability.RaySummary.Trace
import FormalSystem.Metalogic.Decidability.RaySummary.Compose
import FormalSystem.Metalogic.Decidability.RaySummary.Transport
import FormalSystem.Metalogic.Decidability.RaySummary.Profile
import FormalSystem.Metalogic.Decidability.RaySummary.Periodic
import FormalSystem.Metalogic.Decidability.RaySummary.HitComplete
import FormalSystem.Metalogic.Decidability.RaySummary.Present
import FormalSystem.Metalogic.Decidability.RaySummary.HitOf
import FormalSystem.Metalogic.Decidability.RaySummary.StabCheck
import FormalSystem.Metalogic.Decidability.RaySummary.Realize
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel
import FormalSystem.Metalogic.Decidability.RaySummary.Certificate
import FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient
import FormalSystem.Metalogic.Decidability.RaySummary.LadderRealize
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree
import FormalSystem.Metalogic.Decidability.RaySummary.LadderPump
import FormalSystem.Metalogic.Decidability.RaySummary.LadderPin
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell
import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle
import FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow

/-!
# `RaySummary` — the seam interface for `⊡` over the time axis

Aggregator for the decidability side's interface to the `k`-type summary substrate
(`FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`). It holds the seam interface and the
realizability device beside it. `Seam.lean` states the `⊡` bridge `plusStab_iff_seamSummary`
against the single-family hypothesis bundle `Presents`, and `SeamMulti.lean` characterizes that
bundle (it is inhabited iff the seam is `⊡`-decided, `exists_presents_iff`) and states the
hypothesis-free bridge `plusStab_iff_forall_hit` over the realized family triples `Hit` of a
two-letter trace. The five modules after them are the device that reads such triples off a
finite presentation: the closure alphabet and the trace of a history as its unique anchored
local run (`Closure`, `Trace`), composition on representatives (`Compose`), finite labelled
presentations with a computable path-type closure (`Present`), and the computable realized-triple
set `hitOf` with its characterization (`HitOf`). The per-model bridge `hit_eq_hitOf_of_presented`
(`Trace`) says a seam's `HitCl` IS `hitOf` under the explicit realization hypothesis
`Presented`. That hypothesis now has a NON-VACUOUS instance, and `Realize.lean` is where it is
built: `Presented` is discharged for a model constructed FROM a presentation
(`presented_modelOf`), at ONE seam, for `box`/`stab`-free `φ`, under the eleven-field
consistency bundle `Cons` — and the Hit-level equality follows in one line
(`hitCl_modelOf_eq_hitOf`). It is discharged for no model NOT so constructed, and the
`box`/`stab`-bearing fragment is assigned to the README's requirement (W), whose status is now
precise: the ANCHOR LAYER of (W) is landed (`AnchorLayer.lean` — closure types `tpOf`, cells
`cellAt`, the `box`/`stab` fixpoint equations, the finite object `AnchorCons` with
`anchorCons_anchorCells` for EVERY model and the bound `anchorCells_ncard_le`; the requirement's
"for every time" quantifier is dropped by the theorem `box_time_invariant`), and the RUN LAYER —
the `untl`/`snce` nesting, the lift from one seam to validity — is BLOCKED on three named
obligations recorded in the README's "(W): what landed and what did not", with the shape of
(S)'s construction refuted as its soundness half by the wired probe
`w-soundness-shape-refuted.lean`. Nothing in this cluster states `PlusValidZTime` in any form.
So `hitOf` is computable on presentations, `Hit` is never computed for a model outright, and
nothing here is a decision procedure: no decidability result is proved, no complexity bound is
claimed, everything is under `[F.IsRegular]` over the `ℤ` time axis where the seam's fibre is
used (the anchor layer needs no regularity), and the cited fixtures are forward-only (no
backward Bool-fixture bridge exists).
A conditional per-seam `⊡` decider exists under `Presented` (`StabCheck`: `stabCheckSig`,
`stabCheck_iff_of_presented`, `decidableStabOfPresented`), and `Presented` is refuted as a
completeness carrier by the wired probe `presented-not-complete.lean`
(`specs/evidence/seam-gluing-ray-product/`), so that decider is vacuous on model A and decides
nothing about `PlusValidZTime` — see the README's verdict.

## Modules

* `RaySummary.Seam` — `SeamSummary`, `Presents`, `plusStab_iff_seamSummary`.
* `RaySummary.SeamMulti` — `SeamDecided`, `exists_presents_iff`, the two-letter interface
  (`seamTrace`, `stabTarget`, `Hit`), the hypothesis-free bridge `plusStab_iff_forall_hit`, and
  `PresentsMulti` with its inhabitant `presentsMulti_seamTrace`.
* `RaySummary.Closure` — the closure alphabet `clSig`, the local run conditions `LocalRun`,
  the anchors `Anchored`, and the signature-generic bridge `plusStab_iff_forall_hitSig`.
* `RaySummary.Trace` — the trace `clTrace` of a history over the closure alphabet, its
  soundness (`clTrace_localRun`, `clTrace_anchored`) and uniqueness
  (`eq_clTrace_of_localRun_anchored`, `clTrace_unique`); the realized set over the closure
  alphabet (`HitCl`, `plusStab_iff_forall_hitCl`, `hitCl_eq_iUnion`); and the realization
  hypothesis `Presented` with the per-model bridge under it (`presented_localRun`,
  `hit_eq_hitOf_of_presented`, `plusStab_iff_forall_hitOf_of_presented`).
* `RaySummary.Compose` — label-list segments (`listSeg`, `labels`,
  `kTypeOf_segZ_eq_listSeg`) and composition on representatives
  (`kTypeOf_listSeg_append_congr`).
* `RaySummary.Transport` — transport of a family triple along the deletion of a constant run:
  the keystone `segZ_const_of_kTypeOf_eq_replicate` (a segment with the `k`-type of a nonempty
  constant block is a nonempty constant block, `k ≥ 1`), the deletion colouring `deleteRun`, and
  the cut surgery `inFamily_of_shrink_run` with its `familyTriples` form
  `familyTriples_subset_deleteRun` — shrink direction only, under an explicit single-segment
  containment hypothesis; no `↔`, no re-cutting, and `m₀ + p ≤ Nat.card (KType sig k)` is a
  count of depth-`k` types and nothing else.
* `RaySummary.Profile` — the σ-star profile of a finite word (`starProfile`, `profile`,
  `cutProfile`, the finite type `Profile`): the summary that composes under concatenation where
  bare `k`-types do not under star (the cut-pair obstruction), with the star languages
  `StarZero`/`StarPlus`/`PrefixStar` read off it (`starPlus_iff_profile`,
  `prefixStar_iff_profile`) at `k ≥ 1`; `Nat.card (Profile sig k)` is a count of profiles and
  nothing else.
* `RaySummary.Periodic` — periodic transport: the bi-ultimately-periodic colouring
  `periodicColouring` (`w^(ω*) · m · v^ω`, letter read-outs `labels_periodicColouring_*`), its
  one-sided forms `fwdPeriodic`/`bwdPeriodic`, the tail type sets `FwdTypes`/`BwdTypes` of a
  colouring read from a seam time with their tail congruences, and the one-sided transports
  `exists_periodic_fwd`/`exists_periodic_bwd` (Ramsey over the profile, bounded representatives)
  assembled through the seam into `exists_periodic_subfamily`; every length bound is a count of
  pairs of profiles.
* `RaySummary.HitComplete` — requirement (C)'s general row: the three-piece gadget presenting a
  bi-ultimately-periodic word (`GadgetState`, `gadgetLab`, `gadgetStep`, `gadgetRun`) with its
  unique anchored run (`isRun_gadget_iff`) and realized triples (`hitOf_gadget_eq`), disjoint
  unions of presentations (`hitOf_sigma_eq`), the exhibited count `sizeBound` and the headline
  `exists_hitPresented`: for EVERY regular `ℤ`-model, seam, `φ` and `k ≥ 1`, a presentation with
  `Fintype.card Q ≤ sizeBound φ k` satisfies `HitPresented` — one seam, no complexity bound,
  nothing about `PlusValidZTime`.
* `RaySummary.Present` — finite labelled presentations with their runs (`IsRun`,
  `runTrace`), the computable path-type closure (`pathTypes`, `pathTypesNow`,
  `mem_pathTypes_iff`, `mem_pathTypesNow_iff`) and liveness (`fwdLive`, `bwdLive`,
  `fwdLive_iff`, `bwdLive_iff`).
* `RaySummary.HitOf` — the computable realized-triple set of a presentation (`hitOf`), read
  through liveness over disjoint segments (`fwdLiveSep`, `bwdLiveSep`; `Present`'s
  `fwdLive`/`bwdLive` are retained but not consumed), and its membership characterization
  against the family triples of the presentation's runs (`mem_hitOf_iff`).
* `RaySummary.StabCheck` — the `now`-free step graphs (`fwdNowFree`, `bwdNowFree`), the
  states on anchored runs by liveness (`OnRun`, `onRun_iff_live`), the presentation-level
  decider of the run-level `⊡` condition (`stabCheckSig`, `stabCheckSig_iff`), and its closure
  instance under `Presented` (`stabCheck_iff_of_presented`, `decidableStabOfPresented`),
  vacuous on model A where `Presented` is refuted.
* `RaySummary.Realize` — requirement (S), the soundness half: the decidable per-edge
  consistency conditions on a finite labelled presentation (`UCoh`, `deferGraph`, `ULive`,
  `SCoh`, `bwdDeferGraph`, `SLive`) and the two theorems forcing `LocalRun`'s eventuality
  clauses from them (`untl_iff_of_UCoh_ULive`, `snce_iff_of_SCoh_SLive`, the latter proved
  outright and not transported); the scope predicate `PlusFormula.BoxStabFree` with the
  closure-vacuity lemmas it buys (`not_box_mem_plusSubformulaClosure`,
  `not_stab_mem_plusSubformulaClosure`); the ELEVEN-field bundle `Cons` with `cons_localRun`
  (ten fields mirror a `LocalRun` field or a frame law; the eleventh, `nowUnique`, was derived
  from the realization theorem's own obligation); the constructed model `frameOf` / `modelOf`
  with its regularity instance and the explicit record that its carrier is infinite
  (`frameOf_isRegular`, `frameOf_not_finite_worldState`); and the realization theorem
  `presented_modelOf` with its Hit-level corollary `hitCl_modelOf_eq_hitOf`. Scope: ONE seam,
  `box`/`stab`-free `φ`, `[Fintype Q]` on the PRESENTATION only. Nothing there states
  `Decidable (PlusValidZTime φ)`.
* `RaySummary.AnchorLayer` — the anchor layer of requirement (W): closure types read off a
  model (`tpOf`, `mem_tpOf_iff`, `tpOf_timeShift`), the per-state cells (`cellAt`,
  `cellAt_eq_cellAt`), the four fixpoint equations a closure type satisfies by the truth
  clauses alone (`bot_not_mem_tpOf`, `imp_mem_tpOf_iff`, `box_mem_tpOf_iff` — one global bit,
  `stab_mem_tpOf_iff` — one bit per cell), the finite object `AnchorCons` on a set of cells with
  its completeness theorem for EVERY model (`anchorCons_anchorCells`, no presentation, no
  finiteness, no regularity hypothesis), `anchorCells_finite` and the cardinality bound
  `anchorCells_ncard_le` (`≤ 2 ^ (2 ^ |cl φ|)`, a count of cells and not a complexity bound),
  and the `Finset` twin `AnchorConsFin` with `decidableAnchorConsFin` (decidable on a concrete
  finite object, never about a model) and the bridge `anchorConsFin_iff`. No `[F.IsRegular]`,
  no `untl`/`snce` equation (the run layer, blocked), nothing about `PlusValidZTime`.
* `RaySummary.RunLayer` — the run layer's frame scheme, the regularity part of its first
  obligation: the branching core transcribed from the wired probe
  `b2b-frame-constructor-branching.lean` (`FwdFinBranch`, `BwdFinBranch`, `iterS_fwd_finite`,
  `iterS_bwd_finite`, `fib_finite_of_finBranch`, `saturation_of_finBranch`), the parallel
  constructor `ofSlicedStepFinBranch` (`ofSlicedStep`'s body with `[Finite W]` replaced by
  two-sided finite branching in its one `Saturation` slot; `SlicedFrame.lean` untouched) with
  its regularity instance, step lemma, infinite-carrier record and history characterization
  (`ofSlicedStepFinBranch_mem_HF_iff`), and the deadline ladder `Rlad` (`Drift`, `Count`) with
  two-sided finite branching for EVERY finite object (`Rlad_fwd`, `Rlad_bwd`), an infinite
  slice (`Rlad_slice_infinite`), and the frame `ladderFrame` it yields (`ladderFrame_isRegular`,
  `ladderFrame_step`); seriality is the object's own `fwd`/`bwd` hypotheses; depth `k = 1`.
  No `[F.IsRegular]`-free claim about validity, nothing about `PlusValidZTime`, no realization
  theorem (the run layer's phase 2, open).
* `RaySummary.LadderModel` — the admissible ladder carrier beside `ladderFrame`: the record
  that `ladderFrame`'s own seriality hypotheses are unsatisfiable (`no_fwd` for every object,
  `no_bwd_of_idle` for every object with an idle state — the frame has no instances), the
  admissibility set `Adm` (`{c | pend q = false → c = 0}`, a restriction of the CARRIER), the
  carrier `LadderState` with `ladderState_nonempty`, the restricted relation `RladAdm` with
  two-sided finite branching for EVERY finite object (`RladAdm_fwd`, `RladAdm_bwd`, pulled
  back along `Subtype.val`), the frame `ladderFrameAdm` with `ladderFrameAdm_isRegular`, and
  the model `ladderModel` whose valuation reads the object component only. `[Finite Q]` on
  the OBJECT only; the slice `LadderState Q pend` is infinite; `RunLayer.lean` untouched. No
  realization theorem (the run layer's phase 2, open — its stabilization statement in the
  counter pair is refuted by the wired probe `ladder-cell-refutation.lean`), no index of a
  ladder cell claimed, nothing about `HitPresented`, nothing about `PlusValidZTime`, no
  complexity bound.
* `RaySummary.Certificate` — the `K`-free, LABEL-LEVEL certificate of realizable closure types,
  promoted from the compiled probes `realizable-type-certificate.lean` and
  `certificate-sufficiency-dovetailing.lean`: the existential until-fixpoint
  (`euStep`/`euIter`/`euLfp` through `eu_mem_lfp_path_le_card`), the dovetailing theorem
  (`exists_dovetail_chain`), the product layer (`ClType`, `ProdState`, `locCoh`, `untlLink`,
  `coh`, `coh_iff`), the backward arm (`snceLink`, `cohBi`, `cohBi_iff`), the certificate
  predicates with the relation as a PARAMETER (`certLoc`, `certBiInf`, `certFwd`, `certBwd`,
  `certStab`, `certBox`, `certAdm`, `certAdm_iff`), the forward and backward chain
  constructions, `Realizes`, the splice, and the label-level sufficiency
  `realizes_of_certAdm_cohBi`. The idle-extended relation `cohIdle` is `cohBi` with both `pend`
  conjuncts dropped (`cohIdle_eq_cohBi_of_pend`, `cohIdle_of_cohBi`). REGION-INTERIOR: `coh` and
  `cohBi` require `pend` at both endpoints and no forward `Rlad` ray is pending forever
  (`exists_idle_of_rlad_ray`, `no_rlad_ray_of_pending_forever`, wired probe
  `no-pending-forever-ray.lean`), so the sufficiency is sufficiency for the interior of ONE
  region and transfers to the region segments of a ladder history, never to the history itself.
  NO ladder consequence is stated here; `[Fintype Q]` on the OBJECT only, no fibre bound, no
  finite width, nothing about `HitPresented` or `PlusValidZTime`, no complexity bound.
* `RaySummary.CounterQuotient` — the `K`-indexed half of that certificate layer: the counter
  quotient `CK` of the forced five-coordinate shape with its class map `kappa` (a CARRIER
  COORDINATE, never an index — `CK` does not factor `cellAt` on its own, which
  `ladder-cell-refutation.lean` refutes), the class-level step relation `RK` (the image of
  `Count`/`Drift` on classes, decidable by construction, with NO faithfulness claim — that is
  the gated counter-lift lemma's own content), the four parameters `Tcof`/`Tnof`/`Pof`/`Bof` as
  OUTPUTS of the periodicity fixpoint (`prodPre_periodic`, ported from the wired probe
  `closure-indexed-periodicity.lean`) and of the cascade recurrence (`iter_doubling`), the
  parameter-conditions predicate `ParamsOk` as the conjunction of the four sources (K1)-(K4)
  with its discharge lemma `paramsOk_params` at those outputs, the exclusion
  `AllZero.not_paramsOk_allZero` recording that the predicate FAILS at the all-zero tuple the
  fourteenth wired probe's refutation turns on, the `K`-indexed certificate conditions with
  `certStabK` rebuilt per `(q, κ)` (`certLocK`, `certBiInfK`, `certFwdK`, `certBwdK`,
  `certStabK`, `certBoxK`, `certAdmK`), and `Dmax` with its maximality (`dmax_maximal`: every
  certified set lies inside it) and the four union-stable conditions holding of it
  (`dmax_certLocK`, `dmax_certBiInfK`, `dmax_certFwdK`, `dmax_certBwdK`). NO ladder consequence:
  nothing relates `CK`, `RK`, `certAdmK` or `Dmax` to `Rlad`, `ladderModel`, `tpOf` or `cellAt`,
  and that `Dmax` itself satisfies the two acceptance conditions `certStabK`/`certBoxK` — which
  are equalities and so not union-stable — is claimed nowhere. `[Fintype Q]` on the OBJECT
  only, no fibre bound, no finite width, every quantity a COUNT, nothing about `PlusValidZTime`,
  no complexity bound.
* `RaySummary.LadderRealize` — the DEFINITIONAL layer of the ladder's realization statement, and
  only that: `typeOfCl` (the projection out of `Certificate.lean`'s landed closure component
  `ClType`), `certChain` (the bi-infinite certificate chain over the product carrier
  `Q × ClType φ × CK Tc Tn P B` — `relK` between consecutive positions, `certLocK` at every
  position, and the forward `untl` and backward `snce` obligations read as formula membership in
  the closure component, with NO `⊡`-nesting-depth stratification), and `LadderCons` (the
  consistency bundle: `certAdmK` on a candidate set together with the maximality clause
  `Dmax ⊆ R`, the acceptance conditions `certStabK` per `(q, κ)` and `certBoxK` as one global bit
  included through `certAdmK` and never dropped, and NO soundness field). `Cons`'s forward
  liveness field is REPLACED by the `Count`-driven decrease of the current deadline while the
  object is pending; its backward field is RETAINED as `certAdmK`'s own `certBwdK`, because the
  ladder's structural liveness is FORWARD-ONLY (wired probe
  `ladder-liveness-forward-only.lean`: an admissible path pending at every past time with its
  countdown unbounded into the past), and `Realize.lean`'s `SLive` and its neighbours do not
  transfer at all — they are indexed by `(clSig φ).preds` letters over a different labelling and
  do not elaborate at this carrier. NO theorem: the module holds three definitions, so nothing
  here is a soundness claim, a lift, or a realization theorem, nothing relates these conditions
  to `tpOf`, `cellAt` or `ladderModel`, nothing is claimed about `HitPresented` or
  `PlusValidZTime`, no index of a ladder cell is claimed at any parameters, and no complexity
  bound and no device-discrimination claim is made.
* `RaySummary.LadderAgree` — the RIGID ANCHORS of a ladder history, and the module the agreement
  of class-equivalent cells is to be proved in: `stab_mem_tpOf_iff_cell` (the `⊡` bit of a
  realized type is a datum of the cell at the point's own world state), the accessors `objAt`,
  `cntAt`, `nxtAt` and the path predicate `IsLadderPath`, the four readings of `Count` along a
  path, the rigid pending region (`cntAt_sub_of_pend`, `not_pend_of_count`,
  `cntAt_add_of_pend_back`: the countdown IS the distance to the region's end, so the region's
  first idle position sits at distance exactly `cntAt g u + 1`), the rigidity of the countdown
  under a fixed object walk (`cntAt_eq_of_obj_eq`: two paths with the same object walk carry the
  same countdown everywhere, so no replacement can move a counter without changing the walk — the
  library-level form of the refutation of the positionwise statement shape), and the window the
  `1`-Lipschitz next-deadline register imposes (`nxtAt_lipschitz`,
  `cntAt_le_nxtAt_succ_of_idle_past`: a pending position with any idle position in its past has
  `c ≤ n + 1`) with its dichotomy (`pend_past_of_nxtAt_lt`: a pending position with
  `n + 2 ≤ c` lies on a path pending at EVERY earlier position — the second regime, populated by
  the thirteenth wired probe's forward-only witness, and the one the gap coordinate separates),
  with the reading of a class collision off the counter quotient's coordinates
  (`kappa_eq_components`, `eq_or_both_ge_of_min_eq`, and `clipIdx_regime_of_eq`: at `2 ≤ B`, which
  `(K4)` requires, a collision at a fixed next deadline cannot straddle the two regimes, so a
  replacement argument may be given separately in each).
  CERTIFICATE-FREE by construction: no certificate condition, no maximum certified subset and no
  consistency bundle is named, because the acceptance condition collapses the `⊡` bits across a
  counter class and would make the agreement a consequence of the very obligations that read it.
  **The agreement itself is NOT landed**: three obstructions are recorded in the module docstring
  — the walk must be pumped, the model-level periodicity that pumping needs is not the landed
  certificate-graph fixpoint, and the `⊡` bit forces an induction on `⊡`-nesting depth. Nothing
  here is a realization theorem, nothing is claimed about `HitPresented` or `PlusValidZTime`, no
  index of a ladder cell is claimed at any parameters, and no complexity bound is claimed.
* `RaySummary.LadderIdle` — the idle pump: the register-anchored `d`-fold duplication of an idle
  block (`exists_iterIdleSpliced_ladderPath`), and the sharpened idle-gap lengthening schema with
  its verdict. The pump-layer inputs (the idle-cycle vocabulary, the idle-block countdown with
  its free pin clause, the idle-restricted `(objAt, tpOf)` pigeonhole) are `LadderPump.lean`'s;
  `LadderChain` is imported for `exists_ladderPath_of_walk_nxt_at` alone, the only landed lift
  that exposes the next-deadline register at a chosen position. `LadderWindow` imports it. It
  states ONE cell-level consequence, `forwardSlackWitnessed_of_cell_idleRunPumpable`, and that
  consequence is CONDITIONAL: the premise it runs on is an object/run hypothesis, not a
  consequence of `ParamsOk`, so no `ParamsOk`-level restriction is removed anywhere. The module
  ALSO holds the repository's first CELL-level REFUTATION of `ForwardSlackWitnessed`
  (`section IOne`): `forwardSlackWitnessed_refuted_I_one` falsifies it at amount `4` on a serial
  object with no idle self-loop, where every idle run has length exactly `1` and the amount
  ceiling `hasForwardSlack_amount_le` is forced by the OBJECT rather than by a choice of path.
  Its reach is bounded and the bound is compiled: `ceiling_slack_at_consumer_amount` shows the
  ceiling is slack at the amount `m · (P + 1)` the five depth-`0` `LadderCell.lean` schemas
  instantiate it at, so all five KEEP `ForwardSlackWitnessed`, no schema signature is touched,
  `certStabK`'s restatement obligation stays PROVISIONAL, and `not_idleRunPumpable` compiles that
  the refuted object cannot collide with the conditional discharge. The reserved
  `cellLE_zero_const_of_kappa_eq` is claimed by nothing here.
* `RaySummary.LadderWindow` — the ORDINARY WINDOW regime `c ≤ n + 1` of the depth-`0` cell
  obligation, the exact complement of the pending-forever gap `n + 2 ≤ c` that the five
  `LadderCell.lean` schemas carry: the collision's own room upgrade
  (`kappa_collision_window_room` — at `2 ≤ B` a class collision at a fixed register either pins
  the two countdowns equal or exhibits a positive multiple of `P + 1` TOGETHER WITH the strict
  room `c' ≤ n` for the larger one, the gap coordinate paying for it through
  `clipIdx_regime_of_eq` with the gap branch killed), and the three scale-invariant pin
  statements the regime's surgery reads (`window_anchor_compat_of_room`,
  `window_pin_compat_raise_of_gap`, `window_pin_compat_lower_of_spacing`), in which the
  displacement is an OPAQUE natural so none of them depends on the modulus, on `(K1)`, or on any
  parameter tuple. The regime's compensator is the IDLE RUN BELOW the position and not slack
  above it, so nothing here touches `ForwardSlackWitnessed` and the refuted deletion-above route
  is not re-entered. The reserved `cellLE_zero_const_of_kappa_eq` is claimed by nothing here and
  no declaration carries that name or any prefix of it; no path-level construction, no cell-level
  inclusion and no schema is stated, nothing is claimed about `HitPresented` or
  `PlusValidZTime`, no index of a ladder cell is claimed at any parameters, and no complexity
  bound is claimed.
-/
