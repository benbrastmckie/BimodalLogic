---
next_project_number: 933
---

# TODO

## Task Order

*Updated 2026-11-14. Generated from state.json dependency graph.*

**Goal**: Close the residual repository-hygiene backlog

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 178,257,298,428,481,502,570,604,664,713,734,761,829,831,869,890,926,931,932 | -- | algebraic-representation, completeness, dataset-enhancement, ... |
| 2 | 231,282,296,429,497,763,862,873 | 298,428,502,761,869 | algebraic-representation, dataset-enhancement, decidability, ... |
| 3 | 410,498,499,500,861,874,875,876 | 429,497,763,873 | algebraic-representation, decidability, metalogic, ... |
| 4 | 125,411,543 | 410,498,499,500 | algebraic-representation, decidability, metalogic |
| 5 | 430,501 | 125,411 | algebraic-representation, decidability |
| 6 | 412 | 430 | decidability |
| 7 | 482 | 412 | decidability |
| 8 | 177 | 178,282,296,481,482,543 | formula-refactor |

**Grouped by Topic** (indented = depends on parent):

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

926 [RESEARCHED] — DECISION RECORD ONLY -- report only, file\_scope: ], no Lean...

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
734 [HOLD] — Run experiment E4: decide StabSaturated on the Bool fixture's...
761 [BLOCKED] — AMENDED 2026-10-18 (presentation chosen): the cell...
  └─ 763 [NOT STARTED] — AMENDED 2026-10-11 (index deletion): the finite cell index...
    └─ 861 [RESEARCHED] — Record the one-sided transport refutation in the RaySummary...
  └─ 862 [RESEARCHED] — Promote cntAt\_eq\_of\_pend\_eq\_fwd into LadderAgree as a...
831 [NOT STARTED] — RESEARCH TASK, verdict-first. State and attempt the...

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

### Semantics

869 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...

### Build Performance

829 [NOT STARTED] — NO BUILD CACHE FOR .lake/build IN ANY CI WORKFLOW. Every CI...

### Syntax

873 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...
  └─ 874 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...
  └─ 876 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...

### Uncategorized

931 [NOT STARTED] — Apply the final-frame amendments to the 901 two-sided...
932 [NOT STARTED] — Land the four ofStepRel constraint lemmas and an ofStepPlain...

## Tasks

### 932. Land the four ofStepRel constraint lemmas and an ofStepPlain constructor in IntNormalForm.lean
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: None

**Description**: FRAME-PRESENTATION API ONLY. Land five declarations in FormalSystem/Semantics/IntNormalForm.lean, plus one equation lemma, and rewrite `ofStepSat`'s body to cite them instead of duplicating them.

THE DECLARATIONS. `ofStepRel_reflective`, `ofStepRel_compositional`, `ofStepRel_serial`, `ofStepRel_limit`, the `ofStepPlain` constructor, and the `ofStepPlain_taskRel` equation. Their statements and compiled proof bodies are transcribed VERBATIM in specs/927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md, Appendix probe A. Cite them from there; do not restate or re-derive them here. All six elaborated sorry-free through `lean_run_code`, and the downstream composition reports axiom profile [propext, Classical.choice, Quot.sound].

WHY THIS IS A REFACTOR, NOT NEW MATHEMATICS. The four constraint proofs ALREADY EXIST in the library as inline lambdas inside `FrameOver.ofStepSat` (IntNormalForm.lean:563 at measurement time). This task names them. `ofStepSat` then becomes `ofStepPlain` wrapped by `ofReflectiveRegular`, so no existing signature changes and no proof body is duplicated -- which is the point: a duplicated transcription can diverge, a citation cannot.

THE IDIOM TO USE. The remeasurement report's Tactic Survey isolates it: prove each constraint as a BARE-RELATION lemma and transport with `|>`, never by rewriting a frame's `TaskRel` in place. Rewriting in place does not go through.

