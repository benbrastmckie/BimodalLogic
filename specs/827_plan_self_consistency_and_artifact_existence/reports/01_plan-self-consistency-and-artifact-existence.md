# Research Report: Task #827

**Task**: 827 - Require a plan phase to agree with its own Scope Hypothesis and to name only artifacts that exist
**Started**: 2026-11-07
**Completed**: 2026-11-07
**Effort**: low
**Dependencies**: 769, 772, 774 (task-level; none block this record's own `plan-format.md` edit territory)
**Sources/Inputs**: Codebase exploration of `context/formats/plan-format.md`, `agents/planner-agent.md`, `scripts/plan-file-scope-harvest.sh`, `index-entries.json`, and the local `specs/*/plans/*.md` corpus
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The source store for the `core` extension is `/home/benjamin/.config/nvim/agent-system/extensions/core`; both edit targets (`context/formats/plan-format.md`, `agents/planner-agent.md`) and the wiring file (`index-entries.json`) resolve cleanly under it.
- `plan-format.md` is currently 1020 lines (not the 784 the dispatch's addendum recorded — two unrelated tasks landed in the interim); `index-entries.json`'s existing entry already carries `line_count: 1020`, so no drift exists today, but the entry must be re-checked against the file's final line count after this record's own edits land.
- Both items' natural homes are confirmed: item 1 sits beside "Counts-are-hypotheses obligation" (plan-format.md, current lines 471-498) and connects to "Reasoned Exclusions" (lines 798-836); item 2 sits beside "Files to modify" 's "Consumers of this field" subsection (lines 134-170), since it is the field whose entries name the targets in question.
- The sibling lean-extension record's precedence rule (pinned Challenge block beats an order-dependent Verification criterion) is not yet landed in any file on disk — it exists only as an open task description (task 813) — so item 1's cross-reference must point at the concept by name/location convention, not at specific prose that does not yet exist; recommend pointing at `rules/plan-compliance.md`'s "Statement Fidelity" section, which is the file task 813's own siting names as item 1's landing spot.
- **Mechanical-check decision: no sound discrimination exists; build nothing.** `plan-file-scope-harvest.sh`'s own grammar treats every `Files to modify` entry's trailing annotation as unstructured free text, and the live plan corpus demonstrates no consistent vocabulary across "new", "created", "new file", "new module", and "amendment" — a keyword heuristic would both under-fire (an author who writes "fix", "repair", or "retract" instead of "correct"/"amend"/"retire") and over-fire (an "update" annotation is used for both newly-created and pre-existing targets in the corpus), and flagging every not-yet-existing path is explicitly the rejected worse-than-nothing alternative. The prose-only outcome the dispatch names as acceptable is the correct outcome here.
- `planner-agent.md` already has a precedent pattern for a short, pointer-only, generation-time obligation (item 9, "Declare a Whole-Tree-Claim Phase Honestly" — a numbered MUST/MUST NOT item that states the obligation in one or two sentences and points at `plan-format.md` for the full mechanism). Both item 1(a) and item 2(a)/(b) are generation-time obligations in the same sense (the planner-agent is the one who writes the Scope Hypothesis/task list pair and the one who names a correction target), so recommend adding two short pointer items there in this same style, rather than a longer restatement.

## Context & Scope

This record closes two plan-authoring truthfulness gaps in `context/formats/plan-format.md`:

1. A phase's task list may contradict that same phase's own `**Scope Hypothesis**:` exclusion.
2. A plan may name an artifact as a CORRECT/AMEND/RETIRE target without confirming it exists.

Both are prose-only additions to an existing file (no script, hook, or format-field change); the dispatch also asks research to investigate and decide whether a mechanical check can soundly discriminate a correction-target path from a creation-target path in the existing `Files to modify` field, given that no new plan-format field may be added to make such a check possible. Research scope was: (a) confirm siting and resolve the source store, (b) read the exact sections the new prose must sit beside/connect to, (c) confirm the sibling lean-extension cross-reference target, and (d) settle the mechanical-check question with corpus evidence rather than assumption.

## Findings

### Source store and current file state

- `.claude-extensions.json`'s `core` entry's `source_dir` is `/home/benjamin/.config/nvim/agent-system/extensions/core`; `context/formats/plan-format.md`, `agents/planner-agent.md`, and `index-entries.json` all exist under it at the expected paths.
- `wc -l` on the source-store file reports **1020** lines, not the 784 the dispatch addendum's "reading above" cites — two unrelated tasks (`task 464`, `task 493`, visible in `git log -- context/formats/plan-format.md`) added the "Cross-phase ceiling consistency obligation" and related enforcement/measurement subsections since that reading was taken. `index-entries.json`'s existing entry for this path already carries `"line_count": 1020`, matching the file as it stands *before* this record's own edits — so there is no live drift today, but the figure must be re-measured and reconciled after this record's edits land (acceptance criterion 7), not copied forward.

### Item 1's siting

- "Counts-are-hypotheses obligation" (plan-format.md, current lines 471-498) states the general rule that any count/file-list/scope estimate is a hypothesis requiring implementation-time confirmation, and explicitly frames `**Scope Hypothesis**:` as a claim about *future implementation-time state* — it says nothing about internal consistency with the same phase's own task list. This is exactly the gap the dispatch names in item 1(a): the existing obligation is the right vocabulary for a claim about the world, and a new, adjacent subsection is needed for a claim that contradicts the plan's own other instructions.
- "Reasoned Exclusions" (lines 798-836) is the existing mechanism for recording a decided, evidenced deviation inside a phase, including an explicit "Relationship to Scope Hypothesis" paragraph (lines 830-835) stating that a reasoned exclusion is "structurally the closing act of a Scope Hypothesis... discovered mid-phase at implement time, with implement-time entries confirming or superseding any plan-time hypothesis." Item 1(b)'s implementer rule (preserve the task list's requirement, record the deviation in place, propagate the consequence) is a second mode alongside the one already described there — the existing text covers an overcount discovered and resolved by narrowing scope; item 1(b)'s case is an internal *contradiction* resolved by preserving what the phase exists to produce. The new text should sit adjacent to both, with each existing section gaining nothing but a short forward/backward pointer rather than restated content.

### Sibling cross-reference target (lean extension)

- The sibling record's name in the dispatch (`lean_plan_challenge_block_authoring_contract`) does not correspond to any task directory or landed file on disk today; the matching open task is **task 813**, "State the precedence and snapshot-prerequisite rules for a lean plan's pinned Challenge block" (`specs/TODO.md`), status `[NOT STARTED]`, dependent on task 785 (currently `[IMPLEMENTING]`, a concurrent sibling in this same orchestration cycle per the dispatch's Territory block).
- Task 813's own siting names `rules/plan-compliance.md`'s existing "Statement Fidelity" section (lean extension) as item 1's intended landing spot, and states the precedence rule in the same terms the dispatch's own summary gives: the pinned Challenge block wins over a contradicting Verification criterion "because it is immutable by design after plan time."
- **Consequence for this record**: the precedence prose itself is not yet written anywhere — this record's cross-reference cannot quote or link to live prose that does not exist. The correct move is to point at the *location* (`rules/plan-compliance.md`'s "Statement Fidelity" section in the lean extension) and state in one sentence why the immutability argument does not transfer here (neither a Scope Hypothesis nor a task list is pinned/immutable), per acceptance criterion (2) — not to wait on task 813 landing first. No dependency edge is needed for this: the cross-reference is a prose pointer to a named location, not a parse-time or build-time link, and the dispatch's existing dependency note already covers the one real file-territory overlap (the other `plan-format.md` record) without naming task 813.

