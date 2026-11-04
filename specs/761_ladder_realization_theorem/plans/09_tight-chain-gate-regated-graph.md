# Implementation Plan: Task #761

- **Task**: 761 - Ladder realization theorem: `LadderCons` and `ladderRealized` per ladder cell for all φ including box/stab letters
- **Status**: [IMPLEMENTING] (Phases 1-11.1 and 11.3-11.5 closed; Phases 11.2, 11.8, 11.9 and 12.1 the enterable work; Phases 11.6-11.7, 12.2 and 13-18 gated on the open depth-`0` core, which no longer gates on any abandoned record)
- **Effort**: 26.5 hours costable (Phases 1-10, 12.1, 12.2, 13, 14, 16, 17, 18), RE-DERIVED at this revision's authoring by summing this plan's own per-phase **Timing** lines rather than carrying the header figure: 15.5 hours landed (Phases 1-10, at 0.5/1/0.5/1/0.75/1.25/2/3/3.5/2) and 11 hours open (Phases 12.1, 12.2, 13, 14, 16, 17, 18, at 1.5/1/2/1.5/2/1.5/1.5). The total does not move, and the reason is structural rather than lucky: the only COSTABLE phase this revision touches is Phase 12, which is SPLIT into 12.1 (1.5) and 12.2 (1) summing to its recorded 2.5; every other phase this revision adds or re-sequences is NOT COSTABLE. Phases 11, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, the new 11.9 and 15 are NOT COSTABLE — Phases 11, 11.1, 11.3, 11.4 and 11.5 closed against that declaration, the rest are open, and no hour figure is invented for any of them, the new Phase 11.9 included
- **Dependencies**: 760, 775, 805, 806, 819, 820 — all six discharged (760/775 archived; 805/806 `[COMPLETED]`; 819 the presentation decision; 820 the counter-lift gate table), and none of them is reopened or re-planned by this revision. NO OPEN GATING TASK IS NAMED BY THIS PLAN. The predecessor plan named one external gating input, the construction task whose record is now archived at `specs/archive/836_ladder_type_preserving_cell_agreement_construction/` and is `[ABANDONED]` (commits `9b89333f9`, `4d95df657`); that gate is REMOVED by this revision and replaced by Phase 11.9, a decision gate this plan can run itself. The live successor chain on the open core is task 838 (`two_sided_open_core_pin_free_pigeonhole`, status `partial`) and its closed descendants 844, 849 and 850, whose landed work this revision integrates as INPUT rather than as a gate; whether a `state.json` dependency edge to 838 is carried is the orchestrator's call and not this plan's. Phases 11.2, 11.8, 11.9 and 12.1 are gated on nothing open and are enterable now
- **Research Inputs**:
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
- **Artifacts**: plans/09_tight-chain-gate-regated-graph.md (this file; supersedes plans/08_cell-agreement-construction-handoff.md, which is RETAINED UNMODIFIED as the record of the round that split the pin cascade and filed the external gate this revision removes)
- **Reports Integrated**: 01_obligation-repair-and-pump-layer-summary.md; 01_type-preserving-cell-agreement-construction.md; 01_obligation-repair-and-pump-layer.md; phase-10-handoff-20261103T051549Z.md; phase-11-handoff-20261103T053018Z.md; issues.jsonl (836); .decisions.json (836); 01_pin-free-pigeonhole-open-core-summary.md; 01_reanchored-deletion-half-summary.md; 01_forward-slack-exact-shift-summary.md; 01_upfirst-exact-shift-copy-boundary-summary.md; 05_ladder-cell-agreement-construction-refuted-summary.md; phase-11.5-handoff-20261102T215926Z.md; ladder-cell-obligation-refutation.lean; ladder-cell-agreement-refutation.lean
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The filed record asks for a library module carrying `LadderCons`, `ladderCons_localRun` and the
per-cell realization `ladderRealized` for ALL `φ`, `box`/`stab` letters included, on presentation
(a) — the set-valued per-state datum, with `ladderRealized` the FIBRE EQUATION and the
factorization lemma for `CK` its COROLLARY. That decomposition, its agreement-first phase order,
its six recorded Challenge statements and its landed Phases 1-11.1 and 11.3-11.5 all stand
unchanged. **What this revision does is re-sequence the phase graph so that no phase gates on an
abandoned record, and give the one remaining open question a gate this plan can run itself.**

