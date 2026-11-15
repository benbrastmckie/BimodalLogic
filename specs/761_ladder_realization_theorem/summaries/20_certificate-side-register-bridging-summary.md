# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem: `LadderCons` and `ladderRealized` per ladder cell for all φ including box/stab letters
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-15T20:25:17Z
- **Completed**: 2026-11-15T23:55:00Z
- **Effort**: ~2 hours (Phase 11.25, the bounded design round) + ~1 hour (Phase 11.26, NOT COSTABLE as filed) + ~1 hour (Phase 11.27, NOT COSTABLE as filed)
- **Dependencies**: 760, 775, 805, 806, 819, 820, 934 — all discharged or terminal
- **Artifacts**: plans/20_certificate-side-register-bridging.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 11.25 — the one bounded design round route (P-2) is entered through, and a decision gate —
was executed and closed `[COMPLETED]`. Its deliverable is a VERDICT backed by compiled objects:
**outcome (iii), the obligation is NAMED and the transport is OPEN**. Eight declarations landed in
`FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean`, reducing `certStabK` of `Real`
— condition (5), the one condition that consumes the agreement of class-equivalent cells — to a
single cell-side obligation, measuring that obligation's quantifier domain, and stating the
class-representative transport that would discharge it. No `sorry`, no axiom, no vacuous
definition, no probe imported into a library module, and no position-pair relation anywhere.

Phase 11.26 then entered on **branch OPEN**, the branch outcome (iii) selects, and attempted the
transport on its own ground. Five further declarations landed in the same module. The transport
**does not close in general**: what closes is a transport over a NARROWED regime — the
downward-saturated register-displaced collisions — together with two compiled objects naming the
two coordinates that refuse the rest, and a third gap recorded rather than closed.
`ClassRepTransport` remains OPEN exactly as Phase 11.25 left it.

Phase 11.27 then composed the two. Five further declarations landed in the same module. The
covered collision set was stated before any proof was attempted, the reduction's one hypothesis
was discharged on it **in both orientations**, and the composition's `certStabK` product over the
covered regime was landed as the restricted form with its restriction an explicit named binder.
**The phase's result is what that restriction is worth**: the covered regime is confined to
stab-free closures by both register-moving deletions' own premise, and at a stab-free closure
`certStabK_of_stabFree` already gives condition (5) outright, so the composition closes on the
covered set and closes VACUOUSLY there — the transport is not load-bearing in it. The genuine
gain of the phase is on the cell side: the reverse inclusion landed too, so what the covered
family carries is a real cell-level **AGREEMENT**, an equality and not merely an inclusion.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — 642 → 926 lines. Eight new
  declarations in a new `CertificateBridge` section, plus the section docstring that records the
  verdict:
  - **LEG A, the reduction.** `real_certStabK_mpr` — the `⟸` direction of `certStabK`'s clause at
    a member of `Real`, landed UNCONDITIONALLY with NO cell transfer: every history through the
    member's own witnessing world state projects into `Real` at the same object component and the
    same counter class (`mem_real_realItem`), so the direction is discharged by `Real`'s own
    definition. `real_certStabK_mp_of_cell_stab_transfer` — the `⟹` direction, from the cell-side
    obligation written out in its own binder. `real_certStabK_of_cell_stab_transfer` — the two
    joined: `certStabK φ Tc Tn P B (Real …)` from that one hypothesis, with no parameter condition.
  - **LEG A, the scope reading.** `kappa_eq_register_displaced` — all five `kappa` coordinates are
    held across `n ↦ n + (P + 1)` once `Tn ≤ n` and `c + B ≤ n`. `register_displaced_collision_in_domain`
    — the two DISTINCT admissible ladder states carrying that collision, at a FIXED countdown and
    sharing ONE admissibility witness. `register_displaced_ne_common_shift` — that pair is no
    instance of the common downward shift, so `kappa_eq_of_shift` does not reach it.
  - **LEG B, the transport.** `ClassRepTransport` — the class-representative transport at the
    HISTORY level, whose body IS the recorded goal state. `cell_stab_transfer_of_classRepTransport`
    and `real_certStabK_of_classRepTransport` — the implications out of it.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — 3,240 → 3,307 lines. Eight
  `#guard_msgs`-pinned axiom profiles with their section docstring; in-source
  `set_option linter.style.longFile` baseline raised one chunk, 3,300 → 3,400, per the file's own
  documented convention.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the regenerated inventory row plus
  two new paragraphs: the certificate-side bridge's two legs and its verdict, and the path-level
  closure recorded in Ruling 2's honest form (four MEASURED readings, closed by the recorded ruling
  on that evidence, no general impossibility asserted).
