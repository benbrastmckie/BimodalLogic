# Implementation Summary: Task #523

- **Task**: 523 - Frame kit helpers, transport, standard frames (WAVE 2, core utilities)
- **Plan**: `specs/523_frame_kit_helpers_transport_standard_frames/plans/01_frame-kit-helpers-transport.md`
- **Status**: **IMPLEMENTED** — 13 of 14 phases `[COMPLETED]`, 1 `[COMPLETED WITH EXCLUSIONS]`;
  all 14 closed
- **Type**: lean4
- **Sessions**: sess_1788377349_296ecf (dispatch 1: phases 1-14, with Phase 10 left `[BLOCKED]`);
  sess_1788396924_3fde5e (resumed dispatch: Phase 10 re-verified and closed after task 532
  resolved the blocker)

## Outcome at a glance

| Phase | Outcome | Note |
|-------|---------|------|
| 1 Helper D and the Saturation sites | COMPLETED | census was **eight** sites, not seven |
| 2 Z step-path dictionary by import | COMPLETED | `isWalk_iff_isStepPath` is `Iff.rfl` |
| 3 `DiscreteOrder.lean` and the order duals | COMPLETED | 184 proof lines → ~24 at the sites |
| 4 Helper B completion | COMPLETED | four new lemmas, all `[propext]` |
| 5 `ofTotal` and the six total-history sites | COMPLETED | one adapted call site, hazard recorded |
| 6 Eight dead lemmas; `Function.Periodic` | COMPLETED | each re-confirmed at 1 occurrence first |
| 7 Shared `isLeast_succ` / `isGreatest_pred` | COMPLETED | Direction A deliberately untouched |
| 8 `LexCarrier` generalised to `α ×ₗ ℤ` | COMPLETED | two `example`s promoted to theorems |
| 9 `TruthIso` + `truthAt_of_truthIso` | COMPLETED | generic body is **45 lines**, est. ~90 |
| 10 Shift and period transports | COMPLETED | blocked in dispatch 1 by a research-report error; resolved by task 532's `TruthCorr`; closed on re-verification — see below |
| 11 Anti-iso twin + `truthAt_mirror` | COMPLETED | `CoNotPriorU.lean` has zero `induction φ` |
| 12 Recast `Aligned`; derive `truthAt_map` | COMPLETED WITH EXCLUSIONS | documented fallback taken; both exclusions since resolved by task 532 (`alignedCorr`), marker left as recorded |
| 13 `TemporalOrder` migration go/no-go | COMPLETED | **NO-GO** on a re-measurement |
| 14 `Frames/Standard.lean`, gaps, docs, rename | COMPLETED | all four counts re-measured |

## The blocker (Phase 10) and its resolution — read this first

**`Truth.time_shift_preserves_truth` cannot be derived from the `TruthIso` structure Phase 9
landed, and no rearrangement of `dur`/`hist` fixes it.** (Dispatch 1's finding, retained
verbatim; the resolution follows it.) The obstruction is a quantifier mismatch
that the research report and the plan both missed:

- `time_shift_preserves_truth` is stated for an **arbitrary** `σ : WorldHistory F`, with no
  totality hypothesis anywhere.
- `TruthIso.hist` is an `F.HF ≃ F'.HF`, so `truthAt_of_truthIso` transports **total** histories
  only.
- An arbitrary history cannot be reduced to a total one: `TruthAt`'s `atom` clause is
  `∃ ht : τ.domain t, …`, so a non-total history makes atoms *false* off its domain and no total
  history reproduces that. Only the `box` case of the general induction is history-independent;
  `atom`, `imp`, `untl` and `snce` all genuinely depend on `σ`.

The report's §4.3 table records this transport as "derivable from a uniform `TruthIso`? **yes**",
which is the error. `IntTransfer.truthAt_map` (Phase 12) has the identical quantification and is
blocked the same way.

