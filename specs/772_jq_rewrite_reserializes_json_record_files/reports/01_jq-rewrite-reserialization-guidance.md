# Research Report: Task #772

**Task**: 772 - planned jq rewrites re-serialize formatting-sensitive JSON record files
**Started**: 2026-11-07T00:00:00Z
**Completed**: 2026-11-07T00:00:00Z
**Effort**: small (guidance-only, no helper script, no code change)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `agent-system/extensions/core/context/patterns/jq-escaping-workarounds.md`,
  `agent-system/extensions/core/merge-sources/claudemd.md`, `agent-system/extensions/core/index-entries.json`,
  `agent-system/extensions/core/scripts/state-write.sh`, `specs/state.json` (active task file_scope survey)
- Dispatch file: `specs/772_jq_rewrite_reserializes_json_record_files/.dispatch/2.md`
**Artifacts**:
- This report
**Standards**: report-format.md, subagent-return.md, source-store-deploy-boundary.md,
no-task-references-in-deliverables.md, no-record-versioning-in-deliverables.md

## Executive Summary

- **Siting decision: candidate (a).** Extend `context/patterns/jq-escaping-workarounds.md` with
  a new section covering jq's unconditional whole-file re-serialization, widen that file's own
  framing so the title no longer undersells its contents, and add one line to
  `merge-sources/claudemd.md`'s existing "jq Command Safety" section. This file already has 27
  referrers across `core` and six other extensions and is the documented "full documentation"
  target from the deployed `CLAUDE.md`; a sibling file (candidate b) would start with zero
  referrers and require wiring work this record would then also have to carry.
- **Both audiences are reached by this siting** without the reader needing to know the term
  "re-serialization" in advance: the plan-author audience is reached because the deployed
  `CLAUDE.md`'s "jq Command Safety" section is auto-injected into every agent session (visible in
  this very dispatch's context) and will carry the one added line; the implementer audience is
  reached because any of the 27 existing referrers that currently point at this file for the
  escaping bug will land the reader on the same file, where the widened framing makes the second,
  unrelated section impossible to miss.
- **The copyable recipe** (HEAD-bytes extraction, text-level edit, jq-computed comparison value,
  canonicalized-diff assertion, move-into-place) is specified below in full, ready to drop into
  the new section verbatim.
- **No helper script** — confirmed by re-deriving the filing-time reasoning against the current
  codebase; `scripts/state-write.sh`'s concurrency rationale genuinely does not transfer to
  single-implementer record-file edits.
- **A real `index-entries.json` file-scope overlap exists** with another active task (827), but
  it is the coarse-registration-file case the batching guardrail's narrowness qualifier
  explicitly exempts from mandatory sequencing, not a narrow overlap — no dependency edge is
  recommended (see Decisions).
- **`planner-agent.md` does not need a line added.** The plan-author audience is already reached
  through the `CLAUDE.md` jq-section line, since every agent session (plan-authoring dispatches
  included) receives the deployed `CLAUDE.md` as auto-injected context — confirmed empirically:
  this very research dispatch's own system context carries that file's rendered content. No
  dependency edge against task 827 (which claims `planner-agent.md`) is needed.

## Context & Scope

The task asks for agent-system guidance that stops a whole-file `jq` rewrite from being used as
the edit mechanism against a JSON record file whose on-disk layout is hand-maintained (mixed
compact/expanded records, a deliberate key order). The triggering incident is fully resolved and
out of scope for any further repair; the deliverable is guidance prose plus index wiring in the
agent-system source store, landed through a redeploy. Scope explicitly excludes a formatting-
preserving helper script (decided at filing time; re-examined here, not re-litigated) and
excludes editing `planner-agent.md` directly (claimed by another active task; research decides
whether that exclusion is actually necessary).

## Findings

### Codebase Patterns

**The jq pitfalls hub, measured.** `jq-escaping-workarounds.md` is referenced by 27 files across
8 extensions (`core`: 15 referrers including `index-entries.json`, `merge-sources/claudemd.md`,
`commands/todo.md`, `scripts/lint/lint-state-writer-boundary.sh`, several `context/patterns/*.md`
and `context/standards/*.md` files, and three skills; plus `cslib`, `founder`, `epidemiology`,
`present` extensions contributing the remaining 12). The deployed `CLAUDE.md`'s own "jq Command
Safety" section (rendered at `merge-sources/claudemd.md:247-261`) names it explicitly as "Full
documentation". This confirms the dispatch's "roughly eighteen" as an undercount, not an
overstatement, and reinforces that candidate (a) is free discovery while candidate (b) starts
from zero.

