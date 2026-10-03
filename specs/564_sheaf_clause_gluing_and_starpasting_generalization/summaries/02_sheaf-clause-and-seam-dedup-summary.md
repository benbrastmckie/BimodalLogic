# Implementation Summary: Task #564

- **Task**: 564 - sheaf_clause_gluing_and_starpasting_generalization
- **Status**: [COMPLETED]
- **Started**: 2026-10-03T12:27:00Z
- **Completed**: 2026-10-03T13:25:00Z
- **Effort**: ~1 hour
- **Dependencies**: None
- **Artifacts**: plans/02_sheaf-clause-and-seam-dedup.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The *Sheaf* clause of the presheaf dictionary landed as a new module
`FormalSystem/Semantics/Presheaf/Sheaf.lean`: the glued section in cut form, its two reading
equations, both restriction identities, uniqueness, the `∃!` packaging in raw-data and
site-indexed form, and the compatible-family theorem. In the same task the duplication the clause
would otherwise have created was removed: the seam-composition argument was extracted once as
`PartialHistory.rel_across_seam` with two independent seam coordinates, and
`PlusLanguage.paste_rel_le_lt` rewritten as a delegation to it at a byte-identical signature.
`paste` was additionally generalized off its totality hypothesis as `pasteAt`, with `paste`
recovered as a corollary and its own definition and signature untouched.

All four plan phases closed `[COMPLETED]`. Every mathematical obligation came from this task's
three compiled probes; no proof needed new tactic work, which is the evidence the transcription
held rather than drifted.

## What Changed

- `FormalSystem/Semantics/Presheaf/Sheaf.lean` — **new**, 12 declarations. `glue` (the glued
  section, cut form); `glue_states_le`/`glue_states_not_le` (the two reading equations, `dif_pos`
  and `dif_neg`); `restrict_glue_left`/`restrict_glue_right` (the restriction identities);
  `states_eq_of_eq`; `glue_unique`; `sheaf_clause`; `restrictTr_coverLeft`/`restrictTr_coverRight`
  (both `rfl`); `compat_iff_match`; `sheaf_clause_site`. Tier-3 module docstring carrying the
  two-sense choice-freedom record.
- `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory.rel_across_seam`, the seam
  argument stated once off totality with two independent seam coordinates, a duration parameter
  plus a splitting hypothesis, and an explicit `Compositional` hypothesis.
- `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.reflection_of_ne`, the binder-free off-zero
  reflection wrapper. It exists because `rw` cannot see through `TaskRel` to the underlying
  `reflect` pattern.
- `FormalSystem/PlusLanguage/PlusPasting.lean` — `paste_rel_le_lt` is now a four-line delegation
  to `rel_across_seam`; `paste_rel`'s mixed-orientation case routes through the off-zero
  reflection law; `pasteAt`, `pasteAt_states_le`, `pasteAt_states_not_le`, `isTotal_pasteAt` and
  `paste_eq_pasteAt` added **after** `paste`; module docstring updated twice.
- `FormalSystem/Semantics/Presheaf.lean` — one import line, one `## Modules` bullet.
- `FormalSystem/Semantics/Presheaf/README.md` — inventory re-emitted, Key Definitions and Key
  Results for both the raw and site-level declarations.
- `docs/reference/paper-definitions-of-record.md` — exactly two row descriptions amended
  (`app:gluing`, `app:presheaf-dictionary`), both statuses kept verbatim, neither anchor pinned.
- Regenerated, never hand-edited: `FormalSystem.lean`, `README.md`, `FormalSystem/README.md`,
  `FormalSystem/PlusLanguage/README.md`, `typst/generated/status.typ`,
  `scripts/lean-citation-manifest.json`.

## Decisions

- **The clause is stated in cut form `(l, p)`, not sum form.** `restrictTr (coverLeft …)` and
  `restrictTr (coverRight …)` are *definitionally* the raw-data restrictions, so the site-indexed
  clause follows by `rfl` with no transport and no cast. The sum form would have needed a
  dependent transport along `l₁ + l₂ - l₁ = l₂` at every statement.
- **The shared lemma carries two seam coordinates, not one.** A one-coordinate form covers the
  pasting instance but would force a time shift at the gluing call site, where the right-hand
  section's seam sits at its own origin `0` while the left-hand one sits at the cut point.
- **The duration is a parameter with a splitting hypothesis** rather than the literal sum, so each
  call site supplies its own arithmetic identity and no post-hoc rewrite is needed.
- **`Compositional` is taken explicitly, never as an `[F.IsRegular]` bundle.** The bundle would
  have supplied *Saturation* too and made the saturation-independence claim unreadable from the
  signature.
