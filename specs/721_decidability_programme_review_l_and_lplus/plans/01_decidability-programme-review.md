# Implementation Plan: Task #721

- **Task**: 721 - Review and reconcile the decidability programme across L and L-plus
- **Status**: [IMPLEMENTING]
- **Effort**: 5.5 hours
- **Dependencies**: None (consumes the completed task 718 round, the task 706/710 probe records, and the landed `WitnessFamily/Compression/` layer; writes nothing any live task owns)
- **Research Inputs**: specs/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md
- **Artifacts**: plans/01_decidability-programme-review.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal:logic
- **Lean Intent**: false

## Overview

The research dispatch delivered Deliverables 1-3 of the task in full (the four-status inventory
by declaration name, the L-side account, and the re-ranked routes for both languages) and
*specified* Deliverables 4 and 5 without executing them. This plan executes those two
deliverables inside the task's declared `file_scope`
(`specs/721_decidability_programme_review_l_and_lplus/`, `specs/ROADMAP.md`): it re-verifies every
anchor the writes will cite, emits the revision specification as
`specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` in the
`specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` format of record, and
reconciles `specs/ROADMAP.md` with the tree as it stands. Definition of done: both files written,
every status claim in them checkable at the path given, Phase 0 of the ROADMAP restated but not
decided, and no write to `specs/state.json` or `specs/TODO.md`.

The plan is a verification-then-transcription pipeline, deliberately: the research report is the
inventory of record (acceptance item 1 and 2), and the implementation writes nothing it has not
re-checked this round. Every fix the review found *outside* the task's `file_scope` (the stale
prose on seven surfaces, the ungrounded `pinned:C14` rows, the unwritten `Decidable (Derivable
.ZTime [] φ)` corollary) is routed into the specification's new-task section, never applied here.

### Research Integration

Integrated from `reports/01_decidability-programme-review.md`:

- **Headline reconciliation finding (Executive Summary, §2):** Z-time validity of the base
  language L is machine-checked decidable --
  `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime : (φ : Formula) →
  Decidable (ValidZTime φ)` (`FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/
  Assembly.lean:147`, a `def`, axioms `[propext, Classical.choice, Quot.sound]`, empty premises)
  -- while every programme-level surface, `specs/ROADMAP.md` included, describes only the tableau
  spine's open biconditional. The two families of claims are about different statements; the
  ROADMAP reconciliation (Phase 4) must state both, naming the frame class and the declaration
  every time so the result is never over-read as "TM is decidable".
- **Inventory (§1):** the four statuses are assigned by *statement*, not directory; the L⁺
  compression theorem is WITHDRAWN (`PlusSharingWitnessFamily.not_exists_plusCertifies_pumpTarget`,
  `PlusWitnessFamily/Limits/NoCertificate.lean`); the finite-carrier and finite-width FMPs are
  REFUTED at probe level (`Probe706.no_finite_carrier_sat`, `Probe710.not_finite_width_fmp`,
  `Probe710.not_sliced_complete`), both Z-only, the former `⊡`-free (a fact about TM itself), the
  latter `⊡`-bearing (L⁺-specific).
- **Routes (§3):** R1 (seam-gluing ray product + a universal summary) stays first with its
  hypothesis sharpened to `[F.IsRegular]` via `TaskFrame.comp` plus the reflection convention --
  never unconditional; only the forward factor of the finite-graph summary is proved; necessity of
  *some* universal device is shown (`Probe718PathQuantifier.exists_ne_stab`), necessity of
  Safra/Piterman specifically is not. Cheapest next experiment: the backward-dual probe on a
  time-asymmetric fixture (E1).
- **Revision specification draft (§4, Sections A-H)** and **ROADMAP item list (§5, items
  5.1-5.8)**: transcribed by Phases 2-4 below, with the prior decision applied.
- **Record-integrity defect (Executive Summary, §5.3):** `docs/theorem-index.md` rows 147-149
  claim `pinned:C14` but `scripts/check-module-invariants.sh` names those declarations only in the
  shadowing allowlist (lines 3411-3415). Out of `file_scope`; routed to new task H2 in the spec.

