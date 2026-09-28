# Implementation Plan: Task #682

- **Task**: 682 - Stability decidability provenance gate
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: `specs/682_stability_decidability_provenance_gate/reports/01_stability-decidability-provenance-gate.md`
- **Artifacts**: plans/01_stability-decidability-provenance-gate.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/no-task-references-in-deliverables.md
  - .claude/rules/source-store-deploy-boundary.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The task's own deliverable — the three-verdict report — is already written and linked. What this
plan executes is the follow-through the report's Recommendations section hands on, restricted to
the targets the task's scope constraint admits: **no changes to `FormalSystem/` or `Tests/`**.
Four of the report's five recommendations land inside that constraint (the archived probe repair,
the corpus-entry disambiguation, and the two documentation notes); the fifth (the L-plus carrier
normalization) is squarely a `FormalSystem/` change and is carried as a Non-Goal.

The plan's spine is the bit-rot finding, which the report flags as load-bearing for the whole
citation chain: as stored, `Probe476.fmp_false` no longer elaborates and `#print axioms` reports
`sorryAx`, while five files under `FormalSystem/Metalogic/Decidability/` cite it as a
machine-refutation. Phase 1 lands the one-term repair; Phase 2 wires the probe into the existing
`scripts/check-evidence-probes.sh` guard so the same drift cannot recur silently. Phases 3 and 4
record the provenance findings where a future reader will actually meet them.

### Research Integration

Every phase below traces to a numbered recommendation in the research report:

- **Recommendation 2** (repair or annotate the archived probe) -> Phases 1 and 2. The report
  supplies the repair verbatim: at the probe's line 70, `TaskFrame.isZTime_of_instances _` must
  become the pair `⟨S.frame_isRegular, TaskFrame.isZTime_of_instances _⟩`, because the probe
  predates `FrameClass.Sat .ZTime` becoming the conjunction `IsRegular ∧ IsZTime`. The report
  records the repaired axiom list as `[propext, Classical.choice, Quot.sound]`.
- **Context Extension Recommendation 2** (author-year id stems) -> Phase 3, plus the narrative
  half in Phase 4. The report establishes that the sub-index hazard on `thomas_1997` attaches to
  a *different document* (`sources/thomas_1997/…EF_Games_Composition_Monadic.md`) than the one
  the citation chain now rests on (`thomas_1997_languages_automata`).
- **Recommendation 1** (the discharged citation licence) and **Context Extension Recommendation
  1** (finite *model* vs finite *presentation*) -> Phase 4.
- **Recommendations 3 and 4** -> Non-Goals below; neither is actionable inside this task's scope.

Two findings from the report shape the plan more than they show up in any single phase. First,
Verdict 1 is a provenance result and not a decidability result — every documentation sentence
written in Phase 4 must say so, because the report names "Verdict 1 is read as 'the target is now
known decidable'" as its first risk. Second, Verdict 3's negative is *stronger* than
"unobtained": a finite-model certificate is refuted, and the only certificate shape the held
literature offers is a finite *generator* for an infinite regular model.

### Prior Plan Reference

No prior plan. This is the first plan round for this task.

### Roadmap Alignment

`specs/ROADMAP.md` exists but no `roadmap_path` was supplied in this dispatch and no roadmap flag
was set, so no roadmap consultation was performed and no roadmap phases are included. The plan
writes nothing to ROADMAP.md.

## Goals & Non-Goals

**Goals**:
- Restore `Probe476.fmp_false` to a sorry-free elaborating state, so the five
  `FormalSystem/Metalogic/Decidability/` sites that cite it as machine-refuted are telling the
  truth about the file on disk.
- Put that probe under the same automated rot guard the repository's other evidence probes
  already have, so this specific failure cannot recur unannounced.
- Make the two Thomas 1997 corpus entries individually identifiable in
  `specs/literature-index.json`, with the existing hazard bound to the entry it actually
  describes.
