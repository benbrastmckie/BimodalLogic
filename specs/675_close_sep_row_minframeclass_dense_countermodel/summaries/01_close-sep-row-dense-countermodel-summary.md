# Implementation Summary: Task #675

- **Task**: 675 - Close the sep row of Axiom.minFrameClass by constructing a densely ordered countermodel
- **Status**: [COMPLETED]
- **Started**: 2026-09-25T19:45:00Z
- **Completed**: 2026-09-25T21:30:00Z
- **Effort**: ~1.75 hours
- **Dependencies**: None (`DenseRTimeSharpness.lean`, `ZTimeSharpness.lean`, `Soundness.lean` landed)
- **Artifacts**: plans/01_close-sep-row-dense-countermodel.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The `sep` row of `Axiom.minFrameClass` — the last row carrying only the upper bound from
`axiom_validIn_min` — is now closed, and in fact characterized. A new module
`FormalSystem/Metalogic/Independence/SepSharpness.lean` refutes `Axiom.sep`'s atomic instance at
frame level over the translation frame on the Hahn group `Lex (ℚ →₀ ℚ)`, which closes `.Base` and
`.Dense` (the only two classes strictly below `.RTime`) from a single refutation. A separate
positive result settles `.ZTime`, so the row admits an exhaustive characterization rather than
mere minimality. All five phases of the plan completed; the work was transcription of proof text
the research phase had already machine-checked end to end, so no proof search was needed.

## What Changed

- `FormalSystem/Metalogic/Independence/SepSharpness.lean` — **created** (439 lines). Carries:
  - `LexHahn` (the Hahn group `⊕_{γ∈ℚ} ℚ`), the `DenselyOrdered` instance Mathlib does not
    supply, `sepSharpOrder`, the generator `sepGen`, and the φ-region `sepRegion`.
  - Six order helpers: `sepGen_apply`, `sepGen_pos`, `sepGen_lt_of_index_lt`,
    `lt_sepGen_of_lt_index`, `pos_index`, `sepGen_lt_sepGen`.
  - Three accumulation facts: `exists_mem_sepRegion_lt`, `not_gapped_successor_sepRegion`,
    `exists_sepRegion_free_interval`.
  - `not_validOn_sep_lexHahn` — the frame-level refutation.
  - `not_validIn_base_sep`, `not_validIn_dense_sep`, `sep_minFrameClass_sharp` — the closed row.
  - `isLeastPos_of_succOrder`, `sep_validIn_ztime` — the positive `.ZTime` result.
  - `sep_validIn_iff` — the exhaustive characterization.
  - `not_derivable_dense_sep` — underivability through `soundness_validIn`.
  - One `example … := Axiom.sep φ` shape pin, so formula transcription is a compiler obligation.
- `FormalSystem/Metalogic/Independence.lean` — import added; ledger count Eleven → Twelve; item 11's
  now-false closing sentence rewritten; new item 12; `## Contents` bullet added and the
  `DenseRTimeSharpness.lean` bullet repointed.
- `FormalSystem/Metalogic/Independence/README.md` — the same three ledger edits in the README's own
  numbering; three new `## Key Results` entries; a new countermodel-kit subsection "When one
  infinitesimal level is not enough"; the `SepSharpness.lean` inventory description (pipe-free)
  and a correction to the `DenseRTimeSharpness.lean` description.
- `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` — docstrings only. The module
  docstring's "The `sep` row" section and the Row 4 section docstring no longer survey three
  candidate routes; they record the row as closed, note that route 1 is refuted and route 3
  excluded on cost, and state that `sep_validOn_of_isLeastPos` is now *consumed* by
  `sep_validIn_ztime` rather than merely a boundary. No declaration added, changed or removed —
  `not_kPlus_of_isLeastPos` and `sep_validOn_of_isLeastPos` are both still present.
- `FormalSystem/ProofSystem/Axioms.lean` — `Axiom.minFrameClass` docstring only. "every row but
  one is also known minimal" → "every row"; the "`sep` is the one row still carrying the upper
  bound only" paragraph replaced by an "RTime row, `sep`" bullet citing
  `sep_minFrameClass_sharp` and `sep_validIn_iff` and stating the `.ZTime` divergence explicitly.
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` — one docstring sentence in its
  `## Scope` section, which claimed the two `.RTime` rows "remain upper-bound-only".

## Decisions

- **`sep_validIn_iff` states `ValidIn fc φ ↔ fc = .ZTime ∨ .RTime ≤ fc`, not `↔ .RTime ≤ fc`.**
  The latter is false: `.RTime ≰ .ZTime`, yet `sep` is `.ZTime`-valid, because `IsZTime` supplies
  a `SuccOrder` and hence a least positive duration, feeding `sep_validOn_of_isLeastPos`. Copying
  `density_validIn_iff`'s shape mechanically would have stated something false. This is the one
  place the `sep` row's shape genuinely diverges from `prior_U_gap`'s.
- **A new sibling module rather than extending `DenseRTimeSharpness.lean`**, which is already 409
  lines and whose subject is the `.Dense` rows; the Hahn carrier brings ~90 lines of
  `Finsupp.Lex` order machinery unrelated to them.
- **Every helper stated at the bare `LexHahn` abbreviation, never at `(sepSharpOrder : Type)`.**
  Forced, not stylistic: `ofLex r j` does not elaborate at `TemporalOrder.carrier`.
- **`K⁺φ` refuted at every `r > 0`, rather than `K⁻φ` or the conjunction.** A two-way split on
  `sepGen i ≤ r` suffices; the `K⁻` route would force a three-way split on the leading
  coefficient.