**Prior decision applied (from `.decisions.json`, cycle 1):** Option A -- library landing. The
specification's Section F and the ROADMAP's Success Metric adopt the reading that 706 and 710 land
`Probe706.no_finite_carrier_sat` and `Probe710.not_finite_width_fmp` as `FormalSystem/` theorems,
with 720 re-pointing citations to library names. Both files MUST carry the recorded caveat
verbatim in substance: this was adopted autonomously from the research recommendation under a
non-blocking `user_decision`, is NOT a user ruling, and is re-openable via `/revise`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was read (not as a `roadmap_flag` dispatch -- `roadmap_flag` is unset, so no
snapshot/update wrapper phases are added; the ROADMAP edit is itself Deliverable 5 and is a core
phase). This task advances the "Gluing route to decidability" front indirectly (it re-ranks the
routes and names E1 as the next probe) and the "Parked" front (it restates the 711/712/713
rulings with their new evidence). It completes no ROADMAP checkbox of its own; it annotates 718's
four Phase 1 checkboxes as completed and strikes 563's Phase 3 item, both from `specs/state.json`
status (`completed`).

## Goals & Non-Goals

**Goals**:
- Re-verify, this round, every declaration name, file path, hypothesis and task status the two
  deliverable files will cite (Phase 1), and record the verification so the writes are grounded.
- Emit `followup-scope-spec.md` naming, per affected task (712, 711, 713, 709, 719, 706/710/720,
  430/412), the concrete scope change required, plus the five new tasks to file, in the 718
  format of record (Phases 2-3).
- Resolve the 711 tension explicitly (ROADMAP: ABANDONED vs. `.decisions.json`: revive on
  evidence) by the research's third option -- REVISE -- stated with both records' partial
  correctness and the evidence condition's status (Phase 2).
- Reconcile `specs/ROADMAP.md`'s Fronts table, Phase 1/2/3 items, Open Risks, Success Metrics,
  header and Maintenance with the tree, leaving Phase 0 restated and undecided (Phase 4).
- Confirm cross-file consistency and the hard constraints before closing (Phase 5).

**Non-Goals**:
- Writing `specs/state.json` or `specs/TODO.md`, or creating/abandoning/revising any task; the
  specification is executed afterwards by the user or orchestrator via `/task` and `/revise`.
- Editing any file outside `file_scope`: no change to `docs/theorem-index.md`,
  `scripts/check-module-invariants.sh`, `scripts/check-evidence-probes.sh`, `README.md`,
  `FormalSystem/**`, `typst/**`, or the paper repository. Each such fix is a spec item.
- Landing any complexity claim; the CTL⋆ 2EXPTIME lower bound (task 713, ARGUED) remains the
  sanity ceiling only.
- Reopening settled soundness: `plusTruth_iff_mem` and `plusRefutes_of_certifies` are untouched.
- Marking any Phase 0 ruling decided, or checking any Phase 0 checkbox.
- Building the re-runnable review mechanism (spec item H5 names it as a new task).
- Running `roadmap-integration.sh` or any annotator that could touch ROADMAP checkboxes
  mechanically; all ROADMAP edits in this task are hand-written and reviewed against the tree.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The headline positive finding is over-read in the ROADMAP as "TM is decidable" | H | M | Every statement of it names `FrameClass.ZTime`, `Formula` (no `⊡`), empty premises, the declaration and its axioms; Phase 5 greps the ROADMAP for the bare phrase "decidable" near "TM"/"L" and checks each hit is qualified |
| Phase 0 is read as decided by this task | H | L | Phase 0 items keep `- [ ]`; edits add evidence sentences only; Phase 5 diffs the Phase 0 block and fails if any checkbox state changed |
| An anchor the research cited has moved since the research dispatch (e.g. a probe promoted, a line renumbered) | M | L | Phase 1 re-runs every grep/`#check`; Phase 2-4 cite declaration names and paths, never line numbers, except where the research's own line citations are reproduced as "as of this round" |
| Section F's Option A changes 706/710's scope while they are `[RESEARCHED]` and own files 720 depends on | M | M | The spec states Option A as the adopted reading with the autonomous-adoption caveat verbatim, lists Option B, and names the collision; the ROADMAP gains an unchecked Phase 0 item asking the user to confirm the reading |
| The `pinned:C14` defect is a grep miss, not a real defect | L | L | Spec item H2 is scoped to re-verify before editing; Phase 1 re-runs the grep and records the exact command and output |
| A concurrent dispatch (sibling tasks are live this session) touches `specs/ROADMAP.md` | M | L | Phase 4 reads the file immediately before editing, commits as soon as green, and stages only the two files this task owns |
| The ROADMAP's open-task count and front rows drift from `specs/state.json` during the cycle | L | M | The count and every front row are Scope Hypotheses recomputed from `specs/state.json` at implementation time, not copied from the research |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phases 2 and
3 write the same file, and Phase 4's ROADMAP text cites the spec's section letters.

