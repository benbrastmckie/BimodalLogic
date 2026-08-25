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
