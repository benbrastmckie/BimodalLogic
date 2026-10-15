# Implementation Summary: Task #800

- **Task**: 800 - Extend the time-reflection transport from BL to the Stability language
- **Status**: [COMPLETED]
- **Started**: 2026-10-15T11:28:00Z
- **Completed**: 2026-10-15T13:05:00Z
- **Effort**: ~1.6 hours wall clock, of which roughly 70 minutes was detached `lake build` time
- **Dependencies**: The base time-reflection task — landed before this one began
- **Artifacts**: plans/01_stability-time-reflection-transport.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md,
  plan-compliance.md, lean4.md

## Overview

The paper's cut proof of `cor:deterministic-completeness` extends `lem:time-reflection` to the
Stability language in one sentence: the mirror of a Stability formula is the Stability of its
mirror, since `τ ↦ τ⁻` carries the state-local class at `x` onto the state-local class at `-x`,
and `F ↦ F⁻` preserves the class of frames validating *Determined*. That sentence is now built in
Lean, as fifteen declarations across five phases, each with the signature pinned in the plan's
`## Lean Challenge Statements` section and a real proof.

Deliverable (1) required no work: `PlusFormula.reflectTime` already carried the Stability clause
commuting (`| stab φ => stab φ.reflectTime`) together with `reflect_time_involution` and the full
`reflect_time_*` family, so the dispatch's "check whether it already carries one" resolves to
**yes**. Deliverable (2), the one genuinely new semantic step, was delivered by *promotion*
rather than a second copy. Deliverable (5) resolves to keep-the-present-route, recorded in the
docstring with the alternative named.

## What Changed

- `FormalSystem/Semantics/Reversal.lean` — `sameState_rev_iff`, the carrying lemma, promoted to
  the lowest layer that can state it (it mentions only `WorldHistory.state`). Plus a
  `## Main Results` bullet.
- `FormalSystem/OpenLanguage/OpenReversal.lean` — the Open layer's duplicate retired;
  `image_rev_stabClass` added as the paper's *carries onto* form, a `Set.image` equation. Both
  former call sites resolve to the promoted name with **no edit**, as the plan predicted, because
  the file already imports `Semantics.Reversal` and already opens `FormalSystem.Semantics`.
- `FormalSystem/PlusLanguage/PlusReversal.lean` — **new module, 220 lines, exactly two imports**:
  the seven-case `plusTruthAt_rev` (`lem:time-reflection` at L⁺) and the `thm:TR-valid` family
  `plusValidOn_rev_iff`, `plusValidOnFrames_reflectTime`, `plusValidIn_reflectTime`,
  `plusValidIn_reflectTime_iff`, `plusValid_reflectTime`.
- `FormalSystem/Semantics/FrameProperty.lean` — `TaskFrame.deterministic_rev`.
- `FormalSystem/Metalogic/Deterministic/Validity.lean` — one import and the six closure
  declarations: `reflect_determined`, `determinedValid_rev`, `determinedSat_rev`,
  `plusValidDeterminedIn_reflectTime`, `detSat_rev`, `plusValidDetIn_reflectTime`.
- `FormalSystem/Metalogic/Deterministic/Soundness.lean` — docstring only: the recorded decision.
- `FormalSystem.lean` — exactly one sorted import line, zero removed; never regenerated.
- `FormalSystem/PlusLanguage.lean`, `FormalSystem/OpenLanguage.lean`, `FormalSystem/Semantics.lean`
  — registration and docstring surfaces.
- Five generated inventory blocks plus `typst/generated/status.typ` — regenerated, never
  hand-edited.
- `docs/reference/paper-definitions-of-record.md`, `scripts/measure-refactor-partitions.py`,
  `ORGANISATION.md` — three gate prerequisites; see `## Plan Deviations`.

## Decisions

- **Promotion, not a third copy.** A Plus-local `sameState_rev_iff` would have made three copies
  of a four-line, language-free fact about `WorldHistory.state`.
- **The image form is sited in `OpenReversal.lean`, not `OpenClasses.lean`** — zero new imports,
  and it sits beside the pointwise lemma it consumes. `stabClass` is therefore not promoted.
- **A separate module `PlusReversal.lean`, not an extension of `PlusValidity.lean`** — it mirrors
  `OpenLanguage/OpenReversal.lean` one-for-one, which is what makes the two layers readable side
  by side.
