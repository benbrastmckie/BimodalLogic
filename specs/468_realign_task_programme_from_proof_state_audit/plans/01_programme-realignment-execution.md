# Implementation Plan: Task #468

- **Task**: 468 - Programme realignment from a verified proof-state audit
- **Status**: [NOT STARTED]
- **Effort**: 11 hours
- **Dependencies**: 469 (completed), 426 (completed), 451 (completed)
- **Research Inputs**:
  - `specs/468_realign_task_programme_from_proof_state_audit/reports/01_proof-state-audit-and-realignment-charter.md`
  - `specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md`
- **Artifacts**: plans/01_programme-realignment-execution.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Execute the charter's Stages 0-5 against the *re-verified* proof state, not the charter's own
now-stale premise. Report 02 established, by a fresh `scripts/check-module-invariants.sh` run,
that C3 reports **zero** live structural sorries and C2 reports **all four** flagship theorems
axiom-clean: tasks 477 -> 478 -> 479 closed `countermodel_discrete` at the `Q x_l Z` carrier while
the charter was in flight. The soundness/completeness metatheory front is DONE, not nearly-done.
Every stage below is still executed; the *content* of the verdicts, the critical path, and the
rewritten roadmap must be built on the re-verified state.

Definition of done: every active task carries a verdict with evidence; the three specced new tasks
exist; the description REVISEs are applied; the dependency graph has zero dangling edges and a
stated per-front critical path; `specs/ROADMAP.md` is split, retitled, per-front, grounded, and
machine-annotatable; `specs/state.json`'s counters are repaired or their non-repair is argued; and
one report carries the whole decision record including every proposed status correction for user
decision.

### Research Integration

Load-bearing findings from report 02 that this plan is built on:

- **§1(f)** — `countermodel_discrete` is closed; C3 sorry inventory is zero; C2 clean for
  `completeness`, `completeness_dense`, `completeness_discrete`, `Chronicle.countermodel_dense`.
  This invalidates the charter's headline premise and reshapes the completeness front's roadmap
  entry, tasks 169/422/95, and task 412's description.
- **§2** — the Stage 1b box-anchor question is settled NEGATIVE and broader than the charter
  framed it (the whole decidable-branch-gate family collapses, not just `boxAnchoredCheck`).
  Task 429 is a **redesign**, not a repair. Probe NOT re-run, per amendment 10a.
- **§3** — task 455 disposition: **ABSORB**, reached independently of the review's recommendation.
- **§4** — 165/432/436/170 all CURRENT; no REOPEN proposed. 177's `file_scope` already repaired by
  task 470 item (G).
- **§5** — three ADDs survive (isValid bridge, proof-extraction completeness, fifth termination
  residual `UnorderedSuccessorLabelClosed`); semantic FMP is now owned by 476; amendment 10b's
  three struck candidates confirmed struck.
- **§6** — 177 DIVIDE already half-executed by task 472; only the retained half's text remains.
- **§8** — zero dangling edges (after correcting a lexicographic-vs-numeric `comm` artifact that
  produced 50 false positives); `active_topics` is missing `metalogic`; 9-wave decidability spine.
- **§9** — the ROADMAP split has had **zero** progress; `state.json` counters still wrong
  (48 entries vs `metadata.total_tasks` 42 vs `task_counts.total` 42).

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

`specs/ROADMAP.md` is an *output* of this task, not an input to it. Phase 7 rewrites it wholesale;
Phase 3 archives its historical sediment. No roadmap item is consumed as a gating input, and
`roadmap_flag` is not set for this dispatch, so no roadmap-review/roadmap-update wrapper phases
are added.

### Planner decisions taken here (not deferred to the implementer)

Report 02 explicitly left two calls to planning. Both are decided:

1. **Proof-extraction completeness gets its OWN task, deps `[412]` — it is NOT folded into 412's
   acceptance criteria.** Report 02 flagged both options. Folding loses on the charter's own
   §3 rule: "do not create a task that hides a research problem behind an engineering
   description." 412's remaining scope (`allClosed_derivable`, the `Decidable (Derivable fc [] φ)`
   instance, the completeness corollaries, the Dedekind engine) is engineering-shaped and already
   large; extraction completeness is multi-month open mathematics that would be invisible as a
   trailing bullet on 412's acceptance list. Separate task, explicit `[412]` edge, plus a one-line
   REVISE to 412 naming the successor as the owner.
2. **The 169/422/95 redundancy question is sequenced at Phase 2, ahead of the ROADMAP split**, not
   the other way round. Report 02 recommended the ROADMAP split as first phase on the grounds that
   it is the fully-specified, wholly-undone piece — which is true, but the roadmap is a *derived*
   artifact: its strong-completeness front's current-state statement and its critical path both
   depend on whether 169/422/95 still describe live work. Writing the roadmap first would mean
   writing that front twice. Phase 3 (archive extraction) is the part of the split that has no
   such dependency, so it runs in the same wave as Phase 2 and the split is not, in practice,
   delayed.

## Goals & Non-Goals

**Goals**:
- Record the task-455 ABSORB disposition and its reasoning (Stage 0), proposing abandonment only.
- Issue one evidenced verdict for every active task, with CURRENT rows stating what was checked
  (Stage 2).
- Create the three new tasks report 02 specced, with the sequencing decisions above wired in.
- Apply every description REVISE, including the retained half of 177 with 472's territory excluded.
- Wire every implied dependency edge; re-derive and state the per-front critical path with the
  routine/hard split explicit; add `metalogic` to `active_topics`; repair the `state.json` counters
  or argue in writing why `/task --sync` must own them.
