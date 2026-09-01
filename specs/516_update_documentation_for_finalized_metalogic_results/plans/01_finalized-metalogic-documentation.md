# Implementation Plan: Task #516

- **Task**: 516 - Update documentation for finalized metalogic results
- **Status**: [IMPLEMENTING]
- **Effort**: 4.25 hours
- **Dependencies**: None
- **Research Inputs**: `specs/516_update_documentation_for_finalized_metalogic_results/reports/01_finalized-metalogic-documentation.md`
- **Artifacts**: plans/01_finalized-metalogic-documentation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The research pass verified, against live tooling rather than against existing prose, that
`README.md`'s soundness, weak/finite-context completeness, three-way compactness, and
one-directional decidability sections are **already accurate** — so this task is not a correction
pass over those sections. The single real gap is that two finished, sorry-free result families
(frame-class Galois-closure/definability in `FormalSystem/Semantics/Correspondence/`, and Kamp
expressive-completeness for Prior structures in
`FormalSystem/Metalogic/WeakCanonical/Kamp/KampPrior.lean`) appear in **no** status-summarizing
document: not in `README.md`, not in `FormalSystem/Metalogic.lean`'s "Publication-Ready Results"
ledger, not in `docs/project-info/implementation-status.md`. This plan adds those two families to
the three documents, in that ledger-first order so the mirrors never state something the ledger
omits, and gates every added sentence on a re-verified theorem name. Definition of done: the two
result families are documented with their exact scope qualifiers in all three places, `lake build`
and `scripts/check-module-invariants.sh` are no worse than the pre-task baseline, and no
previously-accurate sentence has been rewritten.

### Research Integration

Findings carried directly into phases below:

- Verification tooling is `scripts/check-module-invariants.sh` (C1-C15, includes `lake build`),
  `scripts/typst-status-counts.sh --json`, and per-theorem axiom checks. C6 currently **FAILS**
  on a pre-existing manifest-registration gap (4 unreachable live modules absent from
  `scripts/module-invariants-manifest.txt`); this is test infrastructure, unrelated to prose, and
  is an accepted pre-existing baseline failure, not a regression this task may introduce or must
  fix.
- Positive Galois-closure results: `galoisClosed_mod` (`Correspondence/Galois.lean`),
  `galoisClosed_of_indicator` (same file), `galoisClosed_sat_dense` and `galoisClosed_isDiscrete`
  (`Correspondence/Indicator.lean`), with indicator biconditionals `validOn_nextTop_iff` and
  `validOn_nextTop_iff_isDiscrete`. The discreteness result is at `TaskFrame.IsDiscrete`, the bare
  structural clause, **not** the narrower Hölder-to-`ℤ` class.
- Negative results: `sat_dedekind_ssubset_mod_axiomSet` (`Independence/RationalWitness.lean`) and
  `sat_discrete_ssubset_mod_axiomSet` (`Independence/LexIntWitness.lean`).
- Documented non-goal to preserve: closed-form characterizations of `Mod (AxiomSet .Discrete)` and
  `Mod (AxiomSet .Dedekind)` are open and not promised.
- Kamp: `kampPriorExpressiveCompleteness` (`WeakCanonical/Kamp/KampPrior.lean`), sorry-free at all
  depths, axioms `[propext, Classical.choice, Quot.sound]`, load-bearing for the live completeness
  chain via `uSExpressivelyCompleteOverPrior`. Scope qualifier is **Prior structures**.
- Explicitly out of scope per the report: C6's manifest gap, and C9D's 138 task-number citations
  under `docs/` (a separate pre-existing hygiene item in files that carry no
  completeness/soundness/compactness/characterization claims).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was supplied in the delegation context; no ROADMAP.md was consulted or modified.

## Goals & Non-Goals

**Goals**:
- Add the frame-class Galois-closure/definability results and the Kamp expressive-completeness
  result to `FormalSystem/Metalogic.lean`'s "Publication-Ready Results" ledger, in that file's
  existing bullet format.