**Current file shape.** The file is 285 lines, titled "# jq Escaping Workarounds", and its entire
content addresses Claude Code Issue #1132 (the `!=`-escaping / pipe-injection bug), not jq's
re-serialization behavior. Its `index-entries.json` entry (`core/index-entries.json`, entry for
`patterns/jq-escaping-workarounds.md`) carries `summary: "Workarounds for jq escaping issues"`,
`line_count: 285` (currently in sync with the file), and `keywords: ["patterns", "jq",
"escaping"]` — none of which mention formatting, record files, or re-serialization, so a keyword-
driven lookup for this new failure class would currently miss the file entirely even though a
human reader who opens it (via a referrer link) would not.

**The `state-write.sh` contrast, confirmed from source.** `scripts/state-write.sh`'s own header
states its rationale directly: nine prior scripts plus two inline write blocks each hand-rolled
`jq ... > tmp && mv tmp state.json`, only two of which took the `specs/.scope-lock` mutex, and
both of those failed open on timeout. The wrapper exists to close two failure channels specific
to **many concurrent automated writers against one hot file** — a fail-closed mutex plus a
private `mktemp` staging path. Neither channel is present for a record file edited by a single
implementer inside one planned step: there is no concurrent writer population and no shared hot
file. The dispatch's filing-time reasoning holds up against the actual script, not just against
its description.

**A genuine `index-entries.json` overlap, checked and classified.** The dispatch asked to
re-verify at admission time that no other active record touches `index-entries.json` — that
check surfaces one: task 827 ("Require a plan phase to agree with its own Scope Hypothesis...")
declares `file_scope: ["agent-system/extensions/core/agents/planner-agent.md",
"agent-system/extensions/core/context/formats/plan-format.md",
"agent-system/extensions/core/index-entries.json"]`. Task 827 is not among this cycle's
`concurrent_siblings` (743, 785, 774), so there is no same-cycle git-collision risk today, but
the two tasks' `file_scope` arrays do share `index-entries.json` as declared territory. Per
`batch-orchestration-guardrails.md`'s dominance rule, a shared *narrow* file overlap is mandatory
grounds for a serializing dependency edge — but the rule's own "narrowness qualifier" explicitly
exempts "a registration manifest... a shared README... or any entry that would independently
trip `validate-state.sh` Check 8's coarse-`file_scope` WARN", citing exactly this pattern (the
`manifest.json` precedent: 4 open tasks sharing one registration file without being treated as
one mandatory group). `index-entries.json` is the same shape of file — a registration array many
unrelated tasks append distinct entries/fields to — and 772's and 827's edits are to disjoint
entries within it (772: the `jq-escaping-workarounds.md` entry's `keywords`/`line_count`/
`summary`; 827: plan-format's index wiring). This is the coarse case, not the narrow case; no
dependency edge is warranted.

**`planner-agent.md` exclusion re-examined.** The dispatch names this file as a tempting but
deliberately excluded edit target (claimed by task 827) and asks research to decide whether a
matching line is genuinely necessary there. It is not: the deployed `CLAUDE.md` — which carries
the "jq Command Safety" section this record will extend by one line — is auto-injected into
every agent session's system context regardless of agent type, confirmed directly: this research
dispatch's own system-reminder blocks include the full rendered `CLAUDE.md`/`.claude/CLAUDE.md`
content. A plan-authoring dispatch (`planner-agent`) receives the identical injection. The
one-line addition to `merge-sources/claudemd.md` therefore already reaches the plan-author
audience without any edit to `planner-agent.md`, so the exclusion stands and no dependency edge
against task 827 is needed on this account either.

### External Resources

Not applicable — this is a codebase-convention question with no external jq documentation gap;
jq's lack of a formatting-preserving/idempotent-byte-layout mode is a well-known, uncontested
property of the tool (it parses to a value and serializes that value in its own canonical style),
not something requiring a citation to establish.

## Decisions

1. **Siting: candidate (a).** Add a new section to `context/patterns/jq-escaping-workarounds.md`
   (source store: `/home/benjamin/.config/nvim/agent-system/extensions/core/context/patterns/jq-escaping-workarounds.md`)
   covering the re-serialization failure class, and widen the file's opening framing so a reader
   is not surprised to find a second, unrelated jq hazard inside a file titled "jq Escaping
   Workarounds". Candidate (b) is rejected: it would start with zero referrers and would require
   this same record to also carry the referrer-wiring and `index-entries.json`-creation work the
   dispatch flags as mandatory if (b) is chosen — strictly more work for strictly worse day-one
   discoverability than extending the existing hub.
2. **One-line addition to `merge-sources/claudemd.md`'s "jq Command Safety" section** (same
   source-store root, `merge-sources/claudemd.md:247-261`), pointing at the new section — this is
   the cheapest path to the plan-author audience since every session already reads this merged
   section.
