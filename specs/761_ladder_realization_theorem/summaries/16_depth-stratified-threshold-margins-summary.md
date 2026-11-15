# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem (run-layer phase 2's soundness half)
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-14T20:21:19Z
- **Completed**: 2026-11-14T20:40:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: 760, 775, 805, 806, 819, 820 (all DISCHARGED); 836 consumed as artifact input, not as a `dependencies[]` edge
- **Artifacts**: plans/15_depth-stratified-threshold-margins.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Executed Phase 11.18 of plan v15 — the one enterable phase, and the phase that spends route S-2's
price. The `(K2)` parameter condition is strengthened with one depth-stratified margin conjunct
coupling `Tc` to the modulus `P + 1` and to the `⊡`-nesting-depth sup of the closure; `Tcof` is
redefined as a `max` through `Pof`; the discharge lemma `paramsOk_params` is re-proved green at
the raised `Tcof` with its filed signature unchanged; the inflation lemma is restated with its
room premise explicit and given an unconditional sibling; and the two room lemmas the spaced
pigeonhole and the depth induction consume are landed and compiled. No depth induction, no cell
agreement and no pump was attempted — those are Phases 11.19-11.21 and 11.6.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` — `paramsOkK2` gains a
  `(P : ℕ)` binder and the pinned third conjunct
  `Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (P + 1) * ((plusSubformulaClosure φ).sup stabDepth + 1) ≤ Tc`;
  `ParamsOk` passes `P`; `Tcof` gains one outer `max` arm read at `Pof`; `paramsOk_params`
  RE-PROVED at the new `Tcof`; `paramsOk_inflate` restated with an explicit `hroom` premise; NEW
  `paramsOk_inflate_raise`, `budget_mul_spacing_le_Tc`, `margin_room_at_depth`; `def stabDepth`
  relocated in from `LadderAgree.lean`; the module docstring's `(K2)` bullet and the
  "`(K2)` … never mention `P`" sentence corrected. 1,115 → 1,305 lines.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` — `def stabDepth` removed
  (relocated down; the pinned-letter layer and the three depth facts stay) behind a pointer
  comment. 3,366 → 3,362 lines.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — the inflation-lemma sentence
  in `hasForwardSlack_amount_le`'s docstring brought current. 2,984 → 2,986 lines.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — three new axiom pins, a new margin
  section with its prose record, three corrected passages, `longFile` baseline raised 3,000 →
  3,100. 2,992 → 3,057 lines.
- `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` — the
  `paramsOkK2` application brought to the new arity; the frozen `paramsOkK4Pre` NOT touched.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  `README.md` — regenerated inventory blocks, plus one corrected locator sentence for the depth
  measure.
- `typst/generated/status.typ` — regenerated line counts.

## Decisions

- **`stabDepth` relocated into `CounterQuotient.lean`.** The pinned conjunct reads
  `(plusSubformulaClosure φ).sup stabDepth`, but `stabDepth` was declared in `LadderAgree.lean`,
  which IMPORTS `CounterQuotient.lean` — the symbol was not in scope at the site the plan pins the
  conjunct at. The measure is a pure recursion on `PlusFormula` with no dependency on the
  transport layer, so the `def` moved down; namespace unchanged, so no axiom pin moved. This is
  the only file touched beyond the phase's listed set.
- **The conjunct was added THIRD, not second.** Every `hp.1.*`, `hp.2.1.1` and `hp.2.2.*`
  projection across the RaySummary tree therefore still resolves, and nothing in the tree projects
  `(K2)`'s second conjunct, so the strengthening cost zero downstream repairs.
- **`margin_room_at_depth`'s base `Tc_0` is `0`, and that is forced rather than chosen.** The
  conjunct supplies `b · (P + 1) · (D + 1)` and no more, so the `D + 1` reserved blocks consume
  all of it. The lemma is stated for every `d : ℕ`, with no `d ≤ D` side condition, because
  `D − d` is truncated subtraction: the stated form implies the plan's and carries no redundant
  hypothesis.
- **`paramsOk_inflate_raise` is existential in the raised `(Tc', Tn')` pair** rather than
  committing to a formula, which keeps it usable at any margin a caller needs.

## Plan Deviations

- **Phase 11.18, first checklist item** altered: `stabDepth` relocated from `LadderAgree.lean`
  into `CounterQuotient.lean` as an import-direction prerequisite the plan did not anticipate, and
  `LadderAgree.lean` edited although it is outside the phase's listed file set. The pinned
  conjunct itself landed token-for-token; no decomposition step was skipped, no intermediate lemma
  was inlined, and no Challenge signature changed. Annotated inline on the plan's checklist item
  and recorded in `issues.jsonl` as a `plan omission`.
- The `KTypeSummaryAxiomTest.lean` `longFile` baseline was RAISED 3,000 → 3,100. The phase text
  predicted eight lines of headroom and named the baseline-raise remedy as the fallback; three
  pins plus prose needed 65 lines, so the remedy was taken.

## Verification

- Build: Success — full `lake build` exit 0, 0 errors, 0 warnings; `lake build BimodalTest` exit 0,
  0 errors, 0 warnings, every `#guard_msgs` axiom pin green.