- Add a characterization/definability subsection to `README.md`'s "## Metalogical Results",
  mirroring the ledger and carrying the same scope qualifiers.
- Mirror both families into `docs/project-info/implementation-status.md`'s Layer 2 table so the
  three status documents agree.
- Keep every added claim traceable to a theorem name plus file path re-verified during this task.

**Non-Goals**:
- No Lean proof work. The only `.lean` edits in scope are docstring / status-ledger prose.
- No rewriting of the soundness, completeness, compactness, or decidability prose in `README.md`,
  `docs/project-info/known-limitations.md`, or `docs/project-info/implementation-status.md` — the
  research pass verified these accurate, and editing correct prose is the staleness risk this
  task exists to avoid.
- No fix for the pre-existing C6 manifest gap.
- No cleanup of C9D task-number citations under `docs/`.
- No change to any documented count (axiom/rule/sorry counts) — those were independently
  reproduced and already match.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| New prose conflates "`Sat FrameClass.Dedekind` is not Galois-closed" (proved negative) with "Dedekind compactness is unresolved" (open) | H | M | Correctness constraint C1 below; Phase 5 read-through explicitly checks for it |
| Kamp result over-claimed as holding "for TM" or "for all task frames" rather than for Prior structures | H | M | Correctness constraint C2; use the report's qualifier verbatim |
| "Make it comprehensive" pressure leads to editing already-accurate sections | M | M | Non-Goals above; Phase 5 diff review rejects any hunk outside the added subsections |
| A theorem name is transcribed from the report without re-verification and has since moved or been renamed | M | L | Phase 1 re-verifies every name before any prose is written; Phase 1 output is the only permitted source for names |
| Task-number reference leaks into a deliverable outside `specs/` | M | L | Correctness constraint C3; `.claude/scripts/check-task-references.sh` in Phase 5 |
| Pre-existing C6 failure mistaken for a regression caused by this task | L | M | Baseline captured in Phase 1 before any edit; Phase 5 compares against that baseline, not against "all green" |

### Correctness constraints (binding on all writing phases)

- **C1 — Two different facts, never merged.** "`Sat FrameClass.Dedekind` is not Galois-closed"
  (settled, proved by `sat_dedekind_ssubset_mod_axiomSet`) and "Dedekind compactness / strong
  completeness is unresolved" (open, no `CompactDedekind` and no refuting theorem in the tree) are
  statements about **different properties** of the same frame class — Galois-closedness of the
  *model class* versus compactness of the *consequence relation*. No sentence may present either
  as evidence for, or a consequence of, the other. Where both appear near each other, name the
  property explicitly in each.
- **C2 — Scope qualifiers verbatim.** The Kamp result is expressive completeness of `{U, S}`
  **for Prior structures** relative to monadic first-order logic — never "for TM", never "for all
  task frames". The discreteness Galois-closure result is at `TaskFrame.IsDiscrete`, the bare
  structural clause — never the narrower Hölder-to-`ℤ` class.
- **C3 — No task-number references in deliverables.** `README.md`, `FormalSystem/**`, and `docs/**`
  are outside `specs/`, so per `.claude/rules/no-task-references-in-deliverables.md` they must cite
  theorem names and file paths, never "task N".
- **C4 — Verify before writing.** Every theorem name, file path, and status word ("sorry-free",
  "proved", "open") written into a deliverable must appear in the Phase 1 evidence file with a
  live-tool result behind it. A name that failed Phase 1 verification is not written, and the
  phase is marked `[BLOCKED]` rather than softened into vaguer prose.
- **C5 — Preserve the documented non-goal.** Any new prose about the Correspondence layer must
  carry the existing disclaimer that closed-form characterizations of `Mod (AxiomSet .Discrete)`
  and `Mod (AxiomSet .Dedekind)` are open and not promised.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Re-verify characterization claims and capture the tooling baseline [COMPLETED]