- `FormalSystem/Metalogic/README.md`, `README.md`, `typst/generated/status.typ` — regenerated
  counts only (`scripts/check-module-invariants.sh --emit-inventory`, `scripts/typst-status-counts.sh`).
- `specs/761_ladder_realization_theorem/plans/20_certificate-side-register-bridging.md` — Phase
  11.25 marked `[COMPLETED]`, its eight checklist items checked, and a `#### Recorded Outcome`
  block carrying the verdict, the per-direction pair-set table, the scope reading, the named
  refusing coordinate, and the re-measured figures.

### The finding this round bought

`certStabK`'s iff is **not symmetric in what it costs**. The direction in which the fibre forces
the `⊡` letter needs no cell transfer at all and ranges over no register-displaced pair; only the
direction in which the letter forces the fibre carries the transfer, and its pair set **does**
contain register-displaced `kappa`-collisions — at a fixed countdown, in the register coordinate
alone. Four path-level rounds never measured either half. The certificate side therefore does ask
for what those rounds were trying to deliver, but it asks for half as much of it.

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — 926 → 1,098 lines.
  **Phase 11.26, branch OPEN**: five new declarations and a section docstring recording the
  branch and the three gaps.
  - `kappa_eq_register_raise_down` — the DOWNWARD-saturated register-displaced
    `kappa`-collisions: at a held countdown, `Tn ≤ n' ≤ n` with `n ≡ n' [MOD P + 1]` and
    `n + B ≤ c` give the same class.
  - `exists_ladderPath_register_raised_at_held_countdown` — the raised exact-shift deletion at
    `m = 0`, the ONLY instance of either register-moving deletion that holds a countdown fixed,
    with its room conditions (`hraise`, `hTc`, `hroom`, `hslack`) as explicit named binders.
  - `cellAt_subset_of_register_raise` — **the transport**, in `ClassRepTransport`'s own inclusion
    direction at the diagonal world state, with the `kappa`-collision carried as the FIRST
    conjunct of the conclusion rather than assumed.
  - `raise_room_excludes_upward_displacement` — the compiled inequality by which the raise tool's
    room ceiling `n₀ + 2 ≤ c` excludes the UPWARD-saturated family `c + B ≤ n₀` that Phase
    11.25's scope reading exhibited inside the obligation's own domain.
  - `certStabK_of_stabFree` — condition (5) is VACUOUS at a stab-free closure, which is the only
    closure at which the register-moving deletions are available.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — 3,307 → 3,355 lines, five new
  `#guard_msgs` axiom pins and their section docstring, inside the existing 3,400 baseline (no
  baseline raised in this phase).
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — regenerated inventory blocks plus
  one new paragraph recording how far the landed machinery carries the transport and the two
  coordinates that refuse the rest.