THIS FORMALIZES NO PART OF SECTIONS 7-15. It is frame-presentation API in IntNormalForm.lean. It formalizes no chronicle, no hue, no ban, no lull and no truth lemma. The 901 report's Recommendation 8, which bars formalizing sections 7-15 of the Reynolds engine paper proof, is UNTOUCHED by this task and must stay untouched. Landing these lemmas does not make T3 complete and is not a completeness claim; it discharges the single named condition the remeasurement report's Finding (4) attaches to its `conditionally discharged` verdict.

COUPLED GENERATED SURFACES -- inherited at filing time, not to be discovered at the first commit. A Lean line-count change moves two generated surfaces. (1) `typst/generated/status.typ` carries `formalsystem-line-count` and its check is PRE-COMMIT BLOCKING: regenerate via `bash .claude/scripts/typst-sync-check.sh --fix` in the SAME phase as the line-count change, not in a later reconciliation phase. (2) The module-inventory blocks in `README.md` and `FormalSystem/Metalogic/README.md` are checked later and may be deferred to a reconciliation phase: regenerate via `bash .claude/scripts/check-module-invariants.sh --emit-inventory`. All three are in this task's file_scope for that reason.

---

### 931. Apply the final-frame amendments to the 901 two-sided Reynolds engine paper-proof report
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Dependencies**: None

**Description**: RECORD CORRECTION, no Lean. The 901 paper-proof report records the final-frame step as resting on two unlanded Lean pieces. Both landed on 2026-11-09, four to six hours after that report was committed, so the row is STALE rather than wrong-at-the-time. Apply the amendment that has already been written.

SOURCE OF THE REPLACEMENT TEXT. specs/927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md, Finding (3), supplies VERBATIM replacement text for (i) the `**missing**` ingredient-table row, (ii) the adjacent compiled row's drifted line-number citations, (iii) the `weakest link` Risks paragraph (a full dated replacement), and (iv) a one-clause correction to the companion Risks paragraph. Do not re-derive any of it and do not re-measure the landing timestamps -- they are recorded in that Finding's table.

THE COMPLETE WORK LIST. specs/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md, the `#### Phase 1 Notes` section, carries the full SEVEN-anchor table with per-anchor disposition. Three of those anchors are NOT enumerated by Finding (3) and exist only in that table: the drifted citation pair inside the evidence/status table (line 1047 at measurement time), the same drift in the reads list (line 1075, where `exists_preimage_step_neg` is additionally cited at a stale `:306` and is live at `:335`), and the `OrientedForest.lean:134` citation inside the 15.3 route prose (line 908). Work from the Phase 1 Notes table, not from Finding (3) alone.

RE-LOCATE BY CONTENT. Every line number in both records is a measurement taken at that time and is explicitly labelled as such. Locate each anchor by its matched text, never by line number.

TWO THINGS THAT MUST NOT BE TOUCHED. (1) Section 15.2's assessment of why the chronicle quotient's OWN Saturation is doubtful -- countably infinite slices, the quotient is not an oriented forest -- is CORRECT and LOAD-BEARING. It is the reason the universal-cover route exists at all. Leave it exactly as written. (2) The 901 report's own refusal to claim the step (`This write-up does not claim the final-frame step; it claims the engine up to it`) sits inside the Risks paragraph being replaced. The replacement reframes what is landed; it does NOT lift that refusal. Preserve it.

The `**The two missing pieces, named.**` paragraph in 15.3 is stale by the same measure; Finding (3) directs its replacement to be the Risks amendment text rather than a separate rewrite.

THIS IS A RECORD CORRECTION, NOT A COMPLETENESS CLAIM. Applying it does not make T3 complete and does not advance the completeness programme. Rows 17-21 of the ingredient table remain paper, and (O1), (O3) and (O4) are untouched. The 901 report's Recommendation 8 -- which bars formalizing sections 7-15 -- is not affected by this amendment and must not be edited by it.

---

