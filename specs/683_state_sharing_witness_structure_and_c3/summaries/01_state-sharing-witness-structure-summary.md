# Implementation Summary: Task #683

- **Task**: 683 - State-sharing witness structure and C3
- **Status**: [COMPLETED]
- **Started**: 2026-09-27
- **Completed**: 2026-09-28
- **Effort**: ~4 agent dispatches (plan budget: 23.5 hours across 14 phases)
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
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Agreement.lean` — new, 411 lines
    (Phases 10-11). **`model`** (the branching `TaskModel`, valuation a `Quotient.lift` over
    `share`-classes, taking the (C0) proof as an explicit argument), `valuation_cls`, the two
    inner inductions along a thread **`untl_mem_along_thread`** / **`snce_mem_along_thread`**,
    and **`truth_iff_mem`** — T1 for the branching device, by induction on `Formula`'s six
    constructors, generalised over the thread and the time offset. Then the bundle
    **`Certifies`** (five components, with (C1') and (C2') nested as one conjunct),
    **`decidableCertifies`**, `truth_main_iff_mem`, `not_consequence_ztime`,
    **`joint_countermodel`** and **`refutes_of_certifies`**, the last landing in the unchanged
    `WitnessFamily.Refutes Γ Del`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Specialize.lean` — new, 455 lines
    (Phases 12-13). **`WitnessFamily.toSharing`** (three singleton `id` segments), `rep_toSharing`,
    **`share_toSharing`** (`share u i j ↔ i = j`), **`atomCoherent_toSharing`**,
    **`localCoherentShare_toSharing`** ((C1') ↔ (C1)), `thread_toSharing_eq_zero` /
    `thread_toSharing_idx` (every thread at the diagonal is constant, by `Int.induction_on` on
    the step field), **`threadFulfilling_toSharing`** ((C2') ↔ (C2)) and
    **`certifies_toSharing`**. Then the isomorphism: `step_toSharing`, `reachN_toSharing`,
    `conn_toSharing` (connectivity at the diagonal is index equality), **`stateEquiv`**,
    `stateEquiv_cls_pair` / `cls_stateEquiv`, `taskRel_toSharing` and its pair-level twin
    `taskRel_toSharing'`, **`histEquiv`**, `valuation_toSharing`, **`truthIso`**,
    **`truth_iff_mem_toSharing`** and `refutes_of_certifies_toSharing`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` — new, 237 lines
    (Phase 14). The module map, the `share` encoding decision, the thread characterization, the
    condition-by-condition break/reuse table with the **(C3) correction**, the (C2') fixpoint and
    its recorded decidability limitation, the accurate `Probe476.fmp_false` scoping, the
    three-part (C5) status, the consuming-model-checker hand-off, and the diagonal instance.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` — Phase 14. A `Sharing/`
    submodule table and a new `## (C3) BoxFaithful is recombination-stable — a correction`
    section naming the consuming repository's adequacy document as the thing being corrected.
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — Phase 14. The stability-modal scope
    note now says plainly that `ShiftSet.total_eq_orbit` holds *because* the shift relation is
    functional and is false for a branching frame, and points at `../WitnessFamily/Sharing/`
    where the branching structure it called for now lives.
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — nine import lines, plus a
    `Sharing/` entry in the `## Submodules` block.
- `specs/state.json` — `file_scope` extended (append-only) to cover the new modules.

The deterministic path is byte-identical: `git diff` against the dispatch's own starting commit
over `Semantics/ShiftSet.lean` and `WitnessFamily/{Basic,Predicates,Std,Agreement,Decide}.lean`
is empty, and so is `git diff HEAD` over the same six files.

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
- **No `ShiftTruth` analogue, and therefore no `forward_repr`.** The deterministic development
  states its induction at `ShiftSet.ShiftTruth` and composes with `ShiftSet.forward_repr` to
  reach `TruthAt`. There is no shift-set layer under the branching frame, so `Sharing/Agreement`
  states the induction at `TruthAt` from the start, generalised over the thread and the time
  offset instead of over a carrier point. The role `forward_repr` plays on the deterministic
  side is played here by nothing, because there is no auxiliary predicate to convert from.
- **`total_eq_thread` and `thread_is_history` are consumed one per half of the `box` case.**
  The labels-to-truth half needs every world history to be a thread's trace, so that the
  induction hypothesis applies to an arbitrary `σ`; that is `total_eq_thread` composed with
  `WorldHistory.ext_state`. The truth-to-labels half needs every position to carry a history
  through it, so that a universally quantified truth can be read at an arbitrary `(j, v)`; that
  is the constant thread at `j` from offset `v - t`. Neither half survives the deterministic
  argument's shape.
- **The (C1')/(C2') pair is nested inside `Certifies`, not left flat.** `Fulfil.lean` exports no
  standalone `Decidable (ThreadFulfilling S)`, so `decidableCertifies` is assembled from four
  instances and the nesting is what makes that assembly a bare `inferInstanceAs` rather than a
  `decidable_of_iff` through a reassociation. The bundle still has five *components*; the
  docstring records both counts.
- **The two devices coexist because `Refutes` existentially quantifies the frame.** Nothing
  about the deterministic producer changes, and a consumer written against `Refutes` accepts
  certificates of either shape with no change; the branching producer simply supplies
  `S.frame.toTaskFrame` where the deterministic one supplies `W.std.frame`.
- **The specialization reductions are `iff`s, and only at the diagonal.** `Predicates.lean`
  already proves (C1') → (C1) and (C2') → (C2) unconditionally. The converses hold exactly
  because `share u i j ↔ i = j` collapses the shared-successor quantifier to one index and makes
  every thread constant; `thread_toSharing_idx` is the whole content of the second.
- **The frames are isomorphic, not equal, and the round trip cannot be collapsed.**
  `W.std.frame`'s carrier is `Fin |lassos| × ℤ`; `(W.toSharing).frame`'s is a quotient of that
  type *by equality*, and a quotient by equality is equivalent to what it quotients but never
  equal to it. A second, quieter obstacle: `W.std.Carrier` is a structure field of a plain `def`
  (`ShiftSet.ofIntAction`), so it unfolds only at default transparency and a `rw` whose pattern
  is typed at `Fin |lassos| × ℤ` will not fire against a term typed at `W.std.frame.WorldState`.
  `stateEquiv_cls_pair`, `cls_stateEquiv` and `taskRel_toSharing'` exist to route around that by
  `exact` instead of by `rw`.
- **`Semantics/HistoryMorphism.lean` was not needed.** Its `HistMap`/`HistMorphism` are for
  non-invertible maps; the diagonal instance gives a genuine `Equiv` of world histories, which
  is exactly what `TruthIso`'s `hist` field wants, so the transport goes through
  `TruthTransport.lean`'s `TruthIso` and `Truth.truthAt_of_truthIso` alone.

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
- **Phase 10** `forward_repr` altered: there is no `ShiftSet` layer under the branching frame
  and hence no `forward_repr` to prove. The induction is stated at `TruthAt` directly and the
  `box` case is grounded in `total_eq_thread` plus the constant thread, which is the content the
  plan item names. Annotated inline on the plan's checklist item.
- **Phase 11** `decidableCertifies` altered: landed in `Sharing/Agreement.lean` beside
  `Certifies`, not in `Sharing/Decide.lean` as the plan's file list says. `Sharing/Fulfil.lean`
  imports `Sharing/Decide.lean`, so the joint `decidableCoherentShareAndFulfilling` instance is
  not in scope in `Decide.lean` and the instance cannot be stated there without inverting the
  import edge. `Sharing/Decide.lean` is therefore unmodified by this phase.
- **Phase 11** `Scope Hypothesis` confirmed with the Phase 9 adjustment: five components, four
  instances. Recorded in the plan.
- **Phase 12** no deviation.
- **Phase 13** transport machinery altered: `Semantics/HistoryMorphism.lean` was not used (see
  Decisions). The specialization corollary is also altered — `WitnessFamily.Refutes` is a `Prop`,
  so an equality of the two producers' outputs is proof irrelevance and carries no mathematical
  content. What is landed is that equality, `refutes_of_certifies_toSharing`, together with an
  explicit docstring saying the substantive specialization is `truthIso` (the two countermodels
  are built over isomorphic frames) and that the equality's value is what its *statement*
  requires in order to typecheck: one and the same `Refutes Γ Del`, from one and the same
  `W.Certifies t`, with no coercion and no re-proof.
- **Phase 14** one file beyond the plan's three: `WitnessFamily.lean`'s own `## Submodules`
  block gained a `Sharing/` entry, which would otherwise have been left silently incomplete.
  Annotated inline on the plan's file list.

## Verification

All figures below are this dispatch's own, re-measured after Phase 14.

- Build: **Success.** Full `lake build` through `lake-build-guard.sh`, detached: guard
  `exit_status=0`, `Build completed successfully (2750 jobs)`, zero `error:` lines over both
  captured streams, and `.olean` newer than source for every module this task touched
  (`Sharing/Agreement`, `Sharing/Specialize`, `WitnessFamily`).
- Sorry count: **0** (`lean-sorry-census.sh` over the eight resolved source roots).
- Vacuous count: **0 introduced.** The repo-wide single-line grep returns one hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`
  (`theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`). It is
  pre-existing — last touched by an unrelated earlier change, and `git diff` over that file is
  empty for this dispatch — and it is a true theorem whose proposition is definitionally `True`
  for a total history, not a placeholder standing in for an unproved obligation. It is a false
  positive of the heuristic, not a vacuous definition.
- Axiom count: **14**, unchanged from the pre-task baseline and from this dispatch's baseline.
- `#print axioms` on **all fifteen** of the plan's pinned Goals, fully qualified —
  `SharingWitnessFamily`, `.share`, `.Thread`, `.frame`, `.instIsRegular`, `.total_eq_thread`,
  `.AtomCoherent`, `.LocalCoherentShare`, `.ThreadFulfilling`, `.Certifies`,
  `.decidableCertifies`, `.truth_iff_mem`, `.refutes_of_certifies`, `WitnessFamily.toSharing`,
  `WitnessFamily.certifies_toSharing` — fifteen reports, every one exactly
  `[propext, Classical.choice, Quot.sound]`, zero `sorryAx`. Elaborating those `#print axioms`
  lines is itself the existence check: a missing declaration is an elaboration error, which is
  strictly stronger evidence than the bare-name grep the compliance spot-check runs.
- `#print axioms` likewise clean on the new supporting declarations: `model`,
  `untl_mem_along_thread`, `snce_mem_along_thread`, `joint_countermodel`,
  `not_consequence_ztime`, `localCoherentShare_toSharing`, `threadFulfilling_toSharing`,
  `atomCoherent_toSharing`, `stateEquiv`, `histEquiv`, `truthIso`, `truth_iff_mem_toSharing`,
  `refutes_of_certifies_toSharing`.
- `example (S : SharingWitnessFamily Γ Del) (t : ℤ) : Decidable (S.Certifies t) := inferInstance`
  elaborates, in the module, by synthesis — the Phase 11 verification bullet.
- `#check @SharingWitnessFamily.refutes_of_certifies` shows the codomain
  `WitnessFamily.Refutes Γ Del`, the **same** statement the deterministic producer lands in.
- `grep -n "BoxFaithful" Sharing/Agreement.lean`: the existing (C3) is *applied* (as the
  hypothesis `hbox : S.toWitnessFamily.BoxFaithful`), never restated.
  `grep -n "StabFaithful" Sharing/Agreement.lean`: one hit, in the module docstring only.
- Deterministic path untouched: `git diff --stat` against this dispatch's starting commit over
  `Semantics/ShiftSet.lean` and `WitnessFamily/{Basic,Predicates,Std,Agreement,Decide}.lean` is
  empty. `example (W : WitnessFamily Γ Del) (t : ℤ) : Decidable (W.Certifies t) := inferInstance`
  still elaborates.
- `bash .claude/scripts/check-task-references.sh`: **PASS**, 0 unexempted occurrences across 4
  trees.
- Plan-compliance spot-check: **passed**. The contract's grep extracts only dot-free backticked
  names from the plan's Goals block, which is `SharingWitnessFamily` and `share`; both are
  present. The namespace-qualified evidence for all fifteen is the `#print axioms` run above.
- Earlier phases' verification evidence (the Phase 1-9 `#print axioms` runs and the three
  `SmokeTest` `#guard`s) stands unchanged; the `#guard`s re-ran green in the full build.
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
- **The certificate format is now two-shaped, at one interface.** `WitnessFamily.Refutes Γ Del`
  has two producers, and a consumer written against it accepts either with no change. A model
  checker that wants to emit a sharing certificate adds exactly three fields — `repBack`,
  `repMid`, `repFwd`, three periodic segments of idempotent index maps in the same shape as the
  existing label segments — and changes the accepting branch's name; the five exported fields
  keep their names, meanings and shapes. `Sharing/README.md` carries that hand-off as prose.
- **The received account's (C3) claim is corrected in-repo, twice.** Both
  `WitnessFamily/README.md` and `Sharing/README.md` now record that `BoxFaithful`'s right-hand
  side quantifies over the label pool and mentions no history, so recombination adds nothing for
  `□` to range over; what breaks is (C1) and (C2), both stated per lasso. A future reader coming
  from the consuming repository's adequacy document meets the correction before the code.
- **`Probe476.fmp_false` is now scoped accurately in-repo.** It refutes a finite model property
  for time-free finite digraphs, by a pigeonhole step that has no analogue here because the time
  coordinate stays in the carrier. It is a reason to prefer a labelled family over a finite
  presentation as the searched object, not an obstruction to admitting recombined histories.

## Follow-ups

- **The standalone `Decidable (ThreadFulfilling S)` remains open, and is now settled as
  accepted rather than pending.** The far-left case of the (C2') window reduction is closed by
  (C1') propagation, so the reduction is coherence-relative. The user decision (recorded in
  `.return-meta.json` from the previous cycle and carried into this dispatch's Prior Decisions)
  accepted the coherence-relative form: `Certifies` carries (C1') anyway, so
  `decidableCertifies` assembles from four pieces and nothing downstream loses anything. The
  unconditional form is not refuted — it would need the position graph's backward region to
  carry a cycle edge `-1 → -NB-1` alongside `-1 → 0`, and the fixpoint lemmas re-proved against
  the strictly larger walk set — and is recorded in `Sharing/README.md` as a possible
  refinement, not a defect.
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
- **All fourteen phases are complete.** The three phase handoffs
  (`phase-6`, `phase-8`, `phase-9`) remain useful as an elaboration-trap catalogue (seventeen
  traps, numbered), and `phase-14-handoff-20260928.md` records the final state.
- **The branching device has no `Examples.lean`.** The deterministic device has a non-vacuity
  witness (`posFamily`), a separation witness (`sepFamily`) and two impossibility theorems.
  `Sharing/` has the three `SmokeTest` `#guard`s on the fixpoint computation and nothing else:
  there is no worked example of a family whose branching genuinely does something the
  deterministic one cannot — specifically, no exhibited family satisfying (C1') and (C2') whose
  `share` is non-trivial, and no exhibited family satisfying the deterministic (C2) but failing
  (C2'). The second would be the direct non-vacuity witness for the whole design, since it is
  exactly the gap the branching fulfilment check exists to catch. Worth a follow-up.
- **The complexity bound is recorded but not measured.** The fulfilment fixpoint runs over a
  graph of size `|lassos| · (2·NB + NM + 2·NF)` with `NB`/`NF` products over cycle lengths, so
  it is exponential in the number of lassos in the worst case. No benchmark exists.
- **The consuming model checker is not updated.** `Sharing/README.md` records what it would need
  to emit; that repository is deliberately untouched by this work.

## References

- `specs/683_state_sharing_witness_structure_and_c3/plans/01_state-sharing-witness-structure.md`
- `specs/683_state_sharing_witness_structure_and_c3/reports/01_state-sharing-witness-structure.md`
- `specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-6-handoff-20260927.md`
- `specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-8-handoff-20260928.md`
- `specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-9-handoff-20260928.md`
- `specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-14-handoff-20260928.md`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` (the durable in-repo map)
- `specs/683_state_sharing_witness_structure_and_c3/.decisions.json` (the (C5) scope decision)