### Item 2's siting

- "Files to modify"'s "Consumers of this field" subsection (lines 134-170) is the structural home: it already documents the field's grammar (one `- \`path\`` entry per line, optional free-text annotation) and its four consumers. Item 2(a)/(b) belongs immediately after this subsection (or as a new subsection titled for the correction-vs-creation distinction), since it is additional authoring guidance about *what the annotation on an entry means*, not a new field or a new consumer.
- The durable record carriers item 2(b) must name are already established and in active use elsewhere in this same originating run: `specs/state.json`'s task description (amended) and a task's own `records/` directory. Both are existing, documented concepts (state-management.md, artifact conventions) — no new carrier mechanism needs inventing, only naming them as the sanctioned substitute for a correction task against a sidecar whose existence is dispatch-contingent.

### Mechanical-check investigation (item 2's "investigate and report a decision" clause)

`plan-file-scope-harvest.sh`'s own header comment (read in full) states the governing constraints directly:

- The script "deliberately does NOT distinguish 'no Files to modify header anywhere in a phase' from 'header present, zero paths'" and treats every backtick-delimited entry as an opaque string with no structural field for intent (create vs. correct vs. retire).
- It explicitly documents, as a design decision already made and defended: "Never stats, resolves, or filesystem-validates a harvested path... a path a plan names for a file it will CREATE is exactly what must be harvested, not filtered out." This is the harvester's own statement of the exact failure mode the dispatch warns against (flagging every not-yet-existing path), already rejected once at this layer.
- The only structured signal available per entry is the free-text annotation after the closing backtick, which `plan-format.md` describes as "optionally followed by ` - {what changes}` free text" with no governing vocabulary.