The predecessor decomposition gated Phases 11.6, 11.7 and 12-18 on an external construction task.
That task is `[ABANDONED]`. Its ten closed phases left a large, green, reusable layer and one
`[BLOCKED]` phase, and its two named routes for a successor have since been taken up by a live
chain of tasks whose work is landed in the library. Reading that landed library directly rather
than trusting any summary produces a sharper statement of what is open than "an unknown
construction", and that sharper statement is what makes a gate possible:

- the depth-`0` obligation's UPWARD cell inclusion is landed unconditionally on the pin-free side;
- its DOWNWARD inclusion is landed at the cell level ON THE WITNESSING PATH under a named
  path-level regime, with that regime proved NECESSARY by a compiled counterexample;
- no STATE-level regime-restricted variant of the obligation is claimable, because the compiled
  climbing-register path passes through a state satisfying every state-level hypothesis a consumer
  could carry while violating the regime;
- so the whole residue is one claim, stated in the library's own README as **argued, not
  compiled**: no finite deletion-derivative of the tight (doubling) chain lifts.

Compiling that claim DECIDES this plan's route, because the schema the claim is about is a strictly
weaker instance of this plan's own recorded Challenge statement. Phase 11.9 is that decision gate.

**Definition of done for this round's revision**: a phase graph in which every `[NOT STARTED]`
phase either is enterable now or names a gate that is a phase of this same plan; the four
enterable phases (11.2, 11.8, 11.9, 12.1) each closable on their own; and every criterion
expressed relative to a baseline measured at this plan's authoring rather than as an absolute.

### Research Integration

Every claim below was re-derived at this revision's authoring against the live tree, not carried
from a summary. The discrepancies are reported as findings rather than silently resolved in either
direction, as the revision's constraints require.

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
| 8 | 11.3, 11.8 | 11.1 (11.3); 11.2 (11.8) |
| 9 | 11.4 | 11.3 |
| 10 | 11.5 | 11.4 |
| 11 | 11.9 | 11.5 |
| 12 | 11.6 | 11.5, 11.9 |
| 13 | 11.7 | 11.6 |
| 14 | 12.2 | 12.1, 11.7 |
| 15 | 13 | 12.2 |
| 16 | 14, 15 | 10, 13 (14); 7, 11.8, 11.7, 12.2 (15) |
| 17 | 16 | 13, 15 |
| 18 | 17 | 16 |
| 19 | 18 | 6, 14, 17 |

Phases within the same wave can execute in parallel.

