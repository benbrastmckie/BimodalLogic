# Implementation Summary: Task #833

- **Task**: 833 - Land the definability biconditional `⊡φ ↔ ▷◁φ` in OpenLanguage, with its ledger and README rows
- **Status**: [COMPLETED]
- **Started**: 2026-11-04T22:33:42Z
- **Completed**: 2026-11-04T22:50:00Z
- **Effort**: 0.3 hours
- **Dependencies**: None declared. Shared-file serialization against 761 and 763 on `docs/theorem-index.md`
- **Artifacts**: plans/01_stab-definable-from-open-modals.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Transcribed six already-compiled declarations from probe 05 of task 559 into
`FormalSystem/OpenLanguage/`, landing `⊡φ ↔ ▷◁φ ↔ ◁▷φ` as library results rather than a probe:
four pointwise results in `OpenTruth.lean` and both implications as `OpenValid` in
`OpenValidity.lean`. Landed the three documentation surfaces the task owns — the component
README's per-file Description cells and a paper-label correspondence row, the regenerated
inventory block, and six rows in `docs/theorem-index.md`. This was a transcription, not a proof
search: every statement is the probe's verbatim, unweakened, and every measured axiom set is
unchanged from the probe's.

## What Changed

- `FormalSystem/OpenLanguage/OpenTruth.lean` — new section `## ⊡ is definable: ⊡φ ↔ ▷◁φ ↔ ◁▷φ`
  with `stab_to_ofut_opast` (the `→` half, the two class inclusions at the point of evaluation, no
  frame axiom and no `[F.IsRegular]`), `ofut_opast_to_stab` (the `←` half, `[F.IsRegular]`, one
  `paste` via `paste_agreeUpTo`/`paste_agreeFrom`), and the two pointwise biconditionals
  `stab_iff_ofut_opast` and `stab_iff_opast_ofut`; plus one `## Main Results` bullet. 67
  insertions, zero deletions; 288 → 355 lines.
- `FormalSystem/OpenLanguage/OpenValidity.lean` — the same section heading with
  `openValid_stab_imp_ofut_opast` and `openValid_ofut_opast_imp_stab`, both in the surrounding
  block's house style (`OpenValid.of_forall_regular fun _ _ M τ t h => …`, which consumes the
  `FrameClass.Base` membership and registers `[F.IsRegular]`, so no `_hF` binder and no
  unused-binder warning); plus one `## Main Results` bullet. 30 insertions, zero deletions;
  229 → 259 lines.
- `FormalSystem/OpenLanguage/README.md` — Description cells of the `OpenTruth.lean` and
  `OpenValidity.lean` inventory rows extended with the new identifiers (Lines cells left entirely
  to the generator); one new paper-label correspondence row, `` `app:gluing` (two histories),
  operator form ``, placed immediately after the row it extends and labelled
  **formalization-native**. No new paper anchor was introduced.
- `README.md` (repository root) — generated metrics block only, rewritten by
  `check-module-invariants.sh --emit-inventory`. See Plan Deviations.
- `docs/theorem-index.md` — six rows appended to the `### L^▷` section in declaration order, each
  with paper label `—`, a fully-qualified Lean name, a file path with no line number, frame class
  `Base`, and a literal axiom cell.
- `typst/generated/status.typ` — generated line-count stamp only. See Plan Deviations.

All six declarations carry a `Paper: — (formalization-native; the manuscript sets the restricted
modals aside and states no such equation)` doc-comment line, which is what C15's second assertion
requires of every `docs/theorem-index.md` row key.

## Decisions

- `stab_iff_opast_ofut` uses the probe's **direct** proof — the same paste with the two histories
  exchanged via `hs.symm` — and its docstring says so without offering the
  `openValid_reflectTime` alternative. The research report established that the reversal route is
  structurally unavailable from this module (`OpenReversal.lean` imports `OpenValidity.lean`
  imports `OpenTruth.lean`, so it would be an import cycle), and it is validity-level where this
  statement is pointwise. A docstring claiming the route was available and declined would be a
  defect; the dispatch's "implementer's call" framing does not apply.
- The two `OpenValid` statements are spelled in `OpenValidity.lean`'s house style
  (`imp (stab φ) (ofut (opast φ))` under `open … OpenFormula`) rather than the probe's
  dot-notation. The plan sanctions this explicitly as a spelling choice; the measured axiom sets
  confirm the two spellings are the same term.