- Record, in the durable documentation store, (a) the exact form in which the MSO decidability
  argument may now be cited and the form in which it may not, and (b) the finite-model /
  finite-presentation distinction the report identifies as the propagating conflation.

**Non-Goals**:
- Any edit under `FormalSystem/` or `Tests/` — excluded by the task description. This rules out
  the report's Recommendation 4 (generalizing `Semantics.TruthCorr` from `Formula` to
  `PlusFormula` and deriving `plusValidZTime_iff_plusValidInt`) and any in-tree
  `Decidability/README.md` change.
- Relocating the probe to `specs/evidence/`. The repository's own probe convention would prefer
  that, but three files outside this task's writable scope cite the probe by its archive path
  verbatim (`WitnessFamily/README.md:51`, `BiLasso/README.md:34`, `BiLasso/Assembly.lean:26`), so
  a move cannot be completed here. Phase 2 guards the probe where it stands instead and records
  why.
- Deciding whether the downstream stability-modal design tasks should be started. The research
  dispatch already surfaced that as a non-blocking user decision with a recommendation
  ("construct a decision procedure", not "formalize a known-decidable target"); this plan neither
  re-asks it nor acts on it, and creates no downstream tasks.
- Running `deploy-headless.sh`. See Phase 4's rationale.
- Renaming the `Probe476` namespace, notwithstanding that it embeds a task number: the five
  citation sites that would have to move with it are outside this task's writable scope.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The one-term repair elaborates but the probe's *result* has silently weakened (e.g. a hypothesis quietly strengthened to make it pass) | H | L | Phase 1 verifies the statement of `fmp_false` is byte-identical before and after, and checks `#print axioms` output explicitly rather than trusting exit status |
| Changing `check-evidence-probes.sh` breaks the five probes it already guards | M | M | Phase 2 records the script's output *before* the edit and requires the same five PASS lines afterwards; the change is additive (a new path form), not a rewrite of the existing loop |
| A sibling dispatch is editing the shared working tree concurrently | M | H | Two sibling implement dispatches are live this cycle (`scripts/check-module-invariants.sh`, `scripts/nolints-style.txt`; and five `FormalSystem/`/`BimodalTools/` files). None overlaps this plan's targets. Re-read every file immediately before editing; stage only this task's own hunks with an explicit file list; never a directory or glob pathspec |
| A Phase 4 note is written under `.claude/**` and is wiped by the next deploy | M | M | `.claude/` here is a deploy artifact (it is gitignored at `.gitignore:106`). Phase 4 edits the source store under `/home/benjamin/.config/nvim/agent-system/extensions/` only, per `source-store-deploy-boundary.md` |
| Phase 4's prose is read as asserting decidability | H | M | The report names this as its first risk. Every Phase 4 sentence must pair the licence with its limit: the theorem is citable, the conclusion is not established, four of five steps are uncompiled |
| A Phase 4 file cites a task number and trips the deliverable lint | L | M | `.claude/**` and the source store are outside `specs/**`, so `no-task-references-in-deliverables.md` applies. Cite `Probe476.fmp_false`, `thomas_1997_languages_automata`, and Thomas's theorem numbers — never a task or report number |
| `lake env lean` on the probe is slow enough to look hung | L | M | It is a single file outside the build graph against an already-built tree. If backgrounded, follow `context/patterns/bounded-build-waiter.md` (hard timeout, `kill -0` on the captured PID) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2, 4 | 1 (for 2); 3 (for 4) |
| 3 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Repair the archived `fmp_false` evidence probe [COMPLETED]

**Goal**: `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`
elaborates cleanly and `#print axioms fmp_false` reports `[propext, Classical.choice, Quot.sound]`
with no `sorryAx`, with the cause of the drift recorded in the file itself.

