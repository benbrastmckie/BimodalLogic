# Implementation Plan: Task #931

- **Task**: 931 - Apply the final-frame amendments to the 901 two-sided Reynolds engine paper-proof report
- **Status**: [NOT STARTED]
- **Effort**: 1.25 hours
- **Dependencies**: None
- **Research Inputs**: `specs/931_apply_901_final_frame_amendments/reports/01_apply-final-frame-amendments.md`
- **Artifacts**: plans/01_apply-final-frame-amendments.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

One markdown file is corrected in place: the archived 901 paper-proof report, whose final-frame
surfaces have been stale since 2026-11-09 17:56 (both Lean pieces it names as missing landed four
to six hours after it was committed). The replacement text was written verbatim by task 927 and
must not be re-derived. The work is **eight** textual anchors in one file, applied by content
match and never by line number, split into a drift-only phase, a claim-changing phase, and a
closure/invariant verification phase.

### Carried-Figure Re-Validation (plan-time, measured today 2026-11-19)

The dispatch's `## Premise Re-Validation` section extracted the "RE-LOCATE BY CONTENT" line. Result,
stated explicitly as the discipline requires:

| Carried claim | Plan-time result |
|---|---|
| 901 report at 1084 lines | **confirmed** — `wc -l` = 1084, unchanged since 927's measurement and since the research dispatch |
| All anchors live at the lines the research report recorded (109, 110, 908, 1001, 1002, 1047, 1075) | **confirmed** by content-match grep; zero drift |
| Declaration lines 591 / 681 / 707 / 880 / 335 | **confirmed** by grep against live `.lean` source (`UniversalCover.lean:591`, `HistoryMorphism.lean:681` and `:707`, `OrientedForest.lean:880`, `HistoryMorphism.lean:335`) |
| `plus_invariance_of_isZTime` carries `@[nolint unusedArguments]` with an unread-binder comment | **confirmed** at `HistoryMorphism.lean:699-707` — the amendment text's claim about it is accurate today |
| §15.2 (line 904) load-bearing and reached by no anchor | **confirmed** — line 904 is the "quotient is not an oriented forest" assessment; no anchor's matched text lies on it |
| Research report: "the cross-check grep returns exactly the occurrences at lines 109, 908, 1047 and 1075 ... The enumeration is closed." | **FALSIFIED as a site list.** A live per-string re-grep returns `OrientedForest.lean:134` at 109/908/1047/1075, `HistoryMorphism.lean:589` at 109/**910**/1047, and `HistoryMorphism.lean:306` at 1075 only. Line **910** is a site the research report's closure sentence omits, and line 1075's `:306,589` is a comma-joined pair the standalone `:589` grep never matched. See Decision 1. |

No other figure in the research report required correction; everything else above it is confirmed
unchanged.

### Research Integration

