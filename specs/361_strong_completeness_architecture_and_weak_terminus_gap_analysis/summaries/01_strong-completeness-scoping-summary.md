# Implementation Summary: strong-completeness architecture and weak-terminus gap analysis

- **Task**: 361 - strong_completeness_architecture_and_weak_terminus_gap_analysis
- **Status**: [COMPLETED]
- **Started**: 2026-07-28T00:00:00Z
- **Completed**: 2026-07-28T23:30:00Z
- **Effort**: 6.5 hours (6 phases)
- **Dependencies**: None
- **Artifacts**: plans/01_strong-completeness-scoping.md, design/01_set-consequence-layer.md, design/02_compactness-route.md, design/03_weak-terminus-status.md, design/04_subtask-decomposition.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

An ANALYSIS / SCOPING task that closed no proof obligation and wrote no Lean code into the tree —
every proposed Lean definition lives inside a `specs/` design document as a fenced code block. It
delivered four design documents, spawned five gated sub-tasks, and corrected materially stale
weak-terminus claims in `specs/ROADMAP.md` and in two existing task descriptions.

**No file under `FormalSystem/` or `Tests/` was created, edited, or deleted, and no build command
(`lake build`, `lake clean`, `lake exe`, `lean_build`) was run at any point.** A separate session
held the advisory build lock `.lake/.task-418-build.lock` throughout; the standing constraint was
honoured without exception. Lean tooling was limited to read-only `lean-lsp` queries against
existing oleans, plus `Read`/`Grep`/`Glob`.

## What Changed

- **Four design documents** under `design/`: the set-based consequence layer spec (`SetDerivable`,
  four per-class `SetSemanticConsequence*`, basic lemmas, compactness → strong completeness via the
  already-proved generic `derivable_foldr_imp_iff`); the compactness route (Q1/Q2 verdicts, shift-set
  representation theorem, four-step ultraproduct route, four named risks, GATING RULE, Discrete
  non-compactness witness); the verified weak-terminus status; and the sub-task decomposition.
- **Five new tasks created** in `specs/state.json`, all `task_type: lean4`,
  `topic: strong_completeness`, `status: not_started`:

  | # | Symbolic | Title | Depends on | `file_scope` |
  |---|---|---|---|---|
  | **421** | N1 (`B0`+`B1`) | Correct Transfer.lean route guidance and probe the non-Archimedean discrete carrier | `[361]` | `Transfer.lean`, `BXCanonical/DiscreteCarrierProbe.lean` |
  | **422** | N2 (`B2`+`B3`) | Build the discrete chronicle over the non-Archimedean block carrier with restricted coherence | `[421]` | `BXCanonical/Chronicle/` |
  | **423** | N3 (`S0`) | Land the set-based consequence layer | `[361]` | `Metalogic/SetConsequence.lean`, `Metalogic/StrongCompleteness.lean` |
  | **424** | N4 (`S1`) | Prove the shift-set representation theorem (compactness feasibility gate) | `[361]` | `Semantics/ShiftSet.lean` |
  | **425** | N5 (`D1`) | Machine-check the Discrete non-compactness witness | `[361, 423]` | `Metalogic/DiscreteNonCompactness.lean` |

- **`specs/ROADMAP.md`** completeness table: the `Base` and `Dense` rows corrected, the
  `Genuine strong (Set Formula)` cells repointed from "compactness research, task 361" to the
  feasibility gate (task 424), and a new bullet stating the gating rule. `Discrete` and `Dedekind`
  rows left untouched — both were already accurate.
- **Task 169's description** rewritten (one remaining sorry, not three; routes scoped) and its
  `dependencies` extended to `[361, 422]`.
- **Task 170's description** rewritten to record its verified-green status; its `status` was
  deliberately left `not_started`.
- **`specs/TODO.md`** regenerated from `state.json` via `generate-todo.sh` only; never hand-edited.

## Decisions

- **Dense weak terminus is SUBSTANTIVELY CLOSED, not open.** `completeness_dense`
  (`BXCanonical/Completeness.lean:255`) is machine-verified sorry-free — `#print axioms` reports
  exactly `propext, Classical.choice, Quot.sound`. **No implementation agent should be dispatched at
  task 170**; the only remaining action is an independent clean-build re-verification by a
  build-lock holder, then the `[COMPLETED]` transition. That transition was deliberately left undone
  here because this task could not take the build lock and so could not produce the evidence it
  should rest on.
- **Base has exactly ONE reachable sorry, not three**: `countermodel_discrete` at
  `WeakCanonical/Transfer.lean:1242`.
