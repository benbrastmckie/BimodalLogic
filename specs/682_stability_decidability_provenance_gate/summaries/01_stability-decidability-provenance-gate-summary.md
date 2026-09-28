# Implementation Summary: Task #682

- **Task**: 682 - Stability decidability provenance gate
- **Status**: [COMPLETED]
- **Started**: 2026-09-27
- **Completed**: 2026-09-27
- **Effort**: ~3 hours
- **Dependencies**: None
- **Artifacts**: plans/01_stability-decidability-provenance-gate.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The task's own deliverable — the three-verdict provenance report — was already written and linked
before this dispatch. What this dispatch executed is the follow-through the report's
Recommendations section hands on, restricted to the four recommendations that fall inside the
task's scope constraint (no changes to `FormalSystem/` or `Tests/`). The spine is the bit-rot
finding: the archived evidence probe that five sites under `FormalSystem/Metalogic/Decidability/`
cite as a machine-checked refutation had silently stopped elaborating and was measuring `sorryAx`.
That probe is now repaired, guarded against recurrence, and the provenance findings are recorded in
the durable documentation store.

All five plan phases completed. No file under `FormalSystem/` or `Tests/` was modified.

## What Changed

- `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean` —
  one-term repair in `not_validZTime_neg_psi`: the bare witness `TaskFrame.isZTime_of_instances _`
  became the pair `⟨S.frame_isRegular, TaskFrame.isZTime_of_instances _⟩`. The probe predates
  `FrameClass.Sat .ZTime` becoming the conjunction `IsRegular ∧ IsZTime`
  (`Semantics/FrameClassValidity.lean`), so the single argument no longer had the expected type and
  elaboration failed with `synthInstanceFailed: SuccOrder (TaskFrame.Duration ?m).carrier`. Header
  docstring corrected (it still named the pre-archive compile-check path) and a drift note added
  recording the cause, the repair, and the re-verified axiom list.
  - Theorems re-verified sorry-free: `shiftTruth_psi`, `not_validZTime_neg_psi`,
    `no_presentation_sat`, `no_presentation_satAtState`, `fmp_false`.
  - `#print axioms fmp_false` now reads `[propext, Classical.choice, Quot.sound]`. Before the
    repair it read `[propext, sorryAx, Classical.choice, Quot.sound]`.
  - The statement of `fmp_false` is byte-identical before and after: what is refuted is unchanged.
- `scripts/check-evidence-probes.sh` — new additive `WIRED_REPO` entry form accepting a
  repository-relative probe path alongside the existing `specs/evidence/`-relative `WIRED` entries.
  Both forms now route through one `check_probe` function; the totals line counts both arrays. The
  repaired probe is wired as the first `WIRED_REPO` entry, with a table row naming the decision it
  holds in place and a note recording why it is not yet under `specs/evidence/`.
- `specs/literature-index.json` — new entry `thomas_1997_languages_automata` (the held source for
  Thomas Thm. 6.20, the countable-branching sentence, and Thm. 6.18), with a `citation_rule`
  mandating citation by theorem number and section and recording the conversion's cosmetic ligature
  drop. The existing `thomas_1997` entry's `hazard` now opens by naming its own file and states
  explicitly that the hazard does not attach to the new id. `updated` bumped to 2026-09-27.
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/decidability-provenance.md`
  — new source-store note (116 lines): the citation licence and its limits, the frame-class
  assumption's machine-checked/not-landed split, the finite-MODEL vs finite-PRESENTATION
  distinction, and the absence of any inherited complexity bound.
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/README.md` and
  `.../lean/index-entries.json` — the new note registered in the two places that enumerate context
  files individually.
- `/home/benjamin/.config/nvim/agent-system/extensions/literature/context/project/literature/domain/literature-index.md`
  — new subsection "Ids Are Matched Whole; Hazards Attach to Ids", with the two Thomas 1997 entries
  as the worked example; `.../literature/index-entries.json` line count and summary refreshed.

## Decisions

- **The repair uses `S.frame_isRegular` rather than `inferInstance`.** Both elaborate —
  `frame_isRegular` is declared as an `instance` in `Semantics/ShiftSet.lean` — and the in-tree
  idiom at e.g. `BiLasso/Assembly.lean:79` is `⟨inferInstance, …⟩`. The named form was chosen
  because it makes the probe self-documenting about *which* regularity fact discharges the new
  conjunct, and the drift note records the relationship to the in-tree idiom.
