# Implementation Summary: Task #639

- **Task**: 639 - README accuracy and entry point fixes
- **Status**: [COMPLETED]
- **Started**: 2026-09-20T23:56:10Z
- **Completed**: 2026-09-21T01:50:00Z
- **Effort**: ~3 hours
- **Dependencies**: task 631 (README.md Logos/ProofChecker naming, latex/ retirement) — confirmed already landed
- **Artifacts**: plans/01_readme-accuracy-entry-points.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The repository stated two legitimate but unlabelled axiom-count conventions — 29 primitive
`inductive Axiom` constructors (23 Base / 2 Dense / 2 ZTime / 2 RTime) versus 45 total named
schemata (29 primitives + 16 `DerivedAxioms` theorems, partitioned 37/40/39/42 by minimum frame
class) — without ever saying which convention a given number used, alongside several stale
directory-nesting, entry-point-link, and citation defects in the root README and its nearest
siblings. All seven phases of the plan are complete: a canonical "Two axiom counts" derivation
was written once in `docs/reference/axiom-reference.md`, then every other file's counts, labels,
frame-class names, and navigational defects were swept into agreement with it.

## What Changed

- `docs/reference/axiom-reference.md` — added a `## Two axiom counts` subsection giving the
  canonical primitive-vs-total-names derivation and the 37/39/40/42/45 partition, with the three
  files that legitimately use the total-names convention named explicitly.
- `README.md` — mermaid graph nodes and the Axiom Systems table now lead with primitive-constructor
  counts (23/25/25/27), with the total-names figures (37/40/39/42, 45 in all) retained only as an
  explicitly labelled, linked footnote; the `Additional Axioms` column no longer lists derived
  mirrors (`prior_SZ`, `prior_S_gap`) as primitives; the Project Structure tree now correctly nests
  `MinusLanguage/`, `PlusLanguage/`, and the previously-missing `StarLanguage/` under `Syntax/`; a
  `MainResults.lean` entry-point link was added to the top matter; the in-text citation and BibTeX
  `year` field were aligned to "forthcoming"/`{2025}`.
- `FormalSystem/README.md` — replaced every stale `FrameClass.Discrete`/`FrameClass.Dedekind`
  reference with the live `ZTime`/`RTime` names; replaced nonexistent declaration citations
  (`completeness_discrete`, `completeness_dedekind`, `soundness_dedekind`) with the live names
  (`completeness_ztime`, `completeness_rtime`, `soundness_rtime`); filled the
  `<!-- TODO: add description -->` row for `MainResults.lean`; added a pointer to the canonical
  axiom-count derivation.
- `docs/reference/API_REFERENCE.md` — replaced the stale hand-copied `inductive Axiom : Formula →
  Prop` code block (wrong universe, six constructors that are now derived theorems, missing
  layers) with a pointer to the live source and the maintained per-layer table; corrected the
  count sentence and the Axiom Categories prose, folding the paper-key-dependent Temporal/
  Interaction rows into a pointer after discovering two further pre-existing errors there.
- `docs/user-guide/architecture.md` — corrected the Base axiom count and the ZTime/RTime
  "extends Base with..." bullets, which listed derived mirrors as primitives; disambiguated the
  "29 constructors, 4 layers" line (frame-class layers vs. axiom-category layers are different
  senses of "layer").
- `docs/project-info/implementation-status.md`, `docs/project-info/FEATURE_REGISTRY.md` —
  additional stale-count occurrences surfaced by the plan's own scope-confirmation grep, outside
  the two files it named; fixed to the primitive convention with a pointer to the canonical
  derivation.
- `FormalSystem/Examples/BimodalProofs.lean` — fixed two stale `../ProofChecker/Theorems/
  Perpetuity.lean` relative links (`ProofChecker` is a role name, not a directory) and one
  further broken link (`../docs/...` resolved to the nonexistent `FormalSystem/docs/...`).
- `FormalSystem/Examples/TemporalStructures.lean` — fixed two further `../ProofChecker/...`
  relative links found by the plan's re-grep instruction.
- `FormalSystem/Automation/BenchmarkAnchorsMain.lean` — retitled two "N constructors" phrasings
  that actually counted derived-mirror-inclusive totals to "N names"; fixed a stale
  `Dense/Discrete` mention; added a pointer to the canonical axiom-count derivation.
- `FormalSystem/Metalogic/Independence/RationalWitness.lean` — corrected "this covers the 37 Base
  axioms" to the primitive count and total-claim phrasing ("discharges all 23 Base constructors").
- `README.md`, `FormalSystem/Automation/README.md` — mechanically regenerated generated-inventory
  blocks (`--emit-inventory`) after the Lean docstring edits shifted line counts; pure count
  regeneration, no prose change.

## Decisions

- Primitive `Axiom` constructors are the headline convention everywhere; the 45-name/37-40-39-42
  total-names convention is retained only where explicitly labelled and linked to the canonical
  derivation (per plan Decision 1).
- `FormalSystem/README.md`'s `Discrete`/`Dedekind` naming was treated as in-scope alongside the
  count fix, since correcting numbers beside wrong class names would be a net loss of reader trust
  (plan Decision 2).