- `typst/generated/status.typ` — regenerated line counts.

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — 1,098 → 1,316 lines.
  Phase 11.27's five new declarations and its section docstring, which states the covered
  collision set, the discharged/left-standing table, and what the composition buys:
  - `exists_ladderPath_register_lowered_at_held_countdown` — the LOWERED exact-shift deletion at
    `m = 0`, the mirror of Phase 11.26's raise instance. Countdown held, object state and realized
    stab-free type held, register delivered at the prescribed `n₀ ≤ nxtAt g z`; its regime is at
    amount `k` (the `k` of the lowering) rather than at `0`, because lowering an anchor is paid
    for in the upper direction of the single anchor inequality where raising it is free.
  - `cellAt_subset_of_register_lower` — the reverse cell inclusion it yields, with its one extra
    room condition `hroom : n + (n - n') ≤ c` an explicit named binder, since nothing in the
    covered family implies `n - n' ≤ B`.
  - `cellAt_eq_of_register_displacement` — **the cell-level AGREEMENT over the covered set**: an
    EQUALITY of the cells of two class-equal ladder states differing in the REGISTER alone, by
    `Set.Subset.antisymm` on the raise and the lower, with two per-path regimes (one through each
    state, because the two directions are carried by different tools through different source
    states). Its docstring records that it is an agreement over the COVERED set and is NOT the
    filed `cellAt_const_of_kappa_eq`.
  - `cell_stab_transfer_of_register_displacement` — that agreement read in the shape
    `real_certStabK_of_cell_stab_transfer`'s `hcell` binder consumes, in BOTH orientations; the
    compiled form of the phase's table.
  - `real_certStabK_of_stabFree` — **the composition's `certStabK` product over the covered
    regime**: condition (5) of `Real` at a stab-free closure. Its proof consumes nothing from the
    transport, the agreement, or the reduction.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — 3,354 → 3,405 lines; five new
  `#guard_msgs`-pinned `#print axioms` entries and their section docstring. In-source `longFile`
  baseline raised ONE chunk, 3,400 → 3,500, that file's own documented convention.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the generated inventory blocks
  (line counts) plus a paragraph recording, in terms, what is covered and what is not, and that
  the composition closes vacuously on the covered set.
- `typst/generated/status.typ` — regenerated line counts and stamp commit.

## Decisions

- **The LEG A hypothesis is written out inline in every theorem that takes it**, rather than
  abbreviated behind a `def`. The phase body required the obligation's quantifier domain to be
  written out; repeating the eight-line binder in three signatures is the literal reading.
- **The transport is stated as a `def` (`ClassRepTransport`) and consumed as a hypothesis**, never
  as a premise carried by anything above it — the same discipline Phase 11.23 held the gap
  conjecture to.
- **The pre-authorized `LadderWindow` import edge was NOT added.** No declaration here consumes
  `cellSubset_of_kappa_eq_window_raise`, and the phase's own verification rejects an import edge
  added without a consumer. `LadderRealize.lean` still imports `CounterQuotient` and `LadderChain`
  alone.
- **No evidence probe was authored.** The phase body owes one on outcome (ii) only; outcome (iii)
  was reached, so the wired total stays at 63.
- **The test module's `longFile` baseline was raised** 3,300 → 3,400 rather than splitting the
  ledger, which is that file's own documented convention and is recorded in the phase body rather
  than left silent.
- **Phase 11.26's transport was NARROWED, and the narrowing is recorded in the statement and the
  docstring** — which the phase's prohibition list permits in that form and only that form. It is
  not `ClassRepTransport`, which quantifies over every class-equal pair with no room condition and
  no regime hypothesis, and which stays OPEN.
- **The `kappa`-collision was moved into the conclusion rather than deleting two redundant
  binders.** The first landed form of `cellAt_subset_of_register_raise` consumed neither `hTn` nor
  `hres` (the unused-variable linter flagged both — this phase's `lean_minimal_hypotheses` check in
  mechanical form), because the inclusion follows from the raise tool and the room conditions
  alone. Deleting them would have left a statement not visibly about class-equal states; carrying
  the collision as the conclusion's first conjunct makes every binder load-bearing and records the
  finding that the surgery never consults the class.
- **Phase 11.27 WAS entered**, against exactly that measurement, as its entry condition permits
  (Phase 11.26 landed the transport over a named sub-regime). What it could buy was known in
  advance to be bounded by the stab-free confinement; it was entered to land the agreement and to
  record the covered set precisely, which is what Phases 11.7 and 12.2 need in order to quantify
  over what is actually covered.
- **The restricted form was landed, not the unconditional one.** The covered set is not the whole
  of what `certStabK` quantifies over, so `certStabK … Real` was landed under the explicit named
  binder `hno` — and the phase records, rather than hides, that this binder is strong enough to
  make the conclusion free.
- **The agreement is an EQUALITY, not the one-directional inclusion Phase 11.26 left.** The
  lowered exact-shift deletion at `m = 0` supplies the reverse direction, so
  `cellAt_eq_of_register_displacement` is a genuine cell agreement over the covered family. This
  is the phase's substantive gain and is the reason five declarations landed where the Scope
  Hypothesis estimated two.
- **No `docs/theorem-index.md` row was added.** The filed Goal lands in Phase 11.7, which owes the
  C14 pin; nothing filed landed here.

## Plan Deviations

