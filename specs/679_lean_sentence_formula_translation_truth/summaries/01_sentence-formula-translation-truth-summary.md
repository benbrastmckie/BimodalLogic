# Implementation Summary: Task #679

- **Task**: 679 - Lean Sentence-to-Formula translation, proved truth-preserving
- **Status**: [COMPLETED]
- **Started**: 2026-09-27T11:15:00Z
- **Completed**: 2026-09-27T13:10:00Z
- **Effort**: ~2 hours
- **Dependencies**: None
- **Artifacts**: plans/01_sentence-formula-translation-truth.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

A new `FormalSystem/SourceLanguage/` component defines the consuming repository's source sentence
AST (all seventeen operators plus atoms), its elimination `tr` into this repository's six `Formula`
primitives, and a native source-side truth evaluation `Sat`; `sat_iff` proves the two agree at every
frame, model, world history and time, stated against `Semantics.TruthAt` itself rather than against a
second transcription of the semantics. A JSON codec, a `translate_sentence` executable and a
committed 26-line fixture list expose the elimination mechanically, so the consuming repository can
diff its own translation against this verified one without reading Lean. No `sorry`, no new axiom, no
deferral.

The one substantive correction to the plan: `tr_injective` is **false**, and `tr_not_injective` — its
disproof — is delivered in its place.

## What Changed

New, under `FormalSystem/`:

- `FormalSystem/SourceLanguage/Sentence.lean` (321 lines) — `Sentence`, the 18-constructor source
  AST with a per-constructor docstring naming the consumer surface form and, for `untl`/`snce`, which
  operand is the guard; `tr : Sentence → Formula`, the elimination; twelve `@[simp]` `rfl`
  push-through equations; `imp_imp_bot_bot_ne`; `tr_cond_ne`, `tr_someFut_ne`, `tr_somePast_ne` — the
  three rows that deliberately do not push through; `tr_not_injective`.
- `FormalSystem/SourceLanguage/SentenceTruth.lean` (253 lines) — `Sat`, the 18-clause native
  evaluation; `next_iff_covBy`, `prev_iff_covBy` (unconditional); `next_iff_succ`, `prev_iff_pred`
  (corollaries under `[SuccOrder] [NoMaxOrder]` / `[PredOrder] [NoMinOrder]`); `sat_iff`.
- `FormalSystem/SourceLanguage.lean` (79 lines) — the sibling aggregator, with the Module Invariant
  paragraph and the `grep` that checks it.
- `FormalSystem/SourceLanguage/README.md` (156 lines) — the 18-row elimination table, the
  non-push-through rows, the lossiness note, the `CovBy`-vs-`succ` caveat, the box-clause note, the
  conformance channel, and a "Not formalized" table.

New, tooling and tests:

- `BimodalTools/SentenceExport.lean` (244 lines) — `Sentence.toJson`, `pSentence`, `parseSentence`,
  `translateSentenceLineToJson`, `normalizeSentenceLineToJson`.
- `BimodalTools/TranslateSentenceMain.lean` (51 lines) — the `main`-only root of
  `lake exe translate_sentence`.
- `Tests/BimodalTest/Syntax/SentenceTranslationTest.lean` (156 lines, 33 `#guard` rows).
- `Tests/BimodalToolsTest/SentenceCodecTest.lean` (200 lines, 11 `#guard` rows over the fixture file,
  read with `include_str`).
- `Tests/fixtures/sentence-translation-fixtures.jsonl` (26 lines) and `Tests/fixtures/README.md`.

