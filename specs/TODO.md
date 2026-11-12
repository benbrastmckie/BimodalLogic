---
next_project_number: 926
---

# TODO

## Task Order

*Updated 2026-11-12. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 178,257,298,428,481,502,570,604,664,713,714,734,743,761,781,817,818,821,829,830,831,832,873,890,906,907 | -- | agent-system, algebraic-representation, completeness, ... |
| 2 | 231,282,296,429,497,763,787,803,862,869,874,875,876 | 298,428,502,743,761,873 | algebraic-representation, dataset-enhancement, decidability, ... |
| 3 | 410,498,499,500,804,861 | 429,497,763,803 | algebraic-representation, decidability, build-performance |
| 4 | 125,411,543 | 410,498,499,500 | algebraic-representation, decidability, metalogic |
| 5 | 430,501 | 125,411 | algebraic-representation, decidability |
| 6 | 412 | 430 | decidability |
| 7 | 482 | 412 | decidability |
| 8 | 177 | 178,282,296,481,482,543 | formula-refactor |

**Grouped by Topic** (indented = depends on parent):

### Agent System

907 [NOT STARTED] — Regenerate the deployed .claude/ tree in BimodalLogic, which...

### Algebraic Representation

502 [NOT STARTED] — RESEARCH TASK. Ground the algebraic representation front in...
  └─ 497 [NOT STARTED] — Bring the Shift-closed Tense S5 Algebra class into live code...
    └─ 498 [NOT STARTED] — Phase 1 of the Jonsson-Tarski representation: the complex...
      └─ 125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the...
        └─ 501 [NOT STARTED] — Phase 4 of the Jonsson-Tarski representation: extend STSA...
    └─ 499 [NOT STARTED] — HARD. Phase 2 of the Jonsson-Tarski representation: the...
      └─ 125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the... (see above)
    └─ 500 [NOT STARTED] — RESEARCH TASK. Prevent two parallel representation theorems...

### Completeness

906 [IMPLEMENTING] — Settle whether LCU is derivable from TM-plus + LC\_n at ZTime...

### Dataset Enhancement

257 [BLOCKED] — Complete the Hugging Face Hub migration for large dataset...
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded...
  └─ 231 [NOT STARTED] — Build comprehensive automation so that every dataset...
  └─ 282 [PARTIAL] — Flip complexity-9 dataset generation from stratified to...
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release,...
604 [NOT STARTED] — Add zstd-compressed .jsonl dataset support across the data...

### Decidability

428 [BLOCKED] — Engine totality at a quantified branch budget. Owns...
  └─ 429 [NOT STARTED] — Repair the truth-lemma side conditions. Owns obstructions O2...
    └─ 410 [PLANNED] — Track B part 1 for the TM tableau decidability program...
      └─ 411 [NOT STARTED] — Track B part 2 for the TM tableau decidability program...
        └─ 430 [NOT STARTED] — The semantic lift and the Track A assembly. Owns obstruction...
          └─ 412 [NOT STARTED] — Track B finish for the TM tableau decidability program...
            └─ 482 [NOT STARTED] — CLASSIFICATION: OPEN MATHEMATICS, multi-month. This MUST NOT...
481 [BLOCKED] — CLASSIFICATION: genuinely open -- the predicate is refuted as...
713 [HOLD] — OPTIONAL, FILED NOT SCHEDULED -- AND LOAD-BEARING AS A CHECK....
714 [NOT STARTED] — Evaluate removing the TailStable junk-position obstruction at...
734 [HOLD] — Run experiment E4: decide StabSaturated on the Bool fixture's...
761 [HOLD] — AMENDED 2026-10-18 (presentation chosen): the cell...
  └─ 763 [NOT STARTED] — AMENDED 2026-10-11 (index deletion): the finite cell index...
    └─ 861 [RESEARCHED] — Record the one-sided transport refutation in the RaySummary...
  └─ 862 [RESEARCHED] — Promote cntAt\_eq\_of\_pend\_eq\_fwd into LadderAgree as a...
781 [RESEARCHED] — Decide whether the Phase 5 inner-fixpoint hoist in...
830 [NOT STARTED] — Generalize Compression.decidableValidZTime from the...
831 [NOT STARTED] — RESEARCH TASK, verdict-first. State and attempt the...
787 [NOT STARTED] — Audit the remaining lake-invoking scripts for the unguarded...

### Formula Refactor

178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of...
  └─ 177 [NOT STARTED] — Update README.md, docs/, and FormalSystem/ module-level...

### Literature

664 [NOT STARTED] — Acquire and ingest the Cmiel-Kuhlmann-Kuhlmann ball-space...

### Metalogic

570 [NOT STARTED] — OPEN RESEARCH QUESTION, not an implementation task. Is the...
890 [RESEARCHED] — Record the GHR94 Lemma 10.2.3 Case 5 erratum in the Typst...
543 [NOT STARTED] — Machine-check the principal new results from the MF...
875 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...

### Repo Hygiene

743 [PLANNED] — Teach typst-sync-check.sh Check 1 to resolve namespaced Lean...
817 [NOT STARTED] — Wrap the remaining count-carrying inventory tables under...
818 [NOT STARTED] — Wrap the four directory-rollup inventory tables that need the...
821 [RESEARCHED] — Reconcile specs/state.json's next\_project\_number against...
832 [NOT STARTED] — Two local-disk reclamations found by the 2026-11-02 review....

### Semantics

869 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...

### Build Performance

829 [NOT STARTED] — NO BUILD CACHE FOR .lake/build IN ANY CI WORKFLOW. Every CI...
803 [PLANNED] — Cut the elaboration time of...
  └─ 804 [NOT STARTED] — Determine whether...

### Syntax

873 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...
  └─ 874 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...
  └─ 876 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...

## Tasks

### 925. Ladderpump c16 unused arguments lint debt
- **Effort**: low
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Parent**: Task 917
- **Research**: [925_ladderpump_c16_unused_arguments_lint_debt/reports/01_ladderpump-c16-unusedarguments-clear.md]
- **Other**: [925_ladderpump_c16_unused_arguments_lint_debt/handoffs/phase-2-handoff-20261111T2015Z.md]
- **Plan**: [925_ladderpump_c16_unused_arguments_lint_debt/plans/01_ladderpump-c16-unusedarguments-clear.md]
- **Summary**: [925_ladderpump_c16_unused_arguments_lint_debt/summaries/01_ladderpump-c16-unusedarguments-clear-summary.md]

**Description**: Clear the C16 env_linter unusedArguments lint debt in RaySummary/LadderPump.lean, which fails check-module-invariants.sh for every other task in the module.

Originating evidence (orchestrate conclusion stage, channel (c)), cited from the parent's issue log: {task 917, iss_1794382565390_CmXKYM}.

VERIFIED STARTING POSITION. check-module-invariants.sh's C16 env_linter group FAILS on two unusedArguments findings in FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean, on the declarations exists_idleSpliced_ladderPath and exists_idleTypeBlock_of_budget_le_run. Neither the parent record nor its batch sibling touched that file; git log -S attributes the declarations to a concurrent sibling record's commit 3692d517e. Both handled the finding by enumerating and attributing it as pre-existing and out of scope -- correct under their own plans, but it costs every subsequent task in this module an attribution step before it can read its own gate result.

WHY THIS IS NOT A DIRECT FIX. The conclusion stage considered fixing the two findings in place and rejected it: the file sits in a concurrent sibling record's file_scope, so an in-place edit risks a territory collision with in-flight work. This task exists so the fix happens once under a declared file_scope, rather than being attempted opportunistically from a task that does not own the file.

SCOPE. Resolve the two unusedArguments findings on the two named declarations -- either by removing genuinely unused arguments, or by establishing that each argument is load-bearing and suppressing the linter at that declaration with a stated reason. Verify by running check-module-invariants.sh and confirming the C16 env_linter group reaches exit 0 with no unusedArguments findings in LadderPump.lean. Out of scope: the one genuine ':= trivial' proof in FormalSystem/Examples/TemporalStructures.lean, enumerated by the sibling record as a separate pre-existing finding. Before dispatching, check for a live task holding LadderPump.lean and add a dependencies[] edge rather than racing it.

PRECEDENT. The archived record ladderchain_c16_unusedarguments_clear cleared this exact C16 unusedArguments class in the sibling file LadderChain.lean; the matcher returns it as covered-by-closed (semantic 0.42). It is precedent for the method, not coverage of this file -- read its artifacts before starting. The two duplicate-of-open verdicts the matcher returns are both false positives on subject: lake_unguarded_reader_lock_audit concerns the unguarded .lake read hazard, and open_modal_invariance_ray_agreement_lifting is a demoted L-triangleright line; the subset-of-open verdict against update_readme_and_module_docstrings scores 0.19 and is territory-driven.

---

### 924. Forward slack witnessed frontier disposition
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 925
- **Parent**: Task 917
- **Research**: [924_forward_slack_witnessed_frontier_disposition/reports/01_forward-slack-frontier-disposition.md]
- **Plan**: [924_forward_slack_witnessed_frontier_disposition/plans/01_forward-slack-frontier-disposition.md]
- **Source**: [FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean]
- **Evidence**: [evidence/forward-slack-pin-cascade/route-space-closure.lean]
- **Handoff**: [924_forward_slack_witnessed_frontier_disposition/handoffs/phase-3-handoff-20261111T233000Z.md]
- **Summary**: [924_forward_slack_witnessed_frontier_disposition/summaries/01_forward-slack-frontier-disposition-summary.md]

**Description**: Decide the fate of the ForwardSlackWitnessed frontier, now that its only landed discharge route is refuted.

Originating evidence (orchestrate conclusion stage, channel (c)), cited from the parent's issue log: {task 917, iss_1794380410445_QbPDDB}.

