# Implementation Summary: Task #928

- **Task**: 928 - Muller to Rabin determinization cost assessment
- **Status**: [COMPLETED]
- **Started**: 2026-11-13T22:43:00Z
- **Completed**: 2026-11-13T22:52:00Z
- **Effort**: ~0.5 hours (plan budgeted 2)
- **Dependencies**: None
- **Artifacts**: plans/01_muller-torabin-cost-assessment.md, reports/01_muller-torabin-cost-assessment.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This is an assessment task whose deliverable is a report, and the report was already written
before this dispatch. What this dispatch did was **evidence-tier repair and closure**: both
places where a load-bearing claim rested on something weaker than a first-hand read were
retired against primary sources, the report was audited against the dispatch's four deliverables
and six guardrails, and the guardrails were re-checked mechanically rather than asserted. No
`.lean` file was written or edited in either tree, no `require` was added, and no proof of
`Muller.toRabin_exists` was attempted.

Both evidence repairs succeeded in full — neither fell back to its plan contingency — and both
turned up a correction, which is the point of doing them rather than asserting them.

## What Changed

- `specs/928_.../reports/01_muller-torabin-cost-assessment.md` — Finding 1.4 regrounded on
  first-hand Reynolds 2001 citations (sub-claim table, three claims individually cited by chunk
  file and line); Findings 1.2 and 1.3 given a page-image fidelity table and a corrected
  tree-specificity claim; a previously omitted construction step recorded; the rigour gap
  strengthened; Recommendation 8 widened from one unproved obligation to two; two Risks rows
  rewritten to their new evidence tiers.
- `specs/928_.../plans/01_muller-torabin-cost-assessment.md` — phase markers and checklists.
- `specs/928_.../summaries/01_...-summary.md` — this file (new).

No `.lean` file, no `lakefile.toml`, no `lake-manifest.json`, and no file outside
`specs/928_muller_torabin_determinization_cost_assessment/` was created or modified.

## The Four Findings, in Brief

1. **Construction of record: the appearance-record (LAR) route** — Thomas 1997 §6.1 Theorem 6.5
   with Remark 6.6 — not Safra's and not Piterman's. The ground is that the lemma's input
   `a : Muller State Symbol` is *already deterministic*, so there is no nondeterminism for a
   determinization construction to remove. The archived "Safra/Piterman in corpus" attribution is
   a misattribution as to this lemma, accurate only about the composite NBA→DRA step.
2. **~1,000 lines (800–1,200), one new file in the fork, 4–7 phases**, anchored on measured
   in-tree comparables (`DA/Concat.lean`, 762 lines) rather than on the landed same-state-space
   conversions, which would understate the job roughly fivefold.
3. **Siting: the fork, and no `require` is entailed.** The minimal statement closure is 956
   measured lines of third-party code, and this repository's `lake-manifest.json` holds no
   `cslib` entry. Proving the lemma in the fork commits this repository to nothing; the `require`
   question becomes live only if this repository's Lean code comes to consume it.
4. **(O1) and (O3) are separable.** (O3) originates at `IsRegular` itself, not at
   `toRabin_exists`, so proving the latter in existential form leaves (O3) exactly where it
   stands — and (O1) alone unblocks the `Prop`-valued completeness line.

## Outcome of the Two Evidence Repairs

**Phase 1 — Reynolds 2001 K4B grounding (was `CARRIED-UNVERIFIED`).** All three carried
sub-claims confirmed first-hand and now cited by chunk file and line:

| Sub-claim | Verdict |
|---|---|
| `bl : T → (C × {1,…,K})*` | CONFIRMED (shape); the sequence operator's glyph is scan-garbled, its reading pinned by §11's prose gloss |
| `K` = number of accepting pairs | CONFIRMED verbatim (§12) |
| K4B orders by recency of last appearance | CONFIRMED verbatim (§12) |

One **carried wording error corrected**: the phrase "the order of `V_p`s ceasing to appear" is
§11's *motivating* remark, not K4B's own text. K4B states the same order from the other
direction, by most recent appearance, so the finding's substance is unaffected. The
`CARRIED-UNVERIFIED` marker was retired, leaving a narrower, honestly-stated OCR-glyph residual.

**Phase 2 — Thomas 1997 Theorem 6.5 / Remark 6.6 fidelity (page images).** Pagination resolved
(printed page = PDF page − 3); Theorem 6.5 on PDF page 49, Remark 6.6 on PDF page 50; both read
as images. All seven quoted passages confirmed verbatim — the markdown transcription's only
defects are dropped `fi`/`ffi` ligatures, i.e. text-layer extraction loss, not OCR error. Three
substantive results beyond confirmation:

- **One overstatement corrected.** Finding 1.3's "nothing in either is tree-specific" was wrong
  about the transition rule, which is written with two successor components, one per tree
  direction. Remark 6.6 and the `Eᵢ`/`Fᵢ` chain *are* fully tree-agnostic. The conclusion
  (transposition is a restriction, not a generalization) survives, and the corrected reading
  makes it slightly cheaper, not dearer: one `δ` application instead of two, same operation.
- **One omitted construction step surfaced**: the proper-chain pruning that drops degenerate
  `Eᵢ`/`Fᵢ` pairs. It is dischargeable by *not performing it* — CSLib's `DA.Rabin` takes an
  unconstrained pair set and imposes no chain or properness condition, so the step is an artifact
  of Thomas targeting a Rabin *chain* automaton rather than a Rabin automaton.
- **The rigour gap strengthened, not narrowed.** Thomas closes the proof with "It is now easy to
  check (using the Remark above) that `A'` accepts the same trees as `A`" and stops. So *two*
  steps are asserted rather than proved — Remark 6.6 itself and the equivalence given it.
  Recommendation 8 was widened accordingly.

## Deliverable and Guardrail Audit

| Dispatch item | Discharged by | Evidence |
|---|---|---|
| **(1)** construction of record, and why it matters for the pair-indexed consumer | Finding 1 (1.1–1.4) | LAR route fixed; consumer half now first-hand-cited to Reynolds §11/§12 |
| **(2)** size and shape estimate on this toolchain, with a basis | Finding 2 | ~1,000 lines (800–1,200), basis = measured `wc -l` on in-tree comparables, not a bare number |
| **(3)** siting, and whether a `require` is entailed | Finding 3 | fork; 956-line measured closure; no `cslib` in `lake-manifest.json`; no `require` entailed |
| **(4)** whether (O1) alone unblocks, or (O1)+(O3) together | Finding 4 | separable; (O3) originates at `IsRegular`; (O1) alone unblocks the `Prop`-valued line |
| **(a)** assessment only; no proof, no `.lean` written in either tree | — | **MECHANICALLY VERIFIED**: `git -C ~/Projects/cslib status --porcelain -- '*.lean'` empty; this tree's only untracked `.lean` files are under `specs/evidence/history-morphism-saturation-audit/`, mtime 1794272477, ~4 days before this dispatch's start (1794638373) — not attributable to this task |
| **(b)** no `lakefile.toml`/`lake-manifest.json` edit, no `require` in any form | — | **MECHANICALLY VERIFIED**: `git diff --stat` and `git diff --cached --stat` on both files are empty |
| **(c)** no formalization of Reynolds §§7–15 | — | Reynolds §§11–14 were *read* to verify quotations; nothing was formalized |
| **(d)** no completeness claim | Finding 4 | states what (O1) unblocks, claims no completeness result |
| **(e)** cite the fork's `proof_wanted` sites with file and line | Finding 1.1, Finding 3 | **RE-CONFIRMED against the live fork**: HEAD still `3bdf16d9f`; `Rabin.toParity_exists` at `DA/Conversions.lean:89`, `Muller.toRabin_exists` at `:112` — both exact, no citation drift |
| **(f)** say so if the corpus lacks the rigour to cost it | Finding 1.2 | **partial fire, now better evidenced**: construction held at full rigour (page images); *two* correctness obligations held only as statements |

## Disposition of the Report's Eight Recommendations

| # | Disposition |
|---|---|
| 1 | Stands. The correction to the "Safra/Piterman" attribution lives in this report (Finding 1.1 and Decisions), which is the durable carrier — see Deferred Items. |
| 2 | Stands, unchanged. Compiled-probe evidence unaffected by this dispatch. |
| 3 | Stands, unchanged. |
| 4 | Stands, unchanged. The ~1,000-line estimate is not revised: Phase 2's two findings roughly offset (the pruning step is *removed* from the budget; the second unproved obligation was already budgeted as a separate line item). |
| 5 | Stands, unchanged. |
| 6 | Stands, unchanged. Not acted on, per guardrail (b). |
| 7 | Stands, unchanged. |
| 8 | **Widened** by Phase 2: two obligations are original work, not one. |

## Decisions

- **Both evidence repairs were run to completion rather than taking their plan contingencies.**
  Each plan phase authorized "record the attempt and leave the risk standing" as a valid outcome;
  neither was needed.