- The research report's unverified claim that `OpenValid.of_forall_regular` is axiom-identical to
  the probe's raw lambda was confirmed by measurement, not assumed.
- The optional `OpenClasses.lean` class-level corollary was **omitted**, per the plan: no consumer
  exists, and a theorem with no consumer is not worth an INV row. Its statement and the
  `paste_agreeFrom`-not-`.2` gotcha are recorded in the research report for a later task.
- Axiom cells are written literally (`[propext]`, `[propext, Quot.sound]`) with no `pinned:`
  token, since the ledger's `pcq` abbreviates exactly `[propext, Classical.choice, Quot.sound]`
  and C2/C14 pinning is out of scope. Writing `pcq` would have claimed choice these proofs do not
  use.

## Plan Deviations

- **No deviation on any plan task or any Lean statement.** Every phase executed its task list as
  written, in order; no step was skipped, altered, or deferred.
- **Two generator-owned files outside the plan's declared `Files to modify` blocks were carried in
  the phase commits.** Neither was hand-edited.
  - `typst/generated/status.typ`: the pre-commit `typst-sync-check.sh` Check 2 gate blocks a
    commit whose Lean line count drifts from this stamp. The drift was exactly this task's added
    lines (377507 → 377604 across the two code phases), so the gate's own documented remedy
    (`bash scripts/typst-sync-check.sh --fix`) was run and the file staged, rather than bypassing
    with `git commit --no-verify` — the bypass is legitimate only for another writer's drift, not
    one's own.
  - `README.md` (repository root): `check-module-invariants.sh --emit-inventory` rewrites its
    generated metrics block as well as the component README's inventory block, because that block
    carries live lines-of-code and comment-line counts.

  Both are recorded in `issues.jsonl`. The plan's Phase 3 `Files to modify` block should have
  listed the root README, and no phase anticipated the typst stamp.

## Verification

- **Build**: Success. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (unscoped) exit 0, 2895 jobs, 0 errors, 0 warnings. Verdict read at all three tiers: the
  guard's own exit status, the success line with a zero `error:` count over both captured streams,
  and an `.olean`-newer-than-source check on both touched modules. A full unscoped build was also
  run at the end of each code phase, not only at the end.
- **Sorry count**: 0 (`lean-sorry-census.sh` over all four resolved source roots:
  `sorry_count: 0`, empty inventory). Zero `sorry` under `FormalSystem/OpenLanguage/`.
- **Vacuous count**: 0 introduced. The single repository-wide hit of the vacuous-pattern grep,
  `FormalSystem/Examples/TemporalStructures.lean:495 int_domain_universal … := trivial`, is
  pre-existing (landed under task 756) and is a genuine proof — `intTimeHistory.domain t` unfolds
  to `True` — not a placeholder. This task introduced no `:= True` / `:= Unit` / `:= trivial`
  body.
- **Axiom count**: 14, unchanged from the pre-implementation commit. No `axiom` declaration added.
- **Axiom sets, measured twice by two mechanisms** — `lean_verify` per declaration, then an
  independent compiled `#print axioms` batch over all six. Both agree, and both match the pinned
  sets exactly, **choice-free throughout**:
  - `[propext]`: `FormalSystem.OpenLanguage.stab_to_ofut_opast`,
    `FormalSystem.OpenLanguage.openValid_stab_imp_ofut_opast`
  - `[propext, Quot.sound]`: `ofut_opast_to_stab`, `stab_iff_ofut_opast`, `stab_iff_opast_ofut`,
    `openValid_ofut_opast_imp_stab`

  No declaration picked up `Classical.choice`, so the predicted regression (routing the `←` half
  through something other than `paste`) did not occur.
