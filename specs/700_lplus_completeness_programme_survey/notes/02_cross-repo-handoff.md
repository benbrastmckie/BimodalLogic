# Cross-Repository Hand-Off: L-plus Completeness Programme

**Date**: 2026-09-29
**Task**: 700 — lplus_completeness_programme_survey
**Purpose**: Phase 3 of the implementation plan
(`plans/01_completeness-programme-sequencing.md`). One self-contained note a reader in either
repository can act on, naming every must-land result by fully-qualified declaration name so the
hand-off survives task renumbering on either side. **The paired repository
(`/home/benjamin/Projects/ModelChecker`) is not edited by this task or by any task proposed
here** — this note is a hand-off by content, not a cross-repository write.

**Soundness is not in question anywhere in this programme.** Every gap named below is a
completeness-side gap: the certificate class is empty on the affected fragment, and it is never
unsound on it. `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem`
and `...plusRefutes_of_certifies` are untouched by everything in this note and must remain so.

## Five must-land results, by fully-qualified declaration name

These are what `ModelChecker`'s `extend_bimodal_to_stability_modal` (#200) needs from this
repository, in the order they arrive. Numbering matches the survey's cross-repository section,
with the Phase 1 correction to item 1 applied.

1. **`FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt`** — task 695, **landed**.
   Corrected from the survey's original `FormalSystem.Semantics.plusValidZTime_iff_plusValidInt`
   (wrong namespace); confirmed live in `FormalSystem/PlusLanguage/PlusIntTransfer.lean:188` and
   pinned in `docs/theorem-index.md`. This is Step 0 of the L⁺ compression theorem (item 5 below)
   and is unrelated to #200's four stated needs directly, but nothing downstream is stateable
   without it.
2. **`FormalSystem.Metalogic.Decidability.SharingSkeleton.total_eq_thread`** — **landed**, and
   must be **re-proved in its `trans`-relative form** by task 696. This is #200's "histories
   characterization" need.
3. The redesigned **`FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.PlusLocalCoherentShare`**
   and **`...StabFaithful`** — task 696. These are #200's "state-sharing witness structure" and
   "redesigned box condition" needs. Both names are confirmed live today (pre-redesign) in
   `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/{Basic,Agreement,Decide}.lean`; 696's
   redesign changes their defining conditions, not their names.
4. **`FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem`** and
   **`...plusRefutes_of_certifies`** — **landed**, confirmed live in
   `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean`, and **must survive
   task 696 with their statements unchanged**. This is #200's soundness argument, and its absence
   was the reason #200 was blocked in the first place.
5. **The L⁺ compression theorem and its bound** — task 703 (`lplus_compression_and_completeness`,
   newly created this round). This is #200's "compression bound", the fourth of its four stated
   needs and the last to arrive. Task 703 is gated on both 695 (landed) and 696 (not yet
   implemented); see the serialization rule below.

## Already satisfied — need nothing further, should not wait

Three paired-repository tasks consume only
`FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime` and the four
`PlusWitnessFamily/Incompleteness.lean` declarations it names, every one of them landed and
C2-pinned:

- `apply_upstream_adequacy_chain_rows` (#216)
- `rescope_blocked_adequacy_consumers` (#217)
- `bimodal_theory_limits_example_group` (#219)

These should proceed in the paired repository's own schedule and not be held for anything in
this programme.

## Orthogonal — not part of this programme

`a3_compute_bounds_from_closure` (#198) needs a **minimal-period** result on the `Formula` side,
which `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime` does not
supply (it bounds segment lengths, not minimal periods). This is a `Formula`-side question with
no L⁺ content and is not gated by, or gating, anything in this programme.

## The O3 bound warning, carried forward explicitly

The survey's O3 obligation (now assigned to task 703's research round): `(C5) StabFaithful`'s
truth-lemma case demands witnesses that share the state at a **specific** time, unlike `box`'s
witnesses. The `Formula` side's lasso-count bound (`|closure| + 1`) **may not survive** for L⁺ —
the honest estimate in the survey is that the L⁺ bound could instead be `|closure| × window`. **The
paired repository's search-bound expectations for #200's fourth need must not be set from the
`Formula` side's `|closure| + 1` figure** until task 703's research round settles O3. Setting an
expectation from the wrong side's bound now would need correcting later, after code in the paired
repository may already depend on it.

## Two hand-offs that are notes, not edits, and why

Neither of the following is applied by this task. Both are recorded here as obligations for a
future round of the named task, per this task's Non-Goals (no editing another task's artifacts
or `file_scope`).

**(a) The F7 nine-file table belongs in task 696's plan, not in task 698.** Task 698's landed
report (`specs/698_file_scope_declaration_hygiene/reports/01_file-scope-hygiene-audit.md`, Item
3) explicitly declines to widen any task's `file_scope` by inference, including 696's — it
checks every task mentioning `check-module-invariants.sh`/`theorem-index` and finds none, 700
included, describes editing the script's content directly enough to justify widening a
`file_scope` from outside that task. The mechanism that makes the F7 nine-file table's inclusion
automatic already exists: `scripts/plan-file-scope-harvest.sh` harvests `file_scope` from a
plan's own `Files to modify` lines at plan postflight. **The obligation is therefore on task
696's own plan phase**: when 696's plan is written, its `Files to modify` lines should list the
F7 nine files (696's round-2 report's own 23-file real-footprint accounting, beyond the 14
already declared in `file_scope`) so the harvester picks them up. This task does not edit 696's
`file_scope` itself.

**(b) The general-consequence (`Γ ≠ []`) extension point belongs in task 695's plan, and 695 has
not written one yet.** `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean:66`
identifies the general-premise form as one of exactly three `Γ = []`-specific residue items; task
695's landed report's own Recommendations section (5 items) does not mention it. Confirmed by
direct read of `specs/695_plus_carrier_normalization_int_transfer/reports/01_plus-carrier-normalization-transfer.md`
lines 226–247 in Phase 1 of this task. **The obligation is a single sentence in a future revision
of task 695's plan** naming the `Γ ≠ []` analogue as a named extension point — not a task, per
this programme's Decision 4 (the general-consequence obligation is parallel to the critical path;
`Compression/README.md:114-129` and `Assembly.lean:55-73` already record it accurately, and the
paired repository's #216/#217 already carry it as an open upstream obligation in their own
scope).

## Standing operational note: serialization

**Never dispatch two of {695, 696, 703, 704} implementing in the same cycle.**
`scripts/check-module-invariants.sh` (specifically the C2 `AXIOM_BASELINE` heredoc) and
`docs/theorem-index.md` are shared, block-rewritten artifacts written by 695, 696 and 703 (704
writes only the invariants script). Two of these implementing concurrently produces a gate that
is red for both and diagnosable for neither. Task 695 has already landed, so the live
constraint going forward is: 696 alone, then 703 alone, then 704 alone (704's own dependency on
703 already enforces this for the 703→704 pair; the 696→703 ordering must be enforced
operationally, since 703's `dependencies: [695, 696]` gates *creation-time* topological order,
not concurrent-dispatch scheduling).

## Confirmation summary table (Component 7, non-interactive creation)

Per the multi-task-creation standard's Component 7, this table stands in for the interactive
confirmation a background `/orchestrate` dispatch cannot surface. The task description
pre-authorizes creation ("Spawn at most what the survey concludes is needed, in the order it
concludes"), so creation proceeded non-interactively; this table is the audit trail.

| # | Title | Task type | Dependencies | Notes |
|---|-------|-----------|---------------|-------|
| 703 | `lplus_compression_and_completeness` | `lean4` | `[695, 696]` | The target theorem; research-first (O1, O2, O3 named; O4 carried from 699 Part B as unanswered, not resolved) |
| 704 | `certificate_non_vacuity_and_shape_gates` | `general` | `[696, 703]` | Both structural preventions, one task; dependency on 703 is `(auto: file overlap)` — both write `scripts/check-module-invariants.sh`'s C2 `AXIOM_BASELINE` block, per the multi-task-creation standard's Component 4a |

No third task was created. The general-consequence obligation (item 4 of the survey scope)
remains parallel and unowned by design (Decision 4); the substrate design (item 1), carrier
normalization (item 2), and invariance audit (item 3) remain owned by tasks 696, 695 and 699
respectively, with no `file_scope` or entry of any of those three tasks modified by this task.