Edited: `FormalSystem.lean` (regenerated), `scripts/measure-refactor-partitions.py`
(`LANGUAGE_FILE_LAYERS` rows plus the count prose), `ORGANISATION.md`, `README.md`,
`FormalSystem/README.md`, `BimodalTools.lean`, `BimodalTools/README.md` (a new "Source-sentence
translation protocol" section), `lakefile.toml` (the `translate_sentence` `[[lean_exe]]`),
`Tests/BimodalTest.lean`, `Tests/BimodalToolsTest.lean`, and four test READMEs.

Outside this repository: the cross-repository contract was authored at
`<source_dir>/context/project/lean4/domain/sentence-translation-contract.md` (210 lines) under the
lean extension's source store resolved from `.claude-extensions.json`, with a matching
`index-entries.json` row. That store is a separate git repository and was **not** committed from
here.

## Decisions

- **`tr_injective` is false; `tr_not_injective` replaces it.** `tr (cond A B) = tr (vee (neg A) B)`
  by `rfl`, because the elimination sends each defined operator onto the very abbreviation it stands
  for; `top`/`neg bot`, `dia`/`neg (box (neg ·))` and the two existential tenses collide the same
  way. The `FormalSystem/MinusLanguage/Translation.lean` precedent does not transfer: that
  translation is primitive-to-primitive and same-name, this one collapses seventeen operators onto
  six. The consequence — a translated formula does not determine its source sentence, so the
  conformance channel is forward-only and no inverse pass is checkable — is recorded in the module
  docstring, the directory README and the contract context file.
- **`CovBy` is the theorem, `succ`/`pred` the corollaries**, per the plan and the research report.
  The dense-carrier reason is in the module docstring with the
  `Metalogic/DedekindNonCompactness.lean` citation.
- **The box clause is `TruthAt`'s** (all histories, same time), not the consumer evaluator's
  (all histories, all positions = `□△φ`). The extensional-equivalence-under-shift-closure note cites
  `Semantics/ShiftSet.lean` and `Semantics/TruthTransport.lean`.
- **The fixture file is generated, never hand-written**, so its canonical form is pinned to the two
  serializers rather than to an editor, and `SentenceCodecTest.lean` asserts exactly that by
  rebuilding each line and comparing bytes.
- **Scope honesty is stated, not implied.** Every module docstring says the theorem certifies the
  encoding and not the consumer's implementation, and does not discharge the consumer's obligation or
  license removing it. A grep for "discharges S4", "delete the obligation" and "no longer needed"
  returns 0.

## Plan Deviations

- **Phase 1, `tr_injective`** altered: the statement is false; `tr_not_injective` (its disproof) is
  delivered instead, with the reasoning recorded in three places. Annotated inline on the plan's
  checklist item.
- **Phase 4, fixture location** altered: the plan named `data/sentence-translation-fixtures.jsonl`,
  but `/data` is gitignored in its entirety (`.gitignore` line 107, with `data/*.jsonl` at line 68)
  and no file under `data/` is tracked — `data/README.md` included. A shared cross-repository
  artifact that cannot be obtained from git is not one, so the file was relocated to
  `Tests/fixtures/sentence-translation-fixtures.jsonl`, a tracked path beside its reader, rather than
  punching a hole in shared `.gitignore` config. Every reference was updated, including in the
  already-committed Phase 1 and 2 files, and `Tests/fixtures/README.md` records why the directory
  exists. Annotated inline on the plan's checklist item.
- **Phase 4, fixture count**: the plan's hypothesis was "17 + 3 entries"; 26 were delivered — 18
  constructor rows (the table has 18, not 17: `\bot` and the atom are rows too), 4 `Until`/`Since`
  argument-order rows (the plan asked for one; four covers both operators in both operand positions)
  and 4 nested rows. A superset, in the plan's own categories.
- **Phase 1 verification tier**: the plan listed a full `lake build` for Phase 1. A scoped
  `lake build FormalSystem.SourceLanguage FormalSystem.SourceLanguage.Sentence` was run instead, plus
  every script gate; the full build was run once after Phase 2 and again at the end, superseding it.
- **Commit labelling**: two consecutive commits carry the subject
  `task 679 phase 4: ...`. The first of them holds Phase 3's content plus most of Phase 4's, because
  a failed `git add` of the then-gitignored fixture path left files staged that a following
  `--amend` folded into the Phase 3 commit and relabelled. All content is committed and correct; the
  history was **not** rewritten, because three sibling dispatches were committing onto the same
  branch concurrently and a `reset --soft` across their commits was the more harmful option.
- Not deviations, but beyond the plan's declared lists: `imp_imp_bot_bot_ne` (the `sizeOf` workhorse
  `tr_cond_ne` needs), `normalizeSentenceLineToJson`, and `Tests/fixtures/README.md`.