- **The deterministic-frames sibling is in scope.** `deterministic_rev`, `detSat_rev` and
  `plusValidDetIn_reflectTime` are the same transport at the sibling frame predicate, not a port
  of `cor:deterministic-completeness`, which the dispatch's scope limit excludes.
- **Deliverable (5): keep the present route.** The Deterministic soundness TR case keeps its
  paired shape, with deliverable (4) recorded as an independent second route. The base-layer
  decision record names *this* recursion among the siblings that mirror the base one arm for arm,
  so switching only this copy would falsify that sentence.
- **`PlusStateLocal` is not involved**, correcting the dispatch's gloss: that module is the
  state-locality fragment of L⁺, a class of *formulas*. The object the carrying lemma is about is
  the history class, inlined in the `stab` clause of `PlusTruth.lean`.
- **The unification question is answered negatively and reported, not acted on.** The base, Plus
  and Open reversals cannot be collapsed behind one transport at the current layers:
  `TruthAntiIso` and `truthAt_of_truthAntiIso` are `Formula`-only, the clause layer supplies no
  recursor and no `reflectTime`, and L^▷ cannot be derived from L⁺ through `ofPlus` because
  `ofPlus` only reaches the image of L⁺. A generic transport needs a new `ReflectableLanguage`
  class carrying `reflectTime` plus an induction principle, with four or five instances — a design
  change. Also relevant to whoever attempts it: only two of the five object languages have a
  reversal transport today, and L⋆ would not inherit one for free, since `starTruthAt_timeShift`
  already shifts the stored-time vector separately.

## Plan Deviations

- **Phase 2, altered — one extra file.** C15 requires a paper anchor to be recorded *before* it is
  cited, and `cor:deterministic-completeness` had zero rows in
  `docs/reference/paper-definitions-of-record.md` while the plan mandated citing it. Verified the
  anchor is not live (its only occurrence in `possible_worlds.tex` is commented out; the live
  `\label` is in `appendix_cut_material.tex`), added a `DANGLING` row on the
  `cor:after-negation-stable` cut-material precedent, and made the citation site say so — which
  is what the record's own row-adding discipline requires.
- **Phase 2, altered — two extra files.** `check-metalogic-cycles.sh` requires a per-file layer
  row for every new language-directory module. Added `"PlusReversal": 1` to
  `scripts/measure-refactor-partitions.py` and the matching name to `ORGANISATION.md`, together,
  as the checker's own remediation text instructs. **This requirement was documented and the plan
  missed it**: `FormalSystem/PlusLanguage/README.md` states in bold that "A new file in this
  directory needs a row in that table". The lesson is to read a component directory's README
  before planning its registration surfaces.
- **Phase 3, altered — proof route refined.** The plan correctly warns that `fun w d => h w (-d)`
  fails, because `F.rev.TaskRel w x u` is `F.TaskRel u x w` definitionally. Its prescribed
  replacement `rw [FrameOver.rev_taskRel_neg]` **also** fails: `F.rev.TaskRel` is
  `F.toFibre.rev.TaskRel` only definitionally, so `rw` finds no syntactic occurrence of the
  pattern. The working route applies the lemma as an explicit term at `F.toFibre`. The plan's
  `rw [deterministic_iff]` step and its `[F.IsRegular]` reasoning are both still load-bearing.
- **Phase 5, timing.** `typst/generated/status.typ` had to be regenerated at *every* phase commit,
  not only in Phase 5: a pre-commit gate blocks any commit whose `.lean` diff moves the
  whole-tree line count, so the plan's Phase-5-only step was unreachable.
- **Phase 5, scope.** `FormalSystem/PlusLanguage/README.md` carries no paper-correspondence
  surface (unlike `OpenLanguage/README.md`), so that task bullet was skipped as the plan directs.
  The hand-maintained "What it carries" table in the same README was left alone: it is a third
  surface the plan does not name and it already omits `PlusRayFibre.lean`, so adding only this
  task's row would partially repair a surface outside this task's scope.

## Verification

- Build: **Success.** `lake-build-guard.sh build --no-share --timeout 1800 -- build` (un-narrowed,
  whole project): guard exit 0, zero `REPLAY` occurrences, `STATUS: exit_status=0`,
  `Build completed successfully (2859 jobs)`, zero `error:` lines, and `.olean` strictly newer
  than source on all six touched modules.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots: `sorry_count: 0`;
  `grep -c sorry PlusReversal.lean` returns 0; C3 PASSes).
