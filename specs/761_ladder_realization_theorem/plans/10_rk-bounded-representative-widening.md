# Implementation Plan: Task #761

- **Task**: 761 - Ladder realization theorem: `LadderCons` and `ladderRealized` per ladder cell for all φ including box/stab letters
- **Status**: [IMPLEMENTING] (Phases 1-11.1, 11.3-11.5, 11.9 and 12.1 closed; Phase 11.2 closed and Phase 12.3 enterable now, with 11.8 behind 11.2 and 12.4, 12.5, 12.6 behind 12.3; Phases 11.6-11.7, 12.2 and 13-18 still behind Phase 11.9's INCONCLUSIVE verdict on the open depth-`0` core)
- **Effort**: 32.5 hours costable (Phases 1-10, 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 13, 14, 16, 17, 18), RE-DERIVED at this revision's authoring by summing this plan's own per-phase **Timing** lines rather than carrying the predecessor header figure: 17 hours landed (Phases 1-10 at 0.5/1/0.5/1/0.75/1.25/2/3/3.5/2, plus Phase 12.1 at 1.5, which has CLOSED since the predecessor revision counted it as open) and 15.5 hours open (Phases 12.2, 13, 14, 16, 17 and 18 at 1/2/1.5/2/1.5/1.5, plus the four phases this revision adds — 12.3, 12.4, 12.5 and 12.6 at 2.5/1.5/1.5/0.5). The predecessor's 26.5 moves to 32.5 by exactly the 6 hours those four new phases carry and by nothing else: no existing phase's **Timing** line is re-estimated by this revision. Phases 11, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9 and 15 are NOT COSTABLE — Phases 11, 11.1, 11.2, 11.3, 11.4, 11.5 and 11.9 closed against that declaration, the rest are open, and no hour figure is invented for any of them, the restated Phase 11.8 included
- **Dependencies**: 760, 775, 805, 806, 819, 820 — all six discharged (760/775 archived; 805/806 `[COMPLETED]`; 819 the presentation decision, now archived at `specs/archive/819_ladder_cell_presentation_design_decision/`; 820 the counter-lift gate table), and none of them is reopened or re-planned by this revision. NO OPEN GATING TASK IS NAMED BY THIS PLAN, and this revision adds none: the one definitional repair it introduces — the `repsCnt` widening of Phase 12.3 — lands in a module inside this task's own `file_scope` that no other live task declares. The external construction gate the predecessor revision removed stays removed; its record is archived at `specs/archive/836_ladder_type_preserving_cell_agreement_construction/` and is `[ABANDONED]`. The live successor chain on the open depth-`0` core is task 838 (`two_sided_open_core_pin_free_pigeonhole`, status `partial`) and its closed descendants 844, 849 and 850, whose landed work is INPUT rather than a gate; whether a `state.json` dependency edge to 838 is carried is the orchestrator's call and not this plan's. Phases 11.8 (behind the closed 11.2) and 12.3 are gated on nothing open and are enterable now
- **Research Inputs**:
  - specs/761_ladder_realization_theorem/reports/08_rk-bounded-representative-refutation.md — THIS REVISION'S PRIMARY INPUT: the compiled refutation of `rk_of_count_drift` at `repsCnt`'s landed bound (three `decide`-checked witnesses against the live library), the 900-tuple sweep that locates the defect in the bound rather than in the lemma, the parameter-generic construction the recommended replacement discharges, the `ParamsOk`-cannot-rescue-it finding, the monotonicity-and-dependents sweep, the interface-level restatement for Phase 11.8, and the measurement that Phase 11.9's probe is tracked but unwired
  - FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean — re-read at THIS revision's authoring for `repsCnt` (`:184`), `rkStepB` (`:190`), `RKb` (`:196`), `RK` (`:200`), `decidableRK` (`:203`), `rkStepB_iff` (`:207`), `rk_iff` (`:214`), `relK` (`:630`), `Dmax` (`:701-704`) and `dmax_maximal` (`:714`); the widening's blast radius and `Dmax`'s growth are measured from these, not carried
  - FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean — re-read for the module docstring's open-sub-question sentence (`:47`), which this revision retires, and for the three-condition "NOT landed" paragraph Phase 12.5 replaces
  - FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean — re-read for `spliced_at_region` (`:1260`), `exists_spliced_ladderPath` (`:1241`), `exists_spliced_ladderPath_of_pend_past` (`:1293`), `pinnedRegions_subset_Ico` (`:1405`), `cascadeDemand` (`:1445`) and the in-source `longFile` baseline (`:308`)
  - specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean — Phase 11.9's landed, compiling, UNWIRED probe (480 lines, measured at this revision's authoring), which Phase 12.4 wires
  - specs/archive/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md — the presentation-decision record whose maximum-certified-set finding Phase 12.6 re-reads against the widened `RK`; cited at its ARCHIVED path, the predecessor plan's pre-archive path having stopped resolving
  - specs/archive/836_ladder_type_preserving_cell_agreement_construction/summaries/01_obligation-repair-and-pump-layer-summary.md — THIS REVISION'S PRIMARY INPUT: the abandoned construction round's own record, including its explicit "For task 761's reviser" impact item. Ten phases closed, Phase 10 `[BLOCKED]` on the Phase 3 decision gate's FAIL branch
  - specs/archive/836_ladder_type_preserving_cell_agreement_construction/reports/01_type-preserving-cell-agreement-construction.md — the research that round ran on
  - specs/archive/836_ladder_type_preserving_cell_agreement_construction/plans/01_obligation-repair-and-pump-layer.md — the plan whose eight Lean Challenge Statements that round pinned; seven landed as theorems, the eighth (`cellLE_zero_const_of_kappa_eq`) did not
  - specs/archive/836_ladder_type_preserving_cell_agreement_construction/handoffs/phase-10-handoff-20261103T051549Z.md — the FAIL branch's five owed items, including the two named routes (a) and (b) for a successor
  - specs/archive/836_ladder_type_preserving_cell_agreement_construction/handoffs/phase-11-handoff-20261103T053018Z.md — the closing gate set, each exit read directly
  - specs/archive/836_ladder_type_preserving_cell_agreement_construction/issues.jsonl — the four blocking and two costly records this revision answers: `iss_1793676481950_X5nVmj` (the Phase 3 FAIL verdict), `iss_1793682949115_VWHeyc` (the Phase 10 blocker and the two routes), `iss_1793666338306_aFixsS` (the plan-gap: a plan cannot be written against an unidentified construction), `iss_1793680346301_9l9mvq` (the gate collision: a contingency file not listed under `Files to modify` cannot be committed by an implement dispatch), `iss_1793672574750_4C3zev` (the open core is TWO-SIDED, not regime-B-only)
  - specs/archive/836_ladder_type_preserving_cell_agreement_construction/.decisions.json — the recorded `(K4)` decision (Option A: carry a forward exactness depth), recorded autonomously and marked non-blocking, so open to revision
  - specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md — THE DECISIVE NEW INPUT, not named in the delegation: route (a) was ENTERED by the live successor task and its own decision gate returned FAIL with a compiled refuting object. `LadderPin.lean` landed (the pin-free dichotomy, the pigeonhole over region starts, the exponential `(K2)` reading)
  - specs/844_reanchored_deletion_half_depth_zero_cell/summaries/01_reanchored-deletion-half-summary.md — the re-anchored lift, the deletion theorem with the register exposed, the anchor-clause collapse, and `HasForwardSlack` as the named path-level regime
  - specs/849_forward_slack_discharge_and_exact_shift_iteration/summaries/01_forward-slack-exact-shift-summary.md — the regime's entry lemma, monotonicity, transport and vacuity, its NECESSITY by the compiled climbing-register path, its inhabitation, and the exact-shift iterated deletion
  - specs/850_upfirst_exact_shift_copy_boundary_types/summaries/01_upfirst-exact-shift-copy-boundary-summary.md — the up-first ordering with copy-boundary realized types exposed, `iterSpliceIdx`, and the clean-hypothesis restatements with the predecessor-pinned theorems kept verbatim as corollaries
  - FormalSystem/Metalogic/Decidability/RaySummary/README.md — the LIVE authority, re-read at this revision's authoring: the two register windows, the two-depth `(K4)`, the depth-`0` obligation's status paragraph, the pin layer and what it settles, and `(K1)`'s non-constraint of a spanning block's length
  - FormalSystem/Metalogic/Decidability/RaySummary/{LadderAgree,LadderPump,LadderPin,LadderChain,LadderRealize,CounterQuotient}.lean — read directly, not inferred from any summary; see `### Research Integration` for every claim confirmed and every discrepancy found
  - specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean — the forty-seventh wired probe: `Probe836A.cellLEZeroConstOfKappaEqPre_refuted` against the frozen `ParamsOkPre`, plus `not_paramsOkK4_two` and `kappa_D_dissolves`
  - specs/761_ladder_realization_theorem/summaries/05_ladder-cell-agreement-construction-refuted-summary.md — Phase 11.5's close: route B's named construction `AtomPreservingCountMove` is REFUTED in the library, and the obligation `CellLEZeroConstOfKappaEq` is a Prop-valued schema proved nowhere
  - specs/761_ladder_realization_theorem/handoffs/phase-11.5-handoff-20261102T215926Z.md — the mechanism of that refutation, the `n` half closing (`nxt_free`), and the finding that Phase 11.6 is not enterable from a base case that is stated rather than landed
  - specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean — the forty-sixth wired probe, `Probe761C`: `ParamsOk` discharged at the periodicity fixpoint's own outputs, a populated `kappa`-collision at `c ≠ c'`, a ladder path through EACH of the two ladder states
  - specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean — the forty-fifth wired probe: `Probe761S.splice_type_invariance_refuted`, half (ii) of the transport layer FALSE rather than open
  - specs/evidence/seam-gluing-ray-product/ladder-unconstrained-parameter-refutation.lean — the fourteenth wired probe, the compiled reason the parameter hypothesis exists
  - specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean — where `forward_window`, `backward_constraint`, `region_doubling`, `doubling_attained` and `iter_doubling` actually live; see the discrepancy finding below
  - specs/761_ladder_realization_theorem/reports/01_ladder-realization-theorem.md, reports/02_spawn-analysis.md
  - specs/761_ladder_realization_theorem/prototype/alt-history-cell-check.lean, prototype/interior-budget-check.lean, prototype/step0-budget-check.lean — retained prototype records, not wired and not gate-covered
  - specs/761_ladder_realization_theorem/handoffs/phase-11-handoff-20261019T015000Z.md, handoffs/phase-11-handoff-20261019T091503Z.md — the four candidate certified sets ruled out, and the walk-pumping surgery that landed
  - specs/761_ladder_realization_theorem/issues.jsonl, specs/761_ladder_realization_theorem/.decisions.json
  - specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md, specs/820_ladder_counter_lift_lemma_gated/summaries/01_counter-lift-gate-table-summary.md
  - specs/ROADMAP.md — read, not edited by any phase of this plan
- **Artifacts**: plans/10_rk-bounded-representative-widening.md (this file; supersedes plans/09_tight-chain-gate-regated-graph.md, which is RETAINED UNMODIFIED as the record of the round that re-pointed the phase graph onto an internal decision gate and ran that gate to its INCONCLUSIVE verdict)
- **Reports Integrated**: 01_obligation-repair-and-pump-layer-summary.md; 01_type-preserving-cell-agreement-construction.md; 01_obligation-repair-and-pump-layer.md; phase-10-handoff-20261103T051549Z.md; phase-11-handoff-20261103T053018Z.md; issues.jsonl (836); .decisions.json (836); 01_pin-free-pigeonhole-open-core-summary.md; 01_reanchored-deletion-half-summary.md; 01_forward-slack-exact-shift-summary.md; 01_upfirst-exact-shift-copy-boundary-summary.md; 05_ladder-cell-agreement-construction-refuted-summary.md; phase-11.5-handoff-20261102T215926Z.md; ladder-cell-obligation-refutation.lean; ladder-cell-agreement-refutation.lean; 08_rk-bounded-representative-refutation.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The filed record asks for a library module carrying `LadderCons`, `ladderCons_localRun` and the
per-cell realization `ladderRealized` for ALL `φ`, `box`/`stab` letters included, on presentation
(a) — the set-valued per-state datum, with `ladderRealized` the FIBRE EQUATION and the
factorization lemma for `CK` its COROLLARY. That decomposition, its agreement-first phase order,
its six recorded Challenge statements and its landed Phases 1-11.2, 11.3-11.5, 11.9 and 12.1 all
stand unchanged. **What this revision does is repair two recorded statements that compiled evidence
has refuted, and open the work those repairs unblock.** Neither repair touches the open depth-`0`
core, and neither gates on it.

**The first repair is a definitional widening.** The closed Phase 12.1 landed two of `Real`'s six
certification conditions and excluded three — `certBiInfK`, `certFwdK`, `certBwdK` — for one shared
missing link: no theorem derives an `RK` edge from an actual `Count`/`Drift` step. It named the one
lemma that would supply it, `rk_of_count_drift`, and recorded as open whether `repsCnt`'s own bound
`Tc + Tn + P + B + 2` suffices for its construction. It does not suffice, and the answer is now
compiled rather than argued: three `decide`-checked witnesses refute the lemma at that bound, in two
independent directions, and an exhaustive sweep finds the bound failing on more than half of a
900-tuple grid. The same sweep finds NO class pair that is unliftable in a wider window, so the
defect is the bound and not the lemma, the repair is a definitional widening and not a new
hypothesis, and `ParamsOk` cannot close the gap because it constrains `P` only by divisibility from
below. Phases 12.3 through 12.6 are that repair: widen `repsCnt` to the bound a parameter-generic
construction actually discharges, land `rk_of_count_drift` without `ParamsOk`, land the three
re-homed conditions, carry the compiled reason into the evidence gate against the FROZEN
pre-widening bound, and re-read — rather than inherit — the one claim the widening threatens, since
`Dmax` is the union of certified sets and a weaker relational condition certifies strictly more of
them.

**The second repair is a restatement at the interface level.** Phase 11.8 was raised `[BLOCKED]`
because its Goal and its deliverable contradicted each other and the shape the deliverable named is
refutable: a walk that lengthens the earlier idle runs is not `spliceObj g a l`, and on the tight
chain — whose every pin pair is exactly tight — the `spliceObj`-shaped conclusion is false rather
than open. What its single consumer actually reads is narrower: the two facts `spliced_at_region`
exposes at the comparison position, the same object state and the countdown raised by `l`. That
statement the refutation leaves OPEN, and the cascade has a coherent mechanism for it — insert idle
positions strictly BELOW the comparison position's region start, so the walk at and above that start
stays pointwise fixed. Phase 11.8 is restated against it and returns to `[NOT STARTED]`, with its
blocker record carried verbatim as the compiled reason, and with the interface Phase 15 consumes
decided here rather than at dispatch time.

**What this revision does NOT do.** It does not lift, re-run or re-litigate the depth-`0` gate.
Phase 11.9 compiled the one claim the library's own README recorded as argued rather than compiled —
no positive deletion-derivative of the tight doubling chain lifts, with the countdown and the
register quantified away and the pins unbounded above — and its verdict was INCONCLUSIVE: the step
from that non-liftability to a cell inequality needs a closure formula whose letters FORCE the
realizing path to be a deletion-derivative of the chain, and that is the open core itself. So
Phases 11.6, 11.7, 12.2 and 13-18 stay behind that verdict exactly as the predecessor revision left
them. What this revision additionally owes that phase is the wiring its own Exclusions named: the
480-line probe it landed is tracked, compiling and absent from the evidence gate's arrays, which is
the one state that gate exists to catch and is not catching.

**Definition of done for this round's revision**: no recorded statement of this plan that compiled
evidence has refuted is left standing as a live deliverable; the three `Real` conditions the closed
Phase 12.1 excluded are re-homed onto a phase whose prerequisite this plan itself lands; the
widening's one semantic consequence is CHECKED by a phase rather than inherited from a record; the
evidence gate holds every compiled refutation this plan has produced, the pre-widening bound frozen
inside a probe so the refutation survives the widening; and every criterion is expressed relative to
a baseline measured at this plan's authoring rather than as an absolute.

### Research Integration

Findings 1-15 are the predecessor revision's, carried forward unchanged: each was re-derived against
the live tree at that revision's authoring, and nothing in the live tree has falsified any of them.
Findings 16-26 are THIS revision's, and the newly integrated report is
`reports/08_rk-bounded-representative-refutation.md`. Throughout, a figure re-derived at the
authoring that states it is given plainly; a figure taken from another record is marked CARRIED with
its source named, per the carried-figure discipline. Discrepancies are reported as findings rather
than silently resolved in either direction.

**Confirmed against the live library.**

1. **The `(K4)` design.** `CounterQuotient.lean` carries `dFwd` (the `U`-nesting depth, by
   recursion with `| .untl α β => max (dFwd α) (dFwd β) + 1`),
   `paramsOkK4 φ B := 2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧ 2 ≤ B`, and
   `Bof := max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)`, with `paramsOk_params` discharging
   `ParamsOk` at the four parameter outputs. `(K4)` therefore bounds the gap clip `B` by BOTH
   exactness depths and by `2`. Every consumer of `ParamsOk` reads that `(K4)`.
2. **The pump layer.** `LadderPump.lean` is 1,485 lines and imports `LadderAgree` alone.
   `tpOf_eq_spliceIdx_of_tpOf_eq`, `tpOf_eq_delIdx_of_tpOf_eq`,
   `nxtAt_le_cntAt_add_of_next_region`, `exists_typeBlock_of_budget_le_cnt` and
   `exists_iterSpliced_ladderPath_of_pend_past` are all present as declarations.
3. **The chain layer.** `realized_typeBlock_mem_prodCycleLens`, `typeBlock_length_dvd_of_paramsOk`,
   `exists_ladderPath_through_shifted_of_pend_past` and `cellAt_subset_of_shift_of_pend_past` are
   all present in `LadderChain.lean`.
4. **The probe.** `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean`
   is 550 lines, declares `Probe836A.cellLEZeroConstOfKappaEqPre_refuted`,
   `Probe836A.exists_refuting_cell_collision`, `not_paramsOkK4_two` and `kappa_D_dissolves`, and is
   WIRED: `scripts/check-evidence-probes.sh` carries 46 `WIRED` entries plus 1 `WIRED_REPO` entry,
   for the 47 the record claims.
5. **The reserved name.** `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returns
   seven lines, every one of them prose: three docstring lines in `LadderChain.lean`, two in
   `README.md`, two in `LadderAgree.lean`. No declaration claims the name.

**Discrepancies and corrections — each a finding, not a silent fix.**

6. **`LadderChain.lean` is 2,216 lines, not the 612 the abandoned record and task 838's
   description both state.** The difference is not drift in that record: tasks 844, 849 and 850
   each landed further work in that module after it was written, all three `[COMPLETED]`. Any
   figure for that module carried from a pre-844 record is stale by construction. The five
   declarations named in finding 3 are nevertheless all still present and none was renamed.
7. **The four uncommitted `nolints.json` rows are COMMITTED, and the carry-forward is discharged.**
   The abandoned record's Follow-up ("commit `scripts/nolints.json` once `file_scope` admits it")
   was closed by that same round's own final commit `e379d42c6`, which adds exactly the four
   `unusedArguments` rows for `tpOf_eq_spliceIdx_of_tpOf_eq`, `tpOf_eq_delIdx_of_tpOf_eq`,
   `exists_typeBlock_of_budget_le_cnt` and `realized_typeBlock_mem_prodCycleLens` as a declared
   `file_scope` excursion. `git status --short scripts/nolints.json` is empty and all four rows are
   present in the committed file, so `check-module-invariants.sh`'s C16 passes against HEAD and not
   only against the working tree. **Decision**: nothing needs admitting — `scripts/nolints.json` is
   already in this task's own `file_scope`, and this plan edits it in no phase. The narrow-remedy
   route for those four pins is owned by task 840 and is not this plan's.
8. **Five of the six sizing anchors the predecessor plan tells Phases 11.2 and 11.8 to CITE are
   not library declarations.** `forward_window`, `backward_constraint`, `region_doubling`,
   `doubling_attained` and `iter_doubling` exist only in the evidence probe
   `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`; `RunLayer.lean`'s and
   `Certificate.lean`'s own docstrings say in terms that the pin lemma's soundness half "stays in
   the probe and is not promoted". Only `cascadeBound` (`CounterQuotient.lean`) is importable. A
   proof term cannot cite the other five; a docstring can. Phases 11.2 and 11.8 below are corrected
   to say which kind of citation each anchor admits, so the collision is not discovered mid-proof.
9. **The import direction forbids Phases 11.2 and 11.8 from consuming the landed layer.** The live
   DAG is `AnchorLayer`/`CounterQuotient` → `LadderAgree` → `LadderPump` → {`LadderPin`,
   `LadderChain`}, read off the `import` lines of each module. `LadderAgree.lean` is STRICTLY BELOW
   the pump, pin and chain layers, so neither `two_pow_card_prodState_le_Tc` (`LadderChain.lean`)
   nor `pendPast_or_cntAt_le_nxtAt_succ` (`LadderPin.lean`) is available to a phase landing in
   `LadderAgree.lean`. The exponential `(K2)` reading and the pin-free dichotomy are available to a
   consumer ABOVE the pump layer — Phase 15 and the successor chain — and to nothing in the
   11.2/11.8 pair. This is recorded rather than worked around: re-homing the cascade above the pump
   layer would move it into territory the live successor task declares.
10. **`LadderAgree.lean` is at 2,300 lines against an in-source `set_option linter.style.longFile
    2400` baseline — 100 lines of headroom for two phases that both land in it.** Measured directly.
    Both remedies are pre-authorized by name in Phases 11.2 and 11.8 below, and the contingency file
    is listed under `Files to modify`, because the abandoned round's `iss_1793680346301_9l9mvq`
    records that a contingency file absent from that field cannot be committed by an implement
    dispatch at all.
11. **Two of the predecessor plan's verification criteria name paths that do not exist.**
    `scripts/lean-sorry-census.sh` and `scripts/check-task-references.sh` are both absent; the
    sanctioned entry points are `.claude/scripts/lean-sorry-census.sh` — which additionally
    REQUIRES explicit roots and exits with a usage error when invoked bare, exactly as the
    predecessor criterion invokes it — and `.claude/scripts/check-task-references.sh`. Corrected
    throughout, with the roots named.
12. **The ParamsOk-quantification repair the recorded Challenge statements needed is already
    adopted in the block this plan carries.** Both `cellAt_const_of_kappa_eq` and `ladderRealized`
    carry `(hp : ParamsOk step pend lab phi Tc Tn P B)` in the `## Lean Challenge Statements` block
    below, which is repair (a) of the two the statement-repair record (task 837, `researched`,
    `parent_task: 761`) names. That record's second, independent item — a Phase 8 task list
    requiring a promotion its own Scope Hypothesis excluded — is settled in the landed tree and is
    not reopened here.

**The route analysis this revision runs, and what it decides.**

13. **Route (a) is closed, by a compiled object rather than by argument.** The abandoned record's
    first named route — a `(K2)`-level pigeonhole over region starts exploiting the pin-free side —
    was entered by the live successor task. Its three provable pieces landed (`LadderPin.lean`'s
    dichotomy, its pigeonhole over the pins, and `two_pow_card_prodState_le_Tc`), and the decision
    gate they fed returned FAIL: `(K1)` does not constrain the length of a type-respecting block
    that spans a pin. Both of `(K1)`'s cycle-length conjuncts carry `∀ i, pend (f i) = true` on the
    closed walk they quantify, the walk a spanning block induces is idle at the pin strictly inside
    it, `objCycleLens` bounds the length by `Fintype.card Q` which a pin-window pigeonhole does not
    respect, and `satPeriod` is a datum of `step`, `lab` and `φ` alone. The refuting object is the
    alternating path, which carries a type-respecting block of EVERY even length with a pin strictly
    inside it.
14. **Route (b) read as a WEAKENING is closed too, and for a reason internal to this plan.** The
    path-level restatement already exists as landed library facts — `cellAt_subset_of_shift_of_pend_past`
    upward, and `mem_cellAt_of_shift_of_hasForwardSlack_exact` downward on the witnessing path — so
    nothing is owed under a new name. The state-level restatement is refuted by the climbing-register
    path. And neither form can feed this plan's Phase 11.6, because `stab_mem_tpOf_iff_cell` reads
    `PlusFormula.stab χ ∈ tpOf M φ σ z ↔ ∀ T ∈ cellAt M φ (σ.state z) z, χ ∈ T`, whose right-hand
    side is a UNIVERSAL over the full cell, and `cellAt M φ w z = {T | ∃ σ, σ.state z = w ∧ tpOf M φ σ z = T}`
    quantifies over EVERY history through the state — the climbing-register path included. A depth-`0`
    result that selects a witnessing path therefore cannot discharge a `⊡` bit at the compared state,
    however strong it is on that path. This is the "path-versus-state quantification" gap the
    successor chain names, stated in the semantics that make it binding on this plan.
15. **The route this revision takes is (b) read as DECIDE THE STATEMENT, and it is a phase of this
    plan.** `CellLEZeroConstOfKappaEq` (`LadderAgree.lean`) is the instance `t := z` of this plan's
    recorded `cellAt_const_of_kappa_eq` with one extra hypothesis (the closure carries no `⊡`
    letter), so the recorded statement IMPLIES the schema and a refutation of the schema under
    `ParamsOk` refutes the recorded statement outright. `ladderRealized` implies the schema too: its
    right-hand side depends on `(c, n)` only through `kappa Tc Tn P B (c, n)`, so two
    `kappa`-colliding states are assigned the same cell by it. The one claim standing between the
    landed layer and a verdict is the README's own argued-not-compiled one. Phase 11.9 compiles it
    or reports that it cannot, on three named branches, and its verdict decides whether Phases
    11.6-11.7 and 12.2-18 are a route at all.

**What the new research input settles, and what it changes.** Every figure in findings 16-26 was
re-derived at THIS revision's authoring against the live tree; where a figure is carried from the
new report it is marked and its source named.

16. **`rk_of_count_drift` is REFUTED at `repsCnt`'s current bound, not open.** The predecessor
    plan's Phase 12.1 closed three of `Real`'s six conditions with a `#### Reasoned Exclusions`
    record naming one missing lemma, `rk_of_count_drift`, and recorded as its third finding that
    "whether `repsCnt`'s own bound `Tc + Tn + P + B + 2` suffices for that construction is itself
    open". It does not suffice, and the answer is machine-checked: three `decide` witnesses were
    compiled standalone against the live library — `(Tc,Tn,P,B) = (1,2,2,2)` with the step
    `Count false false 9 5 0`, `Drift 5 4`; `(4,6,5,2)` with `Count true true 20 11 19`,
    `Drift 11 12`; and `(0,0,0,3)` with `Count false false 5 2 0`, `Drift 2 3` — each refuting
    `RK` at the two colliding classes. The lemma is FALSE as stated at the landed bound, and the
    defect is in `repsCnt`, not in the lemma.
    [CARRIED, source named: `reports/08_rk-bounded-representative-refutation.md`, Finding 1 and
    Appendix B. The three probe sources are reproduced there in full and are landed verbatim by
    Phase 12.4 below; this planning round runs no build and re-derives no `decide`.]

17. **The bound is wrong in two independent directions, and in the typical case rather than at an
    edge.** One `B` where the saturated-gap regime needs `2B` — witness `(0,0,0,3)` has `P = 0`,
    so no residue coupling is in play at all and it still fails — and one `P` where the
    `Drift`-plus-residue coupling needs `2P`. An exhaustive sweep over the 900 parameter tuples
    with `Tc < 5`, `Tn < 6`, `P < 6`, `B < 5` finds the landed bound failing on **496 of 900**.
    [CARRIED, source named: the same report, Finding 2 and Appendix C.]

18. **`ParamsOk` cannot rescue it, and `rk_of_count_drift` therefore carries no parameter
    hypothesis.** Re-read against the live `CounterQuotient.lean`: `(K1)` constrains `P` only
    through a divisibility condition into `P + 1`, and neither `(K2)` nor `(K3)` mentions `P` at
    all, so `ParamsOk` admits `P` arbitrarily large relative to `Tc`, `Tn` and `B` — precisely the
    direction the refutation exploits. The `(4,6,5,2)` witness additionally sits at numerics
    satisfying every numeric conjunct of `ParamsOk` for an object with
    `Fintype.card (ProdState Q φ) = 1`, `tIdle pend = 0` and `dBack φ = dFwd φ = 0`. **Decision,
    recorded so a later round does not re-propose it**: Phase 12.3's `rk_of_count_drift` does NOT
    take `ParamsOk`, and adding it is a prohibited workaround of that phase.

19. **Every class pair IS liftable in a wider window, so the repair is a definitional widening and
    not a hypothesis, a weakening, or a new obligation.** Across the whole sweep, zero class pairs
    were unliftable in a window of 160. The replacement this revision adopts is
    `Finset.range (Tc + Tn + 3*P + 2*B + 5)` squared — the bound a parameter-generic construction
    actually discharges (its analytic bound on the largest coordinate is `Tc + Tn + 3P + 2B + 4`),
    deliberately NOT the empirically tightest: `Tc + Tn + 2*P + 2*B + 3` also passes the whole
    900-tuple grid, but no construction on record closes it, and by finding 20 a larger `repsCnt`
    costs nothing structurally. A bound a proof can close is worth more than two saved `P`s.
    [CARRIED, source named: the same report, Finding 3, Decision D4 and Appendix A, which records
    the construction's three stages — one common downward shift on the `n`-side, three gap
    sub-cases on the `a`-side, and a `Count`-case split on the `a'`-side.]

20. **The widening's blast radius, measured at this revision's authoring and not carried.**
    `repsCnt` is `CounterQuotient.lean:184` and reads
    `(Finset.range (Tc + Tn + P + B + 2)) ×ˢ (Finset.range (Tc + Tn + P + B + 2))`. Its two
    proof-term consumers are in the same module: `rkStepB` (`:190`) and `rk_iff` (`:214`), with
    `RKb` (`:196`), `RK` (`:200`), `decidableRK` (`:203`) and `rkStepB_iff` (`:207`) beside them.
    Outside `CounterQuotient.lean`, the only occurrences of `repsCnt`, `RKb`, `rk_iff`, `rkStepB`
    or `decidableRK` anywhere in `FormalSystem/`, `Tests/` or `specs/evidence/` are **three prose
    lines in `LadderRealize.lean`'s module docstring** (`:34`, `:38`, `:47`). `relK`
    (`CounterQuotient.lean:630`) occurs only POSITIVELY — under an existential in `certBiInfK` and
    under `∀ i < m, rel (f i) (f (i+1))` in `DischPathK`'s consumers — and there is no negated
    occurrence of `RK` or `relK` anywhere. Widening `repsCnt` therefore enlarges `RK`, hence
    `relK`, hence WEAKENS `certBiInfK`, `certFwdK`, `certBwdK` and `certChain` monotonically, and
    the two landed conditions of `Real` (`real_certLocK`, `real_certBoxK`) mention no relation and
    are untouched. The four direct dependents of `CounterQuotient.lean` in the live import graph,
    read off their `import` lines, are `RaySummary.lean` (the aggregator), `LadderRealize.lean`,
    `LadderAgree.lean` and `LadderChain.lean`; that enumerated set is what Phase 12.3's
    `interface` tier covers.

