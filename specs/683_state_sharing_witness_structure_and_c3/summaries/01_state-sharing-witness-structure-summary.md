# Implementation Summary: Task #683

- **Task**: 683 - State-sharing witness structure and C3
- **Status**: [IN PROGRESS]
- **Started**: 2026-09-27
- **Completed**: (not complete — Phases 9-14 remain)
- **Effort**: ~2 agent dispatches (plan budget: 23.5 hours across 14 phases)
- **Dependencies**: 682
- **Artifacts**: plans/01_state-sharing-witness-structure.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Added a state-sharing (branching) witness device alongside the shipped deterministic bi-lasso
device, as a new `Sharing/` subdirectory under `WitnessFamily/`. Phases 1-5 of the plan are
complete and green: the `SharingWitnessFamily` structure with its periodic `share` decoding, the
`Thread`/`Step`/`ReachN` layer, the branching `FrameOver intOrder` with all four `def:frame`
constraints and the ℤ-time instances, and `total_eq_thread` — the histories characterization
that replaces `ShiftSet.total_eq_orbit` for a non-functional task relation.

Phase 6 closed with exclusions: (C0) `AtomCoherent` and (C1') `LocalCoherentShare` landed, and
(C5) `StabFaithful` was dropped from this task's scope by user decision — it is not stateable
over a `Formula`-indexed certificate, since the stability modal lives on the separate inductive
`PlusFormula`. Phases 7 and 8 then landed the decision machinery: a family-wide combined window
that makes (C0) and (C1') decidable, and the finite position graph with the `A[g U e]` least
fixpoint that is the computational core of (C2'). Phases 9-14 remain.

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
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Decide.lean` — new (Phase 7). The
  family-wide combined periods `perBack`/`perFwd`/`perMid` with their positivity, divisibility
  and bound lemmas; `emod_of_dvd`; the two generic `Periodic.unrollOf_congr_back`/`_fwd`
  congruences and their `rep_congr_back`/`_fwd` instantiations; **`data_congr_back`** and
  **`data_congr_fwd`**, which say the representative map and *every lasso's* label agree at two
  congruent times; the window `cohWindowLo`/`cohWindowHi` and **`exists_window_repr`**; the
  closure-gated forms `atomClauseAt`/`AtomCoherentAt` and `shareClauseAt`/`CoherentShareAt`
  with their `_iff_at` equivalences and congruences; **`atomCoherent_iff_window`** and
  **`localCoherentShare_iff_window`**; the two instances **`decidableAtomCoherent`** and
  **`decidableLocalCoherentShare`**; and an `Inherited` section of nine
  `example … := inferInstance` lines.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean` — new (Phase 8). The
  generic `AUFix` layer (`step`, `step_mono`, `iter`, `iter_stab`, **`exists_stab`**, `lfp`,
  **`lfp_fixed`**, **`lfp_least`**, `mem_lfp_iff`, **`lfp_induction`**), the position graph
  (`Pos`, `winTimes`, `verts`, `nextTime`/`prevTime` with the four data-preservation lemmas
  `rep_nextTime`/`L_nextTime`/`rep_prevTime`/`L_prevTime`, `succF`/`predF` with their
  membership, subset and non-emptiness lemmas), the two fixpoints **`untlFix`** and
  **`snceFix`** with `mem_untlFix_iff`/`mem_snceFix_iff` and
  `untlFix_induction`/`snceFix_induction`, and a `SmokeTest` section whose three `#guard`s
  check the computed answers on a one-lasso family.
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — seven import lines only.
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
- **The combined window is family-wide, not one lasso's window widened.** Both sharing
  conditions compare *two different lassos* at the same time, so `Decide.lean`'s per-lasso
  decomposition (`localCoherentLab_iff_lassos`) is unavailable and the different lassos'
  periods must be reconciled with each other as well as with the `share` period. `perBack` and
  `perFwd` are therefore products over the whole family and `perMid` a sum — common multiples
  and an upper bound, not least ones, because nothing needs minimality and `List.dvd_prod`
  supplies the divisibility facts off the shelf.
- **(C0) is decided through a closure gate, not as written.** `AtomCoherent` quantifies over
  `∀ p : Atom` and `Atom` is `Infinite`, so the condition is not decidable in its stated shape.
  It is decidable because every label is a subset of `closureOf (Γ ++ Del)`: an atom outside
  the closure is absent from both sides. `atomClauseAt`/`atomCoherent_iff_at` is that gate, the
  same device `labClauseAt` and `boxClause` already use. (C0) itself is unchanged.
- **Finiteness lives on `verts`, not on a `Fintype` of positions.** `Pos = Fin |lassos| × ℤ`
  cannot be a `Fintype`, and keeping the time coordinate in the carrier is exactly what makes
  `Probe476.fmp_false`'s pigeonhole step inapplicable here. The graph is carried as a
  `Finset`-valued successor function over the `Finset` `verts`, and the `Fintype` the fixpoint
  needs is `Fintype {v : Pos // v ∈ verts}`, which comes free.
- **The `snce` computation is an instantiation, not a second development.** Every fixpoint
  lemma is stated at an arbitrary successor function, so `snceFix := AUFix.lfp verts predF …`
  inherits all of them; `mem_snceFix_iff` and `snceFix_induction` are two-line specialisations.
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
- **Phase 6** `StabFaithful` excluded by user decision (recorded in `.decisions.json`, cycle 3),
  and the phase re-marked `[COMPLETED WITH EXCLUSIONS]` with a full `Reasoned Exclusions`
  record. Not a deviation: a settled scope change.
- **Phase 7** no deviation. Two in-plan `Scope Hypothesis` corrections were recorded on the
  phase rather than absorbed: the combined window is family-wide rather than one lasso's window
  widened by the `share` period, and the number of `Decide.lean` instances reusable at a
  sharing family is seven, not four (nothing in `Decide.lean` reads the sharing datum). The
  closure gate (C0) needs was an unbudgeted extra lemma, also recorded there. The `#check`
  confirmation was strengthened to `example … := inferInstance`, which exercises synthesis
  rather than only the constants' existence.
- **Phase 8** no deviation. One in-plan `Scope Hypothesis` correction: the fuel bound is
  `|V| + 1`, not `|V|`, because the chain starts at index `0` with `∅`. The `Fintype`
  deliverable is met on the coercion of `verts` rather than on `Pos`, for the reason in
  Decisions; the phase records that as a representation note. The `#eval` verification bullet
  is discharged by `#guard`, which checks the computed answer instead of only printing it.

## Verification

- Build: Success. Full `lake build` through the guard, detached: 2748 jobs, exit 0, zero
  `error:` lines, zero warnings on the new modules, `.olean`s regenerated for every touched
  module.
- Sorry count: 0 (over the resolved source roots; `Sharing/` reports 0 on its own).
- Vacuous count: 0 introduced. The single repo-wide grep hit
  (`FormalSystem/Examples/TemporalStructures.lean:495`) is pre-existing, unrelated and unchanged.
- Axiom count: 14, unchanged from the pre-task baseline and from this dispatch's own baseline.
- `#print axioms` on `share`, `rep_idem'`, `reachN_add`, `frame`, `instIsRegular`,
  `frame_sat_ztime`, `total_eq_thread`, `thread_is_history`, `localCoherentLab_of_share`,
  `exists_window_repr`, `atomCoherent_iff_window`, `localCoherentShare_iff_window`,
  `decidableAtomCoherent`, `decidableLocalCoherentShare`, `AUFix.exists_stab`,
  `AUFix.lfp_fixed`, `AUFix.lfp_least`, `AUFix.lfp_induction`, `untlFix`, `snceFix`,
  `rep_nextTime`, `L_prevTime`: each reports exactly
  `[propext, Classical.choice, Quot.sound]`. No `sorryAx`.
- The three `SmokeTest` `#guard`s pass, which is a real check and not a print: on the one-lasso
  family the window is `[-2, 4)`, `untlFix p p` is the single position at time `-1`, and
  `snceFix p p` its mirror at time `1`.
- `example (W : WitnessFamily Γ Del) (t : ℤ) : Decidable (W.Certifies t) := inferInstance` still
  elaborates: the deterministic decision procedure is intact.
- `bash .claude/scripts/check-task-references.sh`: PASS, 0 unexempted occurrences.
- Plan-compliance spot-check against the plan's fifteen pinned Goals (sixteen minus the
  excluded (C5)): 8 present (`SharingWitnessFamily`, `share`, `Thread`, `frame`,
  `instIsRegular`, `total_eq_thread`, `AtomCoherent`, `LocalCoherentShare`), 7 absent
  (`ThreadFulfilling`, `Certifies`, `decidableCertifies`, `truth_iff_mem`,
  `refutes_of_certifies`, `toSharing`, `certifies_toSharing`) — they belong to Phases 9-14,
  which were not reached. Phases 7 and 8 deliver supporting plumbing, which the plan states
  carries no pinned statement.
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

- **Phase 9 is where the remaining difficulty is, and it is identified.** Folding a far-left
  position into the window is not obviously obligation-preserving for a **universal** path
  quantifier: the real forward ray from `u ≪ -2·NB` winds around the backward cycle extra times.
  This is the branching analogue of `Decide.lean`'s `untlObl_shift_back`, whose proof works only
  because that obligation is existential. The route through it is (C1') propagation — under
  `LocalCoherentShare` the only possible counterexample walk is "guard forever, event never", so
  the extra prefix's guard obligations are automatic. If that makes the reduction
  coherence-relative, Phase 9's standalone `Decidable (ThreadFulfilling S)` deliverable becomes
  a plan deviation on a `.lean` file and must be raised, not restated. Full design, including
  the `FoldRel` invariant that lets a graph walk be read as a ℤ-walk, is in
  `handoffs/phase-8-handoff-20260928.md`.
- **(C5) is settled, not open.** `StabFaithful` as pinned is not stateable at this
  datatype: `WitnessFamily` is indexed by `Context = List Formula`, and
  `FormalSystem.Syntax.Formula` has six constructors with no `⊡`; the stability modal is
  `PlusFormula.stab`, a constructor of the separate inductive
  `FormalSystem.PlusLanguage.PlusFormula`. Either (a) add an L⁺-indexed certificate datatype
  (re-indexing `LabelledLasso`, `closureOf`, `WitnessFamily`, its four conditions and its
  agreement theorem over `PlusFormula`, which also re-opens the JSON export contract), or
  (b) drop (C5), `StabFaithful` and the `⊡` case of the truth lemma from this task and keep the
  branching frame as the deliverable that unblocks them. **The user chose (b)** (recorded in
  `.decisions.json`, cycle 3): (C5) moves to a follow-up task that introduces an L⁺-indexed
  certificate datatype. Phase 6 carries the full `Reasoned Exclusions` record, and Phases 10,
  11 and 12 each lost exactly one deliverable.
- Phases 9-14 remain. See `handoffs/phase-8-handoff-20260928.md` for the resume point, the
  inherited API inventory, and six further elaboration traps.
- `Sharing/README.md`, the `WitnessFamily/README.md` submodule map and the `BiLasso/README.md`
  scoping of the all-histories claim are Phase 14 items and are not yet written.

## References

- `specs/683_state_sharing_witness_structure_and_c3/plans/01_state-sharing-witness-structure.md`
- `specs/683_state_sharing_witness_structure_and_c3/reports/01_state-sharing-witness-structure.md`
- `specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-6-handoff-20260927.md`
- `specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-8-handoff-20260928.md`
- `specs/683_state_sharing_witness_structure_and_c3/.decisions.json` (the (C5) scope decision)