### 930. Wire orphan open core prototypes
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**: [930_wire_orphan_open_core_prototypes/reports/01_wire-orphan-open-core-prototypes.md]
- **Plan**: [930_wire_orphan_open_core_prototypes/plans/01_wire-orphan-open-core-prototypes.md]
- **Handoff**: [930_wire_orphan_open_core_prototypes/handoffs/phase-3-handoff-20261113-194604.md]
- **Summary**: [930_wire_orphan_open_core_prototypes/summaries/01_wire-orphan-open-core-prototypes-summary.md]

**Description**: Promote and wire the two orphan open-core prototypes into the evidence gate. RaySummary/README.md cites two standalone prototypes as the sole authority for two load-bearing refutations about the depth-0 open core, and explicitly flags each as "not a wired probe": (1) tight-chain-regime-b.lean, cited at README.md:1002 as settling that the only candidate device for the two cascades on a tight chain of pins -- a type-respecting block SPANNING a region start -- is refuted in BOTH directions as a consequence of the parameter conditions; (2) spanning-divisibility.lean, cited at README.md:1039 as settling that (K1) does not constrain a spanning block length, via the ALTERNATING path (idle at every even position, pending at every odd one) carrying a type-respecting block of every even length with a pin strictly inside it, so no single modulus divides them all. BOTH FILES NOW SIT IN GITIGNORED specs/archive/: specs/archive/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean and specs/archive/838_two_sided_open_core_pin_free_pigeonhole/prototype/spanning-divisibility.lean. This is the same defect class already repaired once for the WIRED_REPO entry that pointed into specs/archive/918_.../evidence/lowering-anchor-deficit.lean and made scripts/check-evidence-probes.sh exit 1 for every task in the repository: a compiled record the evidence gate does not hold, in a location git does not track, cited by the library as an authority. WORK: re-verify each prototype compiles against the live tree through the build guard; promote each to a tracked, durable path under specs/evidence/ alongside its siblings; wire each into scripts/check-evidence-probes.sh (table block plus WIRED array entry); update the two README citations to the new paths and drop the "not a wired probe" qualifier where it ceases to be true. VERIFY: bash scripts/check-evidence-probes.sh exits 0 with the wired pass count raised by exactly two and no other probe disturbed; #print axioms on every headline theorem of both files shows no sorryAx, no custom axiom and no native_decide; bash scripts/readme-lint.sh and bash .claude/scripts/check-task-references.sh --quiet each exit 0. If a prototype no longer compiles against the live tree, that is a finding to report with the goal state recorded, not a thing to repair by weakening the statement -- and it would mean a README authority claim is stale, which is the more serious outcome and must be surfaced rather than absorbed. Do not edit either archived original in place, and do not claim any reserved name.

---

### 929. Idle run length one forward slack discharge
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**: [929_idle_run_length_one_forward_slack_discharge/reports/01_idle-run-one-forward-slack.md]
- **Plan**: [929_idle_run_length_one_forward_slack_discharge/plans/01_idle-run-one-forward-slack.md]
- **Evidence**: [evidence/forward-slack-pin-cascade/idle-run-one-ceiling.lean]
- **Handoff**: [929_idle_run_length_one_forward_slack_discharge/handoffs/phase-3-handoff-20261113185153.md]
- **Summary**: [929_idle_run_length_one_forward_slack_discharge/summaries/01_idle-run-one-forward-slack-summary.md]