**Tasks**:
- [x] Re-read the probe file in full (a sibling may have touched the tree since this plan was
      written) and record the current `lake env lean` output verbatim, so the before-state is on
      the record rather than taken from this plan.
- [x] Capture the exact source text of the `fmp_false` statement (from `theorem fmp_false` through
      the end of its type) so it can be compared byte-for-byte after the repair.
- [x] Apply the one-term repair inside `not_validZTime_neg_psi`: replace the bare
      `TaskFrame.isZTime_of_instances _` witness with the pair
      `⟨S.frame_isRegular, TaskFrame.isZTime_of_instances _⟩`, which is what
      `FrameClass.Sat .ZTime = IsRegular ∧ IsZTime` now requires. Change nothing else in the proof
      body.
- [x] Update the file's header docstring: correct the stale compile-check path (it still names
      `specs/476_box_faithful_small_model_theorem/…`, but the file now lives under
      `specs/archive/…`), and add a short drift note giving the cause (the probe predates the
      `Sat .ZTime` conjunction split), the repair, and the re-verified axiom list with its date.
- [x] Confirm the captured `fmp_false` statement text is unchanged by the repair.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean` —
  one term in `not_validZTime_neg_psi`; header docstring path correction and drift note

**Verification**:
- `lake env lean specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`
  exits 0 with no `synthInstanceFailed` and no error output.
- The same run's `#print axioms fmp_false` line reads exactly
  `'Probe476.fmp_false' depends on axioms: [propext, Classical.choice, Quot.sound]` — the check is
  on this printed line, not on exit status alone, since the pre-repair file also produced output.
- A diff of the `theorem fmp_false` statement before and after is empty: the repair must restore
  elaboration without weakening what is refuted.
- `git diff --stat` shows exactly one file changed.

---

### Phase 2: Wire the probe into the evidence-probe rot guard [COMPLETED]

**Goal**: `scripts/check-evidence-probes.sh` compile-checks the repaired probe alongside the five
it already guards, so a future API drift fails loudly instead of leaving a `sorryAx` behind five
citations.

**Tasks**:
- [x] Re-read `scripts/check-evidence-probes.sh` in full, and record its current output
      (`bash scripts/check-evidence-probes.sh`) as the before-state, including which entries PASS.
- [x] Extend the probe loop to accept an explicit repository-relative path entry in addition to
      the existing entries relative to `specs/evidence/`. Keep the existing collection-relative
      entries working unchanged — this is an additive path form, not a rewrite.
- [x] Add the probe as a guarded entry, with its row in the WIRED table comment naming the
      decision it holds in place: the finite model property fails at ZTime for every candidate
      list, which is why the decision layer presents finite *generators* of infinite regular
      models rather than searching finite models.
- [x] Add a short comment beside the new entry recording why this one probe does not live under
      `specs/evidence/` as the script's header prescribes: three files under
      `FormalSystem/Metalogic/Decidability/` cite its archive path verbatim, and those files are
      outside this task's writable scope. Frame it as a deferred move with a named blocker, not as
      an exemption from the convention.
- [x] Re-run the script and confirm the five pre-existing entries still PASS.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that exactly one file changes
(`scripts/check-evidence-probes.sh`) and that the guard currently wires exactly five probes with
one deliberately deferred. Both are hypotheses read off the script at plan time. Confirm at
implementation time by re-reading the `WIRED`/`DEFERRED` arrays and by comparing the script's
before/after output line-for-line; if the count differs, take the observed count and say so
rather than forcing the plan's number.

**Files to modify**:
- `scripts/check-evidence-probes.sh` — additive path form in the probe loop; one new guarded
  entry; WIRED table comment row; deferred-move note

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0.
- Its output lists the newly wired probe as PASS, and every entry that passed in the before-state
  still passes — compared line-for-line against the captured before-state, not judged by exit
  status alone.