**Resolution.** Dispatch 1 escalated this as a planning decision between widening `TruthIso`
to a `WorldHistory F ≃ WorldHistory F'` and accepting two extra inductions. Neither option was
taken. Task 532 (`specs/532_worldhistory_extension_faithfulness_audit/`) resolved the mismatch
with a *relational* generic transport: `Semantics.TruthCorr` — an order iso `dur`, a
`Prop`-valued relation `Rel` on **arbitrary** histories, atomic agreement on related pairs, and
totality-existence in both directions (`total_fwd` / `total_bwd`, the paper's
`app:auto_existence`) — with `Truth.truthAt_of_truthCorr` as the one six-case induction.
`TruthIso` survives as the total-only bijective special case (`TruthIso.toCorr`), so Phase 9's
structure was neither widened nor discarded and `truthAt_of_truthIso` is now a one-line
instance. `TimeShift.timeShift_preserves_truth` is `truthAt_of_truthCorr` at
`shiftCorr M (y − x)` (`Truth.lean:787-795`; statement byte-identical, arbitrary `σ`; the
230-line induction deleted), and Phase 12's `IntTransfer.truthAt_map` is the same lemma at
`alignedCorr` — the module's recorded `Aligned`-not-`Equiv` prohibition is honoured, since
`Aligned e` is exactly a `Rel`. `time_shift_preserves_truth`'s statement was never weakened.

The resumed dispatch (session `sess_1788396924_3fde5e`) re-verified every Phase 10 checklist
item on the tree at HEAD `162f38511`, annotated the deviations inline in the plan, and advanced
the marker to `[COMPLETED]`. It modified **no Lean file**. Phase 12's
`[COMPLETED WITH EXCLUSIONS]` marker is left as recorded: its exclusions are resolved and the
plan says so, but that phase was already closed and the closure contract does not reopen it.

**Two of Phase 10's three deliverables had already landed in dispatch 1**, before the
resolution:

- `LoopingDuration.truthAt_add_period` *is* total-history-only and *is* derivable. It is now
  `truthAt_of_truthIso` at a new `loopingTruthIso`: 68 lines → 12, statement unchanged.
- `Truth.truth_double_shift_cancel` is **deleted**, together with
  `WorldHistory.time_shift_time_shift_neg_domain_iff` and `time_shift_time_shift_neg_states`.
  This turned out not to need the `TruthIso` derivation the plan expected to unlock it:
  `time_shift_preserves_truth`'s `box` case was instantiating its own induction hypothesis at
  `(timeShift ρ (x − y), x, y)` and then cancelling the double shift that produced, where
  instantiating the *same* hypothesis at `(ρ, y, x)` — times swapped — gives the goal outright.
  Three lemmas and ~75 lines removed for a one-line change.

## The `induction φ` ledger

The acceptance criterion asked for **at most two** truth-transport inductions across
`Semantics/` + `Independence/` ("at most three" if Phase 12 took its fallback). The plan's
Phase 10 resolution note restates it as "at most three" — two generic plus the per-history
exception — and that is the measured count at closure, **three**:

| Declaration | Status |
|---|---|
| `Truth.truthAt_of_truthCorr` (`Truth.lean:638`) | the generic relational lemma (task 532); `truthAt_of_truthIso`, `timeShift_preserves_truth`, `truthAt_map` and `truthAt_add_period` are all instances of it |
| `Truth.truthAt_of_truthAntiIso` (`:1126`) | generic time-reversal twin (Phase 11) — the plan's original criterion did not count it |
| `FwdRecPeriodicity.truthAt_add_hist_period` (`:401`) | permanently not an instance; docstring records why |

At the close of dispatch 1 the count was **five** (`timeShift_preserves_truth` blocked at
Phase 10 and `truthAt_map` excluded at Phase 12, both still hand-written). Three transports were
removed by this task's own dispatches (`LoopingDuration.truthAt_add_period`,
`CoNotPriorU.truthAt_mirror`, `Truth.truth_double_shift_cancel`) and two more by task 532.
Before the task the region carried six hand-written transport inductions and no generic one.

(Three further `induction φ` proofs in the region are **not** truth transports and were never in
scope: `Truth.truthAt_atomFree_history_indep`, and `ShiftSet`'s `forward_repr` / `reverse_repr`
representation theorems.)

## Corrections to the plan's stated figures

Every count the plan asserted was re-measured before use. Five were wrong:

1. **Phase 1's census was eight, not seven.** `FlowFrame.lean`'s own
   `multiFamTaskFrameGen.saturation` field — distinct from `multiFamGen_saturation` — was a
   further copy of the same argument. All eight are collapsed.
2. **Phase 5's "zero remaining `domain := fun _ => True` in `Semantics/`"** contradicts that
   phase's own fourth task, which lists `DurationFrames:178,264` among the deliberately-deferred
   follow-ons. The task list governs; those two literals remain.
3. **Phase 10's premise** that `time_shift_preserves_truth` is derivable *from `TruthIso`* (see
   above). It is derivable from the relational `TruthCorr` that task 532 landed, which is the
   form that finally closed the phase.