### Phase 1: Re-verify the Anchors and Open the Specification File [COMPLETED]

**Goal**: Ground every claim the two deliverable files will make by re-checking it against the
tree this round, and record the results as Section 0 of the new `followup-scope-spec.md`.

**Tasks**:
- [x] Create `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` with *(completed)*
      the header block modelled on the 718 file's opening paragraph (written by which round, what
      it records, that it files nothing and edits no other task's state) and an empty section
      skeleton for Sections 0, A-H, "The 711 tension", "Ranking ratification", "State-write
      disclosure".
- [x] Section 0 (verification record), one row per anchor, columns Anchor | Path | Check run | *(completed: 27 rows plus task-record table)*
      Result. Re-run and record:
  - `grep -n 'def decidableValidZTime\|theorem validZTime_iff_noCertifiedCandidate\|def
    decidableSemanticConsequenceNil'` on `FormalSystem/Metalogic/Decidability/WitnessFamily/
    Compression/Assembly.lean`; then `lake env lean` on a scratch file (scratchpad directory, not
    the repo) importing `FormalSystem` with `#check` and `#print axioms` for
    `Compression.decidableValidZTime` and `validZTime_iff_noCertifiedCandidate`; record the
    axiom list verbatim.
  - `grep -n 'theorem no_finite_carrier_sat\|theorem not_finite_carrier_fmp\|theorem
    θ_eq_ofFormula'` on `specs/706_lplus_finite_model_property_and_completeness/probes/
    NoFiniteCarrierModel.lean`; `grep -n 'theorem not_finite_width_fmp\|theorem
    not_sliced_complete'` on `specs/710_sliced_class_incompleteness_characterization/probes/
    NoFiniteWidthModel.lean`; confirm the `[Finite F.WorldState]` / `[Finite W]` hypotheses on the
    core lemmas.
  - `grep -n 'IsRegular' specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean`
    and confirm `seamFibreEquiv`, `seamOmegaEquiv`, `plusStab_iff_rays`, `plusStab_iff_omega` all
    sit under `[F.IsRegular]` (declaration-level or `variable`-level).
  - `grep -n 'not_exists_plusCertifies_pumpTarget' FormalSystem/Metalogic/Decidability/
    PlusWitnessFamily/Limits/NoCertificate.lean` (the WITHDRAWN anchor).
  - `grep -n 'Retired as vacuous' FormalSystem/Metalogic/Decidability/Correctness.lean` (the NOT
    ESTABLISHED anchor).
  - `scripts/check-evidence-probes.sh`: list the `WIRED_REPO` array entries and their recorded
    blockers; run the script and record its exit status.
  - `grep -n 'pinned:C14' docs/theorem-index.md | grep -i 'validZTime\|decidableValidZTime'` and
    `grep -n 'Compression\.\|decidableValidZTime\|validZTime_iff_noCertifiedCandidate\|
    exists_witnessFamily_of_not_validZTime' scripts/check-module-invariants.sh`; record both
    outputs verbatim (this is the evidence for spec item H2).
  - `jq` over `specs/state.json` (read-only): status and `dependencies` of 706, 709, 710, 711,
    712, 713, 718, 719, 720, 430, 412, 563, 177, 543; the open-task count (status not in
    completed/abandoned/expanded); the date 718 and 563 completed (from `last_updated` or the
    `git log` commit `task 718: complete implementation` / `task 563: complete implementation`).
- [x] If any anchor differs from the research report's statement, record the difference in *(completed: one namespace difference, row 14)*
      Section 0 and carry the *verified* value forward into Phases 2-4; do not edit the research
      report.
- [x] Commit the file (scoped staging: this file only). *(completed: 6710a1fbc)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The research names 14 task records and roughly 12 declaration anchors to
re-verify; confirm the count by enumerating Section 0's rows at implementation time -- a missing
anchor cited later in the spec or ROADMAP is a defect in Section 0, not in the citing text.

**Files to modify**:
- `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` - create; header plus Section 0 verification record plus empty section skeleton

**Verification**:
- The file exists, opens with the header paragraph, and Section 0 has one row per anchor with a
  literal command and a literal result (no "confirmed" without the output).
- `#print axioms` output for `Compression.decidableValidZTime` is recorded verbatim.
- No file outside the task directory was modified (`git status --short` shows only the new file).

---

