# Implementation Summary: Wire the Algebraic Stack into the Build Graph

- **Task**: 496 - research_algebraic_stack_build_graph_wiring
- **Plan**: `specs/496_research_algebraic_stack_build_graph_wiring/plans/01_wire-algebraic-stack-fix-readme.md`
- **Research input**: `specs/496_research_algebraic_stack_build_graph_wiring/reports/01_algebraic-stack-build-graph-wiring.md`
- **Completed**: 2026-08-26
- **Phases**: 5 of 5 COMPLETED
- **Type**: lean4

## What Was Done

The report reached **option (a), re-wire**, and this implementation landed it rather than
re-adjudicating the question.

**Phase 1 — wiring (commit `b06c3b961`).** One line, `import FormalSystem.Metalogic.Algebraic`,
was added to `FormalSystem/Metalogic.lean` after the existing `Conservativity` import. That brings
the sibling aggregator and its four previously-orphaned children — `LindenbaumQuotient` (393),
`BooleanStructure` (441), `InteriorOperators` (176), `UltrafilterMCS` (1,071); 2,081 lines total —
into the Lake default target's import closure. In the same commit, the five now-stale entries were
deleted from `scripts/module-invariants-manifest.txt` (C6 fails if a manifest entry names a
reachable module), and the two surrounding comment blocks were rewritten: the first no longer
claims `Algebraic` is a deliberately importer-less sibling aggregator, and the second lost the
`FlowFrame.lean` contrast-case paragraph (which no longer contrasts with anything) and had its
coverage-note count corrected from "these six" to "these two". Both load-bearing sentences — the
`DELETE a line here when ...` instruction and the rot-guard rationale — were preserved verbatim.

**Phases 2-4 — documentation correctness (commits `2bc0e53c9`, `e191666c7`, `cb71c0ef2`).** The two
overstatements the task named were corrected, along with the further inaccuracies the research
audit found.

## Measured Results

| Measurement | Result |
|---|---|
| Phase 1 `lake build` (guarded, detached) | `rc=0`, 0 `error:` lines, 2499 jobs |
| Phase 5 `lake build` on the final tree | `rc=0`, 0 `error:` lines, 2501 jobs |
| Five `Algebraic` modules genuinely `Built` (not replayed) | Yes, both builds |
| Marginal elaboration, Phase 5 run | 2.2s + 1.8s + 1.5s + 1.8s + 1.3s = **8.6s** |
| `.olean` added | **948 KB** — exactly the report's F5 figure, re-measured |
| `check-module-invariants.sh` on the final tree | `rc=0`, **ALL CHECKS PASSED** (baseline was `rc=1`) |

The report's F5 prediction (5.3s elaboration, 948 KB) held on artifact size exactly; the
elaboration figure came in higher (8.6s vs 5.3s) because these builds ran against a machine
under concurrent load from three sibling Lean dispatches, not on an otherwise-idle box.

## Invariant Comparison

**Final result: `scripts/check-module-invariants.sh` exits 0, `ALL CHECKS PASSED`**
(`logs/phase5-invariants.log`). This is *better* than the baseline, which failed.

The baseline run at the start of this task (`logs/baseline-invariants.log`, `rc=1`) had exactly one
failing group, C6, naming `BimodalTest.Semantics.DependentUltraproductProbe` — an untracked file
created by a *concurrent sibling dispatch*, not by this task. Over the course of the work the C6
failing member set changed twice more as siblings landed further files
(`FormalSystem.Metalogic.BaseLanguageSoundness`, `FormalSystem.Semantics.BLValidity`), and was
cleared entirely once those siblings manifested their own modules.

Every C6 member named at any point was a foreign module. **No `Algebraic` module appeared in any
C6 failure at any point**, which is the check that this task's five manifest deletions were
correct: had a deletion been wrong, the deleted module would have reappeared as "unreachable and
absent from the manifest". Final C6 now reads `all 17 unreachable live module(s) are manifested`,
down from 23 unreachable at baseline — five of that reduction is this task's wiring.

The acceptance criterion — "no regression to any check currently passing" — is met with room to
spare: every check is green, including C1 (`lake build` exits 0, both targets), C2 and C14 (all six
flagship axiom sets unchanged at `[propext, Classical.choice, Quot.sound]`), C3 (zero sorries),
C5/C12/C13 (the markdown scans that the three README edits had to survive), and C8.

C8 (sibling aggregator) still passes, as predicted: the aggregator file did not move, it merely
acquired an importer.

