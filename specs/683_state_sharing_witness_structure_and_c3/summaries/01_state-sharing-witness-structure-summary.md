# Implementation Summary: Task #683

- **Task**: 683 - State-sharing witness structure and C3
- **Status**: [IN PROGRESS]
- **Started**: 2026-09-27
- **Completed**: (not complete — Phases 6-14 remain)
- **Effort**: ~1 agent dispatch (plan budget: 25 hours across 14 phases)
- **Dependencies**: 682
- **Artifacts**: plans/01_state-sharing-witness-structure.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Added a state-sharing (branching) witness device alongside the shipped deterministic bi-lasso
device, as a new `Sharing/` subdirectory under `WitnessFamily/`. Phases 1-5 of the plan are
complete and green: the `SharingWitnessFamily` structure with its periodic `share` decoding, the
`Thread`/`Step`/`ReachN` layer, the branching `FrameOver intOrder` with all four `def:frame`
constraints and the ℤ-time instances, and `total_eq_thread` — the histories characterization
that replaces `ShiftSet.total_eq_orbit` for a non-functional task relation. Phase 6 is partial:
two of its three conditions are landed, and the third, `StabFaithful`, is blocked on a syntax
fact the plan did not anticipate.

## What Changed

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Basic.lean` — new.
  `SharingWitnessFamily` (extends `WitnessFamily`, adding three periodic segments of
  **representative maps**), `rep`, `share` as the kernel of `rep`, the three equivalence laws,
  the two periodicities instantiated from `Periodic.unrollOf_sub_back_length` /
  `_add_fwd_length`, `rep_idem'`, `share_rep`, `decidableShare`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Thread.lean` — new. `Thread`
  (bi-infinite index choice with the tight step law), `Thread.const`, `Thread.ext`, the
  class-level one-step relation `Step` with its two congruences, `n`-step reachability `ReachN`
  with `reachN_congr_left/right`, `reachN_const`, `reachN_one`, **`reachN_add`** (concatenation
  and splitting), `decidableReachN`, and `Thread.reachN`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Frame.lean` — new. `shareSetoid`,
  `WorldState`, `cls`, `time`, the duration-free connectivity predicate `Conn` with `conn_symm`
  and its two congruences, the two-sided relation `RelZ`, `relZ_reflection`, **`relZ_comp`**,
  **`relZ_serial`**, `relZ_zero`, `relZ_limit`, `relZ_fib_finite`, `relZ_saturation`, the frame
  itself, `frame_taskRel`, `instIsRegular`, `instIsRegularTask`, `frame_isZTime`,
  `frame_sat_ztime`, `frame_sat_base`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Histories.lean` — new.
  `conn_thread`, `hist`, `thread_is_history`, and **`total_eq_thread`**.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean` — new. (C0)
  `AtomCoherent`, (C1') `LocalCoherentShare`, `localCoherentLab_of_share`, `untl_self_of_share`,
  `snce_self_of_share`, and the module-header record that (C3) `BoxFaithful` and (C4) `Target`
  are reused verbatim.
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — five import lines only.
- `specs/state.json` — `file_scope` extended (append-only) to cover the new modules.

The deterministic path is byte-identical: `git diff HEAD` over `Semantics/ShiftSet.lean` and
`WitnessFamily/{Basic,Predicates,Std,Agreement,Decide}.lean` is empty.

## Decisions

- **`share` is the kernel of a representative map, not a relation field.** Three segments of
  `Fin L → Fin L` decoded by `Periodic.unrollOf`, with `share u i j := rep u i = rep u j`. The
  equivalence laws are then `rfl`/`Eq.symm`/`Eq.trans` and the structure carries no
  `share_equiv` obligation; the decoding's out-of-range default is `id`, so outside the encoded
  segments `share` degenerates to equality. The `Inhabited` witness is a plain `abbrev`
  (`repIdInhabited`), never an instance, so it cannot compete with `Pi.instInhabited`; every use
  site passes it with `@`, and one consequence is that `rw [Periodic.unrollOf]` is unusable here
  (it asks synthesis for the instance) — `unrollOf_mem_or_default` takes the instance explicitly
  for exactly that reason.
- **A duration-free connectivity predicate `Conn`, and one two-sided relation `RelZ`.** The
  frame's `PosRel` is `RelZ` restricted to the positive cone, and all four constraints are
  discharged against `RelZ` via `TaskFrame.*_reflect_of_reflective`, exactly as
  `ShiftSet.fibre_isRegular` does. Because `Conn` mentions no duration, the reflection law is
  `conn_symm` plus an `omega`, rather than a sign case split inside every constraint proof.
- **Three relations, not one.** `Thread.step` is the *tight* law `share (u+1) (idx u) (idx (u+1))`;
  the frame's one-step relation `Step u i j = ∃ i', share u i i' ∧ share (u+1) i' j` is wider.
  The gap is exactly the branching, and it costs nothing in `total_eq_thread` because a
  history's index at `u` is read off the step witness.
- **The plan's Limit/Saturation reading is confirmed.** `TaskFrame.limit_of_succOrder` needs only
  the zero-duration law, and `TaskFrame.saturation_of_fib_finite` is the infinite-carrier /
  finite-fibres case this construction is. Determinism is used nowhere in the frame discharges.