The research report supplies the by-content work list and resolves the one genuine textual
question (the refusal sentence must be **appended** to task 927's anchor-3 replacement text, not
treated as subsumed by it — a literal swap would silently delete a sentence the dispatch names as
must-preserve). Both resolutions are adopted here unchanged. Its formatting resolution (render the
amendment as a `- **Amended 2026-11-13.** …` list bullet, never as a `>` blockquote, because the
901 report's Risks list has no blockquote item and a blockquote is not a list item) is also
adopted unchanged. One conclusion is **not** adopted: see Decision 1.

### Prior Plan Reference

No prior plan for task 931. Task 927's own plan (`#### Phase 1 Notes`) is an *input* record, not a
prior version of this plan; its seven-anchor table is read as source material and its effort
calibration (a by-content locate pass costs minutes, not hours) informs the estimates below.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no roadmap flag is set. This is a
record correction and advances no roadmap item: applying it does not make T3 complete, leaves rows
17-21 of the ingredient table as paper, and does not touch (O1), (O3), (O4), or Recommendation 8.

## Goals & Non-Goals

**Goals**:
- Correct all eight stale final-frame surfaces in `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`, using task 927's verbatim replacement text.
- Preserve the 901 report's own refusal sentence ("This write-up does not claim the final-frame step; it claims the engine up to it.") inside the replaced Risks bullet.
- Leave the report internally consistent: no surface may still call the two pieces missing after an adjacent surface calls them compiled.
- Verify, mechanically, that the two must-not-touch surfaces are byte-unchanged.

**Non-Goals**:
- Re-deriving, rewording, or re-measuring any amendment text or landing timestamp. The dispatch forbids it; every figure comes from task 927's records or a plan-time confirmation grep.
- Editing any `.lean` file, any other archived report, or anything outside the one declared `file_scope` path.
- Claiming T3 completeness, reopening the completeness programme, or editing Recommendation 8.
- Re-dating the amendment note to today. `**Amended 2026-11-13.**` is the date the amendment was *written*, carried verbatim; the implementer must not "helpfully" advance it to 2026-11-19.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The anchor-3 swap is applied literally from task 927's Finding (3) and silently drops the refusal sentence — the exact defect the research dispatch exists to catch | H | M | Phase 2 gives the **fully merged** bullet text in a fenced block; the implementer copies it rather than performing the merge. Phase 3 greps for the refusal sentence and requires exactly one occurrence. |
| Collateral damage to §15.2 (line 904), whose "the quotient is not an oriented forest" assessment is the reason the cover route exists | H | L | Named as must-not-touch in both edit phases; Phase 3 confirms line 904's text byte-unchanged via `git diff` hunk inspection. |
| Collateral damage to line 112's unrelated `**missing**` (the programme report's row 2, `LCU`) while flipping line 110's `**missing**` | M | M | Phase 2's `old_string` for line 110 is the full table row, not the bare `**missing**` token; Phase 3 confirms line 112 still carries its `**missing**`. |
| Replacing the line-1001 bullet removes the `**Risk: …**` lead-in, so the amendment bullet's opening "Both pieces **this risk** named as missing" loses its antecedent | M | M | Accepted, not re-derived: task 927's Finding (3) says explicitly "Replace the paragraph beginning '**Risk: the final-frame step is the weakest link…**' with:" and the dispatch forbids re-derivation. The sibling line-1002 risk and the amended §15.3 paragraph supply the surrounding context, and the appended refusal sentence restores the entry's cautionary register. |
| The amendment paragraph appears twice in one document (Risks bullet and §15.3 prose) | L | H (by design) | Intended: task 927 directs §15.3's stale paragraph to be replaced *by the Risks amendment text* rather than by a separate rewrite. The §15.3 copy omits the Risks-specific refusal sentence so the refusal occurs exactly once, in the paragraph the dispatch says it sits in. |
| A ninth stale surface exists and is missed | M | L | Phase 3's closure grep sweeps all three stale citation strings plus `**missing**` plus "unlanded"/"unverified" phrasing across the whole file, and requires every surviving hit to be an enumerated, deliberate non-anchor. |
| `verify-touched.sh` cannot run in this repo's deployed tree (stale `core`) and a verification claim is asserted rather than measured | L | M (already hit) | Already hit at plan time and recorded in `issues.jsonl`; the selector was run from the source store instead and returned `__FULL_SWEEP__`. Phase 3 names `validate-artifact.sh` as the covering check rather than a suite. |

## Decisions