## Verification

- Build: **green**. `lake build` — `Build completed successfully (2741 jobs)`, guard exit 0, zero
  errors, zero warnings. Non-default targets green too (4688 jobs). Detail below.
- Sorry count: 0 (`lean-sorry-census.sh` over every resolved source root; the baseline was also 0).
- Vacuous count: 0.
- Axiom count: 14, unchanged from the pre-work baseline — no `axiom` declaration was added.
- `#print axioms`, on every new result: `sat_iff`, `next_iff_succ`, `prev_iff_pred` →
  `propext, Classical.choice, Quot.sound`; `next_iff_covBy`, `prev_iff_covBy`, `tr_cond_ne` →
  `propext, Quot.sound`; `tr_someFut_ne`, `tr_somePast_ne`, `tr_not_injective` → none. Nothing
  outside the standard three.
- Tests: `lake build BimodalTest` and `lake build BimodalToolsTest` reached and built both new test
  modules green (`BimodalTest.Syntax.SentenceTranslationTest`,
  `BimodalToolsTest.SentenceCodecTest`), which is the assertion: a failing `#guard` is a build error.
- `lake exe translate_sentence` over **every** fixture line, comparing **parsed** JSON against the
  line's own `formula` field: 26 reproduced, 0 mismatches.
- Both embedded objects are byte-identical to `json.dumps(..., separators=(', ', ': '))` on all 26
  lines — a convenience for a Python consumer, documented as not a contract.
- `bash scripts/check-metalogic-cycles.sh`: all three assertions PASS, reporting 17
  language-directory syntax modules and 30 semantics modules — the figures the `ORGANISATION.md`
  prose was updated to.
- `python3 scripts/measure-refactor-partitions.py upward-edges`: no `UnlayeredModuleError`, the
  upward set still exactly the recorded 7 lines, 0 stale per-file rows.
- `lake exe checkInitImports`: clean (exit 0).
- `bash scripts/readme-lint.sh`: RESULT PASS — 0 missing READMEs, 0 broken file references. The one
  "MISSING DATE" it reports is `FormalSystem/Metalogic/ConvexConsequence/README.md`, pre-existing.
- `bash scripts/check-copyright-headers.sh`: 0 nonconforming, 0 missing, 0 duplicate.
- `git diff FormalSystem.lean` against the pre-work tree adds exactly the three expected import
  lines and nothing else.
- Docstring over-claim grep ("discharges S4", "delete the obligation", "no longer needed"): 0 hits.

### Non-vacuity controls — run, then reverted

These are recorded as executed, not asserted:

1. **`tr`'s `cond` row.** Changing the `#guard`'s expected image to `Formula.imp fp fq` produces
   `error: Expression tr (sp.cond sq) == fp.imp fq did not evaluate to 'true'`. Restored and
   re-checked clean.
2. **`Sat`'s argument order.** Swapping guard and event in `Sat`'s `untl` clause makes `sat_iff`
   **fail**, and fail precisely at the `untl` case with the two quantifier bodies exchanged. So the
   theorem does pin which operand is which — which is the residual hazard the dispatch's Revised
   Premise 1 names, now covered by proof rather than by a convention holding on both sides. Restored
   and re-checked clean.
3. **The fixture file.** Replacing the `\rightarrow` row's `formula` with the plain `Formula.imp`
   image fails two `SentenceCodecTest` rows (the translation row and the end-to-end row). Restored
   and re-checked clean.