### Phase 2: Per-Task Revision Specifications (Sections A-G) and the 711 Resolution [IN PROGRESS]

**Goal**: Write the per-task scope changes in the 718 format, each naming the task, its current
status and dependencies (from Section 0), the concrete change, the command that executes it
(`/revise N`), and what must NOT be done by this task.

**Tasks**:
- [x] Section A -- Task 712 (L⁺ sliced FMP, `[BLOCKED]`, deps `[703, 711]`): record that the *(completed)*
      statement is machine-checked FALSE (`Probe710.not_sliced_complete`,
      `Probe710.not_finite_width_fmp`, Z-only, `⊡`-bearing witness) so the record is a refutation;
      specify removal of dependency `711` via `/revise 712`; state the two honest terminal
      options (`[ABANDONED]` vs. `[COMPLETED]` as a refutation record once the library landing
      of Section F exists) as a Phase 0 user ruling, with the research's recommendation stated
      and marked as not decided.
- [x] Section B -- Task 711 (ω-automata determinization substrate, `[BLOCKED]`, deps `[]`): state *(completed)*
      the tension verbatim from both records (`specs/ROADMAP.md` Phase 0 bullet; `specs/718_.../
      .decisions.json` answer); state what the probes actually showed (`Probe718PathQuantifier.
      exists_ne_stab`, `exists_ne_universal`: a universal/complementation-shaped device is
      necessary on the fixture; Safra/Piterman specifically is not shown necessary); resolve by
      REVISE: re-title/re-describe as the universal-summary substrate for the `⊡` fibre check on
      the seam-gluing route, list the candidate devices (Safra/Piterman; Safraless per
      Kupferman-Vardi 2005, `~/Projects/Literature/SOURCES.md` D8; MSO over `⟨ℤ,<⟩` plus Büchi per
      HWZ 2000; a Ramsey-coloured summary per F4), re-point the consumer from 712 to 719
      Deliverable 5, keep `[BLOCKED]` with reason "device not yet selected; probe E3 pending",
      keep the prohibition that no 719 phase builds the substrate. Restate the Phase 0 ruling as
      newly answerable (the decision's evidence condition is met) and not decided here.
- [x] Section C -- Task 713 (CTL⋆ 2EXPTIME reduction, `[NOT STARTED]`, deps `[]`): record its *(completed)*
      role as the sanity ceiling cited by 718, 719 and this review; specify a description
      revision that states that role and forbids landing any upper-bound claim; leave
      unscheduled; restate the Phase 0 ruling (keep as write-up note, recommended, or abandon).
- [x] Section D -- Task 709 (F4 periodicity, `[NOT STARTED]`, deps `[703, 710]`): record 718's *(completed)*
      demotion of F4 to a component of R1; specify adding dependency `719` and re-describing F4
      as R1's summary step, with the fallback (restrict to safety/bounded-step `⊡`; close as a
      reasoned exclusion if R1 selects an automaton acceptance condition).
- [x] Section E -- Task 719 (ray layer, `[NOT STARTED]`, deps `[563, 564, 718]`): specify that *(completed)*
      Deliverable 5 names experiment E1 (backward-dual finite-graph probe on a time-asymmetric
      fixture, reusing `Probe710.Node`/`Step`) as its first probe, and that acceptance requires
      every promoted keystone declaration to carry `[F.IsRegular]` verbatim.
