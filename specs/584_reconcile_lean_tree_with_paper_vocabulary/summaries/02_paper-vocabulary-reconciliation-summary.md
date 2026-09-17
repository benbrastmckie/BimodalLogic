# Implementation Summary: Task #584

- **Task**: 584 - Reconcile the Lean tree with the paper's renamed vocabulary and re-pin the record
- **Status**: [COMPLETED]
- **Started**: 2026-09-17T08:10:31Z
- **Completed**: 2026-09-17T09:30:00Z
- **Effort**: ~1.3 hours
- **Dependencies**: 595, 583, 601 (all done)
- **Artifacts**: plans/02_paper-vocabulary-reconciliation.md, rename-map.tsv, prose-ledger.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`check-paper-definitions.sh` went from case (c), exit 1, to case (a), exit 0. The work re-quoted 14 drifted anchors, retired `thm:M5-valid`, carried out the user-chosen full TD -> TR rename (identifiers and prose, with recorded carve-outs), adopted the Some/All Past/Future labels, closed the constructor naming audit, re-pinned the record, and wired the check into CI through a new skip-and-report-neutral path.

## What Changed

- `docs/reference/paper-definitions-of-record.md`: 14 anchors re-quoted and re-hashed through `--resolve`. `thm:M5-valid` is now DANGLING (manifest row removed, KNOWN-ANCHORS row added). New section "Drift correction and rename absorption (2026-09-17)" records every decision and carve-out. Re-pinned to PINNED_COMMIT `a166fcbf`, FILE_CHECKSUM `b4e45e2c...`, LINE_COUNT 4529, with provenance rows. The invocation section was rewritten for CI.
- Lean identifier rename in 81 files under `FormalSystem/` (Boneyard excluded) and `Tests/`, 1,466 occurrences: `swapTemporal`->`reflectTime`, `swap_temporal_*`->`reflect_time_*`, `temporal_duality`->`time_reflection`, `TemporalDuality`->`TimeReflection`, `temporalDuality`->`timeReflection`. The challenge-pinned theorems `Formula.reflect_time_involution`, `PlusFormula.reflect_time_involution` and `StarFormula.reflect_time_involution` exist and build.
- Wire-tag strings `"temporal_duality"` and `"temporalDualityCount"` kept byte-stable, each with a comment. `MachineAppendixMain.lean`'s name and conclusion follow the rename, and `typst/generated/machine-appendix.{jsonl,typ}` was regenerated.
- Prose: 187 rule-sense lines renamed (TD -> TR, "temporal duality" -> "time reflection") across Lean docstrings, READMEs, `docs/`, `typst/` and `latex/`. 28 lines kept, each classified in `prose-ledger.md`.
- `FormalSystem/Syntax/Formula.lean`: the `reflectTime` docstring now says it swaps `untl`/`snce`, and F/P/G/H carry the Some/All Future/Past labels. `docs/user-guide/quickstart.md` lost the nonexistent `φ.past`/`φ.future`, and `docs/reference/operators.md` was relabelled.
- `FormalSystem/Syntax/MinusLanguage/Axioms.lean`: TM⁻ is no longer attributed to the paper, and the audit note is closed with a pointer to the new `docs/reference/axiom-reference.md` § Paper Key Correspondence table.
- `typst/FormalFoundations.typ` and `typst/chapters/03-proof-theory.typ`: 7 "smallest extension" sites reworded to "extends ... to include". Also corrected the remark claiming "no TR rule" and a count mismatch, plus the dependent "conjecture" sentence.
- `scripts/check-paper-definitions.sh`: when the paper is absent (and neither `--against` nor `--resolve` is given) it prints `SKIP (neutral): ...` and exits 0. Header exit codes updated.
- `.github/workflows/ci.yml`: new `Check paper definitions (scripts/check-paper-definitions.sh)` step before "Report results". `docs/development/CI_CD_PROCESS.md` gains a Runtime Budget row, and the non-conforming paragraph was replaced.

## Decisions

