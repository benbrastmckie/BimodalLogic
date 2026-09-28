# Implementation Summary: Task #689

- **Task**: 689 - Reconcile records with landed code
- **Status**: [COMPLETED]
- **Started**: 2026-09-27T16:00:00Z
- **Completed**: 2026-09-27T17:30:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_reconcile-records-landed-code.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Four durable records that disagreed with the landed tree were brought into agreement with it. No
theorem statement, proof term, binder or definition changed anywhere: every edit lands in a Lean
module docstring, a markdown file, one other task's plan file, or a generated record. All six plan
phases are closed and every mechanical gate is green.

## What Changed

- `specs/678_canonical_wire_parser_round_trip/plans/01_canonical-wire-parser-round-trip.md` — three
  of the nine pinned Challenge signatures corrected to the forms actually proved
  (`unescape_escape` gains the consumed closing quote, `parseCJson_printCJson` and
  `parseCJson_fuel_sufficient` each gain `(hrest : NoDigitHead rest)` after `(hok : Canonical j)`),
  plus a new `### Amendment` subsection preserving each original verbatim beside its counterexample
  and landed module. The block still declares nine theorems and is not renumbered; no import
  changed (`NoDigitHead` reaches the block transitively through the existing
  `import BimodalTools.CanonicalWire.Cert`).
- `FormalSystem/MinusLanguage/Translation.lean` — the `## Main Results` bullet and the
  `### Injectivity` section comment now say *why* `tr` is injective (primitive-to-primitive,
  same-name) and that the reason does not transfer to an elimination, naming
  `FormalSystem/SourceLanguage/Sentence.lean`'s `tr_not_injective` as the worked case where the
  collisions hold by reflexivity after unfolding. Docstrings only.
- `FormalSystem/Semantics/FrameConstraintIndependence.lean` — the honest duplication *observation*
  became a stated `### The decision: the duplication is kept, deliberately`, recording both
  rejected consolidation directions. Docstring only.
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — a short reciprocal paragraph
  naming the other matrix, the aggregate theorem this module lacks, the discrete-time *Limit*
  refutation it lacks, the identical `voidRel`/`emptyRel` witness, and the no-merge decision. The
  module went 1,727 → 1,739 lines, well inside its `linter.style.longFile 1800` baseline; the
  baseline was not raised. `grep -c FrameConstraintIndependence` on it went 0 → 1.
- `docs/reference/transcription-audit-surface.md` — one amended sentence keeping the third record
  in agreement with both module headers.
- `scripts/module-invariants-allowlist.txt` — dropped the stale `:1453` line pin from one `#`
  comment rather than re-pinning it.
- `Tests/fixtures/README.md`, `Tests/README.md`, `docs/development/MODULE_ORGANIZATION.md` — the
  shared-fixture convention, including the rejected `.gitignore`-hole alternative, recorded where a
  plan author reads it. The `Tests/README.md` Structure table gained `fixtures/` and
  `BimodalToolsTest/` rows; §1's tree gained `Tests/fixtures/` and a root `data/` node.
- `scripts/lean-citation-manifest.json`, `FormalSystem/MinusLanguage/README.md`,
  `FormalSystem/Semantics/StateTopology/README.md`, `README.md` — regenerated, plus two
  `Last verified` bumps.

## Decisions

- **The two independence matrices are not consolidated.** Moving the four new rows into
  `ConstraintWitnesses.lean` is *blocked*: that module imports
  `FormalSystem.Semantics.StateTopology`, and the aggregator's prohibition on `Mathlib.Topology.*`
  is exactly why the aggregate theorem cannot live there. Moving the topology-free
  `voidFrame`/`bumpFrame` block the other way is *feasible but disproportionate* — eight
  `docs/theorem-index.md` rows (six `pinned:C14`), a `state-topology-appendix-support.md` citation
  and four allowlist entries would migrate, and the older module's matrix-completeness claim would
  become false. The decision and both rejected directions are now stated in both module headers.
- The amendment subsection states in its own text that it exists *because* the recorded statements
  were false, that the originals are preserved above it, and that it took the reviewed follow-up
  route — so it cannot be read as licence to edit recorded statements to match implementations.
