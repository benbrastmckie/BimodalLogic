# Implementation Summary: Task #602

- **Task**: 602 - Bundle semantics over WorldHistory
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T22:10:00Z
- **Completed**: 2026-09-17T01:30:00Z
- **Effort**: ~3.5 hours wall clock (lead agent plus six migration subagents)
- **Dependencies**: None (task 601 had already landed on main; this work was applied on top of it)
- **Artifacts**: plans/01_bundle-semantics-worldhistory.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`TaskFrame.HF` was replaced by `WorldHistory F := {τ : PartialHistory F // τ.IsTotal}`, which has a
non-dependent `state` accessor. Every truth relation (`TruthAt`, `MinusTruthAt`, `PlusTruthAt`,
`StarTruthAt`, `CTruthAt`, and the test-only `ToyTruthAt`) is now evaluated at world histories.
Every validity, consequence, and satisfiability predicate quantifies over them too. The atom
clause is the paper's `M.valuation (τ.state t) p`, box is `∀ σ : WorldHistory F`, and stability
is `∀ σ : WorldHistory F, τ.state t = σ.state t → …`. The audit found no consumer that needed
truth at a non-total history.

## What Changed

- `FormalSystem/Semantics/PartialHistory.lean` — new `WorldHistory` with this API: `CoeOut`,
  `state`, `@[simp] states_eq_state`, `@[ext] ext`, `ext_state` (a world history is determined
  by its states), `state_congr`, `ofTotal`, `@[simp] ofTotal_state`, `timeShift`,
  `@[simp] timeShift_state`. Removed: `TaskFrame.HF`, `FrameOver.HF`. The module docstring's
  paper/Lean table was rewritten.
- `Semantics/{TruthClauses,Truth,ValidityLayer,TruthTransport,Validity,IntTransfer}.lean` — the
  truth core, restated over world histories:
  - `StabClause.sameState` was deleted.
  - `Truth.atom_iff` (`Iff.rfl`) replaces `atom_iff_of_domain`; `atom_false_of_not_domain` was
    deleted.
  - `TruthCorr` fields are now `fwd`/`bwd` and pointwise on states. `ShiftRel` is a state
    equation. `timeShift_preserves_truth_total` was deleted.
  - `box_const`/`box_time_const` lost their totality arguments.
  - `IntTransfer` gained `WorldHistory.map`/`comap`; `Aligned` is now a pointwise `def`.
- Identity binder-shape adapters were deleted: `*.of_forall_total`, `*.apply_total` and `*.of_not`
  for every frame-predicate or frame-class notion, plus `validOn_iff_total` and
  `genericValidOn_iff_total`. Only the `.Base` adapters survive, renamed to
  `Valid/GenericValid/MinusValid/PlusValid/StarValid.of_forall`, `.apply`, `.of_not`, and
  `SemanticConsequence.of_forall`/`.apply`.
- Minus/Plus/Star language layers:
  - `SameStateAt` and its whole API were deleted, along with `timeShift_isTotal'`,
    `shift_neg_shift_*`, `states_congr`, `paste_isTotal` and `natHist_isTotal`.
  - `stab_congr_sameState` became `stab_congr_state`.
  - `truth_congr_ext` and `star_truth_congr_ext` now take a pointwise state hypothesis.
  - `paste`, `AgreeFrom`/`AgreeUpTo`, `IsPlusStateLocal`/`IsStateLocal`,
    `states_eq_of_deterministic` and `SingletonClasses` are all restated with state equations.
- `ShiftSet.lean`:
  - `hist` is a `WorldHistory`.
  - `wh_ext` and `hist_isTotal` were deleted in favour of `WorldHistory.ext_state`.
  - `total_eq_orbit`, `ts_zero` and `ts_add` are restated over `WorldHistory`.
- `Correspondence/*`: `translationHist`/`permissiveHist` are themselves world histories (the
  Phase 1 wrappers were removed). `FwdRec`, `FwdRecBridge` and `FwdRecPeriodicity` are restated
  with `state`.
- Metalogic consumers, migrated in subagent waves against the shared contract in
  `scratch/migration-brief.md`:
  - Soundness, SoundnessLemmas, SetConsequence, StrongCompleteness, Compactness, and
    Dedekind/DiscreteNonCompactness;
  - Algebraic (`multiFamHistoryGen`/`bundleFlowHistory` return `WorldHistory`; the set equalities
    became `Set.univ = Set.range …`);
  - Decidability (BiLasso, Verified bridge, Decidable, Tableau, …), BXCanonical, WeakCanonical,
    Conservativity, Independence (including `CTruthAt`) and Deterministic;
  - Automation/PrefilterSoundness, Examples, and Tests (including `ToyTruthAt`).
- Prose:
  - `docs/architecture/total-history-validity-decisions.md` records **Decision A'** and marks
    Decision A, its accepted atom-clause gap, and B''s deferred alternative as superseded.
  - Also updated: `docs/user-guide/{tutorial,architecture,INTEGRATION}.md`,
    `docs/reference/{API_REFERENCE,operators,paper-definitions-of-record}.md`,
    `docs/development/{LEAN_STYLE_GUIDE,DIRECTORY_README_STANDARD}.md`, `docs/theorem-index.md`,
    `README.md`, `typst/chapters/02-semantics.typ`, the directory READMEs, and the generated
    inventory blocks.
