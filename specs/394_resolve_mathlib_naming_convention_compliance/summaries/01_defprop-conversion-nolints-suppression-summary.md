# Implementation Summary: Task #394

- **Task**: 394 - resolve_mathlib_naming_convention_compliance
- **Plan**: `specs/394_resolve_mathlib_naming_convention_compliance/plans/01_defprop-conversion-nolints-suppression.md`
- **Status**: All 4 phases COMPLETED
- **Session**: sess_1785074764_351b3f_394

## Outcome

Route (c′) executed as specified: 38 `Prop`-typed `def`s converted to `theorem`s, then a filtered
`scripts/nolints.json` added covering the residual 860 `defsWithUnderscore` findings, and the
deviation documented in `docs/development/`. Zero declarations renamed. No `def` converted beyond
the pre-approved 38.

Every gate hit its predicted value exactly. The build never went red at any point — the Phase 2
conversion compiled green on the first attempt.

## Linter Results

`lake exe runLinter Bimodal` (the **only** gate that observes `defsWithUnderscore`; a green
`lake build` carries no information about this category):

| Category | Phase 1 (frozen) | After Phase 2 | After Phase 3 | Gate |
|---|---|---|---|---|
| `defsWithUnderscore` | 888 | 860 (−28) | **0** | target |
| `unusedArguments` | 122 | 122 | 122 | strict equality |
| `LINTER FAILED` | 115 | 115 | 115 | strict equality |
| `docBlame` | 39 | 39 | 39 | strict equality |
| `tacticDocs` | 4 | 4 | 4 | strict equality |
| `structureInType` | 1 | 1 | 1 | strict equality |

All five sibling-owned categories held at **strict equality** through both mutating phases — no
divergence in either direction, so no trespass on sibling tasks.

Build warning stream (`lake build`):

| Category | Before | After |
|---|---|---|
| `linter.defProp` | 38 | **0** |
| `classDefReducibility` | 2 | **0** |
| **Total build warnings** | 70 | **30** |
| Warnings *added* | — | **0** (line-by-line normalized census diff) |

## Divergence from the Research Clone

**None.** Phase 1 re-measured all six linter categories in the working tree and every value
reproduced the research clone exactly (888 / 122 / 115 / 39 / 4 / 1), as did the build warning
counts (70 total, 38 `defProp`, 2 `classDefReducibility`). The measured values were frozen as the
differential gate; no adjustment was needed and none was made.

## Invariants Held at Every Phase Boundary

| Invariant | Value | Status |
|---|---|---|
| `lake build` | exit 0, **1874 jobs** | held at all 4 boundaries |
| `lake build BimodalTest` | exit 0, **1909 jobs** | held at all 4 boundaries |
| Live `sorry` count | exactly **1** | held at all 4 boundaries |
| Live `sorry` location | `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` :: `countermodel_discrete` | located by content, never by line number |

## The Three Traps — All Three Hit as Predicted

The dry run of the conversion reported counts matching the research prediction exactly before any
file was written:

1. **`noncomputable` must be dropped**: **31 of 38** carried it. All 31 dropped in the same edit as
   the `def`→`theorem` change. (`noncomputable theorem` does not elaborate.)
2. **`@[instance_reducible]` must be removed**: exactly **1** declaration,
   `limitDomSubtype_denselyOrdered_from_F'T` in
   `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`. Its sole
   consumer is a `letI` a few lines below; removal build-verified.
3. **Reported line numbers point at the doc comment, not the `def`**: confirmed by inspection
   (offsets observed 4-8 lines). The converter forward-scans from the anchor for a line matching
   `^(modifiers)*def <name>(?=[\s(:{\[]|$)` and **aborts if it does not find exactly one match**.
   Replacement is strictly position-anchored — no global or substring replace anywhere in this
   task.

The converter also correctly preserved `private` / `protected` modifiers while dropping only
`noncomputable` (e.g. `private noncomputable def build_bicompat` → `private theorem build_bicompat`).

## The `--update` Indiscriminacy Trap

`lake exe runLinter Bimodal --update` emitted **1141** rows — **281** of them sibling-owned:

| Swept-in category | Rows |
|---|---|
| `unusedArguments` | 122 |
| `simpNF` | 115 |
| `docBlame` | 39 |
| `tacticDocs` | 4 |
| `structureInType` | 1 |

Filtered to the **860** `defsWithUnderscore` rows only. Verified: `jq 'length'` = 860, and
`jq -r '.[][0]' | sort -u` yields exactly one distinct `linterName`.

**Format fidelity.** Rather than re-serializing blindly, the writer format was reverse-engineered
(rows wrap to a continuation line at width 80) and **round-trip verified byte-for-byte against the
unfiltered generated file** before the filtered file was trusted. Row order is the exact
subsequence of `--update`'s own output (verified programmatically), so the file is
regeneration-stable.

## Deviations from Plan

- **Altered — Phase 4, documentation framing**: mid-implementation the coordinator relayed a user
  decision that a full `lowerCamelCase` rename **will** happen as a dedicated follow-up task. The
  deviation document was therefore written as a *deliberate interim measure with a known
  successor* rather than as the permanent architectural decision the plan's Phase 4 described. It
  additionally records the migration constraints (24,364 resolved usages across 258 of 300
  modules; 398 of 873 names being proper prefixes of other identifiers; the 46.4% naive-replace
  error rate over 68,076 touched sites; deprecation shims raising the count 860→861; churn
  concentrated in `Syntax/Formula.lean`'s 12 data names at 4,929 usages, ~5× the `Theorems/`
  layer), and states that `scripts/nolints.json` entries are expected to be deleted as the
  migration lands rather than maintained in perpetuity. `LEAN_STYLE_GUIDE.md`'s cross-reference
  describes the state as interim to match. Phases 1-3 were unaffected.
- **Altered — Phase 4, task-number gate**: the plan's `grep` check failed on a **pre-existing**
  citation, `**Key Lesson (Task 213)**` at `docs/development/LEAN_STYLE_GUIDE.md:887` — not
  introduced by this task. Since the plan scopes the gate to the whole file and
  `no-task-references-in-deliverables.md` is repo-wide, the citation was removed. The surrounding
  text is self-contained and already cites durable anchors (`swap_past_future_involution`,
  `Formula.lean`, `Validity.lean`), so nothing was lost. Flagged here because it is a change
  outside the task's nominal scope.

Everything else followed the plan as written.

## Files Modified

**Lean sources — 38 `def`→`theorem` conversions across 13 files** (+38 / −39 lines; the extra
deletion is the `@[instance_reducible]` line):

| File | Conversions |
|---|---|
| `Theories/Bimodal/FrameConditions/FrameClass.lean` | 2 |
| `Theories/Bimodal/FrameConditions/Soundness.lean` | 1 |
| `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` | 9 |
| `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` | 1 |
| `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` | 1 |
| `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` | 4 |
| `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` | 5 |
| `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` | 2 |
| `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` | 2 |
| `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CustomGame.lean` | 2 |
| `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` | 1 |
| `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` | 5 |
| `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` | 3 |

**Other**:
- `scripts/nolints.json` — new, 860 filtered `defsWithUnderscore` entries
- `docs/development/NAMING_CONVENTION_DEVIATION.md` — new
- `docs/development/LEAN_STYLE_GUIDE.md` — interim-state cross-reference added; pre-existing task
  citation removed

## Commits

| Phase | Commit |
|---|---|
| 2 | `task 394 phase 2: convert 38 Prop-typed defs to theorems` |
| 3 | `task 394 phase 3: add filtered scripts/nolints.json` |
| 4 | `task 394 phase 4: document naming-convention deviation` |

Phase 1 was read-only measurement; its plan status marker rode along with the Phase 2 commit.

## Notes for the Follow-Up Migration

The reusable converter used in Phase 2 (position-anchored, forward-scanning, aborts unless exactly
one match per declaration) is a workable template for the rename, but the rename is a strictly
harder problem: the `def`→`theorem` edit touched only the *declaration site*, whereas a rename
must touch all 24,364 resolved usages. The 45.6% prefix-collision rate means textual matching is
not viable; the migration should drive off resolved reference positions from the `.ilean`
`references` blocks rather than off `grep`.