- The `:1453` line pin was dropped rather than re-pinned, consistent with the repository's
  anti-line-number convention and with the defect class this task exists to close.

## Plan Deviations

- **Phase 2 (altered)**: `FormalSystem/SourceLanguage/Sentence.lean` and `BimodalTools/README.md`
  were verified as already correct and left unmodified as planned, but the verification is recorded
  here and on the plan checklist rather than in the phase commit body — `git-commit-scoped.sh`
  generates a fixed body and accepts no free-form body text.
- **Phase 3 (altered)**: the plan described `voidRel` and `emptyRel` as "the same relation at
  different duration types". They are at the *same* type — both are literally
  `Bool → ℤ → Bool → Prop` defined as `fun _ _ _ => False` — so the landed text says
  character-identical instead. The plan's phrasing was itself an instance of the defect class this
  task repairs.
- **Phase 3 (added)**: the first draft of the decision paragraph produced one 101-character line and
  a `linter.style.longLine` warning. It was rewrapped and the scoped build re-run clean; no plan
  step anticipated this.
- **Phase 4 (altered)**: the `*Last verified:*` bump in `Tests/fixtures/README.md` was a no-op — the
  line already read `2026-09-27`, the implementation date.

## Verification

- Build: **Success** — `Build completed successfully (2741 jobs)`, guard exit 0, zero `error:` and zero `warning:` lines over the captured output, and the `.olean` of all three touched modules newer than its source (full `lake build`, detached via `Bash(run_in_background: true)` through
  `lake-build-guard.sh build --timeout 1800`)
- Sorry count: 0
- Vacuous count: 0 in this change set. The mandated repo-wide grep returns one hit,
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal ... := trivial`, which
  is pre-existing (last touched by an unrelated earlier commit), untouched here, and not a
  placeholder — `intTimeHistory.domain t` unfolds to `True` because the integer time history is
  total, so `trivial` is the correct proof rather than a stand-in.
- Axiom count: unchanged (no `axiom` declaration added or removed)
- Tests: covered by the full build (`BimodalTest`, `BimodalToolsTest`)
- Files verified: Yes
- `bash scripts/check-module-invariants.sh`: `ALL CHECKS PASSED`, zero FAIL rows — including `PASS INV` and `PASS C35`
- `python3 scripts/export-lean-citations.py --check`: clean (53 seeded names resolved)
- `bash scripts/check-module-invariants.sh --emit-inventory --check`: `PASS INV`
- `bash scripts/readme-lint.sh`: `RESULT: PASS`
- Zero task-number occurrences across all eleven touched non-`specs/` deliverables
- Every `.lean` hunk lies inside a `/-!` comment region; no declaration, binder or proof term
  changed
- Scope hypotheses confirmed: exactly three of nine pinned statements corrected (the other six
  match the tree, `parseDigits_printDigits` modulo the pre-authorised coercion spelling); exactly
  four files in Phase 3; exactly three files in Phase 4 (`ls -d Tests/*/` is exhaustive at three);
  exactly three inventory blocks and one manifest entry in Phase 5.

## Impacts

- A reader arriving at either independence module now learns that there are two, why the
  duplication is deliberate, and what each uniquely contributes — so neither reads as an unreviewed
  duplicate.
- The next task consulting `FormalSystem/MinusLanguage/Translation.lean` as an injectivity
  precedent will find the property attributed to the translation's shape, not to being a
  translation module, and so should not request a false `tr_injective` for an elimination a third
  time.
- A future plan author choosing where a cross-repository data file goes will find the convention in
  all three places they consult, with the rejected `.gitignore`-hole alternative recorded.
- The canonical wire codec's pinned block is now a contract a reader can check against the tree.

## Follow-ups

- None. Each record was reconciled in place; no deferred work remains.

## References

- `specs/689_reconcile_records_with_landed_code/plans/01_reconcile-records-landed-code.md`
- `specs/689_reconcile_records_with_landed_code/reports/01_reconcile-records-landed-code.md`
- `specs/678_canonical_wire_parser_round_trip/summaries/01_canonical-wire-parser-round-trip-summary.md`
- `docs/reference/transcription-audit-surface.md`