- **Corrections were made in place and disclosed, not silently absorbed.** Three claims in the
  report were weakened or corrected by first-hand reading (the K4B quotation's attribution,
  Finding 1.3's tree-specificity, Recommendation 8's scope). Each is stated as a correction in
  the report rather than quietly rewritten.
- **The cost estimate was not revised.** Phase 2's two findings pull in opposite directions and
  roughly cancel; revising a deliberately order-of-magnitude figure on that basis would imply a
  precision the estimate does not have.

## Plan Deviations

- None (implementation followed plan). Phases 1 and 2 both completed on their primary paths
  rather than their documented contingency paths; Phase 3's conditional "update the report's
  cited lines if the fork has moved" did not fire, because the fork had not moved.

## Verification

- Build: N/A — no `.lean` file was written or edited in either tree (guardrail (a)); this task
  has no Lean build surface. `lean_intent: false` in the plan metadata.
- Sorry count: N/A (no Lean source touched)
- Vacuous count: N/A (no Lean source touched)
- Axiom count: N/A (no Lean source touched)
- Tests: `validate-artifact.sh` exits 0 on the report, the plan, and this summary
- Gate set: scoped discharge per this dispatch's Batch Gate Deferral directive — see below
- Files verified: Yes

### Gate discharge (scoped, per the dispatch's Batch Gate Deferral directive)

Phase 3 declares `**Verification Tier**: full`. This dispatch is one `implement` dispatch inside
a multi-task `/orchestrate` batch, so per the directive the full gate set is **deferred to the
batch stage** and discharged here against the narrowing invocation that actually covers this
phase's touched files. `suite_selection_select` returned `__FULL_SWEEP__` for this task's pure
`specs/**` prose paths at plan time, and sub-case (a) names the covering check as
`validate-artifact.sh` per artifact — an **unmappable criterion** in the directive's sense (no
matching `--only` suite basename and no matching `--only-gate` number expresses "validate these
three `specs/**` artifacts"), so that named check was run directly, scoped to this phase's own
touched files, and recorded as the scoped discharge. The complete gate set runs once for the
whole batch at the end of the invocation and is attributed back by `modified_files`. The full
gate is deferred, not forgiven.

## Impacts

- The single highest-value `proof_wanted` on the Lean completeness line now has a costed,
  sourced, first-hand-grounded assessment: a named construction, an order-of-magnitude budget
  with a measured basis, a siting decision that commits this repository to nothing, and an
  explicit statement that (O1) alone unblocks the `Prop`-valued line.
- A future implementer inherits two concrete savings from this dispatch's evidence work: skip
  Thomas's proper-chain pruning step (CSLib's `DA.Rabin` does not need it), and budget *two*
  original correctness proofs rather than one.
- The standing `require` ruling is untouched and remains in force.

## Follow-ups

Two items were deliberately deferred rather than done, each for a stated reason:

- **The 879 row-16 "Safra/Piterman" correction is not applied in place.** The archived report
  lives under `specs/archive/`, which `.gitignore:94` ignores (checked at plan time), so an edit
  there leaves no record a future reader can verify. This report carries the correction instead,
  in Finding 1.1 and in Decisions.
- **`context/project/lean4/domain/omega-automata-conversions.md` was not created.** It is outside
  this dispatch's declared file scope ("FILE SCOPE: none. Report only"), and its real home is the
  extension source store resolved through `.claude-extensions.json`, not this repository's
  disposable `.claude/` tree — so it belongs to a task sited in the repository holding that
  source store. Recorded here for the user to act on.

One residual, honestly stated: the `bl` signature's finite-sequence operator is scan-garbled in
every occurrence in the held Reynolds chunks. Its *reading* is fixed by §11's prose gloss, so the
claim stands; a page-image check of §12's definition would retire even the glyph-level doubt and
was not performed.

## References

- `specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md`
- `specs/928_muller_torabin_determinization_cost_assessment/plans/01_muller-torabin-cost-assessment.md`
- `/home/benjamin/Projects/Literature/sources/reynolds_2001/` — §§11–14 chunks (K4B grounding)
- `/home/benjamin/Projects/Literature/sources/thomas_1997_languages/Thomas_1997_Languages_Automata_Logic.pdf` — PDF pages 49–50
- `~/Projects/cslib/Cslib/Computability/Automata/DA/Conversions.lean:89,112` (fork HEAD `3bdf16d9f`)
