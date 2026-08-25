# Stage 5 Report: Realignment Decisions and Verdicts — Task #468

**Task**: 468 - Programme realignment from a verified proof-state audit
**Completed**: 2026-08-25
**Dependencies**: reports 01 (charter), 02 (Stage 1 verification), 03 (implementation evidence
ledger, this task's own Phases 1-7)
**Standards**: report-format.md, subagent-return.md

This report carries the whole decision record for task 468's implementation: every verdict, every
new task, every REVISE, every dependency-graph change, the ROADMAP.md rewrite's grounding, the
resulting critical path, and — most importantly — the explicit list of proposed status
corrections for the user to act on. **No existing task's status was transitioned by this task.**
Every "propose" or "recommend" below is a recommendation, not an action.

---

## 1. Task 455 disposition: ABSORB (propose abandonment)

**Verdict: ABSORB**, established by report 02 §3 and re-confirmed here.

Evidence:
- 455's Stage 1 (bring `specs/ROADMAP.md` and every remaining active task into agreement with
  progress actually made, grounded in `check-module-invariants.sh` C2/C3/C4/C5/C7) is a **strict
  subset** of this task's own Stage 4(c)/Phase 7, which additionally delivers the PROVEN-vs-
  SORRY-FREE distinction, refuted-route tombstones cross-referencing the C9 register, and the
  archive split (amendment 10c) — content 455's own scope never asked for.
- 455's Stages 2-4 (per-task anchor sweep, five-verdict issuance: CURRENT/RE-ANCHOR/RE-SCOPE/
  SUPERSEDED/OBSOLETE) are contained in this task's own Phase 2/Phase 8 survey, which extends the
  verdict vocabulary with ADD and REOPEN beyond 455's four (`CURRENT`/`REVISE`/`DIVIDE`/`REMOVE`
  plus `ADD`).
- 455 currently carries `dependencies: [452, 454, 468]` — it cannot run before this task
  regardless of disposition.
- Every piece of 455's scope (the full active-set survey, the file-scope/anchor corrections such
  as 177) is covered by §2 below; nothing in 455 is NOT covered.

**Recommendation**: propose 455 for abandonment once this task's realignment is acted on by the
user. **Not transitioned here.**

---

## 2. Stage 1 verification results (from Phase 1 of the evidence ledger)

Full detail: `specs/468_.../reports/03_implementation-evidence-ledger.md` (Phase 1 section).
Summary:

- **`scripts/check-module-invariants.sh`, full run, this dispatch (2026-08-25)**: `lake build`
  exit 0, `lake build BimodalTest` exit 0, **all 11 checks PASS**. C2: all four flagship theorems
  (`completeness`, `completeness_dense`, `completeness_discrete`,
  `Chronicle.countermodel_dense`) depend on exactly `[propext, Classical.choice, Quot.sound]` —
  no `sorryAx`. C3: **zero** live structural sorries tree-wide (Boneyard excluded).
- **Six Stage 1(a) claims re-confirmed by symbol name**, all unchanged except the sixth, which is
  the load-bearing correction of this whole task: `countermodel_discrete` as "the only live
  structural sorry" is **STALE** — the sorry count is now zero (closed by tasks 477→478→479). The
  soundness/completeness metatheory front (charter's F7) is **DONE**, not nearly-done, axiom-clean
  for all four frame classes.
- **Box-anchor artifact prerequisites re-verified without re-running the probe** (amendment 10a):
  all four named probes live, `BoxSpreadProbe.lean`'s five `#guard_msgs` blocks still hold,
  `lake build BimodalTest` exits 0. **Verdict: NEGATIVE**, cited from
  `specs/archive/418_.../artifacts/boxanchored-finding.md`. See §3.
- Task 470 item (G)'s repair of 177's `file_scope` confirmed still resolvable, no duplicate.
- Task 472/473's corrections confirmed landed (spot-checked file existence and the 473 deletion's
  absence from live code).