VERIFIED STARTING POSITION. The parent task's Phase 5 measured its decision gate as FAIL rather than arguing it: both clauses of exists_deleted_ladderPath_of_next_region_nxt are non-dischargeable from the admitted regime -- hanch short by exactly d, hstraddle by exactly 2*d, where d is the deleted block's length. The measurement compiles sorry-free at specs/917_forward_slack_witnessed_discharge_or_refutation/evidence/phase-5-gate-measurement.lean and exhibits concrete saturated assignments satisfying every available fact (pinCompat_of_ladderPath at the pin pair, nxtAt_lipschitz_two_sided from z, the gap, Tc <= C, (K3), and the pigeonhole's room and window bounds) at which each clause is false. The root cause: cascadeBound's recurrence a(k+1) <= 2*a k + J + 1 is attained WITH EQUALITY by the saturated configuration, so (K2)'s budget describes the obstruction rather than dominating it. The parent then compiled the obstruction as a theorem -- no_deleted_ladderPath_of_straddle_break in FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean shows that once the straddling pair breaks at the reduced distance, no deleted ladder path exists at all, so the primitive's own conclusion is false there rather than merely unproved.

CONSEQUENCE TO RESOLVE. ForwardSlackWitnessed, being an existential over paths, is neither discharged nor refuted; it remains a hypothesis carried on all five depth-0 cell-equality schemas, and every consumer must supply it. The parent recorded in four durable places (the module docstring, the primitive's docstring, Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean, and specs/state.json) that certStabK's condition must be RESTATED rather than proved for as long as the hypothesis stays carried.

SCOPE. Two admissible outcomes, both terminal: (a) identify and land a discharge route that neither passes through block deletion inside the first region above z's (the refuted route) nor re-enters the doubling cascade; or (b) record the frontier as closed, with a compiled statement of why no route through the currently landed machinery can succeed, and make the certStabK restatement obligation permanent rather than provisional. Reaching neither is a third, non-terminal result and must be reported as such rather than smoothed into (b). Amending (K1) to constrain spanning-block length is assessed in the sibling research report as carrying a blast radius of all 53 wired probes and is NOT admitted here without its own decision.

BACKLOG AUDIT. The matcher's strongest signal is covered-by-closed against the parent record itself (semantic 0.74, mechanical subset) -- expected and not a duplication, since this task exists precisely to reach the outcome the parent measured it could not. The one open-task verdict, subset-of-open against update_readme_and_module_docstrings, scores 0.20 and is territory-driven (a shared FormalSystem/Metalogic/Decidability/ prefix), not subject overlap; that record is a documentation sweep and was separately flagged this invocation as an idle cross-batch file_scope overlap. Add a dependencies[] edge if the two are ever dispatched together.

OUTCOME. Neither of the description's two terminal outcomes was reachable as worded: outcome (b) is FALSE, because a route through the currently landed machinery does succeed. What landed is a cascade-free, deletion-free CONDITIONAL discharge. hasForwardSlack_of_idleRunRepeat and forwardSlackWitnessed_of_cell_idleRunPumpable (both FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean) conclude ForwardSlackWitnessed at EVERY amount from the amount-free run-local premise IdleRunPumpable, through the duplication of an idle block inside the idle run separating z's region from the next one; idleSplice_pins discharges the pin clause unconditionally, so no block deletion above z's region occurs and none of (K2)'s cascadeBound is spent. The premise is NOT ParamsOk-derivable -- (K1) quantifies prodCycleLens, objCycleLens and satPeriod and never idleCycleLens -- so the hypothesis is RESTRICTED, not removed: ForwardSlackWitnessed still sits on all five depth-0 cell-equality schemas of LadderCell.lean, which is not edited. The route-space closure is the wired probe specs/evidence/forward-slack-pin-cascade/route-space-closure.lean. THE FRONTIER is now exactly one named sub-regime: the paths whose intervening idle run has length 1, where no repeat block exists to pump. The certStabK restatement obligation is therefore PROVISIONAL rather than permanent -- blocked on a condition dischargeable on the pumpable side, not on one refuted outright.

---

### 923. Separate generator-written files from hand-edited read-only scope declarations
- **Status**: [ABANDONED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: Task 912, Task 914, Task 922

**Description**: Agent-system change request from the /orchestrate conclusion stage (channel b), approved by the user.

ORIGINATING EVIDENCE (issue-log entry; audit the proposal against it before acting):
- {task 918, iss_1794387273674_2UjfIi}

OBSERVED DEFECT (severity: minor). Two provisions of ONE plan contradicted each other about the
same file. 918's plan risk table declared
`FormalSystem/Metalogic/Decidability/RaySummary/README.md` READ-ONLY (a sibling task holds it in
its `file_scope`), while that same plan's Phase 7 Scope Hypothesis instructed the implementer to
"add any file they touch that is absent here" -- and `check-module-invariants.sh --emit-inventory`
rewrites four tracked files, that README among them.

The implementation resolved it by running the regeneration anyway (leaving the INV gate red from
the task's own new module was the worse outcome) and recorded the tension rather than silently
picking a side.

ROOT SHAPE OF THE DEFECT. The plan-authoring contract has a single category -- "read-only" --
covering two materially different things: a file a HUMAN/agent must not hand-edit because another
task owns it, and a file a GENERATOR rewrites wholesale as a side effect of a gate the plan
itself requires to be green. The second is not an edit the plan can decline to make; declaring it
read-only states an obligation the plan cannot keep.

CHANGE REQUEST. Reconcile the contract so a risk table's read-only declaration and a phase's
generated-file regeneration surface cannot disagree. The suggested shape (not mandated -- assess
it): require generator-written files to be declared as a DISTINCT category from hand-edited
read-only ones, so a plan can say "this file will be rewritten by <generator>, not hand-edited,
and that is expected" without either lying about read-only status or being silently out of scope.
Whatever shape is chosen must also settle how such a file interacts with the Scope-Hypothesis
self-consistency obligation and with a sibling task's `file_scope` claim on the same path.

CURRENT STATE TO READ FIRST. plan-format.md already carries a "Files to modify" authoring shape
with its own enforcement level, a "### Scope-Hypothesis / task-list self-consistency obligation",
and a "## Risks & Mitigations" section in the skeleton. The fix almost certainly belongs in the
interaction between those, not in a new top-level section.

EDIT TARGET (source store, NOT the deployed mirror). Per .claude/rules/source-store-deploy-boundary.md,
`.claude/**` here is a gitignored deploy artifact; source_dir for the `core` extension resolves
from .claude-extensions.json to /home/benjamin/.config/nvim/agent-system/extensions/core. Edit:
- /home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md
  (the "Files to modify" enforcement-level subsections, the Scope-Hypothesis self-consistency
  obligation, and the "## Risks & Mitigations" skeleton entry)

NOTE ON FILE TERRITORY: plan-format.md is shared with the sibling tasks created from this same
approved batch; this task is last in that serialized chain.

OPEN-RECORD RECONCILIATION -- READ THIS BEFORE PLANNING (backlog audit run at creation time;
verdict recorded verbatim in this entry's `audit_verdict` field). Verdict `subset-of-open` against
#912 `coupled_generated_surfaces_in_plan_authoring` [not_started]: this task's entire declared
file scope (`core/context/formats/plan-format.md`) is a mechanical SUBSET of #912's, and the
subject is adjacent rather than merely co-located.

#912's Defect A targets the same mechanism from the other side: it asks for "a general,
repo-agnostic coupled-generated-surface declaration obligation in
core/context/formats/plan-format.md's 'Files to modify' contract", i.e. that a phase whose edits
move a quantity a generated artifact derives MUST declare that artifact's path in the SAME phase's
Files to modify block and schedule its regeneration there. #912 names
`scripts/check-module-invariants.sh` and the generated README inventory blocks explicitly -- the
very generator and the very README this task's evidence is about.

RULING, rendered at creation time rather than deferred: this record is filed as a REFINEMENT of
#912's remedy (i), not as independent work, and carries a hard dependency on #912. #912 establishes
that a generated surface must be DECLARED; this record adds the distinction #912 does not make --
that a generator-written file is a DIFFERENT CATEGORY from a hand-edited read-only one, so a risk
table cannot declare the former read-only without stating an obligation the plan cannot keep. The
918 evidence is the post-#912-filing recurrence that shows declaration alone is insufficient.

THEREFORE, explicitly admissible outcomes for this record, to be decided in its own research phase
rather than assumed: (a) if #912's implementation already distinguishes generator-written from
hand-edited read-only scope when it lands, close this record as covered, naming #912's artifact as
the discharging evidence -- do NOT re-litigate it; (b) otherwise, implement the distinction here on
top of #912's landed obligation. Silently duplicating #912's remedy is the one outcome ruled out.
=== TERMINAL DISPOSITION: ABANDONED HERE, MIGRATED OUT (no work was lost) ===

This record was filed in this repository by mistake and has been relocated, whole and one-for-one,
into the repository that owns the shared agent-system source store. Nothing was dropped and nothing
was divided: the migrated record carries this description verbatim, including every iss_* citation
id, plus a migration note recording how its cross-repo citations were made resolvable.

WHY ABANDONED RATHER THAN EXPANDED, decided rather than defaulted. EXPANDED is for a record divided
into children inside the same task space; no children were created here and no part of this work
remains in this repository. The relocation is a change of owning repository, not a decomposition,
so the terminal state that fits is ABANDONED -- this record will never be worked here, while the
work itself is live elsewhere.

WHY IT COULD NOT STAY. Its file_scope names only paths under the shared source store at
~/.config/nvim/agent-system/**. That work cannot be performed or committed from this repository,
and this repository's own .claude/** tree is a gitignored, disposable deploy artifact regenerated
from that store, so editing here would be silently wiped by the next regeneration.

WHERE THE WORK WENT (durable anchors, paired with the number as the pointer hazard requires).
Repository: /home/benjamin/.config/nvim (specs/state.json, specs/TODO.md). The migrated record
keeps this record's own project_name slug unchanged, which is the anchor to match on; the number it
was allocated there belongs to that repository's independent numbering space and is unstable under
vault renumbering, so match on the slug first and treat any number as corroboration only.

---

### 922. Define Goal Polarity semantics for decision-gate plans
- **Status**: [ABANDONED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: Task 912, Task 914, Task 921

**Description**: Agent-system change request from the /orchestrate conclusion stage (channel b), approved by the user.

ORIGINATING EVIDENCE (issue-log entry; audit the proposal against it before acting):
- {task 917, iss_1794372876974_DWXNdc}

OBSERVED DEFECT (severity: minor). plan-format.md requires a `## Lean Challenge Statements` block
whose identifier set equals the plan's Goals, and lean-plan-compliance-check.sh's Final
Verification Stage spot-check then requires every named identifier to be PRESENT in the resolved
Lean source roots. A DECISION-GATE plan -- one whose later phases may legitimately close
`[COMPLETED WITH EXCLUSIONS]` because the gate resolved the other way -- cannot satisfy those
must-exist semantics. The `refutation` polarity is equally wrong for it: the identifiers are not
required to be ABSENT either.

917 worked around this by declaring an explicit non-`refutation` Goal Polarity value, which makes
the spot-check record `compliance_check: "skipped"` with a stated reason. That is the documented
mixed-polarity escape hatch, used here for a purpose it was not written for.

CHANGE REQUEST. The polarity vocabulary has no `conditional` value. Pick one of two resolutions
and implement it fully:
(a) add a `conditional` value with DEFINED check semantics for decision-gate plans (what the
    spot-check asserts, and what it records, when the gate may foreclose a Goal); or
(b) document the non-`refutation`-polarity workaround as the SANCTIONED route for decision-gate
    plans, named as such in plan-format.md, so the next planner does not rediscover it.
Resolution (b) is cheaper and may well be correct -- do not assume (a) is the answer. Whichever
is chosen, the existing `refutation` and mixed-polarity semantics must not change behaviour for
plans already relying on them.

CURRENT STATE TO READ FIRST. plan-format.md's "## Goal Polarity (optional, lean/lean4 plans)"
section already defines: field-absent default (every identifier must be present), `refutation`
(every identifier must be absent), and the mixed-polarity ruling (any explicitly declared
non-`refutation` value records `skipped` with a stated reason). Note the implication: the escape
hatch already works mechanically -- what is missing is naming it for this case.

EDIT TARGET (source store, NOT the deployed mirror). Per .claude/rules/source-store-deploy-boundary.md,
`.claude/**` here is a gitignored deploy artifact; source_dir resolves from .claude-extensions.json
to /home/benjamin/.config/nvim/agent-system/extensions/{core,lean}. Edit:
- /home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md
  (the "## Goal Polarity (optional, lean/lean4 plans)" section)
- /home/benjamin/.config/nvim/agent-system/extensions/lean/scripts/lean-plan-compliance-check.sh
  (only if resolution (a) is chosen)
- /home/benjamin/.config/nvim/agent-system/extensions/lean/scripts/tests/test-lean-plan-compliance-check.sh

NOTE ON FILE TERRITORY: plan-format.md and lean-plan-compliance-check.sh are shared with the
sibling tasks created from this same approved batch; this task is serialized behind the
symmetric-pair phase-sizing task, which is itself behind the pinned-signature-measurement task.

OPEN-RECORD RECONCILIATION (backlog audit run at creation time; verdict recorded verbatim in this
entry's `audit_verdict` field). Verdict `overlaps-open` against #912
`coupled_generated_surfaces_in_plan_authoring` and #914
`batch_gate_deferral_narrowing_for_project_sources`, both [not_started], 1 shared path each:
`core/context/formats/plan-format.md`. RULING: not duplicates -- file territory only; neither
record concerns Goal Polarity. Dependency edges on both are recorded rather than exclusions.
Separately, the audit's highest-scoring closed match is #785
`lean_plan_gate_collision_authoring_guidance` (semantic 0.68), which authored the gate-collision
conditions this plan-format area sits in, and #827 `plan_self_consistency_and_artifact_existence`
(0.64). Read both before planning and decide explicitly whether the decision-gate polarity case is
already addressed there; the 917 evidence is a post-closure recurrence, which is why it is filed.
=== TERMINAL DISPOSITION: ABANDONED HERE, MIGRATED OUT (no work was lost) ===

This record was filed in this repository by mistake and has been relocated, whole and one-for-one,
into the repository that owns the shared agent-system source store. Nothing was dropped and nothing
was divided: the migrated record carries this description verbatim, including every iss_* citation
id, plus a migration note recording how its cross-repo citations were made resolvable.

WHY ABANDONED RATHER THAN EXPANDED, decided rather than defaulted. EXPANDED is for a record divided
into children inside the same task space; no children were created here and no part of this work
remains in this repository. The relocation is a change of owning repository, not a decomposition,
so the terminal state that fits is ABANDONED -- this record will never be worked here, while the
work itself is live elsewhere.

WHY IT COULD NOT STAY. Its file_scope names only paths under the shared source store at
~/.config/nvim/agent-system/**. That work cannot be performed or committed from this repository,
and this repository's own .claude/** tree is a gitignored, disposable deploy artifact regenerated
from that store, so editing here would be silently wiped by the next regeneration.

WHERE THE WORK WENT (durable anchors, paired with the number as the pointer hazard requires).
Repository: /home/benjamin/.config/nvim (specs/state.json, specs/TODO.md). The migrated record
keeps this record's own project_name slug unchanged, which is the anchor to match on; the number it
was allocated there belongs to that repository's independent numbering space and is unstable under
vault renumbering, so match on the slug first and treat any number as corroboration only.

---

### 921. Size symmetric-pair phases and iteration obligations separately
- **Status**: [ABANDONED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: Task 912, Task 914, Task 920

**Description**: Agent-system change request from the /orchestrate conclusion stage (channel b), approved by the user.

ORIGINATING EVIDENCE (issue-log entry; audit the proposal against it before acting):
- {task 918, iss_1794387530357_nlDygI}

OBSERVED DEFECT (severity: costly). Phase sizing. 918's Phase 3 budgeted 2.5 hours and an
estimated +220 lines for "both directions" of the composite splice. The raising primitive's
ADMISSIBILITY HALF ALONE came to +276 lines -- the single estimate for a symmetric pair was
already exceeded by one of its two halves.

Two compounding omissions, both invisible in the plan's task list:
- The raise must be ITERATED to reach an exact multiple of `P + 1`. The only landed iterate
  carries the pending-forever hypothesis that the task's own regime DENIES -- in two separate
  places. None of this appeared as a task-list item.
- The composite's formulation had to be REDESIGNED mid-phase to be iterable at all.

Outcome: three of seven phases landed rather than seven.

CHANGE REQUEST. Add a plan-authoring rule with two clauses:
(1) A phase claiming "both directions" -- or any symmetric pair, biconditional, or round-trip of
    a primitive -- must size and schedule EACH DIRECTION SEPARATELY. One budget covering a
    symmetric pair is not a budget.
(2) An ITERATION or CLOSURE obligation on a landed primitive (iterate to reach a multiple, take a
    transitive/reflexive closure, discharge a hypothesis the regime denies) must appear as its
    OWN NAMED task-list item, not be absorbed into the primitive's phase.
Make both clauses checkable: state the enforcement level (blocking vs advisory) in the same style
as plan-format.md's existing enforcement-level subsections, and say what a reviewer or script
looks for.

CURRENT STATE TO READ FIRST. plan-format.md already carries "## Implementation Phases (format)",
a "### Counts-are-hypotheses obligation", a "### Cross-phase ceiling consistency obligation", and
per-obligation "### Enforcement level" subsections -- the new rule should match that established
shape rather than invent a new one. hard-mode-routing.md separately states phase sizing (H8) as
"each phase bounded to one agent run (~100-500 lines output)"; the +276-line half inside a
+220-line budget is a direct H8 datapoint, so check whether H8's wording also needs the
symmetric-pair clause. planner-agent.md is the agent that must actually apply the rule.

EDIT TARGET (source store, NOT the deployed mirror). Per .claude/rules/source-store-deploy-boundary.md,
`.claude/**` here is a gitignored deploy artifact; source_dir for the `core` extension resolves
from .claude-extensions.json to /home/benjamin/.config/nvim/agent-system/extensions/core. Edit:
- /home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md
  ("## Implementation Phases (format)" and its obligation/enforcement-level subsections)
- /home/benjamin/.config/nvim/agent-system/extensions/core/context/guides/hard-mode-routing.md
  (the H8 phase-sizing entry)
- /home/benjamin/.config/nvim/agent-system/extensions/core/agents/planner-agent.md

NOTE ON FILE TERRITORY: plan-format.md is shared with the sibling tasks created from this same
approved batch; this task is serialized behind the pinned-signature-measurement task.

OPEN-RECORD RECONCILIATION (backlog audit run at creation time; verdict recorded verbatim in this
entry's `audit_verdict` field). The audit emitted `duplicate-of-open` against #912
`coupled_generated_surfaces_in_plan_authoring` [not_started] (2 shared paths:
`core/context/formats/plan-format.md`, `core/agents/planner-agent.md`; semantic score 0.40).
RULING: NOT a duplicate -- the shared verdict is driven by file territory, not subject. #912's two
defects are (A) coupled generated surfaces going undeclared in a phase's Files to modify, and (B)
`linter.style.longFile` acceptance-window semantics. Neither is phase SIZING of a symmetric pair,
and neither covers an unscheduled iteration/closure obligation. What IS shared is the authoring
surface: #912 adds a declaration obligation to plan-format.md's "Files to modify" contract and adds
a lean-context pointer to planner-agent.md. A dependency edge on #912 is recorded rather than an
exclusion, so this task amends plan-format.md and planner-agent.md after #912's edits land, not
against a stale reading of them. #914 also carries plan-format.md in its scope; an edge on it is
recorded for the same reason.
=== TERMINAL DISPOSITION: ABANDONED HERE, MIGRATED OUT (no work was lost) ===

This record was filed in this repository by mistake and has been relocated, whole and one-for-one,
into the repository that owns the shared agent-system source store. Nothing was dropped and nothing
was divided: the migrated record carries this description verbatim, including every iss_* citation
id, plus a migration note recording how its cross-repo citations were made resolvable.

WHY ABANDONED RATHER THAN EXPANDED, decided rather than defaulted. EXPANDED is for a record divided
into children inside the same task space; no children were created here and no part of this work
remains in this repository. The relocation is a change of owning repository, not a decomposition,
so the terminal state that fits is ABANDONED -- this record will never be worked here, while the
work itself is live elsewhere.

WHY IT COULD NOT STAY. Its file_scope names only paths under the shared source store at
~/.config/nvim/agent-system/**. That work cannot be performed or committed from this repository,
and this repository's own .claude/** tree is a gitignored, disposable deploy artifact regenerated
from that store, so editing here would be silently wiped by the next regeneration.

WHERE THE WORK WENT (durable anchors, paired with the number as the pointer hazard requires).
Repository: /home/benjamin/.config/nvim (specs/state.json, specs/TODO.md). The migrated record
keeps this record's own project_name slug unchanged, which is the anchor to match on; the number it
was allocated there belongs to that repository's independent numbering space and is unstable under
vault renumbering, so match on the slug first and treat any number as corroboration only.

---

### 920. Require pinned Lean Challenge signatures to be measured at plan time
- **Status**: [ABANDONED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: Task 912, Task 914

**Description**: Agent-system change request from the /orchestrate conclusion stage (channel b), approved by the user.

ORIGINATING EVIDENCE (issue-log entries; audit the proposal against these before acting):
- {task 917, iss_1794374793101_psy7sY}
- {task 917, iss_1794375246019_OW3KwL}

OBSERVED DEFECT (severity: blocking). Pinned Lean Challenge signatures were authored without
being measured. 917's Phase 4 pinned statement for `exists_deleted_ladderPath_of_next_region_nxt`
was unprovable AS PINNED -- incomplete by exactly one hypothesis (`nxtAt g z <= cntAt g z`).

The plan's own Decision 3 had assumed every pin between `z` and the deleted block is undisplaced.
Their POSITIONS are; but `delCnt` lowers the VALUE of the pin starting the region that contains
the block, by exactly `l`. The deficit was measured by compiling the proof with and without the
hypothesis (both variants preserved under that task's evidence/), the phase was marked BLOCKED
per lean plan-compliance.md's Statement Fidelity rule rather than laundering the extra hypothesis
under the pinned name, and a mid-task plan revision was required.

THE PRACTICE THAT AVOIDED IT ALREADY EXISTS, VOLUNTARILY. 918's planner then measured all four of
its pinned arithmetic statements through `lake env lean` BEFORE closing the plan, and deliberately
left its gate-dependent signatures unpinned -- recording in its own Decisions that an unmeasured
pin is exactly what forced 917's revision.

CHANGE REQUEST. Promote that voluntary practice into the plan-authoring contract: a pinned
Challenge signature must EITHER be compiled sorry-free at plan time (evidence recorded) OR be
explicitly marked unpinned / gate-dependent. Define what "measured" means operationally (what
command, what evidence, where recorded) and what the compliance checker does with an unmeasured
pin, so the obligation is checkable rather than aspirational.

CONSTRAINT TO PRESERVE. Statement Fidelity must stay intact: the point is not to permit
weakening a pinned statement once reality disagrees, it is to make the disagreement surface at
plan time instead of mid-implementation.

EDIT TARGET (source store, NOT the deployed mirror). Per .claude/rules/source-store-deploy-boundary.md,
`.claude/**` here is a gitignored deploy artifact; source_dir resolves from .claude-extensions.json
to /home/benjamin/.config/nvim/agent-system/extensions/{core,lean}. Edit:
- /home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md
  (the "## Lean Challenge Statements (format, lean/lean4 plans only)" section)
- /home/benjamin/.config/nvim/agent-system/extensions/lean/rules/plan-compliance.md
  (the "## Statement Fidelity" section)
- /home/benjamin/.config/nvim/agent-system/extensions/lean/scripts/lean-plan-compliance-check.sh
- /home/benjamin/.config/nvim/agent-system/extensions/lean/scripts/tests/test-lean-plan-compliance-check.sh

NOTE ON FILE TERRITORY: plan-format.md and lean-plan-compliance-check.sh are shared with the
sibling tasks created from this same approved batch (goal-polarity semantics for decision-gate
plans; generator-written vs read-only scope; symmetric-pair phase sizing). This task is first in
that serialized chain; the others depend on it.

OPEN-RECORD RECONCILIATION (backlog audit run at creation time; verdict recorded verbatim in this
entry's `audit_verdict` field). Verdict `overlaps-open` against #912
`coupled_generated_surfaces_in_plan_authoring` and #914
`batch_gate_deferral_narrowing_for_project_sources`, both [not_started], 1 shared path each:
`core/context/formats/plan-format.md`. RULING: not duplicates -- neither record concerns Lean
Challenge pin measurement; the shared verdict is file territory only. Dependency edges on both are
recorded rather than exclusions, so this task amends plan-format.md after their edits land.
Separately, two CLOSED records sit near this subject and must be decided explicitly rather than
silently resurrected or silently skipped: #813 `lean_plan_challenge_block_authoring_contract` and
#824 `fixture_dependent_challenge_statement_pinning` (both surfaced `covered-by-closed`). Read
both before planning: if either already fixes the measurement obligation, say so and close this
record against it; the 917 evidence is a post-closure recurrence, which is why it is filed.
=== TERMINAL DISPOSITION: ABANDONED HERE, MIGRATED OUT (no work was lost) ===

This record was filed in this repository by mistake and has been relocated, whole and one-for-one,
into the repository that owns the shared agent-system source store. Nothing was dropped and nothing
was divided: the migrated record carries this description verbatim, including every iss_* citation
id, plus a migration note recording how its cross-repo citations were made resolvable.

WHY ABANDONED RATHER THAN EXPANDED, decided rather than defaulted. EXPANDED is for a record divided
into children inside the same task space; no children were created here and no part of this work
remains in this repository. The relocation is a change of owning repository, not a decomposition,
so the terminal state that fits is ABANDONED -- this record will never be worked here, while the
work itself is live elsewhere.

WHY IT COULD NOT STAY. Its file_scope names only paths under the shared source store at
~/.config/nvim/agent-system/**. That work cannot be performed or committed from this repository,
and this repository's own .claude/** tree is a gitignored, disposable deploy artifact regenerated
from that store, so editing here would be silently wiped by the next regeneration.

WHERE THE WORK WENT (durable anchors, paired with the number as the pointer hazard requires).
Repository: /home/benjamin/.config/nvim (specs/state.json, specs/TODO.md). The migrated record
keeps this record's own project_name slug unchanged, which is the anchor to match on; the number it
was allocated there belongs to that repository's independent numbering space and is unstable under
vault renumbering, so match on the slug first and treat any number as corroboration only.

---

### 919. Re-verify or timestamp a task recorded starting position at dispatch composition
- **Status**: [ABANDONED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: Task 914

**Description**: Agent-system change request from the /orchestrate conclusion stage (channel b), approved by the user.

ORIGINATING EVIDENCE (issue-log entries; audit the proposal against these before acting):
- {task 917, iss_1794371652447_TTinEN}
- {task 918, iss_1794383423202_EAr4Us}

OBSERVED DEFECT (recurs across BOTH tasks in that batch; severity: costly). The dispatch file's
hand-authored "VERIFIED STARTING POSITION" block carried a task-description snapshot that was
roughly 38 wired probes out of date in both tasks.

For 918 the consequence was not cosmetic: one of the task's two admissible outcomes -- a
refutation that the two parameter constraints cannot be jointly met -- had ALREADY been
foreclosed by compiled code (`paramsOk_params` discharges all four of (K1)-(K4) at exhibited
parameters), so the task as described could not be executed as written.

For 917 the stale block named three landed depth-0 cell-equality schemas where the tree carried
five, and asserted that discharging `ForwardSlackWitnessed` would land
`cellLE_zero_const_of_kappa_eq` -- which it would not, since the reserved schema quantifies over
all kappa-collisions while every landed inclusion carries the pending-forever gap `n+2 <= c`.

In both cases the receiving agent had to re-derive the current frontier from source before it
could scope its own task, and discovered the staleness by contradiction rather than being told.

CHANGE REQUEST. Provide a mechanism or convention that, at dispatch-composition time,
re-verifies the task's recorded starting position -- or, failing that, visibly timestamps it and
flags it as unverified -- so a research or plan agent is told the snapshot's age up front.

STARTING POINT ALREADY IN THE TREE (verify before designing anything new). The dispatch composer
already carries a "Premise re-validation block" whose owner ruling is "the composer EMITS, it
never ADJUDICATES": it lexically extracts numeric/measurement/pass-fail/ratio/hard-claim shapes
from the current description and emits them, but only when the task directory already holds a
prior artifact, and it attaches no age or verification status. It also already computes a
`description_fingerprint` (sha256 of the description) to mark recorded Prior Decisions as
POTENTIALLY SUPERSEDED. Both mechanisms are plausible carriers for this request; a third,
independent mechanism is probably the wrong answer. Respect the EMITS-not-ADJUDICATES ruling --
re-deriving semantic truth of a claim inside the composer was explicitly rejected once already
(see report-format.md's "Internal consistency" paragraph).

EDIT TARGET (source store, NOT the deployed mirror). Per .claude/rules/source-store-deploy-boundary.md,
`.claude/**` here is a gitignored deploy artifact; source_dir for the `core` extension resolves
from .claude-extensions.json to /home/benjamin/.config/nvim/agent-system/extensions/core. Edit:
- /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/orchestrate-build-dispatch.sh
- /home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/report-format.md
  (the "## Carried-Figure Discipline" / "The premise a dispatch acts on" subsection that owns
  the premise concept)
- /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-orchestrate-build-dispatch.sh
  (the composer's existing test suite -- any emission change needs coverage here)

OPEN-RECORD RECONCILIATION (backlog audit run at creation time; verdict recorded verbatim in this
entry's `audit_verdict` field). Verdict `overlaps-open` against #914
`batch_gate_deferral_narrowing_for_project_sources` [not_started], 2 shared paths:
`core/scripts/orchestrate-build-dispatch.sh` and its test suite
`core/scripts/tests/test-orchestrate-build-dispatch.sh`. #914's subject is different (giving the
Batch Gate Deferral directive a narrowing form for project-only phases), but it rewrites the same
composer and the same test file. RULING: not a duplicate -- a file-territory overlap. A dependency
edge on #914 is recorded rather than an exclusion, so the two land as a sequence; do not plan this
task against a pre-#914 reading of the composer.
=== TERMINAL DISPOSITION: ABANDONED HERE, MIGRATED OUT (no work was lost) ===

This record was filed in this repository by mistake and has been relocated, whole and one-for-one,
into the repository that owns the shared agent-system source store. Nothing was dropped and nothing
was divided: the migrated record carries this description verbatim, including every iss_* citation
id, plus a migration note recording how its cross-repo citations were made resolvable.

WHY ABANDONED RATHER THAN EXPANDED, decided rather than defaulted. EXPANDED is for a record divided
into children inside the same task space; no children were created here and no part of this work
remains in this repository. The relocation is a change of owning repository, not a decomposition,
so the terminal state that fits is ABANDONED -- this record will never be worked here, while the
work itself is live elsewhere.

WHY IT COULD NOT STAY. Its file_scope names only paths under the shared source store at
~/.config/nvim/agent-system/**. That work cannot be performed or committed from this repository,
and this repository's own .claude/** tree is a gitignored, disposable deploy artifact regenerated
from that store, so editing here would be silently wiped by the next regeneration.

WHERE THE WORK WENT (durable anchors, paired with the number as the pointer hazard requires).
Repository: /home/benjamin/.config/nvim (specs/state.json, specs/TODO.md). The migrated record
keeps this record's own project_name slug unchanged, which is the anchor to match on; the number it
was allocated there belongs to that repository's independent numbering space and is unstable under
vault renumbering, so match on the slug first and treat any number as corroboration only.

---

### 918. Ladder cell index positive factorization
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 917
- **Parent**: Task 761
- **Research**: [918_ladder_cell_index_positive_factorization/reports/01_ladder-cell-index-positive-factorization.md]
- **Plan**: [918_ladder_cell_index_positive_factorization/plans/01_ladder-cell-window-regime.md]
- **Summary**: [918_ladder_cell_index_positive_factorization/summaries/01_ladder-cell-window-regime-summary.md]

**Description**: Produce a positive factorization lemma for the index of which cell a ladder state has, or compile a refutation that no index meeting the recorded constraints exists. This is the SECOND, INDEPENDENT blocker on the ladder realization theorem -- the one the cell-agreement chain does not touch.

VERIFIED STARTING POSITION (every refutation below is a compiled wired probe, not an argument):
(1) The realization theorem is BLOCKED on this index, separately from the cell agreement. FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean claims NO index of a ladder cell.
(2) The clipped-coordinate index family is REFUTED at the countdown coordinate and bounded at the gap one by specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean: the region's first idle state sits at distance exactly c + 1, where the countdown's parity is observable.
(3) The bounded-carrier alternative is closed AS A GENERAL ROUTE by that same probe.
(4) The residue-carrying candidate that probe exhibits is refuted at BOTH of its object-exhibited parameters by specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean (object_only_parameters_refuted, reach_period_refuted).

THE CONSTRAINTS ARE THEREFORE COMPILED, NOT GUESSED. Any index must satisfy both: the threshold must be FORMULA-derived, not object-exhibited; and the modulus must be a MULTIPLE OF THE PERIOD of every letter-definable sub-object. A candidate violating either is already refuted by (4) and must not be re-attempted.

TWO ADMISSIBLE OUTCOMES: the positive factorization lemma under those two constraints, or a compiled refutation that they cannot be jointly met -- which would close the ladder route for the realization theorem and is a reportable negative result, not a failure. The stabilization lemma in the pair of ladder counters is ALREADY refuted (ladder-cell-refutation.lean) and is not to be re-attempted; this task is about the index, not the stabilization.

SCOPE: the index only. Different file set from the cell-agreement siblings, so this may run concurrently with them.

---

### 917. Forward slack witnessed discharge or refutation
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 916
- **Parent**: Task 910
- **Research**: [917_forward_slack_witnessed_discharge_or_refutation/reports/01_forward-slack-witnessed-discharge.md]
- **Plan**: [917_forward_slack_witnessed_discharge_or_refutation/plans/01_forward-slack-witnessed-discharge.md]
- **Summary**: [917_forward_slack_witnessed_discharge_or_refutation/summaries/01_forward-slack-witnessed-discharge-summary.md]

**Description**: Discharge ForwardSlackWitnessed under ParamsOk, or compile a refutation showing it is unremovable. This is the hypothesis that currently keeps every landed depth-0 cell-equality schema from bearing on the reserved obligation in either direction.

VERIFIED STARTING POSITION (compiled, not argued):
(1) THREE depth-0 cell-EQUALITY schemas are landed in FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean -- cellLE_zero_const_of_kappa_eq_of_forwardSlack (equal register), cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack (common shift, register freed), and cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack (monotone, carrying neither restriction and specializing to both the others at the equal-register and common-shift instances). ALL THREE carry ForwardSlackWitnessed as a hypothesis a consumer must supply, and nothing in the tree discharges it.
(2) Consequently all three are STRICTLY STRONGER IN HYPOTHESES than the reserved statement and bear on its truth value in NEITHER DIRECTION. The reserved name cellLE_zero_const_of_kappa_eq has no declaration site anywhere under FormalSystem/, and CellLEZeroConstOfKappaEq under ParamsOk stays neither proved nor refuted.
(3) ForwardSlackWitnessed (LadderCell.lean:718) lifts the forward-slack regime from one path to a whole cell: every type the cell at a state realizes is realized there by SOME path carrying HasForwardSlack. Being an existential over paths it is untouched by ClimbWitness.hasForwardSlack_refuted_unconditional (LadderChain.lean:1497), which refutes the PER-PATH state-level regime -- that asymmetry is why the existential form survives while the per-path one does not. It asserts nothing as it stands; it is a hypothesis.
(4) A second, independent restriction travels with it: the room bounds. The monotone schema carries a room bound on the upper pair plus that pair's own gap; the common-shift one carries a DOUBLED displacement amount (one multiple of P+1 for the countdown, one for the lowered anchor) with a correspondingly doubled room bound. None of these is implied by, nor implies, the pending-forever gap.

TWO ADMISSIBLE OUTCOMES: discharge ForwardSlackWitnessed from ParamsOk (plus the room bounds, if they come free), landing cellLE_zero_const_of_kappa_eq at last; or compile a refutation that it is derivable, which is itself a result -- it would force certStabK's one unclaimed Real condition to be RESTATED rather than proved, and that consequence must be recorded if so. Never leave the verdict tacit.

SCOPE: the hypothesis discharge only. The antitone slice of the collision dichotomy belongs to a sibling, and this task must not land anything under the reserved name unless the discharge actually succeeds

OUTCOME: the SECOND admissible outcome was reached, and it is RECORDED here rather than left tacit. ForwardSlackWitnessed is NOT discharged, and the discharge route is REFUTED AT THE PIN LAYER rather than merely unproved. The route attempted was to delete a type-respecting block inside the first region above z's own region with the register held at z, and iterate to drive that region's countdown below tShort. Its deletion primitive exists_deleted_ladderPath_of_next_region_nxt landed (LadderChain.lean, section DelNxt) taking exactly two clauses as hypotheses, hanch and hstraddle; BOTH are non-dischargeable from the pending-forever regime at countdown at least Tc together with ParamsOk -- hanch by exactly l, hstraddle by exactly 2*l, where l is the deleted block's length. On a path whose straddling pin pair saturates pin compatibility the primitive's own CONCLUSION is false, since any deleted path would itself be a ladder path and pinCompat_of_ladderPath would bind its pins at exactly the broken positions. (K2)'s budget cannot pay: cascadeBound's recurrence a(k+1) <= 2*a k + J + 1 is the bound the saturated configuration ATTAINS WITH EQUALITY, Adm places no upper bound on a pending state's countdown, and every ParamsOk conjunct the thresholds enter is a LOWER bound on a parameter. Compiled records: specs/evidence/forward-slack-pin-cascade/pin-cascade-straddle.lean (wired into scripts/check-evidence-probes.sh) for the path-level refutation, and this task's evidence/phase-5-gate-measurement.lean for the scale-invariant arithmetic.

THE NAMED CONSEQUENCE, recorded as this description required: because the hypothesis is not derivable by this route and stays carried on all five depth-0 cell-equality schemas of LadderCell.lean, certStabK's one unclaimed Real condition must be RESTATED rather than proved for as long as that remains the case. The reserved name cellLE_zero_const_of_kappa_eq is still claimed by nothing. What is NOT established: ForwardSlackWitnessed is an existential over paths, so a saturated path may still realize each of its types via some other path carrying HasForwardSlack -- the hypothesis itself is neither discharged nor refuted, and only this route through the pin layer is refuted.

---

### 916. Antitone collision residue lower pair witnessing
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Parent**: Task 910
- **Research**: [916_antitone_collision_residue_lower_pair_witnessing/reports/01_antitone-collision-residue-witnessing.md]
- **Plan**: [916_antitone_collision_residue_lower_pair_witnessing/plans/01_antitone-slice-dispatch.md]
- **Summary**: [916_antitone_collision_residue_lower_pair_witnessing/summaries/01_antitone-slice-dispatch-summary.md]

**Description**: Dispatch or compile a refutation of the ANTITONE slice of a kappa-class collision -- the complement that cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack excludes in its own quantifier.

VERIFIED STARTING POSITION (compiled, not argued):
(1) kappa_collision_monotone_or_antitone makes the monotone and antitone slices an EXHAUSTIVE dichotomy over collisions, with no third case. The monotone slice is dispatched as depth-0 cell EQUALITY by cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack (FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean); the antitone slice is excluded by a named hypothesis, not refuted.
(2) The excluded slice is NOT vacuous: kappa_collision_antitone_residue_nonvacuous inhabits it inside the pending-forever regime above the threshold at the pairs (4,2) against (6,0).
(3) The reason the free-register raise reaches the monotone side and no further is compiled, not asserted: free_register_anchor_clause_monotone_required shows the lower bound nxtAt g z <= n0 of exists_ladderPath_through_free_register_shifted_of_pend_past is NON-REMOVABLE at the arithmetic witness X = 19, nz = 8, cz = 10, mP = 0, n0 = 0, d = 11. The two bounds on the free anchor pay for OPPOSITE directions of the one anchor clause -- the lower for the register two-sided Lipschitz bound, the upper for the pin distance -- so an antitone displacement puts the register on the wrong side of the clause the raise closes.

THE ROUTE IS NAMED AND CLAIMED IN NEITHER DIRECTION (recorded by its predecessor in both the necessity record docstring and RaySummary/README.md): forward-slack witnessing at the LOWER pair, to pay the upper anchor direction the necessity record compiles as failing. That is the statement to try first; it is not a prediction that it holds.

TWO ADMISSIBLE OUTCOMES, both closing the dichotomy: dispatch the slice with a genuine argument, or compile a refutation. A refutation is as good an outcome as a proof and must be a compiled witness, never an argument. The reserved name cellLE_zero_const_of_kappa_eq stays reserved either way and nothing may land under it here.

SCOPE: the antitone slice only. It does not reach the ForwardSlackWitnessed discharge, which a sibling owns.

---

### 915. Reconvert reindex reynolds auxiliary atoms sections
- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: general
- **Topic**: completeness
- **Dependencies**: None
- **Parent**: Task 894
- **Research**: [915_reconvert_reindex_reynolds_auxiliary_atoms_sections/reports/01_reynolds-sections-5-8-reconversion.md]
- **Plan**: [915_reconvert_reindex_reynolds_auxiliary_atoms_sections/plans/01_reynolds-sections-5-8-splice.md]
- **Summary**: [915_reconvert_reindex_reynolds_auxiliary_atoms_sections/summaries/01_reynolds-sections-5-8-splice-summary.md]

**Description**: Re-convert and re-index reynolds_2001 with sections 5-8 included, so the Auxiliary Atoms rule has a citable source statement in the corpus. Evidence: literature-search.sh returns nothing for 'auxiliary atoms' in a formal-logic sense, and reynolds_2001's existing sub-index entry skips the axiom-system sections where the rule sits (its TOC jumps 4.7-4.8 straight to 9). Research on the forward-cone unravelling proceeded from FormalSystem/Metalogic/NamingRules.lean's recorded Saturation obligation as the source of record instead. The Auxiliary-Atoms rule for L-plus at ZTime is the direct subject of a downstream task, which needs the rule's actual source statement rather than only the repo's recorded obligation. Deliverable: the converted sections present in Literature/, a refreshed specs/literature-index.json entry covering them, and a literature-search.sh query for the rule that returns the right chunk.

---

### 914. Give the batch-gate-deferral directive a narrowing form that covers a phase touching only project sources, not the agent-system deploy tree
- **Status**: [ABANDONED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: Task 912

**Description**: META TASK. Source store resolved from .claude-extensions.json: /home/benjamin/.config/nvim/agent-system/extensions. All edits land there, never under .claude/**.

Measured in task 853 (citations: 853:iss_1794302893073_ova4vV, 853:iss_1794308541955_gBjHi5). The '## Batch Gate Deferral' directive composed by scripts/orchestrate-build-dispatch.sh (emitted when --batch-gate-deferral is passed, implement phase only) names exactly two narrowing forms: run-all.sh --only SUITE and verify-deploy.sh --only-gate N. BOTH are scoped to the agent-system deploy tree and its shell test suites. Neither covers Lean library sources. Phases that touched only FormalSystem/**, Tests/**, typst/generated/status.typ and task artifacts therefore had no applicable narrowing form, and the agents correctly recorded the mismatch rather than invoking an unrelated gate for the appearance of compliance.

What exists today and why it does not close this. The directive already carries an 'UNMAPPABLE CRITERION' clause (and core/context/formats/plan-format.md's 'Batch-aware deferral' subsection carries its 'Unmappable criterion' paragraph), but both are keyed on the phase's own DECLARED criterion naming a repository-specific check that neither narrowing form can express. The case measured here is different and more basic: the phase's touched files lie entirely outside the deploy tree, so no narrowing form applies at all, independent of how the criterion was worded. An agent reading the directive finds two invocations, neither of which reaches anything it touched, and no positive instruction for that case.

Remedy to design: either a third narrowing form that resolves the repository's OWN project gates (the same two-candidate, existence-checked resolution pattern the composer already uses for run_all_candidates/verify_deploy_candidates - note the project-gate names are repository-specific, so they must be resolved or declared, never hardcoded into core; scripts/gate-registry.data is the existing declarative-registry precedent to consider), or an explicit 'no applicable narrowing form' clause that names the project gates to run instead and states what counts as a recorded scoped discharge. Whichever shape is chosen, the directive, context/contracts/batch-gate-stage.md ('Narrowing-invocation paths are resolved, not hardcoded'), and plan-format.md's 'Batch-aware deferral' subsection must all agree, and the non-negotiable invariant must survive intact: the complete gate set still runs once for the batch, deferred and never forgiven. Add coverage to scripts/tests/test-orchestrate-build-dispatch.sh alongside its existing Group 19 --batch-gate-deferral assertions.

PRIOR RECORD -- decide explicitly, do not silently resurrect. This is FACE 2 of `per_phase_generated_surface_gates_and_batch_defer` (#885, ABANDONED 2026-11-06T06:57:09Z inside a 5-record meta-backlog pruning sweep with no per-record reason recorded). That record measured the same directive against a different trigger ({880, iss_1793932578569_JqSq31}: a plan phase naming the bare `scripts/check-module-invariants.sh` as its gate, superseded by a deferral directive that could not express it) and stated the decision it owed verbatim: should the directive resolve a narrowing invocation from the TARGET repository's own declared gate set (weighing `context/standards/repo-level-declarations.md` as the existing declaration surface), or should it DECLINE to supersede a plan criterion it cannot express a narrowing for, and say so in the directive text? Pick one, implement it, record the rejected alternative. The two citations from task 853 are the post-pruning recurrence.

EDIT TARGET, binding. Re-derive the source store rather than trusting any path quoted here: `source_dir` lives PER-EXTENSION at `.extensions.<name>.source_dir` in `<project-root>/.claude-extensions.json`, not as a top-level key -- a top-level `jq -r '.source_dir'` returns null and must NOT be read as the key being absent. All seven loaded extensions resolve under /home/benjamin/.config/nvim/agent-system/extensions/<name>. Edit at the path mirroring the deployed one; a hand-authored file under .claude/** is silently wiped by the next regeneration.

NOT a repair of this repository's own gates. `.githooks/pre-commit`, `scripts/typst-sync-check.sh`, `scripts/check-module-invariants.sh`, `scripts/nolint-attribute-allowlist.txt`, `typst/generated/status.typ` and the generated README inventory blocks are correct as they stand; do not edit them. The subject is agent-system guidance and mechanism only.
=== TERMINAL DISPOSITION: ABANDONED HERE, MIGRATED OUT (no work was lost) ===

This record has been relocated, whole and one-for-one, into the repository that owns the shared
agent-system source store, following that repository's own
context/patterns/cross-repo-task-migration.md. The migrated record carries this description
verbatim -- every iss_* citation id, line number and enumerated sub-fault as authored -- plus a
provenance note recording the migration, how its cross-repo citations were made resolvable, and
the disposition of each of its dependency edges.

WHY ABANDONED RATHER THAN EXPANDED, decided rather than defaulted. EXPANDED is for a record
divided into children inside the same task space; no children were created here and no part of
this work remains in this repository. The relocation is a change of owning repository, not a
decomposition, so ABANDONED is the terminal state that fits: this record will never be worked
here, while the work itself is live elsewhere.

WHY IT COULD NOT STAY. Its file_scope names only paths under the shared source store at
~/.config/nvim/agent-system/**. That work cannot be performed or committed from this repository,
and this repository's own .claude/** tree is a gitignored, disposable deploy artifact regenerated
from that store, so an edit made here would be silently wiped by the next regeneration.

WHERE THE WORK WENT (durable anchors, paired with the number as the pointer hazard requires).
Repository: /home/benjamin/.config/nvim (specs/state.json, specs/TODO.md). The migrated record
keeps this record's own project_name slug unchanged, which is the anchor to match on; the number
it was allocated there belongs to that repository's independent numbering space and is unstable
under vault renumbering, so match on the slug first and treat any number as corroboration only.

---

### 913. Provide a sanctioned in-dispatch remedy for a mechanically coupled pair path dropped by git-commit-scoped.sh's V10 containment guard
- **Status**: [ABANDONED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: Task 912

**Description**: META TASK. Source store resolved from .claude-extensions.json: /home/benjamin/.config/nvim/agent-system/extensions. All edits land there, never under .claude/**.

Measured in task 853 (citations: 853:iss_1794306406773_b3PFRR, 853:iss_1794306480665_1NQyk3). scripts/git-commit-scoped.sh's V10 containment guard drops any positive pathspec lying outside the dispatching task's declared file_scope and reports exit 7 when the commit otherwise succeeded. There is no sanctioned in-dispatch remedy for a MECHANICALLY COUPLED pair file - a path whose edit is REQUIRED by another edit the phase is making.

Concrete instance: a @[nolint unusedArguments] attribute requires a paired entry in scripts/nolint-attribute-allowlist.txt (enforced by scripts/check-module-invariants.sh C26), but that path was not in task 853's file_scope, so the guard dropped it. git-commit-scoped.sh has no --allow-out-of-scope flag (that flag belongs to scripts/git-snapshot.sh). The implementing agent landed the pair in a separate commit invoked WITHOUT --task rather than mutating state.json's file_scope from an implementation dispatch - a defensible workaround, but the required pairing then lands outside the task-scoped commit, so the commit no longer records the coupled change as part of the phase that necessitated it.

The structural reason no in-dispatch remedy exists: scripts/update-task-status.sh's --file-scope-add is RESTRICTED to operation=postflight with target_status in {research, plan, implement}, i.e. it fires AFTER the phase's commits. The widening surface and the moment the widening is needed are on opposite sides of the commit.

Design the remedy and state the rejected alternatives. Candidate shapes: (a) a narrow, audited coupled-path allowance in git-commit-scoped.sh keyed on a repo-declared pairing manifest (attribute -> allowlist, generated-artifact -> source), so V10 never drops a path the repository itself declares as coupled - this keeps the guard's refusal semantics intact for genuinely unrelated paths; (b) a pre-commit, in-dispatch file_scope widening path narrower than the full --file-scope-add surface, with its own stderr announcement in the shape of emit_file_scope_notice(); (c) leave the mechanism alone and discharge the problem entirely at plan-authoring time via the coupled-surface declaration obligation (the sibling task this one depends on), accepting a residual failure mode for pairings a plan could not foresee. Whichever is chosen, the no-sanctioned-remedy state must end: the dispatch-time guidance must name one procedure an implementing agent can follow without either widening the commit pathspec or mutating state.json mid-dispatch.

Coordinate with the plan-authoring declaration obligation landed by the task this one depends on: if that obligation makes coupled paths a plan-time declaration, remedy (a)'s manifest may be derivable from the plan's own Files to modify harvest (scripts/plan-file-scope-harvest.sh) rather than a second hand-maintained list.

PRIOR RECORDS -- decide explicitly, do not silently resurrect. `plan_contingency_file_scope_and_containment_drop` (#839, ABANDONED) owned the same V10-plus-harvest mechanism from a different trigger: a plan's declared Scope Hypothesis CONTINGENCY file, never harvested because `plan-file-scope-harvest.sh` deliberately reads only the `Files to modify` block (its own header states the exclusion outright). `git_commit_scoped_gate_refusal_diagnostic` (#845, ABANDONED) owned a narrow, message-only diagnostic defect in the same script and is NOT this record's subject. The coupled-PAIR-path trigger measured in task 853 is new residue on the mechanism #839 left unsettled; if that record's design question was abandoned as policy, settle this one the same way explicitly rather than by implementation.

EDIT TARGET, binding. Re-derive the source store rather than trusting any path quoted here: `source_dir` lives PER-EXTENSION at `.extensions.<name>.source_dir` in `<project-root>/.claude-extensions.json`, not as a top-level key -- a top-level `jq -r '.source_dir'` returns null and must NOT be read as the key being absent. All seven loaded extensions resolve under /home/benjamin/.config/nvim/agent-system/extensions/<name>. Edit at the path mirroring the deployed one; a hand-authored file under .claude/** is silently wiped by the next regeneration.

NOT a repair of this repository's own gates. `.githooks/pre-commit`, `scripts/typst-sync-check.sh`, `scripts/check-module-invariants.sh`, `scripts/nolint-attribute-allowlist.txt`, `typst/generated/status.typ` and the generated README inventory blocks are correct as they stand; do not edit them. The subject is agent-system guidance and mechanism only.
=== TERMINAL DISPOSITION: ABANDONED HERE, MIGRATED OUT (no work was lost) ===

This record has been relocated, whole and one-for-one, into the repository that owns the shared
agent-system source store, following that repository's own
context/patterns/cross-repo-task-migration.md. The migrated record carries this description
verbatim -- every iss_* citation id, line number and enumerated sub-fault as authored -- plus a
provenance note recording the migration, how its cross-repo citations were made resolvable, and
the disposition of each of its dependency edges.

WHY ABANDONED RATHER THAN EXPANDED, decided rather than defaulted. EXPANDED is for a record
divided into children inside the same task space; no children were created here and no part of
this work remains in this repository. The relocation is a change of owning repository, not a
decomposition, so ABANDONED is the terminal state that fits: this record will never be worked
here, while the work itself is live elsewhere.

WHY IT COULD NOT STAY. Its file_scope names only paths under the shared source store at
~/.config/nvim/agent-system/**. That work cannot be performed or committed from this repository,
and this repository's own .claude/** tree is a gitignored, disposable deploy artifact regenerated
from that store, so an edit made here would be silently wiped by the next regeneration.

WHERE THE WORK WENT (durable anchors, paired with the number as the pointer hazard requires).
Repository: /home/benjamin/.config/nvim (specs/state.json, specs/TODO.md). The migrated record
keeps this record's own project_name slug unchanged, which is the anchor to match on; the number
it was allocated there belongs to that repository's independent numbering space and is unstable
under vault renumbering, so match on the slug first and treat any number as corroboration only.

---

### 912. Make the coupled-generated-surface and longFile-baseline plan-authoring conditions reach the plan author, and correct the longFile acceptance window
- **Status**: [ABANDONED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: None

**Description**: META TASK. Source store resolved from .claude-extensions.json: /home/benjamin/.config/nvim/agent-system/extensions. All edits land there, never under .claude/** (rules/source-store-deploy-boundary.md).

Two plan-authoring defects measured across the aggregated issue logs of tasks 838 and 853.

DEFECT A - the dominant cross-task class, 10 entries, every phase commit in the batch. A Lean-line-moving phase trips two mechanically coupled generated surfaces: typst/generated/status.typ (scripts/typst-sync-check.sh Check 2 derives formalsystem-line-count/tests-line-count from the Lean tree; the pre-commit hook REFUSES the commit when stale) and the generated README inventory blocks (scripts/check-module-invariants.sh reports FAIL INV on stale blocks in FormalSystem/RaySummary/README.md, FormalSystem/Metalogic/README.md, root README.md). A prose-only docstring edit is enough to trigger the first. Neither path appeared in any phase's 'Files to modify' list or Scope Hypothesis in either task's plan, so each phase independently rediscovered the refusal, ran the sanctioned --fix / --emit-inventory remedy, and logged a scope excursion. Citations: 838:iss_1793728724405_1fBgOG, 838:iss_1794299302926_83yAVE, 838:iss_1794300659565_fmSIEH, 853:iss_1794302533674_MPP05G, 853:iss_1794303002229_VdtRjf, 853:iss_1794304319804_aeXwxx, 853:iss_1794304999132_eNfuE1, 853:iss_1794306369676_I5sDpc, 853:iss_1794306547357_vOYuvx, 853:iss_1794307543832_6ZVbPo.

This is NOT a missing-documentation gap. extensions/lean/context/project/lean4/patterns/plan-authoring-gate-collisions.md already carries Condition 1, which states both surfaces, the hook-blocking asymmetry, and the exact consequence ('pre-authorizes the --fix run and carries typst/generated/status.typ in its own file scope, in the same phase as the line-count change'). It is a REACH gap: that file is referenced only by extensions/lean/EXTENSION.md and extensions/lean/index-entries.json; lean4 plan-phase work routes to core's planner-agent (extensions/lean/manifest.json routing_agents.plan.lean4 = planner-agent), and core/agents/planner-agent.md contains no pointer to the lean gate-collisions checklist and no lean-specific context table at all. Nothing in the plan dispatch path puts Condition 1 in front of the author.

Remedy to design: (i) a general, repo-agnostic coupled-generated-surface declaration obligation in core/context/formats/plan-format.md's 'Files to modify' contract - author it parallel to the existing 'Whole-tree-claim declaration rule' and 'Correction-target existence obligation' subsections already there, i.e. a phase whose edits move a quantity that a generated artifact derives MUST declare that artifact's path in the same phase's Files to modify block and schedule its regeneration step in that same phase (not a later reconciliation phase) whenever the check is commit-blocking; (ii) a reach mechanism so a lean4 plan dispatch actually surfaces plan-authoring-gate-collisions.md (planner-agent context pointer keyed on lean intent, extension-provided plan-phase context injection, or an index-entries trigger - pick one and state why); (iii) consider an advisory validate-artifact check in the same shape as the existing 'Enforcement level (Files to modify authoring shape)' tier, reading a repo-declared coupling list rather than hardcoding BimodalLogic paths.

DEFECT B - linter.style.longFile semantics are documented wrongly where the plan author writes the bump. Condition 7 of plan-authoring-gate-collisions.md states the acceptance window as 'N - 200 <= lines < N'. Two measurements contradict that: a plan step directing 'raise 2900 -> 3400' put a NEW warning into a previously warning-free module at 2967 lines ('The current limit is 3400, but it is expected to be 3100'), and at 3200 lines against a 3200 limit the linter demanded 3400, not 3300. Both are consistent with the linter demanding the file's OWN round-up rather than a forward-looking ceiling, and with a step that is not always +100 (hypothesis to confirm, not to copy: expected = (floor(lines/100) + 2) * 100). Derive the exact rule from the linter's own source for the pinned toolchain (Lean v4.33.0-rc1) rather than from these two data points alone, correct Condition 7, and state the consequence: the baseline is bumped INCREMENTALLY as a file grows across phases, so each phase that moves the file's line count owns its own re-tightening - a single early bump to the final expected value is itself a new warning. Citations: 853:iss_1794302533674_MPP05G, 838:iss_1794300659586_vZ4XxM.

Both defects are plan-authoring guidance in the same two files, which is why they are one task.

PRIOR RECORDS -- decide explicitly, do not silently resurrect or silently skip. Defect A's core face was owned by the record `per_phase_generated_surface_gates_and_batch_defer` (#885, ABANDONED 2026-11-06T06:57:09Z), and the lean prose this task finds unreachable was authored by `lean_plan_gate_collision_authoring_guidance` (#785, COMPLETED). #885's abandonment fell inside a 5-record meta-backlog pruning sweep (#858, #885, #886, #887, #888, all abandoned within 70 seconds) with no per-record reason recorded in state. The class then RECURRED after that pruning with 10 fresh citations across tasks 838 and 853 -- that recurrence, not a disagreement with the pruning, is why it is filed again. If pruning this class was deliberate policy, abandon this record explicitly rather than implementing it. Defect B is new ground: #785 authored Condition 7, and this record corrects it.

EDIT TARGET, binding. Re-derive the source store rather than trusting any path quoted here: `source_dir` lives PER-EXTENSION at `.extensions.<name>.source_dir` in `<project-root>/.claude-extensions.json`, not as a top-level key -- a top-level `jq -r '.source_dir'` returns null and must NOT be read as the key being absent. All seven loaded extensions resolve under /home/benjamin/.config/nvim/agent-system/extensions/<name>. Edit at the path mirroring the deployed one; a hand-authored file under .claude/** is silently wiped by the next regeneration.

NOT a repair of this repository's own gates. `.githooks/pre-commit`, `scripts/typst-sync-check.sh`, `scripts/check-module-invariants.sh`, `scripts/nolint-attribute-allowlist.txt`, `typst/generated/status.typ` and the generated README inventory blocks are correct as they stand; do not edit them. The subject is agent-system guidance and mechanism only.
=== TERMINAL DISPOSITION: ABANDONED HERE, MIGRATED OUT (no work was lost) ===

This record has been relocated, whole and one-for-one, into the repository that owns the shared
agent-system source store, following that repository's own
context/patterns/cross-repo-task-migration.md. The migrated record carries this description
verbatim -- every iss_* citation id, line number and enumerated sub-fault as authored -- plus a
provenance note recording the migration, how its cross-repo citations were made resolvable, and
the disposition of each of its dependency edges.

WHY ABANDONED RATHER THAN EXPANDED, decided rather than defaulted. EXPANDED is for a record
divided into children inside the same task space; no children were created here and no part of
this work remains in this repository. The relocation is a change of owning repository, not a
decomposition, so ABANDONED is the terminal state that fits: this record will never be worked
here, while the work itself is live elsewhere.

WHY IT COULD NOT STAY. Its file_scope names only paths under the shared source store at
~/.config/nvim/agent-system/**. That work cannot be performed or committed from this repository,
and this repository's own .claude/** tree is a gitignored, disposable deploy artifact regenerated
from that store, so an edit made here would be silently wiped by the next regeneration.

WHERE THE WORK WENT (durable anchors, paired with the number as the pointer hazard requires).
Repository: /home/benjamin/.config/nvim (specs/state.json, specs/TODO.md). The migrated record
keeps this record's own project_name slug unchanged, which is the anchor to match on; the number
it was allocated there belongs to that repository's independent numbering space and is unstable
under vault renumbering, so match on the slug first and treat any number as corroboration only.

---

### 911. Idle cycle sharpening idle gap lengthening
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 909
- **Parent**: Task 838
- **Plan**: [911_idle_cycle_sharpening_idle_gap_lengthening/plans/01_idle-cycle-sharpening.md]
- **Summary**: [911_idle_cycle_sharpening_idle_gap_lengthening/summaries/01_idle-cycle-sharpening-summary.md]

**Description**: Pursue the idle-cycle sharpening left open by the idle-gap lengthening decision gate's FAIL verdict: the lengthening is available exactly where the object's idle states carry a reachable cycle, which is an OBJECT hypothesis rather than a consequence of ParamsOk.

VERIFIED STARTING POSITION (compiled refutation, not an unproved conjecture):
(1) The decision gate returned FAIL on sub-question (i), ADMISSIBILITY. IdleGapLengthening is refuted by idleGapLengthening_refuted in prototype/idle-gap-lengthening.lean (namespace Probe838C, standalone, not wired), on the standard axiom profile with no sorryAx.
(2) The obstruction is NOT where it was expected. pinCompat_of_ladderPath does loosen as a region start moves farther from z, exactly as predicted -- but the lengthening is denied one level BELOW the pin condition, by step itself. A ladder path's object walk satisfies step (objAt g v) (objAt g (v+1)) = true at every position, so an idle run of length two requires an idle-to-idle edge in the object's step graph, and an object satisfying ParamsOk need not have one. no_consecutive_idle_of_no_idle_step states this generically.
(3) The witness is the two-state object Qo := Bool with pendO = id and stepO x y = x || y (exactly that edge missing), serial in both directions, at a parameter tuple ParamsOk genuinely admits (the periodicity fixpoint's own outputs, discharged by paramsOk_params).
(4) Sub-question (ii), TYPE PRESERVATION, was NEVER REACHED -- the refutation closes from step alone. It is untouched, not skipped.

SCOPE: identify the object hypothesis (reachable cycle among idle states) under which the lengthening IS available, state it as an explicit premise, and determine what it buys. The idle run's length is a datum of the object, not a parameter a construction may raise -- any statement claiming otherwise is false, not merely weaker.

ORIGIN: conclusion-stage channel (c) of an orchestration run, user-approved. Citation: parent issues.jsonl iss_1794297685402_9saHqw.

---

### 910. Saturated gap branch kappa collision regimes
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 909
- **Parent**: Task 838
- **Plan**: [910_saturated_gap_branch_kappa_collision_regimes/plans/01_saturated-gap-monotone-dispatch.md]
- **Summary**: [910_saturated_gap_branch_kappa_collision_regimes/summaries/01_saturated-gap-monotone-dispatch-summary.md]

**Description**: Dispatch or explicitly exclude the SATURATED-GAP third branch of kappa_collision_regimes, which neither landed cell inclusion addresses in either direction.

VERIFIED STARTING POSITION (compiled, not argued):
(1) kappa_collision_regimes landed with THREE branches (equal register, common shift, saturated gap), not the two its plan anticipated. The two-branch shape is NOT derivable from the three destructors it was to be proved from plus (K4)'s 2 <= B: clipIdx clips the gap coordinate at B, so a collision saturated at that clip on both sides of the window satisfies neither alternative.
(2) The refutation is compiled, not asserted: kappa_collision_two_regimes_refuted at Tc = Tn = P = 0, B = 2 and the pairs (0,2),(0,3).
(3) The residue SURVIVES regime restriction. kappa_collision_two_regimes_refuted_of_pend_gap shows the saturated-gap branch survives restriction to the pending-forever regime at countdowns above the threshold (Tc = Tn = P = 0, B = 2, pairs (2,0) and (4,1)). On that residue no landed inclusion applies in either direction, and the forward-slack hypothesis does not reach it: forward slack buys the deletion inside z's region, while the obstruction is that the register must move by an amount the countdown does not match.

TWO ADMISSIBLE OUTCOMES: either dispatch the branch with a genuine argument, or exclude it from the obligation's hypotheses explicitly and state the exclusion in the signature -- never leave it tacit. The reserved name cellLE_zero_const_of_kappa_eq stays reserved either way.

ORIGIN: conclusion-stage channel (c) of an orchestration run, user-approved. Citation: parent issues.jsonl iss_1794296515751_mFmN7o.

---

### 909. Register lowering deletion drop equal register
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Parent**: Task 838
- **Plan**: [909_register_lowering_deletion_drop_equal_register/plans/01_register-lowering-deletion-common-shift.md]
- **Summary**: [909_register_lowering_deletion_drop_equal_register/summaries/01_register-lowering-deletion-common-shift-summary.md]

**Description**: Construct the register-LOWERING deletion that would drop the equal-register hypothesis n = n' from cellLE_zero_const_of_kappa_eq_of_forwardSlack on branch 2 of the collision case split.

VERIFIED STARTING POSITION (established by compiled objects, not argued):
(1) The landed restricted obligation cellLE_zero_const_of_kappa_eq_of_forwardSlack (FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean) concludes cell EQUALITY via Set.Subset.antisymm, but carries FOUR restrictions, the fourth of which -- the equal-register hypothesis n = n' -- was not anticipated when the obligation was stated. The proof routes through kappa_eq_components rather than kappa_collision_regimes.
(2) The common-shift sub-regime's DOWNWARD direction is the specific blocker: the landed deletion HOLDS the register, and nothing landed LOWERS it. That asymmetry is what forces the n = n' hypothesis.
(3) The forward register cascade is the underlying obstruction. For a <= v the deleted walk's pin v IS the original path's pin v + l, so the bound demanded by exists_ladderPath_of_walk_nxt exceeds what pinCompat_of_ladderPath supplies by exactly l, and by m*(P+1) when iterated. This is not slack a sharper proof recovers: tightChain_slack_zero compiles a tight doubling chain with Lipschitz slack exactly 0 at every gap between pins.
(4) LadderPump.lean carries single-step deletion admissibility (exists_deleted_ladderPath_of_pend_past) and the deletion type lemma (tpOf_eq_delIdx_of_tpOf_eq), but NO iterated deletion and no downward assembly; the single-step lemma fixes the deleted path's register base at nxtAt g (l : Z) rather than prescribing the register at the compared position.

SCOPE: a register-lowering deletion dropping the hypothesis on branch 2 only. It does NOT reach the saturated-gap residue, which a sibling follow-up owns. The reserved name cellLE_zero_const_of_kappa_eq remains reserved and claimed by nothing -- nothing here may land under it.

ORIGIN: conclusion-stage channel (c) of an orchestration run, user-approved. Citations: parent issues.jsonl iss_1793731048423_ByWoAB (suggested_channel follow_up_task, honored) and iss_1794299302902_wvV3dt.

---

### 908. Constraints consumed marker accuracy audit
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: documentation
- **Dependencies**: Task 918
- **Parent**: Task 898
- **Research**: [908_constraints_consumed_marker_accuracy_audit/reports/01_constraints-consumed-marker-audit.md]
- **Plan**: [908_constraints_consumed_marker_accuracy_audit/plans/01_constraints-consumed-marker-corrections.md]
- **Summary**: [908_constraints_consumed_marker_accuracy_audit/summaries/01_constraints-consumed-marker-corrections-summary.md]

**Description**: Audit the 65 remaining "Constraints consumed: Compositionality, Seriality, Limit, Saturation" docstring lines across 16 library modules against what each declaration's proof actually projects, and correct the over-reporting ones.

Background. The completed work on L-plus invariance without Saturation established that such a line records the IsRegular binder PRESENT on a declaration, not the constraints the proof CONSUMES. Four lines in FormalSystem/Semantics/HistoryMorphism.lean and FormalSystem/Semantics/UniversalCover.lean over-reported in exactly that way and were corrected there; that over-claim is why the Saturation question looked open for as long as it did. Measurement found the residue is larger than first estimated: 65 occurrences across 16 files (FormalSystem/Semantics/Nomic/, Presheaf/, Extension/, Validity.lean, Correspondence/RigidityReal.lean, NomicLanguage/), not the ~20 initially reported. Correcting them was declared an explicit Non-Goal of that work, so the residue is unfiled.

Scope. For each occurrence, determine which constraints the proof actually projects -- the transplant-probe technique is proven: replace the bundling binder with explicit constraint hypotheses in a scratch copy and check it still compiles. Then correct the marker line where it over-reports. Many occurrences will be ACCURATE: a declaration that genuinely consumes Saturation keeps its line unchanged. This is an audit, not a sweep; a blind rewrite would be worse than the current state.

Constraints to respect. The "Constraints consumed:" marker vocabulary is CLOSED (check-module-invariants.sh C34), and a side-attributing form such as "source: ...; base: none" is inadmissible on the marker line. Any phase touching a marker must name scripts/check-module-invariants.sh in its own verification tier -- a full lake build covers none of C34/C34a/C34b. typst/generated/status.typ is a mandatory file_scope member of any .lean-touching phase (typst-sync-check.sh pre-commit gate).

Evidence anchor. specs/evidence/history-morphism-saturation-audit/ holds the two compiled transplant probes from the originating work.

---

### 907. Redeploy-stale-claude-tree
- **Effort**: small
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: agent-system
- **Dependencies**: None
- **Parent**: Task 901

**Description**: Regenerate the deployed .claude/ tree in BimodalLogic, which two dispatches reported stale relative to the source store for six extensions (core, formal, lean, literature, memory, typst). Run deploy-headless.sh under the bounded-wait idiom (timeout 540, Bash tool timeout parameter 600000, per context/patterns/external-process-wait.md Rule 1), then verify with verify-deploy.sh and confirm the per-extension staleness warning from skill-base.sh no longer fires. Never hand-patch a deployed .claude/** file to clear the warning: that masks the divergence instead of fixing it. Neither reporting dispatch relied on a stale deployed command, so no prior work needs redoing. Recurrence of the condition addressed by closed task 715.

---

### 906. Settle whether LCU is derivable from TM-plus + LC_n at ZTime via a non-ZTime separating model
- **Status**: [IMPLEMENTING]
- **Task Type**: formal
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [906_lcu_derivability_from_lcn_non_ztime_separating_model/reports/01_lcu-lcn-separating-model.md]
- **Plan**: [906_lcu_derivability_from_lcn_non_ztime_separating_model/plans/01_lcu-lcn-separating-model.md]
- **Handoff**: [906_lcu_derivability_from_lcn_non_ztime_separating_model/handoffs/phase-2-handoff-20261112T053703Z.md]

**Description**: RESEARCH TASK, report only. Deliverable: either a derivation of lcU alpha beta in TM-plus + LC_n + mirror LC_n for state-local beta, or a non-ZTime separating model. A ZTime countermodel cannot settle this question -- both lcN_plusValidZTime and lcU_plusValidZTime are compiled, so the two systems have the same ZTime models -- so the first target is .Base, where both schemata's validity is open and unclaimed per FormalSystem/PlusLanguage/PlusLCSchema.lean's own docstring, for a separating general frame or algebra. No Lean work beyond what is needed to state the separating model or derivation at the report level; no completeness claim.

---

### 905. Eliminate cross-certification between the forward and backward Rabin automata, or show it is load-bearing
- **Status**: [COMPLETED]
- **Task Type**: formal
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [905_eliminate_cross_certification_two_sided_reynolds_automata/reports/01_eliminate-cross-certification-clauses.md]
- **Plan**: [905_eliminate_cross_certification_two_sided_reynolds_automata/plans/01_eliminate-cross-certification-clauses.md]
- **Handoff**: [905_eliminate_cross_certification_two_sided_reynolds_automata/handoffs/phase-4-handoff-20261112T034500Z.md]
- **Summary**: [905_eliminate_cross_certification_two_sided_reynolds_automata/summaries/01_eliminate-cross-certification-clauses-summary.md]

**Description**: RESEARCH TASK, report only. Deliverable: an answer, with its argument, to whether the clause-(a) cross-certification of specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md's Finding 5.2/14.4 is eliminable -- either a proof that the certification is automatic from the chronicle clauses of that report's Finding 8.2, or a demonstration that it is load-bearing, or a bi-infinite-automaton alternative with its cost. The question is answerable against the chronicle clauses and the two clause (a)s alone, strictly cheaper than anything in that report's Finding 17; eliminating the clauses would remove one omega-regularity argument from each automaton and shrink the alphabet's enlargement. No Lean work; no completeness claim.

---

### 904. Record three method lessons in the source store: proof_wanted as a trust surface, the external-library dependency-assessment checklist, and ground-overturned-outcome-preserved verdict amendments
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Dependencies**: None
- **Research**: [904_proof_wanted_trust_surface_and_external_library_dependency_assessment/reports/01_proof-wanted-trust-surface-and-dependency-assessment-lessons.md]
- **Plan**: [904_proof_wanted_trust_surface_and_external_library_dependency_assessment/plans/01_register-and-verify-method-lessons.md]

**Description**: META TASK. File three method lessons measured in specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md (its Context Extension Recommendations section). All three MUST be authored in the source store resolved from .claude-extensions.json's source_dir, never hand-authored under .claude/**, per rules/source-store-deploy-boundary.md.

LESSON 1 - proof_wanted is a trust surface distinct from sorry. proof_wanted ELABORATES AND DISCARDS, so a zero sorry count and a clean #print axioms are BOTH blind to it. The 902 session found five named-but-absent theorems this way (two in the CSLib fork's DA/Conversions.lean, three in NA/BuchiCompl.lean at lines 293, 321, 328) in a tree whose own dispatch described it as 'all reported sorry-free'. Add a proof_wanted subsection to metadata-trust-surfaces.md naming grep -c '^proof_wanted' as the only reliable detector, and stating that a module consisting entirely of proof_wanted declares nothing. The archived CSLib omega-automata survey raised this same recommendation and it remains unimplemented.

LESSON 2 - a checklist for assessing an external Lean library as a candidate dependency, in a new pattern file. Read upstream claims through 'git show upstream/main:<path>' rather than a fork worktree (this is how the prod_run_eq misattribution surfaced); measure 'git rev-list --left-right --count' in BOTH directions (this is how a 235-commit lag behind upstream surfaced under a '4717 commits ahead' description); compare lean-toolchain BEFORE Mathlib revisions (this inverted the cost ordering between two candidate dependencies); verify a build cache post-dates its sources before trusting #print axioms; and compute the IMPORT CLOSURE of the target modules rather than the repository's line count (8,526 lines versus 244,339 - a 29x difference in the honest number).

LESSON 3 - 'ground overturned, outcome preserved' as a distinct kind of verdict amendment. A prior verdict can be correct in outcome and wrong in its stated reason; the correct amendment preserves the outcome, replaces the reason, and says so explicitly, so that a later reader is not misled into thinking a NO-GO was lifted. Nothing in context/standards/ currently names this pattern. A short subsection in the report-format or status-markers standard.

NON-GOALS. No hand-authored file under .claude/**; no redeploy claimed by this task; no change under FormalSystem/ or Tests/.

---

### 903. Settle whether a deterministic Muller automaton suffices for the Auxiliary-Atoms rule and the ban/lull mechanism at ZTime, or whether Rabin or parity is genuinely needed
- **Status**: [COMPLETED]
- **Task Type**: formal
- **Dependencies**: None
- **Research**: [903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md]
- **Plan**: [903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/plans/01_muller-sufficiency-aa-rule-ban-lull.md]
- **Summary**: [903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/summaries/01_muller-sufficiency-aa-rule-ban-lull-summary.md]

**Description**: PAPER QUESTION, no Lean work. The L-plus ZTime completeness architecture (see specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md) specifies a deterministic RABIN or PARITY automaton for the violation language, and the re-assessment in specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md identifies that choice as obstruction component (O1) and as the cheapest open question in the whole assessment. Decide, on paper, whether a deterministic MULLER automaton suffices for the Auxiliary-Atoms rule and for the ban/lull mechanism at ZTime.

WHAT MAKES IT ANSWERABLE WITHOUT LEAN WORK. The architecture's actual requirement on the automaton is literally 'deterministic', because the AA rule records a run as a function of the path prefix (what coneSt and Reynolds' Lemma 13/26 use). Muller acceptance is as expressible by state-valued fresh atoms as Rabin's is: 'infOcc in accept' is a finite disjunction over F in accept of (conjunction over b in F of GF b) and (conjunction over b not in F of FG not-b). So the Rabin/parity requirement may be a presentational preference rather than a real need. Settling it needs Reynolds' Lemma 13/26 and the ban/lull mechanism read against that expressibility fact, and nothing else.

THE STAKE. If Muller suffices, the local CSLib fork's already-proved, sorry-free IsRegular.iff_da_muller IS the determinization the architecture needs and (O1) vanishes, which makes the CSLib dependency question live rather than hypothetical. If Rabin is genuinely needed, Muller.toRabin_exists (fork DA/Conversions.lean:112, proof_wanted) becomes the single highest-value gap in either CSLib tree.

NON-GOALS. No Lean source, no change under FormalSystem/ or Tests/, no require on CSLib, no completeness claim. This task answers one acceptance-condition question and reports.

---

### 902. Reassess lplus ztime nogo cslib omega automata
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md]
- **Plan**: [902_reassess_lplus_ztime_nogo_cslib_omega_automata/plans/01_cslib-omega-automata-nogo-reassessment.md]
- **Summary**: [902_reassess_lplus_ztime_nogo_cslib_omega_automata/summaries/01_cslib-omega-automata-nogo-reassessment-summary.md]

**Description**: RESEARCH TASK: re-assess the L-plus ZTime completeness NO-GO against CSLib's deterministic omega-automata inventory, including the local fork. Report only; no change under `FormalSystem/` or `Tests/`, and no `require` edit to `lakefile.toml` as part of this task.

WHY THIS EXISTS. The completeness-programme report `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` returned NO-GO on any Lean completeness proof today, on the stated ground that deterministic omega-automata are "absent from Mathlib", placed in the same class as the MSO refusal. That ground is correct about Mathlib and incomplete as a search: the material lives in CSLib, which the report did not consult. A direct inspection (2026-11-09) establishes the following, and this task must re-verify every claim below against the trees rather than trusting this note.

WHAT IS UPSTREAM (`leanprover/cslib`, head `1e285fd14`). `DA` with `run`/`run'` over `ωSequence`, and `DA.Buchi` and `DA.Muller`, each with an `ωAcceptor` instance, all in `Cslib/Computability/Automata/DA/Basic.lean` (`DA` at line 37, `Buchi` at 91, `Muller` at 106); `DA.prod` with `prod_run_eq` in `DA/Prod.lean`; Buchi complementation and the `IsRegular` closure lattice (`sup`, `inf`, `iSup`, `iInf`, `hmul`, `omegaPow`, `compl`) in `Cslib/Computability/Languages/OmegaRegularLanguage.lean`; the `OmegaSequence` infrastructure (`InfOcc`, `Flatten`, `Init`, `Temporal`, `Topology`) under `Cslib/Foundations/Data/OmegaSequence/`. Upstream genuinely lacks McNaughton determinization, which is a `proof_wanted` at `OmegaRegularLanguage.lean:261` (`IsRegular.iff_da_muller`), and has no Rabin, Streett or Parity.

WHAT THE LOCAL FORK ADDS (`benbrastmckie/cslib`, ~4717 commits ahead of upstream, checkout at `~/Projects/cslib`), all reported sorry-free. `DA/Rabin.lean`: `Rabin` and `Streett` with `ωAcceptor` instances plus `Buchi.toRabin`, `Rabin.toMuller`, `Rabin.toStreett`, `Streett.toRabin`, each with a `_language_eq` correctness theorem. `DA/Parity.lean`: `Parity` with `Parity.toRabin_language_eq`. `DA/Choueka.lean`: the Choueka language, `chouekaLang_regular`, `chouekaLang_omega_power_eq_omega_limit`. `DA/MullerClosure.lean`: DMA finite-union closure via the product automaton. And `IsRegular.iff_da_muller` PROVED, both directions, the forward one by the Choueka route ported from `ctchou/AutomataTheory`. Also fork-only: `DA/Concat.lean`, `DA/Conversions.lean`, `DA/BuchiChar.lean`, `DA/BuchiClosure.lean`, `NA/BuchiCompl.lean`, `NA/Emptiness.lean`. The separate `~/Projects/cslib-pr648` checkout is on `rebase/pr648-upstream` and carries only the upstream DA set, so it is not a source of this material.

WHAT TO DELIVER.
(1) A verified inventory table: for each ingredient the completeness architecture needs, whether it is landed upstream, landed fork-only, or genuinely missing. Re-derive every row from the trees; cite file and declaration name, and give the measured axiom profile of any declaration the architecture would depend on.
(2) The decisive open question this task exists to settle: does the fork have the FULL-PRODUCT / PASTING lemma the architecture consumes at its single separation-consumption point (the state-level initialisation of the two clock-anchored product automata from the cut colour's type sets)? `DA.prod` plus `prod_run_eq` is strictly weaker than what that step needs. If the lemma is absent, state precisely what is missing and what it would cost.
(3) A revised verdict on the Lean route for T3 (TM-plus + until-form LCU + mirror + rules), replacing the NO-GO in the report named above. A located obstruction, stated precisely, is a complete outcome; so is an overturn.
(4) A dependency-cost assessment, stated as a recommendation and not acted on: CSLib is NOT currently a dependency of this project (`lake-manifest.json` lists only mathlib, batteries, aesop, Qq, proofwidgets, Cli, plausible, LeanSearchClient, importGraph). Consuming the fork-only material means a `require` on a fork that is ~4717 commits ahead of an upstream that has not reviewed it, with a real and recurring sync cost; consuming only upstream material avoids that but leaves determinization unavailable. Assess both, and whether the fork-only modules are candidates for upstreaming instead.

SCOPE AND NON-GOALS. ZTime only. No change under `FormalSystem/` or `Tests/`; no edit to `lakefile.toml` or `lake-manifest.json`; no completeness claim lands from this task. Do not re-derive the architecture itself, which the report already gives: this task re-tests exactly one premise of its verdict.

PRIOR ART TO READ FIRST. The backlog audit surfaced a closed CSLib omega-automata survey whose close-out record is `specs/736_cslib_omega_automata_survey_and_e3_reopen_check/summaries/01_cslib-omega-automata-survey-summary.md`; its summary names a six-item operator hand-off list of findings deliberately not acted on. Read that summary and its hand-off list before starting, and state explicitly which of this task's deliverables it already discharges and which it does not. It is prior art, not a blocker: it predates the completeness-programme report's NO-GO and does not address the pasting-lemma question in deliverable (2).

---

### 901. Paper proof of the two-sided Reynolds engine for L-plus at ZTime: ban preservation, fair scheduling, universal non-acceptance, truth lemma
- **Status**: [COMPLETED]
- **Task Type**: formal
- **Dependencies**: Task 893, Task 903
- **Research**: [901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md]
- **Plan**: [901_two_sided_reynolds_engine_paper_proof/plans/01_two-sided-reynolds-engine-paper-proof.md]
- **Summary**: [901_two_sided_reynolds_engine_paper_proof/summaries/01_two-sided-reynolds-engine-paper-proof-summary.md]

**Description**: RESEARCH TASK, report only. Write out, at the level of rigour of Reynolds 2001 sections 9-15, the two-sided transposition of the CTL* completeness engine to L-plus over Z-time for the system TM-plus + LCU + mirror LCU + clock rule + forward and backward Auxiliary-Atoms rules: the closure sets with the separated CNF of every closure formula; hues, colours and the state formula of a colour; the two deterministic Rabin automata over colour words, the forward one indexed by the set of past-types realized at the cut colour and the backward one by the set of future-types, with the violation language defined through the separated CNF; the consistency lemma for phi-plus via the linear bridge and the three rules; the two-sided chronicle with alternating future and past defect curing, pioneers and lulls in both directions; the ban-preservation lemma consuming LCU and its mirror; universal non-acceptance along every bi-infinite walk of the limit quotient; the truth lemma including the stab case for emergent walks; and the final-frame step through the universal cover. Record, as located questions, whether LCU is derivable from TM-plus + LC_n at ZTime and whether the three naming rules are admissible in the rule-free system. Inherit as a settled premise, not as an open question, the split verdict of `specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md`: a deterministic Muller automaton suffices for the Auxiliary-Atoms rule -- the rule's antecedent, Reynolds' `theta_A`, carries no acceptance condition at all, so determinism is the whole demand the rule makes on the automaton -- but does not suffice for the ban/lull mechanism, whose chronicle indexes `bl` by the number of accepting pairs of the automaton; a two-state counterexample (`Q = {a,b}`, with Muller family `{{a,b}}`) shows that enumerating pairs over a Muller family is unsound, not merely incomplete, so the determinization state-space blowup is unavoidable and the write-up may name deterministic Rabin automata without hedging. Note that a Lean formalization of this proof is blocked on a relocated obstruction with three live named components, not on absence from Mathlib or from either CSLib tree -- see `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md`: (O1) determinization to a deterministic Rabin automaton is unproved everywhere -- the local fork's `Muller.toRabin_exists` is a `proof_wanted`, and it is the single remaining determinization gap, `Rabin.toParity_exists` being off the critical path because `Parity.toRabin_language_eq` is already proved and the ban mechanism consumes Rabin rather than parity; (O3) every determinization result arrives as an existential over `Type`, not as the syntax the Auxiliary-Atoms rule needs to name the automaton in fresh state-valued atoms; and (O4) the rest of the paper proof -- consistency of phi-plus, ban preservation, universal non-acceptance, fair scheduling, the two-sided truth lemma -- is untouched by any of this. The component labels are kept as the 902 report numbers them, because the fourth member of the earlier count, (O2) the indexed conjunctive product automaton with a nameable initial state, is now discharged rather than merely deprioritized: taking the cut product as a finite indexed union on the Muller side and determinizing once afterwards puts it inside the already-proved `Muller.exists_iSup`, so none of the Rabin-side product or closure code it was costed at is needed. A Lean formalization is not to be filed until this located obstruction is resolved.

---

### 900. Bridge: ZTime-valid L formulas yield TM-plus theorems under PlusFormula substitution
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 899
- **Research**: [900_linear_ztime_validity_tm_plus_substitution_bridge/reports/01_ztime-validity-tm-plus-substitution-bridge.md]
- **Handoff**: [900_linear_ztime_validity_tm_plus_substitution_bridge/handoffs/phase-3-handoff-20261111-201754.md]
- **Plan**: [900_linear_ztime_validity_tm_plus_substitution_bridge/plans/01_ztime-validity-substitution-bridge.md]
- **Summary**: [900_linear_ztime_validity_tm_plus_substitution_bridge/summaries/01_ztime-validity-substitution-bridge-summary.md]

**Description**: A two-step bridge lemma in FormalSystem/PlusLanguage/Substitution.lean: for an L formula valid at FrameClass.ZTime, every substitution instance substPlus sigma of it is PlusDerivable FrameClass.ZTime [], by completeness_ztime followed by PlusDerivationTree.ofTMSubst; plus the corollary for box-free formulas that a formula valid on every bi-infinite Z-word (the linear fragment) yields TM-plus theorems at every substitution. This is the transposition of Reynolds 2001's use of PLTL completeness inside the CTL* proof (Lemma 7, Claims 1-2, Lemma 17, Lemma 23): the automaton-correctness and fair-scheduling facts are linear validities over Z-words with stab-headed formulas and fresh atoms as sentence letters, derived in TM-plus through this bridge.

---

### 899. The stability cluster's (past-type, future-type) set is a full product
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [899_stability_cluster_type_product_lemma/reports/01_stability-cluster-type-product.md]
- **Plan**: [899_stability_cluster_type_product_lemma/plans/01_stability-cluster-type-product.md]
- **Source**: [FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean]
- **Documentation**: [docs/theorem-index.md]
- **Summary**: [899_stability_cluster_type_product_lemma/summaries/01_stability-cluster-type-product-summary.md]

**Description**: In FormalSystem/PlusLanguage/PlusPasting.lean, for a regular frame, a model, a history tau, a time t and a finite list of past-determined and future-determined formulas, prove that the set of pairs (past-type, future-type) realized by histories through tau.state t at t equals the product of the set of realized past-types and the set of realized future-types, by paste with paste_agreeUpTo, paste_agreeFrom and the semantic PastDet/FutDet predicates of OpenFutureElimination.lean. This is the lemma that makes the initialization of the forward and backward Auxiliary-Atoms automata at the clock cut a state-level datum, and it is the exact point at which separationOver_ztime is consumed by the completeness architecture.

---

### 898. Two-way bounded L-plus invariance over ZTime with no Saturation hypothesis on the base frame
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Dependencies**: None
- **Research**: [898_plus_invariance_base_without_saturation/reports/01_plus-invariance-base-without-saturation.md]
- **Plan**: [898_plus_invariance_base_without_saturation/plans/01_plus-invariance-base-without-saturation.md]
- **Summary**: [898_plus_invariance_base_without_saturation/summaries/01_plus-invariance-base-without-saturation-summary.md]

**Description**: plus_invariance_of_isZTime and exists_histMorphism_of_isZTime in FormalSystem/Semantics/HistoryMorphism.lean take [F.IsRegular] on the base frame F, which bundles Saturation. Determine whether Saturation of the base is consumed anywhere in the lifting chain (bwdSeq_spec, chain_spec, chain_step, chain_rel, exists_preimage_step_neg) and, if not, restate the chain over a base carrying only reflection, Compositionality, Seriality and Limit, so that truth transfers from a non-saturated doubly serial digraph over Z to its universal cover. The completeness programme needs exactly this direction: the canonical quotient digraph of the Reynolds-style construction has infinite fibres and is not known saturated, and the countermodel of record is its cover. If Saturation turns out essential, record the exact step and the obstruction instead.

---

### 897. Universal cover of a doubly serial digraph: oriented forest, surjective two-way bounded covering map
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Dependencies**: None
- **Research**: [897_universal_cover_oriented_forest_two_way_bounded/reports/01_universal-cover-oriented-forest.md]
- **Plan**: [897_universal_cover_oriented_forest_two_way_bounded/plans/01_universal-cover-oriented-forest.md]
- **Summary**: [897_universal_cover_oriented_forest_two_way_bounded/summaries/01_universal-cover-oriented-forest-summary.md]

**Description**: The second half of ROADMAP hypothesis (H5), left unowned when the oriented-forest Saturation lemma landed: for a doubly serial one-step relation E on W, construct the cover relation on reduced walks (components taken as orientation-keeping undirected multigraphs, so an opposite-edge pair lifts to two distinct edges and a loop to a ray), prove IsOrientedForest for it, doubly serial, and that the endpoint projection is surjective and TwoWayBounded for the induced ofStepRel frames, so that saturation_of_orientedForest makes the cover a regular ZTime frame and plus_invariance_of_isZTime transfers L-plus truth. Mathlib's Combinatorics/Quiver/Covering.lean is the recorded starting point. Two consumers: the decidability paper proof's cover step (reports 03 section 1.2 and 878 finding 1) and the completeness programme's final-frame step, where the canonical quotient digraph is not known to satisfy Saturation and is replaced by its cover. New module FormalSystem/Semantics/UniversalCover.lean.

---

### 896. The extended L-plus proof system (TM-plus + axiom set + naming rules) with its ZTime soundness, and the completeness targets as stated Props
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 895
- **Research**: [896_lplus_extended_proof_system_and_target_statement/reports/01_lplus-extended-proof-system.md]
- **Plan**: [896_lplus_extended_proof_system_and_target_statement/plans/01_lplus-extended-proof-system.md]
- **Summary**: [896_lplus_extended_proof_system_and_target_statement/summaries/01_lplus-extended-proof-system-summary.md]

**Description**: A new module FormalSystem/Metalogic/LCExtension.lean carrying: RuleSet (flags clock, aaFwd, aaBwd); ExtDerivation (fc) (Ax : PlusFormula -> Prop) (R : RuleSet) : PlusFormula -> Prop, a Prop-valued theoremhood closure whose base is PlusDerivable fc [] and whose constructors are Ax, modus ponens, necessitation, temporal necessitation, time reflection, and the three naming rules gated by R with their freshness side conditions; IsLCAxiom (lcN n alpha and its reflectTime, n >= 1) and IsLCUAxiom (lcU and its mirror); the soundness theorem ext_sound_ztime : ExtDerivation .ZTime Ax R phi -> PlusValidZTime phi under the hypothesis that Ax is ZTime-valid, assembled from plus_soundness_ztime, clock_irr_sound and the Auxiliary-Atoms soundness; and the completeness targets stated as Prop definitions with no proof and no sorry: LCComplete (RuleSet.none, IsLCAxiom), LCRulesComplete (RuleSet.all, IsLCAxiom), LCURulesComplete (RuleSet.all, IsLCUAxiom). PlusDerivationTree, PlusAxiom and PlusFormula are not modified (standing ruling). Depends on the Auxiliary-Atoms rule task for the soundness arm; the statements themselves can land first with the soundness arm parametric in a rule-soundness hypothesis.

---

### 895. The Auxiliary-Atoms rule for L-plus at ZTime, forward and mirror, formula level with soundness
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 894, Task 915
- **Research**: [895_auxiliary_atoms_rule_soundness_ztime/reports/01_auxiliary-atoms-rule-soundness.md]
- **Plan**: [895_auxiliary_atoms_rule_soundness_ztime/plans/01_auxiliary-atoms-rule-soundness.md]
- **Summary**: [895_auxiliary_atoms_rule_soundness_ztime/summaries/01_auxiliary-atoms-rule-soundness-summary.md]

**Description**: State the transposed Reynolds-2001 Auxiliary-Atoms rule at the formula level and prove it validity-preserving at FrameClass.ZTime. Antecedent aaAnte b0 Q a p := b0 and stab (gle (bigAnd over b in Q, i < k of ((b and a i) -> stab (next (p b i))))) and stab (gle (bigAnd over b != b' of not (b and b'))), where Q is a finite set of fresh atoms, a i are state-local formulas (PlusFormula.StateLocal) that are provably pairwise inconsistent and jointly exhaustive, and p : Q -> Fin k -> Q is the machine. The rule: if (aaAnte b0 Q a p).imp phi is ZTime-valid and no Q-atom occurs in phi or in any a i, then phi is ZTime-valid. The proof runs the premise on the cone unravelling of the given frame with the machine-run valuation coneSt (semantic core: the archived probe's aa_expand), forgets Q by plusTruthAt_congr_of_fresh, and projects by plus_invariance_of_isZTime. The mirror rule follows by plusValidIn_reflectTime-style reflection of the construction or by a mirrored cone. Depends on the cone-unravelling frame task. Home: FormalSystem/Metalogic/NamingRules.lean or a sibling FormalSystem/Metalogic/AuxiliaryAtoms.lean. No completeness claim.

---

### 894. The forward-cone unravelling as a regular ZTime frame: inr-layer oriented forest and the two-layer Saturation split
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [894_cone_unravelling_frame_layer_split_saturation/reports/01_cone-unravelling-frame-layer-split.md]
- **Plan**: [894_cone_unravelling_frame_layer_split_saturation/plans/01_cone-unravelling-frame-layer-split.md]
- **Summary**: [894_cone_unravelling_frame_layer_split_saturation/summaries/02_cone-unravelling-frame-layer-split-summary.md]

**Description**: Land the Auxiliary-Atoms carrier as a FrameOver intOrder over the sum type W + (W x List W) with the one-step relation coneR (inl u -> inl v and inl u -> inr (v, h) when u -> v; inr (u, h) -> inr (v, u :: h) when u -> v; nothing leaves inr), for a doubly serial base relation. Three lemmas: (1) the inr layer is an IsOrientedForest (every inr node has a unique inr-predecessor and the recorded list strictly lengthens along edges, so the undirected multigraph is acyclic, loop-free and opposite-edge-free); (2) the two-layer Saturation lemma: TaskFrame.Saturation (ofStepRel coneR) from TaskFrame.Saturation of the base relation on the inl-anchored families and saturation_of_orientedForest' on the inr-anchored families, with the mixed-family case handled by directedness; (3) TwoWayBounded for the projection coneF with surjectivity, so plus_invariance_of_isZTime applies. This discharges the Saturation obligation recorded in NamingRules.lean's module docstring and is the frame-side prerequisite of the formula-level Auxiliary-Atoms rule. New module FormalSystem/Semantics/ConeUnravelling.lean.

---

### 893. Declare the until-form limit-closure schema LCU and its mirror, with ZTime validity
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Dependencies**: None
- **Research**: [893_lcu_until_form_schema_ztime_validity/reports/01_lcu-until-form-ztime-validity.md]
- **Plan**: [893_lcu_until_form_schema_ztime_validity/plans/01_lcu-until-form-ztime-validity.md]
- **Summary**: [893_lcu_until_form_schema_ztime_validity/summaries/01_lcu-until-form-ztime-validity-summary.md]

**Description**: Declare lcU (alpha beta : PlusFormula) : PlusFormula := stab (gle ((dstab alpha).imp (dstab (untl (dstab beta) (dstab alpha))))) imp ((dstab alpha).imp (dstab (gle ((dstab alpha).or (untl (dstab beta) (dstab alpha)))))) in FormalSystem/PlusLanguage/PlusLCSchema.lean beside lcN, prove lcU_plusValidInt and lcU_plusValidZTime by instantiating omega_chain with A k := dstab alpha at the markers and the segment property P k eta s s' := dstab beta throughout (s, s'] (the hook restored by the omega_chain repair), and state the backward schema lcU_reflectTime_plusValidZTime as the plusValidIn_reflectTime corollary. This is the limit-closure principle the Reynolds-2001 ban-preservation lemma consumes for the L-plus language with untl and snce primitive; lcN is the F-form and does not discharge the segment guard. Add the docs/theorem-index.md rows and the C14 pins. No completeness claim.

---

### 890. Ghr lemma 10 2 3 case5 erratum reference manual
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: typst
- **Topic**: metalogic
- **Dependencies**: None
- **Parent**: Task 867

**Description**: Record the GHR94 Lemma 10.2.3 Case 5 erratum in the Typst reference manual.

GHR94's printed Case 5 formula for Lemma 10.2.3 is refuted over integer time by an explicit counterexample: a(0), A(1), B identically false, q(1)=q(2). The LHS is true at t=3 while the RHS is false, because both printed disjuncts carry the conjunct [A or (B and U(A,B))] evaluated at t. The refutation was verified against the ch10 PDF layout, not only the markdown chunk -- the PDF carries the same conjunct on the second disjunct, so the defect is in the printed source and not an artifact of conversion.

The corrected rederivation is already landed in Lean. What is missing is the durable write-up: the erratum and its counterexample currently exist only in a task artifact under specs/, which is not where this repository keeps its account of the GHR material. The reference manual is.

Scope: state the printed formula, state the counterexample with its valuation, show which conjunct fails and why integer time (as against the dense time GHR assume) is what exposes it, and point at the landed corrected form. No Lean work -- the mathematics is done.

Evidence: originating issue entry iss_1793912463353_yZ5rLd, recorded during the formalization of GHR separation over Z-time.

---

### 879. Own the L-plus ZTime completeness programme for TM-plus with the limit-closure schema
- **Status**: [COMPLETED]
- **Task Type**: formal
- **Topic**: completeness
- **Dependencies**: Task 870, Task 871, Task 867
- **Research**: [879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md]
- **Plan**: [879_lplus_ztime_completeness_tm_plus_lc_programme/plans/01_lplus-ztime-completeness-programme.md]
- **Summary**: [879_lplus_ztime_completeness_tm_plus_lc_programme/summaries/01_lplus-ztime-completeness-programme-summary.md]

**Description**: RESEARCH TASK, and the owner of a programme that again has no owner: is TM-plus extended by the limit-closure schema LC_n complete for L-plus validity at ZTime? Report only; no change under `FormalSystem/` or `Tests/`.

WHY THIS EXISTS. The aim of the repository is completeness and decidability of the stability-modal language L-plus (specs/ROADMAP.md). Task 559 completed as a narrowed task (the naming-rule soundness toolkit only) and task 865 completed as research with two corrective successors, 870 and 871, and no successor owning the completeness question itself. The standing facts: TM-plus is incomplete at Base (`plus_incomplete_base`); LC_n is valid at ZTime for every n >= 1 (`lcN_plusValidZTime`); completeness of any recursive extension of TM-plus is open at every frame class.

WHAT IS ALREADY ESTABLISHED AND MUST NOT BE REDONE. specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md: a doubled (two one-sided, clock-anchored) automaton pair is sufficient in shape, conditional on `SeparationOver TaskFrame.IsZTime` (task 867); the binding obstruction is the Auxiliary-Atoms carrier, proved intrinsic, so the two-layer shape of `coneR` and its Saturation obligation are forced; a layer-split route to that obligation is given whose one missing ingredient is oriented-forest Saturation (task 870). From task 559's record: the binding obstruction on the completeness front is closedness of the canonical bundle, and the cure of record is LC_n plus progress measures in the state. Re-verify every declaration name against the tree before citing it.

WHAT TO DELIVER.
(1) The target theorem as a precise statement: weak completeness at ZTime of TM-plus together with the LC_n schema (and backward LC_n, which task 871 states as a corollary), written as a Lean proposition that is stated and not proved.
(2) The proof architecture end to end: canonical-bundle closedness from LC_n with progress measures; the doubled Auxiliary-Atoms rule over the layer-split carrier; and the exact point at which separation is consumed.
(3) An ingredient table: each lemma the architecture needs, marked landed, owned by a named task, or missing. File each missing ingredient as its own implementation task through the backlog audit.
(4) A go/no-go verdict. A located obstruction, stated precisely, is a complete outcome.

SEQUENCING AND SCOPE. The standing ruling is decidability before completeness: if the ZTime decidability paper proof lands, Craig gives a recursive axiomatization at the level of existence and this question sharpens to whether the natural one works. ZTime only; Base, Dense and RTime are out of scope. L^▷ is out of scope: at ZTime and RTime its completeness transfers from L-plus through the landed conditional corollaries, and it is a secondary line of investigation.

---

### 876. Open language stability primitive removal
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: syntax
- **Dependencies**: Task 856, Task 873

**Description**: PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the repository is now completeness and decidability of the stability-modal language L-plus; L^▷ is a secondary line of investigation, kept and not abandoned. This task belongs to the L^▷ exploration stage of specs/ROADMAP.md, off both critical paths: do not dispatch it ahead of, or batch it with, L-plus critical-path work. Its content below stands except where this paragraph says otherwise. SCOPE REVISED: DECISION RECORD ONLY. No removal is to be attempted, and no constructor of `OpenFormula` is to be deleted or re-expressed as notation: the stability modal stays primitive in both L-plus and L^▷. The deliverable is the Phase 1 gate alone, as a report: (1) whether any live consumer evaluates the stability modal off the regular class, where the backward half of the definability biconditional fails; (2) what losing state-locality would cost the decidability front and the atomization route; (3) a verdict on whether removal would be sound relative to this tree, recorded for a future ruling and not acted on. Every sentence below that names removal as a deliverable is superseded by this paragraph. Dependencies are reduced to the L^▷ proof-system task alone.

IMPLEMENTATION TASK WITH A DECISION GATE IN PHASE 1, and the gate is the point: remove the stability modal from `OpenFormula`'s primitive constructors, replacing it with notation for the open-past-of-open-future composite, OR record with compiled evidence why it cannot be removed. Entering this task committed to removal is the way to get it wrong; the removal is desired and must be attempted, but two specific obstructions are on record and the task is accountable to them.

THE REQUEST. The stability modal is definable in L^▷ -- the biconditional is landed, in both associations -- so carrying it as a tenth primitive constructor is redundant, and the maintainer's standing preference is that it go. This task owns that removal.

THE TWO OBSTRUCTIONS, BOTH ON RECORD AND NEITHER A GUESS. Read both before planning.
(1) THE BICONDITIONAL IS CLASS-RESTRICTED. The forward half holds on every regular task frame; the backward half needs `[F.IsRegular]`. So a syntactic abbreviation does not preserve the stability modal's truth conditions off the regular class -- it changes the language's meaning on exactly the frames where the two differ. Establish FIRST, as Phase 1's deliverable, whether any live consumer evaluates the stability modal off the regular class. If none does, removal is sound relative to this tree and the restriction is a documented precondition rather than a blocker. If one does, removal is refused on this ground and the task's outcome is that finding.
(2) STATE-LOCALITY IS LOST. The decidability front's one working anchor for the stability modal is that it is state-local -- one bit per cell, `stab_mem_tpOf_iff_cell` resting on `stab_state_only`. The open-future and open-past modals are not state-local; they quantify over agreement classes through the time of evaluation. Routing the stability modal through them discards that anchor. Phase 1 must measure what actually depends on it: enumerate the consumers of `stab_state_only`, `stab_mem_tpOf_iff_cell` and the cell-level stability reasoning, and say for each whether it is reachable from `OpenFormula` at all or lives purely on the other language's side of the embedding. The two languages are separate inductives, so a consumer that only ever sees the other language's stability constructor is NOT affected by removing this one -- establishing that is the cheapest possible route to a clean removal, and it may well be the actual situation. Do not assume it; measure it.

WHAT REMOVAL MEANS IF PHASE 1 CLEARS IT. Delete the stability constructor from `OpenFormula`; introduce the stability modal as notation or an abbreviation over the open-past and open-future composite; re-derive every landed stability result at `OpenFormula` from the composite form, including the pointwise S5 laws, the strength ordering, the reversal transport (the reflection operation fixes the stability modal and exchanges the two open modals, so the reflection arms change shape and must be re-proved rather than re-cited), and the stability arms of the truth recursion, the axiom type, the derivation tree and the soundness recursion. Both conservativity directions over the other language must be re-stated, since the embedding's stability clause is exactly what changes. The regularity precondition goes in the docstring of every result that now needs it, and in the theorem-index row's frame-class column.

ORDERING, AND IT IS A HARD GATE. This task must run AFTER the L^▷ proof system, the L^▷ substitution closure and the L^▷ incompleteness transfer have landed, and BEFORE the display-name rename. Rationale: each of those three lands new declarations that pattern-match on `OpenFormula`'s constructors, so removing a constructor first would force them to be written twice; and the rename should operate on a language whose constructor set is final. Declare all three as dependencies.

EXPLICITLY NOT IN SCOPE. Do not touch the other language's own stability constructor, its axiom type or its derivation tree -- the standing ruling against mutating those inductives is unaffected by this task and the landed incompleteness and independence results depend on them unchanged. No completeness claim. No decidability claim. Do not weaken a landed result to a regular-class-only form in order to make removal go through without saying so: any result whose frame class narrows is a recorded consequence of this task, listed in the summary, not a silent edit.

THE HONEST OUTCOMES, and all three are complete. (a) Removal lands, with the regularity precondition documented. (b) Removal is refused on obstruction (1) or (2), with the blocking consumer named and compiled evidence recorded under the evidence-probe convention. (c) Removal lands at the regular class only, with the off-regular behaviour change stated explicitly in the module docstring and the theorem-index rows. A refusal with a named cause is a complete outcome and must not be reported as a failure.

LAYERING AND GATES. Add any new file's row to the layer table in `scripts/measure-refactor-partitions.py` in the same phase as the file or the cycle checker FAILS naming it. One theorem-index row per changed result, with the frame class explicit -- a result whose class narrows and whose row does not say so is a defect. Re-run the module-invariants emitter rather than hand-editing a README inventory block.

VERIFICATION GATE. Guarded scoped build green, then the unscoped build; never bare `lake`. Zero `sorry`, zero vacuous definitions. The bare module-invariants check and the metalogic-cycles check both green. Axiom sets measured per declaration and diffed against the pre-removal baseline, captured in Phase 1 before any edit: the composite form routes through two operators whose own proofs may carry choice where the primitive's did not, and a widened axiom set is a recorded cost of this task, not a new baseline.

---

### 875. Open language incompleteness transfer
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 856, Task 871, Task 873

**Description**: PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the repository is now completeness and decidability of the stability-modal language L-plus; L^▷ is a secondary line of investigation, kept and not abandoned. This task belongs to the L^▷ exploration stage of specs/ROADMAP.md, off both critical paths: do not dispatch it ahead of, or batch it with, L-plus critical-path work. Its content below stands except where this paragraph says otherwise.

IMPLEMENTATION TASK, gated on the L^▷ proof system and its conservativity directions: transfer the landed L-plus incompleteness results to L^▷, and state the limit-closure schema in L^▷ form at the frame classes where the L-plus translation does not reach.

THE GAP, VERIFIED AT FILING. `plus_incomplete_base`, `not_plus_complete_base` and `blc_not_plusDerivable_base` are landed and cited from `FormalSystem/Metalogic.lean` and `FormalSystem/Metalogic/Independence.lean`. A tree-wide grep for an L^▷ counterpart (`open_incomplete`, `not_open_complete`) returns nothing, and no task in `specs/state.json` names one. The L^▷ proof-system task states in its own description that `plus_incomplete_base` "stands exactly as proved", that `blc` "stays a non-theorem", and that "an LC_n-style schema is still required in L^▷ exactly as in L-plus" -- it flags both items and scopes neither. Nobody owns them.

WHY THE TRANSFER IS AVAILABLE RATHER THAN OPEN. This is a corollary task, not a research task. The L^▷ proof-system work delivers conservativity over TM-plus in both directions; with both directions in hand, incompleteness transfers by composition: a formula valid at Base but not L-plus-derivable has an `ofPlus` image valid at Base (semantic conservativity, landed in `OpenValidity.lean`) whose L^▷-derivability would, by backward conservativity, give the L-plus derivation that does not exist. Write it in that shape -- as the composition of named landed results -- and do not reprove any underivability.

WHAT TO STATE. (1) The L^▷ incompleteness triple at Base: the `ofPlus`-image of the limit-closure countermodel formula is Base-valid and not L^▷-derivable, hence the L^▷ system is incomplete at Base. (2) The honest scope line: this says the particular L^▷ system is incomplete, not that no recursive axiomatization exists -- that question is open at every class for L-plus too and must not be overstated here. (3) The limit-closure schema in L^▷ form, at Base and Dense. At ZTime the translation already answers it, because `openValidIn_ztime_iff_tr` makes any L^▷ validity question at ZTime an L-plus question; at Base and Dense the open-future modal is a genuine expressive extension, the translation is unavailable, and the schema must be stated natively over `OpenFormula`. Cite the landed L-plus schema rather than re-deriving it: `PlusLanguage/PlusLCSchema.lean` and `PlusLanguage/PlusLimitClosure.lean`.

DEPENDENCIES, BOTH HARD. The L^▷ proof-system task (for `OpenDerivable` and both conservativity directions) and the corrective limit-closure repair task (which fixes the `PlusLCSchema` docstring and the `omega_chain` parameter this task would otherwise cite in its broken form). Do not enter before both land.

EXPLICITLY NOT IN SCOPE, each being a way to get this wrong. No positive completeness claim for L^▷ at any class, conditional or otherwise. No claim that no recursive axiomatization of L^▷ exists -- that is strictly stronger than incompleteness of one system and is not established for L-plus either. No new constructor anywhere, and no change to the landed L-plus underivability proofs: they are cited, never edited. Do not route the transfer through the ZTime translation at Base or Dense, where it does not apply.

LAYERING AND GATES. This is metalogic-layer work and belongs under `FormalSystem/Metalogic/`, beside the existing Independence block, not inside `OpenLanguage/`. Add any new file's row to the layer table in `scripts/measure-refactor-partitions.py` in the same phase as the file. One `docs/theorem-index.md` row per result, with the frame class stated explicitly -- a Base-only result recorded without its class is a defect. Re-run `bash scripts/check-module-invariants.sh --emit-inventory`.

VERIFICATION GATE. Guarded scoped build green, then the unscoped build; never bare `lake`. Zero `sorry`. `bash scripts/check-module-invariants.sh` (bare form) and `bash scripts/check-metalogic-cycles.sh` both green. Axiom sets measured per declaration and compared against the L-plus originals: the landed underivability results pin their own axiom sets and the transfer must not widen them.

---

### 874. Open language substitution closure
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: syntax
- **Dependencies**: Task 856, Task 873

**Description**: PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the repository is now completeness and decidability of the stability-modal language L-plus; L^▷ is a secondary line of investigation, kept and not abandoned. This task belongs to the L^▷ exploration stage of specs/ROADMAP.md, off both critical paths: do not dispatch it ahead of, or batch it with, L-plus critical-path work. Its content below stands except where this paragraph says otherwise. RATIONALE CORRECTION: the paragraph below headed WHY IT MATTERS FOR THE END STATE is superseded. L-plus is not to be made dispensable. The value of this task is that L^▷ gains its own substitution closure and a direct embedding of L, as properties of L^▷ worth having on record.

IMPLEMENTATION TASK, gated on the L^▷ proof system: build `FormalSystem/OpenLanguage/Substitution.lean`, the L^▷ counterpart of `FormalSystem/PlusLanguage/Substitution.lean`. This is the substitution-closure half of the L^▷ proof system and it also lands the direct L-to-L^▷ embedding, which the tree currently reaches only by composing two maps.

THE GAP, VERIFIED AT FILING. `FormalSystem/OpenLanguage/` has no `Substitution.lean`; `OpenAxioms.lean` contains zero occurrences of "subst" and `OpenDerivation.lean` one. A tree-wide grep for `substOpen` returns nothing and no task names it. By contrast `PlusLanguage/Substitution.lean` carries `substPlus : (Atom -> PlusFormula) -> Formula -> PlusFormula`, `substCtxPlus`, `substPlus_atom` (which identifies the atom-substitution with `ofFormula`, making the base-language embedding a corollary rather than a separate definition), `substPlus_reflectTime`, `PlusAxiom.ofTMSubst`, `PlusAxiom.minFrameClass_ofTMSubst`, `PlusDerivationTree.ofTMSubst`, `plusDerivable_substPlus` and `plusDerivable_substPlus_nil`. None of this exists at L^▷.

WHY IT MATTERS FOR THE END STATE. `substPlus_atom : substPlus PlusFormula.atom phi = ofFormula phi` is the statement that makes L-plus a genuine extension of L's proof system rather than a parallel one: every TM axiom lifts to a TM-plus axiom under substitution, and every TM derivation lifts to a TM-plus derivation. Without the L^▷ mirror, L^▷ inherits L's proof system only through L-plus, so L-plus is load-bearing in the chain and cannot become internal. The mirror `substOpen_atom : substOpen OpenFormula.atom phi = ofFormula' phi` is the direct L-to-L^▷ embedding, and it is the structural step that leaves L and L^▷ as the two languages a reader needs.

WHAT TO BUILD, mirroring the L-plus file declaration for declaration. `substOpen : (Atom -> OpenFormula) -> Formula -> OpenFormula`; `substCtxOpen`; `substOpen_atom` together with whatever direct embedding `Formula -> OpenFormula` it identifies (introduce it in `Formula.lean` if it is not already there, and prove it equal to `ofPlus (ofFormula .)` so the two routes into L^▷ are provably the same map -- that equation is a deliverable, not an aside); `substOpen_reflectTime`, cheap because `reflectTime` fixes box and stab and exchanges ofut with opast (`OpenReversal.lean`); `OpenAxiom.ofTMSubst` with its `minFrameClass` companion; `OpenDerivationTree.ofTMSubst`; `openDerivable_substOpen` and its empty-context form.

DEPENDENCY, AND IT IS A HARD GATE. `OpenAxiom` and `OpenDerivationTree` must exist before `OpenAxiom.ofTMSubst` and `OpenDerivationTree.ofTMSubst` can be stated. Declare the L^▷ proof-system task as a dependency and do not enter this one before it lands. The `substOpen`/`substOpen_atom`/embedding-agreement part is pure syntax and could in principle be split out ahead of the gate; if the proof-system task is still open when this is dispatched, land the syntax half and record the axiom/derivation half as a reasoned exclusion rather than blocking.

EXPLICITLY NOT IN SCOPE. No completeness claim. No new constructor on `OpenFormula`, `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`. Do not define stab away as ofut-opast: it stays primitive, since the backward half of that biconditional needs `[F.IsRegular]`. Do not alter `substPlus` or anything under `PlusLanguage/` -- this task adds the L^▷ mirror and touches the L-plus original only to cite it.

LAYERING AND GATES. Syntax layer: no import from `FormalSystem/Semantics/` and no semantic module of any language. Add the new file's row to the `LANGUAGE_FILE_LAYERS` table in `scripts/measure-refactor-partitions.py` in the same phase as the file or `scripts/check-metalogic-cycles.sh` FAILS naming it. One `docs/theorem-index.md` row per result; re-run `bash scripts/check-module-invariants.sh --emit-inventory` rather than hand-editing the README inventory block.

VERIFICATION GATE. Guarded scoped build of `FormalSystem.OpenLanguage` green, then the unscoped build; never bare `lake`. Zero `sorry`, zero vacuous definitions. `bash scripts/check-module-invariants.sh` (bare form) and `bash scripts/check-metalogic-cycles.sh` both green. Axiom sets measured per declaration and compared against the L-plus originals being mirrored.

---

### 873. Open language subformula closure
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: syntax
- **Dependencies**: None

**Description**: PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the repository is now completeness and decidability of the stability-modal language L-plus; L^▷ is a secondary line of investigation, kept and not abandoned. This task belongs to the L^▷ exploration stage of specs/ROADMAP.md, off both critical paths: do not dispatch it ahead of, or batch it with, L-plus critical-path work. Its content below stands except where this paragraph says otherwise.

IMPLEMENTATION TASK, small and fully templated: build `FormalSystem/OpenLanguage/Subformulas.lean`, the L^▷ counterpart of `FormalSystem/PlusLanguage/Subformulas.lean`. This is pure syntax, gated on nothing, and it is the one piece of L^▷ infrastructure that any native decision procedure over `OpenFormula` needs before it can be stated at all.

THE GAP, VERIFIED AT FILING. `FormalSystem/OpenLanguage/` holds nine files and no `Subformulas.lean`. A tree-wide grep for `openSubformulas`, `subformulasOpen`, `openSubformulaClosure` and `openComplexity` returns nothing, and no task in `specs/state.json` names any of them in a description or a `file_scope`. By contrast `PlusLanguage/Subformulas.lean` is 373 lines carrying `subformulas`, the per-constructor membership lemmas, `subformulas_trans`, `plusSubformulaClosure` as a `Finset`, `self_mem_plusSubformulaClosure`, the `decidableMemPlusSubformulaClosure` instance and the `plusClosure_*` closure lemmas one per constructor. L^▷ has none of it.

WHAT TO BUILD, mirroring that file constructor for constructor. `subformulas : OpenFormula -> List OpenFormula` over all nine constructors; the membership lemmas (`self_mem_subformulas`, `imp_left`/`imp_right`, `box_inner`, `untl_left`/`untl_right`, `snce_left`/`snce_right`, `stab_inner`, and the two new arms `ofut_inner_mem_subformulas` and `opast_inner_mem_subformulas`); transitivity; `openSubformulaClosure` as a `Finset OpenFormula` with its self-membership, its decidable-membership instance and one `openClosure_*` lemma per constructor. `OpenFormula` must have `DecidableEq` for the `Finset` layer -- check whether `Formula.lean` already derives it and derive it there if not, in the same phase.

THE AGREEMENT LEMMA THAT MAKES THIS A TRANSFER AND NOT A DUPLICATE. State `subformulas_ofPlus`: the subformulas of `ofPlus phi` are the `ofPlus`-images of the subformulas of `phi`, and the closure analogue. This is what lets a result proved by induction on L-plus subformula closure be re-read at L^▷ instead of re-proved, and it is the reason this file belongs to the transfer programme rather than being incidental library padding. Expect it to hold by `rfl` or a short induction, since `ofPlus` is constructor-to-constructor and every derived operator shares its `PlusFormula` namesake's right-hand side.

EXPLICITLY NOT IN SCOPE. No decision procedure, no decidability claim, no engine change. `clSig`, `LocalRun` and `Anchored` get no `ofut`/`opast` clause from this task -- the standing containment ruling keeps the L-plus decidability engine's own definitions untouched, and this task supplies a syntactic closure over `OpenFormula` that no existing engine consumes yet. Add no constructor to `OpenFormula`, `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`.

LAYERING AND GATES. This is a syntax-layer file: it imports nothing from `FormalSystem/Semantics/` and no semantic module of any language. `scripts/check-metalogic-cycles.sh` enforces that edge and reads each file's layer from the per-file `LANGUAGE_FILE_LAYERS` table in `scripts/measure-refactor-partitions.py` -- add the row for the new file in the same phase as the file, or the gate FAILS naming it. Every result needs a `docs/theorem-index.md` row: statement, fully-qualified Lean name, file, frame class, pinned axiom set. The README inventory block is generated, not hand-edited: re-run `bash scripts/check-module-invariants.sh --emit-inventory`.

VERIFICATION GATE. Guarded scoped build of `FormalSystem.OpenLanguage` green, then the unscoped build; never bare `lake`. Zero `sorry`, zero vacuous definitions. `bash scripts/check-module-invariants.sh` (bare form) and `bash scripts/check-metalogic-cycles.sh` both green. Axiom sets measured per declaration; the L-plus original is choice-free, so picking up `Classical.choice` here is a regression rather than a new baseline.

---

### 869. Open modal invariance ray agreement lifting
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: semantics
- **Dependencies**: Task 743, Task 898

**Description**: PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the repository is now completeness and decidability of the stability-modal language L-plus; L^▷ is a secondary line of investigation, kept and not abandoned. This task belongs to the L^▷ exploration stage of specs/ROADMAP.md, off both critical paths: do not dispatch it ahead of, or batch it with, L-plus critical-path work. Its content below stands except where this paragraph says otherwise.

IMPLEMENTATION TASK, small and self-contained: state and prove truth invariance for the open-future and open-past modals along a history morphism that lifts ray agreement, and derive such a lifting at ZTime from TwoWayBounded. This is the one formalization item recommended by the MSO-route research; it is independent of every unverified step in that route.

WHY THIS EXISTS, AND WHAT IT IS NOT. The MSO route argues on paper that ZTime validity of the open language is decidable, and the open modals were confirmed to ride step 4's encoding -- see specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md, recommendation R1. That route is NOT being formalized and is not to be: Mathlib has no MSO syntax, no omega-automata, no determinization, and no Rabin tree theorem, so step 5 would mean a multi-year project of a different kind. This task lands only the semantic invariance lemma the route's cover step needs, which is useful on its own terms wherever open-modal truth must be transported along a morphism. Claim no decidability result and no completeness result here.

WHAT TO STATE. Three pieces, in this order:

(1) A ray-agreement lifting hypothesis beside HistMap.lift in FormalSystem/Semantics/HistoryMorphism.lean, as a standalone hypothesis or a new field: a history of the image frame agreeing with the image of tau' up to x lifts to a history of the source agreeing with tau' up to x. Then its time-reflected mirror for the open-past modal. Note that HistoryMorphism.lean's own docstring already records that HistMap.lift is derivable from TwoWayBounded.step rather than primitive, and that step is strictly weaker than lift -- read that discussion before choosing between a field and a hypothesis, and record the choice.

(2) The ZTime derivation of both from TwoWayBounded.step/forth via the existing forward/backward sequence machinery in the same module. The research notes the lifted witness reuses the given history's past verbatim and needs only forward lifting from the basepoint at x, which is strictly weaker than the two-sided HistMap.lift that plus_invariance's stab case already uses -- so this should be easier than the landed two-sided case, not harder.

(3) An open_invariance theorem over OpenFormula, reusing plus_invariance's seven cases. OpenLanguage sits above Semantics (OpenTruth.lean imports Semantics.Truth; nothing under Semantics/ imports OpenLanguage), so a new FormalSystem/OpenLanguage/OpenInvariance.lean can import HistoryMorphism -- confirm the aggregator wiring in FormalSystem/OpenLanguage.lean, and confirm the layering still holds before committing to the module site.

SIZE: estimated 150-350 lines, one implementation phase. Independent of Gabbay separation (no SeparationOver hypothesis is needed), of the ladder/RaySummary front, and of the two gaps the MSO research located in report 03 section 1.3 (the step-1 fixpoint circularity and the step-3 forest-versus-tree mismatch). Nothing gates it.

GATES. Zero sorry, zero vacuous definitions. A docs/theorem-index.md row per landed result, with Paper: and a reason at the declaration or C15's second assertion fails. Re-measured axiom baselines pinned by scripts/check-module-invariants.sh, never typed by hand. Guarded scoped build green, then the unscoped build; check-module-invariants.sh and check-metalogic-cycles.sh both green against their pre-task baselines.

TWO KNOWN ENVIRONMENT FACTS, so they are not rediscovered. First, any task adding .lean lines in this repository must regenerate three files that a phase file list will not obviously name: the BEGIN GENERATED inventory blocks in README.md and the relevant FormalSystem README, via check-module-invariants.sh --emit-inventory, and typst/generated/status.typ via typst-sync-check.sh --fix, which a pre-commit hook enforces. They are in this task's file_scope for that reason. Second, check-module-invariants.sh's C16 group currently reports one pre-existing unusedArguments finding at FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136, last touched by an unrelated commit; it is not this task's to fix, and "green against pre-task baselines" means that finding and no other. scripts/check-paper-definitions.sh likewise exits 1 on manuscript drift outside this repository.

NAMING CONSTRAINT, which has already cost one round elsewhere: gate C26 and C16's defsWithUnderscore linter both reject a snake_case def or abbrev name in the live tree. Decidable-valued and other defs are camelCase; theorems keep snake_case. Name accordingly when writing the plan's challenge statements, not afterwards.

---

### 867. Formalize gabbay separation ztime
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: None
- **Research**: [867_formalize_gabbay_separation_ztime/reports/01_gabbay-separation-ztime-plusformula.md]
- **Plan**: [867_formalize_gabbay_separation_ztime/plans/04_landed-device-resize-10-2-7-10-2-8.md]
- **Summary**: [867_formalize_gabbay_separation_ztime/summaries/04_separation-theorem-discharge-ztime-summary.md]

**Description**: PRIORITY AND RATIONALE RULING (2026-11-05, user): this task STAYS on the L-plus path, sequenced AFTER the ZTime decidability front, and its consumers are re-ordered. FIRST consumer: the L-plus ZTime completeness programme -- the doubled (two one-sided, clock-anchored) automaton route located in specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md is sufficient in shape only conditional on `SeparationOver TaskFrame.IsZTime`, and the until-form LCU waits on it. SECOND consumer: the L^▷ translation (making `tr` executable and the ZTime/RTime transfer rows unconditional), which is now a secondary line of investigation. Read the WHY NOW paragraph below in that order.

IMPLEMENTATION TASK, sizeable: formalize Gabbay separation over discrete time for PlusFormula, discharging the SeparationOver hypothesis and making the open-future translation executable.

WHY NOW. This was proposed as recommendation R4 of specs/854_open_future_modal_lplus_definability/reports/01_open-future-definability-verdict.md and deliberately NOT filed there, on the stated condition that it be filed "only if a consumer needs the executable translation". Two consumers now exist. First, FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean's two headline results, openValidIn_ztime_iff_tr and openValidIn_rtime_iff_tr, are conditional on SeparationOver -- a hypothesis standing for cited literature that this tree does not formalize -- so the unconditional verdict that the open-future modal is definable at ZTime and RTime lives only in that module's docstring with its citation, not in a pinned row. Second, any transfer of decidability through the translation needs tr to be computable, not merely to exist.

WHAT TO FORMALIZE. GHR Lemmas 10.2.1 through 10.2.8 -- the eight eliminations plus the junction-depth induction -- for PlusFormula over frames satisfying IsZTime, discharging SeparationOver TaskFrame.IsZTime. The reference is Gabbay, Hodkinson and Reynolds, Theorem 10.2.9 over the integers; Theorem 10.3.20 is the Dedekind-complete counterpart and is the natural second target, not necessarily this task's.

WHAT IS ALREADY LANDED AND MUST NOT BE REDONE. The elimination layer that CONSUMES separation is complete and compiled in OpenFutureElimination.lean: PastDet, FutDet, the syntactic bridges, OfutP and OpastP, the eliminations ofutP_or_iff and opastP_or_iff with their CNF forms ofutP_sepForm_iff and opastP_sepForm_iff, the SeparationOver predicate itself, tr, and the two validity-transfer results. This task supplies the hypothesis those results take; it does not restate them and must not weaken any of their signatures.

SIZING, AND AN HONEST WARNING. Report 01 of task 854 rates this as a sorry-free path that EXISTS and is SIZEABLE, comparable to a multi-phase implementation round. Expect the junction-depth induction to be the expensive part. Before committing, weigh it against the MSO/Rabin decidability route, which reaches a decidability answer for the open language at ZTime with no translation at all -- if that route holds, this task's value is confined to making the definability verdict unconditional and to giving an executable tr, which is real but narrower than it looks.

SCOPE. The separation development and the discharge of SeparationOver at IsZTime; the theorem-index rows that become unconditional as a result, restated from their conditional form; the re-measured axiom baselines. Do NOT touch FormalSystem/Metalogic/Independence/ -- the non-definability result at Base and Dense is a separate verdict and is unaffected, since separation does not hold there. Do not alter the metalogic-cycles allowlist.

GATES. Zero sorry, zero vacuous definitions, no new axiom beyond what the eliminations already carry. Guarded scoped build then unscoped; check-module-invariants.sh and check-metalogic-cycles.sh green against their pre-task baselines; every axiom profile measured, never hand-typed. If the development stalls, a precisely located obstruction -- which elimination resists formalization and why -- is a legitimate [COMPLETED WITH EXCLUSIONS] outcome.

---

### 862. Promote cntAt_eq_of_pend_eq_fwd into LadderAgree as a strict sharpening
- **Effort**: small
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 761, Task 852
- **Parent**: Task 855

**Description**: Promote cntAt_eq_of_pend_eq_fwd from the evidence probe into FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean as a strict sharpening of the landed cntAt_eq_of_pend_eq. The landed theorem's own proof already reads its hypothesis only at positions at or above the compared one, so the forward-only hypothesis suffices -- the same proof at a weaker hypothesis, verified sorry-free in specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean. Land it beside the existing theorem, derive the existing theorem from the sharpening or state why that direction is not worth the churn, and keep the probe compiling. No sorry, no new axiom, axiom profile within [propext, Classical.choice, Quot.sound]; check-evidence-probes.sh and the full guarded lake build must both stay green.

---

### 861. Record the one-sided transport refutation in the RaySummary refutation table
- **Effort**: small
- **Status**: [RESEARCHED]
- **Task Type**: markdown
- **Topic**: decidability
- **Dependencies**: Task 761, Task 763, Task 838
- **Parent**: Task 855

**Description**: Add the one-sided transport refutation row to the RaySummary refutation table in FormalSystem/Metalogic/Decidability/RaySummary/README.md, recording the NEGATIVE verdict that the probe specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean establishes: the one-sided open-modal factorization does not crack the transport condition. State the mechanism as the probe states it -- the ladder countdown and the closure eventualities read the same forward half-line, so freezing the future leaves nothing to transport and freeing it loses the realized type. Cite the probe file and its headline declarations by name. Scope: README.md only; no .lean edits. Do not claim any decidability consequence.

---

### 853. Ladder path insertion cascade idle past
- **Effort**: large
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 838
- **Parent**: Task 761
- **Plan**: [853_ladder_path_insertion_cascade_idle_past/plans/01_insertion-cascade-idle-past.md]
- **Summary**: [853_ladder_path_insertion_cascade_idle_past/summaries/01_insertion-cascade-idle-past-summary.md]

**Description**: Construct the Phase 11.8 insertion cascade for the ladder-path region lemmas: the idle-past half (exists_ladderPath_at_region_of_idle_past) and, given it, the unconditional join (exists_ladderPath_at_region), which follows by by_cases on the pending-past predicate.

VERIFIED STARTING POSITION (blocker research, checked against the Lean source):
(1) Both unlanded names are gated on a SINGLE owed construction, not two.
(2) The obvious route is REFUTED, not absent: pinCompat_of_ladderPath proves the splice demand necessary, and on a pin-tight original it reads s-v+l <= s-v, false for l>0 (tight witness tightChain_slack_zero compiles). No pin hypothesis can be relaxed -- a relaxed lift lemma would be FALSE, not weaker.
(3) cntAt_eq_of_obj_eq makes the countdown a function of the object walk, so the surgery cannot be confined to the countdown.
(4) No insertion/lengthening walk constructor exists under FormalSystem/. Only cascade bookkeeping is landed (pinnedRegions_subset_Ico/_finite/_ncard_le, pin_deficit_le_of_lengthen, cascadeDemand*, LadderAgree.lean:1424-1484).

SIZING: three new components, none landed, with a refuted predecessor -- a standalone construction, not a residual phase.
TRAP: two_pow_card_prodState_le_Tc lives in LadderChain.lean, which IMPORTS LadderAgree.lean and is unavailable here. Only cascadeBound from CounterQuotient.lean is citable.
SOUNDNESS: the parent is sound as recorded; the counter-lift admissibility half is unconditional in the pending-forever regime and conditional in the idle-past one. The parent proceeds on certStabK, independent of this blocker.

RECONCILIATION: overlaps-open against the two-sided open-core pigeonhole task (shared LadderAgree.lean, sibling open core, different construction) -- a serializing dependency edge is recorded. A duplicate-of-open against the nondeterministic-canonical-model research task was ruled a Pass-2 false positive at the lead level.

ORIGIN: Conclusion stage (channel c) of an /orchestrate invocation over the ladder realization theorem task, user-approved.
CITATIONS: parent issues.jsonl iss_1793819583011_jsu079 and iss_1792373250168_HQM6Je.

---

### 838. Two sided open core pin free pigeonhole
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Parent**: Task 836
- **Plan**: [838_two_sided_open_core_pin_free_pigeonhole/plans/01_pin-free-pigeonhole-open-core.md]
- **Summary**: [838_two_sided_open_core_pin_free_pigeonhole/summaries/01_pin-free-pigeonhole-open-core-summary.md]

**Description**: The depth-0 cell obligation is blocked on a two-sided open combinatorial core: the spanning-block device is refuted in BOTH directions, so a new route is needed.

Established by the Phase 3 decision gate of the ladder pump layer (commits fb99cfa0f, f88de40a9), compiled rather than argued. The tight doubling chain was built (tightChain_isLadderPath, tightChain_pin, tightChain_slack_zero), the spanning-block condition was stated in both directions, and both directions were refuted by compiled objects in specs/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean: spanningBlockBwd_refuted at a path with one idle position and the closure of a S not-a, and spanningBlockFwd_refuted at Probe761C own gC.

Mechanism: the only candidate device for rebuilding the register type-respectingly across a tight pin -- duplicate a block SPANNING a region start, then pump the copies -- is false as a consequence of ParamsOk. The two cascades (backward on the tight doubling chain, forward on its mirror) are the open core. This is two-sided, not regime-B-only: the downward inclusion (shortening the region of z by deletion) and the n-sub-regime where the register must drop by more than the window allows cascade forward exactly as regime B cascades backward.

What is NOT settled: both refuting objects have a pin-free side on which the register IS rebuildable without a spanning block, so the obligation under the repaired two-depth (K4) is NEITHER proved NOR refuted. cellLE_zero_const_of_kappa_eq remains reserved in FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean and is claimed by nothing.

Two named routes, both open:
(a) a (K2)-level pigeonhole over region starts that exploits the pin-free side the two refuting objects both have;
(b) revising the obligation statement itself -- never under the reserved name.

Available ground: the certificate-free pump layer is landed and green. LadderPump.lean (1,485 lines) carries deletion admissibility, both type lemmas (duplication and deletion, HWZ 2000 Lemma 17 over the integers), the forward window nxtAt_le_cntAt_add_of_next_region, the pigeonhole and iterated duplication. LadderChain.lean (612 lines) carries the budget lemmas, the realized-chain bridge, the regime-A assembly and the upward cell inclusion. Seven of eight pinned Lean Challenge Statements are theorems on the standard axiom profile, pinned in Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean. (K4) is repaired with the forward exactness depth dFwd and the obligation refutation at the frozen one-depth (K4) is wired as the forty-seventh probe.

Consequence if unresolved: the depth-0 base case does not land, so the parent ladder realization theorem Phase 11.6 (which inducts from it) stays unenterable, and the phases above it remain unreachable along this route.

Origin: conclusion-stage channel (c) of an orchestration run, citations iss_1793676481950_X5nVmj (Phase 3 FAIL, design-record defect, blocking), iss_1793682949115_VWHeyc (Phase 10 BLOCKED, design-record defect, blocking), iss_1793666338306_aFixsS (plan-gap, blocking), iss_1793672574750_4C3zev (two-sidedness, plan-gap, costly).

---

### 832. Reclaim opencode old and data partials
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: repo-hygiene
- **Dependencies**: None

**Description**: Two local-disk reclamations found by the 2026-11-02 review. Both are LOCAL-DISK ONLY: every path below is gitignored with zero tracked files, so nothing here produces a commit and nothing is recoverable from git afterwards. That asymmetry is the whole reason item 2 is a user decision rather than an action.

STANDING INSTRUCTION -- RE-VERIFY BEFORE DELETING. Re-check sizes, mtimes and `git ls-files` for each path before removing anything. Never delete on the strength of this description alone.

ITEM 1 -- `.opencode_OLD/`: SAFE TO DELETE (62 MB). Verified at filing: gitignored at `.gitignore:105`, zero tracked files; mtime 2026-05-07 against `.opencode/`'s 2026-05-14; `diff -rq .opencode .opencode_OLD` shows 38 entries differing, mostly `node_modules` plus a `python` extension present in the live `.opencode/` and absent here. It is strictly a stale subset of the live tree. Confirm the subset relation once more (`diff -rq`), then delete. No commit follows.

ITEM 2 -- `data/`: USER DECISION, NOT AN AUTOMATIC DELETE (2.3 GB total). Verified at filing: gitignored at `.gitignore:107`, zero tracked files. Composition: `proof_steps.jsonl` 1.6 GB, plus two abandoned checkpoints, `bmlogic-c8-clean.jsonl.partial` (375 MB) and `.checkpoint.partial` (15 MB).
  - The two `.partial` files (390 MB combined) are the unambiguous candidates -- abandoned checkpoints of an interrupted run.
  - `proof_steps.jsonl` is NOT a safe unilateral delete: it feeds the training-dataset pipeline consumed by the separate BimodalHarness repository (private, per `README.md`'s Related Projects section). Removing it may destroy a dataset that is not reproducible without re-running the generator. ASK before touching it; do not treat its size as justification.

NOT IN SCOPE -- the rest of the top-level directories were audited and are each intentional or harmless, so do not sweep them: `Boneyard/` (5.4 MB, 225 TRACKED files, intentional and justified by `Boneyard/README.md`, ADR-009 retention and ADR-005 single-archive; `#exit`-guarded, not a Lake root -- DO NOT DELETE), `research/` (`.gitignore:90`), `training/` (:91), `other/` (:109, single `dana.md`), `build/` (:3, stray LaTeX aux output), `.memory/` (:76), `.agent-logs/` (:108), `.playwright-mcp/` (:118), `.opencode/` (:75, the LIVE tree).

ALSO NOT IN SCOPE -- documentation staleness. `CHANGELOG.md` is roughly six weeks stale (last touched 2026-09-21 against a 2026-11-02 last commit) and `FormalSystem/Metalogic/README.md` cites `completeness_discrete`, a name that no longer exists (renamed to the ZTime form; the README admits the discrepancy in prose). Both fold into the already-filed documentation-polish record (177), which is last in the programme. Do NOT fix them here and do not file them separately.

ACCEPTANCE. `.opencode_OLD/` removed after a confirming `diff -rq`; a recorded decision on the two `data/*.partial` files; `proof_steps.jsonl` untouched unless the user says otherwise. No commit is expected from this task -- if `git status` shows anything staged after it, something outside scope was touched.

FILE SCOPE: `.opencode_OLD/`, `data/` (inspection and the two `.partial` files only).

PROVENANCE: `specs/reviews/review-2026-11-02.md`, Low Priority Issues section.

---

### 831. Dense time certificate dichotomy gate
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None

**Description**: RESEARCH TASK, verdict-first. State and attempt the logic-level dichotomy that gates the dense-time certificate route (L-R3).

CLASSIFICATION: RESEARCH, not implementation. The deliverable is a verdict plus grounds, not a landed theorem. Do not re-describe this as engineering, and do not budget it as a routine task.

WHY IT MATTERS. Every landed and in-flight decidability result in this tree is ZTime-shaped. L-R3 is the ONLY identified non-spine route to Base/Dense/RTime. The review `specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` marks L-R3 "NEW, UNFILED"; this record is what makes that reference resolve.

STANDING INSTRUCTION -- RE-VERIFY BEFORE CITING. Re-read the followup-scope-spec and re-grep before citing any name below. The spec lives under `specs/archive/`; confirm the path still resolves before quoting it.

THE GATE, VERIFIED AT FILING (2026-11-02). L-R3 is blocked on a logic-level dichotomy of the shape

    Log(all) = Log(ZTime) INTERSECT Log(Dense)

and NO Lean declaration states it -- confirmed by grep over `FormalSystem/` at filing time. Re-confirm that absence before writing anything, and if a declaration has since appeared, say so and stop: the premise of this task would then be stale.

CHEAPEST HONEST FIRST INCREMENT. State the dichotomy as a Lean proposition and attempt it. A refutation is a complete outcome; so is a verdict that it is open with the obstruction named. What is NOT acceptable is a plan that assumes the dichotomy and builds the certificate class on top of it -- that is the shape this record exists to prevent.

RELATION TO THE TABLEAU SPINE. This is deliberately OFF the spine (428 / 429 / 430 / 412 / 482). 430's own record states the spine is no longer the critical path to a first decidability result, and 429 and 482 are both flagged open mathematics, multi-month. Do not fold this into any of them, and do not schedule it as a substitute for ROADMAP Stage 1 (`/orchestrate 761 --hard --lit`), which it does not advance.

ACCEPTANCE. A report recording (a) the dichotomy as stated in Lean, (b) the attempt and its outcome -- proved, refuted, or open with the obstruction named -- and (c) a verdict on whether L-R3 is worth filing as an implementation front at all. No Lean needs to land beyond the statement itself and whatever the attempt produces.

FILE SCOPE: research-only; no committed Lean required beyond a probe. Any probe goes under this task's own `specs/` directory, not into `FormalSystem/`.

PROVENANCE: `specs/reviews/review-2026-11-02.md`, Medium Priority Issues section.

---

### 830. Generalize decidable validztime finite premises
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None

**Description**: Generalize `Compression.decidableValidZTime` from the empty-premise case to arbitrary finite premises.

CLASSIFICATION: IMPLEMENTATION, bounded residue, NO OPEN MATHEMATICS. This is the one genuinely new tractable piece of decidability work the 2026-11-02 review found. It is NOT open research and must not be re-described as such.

SCOPE LIMIT, STATED FIRST SO IT IS NOT MISREAD. This strengthens the BASE-LANGUAGE result and does **not** advance the L+ aim (`Decidable (PlusValidZTime phi)`, ROADMAP Stage 1). `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md:132` records why: `ValidZTime` is stated for `FormalSystem.Syntax.Formula`, which carries no stability operator, and the durable scope sentence lives in `BiLasso/Assembly.lean`'s docstring. Do not let a plan or report claim this moves Stage 1.

STANDING INSTRUCTION -- RE-VERIFY BEFORE CITING. Re-read the README and re-grep every declaration name below before citing it.

VERIFIED AT FILING (2026-11-02). `Compression/README.md:114-129` ("## What is out of scope", "General finite-premise consequence") enumerates the residue and bounds it. Already stated at arbitrary `Gamma Del`, so NOT part of the work: `WitnessFamily.Refutes`, `WitnessFamily.refutes_of_certifies`, `WitnessFamily.joint_countermodel`, `exists_labelledLasso_of_history_realized`, `compressionBound`, and `WitnessFamily.decidableCertifies` with its four component instances.

THE RESIDUE IS EXACTLY THREE ITEMS (README:124-127):
1. The consequence analogue of `validZTime_iff_validInt`, for the entry point's carrier normalization.
2. `WitnessFamily.Target`'s premise clause.
3. `Enumerate.lean`'s phi-specializations: `closureSubsetsOf`, `rawLabelledLassos`, `IsLabelledLasso`, `boundedLassos`, `cands`.

THE README'S OWN CAVEAT, CARRIED FORWARD VERBATIM IN SUBSTANCE: "That residue is bounded and enumerated, and it is unproved -- the consequence-form normalization has never been written, so the general form is not known to compile." Treat item 1 as the risk-bearing item. If it does not go through, report that as the finding rather than forcing items 2-3 around it.

WHAT THIS CLOSES. The gap `decidableSemanticConsequenceNil` leaves -- it covers the empty-premise case only. The obstruction is narrower than it looks (README:116-121): a context-conjunction deduction theorem, which this tree does NOT have, is what the *reduction* route (`Gamma |= sigma` from `|= AND Gamma -> sigma`) would need; the *direct* route needs none, because `SemanticConsequenceIn` unfolds to local consequence at a point. Take the direct route.

ALREADY SPENT, DO NOT RE-DERIVE. `Decidable (Derivable .ZTime [] phi)` has already landed as `decidableDerivableZTime` in `FormalSystem/Metalogic/ZTimeProvability.lean`. That corollary is not available as this task's deliverable.

NOT IN SCOPE. A usable executable: `cands` is astronomically large and [GKWZ] section 6.5 gives an EXPSPACE-hardness lower bound for `PTL x S5`, so the cost is the literature's own (README:130-131, `Assembly.lean` docstring). Do not file performance work against it here.

ACCEPTANCE. The general finite-premise form is stated and proved sorry-free, or the attempt is reported with the specific item that blocked it; `lake build` green; axioms of any new headline declaration pinned to exactly `[propext, Classical.choice, Quot.sound]`; no regression in `scripts/check-module-invariants.sh`.

FILE SCOPE: `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/` (README plus the normalization entry point), `FormalSystem/Metalogic/Decidability/WitnessFamily/Enumerate.lean`, `FormalSystem/Metalogic/Decidability/WitnessFamily/Target.lean` (verify this path before relying on it).

PROVENANCE: `specs/reviews/review-2026-11-02.md`, Medium Priority Issues section.

---

### 829. Ci lake build cache and job config
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: build-performance
- **Dependencies**: None

**Description**: **NO BUILD CACHE FOR `.lake/build` IN ANY CI WORKFLOW.** Every CI run re-elaborates the whole library from scratch.

STANDING INSTRUCTION -- RE-VERIFY BEFORE CITING. Re-grep the workflow files before citing any line number below.

VERIFIED AT FILING (2026-11-02):
- All three workflows set `use-mathlib-cache: true` (`ci.yml:55`, `docs.yml:92`, `release.yml:115`), so Mathlib oleans are FETCHED, not built. That part is correct and is not what this record is about.
- There is NO `actions/cache` step anywhere under `.github/workflows/`: grep returns no `actions/cache`, no `key:`, no `restore-keys`. The project's OWN build artifacts are therefore discarded between runs.
- Scale being discarded: 716 `FormalSystem` modules, 371,441 lines; local `.lake/build` is 6.3 GB.

THIS IS DISTINCT FROM THE TWO FILED BUILD-COST TASKS (803 SubformulaProperty elaboration time, 804 its fan-in). Those reduce the cost of elaborating one module and its dependents; this one is cross-run artifact reuse. Neither subsumes the other, and this one is independent of both -- do not fold it into either.

TWO SUBORDINATE CONFIGURATION FINDINGS, same surface:
1. `ci.yml`'s `build` job (declared at `:17`, `runs-on: ubuntu-latest` at `:19`) has NO `timeout-minutes`, inheriting GitHub's 360-minute default, while `docs.yml:57` sets 300. Parity is the cheap fix.
2. `lakefile.toml` carries ZERO build-performance configuration: no `moreLeanArgs`, no `precompileModules`, no `extraDepTargets`, no parallelism or memory setting. All its `leanOptions` are linter-related (`linter.mathlibStandardSet`, `linter.style.longFile = 1500`, `unicodeLinter = false`). This is a greenfield area, NOT a misconfiguration -- say it that way in any report.
3. CI is a single serial job with no `strategy:`/`matrix:`. Four further sequential `lake build` invocations stack after the main step: the 15-target `lean_exe` root loop, `BimodalTools --wfail`, `BimodalToolsTest --wfail`, and the check scripts.

DELIVERABLE, ORDERED. (a) Add an `actions/cache` step scoped to `.lake/build` ONLY (Mathlib stays on `use-mathlib-cache`), keyed on the toolchain plus `lake-manifest.json` plus a cache-epoch segment -- an epoch segment such as `lake-recheck-v3-` is a sanctioned durable version axis under `rules/no-record-versioning-in-deliverables.md`, so it is permitted in the key. (b) Set `timeout-minutes` on `ci.yml`'s build job for parity with `docs.yml`.

GUARDRAIL. `precompileModules` and any matrix split are MEASURED EXPERIMENTS, not part of (a) or (b). Do not land either without a before/after timing recorded in the task's own artifacts. If a matrix split is ever evaluated, the natural seams are the two subdirectories that are 57% of the library: `Metalogic/Decidability/` (179 files, 106,266 lines) and `Metalogic/Expressiveness/` (143 files, 104,211 lines), then `WeakCanonical/` (45 / 29,303) and `BXCanonical/` (28 / 23,165).

NOT IN SCOPE. The agent-side mitigations are already in place and are a different problem: `.claude/context/project/lean4/operations/long-builds.md`, `multi-instance-optimization.md`, and `lake-build-guard.sh` (flock serialization, PSI/swap preflight, opt-in cgroup bounding) mitigate MULTI-SESSION CONTENTION, not build duration. Do not touch them here; they also live in the source store, not this repo.

ACCEPTANCE. A second CI run on an unchanged tree restores from cache rather than re-elaborating (visible in the run log); `ci.yml` declares a `timeout-minutes`; no change to what any check step verifies.

FILE SCOPE: `.github/workflows/ci.yml`, `lakefile.toml`.

PROVENANCE: `specs/reviews/review-2026-11-02.md`, High Priority Issues and Medium Priority Issues sections.

---

### 821. State counter archive numbering reconciliation
- **Effort**: low
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: repo-hygiene
- **Dependencies**: None
- **Parent**: Task 819

**Description**: Reconcile specs/state.json's next_project_number against the five archived rows carrying stray high numbers, so that validate-state.sh --deep Check 12 passes and state-write.sh --allocate-into stops refusing.

OBSERVED STATE, measured and not inferred. next_project_number is 821. Five archived rows carry 949, 953, 992, 998 and 1054 -- all above the counter. Check 12 of validate-state.sh --deep fails on exactly this relation, so the validator exits 1 repo-wide, before and after any unrelated task's writes. No archived row carries 820 or 821, so no duplicate task number has been created and nothing is corrupt today; the failure is a counter-versus-archive ordering invariant, not a collision.

TWO CONCRETE CONSEQUENCES, both already measured during an evidence-probe round. (1) state-write.sh --allocate-into refuses outright, forcing callers onto the literal fallback route commands/task.md Step 6 uses (re-read next_project_number immediately before the write, set next+1). That fallback works but it is a bypass of the allocator's own concurrency protection, so every task creation in this repo currently runs without it. (2) A permanently red validate-state.sh --deep masks any future real finding there: a second, genuine defect would not change the exit code and would be invisible to anyone who reads only the exit status.

THE DECISION THIS TASK OWNS, which is why this is research-first rather than a mechanical fix. The validator names "reset the counter to 1055" as the repair, but that is only correct if the five high numbers are legitimate history. Determine which of the two readings holds before writing anything:
(a) The five rows are legitimate archived tasks from a numbering range the counter lost track of -- in which case the repair is to raise next_project_number above the maximum (1055) and accept the gap from 821, documenting why the gap exists so a future reader does not "fix" it back.
(b) The five rows are artifacts of a vault operation or an import that renumbered live tasks without renumbering the archive -- in which case raising the counter to 1055 bakes a mistake into the numbering permanently, and the right repair is to the archived rows instead.
Read the archived directories and their CHANGE_LOG entries to establish which. State the evidence for the reading chosen, and do not raise the counter before that reading is settled.

GUARDRAILS. No live task is renumbered under any reading: renumbering a live task invalidates the task-number references in its own specs/ artifacts and in git history. The archive is append-only history -- if reading (b) holds, propose the archived-row correction as its own gated step with its evidence, never apply it in passing. Whatever lands, validate-state.sh --deep must be run before and after and both exit codes reported, so the change is shown to fix Check 12 without breaking another check. Leave the fallback allocation route in place and working; this task may restore --allocate-into but must not remove the fallback that callers currently depend on.

OUT OF SCOPE. The allocator's own concurrency design and git-commit-scoped.sh's cross-repository behaviour are separate standing records and are not touched here.
AMENDED 2026-11-03 (the reading is settled; evidence measured, not inferred). The two readings above are resolved in favour of (a) IN SUBSTANCE but NOT in remedy: the five rows are legitimate history, AND raising the counter is the wrong repair. Both halves are measured below.

EVIDENCE THAT THE FIVE ROWS ARE LEGITIMATE HISTORY (reading (a)'s premise, confirmed):
  - Four of the five carry real archived directories with real artifacts: specs/archive/{949,953,992,1054}_*. Row 998 (fmp_redesign_strict_temporal) has NO directory.
  - They are NOT duplicates of renumbered live tasks, which is reading (b)'s literal mechanism: each of the five project_name values appears exactly once across archived_projects and completed_projects. Reading (b) as stated did not happen.
  - They predate the current repository layout. specs/archive/1054_splitting_seed_consistent/.return-meta.json names Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean -- a path under Theories/, which does not exist in the current tree (FormalSystem/). Its started_at is 2026-05-01. The sibling directories carry the superseded reports/research-00N.md artifact naming rather than the current MM_{short-slug}.md convention. Created dates run 2026-02-28 to 2026-03-19; archived 2026-05-18. Row 1054's status is orphan_archived -- swept in as an orphan, not archived through the lifecycle.

EVIDENCE THAT RAISING THE COUNTER IS NEVERTHELESS THE WRONG REPAIR (the half reading (a) does not anticipate): the 844-1054 range is SPARSE, not occupied. Zero archived directories lie between 844 and 1054 apart from those four isolated outliers, against 86 directories densely filling 700-843. The counter never continuously occupied that range, so "a numbering range the counter lost track of" overstates it: five numbers are in use up there, and roughly two hundred are free.

CONSEQUENCE, MEASURED. Raising the counter past the archive max was applied, and it cost real numbering: an orchestration run's conclusion stage allocated 1055 and 1056 for two follow-up tasks whose natural numbers were 844 and 845. Both were renumbered by hand immediately afterwards (no artifacts had been written, no inbound dependency or parent edge existed, and the commit messages named no number, so the renumber was safe); they are now 844 and 845, and the counter sits at 1055, the minimum value satisfying Check 12 given an archive max of 1054. validate-state.sh reports Check 12 PASS, 11 passed / 0 failed. The next allocation will jump to 1055 again, so this is contained, not fixed.

THE DEFECT IS THE BOUND'S SHAPE, which neither reading named. state-write.sh --allocate-into refuses any counter not strictly greater than the combined active-plus-archive MAXIMUM. A max-based bound is conservative where a MEMBERSHIP-based bound is precise: the invariant that actually matters is that an allocated number is not already in use, and 844 and 845 were free -- allocating them collided with nothing. A smallest-unused-number allocation satisfies the real invariant, keeps numbering dense, and needs no change to the archive.

TWO CANDIDATE REMEDIES, for this record to choose between with its own evidence:
  (i) Make the allocation bound membership-based (smallest unused number across active and archive) rather than max-based. Touches agent-system/extensions/core/scripts/state-write.sh and validate-state.sh's Check 12, which must stay in sync per that script's own header; lands in the source store, never hand-authored under .claude/**. Leaves the archive untouched, which this record's own guardrail prefers.
  (ii) Relocate the five pre-reset-era rows to specs/vault/, which state-write.sh ALREADY excludes from the allocation bound for exactly this recycling rationale. This is a migration on append-only history, so under this record's guardrail it is a gated step with its evidence, never applied in passing.
Remedy (i) is the cheaper and more durable of the two and does not touch history; (ii) is recorded because the exclusion mechanism it uses was designed for this case and should be considered on its merits rather than passed over silently.

UNCHANGED BY THIS AMENDMENT: the guardrail that no live task is renumbered under any reading still governs every task that has written artifacts or is cited by number. The two tasks renumbered above were minutes old, artifact-free and uncited, which is why they were exempt; that exemption does not generalise.

---

### 818. Wrap directory rollup tables files lines cols
- **Status**: [NOT STARTED]
- **Task Type**: markdown
- **Topic**: repo-hygiene
- **Dependencies**: None
- **Parent**: Task 744

**Description**: Wrap the four directory-rollup inventory tables that need the cols=files-lines column set

MEASURED, do not re-derive. A prior sweep wrapped 23 READMEs under FormalSystem/ in BEGIN GENERATED inventory markers. Four READMEs were demoted from the clean-fit tier to report-only for one shared reason, distinct from every other deferral: their rows are SUBDIRECTORY rollups carrying numeric line totals, and the default cols=lines column set renders a subdirectory row as an em-dash placeholder, so wrapping them as-is would silently destroy the totals.

SCOPE, with the measured totals that must survive:
- FormalSystem/Metalogic/Expressiveness/README.md -- EFGames/ 11,800, GameTransfer/ 9,507, Kamp/ 77,714, Separation/ 926
- FormalSystem/Metalogic/WeakCanonical/README.md -- same shape, five subdirectory rows with numeric totals
- FormalSystem/Metalogic/Expressiveness/Kamp/README.md -- a `| | Files | Lines |` rollup, i.e. cols=files-lines shape with an empty leading header cell
- FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/README.md -- same empty-header-cell rollup shape

THE WORK IS A HEADER AND OPTION QUESTION, not a row question. Establish against the generator in scripts/check-module-invariants.sh -- by reading its marker option list and exercising it, not from memory -- whether cols=files-lines emits what these four tables need, and what header the wrapped block must carry. A four-column header rewrite is expected for the first two. The two Kamp rollups already carry a files-lines shape but with an empty leading header cell, so confirm whether the generator preserves that cell or requires a named one.

ALSO IN SCOPE: the earlier pass recorded that the `(N files)` phrases appearing inside some descriptions would need re-authoring if the column set changes, since a files count would then be a machine-owned column rather than prose. Resolve that duplication deliberately -- either re-author the prose or state why it stays.

VERIFY, do not assume. Confirm on a scratch copy before committing that every numeric total survives and every hand-written description is preserved byte-for-byte (use a key-sorted before/after diff; alphabetical re-ordering and thousands separators are expected regeneration effects). scripts/check-module-invariants.sh split_row is already escape-aware, so an inline pipe in a description must be written \| to survive. Then demonstrate coverage per newly wrapped block: corrupt one count, confirm INV FAIL names exactly that README, restore via the writer (--emit-inventory, never a pathspec checkout), confirm the diff is empty.

NON-GOALS. No change to the generator algorithm beyond using an option it already supports -- if cols=files-lines turns out not to cover these shapes, REPORT that and stop rather than extending the generator under this task. No Lean source changes. No hand-correction of counts in any table this task does not wrap.

---

### 817. Wrap remaining phantom row inventory tables
- **Status**: [NOT STARTED]
- **Task Type**: markdown
- **Topic**: repo-hygiene
- **Dependencies**: None
- **Parent**: Task 744

**Description**: Wrap the remaining count-carrying inventory tables under FormalSystem/ whose blockers are phantom or missing rows

MEASURED, do not re-derive. A prior sweep wrapped 23 READMEs under FormalSystem/ in BEGIN GENERATED inventory markers and left a measured Tier B bucket unwrapped, each with a named, re-verified blocker. At measurement time 29 of roughly 33 unwrapped Lines-bearing inventory tables under FormalSystem/ were stale, and the INV check in scripts/check-module-invariants.sh was green throughout because it fails only on a STALE WRAPPED BLOCK and never sees an unwrapped one. Wrapping is the opt-in that brings a table under that gate.

SCOPE: the Tier B READMEs whose blocker is a row-set mismatch, not a column-set mismatch:
- FormalSystem/Metalogic/BXCanonical/Chronicle/README.md -- phantom row HenkinDiscreteChain.lean; 8 live files carry no row
- FormalSystem/Metalogic/BXCanonical/Quasimodel/README.md -- phantom row EnrichedClosure.lean
- FormalSystem/Metalogic/Core/RestrictedMCS/README.md -- phantom row Deferral.lean
- FormalSystem/Metalogic/Expressiveness/Separation/README.md -- 10 phantom .lean rows and 2 phantom subdirectory rows (DedekindZ/, Hierarchy/); the directory now holds only Defs, KampTranslation, SemanticBridge, so the table describes a layout that has moved
- FormalSystem/Metalogic/Decidability/WitnessFamily/README.md -- upper table is rows=loose-shaped (no subdirectory rows for Compression/, Sharing/); lower table keys rows on Sharing/-prefixed paths the generator would not emit
- FormalSystem/Metalogic/BXCanonical/README.md -- fits apart from the pinned row ../BXCanonical.lean, which the generator keeps with refreshed numbers; left out of the earlier pass only because the pinned-row path was never exercised against the description-preservation check

PROCEDURE, established and verified by the earlier pass: a phantom row has no file, so its hand-written description has no destination and regeneration drops it. Decide per row whether the description is worth re-homing onto a live module or is simply obsolete, and state the decision -- do not let the generator silently drop prose. Then wrap and regenerate via `bash scripts/check-module-invariants.sh --emit-inventory`, and verify every surviving description byte-for-byte with a key-sorted before/after diff rather than a whole-file diff (alphabetical re-ordering and thousands separators are expected regeneration effects). Note that scripts/check-module-invariants.sh split_row is already escape-aware, so an inline pipe in a description must be written \| to survive.

DEMONSTRATE COVERAGE, do not assume it: for each newly wrapped block, corrupt one count, confirm INV FAIL names exactly that README, restore via the writer (--emit-inventory, never a pathspec checkout, per the shared-worktree discipline), and confirm the diff is empty.

NON-GOALS. No change to the generator column set or algorithm. No Lean source changes. Do not hand-correct counts in any table this task does not wrap -- report it instead, so the recurrence stays visible. The four READMEs whose blocker is a COLUMN-set mismatch (subdirectory rows carrying numeric totals that need cols=files-lines) are deliberately excluded here and belong to their own task.

---

### 804. Narrow termination syntax layer fanin
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: build-performance
- **Dependencies**: Task 803

**Description**: Determine whether FormalSystem/Metalogic/Decidability/Verified/Termination/ must sit downstream of the syntax layer, and narrow the fan-in if it need not.

THE OBSERVATION (measured 2026-10-15, this repo, from .lake/build-guard.stdout on a full guarded build): a batch touching FormalSystem/ProofSystem/Axioms.lean, FormalSystem/Semantics.lean and Syntax modules rebuilt 414 of 2848 jobs, costing 6354s of elaboration. Metalogic was 5649s of that across 306 modules. The decidability and termination subtree dominated: SubformulaProperty 1103s, Decidability.Tableau 476s, MintBound.MintPotential 360s, Termination.Fuel 238s. SubformulaProperty.lean imports FormalSystem.Metalogic.Decidability.Tableau and FormalSystem.Syntax.SubformulaClosure.Closure.

THE QUESTION. Paper-alignment work edits the syntax and proof-system layers constantly, and each such edit currently invalidates the most expensive subtree in the repository. Is that fan-in ESSENTIAL (the termination argument genuinely needs the syntax layer it imports) or INCIDENTAL (it imports a broad aggregator when a narrow one would do, or depends on a definition that could be relocated or abstracted behind a smaller interface)?

RESEARCH FIRST, and this may legitimately conclude NO CHANGE. A finding that the fan-in is essential, recorded with the import-path evidence that establishes it, is a successful outcome; do not manufacture a refactor to justify the task. Map the actual import paths from the termination subtree up to the syntax and proof-system layers, identify which specific declarations create each edge, and classify each edge as essential or reducible with evidence.

IF REDUCIBLE. Propose the narrowing before implementing it. Candidate shapes: import a narrower module instead of an aggregator; relocate a shared definition to a lower module both sides can import; introduce a minimal interface so the termination argument depends on a stable signature rather than on the syntax layer directly. Prefer the smallest change that breaks the invalidation path.

RELATIONSHIP TO THE PER-MODULE COST. Reducing this fan-in and reducing SubformulaProperty's own 1103s elaboration are complementary, not alternatives: the first reduces how OFTEN the expensive subtree rebuilds, the second how LONG it takes when it does. Neither subsumes the other.

NON-GOALS. No change to any statement that is proved. Zero new sorry. No new axiom dependency. No reorganization of modules outside the dependency path actually implicated by the measured evidence.

ACCEPTANCE. A written classification of every import edge from the termination subtree to the syntax and proof-system layers as essential or reducible, each with the declaration-level evidence establishing it; a recommendation (narrow, relocate, abstract, or leave as is) with reasoning; if a change is made, measured before/after rebuild scope for an edit to FormalSystem/ProofSystem/Axioms.lean, plus lake build green, check-module-invariants.sh ALL CHECKS PASSED and sorry_count 0.

---

### 803. Cut subformulaproperty elaboration time
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: build-performance
- **Dependencies**: Task 743
- **Research**: [803_cut_subformulaproperty_elaboration_time/reports/01_cut-subformulaproperty-elaboration-time.md]
- **Plan**: [803_cut_subformulaproperty_elaboration_time/plans/01_cut-subformulaproperty-elaboration-time.md]

**Description**: Cut the elaboration time of FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean, the repository's single largest rebuild cost.

MEASURED EVIDENCE (from .lake/build-guard.stdout, full guarded build, 2026-10-15, this repo): the module elaborates in 1103s (18.4 minutes) as ONE module. On that build 414 of 2848 jobs actually rebuilt, totalling 6354s of elaboration across those 414; Metalogic accounted for 5649s across 306 modules. Seven modules accounted for roughly 2500s of the total, and SubformulaProperty alone is about 17 percent of the whole incremental rebuild. Next worst: Decidability.Tableau 476s, Termination.MintBound.MintPotential 360s, Termination.Fuel 238s.

WHY IT HURTS REPEATEDLY. The module imports FormalSystem.Metalogic.Decidability.Tableau and FormalSystem.Syntax.SubformulaClosure.Closure, so any edit to the syntax or proof-system layer invalidates it. Paper-alignment work routinely edits FormalSystem/ProofSystem/Axioms.lean and FormalSystem/Semantics.lean, so this 18-minute module is woken by edits unrelated to decidability.

GOAL. Reduce elaboration time substantially while proving exactly the same results. Localize hotspots with lean_profile_proof BEFORE changing anything, and record before/after per-declaration timings as evidence rather than asserting an improvement. Suspects to confirm rather than assume: simp set blowup, decide on a non-trivial decidable instance, unfolding of large structures, Nat/Int arithmetic normalization. Candidate remedies: replace simp with targeted rewrites, extract heavy sublemmas into their own declarations, mark expensive defs irreducible where sound, scope set_option maxHeartbeats.

NON-GOALS. No change to any statement that is proved. Zero new sorry. No new axiom dependency (verify with #print axioms before and after). No weakening of the termination argument.

ACCEPTANCE. A measured, reported reduction in this module's elaboration time with before/after numbers from the build log or lean_profile_proof; lake build green; check-module-invariants.sh ALL CHECKS PASSED; sorry_count 0; axiom profiles unchanged for every declaration in the module.

---

### 787. Lake unguarded reader lock audit
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: decidability
- **Dependencies**: Task 743
- **Parent**: Task 786

**Description**: Audit the remaining lake-invoking scripts for the unguarded .lake read hazard, and take the shared build-guard lock wherever a per-script judgment says it belongs.

WHY THIS EXISTS. A sibling record established, by measurement, that scripts/check-evidence-probes.sh read .lake artifacts while a concurrent build rewrote them, producing `object file '.../FormalSystem/<Module>.olean' ... does not exist` errors on four consecutive wired probes. Those errors were then misread as four independent probe rots, which cost two Reasoned Exclusions and a full research/plan/implement round before re-measurement showed every probe had always compiled. The cost of this hazard is measured, not hypothetical. That script now takes an flock on `$REPO_ROOT/.lake/build-guard.lock` and distinguishes an environment failure from probe rot in its output.

THE SURVEYED CONDITION, as measured at filing. Across scripts/ and .claude/scripts/, only three files reference `build-guard.lock` at all: scripts/check-evidence-probes.sh (just hardened), scripts/check-module-invariants.sh (the precedent, which documents its rejected alternatives in place at its C1 block), and .claude/scripts/lake-build-guard.sh (which publishes the lock path). Every other file that invokes `lake env lean` or `lake build` takes no lock.

CANDIDATES, AND WHY EACH NEEDS ITS OWN JUDGMENT RATHER THAN A BLANKET EDIT. Do not add a lock to all of these on sight. Three distinct shapes appear among them and they do not want the same treatment:

1. UNGUARDED READERS -- the exact shape just fixed. scripts/typst-module-map.sh invokes bare `lake env lean`. A reader that elaborates against .lake while another process rewrites it is the hazard verbatim; this is the strongest candidate.

2. SCOPED BUILDERS -- scripts/export-training-data.sh runs `lake build dataset_generator proof_extractor`. Note the direction of the hazard here: a SCOPED build is precisely what leaves an import-closure tail stale for a later reader, so such a script is a plausible CAUSE of the fault rather than only a victim of it. Decide whether it should hold the lock (serialising it against readers) on that basis.

3. PROSE-ONLY MATCHES -- .claude/scripts/lean-sorry-census.sh and .claude/scripts/plan-file-scope-harvest.sh mention `lake build` / `lake env lean --run` in comments and docstrings. Verify whether each actually invokes lake at runtime before treating it as a candidate at all; a grep hit in a comment is not an invocation.

Also present in the initial survey and needing the same per-file determination: scripts/typst-sync-check.sh, scripts/typst-machine-appendix.sh, scripts/typst-status-counts.sh, .claude/scripts/lean-comparator-run.sh, .claude/scripts/lean-comparator-landrun-shim.sh, .claude/scripts/claude-refresh.sh. Re-derive this list rather than trusting it: the survey was a grep for `lake env lean`/`lake build` over scripts/ and .claude/scripts/ and may have both false positives (comments) and gaps.

REUSE THE EXISTING PRECEDENT; DO NOT INVENT A SECOND LOCK. The lock is `$REPO_ROOT/.lake/build-guard.lock`, the path .claude/scripts/lake-build-guard.sh publishes. scripts/check-module-invariants.sh's C1 block and the now-hardened scripts/check-evidence-probes.sh are both working implementations of the shape: `flock -n` first, then a bounded and announced `flock -w`, fd held to process exit, audible degradation when flock is unavailable. Follow them and cross-reference their rejected-alternatives notes rather than re-litigating the design.

SOURCE-STORE BOUNDARY. Any candidate under .claude/scripts/ is a deploy artifact. Resolve the source store via .claude-extensions.json's source_dir and edit the mirrored path under agent-system/extensions/<name>/scripts/ -- never hand-author under .claude/** directly, which the next regeneration silently wipes.

DELIVERABLE. A per-script determination for every surveyed candidate -- lock added, or explicitly ruled out with the reason stated where a future reader will find it (not only in a commit message). Each script that gains the lock keeps its existing exit-status contract and still passes its own gate. No probe file and no manifest array is touched by this record.

WHAT WOULD MAKE THIS A COMPLETE RESULT EVEN IF NO LOCK IS ADDED. A reasoned finding that some or all remaining candidates genuinely do not need the lock -- because they build rather than read, run only in CI where nothing is concurrent, or never invoke lake at runtime -- is a complete outcome, provided the reasoning is recorded per script. Closing a hazard by establishing it does not apply is a result, not a shortfall.

---

### 781. Phase5 hoist kernel neutral decision
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Parent**: Task 716

**Description**: Decide whether the Phase 5 inner-fixpoint hoist in FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean should stay. A zero-rebuild A/B measured it NEUTRAL under the kernel (25.9 s OLD vs 24.4 s NEW on certA's backward fixpoint under decide -- 1.06x, inside variance) and roughly 25 percent WORSE at the small embedded witness, against 5.4x BETTER at certA. It is landed and proved equal via unconditional equality lemmas, so correctness is not at issue; the question is whether its justification (resting on the hard certificate alone) warrants keeping the added decomposition. Evidence: parent task issue log entry iss_1791925368675_oyqhCa, and the A/B method recorded at iss_1791925368699_dlHTwK.

---

### 763. Ladder lift decidability corollary
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 761, Task 762

**Description**: AMENDED 2026-10-11 (index deletion): the finite cell index this record assembled its object from is refuted and deleted below; see specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md.

STATEMENT (library, research-first; new module `RaySummary/Lift.lean`). The (W) row's lift from one seam to validity — "one presentation-level object witnesses ¬ PlusValidZTime φ for some regular ℤ-model, history and time" — and obligation (3)'s second half ("every seam but the one"):
  `theorem not_plusValidZTime_iff_ladderRefutes (φ : PlusFormula) : ¬ PlusValidZTime φ ↔ ∃ (Q : Type) (_ : Fintype Q) (_ : DecidableEq Q) (lab) (step) (pend) (fwd : ∀ t x, ∃ y, RladAdm step pend t x y) (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x), Fintype.card Q ≤ objBound φ ∧ LadderCons φ lab step pend ∧ LadderRefutes φ lab step pend` (`Adm` is a CARRIER restriction defined in `RaySummary/LadderModel.lean` — `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` — not an object-side hypothesis; the object ranges over the admissible carrier, with its seriality `fwd`/`bwd` stated over `RladAdm` on that carrier)
(→), completeness: a refuting regular ℤ-model has cells bounded by `anchorCells_ncard_le`, per-cell presentations by (C)'s general row (`exists_hitPresented`) — and the step from finitely many CELLS to finitely many ladder STATES per cell has NO support: `ladderCell_stabilizes` is REFUTED for every bound (`specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`: `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted`; the gap n − c is observable) and is DELETED from this assembly. How a refuting model's finitely many cells (`anchorCells_finite`, `anchorCells_ncard_le`, untouched) are assembled into ONE finite ladder object — a computable index of WHICH cell a ladder state has — is an OPEN SUB-PROBLEM of this record: recorded here, not solved, and never re-stated over a concrete substitute (the candidate carrying a clipped gap coordinate is research-level and unproved). (←), soundness: `ladderRealized` at the refuting cell gives a regular ℤ-model (`ladderFrameAdm_isRegular`, the frame on the admissible carrier; `ladderFrame` has no instances, `no_fwd`/`no_bwd_of_idle`), a history and a time where φ fails. Depth k = 1 throughout.

THE COROLLARY — THE AIM — IS STATED HERE AND NOWHERE EARLIER: `Decidable (PlusValidZTime φ)` by bounded enumeration over objects of size ≤ objBound φ (finitely many on `Fin n`; `LadderCons`/`LadderRefutes` decidable on a Fintype, as `decidableAnchorConsFin` already is on a concrete finite object). `Decidable (PlusValidZTime` has zero statement-level occurrences in the tree today (14 hits, all prose denials); no predecessor record may state it.

STATUS. Not costable until both predecessors have landed shapes and until the open index sub-problem above is resolved; the research phase re-derives the statement from `LadderRealize.lean` and `HitComplete.lean` as landed. Honest outcomes: landed; or [BLOCKED] on whichever predecessor did not close or on the open sub-problem — never sorry, axiom, vacuous definition, or a decidability claim from the semi-decidable ∃-object form without the bound (the README: without the bound the composition theorem is "at best semi-decidable — and NOT Decidable (PlusValidZTime φ)").

GUARDRAILS: (a) the ladder object is a time-axis object over the closure alphabet; (b) its slice is infinite — the object bounds cells and deadline classes, never the fibre, and no finite-fibre assumption may be introduced to make the enumeration finite (the bound comes from counts); (c) `objBound φ` is a count (its shape is part of the open sub-problem; no figure exists) and the corollary is a `Decidable` instance, not a complexity statement — the held 2EXPTIME ceiling is neither cited nor approached; (d) zero debt: the enumeration is the tree's own, no external decidability theorem, no cslib require; (e) if T4/T5 land forward-only the lift is forward-only and says so — nothing beyond `Probe719Backward.pastStab_iff_allBwdPathsMeet` is claimed about ⊡(Pp). Dispatch with --lit (HWZ 2000 / GKWZ 2003 indexed, orientation only).

FILE SCOPE: new `Lift.lean` plus the shared library set. Durable anchors only outside specs/**. Cross-set collisions left to the admission gate: 744, 410. Logical edges on T4 and T5.

NOT COSTABLE, and why: statement fixed by T4/T5. Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Sections C, D and H6.

---

### 761. Ladder realization theorem
- **Status**: [HOLD]
- **Held**: 2026-11-04
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 760, Task 775, Task 805, Task 806, Task 819, Task 820
- **Research**: [761_ladder_realization_theorem/reports/08_rk-bounded-representative-refutation.md]
- **Plan**: [761_ladder_realization_theorem/plans/11_idle-insertion-cascade-restatement.md]
- **Summary**: [761_ladder_realization_theorem/summaries/11_idle-insertion-cascade-restatement-summary.md]

**Description**: AMENDED 2026-10-18 (presentation chosen): the cell presentation is (a), the set-valued per-state datum — the maximum certAdm-certified subset D of Q × ClType φ × K, with ladderRealized the fibre equation and the factorization lemma for K its corollary; no tuple index is to be stated at any parameters (K is a carrier coordinate whose parameters are outputs of the counter-lift lemma). The realization theorem now waits on the counter-lift lemma (obligations (2) and (3) jointly), filed as task 820, gated before any sufficiency attempt; the label-level results of the certificate rounds are region-interior (wired probe specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean) and compose only through that lemma. Route A is not entered. See specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md. All six declared edges (760, 775, 805, 806, 819, 820) are DISCHARGED: 760/775 archived, 805/806 completed, 819 the presentation decision, 820 the counter-lift gate table — which compiled with BOTH decision gates COLLIDING (`gate9_col_cell_eq`, `gap_shift_cell_eq`), so the lemma's two halves are licensed in PUMPING form and no open edge remains. The positionwise statement shape is refuted for every finite counter quotient (`no_positionwise_lift`). Live route: specs/761_ladder_realization_theorem/plans/01_ladder-realization-presentation-a.md.

AMENDED 2026-10-12 (realization blocked): the realization theorem is [BLOCKED] on the open index sub-problem — `hitOf (truncate B …)` is a residue of the deleted index (`truncate` is defined nowhere; its only reading is `Q × Fin (B+1) × Fin (B+1)`) and is withdrawn from the statement line; every per-cell soundness statement presupposes a finite index of ladder states (`cell_ne`; the `Count` clause; the `stab` clause's collapse of any per-state labelling), and the `box`/`stab` acceptance clause presupposes it too; the ladder's structural liveness is FORWARD-ONLY (wired probe `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`: `gPast_isPath`), so a ladder bundle replaces `ulive` only and keeps `slive` — "`ulive`/`slive` replaced" reads `ulive` replaced, `slive` retained. No library module; the index-free run-layer half is a user option (R2) not taken. See specs/761_ladder_realization_theorem/plans/01_ladder-realization-blocked-probe.md.

AMENDED 2026-10-11 (carrier repair): the frame this record is stated on is the admissible-carrier frame of RaySummary/LadderModel.lean; see specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md.

STATEMENT (library; new module `RaySummary/LadderRealize.lean`). Run-layer phase 2's soundness half (object → model), the ladder analogue of `Realize.lean`'s `Cons`/`cons_localRun`/`presented_modelOf`, stated at the HIT level per ladder cell:
  `structure LadderCons (φ : PlusFormula) (lab) (step) (pend) : Prop`  -- `Cons`'s fields with the liveness fields `ulive`/`slive` replaced by the ladder's structural liveness (c strictly decreases while pending, by `Count`), and with the box/stab letters PINNED per cell by the anchor layer's equations: `lab q (box ψ)` is one global bit (`box_mem_tpOf_iff`), the stab letter at `(q, c, n)` is that cell's bit (`stab_mem_tpOf_iff`); `anchorCons_anchorCells` is the completeness side of exactly those equations
  `theorem ladderCons_localRun …`  -- every ladder run satisfies the run conditions
  `theorem ladderRealized … : cellAt (ladderModel …) φ (t, ⟨(q, c, n), h⟩) z = {T | ∃ S : ClType φ, typeOfCl S = T ∧ (q, S, κ (c, n)) ∈ Dmax …}`  -- the FIBRE EQUATION over the maximum certAdm-certified subset `Dmax` of `Q × ClType φ × K` (presentation (a)). The earlier `HitCl … = ↑(hitOf (truncate B …) … (clNow φ) k)` line is WITHDRAWN: `truncate` is defined nowhere and its only reading is the refuted index, so that line named no object. Per ladder cell, for ALL φ, box/stab letters INCLUDED, the cell being `cellAt (ladderModel …) φ (t, ⟨(q, c, n), h⟩)` on the world state `ℤ × LadderState Q pend` (the `ℤ` component is invisible to `cellAt`, `cellAt_eq_cellAt`, but must be written). NO finite index of which cell a ladder state has is provided by any predecessor: the index `Q × Fin (B+1) × Fin (B+1)` is refuted (`ladder-cell-refutation.lean`: `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted`) and is DELETED here; which cell a ladder state has is an OPEN SUB-PROBLEM, recorded and not re-stated over any substitute. The SET of cells stays finite and bounded (`anchorCells_finite`, `anchorCells_ncard_le`)
The box/stab clause is the acceptance criterion: it is where obligation (3)'s first half ("(S) beyond its landed corner": box/stab-bearing φ) lands, by the README's own assignment of that limitation to (W). No standalone (S) record exists for it (agent decision D1, re-openable by /revise).

WHY HIT-LEVEL, WHY THIS FRAME. Two machine-checked facts (wired probe `w-soundness-shape-refuted.lean`): WIDTH — `Probe747.modelOf_incomplete`: `modelOf` on any `Cons` presentation validates `Φ.neg` while `¬ PlusValidZTime Φ.neg`, whatever clauses are added, because `ofSlicedStep` on a Fintype has finite width; COLLAPSE — `Probe747.stab_iff_of_presented_nowUnique`: at a trace-level `Presented` seam with `nowUnique`, ψ ↔ ⊡ψ for every closure formula, so trace-level realization cannot witness any ⊡-refutation. Hence the hypothesis is `HitPresented`-shaped per cell and the frame is `ladderFrameAdm` on the admissible carrier `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` (`RaySummary/LadderModel.lean`; slice infinite — `(q, 0, n)` is admissible for every `n`, `Rlad_slice_infinite` one level down; regular by `ladderFrameAdm_isRegular`), with the model `ladderModel` reading the object component; `ladderFrame` itself has no instances (`no_fwd`, `no_bwd_of_idle`) and stays beside it, untouched. `presented_modelOf` is untouched and not re-proved.

DEPTH. `1 ≤ k` stated; the consumer depth is k = 1 (every landed bridge carries `1 ≤ k`; the closure alphabet makes nesting visible through letters).

CONTINGENCY. If the theorem does not close, mark [BLOCKED] with the goal state recorded; never sorry, axiom, vacuous definition, a trace-level hypothesis, or any finite-fibre/finite-width assumption. T3/T4 keep standalone value whatever T2 reports (the HWZ 2000 Theorem 14 ⇐ direction for this semantics — a literature description that sources no claim).

GUARDRAILS: (a) closure-indexed letters over the time axis, box/stab bits included; (b) infinite width, no fibre bound; (c) no upper bound — B and the presentation size are counts; (d) zero debt: no Büchi/MSO lemma cited in place of a proof, no cslib require; (e) if the landed form is forward-only, say so; no device-discrimination claim.

FILE SCOPE: new `LadderRealize.lean` plus the shared library set (`RaySummary.lean`, `FormalSystem.lean`, `KTypeSummaryAxiomTest.lean`, `check-module-invariants.sh`, `docs/theorem-index.md`, RaySummary README, `typst/generated/status.typ`). Durable anchors only outside specs/**. Cross-set collisions left to the admission gate: 744 (README, invariants), 410 (status.typ). Logical edge on T3.

NOT COSTABLE, and why: T3 landed no bound (its stabilization lemma is refuted); sized by the open index sub-problem and by how much of `Realize.lean` (1004 lines) transfers; the README records it has no figure. Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Sections A, C and H4.

---

### 743. Typst sync check1 namespace resolution
- **Status**: [PLANNED]
- **Task Type**: general
- **Topic**: repo-hygiene
- **Dependencies**: None
- **Research**: [743_typst_sync_check1_namespace_resolution/reports/01_namespace-resolution-feasibility.md]
- **Plan**: [743_typst_sync_check1_namespace_resolution/plans/01_check1-namespace-resolution.md]

**Description**: Teach typst-sync-check.sh Check 1 to resolve namespaced Lean declarations, or rule on the whitelist-vs-docstring convention it currently depends on

MEASURED 2026-10-08. `bash scripts/typst-sync-check.sh` FAILS Check 1 (backtick name resolution) on exactly one finding: VIOLATION `FormalSystem.Semantics.validZTime_iff_validInt` -- "identifier not found in any *.lean file under the Lean source roots", cited from typst/FormalFoundations.typ:790. Three separate implementation dispatches during an /orchestrate run reported it and each correctly declined to repair it as out of scope.

THE CITATION IS CORRECT; THE CHECK CANNOT RESOLVE IT. `theorem validZTime_iff_validInt` is declared at FormalSystem/Semantics/IntTransfer.lean:338, inside `namespace FormalSystem.Semantics` (opened line 70, closed line 353), so the fully-qualified name the manual cites is the right name. Check 1's dotted-identifier branch does a LITERAL grep for the full dotted string and performs no namespace resolution, so a correctly-cited namespaced declaration fails unless its full dotted name happens to appear verbatim somewhere in a .lean file.

WHY THAT IS FRAGILE, measured rather than asserted. Every other fully-qualified FormalSystem.* citation sampled from the typst tree DOES get a literal hit (FormalSystem.Metalogic.BXCanonical, FormalSystem.Metalogic.Conservativity, FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime, FormalSystem.ProofSystem, FormalSystem.ProofSystem.Axioms, FormalSystem.ProofSystem.DerivedAxioms) -- because the name appears in a namespace declaration or a docstring cross-reference, not because the check resolved anything. The manual's citations are therefore validated by coincidence of source text: a correct citation passes or fails depending on whether some docstring mentions it.

THREE ROUTES, none obviously right, to be decided rather than assumed. (1) Teach Check 1 to resolve a dotted name against open namespaces -- correct, but the script is deliberately BUILD-FREE (no lake, no oleans, so it can run in a fast pre-commit gate), so resolution without a build means parsing namespace/end nesting. (2) Whitelist the name in typst/sync-check-whitelist.txt -- the sanctioned escape hatch, BUT it holds 89 entries and ZERO dotted FormalSystem.* entries, and its documented categories are "type-signature / turnstile illustrations" and "typst/template API names (not Lean identifiers)", so a valid-but-unresolvable declaration would set a new precedent and mask a real gap. (3) Change the manual to cite the short name, which does appear literally -- cheapest, but loses the fully-qualified form in a reference manual and does not stop the next namespaced citation from failing.

A FOURTH, if route 1 is rejected: add the fully-qualified cross-reference to IntTransfer.lean's own module docstring, making the citation resolve the same way the other six do. Cost: touching a .lean file changes formalsystem-line-count (347522 at measurement) in typst/generated/status.typ, forcing a status.typ regeneration, and that docstring's existing bullet list uses SHORT names throughout, so a dotted entry would be stylistically inconsistent there.

ACCEPTANCE. Either Check 1 resolves the citation and `bash scripts/typst-sync-check.sh` exits 0, with the chosen mechanism's limits stated where the next citation author will see them; or a recorded verdict naming which route was taken and why the others were rejected, with the finding left visible rather than silently suppressed. If the whitelist route is chosen, say explicitly that it is suppressing a resolution gap and not certifying the name.

NON-GOALS. No change to Check 2 (status.typ counts), Check 2b (module map) or Check 3 (machine appendix). No change to what any generator emits. Do not make the script require a built library -- its build-free property is load-bearing for the pre-commit gate.

BACKLOG RECONCILIATION, verified 2026-10-08 against all 51 open tasks in this repo. No open task covers Check 1 or phantom-citation resolution. Nearest records: 731 (plan-time file_scope harvest must include generated surfaces a .lean edit forces -- adjacent because it also concerns typst-sync-check.sh, but its subject is scope DECLARATION and its NON-GOALS explicitly exclude generator changes) and 741 (agent-system context extensions; mentions typst-sync staleness only as deploy-freshness context). Neither overlaps this.

UPDATE 2026-10-10: THE REPRO ABOVE NO LONGER FIRES; THE MECHANISM GAP IS UNCHANGED.

`scripts/typst-sync-check.sh` now exits 0 (all four checks green). That is NOT because Check 1 learned namespace resolution — it is because the single citation was rewritten at `typst/FormalFoundations.typ:790` from the fully-qualified `FormalSystem.Semantics.validZTime_iff_validInt` to the module-path-plus-leaf form `` `validZTime_iff_validInt` in `Semantics/IntTransfer.lean` ``, which resolves on both halves under the existing rules (the path through the path-exists branch, the bare leaf through the literal grep). Commit: `ci: clear the two standing red gates (PlusRayFibre layer row, stale typst citation)`.

WHAT THIS CHANGES FOR THIS TASK. The measured finding above is no longer reproducible by running the gate; anyone starting here will see a green gate. The underlying defect is untouched: Check 1's dotted-identifier branch still does a literal grep with no namespace resolution, so any future correctly-cited namespaced declaration will fail the same way unless its full dotted name happens to appear verbatim in a docstring. The sibling citation `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`, in the same paragraph, resolves ONLY by that accident — the string appears at `FormalSystem/Metalogic/Decidability.lean:181`. That accidental dependency is the clearest remaining evidence and should be the new starting point.

TO REPRODUCE ON DEMAND: reintroduce any fully-qualified declaration name whose dotted form appears in no `.lean` file, or delete the docstring line at `Decidability.lean:181` and re-run the gate.

THE QUESTION THIS TASK STILL OWNS, now sharpened by having three resolution styles live in one paragraph: decide which citation style the manual is entitled to use, and make the checker honour it. Option (a) teach Check 1 real namespace resolution (match a dotted name against `namespace` prefix plus declared leaf); option (b) rule that the manual cites module-path-plus-leaf and document that, making the two surviving fully-qualified declaration citations non-conforming; option (c) keep the literal grep and accept that fully-qualified citations depend on a docstring mentioning them, which is the status quo and is what made this a recurring finding. Option (c) is the one the evidence argues against.

---

### 734. E4 mosaic stabsaturated mixed germ probe
- **Status**: [HOLD]
- **Held**: 2026-10-17
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 733, Task 805
- **Research**: [734_e4_mosaic_stabsaturated_mixed_germ_probe/reports/01_e4-stabsaturated-mixed-germ-probe.md]
- **Plan**: [734_e4_mosaic_stabsaturated_mixed_germ_probe/plans/01_e4-stabsaturated-mixed-germ-probe.md]
- **Summary**: [734_e4_mosaic_stabsaturated_mixed_germ_probe/summaries/01_e4-stabsaturated-mixed-germ-probe-summary.md]

**Description**: Run experiment E4: decide StabSaturated on the Bool fixture's mosaic set, and acquire the Hodkinson-Reynolds Handbook sections

WHY THIS EXISTS. Route R2 -- mosaics and quasimodels -- is the rank-2 route to decidability of L+ over discrete time, behind the seam-gluing route R1 and ahead of the closed and low-ranked alternatives. Its amalgamation precondition is already FREE: `paste` glues two mosaics agreeing at a shared germ, choice-free and with uniqueness, exported as `amalgamate` and `amalgamate_unique`. What gates R2 is a single decidability question that the landed probe fixes as a `Prop` and proves only in a degenerate corner, plus two Handbook sections absent from the corpus. The review named this experiment E4 and left it "open for the next round to attack by name". It was never filed.

THE GATE, precisely. `Probe718Mosaic.StabSaturated` is proved only by `stabSaturated_of_sameState` -- the SAME-STATE corner. R2's hypothesis is that `StabSaturated` is decidable on finite mosaic sets with MIXED germ states, under `[F.IsRegular]`, and that a saturated-set existence theorem holds for L+. Neither is established. Re-verify both declaration names against the tree before relying on them; this description's reading is from 2026-10-05.

WHAT TO DELIVER, in two parts.
(1) The probe: decide `StabSaturated` on the two-state Bool fixture's mosaic set at `box-dot(Fp)`, with MIXED germ states rather than the same-state corner. This is the cheapest test of R2's load-bearing hypothesis.
(2) The sources: the Hodkinson-Reynolds Handbook of Modal Logic sections 5.10 and 5.11 bodies are ABSENT from the corpus, which is why R2 cannot be promoted on textual grounds no matter how the probe comes out. Acquire and ingest them. R2's standing cannot be settled by a probe alone.

THE FALSIFIER, which is a valid outcome. A finite mosaic set, with mixed germ states, on which `StabSaturated` is FALSE yet every finite coherence condition holds. That would close R2 the way filtration was closed, and closing a route on evidence is a complete result -- not a failed task. Record it rather than working around it; the no-weakening rule for wired probes applies.

HARD CONSTRAINTS. No complexity claim. Do not file a fourth certificate class on the strength of anything found here: any certificate class presenting finite fibres is already refuted by `Probe710.not_finite_width_fmp`, and R2 is a quasimodel route, not a certificate class. Do not promote R2 above R1 on probe evidence alone; ranking is the review's, and the Handbook sections are part of what any re-ranking would rest on.

LITERATURE. Part (2) is source acquisition; run with `--lit`.

SCHEDULING. Wiring into `scripts/check-evidence-probes.sh` collides with the declared file_scope of tasks 720 and 725, and with the two sibling probe tasks filed alongside this one. Run in a separate cycle from each of them.

ACCEPTANCE. One probe file under `specs/evidence/seam-gluing-ray-product/` compiling under `lake env lean` and wired into `scripts/check-evidence-probes.sh`, whose header states whether `StabSaturated` is decidable on mixed germ states and what that does to R2's standing; plus the two Handbook sections present in the Literature index with an index entry. Either half landing without the other is a [PARTIAL], not a completion.

---

### 714. Evaluate full labels in sliced certificate
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 716

**Description**: Evaluate removing the TailStable junk-position obstruction at its root by carrying full labels in the sliced certificate. Research report 06_tailstable-backward-conjunct-repair.md established that undischargeable snce positions are determined by the certificate position space posAt, not by the witness family: at target bot-S-bot the closure is {bot S bot, bot} with no state shape, so posAt is the same two-label set for every certificate and LocalCoherentLab forces every label of every certifying family to be empty. Because posAt admits every coherent closure-subset agreeing with slab on state shapes only (atom/box/stab) while temporal obligations are pinned by nothing, carrying FULL labels in the certificate rather than only the state part would make posAt a singleton, so no junk position could exist for either obligation direction and arguably neither liveness filter would be needed. This was option 3 in the repair decision; the chosen repair was option 1 (mirror the filter, landing as TailStableMirror/bwdLiveAt). Option 3 was NOT rejected on the merits, only deferred, because it costs the decidable search that FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Check.lean is built around, i.e. most of Stage 2 again. Determine whether the obstruction can be removed at the root this way, with refactoring permitted as needed to obtain the best result. The central question is whether decidability of the certificate check survives full labels, and if not, whether a weaker label refinement makes posAt small enough to drop both filters while keeping the search decidable. Compare against the landed option-1 design: with full labels, both TailStableMirror and the forward filter would become deletable and the symmetric two-filter shape in Stable.lean would collapse. Also settle whether the superset failure mode (the Fixture.cert pre-period, repaired by absorption rather than by any filter) likewise disappears under full labels or survives independently.

---

### 713. Formalize ctl star reduction 2exptime lower bound
- **Status**: [HOLD]
- **Held**: 2026-10-03
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None

**Description**: OPTIONAL, FILED NOT SCHEDULED -- AND LOAD-BEARING AS A CHECK. This task stays unscheduled: status HOLD (user ruling 2026-10-03; prior_status not_started), dependencies [], nothing depends on it. What has changed since it was filed is the claim that "none of the L-plus programme's recommendations rest on it." That is no longer accurate. Its 2EXPTIME lower bound -- ARGUED, not formalized -- is the sanity ceiling that three live records cite against any proposed decision procedure for L-plus. It is load-bearing as a check even while unproved.

ITS ROLE: THE SANITY CEILING. Three records USE this task's argued lower bound as the bound-sanity check -- nothing cheaper than 2EXPTIME is a credible decision procedure. All three were re-verified against the tree on 2026-10-07 (task 738), at their archive locations:

1. specs/archive/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md (archived), the "Complexity sanity check" bullet at line 258: "the CTL* 2EXPTIME-hardness reduction (filed, argued in both directions) is the lower bound; determinization-based upper bounds are doubly exponential, which is consistent. Any proposal cheaper than 2EXPTIME is prima facie wrong. No bound committed."

2. Task 719's description (ray layer, seam gluing and stab fibre; completed and archived at specs/archive/719_ray_layer_seam_gluing_and_stab_fibre, record in specs/archive/state.json -- now provenance rather than a live document), Deliverable 5: "DO NOT LAND A COMPLEXITY CLAIM; the CTL-star 2EXPTIME lower bound is the sanity check on any proposed bound."

3. specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md (archived) section 3.1 (L-plus routes forward), line 147 -- its Section C ruling on this task is at line 183: "the CTL* 2EXPTIME-hardness argument (task 713, ARGUED) is the lower bound on any proposed procedure; nothing cheaper is credible; no bound is committed here."

ARGUED, NOT FORMALIZED -- AND EVERY CITING RECORD MUST SAY SO. The bound is an argument in prose, not a machine-checked theorem. No Lean declaration establishes it; there is no CTL-star syntax or semantics in the tree to state it against. Every record that cites it must describe it that way, with the ARGUED qualifier attached, exactly as the three records above do. A citation that presents the bound as established, or that drops the qualifier, is a defect in that record.

NO UPPER-BOUND CLAIM MAY LAND FROM THIS TASK. The programme commits to no complexity bound. This task's content is a LOWER bound used as a ceiling: it rules proposals out, it never certifies that any procedure achieves a cost. Deriving or landing an upper-bound claim from it -- in this task's artifacts, in a citing record, or in the write-up -- is a defect, not a result. The asymmetry is the point: a lower bound says "nothing cheaper is credible", it does not say "this much suffices."

GOAL. Raise the 2EXPTIME-hardness of L-plus Z-time validity from ARGUED to MACHINE-CHECKED. The argument is given in both directions in specs/archive/706_lplus_finite_model_property_and_completeness/reports/01_lplus-finite-model-property-research.md section Q4 ("The true order of the state bound"), completing what task 703's round-2 report argued in one direction only -- now archived at specs/archive/703_lplus_compression_and_completeness/reports/02_semantics-first-compression-research.md section 1.6 ("The complexity picture").

THE REDUCTION. Translate CTL-star by A |-> stab and X |-> bottom U ., with non-strict U rendered as e or (g and (g U e)). FORWARD: a rooted total Kripke structure becomes bi-serial by adding one fresh state with a self-loop and an edge to the root, which leaves forward paths from the original states unchanged; stab at (sigma, t) with sigma t = w ranges over histories through w, whose futures are exactly the forward paths from w, and the translation is pure-future so its truth depends only on the future (truth_congr_agreeFrom). BACKWARD: from a Z-model of the translation at (sigma, t), the Kripke structure of the state graph forward-reachable from sigma t satisfies the CTL-star formula at sigma t, by the same two facts read backwards. CTL-star satisfiability is over arbitrary, possibly infinite structures, so no finiteness is needed anywhere.

WHAT IT WOULD BUY. Formalization would turn the ceiling from an argued check into a theorem-backed one: the sharpest available limit on how good ANY certificate class can be. As task 706's Q4 and the archived 703 round-2 section 1.6 record the consequence, with the reduction a theorem no complete certificate class with singly exponential, polynomially checkable certificates could exist for full L-plus without a complexity-theoretic surprise.

CANONICAL WORDING OF THE CONSEQUENCE (quote this, verbatim, in any record that repeats it). L-plus Z-time validity -- equivalently, by negation, L-plus Z-time satisfiability -- is 2EXPTIME-hard by the CTL-star reduction. ARGUED, NOT FORMALIZED: no Lean declaration establishes it. CONSEQUENCE, stated for NON-VALIDITY: if every non-valid formula had a certificate of size singly exponential in the closure size, checkable in time polynomial in the certificate's size, then non-validity (satisfiability of the negation) would be in NEXPTIME and, equivalently, validity would be in co-NEXPTIME; hence 2EXPTIME would be contained in NEXPTIME, equivalently in co-NEXPTIME, since 2EXPTIME is closed under complement. That containment is not refuted but is widely disbelieved. The two class names are the same statement read from opposite sides of the complement: a record may name either, but must say which problem it is placing (NON-VALIDITY with NEXPTIME; VALIDITY with co-NEXPTIME). This is a LOWER bound used as a ceiling: nothing cheaper than 2EXPTIME is credible. It says nothing about any cost sufficing for L-plus and must never be restated as an upper bound. Sources: 706 Q4 (validity / co-NEXPTIME reading) and 703 round-2 section 1.6 (satisfiability / NEXPTIME reading), reconciled 2026-10-07 (task 738): the apparent divergence was one of presentation, not content.

WHAT IT COSTS. A CTL-star syntax and semantics must be added to the tree, which is substantial standalone work the programme otherwise has no need for. Task 706 rates the risk that the reduction has a gap as LOW (its R4) and records it as affecting the complexity picture only.

KEEP-OR-ABANDON IS A PHASE 0 USER RULING, NOT MADE HERE. This revision records the task's role; it does not decide the task's fate and does not schedule it. The decidability-programme review's Section C (specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md, Section C at line 220) restates the choice as the user's: keep this as a write-up note, or abandon it. RECOMMENDATION ONLY, not a decision: keep it as a write-up note, because it is load-bearing as a check even while unproved -- abandoning the record would leave the three citing documents pointing at nothing. If the ruling is to abandon, the three citing records need their sanity-check bullets re-sourced to the argument's actual homes (706's Q4 and the archived 703 round-2 section 1.6) rather than to this task.

---

### 664. Ingest cmiel kuhlmann ball space source
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: literature
- **Dependencies**: None

**Description**: Acquire and ingest the Cmiel-Kuhlmann-Kuhlmann ball-space paper into the literature corpus, which currently has no copy of it.

Measured gap (verify rather than trust): the manuscript's def:frame carries a footnote citing \cite{Cmiel2021} for the claim that the nonempty fibers and segments form a BALL SPACE, and that Saturation is the downward-directed-intersection condition S_1^d of that hierarchy -- the nest condition S_1 with a directed system of balls in place of a nest. That citation has no local backing document: no entry matching Kuhlmann, ball space, spherically complete or ultrametric appears in ~/Projects/Literature/index.json or in specs/literature-index.json, and a filename search across ~/Projects/Literature/ returns nothing.

Why this matters rather than being bookkeeping. Research on the S1-versus-directedness question had to proceed without the primary source and was able to settle only part of it: S_1 provably suffices for the step lemma over every history with a countable domain (covering Z-time and Q-time), while directedness can only be forced over a non-archimedean duration type with an omega_1-coinitial positive cone. The converse direction S_1 -> S_1^d remains open, and the manuscript has already withdrawn its earlier "strictly stronger" wording in favour of "at least as strong as", so the strictness question is live rather than settled. Both the open direction and the ball-space framing route through the cited hierarchy, and neither can be grounded against the source while the source is absent. Note also that Mathlib has no spherical-completeness API at all, so there is no secondary formal reference to fall back on.

Scope: locate the paper (Cmiel, Kuhlmann and Kuhlmann, ball spaces; the manuscript's own bibliography entry is the starting point for exact title and venue), then run /literature to convert and index it so it is discoverable by future --lit dispatches. Record in the sub-index what the hierarchy's S_1 and S_1^d conditions are as the source states them, so later work can check the project's usage against the source's own definitions rather than against paraphrase.

Out of scope: any Lean change, and any edit to the manuscript.

---

### 604. Support zstd compressed jsonl datasets
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 631, Task 632

**Description**: Add zstd-compressed .jsonl dataset support across the data pipeline so large datasets can live on disk as .jsonl.zst. data/bmlogic-c7.jsonl was compressed to data/bmlogic-c7.jsonl.zst to reclaim disk space (17G -> 153M; lossless, sha256 of decompressed stream 4079d0a6b4310d417ae91999abcd581e5ebd9dacd4e9f3c33d1d9b3aa55f2704 verified identical; restore with `zstd -d data/bmlogic-c7.jsonl.zst`). Consumers that hardcode data/bmlogic-c7.jsonl are currently broken. Research first: (1) inventory every reader/writer of .jsonl datasets -- Python scripts (validate_benchmark.py, validate_datasets.py, verify_benchmark.py, migrate_schema_v2.py, standardize_metadata.py, curate_benchmark.py, curate_very_hard_plus.py, finalize_benchmark.py, validate_c5_dataset.py), shell scripts (run_dataset_generation.sh, export-training-data.sh, typst-machine-appendix.sh, typst-sync-check.sh), Lean executables under FormalSystem/Automation/*Main.lean, lakefile.lean, Tests/BimodalTest/Automation/ProofFirstTests.lean, data/hf-dataset/ tooling, and path fields in data/*_metadata.json; (2) choose the Python approach, e.g. one shared open_dataset() helper transparently handling .jsonl and .jsonl.zst (zstandard package vs zstd subprocess) and how that dependency is provided; (3) decide how Lean executables handle compressed data given Lean has no native zstd (IO.Process pipe through zstd, or shell-wrapper streaming via stdin/stdout) and whether generators should write .jsonl.zst directly; (4) reconcile with the Hugging Face Hub storage migration (task 257). Then implement, keeping plain .jsonl working, and verify every updated consumer against data/bmlogic-c7.jsonl.zst

Reconciliation note (task 629): depends on task 631 (deliverable hygiene, deletes migrate_schema_v2.py and standardize_metadata.py -- drop these two from this task's own script inventory step) and on task 632 (BimodalTools split -- write the Lean-executable inventory step against BimodalTools.* paths directly, avoiding a second rewrite).

POST-RELOCATION NOTE (2026-09-21). Dependency 632 is complete. The Lean executables this task names as 'FormalSystem/Automation/*Main.lean' are now BimodalTools/*Main.lean (root-level lean_lib BimodalTools, outside defaultTargets; lake exe target names unchanged), and Tests/BimodalTest/Automation/ProofFirstTests.lean is now Tests/BimodalToolsTest/ProofFirstTests.lean. Build and test with lake build BimodalTools and lake build BimodalToolsTest. typst-sync-check.sh now scans two Lean source roots (FormalSystem/, BimodalTools/).

---

### 570. C3 completeness question
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: metalogic
- **Dependencies**: Task 568

**Description**: OPEN RESEARCH QUESTION, not an implementation task. Is the logic of C3 -- the domain-restricted consequence relation -- equal to Burgess-Xu without the unboundedness assumption, plus S5?

WHAT IS ALREADY ESTABLISHED (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 4.2) is the CONTAINMENT: C3 includes classical propositional logic, S5 for box, the whole Burgess-Xu monotonicity, enrichment, accumulation, absorption and linearity block, and `modal_future`; and C3 excludes seriality and the uniformity layer. The study explicitly DECLINES the completeness claim. Establishing or refuting it is this task, and the honest starting position is that it is open.

THE FIRST OBSTACLE, which any canonical-model construction will hit immediately (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 4.3): the germ constraint. Every C3-validity holds at every one-point germ, and `box (phi U psi)` and `box (phi S psi)` are C3-UNSATISFIABLE for every `phi` and `psi`. That is stronger than the loss of seriality: it constrains what any axiomatization of C3 could look like, since no boxed binary-tense formula can ever be a theorem. A canonical model for C3 must either accommodate germs in the box range or the box range must be cut back first.

SEQUENCING. Do not start before the box-range design choice recorded in the C3/C4 library task is settled by the author. If the box range is cut back, this task is about a DIFFERENT logic and this description must be revised before any work begins.

LITERATURE. Burgess 1982 and Xu 1988 axiomatize `U`/`S` over an arbitrary linear order BEFORE unboundedness is added, which is exactly the setting C3 lives in. Check the Literature/ index for both before starting; acquire them if absent.

---

### 543. Formalize mf correspondence rigidity
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 500, Task 652, Task 656, Task 683

**Description**: Machine-check the principal new results from the MF frame-correspondence research conducted in the PossibleWorlds paper repository. SOURCE MATERIAL (read before starting; six reports, all outside this repository): /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/02_mf-substrate-weakening-definability.md (Theorem A), /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/03_worlds-topological-categorical-characterization.md (rigidity, T1 converse), /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/04_dense-correspondent-and-rigidity.md (Theorems B and C, scope limits), and /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/05_lean-verification-and-formalization-program.md (THE ROADMAP -- effort estimates, elaborated statements, and Mathlib dependencies, all checked against this tree). VERIFIED BASELINE, established by that round-3 work against this repository: lake build FormalSystem green (2591 jobs); 20 lean_verify calls returning standard axioms with no sorryAx; and the claim that modal_future_valid discharges no frame field now verified at the proof-term level by a transitive constant-closure walk (696 of 703 constants, imported bodies loaded via findAsync?) finding no FrameOver or TaskFrame field projection and no hF_nonempty. TARGETS, in roadmap priority order. R1: the result that deterministic task frames determine the same BL-logic as all task frames. It is NOT the pure composition of reverse_repr and forward_repr that the originating report claimed -- it needs a third fact, S.frame.Deterministic, absent from this tree; with a one-line helper it typechecks in about 25 lines, reproduced in report 05 Appendix A.1 (elaborated in scratch only; nothing was written into this repository). R2 -- BEST EFFORT-TO-VALUE IN THE SET: the rigidity theorem (report 03 section 4.3.6): over a dense Archimedean temporal order a task frame is static iff it has a uniform dwell time, hence every task frame over such an order with finitely many world states is static. Approximately 100 lines, and the finite-W half ALREADY EXISTS here as exists_uniform_radius_of_finite. The proof uses only Limit and Compositionality; Mathlib supplies Archimedean and DenselyOrdered. The claim is surprising enough that machine-checking it before it enters the paper is the point. Note report 04's refinement: for time-indexed frames the boundary is Dedekind completeness rather than the Archimedean property. R3: the T1-converse witness (report 03 section 4.2.3), a 4-state structure refuting the converse of the paper's Limit-implies-T1 result. BLOCKER TO RESOLVE FIRST: this witness cannot currently even be STATED here, because WorldHistory requires a TaskFrame and the witness violates that structure's limit field; a structural workaround is needed, and this would introduce the first topology into the repository. R4: Theorem A (MF valid iff the task relation is stationary) over Z-time, medium-large; the TimeIndexed structure and the statement are elaborated in report 05. CRITICAL SCOPE CONSTRAINT from report 04 Theorem C: Theorem A's scope is EXACTLY D isomorphic to Z -- for every discrete D not isomorphic to Z (including Z x_lex Z) and every countable or divisible dense D, a non-affine order-automorphism yields a deterministic non-stationary MF-valid frame. Do not state it more generally. Also worth formalizing: Theorem B (report 04) -- MF valid iff its past mirror MP valid iff every box-sentence is globally constant in every model -- which is exact and uniform over every D and is flagged in report 04 as reachable via box_const. NOT RECOMMENDED: Theorem A-prime; report 05 judges the formalization cost unjustified and the paper statement fine unformalized. DEPENDENCY RATIONALE: this task depends on the ShiftSet representation-theorem reconciliation research task because Theorems A and B both touch FormalSystem/Semantics/ShiftSet.lean, and that task exists precisely to prevent two parallel representation theorems from being developed and having to be reconciled afterwards. Settle that question before landing R4. Land real proofs; no sorry. This repository already carries a task-relation correspondent the paper lacks, density_schema_iff_fwdRec over Z, which is a useful model for how to state these. Reconciliation notes (2026-09-21): R1 and R2 were split out into task 646 (they import but never edit FormalSystem/Semantics/ShiftSet.lean, so they do not need the ShiftSet reconciliation this task waits on). This task retains R3 (the T1-converse witness), R4 (Theorem A over Z-time) and Theorem B, and still depends on task 500. Do not re-do R1 or R2 here. Reconciliation notes (2026-09-22): task 646 has LANDED R1 and R2. R2 is FormalSystem/Semantics/Correspondence/Rigidity.lean (FrameOver.static_iff_uniformDwell, static_of_finite; the core chop lemma eq_of_rel_of_step needs only [Archimedean D], density enters once, the biconditional consumes Seriality and the reflection law) with compiled sharpness witnesses in RigiditySharpness.lean showing neither density nor the Archimedean property can be dropped (lexRatFrame_not_static over ℚ ×ₗ ℚ, lexRat_not_archimedean). R1 is FormalSystem/Metalogic/Deterministic/SameLogic.lean (validIn_iff_validDetIn, valid_iff_valid_deterministic) via the helper ShiftSet.frame_deterministic, which lives in SameLogic.lean, not in ShiftSet.lean. The Dedekind-completeness refinement for time-indexed frames noted in report 04 is now its own task, 652, which DEFINES the TimeIndexed structure per report 05 in FormalSystem/Semantics/TimeIndexed.lean; this task now depends on 652 and R4 (Theorem A over ℤ-time) MUST consume that structure rather than define a second one. Remaining scope here: R3, R4, Theorem B. R3 additionally depends on the general-task-frame refactor, which is what makes the four-state witness statable (a frame satisfying Compositionality, Seriality and Saturation but not Limit, with its own histories); do not attempt a structural workaround here.

---

### 502. Ground algebraic representation in goldblatt and brv
- **Effort**: 12-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: None

**Description**: RESEARCH TASK. Ground the algebraic representation front in the literature BEFORE the STSA axiom set is fixed and before Uf(A) is constructed. Gates the STSA port; the complex-algebra and ultrafilter-frame tasks inherit the gate transitively.

WHY THIS RUNS EARLY. Goldblatt 1989 is largely about which varieties of Boolean algebras with operators are complex algebras, and about canonicity. Those are design questions for the STSA axiomatization and for the Uf(A) construction, not questions the eta-embedding capstone can act on. On the pre-existing graph this paper was ingested in wave 1 and not opened until wave 4, by which point three tasks would have committed to designs it should have informed.

PRIMARY SOURCE, WITH A HARD READING CONSTRAINT. Goldblatt, R. "Varieties of complex algebras", Annals of Pure and Applied Logic 44 (1989) 173-242, doi 10.1016/0168-0072(89)90032-8. The acquired PDF is an Acrobat 3.0 Capture scan (70 pages) whose OCR text layer is UNRELIABLE ON MATHEMATICS: symbols mangle, lines drop and reorder, and even the title page renders New Zealand as "New 2Miand". READ THE PAGE IMAGES via the Read tool's pages parameter. Do NOT grep the text layer for definitions or theorem statements, and do NOT accept a pdftotext- or /literature --convert-derived markdown as a faithful source for any axiom or equation. The text layer is usable only as a rough locator.

PAGINATION. Journal page 173 is PDF page 1, so PDF page = journal page - 172. The paper's own table of contents is partly OCR-garbled in its page-number column; verify each section start against the actual page image rather than trusting the offsets below.

SECTIONS IN SCOPE (do not read the whole paper):
- 2.2 The dual space of a lattice (journal ~185) and 2.3 Bounded morphisms (~192) -- the duality machinery the eta embedding rests on.
- 3.1 Canonical structures (~198) -- the canonical extension / Uf(A) construction. Bears directly on the ultrafilter-frame task.
- 3.5 Canonical varieties (~208) -- IS THE STSA VARIETY CANONICAL? This is the single most load-bearing question for the STSA port, which must restate three Boneyard sorries against the current 45-constructor axiom set and should not do so blind.
- 3.6 The elementary case (~210) and 3.8 First-order definability -- bears on whether the Spherical frame condition is first-order definable and preserved, which is the ultrafilter-frame task's dominant and explicitly unattempted obligation, and one the paper's finite-W discharge pattern does not cover.
- 4.2 Preservation by bounded morphisms and inner substructures (~229) -- whether the TaskFrame axioms transfer along the constructions.
EXPLICITLY OUT OF SCOPE: 2.4 Heyting algebras (intuitionistic, not this signature).

CROSS-FRONT NOTE, RECORD BUT DO NOT PURSUE HERE: section 4.3 covers preservation by DISJOINT UNIONS, which may bear on the two-fibre structure named in Metalogic/Conservativity.lean as the CEB countermodel shape. That belongs to the TM-completeness research task on the metalogic front; if 4.3 looks relevant, record a pointer for that task rather than expanding this one.

SECONDARY SOURCE: Blackburn/de Rijke/Venema 2002 Chapter 5 (corpus entry blackburn_2002, born-digital, full text) is the standard Jonsson-Tarski reference and should be read alongside. CAVEAT: the corpus warns this entry is 365,868 tokens and exceeds a single context budget -- create a chapter-scoped sub-entry before an agent consumes it.

DELIVERABLE: a grounding report answering, with citations to specific pages read as images: (1) does the STSA axiom set as seeded in Boneyard/UltrafilterFrame/TenseS5Algebra.lean match the standard BAO presentation, and where does it diverge; (2) is the variety canonical, and what does that buy or cost the representation; (3) what the literature says about discharging a Spherical-style frame condition on an ultrafilter frame; (4) a concrete recommendation on how the three removed-axiom sorries (temp_a, temp_l) should be restated against the current axiom set. A finding that the literature does NOT settle one of these is a complete and valid answer for that item -- record it as unsettled rather than manufacturing a verdict.

---

### 501. Extend stsa with until since operators
- **Effort**: 20-32 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 125

**Description**: Phase 4 of the Jonsson-Tarski representation: extend STSA with the binary Until and Since operators. The STSA class as seeded in Boneyard/UltrafilterFrame/TenseS5Algebra.lean carries only the unary box, G, H and sigma. The live object language's primitives are untl and snce (Formula, Syntax/Formula.lean), with allFuture and allPast DERIVED from them (:167, :177) -- so an STSA over the unary fragment alone does not represent the actual logic, and the representation theorem is incomplete without this. SCOPE: add binary operators to the STSA signature with their algebraic laws, extend the complex algebra Cm(F) to interpret them from the frame relations, extend the ultrafilter frame Uf(A) correspondingly, and re-prove the eta embedding at the extended signature. SEQUENCING: this deliberately follows the unary capstone rather than being folded into it -- the unary representation is a standalone result worth landing first, and folding the binary case in would make a single task that cannot complete in one dispatch. LITERATURE: Blackburn/de Rijke/Venema 2002 Chapter 5 (in the corpus as blackburn_2002, full text) is the standard reference for Jonsson-Tarski and its extensions to n-ary operators. Note the corpus warns blackburn_2002 exceeds a single context budget at 365,868 tokens -- a chapter-scoped sub-entry should be created before an agent consumes it.

---

### 500. Reconcile shiftset representation with stsa route
- **Effort**: 10-16 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: RESEARCH TASK. Prevent two parallel representation theorems from being developed and having to be reconciled after the fact. THE OBSERVATION: FormalSystem/Semantics/ShiftSet.lean -- landed by task 424 for the COMPACTNESS route -- is already a representation theorem. forward_repr (:263) and reverse_repr (:362) represent task models as shift sets, both directions, sorry-free. Separately, the STSA design report (specs/archive/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md) identifies its key structural claim as: box a <= box(G a) meet G(box a) says the box-fixed points form a G-invariant subalgebra, which is the algebraic encoding of OMEGA BEING SHIFT-CLOSED. That is the same shift structure ShiftSet.lean makes explicit. These look like two views of one representation. SCOPE: determine whether they are, and if so, specify the shared infrastructure so the algebraic route consumes ShiftSet rather than duplicating it. Concretely: (a) is Cm(F) expressible as an algebra of shift-invariant subsets of a ShiftSet carrier? (b) does ShiftSet's sep hypothesis correspond to an STSA axiom, and if so which? (c) can the eta embedding be factored through reverse_repr? DELIVERABLE: a report with a verdict and, if affirmative, a concrete refactor specification. A NEGATIVE VERDICT IS A COMPLETE OUTCOME -- if the two representations are genuinely different objects, say so with evidence and record it so the question is not reopened. TIMING: run this after the Los-lemma work and the STSA port have both landed, so both sides are concrete rather than projected.

---

### 499. Build ultrafilter frame and prove task frame axioms
- **Effort**: 24-40 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: HARD. Phase 2 of the Jonsson-Tarski representation: the ultrafilter frame Uf(A), and the proof that it is a TaskFrame. THE SEED: Boneyard/UltrafilterFrame/UltrafilterFrame.lean (1189 lines, behind #exit, 4 sorry hits) already has R_G (:82), R_Box (:90), R_H (:98) and a substantial body of proved structure -- R_Box_refl (:111), R_Box_euclidean (:127), R_Box_symm (:154), R_Box_trans (:164), R_G_R_H_converse (:179), the preimage and upward-closure lemmas (:229-251), R_G_trans (:281), R_H_trans (:304), and the F/P resolution lemmas (:515, :750). Port and revive rather than rebuild. THE GENUINELY NEW OBLIGATION, flagged in task 125's own FOUR-AXIOM EXPOSURE NOTE (2026-08-10): proving SPHERICAL for an ultrafilter frame is nontrivial and unattempted, and the paper's finite-W discharge pattern EXPLICITLY DOES NOT APPLY. Budget this as the dominant cost of the task; Compositionality, Seriality and Limit are expected to be far cheaper. MATHLIB HOOKS: Order/PrimeSeparator.lean:44 (DistribLattice.prime_ideal_of_disjoint_filter_ideal -- the Boolean prime ideal theorem in distributive-lattice form) is what a Zorn-free Uf(A)-nonemptiness argument should use; Order/Ideal.lean and Order/PrimeIdeal.lean (:156, :171) give the ultrafilter-as-prime-filter characterization. NOTE: Mathlib has NO Ultrafilter on an abstract Boolean algebra -- its Ultrafilter is Filter-on-Set-based. UltrafilterMCS.lean:44 rolls its own structure for exactly this reason, and its MCS-to-ultrafilter bijection (ultrafilter_correspondence :782) is available, though stated existentially rather than as a named Equiv. SHADOWING HAZARD: if Mathlib's Ultrafilter is opened in that namespace it collides with the bespoke one; keep them explicitly qualified.

---

### 498. Build complex algebra for task frames
- **Effort**: 16-24 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: Phase 1 of the Jonsson-Tarski representation: the complex algebra Cm(F). Construct the powerset STSA over a TaskFrame -- carrier the powerset of the world-history space, with box, G, H and sigma defined from the frame relations -- and prove it satisfies every STSA axiom. GREENFIELD WARNING: Mathlib has NO Boolean algebras with operators, no complex algebras, no canonical extensions, and no modal-algebra machinery of any kind; a survey of the pinned v4.33.0-rc1 tree found nothing reusable for this. What Mathlib DOES supply and should be used: Order/BooleanAlgebra/ (already consumed by BooleanStructure.lean:421) and Order/CompleteBooleanAlgebra.lean:711 (CompleteAtomicBooleanAlgebra). CONSTRAINT FROM THE FOUR-AXIOM WORK (task 420, completed): TaskFrame (Semantics/TaskFrame.lean:474-577) now carries SEVEN fields, not five -- biconditional Compositionality, Seriality, Limit and Spherical plus a Nonempty WorldState field and [Nontrivial D]. The complex algebra must be built against the live seven-field structure, not the five-field shape the older design documents assume. ACCEPTANCE: Cm(F) defined, instance STSA (Cm F) proved, sorry-free, lake build green.

---

### 497. Port stsa class and add g operator
- **Effort**: 16-24 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 502

**Description**: Bring the Shift-closed Tense S5 Algebra class into live code and close the G-operator gap. Phase 1 groundwork for the Jonsson-Tarski representation. THE SEED: Boneyard/UltrafilterFrame/TenseS5Algebra.lean (361 lines, behind #exit) already contains the full class STSA extending BooleanAlgebra with fields box, G, H, sigma and axioms box_deflationary, box_monotone, box_idempotent, box_s5, G_monotone, H_monotone, sigma_involution, sigma_neg, sigma_sup, sigma_G, sigma_H, sigma_box, MF, TF, TA, TL. This is the exact algebraic signature the representation needs. IT CARRIES 3 SORRIES, AND THEY MUST NOT BE PROVED AS-IS: they are for temp_a and temp_l, axioms that have since been REMOVED or restructured; restate them against the current 45-constructor ProofSystem.Axiom set (Axioms.lean:115-464) rather than reviving the old shapes. THE G GAP: LindenbaumQuotient.lean supplies boxQuot (:305-ish), hQuot, and sigmaQuot (:346) with its four laws (sigma_quot_involution :353, sigma_quot_neg :362, sigma_quot_sup :373, sigma_quot_box :385) -- but there is NO gQuot. G on the Lindenbaum quotient must be constructed and its congruence proved before LindenbaumAlg can be an STSA instance. Boneyard/SorriedDeclExcisions/AlgebraicGQuotChain.lean is the excised prior attempt and should be consulted, not trusted. DESIGN REFERENCE: specs/archive/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md (538 lines) gives the full axiom-to-equation translation table and the key structural claim that box a <= box(G a) meet G(box a) says the box-fixed points form a G-invariant subalgebra -- the algebraic encoding of Omega being shift-closed. It is stale on file names (references deleted AlgebraicRepresentation.lean and ParametricRepresentation.lean) but sound on the mathematics. ACCEPTANCE: STSA class live and sorry-free, gQuot constructed with congruence, instance STSA LindenbaumAlg, lake build green.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 528 (Algebraic/ modernisation: propDecide in BooleanStructure.lean, SetMaximalConsistent.ultrafilterEquiv as a named Equiv, the bespoke `Ultrafilter` structure reconciled with Mathlib Order.PFilter/Ideal.IsPrime, Multiset.inf; from specs/reviews/review-2026-09-01-lean-engineering.md findings D-08, F-11, F-12, F-13) must land first so this task builds on the modernised algebra rather than inheriting a shadowed Ultrafilter name and ~430 lines of hand-built Boolean algebra.

---

### 482. Discharge proof extraction completeness
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 412

**Description**: CLASSIFICATION: OPEN MATHEMATICS, multi-month. This MUST NOT be re-described as engineering, and must not be scheduled or budgeted as a routine task.

STANDING INSTRUCTION — RE-VERIFY BEFORE CITING. Every declaration name, file path, and line number in this record must be re-verified against the tree before it is cited again, in a report, a plan, a dispatch prompt, or a revision of this description. This record previously asserted as established fact a declaration that does not exist (see CORRECTION below), and that false fact propagated into downstream planning. Do not inherit a name from this text; re-grep it. A citation that cannot be re-verified must be struck or re-stated as absent, not carried forward.

CORRECTION (2026-10-03) — THE VERIFIER THIS TASK WAS FILED AGAINST DOES NOT EXIST. This description previously stated that `verifyProof` is `fun _ _ => true` at `FormalSystem/Metalogic/Decidability/ProofExtraction.lean:345`, "honestly commented, misleadingly named". That was false in every part, and is withdrawn. Re-verified at revision time:

  - `grep -rn 'verifyProof' FormalSystem/` returns ZERO hits. `grep -rn --include='*.lean' 'verifyProof' .` over the whole repository also returns zero hits. There is no declaration of that name anywhere.
  - `FormalSystem/Metalogic/Decidability/ProofExtraction.lean` DOES exist (351 lines), but contains no verifier declaration under any name. Its complete declaration list is: `proofFromAxiom` (:66), `extractFromClosureReason` (:87), `tryAxiomProof` (:112), `buildCompositionalProof` (:148), `enhancedSearch` (:219), `ProofExtractionResult` (:236, an `inductive`), `extractProof` (:260), `findProofCombined` (:313), and the `ProofExtractionStats` structure (:342).
  - Line 345 — the anchor the old text gave for the stub — is the doc comment `/-- Method used (axiom, derived, closure, compositional, search). -/` belonging to the `method : String` field of `ProofExtractionStats` at :346. It is a statistics record, not a verifier.
  - There is a `## Proof Verification` doc-section header at :332 (its `/-!` opener at :331, closer at :333), and the section is EMPTY: the only line between it and the next doc block is blank :334, with that block opening at :335 and `## Statistics` at :336. No declaration occupies the section. The section that would have held a verifier is a heading with no content. That empty heading is the likely origin of the phantom citation.
  - `grep -n 'fun _ _ => true' FormalSystem/Metalogic/Decidability/ProofExtraction.lean` returns nothing. The six tree-wide matches for that term are all unrelated (`WitnessFamily/Sharing/Skeleton.lean:277`, `PlusSlicedCertificate/Check.lean:665`, `PlusSlicedCertificate/Fixture.lean:222/:228/:234`, `BiLasso/Examples.lean:74`).

THIS IS A STRONGER PROBLEM THAN A TRIVIAL STUB WOULD BE. A `verifyProof := fun _ _ => true` would at least be a named function with a type, so "this verifier is correct" would be a statable proposition and this task would have had a definite theorem to discharge. There is no such function. There is therefore nothing whose correctness could be stated, let alone proved. The task cannot begin by proving a verifier correct, because the subject of that proof is absent. What previously read as a vacuous-but-present obligation is in fact an absent one.

CONFIRMED-TRUE substance carried over from the old text (re-verified at revision time, not inherited):
  - `ProofExtraction.lean` has ZERO theorems and zero lemmas: `grep -nE '^\s*(theorem|lemma)' FormalSystem/Metalogic/Decidability/ProofExtraction.lean` returns nothing. Nothing in the file is proved about anything in the file.
  - No theorem anywhere establishes that a closed tableau ALWAYS yields an extractable Hilbert-system derivation.

DELIVERABLE, RE-STATED AGAINST WHAT IS ACTUALLY IN THE TREE. This task was filed to discharge proof-extraction completeness against a verifier that turns out not to exist, so its deliverable cannot be "prove the verifier correct". The first piece of work is a scoping decision between two routes, and THE EVIDENCE GATHERED SO FAR DOES NOT SETTLE WHICH IS RIGHT. Both are recorded honestly; do not treat either as pre-selected, and do not let a dispatch quietly default to one:

  ROUTE A — WRITE A VERIFIER, THEN STATE AND PROVE ITS CORRECTNESS. Introduce a verifier over extracted proof objects (the natural domain is `ProofExtractionResult` / the output of `extractProof` and `findProofCombined`), state its correctness against the refutation induction, and prove it. This creates the proposition the old description wrongly assumed already existed. Cost: the verifier's own design is unsettled — its type, what it consumes, and what "correct" means for it are all open, and a badly chosen signature would make the correctness statement either unprovable or vacuous. Choosing this route means owning that design, not just the proof.

  ROUTE B — RE-SCOPE TO THE EXTRACTION SIDE ALONE. Drop the verifier entirely and target only the extraction obligation: that a genuinely closed tableau yields a derivation, so that `.extractionFailed` is unreachable on one. On this route the task's content is the corollary off the refutation induction and nothing more; no verifier is written and no verifier-correctness theorem is stated. Cost: whatever downstream consumer motivated wanting a verifier (if any — this has NOT been established) goes unserved, and the question returns later as a separate task.

  WHAT TO DO FIRST: establish, from the tree and from the consumers of `extractProof`/`findProofCombined`, whether any caller actually needs a verifier, and record the finding. That evidence — not a preference — decides between A and B. Report the decision and its grounds before writing any Lean.

NEIGHBOURING FACTS, EACH RE-VERIFIED AT REVISION TIME:
  - `.extractionFailed` IS LIVE. It is a constructor of `DecisionResult`, declared `inductive DecisionResult (φ : Formula) : Type where` at `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean:80`, with the constructor itself at :89. PRECISION NOTE: the outcome is DECLARED in `DecisionProcedure.lean`, not in `Correctness.lean`; what `Correctness.lean` carries is two proved theorems ABOUT it — `not_undecided_of_extractionFailed` (`Correctness.lean:264`) and `isKnownValid_of_extractionFailed` (`Correctness.lean:275`), both establishing that an `extractionFailed` verdict means the tableau closed and the formula is valid, with no proof term recovered. Cite the declaration and the theorems to their own files; do not merge them.
  - `FormalSystem/Metalogic/Decidability/Verified/Refutation/` DOES NOT EXIST. `ls` on that path fails. The parent `Verified/` directory does exist and contains `Bridge/`, `Decidable.lean`, `README.md`, `RuleSpec.lean`, and `Termination/` — no `Refutation/`. THIS TASK'S OWN `file_scope` NAMES THIS PATH, so that `file_scope` entry names an UNBUILT PATH: it is a destination, not an existing location, and any tooling or dispatch that reads `file_scope` as a list of files to open will fail on it. Do not create the directory as part of acting on this note.
  - `allClosed_derivable` DOES NOT EXIST IN THE TREE. `grep -rn 'allClosed_derivable' FormalSystem/` returns zero hits. It is task 412's target, not a landed theorem; `allClosed` itself is live as a tableau-result constructor (e.g. `ProofExtraction.lean:326`, `CancellableExpansion.lean:271`). Treat `allClosed_derivable` as a name for work not yet done.

PREREQUISITE AND SEQUENCING (substance preserved). The refutation induction (`allClosed → Derivable`, the content that would live under the unbuilt `Verified/Refutation/`) is a PREREQUISITE owned by task 412, which targets exactly that induction under the name `allClosed_derivable`. Task 412 is `not_started` with dependencies `[410, 411, 428, 430]`, and its description carries a paragraph naming this task as the owner of eliminating `.extractionFailed` as a live outcome on a genuinely closed tableau — verified present in 412's live description at revision time. This task is sequenced AFTER 412 rather than folded into 412's acceptance criteria, so that the research problem is not hidden behind 412's engineering-shaped description.

DO NOT schedule this as an independent parallel effort that would redundantly re-derive the refutation induction 412 already targets — consume 412's `allClosed_derivable` once it lands.

DEPENDENCIES: `[412]` (unchanged).

FILE SCOPE: `FormalSystem/Metalogic/Decidability/ProofExtraction.lean` (exists); `FormalSystem/Metalogic/Decidability/Verified/Refutation/` (DOES NOT EXIST — unbuilt path, see NEIGHBOURING FACTS; this task or a predecessor would have to create it, and only after the Route A/Route B decision is made).

ACCEPTANCE, RESTATED. The route decision (A or B) is recorded with the evidence that settled it, before any Lean is written. Then: `.extractionFailed` is unreachable on a genuinely closed tableau, stated and proved as a corollary of 412's `allClosed_derivable` or equivalent; `lake build` green; no regression to any currently-passing `scripts/check-module-invariants.sh` check (script verified present at that path). The old acceptance clause requiring `verifyProof` to be "either proved correct against the new theorem or replaced" is WITHDRAWN as unsatisfiable — there is no `verifyProof` to prove correct or to replace. On Route A it is superseded by the correctness theorem for the newly written verifier; on Route B it is dropped outright.

PROVENANCE (paths corrected 2026-10-03). Specced by task 468's realignment, whose artifacts have been ARCHIVED and are no longer at the live paths this description previously gave. Corrected locations, both verified present:
  - `specs/archive/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md` — §5 is "Amendment-aware ADD list"; the spec for this task is "### New task spec 2 — proof-extraction completeness" at :272.
  - `specs/archive/468_realign_task_programme_from_proof_state_audit/plans/01_programme-realignment-execution.md` — "### Planner decisions taken here (not deferred to the implementer)" at :66, item 1 at :70-77, which is the decision to give proof-extraction completeness its own task with deps `[412]` rather than fold it into 412.
  The old description cited both of these under `specs/468_.../` (no `archive/`), where neither exists.
  MISATTRIBUTED CITATION, also corrected: the old text traced this task to "`specs/reviews/review-2026-08-24.md` amendment 10b's surviving ADD-list item". That file EXISTS, but contains NO "amendment 10b" — its sections are C-1, C-2, H-1 through H-6, M-1 through M-7, and L-1 through L-3. "Amendment 10b" is an amendment to task 468's CHARTER, referenced from 468's own artifacts (report 02 at :235, plan 01 at :47 and :388), not a section of the review. Cite it to 468's artifacts, not to the review file. The "per R4" tag is genuine and resolves to "### R4. Schedule the genuinely hard items honestly (months each)" at `specs/archive/468_realign_task_programme_from_proof_state_audit/reports/01_proof-state-audit-and-realignment-charter.md:347`.

ROADMAP ALIGNMENT. `specs/ROADMAP.md` has already been corrected to state this absence honestly: its proof-extraction line (:416-420) records that `Verified/Refutation/` does not exist and that no verifier declaration exists in `ProofExtraction.lean`, and its Open Risks row (:513) records that proof extraction has no verifier at all. This description is now consistent with both.

---

### 481. Discharge or replace unorderedsuccessorlabelclosed residual
- **Effort**: large
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**:
  - [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/01_unorderedsuccessorlabelclosed-verdict.md]
  - [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/02_spawn-analysis.md]
- **Plan**: [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/plans/01_sharpen-replace-labelclosed-residual.md]
- **Summary**: [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/summaries/01_sharpen-replace-labelclosed-residual-summary.md]

**Description**: CLASSIFICATION: genuinely open -- the predicate is refuted as stated, so this is a repair-or-replace problem, not routine discharge. This is the FIFTH termination residual; the four-residual framing used elsewhere in this programme (`UniverseClosed`, `DifficultyBounded`/`StepLengthBounded`, `MintPaysForTime`, `PostBlockingSettles`) is WRONG and must be corrected wherever it recurs.

TARGET: `UnorderedSuccessorLabelClosed` (`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ClosureResidual.lean:836`) is carried as a live hypothesis by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` (`ClosureResidual.lean:1139`) and has an in-tree refutation at `ClosureResidual.lean:889` (`¬ UnorderedSuccessorLabelClosed fc freshWorldLabels`) -- the same shape of problem `DifficultyBounded` presented before `StepLengthBounded` replaced it.

WHAT TO DO -- determine which of three outcomes applies:
(a) the predicate can be discharged at the frame classes/settings the surviving terminus theorems actually need (distinct from the setting `ClosureResidual.lean:889` refutes it in -- check precisely which); or
(b) it needs a `StepLengthBounded`-style weaker replacement, analogous to the `DifficultyBounded` -> `StepLengthBounded` repair pattern already in this file; or
(c) it is unclosable as stated and needs a C9 register entry (the file already has 24 such entries; this would be the 25th) plus an explicit statement of which theorem still carries it and at which frame classes.

A C9 REGISTER ENTRY IS A VALID, COMPLETE DELIVERABLE for this task -- do not treat "prove it" as the only acceptable outcome.

SEQUENCING NOTE (direct from `specs/reviews/review-2026-08-24.md` amendment 10e, re-affirmed by task 468's realignment): task 462 targets `MintPaysForTimeFixed` discharge at a NONEMPTY UNIVERSE, which is the same setting `ClosureResidual.lean:889`'s refutation applies in. If this task and 462 are not sequenced, 462 risks either duplicating the discovery of the refutation or, worse, building on an implicit assumption that this residual is harmless. This task should run BEFORE OR ALONGSIDE 462.

DEPENDENCIES: `[434]` (established the residual set this belongs to). Do NOT fold into 465 (the mechanical restatement-family task) -- 465 is explicitly scoped as "a one-line application of its family root" for SETTLED residuals; this residual is not settled, so folding it in would either force 465 to do research work outside its charter or produce a restatement of an unsettled predicate, which is exactly the kind of premature-closure risk this whole realignment exists to prevent.

VERIFIED at task-468 realignment time (2026-08-25): none of tasks 462, 463, 464, 465 mentions the symbol `UnorderedSuccessorLabelClosed` in its live description.

ACCEPTANCE: one of outcomes (a)/(b)/(c) above is reached and recorded; `lake build` green; no regression to any currently-passing check-module-invariants.sh check.

PROVENANCE: specced by task 468's realignment (report `specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md` §5, new-task-spec-3), itself descended from `specs/reviews/review-2026-08-24.md` amendment 10e.

POINTER REFRESH (2026-09-16 reorganization): `MintBound.lean` was split into the `MintBound/` directory (the monolithic `MintBound.lean` is now a 121-line aggregator). Line references above were re-confirmed against `MintBound/ClosureResidual.lean` (definition :836, in-tree refutation :889, carrying theorem :1139); "this file" in the text above now means that directory. The completed dependency numbers 434/483 were pruned from the dependency list; the blocked status and blockers are unchanged.

---

### 430. Semantic lift and track a assembly valid iff allclosed
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428, Task 429, Task 411
- **Parent**: Task 165

**Description**: The semantic lift and the Track A assembly. Owns obstruction O4 of the Phase 7.3 deadlock, then delivers what Phase 7.3 of task 165 was for. Grounding: specs/archive/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md (the report was archived with 165; the pre-archive path in earlier revisions of this description no longer resolves).

READ THIS FIRST: THIS TASK IS NO LONGER ON THE CRITICAL PATH TO A FIRST DECIDABILITY RESULT. ℤ-time validity of the base language is already decided, by a route that has nothing to do with this tableau spine. Verified against the tree on 2026-10-03 by `#check` and `#print axioms` under `import FormalSystem`:

  FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime
    : (φ : FormalSystem.Syntax.Formula) → Decidable (FormalSystem.Semantics.ValidZTime φ)
  axioms: [propext, Classical.choice, Quot.sound]
  FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean

It is a `def`, not an `instance` (a global instance would change instance resolution repository-wide; its own docstring says so). Its scope qualifiers are load-bearing and must be carried on every restatement: `FrameClass.ZTime` only; `φ : Formula`, the base-language syntax with no stability operator; empty premises. It is `decidable_of_iff` through `validZTime_iff_noCertifiedCandidate` (same file, same axiom set). The empty-premise consequence corollary `decidableSemanticConsequenceNil` covers `SemanticConsequenceIn FrameClass.ZTime [] σ` only; the general-premise case is unwritten. Do NOT restate any of this as "TM is decidable": that sentence drops every qualifier that makes the result true.

DISAMBIGUATION, because the name collides. `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` also declares defs of type `Decidable (ValidZTime φ)`, but they TAKE a finite-model-property hypothesis as an argument, and that hypothesis is refuted by `Probe476.fmp_false` (`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`). The unconditional one is the `Compression`-sub-namespaced declaration above. Cite the full name, never the bare one.

WHAT THIS TASK'S DELIVERABLE ACTUALLY IS, GIVEN THAT. Not "the first decidability theorem". The spine's deliverable is the FOUR-CLASS statement: the biconditional `isValid φ fc = true ↔ ⊨ φ` together with the `Decidable (⊨ φ)` instances at all four `FrameClass` constructors -- `Base`, `Dense`, `ZTime`, `RTime` (verified: `inductive FrameClass` in `FormalSystem/ProofSystem/Axioms.lean` has exactly these four; earlier revisions of this description named them "Base, Dense, Discrete and Dedekind", which are the prose names, not the constructors). The spine is the only route FILED for Base, Dense and RTime. It is NOT the only route to any decidability result, and at ZTime it is not even the first: there it duplicates, by a different method, something already proved. Rank the work accordingly -- this is a four-class uniformity result and a tableau-correctness result, not a race to a first theorem.

WHAT THE SPINE HAS TODAY: THE SOUND DIRECTION ONLY. Verified:

  FormalSystem.Metalogic.Decidability.sound_of_isValid
    : ∀ {φ} (r : DecisionResult φ), r.isValid = true → ⊨ φ
  FormalSystem.Metalogic.Decidability.isValid_sound
    : ∀ (φ : Formula) (fc : FrameClass), isValid φ fc = true → ⊨ φ
  both axioms: [propext, Classical.choice, Quot.sound]
  FormalSystem/Metalogic/Decidability/Correctness.lean

Their conclusion is the UNRELATIVIZED `⊨ φ` whatever `fc` was passed, and that is forced by the types rather than chosen: `DecisionResult.valid` carries `⊢ φ` = `DerivationTree FrameClass.Base [] φ` for every `fc`. The frame-class-relative forms (`isValid_validDense`, `isValid_validZTime`, `isValid_validRTime`) are therefore weakenings obtained through the `Validity.valid_implies_*` monotonicity lemmas, not independent results. The siblings `isTautology_sound`, `isContradiction_sound`, `not_isSatisfiable_sound`, `decide_isValid_sound`, `decideBlocking_isValid_sound` and `decideAuto_isValid_sound` all factor through `sound_of_isValid`. The completeness direction `⊨ φ → isValid φ fc = true` is open, and it is the whole of what this task owes.

THE RETIRED-AS-VACUOUS RECORD, AND WHY IT IS A CONSTRAINT ON THIS TASK. `Correctness.lean` carries a section headed "`validity_decidable` / `validity_has_decision_procedure` -- Retired as vacuous". Two theorems once stood there and were retired rather than deleted quietly, because their NAMES claimed a decidability result their PROOFS did not contain. Faithfully, per that section:

  (i) `validity_decidable (φ : Formula) : (⊨ φ) ∨ ¬(⊨ φ)` was proved by
      `exact Classical.em (⊨ φ)`. That is excluded middle for an arbitrary proposition. It
      holds of any predicate whatsoever and says nothing about `⊨` in particular, about
      tableaux, or about computation. It produces no procedure and no `Decidable` instance.
  (ii) `validity_has_decision_procedure (φ : Formula) : ∃ decision : Bool, decision = true ↔ ⊨ φ`
      was proved by `by_cases h : (⊨ φ)` supplying `true` or `false` accordingly. The
      existential is witnessed non-constructively BY THE TRUTH VALUE ONE IS TRYING TO COMPUTE --
      `Classical.em` with a `Bool` wrapped around it. In particular it is not the statement that
      `isValid` (`DecisionProcedure.lean`) is that `decision`, which is the content one would want.

That section also records what is still owed and why it is deliberately not stated there: the completeness direction, hence the biconditional and the four `Decidable (⊨ φ)` instances, needs the fuel/termination side and the truth-lemma gate on top of the landed rule half, and must additionally account for the two rules scheduled outside `allRulesForFC`. Its closing sentence is the standing prohibition this task works under: stating an `isValid`-shaped `iff` before the obligation is discharged "would reproduce exactly the defect this retirement removes: a true-looking name over a proof that does not reach it."

O4 HAS TWO DISTINCT PIECES. The source is the docstring of the "7.2, the assembly" section of `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`, under the heading "What this does and does not deliver" (cited by section heading rather than line number; the line numbers in earlier revisions of this description have drifted):

(a) Two more `RuleSound`-analogues at the `expandOnce` level, for `serialityRule` and `timeLinearity`. These two are deliberately OUTSIDE `allRulesForFC` -- `mem_allRulesForFC_iff` (`Verified/RuleSpec.lean`) turns membership into `r ≠ .serialityRule ∧ r ≠ .timeLinearity ∧ ruleFrameClass r ≤ fc`, so the landed assembly provably does not cover them. They run as stages 2 and 3 of `expandOnce` and need their own obligations at the point where `expandOnce`, rather than `applyRule`, is the object.

(b) THE SEMANTIC LIFT: the induction lifting single-step satisfiability preservation to the whole recursion, so that `.allClosed` yields a contradiction. This is the LARGER of the two and is comparable in weight to a landed sub-phase, not to a wrapper. Naming it inside "the two outside rules" understates it.

THEN, and only after (a), (b) and both predecessors: the semantic lift's consequence at all four frame classes.

WHAT IS ALREADY LANDED (do not re-prove). The rule half is done. Verified:

  FormalSystem.Metalogic.Decidability.Verified.ruleSound_of_mem_allRulesForFC
    : ∀ (fc : FrameClass), ∀ r ∈ allRulesForFC fc, RuleSound (carrierForFC fc) r
  axioms: [propext, Classical.choice, Quot.sound]
  FormalSystem/Metalogic/Decidability/Verified/Decidable.lean

One induction over `mem_allRulesForFC_iff`, discharged case by case against a per-rule ledger complete at 34/34 `TableauRule` constructors; from task 165 Phase 7.2. Twenty-seven of the thirty-four travel through `ruleSound_base_mono` (`carrierBase` is `fun _ => True`); only two transports are non-trivial and both are one projection.

PLAN AGAINST SIX ROWS, NOT EIGHT. The truth-lemma gate hypothesis `hTW` is discharged on SIX accepted `TemporalWitnessProbe` rows (A, B, C, D, E, F), not the historical eight. Verified against the banner at the head of `Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean` (task 634 relocated the file there from the test root): "The eight rows this file repeatedly describes as 'the rows the gate accepts' -- A, B, C, D, E, F, I, K -- are now six: I and K, the two genuine negative-until/since rows, have joined H, J, M and N on the rejected side." The cause is the retirement of the PASSIVE co-decomposition arms of `.untlNeg`/`.snceNeg`; the banner calls it a deliberate, authorized completeness regression and notes it removes the last set of hand-built branches on which `hTW` was discharged. Read every "all eight rows the gate accepts" in that file's findings as "accepted before the retirement".

DO NOT write a conditional form carrying `hTW` as an explicit hypothesis. `Correctness.lean` refuses exactly this shape in two places -- the retirement section quoted above, and the docstring paragraph "`isKnownValid` is not a substitute hypothesis here" -- and the O4(b) hypothesis would BE the conclusion's forward direction, making the theorem vacuous. Four vacuous theorems were deleted in 165's Phase 8; do not land a fifth.

THE INDEPENDENT ORACLE FOR THE ZTIME INSTANCE. At ZTime this task's result must AGREE with a route already proved, and there is a cheap fixture that tests it. This is cross-check L-E3 of the ranking ratification in `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` (section "L -- the base language", entry L-R1). The target formula, verified by `#print` under `import FormalSystem` and NOT at the namespace the scope spec's shorthand suggests -- it lives in `FormalSystem.Metalogic.Decidability.WitnessFamilyExamples`, not directly in `FormalSystem.Metalogic.Decidability`:

  WitnessFamilyExamples.phiPos : Formula := occurs.box.and once.box
  WitnessFamilyExamples.occurs : Formula := pForm.or (fP.or pP)      -- p ∨ (Fp ∨ Pp)
  WitnessFamilyExamples.once   : Formula := pForm.imp pP.neg        -- p → ¬Pp
  with pForm = Formula.atom pA, fP = pForm.someFuture, pP = pForm.somePast
  FormalSystem/Metalogic/Decidability/WitnessFamily/Examples.lean

So the formula the scope spec writes as `□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` is `phiPos`, with the disjunction right-associated as `pForm.or (fP.or pP)`. `phiPos` is the sole member of `gammaPos`; `delPos = []`, so `posFamily` refutes no `σ` and instead exhibits a model of `gammaPos`.

The oracle is stronger than a mere certificate run, and this is worth knowing before building the fixture: `WitnessFamilyExamples.phiPos_satisfiable` is a landed theorem (axioms `[propext, Classical.choice, Quot.sound]`) producing a `FrameClass.ZTime.Sat` frame, model, history and duration at which every member of `gammaPos` is true -- assembled from `posFamily.joint_countermodel` and the four `by decide` facts `posFamily_localCoherent`, `posFamily_fulfilling`, `posFamily_boxFaithful`, `posFamily_target`. Hence `phiPos.neg` is NOT ZTime-valid, as a theorem and not as a computation.

THE CROSS-CHECK: run both routes on `phiPos.neg`.
  - `Compression.decidableValidZTime phiPos.neg` must decide NEGATIVELY (it is refuting a formula
    whose negation has a proved ZTime model).
  - `decide phiPos.neg searchDepth tableauFuel fc` (signature verified: `decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000) (fc : FrameClass := .Base)`)
    must NOT report `.valid` at `fc = .ZTime`. `.fuelExhausted` is an acceptable outcome;
    `.valid` is a soundness contradiction with `phiPos_satisfiable` and would mean the spine is
    broken, not merely incomplete.
  - `isValid phiPos.neg .ZTime` must not be `true`, for the same reason.
This is a cheap consistency witness the two routes have never been given, it needs none of O4, and it can be landed as a test fixture before (a) or (b). Doing it first is recommended: it either buys confidence in the engine at no cost or finds a soundness defect while the spine is still open.

OUT OF SCOPE. Do not reopen the C9 do-not-re-attempt register; it already holds the refuted forms (an unconditional `buildTableau_isSome`, and the decidable-branch-gate family that collapses to `false` on branches that mint a world). `gapPotential`'s density measure for `densityRule` is task 464's, genuinely open, and not this task's to attempt. `Decidable (Derivable .ZTime [] φ)` by the witness-family route is task 412's, not this one's (verified: `Decidable (Derivable` has zero occurrences anywhere in `FormalSystem/`).

DONE WHEN: (a) and (b) are landed unconditionally; the semantic lift's consequence is stated and proved at all four of `Base`, `Dense`, `ZTime`, `RTime` with no hypothesis standing in for its own forward direction; the L-E3 cross-check fixture is wired and green; sorry-free and axiom-clean outside Boneyard; `lake build` green.

VERIFICATION NOTE (2026-10-03, this revision). Every declaration name, type, axiom set and path cited above was re-derived from the tree by `#check`/`#print axioms`/`#print` under `import FormalSystem`, plus grep, not taken on trust. Three things the sources named did not survive that check and were corrected here: the grounding report path (archived under `specs/archive/165_.../`); the four frame classes (constructors are `Base`/`Dense`/`ZTime`/`RTime`); and the namespace of the L-E3 target (`...Decidability.WitnessFamilyExamples.phiPos`, which does not resolve as `...Decidability.phiPos`). Line-number citations were replaced by declaration names and section headings throughout, since the previously cited lines had drifted.

---

### 429. Repair truth lemma side conditions boxanchored and temporalwitness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428
- **Parent**: Task 165

**Description**: Repair the truth-lemma side conditions. Owns obstructions O2 and O3 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md. THIS IS THE TASK WITH GENUINE OPEN MATHEMATICS IN IT and should be budgeted accordingly.

READ FIRST: specs/418_*/artifacts/boxanchored-finding.md -- it carries the measurement, the full carrier list, and the repair options. Then TruthLemma.lean:399-404 and BoxSaturation.lean:430-435, :574-580.

O2 -- `hBA` (`boxAnchoredCheck`) is no longer dischargeable on multi-world branches. BoxSaturation.lean:430-435: the two copy blocks "have since been removed as unsound ... They were the ONLY route by which T(G phi)/T(H phi) could reach a freshly minted world ... `boxAnchoredCheck` is therefore expected to compute `false` on multi-world branches now." :574-580: "a caller can no longer expect to discharge that hypothesis from a real run." TruthLemma.lean:399-404 names the repair as "an open design decision with its own soundness obligations" and lists THREE candidate routes: (a) propagate T(box phi) itself; (b) copy T(G phi)/T(H phi) only when box-derived; (c) restructure the `box` case to need no anchor.

CRITICAL CONSTRAINT: this was caused by task 418 (completed) removing a GENUINE UNSOUNDNESS. It is the cost of a correct fix, not a regression to revert. TruthLemma.lean:404 says "Do NOT reinstate the removed copies." Any repair must re-establish the anchor WITHOUT reinstating them.

O3 -- `hTW` (`temporalWitnessCheck`) is no longer dischargeable on any branch carrying a negative until with a known future time. TemporalWitnessProbe.lean:66-73: `untlNegFuture` demands F(event) at every known future time of every negative until; the PASSIVE arm's branch 1 was the ONLY producer of `not event` at an EXISTING time; that arm was retired as unsound (user-authorized rank 2), so the producer is gone. Measured cost: fourteen probe rows moved check=true -> check=false; the accepted set went from EIGHT rows to SIX (rows A, B, C, D, E, F; I and K left). :86-88: "it was already `false` on the branches the engine actually builds. What it removes is the last set of hand-built branches on which the hypothesis was discharged."

DO NOT REOPEN (settled by 165): guardWitnessed in any variant; restoring sat_untl_neg / sat_snce_neg (they are FALSE against the current engine, not merely unproved); reinstating the retired PASSIVE arms or the removed box copy blocks.

GOAL: choose among the three documented BoxAnchored repair routes and land it with its soundness obligations discharged; and re-establish a producer for `not event` at existing future times. Both must hold on branches the engine ACTUALLY builds, measured by the probes, not on hand-built branches.

DONE WHEN: `boxAnchoredCheck` and `temporalWitnessCheck` are dischargeable on real engine output for the relevant branch classes, evidenced by probe rows moving back to check=true; no unsound copy block or retired arm is reinstated; lake build green.
REALIGNMENT ADDENDUM (task 468, 2026-08-25) -- RECOMMENDED ROUTE, NAMED UP FRONT: of the three O2
repair routes listed above, route (a) -- propagate T(box phi) itself to the fresh world -- is the
RECOMMENDED route (per specs/reviews/review-2026-08-24.md amendment 10a and the box-anchor
artifact's own §5), so a dispatch need not re-derive the recommendation from
boxanchored-finding.md each time. It follows the S5 axiom-4/5 pattern, carries its own RuleSound
obligation, and has named fuel/termination consequences that Fuel.lean's bounds and the
subformula property must absorb -- all as already detailed in that artifact. Route (b) remains
available but reduces to route (a)'s obligation once branch provenance is tracked, per the
artifact. Route (c) stays recorded as CLOSED AS FORMULATED (boxGridCheck fails for the same
structural reason the anchor does, so weakening only the anchor buys nothing) -- do not
re-attempt it. This addendum names a recommendation; it does not narrow the task's own account of
all three routes and their obligations above, which stands as written.

Reconciliation note (task 629): task 634 (language-extension directories and probe tests) relocates this task's cited Tests/BimodalTest/TemporalWitnessProbe.lean to Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean (added to this task's file_scope above). No dependency edge in either direction: at execution time, check whether task 634 has landed and adjust the path accordingly.

POST-RELOCATION NOTE (2026-09-21). Task 634 has landed and moved Tests/BimodalTest/TemporalWitnessProbe.lean to Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean together with the other seven probe files and TableauConformance.lean, with no follow-up move outstanding (this task was not_started with no uncommitted work under Tests/ when 634 checked). This task's file_scope already names the new path; any mention of the old path in the description above is historical.

---

### 428. Engine totality at a quantified branch budget
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 465
- **Parent**: Task 165
- **Plan**:
  - [428_engine_totality_at_a_quantified_branch_budget/plans/02_lexicographic-splitordered-measure.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/03_mint-bound-irreflexivity-totality.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/04_ordtimesknown-strengthening-totality.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/01_budget-totality-engine-repair.md]
- **Summary**:
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/02_lexicographic-splitordered-measure-summary.md]
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/01_budget-totality-engine-repair-summary.md]
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/04_ordtimesknown-strengthening-totality-summary.md]
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/03_phase11-potential-obstruction.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/04_witness-preservation-machine-checked.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/01_budget-totality-refuted-and-repair.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/02_splitordered-measure-blocker.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]

**Description**: Engine totality at a quantified branch budget. Owns obstruction O1 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md section "The four obstructions" (read it first; do not re-derive the refutation).

THE REFUTED THEOREM, SETTLED: `buildTableau_isSome` in unconditional form is FALSE, not merely unproved, and is on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine SIGNATURE, not a proof difficulty: `buildTableau` (Saturation.lean:928-951) calls `expandBranchWithFuel` at the default `maxBranches := 50000` (Saturation.lean:590), whose first line is `if branchesUsed >= maxBranches then none` (:594). A formula exploring more than 50000 branches returns `none` at ANY fuel whatsoever. Independently, `buildTableau`'s last arm returns `none` on a still-unsaturated branch (:950). Neither is fuel exhaustion, so no fuel figure rules them out. DO NOT attempt the unconditional form.

WHAT LANDED INSTEAD, and why it is unusable as-is: Verified/Termination/Fuel.lean:1587-1598 carries two hypotheses -- `(hP : NoSplit P fc)` and `(hbud : branchesUsed + fuel <= maxBranches)`. `NoSplit` excludes impPos, orPos, untlPos, untlNeg, sncePos, snceNeg, orderTrichotomy and every frame-class-gated splitting rule, i.e. it holds only on non-branching runs. 165's plan:1467-1468 records "Residual 2 (branching arms) -- isolated, not discharged."

GOAL: add a `maxBranches`-parameterised entry point ALONGSIDE `buildTableau` -- an ADDITION, never an edit to the existing default, because `maxBranches = 50000` is a deliberate runtime guard -- and prove totality against a quantified budget. Target shape:

  theorem buildTableau_isSome_of_budget (phi : Formula) (fc : FrameClass)
      (maxBranches : Nat) (hmb : <bound in phi> <= maxBranches) :
      (buildTableauAt phi (soundFuel' phi) fc maxBranches).isSome = true

THREE SUB-OBLIGATIONS:
1. Discharge the branching-arm residual that `NoSplit` currently hypothesises (Fuel.lean:1587, Saturation.lean:661-664, :686-689).
2. Supply the missing WORLD-COUNT dimension. 165's plan:1484-1488: "T1 bounds formulas and T2 bounds times; neither bounds worlds ... as defined, `soundFuel' = 2*n*2^(2n)` has no world factor at all." A branch bound that ignores worlds cannot bound branches.
3. Establish the `<bound in phi> <= maxBranches` side condition in a form callers can actually discharge.

COORDINATION: overlaps task 426's hypothesis (b) on the same file (Fuel.lean). Sequence with 426 or merge; do not both edit Fuel.lean concurrently. Task 412 consumes this theorem in place of the refuted `buildTableau_isSome`.

DONE WHEN: the budget-parameterised totality theorem is landed sorry-free with no `NoSplit` hypothesis, lake build green, and the world dimension is either supplied or its absence is proved harmless.

RETARGET DECISION (user-approved, post-research): the specified unconditional target shape is refuted (see reports/01_budget-totality-refuted-and-repair.md). Task WIDENED to own the validated certificate repair: swap findUnexpanded -> findUnexpandedUnblocked at resolveOpenArm's two decision points, discharge the accompanying soundness obligation on what .hasOpen certifies (shared with O2/O3), lift the proved saturateBlocked_isSome asset, close the world dimension via worldFuel'/WorldWitness, and land the budget-parameterised totality theorem against the repaired engine. The per-path budget finding (maxBranches >= 3*fuel linear invariant) supplies the side condition.

SECOND RETARGET DECISION (user-approved, post-research 03). The per-step framing of Phase 11 cannot be closed: reports/03_phase11-potential-obstruction.md section 4 is a proof about the SHAPE of the argument, not a report of a failed attempt. Route (a) (a lower bound on branch cardinality after identification) is DEAD by definition -- `Branch.identifyTime = (b.map relabel).eraseDups`, so all shrinkage comes from eraseDups and is bounded only by |U|. Route (b) (an independent mint bound) is the APPROVED path.

THE CHEAPER ALTERNATIVE IS EXPLICITLY REJECTED BY THE USER: do NOT carry the mint bound as a hypothesis in the shape `hT` has, and do NOT push the discharge obligation onto task 412. Do it the right way.

APPROVED WORK (route (b), ~6-7 phases, comparable in size to everything landed so far):
1. WITNESS PRESERVATION (~3 phases): the eight-rule case analysis of report 03 section 3 step 4, resting on the three lemmas already machine-checked in that report's section 1 (`mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`, `identifyTime_no_collapse`).
2. RESTATEMENT (~1 phase): give `expandBranchWithFuel_isSome_of_budget` an explicit MINT-BUDGET PARAMETER, in the shape `branchesUsed`/`maxBranches` already establishes. This is what converts route (b)'s amortized bound into something the induction can carry; a per-step potential over (b, ord) provably cannot express it (report 03 section 4), and `maxTime` was checked and is not a usable proxy (arm 3 can lower it).
3. AMORTIZED INDUCTION (~2-3 phases): #mints <= 8*|U|; #identifications <= |knownTimes|_0 + #mints; total shrinkage <= #identifications * |U|; #extensions <= |U| + total shrinkage; then the terminus `buildTableauAt_isSome_of_budget`.

RESEARCH GATE -- MACHINE-CHECK BEFORE PLANNING. Report 03 marks two load-bearing claims UNCERTAIN, and the whole mint bound rests on both:
  (i) section 3 step 4, witness preservation across `.splitOrdered` arm 3 -- ARGUED, NOT MACHINE-CHECKED. The two modal rules are trivial (their witness sits at the same time as `sf`, so identification moves both together); THE SIX TEMPORAL ONES NEED THE REACHABILITY TRANSPORT and were not verified.
  (ii) section 3 step 3, "formulas are never deleted" -- read off the rule shapes, consistent with the landed `expandOnceUnblocked_card_lt` / `expandOnceUnblocked_split_card_lt`, but NOT PROVED.
Machine-check BOTH before any plan is written. This task has twice had a plan rest on an unverified lemma that later turned out FALSE (the unconditional `buildTableau_isSome`; then the `.splitOrdered` cardinality twin). A third occurrence is not acceptable. If witness preservation fails for any temporal rule, ROUTE (b) IS DEAD and that is a THIRD retarget decision requiring human approval -- report it plainly, do not work around it and do not substitute a weaker statement.

PRESERVED, DO NOT RE-PROVE: phases 1-10 of plans/02_lexicographic-splitordered-measure.md are landed, sorry-free, axiom-free, and green repo-wide. Consume those declarations. `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s `maxBranches := 50000` default stay BYTE-IDENTICAL. No `NoSplit` reintroduction; no admitted `WorldWitness` or `hT`; no `sorry`; no narrowing a statement into vacuity. The refuted unconditional `buildTableau_isSome` and the refuted `.splitOrdered` cardinality twin stay on the do-not-re-attempt register. `resolveOpenArmCancellable` in CancellableExpansion.lean remains a DECLARED, deliberately-unrepaired out-of-scope divergence. Task 412 must not be planned against `buildTableauAt_isSome_of_budget` until it lands; the Phase 3 assets (`BudgetedTableau`, `buildTableauAt`, `BudgetedTableau.upgrade`) are available and sorry-free meanwhile.

RESUME SEQUENCE: `/research 428` first (discharge the two uncertain claims above), then `/orchestrate 428`. The stale loop guard from the prior invocation has been removed so a restart gets a fresh cycle budget.
REALIGNMENT ADDENDUM (task 468, 2026-08-25) -- ASSESS-AND-C9-REGISTER ESCAPE CLAUSE FOR THE
SPLIT-ARM FUEL SCALING PROBLEM: the opening "THE REFUTED THEOREM, SETTLED" paragraph above is
unaffected by this addendum and gets a CURRENT verdict on that point -- do NOT touch it.

`Fuel.lean:1595-1610` documents that fuel adequate for a split run scales like
`beta ^ depth * worldFuel'`, and depth is not bounded by anything proved in that file -- this is,
in its own words, "a real property of a deliberate engine policy, not a gap in a proof," of the
same class as the already-settled `buildTableau_isSome` refutation. If, in the course of this
task's approved route (b) work, the split-arm fuel-adequacy question proves genuinely unclosable
as specified -- i.e. no depth bound can be established or supplied without weakening the engine's
own proportional-fuel policy -- the correct deliverable is an explicit ASSESS-and-C9-register
outcome: name the specific obstruction, add a C9 register entry (in
`Verified/Termination/MintBound.lean`, alongside its other entries) stating precisely which
theorem still carries the split-arm scaling exposure and under what hypothesis, and stop there.
This is a VALID, COMPLETE outcome for this sub-question -- do not treat "close it" as the only
acceptable result, and do not force a proof past this obstruction by weakening `NoSplit`,
reintroducing a hypothesis this task's own do-not-re-attempt register forbids, or narrowing a
statement into vacuity.

---

### 412. Prove refutation core and decidability of provability with completeness corollaries
- **Effort**: 10-15 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 410, Task 411, Task 428, Task 430
- **Parent**: Task 165

**Description**: Track B finish for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.1, 8.3, 8.5). Create Verified/Refutation/Core.lean proving allClosed_derivable as ONE induction over allRulesForFC fc, discharging each rule by its admissibility lemma (predecessor tasks) and its ruleFrameClass r <= fc hypothesis via the RuleSpec GATE lemmas — Dense/Discrete/Dedekind instantiate the generic theorem, they do not re-prove it. Then Verified/Provable.lean: Decidable (Derivable fc [] phi) combining allClosed_derivable with Track A's buildTableau_isSome and not_valid_of_hasOpen; the completeness corollaries ValidFor fc phi -> Derivable fc [] phi [PHANTOM NAME -- see STALE REFERENCES addendum below]; supply the Dedekind engine consumed by completeness_dedekind_of_engine (StrongCompleteness.lean:308, target ValidDedekindDense) [PHANTOM NAME -- see STALE REFERENCES addendum below]. Acceptance: zero sorries repo-wide outside Boneyard; lake build green; update typst/latex decidability chapters to record headline result 2.
RE-SCOPING ADDENDUM (2026-07-29, supersedes the buildTableau_isSome reference above): the scope text above depends on "Track A's buildTableau_isSome", which task 165 proved FALSE and placed on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine signature, not a proof difficulty: buildTableau returns none whenever a formula explores more than maxBranches := 50000, at ANY fuel. Consequently this task's acceptance criterion "zero sorries repo-wide outside Boneyard" was UNREACHABLE AS SCOPED, independently of task 165's own status.

CORRECTED DEPENDENCE: consume the budget-parameterised totality theorem from task 428 (engine_totality_at_a_quantified_branch_budget) -- shape `buildTableau_isSome_of_budget phi fc maxBranches (hmb : <bound in phi> <= maxBranches)` -- in place of the unconditional buildTableau_isSome. Task 428 has been added as a predecessor. Do NOT attempt the unconditional form yourself.

ALSO NOTE: this task inherits obstructions O2 and O3 (the boxAnchoredCheck and temporalWitnessCheck truth-lemma side conditions) from Phase 7.3 of task 165 by way of not_valid_of_hasOpen. Those are owned by task 429. If your induction reaches a point where a truth-lemma gate hypothesis must be discharged on real engine output, that is 429's work, not this task's -- record it and coordinate rather than re-deriving it. Grounding for all of this: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

REALIGNMENT CORRECTION (task 468, 2026-08-25): the struck clause above ("discharge the
pre-existing sorry countermodel_discrete at Transfer.lean:1242") is STALE. That sorry no longer
exists -- countermodel_discrete is CLOSED, via tasks 477/478/479's k-equivalence/groupable-
companion route, and now lives sorry-free in
FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean, not Transfer.lean. Verified
fresh by scripts/check-module-invariants.sh C2/C3 at realignment time: C3 reports zero live
structural sorries tree-wide; C2 reports BXCanonical.completeness axiom-clean
([propext, Classical.choice, Quot.sound]). This task's remaining scope (allClosed_derivable, the
Decidable (Derivable fc [] phi) instance, the completeness corollaries, the Dedekind engine) is
UNCHANGED and still open.

New task 482 (discharge_proof_extraction_completeness, dependencies: [412]) is the owner of
eliminating .extractionFailed as a live outcome on a genuinely closed tableau -- it is gated on
this task's allClosed_derivable induction as a prerequisite and consumes it once landed. This
task's own acceptance criteria are unchanged by 482's existence; 482 is a downstream consumer,
not an addition to this task's scope.

DECIDABILITY-HALF NARROWING (2026-10-03, scope spec Section G item 2 of
specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md). This revision narrows
the decidability half of this task only. The refutation half -- Verified/Refutation/Core.lean and
allClosed_derivable -- is untouched and remains this task's core.

THE Z-TIME CLASS LEAVES THIS TASK. `Decidable (Derivable FrameClass.ZTime [] phi)` -- one of the
four frame classes the `Decidable (Derivable fc [] phi)` deliverable above was filed to cover --
is a FEW-LINE COROLLARY of a route that has already landed independently of the tableau spine, and
is being filed as its own follow-up task (scope spec Section H3) rather than done here. The route,
each declaration re-verified against the tree at revision time:

  - `FormalSystem.Metalogic.soundness_ztime_valid {phi : Formula}
    (d : DerivationTree FrameClass.ZTime [] phi) : ValidZTime phi`
    -- FormalSystem/Metalogic/Soundness.lean:1522.
  - `FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime (phi : Formula) :
    ValidZTime phi -> Derivable FrameClass.ZTime [] phi`
    -- FormalSystem/Metalogic/BXCanonical/Completeness.lean:394.
  - Together these give `Derivable FrameClass.ZTime [] phi <-> ValidZTime phi`. `Derivable fc G p`
    is `Nonempty (DerivationTree fc G p)` (FormalSystem/ProofSystem/Derivable.lean:69), so the
    soundness direction is applied under a `Nonempty` elimination (the `h.elim fun d => ...`
    pattern already used at FormalSystem/Metalogic/StrongCompleteness.lean:309) -- still a few
    lines, not a new proof.
  - `decidable_of_iff` against
    `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime (phi : Formula) :
    Decidable (ValidZTime phi)`
    -- FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean:147, a `def`
    and deliberately not an `instance` -- finishes it.

UNWRITTEN, NOT ALREADY DONE. `grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/`
returns zero hits at revision time; the only tree-wide match is the "not built" row at
FormalSystem/Metalogic/Decidability/Verified/README.md:62. So the corollary is genuinely unwritten.
Do not treat it as landed -- and do not write it here either, since it belongs to the Section H3
follow-up.

THIS TASK'S REMAINING DECIDABILITY CONTENT is therefore the OTHER THREE frame classes -- Base,
Dense and RTime -- plus the completeness corollaries through the tableau. The tableau spine remains
the only route FILED for Base, Dense and RTime; that is not the same as being the only route to any
decidability result. Two verified refinements of what "the other three classes" means:

  - At RTime the biconditional is already available by the same canonical-model route, not only by
    the spine: `FormalSystem.Metalogic.soundness_rtime_valid` (Soundness.lean:1565) and
    `FormalSystem.Metalogic.BXCanonical.completeness_rtime_engine (psi : Formula) :
    ValidRTime psi -> Derivable FrameClass.RTime [] psi`
    (FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:598). The open ingredient at
    RTime is therefore a decision procedure for `ValidRTime`, not the biconditional.
  - No `Decidable (ValidRTime ...)`, `Decidable (ValidDense ...)` or `Decidable (Valid ...)`
    declaration exists anywhere in FormalSystem/ at revision time (grep, Lean files only), so
    Base, Dense and RTime have no decision procedure for validity by any route today.

NEITHER THIS TASK NOR THE SPINE DELIVERS THE FIRST DECIDABILITY THEOREM. Z-time validity of the
base language is already decided by `Compression.decidableValidZTime`, with its qualifiers, which
every statement of the result must carry: frame class `FrameClass.ZTime` ONLY; `phi : Formula`, the
base language with no stability operator; EMPTY premises. The empty-premise consequence form
`FormalSystem.Metalogic.Decidability.decidableSemanticConsequenceNil (sigma : Formula) :
Decidable (SemanticConsequenceIn ProofSystem.FrameClass.ZTime [] sigma)` sits beside it at
Compression/Assembly.lean:161, also `Gamma = []` only. Nothing in any of this licenses an
unqualified "TM is decidable" claim, and NO COMPLEXITY BOUND is asserted or implied -- do not write
one into the Typst or LaTeX decidability chapters, and do not drop the ZTime / `Formula` /
empty-premise qualifiers when recording the result there.

REFUTATION HALF UNCHANGED. Verified/Refutation/Core.lean proving `allClosed_derivable` as ONE
induction over `allRulesForFC fc` (`FormalSystem/Metalogic/Decidability/Tableau.lean:1657`),
discharged per rule by its admissibility lemma and its `ruleFrameClass r <= fc` hypothesis through
the RuleSpec GATE lemmas, with Dense/Discrete/Dedekind instantiating the generic theorem rather
than re-proving it, is untouched scope and still the core of this task. Neither target file exists
yet: FormalSystem/Metalogic/Decidability/Verified/ currently holds `Bridge/`, `Decidable.lean`,
`README.md`, `RuleSpec.lean` and `Termination/`, with no `Refutation/` subdirectory and no
`Provable.lean`. Task 482 remains a downstream consumer of `allClosed_derivable`, not an addition
to this scope. The budget-parameterised totality correction (task 428) and the O2/O3 ownership
assignment (task 429) in the addenda above both stand.

STALE REFERENCES IN THE ORIGINAL SCOPE TEXT, now marked PHANTOM NAME inline above (sweep
task, 2026-10-04 revision) rather than left as a standing flag -- the names below were never
corrected at their point of citation in the first paragraph, which is itself the defect this
sweep targets. Three names the first paragraph cites could NOT be verified in
FormalSystem/**/*.lean at revision time: `completeness_dedekind_of_engine`, `ValidDedekindDense`,
and `ValidFor` (used in the phrase "completeness corollaries ValidFor fc phi -> Derivable fc
[] phi"). `completeness_dedekind` and `ValidDedekind` are likewise absent from Lean sources and
survive only in prose at FormalSystem/Metalogic/README.md, FormalSystem/Metalogic/BXCanonical/
README.md and FormalSystem/Metalogic/WeakCanonical/RealModel/README.md -- all three corrected by
the same sweep to cite their own live replacements rather than repeating these names. The cited
anchor StrongCompleteness.lean:308 is inside `soundness_consequence`, not a Dedekind engine.

RE-VERIFIED 2026-10-04, SHARPER MATCH FOUND. `completeness_dedekind_of_engine` has a precise
renamed counterpart, not just a "nearest" one: `completeness_rtime_of_engine`
(`FormalSystem/Metalogic/StrongCompleteness.lean:729`), signature
`(engine : WeakCompleteness FrameClass.RTime) (phi : Formula) (h : ValidRTime phi) :
Derivable FrameClass.RTime [] phi` -- the exact `_of_engine` shape the phantom name was reaching
for, with `ValidRTime` (`FormalSystem/Semantics/Validity.lean:655`) standing in for the phantom
`ValidDedekindDense`/`ValidFor`. Its engine hypothesis is discharged unconditionally by
`completeness_rtime_engine` (`CompletenessDedekind.lean:598`), consumed in turn via
`countermodel_dedekind_dense` (`CompletenessDedekind.lean:325`). Whoever picks this task up
should state the completeness corollaries against `completeness_rtime_of_engine`'s pattern at
RTime, and its `ValidZTime`/sibling analogues at the other three frame classes, rather than
re-deriving the shape from scratch.

---

### 411. Prove hard admissibility lemmas for until since trichotomy discrete and dedekind rules
- **Effort**: 15-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 410
- **Parent**: Task 165

**Description**: Track B part 2 for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.2-3.3 and 10). First run a /literature acquisition pass for Reynolds 1992 and Reynolds 2003 (the untlNeg co-decomposition and the Dedekind gap axioms; report 02 section 10 flags in-repo literature as thin). Then prove the hard admissibility block in Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean: untlPos (branch 1 via until_F, branch 2 via self_accum_until — follow the axiom literally), untlNeg (Reynolds co-decomposition via absorb_until + left_mono_until_G; the single largest lemma — budget it its own dispatch), sncePos/snceNeg duals, orderTrichotomy (one-liner if Phase 2.2 kept branches syntactically equal to temp_linearity disjuncts — verify, do not assume), z1Rule (two-premise instance of z1 + two modus ponens, relies on same-label internalization from the predecessor task), densityRule/denseIndicatorClosure via density/dense_indicator, and the Dedekind rules via prior_U_gap/prior_S_gap/sep. Acceptance: all admissibility lemmas sorry-free; lake build green.

---

### 410. Internalize tableau branches and prove routine rule admissibility
- **Effort**: 12-18 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 429
- **Parent**: Task 165
- **Research**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/reports/01_internalize-routine-admissibility.md]
- **Plan**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md]