- Split `specs/ROADMAP.md` into a retitled, per-front, machine-annotatable current file and a
  `specs/ROADMAP-ARCHIVE.md`, with PROVEN distinguished from SORRY-FREE throughout, refuted routes
  tombstoned against the C9 register, the BiLasso subtree's status stated honestly, and every
  status claim naming the check that grounds it.
- Produce one report carrying the whole decision record and the explicit list of proposed status
  corrections for user decision (Stage 5).

**Non-Goals**:
- **No task status transitions.** No existing task may be moved to `completed`, `abandoned`, or
  `expanded`. Every such correction is PROPOSED in the report. Creating new tasks at
  `status: "not_started"` is creation, not a transition, and is in scope.
- **No `.lean` edits of any kind.** This task proves nothing and closes no sorry. The Stage 1b
  probe is NOT re-run (amendment 10a); the committed `boxanchored-finding.md` artifact is cited.
- No duplicate of task 472's documentation-correction pass (amendment 10f), and no re-scheduling
  of task 473's `neg_2var_vec_ea` deletion.
- No new task for the semantic FMP (owned by 476), the soundness lift or the RuleSound-at-
  firing-site discharge (both owned by 430), or the `NoSplit`-free termination result (inside 428).
- No archiving (that is `/todo`'s job, after the user acts on the report).
- No implementation, research, or planning of any surveyed or newly created task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Charter's verification criterion "C5 passes over the rewritten specs/ROADMAP.md" is **not literally satisfiable**: `check-module-invariants.sh`'s C5 walk prunes `specs` from `dirs[:]`, so it never reads `specs/ROADMAP.md` | H | Certain (verified) | Phase 7 runs a **C5-equivalent replication** over `specs/ROADMAP.md` using C5's own `mod_re` regex and `resolves()` logic, and Phase 9 records both the replication result and the fact that C5 proper excludes `specs/`. Baseline measured this plan: **0 unresolved** module-shaped paths in the current file. Do not report "C5 passed" without this qualification |
| `state.json` written concurrently by another in-flight task, clobbering an edit | H | Medium (13 sibling agents active this session) | Every write goes through `.claude/scripts/state-write.sh` (fail-closed `specs/.scope-lock` mutex, private `mktemp` staging). Never hand-edit `specs/state.json`; never hand-edit `specs/TODO.md`. Re-read `next_project_number` immediately before each task-creation write |
| Phase 2 cannot reach a defensible verdict on 169/422/95 from source comparison alone | M | Medium | Phase 2 has a declared fallback: if the mathematical comparison is genuinely inconclusive, record REVISE-with-open-question (not REMOVE), state precisely what a `/plan 422` dispatch must read to settle it, and carry the open question into the report's proposed-corrections list. An honest "unresolved, here is the exact question" beats a guessed abandonment |
| Rewritten ROADMAP.md re-introduces an unreproducible status claim | H | Medium | Phase 7 requires every status line to name its grounding check (C2/C3/C4/C5/C7) inline; Phase 9 greps the new file for status vocabulary and confirms each occurrence carries a check name |
| Counter repair conflicts with `/task --sync`'s own recomputation | M | Medium | Phase 6 computes the counters from `active_projects` itself, writes them through `state-write.sh`, and re-verifies by recomputation. If the schema's status key set cannot be reconciled (e.g. `task_counts` lacks `completed`/`researching` keys that the live data needs), Phase 6 records the argument for leaving it to `/task --sync` instead — the charter permits that outcome explicitly |
| Dangling-edge scan reproduces the 50 false positives from lexicographic-vs-numeric sorting | M | Medium | Phases 1 and 6 both zero-pad task numbers before any `sort`/`comm`, per report 02's Appendix. The corrected form is the only accepted form |
| Report 02's task-count arithmetic (§7's self-flagged hand-tally) is stale by implementation time | L | High | Phase 1 recomputes the count and the status breakdown fresh; Phase 8's verdict table is checked against that recomputed count, not against 48 as a literal |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 4 |
| 4 | 6 | 4, 5 |
| 5 | 7 | 3, 6 |
| 6 | 8 | 2, 5, 6, 7 |
| 7 | 9 | 8 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Baseline re-verification and evidence ledger [NOT STARTED]

**Goal**: Re-establish, at implementation time, every fact the later phases cite, so that no claim
in the final report is inherited from report 02 without a fresh check. Produce a durable evidence
ledger the later phases read instead of re-running checks.

**Tasks**:
- [ ] Run `bash scripts/check-module-invariants.sh` (full, with build). Record verbatim: C2's four
      flagship axiom sets, C3's sorry count, C4/C5/C7 results, and both `lake build` exit codes.
- [ ] Re-confirm the six Stage 1(a) claims by symbol name, not line number: no declaration takes
      `DecisionProcedure.isValid` as its subject; `ruleSound_of_mem_allRulesForFC` is not lifted
      and no `allClosed -> valid` exists; `serialityRule_not_mem_allRulesForFC` /
      `timeLinearity_not_mem_allRulesForFC` hold at every frame class;
      `FormalSystem/Metalogic/Decidability/Verified/Refutation/` does not exist; `verifyProof` is
      constantly `true` and `ProofExtraction.lean` has zero theorems; and the sixth claim
      (`countermodel_discrete` as the only live sorry) is **STALE** — record the correction with
      C2/C3 as its grounding.