**Description**: Discharge the I = 1 idle-run sub-regime so ForwardSlackWitnessed becomes unconditional. Task 924 landed a cascade-free CONDITIONAL discharge: forwardSlackWitnessed_of_cell_idleRunPumpable (FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean:1035) concludes ForwardSlackWitnessed at EVERY amount from the amount-free, run-local premise IdleRunPumpable, by duplicating an idle block inside the idle run separating z's region from the next. It splices rather than deletes, so the refuted deletion route is not re-entered, and it spends none of (K2)'s cascadeBound. The premise is NOT ParamsOk-derivable: (K1) quantifies prodCycleLens, objCycleLens and satPeriod, never idleCycleLens. THE REMAINING GAP, named by 924 as its entire frontier: paths whose intervening idle run has length 1, where no repeat block exists to pump. Closing it is dischargeable on the pumpable side rather than refuted, which is why 924 left certStabK's restatement obligation PROVISIONAL rather than permanent. SCOPE AND WHAT THIS DOES NOT DO: discharging I = 1 removes ForwardSlackWitnessed from the five depth-0 cell-equality schemas of LadderCell.lean (cellLE_zero_const_of_kappa_eq_of_forwardSlack and its _commonShift_, _monotone_, _antitone_, _antitone_bounded_ siblings) and lifts certStabK's provisional obligation. It does NOT lift task 761's Phase 11.6 depth-0 gate: those schemas carry three further added-hypothesis families beyond forward slack (the equal-register restriction, the pending-forever gap with its threshold bound, and the common-shift / monotone / antitone displacement), each is strictly stronger in hypotheses than the reserved statement CellLEZeroConstOfKappaEq and bears on its truth value in neither direction, and 761 plan v12 separately settled that 924's route cannot feed a stab-depth induction because forwardSlackWitnessed_of_cell_idleRunPumpable carries hno (a STAB-FREE closure) at LadderIdle.lean:1040. Do not claim the reserved name cellLE_zero_const_of_kappa_eq on any branch. PROHIBITED: the (K1) amendment constraining spanning-block length, which 924 explicitly declined to admit. A refutation of the I = 1 case is an equally reportable outcome and must be compiled, not argued.

---

### 928. Muller torabin determinization cost assessment
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [928_muller_torabin_determinization_cost_assessment/reports/01_muller-torabin-cost-assessment.md]
- **Plan**: [928_muller_torabin_determinization_cost_assessment/plans/01_muller-torabin-cost-assessment.md]
- **Summary**: [928_muller_torabin_determinization_cost_assessment/summaries/01_muller-torabin-cost-assessment-summary.md]

**Description**: ASSESSMENT TASK, report only. Costs the single lemma that gates the Lean completeness line, and decides where it would live. Does NOT prove it.

WHY THIS LEMMA. specs/archive/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01 names `Muller.toRabin_exists` `the single highest-value proof_wanted in either tree`, and specs/archive/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01 row 16 names determinization to Rabin as the load-bearing gap with this as `its single named target`, explicitly labelled `Not a Mathlib-absence refusal; a located and costed gap`. specs/archive/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01 established WHY the Rabin pair shape is unavoidable: a deterministic Muller automaton suffices for the Auxiliary-Atoms rule, which carries no acceptance condition, but NOT for the ban/lull mechanism, whose banned list is indexed by the automaton's accepting pairs (Reynolds 2001 section 12, `bl : T -> (C x {1,...,K})*`). So the fork's already-proved `IsRegular.iff_da_muller` is not the determinization the architecture consumes end-to-end.

WHAT IS ALREADY SETTLED, and is not to be re-litigated: `Rabin.toParity_exists` is OFF the critical path (902: the ban mechanism consumes Rabin, not parity, and `Parity.toRabin_language_eq` is already proved). (O2) is discharged for free via `Muller.exists_iSup` under a union-on-the-Muller-side-then-determinize-once composition order. The existing cost estimate on record is the fork's own docstrings: an exponential pair blowup for DMA->DRA (`2^|Q|` pairs) and the LAR permutation construction for DRA->DPA.

