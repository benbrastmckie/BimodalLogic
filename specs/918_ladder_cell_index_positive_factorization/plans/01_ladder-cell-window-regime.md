# Implementation Plan: The ladder cell index in the ordinary window regime

- **Task**: 918 - Produce a positive factorization lemma for the index of which cell a ladder state has
- **Status**: [IMPLEMENTING]
- **Effort**: 12.5 hours
- **Dependencies**: None blocking. Reads task 917's closed record as its starting position; the idle-splice layer it builds on (`LadderPump.lean`'s three `Idle`-prefixed sections, `LadderIdle.lean`'s register-anchored assembly) is already landed by a sibling.
- **Research Inputs**: `specs/918_ladder_cell_index_positive_factorization/reports/01_ladder-cell-index-positive-factorization.md`; the plan-time compiled gate measurement `specs/918_ladder_cell_index_positive_factorization/evidence/plan-gate-arithmetic.lean` (`lake env lean`, zero output, `sorry`-free)
- **Reports Integrated**: `reports/01_ladder-cell-index-positive-factorization.md`, `evidence/plan-gate-arithmetic.lean`
- **Artifacts**: plans/01_ladder-cell-window-regime.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Research established that the task as dispatched is not executable: its second admissible
outcome is foreclosed by the compiled `paramsOk_params`, and its first reduces to discharging
`ForwardSlackWitnessed`, whose only landed route task 917 refuted at the pin layer three commits
ago. The prior cycle's recorded decision re-scoped the task to **Target A, the ordinary window
regime `c ≤ n + 1`** — the one branch of the collision case split that no landed inclusion
addresses in either direction, independent of `ForwardSlackWitnessed` and of the parameter
contract. This plan lands that branch in a new leaf module, through a named decision gate whose
arithmetic layer is already compiled and whose path-level layer is measured before any
construction is attempted. Done means: the window regime's arithmetic and its two cell
inclusions are landed with the regime's own schema and a compiled dichotomy against the
pending-forever schemas, or the obstruction is compiled as a wired probe and the window branch
is closed as a reportable negative. The verdict is stated either way, never tacit.

### Research Integration

- **The two constraints the dispatch names are landed and jointly discharged (F1)**. `paramsOkK1`
  is the modulus-multiple-of-period conjunct (over `prodCycleLens`, `objCycleLens`, `satPeriod`),
  `paramsOkK2`/`paramsOkK4` the formula-derived threshold and clip, and `paramsOk_params`
  discharges all four at `(Tcof, Tnof, Pof, Bof)`. No refutation of joint satisfiability can
  exist, so the dispatch's outcome (b) is not planned for.
- **The positive lemma's identity (F2)**. The reserved name is `cellLE_zero_const_of_kappa_eq`,
  claimed by nothing. Five hypothesis-strengthened schemas exist in `LadderCell.lean`, all
  concluding cell EQUALITY, all carrying the pending-forever gap `n + 2 ≤ c`.
- **The untouched branch (F7)**. The complementary regime `c ≤ n + 1` is addressed by no landed
  inclusion in either direction. `pend_past_of_nxtAt_lt` is what restricts the landed schemas to
  paths pending at every earlier position; in the complementary regime the compared position has
  an idle position in its past, where `cntAt_le_nxtAt_succ_of_idle_past` is available and the two
  counters are tied together rather than free.
- **The collision pays for the room, and this is compiled rather than argued** (plan-time
  measurement, layer A of the Phase 2 gate, lifted into Phase 1). `clipIdx_regime_of_eq` reads a
  collision at a fixed register as `c' ≤ n ∨ n + 2 ≤ c`; the window hypothesis kills the second
  branch, so the window regime's own hypothesis `c ≤ n + 1` is UPGRADED by the collision to the
  strict room `c' ≤ n` for whichever countdown is larger. That room is exactly the anchor clause
  of the z-anchored lift `exists_ladderPath_of_walk_nxt_at` at the region start below `z`, once
  the in-region duplication has raised that start's countdown by the displacement. All four
  statements compile `sorry`-free; see `evidence/plan-gate-arithmetic.lean`.
- **The planned attack, named as an attack rather than a result**. The pending in-region
  duplication raises `cntAt g z`, but it also raises the countdown at the region start BELOW `z`,
  whose pin compatibility against still-lower starts then falls short by exactly the displacement
  — the same deficit shape route (d) died of, now in the backward direction. The compensator the
  window regime makes available and the pending-forever regime does not is the IDLE RUN below
  `z`'s region: splicing the displacement into that run grows every lower pin's distance by the
  same amount the raise cost, and `idleSplice_pins` (`LadderPump.lean`) discharges the idle
  splice's own pin clause UNCONDITIONALLY — "no regime hypothesis, no `ParamsOk`, no side
  condition carried to the caller". The composite is what Phase 2's gate measures.
- **Supporting machinery already landed (F8)**, consumed rather than rebuilt:
  `tpOf_eq_spliceIdx_of_tpOf_eq` and `tpOf_eq_delIdx_of_tpOf_eq` (type held across a
  duplication/deletion, needing only stab-freeness and NOT pend-past — the pend-past hypotheses
  sit only on the admissibility halves); `exists_typeBlock_of_budget_le_cnt_within` (the pending
  pigeonhole); `exists_idleTypeBlock_of_budget_le_run` and `exists_idleSpliced_ladderPath` (the
  idle mirror, with `idleBudget`); `exists_iterIdleSpliced_ladderPath` and
  `idleGapLengtheningOfIdleRunRepeat_holds` (`LadderIdle.lean`);
  `exists_ladderPath_of_walk_nxt_at` (the z-anchored lift, pins measured from `z`);
  `drift_extension_of_pins`; `cntAt_eq_nxtAt_of_idle_pend` (the pin equation at a region start);
  `cntAt_add_of_pend_back` and `nxtAt_lipschitz` (the two facts behind `n ≤ c + 2·d`).
- **Prohibited routes carried forward verbatim (Recommendation 4)**: route (d), a tuple index at
  any parameters, the stabilization lemma, the clipped-coordinate index family, the
  bounded-carrier route, the object-exhibited-parameter residue index, and route (e)'s `(K1)`
  amendment.

### Prior Plan Reference

No prior plan. This is the task's first plan round. Task 917's plan is read as a sibling
precedent for the two-layer gate shape, the FAIL-branch probe phase, and the gate-collision
schedule — not as a template for content.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no roadmap phases are scheduled.

## Goals & Non-Goals

**Goals**:
- `kappa_collision_window_room` -- a `kappa` collision at a fixed register in the window regime either pins the two countdowns equal or exhibits a positive multiple-of-`P + 1` displacement together with the strict room `c' ≤ n` for the larger countdown.
- `window_anchor_compat_of_room` -- that room is exactly the z-anchored lift's anchor clause at the region start below `z` after the raise.
- `window_pin_compat_raise_of_gap` -- the pin pair clause is strictly looser in the raising direction once the compensating idle splice has grown the distance.
- `window_pin_compat_lower_of_spacing` -- the pin pair clause in the lowering direction, discharged from region-start spacing alone.

**Non-Goals**:
- Landing anything under the reserved name `cellLE_zero_const_of_kappa_eq`, or any prefix of it.
  This plan covers one regime of one case split; the reserved statement stays claimed by nothing,
  and no declaration introduced here may take that name.
- Re-attempting route (d) (deletion inside the first region above `z`'s with the register held at
  `z`), the stabilization lemma, the clipped-coordinate index family, the bounded-carrier route,
  or the object-exhibited-parameter residue index. Each is refuted on the record's own authority.
- Any amendment to `(K1)` or to `ParamsOk` (route (e)). A phase that would touch `paramsOkK1`
  stops and escalates.
- Stating a tuple index at any parameters. `kappa` is a coordinate of the carrier, not an index;
  the factorization lemma for the quotient is a corollary of the fibre equation, never its
  hypothesis.
- Discharging `ForwardSlackWitnessed`, or weakening it. This branch does not go through it.
- A weakened substitute for the window-regime result. If Phase 2's gate fails, the terminus is
  the compiled obstruction, not an inclusion with an extra hypothesis bolted on to make it pass.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 2's gate fails: the composite splice's pin clause is not dischargeable without a further hypothesis | H | M | Phase 2 is an explicit decision gate with a stated criterion and a STOP. On failure Phase 6 compiles the obstruction and Phases 3-5 close `[COMPLETED WITH EXCLUSIONS]` citing Phase 2's own measurement. Do not add a hypothesis to force the clause, do not introduce an axiom, do not leave a `sorry`-deferred case |
| The idle-run condition survives as a carried hypothesis, so the window schema is itself hypothesis-strengthened | M | H | This is an expected, honest outcome, not a failure: the schema's docstring states exactly what it carries and that the reserved name stays unclaimed, in the same scoping language `kappa_collision_two_regimes_refuted` and the five landed schemas already use. A carried, CHECKABLE condition on the run below is strictly more tractable than `ForwardSlackWitnessed` and is not to be presented as the reserved statement |
| Concurrency: three RaySummary files are hot (`LadderAgree.lean`, `LadderChain.lean`, `LadderCell.lean`), and two sibling tasks declare `LadderAgree.lean` and `RaySummary/README.md` in their own scope | M | H | Every new declaration lands in a NEW leaf module `LadderWindow.lean`; `LadderAgree.lean`, `LadderChain.lean`, `LadderCell.lean`, `LadderPump.lean`, `LadderIdle.lean` and `RaySummary/README.md` are READ-ONLY for this task and appear in no phase's file list. The only shared surfaces are the two aggregators and the regenerated generated files, all of which are regenerated by tool rather than hand-edited and are idempotent under a sibling's concurrent regeneration |
| New-module plumbing is forgotten and a gate fails late | M | H | Phase 1 schedules every piece as named work: the copyright header (`scripts/check-copyright-headers.sh`), the aggregator import in `FormalSystem/Metalogic/Decidability/RaySummary.lean`, the library root via `lake exe mk_all --lib FormalSystem` (gate-collision C33), and the module-inventory blocks (Condition 1 surface (a), legitimately deferred to Phase 7) |
| `check-metalogic-cycles.sh` Assertion B asserts EQUALITY against a frozen allowlist and fails on surplus as well as deficit | M | L | `LadderWindow.lean` imports only `LadderCell` and `LadderIdle`, both siblings in the same layer, so no new upward edge is expected. Phase 1 CONFIRMS that by running the script rather than assuming it (gate-collision Condition 5); if a surplus edge appears, the allowlist is extended in the same phase and `scripts/check-metalogic-cycles.sh` enters that phase's file list |
| `.githooks/pre-commit` blocks any commit staging a `.lean` path while `typst/generated/status.typ` has drifted | M | H | Every Lean-touching phase runs `bash scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in its own commit (Condition 1 surface (b) — cannot be deferred) |
| `LadderWindow.lean` crosses the package-wide 1500-line `longFile` ceiling | L | M | The file starts empty, so no baseline is owed at first. The phase that crosses 1500 adds `set_option linter.style.longFile N` directly after the module docstring at the smallest multiple of 100 strictly greater than the count, and Phase 7 re-tightens it at the final count inside the linter's `N - 200 ≤ lines < N` window (Condition 7) |
| A repo-wide gate is red for pre-existing, unrelated reasons | L | H | Every criterion below is scoped to the files the phase touches, or stated as a delta against the pre-task baseline, never as an absolute repo-wide zero (Condition 4). `check-module-invariants.sh`'s C16 group is already failing on `LadderPump.lean` from a concurrent sibling; enumerate and attribute it, never edit that out-of-scope file |
| A pinned Challenge signature turns out incomplete, blocking a phase mid-flight | M | L | Every identifier named under `- **Goals**:` is already compiled `sorry`-free at plan-authoring time in `evidence/plan-gate-arithmetic.lean`. The gate-dependent declarations are deliberately NOT pinned — see Decisions |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel. This plan is fully sequential: every phase
from 1 onward writes the same new module `LadderWindow.lean`, so no two may run concurrently
against it.

### Phase 1: The New Leaf Module and the Window Regime's Arithmetic [COMPLETED]

**Goal**: Create `LadderWindow.lean` with its plumbing complete, and land the four compiled
arithmetic statements that constitute layer A of the decision gate. Every line of Lean in this
phase is already measured; nothing here depends on the gate's outcome.

**Tasks**:
- [ ] Exact-name sweep (not a prefix anchor — gate-collision Condition 3) confirming `kappa_collision_window_room`, `window_anchor_compat_of_room`, `window_pin_compat_raise_of_gap` and `window_pin_compat_lower_of_spacing` have no declaration site anywhere under `FormalSystem/`, `Tests/` or `specs/evidence/`, excluding the refutation-probe paths.
- [ ] Create `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` with the repository copyright header, a module docstring, and `import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell` plus `import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle`. Both imports are load-bearing: the arithmetic reads `kappa_eq_components` and `clipIdx_regime_of_eq` through `LadderCell`, and the construction reads the idle-splice layer through `LadderIdle`.
- [ ] The module docstring MUST state the module's scope in the record's own terms: it holds the ORDINARY WINDOW regime `c ≤ n + 1` of the depth-`0` cell obligation, the complement of the pending-forever gap `n + 2 ≤ c` that the five `LadderCell.lean` schemas carry; it claims nothing about the reserved `cellLE_zero_const_of_kappa_eq`; and it touches neither `ForwardSlackWitnessed` nor `ParamsOk`'s own conditions.
- [ ] Land the four arithmetic theorems, lifting the bodies VERBATIM from `specs/918_ladder_cell_index_positive_factorization/evidence/plan-gate-arithmetic.lean` rather than re-deriving them. Their statements are pinned in `## Lean Challenge Statements` below and must land exactly as pinned.
- [ ] Each docstring states what the statement measures and what it does not: `kappa_collision_window_room` records that the room `c' ≤ n` is the GAP COORDINATE paying for it (via `clipIdx_regime_of_eq` with the gap branch killed), not an added assumption; the three pin lemmas record that `jP` is opaque, so the arithmetic is scale-invariant and never reads `j · (P + 1)` as such.
- [x] Add the aggregator import to `FormalSystem/Metalogic/Decidability/RaySummary.lean`, after the `LadderIdle` line. *(deviation: altered -- the aggregator's own `## Modules` docstring list, which enumerates every module it imports, gained a matching `RaySummary.LadderWindow` bullet alongside the bare import line; an import with no entry there would have been the file's only such gap.)*
- [ ] Regenerate the library root: `lake exe mk_all --lib FormalSystem`, then confirm with `lake exe mk_all --lib FormalSystem --check` (gate-collision C33).
- [ ] Run `bash scripts/check-copyright-headers.sh` and confirm the new file is counted and passing.
- [ ] Run `bash scripts/check-metalogic-cycles.sh` and CONFIRM no new upward import was introduced (Condition 5). If Assertion B reports surplus, extend the frozen allowlist in this same phase and add `scripts/check-metalogic-cycles.sh` to this phase's file list.
- [ ] Guarded scoped build, then `bash scripts/typst-sync-check.sh --fix`, and stage `typst/generated/status.typ` in the same commit.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Tier Justification**: adding a module changes the two aggregators that import it, so the covering check is the changed module plus its enumerated direct dependents — `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow FormalSystem.Metalogic.Decidability.RaySummary` together with `lake exe mk_all --lib FormalSystem --check`.

