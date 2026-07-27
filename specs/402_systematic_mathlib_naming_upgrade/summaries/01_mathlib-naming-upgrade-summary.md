# Implementation Summary: Systematic Mathlib Naming Upgrade

- **Task**: 402 - systematic_mathlib_naming_upgrade
- **Plan**: `plans/01_mathlib-naming-upgrade-migration.md`
- **Status**: COMPLETE — all 8 phases, definition of done met in full
- **Type**: lean4

## Definition of done, item by item

| Plan clause | Result |
|---|---|
| `lake build` green with no new errors | **GREEN**, 2,725 jobs |
| `BimodalTest` green | **GREEN** (inside the same 2,725) |
| Sole live `sorry` unchanged, located by content | **1**, `theorem countermodel_discrete`, `Metalogic/WeakCanonical/Transfer.lean` |
| `scripts/nolints.json` deleted | **deleted from the tree** (`git rm`, 860 entries) |
| `runLinter FormalSystem` -> `defsWithUnderscore = 0` | **0** |

Supplementary invariants: `scripts/check-module-invariants.sh` ALL CHECKS PASSED; all six
`Bimodal*` identifiers intact; **0** new axioms; **0** new `@[deprecated]` aliases.

## What changed

| Dimension | Change |
|---|---|
| Library location | `Theories/Bimodal/` -> `FormalSystem/`, root module `FormalSystem.lean` |
| Root namespace | `Bimodal` -> `FormalSystem` |
| Declaration names | **845 renamed**, 25,640 resolved-reference spans rewritten across 284 files |
| Tactic tokens | 11 internal-only renamed, 7 documented ones exempted in source |
| Non-elaborated text | 8,116 rewrites (7,300 in Lean comments/strings, 816 in docs) |
| `defsWithUnderscore` | **861 -> 0** |

## Verification, four layers

| Layer | What it proves | Result |
|---|---|---|
| 1 — Guard rejection report | prefix corruption is structurally impossible | **0 rejections**; self-test 128,083/128,317 = **99.8176%** exact suffix, five known buckets, no unknown bucket |
| 2 — Build | catches the `.ilean` coverage gap | green, 2,725 jobs; sorry = 1; module invariants pass |
| 3 — `runLinter`, suppression file absent | the only evidence for this category | `defsWithUnderscore` **0**; every sibling category unchanged **to the unit** |
| 4 — Residual-text sweep | what the build can never catch | 8,116 rewrites; re-sweep returns **4** hits, each deliberate and listed |

Layer 3 in full — the comparison is against `baseline/linter-unmasked.json`, produced by the same
`tools/runlinter.py`, because that tool breaks `LINTER FAILED` out of `simpNF` and its split is
not comparable to figures produced any other way:

| Category | Phase 1 unmasked | Final |
|---|---:|---:|
| `defsWithUnderscore` | 861 | **0** |
| `unusedArguments` | 124 | 124 |
| `LINTER FAILED` | 115 | 115 |
| `docBlame` | 39 | 39 |
| `tacticDocs` | 4 | 4 |
| `structureInType` | 1 | 1 |
| total | 1144 | **283** |

283 = 1144 − 861 exactly. No category regressed.

## Findings that changed the work

**The projected `.ilean` coverage gap was ~13x too pessimistic.** Research projected ~390 sites
(1.6%, Low confidence, extrapolated from one declaration). Measured: **30 sites, 0.117%** of the
25,640 rewritten spans. But they fell into five structural classes rather than one, and two
classes needed the fix-loop extended mid-run:

1. Intra-`structure` field references — a later field's *type* mentioning an earlier field carries
   no `.ilean` range (6 sites, `Semantics/TaskFrame.lean`).
2. `have ⟨pat⟩ : T := by` type ascriptions — the predicted class, at the predicted file (8 sites).
3. Dot-notation projections, reported as ``Invalid field `f`: the environment does not contain
   `FQN` `` — a different message shape, and the edit must anchor on the dot (4 sites).
4. Identifiers inside a `macro` syntax quotation — **reported at the USE site with a hygiene
   dagger** (`deduction_theorem✝`) while the defect is at the macro definition in another file, so
   a position-driven fixer edits the wrong place (1 site).
5. Plain unrecorded term references (11 sites).

**`lake build` alone does not build the project.** The default target is
`@[default_target] lean_lib FormalSystem`, whose glob is its root module's import closure. That
leaves **22 source files with no `.ilean` artifact at all** — including
`Automation/ProofStepExport.lean`, which the plan names as load-bearing. Those files are invisible
to both the rewriter *and* the build meant to catch what the rewriter missed, so a rename would
have broken them silently and greenly. Fixed by `tools/build-all.sh`, which adds `BimodalTest` and
all 12 `lean_exe` roots; the snapshot went from 269 to **329** `.ilean` files.

**`lake clean` with no argument deletes every package's build directory, Mathlib included.** The
plan's literal command would have discarded the entire dependency build. Scoped to
`lake clean Logos`.

