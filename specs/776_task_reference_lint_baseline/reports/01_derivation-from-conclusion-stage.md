# Derivation Note: Task-Reference Lint Baseline

**Origin**: `/orchestrate` conclusion stage, channel (c). Derived from a parent task's issue log
rather than researched from scratch; this note records the evidence so the planning phase has
grounding, and does not substitute for the survey the task itself calls for.

## Cited Evidence

- `specs/773_ladder_cell_index_factorization/issues.jsonl`, entry `iss_1791781468414_vgo3gh`
  (class `gate-baseline`, severity `minor`, resolution null — implicit-open).

## The Observation

`scripts/check-task-references.sh` — the repo-wide lint backing
`.claude/rules/no-task-references-in-deliverables.md` — **exits 1 at 198 unexempted occurrences
repo-wide**. This is a pre-existing baseline, not a regression introduced by the task that
reported it:

- None of that task's three touched non-`specs/` files
  (`FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `docs/theorem-index.md`) appears
  anywhere in the lint's findings.
- A direct grep over all three for `specs/NNN_` and `task N` returns nothing.

## The Two Questions

**1. The baseline itself.** 198 unexempted occurrences either need resolving (edited to cite
durable anchors — a filename, a section heading, a decision-record name, or a verified fact, per
the rule) or formally accepting (exempted via the `task-ref-ok` marker convention and the
7-category taxonomy in `.claude/context/standards/task-reference-exemptions.md`, with the reason
recorded). Deciding which occurrences fall in which category is the bulk of the work, and the
answer is probably not uniform across all 198.

The mechanical source of truth for pattern and exemption logic is
`scripts/lib/task-reference-patterns.sh`, consumed by both `check-task-references.sh` and
`hooks/validate-no-task-references.sh`. Any exemption-logic change lands in the **source store**
resolved from `.claude-extensions.json`, never hand-authored under `.claude/**`.

**2. The verification-criterion question (secondary angle, deliberately not split into its own
record).** A plan phase asked for `exit 0` from this lint as a phase verification criterion — a
criterion the repository cannot deliver independently of the phase being verified, since the
baseline is repo-wide and pre-existing. The per-file criterion actually met was "no occurrence
INTRODUCED by this phase." Whether plan verification criteria should ask for the per-file form
rather than a repo-wide `exit 0` for any lint with a standing baseline is the same question in a
different register, and is noted here rather than filed separately.

Resolving (1) would make (2) moot for this lint specifically, but not for the general class.
