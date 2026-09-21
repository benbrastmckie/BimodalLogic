# Implementation Summary: Task #625

- **Task**: 625 - Formalize the manuscript's open-future and open-past modalities and machine-check that the stability modal is NOT Ockhamist historical necessity while the open-future modality is
- **Status**: [COMPLETED]
- **Started**: 2026-09-21T20:23:57Z
- **Completed**: 2026-09-21T21:02:42Z
- **Effort**: about 35 minutes of wall time against a 12.5 hour estimate (the two research probes compiled almost unchanged against the live tree)
- **Dependencies**: None
- **Artifacts**: plans/01_open-future-open-past-modalities.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

A fifth object language, L^▷ = L⁺ plus the open-future modal `▷` and the open-past modal `◁`, is
landed as the self-contained, semantic-only component `FormalSystem/OpenLanguage/`. All 31 theorems
of the plan's `## Lean Challenge Statements` are proved sorry-free with the recorded signatures:
the Ockhamist principle `Pα → ▷P▷̂α` is valid over every task frame, while its stability
transposition `Pp → ⊡P⟐p` is refuted on a three-state integer-time frame that satisfies every field
of `FrameOver`.

**Closure.** All eight phases are `[COMPLETED]`. Phase 8 was first recorded `[PARTIAL]` for one
residual item, a commit rather than work: the repository-root `README.md` held this task's edits
together with hunks authored outside the run, and the commit script commits whole paths, so it was
left unstaged. It was subsequently committed whole at the author's explicit direction as 75a3baca8,
whose message names the outside hunks it carries. A closing dispatch confirmed the file is clean,
confirmed `HEAD:README.md` carries this task's five edits, and re-ran the final verification.

## What Changed

- `FormalSystem/OpenLanguage/OpenClasses.lean` — created. `stabClass`, `openFutureClass`,
  `openPastClass`; `sameState_equivalence`, `agreeUpTo_equivalence`, `agreeFrom_equivalence`;
  the two inclusions and `stabClass_subset_univ`; `openFutureClass_inter_openPastClass`;
  `openFutureClass_anti`, `openPastClass_mono`; `paste_mem_openFutureClass_inter_openPastClass`.
  Reuses `AgreeUpTo` / `AgreeFrom` / `paste` from `PlusLanguage/PlusPasting.lean`; nothing redefined
- `FormalSystem/OpenLanguage/Formula.lean` — created, layer 0, one import. `OpenFormula` (nine
  constructors), derived operators with `PlusFormula`'s right-hand sides, `dofut`, `dopast`,
  `reflectTime` (exchanges `ofut`/`opast`), `reflect_time_involution`, `ofPlus`,
  `ofPlus_injective`, `ofPlus_reflectTime`, thirteen `rfl` pins
- `FormalSystem/OpenLanguage/OpenTruth.lean` — created. `OpenTruthAt`; `TruthEnv` and
  `StabClauses` instances with every field `Iff.rfl` / `fun h => h`; clause lemmas including
  `ofut_iff`, `opast_iff`, `dofut_iff`, `dopast_iff`; `openTruthAt_ofPlus`; pointwise S5 for each
  operator and the pointwise ordering
- `FormalSystem/OpenLanguage/OpenValidity.lean` — created. `TaskFrame.OpenValidOn`,
  `OpenValidOnFrames`, `OpenValidIn`, `OpenValid` (own `def`s); conservativity over L⁺ at frame,
  predicate, class and Base; S5 and the ordering as validities
- `FormalSystem/OpenLanguage/OpenReversal.lean` — created. `FrameOver.rev` with all four frame
  axioms, `TaskFrame.rev`, `TaskModel.rev`, `WorldHistory.rev`; three `rev_rev` by `rfl`;
  `rev_rev_hist`, `rev_surjective`; the three class swaps; `openTruthAt_rev`;
  `openValidOn_rev_iff`; **`openValid_reflectTime` proved**, so the plan's hand-mirror fallback was
  not needed
- `FormalSystem/OpenLanguage/OpenOckhamist.lean` — created. `hnOpen`, `hnOpenMixed`, `hnStab`;
  `hnOpen_openValid`, `hnOpenMixed_openValid`; `SinkState`, `sinkFrame` (via `FrameOver.ofStep`),
  `sinkHistA`, `sinkHistB`, `sinkModel`; `hnStab_refuted_sinkFrame`, `not_openValid_hnStab`,
  `not_plusValid_hnStab`; the mirror (`hnOpenMirror_openValid`, `openValid_hnOpenPast`,
  `not_openValid_hnStabMirror`); the five converse failures; five transferred L⁺ refutations
- `FormalSystem/OpenLanguage.lean`, `FormalSystem/OpenLanguage/README.md` — created. Aggregator
  with decisions D1-D3 and the three manuscript operators without a formalization; README with the
  generated inventory and the full paper-label correspondence table