21. **The widening is NOT semantically free: `Dmax` grows, and the maximum-certified-set finding
    must be re-read rather than inherited.** `Dmax` is literally the union of `certAdmK`-certified
    sets (`CounterQuotient.lean:701-704`, `{x | ∃ R, certAdmK … R ∧ x ∈ R}`), and `dmax_maximal`
    (`:714`) says every certified set lies inside it. Enlarging `RK` weakens the three relational
    conditions, so strictly MORE sets are certified and `Dmax` can only grow. The same module's own
    docstring (`:100-103`) records that `certStabK` and `certBoxK` are EQUALITIES between a
    letter's bit and a fibre of the candidate set, are therefore not preserved by enlarging it, and
    that "`Dmax` is itself certified is Finding 3 of the presentation-decision record" — which is
    exactly the inherited claim the growth threatens. Its SUFFICIENCY half ("every certified `R`
    lies inside `Real`") is the direction at risk, not its certification half. Phase 12.6 below
    exists to re-read it, and the consequence it bears on is named there: `dmax_subset_real`
    (Phase 15's corollary) and `ladderRealized`'s own right-hand side are both statements ABOUT the
    grown `Dmax`. The record to re-read is
    `specs/archive/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md`
    — the ARCHIVED path; the predecessor plan's `Research Inputs` cite the pre-archive path, which
    no longer resolves.

22. **Phase 11.8's refutation stands, and what it leaves open is an INTERFACE-LEVEL statement.**
    The blocker record carried in that phase below is correct as diagnosed and was re-checked
    against the landed source: `spliceCnt`'s own `if a ≤ v + cntAt g v` branch raises the pin at
    `a`'s region start by exactly `l` while leaving an earlier region start alone
    (`spliceObj_of_lt`), and `pinCompat_of_ladderPath` makes pairwise pin compatibility NECESSARY
    for any ladder path — so on the tight chain, whose every pin pair is exactly tight, the
    `spliceObj`-shaped conclusion is false rather than open. What the single consumer actually
    reads is narrower: `spliced_at_region` (`LadderAgree.lean:1260`) delivers TWO facts at one
    position, `objAt g' v = objAt g v` and `cntAt g' v = cntAt g v + l`, for `v ≤ a` inside `a`'s
    region. Those two facts, not the pointwise identity of the walk, are what the agreement
    consumes. The restatement this revision adopts is therefore an existential over SOME ladder
    path delivering those two facts, with no claim that it is `spliceObj g a l`; and the cascade
    has a coherent mechanism for it — insert idle positions into idle runs strictly BELOW the
    comparison position's region start, which shifts the past downward on the `ℤ` axis while
    leaving the walk at and above that start pointwise fixed, so `objAt g' v = objAt g v` survives
    by construction. Pushing an earlier region start down by `d` grows `|s - v|` by `d` and so
    relaxes the inequality the splice violated; the displacement propagates to the next pin down,
    which is the doubling recurrence `cascadeDemand` (`LadderAgree.lean:1445`) already encodes; and
    it terminates because `pinnedRegions_subset_Ico` (`:1405`) confines the constraining pins to
    `Set.Ico p a` when the anchor `p` is idle, which is the regime hypothesis itself. **This is a
    mechanism, not a proof**: nothing establishes that the restated existential holds in the tight
    idle-past regime, only that the refutation which kills the `spliceObj`-shaped conclusion leaves
    it open. Phase 11.8's Scope Hypothesis and the Risks table both say so.

23. **Phase 11.9's probe is tracked, compiling and UNWIRED — the one state the evidence gate exists
    to catch and is not catching.** Re-measured:
    `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean` is 480 lines;
    `grep -n 'ladder-tight-chain-nonliftability' scripts/check-evidence-probes.sh` returns nothing;
    and that script's arrays hold 46 `WIRED` entries plus 1 `WIRED_REPO` entry, the 47 the
    predecessor baseline records. The gate's own `check_probe` requires presence AND tracking, so
    the file passes neither test by being absent from the array: it will rot silently. Phase 11.9's
    own `#### Reasoned Exclusions` recorded this consequence and said the revision repairing the
    recorded statements should wire it in the same round. Phase 12.4 below is that round.

24. **Three carried length figures are stale; re-measured here.** `LadderAgree.lean` is **2,477
    lines** against an in-source `set_option linter.style.longFile 2600` (`:308`) — Phase 11.2 took
    the pre-authorized primary remedy and raised the baseline from `2400` in place, so the headroom
    for Phases 11.8 and 11.6 is **123 lines**, not the 100 the predecessor header measured against
    a 2,400 ceiling. `LadderRealize.lean` is **371 lines** (Phase 12.1 closed it at 363),
    `CounterQuotient.lean` is **758**, and `LadderChain.lean` is **2,216**, confirming the
    predecessor's finding 6. `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0
    with `sorry_count: 0`, unchanged from the predecessor baseline.

25. **Phase 11.9's three statement-level findings are the repair this revision records, not a
    reopening of that closed phase.** Its `[COMPLETED WITH EXCLUSIONS]` body below is carried
    byte-identical, its recorded statement block included, exactly as its own Exclusions require.
    What this revision adds is the repaired statement set, written into Phase 12.4's body: `0 < m`
    on the deletion count, the LIFTING form (countdown and register existentially quantified)
    rather than the register-specific `¬ IsLadderPath` form, and the chain with pins unbounded
    above. Those three repairs are what the landed probe's own headline theorems already carry,
    under honest names of their own.

26. **The pre-existing `C16` finding is left alone, and that is a decision.** The single
    `unusedArguments` finding on `mem_cellAt_of_shift_of_hasForwardSlack` sits in
    `LadderChain.lean`, a module no phase of this plan may edit, and no phase this revision adds
    puts that module in a phase's territory — so the narrow remedy stays outside this plan, as
    Phases 11.2 and 12.1 both recorded. `check-module-invariants.sh` therefore still exits 1 on
    that one group, and every criterion below that names it says so rather than asking for an
    unmeetable absolute.
    [CARRIED-UNVERIFIED: `reports/08_rk-bounded-representative-refutation.md`, Recommendation 7,
    which itself carries it from `.orchestrator-handoff.json`'s `blockers[3]`;
    `scripts/check-module-invariants.sh` was not run at this revision's authoring.]

**The route this revision takes.** Three independent repairs, none of which touches the open
depth-`0` core and none of which gates on it:

- **A definitional widening with a construction behind it** (Phase 12.3), which unblocks three of
  the six conditions of `Real` (Phase 12.5) and which carries its own compiled reason into the
  evidence gate (Phase 12.4), together with the gate's one unprotected probe.
- **A semantic re-read the widening forces** (Phase 12.6), because `Dmax` grows under it and the
  inherited maximum-certified-set finding is what later phases stand on.
- **An interface-level restatement of the refuted cascade conclusion** (Phase 11.8), with the
  interface Phase 15 consumes decided here rather than left to a dispatch.

The depth-`0` gate is UNCHANGED: Phase 11.9's verdict was INCONCLUSIVE, so Phases 11.6, 11.7, 12.2
and 13-18 stay behind it, and this revision neither lifts that gate nor re-attempts it.

## Goals & Non-Goals

**Goals**:
(The identifier set equals the six theorem declarations of the Lean Challenge Statements block
below, UNCHANGED by this revision. That block's `abbrev` definitions are context, not goals: they
pin by position the objects Phases 8-10 define. No other identifier is backticked in this block,
because the snapshot tool reads every backticked token here as a Goal. Phase 11.9's refutation
target is a PROBE declaration, stated in full in that phase's own body and deliberately not added
here — on the precedent of the forty-fifth, forty-sixth and forty-seventh wired probes, none of
whose declarations is a filed Goal of any plan.)
- `cellAt_const_of_kappa_eq` — the factorization lemma for the counter quotient, proved FIRST and directly at the history level: under the parameter conditions, cells agree on counter-class-equal states.
- `ladderSound` — obligation (S): every admissible ladder history projects to a member of the maximum certified subset at its own counter class, with its own closure type.
- `ladderCons_localRun` — every ladder run projects to a certificate chain inside a consistent bundle.
- `ladderLift` — obligation (C') in pumping form: every bi-infinite certificate chain through a class lifts to an admissible ladder history through any representative of that class, with the same closure type at the origin.
- `ladderRealized` — the fibre equation: under the parameter conditions, the cell at an admissible ladder state is exactly the fibre of the maximum certified subset at that state's class, for ALL φ, box and stab letters included.
- `paramsOk_params` — the parameter conditions (K1)-(K4) hold at the four parameters the periodicity fixpoint defines, so the hypothesis the two factorization-side statements carry is dischargeable and they are not vacuous. (Landed in Phase 9; carried in the block because it is a recorded Goal of this task.)

**Non-Goals**:
- No tuple index stated as a candidate at any parameters; `CK` stays a carrier coordinate. No
  seventh coordinate. No `truncate`, under any reading.
- The parameter hypothesis is NOT a predicate on four naturals, and is NOT to be weakened to one.
- The parameter hypothesis is NOT added to `ladderSound`, `ladderLift` or `ladderCons_localRun`.
  Those three keep the signatures recorded below token-for-token. If a phase finds one of them
  provable only under the hypothesis, the remedy is an auxiliary under an honest new name plus a
  `[BLOCKED]` raise on the filed statement — never a quiet edit of the filed signature.
- The agreement `cellAt_const_of_kappa_eq` is never a HYPOTHESIS of `ladderRealized`, and is never
  re-derived as a corollary of (S) and (C'). It is proved on its own ground in Phases 11.3-11.7.
- No depth-stratified certificate family is introduced: route (R-a) is not the chosen route, and
  `certChain` is not stratified by `⊡`-nesting depth.
- **No new module for the transport layer.** It lands in `LadderAgree.lean`, beside the
  admissibility layer it pairs with. The one exception this revision pre-authorizes is the
  `longFile` contingency of Phases 11.2 and 11.8, which is a length remedy and not a layering
  change, and which is named with its file and its two wiring edits so a dispatch can commit it.
- **No general bisimulation or truth-congruence framework.**
- **`ParamsOk` is not strengthened by any phase of this plan, and `CounterQuotient.lean` is not
  edited by the 11-series.** The predecessor plan's Non-Goal was the stronger "no strengthening of
  `ParamsOk`" simpliciter; that reading is SUPERSEDED by the recorded decision in
  `specs/archive/836_ladder_type_preserving_cell_agreement_construction/.decisions.json`. The
  design of record, stated on its own merits: `(K4)` is
  `paramsOkK4 φ B := 2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧ 2 ≤ B`, with `dFwd` the `U`-nesting
  depth and `Bof := max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)` the matching output, because
  `kappa`'s gap coordinate clips `n - c` at `B` and the cell reads the deadline register in BOTH
  directions — forward through `nxtAt_le_cntAt_add_of_next_region`, backward through
  `cntAt_le_nxtAt_succ_of_idle_past`. A `(K4)` answering only the backward window admits a clip a
  `U`-only formula of bounded `X`-depth defeats, which is what the forty-seventh wired probe
  compiles against the frozen `ParamsOkPre`. `paramsOk_params` discharges the predicate as it
  stands, and `not_paramsOkK4_two` compiles that it rejects the defeating clip. No FIFTH parameter
  source is added, and no phase below raises `Tc` or `Tn`.
- The landed admissibility layer is not reopened: `exists_spliced_ladderPath`,
  `pinCompat_of_ladderPath` and the declarations beside them are cited, never restated, weakened,
  or re-proved, and no pin hypothesis is relaxed.
- **Half (ii) of the truth-transport layer, `tpOf_stabFree_eq_of_splice`, is WITHDRAWN.** It is
  FALSE, not open (`Probe761S.splice_type_invariance_refuted`), and it must never reappear in this
  plan as a goal, nor in any weakened, conditional, positionwise-narrowed or raised-`Tc`
  restatement, nor as a hypothesis of anything.
- **The pumping/splice route to the truth-transport layer is RETIRED, and the
  type-respecting-block route is not entered by any phase of THIS plan.** No phase below pigeonholes
  on `(objAt v, tpOf v)` pairs, iterates the splice `P + 1` times to repair `kappa`'s residue, or
  spends a `(K2)` budget on a type pigeonhole. That the successor chain's own landed layer does
  exactly such pumping, above the pump-layer boundary and in its own modules, is not a licence for a
  phase of this plan to reach for it from below — finding 9 makes it unavailable in any case.
- **The replacement/splice layer's ADMISSIBILITY content is NOT deleted, narrowed or weakened.**
  ONLY its use for TYPE transport is retired.
- **`LadderAgree.lean` stays CERTIFICATE-FREE**: no certificate object, condition, `Dmax`,
  certificate-layer closure type or consistency bundle is named in its import list or in any of its
  statements, and the certificate-freedom grep stays a verification criterion of every phase of the
  11-series.
- **The two budget prototypes are NOT landed in the library.**
- No `sorry`, axiom, vacuous definition, trace-level `Presented` hypothesis, finite-fibre or
  finite-width assumption, capped ladder, or weakened statement under a filed name
  (`plan-compliance.md`, Statement Fidelity). The `box`/`stab` acceptance clause is never dropped
  to make a structure writable.
- No soundness clause carried as a `LadderCons` hypothesis field.
- `Realize.lean`'s `SLive`/`SCoh`/`deferGraph`/`bwdDeferGraph`/`Disch`/`persist` are NOT retained,
  ported or re-indexed; `Realize.lean`, `Trace.lean` and `presented_modelOf` are not re-proved;
  `ladderFrame` is untouched.
- Route A (deciding generalized-Büchi nonemptiness) is NOT entered on any branch.
- No complexity claim and no upper bound: every quantity named is a count.
- `anchorCells_finite` and `anchorCells_ncard_le` are not touched, re-proved, or strengthened.
- No edit to `specs/ROADMAP.md`, to 763's description, or to any archived predecessor's records —
  the archived construction round's artifacts under
  `specs/archive/836_ladder_type_preserving_cell_agreement_construction/` are READ by this revision
  and edited by no phase of it. `plans/08_cell-agreement-construction-handoff.md` is likewise not
  edited.
- The refutation probes `ladder-unconstrained-parameter-refutation.lean`,
  `ladder-splice-type-refutation.lean`, `ladder-cell-agreement-refutation.lean` and
  `ladder-cell-obligation-refutation.lean` are not deleted, narrowed, unwired or re-proved.
- Phase 9's and Phase 11.5's landed layers are not re-planned, re-proved or reopened; their
  `#### Reasoned Exclusions` records stand.
- **Route B's construction is not reattempted, in any form.** `AtomPreservingCountMove` is REFUTED
  (`atomPreservingCountMove_refuted`, landed and axiom-pinned).
- **`CellLEZeroConstOfKappaEq` is not weakened to something the landed machinery can reach, and the
  reserved name `cellLE_zero_const_of_kappa_eq` stays claimed by nothing until something proves the
  schema's own text.** A regime-restricted or path-selected variant is never landed under that name;
  finding 14 is why no such variant is landed under a new name by this plan either.
- **No phase of this plan edits `LadderPump.lean`, `LadderPin.lean` or `LadderChain.lean`.** They
  are the live successor task's declared territory, and finding 9 makes them unreachable from this
  plan's own modules in any case.
- **`repsCnt` IS widened by Phase 12.3, and that is the one edit to `CounterQuotient.lean` this
  plan makes.** The Non-Goal above is scoped to `ParamsOk` and to the 11-series, and it stands
  unchanged at that scope; what is stated positively here is the boundary the widening may not
  cross. `repsCnt`'s range argument moves from `Tc + Tn + P + B + 2` to
  `Tc + Tn + 3*P + 2*B + 5` in both factors and nothing else in that module's parameter layer
  moves: `ParamsOk`, `paramsOkK1`-`paramsOkK4`, `Tcof`, `Tnof`, `Pof`, `Bof`, `paramsOk_params`
  and `not_paramsOk_allZero` are untouched, no FIFTH parameter source is added, and `Tc` and `Tn`
  are not raised. A widening is not a strengthening: it ENLARGES `RK` and so WEAKENS every
  condition quantifying `relK` (finding 20), which is the opposite direction from adding a
  hypothesis.
- **`rk_of_count_drift` does NOT carry `ParamsOk`, and no round may add it.** Finding 18 is the
  reason and it is recorded in the lemma's own docstring so a later round does not re-propose it:
  `ParamsOk` bounds `P` only by divisibility from below and never from above, so no numeric
  consequence of it closes the gap the refutation exploits.
- **The widened `repsCnt` is not re-narrowed to recover an inherited claim.** If Phase 12.6's
  re-read returns MOVED, the remedy is a recorded finding and a further `/revise`, never a partial
  rollback of the widening to make the maximum-certified-set finding true again.
- **The refuted statement's name stays unclaimed.** Nothing is landed under
  `exists_spliced_ladderPath_of_idle_past`, in any weakened, regime-narrowed or positionwise form;
  the restated interface-level deliverables carry their own honest names (Phase 11.8), and the
  `spliceObj`-shaped conclusion is not re-attempted in the idle-past regime on any branch.
- **Phase 11.9 is not reopened, re-run or re-signed.** Its `[COMPLETED WITH EXCLUSIONS]` body,
  its recorded statement block and its `#### Reasoned Exclusions` record are carried byte-identical;
  what this revision adds is the WIRING its own Exclusions said a repairing round owes, plus the
  repaired statement set recorded in Phase 12.4's body. The depth-`0` gate is NOT lifted by this
  revision and the INCONCLUSIVE verdict is not re-litigated.
- **No round tunes the representative bound empirically.** The bound is the one a construction
  discharges (finding 19); if that construction's case analysis does not close, the phase is
  `[BLOCKED]` with the goal state recorded, never widened further until a probe passes.
- **`LadderChain.lean` is in no phase's territory, so the `C16` finding is not this plan's to
  remedy** (finding 26). No phase this revision adds changes that.
- **No successor task is created by this revision.** `/revise` does not create tasks; the two
  records that would be owed are named under Rollback/Contingency as Follow-ups.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Phase 11.9's gate returns REFUTED, which refutes this plan's recorded `cellAt_const_of_kappa_eq` and `ladderRealized` outright** | H | M | This is a COMPLETE and reportable outcome, not a failure, and it is the gate's whole point. Finding 15 derives the implication before the gate is run, so nobody has to re-derive it mid-dispatch. On that branch Phases 11.6, 11.7, 12.2 and 13-18 close `[COMPLETED WITH EXCLUSIONS]` with `#### Reasoned Exclusions` records citing the gate's own compiled object, the two filed statements are named as REFUTED in `docs/theorem-index.md`, the README and the summary, and the remedy is a further `/revise` with the compiled finding as its input — never a weakened statement under a filed name, never route A, and never a quiet edit of the Challenge block |
| Phase 11.9's gate returns INCONCLUSIVE and the plan is back where it started | M | M | Not where it started: the gate is a phase of THIS plan rather than an external task, so an inconclusive verdict leaves Phases 11.2, 11.8 and 12.1 enterable and names the specific sub-claim that resisted. The honest report is that verdict plus those three phases, never a partial on 11.6 |
| **A dispatch reads the predecessor plan's gate note, looks for the external construction task, finds it archived and `[ABANDONED]`, and either stalls or enters Phase 11.6 anyway** | H | H | The whole reason this revision exists. No phase of this plan names an abandoned or nonexistent task as a gate; Phase 11.6's gate is Phase 11.9 of this same plan plus Phase 11.5, both named in its `Depends on` line and in the wave table; and its FIRST verification item is unchanged — `cellLE_zero_const_of_kappa_eq` must exist as a landed, `sorryAx`-free THEOREM before any other item of that phase is read |
| A dispatch tries to cite `forward_window`, `iter_doubling` or their three companions as proof terms in Phase 11.2 or 11.8 | M | H | Finding 8 names all five as probe-level, says which file they live in, and both phases' task lists now distinguish a prose citation from a proof term. The mechanical catch is the scoped build itself: an unknown identifier does not elaborate |
| A dispatch tries to cite the landed pin or chain layer from `LadderAgree.lean` | M | H | Finding 9 states the import DAG as read off the `import` lines; both phases record that the exponential `(K2)` reading and the pin-free dichotomy are available only ABOVE the pump layer. The mechanical catch is again elaboration failure, and the certificate-freedom grep plus the import check are re-run per phase |
| **`LadderAgree.lean` crosses its `longFile 2400` baseline mid-phase and the dispatch cannot commit the remedy** | M | H | Measured, not guessed: the module is at 2,300 lines with 100 lines of headroom. The primary remedy — raise the in-source baseline in place, never split — is pre-authorized in both phases; the contingency module `LadderCascade.lean` and its two wiring edits are LISTED under `Files to modify` in both phases, because `iss_1793680346301_9l9mvq` records that an unlisted contingency file is dropped from the commit by `git-commit-scoped.sh` while its import edges are committed, leaving HEAD importing an uncommitted module |
| Territory collision on `LadderAgree.lean`, `README.md`, `KTypeSummaryAxiomTest.lean` and `typst/generated/status.typ` with the live successor task, which declares all four | M | M | Recorded rather than hidden. Per the batching guardrail, an unordered overlap is an edge and not a bare exclusion; whether a `761 -> 838` edge is added is the orchestrator's call, as the `Dependencies` field says. This plan reduces the overlap where it can: Phase 11.9 touches neither the library modules nor the README, and no phase of this plan edits the successor's three own modules |
| `ladderSound`'s pinned signature carries no parameter hypothesis, but the only route to it runs through `certAdmK Real`, which consumes the agreement and therefore `hp` | H | H | Unchanged from the predecessor decomposition and recorded up front. Phase 12.2 lands `Real`'s certification UNDER `hp`; Phase 13 first probes whether the unconstrained `ladderSound` is REFUTABLE at the all-zero tuple (a landed separating pair is a complete outcome), then attempts the pinned statement, then falls back to `ladderSound_of_paramsOk` under that honest auxiliary name with the filed statement `[BLOCKED]` and the statement-defect raised. Adding `hp` to a recorded Challenge statement is routed to the user by Statement Fidelity |
| The cascade of the row above: `ladderCons_localRun` also carries no `hp` and consumes (S) | H | M | Stated as Phase 14's own contingency. Phase 16's `ladderRealized` DOES carry `hp` and can consume the constrained auxiliary |
| The agreement (Phase 11.7) does not close | H | M | Not costable, and declared so for 11.2 and 11.6-11.9. `no_positionwise_lift` is COMPILED, so narrowing to the positionwise form is not a weaker statement but a wrong one. The contingency is `[BLOCKED]` with the goal state recorded, per phase |
| **MATERIALIZED and retained: splice invariance of the stab-free type is FALSE as stated** | H | fired | The recorded mitigation produced the planned COMPLETE outcome: the separating object is compiled and wired as the forty-fifth probe with non-vacuity on both sides, half (i) stands independently, `Tc` was not raised and no parameter was added. The residual risk is a reader mistaking it for a refutation of the agreement; `AltHistory.chiS_in_cell_at_original_state` compiles that the separating formula does not separate the CELLS |
| **MATERIALIZED and retained: the cell-level route's CONSTRUCTION is refuted** | H | fired | `atomPreservingCountMove_refuted` is a library theorem at full generality, wired as the forty-sixth probe with non-vacuity on both sides. What fired is the CONSTRUCTION clause only: nothing there settles the filed `cellAt_const_of_kappa_eq`. Phase 11.5 is closed with a `#### Reasoned Exclusions` record rather than held open |
| **NEWLY MATERIALIZED: the obligation is refuted at a `(K4)` answering only the backward window, and the device the successor route named is refuted in both directions** | H | fired | Both outcomes are compiled and recorded — the forty-seventh wired probe against the frozen `ParamsOkPre`, and the two spanning-block refutations in the archived prototype `tight-chain-regime-b.lean`. Neither settles the schema under `ParamsOk`: both refuting objects have a pin-free side on which the register is rebuildable without a spanning block. That is exactly the residue Phase 11.9 gates |
| An implementer "discharges" type preservation by citing `prodPre_periodic` across the certificate/model boundary | H | M | Named as a prohibited workaround in every phase of the 11-series and caught by the certificate-freedom grep extended with `prodPre_periodic`, `prodPreStep`, `cohIdle`, `satThreshold` and `satPeriod` |
| An implementer reinstates half (ii) under a new name because the open core is hard | H | M | Half (ii) is WITHDRAWN in Non-Goals, prohibited by name in every open phase, and caught by `grep -rnE 'tpOf.*splice|splice.*tpOf' FormalSystem/ Tests/`, which must return nothing outside a docstring sentence recording the refutation |
| A verification criterion is written as an absolute "exits 0" or "count 0" against a pre-existing baseline and is unmeetable | M | H | Three criteria of exactly this class are already recorded in this task's history, and finding 11 adds two more (two named script paths that do not exist). Every criterion below names either a baseline MEASURED at this plan's authoring — vacuous-grep 1 hit at `FormalSystem/Examples/TemporalStructures.lean:495`; `^axiom ` 10 in `FormalSystem/` and 2 in `Tests/`, all prose; `sorry_count: 0` from `.claude/scripts/lean-sorry-census.sh FormalSystem Tests` — or a scoped path set, and names the repository's sanctioned entry point with its exit status read. The format fix itself is owned by task 835 and is not this plan's |
| A full `lake build` with the landed layer exceeds a foreground tool call | M | H | Route every build through `lake-build-guard.sh` with an explicit `--timeout`; detach as a shell-level background job and block with the bounded single-call idiom per `context/patterns/bounded-build-waiter.md` — never `Bash(run_in_background: true)` |
| `typst-status-counts.sh` (pre-commit) regenerates `status.typ` with a diff | L | H | Expected whenever library declarations change; commit it with the phase that caused it. The archived round records that a commit touching `FormalSystem/**/*.lean` is REFUSED by the typst-sync pre-commit gate without it, so every such phase's `Files to modify` names it |
| **The widening enlarges `Dmax`, and the inherited maximum-certified-set finding is what Phases 15 and 16 stand on** | H | H | NOT inherited: Phase 12.6 is a decision gate whose whole content is re-reading that finding against the widened `RK`, with its two branches and its derivation obligation written out. Finding 21 derives the mechanism at plan time — `Dmax` is the union of certified sets, weakening the relational conditions certifies strictly more sets, and only `certStabK` and `certBoxK` bound the growth — so no dispatch has to rediscover it. On the MOVED branch the consequence is named where it bites (`dmax_subset_real`, Phase 15) and the remedy is a further `/revise`, never a partial rollback of the widening |
| A larger `repsCnt` makes every `decide` over `RK` quadratically more expensive, and one witness already needed raised limits at bound 19 | M | M | No landed theorem decides `RK` at a concrete parameter tuple, and Phase 12.3 carries a verification item that checks exactly that rather than assuming it. Phase 12.4's refutation witnesses keep their small tuples at the FROZEN pre-widening bound, and their positive counterparts are proved by `rk_of_count_drift` rather than by `decide` — at tuple B the widened bound is 34 and a `decide` there is `34^4`-shaped. The rule, recorded in both phases: `decide`-based probes stay at small bounds and the general lemma is proved by construction, never by enumeration |
| The recommended bound is justified by a 900-tuple sweep plus an analytic construction, not by a compiled proof | M | M | Recorded as such, with the sweep's finite step range named (finding 19 marks both figures CARRIED with their source). The construction is parameter-generic and is what Phase 12.3 proves; if its case analysis does not close, that phase goes `[BLOCKED]` with the goal state and the stalling sub-case recorded, which is a prohibited-workaround item of that phase rather than a licence to tune the bound |
| **The refutation becomes unstatable once the widening lands, and the compiled reason for the change is silently lost** | H | H | Phase 12.4 freezes the pre-widening bound inside the probe as its own `repsCntPre`/`RKPre` and refutes against that, which is the pattern the forty-seventh wired probe already uses against the frozen `ParamsOkPre`. Both halves are verification items: the frozen range argument is read directly, and each of the three tuples must carry BOTH its refutation at the frozen bound and its positive `RK` at the widened library definition |
| Phase 11.8's restated interface-level existential is itself refutable | M | M | Said so rather than assumed: finding 22 states that the refutation which kills the `spliceObj`-shaped conclusion leaves the interface-level one OPEN and that the cascade is a mechanism, not a proof. The phase's Scope Hypothesis carries both contingencies — `[BLOCKED]` with the failing pin pair named, or a REFUTED branch whose refuting object is landed as a wired probe under a new honest name — and the contingency probe file and its gate entry are LISTED under `Files to modify`, because an unlisted contingency file cannot be committed by an implement dispatch |
| A dispatch re-attempts the `spliceObj`-shaped conclusion in the idle-past regime because the phase is `[NOT STARTED]` again | M | M | The blocker record is carried VERBATIM inside the restated phase, the refuted name is left unclaimed by a prohibited-workaround item and checked by a grep, and the restated conclusion is required to contain no occurrence of `spliceObj` or `spliceCnt` |
| **Phase 11.9's 480-line probe rots unprotected** | M | fired | Measured, not predicted: the file is tracked and compiling and absent from the gate's arrays (finding 23), which is the one state that gate was built to catch and is not catching. Phase 12.4 wires it in the same commit as its own probe, and the gate's PASS line is required to report 49 against the 47 measured at this revision's authoring |
| A later reader takes Phase 11.9's recorded statement block as the live statement | M | M | Its three defects are recorded as the repaired set in Phase 12.4's body, with the landed probe's own honest theorem names given as the correspondence. Phase 11.9's block stays byte-identical, as its own Exclusions require, so the plan carries both the recorded text and its repair rather than silently replacing one with the other |
| 763 shares the RaySummary library set and could collide | M | L | 763 waits on 761 alone and is not dispatched concurrently |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4, 5 | 2 |
| 3 | 6 | 3, 4, 5 |
| 4 | 7, 8 | 1 |
| 5 | 9 | 8 |
| 6 | 10, 11 | 9 (10); 7, 9 (11) |
| 7 | 11.1, 11.2, 12.1 | 11 (11.1); 7, 11 (11.2); 10 (12.1) |
| 8 | 11.3, 11.8, 12.3 | 11.1 (11.3); 11.2 (11.8); 12.1 (12.3) |
| 9 | 11.4, 12.4, 12.5 | 11.3 (11.4); 12.3 (12.4); 12.3 (12.5) |
| 10 | 11.5, 12.6 | 11.4 (11.5); 12.3, 12.5 (12.6) |
| 11 | 11.9 | 11.5 |
| 12 | 11.6 | 11.5, 11.9 |
| 13 | 11.7 | 11.6 |
| 14 | 12.2 | 12.1, 11.7, 12.5 |
| 15 | 13 | 12.2 |
| 16 | 14, 15 | 10, 13 (14); 7, 11.8, 11.7, 12.2 (15) |
| 17 | 16 | 13, 15 |
| 18 | 17 | 16 |
| 19 | 18 | 6, 14, 17, 12.4, 12.6 |

Phases within the same wave can execute in parallel.

**What is closed, what is enterable, and what is gated.** Waves 1-7 are landed or closed (Phases
1-11, 11.1, 11.2 and 12.1), as are Phases 11.3, 11.4, 11.5 and 11.9 — several with
`#### Reasoned Exclusions` records. The ENTERABLE work is **Phase 12.3** (the representative
widening and `rk_of_count_drift`, which waits on the closed Phase 12.1) and **Phase 11.8** (the
restated cascade, which waits on the closed Phase 11.2), with **Phases 12.4, 12.5 and 12.6** opening
behind 12.3. Everything else that is open — Phases 11.6, 11.7, 12.2 and 13-18 — still sits behind
Phase 11.9's verdict and, through it, behind the open depth-`0` core. **This revision does not lift
that gate, does not re-run it, and does not re-litigate its INCONCLUSIVE verdict.**

**What this revision changed about the graph, phase by phase.**

- **Phases 1-10, 11, 11.1, 11.2, 11.3, 11.4, 11.5, 11.9 and 12.1 are carried forward closed and
  unmodified in substance.** Their status markers, `Timing` lines, `Depends on` sets, NOT COSTABLE
  declarations, recorded statement blocks, closure records and `#### Reasoned Exclusions` records
  are preserved. Phase 12.1's record additionally carries one clearly-labelled forward-pointer line
  added by this revision, which annotates its third finding as now settled and names where its three
  exclusions are re-homed; nothing in that record is rewritten, and its own text stands.
- **Phase 11.8 is RESTATED and returns to `[NOT STARTED]`.** Its blocker record is carried verbatim
  — it is the compiled reason the restatement exists — and its deliverable moves from the refuted
  `spliceObj`-shaped `exists_spliced_ladderPath_of_idle_past` to three interface-level declarations
  delivering, at the comparison position, exactly the two facts `spliced_at_region` exposes there.
  Its `Depends on` (11.2), its NOT COSTABLE declaration and its sizing-as-a-count obligation do not
  move.
- **Phase 15's consumed interface is DECIDED here**, not left to a dispatch: it consumes Phase
  11.8's joined `exists_ladderPath_at_region` and nothing else from the cascade. Its `Depends on`
  set is unchanged.
- **Phase 12.3 is NEW**: widen `repsCnt` to the bound a construction discharges, re-close the four
  declarations stated over it, and land `rk_of_count_drift` without `ParamsOk`.
- **Phase 12.4 is NEW**: the three refutation witnesses as a wired probe against the FROZEN
  pre-widening bound, plus the wiring Phase 11.9's own Exclusions said a repairing round owes, plus
  the repaired form of that phase's three recorded statements.
- **Phase 12.5 is NEW** and lands exactly Phase 12.1's three excluded conditions, whose single
  shared missing link Phase 12.3 supplies. Phase 12.2's `Depends on` gains `12.5` for that reason
  — the same kind of re-pointing the predecessor revision applied when it split Phase 12.
- **Phase 12.6 is NEW** and is a decision gate: re-read the maximum-certified-set finding against
  the widened `RK`, because `Dmax` grows under the widening and that finding is what Phases 15 and
  16 stand on.
- **Phases 11.6, 11.7, 12.2 and 13-18 are unchanged in content**, except that Phase 12.2's
  `Depends on` gains `12.5`, Phase 15's interface decision is recorded in its body, and Phase 18's
  `Depends on` gains `12.4` and `12.6` so that the final phase keeps observing every phase of the
  plan.

**Why the new work is four phases and not one.** Each has a different failure mode and a different
territory, and collapsing them would make a single dispatch's partial unreportable: 12.3 edits
`CounterQuotient.lean` and can go `[BLOCKED]` on a case analysis; 12.4 edits only
`specs/evidence/**` and `scripts/check-evidence-probes.sh` and cannot fail for a mathematical
reason at all; 12.5 edits `LadderRealize.lean` and depends on 12.3's lemma being usable rather than
merely true; and 12.6 is a recorded verdict with two branches and no declaration on either. The two
evidence-gate wirings are deliberately in ONE phase (12.4) rather than two, because both are edits
to the same shell script and two phases contending for it would be an unordered overlap.

**The final phase is unchanged in identity.** Phase 18 is still the highest-numbered phase, nothing
depends on it, and it depends — directly or transitively — on every other phase, the four new ones
included (12.3 through 12.5 and 12.2; 12.4 and 12.6 by the direct edges this revision adds), which
is what makes its `full` gate meaningful. Its edges to Phases 6 and 14 are there for the same reason
the predecessor recorded.

### Phase 1: Retire the Deleted Statement Line and Record the Discharge [COMPLETED]

**Goal**: Closed. The withdrawn `truncate`-bearing statement line retired and the discharge of the
six declared dependency edges recorded.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: Record edits only, with no compile surface; the covering check is the diff
read-through the `prose` row prescribes plus `bash .claude/scripts/check-task-references.sh --quiet`
on every touched non-`specs/**` file.

**Files to modify**:
- `specs/state.json` - the amended description
- `specs/761_ladder_realization_theorem/records/761-amendment.txt` - the amendment record

**Verification**: Closed as executed; the full as-executed criteria are in
`plans/08_cell-agreement-construction-handoff.md`, Phase 1.

---

### Phase 2: Author the Wired Forward-Only Liveness Probe [COMPLETED]

**Goal**: Closed. The forward-only structural-liveness probe authored and compiled.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: One standalone probe file with no library consumer, so the covering check is
the guarded standalone compile of that one file through `lake-build-guard.sh ... -- env lean`.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` - the probe

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`, Phase 2.

---

### Phase 3: Wire the Probe into the Evidence Gate [COMPLETED]

**Goal**: Closed. The probe wired into the evidence gate's `WIRED` table and array.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: One shell-script table edit whose own covering check is
`bash scripts/check-evidence-probes.sh` read for its exit status.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - the table block and array entry

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`, Phase 3.

---

### Phase 4: Record the Obstruction in the README and the Theorem Index [COMPLETED]

**Goal**: Closed. The obstruction recorded in the RaySummary README and the theorem index.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: Record prose only; the covering checks are
`bash scripts/readme-lint.sh` and `bash .claude/scripts/check-task-references.sh --quiet`, each read
for its exit status.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the obstruction paragraph
- `docs/theorem-index.md` - the index rows

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`, Phase 4.

---

### Phase 5: Amend the Design of Record and the Task's Own Description [COMPLETED]

**Goal**: Closed. The design of record and the task description amended to the chosen presentation.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: `specs/**` record edits only; the covering check is
`bash .claude/scripts/validate-artifact.sh` on the touched artifacts plus the diff read-through.

**Files to modify**:
- `specs/state.json` - the amended description
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - the design of record

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`, Phase 5.

---

### Phase 6: Run the Full Gate, Write the Summary, Return Blocked [COMPLETED]

**Goal**: Closed. The full gate set run and the round's summary written.

**Timing**: 1.25 hours

**Depends on**: 3, 4, 5

**Verification Tier**: full

**Tier Justification**: The round's closing gate observes every record and probe edit of Phases 1-5
at once, and no cheaper tier covers the deploy-level record surface.

**Files to modify**:
- `specs/761_ladder_realization_theorem/summaries/01_ladder-realization-blocked-probe-summary.md` - the summary

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`, Phase 6.

---

### Phase 7: Promote the Pin Lemma's Lift Half into `RunLayer.lean` [COMPLETED]

**Goal**: Closed. The pin lemma's lift half promoted into `RunLayer.lean` as nine declarations.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: Nine declarations in one module consumed by `LadderAgree.lean` across the
module boundary, so the covering check is the guarded scoped build of `RunLayer.lean` plus its
axiom test.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` - the nine declarations
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pins
- `typst/generated/status.typ` - the regenerated line counts

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`, Phase 7.

---

### Phase 8: Promote the Certificate Layer into the Library [COMPLETED]

**Goal**: Closed. The `CK`-free certificate layer promoted from the probes into `Certificate.lean`.

**Timing**: 3 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: A new module consumed by `CounterQuotient.lean`, so the covering check is the
guarded scoped build of both plus the axiom test.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean` - the certificate layer
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean` - the import edges
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pins
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`, Phase 8.

---

### Phase 9: The Counter Quotient `K`, Its Parameters, the Parameter Conditions, and the Maximum Certified Subset [COMPLETED WITH EXCLUSIONS]

**Goal**: Closed. `CK`, `kappa`, `RK`, the four parameter outputs, `ParamsOk` and
`paramsOk_params`, `not_paramsOk_allZero`, `relK`, `DischPathK`, `certStabK`, `certAdmK`, `Dmax`
and `dmax_maximal`, all landed in `CounterQuotient.lean`.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The `Dmax` task's justifying clause "the union of certified sets is certified, so the maximum exists" | FALSE for this certificate, so proving it would mean proving a false statement: `certStabK` and `certBoxK` are BICONDITIONALS between a letter's bit and a fibre of the candidate set, so a member whose bit is set in a small certified set has that bit falsified as soon as the union adds a member missing the argument. Only the four monotone conditions survive a union. The maximum is still well defined and is the union; its own certification is Finding 3's route, assigned to the soundness and completeness obligations and never to a union argument | Landed in `CounterQuotient.lean`: `dmax_maximal` plus `dmax_certLocK`, `dmax_certBiInfK`, `dmax_certFwdK`, `dmax_certBwdK`. No theorem claims `certStabK`/`certBoxK` of `Dmax`, and the module's "What this module does NOT hold" section says so in the source. Full as-executed record with the closing gate figures: `plans/08_cell-agreement-construction-handoff.md`, Phase 9 |

No residual work follows from this exclusion: the clause as written will not be revisited, because
it is false. The certification of `Dmax` itself is Phases 12.1-12.2's own obligation along Finding
3's route and is already in this plan.

**Timing**: 3.5 hours

**Depends on**: 8

**Verification Tier**: interface

**Tier Justification**: The counter quotient and `Dmax` are consumed by `LadderAgree.lean` and
`LadderRealize.lean` across module boundaries, so the covering check is the guarded scoped build of
`CounterQuotient.lean` plus its enumerated dependents and the axiom test.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` - CK, kappa, RK, the parameter outputs, ParamsOk, paramsOk_params, not_paramsOk_allZero, relK, DischPathK, certStabK, certAdmK, Dmax, dmax_maximal
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pins
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`, Phase 9.

---

### Phase 10: The Definitional Layer of `LadderRealize.lean` — `typeOfCl`, `certChain`, `LadderCons` [COMPLETED]

**Goal**: Closed. The three objects the realization statements quantify over, landed in
`LadderRealize.lean` with no theorem in the module.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: interface

**Tier Justification**: Three definitions consumed by Phases 12.1-16 across the module boundary, so
the covering check is the guarded scoped build of `LadderRealize.lean` plus the axiom test.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - typeOfCl, certChain, LadderCons
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean` - the import edges
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`,
Phase 10. Confirmed standing at this revision's authoring: the module is 132 lines and carries
exactly `typeOfCl`, `certChain` and `LadderCons`, with no theorem.

---

### Phase 11: The Rigid-Anchor and Replacement-Admissibility Layer of `LadderAgree.lean` [COMPLETED WITH EXCLUSIONS]

**Goal**: Closed. The rigid-anchor and replacement-admissibility layer landed as 45 named exported
machinery declarations, none of which mentions the agreement.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The type-preservation conjunct of the chain-replacement machinery | Not an item of this phase: it is a MODEL-level truth-transport statement about `tpOf`, and the repository had no state-to-state truth transport to build it from. Re-planned as Phase 11.1 | The blocker research in `.dispatch/16-aux-plan-revision.md`'s `## Prompt`: the only landed transport, `tpOf_timeShift`/`cellAt_eq_cellAt`, moves along the TIME axis at a FIXED world state. Full record: `plans/08_cell-agreement-construction-handoff.md`, Phase 11 |
| The ITERATION of the replacement (the cascade in the regime where an idle position lies in the past) | Not an item of this phase: `pinCompat_of_ladderPath`, compiled HERE, proves the pin condition is forced on every ladder path, so the cascade is a distinct obligation sized by `(K2)`'s `cascadeBound`. Re-planned as Phases 11.2 and 11.8 | `pinCompat_of_ladderPath` and `exists_spliced_ladderPath`, both compiled in this phase; only `exists_spliced_ladderPath_of_pend_past` discharges the latter's pin hypothesis, confirmed present at this revision's authoring |
| The `⊡`-nesting-depth induction | Never an item of this phase's task list, and that absence was the defect: `stab_mem_tpOf_iff_cell`, compiled here, makes the `⊡` bit a datum of the very cell the agreement compares. Re-planned as Phase 11.6 | `stab_mem_tpOf_iff_cell`, confirmed at `LadderAgree.lean` with conclusion `PlusFormula.stab χ ∈ tpOf M φ σ z ↔ ∀ T ∈ cellAt M φ (σ.state z) z, χ ∈ T` |
| The Goal `cellAt_const_of_kappa_eq` | Not reachable from this phase's landed layer: it consumes all three items above. Relocated unchanged — same signature, same recorded position for `hp` — to Phase 11.7, so no filed statement is weakened, narrowed or dropped | `cellAt_const_of_kappa_eq` appears nowhere in the tree; re-confirmed at this revision's authoring. The signature stands token-for-token in the `## Lean Challenge Statements` block below, unedited |

Condition 5 of the `[COMPLETED WITH EXCLUSIONS]` admission test is met in the exact sense the marker
defines: nothing remains for a future dispatch to pick up *in this phase*. Every excluded item is a
named, numbered, separately-verified phase of this same plan.

**Timing**: Closed. ~2.5 hours across two dispatches (seq 13 and seq 15), against a NOT COSTABLE
declaration. 46 compiled declarations landed. No estimate was offered and none was invented; the
work closed where the mathematics stopped, which is what the declaration was for.

**Depends on**: 7, 9

**Verification Tier**: full

**Tier Justification**: The chain-replacement argument spans the whole `RunLayer.lean` pin-lemma
interface, `AnchorLayer.lean`'s cell layer and `CounterQuotient.lean`'s `kappa` at once, and no
cheaper tier covers that surface.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - the rigid-anchor and replacement-admissibility layer
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean` - the import edges
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pins
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`,
Phase 11.

---

### Phase 11.1: The Model-Level Truth-Transport Layer — Half (i) Landed, Half (ii) Refuted and Withdrawn [COMPLETED WITH EXCLUSIONS]

**Goal**: Closed. Half (i) landed as 28 declarations — `truthAt_iff_of_objAt_eq_of_stabPinned`,
`tpOf_eq_of_objAt_eq_of_pinned`, `tpOf_stabFree_eq_of_objAt_eq`, `stabDepth`/`StabPinned`, the
path/history bridge and the non-vacuity witness `exists_ladderPath_pair_nxtAt_ne` — stated RELATIVE
to a pinned-letter parameter so Phase 11.6 can instantiate it. Half (ii) closed by refutation.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Half (ii), `tpOf_stabFree_eq_of_splice` | Not deferred and not merely unproved: FALSE as stated, and WITHDRAWN as a goal by the recorded decision. It will not be revisited in any weakened, conditional, positionwise-narrowed or raised-`Tc` form | The forty-fifth wired probe `specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean`, `Probe761S.splice_type_invariance_refuted`, against a schema carrying every hypothesis the predecessor decomposition recorded. Confirmed wired at this revision's authoring |
| The pending-forever instance `tpOf_stabFree_eq_of_splice_pend_past` | Unreachable for the same reason and excluded with it: it instantiates a refuted statement | The same probe. Full record: `plans/08_cell-agreement-construction-handoff.md`, Phase 11.1 |

Condition 5 is met: the two excluded items are the same item twice — a refuted statement and its
instance — and both are closed by a compiled counterexample rather than handed on.

**Timing**: Closed, against a NOT COSTABLE declaration. Half (i) was a structural induction over six
clauses and landed 28 declarations; half (ii) was the semantic heart of the pumping route and closed
by refutation. No estimate was offered for either and none was invented.

**Depends on**: 11

**Verification Tier**: full

**Tier Justification**: Half (i) quantifies over every clause of the truth definition and is
instantiated by Phase 11.6 across the closure, so it reaches `PlusLanguage`'s truth clauses and
`AnchorLayer.lean`'s cell layer at once.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - half (i)'s 28 declarations
- `specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean` - the refuting probe
- `scripts/check-evidence-probes.sh` - the probe's table block and array entry
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pins
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the inventory blocks and the refutation record
- `typst/generated/status.typ` - the regenerated line counts

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`,
Phase 11.1.

---

### Phase 11.2: The Pin Cascade, Front Half — Regime Exhaustiveness, Finiteness, and the Sizing [COMPLETED]

**ENTERABLE NOW, AND GATED ON NOTHING OPEN.** Re-confirmed at this revision's authoring rather than
carried: its two prerequisites (Phases 7 and 11) are both closed; `exists_spliced_ladderPath`,
`exists_spliced_ladderPath_of_pend_past`, `pinCompat_of_ladderPath`, `pend_past_of_nxtAt_lt`,
`clipIdx_regime_of_eq`, `nxtAt_lipschitz`, `nxtAt_lipschitz_two_sided` and
`cntAt_le_nxtAt_succ_of_idle_past` are all present in `LadderAgree.lean`; and
`exists_spliced_ladderPath_of_idle_past` — Phase 11.8's deliverable — is present nowhere, so this
pair's work is genuinely unlanded. Nothing the abandoned round or the live successor chain landed
changes any of that, because all of it sits ABOVE this module in the import DAG (finding 9).

**Goal**: Land, as named exported lemmas in `LadderAgree.lean`, the three facts the cascade
construction needs before it can be written, none of which requires the construction itself: (1)
REGIME EXHAUSTIVENESS — `pend_past_of_nxtAt_lt` is the dichotomy and `clipIdx_regime_of_eq` says a
class collision at a fixed next deadline stays inside one regime, so the landed
`exists_spliced_ladderPath_of_pend_past` and the cascade together cover every collision the lift
must transport, with no path ever carried from one regime into the other; (2) FINITENESS — the set
of pinned regions between an idle position `p ≤ a` on the original path and the splice point `a` is
finite, PROVED from `p` being idle rather than assumed, which is what makes the cascade's iteration
well-founded; (3) the SIZING, stated as a COUNT. No new path and no construction is built here.

**Why this phase exists, and why it is not optional**: `pinCompat_of_ladderPath` (compiled, Phase
11) proves that the region-start countdowns of EVERY ladder path are pairwise
`1`-Lipschitz-compatible, because a region start's countdown IS the deadline register's value at
the idle position before it (`cntAt_eq_nxtAt_of_idle_pend`) and the register is `1`-Lipschitz
(`nxtAt_lipschitz_two_sided`). Lengthening one region by `l` raises that one pin by `l` and moves no
earlier region start, so compatibility must be re-established rather than assumed. The condition is
forced by the carrier, not an artefact of the lift lemma's shape.

**Tasks**:
- [x] State and prove the FINITENESS: given a splice at `a` of length `l` and an idle position
      `p ≤ a` on the original path, the set of pinned regions between `p` and `a` is finite. Prove
      that finiteness FROM `p` being idle rather than assuming it — that derivation is the content
      of this item, and it is what makes the cascade's iteration well-founded.
- [x] State the sizing as a COUNT (guardrail (c)). **Finding 8 applies and is binding**: of the six
      anchors the predecessor plan named, only `cascadeBound` (`CounterQuotient.lean`, which this
      module imports) is a library declaration and so the only one citable as a PROOF TERM.
      `forward_window`, `backward_constraint`, `region_doubling`, `doubling_attained` and
      `iter_doubling` live in `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` and
      are deliberately not promoted (`RunLayer.lean`'s and `Certificate.lean`'s own docstrings say
      so); cite them by PATH in a docstring as the probe-level record of the arithmetic, never as
      proof terms. The in-module proof terms available for the sizing are `cascadeBound`,
      `nxtAt_lipschitz_two_sided` and `cntAt_eq_nxtAt_of_idle_pend`. **Finding 9 also applies**: the
      exponential `(K2)` reading `two_pow_card_prodState_le_Tc` lives in `LadderChain.lean`, which
      imports this module, so it is NOT available here; it is available to Phase 15 and above. Do
      not attempt to import it. No complexity claim: the exponential in the number of pinned regions
      is named as a count of iterations.
- [x] Record the regime exhaustiveness explicitly, as a lemma rather than as prose, from
      `pend_past_of_nxtAt_lt` and `clipIdx_regime_of_eq`. The pin-free dichotomy of `LadderPin.lean`
      is a DIFFERENT dichotomy over a different hypothesis and is above this module in any case; do
      not cite it, and do not restate it here under a new name.
- [x] **Keep the module under its length ceiling, by the pre-authorized remedy.** Measured at this
      plan's authoring: `LadderAgree.lean` is 2,300 lines against an in-source
      `set_option linter.style.longFile 2400`. PRIMARY REMEDY: raise the in-source baseline in place
      to the next value the linter accepts, and record the new value in the phase's own notes; never
      split as a first move. CONTINGENCY, pre-authorized and listed under `Files to modify` so a
      dispatch can actually commit it: move this phase's three facts into a new
      `LadderCascade.lean` importing `LadderAgree` alone, with the two import edges, and record that
      Phase 15 must then import it.
- [x] Wire the new declarations (axiom pins, docstring, generated inventory blocks, `status.typ`).
      No C14 entry and no theorem-index row: this phase lands no Goal. *(deviation: altered — the
      inventory regeneration rewrote `FormalSystem/Metalogic/README.md` and the root `README.md`
      as well as the RaySummary README; both are generated line-count cascades of the one library
      edit, neither is listed under `Files to modify`, and both are committed with this phase as a
      declared `file_scope` excursion, because leaving them out leaves the INV inventory check
      stale.)*

**Prohibited workarounds**: do NOT state, assume or anticipate the cascade construction here — it is
Phase 11.8's; do NOT weaken `exists_spliced_ladderPath` by dropping or relaxing a pin hypothesis
(`pinCompat_of_ladderPath` proves the condition is forced, so a relaxed lift lemma would be false,
not weaker); do NOT replace the sizing by raising `Tc` or `Tn` (the parameters are OUTPUTS, and
`short_idle_threshold_refuted` is why `Tc` comes from the cascade bound); do NOT assume the number
of pinned regions is bounded by a constant; do NOT name any certificate object or any
certificate-side periodicity (`prodPre_periodic`, `prodPreStep`, `cohIdle`, `satThreshold`,
`satPeriod`); do NOT edit `LadderPump.lean`, `LadderPin.lean` or `LadderChain.lean`; and do NOT use
`sorry`, `axiom` or a vacuous definition.

**Timing**: NOT COSTABLE, and no hour figure is invented by this revision. The three deliverables are
consequences of arithmetic already landed, which is why they are separable and closable — but the
NOT COSTABLE declaration covers this content and this revision does not convert a declaration of
ignorance into an estimate.

**Depends on**: 7, 11

**Verification Tier**: interface

**Tier Justification**: Every statement here is about `IsLadderPath`, `objAt`/`cntAt`/`nxtAt` and
the pins, all inside `LadderAgree.lean` over the landed `RunLayer.lean` pin-lemma interface, so the
covering check is the guarded scoped build of that one module plus its axiom test
(`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree`
and the same for `BimodalTest.Metalogic.KTypeSummaryAxiomTest`); no statement of this phase mentions
`tpOf`, `cellAt` or any certificate object.

**Scope Hypothesis**: One module plus three wiring files; roughly one finiteness lemma, one sizing
statement and one regime-exhaustiveness lemma — three declarations plus whatever helpers the
finiteness derivation needs, to be MEASURED at phase close rather than trusted from here. The
carried figures this hypothesis rests on and their sources: `LadderAgree.lean` at 2,300 lines with
baseline 2,400, both measured directly at this plan's authoring; the five probe-level anchor names,
read from `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` and the two module
docstrings that disclaim their promotion. If the finiteness cannot be derived from `p` being idle,
the phase is `[BLOCKED]` with the goal state recorded, Phase 11.8 inherits that, and Phase 15
inherits it in turn; never an assumed bound on the number of pinned regions, and never a relaxed pin
hypothesis.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - the finiteness of the pinned-region set, the sizing statement, the regime-exhaustiveness lemma, and the `longFile` baseline if the primary remedy is taken
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCascade.lean` - CONTINGENCY ONLY (the length remedy of last resort); listed here so that a dispatch taking it can commit it
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - CONTINGENCY ONLY: the import edge for that module
- `FormalSystem.lean` - CONTINGENCY ONLY: the import edge for that module
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom-profile entries for the new declarations
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the generated inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- Guarded scoped build of `LadderAgree.lean` and of the axiom test each exit 0 with 0 warnings, with an explicit `--timeout` and the bounded single-call idiom per `context/patterns/bounded-build-waiter.md`.
- The finiteness is PROVED from `p` being idle: the hypothesis appears in the statement and `lean_minimal_hypotheses` (or an equivalent check) confirms it is consumed. A finiteness lemma carrying an assumed bound on the number of pinned regions does not meet this phase.
- The sizing is stated as a count: a grep of the phase's new docstrings for `complexity`, `bound on the size`, `upper bound` finds nothing outside a sentence naming the quantity as a count (guardrail (c)).
- **No proof term in this phase names a probe-level identifier**: `grep -nE 'forward_window|backward_constraint|region_doubling|doubling_attained|iter_doubling|two_pow_card_prodState_le_Tc' FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` returns only lines inside a docstring or comment. The scoped build is the second, mechanical check: none of the six elaborates in this module.
- `exists_spliced_ladderPath` is UNMODIFIED: `git diff` shows no change to its statement, so no pin hypothesis was relaxed. `pinCompat_of_ladderPath`, `exists_spliced_ladderPath_of_pend_past` and `atomPreservingCountMove_refuted` are likewise unmodified.
- No declaration of this phase constructs a path: a grep of the new declarations for `exists_spliced_ladderPath_of_idle_past` returns nothing — that lemma is Phase 11.8's.
- The length ceiling holds: the module's own `set_option linter.style.longFile N` is at or above the file's line count at the phase's close, and the scoped build reports 0 warnings (the `longFile` linter is the mechanical check here, so a clean scoped build IS the evidence). If the contingency module was taken, `git show --stat HEAD` names it and both import edges in the SAME commit as the import edges, and the phase's notes record that Phase 15 must import it.
- The certificate-freedom grep (the Phase 11.3 form, extended with `prodPre_periodic`, `prodPreStep`, `cohIdle`, `satThreshold` and `satPeriod`) over `LadderAgree.lean` returns nothing, and the import list contains no certificate module other than `CounterQuotient`.
- `#print axioms` on every new declaration: no `sorryAx`, no custom axiom, no `native_decide`. `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0` (baseline 0, measured at this plan's authoring). The repository-wide vacuous-definition grep is UNCHANGED from the dispatch's starting commit (baseline 1 hit, `FormalSystem/Examples/TemporalStructures.lean:495`, `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`, a false positive where `:= trivial` closes a real goal — "count 0" is unmeetable for this pattern and is not asked for), and a MODULE-SCOPED grep over `LadderAgree.lean` is count 0. `grep -rn '^axiom ' FormalSystem/ --include=*.lean | wc -l` is unchanged from its baseline of 10, and the same over `Tests/` unchanged from 2 (both measured at this plan's authoring; both counts are docstring prose, so "count 0" is unmeetable and is not asked for).
- `bash scripts/check-module-invariants.sh`, `bash scripts/typst-sync-check.sh`, `bash scripts/readme-lint.sh`, `bash scripts/check-evidence-probes.sh` and `bash .claude/scripts/check-task-references.sh --quiet` each exit 0, each exit status read directly.
- If the phase closes `[BLOCKED]`: the goal state is recorded, Phase 11.8's and Phase 15's inherited contingency is named in the handoff, and no pin hypothesis anywhere has been relaxed to get past it.

**CLOSURE RECORD (measured, not estimated).** Landed in `LadderAgree.lean`, in a new
`section Cascade` between the splice section and the alternative-history section: `pinnedRegions`
(def), `pend_of_mem_region`, `pinnedRegions_subset_Ico`, `pinnedRegions_finite`,
`pinnedRegions_ncard_le`, `pin_deficit_le_of_lengthen`, `cascadeDemand` (def),
`cascadeDemand_add_succ` and `cascadeDemand_le_cascadeBound`, plus
`regime_exhaustive_of_clipIdx_eq` — nine theorems and two definitions, against the Scope
Hypothesis's "three declarations plus whatever helpers the finiteness derivation needs".

- **Finiteness, and where `p` idle is consumed.** The load-bearing statement is
  `pinnedRegions_subset_Ico`: a pending region can be arbitrarily long, so a region whose span
  meets the window `[p, a]` can start arbitrarily far below `p`, and nothing about the window
  bounds that set below. An IDLE `p` lies in no pending region (`pend_of_mem_region`, over
  `cntAt_sub_of_pend`), so no region start below `p` can have its span reach `p`, and the set
  collapses into `Set.Ico p a`. `lean_minimal_hypotheses` on `pinnedRegions_subset_Ico` reports
  every explicit binder, `hp` included, **load-bearing**. `pinnedRegions_finite` and
  `pinnedRegions_ncard_le` are its corollaries; no bound on the number of pinned regions is
  assumed anywhere.
- **The sizing, as a count.** `cascadeDemand` is the recurrence `a (k + 1) = 2 * a k + J + 1`,
  `cascadeDemand_add_succ` its closed form `a k + (J + 1) = (J + 1) * 2 ^ k`, and
  `cascadeDemand_le_cascadeBound` the sizing against `cascadeBound` — the only sizing anchor
  citable here as a proof term, as finding 8 says. The five probe-level anchors are cited by PATH
  in the section docstring and appear nowhere in a proof term; `two_pow_card_prodState_le_Tc` is
  named only as unavailable (finding 9).
- **Length remedy: the PRIMARY one.** The in-source baseline was raised in place from
  `set_option linter.style.longFile 2400` to `2600`; the module measures 2,476 lines at close.
  The contingency module `LadderCascade.lean` was NOT created and no import edge moved.
- **Measured at close.** Scoped build of `LadderAgree` and of
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest`: exit 0, 0 errors, 0 warnings each. Full
  `lake build`: exit 0, 0 errors, 0 warnings, 2,895 jobs. `#print axioms` on all nine new
  theorems: subsets of `[propext, Classical.choice, Quot.sound]`; no `sorryAx`, no custom axiom,
  no `native_decide`. `lean-sorry-census.sh FormalSystem Tests`: exit 0, `sorry_count: 0`.
  Module-scoped vacuous grep: 0. Repository-wide vacuous grep: 1, unchanged. `^axiom `: 10 in
  `FormalSystem/`, 2 in `Tests/`, both unchanged. `git diff --numstat` on `LadderAgree.lean`:
  178 added, 1 removed — the one removal is the `longFile` line, so
  `exists_spliced_ladderPath`, `pinCompat_of_ladderPath`,
  `exists_spliced_ladderPath_of_pend_past` and `atomPreservingCountMove_refuted` are byte-identical
  and no pin hypothesis was relaxed. `exists_spliced_ladderPath_of_idle_past` appears once, in a
  docstring sentence saying it is NOT landed here. Certificate-freedom grep (extended form): 0;
  the import list is unchanged at `AnchorLayer` and `CounterQuotient`.
  `typst-sync-check.sh`, `readme-lint.sh`, `check-evidence-probes.sh` (47 wired probes) and
  `check-task-references.sh --quiet` each exit 0.
- **One criterion NOT met, and why it is not this phase's.** `check-module-invariants.sh` exits 1
  on `FAIL C16`: `lake exe runLinter` reports an `unusedArguments` finding on
  `mem_cellAt_of_shift_of_hasForwardSlack` (`LadderChain.lean:2136`, the `hslk` binder) that is
  absent from `scripts/nolints.json`. `LadderChain.lean` is clean at this dispatch's starting
  commit and this phase is forbidden to edit it, so the finding is pre-existing and outside this
  phase's territory. Every other group of that script passes, the `INV` inventory group included
  after regeneration. This is the exact "absolute criterion against a pre-existing baseline"
  class the Risks table names; recorded rather than worked around, and the narrow remedy belongs
  to whoever owns that module's lint pins.

---

---

### Phase 11.3: Land the Alternative-History Construction in the Library, Generalised [COMPLETED]

**Goal**: Closed. `altWalkPath` and `altWalkPath_eq_of_objAt_eq` landed in `LadderAgree.lean`,
generalised away from the prototype's fixture, with the compiled non-vacuity witness the phase
required.

**Timing**: NOT COSTABLE. The record offered no cost figure for this phase and none was invented.

**Depends on**: 11.1

**Verification Tier**: interface

**Tier Justification**: The construction is consumed by Phases 11.4 and 11.6 inside the same module
over the landed `RunLayer.lean` interface, so the covering check is the guarded scoped build of
`LadderAgree.lean` plus its axiom test.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - altWalkPath, altWalkPath_eq_of_objAt_eq, the non-vacuity witness
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pins
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`,
Phase 11.3. The two budget prototypes stayed prototype records and were not promoted, for the two
reasons that phase's task list records.

---

### Phase 11.4: The Atom-Valuation Closure Agreement [COMPLETED]

**Goal**: Closed. The atom-valuation closure agreement landed — `truthAt_iff_of_lab_eq_of_stabBoxFree`,
`truthAt_iff_of_lab_eq_of_stabPinned`, `tpOf_stabFree_eq_of_lab_eq`, `tpOf_stabBoxFree_eq_of_lab_eq`.

**Timing**: NOT COSTABLE. The record offered no cost figure for a closure induction of this shape and
none was invented.

**Depends on**: 11.3

**Verification Tier**: full

**Tier Justification**: The induction quantifies over every clause of the closure and reaches
`PlusLanguage`'s truth clauses and `AnchorLayer.lean`'s type layer at once.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - the closure agreement's four declarations
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pins
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`,
Phase 11.4.

---

### Phase 11.5: The Stab-Free Cell Agreement on `kappa`-Classes [COMPLETED WITH EXCLUSIONS]

**Goal**: Closed on its own refuting branch. The countdown rigidity landed (`cntAt_eq_of_pend_eq`,
`PendFactorsLab`, `pendFactorsLab_of_atom`, `cntAt_eq_of_lab_eq_of_pendFactorsLab`); route B's
construction landed as the named schema `AtomPreservingCountMove` and was REFUTED at full generality
as `atomPreservingCountMove_refuted`; the obligation landed as the Prop-valued schema
`CellLEZeroConstOfKappaEq` beside `kappa_eq_of_shift`; and the forty-sixth wired probe records the
refutation with non-vacuity witnessed on both sides.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Prove `cellLE_zero_const_of_kappa_eq` under route B's construction | The construction the proof would run on is REFUTED at full generality, for every object whose pending bit is readable in the language, so the item is decided against rather than deferred | `atomPreservingCountMove_refuted`, confirmed present in `LadderAgree.lean` at this revision's authoring, with `cntAt_eq_of_pend_eq`, `pendFactorsLab_of_atom` and `cntAt_eq_of_lab_eq_of_pendFactorsLab` as its mechanism. Wired as the forty-sixth probe `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` |
| The depth-`0` cell agreement itself, as a THEOREM of this phase | The obligation is STATED (`CellLEZeroConstOfKappaEq`, a Prop-valued schema on the precedent of `LadderCons`/`certChain`) and is neither proved nor refuted under `ParamsOk`. The reserved name stays claimed by nothing | `CellLEZeroConstOfKappaEq` confirmed present as a `def` in `LadderAgree.lean`; the reserved name claimed by no declaration, confirmed by grep at this revision's authoring. Where the decision now sits: Phase 11.9 of this plan |
| Route B as the route to the agreement | Decided against on compiled ground, not abandoned: the route's two requirements are jointly unsatisfiable, and no parameter condition can exclude the refuting labelling | The same refutation at full generality. Full as-executed record: `plans/08_cell-agreement-construction-handoff.md`, Phase 11.5 |

**What these exclusions do NOT say**: they do not refute `CellLEZeroConstOfKappaEq`, they do not
settle the filed `cellAt_const_of_kappa_eq`, `ladderSound`, `ladderLift` or `ladderRealized`, they do
not touch the presentation decision, and they leave half (i) and the atom-valuation agreement
standing at their own hypotheses. `cntAt_eq_of_pend_eq` is a strict strengthening available to every
later argument about ladder counters whatever this route's fate.

**Timing**: NOT COSTABLE. This was the mathematical heart of route B and no construction for it was
recorded; no estimate was offered and none was invented.

**Depends on**: 11.4

**Verification Tier**: full

**Tier Justification**: The phase's statements span `cellAt`, `tpOf`, `kappa` and the whole atom row
at once, and its refuting object is a wired probe observed by the evidence gate.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - the countdown rigidity, AtomPreservingCountMove, atomPreservingCountMove_refuted, CellLEZeroConstOfKappaEq, kappa_eq_of_shift
- `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` - the forty-sixth probe
- `scripts/check-evidence-probes.sh` - the probe's table block and array entry
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pins
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the inventory blocks and the refutation record
- `typst/generated/status.typ` - the regenerated line counts

**Verification**: Closed as executed; see `plans/08_cell-agreement-construction-handoff.md`,
Phase 11.5.

---

### Phase 11.6: The `⊡`-Nesting-Depth Induction [NOT STARTED]

**GATED ON PHASE 11.9 OF THIS PLAN — NOT ON ANY EXTERNAL TASK.** This phase inducts from the
depth-`0` cell agreement as its base case, and that base case is STATED
(`CellLEZeroConstOfKappaEq`, a Prop-valued schema) and landed as no theorem. **The gate this phase
carried in the predecessor plan named an external construction task that is now `[ABANDONED]`; that
gate is removed and replaced by Phase 11.9, which decides the schema.** Entering this phase before
`cellLE_zero_const_of_kappa_eq` exists as a LANDED theorem would mean inducting from nothing, and
the first verification item below is written to catch exactly that. **Two further facts constrain
what may lift the gate**, both re-derived at this revision's authoring and recorded here so a
dispatch does not rediscover them mid-proof: (i) a path-selected or regime-restricted depth-`0`
result CANNOT feed this induction, because `stab_mem_tpOf_iff_cell` reads
`PlusFormula.stab χ ∈ tpOf M φ σ z ↔ ∀ T ∈ cellAt M φ (σ.state z) z, χ ∈ T`, a universal over the
FULL cell, and `cellAt M φ w z = {T | ∃ σ, σ.state z = w ∧ tpOf M φ σ z = T}` ranges over every
history through the state; (ii) the landed depth-`0` facts are exactly of that path-selected kind —
`cellAt_subset_of_shift_of_pend_past` upward and `mem_cellAt_of_shift_of_hasForwardSlack_exact`
downward on the witnessing path — so neither lifts the gate however it is instantiated. Re-entry is a
`/revise` act once Phase 11.9 reports, with its verdict as the input; the remedy is never a `sorry`,
a schema consumed as if it were a theorem, a weakened base case, or a derivation of the agreement
from (S) and (C'). The phase's goal, tasks, prohibitions, sizing and verification are otherwise
unchanged by this revision.

**Goal**: Lift the depth-`0` cell agreement to the whole closure by induction on `stabDepth`, and
land the depth-indexed agreement `cellAt_le_const_of_kappa_eq : ∀ d, …` — for every `d`, the
depth-`≤ d` part of the cell is constant on `kappa`-classes under
`hp : ParamsOk step pend lab φ Tc Tn P B`. The step at `d + 1` reads the `⊡` bits through the landed
`stab_mem_tpOf_iff_cell`, whose right-hand side is a statement about the very cells the induction
hypothesis has already equated at depth `d`; Phase 11.1's landed relative transport
(`truthAt_iff_of_objAt_eq_of_stabPinned`, `tpOf_eq_of_objAt_eq_of_pinned`) is instantiated at
`L := stabDepth · ≤ d` to carry everything else. Phase 11.7 reads the final instance at the
closure's own bounded depth.

**This obligation is carried forward, not introduced by the route decision.**
`stab_mem_tpOf_iff_cell` says the `⊡` letters cannot be transported clause-by-clause the way the
other five can: their values ARE cell-level data, and the only way to know them at the compared state
is to know the cells agree at lower depth already. The induction is forced by the semantics however
the route is chosen; what changes is only its BASE CASE.

**Tasks**:
- [ ] Define the depth-restricted type and cell: `tpLE d M φ σ z` (the filter of `tpOf` by
      `stabDepth · ≤ d`) and `cellLE d M φ w z` (its image over histories through `w` at `z`). Prove
      the two readings the induction needs: `tpLE` at the closure's own bound is `tpOf`, and
      `cellLE 0` is the fragment the base case agrees. If Phase 11.4's widened corollary landed,
      `cellLE 0` is the stab-free cell; if it did not, it is the stab-free-and-box-free cell and the
      `box` letters are carried by the step through the landed `box_mem_tpOf_transfer`. Record which.
- [ ] Prove the base case `d = 0` by CITING the landed `cellLE_zero_const_of_kappa_eq`. The base case
      is not re-derived here, and in particular it is NOT re-derived from any splice-indexed type
      transport, and NOT from a path-selected or regime-restricted substitute — the gate note above
      says why neither suffices.
- [ ] Prove the step: assume the depth-`≤ d` agreement for every `kappa`-colliding pair; show the
      depth-`≤ (d+1)` agreement. The `⊡χ` letters with `stabDepth χ ≤ d` are transported by
      `stab_mem_tpOf_iff_cell` read against the induction hypothesis, and every other
      depth-`≤ (d+1)` formula by Phase 11.1's relative transport at `L := stabDepth · ≤ d` together
      with Phase 11.4's atom-valuation agreement where the two paths' walks differ.
- [ ] Record that the induction consumes `hp` at every depth, not only at the base. If the step
      closes without `hp`, stop and record it — the fourteenth probe's refutation holds for every
      `kappa` and every candidate `Dmax`, so a proof that does not consume the parameter conditions
      has collapsed into the refuted shape.
- [ ] Wire the new declarations (axiom pins, docstring, generated inventory blocks, `status.typ`).
      No C14 entry and no `docs/theorem-index.md` row: this phase lands no filed Goal.

**Prohibited workarounds**: do NOT introduce a depth-stratified certificate family — that is route
(R-a), which the recorded decision did not take; do NOT discharge the step by citing
`prodPre_periodic`, `prodPreStep`, `cohIdle`, `satThreshold`, `satPeriod` or any certificate-side
periodicity; do NOT reinstate `tpOf_stabFree_eq_of_splice` in any form at any depth; do NOT bound
the depth by a constant or by the model; do NOT state the induction over a trace-level `Presented`
hypothesis or any finite-fibre or finite-width assumption; do NOT raise `Tc`, add a parameter, add a
fifth parameter source or further strengthen `ParamsOk`; do NOT cite a Büchi or MSO lemma in place
of a proof; do NOT require `cslib`; and do NOT use `sorry`, `axiom` or a vacuous definition.

**Timing**: NOT COSTABLE. The step is the part route (R-b) relocates into the agreement's own proof
rather than removing; no estimate is offered and none is to be invented.

**Depends on**: 11.5, 11.9 — both are required, and 11.5 being closed does not on its own make this
phase enterable, because what 11.5 closed with exclusions is exactly this phase's base case. Phase
11.9's verdict decides whether this phase is a route at all.

**Verification Tier**: full

**Tier Justification**: The induction quantifies over the whole closure and over `cellAt`, so it
reaches `AnchorLayer.lean`'s cell layer, `PlusLanguage`'s truth clauses and all of Phases 11.1, 11.4
and 11.5 at once, and Phase 11.7 consumes its conclusion — no cheaper tier covers that surface.

**Scope Hypothesis**: One module plus three wiring files; roughly two definitions (`tpLE`, `cellLE`),
their two readings, the base case, the step and the depth-indexed conclusion — six declarations, to
be measured at phase close rather than trusted from here. The `longFile` constraint of Phase 11.2
applies here too, with the same pre-authorized primary remedy. If the step cannot be closed, the
phase is `[BLOCKED]` with the goal state recorded and the depth at which it stalls named: the depth
is itself the useful datum for a successor round.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - tpLE, cellLE, their readings, the base case, the step, cellAt_le_const_of_kappa_eq, and the `longFile` baseline if the primary length remedy is taken
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom-profile entries for the new declarations
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the generated inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- **The gate is checked before any other item of this phase is read**: `cellLE_zero_const_of_kappa_eq` exists in the library as a LANDED theorem — not as the Prop-valued schema `CellLEZeroConstOfKappaEq`, and not as a path-selected or regime-restricted substitute under another name — and `#print axioms` on it shows no `sorryAx`, no custom axiom and no `native_decide`. If it does not, this phase is not enterable, no item below applies, and the honest report is that the plan's enterable work is Phases 11.2, 11.8, 11.9 and 12.1 — never a partial on this phase.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` exits 0 with 0 warnings; the unscoped guarded build exits 0 at the end of the phase. Guarded, explicit `--timeout`, bounded single-call idiom.
- The certificate-freedom grep (the Phase 11.3 form) over `LadderAgree.lean` still returns nothing, and the import list is unchanged.
- `lean_minimal_hypotheses` (or an equivalent check) confirms `hp` is NOT a redundant binder in the step, and not only in the base case.
- `cellLE` at the closure's own depth bound is proved equal to `cellAt`, so the final instance is the full cell and not a restriction left in place.
- No depth-stratified certificate object exists anywhere: `grep -rnE 'certChain.*[Dd]epth|certAdmK.*[Dd]epth|stratif' FormalSystem/Metalogic/Decidability/RaySummary/` returns nothing outside a docstring naming route (R-a) as not taken.
- No splice-indexed type transport appears as a lemma or a hypothesis: `grep -rnE 'tpOf.*splice|splice.*tpOf' FormalSystem/ Tests/` returns nothing outside a docstring sentence recording the refutation.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; module-scoped vacuous grep over `LadderAgree.lean` count 0; the repository-wide vacuous grep unchanged from its 1-hit baseline and `grep -rn '^axiom '` unchanged from its 10/2 baselines (see Phase 11.2's verification for the measured values and why absolutes are not asked for).
- `#print axioms` on every new declaration: no `sorryAx`, no custom axiom, no `native_decide`.
- `bash scripts/check-module-invariants.sh`, `bash scripts/typst-sync-check.sh`, `bash scripts/readme-lint.sh`, `bash scripts/check-evidence-probes.sh` and `bash .claude/scripts/check-task-references.sh --quiet` each exit 0.
- If the phase closes `[BLOCKED]`: the goal state and the stalling depth are recorded in the phase body and the handoff, with no `sorry`, axiom, vacuous definition, trace-level hypothesis, finite-fibre retreat, raised `Tc` or positionwise restatement anywhere in the tree.

---

### Phase 11.7: The Agreement `cellAt_const_of_kappa_eq` [NOT STARTED]

**GATED TRANSITIVELY, THROUGH PHASE 11.6 AND SO THROUGH PHASE 11.9.** This phase instantiates Phase
11.6's depth-indexed agreement. Nothing in its body is changed by this revision beyond this note and
one recorded consequence: **if Phase 11.9's verdict is REFUTED, this phase's Goal is FALSE**, because
`CellLEZeroConstOfKappaEq` is the instance `t := z` of this Goal's own signature with one extra
hypothesis, so this Goal implies the schema. On that branch this phase closes
`[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record citing Phase 11.9's compiled
object, and the remedy is a further `/revise` — never a weakened statement under this filed name.
Its Goal, its token-for-token signature fidelity to the `## Lean Challenge Statements` block, its C14
obligation and its contingency branch all otherwise stand as written.

**Goal**: Prove `cellAt_const_of_kappa_eq` at the signature the `## Lean Challenge Statements` block
pins, token-for-token, with `(hp : ParamsOk step pend lab φ Tc Tn P B)` in the recorded position:
under the parameter conditions, the cell at `(q, c, n)` equals the cell at `(q, c', n')` whenever
`kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')`. The proof is Phase 11.6's depth-indexed
agreement at the closure's own depth bound, with Phase 11.1's path/history bridge moving between the
two presentations. This is the phase that breaks the circularity, and the certificate-freedom of its
module is the mechanical form of that claim.

**Tasks**:
- [ ] Prove `cellAt_const_of_kappa_eq` by instantiating `cellAt_le_const_of_kappa_eq` at the
      closure's depth bound and rewriting `cellLE` to `cellAt`. The hypothesis `hp` is CONSUMED in
      the argument and must appear in the proof, not be discarded at the top. If a proof appears to
      close without using `hp`, stop and record it.
- [ ] Add the `docs/theorem-index.md` row carrying `pinned:C14` and the matching C14 heredoc entry in
      `scripts/check-module-invariants.sh`. Unlike Phases 11 through 11.6, this phase DOES land a
      filed Goal, so the C14 pin is owed here.
- [ ] Pin the declaration in `KTypeSummaryAxiomTest.lean` and resync the generated README inventory
      blocks and `typst/generated/status.typ`.
- [ ] Record in the module docstring and in the README paragraph what the agreement does and does NOT
      say: it equates CELLS at `kappa`-colliding states; it asserts no tuple index, no bound, and no
      device discrimination; and the forward-only character of the ladder's structural liveness is
      unaffected by it (guardrail (e)). Record also that the route taken is the cell-level one and
      that the path-level splice invariance it replaces is REFUTED, not merely absent — in a sentence
      that names the refutation probe by path.
- [ ] **Contingency branch, taken ONLY if Phase 11.5, 11.6 or 11.9 closed `[BLOCKED]` while a
      strictly weaker, honestly named auxiliary did land**: record the auxiliary under its own name,
      mark the filed `cellAt_const_of_kappa_eq` `[BLOCKED]` with the goal state recorded, and name
      both in `docs/theorem-index.md` with the filed statement listed as OPEN. Adding any hypothesis
      to a recorded Challenge statement is never an implementer's move — Statement Fidelity routes it
      to the user. A landed auxiliary never promotes the phase out of `[BLOCKED]`.

**Prohibited workarounds**: do NOT use `sorry`, `axiom`, `def X := True` or any vacuous placeholder;
do NOT add a finite-fibre or finite-width hypothesis; do NOT state the agreement with a trace-level
`Presented` hypothesis; do NOT narrow it to the positionwise shape (`no_positionwise_lift` is
compiled, so the narrowed form is FALSE, not weaker); do NOT reinstate `tpOf_stabFree_eq_of_splice`
in any form; do NOT discharge it by citing `prodPre_periodic` or any certificate-side periodicity
across the certificate/model boundary; do NOT derive it from (S) or (C'); do NOT enter route A; do
NOT raise `Tc`, add a parameter, add a fifth parameter source or further strengthen `ParamsOk`; do
NOT cite a Büchi or MSO lemma in place of a proof; and do NOT require `cslib`.

**Timing**: NOT COSTABLE. It is the conclusion of the counter-lift mathematics; no estimate is
offered and none is to be invented by the implementer.

**Depends on**: 11.6

**Verification Tier**: full

**Tier Justification**: The Goal's statement spans `ladderModel`, `cellAt` and `kappa` at once, it is
the input of Phases 12.2, 13, 15 and 16 across a module boundary, and it is a filed Challenge
statement whose signature fidelity is checked against the block below — no cheaper tier covers that
surface.

**Scope Hypothesis**: One Goal declaration in `LadderAgree.lean` plus five wiring/record files; no
new machinery, since Phases 11.3-11.6 own all of it. If the instantiation needs a lemma those phases
did not land, that is a defect in their decomposition and is to be recorded as such rather than
patched by inlining a new argument here.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - cellAt_const_of_kappa_eq and its docstring
- `docs/theorem-index.md` - one row carrying pinned:C14
- `scripts/check-module-invariants.sh` - the matching C14 heredoc entry
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - one axiom-profile entry
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the generated inventory blocks and the paragraph recording what the agreement does and does not say
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- The guarded scoped build of `LadderAgree.lean` exits 0 with 0 warnings; the unscoped guarded build exits 0 at the end of the phase. Guarded, explicit `--timeout`, bounded single-call idiom.
- `cellAt_const_of_kappa_eq`'s signature matches the `## Lean Challenge Statements` block token-for-token, by direct `diff` of the extracted signature text — the parameter hypothesis included, in the recorded position. `lean-challenge-snapshot.sh` is NOT a gate (it refuses past `planned`, and its `--check` verdict is advisory in any case).
- `lean_minimal_hypotheses` (or an equivalent check) confirms `hp` is NOT a redundant binder in the proof.
- `#print axioms cellAt_const_of_kappa_eq` shows no `sorryAx`, no custom axiom, no `native_decide`.
- The certificate-freedom grep (the Phase 11.3 form) over `LadderAgree.lean` still returns nothing, and the import list contains no certificate module other than `CounterQuotient`.
- `bash scripts/check-module-invariants.sh` exits 0 WITH the new C14 entry and the matching `docs/theorem-index.md` row present — this is the one phase of the 11-series for which that is owed.
- No tuple index is stated: a grep for an `index x = index y → cellAt x = cellAt y` shape returns nothing outside a docstring naming it as refuted.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; module-scoped vacuous grep count 0; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.
- `bash scripts/typst-sync-check.sh`, `bash scripts/readme-lint.sh`, `bash scripts/check-evidence-probes.sh` and `bash .claude/scripts/check-task-references.sh --quiet` each exit 0.
- If the phase closes `[BLOCKED]` or on the contingency branch: the goal state is recorded in the phase body and the handoff, the filed statement is named as OPEN in `docs/theorem-index.md`, the README paragraph and the summary — never as landed — and no `sorry`, axiom, vacuous definition, trace-level hypothesis, finite-fibre retreat, raised `Tc` or positionwise restatement appears anywhere in the tree.

---

### Phase 11.8: The Pin Cascade, The Construction — The Interface-Level Statement in the Remaining Regime [BLOCKED]

**ENTERABLE BEHIND PHASE 11.2, AND GATED ON NOTHING OPEN. RESTATED BY THIS REVISION.** The blocker
record below is carried verbatim: it is the compiled reason the restatement exists, and it is
correct as diagnosed — re-checked against the landed source at this revision's authoring (finding
22). What it refutes is the `spliceObj`-shaped conclusion, in the regime where the tight chain makes
every pin pair exactly tight. What it leaves OPEN is the narrower statement the single consumer
actually reads: the two facts `spliced_at_region` exposes at the comparison position. This revision
takes that restatement, decides here rather than at dispatch time what Phase 15 consumes, and
returns the phase to `[NOT STARTED]` against the restated deliverable. **The restated statement is
OPEN, not proved**: the refutation that kills the `spliceObj`-shaped conclusion establishes nothing
about this one, and the cascade below is a mechanism rather than a proof.

**BLOCKER** (Phase 11.8), raised before any proof attempt rather than discovered mid-proof:

- **What failed**: This phase's Goal and its third task contradict each other, and the shape the
  third task names is REFUTABLE rather than merely hard. The Goal says the construction discharges
  the pin hypotheses "by lengthening the preceding idle runs along with the spliced region", which
  changes the object walk BELOW the splice point. The third task asks for
  `exists_spliced_ladderPath_of_idle_past` "with the same conclusion shape the landed
  pending-forever companion has" — that companion concludes about `spliceObj g a l` and
  `spliceCnt g a l`, which leave the walk below `a + l` untouched (`spliceObj_of_lt`). A walk that
  lengthens the earlier idle runs is not `spliceObj g a l`, so no construction can satisfy both.
- **What was tried**: the two statements were read against the landed module rather than attacked.
  `spliceCnt`'s own definition raises the pin at the start `s` of `a`'s region by exactly `l` — its
  `if a ≤ v + (cntAt g v : ℤ)` branch fires at `v = s + 1`, because `a` lies in that region — while
  leaving an earlier region start `v` whose region ends below `s` at `cntAt g (v + 1)`, since the
  branch does not fire there. `pinCompat_of_ladderPath` (compiled, Phase 11) proves pairwise
  compatibility of region-start countdowns NECESSARY for ANY ladder path whatsoever. So the spliced
  walk needs `((cntAt g (s+1) + l : ℤ) - cntAt g (v+1)).natAbs ≤ (s - v).natAbs` where the original
  path only supplies the same inequality without the `+ l`.
- **Why it is stuck**: whenever the original is TIGHT at that pair — `cntAt g (s+1) - cntAt g (v+1)
  = s - v` — the spliced walk demands `s - v + l ≤ s - v`, so for `l > 0` no ladder path has that
  object walk and that countdown. The regime's hypotheses are satisfiable together with tightness:
  Phase 11.9's compiled `tightChain_slack_zero` makes EVERY pair of pins of the tight doubling
  chain exactly tight, and every `v ≤ 0` of that chain is idle, which is the idle-past regime. The
  `spliceObj`-shaped conclusion is therefore false in this regime, not open.
- **What is needed**: a restatement, by `/revise`, of what the cascade concludes about — the walk
  that lengthens the earlier idle runs as well, with its own object and countdown, rather than
  `spliceObj`/`spliceCnt`; and a decision about what interface Phase 15 then consumes, since "one
  interface serves both regimes" is exactly what the refutation denies. A one-theorem probe would
  compile the refutation on the chain Phase 11.9 already declares, and is cheap, but no file under
  `specs/evidence/**` is listed under this phase's `Files to modify`, and an unlisted contingency
  file cannot be committed by an implement dispatch.
- **Prohibited workarounds**: NOT taken. No pin hypothesis of `exists_spliced_ladderPath` was
  relaxed, nothing was landed under the deliverable's name, no `sorry`, axiom or vacuous definition
  was written, and no checklist item was annotated and walked past. Phase 11.2's three landed facts
  are left standing and untouched. Phase 15 inherits this as its own contingency, as this phase's
  Scope Hypothesis says; the agreement does not.

**Goal**: Discharge, at the INTERFACE LEVEL, what `exists_spliced_ladderPath`'s two explicit pin
hypotheses were wanted for, in the regime the landed `exists_spliced_ladderPath_of_pend_past` does
NOT cover — the regime where an idle position lies in the path's past. The deliverable is not a
second description of a walk but an EXISTENTIAL over some ladder path delivering, at the comparison
position, exactly the two facts `spliced_at_region` exposes there: the same object state, and the
countdown raised by `l`. Three declarations, so that one interface serves both regimes for Phase 15:

```lean
-- In `LadderAgree.lean`, in the cascade section Phase 11.2 opened. The binders follow
-- `exists_spliced_ladderPath_of_pend_past`'s own (`LadderAgree.lean:1293`) and the conclusion
-- follows `spliced_at_region`'s (`:1260`); match them against the landed text rather than against
-- this block, which fixes the SHAPE and not the elaborated signature.

theorem exists_ladderPath_at_region_of_idle_past
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hpa : pend (objAt g a) = true)
    (hrep : objAt g a = objAt g (a + (l : ℤ)))
    (hidle : ∃ p : ℤ, p ≤ a ∧ pend (objAt g p) = false)
    (v : ℤ) (hv : v ≤ a) (hreg : a ≤ v + (cntAt g v : ℤ)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' v = objAt g v ∧ cntAt g' v = cntAt g v + l := sorry

theorem exists_ladderPath_at_region_of_pend_past
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hpast : ∀ p : ℤ, p ≤ a → pend (objAt g p) = true)
    (hrep : objAt g a = objAt g (a + (l : ℤ)))
    (v : ℤ) (hv : v ≤ a) (hreg : a ≤ v + (cntAt g v : ℤ)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' v = objAt g v ∧ cntAt g' v = cntAt g v + l := sorry

theorem exists_ladderPath_at_region
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hpa : pend (objAt g a) = true)
    (hrep : objAt g a = objAt g (a + (l : ℤ)))
    (v : ℤ) (hv : v ≤ a) (hreg : a ≤ v + (cntAt g v : ℤ)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' v = objAt g v ∧ cntAt g' v = cntAt g v + l := sorry
```

**The decision this revision takes about Phase 15's interface, so a dispatch does not have to.**
Phase 15 consumes `exists_ladderPath_at_region` and nothing else from the cascade. The middle
declaration is the pending-forever regime's corollary — the landed
`exists_spliced_ladderPath_of_pend_past` composed with `spliced_at_region`, which is where the two
facts come from on that side and is why that half is cheap. The third is the two joined by Phase
11.2's landed dichotomy `regime_exhaustive_of_clipIdx_eq`, which is what makes the interface
UNCONDITIONAL and retires the `spliceObj`-shaped conclusion from Phase 15's diet entirely. "One
interface serves both regimes" is therefore restored, at the level the refutation leaves open rather
than the level it closed: both regimes deliver the same two facts at the comparison position, and
neither delivers a pointwise walk identity.

**This phase is NOT dropped and not optional**: the two facts are what the lift reads at the
comparison position, and only the pending-forever regime supplies them today, so the admissibility
half of the counter-lift lemma stays conditional in one of the two regimes until this phase closes,
and (C') — Phase 15, its single consumer — needs it unconditional. The agreement does not depend on
it: no phase of 11.3-11.7 does, because the cell-level route spends no pin budget.

**Tasks**:
- [x] Land `exists_ladderPath_at_region_of_pend_past` FIRST *(completed and GREEN: three lines, `exists_spliced_ladderPath_of_pend_past` composed with `spliced_at_region`, in the Cascade section with `{g a l}` as explicit implicit binders because that section — unlike the Splice section the companion lives in — declares none; the elaborated signature matches the recorded block)* — it is the landed companion composed
      with `spliced_at_region` and costs almost nothing, and having it in hand fixes the conclusion
      shape the other two must match.
- [ ] State and prove `exists_ladderPath_at_region_of_idle_past` *(deviation: BLOCKED — not attempted and not faked. Phase 11.2 landed the cascade's BOOKKEEPING (`pinnedRegions_subset_Ico`, `pinnedRegions_finite`, `pinnedRegions_ncard_le`, `pin_deficit_le_of_lengthen`, `cascadeDemand`, `cascadeDemand_add_succ`, `cascadeDemand_le_cascadeBound`) and NOT the inserted walk: no declaration anywhere builds an idle-insertion walk, proves it is a ladder path, or iterates the construction over the pins. Goal state: the three-conjunct existential is open with its first conjunct `IsLadderPath step pend g'` unprovable from anything landed, because `cntAt_eq_of_obj_eq` (the countdown's rigidity) forces any path with `cntAt g' v = cntAt g v + l` to carry a DIFFERENT object walk, `spliceObj g a l` is the refuted candidate in this regime, and no third walk exists in the library. The failing pin pair is the one the carried blocker names: `(s, v)` with `s` the region start of `a`'s region and `v` an earlier region start whose region ends below `s`, at which the original is TIGHT — `cntAt g (s+1) - cntAt g (v+1) = s - v` — so the spliced walk demands `s - v + l ≤ s - v`. No pin hypothesis was relaxed, nothing was landed under a filed name, and no `sorry`, axiom or vacuous definition was written)* by the cascade, over Phase 11.2's
      four landed facts, which are CITED and never re-proved: `pinnedRegions_subset_Ico` (the
      confinement of the constraining pins to `Set.Ico p a` when the anchor `p` is idle — the
      regime hypothesis itself), `pinnedRegions_finite` (well-foundedness of the iteration),
      `pin_deficit_le_of_lengthen` (the per-step deficit) and `cascadeDemand_le_cascadeBound` (the
      sizing). **The insertion is strictly BELOW the comparison position's region start**: insert
      idle positions into idle runs below that start, which shifts the past downward on the `ℤ`
      axis while leaving the walk at and above the start pointwise fixed, so
      `objAt g' v = objAt g v` survives BY CONSTRUCTION rather than by a further argument. Pushing
      an earlier region start down by `d` grows `|s - v|` by `d` and so relaxes the inequality the
      splice violated; the displacement propagates to the next pin down, which is the doubling
      recurrence `cascadeDemand` already encodes.
- [ ] Join the two *(deviation: BLOCKED behind the item above, with a STATEMENT-LEVEL finding recorded: the join CANNOT be `regime_exhaustive_of_clipIdx_eq`. That lemma's dichotomy is between two ladder paths meeting at a `clipIdx` collision at a fixed next deadline, and it needs `hB : 2 ≤ B`, `g'`, `z'`, `hn : nxtAt g z = nxtAt g' z'`, `hne` and the `clipIdx` equality — none of which the three recorded signatures carry. The join these signatures actually admit is the plain excluded middle on `hidle : ∃ p ≤ a, pend (objAt g p) = false`, whose negation `push_neg`s to `hpast`. A future revision should name that instead)* into
      `exists_ladderPath_at_region`, and record in its docstring that this is the ONE interface
      Phase 15 consumes and that the `spliceObj`-shaped conclusion is REFUTED in the idle-past
      regime rather than merely unavailable — in a sentence naming the refutation's mechanism
      (`spliceCnt` raises the pin at `a`'s region start by exactly `l` while leaving an earlier
      region start alone, against `pinCompat_of_ladderPath`'s necessity) and the compiled object on
      which it bites (`tightChain_slack_zero`, in the Phase 11.9 probe, cited by PATH).
- [ ] Size the construction by CITING Phase 11.2's sizing statement *(deviation: deferred — not reached, because the construction it would size does not exist. Nothing was re-derived and `cascadeBound` was not cited as a proof term anywhere)*, never re-deriving it.
      **Findings 8 and 9 apply exactly as in Phase 11.2**: `cascadeBound`
      (`CounterQuotient.lean`) is the only importable anchor and the only one citable as a PROOF
      TERM; `forward_window`, `backward_constraint`, `region_doubling`, `doubling_attained` and
      `iter_doubling` live in `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` and
      are citable only in a docstring, by path; and `two_pow_card_prodState_le_Tc` is above this
      module in the import DAG and unavailable. The bound stays a COUNT (guardrail (c)): no
      complexity claim.
- [x] **Do NOT land anything under the name `exists_spliced_ladderPath_of_idle_past`.** *(honoured: the name is claimed by nothing, and so are `exists_ladderPath_at_region_of_idle_past` and `exists_ladderPath_at_region`. The existing docstring sentence is UPGRADED from "not landed" to "REFUTED IN THE IDLE-PAST REGIME, not merely absent", naming the mechanism — `spliceCnt` raising the pin at `a`'s region start by exactly `l` against `pinCompat_of_ladderPath`'s necessity — and the compiled object by PATH, `tightChain_slack_zero` in `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean`; the three declarations are named there too)* That name
      belongs to the refuted statement; leaving it unclaimed is what keeps the refutation legible.
      `LadderAgree.lean`'s existing docstring sentence saying it is not landed here stays, with the
      reason upgraded from "not landed" to "refuted in this regime, restated at the interface
      level", naming the three declarations above.
- [x] **Keep the module under its length ceiling** *(MEASURED at close: 2,477 → **2,558** lines against the in-source `set_option linter.style.longFile 2600`, so **42 lines** of headroom remain and no remedy was taken. The contingency module `LadderCascade.lean` was NOT created and neither import edge was touched)*, by the same pre-authorized primary remedy and
      the same listed contingency as Phase 11.2. Finding 24's measured figures apply: the module is
      at **2,477 lines** against an in-source `set_option linter.style.longFile 2600` (`:308`), so
      the headroom is **123 lines** — re-measure before editing rather than trusting that figure.
- [x] Wire the new declarations *(completed for the one declaration landed: a `#guard_msgs` + `#print axioms` pin for `exists_ladderPath_at_region_of_pend_past` whose own docstring records that the idle-past half is refuted and that the three other names are claimed by nothing; the upgraded `LadderAgree.lean` docstring; three generated inventory blocks; `status.typ`. The `#print axioms` invocation is split across two lines because the qualified name exceeds the 100-character limit on one)*.
      No C14 entry and no theorem-index row: this phase lands no filed Goal.

**Prohibited workarounds**: do NOT weaken `exists_spliced_ladderPath` by dropping or relaxing a pin
hypothesis, and do NOT modify `spliced_at_region`, `pinCompat_of_ladderPath`,
`exists_spliced_ladderPath_of_pend_past` or `spliceObj_of_lt`; do NOT land the restated conclusion
under the refuted statement's name; do NOT re-attempt the `spliceObj`-shaped conclusion in the
idle-past regime in any form (it is FALSE there, not open — the blocker record above is the
derivation and `tightChain_slack_zero` is the compiled object); do NOT replace the cascade by
raising `Tc` or `Tn`; do NOT assume the number of pinned regions is bounded by a constant, and do
NOT re-prove Phase 11.2's finiteness inline instead of citing it; do NOT reach for any certificate
object or certificate-side periodicity; do NOT edit `LadderPump.lean`, `LadderPin.lean` or
`LadderChain.lean`; and do NOT use `sorry`, `axiom` or a vacuous definition.

**Timing**: NOT COSTABLE. The construction is the one `(K2)`'s `cascadeBound` sizes, exponential in
the number of pinned regions, and the restated statement is open rather than known to hold; no
estimate is offered and none is to be invented.

**Depends on**: 11.2

**Verification Tier**: interface

**Tier Justification**: The three declarations are about `IsLadderPath`, `objAt`/`cntAt`/`nxtAt` and
the splice, all inside `LadderAgree.lean` over the landed `RunLayer.lean` pin-lemma interface, and
the third is consumed by Phase 15 across a module boundary, so the covering check is the guarded
scoped build of that one module plus its axiom test
(`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree`
and the same for `BimodalTest.Metalogic.KTypeSummaryAxiomTest`); no statement of this phase mentions
`tpOf`, `cellAt` or any certificate object.

**Scope Hypothesis**: One module plus three wiring files; three conclusion lemmas plus whatever
insertion construction the idle-past half needs, over Phase 11.2's four facts, the count to be
MEASURED at phase close rather than trusted from here. The carried figures and their source: the
module's **2,477** lines against its **2,600** in-source baseline, both measured at this revision's
authoring (finding 24), superseding the 2,300/2,400 pair the predecessor plan carried. **The
restated existential may itself be refutable** — nothing proves that a ladder path through the same
object state with the countdown raised by `l` exists in the tight idle-past regime, and the cascade
is a mechanism rather than a proof. If it cannot be closed, the phase is `[BLOCKED]` with the goal
state recorded and the failing pin pair named, and Phase 15 inherits that as its own contingency —
the agreement does not. If it is REFUTED instead, that is a complete outcome: land the refuting
object as a wired probe under a new honest name, record it, and leave Phase 15's interface named as
open. Never a relaxed pin hypothesis and never a quiet narrowing of a filed statement. A one-theorem
probe on the chain Phase 11.9's landed probe already declares is the cheap way to test the restated
shape before much is spent on it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - the insertion cascade, the three `exists_ladderPath_at_region*` declarations, the upgraded docstring sentence about the refuted name, and the `longFile` baseline if the primary length remedy is taken
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCascade.lean` - CONTINGENCY ONLY, listed so a dispatch taking the length remedy of last resort can commit it
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - CONTINGENCY ONLY: the import edge
- `FormalSystem.lean` - CONTINGENCY ONLY: the import edge
- `specs/evidence/seam-gluing-ray-product/ladder-idle-past-interface-refutation.lean` - CONTINGENCY ONLY, listed so a dispatch that REFUTES the restated statement can commit the refuting object in the same dispatch rather than discovering the file is unlisted
- `scripts/check-evidence-probes.sh` - CONTINGENCY ONLY: that probe's table block and `WIRED` array entry, on the refuting branch only
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom-profile entries for the new declarations
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the generated inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- Guarded scoped build of `LadderAgree.lean` and of the axiom test each exit 0 with 0 warnings, with an explicit `--timeout` and the bounded single-call idiom.
- All three of `exists_ladderPath_at_region_of_pend_past`, `exists_ladderPath_at_region_of_idle_past` and `exists_ladderPath_at_region` are proved theorems whose conclusions are IDENTICAL, checked by `diff` of the three extracted conclusion texts, and that shared conclusion is `spliced_at_region`'s own conjunction made existential — no occurrence of `spliceObj` or `spliceCnt` appears in any of the three conclusions (grep).
- **The refuted name is unclaimed**: `grep -rn 'exists_spliced_ladderPath_of_idle_past' FormalSystem/ Tests/` returns only docstring prose, and that prose names the statement as refuted in the idle-past regime rather than merely absent.
- The idle-past proof CITES Phase 11.2's `pinnedRegions_subset_Ico`, `pinnedRegions_finite`, `pin_deficit_le_of_lengthen` and `cascadeDemand_le_cascadeBound` by name (grep the proof body) rather than restating any of them, and the insertion's positions are all strictly below the comparison position's region start (read the construction).
- **No proof term names a probe-level or above-the-DAG identifier**: the grep of Phase 11.2's corresponding item returns only docstring or comment lines, and the scoped build is the mechanical check.
- `exists_spliced_ladderPath`, `exists_spliced_ladderPath_of_pend_past`, `spliced_at_region`, `spliceObj_of_lt`, `pinCompat_of_ladderPath` and `atomPreservingCountMove_refuted` are UNMODIFIED: `git diff` shows no change to any of their statements, and no pin hypothesis anywhere has been relaxed.
- The sizing stays a count: the guardrail (c) grep finds nothing outside a sentence naming the quantity as a count.
- The length ceiling holds, by the same check Phase 11.2 names; if the contingency module was taken, it and both import edges are in the SAME commit.
- The certificate-freedom grep (the extended form) over `LadderAgree.lean` returns nothing, and the import list is unchanged at `AnchorLayer` and `CounterQuotient`.
- `#print axioms` on every new declaration: no `sorryAx`, no custom axiom, no `native_decide`. `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; module-scoped vacuous grep count 0; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.
- `bash scripts/typst-sync-check.sh`, `bash scripts/readme-lint.sh`, `bash scripts/check-evidence-probes.sh` and `bash .claude/scripts/check-task-references.sh --quiet` each exit 0; `bash scripts/check-module-invariants.sh` passes every group except the single pre-existing `C16` finding of finding 26, unchanged in content and count.
- If the phase closes `[BLOCKED]`: the goal state is recorded with the failing pin pair named, Phase 15's inherited contingency is named in the handoff, Phase 11.2's landed facts are left standing, and no pin hypothesis anywhere has been relaxed. If it closes on the REFUTED branch: the refuting object compiles standalone through the build guard with `#print axioms` reporting a subset of `[propext, Classical.choice, Quot.sound]`, it is wired in the same commit, and Phase 15's interface is named as open in the phase body and the handoff — never as landed.

---

### Phase 11.9: The Tight-Chain Decision Gate — Compile the One Argued Claim and Decide the Depth-`0` Schema [COMPLETED WITH EXCLUSIONS]

**NEW IN THIS REVISION, AND ENTERABLE NOW.** This phase replaces the external gate the predecessor
plan carried on an abandoned task. It is a DECISION GATE in the sense `plan-format.md`'s "Decision
gates and contingency branches" defines: its own verification measures a criterion that decides which
branch the rest of the plan takes.

**Goal**: Decide `CellLEZeroConstOfKappaEq` under `ParamsOk` by compiling, as a wired evidence probe,
the one claim the library's own README records as argued rather than compiled: **no finite
deletion-derivative of the tight (doubling) chain lifts.** The verdict is one of three branches, each
of which is a complete and reportable outcome.

**Why this is the residue, and why it decides the plan.** Four facts, each re-derived at this
revision's authoring:

1. The schema is REFUTED at a `(K4)` answering only the backward register window — the forty-seventh
   wired probe, `Probe836A.cellLEZeroConstOfKappaEqPre_refuted`, against the frozen `ParamsOkPre`.
   Under `ParamsOk`, whose `(K4)` answers both windows, it is neither proved nor refuted, and the same
   probe compiles that the two-depth predicate rejects the defeating clip
   (`not_paramsOkK4_two`) and dissolves that collision (`kappa_D_dissolves`).
2. The only candidate DEVICE for rebuilding the register type-respectingly across a tight pin — a
   type-respecting block SPANNING a region start — is refuted in both directions by compiled objects,
   and the pigeonhole route to it is refuted at the level of its arithmetic: `(K1)` does not constrain
   a spanning block's length, because both of its cycle-length conjuncts carry
   `∀ i, pend (f i) = true` on the closed walk they quantify while a spanning block's induced walk is
   idle at the pin strictly inside it.
3. What IS landed is the UPWARD cell inclusion on the pin-free side, and the DOWNWARD inclusion at the
   cell level on the WITNESSING PATH under a named path-level regime whose necessity is itself compiled
   (a climbing-register path that is a ladder path, pending forever into the past, satisfying the gap
   and violating the regime).
4. No STATE-level regime-restricted variant is claimable, for that same compiled reason, and no
   path-selected variant can feed Phase 11.6 (see that phase's gate note). So the gap between the
   landed inclusions and the schema is exactly the tight chain — slack `0` at every gap between pins,
   register `n = position` at every pin — and the claim that it does not lift.

**And deciding the schema decides this plan's own filed statements.** `CellLEZeroConstOfKappaEq` is the
instance `t := z` of `cellAt_const_of_kappa_eq`'s recorded signature with one additional hypothesis
(the closure carries no `⊡` letter), so the recorded statement IMPLIES the schema; and
`ladderRealized`'s right-hand side depends on `(c, n)` only through `kappa Tc Tn P B (c, n)`, so it
assigns `kappa`-colliding states the same cell and implies the schema too. A refutation of the schema
under `ParamsOk` therefore refutes BOTH filed statements outright. That implication is derived here, at
plan time, precisely so that no implement dispatch has to derive it mid-proof or guess what a
refutation licenses.

**The statement this phase commits to, in full.** Recorded here token-for-token so that a later
dispatch lands it without a Statement-Fidelity question, and deliberately NOT added to the
`## Lean Challenge Statements` block: that block's identifier set must equal the `- **Goals**:` set,
whose members are this task's six FILED theorems, and a probe declaration is not a filed Goal — the
forty-fifth, forty-sixth and forty-seventh wired probes set that precedent. The probe declares, in
namespace `Probe761T`, the tight doubling chain re-declared verbatim from the archived prototypes (a
standalone file under `specs/**` is not on the Lake library path, so it cannot be imported and must be
re-declared, exactly as the successor task's own two prototypes did), and then:

```lean
-- In namespace Probe761T, over the chain `tightChain` and the parameter outputs of the
-- periodicity fixpoint, with `chi` the separating stab-free closure formula:

theorem tightChain_deletion_derivative_not_ladderPath
    (m l : Nat) (hl : 0 < l) (hdvd : l ∣ Pof step pend lab chi + 1)
    (z : Int) (hz : Tcof step pend lab chi ≤ cntAt tightChain z) :
    ¬ IsLadderPath step pend (delIterWalk tightChain z m l) := sorry

theorem cellLEZeroConstOfKappaEq_refuted :
    ¬ CellLEZeroConstOfKappaEq step pend fwd bwd lab chi
        (Tcof step pend lab chi) (Tnof step pend lab chi)
        (Pof step pend lab chi) (Bof step pend lab chi) := sorry

theorem exists_refuting_tight_collision :
    ParamsOk step pend lab chi (Tcof step pend lab chi) (Tnof step pend lab chi)
        (Pof step pend lab chi) (Bof step pend lab chi)
      ∧ (∀ psi : PlusFormula, PlusFormula.stab psi ∉ plusSubformulaClosure chi)
      ∧ (∃ q c n c' n' : _, kappa (Tcof step pend lab chi) (Tnof step pend lab chi)
            (Pof step pend lab chi) (Bof step pend lab chi) (c, n)
          = kappa (Tcof step pend lab chi) (Tnof step pend lab chi)
            (Pof step pend lab chi) (Bof step pend lab chi) (c', n')
          ∧ c ≠ c' ∧ c ∈ Adm pend q ∧ c' ∈ Adm pend q)
      ∧ ¬ CellLEZeroConstOfKappaEq step pend fwd bwd lab chi
            (Tcof step pend lab chi) (Tnof step pend lab chi)
            (Pof step pend lab chi) (Bof step pend lab chi) := sorry
```

`delIterWalk` is this probe's own local definition of the iterated deletion-derivative walk (delete
`m` sampled type-respecting blocks of length `l` at the chain's own spacing), declared in the probe
beside the chain. The three statements are the probe's, not the library's: nothing in this phase lands
a declaration in `FormalSystem/`, and the reserved name `cellLE_zero_const_of_kappa_eq` is not claimed
on any branch. **If the attempt shows the chain's deletion-derivatives DO lift**, these three
statements are not weakened, narrowed or re-signed to match what was found: the phase takes branch
PASS or branch INCONCLUSIVE below and the positive content is reported, never landed under a negated
name.

**Tasks**:
- [x] Author the probe at `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean`.
      Re-declare the tight doubling chain and its register facts verbatim from the archived prototypes
      `specs/archive/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean`
      and `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/pin-free-side.lean`
      (`tightChain_isLadderPath`, `tightChain_pin`, `tightChain_slack_zero`, `tightChain_pins`,
      `tightChain_pin_count_ge`), and define `delIterWalk` beside them. Compile standalone through the
      build guard.
- [ ] Attempt `tightChain_deletion_derivative_not_ladderPath` at the statement recorded above, *(deviation: altered — the recorded statement is false at `m = 0` and its conclusion is register-specific; the claim is landed in its lifting form under its own names and the recorded block is left byte-identical, see `#### Reasoned Exclusions`)*
      token-for-token. The obstruction to localize is the one the successor chain already localized at
      the path level: feeding the deleted walk to the assembly leaves a register demand exceeding what
      `1`-Lipschitz pin compatibility supplies by exactly the amount deleted, and the chain has slack
      exactly `0` at every gap between pins. Record the goal state if it does not close.
- [x] **DECISION GATE.** Read the verdict and take exactly one branch: *(INCONCLUSIVE taken)*
      - **REFUTED** — `tightChain_deletion_derivative_not_ladderPath` closes AND
        `cellLEZeroConstOfKappaEq_refuted` and `exists_refuting_tight_collision` close with it. Wire
        the probe into `scripts/check-evidence-probes.sh` (table block and `WIRED` array entry) and
        record the verdict. Phases 11.6, 11.7, 12.2 and 13-18 then close
        `[COMPLETED WITH EXCLUSIONS]`, each with a `#### Reasoned Exclusions` record whose `Evidence`
        column cites this phase's compiled object, and the two filed statements
        `cellAt_const_of_kappa_eq` and `ladderRealized` are named REFUTED, with the remedy a further
        `/revise`.
      - **PASS** — the attempt instead yields a type-respecting lifting construction for the chain's
        deletion-derivatives. Land nothing under the reserved name in this phase; record the
        construction and its goal state, and report that Phase 11.6's gate can be lifted by a
        successor round that lands it in the module where the pump layer lives. This phase does not
        reach into that module (Non-Goals).
      - **INCONCLUSIVE** — neither closes. Record the goal state and the exact sub-claim that
        resisted; the probe is NOT wired on this branch, because the evidence gate holds compiled
        records in place and has nothing to hold. Phase 11.6 stays gated and the honest report is that
        the enterable work is Phases 11.2, 11.8 and 12.1.
- [x] Record the verdict in the durable carriers only: this phase's own body, the dispatch handoff,
      and the round summary. **Do not amend
      `FormalSystem/Metalogic/Decidability/RaySummary/README.md` in this phase** — its depth-`0`
      status paragraph is live territory of the successor chain, and Phase 18 is this plan's records
      pass. This is deliberate collision avoidance, not an omission.

**Prohibited workarounds**: do NOT claim the name `cellLE_zero_const_of_kappa_eq` on any branch; do NOT
weaken, narrow or re-sign the three recorded probe statements to match what the attempt found; do NOT
land a `sorry`, an axiom, a `native_decide` or a vacuous definition in the probe (a probe carrying one
is not evidence); do NOT edit any file under `FormalSystem/`, `Tests/` or `scripts/` other than
`scripts/check-evidence-probes.sh`, and that one only on the REFUTED branch; do NOT edit
`LadderPump.lean`, `LadderPin.lean` or `LadderChain.lean` on any branch; do NOT raise `Tc` or `Tn`, add
a parameter, add a fifth parameter source or further strengthen `ParamsOk` to reach either verdict; do
NOT cite `prodPre_periodic` or any certificate-side periodicity; do NOT enter route A; and do NOT wire
an INCONCLUSIVE attempt into the evidence gate.

**Timing**: NOT COSTABLE. This is the open core of the counter-lift mathematics, attacked at the one
object where it is sharpest; no estimate is offered and none is to be invented. The phase is
nevertheless genuinely CLOSABLE on all three branches, which is the point of writing it as a gate
rather than as an open-ended attempt.

**Depends on**: 11.5

**Verification Tier**: local

**Tier Justification**: The deliverable is one standalone probe file with no library consumer and no
import into `FormalSystem/`, plus at most one shell-table entry, so the cheapest covering check is the
guarded standalone compile of that one file
(`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean`)
together with `bash scripts/check-evidence-probes.sh` read for its exit status on the branch that
wires it.

**Scope Hypothesis**: One new probe file plus, on one branch only, one shell-table entry. The chain and
its register facts are re-declared rather than imported, so the file is expected to be large — the
successor chain's comparable prototype landed at 474 lines against a 120-220 estimate for exactly this
reason, which is the figure this hypothesis is calibrated against (source:
`specs/838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md`,
Phase 3 deviation). MEASURE the final line count at phase close rather than trusting any estimate from
here. No library declaration is added by this phase on any branch, so no axiom pin, no C14 entry, no
theorem-index row and no inventory block moves.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean` - the probe: the re-declared tight chain, `delIterWalk`, and the three recorded statements
- `scripts/check-evidence-probes.sh` - the probe's table block and `WIRED` array entry, on the REFUTED branch ONLY

**Verification**:
- The probe compiles standalone through the build guard with an explicit `--timeout`: exit 0, zero `error:`, and zero `declaration uses 'sorry'` on whichever of the three statements the taken branch claims to have landed. A statement left open is reported as open in the phase body, never committed with a `sorry` body.
- `#print axioms` on every headline theorem of the probe reports a subset of `[propext, Classical.choice, Quot.sound]`: no `sorryAx`, no custom axiom, no `native_decide`.
- **Non-vacuity is witnessed on both sides** on the REFUTED branch: `exists_refuting_tight_collision` carries `ParamsOk` discharged at the parameter outputs, the stab-free closure condition, a populated `kappa`-collision at `c ≠ c'` with both counters admissible, and the negation. A refutation without that conjunct is reported as vacuous, not as met.
- **The reserved name is unclaimed on every branch**: `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returns only prose lines, and the count does not fall below the seven prose lines measured at this plan's authoring (three in `LadderChain.lean`, two in `README.md`, two in `LadderAgree.lean`) in a way that indicates a docstring was weakened.
- **The recorded statements are intact**: a `diff` of the three extracted signature texts against this phase's own recorded block is empty, modulo whitespace. A branch that found something else reports it in prose and leaves the block alone.
- **No library file changed**: `git status --short FormalSystem/ Tests/` is empty at the phase's close, and `git diff --stat` names only the probe and, on the REFUTED branch, `scripts/check-evidence-probes.sh`.
- On the REFUTED branch, `bash scripts/check-evidence-probes.sh` exits 0 and its PASS line reports one more wired probe than the 47 measured at this plan's authoring (46 `WIRED` entries plus 1 `WIRED_REPO` entry, counted directly from the script). On the other two branches the probe is not wired and the gate's count is unchanged.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0` — unchanged from the baseline measured at this plan's authoring, as it must be, since this phase adds nothing to either root.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on the probe: its prose cites the archived prototypes and the live declarations by PATH and by NAME, never by task number, since `specs/evidence/**` is outside the `specs/**` task-artifact exemption's intent for deliverable prose.
- `bash scripts/check-module-invariants.sh` and `bash scripts/typst-sync-check.sh` each exit 0; neither should move, and a move is itself a finding to record.
- The verdict is recorded in this phase's body, the handoff and the summary, naming which of the three branches was taken and why, with the goal state recorded verbatim on the PASS and INCONCLUSIVE branches.

#### VERDICT: INCONCLUSIVE

Neither `cellLEZeroConstOfKappaEq_refuted` nor `exists_refuting_tight_collision` closes, so by the
branch definitions this is the INCONCLUSIVE branch: the probe is NOT wired into
`scripts/check-evidence-probes.sh` (which stays at its measured 47), `scripts/` is untouched,
Phase 11.6 stays gated, and the honest report is that the enterable work was Phases 11.2, 11.8 and
12.1. The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing, and the two filed
Challenge statements `cellAt_const_of_kappa_eq` and `ladderRealized` are NOT named REFUTED.

**What the branch nevertheless landed, and why it is more than an empty inconclusive.** The claim
the live README records as ARGUED rather than compiled is now COMPILED, in a form strictly stronger
than the recorded statement. `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean`
(480 lines, measured at close against a Scope Hypothesis calibrated at 474) declares, in namespace
`Probe761T`:

- the two-state object, and the tight doubling chain with its pins UNBOUNDED ABOVE — `idleT`,
  `wT`, `cT`, `pin_eq`, `no_idle_between`, `cT_pin_succ`, `cT_pend_pend`, `cT_pend_idle`,
  `tightChain_exists`, and `tightChain` itself with `tightChain_isLadderPath`,
  `tightChain_objAt`, `tightChain_cntAt`;
- `tightChain_pins` (a pin at every `2^j - 2`) and `tightChain_slack_zero` (the register equals
  the POSITION at every pin, so every gap between pins has Lipschitz slack exactly `0`);
- `delObj`/`delIterObj`, the deletion-derivative's object walk;
- **`tightChain_positive_deletion_does_not_lift`**: for every `a ≥ 4` and every `L > 0`, NO ladder
  path whatsoever has the chain's object walk with `[a, a + L)` deleted — the countdown and the
  register are both existentially quantified away;
- `tightChain_iter_deletion_does_not_lift` and
  `tightChain_deletion_derivative_does_not_lift`, the same claim at the iterated shape and at the
  gate's own hypothesis `Tcof … ≤ cntAt tightChain z` (which does place `z` where the claim needs
  it: `two_le_Tcof` and `three_le_of_two_le_cT` derive `3 ≤ z` from it);
- `paramsOk_chain` (the parameter conditions discharged at the fixpoint's own outputs for this
  object and formula) and `stabFree_chiT`.

`#print axioms` on every headline theorem reports `[propext, Classical.choice, Quot.sound]`: no
`sorryAx`, no custom axiom, no `native_decide`. The mechanism is the chain's own tightness read at
two pins of the DELETED walk on opposite sides of the deletion — the pin at `0`, whose region is
the single position `1` and lies entirely below the deletion, and a pin `2^j - 2 - L` whose region
lies entirely above it — whose distance has fallen by exactly `L` while their countdown difference
has not moved, against `pinCompat_of_ladderPath`'s necessity. No type, no parameter condition and
no certificate object enters the argument.

**The sub-claim that resisted, stated exactly.** Going from non-liftability of the chain's
deletion-derivatives to `¬ CellLEZeroConstOfKappaEq` needs the realized-type layer over the chain,
and the missing link is NOT an arithmetic one. A cell equality at a `kappa`-collision `(c, n)`
versus `(c', n')` with `c' < c` asks that every type realized at the first state be realized at the
second by SOME ladder path through it. Nothing makes that path a deletion-derivative of the chain:
the cell quantifies over every history through the state, so non-liftability of the derivatives
does not by itself exclude the equality. What is owed is a closure formula whose own letters FORCE
the realizing path to be a deletion-derivative of the chain — and the two compiled facts that bear
on the choice both cut against the obvious candidates: the schema is refuted at the frozen
`ParamsOkPre` whose `(K4)` reads the backward depth alone, while under `ParamsOk` the same probe's
`not_paramsOkK4_two` and `kappa_D_dissolves` show the two-depth predicate rejects that clip and
dissolves that collision. A formula at `atom`-level depth is no use either: the closure of
`chiT := atom p` has a single member, so its cell depends on the object state alone and the schema
holds for it. The owed object is therefore a deeper formula together with a surviving collision,
which is the open core itself.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `cellLEZeroConstOfKappaEq_refuted` at the recorded statement | Not attempted and not claimed. The step from the compiled non-liftability to a cell inequality needs a closure formula forcing the realizing path to be a deletion-derivative; see "The sub-claim that resisted" above. Nothing was weakened or re-signed to reach a verdict. | The recorded `## Lean Challenge Statements` block and this phase's own recorded statement block are byte-identical to their pre-dispatch text. `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returns the same seven prose lines measured at this plan's authoring. |
| `exists_refuting_tight_collision` at the recorded statement | Its fourth conjunct is the row above. Its other three conjuncts ARE available — `paramsOk_chain` discharges `ParamsOk` at the fixpoint outputs and `stabFree_chiT` the stab-free condition — but a conjunction whose last conjunct is unproved is not landed, and a probe carrying a `sorry` is not evidence. | `paramsOk_chain`, `stabFree_chiT` in the probe; `kappa_eq_of_shift` (`LadderAgree.lean`) is the landed source of a populated `kappa`-collision at `c ≠ c'` whenever both counters are at or above their thresholds. |
| The probe is NOT wired into `scripts/check-evidence-probes.sh` | The INCONCLUSIVE branch's own instruction, and `scripts/check-evidence-probes.sh` is listed under `Files to modify` for the REFUTED branch ONLY. The consequence is recorded rather than hidden: the 480-line probe is unprotected by the evidence gate and will rot silently, so the revision that repairs the recorded statements should wire it in the same round. | `bash scripts/check-evidence-probes.sh` exits 0 and still reports `all 47 wired probe(s) compile`, unchanged from the figure measured at this plan's authoring. `git status --short scripts/` is empty. |

**Three statement-level findings, reported and not worked around.**

1. **The recorded statement is false at `m = 0`.** It quantifies `(m l : Nat)` with `0 < l` and no
   constraint on `m`; at `m = 0` the deletion-derivative deletes nothing and IS the chain, which is
   a ladder path. It needs `0 < m`. The landed theorems carry `hm : 0 < m` and honest names of
   their own; the recorded block is left exactly as recorded.
2. **The recorded conclusion is register-specific, and the record's claim is not.**
   `¬ IsLadderPath step pend (delIterWalk …)` constrains the deleted walk's own register, so it is
   weaker than "the derivative does not LIFT". The landed form quantifies the countdown and the
   register away, which is the claim the README makes and the claim a consumer needs.
3. **The object must be the chain with pins unbounded above.** On the archived prototype's
   finite-`J` chain the LAST region is followed by the idle-forever tail and so carries no pin
   above it; deleting a block from it moves no later pin, the register demand at the last pin drops
   by the deleted amount while every earlier pin keeps its own, and the `1`-Lipschitz pin condition
   admits that. A finite-`J` chain therefore HAS a lifting deletion-derivative and the claim is
   false at that object. The probe declares the unbounded chain and says so in its own docstring;
   the archived finite-`J` prototype is unmodified and is not restated.

**Measured at close.** The probe compiles standalone through the build guard: exit 0, zero
`error:`, zero `declaration uses 'sorry'`. `#print axioms` on all eight headline theorems:
`[propext, Classical.choice, Quot.sound]`. `git status --short FormalSystem/ Tests/ scripts/` is
empty — no library file and no script changed by this phase, as the phase's own verification
requires — and `git status --short specs/evidence/` names the one new probe.
`bash scripts/check-evidence-probes.sh` exits 0 at 47 wired probes;
`bash .claude/scripts/check-task-references.sh --quiet` exits 0 on the probe, whose prose cites the
archived prototypes and the live declarations by path and by name and never by task number;
`bash scripts/typst-sync-check.sh` exits 0 and did not move. Full `lake build`: exit 0, 0 errors,
0 warnings, 2,895 jobs. `bash scripts/check-module-invariants.sh` still exits 1 on the same single
pre-existing `C16` finding in `LadderChain.lean` recorded by Phase 11.2, unchanged in content and
count; every other group passes.

---

---

### Phase 12.1: `Real` and Its Agreement-Free Conditions [COMPLETED WITH EXCLUSIONS]

**ENTERABLE NOW. SPLIT OUT BY THIS REVISION FROM THE PREDECESSOR PLAN'S PHASE 12; CONTENT UNCHANGED —
ONLY THE COMMIT BOUNDARY MOVES.** Phase 12 carried nine deliverables in one unit behind the agreement,
of which six need no agreement at all, so a dispatch arriving against a gated board could land every
one of them and close nothing. This phase takes those six; Phase 12.2 takes the three that consume
Phase 11.7. The recorded 2.5 hours split 1.5/1 and the plan's total does not move. No statement, no
candidate choice and no prohibition changes.

**Goal**: Define `Real`, the actual realizable subset of `Q × ClType φ × CK Tc Tn P B`, and prove
every certification condition of it that does not consume the agreement: `stab_bit_agree_of_certStabK`,
the four monotone conditions, and `certBoxK`. This is Finding 3's route to `Dmax`'s own certification
and candidate (2) of the four — the one the agreement makes reachable.

**Tasks**:
- [x] Define `Real step pend lab φ Tc Tn P B fwd bwd : Set (Q × ClType φ × CK Tc Tn P B)` as the set
      of `(q, T, κ)` for which some admissible ladder history `σ` and some `z` realize `T` at a state
      `⟨(q, c, n), h⟩` with `kappa Tc Tn P B (c, n) = κ`. Docstring: this is the set-valued per-state
      datum of presentation (a), and `Real` is not an index — `Dmax` is.
- [x] Land `stab_bit_agree_of_certStabK` here, verbatim from the phase-11 handoff: any
      `certStabK`-certified set collapses the `⊡` bits across a `(q, κ)`-class. It is a statement about
      certified sets, which is why it belongs in the certificate-side module and not in
      `LadderAgree.lean`.
- [ ] Prove the four monotone conditions of `Real` — `certLocK`, `certBiInfK`, `certFwdK`, `certBwdK` — *(deviation: altered — `certLocK` landed as `real_certLocK`; `certBiInfK`, `certFwdK` and `certBwdK` EXCLUDED, see `#### Reasoned Exclusions` below)*
      from the structure of an admissible ladder history: local coherence and the `untl`/`snce` links
      along an actual history, with the counter classes following `RK` by `Count`/`Drift`, and both
      fulfilment arms EXISTENTIAL.
- [x] Prove `certBoxK` of `Real`. This is the condition candidate (1) failed, and it is reachable for
      `Real` exactly because `box_mem_tpOf_iff`'s quantifier is GLOBAL.
- [x] **Do not state or prove `certStabK` of `Real`, `real_certAdmK_of_paramsOk` or `real_subset_dmax`
      here.** All three consume the agreement and are Phase 12.2's; the split exists so that this phase
      closes without them.
- [x] **Do not state or prove `Dmax ⊆ Real` in this phase or in 12.2.** The reverse inclusion is the
      lift's own content and is Phase 15's corollary.

**Prohibited workarounds**: do NOT shrink `Real` to one of candidates (1), (3) or (4) — each is already
refuted by a named condition; do NOT reach for a union argument (no theorem may claim `certStabK` or
`certBoxK` of a union of certified sets, and none may claim `certAdmK … (Dmax …)`); do NOT consume
`cellAt_const_of_kappa_eq` or the schema `CellLEZeroConstOfKappaEq` in any proof of this phase; do NOT
add `hp` to a recorded Challenge statement; and do NOT use `sorry`, `axiom` or a vacuous definition.

**Timing**: 1.5 hours — the agreement-free six of Phase 12's nine deliverables, taken as that phase's
recorded 2.5 hours apportioned by deliverable count and weighted toward the four condition lemmas,
which are the bulk. The split sums to the recorded figure and invents nothing.

**Depends on**: 10

**Verification Tier**: interface

**Tier Justification**: `Real` and its conditions are consumed by Phases 12.2, 13 and 15 across the
module interface and the declarations enter the axiom test, so the covering check is the guarded scoped
build of `LadderRealize.lean` plus `bash scripts/check-module-invariants.sh` and `#print axioms`.

**Scope Hypothesis**: One definition (`Real`), one ported lemma (`stab_bit_agree_of_certStabK`), four
monotone condition lemmas and one `certBoxK` lemma — seven declarations, all inside
`LadderRealize.lean` (132 lines at this plan's authoring, measured directly, so no length remedy is in
prospect); no new module and no wiring file beyond the axiom test. To be MEASURED at phase close. If a
monotone condition turns out to need the agreement after all, that is a finding about the condition and
is recorded as such — the deliverable moves to Phase 12.2 with the reason stated, and this phase closes
with a `#### Reasoned Exclusions` record rather than being held open.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - Real, stab_bit_agree_of_certStabK, the four monotone condition lemmas, certBoxK of Real
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom-profile entries for the new declarations
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the generated inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- Guarded scoped build of `LadderRealize.lean` and of the axiom test each exit 0 with 0 warnings, with an explicit `--timeout` and the bounded single-call idiom; `bash scripts/check-module-invariants.sh` exits 0.
- `#print axioms` on every new declaration: no `sorryAx`, no custom axiom, no `native_decide`.
- `stab_bit_agree_of_certStabK` is a proved theorem in this module, stated as the handoff quotes it.
- **No proof of this phase consumes the agreement or the schema**: `grep -n 'cellAt_const_of_kappa_eq\|CellLEZeroConstOfKappaEq\|cellLE_zero_const_of_kappa_eq' FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` returns nothing outside a docstring sentence naming them as Phase 12.2's input. This is the split's own acceptance criterion.
- No theorem in the module states `certStabK … (Real …)`, `real_certAdmK_of_paramsOk`, `real_subset_dmax`, `Dmax … ⊆ Real …` or any equality `Dmax … = Real …` (grep): the first three are Phase 12.2's, the last two Phase 15's.
- No union argument appears: no theorem claims `certStabK` or `certBoxK` of a union of certified sets, and none claims `certAdmK … (Dmax …)` (grep).
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; module-scoped vacuous grep over `LadderRealize.lean` count 0; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.
- `bash scripts/typst-sync-check.sh`, `bash scripts/readme-lint.sh` and `bash .claude/scripts/check-task-references.sh --quiet` each exit 0.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `certBiInfK` of `Real` (condition (2)) | Quantifies `relK`, whose counter conjunct is `RK Tc Tn P B (pend x.1) (pend y.1) x.2.2 y.2.2`. No theorem of this library derives an `RK` edge from an actual `Count`/`Drift` step at arbitrary counters, so a successor-and-predecessor claim inside `Real` cannot be stated, let alone proved, from a ladder history alone. | `grep -rn "RK Tc" FormalSystem/ --include=*.lean` returns three lines, all in `CounterQuotient.lean`: the `Decidable` instance, `rk_iff`'s own statement, and `relK`'s definition. `CounterQuotient.lean`'s `R_K` section docstring: "NOTHING below says the image is faithful — that every counter step of a ladder history is an `R_K` edge at the two classes — and nothing assumes it: that is the gated counter-lift lemma's own content (obligations (2) and (3))". |
| `certFwdK` of `Real` (condition (3)) | Its `DischPathK` quantifies `relK (f i) (f (i + 1))` at every position of the discharge path, so it inherits the same missing step. The temporal content itself is available — `untl_mem_tpOf_iff` (`LadderAgree.lean`) gives the fulfilling position and the guard along the intervening stretch of the SAME history — and the discharge path would be the contiguous stretch `z, z+1, …, z+m` of that history, every position of which lies in `Real` by `mem_real_realItem`. The one missing link is the relation between consecutive positions. | Same as the row above, plus `DischPathK`'s own definition in `CounterQuotient.lean`, whose fourth conjunct is `∀ i < m, rel (f i) (f (i + 1)) ∧ f (i + 1) ∈ R`. |
| `certBwdK` of `Real` (condition (4)) | The past-directed mirror of the row above, along the reversed `relK`; `snce_mem_tpOf_iff` supplies the temporal content and the same relation link is missing. | Same as the two rows above. |

**What the three exclusions need, stated so a successor does not re-derive it.** One lemma, and
its statement is:

```lean
theorem rk_of_count_drift (Tc Tn P B : ℕ) (px py : Bool) (c n c' n' : ℕ)
    (hc : Count px py c n c') (hd : Drift n n') :
    RK Tc Tn P B px py (kappa Tc Tn P B (c, n)) (kappa Tc Tn P B (c', n'))
```

By `rk_iff` this asks for `x, y ∈ repsCnt Tc Tn P B` with `kappa x = kappa (c, n)`,
`kappa y = kappa (c', n')`, `Count px py x.1 x.2 y.1` and `Drift x.2 y.2`. Three findings about
it, each derived at this phase's close rather than guessed:

1. **It is not a reduction coordinate by coordinate.** `kappa`'s fifth coordinate
   `clipIdx B c n` COUPLES the two counters, so reducing each counter independently inside its own
   threshold and residue class can move the gap. At `c = 100`, `n = 101`, `B = 3`, `Tc = Tn = 1`,
   `P = 0` the independent reduction sends both coordinates to `3` and the gap from `1` to `0`,
   which is a different class.
2. **A COMMON downward shift by a multiple of `P + 1` does preserve all five coordinates** — that
   is `kappa_eq_of_shift` (`LadderAgree.lean`) read downward, since a common shift leaves the gap
   alone — but it is bounded by whichever counter reaches its own threshold first, so it does not
   by itself bring a pair with a large gap into range. The construction therefore needs the
   saturated-gap regime (`|n - c| ≥ B`, where the two coordinates decouple because the clip is
   pinned at `0` or `2B`) as a second case, and the `py = false` arm of `Count` as a third, where
   `c' = 0` is forced and cannot be shifted at all.
3. **Whether `repsCnt`'s own bound `Tc + Tn + P + B + 2` suffices for that construction is
   itself open**, and nothing in this phase assumes it. If it does not, `rk_of_count_drift` is
   false as stated and the bound is the defect — which would be a finding about
   `CounterQuotient.lean`, not about `Real`.

This is the Scope Hypothesis's own contingency fired: a condition turned out to need more than
the phase expected, the deliverable is recorded as such with the reason stated, and the phase is
closed rather than held open. The three conditions do NOT belong in Phase 12.2 as that phase is
written — 12.2's input is Phase 11.7's agreement, which is a different missing ingredient — so
they are recorded here as owed to whichever round lands `rk_of_count_drift`, and a `/revise` is
the route that re-homes them.

**RE-HOMED BY THIS REVISION, and the third finding above SETTLED.** This record stands as written;
this line is a forward pointer, not a rewrite. Finding 3 above — "whether `repsCnt`'s own bound
`Tc + Tn + P + B + 2` suffices for that construction is itself open" — is now settled NEGATIVELY
and by compiled witnesses: it does not suffice, `rk_of_count_drift` is false as stated at that
bound, and the defect is the bound (see this plan's findings 16-19 and
`reports/08_rk-bounded-representative-refutation.md`). The repair is a definitional widening, landed
by **Phase 12.3**; the three conditions this record excludes are landed by **Phase 12.5**; and the
three witnesses are landed as a wired probe against the frozen pre-widening bound by **Phase 12.4**.
The route this record named — "owed to whichever round lands `rk_of_count_drift`, and a `/revise` is
the route that re-homes them" — is the route that was taken.

**CLOSURE RECORD (measured, not estimated).** Landed in `LadderRealize.lean`:
`stab_bit_agree_of_certStabK` (verbatim from the phase-11 handoff, which had it compiling
standalone), `realItem` (def), `Real` (def), `mem_real_iff`, `mem_real_realItem`,
`mem_clType_iff_truth`, `real_certLocK` and `real_certBoxK` — six theorems and two definitions.
The module measures 363 lines against the Scope Hypothesis's 132 at this plan's authoring, so no
length remedy was needed for it; `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` crossed
its own in-source baseline and had it raised in place from `1900` to `2000` (the same
pre-authorized primary remedy the 11-series phases use, on a file this phase's
`Files to modify` already lists).

- **`Real`'s time coordinate is quantified, not pinned.** "Some history and some `z` realize `T`
  at a state `⟨(q, c, n), h⟩`" names the LADDER state; the `ℤ` component of the world state is
  invisible to `cellAt` (`cellAt_eq_cellAt`), and quantifying it is what makes `Real` closed
  under the model's own re-anchoring, which `real_certBoxK`'s right-to-left direction reads
  through `mem_real_realItem`. No new import was needed: `CounterQuotient` already pulls in
  `Certificate` → `AnchorLayer` and `LadderModel`.
- **Measured at close.** Scoped build of `LadderRealize` and of
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest`: exit 0, 0 errors, 0 warnings each. Full
  `lake build`: exit 0, 0 errors, 0 warnings, 2,895 jobs; `.olean` newer than source for both
  touched modules. `#print axioms` on all six new theorems: `[propext, Classical.choice,
  Quot.sound]`; no `sorryAx`, no custom axiom, no `native_decide`.
  `lean-sorry-census.sh FormalSystem Tests`: exit 0, `sorry_count: 0`. Module-scoped vacuous
  grep over `LadderRealize.lean`: 0. Repository-wide vacuous grep: 1, unchanged; `^axiom ` 10 in
  `FormalSystem/` and 2 in `Tests/`, both unchanged. `cellAt_const_of_kappa_eq`,
  `CellLEZeroConstOfKappaEq` and `cellLE_zero_const_of_kappa_eq` appear in `LadderRealize.lean`
  only in two module-docstring lines naming them as the input of the conditions this module does
  NOT carry — the split's own acceptance criterion. No theorem states `certStabK … (Real …)`,
  `real_certAdmK_of_paramsOk`, `real_subset_dmax`, `Dmax … ⊆ Real …` or `Dmax … = Real …`; no
  union argument appears and no theorem claims `certAdmK … (Dmax …)`. `typst-sync-check.sh`,
  `readme-lint.sh` and `check-task-references.sh --quiet` each exit 0, and
  `check-module-invariants.sh`'s `INV` inventory group passes after regeneration.
- **One criterion NOT met, for the same pre-existing reason Phase 11.2 recorded.**
  `check-module-invariants.sh` still exits 1 on `FAIL C16` — the single `unusedArguments` finding
  on `mem_cellAt_of_shift_of_hasForwardSlack` (`LadderChain.lean:2136`), unchanged in content and
  count from this dispatch's starting commit, in a module this plan forbids editing. Every other
  group passes, `C23`'s shadowing check included (the new `Real` is namespace-scoped and does not
  trip it).
- **Inventory regeneration again rewrote all three READMEs**, two of which this phase's
  `Files to modify` does not list, for the same generated-line-count reason Phase 11.2 recorded;
  committed with the phase as a declared `file_scope` excursion.

---

---

### Phase 12.2: `Real`'s Certification Under the Parameter Conditions, and `Real ⊆ Dmax` [NOT STARTED]

**GATED THROUGH PHASE 11.7, AND SO THROUGH PHASE 11.9.** Split out by the predecessor revision from
its Phase 12 as the agreement-consuming half; content unchanged by this revision except that its
`Depends on` gains `12.5`, which lands three of the five conditions its assembly reads, and its Goal
and assembly task now name where each of the six comes from.

**Goal**: Prove `certStabK` of `Real` from Phase 11.7's agreement — the ONE condition of the six
that consumes the agreement, the other five being landed by Phases 12.1 and 12.5 — assemble all six
as `real_certAdmK_of_paramsOk`, and conclude `real_subset_dmax` by `dmax_maximal`.

**Tasks**:
- [ ] **Prove `certStabK` of `Real` from Phase 11.7's agreement.** Both directions reduce, by
      `stab_mem_tpOf_iff_cell`, to the cells of class-equivalent states agreeing — which is
      `cellAt_const_of_kappa_eq`, available as a theorem rather than as an obligation.
- [ ] Assemble the six conditions — `real_certLocK` and `real_certBoxK` from Phase 12.1,
      `real_certBiInfK`, `real_certFwdK` and `real_certBwdK` from Phase 12.5, and this phase's own
      `certStabK` — as `real_certAdmK_of_paramsOk : ParamsOk step pend lab φ Tc Tn P B →
      certAdmK step pend lab φ Tc Tn P B (Real …)`. The parameter hypothesis enters here and only here
      on the certificate side, through the agreement.
- [ ] Conclude `real_subset_dmax : Real … ⊆ Dmax …` by `dmax_maximal` applied to
      `real_certAdmK_of_paramsOk`, so the inclusion is likewise stated under `hp`.
- [ ] **Do not state or prove `Dmax ⊆ Real`.** That is Phase 15's corollary of `ladderLift` plus the
      landed `dmax_certBiInfK`; attempting it here pulls (C') forward and re-closes a loop.

**Prohibited workarounds**: do NOT re-derive the agreement inside this phase; do NOT confine `Real` to
one state's cell (`certBiInfK` forbids it); do NOT reach for a union argument; do NOT shrink `Real` to
a refuted candidate; and do NOT use `sorry`, `axiom` or a vacuous definition.

**Timing**: 1 hour — the remaining three of Phase 12's nine deliverables under its recorded 2.5 hours,
with 1.5 apportioned to Phase 12.1. The split sums to the recorded figure.

**Depends on**: 12.1, 11.7, 12.5

**Verification Tier**: interface

**Tier Justification**: `real_certAdmK_of_paramsOk` and `real_subset_dmax` are consumed by Phases 13
and 15 across the module interface and enter the axiom test, so the covering check is the guarded
scoped build of `LadderRealize.lean` plus `bash scripts/check-module-invariants.sh` and
`#print axioms`.

**Scope Hypothesis**: One condition lemma (`certStabK` of `Real`), one assembly and one inclusion —
three declarations inside `LadderRealize.lean`, to be MEASURED at phase close. If `certStabK` of `Real`
does not close even with the agreement in hand, that is a finding about the agreement's strength, not a
reason to shrink `Real`: mark the phase `[BLOCKED]` and record which direction of the biconditional
failed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - certStabK of Real, real_certAdmK_of_paramsOk, real_subset_dmax
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom-profile entries for the new declarations
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- Guarded scoped build exits 0 with 0 warnings; `bash scripts/check-module-invariants.sh` exits 0.
- `real_certAdmK_of_paramsOk` is a proved theorem; `#print axioms` on it and on `real_subset_dmax` shows no `sorryAx`, no custom axiom, no `native_decide`.
- The `certStabK` proof CITES `cellAt_const_of_kappa_eq` (grep the proof body); it does not re-derive the agreement, and it does not confine `Real` to one state's cell.
- No theorem in the module states `Dmax … ⊆ Real …` or any equality `Dmax … = Real …` (grep): that inclusion is Phase 15's.
- No union argument appears (grep), and no theorem claims `certAdmK … (Dmax …)`.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; module-scoped vacuous grep count 0; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.
- If Phase 11.9's verdict was REFUTED, this phase closes `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record whose `Evidence` column cites that phase's compiled object, and its three deliverables are not attempted.

---

### Phase 12.3: Widen `repsCnt` and Land `rk_of_count_drift` [COMPLETED]

**NEW IN THIS REVISION, ENTERABLE NOW, AND GATED ON NOTHING OPEN.** It repairs the one defect the
new research input compiled — `repsCnt`'s bound, not the lemma (findings 16-19) — and it is the
only phase of this plan that edits `CounterQuotient.lean`.

**Goal**: Replace `repsCnt`'s `Finset.range (Tc + Tn + P + B + 2)` by
`Finset.range (Tc + Tn + 3*P + 2*B + 5)`, re-close the four declarations stated over it in the same
module, and land `rk_of_count_drift` — WITHOUT `ParamsOk` and without any other added hypothesis —
by the parameter-generic construction the new report's Appendix A records. Retire
`LadderRealize.lean`'s docstring sentence that calls the sufficiency of the old bound open.

**The statement this phase commits to, in full.** Recorded here token-for-token so a later dispatch
lands it without a Statement-Fidelity question, and deliberately NOT added to the
`## Lean Challenge Statements` block: that block's identifier set must equal the `- **Goals**:`
set, whose members are this task's six FILED theorems, and `rk_of_count_drift` is a library lemma
rather than a filed Goal — exactly as Phases 11.2 and 11.8's own deliverables are not.

```lean
-- In `CounterQuotient.lean`, beside `rk_iff`:

theorem rk_of_count_drift (Tc Tn P B : ℕ) (px py : Bool) (c n c' n' : ℕ)
    (hc : Count px py c n c') (hd : Drift n n') :
    RK Tc Tn P B px py (kappa Tc Tn P B (c, n)) (kappa Tc Tn P B (c', n')) := sorry
```

**Tasks**:
- [x] Widen `repsCnt` to *(completed)*
      `(Finset.range (Tc + Tn + 3*P + 2*B + 5)) ×ˢ (Finset.range (Tc + Tn + 3*P + 2*B + 5))`, and
      record in its docstring the COMPILED reason the old bound was replaced, in both of the two
      directions finding 17 names (the saturated-gap direction at `P = 0` and the residue-coupling
      direction), citing the probe Phase 12.4 lands by PATH and by declaration name. The docstring
      keeps its existing "a COUNT of candidate pairs, bounded by the parameters themselves, not a
      bound on anything" sentence: the widening does not change what kind of object this is.
- [x] Re-close the four declarations stated over `repsCnt` in the same module — `rkStepB`, `RKb`, *(completed: no proof mentions the numeral; all four re-closed unchanged)*
      `rk_iff` and `rkStepB_iff`, with `decidableRK` and `RK` beside them. **None of their proofs
      should mention the numeral**: they are stated over `repsCnt` abstractly and `rk_iff`'s proof
      unfolds `RK`/`RKb` rather than computing. If any proof does turn out to depend on the bound
      numerically, that is a finding about that proof and is recorded as such, not patched by
      tuning the bound.
- [x] Prove `rk_of_count_drift` by the recorded construction, in its three stages, converting to *(deviation: altered — `kappa_eq_components`, `eq_or_both_ge_of_min_eq`, `kappa_eq_of_shift` and `clipIdx_regime_of_eq` are all declared in `LadderAgree.lean`, which IMPORTS `CounterQuotient.lean`, so none is citable from this phase's own target module; the needed content is landed locally under honest names — `kappa_eq_of_components` (constructor direction), `clipIdx_sub_sub`, `clipIdx_of_add_le`, `clipIdx_of_le_sub`, `mod_sub_cancel`, `add_mod_mod_cancel`, `mem_repsCnt`, `exists_nShift`, `exists_aRep` — under the phase's own escape clause; `clipIdx_lt` is cited as landed. The two destructors were not needed at all: the proof must PROVE class equalities, not read them)*
      `RK` through `rk_iff` at the end. Write `L = P + 1` and `T* = max Tn (Tc + L + B)`:
      - the `n`-side, ONE common downward shift: with `m = min n n'`, take `s = 0` if `m ≤ T*` and
        `s = (m - T*) / L` otherwise, and set `b = n - s*L`, `b' = n' - s*L`. Residues mod `L` are
        preserved, `b' - b = n' - n` is preserved so `Drift b b'` survives, and either `s = 0` or
        `min b b' ≥ T*`, which saturates `min · Tn` and `min · B` alike;
      - the `a`-side, THREE sub-cases on the gap coordinate: `|n - c| < B` (clip exact, so shift
        `c` by the same `s`), `n - c ≥ B` (take `a` least `≥ Tc + 1` congruent to `c` mod `L`), and
        `c - n ≥ B` (take `a` least `≥ max (Tc + 1) (b + B)` congruent to `c` mod `L` — the
        sub-case that drives the bound and the one all three witnesses live in or next to);
      - the `a'`-side, by the `Count` case: `py = false` forces `a' = 0`; `py = true, px = true`
        gives `a' = a - 1`, which is why the `a` choices target `Tc + 1` rather than `Tc`;
        `py = true, px = false` gives `a' = b`.
      The landed lemmas to CITE rather than re-derive: `kappa_eq_components` and
      `eq_or_both_ge_of_min_eq` to read a class equality coordinate by coordinate,
      `kappa_eq_of_shift` instantiated at the REDUCED pair (the down-shift form), and `clipIdx_lt`
      and `clipIdx_regime_of_eq` for the gap sub-cases. No new helper about `clipIdx` beyond
      `clipIdx_lt` is needed; if one turns out to be, land it under its own honest name here.
- [x] Record the `ParamsOk` decision in `rk_of_count_drift`'s own docstring, with finding 18's *(completed)*
      reason stated (`(K1)` is a divisibility condition into `P + 1`; `(K2)` and `(K3)` never
      mention `P`; so `ParamsOk` bounds `P` from below only and the refutation's direction stays
      open to it), so a later round does not re-propose adding it.
- [x] Retire `LadderRealize.lean`'s open-sub-question sentence *(deviation: altered — the same sentence's own paragraph also asserted "no theorem of this library derives an `RK` edge from an actual `Count`/`Drift` step at arbitrary counters", which this phase makes false; that clause is corrected in the same pass rather than left standing for Phase 12.5, which still owns the "NOT landed" framing of conditions (2)-(4). The independent-reduction counterexample sentence is kept verbatim)* (`:47`, "Whether `repsCnt`'s own
      bound `Tc + Tn + P + B + 2` suffices for that construction is itself open and is not assumed
      anywhere here") and put the compiled answer in its place, naming the widened bound and the
      lemma. **Keep** the docstring's independent-reduction counterexample sentence
      (`c = 100`, `n = 101`, `B = 3`, `Tc = Tn = 1`, `P = 0`): it is about a different mechanism and
      is still correct.
- [x] Wire the new declaration (axiom pin, generated inventory blocks, `status.typ`) *(deviation: altered — `check-module-invariants.sh --emit-inventory` rewrote three generated blocks, not one: the RaySummary README plus `FormalSystem/Metalogic/README.md` and the repository `README.md`, because the line-count change propagates up the inventory chain and a stale block fails the INV check)*. No C14 entry
      and no `docs/theorem-index.md` row: this phase lands no filed Goal.

**Prohibited workarounds**: do NOT add `ParamsOk`, a size hypothesis, a regime hypothesis or any
other binder to `rk_of_count_drift` — finding 18 is why, and Statement Fidelity routes a
hypothesis-bearing substitute to `/revise`, not to an implementer; do NOT prove it by `decide` or
by enumeration at concrete parameters (`decide` over `RK` is `M^4`-shaped in the bound `M`, so a
general proof by enumeration does not exist and a concrete one proves nothing general); do NOT tune
the bound empirically until a probe passes — if the construction's case analysis does not close,
the phase is `[BLOCKED]` with the goal state recorded and the stalling sub-case named; do NOT adopt
the tighter `Tc + Tn + 2*P + 2*B + 3` because the sweep passes it (finding 19: no construction on
record closes it); do NOT edit `ParamsOk`, `paramsOkK1`-`paramsOkK4`, `Tcof`, `Tnof`, `Pof`, `Bof`,
`paramsOk_params` or `not_paramsOk_allZero`; do NOT add a fifth parameter source; do NOT narrow
`repsCnt` to a non-square or otherwise re-shaped set; do NOT edit `LadderPump.lean`,
`LadderPin.lean` or `LadderChain.lean`; do NOT consume the agreement or the schema
`CellLEZeroConstOfKappaEq` anywhere in this phase; and do NOT use `sorry`, `axiom`,
`native_decide` or a vacuous definition.

**Timing**: 2.5 hours — a one-line definitional change plus one construction whose three stages and
whose cited lemmas are all named above, against a module of 758 lines this plan has not previously
edited.

**Depends on**: 12.1

**Verification Tier**: interface

**Tier Justification**: The widening changes `repsCnt`/`RK`/`relK` in `CounterQuotient.lean`, whose
direct dependents are the enumerated four — `RaySummary.lean`, `LadderRealize.lean`,
`LadderAgree.lean` and `LadderChain.lean` (finding 20) — so the covering check is the guarded scoped
build of the changed module plus those four and the axiom test:
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient`
and the same for `...RaySummary.LadderAgree`, `...RaySummary.LadderRealize`,
`...RaySummary.LadderChain` and `BimodalTest.Metalogic.KTypeSummaryAxiomTest`.

**Scope Hypothesis**: One definitional edit, one new theorem and at most whatever helper the gap
sub-cases need, all in `CounterQuotient.lean` (**758 lines** at this revision's authoring, measured
directly, with no in-source `longFile` baseline and well under the package-wide 1500, so no length
remedy is in prospect), plus one docstring edit in `LadderRealize.lean` (**371 lines**) and three
wiring files. To be MEASURED at phase close rather than trusted from here. The carried figures and
their source: the recommended bound `Tc + Tn + 3*P + 2*B + 5` and the construction's analytic bound
`Tc + Tn + 3P + 2B + 4` come from `reports/08_rk-bounded-representative-refutation.md`'s Appendix A
and Decision D4 and are NOT re-derived by this planning round; confirm at implementation time that
the construction's largest coordinate really is bounded by the recorded figure, and if it is not,
record the discrepancy rather than widening further by guess.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` - the widened `repsCnt`, its docstring's compiled reason, `rk_of_count_drift` and its `ParamsOk` decision docstring
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - the module docstring's retired open-sub-question sentence, replaced by the compiled answer
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom-profile entry for `rk_of_count_drift`
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the generated inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- The guarded scoped builds of `CounterQuotient`, `LadderAgree`, `LadderRealize`, `LadderChain` and the axiom test each exit 0 with 0 warnings, with an explicit `--timeout` and the bounded single-call idiom; the unscoped guarded build exits 0 at the end of the phase.
- `rk_of_count_drift` matches the statement recorded in this phase's body token-for-token, by direct `diff` of the extracted signature text. In particular it carries NO `ParamsOk` binder and no size or regime hypothesis.
- `lean_minimal_hypotheses` (or an equivalent check) on `rk_of_count_drift` reports `hc` and `hd` load-bearing and reports no redundant binder. A proof that closes without consuming one of them is a finding to record, not a pass.
- `repsCnt`'s new bound is exactly `Tc + Tn + 3*P + 2*B + 5` in both factors (read the definition), and `repsCnt` is still a square product of two `Finset.range`s.
- **The parameter layer is UNMODIFIED**: `git diff FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` over this phase's commits shows no change to `ParamsOk`, `paramsOkK1`-`paramsOkK4`, `Tcof`, `Tnof`, `Pof`, `Bof`, `paramsOk_params` or `not_paramsOk_allZero`, and no fifth parameter source exists anywhere. This is the item that distinguishes a permitted definitional widening from a prohibited strengthening.
- **No landed theorem decides `RK` at a concrete parameter tuple**: `grep -rnE 'decide|native_decide' FormalSystem/Metalogic/Decidability/RaySummary/*.lean` returns no occurrence inside a proof of a statement mentioning `RK` or `relK`. If one exists, its elaboration cost under the widened bound is a finding to record at this phase rather than discovered by a later full build.
- `#print axioms rk_of_count_drift` shows no `sorryAx`, no custom axiom and no `native_decide`, and the same holds for `rk_iff`, `rkStepB_iff`, `RKb` and `decidableRK` after the re-close.
- `LadderRealize.lean`'s docstring no longer calls the bound's sufficiency open: `grep -n 'is itself open' FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` returns nothing about `repsCnt`, while the independent-reduction counterexample sentence is still present (grep for `c = 100`).
- The certificate-freedom grep (the Phase 11.3 extended form) over `LadderAgree.lean` still returns nothing and that module's import list is unchanged at `AnchorLayer` and `CounterQuotient`.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; module-scoped vacuous grep over `CounterQuotient.lean` count 0; the repository-wide vacuous grep unchanged from its 1-hit baseline and the `^axiom ` counts unchanged from their 10/2 baselines.
- `bash scripts/typst-sync-check.sh`, `bash scripts/readme-lint.sh`, `bash scripts/check-evidence-probes.sh` and `bash .claude/scripts/check-task-references.sh --quiet` each exit 0. `bash scripts/check-module-invariants.sh` passes every group except the single pre-existing `C16` finding of finding 26, which is unchanged in content and count; a move in that finding is itself a datum to record.
- If the phase closes `[BLOCKED]`: the goal state is recorded with the stalling sub-case named (which of the three `a`-side cases, or which `Count` arm), the widening is either committed on its own with the lemma named as open or reverted as a unit — never left half-applied — and no hypothesis was added to the recorded statement to reach a close.

---

### Phase 12.4: The Frozen-Bound Refutation Witnesses, and the Evidence Gate's Two Owed Wirings [COMPLETED]

**NEW IN THIS REVISION.** Two deliverables under one commit boundary, because both are edits to
`scripts/check-evidence-probes.sh` and splitting them would have two phases contend for the same
file: the compiled reason Phase 12.3's bound changed, and the wiring of the probe Phase 11.9 landed
and left unprotected (finding 23).

**Goal**: Land the three `decide`-checked refutation witnesses as a wired evidence probe against the
FROZEN pre-widening bound, with their positive counterparts at the widened library `RK`; and wire
Phase 11.9's already-landed `ladder-tight-chain-nonliftability.lean` into the same gate, recording
in this phase's body the three statement-level repairs that phase's close reported.

**Why the bound must be frozen inside the probe.** Once Phase 12.3 lands, `RK` at the three
witness tuples is TRUE, so `¬ RK` against the library's own `RK` no longer compiles — the
refutation would silently become unstatable and the compiled reason for the widening would be lost.
The probe therefore declares the pre-widening bound as its own local `repsCntPre` and the three
derived Booleans `rkStepBPre`/`RKbPre`/`RKPre` over it, refutes against those, and separately
compiles the POSITIVE statement at the library's widened `RK` for the same three tuples. This is
the pattern the forty-seventh wired probe already uses against the frozen `ParamsOkPre`
(`specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean`), not a new
device.

**Tasks**:
- [x] Author `specs/evidence/seam-gluing-ray-product/ladder-reps-bound-refutation.lean` *(deviation: altered — the namespace is `Probe761W`, not `Probe761R`: that name is already taken by `ladder-unconstrained-parameter-refutation.lean`, the fourteenth wired probe, which `CounterQuotient.lean`'s own module docstring names as `Probe761R`. All three witnesses, their steps and the recorded `set_option` values are as filed)* in namespace
      `Probe761R`: `repsCntPre` at the pre-widening `Tc + Tn + P + B + 2`, the three derived
      Booleans over it, and the three witnesses — A at `(1,2,2,2)` with `Count false false 9 5 0`
      and `Drift 5 4`; B at `(4,6,5,2)` with `Count true true 20 11 19` and `Drift 11 12`; C at
      `(0,0,0,3)` with `Count false false 5 2 0` and `Drift 2 3` — each carrying its `Count` and
      `Drift` step by `decide` and its `¬ RKPre` by `decide`. Use the `set_option` values the
      report records (A: `maxRecDepth 100000`; B: `maxRecDepth 4000000` and
      `maxHeartbeats 4000000`; C: `maxRecDepth 400000`), and say in the probe's docstring that
      `decide` over this predicate is `M^4`-shaped in the bound `M`, so the heartbeat ceiling is
      the practical limit on how large a tuple any probe may name.
- [x] **Name witness C explicitly as the `P = 0` half** *(completed: its own section docstring says so in those words and spells out that at `P = 0` the modulus is `1`, so both residue coordinates are trivial and both clipped coordinates are pinned at `0`, leaving the gap as the only obstruction; witness A's worked mechanism, least admissible first coordinate `9`, is in its own docstring too)* in its own docstring, so a later reader
      cannot conclude the defect was only about residues. Witness A's worked mechanism — the least
      admissible first coordinate is `9`, exactly one above the old bound `Tc + Tn + P + B + 2 = 9`
      — belongs in the docstring too.
- [x] Compile the POSITIVE counterpart for each of the three tuples at the library's widened `RK`, *(completed: `witnessA_RK`, `witnessB_RK`, `witnessC_RK`, each ONE application of `rk_of_count_drift` and no `decide`; `both_sides_A`/`both_sides_B`/`both_sides_C` carry the two sides as conjuncts per tuple)*
      **by applying Phase 12.3's `rk_of_count_drift` to the same `Count`/`Drift` steps, never by
      `decide`**: at tuple B the widened bound is 34, so a `decide` there is `34^4`-shaped and
      infeasible, while the lemma discharges it in one application. These three are the probe's
      non-vacuity on the positive side and are also the first use site of the new lemma.
- [x] Wire BOTH probes into `scripts/check-evidence-probes.sh` *(completed: table block and `WIRED` entry for each, in the same commit as the probe file; the gate reports PASS at 49 wired probes, the authoring baseline of 47 plus these two)* — this new one and
      `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean` — adding a
      table block and a `WIRED` array entry for each, in the SAME commit as the probe file.
- [x] Record, in this phase's body, the repaired form of Phase 11.9's three recorded statements *(completed, and recorded HERE rather than as new prose because this agent's plan-file write authority covers phase headings and checklist items only. The correspondence: (i) `0 < m` on the deletion count is carried by `tightChain_iter_deletion_does_not_lift` and `tightChain_deletion_derivative_does_not_lift` — at `m = 0` the derivative IS the chain and is a ladder path; (ii) the LIFTING form, with the countdown and the register existentially quantified away rather than the register-specific `¬ IsLadderPath (delIterWalk …)`, is carried by all three headlines, `tightChain_positive_deletion_does_not_lift` included; (iii) the chain with pins UNBOUNDED ABOVE is the probe's declared object — on a finite-`J` chain the last region carries no pin above it and the chain HAS a lifting deletion-derivative. Phase 11.9's own body and its `#### Reasoned Exclusions` record are untouched)*, so
      a later reader does not take that phase's recorded block as the live statement. Phase 11.9's
      own body stays byte-identical; the repairs are (i) `0 < m` on the deletion count, since at
      `m = 0` the derivative IS the chain and is a ladder path; (ii) the LIFTING form, with the
      countdown and the register existentially quantified away rather than the register-specific
      `¬ IsLadderPath (delIterWalk …)`; and (iii) the chain with pins UNBOUNDED ABOVE, since on a
      finite-`J` chain the last region is followed by the idle-forever tail, carries no pin above
      it, and admits a lifting deletion-derivative. The landed probe's own headline theorems
      already carry all three under honest names
      (`tightChain_positive_deletion_does_not_lift`, `tightChain_iter_deletion_does_not_lift`,
      `tightChain_deletion_derivative_does_not_lift`); this task records that correspondence, it
      does not restate or re-sign them.
- [x] **No library file is edited by this phase** *(completed: `git status --short FormalSystem/ Tests/` empty at close; the only non-probe file touched is `scripts/check-evidence-probes.sh`. The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing)*, and no declaration is added under any reserved
      name.

**Prohibited workarounds**: do NOT state the refutation against the library's own `RK` after the
widening (it is false there, and a probe asserting it would not compile — if it somehow does, the
widening did not land); do NOT weaken, narrow or re-sign Phase 11.9's recorded statement block to
match what its dispatch found; do NOT claim the reserved name `cellLE_zero_const_of_kappa_eq`; do
NOT land a `sorry`, an axiom, a `native_decide` or a vacuous definition in either probe (a probe
carrying one is not evidence); do NOT raise a `decide` ceiling to name a larger tuple instead of
applying `rk_of_count_drift`; and do NOT edit any file under `FormalSystem/`, `Tests/` or
`scripts/` other than `scripts/check-evidence-probes.sh`.

**Timing**: 1.5 hours — three witnesses whose sources are reproduced verbatim in the research
input, three one-line positive counterparts, and two gate entries.

**Depends on**: 12.3

**Verification Tier**: local

**Tier Justification**: The deliverable is one new standalone probe file plus two shell-table
entries, with no library file edited and no library module importing either probe, so the cheapest
covering check is the guarded standalone compile of that one file
(`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean specs/evidence/seam-gluing-ray-product/ladder-reps-bound-refutation.lean`)
together with `bash scripts/check-evidence-probes.sh` read for its exit status and its wired count.

**Scope Hypothesis**: One probe file plus two gate entries. The probe re-declares the frozen bound
rather than importing it, so it is expected to be modest — the three witness sources are about
twenty lines in total — but MEASURE the final line count at phase close rather than trusting any
estimate from here. The carried figures and their source: the three tuples, their steps and their
`set_option` values come from `reports/08_rk-bounded-representative-refutation.md`'s Appendix B and
Tactic Survey, and the `34^4` figure for tuple B under the widened bound is derived here from
`4 + 6 + 3*5 + 2*2 + 5`; re-derive both at implementation time.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-reps-bound-refutation.lean` - the frozen pre-widening bound, the three refutation witnesses, and their three positive counterparts at the widened `RK`
- `scripts/check-evidence-probes.sh` - the table block and `WIRED` array entry for this probe AND for the already-landed `ladder-tight-chain-nonliftability.lean`

**Verification**:
- The new probe compiles standalone through the build guard with an explicit `--timeout`: exit 0, zero `error:`, zero `declaration uses 'sorry'`.
- `#print axioms` on every headline theorem of the new probe reports a subset of `[propext, Classical.choice, Quot.sound]`: no `sorryAx`, no custom axiom, no `native_decide`.
- **Non-vacuity is witnessed on both sides, per tuple**: each of the three tuples carries both its `¬ RKPre` refutation at the frozen bound AND its positive `RK` at the widened library definition. A tuple carrying only one side is reported as half-landed, not as met.
- The frozen bound really is frozen: `repsCntPre`'s range argument is `Tc + Tn + P + B + 2` (read the definition), the probe declares it locally rather than importing `repsCnt`, and the three positive counterparts are proved by `rk_of_count_drift` rather than by `decide` (grep the proof bodies).
- Witness C is named as the `P = 0` half in its own docstring (grep).
- **Both probes are wired, in the same commit**: `bash scripts/check-evidence-probes.sh` exits 0 and its PASS line reports **49** wired probes — the 47 measured at this revision's authoring (46 `WIRED` plus 1 `WIRED_REPO`, counted directly from the script's two arrays) plus these two — stated as that delta rather than as an absolute, and `git show --stat` for the commit names the probe file and the script together.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0 on both probes: their prose cites the live declarations and the archived prototypes by PATH and by NAME, never by task number.
- **No library file changed**: `git status --short FormalSystem/ Tests/` is empty at the phase's close, and `git diff --stat` names only the new probe and `scripts/check-evidence-probes.sh`.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`, unchanged, as it must be since this phase adds nothing to either root.
- Phase 11.9's recorded statement block and its `#### Reasoned Exclusions` record are byte-identical to their pre-dispatch text (`git diff` on this plan file over the phase's commits touches only Phase 12.4's own body).

---

### Phase 12.5: The Three Re-Homed Conditions of `Real` [COMPLETED]

**NEW IN THIS REVISION.** It lands exactly the three deliverables Phase 12.1 closed with a
`#### Reasoned Exclusions` record, whose single shared missing link — an `RK` edge from an actual
`Count`/`Drift` step — Phase 12.3 supplies. That record said the three were owed to whichever round
lands `rk_of_count_drift` and that a `/revise` is the route that re-homes them; this is that
re-homing.

**Goal**: Prove `certBiInfK`, `certFwdK` and `certBwdK` of `Real` — conditions (2), (3) and (4) —
as `real_certBiInfK`, `real_certFwdK` and `real_certBwdK`, named on the pattern the landed
`real_certLocK` and `real_certBoxK` set. After this phase, five of `Real`'s six conditions are
landed and only `certStabK` — the one that consumes the agreement — remains for Phase 12.2.

**Tasks**:
- [x] Prove `real_certBiInfK` *(completed: both witnesses are the neighbouring points of the member's own witnessing history, `realItem … σ (z + 1)` and `realItem … σ (z - 1)`; both arms existential; `Real` unmodified and not confined to one state's cell)*: every member of `Real` has a successor and a predecessor inside
      `Real`, with the `relK` edge at each supplied by `rk_of_count_drift` applied to the actual
      `Count`/`Drift` step of the witnessing history. Both fulfilment arms stay EXISTENTIAL.
- [x] Prove `real_certFwdK` *(completed by exactly the recorded decomposition: `m = (s - z).toNat` for the `s` that `untl_mem_tpOf_iff` supplies, `f i = realItem … σ (z + i)`, membership by `mem_real_realItem`, the consecutive-position relation by `relK_realItem_succ`)*: the discharge path is the contiguous stretch `z, z+1, …, z+m` of the
      SAME history — `untl_mem_tpOf_iff` (`LadderAgree.lean`) supplies the fulfilling position and
      the guard along the intervening stretch — every position of which lies in `Real` by
      `mem_real_realItem`, with the consecutive-position relation by `rk_of_count_drift`. This is
      the decomposition Phase 12.1's exclusion record already identified; follow it rather than
      re-deriving one.
- [x] Prove `real_certBwdK` *(completed: the mirror with `m = (z - s).toNat` and `f i = realItem … σ (z - i)`, `snce_mem_tpOf_iff` supplying the temporal content)*: the past-directed mirror along the reversed `relK`, with
      `snce_mem_tpOf_iff` supplying the temporal content and the same relation link.
- [x] Record in the module docstring that the three exclusions are DISCHARGED and by what *(completed: the predecessor's "NOT landed, and the reason is one shared obstruction rather than three" paragraph is REPLACED by what is now true — five of six conditions landed, condition (5) `certStabK` the only one outstanding — and the discharge names `rk_of_count_drift` and the widened `repsCnt` range by figure)*, naming
      `rk_of_count_drift` and the widened `repsCnt` by declaration name. The paragraph the
      predecessor round wrote — "NOT landed, and the reason is one shared obstruction rather than
      three" — is replaced by what is now true, not annotated.
- [x] **Do not state or prove `certStabK` of `Real`, `real_certAdmK_of_paramsOk` or *(completed: none of the three is stated; greps return only docstring prose naming them as Phase 12.2's)*
      `real_subset_dmax` here.** All three consume the agreement and stay Phase 12.2's; the split
      Phase 12.1 established is preserved by this phase.
- [x] Wire the new declarations (axiom pins, generated inventory blocks, `status.typ`) *(deviation: altered — `LadderRealize.lean` gains `import …RaySummary.LadderChain`, which the phase's tasks imply but do not state: `untl_mem_tpOf_iff`/`snce_mem_tpOf_iff` live in `LadderAgree.lean` and `cohIdle_of_realized` in `LadderChain.lean`, neither of which the module previously imported. The import is cycle-free — `LadderChain → LadderPump → LadderAgree → {AnchorLayer, CounterQuotient}`, and only `RaySummary.lean` imports `LadderRealize`. Three generated-block files again, not one)*. No C14
      entry and no theorem-index row: this phase lands no filed Goal.

**Prohibited workarounds**: do NOT consume `cellAt_const_of_kappa_eq` or the schema
`CellLEZeroConstOfKappaEq` in any proof of this phase — that is Phase 12.2's input and the split's
own acceptance criterion; do NOT reach for a union argument; do NOT shrink `Real` to one of the
refuted candidates; do NOT confine `Real` to one state's cell (`certBiInfK` forbids it); do NOT add
`hp` to a recorded Challenge statement; do NOT re-prove `rk_of_count_drift` inline instead of
citing it; and do NOT use `sorry`, `axiom` or a vacuous definition.

**Timing**: 1.5 hours — three condition lemmas whose temporal content is landed
(`untl_mem_tpOf_iff`, `snce_mem_tpOf_iff`, `mem_real_realItem`) and whose one missing link Phase
12.3 supplies.

**Depends on**: 12.3

**Verification Tier**: interface

**Tier Justification**: The three conditions are consumed by Phase 12.2's assembly and by Phase 15
across the module interface and all three enter the axiom test, so the covering check is the guarded
scoped build of `LadderRealize.lean` plus `bash scripts/check-module-invariants.sh` and
`#print axioms`.

**Scope Hypothesis**: Three condition lemmas plus whatever step-extraction helper the history's
`Count`/`Drift` step needs, inside `LadderRealize.lean` (**371 lines** at this revision's authoring,
measured directly, so no length remedy is in prospect), plus three wiring files. To be MEASURED at
phase close. If one of the three still does not close with `rk_of_count_drift` in hand, that is a
finding about THAT condition rather than about the lemma: record which conjunct resisted and close
the phase `[COMPLETED WITH EXCLUSIONS]` with a record naming it, rather than holding the phase open
or weakening `Real`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - real_certBiInfK, real_certFwdK, real_certBwdK and the module docstring paragraph recording the discharge
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom-profile entries for the three new declarations
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the generated inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- Guarded scoped build of `LadderRealize.lean` and of the axiom test each exit 0 with 0 warnings, with an explicit `--timeout` and the bounded single-call idiom.
- All three of `real_certBiInfK`, `real_certFwdK` and `real_certBwdK` are proved theorems, and each proof CITES `rk_of_count_drift` by name (grep the proof bodies) rather than deriving an `RK` edge inline.
- `#print axioms` on each of the three: no `sorryAx`, no custom axiom, no `native_decide`.
- **No proof of this phase consumes the agreement or the schema**: `grep -n 'cellAt_const_of_kappa_eq\|CellLEZeroConstOfKappaEq\|cellLE_zero_const_of_kappa_eq' FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` returns nothing outside a docstring sentence naming them as Phase 12.2's input. This is the split's own acceptance criterion, carried from Phase 12.1 unchanged.
- No theorem in the module states `certStabK … (Real …)`, `real_certAdmK_of_paramsOk`, `real_subset_dmax`, `Dmax … ⊆ Real …` or any equality `Dmax … = Real …` (grep): the first three are Phase 12.2's, the last two Phase 15's.
- No union argument appears, and no theorem claims `certAdmK … (Dmax …)` (grep).
- Both fulfilment arms of `real_certBiInfK` are existential, and `Real` is not confined to one state's cell (read the statement).
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; module-scoped vacuous grep over `LadderRealize.lean` count 0; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.
- `bash scripts/typst-sync-check.sh`, `bash scripts/readme-lint.sh`, `bash scripts/check-evidence-probes.sh` and `bash .claude/scripts/check-task-references.sh --quiet` each exit 0; `bash scripts/check-module-invariants.sh` passes every group except the single pre-existing `C16` finding of finding 26, unchanged in content and count.
- The module docstring no longer says the three conditions are NOT landed: `grep -n 'NOT landed' FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` returns nothing about conditions (2), (3) and (4).

---

### Phase 12.6: Re-Read the Maximum-Certified-Set Finding Against the Widened `RK` [COMPLETED]

**NEW IN THIS REVISION, AND IT EXISTS BECAUSE THE WIDENING IS NOT SEMANTICALLY FREE.** It is a
DECISION GATE in the sense `plan-format.md`'s "Decision gates and contingency branches" defines,
with two branches, each complete and reportable. Its subject is the one inherited claim Phase 12.3's
widening threatens, and the point of the phase is that the claim is CHECKED rather than inherited.

**Goal**: Decide, and record with its derivation, whether `Dmax`'s growth under the widened
`repsCnt` leaves the presentation-decision record's maximum-certified-set finding standing —
specifically its SUFFICIENCY half, "every certified `R` lies inside `Real`", which is the direction
the widening threatens.

**The mechanism, derived at this revision's authoring (finding 21).** `Dmax` is literally the union
of `certAdmK`-certified sets (`CounterQuotient.lean:701-704`) and `dmax_maximal` (`:714`) says every
certified set lies inside it. Widening `repsCnt` enlarges `RK`, hence `relK`, hence WEAKENS the
three relational conditions, so strictly MORE sets are certified and `Dmax` can only grow. What
bounds that growth is the pair of conditions that are NOT preserved by enlarging the candidate set
— `certStabK` and `certBoxK`, equalities between a letter's bit and a fibre of the candidate set,
as that module's own docstring (`:100-103`) records while naming this very finding. The consequences
a later phase stands on: `dmax_subset_real` (Phase 15's corollary) and `ladderRealized`'s own
right-hand side are both statements ABOUT the grown `Dmax`.

**Tasks**:
- [x] Re-read the record at *(completed at the ARCHIVED path; the record's Finding 3 sufficiency half is NARROWER than this plan's paraphrase of it: it reads "every certified `R` **with `Real ⊆ R`** satisfies `R ⊆ Real`", not "every certified `R` lies inside `Real`". `CounterQuotient.lean`'s `Dmax` docstring and its "No ladder consequence" bullet were re-read by declaration name, not by line number)*
      `specs/archive/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md`
      — the ARCHIVED path (finding 21: the predecessor plan's `Research Inputs` cite the pre-archive
      path, which no longer resolves) — together with `CounterQuotient.lean`'s `Dmax` docstring,
      which names that finding directly.
- [x] **Decide the branch by a derivation, not by assertion** — **VERDICT: MOVED.** *Derivation: `Real`'s definition names no relation, no `RK` and no `repsCnt`, so `Real` is UNCHANGED by the widening, while `Dmax` is the union of certified sets and the widening weakens `certBiInfK`/`certFwdK`/`certBwdK` (each an existential over `relK`-related members), so `Dmax` can only grow and `Dmax ⊆ Real` is strictly harder than before. The specific conjunct that fails to bound the growth is `certStabK`, whose right-hand side `∀ y ∈ R, y.1 = x.1 → y.2.2 = x.2.2 → argOf ψ ∈ y.2.1.val` quantifies over `R` ITSELF — and `certBoxK`'s `∀ y ∈ R, argOf ψ ∈ y.2.1.val` likewise. Neither names `cellAt`, `tpOf`, `Rlad` or any history (`CounterQuotient.lean`'s own "No ladder consequence" bullet), so neither can force `R`'s fibre at a `(q, κ)` into `Real`'s fibre there: both constrain which TYPES a candidate may carry at a `(q, κ)`, never which class pairs are related, which is where the widening acts. What does force the inclusion is the lift consumed by the recorded sufficiency argument's `⟸` direction — "the induction hypothesis on a chain through each `R`-fibre member" — and a chain is admitted by `certLocK` together with `relK`, whose counter conjunct is exactly what grew; so that lift now has a WEAKER hypothesis and is a STRICTLY STRONGER statement.*: for a `certAdmK`-certified `R` under
      the WIDENED `RK`, do `certStabK` and `certBoxK` still force `R`'s fibre at each `(q, κ)` into
      `Real`'s fibre there? Record the derivation if they do, or the obstruction if they do not,
      with the specific conjunct named either way.
      - **STANDS** — the two non-union-stable conditions still pin every certified set's fibres to
        `Real`'s, so the finding is unchanged under the widening and Phase 15's `dmax_subset_real`
        is unaffected. Record the re-read and its reason.
      - **MOVED** — the growth is not bounded by those two conditions, so the finding is weaker
        than recorded under the widened `RK`. Record exactly which inclusion fails and at which
        conjunct, name it as Phase 15's inherited contingency (that phase's `dmax_subset_real` task
        is the one that consumes it), and name it under `### Follow-ups this revision records and
        does not act on` as the input to a further `/revise`. The phase still CLOSES on this branch:
        a recorded, derived MOVED verdict is a complete outcome, not a failure.
- [x] Record the verdict in `LadderRealize.lean`'s module docstring and in this phase's own body *(completed: the docstring carries the MOVED verdict with its derivation, the named conjuncts, and the consequence for `ladderRealized`'s right-hand side; the RaySummary README's depth-`0` status paragraph is UNTOUCHED)* *(deviation: altered — `check-module-invariants.sh`'s INV check went RED on three stale generated inventory blocks once `LadderRealize.lean` grew from 576 to 613 lines, so the machine-owned blocks were refreshed. The diff is three line-count numerals inside `<!-- BEGIN GENERATED -->` blocks and nothing else; the depth-`0` status paragraph and every line of prose in the RaySummary README are untouched, so the collision this phase's prohibition exists to avoid does not arise. Leaving a NEW red gate in the tree was judged the worse outcome)*.
      **Do NOT amend `FormalSystem/Metalogic/Decidability/RaySummary/README.md` in this phase** —
      its depth-`0` status paragraph is the successor chain's live territory and Phase 18 is this
      plan's records pass. This is the same deliberate collision avoidance Phase 11.9 recorded, not
      an omission.
- [x] Do NOT narrow `repsCnt`, weaken `Real` or restate any filed statement to reach STANDS *(honoured: `repsCnt`, `Real`, `Dmax`, `ParamsOk` and every filed statement are unmodified by this phase; `git diff` names only `LadderRealize.lean`'s module docstring, `typst/generated/status.typ` and the three generated inventory blocks)*.

**Prohibited workarounds**: do NOT narrow `repsCnt` back, in whole or in part, to reach the STANDS
branch; do NOT strengthen `ParamsOk` to reach it either; do NOT record a verdict without the
derivation that produced it; do NOT claim `certAdmK … (Dmax …)`, or `certStabK` or `certBoxK` of a
union of certified sets, on either branch; do NOT edit the RaySummary README in this phase; and do
NOT use `sorry`, `axiom` or a vacuous definition.

**Timing**: 0.5 hours — a re-read and a recorded derivation over two already-landed docstrings and
one archived record, with no new declaration owed on either branch.

**Depends on**: 12.3, 12.5

**Verification Tier**: local

**Tier Justification**: The deliverable is a recorded verdict plus one docstring paragraph in the
single module `LadderRealize.lean`, with no signature change and no new declaration on either
branch, so the covering check is the guarded scoped build of that one module
(`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderRealize`)
together with `bash scripts/readme-lint.sh` and
`bash .claude/scripts/check-task-references.sh --quiet` read for their exit statuses.

**Scope Hypothesis**: One docstring paragraph and zero declarations on the STANDS branch; on the
MOVED branch, additionally one named inherited contingency on Phase 15 and one recorded Follow-up.
To be MEASURED at phase close. The carried figures and their source: `Dmax`'s definition at
`CounterQuotient.lean:701-704`, `dmax_maximal` at `:714` and the Finding-3 docstring at `:100-103`
were read directly at this revision's authoring (this plan's finding 21) — but **Phase 12.3 edits
that module**, so these line numbers will have drifted by the time this phase runs. Re-read by
declaration name, never by line number.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - the module-docstring paragraph recording the verdict and its derivation
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- The guarded scoped build of `LadderRealize.lean` exits 0 with 0 warnings, with an explicit `--timeout`.
- The verdict appears in this phase's body and in the module docstring, naming which of the two branches was taken AND the derivation or obstruction that decided it, with the specific conjunct named. A verdict recorded without its derivation fails this item.
- **No declaration was added, removed or re-signed**: `git diff --stat` over this phase's commits names only `LadderRealize.lean` and `typst/generated/status.typ`, and `git diff` on that module shows changes inside the module docstring only.
- No theorem anywhere claims `certAdmK … (Dmax …)`, or `certStabK` or `certBoxK` of a union of certified sets (grep), on either branch.
- The RaySummary README is untouched by this phase: `git status --short FormalSystem/Metalogic/Decidability/RaySummary/README.md` is empty at the phase's close, and any concurrent edit by the successor chain is preserved.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.
- `bash scripts/readme-lint.sh`, `bash scripts/typst-sync-check.sh` and `bash .claude/scripts/check-task-references.sh --quiet` each exit 0.
- On the MOVED branch: Phase 15's inherited contingency is named in that phase's body or in the handoff, the Follow-up is recorded, and `Real`, `Dmax`, `repsCnt` and every filed statement are unmodified by this phase (`git diff` confirms).

---

### Phase 13: Obligation (S) — `ladderSound` [NOT STARTED]

**GATED THROUGH PHASE 12.2.** Content unchanged by this revision; its `Depends on` is re-pointed from
Phase 12 to Phase 12.2, which is the half that carries what it consumes.

**Goal**: Prove `ladderSound` at the signature the `## Lean Challenge Statements` block pins, with no
parameter hypothesis, by projecting an admissible ladder history into `Real` and citing
`real_subset_dmax`. This is the plan's statement-level contingency point.

**Tasks**:
- [ ] First probe whether the unconstrained `ladderSound` is REFUTABLE at the all-zero tuple on the
      refutation probe's own object. A landed separating pair is a complete, reportable outcome and is
      wired as a probe.
- [ ] If it is not refutable, attempt the pinned statement token-for-token.
- [ ] If neither closes, land `ladderSound_of_paramsOk` under that honest auxiliary name, mark the
      pinned `ladderSound` `[BLOCKED]` with the goal state recorded, and raise the statement-defect.
      Adding `hp` to a recorded Challenge statement is routed to the user by Statement Fidelity, never
      taken by an implementer.
- [ ] Add the `docs/theorem-index.md` row and the matching C14 heredoc entry for whichever statement
      landed, with a filed statement that did not land named as OPEN.

**Prohibited workarounds**: do NOT add `hp` to `ladderSound`'s own signature; do NOT carry a soundness
clause as a `LadderCons` hypothesis field; do NOT use a trace-level `Presented` hypothesis, a
finite-fibre or finite-width assumption; and do NOT use `sorry`, `axiom` or a vacuous definition.

**Timing**: 2 hours

**Depends on**: 12.2

**Verification Tier**: interface

**Tier Justification**: The Goal is consumed by Phase 14 across the module interface and enters both
the axiom test and the C14 pin, so the covering check is the guarded scoped build of
`LadderRealize.lean` plus `bash scripts/check-module-invariants.sh` with the new C14 entry.

**Scope Hypothesis**: One Goal declaration plus, on the refuting branch, one new wired probe and its
gate entry; three record files. To be MEASURED at phase close.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderSound or ladderSound_of_paramsOk
- `specs/evidence/seam-gluing-ray-product/ladder-sound-unconstrained-parameter-refutation.lean` - the probe, on the refuting branch ONLY
- `scripts/check-evidence-probes.sh` - the probe's table block and array entry, on the refuting branch ONLY
- `docs/theorem-index.md` - the row
- `scripts/check-module-invariants.sh` - the matching C14 heredoc entry
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pin
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- Guarded scoped build exits 0 with 0 warnings; `bash scripts/check-module-invariants.sh` exits 0 with the new C14 entry and the matching index row.
- Whichever statement landed matches its recorded signature token-for-token by direct `diff`; `ladderSound` carries NO parameter hypothesis if it landed under that name.
- `#print axioms` on the landed declaration: no `sorryAx`, no custom axiom, no `native_decide`.
- On the refuting branch, `bash scripts/check-evidence-probes.sh` exits 0 with the new probe PASS.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.
- If the phase closes `[BLOCKED]`: the filed statement is named as OPEN in `docs/theorem-index.md`, the README and the summary, with the auxiliary recorded under its own name.

---

### Phase 14: `ladderCons_localRun` [NOT STARTED]

**GATED THROUGH PHASE 13.** Content unchanged by this revision.

**Goal**: Prove `ladderCons_localRun` at its pinned signature, with no parameter hypothesis: every
ladder run projects to a certificate chain inside a consistent bundle.

**Tasks**:
- [ ] Prove the two conjuncts — `certChain` of the projection, and membership in `R` — from the bundle's
      definition and Phase 13's (S).
- [ ] Add the `docs/theorem-index.md` row and the matching C14 heredoc entry.
- [ ] **Contingency**: if Phase 13 closed on its auxiliary branch, this phase inherits that as its own
      `[BLOCKED]` contingency and must NOT repair it by adding a `LadderCons` field — that would make
      the second conjunct near-vacuous under a filed name.

**Prohibited workarounds**: do NOT add `hp`; do NOT carry a soundness clause as a `LadderCons` field;
and do NOT use `sorry`, `axiom` or a vacuous definition.

**Timing**: 1.5 hours

**Depends on**: 10, 13

**Verification Tier**: interface

**Tier Justification**: The Goal enters the axiom test and the C14 pin and is observed by Phase 18's
final gate, so the covering check is the guarded scoped build of `LadderRealize.lean` plus
`bash scripts/check-module-invariants.sh` with the new C14 entry.

**Scope Hypothesis**: One Goal declaration plus three record files. To be MEASURED at phase close.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderCons_localRun
- `docs/theorem-index.md` - the row
- `scripts/check-module-invariants.sh` - the matching C14 heredoc entry
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pin
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- Guarded scoped build exits 0 with 0 warnings; `bash scripts/check-module-invariants.sh` exits 0 with the new C14 entry and index row.
- The signature matches the Challenge block token-for-token by direct `diff`, with no parameter hypothesis.
- `#print axioms`: no `sorryAx`, no custom axiom, no `native_decide`.
- No `LadderCons` field was added: `git diff` on `LadderCons` is empty.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.

---

### Phase 15: Obligation (C') — `ladderLift`, the Pumping Completeness, and `Dmax ⊆ Real` [NOT STARTED]

**GATED THROUGH PHASES 11.7 AND 12.2. ITS CONSUMED CASCADE INTERFACE IS DECIDED BY THIS REVISION.**
Content otherwise unchanged; its `Depends on` was re-pointed by the predecessor revision from Phase
12 to Phase 12.2, which is the half that carries what it consumes. **The decision this revision
takes**: this phase consumes Phase 11.8's joined `exists_ladderPath_at_region` and nothing else from
the cascade — the two facts `spliced_at_region` exposes at the comparison position (the same object
state, and the countdown raised by `l`), delivered unconditionally in both regimes by Phase 11.2's
landed dichotomy. It does NOT consume a `spliceObj`-shaped conclusion, which is REFUTED in the
idle-past regime (Phase 11.8's blocker record), and it does not reach for `spliceObj`/`spliceCnt`
directly. **One wiring consequence to carry**: if Phase 11.2 or 11.8 took its pre-authorized
contingency and landed the cascade in `LadderCascade.lean`, this phase must import that module;
Phase 11.2 did NOT take it (it raised the in-source `longFile` baseline in place instead), so the
phase's first task is to check which module Phase 11.8's half landed in.

**Goal**: Prove `ladderLift` at its pinned signature in PUMPING form, and conclude `Dmax ⊆ Real` as its
corollary with the landed `dmax_certBiInfK`.

**Tasks**:
- [ ] Check which module Phase 11.8's half of the cascade landed in and import it if it is not
      `LadderAgree.lean`. Phase 11.2's half took the in-place `longFile` remedy rather than the
      contingency module, so `LadderCascade.lean` is not expected to exist.
- [ ] Prove `ladderLift` in pumping form, CITING Phase 11's machinery declarations and Phase 11.8's
      joined `exists_ladderPath_at_region` rather than re-proving either, so that one interface
      serves both regimes. Read the two facts that interface delivers at the comparison position —
      the same object state, and the countdown raised by `l` — and nothing else from the cascade; do
      NOT reach for `spliceObj`, `spliceCnt` or a `spliceObj`-shaped conclusion, which is REFUTED
      in the idle-past regime.
- [ ] Conclude `dmax_subset_real` from `ladderLift` and `dmax_certBiInfK`.
- [ ] Add the `docs/theorem-index.md` row and the matching C14 heredoc entry.

**Prohibited workarounds**: do NOT weaken `ladderLift` to the positionwise form
(`no_positionwise_lift` is compiled, so the narrowed form is FALSE, not weaker); do NOT re-prove Phase
11's machinery; do NOT relax a pin hypothesis; and do NOT use `sorry`, `axiom` or a vacuous definition.

**Timing**: NOT COSTABLE, for the same reason Phases 11.2 and 11.6-11.9 are not: this is the second half
of the open counter-lift mathematics.

**Depends on**: 7, 11.8, 11.7, 12.2

**Verification Tier**: full

**Tier Justification**: The lift spans the pin-lemma interface, the cascade, the agreement and the
certificate layer at once and is consumed by Phase 16, so no cheaper tier covers that surface.

**Scope Hypothesis**: One Goal declaration, one corollary and three record files, plus one import line
if the cascade's contingency module was taken. To be MEASURED at phase close. If `ladderLift` does not
close, mark the phase `[BLOCKED]` with the goal state recorded and leave Phases 16-18 `[NOT STARTED]`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderLift, dmax_subset_real, and the cascade module's import if Phase 11.8's contingency was taken
- `docs/theorem-index.md` - the row
- `scripts/check-module-invariants.sh` - the matching C14 heredoc entry
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pin
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- The guarded scoped build exits 0 with 0 warnings and the unscoped guarded build exits 0 at the end of the phase; `bash scripts/check-module-invariants.sh` exits 0 with the new C14 entry and index row.
- The signature matches the Challenge block token-for-token by direct `diff`.
- The proof CITES Phase 11's machinery and Phase 11.8's joined `exists_ladderPath_at_region` by name (grep the proof body) rather than re-proving either, and no proof of this phase names `spliceObj`, `spliceCnt` or `exists_spliced_ladderPath_of_idle_past` (grep).
- `#print axioms`: no `sorryAx`, no custom axiom, no `native_decide`.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.

---

### Phase 16: The Fibre Equation `ladderRealized` [NOT STARTED]

**GATED THROUGH PHASES 13 AND 15. If Phase 11.9's verdict was REFUTED, this phase's Goal is FALSE** —
`ladderRealized` implies the depth-`0` schema, as Phase 11.9's body derives — and the phase closes
`[COMPLETED WITH EXCLUSIONS]` citing that compiled object rather than being attempted. Content otherwise
unchanged by this revision.

**Goal**: Prove `ladderRealized` at its pinned signature, with `hp` in the recorded position: the cell
at an admissible ladder state is exactly the fibre of `Dmax` at that state's class, for ALL `φ`,
`box` and `stab` letters included.

**Tasks**:
- [ ] Prove the two inclusions from (S) and (C') with `real_subset_dmax` and `dmax_subset_real`.
- [ ] Assert `hp` is present in the elaborated signature and is CONSUMED, not discharged by `trivial`.
- [ ] Add the `docs/theorem-index.md` row and the matching C14 heredoc entry.

**Prohibited workarounds**: do NOT consume `cellAt_const_of_kappa_eq` as a HYPOTHESIS of this statement;
do NOT drop the `box`/`stab` acceptance clause; do NOT add a finite-fibre or finite-width assumption;
and do NOT use `sorry`, `axiom` or a vacuous definition.

**Timing**: 2 hours

**Depends on**: 13, 15

**Verification Tier**: full

**Tier Justification**: The fibre equation spans `cellAt`, `Dmax`, `kappa` and both obligations at once
and is this task's headline statement, so no cheaper tier covers that surface.

**Scope Hypothesis**: One Goal declaration plus three record files. To be MEASURED at phase close.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderRealized
- `docs/theorem-index.md` - the row
- `scripts/check-module-invariants.sh` - the matching C14 heredoc entry
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pin
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- The unscoped guarded build exits 0 with 0 warnings; `bash scripts/check-module-invariants.sh` exits 0 with the new C14 entry and index row.
- The signature matches the Challenge block token-for-token by direct `diff`, with `hp` in the recorded position; `lean_minimal_hypotheses` confirms `hp` is not a redundant binder.
- The agreement appears as an INPUT of the proof, never as a hypothesis of the statement (grep the signature).
- `#print axioms`: no `sorryAx`, no custom axiom, no `native_decide`.
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.

---

### Phase 17: Gate 8 — Exercise the `stab` Clause on a `stab`-Bearing Fixture [NOT STARTED]

**GATED THROUGH PHASE 16.** Content unchanged by this revision.

**Goal**: Author and wire the gate-8 probe that exercises the `stab` acceptance clause on a
`stab`-bearing fixture, so the clause is not merely stated.

**Tasks**:
- [ ] Author `specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean` at a fixture whose
      closure carries a `⊡` letter, and compile it standalone through the build guard.
- [ ] Wire it into `scripts/check-evidence-probes.sh`.

**Prohibited workarounds**: do NOT use a stab-free fixture; do NOT use `sorry`, `axiom`,
`native_decide` or a vacuous definition in the probe.

**Timing**: 1.5 hours

**Depends on**: 16

**Verification Tier**: local

**Tier Justification**: One standalone probe file with no library consumer plus one shell-table entry,
so the covering check is the guarded standalone compile plus `bash scripts/check-evidence-probes.sh`
read for its exit status.

**Scope Hypothesis**: One probe file plus one gate entry. To be MEASURED at phase close.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean` - the gate-8 probe
- `scripts/check-evidence-probes.sh` - the probe's table block and array entry

**Verification**:
- The probe compiles standalone through the build guard: exit 0, zero `error:`, zero `declaration uses 'sorry'`.
- `#print axioms` on every headline reports a subset of `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/check-evidence-probes.sh` exits 0 with the new probe PASS and one more wired probe than its count at the start of the phase.
- The fixture's closure carries a `⊡` letter: the probe's own non-vacuity conjunct says so and compiles.

---

### Phase 18: Records, the Full Gate, and the Summary [NOT STARTED]

**THE FINAL PHASE.** Content unchanged by this revision except in its records pass, which now owes
three records rather than one: the Phase 11.9 verdict's record in the README (which that phase
deliberately deferred to here), Phase 12.6's maximum-certified-set verdict, and the representative
widening together with what it unblocked. Its `Depends on` gains `12.4` and `12.6`, the two phases
this revision adds that nothing else depends on, so that the final phase keeps observing every phase
of the plan directly or transitively.

**Goal**: Bring every record current, run the full gate set, and write the round's summary.

**Tasks**:
- [ ] Bring the RaySummary README's depth-`0` status paragraph current with Phase 11.9's verdict and
      with whatever Phases 11.2, 11.6, 11.7, 11.8, 12.1, 12.2, 12.3, 12.4, 12.5, 12.6 and 13-17
      landed. Check for a concurrent edit by the live successor chain before editing, and preserve
      it.
- [ ] Record the representative widening in the README and in `docs/theorem-index.md`: the bound
      that replaced `Tc + Tn + P + B + 2`, the two compiled directions that forced it, the wired
      probe that carries them, and `rk_of_count_drift` with the three conditions of `Real` it
      unblocked. Record that `ParamsOk` was NOT added to it, and why.
- [ ] Record Phase 12.6's verdict (STANDS or MOVED) on the maximum-certified-set finding, with the
      conjunct its derivation named, and — on MOVED — the consequence for `dmax_subset_real` and for
      `ladderRealized`'s right-hand side, named as open rather than as settled.
- [ ] Guardrail read-through of every header and record paragraph: closure-indexed letters with
      `box`/`stab` bits included; infinite width and no fibre bound; every quantity a count; zero debt;
      the forward-only liveness fact in its precise sense with no device-discrimination claim.
- [ ] Grep every touched record for `truncate`, `Fin (B+1)`, `min c B`, `clip (n`, and require each
      occurrence to sit inside a sentence naming it as deleted, refuted or research-level.
- [ ] Run the full gate set and record each exit status directly.
- [ ] Write the summary at
      `specs/761_ladder_realization_theorem/summaries/10_rk-bounded-representative-widening-summary.md`.

**Prohibited workarounds**: do NOT state a cost figure for a NOT COSTABLE phase; do NOT re-introduce the
deleted index in any record; do NOT narrate a record's own draft history.

**Timing**: 1.5 hours

**Depends on**: 6, 14, 17, 12.4, 12.6

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the brought-current records, including Phase 11.9's verdict
- `docs/theorem-index.md` - the final row set, with every open or blocked statement named as OPEN
- `specs/761_ladder_realization_theorem/summaries/10_rk-bounded-representative-widening-summary.md` - the summary
- `specs/state.json` - the status transition
- `typst/generated/status.typ` - the regenerated line counts

**Verification**: the complete gate set, each exit status read directly —
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` and the same for
`build BimodalTest`; `bash scripts/check-evidence-probes.sh`; `bash scripts/check-module-invariants.sh`;
`bash scripts/typst-sync-check.sh`; `bash scripts/readme-lint.sh`;
`bash .claude/scripts/check-task-references.sh --quiet`; `bash .claude/scripts/verify-deploy.sh`; and
the `## Testing & Validation` checklist below in full.

## Lean Challenge Statements

**Carried verbatim and unedited from `plans/08_cell-agreement-construction-handoff.md`.** The six
`theorem` declarations are the Goals and carry `sorry` bodies; they are listed in the order the phases
prove them. Everything above them is supporting context declared with `abbrev`, which the snapshot tool
(`lean-challenge-snapshot.sh`) neither counts as a Goal nor rewrites — but it DOES swallow any
non-`theorem` text that sits between two `theorem` declarations into the preceding `:= sorry`, so every
`abbrev` must precede the first `theorem`. The `abbrev`s pin BY POSITION ONLY the objects Phases 8-10
define: `ClType` and `certAdmK`, `kappa`, `ParamsOk`, `Tcof`, `Tnof`, `Pof`, `Bof` and `Dmax` are
landed (Phases 8 and 9), and `typeOfCl`, `certChain` and `LadderCons` are Phase 10's. `CK` is written
out, because its five-coordinate shape is forced by the compiled mechanisms and is part of the
contract; its four parameters are OUTPUTS, which is why they are universally quantified arguments at
every use site and never exhibited constants — and why the two factorization-side theorems constrain
them through `ParamsOk` rather than quantifying over them freely. `ParamsOk`, `Tcof`, `Tnof`, `Pof` and
`Bof` take `[Fintype Q]`, `step`, `pend`, `lab` and `phi` as well as the naturals, matching their
landed signatures in `CounterQuotient.lean`: (K1) quantifies the certificate graph's cycle lengths,
(K2) the cascade bound and the periodicity threshold, and (K4) the formula's exactness depths, none of
which a predicate on four naturals can express. `paramsOk_params` is what makes that hypothesis
dischargeable at the parameters the periodicity fixpoint defines; without it the two statements would
be safe but vacuous. Identifiers are ASCII for the snapshot tool's regex.

**CARRIED-UNVERIFIED, with the source named.** The predecessor plan records that this block was
compiled standalone at ITS authoring time through the build guard
(`bash .claude/scripts/lake-build-guard.sh build --timeout 800 -- env lean <file>`): exit 0, zero
errors, exactly eighteen `declaration uses 'sorry'` warnings (twelve `abbrev`, six `theorem`). That
figure is NOT re-derived here, because this revision is a planning round that runs no build; its source
is `plans/08_cell-agreement-construction-handoff.md`'s own `## Lean Challenge Statements` preamble, and
the block below is byte-for-byte what was compiled there. A dispatch that wants the figure current
re-runs that one command.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761A

abbrev ClType (phi : PlusFormula) : Type := sorry

abbrev typeOfCl {phi : PlusFormula} : ClType phi -> Finset PlusFormula := sorry

abbrev CK (Tc Tn P B : Nat) : Type :=
  Fin (Tc + 1) × Fin (P + 1) × Fin (Tn + 1) × Fin (P + 1) × Fin (2 * B + 1)

abbrev kappa (Tc Tn P B : Nat) : Nat × Nat -> CK Tc Tn P B := sorry

abbrev ParamsOk {Q : Type} [Fintype Q] (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) (Tc Tn P B : Nat) : Prop := sorry

abbrev Tcof {Q : Type} [Fintype Q] (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) : Nat := sorry

abbrev Tnof {Q : Type} [Fintype Q] (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) : Nat := sorry

abbrev Pof {Q : Type} [Fintype Q] (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) : Nat := sorry

abbrev Bof {Q : Type} [Fintype Q] (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) : Nat := sorry

abbrev certAdmK {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (R : Set (Q × ClType phi × CK Tc Tn P B)) : Prop := sorry

abbrev certChain {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (xi : Int -> Q × ClType phi × CK Tc Tn P B) : Prop := sorry

abbrev Dmax {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat) : Set (Q × ClType phi × CK Tc Tn P B) := sorry

abbrev LadderCons {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (R : Set (Q × ClType phi × CK Tc Tn P B)) : Prop := sorry

theorem cellAt_const_of_kappa_eq {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (hp : ParamsOk step pend lab phi Tc Tn P B)
    (q : Q) (c n c' n' : Nat) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) (t z : Int) :
    cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
      = cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c', n'), h'⟩) z := sorry

theorem ladderSound {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : Int)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q)
    (hs : (sigma.state z).2 = ⟨(q, c, n), h⟩) :
    exists T : ClType phi,
      typeOfCl T = tpOf (ladderModel step pend fwd bwd lab) phi sigma z ∧
      (q, T, kappa Tc Tn P B (c, n)) ∈ Dmax step pend lab phi Tc Tn P B := sorry

theorem ladderCons_localRun {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (R : Set (Q × ClType phi × CK Tc Tn P B))
    (hR : LadderCons step pend lab phi Tc Tn P B R)
    (sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (xi : Int -> Q × ClType phi × CK Tc Tn P B)
    (hproj : forall t, (xi t).1 = (sigma.state t).2.1.1 ∧
      typeOfCl (xi t).2.1 = tpOf (ladderModel step pend fwd bwd lab) phi sigma t ∧
      (xi t).2.2 = kappa Tc Tn P B ((sigma.state t).2.1.2.1, (sigma.state t).2.1.2.2)) :
    certChain step pend lab phi Tc Tn P B xi ∧ forall t, xi t ∈ R := sorry

theorem ladderLift {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (xi : Int -> Q × ClType phi × CK Tc Tn P B)
    (hxi : certChain step pend lab phi Tc Tn P B xi)
    (hmem : forall t, xi t ∈ Dmax step pend lab phi Tc Tn P B)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q)
    (h0 : (xi 0).1 = q) (hk : (xi 0).2.2 = kappa Tc Tn P B (c, n)) :
    exists sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
      (sigma.state 0).2 = ⟨(q, c, n), h⟩ ∧
      tpOf (ladderModel step pend fwd bwd lab) phi sigma 0 = typeOfCl (xi 0).2.1 := sorry

theorem ladderRealized {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (hp : ParamsOk step pend lab phi Tc Tn P B)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q) (t z : Int) :
    cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
      = {T | exists S : ClType phi, typeOfCl S = T ∧
          (q, S, kappa Tc Tn P B (c, n)) ∈ Dmax step pend lab phi Tc Tn P B} := sorry

theorem paramsOk_params {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) :
    ParamsOk step pend lab phi (Tcof step pend lab phi) (Tnof step pend lab phi)
      (Pof step pend lab phi) (Bof step pend lab phi) := sorry

end Probe761A
```

## Testing & Validation

Every criterion below is expressed relative to a baseline MEASURED at this plan's authoring or to a
scoped path set, and names the repository's sanctioned entry point with its exit status read. The
baselines, with the exact command each was measured by:

| Baseline | Value at this plan's authoring | Command |
|----------|-------------------------------|---------|
| Sorry census | `sorry_count: 0`, exit 0 | `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` |
| Vacuous-definition heuristic | 1 hit: `FormalSystem/Examples/TemporalStructures.lean:495` (`theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`), a false positive | `grep -rnE '^\s*(noncomputable )?(def\|theorem\|lemma\|instance\|abbrev) [A-Za-z_].*:=\s*(True\|Unit\|trivial\|Trivial)\s*$' FormalSystem/ Tests/ --include=*.lean` |
| `^axiom ` line count | 10 in `FormalSystem/`, 2 in `Tests/`, all docstring prose | `grep -rn '^axiom ' FormalSystem/ --include=*.lean \| wc -l` and the same over `Tests/` |
| Wired evidence probes | 47 (46 `WIRED` entries plus 1 `WIRED_REPO` entry), with `ladder-tight-chain-nonliftability.lean` tracked, compiling and ABSENT from both arrays | counted from the two arrays in `scripts/check-evidence-probes.sh`; absence by `grep -n 'ladder-tight-chain-nonliftability' scripts/check-evidence-probes.sh` |
| `LadderAgree.lean` length / ceiling | 2,477 lines / in-source `set_option linter.style.longFile 2600` (`:308`) — 123 lines of headroom | `wc -l` and `grep -n longFile` on the module |
| `LadderRealize.lean` length | 371 lines, no in-source `longFile` baseline | `wc -l` on the module |
| `CounterQuotient.lean` length | 758 lines, no in-source `longFile` baseline, under the package-wide 1500 | `wc -l` and `grep -n longFile` on the module |
| `repsCnt`'s landed bound | `Finset.range (Tc + Tn + P + B + 2)` squared, `CounterQuotient.lean:184` | direct read |
| Pre-existing `check-module-invariants.sh` state | exit 1 on one `C16` `unusedArguments` finding (`mem_cellAt_of_shift_of_hasForwardSlack`, `LadderChain.lean`); every other group passes | recorded by Phases 11.2 and 12.1 at their closes; NOT re-run at this revision's authoring |

- [ ] The library modules this plan touches (`LadderAgree.lean`, `LadderRealize.lean`, and the
      contingency `LadderCascade.lean` if taken) compile through the build guard with 0 errors and 0
      warnings, scoped per phase and once in full at Phase 18.
- [ ] `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`.
      The repository-wide vacuous-definition grep is UNCHANGED from the 1-hit baseline above — "count
      0" is unmeetable for this pattern and is not asked for — while a MODULE-SCOPED grep over each
      file this plan creates or edits is count 0. The `^axiom ` counts are unchanged from the 10/2
      baselines above; "count 0" is likewise unmeetable there, because every hit is prose.
- [ ] Per-theorem `#print axioms` on all six Goals that landed: no `sorryAx`, no custom axiom, no
      `native_decide`. A Goal that did not land is named as OPEN rather than counted.
- [ ] The six Goal signatures match the Lean Challenge Statements block token-for-token, verified by
      direct `diff` of the extracted signature text against that block. `lean-challenge-snapshot.sh`
      is NOT a gate here: it refuses with exit 73 once the task's status is past `planned`, and its
      `--check` verdict is advisory in any case.
- [ ] The parameter hypothesis appears in `cellAt_const_of_kappa_eq` and `ladderRealized` and in none
      of `ladderSound`, `ladderLift`, `ladderCons_localRun`; it is a used binder in both proofs; and
      `paramsOk_params` discharges it at the four defined parameter outputs.
- [ ] **The acyclicity check, re-run on the landed tree**: `LadderAgree.lean` contains no certificate
      identifier (`certAdmK`, `certStabK`, `certBoxK`, `certBiInfK`, `certLocK`, `certFwdK`,
      `certBwdK`, `certChain`, `Dmax`, `ClType`, `LadderCons`) outside its docstring, and imports no
      certificate module other than `CounterQuotient`.
- [ ] **The third-circularity check**: the same grep extended with `prodPre_periodic`, `prodPreStep`,
      `cohIdle`, `satThreshold` and `satPeriod` returns nothing in `LadderAgree.lean`.
- [ ] **The transport layer is a layer, not a parameter change**: `git diff` on `CounterQuotient.lean`
      over this plan's commits shows no change to `ParamsOk`, to `paramsOkK1`-`paramsOkK4`, or to the
      four parameter outputs; no fifth parameter source exists anywhere; and `paramsOk_params` and
      `not_paramsOk_allZero` are unmodified by any phase of this plan.
- [ ] **The import DAG is unchanged in direction**: `LadderAgree.lean` imports `AnchorLayer` and
      `CounterQuotient` and nothing else; no phase of this plan adds an import of `LadderPump`,
      `LadderPin` or `LadderChain` to it, and no phase edits those three modules
      (`git diff --stat` over this plan's commits names none of them).
- [ ] Half (i) of the transport layer carries a compiled non-vacuity witness, and the
      alternative-history construction carries its own. A transport lemma or a construction without
      its witness is reported as vacuous, not as met.
- [ ] Half (i) is stated RELATIVE to a pinned-letter parameter and the depth induction instantiates
      it. **Half (ii) is WITHDRAWN and must appear nowhere**: no declaration in the tree is named
      `tpOf_stabFree_eq_of_splice`, and `grep -rnE 'tpOf.*splice|splice.*tpOf' FormalSystem/ Tests/`
      returns nothing outside a docstring sentence recording the refutation.
- [ ] The four landed refutation probes (`ladder-unconstrained-parameter-refutation.lean`,
      `ladder-splice-type-refutation.lean`, `ladder-cell-agreement-refutation.lean`,
      `ladder-cell-obligation-refutation.lean`) are unmodified, still wired, and still PASS, and the
      docstrings recording their refutations are not weakened.
- [ ] No theorem anywhere claims `certAdmK … (Dmax …)`, `certStabK` or `certBoxK` of a union of
      certified sets: only the four monotone conditions survive a union, and `Dmax`'s own certification
      is reached through `Real`.
- [ ] `Realize.lean`'s `SLive`, `SCoh`, `deferGraph`, `bwdDeferGraph`, `Disch`, `DischBwd`, `persist`
      and `snce_iff_of_SCoh_SLive` appear in neither new module outside the docstring sentence
      recording why they do not transfer.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with every wired probe PASS. The wired count is
      47 plus one for each probe this plan actually wires (Phase 11.9 on its REFUTED branch, Phase 13
      on its refuting branch, Phase 17 unconditionally) — stated as a delta against the measured
      baseline rather than as an absolute.
- [ ] `bash scripts/check-module-invariants.sh`, `bash scripts/readme-lint.sh`,
      `bash scripts/typst-sync-check.sh`, `bash .claude/scripts/verify-deploy.sh` and
      `bash .claude/scripts/check-task-references.sh --quiet` all exit 0, each exit status read
      directly rather than inferred from a diff of captured output.
- [ ] Guardrail read-through of every header and record paragraph: closure-indexed letters with
      `box`/`stab` bits included; infinite width and no fibre bound; every quantity a count; zero debt;
      the forward-only liveness fact in its precise sense with no device-discrimination claim.
- [ ] No tuple index stated at any parameters anywhere in the library (grep for an
      `index x = index y → cellAt x = cellAt y` shape returns nothing outside a docstring naming it as
      refuted).
- [ ] `anchorCells_finite` and `anchorCells_ncard_le` untouched (`git diff` on `AnchorLayer.lean` over
      this plan's commits is empty).
- [ ] Every statement that closed in a constrained or `[BLOCKED]` form is recorded as such in
      `docs/theorem-index.md`, in the README paragraph and in the summary, with the filed statement
      named as open — never as landed.
- [ ] **The depth-`0` obligation is honestly represented in the landed tree**: on every branch except
      Phase 11.9's PASS branch followed by a successor round landing it, `CellLEZeroConstOfKappaEq`
      exists in `LadderAgree.lean` as a Prop-valued schema, nothing discharges it, and the theorem
      name `cellLE_zero_const_of_kappa_eq` is claimed by no declaration
      (`grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returns only prose lines; seven
      at this plan's authoring). No phase of this plan consumes the schema as if it were a proved base
      case, and no path-selected or regime-restricted variant is landed under that name.
- [ ] **Route B's refutation is intact and is not restated as a goal**:
      `atomPreservingCountMove_refuted`, `cntAt_eq_of_pend_eq`, `pendFactorsLab_of_atom` and
      `cntAt_eq_of_lab_eq_of_pendFactorsLab` are unmodified; `AtomPreservingCountMove` appears nowhere
      as a goal or as a hypothesis of anything new.
- [ ] **The gate held, in its new form**: no declaration belonging to Phases 11.6, 11.7, 12.2 or 13-18
      exists in the tree unless either `cellLE_zero_const_of_kappa_eq` landed as a theorem first, or
      Phase 11.9 returned REFUTED and the phase is closed `[COMPLETED WITH EXCLUSIONS]` with its
      `#### Reasoned Exclusions` record citing that phase's compiled object. A tree carrying any of
      them over the schema with neither condition met fails this item whatever else is green, and a
      `sorry`, an axiom or a vacuous definition standing in for the base case fails it twice.
- [ ] **The representative widening is a widening and not a strengthening**: `repsCnt`'s range
      argument is `Tc + Tn + 3*P + 2*B + 5` in both factors; `git diff` on `CounterQuotient.lean`
      over this plan's commits shows no change to `ParamsOk`, to `paramsOkK1`-`paramsOkK4`, to the
      four parameter outputs, to `paramsOk_params` or to `not_paramsOk_allZero`; and no fifth
      parameter source exists anywhere. This item and the `transport layer is a layer` item above
      are the two halves of one boundary: the widening is permitted, a parameter change is not.
- [ ] **`rk_of_count_drift` carries no parameter hypothesis**: its extracted signature has no
      `ParamsOk` binder and no size or regime hypothesis, `lean_minimal_hypotheses` reports both of
      its explicit hypotheses load-bearing, and its docstring records why `ParamsOk` must not be
      added.
- [ ] **Five of `Real`'s six conditions are landed, and the sixth is named**: `real_certLocK`,
      `real_certBoxK`, `real_certBiInfK`, `real_certFwdK` and `real_certBwdK` are proved theorems,
      the three relational ones each citing `rk_of_count_drift`; `certStabK` of `Real` is either
      landed by Phase 12.2 or named as OPEN in `docs/theorem-index.md`, the README and the summary.
- [ ] **The refutation survives the widening**: the frozen pre-widening bound lives inside
      `specs/evidence/seam-gluing-ray-product/ladder-reps-bound-refutation.lean` as its own
      `repsCntPre`, each of the three witness tuples carries both its refutation at that bound and
      its positive `RK` at the widened library definition, and witness C is named as the `P = 0`
      half. A probe whose refutation half is stated against the library's own post-widening `RK`
      fails this item, because that statement is false.
- [ ] **No landed theorem decides `RK` at a concrete parameter tuple**, so the widening's
      `M^4`-shaped elaboration cost is not paid anywhere in the library; the `decide`-bearing probes
      stay at small bounds and the general lemma is proved by construction.
- [ ] **Both owed evidence-gate wirings landed**: `bash scripts/check-evidence-probes.sh` exits 0
      and reports 49 wired probes — the 47 measured at this plan's authoring plus
      `ladder-reps-bound-refutation.lean` and `ladder-tight-chain-nonliftability.lean` — stated as
      that delta rather than as an absolute, plus one more for each probe a later phase wires
      (Phase 13 on its refuting branch, Phase 17 unconditionally, Phase 11.8 on its REFUTED
      branch).
- [ ] **The refuted cascade statement's name is unclaimed and its restatement is honest**:
      `grep -rn 'exists_spliced_ladderPath_of_idle_past' FormalSystem/ Tests/` returns only
      docstring prose naming the statement as refuted in the idle-past regime; the three
      `exists_ladderPath_at_region*` declarations share one conclusion, checked by `diff`; that
      conclusion mentions neither `spliceObj` nor `spliceCnt`; and Phase 15 consumes the joined
      form and nothing else from the cascade (grep its proof body).
- [ ] **The maximum-certified-set finding was re-read, not inherited**: Phase 12.6's verdict and the
      derivation or obstruction that decided it appear in `LadderRealize.lean`'s module docstring
      and in that phase's body, naming the specific conjunct; and on a MOVED verdict the
      consequence for `dmax_subset_real` and for `ladderRealized`'s right-hand side is named as open
      in `docs/theorem-index.md`, the README and the summary rather than as settled.
- [ ] **Phase 11.9's closed record is intact**: its recorded statement block, its `#### VERDICT:
      INCONCLUSIVE` section and its `#### Reasoned Exclusions` record are byte-identical to their
      text at this plan's authoring, and the repaired statement set recorded in Phase 12.4's body
      names the landed probe's own theorems rather than re-signing that block.
- [ ] **No phase of this plan named a gate on an abandoned or nonexistent task**: every `Depends on`
      line names only phases of this plan, and the `- **Dependencies**:` field names no open gating
      task. This is the round's own acceptance criterion and is checked by reading the plan.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean` (landed — the CK-free certificate layer)
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` (landed — CK, kappa, repsCnt, RK, the four parameter outputs, ParamsOk with the two-depth (K4), paramsOk_params, not_paramsOk_allZero, relK, DischPathK, certStabK per (q, kappa), certAdmK, Dmax and dmax_maximal; EDITED BY PHASE 12.3 ONLY, and only to widen `repsCnt` and add `rk_of_count_drift` — the parameter layer is untouched by every phase of this plan)
- `specs/evidence/seam-gluing-ray-product/ladder-reps-bound-refutation.lean` (NEW, wired — Phase 12.4: the frozen pre-widening bound, the three refutation witnesses, and their positive counterparts at the widened `RK`)
- `specs/evidence/seam-gluing-ray-product/ladder-idle-past-interface-refutation.lean` (CONTINGENCY ONLY — Phase 11.8's REFUTED branch, listed under that phase's `Files to modify` so a dispatch taking it can commit it; not expected)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` (landed for its rigid-anchor and replacement-admissibility layer, half (i) of the truth-transport layer, the alternative-history construction, the atom-valuation closure agreement, the countdown rigidity, the refuted construction and its refutation, and the STATED obligation CellLEZeroConstOfKappaEq with kappa_eq_of_shift; extended by Phases 11.2 and 11.8 with the pin cascade's two halves and, if Phase 11.9's gate lifts, by the depth induction and cellAt_const_of_kappa_eq; certificate-free and certificate-periodicity-free by construction; 2,300 lines against a 2,400 ceiling at this plan's authoring)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCascade.lean` (CONTINGENCY ONLY — the length remedy of last resort for Phases 11.2/11.8, listed under their `Files to modify` so a dispatch taking it can commit it; not expected)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` (landed for Phase 10's typeOfCl, certChain and LadderCons; extended by Phases 12.1, 12.2 and 13-16 with Real, stab_bit_agree_of_certStabK, the six condition lemmas, real_certAdmK_of_paramsOk, real_subset_dmax, ladderSound, ladderCons_localRun, ladderLift, dmax_subset_real and ladderRealized)
- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` (landed — the pin lemma's lift half, nine declarations)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean`, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `scripts/check-module-invariants.sh` (wiring)
- `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean` (NEW — Phase 11.9's probe; wired on its REFUTED branch only) and `scripts/check-evidence-probes.sh`
- `specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean` (new, wired — Phase 17, gate 8)
- `specs/evidence/seam-gluing-ray-product/ladder-sound-unconstrained-parameter-refutation.lean` (new, wired — ONLY on Phase 13's refuting branch)
- `specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean`, `ladder-cell-agreement-refutation.lean`, `ladder-cell-obligation-refutation.lean`, `ladder-unconstrained-parameter-refutation.lean` (landed, wired, UNMODIFIED by every phase of this plan)
- `specs/761_ladder_realization_theorem/prototype/alt-history-cell-check.lean`, `interior-budget-check.lean`, `step0-budget-check.lean` (landed as prototype records, not promoted and not wired)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `docs/theorem-index.md`, `typst/generated/status.typ`
- `specs/state.json`, `specs/TODO.md`
- `specs/761_ladder_realization_theorem/summaries/10_rk-bounded-representative-widening-summary.md`
- This plan (`plans/10_rk-bounded-representative-widening.md`), superseding `plans/09_tight-chain-gate-regated-graph.md`, which is retained unmodified as the record of the round that re-pointed the phase graph onto an internal decision gate and ran that gate to its INCONCLUSIVE verdict

## Rollback/Contingency

- Each phase is one to seven files and commits per green substep; reverting a phase is reverting its
  commit(s). The new modules are additive: removing a module's import from `RaySummary.lean`,
  `FormalSystem.lean`, the C14 heredoc and the axiom test, and deleting the file, restores the tree.
- If a promoted definition does not compile in the library, compare line by line against the probe —
  it is a compiled oracle. Do not re-derive the proof and do not substitute a different decomposition
  (`plan-compliance.md`). Port the missing helper rather than weakening the statement.
- **The 11-series' contingency structure, as this revision leaves it.** Four phases are ENTERABLE:
  11.2, 11.8, 11.9 and 12.1. If any does not close, mark THAT phase `[BLOCKED]` with the goal state
  recorded, return `partial` with `requires_user_review: true`, and leave the others standing; the
  agreement does not inherit a cascade blocker, because no phase of 11.3-11.7 depends on the cascade.
  Phases 11.6, 11.7, 12.2 and 13-18 are a GATE rather than a contingency, and the gate is now Phase
  11.9 of this same plan — a dispatch finding them gated reports the verdict of 11.9, or that 11.9 has
  not been run, rather than a partial on them.
- **Phase 11.9's three branches, and what each licenses.** On REFUTED, the schema and therefore both
  `cellAt_const_of_kappa_eq` and `ladderRealized` are false, Phases 11.6, 11.7, 12.2 and 13-18 close
  `[COMPLETED WITH EXCLUSIONS]` with records citing the compiled object, the two filed statements are
  named REFUTED everywhere they are recorded, and the remedy is a further `/revise` whose input is
  that object — never a weakened statement under a filed name, never route A, never a raised `Tc`,
  never a further strengthening of `ParamsOk`, and never the positionwise form, which
  `no_positionwise_lift` compiles as FALSE rather than weaker. On PASS, the construction is recorded
  and Phase 11.6's gate can be lifted by a round that lands the base case in the module where the pump
  layer lives — not by this plan, which edits none of those modules. On INCONCLUSIVE, the verdict and
  the resisting sub-claim are recorded and the enterable work is 11.2, 11.8 and 12.1.
- **What this revision's four new phases contribute to the contingency structure.** Phase 12.3 is a
  definitional repair with one mathematical failure mode: if the construction's case analysis does
  not close, mark THAT phase `[BLOCKED]` with the goal state and the stalling sub-case recorded,
  commit the widening on its own with the lemma named as open or revert it as a unit — never leave
  it half-applied — and leave Phases 12.4, 12.5 and 12.6 standing as gated rather than partial.
  Phase 12.4 has no mathematical failure mode at all: its three witnesses are reproduced verbatim in
  the research input and its two gate entries are mechanical, so a failure there is an authoring
  error to fix forward. Phase 12.5 depends on 12.3's lemma being USABLE rather than merely true: if
  one of its three conditions still does not close, close the phase
  `[COMPLETED WITH EXCLUSIONS]` with a record naming the resisting conjunct rather than holding it
  open or weakening `Real`. Phase 12.6 closes on either of its two branches; a derived MOVED verdict
  is a complete outcome and its remedy is a recorded Follow-up plus a further `/revise`, never a
  rollback of the widening.
- **Phase 11.8's restatement has three outcomes, and all three are closable.** It closes on a proof
  of the three interface-level declarations; it closes `[BLOCKED]` with the failing pin pair
  recorded, which Phase 15 inherits as its own contingency; or it closes on a REFUTED branch, with
  the refuting object landed as a wired probe under a new honest name and Phase 15's interface named
  as open. The contingency probe and its gate entry are LISTED under that phase's `Files to modify`
  for exactly that reason. On no branch is anything landed under
  `exists_spliced_ladderPath_of_idle_past`, and on no branch is the `spliceObj`-shaped conclusion
  re-attempted in the idle-past regime.
- **Re-entry after Phase 11.9 reports is a `/revise` act, never an implementer's judgement.** The next
  revision of this plan carries that phase's verdict as a Research Input and decides what Phases 11.6
  and 11.7 then say.
- **The predecessor plan's refuting branches all FIRED, and each outcome is closed rather than
  pending.** Half (ii) of the transport layer is refuted and WITHDRAWN; route B's construction is
  refuted at full generality; and the depth-`0` schema is refuted at a `(K4)` answering only the
  backward window. None of the three was answered by raising `Tc`, adding a parameter, narrowing a
  position, or weakening a statement under a filed name, and none of the three settles the filed
  `cellAt_const_of_kappa_eq` — which is exactly why Phase 11.9 exists.
- **Phase 13 is the statement-level contingency point.** Its three-branch task list is the
  contingency. Adding `hp` to `ladderSound`'s own signature is never an implementer's move; Statement
  Fidelity routes it to the user and to `/revise`. Phase 14 inherits that branch as its own
  `[BLOCKED]` contingency and must not repair it by a `LadderCons` field.
- **Phase 15 is the second mathematical contingency point.** If `ladderLift` does not close, mark it
  `[BLOCKED]` with the goal state recorded and leave Phases 16-18 `[NOT STARTED]`.
- If a phase is `[BLOCKED]` but a strictly weaker, honestly named auxiliary did land, record the
  auxiliary in the phase body, in `docs/theorem-index.md` and in the summary with the filed statement
  named as open. A landed auxiliary never promotes the phase out of `[BLOCKED]`.
- If `state-write.sh` is refused three times on the `specs/.scope-lock` mutex, the record phase closes
  `[PARTIAL]` with the record edits committed and the `state.json` step named as the remainder.
- A rollback that would discard uncommitted work takes a snapshot first: see
  `context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
  out-of-scope override for a deliberate whole-tree case.

### Follow-ups this revision records and does not act on

`/revise` creates no tasks. Two records would be owed, and both are named here rather than filed:

1. **Resumption of the live open-core task rather than a new one.** Task 838
   (`two_sided_open_core_pin_free_pigeonhole`) is `partial`, owns route (a), and raised a
   `user_decision` in its own `.return-meta.json` after its gate's FAIL refuted the premise of the
   answer recorded for it. Its descendants 844, 849 and 850 are `[COMPLETED]` and carry the path-level
   downward inclusion. **No new task is recommended for the open core**: the right move is a decision
   on 838's raised question and a resumption of 838, and this plan's Phase 11.9 is the complementary
   move from this side — the refutation attempt that side has not taken.
2. **A record for re-filing the presentation, on Phase 11.9's REFUTED branch only.** If the schema is
   refuted under `ParamsOk`, `cellAt_const_of_kappa_eq` and `ladderRealized` are both false as filed,
   and what the realization theorem should state instead is a design question this plan cannot answer
   from inside a refutation. The record would own: which statement replaces the fibre equation given
   that the cell is NOT a function of `kappa`'s class; whether presentation (a) survives at all;
   and whether a coarser or finer quotient than `kappa` is the right carrier coordinate. It would NOT
   own route A, which stays unentered. The filed statements' own repair record (task 837,
   `researched`) is adjacent but narrower — it owns the parameter-quantification question, which the
   block above already answers by carrying `hp` — so the two should cross-reference rather than
   subsume one another.
3. **The uncommitted-`nolints.json` carry-forward is DISCHARGED and needs no record**: finding 7 above
   shows all four rows committed at `e379d42c6`, and `scripts/nolints.json` is already in this task's
   `file_scope`. The narrow-remedy route for those four pins is owned by task 840.
4. **A record for the maximum-certified-set finding, on Phase 12.6's MOVED branch only.** If the
   widening's growth of `Dmax` is not bounded by `certStabK` and `certBoxK`, then "every certified
   `R` lies inside `Real`" is weaker than the presentation-decision record states, and the record
   would own: which inclusion fails and at which conjunct; whether `dmax_subset_real` (Phase 15's
   corollary) survives; and whether `ladderRealized`'s right-hand side — a fibre of `Dmax` — still
   states what the realization theorem intends. It would NOT own re-narrowing `repsCnt`, which is a
   prohibited workaround of Phase 12.6.
5. **A context record for the `decide`-refutation pattern this round's input used.** When a recorded
   lemma quantifies over a bounded `Finset` of representatives, the statement is a closed decidable
   proposition at any concrete parameter tuple, so `decide` refutes it outright and no proof search
   is needed; the two practical constraints are the `maxRecDepth`/`maxHeartbeats` ceilings and the
   `M^4` growth in the bound, and the rule is that a `decide` refutation at concrete parameters
   refutes the universally quantified statement while saying nothing about a repaired one. The
   research input recommends it at
   `context/project/lean4/patterns/decide-refutation-of-bounded-claims.md`; `/revise` creates no
   tasks, and a `.claude/**` write would in any case belong in the source store rather than the
   deployed tree.