**One stale count, foreign-caused, left alone deliberately.** C7 now rolls up `Metalogic 315`
files, because a sibling dispatch added `FormalSystem/Metalogic/BaseLanguageSoundness.lean`.
`FormalSystem/Metalogic/README.md` still says "The eight directories total 314 files, matching
C7's `Metalogic 314` rollup". That line was correct when this task began, is not part of this
task's file set, and belongs to the dispatch that added the file — it was not edited here.


## Documentation Corrections

### `FormalSystem/Metalogic/Algebraic/README.md` (Phase 2)

1. **Header status** — was "Active -- infrastructure consumed by the live completeness proof",
   asserted of the whole directory. Now states the two footings separately: `FlowFrame.lean` is
   consumed by the live proof; the Boolean-algebra/ultrafilter layer is standalone sorry-free
   infrastructure with no current consumer, covered by `lake build` via the aggregator.
2. **"This directory is not optional"** — scoped to `FlowFrame.lean`, which is the only file the
   claim was ever true of.
3. **"`Algebraic/` participates in the live proof"** — likewise scoped to `FlowFrame.lean`, with
   an explicit sentence saying the other four modules *do* stand beside the proof.
4. **Importer list** — was four files, all under `BXCanonical/`. Corrected to the actual six, and
   the "BXCanonical imports ..." framing was widened, because two of the six
   (`Bundle/LimitMCS.lean`, `WeakCanonical/GroupModel/CountermodelBase.lean`) are not under
   `BXCanonical/` at all.
5. **"G and H are shown to be interior operators using the T and 4 axioms"** — false on both
   counts, replaced with what is actually proved: `boxInterior` (`InteriorOperators.lean:142`) is
   the only `InteriorOp`, assembled from `box_le_self` (`:101`), `box_monotone` (`:112`) and
   `box_idempotent` (`:130`); `H_monotone` (`:80`) is the only surviving G/H-family result; and
   there is no G operator on the quotient at all — it carries `boxQuot`
   (`LindenbaumQuotient.lean:289`), `hQuot` (`:296`) and `negQuot` (`:261`), with no G
   counterpart anywhere in the tree.
6. **Mathematical Overview step 3** — repeated the same false claim in expanded form, with
   G-specific deflationary/monotone/idempotent bullets. Rewritten to state the Box triple, with a
   closing sentence on why G and H do not qualify under strict temporal semantics.
7. **Modules table row** — `InteriorOperators.lean` is now "Box as interior operator; H
   monotonicity".
8. **Footer** — `*Last updated:*` refreshed from 2026-04-06 to 2026-08-26.

### `FormalSystem/Metalogic/README.md` (Phase 3)

1. **Route-table row** and **Directory-Inventory row** — the "Parametric/algebraic" labels named a
   stack deleted in commit `6c3419a4f`. Both now describe what is actually there: the
   Lindenbaum-Tarski quotient algebra, the ultrafilter/MCS correspondence, and the flow-frame
   countermodel engine.
2. **Aggregator rule** — "No existing file is edited to import an aggregator" was already false at
   HEAD (`Metalogic.lean` imports four aggregators, five after this change). Restated in its true
   narrow form: do not import an aggregator whose own contents already reach the importing file.
3. **"No importer" claim** — `Algebraic.lean` removed from that list, with a sentence saying it is
   now imported by `Metalogic.lean` and covered by `lake build` rather than by the C6 manifest.
4. **Footer** — `*Last verified:*` refreshed to 2026-08-26.

The file's own counts (314 Metalogic files, the C7 rollup, the `Algebraic/` row's `5 | 2,887`) were
deliberately left untouched — no `.lean` file was added or removed by this task.

### `FormalSystem/Boneyard/` (Phase 4)

`UltrafilterFrame/README.md` gained a dated "Adjudication of the elaboration-conflict claim"
subsection recording both halves honestly: the concern did **not** reproduce for the four remaining
`Algebraic/` modules (the adversarial upstream-import build re-elaborated `Completeness`,
`CompletenessDedekind` and `StrongCompleteness` with `rc=0` and zero errors), **and** the warning
remains in force for `UltrafilterFrame.lean` and `TenseS5Algebra.lean` themselves, which carry five
sorries, were never built, and were not part of the experiment. `Boneyard/README.md`'s
`### UltrafilterFrame` entry, which repeats the same attribution verbatim, gained a one-clause
cross-reference. Evidence is cited by durable path to the research report, not by task number.

## Plan Deviations