**Description**: Track B part 1 for the TM tableau decidability program (parent: task 165, plan plans/01_tableau-decidability-two-track.md, research reports/02_tableau-decidability-hard-research.md sections 3.1-3.4). Create FormalSystem/Metalogic/Decidability/Verified/Internalize.lean defining Branch.internalize (world labels via box/diamond nesting, time labels via U/S guards realizing the branch TimeOrdering; SETTLED constraints: internalization design over substitution — no cut or uniform-substitution admissibility exists in the tree — and z1Rule's two premises must stay at the same label). Then prove the routine admissibility lemmas in Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean (~21 lemmas: 8 propositional, 4 S5 modal, 1 boxTemporal, 8 temporal universal/existential), each stated as rule_admissible per report 02 section 3.1 with hypothesis ruleFrameClass r <= fc, reusing Combinators.lean, ModalS5.lean, TemporalDerived.lean, GeneralizedNecessitation.lean, and DeductionTheorem.lean via DerivationTree.lift. Acceptance: all lemmas sorry-free, lake build green, RuleSpec GATE lemmas still green.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**:
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the 25 tooling modules (DatasetGenerator, DatasetAssembly, FormulaEnumerator, DataExport, ProofFirstBenchmark, the *Main exe roots and the rest) from FormalSystem/Automation/ to a root-level lean_lib BimodalTools, namespace BimodalTools, with tests under Tests/BimodalToolsTest/. This task's partial work was committed before the move (task 632 gated its move on a clean git status for FormalSystem/Automation/), so nothing was lost, but every path in this task's plan and handoff that names a tooling module is stale: re-derive before resuming. The library half (Tactics/, ProofSearch/, SuccessPatterns) stays under FormalSystem/Automation/. file_scope widened to include BimodalTools/ and Tests/BimodalToolsTest/. Build the tooling with lake build BimodalTools; a default lake build no longer compiles it, and a green lake build does not prove the exe roots compile (gate on the build-inclusive check-module-invariants.sh, C25). Tasks 231, 282 and 296 depend on this task.

SCOPE NARROWED (2026-09-28): file_scope's BimodalTools/, FormalSystem/Automation/ and Tests/BimodalToolsTest/ directory-wide entries were an inherited blanket widening from task 632's relocation note, not a derived surface for this task. Replaced with the specific paths this task actually touches per its own description (fixing the c7 labeling/timeout bug in the dataset generator and regenerating c7): BimodalTools/DatasetGenerator.lean, Tests/BimodalToolsTest/DatasetGeneratorTest.lean. Re-widen at this task's own research/plan time if the chosen approach implicates more files.

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]
- **Summary**: [296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the 25 tooling modules (DatasetGenerator, DatasetAssembly, FormulaEnumerator, DataExport, ProofFirstBenchmark, the *Main exe roots and the rest) from FormalSystem/Automation/ to a root-level lean_lib BimodalTools, namespace BimodalTools, with tests under Tests/BimodalToolsTest/. This task's partial work was committed before the move (task 632 gated its move on a clean git status for FormalSystem/Automation/), so nothing was lost, but every path in this task's plan and handoff that names a tooling module is stale: re-derive before resuming. The library half (Tactics/, ProofSearch/, SuccessPatterns) stays under FormalSystem/Automation/. file_scope widened to include BimodalTools/ and Tests/BimodalToolsTest/. Build the tooling with lake build BimodalTools; a default lake build no longer compiles it, and a green lake build does not prove the exe roots compile (gate on the build-inclusive check-module-invariants.sh, C25).

SCOPE NARROWED (2026-09-28): file_scope's BimodalTools/, FormalSystem/Automation/ and Tests/BimodalToolsTest/ directory-wide entries were an inherited blanket widening from task 632's relocation note, not a derived surface for this task. Replaced with the specific paths this task actually touches per its own description (re-adding the 6 derived binary temporal operators to the enumerator/canonicalizer): BimodalTools/FormulaEnumerator.lean, BimodalTools/AtomCanonicalization.lean, Tests/BimodalToolsTest/EnumeratorCountsTest.lean. Re-widen at this task's own research/plan time if the chosen approach implicates more files.

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

**Description**: Flip complexity-9 dataset generation from stratified to exhaustive-by-default once feasibility is confirmed. Prior work (see plans/01_exhaustive-enumeration-plan.md, handoffs/phase-1-6-handoff-20260714.md) verified the 0-sentinel/.take-guard machinery is already correct and unlimited-capable, and corrected stale infeasibility claims in data/README.md and scripts/run_dataset_generation.sh. The next action is the deferred c9 feasibility probe (Plan Phase 2), followed -- pending a GO verdict and explicit user approval for the multi-hour compute -- by c8/c9 exhaustive regeneration and HF Hub republication (Phases 3, 4(rest), 5, 6(rest), 7).

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the 25 tooling modules (DatasetGenerator, DatasetAssembly, FormulaEnumerator, DataExport, ProofFirstBenchmark, the *Main exe roots and the rest) from FormalSystem/Automation/ to a root-level lean_lib BimodalTools, namespace BimodalTools, with tests under Tests/BimodalToolsTest/. This task's partial work was committed before the move (task 632 gated its move on a clean git status for FormalSystem/Automation/), so nothing was lost, but every path in this task's plan and handoff that names a tooling module is stale: re-derive before resuming. The library half (Tactics/, ProofSearch/, SuccessPatterns) stays under FormalSystem/Automation/. file_scope widened to include BimodalTools/ and Tests/BimodalToolsTest/. Build the tooling with lake build BimodalTools; a default lake build no longer compiles it, and a green lake build does not prove the exe roots compile (gate on the build-inclusive check-module-invariants.sh, C25).

SCOPE NARROWED (2026-09-28): file_scope's BimodalTools/, FormalSystem/Automation/ and Tests/BimodalToolsTest/ directory-wide entries were an inherited blanket widening from task 632's relocation note, not a derived surface for this task -- this task's own description names no BimodalTools/ module edit, only the deferred c9 feasibility probe and the dataset-generation mode flip. Dropped all three directory entries and added scripts/run_dataset_generation.sh, the mode-flip target this task's description names as its next action but never previously declared. Re-widen at this task's own research/plan time if the chosen approach implicates more files.

---

### 257. Large data storage huggingface
- **Status**: [BLOCKED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

**Description**: Complete the Hugging Face Hub migration for large dataset storage. Prior work (see plans/01_implementation-plan.md, summaries/01_execution-summary.md) removed Git LFS tracking from .gitattributes and rewrote data/README.md to point at HF Hub (logos-labs/bmlogic-bench) as the canonical source, but Phase 1 -- the actual upload to HF Hub via the existing data/hf-dataset/upload.py pipeline -- was never executed because it requires user HF authentication. This task is blocked on that credential; once supplied, run the upload, validate, and confirm data/hf-dataset/PUBLISHING.md's 'Migration Status' header reflects completion.

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.
=== ITEM (7) TARGETS A DISPOSABLE DEPLOY ARTIFACT -- CORRECTED 2026-08-24 ===

Item (7) above says "Integrate into agent context (.claude/context/project/dataset/)". DO NOT WRITE
THERE. Verified 2026-08-24: `.claude/` in this repository is fully gitignored (`.gitignore:81`) with
zero tracked files, and is regenerated wholesale from a source store that is NOT in this repository
-- it lives at /home/benjamin/.config/nvim/agent-system/, a separate git repo. A file written to
`.claude/context/project/dataset/` will be silently destroyed on the user's next agent-system
reload.

Item (7) therefore CANNOT be completed from inside this repository. Two acceptable dispositions,
both of which require asking the user first:

  (a) DROP item (7) from this task's scope and record why. The other seven sub-targets of this task
      are ordinary repository work (`data/scripts/sync-all.py`, `data/README.md`,
      `data/dataset-card.md`, `croissant.json`, the splits file, schema validation, contamination
      check) and are unaffected. This is the recommended default -- it keeps the task in one repo.
  (b) Split item (7) into a task filed in the nvim repository's own tracker
      (/home/benjamin/.config/nvim/specs/state.json), targeting
      agent-system/extensions/<appropriate-extension>/context/, and committed there.

Do not silently satisfy item (7) by writing into `.claude/`.
=== ITEM (7) DROPPED FROM SCOPE -- 2026-08-24, user decision ===

Item (7) ("Integrate into agent context (.claude/context/project/dataset/) so /implement for
dataset tasks runs sync-all as post-implementation step") is REMOVED from this task's scope. It is
not a defect and not deferred -- it is out of scope here, permanently, and no successor task owns
it in this repository.

WHY. The disposition options recorded above were put to the user on 2026-08-24 and option (a) was
chosen. Three considerations decided it:

  1. `.claude/` here is gitignored (`.gitignore:81`, zero tracked files) and regenerated wholesale
     from /home/benjamin/.config/nvim/agent-system/, a separate git repo. A file written to
     `.claude/context/project/dataset/` is destroyed on the next agent-system reload.
  2. Filing it in the nvim tracker instead was considered and declined. There is no `dataset`
     extension in that source store (verified 2026-08-24: core, cslib, email, epidemiology,
     filetypes, formal, founder, latex, lean, literature, memory, nix, nvim, present, python,
     slidev, typst, web, z3), and a BimodalLogic-specific post-implementation hook placed in the
     shared global agent-system would deploy to every repository that loads it. It would have to be
     generalized into a repo-local hook mechanism first -- a different and larger piece of work
     than this task.
  3. The `.syncprotect` escape hatch (project root; honored by deploy-headless.sh and the picker's
     sync path) would survive a reload, but leaves the file untracked and unbacked-up in a repo
     where everything else is version-controlled.

WHAT REMAINS IN SCOPE. Items (1) through (6) and (8), unchanged and unaffected -- they are ordinary
repository work under `data/`: `data/scripts/sync-all.py`, `data/README.md`,
`data/dataset-card.md`, `croissant.json`, `bmlogic-bench-splits.json`, schema validation, the
train/benchmark contamination check, and the metadata-key consistency check. Do not treat the
removal of item (7) as reducing any of them.

IF THE HOOK IS WANTED LATER. `sync-all.py` is a plain script with CI-friendly exit codes (item 5).
Wire it from repository CI or run it manually after a regeneration. That reaches the same outcome
without depending on agent-system context at all.

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the dataset tooling out of FormalSystem/Automation/ into a root-level lean_lib BimodalTools (outside defaultTargets) and re-rooted the 12 lean_exe targets under BimodalTools.*. The lake exe target NAMES are unchanged (benchmark_oracle, dataset_generator, proof_extractor and the rest), so command lines in this task still work, but every source path is now BimodalTools/<Module>.lean and every tooling test is under Tests/BimodalToolsTest/. A default lake build no longer compiles the tooling; build it with lake build BimodalTools.

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 635, Task 641

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness and completeness on a concrete formula, plus decidability of the propositional fragment (genuinely complete today, per the soundness/completeness metatheory's axiom-clean status). Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

REALIGNMENT CORRECTION (task 468, 2026-08-25, carried from specs/reviews/review-2026-08-24.md
amendment M-7, independently re-confirmed at realignment time): the struck original acceptance
criterion above ("Complete worked example showing soundness-completeness-decidability on a
concrete formula") is RESCOPED. Decidability of TM (the full bimodal logic) is still open --
re-confirmed fresh this dispatch: grep -rn "isValid" FormalSystem/Metalogic/Decidability/ shows no
declaration takes DecisionProcedure.isValid as its subject, and ruleSound_of_mem_allRulesForFC is
not lifted to any allClosed -> valid theorem. `truthAt_of_isValid`
(Verified/Decidable.lean:2412) is NOT evidence of decidability -- it concerns a different,
semantic-side `SoundnessLemmas.IsValid`, not the decision procedure's `DecisionProcedure.isValid`.
Do not cite it as such. This task's decidability example is therefore rescoped to the
propositional-fragment case (genuinely decidable today) rather than the full logic; a full-logic
decidability example remains gated on the decidability/tableau front (410-465,
480-482) landing.

Reconciliation note (task 629): depends on task 635 (Expressiveness extraction), which renames the Kamp-named results this task cites. Task 632 (BimodalTools split) also edits Examples/BimodalProofs.lean's imports; that overlap is covered transitively via task 635's own dependency chain (635 <- 634 <- {632,633}), so no separate edge to 632 is added here.

POST-RELOCATION NOTE (2026-09-21). Dependency 635 is complete. It moved 141 modules from FormalSystem/Metalogic/WeakCanonical/ to FormalSystem/Metalogic/Expressiveness/ with the namespace rename WeakCanonical.X -> Expressiveness.X (the Kamp development is at Metalogic/Expressiveness/Kamp/), renamed 12 paper-numbered files to content names, and deleted 2 declaration-free stubs. The old-to-new name table is in specs/635_expressiveness_extraction/summaries/01_expressiveness-extraction-move-summary.md: cite results by their new names. Kamp/Section5Correspondence.lean was deliberately NOT renamed, so that a reader searching 'Section 5' finds it. Task 636 then stripped Logos and ProofChecker wording and personal paths from FormalSystem/Examples/ docstrings and installed the ## References normal form (docs/development/REFERENCE_NORMAL_FORM.md, keys in the root references.bib): new example files follow it. Examples/BimodalProofs.lean and Examples/Walkthrough.lean now import specific Automation modules and not the aggregator, since the tooling half left for lean_lib BimodalTools.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 178, Task 282, Task 296, Task 298, Task 428, Task 429, Task 430, Task 464, Task 465, Task 481, Task 482, Task 534, Task 543, Task 568, Task 623, Task 628, Task 635, Task 636, Task 645, Task 646, Task 683, Task 684, Task 685, Task 696, Task 703, Task 706

**Description**: Update README.md, docs/, and FormalSystem/ module-level docstrings to their final post-refactor state, once the decidability chain (426, 428, 429, 430, 432, 433, 434) lands. This is the final polish pass, distinct from and run after task 472's already-completed immediate correction pass. Explicitly excludes: every item task 472 already corrected (the Decidability.lean Status block, Verified/README.md, FMP/README.md, DecisionProcedure.lean's decideAuto docstring, Verified/Decidable.lean's Status docstring, WeakCanonical.lean, RealModel/ShuffleReal.lean, Soundness.lean, PriorExpressivenessDense.lean) and the two Kamp files task 473 already swept (Kamp/EANegationClosure.lean, NfMultiAnchorBridge/NavigatedSpine.lean). This task's residual content is: re-auditing all touched documentation for drift accumulated during the decidability chain's landing (472/473 audited a snapshot; the chain's remaining tasks will touch further files after 472/473 ran), and the Axiom Reference update the charter names as part of 177's original scope.

REALIGNMENT NOTE (task 468, 2026-08-25, verdict per specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md §6): DIVIDE, already half-executed exactly as specs/reviews/review-2026-08-24.md amendment 10f states -- tasks 472 (documentation correction pass) and 473 (Kamp vacuity deletion) already ran the ungated half; the description above is the remaining, gated half's text. `file_scope` (README.md, specs/ROADMAP.md, FormalSystem/, docs/) was already repaired by task 470 item (G) and is confirmed resolvable, no duplicate -- left unchanged here.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 530 (documentation single source of truth + theorem index, from specs/reviews/review-2026-09-01-lean-engineering.md) is the UN-GATED metalogic half of this charter and is now a dependency; this task remains the gated post-decidability-chain pass and its residual shrinks to re-auditing drift the decidability chain introduces plus the Axiom Reference update.

Reconciliation note (task 629): gains dependencies on task 635 (Expressiveness extraction) and task 636 (docstring and citation normalisation), in addition to its existing 428/429/430 dependencies. Kept separate from task 636 rather than merged: this task's residual scope (re-auditing documentation drift the decidability chain introduces, plus the Axiom Reference update) is materially different from task 636's citation-form/bibliography normalisation work.

POST-RELOCATION REVISION (2026-09-21, after tasks 626, 630 and 632-636 landed). Dependencies 635 and 636 are complete. (A) PATHS CHANGED under this task's description: the archive is a root-level Boneyard/; 25 tooling modules left FormalSystem/Automation/ (and Metalogic/Decidability/TraceExport.lean) for a root-level lean_lib BimodalTools; FormalSystem/Tactic/ is new; Syntax/ and Semantics/{Plus,Minus,Star}Language/ merged into FormalSystem/{X}Language/ with flat FormalSystem.{X}Language namespaces; 141 modules moved from Metalogic/WeakCanonical/ to Metalogic/Expressiveness/ (Kamp/, Separation/, GameTransfer/, EFGames/ are there now) and 12 files took content names. The Kamp files named in the exclusion list above live under Metalogic/Expressiveness/Kamp/. Re-derive every path. BimodalTools/ is in scope for module-docstring work; Boneyard/ is not. (B) CITATION FORM: write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, each key resolving in the root references.bib; typst/bibliography.bib no longer exists. Historical and provenance statements are preserved verbatim, never rewritten to current paths (Semantics/TaskFrame.lean's 'Known gaps... recorded as closed' block, Metalogic/Soundness.lean's 'app:valid... never existed' block, Boneyard provenance READMEs, typst/SYNC-MAP.md, ADR histories). sub: anchors stay verbatim. (C) ITEMS FOLDED IN from the batch's recorded follow-ups, each outside the recording task's scope. Docstring and documentation edits only. (C1) FormalSystem/Theorems/TemporalDerived.lean's ### Removed section names two archive files that do not exist, Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean and Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean; both directories hold only a README.md. Repairing it needs knowledge of where those 27 definitions went; find out from git history. (C2) FormalSystem/Examples/TemporalStructures.lean:21 cites the JPL paper as 'The Perpetuity Calculus of Agency'; the paper this repository formalizes is 'The Construction of Possible Worlds'. Determine whether it names a different work; if the same, correct and cite by bibkey; if different, leave and report. (C3) BimodalTools/TraceExporterMain.lean carries a verbatim-duplicated leading module docstring (lines 16-49 repeated at 51-86, the second with one extra bullet); keep one copy with the extra bullet. (C4) Task-number citations survive in body prose outside ## References, notably Tests/BimodalTest/Automation/TacticsTest.lean's ## Test Coverage and ## Test Organization; the task-reference lint does not scan Tests/ or FormalSystem/, so they are ungated. Grep FormalSystem/, BimodalTools/ and Tests/ and replace each with a durable anchor. The lint lives under .claude/, a deploy artifact with no source store in this repository: do not edit it here; record the scan-root gap for an upstream fix. (C5) The 34 chunk_00NN citations in 15 files under FormalSystem/Metalogic/Expressiveness/Kamp/ (NfMultiAnchorBridge/ and neighbours) point into a corrupt markdown conversion. Kamp/Section5Correspondence.lean records that they 'should be re-cited by page as they are touched'. Re-cite by page from a sound copy of the source (run with --lit); where a page cannot be established, leave the citation and list it; never guess a page. (C6) FormalSystem/Metalogic/README.md's aggregator table has one '<!-- TODO: add description -->' for Deterministic.lean. (C7) docs/development/PUBLICATION_REFACTOR.md:476, the Phase 7 bullet, is still future-tense though task 636 closed that phase; past-tense it; line 597 stays verbatim, being a quoted task brief. (C8) USER DECISION, STILL OPEN, carried from task 636: at FormalSystem/Metalogic/Expressiveness.lean:67,69 the dangling keys stavi1979 and gabbay1980 were re-pointed to gabbay1994 (Ch.9 s.3 and Ch.10), a default the user never confirmed. The bibliography merge then brought in gpss1980 (Gabbay, Pnueli, Shelah and Stavi 1980), a plausible better match for the gabbay1980 site. Which source was intended is not derivable from the repository: ask the user; never author a bibliography entry whose details cannot be verified. SCHEDULING: C1-C8 do not depend on the decidability chain. If that chain stays open, split C1-C8 off with /task --expand instead of letting them wait.

SCOPE NARROWED (2026-09-21): file_scope previously named the whole of FormalSystem/ and docs/, which made every library task flag an overlap with this one at admission. It now names only the paths this description cites (C1-C8, the Axiom Reference, the decidability directory for the gated re-audit). The re-audit is open-ended by design: re-derive and widen file_scope at research time. Dependencies on 534, 543, 568, 628, 645 and 646 added because each also edits the root README.md and this task is the final pass that runs after them.

FURTHER EDGES (2026-09-21): dependencies on 178, 282, 296, 298, 464, 465, 481 and 482 added, each sharing a named path with this task (Examples/TemporalStructures.lean; BimodalTools/TraceExporterMain.lean; Metalogic/Decidability/). This task is the final pass and runs after them. Note 481 is blocked and 282, 296 and 298 are partial: if any of them is abandoned the edge is satisfied; if one stalls indefinitely, drop its edge rather than hold this task.

FURTHER EDGES (2026-09-28): the whole-directory FormalSystem/Metalogic/Decidability/ entry is retained, not narrowed, because this task's own description already defers that narrowing: "The re-audit is open-ended by design: re-derive and widen file_scope at research time." Narrowing it now, before the decidability chain lands, would be exactly the guessing this task's charter prohibits. scripts/validate-state.sh Check 8 currently reports this entry overlapping 8 non-terminal tasks (428,429,430,464,465,481,482,696); 7 of the 8 (428,429,430,464,465,481,482) were already dependency-gated. 696 was not -- it declares Decidability/PlusWitnessFamily/* and Decidability/WitnessFamily/Sharing/*, both under this directory -- so 696 is added to dependencies below to close that one real exposure. The existing "if one stalls indefinitely, drop its edge rather than hold this task" clause (see the 2026-09-21 FURTHER EDGES note above) extends to this new edge.

---

### 125. Jonsson tarski representation bimodal sus
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 498, Task 499

**Description**: CAPSTONE of the algebraic representation front. Prove the Jonsson-Tarski representation theorem for the bimodal logic: the embedding eta(a) = {U | a in U} is an injective STSA homomorphism A -> Cm(Uf(A)).

RE-SCOPED. This task's original four phases are now distributed: Phase 1 (complex algebra Cm(F)) and Phase 2 (ultrafilter frame Uf(A), including the Spherical obligation) are separately tasked and are this task's dependencies; Phase 4 (binary untl/snce operators) is separately tasked and depends on this one. What remains here is Phase 3 -- the embedding itself and its injectivity -- stated at the unary signature (box, G, H, sigma).

PREREQUISITE STATE, RE-VERIFIED 2026-08-26: the STSA class and the R_G/R_H/R_Box ultrafilter frame exist as Boneyard seeds behind #exit and are ported by the dependency tasks. The MCS-to-ultrafilter bijection is live at Algebraic/UltrafilterMCS.lean:782 (ultrafilter_correspondence), though stated existentially rather than as a named Equiv -- converting it to an Equiv may be worth doing here. The BooleanAlgebra LindenbaumAlg instance is at BooleanStructure.lean:421.

THE PRIOR PREREQUISITE LIST IN THIS DESCRIPTION IS STALE and is superseded: it named 'resolve 6 algebraic sorries in TenseS5Algebra/InteriorOperators/LindenbaumQuotient'. InteriorOperators.lean and LindenbaumQuotient.lean are sorry-free today; the remaining sorries are the 3 in the Boneyard TenseS5Algebra seed, and they are for REMOVED axioms (temp_a, temp_l) that must be restated against the current 45-constructor axiom set rather than proved as-is. That is the STSA port task's business, not this one's.

LITERATURE: Goldblatt 1989 'Varieties of complex algebras' (APAL 44, 173-242, doi 10.1016/0168-0072(89)90032-8) has been acquired. CAVEAT THAT MUST BE HONORED: the acquired PDF is an Acrobat 3.0 Capture scan with a badly degraded OCR text layer -- math-heavy pages yield mangled symbols, dropped and reordered lines. READ THE PAGE IMAGES DIRECTLY (the Read tool's pages parameter); do NOT rely on a pdftotext-derived conversion for any axiom statement or equation. Blackburn/de Rijke/Venema 2002 Chapter 5 (corpus entry blackburn_2002) is the primary reference and is born-digital.

MATHLIB HOOK: Order/Atoms.lean:710 (toSetOfIsAtom : alpha <-> Set {a // IsAtom a} for CompleteAtomicBooleanAlgebra) is the atom-structure half of Stone/Jonsson-Tarski for the complete atomic case and is the single most relevant Mathlib lemma here; supporting lemma eq_setOf_le_sSup_and_isAtom at :695. Mathlib has NO Stone duality for Boolean algebras and no BAO machinery -- the rest is greenfield.

SEE ALSO the reconciliation task on whether this embedding can be factored through ShiftSet.lean's reverse_repr rather than built independently; if it can, that supersedes part of this task's construction and this description should be revised again before implementation starts.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 528 (Algebraic/ modernisation: propDecide in BooleanStructure.lean, SetMaximalConsistent.ultrafilterEquiv as a named Equiv, the bespoke `Ultrafilter` structure reconciled with Mathlib Order.PFilter/Ideal.IsPrime, Multiset.inf; from specs/reviews/review-2026-09-01-lean-engineering.md findings D-08, F-11, F-12, F-13) must land first so this task builds on the modernised algebra rather than inheriting a shadowed Ultrafilter name and ~430 lines of hand-built Boolean algebra.