**Goal**: Produce a single evidence file that every later phase quotes from, and record the
pre-edit state of the verification tooling so a pre-existing failure is never mistaken for a
regression. No deliverable file is touched in this phase.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh` and record the pass/fail verdict of each
      check. Note explicitly that C6 is expected to FAIL on the pre-existing manifest gap; record
      the exact set of failing checks as the baseline.
- [x] Run `bash scripts/typst-status-counts.sh --json` and record the counts, to confirm no count
      this task might touch has drifted.
- [x] For each name below, confirm it exists at the stated path with the stated shape, using
      `grep -n` for the declaration plus `lean_local_search` or `lean_hover_info` for the
      signature: `galoisClosed_mod`, `galoisClosed_of_indicator` (`Semantics/Correspondence/Galois.lean`);
      `galoisClosed_sat_dense`, `galoisClosed_isDiscrete`, `validOn_nextTop_iff`,
      `validOn_nextTop_iff_isDiscrete` (`Semantics/Correspondence/Indicator.lean`);
      `sat_dedekind_ssubset_mod_axiomSet` (`Metalogic/Independence/RationalWitness.lean`);
      `sat_discrete_ssubset_mod_axiomSet` (`Metalogic/Independence/LexIntWitness.lean`);
      `kampPriorExpressiveCompleteness` (`Metalogic/WeakCanonical/Kamp/KampPrior.lean`).
- [x] For `kampPriorExpressiveCompleteness` and at least one Galois-closure positive result, run
      `lean_verify` (or `#print axioms`) and record the axiom set. Write down the actual set; do
      not copy `[propext, Classical.choice, Quot.sound]` forward unless the tool prints it.
- [x] Confirm the absence claims that constrain the wording: no `CompactDedekind`,
      `StrongCompletenessDedekind`, `SatisfiableDedekindSet`, or `ModelExistenceDedekind` symbol
      anywhere under `FormalSystem/` outside `Boneyard/`.
- [x] Read `FormalSystem/Semantics/Correspondence/Galois.lean`'s module docstring and
      `Correspondence/README.md`, and transcribe the "closed-form characterizations ... are open
      and not promised" disclaimer verbatim for reuse under C5.
- [x] Write all of the above to
      `specs/516_update_documentation_for_finalized_metalogic_results/verification-evidence.md`,
      one line per claim in the form `claim | command run | result`.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that exactly nine declarations exist at five named files.
Confirm each individually with `grep -n`; if any name is missing or has moved, record the actual
location (or the absence) in the evidence file and do **not** silently substitute a similarly
named declaration. A missing name propagates as a blocked claim into Phases 2-4, not as a
paraphrase.

**Files to modify**:
- `specs/516_update_documentation_for_finalized_metalogic_results/verification-evidence.md` -
  new file; the evidence ledger all later phases quote from. Inside `specs/`, so C3 does not
  apply to it.

**Verification**:
- The evidence file exists and has one entry per name listed above, each with a command and a
  result — no entry reading only "per the research report".
- The recorded baseline names every currently-failing check, so Phase 5 has something concrete to
  compare against.
- No file outside `specs/` was modified: `git status --short` shows only the new evidence file.

---

### Phase 2: Add both result families to the `Metalogic.lean` status ledger [COMPLETED]

**Goal**: Extend `FormalSystem/Metalogic.lean`'s "Publication-Ready Results" list with the
Galois-closure/definability family and the Kamp expressive-completeness result, in the file's own
existing `- **Name** (\`theorem\`): SORRY-FREE ...` bullet style. This file is the in-tree
authoritative ledger the other two documents mirror, so it is authored first and the wording
settled here is what Phases 3 and 4 reuse.

**Tasks**:
- [x] Locate the end of the "Publication-Ready Results" bullet list (currently terminating at the
      `**Decidability** (\`decide\`)` bullet, immediately before the `## Completeness Architecture`
      heading) and confirm the insertion point by reading the surrounding lines.