- None (implementation followed plan).

## Verification

- Build: Success. Full `lake build` through `.claude/scripts/lake-build-guard.sh`, exit 0.
  Module-scoped builds of `FormalSystem.Metalogic.Decidability.RaySummary.LadderRealize` and
  `BimodalTest.Metalogic.KTypeSummaryAxiomTest` each exit 0 with **0 errors and 0 warnings**.
- Sorry count: 0 (`bash .claude/scripts/lean-sorry-census.sh` over the resolved source roots)
- Vacuous count: repository-wide grep at its **1-hit baseline, unchanged**; 0 in the modules this
  phase touched
- Axiom count: `^axiom ` grep-match count **14, unchanged**
- `#print axioms` on each of the eight new declarations: a subset of
  `[propext, Classical.choice, Quot.sound]`. `kappa_eq_register_displaced`,
  `register_displaced_collision_in_domain` and `register_displaced_ne_common_shift` at
  `[propext, Quot.sound]`; the other five at the full standard profile. No `sorryAx`, no custom
  axiom, no `native_decide`.
- Gates: `scripts/check-module-invariants.sh`, `scripts/typst-sync-check.sh`,
  `scripts/readme-lint.sh`, `scripts/check-evidence-probes.sh` (63 wired, PASS, **unchanged**) and
  `.claude/scripts/check-task-references.sh --quiet` each exit 0.
- Prohibition greps over this phase's own added lines: `iterSpliceIdx`, `nxtAt`, `ProbeB1`,
  `gate9_col_cell_eq`, `gap_shift_cell_eq`, `real_certAdmK_of_paramsOk`, `real_subset_dmax`,
  `dmax_subset_real`, `cellLE_zero_const_of_kappa_eq`, `ladderSound`, `ladderLift`,
  `refuted in general`, `shown impossible`, `path level is refuted` — **all 0**.
- Landed declarations of the earlier register rounds are byte-identical: `git diff` shows
  `LadderCell.lean`, `LadderAgree.lean` and `CounterQuotient.lean` untouched by this phase, so
  `stab_alphaR_iff`, `stab_bit_ne_of_register_ne`, `stab_alphaR_eq_of_clipped_eq`, `stab_gapR_iff`,
  `stab_gapR_eq_of_gap_eq`, `stab_gapR_ne_of_clipped_eq`,
  `iterSpliced_gap_interior_forces_block_gap_le`, `paramsOkK1`–`paramsOkK4`, `ParamsOk`, `Tcof`,
  `Tnof`, `Pof`, `Bof` and `paramsOk_params` are all unchanged and `Tc_0` is not re-based.
- Files verified: Yes

### Phase 11.26 verification (branch OPEN)

- Build: Success. Module-scoped `FormalSystem.Metalogic.Decidability.RaySummary.LadderRealize`
  exit 0 with **0 errors and 0 warnings**; `BimodalTest.Metalogic.KTypeSummaryAxiomTest` exit 0
  with all five new `#guard_msgs` pins green; **full unscoped `lake build` exit 0, 0 errors,
  2,975 jobs**, with both touched modules' `.olean` newer than their sources.
- Sorry count: **0**. Vacuous grep: repository-wide **1-hit baseline, unchanged**; 0 in the
  touched modules. `^axiom ` grep-match count **14, unchanged**.
- `#print axioms` on each of the five new declarations is a subset of
  `[propext, Classical.choice, Quot.sound]`: `kappa_eq_register_raise_down` and
  `raise_room_excludes_upward_displacement` at `[propext, Quot.sound]`, the other three at the
  full standard profile.
- Circularity grep (`ladderSound|ladderLift|ladderCons_localRun|real_certStabK`) over this phase's
  own additions: one docstring-prose hit, nothing in any proof term. Position-pair grep
  (`~_d|iterSpliceIdx|nxtAt … = nxtAt …|min (nxtAt …) Tn`): **nothing**. Three-claims grep: one
  docstring-prose hit recording that they are NOT claimed. Cell-agreement grep: **nothing**.
- No probe declaration cited as a library fact; `grep -n '^import'` on `LadderRealize.lean` names
  `CounterQuotient` and `LadderChain` alone — **no `LadderWindow` edge, no path under `specs/`**.
