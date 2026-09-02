# Implementation Summary: Task #523

- **Task**: 523 - Frame kit helpers, transport, standard frames (WAVE 2, core utilities)
- **Plan**: `specs/523_frame_kit_helpers_transport_standard_frames/plans/01_frame-kit-helpers-transport.md`
- **Status**: **PARTIAL** — 12 of 14 phases `[COMPLETED]`, 1 `[COMPLETED WITH EXCLUSIONS]`,
  **1 `[BLOCKED]`**
- **Type**: lean4
- **Session**: sess_1788377349_296ecf

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
| 10 Shift and period transports | **BLOCKED** | see below — a research-report error |
| 11 Anti-iso twin + `truthAt_mirror` | COMPLETED | `CoNotPriorU.lean` has zero `induction φ` |
| 12 Recast `Aligned`; derive `truthAt_map` | COMPLETED WITH EXCLUSIONS | documented fallback taken |
| 13 `TemporalOrder` migration go/no-go | COMPLETED | **NO-GO** on a re-measurement |
| 14 `Frames/Standard.lean`, gaps, docs, rename | COMPLETED | all four counts re-measured |

## The blocker (Phase 10) — read this first

**`Truth.time_shift_preserves_truth` cannot be derived from the `TruthIso` structure Phase 9
landed, and no rearrangement of `dur`/`hist` fixes it.** The obstruction is a quantifier mismatch
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

**What is needed** is a planning decision, not an implementation one:

1. **Widen `TruthIso`** — `hist` becomes a `WorldHistory F ≃ WorldHistory F'` plus a
   totality-preservation field and a domain-transport field, with the `F.HF` form derived from
   it. This subsumes the landed structure and would unblock Phase 12 as well. It changes the
   structure Phase 9 specified and landed, so it is not a change to make silently inside an
   implementation dispatch.
2. **Accept** that `time_shift_preserves_truth` and `truthAt_map` keep their own inductions and
   restate the acceptance criterion.

Option 1 is the better deal — it converts Phase 12's fallback into a second win. Neither option
involves weakening `time_shift_preserves_truth`'s statement, which is explicitly prohibited: its
`σ` is genuinely general and its consumers are entitled to that.

**Phase 10 was not a total loss.** Two of its three deliverables landed:

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
`Semantics/` + `Independence/`. The measured count is **five**:

| Declaration | Status |
|---|---|
| `Truth.truthAt_of_truthIso` | new generic lemma (Phase 9) |
| `Truth.truthAt_of_truthAntiIso` | new generic twin (Phase 11) — the plan's criterion did not count it |
| `TimeShift.timeShift_preserves_truth` | **blocked**, Phase 10 |
| `IntTransfer.truthAt_map` | **excluded**, Phase 12 |
| `FwdRecPeriodicity.truthAt_add_hist_period` | permanently not an instance; docstring records why |

Three transports were **removed** by this task: `LoopingDuration.truthAt_add_period`,
`CoNotPriorU.truthAt_mirror`, and `Truth.truth_double_shift_cancel`. Before the task the region
carried six hand-written transport inductions and no generic one; it now carries two generic ones
and three remaining.

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
3. **Phase 10's premise** that `time_shift_preserves_truth` is derivable (see above).
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
| `./.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (detached, unpiped) | **exit 0**, 2520 jobs |
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

1. Phases 10 and 12 did not delete what they were budgeted to delete: `time_shift_preserves_truth`
   (233 lines) and `truthAt_map` (72) both survive, and the two derivations that would have
   replaced them are ~24 lines that were never written. That is ≈ 280 lines of the shortfall.
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
- **Phase 10** — **BLOCKED**, escalated, full record in the plan file.
- **Phase 11** — *(altered)* the "written against `swap_norm`, not raw
  `simp only [Formula.swapTemporal]`" bullet is not satisfiable as written: `swap_norm` collects
  the eleven lemmas that push `swapTemporal` through the *derived* operators, and a
  six-constructor induction needs the *base* equations, which are not in that set and should not
  be added to it. Recorded in the generic lemma's own docstring.
- **Phase 12** — **COMPLETED WITH EXCLUSIONS**, documented fallback, `#### Reasoned Exclusions`
  table in the plan file.
- **Phase 14** — *(altered)* `Frames/Standard.lean` imports `Mathlib.Tactic.Abel` in addition to
  `TaskFrame`; `translationFrame`'s group arithmetic needs it and `DurationFrames.lean` had been
  supplying it transitively. No `FormalSystem` import beyond `TaskFrame`, which is what the
  verification bullet constrains.

## Follow-on work identified

- **The `TruthIso` widening decision** (see the blocker). This is the one item that needs a human.
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
- 32 modified files across `FormalSystem/`, `Tests/`, `scripts/`