- A deliberate temporary break (revert the Phase 1 term repair in a scratch copy, point the guard
  at it) makes the script exit 1 and name that probe. This confirms the guard actually guards;
  restore immediately afterwards and confirm the tree is clean.
- `scripts/check-evidence-probes.sh` is not in any sibling dispatch's declared file scope — re-read
  `git status --short scripts/` immediately before staging to confirm no foreign modification.

---

### Phase 3: Disambiguate the two Thomas 1997 entries in the repository sub-index [COMPLETED]

**Goal**: `specs/literature-index.json` carries a distinct entry for
`thomas_1997_languages_automata`, and the existing `thomas_1997` hazard names the file it actually
describes, so a reader matching on "Thomas 1997" cannot pull the wrong fidelity verdict.

**Tasks**:
- [x] Re-read the current `thomas_1997` entry and confirm the sub-index schema in use
      (`doc_id`, `reason`, optional `citation_rule`, `hazard`, `known_corrections`, `audits`).
- [x] Add an entry for `thomas_1997_languages_automata` recording: it is the held source for the
      Rabin Tree Theorem (Thm 6.20), the countable-branching extension stated immediately after
      it, and the Rabin Basis Theorem (Thm 6.18); `provenance_fidelity: verified_conversion`, with
      a source PDF present.
- [x] Give that entry a `citation_rule` mandating citation by theorem number and section, never by
      markdown line number, and recording the conversion's cosmetic ligature drop (`fi`/`fl`
      dropped, so "finite" reads "nite" and "definable" reads "denable"; citation keys render with
      a trailing bracket only). State that the cited passages were re-extracted from the PDF
      independently.
- [x] Amend the existing `thomas_1997` hazard so its opening clause names its own file
      (`sources/thomas_1997/Thomas_1997_EF_Games_Composition_Monadic.md`) and states explicitly
      that the hazard does not attach to `thomas_1997_languages_automata`.
- [x] Update the sub-index `updated` field.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `specs/literature-index.json` — one new entry; `hazard` text amended on the existing
  `thomas_1997` entry; `updated` bumped

**Verification**:
- The file parses as JSON and the entry count increases by exactly one.
- Both `thomas_1997` and `thomas_1997_languages_automata` resolve to distinct `id` records in the
  global index at `~/Projects/Literature/index.json`, with the paths the report records.
- `bash .claude/scripts/…` literature validation (the `--validate` path documented for
  `/literature`) reports no unresolved sub-index ids; if that entry point is unavailable in this
  deploy, substitute a direct id-resolution check against the global index and say which was run.
  *(deviation: altered — no standalone sub-index validator exists in this deploy; the dangling-ref
  lint is reachable only as Job 1 of the interactive `/literature --rebuild` mode. Substituted the
  sanctioned fallback: a direct id-resolution check of all 77 sub-index `doc_id`s against
  `~/Projects/Literature/index.json`, which reported 0 unresolved.)*
- Reading the amended `thomas_1997` hazard in isolation, without the new entry beside it, still
  makes clear which document it is about.

---

### Phase 4: Record the citation licence and the certificate vocabulary in the source store [COMPLETED]

**Goal**: the discharged citation licence and the finite-model / finite-presentation distinction
are written where a future dispatch will meet them, in the extension source store rather than in
the disposable deployed tree.

**Tasks**:
- [x] Resolve the source store from `.claude-extensions.json` and confirm the two target
      directories exist before writing:
      `…/agent-system/extensions/lean/context/project/lean4/domain/` and
      `…/agent-system/extensions/literature/context/project/literature/domain/`.
- [x] Add a decidability-provenance note under the lean extension's `domain/` directory covering
      two things. First, the citation licence: the MSO route's appeal to Rabin's theorem may be
      cited as Thomas, *Languages, Automata, and Logic* (1997), §6.3 Theorem 6.20, with the
      countable-branching sentence immediately following and a self-contained proof in §6.1-6.2 —
      and, in the same breath, that citing the *conclusion* as established is not sanctioned,
      because four of the argument's five steps are uncompiled. Second, that the frame-class
      assumption (`D` exactly the integers, histories exactly the bi-infinite walks) is
      machine-checked for the modal-only language and is not yet landed for the language with the
      stability modal.