- **No `Constraints consumed:` marker anywhere.** All constraint discussion stays inside `/-!`
  blocks, whose span C34b does not read.
- **`app:gluing` is cited as a pointer and never quoted**, so its `LIVE-UNPINNED` row's own stated
  reason ("no docstring quotes its text") remains true.
- **Declaration names, never `file.lean:NNN`**, in every docstring and README line written here.

## Plan Deviations

- **Phase 1** altered: one shared touch beyond the plan's four-row **Shared Touches** table.
  Inserting into `PartialHistory.lean` shifted three recorded declaration spans and failed C35, so
  `scripts/lean-citation-manifest.json` was regenerated with
  `python3 scripts/export-lean-citations.py` — the fix the gate itself names. Regenerated, never
  hand-edited, and confirmed clean of foreign modification beforehand.
- **Phase 4** altered: `linter.style.show` fired on `paste_eq_pasteAt`'s `show`, which was
  replaced by `change` — identical tactic semantics, and this plan's own Phase 2 remedy for that
  linter. No `scripts/warning-budget.txt` row was added.
- No phase was cut. Phase 4, the pre-authorized droppable one, was completed in full.

## Verification

- Build: **Success**. Full-project `lake build` green, 2812 jobs, guard `exit_status=0`, zero
  `error:` across both captured streams. `defaultTargets = ["FormalSystem"]`, so the bare
  `lake build` and `lake build FormalSystem` are the same target here; `lake build BimodalTest`
  was additionally run green (2873 jobs, exit 0) because the test library consumes `PlusPasting`.
  Olean freshness confirmed for all five touched modules.
- Sorry count: **0** (baseline 0)
- Vacuous count: **0** attributable. The scan's single match (`int_domain_universal`,
  `FormalSystem/Examples/TemporalStructures.lean`) predates this task, sits in a file this task
  never touched, and is a genuine proof rather than a placeholder.
- Axiom count: **14**, unchanged from baseline. No `axiom` declaration added.
- Tests: Passed (`lake build BimodalTest`, 2873 jobs, exit 0)
- Files verified: Yes

### Choice-freedom, measured not asserted

| Declaration | Axioms |
|---|---|
| `TaskFrame.reflection_of_ne` | `[propext]` |
| `PartialHistory.rel_across_seam` | `[propext, Quot.sound]` |
| `PlusLanguage.paste_rel_le_lt` | `[propext, Quot.sound]` |
| `PlusLanguage.paste_rel` | `[propext, Quot.sound]` |
| `PlusLanguage.paste` | `[propext, Quot.sound]` — **`Classical.choice` cleared** |
| `Presheaf.glue` | `[propext, Quot.sound]` |
| `Presheaf.glue_states_le`, `glue_states_not_le` | `[propext, Quot.sound]` |
| `Presheaf.restrict_glue_left`, `restrict_glue_right` | `[propext, Quot.sound]` |
| `Presheaf.states_eq_of_eq` | `[propext]` |
| `Presheaf.glue_unique` | `[propext, Quot.sound]` |
| `Presheaf.sheaf_clause` | `[propext, Quot.sound]` |
| `Presheaf.restrictTr_coverLeft`, `restrictTr_coverRight` | `[propext, Quot.sound]` |
| `Presheaf.compat_iff_match` | `[propext, Quot.sound]` |
| `Presheaf.sheaf_clause_site` | `[propext, Quot.sound]` |
| `PlusLanguage.pasteAt` | `[propext, Quot.sound]` |
| `PlusLanguage.pasteAt_states_le`, `pasteAt_states_not_le` | `[propext, Quot.sound]` |
| `PlusLanguage.isTotal_pasteAt` | `[propext, Quot.sound]` |
| `PlusLanguage.paste_eq_pasteAt` | `[propext, Quot.sound]` |

`paste` entered the task at `[propext, Classical.choice, Quot.sound]`. Its dropping
`Classical.choice` is the observable proof that the reflection reroute took, and
`paste_eq_pasteAt` — which mentions `paste` — is an independent second observable of the same
fact.

### Gate exit codes

| Gate | Exit | Note |
|---|---|---|
| `lake-build-guard.sh ... -- build` | 0 | 2812 jobs, 0 `error:` |
| `lake-build-guard.sh ... -- build BimodalTest` | 0 | 2873 jobs, 0 `error:` |
| `check-module-invariants.sh --no-build` | 1 | **Pre-existing** C15 theorem-index row only — see below |
| `check-module-invariants.sh --emit-inventory --check` | 0 | INV green |
| `readme-lint.sh FormalSystem` | 0 | RESULT PASS |
| `check-copyright-headers.sh --strict FormalSystem` | 0 | 0 missing of 646 |
| `typst-sync-check.sh --counts-only` | 0 | the pre-commit hook's own check |
| `check-paper-definitions.sh` | 1 | **Pre-existing** `def:BX` drift — see below |