### Full build (third run)

**Result**: Three full `lake build` runs were made. The first two each failed on **exactly one** module —
`FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.MonotoneIssuance`, then
`FormalSystem.Metalogic.Bundle.LimitMCSCoherence` — and in both cases with
`error: no such file or directory (error code: 4294967294)` naming the module's **own `.olean`
output path**, with no Lean diagnostic of any kind. That is a build-artifact race in
`.lake/build/`, not a proof or elaboration failure, and neither module is in this task's file set or
imports anything from it.

The cause was concurrent unguarded `lake build` invocations against the same `.lake/build` tree.
Part of it was **self-inflicted and is worth recording**: `scripts/check-module-invariants.sh` runs
its own `lake build` internally, *outside* the `lake-build-guard.sh` lock, so leaving that script
running in the background while a guarded full build proceeds guarantees this class of failure. The
tell is decisive: `MonotoneIssuance` — the module that failed the first run — **built green in
2.0 s** in the second run, and the previously-failing points were passed cleanly once nothing else
of this dispatch was building.

The third run was started with no other build of this dispatch in flight, and it is **green**:

```
Build completed successfully (2741 jobs).
lake-build-guard: STATUS: exit_status=0
```

Zero `error` lines and zero `warning` lines over both captured streams. A follow-up guarded build
of the three non-default targets and the new executable —
`lake build BimodalTools BimodalTest BimodalToolsTest translate_sentence`, which a bare
`lake build` does not cover — is likewise green: `Build completed successfully (4688 jobs)`, with
`BimodalToolsTest.SentenceCodecTest` and `BimodalTest.Syntax.SentenceTranslationTest` among the
modules built, so every `#guard` row in both test files passed inside a real library build and not
only under `lake env lean`.

That run surfaced one warning of this task's own — a 108-character line in
`BimodalTools/TranslateSentenceMain.lean`, lengthened by the fixture relocation. It was rewrapped
and the target rebuilt: `Build completed successfully (3712 jobs)`, `exit_status=0`, no warning.
**Zero warnings on every file this task adds.**

### `check-module-invariants.sh`

**Green, on the run made once the tree was quiet.** `PASS` on B0, B1, B2, B3, C1 (`lake build`
exits 0), C1 (`lake build BimodalTest` exits 0), C2, **C3 (structural `sorry` inventory is ZERO
across `FormalSystem/` and `BimodalTools/`)**, C4, C5, C6 (both rows), **C8 (every subdirectory has
its aggregator — the `FormalSystem/SourceLanguage.lean`-beside-`FormalSystem/SourceLanguage/`
convention)**, C9 (**zero task-number citations** under `FormalSystem/`, `lakefile.toml`,
`README.md`, `scripts/`), C10, C11, C12, C13, C14 (both rows), C15 (both rows), C16, C20 (all three
rows), and INV.

One finding had to be resolved rather than merely reported. The first run failed
`INV  2 file(s) carry a stale generated inventory block` on `README.md` and `FormalSystem/README.md`
— which was the direct consequence of this task having hand-set those two machine-owned blocks to
its *own* contribution rather than to the live-tree figures, to avoid folding a concurrent
dispatch's uncommitted work into them. That trade was wrong: the blocks are defined as live-tree
measurements and the gate checks exactly that, so a hand-set value is a guaranteed failure. They
were regenerated with `bash scripts/check-module-invariants.sh --emit-inventory`, the diff was
checked to touch only those two files, and
`bash scripts/check-module-invariants.sh --emit-inventory --check` now reports
`PASS  INV  every generated inventory block is current, every hand-maintained one is exhaustive`.

One caveat, stated rather than hidden: the regenerated totals count one concurrent dispatch's
**uncommitted** edit to `FormalSystem/Semantics/FrameConstraintIndependence.lean`, because the
figures measure the working tree. That self-heals on the next regeneration and no sibling source
hunk was staged.