- `check-module-invariants.sh`, `typst-sync-check.sh`, `readme-lint.sh`,
  `check-evidence-probes.sh` (**63 wired, unchanged** — no probe authored) and
  `check-task-references.sh --quiet` each exit 0.

### Phase 11.27 verification (the composition over the covered collisions)

- Build: Success. Module-scoped `FormalSystem.Metalogic.Decidability.RaySummary.LadderRealize`
  exit 0 with **0 errors and 0 warnings**; `BimodalTest.Metalogic.KTypeSummaryAxiomTest` exit 0
  with **0 errors, 0 warnings** and all five new `#guard_msgs` pins green; **full unscoped
  `lake build` exit 0, 0 errors, 0 warnings, 2,975 jobs**, with both touched modules' `.olean`
  newer than their sources.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots, exit 0). Vacuous
  grep: repository-wide **1-hit baseline, unchanged**; **0** in `LadderRealize.lean`. `^axiom `
  grep-match count **14, unchanged**.
- `#print axioms` on each of the five new declarations is `[propext, Classical.choice, Quot.sound]`
  — a subset of the permitted set. No `sorryAx`, no custom axiom, no `native_decide`.
- The phase body states the covered collision set, read off Phase 11.26's recorded outcome, and
  the module's own section docstring states it before the first declaration of the phase.
- Circularity grep (`ladderSound|ladderLift|ladderCons_localRun`) over this phase's own additions:
  **one docstring-prose hit** (the sentence recording that nothing is derived from them) and
  nothing in any proof term. Filed/reserved-name grep
  (`theorem (cellAt_const_of_kappa_eq|ladderSound|ladderCons_localRun|ladderLift|ladderRealized|cellLE_zero_const_of_kappa_eq)`)
  over the module: **nothing**. Three-claims grep: one docstring-prose hit recording that they are
  NOT claimed. Position-pair grep (`iterSpliceIdx|nxtAt … = nxtAt …|min (nxtAt …)`): **nothing**.
- Hypothesis non-redundancy, in mechanical form: the module builds with **0 warnings**, so Lean's
  unused-variable linter flags no binder of any of the five declarations — the same check Phase
  11.26 used in place of a separate `lean_minimal_hypotheses` call. `real_certStabK_of_stabFree`
  is the one declaration whose route is deliberately NOT through the transport, and that is
  recorded in its docstring rather than concealed.
- No probe cited as a library fact; `grep -n '^import'` on `LadderRealize.lean` still names
  `CounterQuotient` and `LadderChain` alone — **no `LadderWindow` edge, no path under `specs/`**.
- `check-module-invariants.sh`, `typst-sync-check.sh`, `readme-lint.sh`,
  `check-evidence-probes.sh` (**63 wired, PASS, unchanged** — no probe authored) and
  `check-task-references.sh --quiet` each exit 0.
- Figures re-measured rather than carried: `LadderRealize.lean` **1,098 → 1,316** (no in-source
  `longFile` baseline; package-wide limit 1,500), `KTypeSummaryAxiomTest.lean` **3,354 → 3,405**
  with its in-source baseline raised one chunk **3,400 → 3,500**.
- Plan-revision sentinel: `.plan-revised.json` carries `revised_at: 1794776400`, EARLIER than this
  dispatch's `dispatch_start_ts: 1794779733` — no fresh hit, so Phase 11.27's section was executed
  as re-read from the live plan file.
- Files verified: Yes

### Carried-figure check against live state

The dispatch extracted three description lines for re-checking. Each was checked rather than
assumed, and the result is stated even where it only confirms the description:

- **Line 13 (WHY HIT-LEVEL, WHY THIS FRAME) — CONFIRMED UNCHANGED.** `Probe747.modelOf_incomplete`
  and `Probe747.stab_iff_of_presented_nowUnique` are live in
  `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean` (`:131`, `:188`);
  `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` is live at `LadderModel.lean:163`
  exactly as quoted; `ladderFrameAdm_isRegular`, `no_fwd` (`:124`) and `no_bwd_of_idle` (`:144`)
  are live; `Rlad_slice_infinite` resolves.
- **Line 17 (CONTINGENCY) — HONORED.** This round neither blocked nor used a `sorry`, an axiom, a
  vacuous definition, a trace-level hypothesis, or any finite-fibre or finite-width assumption.