Within `check-module-invariants.sh`, C6, C8, C9, C15's *anchor* half (65 anchors resolve), C20
(all three tiers), C26, C31 (224 bibkey citations, 24 keys, both `schultz2020` and
`johnstone1999` resolving), C33 (byte-exact root, 646 imports), C34a, C34b and INV all PASS. C24
is build-gated and reports skipped under `--no-build`; the green full build is the stronger check.

### Two pre-existing failures, reported rather than fixed

Both were measured **before** any edit and are unchanged by this task:

1. **C15, theorem-index half** — one of 240 rows,
   `...PlusSlicedCertificate.NoFiniteWidth.not_plusValidZTime_neg_Φ`, is not anchored at its
   declaration. It failed at baseline. `docs/theorem-index.md` is an explicit non-goal of this
   plan and belongs to another task's territory.
2. **`check-paper-definitions.sh`, exit 1** — the `def:BX` drift, from the paper renaming axiom
   `SU` to `US`. The gate's reported anchor set is byte-identical to the pre-edit baseline and
   names none of this task's three anchors.

### Scope Hypotheses, all four confirmed

| Phase | Predicted | Measured |
|---|---|---|
| 1 | 2 new declarations, 2 rewritten bodies, 3 `.lean` files, no signature line changed | exactly that; `git diff -U0` shows no signature hunk |
| 2 | 8 declarations in `Sheaf.lean` | `grep -c` reads **8** |
| 3 | 4 more declarations, exactly 2 amended anchor rows | reads **12**; diff touches exactly 2 rows |
| 4 | 5 declarations, `PlusPasting.lean` alone, no hunk in `paste` | exactly that; 106 insertions, **0 deletions** |

### Transcription audit

All three probes reproduce against the post-task tree at exit 0:
`probes/01_seam-lemma-and-glue.lean`, `probes/02_site-and-compatible-family.lean`,
`probes/03_pasteat-off-totality.lean`.

## Impacts

- `PartialHistory.rel_across_seam` is now the single home of the seam-composition argument, and is
  the shared asset the directed-gluing and totality clauses of the dictionary will reuse rather
  than re-derive. The duplication this task existed to prevent is closed.
- `PlusLanguage.paste` is now choice-free, which propagates to every consumer measuring axioms
  through it — including the six pasting validities and their `*_plusValid` packagings, none of
  which moved.
- `sheaf_clause_site` closes the loop `Site.lean`'s `cover_germ_composites` docstring opened: the
  coverage's two covering morphisms meet in one point, and the sheaf condition over that coverage
  now holds as a theorem.
- Two clauses of `app:presheaf-dictionary` — *Germs* and *Sheaf* — are now formalized.

## Follow-ups

- Moving `partialHistory_ext` down into `Semantics/PartialHistory.lean` remains the recorded
  follow-up it was before this task; `Sheaf.lean` consumes it from `Behavior.lean` and adds no new
  reason to defer, but also no new reason to churn `Behavior.lean` here.
- The sum-form `(l₁, l₂)` corollary and its `Beh.cast` transport were declined a phase and remain
  undone; `l := l₁ + l₂`, `p := l₁` recovers it from the cut form.
- The directed/ω-indexed gluing clause, and the *Totality*, *Possible Worlds*, *Determinism* and
  *Reflection* clauses of the dictionary, are untouched. Directed gluing is the case that does
  rest on *Saturation*, through the Extension Theorem.
- Neither `app:gluing` nor `app:presheaf-dictionary` was pinned, and no attempt was made to; both
  keep their recorded statuses.

## References

- `specs/564_sheaf_clause_gluing_and_starpasting_generalization/plans/02_sheaf-clause-and-seam-dedup.md`
- `specs/564_sheaf_clause_gluing_and_starpasting_generalization/reports/02_sheaf-clause-and-seam-dedup.md`
- `specs/564_sheaf_clause_gluing_and_starpasting_generalization/reports/01_finite-vs-directed-gluing-findings.md`
- `specs/564_sheaf_clause_gluing_and_starpasting_generalization/probes/01_seam-lemma-and-glue.lean`
- `specs/564_sheaf_clause_gluing_and_starpasting_generalization/probes/02_site-and-compatible-family.lean`
- `specs/564_sheaf_clause_gluing_and_starpasting_generalization/probes/03_pasteat-off-totality.lean`
- `specs/564_sheaf_clause_gluing_and_starpasting_generalization/handoffs/` — the four phase-end
  handoffs, each carrying that phase's own measurements