- **Phase ordering (altered)**: the plan's Wave 2 (Phases 2-4) was executed while Phase 1's
  detached build was still running, rather than strictly after Phase 1 closed. The build takes
  tens of minutes on this machine under concurrent load, and Phases 2-4 touch only markdown with
  no compile surface and no file overlap with Phase 1's declared set. Phase 1 was still committed
  first, as its own atomic two-file batch, and no prose edit was committed before its build came
  back green.
- **Phase 2 verification criterion (altered)**: the plan asks that
  `grep -c 'gQuot' FormalSystem/Metalogic/Algebraic/README.md` return 0. That is unsatisfiable as
  literally written, because the same phase instructs the corrected text to name `negQuot`, which
  contains `gQuot` as a substring. The criterion actually intended — that the nonexistent name
  `gQuot` is not introduced — was verified with the word-anchored form `grep -c '\bgQuot'`, which
  returns 0. Annotated inline on the plan's verification line.
- **Phase 2 verification criterion (satisfied by rewording)**: the plan asks that
  `grep 'participates in the live proof'` return nothing, while its task list asks that the claim
  be *scoped* to `FlowFrame.lean` rather than deleted. The scoped restatement was worded to avoid
  the retired phrase ("that one file is therefore part of the live proof, not merely adjacent to
  it"), satisfying both. No substantive deviation.
- No other deviations. No phase was blocked, skipped, or deferred.

## Concurrency Record

Three sibling lean4 dispatches (tasks 489, 490, 491) ran in this repository throughout. They
created `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean`,
`FormalSystem/Metalogic/BaseLanguageSoundness.lean`, `FormalSystem/Semantics/BLTruth.lean`,
`FormalSystem/Semantics/BLValidity.lean`, edited `SetConsequence.lean`, `StrongCompleteness.lean`,
`Semantics.lean`, `Tests/BimodalTest.lean`, and amended a docstring in `FormalSystem/Metalogic.lean`
after this task's import landed there (the import survives intact). Foreign commits landed on
`main` between this task's own commits.

**Nothing foreign was reverted, staged, or "fixed" by this dispatch.** Every commit here is scoped
to this task's own six files plus its `specs/**` artifacts. The observations are recorded in
`logs/concurrency-observations.md`.

## Out of Scope — Recorded Observations

Carried forward from the plan's Non-Goals, so they are not lost:

- **D4 aggregator candidates.** `Core.lean`, `Bundle.lean` and `SoundnessLemmas.lean` sit in the
  same manifest block for the same reason and are plausible follow-on wiring candidates, but each
  needs its own cycle analysis and none was tested. Their manifest entries were deliberately left
  untouched.
- **Is `Algebraic/` a completeness route at all?** `Metalogic/README.md` lists it as one of three
  routes, while the directory's own flowchart says "no completeness theorem is stated here". The
  report evidenced only the word "parametric", so only that was changed. The framing question is
  left for a future documentation pass.
- **The `UltrafilterFrame`/`TenseS5Algebra` hazard is untested and still in force.** Recovering
  those two files for the STSA / Jonsson-Tarski port should re-run the adversarial upstream-import
  build with them included before assuming the same clean result.
- **A named first suspect if this ever bites.** The one genuinely global declaration now entering
  the build library-wide is `instance instMembershipUltrafilter` (`UltrafilterMCS.lean:63`),
  quantified over every Boolean algebra, plus two `@[simp]` lemmas (`:537`, `:976`). Neither was
  observed to interfere in any of the six measured builds across this task and its research;
  scoping the instance is the remedy if it ever does.
- **The report's Context Extension Recommendation** — a
  `context/project/lean4/patterns/testing-archived-elaboration-hazards.md` capturing the
  two-variant experiment design — is agent-system work under `agent-system/extensions/**`, a
  different source store and task type, and was not done here.

## Files Modified

| File | Change |
|---|---|
| `FormalSystem/Metalogic.lean` | one import line added |
| `scripts/module-invariants-manifest.txt` | five entries deleted, two comment blocks rewritten |
| `FormalSystem/Metalogic/Algebraic/README.md` | eight corrections |
| `FormalSystem/Metalogic/README.md` | four corrections plus footer date |
| `FormalSystem/Boneyard/UltrafilterFrame/README.md` | scoped adjudication note |
| `FormalSystem/Boneyard/README.md` | one-clause cross-reference |

## Commits

| Commit | Phase |
|---|---|
| `b06c3b961` | 1 — wire the aggregator and clear the manifest (atomic two-file batch) |
| `2bc0e53c9` | 2 — correct `Algebraic/README.md` |
| `e191666c7` | 3 — correct `Metalogic/README.md` |
| `cb71c0ef2` | 4 — record the elaboration-hazard adjudication in the Boneyard |
