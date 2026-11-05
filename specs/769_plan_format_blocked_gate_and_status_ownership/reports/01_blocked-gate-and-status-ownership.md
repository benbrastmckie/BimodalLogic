# Research Report: Task #769

**Task**: 769 - plan-format: blocked decision gates and plan-level Status ownership
**Started**: 2026-11-04T21:58:00Z
**Completed**: 2026-11-04T22:40:00Z
**Effort**: 1-1.5 hours (research), 1-2 hours (implementation estimate)
**Dependencies**: None
**Sources/Inputs**: Codebase (`context/formats/plan-format.md`, `context/contracts/plan-status-ownership.md`, `context/standards/status-markers.md`, `agents/planner-agent.md`), archived plan precedent (`specs/archive/760_ladder_model_cell_stabilization_lemma/plans/01_ladder-cell-refutation-probe.md`, `specs/archive/006_canonical_taskframe_completeness/plans/05_torsor-construction-plan.md`, `specs/archive/008_genuine_truth_at_completeness/plans/03_revised-completeness-plan.md`), issue-log entries (`specs/archive/760_ladder_model_cell_stabilization_lemma/issues.jsonl`)
**Artifacts**: - this report (`specs/769_plan_format_blocked_gate_and_status_ownership/reports/01_blocked-gate-and-status-ownership.md`)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Both gaps are real and independently confirmed against the originating precedent
  (`specs/archive/760_ladder_model_cell_stabilization_lemma`'s plan): `plan-format.md`'s
  "Decision gates and contingency branches" subsection has no provision for a decision gate that
  is already `[BLOCKED]` before any phase in the plan executes, and its "Plan-level vs.
  phase-level markers" subsection documents the plan-level `- **Status**:` field's vocabulary
  without ever stating who owns writing it.
- The precedent plan's own resolution is directly reusable as the shape of Provision 1: place
  the pre-decided `[BLOCKED]` gate in wave 1 with `Depends on: none` beside the first executable
  phase, and have the final phase's `full`-tier verification re-observe the gate's own measurement
  by name rather than depend on it in the dependency graph.
- `context/contracts/plan-status-ownership.md` already names `plan-format.md`'s "Plan-level vs.
  phase-level markers" subsection as the authority for the ownership split, but that subsection
  currently only describes the two vocabularies, not the ownership/write-authority split itself —
  Provision 2 closes exactly that gap, at exactly that location, with a load-bearing sanctioned
  alternative (mark the phase heading, let postflight stamp the plan-level field).
- `agents/planner-agent.md`'s plan-authoring template contains no instruction that invites writing
  a checklist item which sets the plan-level `- **Status**:` field; the originating defect was
  freeform phase-body prose a planner wrote for one task, not a template default. Recommendation:
  `plan-format.md` alone is sufficient; no planner-agent.md edit is needed (see Decisions).
- Both target files (`context/formats/plan-format.md`, `agents/planner-agent.md`) are
  byte-identical between this repo's deployed `.claude/` tree and the source store at
  `/home/benjamin/.config/nvim/agent-system/extensions/core`, despite the `core` extension being
  flagged stale overall — the staleness does not affect either edit target.

## Context & Scope

Researched what prose to add to `context/formats/plan-format.md` to close two gaps surfaced
during the ladder-model orchestration (the originating issue-log entries, both class
"standard/plan-contract ambiguity", both `resolution: worked_around`, both hinted channel
`agent_system`):

1. A pre-decided `[BLOCKED]` decision-gate phase has no stated relationship to the final-phase
   transitive-dependency rule.
2. Plan authors can write a phase checklist item instructing the implementer to hand-set the
   plan-level `- **Status**:` field, which the implementer's own contract correctly refuses to
   execute — but the instruction should never have been writable.

Scope is documentation-only: no change to the closed six-value phase-heading enum, the
`### Phase N: {name} [STATUS]` heading contract, or any mechanical consumer
(`update-phase-status.sh`, `update-plan-status.sh`, `update-task-status.sh --phase-check`). Both
edit targets resolve under the `core` extension's source store
(`/home/benjamin/.config/nvim/agent-system/extensions/core`), not under this repo's deployed
`.claude/**`, per `.claude/rules/source-store-deploy-boundary.md`.

## Findings

### Codebase Patterns

**The final-phase rule, verbatim** (`context/formats/plan-format.md:304-310`):

> "a plan's final phase is its highest-numbered phase, which MUST be a terminal node of the
> dependency graph (no other phase depends on it) and MUST depend, directly or transitively, on
> every other phase in the plan. The transitivity requirement is what makes that phase's `full`
> gate meaningful — it must observe all of the task's work..."

**The existing decision-gate subsection** (`plan-format.md:690-733`, "Decision gates and
contingency branches") covers only the case where a gate phase *executes inside the plan*,
produces a measurement, and the plan's contingency branch is taken afterward — the bypassed
phases close `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record. This is a
distinct shape from a gate that is *already* `[BLOCKED]` when the plan is authored (the
measurement already failed, at research time, before any phase in the plan runs) — the
subsection says nothing about that case, which is exactly Provision 1's gap.

**The precedent, confirmed by direct read**
(`specs/archive/760_ladder_model_cell_stabilization_lemma/plans/01_ladder-cell-refutation-probe.md`):
a 4-phase plan with Phase 1 heading `[BLOCKED]` from authoring, `Depends on: none`,
`Verification Tier: prose`, 0 hours timing — placed in wave 1 beside Phase 2 (also
`Depends on: none`). The wave table and prose state explicitly: "Phase 1 is a pre-decided
decision gate whose measurement ... was taken at research time and is re-taken by Phase 2's port
and Phase 4's gate run; it requires no work and is `[BLOCKED]` at plan time, so it is never a
prerequisite of any executable phase... Phase 4 is the final phase: it depends transitively on 2
and 3, and its full-gate verification re-observes Phase 1's measurement through the wired probe."
Phase 4's own `**Verification**:` list includes `lake-build-guard.sh` re-compiling the same
prototype/probe that produced Phase 1's blocking verdict. This is the exact mechanism Provision 1
needs to generalize: exemption from the literal depends-on edge, discharged instead by
re-observation inside the final phase's own verification criteria.

**Two older archived precedents confirm `[BLOCKED]` as a legitimate phase-heading value
predating the wave/dependency machinery**: `specs/archive/006_canonical_taskframe_completeness/plans/05_torsor-construction-plan.md`
(Phase 1 `[BLOCKED]`) and `specs/archive/008_genuine_truth_at_completeness/plans/03_revised-completeness-plan.md`
(Phase 1 `[BLOCKED]`). Neither carries a `Depends on`/wave table (both predate that convention),
so they corroborate only the phase-heading marker's legitimacy, not the dependency-graph
resolution — the 760 plan is the only one of the three with the wave-table mechanics Provision 1
must speak to.

**The ownership gap, confirmed against the existing canonical fragment**
(`context/contracts/plan-status-ownership.md`): this file is explicit that it is "a
generated-copy source" for 16 implementation agents' MUST-NOT bullets, and that `plan-format.md`'s
"Plan-level vs. phase-level markers" subsection is "the authority for the two-vocabulary /
two-owner distinction (that file is not edited by this fragment or by the agents that carry this
bullet — it is pointed at, not restated)". Reading that subsection
(`plan-format.md:741-786`) confirms it currently documents only the two *vocabularies* (plan-level
six-value subset vs. phase-heading six-value enum) and their grain difference — it never states
that `update-plan-status.sh` (via `update-task-status.sh` postflight) is the sole writer, or that
a phase checklist item must not instruct otherwise. The fragment's own prose already asserts
`plan-format.md` carries that authority; it currently does not, which is the exact gap
Provision 2 closes, in the exact subsection the fragment already points at.

**The originating defect's provenance, confirmed by direct read of the issue log**
(`specs/archive/760_ladder_model_cell_stabilization_lemma/issues.jsonl`, entry
`iss_1791711120761_z8uj5G`): "Plan Phase 4's last task instructs the implementer to set the
plan-level `- **Status**:` field to `[BLOCKED]`; the lean-implementation-agent contract (MUST NOT
15, plan-status-ownership) reserves that field for `update-plan-status.sh`... The agent followed
the contract: the field was left untouched and the checklist item annotated as a deviation
(skipped)". The 760 plan file itself (line 486-493, Phase 4's last checklist item) shows the
exact instruction text and the implementer's own
`*(deviation: altered — the plan-level `- **Status**:` field was NOT hand-edited...)*` annotation
— nothing malfunctioned at run time; the defect is that the instruction was authorable.

**`agents/planner-agent.md`'s template carries no matching instruction.** Read in full
(deployed and source-store copies are byte-identical): the "Write plan file" template
(`planner-agent.md:274-367`) is a generic phase skeleton (`**Tasks**: - [ ] {Step 1}`) with no
example or instruction anywhere that tells a planner to set the plan-level `- **Status**:` field
via a checklist item, nor any language about `[BLOCKED]` outcomes at all. The file's Stage 6a
verification (`planner-agent.md:411-440`) checks only that the Status field *exists* with the
correct bracket syntax at authoring time — orthogonal to Provision 2's concern. The file already
instructs the planner, generally, to "Follow plan-format.md structure exactly"
(`planner-agent.md:578`) and always loads `plan-format.md` (`planner-agent.md:24`). The
originating defect was phase-specific freeform prose a planner wrote for one task's final phase,
not a default the template supplies — there is nothing in the template to remove or amend.

**`status-markers.md`'s target-argument/resting-state distinction is a task-level (`state.json`)
mechanism, textually disjoint from the plan-level field.** `status-markers.md:419-433`'s "Target
Arguments vs. Resting States" subsection describes how `update-task-status.sh`'s target argument
resolves to a persisted `state.json`/`TODO.md` status, including the `postflight:pr_ready ->
completed` mapping. Provision 2's wording (below) cites only that `update-plan-status.sh` is
"invoked from `update-task-status.sh` postflight" — the same phrasing
`plan-status-ownership.md` already uses — without describing target-argument resolution itself,
so the two mechanisms stay textually separate and acceptance criterion (3) is satisfied by
construction.

### External Resources

Not applicable — this is a closed, internal documentation-contract gap with no external
dependency.

## Decisions

1. **Provision 1 lands in `plan-format.md`'s "Decision gates and contingency branches"
   subsection**, as a new paragraph immediately after the existing "Do not leave the bypassed
   phases `[NOT STARTED]`" paragraph (currently ending at line 733) and before `## Status Marker
   Requirements`. It is a *new* paragraph, not an edit to the existing worked example, because the
   existing subsection's worked example covers a gate that executes and measures *inside* the
   plan — a distinct shape from a gate that is already `[BLOCKED]` at authoring time.

   Recommended text:

   > **A phase that is already `[BLOCKED]` at plan-authoring time** — a decision gate whose
   > criterion was already measured, and already failed, before any phase in this plan executes
   > — is exempt from the final phase's transitive-dependency requirement's literal depends-on
   > edge: no executable phase can depend on a phase that will never complete, so a plan MUST NOT
   > force that edge merely to satisfy the rule's letter. Place such a gate in wave 1 with
   > `Depends on: none`, alongside the plan's first executable phase (itself also
   > `Depends on: none`). In exchange, the final phase — necessarily `full`-tier — MUST
   > re-observe the blocked gate's own measurement by name inside its own verification criteria
   > (re-running or re-citing the specific artifact, probe, or check whose outcome produced the
   > `[BLOCKED]` verdict), and the Dependency Analysis wave-table note MUST say so explicitly.
   > This satisfies the final phase's observe-all-work rationale through re-observation rather
   > than through a graph edge, while leaving no executable phase deadlocked on work that will
   > never complete. This paragraph covers a gate already `[BLOCKED]` when the plan is written;
   > the worked example above covers a gate that executes and is measured inside this same plan.

   This directly answers acceptance criteria (1) and (4): a reader can determine conformance
   (literal depends-on edge not required; re-observation inside the final phase's own
   verification criteria IS required) and predict placement (wave 1, `Depends on: none`,
   alongside the first executable phase), with no touch to the phase-heading enum or heading
   contract.

2. **Provision 2 lands in `plan-format.md`'s "Plan-level vs. phase-level markers" subsection**,
   as a new paragraph after the four-bullet vocabulary list (ending at line 763) and before
   `#### Trailing annotations on the plan-level Status line` (line 765). This is the exact
   location `context/contracts/plan-status-ownership.md` already asserts is the authority for the
   ownership split, so the new paragraph closes that file's own forward reference rather than
   introducing a new concept.

   Recommended text:

   > **Ownership**: the plan-level `- **Status**:` field is owned by `update-plan-status.sh`,
   > invoked from `update-task-status.sh` postflight — never by a phase's own checklist,
   > verification criteria, or other phase-body prose. No phase's `**Tasks**:` item or
   > `**Verification**:` criterion may instruct a writer to hand-set this field; an implementation
   > agent's contract (`context/contracts/plan-status-ownership.md`) correctly refuses such an
   > instruction, and the refusal is exactly correct — the defect is in a plan authoring the
   > instruction at all, not in the refusal. When a plan is expected to come to rest at
   > `[BLOCKED]` (for example, a plan containing a pre-decided `[BLOCKED]` gate, per the Decision
   > gates and contingency branches subsection above), the sanctioned way to say so is: mark the
   > relevant phase heading `[BLOCKED]` (or close bypassed phases `[COMPLETED WITH EXCLUSIONS]`
   > with their `#### Reasoned Exclusions` record, whichever shape this plan calls for), and let
   > the implementer's return (`.return-meta.json` status, the handoff's `blockers[]`) carry the
   > outcome forward — postflight stamps the plan-level field from that return, never from plan
   > prose.

   This directly answers acceptance criteria (2) and (3): a reader can determine the field is not
   writable from a checklist item and can find the sanctioned alternative (mark the phase
   heading; let postflight stamp the plan-level field from the return value), and the wording
   never touches `status-markers.md`'s target-argument/resting-state mechanism (it cites only
   "invoked from `update-task-status.sh` postflight," identical to the existing canonical
   fragment's own phrasing).

3. **`agents/planner-agent.md` is dropped from the edit set.** Its plan-authoring template
   contains no instruction or example that invites writing a plan-level-Status-setting checklist
   item; the file already instructs following `plan-format.md` structure exactly and always loads
   it. The Provision-2 fix at the `plan-format.md` location governs every plan author
   uniformly (planner-agent and any sibling planning agent alike), which is the right place for a
   rule about what phase-body prose MUST NOT instruct — a cross-cutting constraint on plan
   *content*, not on this one agent's authoring *procedure*. No edit to `planner-agent.md` is
   recommended.

4. **Both provisions stay prose-only.** Neither changes the six-value phase-heading enum, the
   `### Phase N: {name} [STATUS]` heading contract, the plan-level six-value Status vocabulary,
   or any mechanical consumer's parsing logic (`update-phase-status.sh`, `update-plan-status.sh`,
   `update-task-status.sh --phase-check`) — confirmed by inspection of each provision's wording
   above, which cites existing vocabulary and existing script names without altering either.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Provision 1's "re-observe by name" requirement is read as merely advisory, and plans keep skipping it | M | L | State it as a MUST inside the final phase's own verification criteria, as drafted above, mirroring the precedent plan's own concrete instance |