- `Tests/BimodalTest/Semantics/OpenLanguageAxiomTest.lean` — created, six `#guard_msgs` guards;
  `ValidityLayerTest.lean` gains `section LOpen` and `LOpenOperators`
- `scripts/check-module-invariants.sh` — four C14 pins in both lists;
  `scripts/measure-refactor-partitions.py` — `LANGUAGE_FILE_LAYERS["OpenLanguage"]` and the
  post-merge layering sentence; `scripts/check-metalogic-cycles.sh` — prose and failure message
- Documentation: `ORGANISATION.md`, `docs/ARCHITECTURE.md`, `docs/development/MODULE_INVARIANTS.md`,
  `docs/development/MODULE_ORGANIZATION.md`, `docs/README.md`, `docs/theorem-index.md` (new L^▷
  section), `docs/reference/paper-definitions-of-record.md` (rows `app:gluing`,
  `sub:RestrictedModalities`), `FormalSystem/README.md`, `FormalSystem/Semantics/README.md`,
  `FormalSystem/Semantics/Frames/README.md` (`sinkFrame`), `FormalSystem/StarLanguage/README.md`
- `FormalSystem.lean` — regenerated by `lake exe mk_all`, never hand-edited
- `README.md` (repository root) — the `OpenLanguage/` tree line, the "five object languages" heading
  and sentence, the `**L^▷**` table row, the mapping bullet and the regenerated totals; committed as
  75a3baca8 together with hunks authored outside the run (named in that commit's message)

Commits: 203619c1b, d50fd0fed, 69087ab43, 4d588a9d8, 71fb8fd25, 4d70aa21e, ba3034c09, a5c676b1e,
75a3baca8 (root `README.md`).

## Decisions

- **Measured axiom profiles were pinned, not the plan's expectation.** The plan guessed
  `hnOpen_openValid` would be `[propext]`-class. It is `[propext, Classical.choice, Quot.sound]`,
  because `dofut_iff` uses `by_contra` exactly as the inherited `dstab_iff` does. All four C14 pins
  and all six test guards carry measured values; `openValid_ofPlus_iff` is `[propext]`
- **`TaskFrame.rev` is `@[reducible] def`**, so `F.rev.Duration` reduces to `F.Duration` for
  instance synthesis; `openTruthAt_rev` then needed no transport
- **Statement fidelity was checked by compilation, not by name.** A scratch file restates all 31
  challenge statements verbatim and closes each with `exact <library theorem>`, plus 13 `rfl`
  checks that the carriers have the challenge preamble's bodies: exit 0. The only differences from
  the challenge block are the two its own authoring note sanctions (`def` for `abbrev`;
  `TaskFrame.OpenValidOn` for the undotted form)
- **No challenge snapshot was created after the fact.** No `challenge/manifest.json` exists (the
  planner ran `--dry-run` only). A snapshot taken after implementation would pin statements to what
  was implemented, which defeats it
- **The `23 / 9 / 5 / 3` "one layer for all three directories" figures were left as a three-directory
  measurement.** Adding a fourth directory changes them and they were not re-measured; the verified
  per-layer counts (14 / 21 / 1) were updated
- **`Paper: — (reason)` on all four indexed theorems**, including `openValid_reflectTime`: the
  manuscript states `lem:time-reflection` for its base language only, so claiming the label for the
  L^▷ extension would overstate the source

## Plan Deviations

- **Per-phase gate line** altered: the plan passed `-- FormalSystem` to the build guard, which
  exits 77 without building; through `tail` that reads as exit 0. Corrected to
  `-- build FormalSystem`. This was caught in Phase 1 by reading the output, before any phase closed
  on it
- **Phase 1, `app:gluing`** altered: the anchor had no row in the definitions record, so a
  `LIVE-UNPINNED` row was added in Phase 1, before the citation, as C15 requires (planned for
  Phase 8 only)
- **Phase 1, inventory step** altered: the emitter also rewrites the root `README.md` totals; that
  file carried foreign hunks and was left unstaged from Phase 1 onward
- **Phase 5, optional `Equiv` packaging** not built: the bijection is carried by
  `WorldHistory.rev_rev_hist` and `WorldHistory.rev_surjective`, the form `openTruthAt_rev` consumes
- **Phase 6, `sinkFrame` census row** altered: the linked census is in the docstring of
  `Semantics/Frames/Standard.lean`, not in the README the plan named. Editing an existing Lean
  module is a plan non-goal, so the row went into the README under a new subsection
- **Phase 7, `rfl` unfolding of `hnOpenMirror`** altered: it unfolds to `Fα' → ◁F◁̂α'` at
  `α' := α.reflectTime`; the instance at arbitrary `α` is the added corollary
  `openValid_hnOpenPast`. Additive; nothing planned was dropped or restated
- **Phase 8, listing sweep** altered: `scripts/check-metalogic-cycles.sh` and `docs/README.md` were
  added by the scope-hypothesis rule; `PUBLICATION_REFACTOR.md` (historical) and
  `Syntax/README.md` (pre-existing stale text) matched and were left alone
- **Phase 8, root `README.md`** altered: committed separately and later than the rest of the sweep
  (75a3baca8), whole, at the author's direction, because it also carried hunks authored outside the
  run; Phase 8 stood `[PARTIAL]` until then

No deviation touched a `.lean` statement or the plan's lemma decomposition.

## Verification

- Build: Success. Full guarded `lake build` exit 0, 2674 jobs, genuine (no `REPLAY` marker);
  `lake build FormalSystem BimodalTest` exit 0, 2731 jobs. Every exit status was read from the
  guard itself (`PIPESTATUS` or a redirected file), never from a pipeline
- Sorry count: 0
- Vacuous count: 0 in the files this task created or modified. The prescribed single-line grep over
  all of `FormalSystem/` reports one match, `int_domain_universal` in
  `FormalSystem/Examples/TemporalStructures.lean`, dated 2025-12-04: a genuine `trivial` proof of a
  proposition that unfolds to `True`, not a placeholder, and not this task's
- Axiom count: 14 `^axiom ` declarations before the task and 14 after (12 under `FormalSystem/`, 2
  under `Tests/`); none introduced, none under `FormalSystem/OpenLanguage/`
- Closing re-run (after 75a3baca8): guarded full `lake build` exit 0, 2674 jobs, no `REPLAY` marker;
  sorry census 0; no `.lean`, `lakefile.toml` or `lake-manifest.json` change landed between the
  first gated build and the closing one; the task-reference grep over deliverables prints nothing
- Tests: Passed. `OpenLanguageAxiomTest` and `ValidityLayerTest` build; all `#guard_msgs` hold
- Files verified: Yes. `check-module-invariants.sh` with build exit 0, 49 PASS / 0 FAIL (C14 with
  the four new pins, C15 anchors and all 80 index rows, C28 zero warnings, C33 generated root);
  `check-metalogic-cycles.sh` exit 0, allowlist unchanged, assertion C at 14 syntax modules;
  `mk_all --check` clean; zero warnings under `FormalSystem/OpenLanguage`
- Plan compliance: passed. 31/31 challenge identifiers present and statement-faithful
- Comparator: not run (`compare_flag` unset); no `comparator` block recorded
- Note on the prescribed commands: the agent's verification snippets scan `Theories/`, which does
  not exist here. Run as written they scan nothing and report a vacuous zero, so they were pointed
  at `FormalSystem/` and `Tests/`

## Impacts

- The distinction two research rounds of the TM⋆ completeness programme got wrong is now a pair of
  library theorems: arguments that rely on shared pasts transfer to `▷` and not to `⊡`
- `FrameOver.rev` and `openValid_reflectTime` give a semantic time-reversal that transports clauses
  quantifying over a *class* of histories, which `TruthAntiIso` cannot
- `sinkFrame` is a reusable finite frame with every `FrameOver` field discharged
- A new language directory now has a worked precedent for the post-merge layering rule

## Follow-ups

- The prose figure "105 pinned declarations" (`FormalSystem/MainResults.lean`, root `README.md`, a
  script comment) was already stale before this task: 4 + 114 = 118 then, 122 now
- `FormalSystem/Semantics.lean` and `Semantics/TruthClauses.lean` docstrings say "all four object
  languages"; there are five. Existing modules, deliberately untouched
- `FormalSystem/Syntax/README.md` still describes language subdirectories the merge removed
- The task's `file_scope` in `specs/state.json` still names `FormalSystem/Semantics/OpenLanguage*`
- Commit 203619c1b (Phase 1) lacks the attribution trailers; not amended because other agents
  commit to `main` concurrently (tasks 647 and 648 landed between this task's phases)
- Promotion criteria for the comparator gate, should it be wired in: N consecutive `verified` runs
  across M distinct projects with zero `comparator_unavailable` or preflight-sourced verdicts, and a
  measured p95 runtime under an agreed budget. This run contributes no data point

## References

- `specs/625_formalize_open_future_open_past_modalities/plans/01_open-future-open-past-modalities.md`
- `specs/625_formalize_open_future_open_past_modalities/reports/01_open-future-open-past-modalities.md`
- `specs/625_formalize_open_future_open_past_modalities/probes/01_sink-frame-hn-refutation.lean`,
  `probes/02_frame-reversal.lean`
- `specs/625_formalize_open_future_open_past_modalities/handoffs/` — one handoff per phase