- [x] Section F -- Tasks 706, 710, 720 (refutations' library landing): state both readings of *(completed)*
      the Success Metric; record that Option A was adopted (per `.decisions.json`, cycle 1) with
      the caveat that the adoption was autonomous under a non-blocking `user_decision`, is not a
      user ruling, and is re-openable via `/revise`; specify: 706 and 710's implementation scope
      is the library landing (`PlusSlicedCertificate/Limits/NoFiniteWidth.lean` for 710's
      theorems; a `FormalSystem/` home for 706's `no_finite_carrier_sat` family, to be chosen by
      706's plan), and 720 is revised to re-point `FMP/README.md` and
      `scripts/check-evidence-probes.sh` citations to library names rather than
      `specs/evidence/` paths (or to be closed as subsumed if the landing leaves no probe to
      move). Name the file collisions (706/710 share `PlusSlicedCertificate.lean` and
      `docs/theorem-index.md`).
- [x] Section G -- Tasks 430 and 412 (tableau spine): specify description revisions recording *(completed)*
      that `Decidable (ValidZTime φ)` exists by the witness-family route and that the spine's
      deliverable is the four-class biconditional, whose ZTime instance must agree with the
      independent oracle (cross-check L-E3); no dependency change.
- [x] Every section ends with an "Action required" line naming the exact command (`/revise N`) *(completed)*
      and the executor (user or orchestrator), per the 718 format.
- [x] Commit (scoped staging: the spec file only). *(completed: see git log, phase 2.2)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: Seven sections (A-G) covering ten tasks (712, 711, 713, 709, 719, 706, 710,
720, 430, 412). Confirm at implementation time against the research report's §4 that no affected
task is omitted and no task outside that list is added without a stated reason.

**Files to modify**:
- `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` - Sections A-G

**Verification**:
- Each section names: current status and deps (matching Section 0), the concrete change, the
  command, and what is left to the user; no section says "update state.json" or similar.
- Section B contains both records' positions and the probe declaration names, and the word
  "REVISE" as the resolution; Section F contains the Option A caveat.
- `grep -c 'Action required' followup-scope-spec.md` ≥ 7.

---

### Phase 3: New-Task Specifications (Section H), Ranking Ratification and Disclosure [NOT STARTED]

**Goal**: Complete the specification with the tasks to file, the ratified ranking for both
languages, and the state-write disclosure.

**Tasks**:
- [ ] Section H -- five new-task specifications, each with proposed title, `task_type`,
      dependencies, `file_scope`, description, and "Action required: file with `/task`":
  - H1 prose reconciliation of the decidability status (`markdown` or `general`; `file_scope`:
    `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/Decidability/README.md`,
    `FormalSystem/Metalogic/Decidability.lean` docstring,
    `FormalSystem/Metalogic/Decidability/BiLasso/README.md`,
    `docs/architecture/ADR-007-Decidability-One-Directional.md`,
    `docs/project-info/known-limitations.md`, `typst/FormalFoundations.typ`); state the
    two-statement distinction once; note the collision with 177's and 543's scopes.
  - H2 pin the three witness-family rows in `scripts/check-module-invariants.sh`'s C14 baseline
    (`lean4` or `general`), with Section 0's grep output as the evidence and the instruction to
    re-verify first.
  - H3 `Decidable (Derivable .ZTime [] φ)` (L-E1; `lean4`; via `decidable_of_iff` through
    `soundness_ztime_valid` and `derivable_of_validZTime`; plus its `docs/theorem-index.md` row).
  - H4 backward-dual finite-graph probe E1 (`lean4`; `specs/evidence/seam-gluing-ray-product/`,
    `scripts/check-evidence-probes.sh`); note it may be folded into 719 Deliverable 5 (Section
    E) and should be filed separately only if 719 is not dispatched within the cycle.
  - H5 make this review re-runnable (a `/review` step or a standing task regenerating the
    inventory from `docs/theorem-index.md`, the `WIRED`/`WIRED_REPO` arrays and the "Retired as
    vacuous" section; the ROADMAP Maintenance section to name the owner).
- [ ] "Ranking ratification" section, both languages, each route with its load-bearing
      hypothesis, falsifier and cheapest next experiment, transcribed from research §3: L⁺ R1
      (hypothesis `[F.IsRegular]`; forward factor only proved; E1 then E2 then E3) > R2
      (`StabSaturated`; E4) > R3 as a component of R1 > R4 closed for Z > R5 low; L: L-R1 done
      (L-E1, L-E2, L-E3 corollaries), L-R2 tableau spine (four-class, the only Base/Dense/RTime
      route), L-R3 dense-time certificate class (unfiled). State explicitly where this ranking
      supersedes `specs/718_.../reports/02_ranked-route-analysis.md` (next experiment is the
      backward dual, not stratification) and where it agrees. No complexity bound is committed;
      713's lower bound is named as the ceiling.
- [ ] "State-write disclosure" section: this task wrote only files under
      `specs/721_decidability_programme_review_l_and_lplus/` and `specs/ROADMAP.md`;
      `specs/state.json` and `specs/TODO.md` were read, not written; no task was created,
      revised or abandoned.
- [ ] Commit (scoped staging: the spec file only).

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: Five new tasks (H1-H5) and eight ranked routes (five L⁺, three L). Confirm
at implementation time against research §3 and §4 Section H; a route or task omitted here is an
omission to fix, not a judgment call.

**Files to modify**:
- `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` - Section H, Ranking ratification, State-write disclosure

**Verification**:
- `grep -c 'Proposed title' followup-scope-spec.md` = 5; each H item has `task_type`,
  dependencies and `file_scope`.
- The ranking section contains the string `IsRegular` and the phrase that the backward factor is
  unproved; it contains no numeric complexity bound asserted as a result.
- The file contains no instruction to edit `specs/state.json` or `specs/TODO.md` directly.

---

### Phase 4: Reconcile specs/ROADMAP.md [NOT STARTED]

**Goal**: Bring the ROADMAP's Fronts table, phase items, Open Risks, Success Metrics, header and
Maintenance into agreement with the tree, citing declarations and the spec's sections, with
Phase 0 restated and undecided.

**Tasks**:
- [ ] Re-read `specs/ROADMAP.md` immediately before editing (a sibling task may have touched it);
      record its `git log -1` SHA in the commit message body.
- [ ] Header: re-date to the implementation date; add a sentence that the interval-site/behavior-
      presheaf layer (`FormalSystem/Semantics/Presheaf/{Site,Behavior}.lean`, task 563) and the
      omega-sequence round (task 718) have landed since the previous date; recompute the open-task
      count from `specs/state.json`.
- [ ] Fronts table: "Gluing route to decidability" row -> open tasks `719, 720, 711 (revised per
      followup-scope-spec Section B)` plus `709` if Section D is adopted, 718 removed; "L⁺ sliced
      certificates" row -> drop 709 correspondingly (or keep with a note if the user has not
      adopted Section D -- state which); "Categorical structure" row -> drop 563; "TM tableau
      spine" row -> Delivers column gains "the four-class biconditional (Z-time validity of L is
      already decided by `Compression.decidableValidZTime`)"; add 721 to the front it belongs to
      (the gluing-route row, as the review that re-ranked it) until it completes.
- [ ] Phase 0 (user-only): keep every `- [ ]` unchecked and every existing bullet; append
      evidence sentences only -- 712: the 711 dependency edge is now meaningless (Section A) and
      closing as a refutation record waits on the library landing (Section F); 711: the third
      option REVISE (Section B) and that the decision's evidence condition is met; 713: its
      sanity-ceiling role (Section C). Add one new unchecked item: confirm or overturn the Option
      A reading of the Success Metric adopted autonomously in cycle 1 of task 721 (Section F).
- [ ] Phase 1: annotate 718's four checkboxes `- [x] ... *(Completed: Task 718, {DATE})*` with
      the one-line verdicts (keystone proved under `[F.IsRegular]`; ray layer is a
      `PartialHistory` with a half-line domain; the ω move is a decomposition not a re-basing;
      filtration closed for Z); replace "Blocked by: Task 718 (→ 719); Tasks 563, 564 (→ 719)"
      with "Task 564 (→ 719)"; add E1 (backward-dual probe on a time-asymmetric fixture) as the
      phase's first probe and name the three E-experiments in order; quote the determinization-
      funding decision from `specs/718_.../.decisions.json` and state that its evidence condition
      is met and that reviving/revising 711 is a Phase 0 call; update the Run block (718 done).
- [ ] Phase 2: rewrite the 709 item and the sentence "Task 709 is the phase's substance and the
      only item that is open mathematics" per Section D (F4 is R1's summary step, sequenced under
      719); reword the 706 and 710 items as the library landing per Option A and add a 720 item
      (re-point citations to library names), with the Option A caveat in one clause; update the
      Run block ordering note accordingly.
- [ ] Phase 3: strike 563's item (annotate completed, note `Beh F 0 ≃ F.WorldState` landed);
      change "Blocked by: Task 563 (→ all)" to the remaining edges (565 → 566; 564, 616 → 618);
      keep the aggregator-import hazard paragraph; update the Run block (563 done).
- [ ] Phase 6: add one sentence to the 430 item and to the preamble: `Decidable (ValidZTime φ)`
      is proved by the witness-family route (`Compression.decidableValidZTime`, ZTime, `Formula`,
      empty premises, axioms `[propext, Classical.choice, Quot.sound]`); the spine's deliverable
      is the four-class `isValid` biconditional, whose ZTime instance has an independent oracle.
- [ ] Open Risks table: (a) filtration row -> CLOSED for Z-time by `Probe706.no_finite_carrier_sat`
      / `Probe710.not_finite_width_fmp`, dense residue only, owner 706/710 (landing) and 720;
      (b) determinization row -> a universal/complementation-shaped device is NECESSARY on the
      fixture (`exists_ne_stab`), Safra/Piterman specifically NOT shown necessary, device
      selection pending (E3), owner 711 (revised); (c) "Zero sorries" row -> keep, add that
      `Decidable (ValidZTime φ)` does exist by the witness-family route, so the risk is one of
      description; (d) new row: programme-level surfaces describe only the tableau and understate
      L -- CONFIRMED -- owner: new task H1; (e) new row: `docs/theorem-index.md` rows for the
      three witness-family declarations claim `pinned:C14` without a baseline entry -- CONFIRMED
      by grep (Section 0) -- owner: new task H2; (f) 2EXPTIME row -> add "the sanity ceiling
      cited by 718, 719 and 721"; (g) gluing-route row -> owners 719, 720, 711 (revised); 718
      completed.
- [ ] Success Metrics: keep "Every refutation ... lives in `FormalSystem/`" (Option A) and add
      "(reading adopted autonomously in task 721 cycle 1; confirm in Phase 0)"; amend the
      `isValid` biconditional metric with "and `Decidable (ValidZTime φ)` is already proved
      (`Compression.decidableValidZTime`); the ZTime instance of the former must agree with it";
      add a metric that the `pinned:C14` claim on the three witness-family rows is grounded (H2).
- [ ] Recommended Execution Order: strike 563 and 718 from item 1; insert E1 under item 2; adjust
      item 5 (709 under the gluing route, not "the one real theorem"); keep all else.
- [ ] Maintenance: name the periodic re-run owner as "new task H5 of
      `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` until filed",
      and point to `reports/01_decidability-programme-review.md` as the inventory baseline.
- [ ] Commit (scoped staging: `specs/ROADMAP.md` only), message body naming the pre-edit SHA.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: prose

**Scope Hypothesis**: Eight ROADMAP regions are edited (header, Fronts, Phase 0, Phase 1, Phase 2,
Phase 3, Phase 6, Open Risks, Success Metrics, Execution Order, Maintenance -- eleven named
touch points across eight `##` sections) and no other `##` section changes. Confirm with
`git diff --stat` and a per-hunk read-through at implementation time; an unplanned hunk is
reverted, not kept.

**Files to modify**:
- `specs/ROADMAP.md` - header, Fronts, Phase 0 (annotate only), Phase 1, Phase 2, Phase 3, Phase 6, Open Risks, Success Metrics, Recommended Execution Order, Maintenance

**Verification**:
- `grep -c '^- \[ \]' ` over the Phase 0 block is at least its pre-edit value (no checkbox
  checked; one added); `git diff` of the Phase 0 block shows additions only.
- Every `## Phase N: ... (... Priority)` header still matches
  `^## Phase (\d+): (.+?) \((\w+) Priority\)` per `roadmap-format.md`, so `/review`'s parser
  still reads the file (the Phase 1 header's "Highest Priority" is pre-existing; do not change
  it).
- `grep -n 'decidableValidZTime' specs/ROADMAP.md` is non-empty, and every hit's sentence names
  ZTime and `Formula` or "no `⊡`".
- `grep -n 'IsRegular' specs/ROADMAP.md` is non-empty (the keystone hypothesis is stated).
- `grep -n '718' specs/ROADMAP.md` shows 718 only in completed annotations, quoted decisions,
  or the Open Risks history -- not in any "Open tasks" cell.

---

### Phase 5: Cross-File Consistency Check and Hard-Constraint Audit [NOT STARTED]

**Goal**: Confirm the two deliverable files agree with each other and with the tree, and that
every hard constraint of the task holds, before the task closes.

**Tasks**:
- [ ] Trace: every task number named in a ROADMAP change (709, 711, 712, 713, 719, 720, 706,
      710, 430, 412, 563, 718) has a corresponding spec section or Section 0 fact; every spec
      section that changes a ROADMAP-visible fact (A-G, H1, H2, H5) is reflected in the ROADMAP.
      Record the trace as a short table at the end of the spec (or confirm Section 0 already
      covers it).
- [ ] Declaration sweep: for every backticked declaration name in both files, `grep -rn` it under
      `FormalSystem/`, `specs/evidence/`, `specs/706_.../probes/`, `specs/710_.../probes/`; each
      must resolve to a definition. Fix any typo in the deliverable files; never "fix" the tree.
- [ ] Hypothesis sweep: every mention of `seamFibreEquiv`, `seamOmegaEquiv`, `plusStab_iff_rays`,
      `plusStab_iff_omega` in both files is accompanied by `IsRegular` in the same sentence or
      row; every mention of `decidableValidZTime` is qualified by ZTime/`Formula`/empty premises.
- [ ] Negative-conclusion check: the WITHDRAWN and REFUTED statuses are stated as such in both
      files (no "open question" wording for `not_sliced_complete`/`not_finite_width_fmp`; no
      softening of the compression theorem's withdrawal).
- [ ] Complexity check: `grep -n 'EXPTIME\|EXPSPACE\|PSPACE' ` over both files; every hit is
      either the 713 lower-bound ceiling or a literature citation, never a claimed result.
- [ ] Soundness check: `plusTruth_iff_mem` and `plusRefutes_of_certifies` appear only as
      "untouched/sound" anchors.
- [ ] State-write check: `git status --short` and `git diff --name-only HEAD~N` for this task's
      commits list only files under `specs/721_decidability_programme_review_l_and_lplus/` and
      `specs/ROADMAP.md`; `specs/state.json` and `specs/TODO.md` are not among them (the
      orchestrator's own status-sync writes are outside this task's commits and are not counted
      against it -- note that distinction in the summary).
- [ ] Write `specs/721_decidability_programme_review_l_and_lplus/summaries/01_decidability-
      programme-review-summary.md` per `summary-format.md`: what was written, the Option A
      caveat, the Phase 0 items left to the user, and the five tasks to file.
- [ ] Commit (scoped staging: the summary and any spec/ROADMAP fix from this phase).

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: prose

**Files to modify**:
- `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` - trace table and any typo fix found by the sweeps
- `specs/ROADMAP.md` - any typo fix found by the sweeps
- `specs/721_decidability_programme_review_l_and_lplus/summaries/01_decidability-programme-review-summary.md` - create

**Verification**:
- All six sweeps above pass with their commands and outputs recorded in the summary.
- The summary names every file written by the task and states the state.json/TODO.md
  non-write explicitly.

## Testing & Validation

- [ ] `bash scripts/check-evidence-probes.sh` exits 0 before and after (this task changes no probe;
      the run is the Section 0 baseline).
- [ ] `specs/ROADMAP.md` phase headers all match `roadmap-format.md`'s regex
      `^## Phase (\d+): (.+?) \((\w+) Priority\)` (Phase 1's "Highest Priority" is pre-existing and
      is left as found).
- [ ] Phase 0 block diff is additions-only; no `- [ ]` became `- [x]` in Phase 0.
- [ ] Every backticked declaration in `followup-scope-spec.md` and the ROADMAP diff resolves by
      grep to a definition in the tree.
- [ ] `git diff --name-only` across this task's commits ⊆ {`specs/721_.../**`, `specs/ROADMAP.md`}.
- [ ] `followup-scope-spec.md` has: Section 0 with literal command outputs; Sections A-G each with
      an "Action required" line; Section H with five `Proposed title` entries; a ranking section
      naming `IsRegular`; a state-write disclosure.
- [ ] No complexity bound is asserted as a result in either file.

## Artifacts & Outputs

- `specs/721_decidability_programme_review_l_and_lplus/plans/01_decidability-programme-review.md` (this plan)
- `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` (Deliverable 4: the revision specification, in the 718 format of record, with Section 0 verification record)
- `specs/ROADMAP.md` (Deliverable 5: reconciled; Phase 0 restated, undecided)
- `specs/721_decidability_programme_review_l_and_lplus/summaries/01_decidability-programme-review-summary.md`
- Deliverables 1-3 remain in `specs/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md` (research round; not rewritten by this plan)

## Rollback/Contingency

- All writes are two markdown files plus a summary, each committed as its own green sub-step. To
  revert a single step, `git revert <sha>` the offending commit; no working-tree discard is
  required because every phase ends in a commit.
- If `specs/ROADMAP.md` is found modified by a concurrent dispatch between Phase 4's read and its
  edit, stop, re-read, and re-apply the Phase 4 edits on the new base rather than overwriting;
  record the intervening SHA in the commit body.
- If Phase 1 finds an anchor has moved so that a research claim is no longer true (e.g. a probe
  already promoted into `FormalSystem/`), carry the verified fact into Sections A-H and the
  ROADMAP and record the discrepancy in Section 0; do not block on it and do not edit the
  research report.
- If a genuine rollback of uncommitted Phase 4 edits is ever needed (not a routine checkpoint),
  follow `context/contracts/recovery.md`'s rollback rung for the snapshot-then-rollback
  invocation; do not emit a bare precautionary `git-snapshot.sh` at phase start.