A grep sweep of the live `specs/*/plans/*.md` corpus for annotations on `Files to modify`-style entries found no consistent vocabulary: observed forms for a creation target include "new certificate type...", "new lemmas", "new import...", "new module: header, imports...", "created", "created; defines...", and "new file, lifted from...". One real entry uses "amendment paragraphs" for a target that is a pre-existing, unambiguously-already-existing file being modified in place — so the one word that might seem a natural signal for "this is not a creation" ("amendment") is already in live, correct use for exactly the correction-like case item 2 is about, but nothing in the corpus establishes it, or any other word, as the *required* vocabulary a lint could key on. Authors use whichever word reads naturally in context; a lint keyed on a finite keyword set (e.g. "correct", "amend", "retire") would produce false negatives against every author who instead writes "fix", "repair", "retract", or "update" for a correction target, and false positives/negatives in the other direction are equally easy to construct given "update" is used ambiguously for both newly-created artifacts (e.g. "update the generated inventory downstream of this new module") and genuinely pre-existing ones.

**Decision: no sound correction-target-versus-creation-target discrimination is buildable from the current `Files to modify` grammar, and none should be built.** The reasons, in order of weight:
1. The field carries no structured intent signal — only an optional, free-form annotation — and the live corpus demonstrates no consistent vocabulary a keyword lint could key on without high false-positive and false-negative rates in both directions.
2. The harvester's own documented design principle ("never filesystem-validates a harvested path... a creation-target path is exactly what must be harvested, not filtered out") is already the correct behavior for the overwhelmingly common case (a plan naming files it will create); building a check that flags not-yet-existing paths as suspect would regress this and fire on every legitimate new-file phase, which the dispatch already names as worse than no check.
3. The dispatch explicitly places a new plan-format field (which could carry the needed structured signal honestly) out of scope for this record.

The prose-only outcome is therefore the complete, correct deliverable for item 2's mechanical-check sub-question; nothing beyond stating this finding and its reasoning (in the completion summary, per the dispatch's own instruction) should be built.

### `planner-agent.md` pointer

- `planner-agent.md` already contains a directly analogous precedent: item 9 under its phase-authoring checklist, "Declare a Whole-Tree-Claim Phase Honestly" — a short numbered item stating a generation-time obligation in one to two sentences, with a `MUST NOT` bullet, pointing at `plan-format.md`'s corresponding subsection for the full mechanism rather than restating it.
- Both item 1(a) (check the phase's task list against its own Scope Hypothesis exclusions before writing the phase) and item 2(a)/(b) (confirm an existing-artifact correction target actually exists; never make a phase's goal turn on a dispatch-created sidecar) are obligations that bind at the moment the planner-agent is generating the phase — exactly the class of obligation item 9 already represents. Recommend two short pointer items in this same style (one for item 1(a), one for item 2(a)/(b)), each one or two sentences plus a pointer to the corresponding `plan-format.md` subsection, rather than a single blended item or no pointer at all. This discharges the dispatch's own conditional ("in scope for a short pointer if, and only if, the provisions need to reach the author at generation time") affirmatively for both items, since both are specifically generation-time, author-side checks rather than review-time or implementation-time concerns.

## Recommendations