**What is closed, what is enterable, and what is gated.** Waves 1-6 are landed or closed (Phases
1-11); of wave 7 Phase 11.1 is closed; and Phases 11.3, 11.4 and 11.5 are closed, 11.5 with a
`#### Reasoned Exclusions` record. The ENTERABLE work is exactly four phases: Phase 11.2 (the pin
cascade's front half, which waits on nothing), Phase 11.8 behind it (the cascade construction),
Phase 11.9 (the tight-chain decision gate, which waits on Phase 11.5 alone and is therefore
enterable now), and Phase 12.1 (the agreement-free half of `Real`, which waits on Phase 10 alone).
Everything else that is open — Phases 11.6, 11.7, 12.2 and 13-18 — sits behind Phase 11.9's verdict
and, through it, behind the open depth-`0` core.

**What this revision changed about the graph, phase by phase.**

- **Phases 1-10, 11, 11.1, 11.3, 11.4 and 11.5 are carried forward closed and unmodified in
  substance.** Their status markers, `Timing` lines, `Depends on` sets, NOT COSTABLE declarations
  and `#### Reasoned Exclusions` records are preserved. Their bodies below are condensed to the
  closure record; the full as-executed bodies stay readable in
  `plans/08_cell-agreement-construction-handoff.md`, which this plan supersedes without editing.
- **Phase 11.2 keeps its three deliverables and its `Depends on` set (7, 11), and its CITATION
  DISCIPLINE is corrected** by findings 8, 9 and 10. Nothing about its statements, its prohibitions
  or its sizing-as-a-count obligation moves.
- **Phase 11.8 keeps its construction, its sizing and its `Depends on` set (11.2)**, with the same
  three corrections. It is still Phase 15's single consumer of the cascade.
- **Phase 11.6's gate is RE-POINTED.** It no longer gates on an external task; it gates on Phase
  11.9 of this plan plus Phase 11.5. Its Goal, tasks, prohibitions, sizing and verification are
  otherwise unchanged, including the first verification item.
- **Phase 11.7 is unchanged and stays gated transitively**, through 11.6.
- **Phase 11.9 is NEW**: the tight-chain decision gate, which compiles the one claim the live
  library records as argued rather than compiled, and whose verdict decides this plan's route.
- **Phase 12 is SPLIT into 12.1 and 12.2**, on the same reasoning the predecessor revision applied
  to the pin cascade: of Phase 12's nine deliverables, six need no agreement at all, so a dispatch
  arriving against a gated board can close real work instead of reporting a partial. 12.1 takes
  `Real`'s definition, `stab_bit_agree_of_certStabK`, the four monotone conditions and `certBoxK`;
  12.2 takes `certStabK`, the assembly and the inclusion, which consume Phase 11.7. The recorded 2.5
  hours split 1.5/1 and the total does not move. No statement, candidate choice or prohibition
  changes; only the commit boundary.
- **Phases 13-18 are unchanged in content.** Phase 13's `Depends on` becomes 12.2 and Phase 15's
  becomes `7, 11.8, 11.7, 12.2`, which is the same edge re-pointed at the half of Phase 12 that
  actually carries what they consume.

**Why the gate is a phase of this plan and not another external task.** The predecessor filed the
construction externally for a stated reason: the construction was not known, and a phase cannot be
written against an unidentified construction without inventing one. That reason has expired.
Finding 14 shows the residue is not a construction at all but a DECISION about a named statement,
and finding 15 shows that the statement in question is a weaker instance of this plan's own
recorded Challenge statement — so the decision is this plan's to take, Statement Fidelity routes a
wrong recorded statement to `/revise`, and `/revise` is where this plan is being written. The
deliverable is an evidence probe plus one gate-script entry, both inside this task's own declared
`file_scope` and outside every module the live successor task declares.

**The final phase is unchanged.** Phase 18 is the highest-numbered phase, nothing depends on it, and
it depends — directly or transitively — on every other phase, the new 11.9 and 12.1 included
(11.9 through 11.6, 11.7, 12.2, 13 and 14; 12.1 through 12.2), which is what makes its `full` gate
meaningful. Its edges to Phases 6 and 14 are there for the same reason the predecessor recorded.

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

### Phase 11.8: The Pin Cascade, The Construction — Replacement Admissibility in the Remaining Regime [NOT STARTED]

**ENTERABLE BEHIND PHASE 11.2, AND GATED ON NOTHING OPEN.** Re-confirmed at this revision's authoring:
its deliverable `exists_spliced_ladderPath_of_idle_past` exists nowhere in the library, so nothing the
abandoned round or the live successor chain landed has pre-empted it.

**Goal**: Discharge `exists_spliced_ladderPath`'s two explicit pin hypotheses in the regime the landed
`exists_spliced_ladderPath_of_pend_past` does NOT cover — the regime where an idle position lies in the
path's past — by lengthening the preceding idle runs along with the spliced region so that pin
compatibility is re-established, sized as Phase 11.2 states it. The deliverable is
`exists_spliced_ladderPath_of_idle_past`, the companion of the landed lemma, after which the
admissibility half of the counter-lift lemma is unconditional in both regimes.

**This phase is NOT dropped and not optional**: `exists_spliced_ladderPath` carries its pin hypotheses
explicitly and only `exists_spliced_ladderPath_of_pend_past` discharges them, so the admissibility half
of the counter-lift lemma stays conditional in one of the two regimes until this phase closes, and (C')
— Phase 15, its single consumer — needs it unconditional. The agreement does not depend on it: no phase
of 11.3-11.7 does, because the cell-level route spends no pin budget.

**Tasks**:
- [ ] State the cascade: given a splice at `a` of length `l` and an idle position `p ≤ a` on the
      original path, construct a second walk that repeats the segment AND lengthens each idle run
      between `p` and `a` so that every pin inequality of `exists_spliced_ladderPath` holds. The
      iteration is well-founded by Phase 11.2's finiteness lemma, which is CITED here and not
      re-proved.
- [ ] Size the construction by CITING Phase 11.2's sizing statement, never re-deriving it. **Findings
      8 and 9 apply exactly as in Phase 11.2**: `cascadeBound` is the only importable anchor;
      `forward_window`, `backward_constraint`, `region_doubling`, `doubling_attained` and
      `iter_doubling` are probe-level and citable only in a docstring, by path; and
      `two_pow_card_prodState_le_Tc` is above this module in the import DAG and unavailable. The bound
      stays a COUNT (guardrail (c)): no complexity claim.
- [ ] Prove `exists_spliced_ladderPath_of_idle_past`, discharging both `hpins` and `hn₀` of
      `exists_spliced_ladderPath` in this regime, with the same conclusion shape the landed
      pending-forever companion has — so that one interface serves both regimes for Phase 15.
- [ ] **Keep the module under its length ceiling**, by the same pre-authorized primary remedy and the
      same listed contingency as Phase 11.2.
- [ ] Wire the new declarations (axiom pins, docstring, generated inventory blocks, `status.typ`). No
      C14 entry and no theorem-index row: this phase lands no Goal.

**Prohibited workarounds**: do NOT weaken `exists_spliced_ladderPath` by dropping or relaxing a pin
hypothesis; do NOT replace the cascade by raising `Tc` or `Tn`; do NOT assume the number of pinned
regions is bounded by a constant, and do NOT re-prove Phase 11.2's finiteness inline instead of citing
it; do NOT reach for any certificate object or certificate-side periodicity; do NOT edit
`LadderPump.lean`, `LadderPin.lean` or `LadderChain.lean`; and do NOT use `sorry`, `axiom` or a vacuous
definition.

**Timing**: NOT COSTABLE. The construction is the one `(K2)`'s `cascadeBound` sizes, exponential in the
number of pinned regions; no estimate is offered and none is to be invented.

**Depends on**: 11.2

**Verification Tier**: interface

**Tier Justification**: The construction and its conclusion are about `IsLadderPath`,
`objAt`/`cntAt`/`nxtAt` and the splice, all inside `LadderAgree.lean` over the landed `RunLayer.lean`
pin-lemma interface, so the covering check is the guarded scoped build of that one module plus its
axiom test
(`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree`
and the same for `BimodalTest.Metalogic.KTypeSummaryAxiomTest`); no statement of this phase mentions
`tpOf`, `cellAt` or any certificate object.

**Scope Hypothesis**: One module plus three wiring files; roughly one construction and one conclusion
lemma over Phase 11.2's three facts, the count to be MEASURED at phase close rather than trusted from
here. The carried figures and their sources are Phase 11.2's: the module's 2,300 lines and its 2,400
baseline, both measured at this plan's authoring. If the cascade cannot be closed, the phase is
`[BLOCKED]` and Phase 15 inherits that as its own contingency — the agreement does not. Never a relaxed
pin hypothesis and never a quiet narrowing of a filed statement.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - the cascade construction and exists_spliced_ladderPath_of_idle_past, and the `longFile` baseline if the primary length remedy is taken
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCascade.lean` - CONTINGENCY ONLY, listed so a dispatch taking the length remedy of last resort can commit it
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - CONTINGENCY ONLY: the import edge
- `FormalSystem.lean` - CONTINGENCY ONLY: the import edge
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom-profile entries for the new declarations
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the generated inventory blocks
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- Guarded scoped build of `LadderAgree.lean` and of the axiom test each exit 0 with 0 warnings, with an explicit `--timeout` and the bounded single-call idiom.
- `exists_spliced_ladderPath_of_idle_past` has the same conclusion shape as the landed `exists_spliced_ladderPath_of_pend_past`, checked by `diff` of the two extracted conclusion texts.
- The proof CITES Phase 11.2's finiteness and sizing lemmas by name (grep the proof body for them) rather than restating either.
- **No proof term names a probe-level or above-the-DAG identifier**: the grep of Phase 11.2's corresponding item returns only docstring or comment lines, and the scoped build is the mechanical check.
- `exists_spliced_ladderPath` is UNMODIFIED: `git diff` shows no change to its statement. `pinCompat_of_ladderPath` and `atomPreservingCountMove_refuted` are likewise unmodified.
- The sizing stays a count: the guardrail (c) grep finds nothing outside a sentence naming the quantity as a count.
- The length ceiling holds, by the same check Phase 11.2 names; if the contingency module was taken, it and both import edges are in the SAME commit.
- The certificate-freedom grep (the extended form) over `LadderAgree.lean` returns nothing, and the import list is unchanged.
- `#print axioms` on every new declaration: no `sorryAx`, no custom axiom, no `native_decide`. `bash .claude/scripts/lean-sorry-census.sh FormalSystem Tests` exits 0 with `sorry_count: 0`; module-scoped vacuous grep count 0; the repository-wide vacuous grep and `^axiom ` counts unchanged from their measured baselines.
- `bash scripts/check-module-invariants.sh`, `bash scripts/typst-sync-check.sh`, `bash scripts/readme-lint.sh`, `bash scripts/check-evidence-probes.sh` and `bash .claude/scripts/check-task-references.sh --quiet` each exit 0.
- If the phase closes `[BLOCKED]`: the goal state is recorded, Phase 15's inherited contingency is named in the handoff, Phase 11.2's landed facts are left standing, and no pin hypothesis anywhere has been relaxed.

---

### Phase 11.9: The Tight-Chain Decision Gate — Compile the One Argued Claim and Decide the Depth-`0` Schema [NOT STARTED]

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
- [ ] Author the probe at `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean`.
      Re-declare the tight doubling chain and its register facts verbatim from the archived prototypes
      `specs/archive/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean`
      and `specs/838_two_sided_open_core_pin_free_pigeonhole/prototype/pin-free-side.lean`
      (`tightChain_isLadderPath`, `tightChain_pin`, `tightChain_slack_zero`, `tightChain_pins`,
      `tightChain_pin_count_ge`), and define `delIterWalk` beside them. Compile standalone through the
      build guard.
- [ ] Attempt `tightChain_deletion_derivative_not_ladderPath` at the statement recorded above,
      token-for-token. The obstruction to localize is the one the successor chain already localized at
      the path level: feeding the deleted walk to the assembly leaves a register demand exceeding what
      `1`-Lipschitz pin compatibility supplies by exactly the amount deleted, and the chain has slack
      exactly `0` at every gap between pins. Record the goal state if it does not close.
- [ ] **DECISION GATE.** Read the verdict and take exactly one branch:
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
- [ ] Record the verdict in the durable carriers only: this phase's own body, the dispatch handoff,
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

---

### Phase 12.1: `Real` and Its Agreement-Free Conditions [NOT STARTED]

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
- [ ] Define `Real step pend lab φ Tc Tn P B fwd bwd : Set (Q × ClType φ × CK Tc Tn P B)` as the set
      of `(q, T, κ)` for which some admissible ladder history `σ` and some `z` realize `T` at a state
      `⟨(q, c, n), h⟩` with `kappa Tc Tn P B (c, n) = κ`. Docstring: this is the set-valued per-state
      datum of presentation (a), and `Real` is not an index — `Dmax` is.
- [ ] Land `stab_bit_agree_of_certStabK` here, verbatim from the phase-11 handoff: any
      `certStabK`-certified set collapses the `⊡` bits across a `(q, κ)`-class. It is a statement about
      certified sets, which is why it belongs in the certificate-side module and not in
      `LadderAgree.lean`.
- [ ] Prove the four monotone conditions of `Real` — `certLocK`, `certBiInfK`, `certFwdK`, `certBwdK` —
      from the structure of an admissible ladder history: local coherence and the `untl`/`snce` links
      along an actual history, with the counter classes following `RK` by `Count`/`Drift`, and both
      fulfilment arms EXISTENTIAL.
- [ ] Prove `certBoxK` of `Real`. This is the condition candidate (1) failed, and it is reachable for
      `Real` exactly because `box_mem_tpOf_iff`'s quantifier is GLOBAL.
- [ ] **Do not state or prove `certStabK` of `Real`, `real_certAdmK_of_paramsOk` or `real_subset_dmax`
      here.** All three consume the agreement and are Phase 12.2's; the split exists so that this phase
      closes without them.
- [ ] **Do not state or prove `Dmax ⊆ Real` in this phase or in 12.2.** The reverse inclusion is the
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

---

### Phase 12.2: `Real`'s Certification Under the Parameter Conditions, and `Real ⊆ Dmax` [NOT STARTED]

**GATED THROUGH PHASE 11.7, AND SO THROUGH PHASE 11.9. SPLIT OUT BY THIS REVISION FROM THE PREDECESSOR
PLAN'S PHASE 12; THE AGREEMENT-CONSUMING HALF, CONTENT UNCHANGED.**

**Goal**: Prove `certStabK` of `Real` from Phase 11.7's agreement, assemble the six conditions as
`real_certAdmK_of_paramsOk`, and conclude `real_subset_dmax` by `dmax_maximal`.

**Tasks**:
- [ ] **Prove `certStabK` of `Real` from Phase 11.7's agreement.** Both directions reduce, by
      `stab_mem_tpOf_iff_cell`, to the cells of class-equivalent states agreeing — which is
      `cellAt_const_of_kappa_eq`, available as a theorem rather than as an obligation.
- [ ] Assemble the six conditions as `real_certAdmK_of_paramsOk : ParamsOk step pend lab φ Tc Tn P B →
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

**Depends on**: 12.1, 11.7

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

**GATED THROUGH PHASES 11.7 AND 12.2.** Content unchanged by this revision; its `Depends on` is
re-pointed from Phase 12 to Phase 12.2. **One wiring consequence of this revision to carry**: if Phase
11.2 or 11.8 took its pre-authorized contingency and landed the cascade in `LadderCascade.lean`, this
phase must import that module; the phase's first task is to check which module the cascade landed in.

**Goal**: Prove `ladderLift` at its pinned signature in PUMPING form, and conclude `Dmax ⊆ Real` as its
corollary with the landed `dmax_certBiInfK`.

**Tasks**:
- [ ] Check which module the cascade landed in and import it.
- [ ] Prove `ladderLift` in pumping form, CITING Phase 11's machinery declarations and Phase 11.8's
      `exists_spliced_ladderPath_of_idle_past` rather than re-proving either, so that one interface
      serves both regimes.
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
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderLift, dmax_subset_real, and the cascade module's import if its contingency was taken
- `docs/theorem-index.md` - the row
- `scripts/check-module-invariants.sh` - the matching C14 heredoc entry
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the axiom pin
- `typst/generated/status.typ` - the regenerated line counts

**Verification**:
- The guarded scoped build exits 0 with 0 warnings and the unscoped guarded build exits 0 at the end of the phase; `bash scripts/check-module-invariants.sh` exits 0 with the new C14 entry and index row.
- The signature matches the Challenge block token-for-token by direct `diff`.
- The proof CITES Phase 11's machinery and Phase 11.8's companion by name (grep the proof body) rather than re-proving either.
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

**THE FINAL PHASE.** Content unchanged by this revision except that its records pass now also owes the
Phase 11.9 verdict's record in the README, which Phase 11.9 deliberately deferred to here.

**Goal**: Bring every record current, run the full gate set, and write the round's summary.

**Tasks**:
- [ ] Bring the RaySummary README's depth-`0` status paragraph current with Phase 11.9's verdict and
      with whatever Phases 11.2, 11.6, 11.7, 11.8, 12.1, 12.2 and 13-17 landed. Check for a concurrent
      edit by the live successor chain before editing, and preserve it.
- [ ] Guardrail read-through of every header and record paragraph: closure-indexed letters with
      `box`/`stab` bits included; infinite width and no fibre bound; every quantity a count; zero debt;
      the forward-only liveness fact in its precise sense with no device-discrimination claim.
- [ ] Grep every touched record for `truncate`, `Fin (B+1)`, `min c B`, `clip (n`, and require each
      occurrence to sit inside a sentence naming it as deleted, refuted or research-level.
- [ ] Run the full gate set and record each exit status directly.
- [ ] Write the summary at
      `specs/761_ladder_realization_theorem/summaries/09_tight-chain-gate-regated-graph-summary.md`.

**Prohibited workarounds**: do NOT state a cost figure for a NOT COSTABLE phase; do NOT re-introduce the
deleted index in any record; do NOT narrate a record's own draft history.

**Timing**: 1.5 hours

**Depends on**: 6, 14, 17

**Verification Tier**: full

**Tier Justification**: This is the final phase; its `full` tier is mandated by the invariant rather
than chosen, and it observes every phase of the plan directly or transitively.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the brought-current records, including Phase 11.9's verdict
- `docs/theorem-index.md` - the final row set, with every open or blocked statement named as OPEN
- `specs/761_ladder_realization_theorem/summaries/09_tight-chain-gate-regated-graph-summary.md` - the summary
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
| Wired evidence probes | 47 (46 `WIRED` entries plus 1 `WIRED_REPO` entry) | counted from the two arrays in `scripts/check-evidence-probes.sh` |
| `LadderAgree.lean` length / ceiling | 2,300 lines / `set_option linter.style.longFile 2400` | `wc -l` and `grep -n longFile` on the module |

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
- [ ] **No phase of this plan named a gate on an abandoned or nonexistent task**: every `Depends on`
      line names only phases of this plan, and the `- **Dependencies**:` field names no open gating
      task. This is the round's own acceptance criterion and is checked by reading the plan.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean` (landed — the CK-free certificate layer)
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` (landed — CK, kappa, RK, the four parameter outputs, ParamsOk with the two-depth (K4), paramsOk_params, not_paramsOk_allZero, relK, DischPathK, certStabK per (q, kappa), certAdmK, Dmax and dmax_maximal; edited by no phase of this plan)
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
- `specs/761_ladder_realization_theorem/summaries/09_tight-chain-gate-regated-graph-summary.md`
- This plan (`plans/09_tight-chain-gate-regated-graph.md`), superseding `plans/08_cell-agreement-construction-handoff.md`, which is retained unmodified as the record of the round that split the pin cascade and filed the external gate this revision removes

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
