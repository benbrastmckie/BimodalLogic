# Implementation Summary: Task #683

- **Task**: 683 - State-sharing witness structure and C3
- **Status**: [IN PROGRESS]
- **Started**: 2026-09-27
- **Completed**: (not complete — Phases 10-14 remain)
- **Effort**: ~3 agent dispatches (plan budget: 23.5 hours across 14 phases)
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
fixpoint that is the computational core of (C2').

Phase 9 closed with one exclusion. (C2') `ThreadFulfilling` is defined, and both correctness
directions against the Phase 8 fixpoint are proved: soundness (a vertex in the fixpoint
discharges the eventuality along every thread through every time it folds) and completeness (a
vertex outside it admits a counterexample thread, pumped from a graph escape walk). The
reduction to a bounded window check, and hence the decision procedure, is delivered **relative
to (C1') `LocalCoherentShare`** rather than standalone; the plan's `Decidable
(ThreadFulfilling S)` instance is excluded and the reason is recorded below and in the plan's
Phase 9 Reasoned Exclusions table. Phases 10-14 remain.

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
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean` — extended
  (Phase 9). (C2') **`ThreadFulfilling`**, the universal-path form of `FulfillingLab`, and
  **`fulfillingLab_of_thread`**, its constant-thread specialization to the deterministic (C2)
  (the mirror of `localCoherentLab_of_share`). A new header section records why (C3)
  `BoxFaithful` survives recombination while (C2) does not.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean` — extended (Phase 9),
  in four layers.
  - *Fold relations*: **`FoldRel`** / **`FoldRelB`** with `refl`/`symm`/`trans`, the data
    lemmas `foldRel_rep`/`foldRel_L` and duals, `foldRel_succ`/`foldRelB_pred`, the wrap
    lemmas **`foldRel_nextTime`**/**`foldRelB_prevTime`**, and the window folds
    **`exists_fold_fwd`**/**`exists_fold_back`**.
  - *Walks as threads*: **`FwdWalk`**/**`BwdWalk`**, `mem_verts`, `time_succ`, `share_succ`,
    the fold invariants **`FwdWalk.foldRel`**/**`BwdWalk.foldRelB`**, `walkIdx` with
    `walkIdx_add`/`walkIdx_sub`/`walkIdx_le`/`walkIdx_ge`, and **`toThread`**.
  - *(C1') propagation*: `untl_thread_step`, `snce_thread_step`, `thread_share_pred`,
    `untl_propagate`/**`untl_propagate_le`**, `snce_propagate`/**`snce_propagate_ge`**, and
    **`untl_fulfil_of_exists`**/**`snce_fulfil_of_exists`**.
  - *Correctness and decision*: **`thread_untl_of_mem_untlFix`**/
    **`thread_snce_of_mem_snceFix`** (soundness), `fulfilClauseAt`, **`FulfilWindow`**,
    `decidableFulfilWindow`, `untlFix_of_window`/`snceFix_of_window`, `cohWindow_lo_mem`/
    `cohWindow_hi_pred_mem`, **`threadFulfilling_of_window`**,
    **`window_of_threadFulfilling`**, **`threadFulfilling_iff_window`**,
    `decidableThreadFulfilling` (a term taking the (C1') hypothesis) and the genuine instance
    **`decidableCoherentShareAndFulfilling`**. The module now carries
    `set_option linter.style.longFile 1700`, as `lakefile.toml` prescribes for a file over the
    1500-line limit.
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
- **The window reduction for (C2') is relative to (C1'), and that is structural.** A position
  at or after `cohWindowLo` folds into the window and its obligation transports. A position
  strictly left of it does not: the forward ray from far left lingers in the backward periodic
  region for arbitrarily many steps, while the graph's backward region is a finite *path* into
  the origin rather than a cycle, so a walk that lingers longer than `2·NB` steps has no image
  in the graph at all. `Decide.lean`'s `untlObl_shift_back` closes the same gap for the
  deterministic device only because its obligation is **existential**; a universal path
  quantifier does not transpose that argument. (C1') propagation closes it instead, by carrying
  an unfulfilled eventuality forward along every thread together with its guard, so the
  far-left obligation *walks* into the window. The consequence for the deliverable is recorded
  under Plan Deviations.
- **The escape walk is built by `choose` on a total function, not by dependent choice.** The
  completeness direction needs an infinite counterexample walk. Stating the escape as
  `∀ z, ∃ y, (z ∈ verts → y ∈ succF z) ∧ …` — total in `z`, with the interesting content behind
  hypotheses — makes `choose` yield a plain `f : Pos → Pos`, and the walk is `f^[k] v`. No
  recursion-with-proof-obligations and no `Nat.rec` on a dependent motive.
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
- **Phase 9** `Decidable (ThreadFulfilling S)` altered, and the phase re-marked
  `[COMPLETED WITH EXCLUSIONS]` with a full `Reasoned Exclusions` record. The plan's fourth
  task asks for a standalone instance; what is landed is the hypothesised term
  `decidableThreadFulfilling (hlc : S.LocalCoherentShare) : Decidable S.ThreadFulfilling`
  together with the unhypothesised instance `decidableCoherentShareAndFulfilling` on the
  conjunction `LocalCoherentShare ∧ ThreadFulfilling`. The reason is in Decisions above; the
  Phase 8 handoff predicted this exact outcome and asked that it be raised rather than silently
  restated, which is why it is a `user_decision` on this dispatch's return metadata and not a
  quiet substitution. Nothing downstream is lost — `Certifies` carries (C1') as one of its five
  components — but Phase 11's `decidableCertifies` must now be assembled from four pieces
  rather than five, and Phase 11's task list has been annotated accordingly. The other three
  Phase 9 tasks landed as written; the mathematical content the phase asked for (the semantic
  condition, both correctness directions, a bounded decision procedure) is complete.
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
- `#print axioms` on all twenty-one Phase 9 declarations — `ThreadFulfilling`,
  `fulfillingLab_of_thread`, `FoldRel`, `FoldRelB`, `exists_fold_fwd`, `exists_fold_back`,
  `FwdWalk.toThread`, `BwdWalk.toThread`, `untl_propagate_le`, `snce_propagate_ge`,
  `untl_fulfil_of_exists`, `snce_fulfil_of_exists`, `thread_untl_of_mem_untlFix`,
  `thread_snce_of_mem_snceFix`, `FulfilWindow`, `decidableFulfilWindow`,
  `threadFulfilling_of_window`, `window_of_threadFulfilling`, `threadFulfilling_iff_window`,
  `decidableThreadFulfilling`, `decidableCoherentShareAndFulfilling` — reports exactly
  `[propext, Classical.choice, Quot.sound]` in every case; twenty-one reports, zero `sorryAx`.
- `example (S : SharingWitnessFamily Γ Del) : Decidable (S.LocalCoherentShare ∧ S.ThreadFulfilling) := inferInstance`
  elaborates, in the module, by synthesis. This is the replacement for the plan's
  `Decidable (ThreadFulfilling S)` verification bullet, which is excluded with the instance.
- The three `SmokeTest` `#guard`s pass, which is a real check and not a print: on the one-lasso
  family the window is `[-2, 4)`, `untlFix p p` is the single position at time `-1`, and
  `snceFix p p` its mirror at time `1`.
- `example (W : WitnessFamily Γ Del) (t : ℤ) : Decidable (W.Certifies t) := inferInstance` still
  elaborates: the deterministic decision procedure is intact.
- `bash .claude/scripts/check-task-references.sh`: PASS, 0 unexempted occurrences.
- Plan-compliance spot-check against the plan's fifteen pinned Goals (sixteen minus the
  excluded (C5)): 9 present (`SharingWitnessFamily`, `share`, `Thread`, `frame`,
  `instIsRegular`, `total_eq_thread`, `AtomCoherent`, `LocalCoherentShare`,
  `ThreadFulfilling`), 6 absent (`Certifies`, `decidableCertifies`, `truth_iff_mem`,
  `refutes_of_certifies`, `toSharing`, `certifies_toSharing`) — they belong to Phases 10-14,
  which were not reached. Read the raw bare-name grep with care: `Certifies`,
  `decidableCertifies`, `truth_iff_mem` and `refutes_of_certifies` all match the *deterministic*
  namesakes in `WitnessFamily/`, so the counts above are the namespace-qualified ones.
  Phases 7, 8 and 9 additionally deliver supporting plumbing, which the plan states carries no
  pinned statement.
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
- (C2') is now a decidable condition of the branching certificate, which is what makes the whole
  device a decision procedure rather than a definition. The fulfilment check runs a least
  fixpoint over a finite position graph whose size is `|lassos| · (2·NB + NM + 2·NF)`, with
  `NB`/`NF` products over the family's backward/forward cycle lengths and `NM` a sum of window
  lengths — so it is exponential in the number of lassos in the worst case, and that bound is
  recorded here rather than discovered later.
- `FwdWalk`/`BwdWalk` and their `toThread` are reusable: any later development that needs to
  exhibit a thread realizing a graph walk should go through them rather than building the index
  function by hand.

## Follow-ups

- **The Phase 9 difficulty resolved as the Phase 8 handoff predicted, and the resolution needs
  a user decision.** The far-left case is closed by (C1') propagation, so the window reduction
  is coherence-relative and the standalone `Decidable (ThreadFulfilling S)` is not available.
  Two options, of which the second is what is implemented: (1) keep the plan's standalone
  instance and find a genuinely unconditional far-left argument — which would mean giving the
  graph's backward region a cycle edge `-1 → -NB-1` alongside `-1 → 0`, i.e. reopening Phase 8's
  committed `succF`, and re-proving its fixpoint lemmas against a strictly larger walk set; or
  (2) accept the coherence-relative form, which costs nothing downstream because `Certifies`
  carries (C1') anyway. Option 1 is not refuted, only out of scope for this dispatch. The
  decision is relayed as `user_decision` on `.return-meta.json`.
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
- Phases 10-14 remain. See `handoffs/phase-9-handoff-20260928.md` for the resume point, the
  inherited API inventory, and five further elaboration traps (thirteen through seventeen);
  `handoffs/phase-8-handoff-20260928.md` and `handoffs/phase-6-handoff-20260927.md` carry the
  first twelve.
- **Phase 11 has a concrete adjustment waiting.** Assemble `decidableCertifies` from four
  pieces — `decidableAtomCoherent`, `decidableCoherentShareAndFulfilling`,
  `decidableBoxFaithful`, `decidableTarget` — and either order `Certifies`' projections so the
  (C1')/(C2') pair is adjacent or prove the instance by `decidable_of_iff` through the
  reassociated conjunction. The plan's Phase 11 task list records this.
- `Sharing/README.md`, the `WitnessFamily/README.md` submodule map and the `BiLasso/README.md`
  scoping of the all-histories claim are Phase 14 items and are not yet written.

## References

- `specs/683_state_sharing_witness_structure_and_c3/plans/01_state-sharing-witness-structure.md`
- `specs/683_state_sharing_witness_structure_and_c3/reports/01_state-sharing-witness-structure.md`
- `specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-6-handoff-20260927.md`
- `specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-8-handoff-20260928.md`
- `specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-9-handoff-20260928.md`
- `specs/683_state_sharing_witness_structure_and_c3/.decisions.json` (the (C5) scope decision)