1. **The work list carries EIGHT anchors, not seven. Line 910 (§15.3's "**The two missing pieces,
   named.**" paragraph) is replaced, not left standing.** The research report's Finding (2)
   concludes "no independent edit is made at line 910". That reading is not adopted, for two
   reasons. (a) Both higher-authority inputs say the paragraph *is* replaced: task 927's Finding
   (3) states "Section 15.3's own prose … is stale by the same measure; **its replacement text is
   the Risks amendment above**", and this dispatch's own description states "Finding (3) directs
   **its replacement** to be the Risks amendment text rather than a separate rewrite" — both
   instruct a replacement whose *text* is the amendment, not an exemption from editing. (b)
   Leaving it would defeat the task's purpose: line 910 asserts the cover construction is
   "**missing**" and cites `HistoryMorphism.lean:589`, so after Phase 2 flips line 110 to
   **compiled** the report would contradict itself two sections apart. The §15.3 copy is applied
   as a plain bold-lead-in paragraph (matching its own section's prose shape), without the
   refusal sentence, which stays in its Risks home.
2. **No `user_decision` is raised.** Decision 1 is resolved by the dispatch's own explicit
   wording, not by a preference the artifacts cannot infer; the remaining questions (formatting,
   refusal preservation) were resolved by this round's research. Nothing here needs the user's
   judgment, cost acceptance, or authorization.
3. **Every anchor is located by its matched text.** The line numbers throughout this plan are
   measurements taken 2026-11-19 and are navigational aids only; applying any earlier edit may
   shift them, and the implementer must never use one as an `old_string` locator.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Phases within the same wave can execute in parallel. All three phases write the same single file,
so they are deliberately serialized into three waves of one.

### Phase 1: Correct the four drift-only citation sites [NOT STARTED]

**Goal**: Every stale Lean line-number citation in the 901 report points at the live declaration,
with no claim, status, or prose change anywhere in this phase.

**Tasks**:
- [ ] Locate by content and correct the adjacent compiled ingredient row (live line 109). Replace
      the exact row:
      ```
      | `saturation_of_orientedForest`, `plus_invariance_of_isZTime` | compiled | `OrientedForest.lean:134`, `HistoryMorphism.lean:589` |
      ```
      with:
      ```
      | `saturation_of_orientedForest`, `plus_invariance_of_isZTime` | compiled | `OrientedForest.lean:880`, `HistoryMorphism.lean:707` |
      ```
- [ ] Locate by content and correct §15.3's route-prose citation (live line 908): change
      `OrientedForest.lean:134` to `OrientedForest.lean:880` inside the sentence beginning
      "Replace `S` by its **universal cover** `S̃`". No other word of that sentence changes.
- [ ] Locate by content and correct the evidence/status table row (live line 1047). Replace:
      ```
      | `saturation_of_orientedForest`; `plus_invariance_of_isZTime` demands `[F.IsRegular]` on the base | compiled (`OrientedForest.lean:134`, `HistoryMorphism.lean:589`) |
      ```
      with:
      ```
      | `saturation_of_orientedForest`; `plus_invariance_of_isZTime` demands `[F.IsRegular]` on the base | compiled (`OrientedForest.lean:880`, `HistoryMorphism.lean:707`) |
      ```
- [ ] Locate by content and correct the reads list (live line 1075). Replace:
      ```
      `Semantics/OrientedForest.lean:134` (`saturation_of_orientedForest`), `Semantics/HistoryMorphism.lean:306,589` (`exists_preimage_step_neg`, `plus_invariance_of_isZTime`).
      ```
      with:
      ```
      `Semantics/OrientedForest.lean:880` (`saturation_of_orientedForest`), `Semantics/HistoryMorphism.lean:335,707` (`exists_preimage_step_neg`, `plus_invariance_of_isZTime`).
      ```
- [ ] Re-grep each of the three stale strings (`OrientedForest.lean:134`, `HistoryMorphism.lean:589`,
      `HistoryMorphism.lean:306`) and confirm the only surviving hit is `HistoryMorphism.lean:589`
      at the §15.3 paragraph Phase 2 replaces (live line 910). Any other surviving hit is an
      unenumerated ninth site — stop and record it before continuing.
- [ ] Commit this green sub-step.

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts there are exactly **four** drift-only citation sites
(live lines 109, 908, 1047, 1075) and that line 910 is the only `:589` hit left standing after it.
Confirm at implementation time with the three per-string greps named in the final task above —
not by trusting this count.

**Tier Justification**: the only touched path is a `specs/**` markdown report with no compile or
elaboration surface, and `suite_selection_select` returns `__FULL_SWEEP__` for it (measured at
plan time from the source store, since this repo's deployed `verify-touched.sh` aborts on a stale
`suite-selection-map.data` entry), so no suite covers it; the covering check is the `prose` row's
diff read-through confirming all four hunks are citation-token-only, plus
`bash .claude/scripts/validate-artifact.sh <report path> report`.

**Files to modify**:
- `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` - four citation-token corrections at live lines 109, 908, 1047, 1075

**MUST NOT touch in this phase**: line 110's `**missing**` row (Phase 2), line 112's unrelated
`**missing**` (the programme report's row 2, `LCU`), line 904 (§15.2), line 910 (Phase 2), the two
Risks bullets at lines 1001-1002 (Phase 2).

**Verification**:
- `git diff` on the report shows exactly four changed hunks, every one of them a citation-token
  substitution inside an otherwise byte-identical line.
- `grep -c 'OrientedForest.lean:134'` returns 0; `grep -n 'HistoryMorphism.lean:589'` returns
  exactly one hit, on the §15.3 paragraph; `grep -c 'HistoryMorphism.lean:306'` returns 0.
- `grep -c 'OrientedForest.lean:880'` returns 4; `grep -c 'HistoryMorphism.lean:707'` returns 2;
  `grep -c 'HistoryMorphism.lean:335'` returns 1.

---

### Phase 2: Apply the four claim-changing corrections [NOT STARTED]

**Goal**: Every surface that still calls the two final-frame pieces missing or unlanded now records
them as landed, using task 927's verbatim amendment text, with the 901 report's refusal sentence
preserved exactly once.

**Tasks**:
- [ ] Locate by content and replace the `**missing**` ingredient row (live line 110). Replace:
      ```
      | universal cover; invariance with no *Saturation* on the base | **missing** | the two Lean pieces the final-frame step needs |
      ```
      with:
      ```
      | `exists_orientedForest_cover_of_constraints`; `plus_invariance_of_isZTime_of_constraints` | **compiled** | `UniversalCover.lean:591`, `HistoryMorphism.lean:681` — both landed 2026-11-09, after this report |
      ```
      Use the whole row as the `old_string`, never the bare `**missing**` token — line 112 carries
      an unrelated `**missing**` that must survive.
- [ ] Locate by content and replace the weakest-link Risks bullet (live line 1001) — the whole
      list item beginning `- **Risk: the final-frame step is the weakest link` — with this single
      list item, copied exactly (it is task 927's Finding (3) text with the refusal sentence
      appended as its final sentence; do not re-merge, re-wrap, or re-date it, and do not render
      it as a `>` blockquote):
      ```
      - **Amended 2026-11-13.** Both pieces this risk named as missing landed later the same day, and the lifting chain was audited. `exists_orientedForest_cover_of_constraints` (`UniversalCover.lean:591`) supplies the cover with its forest, double-seriality and two-way-boundedness properties; `plus_invariance_of_isZTime_of_constraints` (`HistoryMorphism.lean:681`) supplies invariance over a base carrying **no** `def:frame` constraint. The negative evidence recorded here — that `plus_invariance_of_isZTime` demands `[F.IsRegular]` on the base — is answered: that binder is now carried only on the specialised form, is marked `@[nolint unusedArguments]` with a comment recording that it is genuinely unread, and the general form takes no base binder at all. *Saturation* is consumed nowhere in the lifting chain on either side. The positive evidence recorded here (`exists_preimage_step_neg` using only `reflection`) is likewise discharged: at the nonzero step duration that use is `TaskFrame.reflect_reflection_of_ne`, a fact about how `FrameOver.TaskRel` extends `PosRel` rather than a constraint on the frame. What remains for §15 is API packaging, not mathematics — see Finding (2) of the remeasurement report. This write-up does not claim the final-frame step; it claims the engine up to it.
      ```
- [ ] Locate by content and correct the one clause in the companion Risks bullet (live line 1002):
      change `one step (the final frame) resting on two unlanded pieces` to
      `one step (the final frame), now resting on landed pieces`. Every other word of that bullet,
      including its own `*Mitigation*` sentence and its "the whole resting on no machine checking"
      claim, is still accurate per task 927's Finding (3) and must be left untouched.
- [ ] Locate by content and replace §15.3's stale paragraph (live line 910) — the whole paragraph
      beginning `**The two missing pieces, named.**` — with the same amendment text as a plain
      paragraph: identical to the bullet above but with the leading `- ` list marker removed and
      **without** the appended refusal sentence (which belongs to, and must occur only in, the
      Risks bullet). See Decision 1 for why this anchor is in scope.
- [ ] Commit this green sub-step.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts there are exactly **four** claim-changing sites (live
lines 110, 910, 1001, 1002) and that the only `**missing**` token surviving the phase is line
112's unrelated programme-report reference. Confirm at implementation time with
`grep -n '\*\*missing\*\*'` over the whole file and with the `unlanded`/`unverified` grep in the
verification block below — not by trusting this count.

**Tier Justification**: the only touched path is the same `specs/**` markdown report with no
compile or elaboration surface, for which `suite_selection_select` returns `__FULL_SWEEP__`
(measured at plan time from the source store), so no suite covers it; the covering check is the
`prose` row's diff read-through against the four fenced replacement texts above, plus
`bash .claude/scripts/validate-artifact.sh <report path> report`.

**Files to modify**:
- `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` - the status row at live line 110, the §15.3 paragraph at live line 910, and the two Risks bullets at live lines 1001-1002

**MUST NOT touch in this phase**: line 904 (§15.2's "the quotient is not an oriented forest"
assessment — load-bearing, it is the reason the cover route exists); line 112's `**missing**`;
rows 17-21 of the ingredient table; (O1), (O3), (O4); Recommendation 8; the four citation sites
Phase 1 already corrected.

**Verification**:
- `grep -c 'This write-up does not claim the final-frame step; it claims the engine up to it.'`
  returns exactly 1 — the refusal sentence survives, once, inside the amended Risks bullet.
- `grep -c 'Amended 2026-11-13.'` returns exactly 2 (the Risks bullet and the §15.3 paragraph).
- `grep -n '\*\*missing\*\*'` returns exactly one hit, on line 112's programme-report sentence.
- `grep -n 'two unlanded pieces\|The two missing pieces, named\|Risk: the final-frame step is the weakest link'`
  returns no hits.
- `grep -c 'HistoryMorphism.lean:589'` returns 0 (the last `:589` hit, inside the §15.3 paragraph,
  is removed with that paragraph).
- `git diff` shows exactly four changed hunks for this phase; line 904's text and line 112's text
  appear in no hunk.

---

### Phase 3: Closure, invariant confirmation, and final gate [NOT STARTED]

**Goal**: Prove mechanically that the enumeration was closed at eight anchors, that both
must-not-touch surfaces are byte-unchanged, and that the amended report is internally consistent
and still passes artifact validation.

**Tasks**:
- [ ] Run the closure sweep over the whole report for every stale form:
      `grep -n 'OrientedForest.lean:134\|HistoryMorphism.lean:589\|HistoryMorphism.lean:306\|two unlanded pieces\|The two missing pieces, named\|the two Lean pieces the final-frame step needs'`
      — expect zero hits. Any hit is a ninth site; stop and record it rather than silently fixing it.
- [ ] Run the residual-staleness sweep: `grep -n 'unlanded\|is \*\*unverified\*\*\|\*\*missing\*\*'`
      and confirm every surviving hit is a deliberate, enumerated non-anchor (line 112's
      programme-report row 2; rows 17-21's own paper/missing markers, which this task does not
      touch). Record the surviving hit list in the phase notes.
- [ ] Confirm both must-not-touch surfaces are byte-unchanged by inspecting the cumulative
      `git diff` for the file: §15.2's line-904 paragraph ("Reynolds stops at … the quotient is not
      an oriented forest … `saturation_of_orientedForest` does not apply directly") appears in no
      hunk, and the refusal sentence appears in a hunk only as added/retained context, never as a
      deletion without a matching addition.
- [ ] Confirm the untouched-surface guarantees: `grep -n 'Recommendation 8\|(O1)\|(O3)\|(O4)'` hits
      appear in no `git diff` hunk for this file.
- [ ] Confirm the report's line count and internal consistency: `wc -l` on the file, and a read of
      §15.3 plus the Risks section end-to-end confirming no surface still calls the two pieces
      missing while another calls them compiled.
- [ ] Run the full gate set (below) and commit the phase.

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the enumeration is **closed at eight anchors** — that no
ninth stale final-frame surface exists in the 1084-line report. Confirm with the two whole-file
sweeps in the first two tasks above; the assertion is a hypothesis of this plan, not a fact, and
the research report's own seven-anchor closure sentence was already found mis-stated (see the
Carried-Figure table), so this sweep is the real check.

**Files to modify**:
- `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` - no further edits expected; listed because a failed invariant or closure check is corrected here

**Verification** (the complete gate set — no tier narrowing applies to this phase):
- `bash .claude/scripts/validate-artifact.sh specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md report` exits 0.
- `bash .claude/scripts/validate-artifact.sh specs/931_apply_901_final_frame_amendments/plans/01_apply-final-frame-amendments.md plan` exits 0.
- `bash .claude/scripts/validate-state.sh` exits 0.
- `bash .claude/scripts/validate-return-meta.sh` (against this task's `.return-meta.json`) exits 0.
- No Lean build, lint, or test suite is in the gate set for this task, and asserting one would be
  dishonest: no `.lean`, `.toml`, or script file is touched, and `suite_selection_select` returns
  `__FULL_SWEEP__` for the single touched path (measured at plan time from the source store at
  `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/lib/suite-selection-lib.sh`,
  because this repo's deployed `verify-touched.sh` aborts on a stale `suite-selection-map.data`
  entry — recorded in `issues.jsonl`).
- Both closure sweeps above return their expected hit sets, and the cumulative `git diff` for the
  file shows exactly eight changed hunks and no others.

---

## Testing & Validation

- [ ] All three stale citation strings (`OrientedForest.lean:134`, `HistoryMorphism.lean:589`, `HistoryMorphism.lean:306`) are absent from the report.
- [ ] All five live citations appear with the correct multiplicity: `OrientedForest.lean:880` (4), `HistoryMorphism.lean:707` (2), `HistoryMorphism.lean:335` (1), `HistoryMorphism.lean:681` (2), `UniversalCover.lean:591` (2).
- [ ] The refusal sentence occurs exactly once.
- [ ] `**Amended 2026-11-13.**` occurs exactly twice, dated 2026-11-13 and not re-dated.
- [ ] §15.2's line-904 paragraph is byte-unchanged.
- [ ] Line 112's unrelated `**missing**` is byte-unchanged.
- [ ] Rows 17-21, (O1), (O3), (O4), and Recommendation 8 are byte-unchanged.
- [ ] `validate-artifact.sh` passes on the amended report and on this plan; `validate-state.sh` passes.
- [ ] The cumulative diff for the task is exactly eight hunks in exactly one file.

## Artifacts & Outputs

- The amended `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` (eight corrected anchors).
- `specs/931_apply_901_final_frame_amendments/summaries/01_apply-final-frame-amendments-summary.md`, which MUST state the "record correction, not a completeness claim" framing explicitly — applying this amendment does not make T3 complete, leaves rows 17-21 as paper, and leaves (O1)/(O3)/(O4) and Recommendation 8 untouched — so a future reader of the amended Risks section does not misread it as reopening T3 completeness.
- Three phase commits plus the completion commit, all scoped to the one report path (plus this task's own `specs/931_*` artifacts).

## Rollback/Contingency

Every edit is a content-located textual substitution in a single tracked markdown file, and each
phase commits separately, so rollback is `git revert` of the offending phase commit — no snapshot
or tree-destructive operation is needed, and none is authorized here.

Contingencies:
- **A ninth stale site is found** (Phase 1's or Phase 3's sweep returns an unexpected hit): do not
  invent replacement text for it. Record it in `issues.jsonl`, complete the eight enumerated
  anchors, and report the ninth site in the handoff and summary as residual staleness for a
  successor remeasurement task — the same guardrail task 927 operated under.
- **An `old_string` does not match** (the matched text has drifted since this plan was written):
  re-locate by a shorter distinctive substring of the same anchor. Never fall back to a line
  number, and never widen the `old_string` to a region that includes line 904 or line 112.
- **The anchor-3 merge is found already wrong after commit**: the fully merged text is fenced in
  Phase 2 and in the research report's Finding (1); re-apply from there rather than re-deriving it
  from task 927's blockquote.