**Mathlib does not camelCase its tactic tokens.** `macro "push_neg"` produces `tacticPush_neg`;
Mathlib escapes this very linter by whitelisting the `Mathlib.Tactic` *namespace prefix*
(`isBadNameWithUnderscore`), not by renaming. So renaming a tactic token to camelCase buys linter
conformance at the cost of surface conformance. The plan's rule was applied as written anyway —
11 internal-only tokens renamed — with the dissent recorded in `phase8-decision-record.md` so it
can be revisited deliberately.

**Two declarations were missing from the Phase 5.1/5.2 exclusion lists**, and only the linter
found them: the `tm_lemma` label attribute, and
`Separation.sNestingAboveU.S_nesting_above_U_inner` — excluded as a "parent-derived auxiliary" on
the theory that Lean regenerates such names from the parent's. **False for `where` helpers**:
renaming the parent moved only the namespace component. The two genuinely parent-derived
auxiliaries did follow, which is why the error was not symmetric.

**The tombstone-comment purge was the wrong instinct.** 81 "removed/archived/superseded" comments
measured; **zero deleted**. Reviewed individually, they record soundness results (`BX9/BX9'
removed -- unsound under open guard`), archival pointers to code that still exists, refuted
scaffolds, and import-cycle decisions. The plan required verifying before deleting; verification
overturned the premise.

**A mechanical sweep over a document about naming corrupts it.** Phase 7.2 left
`LEAN_STYLE_GUIDE.md` self-contradictory — an `-- Avoid` block listing `def TruthAt` directly
beneath a `-- Good` block containing the same text. Rewritten by hand in Phase 8.

## Plan Deviations

Every deviation is annotated inline on its checklist item in the plan. Summary:

| Phase | Deviation |
|---|---|
| 6.1 | `lake clean Logos` not bare `lake clean`; `build-all.sh` for full `.ilean` coverage; 2 orphan test modules permanently uncovered (**pre-existing breakage**, verified broken at HEAD before any edit) |
| 6.1 | 0 guard rejections, not the projected ~0.2% — the mismatching ranges all belong to declarations outside the rename map |
| 6.1 | Gap rate 30 sites / 0.117%, vs projected ~390 / 1.6% |
| 6.2 | `fixloop.py` extended three times mid-run (backtick message shape, `Invalid field` dot-notation, hygiene daggers) |
| 6.2 | 5 sub-staged commits, not 7 |
| 7.1 | Backtick sites enumerated exhaustively, not sampled; the 4 "unresolved" double-backticks no longer exist; `tm_lemma` deferred to Phase 8 |
| 7.1 | Tombstone purge: 0 of 81 deleted, with per-class justification |
| 7.1 | One sweep false positive reverted by hand (`lem:` paper label) |
| 7.2 | `bx_completeness` already absent from docs; the one live occurrence was in a Lean file and was fixed there, crossing the phase's territory contract |
| 7.2 | 178 pre-existing task-number citations **not** purged (0 introduced); `PIPELINE.md` uses "Task N" for ML-pipeline items, a different referent |
| 8 | Decision set was 20, not 19; two additions found only by the linter |
| 8 | `NAMING_CONVENTION_DEVIATION.md` superseded in place, not removed, to preserve the inbound link; `LEAN_STYLE_GUIDE.md` repaired |
| 8 | Boneyard note written as a section, not one line; stale `Bimodal` library name in the same file corrected |

## Recommended follow-ups

1. **Task-number citations in deliverables** — 178 across `docs/`/`typst/`/`latex/`/`README.md`
   and 112 across `Tests/`, all pre-existing, none introduced here. `check-module-invariants.sh`
   check C9 scopes its task-citation check to `FormalSystem/` only, which is why both trees
   escaped it. Note `docs/training/PIPELINE.md` uses "Task N" for ML-pipeline work items — a
   blanket purge would corrupt it.
2. **Two orphan test modules do not compile** —
   `Tests/BimodalTest/Semantics/SemanticBenchmark.lean` and
   `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`. Unreachable from any target root, so
   nothing builds them; broken before this task began.
3. **Make `build-all.sh` the project's build command.** A green `lake build` currently says
   nothing about 22 source files.
4. **Revisit the 11 renamed tactic tokens** if snake_case tokens are preferred; see the recorded
   dissent in `phase8-decision-record.md`.

## Artifacts

| Path | Contents |
|---|---|
| `tools/` | `ilean.py`, `rename.py`, `runlinter.py`, `derive_names.py`, `Classify.lean`, `leanmask.py`, `refcount.py`, `fixloop.py`, `prose_sweep.py`, `build-all.sh`, `check-sorry.sh` |
| `baseline/` | Phase 1 masked/unmasked linter runs, `linter-p6-*`, `linter-final.*`, self-test reports |
| `target-names/` | `categories.tsv`, `target-names.tsv` (the derive-once table), `README.md` (reviewed and ACCEPTED) |
| `guard-rejections.md` | the zero-rejection report |
| `build-errors-initial.txt`, `build-rounds/`, `fixloop.log` | the Phase 6 red interval and its convergence |
| `phase7-lean-sweep.md`, `phase7-docs-sweep.md` | Layer 4 reports |
| `phase8-decision-record.md` | tactic decision table, recorded dissent, final linter reading |
| `handoffs/` | Phase 5 and Phase 6 continuation handoffs |
