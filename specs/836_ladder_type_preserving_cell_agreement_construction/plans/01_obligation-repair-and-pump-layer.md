# Implementation Plan: Task #836

- **Task**: 836 - Ladder type-preserving cell-agreement construction: wire the compiled refutation of `CellLEZeroConstOfKappaEq`, repair `(K4)` with the forward exactness depth, and land the certificate-free type-preserving pump layer the repaired obligation consumes
- **Status**: [IMPLEMENTING]
- **Effort**: 20 hours (Phases 1-11 at 1.5 / 2 / 2 / 2 / 2 / 1.5 / 1.5 / 2 / 2 / 2 / 1.5; Phase 10 is a decision-gated phase whose two hours are spent only on the gate's PASS branch — on the FAIL branch it closes `[BLOCKED]` in under half an hour, so the honest range is 18.5-20 hours)
- **Dependencies**: None at the `state.json` level. Task 761 is the CONSUMER: its plan 08 gates Phases 11.6, 11.7 and 12-18 on `cellLE_zero_const_of_kappa_eq` existing as a landed theorem, and its reviser receives this plan's summary as input. Nothing here edits any artifact of task 761
- **Research Inputs**:
  - specs/836_ladder_type_preserving_cell_agreement_construction/reports/01_type-preserving-cell-agreement-construction.md — THE PRIMARY INPUT. Q5: the obligation is REFUTED at Probe761C's own object at the periodicity fixpoint's own outputs (`Probe836A.cellLEZeroConstOfKappaEq_refuted`, compiled). Q1: the duplication and deletion type lemmas verified clause by clause on paper, with the Lean statement shapes recorded. Q2: exactness reachable only through the realized-chain bridge into `prodCycleLens` (certificate-free at the parameter level, placement-breaching in `LadderAgree.lean`). Q3/Q4: the two Lipschitz windows of the register; regime B's tight doubling chain defeats every cascade that pumps the original past. Q6: placement in two new modules. Recommendations 1-5 are followed in order
  - specs/836_ladder_type_preserving_cell_agreement_construction/prototype/cell-obligation-refutation.lean — the compiled separating object (468 lines by `wc -l`, re-derived at this plan's authoring), six `#print axioms` lines each `[propext, Classical.choice, Quot.sound]`; NOT yet a wired probe
  - specs/836_ladder_type_preserving_cell_agreement_construction/.decisions.json — the recorded repair decision (Option A: forward exactness depth `dFwd`, repaired `(K4)`, redefined `Bof`, obligation and filed Goals restated against the repaired predicate). Recorded autonomously on the research agent's recommendation with `blocking=false`; this plan proceeds on it and names `/revise` as the route if it is overturned
  - specs/761_ladder_realization_theorem/plans/08_cell-agreement-construction-handoff.md — the consumer's record, consulted for the module-wiring pattern (probe row + `WIRED=(` entry, axiom-test pins, `--emit-inventory`), for its Non-Goal "no strengthening of `ParamsOk`" (superseded by the recorded decision — see Decisions below), and for the gate note on its Phase 11.6
  - FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean (2,241 lines under `longFile 2400`), CounterQuotient.lean (728 lines), Certificate.lean, AnchorLayer.lean, LadderModel.lean — read at the sections this plan edits or consumes; every landed name cited below was re-verified by grep at authoring time
- **Artifacts**: plans/01_obligation-repair-and-pump-layer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

The obligation this task was opened to construct is false as filed, and the falsity is compiled: `CellLEZeroConstOfKappaEq` fails at the periodicity fixpoint's own parameter outputs because `(K4)` bounds `kappa`'s gap clip `B` by the BACKWARD exactness depth `dBack` alone, while the cell also reads the next-deadline register FORWARD through the next region's pin (`nxtAt z ≤ cntAt z + I₁ + L₁ - 1`), and a `U`-only formula of bounded `X`-depth pins `I₁ + L₁` below any such `B`. This plan therefore does three things in order. It wires the refutation as the forty-seventh evidence probe so the record carries it (Phase 1). It repairs `(K4)` with a forward exactness depth `dFwd` mirroring `dBack`, redefines `Bof`, re-proves `paramsOk_params`, and re-anchors the probe to a frozen copy of the pre-repair conjunct so the refutation stays a theorem about a named object (Phase 2). It then lands, in two new modules, the certificate-free type-preserving pump layer the repaired obligation needs — the deletion admissibility mirror, the duplication and deletion TYPE lemmas (HWZ 2000 Lemma 17 and its mirror), the `(objAt, tpOf)` pigeonhole, the named forward window, the realized-chain bridge into `prodCycleLens`, and the regime-A assembly that moves a countdown by an exact multiple of `P + 1` while holding the register and the stab-free type (Phases 4-9).

Whether the repaired depth-`0` theorem is then PROVABLE is not settled by the research: regime B (an idle position in the past) is an open combinatorial core (the tight doubling chain defeats every cascade that pumps the original past), and this plan's own analysis finds the mirror obstruction FORWARD (the downward inclusion, and the `n`-sub-regime where the register must drop by more than the countdown rises, both need the NEXT region lengthened or shortened type-respectingly). So the plan carries a decision gate (Phase 3) that probes the open core before the final theorem is attempted, and the final theorem phase (Phase 10) is entered as a proof attempt only on the gate's PASS branch; on FAIL it closes `[BLOCKED]` with an explicit handoff, and the reserved name `cellLE_zero_const_of_kappa_eq` stays claimed by nothing — never a `sorry`, never a narrowed restatement under the reserved name.

### Research Integration

- **The refutation is the first input, and the record must carry it.** Phase 1 promotes the prototype verbatim; Phase 2's re-anchoring freezes the pre-repair `(K4)` locally (`paramsOkK4Pre`, `ParamsOkPre`, a local schema `CellLEZeroConstOfKappaEqPre` carrying the library schema's text with `ParamsOkPre`) so the refutation remains a theorem about a named object after the library predicate changes, on the precedent of `AtomPreservingCountMove`. Two positive facts are added at the same time: the repaired `(K4)` rejects `B = 2` for the refuting formula (`not_paramsOkK4_two`), and the specific collision dissolves at the repaired `Bof` (`kappa_D_dissolves`).
- **The repair's shape is the research's.** `dFwd` counts `untl` nesting as `dBack` counts `snce` nesting; `paramsOkK4 φ B := 2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧ 2 ≤ B`; `Bof := max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)`. The factor `2` is the conservative mirror of the backward bound. The refutation family scales with `B` through an `X`-chain of depth `B + 2`, whose `dFwd` is `B + 3`, so the repaired `Bof` exceeds every `B` that family can defeat; the constant is tightened only by a proof, never loosened. No consumer projects the `(K4)` conjunct positionally (grep for `.2.2.2` over `RaySummary/*.lean`, the probes and the axiom test hits only unrelated tuples), both existing wired probes pass `Bof` straight into `paramsOk_params` and collide through the `B`-generic `kappa_eq_of_shift`, so the ripple is confined to `CounterQuotient.lean`, one docstring line of `RaySummary.lean` (line 198), and the new probe.
- **Q1's statements are pinned as Goals**, with the pinned-letter (`StabPinned L`) truth-level form as the induction and the stab-free theorem as its `L := fun _ => False` instance, exactly as half (i) is organised (`tpOf_eq_of_objAt_eq_of_pinned` / `tpOf_stabFree_eq_of_objAt_eq`). The seam sub-cases listed in the report under "Q1 … Proof, verified clause by clause" are the step list; the device is the endpoint equality applied to `ψ U χ` ITSELF, never the induction hypothesis for it.
- **Q2's bridge lands in its own module** (`LadderChain.lean`), which is NOT certificate-free by design and says so; its grep forbids the certificate-SET objects and the periodicity bridge (`certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|LadderCons|prodPre_periodic|prodPreStep|satThreshold|satPeriod`) so the distinction from the recorded circularity is mechanical. `card_prodState` and the budget lemmas of task 761's `step0-budget-check.lean` are promoted there too, because `ClType` is on `LadderAgree.lean`'s forbidden list and therefore on `LadderPump.lean`'s.
- **Q3/Q4 are the gate.** The forward window is landed as a named lemma (`nxtAt_le_cntAt_add_of_next_region`; the report's "`RunLayer.lean`'s `forward_window`" is a prose name in a docstring, not a declaration — re-derived by grep). The regime-A assembly is pinned one-directionally (upward shift, register held) because that is what the two windows admit without a cascade. The open core is probed at Phase 3.
- **Q6's placement is followed**: `LadderPump.lean` (imports `LadderAgree` only, certificate-free under the same grep) and `LadderChain.lean` (imports `LadderPump` and `CounterQuotient`). `LadderAgree.lean` receives docstring edits only (159 lines of headroom).

### Prior Plan Reference

No prior plan for this task. Task 761's plan 08 was consulted as the consumer's record, not as a template: its Phase 11.5 (the forty-sixth probe's wiring) calibrates Phase 1 here at 1.5 hours; its gate note on Phase 11.6 is the contract this plan's Phase 10 either lifts or leaves in place; its Non-Goal "no strengthening of `ParamsOk`" is superseded by the recorded decision and is named in Decisions below so 761's reviser sees the supersession stated rather than discovered.

### Roadmap Alignment

No `roadmap_path` was provided in the dispatch; `ROADMAP.md` was not loaded.

## Goals & Non-Goals

**Goals**:
(The identifier set equals the eight theorem declarations of the Lean Challenge Statements block below. That block's three abbrev declarations — delIdx, delObj and delCnt — are context pinned by position, defined in Phase 4, and are not Goals. No other identifier is backticked in this block, because the snapshot tool reads every backticked token here as a Goal.)
- `nxtAt_le_cntAt_add_of_next_region` — the forward Lipschitz window of the next-deadline register, named: the register at a position is at most the countdown there plus the length of the next idle run plus the next region's countdown at its start. (Phase 7)
- `exists_deleted_ladderPath_of_pend_past` — deletion admissibility in the pending-forever regime: deleting a repeated segment inside a region yields a ladder path, the mirror of the landed duplication. (Phase 4)
- `tpOf_eq_spliceIdx_of_tpOf_eq` — the duplication TYPE lemma: duplicating a type-respecting block preserves the stab-free closure type at EVERY position, read through the landed splice retraction. (Phase 5)
- `tpOf_eq_delIdx_of_tpOf_eq` — the deletion TYPE lemma, HWZ 2000 Lemma 17 verbatim over `ℤ`. (Phase 6)
- `exists_typeBlock_of_budget_le_cnt` — the `(objAt, tpOf)` pigeonhole: a region of countdown at least the budget carries a type-respecting block of length at most the budget, inside the region and not before the chosen position. (Phase 7)
- `realized_typeBlock_mem_prodCycleLens` — the realized-chain bridge: a pending type-respecting block's length is a member of the certificate graph's saturated cycle-length set, hence divides P + 1 under (K1). (Phase 8)
- `exists_ladderPath_through_shifted_of_pend_past` — the regime-A assembly: through a pending-forever path's state, a path with countdown raised by an exact multiple of `P + 1`, the register held, the object state held, and the same stab-free type. (Phase 9)
- `cellLE_zero_const_of_kappa_eq` — the depth-`0` cell agreement under the repaired `(K4)`, GATED on Phase 3. (Phase 10)

**Non-Goals**:
- No weakening of the obligation's TEXT: `CellLEZeroConstOfKappaEq` keeps its statement token for token; the only change reaching it is the definition of `ParamsOk`, which it names. No positionwise narrowing, no "cells agree up to the register's forward window", no restatement under the reserved name of anything weaker than the schema.
- No `sorry`, no axiom, no `native_decide`, no vacuous definition (`:= True`, `:= trivial`), no raised parameter as a workaround — the one parameter change is the repair of a condition shown too weak by a compiled refutation.
- No edit to `LadderAgree.lean` beyond docstrings; no raise of its `longFile 2400` baseline; no certificate object named in it or in `LadderPump.lean`.
- No derivation of the agreement from obligations (S) and (C'), no citation of `prodPre_periodic`, `prodPreStep`, `satThreshold` or `satPeriod` anywhere in this task's modules.
- No reuse of task 761's Phase 11.8 idle-run cascade (type-blind) by any type-preserving construction; no edit to any artifact of task 761.
- No general bisimulation or truth-congruence framework; exactly the two index-map transports the pump consumes.
- No `git push`, no PR; no `git-snapshot.sh` in its default form as a routine checkpoint.

## Decisions

- **The `(K4)` repair proceeds on the recorded decision** (`.decisions.json`, Option A). It was recorded autonomously and marked non-blocking; the dispatch treats it as settled. If the user overturns it, the route is `/revise 836` with the alternative named (the research's own alternative was to restate the obligation for regime A only, which this plan already carries as a one-directional Goal). Task 761's plan 08 Non-Goal "No new parameter, no fifth parameter source, and no strengthening of `ParamsOk`" was written against a statement believed true but hard; the research shows the statement is FALSE at the recorded predicate, and a prohibition cannot bind against a false statement. The summary names this supersession for 761's reviser.
- **Wire first, repair second, re-anchor in the repair phase.** The refutation as filed lands as its own green commit (Phase 1) before the predicate it refutes changes; the probe is re-anchored to a frozen local copy of the pre-repair conjunct in the SAME phase as the repair (Phase 2) so no commit leaves the evidence gate red. The cost is one mechanical second pass over the probe; the benefit is a record in which "what was refuted" and "what was repaired" are separate commits.
- **The gate sits early, and the layer lands regardless of it.** Phase 3 probes the open core immediately after the repair so the orchestrator learns early whether this task will end with the headline theorem or with a `[BLOCKED]` raise; Phases 4-9 proceed on either branch because they are the certificate-free layer any successor construction consumes, each verified on paper by the research.
- **One-directional regime-A assembly as a Goal, not a two-sided restatement.** The upward inclusion (duplicate after `z`, register held) is constructible from landed material plus Q1 and Q2 because the forward window WIDENS with the countdown; the downward inclusion shrinks that window and may need the next region shortened, which cascades forward on a tight chain. Pinning a two-sided regime-A theorem would pin a statement this plan cannot vouch for.
- **Paper citations in the new modules use the prose form `Closure.lean` already uses** ("HWZ 2000 Def 11"), which `check-module-invariants.sh`'s C15 passes today; no paper-anchor citation syntax is introduced, so no manifest row is needed.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Regime B (and its forward mirror) is genuinely open under the repaired predicate, so `cellLE_zero_const_of_kappa_eq` cannot be proved as filed | H | H | Phase 3 is a decision gate run BEFORE the final theorem is attempted; Phase 10's FAIL branch closes `[BLOCKED]` per `plan-compliance.md` with a handoff naming the open core; Phases 4-9 land the reusable layer regardless, so the task's deliverable value does not depend on the gate |
| The repaired `(K4)` is still insufficient against some forward-pinning family other than the `X`-chain | M | M | Phase 2 compiles `not_paramsOkK4_two` and `kappa_D_dissolves` at the refuting formula; no general "forward pinning bound" is CLAIMED by this plan (it would be the heart of the construction, not a parameter fact); a new separating family surfaces at Phase 3 or Phase 10 as a compiled refutation, which is the honest outcome |
| The Q1 inductions run over their two-hour caps (six clause cases, four seam sub-cases each for `U` and `S`, both directions) | M | M | The report's sub-case list is the step list; the pinned-form lemma and its stab-free instance are separate items; on overflow, checkpoint with `bash .claude/scripts/git-snapshot.sh 836 --no-revert`, record the sub-case reached in the progress file, and close `[PARTIAL]` honestly rather than compress the induction |
| The Q2 bridge is read as the recorded circularity | M | L | `LadderChain.lean`'s header states which objects it reads (`locCoh`, `untlLink`, `snceLink`, `SatCl`, `prodCycleLens`) and its grep forbids every certificate-SET object and the periodicity bridge; the bridge's statement names no class-level object |
| `ParamsOk` change ripples further than the grep inventory shows (a positional projection, a probe computing `Bof`'s value, a Typst statement of `(K4)`) | M | L | Authoring-time greps: no positional `(K4)` projection, both probes pass `Bof` through `paramsOk_params` only, no `docs/` or `typst/` statement of `(K4)` (the `docs/` hits are `ced_backward`); Phase 2 re-runs the inventory before editing and carries a Scope Hypothesis |
| `longFile` baselines: `LadderAgree.lean` has 159 lines of headroom, `KTypeSummaryAxiomTest.lean` 191 (1,609 of 1,800), `LadderPump.lean` is estimated at 350-600 lines against the package default 1,500 | M | L | `LadderAgree.lean` receives docstring edits only (≈ 20 lines); the axiom-test pins are ≈ 8 × 4 lines plus one prose block (≈ 70 lines); if `LadderPump.lean` approaches 1,500 the type lemmas move to `LadderPumpType.lean` rather than raising a baseline |
| Record-versioning or task-number language leaks into `FormalSystem/**` docstrings ("repaired", "previously", "task 836") | M | M | Every phase touching a library docstring carries the criterion that it states the current design only and cites durable anchors (probe filenames, theorem names); `check-module-invariants.sh` C9 and `check-task-references.sh` are run; probes under `specs/evidence/` are exempt |
| `lean_local_search` reports `index: unavailable` (as throughout the research), so existence/absence claims are grep-backed | L | M | Every "claimed by nothing" claim in this plan was re-derived by grep at authoring; the implementer re-runs the two greps named under Phase 1 before editing and announces the evidence tier |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2, 5, 6, 7, 8 | 1 (for 2); 4 (for 5, 6, 7, 8) |
| 3 | 3, 9 | 2 (for 3); 2, 5, 7, 8 (for 9) |
| 4 | 10 | 3, 6, 9 |
| 5 | 11 | 10 |

Phases within the same wave can execute in parallel. Phase 11 is the final phase: it is a terminal node and depends, transitively through Phase 10, on every other phase.

### Phase 1: Wire the Obligation Refutation as the Forty-Seventh Probe [COMPLETED]

**Goal**: The compiled refutation of `CellLEZeroConstOfKappaEq` as filed — at Probe761C's own object, at the periodicity fixpoint's own outputs — becomes gate-covered evidence, and the three records that currently say the obligation is "proved or refuted by nothing" say instead that it is refuted and name the mechanism.

**Tasks**:
- [x] Re-run the two authoring greps and announce the evidence tier (`lean_local_search` may again report `index: unavailable`): `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returns only the two docstring lines of `LadderAgree.lean` (2168, 2222) — the reserved name is claimed by nothing; `grep -rnE 'tpOf_[A-Za-z_]*_of_splice|delIdx|LadderPump|LadderChain|dFwd' FormalSystem/ Tests/` returns nothing.
- [x] Copy `specs/836_ladder_type_preserving_cell_agreement_construction/prototype/cell-obligation-refutation.lean` verbatim to `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean`; change only the header's last sentence ("Prototype, compiled standalone … not a wired probe") to say it is the forty-seventh wired probe. Namespace `Probe836A` and all six `#print axioms` lines stay.
- [x] In `scripts/check-evidence-probes.sh`: add a WIRED table comment block for `seam-gluing-ray-product/ladder-cell-obligation-refutation` immediately after the `ladder-cell-agreement-refutation` block (the row names the decision it holds in place: the obligation is FALSE at the recorded `(K4)` because the gap clip does not dominate the register's forward window; headline theorems `cellLEZeroConstOfKappaEq_refuted` and `exists_refuting_cell_collision`; axiom profile), and the array entry `"seam-gluing-ray-product/ladder-cell-obligation-refutation"` immediately after line 1777's entry.
- [x] `bash -n scripts/check-evidence-probes.sh`; then run the gate (foreground, `timeout 540`, Bash tool timeout raised) and confirm `PASS  all 47 wired probe(s) compile`.
- [x] `LadderAgree.lean`, obligation section (the `/-! ## The obligation of the cell-level agreement …` docstring before `section Obligation`, and the docstring of `CellLEZeroConstOfKappaEq`): state that the schema is REFUTED at the fixpoint's own outputs for a stab-free closure by the probe, with the mechanism (the register is read forward through the next region's pin, `nxtAt z ≤ cntAt z + I₁ + L₁ - 1`; `(K4)` as it reads bounds `B` by `dBack` only; a `U`-only formula of bounded `X`-depth pins `I₁ + L₁ = 3`), that the `def` is kept so the refutation is a theorem about a named object (precedent: `AtomPreservingCountMove`), and that the reserved name stays reserved. Current-design language only; no "previously", no task number.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, the `/-! ## Requirement (W): the countdown rigidity …` block: the sentence "They do NOT certify that the obligation is false: `CellLEZeroConstOfKappaEq` is a definition, nothing proves or refutes it" is now false — amend to cite the probe and say the pins certify the schema's axiom profile only. The `#guard_msgs` pins themselves are unchanged.
- [x] `bash .claude/scripts/check-task-references.sh --quiet scripts/check-evidence-probes.sh FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` exits 0.
- [x] Record in `issues.jsonl` whether the README needed an edit *(deviation: altered — the three generated inventory blocks (RaySummary/README.md, Metalogic/README.md, README.md) were regenerated with --emit-inventory because LadderAgree.lean's line count changed; count-only, no prose edit; recorded in issues.jsonl)* (authoring-time grep: `RaySummary/README.md` mentions neither the obligation nor the forty-sixth probe, so no README edit is expected in this phase; the (W) narrative is Phase 11's).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The probe is 468 lines (prototype `wc -l`, re-derived at authoring) and compiles unchanged through the gate; three files besides it change (`scripts/check-evidence-probes.sh`, `LadderAgree.lean` docstrings, the axiom test's prose block) and the README does not — confirm by `git diff --stat` before the commit and by `grep -n 'CellLEZeroConstOfKappaEq\|ladder-cell-agreement-refutation' FormalSystem/Metalogic/Decidability/RaySummary/README.md` returning nothing.

**Tier Justification**: `bash scripts/check-evidence-probes.sh` (compiles the new probe with the other forty-six) plus guarded scoped builds of `FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` and `BimodalTest.Metalogic.KTypeSummaryAxiomTest` (docstring-only edits that still elaborate) plus `bash scripts/check-module-invariants.sh` is the complete covering check — no signature changes anywhere.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` - new, the prototype promoted verbatim
- `scripts/check-evidence-probes.sh` - one WIRED table block and one `WIRED=(` array entry
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - obligation-section docstrings only
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - one prose block amended, no pin changed

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 and prints `PASS  all 47 wired probe(s) compile`.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` and `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` each exit 0 (read the guard's `result` subcommand, never a piped exit code).
- `bash scripts/check-module-invariants.sh` exits 0 (C9 in particular).
- `#print axioms` on `Probe836A.cellLEZeroConstOfKappaEq_refuted` and `Probe836A.exists_refuting_cell_collision` show `[propext, Classical.choice, Quot.sound]`; `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial' specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` is 0.
- `LadderAgree.lean` is still 2,241 ± 25 lines and under `longFile 2400`; no `theorem` or `def` was added to it.

---

### Phase 2: Repair `(K4)` with the Forward Exactness Depth, and Re-Anchor the Probe [COMPLETED]

**Goal**: `ParamsOk`'s `(K4)` conjunct bounds `B` by BOTH exactness depths; `Bof` is the fixpoint's matching output; `paramsOk_params` discharges the repaired predicate; the forty-seventh probe refutes the obligation at a FROZEN copy of the pre-repair conjunct and compiles two positive facts about the repair; every consumer of `paramsOkK4`, `Bof` and `dBack` is re-read.

**Tasks**:
- [x] Re-run the consumer inventory before editing: `grep -rn 'paramsOkK4\|\bBof\b\|\bdBack\b' FormalSystem/ Tests/ specs/evidence/ scripts/ typst/ docs/` (authoring-time result: 17 lines in `CounterQuotient.lean`, line 198 of `RaySummary.lean`, one `Bof` line in each of `ladder-cell-agreement-refutation.lean` and `ladder-splice-type-refutation.lean`, and the new probe); `grep -rn '\.2\.2\.2' FormalSystem/Metalogic/Decidability/RaySummary/*.lean specs/evidence/seam-gluing-ray-product/ladder-*.lean` shows no positional projection of `ParamsOk`'s fourth conjunct.
- [x] `CounterQuotient.lean`: add `dFwd : PlusFormula → ℕ` immediately after `dBack` — `| .atom _ => 0 | .bot => 0 | .imp α β => max (dFwd α) (dFwd β) | .box α => dFwd α | .untl α β => max (dFwd α) (dFwd β) + 1 | .snce α β => max (dFwd α) (dFwd β) | .stab α => dFwd α` — with a docstring naming it the forward exactness depth and the probe that forces it.
- [x] `paramsOkK4 φ B := 2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧ 2 ≤ B`; `Bof … φ := max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)` (the `set_option linter.unusedVariables false in` wrapper and the three binders stay for the reason their comment records).
- [x] `paramsOk_params`: the `refine` pattern's last component becomes `⟨?_, ?_, ?_⟩`, discharged by `le_max_left _ _`, `le_trans (le_max_left _ _) (le_max_right _ _)`, `le_trans (le_max_right _ _) (le_max_right _ _)`. `not_paramsOk_allZero` is unchanged (it reads `(K1)`).
- [x] Docstrings and header prose of `CounterQuotient.lean` (the `(K4)` paragraphs at the header, the `Bof` docstring, the `paramsOkK4` docstring, the `ParamsOk` docstring): state the CURRENT design — `(K4)` bounds `B` by both exactness depths and by `2`; compiled anchors `gate1_cell_ne` (reads the gap at distance two) and `ladder-cell-obligation-refutation.lean` (the gap clip must dominate what a closure formula can pin forward). No "previously", no "repaired", no task number. `RaySummary.lean` line 198's mention of `Bof` re-read and amended only if it states the old bound.
- [x] Re-anchor the probe `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean`: add local `paramsOkK4Pre (φ) (B) : Prop := 2 * dBack φ + 1 ≤ B ∧ 2 ≤ B` and `ParamsOkPre … := paramsOkK1 … ∧ paramsOkK2 … ∧ paramsOkK3 … ∧ paramsOkK4Pre φ B` (a verbatim copy of the library's conjunction with the frozen fourth conjunct, documented as "the parameter conditions as the obligation was filed against"); `CellLEZeroConstOfKappaEqPre` as the library schema's text with `ParamsOkPre`; `BC := 2` (replacing `Bof …`), `paramsOkPreD : ParamsOkPre … TcC TnC PC 2` from `paramsOk_params`'s first three components plus `by simp [paramsOkK4Pre, dBack_chiD]`; the headline `cellLEZeroConstOfKappaEqPre_refuted : ¬ CellLEZeroConstOfKappaEqPre …` and `exists_refuting_cell_collision` restated against the Pre schema with the same proofs; NEW `dFwd_chiD : dFwd chiD = 4`, `not_paramsOkK4_two : ¬ paramsOkK4 chiD 2`, and `kappa_D_dissolves : kappa TcC TnC PC (Bof stepC pendC labC chiD) (c0, c0 + 2) ≠ kappa TcC TnC PC (Bof stepC pendC labC chiD) (c0, c0 + 2 + (PC + 1))` (the unclipped gap `2` against a gap of at least `3` once `B ≥ 9`). `#print axioms` lines for every headline; header prose updated (probes under `specs/evidence/` may narrate the repair).
- [x] Update the probe's WIRED table block in `scripts/check-evidence-probes.sh` to the re-anchored headlines.
- [x] Confirm the two older probes are untouched by the change: `bash scripts/check-evidence-probes.sh` exits 0 with all 47.
- [x] `grep -rn '(K4)\|d_back\|dBack\|dFwd' typst/ docs/` *(completed — no Typst or docs statement of (K4); the docs hits are `ced_backward`)* — authoring-time result: no statement of `(K4)` outside `FormalSystem/` (the `docs/` hits are `ced_backward`); if a Typst statement exists after all, amend it and run `bash scripts/typst-sync-check.sh`.
- [x] Record the repair's rationale in `issues.jsonl` as a design-record entry (the recorded decision, the constant chosen, the consumers re-read).

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: The repair touches exactly one definition body (`paramsOkK4`), one output (`Bof`), one new definition (`dFwd`), one proof (`paramsOk_params`, three new bullets) and their docstrings in `CounterQuotient.lean`, plus the probe's re-anchoring; no theorem signature changes anywhere and no module outside `CounterQuotient.lean` needs a code edit — confirm by the consumer inventory grep above returning the same five files and by `git diff --stat` at the commit.

**Tier Justification**: `paramsOkK4` and `Bof` are definitions whose consumers span `CounterQuotient.lean`, `LadderAgree.lean` (through `ParamsOk`, by name), the two older wired probes and the axiom test — guarded scoped builds of `FormalSystem.Metalogic.Decidability.RaySummary` and `BimodalTest.Metalogic.KTypeSummaryAxiomTest` plus `bash scripts/check-evidence-probes.sh` enumerate exactly that one-hop dependent set.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` - `dFwd`, `paramsOkK4`, `Bof`, `paramsOk_params`, docstrings and header prose
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - line 198 docstring, only if it states the old bound
- `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` - frozen `ParamsOkPre`, Pre schema, `BC := 2`, three new theorems, header
- `scripts/check-evidence-probes.sh` - the probe's table block updated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0 (every existing `#guard_msgs` pin still matches — `paramsOk_params`'s axiom profile is unchanged).
- `bash scripts/check-evidence-probes.sh` prints `PASS  all 47 wired probe(s) compile`.
- `lean_verify` (or `#print axioms`) on `FormalSystem.Metalogic.Decidability.RaySummary.paramsOk_params`, `Probe836A.cellLEZeroConstOfKappaEqPre_refuted`, `Probe836A.not_paramsOkK4_two`, `Probe836A.kappa_D_dissolves`: no `sorryAx`, no custom axiom, no `native_decide`.
- `grep -n 'paramsOkK4' FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` shows the three-conjunct body; `grep -c 'dFwd' …CounterQuotient.lean` is at least 4 (definition, `(K4)`, `Bof`, docstring).
- `bash scripts/check-module-invariants.sh` exits 0; `bash .claude/scripts/check-task-references.sh --quiet FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean scripts/check-evidence-probes.sh` exits 0; the edited docstrings contain none of "previously", "no longer", "formerly", "repaired", "v1".

---

### Phase 3: Regime-B Decision Gate — the Tight Doubling Chain and the Spanning-Block Condition [COMPLETED]

**Gate verdict (Phase 3)**: FAIL — 2026-11-03. The spanning-block condition is REFUTED in BOTH directions by compiled objects smaller than the chain, so no derivation from `(K1)`-`(K4)` is possible (`prototype/tight-chain-regime-b.lean`, exit 0, six headlines at `[propext, Classical.choice, Quot.sound]`, no `sorryAx`). The non-derivable quantity is the existence of a SECOND type-equal partner across a pin: backward, `spanningBlockBwd_refuted` at the path `gB` (pending forever into the past, ONE idle position at `0`, a region of length `Tc + 2` after it) with the closure of `chiB := a S ¬a` (`dBack = 1`, `dFwd = 0`, stab-free) — every position `u ≤ 0` has no idle position in its past and every position `≥ 1` has, so the only region start in the past of `z = 2` (at `1`) is straddled by no block with equal types at its ends; forward, `spanningBlockFwd_refuted` at Probe761C's own `gC` (pending on `(-∞, c₀]`, idle forever after), which has no idle-to-pending transition above `z` at all. The tight doubling chain itself is landed as required (`tightChain_isLadderPath` through `exists_ladderPath_of_walk` with `n₀ := 0`; `tightChain_pin`: the register equals the position at every pin; `tightChain_slack_zero`; `tightChain_pins`). The past-extension attempt on the chain stops at the type condition (recorded in the prototype's header): for the register alone a spanning block of length `l` at the pin `2^J - 2` needs `2^(J-1) ≤ l ≤ 2^J`, but a closure of `U`-nesting depth `D` distinguishes the last `D` regions of the chain from each other, so for `J ≤ D + 1` no spanning block exists at any pin for that closure. The FAIL concerns the DEVICE: at the two refuting objects the register on the pin-free side can be rebuilt without any spanning block, so the obligation under the repaired `(K4)` is neither proved nor refuted there. Phase 10 closes `[BLOCKED]` per its FAIL branch.

**Goal**: Before any hour is spent on the depth-`0` theorem, establish by a compiled prototype whether the open combinatorial core — a type-respecting block SPANNING a region start (so each copy carries a pin), in both the backward and the forward direction — is derivable from the repaired `ParamsOk`, and record a PASS/FAIL verdict that Phase 10 reads.

**Tasks**:
- [x] Prototype `specs/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean` (NOT a wired probe; `lake env lean` through the build guard): define the tight doubling chain on Probe761C's two-state object — regions of lengths `2^j - 1` for `j = 1..J`, unit idle runs, register climbing by exactly `1` per step — and prove `tightChain_isLadderPath` (via `cntAt_eq_nxtAt_of_idle_pend` and `Drift`) and `tightChain_slack_zero` (every backward gap between consecutive pins has Lipschitz slack `0`: `(s - s_prev) = |n(s) - n(s_prev)|`).
- [x] State the spanning-block condition as a Lean `Prop` in the prototype, in both directions: BACKWARD — for every ladder path with an idle position below `z` and `Tc ≤ cntAt g z`, under `ParamsOk`, there is a type-respecting block (equal `(objAt, tpOf)` at its ends) containing a region start in the past of `z`; FORWARD — the mirror for the region after `z`'s. Attempt, time-boxed to one hour, to derive it from `(K1)`-`(K4)` — in particular from `(K2)`'s `cascadeBound pend φ = 2 ^ card (ProdState Q φ) * (tIdle pend + 2)` shape, read as a pigeonhole over the region starts of a doubling chain. A derivation counts only if it is written as a compiled statement whose proof the implementer could transcribe from a paper argument recorded in the prototype's header.
- [x] Attempt the past-extension on the tight chain for ONE `l` *(deviation: altered — not pursued past the register analysis, because the spanning block it duplicates is refuted; where it stops is recorded in the prototype header and the verdict note)* (duplicate a spanning block, pump the copies by increasing amounts, rebuild the register by `exists_ladderPath_of_walk`), as far as the hour allows; record where it stops.
- [x] Record the verdict: PASS iff the spanning-block condition is derived in both directions as above; FAIL otherwise (including "not reached within the box"). Write it as a dated note directly under this phase's heading, in `issues.jsonl` (class design-record defect or ambiguity, severity blocking on FAIL), and in the phase-end handoff. On FAIL, state in the note exactly which quantity is not derivable and the smallest object that witnesses it.
- [x] Run `bash .claude/scripts/validate-artifact.sh specs/836_ladder_type_preserving_cell_agreement_construction/plans/01_obligation-repair-and-pump-layer.md plan` after the note is added.

**Timing**: 2 hours (the derivation attempt capped at one hour; the box is the criterion, not a target)

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: The prototype is 150-300 lines (Probe761C's own object and path constructions are the template; the chain is a `ℤ`-indexed piecewise function with `J` as a parameter) and touches no library module — confirm by `git diff --stat` showing only `specs/836_…/prototype/` and this plan.

**Tier Justification**: The prototype compiles standalone through `bash .claude/scripts/lake-build-guard.sh build --timeout 800 -- env lean specs/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean` and the plan note passes `bash .claude/scripts/validate-artifact.sh <plan> plan`; nothing under `FormalSystem/` or `Tests/` changes, so those two checks are the complete covering check.

**Files to modify**:
- `specs/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean` - new prototype
- `specs/836_ladder_type_preserving_cell_agreement_construction/plans/01_obligation-repair-and-pump-layer.md` - the gate verdict note under this heading

**Verification**:
- The prototype's guard run reports `exit_status=0` with zero errors; `#print axioms` on `tightChain_isLadderPath` and `tightChain_slack_zero` show no `sorryAx`.
- A `**Gate verdict (Phase 3)**:` line exists under this heading reading `PASS` or `FAIL` with the date and the evidence (the prototype's theorem names, or the named non-derivable quantity).
- `issues.jsonl` carries the verdict entry.

---

### Phase 4: `LadderPump.lean` — the Deletion Admissibility Layer and Module Wiring [COMPLETED]

**Goal**: A new certificate-free module beside `LadderAgree.lean` holds the deletion mirror of the landed splice layer and proves `exists_deleted_ladderPath_of_pend_past`; the module is wired into both root imports, the README inventory and the axiom test.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean`: copyright header; `import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree` and nothing else; module docstring stating its contract — certificate-free under `LadderAgree.lean`'s grep (`certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|cohIdle|satThreshold|satPeriod`), one argument about ladder paths and their types under index-map surgery; names the two windows and the probe.
- [x] `delIdx (a : ℤ) (l : ℕ) (v : ℤ) : ℤ := if v < a then v else v + l` (strictly monotone; image `ℤ \ [a, a + l)`), with `delIdx_of_lt`, `delIdx_of_ge`, `delIdx_strictMono`, and `delIdx_spliceIdx`/`spliceIdx_delIdx` relating it to the landed retraction.
- [x] `delObj g a l v := objAt g (delIdx a l v)`; `delCnt g a l v := if v < a then (if a ≤ v + (cntAt g v : ℤ) then cntAt g v - l else cntAt g v) else cntAt g (v + (l : ℤ))`; the three `Count` readings `delCnt_idle`, `delCnt_pend_pend`, `delCnt_pend_idle` mirroring `spliceCnt_idle`/`spliceCnt_pend_pend`/`spliceCnt_pend_idle` (hypotheses `0 < l`, `l ≤ cntAt g a`, `objAt g a = objAt g (a + l)`); the payoff `delCnt_sub_of_mem_region : v ≤ a → a ≤ v + cntAt g v → delCnt g a l v = cntAt g v - l`.
- [x] `exists_deleted_ladderPath_of_pend_past` (Goal, signature as pinned below): mirror `exists_spliced_ladderPath_of_pend_past` line for line through `exists_ladderPath_of_walk`, with the pin condition LOWERED by `l` (the pending-forever regime has no pin below `a`; pins above are the original's translated by `-l`).
- [x] Wiring: `import FormalSystem.Metalogic.Decidability.RaySummary.LadderPump` after the `LadderAgree` line in `FormalSystem/Metalogic/Decidability/RaySummary.lean` and in `FormalSystem.lean`'s RaySummary block; `bash scripts/check-module-invariants.sh --emit-inventory` then hand-write the `LadderPump.lean` description cell in `RaySummary/README.md`'s generated table (the generator carries descriptions across by file name and seeds a `<!-- TODO: add description -->` for a new file); `--emit-inventory --check` exits 0.
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: a new `/-! ## Requirement (W): the type-preserving pump layer … -/` block and `#guard_msgs in #print axioms` pins for `delIdx`, `delCnt_sub_of_mem_region` and `exists_deleted_ladderPath_of_pend_past`.
- [x] `grep -nE 'certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|ClType|LadderCons|prodPre_periodic|prodPreStep|cohIdle|satThreshold|satPeriod' FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` returns nothing.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: The deletion layer is 180-260 lines (the splice layer it mirrors spans `LadderAgree.lean` lines 1007-1155 and 1219-1316 by the section markers, re-derived at authoring) and five files change (`LadderPump.lean`, `RaySummary.lean`, `FormalSystem.lean`, `RaySummary/README.md`, the axiom test) — confirm by `wc -l` and `git diff --stat` at the commit.

**Tier Justification**: The new module's only externally visible effect is two import edges (`RaySummary.lean`, `FormalSystem.lean`) plus the axiom-test pins — guarded scoped builds of `FormalSystem.Metalogic.Decidability.RaySummary.LadderPump`, of `FormalSystem` (the root that now imports it) and of `BimodalTest.Metalogic.KTypeSummaryAxiomTest`, plus `bash scripts/check-module-invariants.sh`, enumerate that one-hop dependent set.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` - new module
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import line
- `FormalSystem.lean` - one import line
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - regenerated inventory block plus the new row's description
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - new pin block

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderPump` exits 0; `… -- build FormalSystem` exits 0; `… -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0.
- `#print axioms` on `exists_deleted_ladderPath_of_pend_past` shows no `sorryAx`; `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial' …/LadderPump.lean` is 0.
- The certificate-freedom grep above returns nothing; `bash scripts/check-module-invariants.sh` exits 0 (inventory current, C9 clean, C14 counts match).
- `bash .claude/scripts/check-task-references.sh --quiet FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` exits 0.
- The Goal's signature matches the `## Lean Challenge Statements` block token for token (the `abbrev` pins for `delIdx`/`delObj`/`delCnt` are now definitions with the bodies above).

---

### Phase 5: The Duplication Type Lemma — Pinned Form and Stab-Free Instance [COMPLETED]

**Goal**: `tpOf_eq_spliceIdx_of_tpOf_eq` is landed: duplicating a type-respecting block preserves the stab-free closure type at EVERY position, read through `spliceIdx`, proved by the pinned-letter induction the landed transport layer uses.

**Tasks**:
- [x] Index-map helpers in `LadderPump.lean`: `spliceIdx` is an order isomorphism on each side of the seam `u + l` (`spliceIdx_lt_iff_of_same_side`), and the guard-set retraction lemma: for `w < u + l ≤ s`, the image of `(w, s)` under `spliceIdx u l` contains `(w, s - l)` (the two sub-intervals `(w, u + l)` and `[u, s - l)` retract onto it).
- [x] The truth-level pinned-form lemma `plusTruthAt_iff_spliceIdx_of_tpOf_eq_of_stabPinned`: induction on `ψ` with the invariant `ψ ∈ plusSubformulaClosure φ` (closure lemmas `plusClosure_untl_left/right`, `plusClosure_snce_left/right`, `plusClosure_box`, the `imp` projections) and `StabPinned L ψ`, proving `∀ w, PlusTruthAt M σ' w ψ ↔ PlusTruthAt M σ (spliceIdx u l w) ψ`. Let `E(θ)` abbreviate the endpoint equality `truth(σ, u, θ) ↔ truth(σ, u + l, θ)` obtained from `hty` through `mem_tpOf_iff`. Cases, in this order, following the report's clause-by-clause verification: `atom` (by `hobj` and the valuation reading the object component), `bot`, `imp` (structural), `box` (`box_mem_tpOf_transfer` — the two times differ, so `Iff.rfl` is NOT available), `stab` (by `hL`), `untl` duplication `σ' → σ` (same side: IH; `w < u + l ≤ s` with `s - l > w`: witness `s - l` with the retracted guard; fold-back `s - l ≤ w`, forcing `w ∈ [u, u + l)`: sub-case `s - l > u` through `E(ψ U χ)` and `E(ψ)` at `u`; sub-case `s - l = u` through `E(χ)`), `untl` `σ → σ'` (the four sub-cases of the report: `w ≥ u + l` shift by `l`; `w < u` with `s₀ < u + l` or `s₀ + l`; `w ∈ [u, u + l)` with `s₀ = u + l` through `E(χ)` or `s₀ > u + l` through `E(ψ)`, `E(ψ U χ)` and the three positions of the new witness `s₁`), `snce` (the mirror, with the fold in the FIRST copy, through `E(ψ S χ)` and `E(ψ)` at `u`). The hypothesis for `ψ U χ` itself is used at the endpoints and never the induction hypothesis for it; `E(ψ)`/`E(χ)` are used at exactly one position each.
- [x] `tpOf_eq_spliceIdx_of_tpOf_eq` (Goal) as the `L := fun _ => False` instance via `stabPinned_false_of_mem_closure` and `mem_tpOf_iff`, with the signature pinned below.
- [x] Docstring: cite the literature in the prose form `Closure.lean` uses ("HWZ 2000 Lemma 17", the deletion form of which this is the mirror); state what the lemma does NOT need (no pending-region hypothesis, no `ParamsOk`, no pin condition — those are the admissibility layer's).
- [x] Axiom-test pin for the Goal.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: The induction is 200-300 lines (six clause cases; four seam sub-cases for each of `U` and `S`, both directions) — if it exceeds 300, split the `untl` and `snce` cases into named helper lemmas rather than compress; confirm by `wc -l` at the commit.

**Tier Justification**: Edits are confined to `LadderPump.lean` (new theorems, no externally visible signature changed) plus one axiom-test pin — the guarded scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.LadderPump` and of `BimodalTest.Metalogic.KTypeSummaryAxiomTest` is the complete covering check.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` - helpers, the pinned-form lemma, the Goal
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - one pin

**Verification**:
- Guarded scoped builds of `LadderPump` and the axiom test exit 0; `#print axioms` on the Goal shows `[propext, Classical.choice, Quot.sound]` or a subset, no `sorryAx`.
- `lean_verify FormalSystem.Metalogic.Decidability.RaySummary.tpOf_eq_spliceIdx_of_tpOf_eq` reports no `sorry` in the source scan.
- The Goal's signature matches the `## Lean Challenge Statements` block token for token.
- The certificate-freedom grep of Phase 4 still returns nothing; `bash scripts/check-module-invariants.sh` exits 0.

---

### Phase 6: The Deletion Type Lemma — HWZ 2000 Lemma 17 over `ℤ` [COMPLETED]

**Goal**: `tpOf_eq_delIdx_of_tpOf_eq` is landed: deleting a type-respecting block preserves the stab-free closure type at every position, read through the monotone `delIdx`.

**Tasks**:
- [x] The truth-level pinned-form lemma `plusTruthAt_iff_delIdx_of_tpOf_eq_of_stabPinned`, the same induction as Phase 5 with `delIdx u l` in place of `spliceIdx u l`. Because `delIdx` is monotone, witnesses transport forward trivially; the only gap is the deleted block `[u, u + l)` inside a guard interval or carrying the witness. Sub-cases, following HWZ 2000 Lemma 17's `⇒`-case for `ψ₁ U ψ₂` verbatim: witness `s` of the original with `s ≥ u + l` (shift by `-l`, guard retracted across the block through `E(ψ)` at `u`); witness inside the block, `s > u` (then `ψ U χ` holds at `u` on `σ`, so by `E(ψ U χ)` at `u + l` with a new witness beyond the block); witness `s = u` (through `E(χ)`); and the `S` mirrors with the block in the past.
- [x] `tpOf_eq_delIdx_of_tpOf_eq` (Goal) as the `L := fun _ => False` instance; docstring citing "HWZ 2000 Lemma 17" in the prose form; axiom-test pin. *(deviation: altered — `LadderPump.lean` reached 1,239 lines; the Scope Hypothesis's move to `LadderPumpType.lean` was taken and then reverted in the same phase, because that contingency file is outside the task's declared `file_scope` and no commit route in this dispatch can carry it; `LadderPump.lean` stays one module at 1,239 lines, under the package `longFile` 1,500 with no baseline raised)*
- [x] Record in the docstring that the lemma needs no pending-region hypothesis and that the admissibility side (`exists_deleted_ladderPath_of_pend_past`) is where the pins enter.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: 150-250 lines, shorter than Phase 5 because monotonicity removes the fold-back sub-cases — confirm by `wc -l`; `LadderPump.lean` stays under 1,000 lines after this phase (if it does not, the two type lemmas move to `LadderPumpType.lean` with the same import and grep contract rather than any baseline being raised).

**Tier Justification**: Edits are confined to `LadderPump.lean` plus one axiom-test pin; the guarded scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.LadderPump` and of `BimodalTest.Metalogic.KTypeSummaryAxiomTest` is the complete covering check.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` - the pinned-form lemma and the Goal
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - one pin

**Verification**:
- Guarded scoped builds exit 0; `#print axioms` on the Goal shows no `sorryAx`; `lean_verify` clean.
- The Goal's signature matches the Challenge block token for token.
- Certificate-freedom grep clean; `check-module-invariants.sh` exits 0.

---

### Phase 7: The Pigeonhole, the Iterated Countdown and the Forward Window [COMPLETED]

**Goal**: `exists_typeBlock_of_budget_le_cnt` and `nxtAt_le_cntAt_add_of_next_region` are landed, together with the bookkeeping that iterated duplication raises a countdown by exactly `d · l`.

**Tasks**:
- [x] `exists_typeBlock_of_budget_le_cnt` (Goal): with `c := cntAt g z ≥ budget := card Q * 2 ^ |closure|`, the `budget + 1` positions `z, …, z + budget` are pending and inside the region (`cntAt_sub_of_pend`); map each to `(objAt g v, tpOf M φ σ v)` in `Q × {T // T ∈ (plusSubformulaClosure φ).powerset}` (membership from `mem_tpOf_iff`/`Finset.filter_subset`); `Fintype.exists_ne_map_eq_of_card_lt` on `Fin (budget + 1)` against `Fintype.card_prod`, `Fintype.card_coe` and `Finset.card_powerset` (the budget is written out, NOT through `ClType`/`ProdState`, which this module's grep forbids); order the pair as `u < u + l`, `l ≤ budget`, `z ≤ u`, `l ≤ cntAt g u` (from `u + l ≤ z + budget ≤ z + c = u + cntAt g u`).
- [x] `cntAt_iterSplice` bookkeeping *(deviation: altered — landed as `exists_iterSpliced_ladderPath_of_pend_past`, a single induction packaging the countdown at every region position before the block, the pending copies, the displaced walk above them, and the type at every position before the block's end; the pigeonhole is landed twice, as `exists_typeBlock_of_budget_le_cnt_within` recording the block's position and the pinned Goal derived from it)*: for `z ≤ u` and `u ≤ z + cntAt g z`, after `d` duplications of `[u, u + l)` (each by `exists_spliced_ladderPath_of_pend_past`, the hypotheses `l ≤ cntAt g u`, `objAt g u = objAt g (u + l)` and pending-forever past re-established at each step from `spliceCnt_add_of_mem_region`, `spliceObj_of_lt`/`spliceObj_of_ge`), the countdown at `z` is `cntAt g z + d * l` and the object at `z` is unchanged; the type at `z` is preserved at each step by Phase 5's Goal with `spliceIdx u l z = z`.
- [x] `nxtAt_le_cntAt_add_of_next_region` (Goal): the pin at `v := z + cntAt g z + I` (idle, `v + 1` pending by `hidle`/`hnext`) gives `cntAt g (v + 1) = nxtAt g v` (`cntAt_eq_nxtAt_of_idle_pend`); `nxtAt_lipschitz` over `j := cntAt g z + I` steps bounds `nxtAt g z ≤ nxtAt g v + j`; `omega` on `natAbs` closes. Docstring: this is the FORWARD window the cell reads, the mirror of the landed backward window `cntAt_le_nxtAt_succ_of_idle_past`, and the quantity `(K4)`'s forward conjunct must dominate.
- [x] Axiom-test pins for both Goals.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: 120-200 lines; the pigeonhole budget expression `Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card` matches `card_prodState` of task 761's `step0-budget-check.lean` (re-derived at authoring) so Phase 8 can equate the two without restating either.

**Tier Justification**: Edits are confined to `LadderPump.lean` plus two axiom-test pins; the guarded scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.LadderPump` and of `BimodalTest.Metalogic.KTypeSummaryAxiomTest` is the complete covering check.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` - the two Goals and the iteration bookkeeping
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - two pins

**Verification**:
- Guarded scoped builds exit 0; `#print axioms` on both Goals: no `sorryAx`.
- Both signatures match the Challenge block token for token.
- Certificate-freedom grep clean (in particular no `ClType`, no `ProdState`); `check-module-invariants.sh` exits 0.

---

### Phase 8: `LadderChain.lean` — the Realized-Chain Bridge and the Exact Shift [COMPLETED]

**Goal**: A second new module, not certificate-free by design, proves that a realized pending type-respecting block is a `prodCycleLens` member, hence that its length divides `P + 1` under `(K1)`; the budget lemmas of the `step0` prototype are promoted beside it.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`: imports `LadderPump` and `CounterQuotient`; module docstring stating that it reads `locCoh`, `untlLink`, `snceLink`, `SatCl` and `prodCycleLens` — the LOCAL, one-directional half of obligation (S) — and NO certificate-set object; its own grep `certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|LadderCons|prodPre_periodic|prodPreStep|satThreshold|satPeriod` returns nothing; why this is not the recorded circularity (which runs through `certStabK` and `certBiInfK`).
- [x] Promote `card_prodState`, `budget_le_cascadeBound`, `budget_le_Tc` from `specs/761_ladder_realization_theorem/prototype/step0-budget-check.lean` verbatim (the prototype stays in place as the record).
- [x] Local coherence of realized types: `locCoh_of_realized` (the `atom` arm from `atom_mem_tpOf_ladder_iff` against `ladderModel`'s valuation, `bot` from `bot_not_mem_tpOf`, `imp` from `imp_mem_tpOf_iff`; the modal and temporal arms of `locPred` are `true`); `untlLink_of_realized` and `snceLink_of_realized` (the strict one-step unfoldings from `untl_mem_tpOf_iff`/`snce_mem_tpOf_iff` over `ℤ` by splitting the witness at `z + 1`, resp. `z - 1`); `satCl_of_cycle` (the `l`-periodic walk is its own infinite forward `cohIdle`-walk).
- [x] `realized_typeBlock_mem_prodCycleLens` (Goal): the walk `f i := (objAt g (u + i % l), ⟨tpOf M φ σ (u + i % l), _⟩)` is `cohIdle`-linked (`step` along the ladder path from `IsLadderPath`'s step component; the link conditions above), pending throughout (`cntAt_sub_of_pend` with `l ≤ cntAt g u`), saturated at every point, closes at `l` by `hrep`/`hty`, and `l ≤ card (ProdState Q φ)` by `hbud` and `card_prodState`.
- [x] Corollary `typeBlock_length_dvd_of_paramsOk : … → l ∣ P + 1` from `hp.1.1`.
- [x] Wiring as in Phase 4: both root imports, `--emit-inventory` plus the description cell, axiom-test pins for the Goal and the corollary.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: 200-350 lines and five files (`LadderChain.lean`, `RaySummary.lean`, `FormalSystem.lean`, the README, the axiom test); the `untlLink`/`snceLink` unfoldings are the uncertain item — if `linkPred`'s `==`-shape needs a `decide` bridge beyond `simp`, that is a helper, not a scope change. Confirm by `wc -l` and `git diff --stat`.

**Tier Justification**: The new module's only externally visible effect is two import edges plus the axiom-test pins — guarded scoped builds of `FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`, of `FormalSystem` and of `BimodalTest.Metalogic.KTypeSummaryAxiomTest`, plus `bash scripts/check-module-invariants.sh`, enumerate that one-hop dependent set.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - new module
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import line
- `FormalSystem.lean` - one import line
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - regenerated inventory block plus the new row's description
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - pins

**Verification**:
- Guarded scoped builds of `LadderChain`, `FormalSystem` and the axiom test exit 0; `#print axioms` on the Goal and the corollary: no `sorryAx`.
- `grep -nE 'certAdmK|certStabK|certBoxK|certBiInfK|certLocK|certFwdK|certBwdK|certChain|Dmax|LadderCons|prodPre_periodic|prodPreStep|satThreshold|satPeriod' …/LadderChain.lean` returns nothing.
- The Goal's signature matches the Challenge block token for token.
- `bash scripts/check-module-invariants.sh` exits 0; `check-task-references.sh --quiet …/LadderChain.lean` exits 0.

---

### Phase 9: The Regime-A Assembly and the Upward Cell Inclusion [COMPLETED]

**Goal**: `exists_ladderPath_through_shifted_of_pend_past` is landed: through a pending-forever path's state at countdown at least `Tc`, a ladder path with the countdown raised by exactly `m · (P + 1)`, the register and the object state held, and the same stab-free type; and its cell-level corollary, the upward inclusion along the common-shift chain.

**Tasks**:
- [x] In `LadderChain.lean`, `exists_ladderPath_through_shifted_of_pend_past` (Goal): `budget + 1 ≤ Tc ≤ cntAt g z` (`budget_le_Tc`); Phase 7's pigeonhole gives `(u, l)` with `z ≤ u`; Phase 8's corollary gives `l ∣ P + 1`, so `d := m * (P + 1) / l` with `d * l = m * (P + 1)`; Phase 7's iterated duplication gives a ladder path `g₁` with `cntAt g₁ z = cntAt g z + m * (P + 1)`, `objAt g₁ z = objAt g z`, pending-forever past, and `tpOf` at `z` preserved along the histories (`exists_hist_of_isLadderPath` at each step, Phase 5's Goal, `tpOf_stabFree_eq_of_objAt_eq` to pass between histories of paths with the same object walk).
- [x] Hold the register: `g₁`'s register is whatever the splice lemma produced; rebuild it with `exists_ladderPath_of_walk` on `g₁`'s object walk and countdown, translated so that `z` sits at the origin, with `n₀ := nxtAt g z`. Discharge `hpins` from `pinCompat_of_ladderPath` on the original path (the displaced pins are the original's translated by `m · (P + 1)`, pairwise compatible by translation invariance) and `hn₀` from the forward window: there is no pin below (pending forever), and the first pin above lies at distance `cntAt g z + m * (P + 1) + I₁` from `z`, which exceeds the distance `cntAt g z + I₁` the original path's register already bridged. Types are register-invisible (`tpOf_stabFree_eq_of_objAt_eq`).
- [x] Corollary `cellAt_subset_of_shift_of_pend_past`: under `hp`, `hno`, `n + 2 ≤ c` (so `pend_past_of_nxtAt_lt` gives the pending-forever past for EVERY path through `(q, c, n)`) and `Tc ≤ c`: `cellAt M φ (z, ⟨(q, c, n), h⟩) z ⊆ cellAt M φ (z, ⟨(q, c + m * (P + 1), n), h'⟩) z`, through `mem_cellAt_ladder_iff` in both directions.
- [x] Docstring: name precisely why this is ONE direction (the downward inclusion shrinks the forward window) and which sub-regimes of `kappa_eq_components` it covers (`n = n'`, and the common shift `n' = n + m · (P + 1)` by the same construction with `n₀ := n'` inside the widened window); axiom-test pins for the Goal and the corollary.

**Timing**: 2 hours

**Depends on**: 2, 5, 7, 8

**Verification Tier**: local

**Scope Hypothesis**: 150-250 lines; the register rebuild is the uncertain item — `exists_ladderPath_of_walk`'s `hn₀` is stated at the origin, so the translation by `z` is a `tpOf_timeShift`/`cellAt_eq_cellAt` bookkeeping step, not a new lemma. Confirm by `wc -l` at the commit.

**Tier Justification**: Edits are confined to `LadderChain.lean` plus axiom-test pins; the guarded scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` and of `BimodalTest.Metalogic.KTypeSummaryAxiomTest` is the complete covering check.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the Goal, the corollary, the register-rebuild helper
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - two pins

**Verification**:
- Guarded scoped builds exit 0; `#print axioms` on the Goal and the corollary: no `sorryAx`; `lean_verify` clean.
- The Goal's signature matches the Challenge block token for token; `hp` is a USED hypothesis (`lean_minimal_hypotheses` or a deletion trial reports it needed — the budget and the divisibility both consume it).
- `LadderChain.lean`'s grep clean; `check-module-invariants.sh` exits 0.

---

### Phase 10: The Depth-`0` Cell Agreement Under the Repaired `(K4)` — GATED ON PHASE 3 [NOT STARTED]

**GATED ON PHASE 3's VERDICT.** This phase is entered as a PROOF ATTEMPT only if Phase 3 recorded `PASS`. On `FAIL`, no proof is attempted: the phase closes `[BLOCKED]` per `plan-compliance.md`'s escalate-rather-than-substitute rule, with the handoff below, and Phase 11 still runs. The remedy on `FAIL` is never a `sorry`, a narrowed restatement under the reserved name, a positionwise or regime-restricted weakening of the schema's text, or a vacuous definition.

**Goal**: `cellLE_zero_const_of_kappa_eq : CellLEZeroConstOfKappaEq step pend fwd bwd lab φ Tc Tn P B` is landed in `LadderChain.lean`, and task 761's Phase 11.6 gate lifts.

**Tasks** (PASS branch):
- [ ] Unfold the schema; from `kappa_eq_components` and `eq_or_both_ge_of_min_eq` on `c, c'` and on `n, n'`, dispose of the trivial case `c = c' ∧ n = n'`; in the saturated regime (`Tc ≤ c, c'`, equal residues, equal clipped gap) take `c < c'` without loss (symmetry of set equality) and split by `clipIdx_regime_of_eq` into regime A (`n + 2 ≤ c`, pending-forever past) and regime B (`c' ≤ n`, an idle position in the past).
- [ ] Regime A, upward inclusion: Phase 9's corollary for `n = n'`; for the common shift `n' = n + m · (P + 1)` the same assembly with `n₀ := n'`; for the third sub-regime (both gaps clipped, `n' - n ≠ c' - c`) and for EVERY downward inclusion, the Phase 3 device (the forward spanning-block lengthening or shortening of the next region, with the register rebuilt inside the window).
- [ ] Regime B: the Phase 3 backward device (duplicate a block spanning a region start, pump the copies by increasing amounts, rebuild the register from the new pins; absorb the time shift of `z` by `tpOf_timeShift`/`cellAt_eq_cellAt`), Phase 6's deletion lemma for the downward direction.
- [ ] The `n` coordinate inside the windows by re-profiling alone (`tpOf_stabFree_eq_of_objAt_eq`), outside them by the Phase 3 device.
- [ ] Records: `LadderAgree.lean`'s obligation docstring now says the reserved name is claimed, in `LadderChain.lean`, under the repaired `(K4)`; the axiom-test (W) block's "claimed by nothing" sentence amended; pin for the Goal; task 761's reviser is told in the summary that its Phase 11.6 gate is satisfiable.

**Tasks** (FAIL branch):
- [ ] Close this phase `[BLOCKED]`. The handoff names: the Phase 3 verdict and its evidence; the two cascades (backward on the tight doubling chain, forward on its mirror) as the open combinatorial core; what the landed layer (Phases 4-9) gives a successor construction; that `cellLE_zero_const_of_kappa_eq` stays reserved and claimed by nothing (`grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returns only docstrings); and the two routes a successor has — a `(K2)`-level pigeonhole over region starts that yields the spanning block, or a restated obligation whose statement is NOT the schema's text (a `/revise` act for the user, never an implementer's).
- [ ] Record the block in `issues.jsonl` (class design-record defect or ambiguity, severity blocking) and in `.return-meta.json` as `blocked` with `errors[]` carrying the recommendation.

**Timing**: 2 hours on PASS; under 0.5 hours on FAIL

**Depends on**: 3, 6, 9

**Verification Tier**: local

**Scope Hypothesis**: On PASS, 250-400 lines in `LadderChain.lean` and docstring edits in `LadderAgree.lean` (within its 159-line headroom) — confirm by `wc -l`; on FAIL, no library file changes at all — confirm by `git diff --stat` showing only `specs/`.

**Tier Justification**: Edits are confined to `LadderChain.lean` (new theorem), `LadderAgree.lean` (docstrings) and the axiom test — guarded scoped builds of `FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`, `…LadderAgree` and `BimodalTest.Metalogic.KTypeSummaryAxiomTest` are the complete covering check, with the full gate set owed by Phase 11.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the Goal (PASS only)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - obligation docstring (PASS only)
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - one pin and one prose amendment (PASS only)
- `specs/836_ladder_type_preserving_cell_agreement_construction/handoffs/` - the phase handoff (both branches)

**Verification**:
- PASS: guarded scoped builds exit 0; `#print axioms FormalSystem.Metalogic.Decidability.RaySummary.cellLE_zero_const_of_kappa_eq` shows `[propext, Classical.choice, Quot.sound]` or a subset, no `sorryAx`, no custom axiom, no `native_decide`; the Goal's signature matches the Challenge block token for token; `hp` is a USED hypothesis.
- FAIL: the phase heading reads `[BLOCKED]`; the handoff file exists with the five items above; `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returns only docstring lines; no `sorry` anywhere in the two new modules.

---

### Phase 11: Records, the Full Gate Set, and the Summary [NOT STARTED]

**Goal**: The repository's records state the current design (the two windows, the repaired `(K4)`, the pump layer, the obligation's status), every gate the repository owns runs green, and the summary hands task 761's reviser exactly what it needs.

**Tasks**:
- [ ] `RaySummary/README.md`, under `### (W): what landed and what did not`: a short "What the cell reads of the register" subsection pairing the backward window `cntAt_le_nxtAt_succ_of_idle_past` with the forward window `nxtAt_le_cntAt_add_of_next_region`, naming `kappa`'s gap coordinate and the forty-seventh probe, and stating the depth-`0` obligation's status as Phase 10 left it (landed in `LadderChain.lean`, or reserved and claimed by nothing with the open core named). Regenerate the inventory block (`--emit-inventory`), confirm `--emit-inventory --check` exits 0.
- [ ] `.claude/context/project/lean4/domain/ladder-counter-observables.md` is NOT edited by this task (it is a deployed `.claude/**` file; the research's context recommendation is relayed in the summary for the source store's owner).
- [ ] Full gate set, each exit status read directly (never through a pipe): `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, read via the guard's `result`); `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest`; `bash scripts/check-evidence-probes.sh`; `bash scripts/check-module-invariants.sh`; `bash scripts/typst-sync-check.sh`; `bash .claude/scripts/verify-deploy.sh`; `bash .claude/scripts/lean-challenge-snapshot.sh --check 836 .` (advisory only; a drift finding is investigated, never a verdict).
- [ ] Summary `specs/836_ladder_type_preserving_cell_agreement_construction/summaries/01_obligation-repair-and-pump-layer-summary.md`: what was refuted and where it is wired; the repaired `(K4)` and the constant; the eight Goals' status; the Phase 3 verdict; for task 761's reviser, whether Phase 11.6's gate (`cellLE_zero_const_of_kappa_eq` landed, `sorryAx`-free) is satisfied, the supersession of plan 08's "no strengthening of `ParamsOk`" Non-Goal by the recorded decision, and the note that the pinned-letter case at depth `≥ 1` needs the pumped block's length `≡ 0 (mod P + 1)` at countdown `≥ Tc`.
- [ ] Final `issues.jsonl` entries (wins and issues of this phase, or the explicit attestation that there were none) and the `.orchestrator-handoff.json`.

**Timing**: 1.5 hours

**Depends on**: 10

**Verification Tier**: full

**Scope Hypothesis**: The README subsection is 15-30 lines and the summary 80-150 lines; `typst-sync-check.sh` is expected clean because no Typst source states `(K4)` (authoring-time grep) — if it reports a count drift, apply its documented Check-2 regeneration (`bash scripts/typst-status-counts.sh`) and re-run.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the (W) subsection and the regenerated inventory
- `specs/836_ladder_type_preserving_cell_agreement_construction/summaries/01_obligation-repair-and-pump-layer-summary.md` - new
- `typst/generated/status.typ` - only if `typst-sync-check.sh` requires regeneration

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` reports `exit_status=0` via `result`; the `BimodalTest` build likewise.
- `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 47 wired probe(s) compile`.
- `bash scripts/check-module-invariants.sh` exits 0 (C9, C14, C15, C35, inventory).
- `bash scripts/typst-sync-check.sh` exits 0.
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- `bash .claude/scripts/check-task-references.sh --quiet FormalSystem/Metalogic/Decidability/RaySummary/README.md` exits 0; the README subsection contains no record-versioning language.
- `bash .claude/scripts/validate-artifact.sh <summary path> summary` exits 0.
- Every phase heading above carries its closing marker; the plan's `- **Status**:` line matches.

## Lean Challenge Statements

The eight `theorem` declarations are the Goals and carry `sorry` bodies, listed in the order the phases prove them. The three `abbrev` declarations precede the first `theorem` (the snapshot tool swallows non-`theorem` text between two `theorem`s into the preceding `:= sorry`) and pin BY POSITION the Phase 4 definitions `delIdx`, `delObj`, `delCnt`; every landed object (`IsLadderPath`, `objAt`, `cntAt`, `nxtAt`, `spliceIdx`, `tpOf`, `ladderModel`, `ladderFrameAdm`, `RladAdm`, `LadderState`, `plusSubformulaClosure`, `ParamsOk`, `prodCycleLens`, `CellLEZeroConstOfKappaEq`) is imported from the library rather than pinned, because it is landed. `ParamsOk` is named, not unfolded, so the repair of `(K4)` changes no signature here. Identifiers are ASCII for the snapshot tool's regex; `∉` and `∈` appear inside hypotheses only.

This block was elaborated standalone at this plan's authoring time through the build guard (`bash .claude/scripts/lake-build-guard.sh build --timeout 480 -- env lean <file>`): `exit_status=0`, zero errors, exactly eleven `declaration uses 'sorry'` warnings (three `abbrev`, eight `theorem`).

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderAgree

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe836P

abbrev delIdx (a : Int) (l : Nat) (v : Int) : Int := sorry

abbrev delObj {Q : Type} {pend : Q -> Bool} (g : Int -> LadderState Q pend) (a : Int) (l : Nat) :
    Int -> Q := sorry

abbrev delCnt {Q : Type} {pend : Q -> Bool} (g : Int -> LadderState Q pend) (a : Int) (l : Nat) :
    Int -> Nat := sorry

theorem nxtAt_le_cntAt_add_of_next_region {Q : Type} {step : Q -> Q -> Bool} {pend : Q -> Bool}
    (g : Int -> LadderState Q pend) (hg : IsLadderPath step pend g) (z : Int) (I : Nat)
    (hI : 0 < I)
    (hidle : forall i : Nat, i < I ->
      pend (objAt g (z + (cntAt g z : Int) + 1 + (i : Int))) = false)
    (hnext : pend (objAt g (z + (cntAt g z : Int) + 1 + (I : Int))) = true) :
    nxtAt g z <= cntAt g z + I + cntAt g (z + (cntAt g z : Int) + 1 + (I : Int)) := sorry

theorem exists_deleted_ladderPath_of_pend_past {Q : Type} {step : Q -> Q -> Bool}
    {pend : Q -> Bool} {g : Int -> LadderState Q pend} {a : Int} {l : Nat}
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l <= cntAt g a)
    (hpast : forall p : Int, p <= a -> pend (objAt g p) = true)
    (hrep : objAt g a = objAt g (a + (l : Int))) :
    exists g' : Int -> LadderState Q pend, IsLadderPath step pend g' /\
      (forall v, objAt g' v = delObj g a l v) /\ (forall v, cntAt g' v = delCnt g a l v) := sorry

theorem tpOf_eq_spliceIdx_of_tpOf_eq {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) (u : Int) (l : Nat) (hl : 0 < l)
    {k k' : Int} {g g' : Int -> LadderState Q pend}
    (sigma sigma' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hsigma : forall t : Int, sigma.state t = (t + k, g t))
    (hsigma' : forall t : Int, sigma'.state t = (t + k', g' t))
    (hobj : forall w : Int, objAt g' w = objAt g (spliceIdx u l w))
    (hno : forall chi : PlusFormula, PlusFormula.stab chi ∉ plusSubformulaClosure phi)
    (hty : tpOf (ladderModel step pend fwd bwd lab) phi sigma u
         = tpOf (ladderModel step pend fwd bwd lab) phi sigma (u + (l : Int))) :
    forall w : Int, tpOf (ladderModel step pend fwd bwd lab) phi sigma' w
      = tpOf (ladderModel step pend fwd bwd lab) phi sigma (spliceIdx u l w) := sorry

theorem tpOf_eq_delIdx_of_tpOf_eq {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) (u : Int) (l : Nat) (hl : 0 < l)
    {k k' : Int} {g g' : Int -> LadderState Q pend}
    (sigma sigma' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hsigma : forall t : Int, sigma.state t = (t + k, g t))
    (hsigma' : forall t : Int, sigma'.state t = (t + k', g' t))
    (hobj : forall w : Int, objAt g' w = objAt g (delIdx u l w))
    (hno : forall chi : PlusFormula, PlusFormula.stab chi ∉ plusSubformulaClosure phi)
    (hty : tpOf (ladderModel step pend fwd bwd lab) phi sigma u
         = tpOf (ladderModel step pend fwd bwd lab) phi sigma (u + (l : Int))) :
    forall w : Int, tpOf (ladderModel step pend fwd bwd lab) phi sigma' w
      = tpOf (ladderModel step pend fwd bwd lab) phi sigma (delIdx u l w) := sorry

theorem exists_typeBlock_of_budget_le_cnt {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula)
    {k : Int} {g : Int -> LadderState Q pend}
    (sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hsigma : forall t : Int, sigma.state t = (t + k, g t))
    (hg : IsLadderPath step pend g) (z : Int) (hz : pend (objAt g z) = true)
    (hbud : Fintype.card Q * 2 ^ (plusSubformulaClosure phi).card <= cntAt g z) :
    exists (u : Int) (l : Nat), 0 < l /\
      l <= Fintype.card Q * 2 ^ (plusSubformulaClosure phi).card /\
      z <= u /\ l <= cntAt g u /\
      objAt g u = objAt g (u + (l : Int)) /\
      tpOf (ladderModel step pend fwd bwd lab) phi sigma u
        = tpOf (ladderModel step pend fwd bwd lab) phi sigma (u + (l : Int)) := sorry

theorem realized_typeBlock_mem_prodCycleLens {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula)
    {k : Int} {g : Int -> LadderState Q pend}
    (sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hsigma : forall t : Int, sigma.state t = (t + k, g t))
    (hg : IsLadderPath step pend g)
    (hno : forall chi : PlusFormula, PlusFormula.stab chi ∉ plusSubformulaClosure phi)
    (u : Int) (l : Nat) (hl : 0 < l)
    (hbud : l <= Fintype.card Q * 2 ^ (plusSubformulaClosure phi).card)
    (hpu : pend (objAt g u) = true) (hcl : l <= cntAt g u)
    (hrep : objAt g u = objAt g (u + (l : Int)))
    (hty : tpOf (ladderModel step pend fwd bwd lab) phi sigma u
         = tpOf (ladderModel step pend fwd bwd lab) phi sigma (u + (l : Int))) :
    l ∈ prodCycleLens step pend lab phi := sorry

theorem exists_ladderPath_through_shifted_of_pend_past {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) (Tc Tn P B : Nat)
    (hp : ParamsOk step pend lab phi Tc Tn P B)
    (hno : forall chi : PlusFormula, PlusFormula.stab chi ∉ plusSubformulaClosure phi)
    (g : Int -> LadderState Q pend) (hg : IsLadderPath step pend g) (z : Int)
    (hpast : forall p : Int, p <= z -> pend (objAt g p) = true)
    (hTc : Tc <= cntAt g z) (m : Nat) :
    exists g' : Int -> LadderState Q pend, IsLadderPath step pend g' /\
      objAt g' z = objAt g z /\ cntAt g' z = cntAt g z + m * (P + 1) /\
      nxtAt g' z = nxtAt g z /\
      forall (sigma sigma' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (forall t : Int, sigma.state t = (t, g t)) ->
        (forall t : Int, sigma'.state t = (t, g' t)) ->
        tpOf (ladderModel step pend fwd bwd lab) phi sigma' z
          = tpOf (ladderModel step pend fwd bwd lab) phi sigma z := sorry

theorem cellLE_zero_const_of_kappa_eq {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (lab : Q -> Atom -> Bool) (phi : PlusFormula) (Tc Tn P B : Nat) :
    CellLEZeroConstOfKappaEq step pend fwd bwd lab phi Tc Tn P B := sorry

end Probe836P
```

## Testing & Validation

- [ ] `bash scripts/check-evidence-probes.sh` exits 0 and reports all 47 wired probes compiling, after Phase 1 and at every later phase.
- [ ] Every Goal landed carries `#print axioms` of `[propext, Classical.choice, Quot.sound]` or a subset, no `sorryAx`, no custom axiom, no `native_decide`; the axiom test pins each one.
- [ ] `grep -cE 'sorry|native_decide|^axiom|:= True|:= trivial'` is 0 on `LadderPump.lean`, `LadderChain.lean` and the forty-seventh probe at every commit.
- [ ] `LadderPump.lean` passes `LadderAgree.lean`'s certificate-freedom grep; `LadderChain.lean` passes its own certificate-set grep.
- [ ] Every Goal's landed signature matches the `## Lean Challenge Statements` block token for token; `lean-challenge-snapshot.sh --check 836 .` is run at Phase 11 as an advisory signal.
- [ ] `bash scripts/check-module-invariants.sh` exits 0 at every phase that touches `FormalSystem/**`, `Tests/**`, `scripts/**` or the README; `bash .claude/scripts/check-task-references.sh --quiet` on every non-`specs/**` file touched.
- [ ] No library docstring edited by this task contains record-versioning language ("previously", "no longer", "formerly", "repaired", a version label) or a task number.
- [ ] Phase 3's verdict line exists before Phase 10 is entered; Phase 10's branch matches it.
- [ ] The full gate set of Phase 11 is green: full guarded `lake build`, `BimodalTest` build, probes, invariants, `typst-sync-check.sh`, `verify-deploy.sh`.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` — the forty-seventh wired probe (Phase 1, re-anchored in Phase 2)
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` — `dFwd`, the repaired `(K4)`, the redefined `Bof` (Phase 2)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` — the certificate-free pump layer: deletion admissibility, the two type lemmas, the pigeonhole, the forward window (Phases 4-7)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — the realized-chain bridge, the budget lemmas, the regime-A assembly, and (on PASS) the depth-`0` theorem (Phases 8-10)
- `specs/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean` — the Phase 3 gate prototype
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — pins for every landed Goal
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — inventory rows and the "What the cell reads of the register" subsection
- `specs/836_ladder_type_preserving_cell_agreement_construction/summaries/01_obligation-repair-and-pump-layer-summary.md` — the summary (Phase 11)

## Rollback/Contingency

- Every phase commits only verified-green sub-steps (`task 836 phase P.O: …`), so a failed sub-step is abandoned by reverting the uncommitted edits of that sub-step alone, after `bash .claude/scripts/git-snapshot.sh 836 --no-revert` if anything in the working tree is worth keeping; never `git reset --hard` on a dirty tree without that snapshot.
- If the `(K4)` repair breaks a consumer the inventory missed, fix forward in `CounterQuotient.lean` (the repair is one conjunct and one `max`); do not revert the repair to reach green — the obligation it protects is false without it.
- If a Q1 induction overflows its cap, checkpoint with `--no-revert`, record the sub-case reached in the progress file and the handoff, close the phase `[PARTIAL]`; the next dispatch resumes at that sub-case.
- If `LadderPump.lean` approaches 1,500 lines, the type lemmas move to `LadderPumpType.lean` (same import, same grep) rather than any `longFile` baseline being raised.
- If Phase 3 records `FAIL`, Phase 10 closes `[BLOCKED]` as written and Phase 11 still runs; the task's outcome is then `blocked` with the handoff naming the open core — the honest report, never a partial on the final theorem.
- If the recorded repair decision is overturned by the user, the route is `/revise 836`; nothing in Phases 4-9 depends on the constant chosen for `(K4)`, so that layer survives any repair shape.