- **`DenselyOrdered (Lex (ℚ →₀ ℚ))` kept local**, with the Mathlib-shaped generalisation recorded
  in the module docstring as an upstreaming candidate for `FormalSystem/ForMathlib/Order/`. A new
  `ForMathlib/` file is a recorded exception requiring coordinated init-import-checker edits,
  churn out of proportion to a fourteen-line instance.
- **Route 1 recorded as refuted, route 3 as excluded-by-cost** — not conflated.

## Plan Deviations

- **Phase 4, `ZTimeSharpness.lean`** altered: the plan's `## Files to modify` list named five
  files; a sixth needed editing. Its `## Scope` section claimed the two `.RTime` rows "remain
  upper-bound-only", which was already stale for `prior_U_gap` and becomes fully false with `sep`
  closed. This was found by the phase's own mandated scope-hypothesis grep, which the plan wrote
  specifically to catch a missed occurrence of the now-false claim, so it is the plan's own check
  firing rather than a scope renegotiation. Docstring-only; no declaration touched.

## Verification

- Build: **Success**. Full `lake build` through
  `.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached. All three verdict
  tiers pass: guard `exit_status=0`; "Build completed successfully (2737 jobs)" with zero `error:`
  lines across both captured streams; and `.olean` newer than source for every module this task
  touched (`SepSharpness`, `Independence`, `DenseRTimeSharpness`, `ZTimeSharpness`,
  `ProofSystem.Axioms`, `MainResults`).
- **Two full builds were spent, not the one the plan budgeted.** The first build is what made two
  gate findings visible, neither of which can be raised earlier: C28 flagged a new
  `linter.style.longLine` warning produced by the Phase 4 `ZTimeSharpness.lean` docstring
  sentence, and C33 flagged that the generated root `FormalSystem.lean` did not yet import the new
  module (remedy: `lake exe mk_all --lib FormalSystem`, never a hand edit). Both fixes change
  `.lean` files, so a rebuild was unavoidable; it ran incrementally off the first build's cache.
  Re-checked per the plan's instruction: the cause was not an `--emit-inventory` side effect and
  not a Phase 4 edit leaking outside a docstring — every `Axioms.lean` and
  `DenseRTimeSharpness.lean` hunk is still strictly inside a docstring region.
- `scripts/check-module-invariants.sh`: exit 0, green across all check groups, including C2 (all
  four flagship axiom sets match baseline) and C3 (structural sorry inventory ZERO across
  `FormalSystem/` and `BimodalTools/`).
- Sorry count: 0 (`lean-sorry-census.sh` over all resolved source roots).
- Vacuous count: 0 introduced by this task. The tree-wide single-line grep reports 1 hit,
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`, byte-identical at the
  pre-task baseline and outside this task's scope; this task's diff introduces none.
- Axiom count: 14, unchanged from the pre-task baseline. No `axiom` declaration added.
- `#print axioms` on `sep_minFrameClass_sharp`, `sep_validIn_iff`, `sep_validIn_ztime`,
  `not_validOn_sep_lexHahn`, `not_derivable_dense_sep`, `not_validIn_base_sep` and
  `not_validIn_dense_sep`: `[propext, Classical.choice, Quot.sound]` on every one.
- `scripts/readme-lint.sh`: PASS (0 missing READMEs, 0 broken file references). No
  `file.lean:NNN` line-number citation was introduced into any `README.md` under `FormalSystem/`.
- `scripts/check-module-invariants.sh --emit-inventory`: run after the last docstring edit;
  reports "no generated inventory block needed a rewrite".
- Tests: N/A (no test-suite change; the countermodel is itself the verification).
- Files verified: Yes.

## Impacts

- `Axiom.minFrameClass` now has **every** row known minimal, and every non-`.Base` row
  characterized outright. The `Axioms.lean` docstring, both Independence ledgers, and
  `DenseRTimeSharpness.lean`'s and `ZTimeSharpness.lean`'s scope prose all say so consistently;
  no surface still describes `sep` as open.
- `sep_validOn_of_isLeastPos` gains a consumer (`sep_validIn_ztime`) and so must not be retired;
  this is now recorded in `DenseRTimeSharpness.lean`'s Row 4 docstring.
- The `Independence/README.md` countermodel kit gains the infinitely-many-levels carrier pattern
  and the two `Finsupp.Lex` elaboration traps, which the existing kit did not cover.

## Follow-ups

- The generalised `[LinearOrder α] [AddCommGroup N] [LinearOrder N] [DenselyOrdered N] →
  DenselyOrdered (Lex (α →₀ N))` is a genuine Mathlib-shaped upstreaming candidate for
  `FormalSystem/ForMathlib/Order/`; deliberately not taken here.
- **Concurrency note, not a defect of this task**: sibling task 676 was live on this working tree
  throughout and committed several times during these phases. Its inventory regeneration picked
  up this task's new module mid-flight, so the generated count blocks in
  `FormalSystem/Metalogic/README.md` and the root `README.md` were updated by that run rather than
  by this one. Those two files were left for task 676 to commit; they are purely generated blocks
  and are correct either way.

## References

- `specs/675_close_sep_row_minframeclass_dense_countermodel/plans/01_close-sep-row-dense-countermodel.md`
- `specs/675_close_sep_row_minframeclass_dense_countermodel/reports/01_close-sep-row-dense-countermodel.md`
- `specs/675_close_sep_row_minframeclass_dense_countermodel/handoffs/` — per-phase handoffs 1-4
- `FormalSystem/Metalogic/Independence/SepSharpness.lean`
