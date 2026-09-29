# Implementation Plan: Task #699

- **Task**: 699 - invariance_clause_audit_and_ockhamist_grounding
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None. Task 696 is cited, never touched; its fourteen declared paths and its
  design are out of scope here.
- **Research Inputs**: `specs/699_invariance_clause_audit_and_ockhamist_grounding/reports/01_invariance-clause-audit-ockhamist-grounding.md`
  (671 lines) and `specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/01_clause_shape_collapse_probe.lean`
  (220 lines, elaborates clean)
- **Artifacts**: plans/01_invariance-clause-audit-ockhamist-grounding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal:logic
- **Lean Intent**: false — no statement in `FormalSystem/` is created, modified or deleted by any
  phase. Phase 1 writes one standalone probe file under this task's own `probes/` directory, which
  the task description explicitly permits, and elaborates it against the existing oleans.

## Overview

The research round already produced this task's named deliverable: one report carrying Part A's
19-row audit table and Part B's literature verdict, plus a named follow-on task proposal. This plan
is therefore a **closing round**, not new investigation. It does four things: (1) raises the two
Part A verdicts that are currently *asserted* to the machine-checked bar the task description sets
("so the verdict is checkable rather than asserted"); (2) lands the one time-critical actionable
output — the `trans_reflexivity_residual_collapse` follow-on, which must be filed before task 696's
Phase 1 declares `trans_refl` — as a command-ready payload; (3) converts Part A's prose enumeration
commands into a re-runnable script plus a dated snapshot, so the "mechanical audit" is reproducible
against a changed tree rather than a 2026-09-28 prose snapshot; (4) reconciles the report with all
three and runs a no-asserted-claim consistency pass over it.

**If cost is a concern, Phase 2 is the only load-bearing phase.** It is the phase with an external
deadline (task 696 Phase 1). Phases 1 and 4 tighten a deliverable that is already acceptable;
Phase 3 is additive and is flagged as such in Non-Goals. Closing the task on the research artifact
alone plus Phase 2 is a defensible outcome and the plan is structured so that Phase 2 can run first
and independently.

**Soundness is not in question in any phase.** `plusTruth_iff_mem` and `plusRefutes_of_certifies`
are untouched and unread; every finding this plan hardens is a completeness-side restriction on
which families are well-formed. The report states this in its Executive Summary and Phase 4
verifies that statement survived editing verbatim.

### Research Integration

Four findings from the report drive the phases:

- **Row 6 is asserted, not probed.** The report's table marks `shareClauseAt`'s `snce`/`untl` arms
  (`Sharing/Decide.lean` 420-429) **COLLAPSE** with the Derivation cell reading "same two
  derivations at `Formula`; not separately probed". Probe 01's ten declarations cover the
  `PlusFormula`-side mirror (`plusShareClauseAt_snce_collapse`, `..._untl_collapse`) but not this
  one. Verified independently: `Sharing/Decide.lean` 420-429's two arms have the identical clause
  shape (`∀ j, rp i = rp j → (untl g e ∈ Lt i ↔ …)`, `∀ k, rt i = rt k → (snce g e ∈ Lt i ↔ …)`),
  so the instantiation of `clause_shape_collapse` is the same three-argument application probe 01
  already uses. Phase 1 closes it.
- **Row 12's globality derivation is prose-only.** A3 writes the (C3) composition out in text
  (`box χ ∈ L i t ↔ bx χ = true ↔ box χ ∈ L j v`) and says "the derivation is worth writing out
  anyway", but no probe declaration checks it. The *verdict* stays INTENDED on the evidence A3
  cites (`Truth.box_const`, `plusTruthAt_timeShift`, the truth lemma's box case consuming the
  globality); what Phase 1 checks is the verdict's *premise*, that the invariance is real and of
  the audited shape.
- **The follow-on is time-critical and unfiled.** The report's `next_steps` names
  `trans_reflexivity_residual_collapse` as the actionable output and says it "should be created
  before task 696 Phase 1 declares `trans_refl`". It exists as a prose section, not as a filed
  task or a command-ready payload. Phase 2 produces the payload.