- Sorry count: 0
- Vacuous count: 0 (module-scoped over `CounterQuotient.lean`; repository-wide unchanged at its
  1-hit baseline)
- Axiom count: 14, identical to the count at `HEAD` — not increased
- Tests: Passed
- Files verified: Yes
- `#print axioms` on `paramsOk_params`, `paramsOk_inflate`, `paramsOk_inflate_raise`,
  `budget_mul_spacing_le_Tc`, `margin_room_at_depth`: each exactly
  `[propext, Classical.choice, Quot.sound]`; `stabDepth` depends on no axioms. No `sorryAx`, no
  custom axiom, no `native_decide`.
- `paramsOk_params`'s signature is unchanged token-for-token against the plan's
  `## Lean Challenge Statements` block and gained no binder, so the parameter hypothesis remains
  dischargeable and no statement carrying `ParamsOk` became vacuous.
- The room lemma's instantiation was WRITTEN OUT and COMPILED (`lake env lean`, exit 0): a
  `spacing_at_modulus` witness discharges `exists_typeBlock_of_spacing`'s single `hroom`
  hypothesis at `s := P + 1` from `budget_mul_spacing_le_Tc` and one `le_trans`. The full term is
  recorded in the plan's Phase 11.18 Completion Record.
- Gates: `check-evidence-probes.sh` exit 0 (`PASS all 62 wired probe(s) compile`, with
  `ladder-cell-obligation-refutation` PASS); `check-module-invariants.sh` exit 0 with the single
  pre-existing `C16` `TODO` finding unchanged (230 findings across 16 of 18 non-`FormalSystem`
  roots) and the C34 family green; `typst-sync-check.sh` exit 0 (all 4 checks);
  `readme-lint.sh` exit 0; `check-task-references.sh --quiet` exit 0.
- **Carried-figure check (dispatch Premise Re-Validation).** All three flagged Description lines
  were checked against live state. Line 13 (`WHY HIT-LEVEL`): `w-soundness-shape-refuted.lean`
  exists and carries both `Probe747.modelOf_incomplete` and
  `Probe747.stab_iff_of_presented_nowUnique`; `no_fwd`, `no_bwd_of_idle` and
  `ladderFrameAdm_isRegular` are live in `LadderModel.lean` and `Rlad_slice_infinite` is named in
  `RunLayer.lean` — UNCHANGED, confirmed accurate. Line 17 (`CONTINGENCY`): the policy was upheld
  — no `sorry`, axiom, vacuous definition, trace-level hypothesis or finite-fibre/finite-width
  assumption was introduced. Line 23 (`NOT COSTABLE`): `Realize.lean` measures exactly 1,004
  lines — UNCHANGED, confirmed accurate. One figure IN THE PHASE'S OWN verification text was
  found stale and is corrected in the completion record: the cited `57 WIRED / 1 WIRED_REPO`
  evidence-gate figures do not exist in the live gate's output, which reports `all 62 wired
  probe(s) compile` with 1 `SKIP`.

## Impacts

- `ParamsOk` is strictly stronger, so every statement in `LadderChain.lean`, `LadderCell.lean`,
  `LadderWindow.lean`, `LadderIdle.lean`, `LadderPin.lean`, `LadderPump.lean`, `LadderAgree.lean`
  and `LadderRealize.lean` that carries it now has the margin available for free, and the hypothesis
  is still dischargeable at the periodicity fixpoint's own parameters.
- Phase 11.20 can instantiate the spaced type pigeonhole at `s := P + 1` — the spacing at which a
  pumped block's length is a multiple of the modulus, hence at which `kappa`'s residue coordinate
  survives a pump — discharging its single room hypothesis from `budget_mul_spacing_le_Tc` alone.
- `paramsOk_inflate`'s unconditional form is gone, replaced by a room-premised form plus
  `paramsOk_inflate_raise`. Nothing in the tree applies either lemma, so no proof broke; the two
  prose passages that described the unconditional form as landed are brought current.

## Follow-ups

- Phase 11.19 (the two unexposed splice clauses) is the other half of the recorded S-2
  obligation's first gate, independent of this phase and enterable now. Phases 11.20, 11.21 and
  then 11.6 follow, in that order.
- `margin_room_at_depth` gives a trivial threshold at the DEEPEST depth level (`Tc_D = 0`). If
  Phase 11.20's invariant needs a non-trivial threshold there, the only route is raising `Tc`
  further, which is a new `(K2)` ruling and outside this phase's scoped lift.

## References

- `specs/761_ladder_realization_theorem/plans/15_depth-stratified-threshold-margins.md` — the
  plan, with the Phase 11.18 Completion Record
- `specs/761_ladder_realization_theorem/reports/15_stab-bit-copy-pair-decision.md` — the
  route-deciding research round whose findings F1-F5 this phase executes
- `specs/761_ladder_realization_theorem/handoffs/phase-11.18-handoff-20261114-203711.md`
- `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` — the wired
  probe whose `paramsOkK2` application was brought to the new arity
