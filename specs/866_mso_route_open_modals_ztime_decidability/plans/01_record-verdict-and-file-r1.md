# Implementation Plan: Task #866

- **Task**: 866 - MSO route: do the open modals ride the encoding that decides L⁺ validity at ZTime?
- **Status**: [COMPLETED]
- **Effort**: 1.75 hours
- **Dependencies**: None
- **Research Inputs**: `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`
- **Artifacts**: plans/01_record-verdict-and-file-r1.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal
- **Lean Intent**: false

## Overview

The task's own deliverable — a report carrying the verdict on whether `▷`/`◁` ride report 03
section 1.3's MSO encoding — is already written and linked in `state.json`. The verdict is YES at
step 4, with an amendment at step 1 and two pre-existing gaps located in report 03's own
argument. What remains is **propagation, not discovery**: the three findings that correct or
qualify another live record (report 03 section 1.3) have to reach that record, and the one
recommendation the research cycle already decided to act on (R1, the `▷`/`◁` invariance lemma)
has to be made filing-ready where the batch order is read. No Lean work, no formalization, and no
new mathematical claim: every phase below edits `specs/**` markdown only.

This plan deliberately does **not** plan the MSO decidability proof. The report's finding 8 settles
that cost (Mathlib has DFA/NFA/regular expressions and no MSO, no ω-automata, no Rabin tree
theorem), and recommendation R2 is an explicit do-not-file.

### Research Integration

Four findings drive the phases below:

- **Finding 3 (derived)**: in the `(P, x)` encoding the `▷` restriction is the single first-order
  conjunct `∀y (y ⊑ x → (y ∈ P ↔ y ∈ P'))` over directed reachability `⊑`, adding no quantifier
  alternation over what `⊡` already pays; `◁` is the mirror. This is the verdict, and report 03
  has no record of it.
- **Finding 4 (derived)**: the cover step carries `▷`/`◁`, because the lifted witness reuses the
  given history's past verbatim and so needs one-sided lifting only — a strictly weaker obligation
  than the compiled `⊡` case of `plus_invariance`. This is what makes R1 cheap.
- **Finding 5 (derived)**: step 1's "one witness per (state, diamond subformula)" economy is
  **unsound** for any modal whose witness is not state-local. Countability survives under
  (walk, time, subformula) indexing; the economy does not. This is a correction to report 03, not
  a qualification of it, and it is the single most important thing to propagate.
- **Finding 6 (derived)**: gaps G1 (step 1's induction scope — the fixpoint between the witness set
  `W` and the sub-digraph `G'` it determines) and G2 (section 1.2 yields a forest, step 5 applies
  Rabin to one tree). Both pre-exist for `⊡` and neither is caused by the open modals.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided to this dispatch, so `specs/ROADMAP.md` was not consulted as
delegation context. It is nonetheless a **file target** of Phase 2, because the settled decision
recorded in `.decisions.json` routes R1's filing there explicitly ("file R1 now as a separate Lean
task … deferred to the Conclusion stage as a roadmap proposal rather than created mid-loop"), and
because the roadmap's own Stage 2 line for `867` instructs a future reader to weigh that task
against this task's verdict — an instruction that is now answerable. Phase 2 reads the current
roadmap state immediately before editing rather than relying on anything stated here.

## Goals & Non-Goals

**Goals**:

- Land the three propagable findings (open-modal accommodation, the unsound witness economy, gaps
  G1/G2) into report 03 section 1.3, so that the per-state economy is not relied on again and the
  next attempt at the MSO route starts at G1.
- Make R1 filing-ready: a named, scoped, cost-estimated proposal sitting where the batch order is
  read, with its independence from G1/G2/Rabin/Gabbay/the ladder stated.
- Record that the MSO route reaches **ZTime only**, and that it does not close
  `Decidable (PlusValidZTime φ)` — which remains Stage 1's own aim.
- Leave every touched record consistent with the four dispatch guardrails (no verification claim,
  no finite model property, no conflation with the landed base-language decidability, Base/Dense/
  RTime still open with the obstruction at report 03 section 1.4).