- **Base route settled**: route (i) (Base-MCS → Discrete-MCS transfer) is **REFUTED** by an explicit
  `ℤ ×ₗ ℤ` lexicographic witness that validates `□U(⊤,⊥)` while falsifying `Axiom.z1`; route (iii)
  (reuse the ℚ dense chronicle) is **BLOCKED** at `box_dense_gives_density`; route (ii) (direct
  construction over the non-Archimedean carrier `ℚ ×ₗ ℤ`) is **RECOMMENDED**.
- **The chronicle machinery does NOT extend to model existence** (Q2 = NO): its truth lemma is tied
  to finite root closures, and unrestricted temporal coherence needs bounded F-nesting depth, which
  infinite premise sets destroy. No chronicle-based model-existence work is planned or spawned.
- **`S2`, `S3`, `S4`, `S5-Dense`, `S5-Base` deliberately NOT created.** They are authorized only
  after task 424's gate returns positive. Gate-passed evidence standard, and nothing weaker: a
  sorry-free statement of **both** directions with `#print axioms` clean on **each**. A `sorry` body
  does not pass; the forward direction alone does not pass; prose does not pass. If either direction
  is refuted, the route is **cancelled, not retried**.
- **`file_scope` overlaps are intentional where they exist**: 422 overlaps tasks 169/170 on
  `BXCanonical/Chronicle/` (422 produces what 169 consumes — serializing is correct); 423 overlaps
  task 362 on `StrongCompleteness.lean` (prevents a same-file merge conflict).

## Impacts

- **Dense is the natural first strong-completeness target.** `S5-Dense` depends on `S4` and `S0`
  only — it does *not* wait on the Base weak terminus, since the Dense engine is dischargeable
  today. This is the most schedule-relevant fact in the decomposition.
- Task 169's scope narrowed from three obligations to one, behind a two-task chain (421 → 422).
- Task 170 should not receive an implementation dispatch; misrouting one would spend a full
  implementation budget hunting sorries that do not exist.
- The whole ultraproduct branch is now budget-gated behind one cheap task rather than pre-committed.

## Follow-ups

- **A build-lock holder** runs a clean-build `#print axioms completeness_dense`; if it reports
  exactly `propext, Classical.choice, Quot.sound`, transitions task 170 to `[COMPLETED]` with that
  axiom set recorded verbatim.
- **Task 424** must be scheduled before any of `S2`-`S5`; its summary must state explicitly whether
  the gate PASSED or FAILED.
- **Task 422 carries an unresolved principal risk**: it is not verified that the chronicle's block
  order can always be densified without disturbing MCS-chain coherence. If it fails, escalate as
  `[BLOCKED]` naming the failing coherence obligation — never a `sorry` or vacuous placeholder.
- **Out of scope, deliberately**: an analogous Dedekind non-compactness witness belongs to task 408.

### Divergences found and recorded

| Source claim | Observed | Impact |
|---|---|---|
| Report: "exactly three live sorries outside `Boneyard/`" | **two** — the report's third row is itself a `Boneyard/` sub-tree | None on any verdict; sorries reachable from `completeness` unchanged at one |
| Report: no `IsOrderedAddMonoid (α ×ₗ β)` instance in Mathlib | **The instance exists** (`Mathlib/Algebra/Order/Monoid/Prod.lean:52-59`, `@[to_additive]`) | Retires a named risk; task 421's probe becomes confirmation, not supply |
| Report: `completeness_discrete` axiom set "per in-file audit" | machine-verified by `lean_verify` | Strengthens the report |
| Plan: task 408 scoped to `ShuffleReal.lean` | task 408's `file_scope` is **`[]`** | Non-overlap claim holds, but the admission gate is not what enforces it |
| Manifest: `next_project_number` = 420 | **421** at allocation time (a concurrent session created 420) | Allocation started at 421; caught by the mandated re-read |

### Verification performed

- `jq empty specs/state.json` clean after every mutation.
- Tasks 418 and 408 byte-compared (`jq -S`) before and after the batch — **unchanged**.
- Full pre-existing `project_number` set compared before/after — delta is **exactly** the five new
  tasks; no task record lost.
- Every integer in every new task's `dependencies` resolves to a real `project_number`.
- `next_project_number` advanced by exactly five (421 → 426).
- `git status --short` shows **no** file under `FormalSystem/` or `Tests/`.

## References

- `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/plans/01_strong-completeness-scoping.md`
- `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/reports/01_strong-completeness-architecture-gap-analysis.md`
- `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/01_set-consequence-layer.md`
- `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md`
- `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md`
- `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/04_subtask-decomposition.md`
- `specs/ROADMAP.md` (completeness table, `Base` and `Dense` rows)