**Scope Hypothesis**: the new module is estimated at 120-160 lines after this phase (the four statements plus their docstrings and the module docstring), which is well under the 1500-line ceiling so no `longFile` baseline is owed yet; and the two aggregator files are asserted to be the complete set of files that must change for a new RaySummary module, read from `FormalSystem/Metalogic/Decidability/RaySummary.lean`'s own import list and `FormalSystem.lean`'s line 218 at authoring time. Confirm the line count with `wc -l` and confirm the aggregator set by reading which tracked files `lake exe mk_all --lib FormalSystem` actually rewrites, rather than assuming this list is complete.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` - new leaf module: header, module docstring, and the four compiled arithmetic theorems
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - the aggregator import for the new module
- `FormalSystem.lean` - regenerated library root (`lake exe mk_all --lib FormalSystem`); exists, and is machine-regenerated rather than hand-edited
- `typst/generated/status.typ` - regenerated line/count fields (`--fix`), staged in the same commit

**Verification**:
- The scoped guarded build is green with no `linter.autoImplicit`, `linter.style.show`, or unused-variable warning on the new declarations (treat a warning as a failure: CI builds with `--wfail`).
- `lake exe mk_all --lib FormalSystem --check` exits 0.
- `bash scripts/check-copyright-headers.sh` exits 0 and its total file count has increased by one.
- `bash scripts/check-metalogic-cycles.sh` exits 0, run rather than assumed.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.
- `lean_verify` on each of the four names reports the standard axiom profile and no `sorryAx`.

---

### Phase 2: DECISION GATE -- The Composite Splice's Pin Clause in the Window Regime [COMPLETED]

**Goal**: Decide, by compiled attempt rather than by argument, whether the composite surgery
(a pending type-respecting block duplicated inside `z`'s region, compensated by the same
displacement spliced into the idle run immediately below `z`'s region) satisfies every clause of
the z-anchored lift in the window regime. This phase decides which branch the rest of the plan
takes.

**Tasks**:
- [ ] Read `exists_ladderPath_of_walk_nxt_at`'s signature and enumerate its five clauses (`hw`, `hidle`, `hpp`, `hpi`, `hpins`, `hn₀`) against the composite walk, naming for each one the landed lemma that discharges it or the arithmetic that must. Do this from the signature, not from memory.
- [ ] Establish the two facts the window regime supplies about the region start `a = z - d` below `z`: `cntAt g a = cntAt g z + d` (`cntAt_add_of_pend_back`) and `cntAt g a = nxtAt g a` (`cntAt_eq_nxtAt_of_idle_pend`), hence `n ≤ c + 2·d` by `nxtAt_lipschitz` from `a` to `z`. This is `window_anchor_compat_of_room`'s `hlow` and is NOT a new hypothesis.
- [ ] Establish the region-start spacing fact `window_pin_compat_lower_of_spacing`'s `hsp` consumes: for region starts `s < v`, the distance `v - s` is at least `cntAt g (s + 1) + 1`. Find it landed (`cntAt_sub_of_pend`, `not_pend_of_count`, `pinCompat_of_ladderPath` are the candidates) or land it as a named lemma in `LadderWindow.lean` before building on it.
- [ ] ATTEMPT the gate: discharge `hpins` and `hn₀` for the composite walk at displacement `jP := j · (P + 1)`, under `ParamsOk`, the window hypotheses `¬ (n + 2 ≤ c)` and `¬ (n + 2 ≤ c')`, `Tc ≤ c`, the room from `kappa_collision_window_room`, and ONE named condition on the idle run immediately below `z`'s region (that it is at least `jP` long and carries a type-respecting idle block, which is what `exists_idleTypeBlock_of_budget_le_run`'s `hbud : idleBudget pend φ ≤ L` and `exists_idleSpliced_ladderPath`'s `hrep` jointly ask for). Define that condition as a named `def` in `LadderWindow.lean` so it is a checkable hypothesis rather than an inline existential.
- [ ] GATE CRITERION, measured not asserted: both `hpins` and `hn₀` elaborate for the composite walk with NO hypothesis beyond `ParamsOk`, the two window hypotheses, `Tc ≤ c`, the collision's room, and the one named idle-run condition. A clause that needs a sixth hypothesis is a FAIL, not a widening.
- [ ] On PASS: record which lemma discharged each clause, and proceed to Phase 3.
- [ ] On FAIL: STOP. Do not add a hypothesis to make a clause go through, do not introduce an axiom, do not leave a `sorry`-deferred case. Record the obstruction's exact shape — which clause, which pin pair, which deficit, what was tried — in this phase's own notes for Phase 6 to compile, and mark Phases 3, 4 and 5 `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record each citing this phase's measurement.
- [ ] Whatever the branch, run the guarded scoped build, `bash scripts/typst-sync-check.sh --fix`, and stage `typst/generated/status.typ` if any `.lean` line count moved.

**Timing**: 2.5 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow` is the complete covering check — on the PASS branch this phase adds declarations to one module and changes no existing signature, and on the FAIL branch it adds at most the named idle-run `def`, so nothing outside this module can observe the edit.

**Scope Hypothesis**: estimated +60 lines on the PASS branch (the named idle-run condition plus the spacing lemma if it is not already landed) and +20 on the FAIL branch, and the spacing fact is asserted to be derivable from the three landed candidates named above rather than confirmed at authoring time. Confirm the spacing fact as this phase's third task, before the gate attempt rests on it; confirm the line count with `wc -l`. Nothing in this phase's task list is excluded by this hypothesis — the FAIL branch's small-delta outcome is a recorded result, not a skipped task.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` - the named idle-run condition, the region-start spacing lemma if it is not already landed, and the gate's own notes in a module comment
- `typst/generated/status.typ` - regenerated count fields if any `.lean` line count moved, staged in the same commit

**Verification**:
- PASS: the scoped guarded build is green, both clauses elaborate with no hypothesis beyond the five named above, and `lean_verify` reports no `sorryAx` on anything landed.
- FAIL: the obstruction is recorded with the specific clause, pin pair and deficit that could not be closed, in a form Phase 6 can compile. A FAIL with no recorded measurement is not a completed phase.

---

### Phase 3: The Window-Regime Composite Splice, Both Directions [COMPLETED WITH EXCLUSIONS]

**Goal**: Land the path-level primitives the window regime needs: given a ladder path through
`(q, c, n)` at `z` with an idle position in its past and the named idle-run condition, produce a
ladder path through `(q, c ± j·(P + 1), n)` at `z` with the object state and the register held and
the realized stab-free type at `z` held.

**Tasks**:
- [x] Land the RAISING primitive: the pending type-respecting block from `exists_typeBlock_of_budget_le_cnt_within` inside `z`'s region duplicated to raise `cntAt g z` by `j · (P + 1)` (the bridge putting the block length among the divisors of `P + 1` is `(K1)`'s, as `exists_ladderPath_through_shifted_of_pend_past` already consumes it), composed with the compensating idle splice below through `exists_iterIdleSpliced_ladderPath`, and lifted by `exists_ladderPath_of_walk_nxt_at` with `n₀ := nxtAt g z` and Phase 2's discharged clauses. Re-anchor by translation (`isLadderPath_shift`) so `z` keeps its position.
- [ ] Land the LOWERING primitive: the mirror, with the in-region block deleted and the idle run shortened by the same displacement, `window_pin_compat_lower_of_spacing` discharging the pin pair clause. *(deviation: skipped — EXCLUDED on a compiled measurement; see `#### Reasoned Exclusions` below. The anchor clause reverses direction under deletion and needs a sixth hypothesis, which Phase 2's gate criterion forbids adding.)*
- [x] For both, carry the type through with `tpOf_eq_spliceIdx_of_tpOf_eq` / `tpOf_eq_delIdx_of_tpOf_eq`, which need only stab-freeness and NOT pend-past — that asymmetry is the whole reason this regime is reachable and MUST be recorded in the docstrings. *(deviation: altered — carried for the raising direction only, since the lowering direction is excluded, so `tpOf_eq_delIdx_of_tpOf_eq` is unused. The idle stage needed a NEW index-form iterate, `exists_iterIdleSpliced_ladderPath_idx`, because the landed `exists_iterIdleSpliced_ladderPath` exposes the realized type only strictly BELOW its block while the comparison position sits above it, and no shift argument substitutes — a stab-free realized type is not determined locally.)*
- [x] Each docstring states, explicitly, that the compensator is the idle run BELOW and not slack above, so neither primitive goes through `HasForwardSlack` or `ForwardSlackWitnessed`, and that route (d) is not re-entered.
- [x] If either primitive's construction requires an additional clause not admitted by Phase 2's gate criterion, STOP and escalate rather than widening the signature: Phase 2's criterion is the contract. *(EXERCISED: the lowering direction does, and it was escalated rather than widened.)*
- [x] Guarded scoped build, `bash scripts/typst-sync-check.sh --fix`, stage `typst/generated/status.typ`. Apply the `longFile` rule if the file crosses 1500. *(the file crossed 1500, so `set_option linter.style.longFile 1700` was added at the module's own baseline position, after the docstring and before `namespace`.)*
- [x] If Phase 2's gate FAILED: close this phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record whose Evidence column cites Phase 2's measurement. Land nothing. *(deviation: altered — Phase 2's gate PASSED, so this branch's "land nothing" does not apply; the marker and the `#### Reasoned Exclusions` record are used for the DIRECTION-SPECIFIC exclusion instead, with its own compiled measurement in the Evidence column.)*

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| The LOWERING primitive (`c − j·(P + 1)` at `z`) | The anchor clause at the region start REVERSES direction when the in-region block is deleted: its binding half becomes `nxtAt g z + jP ≤ cntAt g z + 2·d + 1`, a bound on the register from ABOVE. `kappa_collision_window_room`'s lowering branch supplies `c ≤ n`, not that; and `nxtAt_le_cntAt_region_start`'s bound `n ≤ c + 2·d + 1` is TIGHT, so the requirement is short by exactly the displacement. The pin PAIR clause is short by the same `jP` for the same reason: `window_pin_compat_lower_of_spacing`'s `hsp : W + 1 + jP ≤ DW` is region-start spacing PLUS the displacement, and `regionStart_spacing` supplies only `W + 1 ≤ DW`. Under Phase 2's own gate criterion a sixth hypothesis is a FAIL, not a widening, so the condition was NOT added. | `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean` (three assertions, `lake env lean`, zero output), landed in the module as `window_lower_anchor_not_implied`, `window_lower_anchor_fails_at_tight_bound` and `window_lower_anchor_of_required` |
| `tpOf_eq_delIdx_of_tpOf_eq` in the type half | Consumed only by the lowering direction, which is excluded above. The raising direction's type half is landed in full, through `tpOf_eq_spliceIdx_of_tpOf_eq` for the pending stage and the new `exists_iterIdleSpliced_ladderPath_idx` for the idle stage. | `exists_window_raise_ladderPath`'s own type clause, `lean_verify` standard profile, no `sorryAx` |

**Timing**: 2.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow` is the complete covering check; both primitives are new declarations in this one leaf module and no existing signature anywhere else is touched.

**Scope Hypothesis**: estimated +220 lines across the two primitives, which would put the module near 400 lines and still well under the 1500 ceiling. Confirm with `wc -l` and apply the `longFile` rule only if the count actually crosses 1500, rather than pre-emptively adding a baseline the linter would reject.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` - the raising and lowering composite-splice primitives and their scoping docstrings
- `typst/generated/status.typ` - regenerated count fields, staged in the same commit

**Verification**:
- Scoped guarded build green and warning-free on the new declarations.
- `lean_verify` on both primitives: no `sorryAx`, standard axiom profile.
- Each docstring contains the two scope statements named in the task list (the idle compensator below, and the pend-past-free type half).

---

### Phase 4: The Two Cell Inclusions in the Window Regime [COMPLETED WITH EXCLUSIONS]

**Goal**: Lift Phase 3's primitives to the cell level, mirroring
`cellAt_subset_of_shift_of_pend_past` and `cellAt_subset_of_shift_of_pend_past_rev` with the
idle-past hypothesis in place of the pending-forever one.

**Tasks**:
- [x] Land the upward inclusion: in the window regime at countdown at least `Tc`, under the named idle-run condition, the cell at `(q, c, n)` is contained in the cell at `(q, c + j · (P + 1), n)`. Follow `cellAt_subset_of_shift_of_pend_past`'s own proof shape — `mem_cellAt_ladder_iff`, read `objAt`/`cntAt`/`nxtAt` off the witnessing state, derive the idle-past fact from the window hypothesis, apply Phase 3's raising primitive, rebuild the history with `exists_hist_of_isLadderPath`. *(deviation: altered — the idle-past fact is NOT derivable from the window hypothesis. `cntAt_le_nxtAt_succ_of_idle_past` runs one way only (idle past ⟹ window) and its converse is false, so the region start and the idle run are CARRIED, through a new existential-over-paths condition `WindowIdleRunWitnessed`, in the exact shape the landed `ForwardSlackWitnessed` takes for the pending-forever regime. Everything else in the task is as written: `mem_cellAt_ladder_iff`, the three read-offs, `exists_window_raise_ladderPath`, `exists_hist_of_isLadderPath`.)*
- [ ] Land the downward inclusion from the lowering primitive, in the same shape. *(deviation: skipped — EXCLUDED. The lowering primitive it consumes does not exist: Phase 3 excluded it on a compiled measurement, and the cycle-1 recorded decision re-scoped Phases 4-5 to the upward inclusion only. See `#### Reasoned Exclusions` below.)*
- [x] Record in both docstrings that neither inclusion carries `HasForwardSlack`: the downward direction, which in the pending-forever regime needs the witnessing hypothesis, is here paid for by the idle run below. *(deviation: altered — recorded in the upward inclusion's docstring and in `WindowIdleRunWitnessed`'s, since the downward inclusion is excluded. Both state that neither `HasForwardSlack` nor `ForwardSlackWitnessed` appears, and that the compensator is the idle run BELOW.)*
- [x] Guarded scoped build, `bash scripts/typst-sync-check.sh --fix`, stage `typst/generated/status.typ`. Apply the `longFile` rule if the file crosses 1500. *(the file is 1683 lines, inside Phase 3's existing `set_option linter.style.longFile 1700` window `1500 ≤ lines < 1700`, so no baseline change was owed.)*
- [x] If Phase 2's gate FAILED: close this phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record citing Phase 2's measurement. Land nothing. *(deviation: altered — Phase 2's gate PASSED, so this branch's "land nothing" does not apply. The marker and the record are used for the DIRECTION-SPECIFIC exclusion instead, exactly as Phase 3 used them, with Phase 3's own compiled measurement in the Evidence column.)*

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| The DOWNWARD cell inclusion (`c − j·(P + 1)` at `z`) | It is a lift of a primitive that does not exist. Phase 3 excluded the lowering primitive on a compiled measurement — the anchor clause reverses direction under deletion and its binding half becomes `nxtAt g z + jP ≤ cntAt g z + 2·d + 1`, a bound on the register from ABOVE, which `kappa_collision_window_room`'s lowering branch (`c ≤ n`) does not supply and which `nxtAt_le_cntAt_region_start`'s TIGHT bound leaves short by exactly the displacement. Under Phase 2's gate criterion a sixth hypothesis is a FAIL, not a widening. The cycle-1 recorded decision (`.decisions.json`) settled the disposition: stay one-directional and re-scope Phases 4-5 to the upward inclusion, rather than admit the sixth carried condition. Nothing was re-attempted here. | `window_lower_anchor_not_implied`, `window_lower_anchor_fails_at_tight_bound`, `window_lower_anchor_of_required` (`LadderWindow.lean`), and the probe `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean` (`lake env lean`, zero output) |
| The idle-past fact as a DERIVED rather than carried input | `cntAt_le_nxtAt_succ_of_idle_past` is one-directional: an idle position in the past puts the position inside the window, never the converse. A pending-forever path can satisfy `c ≤ n + 1` outright (take `c = 0`), so the window hypothesis returns no region start and no state-level variant of the regime's path data exists. The package is therefore carried, by `WindowIdleRunWitnessed`, which is existential over the paths through the state and so exactly as weak as the landed `ForwardSlackWitnessed` precedent — not universal, and asserted to hold nowhere. | `cntAt_le_nxtAt_succ_of_idle_past` and `pend_past_of_nxtAt_lt` (`LadderAgree.lean`); `WindowIdleRunWitnessed`'s own docstring; `cellAt_subset_of_window_raise` compiles with the condition carried and with no window hypothesis of its own (the room `c + m·(P+1) ≤ n` implies `¬ (n + 2 ≤ c)` by itself) |

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow` is the complete covering check; the two inclusions are new declarations in the same leaf module, whose only dependents are the two aggregators Phase 1 already wired.

**Scope Hypothesis**: estimated +140 lines for the two inclusions, putting the module near 540 lines. Confirm with `wc -l`; apply the `longFile` rule only on an actual crossing of 1500.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` - the upward and downward window-regime cell inclusions
- `typst/generated/status.typ` - regenerated count fields, staged in the same commit

**Verification**:
- Scoped guarded build green and warning-free. DONE: `lake-build-guard.sh ... build FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow`, guard exit 0, 2018 jobs, 0 errors, 0 warnings, green on the first attempt. The phase-end FULL library build is also green: guard exit 0, 2974 jobs, 0 errors, 0 warnings, `.olean` newer than source.
- `lean_verify` on both inclusions: no `sorryAx`. DONE for the one inclusion that exists: `cellAt_subset_of_window_raise` carries the standard profile `[propext, Classical.choice, Quot.sound]`, `trust: standard`, no non-standard axioms. The downward inclusion is excluded above, so there is no second declaration to verify.
- An exact-name sweep confirms neither inclusion was named with any prefix of `cellLE_zero_const_of_kappa_eq`. DONE: the landed names are `WindowIdleRunWitnessed` and `cellAt_subset_of_window_raise`; an exact-name declaration sweep over `FormalSystem/` returns 0 sites for `cellLE_zero_const_of_kappa_eq` itself.
- Batch-gate note: this phase's declared `**Verification Tier**` is `local`, not `full`, so the dispatch's batch-gate deferral directive does not bite here — the scoped guarded build named in the Tier Justification is the complete covering check and was independently run. The plan's final phase retains `**Verification Tier**: full`, unedited.

---

### Phase 5: The Window Schema, Its Theorem, and the Compiled Dichotomy [COMPLETED WITH EXCLUSIONS]

**Goal**: State the window regime's depth-`0` cell obligation as a schema, prove it from Phase 4's
two inclusions by `Set.Subset.antisymm`, and compile the dichotomy that makes the window and
pending-forever regimes exhaustive — so the regime this task closes is visibly one half of a
partition rather than an unquantified special case.

**Tasks**:
- [x] Land `def CellLEZeroConstOfKappaEqWindow` in `LadderWindow.lean`, in the shape the five `LadderCell.lean` schemas use: `ParamsOk` and the stab-free hypothesis as antecedents, then the collision, the register equality, the WINDOW hypotheses `¬ (n + 2 ≤ c)` and `¬ (n + 2 ≤ c')` where the landed schemas carry `n + 2 ≤ c`, the threshold bounds, the named idle-run condition at whichever pair carries the lower countdown, and cell EQUALITY as the conclusion. *(deviation: altered — landed as `CellSubsetOfKappaEqWindowRaise` with direction-indexed cell INCLUSION as the conclusion, not equality, and named for that. Everything else is as written: `ParamsOk` and the stab-free hypothesis as antecedents, the collision, the register equality built into the quantifier, both window hypotheses, both threshold bounds, and `WindowIdleRunWitnessed` demanded at the lower-countdown pair only. Equality is not reachable in this regime — there is ONE landed inclusion; see `#### Reasoned Exclusions`.)*
- [x] Land `theorem cellLE_zero_const_of_kappa_eq_window` proving that schema: destruct the collision with `kappa_collision_window_room`, dispatch the `c = c'` branch by `rfl`, and close each displacement branch by `Set.Subset.antisymm` of Phase 4's two inclusions. *(deviation: altered — landed as `cellSubset_of_kappa_eq_window_raise`. The destructor and the `rfl` branch are exactly as written; each displacement branch closes by the single landed `cellAt_subset_of_window_raise` applied from the lower countdown to the higher, with the reverse ordering discharged as vacuous (`0 < j * (P + 1)`), because `Set.Subset.antisymm` has no second inclusion to consume.)*
- [x] Land the exhaustiveness record: a compiled dichotomy stating that every `kappa` collision at a fixed register falls in the window regime or in the pending-forever gap, with no third case, so this schema and the five landed ones partition the fixed-register collisions. Derive it from `clipIdx_regime_of_eq` and `pend_past_of_nxtAt_lt` rather than asserting it. *(landed in full as `kappa_collision_window_or_pendPast_exhaustive`, with BOTH named lemmas consumed: `clipIdx_regime_of_eq` for the same-side arithmetic and `pend_past_of_nxtAt_lt` for the gap branch's path-level half. Nothing asserted.)*
- [x] The schema's docstring MUST carry the scope boundary in the record's own language, modelled on `CellLEZeroConstOfKappaEqForwardSlack`'s: what separates this schema from the reserved `CellLEZeroConstOfKappaEq` is the window hypotheses, the threshold bounds, and the named idle-run condition; the reserved name is claimed by nothing here; and being strictly stronger in hypotheses, this schema bears on the reserved statement's truth value in NEITHER direction. *(all three parts present, with the conclusion strength added as a fifth separator since the conclusion is weaker as well as the hypotheses stronger.)*
- [x] Do NOT name any declaration in this phase `cellLE_zero_const_of_kappa_eq` or any prefix of it. *(the three landed names are `CellSubsetOfKappaEqWindowRaise`, `cellSubset_of_kappa_eq_window_raise` and `kappa_collision_window_or_pendPast_exhaustive`; none is a prefix of the reserved name, and an exact-name declaration sweep over `FormalSystem/` still returns 0 sites for it.)*
- [x] Guarded scoped build, `bash scripts/typst-sync-check.sh --fix`, stage `typst/generated/status.typ`. Apply the `longFile` rule if the file crosses 1500. *(the module reached 1866 lines, crossing Phase 3's existing `set_option linter.style.longFile 1700` window, so the baseline was raised to 1900 at its own position.)*
- [x] If Phase 2's gate FAILED: close this phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record citing Phase 2's measurement. Land nothing — a schema with no theorem is not a deliverable, and the dichotomy alone is not this phase's goal. *(deviation: altered — Phase 2's gate PASSED, so this branch's "land nothing" does not apply. The marker and the record are used for the CONCLUSION-STRENGTH exclusion instead, exactly as Phases 3 and 4 used them, with Phase 3's own compiled measurement in the Evidence column. The schema, its theorem and the dichotomy are all landed.)*

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| Cell EQUALITY as the schema's conclusion (and with it the name `CellLEZeroConstOfKappaEqWindow` / `cellLE_zero_const_of_kappa_eq_window`) | `Set.Subset.antisymm` needs two inclusions and this regime has one. Phase 3 excluded the LOWERING composite splice on a compiled measurement — the `z`-anchored lift's anchor clause reverses direction under deletion, its binding half becoming `nxtAt g z + jP ≤ cntAt g z + 2*d + 1`, a bound on the register from ABOVE, which `kappa_collision_window_room`'s lowering branch (`c ≤ n`) does not supply and which `nxtAt_le_cntAt_region_start`'s TIGHT bound leaves short by exactly the displacement; Phase 4 therefore excluded the downward cell inclusion as a lift of a primitive that does not exist. Under Phase 2's gate criterion a sixth hypothesis is a FAIL, not a widening, and the cycle-1 recorded decision (`.decisions.json`) settled the disposition: stay one-directional and re-scope Phases 4-5 to the upward inclusion. The schema therefore concludes direction-indexed INCLUSION and says so in its name, rather than stating an equality that is not proved. Nothing was re-attempted here. | `window_lower_anchor_not_implied`, `window_lower_anchor_fails_at_tight_bound`, `window_lower_anchor_of_required` (`LadderWindow.lean`); the probe `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean` (`lake env lean`, zero output); Phase 3's and Phase 4's own `#### Reasoned Exclusions` records; `.decisions.json` cycle-1 answer |
| The reverse-ordering half of each displacement branch as a PROVED inclusion | It is vacuous, not proved, and is recorded as such in the theorem's docstring. A positive multiple of `P + 1` separating the two countdowns makes the opposite ordering contradictory (`0 < j * (P + 1)`), so that half of the conjunction is discharged by `absurd` rather than by a surgery. This is the honest shape of a one-directional result stated symmetrically; stating only the one direction would have hidden which pair the room pays for. | `cellSubset_of_kappa_eq_window_raise`'s two `absurd hle (by omega)` branches; `lean_verify` standard profile, no `sorryAx` |

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow` is the complete covering check; the schema, its theorem and the dichotomy are new declarations in the same leaf module and change no signature any other module reads.

**Scope Hypothesis**: estimated +180 lines, putting the module near 720 lines, still under the 1500 ceiling. Confirm with `wc -l`; apply the `longFile` rule only on an actual crossing. *(the per-phase delta held — +183 lines — but the absolute figure did not: the module was already 1683 lines at Phase 4's close, so it reached 1866 and the `longFile` baseline was raised from 1700 to 1900. The "near 720 lines" figure in this hypothesis was stale from Phase 3 onward, not wrong about this phase's own size.)*

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` - the window schema, its theorem, the exhaustiveness dichotomy, and the scope docstrings
- `typst/generated/status.typ` - regenerated count fields, staged in the same commit

**Verification**:
- Scoped guarded build green and warning-free. DONE: `lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow`, guard exit 0, 2018 jobs, 0 errors, 0 warnings. Green on the first attempt; one `unusedFintypeInType` warning on the dichotomy was fixed by dropping the unused `[Fintype Q]` and the rebuild is warning-free.
- `lean_verify` on the theorem and the dichotomy: no `sorryAx`, standard axiom profile. DONE: `cellSubset_of_kappa_eq_window_raise` carries `[propext, Classical.choice, Quot.sound]`, `trust: standard`; `kappa_collision_window_or_pendPast_exhaustive` carries `[propext, Quot.sound]`, `trust: standard`. No non-standard axioms, no `sorryAx` on either.
- The schema docstring contains the three-part scope boundary verbatim (what separates it from the reserved statement; that the reserved name is unclaimed; that it bears on the reserved statement in neither direction). DONE, with a fifth separator added for the weaker conclusion.
- An exact-name sweep confirms `cellLE_zero_const_of_kappa_eq` still has no declaration site under `FormalSystem/`. DONE: 0 declaration sites.
- Batch-gate note: this phase's declared `**Verification Tier**` is `local`, not `full`, so the dispatch's batch-gate deferral directive does not bite here — the scoped guarded build named in the Tier Justification is the complete covering check and was independently run. The plan's final phase retains `**Verification Tier**: full`, unedited. The phase-end FULL library build was additionally run and is green (see Phase Verification Notes).

---

### Phase 6: CONDITIONAL -- Compile the Window-Regime Obstruction [COMPLETED WITH EXCLUSIONS]

**Goal**: Runs only if Phase 2's gate FAILED. Turn the obstruction into a machine-checked record,
so the window branch is refuted rather than merely unproved, and record the consequence: the
ladder route for the realization theorem is closed in both regimes, which is the reportable
negative result the dispatch admits as a complete outcome.

**Tasks**:
- [ ] Write a `sorry`-free probe under `specs/evidence/ladder-window-regime/` whose theorem exhibits the failure: a ladder path in the window regime with an idle position in its past, the composite surgery at a positive displacement, and the clause whose compatibility fails for every admissible choice the construction can make. Model it on `specs/evidence/forward-slack-pin-cascade/pin-cascade-straddle.lean`'s shape — a theorem for the obstruction, a concrete object for non-vacuity, and exhaustion over the choices the construction admits. *(deviation: skipped — FAIL-branch-only task and Phase 2's gate measured PASS; there is no window-regime obstruction to compile. See `#### Reasoned Exclusions`.)*
- [x] Add the probe's path to `scripts/check-evidence-probes.sh`'s `WIRED` list with a one-line entry saying what it holds in place. A probe under `specs/` is reached by no Lake target, so without the entry it rots silently. *(deviation: altered — no window-regime probe exists to wire (gate PASSED), so this task was discharged against the obstruction this task ACTUALLY compiled, exactly as this phase's `**Files to modify**` note directs ("adjust the directory and file name to the obstruction actually measured"): `evidence/lowering-anchor-deficit.lean`, the lowering-direction anchor deficit that Phases 3, 4 and 5 each cite as the Evidence for their own exclusion. It was unwired and therefore rotting unguarded. Wired under `WIRED_REPO` rather than `WIRED` because three landed Reasoned Exclusions records cite its task-directory path verbatim — the same deferred-move-with-a-named-blocker form the existing `WIRED_REPO` entry uses — with the owed promotion to `specs/evidence/seam-gluing-ray-product/` recorded beside the entry and flagged as due before archival.)*
- [ ] Record the verdict in `LadderWindow.lean`'s module docstring: the window regime is refuted at the named clause; the ladder route for the realization theorem is closed in both regimes; `cellLE_zero_const_of_kappa_eq` is unreachable by the composite-splice route and stays claimed by nothing. *(deviation: skipped — FAIL-branch-only task, and its content is counterfactual: the window regime is NOT refuted and the ladder route is NOT closed in both regimes. Writing it would put a false verdict in the module docstring. See `#### Reasoned Exclusions`.)*
- [ ] Record the consequence in the DURABLE record — this task's own description in `specs/state.json` — rather than in any dispatch-created sidecar, and name it in the summary artifact. *(deviation: skipped — FAIL-branch-only task; the consequence it would record (the ladder route closed in both regimes) did not occur. The PASS-branch outcome is recorded in the summary artifact by Phase 7's own verdict task.)*
- [x] If Phase 2's gate PASSED: close this phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record whose Evidence column cites Phase 2's passing measurement. Land nothing. *(done — this is the branch taken. No probe, no docstring verdict, no durable-record amendment. The one edit made is the guard entry above, which lands no new obstruction and only stops an already-landed one from rotting.)*

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| The window-regime obstruction probe (`specs/evidence/ladder-window-regime/window-pin-compensation.lean`) and its `WIRED` entry | This entire phase is conditional on Phase 2's decision gate FAILING, and the gate measured PASS. Both of the lift's measured clauses closed for the composite walk with no hypothesis beyond the five the gate criterion admits — `ParamsOk`, the two window hypotheses, `Tc ≤ c`, the collision's room, and the one named idle-run condition `HasIdleRunBelow`. There is therefore no window-regime obstruction in existence to compile, and a probe asserting one would be false rather than merely unnecessary. The plan's own PASS branch for this phase is "Land nothing", and that is what was done. | Plan `## Phase Verification Notes`, `### Verification notes: phase 2 (measured) -- GATE VERDICT: PASS`, whose clause table names the discharging lemma for each of `hw`, `hidle`, `hpp`, `hpi`, `hpins`, `hn0` and records "No sixth hypothesis was needed, so this is a PASS, not a widening"; Phase 2's heading marker `[COMPLETED]` (not `[COMPLETED WITH EXCLUSIONS]`); the landed `window_anchor_clause_of_pin_classification`, `window_pin_pair_raise_of_slack`, `nxtAt_le_cntAt_region_start`, `regionStart_spacing` and `HasIdleRunBelow` in `LadderWindow.lean`, all compiled `sorry`-free with a standard axiom profile |
| The `LadderWindow.lean` module-docstring verdict line ("the window regime is refuted at the named clause; the ladder route is closed in both regimes") | Counterfactual on the branch actually taken. The window regime is closed POSITIVELY — one-directionally, under `CellSubsetOfKappaEqWindowRaise` — not refuted; and the ladder route is closed in neither regime by this task. Landing this text would put a false statement in the record, which is a worse outcome than an absent one. The accurate verdict is Phase 7's own final task and belongs there, stated once. | `cellSubset_of_kappa_eq_window_raise` and `kappa_collision_window_or_pendPast_exhaustive`, both landed and `sorry`-free (Phase 5's verification notes; `lean_verify` standard profile, no `sorryAx`); Phase 5's `#### Reasoned Exclusions`, which records the result as one-directional INCLUSION rather than refuted |
| The durable-record (`specs/state.json` task description) amendment | Its content is the same counterfactual consequence as the row above — "the ladder route for the realization theorem is closed in both regimes" — which did not occur. Amending the durable record to say so would be a false durable claim. No amendment is owed on the PASS branch: the task's description already states the two admissible outcomes, and the one reached is the positive one. | Same evidence as the row above; the dispatch's own recorded prior decision (`.decisions.json`, cycle 2, Target A) which re-scoped the task to this regime and anticipated the positive outcome |

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: `bash scripts/check-evidence-probes.sh` compiles the new probe through `lake env lean` and is the complete covering check for it; the accompanying docstring edit has no elaboration surface beyond the scoped module build Phase 5 already names.

**Scope Hypothesis**: this phase lands content only on the FAIL branch, and the probe is estimated at one file of 80-140 lines plus one `WIRED` entry. Confirm the branch from Phase 2's recorded measurement before starting, and confirm the probe compiles via `check-evidence-probes.sh` rather than by reading it.

**Files to modify**:
- `specs/evidence/ladder-window-regime/window-pin-compensation.lean` - the new wired probe (FAIL branch only; adjust the directory and file name to the obstruction actually measured)
- `scripts/check-evidence-probes.sh` - the probe's `WIRED` entry (FAIL branch only); exists, and gains one line rather than being rewritten
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` - the module docstring recording the verdict (FAIL branch only)
- `typst/generated/status.typ` - regenerated count fields if any `.lean` line count moved, staged in the same commit

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 with the new probe compiled and no pre-existing probe newly red (stated as a delta against the pre-task run, not an absolute count). DONE: exit 0, `PASS  all 54 wired probe(s) compile`. Delta against the pre-phase run: +1 wired probe (53 -> 54), that one being `specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean` at `PASS`; zero probes moved from PASS to FAIL, and the single `SKIP` (`spike-untl-unfolding-and-fwd-obstruction`, deliberately deferred in the script's own `DEFERRED` block) is unchanged. No window-regime probe was written — see `#### Reasoned Exclusions`.
- The probe is `sorry`-free and axiom-free beyond the standard profile. DONE for the probe actually wired: `timeout 540 lake env lean specs/918_ladder_cell_index_positive_factorization/evidence/lowering-anchor-deficit.lean` exits 0 with zero output; a `sorry`/`axiom` sweep over the file returns no occurrence; all three theorems (`lowering_anchor_not_implied`, `lowering_anchor_of_required`, `lowering_anchor_fails_at_tight_bound`) close by `omega` alone, so nothing beyond the standard profile is reachable.
- The verdict appears in the durable record, not only in this plan. NOT APPLICABLE on this branch, and deliberately so: the verdict this bullet asks for is the FAIL branch's ("the window regime is refuted; the ladder route is closed in both regimes"), which is counterfactual here. No false verdict was written to the durable record. The PASS-branch verdict is Phase 7's own final task.
- Batch-gate note: this phase's declared `**Verification Tier**` is `local`, not `full`, so the dispatch's batch-gate deferral directive does not bite here — `bash scripts/check-evidence-probes.sh`, the covering check named in the Tier Justification, was independently run in full (all 54 probes, not a scoped subset). The plan's final phase retains `**Verification Tier**: full`, unedited.

---

### Phase 7: Records, Generated Surfaces and Final Verification [COMPLETED]

**Goal**: Land the test-file pin block, reconcile every generated surface, set or re-tighten the
`longFile` baseline, and run the complete gate set. The verdict — the window regime closed, or
the window regime refuted — is stated explicitly here, never left tacit.

**Tasks**:
- [x] Update `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`'s Requirement (W) narrative to the actual outcome. On the PASS branch: the window regime is closed under its own named schema, the five pending-forever schemas are unchanged, the two regimes are exhaustive by the Phase 5 dichotomy, and the reserved `cellLE_zero_const_of_kappa_eq` is STILL claimed by nothing because the window schema carries the idle-run condition and the threshold bounds. On the FAIL branch: the window regime is refuted at the named clause and the ladder route is closed in both regimes. *(PASS branch taken. Nine new `/-! ## Requirement (W): ...` sections landed, covering the regime's arithmetic, the decision gate's clause lemmas, the composite splice, the iterate, the idle lengthening and where each resource is spent, the raising primitive, the lowering direction's MEASURED deficit, the upward cell inclusion, and the schema with the compiled dichotomy. All four PASS-branch elements are stated: the regime closed under `CellSubsetOfKappaEqWindowRaise`; the five pending-forever schemas unchanged; the two regimes exhaustive by `kappa_collision_window_or_pendPast_exhaustive`; and the reserved name still claimed by nothing, with the five separators named. No pre-existing narrative needed repair: the FORWARD-SLACK section's claims (`ForwardSlackWitnessed` still a hypothesis on all five schemas; the saturated-gap branch addressed by no landed inclusion) are all still true, since the window schema carries the register equality built into its collision.)*
- [x] Add `#print axioms` pins (with `#guard_msgs`) for every declaration this task landed, following the file's existing pin convention. *(all 42 declarations of `LadderWindow.lean` pinned -- the complete set, verified by a scripted diff of the pinned names against a declaration sweep of the module. Pin bodies were GENERATED from a compiled `#print axioms` probe over the module (`lake env lean`, exit 0) rather than hand-predicted, so the `#guard_msgs` message wrapping is measured. Measured profiles: 29 at `[propext, Quot.sound]`, 13 at the standard `[propext, Classical.choice, Quot.sound]`, zero `sorryAx`, zero axiom outside the standard three. Green on the first test-library build.)*
- [x] Set or re-tighten `set_option linter.style.longFile N` in `LadderWindow.lean` to the smallest value satisfying the linter's `N - 200 ≤ lines < N` window at the file's FINAL line count — or confirm the file stayed below 1500 and that no baseline is owed. An earlier phase's judgement is wrong by construction once later phases have grown the file. *(this phase's own docstring edits grew the module from 1866 to 1907 lines, crossing Phase 5's baseline of 1900; raised to 2000, which satisfies `1800 ≤ 1907 < 2000`. The test file also crossed: 2532 to 2873 lines, so its baseline moved from 2600 to 2900, satisfying `2700 ≤ 2873 < 2900`. Both confirmed by a warning-free build, which is where this linter reports.)*
- [x] Regenerate the module-inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`, then verify with `--emit-inventory --check`. This is Condition 1's surface (a) and is legitimately deferred to here. *(deviation: altered -- executed EARLY, at the close of Phase 3 rather than in Phase 7, because this dispatch ends at Phase 3 `[PARTIAL]` and the new module had turned the `INV` group RED; leaving a gate red from this task's own file was the worse option. The regeneration rewrote FOUR tracked files, two of them absent from this phase's file list -- `FormalSystem/README.md` and `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, the latter declared READ-ONLY by the risk table -- which is exactly the case this phase's Scope Hypothesis instructs be resolved by adding what the regeneration actually touches. The row's hand-written description cell was supplied rather than left at the generator's `<!-- TODO: add description -->` placeholder. `--emit-inventory --check` exits 0.)*
- [x] Run `bash scripts/typst-sync-check.sh --fix` one final time and stage `typst/generated/status.typ`. *(run twice -- once after the pin block landed and once after the docstring repairs moved the counts again; `--fix` exit 0 both times, and the read-only re-run is PASS on all four checks.)*
- [x] Run the complete gate set and record each result: the unscoped guarded `lake build`; the test library (`lake build BimodalTest`); `lake exe mk_all --lib FormalSystem --check`; `bash scripts/check-module-invariants.sh`; `bash scripts/typst-sync-check.sh`; `bash scripts/check-metalogic-cycles.sh`; `bash scripts/check-evidence-probes.sh`; `bash scripts/check-copyright-headers.sh`; and `bash .claude/scripts/validate-artifact.sh specs/918_ladder_cell_index_positive_factorization/plans/01_ladder-cell-window-regime.md plan`. *(all nine run and tabled in the Phase Verification Notes below. The dispatch's batch-gate deferral directive offered a SCOPED tier in place of the full set; it was NOT taken -- the complete nine-command set was run independently, so nothing is owed to the batch stage on this phase's behalf.)*
- [x] For each gate, distinguish findings that name this task's own touched files from the tree's standing baseline. `check-module-invariants.sh`'s C16 group is already failing on `LadderPump.lean` from a concurrent sibling: enumerate and attribute it with `git log -S`, and do NOT edit that out-of-scope file. A gate whose only failures are pre-existing and outside this task's file scope is a recorded PASS for this phase. *(done, and the attribution found one finding this instruction did NOT anticipate: C9 was failing on THIS task's own `LadderWindow.lean`, which is in scope and was therefore repaired rather than attributed away. See the Phase Verification Notes for both.)*
- [x] State the task's verdict in the summary artifact, in one sentence, naming which outcome was reached and that the re-scope to the window regime was the prior cycle's recorded decision rather than a drift from the dispatch. *(stated in the summary artifact's Overview, and additionally landed as a `## Verdict` section in `LadderWindow.lean`'s own module docstring so the record does not live only in a task artifact.)*

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: the file list below is the set of generated and record surfaces a Lean line-count change and a new module are expected to move, enumerated from gate-collision Conditions 1 and 7 and from C33 at authoring time. Confirm it by running the regeneration commands and reading which tracked files they actually rewrite — add any file they touch that is absent here, and drop any that comes back unchanged, rather than forcing a surface to appear in the diff.

**Files to modify**:
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the Requirement (W) narrative and the new axiom pins; exists at 2532 lines with a `longFile` baseline of 2600, confirmed at authoring time, and is amended rather than created *(reached 2873 lines; baseline raised to 2900)*
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` - the final `longFile` decision and the verdict line in the module docstring *(reached 1907 lines; baseline raised to 2000. Two unlisted-but-necessary edits to the same file beyond the verdict: the stale `## What this module does not hold` section, which still claimed "No path-level construction, no cell-level inclusion, and no schema" after Phases 3-5 landed all three, and the C9 task-path citation repair)*
- `README.md` - regenerated module-inventory block
- `FormalSystem/Metalogic/README.md` - regenerated module-inventory block
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - regenerated module-inventory block *(added per the Scope Hypothesis: the regeneration rewrote it, and the hypothesis directs adding what the command actually touches)*
- `typst/generated/status.typ` - final regenerated count fields

**Verification**:
- The complete gate set runs and is recorded: `bash .claude/scripts/verify-deploy.sh` is not the gate set for this repository's Lean work, so the complete set is the nine commands enumerated in this phase's task list, each run and each result tabled, with pre-existing findings outside this task's file scope enumerated and attributed rather than absorbed. DONE: all nine run and tabled in `## Phase Verification Notes`, `### Verification notes: phase 7 (measured)`. The scoped batch-gate alternative the dispatch offered was NOT taken, so nothing is owed to the batch stage on this phase's behalf. C16 is attributed to a concurrent sibling's `LadderPump.lean` by `git log -S` and recorded PASS; C9 named this task's OWN file and was repaired rather than attributed away.
- The unscoped guarded `lake build` is green with zero errors and zero warnings. DONE: guard exit 0, 2974 jobs, `error:` 0, `warning:` 0, and `.olean` newer than source for both touched modules.
- `lake build BimodalTest` is green with every `#guard_msgs` axiom pin satisfied, including the new ones. DONE: guard exit 0, 3042 jobs, 0 errors, 0 warnings, all 42 new pins green on the first attempt.
- `LadderWindow.lean`'s `longFile` posture is correct at the final line count: a baseline inside the linter's acceptance window, or no baseline and a count below 1500. DONE: 1907 lines at baseline 2000 (`1800 ≤ 1907 < 2000`). The test file's own posture was corrected on the same rule: 2873 lines at baseline 2900.
- `bash .claude/scripts/validate-artifact.sh specs/918_ladder_cell_index_positive_factorization/plans/01_ladder-cell-window-regime.md plan` passes. DONE: exit 0, 0 warnings.
- The verdict sentence is present and names the outcome reached. DONE: landed as a `## Verdict` section in `LadderWindow.lean`'s module docstring, not only in the task artifact, and restated in the summary artifact's Overview.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell
import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle

namespace FormalSystem.Metalogic.Decidability.RaySummary

theorem kappa_collision_window_room (Tc Tn P B c n c' : ℕ) (hB : 2 ≤ B)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n))
    (hwin : ¬ (n + 2 ≤ c)) (hwin' : ¬ (n + 2 ≤ c')) :
    c = c' ∨ ∃ j : ℕ, 0 < j ∧
      ((c' = c + j * (P + 1) ∧ c' ≤ n) ∨ (c = c' + j * (P + 1) ∧ c ≤ n)) := sorry

theorem window_anchor_compat_of_room (c n d jP : ℕ) (hroom : c + jP ≤ n)
    (hlow : n ≤ c + 2 * d) :
    (((c + d + jP : ℕ) : ℤ) - (n : ℤ)).natAbs ≤ d := sorry

theorem window_pin_compat_raise_of_gap (c d W jP DW : ℕ)
    (horig : (((c + d : ℕ) : ℤ) - (W : ℤ)).natAbs ≤ DW) :
    (((c + d + jP : ℕ) : ℤ) - (W : ℤ)).natAbs ≤ DW + jP := sorry

theorem window_pin_compat_lower_of_spacing (c d W jP DW : ℕ)
    (hsp : W + 1 + jP ≤ DW)
    (horig : ((c + d + jP : ℕ) : ℤ) - (W : ℤ) ≤ (DW : ℤ)) :
    (((c + d : ℕ) : ℤ) - (W : ℤ)).natAbs ≤ DW - jP := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

Every statement above is compiled `sorry`-free at plan-authoring time in
`specs/918_ladder_cell_index_positive_factorization/evidence/plan-gate-arithmetic.lean`
(`lake env lean`, zero output), with the bodies Phase 1 lifts verbatim. The pins are therefore
measurements, not predictions.

## Decisions

- **The task is planned at its re-scoped target, not at its dispatched words.** The dispatch's
  second admissible outcome is foreclosed by `paramsOk_params` and its first reduces to an
  obligation task 917 refuted its only landed route against. The prior cycle's recorded decision
  (`.decisions.json`, cycle 2) selected Target A, the ordinary window regime. Planning the
  dispatch's two outcomes verbatim would be planning work that is either impossible or already
  measured.
- **The work lands in a NEW leaf module, `LadderWindow.lean`, rather than in `LadderCell.lean`.**
  Three reasons, in order of weight. First, the construction needs the idle-splice layer, which
  lives in `LadderIdle.lean` — a sibling leaf that `LadderCell.lean` does not import, so the
  alternative would have been to add an import to a file two concurrent sibling tasks are already
  reading. Second, `LadderCell.lean` sits at 1991 lines against a `longFile` baseline of 2000,
  so any addition there forces an immediate baseline move; a new file starts with no baseline
  owed. Third, territory: `LadderAgree.lean` is in another task's declared `file_scope` and
  `RaySummary/README.md` in a third's, and a new module keeps this task's writes disjoint from
  both. The cost is the new-module plumbing, which Phase 1 schedules explicitly.
- **Only the four compiled statements are pinned in `## Lean Challenge Statements`.** The
  gate-dependent declarations — the composite-splice primitives, the two cell inclusions, the
  window schema and its theorem — are deliberately NOT pinned and are deliberately absent from
  `- **Goals**:`. Their hypothesis sets are precisely what Phase 2's gate measures, and pinning
  an unmeasured signature is the defect that forced a mid-task revision on task 917, whose Phase
  4 pin was short by exactly one inequality. Under `rules/plan-compliance.md`'s Statement
  Fidelity section a pinned signature is part of the contract and a deficit is grounds to mark a
  phase `[BLOCKED]`; this plan therefore pins only what it has already compiled, and leaves the
  rest to be stated against the gate's own output.
- **`Goal Polarity` is left absent, i.e. must-exist.** All four named identifiers are
  unconditional Phase 1 deliverables that land whatever the gate decides, so the default
  must-exist semantics is the correct one and no `mixed` declaration is needed. The separate
  must-be-ABSENT claim — that `cellLE_zero_const_of_kappa_eq` still has no declaration site — is
  carried as a Testing & Validation criterion rather than as a Goal, so the two polarities never
  have to share one field.
- **The idle run below is the compensator, and that is why this regime is reachable at all.** The
  pending-forever regime has no idle run below `z` to spend, which is exactly why it must look
  for slack ABOVE and why route (d) died there. The window regime's defining feature is that
  such a run exists. The plan is built on that asymmetry rather than on a variant of the refuted
  route, and no phase re-enters route (d).
- **A carried idle-run condition is an acceptable terminus; a weakened substitute for the
  reserved statement is not.** If the window schema lands carrying the named idle-run condition,
  that is a complete, honestly scoped result and the reserved name stays unclaimed. What is not
  acceptable is naming such a result `cellLE_zero_const_of_kappa_eq`, or presenting it as the
  positive factorization lemma the dispatch asked for.
- **The plan file's slug names the re-scoped content.** The report round is numbered `01` and the
  plan reuses that round number, but the slug reads `ladder-cell-window-regime` rather than
  echoing the report's `ladder-cell-index-positive-factorization`, because the latter names an
  outcome this plan explicitly does not claim.

## Testing & Validation

- [ ] Every new declaration elaborates with no `sorry` and no new axiom beyond the standard
      `propext`/`Classical.choice`/`Quot.sound` profile (`lean_verify` per name).
- [ ] Every new declaration is warning-free: no `linter.autoImplicit`, no `linter.style.show`, no
      unused variable, no unused instance argument. CI builds with `--wfail`, so a warning is a
      failure.
- [ ] The four pinned statements land exactly as pinned in `## Lean Challenge Statements`; a
      deficit is grounds to mark the phase `[BLOCKED]` and raise it, never to edit the pin.
- [ ] An exact-name sweep confirms `cellLE_zero_const_of_kappa_eq` has no declaration site
      anywhere under `FormalSystem/`, and that no declaration this task landed carries that name
      or any prefix of it.
- [ ] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` builds with every `#guard_msgs`
      axiom pin satisfied, including the new ones.
- [ ] `lake exe mk_all --lib FormalSystem --check`, `bash scripts/check-copyright-headers.sh` and
      `bash scripts/check-metalogic-cycles.sh` are green.
- [ ] `bash scripts/check-module-invariants.sh` and `bash scripts/typst-sync-check.sh` are green,
      or green modulo enumerated pre-existing findings outside this task's file scope.
- [ ] `bash scripts/check-evidence-probes.sh` is green and no pre-existing probe is newly red.
- [ ] `LadderWindow.lean`'s `longFile` posture is correct at the final line count: a baseline
      inside the linter's `N - 200 ≤ lines < N` window, or no baseline and a count below 1500.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderWindow.lean` — the new leaf module: the
  four compiled arithmetic statements, the named idle-run condition, the two composite-splice
  primitives, the two window-regime cell inclusions, the window schema with its theorem, and the
  exhaustiveness dichotomy (the last five gate permitting).
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` and `FormalSystem.lean` — the aggregator
  import and the regenerated library root.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — the updated Requirement (W)
  narrative and the new axiom pins.
- `specs/evidence/ladder-window-regime/` probe plus its `check-evidence-probes.sh` `WIRED` entry,
  on the obstruction branch only.
- Regenerated generated surfaces: `typst/generated/status.typ`, and `README.md`'s and
  `FormalSystem/Metalogic/README.md`'s module-inventory blocks.
- `specs/918_ladder_cell_index_positive_factorization/evidence/plan-gate-arithmetic.lean` — the
  plan-time gate measurement, already written and already compiled, preserved as task evidence.
- `specs/918_ladder_cell_index_positive_factorization/summaries/01_ladder-cell-window-regime-summary.md`
  carrying the verdict sentence.

## Rollback/Contingency

Each phase commits once, green, with its generated-surface regeneration staged alongside its Lean
change, so reverting is a per-phase `git revert` of a single commit and no cross-phase unwinding
is needed. Phase 1 is independent of the gate's outcome and is kept whatever Phase 2 decides.
Because every declaration lands in one new file, a full rollback of the Lean work is the removal
of that file plus the two aggregator lines — a smaller blast radius than editing any existing
RaySummary module would have given.

If a phase must be abandoned mid-edit with uncommitted work in the tree, take a durable,
non-reverting checkpoint first (`bash .claude/scripts/git-snapshot.sh 918 --no-revert`) and then
decide; only a genuine rollback uses the default reverting mode, per
`context/contracts/recovery.md`'s rollback rung, including its out-of-scope override flag for the
deliberate whole-tree case.

Two contingencies are planned rather than improvised. If Phase 2's gate fails, Phases 3, 4 and 5
close `[COMPLETED WITH EXCLUSIONS]` citing its measurement and Phase 6 compiles the obstruction —
the task still lands the new module, the four arithmetic statements, the named idle-run condition,
and a machine-checked refutation of the window branch, which closes the ladder route in both
regimes and is the reportable negative the dispatch admits. If the raising primitive lands but
the lowering one does not, the upward inclusion is landed alone and the schema is recorded as
excluded with the specific clause that did not go through; a one-directional result is an honest
partial, and the two directions are not bundled into one all-or-nothing step.

## Phase Verification Notes

### Verification notes: phase 1 (measured)

- Exact-name sweep: all four names (`kappa_collision_window_room`,
  `window_anchor_compat_of_room`, `window_pin_compat_raise_of_gap`,
  `window_pin_compat_lower_of_spacing`) had no declaration site under `FormalSystem/`, `Tests/`
  or `specs/evidence/` before this phase.
- Scoped guarded build of `...RaySummary.LadderWindow` + `...RaySummary`: green,
  `error:` count 0, `warning:` count 0.
- Phase-end FULL guarded `lake build`: green (2974 jobs), 0 errors, 0 warnings; `.olean` newer
  than source confirmed for `LadderWindow`, `RaySummary` and `FormalSystem`.
- `lake exe mk_all --lib FormalSystem --check`: exit 0 ("No update necessary") after
  regeneration. The regeneration itself rewrote exactly one tracked file, `FormalSystem.lean`
  (+1 line), confirming the Scope Hypothesis's aggregator set.
- `bash scripts/check-copyright-headers.sh`: exit 0, total 754 -> 755 (exactly +1).
- `bash scripts/check-metalogic-cycles.sh`: exit 0, run rather than assumed; Assertion B reports
  "upward import set is exactly the recorded 10 line(s)" — NO surplus edge, so the frozen
  allowlist was not extended and `scripts/check-metalogic-cycles.sh` stayed out of this phase's
  file list.
- `bash scripts/typst-sync-check.sh --fix` then `--counts-only`: exit 0, `MISMATCH_COUNT=0`;
  `typst/generated/status.typ` staged in this phase's commit.
- `lean_verify` per name: standard profile, no `sorryAx`
  (`kappa_collision_window_room`: `propext`, `Classical.choice`, `Quot.sound`; the three pin
  statements: `propext`, `Quot.sound`).
- Scope Hypothesis outcome: estimated 120-160 lines, ACTUAL 163 (`wc -l`) — a 3-line overshoot,
  still far below the 1500 `longFile` ceiling, so no baseline is owed at this phase.

### Verification notes: phase 2 (measured) -- GATE VERDICT: PASS

**Clause inventory, read off `exists_ladderPath_of_walk_nxt_at`'s signature**
(`LadderChain.lean:657`), not from memory: `hw`, `hidle`, `hpp`, `hpi`, `hpins`, `hn0`.

| Clause | Discharged by | Status |
|---|---|---|
| `hw` | `objAt_step` on the composite ladder path | free |
| `hidle` | `cntAt_eq_zero_of_idle` | free |
| `hpp` | `cntAt_succ_of_pend_pend` | free |
| `hpi` | `cntAt_eq_zero_of_pend_idle` | free |
| `hpins` | `pinCompat_of_ladderPath` on the composite; the composite's OWN construction spends the compensator, via `window_pin_pair_raise_of_slack` + `no_pin_in_idle_run` | measured, closes |
| `hn0` | `window_anchor_clause_of_pin_classification` (landed, compiled) | measured, closes |

**The two region-start facts (task 2), established rather than assumed**: landed as
`nxtAt_le_cntAt_region_start` in `LadderWindow.lean`, deriving BOTH
`cntAt g (a+1) = cntAt g z + d` (`cntAt_add_of_pend_back`) and `nxtAt g z <= cntAt g z + 2d + 1`
(`cntAt_eq_nxtAt_of_idle_pend` composed with `nxtAt_lipschitz`). Note the `+ 1`: the path gives
`n <= c + 2d + 1`, one slacker than the pinned `window_anchor_compat_of_room`'s `hlow`, so the
construction consumes the new `window_anchor_compat_at_region_start` at displacement `d + 1`. The
pinned statement is unchanged and still lands exactly as pinned.

**The region-start spacing fact (task 3), confirmed before anything rests on it**: NOT found
landed among the three named candidates in the form needed; landed here as `regionStart_spacing`,
derived from `cntAt_sub_of_pend` alone -- no parameter condition, no regime hypothesis.

**The gate attempt (task 4) and criterion (task 5)**: both clauses close with NO hypothesis
beyond `ParamsOk`, the two window hypotheses, `Tc <= c`, the collision's room, and the ONE named
idle-run condition `HasIdleRunBelow` (landed as a `def`: the `idleBudget pend phi + 1` positions
at and below the region start are idle). No sixth hypothesis was needed, so this is a PASS, not a
widening.

**A measurement that corrected a plan prediction**: the compensator's LENGTH (`jP <= E`) was
written into the anchor-clause lemma and the elaborator reported it UNREFERENCED. The idle
insertion displaces the region start and the anchor by the same amount, so their distance is
unchanged and the anchor clause never reads `E`. The compensator is spent entirely in the pin
PAIR clause, against pins strictly below the lengthened run, which is why
`window_pin_pair_raise_of_slack` carries `jP <= E` as a live hypothesis and the anchor lemma does
not. This is recorded in the module docstring at the lemma itself.

- Scoped guarded build: green, 0 errors, 0 warnings.
- Phase-end FULL guarded `lake build`: green (2974 jobs), 0 errors, 0 warnings.
- `bash scripts/typst-sync-check.sh --fix` then `--counts-only`: `MISMATCH_COUNT=0`.
- Scope Hypothesis outcome: estimated +60 lines on the PASS branch; ACTUAL +243 (163 -> 406
  `wc -l`). The overshoot is the gate's own compiled measurement -- the plan anticipated the
  named `def` plus a spacing lemma, and the measurement additionally landed the pin
  classification lemma, the two distance-growth lemmas, the region-start arithmetic and the
  slack lemma, all of which Phase 3 consumes rather than re-deriving. Still far below the 1500
  `longFile` ceiling, so no baseline is owed.

### Verification notes: phase 3, first dispatch (measured) -- PARTIAL AT THE TIME

**What landed, green and committed** (`3686ab01e`, zero errors, zero warnings, no `sorry`, standard
axiom profile):

- `region_run_of_region_start` -- the translation between the landed
  `exists_region_start_of_idle_past`'s quantifier-over-positions maximality clause and the
  quantifier-over-backward-distances form `cntAt_add_of_pend_back` is indexed by.
- `exists_idleBlock_of_hasIdleRunBelow` -- the named idle-run condition spent, once, on the
  EXISTENCE of a type-respecting idle block, through `exists_idleTypeBlock_of_budget_le_run`.
- `window_composite_pin_trichotomy` -- the composite walk's pin classification, which is exactly
  Phase 2's gate hypothesis `hclass` discharged. Three classes: a pin strictly below the region
  start carried unchanged, the region start displaced by `E` with its countdown raised by `l`, and
  a pin at or above `z` displaced by `E + l` with its countdown unmoved.
- `window_composite_pins` -- the pin PAIR clause for the composite, nine pin-class pairs, eight
  closing on `pinCompat_of_ladderPath` and a rigid displacement and the ninth spending the
  compensator through `l <= E`.
- `exists_window_composite_ladderPath` -- the RAISING primitive's admissibility half at ONE block
  length: the composite walk lifted to a ladder path with the countdown raised by `l` at the
  displaced comparison position and the register held at the ORIGINAL path's `nxtAt g z`. Lifted
  twice -- anchor-free (`exists_ladderPath_of_walk_of_pins`) to put the trichotomy on a genuine
  ladder path, then through the `z`-anchored lift at the PRESCRIBED register value.

**What does NOT yet land, stated precisely rather than as "more work"** -- three items, in
dependency order:

1. **The iteration to an exact multiple of `P + 1`.** `exists_window_composite_ladderPath` raises
   by one block length `l`. `(K1)` puts `l` among the divisors of `P + 1`
   (`typeBlock_length_dvd_of_paramsOk`), so `m * q * l = m * (P + 1)` is reachable, but only
   through an ITERATE, and the landed iterate
   `exists_iterSpliced_ladderPath_idx_of_pend_past` carries `hpast` -- the pending-forever
   hypothesis this regime denies -- in two places: inside its per-step
   `exists_spliced_ladderPath_of_pend_past`, and in the `hpend_all` step of its own anchor-clause
   proof. A window-regime analogue is owed.
2. **The model-level half (the realized type carried through both splices).**
   `tpOf_eq_spliceIdx_of_tpOf_eq` for the pending stage and
   `exists_iterIdleSpliced_ladderPath`'s own type clause for the idle stage; the idle stage's
   clause is exposed only strictly BELOW the block, so the type at the comparison position needs
   the shift form of `tpOf_stabFree_eq_of_objAt_eq`.
3. **The LOWERING primitive.** Untouched. Its pin pair clause is
   `window_pin_compat_lower_of_spacing` against `regionStart_spacing`, both landed in Phase 2.

**The iterable reformulation, worked out and recorded so the next dispatch does not re-derive
it.** The landed trichotomy and pin clause are stated RELATIVE TO the original path `g` (via the
hypotheses `hbelow`/`habove`, "`g1` is `g` displaced by `E`"), which is what the base case
supplies but is NOT preserved by a second splice -- after one splice the path is `g` displaced by
`E` AND raised by `l`, which is not a pure displacement. The self-contained, ITERABLE form states
every clause about `g1` alone and carries a decreasing budget `R`:

- the trichotomy's hypotheses reduce to `0 < l`, `a1 < u`, `pend (objAt g1 a1) = false`,
  `pend` on all of `(a1, u + l]`, and `u <= a1 + 1 + cntAt g1 (a1 + 1)` -- with NO reference to
  `g` and no idle-run hypothesis at all, since a pin at or above `a1` is forced to BE `a1` by the
  pending stretch;
- the classes become `w + 1 < a1` / `w = a1` / `u <= w`, all pins of `g1`, with countdowns
  `cntAt g1 (w + 1)` / `cntAt g1 (a1 + 1) + l` / `cntAt g1 (w + 1)`;
- the pin pair clause needs ONE extra invariant, used only at the (class 1, class 2) pair:
  `|cntAt g1 (a1 + 1) - cntAt g1 (w + 1)| + R <= a1 - w` for every pin `w < a1`, with `l <= R`.
  The step consumes exactly `l` from `R`, so the invariant reproduces itself;
- the anchor clause becomes its own invariant -- `|cntAt g1 (v + 1) - nxtAt g z| <= |v - z1|` at
  every pin of `g1` -- preserved at class 1 and class 3 directly, and at class 2 from the
  companion budget invariant `cntAt g1 (a1 + 1) + R <= nxtAt g z + (z - a)`, which the step also
  reproduces exactly because the countdown rises by `l` as `R` falls by `l`. That companion
  invariant is where the collision's ROOM is spent, once, in the base case.

**A landed sibling route, found during this phase and deliberately not taken.**
`LadderAgree.lean`'s `exists_ladderPath_at_region_of_idle_past` ("THE INTERFACE, IN THE IDLE-PAST
REGIME") already lands a STATE-LEVEL raise in this very regime, compensating by INSERTING idle
positions at the region start (`insObj`/`insCnt`, `insPins_of_region_start`) rather than by
duplicating an existing idle block. It is not the plan's Phase 3 primitive and does not subsume
it: it holds neither the register (it eliminates the anchor obligation through
`exists_ladderPath_of_walk_of_pins` instead, so it cannot serve a cell inclusion, which reads
`nxtAt` at the comparison position) nor the realized type, it raises by one cycle length rather
than a multiple of `P + 1`, and it carries `hself`, a path-local self-loop at the idle object
states, which the idle-block route does not need. The plan's route was followed as written; the
sibling is recorded here because it corroborates Phase 2's PASS verdict from an independent
construction, and because its own docstring records that the UNCOMPENSATED splice is REFUTED in
this regime -- which is why the compensator is not optional and why `l <= E` is a payment rather
than a convenience.

- Phase-end FULL guarded `lake build`: green, 0 errors, 0 warnings.
- `bash scripts/typst-sync-check.sh --fix` then `--counts-only`: `MISMATCH_COUNT=0`.
- Scope Hypothesis outcome: estimated +220 lines for the two primitives; ACTUAL +276 for the
  raising primitive's admissibility half alone (406 -> 682 `wc -l`), with the lowering primitive
  and the type half not landed. Still below the 1500 `longFile` ceiling, so no baseline is owed.

### Verification notes: phase 3, closing dispatch (measured) -- COMPLETED WITH EXCLUSIONS

The three items the first dispatch left open are resolved: items 1 and 2 LANDED, item 3 EXCLUDED
on a compiled measurement.

**What landed, green and committed** (zero errors, zero warnings, no `sorry`, standard axiom
profile):

- `window_natAbs_sub_comm`, `window_iter_anchor_raise`, `window_iter_anchor_shift`,
  `window_iter_slack_raise`, `window_iter_budget_raise`, `window_iter_no_low_shift` — the
  iteration's arithmetic, factored into named lemmas over plain naturals.
- `window_iter_pin_trichotomy`, `window_iter_pins` — the ITERABLE reformulation: every hypothesis
  and every conclusion about the path being spliced, so the statement applies to the result of its
  own conclusion. Strictly SHORTER than the relative form, because the pending stretch `(a, u + l]`
  forces a region start at or above `a` to BE `a`, so the class-1 clause needs no agreement
  hypothesis and the idle-run condition drops out of the trichotomy entirely.
- `exists_window_iterSpliced_ladderPath` — the window-regime analogue of
  `exists_iterSpliced_ladderPath_idx_of_pend_past` (item 1). The regime hypothesis the landed one
  carries is replaced by two BUDGET invariants, each written with the spend added on the RIGHT so
  no truncated subtraction appears and each step's reproduction is one `omega` away. The register
  is prescribed once, by a terminal re-lift, not per step.
- `window_idle_pin_dichotomy`, `window_idle_anchor_clause`, `window_idle_slack`,
  `window_idle_budget` — the base case. A DICHOTOMY, not a trichotomy: no pending raise has
  happened yet and the lengthened run contains no region start. The collision's ROOM pays the
  anchor budget once; the insertion's LENGTH pays the pin-pair budget once; no step of the
  iteration touches either again.
- `exists_iterIdleSpliced_ladderPath_idx` (item 2) — the iterated idle lengthening with the
  realized type exposed at EVERY position. Needed because the landed
  `exists_iterIdleSpliced_ladderPath` exposes the type only strictly BELOW its block while the
  comparison position sits above it. What makes the global form available, measured rather than
  assumed: the idle splice is a rigid index pullback in BOTH coordinates
  (`idleSpliceCnt g α k = cntAt g ∘ spliceIdx α k` by definition, because inserting idle positions
  raises no countdown anywhere), so `tpOf_eq_spliceIdx_of_tpOf_eq` applies unchanged — it reads the
  object walk relation and the block's endpoint type equality and is indifferent to whether the
  block is pending.
- `exists_window_raise_displaced`, `exists_window_raise_ladderPath` — the RAISING primitive, at an
  exact multiple of `P + 1`, re-anchored at `z` itself.
- `window_lower_anchor_not_implied`, `window_lower_anchor_fails_at_tight_bound`,
  `window_lower_anchor_of_required` — the lowering direction's obstruction, measured.

**`exists_idleBlock_of_hasIdleRunBelow` strengthened**: it now also returns
`∀ v, α ≤ v → v ≤ a → pend (objAt g v) = false`, the stretch from the block's start up to the
region start. The dichotomy needs it and `exists_idleTypeBlock_of_budget_le_run` already supplies
the lower bound the previous reading dropped. Strengthening a conclusion, with no consumer outside
this module.

**The re-anchoring, which the first dispatch's note left unresolved**: it is a genuine translation
of the path (`isLadderPath_shift`), not a restatement at a moved index, and the realized type
crosses it through `tpOf_timeShift` composed with `tpOf_stabFree_eq_of_objAt_eq` at the shifted
history `σ₂.timeShift E` — the same conjugation `tpOf_periodic_of_objAt_periodic` uses. No new
model-level machinery was needed and none was added.

**EXCLUDED, measured**: the lowering primitive. See this phase's `#### Reasoned Exclusions`
record. The deficit is two-sided (anchor clause AND pin pair clause, each short by exactly `jP`)
and it is NOT an artefact of a loose witness: `window_lower_anchor_fails_at_tight_bound` exhibits
the failure with the path's own bound tight, so no sharpening of the path's arithmetic recovers it.
The missing hypothesis's exact shape is recorded as `window_lower_anchor_of_required` so a later
phase decides on its admissibility rather than rediscovering the deficit.

**Build and gate evidence**

- Scoped guarded build of `...RaySummary.LadderWindow` at every sub-step: green, `error:` 0,
  `warning:` 0.
- Phase-end FULL guarded `lake build`: see the record below this list.
- `bash scripts/typst-sync-check.sh --fix`: run before each commit; `typst/generated/status.typ`
  staged in each.
- `lean_verify` on `exists_window_raise_ladderPath`: axioms `propext`, `Classical.choice`,
  `Quot.sound`; no `sorryAx`. The `opaque` source-scan warnings are the word "opaque" occurring in
  docstrings.
- `bash .claude/scripts/lean-sorry-census.sh ... --cross-check`: see the record below this list.
- Batch-gate deferral: this dispatch ran the scoped narrowing invocation that covers the files it
  touched and DEFERRED the complete gate set to the batch stage at the end of the invocation, per
  this dispatch's Batch Gate Deferral directive. The plan's final phase keeps
  `**Verification Tier**: full` unedited.
- Scope Hypothesis outcome, cumulative for phase 3: estimated +220 lines for the two primitives;
  ACTUAL +889 for the raising direction alone plus the exclusion record (682 -> 1571 `wc -l`). The
  file crossed the 1500 `longFile` ceiling, so `set_option linter.style.longFile 1700` was added.
  The overshoot is attributable to item 1 and item 2 each needing a NEW iterate the plan assumed
  could be borrowed from the pending-forever and idle layers respectively.

### Verification notes: phase 5 (measured) -- COMPLETED WITH EXCLUSIONS

**What landed**, three declarations in `LadderWindow.lean`, all new names:

| Name | Kind | What it states |
|---|---|---|
| `CellSubsetOfKappaEqWindowRaise` | `def` (schema) | the window regime's depth-`0` cell obligation, with direction-indexed cell INCLUSION as the conclusion |
| `cellSubset_of_kappa_eq_window_raise` | `theorem` | that schema holds at every tuple `ParamsOk` admits |
| `kappa_collision_window_or_pendPast_exhaustive` | `theorem` | a fixed-register `kappa` collision puts both countdowns on the SAME side of the window boundary, and in the gap branch every ladder path through either state is pending at every earlier position |

**Build and verification evidence**

- Scoped guarded build of `...RaySummary.LadderWindow`: guard exit 0, 2018 jobs, `error:` 0.
  Green on the FIRST attempt; the first run carried one `unusedFintypeInType` warning on the
  dichotomy, fixed by dropping the unused `[Fintype Q]` binder, and the rebuild is `warning:` 0.
- Phase-end FULL guarded `lake build`: guard exit 0 (Tier 1), 2974 jobs, `error:` 0, `warning:` 0
  over both captured streams (Tier 2), and `LadderWindow.olean` newer than its source (Tier 3).
- `lean_verify`: `cellSubset_of_kappa_eq_window_raise` -> `[propext, Classical.choice,
  Quot.sound]`, `trust: standard`, no non-standard axioms;
  `kappa_collision_window_or_pendPast_exhaustive` -> `[propext, Quot.sound]`, `trust: standard`.
  No `sorryAx` on either. The five `opaque` source-scan warnings are at lines 127, 144, 161, 394
  and 819 -- all below this phase's insertion point (1682) and all the word "opaque" occurring in
  pre-existing docstrings.
- `bash .claude/scripts/lean-sorry-census.sh <roots> --cross-check`: see the record below this
  list.
- Exact-name declaration sweep: `cellLE_zero_const_of_kappa_eq` still has 0 declaration sites
  under `FormalSystem/`. None of the three landed names is a prefix of it.
- `bash scripts/typst-sync-check.sh --fix`: PASS; `status.typ`, the automation module map and the
  machine appendix all in sync, `MA_COUNT_MISMATCHES=0`. `typst/generated/status.typ` staged in
  this phase's commit.
- Batch-gate deferral: this phase's declared `**Verification Tier**` is `local`, so the dispatch's
  Batch Gate Deferral directive does not bite -- the scoped narrowing invocation named in the Tier
  Justification IS the complete covering check for this phase and was independently run, and the
  full library build was additionally run on top of it. The plan's final phase keeps
  `**Verification Tier**: full` unedited.
- Scope Hypothesis outcome: estimated +180 lines, ACTUAL +183 (1683 -> 1866 `wc -l`) -- the
  per-phase delta held to within 3 lines. The hypothesis's ABSOLUTE figure ("near 720 lines") was
  stale from Phase 3's +889 overshoot onward; the module crossed Phase 3's
  `set_option linter.style.longFile 1700` window, so the baseline was raised to 1900 at its own
  position.

**The exclusion, in one line**: cell EQUALITY is not reachable in this regime because
`Set.Subset.antisymm` needs two inclusions and Phases 3-4 compiled the measurement that the
lowering direction's anchor clause reverses and needs a sixth hypothesis the decision gate
forbids. The schema concludes inclusion and is NAMED for it. See this phase's
`#### Reasoned Exclusions`.

**Concurrency observation**: at this dispatch's start and at its close the working tree carried
foreign uncommitted modifications outside this task's territory --
`specs/893_lcu_until_form_schema_ztime_validity/issues.jsonl`, `specs/events.jsonl`, an untracked
`.pid`, `specs/893_.../stale-dispatch-2-plan-report.md` and `specs/evidence/history-morphism-saturation-audit/`.
All were present in the dispatch's own opening git snapshot, so they are a concurrent sibling's
in-flight state rather than anything this phase produced. None was staged or edited here.

### Verification notes: phase 6 (measured) -- COMPLETED WITH EXCLUSIONS, PASS BRANCH

**The branch, read rather than re-derived**: this phase is conditional on Phase 2's decision gate
FAILING. That gate's verdict is recorded in this file at
`### Verification notes: phase 2 (measured) -- GATE VERDICT: PASS`, with a clause-by-clause table
naming the discharging lemma for each of `hw`, `hidle`, `hpp`, `hpi`, `hpins` and `hn0`, and the
sentence "No sixth hypothesis was needed, so this is a PASS, not a widening". Phase 2's heading
carries `[COMPLETED]`, not `[COMPLETED WITH EXCLUSIONS]`. The branch is therefore PASS and this
phase's terminal task applies: close `[COMPLETED WITH EXCLUSIONS]` with a record, land nothing.

**What was NOT written, and why that is the deliverable**: no window-regime obstruction probe, no
`LadderWindow.lean` module-docstring verdict, no `specs/state.json` description amendment. All
three are FAIL-branch content whose substance is counterfactual on this branch -- the window
regime is closed positively (one-directionally, under `CellSubsetOfKappaEqWindowRaise`), not
refuted, and the ladder route is closed in neither regime by this task. Writing any of the three
would have put a false claim into a durable record. Each is enumerated with its own row in this
phase's `#### Reasoned Exclusions`.

**The one edit made, and why it is not a widening**: `scripts/check-evidence-probes.sh` gained one
`WIRED_REPO` entry for `specs/918_ladder_cell_index_positive_factorization/evidence/`
`lowering-anchor-deficit.lean`. That file is this task's ACTUALLY compiled obstruction -- the
lowering-direction anchor deficit that Phases 3, 4 and 5 each cite, by that verbatim path, as the
Evidence for their own exclusion -- and it was wired into nothing, so no gate reached it. This
phase's `**Files to modify**` list names `scripts/check-evidence-probes.sh` and directs that the
directory and file name be adjusted "to the obstruction actually measured"; this is that
adjustment. It lands no new obstruction: it stops an already-landed one from rotting.

**Why `WIRED_REPO` and not `WIRED`**: the script's header prefers `WIRED` and admits `WIRED_REPO`
only for a probe that cannot yet move, with a named blocker recorded beside the entry. The named
blocker here is that three landed `#### Reasoned Exclusions` records cite the task-directory path
verbatim, so moving the file would invalidate those citations in the same edit. The owed
promotion -- to `specs/evidence/seam-gluing-ray-product/`, where every other ladder probe in this
family lives, together with updating those three Evidence citations -- is recorded beside the
entry and is DUE BEFORE THIS TASK IS ARCHIVED, because `.gitignore` excludes `specs/archive/` and
an archival `mv` would take the probe out of version control in that one commit. Flagged for
Phase 7, which owns records reconciliation.

- `timeout 540 lake env lean specs/918_.../evidence/lowering-anchor-deficit.lean`: exit 0, zero
  output. `sorry`/`axiom` sweep: no occurrence. All three theorems close by `omega`.
- `bash scripts/check-evidence-probes.sh` (detached, bounded waiter, guard flock held by the
  script itself): exit 0, `PASS  all 54 wired probe(s) compile`. Delta against the pre-phase run:
  53 -> 54 wired, the new one `PASS`, zero PASS-to-FAIL transitions, the one deliberate `SKIP`
  unchanged.
- `bash scripts/typst-sync-check.sh --fix`: PASS, `MA_COUNT_MISMATCHES=0`; `status.typ` came back
  unchanged, which is correct -- no `.lean` file was touched this phase, so no line count moved.
  Nothing to stage.
- Scope Hypothesis outcome: the hypothesis predicted "content only on the FAIL branch... one file
  of 80-140 lines plus one `WIRED` entry", and instructed that the branch be confirmed from
  Phase 2's recorded measurement before starting. Confirmed PASS, so the 80-140-line probe is
  correctly absent. ACTUAL delta: 0 new `.lean` lines, +53 lines in
  `scripts/check-evidence-probes.sh` (one array entry plus its documentation block, in the
  format the existing `WIRED_REPO` entry establishes).

**Concurrency observation**: the working tree carried the same foreign uncommitted state Phase 5
recorded -- `specs/893_lcu_until_form_schema_ztime_validity/issues.jsonl`, `specs/events.jsonl`,
an untracked `.pid`, `specs/893_.../stale-dispatch-2-plan-report.md` and
`specs/evidence/history-morphism-saturation-audit/` -- unchanged in character from that record, so
a concurrent sibling's in-flight state rather than anything this phase produced. None was staged
or edited here. No foreign commit touched this task's files and no build was running that this
dispatch did not start.

### Verification notes: phase 7 (measured)

**The complete gate set, each command run and each result recorded.** The dispatch's batch-gate
deferral directive offered a SCOPED tier in place of the full set; it was not taken. All nine
commands below were run independently in this dispatch, so nothing on this phase's behalf is owed
to the batch stage.

| # | Gate | Exit | Result |
|---|---|---|---|
| 1 | unscoped guarded `lake build` (`lake-build-guard.sh build --timeout 1800 -- build`) | 0 | PASS -- 2974 jobs, `error:` count 0, `warning:` count 0, guard `exit_status=0` |
| 2 | `lake build BimodalTest` (guarded) | 0 | PASS -- 3042 jobs, 0 errors, 0 warnings; every `#guard_msgs` axiom pin satisfied, including all 42 new ones |
| 3 | `lake exe mk_all --lib FormalSystem --check` (guarded) | 0 | PASS -- "No update necessary" |
| 4 | `bash scripts/check-module-invariants.sh` | 1 | RECORDED PASS -- sole failure is C16, pre-existing and out of scope; see the attribution below. C9 was also failing on this task's own file and was REPAIRED, not attributed away |
| 5 | `bash scripts/typst-sync-check.sh` | 0 | PASS -- all four checks green (status.typ, module map, machine appendix) |
| 6 | `bash scripts/check-metalogic-cycles.sh` | 0 | PASS |
| 7 | `bash scripts/check-evidence-probes.sh` | 0 | PASS -- all 54 wired probes compile; delta against the Phase 6 run is zero (same 54, same single deliberate `SKIP`) |
| 8 | `bash scripts/check-copyright-headers.sh` | 0 | PASS -- 0 missing of 755 |
| 9 | `bash .claude/scripts/validate-artifact.sh .../plans/01_ladder-cell-window-regime.md plan` | 0 | PASS -- 0 warnings |

**Attribution of the two `check-module-invariants.sh` findings, pre-existing vs. this task's own.**

- **C16 (`env_linter`) -- PRE-EXISTING, OUT OF SCOPE, not edited.** Two findings, both in
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean`, a file this task has never
  touched: `exists_idleSpliced_ladderPath` (2 unused instance arguments) and
  `exists_idleTypeBlock_of_budget_le_run` (1 unused hypothesis). `git log -S` attributes them to a
  concurrent sibling's commits (`3692d517e`, `64b8eb6f6`) and not to any commit of this task.
  This is exactly the collision this phase's task list anticipated; the file was left alone, and
  the gate is a recorded PASS for this phase.
- **C9 (task-number citations) -- THIS TASK'S OWN DEFECT, repaired.** One finding, at
  `LadderWindow.lean`, where a docstring cited the lowering-deficit probe by its full
  task-directory path. That path is an ephemeral task-management identifier in a deliverable file,
  which `.claude/rules/no-task-references-in-deliverables.md` forbids and whose stated remedy is a
  durable anchor. Repaired in both places it occurred -- the module docstring and the new test-file
  narrative -- by naming the probe `lowering-anchor-deficit.lean` and pointing at
  `scripts/check-evidence-probes.sh`'s probe list, which is where it is wired. C9 is now PASS.

**Zero-debt sweep.** `bash .claude/scripts/lean-sorry-census.sh` over the resolved source roots
(`lean-src-roots.sh`: `FormalSystem`, `FormalSystem.lean`, `Tests/BimodalTest`,
`Tests/BimodalTest.lean`, `BimodalTools`, `BimodalTools.lean`, `Tests/BimodalToolsTest`,
`Tests/BimodalToolsTest.lean`) reports `sorry_count: 0` with an empty inventory. The four `sorry`
substring hits in the test file are prose occurrences of `sorryAx` inside docstrings, not
sorries. Vacuous-definition sweep: 1 hit, `FormalSystem/Examples/TemporalStructures.lean:495`,
pre-existing and outside this task's file scope (`git log -S` attributes it to an unrelated
task's Examples pass). `^axiom ` sweep: 14, unchanged from the pre-phase baseline.

**`longFile` posture at the FINAL line counts, both touched Lean files.** `LadderWindow.lean`
reached 1907 lines, crossing Phase 5's baseline of 1900; raised to 2000, satisfying
`1800 ≤ 1907 < 2000`. `KTypeSummaryAxiomTest.lean` reached 2873 lines, crossing its baseline of
2600; raised to 2900, satisfying `2700 ≤ 2873 < 2900`. Both confirmed by warning-free builds,
which is where this linter reports.

**Axiom-pin completeness, measured rather than asserted.** The pinned-name set was diffed against
a declaration sweep of `LadderWindow.lean`: 42 declarations, 42 pins, no name pinned twice and
none omitted. The pin bodies were generated from a compiled `#print axioms` probe over the module
rather than hand-predicted, which is why all 42 `#guard_msgs` blocks were green on the first
build. Measured split: 29 at `[propext, Quot.sound]` and 13 at the standard
`[propext, Classical.choice, Quot.sound]`; no `sorryAx` and no axiom outside the standard three
anywhere in the module.

**Scope Hypothesis, confirmed against what the regenerations actually rewrote.** The hypothesis
instructed confirming the file list by running the regeneration commands and reading which
tracked files they touch. `check-module-invariants.sh --emit-inventory` rewrote THREE files:
`README.md` and `FormalSystem/Metalogic/README.md` as predicted, plus
`FormalSystem/Metalogic/Decidability/RaySummary/README.md`, which the phase's list omits and which
is added below. `typst-sync-check.sh --fix` rewrote `typst/generated/status.typ` as predicted.
`FormalSystem/README.md` did NOT come back changed this phase (it moved at Phase 3's early
regeneration instead) and is not claimed here.

**Territory.** The working tree carried, at dispatch start and unchanged at its close, the same
foreign uncommitted state Phase 6 recorded: a modified `specs/893_.../issues.jsonl`, a modified
`specs/events.jsonl`, an untracked `.pid`, `specs/893_.../stale-dispatch-2-plan-report.md` and
`specs/evidence/history-morphism-saturation-audit/`. None was staged or edited here. No foreign
commit touched this task's files and no build was running that this dispatch did not start.
