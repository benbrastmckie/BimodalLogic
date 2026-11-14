# Implementation Plan: Task #928

- **Task**: 928 - Muller to Rabin determinization cost assessment
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md
- **Artifacts**: plans/01_muller-torabin-cost-assessment.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is an assessment task whose deliverable is a report, and the report is already written and
already discharges all four dispatch deliverables. What remains is not construction but
**evidence-tier repair and closure**: the report's own Risks section names two places where a
load-bearing claim rests on something weaker than a first-hand read, and both can be retired
cheaply from material the corpus actually holds. This plan does exactly that, then audits the
report against the dispatch's four deliverables and six guardrails and writes the completion
summary. No `.lean` file is written or edited in either tree, no `require` is added, and no
proof of `Muller.toRabin_exists` is attempted — the dispatch guardrails are carried into this
plan unchanged and are re-checked mechanically in the final phase.

### Research Integration

The research round settled every substantive question the dispatch asked, and this plan does not
re-open any of them:

- **Finding 1** fixes the construction of record as the appearance-record (LAR) route — Thomas
  1997 §6.1 Theorem 6.5 with Remark 6.6 — and records 879 row 16's "Safra/Piterman" as a
  misattribution as to this lemma, on the ground (read) that the lemma's input `a : Muller State
  Symbol` is already deterministic.
- **Finding 2** costs the proof at ~1,000 lines (800–1,200), one new file, 4–7 implementation
  phases, anchored on measured in-tree comparables (`DA/Concat.lean` 762 lines) rather than on
  the landed same-state-space conversions, which would understate it ~5x.
- **Finding 3** sites it in the fork and establishes that no `require` is entailed: the minimal
  statement closure is 956 measured lines of third-party code, and this repository's
  `lake-manifest.json` contains no `cslib` entry.
- **Finding 4** separates (O1) from (O3): (O3) originates at `IsRegular` itself, so proving
  `toRabin_exists` in existential form leaves it exactly where it stands, and (O1) alone
  unblocks the `Prop`-valued completeness line.

Two residual evidence gaps are what this plan acts on, both named by the report itself:

1. **Finding 1.4's consumer-side grounding is CARRIED-UNVERIFIED** — the Reynolds §11/§12
   quotations about the banned list `bl : T -> (C x {1,...,K})*` and clause K4B's ordering were
   carried from the archived Muller-sufficiency report, not re-read. That claim is what makes
   deliverable (1)'s second half ("the reason the choice matters for the pair-indexed consumer")
   stand up, so it is the weakest link in the most load-bearing finding.
2. **Finding 1.2/1.3 rests on the markdown transcription** of Thomas 1997, and the report's own
   mitigation records that the PDF is held for a page-image check "before any attempt".

### Premise Re-Validation (Carried-Figure Discipline)

Every figure this plan depends on was re-checked against live state at plan time, not inherited:

| Carried claim | Live check at plan time | Result |
|---|---|---|
| Fork HEAD is `3bdf16d9f` | `git -C ~/Projects/cslib log -1 --format=%h` | CONFIRMED, unchanged |
| `Muller.toRabin_exists` at `DA/Conversions.lean:112` | `grep -n proof_wanted` on the live file | CONFIRMED, line 112 exact |
| `Rabin.toParity_exists` at `DA/Conversions.lean:89` | same grep | CONFIRMED, line 89 exact |
| Reynolds 2001 is held and covers K4B | `grep -rn "K4B"` over the corpus directory | CONFIRMED: `sec10_…md:78` (the clause), `:346` (purpose of the ordering), `sec09_…md:228` (pair-listing order), `sec11_…md:264` (most-recent-appearance formulation); `sec09_…md:230` carries "order of Vps ceasing to appear" verbatim |
| Thomas 1997 PDF is held for a page-image check | `ls` on the source directory | CONFIRMED: `Thomas_1997_Languages_Automata_Logic.pdf` present |
| The report carries exactly 2 `CARRIED-UNVERIFIED` markers | `grep -c` on the report | CONFIRMED: 2, at lines 89 and 245 |
| 879's report is a durable correction target | `git check-ignore -v` on the archive path | **REFUTED**: `.gitignore:94` ignores `specs/archive/`, so an edit there is not a durable record — see Non-Goals |

Two conditions from `context/project/lean4/patterns/plan-authoring-gate-collisions.md` were
resolved mechanically at plan time rather than left for the implementer:

- **Condition 1 (coupled generated surfaces)** does NOT fire. No `.lean` path is touched, so the
  `.githooks/pre-commit` line-count trigger is a no-op, and `grep -n specs scripts/typst-sync-check.sh`
  returns nothing — no generated surface derives any quantity from `specs/**`. Neither
  `typst/generated/status.typ` nor the module-inventory blocks appear in any phase's file scope,
  deliberately.
- **Condition 4 (baseline-delta lint criteria)** is honored in Phase 3: the full gate set runs
  against the whole deploy tree, so its criterion is phrased to separate findings naming this
  task's own files from the tree's standing baseline, never as a bare "the gate passes".

`suite_selection_select` was run at plan time over this task's artifact paths and returns
`__FULL_SWEEP__` — the expected result for a pure-prose `specs/**` edit. Sub-case (a) of the
`__FULL_SWEEP__` rule therefore applies throughout: the covering check is
`bash .claude/scripts/validate-artifact.sh <path> <type>`, not a gate subset.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context and `roadmap_flag` is not
set; `specs/ROADMAP.md` was not consulted as a plan input and is not modified by this plan. The
report's Finding 3 observes the standing `require` ruling without acting on it.

## Goals & Non-Goals

**Goals**:
- Replace Finding 1.4's CARRIED-UNVERIFIED grounding with a first-hand read of Reynolds 2001, or
  correct the finding if the primary source does not support what was carried.
- Settle the Thomas 1997 transcription-fidelity and tree-to-word transposition risk against the
  held PDF's page images, and record the outcome either way.
- Audit the report against the dispatch's four deliverables and six guardrails, and record that
  audit in a completion summary.
- Leave every dispatch guardrail mechanically re-checked rather than merely asserted.

**Non-Goals**:
- **No proof of `Muller.toRabin_exists`, and no `.lean` file written or edited in either tree**
  (guardrail (a)). The report's Finding 2 recommendations are a budget for a future task, not a
  licence to start one here.
- **No edit to `lakefile.toml` or `lake-manifest.json`, and no `require` in any form**
  (guardrail (b)). Finding 3 assesses siting; this plan does not act on it.
- **No formalization of any part of the Reynolds engine's sections 7–15** (guardrail (c)).
  Reading §10–§13 to verify a quotation is a read, not a formalization.
- **No completeness claim** (guardrail (d)).
- **Not correcting 879 row 16 in place.** Recommendation 1 asks that the "Safra/Piterman"
  attribution be corrected; the archived report is under `specs/archive/`, which `.gitignore:94`
  ignores (checked), so an edit there leaves no record a future reader can verify. This report is
  the durable carrier for that correction, and it already carries it in Finding 1.1 and in the
  Decisions section. No archived file is edited.
- **Not creating `context/project/lean4/domain/omega-automata-conversions.md`.** The report's
  Context Extension Recommendation stands as a recommendation. Acting on it is out of this
  dispatch's declared file scope ("FILE SCOPE: none. Report only"), and the file's real home is
  the extension source store resolved through `.claude-extensions.json`, not this repository's
  disposable `.claude/` tree — a task sited in the repository that holds that source store, not
  work for this one.
- **No new task is created.** Deferred items are recorded in the summary for the user to act on.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The Reynolds chunks' OCR is scan-derived and may garble K4B's exact wording | M | M | Quote conservatively, mark any OCR-doubtful glyph in place, and fall back to the PDF (`Reynolds_2001_Axiomatization_Full_CTL_star.pdf`, held) for any passage whose reading is load-bearing; if a passage stays unreadable, leave the `CARRIED-UNVERIFIED` marker rather than upgrading the claim |
| The primary source refutes part of what was carried about K4B | H | L | Finding 1.4's route ranking rests on three independent grounds (consumer fit, landed work preserved, proof difficulty) and the report already records that the latter two stand unchanged; a refutation narrows the finding rather than voiding it, and Phase 1 mandates re-stating it on the surviving grounds rather than deleting it |
| Theorem 6.5's page images contradict the markdown transcription | M | L | Phase 2 corrects the quoted text in place and records the correction; the construction's identity (appearance record, not Safra) rests on the data-structure attribution passage, which is corroborated independently by Zielonka and Piterman |
| Phase 2's PDF page mapping cannot be resolved from markdown line numbers | L | M | The check is bounded: if the two statements cannot be located within a few page reads, Phase 2 records the attempt and leaves the risk standing rather than burning budget — an honest standing risk is a valid outcome of this phase |
| A concurrent sibling (task 927, plan phase, no declared file scope) touches the same tree | M | M | This task's entire file scope is its own `specs/928_…/` directory; per the territory contract, re-read before editing, stage only this task's own files, and never a directory or glob add. A foreign commit or foreign modification is reported, not worked around |
| The final gate set is red for pre-existing, out-of-scope reasons | M | M | Condition 4's implementer-side corollary applies: a gate whose only failures are pre-existing and outside this task's file scope is a recorded PASS with the findings enumerated, never grounds to edit an out-of-scope file |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. Phases 1 and 2 are serialized despite being
topically independent because both edit the same file (the report) and a concurrent sibling is
live on this working tree.

### Phase 1: De-carry Finding 1.4's K4B grounding [COMPLETED]

**Goal**: Replace the CARRIED-UNVERIFIED grounding of Finding 1.4's consumer-side claim with a
first-hand read of Reynolds 2001, or correct the claim where the primary source does not support
what was carried.

**Tasks**:
- [x] Re-run `grep -c "CARRIED-UNVERIFIED"` on the report and `grep -rn "K4B\|ceasing to appear" /home/benjamin/Projects/Literature/sources/reynolds_2001/` before editing; if either differs from the plan-time figures (2 markers; hits in `sec09`, `sec10`, `sec11`), widen this task list accordingly
- [x] Read `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec09_sec-10-the-standard-basis-of-the-constru.md` around lines 225-235 — the pair-listing order and the "order of Vps ceasing to appear" passage
- [x] Read `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec10_111-lulls-it-will-be-important-in-our-co.md` at and around line 78 (clause K4B itself) and line 346 (the stated purpose of the ordering)
- [x] Read `/home/benjamin/Projects/Literature/sources/reynolds_2001/sec11_132-a-new-chronicle-we-check-that-t.md` around line 264 (the most-recent-appearance formulation)
- [x] Adjudicate each of the three carried sub-claims separately and record the verdict for each: (i) the banned list has the shape `bl : T -> (C x {1,...,K})*`; (ii) `K` is the number of accepting pairs; (iii) K4B orders entries by recency of last appearance
- [x] Amend Finding 1.4 in place: cite each confirmed sub-claim by chunk filename and line; retain the `CARRIED-UNVERIFIED` marker on anything that genuinely remains carried; where a sub-claim is refuted, state the refutation and re-state the finding's conclusion on the surviving grounds (landed work preserved, proof difficulty) rather than deleting it
- [x] Amend the matching Risks & Mitigations row to the new evidence tier; do not delete the row while any part of the claim remains carried
- [x] Record an issue or win via `issue-record.sh` as the phase goes, per the dispatch's Issue Log contract

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: the only touched path is the report under `specs/**`, for which
`suite_selection_select` returned `__FULL_SWEEP__` at plan time, so sub-case (a)'s covering check
is `bash .claude/scripts/validate-artifact.sh specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md report`.

**Scope Hypothesis**: the report carries exactly 2 `CARRIED-UNVERIFIED` occurrences (lines 89 and
245, counted at plan time) and the K4B material is confined to the three Reynolds chunk files
named above; the implementer confirms both counts with the greps in the first task before editing
and widens the task list if either has moved.

**Files to modify**:
- `specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md` - Finding 1.4's grounding and citations; the matching Risks & Mitigations row

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md report` exits 0
- Every new citation names an existing chunk file and a line whose content matches the quoted
  text, spot-checked with `sed -n` on each cited line
- Any surviving `CARRIED-UNVERIFIED` marker sits on a claim that genuinely was not read in this
  phase, and the Risks row says so

---

### Phase 2: Fidelity-check Thomas 1997 Theorem 6.5 and Remark 6.6 [COMPLETED]

**Goal**: Settle, against the held PDF's page images, whether Finding 1.2's quoted construction
and Finding 1.3's tree-to-word transposition claim survive contact with the source — and record
the outcome either way, including "could not be completed".

**Tasks**:
- [x] Map the markdown anchors Finding 1.2 cites (`Thomas_1997_Languages_Automata_Logic.md:1975`
      for Theorem 6.5, `:2004` for Remark 6.6, `:1982-1986` for the data-structure attribution)
      onto PDF pages in `/home/benjamin/Projects/Literature/sources/thomas_1997_languages/Thomas_1997_Languages_Automata_Logic.pdf`
- [x] Read those pages as images and check verbatim against the report: the state set
      (order-vectors with hit), the initial state, the transition rule, the `E_i`/`F_i` chain
      definition, and Remark 6.6's two conditions
- [x] Check specifically whether anything in Theorem 6.5's statement or Remark 6.6's claim is
      tree-specific beyond the automaton type's name — this is Finding 1.3's load-bearing claim
- [x] Confirm or correct the report's statement that Thomas gives no proof of Remark 6.6
      ("one verifies the following claim"), since guardrail (f)'s partial fire rests on it
- [x] Amend Findings 1.2 and 1.3 with a fidelity note naming the actual PDF page numbers read,
      and correct any quoted text the page images contradict
- [x] Update the "stated for tree automata" Risks row with the check's outcome; if the check could
      not be completed, say so there explicitly and leave the risk standing rather than dropping it
- [x] Record an issue or win via `issue-record.sh` as the phase goes

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: the only touched path is the same `specs/**` report, for which
`suite_selection_select` returned `__FULL_SWEEP__`, so sub-case (a)'s covering check is
`bash .claude/scripts/validate-artifact.sh specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md report`.

**Scope Hypothesis**: Theorem 6.5 and Remark 6.6 sit close enough together to be covered by a
small page range (an estimate, not a fact — the markdown line numbers are not page numbers); the
implementer resolves the actual pages first, records them in the report, and if the mapping
cannot be resolved within a few reads, closes the phase by recording the attempt and leaving the
risk standing.

**Files to modify**:
- `specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md` - Findings 1.2 and 1.3 fidelity notes; the tree-automaton Risks row

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md report` exits 0
- The report names actual PDF page numbers for every statement checked, not markdown line numbers
- No quoted passage is left unreconciled: each is either confirmed, corrected, or explicitly
  recorded as unreadable

---

### Phase 3: Deliverable-contract audit, summary, and final gate [COMPLETED]

**Goal**: Confirm the report discharges all four dispatch deliverables and all six guardrails,
write the completion summary, and run the complete gate set.

**Tasks**:
- [x] Audit the report against deliverables (1)-(4) and guardrails (a)-(f) from the dispatch
      description, recording for each the report section that discharges it
- [x] Re-confirm guardrail (e)'s citations against the live fork: `git -C /home/benjamin/Projects/cslib log -1 --format=%h`
      and `grep -n "proof_wanted" /home/benjamin/Projects/cslib/Cslib/Computability/Automata/DA/Conversions.lean`
      (plan-time values: HEAD `3bdf16d9f`, `Rabin.toParity_exists` at line 89,
      `Muller.toRabin_exists` at line 112). If the fork has moved, update the report's cited lines
      and say so in the summary
- [x] Re-check guardrails (a) and (b) mechanically rather than by assertion:
      `git -C /home/benjamin/Projects/cslib status --porcelain -- '*.lean'` shows no modification
      attributable to this task, and `git diff --stat -- lakefile.toml lake-manifest.json` in this
      repository is empty
- [x] Write `specs/928_muller_torabin_determinization_cost_assessment/summaries/01_muller-torabin-cost-assessment-summary.md`
      per `context/formats/summary-format.md`: the four findings in brief, the disposition of each
      of the report's eight recommendations, the outcome of Phases 1 and 2, and the two deferred
      items (the `omega-automata-conversions.md` context extension; the 879 row-16 correction)
      each with the reason it was deferred rather than done
- [x] Run the complete gate set and record its outcome, separating findings that name this task's
      own files from the tree's standing baseline
- [x] Record an issue or win via `issue-record.sh`; if this phase genuinely has nothing to record,
      attest to that explicitly in the handoff prose

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: the audit covers exactly four deliverables and six guardrails and the
report's eight recommendations — counts read off the dispatch description and the report at plan
time; the implementer re-reads both before writing the audit table and widens it if either count
differs.

**Files to modify**:
- `specs/928_muller_torabin_determinization_cost_assessment/summaries/01_muller-torabin-cost-assessment-summary.md` - new completion summary
- `specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md` - only if the live fork re-check moves a cited line

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` is run and its outcome recorded in full. Per Condition 4
  of `context/project/lean4/patterns/plan-authoring-gate-collisions.md`, a red gate whose findings
  name only files outside this task's file scope is a recorded PASS for this phase, with each
  pre-existing finding enumerated; it is not a blocker and is not grounds to edit an out-of-scope
  file
- `bash .claude/scripts/validate-artifact.sh <report> report`, `... <plan> plan`, and
  `... <summary> summary` each exit 0
- `git -C /home/benjamin/Projects/cslib status --porcelain -- '*.lean'` shows no modification
  attributable to this task, and `git diff --stat -- lakefile.toml lake-manifest.json` is empty —
  guardrails (a) and (b) demonstrated, not asserted
- The summary's audit table has a row for every dispatch deliverable and every guardrail

## Testing & Validation

- [x] Every cited Reynolds chunk line exists and its content matches the quoted text
- [x] Every PDF page number cited for Thomas 1997 exists and its content matches the quoted text
- [x] No `CARRIED-UNVERIFIED` marker remains on a claim that was in fact read during Phase 1 or 2
- [x] `validate-artifact.sh` exits 0 on the report, the plan, and the summary
- [x] No `.lean` file is modified in either tree; `lakefile.toml` and `lake-manifest.json` are
      byte-identical to their pre-task state
- [x] The final gate set is run, and any red finding is attributed to this task's files or to the
      standing baseline explicitly
- [x] Commits name only this task's own files — no directory or glob staging, per the territory
      contract and `git-staging-scope.md`

## Artifacts & Outputs

- `specs/928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md` (amended: Findings 1.2, 1.3, 1.4 and two Risks rows)
- `specs/928_muller_torabin_determinization_cost_assessment/plans/01_muller-torabin-cost-assessment.md` (this file)
- `specs/928_muller_torabin_determinization_cost_assessment/summaries/01_muller-torabin-cost-assessment-summary.md` (new)
- `specs/928_muller_torabin_determinization_cost_assessment/issues.jsonl` (appended, via `issue-record.sh`)

No file outside `specs/928_muller_torabin_determinization_cost_assessment/` is created or
modified by this plan.

## Rollback/Contingency

Every edit this plan makes is a prose edit to files inside this task's own directory, each
committed separately per the commit-per-green-substep mandate. Rollback is therefore a per-phase
`git revert` of that phase's commit, with no build, proof, or dependency state to restore and no
other task's work entangled.

Contingencies by phase:

- **Phase 1**, if the Reynolds OCR proves unreadable for a load-bearing passage and the PDF does
  not resolve it: leave the `CARRIED-UNVERIFIED` marker in place, record the attempt and what was
  unreadable in the Risks row, and proceed. A failed de-carry is a recorded outcome, not a blocked
  phase — the finding is already stated with its carried status disclosed.
- **Phase 2**, if the page mapping cannot be resolved: record the attempt, leave the
  tree-automaton risk standing as written, and proceed to Phase 3.
- **Phase 3**, if the fork has moved and a cited line number is stale: update the citation and
  note the drift in the summary. If the fork has moved far enough that a cited declaration no
  longer exists, that is a finding worth recording, not a silent edit — state it in the summary
  and flag it in the handoff.
- If any phase would require writing a `.lean` file, editing `lakefile.toml`/`lake-manifest.json`,
  or adding a `require` to make its criterion meetable, that criterion is wrong: stop, record the
  collision via `issue-record.sh`, and report it rather than breaching a guardrail.