DELIVERABLE, four findings:
  (1) The construction of record: which determinization is actually wanted here (Safra, Piterman, or the LAR route), sourced to the held corpus, with the reason the choice matters for the pair-indexed consumer rather than for the automaton alone.
  (2) A size and shape estimate for a Lean proof on THIS project's toolchain (Lean v4.33.0-rc1, Mathlib v4.33.0-rc1): what the statement looks like, what the induction is on, which Mathlib/CSLib pieces it can stand on, and which it would have to build. An order-of-magnitude line count with its basis is wanted; an unbasised number is not.
  (3) Siting: the local CSLib fork versus this tree. The fork is where `Muller.toRabin_exists` is currently `proof_wanted` and where `IsRegular.iff_da_muller` already lives, so the fork is the presumptive home -- but 902's standing recommendation is `Do not require anything now`, and ROADMAP records the CSLib `require` question as not to be re-opened on sections 7-15's account. State what siting in the fork would and would not commit this repository to, and whether a `require` decision is actually entailed by proving it there.
  (4) (O3) interaction: 902 records that the determinized automaton arrives as `an existential over Type, not as syntax`, making the Auxiliary-Atoms rule's `theta_f` non-computable under classical extraction. State whether a proof of `Muller.toRabin_exists` in the natural existential form would leave (O3) standing -- i.e. whether discharging (O1) alone unblocks the completeness line, or whether (O1) and (O3) must be discharged together.

GUARDRAILS: (a) assessment only -- no proof of `Muller.toRabin_exists` is attempted, and no `.lean` file is written or edited in either tree; (b) no edit to `lakefile.toml` or `lake-manifest.json`, and no `require` added in any form -- finding (3) ASSESSES the siting question and does not act on it; (c) no formalization of any part of the Reynolds engine's sections 7-15 (Recommendation 8), which this lemma is upstream of and separate from; (d) no completeness claim; (e) cite the fork's actual `proof_wanted` sites with file and line; (f) if the corpus does not hold the construction at the rigour needed to cost it, say so and name what is missing rather than estimating from memory.

FILE SCOPE: none. Report only.

---

### 927. Final frame step remeasure against landed cover
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md]
- **Plan**: [927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md]
- **Summary**: [927_final_frame_step_remeasure_against_landed_cover/summaries/01_final-frame-step-remeasure-summary.md]

**Description**: MEASUREMENT AND RECORD-CORRECTION TASK, report only. Answers one question: is the completeness paper proof final-frame step still open, given that both Lean pieces it was said to need have since landed?

THE SITUATION. specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md records the final-frame step as the paper proof one unclosed step. Its ingredient line reads `universal cover; invariance with no Saturation on the base | missing | the two Lean pieces the final-frame step needs`; its Risks section calls it `the weakest link`, naming as negative evidence that `plus_invariance_of_isZTime demands [F.IsRegular] on the base`; and it states `This write-up does not claim the final-frame step; it claims the engine up to it.`

BOTH NAMED PIECES ARE NOW LANDED, and the second is stronger than 901 anticipated:
  - Piece 1, the universal cover: specs/archive/897_universal_cover_oriented_forest_two_way_bounded landed `FormalSystem/Semantics/UniversalCover.lean` (519 lines) with headline `exists_orientedForest_cover`, plus `coverFrame`, `endpt_surjective`, `endpt_twoWayBounded`.
  - Piece 2, base-Saturation-free invariance: specs/archive/898_plus_invariance_base_without_saturation settled this AFFIRMATIVELY and went further than its own task description anticipated. Per its summary: Saturation is consumed NOWHERE in the `HistoryMorphism.lean` lifting chain, and the base frame needs NO `def:frame` constraint at all -- not even reflection. Only the SOURCE frame needs anything, and it needs exactly Compositionality, Seriality and Limit. It landed `plus_invariance_of_isZTime_of_constraints`, `exists_histMorphism_of_isZTime_of_constraints`, `taskRel_eq_iter_of_constraints`, and -- named in its own summary as `the completeness programme entry point over a base with no Saturation` -- `exists_orientedForest_cover_of_constraints`. 901 negative evidence is directly answered: the base `[F.IsRegular]` binder is now genuinely unread, and the one apparent base use (`F.reflection` inside `exists_preimage_step_neg`) is discharged at nonzero step duration by `TaskFrame.reflect_reflection_of_ne`. 898 also corrected the prose surfaces that had recorded Saturation as the obstruction, reframing it as a class-membership obligation, and wired `Tests/BimodalTest/Semantics/OrientedForestSaturationTest.lean` so the headline stops compiling if a base Saturation hypothesis is ever re-acquired.

