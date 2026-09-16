# Implementation Summary: Task #579

- **Task**: 579 - Nest MinusLanguage/, PlusLanguage/, StarLanguage/ under Syntax/
- **Status**: [COMPLETED]
- **Started**: 2026-09-15T21:19:23-07:00
- **Completed**: 2026-09-15T23:20:00-07:00
- **Effort**: ~2 hours (plan estimated 5.25)
- **Dependencies**: None
- **Artifacts**: plans/01_nest-language-family-under-syntax.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The L⁻/L⁺/L⋆ language family now lives under `FormalSystem/Syntax/` instead of as three flat
siblings of it, and `Syntax/README.md` carries a `Language family` section that names `stab`/`⊡`/
"boxdot" and points at the existing implementation — which is what actually closes the
discoverability gap review Finding H1 reported. C8 machine-enforces the aggregator convention on
the new directories. This was a module-path rename only: **zero non-import changed lines** in all
three moved trees, zero namespace changes, zero new axioms, zero new sorries.

All 7 phases closed. Phase 7 closed as `[COMPLETED WITH EXCLUSIONS]` for one gate item owned by
the concurrent task-580 dispatch; every check this task owns is green.

## What Changed

- `FormalSystem/Syntax/{MinusLanguage,PlusLanguage,StarLanguage}/` and their three sibling
  aggregators — **moved** from `FormalSystem/` via `git mv` (19 renames, history preserved,
  similarity indices R088-R100).
- 41 `import` lines rewritten across 26 `.lean` files: `FormalSystem.{X}Language.*` ->
  `FormalSystem.Syntax.{X}Language.*`. Includes `FormalSystem/FormalSystem.lean` and 7
  `Metalogic/` consumers.
- `FormalSystem/Syntax/SubformulaClosure.lean` — **created**; the sibling aggregator C8 requires
  once `FormalSystem/Syntax` joins its `parent` tuple. `Syntax.lean`'s four leaf imports
  collapsed to one.
- `scripts/check-module-invariants.sh` — `"FormalSystem/Syntax"` added to C8's `parent` tuple,
  plus its pass message, header line and comment block.
- `FormalSystem/Syntax/README.md` — new `## Language family` section (the deliverable).
- `FormalSystem/Syntax.lean` — module docstring primitives corrected to `untl`/`snce`, plus three
  further errors found while confirming it (see `## Decisions`).
- `docs/development/MODULE_ORGANIZATION.md` — §2's fictional `Bimodal` root namespace and false
  "namespaces mirror directory structure" claim replaced with the real convention.
- `scripts/module-invariants-allowlist.txt` — 3 namespace-reading entries.
- `FormalSystem/README.md` — Submodule Navigation table's root-level language rows replaced by
  three nested `Syntax/` rows (including the previously missing `StarLanguage/`); Layer 0
  repathed.
- 35 slash-shaped and 6 dotted module references repathed across 14 non-`specs/` markdown files;
  4 generated inventory blocks regenerated; several hand-maintained counts corrected.
- `FormalSystem/Semantics/{MinusFrame,MinusTruth,PlusTruth,StarTruth}.lean` — one import-prefix
  line each, under an explicit orchestrator-granted territory exemption.

### The Language family section

Three things a reader needs, none of which existed before:

- **Constructor-delta table**, measured against each `Formula.lean`: L 6 (`atom, bot, imp, box,
  untl, snce`), L⁻ 6 (`allPast`/`allFuture` in place of `untl`/`snce`), L⁺ 7 (L's six + `stab`),
  L⋆ 9 (L⁺'s seven + `timeStore`, `timeRecall`).
- **L ⊂ L⁺ ⊂ L⋆ is the chain; L⁻ is not in it.** L⁻ is a sibling variant related to L by
  `tr : MinusFormula → Formula`, not an extension. The originating review's "one extension
  hierarchy" phrasing is false and was deliberately not reproduced — putting a fresh false claim
  into the section written to fix a discoverability defect would have been self-defeating.
- **"Looking for boxdot?"** — names `stab`, `⊡` and the word "boxdot", and points at the
  complete, sorry-free `Syntax/PlusLanguage/` implementation.

## Decisions

- **Namespaces stay flat** and **`Syntax.lean` does not import the nested aggregators**, both per
  the plan's Research Integration. Consequence: a dotted name like `FormalSystem.MinusLanguage`
  may be a namespace reading (correct as written) or a module-path reading (must be repathed),
  and the two are textually indistinguishable — which is why 3 allowlist entries were added
  rather than repathing everything, and why each records which reading it covers.
- **The territory boundary was escalated, not overridden.** 4 of the 41 import lines live under
  `FormalSystem/Semantics/`, which the dispatch note placed off-limits. Rather than make the
  trivially-small edits unilaterally, the conflict was raised and Phase 1 closed cleanly while
  waiting. The orchestrator granted a narrow exemption (recorded in `.decisions.json`), noting
  the boundary had been an over-narrow guess authored before the blast radius was known.
- **The C13 repair went further than repathing.** Both sites also asserted the docs workflow
  "runs on every push to `main`", false since `9bcbe9e41` disabled it. Repathing the link alone
  would have preserved a false claim while turning the gate green; the claims were corrected too.
- **Three defects corrected beyond the plan**, all false statements about the primary language
  sitting in the docstring a reader hits first: `always` was documented as `Hφ ∧ Gφ` but
  `Formula.lean:478` is `Hφ ∧ (φ ∧ Gφ)`; `sometimes` was `Pφ ∨ Fφ` but `Formula.lean:621` is
  `¬△¬φ`; and `P`/`F` were shown as derived from `H`/`G`, inverting the real dependency
  (`someFuture = untl ⊤ φ` is primitive-derived, and `allFuture` derives from *it*).
- **`specs/paper-definitions-of-record.md`** had two paths left dangling by the move. No gate
  covers them; repaired anyway rather than knowingly leaving them stale.

## Plan Deviations

- **Phase 1 verification** altered: scoped `lake build FormalSystem.Syntax` instead of a full
  build, because task 580 had `FormalSystem/Semantics/` mid-edit. `Syntax` does not import
  `Semantics`, so the scoped build covered everything the phase could affect.
- **Phase 2** was briefly `[BLOCKED]` on the territory conflict, then executed in full under the
  granted exemption. The blocker record was replaced by an `EXEMPTION GRANTED` record.
- **Phase 3's** verification expected `FAIL C13` to be the only remaining failure. That assumed
  Phase 4 had already run (the wave table puts 3 and 4 together); executing depth-first per the
  phase-closure contract, C5/C12/INV were also open at that point — expected post-move debt owned
  by Phases 4 and 6, not a regression.
- **Phase 7** closed `[COMPLETED WITH EXCLUSIONS]`: `check-module-invariants.sh` exits 1, solely
  on a `C20` finding owned by task 580. See the phase's Reasoned Exclusions table.
- Scope-hypothesis variances (C5 tokens 9->11, inventory blocks 3->4, and two items the
  hypotheses missed entirely) are recorded per-phase in the plan.

## Verification

- Build: **PASS** — guarded, un-piped, `GUARD_EXIT=0`, `Build completed successfully (2653
  jobs).`, 0 `error:` lines in guard stdout and stderr.
- Tests: **PASS** — `Built BimodalTest`, `Build completed successfully (2705 jobs).`, 0 `error:`.
- Sorry count: **0**. `PASS C3` structural sorry inventory is zero across `FormalSystem/`
  (Boneyard excluded). The raw 330-hit `grep -rn '\bsorry\b'` over the live tree is prose
  mentions in docstrings, which is why `C3` is the load-bearing number.
- Vacuous count: **0 introduced**. The one tree-wide grep hit,
  `FormalSystem/Examples/TemporalStructures.lean:496`, is pre-existing and in a directory this
  task never touched.
- Axiom count: **14, unchanged** from pre-task (14).
- **No-proof-change audit: 0 non-import changed lines** in all three moved trees
  (`.lean`-only, both old and new paths in the pathspec so rename detection pairs them).
- **Namespace surface untouched**: zero `[+-]namespace`/`[+-]open` lines in this task's `.lean`
  files; zero `namespace FormalSystem.Syntax.{Minus,Plus,Star}Language` matches.
- **History preserved**: `git log --follow` reaches pre-move commits on one file per tree
  (`6c361b92a`, `d370581c5`, `475507a76`).
- Gates: `PASS C3 C4 C5 C8 C11 C12 C13 C14 C15 C18 C21 C22 C23 C26 INV`. `readme-lint.sh`
  `RESULT: PASS`, 0 missing READMEs, 0 broken references (recovered from a transient 2 that this
  task's own sweep introduced and then repaired).
- **Baseline improved**: the plan's recorded baseline was `FAIL C13`; that is now `PASS C13`.
- Files verified: Yes.

### Not this task's, and left alone

`FAIL C20` tier 1: `Semantics/Ultraproduct/Los.lean:22` cites `Semantics/ShiftSet.lean:261`, now
blank. `ShiftSet.lean` was last touched by `1c9ea208c` (task 580 phase 2); `Los.lean` by
`b9fd6f15c` (task 552). Neither file is this task's. Attribution was verified independently by
the orchestrator, which pre-approved task 580 to fix it by citing the declaration name.
`TODO C16` and `TODO C9D` are pre-existing and gated off by design.

## Impacts

- A reader starting from the base language can now reach `⊡`/`stab` in three ways: the directory
  layout, the `Syntax/README.md` `Language family` section, and `Syntax.lean`'s own docstring.
  The duplicate-work risk the review identified is closed.
- C8 now enforces the aggregator convention on `FormalSystem/Syntax` subdirectories, so a future
  nested directory without a sibling aggregator fails the gate rather than passing silently.
- `import FormalSystem.Syntax` stays as cheap as before: the nested aggregators are deliberately
  not imported there, so the 15 bare consumers do not transitively elaborate `Theorems/` or
  `Metalogic/Core/`.
- `MODULE_ORGANIZATION.md` §2 now describes the namespace convention the tree actually follows,
  which matters beyond this task: the old text would have led a reader to rename namespaces to
  match directory depth.

## Follow-ups

- None for this task. The one outstanding gate item (`C20`) has a named owner and a pre-approved
  fix; see `## Verification`.

### Lessons: four broken measurements, none a broken change

The most transferable output of this dispatch. Each of these initially *looked* like a defect in
the work and was actually a defect in how the work was being measured.

1. **A piped build status is not the build's status.** `lake-build-guard.sh ... | tail -30` makes
   the reported exit code `tail`'s, which is ~always 0. This produced a false "exit 0" report
   elsewhere in the session that had to be retracted. Trust either the guard's own un-piped exit
   code (`GUARD_EXIT=$?`) or an explicit `Build completed successfully (N jobs).` line plus a zero
   `error:` count — never a pipeline's status.
2. **A rename audit naming only the destination reports a total rewrite.** `git diff -M` cannot
   pair a rename when the pathspec hides the source, so all three moved trees showed as wholly
   added: a phantom 1313/1364/1641 "non-import changed lines" that would have read as
   catastrophic proof damage. With both old and new paths in the pathspec: 0/0/0.
3. **A rewrite sweep needs a count assertion on both sides.** A first `sed` used `|` as both the
   delimiter and the BRE alternation operator, so it matched nothing and exited clean. It surfaced
   only because the post-sweep residual count was unchanged at 37 rather than 0. A clean exit is
   not evidence that a sweep did anything.
4. **`pgrep` and `grep` patterns match themselves and their prefixes.** A liveness check for
   build processes matched its own shell wrapper; separately, `^namespace Bimodal` returned 55
   hits that were all `BimodalTest.*` under a different root, briefly appearing to contradict a
   correct finding. Bracket the pattern (`[p]grep`) and anchor it (`^namespace Bimodal$`).

A fifth, related: a blunt rename regex hit `FormalSystem.StarLanguage.StarAxiom` and
`.StarDerivationTree`, which are *declarations* in the flat namespace, not module paths.
Repathing them would have broken C5 and stranded two allowlist entries. This is the pre-edit
gate's "syntactic match, semantically a different concept" failure mode, caught by checking each
token's reading against its context before editing.

## References

- `specs/579_nest_minuslanguage_pluslanguage_starlang/plans/01_nest-language-family-under-syntax.md` — the plan, with per-phase scope-variance and exclusion records
- `specs/579_nest_minuslanguage_pluslanguage_starlang/reports/01_nest-language-family-under-syntax.md` — research report
- `specs/579_nest_minuslanguage_pluslanguage_starlang/.decisions.json` — the territory exemption grant
- `specs/reviews/review-2026-09-15.md`, Finding H1 — origin of this task
- Commits: `53747904e` (p1), `2acf1371c` (p2), `2afb961a3` (p3), `dd03a13f3` (p4), `f0e21b6cc` (C13 repair), `f170ffe57` (p4 close), `524b09830` (p5), `83b0fe12f` (p6)