- Vacuous count: **0 attributable**. The single textual match,
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`, is pre-existing (not
  in this task's diff) and is a genuine proof — the goal really does reduce to `True` for a total
  history over `ℤ`.
- Axiom count: **unchanged, 12 → 12** across identical pathspecs at the plan commit and at HEAD.
  Zero `+axiom ` lines in the `.lean` diff.
- All fifteen declarations confirmed in one compiled probe: each resolves fully qualified and
  depends only on `propext`, `Classical.choice`, `Quot.sound`. No `sorryAx`.
- `check-module-invariants.sh` (build-backed, un-narrowed): exit 0, **`ALL CHECKS PASSED`**, zero
  `FAIL` lines. C16's `env_linter` batch ran and passed — the batch that is silently skipped under
  `--no-build`. C33 confirms `FormalSystem.lean` is byte-for-byte the generated root at 693
  imports. C15 resolves all 84 anchors.
- `check-module-invariants.sh --emit-inventory --check`: exit 0.
- `lake exe checkInitImports` (C24): exit 0.
- `typst-sync-check.sh`: exit 0. `readme-lint.sh`: exit 0. `check-copyright-headers.sh`: exit 0.
  `check-phantom-citations.sh`: exit 0. `check-evidence-probes.sh`: exit 0,
  `all 33 wired probe(s) compile`.
- `check-paper-definitions.sh`: exit 1 — **reasoned exclusion**, inherited upstream paper drift.
- `check-metalogic-cycles.sh`: exit 1 — **reasoned exclusion**, inherited SURPLUS at HEAD.
- `verify-deploy.sh`: exit 0 but over **zero checks** — **reasoned exclusion**, a vacuous pass.
- The `assert_not_exists` guards in `Semantics/Truth.lean` and `Semantics/Reversal.lean` remain
  satisfied; the promoted lemma mentions only `WorldHistory.state`.
- No line over 100 characters in any new or edited file; no `file.lean:NNN` citation and no task
  number outside `specs/`.
- Files verified: Yes. Tests: covered by the full project build, which includes the test library.

## Impacts

- L⁺ now has the same reflection transport the base language and L^▷ have, so any L⁺ validity
  over a `rev`-closed class yields its mirror. `plusValidOnFrames_reflectTime` is the primitive
  and reaches classes no `FrameClass` tag denotes.
- The *Determined*-valid frames and the deterministic frames are both now known closed under
  reversal, which is the pair the paper's completeness result over the deterministic frames is
  stated about.
- `sameState_rev_iff` is available to every language layer rather than only to L^▷, and there is
  now exactly one copy of it.
- The Deterministic soundness TR case has a recorded, *verified* second route available to any
  future task that wants to simplify the four sibling recursions together.

## Follow-ups

- **Three reversal transports remain unified only by convention**, not by a shared abstraction.
  Reported above under Decisions; it needs a `ReflectableLanguage` class and is a design change.
- **`.claude/scripts/verify-deploy.sh` is a no-op in this repository** — `gate-registry.data` is
  absent from both the deployed tree and the source store, so it exits 0 over zero checks. Any
  plan or contract treating it as the aggregate gate is currently resting on nothing.
- **`lake-build-guard.sh` can replay a green result that never covered an edited file**, because
  `post_fingerprint` is taken at build end. See the issue log for the full reproduction.
- **The `LANGUAGE_FILE_LAYERS` table is itself incomplete**: `PlusRayFibre` has a row there but is
  missing from `FormalSystem/PlusLanguage/README.md`'s hand-maintained "What it carries" table.
  Left alone deliberately.
- **`check-paper-definitions.sh`'s ten-anchor drift wave** is live and owned elsewhere; the memory
  note on absorbing a drift wave before re-pinning applies to whoever takes it.

## References

- `specs/800_stability_time_reflection_transport/plans/01_stability-time-reflection-transport.md`
- `specs/800_stability_time_reflection_transport/reports/01_stability-time-reflection-transport.md`
- `specs/800_stability_time_reflection_transport/handoffs/` — one per phase, with the per-phase
  verification evidence
- `specs/800_stability_time_reflection_transport/issues.jsonl` — the issue and win log
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`, section "The
  stability logic and its completeness over the deterministic frames" — the specification