1. In `context/formats/plan-format.md`, add a new subsection immediately after "Counts-are-hypotheses obligation" (before "Cross-phase ceiling consistency obligation") stating item 1(a) and item 1(b) as two separately checkable conditions, each with its own short paragraph, per acceptance criterion (1). Cross-reference "Reasoned Exclusions" for the record-the-deviation half of 1(b) with a one-sentence forward pointer; add a one-sentence backward pointer from "Reasoned Exclusions"'s existing "Relationship to Scope Hypothesis" paragraph.
2. In the same new subsection (or an adjacent short paragraph), state explicitly why the pinned-block precedence reasoning does not transfer (no immutable surface exists for either a Scope Hypothesis or a task list), with a pointer to the lean extension's `rules/plan-compliance.md` "Statement Fidelity" section as the location of the sibling rule — phrased as a pointer to a location and a governing concept, not as a citation of prose that exists yet, since it does not.
3. In `context/formats/plan-format.md`'s "Files to modify" "Consumers of this field" area, add item 2(a) (general confirm-before-naming-as-correction-target rule) and item 2(b) (the stronger sidecar prohibition, naming `specs/state.json`'s task description and a task's own `records/` directory as the sanctioned carriers) as their own short subsection.
4. State the mechanical-check decision (no sound discrimination; nothing built, with the reasoning above) in the completion summary of whichever phase executes this record, not as a sentence inside `plan-format.md` itself — the format document should carry the authoring rule, not a narration of why a linter was not built.
5. In `agents/planner-agent.md`, add two short pointer items to the phase-authoring checklist (alongside item 9's existing style): one for item 1(a)'s check, one for item 2(a)/(b)'s confirm-and-sidecar-prohibition, each pointing at the corresponding new `plan-format.md` subsection rather than restating it.
6. After editing, re-run `wc -l` on the landed `plan-format.md` and update `index-entries.json`'s `line_count` to match exactly (do not reuse the pre-edit 1020 figure), then redeploy via `bash .claude/scripts/deploy-headless.sh` and confirm `RESULT=landed_verify_clean`.

## Decisions

- **Mechanical check**: decided against building one. No new plan-format field (out of scope), no sound keyword/annotation-based discrimination exists given the corpus's inconsistent free-text vocabulary, and the harvester's own documented design already correctly treats every not-yet-existing path as a legitimate creation target. Deliver the prose provisions only.
- **Sibling cross-reference**: point at the lean extension's `rules/plan-compliance.md` "Statement Fidelity" section by name/location, stating the non-transfer reasoning inline, rather than waiting on or depending on the (not yet landed) sibling task.
- **`planner-agent.md` pointer**: add short pointer items for both item 1(a) and item 2(a)/(b), following the existing item-9 precedent pattern, rather than omitting a planner-agent-side pointer or writing a longer restatement there.

## Risks & Mitigations

- **Risk**: `plan-format.md`'s line count will have moved again between this report and the implementation phase (it already moved once, from 784 to 1020, between dispatch authoring and this report). **Mitigation**: the recommendation above already directs re-measuring `wc -l` on the landed file rather than reusing any previously recorded figure.
- **Risk**: citing task 813 by number anywhere in the landed prose would violate `no-task-references-in-deliverables.md` and `no-record-versioning-in-deliverables.md` (task 813 is itself an open, unlanded record, so citing it would also assert a dependency that does not formally exist). **Mitigation**: the recommended cross-reference names only the durable file/section location (`rules/plan-compliance.md`'s "Statement Fidelity" section in the lean extension), never the task number.
- **Risk**: the new `planner-agent.md` pointer items could be written as a full restatement rather than a pointer, inflating an agent-prompt file that should stay terse. **Mitigation**: follow item 9's existing one-to-two-sentence-plus-pointer shape exactly; do not duplicate the `plan-format.md` subsection's content.

## Context Extension Recommendations

None. Both items extend a file (`context/formats/plan-format.md`) that already exists and is already reachable via the existing `index-entries.json` entry; no new context file or topic gap was identified during this research.

## Appendix

- Search/read commands used: `wc -l`, `grep -n` sweeps of `plan-format.md` (section/field locations), `planner-agent.md` (Scope Hypothesis / Files to modify / correction-verb mentions), `plan-file-scope-harvest.sh`'s header comment (grammar and design-principle statements), `index-entries.json`'s existing entry for `formats/plan-format.md`, `specs/TODO.md` (locating tasks 813 and 824, and the originating task 827's own state.json description), `git log --oneline -- context/formats/plan-format.md` (explaining the 784-vs-1020 discrepancy), and a corpus grep over `specs/*/plans/*.md` for `Files to modify`-style annotation verbs.
- Files read in full or in relevant part: `context/formats/plan-format.md` (lines 1-170, 460-610, 790-940), `context/project/lean4/domain/challenge-snapshot.md` (lean extension, for Challenge-block background), `agents/planner-agent.md` (lines 220-270), `plan-file-scope-harvest.sh` (header comment), `specs/TODO.md` (tasks 813, 824, 839 vicinity), `specs/state.json` (task 827's own entry).