- **`bash scripts/check-module-invariants.sh`**: asserted per-check, not by exit code, against
  baselines re-measured in this dispatch before any edit.
  - `PASS INV` — every generated inventory block current; `--emit-inventory --check` reports the
    block byte-stable, exit 0.
  - `PASS C2` — all fifty pinned axiom sets match baseline.
  - `PASS C15` — all 93 paper-anchor citations resolve (count unchanged: no new anchor).
  - `PASS C15` — all 319 theorem-index rows carry their anchor at the declaration (313 → 319,
    exactly the six new rows).
  - Exit 1 is the pre-existing C16 `env_linter` finding only. Its finding list is byte-identical
    to the pre-edit baseline except the declaration count, 17417 → 17423 — exactly this task's six
    new declarations — still exactly one error, on
    `mem_cellAt_of_shift_of_hasForwardSlack` in
    `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` (761/836 territory, not this
    task's to fix). `lake exe runLinter --update` was not run.
- **`bash scripts/check-metalogic-cycles.sh`**: exit **0**, with
  `PASS upward import set is exactly the recorded 8 line(s)`. This confirms the plan's inversion
  of the dispatch's stale note: the task-828 condition is resolved, so exit 0 was required rather
  than exit 1 waved through. This task adds no import at all, and the two other PASS assertions
  (one directory-level cycle; no syntax module importing a semantics module) also hold.
- **Statement fidelity**: all six landed signatures match the plan's `## Lean Challenge
  Statements` section verbatim, modulo the sanctioned house-style respelling of the two
  `OpenValid` statements. No hypothesis added, no binder specialised, no `[F.IsRegular]` instance
  dropped or added.
- **Forbidden-claim sweep** over every added line across the five changed content files: no
  occurrence of gap closure, limit closure, `LC_n`, `blc`, `plus_incomplete_base`, or
  L⁺-undefinability of the open-future modal. Every docstring and both README cells state the
  product structure of `⟨τ⟩_x` and nothing more.
- **`bash .claude/scripts/validate-artifact.sh … plan`**: `[PASS] plan artifact is valid
  (0 warning(s))`.
- **Tests**: N/A — no test file was touched and this task declares none.
- **Files verified**: Yes.

## Impacts

- Task 559's item (P0a) is discharged: its next round can cite
  `FormalSystem.OpenLanguage.stab_iff_ofut_opast` as a library declaration rather than a probe
  under its own `probes/` directory. 559 declares a dependency on this task precisely for that
  durable citation, and cannot land this itself — its hard constraints forbid any change under
  `FormalSystem/` or `Tests/`.
- `PlusLanguage.PlusRayFibre.plusStab_iff_rays` now has an object-language counterpart: `⊡` as a
  quantifier over pairs of a past ray and a future ray agreeing at the seam state, with `▷` and
  `◁` as the two projections. That is the two-sided decomposition device named in task 559's
  report 03 §4.
- The product structure of `⟨τ⟩_x` is now available to any L^▷ module at the operator level, not
  only at the class level through `openFutureClass_inter_openPastClass` and
  `paste_mem_openFutureClass_inter_openPastClass`.

## Follow-ups

- **Nothing here closes any gap, and nothing in this task should be read as doing so.** No
  limit-closure principle is supplied: `plus_incomplete_base` stands exactly as proved, `blc`
  remains a non-theorem, and an `LC_n`-style schema is still required in L^▷ exactly as in L⁺.
- **`▷` is not shown undefinable in L⁺.** Nothing in the tree establishes that; it is task 559's
  item (P0b) and it is open. The landed results separate the **operators**, not the languages.
- Optional and deliberately out of scope: pinning the six declarations' axiom sets in
  `scripts/check-module-invariants.sh` (C2/C14). The ledger cells are literal and unpinned, in
  line with 87 existing unpinned rows. Declaring that script here would have added a second
  contention point with the Stage 1 critical path for no gain; file it separately if wanted.
- Also optional and omitted: a class-level corollary in `OpenClasses.lean` stating `stabClass τ x`
  as the union over `openFutureClass τ x` of the open-past classes. Verified provable, no consumer
  today.
- Two small plan-hygiene gaps worth carrying into future plans that touch Lean line counts: the
  `typst/generated/status.typ` pre-commit gate and the root `README.md` metrics block are both
  moved by any change to Lean line counts, and neither appeared in a `Files to modify` block.

## References

- `specs/833_stab_definable_from_open_modals/plans/01_stab-definable-from-open-modals.md` — the plan executed
- `specs/833_stab_definable_from_open_modals/reports/01_stab-definable-from-open-modals.md` — the research report whose measurements and seven findings the plan is built on
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/05_stab-definable-from-open-modals.lean` — the compiled source of the six declarations
- `specs/833_stab_definable_from_open_modals/handoffs/` — the four phase-end handoffs
- `specs/833_stab_definable_from_open_modals/issues.jsonl` — the two generator-owned-file deviations and the clean-transcription win