## Plan Deviations

- **Phase 2** `Thread.shift` skipped: a thread cannot be time-shifted. `share` is decoded from
  periodic segments indexed by *absolute* time, so `share u` and `share (u+d)` are different
  relations and `fun u => θ.idx (u + d)` fails the step field. The offset lives in the history's
  parametrization instead — `total_eq_thread` carries an explicit `s : ℤ`.
- **Phase 2** `ThreadSeg` altered: delivered as the inductive `Step`/`ReachN` relations with
  `reachN_add` for concatenation and splitting, rather than as a function-on-an-interval
  structure. The relational form additionally yields the four share-congruences the quotient
  lift needs and a `Decidable` instance the Phase 7/8 window work will consume.
- **Phase 3** `PosRel` altered: factored through `Conn` and `RelZ` (see Decisions).
- **Phase 4** `frame_fib_finite` renamed `relZ_fib_finite`, since it is stated at the two-sided
  relation rather than at the frame's reflected task relation.
- **Phase 5** the two-directional recursion was not needed and was not written. The index at each
  time is read off the step witness — an independent choice per time (`choose`) — and the step
  law follows from transitivity of `share` at the later time. The plan budgeted a recursion
  because it assumed the index had to be chosen before the step was known.
- **Phase 6** `StabFaithful` blocked; see Follow-ups and the BLOCKER entry on the phase.

## Verification

- Build: Success. Full `lake build` through the guard, detached: 2746 jobs, exit 0, zero
  `error:` lines, `.olean`s regenerated for every touched module.
- Sorry count: 0 (over the resolved source roots; `Sharing/` reports 0 on its own).
- Vacuous count: 0 introduced. The single repo-wide grep hit
  (`FormalSystem/Examples/TemporalStructures.lean:495`) is pre-existing, unrelated and unchanged.
- Axiom count: 14, unchanged from the pre-task baseline (`git grep` at `HEAD~5`).
- `#print axioms` on `share`, `rep_idem'`, `reachN_add`, `frame`, `instIsRegular`,
  `frame_sat_ztime`, `total_eq_thread`, `thread_is_history`, `localCoherentLab_of_share`: each
  reports exactly `[propext, Classical.choice, Quot.sound]`. No `sorryAx`.
- `example (W : WitnessFamily Γ Del) (t : ℤ) : Decidable (W.Certifies t) := inferInstance` still
  elaborates: the deterministic decision procedure is intact.
- `bash .claude/scripts/check-task-references.sh`: PASS, 0 unexempted occurrences.
- Plan-compliance spot-check against the plan's sixteen pinned Goals: 8 present
  (`SharingWitnessFamily`, `share`, `Thread`, `frame`, `instIsRegular`, `total_eq_thread`,
  `AtomCoherent`, `LocalCoherentShare`), 8 absent — they belong to Phases 7-14, which were not
  reached.
- Tests: N/A (no test-suite change; the branching device has no `Examples.lean` entry yet).
- Files verified: Yes.

## Impacts

- The repository now has a regular ℤ-time frame whose task relation **branches**, built without
  touching `ShiftSet`. That is the object the stability modal needs: on it,
  `PlusLanguage/PlusDeterminism.lean`'s `states_eq_of_deterministic` no longer collapses `⊡` to
  the identity, which is the structural reason the deterministic device is blind to `⊡` by
  construction and cannot be extended by adding a truth clause.
- `total_eq_thread` is available as the replacement for `ShiftSet.total_eq_orbit` in any
  development that needs a histories characterization without determinism.
- Nothing downstream changed: the shipped deterministic path, its `Decidable` instances, its
  agreement theorem and the JSON export contract are all untouched.

## Follow-ups

- **A user decision is required on (C5).** `StabFaithful` as pinned is not stateable at this
  datatype: `WitnessFamily` is indexed by `Context = List Formula`, and
  `FormalSystem.Syntax.Formula` has six constructors with no `⊡`; the stability modal is
  `PlusFormula.stab`, a constructor of the separate inductive
  `FormalSystem.PlusLanguage.PlusFormula`. Either (a) add an L⁺-indexed certificate datatype
  (re-indexing `LabelledLasso`, `closureOf`, `WitnessFamily`, its four conditions and its
  agreement theorem over `PlusFormula`, which also re-opens the JSON export contract), or
  (b) drop (C5), `StabFaithful` and the `⊡` case of the truth lemma from this task and keep the
  branching frame as the deliverable that unblocks them. The full record is the BLOCKER entry on
  Phase 6 of the plan.
- Phases 7-14 remain. Phases 7, 8 and 9 do not depend on (C5) and can proceed as written against
  (C0)/(C1')/(C2'); Phases 10, 11 and 12 each carry a `StabFaithful` deliverable the blocker
  gates. See `handoffs/phase-6-handoff-20260927.md` for the resume point.
- `Sharing/README.md`, the `WitnessFamily/README.md` submodule map and the `BiLasso/README.md`
  scoping of the all-histories claim are Phase 14 items and are not yet written.

## References

- `specs/683_state_sharing_witness_structure_and_c3/plans/01_state-sharing-witness-structure.md`
- `specs/683_state_sharing_witness_structure_and_c3/reports/01_state-sharing-witness-structure.md`
- `specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-6-handoff-20260927.md`
