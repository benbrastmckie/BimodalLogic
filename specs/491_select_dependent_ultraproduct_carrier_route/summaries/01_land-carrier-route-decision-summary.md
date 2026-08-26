# Implementation Summary: Land the Dependent Ultraproduct Carrier Route Decision

- **Task**: 491 - select_dependent_ultraproduct_carrier_route
- **Plan**: `specs/491_select_dependent_ultraproduct_carrier_route/plans/01_land-carrier-route-decision.md`
- **Status**: COMPLETED (both phases)
- **Session**: sess_1787724130_558d21

## What was done

The route-selection decision itself was already made by the research phase and was not reopened.
This implementation made that decision **durable** — it moved the evidence from a prototype under
`specs/`, which no build target compiles, to a module the build checks on every run, and it put
the decision where the successor task will read it.

### Phase 1 — the construction is now compiled

`Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` (283 lines) carries the route-(a)
carrier construction verbatim from
`specs/491_select_dependent_ultraproduct_carrier_route/prototype/DependentUltraproduct.lean`.
Changed from the prototype: the copyright header, a probe-idiom module docstring, and the
namespace (`UProto` → `BimodalTest.DependentUltraproductProbe`, with the three `#print axioms`
lines requalified). Nothing mathematical was re-derived, re-proved, or altered.

Measured:

- **No `autoImplicit := false` fallout.** The plan's largest named risk was that the prototype,
  verified with bare `lake env lean`, would break under the `BimodalTest` lean_lib's
  `theoryLeanOptions`. It did not: the module built clean in **1.4 s** with no binder added and no
  option changed.
- **0 `sorry`, 0 new axioms.** Axiom profiles are exactly the report's §2.5 values:
  - `BimodalTest.DependentUltraproductProbe.shiftSetOnUD` → `[propext, Classical.choice, Quot.sound]`
  - `BimodalTest.DependentUltraproductProbe.shU_add` → `[propext, Classical.choice, Quot.sound]`
  - `BimodalTest.DependentUltraproductProbe.instDenselyOrderedUD` → `[propext, Classical.choice, Quot.sound]`
- **Declaration set identical to the prototype's** — 18 named declarations plus 5 instances
  (3 anonymous, 2 binder-guarded) = the 23 the plan's Scope Hypothesis enumerates. Diffed in both
  directions; empty. No scope leaked in from the successor's work.

The live content of the probe is `shiftSetOnUD`: its elaboration is the check that
`ShiftSet (UD φ D)` is well-typed — every instance binder resolves and the quotient lands in
`Type` rather than `Type 1`. That check is now performed by the compiler on every build instead
of being asserted in prose, which was the entire point of the phase.

### Phase 2 — wired in, and recorded where the successor reads it

- `Tests/BimodalTest.lean` gained one import line, placed with the other
  `BimodalTest.Semantics.*` imports.
- `lake build BimodalTest`: **green**, 2552 jobs, 0 errors. The probe's own job costs **1.6 s**.
- `lake build` (default `FormalSystem` target): **green**, 0 errors.
- The report gained a `## 9. Decision record` section: selected route, rejected route with its
  three grounds, the probe's in-tree path, and §5's three obligations restated as *not done here*.
- `specs/state.json` — the `build_shiftset_ultraproduct_and_los_lemma` entry's description gained
  a `CARRIER ROUTE (SETTLED — do not re-litigate)` block naming the route concretely, the report
  path, the probe path, the "do not import `Filter.Germ`/`FilterProduct`" instruction, and the
  four things the probe deliberately does not supply. Appended only; the rest of the description
  and its `artifacts` field were left alone. `specs/TODO.md` regenerated via
  `generate-todo.sh`, not hand-edited.
- `specs/ROADMAP.md` left unmodified, as the plan required.

## Scope discipline

The task description forbids writing the Łoś lemma, and the plan additionally excludes the
ultrafilter on the index type, `ShiftSet.sep`, `carrier_nonempty`, and the valuation. None of the
five was attempted. The probe's own docstring states what it deliberately does not do, and the
declaration-set diff above is the mechanical check that nothing was added. Nothing under
`FormalSystem/` was touched by this task.

## Plan Deviations

- **Phase 1 verification method — altered.** The plan's verification bullet named
  `lake env lean <file>`; the scoped `lake build BimodalTest.Semantics.DependentUltraproductProbe`
  was used instead. `lake env lean` does not apply the library's `leanOptions`, and applying them
  is precisely what Phase 1 exists to measure, so the substitute is strictly stronger.
- **Phase 2 verification bullet "`git status --short` shows no modification under
  `FormalSystem/`" — altered.** The working tree does carry `FormalSystem/` modifications, every
  one of them foreign: three sibling lean4 dispatches were live in this repository throughout.
  The bullet was verified in the only available form — this task's commits touch zero files under
  `FormalSystem/`, confirmed by `git show --stat` on each.
- No other deviation. The plan was otherwise followed as written.

## Concurrency observations (reported, not acted on)

Three sibling lean4 dispatches ran in this repository throughout. Two observations that a reader
of this summary should not mistake for defects in this task's work:

1. **A transient red build, foreign in origin.** The first `lake build BimodalTest` failed
   (EXIT=1) on `FormalSystem/Metalogic.lean:8`: `object file '…/BaseLanguageSoundness.olean' …
   does not exist`. The task-489 dispatch had added that import to `FormalSystem/Metalogic.lean`
   before its olean was built. 2549 of 2551 jobs succeeded; the probe replayed clean. Once 489
   committed (`84c602b36`) and its olean appeared, the identical build went green with 0 errors.
   Nothing was reverted or "fixed" — the retry alone resolved it.
2. **`check-module-invariants.sh --no-build` fails C6**, on two unreachable live modules:
   `FormalSystem.Metalogic.BaseLanguageSoundness` and `FormalSystem.Semantics.BLValidity`. Both
   are task 489's, both were untracked and minutes old when observed. Every other check that runs
   without a build passes: B0, C3, C4, C5, C8, C9, C10, C11, C12, C13, C14, C15. C9D remains its
   pre-existing not-yet-enforced TODO. **This task introduced no C6 entry** — the probe is
   reachable from `Tests/BimodalTest.lean`.

## Tooling note for successors

`.claude/scripts/lake-build-guard.sh` passes everything after `--` straight to `lake`, so the
lake subcommand must be included: `... build --timeout 1800 -- build <target>`. Omitting it runs
bare `lake`. The guard also replays a concurrent sibling's shared build result unless
`--no-share` is passed; the first attempt here silently returned a sibling's default-target build
with the probe nowhere in it, which is easy to mistake for a green result.

## Files changed

- `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` — new (283 lines)
- `Tests/BimodalTest.lean` — one import line
- `specs/491_select_dependent_ultraproduct_carrier_route/reports/01_dependent-ultraproduct-carrier-route.md` — appended §9
- `specs/491_select_dependent_ultraproduct_carrier_route/plans/01_land-carrier-route-decision.md` — phase markers, annotations
- `specs/state.json` — successor task's description
- `specs/TODO.md` — regenerated