- **Line 23 (NOT COSTABLE) — ONE FIGURE EXACT, ONE PATH STALE.** `Realize.lean` measures exactly
  **1,004 lines**, as the description states. The design of record it cites at
  `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` **does not exist**; the
  file is at `specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`. The
  plan already records correcting the description as an open follow-up, and this round confirms
  the finding rather than acting on it.

## Impacts

- Condition (5) of `Real` now has a **named, compiled reduction**: any future discharge of the
  cell-side obligation — or of the class-representative transport that implies it — yields
  `certStabK φ Tc Tn P B (Real …)` immediately, via `real_certStabK_of_cell_stab_transfer` or
  `real_certStabK_of_classRepTransport`. Half the condition is already discharged
  (`real_certStabK_mpr`), unconditionally.
- Phases 11.26 and 11.27 are ENTERABLE, 11.26 on its **branch OPEN**. Phase 11.7 is re-pointed
  onto 11.27 by the plan of record and is unaffected by this round.
- Route (P-2) is **not** closed: outcome (ii) was not reached, so the task does not rest
  `[BLOCKED]` on this gate and no `/revise` is owed by it.
- **Phase 11.7 and Phase 12.2 now have a named, compiled covered set to quantify over**, plus the
  discharged/left-standing table in both the plan's `#### Recorded Outcome` and the module's
  section docstring — a table rather than an argument, which is what Phase 11.27's task list owed
  them.
- **The filed `cellAt_const_of_kappa_eq` remains OPEN on the uncovered collisions SPECIFICALLY** —
  the upward-saturated register family, moved countdowns, general time components, and every
  closure carrying a `⊡` letter — and not as a general failure. Phase 11.7's contingency branch is
  the one that applies to it.
- **A genuine cell-level agreement now exists in the tree over a real family of
  `kappa`-collisions** (`cellAt_eq_of_register_displacement`), which is new: every earlier landed
  cell result on this route was a one-directional inclusion.

## Follow-ups

- **No second design round is bought by Phase 11.25**, and none is owed.
- **The stab-free confinement is now the binding obstruction on this route, measured twice.** It
  blocked Phase 11.6 on the path side and it empties route (P-2)'s payoff on the certificate side.
  Any continuation must either supply a register-moving surgery whose type half survives a `⊡`
  letter in the closure, or leave the surgery route entirely. That is a route decision for a
  `/revise`, not a move inside a phase.
- The task description's citation of the design of record still names the unarchived path; the
  archive path is the live one. Correcting the description is not an act a phase performs.
- **The class-representative transport `ClassRepTransport` is still OPEN.** The landed transport
  covers only the downward-saturated collisions, at a stab-free closure where the obligation it
  would discharge is vacuous. Closing it needs either a register-moving surgery without the
  stab-free premise, or a route that does not go through a surgery at all — a route decision for a
  `/revise`, not a move inside a phase.
- **The diagonal-to-general offset bridge is not landed.** `cellAt_subset_of_register_raise` is
  stated at `(z, ⟨(q, c, n), h⟩)` evaluated at `z`, while
  `real_certStabK_of_cell_stab_transfer`'s `hcell` binder is at a general time component. The
  bridge is an offset-invariance of `tpOf` under the ladder model — an induction over the closure.

## References

- `specs/761_ladder_realization_theorem/plans/20_certificate-side-register-bridging.md` — the plan
  of record; Phases 11.25, 11.26 and 11.27 and each one's `#### Recorded Outcome`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — the eighteen declarations
  of the three rounds and the three section docstrings carrying their verdicts
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — the two register-moving
  deletions this round's `m = 0` instances come from
  (`exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past` `:2576`,
  `exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past` `:2703`)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the certificate-side bridge
  paragraph and the path-level closure paragraph
- `specs/761_ladder_realization_theorem/summaries/19_pending-state-measurement-kill-criterion-summary.md`
  — the predecessor round whose kill criterion entered route (P-2)
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` — `certStabK` (`:1221`),
  `kappa` (`:169`), `clipIdx` (`:160`), `clipIdx_sub_sub` (`:289`)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` — `stab_mem_tpOf_iff_cell`
  (`:377`), `kappa_eq_of_shift` (`:3320`)