- 128 Lean files changed in total (+3041/−4207 lines).

## Decisions

- `WorldHistory` is a `def` (not an `abbrev`) living in `PartialHistory.lean`. `PartialHistory` and
  `IsTotal` are unchanged.
- I added `WorldHistory.ext_state` (`propext` + funext). It replaced three local extensionality
  copies (ShiftSet `wh_ext`, RegionFrame `partialHistory_ext`, and ad-hoc domain/states transport
  in the time-shift proofs).
- The frame-predicate and frame-class adapters were deleted rather than renamed, because they were
  identities once the binder is bundled; `intro` and function application open the definitions
  directly.
- The lemmas `truth_congr_ext`/`star_truth_congr_ext` keep their structural inductions (not
  `ext_state` + `subst`), so the axiom footprints stay unchanged.

## Plan Deviations

- **Phase 1** altered: I did not create a task branch. Nothing else was running in the tree, so
  batch Phases 2–9 stayed uncommitted on main, with `git-snapshot.sh --no-revert` snapshots, and
  landed as one green commit.
- **Phase 2** altered: all identity adapters were deleted and only the `.Base` ones kept.
  `TruthCorr.total_fwd/total_bwd` were renamed to `fwd/bwd`. I added `WorldHistory.ext_state`.
- **Phase 3** altered: `IntTransfer.isTotal_map` was deleted. The Phase 1
  `translationWorldHistory`/`permissiveWorldHistory` wrappers were folded back into
  `translationHist`/`permissiveHist`.
- **Phases 5–9** altered: the consumer directories were migrated by parallel subagent waves over
  disjoint directories, not phase by phase. The waves were (1) Metalogic core + Algebraic +
  Automation and Decidability; (2) BX/WeakCanonical, Conservativity, and Independence; then
  (3) Deterministic, Examples, and Tests.
- **Phase 9** dead-lemma sweep: `WorldHistory.ofTotal_val`, `timeShift_val` and
  `timeShift_neg_timeShift` were deleted as unused. I kept the pre-existing `PartialHistory`
  simp lemmas `ofTotal_domain`/`ofTotal_states` (now unused) because changing `PartialHistory`
  is a non-goal.
- **Phase 10**: the docs were edited during the batch and land in a separate phase-10 commit.

## Verification

- Build: Success. Full `lake build FormalSystem BimodalTest` passes with the guard, detached.
- Sorry count: 0 (C3, Boneyard excluded).
- Vacuous count: 0
- Axiom count: 0 real `axiom` declarations, unchanged. C2 flagship axiom sets and every C14 pinned
  declaration match the baseline.
  - `timeShift_preserves_truth` and `truthAt_of_truthCorr` are `[propext, Quot.sound]`.
  - `plusValidIn_ofFormula_iff` is `[propext]`.
- `scripts/check-module-invariants.sh`: the full run passed everything except C5, INV and C20,
  and all three were then fixed:
  - C5: a theorem-index module-shaped name;
  - INV: generated inventory blocks, regenerated with `--emit-inventory`;
  - C20: a stale `Decidable.lean:274` citation, replaced by a section name.
  - A final `--no-build` re-run passes with no failures, and a final full build passes.
- Acceptance greps (outside Boneyard) are all empty: `.IsTotal →`/`.IsTotal ∧`,
  `∃ (ht : τ.domain t)`, `\bHF\b`, `SameStateAt`.
- `check-paper-definitions.sh`: no new failures (`thm:M5-valid` was already unresolved before this
  work).
- `typst compile typst/BimodalReference.typ` succeeds.
- Files verified: Yes

## Impacts

- Downstream proofs use `τ.state t`, with no domain proofs anywhere in truth or validity.
- The talk slides ("Semantics in Lean II", "Syntax and Semantics", "Perpetuity, Twice") match the
  final names character for character: `WorldHistory`, `WorldHistory.state`, the `TruthAt` atom,
  box and stab clauses, and `timeShift_preserves_truth (σ : WorldHistory F)` with `σ.timeShift`.
  One caveat remains, as before: the slide shows the `stab` clause inside `TruthAt`, while in Lean
  it belongs to `PlusTruthAt`/`StarTruthAt`.

## Follow-ups

- `PartialHistory.ofTotal_domain`/`ofTotal_states` and `PartialHistory.trivialFrameHistory` are
  now unused or only used through hand-built pairs, so they could be pruned later.

## References

- specs/602_bundle_semantics_over_worldhistory/plans/01_bundle-semantics-worldhistory.md
- specs/602_bundle_semantics_over_worldhistory/reports/01_bundle-semantics-worldhistory.md
- specs/602_bundle_semantics_over_worldhistory/scratch/migration-brief.md
- docs/architecture/total-history-validity-decisions.md (Decision A')