901 and 898 both closed 2026-11-09, so 901 `missing` row is very likely STALE rather than wrong-at-the-time. Confirming that is part of the deliverable.

THE QUESTION THAT IS ACTUALLY STILL OPEN. Because the base side now demands nothing, the obligation has MOVED to the source side: does the chronicle quotient of 901 Finding 15 satisfy Compositionality, Seriality and Limit? 901 describes that quotient as a time-sliced digraph with countably infinite slices, and notes its Saturation `is a real obligation here (unlike in Reynolds Kripke setting, which has no such axiom)`. Nobody has checked the quotient against 898 source-side hypothesis set. That check is this task.

DELIVERABLE, four findings:
  (1) Whether `exists_orientedForest_cover_of_constraints` + `saturation_of_orientedForest` + `plus_invariance_of_isZTime_of_constraints` discharge the final-frame step AS 901 Finding 15 STATES IT -- checked against the landed declarations actual signatures in source, not against either report prose.
  (2) The source-side obligation, stated precisely: what Compositionality, Seriality and Limit each require of the chronicle quotient, and which of the three (if any) is not evidently satisfied. This is the finding with the most expected content.
  (3) A verdict on 901 ingredient row and Risks paragraph: stale, partially stale, or still accurate -- and if stale, the exact amendment text each needs. Do not edit 901 report in place; supply the amendment for a successor to apply.
  (4) Whether the final-frame step is now discharged, conditionally discharged (naming the condition), or still genuinely open (naming what is missing).

WHY THIS NEEDS NO RULING. The final-frame step is section 15, and this task neither formalizes it nor formalizes any part of sections 7-15: it measures whether already-landed declarations discharge it and corrects a stale record. Recommendation 8 bars filing a FORMALIZATION of sections 7-15; it does not bar reading landed signatures and reporting what they compose to. If finding (1) and (4) come back positive, the paper proof one acknowledged gap closes without reversing any ruling -- which is why this is the cheapest high-value question on the completeness front.

GUARDRAILS: (a) read declaration signatures from source, never from a report description of them -- 901 own stale row is the cautionary case; (b) no Lean file written or edited -- if a composition is available, state it as a finding with declaration names, do not land it; (c) no formalization of any part of sections 7-15; (d) no completeness claim, and in particular finding (4) positive does NOT make T3 complete -- rows 17-21 remain paper; (e) do not edit 901 or 879 reports in place, supply amendment text; (f) if the source-side check needs the chronicle quotient stated more precisely than 901 Finding 15 states it, record that as the blocker rather than inventing a formalization of it.

FILE SCOPE: none. Report only. Reads FormalSystem/Semantics/UniversalCover.lean, HistoryMorphism.lean, IntNormalForm.lean, StateTopology/ConstraintWitnesses.lean; writes no Lean.

---

### 926. Lean completeness line reopen decision record
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: completeness
- **Dependencies**: Task 927, Task 928
- **Research**: [926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md]

**Description**: DECISION RECORD ONLY -- report only, file_scope: [], no Lean file written, no formalization attempted. The deliverable is a ruling with its argument, nothing else.

WHY THIS EXISTS. The completeness front currently has zero tasks of any kind: no active record carries topic `completeness`, and none of the four routes named below is owned by any record. That is not because the mathematics is settled or abandoned -- specs/archive/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md Deliverable 4 returns GO for T3 as a staged paper programme -- but because specs/archive/901_two_sided_reynolds_engine_paper_proof's Recommendation 8 bars filing a Lean formalization of the Reynolds engine's sections 7-15, and ROADMAP.md records that lifting it `needs a fresh user ruling reversing that`. A research dispatch cannot reverse a user ruling, so the gap on this front is a DECISION, not missing information.