| A future plan conflates Provision 2's ownership statement with `status-markers.md`'s target-argument/resting-state rule, re-introducing the conflation acceptance criterion (3) guards against | M | L | Keep the recommended wording's citation scoped to "invoked from `update-task-status.sh` postflight" only, with no target-argument language, exactly as drafted |
| Reviewer judges `agents/planner-agent.md` does need a line after all (e.g. for defense-in-depth) | L | L | The plan should state the decision and its reasoning explicitly (Decision 3 above) rather than silently omitting the file, satisfying the dispatch's own instruction to resolve the ambiguity one way or the other |
| The two provisions are drafted at slightly different insertion points and a plan author lands them in the wrong subsection, muddying which gate-shape governs which rule | L | L | Both insertion points are named precisely by surrounding verbatim text above (the paragraph each follows and precedes), leaving no ambiguity for the implementer |

## Context Extension Recommendations

None — `plan-format.md` is already the canonical home for both gaps, and no new context file is
warranted; this record closes a gap inside an existing one.

## Recommendations

- Implement both provisions as drafted in Decisions 1 and 2 above, at the two named insertion
  points inside `context/formats/plan-format.md`, edited at the source store
  (`/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md`)
  per `.claude/rules/source-store-deploy-boundary.md`, then redeployed via
  `bash .claude/scripts/deploy-headless.sh` with `RESULT=landed_verify_clean` confirmed.
