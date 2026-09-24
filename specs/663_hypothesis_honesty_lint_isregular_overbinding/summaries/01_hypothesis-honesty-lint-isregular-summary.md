# Implementation Summary: Task #663

- **Task**: 663 - Add a repo-wide hypothesis-honesty gate so no constraint-independence claim
  silently carries the bundling `IsRegular` class
- **Status**: [COMPLETED]
- **Started**: 2026-09-24
- **Completed**: 2026-09-24
- **Effort**: ~7 hours (plan estimate: 11)
- **Dependencies**: Task "settle S1 vs directedness and restore Saturation" (landed; its Phase 3
  established the explicit-hypothesis-plus-corollary pattern this task generalizes)
- **Artifacts**: plans/01_hypothesis-honesty-lint-isregular.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

A `[F.IsRegular]` instance binder supplies all four of `def:frame`'s constraints at once, so a
declaration whose statement, name or docstring asserts that a result holds *without* one of them
was making a claim its own binder contradicted — vacuous as a minimality claim, and invisible at
every call site. The eight declarations that made such a claim are now restated at the hypotheses
their proofs actually consume, each original surviving as a one-line corollary with a
byte-identical signature; the six declarations that genuinely consume *Saturation* are marked
rather than changed; a `Constraints consumed:` docstring line is documented as the repository's
fourth normal form; and invariant **C34** gates the marked sites and prints a per-run census, so
the classification is re-runnable rather than a one-time human read.

This was deliberately not a blanket unbundling. For ordinary soundness, validity and transfer
theorems `[F.IsRegular]` remains the correct ambient hypothesis, and 194 binder-carrying
declarations were left exactly as they were.

## What Changed

- `FormalSystem/Semantics/Extension/Constraint.lean` — seven explicit-hypothesis restatements
  with seven demoted corollaries: `fib_zero_subset_of_compositional_limit`,
  `fib_zero_subset_mem_of_compositional_limit`, `nonempty_fib_of_serial_limit`,
  `nonempty_seg_of_compositional_limit`,
  `nonempty_of_mem_Constraints_of_compositional_serial_limit`,
  `exists_mem_subset_inter_of_compositional_limit` and the flagship
  `constraint_of_compositional_serial_limit`. Marker lines on all fourteen, plus the three
  pre-existing matched pairs from the prerequisite task.
- `FormalSystem/Semantics/Extension/Admissible.lean` — `admissible_of_serial_limit` at
  `(hser, hlim)`, with `admissible` demoted to a one-line corollary.
- `FormalSystem/Semantics/Extension/{Step,Extension,Completion}.lean`,
  `FormalSystem/Semantics/Correspondence/RigidityReal.lean` — marker lines only, on the six
  genuine *Saturation* consumers; comment-region diffs exclusively, proven with the same masker
  the gate uses.
- `FormalSystem/Semantics/Validity.lean` — one marker line on `not_validOn_bot`, demanded by the
  C34b soft run.
- `scripts/check-module-invariants.sh` — invariant C34: census (ungated), C34a (structural,
  enforced), C34b (trigger, soft), a four-condition anti-silence guard, a twelve-case fixture
  self-test, `ENFORCE_C34A`/`ENFORCE_C34B`, table-driven over `(class, field-vocabulary)` pairs.
- `docs/development/REFERENCE_NORMAL_FORM.md` — `## 3. The constraint-consumption line`.
- `docs/development/MODULE_INVARIANTS.md` — the C34 row.
- `README.md` — regenerated inventory block (line counts moved).

## Decisions

- **The marker is a consumption enumeration, not an independence assertion.** The listed
  constraints are the whole of what the elaborated term reaches, so every unlisted one is thereby
  *claimed* unconsumed. That shape subsumes the independence claim and also fits the honest
  *Saturation* consumers, so the audit record covers the whole population instead of only its
  defects — and it avoids colliding with `FormalSystem/Metalogic/Independence/`, which means
  logical independence of proof-system axioms.
