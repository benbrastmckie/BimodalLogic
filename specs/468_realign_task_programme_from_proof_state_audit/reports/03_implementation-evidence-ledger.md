# Implementation Evidence Ledger: Task #468

**Purpose**: durable record of every fact later phases of this task's implementation cite,
established fresh at implementation time (2026-08-25) rather than inherited from report 02
(2026-08-25T11:00-12:00Z, ~hours earlier) without independent re-confirmation. Later phases
append sections rather than re-running these checks.

**Standards**: report-format.md, subagent-return.md

---

## Phase 1 — Baseline re-verification

### C2/C3/C4/C5/C7 — full `check-module-invariants.sh` run, this dispatch

```
$ bash scripts/check-module-invariants.sh
=== Module invariants: 391e9928f ===

PASS  B0   Boneyard exclusion covers exactly 1 directory
PASS  C1   lake build exits 0
PASS  C1   lake build BimodalTest exits 0

PASS  C2   all four flagship axiom sets match baseline
            'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
            'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]

PASS  C3   structural sorry inventory is ZERO across FormalSystem/ (Boneyard/ excluded)

PASS  C4   all 1438 FormalSystem/BimodalTest import lines resolve
PASS  C5   all module-shaped paths in 1662 markdown files resolve (4 allowlisted)
PASS  C6   all 22 unreachable live module(s) are manifested
PASS  C7   467 live .lean files (413 FormalSystem / 53 Tests); 445 reachable, 22 unreachable
PASS  C8   every FormalSystem/ and Metalogic/ subdirectory has exactly one sibling aggregator
PASS  C11  all 497 archived import lines in 156 archived file(s) resolve (6 waived)
PASS  C9   zero task-number citations under FormalSystem/
PASS  C10  zero references to FormalSystem/{docs,latex,typst} outside specs/

ALL CHECKS PASSED
```

Both `lake build` and `lake build BimodalTest` exit 0. C2's four flagship axiom sets are
identically clean (`[propext, Classical.choice, Quot.sound]`, no `sorryAx`) to report 02's
recording. C3's structural sorry inventory is zero. This is a fresh, independent re-run at
implementation time, not a restatement of report 02.

### Six Stage 1(a) claims, re-confirmed by symbol name

1. **No declaration takes `DecisionProcedure.isValid` as its subject.** `grep -rn "isValid"
   FormalSystem/Metalogic/Decidability/` (Boneyard excluded) shows only: `DecisionResult.isValid`
   (`DecisionProcedure.lean:93`, `Bool`-valued wrapper), `DecisionProcedure.isValid`
   (`DecisionProcedure.lean:317-318`, `def isValid (φ) (fc) : Bool := (decide φ (fc :=
   fc)).isValid`), the case-exhaustion lemma over the four-constructor result type
   (`Correctness.lean:122-126`, pure `simp`), and `truthAt_of_isValid`
   (`Verified/Decidable.lean:2412`) — which is about `SoundnessLemmas.IsValid`, a semantic-side
   predicate distinct from `DecisionProcedure.isValid`. No theorem has
   `DecisionProcedure.isValid _ = true` as hypothesis or conclusion. **CONFIRMED, unchanged.**
2. **`ruleSound_of_mem_allRulesForFC` is not lifted; no `allClosed → valid` exists.**
   `ruleSound_of_mem_allRulesForFC` (`Verified/Decidable.lean:3155`) is real, unique, cited only
   in prose (`Correctness.lean:93`, README files). `grep -rn "allClosed"` over
   `Verified/Decidable.lean` and `Saturation.lean` finds only prose usages and
   `upgrade_allClosed`/`buildTableauAt_allClosed_imp`-style statements, none stating branch
   satisfiability. **CONFIRMED, unchanged.**
3. **`serialityRule`/`timeLinearity` excluded from `allRulesForFC`, no `RuleSound` obligation
   discharged for either.** `serialityRule_not_mem_allRulesForFC` and
   `timeLinearity_not_mem_allRulesForFC` both proved at `Verified/RuleSpec.lean:337,342`.
   **CONFIRMED, unchanged.**
4. **`Verified/Refutation/` does not exist.** `ls
   FormalSystem/Metalogic/Decidability/Verified/Refutation/` → "No such file or directory".
   **CONFIRMED, unchanged.**
5. **`ProofExtraction.lean` has zero theorems; `verifyProof` is constantly `true`.**
   `ProofExtraction.lean:345`: `def verifyProof (_phi : Formula) (_proof : DerivationTree .Base []
   _phi) : Bool := true`. `grep -n "^theorem\|^lemma"` on the file: no output. **CONFIRMED,
   unchanged.**