- [x] In the same note, fix the two terms the report identifies as conflated: a finite *model*
      certificate is refuted outright by `Probe476.fmp_false`; a finite *presentation* — a finite
      generating automaton for an infinite regular model, Thomas Theorem 6.18 — is the shape that
      remains available and the shape the existing decision-layer device already respects. Record
      that Thomas's own text calls the latter "the finite model property", which is how the
      conflation propagates.
- [x] Record that no complexity bound is inherited in either direction: the MSO-to-automaton
      conversion is not elementarily bounded (Meyer-Stockmeyer, via the same chapter), the held
      corroborating source calls the tree route's complexity unclear, and no lower bound for this
      language is held.
- [x] Register the new file wherever the lean extension's `manifest.json` enumerates its provided
      context files, so a deploy copies it. Re-read the manifest's existing `provides` shape first
      and match it exactly. *(deviation: altered — the manifest's `provides.context`
      enumerates DIRECTORIES (`project/lean4`, `contracts`), not individual files, so a deploy
      already copies the new note and no manifest edit was needed. Registered it instead in the
      two places that do enumerate files: `lean/index-entries.json` (the context-discovery
      index) and `context/project/lean4/README.md` (the Key Files list).)*
- [x] Add a short subsection to the literature extension's `literature-index.md`: corpus ids are
      matched whole and never by author-year stem, and a hazard attaches to an id rather than to
      an author-year. Use the two Thomas 1997 entries as the worked example, naming both paths.
- [x] Re-read every file written in this phase and confirm no task number, report number, or
      `specs/{NNN}_…` task-directory path appears: these paths are outside `specs/**`, so
      `no-task-references-in-deliverables.md` applies. Cite declaration names, corpus ids,
      theorem numbers, and `specs/archive/…` evidence paths instead.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts two new or amended source-store markdown files plus one
manifest registration. The manifest count is a hypothesis — the lean extension may register
context files by directory glob rather than by individual path, in which case no manifest edit is
needed at all. Confirm by reading the manifest's `provides` block before editing, and report the
actual file count touched rather than this plan's estimate.

