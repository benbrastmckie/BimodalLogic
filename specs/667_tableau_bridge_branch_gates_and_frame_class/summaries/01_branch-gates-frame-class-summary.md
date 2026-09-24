# Implementation Summary: Task #667

- **Task**: 667 - Tableau bridge branch gates and frame class
- **Status**: [COMPLETED]
- **Started**: 2026-09-24T23:21:48Z
- **Completed**: 2026-09-24T23:45:00Z
- **Effort**: ~25 minutes wall clock (plan estimate: 7 hours)
- **Dependencies**: None
- **Artifacts**: plans/01_branch-gates-frame-class.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The tableau bridge now reports, on every `invalid` verdict, whether that verdict is backed by
`not_valid_of_hasOpen_int` / `not_validZTime_of_hasOpen_int` or is only the decision procedure's
own heuristic, and it rejects an unrecognized `frame_class` instead of silently deciding at
`.Base`. To make both testable, the bridge was first split into an importable library
(`BimodalTools/TableauBridge.lean`) plus a thin executable root. All seven plan phases are
complete; `lake build BimodalTools`, `lake build BimodalToolsTest` and `lake build tableau_bridge`
are green, and the end-to-end REPL smoke passes.

## What Changed

- `BimodalTools/TableauBridge.lean` — **new** (840 lines). Receives the whole former bridge body
  under `namespace BimodalTools.TableauBridge`, plus:
  - `structure BranchGates` with eight `Bool` fields — the four named gates (`timeOrderTotal`,
    `boxAnchored`, `regionLabel`, `temporalWitness`) and the four further hypotheses the two
    theorems actually consume (`branchOrderValid`, `saturated`, `noClosure`, `rootDenied`).
  - `BranchGates.gated` (the eight-way conjunction), `BranchGates.toJson`, `gatesJson`.
  - `gatesOfBranch` and `evalBranchGates φ fc`, the latter re-running
    `buildTableau φ (soundFuel φ) fc` — the exact call `decideAuto` makes via `decide` — because
    `DecisionResult` discards the branch and the `TimeOrdering`.
  - `decideResponseBody`, the pure body of a `tableau_decide` response, extracted from
    `handleDecide` so the response shape is `#guard`-able without an `IO` harness.
  - `"gates"` on the `.invalid` arm of both `decideResponseBody` and `handleCountermodel`.
  - `parseFrameClass : String → Except String FrameClass`, accepting `Base`, `Dense`, `ZTime`,
    `Discrete` (alias) and `RTime`, rejecting everything else.
  - The `## Protocol` docstring section, with a `frame_class` value table, an `invalid` response
    example carrying all nine `"gates"` keys, and what `"gated": true` / `false` each license.
- `BimodalTools/TableauBridgeMain.lean` — reduced 635 → 23 lines: header, docstring pointer,
  one import, `main`.
- `BimodalTools.lean` — one new import, alphabetically placed.
- `Tests/BimodalToolsTest/TableauBridgeTest.lean` — **new** (165 lines), rows A–E.
- `Tests/BimodalToolsTest.lean` — one new import.
- `BimodalTools/README.md` — new "Tableau bridge protocol" prose section, the two inventory
  descriptions filled in, regenerated inventory block, date line.
- `Tests/BimodalToolsTest/README.md` — regenerated inventory block (new test module row).

## Decisions

- **`"gated"` is the eight-way conjunction**, per the relayed prior decision. The four named gates
  keep their own JSON keys, so the deliverable is met literally, while `branchOrderValid` — which
  is strictly stronger than `timeOrderTotal`, since a cycle makes `timeOrderTotal` report `true`
  on an inconsistent order — prevents a cyclic time ordering being read as theorem-backed.
- **`saturated` is computed at `findUnexpanded`'s default `fc := .Base`**, not at the request's
  frame class, because that is how `not_valid_of_hasOpen_int` states `hSat`. Recorded in the
  field's own docstring so the choice reads as deliberate.
- **`rootDenied` bundles `hroot` and `hw₀`** (root denial on the branch, and its label's world in
  `knownWorlds`). Both are needed, so they are one field rather than a ninth key.
- **JSON keys are snake_case named after the Lean gate functions** (`time_order_total`,
  `box_anchored_check`, …), matching the response level's existing `formula_string` / `time_ms`
  convention and keeping each key traceable to its source.
- **`extractCountermodelData` was not modified.** It has no `fc` parameter
  (`BimodalTools/DatasetGenerator.lean:406` calls `buildTableau φ fuel` at the `.Base` default),
  and the task prefers a no-signature-change route where one exists. `handleCountermodel` now
  inlines a single `buildTableau φ fuel fc` re-run and derives the gates, the enriched
  countermodel and the semantic summary from it — which both fixes the frame-class defect on the
  `countermodel` path and satisfies the "one extra build, not two" requirement.

## Plan Deviations

- **Phase 3** altered: `extractCountermodelData` has no `fc` parameter, so the no-signature-change
  route was taken (inlined single re-run in `handleCountermodel`). `DatasetGenerator.lean` is
  untouched and its other call site (line 1320) is unaffected.
- **Phase 4** altered: Phases 2, 3 and 4 were applied in one edit pass and verified by one
  `lake build BimodalTools`, then committed together. The plan chains them only to stop two
  agents writing one file in one wave; a single agent editing three disjoint regions has no such
  conflict. Each phase's own verification steps were still run individually.