- [x] Add a `**Characterization / definability**` bullet naming `galoisClosed_mod` (axiomatizable
      = Galois-closed), `galoisClosed_of_indicator` (single-formula method), and the two positive
      results `galoisClosed_sat_dense` / `galoisClosed_isDiscrete`, each with the status word the
      Phase 1 evidence file supports.
- [x] In the same bullet (or an adjacent sub-bullet), record the two negative results
      `sat_dedekind_ssubset_mod_axiomSet` and `sat_discrete_ssubset_mod_axiomSet`, stating the
      property as Galois-closedness of the model class. Apply C1: if this text sits near the
      existing Dedekind strong-completeness caveat, name the property in both so a reader cannot
      read one as bearing on the other.
- [x] Append the C5 disclaimer that closed-form characterizations of `Mod (AxiomSet .Discrete)`
      and `Mod (AxiomSet .Dedekind)` remain open and are not promised.
- [x] Add a `**Expressive completeness (Kamp, Prior structures)**` bullet for
      `kampPriorExpressiveCompleteness`, with the axiom set recorded in Phase 1, the Prior-structures
      scope qualifier (C2), and the fact that it is load-bearing for the live completeness chain
      via `uSExpressivelyCompleteOverPrior`.
- [x] Re-read the added hunk to confirm every edit sits inside the `/-! ... -/` docstring block and
      no delimiter was broken.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase assumes the "Publication-Ready Results" list is a flat bullet list
ending immediately before `## Completeness Architecture`, and that no existing bullet already
covers either family. Confirm both by reading the section top-to-bottom before inserting; if a
partial mention already exists, extend it rather than adding a duplicate bullet.

**Files to modify**:
- `FormalSystem/Metalogic.lean` - two new bullets appended to the "Publication-Ready Results"
  docstring list. Docstring prose only; no declaration, import, or tactic is touched.

**Verification**:
- `lake build FormalSystem.Metalogic` succeeds (module-local build; the docstring delimiters are
  the only compile surface a prose edit here can break).
- `git diff FormalSystem/Metalogic.lean` shows every changed line inside the `/-!`-delimited
  docstring.
- Every theorem name in the diff appears in the Phase 1 evidence file (C4).
- Grep the diff for the strings `task ` and `Task ` followed by a digit — zero hits (C3).

---

### Phase 3: Add the characterization subsection to `README.md` [COMPLETED]

**Goal**: Give `README.md` a "### Characterization and Definability" subsection under
"## Metalogical Results", mirroring the Phase 2 ledger wording, and correct the one Project
Structure sentence that describes `Kamp/` without noting its headline theorem is finished. This is
the task's primary deliverable.

**Tasks**:
- [x] Add `### Characterization and Definability` after the existing `### Decidability` subsection
      and before the `---` preceding `## Documentation`, matching the surrounding sections'
      house style (bolded status word, theorem name in backticks, file path in backticks).
- [x] Write the Galois-closure paragraph: the organizing equivalence (`galoisClosed_mod`), the
      single-formula method (`galoisClosed_of_indicator`), the two positive results with their
      indicator biconditionals, and the two negative sandwich-witness results — each with the
      property named explicitly per C1, and with the `TaskFrame.IsDiscrete` qualifier per C2.
- [x] Write the Kamp paragraph: `kampPriorExpressiveCompleteness`, `{U, S}` expressively complete
      relative to monadic first-order logic **for Prior structures** (C2), sorry-free at the axiom
      set recorded in Phase 1, and load-bearing for `completeness` through
      `uSExpressivelyCompleteOverPrior`.
- [x] Close the subsection with the C5 open/not-promised disclaimer.
- [x] Update the Project Structure prose sentence that currently reads that `Kamp/` (116 files) "is
      the Kamp-style expressiveness development" so it also records that its headline theorem is
      discharged, citing the theorem name — one sentence, no restructuring of the tree diagram.