- **C34a's discharge is delegation.** The plan's literal C34a ("a marker omitting *Saturation*
  ⇒ no `IsRegular` in the declaration's code") contradicted its own Phase 3, which instructs that
  each demoted corollary carry a marker while keeping its binder: C34a would have failed on
  precisely the declarations the task was told to create. C34a therefore passes a binder-carrying
  declaration when its code names another declaration carrying the identical list and mentioning
  no bundling class — the corollary-with-a-binder-free-twin arrangement. A bare claim over a
  binder, delegating to nothing, still fails; four fixtures pin that.
- **One flag became two.** `ENFORCE_C34A=1` ships enforced; `ENFORCE_C34B=0` ships soft with its
  hit list printed. The two halves reached different readiness and a single flag would have forced
  either shipping the real assertion unenforced or turning the gate red on work this task was told
  not to open.
- **Consumption ≠ elimination.** `isTotal_of_isMax`'s "not a second *Saturation* elimination site"
  reads like an independence claim and is not one. Its sentence survives intact beside a marker
  listing all four, and the distinction is written into the normal form as the worked example.
- **Line numbers and counts were re-measured, never quoted.** `class IsRegular` had moved from
  `TaskFrame.lean:1044` to `:1170`; the occurrence count had moved from 225 to 259 before work
  began and to 261 by close.

## Plan Deviations

- **Phase 1** altered: a third anti-silence condition (zero bracketed binder sites) added beyond
  the two the plan named.
- **Phase 2** altered: the fourth normal form landed as a sibling top-level section rather than a
  fourth `###` subsection of `## 2. The three forms`. Those three are `## References` *citation*
  forms; filing a per-declaration docstring claim among them would tell a reader to write it in a
  References block. Sections 3-5 renumbered to 4-6; no anchor link into the document exists
  anywhere in the tree, so nothing broke.
- **Phase 3** altered: only the first of the two ad-hoc "**Axioms consumed…**" lines was
  normalized here; the second belongs to `constraint`, whose docstring Phase 4 rewrites in full.
- **Phase 4** altered: two `linter.style.longLine` warnings were introduced when substituted
  binder-free lemma names lengthened two call lines past 100 characters, and rewrapped within the
  phase — "no new warning" is the phase's stated bar.
- **Phase 5** altered: all six *Saturation* consumers turned out to consume *all four* fields, so
  each is marked with the full list rather than `Saturation` alone. Two docstrings needed
  correcting rather than merely marking (`extension`'s "*Saturation* is not threaded in directly"
  and `isRestriction_of_isRegular`'s "*Compositionality* drops out entirely" are claims about what
  the results *need*, not about what their terms reach).
- **Phase 6** closed as `[COMPLETED WITH EXCLUSIONS]` with a full `#### Reasoned Exclusions`
  table: the single-flag flip became a two-flag split, the C34b hit list did not go to zero
  (8 residual rows), and 7 marker lines were added beyond the pinned fix set because the gate
  itself named them.
- **Phase 7** altered: two files fall outside the plan's task-level file list —
  `FormalSystem/Semantics/Validity.lean` (one marker line, which Phase 6's own `Files to modify`
  covers under `FormalSystem/Semantics/**/*.lean`) and `README.md` (regenerated inventory block,
  a mechanical consequence of the line-count change).

## Verification

- Build: **Success** — full `lake build` (detached through `lake-build-guard.sh`, per the
  detach-and-guard mandate) exit 0, `Build completed successfully (2726 jobs)`, 0 `error:`,
  0 `warning:`, `.olean` newer than source for every touched module.
- Sorry count: **0** (`lean-sorry-census.sh` over the four resolved source roots).
- Vacuous count: **1** — `FormalSystem/Examples/TemporalStructures.lean:495`
  `int_domain_universal … := trivial`, identical at the task's base commit `e85341f8d`. Not
  introduced here; it is a genuine `Int` domain triviality in an examples file.
- Axiom count: **14**, unchanged from the base commit.
- `bash scripts/check-module-invariants.sh --no-build`: exit 0, ALL CHECKS PASSED, zero FAIL
  lines, with `PASS C34a` enforced.
- Other repository lints at close: `check-copyright-headers`, `check-evidence-probes`,
  `check-metalogic-cycles`, `readme-lint` and `.claude/scripts/check-task-references.sh` all
  green. `check-paper-definitions.sh` and `typst-sync-check.sh` exit 1 — both fail **identically
  at the task's base commit** (verified in a detached worktree at `e85341f8d`): the former on a
  `def:id` drift in the paper's LaTeX sources, the latter on `generated/status.typ` counts stale
  by 23 files and ~13,150 lines. Neither is touched by this task.
- Signature stability: all eight original declarations keep a byte-identical signature line,
  checked mechanically from the keyword line through `:=` against the base blobs.
- Files verified: Yes.

### Census, measured at close

| Figure | Value |
|--------|-------|
| Raw bracketed `IsRegular` occurrences | 261 across 47 files |
| Declarations carrying a bracketed bundling binder | 212 in 46 files |
| Declarations carrying a `Constraints consumed:` marker | 29 |
| …of those, omitting *Saturation* | 22 |
| …of those, binder-carrying and discharged by delegation | 18 |
| Binder-carrying declarations with no marker | 194 |
| Live `.lean` files walked / declaration spans | 630 / 11,988 |
| C34b residual (soft) | 8 |

The raw count and the declaration count differ because the grep also counts `variable`-block
binders and several binders on one declaration.

## Impacts

- `PartialHistory.constraint`'s bold "*Saturation* is **not** consumed" is now a machine-checked
  claim: it reads off `constraint_of_compositional_serial_limit`, which carries no binder at all.
  This matters beyond tidiness — `lem:step` is the sole *Saturation* elimination site and
  `lem:constraint` supplies its hypothesis, so a version quietly consuming *Saturation* would have
  made that appeal circular in substance while staying green.
- Eight new binder-free statements are available to downstream work that needs a result at a
  non-regular frame, at no call-site cost: every original signature is unchanged.
- C34's census is a standing, re-runnable record of the binder population, so the next audit
  starts from a measurement rather than from a figure in a document that has since drifted.
- `ENFORCE_C34A=1` means a new independence claim propped up by a bundling binder now turns the
  gate red at authoring time.

## Follow-ups

- **Clear the 8-row C34b residual, then flip `ENFORCE_C34B=1`.** Each row carries a binder, each
  would need a marker omitting a constraint that binder supplies, and none has a binder-free
  declaration to delegate to — so the honest remedy is a binder-free twin, not a marker line. The
  rows: `Rigidity.lean` `static_iff_uniformDwell`; `RigidityReal.lean` `levels_closed` and
  `constant_of_countable_range`; `TaskFrame.lean` `FrameOver.saturation`, `nullity`,
  `nullity_identity`, `FrameOver.reflection`, `TaskFrame.saturation`. Four of them
  (`levels_closed`, both `saturation` projections, `FrameOver.reflection`) would also be
  discharged by a second, projection-shaped C34a rule — the declaration names exactly the class
  fields its marker lists — if that turns out cheaper than eight restatements.
- `typst-sync-check.sh` Check 2 and `check-paper-definitions.sh` are red on the base commit and
  belong to separate work; this task did not touch them.

## References

- `specs/663_hypothesis_honesty_lint_isregular_overbinding/plans/01_hypothesis-honesty-lint-isregular.md`
- `specs/663_hypothesis_honesty_lint_isregular_overbinding/reports/01_hypothesis-honesty-lint-isregular.md`
- `docs/development/REFERENCE_NORMAL_FORM.md` — `## 3. The constraint-consumption line`
- `docs/development/MODULE_INVARIANTS.md` — the C34 row
- `scripts/check-module-invariants.sh` — the C34 block