- **The guard gained a second entry form rather than the probe being moved.** The repository's own
  probe convention (stated in `check-evidence-probes.sh`'s header) wants probes under
  `specs/evidence/`. Three files cite this probe's archive path verbatim
  (`WitnessFamily/README.md:51`, `BiLasso/README.md:34`, `BiLasso/Assembly.lean:26`) and all three
  are outside this task's writable scope, so a move cannot be completed here. The new entry form is
  framed in the script as a deferred move with a named blocker, not as an exemption.
- **No commit was made in the source-store repository.** The source store
  (`/home/benjamin/.config/nvim`) already carried uncommitted work from other efforts, including a
  foreign registration of `sentence-translation-contract.md` inside the same
  `lean/index-entries.json` file this dispatch edited. Committing that file would have swept a
  sibling effort's in-flight work into this task's history. The edits are in place on disk; the
  source store is committed on its owner's own cadence.

## Plan Deviations

- **Phase 3, validation entry point** altered: no standalone sub-index validator exists in this
  deploy — the dangling-ref lint is reachable only as Job 1 of the interactive
  `/literature --rebuild` mode. The plan's own sanctioned fallback was used instead: a direct
  id-resolution check of all 77 sub-index `doc_id`s against `~/Projects/Literature/index.json`,
  which reported 0 unresolved.
- **Phase 4, manifest registration** altered: the lean extension's `manifest.json` enumerates
  `provides.context` by DIRECTORY (`project/lean4`, `contracts`), not by individual file, so a
  deploy already copies the new note and no manifest edit was needed. This confirms the alternative
  the plan's own Scope Hypothesis flagged. The note was registered instead in the two places that
  do enumerate files individually: `lean/index-entries.json` and
  `context/project/lean4/README.md`.
- Phase 2's Scope Hypothesis was confirmed as written: exactly one file changed, and the guard
  wired exactly five probes with one deliberately deferred before the edit (six wired after).

## Verification

- Build: **Success**. `lake-build-guard.sh build --timeout 1800 -- build`, detached, guard exit 0,
  "Build completed successfully (2741 jobs)", zero `error:` occurrences across both captured
  streams. No module under `FormalSystem/`, `Tests/`, or `BimodalTools/` was touched by this task,
  so no `.olean`-freshness check applies to any of this task's own files; the probe lives outside
  the build graph by construction.
- Sorry count: **0** (`lean-sorry-census.sh` over all eight resolved source roots; empty
  inventory).
- Vacuous count: **1, pre-existing and not introduced here**. The single hit is
  `FormalSystem/Examples/TemporalStructures.lean:495`,
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`, last touched by an
  unrelated effort. It is a false positive of the single-line grep heuristic: the universal
  history's `domain` genuinely reduces to `True`, so `trivial` is the honest proof, not a
  placeholder. This task modified no file under `FormalSystem/`.
- Axiom count: **14, unchanged**. No `FormalSystem/` or `Tests/` file was modified, so no axiom
  could have been added.
- Evidence probes: `bash scripts/check-evidence-probes.sh` exits 0 and reports
  "PASS all 6 wired probe(s) compile". Diffed line-for-line against the captured before-state: the
  five pre-existing entries still PASS, the deferred entry still SKIPs, exactly one line added and
  the total moved 5 -> 6.
- Guard negative test: with the guard temporarily repointed at a deliberately un-repaired scratch
  copy of the probe, the script exits **1** and names that probe with its `synthInstanceFailed`
  error and its `sorryAx`-carrying axiom line. The guard therefore guards. Restored immediately
  afterwards; the restored run is byte-identical to the post-edit run and the tree is clean.
- Tests: covered by the full `lake build` above (the test libraries are in its target set).
- Gate set: 8 of 9 gates green — `check-evidence-probes.sh`,
  `check-module-invariants.sh --no-build`, `check-copyright-headers.sh --strict`, `readme-lint.sh`,
  `check-metalogic-cycles.sh`, `check-paper-definitions.sh`, `lake exe mk_all --lib FormalSystem
  --check`, `lake exe lint-style` all exit 0.
- **One pre-existing gate failure, not attributable to this task**: `typst-sync-check.sh` exits 1 on
  its Check 2 (count freshness), reporting six stale counters in `typst/generated/status.typ`
  (`formalsystem-file-count` committed 537 vs live 575; line count 285608 vs 304046; and the
  analogous tests/ and tools/ pairs). `scripts/typst-status-counts.sh` counts `.lean` files under
  `FormalSystem/`, `Tests/`, and `BimodalTools/` only — none of which this task modified. The file
  was last regenerated 409 commits ago and is committed-and-stale rather than in-flight
  (`git status typst/` is empty). Checks 1, 2b, and 3 of that same gate pass. Regenerating
  `typst/generated/status.typ` is outside this plan's declared file scope and is recorded as a
  carried-forward item.
- Files verified: Yes. `git diff --stat` over this task's six commits names exactly four paths:
  `scripts/check-evidence-probes.sh`, the plan file, the probe, and `specs/literature-index.json`.
  No path under `FormalSystem/`, `Tests/`, or `.claude/`.
- Task-reference lint: `check-task-references.sh` reports 0 unexempted occurrences in both this
  repository and the source-store repository, including the new source-store files.

## Impacts

- The five sites under `FormalSystem/Metalogic/Decidability/` that cite `Probe476.fmp_false` as a
  machine-checked refutation are now telling the truth about the file on disk. Before this
  dispatch they were citing a probe that measured `sorryAx`.
- `scripts/check-evidence-probes.sh` can now guard a probe anywhere in the repository, not only
  inside `specs/evidence/`. This removes the structural reason a stranded probe goes unguarded.
- A reader matching "Thomas 1997" against the corpus sub-index can no longer pull the wrong
  fidelity verdict: the `no_source_pdf` hazard now names its own file and disclaims the sibling id,
  and the verified handbook chapter has its own entry with its own citation rule.
- Future lean and literature dispatches meet the citation licence and the finite-model /
  finite-presentation distinction through the normal context-discovery path, since both notes are
  registered in their extensions' `index-entries.json`.

## Follow-ups

- **The stability-modal carrier normalization.** Generalize the generic truth transport from the
  modal-only formula type to the stability-modal one, after which the integer-carrier normalization
  follows the existing proof line. Blocked here by the no-`FormalSystem/` constraint. Sized in the
  research report as a sorry-free target.
- **Redeploy the extension tree** (`bash .claude/scripts/deploy-headless.sh`) to pick up the two
  new source-store notes. Deliberately not run in this dispatch: the deployed tree was already
  flagged stale for three extensions, so a redeploy would land unrelated pending source-store
  changes across the whole tree while sibling implement dispatches were in flight on it.
- **Commit the source-store edits.** Left uncommitted because that repository carried foreign
  uncommitted work in the same files; see Decisions above.
- **Whether and how the downstream stability-modal design line should be started.** Already
  surfaced by the research dispatch as a non-blocking user decision with a recommendation
  ("construct a decision procedure", not "formalize a known-decidable target"). Not re-asked and
  not acted on here; no downstream tasks were created.
- **Move the probe into `specs/evidence/`.** Blocked by the three citation sites outside this
  task's writable scope. Note also that `.gitignore` excludes `specs/archive/`, so the probe
  survives in version control only because it was tracked before archival — staging a change to it
  requires `git add -u`, since a plain `git add` refuses an ignore-matching pathspec. That
  fragility is a further reason to complete the move.
- **Regenerate `typst/generated/status.typ`.** Pre-existing 409-commit drift causing the one red
  gate; outside this plan's file scope.
- **`FormalSystem/Metalogic/Decidability/README.md`** was not updated with the citation licence,
  for the same no-`FormalSystem/` reason. The licence lives only in the source-store note until
  that constraint lifts.

## References

- `specs/682_stability_decidability_provenance_gate/plans/01_stability-decidability-provenance-gate.md`
- `specs/682_stability_decidability_provenance_gate/reports/01_stability-decidability-provenance-gate.md`
- `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`
- `scripts/check-evidence-probes.sh`
- `specs/literature-index.json`
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/decidability-provenance.md`
- `/home/benjamin/.config/nvim/agent-system/extensions/literature/context/project/literature/domain/literature-index.md`