**Two process lessons worth keeping**, both learned the hard way here:

1. `scripts/check-module-invariants.sh` runs its own `lake build` **outside** the
   `lake-build-guard.sh` lock. Never leave it running in the background while a guarded build
   proceeds — that combination, not any sibling, produced two of the three artifact races above.
2. A machine-owned generated block must be left machine-generated. Hand-setting one to sidestep a
   concurrency concern trades a self-healing inaccuracy for a hard gate failure.

## Impacts

- `FormalSystem/SourceLanguage/` is a seventh language directory at the library root and is
  registered in every mechanism that gates one: `LANGUAGE_FILE_LAYERS`, `ORGANISATION.md`'s layer
  table and per-file prose, the regenerated root aggregator, and four READMEs. A new file in it needs
  a `LANGUAGE_FILE_LAYERS` row or `check-metalogic-cycles.sh` fails.
- `lake exe translate_sentence` is a 14th executable target. Nothing in `FormalSystem/` depends on
  it; `BimodalTools` is outside `defaultTargets`.
- The consuming repository now has a mechanical, verified reference to validate its own elimination
  against: it asserts that its translation of each fixture line's `surface` serializes to that line's
  `formula`. That assertion belongs there and was deliberately **not** written from here.
- `Semantics.Truth`'s characterization family took the whole agreement proof with no new lemma, which
  confirms the research report's "assembly, not new mathematics" finding as measured rather than
  estimated.

## Follow-ups

- **The consumer-side assertion** is the natural next step and belongs in the ModelChecker
  repository, not here. What it consumes is `Tests/fixtures/sentence-translation-fixtures.jsonl` plus
  the "Source-sentence translation protocol" section of `BimodalTools/README.md`.
- **`Formula.next`/`prev` characterizations are duplicated** between
  `FormalSystem/SourceLanguage/SentenceTruth.lean` and
  `FormalSystem/Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff`. Consolidation means
  promoting a shared lemma into `FormalSystem/Semantics/Truth.lean`; importing `Metalogic` from this
  layer-1 module would be an upward edge. Recorded in the docstring, deliberately not done.
- **The consumer's `\top` defect** (its defined-operator expansion pass raises on the tag, so its own
  corpus excludes it) is now a visible mechanical diff rather than a silent hole, because the Lean
  side covers `\top` unconditionally and the fixture list includes it. Repairing the Python is out of
  scope and belongs there.
- **The extension source store** (`~/.config/nvim/agent-system/extensions/lean/`) carries the new
  context file and its `index-entries.json` row as uncommitted changes in its own repository. It also
  needs a redeploy: this repository's deployed `.claude/` tree was already flagged stale for the
  `core`, `lean` and `typst` extensions before this work, and the new file will not appear under
  `.claude/` until `bash .claude/scripts/deploy-headless.sh` runs.
- **The generated README blocks were regenerated** and INV passes; the one residual is that the
  totals count a concurrent dispatch's uncommitted `FormalSystem/Semantics/FrameConstraintIndependence.lean`
  edit, which self-heals on their next `--emit-inventory`. `FormalSystem/Metalogic/README.md` was left
  at HEAD and is a sibling's to refresh.
- **`lake test` was not invoked as such.** `lake build BimodalTest` — the test driver's own library —
  is green, and the invariants gate independently reports `PASS C1 lake build BimodalTest exits 0`.
  Running the `lake test` wrapper once is a cheap loose end.

## References

- `specs/679_lean_sentence_formula_translation_truth/plans/01_sentence-formula-translation-truth.md`
- `specs/679_lean_sentence_formula_translation_truth/reports/01_sentence-formula-translation-truth.md`
- `specs/679_lean_sentence_formula_translation_truth/handoffs/phase-{1..5}-handoff-*.md`
- `FormalSystem/SourceLanguage/README.md` — the elimination table and the component's caveats
- `BimodalTools/README.md` — the wire schema and the cross-repository hand-off contract