- **Phase 5** altered: the plan suggested `String.isInfixOf` for the substring rows. Neither
  `String.isInfixOf` nor `String.containsSubstr` exists at this toolchain and the codebase had no
  equivalent, so the test file defines a two-line private `hasSub` over `String.splitOn` and
  self-tests it with a positive and a negative row.
- **Phase 6** altered: `--emit-inventory` rewrites every registered block, and two besides this
  task's own were stale — `FormalSystem/Metalogic/README.md` and the root `README.md`, whose
  blocks count `FormalSystem/` files (`Decidability/` moved 79 → 85, matching sibling task 665's
  uncommitted `WitnessFamily/*.lean`). This task touched nothing under `FormalSystem/`, so both
  were restored to their committed content rather than re-emitted. See Follow-ups.

## Verification

- Build: **Success** — `lake build BimodalTools`, `lake build BimodalToolsTest` and
  `lake build tableau_bridge` all exit 0.
- End-to-end smoke (`.lake/build/bin/tableau_bridge`, 6-line JSONL here-doc): `ready`, `pong`,
  `invalid`+`gated: true` at `"Base"`, `invalid`+`gated: false` at `"ZTime"`, `error` with
  `unknown frame_class: 'Bogus' (…)` and the REPL alive for the next line (`"RTime"` answered
  `invalid`+`gated: true` afterwards), clean exit on `shutdown`.
- Response-byte regression: a `tableau_decide` response for `p → q` at `"Base"` was captured from
  the pre-split source and is byte-identical after the split. The valid arm carries no `"gates"`
  key; an absent `frame_class` still defaults to `Base`.
- Documented `"gates"` key set compared mechanically against `BranchGates.toJson`'s own output:
  `toJson`, module docstring and `BimodalTools/README.md` agree on all nine keys, in order.
- Test rows confirmed load-bearing: flipping one expected boolean in Row B made elaboration fail;
  the flip was reverted.
- Sorry count: **0** (repo-wide census over the resolved source roots).
- Vacuous count: **0** in this task's files. One repo-wide match,
  `FormalSystem/Examples/TemporalStructures.lean:495`, is pre-existing at the base commit
  (`332b05b01`), is not vacuous in substance (`intTimeHistory.domain t` genuinely reduces to
  `True`), and is untouched here.
- Axiom count: **14**, unchanged from the base commit.
- `scripts/check-module-invariants.sh`: **B3 PASS**. Five checks fail — C6, C23 (×2), C33 and INV
  — and every one names only `FormalSystem/Metalogic/Decidability/WitnessFamily/*.lean` or a
  `FormalSystem/` file-count block. See Follow-ups.
- Tests: **Passed** (`lake build BimodalToolsTest` green with the five new rows).
- Files verified: Yes. `git status --short` at close-out shows no uncommitted file from this task.

## Impacts

- ModelChecker (`~/Projects/ModelChecker`) can now partition the bridge's `invalid` verdicts into
  theorem-citable (`"gated": true`) and heuristic (`"gated": false`) when using it as a
  differential oracle for the bimodal theory at `ZTime`.
- The measured fact that **no** `.ZTime` open branch currently passes `regionLabelCheck` or
  `temporalWitnessCheck` is now visible in the protocol rather than latent. That is a true fact
  about today's `.ZTime` rules (`priorUZ`/`priorSZ` on the seriality-minted `T(F ⊤)`), not a
  defect this task introduced, and Row B pins it so a future repair shows up as a red test rather
  than a silent change.
- `BimodalTools.TableauBridge` is now importable, so further bridge behaviour can be pinned in
  `BimodalToolsTest` without an `IO` harness.
- A `countermodel` request at a non-`Base` frame class now extracts its enriched countermodel from
  a tableau at that class; previously it extracted from a `.Base` tableau while the verdict came
  from the requested one.

## Follow-ups

- `scripts/check-module-invariants.sh` is not clean repo-wide: C6, C23 (Uppercase_x and
  outer-shadows-inner), C33 (`FormalSystem.lean` not the generated root) and INV's two remaining
  stale blocks all name sibling task 665's in-flight `WitnessFamily/` modules. They are 665's to
  resolve (`lake exe mk_all --lib FormalSystem` for C33, a re-emit for INV once those files
  settle); this task deliberately did not touch them.
- Repairing the `.ZTime` `regionLabelCheck` / `temporalWitnessCheck` gates is a separate, larger
  change inside `FormalSystem/Metalogic/Decidability/Verified/Bridge/` and remains open — it is
  an explicit Non-Goal of this plan.
- `.claude/context/project/lean4/tools/tableau-bridge-protocol.md`, the research's context-extension
  recommendation, was a Non-Goal here and is still unwritten.

## References

- `specs/667_tableau_bridge_branch_gates_and_frame_class/plans/01_branch-gates-frame-class.md`
- `specs/667_tableau_bridge_branch_gates_and_frame_class/reports/01_branch-gates-frame-class.md`
- `specs/667_tableau_bridge_branch_gates_and_frame_class/handoffs/phase-4-handoff-20260924.md`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean` (`not_valid_of_hasOpen_int`,
  `not_validZTime_of_hasOpen_int`)
- `Tests/BimodalTest/Metalogic/Decidability/Verified/BridgeProbes.lean` (the
  `timeOrderTotal`/`branchOrderValid` separation)