- Do not edit `agents/planner-agent.md`; record the reasoning in the plan per Decision 3 rather
  than silently dropping the path.
- No change to any script, the phase-heading enum, or the plan-level Status vocabulary is
  required or recommended.
- Verify after editing that neither new paragraph introduces task-number references or
  record-versioning language (`.claude/rules/no-task-references-in-deliverables.md`,
  `.claude/rules/no-record-versioning-in-deliverables.md`) — both drafts above were written to
  satisfy this already (durable anchors only: file names, section headings, script names).

## Appendix

### Search queries / commands used

- `grep -n "blocked\|wave\|decision gate\|Depends on" specs/archive/006_.../plans/05_*.md`
- `grep -n "Depends on\|### Phase\|## Wave" specs/archive/008_.../plans/03_*.md`
- `find specs/archive -maxdepth 2 -iname "*760_*"` / `*836_ladder*`
- Direct `python3 -c "json.load(...)"` reads of `specs/state.json` for task 769's and task 784's
  full records
- `diff` between deployed `.claude/context/formats/plan-format.md` /
  `.claude/agents/planner-agent.md` and their source-store counterparts (byte-identical both
  times, despite the `core` extension's overall staleness flag)

### Key file references

- `context/formats/plan-format.md:304-310` (final-phase rule)
- `context/formats/plan-format.md:690-733` (Decision gates and contingency branches)
- `context/formats/plan-format.md:741-786` (Plan-level vs. phase-level markers, Trailing
  annotations)
- `context/contracts/plan-status-ownership.md` (canonical ownership fragment, 16-agent
  enumeration)
- `context/standards/status-markers.md:419-433` (Target Arguments vs. Resting States)
- `specs/archive/760_ladder_model_cell_stabilization_lemma/plans/01_ladder-cell-refutation-probe.md`
  (originating precedent, lines 176-251 wave table and Phase 1, lines 486-538 Phase 4)
- `specs/archive/760_ladder_model_cell_stabilization_lemma/issues.jsonl` (entries
  `iss_1791710205747_08BVlu`, `iss_1791711120761_z8uj5G`)
- `agents/planner-agent.md:274-367` (plan-authoring template), `:578` ("Follow plan-format.md
  structure exactly")