- [ ] Re-verify the box-anchor artifact's prerequisites WITHOUT re-running the probe: confirm
      `Tests/BimodalTest/{BoxSpreadProbe,RegionGateProbe,RayRegionProbe,TemporalWitnessProbe}.lean`
      are live, that `BoxSpreadProbe.lean`'s `#guard_msgs` blocks still pin the post-fix `false`
      verdicts, and that `lake build BimodalTest` exits 0. Record the verdict as NEGATIVE and cite
      `specs/archive/418_.../artifacts/boxanchored-finding.md`.
- [ ] Verify task 470 item (G) repaired 177's `file_scope` (expect
      `["README.md","specs/ROADMAP.md","FormalSystem/","docs/"]` — resolvable, no duplicate). Do
      not redo it.
- [ ] Verify task 472's corrections held (spot-check its nine named files still carry the
      corrected text) and that task 473's `neg_2var_vec_ea`/`reflatten_neg_step` deletion landed.
- [ ] Recompute from `specs/state.json`: `active_projects | length`, the full status breakdown, and
      the current `next_project_number`.
- [ ] Run the dangling-edge scan over the union of `active_projects` and
      `specs/archive/state.json`'s archived+completed sets, **zero-padding every task number
      before any `sort`/`comm`**. Record the result and note the padding requirement.
- [ ] Write the ledger to `specs/468_realign_task_programme_from_proof_state_audit/reports/03_implementation-evidence-ledger.md`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: Report 02 measured 48 `active_projects` entries and `next_project_number` =
480 at its dispatch. Both are hypotheses at plan time — thirteen sibling agents are active in this
session and either may have moved. Confirm both by direct `jq` read in this phase and use the
recomputed values everywhere downstream; never hard-code 48 or 480.

**Files to modify**:
- `specs/468_realign_task_programme_from_proof_state_audit/reports/03_implementation-evidence-ledger.md` - new evidence ledger

**Verification**:
- The ledger contains a verbatim quotation of C2's four axiom sets and C3's count.
- Every one of the six Stage 1(a) claims has a recorded outcome, including the stale one.
- The box-anchor verdict is recorded with its artifact citation, and no probe was re-run.
- `git diff --stat` shows no `.lean` file touched.

---

### Phase 2: Adjudicate 169, 422, and 95 against the 477-479 closure [NOT STARTED]

**Goal**: Settle the single highest-priority open question report 02 surfaced and could not answer
within a research-only charter: whether tasks 169, 422, and 95 still describe live work now that
`countermodel_discrete` is closed by a route none of them supplies.

**Tasks**:
- [ ] Read task 422's own research report and task 169's description and `file_scope`
      (`BXCanonical/Completeness.lean`, `BXCanonical/Chronicle/`), and task 95's description.
- [ ] Read what 477 -> 478 -> 479 actually proved: `WeakCanonical/GroupModel/CountermodelBase.lean`,
      `WeakCanonical/IntegerModel/ReynoldsBridge.lean`, and the current
      `WeakCanonical/Transfer.lean` header (which now disclaims carrying the theorem). Identify by
      symbol name what `countermodel_discrete` is now proved from.
- [ ] Answer three questions in writing, each with symbol-level evidence:
      (a) Does 422's discrete-chronicle construction supply anything 477-479 did not — a more
      general carrier, a reusable transfer, or a Base-MCS-to-Discrete-consistency bridge that other
      open tasks consume? (b) Does 169's `BXCanonical`-side target still have a consumer, or was
      its only consumer the now-closed theorem? (c) Is 95's confirmation pass already satisfiable
      today given C2's clean axiom sets, and if so does it still need to wait on 169?
- [ ] Issue a verdict for each of 169, 422, 95 from the charter's vocabulary (CURRENT / REVISE /
      DIVIDE / REMOVE), each with its evidence and its consequent action.
- [ ] For any REMOVE: write the abandonment argument. Do NOT transition the task — the proposal
      goes in the report (Phase 8) for user decision.
- [ ] For any REVISE: write the exact corrected description text for Phase 5 to apply.
- [ ] **Declared fallback**: if the comparison is genuinely inconclusive, issue REVISE-with-open-
      question rather than guessing REMOVE, and state precisely which files a `/plan 422` dispatch
      must read to settle it. Record that outcome as such in the report.
- [ ] Append the adjudication to the Phase 1 evidence ledger.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts exactly three tasks are implicated (169, 422, 95). Confirm
at implementation time by grepping every active task's description and `file_scope` for
`countermodel_discrete`, `Chronicle`, and `BXCanonical/Completeness` — if a fourth task is
implicated, adjudicate it in the same phase rather than deferring it.

**Files to modify**:
- `specs/468_realign_task_programme_from_proof_state_audit/reports/03_implementation-evidence-ledger.md` - append adjudication section

**Verification**:
- Each of 169, 422, 95 has a verdict, an evidence paragraph citing symbol names, and a consequent
  action (corrected text, abandonment argument, or the explicit open question).
- No task status was transitioned.
- No `.lean` file touched.

---

### Phase 3: Extract specs/ROADMAP-ARCHIVE.md [NOT STARTED]

**Goal**: Move the historical sediment out of `specs/ROADMAP.md` into a separate archive file, so
Phase 7 can author a clean current-state file rather than editing around 1,970 lines of stacked
dated blocks. This is the mechanical half of amendment 10c's split.