- `docs/reference/API_REFERENCE.md`'s inline axiom code block was replaced with a pointer rather
  than patched, to avoid re-creating the same drift risk (plan Decision 3).
- The BibTeX `year` field was set to `{2025}` to match the existing `brastmckie2025construction`
  key (plan Decision 4); a non-blocking `user_decision` on the alternative (rename the key to
  `brastmckie2026construction`) was already recorded at the planning stage and is not re-litigated
  here.
- Discovered during Phase 5 that `docs/reference/API_REFERENCE.md`'s original Temporal Axioms
  paper-key labels (`TA`, `TF`) were themselves stale/incorrect — `φ → GPφ` is actually `TC`
  (`connect_future`) per `axiom-reference.md`'s Paper Key Correspondence table, and `modal_future`
  is documented as the *sole* interaction axiom (no separate `TF`). Rather than hand-fix
  individual paper-key labels I was not confident in, that subsection was folded into a pointer to
  the authoritative table, avoiding re-introducing either error.

## Plan Deviations

- **Task 7.1** altered: the plan's acceptance-gate phase surfaced an unrelated-but-real `FAIL INV`
  (2 generated-inventory blocks gone stale from the Phase 6 `.lean` comment-line-count changes),
  which was repaired via `check-module-invariants.sh --emit-inventory` inside Phase 7 rather than
  as a separate phase, since it was a pure mechanical count regeneration with no prose change. See
  `progress/phase-7-progress.json`'s `deviations` array.

## Verification

- Build: N/A (acceptance gate is `--no-build`; no phase required elaboration)
- Tests: `bash scripts/check-module-invariants.sh --no-build` — `ALL CHECKS PASSED` (C14, C21, C22
  specifically confirmed); `bash scripts/readme-lint.sh` — `RESULT: PASS`
- Files verified: Yes — every edited file re-read and grep-verified against
  `Axiom.minFrameClass`/`typst-status-counts.sh`; every `.lean` diff hunk confirmed to lie
  strictly inside a comment region; every relative link in `README.md` and
  `FormalSystem/README.md` scripted-swept against the filesystem (zero broken)

### Direct Count Audit (Phase 7)

| File | Figures stated | Convention | Agrees with `Axiom.minFrameClass`? |
|---|---|---|---|
| `README.md` | 23/25/25/27 (primitives, table+graph); 29 (total primitives); 37/40/39/42/45 (labelled, linked) | (a) headline, (b) labelled | Yes |
| `FormalSystem/README.md` | 23/25/25/27 (primitives); 29 (total); 37/40/39/42/45 (linked) | (a) headline, (b) linked | Yes |
| `docs/reference/API_REFERENCE.md` | 23/+2/+2/+2 (primitives); 29; 45/37/40/39/42 (linked) | (a) headline, (b) linked | Yes |
| `docs/user-guide/architecture.md` | 23 (Base primitives); 29 (total); 4 frame-class layers | (a) headline | Yes |
| `FormalSystem/Automation/BenchmarkAnchorsMain.lean` | 29 primitives, 16 derived, 45 names; 37 (Base names) | (b), self-consistent per file's own stated convention | Yes |
| `FormalSystem/Metalogic/Independence/RationalWitness.lean` | 23 (Base primitives) | (a) | Yes |

Cross-checked against `bash scripts/typst-status-counts.sh`: `axiom_count: 29, base_count: 23,
dense_only_count: 2, ztime_only_count: 2, rtime_only_count: 2` — matches every primitive figure
above.

## Impacts

- An anonymous reader of the root README now sees one explained counting convention instead of
  three silently disagreeing numbers, a corrected directory tree, and a working entry point to
  `MainResults.lean`.
- The `docs/reference/axiom-reference.md#two-axiom-counts` section is now the single place the
  29-vs-45 arithmetic is derived; every other file links to it rather than restating it, closing
  the drift-recreation risk the plan's Risks table flagged for `API_REFERENCE.md`'s old inline
  code block.
- `check-module-invariants.sh`'s C14 stale-count regex remains blind to bare-number claims like
  "| **Base** | 37 |" that don't carry the literal words axiom/constructor/schema adjacent to a
  flagged digit — this task closed the specific defects it found by direct comparison, not by
  widening C14 (an explicit non-goal), so a future editor could still reintroduce an unlabelled
  count without tripping any automated gate.

## Follow-ups

- None required for acceptance. Optionally: widen C14's regex to catch bare table-cell counts
  (e.g. `| **Base** | 37 |`) in a future task — this plan's own Non-Goals explicitly deferred that
  widening.

## References

- `specs/639_readme_accuracy_and_entry_point_fixes/plans/01_readme-accuracy-entry-points.md`
- `specs/639_readme_accuracy_and_entry_point_fixes/reports/01_readme-accuracy-entry-points.md`
- `specs/639_readme_accuracy_and_entry_point_fixes/progress/phase-{1..7}-progress.json`
- `docs/reference/axiom-reference.md#two-axiom-counts`