WHAT IS ALREADY KNOWN, and must be read rather than re-derived (these four reports already constitute the scoping research; do not restate them):
  - 879 reports/01: the 21-row ingredient table with per-row status; rows 17-21 (consistency of phi-plus, ban preservation with LCU, two-sided universal non-acceptance, fair scheduling, the two-sided truth lemma) are `paper`; row 16 names determinization to Rabin as the load-bearing gap with `Muller.toRabin_exists` as `its single named target`, and labels it `Not a Mathlib-absence refusal; a located and costed gap`.
  - 901 reports/01: the paper proof itself, which `claims the engine up to the final-frame step` and NOT through it; Finding 15.3 and its Risks section name the final frame `the weakest link`.
  - specs/archive/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01: the obstruction relocated to (O1)/(O3)/(O4); (O2) discharged via `Muller.exists_iSup`; `Muller.toRabin_exists` called `the single highest-value proof_wanted in either tree`.
  - specs/archive/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01: the acceptance-condition split -- a deterministic Muller automaton suffices for the Auxiliary-Atoms rule (no acceptance condition) and does NOT suffice for the ban/lull mechanism, whose banned list is indexed by the automaton's accepting pairs, which is what forces the pair shape.

THE FOUR ROUTES to present, each with its cost and its gate:
  (R1) Prove `Muller.toRabin_exists` (Safra/Piterman; held in corpus). Discharges (O1). Costed separately by the companion cost-assessment task; this record consumes that costing if available and says so if not.
  (R2) Close the final-frame step -- and note this route may already be FREE. Both Lean pieces 901 called missing have since landed: 897 universal cover (`exists_orientedForest_cover`) and, more decisively, 898, which found Saturation is consumed NOWHERE in the lifting chain and the base frame needs NO constraint at all, landing `exists_orientedForest_cover_of_constraints` as what its own summary calls `the completeness programme entry point over a base with no Saturation`. The obligation has moved to the SOURCE side (Compositionality, Seriality, Limit on the chronicle quotient), which its companion measurement task checks. If that check is positive, the paper proof one acknowledged gap closes WITHOUT touching sections 7-15 and without reversing Recommendation 8 -- making this the only route that needs no ruling at all, and the one this record should weigh first.
  (R3) The determinization-free alternative: 879's P9 names `an explicit progress-measure argument that avoids determinization` as the ONLY route to a Lean proof that sidesteps (O1), and calls it `a research design, not an ingredient`.
  (R4) T1's two reduced questions. T1 is NOT refuted but reduced: (Q1) is `lcU alpha beta` derivable in TM-plus + LC_n + mirror at ZTime for state-local beta -- 906 refuted it at Base/Dense/RTime by the translation frame over Q and proved the ZTime case unsettleable by ANY model (both schemata have the same ZTime models by construction), so only a proof-theoretic argument can decide it, and the guarded-until-form candidate in PlusLCSchema.lean survives as an open candidate; (Q2) are `clock`, `aaFwd`, `aaBwd` admissible over TM-plus + the schemata -- blocked on Di Maio-Zanardo 1998, not held in the local Zotero library.

WHAT THE RECORD MUST DECIDE: for each of R1-R4, reopen / keep closed / reopen on stated conditions, with the argument. If any route reopens, the record states the terms (what may be filed, what stays barred) precisely enough that a successor can file against it without re-asking. Recommendation 8 stays in force for every route the ruling does not explicitly reopen.

GUARDRAILS: (a) no Lean file is written or edited by this task; (b) no part of sections 7-15 is formalized, attempted, or filed by this task -- that is what the record decides, not what it does; (c) no completeness claim; (d) the four reports above are cited, not re-derived or condensed; (e) if a route's cost is unknown, say so rather than estimating.

FILE SCOPE: none. Report only.

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
- **Dependencies**: Task 869

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

### 804. Narrow termination syntax layer fanin
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: build-performance
- **Dependencies**: Task 803
- **Research**: [804_narrow_termination_syntax_layer_fanin/reports/01_termination-syntax-fanin.md]
- **Plan**: [804_narrow_termination_syntax_layer_fanin/plans/01_termination-syntax-fanin.md]
- **Summary**: [804_narrow_termination_syntax_layer_fanin/summaries/01_termination-syntax-fanin-summary.md]

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
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: build-performance
- **Dependencies**: Task 743
- **Research**: [803_cut_subformulaproperty_elaboration_time/reports/01_cut-subformulaproperty-elaboration-time.md]
- **Plan**: [803_cut_subformulaproperty_elaboration_time/plans/01_cut-subformulaproperty-elaboration-time.md]
- **Summary**: [803_cut_subformulaproperty_elaboration_time/summaries/01_cut-subformulaproperty-elaboration-time-summary.md]

