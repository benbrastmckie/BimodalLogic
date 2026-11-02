# Phase 11.3 Handoff — The Alternative-History Construction LANDED, Generalised

- **Dispatch**: seq 21, session `sess_1793651515_3f23fb`
- **Plan**: specs/761_ladder_realization_theorem/plans/07_cell-level-agreement-route.md
- **Pre-write re-read obligation**: FIRED and found NO fresh revision. `.plan-revised.json`
  carries `revised_at 1793651289`, EARLIER than this dispatch's `dispatch_start_ts 1793651539`,
  so the dispatch file's own Phase 11.3 excerpt is current; Phase 11.3's section was re-read in
  full before the first edit and is unchanged.
- **Phase 11.3**: `[COMPLETED]`. Phase 11.2 remains `[NOT STARTED]` (off the critical path by
  this plan's own re-sequencing — its single consumer is Phase 15); Phases 11.4-11.7 and 12-18
  remain `[NOT STARTED]`.

## Immediate next action

**Phase 11.4, the atom-valuation closure agreement** (`Depends on`: 11.3, now discharged). The
construction Phase 11.4 consumes is landed and gate-covered: `altWalkPath` with its three
accessor readings, `altWalkPath_isLadderPath`, `altWalkPath_eq_of_objAt_eq` and
`mem_cellAt_of_altWalkPath`, all in
`FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`.

Phase 11.2 is independently enterable at any time and nothing in 11.4-11.7 waits on it.

## What landed this dispatch

Ten declarations in `LadderAgree.lean`, all axiom-pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`.

**The construction, generalised away from the fixture.** The prototype
(`specs/761_ladder_realization_theorem/prototype/alt-history-cell-check.lean`) states its
construction against the three-state object through `hobj : ∀ v, objAt g v = wS v` plus the
fixture lemma `pendS_w2`. The library form replaces both with ONE hypothesis,
`hpend : ∀ v, pend (w' v) = pend (objAt g v)`, and that generalisation made every proof SHORTER
than the fixture's, because the pend equality is exactly and only what each `Rlad` clause
consumes:

- `altWalkPath g w' hpend v = ⟨(w' v, cntAt g v, nxtAt g v), _⟩` — the original path's BOTH
  counters carried on a different object walk; the `Adm` side condition transports through
  `hpend` alone.
- `objAt_altWalkPath`, `cntAt_altWalkPath`, `nxtAt_altWalkPath` — all three by `rfl`.
- `altWalkPath_isLadderPath` — the `step` clause is the hypothesis `hstep`; the idle-zero clause,
  `Drift` and `Count` all transfer with the original's own `cntAt`/`nxtAt`.
- `altWalkPath_eq_of_objAt_eq` — POSITIONWISE on `w' v = objAt g v`, conclusion state IDENTITY
  (`altWalkPath g w' hpend v = g v`), proved by `Subtype.ext`. No finiteness, no "off a finite
  set", no cardinality side condition.
- `mem_cellAt_of_altWalkPath` — the cell-level corollary, by instantiating the landed
  `mem_cellAt_ladder_iff` and `exists_hist_of_isLadderPath` at `altWalkPath`.

**Non-vacuity, and it is stronger than the task asked.** A fresh three-state fixture
(`AltQ`/`altPend`/`altStep`/`altW`/`altC`/`altW'`) rather than a transcription of the prototype's,
because the prototype's carries `fwdS`/`bwdS` seriality, the formula `chiS` and two truth readings
that the non-vacuity statement does not consume. The fixture's walk is pending on `(-∞, 0]` and
idle from `1` on with the countdown `Count` forces, lifted through the landed
`exists_ladderPath_of_walk` with BOTH pin hypotheses discharged vacuously (`altNoRegionStart`:
the walk has no region start). `altWalkPath_not_vacuous` then exhibits the ladder path, the
relabelling, the `step` clause, and — the strengthening — `altPend (objAt g 0) = true`, so the
relabelled position at which the two paths differ is PENDING. The witness is therefore not
confined to the degenerate all-idle regime where every countdown is pinned to `0`.

## What this does and does NOT give — said sharply so no later round over-reads it

GIVES: a ladder state has MORE histories through it than its own path's, so the cell at that
state contains the types those histories realize, and in general is strictly larger than the type
its own history realizes. That is the freedom the retired pumping route had no analogue of, and
it is why the cell-level reading of `cellAt_const_of_kappa_eq` is strictly weaker than pointwise
type equality along a chosen pair of paths.

DOES NOT GIVE: any type-level comparison whatsoever. No claim that the alternative history
realizes the SAME type as the original — in general it does not, and the construction ENLARGES
the cell rather than preserving a type. It is NOT a repair of half (ii), which stays refuted
rather than open; it is not a conditional, positionwise-narrowed or raised-`Tc` restatement of it;
and it supplies no step of an induction over a closure. It proves nothing about
`cellAt_const_of_kappa_eq`, `ladderSound`, `ladderLift` or `ladderRealized`. No bound; every
quantity named is a count.

## The two budget prototypes: disposition RECORDED, nothing landed

`specs/761_ladder_realization_theorem/prototype/step0-budget-check.lean` and
`specs/761_ladder_realization_theorem/prototype/interior-budget-check.lean` are RETAINED AS
PROTOTYPE RECORDS and contribute ZERO library declarations, exactly as the phase task list
directs. Both reasons hold as written: no consumer (no phase of 11.3-11.7 spends a `(K2)` budget
or runs the `(objAt v, tpOf v)` pigeonhole), and landing `interior-budget-check.lean`'s
`budget_hierarchy` in `LadderAgree.lean` would BREAK this module's certificate-freedom grep,
`ClType` being one of the grep's own identifiers. The certificate-freedom grep was re-run at
phase close and still returns NOTHING.

## Verification at closure

- Guarded scoped build of `LadderAgree.lean`: exit 0, 1966 jobs, 0 `error:` and 0 `warning:`.
  Guarded scoped build of `BimodalTest.Metalogic.KTypeSummaryAxiomTest`: exit 0, 2361 jobs, 0
  `error:` and 0 `warning:`.
- `#print axioms` on all ten new declarations: six on NO axioms at all (`altWalkPath` and its
  three accessor readings, `altWalkPath_isLadderPath`, `altWalkPath_eq_of_objAt_eq`),
  `altPend_altW'` on `[propext, Quot.sound]`, and `exists_altLadderPath`,
  `altWalkPath_not_vacuous`, `mem_cellAt_of_altWalkPath` on `[propext, Classical.choice,
  Quot.sound]`. No `sorryAx`, no custom axiom, no `native_decide`.
- Certificate-freedom grep on `LadderAgree.lean` (`certAdmK|certStabK|certBoxK|certBiInfK|
  certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|
  cohIdle|satThreshold|satPeriod`): ZERO occurrences. Import list UNCHANGED from Phase 11.1's
  (`git diff` shows no `import` line added or removed).
- `git diff --stat` on `CounterQuotient.lean`: EMPTY. No parameter added, no parameter source
  strengthened, `ParamsOk` untouched.
- `check-evidence-probes.sh`: exit 0, all 45 wired probes compile, the refutation probe
  unmodified. `readme-lint.sh`: PASS. `typst-sync-check.sh`: PASS (all 4 checks green) after
  `typst-status-counts.sh` resynced the two line counts.
- `check-module-invariants.sh --emit-inventory`: exit 0, rewrote the three generated README
  inventory blocks.
- No `sorry`, axiom, vacuous definition, trace-level `Presented` hypothesis, finite-fibre or
  finite-width retreat, positionwise narrowing, raised `Tc`, or conditional restatement of the
  refuted half (ii) anywhere in the tree.

## Deviations

Two, both annotated inline on Phase 11.3's own checklist items:

1. **Non-vacuity fixture ALTERED** — a fresh three-state fixture instead of a transcription of
   the prototype's, and the witness strengthened so the differing position is PENDING. Rationale
   above.
2. **Wiring ALTERED** — the docstring paragraph was added as its own top-level section
   (`## The alternative-history freedom, and what it does and does not give`) rather than as a
   paragraph inside the existing half-(i) section, because it says what the construction does NOT
   give and that belongs beside, not inside, the transport layer. One file-scope addition the task
   list did not anticipate: `set_option linter.style.longFile 1800` with its explanatory comment,
   since the module crossed the package-wide 1500-line limit at 1700 lines — the same in-repo
   pattern `Periodic.lean` already uses at 1700.

## Landed count against the Scope Hypothesis

The Scope Hypothesis predicted "seven declarations … to be confirmed by the landed count at phase
close rather than trusted from here." The landed count is TEN: the seven predicted, plus three
fixture lemmas that carry the non-vacuity witness and are pinned with it (`altPend_altW'`,
`altNoRegionStart` and `exists_altLadderPath`, of which the first and third are axiom-pinned).
Counting the fixture's own definitions (`AltQ`, `altPend`, `altStep`, `altW`, `altC`, `altW'`)
and its four small walk lemmas, the module grew by 252 lines. The prediction of "one module plus
three wiring files" held exactly.