**Non-Goals**:

- Formalizing anything in Lean. R1 is *proposed*, not executed; this task files no `.lean` edit.
- Repairing G1 or G2. Both are report 03's own gaps; G1 is a research project (report
  recommendation R4, explicitly "not now").
- Verifying report 03 section 1.3. It stays a paper argument, unverified, and this task does not
  change that.
- Formalizing the MSO/Rabin step (report recommendation R2: do not file).
- Creating the R1 task record directly in `state.json`/`TODO.md`. The settled decision defers
  creation to the conclusion stage; Phase 2 produces the proposal, not the task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Report 03's directory is archived mid-flight (task `864` precedes the next `/todo`, and `559` is a completed task pending archival) | M | L | Phase 1 resolves the path at execution time: check `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` first, then `specs/archive/**` for the same basename. Edit whichever exists; if both, the live tree wins and the discrepancy is recorded as an issue |
| Sibling task `864` (plan phase, same cycle, undeclared `file_scope`) also touches `559`'s directory — its stated job is porting the LC schema out of `559`'s probe before archival | M | M | Re-read the target file immediately before editing; stage only this task's own hunks with an explicit file list; if a foreign commit or foreign uncommitted modification to `559`'s tree appears, STOP and report per the dispatch's territory note rather than proceeding |
| Sibling task `868` (the L^▷ transfer corollaries) also edits `specs/ROADMAP.md` | M | M | Same re-read-immediately-before-edit discipline in Phase 2; the edit is additive and section-local, so a sibling's edit elsewhere in the file does not conflict |
| `roadmap-integration.sh --regenerate` discards authored content after the `**Coverage appendix (uncovered tasks)**:` marker *within the run-order section* | H | L | Phase 2 edits only `## Next batches` (Stage 2) and, if needed, the Stage-1 gating prose above `## Run these next` — never below that marker inside the run-order section. The roadmap's own Maintenance section states `--regenerate` retains every other `## ` section byte-for-byte |
| The Phase 3 full gate run reports failures caused by the pre-existing `core` extension staleness this dispatch was warned about, not by this task | M | M | Capture the gate result and attribute every failure by path. This plan touches `specs/**` only, where gate 3 (doc-lint) has no bearing and gate 4 (task-reference lint) is exempt by design, so no gate outcome can be attributable to it. A pre-existing failure is recorded as such, not repaired here, and not reported as this task's regression |
| The amendment is read as establishing decidability of L^▷ at ZTime | H | M | Every added paragraph carries its evidence tier, and the amendment states in its own first sentence that section 1.3 remains an unverified paper argument with G1 live inside it |
| The R1 proposal is read as gated on the MSO route | M | M | The proposal states R1's independence explicitly: it needs none of G1, G2, Rabin, Gabbay separation (`SeparationOver TaskFrame.IsZTime`), or the ladder/`RaySummary` front |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint files
(`559`'s report 03 versus `specs/ROADMAP.md`) and share no content dependency.

### Phase 1: Amend report 03 section 1.3 with the open-modal accommodation, the witness-economy correction, and gaps G1/G2 [COMPLETED]

**Goal**: Report 03 section 1.3 carries, in its own text, (a) that `▷`/`◁` are accommodated by
step 4, (b) that step 1's per-state witness economy is unsound for any modal whose witness is not
state-local, and (c) gaps G1 and G2 — each labelled by evidence tier and pointing at this task's
report for the derivations.

**Tasks**:

- [x] Resolve the target path: `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`, falling back to the same basename under `specs/archive/**` if the directory has been archived. Record which path was used *(completed: live path used, not archived)*
- [x] Read section 1.3 in full plus section 1.4's first paragraph, so the amendment is written against the current text rather than against this plan's description of it *(completed)*
- [x] Append a clearly-delimited amendment block at the end of section 1.3, immediately before the section 1.4 heading, opening with one sentence stating that section 1.3 remains an unverified paper argument and that gap G1 below is live inside it *(completed)*
- [x] In that block, record the step-4 accommodation: the `▷` translation clause, the `◁` mirror, the first-order character of the `⊑` restriction (no transitive-closure quantifier, no new quantifier alternation over `⊡`'s), and the component-locality of `▷`/`◁` against `□`'s forest-wide range. Label *derived* *(completed)*
- [x] In that block, record the step-1 correction as a correction: "one witness per (state, diamond subformula)" is unsound for any modal whose falsifying witness is not state-local; countability survives under (walk, time, subformula) indexing; the economy does not. Label *derived* *(completed)*
- [x] In that block, record G1 (step 1's induction must hold at every walk of `G'`, but witnesses were chosen only for walks in `W`, and `G'` depends on `W` — the fixpoint is not obviously reached) and G2 (section 1.2 yields countably many trees; step 5 applies Rabin to one; the standard new-root coding repairs it), each with the explicit statement that both pre-exist for `⊡` and neither is caused by the open modals. Label *derived* *(completed)*
- [x] Add the pointer to `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md` findings 3-6 for the derivations, and state that the MSO route reaches ZTime only, leaving section 1.4's Base/Dense/RTime obstruction untouched *(completed)*
- [x] Re-read the amended region and confirm no sentence claims the finite model property, claims section 1.3 is verified, or conflates the route with the landed base-language `decidableValidZTime` / `decidableDerivableZTime` *(completed)*
- [x] Commit, staging only the one resolved report path by explicit file list *(completed)*

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: the single touched path lies under `specs/**`, where `suite_selection_select` returns `__FULL_SWEEP__` and no suite covers the file, so the honest covering check is `bash .claude/scripts/validate-artifact.sh <resolved-path> report` together with the `prose` row's diff read-through confirming every changed hunk is prose inside section 1.3.

**Files to modify**:

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` - append an amendment block at the end of section 1.3 (path resolved at execution time; may be under `specs/archive/**` instead)

**Verification**:

- `bash .claude/scripts/validate-artifact.sh <resolved-path> report` exits 0
- Diff read-through: every changed hunk is additive prose located between the end of section 1.3's existing body and the `#### 1.4` heading; no existing sentence of section 1.3 is deleted or reworded
- `grep -n "▷\|◁"` on the amended file returns matches only inside the new block
- Each of the three recorded items carries an explicit evidence tier and the pointer to this task's report

---

### Phase 2: Record the ZTime-only verdict and the filing-ready R1 proposal in specs/ROADMAP.md [COMPLETED]

**Goal**: The roadmap states this task's verdict where the batch order is read, and carries R1 as a
filing-ready proposal — named, scoped, cost-estimated, and with its independence stated — so the
conclusion stage or the user can file it with one `/task` call.

**Tasks**:

- [x] Re-read `specs/ROADMAP.md` immediately before editing: the Stage-1 gating prose above `## Run these next`, the Stage 2 block inside `## Next batches` (including the `867` line that says to weigh it against this task's verdict), and `## Not scoped as tasks` *(completed)*
- [x] Confirm, by locating the `**Coverage appendix (uncovered tasks)**:` marker, that no planned edit falls after it inside the run-order section *(completed: marker at line 175 pre-edit, unchanged)*
- [x] Record the verdict in the Stage-1 gating prose that currently frames this task as a pending measurement: `▷`/`◁` do ride step 4's encoding; the route is independent of Gabbay separation and of the ladder front; it reaches ZTime only; it is a paper result and is **not** being formalized; and it does not close `Decidable (PlusValidZTime φ)`, which remains Stage 1's own aim *(completed)*
- [x] Update the Stage 2 annotation on `867` (Gabbay separation) so that the "weigh against this task's verdict first" instruction is answered rather than left pending: the MSO route makes `SeparationOver TaskFrame.IsZTime` unnecessary *for the decidability question only*, while the `tr` translation keeps its independent expressiveness value *(completed)*
- [x] Add R1 as a prose proposal in the Stage 2 area (not inside the fenced `/orchestrate` block, since it has no task number yet): `▷`/`◁` truth invariance along a history-lifting morphism with ray-agreement lifting; the shape (a ray-agreement lifting field beside `HistMap.lift`, its `◁` mirror, their ZTime derivation from `TwoWayBounded.step`/`forth` via the existing forward/backward sequence machinery, and an `open_invariance` theorem over `OpenFormula` reusing `plus_invariance`'s cases); the estimate carried from the report; and its independence from G1, G2, Rabin, Gabbay separation and the ladder/`RaySummary` front *(completed)*
- [x] Record R2 as a do-not-file with its reason (Mathlib has no MSO, no ω-automata, no Rabin tree theorem — so the MSO step would mean formalizing Rabin's theorem from scratch), in `## Not scoped as tasks` or alongside the Stage 2 note, so the route is not re-proposed as a formalization target *(completed: placed alongside the Stage 2 note, outside the fenced /orchestrate block)*
- [x] Verify no added claim is one that no check can reproduce — each cites either this task's report or a compiled declaration by name *(completed)*
- [x] Commit, staging `specs/ROADMAP.md` by explicit file list only *(completed)*

**Timing**: 35 minutes

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: the single touched path is `specs/ROADMAP.md`, a non-artifact file under `specs/**` for which `suite_selection_select` returns `__FULL_SWEEP__` and `validate-artifact.sh` has no applicable type, so the covering check is exactly the `prose` row's diff read-through plus a `grep` confirming the `**Coverage appendix (uncovered tasks)**:` marker and the generated block below it are byte-identical to their pre-edit state.

**Scope Hypothesis**: R1's cost is carried from this task's report as **150-350 lines, one implementation phase** (report recommendation R1) and is not re-derived here. Confirm at execution time by re-reading that recommendation and reproducing the figure verbatim with its source named; if the report's figure differs from the one stated here, the report wins and this plan's number is the stale one.

**Files to modify**:

- `specs/ROADMAP.md` - record the verdict in the Stage-1 gating prose; answer the `867` annotation in Stage 2; add the R1 proposal and the R2 do-not-file note

**Verification**:

- Diff read-through: every changed hunk is additive or replaces a now-answered pending-measurement sentence; no `## ` section heading is added, removed or renamed
- `grep -n "Coverage appendix (uncovered tasks)" specs/ROADMAP.md` still matches, and the content from that marker to the end of the run-order section is unchanged from the pre-edit state
- The R1 proposal names the deliverable, the shape, the carried cost estimate with its source, and the independence statement
- No added sentence asserts that L^▷ ZTime decidability is established or verified

---

### Phase 3: Close-out verification and guardrail audit [COMPLETED]

**Goal**: Both edited records and this task's own report are mutually consistent, every dispatch
guardrail holds across all three, and the full gate set has been run with every failure attributed
by path to something this task did not touch.

**Tasks**:

- [x] Re-read the three records as a set: this task's report, the amended section 1.3, and the changed regions of `specs/ROADMAP.md`. Confirm they agree on the verdict's scope (step 4 yes, step 1 amended, ZTime only) and on R1/R2's dispositions *(completed: consistent)*
- [x] Audit all four dispatch guardrails across the three records: (1) nothing claims Lean verification of section 1.3; (2) nothing claims the finite model property; (3) nothing presents the landed `decidableValidZTime` / `decidableDerivableZTime` (at base `Formula`, no `⊡`) as covering `⊡` or `▷`/`◁`; (4) Base, Dense and RTime are stated open with the obstruction located at report 03 section 1.4 *(completed: all four hold, confirmed by grep)*
- [x] Confirm every claim added in Phases 1 and 2 carries an evidence tier (compiled / derived / paper / held / recalled) *(completed)*
- [x] Run `bash .claude/scripts/validate-artifact.sh specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md report` and the same on the amended report 03 *(completed: both [PASS], 0 warnings)*
- [x] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. For every failure, attribute it by path; confirm none is attributable to a file this plan touched (all under `specs/**`, where gate 3 has no bearing and gate 4 is exempt by design). Record any pre-existing failure — including anything arising from the `core` extension staleness this dispatch was warned about — as pre-existing, and do not repair it here *(deviation: this dispatch's own Batch Gate Deferral directive supersedes an independent full run here -- confirmed via suite_selection_select on both touched paths, which returned __FULL_SWEEP__ -- i.e. no scoped suite/gate exists for specs/** markdown, matching this plan's own risk-table statement. validate-artifact.sh, the actually-applicable check, was run directly above and passed; the full gate set is deferred to the once-per-batch stage per the dispatch directive)*
- [x] Confirm R1 is surfaced as the task's next step in `.return-meta.json` and the handoff summary, so the conclusion stage can file it *(completed)*
- [x] Record the phase's issue-log entries (including a `kind: win` entry if the propagation ran clean) via `issue-record.sh`, non-fatally *(completed: one win entry, one minor issue entry for the gate-scope deferral)*

**Timing**: 30 minutes

**Depends on**: 1, 2

**Verification Tier**: full

**Files to modify**:

- none - verification only; no file is edited in this phase

**Verification**:

- The complete gate set has been run in this dispatch and observed: `bash .claude/scripts/verify-deploy.sh`, with its result recorded and every failure attributed by path to a file outside this plan's touched set
- `bash .claude/scripts/validate-artifact.sh` exits 0 on this task's report and on the amended report 03
- All four guardrails confirmed, record by record, in the phase's own notes
- R1 appears in `.return-meta.json`'s `next_steps` and in the handoff `summary`

## Testing & Validation

- [x] `validate-artifact.sh` exits 0 on this task's report and on the amended report 03 *(completed)*
- [x] `specs/ROADMAP.md`'s coverage-appendix marker and generated block are unchanged *(completed)*
- [x] Every claim added to either record carries an evidence tier *(completed)*
- [x] No record asserts verification of report 03 section 1.3, the finite model property, or coverage of `⊡`/`▷`/`◁` by the landed base-language decidability *(completed)*
- [x] Base, Dense and RTime are stated open with the obstruction at report 03 section 1.4 *(completed)*
- [x] The full gate set has been run, with failures attributed by path and pre-existing ones recorded as such *(deviation: altered -- superseded by this dispatch's Batch Gate Deferral directive; suite_selection_select confirmed no scoped suite/gate exists for the specs/** files this phase touched, so validate-artifact.sh was run directly instead and the full sweep deferred to the once-per-batch stage)*

## Artifacts & Outputs

- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` — amended section 1.3 (path may resolve under `specs/archive/**`)
- `specs/ROADMAP.md` — verdict recorded, `867`'s annotation answered, R1 proposal and R2 do-not-file note added
- A completion summary under `specs/866_mso_route_open_modals_ztime_decidability/summaries/`
- No Lean file is created or modified by this plan

## Rollback/Contingency

Every change is additive markdown in two independent files, each committed in its own phase, so
rollback is per-phase and loses nothing else.

- **Phase 1 or 2 fails or must be undone**: revert that phase's single commit. The other phase is
  unaffected (disjoint files, no content dependency), and this task's report — the actual
  deliverable — is already landed and linked in `state.json` regardless.
- **Report 03's directory has been archived and the path cannot be resolved**: mark Phase 1
  `[BLOCKED]` with the searched paths recorded, and complete Phase 2, whose value does not depend
  on it. The amendment can then be filed against the archived copy later, or dropped — report
  recommendation R3 is labelled optional.
- **A sibling task's foreign edit is observed in either target**: STOP per the dispatch's territory
  note, confirm via `git log` that the work is not this task's own, and report rather than
  proceeding. Do not run `git-snapshot.sh` in its reverting default mode under concurrency.
- **The Phase 3 gate run fails on something pre-existing**: record it and complete the phase on the
  attribution argument; do not repair out-of-scope failures, and do not discard uncommitted work to
  reach a green gate.