**Description**: Cut the elaboration time of FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean, the repository's single largest rebuild cost.

MEASURED EVIDENCE (from .lake/build-guard.stdout, full guarded build, 2026-10-15, this repo): the module elaborates in 1103s (18.4 minutes) as ONE module. On that build 414 of 2848 jobs actually rebuilt, totalling 6354s of elaboration across those 414; Metalogic accounted for 5649s across 306 modules. Seven modules accounted for roughly 2500s of the total, and SubformulaProperty alone is about 17 percent of the whole incremental rebuild. Next worst: Decidability.Tableau 476s, Termination.MintBound.MintPotential 360s, Termination.Fuel 238s.

WHY IT HURTS REPEATEDLY. The module imports FormalSystem.Metalogic.Decidability.Tableau and FormalSystem.Syntax.SubformulaClosure.Closure, so any edit to the syntax or proof-system layer invalidates it. Paper-alignment work routinely edits FormalSystem/ProofSystem/Axioms.lean and FormalSystem/Semantics.lean, so this 18-minute module is woken by edits unrelated to decidability.

GOAL. Reduce elaboration time substantially while proving exactly the same results. Localize hotspots with lean_profile_proof BEFORE changing anything, and record before/after per-declaration timings as evidence rather than asserting an improvement. Suspects to confirm rather than assume: simp set blowup, decide on a non-trivial decidable instance, unfolding of large structures, Nat/Int arithmetic normalization. Candidate remedies: replace simp with targeted rewrites, extract heavy sublemmas into their own declarations, mark expensive defs irreducible where sound, scope set_option maxHeartbeats.

NON-GOALS. No change to any statement that is proved. Zero new sorry. No new axiom dependency (verify with #print axioms before and after). No weakening of the termination argument.

ACCEPTANCE. A measured, reported reduction in this module's elaboration time with before/after numbers from the build log or lean_profile_proof; lake build green; check-module-invariants.sh ALL CHECKS PASSED; sorry_count 0; axiom profiles unchanged for every declaration in the module.

---

### 787. Lake unguarded reader lock audit
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: general
- **Topic**: decidability
- **Dependencies**: Task 743
- **Parent**: Task 786
- **Research**: [787_lake_unguarded_reader_lock_audit/reports/01_lake-reader-lock-audit.md]
- **Plan**: [787_lake_unguarded_reader_lock_audit/plans/01_lake-reader-lock-audit.md]
- **Summary**: [787_lake_unguarded_reader_lock_audit/summaries/01_lake-reader-lock-audit-summary.md]

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
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 760, Task 775, Task 805, Task 806, Task 819, Task 820
- **Research**: [761_ladder_realization_theorem/reports/08_rk-bounded-representative-refutation.md]
- **Summary**: [761_ladder_realization_theorem/summaries/12_hself-disposition-gate-settlement-summary.md]
- **Plan**: [761_ladder_realization_theorem/plans/13_depth-zero-gate-rest-state.md]

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
- **Status**: [COMPLETED]
- **Task Type**: general
- **Topic**: repo-hygiene
- **Dependencies**: None
- **Research**: [743_typst_sync_check1_namespace_resolution/reports/01_namespace-resolution-feasibility.md]
- **Plan**: [743_typst_sync_check1_namespace_resolution/plans/01_check1-namespace-resolution.md]
- **Handoff**: [743_typst_sync_check1_namespace_resolution/handoffs/phase-3-handoff-20261113T093205Z.md]
- **Summary**: [743_typst_sync_check1_namespace_resolution/summaries/01_check1-namespace-resolution-summary.md]

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