**Files to modify**:
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/context/project/lean4/domain/` — new
  decidability-provenance note
- `/home/benjamin/.config/nvim/agent-system/extensions/lean/manifest.json` — register the new
  context file, if and only if the manifest enumerates context files individually
- `/home/benjamin/.config/nvim/agent-system/extensions/literature/context/project/literature/domain/literature-index.md`
  — new subsection on whole-id matching and hazard attribution

**Verification**:
- `manifest.json` parses as JSON after any edit, and the new path appears in the same block and
  the same shape as its neighbours.
- `bash .claude/scripts/check-task-references.sh` (or the repository-wide equivalent) reports no
  new findings for the written paths.
- Every claim in the new note traces to a passage or a declaration the research report cites by
  name; no sentence asserts decidability of the target.
- Nothing was written under `.claude/**`: `git status --short` shows no change there, and the
  deployed tree is untouched.
- **`deploy-headless.sh` is NOT run in this phase.** The deployed tree is already flagged stale
  for three extensions, so a redeploy would land unrelated pending source-store changes across the
  whole tree while two sibling implement dispatches are in flight on it. Record the redeploy as a
  carried-forward follow-up in Phase 5 instead.

---

### Phase 5: Close out and record the carried-forward items [COMPLETED]

**Goal**: the full gate set is green over everything this plan changed, and the items this task's
scope could not absorb are recorded explicitly rather than left implicit.

**Tasks**:
- [x] Run the repository's full gate set and record the result verbatim, including
      `bash scripts/check-evidence-probes.sh`.
- [x] Confirm no file under `FormalSystem/` or `Tests/` was modified by this task, as the task
      description requires: `git status --short` and `git diff --stat` over the task's own commits.
- [x] Record the carried-forward items in the execution summary, each with the reason it is not
      done here: (i) the stability-modal carrier normalization — generalize the generic truth
      transport from the modal-only formula type to the stability-modal one, then the
      integer-carrier normalization follows the existing proof line — blocked here by the
      no-`FormalSystem/` constraint, and sized in the report as a sorry-free target; (ii)
      redeploying the extension tree to pick up the Phase 4 notes; (iii) the still-open question of
      whether and how the downstream design line should be started, already surfaced by the
      research dispatch with a recommendation and not re-asked here; (iv) the deferred move of the
      probe into `specs/evidence/`, blocked by the three citation sites outside this task's scope.
- [x] Confirm the plan's phase markers and the task's records agree with what actually landed.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Files to modify**:
- `specs/682_stability_decidability_provenance_gate/plans/01_stability-decidability-provenance-gate.md`
  — phase status markers
- `specs/682_stability_decidability_provenance_gate/summaries/01_*-summary.md` — execution summary

**Verification**:
- The full gate set exits green, with the output recorded rather than summarized.
- `git diff --stat` over this task's commits names no path under `FormalSystem/` or `Tests/`.
- Every carried-forward item names its blocker and the artifact that sizes it.

---

## Testing & Validation

- [x] `lake env lean` on the repaired probe exits 0 and prints the three-axiom list with no
      `sorryAx`.
- [x] The `fmp_false` statement text is byte-identical before and after the repair.
- [x] `bash scripts/check-evidence-probes.sh` exits 0, lists the new probe as PASS, and still
      passes every entry it passed beforehand.
- [x] The guard demonstrably fails on a deliberately broken copy of the probe, then the tree is
      restored clean.
- [x] `specs/literature-index.json` parses, gains exactly one entry, and both Thomas ids resolve
      against the global corpus index.
- [x] The source-store notes contain no task-number reference and assert no decidability result.
- [x] No file under `FormalSystem/`, `Tests/`, or `.claude/` is modified by this task.
- [x] The repository's full gate set is green at close-out.

## Artifacts & Outputs

- Repaired, guarded evidence probe:
  `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`
- Extended rot guard: `scripts/check-evidence-probes.sh`
- Disambiguated corpus sub-index: `specs/literature-index.json`
- Source-store documentation: a decidability-provenance note under the lean extension's
  `lean4/domain/`, and a whole-id-matching subsection in the literature extension's
  `literature-index.md`
- Execution summary under `specs/682_stability_decidability_provenance_gate/summaries/`

## Rollback/Contingency

Every change in this plan is confined to five files across four independent phases, and each phase
commits separately, so reverting one phase never disturbs another.

- **Phase 1**: revert the single commit. The probe returns to its pre-repair (non-elaborating)
  state, which is the state the tree is in today — no worse than the starting point.
- **Phase 2**: revert the guard commit. The five pre-existing probes continue to be checked; only
  the new entry is lost. If the additive path form turns out to conflict with how the loop resolves
  entries, fall back to the report's minimum for Recommendation 2 — a header annotation on the
  probe recording the drift and the repair, with no guard change — and record that the guard
  extension was attempted and why it was dropped.
- **Phase 3**: revert the JSON commit. Both entries return to the current single-entry state; the
  hazard mis-attribution returns with it, so re-record it as an open item if this happens.
- **Phase 4**: revert the source-store commits. The source store is a separate repository from this
  one, so its rollback is independent; nothing under `.claude/**` was written, so the deployed tree
  needs no repair either way.

If a sibling dispatch is found to have modified any file this plan targets, stop and report it
after checking `git log` to confirm the work is not this task's own — do not proceed and do not
dismiss it as noise.
