# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem
- **Status**: [COMPLETED]
- **Started**: 2026-11-17T00:51:00Z
- **Completed**: 2026-11-17T01:40:00Z
- **Effort**: ~50 minutes
- **Dependencies**: Phase 19 (CLOSED)
- **Artifacts**: plans/34_readoff-construction-pair-restatement.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 22 only. The object-dependent gap clip `B(Q, φ)` — the one route in this chain that is not
refuted — is now recorded as a NAMED OPEN QUESTION on three surfaces, with its compiled boundary
reproduced as a table whose every row carries COMPILED, INFERRED or OPEN. The phase lands no Lean
declaration, adopts no clip, attempts no agreement, and edits no `ParamsOk`-side object. Every
figure reproduced was re-measured against the live tree rather than carried from the plan.

## What Changed

- `specs/761_ladder_realization_theorem/records/round-34-readoff-construction-pair.md` — six new
  sections (§7–§12): the boundary table, the missing piece (i)–(iii) named as "Phase 11.7 at a
  larger clip", the signature cost, the attack-first sketch, the scope-sentence sweep with the
  plan defect it exposed, and the explicit list of what the section does not do.
- `docs/theorem-index.md` — the gap section's lead rewritten from one genuine gap to two, and a
  new bullet recording the open question with its compiled boundary, its INFERRED row marked as
  such, and its signature cost.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — two closing paragraphs recording
  the same question, the same compiled/inferred line, the absent closure theorem (i)–(iii), and
  why the order of `K` is not the obstacle.
- `specs/761_ladder_realization_theorem/plans/34_readoff-construction-pair-restatement.md` —
  Phase 22's six task items checked with their landing sites, and its scope-sentence verification
  criterion repaired (see Decisions).

No `.lean` file was modified by this phase.

## Decisions

- **Publication-facing citations name declarations, not `file:line`.** The first draft of the two
  documentation surfaces cited every probe by `path.lean:NNN`. `scripts/check-module-invariants.sh`
  C20 tier 2 rejected that with 9 findings across the two files (the gate was green before this
  phase, so the regression was this phase's). Both surfaces were rewritten to cite the probe path
  without a line number plus the declaration name, which is the convention the gate's own
  documentation states for files outside the live Lake tree. The record under `specs/` keeps its
  line numbers, which are outside tier 2's scope and are the re-measurement evidence.
- **The scope-sentence criterion was repaired by regex, not by an exclusion list.** Its filed form
  spelled the forbidden sentence out as two literal alternatives and greps a directory containing
  itself, so it was unsatisfiable by construction — writing the criterion down falsifies it, and
  so does recording that it was run. It now uses `leaves? the exponential clip open`, which
  matches both inflections while being a literal occurrence of neither, so the criterion, the
  record and the task bullet are all exempt by shape rather than by a `grep -v` that could also
  hide a genuine hit. One path is carved out: `issues.jsonl`, a machine capture log whose entry on
  this very defect quotes the sentence as its content.
- **The `card Q − 2` ceiling was derived, not carried.** The plan asserts it; this phase proved it
  from the probe source — `Qm m := Fin (m + 3)` against `chainC_cell_ne`'s hypothesis
  `c + m + 2 ≤ n'`, with a `kappa`-collision requiring both gaps saturated at the clip, so the
  family speaks for `B ≤ m + 1` and is silent at `B ≥ m + 2`.

## Plan Deviations

- **Phase 22, task 6 (the scope-sentence correction sweep)** altered: the sweep found ZERO
  assertions of the stale sentence anywhere in the tree. Its only occurrences were inside Phase
  22's own text — the bullet quoting it and the verification criterion containing the grep
  pattern. The bullet now describes the sentence instead of quoting it, and the criterion was
  repaired as above. Annotated inline on the plan's checklist item and recorded in record §11.
- No other deviation. The other five tasks landed as written.

## Verification

- Build: Success — `lake-build-guard.sh build --timeout 1800 -- build`, `exit_status=0`,
  `Build completed successfully (2976 jobs)`, zero `error:` over the captured streams. The phase
  touched no Lean source, so no module's `.olean` was invalidated.
- Sorry count: 0 (`lean-sorry-census.sh FormalSystem Tests`)
- Vacuous count: 0 (no `.lean` file modified)
- Axiom count: 12 under `FormalSystem`, 2 under `Tests` — both unchanged from baseline
- `scripts/check-module-invariants.sh`: exit 0, with `PASS C20 tier 2: zero file.lean:NNN
  citations in publication-facing scope` (it failed before the citation rewrite and passes after)
- `scripts/readme-lint.sh`: exit 0, `RESULT: PASS`
- `.claude/scripts/check-task-references.sh --quiet`: exit 0, `0 unexempted task-reference
  occurrences`
- `scripts/check-evidence-probes.sh`: exit 0, `PASS  all 67 wired probe(s) compile`
- Scope-sentence sweep: `grep -rnE 'leaves? the exponential clip open' specs/761_ladder_realization_theorem/ docs/ FormalSystem/ --exclude=issues.jsonl` returns nothing
- `grep -rnE '(theorem|lemma|def|abbrev) +(cellAt_const_of_kappa_eq|ladderRealized)\b' FormalSystem/ Tests/` returns nothing
- Every COMPILED row's declaration resolves under `specs/evidence/` at the cited line, re-measured
  in this dispatch: `no_formula_only_clip:521`, `exponential_clip_refuted:555`,
  `gap_clip_below_exponential_refuted:3295`, `no_keyed_cell_map_below_exponential:3482`,
  `chainC_cell_ne:433`, `stepFrag_gap_depth_exact:1160`, `nxt_le_double:3018`; and on the
  `ParamsOk` side `paramsOkK4:920`, `Bof:854`, `paramsOk_params:938`, `Tcof:820`. **No drift.**
- Evidence-gate probe total re-measured rather than quoted: 66 `WIRED` + 1 `WIRED_REPO` = **67**
- Files verified: Yes

## Impacts

- The one unrefuted route in this chain is now recorded as open on a publication-facing surface
  rather than living only in a plan phase body, so a reader of `docs/theorem-index.md` or the
  `RaySummary` README cannot mistake the sub-exponential refutations for a closed question.
- The compiled/inferred line is preserved on all three surfaces: the `card Q · 2 ^ (dBack φ)`
  figure is marked INFERRED everywhere it appears and is stated as compiled nowhere.
- Phases 20 (READ-OFF) and 21 (CONSTRUCTION) are untouched and remain the live work.

## Follow-ups

- Phase 21 (the CONSTRUCTION half) is the sanctioned next step under decision 27's option (C):
  `certAdmK` as an explicit hypothesis on an arbitrary `R`, untouched by the Phase 12.2
  refutation. Phase 20's READ-OFF right-hand side is chosen only once the construction exists.
- Two untracked paths observed in the working tree at dispatch start and still present, neither
  this phase's: `.pid` and `specs/evidence/history-morphism-saturation-audit/`. Not staged, not
  modified; reported rather than dismissed.

## References

- `specs/761_ladder_realization_theorem/plans/34_readoff-construction-pair-restatement.md` — Phase 22
- `specs/761_ladder_realization_theorem/records/round-34-readoff-construction-pair.md` — §7–§12
- `specs/evidence/seam-gluing-ray-product/ladder-chain-object-clip-refutation.lean`
- `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`
- `specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean`
