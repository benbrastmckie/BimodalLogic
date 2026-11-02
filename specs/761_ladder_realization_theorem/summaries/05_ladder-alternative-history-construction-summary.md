# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem: `LadderCons` and `ladderRealized` per ladder cell for all φ including box/stab letters
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-02T20:33:27Z
- **Completed**: 2026-11-02T21:05:00Z
- **Effort**: ~0.5 hours
- **Dependencies**: 760, 775, 805, 806, 819, 820 — all six discharged
- **Artifacts**: plans/07_cell-level-agreement-route.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 11.3 of the cell-level agreement route is `[COMPLETED]`: the alternative-history
construction is promoted out of the prototype and into the library as ten named, exported,
gate-covered declarations, GENERALISED away from the prototype's three-state fixture to an
arbitrary object. The construction holds BOTH of a ladder path's counters fixed and relabels the
WALK — the opposite direction from the refuted pumping surgery, which moves the countdown and so
must move the walk with it. Its payoff is that a ladder state has more histories through it than
its own path's, so the cell at that state is in general strictly larger than the type its own
history realizes. That is the freedom the retired route had no analogue of, and it is why the
cell-level reading of `cellAt_const_of_kappa_eq` is untouched by the splice-type refutation.

No type-transport claim is made anywhere, and none is implied. The construction ENLARGES a cell
rather than preserving a type.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` — +252 lines. Ten new
  declarations plus a fixture:
  - `altWalkPath` — the alternative path: a ladder path's two counters carried on a different
    object walk, the `Adm` side condition transporting through the single hypothesis
    `hpend : ∀ v, pend (w' v) = pend (objAt g v)`.
  - `objAt_altWalkPath`, `cntAt_altWalkPath`, `nxtAt_altWalkPath` — the three accessor readings,
    all `rfl`; the object is the new walk, both counters are the ORIGINAL's verbatim.
  - `altWalkPath_isLadderPath` — the general form of the prototype's `altPath_isLadderPath`: the
    `step` clause is the hypothesis, and the idle-zero clause, `Drift` and `Count` all transfer
    through the pend equality with the original's own `cntAt`/`nxtAt`.
  - `altWalkPath_eq_of_objAt_eq` — the general form of `altPath_eq_of_ne`, stated POSITIONWISE on
    `w' v = objAt g v` with conclusion state IDENTITY (`= g v`), by `Subtype.ext`. No finiteness,
    no "off a finite set", no cardinality side condition.
  - `mem_cellAt_of_altWalkPath` — the cell-level corollary, by instantiating the landed
    `mem_cellAt_ladder_iff` and `exists_hist_of_isLadderPath` at `altWalkPath`.
  - The non-vacuity fixture (`AltQ`, `altPend`, `altStep`, `altW`, `altC`, `altW'`) with
    `altStep_true`, `altPend_altW_of_le`, `altPend_altW_of_ge`, `le_zero_of_altPend_altW`,
    `altNoRegionStart`, `altW'_zero`, `altW_zero`, `altPend_altW'`, `exists_altLadderPath`, and
    the headline `altWalkPath_not_vacuous`.
  - One new top-level docstring section, `## The alternative-history freedom, and what it does
    and does not give`, plus `set_option linter.style.longFile 1800` with its explanatory comment
    (the module reached 1700 lines, past the package-wide 1500 limit).
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — +75 lines. A new
  `Requirement (W): the alternative-history construction` block: its documentation paragraph, the
  "what these pins certify and what they do not" paragraph, and ten `#guard_msgs`-wrapped
  `#print axioms` pins.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`,
  `FormalSystem/Metalogic/README.md`, `README.md` — the three generated inventory blocks resynced
  by `check-module-invariants.sh --emit-inventory`.
- `typst/generated/status.typ` — the two line counts resynced by `typst-status-counts.sh`
  (`formalsystem-line-count` 371441 → 371693, `tests-line-count` 24902 → 24977).

## Decisions

- **The generalisation is to one hypothesis, not two.** The prototype states its construction
  through `hobj : ∀ v, objAt g v = wS v` plus the fixture lemma `pendS_w2`. The library form
  replaces both with `hpend : ∀ v, pend (w' v) = pend (objAt g v)` alone. That made every proof
  SHORTER than the fixture's, because the pend equality is exactly and only what each `Rlad`
  clause consumes — the generalisation was a simplification, not a cost.
- **A fresh non-vacuity fixture, and a stronger witness.** The prototype's fixture carries
  `fwdS`/`bwdS` seriality, the formula `chiS` and two truth readings that the non-vacuity
  statement does not consume, so a fresh three-state fixture was authored instead of transcribed.
  Its walk is pending on `(-∞, 0]` and idle from `1` on, lifted through the landed
  `exists_ladderPath_of_walk` with both pin hypotheses discharged vacuously by `altNoRegionStart`.
  `altWalkPath_not_vacuous` carries `altPend (objAt g 0) = true` as a conjunct, so the relabelled
  position at which the two paths differ is PENDING — the witness is not confined to the
  degenerate all-idle regime where every countdown is pinned to `0`.
- **The two budget prototypes land nothing, by the phase's own direction.**
  `prototype/step0-budget-check.lean` and `prototype/interior-budget-check.lean` are RETAINED AS
  PROTOTYPE RECORDS and contribute zero library declarations. Both recorded reasons hold as
  written: no consumer in Phases 11.3-11.7, and landing `interior-budget-check.lean`'s
  `budget_hierarchy` in `LadderAgree.lean` would break this module's certificate-freedom grep,
  `ClType` being one of the grep's own identifiers.
- **The docstring paragraph is its own section, not a paragraph inside half (i).** It states what
  the construction does NOT give, which belongs beside the transport layer rather than inside it.

## Plan Deviations

- **Phase 11.3 non-vacuity task** altered: a fresh three-state fixture rather than a
  transcription of the prototype's, and the witness strengthened so the differing position is
  PENDING. Annotated inline on the plan's checklist item.
- **Phase 11.3 wiring task** altered: the docstring paragraph added as its own top-level section
  rather than inside the existing half-(i) section, plus one unanticipated file-scope addition
  (`set_option linter.style.longFile 1800` with its explanatory comment, the same in-repo pattern
  `Periodic.lean` already uses). Annotated inline on the plan's checklist item.
- **Scope Hypothesis**: predicted seven declarations; ten landed. The three extra are fixture
  lemmas carrying the non-vacuity witness, two of which are axiom-pinned with it. The predicted
  "one module plus three wiring files" held exactly.
- Phase 11.2 was NOT entered. It is `[NOT STARTED]`, off the critical path by this plan's own
  re-sequencing (its single consumer is Phase 15), and Phase 11.3's `Depends on` set names only
  11.1, which was already closed.

## Verification

- Build: Success. Guarded full `lake build`: guard exit 0, 2892 jobs, 0 `error:` and 0 `warning:`
  across both captured streams, and `.olean` newer than source for both touched modules — all
  three tiers of the verdict bar. Guarded scoped builds: `LadderAgree` exit 0 / 1966 jobs / 0
  warnings; `BimodalTest.Metalogic.KTypeSummaryAxiomTest` exit 0 / 2361 jobs / 0 warnings.
- Sorry count: 0 (`lean-sorry-census.sh` over all eight resolved source roots).
- Vacuous count: 1 — UNCHANGED from the dispatch's starting commit, and the known false positive
  the plan's own "Two Plan-Criterion Corrections" records.
- Axiom count: 14 — UNCHANGED. `grep -c '^axiom '` on `LadderAgree.lean` at `HEAD`: 0, and the
  new code adds none.
- `#print axioms` on all ten new declarations: six on NO axioms at all (`altWalkPath`, its three
  accessor readings, `altWalkPath_isLadderPath`, `altWalkPath_eq_of_objAt_eq`); `altPend_altW'`
  on `[propext, Quot.sound]`; `exists_altLadderPath`, `altWalkPath_not_vacuous` and
  `mem_cellAt_of_altWalkPath` on `[propext, Classical.choice, Quot.sound]`. No `sorryAx`, no
  custom axiom, no `native_decide`.
- Certificate-freedom grep on `LadderAgree.lean`
  (`certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|cohIdle|satThreshold|satPeriod`):
  ZERO occurrences. Import list UNCHANGED (`git diff` shows no `import` line added or removed).
- `git diff --stat` on `CounterQuotient.lean`: EMPTY. No parameter added, no parameter source
  strengthened, `ParamsOk` untouched.
- `check-module-invariants.sh`: ALL CHECKS PASSED, exit 0 (its check C1 is an independent full
  `lake build`). `check-evidence-probes.sh`: exit 0, all 45 wired probes compile, the refutation
  probe unmodified. `typst-sync-check.sh`: PASS, all 4 checks green. `readme-lint.sh`: PASS.
  `check-task-references.sh`: 0 unexempted occurrences outside `specs/`.
- `altWalkPath_eq_of_objAt_eq` read at its signature: hypothesis is positionwise
  (`w' v = objAt g v`), conclusion is state IDENTITY (`altWalkPath g w' hpend v = g v`), not
  class-equivalence.
- Tests: Passed (the axiom test target builds clean; every pin is a `#guard_msgs` assertion).
- Files verified: Yes.
- No `sorry`, axiom, vacuous definition, trace-level `Presented` hypothesis, finite-fibre or
  finite-width retreat, positionwise narrowing, raised `Tc`, or conditional restatement of the
  refuted half (ii) anywhere in the tree.

## Impacts

- Phase 11.4 (`Depends on`: 11.3) is now unblocked, and with it the chain 11.5 → 11.6 → 11.7 that
  carries `cellAt_const_of_kappa_eq`, on which Phases 12 and 15 wait.
- `mem_cellAt_of_altWalkPath` is the mechanical form of why the cell-level route survives the
  splice-type refutation: a cell is the set of types realized by ALL histories through a state,
  the refutation compares two particular histories, and this corollary names histories neither of
  them supplies. Any later round tempted to read the refutation as a cell-level obstruction now
  has a compiled answer rather than prose.
- The prototype `alt-history-cell-check.lean` is now redundant as a source of library content, but
  is retained as the compiled oracle the generalisation was checked against. It is still not a
  wired probe and still not gate-covered; its content IS, in generalised form, through the axiom
  test and the module invariants.

## Follow-ups

- Phase 11.2 (the pin cascade) remains open and un-entered. Nothing in 11.4-11.7 waits on it;
  Phase 15 ((C'), the pumping completeness) does, and inherits its contingency.
- No type-level comparison between an alternative history and the original is landed or attempted.
  Phase 11.4's atom-valuation agreement is where that comparison begins, and it begins from the
  atom layer, not from a splice.
- The module is at 1700 lines against a local ceiling of 1800. The next phase to add substantial
  content to `LadderAgree.lean` should expect to split it or raise the ceiling again.

## References

- specs/761_ladder_realization_theorem/plans/07_cell-level-agreement-route.md — the live plan,
  Phase 11.3
- specs/761_ladder_realization_theorem/prototype/alt-history-cell-check.lean — the compiled
  oracle the generalisation follows
- specs/761_ladder_realization_theorem/handoffs/phase-11.3-handoff-20261102T204919Z.md — this
  round's phase handoff
- specs/761_ladder_realization_theorem/summaries/06_ladder-splice-type-refutation-summary.md —
  the refutation round whose fallback this route is
- specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean — the wired probe
  refuting half (ii)