4. **Phase 13's decision input** — "57 / 61 / 50 references, essentially all of the form
   `(D := ℤ)`". Measured: 175 occurrences carrying 101 explicit annotations, of which only 47 are
   concrete at all. See below.
5. **Phase 14's rename forecast** — "reduces to `time_shift_congr` plus one". Phase 10's blocker
   left `time_shift_preserves_truth` alive, so the surface was 2 declarations and ~34 references
   across 10 files.

## Phase 13: the counted NO-GO

| Constant | Occurrences | Explicit `(D := …)` | concrete | abstract |
|---|---|---|---|---|
| `trivialFrame` | 61 | 33 | 21 | 12 |
| `staticFrame` | 61 | 43 | 9 | 34 |
| `natFrame` | 53 | 25 | 17 | 8 |
| **total** | **175** | **101** | **47** | **54** |

The migration removes **no** annotations. A concrete site still has to name its order — nothing
in `trivialFrame`'s type determines `D`, its `WorldState` being `Unit` — so `(D := ℤ)` merely
becomes `(D := intOrder)`. Each of the 54 abstract sites, where the surrounding declaration binds
`D : Type` because `BFMCS` / `FrameConditionFor` / `TemporalCarrier` / the
`C : (D : Type) → … → Prop` family pins it there, would grow to `(D := TemporalOrder.of D)`,
because unification cannot invert `TemporalOrder.carrier ?D =?= D`. Net: 101 → 101 with 54
strictly longer, against a GO condition of a strict decrease. The decision and its counts are
recorded in `TaskFrame.lean`'s "Frame constants" section.

## Verification

| Check | Result |
|---|---|
| `./.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (detached, unpiped), dispatch 1 | **exit 0**, 2520 jobs |
| Same invocation, resumed dispatch, at HEAD `162f38511` with no Lean change | **exit 0**, 2520 jobs, 0 `declaration uses 'sorry'` warnings, 0 errors |
| `scripts/check-module-invariants.sh`, resumed dispatch | **ALL CHECKS PASSED**, exit 0 |
| `^axiom ` declarations in `FormalSystem/`, resumed dispatch | **8**, equal to task 532's post-landing baseline; no Lean file touched |
| Sorry census (`lean-sorry-census.sh FormalSystem/`), resumed dispatch | 8 hits, all in `Boneyard/StrictSemanticsLegacy/` — pre-existing, not part of the build |
| Vacuous-pattern grep, resumed dispatch | 1 hit, `Examples/TemporalStructures.lean:496` `int_domain_universal … := trivial` — a genuine proof of a `True`-valued domain fact, pre-existing |
| `… -- build BimodalTest` | **exit 0** |
| `scripts/check-module-invariants.sh` | **exit 0** |
| C2 — all four flagship axiom sets | at baseline, unchanged |
| C3 — structural `sorry` inventory across `FormalSystem/` | **ZERO** |
| `^axiom ` declarations, before → after | **10 → 10**, no new axiom |
| `SaturationFiniteAxiomTest.lean`'s four pre-existing `#guard_msgs` blocks | pass unchanged |
| Three new Helper D axiom guards | pass; profiles as predicted |
| `grep -rn Spherical FormalSystem/` | 0 |
| `Bridge.step` / `taskRel_diff` / `ofWalk` / `hist_isWalk` | 0 |
| Eight deleted `WorldHistory.lean` lemma names | 0 each |
| `truth_double_shift_cancel` declarations and uses | 0 (2 prose mentions in docstrings record why it is gone) |
| `grep -rn "time_shift_"` over `FormalSystem/` + `Tests/` | 0 |
| `Semantics.lean` import coverage | all **35** `Semantics/**.lean` modules imported |

Measured axiom profiles, matching the plan exactly:

- `TaskFrame.sInter_nonempty_of_directed_subsingleton` — no axioms
- `TaskFrame.fib_subsingleton_of_functional` — no axioms
- `TaskFrame.saturation_of_fib_subsingleton` — `[propext]`
- all four Helper B additions — `[propext]`
- `Truth.truthAt_of_truthIso` — `[propext, Quot.sound]`

## Line budget

Measured across the whole task: **34 files changed, 1450 insertions, 1297 deletions** — net
**+153**, against a planned ≈ −737. Two causes, both recorded rather than explained away:

1. Within this task's own diff, Phases 10 and 12 did not delete what they were budgeted to
   delete: `time_shift_preserves_truth` (233 lines) and `truthAt_map` (72) both survived
   dispatch 1, and the two derivations that would have replaced them were never written here.
   That is ≈ 280 lines of the shortfall. Both inductions were subsequently deleted by task 532
   (`Truth.lean` 1217 → 1164 lines, `IntTransfer.lean` −28), so the reduction did land in the
   tree — under that task's commits, not this one's.
2. The remainder is **documentation**. Every phase's tasks called for recorded reasons — the
   HC-1/HC-2 rationales, the negative Mathlib survey, the `ofTotal` follow-on census, the
   Phase 13 measurement table, the `Frames/Standard.lean` placement argument, the blocker record.
   The proof and definition bodies did shrink substantially at every site the phases touched;
   the prose that replaced them is the deliverable the plan asked for, not overhead.

## Plan Deviations

- **Phase 2** — *(altered)* `Bridge.taskRel_nat`'s only consumer was `Bridge.taskRel_diff`, also
  deleted in that phase, so "retarget at `taskRel_natCast_iff_iter` + `iter_of_isStepPath`"
  resolved to deletion; `respects_of_isStepPath` already routes through exactly those two.
- **Phase 5** — *(altered)* the "zero remaining `domain := fun _ => True` in `Semantics/`"
  verification bullet contradicts the phase's own fourth task; the task list was followed.
- **Phase 10** — *(altered)* blocked in dispatch 1 and escalated; resolved by task 532's
  relational `TruthCorr` rather than the `TruthIso` instance the phase specified (`shiftCorr`
  with `Rel := ShiftRel Δ` in place of an `F.HF ≃ F.HF` `hist`), and the
  `truth_double_shift_cancel` deletion was unlocked by re-instantiating the consumer's IH at
  `(ρ, y, x)` rather than by `Equiv.symm_apply_apply`. Closed `[COMPLETED]` on re-verification in
  the resumed dispatch; every deviation is annotated on the phase's checklist in the plan.
- **Phase 11** — *(altered)* the "written against `swap_norm`, not raw
  `simp only [Formula.swapTemporal]`" bullet is not satisfiable as written: `swap_norm` collects
  the eleven lemmas that push `swapTemporal` through the *derived* operators, and a
  six-constructor induction needs the *base* equations, which are not in that set and should not
  be added to it. Recorded in the generic lemma's own docstring.
- **Phase 12** — **COMPLETED WITH EXCLUSIONS**, documented fallback, `#### Reasoned Exclusions`
  table in the plan file. Both exclusions were later resolved by task 532 (`alignedCorr`); the
  plan's resolution note records this and the marker is left as recorded.
- **Phase 14** — *(altered)* `Frames/Standard.lean` imports `Mathlib.Tactic.Abel` in addition to
  `TaskFrame`; `translationFrame`'s group arithmetic needs it and `DurationFrames.lean` had been
  supplying it transitively. No `FormalSystem` import beyond `TaskFrame`, which is what the
  verification bullet constrains.

## Follow-on work identified

- ~~The `TruthIso` widening decision~~ — resolved by task 532's `TruthCorr` (see the blocker
  section). Nothing in this task needs a human decision any more.
- `ShiftSet.wh_ext` now has **three** reachable copies (`ShiftSet.wh_ext`,
  `RegionFrame.worldHistory_ext`, and `CoNotPriorU`'s new import of the first). `ShiftSet.lean`'s
  own docstring already names consolidating them into `Semantics/WorldHistory.lean` as the clean
  follow-up; it is not a step of this plan.
- The **twelve `ofTotal` follow-on sites** outside `Semantics/`, enumerated in `ofTotal`'s
  docstring. Note the transparency hazard recorded in Phase 5's commit: a call site that unfolds
  a `WorldHistory` alias in a `simp` set needs `WorldHistory.ofTotal` alongside it, because the
  unfolded term is not type-correct at `implicit` transparency.
- `DurationFrames.lean`'s two remaining `domain := fun _ => True` literals.

## Artifacts

- `FormalSystem/Semantics/Frames/Standard.lean` (new) — standard-frame index
- `FormalSystem/Metalogic/SoundnessLemmas/DiscreteOrder.lean` (new) — abstract-`P` order cores
- 32 modified files across `FormalSystem/`, `Tests/`, `scripts/` (dispatch 1)
- Resumed dispatch: plan file and this summary only; no Lean file modified