**Tasks**:
- [ ] Enumerate every section of `specs/ROADMAP.md` and classify each as CURRENT-STATE-BEARING or
      HISTORICAL. Known historical: the stacked dated "Current state" blocks in `## Overview`
      (2026-07-24, 2026-07-16 superseded, 2026-07-07), the dated block further down (~2026-05-10),
      `## Dead Ends (Archived)`, `## Investigated Dead Ends: Logic Weakening`,
      `## How Until/Since Were Closed`, `## Legacy Code Inventory`, and the trailing 111-row
      `## Task Cross-Reference` table.
- [ ] Create `specs/ROADMAP-ARCHIVE.md` with a provenance header naming its source file, the date
      of the split, and a pointer back to `specs/ROADMAP.md` as the current file. Move the
      historical sections into it **verbatim** — this is a move, not a rewrite; do not correct
      claims in the archived text, and say so in the header (archived content is preserved as a
      record of what was believed when, not as current truth).
- [ ] Leave `specs/ROADMAP.md` temporarily reduced but coherent — Phase 7 replaces it wholesale, so
      this phase need only ensure nothing was lost and nothing dangles.
- [ ] Run the C5-equivalent replication (C5's `mod_re` regex + `resolves()` logic) over BOTH files;
      expect zero unresolved module-shaped paths.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: `specs/ROADMAP.md` measured 1,970 lines and roughly 10 remaining
`HISTORICAL|SUPERSEDED|STALE` banners at report-02 time (down from ~30, after task 472's trim).
Confirm both counts by `wc -l` and `grep -c` before classifying, and treat the section list above
as a starting inventory to be completed from the live file, not as exhaustive.

**Files to modify**:
- `specs/ROADMAP-ARCHIVE.md` - new; receives the historical sediment verbatim
- `specs/ROADMAP.md` - historical sections removed

**Verification**:
- No content is lost: the combined line count of both files, plus the removed section headers,
  accounts for the original file.
- `specs/ROADMAP-ARCHIVE.md` carries a provenance header stating archived text is not current.
- C5-equivalent replication over both files reports zero unresolved paths.

---

### Phase 4: Create the three new tasks [NOT STARTED]

**Goal**: Bring into existence the three tasks report 02 specced, with the planner's sequencing
decisions wired in from the start.

**Tasks**:
- [ ] Re-read `next_project_number` immediately before the first write; allocate consecutively and
      bump the field in the same `state-write.sh` transaction as each creation.
- [ ] Create **`bridge_isvalid_bool_to_semantic_validity`**: `task_type: lean4`,
      `topic: decidability`, `effort: small`, `dependencies: []`, `file_scope:
      ["FormalSystem/Metalogic/Decidability/Correctness.lean",
      "FormalSystem/Metalogic/Decidability/DecisionProcedure.lean"]`. Description states the target
      `isValid_sound`, the proof sketch (case on `decide φ (fc := fc)`; `.valid` case discharged by
      `decide_sound'`; the other three cases contradict `isValid = true` via the existing
      case-exhaustion lemma), that it is **routine engineering, not open mathematics**, that it is
      startable today independent of the 410-465 chain, and why it is NOT folded into 430 (430's
      target is engine-facing over `Derivable`/branch closure; this is decision-procedure-facing
      over the `Bool` API).
- [ ] Create **`discharge_or_replace_unorderedsuccessorlabelclosed_residual`**: `task_type: lean4`,
      `topic: decidability`, `effort: large`, `dependencies: [434]`, `file_scope:
      ["FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean"]`. Description
      states: the predicate is carried as a live hypothesis by
      `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` and is **refuted in-tree** at
      `¬ UnorderedSuccessorLabelClosed fc freshWorldLabels`; the three acceptable outcomes
      (discharge at the frame classes the surviving terminus theorems actually need; a
      `StepLengthBounded`-style weaker replacement following the `DifficultyBounded` repair
      pattern; or a C9 register entry with an explicit statement of which theorem still carries it
      at which frame classes); and that **a C9 entry is a complete deliverable**, not a failure.
      State explicitly that this is the FIFTH residual and that the four-residual framing is wrong.
      State the 462 sequencing: 462 targets discharge at a nonempty universe, the same setting the
      in-tree refutation applies in, so this task should run before or alongside 462.
- [ ] Create **`discharge_proof_extraction_completeness`**: `task_type: lean4`,
      `topic: decidability`, `effort: large`, `dependencies: [412]`, `file_scope:
      ["FormalSystem/Metalogic/Decidability/ProofExtraction.lean",
      "FormalSystem/Metalogic/Decidability/Verified/Refutation/"]`. Description states: eliminate
      `.extractionFailed` as a live outcome on a genuinely closed tableau; `verifyProof` is
      currently `fun _ _ => true`; the refutation induction (`allClosed_derivable`, the content
      that would live under `Verified/Refutation/`, zero files today) is a prerequisite owned by
      412; and that this is **OPEN MATHEMATICS, multi-month — it may not be re-described as
      engineering**. Record the planner's decision inline: kept separate from 412 rather than
      folded into its acceptance criteria, precisely so the research problem is not hidden behind
      412's engineering-shaped description.
- [ ] After all three writes, run `bash .claude/scripts/generate-todo.sh` and confirm it exits
      clean with no undeclared-topic warning.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly three ADDs, from report 02 §5's reconciliation — the semantic FMP is
owned by 476 and the three amendment-10b candidates are owned by 430/428, so none of those four is
re-added. Confirm before creating by grepping every active description for `isValid_sound`,
`UnorderedSuccessorLabelClosed`, and `extractionFailed`; if any is already owned, drop that
creation and record the finding instead.

**Files to modify**:
- `specs/state.json` - three new `active_projects` entries plus `next_project_number` bump (via `.claude/scripts/state-write.sh` only)
- `specs/TODO.md` - regenerated by `generate-todo.sh` only, never hand-edited

**Verification**:
- `jq` confirms three new entries at `status: "not_started"` with the stated `task_type`, `topic`,
  `effort`, `dependencies`, and `file_scope`.
- `next_project_number` advanced by exactly three.
- Each description carries its routine-vs-open-mathematics classification explicitly.
- `generate-todo.sh` exits clean.

---

### Phase 5: Apply the description REVISEs [NOT STARTED]

**Goal**: Correct every description report 02 and Phase 2 identified as drifted, including the
retained half of 177 with task 472's territory excluded.

**Tasks**:
- [ ] **412** — strike the stale clause naming `countermodel_discrete` as a sorry to discharge at
      `Transfer.lean` (that sorry no longer exists; the theorem lives in
      `WeakCanonical/GroupModel/CountermodelBase.lean` and is closed). Add one line naming the new
      proof-extraction-completeness task as the owner of `.extractionFailed` elimination, gated on
      412. Leave the rest of 412's scope untouched.
- [ ] **428** — add the explicit ASSESS-and-C9-register escape clause for the split-arm fuel
      scaling problem (`allocateFuelProportionally`, `β^depth`, `Fuel.lean`'s own note that depth
      is bounded by nothing proved): if it proves unclosable as specified, a C9 register entry plus
      a re-scoped statement is the correct deliverable, not another attempt. Do **not** touch 428's
      opening `buildTableau_isSome` paragraph — it is already correct and gets a CURRENT verdict on
      that point (amendment 10b).
- [ ] **429** — add one sentence naming repair option (a) (propagate `T(□φ)` itself to the fresh
      world; S5 axiom-4/5 pattern; its own `RuleSound` obligation; named fuel/termination
      consequences that `Fuel.lean`'s bounds and the subformula property must absorb) as the
      **recommended** route, so a dispatch need not re-derive the recommendation from the artifact.
      Keep option (c) recorded as closed as formulated. Confirm the description already frames 429
      as a redesign; if not, make that explicit.
- [ ] **462** — add the sequencing note: 462 targets discharge at a nonempty universe, the same
      setting in which `UnorderedSuccessorLabelClosed` is refuted in-tree; name the new
      fifth-residual task and state that it should run before or alongside 462.
- [ ] **178** — rescope: decidability of TM is still open (Phase 1 re-confirmed no declaration
      takes `isValid` as its subject), so a "complete worked example showing soundness-
      completeness-decidability" cannot be delivered. Rescope to soundness + completeness +
      propositional-fragment decidability, or gate the decidability example explicitly on the
      decidability front landing. Note that `truthAt_of_isValid` concerns a different, semantic-side
      `IsValid` and is not evidence of decidability.
- [ ] **177** — replace with the retained-half text: the final post-refactor polish, under its
      existing gating, **explicitly excluding** every item task 472 already corrected
      (`Decidability.lean`'s Status block, `Verified/README.md`, `FMP/README.md`,
      `DecisionProcedure.lean`'s `decideAuto` docstring, `Verified/Decidable.lean`'s Status
      docstring, `WeakCanonical.lean`, `RealModel/ShuffleReal.lean`, `Soundness.lean`,
      `PriorExpressivenessDense.lean`) and the two Kamp files task 473 swept
      (`Kamp/EANegationClosure.lean`, `NfMultiAnchorBridge/NavigatedSpine.lean`). Its residual
      content: re-auditing documentation for drift accumulated *during* the decidability chain's
      landing, plus the Axiom Reference update. Leave `file_scope` alone — task 470 item (G)
      already repaired it (verified Phase 1).
- [ ] Apply whatever corrected text Phase 2 produced for 169 / 422 / 95.
- [ ] Every write through `.claude/scripts/state-write.sh`; regenerate `TODO.md` afterwards.

**Timing**: 1 hour

**Depends on**: 2, 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Six named REVISEs (412, 428, 429, 462, 178, 177) plus up to three from
Phase 2. Before editing each, re-read the live description — report 02 found one candidate REVISE
(428's `buildTableau_isSome` framing) had already self-corrected, and the same may have happened
again. A description already correct gets a CURRENT row in the Phase 8 table, not an edit.

**Files to modify**:
- `specs/state.json` - description fields only, via `.claude/scripts/state-write.sh`
- `specs/TODO.md` - regenerated

**Verification**:
- `jq` shows each revised description containing its new clause and no longer containing the
  struck one.
- No `status`, `dependencies`, or `file_scope` field changed by this phase (dependencies are
  Phase 6's territory; 177's `file_scope` is already correct).
- `generate-todo.sh` exits clean.

---

### Phase 6: Dependency wiring, topics, counters, and critical path [NOT STARTED]

**Goal**: Make the graph consistent with the restructured set, close the `active_topics` gap,
repair the `state.json` counters, and re-derive the critical path.

**Tasks**:
- [ ] Wire every edge implied by the restructured set: the new proof-extraction task's `[412]`
      edge; the fifth-residual task's `[434]` edge; any edge Phase 2's verdicts imply for
      169/422/95; and any edge the REVISEs assert in prose. Where prose asserts a gate that no edge
      encodes, either add the edge or downgrade the prose — never leave both readings.
- [ ] Add `metalogic` to `active_topics` (carried by tasks 477/478/479; currently absent, which
      produces no live warning only because all three carriers are `completed` and filtered out).
- [ ] Re-run the dangling-edge scan over the union of `active_projects` and the archive's
      archived+completed sets, **zero-padding before any `sort`/`comm`**. Confirm zero dangling
      edges. Record the padding requirement in the output so the 50-false-positive artifact is not
      rediscovered.
- [ ] Repair the `state.json` counters: recompute `metadata.total_tasks`, `task_counts.*`, and
      `task_counts.total` from `active_projects` itself and write them through `state-write.sh`;
      refresh `metadata.last_sync`. If the `task_counts` key set cannot represent the live status
      breakdown without a schema change (report 02 observed live statuses including `completed`
      and `researching` against a `task_counts` object that carries `implementing` and no
      `completed` key), do NOT invent schema — record the precise argument for leaving the repair
      to `/task --sync` instead. The charter permits that outcome explicitly; an unargued skip is
      what it forbids.
- [ ] Re-derive the critical path per front (decidability/tableau, weak completeness, strong
      completeness, Kamp, FMP, publication, dataset, hygiene) after the restructuring, and state it
      explicitly with the **routine vs. hard split made explicit** per item. Report 02's spine
      (433/434 -> 462 -> 465 -> 428 -> 429 -> 410 -> 411 -> 430 -> 412 -> retained-177, with the
      new fifth-residual task before/alongside 462, and 476 plus the new isValid bridge parallel to
      the spine) is the starting point, not the answer — re-derive it against the live graph.
- [ ] Run `bash .claude/scripts/generate-todo.sh` and confirm clean regeneration with no
      undeclared-topic warning. Also run `bash .claude/scripts/generate-task-order.sh --print` and
      confirm exit 0 with no undeclared-topic stderr.
- [ ] Append the wave map, the critical path, and the counter outcome to the evidence ledger.

**Timing**: 1 hour

**Depends on**: 4, 5

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Report 02 measured a 9-wave decidability spine and zero dangling edges before
the three new tasks existed. Both change with this phase's writes. Re-derive the wave count and
re-run the scan **after** the new edges are wired, and report the post-write numbers, not
report 02's.

**Files to modify**:
- `specs/state.json` - dependency edges, `active_topics`, `metadata`, `task_counts` (via `.claude/scripts/state-write.sh`)
- `specs/TODO.md` - regenerated
- `specs/468_realign_task_programme_from_proof_state_audit/reports/03_implementation-evidence-ledger.md` - append graph section

**Verification**:
- Dangling-edge scan returns zero, with padding applied.
- `metalogic` present in `active_topics`.
- Counters either match a fresh recomputation, or the ledger carries the written argument for
  deferring to `/task --sync`.
- `generate-todo.sh` and `generate-task-order.sh --print` both clean.

---

### Phase 7: Author the rewritten specs/ROADMAP.md [NOT STARTED]

**Goal**: Produce the current roadmap: one current-state statement per front, retitled, every claim
grounded in a named check, machine-annotatable.

**Tasks**:
- [ ] **Retitle.** The file is `# Roadmap: BX Completeness and Publication`; decidability is now the
      largest front and is absent. Give it a title naming decidability alongside completeness.
- [ ] **One current-state statement per front**, no dated block stack, covering: decidability/
      tableau, weak completeness, strong completeness, Kamp, FMP, publication, dataset, hygiene.
      Each front states what is PROVEN, what is OPEN, what is REFUTED, and what the terminus looks
      like.
- [ ] **Distinguish PROVEN from SORRY-FREE explicitly**, with a short statement near the top of why
      they differ in this repo. This is the specific conflation the whole task exists to correct: a
      zero sorry count coexists with theorems never stated, conditional theorems whose hypotheses
      nobody can supply, and one subtree that does not exist on disk.
- [ ] **Correct the completeness front to the re-verified state**: C3 reports zero live structural
      sorries; C2 reports `completeness`, `completeness_dense`, `completeness_discrete`, and
      `Chronicle.countermodel_dense` all clean. Remove any surviving claim that
      `completeness_discrete` is blocked by live sorries, and any critical-path budget for work
      already finished. Note the Kamp `k ≤ 1` scope caveat and the propositional-fragment note as
      the remaining qualifications.
- [ ] **Correct the Stavi/EFGames status**: it is LIVE, not superseded and parked —
      `FormalSystem/Metalogic/WeakCanonical.lean` imports
      `WeakCanonical.EFGames.StaviCompleteness`, with four further live modules importing from
      `EFGames/`. Verify the imports before writing the claim.
- [ ] **State `FormalSystem/Metalogic/Decidability/BiLasso/`'s status honestly** under the
      decidability front: landed sorry-free, carrying `check_correct` and `instDecidableSatAtState`
      (which computes, while measuring `[propext, Classical.choice, Quot.sound]` — computability
      and choice-freedom are different properties), and its reachability status as of the wiring
      work. Fold task 474's existing "Status: landed" block into this front's statement rather than
      leaving it a late addendum. Note that this qualifies the audit's finding F6 ("FMP is
      syntactic, not semantic"), which was reached from `Decidability/FMP/` without accounting for
      BiLasso.
- [ ] **Tombstone refuted routes** with explicit entries, **cross-referencing** the C9 register (a
      section inside `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`)
      rather than duplicating its entries. Include: the unconditional `buildTableau_isSome` (FALSE
      at the engine's `maxBranches` guard, at any fuel); the decidable-branch-gate family collapse
      (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`, `regionLabelCheck`, `rayUpOk`/`rayDnOk`)
      with repair option (c) recorded as closed as formulated; and the in-tree refutation of
      `UnorderedSuccessorLabelClosed`.
- [ ] **Correct the Paper Alignment section**, which lists six tasks as not-started/blocked that
      were archived completed between 2026-08-13 and 2026-08-18 and carries no stale banner.
- [ ] **State the five-residual terminus**, not four. `UniverseClosed`,
      `DifficultyBounded`/`StepLengthBounded`, `MintPaysForTime`, `PostBlockingSettles`, **and**
      `UnorderedSuccessorLabelClosed` — the last now owned by the new task from Phase 4.
- [ ] **Ground every status claim in a named check.** Each PROVEN/OPEN/REFUTED line names the check
      that reproduces it: C2 (axiom sets), C3 (sorry inventory), C4/C5 (reference resolution), C7
      (file counts). A claim no check can reproduce does not go in the file.
- [ ] **Give the file machine-annotatable structure**: `## Phase N: {Title} ({Priority} Priority)`
      headings with `- [ ]` / `- [x]` checkbox items, per `.claude/context/formats/roadmap-format.md`,
      so `roadmap-integration.sh` reports `phases > 0` and `checkboxes > 0`. If a deliberate
      decision is made that the per-front structure cannot carry checkboxes, record that decision
      and its reason **in the file itself** — the charter permits "intentionally unannotatable" only
      as an explicit, argued statement.
- [ ] Carry the per-front critical path from Phase 6 into each front's section, with the
      routine/hard split visible.
- [ ] Run `bash .claude/scripts/roadmap-integration.sh --roadmap specs/ROADMAP.md --state
      specs/state.json` in parse-only mode and record the `<!-- roadmap-structure phases=N
      checkboxes=M table_rows=T parseable=... -->` marker.
- [ ] Run the C5-equivalent replication over the new file.

**Timing**: 2 hours

**Depends on**: 3, 6

**Verification Tier**: prose

**Scope Hypothesis**: Eight fronts are asserted (decidability/tableau, weak completeness, strong
completeness, Kamp, FMP, publication, dataset, hygiene) — the charter's own list. Confirm against
the live `active_topics` set after Phase 6's `metalogic` addition; if a topic carries active work
with no front, add a front for it rather than dropping the work.

**Files to modify**:
- `specs/ROADMAP.md` - rewritten wholesale

**Verification**:
- Exactly one current-state statement per front; zero stacked dated blocks; `grep -c
  "HISTORICAL\|SUPERSEDED\|STALE"` is zero or near-zero in the current file.
- Title names decidability.
- `roadmap-integration.sh` parse-only reports `phases > 0` and `checkboxes > 0`, OR the file
  carries an explicit written statement of why it is intentionally unannotatable.
- Every status line names its grounding check.
- C5-equivalent replication reports zero unresolved module-shaped paths.

---

### Phase 8: Stage 5 report [NOT STARTED]

**Goal**: One artifact carrying the whole decision record, including the explicit list of proposed
status corrections for user decision.

**Tasks**:
- [ ] Write `specs/468_realign_task_programme_from_proof_state_audit/reports/04_realignment-decisions-and-verdicts.md`
      containing, in order:
- [ ] **Task 455 disposition**: ABSORB, with its reasoning — 455's Stage 1 is strictly contained in
      this task's Stage 4(c) (which adds the PROVEN-vs-SORRY-FREE distinction, refuted-route
      tombstones, the C9 cross-reference, and the archive split); 455's Stages 2-4 are contained in
      Stage 2, which extends the verdict vocabulary with ADD and REOPEN. Propose abandonment; do not
      transition.
- [ ] **Stage 1 verification results**, from the Phase 1 ledger, including the correction of the
      charter's stale sixth claim.
- [ ] **The box-anchor verdict**: NEGATIVE, broader than the charter's framing, the whole gate
      family collapsing; task 429 is a redesign, not a repair; artifact cited; probe not re-run.
- [ ] **The per-task verdict table**: one row per active task — task, topic, verdict, evidence,
      action. CURRENT rows say what was checked. Label the dataset-cluster rows explicitly as
      carried forward from `specs/reviews/review-2026-08-24.md` rather than freshly verified, so the
      distinction is visible to whoever acts on the report. Note that task 298's c7 regeneration was
      observed actively running; re-check its line/metadata counts before treating it as blocked.
- [ ] **Every new task's full spec** and every proposed removal with its argument.
- [ ] **Every dependency edge added or removed**, with justification, plus the zero-dangling-edge
      result and the `metalogic` topic addition.
- [ ] **The ROADMAP changes** and the machine-checked grounding for each, including the explicit
      note that `check-module-invariants.sh` C5 **excludes** `specs/` from its walk, so the
      charter's "C5 passes over the rewritten ROADMAP.md" criterion is satisfied by a documented
      C5-equivalent replication, not by C5 itself.
- [ ] **The resulting critical path per front**, with the routine/hard split explicit.
- [ ] **The explicit list of proposed status corrections** for user decision: 455 -> abandoned; the
      outcome of the 169/422/95 adjudication; no REOPEN for 165/432/436/170 (all four CURRENT, with
      170 independently re-confirmed by C2); and anything else Phases 2-6 surfaced. State clearly
      that none was transitioned.

**Timing**: 1.5 hours

**Depends on**: 2, 5, 6, 7

**Verification Tier**: prose

**Scope Hypothesis**: The verdict table must cover every active task with none silently skipped.
Report 02's own §7 self-flagged an arithmetic discrepancy in its hand-tally. Derive the row set
programmatically from `jq -r '.active_projects[].project_number'` at write time and assert
`row count == active_projects | length`; do not hand-tally, and do not carry report 02's count
forward as a literal.

**Files to modify**:
- `specs/468_realign_task_programme_from_proof_state_audit/reports/04_realignment-decisions-and-verdicts.md` - new report

**Verification**:
- Row count equals the live `active_projects` length.
- All nine required report sections present.
- The proposed-corrections list is explicit and states that nothing was transitioned.

---

### Phase 9: Final verification gate [NOT STARTED]

**Goal**: Check the charter's section-8 criteria one by one and record the outcome of each.

**Tasks**:
- [ ] Every active task has a verdict; none silently skipped — assert row count against
      `active_projects | length`.
- [ ] Zero dangling dependency edges across `active_projects` — re-run the padded scan.
- [ ] `bash .claude/scripts/generate-todo.sh` regenerates cleanly with no undeclared-topic warning;
      `generate-task-order.sh --print` exits 0.
- [ ] C5 over the rewritten `specs/ROADMAP.md` — run the C5-equivalent replication and **also** run
      `bash scripts/check-module-invariants.sh` to confirm C5 proper still passes repo-wide.
      Record explicitly that C5's own walk prunes `specs/`, so the replication is what actually
      covers the roadmap.
- [ ] The Stage 1b box-anchor verdict is recorded (NEGATIVE).
- [ ] `specs/ROADMAP.md` contains no status claim no check can reproduce — grep the status
      vocabulary and confirm each occurrence names its grounding check.
- [ ] 177 is divided, or a written argument for leaving it whole is in the report — confirm the
      retained-half text is in place and 472's territory is excluded.
- [ ] Confirm the hard constraints held: `git diff --stat` shows no `.lean` file touched; no
      existing task moved to `completed`/`abandoned`/`expanded`; every `specs/state.json` write went
      through `state-write.sh`; `specs/TODO.md` was only ever regenerated.
- [ ] Append the gate results to the report and write the implementation summary.

**Timing**: 0.5 hours

**Depends on**: 8

**Verification Tier**: prose

**Files to modify**:
- `specs/468_realign_task_programme_from_proof_state_audit/reports/04_realignment-decisions-and-verdicts.md` - append gate results
- `specs/468_realign_task_programme_from_proof_state_audit/summaries/01_programme-realignment-summary.md` - implementation summary

**Verification**:
- All eight charter criteria have a recorded PASS or an argued exception.
- All four hard constraints confirmed held.

---

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` passes (C1-C11), with C2/C3 quoted verbatim in the
      evidence ledger.
- [ ] `lake build` and `lake build BimodalTest` both exit 0 (unchanged — this task edits no Lean).
- [ ] `bash .claude/scripts/generate-todo.sh` exits clean, no undeclared-topic warning.
- [ ] `bash .claude/scripts/generate-task-order.sh --print` exits 0.
- [ ] Dangling-edge scan (zero-padded) returns zero across `active_projects` union archive.
- [ ] C5-equivalent replication over `specs/ROADMAP.md` and `specs/ROADMAP-ARCHIVE.md` returns zero
      unresolved module-shaped paths.
- [ ] `roadmap-integration.sh` parse-only reports `phases > 0` and `checkboxes > 0`, or the file
      carries the argued unannotatable statement.
- [ ] `jq` confirms three new tasks at `not_started`, and confirms no existing task changed status.
- [ ] `git diff --stat` shows zero `.lean` files touched across the whole implementation.

## Artifacts & Outputs

- `specs/468_realign_task_programme_from_proof_state_audit/plans/01_programme-realignment-execution.md` (this plan)
- `specs/468_realign_task_programme_from_proof_state_audit/reports/03_implementation-evidence-ledger.md`
- `specs/468_realign_task_programme_from_proof_state_audit/reports/04_realignment-decisions-and-verdicts.md`
- `specs/468_realign_task_programme_from_proof_state_audit/summaries/01_programme-realignment-summary.md`
- `specs/ROADMAP.md` (rewritten)
- `specs/ROADMAP-ARCHIVE.md` (new)
- `specs/state.json` (three new tasks, description REVISEs, dependency edges, `active_topics`,
  counters — all via `.claude/scripts/state-write.sh`)
- `specs/TODO.md` (regenerated)

## Rollback/Contingency

Every change is confined to `specs/**` markdown and `specs/state.json`; no `.lean` file is touched,
so no build state can regress. Per-phase commits (`per-substep` commit mode throughout) make each
phase independently revertible with `git revert` of that phase's commit.

- **`state.json` corruption**: `state-write.sh` validates before `mv`, so a malformed filter fails
  closed with the file unchanged. If a semantically wrong write lands, revert that phase's commit
  and re-run `generate-todo.sh`.
- **ROADMAP split loses content**: `specs/ROADMAP-ARCHIVE.md` is created by verbatim move in
  Phase 3, and the pre-split file remains in git history. Recovery is `git show HEAD~N:specs/ROADMAP.md`.
- **A new task is created in error**: it is at `not_started` with no artifacts and no dependents;
  removing its entry and decrementing `next_project_number` via `state-write.sh` is clean.
- **Phase 2 adjudication proves wrong later**: its outcome is a description REVISE and a *proposed*
  status correction, never a transition — the user's decision point is preserved by construction.