- Rename 1 (reflection convention): already adopted, regression-checked only.
- Rename 2 (TD -> TR): full rename per user option A with the plan's default names. Carve-outs: operator duality (including `section TemporalDuality` in `Theorems/TemporalDerived.lean`, which the ledger showed is F/G dual lemmas), `lem:temporal-duality` lemma-sense prose, wire tags, `swapUS`/`swapMinus`/`truth_swap`/`*_swap_valid*`, Boneyard, and benchmark output labels.
- Rename 3 (Some/All Past/Future labels): adopted.
- Naming audit closed as "same system, explicit mirrors" (textual, not machine-checked).

## Plan Deviations

- **Phase 2** altered: backticked identifier mentions in docs/READMEs were renamed in the atomic batch. `scripts/swap_untl_snce.py` pattern data was kept. `status.typ` needed no regeneration.
- **Phase 3** altered: landed as one commit. Also reverted Phase 2's `section TimeReflection` in `TemporalDerived.lean` back to `TemporalDuality`, since it is an operator-duality carve-out.
- **Phase 4** altered: quickstart constructor table now lists `untl`/`snce`. P/G/F were relabelled as well as H. The dependent `FormalFoundations.typ` "conjecture" sentence was reworded.
- **Phase 5** altered: "converse convention" appears 3 times in the record, all as history or regression-gate prose.
- **Phase 6** altered: the non-conforming paragraph was replaced with a reference-implementation sentence rather than deleted outright. The record's invocation section was also updated.

## Impacts

- Every downstream consumer of the renamed Lean API (`reflectTime`, `time_reflection`, `reflect_time_*`) must use the new names. No deprecated aliases were added.
- The dataset/JSON wire format is unchanged.
- CI now keeps the record parseable. The drift check itself still runs only where the paper is present.
- Several docs files that carried my Phase 2 renames were swept into concurrent tasks' commits (590/578/586). The renames are landed, just attributed to those commits.

## Follow-ups

- Fold the `def:BX` Burgess/Xu provenance into `ProofSystem/Axioms.lean`. First reconcile the A7a-vs-CN caution recorded in the record.
- Add a machine-checked paper-keyed `derivable_iff` equivalence for the BX layer.
- Resync `typst/FormalFoundations.typ` in full (it still uses TB/TA, `TM^+_f`, etc.).
- Optional: rename the `swapUS`/`swapMinus`/`truth_swap`/`*_swap_valid*` families.
- Pre-existing, not caused by this task: `check-evidence-probes.sh` fails 4/4 on `ConvexHistory`/`FrameOver.ofReflective` drift. During Phase 2, `typst-sync-check.sh` showed a transient `lakefile.toml` violation from the concurrent lakefile migration; it was clean (0 violations) by Phase 4.

## Verification

- Build: Success. Full `lake build` green after the last Lean edit (Phase 4). All 13 `lean_exe` roots and `BimodalTest` built after Phase 2, and C25 (full invariants, Phase 5) re-confirmed all 13 roots compile. `lake test` green.
- `bash scripts/check-paper-definitions.sh`: case (a), exit 0. Exit-path tests: paper absent SKIP exit 0; record absent exit 2; `--resolve` with paper absent exit 2; `--against` with paper absent exit 2; live run exit 0.
- Full `bash scripts/check-module-invariants.sh`: ALL CHECKS PASSED. C2 and C14 baselines unchanged, C15 resolves all 58 paper-anchor citations, C25 all 13 exe roots compile.
- `typst-sync-check.sh` 0 violations, `readme-lint.sh` PASS, copyright headers (strict) exit 0, CI YAML parses.
- Sorry count: unchanged (336 comment-inclusive `sorry` token lines in non-Boneyard FormalSystem before and after; the rename introduced none). Vacuous count: 0 new (the single grep hit, `int_domain_universal := trivial`, is pre-existing). Axiom count: 14 before and after.
- Residual identifier grep: clean except the enumerated wire-tag literals and their comments.

## References

- specs/584_reconcile_lean_tree_with_paper_vocabulary/plans/02_paper-vocabulary-reconciliation.md
- specs/584_reconcile_lean_tree_with_paper_vocabulary/reports/02_paper-vocabulary-decisions.md
- specs/584_reconcile_lean_tree_with_paper_vocabulary/rename-map.tsv
- specs/584_reconcile_lean_tree_with_paper_vocabulary/prose-ledger.md
- docs/reference/paper-definitions-of-record.md