- **A second, unowned documentation defect fell out of Part A.** Row 2 refutes the module docstring
  at `PlusWitnessFamily/Incompleteness.lean:51-52` ("**The `untl` side is defect-free by
  inspection, not by machine check.**"). Verified: that exact text is at `Incompleteness.lean:51`
  and at `PlusWitnessFamily/README.md:100`, and `Incompleteness.lean` is **not** among task 696's
  fourteen declared `file_scope` paths (checked against `specs/state.json`), while both READMEs
  are. So the README correction is owned by 696 and the docstring correction is owned by nobody.
  This task cannot make either (no Lean modification; both paths outside its `file_scope`), so
  Phase 2 records the handoff and Phase 4 files it in the report.

### Prior Plan Reference

No prior plan. `next_artifact_number` is 2, so this is round 1's plan and shares the round number
with the report and probe already written.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and `roadmap_flag` is absent, so no roadmap-review
or roadmap-update phase is added. `specs/ROADMAP.md` exists and was consulted read-only: its
Phase 2 ("Decidability and the Tableau Engine — the largest open front") is the front this audit
bears on, but the audit ticks no checkbox there. It constrains the design of work under that
phase (task 696's substrate redesign) rather than advancing a roadmap item itself. No phase in
this plan writes to `specs/ROADMAP.md`.

## Goals & Non-Goals

**Goals**:

- Every **COLLAPSE** verdict in Part A's table is backed by a named, elaborated probe declaration
  rather than by an assertion that the derivation is "the same" as a probed one.
- Row 12's globality premise is machine-checked, so the INTENDED verdict rests on checked shape
  plus cited semantic evidence rather than on prose alone.
- The `trans_reflexivity_residual_collapse` follow-on exists as a verbatim-ready `/task`
  invocation, filed inside this task's own directory, ahead of task 696 Phase 1.
- The unowned `Incompleteness.lean` docstring defect, and the strengthening task 696's own
  README-correction text needs per rows 2-4, are both recorded with line references and an
  explicit statement of who owns each.
- Part A's enumeration is re-runnable: one script, one dated snapshot, counts that a future reader
  can reproduce instead of trust.
- The report ends the round with no claim that is neither probe-backed, source-named, nor marked
  unverified.

**Non-Goals**:

- **No modification to any Lean statement, docstring or file under `FormalSystem/`.** Not the
  `Incompleteness.lean` docstring the audit refuted, not either README. Those are handed off.
- **No substrate redesign and no edit to task 696's fourteen declared paths.** The one design input
  this task has (drop `trans_refl`) is filed as a proposal against that design, never as an edit
  to it.
- **No write to `specs/state.json` or `specs/TODO.md`, and no task creation.** Filing a task is a
  `/task` action. Sibling task 698 additionally holds `specs/state.json` as its declared
  `file_scope` this same `/orchestrate` cycle, so writing it here would be a territory violation
  on top of a role violation.
- **No new incompleteness theorem.** Turning the residual `trans` collapse into a named
  non-refutability result needs a hopping countermodel and a detecting target; the report scopes
  that as the follow-on's optional step 4 and this plan does not attempt it.
- **No re-conversion of `thomason-1970-indeterminist-time`.** Its OCR is column-interleaved and
  unusable; the one claim depending on it is marked unverified and nothing else rests on it. The
  corpus lives outside this repository and outside this task's `file_scope`.
- **Phase 3 (the enumeration script) is additive to the named deliverable**, kept because the task
  description calls Part A "a mechanical audit" and a re-runnable enumeration is what makes that
  word true. It is the phase to cut first if the round is trimmed.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Four sibling tasks (695, 697, 698, 700) are dispatched onto this same working tree this cycle | M | H | Every phase writes only under `specs/699_invariance_clause_audit_and_ockhamist_grounding/`, which no sibling declares. Stage an explicit file list per commit, never a directory or glob pathspec. Re-read any file immediately before editing it. Treat a build failure outside this task's own probe file as possibly a sibling's in-flight edit, and report a foreign commit or modification rather than working around it. |
| Phase 3's script reproduces counts different from the report's 67/40/39 | L | M | The script's output is the authority, not the report's figures. A divergence is a report correction in Phase 4, explicitly *not* a licence to tune the script until the numbers match. This direction is written into Phase 3's Scope Hypothesis so the implementer cannot invert it. |
| Probe 02 fails to elaborate because it imports probe 01 (not in the build graph) | M | M | Probe 02 is standalone: it re-declares `clause_shape_collapse` locally in its own three lines and imports only library modules (`...PlusWitnessFamily.Incompleteness`, `...PlusWitnessFamily.Decide`, `...WitnessFamily.Sharing.Decide`). Phase 1's verification is elaboration exit 0, so a bad import fails loudly rather than silently. |
| Row 12's composition needs a hypothesis A3 did not name, and the derivation does not in fact run | M | L | Then the finding is that A3's prose derivation was incomplete, and Phase 4 records the missing hypothesis in row 12's cell. This is a reportable outcome, not a phase failure: the verdict (INTENDED) does not depend on the composition running, only on `Truth.box_const`. Do not weaken the row-12 statement until it elaborates. |
| The report grows less readable as Phase 4 threads new cross-references through a 671-line file | L | M | Phase 4 edits cells and appendix tables in place and adds at most one addendum line under Decisions; it does not restructure sections or re-argue any verdict. |
| A reader takes a hardened COLLAPSE verdict as a soundness finding | H | L | Phase 4 verifies the Executive Summary's soundness paragraph survived editing verbatim, and Phase 1's new declarations are named `*_collapse` / `*_congr` in the report's own vocabulary, which the Executive Summary already glosses as completeness-side. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel. Wave 1's three phases write disjoint new
files (`probes/02_*.lean`, `proposals/01_*.md`, `audit/*`) and none of them edits the report, so
they carry no mutual territory constraint. Phase 4 is the only phase that touches the report and
is the only consumer of the other three.

### Phase 1: Machine-check the audit's remaining asserted verdicts [COMPLETED]

**Goal**: bring Part A's one asserted COLLAPSE verdict (row 6) and row 12's globality premise to
the same machine-checked bar as the nine verdicts probe 01 already covers, so that no verdict in
the table rests on "the same derivation as" another.

**Tasks**:

- [x] Create `specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/02_remaining_verdicts_probe.lean`
      as a standalone file. Import only library modules — `FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Incompleteness`,
      `...PlusWitnessFamily.Decide` and `...WitnessFamily.Sharing.Decide` — and re-declare
      `clause_shape_collapse` locally (its three lines, as probe 01 states it). Do **not** import
      probe 01: it is not in the build graph. *(completed)*
- [x] Row 6, `snce` arm: prove `shareClauseAt_snce_collapse` — from
      `∀ i, shareClauseAt bx rt rp Lm Lt Lp i (Formula.snce g e)` derive
      `∀ i j, rt i = rt j → (Formula.snce g e ∈ Lt i ↔ Formula.snce g e ∈ Lt j)`, by
      `clause_shape_collapse (R := fun i j => rt i = rt j) (fun _ => rfl)`.
      *(completed: `SharingWitnessFamily.shareClauseAt_snce_collapse`)*
- [x] Row 6, `untl` arm: the same at `rp` and `Formula.untl`.
      *(completed: `SharingWitnessFamily.shareClauseAt_untl_collapse`)*
- [x] Row 12: write out A3's composition as a theorem — from (C1')'s `box` conjunct
      (`box χ ∈ L i t ↔ S.bx χ = true`, `PlusWitnessFamily/Predicates.lean` 89-90) together with
      `PlusBoxFaithful` (`Predicates.lean` 195-197), derive
      `box χ ∈ S.L i t ↔ box χ ∈ S.L j v` for arbitrary `(i, t)` and `(j, v)`. Name it so the
      report can cite it as row 12's derivation. If a hypothesis A3 did not name turns out to be
      needed, record it and carry it as an explicit argument rather than weakening the statement.
      *(completed: `PlusSharingWitnessFamily.plusBox_globality` states the full three-way (C1')/(C3)
      chain, `PlusSharingWitnessFamily.plusBox_share_congr` is the named row-12 congruence; both
      hypotheses A3 named (the box conjunct and `PlusBoxFaithful`) were needed and used)*
- [x] Add one `#print axioms` line per new declaration. *(completed)*
- [x] Elaborate and capture the output. *(completed: exit 0, no errors, no warnings, no `sorryAx`;
      all four new declarations show `[propext, Classical.choice, Quot.sound]`)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: this phase assumes three new theorems suffice — two for row 6's arms, one for
row 12. That is a hypothesis read off the table, not a fact. Confirm it at implementation time by
re-reading the Derivation column of *every* row whose verdict is **COLLAPSE** and probing each cell
that names no declaration of its own; rows 5, 18 and 19 are expected to already name probe 01
declarations, and rows 1-4 likewise. If a fourth uncovered cell appears, probe it too rather than
holding to the count of three.

**Files to modify**:

- `specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/02_remaining_verdicts_probe.lean` - new; standalone probe carrying row 6's two arms and row 12's globality composition

**Verification**:

- `cd /home/benjamin/Projects/BimodalLogic && lake env lean specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/02_remaining_verdicts_probe.lean`
  exits 0 with no errors and no warnings.
- Every `#print axioms` line shows `[propext, Classical.choice, Quot.sound]` or "does not depend on
  any axioms"; **no line shows `sorryAx`**.
- `git status --short -- FormalSystem/` is empty: no Lean file in the library was touched.
- Each new theorem's statement, as it will be quoted in the report, matches the elaborated source
  verbatim (copy from the file, do not paraphrase).

---

### Phase 2: File the follow-on proposal and the unowned-documentation handoff [COMPLETED]

**Goal**: land the round's one time-critical actionable output — the follow-on that must precede
task 696 Phase 1's declaration of `trans_refl` — as a verbatim-ready payload, plus the two
documentation-ownership facts Part A generated, without writing `specs/state.json` and without
creating a task.

**Tasks**:

- [x] Create `specs/699_invariance_clause_audit_and_ockhamist_grounding/proposals/01_trans-reflexivity-residual-collapse.md`
      containing a complete, paste-ready `/task "…"` invocation with no unresolved placeholder,
      carrying: the title `trans_reflexivity_residual_collapse`, type `formal:logic`, the defect
      statement, the report's four scope steps, its non-goals, and the ordering constraint
      (`blocks: task 696 Phase 1`, because removing a declared field afterwards costs more than
      not declaring it). *(completed)*
- [x] In the same file, cite the two probe-01 declarations that evidence the defect
      (`tUntl_trans_congr`, `tSnce_trans_congr`) and the one that shows what remains once
      `trans_refl` goes (`tUntl_common_succ_congr` / `clause_shape_common_witness`), with their
      probe path — so the reader of the filed task can check the claim without re-reading the
      671-line report. *(completed)*
- [x] Record handoff item 1 (**unowned**): `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean:51-52`'s
      module docstring asserts the `untl` side is "defect-free by inspection, not by machine check",
      which row 2 refutes. State that `Incompleteness.lean` is not among task 696's fourteen
      declared `file_scope` paths, so no task owns the correction, and that this task cannot make
      it (no Lean modification; path outside this task's `file_scope`). *(completed; line ref
      re-verified by `grep -n` at write time)*
- [x] Record handoff item 2 (**owned by task 696**): the same false text at
      `PlusWitnessFamily/README.md:100-102` and the related claim at `Sharing/README.md:124`. Both
      READMEs *are* in task 696's declared paths and its Phase 0 already schedules a correction, so
      the handoff is a strengthening of that correction's content, not a new owner: per row 2 the
      `untl` collapse is same-shape rather than shifted-only, and per rows 3-4 both halves collapse
      on the `Formula` side too, which neither README records. *(completed; both line refs
      re-verified by `grep -n` at write time)*
- [x] State explicitly, in the file, that filing the task is a user/`/task` action and that no
      phase of this task writes `specs/state.json` or `specs/TODO.md`. *(completed)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:

- `specs/699_invariance_clause_audit_and_ockhamist_grounding/proposals/01_trans-reflexivity-residual-collapse.md` - new; command-ready follow-on payload plus the two documentation handoff items

**Verification**:

- The `/task` invocation is complete: no `{placeholder}`, no "TBD", and the description text stands
  alone without the report open.
- Every line reference in the file is re-verified by `grep -n` against the current tree immediately
  before writing — `Incompleteness.lean:51-52`, `PlusWitnessFamily/README.md:100-102`,
  `Sharing/README.md:124` — and corrected if the lines have moved.
- The task-696-ownership claim is re-checked against `jq '.active_projects[] | select(.project_number==696) | .file_scope' specs/state.json`
  (read-only) at write time.
- `git status --short` shows no modification to `specs/state.json`, `specs/TODO.md`, or anything
  under `FormalSystem/`.

---

### Phase 3: Make Part A's enumeration re-runnable [NOT STARTED]

**Goal**: replace the Appendix's three ad-hoc prose commands with one script and one dated output
snapshot, so a future reader can re-run the Shape-(S) enumeration against a changed tree instead of
trusting a snapshot taken on 2026-09-28.

**Tasks**:

- [ ] Create `specs/699_invariance_clause_audit_and_ockhamist_grounding/audit/enumerate-shape-s.sh`
      implementing the report's three passes: (a) every `def`/`abbrev`/`structure`/`class` under
      `FormalSystem/Metalogic/**/*.lean` whose body contains `↔`; (b) `share`-guarded quantifiers;
      (c) reflexive relations, by `_refl` lemma name and `@[refl]` attribute. Each pass emits
      `path:line` lines and a trailing count. Support `--help`. Exit 0 on success.
- [ ] Run the script and write `audit/01_enumeration-snapshot.md`: the exact invocation, the run
      date, the three counts, and each pass's full `path:line` list.
- [ ] Compare the script's counts with the report's stated figures — 67 candidate definitions
      across 40 files, 39 reflexive-relation hits — and record the comparison in the snapshot,
      including any divergence and its likely cause.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the report asserts 67 candidate definitions across 40 files and 39
reflexive-relation hits. All three are hypotheses about a tree that has changed since the report
was written. **The script's output at implementation time is the authority**: a divergence is
recorded and becomes a report correction in Phase 4, and is explicitly *not* grounds for adjusting
the script's filters until they reproduce the report's numbers. If a divergence is large enough to
change which rows belong in the table (a new Shape-(S) candidate appears), stop and report it
rather than silently absorbing it into the snapshot.

**Files to modify**:

- `specs/699_invariance_clause_audit_and_ockhamist_grounding/audit/enumerate-shape-s.sh` - new; three-pass Shape-(S) enumeration
- `specs/699_invariance_clause_audit_and_ockhamist_grounding/audit/01_enumeration-snapshot.md` - new; dated output with counts and full lists

**Verification**:

- `bash specs/699_invariance_clause_audit_and_ockhamist_grounding/audit/enumerate-shape-s.sh`
  exits 0, and its counts match those written in the snapshot file.
- Two consecutive runs produce byte-identical output (the script sorts; no unstable ordering).
- The script contains no absolute path outside the repository and performs no write, no `git`
  invocation and no `lake` invocation — it reads and prints only.
- `--help` prints usage and exits 0.

---

### Phase 4: Reconcile the report and run the no-asserted-claim pass [NOT STARTED]

**Goal**: the report is this task's deliverable; make it cite what Wave 1 produced and end the
round with no verdict or count that is neither probe-backed, source-named, nor marked unverified.

**Tasks**:

- [ ] Re-read the report immediately before editing (four sibling tasks are live on this tree).
- [ ] Part A table, row 6: replace "not separately probed" with a citation of probe 02's two
      declarations by name.
- [ ] Part A table, row 12: cite probe 02's globality composition in the Derivation cell, keeping
      the verdict INTENDED and the A3 evidence intact. If Phase 1 found a hypothesis A3 did not
      name, record it here.
- [ ] Appendix: add probe 02 to the probe table (declaration, what it establishes), with its
      elaboration command and its `#print axioms` outcome, alongside probe 01's entry.
- [ ] Appendix "Enumeration commands": point at `audit/enumerate-shape-s.sh` and
      `audit/01_enumeration-snapshot.md` in place of the inline awk/grep, and correct any count
      Phase 3 found divergent — the script's figure, not the original prose figure.
- [ ] "Follow-On Task Proposal" section: add a pointer to `proposals/01_trans-reflexivity-residual-collapse.md`,
      and add the unowned `Incompleteness.lean:51-52` docstring item. Label it a *documentation
      defect*, not a fifth collapse — the report's "four live collapses" count must not silently
      change.
- [ ] Header `Artifacts` and `Sources/Inputs` lines: list probe 02, the enumeration script, the
      snapshot and the proposal file.
- [ ] Final consistency pass: walk every row of Part A's table and confirm each **COLLAPSE** cell
      names a probe declaration and each **INTENDED** cell names its specific semantic evidence;
      walk Part B and confirm every claim either names a source `doc_id` plus chunk/section or is
      marked unverified. Record the pass and its outcome as one line under Decisions.
- [ ] Confirm the Executive Summary's soundness paragraph survived editing verbatim.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3

**Verification Tier**: local

**Files to modify**:

- `specs/699_invariance_clause_audit_and_ockhamist_grounding/reports/01_invariance-clause-audit-ockhamist-grounding.md` - edit in place: row 6 and row 12 cells, appendix probe and enumeration tables, follow-on pointer and docstring handoff, header artifact lines, one Decisions addendum

**Verification**:

- `grep -n "not separately probed" specs/699_invariance_clause_audit_and_ockhamist_grounding/reports/01_invariance-clause-audit-ockhamist-grounding.md`
  returns nothing.
- Every declaration named in the appendix probe tables exists in a file under this task's
  `probes/`, confirmed by `grep -n` per name.
- The report's enumeration counts equal the snapshot's counts.
- The report's "four live collapses" claim in the Executive Summary is unchanged, and the new
  docstring item is filed as a documentation defect rather than counted as a collapse.
- The soundness paragraph is present and unaltered.
- `git status --short` lists only paths under `specs/699_invariance_clause_audit_and_ockhamist_grounding/`.

## Testing & Validation

- [ ] Both probes elaborate: `lake env lean` on `probes/01_clause_shape_collapse_probe.lean` and
      `probes/02_remaining_verdicts_probe.lean`, exit 0 each, no `sorryAx` in any `#print axioms`
      line. (Probe 01 is re-run as a regression check that the library it reads against has not
      drifted; if it now fails, that is a finding about the tree, not about this plan, and must be
      reported rather than patched around.)
- [ ] `bash specs/699_invariance_clause_audit_and_ockhamist_grounding/audit/enumerate-shape-s.sh`
      exits 0 and is idempotent across two runs.
- [ ] **No library modification**: `git status --short -- FormalSystem/` is empty.
- [ ] **No bookkeeping modification by this task**: `git status --short -- specs/state.json specs/TODO.md specs/ROADMAP.md`
      shows nothing attributable to this task's phases. (The orchestrator's own status-sync writes
      `state.json`/`TODO.md`; no phase here does.)
- [ ] **Territory**: every path in `git status --short` that this task produced sits under
      `specs/699_invariance_clause_audit_and_ockhamist_grounding/`.
- [ ] Every commit stages an explicit file list. No `git add -A`, no `git add .`, no directory or
      glob pathspec — four sibling tasks are live on this working tree this cycle.
- [ ] `git diff --staged` reviewed before each commit.

## Artifacts & Outputs

- `probes/02_remaining_verdicts_probe.lean` — row 6's two `Formula`-side decision-mirror collapses
  and row 12's (C3) globality composition, elaborated, axiom-clean.
- `proposals/01_trans-reflexivity-residual-collapse.md` — the paste-ready `/task` payload for the
  one Part A finding task 696's plan does not repair, plus the unowned `Incompleteness.lean`
  docstring handoff and the strengthening task 696's README correction needs.
- `audit/enumerate-shape-s.sh` — re-runnable three-pass Shape-(S) enumeration.
- `audit/01_enumeration-snapshot.md` — dated output, counts, full `path:line` lists, comparison
  against the report's figures.
- `reports/01_invariance-clause-audit-ockhamist-grounding.md` — updated in place; every COLLAPSE
  verdict probe-backed, every count script-backed, the follow-on and the docstring handoff filed.

## Rollback/Contingency

Each phase commits on its own, so rollback is per-phase `git revert` of that phase's commit —
never a working-tree discard, because four sibling tasks share this tree and their uncommitted work
must not be caught in it. Phases 1-3 only add new files under this task's directory, so reverting
them removes artifacts and leaves the report exactly as the research round wrote it. Phase 4 is the
only phase that edits an existing file; its commit is a single-file change to the report, so
reverting it restores the research-round text intact.

If a checkpoint is wanted before Phase 4's in-place edit, use
`bash .claude/scripts/git-snapshot.sh 699 --no-revert` — durable and non-reverting. **Do not** call
`git-snapshot.sh` in its default reverting mode: siblings 695, 697, 698 and 700 are live on this
tree and a default-mode call would revert their uncommitted work.

If Phase 1's row-12 composition cannot be made to elaborate, the contingency is to record the
missing hypothesis in row 12's cell (Phase 4 already has that step) and keep the INTENDED verdict,
which does not depend on the composition. If Phase 3's counts diverge enough to change the table's
membership, stop after Phase 3 and report: a new Shape-(S) candidate is a Part A finding, not a
reconciliation detail.