- `active_projects | length` = 48 at Phase 1 (51 after Phase 4's three creations). Dangling-edge
  scan (zero-padded): **zero** dangling edges, both before and after this task's writes.

---

## 3. Box-anchor verdict

**NEGATIVE**, and broader than the charter's original framing anticipated. The entire
decidable-branch-gate family — `boxAnchoredCheck`, `boxGridCheck`, `regionGate`,
`regionLabelCheck`, `rayUpOk`/`rayDnOk` — collapses to `false` on any branch that mints a world,
because task 418's sound fix (removing unsound cross-world temporal-copy propagation) removed the
only route by which `T(Gφ)`/`T(Hφ)` reach a freshly minted world. **Task 429 is a redesign, not a
repair.** Repair option (c) (weaken only the anchor) is **closed as formulated** —
`boxGridCheck` fails for the same structural reason, so weakening only the anchor buys nothing.
Recommended route: option (a), propagate `T(□φ)` itself to the fresh world (S5 axiom-4/5 pattern),
now named explicitly in task 429's own description (Phase 5 REVISE). Probe **not** re-run, per
amendment 10a — the artifact citation is the evidence.

---

## 4. Per-task verdict table

Every one of the 51 `active_projects` entries (row set derived from a fresh `jq -r
'.active_projects[].project_number'` at write time; **51 rows below, matching `active_projects |
length` = 51 exactly** — none silently skipped). CURRENT rows state what was checked. Rows
labeled "carried" are restated from `specs/reviews/review-2026-08-24.md` (one day old at this
task's dispatch), not independently re-derived by this task — the dataset cluster sits outside
this task's decidability/completeness/roadmap charter.

### Decidability / tableau front (freshly verified this dispatch)

| Task | Status | Verdict | Evidence |
|---|---|---|---|
| 410 | planned | CURRENT | Internalizes tableau branches; unaffected. |
| 411 | not_started | CURRENT | Depends on 410; no drift. |
| 412 | not_started | **REVISE (applied)** | Struck the stale `countermodel_discrete`/`Transfer.lean:1242` clause; added 482 as `.extractionFailed`-owner note. |
| 421 | completed | CURRENT | Acceptance criterion already corrected (uses C3, not stale inline grep). |
| 428 | blocked | **REVISE (applied)** | Added ASSESS/C9-register escape clause for split-arm fuel scaling. Opening paragraph left untouched (CURRENT on that point). |
| 429 | not_started | **REVISE (applied)** | Added recommended-route sentence (option (a)) per amendment 10a. |
| 430 | not_started | CURRENT | Already owns items (a)/(b) exactly as amendment 10b requires. |
| 433 | partial | CURRENT | Own description already delegates residual work to 463/465. |
| 434 | partial | CURRENT | Same pattern, delegates to 462/464. |
| 462 | not_started | **REVISE (applied)** | Added sequencing note naming new task 481. |
| 463 | not_started | CURRENT | No drift. |
| 464 | not_started | CURRENT | Correctly the density-coordinate research item. |
| 465 | not_started | CURRENT | Correctly scoped as mechanical restatement of settled residuals only. |
| 469 | completed | CURRENT | `ROADMAP.md` BiLasso "Status: landed" block confirmed present, now folded into Phase 4. |
| 470 | completed | CURRENT | Ran the graph/metadata repair; counter repair remains open (see §6). |
| 472, 473 | completed | CURRENT | Territory confirmed disjoint from 177's retained half. |
| 474 | completed | CURRENT | BiLasso wiring confirmed. |
| 475 | completed | CURRENT | Closes Addendum 2 Gap 1; 476 correctly gates on it. |
| 476 | not_started | CURRENT | Best-scoped semantic-FMP ADD candidate; no action. |
| 477 | completed | CURRENT | `ta_qz_target_structure_plumbing` — landed `QZStructure`/`goodGroupable` at `ℚ ×ₗ ℤ`; first of the three-task chain that closed `countermodel_discrete`. |
| 478 | completed | CURRENT | `tb_groupable_companion_lemma` — landed the groupable-companion lemma via `KEquiv`; the only risk item of the chain, closed. |
| 479 | completed | CURRENT | `tc_close_countermodel_discrete_at_base` — closed `countermodel_discrete` itself; C3 confirms zero live sorries as a direct result. |
| 480 | not_started | **ADD (created)** | `bridge_isvalid_bool_to_semantic_validity`, routine, no deps, startable today. |
| 481 | not_started | **ADD (created)** | `discharge_or_replace_unorderedsuccessorlabelclosed_residual`, deps `[434]`, hard. |
| 482 | not_started | **ADD (created)** | `discharge_proof_extraction_completeness`, deps `[412]`, open mathematics. |
| 468 (self) | implementing | — | Self; deps `[469,426,451]` all completed. |

### Strong completeness / completeness front

| Task | Status | Verdict | Evidence |
|---|---|---|---|
| 95 | not_started | **REMOVE (propose abandonment)** | Confirmation-pass content fully subsumed by this task's Phase 1; the sorry count it would confirm is now zero, not one. See §5. |
| 169 | not_started | **REMOVE (propose abandonment)** | Sole deliverable (close `countermodel_discrete`) already accomplished via 477-479, a different route. See §5. |
| 178 | not_started | **REVISE (applied)** | Rescoped decidability-example criterion to the propositional fragment; carried from 2026-08-24 review M-7, re-confirmed. |
| 193 | not_started | CURRENT | Deps include completed 470; no drift. |
| 362 | not_started | CURRENT (with a flagged observation) | Capstone, correctly gated; Legs A/C/D unblocked now that all four weak engines are DONE. **Observation**: its own `169` dependency edge and stale "170 not_started"/"169 not_started" prose commentary should be revisited if/when 169 is abandoned — not actioned by this task (out of Phase 2's declared 3-task scope). |
| 413 | completed | CURRENT | Unaffected, starter of the completeness chain. |
| 421, 423, 424, 425 | completed | CURRENT | Strong-completeness starter cluster, unaffected. |
| 422 | researched | **REMOVE (propose abandonment)** | Specified deliverables permanently refuted (isomorphism) and superseded (477-479's different route). See §5. |
| 426 | completed | CURRENT | Deps corrected to `[470]`. |

### Formula-refactor / publication front

| Task | Status | Verdict | Evidence |
|---|---|---|---|
| 177 | not_started | **REVISE (applied, DIVIDE verdict)** | Replaced wholesale with report 02 §6's retained-half text, 472/473's territory explicitly excluded. `file_scope` unchanged (already correct). |

### Repo-hygiene / code-quality / literature / other

| Task | Status | Verdict | Evidence |
|---|---|---|---|
| 451 | completed | CURRENT | Boneyard consolidation, unaffected. |
| 455 | not_started | **ABSORB (propose abandonment)** | See §1. |
| 461 | blocked | KEEP as blocked (carried) | Blocked on literature acquisition. |
| 125 | not_started | KEEP, move off critical path (carried) | Dataset cluster. |
| 127, 128 | not_started | ABANDON-or-park candidate (carried) | Antagonistic to the termination-work front. |

### Dataset/misc cluster (carried from the 2026-08-24 review, not independently re-derived this
dispatch — out of this task's charter)

| Task | Status | Verdict (carried) |
|---|---|---|
| 219 | researched | KEEP (depends on 231) |
| 231 | not_started | KEEP, downgrade priority, must follow 298 |
| 257 | blocked | REVISE + reclassify, blocked on human action |
| 282 | partial | REVISE, null description reconstructed by 470, not re-verified |
| 296 | partial | KEEP (review-verified) |
| 298 | partial | KEEP, top of cluster — **note**: c7 regeneration process observed actively running at realignment time (live PID, 645+ CPU-minutes, output 1.5M+ lines vs. the review's 13,749-line truncation snapshot); do not disturb, re-check counts before treating as still blocked. |

**Row-count check**: the task numbers appearing in the four verdict tables above (Decidability/
tableau; Strong completeness/completeness; Formula-refactor/publication; Repo-hygiene/code-
quality/literature/other) plus the Dataset/misc cluster table were extracted and diffed
programmatically against a fresh `jq -r '.active_projects[].project_number'` (51 entries). The
diff is empty in both directions: every one of the 51 live entries has exactly one row above, and
no row above cites a task absent from `active_projects` (432 and 436 appear only in §4a, clearly
marked archived/historical context for tasks 481 and 464 respectively, and are correctly excluded
from the 51-row count).

### 4a. Section 2(c) — five previously-flagged tasks (carried from report 02 §4, unaffected by
this dispatch's findings, restated here for completeness)

165 (archived completed) — CURRENT, its own record already documents the residue accurately, no
correction needed. 432 (archived completed) — CURRENT, candor about `UnorderedSuccessorLabelClosed`
confirmed genuine and now has an owner (task 481). 436 (archived completed) — CURRENT, its open
density coordinate is task 464's job. 170 (archived completed) — CURRENT, independently
re-confirmed by this dispatch's C2 run (`completeness_dense` clean). 177 — see above.

---

## 5. Proposed abandonments — full arguments

**422** (`build_discrete_chronicle_over_non_archimedean_block_carrier_with_restricted_coherence`):
its specified deliverables — (a) a block-decomposition/densification/isomorphism into `ℚ ×ₗ ℤ`,
and (b) three restricted-coherence analogues at that carrier — are permanently REFUTED at the
isomorphism level (its own report 01, machine-checked: no linearly ordered abelian group has
order type `ℤ+ℤ`) and, independently, SUPERSEDED: the goal they existed to serve (closing
`WeakCanonical.countermodel_discrete`) has already been reached by a different, completed
three-task chain (477→478→479) consuming neither deliverable. No active task references either
deliverable's symbols.

**169** (`build_discrete_chronicle...` consumer): sole deliverable — consume 422's output to close
`countermodel_discrete`, delete the `Transfer.lean` sorry, re-verify `#print axioms completeness`
— already fully accomplished via a different route. No remaining consumer for its `file_scope`.

**95** (confirmation pass): narrow content (re-run `#print axioms`; confirm sorry count is exactly
1 in `Transfer.lean`; record that discharging `countermodel_discrete` is its own task) fully
subsumed by this task's own Phase 1 — the sorry count is now zero, not one, so step (2) as
originally written can no longer even be satisfied; nothing distinct remains for a dedicated task
to do.

**455**: see §1.

Full evidence and symbol-level citations for 169/422/95:
`specs/468_.../reports/03_implementation-evidence-ledger.md` (Phase 2 section).

**None of these four tasks was transitioned.** All four remain at their pre-existing status.

---

## 6. New tasks' full specs, and every dependency edge added/removed

### 6a. Three new tasks created (task 480, 481, 482)

**480 — `bridge_isvalid_bool_to_semantic_validity`** (`lean4`, topic `decidability`, effort
`small`, deps `[]`, file_scope `Decidability/Correctness.lean`, `Decidability/
DecisionProcedure.lean`): prove `isValid_sound` bridging `DecisionProcedure.isValid`'s `Bool` API
back to `⊨ φ`, consuming the already-landed `decide_sound'`. Routine engineering, startable today,
independent of the whole decidability chain. Not folded into task 430 (engine-facing vs.
decision-procedure-facing directions are different theorems).

**481 — `discharge_or_replace_unorderedsuccessorlabelclosed_residual`** (`lean4`, topic
`decidability`, effort `large`, deps `[434]`, file_scope `Decidability/Verified/Termination/
MintBound.lean`): the fifth termination residual, refuted in-tree at a nonempty universe; three
acceptable outcomes (discharge, weaker replacement, or a C9 register entry — the last a complete,
valid deliverable). Sequencing: before or alongside task 462 (same setting).

**482 — `discharge_proof_extraction_completeness`** (`lean4`, topic `decidability`, effort
`large`, deps `[412]`, file_scope `Decidability/ProofExtraction.lean`, `Decidability/Verified/
Refutation/`): eliminate `.extractionFailed` as a live outcome on a genuinely closed tableau — open
mathematics, multi-month, must not be re-described as engineering; sequenced after 412 rather than
folded into 412's acceptance criteria, per this task's own planner decision (see the plan's
"Planner decisions taken here" §1).

Full descriptions (verbatim, as written to `specs/state.json`): see
`specs/468_.../reports/03_implementation-evidence-ledger.md` (Phase 4 section) for the creation
record, or `jq -r '.active_projects[] | select(.project_number==480 or .project_number==481 or
.project_number==482) | .description' specs/state.json` for the live text.

### 6b. Dependency edges

- **482's `[412]` edge** and **481's `[434]` edge**: set at creation (Phase 4).
- **No new edge added for 169/422/95's REMOVE verdict** — a status transition (not performed by
  this task) would be the trigger for any edge change, not the verdict itself. **Flagged**: task
  362 lists `169` as a dependency; this edge should be reviewed if/when 169 is abandoned.
- **462's sequencing note (task 481) was deliberately NOT wired as a hard dependency edge** —
  "before or alongside" explicitly permits parallel execution, which a blocking edge would
  foreclose; the prose is advisory coordination, not a gate, and there is exactly one coherent
  reading. See the evidence ledger's Phase 6 section for the full reasoning.
- **`metalogic` added to `active_topics`** (carried by completed tasks 477/478/479, previously
  absent).
- **Dangling-edge scan** (zero-padded, re-run after all writes): **zero dangling edges** across
  the union of `active_projects` (51 entries) and the archive's archived+completed sets (405
  entries archived-side ∪ 51 active-side = 456 valid IDs). Zero-padding requirement recorded so
  the earlier 50-false-positive lexicographic-sort artifact is not rediscovered.

---

## 7. ROADMAP.md changes and their grounding

`specs/ROADMAP.md` was split (Phase 3): historical sediment (1,107 of 1,970 original lines — the
stacked dated Overview blocks, retired module-import diagram, dead-end catalogs, the 111-row
task-cross-reference table, and more) moved verbatim to `specs/ROADMAP-ARCHIVE.md` with a
provenance header; nothing was lost (exact line-count arithmetic verified: 1,107 + 863 = 1,970).

`specs/ROADMAP.md` was then rewritten wholesale (Phase 7): retitled to name decidability alongside
completeness; opens with the PROVEN-vs-SORRY-FREE distinction; organized into `## Phase 1`
through `## Phase 7`, one current-state statement per front (weak/strong completeness,
decidability/tableau, Kamp/expressive completeness, FMP, publication, dataset, repository
hygiene), each with `- [ ]`/`- [x]` checkboxes and a "Check grounding" line naming which
`check-module-invariants.sh` check(s) support it; a `## Tombstoned Routes` section
cross-referencing the C9 register; the durable technical-reference sections retained (BX Axiom
System, Irreflexive Truth Semantics, Canonical Model Construction, Quasimodel/Filtration
Infrastructure, Burgess-Xu Until-Induction Technique, Representation Theorem Goal) with the Paper
Alignment Programme section corrected (six tasks previously shown not-started/blocked are shown
against their actual archived status: five completed, one expanded); a closing Recommended
Priority Order.

**Verification-gate qualification, stated explicitly per the plan's own risk register**:
`scripts/check-module-invariants.sh`'s **C5 check itself excludes `specs/` from its directory
walk** (`dirs[:] = [... "specs" ...]`), so it **never reads** `specs/ROADMAP.md` or
`specs/ROADMAP-ARCHIVE.md` — the charter's literal "C5 passes over the rewritten ROADMAP.md"
criterion is not directly satisfiable by C5 itself. This task instead ran a **C5-equivalent
replication** (C5's own `mod_re` regex and `resolves()` logic, applied standalone to both files):
**zero unresolved module-shaped paths in either file**. Both are true simultaneously: (a) C5
proper still passes repo-wide (confirmed, Phase 9), and (b) the C5-equivalent replication is what
actually covers the roadmap files, since C5 proper structurally cannot.

`roadmap-integration.sh --roadmap specs/ROADMAP.md --state specs/state.json` (parse-only) printed
the structure marker `<!-- roadmap-structure phases=7 checkboxes=39 table_rows=57 parseable=true
-->` — `phases > 0` and `checkboxes > 0`, satisfying the machine-annotatability criterion. The
script's own later JSON-assembly step failed downstream with `jq: Argument list too long` (a
pre-existing script limitation triggered by cross-referencing many cited task numbers against a
now-larger `state.json`) — this is unrelated to the structure marker already captured, and fixing
it is outside this task's charter (recorded as a finding, not actioned).

---

## 8. Resulting critical path per front, routine/hard split explicit

Full derivation: `specs/468_.../reports/03_implementation-evidence-ledger.md` (Phase 6 section).

**Decidability/tableau spine** (11 waves, re-derived by longest-path over the live dependency
graph, not carried forward from any prior hand-drawn diagram):

```
462(ROUTINE) -> 463(ROUTINE) -> 464(HARD) -> 465(ROUTINE) -> 428(HARD) -> 429(HARD)
  -> 410 -> 411 -> 430(HARD) -> 412 -> 482(HARD)  [-> 177 retained-half, parallel to 482]

481(HARD, parallel entry, before/alongside 462)
480(ROUTINE, independent, startable today)
476(HARD, parallel, gated only on 475=completed)
```

**Other fronts**: consequence-completeness capstone (362) is unblocked (all four weak engines
DONE); semantic FMP (476) and proof-extraction completeness (482) are both open mathematics,
multi-month, running parallel to the spine; publication/documentation (177/178/monograph tasks)
gated on the spine or independently schedulable; dataset/training infrastructure is an independent
front (carried-forward priorities); repository hygiene is complete except the counter repair
(§9 below).

---

## 9. state.json counters — repair deferred, argued

`.metadata.total_tasks` (42) and `.task_counts.*`/`.total` (42) remain **unchanged and still
wrong** against the live 51-entry breakdown. **Argument for deferral** (per the plan's explicit
permission): the live status set includes `completed` (16) and a plural `researched` (2), neither
representable in the current `task_counts` key set without inventing a schema convention — and
`grep -rln "task_counts\|\.metadata\.total_tasks" .claude/scripts/ .claude/hooks/` returns **zero
files**, so there is no consumer contract anywhere to confirm which of two equally-plausible
semantics (count everything, vs. count only non-terminal "still active" work) was originally
intended. Recommend `/task --sync`, or a dedicated schema-clarification task, resolve this with
the user rather than this task guessing. Full argument:
`specs/468_.../reports/03_implementation-evidence-ledger.md` (Phase 6 section).

---

## 10. Explicit list of proposed status corrections (user decision — nothing transitioned)

- **455 → abandoned**, once this task's realignment lands (§1).
- **169 → abandoned** (§2, §5).
- **422 → abandoned** (§2, §5).
- **95 → abandoned** (§2, §5).
- **No REOPEN proposed** for 165/432/436/170 — all four's archived-completed status is CURRENT
  (§4a).
- **362's `169` dependency edge** should be revisited if/when 169 is abandoned — not itself a
  status-correction proposal, but a graph consequence of one (§4, §6b).
- **`state.json` counters** (`metadata.total_tasks`, `task_counts.*`) need a schema decision before
  repair — recommend `/task --sync` or a dedicated task (§9). This is a data-quality item, not a
  task-status correction.

**Nothing above was transitioned by task 468.** Every item is a recommendation for the user (or a
future `/task`/`/todo` invocation) to act on.

---

## References

- `specs/468_realign_task_programme_from_proof_state_audit/reports/01_proof-state-audit-and-realignment-charter.md`
- `specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md`
- `specs/468_realign_task_programme_from_proof_state_audit/reports/03_implementation-evidence-ledger.md`
- `specs/468_realign_task_programme_from_proof_state_audit/plans/01_programme-realignment-execution.md`
- `specs/ROADMAP.md`, `specs/ROADMAP-ARCHIVE.md`
- `specs/reviews/review-2026-08-24.md`
