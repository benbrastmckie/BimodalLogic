# Research Report: Task #931

**Task**: 931 - Apply the final-frame amendments to the 901 two-sided Reynolds engine paper-proof report
**Started**: 2026-11-19T00:00:00Z
**Completed**: 2026-11-19T00:00:00Z
**Effort**: low (location + verbatim-text confirmation only; no Lean, no re-derivation)
**Dependencies**: None
**Sources/Inputs**:
- `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` (read in full at the seven anchor sites plus the load-bearing non-anchor, grep-confirmed)
- `specs/archive/927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md` (read in full; Finding (3) is the verbatim source for four of the seven anchors)
- `specs/archive/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md` (read in full; `#### Phase 1 Notes` carries the complete seven-anchor table)
- `FormalSystem/Semantics/HistoryMorphism.lean` (grep-confirmed, lines 313-340, 681, 707)
- `FormalSystem/Semantics/OrientedForest.lean` (grep-confirmed, lines 880, 882)
- `FormalSystem/Semantics/UniversalCover.lean` (grep-confirmed, line 591)
- `specs/state.json` (task 931's own entry: `file_scope`, `description`, `audit_verdict`)
**Artifacts**:
- `specs/931_apply_901_final_frame_amendments/reports/01_apply-final-frame-amendments.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All seven anchors are confirmed live, unchanged, at the exact line numbers task 927's Phase 1
  Notes recorded six days ago.** A content-match re-locate plus a cross-check grep for every
  drifted-citation string found no eighth site and no further drift. The work list below is
  ready to apply mechanically; nothing needs re-measurement.
- **The verbatim replacement text for six of the seven anchors is unambiguous and is reproduced
  below exactly as task 927's records state it.** The seventh (anchor 3, the "weakest link" Risks
  paragraph) carries one load-bearing subtlety this report surfaces explicitly: Finding (3)'s
  quoted replacement text, applied literally and alone, drops the 901 report's own refusal
  sentence ("This write-up does not claim the final-frame step; it claims the engine up to it").
  The dispatch explicitly requires that sentence be preserved. **The correct application appends
  that sentence, verbatim, to the end of the Finding (3) replacement text** — this report states
  the exact resulting paragraph.
- **Two things that must not be touched are independently confirmed untouched by the proposed
  edit set**: §15.2's "doubtful by construction" assessment (line 904) and the refusal sentence
  just named. Neither anchor's replacement text, as applied, reaches either.
- **This is a record correction, not a completeness claim**, and the proposed edit set does not
  touch rows 17-21 of the ingredient table, (O1)/(O3)/(O4), or Recommendation 8.

## Context & Scope

Task 927 measured that both Lean pieces 901's final-frame step named as missing had landed four
to six hours after that report was committed, and wrote verbatim amendment text for the stale
surfaces plus a plan-time enumeration of every stale anchor the amendment touches. Task 927's own
guardrails forbade it from applying any of that text to the archived 901 report; this task (931)
is the filed successor whose `file_scope` is exactly that one report, and whose job is to apply
the amendment.

This research dispatch's scope is to re-confirm that nothing has drifted in the six days since
927's measurement, resolve the one formatting/preservation ambiguity named above, and hand the
plan/implementation phase a finished, by-content work list that needs no further re-derivation.
No edit was made to the 901 report, to any other archived report, or to any file under
`FormalSystem/` or `Tests/` during this research dispatch — none was in scope for a research
phase, and the actual application of the amendment is this task's implementation-phase work.

## Findings

### Codebase Patterns

**The seven-anchor table, re-located by content (not by trusting the recorded line numbers) and
found unchanged.** Task 927's Phase 1 Notes recorded this table against the 901 report at 1084
lines, measured 2026-11-13. The 901 report is still 1084 lines today, 2026-11-19, and every
anchor's matched text is found at the identical line:

| # | Matched text (anchor) | Live line (today) | Plan-time line (927) | Drift |
|---|---|---|---|---|
| 1 | `the two Lean pieces the final-frame step needs` (the `**missing**` ingredient row) | 110 | 110 | none |
| 2 | `` `OrientedForest.lean:134`, `HistoryMorphism.lean:589` `` (adjacent compiled row) | 109 | 109 | none |
| 3 | `Risk: the final-frame step is the weakest link` | 1001 | 1001 | none |
| 4 | `one step (the final frame) resting on two unlanded pieces` | 1002 | 1002 | none |
| 5 | `OrientedForest.lean:134`, `HistoryMorphism.lean:589` inside the evidence/status table | 1047 | 1047 | none |
| 6 | `Semantics/OrientedForest.lean:134` … `Semantics/HistoryMorphism.lean:306,589` in the reads list | 1075 | 1075 | none |
| 7 | `saturation_of_orientedForest` (compiled, `OrientedForest.lean:134`) inside §15.3's route prose | 908 | 908 | none |

**Cross-check for an eighth site.** A grep for every drifted-citation string the table names
(`OrientedForest.lean:134`, `HistoryMorphism.lean:589`, `HistoryMorphism.lean:306`) across the
whole 901 report returns exactly the occurrences at lines 109, 908, 1047 and 1075 — the same four
sites the table already enumerates, each counted once per its row above (line 109 carries one
instance of each of the first two strings; line 1047 the same pair; line 908 one instance of the
first string only; line 1075 one instance of each of all three strings). No further occurrence
exists. The enumeration is closed.

**Declaration locations re-confirmed from source, not from either report's description of them**
(the same discipline 927 itself used):

| Declaration | File | Live line | Matches 927's figure |
|---|---|---|---|
| `exists_orientedForest_cover_of_constraints` | `FormalSystem/Semantics/UniversalCover.lean` | 591 | yes |
| `plus_invariance_of_isZTime_of_constraints` | `FormalSystem/Semantics/HistoryMorphism.lean` | 681 | yes |
| `plus_invariance_of_isZTime` | `FormalSystem/Semantics/HistoryMorphism.lean` | 707 | yes |
| `saturation_of_orientedForest` | `FormalSystem/Semantics/OrientedForest.lean` | 880 | yes |
| `exists_preimage_step_neg` | `FormalSystem/Semantics/HistoryMorphism.lean` | 335 | yes (the stale `:306` 901 cites is `exists_preimage_step_neg_of_ne`'s docstring reference, not the theorem itself) |

**Two things confirmed untouched by the proposed edit set.** §15.2 (live line 904, "Reynolds
stops at … the quotient is not an oriented forest … `saturation_of_orientedForest` does not apply
directly") is load-bearing and is not named by any of the seven anchors — it is explicitly
excluded in both 927's Phase 1 Notes and this task's own dispatch description, and none of the
seven replacement texts below reaches line 904. The 901 report's refusal sentence ("This write-up
does not claim the final-frame step; it claims the engine up to it", inside the anchor-3
paragraph) is addressed directly in Finding (1) below.

### External Resources

None consulted. The question is purely about located Lean-declaration line numbers and the exact
text of two prior project records; no Mathlib or literature search applies.

### Finding (1): The one preservation subtlety in anchor 3, and its resolution

Task 927's Finding (3) supplies this replacement text for the anchor-3 paragraph (quoted here
verbatim, character-for-character, per the dispatch's "do not re-derive any of it"):

> **Amended 2026-11-13.** Both pieces this risk named as missing landed later the same day, and
> the lifting chain was audited. `exists_orientedForest_cover_of_constraints`
> (`UniversalCover.lean:591`) supplies the cover with its forest, double-seriality and
> two-way-boundedness properties; `plus_invariance_of_isZTime_of_constraints`
> (`HistoryMorphism.lean:681`) supplies invariance over a base carrying **no** `def:frame`
> constraint. The negative evidence recorded here — that `plus_invariance_of_isZTime` demands
> `[F.IsRegular]` on the base — is answered: that binder is now carried only on the specialised
> form, is marked `@[nolint unusedArguments]` with a comment recording that it is genuinely
> unread, and the general form takes no base binder at all. *Saturation* is consumed nowhere in
> the lifting chain on either side. The positive evidence recorded here (`exists_preimage_step_neg`
> using only `reflection`) is likewise discharged: at the nonzero step duration that use is
> `TaskFrame.reflect_reflection_of_ne`, a fact about how `FrameOver.TaskRel` extends `PosRel`
> rather than a constraint on the frame. What remains for §15 is API packaging, not mathematics —
> see Finding (2) of the remeasurement report.

**This text, applied alone in place of the whole anchor-3 paragraph, drops a sentence this task's
own dispatch explicitly names as must-preserve**: the paragraph being replaced ends "This
write-up does not claim the final-frame step; it claims the engine up to it." — a sentence the
dispatch's second "MUST NOT be touched" item names by exact quotation and states the replacement
"does NOT lift that refusal. Preserve it." Finding (3)'s replacement text, as written, contains
no occurrence of that sentence or an equivalent; a verbatim swap of the whole paragraph for
Finding (3)'s text alone would therefore silently delete it.

**Resolution**: append the refusal sentence, verbatim, as the final sentence of the replacement
text. The paragraph the implementation phase should write is Finding (3)'s text above with this
sentence added at the end: "This write-up does not claim the final-frame step; it claims the
engine up to it." This is the only way to satisfy both the "apply Finding (3)'s text" instruction
and the "preserve the refusal" instruction simultaneously; the two are not in tension once the
sentence is appended rather than treated as subsumed.

**A secondary, non-substantive formatting note.** Finding (3) renders its replacement text as a
markdown blockquote (`>`-prefixed) when quoting it inside the 927 report, as a visual device for
"this is quoted replacement text." The 901 report's Risks & Mitigations list has no other
blockquote-formatted item — every other risk (including the one at anchor 4, immediately
following) is a single `- **Risk: …**` list bullet with inline bold lead-in, never a blockquote.
Applying the replacement as a literal `>` blockquote would be the only such item in that list and
would break the list's own bullet structure (a blockquote is not a list item). This report
recommends applying the text as a `- **Amended 2026-11-13.** …` bullet — same bold lead-in style
Finding (3) chose, same list marker as every sibling risk, no `>` characters — preserving the
list's own formatting convention. This is a formatting-only recommendation; it changes no word of
the amendment text itself, and the `**Amended by** <doc>, <date>:` pattern (`Amended 2026-11-13.`
abbreviates it, with "see Finding (2) of the remeasurement report" supplying the cross-document
citation) is the project's own sanctioned amendment-note exemption to the no-record-versioning
rule.

### Finding (2): The complete verbatim work list for the remaining six anchors

**Anchor 1** (live line 110, the `**missing**` ingredient row). Replace:
```
| universal cover; invariance with no *Saturation* on the base | **missing** | the two Lean pieces the final-frame step needs |
```
with:
```
| `exists_orientedForest_cover_of_constraints`; `plus_invariance_of_isZTime_of_constraints` | **compiled** | `UniversalCover.lean:591`, `HistoryMorphism.lean:681` — both landed 2026-11-09, after this report |
```

**Anchor 2** (live line 109, the adjacent row's citations). Replace:
```
| `saturation_of_orientedForest`, `plus_invariance_of_isZTime` | compiled | `OrientedForest.lean:134`, `HistoryMorphism.lean:589` |
```
with:
```
| `saturation_of_orientedForest`, `plus_invariance_of_isZTime` | compiled | `OrientedForest.lean:880`, `HistoryMorphism.lean:707` |
```

**Anchor 4** (live line 1002, the companion Risks paragraph — one clause only). Replace the
clause "one step (the final frame) resting on two unlanded pieces" with "one step (the final
frame), now resting on landed pieces". Every other word of this bullet (including its own
`*Mitigation*` sentence) is, per Finding (3), "still accurate and needs no amendment" and must be
left untouched.

**Anchor 5** (live line 1047, the evidence/status table). Replace:
```
| `saturation_of_orientedForest`; `plus_invariance_of_isZTime` demands `[F.IsRegular]` on the base | compiled (`OrientedForest.lean:134`, `HistoryMorphism.lean:589`) |
```
with:
```
| `saturation_of_orientedForest`; `plus_invariance_of_isZTime` demands `[F.IsRegular]` on the base | compiled (`OrientedForest.lean:880`, `HistoryMorphism.lean:707`) |
```

**Anchor 6** (live line 1075, the reads list). Replace:
```
`Semantics/OrientedForest.lean:134` (`saturation_of_orientedForest`), `Semantics/HistoryMorphism.lean:306,589` (`exists_preimage_step_neg`, `plus_invariance_of_isZTime`).
```
with:
```
`Semantics/OrientedForest.lean:880` (`saturation_of_orientedForest`), `Semantics/HistoryMorphism.lean:335,707` (`exists_preimage_step_neg`, `plus_invariance_of_isZTime`).
```

**Anchor 7** (live line 908, §15.3's route prose — found by task 927 at implementation time,
reached by neither Finding (3) nor 927's plan-time task list). Replace the citation
`OrientedForest.lean:134` with `OrientedForest.lean:880` inside the sentence "…which is an
oriented forest, hence saturated by `saturation_of_orientedForest` (compiled,
`OrientedForest.lean:134`), doubly serial, …" — no other word of that sentence changes.

**Deliberate non-anchor, confirmed at live line 910**: the "**The two missing pieces, named.**"
paragraph in §15.3 is stale by the same measure as anchors 1 and 3, but Finding (3) directs its
replacement to be the anchor-3 amendment text rather than a separate rewrite — no independent
edit is made at line 910. This report confirms that instruction is still live and correct: line
910's content (the "(i) … (ii) …" piece-naming) duplicates exactly what anchor 3's replacement
text supersedes, including the same stale `HistoryMorphism.lean:589` citation.

### Finding (3): Guardrail and scope confirmation

`specs/state.json`'s task 931 entry declares `file_scope: ["specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md"]` and no dependencies — matching the dispatch exactly. No other file is in scope for this task, and no Lean file, build file, or second archived report is touched by any of the seven proposed edits above. The proposed edit set does not add, remove, or reword anything about rows 17-21 of the ingredient table, (O1), (O3), (O4), or Recommendation 8 — none of the seven anchors names any of those surfaces, and this report introduces no eighth edit beyond the seven the dispatch's own work list enumerates.

## Recommendations

- **Apply the seven edits of Finding (2) and the resolved anchor-3 text of Finding (1) exactly as
  given**, locating each by its matched text (never by the line numbers recorded above, which are
  measurements taken today and will drift the instant any earlier edit in the same file changes
  line counts). Apply in descending line order (908 is now *before* 1001/1002/1047/1075 numerically
  but after 109/110; applying earlier-line edits first and later-line edits afterward avoids any
  edit shifting a not-yet-applied anchor's line number, though content-based location makes this
  only a convenience, not a requirement).
- **Render anchor 3's combined text as a single `- **Amended 2026-11-13.** …` list bullet**,
  ending with the appended refusal sentence named in Finding (1), not as a markdown blockquote —
  see Finding (1)'s formatting note for why.
- **Do not touch line 904 (§15.2) or any text outside the seven named anchors.** No other
  staleness exists in this report as of this measurement; a future remeasurement task, not this
  one, is the right place to check again if further Lean landings occur.
- **Record the applied edits in the implementation phase's summary with the "record correction,
  not completeness claim" framing stated verbatim**, matching this task's own dispatch description
  and Decision 3 below, so a future reader of the 901 report's amended Risks section does not
  misread the correction as reopening T3 completeness.

## Decisions

1. **The anchor-3 replacement text is amended by appending the refusal sentence, not by
   re-deriving new prose.** Finding (3)'s text is reproduced character-for-character; only the
   dispatch's own explicit must-preserve instruction is additionally satisfied by appending the
   one named sentence. No other word of Finding (3)'s text is altered.
2. **The blockquote-vs-bullet question is resolved as a formatting recommendation, not as a
   content change.** Finding (3)'s `>`-rendering is read as the 927 report's own quoting
   convention, not as an instruction to introduce blockquote syntax into the 901 report's bulleted
   Risks list.
3. **No `user_decision` is raised.** The dispatch names a mechanical record correction with
   verbatim replacement text already supplied; this report's one genuine finding (the
   refusal-sentence preservation) is a textual-fidelity question this research dispatch is
   competent to resolve from the dispatch's own explicit instruction, not a preference, cost, or
   ambiguity requiring the user's judgment.
4. **No edit was made to the 901 report, or to any file, during this research dispatch.** Applying
   the seven-anchor work list is implementation-phase work; this dispatch's deliverable is the
   confirmed, by-content work list itself.

## Risks & Mitigations

- **Risk: a future line-count change to the 901 report (none occurred between 927's measurement
  and this one) invalidates the line numbers recorded above before the implementation phase
  runs.** *Mitigation*: every anchor above is stated with its matched text as the primary locator;
  the line numbers are measurements of today, explicitly labelled as such, exactly as the dispatch
  requires.
- **Risk: the implementation phase applies Finding (3)'s anchor-3 text literally and drops the
  refusal sentence, reproducing the exact defect this report exists to catch.** *Mitigation*:
  Finding (1) states the resolved, final paragraph text in full rather than only describing the
  fix, so the implementation phase has the complete already-merged text rather than having to
  perform the merge itself.
- **Risk: an eighth drifted-citation site is missed.** *Mitigation*: the cross-check grep in
  Codebase Patterns searched for every citation string any of the seven anchors names, across the
  whole file, and found exactly the occurrences the seven-anchor table already accounts for.
- **Risk: this report's own recommendations are read as advancing T3 completeness.** *Mitigation*:
  stated explicitly in the Executive Summary, in Finding (3), and in the Recommendations' closing
  bullet.

## Context Extension Recommendations

None. This task's surface (locating and re-confirming a prior record's amendment anchors) is a
one-off record-correction operation with no reusable pattern beyond what
`context/standards/record-version-exemptions.md` already documents for amendment notes.

## Appendix

### Searches and reads

- `grep -n "the two Lean pieces the final-frame step needs\|OrientedForest.lean:134\|HistoryMorphism.lean:589\|HistoryMorphism.lean:306\|Risk: the final-frame step is the weakest link\|one step (the final frame) resting on two unlanded pieces\|The two missing pieces, named\|exists_preimage_step_neg\|does not claim the final-frame step" specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` — located all seven anchors by content in one pass.
- `grep -n "OrientedForest.lean:134"`, `grep -n "HistoryMorphism.lean:589"`, `grep -n "HistoryMorphism.lean:306"` (each run separately over the full 901 report) — the closure cross-check for Finding (2)'s enumeration.
- `grep -n "exists_preimage_step_neg\|^theorem plus_invariance_of_isZTime\|^def plus_invariance_of_isZTime\|saturation_of_orientedForest" FormalSystem/Semantics/HistoryMorphism.lean FormalSystem/Semantics/OrientedForest.lean` — confirmed live declaration line numbers against source, not against either report's description.
- `grep -n "^theorem exists_orientedForest_cover_of_constraints" FormalSystem/Semantics/UniversalCover.lean` — confirmed line 591.
- `wc -l specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` — 1084 lines, matching 927's plan-time figure exactly.
- `jq '.active_projects[] | select(.project_number==931)' specs/state.json` — confirmed `file_scope`, `description`, and `audit_verdict` for this task.

### Evidence tier by claim

| Claim | Tier |
|---|---|
| All seven anchors present at the identical lines 927 recorded | measured (content-match grep, this dispatch, against live source) |
| No eighth drifted-citation site exists | measured (cross-check grep over the whole file, this dispatch) |
| The five declaration line numbers (591, 681, 707, 880, 335) | measured (grep against live `.lean` source, this dispatch) |
| Finding (3)'s replacement text, quoted verbatim | carried (927's report, not re-derived) |
| The refusal-sentence preservation requirement | carried (this task's own dispatch description, quoted exactly) |
| §15.2 (line 904) is load-bearing and untouched by the proposed edits | carried (927's Phase 1 Notes and this task's dispatch; independently confirmed none of the seven anchors' line numbers is 904) |