6. **`countermodel_discrete` as "the only live structural sorry" — STALE.** `grep -rn
   --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -v Boneyard` — empty output, zero
   live structural sorries anywhere in the tree. C3 (above) independently confirms zero.
   **CONFIRMED STALE — this is the correction, grounded in C2/C3 fresh this dispatch, not
   restated.** The soundness/completeness metatheory front (charter's F7) is DONE, axiom-clean
   for all four frame classes, modulo the Kamp `k ≤ 1` scope caveat and the propositional-fragment
   note (both unaffected by this correction).

### Box-anchor artifact prerequisites (probe NOT re-run, per amendment 10a)

- All four named probes live: `Tests/BimodalTest/BoxSpreadProbe.lean`, `RegionGateProbe.lean`,
  `RayRegionProbe.lean`, `TemporalWitnessProbe.lean` (confirmed by `ls`).
- `BoxSpreadProbe.lean` carries five `#guard_msgs` blocks at lines 168, 177, 185, 221, 229,
  pinning the post-fix `false` verdicts.
- `lake build BimodalTest` exits 0 (see C1 above, this dispatch) — the guard blocks still hold.
- **Verdict: NEGATIVE**, cited from `specs/archive/418_.../artifacts/boxanchored-finding.md`, not
  re-derived. The decidable-branch-gate family (`boxAnchoredCheck`, `boxGridCheck`, `regionGate`,
  `regionLabelCheck`, `rayUpOk`/`rayDnOk`) collapses to `false` on any branch minting a world.
  **Task 429 is a redesign, not a repair.** Probe not re-run, per amendment 10a.

### Task 470 item (G) — 177's `file_scope`

`jq -c '.active_projects[] | select(.project_number==177) | .file_scope' specs/state.json` →
`["README.md","specs/ROADMAP.md","FormalSystem/","docs/"]` — resolvable, no duplicate.
**CONFIRMED repaired; not redone.**

### Task 472/473 spot-check

Both `completed` (`jq` confirmed). Spot-checked file existence for a sample of 472's nine named
files (`Verified/README.md`, `FMP/README.md`, `DecisionProcedure.lean`,
`Verified/Decidable.lean`, `WeakCanonical.lean`, `RealModel/ShuffleReal.lean`,
`Metalogic/Soundness.lean`, `WeakCanonical/PriorExpressivenessDense.lean` — the latter two at
paths one directory level different from a naive guess, both confirmed present by `find`) — all
present. 473's deletion confirmed landed: `grep -rn "neg_2var_vec_ea\|reflatten_neg_step"
FormalSystem/` (Boneyard excluded) returns only doc/comment references inside
`Prop42Vacuity.lean`/`Prop42Contentful.lean`/`EANegationClosure.lean`/`NfMultiAnchorBridge.lean`
recording the deletion as history — no live declaration of either symbol remains.

### `specs/state.json` recomputation

- `active_projects | length` = **48** (matches report 02's measurement; confirmed unchanged
  across the 13-sibling-agent session per the plan's Scope Hypothesis).
- `next_project_number` = **480** (matches report 02's measurement; confirmed unchanged).
- Status breakdown (fresh `jq` tally, this dispatch): `blocked=3, completed=16, implementing=1,
  not_started=20, partial=5, planned=1, researched=2`. Sums to 48. (Task 468 itself now shows
  `implementing` rather than report 02's `researching`, since this task has advanced a stage —
  the only breakdown delta from report 02, and expected.)
- `.metadata.total_tasks` = 42, `.task_counts.total` = 42 — both still wrong against the live 48,
  confirming report 02's finding is unchanged. `.task_counts` = `{blocked:3, implementing:1,
  not_started:31, partial:5, planned:1, researched:1, active:42, total:42}` — internally
  inconsistent with the live breakdown above (`not_started` alone is 20 live vs. 31 recorded;
  `completed`/`researched=2` have no matching keys). Repair deferred to Phase 6.

### Dangling-edge scan (zero-padded)

Built the valid-ID union from `active_projects` (48 entries, all statuses) plus
`specs/archive/state.json`'s `archived_projects` + `completed_projects` (405 entries), zero-padded
to 4 digits before any `sort`/`comm` (avoiding the lexicographic-vs-numeric mismatch that produced
50 false positives in an earlier, unpadded run per report 02's Appendix). Union: 453 valid IDs.
Every one of the 50 distinct dependency targets across `active_projects` (`jq -r
'.active_projects[] | .dependencies[]?'`, zero-padded, deduplicated) is a member of this union.

**Result: zero dangling edges.** Padding requirement recorded here so the 50-false-positive
artifact is not rediscovered downstream.

### Hard-constraint check for this phase

`git diff --stat` at end of Phase 1: no `.lean` file touched (only this ledger file and
`.return-meta.json` written).

---

## Phase 2 — Adjudication of 169, 422, 95 against the 477-479 closure

### Scope-hypothesis grep

Grepped every active task's description and `file_scope` for `countermodel_discrete`,
`BXCanonical/Chronicle`, `BXCanonical/Completeness`. Hits: 468 (self), 422, 421, 169, 95, 362,
412, 451, 469, 470, 472, 473, 474, 477, 478, 479. All but 362 already carry a verdict from
report 02's survey or this task's own Phase 5 REVISE list (412). **362 is a genuinely new hit**,
addressed in its own subsection below — it is a dependent of 169, not itself targeting
`countermodel_discrete`'s closure, and its adjudication is scoped narrowly (an observation, not a
fourth full verdict) since its actual content (the consequence-completeness capstone) is far
broader than the three-task question this phase was dispatched to answer.

### What 477 -> 478 -> 479 actually proved (by symbol)

- **477** (`ta_qz_target_structure_plumbing`, completed): defined `QZStructure` (carrier `Rat
  x_lex Int`) and `goodGroupable` in
  `FormalSystem/Metalogic/WeakCanonical/IntegerModel/` — pure target-structure plumbing, explicit
  non-goal "do NOT prove the companion lemma."
- **478** (`tb_groupable_companion_lemma`, completed): proved the groupable-companion lemma itself
  (`KEquiv`-based, NOT an order isomorphism) via composition over ordered sums, monochromatic
  segment completeness, and region condensation/replacement — the Base analogue of
  `limitdom_is_good` (`WeakCanonical/IntegerModel/ReynoldsBridge.lean`).
- **479** (`tc_close_countermodel_discrete_at_base`, completed): closed
  `WeakCanonical.countermodel_discrete` by porting `countermodel_discrete_reynolds_v2`'s proof
  body with three substitutions (`fc := Base`; `limitdom_is_good` -> 478's companion lemma;
  `multiFamTaskFrame` -> `multiFamTaskFrameGen (Rat x_lex Int)`), landing the theorem in
  `WeakCanonical/GroupModel/CountermodelBase.lean`.
- **`WeakCanonical/Transfer.lean`'s current header** (re-read this dispatch) states explicitly:
  *"It no longer contains `countermodel_discrete`... It had to move because closing it needs
  `companionChronicle`, and `Transfer <- IntegerModel/ReynoldsBridge <- GroupModel/
  GroupableCompanion` makes importing that from here a cycle."* — confirming the actual proof
  chain is `companionChronicle`/`GroupableCompanion`/`ReynoldsBridge`, not a block-carrier
  isomorphism.
- **Governing document for all three**: `specs/422_.../reports/02_o1-verdict-k-equivalence-
  transfer.md` — i.e. **477-479 were spawned directly from 422's own research report**, but
  execute the report's *alternative* (k-equivalence/companion) route, not 422's originally
  specified deliverables.

### Three questions, answered by symbol-level evidence

**(a) Does 422's discrete-chronicle construction supply anything 477-479 did not?**
NO. 422's specified deliverables were (a) a block-decomposition/densification/isomorphism into
`Q x_lex Z` (analogue of `box_dense_gives_density`/`cantorIsoDense`,
`ChronicleToCountermodelBasic.lean:~430,~231`) and (b) three restricted-coherence analogues
(analogues of `cantor_bfmcs_dense_restricted_tc`/`_buc`/`_fuc`, same file, `:~624,~675,~750`).
422's own report 01 (`verification/block_order_refutation.lean`, sorry-free, `#print axioms`
clean) **permanently refutes the isomorphism formulation**: no linearly ordered abelian group has
order type `Z+Z`. Report 02 then pivots to a structurally different technique (`KEquiv` at fixed
finite depth `k`, not an isomorphism) and explicitly names it a "strictly weaker" route. 477-479
implement report 02's route end to end and **consume none of deliverable (a) or (b)** — confirmed
by `grep -n "cantor_bfmcs_dense_restricted_tc\|cantor_bfmcs_dense_restricted_buc\|
cantor_bfmcs_dense_restricted_fuc\|box_dense_gives_density"
ChronicleToCountermodelBasic.lean`, which shows these symbols used only in the pre-existing dense
case (unaffected by 422's scope) — no discrete-case analogue was built or is referenced by
477-479. No active task (`grep` over every description) references 422's specified deliverable
symbols. **422 supplies nothing 477-479 did not already deliver via a different, non-isomorphism
route.**

**(b) Does 169's `BXCanonical`-side target still have a consumer, or was its only consumer the
now-closed theorem?**
Its only consumer was `countermodel_discrete` itself. 169's description states its job in full:
"consume 422's output to close `countermodel_discrete`, delete the Transfer.lean sorry, and
re-verify `#print axioms completeness` reports no `sorryAx`." All three of those outcomes are
**already accomplished** by 479 (confirmed fresh, Phase 1 of this ledger: C2 shows `completeness`
clean, C3 shows zero live sorries). 169's `file_scope`
(`BXCanonical/Completeness.lean`, `BXCanonical/Chronicle/`) names files whose relevant obligation
(the Base discrete branch of `completeness`) is now discharged from a different file
(`WeakCanonical/GroupModel/CountermodelBase.lean`) that 169 never named. **169 has no remaining
consumer for its stated deliverable.**

**(c) Is 95's confirmation pass already satisfiable today given C2's clean axiom sets, and does
it still need to wait on 169?**
95's "what remains" is a three-step confirmation pass: (1) re-run `#print axioms`/`lean_verify` on
the headline theorems; (2) confirm the live sorry count is exactly 1, located in
`WeakCanonical/Transfer.lean`; (3) record that discharging `countermodel_discrete` is genuine open
construction belonging to its own task. **Step (2) as written can no longer be satisfied — the
live sorry count is ZERO, not 1** (Phase 1, this dispatch). Step (3)'s prediction has been
fulfilled in exactly the form it anticipated ("proving it belongs to its own task" — the 477-479
chain), so there is nothing left to *record* as open; it is closed. Step (1) is satisfiable today
(Phase 1's C2 run already performs it) and does **not** need to wait on 169 — 169 was never a
prerequisite for running `check-module-invariants.sh`, and 95's own dependency on 169 exists only
because 169 was expected to be the closer of the last sorry, which did not happen via 169's route.
**95's confirmation-pass job is fully subsumed by Phase 1 of this ledger; nothing distinct remains
for it to do.**

### Verdicts

| Task | Verdict | Action |
|---|---|---|
| **422** | **REMOVE** (propose abandonment) | Its specified deliverables are permanently refuted (isomorphism) or superseded by a different technique that consumed none of them (restricted-coherence analogues). No consumer remains. |
| **169** | **REMOVE** (propose abandonment) | Its sole deliverable (close `countermodel_discrete` via 422's output) is already fully accomplished via a different route (477-479). No remaining consumer for its `file_scope`. |
| **95** | **REMOVE** (propose abandonment) | Its confirmation-pass content is subsumed by this task's own Phase 1 evidence ledger, which already performed steps (1)-(3) fresh and found the state 95 predicted as its "most likely" closing outcome, minus the need for a separate task to have closed it via 169's specific route. |

This is a **conclusive** finding, symbol-grounded and cross-checked two ways (report 02's
narrative plus this dispatch's independent re-read of `Transfer.lean`'s current header and the
three tasks' own descriptions) — the plan's declared fallback (REVISE-with-open-question) is not
invoked because the evidence does not leave a genuine open question.

### Abandonment arguments (for Phase 8's report; no transition performed here)

**422** — `discharge_or_replace_unorderedsuccessorlabelclosed_residual`-style candor: propose
abandonment because its specified deliverables are (a) permanently refuted at the isomorphism
level per its own machine-checked report 01, and (b) superseded — the goal they existed to serve
was reached by a different, already-completed three-task chain (477-479) that used none of them.
Re-attempting deliverable (a) would violate the refutation's own "do not re-attempt" instruction
(carried into 477/478/479's own non-goals sections verbatim). No downstream task references
deliverable (a) or (b)'s symbols.

**169** — propose abandonment because its sole deliverable (closing `countermodel_discrete`) is
already closed, via a route (477-479) that did not consume 169's stated inputs
(`BXCanonical/Completeness.lean`, `BXCanonical/Chronicle/`) or 422's output. Nothing in 169's
`file_scope` names an obligation still open.

**95** — propose abandonment because its narrow confirmation-pass content is fully subsumed by
this task's own Phase 1 baseline re-verification (C2/C3, this dispatch), which already performed
exactly what 95 asks for and found the sorry count to be zero (95's own step (2) can no longer be
satisfied as originally written, since it presupposes exactly one live sorry in `Transfer.lean`).

### Observation: task 362's dependency on 169 (not actioned — out of this phase's 3-task scope)

362 (`main_strong_completeness` capstone) lists `169` among its dependencies
(`[361,375,169,170,424]`) and its own DEPENDENCY STATUS prose states "169 (base weak) not_started"
and "170 (dense weak) not_started" — the latter is independently stale (170 is archived
`completed`, reconfirmed CURRENT by report 02 §4 and by this dispatch's C2 run). 362's actual
requirement is that the Base and Dense weak completeness engines be sorry-free, which they already
are (Phase 1, C2). If 169 is abandoned per this phase's recommendation, 362's `169` dependency
edge would need either removal (the underlying obligation is already met) or reinterpretation.
This is **flagged for the Phase 8 report and for whoever acts on the proposed abandonments** —
adjudicating or revising 362 itself is outside this phase's declared scope (exactly 169/422/95)
and outside the plan's REVISE list (412/428/429/462/178/177). Not actioned here.

### Hard-constraint check for this phase

No task status transitioned. No `.lean` file touched (`git diff --stat` — ledger append only).

## Phase 3 — Extraction of specs/ROADMAP-ARCHIVE.md

### Inventory and classification

Confirmed the plan's Scope Hypothesis by direct measurement: `wc -l specs/ROADMAP.md` = 1,970
lines (matching report 02); `grep -c "HISTORICAL\|SUPERSEDED\|STALE"` = 10 (matching report 02,
down from ~30 pre-472).

Classified every `## `-level section (26 total) plus relevant `### `-level subsections. Moved to
`specs/ROADMAP-ARCHIVE.md`, verbatim, in original relative order, tagged with pre-split line
ranges:

| Pre-split lines | Content |
|---|---|
| 94-419 | Overview's stacked dated "Current state" blocks (2026-07-24, 2026-07-16 superseded, 2026-07-07) plus the older sorry-chain/anti-pattern narrative and 2026-05/06 BXCanonical sorry tables beneath them |
| 657-769 | `### Historical: the task-109 BXCanonical abandonment (2026-05-10, superseded)` and `### Module Import Graph (retired 2026-08-17)` |
| 896-950 | `## How Until/Since Were Closed` |
| 976-1064 | Three `### Historical:` subsections inside `## Sorry Inventory` (Critical Path/RootScopedChain, Irreflexive-Consequence, Irreflexive Semantics Strategy) plus `### Historical: Closed Sorries` |
| 1068-1123 | `## Legacy Code Inventory` |
| 1200-1558 | `## Dead Ends (Archived)` (already self-titled archived; includes its `### Task 93` and `### Current Strategy: Chronicle Construction` subsections) |
| 1659-1663 | `## Investigated Dead Ends: Logic Weakening (Task 77)` |
| 1864-1930 | `## Recommended Priority Order` (carried its own `> STALE (2026-08-17)` banner) |
| 1934-1970 | `## Task Cross-Reference` (the trailing 111-row table) |

**Total moved**: 1,107 lines. **Verified no content lost**: `1,107 (moved) + 863 (reduced file) =
1,970 (original)` — exact arithmetic match, confirmed by script.

**Sections deliberately KEPT in `specs/ROADMAP.md`** despite containing dated or partially-stale
material, because they are current-state-bearing (Phase 7's job to correct, not Phase 3's job to
archive) rather than purely historical sediment: `## Overview`'s lead architecture/terminology
block (lines 1-92, including the per-class completeness table that Phase 7 must correct for
169/422 per Phase 2's verdict); `## Active Metalogic Paths`/`### Chronicle Construction` (retains
one small dated 2026-05-10 sub-paragraph Phase 7 will fold in); `## Other Open Items` (carries the
task 474 BiLasso "Status: landed" block Phase 7 must fold into the decidability front); `##
Representation Theorem Goal` (architecture rationale, no stale banner); `## Paper Alignment
Programme` (explicitly flagged by the plan as needing a Phase 7 correction, not extraction — six
tasks listed not-started/blocked that archived completed 2026-08-13 to 2026-08-18); `##
Burgess-Xu Until-Induction Technique` (durable mathematical-technique reference, not dated
narrative).

### Provenance header

`specs/ROADMAP-ARCHIVE.md` opens with a provenance header naming its source file
(`specs/ROADMAP.md`), the split date (2026-08-25), this task, and stating explicitly that archived
text is a historical record, not current truth, and that `specs/ROADMAP.md` and a fresh
`check-module-invariants.sh` run win on any conflict.

### C5-equivalent replication (both files)

C5 proper prunes `specs` from its directory walk (`dirs[:] = [... "specs" ...]`,
`check-module-invariants.sh` line ~270), so it never reads either file. Replicated C5's own logic
standalone (`mod_re = re.compile(r"\b(?:FormalSystem|BimodalTest)(?:\.[A-Z][A-Za-z0-9_]*)+")` plus
its `resolves()` function, checking `.lean` file or directory existence) directly against both
files:

```
specs/ROADMAP.md: 0 unresolved module-shaped path(s)
specs/ROADMAP-ARCHIVE.md: 0 unresolved module-shaped path(s)
```

Both zero, as the plan's baseline predicted.

### Hard-constraint check for this phase

No `.lean` file touched (`git diff --stat` — only `specs/ROADMAP.md` modified and
`specs/ROADMAP-ARCHIVE.md` created). No task status transitioned.

## Phase 4 — Creation of the three new tasks

### Scope-hypothesis confirmation

Grepped every active task's description for `isValid_sound`, `UnorderedSuccessorLabelClosed`,
`extractionFailed` before creating anything. Hits: `468` (self, plan text), `470` (observes the
fifth-residual gap but does not own fixing it), `426` (unrelated Stage-3 documentation-pass
mention, not ownership). None of the three symbols is owned as a deliverable by any existing
active task — confirmed exactly three ADDs, matching the plan's Scope Hypothesis.

### Tasks created (via `.claude/scripts/state-write.sh`, `next_project_number` re-read
immediately before each write)

| # | Title | Type | Topic | Effort | Deps | file_scope |
|---|---|---|---|---|---|---|
| 480 | `bridge_isvalid_bool_to_semantic_validity` | lean4 | decidability | small | [] | `Decidability/Correctness.lean`, `Decidability/DecisionProcedure.lean` |
| 481 | `discharge_or_replace_unorderedsuccessorlabelclosed_residual` | lean4 | decidability | large | [434] | `Decidability/Verified/Termination/MintBound.lean` |
| 482 | `discharge_proof_extraction_completeness` | lean4 | decidability | large | [412] | `Decidability/ProofExtraction.lean`, `Decidability/Verified/Refutation/` |

Each description states its routine-vs-open-mathematics classification explicitly in its opening
line, per the plan's requirement. `next_project_number` advanced from 480 to 483 (exactly three).

**Note on an accidental bump**: an initial `state-write.sh` call for task 480 failed
(`--rawfile` is not a supported flag on this wrapper) and the immediately-following
`next_project_number` bump was issued anyway before the failure was noticed, advancing the
counter from 480 to 481 with no task 480 entry yet existing. This was caught before any further
writes and corrected by writing `next_project_number` back to 480 (via `state-write.sh`, so the
mutex/validation path was used for the correction too) before retrying task creation with a
working `--arg`-based invocation. Confirmed via `jq` immediately after the correction that
`active_projects | length` was still 48 and `next_project_number` was back to 480 before any task
was actually created — no task exists at a number this dispatch reserved-then-abandoned.

### `generate-todo.sh` verification

Ran after all three creations and the final `next_project_number` write (with `--regen-todo` on
the last state-write call, plus a manual re-run for confirmation): exit 0, no undeclared-topic
warning. `specs/TODO.md` confirmed to carry all three new entries (`### 480.`, `### 481.`,
`### 482.` headings, titles auto-generated from `project_name`).

### Hard-constraint check for this phase

No existing task's status/dependencies/file_scope was touched. No `.lean` file touched. All
writes went through `state-write.sh`; `specs/TODO.md` only ever regenerated via
`generate-todo.sh`.

## Phase 5 — Description REVISEs applied

All nine REVISEs applied via `.claude/scripts/state-write.sh` (description field only, one
targeted `jq` write per task):

| Task | Change |
|---|---|
| 412 | Struck the stale `countermodel_discrete`/`Transfer.lean:1242` clause from the primary scope sentence; added a correction naming the theorem's actual location (`GroupModel/CountermodelBase.lean`) and naming new task 482 as the `.extractionFailed`-elimination owner gated on 412. |
| 428 | Added the ASSESS-and-C9-register escape clause for the split-arm fuel scaling problem (`Fuel.lean:1595-1610`); left the opening "THE REFUTED THEOREM, SETTLED" paragraph untouched. |
| 429 | Added the recommended-route sentence naming option (a) up front, per amendment 10a; kept all three routes' text and option (c)'s closed-as-formulated status unchanged. |
| 462 | Added the sequencing note naming new task 481 and the shared nonempty-universe setting. |
| 178 | Rescoped the decidability-example acceptance criterion to the propositional fragment; added the `truthAt_of_isValid`-is-not-decidability-evidence correction, carried from the 2026-08-24 review's M-7 and independently re-confirmed this dispatch. |
| 177 | Replaced wholesale with the retained-half text from report 02 §6 (472/473's territory explicitly excluded); `file_scope` left untouched (already correct). |
| 169 | Appended the REMOVE/propose-abandonment finding from Phase 2, with evidence pointer and the 362-dependency-edge flag for the report. |
| 422 | Appended the REMOVE/propose-abandonment finding from Phase 2, with evidence pointer. |
| 95 | Appended the REMOVE/propose-abandonment finding from Phase 2, with evidence pointer. |

### Verification

- `jq` confirms each revised description contains its new clause; for 412 and 178 the specific
  struck sentence no longer appears as a live claim (confirmed by targeted `grep -c` returning 0
  for the exact original phrasing; the only remaining occurrences are inside the correction text,
  explicitly quoting what was struck, exactly as the existing convention elsewhere in this file
  does — e.g. task 428's own "THE REFUTED THEOREM, SETTLED" section).
- `status`, `dependencies`, and `file_scope` unchanged for all nine tasks (spot-checked via `jq`
  immediately after all nine writes) — confirmed this phase touched descriptions only.
- `generate-todo.sh` exits 0, no undeclared-topic warning. `active_projects | length` still 51
  (48 original + 3 from Phase 4; unchanged by this phase, as expected).

### Hard-constraint check for this phase

No task's status transitioned. No `.lean` file touched. All writes through `state-write.sh`;
`TODO.md` only regenerated.

## Phase 6 — Dependency wiring, topics, counters, and critical path

### Edges wired / considered

- **482's `[412]` edge** and **481's `[434]` edge**: both already set correctly at Phase 4
  creation time; no further write needed.
- **169/422/95**: Phase 2's verdict was REMOVE (propose abandonment), not REVISE-with-new-edges;
  no new dependency edge is implied by that verdict. The one edge-shaped consequence Phase 2
  surfaced — task 362 lists `169` as a dependency, and would need that edge revisited if 169 is
  ever abandoned — is a **future** consequence of a status transition this task does not perform,
  so no edge write happens here; it is carried to the Phase 8 report as an explicit flag instead.
- **462's sequencing prose** (added Phase 5: task 481 "should run before or alongside" 462):
  **decided NOT to add a hard dependency edge** `462 -> [481]`. Reasoning: "alongside" explicitly
  permits concurrent execution, which a blocking dependency edge would foreclose (it would force
  strict serialization, overconstraining a prose statement that deliberately allows parallelism).
  The prose itself already reads as advisory coordination ("check its disposition before relying
  on any assumption"), not a hard gate, so there is exactly one coherent reading (advisory,
  non-blocking) and no dangling ambiguity to resolve with an edge. Recorded here explicitly per
  the plan's "never leave both readings" instruction — this is a considered decision, not a
  silent skip.
- No other REVISE from Phase 5 asserts a gate lacking a corresponding edge.

### active_topics

Added `metalogic` via `state-write.sh` (`.active_topics = ((.active_topics + ["metalogic"]) |
unique | sort)`). Confirmed present by `jq`.

### Dangling-edge scan (zero-padded, re-run after Phase 4/5's writes)

Union of `active_projects` (51 entries, post Phase 4) and archive's archived+completed sets: 456
valid zero-padded IDs. All 51 distinct dependency targets across the live `active_projects`
resolve into that union. **Result: zero dangling edges**, confirmed after the new tasks and all
description writes.

### state.json counters — REPAIR DEFERRED, with argument (per the plan's explicit permission)

Recomputed fresh: `active_projects | length` = 51. Live status breakdown: `blocked=3,
completed=16, implementing=1, not_started=23, partial=5, planned=1, researched=2` (sums to 51).

Current `.metadata.total_tasks` = 42, `.task_counts` = `{blocked:3, implementing:1,
not_started:31, partial:5, planned:1, researched:1, active:42, total:42}`.

**Decision: do not hand-edit these fields; defer the repair to `/task --sync`.** Argument: the
plan's own Phase 6 task list gives an explicit escape valve for exactly this case — "if the
`task_counts` key set cannot represent the live status breakdown without a schema change... do
NOT invent schema — record the precise argument for leaving the repair to `/task --sync`
instead." That condition is met: the live status set includes `completed` (16 entries) and a
plural `researched` (2 entries), neither representable in the current `task_counts` key set
(which has no `completed` key and was apparently designed to key only non-terminal in-flight
statuses — its own internal invariant, `active == total`, with both equal to the SUM OF ONLY THE
KEYED STATUSES, never included `completed` at all even at whatever point it was last accurate).
Two competing repair semantics are equally defensible from the field names alone and neither can
be confirmed against any schema documentation or consumer code: (a) `total_tasks`/`task_counts`
means literally every `active_projects` entry (51, including `completed`), or (b) it means only
non-terminal "still active" work (35, excluding `completed`), continuing whatever convention
produced the old `42` figure. **Searched exhaustively for a tie-breaker**: `grep -rln
"task_counts\|\.metadata\.total_tasks" .claude/scripts/ .claude/hooks/` returns **zero files** —
no script anywhere reads or writes either field, so there is no consumer contract to consult and
no way to verify either semantics against actual behavior. Inventing a resolution here would be
exactly the "unargued" schema invention the plan forbids; the honest action is to leave the
counters as they are (still stale, unchanged by this task) and hand the precise diagnosis above
to whichever future `/task --sync` (or a dedicated schema-clarification task) is positioned to
either confirm the intended semantics with the user or extend the schema deliberately.
`.metadata.last_sync` is likewise left unchanged (not bumped), since bumping it without actually
reconciling the counts would misrepresent a sync as having occurred.

### Critical path, re-derived against the LIVE dependency graph (not report 02's simplified
diagram, per the plan's explicit instruction to re-derive rather than carry the figure forward)

Computed by longest-path over the actual `dependencies` fields read via `jq` this dispatch (report
02's diagram drew `433/434 -> 462`, but 462's real dependencies are `[469, 470]`, both completed
— report 02's arrow was an aspirational ordering note, not the literal edge set):

```
462 (unblocked today, deps 469✓/470✓, ROUTINE)
  -> 463 (deps 462, ROUTINE)
    -> 464 (deps 462,463, HARD -- "the one genuinely OPEN MATHEMATICAL question", gapPotential)
      -> 465 (deps 462,463,464, ROUTINE -- mechanical restatement of settled residuals)
        -> 428 (deps 432✓,433(partial),434(partial),465, HARD -- split-arm fuel scaling,
                now with the Phase 5 ASSESS/C9-register escape clause)
          -> 429 (deps 428, HARD -- genuine open mathematics, box-anchor redesign,
                  now with the Phase 5 recommended-route addendum)
            -> 410 (deps 165✓,429, planned)
              -> 411 (deps 165✓,410)
                -> 430 (deps 428,429,411, HARD -- item (b) "the semantic lift")
                  -> 412 (deps 165✓,410,411,428,430)
                    -> 482 (deps 412, HARD -- open mathematics, multi-month)
                    -> 177 retained half (deps 131,193,402,426✓,428,429,430,432✓,433,434,440,441,448)

481 (deps 434(partial), HARD -- repair-or-replace) -- parallel entry, recommended before/
    alongside 462 per Phase 5's addendum to 462 (advisory, not a hard edge -- see above)
480 (deps [], ROUTINE, startable today, independent of the whole chain)
476 (deps 475✓, HARD -- open mathematics, gated only on 475) -- parallel, does not feed the spine
```

**This is an 11-wave spine from 462 to 482** (10 waves to reach 412, one further to 482), computed
by strict longest-path level assignment (462=1, 463=2, 464=3, 465=4, 428=5, 429=6, 410=7, 411=8,
430=9, 412=10, 482=11; 434/433 sit at levels 1/2 respectively, feeding into 428 at level 5 without
extending it further since 465's chain is longer). This differs from report 02's stated "9-wave"
figure because report 02's own hand-drawn diagram compressed the real 462->463->464->465 chain
into a single arrow and anchored the spine's start at 433/434 rather than at 462's actual
(already-satisfied) dependencies — an artifact of the diagram, not of the underlying graph, which
this phase re-derives directly from `dependencies` fields rather than carrying forward.

**Routine vs. hard split, explicit per item**: ROUTINE — 462, 463, 465, 480 (mechanical
engineering, no open mathematics). HARD — 464 (`gapPotential`, open mathematics), 428 (split-arm
fuel scaling, now with an explicit ASSESS/C9-register escape), 429 (box-anchor redesign, genuine
open mathematics), 430 item (b) (the semantic lift), 412's refutation induction, 481 (repair-or-
replace, not routine discharge), 482 (open mathematics, multi-month), 476 (open mathematics,
multi-month, parallel to the spine).

### Hard-constraint check for this phase

No `.lean` file touched. No task status transitioned. All writes through `state-write.sh`;
`TODO.md` regenerated; `generate-task-order.sh --print` exits 0 with no undeclared-topic warning.

## Phase 7 — Rewritten specs/ROADMAP.md

### What changed

Wholesale rewrite: retitled `# Roadmap: TM Decidability, Completeness, and Publication` (naming
decidability alongside completeness, per the plan's requirement). New structure: a PROVEN-vs-
SORRY-FREE opening statement, then `## Phase 1` through `## Phase 7` — one current-state
statement per front (weak/strong completeness; decidability/tableau; Kamp/expressive
completeness; FMP; publication/documentation; dataset/training; repository hygiene) — each with
`- [ ]`/`- [x]` checkboxes, followed by a `## Tombstoned Routes` section cross-referencing the C9
register without duplicating its entries, then the durable technical-reference sections retained
from the reduced file (BX Axiom System, Irreflexive Truth Semantics, X/Y Operator Status,
Canonical Model Construction, Quasimodel/Filtration Infrastructure, Burgess-Xu Until-Induction
Technique, Representation Theorem Goal, Paper Alignment Programme — the last corrected, not
merely retained), and a closing `## Recommended Priority Order`.

Corrections applied per the plan's checklist:
- **Completeness front corrected to the re-verified state**: Phase 1 states `completeness`'s
  Base-discrete-branch closure via 477-479, removes the stale "task 169/422 route" framing from
  the per-class table, and states the strong-completeness gating rule's actual current status
  (task 424 completed, not merely "in flight").
- **Stavi/EFGames corrected**: stated LIVE with the confirming import chain
  (`WeakCanonical.lean` -> `EFGames.StaviCompleteness`, plus four further live importers),
  retracting the prior "superseded and parked" claim.
- **BiLasso stated honestly**: landed sorry-free, computing-not-choice-free, the single remaining
  `fmp` theorem named as the box-faithfulness obstruction, folded into Phase 4 as the front's own
  statement rather than a late addendum, with the F6-qualification note.
- **Refuted routes tombstoned** with a dedicated section cross-referencing C9 rather than
  duplicating its 24 entries.
- **Paper Alignment Programme corrected**: the six tasks (420/414/415/417/419/427) previously
  listed not-started/blocked are now shown against their actual archived status (five completed,
  one expanded), confirmed via `jq` against `specs/archive/state.json` this dispatch.
- **Five-residual terminus stated**, not four, naming `UnorderedSuccessorLabelClosed` and its
  owner (task 481).
- **Every status line grounded**: C2/C3/C4/C5/C6/C9 named inline throughout; the closing "Check
  grounding" line under each phase names the checks specific to that front.
- **Machine-annotatable structure**: `## Phase N: {Title} ({Priority} Priority)` headings with
  `- [ ]`/`- [x]` items throughout.
- **Critical path per front carried in**, with the routine/hard split visible (Phase 2).

### Verification

- `wc -l specs/ROADMAP.md` = 712 lines (down from 1,970 pre-split; the retained technical
  reference sections account for most of this length).
- `grep -c "HISTORICAL\|SUPERSEDED\|STALE"` = **0** (down from 10) — every stale claim was
  corrected in place rather than banner-flagged, since this is the rewritten current file, not an
  archive.
- **C5-equivalent replication**: 0 unresolved module-shaped paths.
- **`roadmap-integration.sh --roadmap specs/ROADMAP.md --state specs/state.json`** (parse-only,
  no `--annotate`): stderr marker `<!-- roadmap-structure phases=7 checkboxes=39 table_rows=57
  parseable=true -->` — satisfies `phases > 0` and `checkboxes > 0`.
  **Observed script limitation** (not fixed, out of this task's charter): the script's own JSON
  assembly step later in the same run failed with `jq: Argument list too long` (exit 126), passing
  a `--argjson` blob built by cross-referencing every task number cited in `specs/ROADMAP.md`
  against the now-51-entry, longer-description `specs/state.json` via the command line rather than
  a file/stdin. The structure marker above is printed before that failure and is unaffected by
  it — this is the value Phase 7's own verification criterion asks for. Fixing
  `roadmap-integration.sh`'s argument-passing mechanism is outside task 468's charter (no `.sh`
  script repair is in its Goals, and its Non-Goals forbid scope creep into unrelated fixes);
  recorded here as a finding for a future task, not actioned.
- `git diff --stat -- '*.lean'` — zero files.

### Hard-constraint check for this phase

No `.lean` file touched. No task status transitioned.