3. **No helper script.** Confirmed against `state-write.sh`'s actual source: its concurrency
   rationale does not transfer. The reopen condition (repeated retyping of the assertion recipe
   for one frequently-edited record file) is carried forward into the new guidance section itself
   so a future reader can recognize when to revisit this.
4. **No edit to `planner-agent.md`, no dependency edge against task 827 on that account** — the
   plan-author audience is already reached via the `CLAUDE.md` injection path (item 2).
5. **No dependency edge against task 827 for the shared `index-entries.json` file_scope entry** —
   classified as the coarse-registration-file exemption under the batching guardrail's narrowness
   qualifier (both tasks edit disjoint entries/fields within the same registration array; the
   `manifest.json` precedent in `batch-orchestration-guardrails.md` is directly analogous).
6. **Recipe content and trigger-condition wording** for the new section (see Recommendations) —
   fixed here so the plan phase has exact text to place rather than a description to re-derive.

## Recommendations

**New section to add to `context/patterns/jq-escaping-workarounds.md`** (exact content for the
plan phase to place, after widening the file's opening framing to mention both failure classes it
now documents):

- **Section heading** naming the hazard directly (e.g. "jq Rewrites Reflow Unrelated JSON
  Formatting"), so a reader scrolling the file — including one who arrived via a referrer with no
  idea the term "re-serialization" exists — lands on it without needing the term in advance.
- **Trigger condition, stated as something a reader can check before acting**: the target file is
  committed with a layout a bare `jq . file` round-trip would NOT byte-reproduce — hand-maintained
  per-record compaction (some records one-line, others multi-line), a deliberately preserved key
  order, or any other human-maintained layout — AND the edit is meant to touch only a few fields
  rather than intentionally rewrite the whole file. Name at least one concrete file shape meeting
  it: a dependency/record array where most entries are serialized compactly on one line but one or
  more have been hand-expanded for readability (the exact shape of the originating incident).
- **Why it bites**: jq parses its input to a value and prints that value back out in jq's own
  fixed style; there is no flag that makes jq preserve input formatting. A whole-file pipe through
  jq re-serializes every record's layout, including records the filter never touches — not just
  the one a narrowly-scoped filter targets.
- **The recipe, copyable verbatim**:
  ```bash
  path="<path/to/record-file.json>"

  # 1. Starting bytes: the committed HEAD version, not the possibly-already-edited working copy.
  git show HEAD:"$path" > /tmp/head-bytes.json

  # 2. Text-level edit: apply the intended field changes as literal text edits (sed, or an
  #    editor tool's exact-string replace) against a copy of the HEAD bytes, touching only the
  #    characters that need to change.
  cp /tmp/head-bytes.json /tmp/text-edited.json
  # ... apply the text-level edit to /tmp/text-edited.json here ...

  # 3. Independently compute the intended result with jq, from the SAME starting bytes.
  jq '<filter expressing the same intended change>' /tmp/head-bytes.json > /tmp/jq-output.json

  # 4. Assert the two agree as JSON under canonicalization. This must be empty.
  diff <(jq -S . /tmp/text-edited.json) <(jq -S . /tmp/jq-output.json)

  # 5. Only once step 4 is empty, move the text-edited version into place.
  mv /tmp/text-edited.json "$path"
  ```
- **The assertion is the load-bearing half**, stated explicitly: it buys back the one thing a bare
  text edit gives up relative to jq — the guarantee that the result is well-formed JSON carrying
  exactly the intended values (a stray trailing comma or a broken escape in a hand edit would
  otherwise pass silently). Guidance that omits step 4 is guidance to make the same class of
  mistake with a text editor instead of jq, not a fix.
- **The `state-write.sh` relation, stated so a reader does not go looking for an equivalent
  wrapper**: `specs/state.json` has a dedicated mutex-guarded writer (`scripts/state-write.sh`)
  built for a different problem — many concurrent automated callers racing on one hot file —
  and jq remains the correct, unchanged tool for every call that goes through it. Record files
  edited by a single implementer inside one planned step have no such wrapper, and that absence
  is deliberate: a wrapper would buy no concurrency safety there (see Decisions item 3) while
  adding an interface to learn. If some record file turns out to be edited often enough that this
  five-step recipe is being retyped repeatedly, that is the signal to revisit the script question
  — not before.
- **Explicit non-generalization**: this is not "jq is unsafe for JSON edits." jq remains correct
  for `specs/state.json` (via its wrapper), for computing the intended value inside the recipe
  itself (step 3 above), and for any file whose byte-level layout nobody depends on.

**One-line addition to `merge-sources/claudemd.md`'s existing "jq Command Safety" section**
(immediately after the existing "Full documentation" line, same section, no structural change):
a single sentence stating that piping an entire JSON file through jq also reflows every record's
formatting regardless of which fields a filter targets, and pointing at the new section in the
same referenced file for the trigger condition and the copyable recipe.

**`index-entries.json` entry update**, bringing the existing entry for
`patterns/jq-escaping-workarounds.md` back into agreement with the extended file per Acceptance
criterion 5: recompute `line_count` from the file's new total line count; widen `keywords` to
include terms an implementer might search by (e.g. add `"reserialization"`, `"record-files"`,
`"formatting"` alongside the existing `"patterns"`, `"jq"`, `"escaping"`); widen `summary` to
reflect both failure classes the file now documents (e.g. "jq escaping bug workarounds and
formatting-preservation guidance for record-file edits") so the summary does not undersell the
file the way the bare title currently would without the intro-paragraph widening.

**Verification path for the plan phase**: after the source-store edits, run
`bash .claude/scripts/deploy-headless.sh` (bounded wait per `external-process-wait.md` Rule 1:
`timeout 540 bash .claude/scripts/deploy-headless.sh`) and confirm `RESULT=landed_verify_clean`,
per Acceptance criterion 6.

## Risks & Mitigations

- **Risk**: widening the file's framing reads as apologizing for a misleading title rather than
  stating current structure, which could brush against record-versioning phrasing norms.
  **Mitigation**: state the file's current two-part structure plainly ("this file documents two
  independent jq hazards: ... and ...") without any "originally", "previously", or "now covers"
  framing — a structural description, not a history narration.
- **Risk**: a future task adds a brand-new context file in the same orchestrate cycle as this
  one's eventual implementation dispatch, both appending to `index-entries.json` concurrently.
  **Mitigation**: this record's own implementation dispatch should re-run the
  `concurrent_siblings` check at its own admission time (the check is cycle-scoped, not a
  standing fact this report can freeze); nothing in this research changes that procedure.
- **Risk**: the keyword/summary widening recommended above is not itself gated by Acceptance
  criterion 5's literal text (which names only `line_count`/`keywords`), so an implementer could
  skip widening `summary`. **Mitigation**: flagged explicitly above as a hygiene recommendation
  alongside the two gated fields, not left implicit.

## Context Extension Recommendations

None beyond the edit this task itself delivers — the gap this task closes (no documented
trigger/recipe for formatting-sensitive JSON record-file edits) is the entire scope of the
deliverable, not a side discovery requiring a separate context file.

## Appendix

**Search/inspection steps performed**:
- Resolved `core`'s `source_dir` from `.claude-extensions.json` (`/home/benjamin/.config/nvim/agent-system/extensions/core`).
- `grep -rl "jq-escaping-workarounds"` across `agent-system/extensions/` (27 referrers across 8 extensions).
- Read `merge-sources/claudemd.md`'s "jq Command Safety" section (lines 247-261) and `context/patterns/jq-escaping-workarounds.md` in full (285 lines).
- Read `core/index-entries.json`'s entry for `patterns/jq-escaping-workarounds.md` (summary, line_count, keywords, load_when).
- Read `scripts/state-write.sh`'s header to verify the concurrency rationale against the actual script rather than only the dispatch's description.
- Queried `specs/state.json` for any active task's `file_scope` overlapping `jq-escaping-workarounds.md`, `index-entries.json`, or `merge-sources/claudemd.md`; found task 827's overlap on `index-entries.json` and classified it against `batch-orchestration-guardrails.md`'s narrowness qualifier.
- Confirmed `planner-agent.md`'s exclusion needs no dependency edge by observing that the deployed `CLAUDE.md` (carrying the section this task extends) is auto-injected into every agent session's context, this dispatch's own included.

**References**:
- `agent-system/extensions/core/context/patterns/jq-escaping-workarounds.md`
- `agent-system/extensions/core/merge-sources/claudemd.md`
- `agent-system/extensions/core/index-entries.json`
- `agent-system/extensions/core/scripts/state-write.sh`
- `.claude/context/patterns/batch-orchestration-guardrails.md` (dominance rule, narrowness qualifier)
- `.claude/rules/source-store-deploy-boundary.md`