- [x] Re-read the whole "## Metalogical Results" section end to end and confirm no
      previously-existing sentence was altered.

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase assumes the insertion point is between the `### Decidability`
subsection and the `## Documentation` heading, and that the Project Structure `Kamp/` sentence is
a single prose line below the tree diagram rather than a diagram entry. Confirm both by reading
`README.md`'s heading outline (`grep -n '^#\{1,4\} ' README.md`) and the target lines before
editing; adjust the insertion point to the actual structure rather than forcing the assumed one.

**Files to modify**:
- `README.md` - one new `###` subsection under "## Metalogical Results"; one sentence amended in
  the Project Structure prose. No other section touched.

**Verification**:
- `bash scripts/check-module-invariants.sh` (or its `--no-build` form, then a separate
  `lake build`) — C14 ("no stale axiom or sorry counts documented in `docs/` + `README.md` +
  `FormalSystem/*.lean`") must still PASS, and the failing-check set must equal the Phase 1
  baseline exactly.
- `git diff README.md` — every changed hunk lies either in the new subsection or in the single
  Project Structure sentence; no hunk touches the soundness, completeness, compactness,
  decidability, or Axiom Systems prose.
- Every theorem name in the diff appears in the Phase 1 evidence file (C4).
- Manual C1 check: read the new subsection aloud against the existing Dedekind strong-completeness
  bullet and confirm a reader cannot take either statement as bearing on the other.
- `bash .claude/scripts/check-task-references.sh` reports no new violations in `README.md` (C3).

---

### Phase 4: Mirror both families into `implementation-status.md` [COMPLETED]

**Goal**: Add the two result families to `docs/project-info/implementation-status.md`'s Layer 2
Metalogic table so the three status documents agree. Lowest-priority of the three writes per the
research pass, and strictly additive.

**Tasks**:
- [x] Add a row for `Semantics/Correspondence/` to the Layer 2 table (or the nearest correct
      table if Correspondence belongs to a different layer — check the file's layer definitions
      first), status ✅, notes naming `galoisClosed_mod`, `galoisClosed_sat_dense`,
      `galoisClosed_isDiscrete`. *(deviation: altered — placed as two per-file rows
      (`Correspondence/Galois.lean`, `Correspondence/Indicator.lean`) under Layer 1: Semantics,
      matching that table's own per-file granularity and the file's own directory-based layer
      taxonomy (Layer 1 = `Semantics/*`, Layer 2 = `Metalogic/*`); also names
      `galoisClosed_of_indicator`)*
- [x] Add a row for `Metalogic/WeakCanonical/Kamp/` naming `kampPriorExpressiveCompleteness` with
      the Prior-structures qualifier (C2).
- [x] If the existing `Metalogic/Independence/` row ("Three independence results") does not already
      cover the two sandwich-witness negative results, extend its notes to name them, keeping the
      property explicit per C1. Do not renumber or restate the independence results themselves.
- [x] Confirm no other row was edited.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase assumes `Semantics/Correspondence/` belongs under the existing
"## Layer 2: Metalogic" table, which currently lists `Metalogic/*` modules only. Confirm against
the file's own layer definitions before inserting; if Correspondence is a Semantics-layer concern
in this document's taxonomy, place the row in that layer's table instead and say so in the phase
notes.

**Files to modify**:
- `docs/project-info/implementation-status.md` - two added table rows, and at most one existing
  row's notes cell extended.

**Verification**:
- `git diff docs/project-info/implementation-status.md` shows only added rows plus (at most) one
  extended notes cell.
- Markdown tables still render: column counts match the header row in every touched table.
- Every theorem name in the diff appears in the Phase 1 evidence file (C4).
- `bash .claude/scripts/check-task-references.sh` reports no new violations in this file (C3).

---

### Phase 5: Cross-document accuracy gate [COMPLETED]

**Goal**: Confirm the three documents now agree with each other and with the tree, that nothing
previously accurate was changed, and that the tooling baseline is no worse than Phase 1's.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh` in full (including `lake build`) and diff the
      pass/fail verdict set against the Phase 1 baseline. Any newly failing check is a regression
      this task must fix; C6's pre-existing failure is not.
- [x] Run `bash scripts/typst-status-counts.sh --json` and confirm every count is identical to
      Phase 1 — this task changed no count, so any drift means something unintended was edited.
- [x] Run `bash .claude/scripts/check-task-references.sh` and confirm no new violation in
      `README.md`, `FormalSystem/Metalogic.lean`, or
      `docs/project-info/implementation-status.md` (C3). Pre-existing `docs/` violations elsewhere
      are out of scope and must not be "fixed" here.
- [x] Read the three added passages side by side and confirm they state the same facts with the
      same qualifiers — no document claims more than the ledger.
- [x] Explicit C1 audit: grep all three files for `Dedekind` and read every hit, confirming each
      occurrence states either Galois-closedness of the model class or compactness of the
      consequence relation, and never lets one stand in for the other.
- [x] Explicit C2 audit: grep for `Kamp` and `expressive` and confirm every occurrence carries the
      Prior-structures qualifier; grep for `IsDiscrete` and confirm the bare-structural-clause
      qualifier survives.
- [x] Review the full `git diff` for the task and confirm no hunk falls outside the additive scope
      declared in Phases 2-4.

**Timing**: 0.75 hours

**Depends on**: 3, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- None (verification only). If an audit finds a defect, fix it in the owning phase's file and
  re-run this phase's checks.

**Verification**:
- `check-module-invariants.sh` failing-check set equals the Phase 1 baseline set (expected: C6
  only).
- `typst-status-counts.sh --json` output is byte-identical to Phase 1's.
- `check-task-references.sh` shows no new violation in the three touched deliverables.
- The C1 and C2 audits produce a written pass/fail line each in the execution summary.

---

## Testing & Validation

- [ ] `lake build` exits 0.
- [ ] `bash scripts/check-module-invariants.sh` — C1, C2, C3, C14, C15 PASS; the failing set is
      unchanged from the pre-task baseline (expected: C6 only, pre-existing).
- [ ] `bash scripts/typst-status-counts.sh --json` output unchanged from baseline.
- [ ] `bash .claude/scripts/check-task-references.sh` — no new violations in `README.md`,
      `FormalSystem/Metalogic.lean`, `docs/project-info/implementation-status.md`.
- [ ] Every theorem name written into a deliverable traces to a line in the Phase 1 evidence file.
- [ ] C1 audit passes: the Galois-closure negative results and the Dedekind compactness open
      question are never presented as bearing on each other.
- [ ] C2 audit passes: Kamp scoped to Prior structures; discreteness Galois-closure scoped to
      `TaskFrame.IsDiscrete`.
- [ ] No hunk in the task diff touches previously-verified-accurate soundness, completeness,
      compactness, or decidability prose.

## Artifacts & Outputs

- `specs/516_update_documentation_for_finalized_metalogic_results/verification-evidence.md` -
  per-claim evidence ledger (Phase 1)
- `FormalSystem/Metalogic.lean` - two added "Publication-Ready Results" bullets (Phase 2)
- `README.md` - new "### Characterization and Definability" subsection plus one amended Project
  Structure sentence (Phase 3)
- `docs/project-info/implementation-status.md` - two added Layer 2 rows (Phase 4)
- `specs/516_update_documentation_for_finalized_metalogic_results/summaries/01_*-summary.md` -
  execution summary including the C1/C2 audit results and the baseline-vs-final tooling comparison

## Rollback/Contingency

All four writes are additive prose in tracked files, committed per phase, so `git revert` of the
phase commits restores the pre-task state exactly; no generated artifact or build output depends
on them. If Phase 1 cannot verify a name, the phases that would have cited it are marked
`[BLOCKED]` with the unverified name recorded — the correct outcome is a smaller accurate
addition, never a vaguer sentence that hides the gap. If `check-module-invariants.sh` develops a
new failure after any phase, revert that phase's commit before proceeding rather than layering the
next phase on an unverified base.
