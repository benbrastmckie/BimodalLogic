---
next_project_number: 456
---

# TODO

## Task Order

*Updated 2026-08-18. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 125,127,128,193,231,257,298,413,437,445,451,452,453 | -- | completeness, decidability, frame-extensions, ... |
| 2 | 178,219,282,296,436,446,450,454 | 193,231,298,437,445,452,453 | decidability, formula-refactor, publication-quality, ... |
| 3 | 421,423,424,434,447,455 | 436,446,454 | decidability, publication-quality, code-quality, ... |
| 4 | 422,425,432 | 421,423,434 | decidability, strong_completeness |
| 5 | 169,433 | 422,432 | decidability, strong_completeness |
| 6 | 362,428 | 169,433 | decidability, strong_completeness |
| 7 | 429 | 428 | decidability |
| 8 | 410 | 429 | decidability |
| 9 | 411 | 410 | decidability |
| 10 | 430 | 411 | decidability |
| 11 | 412 | 430 | decidability |
| 12 | 426 | 412 | completeness |
| 13 | 95,177 | 193,426 | completeness, formula-refactor |

**Grouped by Topic** (indented = depends on parent):

### Completeness

413 [NOT STARTED] — Formalize the TM+ over TM conservativity bridge in Lean 4 (paper 
95 [NOT STARTED] — Verify and record the final axiom/sorry status of the headline me
426 [NOT STARTED] — Settle whether the tableau engine can positively refute (G p) -> 
  └─ 95 [NOT STARTED] — Verify and record the final axiom/sorry status of the headline me (see above)

### Decidability

437 [RESEARCHED] — Attack the missing fourth termination-measure component from the 
  └─ 436 [BLOCKED] — Resume task 434's implementation plan (specs/434_discharge_mintpa
    └─ 434 [BLOCKED] — Discharge `MintPaysForTime fc U Tmax`, defined at FormalSystem/Me
      └─ 432 [IMPLEMENTING] — Discharge `UniverseClosed fc U`, defined at FormalSystem/Metalogi
        └─ 433 [RESEARCHED] — Discharge `PostBlockingSettles fc`, defined at FormalSystem/Metal
          └─ 428 [BLOCKED] — Engine totality at a quantified branch budget. Owns obstruction O
            └─ 429 [NOT STARTED] — Repair the truth-lemma side conditions. Owns obstructions O2 and 
              └─ 410 [PLANNED] — Track B part 1 for the TM tableau decidability program (parent: t
                └─ 411 [NOT STARTED] — Track B part 2 for the TM tableau decidability program (parent: t
                  └─ 430 [NOT STARTED] — The semantic lift and the Track A assembly. Owns obstruction O4 o
                    └─ 412 [NOT STARTED] — Track B finish for the TM tableau decidability program (parent: t
453 [PLANNING] — Return `lake build BimodalTest` to green by re-recording 7 stale 

### Formula Refactor

177 [NOT STARTED] — Update all documentation to match final codebase state after refa
178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Publication Quality

445 [NOT STARTED] — Address 39 FIX: tags in `typst/FormalFoundations.typ`, each of th
  └─ 446 [NOT STARTED] — Address 6 bare `// FIX:` tags in `typst/FormalFoundations.typ`, e
    └─ 447 [RESEARCHED] — Address 6 substantive FIX: directives in `typst/FormalFoundations

### Automation

193 [NOT STARTED] — Apply validity-intro and truth-simp macros to the soundness layer

### Code Quality

452 [PLANNED] — Correct two factually inverted sections of specs/ROADMAP.md again
455 [NOT STARTED] — BACKLOG REALIGNMENT: bring specs/ROADMAP.md and every remaining a

### Dataset Enhancement

231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
  └─ 219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
257 [BLOCKED] — large_data_storage_huggingface
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor
  └─ 282 [PARTIAL] — exhaustive_enumeration_by_default
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release, weak_unt

### Strong Completeness

169 [NOT STARTED] — Base (FrameClass.Base / general) WEAK completeness green: make th
  └─ 362 [NOT STARTED] — Implement the completeness capstone under the SETTLED TERMINOLOGY
421 [NOT STARTED] — Two deliverables on the Base weak terminus, both small.
  └─ 422 [NOT STARTED] — Construct the discrete-case analogue of the existing dense chroni
    └─ 169 [NOT STARTED] — Base (FrameClass.Base / general) WEAK completeness green: make th (see above)
423 [NOT STARTED] — Create FormalSystem/Metalogic/SetConsequence.lean containing the 
  └─ 425 [NOT STARTED] — Convert the informal argument at FormalSystem/Metalogic/StrongCom
424 [NOT STARTED] — RE-ISSUED 2026-08-10 (description rewrite only; status remains `n
454 [NOT STARTED] — RE-ISSUE THE SIX STRONG-COMPLETENESS TASK DESCRIPTIONS: re-anchor
  └─ 421 [NOT STARTED] — Two deliverables on the Base weak terminus, both small. (see above)
  └─ 423 [NOT STARTED] — Create FormalSystem/Metalogic/SetConsequence.lean containing the  (see above)
  └─ 424 [NOT STARTED] — RE-ISSUED 2026-08-10 (description rewrite only; status remains `n (see above)

### Proof System Infrastructure

450 [NOT STARTED] — FRAME-CLASS UNIFORMITY: parameterise the restricted-MCS layer (an

### Repo Hygiene

451 [NOT STARTED] — CONSOLIDATE THE TWO BONEYARDS into a single archive tree under Fo

## Tasks

### 455. Survey and realign remaining tasks and roadmap
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Topic**: code-quality
- **Dependencies**: Task 452, Task 454

**Description**: BACKLOG REALIGNMENT: bring specs/ROADMAP.md and every remaining active task into agreement with
the progress actually made and the goals actually remaining.

Ordering is not optional. Stage 1 (ROADMAP) produces the reference frame that Stages 2-4 judge
every task against. Do not begin surveying tasks before the roadmap states what remains.

=== 0. WHY THIS TASK EXISTS ===

A prioritization review (specs/reviews/review-2026-08-18.md) sampled a handful of tasks and found
description rot in most of what it touched: file:line anchors past end-of-file, an acceptance
criterion pinned to four line numbers that had all moved, a governing design built on a Lean
parameter deleted by a completed refactor, and a "gate" that gates nothing in the dependency
graph. That review corrected the six strong-completeness tasks on the critical path (its
predecessor task) and the two worst ROADMAP sections (its dependency). It did NOT sweep the
remaining backlog, and there is no reason to think the rot stopped at the sample.

The tree has moved a long way underneath these descriptions: the total-history-validity refactor,
the untl/snce guard-first argument-order migration (3,711 occurrences across 152 files), the
paper-refactor cluster, the bi-lasso decision layer, and the arrival of a sorry count of ONE. Many
task descriptions predate several of those.

=== 1. STAGE 1 -- REFINE specs/ROADMAP.md (do this FIRST) ===

The dependency task corrects two specific inverted sections (the Sorry Inventory's false 23-vs-1
count, and the "BXCanonical Path (DEAD CODE)" mislabel). That is triage, not completeness. This
stage finishes the job: make ROADMAP.md an accurate statement of WHAT REMAINS.

(a) Audit the whole file, not the two sections already fixed. It is ~1,770 lines and is
selectively maintained -- some sections were current as of 2026-08-10 while others had not been
touched since April. For every section, establish whether it describes (i) current reality,
(ii) settled history that should be explicitly marked historical, or (iii) a stale claim that must
be corrected or deleted. The 111 status-table rows are the roadmap-integration matching surface
and parse cleanly; treat them with care but do not assume they are current.

(b) Ground every status claim in a machine-checkable source. scripts/check-module-invariants.sh is
the generator of record: C2 for the flagship axiom sets, C3 for the live sorry inventory, C4/C5 for
reference resolution, C7 for file counts. A claim in ROADMAP.md that no check can reproduce is
either rewritten to be reproducible or removed.

(c) Add the missing forward-looking content. The file is heavy on how things were built and light
on what is left. It should state, per active front (strong completeness, decidability, FMP,
paper/publication, dataset, hygiene), what remains, what the terminus looks like, and what is
known to be blocked or refuted. Refuted routes deserve explicit tombstones -- the strong-
completeness cluster already carries at least one hard-won refutation (the Base-MCS to
Discrete-MCS transfer lemma, killed by a lex-order countermodel) whose whole value is that nobody
re-attempts it.

(d) Make the sections that rotted structurally harder to rot. Where a section restates a fact a
script can compute, say which script computes it and when it was last reconciled.

=== 2. STAGE 2 -- SURVEY EVERY REMAINING TASK ===

Cover every task in specs/state.json active_projects EXCEPT the six already re-issued by the
predecessor task (169, 362, 421, 422, 423, 424) and this task's own dependencies. At the time of
writing that is roughly 35 tasks across the topics: decidability, completeness, dataset-enhancement,
formula-refactor, frame-extensions, publication-quality, algebraic-representation, automation,
proof-system-infrastructure, repo-hygiene, code-quality.

For each task, produce a verdict in one of these categories, with evidence:

  CURRENT     -- description matches the tree; no change needed. Say what you checked.
  RE-ANCHOR   -- substance intact, citations drifted. List the drifted anchors and fix them.
  RE-SCOPE    -- the work is still wanted but the description's premise has moved (a vocabulary it
                 names is gone, a lemma it targets has been proved, a route it proposes is
                 refuted). State the new scope.
  SUPERSEDED  -- the work has been done, or subsumed by another task. Name what did it. Propose
                 completion or abandonment; do NOT change status unilaterally (see section 5).
  OBSOLETE    -- the goal itself no longer serves the project. Argue it and propose abandonment.

Specific checks each task must survive:
  - Every file:line and symbol it cites resolves in the live tree. Prefer symbol names over line
    numbers when rewriting; line-number anchors are the observed failure mode.
  - No dependency on a task that is archived-but-unsatisfying, and no dangling dependency. (All 41
    edges resolved as of 2026-08-18 -- confirm this still holds and keep it true.)
  - Acceptance criteria are still satisfiable. The observed failure was an acceptance criterion
    demanding byte-comparability against four specific line numbers, none of which still held the
    definitions.
  - Any "PRE-EXISTING RED" or baseline note it records still describes the current build. At least
    one task was found carrying a stale baseline naming a compile failure that no longer exists
    while the real failure had moved elsewhere.
  - Stated priority still reflects reality given what has since landed.

=== 3. STAGE 3 -- RECONCILE THE DEPENDENCY GRAPH ===

Descriptions and edges must agree. The observed failure mode was a task describing itself as a
"feasibility gate" while no task listed it as a dependency, so Kahn's algorithm in
generate-task-order.sh placed it in wave 1 alongside the work it claimed to gate.

  (a) For every task whose prose asserts it blocks, gates, or must precede other work, verify a
      corresponding edge exists. Add it, or downgrade the prose. Do not leave both readings.
  (b) Look for the converse: declared edges with no justification in either description.
  (c) Re-derive the wave structure afterwards and sanity-check it against the stated goals. If the
      capstone of a front is not downstream of that front's open work, something is miswired.
  (d) Confirm active_topics in state.json still matches the topics tasks actually carry
      (generate-task-order.sh warns on undeclared topics rather than failing).

=== 4. STAGE 4 -- REPORT ===

Deliver a survey artifact under this task's reports/ directory containing:
  - the per-task verdict table (task, topic, verdict, evidence, action taken)
  - every anchor corrected, with old -> new
  - every dependency edge added or removed, with justification
  - the ROADMAP.md changes and what machine-checked source grounds each
  - an explicit list of tasks proposed for completion or abandonment, for user decision
  - a short statement of the resulting critical path per front

=== 5. CONSTRAINTS ===

- Descriptions, ROADMAP.md, and dependency edges are in scope. TASK STATUS IS NOT. Propose
  completions and abandonments in the report; do not transition any task to completed, abandoned,
  or expanded. That decision stays with the user.
- No .lean edits. This task proves nothing and closes no sorry.
- All specs/state.json writes go through .claude/scripts/state-write.sh; TODO.md is regenerated via
  generate-todo.sh, never hand-edited.
- Do not re-touch the six tasks handled by the predecessor task. If the survey finds a defect in
  one of them, record it in the report rather than editing it, so the two passes cannot conflict.
- Every claim about build state, sorry counts, or axiom sets must cite the check that produced it.
  Do not restate a status from another description as if it were verified -- the stale-baseline
  finding above is exactly that failure.

=== 6. VERIFICATION ===

- scripts/check-module-invariants.sh C5 passes (module-shaped paths in markdown resolve), which
  covers the rewritten ROADMAP.md.
- Zero dangling dependency edges across active_projects.
- Every task in the survey has a verdict; no task is silently skipped. A task judged CURRENT still
  gets a row saying what was checked.
- generate-todo.sh regenerates cleanly with no undeclared-topic warnings.

=== 7. NON-GOALS ===
- Does not implement, research, or plan any surveyed task.
- Does not archive anything (that is /todo's job, after the user acts on the report).
- Does not restructure the topic taxonomy; it only reports desync.

---

### 454. Reissue strong completeness task descriptions
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Topic**: strong_completeness
- **Dependencies**: Task 452

**Description**: RE-ISSUE THE SIX STRONG-COMPLETENESS TASK DESCRIPTIONS: re-anchor every drifted file:line citation
by symbol name, re-scope the shift-set representation gate against total-history semantics, and
reconcile its "gate" language with the dependency graph.

Targets: the six `strong_completeness`-topic tasks and their immediate terminus -- 169, 362, 421,
422, 423, 424. NONE of them has a task directory or any research/plan artifact, so each task's
state.json description is the ENTIRE input its first dispatch will receive. Every defect below is
therefore live and will be hit on first contact.

=== 1. ANCHOR DRIFT (verified 2026-08-18 against the live tree) ===

  task | cited anchor                                            | actual        | drift
  -----|---------------------------------------------------------|---------------|-------
  423  | Validity.lean:79   (valid)                              | :94           | +15
  423  | Validity.lean:169  (ValidDense)                         | :206          | +37
  423  | Validity.lean:187  (ValidDiscrete)                      | :222          | +35
  423  | Validity.lean:276  (ValidDedekindDense)                 | :310          | +34
  421  | Transfer.lean:1239-1241 (refuted route-(i) guidance)     | :1081-1083    | -158
  169  | Transfer.lean:1242 (the sorry)                          | :1068         | -174
  169  | Completeness.lean:196 (theorem completeness)            | :191          | -5
  422  | ChronicleToCountermodelBasic.lean:435                    | :430          | -5
       |   (box_dense_gives_density)                              |               |
  422  | ChronicleToCountermodelBasic.lean:629                    | :624          | -5
       |   (cantor_bfmcs_dense_restricted_tc)                     |               |

FormalSystem/Metalogic/WeakCanonical/Transfer.lean is now 1086 lines, so tasks 421 and 169 both
cite line numbers PAST THE END OF THE FILE.

The substance survives in every case -- this is drift, not deletion. Verified present and live:
the text at Transfer.lean:1081-1082 is verbatim the refuted route-(i) guidance that 421(a) is
chartered to replace; countermodel_discrete is at Transfer.lean:1068 and is still the tree's sole
live sorry (check C3); theorem completeness is at Completeness.lean:191; and all four lemmas 422
must mirror exist and are live and already frame-class polymorphic
(box_dense_gives_density (fc : FrameClass) ... at :430, cantor_bfmcs_dense_restricted_tc at :624,
_buc and _fuc likewise, plus cantorIsoDense (fc : FrameClass) ... at :231).

Task 423's acceptance criterion is the one that actually bites: it requires each
SetSemanticConsequence* binder list to be "byte-comparable to its Validity.lean source" at four
named lines, none of which are the definitions any more.

Task 421's other anchor -- CompletenessDedekind.lean:61-100, the CarrierProbe pattern -- is still
ACCURATE. Do not "fix" it.

Deliverable (a): re-anchor all nine citations above BY SYMBOL NAME rather than by line number, so
the descriptions stop rotting on every unrelated edit. Where a line number genuinely aids
navigation, keep it as a secondary hint alongside the symbol, never as the primary reference.

=== 2. TASK 424 IS SCOPED AGAINST A DELETED PARAMETER ===

Task 424 (prove_shift_set_representation_theorem_compactness_feasibility_gate) states its entire
Representation Theorem -- both directions, the whole content of the gate -- in terms of
`TruthAt (M : TaskModel F) (Omega : Set (WorldHistory F)) ...`, and notes that the reverse
direction "literally sets Omega := Omega -- identifying the shift-set carrier with that Lean
parameter directly."

That parameter no longer exists. FormalSystem/Semantics/Truth.lean:159 now reads
`def TruthAt (M : TaskModel F)` with the box clause at :164:

    | Formula.box phi => forall (sigma : WorldHistory F), sigma.IsTotal -> TruthAt M sigma t phi

and the file's own docstring is categorical: "There is no admissible-history parameter. ... The
designated-carrier argument that earlier revisions threaded through every clause has been deleted
outright: the box clause reads its quantifier range off WorldHistory.IsTotal, so no set-valued
parameter can narrow, widen, or otherwise influence the meaning of any connective." The quantifier
now ranges over H_F, the total histories.

Task 424's description already contains a self-audit flagging this exposure -- but its verdict was
recorded as a warning about a SIBLING TASK THAT PLANNED to eliminate the vocabulary. That
elimination has since landed and been archived (the total-history-validity refactor), so the
warning is now a fact, and 424 was never re-issued against it.

Deliverable (b): re-scope 424 against total-history semantics. This is genuine design work, not
clerical: decide what the shift-set Representation Theorem becomes when there is no Omega to
identify the carrier with, and whether the compactness feasibility question it was posed to settle
survives the reframing intact, changes shape, or dissolves. Record the verdict in the description.
If the reframing turns out to be substantial enough to need its own research cycle, say so and
scope that cycle rather than papering over it -- but do not leave 424 dispatchable as written.

=== 3. TASK 424 GATES NOTHING IN THE DEPENDENCY GRAPH ===

424 is described as the "compactness feasibility gate", but no task in specs/state.json lists 424
as a dependency. 362 depends on [361, 375, 169, 170]; 423 on [361]; 425 on [361, 423].

generate-task-order.sh computes waves by Kahn's algorithm over the declared edges, so 424 lands in
wave 1 alongside everything else unblocked and will never be ordered BEFORE the work it supposedly
gates.

Deliverable (c): resolve the contradiction in one direction or the other. Either add 424 to the
dependencies of the tasks whose feasibility it actually gates (the Dense strong-completeness arm,
via 423's strongCompletenessDense_of_compact / CompactDense statements, and/or 362), or downgrade
the "gate" language so the prose and the graph agree. Do not leave both readings standing.

=== 4. CONTEXT THE RE-ISSUE SHOULD PRESERVE (verified, do not re-derive) ===

- All 41 declared dependency edges across the active set resolve; there are zero dangling
  references. Task 361, which every strong-completeness task depends on, is archived complete, as
  are 375, 414, 420, 439, 448 and 170.
- The spine is 421 -> 422 -> 169 -> 362, four deep and strictly sequential. 423 -> 425 is a second
  branch. 421, 423 and 424 are all unblocked right now.
- No strong-completeness task depends on any decidability task, and none depends on task 450
  (frame-class parameterization of the restricted-MCS layer). That was checked directly:
  Core.RestrictedMCS is imported by only Metalogic/Core.lean and Decidability/FMP/ClosureMCS.lean;
  StrongCompleteness.lean imports Validity, Core.DeductionTheorem, Soundness and
  BXCanonical.CompletenessDedekind and touches RestrictedMCS nowhere; and the chronicle layer 422
  extends builds on SetConsistent, which is already frame-class polymorphic. Record this so the
  question is not re-opened.

=== 5. VERIFICATION ===
- Every file:line or symbol reference in all six re-issued descriptions resolves in the live tree
  at the time of the re-issue.
- No task's SCOPE changes except 424's, and 424's change is stated explicitly with its rationale.
- Status of all six tasks is unchanged by this work (they stay not_started; this is a description
  re-issue, not progress).
- specs/state.json edits go through .claude/scripts/state-write.sh; TODO.md is regenerated, never
  hand-edited.

=== 6. NON-GOALS ===
- Proves nothing, closes no sorry, writes no Lean.
- Does not start 421, 422, 423 or any other strong-completeness task.
- Does not re-scope 169, 362, 421, 422 or 423 -- their substance was verified intact; only their
  anchors move.

---

### 453. Restore bimodaltest green and clear c6 c9
- **Status**: [PLANNING]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**: [453_restore_bimodaltest_green_and_clear_c6_c9/reports/01_guard-rebaseline-and-c6-c9.md]

**Description**: Return `lake build BimodalTest` to green by re-recording 7 stale #guard_msgs expectations, and
clear the two remaining check-module-invariants.sh failures (C6, C9).

=== 1. THE SEVEN GUARDS (verified 2026-08-18) ===

`lake build` of FormalSystem exits 0. `lake build BimodalTest` fails with exactly 7 #guard_msgs
docstring mismatches and no other errors (lint warnings elsewhere are unrelated):

  Tests/BimodalTest/TableauConformance.lean : 4 errors at :873, :885, :910, :916  (rows W1,W3,W6,W7)
  Tests/BimodalTest/RegionGateProbe.lean    : 2 errors at :299, :330              (rows C, H .Dense)
  Tests/BimodalTest/BoxSpreadProbe.lean     : 1 error  at :165                    (row C, .Dense)

The drift is a genuine change in computed values, not a reordering. Generated time domains are
mostly smaller than recorded (|T| 8->6 and 10->6; knownTimes 9->8, 10->8, 6->5; one row grew
8->10), with constraint lists shrinking correspondingly. RegionGateProbe:299 additionally flips
gate=true check=true -> gate=false check=false, world 1's candidate vector collapsing [1,1,...] ->
[0,0,...].

=== 2. VERDICT: STALE EXPECTATIONS, NOT A REGRESSION (high confidence) ===

Do not open a regression investigation. Four independent lines of evidence:

(a) The value changes match the documented, intended effect of `trivialEventWitnessed` -- the
guard that stops the engine minting trivial seriality witnesses, so time domains stop growing.
That is exactly the "fewer known times" signature.

(b) Every property these probes ASSERT still holds. All four TableauConformance rows still report
total=true and incomparable=[] (time-order totality is what the probe exists to measure).
BoxSpreadProbe:165 still reports spread=false anchor=false grid=false; only |T| moved.
RegionGateProbe's own designed cross-check (its `gate` against the library's `check`) still AGREES
on both failing rows.

(c) Rows W1 (:873) and W7 (:916) now produce identical output. W7 exists by construction as "W1 at
fuel 2000, five times W1's own fuel -- identical, so the flip to total=true is timeLinearity firing
and not a budget artifact." The pinned pair is NOT identical; the generated pair IS. Current
behaviour satisfies the invariant the row was written to test; the recorded expectation does not.

(d) The pinned values were never build-verified when authored: commit d67059938 records "Phase 7
edits applied to all 8 probe modules ... NOT YET BUILD-VERIFIED."

=== 3. PROVENANCE (do not re-derive; recorded here so the attribution note can cite it) ===

Last known-green whole-target build: 1b7636703 (2026-07-29), recording CORPUS_RC=0 and
mismatches=0 across 143 #guard_msgs directives. It went red in the window 1b7636703..d49b977c0
(2026-08-10/11), the semantics-refactor plus tableau-engine work that rewrote Tableau.lean (+517
lines) and Saturation.lean (+634) and added Verified/Termination/MintBound.lean. Commit 59faf7304
marks where the project stopped claiming the target ("record BimodalTest as unmeasured, not
green"). Commit 86eb8963c then did a measured three-point re-baseline taking 40 mismatches -> 7,
re-recording 29 rows attributable to trivialEventWitnessed and DELIBERATELY EXCLUDING these same 7
to avoid folding a separately-owned engine change into that attribution.

Those 7 exclusions are enumerated in-source with their then-current values in the "Re-baseline
record" headers at TableauConformance.lean:104, RegionGateProbe.lean:110, BoxSpreadProbe.lean:94.
All 7 recorded "P2 current" values are byte-identical to what Lean generates today: zero drift
since 2026-08-11.

The untl/snce guard-first argument-order migration is EXONERATED -- it touched Tableau.lean and
Saturation.lean, but these 7 rows use only F/G/P/H/box/diamond/-> /and, and their outputs are
unchanged from the pre-migration record. The BiLasso/FMP work is likewise exonerated: it added new
modules rather than changing the engine these probes exercise.

=== 4. DELIVERABLES ===

(a) Re-record all 7 guard docstrings from Lean's generated `info:` output. There is NO
regeneration script -- scripts/check-evidence-probes.sh is unrelated (it lake-env-lean-compiles the
sorry-free evidence probes) and scripts/check-module-invariants.sh guards axiom baselines, not
#guard_msgs. The established process is manual: run the module, copy the generated line into the
docstring. Incremental elaboration is BoxSpreadProbe ~2.0s, RegionGateProbe ~3.8s,
TableauConformance ~49s.

(b) Rewrite the three "Re-baseline record" header blocks, which currently enumerate these 7 as
deliberately excluded, plus the per-row narrative comments that describe the old values. The repo
convention is that an expected block is updated in the same commit as the calculus change with the
flip justified; this task is the deferred settlement of that debt, so the attribution note is the
deliverable, not an afterthought. It must: attribute the 7 to the 2026-08-10/11 engine window,
record that W1 and W7 now agree as the row was designed to require, and confirm RegionGateProbe
row C's gate loss (below).

(c) RegionGateProbe:299 (row C) needs one sentence of confirmation, not an investigation. It was
"the one moved two-world row that keeps its gate", and it no longer does. The module docstring is
explicit that the gate is a deliberate over-approximation, "harder to pass than the induction will
need, so ... failing it would not by itself refute anything", and rows A/B/H already pin
gate=false for the same documented reason (the unsound cross-world temporal copies removed by the
earlier probe work mean the minted world receives no T(G.)/T(H.)). Row C simply joined them.
Confirm that reading holds and say so in the record.

(d) C6: add the 7 unreachable live modules absent from scripts/module-invariants-manifest.txt, or
justify each exclusion in the manifest. They are Metalogic/Algebraic/{BooleanStructure,
InteriorOperators, LindenbaumQuotient, UltrafilterMCS}, Metalogic/Bundle/Construction,
Metalogic/SoundnessLemmas/CoValidity, and
Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGateFaithful. UltrafilterMCS matters most:
at 81 occurrences it is the single largest FrameClass.Base consumer in the tree and is currently
compile-unchecked.

(e) C9: FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean:185 carries a
task-number citation ("This is the plan's task 3, discharged in full"). Replace with a durable
anchor.

=== 5. VERIFICATION ===
- `lake build BimodalTest` exits 0.
- scripts/check-module-invariants.sh: C1, C6 and C9 all PASS; C2 and C3 unchanged (four flagship
  axiom sets at baseline; sole live sorry still countermodel_discrete).
- No .lean semantics change: every edit is a docstring, a comment, or a manifest line. If any
  guard cannot be made to pass by re-recording alone, STOP and report rather than adjusting the
  engine -- that would falsify the verdict in section 2 and is a different task.

=== 6. NON-GOALS ===
- Does not change the tableau engine, Saturation, or MintBound.
- Does not re-open the 29 rows re-recorded by 86eb8963c.
- Does not add a guard-regeneration script (worth considering, but scope it separately).

---

### 452. Correct roadmap sorry inventory and bxcanonical status
- **Status**: [PLANNED]
- **Task Type**: markdown
- **Topic**: code-quality
- **Dependencies**: None
- **Research**: [452_correct_roadmap_sorry_inventory_and_bxcanonical_status/reports/01_roadmap-sorry-bxcanonical-correction.md]
- **Plan**: [452_correct_roadmap_sorry_inventory_and_bxcanonical_status/plans/01_roadmap-sorry-bxcanonical-correction.md]

**Description**: Correct two factually inverted sections of specs/ROADMAP.md against machine-checked reality.

=== 1. THE DEFECT (verified 2026-08-18 via scripts/check-module-invariants.sh) ===

(a) "Sorry Inventory" (specs/ROADMAP.md:881) opens: "The BXCanonical module has 23 sorry proofs in
three categories." Check C3 verifies the entire live tree has EXACTLY ONE structural sorry:
countermodel_discrete, at FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1068. The section's
"Critical Path (5 sorries in RootScopedChain.lean)" table lists five file:line rows, but
RootScopedChain.lean exists only under FormalSystem/Boneyard/ (two archived copies:
Boneyard/ScheduleBasedBFMCS/ and Boneyard/DefectDirectedChain/), neither of which is compiled or
in the import closure. All five rows are dead references. The "Irreflexive-Consequence (18 sorries
across 6 files)" subsection is likewise unreconciled.

(b) "BXCanonical Path (DEAD CODE -- Task 109 Abandoned)" (specs/ROADMAP.md:624) states that
BXCanonical "has ~17 sorries", is "mathematically false under the current irreflexive semantics",
and is a "Candidate for archival to Boneyard/."

BXCanonical is the flagship, not dead code. Check C2 baselines four theorems, all of them in that
namespace: BXCanonical.completeness, .completeness_dense, .completeness_discrete, and
.Chronicle.countermodel_dense -- three with clean [propext, Classical.choice, Quot.sound] axiom
sets. FormalSystem/Metalogic/StrongCompleteness.lean imports BXCanonical.CompletenessDedekind
directly. FormalSystem/Metalogic/BXCanonical/ holds 7 live .lean files at the top level plus the
Chronicle/ subtree.

=== 2. WHY THIS MATTERS ===

git log -L 881,900:specs/ROADMAP.md shows the Sorry Inventory section last modified 2026-04-20.
ROADMAP.md as a whole was updated 2026-08-10, so the file is selectively maintained -- the Paper
Alignment Programme section is current while these two are ~4 months stale. Anyone planning work
on the completeness path is told by the repository's own roadmap that the module their work rests
on is abandoned dead code carrying 17 sorries, and that 23 sorries stand between them and a clean
tree, when the true count is one.

The 111 status-table rows in this file parse cleanly and participate in roadmap-integration.sh
matching; these prose sections do not, so they are never corrected automatically by /todo or
/review.

=== 3. DELIVERABLES ===

(a) Rewrite the "Sorry Inventory" section against C3 output: a single live entry
(countermodel_discrete, Transfer.lean, owned by the Base weak-completeness terminus), with a
pointer naming scripts/check-module-invariants.sh check C3 as the generator of record so the
section cannot silently rot again. Delete or clearly mark-as-historical the RootScopedChain and
Irreflexive-Consequence tables rather than leaving live-looking file:line rows pointing into
Boneyard/.

(b) Delete or invert the "BXCanonical Path (DEAD CODE -- Task 109 Abandoned)" section. If the
historical record of the abandonment is worth keeping, retain it under an explicitly historical
heading that cannot be mistaken for current status, and state the current status alongside it.

(c) Sweep the rest of the file for the same class of defect: any prose section asserting a sorry
count, a dead-code verdict, or a module status that C2/C3/C4 can contradict. Report what was found
even where no edit was needed.

=== 4. VERIFICATION ===

- Every file:line and module reference introduced or retained must resolve in the live tree
  (check C5 covers module-shaped paths in markdown; run it).
- No claim about sorry counts or axiom sets that is not reproducible from a named
  check-module-invariants.sh check.
- Do not touch the Paper Alignment Programme section or the 111-row status tables; they are
  current and are the roadmap-integration matching surface.

=== 5. NON-GOALS ===
- Does not close, move, or reclassify any actual sorry.
- Does not archive BXCanonical or any other module.
- No .lean edits.

---

### 451. Consolidate boneyard archives
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: repo-hygiene
- **Dependencies**: None

**Description**: CONSOLIDATE THE TWO BONEYARDS into a single archive tree under FormalSystem/Boneyard/, preserving git history via git mv, and add the missing infrastructure that keeps an UNCOMPILED archive honest.

=== 1. THE SITUATION (verified 2026-08-17) ===
The repository has two archive trees:
  FormalSystem/Boneyard/                                  93 .lean, 59,019 lines
  FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/     63 .lean, 29,256 lines
Total archived: 156 files; live tree is 373 of 529.

The second is nested five levels deep and is easy to miss. Both READMEs already carry a "There Are TWO Boneyards" warning because past repository counts were wrong for exactly that reason -- a find/grep filter naming only the top-level archive silently counts ~29k archived lines as live code.

Neither archive is excluded in lakefile.lean. Exclusion works two ways: (i) nothing live imports either tree, so they are outside the import closure and never compiled; (ii) tooling filters on the NAME glob `-not -path '*/Boneyard/*'` (scripts/check-module-invariants.sh:63, scripts/readme-lint.sh at :50,:70,:102,:133,:154,:161,:165). Because the filter is by name, it already covers both trees -- so consolidation does NOT change the build. The case for it is navigability, documentation discipline, and eliminating a class of counting bug, not build correctness.

=== 2. PRE-VERIFIED SAFETY FACTS (do not re-litigate; re-confirm cheaply) ===
- ZERO live importers: `grep -rn "^import .*Boneyard" FormalSystem/ Tests/ --include=*.lean | grep -v "/Boneyard/"` is EMPTY. Also empty for any non-import textual reference to Kamp.Boneyard or Kamp/Boneyard from a live file. The top-level Boneyard likewise has no live importers.
- OUTBOUND imports are unaffected by the move. Kamp Boneyard files import three LIVE modules (FormalSystem.Metalogic.WeakCanonical.Kamp.EANegation, .EANegationClosure, .ESigmaCapture). Import statements name the IMPORTED module, which is not moving, so these keep resolving.
- NAMESPACES are not path-derived. The moved files declare `namespace FormalSystem.Metalogic.WeakCanonical`, `...Kamp`, `...Separation`, `RenderGate` -- none tied to the Boneyard path segment. No namespace edits are required.

=== 3. THE ONE REAL HAZARD ===
52 INTRA-ARCHIVE import lines inside the Kamp Boneyard name modules under `FormalSystem.Metalogic.WeakCanonical.Kamp.Boneyard.*` (e.g. Separation/DualEliminations.lean:16-18, Separation/Hierarchy/HierarchyDefs.lean:16-17, ArityReduction.lean:1). Every one of these breaks when the files move, because the MOVED files' module names change.

Because archived files are never compiled, a broken import here is SILENT -- no build, no test, and no existing check catches it. That is the defect this task must not introduce, and the reason deliverable 4 exists. (The top-level Boneyard has 47 analogous self-imports; those files are not moving and are unaffected, but the new checker must cover them too.)

=== 4. DELIVERABLES ===
(a) MOVE, with git mv exclusively -- never delete-and-re-add, never cp. History preservation is a hard requirement, not a preference: the whole point of a scrapyard is that `git log --follow` still explains why each file died. Target: FormalSystem/Boneyard/KampWeakCanonical/. PRESERVE the existing internal structure rather than flattening: ZetaProbes/, NfMultiAnchorBridgeRetired/, Separation/ (with Separation/DedekindZ/ and Separation/Hierarchy/), ExpressiveCompleteness/.
(b) RECONCILE with the existing FormalSystem/Boneyard/KampBypassArchive/ (13 files: KampBypass*.lean, KampForward, KampMutualInduction, NfCharFormula, PriorComposition{,_old}, GeneralExistPart). Kamp material has been migrated to the top-level archive before, so the result must be ONE coherent Kamp region, not two sibling directories that each look authoritative. Either nest both under a Kamp umbrella or state in writing why they stay separate.
(c) REWRITE the 52 intra-archive import lines to the new module paths. Mechanical, but every one must be verified to resolve -- see (d).
(d) NEW CHECKER: a script (or a new check group in scripts/check-module-invariants.sh) asserting that EVERY import line in every Boneyard file names a module that exists on disk -- whether it points at live code or at another archived file. This is the missing infrastructure. Uncompiled code has no compiler to catch rot, so the archive needs its own resolution check or it silently decays into unrevivable rubble. Wire it into the invariant script so it runs with everything else.
(e) UPDATE the B0 self-test (scripts/check-module-invariants.sh:70-74) from "exactly 2 directories" to 1. B0 is a PASS-asserting self-test and WILL fail loudly the moment anything moves -- that is correct behavior, not breakage. Also re-check the :20-22 comment block, whose two-Boneyard warning becomes obsolete.
(f) READMEs. Merge the two contradictory "There Are TWO Boneyards" sections into one accurate statement. NOTE THE DRIFT: FormalSystem/Boneyard/README.md records the Kamp archive as 62 files / 27,394 lines while the Kamp README records 63 / 29,256 and the filesystem agrees with the latter; the top-level README also states 59,010 lines for itself against an actual 59,019. Stale hand-maintained counts are part of what this task retires -- prefer counts the invariant script emits (C7) over numbers re-typed into prose.
(g) PER-APPROACH DOCUMENTATION, which is the user-facing point of the exercise. The top-level archive already has the right convention: one subdirectory per abandoned approach, each with a README explaining what it was, why it died, and what would have to change for it to be worth reviving (see ClosedGuardLegacy/, DenseChronicle/, UltrafilterFrame/, RoundRobinChain/, NonBurgessSeed/, StageInductionGapAnalysis/). The Kamp archive is largely flat under a single README. Bring it up to that convention. Every README must record the file's ORIGINAL PATH so provenance survives the move even for a reader who never runs git log.

=== 5. NON-GOALS ===
- Do NOT revive, repair, or compile any archived code. Archived files stay uncompiled and outside the import closure.
- Do NOT modify any live module. If a live module turns out to need a change, that is a separate task -- stop and report.
- Do NOT delete anything. This is a consolidation, not a purge. Deciding what deserves deletion is a different judgment call and is explicitly out of scope.
- Do NOT add the archive to lakefile.lean in any form.

=== 6. VERIFICATION CONTRACT ===
- `git log --follow` resolves through the move for a sampled file from each moved subdirectory. If it does not, the move was done wrong -- redo it with git mv.
- `git status` shows renames (R), not delete+add pairs, for all 63 files.
- lake build exits 0 and its output is UNCHANGED from before the move -- nothing live imports either archive, so a build difference means something was moved that should not have been.
- Repository live-sorry count stays at exactly 1 (countermodel_discrete, WeakCanonical/Transfer.lean), via scripts/check-module-invariants.sh, never naive grep.
- check-module-invariants.sh: B0 green at 1 directory; C7's live inventory unchanged (373 live .lean) since only archived files move.
- The new checker (d) is green, including the 47 pre-existing top-level self-imports.
- scripts/readme-lint.sh still skips the consolidated tree correctly (its six *Boneyard* guards match by name, so they should, but verify rather than assume).
- PRE-EXISTING RED, inherited not caused: C6 (SoundnessLemmas/CoValidity.lean:104 `simp` made no progress), C9 (task-number citation in WeakCanonical/PriorExpressivenessDense.lean:185), and `lake build BimodalTest` (#guard_msgs drift in RegionGateProbe, TableauConformance, BoxSpreadProbe). None are in scope here; do not attempt to fix them, but confirm they are no WORSE afterward.

---

### 450. Frame class parameterization restricted mcs
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-system-infrastructure
- **Dependencies**: Task 453

**Description**: FRAME-CLASS UNIFORMITY: parameterise the restricted-MCS layer (and the derived-theorem libraries beneath it) by FrameClass, removing ad hoc FrameClass.Base pins repo-wide.

=== 1. WHY (machine-checked ground truth) ===
Established by specs/417_semantic_fmp_finite_worldstate_over_z/reports/04_filteredstep-fwd-gating-spike.md and its sorry-free evidence file evidence/spike-untl-unfolding-and-fwd-obstruction.lean (9 declarations, all audited via #print axioms, no sorryAx):

RestrictedConsistent (Core/RestrictedMCS/Basic.lean:72) and RestrictedMCS (:80) explicitly pin SetConsistent to FrameClass.Base, even though SetConsistent {fc : FrameClass} (Core/MaximalConsistent.lean:96) is ALREADY frame-class polymorphic. The pin is the anomaly, not the parameter.

Consequence, machine-checked: filteredStep_fwd is FALSE for the existing FilteredWorld. A Base-consistent closure MCS may contain the negation of U(TOP,BOT), which is true at every point of every Z-model, so Base-MCSs include worlds realizable in NO Z-model. At Phi = U(TOP,BOT) there is a filtered world with no successor at all (filteredStep_fwd_fails). Any Z-frame construction over Base-filtered worlds is unsound at the first point it touches Z dynamics.

There is no third option: U(TOP,BOT) derives from Axiom.prior_UZ whose minFrameClass IS Discrete, so "add an axiom to Base" and "instantiate at Discrete" are the same act. The only other escape -- weakening the step table until Base worlds satisfy it -- is the machine-checked-dead Phase 7 universal-relation failure (evidence/phase7-filtered-frame-is-universal.lean).

=== 2. SCOPE: UNIFORMITY AND GENERALITY, NOT A MINIMAL PATCH ===
The charter is explicitly NOT the smallest change that unblocks the FMP work. It is a repo-wide discipline pass. Measured surface at task creation: 668 FrameClass.Base occurrences across 59 live (non-Boneyard) .lean files.

The governing principle: a declaration MUST be stated at the weakest frame class at which it is derivable, and parameterised by {fc : FrameClass} wherever it is class-independent. A Base pin is legitimate ONLY when the statement is genuinely about the Base system (e.g. fmp_contrapositive's conclusion). Every other pin is a defect to be removed.

Known instances of the defect (non-exhaustive; the audit is part of the work):
- Theorems/Propositional/Core.lean is HALF polymorphic already ({fc} on efqAxiom, peirceAxiom, doubleNegation, lceImp, rceImp) and half Base-pinned (12 occurrences); Connectives.lean has 5 more. This inconsistency is why the spike had to rebuild orElim/andIntro/guardMono/eventMono from scratch instead of reusing the library.
- Theorems/ModalS5.lean (9), ModalS4.lean (2), DedekindDerived.lean (4).
- Metalogic/Bundle (11), BXCanonical (6+2+2+1), Algebraic (4), WeakCanonical (4).

=== 3. DELIVERABLES ===
(a) Parameterise RestrictedConsistent / RestrictedMCS / closure_mcs_deductively_closed (FMP/ClosureMCS.lean:171) by {fc : FrameClass}, DEFAULTING TO Base so every existing call site elaborates unchanged. Downstream: ClosureMCS, ClosureMCSBundle, FilteredWorld, FiniteModel, TruthPreservation, Correctness.
(b) PRESERVE the landed Base results verbatim -- mcs_finite_model_property (FMP/FMP.lean:230), fmp_contrapositive (:243), fmp_size_bound (:269) are genuine theorems ABOUT the Base system and their statements must not drift. Hard-coding Discrete instead of parameterising is explicitly rejected for this reason.
(c) Discrete-system consistency lemma. The tree has "the base system is consistent" (Soundness.lean:1957) but NO Discrete analogue, and a Discrete-instantiated MCS layer is vacuous without one. Route: soundness_discrete_valid (Soundness.lean:1334) at D = Z on TaskFrame.trivialFrame -- the same shape the spike used for dense_consistent at Q. This is the FIRST lemma of the task, not an afterthought: everything else is vacuous until it lands.
(d) Promote the spike's Discrete unfolding schema into the library (Theorems/TemporalDerived.lean or a new Theorems/DiscreteUnfolding.lean): succIndicator, nextConj, unfoldTableForward, unfoldTableBackward, unfoldForward, unfoldBackward, noBlockingTriple. All are already sorry-free in the evidence file and are general-purpose facts about the Discrete system, useful well beyond the FMP. Promote the frame-class-polymorphic plumbing alongside rather than leaving it duplicated.
(e) Generalise Theorems/Propositional (and ModalS4/ModalS5/DedekindDerived where derivable at a weaker class) so the library is uniformly {fc}-polymorphic. Any declaration that cannot be generalised must carry a docstring line saying WHY its class is essential.
(f) Repo-wide audit: enumerate every remaining FrameClass.Base occurrence and classify it as (i) legitimately Base-specific, (ii) generalised by this task, or (iii) deliberately deferred with a reason. The audit table is a deliverable artifact, not scratch work.

=== 4. NON-GOALS ===
- Does NOT implement the filtered step relation, filteredStep_fwd/bwd, FilteredStepFrame, the bi-lasso layer, or the semantic FMP. Those remain the A/B/C split of handoff 01 in specs/417_semantic_fmp_finite_worldstate_over_z/handoffs/.
- No edits under /home/benjamin/Philosophy/Papers/ (read-only ground truth).
- Does not attempt to reconcile Discrete with Dense/Dedekind: they are INCOMPARABLE in FrameClass's order (Axioms.lean:511-517), so nothing proved at Dedekind can be borrowed at Discrete. Do not add a joint class.

=== 5. VERIFICATION CONTRACT ===
- Zero new sorry. Repository live-sorry count stays at exactly 1 (countermodel_discrete, WeakCanonical/Transfer.lean), verified via scripts/check-module-invariants.sh, NEVER naive grep.
- lake build exits 0 at every commit; no landed theorem statement weakens silently. Any statement change must be called out explicitly in the summary.
- PRE-EXISTING RED, inherited not caused (verify before blaming this work): check-module-invariants.sh currently fails C6 (SoundnessLemmas/CoValidity.lean:104 `simp` made no progress), C9 (task-number citation in WeakCanonical/PriorExpressivenessDense.lean:185), and lake build BimodalTest (#guard_msgs drift in RegionGateProbe, TableauConformance, BoxSpreadProbe). C6 is a genuine FormalSystem compile failure that predates this task and is unowned -- fixing it is IN SCOPE as part of the uniformity pass if it proves frame-class-related, otherwise report it.
- No vacuous definitions, no restating a lemma in a trivially-true form.
- Default-to-Base is the regression firewall: verify with lake build FormalSystem.Metalogic.Decidability.FMP.FMP before touching anything downstream.

=== 6. UNBLOCKS ===
Task 417's recommended Task B (the filtered step relation) cannot start before (a) and (c) land. Task A (bi-lasso layer) is independent and unaffected.

---

### 447. Substantive rewrites in FormalFoundations.typ: proof repair, axiom presentation, section restructure
- **Status**: [RESEARCHED]
- **Task Type**: logic
- **Topic**: publication-quality
- **Dependencies**: Task 446
- **Research**: [447_substantive_rewrites_formalfoundations/reports/01_substantive-rewrites-research.md]

**Description**: Address 6 substantive FIX: directives in `typst/FormalFoundations.typ`. Unlike the footnote and commented-block restorations, these call for new mathematical exposition, grounded in the source paper at `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`.

- `:244` — The Extension proof is inadequate. Repair it by including the lemmas it needs to cite, drawing on `possible_worlds.tex` where these results are established.
- `:267` — The Task Topology definition needs expansion for readability, including indented definitions in the same style as the definitions above it.
- `:353` — Indent the axioms and formalize all of them to improve readability.
- `:362` — The S5 / BX axiom presentation is unreadable and must be expanded so the document is self-contained rather than requiring the reader to look the axioms up elsewhere.
- `:369` — Everything in the remainder of the proof-systems section is inadequate. Present what is carefully developed in `possible_worlds.tex`, giving a systematic account of the various proof systems with each clearly defined.
- `:393` — Replace the section introduction. Avoid platitudes; give a brief, concrete overview of what the section covers.

**Reference grounding**: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` is the authoritative source for the proof-system definitions and the lemmas the Extension proof depends on. Transcribe faithfully rather than reconstructing from memory.

**Verification**: `typst compile typst/FormalFoundations.typ` must succeed; every axiom named must be stated in full; the Extension proof must cite lemmas that are actually present in the document or in the cited source.

**Important**: When making changes, remove the FIX: tags from the source file.

---

### 446. Restore or retire 6 commented-out prose/proof blocks in FormalFoundations.typ
- **Status**: [NOT STARTED]
- **Task Type**: logic
- **Topic**: publication-quality
- **Dependencies**: Task 445

**Description**: Address 6 bare `// FIX:` tags in `typst/FormalFoundations.typ`, each marking a block of commented-out prose or proof text that must be restored as live document text, rewritten, or deleted.

Tag locations (line numbers as of scan) and their commented-out content:

- `:214` — the proof of the Nullity lemma ($w arrow.r.double.long_(0) w$), which argues from *Seriality* at $x = 0$.
- `:257` — prose on the Step Lemma being the sole application site of *Spherical*, with Extension its sole consumer, plus the footnote at `lem:step` and the observation that Extension and Occurrence are ZFC theorems while Nullity is not; this localization is what makes *Spherical* the identified obstruction of the representation section.
- `:263` — prose stating the cones form a basis for a topology on world states and that the topology is separated.
- `:277` — block following the Separation theorem (T1, hence R0).
- `:323` — block following the BL/BL+ semantics definition.
- `:342` — block following the frame-validity and logical-consequence definitions.

For each, decide restore / rewrite / delete, apply, and remove the FIX: tag.

**Verification**: `typst compile typst/FormalFoundations.typ` must succeed; restored proofs must be mathematically correct and consistent with the surrounding definitions.

**Important**: When making changes, remove the FIX: tags from the source file.

---

### 445. Restore or retire 39 commented-out footnotes in FormalFoundations.typ
- **Status**: [NOT STARTED]
- **Task Type**: logic
- **Topic**: publication-quality
- **Dependencies**: None

**Description**: Address 39 FIX: tags in `typst/FormalFoundations.typ`, each of the form `] // FIX: #footnote[...]` trailing a definition, lemma, theorem, or corollary block. Each commented-out footnote carries either a paper anchor (`def:BLplus-language`, `def:temporal-order`, `def:task-relation`, `def:directed`, `def:frame`, `lem:nullity`, `def:world-history`, `thm:extension`, `cor:occurrence`, `def:task-topology`, `app:topology-t1`/`app:topology-r0`, `def:BL-model`, `def:BL-semantics`/`def:BLplus-semantics`, `def:frame-properties`, `def:frame-validity`/`def:logical-consequence`, `def:S5`, `def:BX`, `thm:TM-soundness`, `app:discrete`/`app:dense`/`app:complete`, `cor:tm-completeness`, `def:TMplus`, `cor:tm-decidability`, `def:strongest`, `thm:exist`, `lem:uniq`/`thm:s4`/`thm:sym`, `sub:Extension`) with an `@brastmckie2026possibleworlds` citation, or a Lean source reference (`Metalogic/Core/MaximalConsistent.lean`, `Metalogic/Bundle/BFMCS.lean`, `Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`, `WeakCanonical/Transfer.lean`, `IntegerModel/GoodStructures.lean`, `RealModel/DoetsTheorem.lean`, `Metalogic/Algebraic/*`).

For each, decide whether the footnote should be restored as live document text, folded into the surrounding prose, or deleted, then apply that decision and remove the FIX: tag.

Tag locations (line numbers as of scan): 149, 178, 191, 196, 211, 213, 238, 242, 255, 274, 276, 305, 321, 333, 340, 359, 367, 409, 418, 434, 448, 488, 505, 511, 523, 554, 575, 663, 691, 714, 739, 832, 841, 855, 883, 885, 891, 902, 944.

**Verification**: `typst compile typst/FormalFoundations.typ` must succeed and all `@`-references and bibliography keys must resolve.

**Important**: When making changes, remove the FIX: tags from the source file.

---

### 437. Repair time index reuse in identification plus nexttime bookkeeping
- **Effort**: 16-22 hours
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**:
  - [436_fourth_termination_measure_component/reports/02_spawn-analysis.md]
  - [437_repair_time_index_reuse_in_identification_plus_nexttime_bookkeeping/reports/01_spawn-analysis-pointer.md]

**Description**: Attack the missing fourth termination-measure component from the identification-plus-maxTime side rather than the measure side, per task 436's roadmap item 2. Root cause: Branch.identifyTime (FormalSystem/Metalogic/Decidability/SignedFormula.lean:364-367) relabels every formula at time src to tgt and erases duplicates, so src disappears from Branch.knownTimes (SignedFormula.lean:349-350) whenever no other formula independently sits at tgt. Branch.maxTime (SignedFormula.lean:373-374, foldl max 0 over the live branch) and Branch.nextTime (SignedFormula.lean:380-381, maxTime + 1) are both recomputed from the current branch on every call, with no memory of a previously-larger retired value. TimeOrdering.identifyTime (SignedFormula.lean:705-710) does the analogous constraint substitution. The decided consequence is nextTime_reissues_retired_time (MintBound.lean:7321): firstIncomparablePair merges away the branch's current maximum time, maxTime drops, and post-identification nextTime re-issues the retired value; reuse_driven_through_engine (MintBound.lean:7363) confirms the live engine actually drives through this path. The accumulated renaming sigma (composed from rhoSF src tgt at each identification) is constructed so it can never land on a retired source time -- rhoSF_time_ne_src (MintBound.lean:7299) proves (rhoSF src tgt sf).label.time != src for every sf -- so mint_not_in_rhoSF_image (MintBound.lean:7307) and, by extension, register entries 15 and 17 (MintBound.lean:7866-7938) refute every measure-side candidate whose decrease is witnessed anywhere on the trigger's label, formula or time. This task's goal is to make Branch/TimeOrdering time issuance monotone across a run -- nextTime must never again hand out an index a prior identification retired -- so the reuse configuration nextTime_reissues_retired_time decides today stops occurring at all, rather than continuing to search for a measure component robust to it. REQUIRED SHAPE: refute-first gate as phase 1, in the same spirit as this task's own predecessor plan (specs/436_fourth_termination_measure_component/plans/01_self-guard-potential.md) -- prototype the monotone-time-issuance mechanism (e.g. a highwater-mark tracked on TimeOrdering, which is already threaded alongside Branch at every rule call site, or an equivalent run-level counter) against the SAME witness configuration used by nextTime_reissues_retired_time and gate_is_reissue_hazard, and decide, before touching any live engine file, both (a) whether reissue is actually prevented, and (b) whether RunInvariant, OrdTimesKnown (the settled repair for the adjacent register entry 7 refutation of OrdTimesLeMaxTime across identification, MintBound.lean entry 7), and UniverseClosedAt-style confinement to U survive the change. Only if the gate passes should later phases thread the repair through the live engine. WIDENED BLAST RADIUS (do not assume additive-only-in-MintBound.lean; explicitly confirmed by grep): Branch.nextTime is called at 9 sites in FormalSystem/Metalogic/Decidability/Tableau.lean (lines 761, 801, 834, 878, 924, 971, 1069, 1168, 1370 -- one per freshTimeRules member, not only the two self-guarded rules the predecessor task touched); Branch.identifyTime/TimeOrdering.identifyTime are called together at Tableau.lean:1520 and consumed in proofs at FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean lines 1948, 1959, 1973, 1991, 2445-2457 that already reason about identifyTime's effect on knownTimes cardinality and must be re-verified (not necessarily rewritten) against any redefinition; FormalSystem/Metalogic/Decidability/Saturation.lean does NOT reference nextTime or identifyTime (confirmed by grep) and should stay untouched; the definitions themselves live in SignedFormula.lean:349-381 and 671-710. DO NOT RE-ATTEMPT (per C9 register, MintBound.lean:7694-7944, all 17 entries read): entry 14's two measure-side repairs (re-indexing mintPotential on freshTimeRules; dropping disjunct 1's cardinality conjunct); entry 17's whole family (any fourth measure component whose decrease is witnessed anywhere on the trigger's label, time or formula). This task is not a measure-side route at all, so none of entries 14/15/17's refutations apply directly to it, but entries 7 and 16 name OrdTimesKnown as a settled repair this task's bookkeeping change must not silently re-break. Must be sorry-free and axiom-free; lake build must be green at completion. Land any newly-refuted route as a fresh C9 register entry (18) following the file's existing convention if the gate or a later phase decides a sub-route false.

---

### 436. Fourth termination measure component
- **Effort**: 10-14 hours
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 435, Task 437
- **Research**:
  - [434_discharge_mintpaysfortime_residual/reports/02_spawn-analysis.md]
  - [436_fourth_termination_measure_component/reports/01_fourth-measure-component.md]
  - [436_fourth_termination_measure_component/reports/02_spawn-analysis.md]
- **Plan**: [436_fourth_termination_measure_component/plans/01_self-guard-potential.md]
- **Summary**: [436_fourth_termination_measure_component/summaries/01_self-guard-potential-summary.md]

**Description**: Resume task 434's implementation plan (specs/434_discharge_mintpaysfortime_residual/plans/01_mintpaysfortime-time-analogue.md) at Phase 7. Before starting, read the full do-not-re-attempt register (MintBound.lean section C9, 16 entries) and in particular entry 14, which records both refuted repair routes for MintPaysForTime: (1) re-indexing mintPotential on freshTimeRules instead of freshLabelRules -- refuted by witnessPresent_eq_false_of_not_freshLabel, whose match has exactly eight arms so the three added columns are permanently false; (2) dropping disjunct 1's cardinality conjunct and relying only on the ordering-rank conjunct -- refuted by splitOrderedRank_lt_of_knownTimes_lt plus mintPaysForTime_rank_repair_false, since splitOrderedRank's base Tmax^2+1 is by construction one more than incompPairs' range so any new known time raises the rank regardless of the pair count. Neither route may be re-attempted. Design a fourth measure component that pays for the three self-guarded minting rules -- untlNeg/snceNeg (guarded by futureOf/pastOf emptiness plus ord.timeCount < 4) and densityRule (guarded by the maximal-unfilled-gap set) -- and that is also preserved across TimeOrdering.identifyTime, which can lower ord.timeCount (the same maxTime-lowering mechanism Phase 6's verdict in the existing plan turns on; see nextTime_reissues_retired_time and reuse_driven_through_engine). Run this task with --lit against the sub-index populated by the literature-curation task, drawing specifically on: caleiro_2013's mosaic-method decidability treatment for combined tense-and-modal logics (sections 6-7, mosaic-based tableau systems and complexity bounds) as a structural analogue for a combined-logic termination measure; venema_2001 section 5's interval-based temporal logic treatment for the density/gap-guarded densityRule component; gerth_1995 and baier_katoen_2008's closure-set LTL tableau termination argument as a model for a measure over an evolving, non-monotonically-changing time set; and massacci_2000's rule-bounding technique. Once a candidate measure is validated, land it in MintBound.lean following the plan's existing Phase 7-8 task lists: define the repaired predicate (e.g. MintPaysForTimeAt, mirroring UniverseClosedAt's naming), prove its direction lemma relative to MintPaysForTime (weakening or strengthening, stated explicitly), confirm it leaks no new hypothesis into the terminus, restate the two seed-level termini at the repaired shape, and discharge the repaired predicate at a concrete instantiation (U = signedUniverse C L). All work must be sorry-free, axiom-free, and additive only (Saturation.lean, Fuel.lean, Tableau.lean remain untouched, and no previously-landed declaration in MintBound.lean is altered). Full lake build must be green at completion, and the new do-not-re-attempt register entries (if any further route is refuted along the way) must be recorded in section C9 following the existing convention.

---

### 434. Discharge mintpaysfortime residual
- **Effort**: 10-15 hours
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 431, Task 435, Task 436
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]
  - [434_discharge_mintpaysfortime_residual/reports/01_spawn-inherited-research.md]
  - [434_discharge_mintpaysfortime_residual/reports/02_spawn-analysis.md]
- **Plan**: [434_discharge_mintpaysfortime_residual/plans/01_mintpaysfortime-time-analogue.md]

**Description**: Discharge `MintPaysForTime fc U Tmax`, defined at FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:3945, the open mathematical core among the four residual hypotheses on the totality terminus `buildTableauAt_isSome_of_budget` (MintBound.lean:4416). Two disjuncts to establish. First disjunct ('a step that does not raise the known-time count does not raise the rank'): the naive reading 'non-ruleMintsFreshLabel implies no new time' is FALSE -- `densityRule` interpolates a fresh time while deliberately absent from `ruleMintsFreshLabel` (it carries its own `existingIntermediates` guard), and the active-mode arms of `untlNeg`/`snceNeg` introduce times without being witness-guarded; the correct test is the ordering-length one `expandOnceNoFresh` already uses (`newOrd.constraints.length`), not the rule list. Establishing this disjunct means proving a time-dimension analogue of `applyRule_emitted_world_mem` keyed on that ordering-length test. Second disjunct (cashed at the once-only bound, carrying the sigma-hit obligation from `mintPotential_lt_of_pick_linear` / `_branching`): the formula the rule fires on must be `sigma sf` for some `sf in U`; this is entangled with the time-reuse question -- `Branch.nextTime = maxTime + 1` while `Branch.identifyTime` can LOWER `maxTime`, so whether the engine can re-issue a time an earlier identification retired is genuinely open (the live-times reformulation carries the identical obligation, confirming it is intrinsic rather than an artifact of the measure). Done means: a theorem proving `MintPaysForTime fc U Tmax` for a concrete, useful instantiation, landed sorry-free and axiom-free in MintBound.lean, with `lake build` green. Do not re-attempt anything in the do-not-re-attempt register at MintBound.lean:4455-4510 (eight entries; read before starting) -- in particular do not re-litigate `witnessPresent_identifyTime`'s unconditional form (entry 5, refuted by `witnessPresent_identifyTime_unconditional_false`) or `OrdTimesLeMaxTime` preservation across the identification arm (entry 7, refuted by `ordTimes_identifyTime_arm3_false`; the settled repair is `OrdTimesKnown`).

---

### 433. Discharge postblockingsettles residual
- **Effort**: 6-10 hours
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 431, Task 432, Task 434
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]
  - [433_discharge_postblockingsettles_residual/reports/01_spawn-inherited-research.md]

**Description**: Discharge `PostBlockingSettles fc`, defined at FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:4344, one of the four residual hypotheses on the totality terminus `buildTableauAt_isSome_of_budget` (MintBound.lean:4416). It states that the post-blocking pass leaves a branch the blocking-aware saturation test certifies -- i.e. `findUnexpandedUnblockedWith satBr satOrd fc (blockedTimes satBr satOrd fc (armTracker satBr)) = none` whenever `saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd))`. It subsumes `resolveOpenArm`'s own `none` arm via `armSettlement_of_postBlockingSettles` (MintBound.lean:4354) -- `ArmSettlement` alone is proved strictly too weak (`resolveOpenArm` tests `findClosure satBr` before its saturation test; `buildTableauAt` does not), so do not attempt to discharge via `ArmSettlement` instead. The relevant definitions are frozen (md5-pinned) in Saturation.lean (`saturateBlocked`, :431) and Tableau.lean (`blockedTimes`, :2104; `findUnexpandedUnblockedWith`, :2115) -- do not edit either file; the residual's own docstring states the gap ('whether the fuel-vs-condition gap can be closed by fuel alone') is exactly what Saturation.lean leaves open using only its existing public interface. Done means: either (a) a proof of `PostBlockingSettles fc` for the frame classes the terminus is meant to be used at, using only the public interface of the frozen files, landed sorry-free and axiom-free with `lake build` green; or (b), if (a) turns out to be genuinely impossible without touching the frozen files, a return to [BLOCKED] with the specific counterexample or obstruction found, analogous to the parent task's own refutation-driven repairs (e.g. `ordTimes_identifyTime_arm3_false`, MintBound.lean:1217) -- do not paper over with a vacuous definition (`lean4.md`'s Vacuous Definitions prohibition applies).

---

### 432. Discharge universeclosed residual
- **Effort**: 4-6 hours
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 431, Task 434
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]
  - [432_discharge_universeclosed_residual/reports/01_spawn-inherited-research.md]
- **Plan**: [432_discharge_universeclosed_residual/plans/01_universeclosed-clause2-verdict-instantiation.md]
- **Summary**: [432_discharge_universeclosed_residual/summaries/01_universeclosed-clause2-verdict-instantiation-summary.md]

**Description**: Discharge `UniverseClosed fc U`, defined at FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:3901, one of the four residual hypotheses on the totality terminus `buildTableauAt_isSome_of_budget` (MintBound.lean:4416). The definition has two conjuncts: (1) closure of `U` under the engine's unblocked-expansion step `expandOnceUnblocked` -- a familiar shape already required by the unsplit totality theorem's `hU` obligation -- and (2) closure of `U` under an ordered split's identification arm `Branch.identifyTime`, which relabels the branch; this second clause is genuinely new. For `U = signedUniverse C L` (Fuel.lean:382, DO NOT edit Fuel.lean -- it is md5-pinned frozen), clause (2) reduces to a statement about the label set `L` being closed under time-merging. Done means: a theorem proving `UniverseClosed fc U` for a concrete, useful instantiation `U = signedUniverse C L` under an explicit closure condition on `L` (state and prove that condition too, if it is not already available), landed sorry-free and axiom-free in MintBound.lean, with `lake build` green. Do not re-attempt anything in the do-not-re-attempt register at MintBound.lean:4455-4510 (eight entries; read before starting), and in particular do not attempt route (a), entry 6 (a lower bound on `(b.identifyTime t2 t1).toFinset.card` from below -- dead by definition).

---

### 430. Semantic lift and track a assembly valid iff allclosed
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428, Task 429, Task 411

**Description**: The semantic lift and the Track A assembly. Owns obstruction O4 of the Phase 7.3 deadlock, then delivers what Phase 7.3 of task 165 was for. Grounding: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

THIS TASK CARRIES THE WORK MOVED OUT OF TASK 165's PHASE 7.3. Task 165 terminated with Phase 7 scoped to what it delivered (the truth lemma and Track A's conditional results); 7.3 -- `valid_iff_allClosed` and the `Decidable` instances -- was moved here rather than closed, because it is blocked on prerequisites no task owned.

O4 HAS TWO DISTINCT PIECES, per Verified/Decidable.lean:3062-3067: "It is not yet `valid_iff_allClosed` (7.3), which additionally needs the fuel/termination side and the truth-lemma gate, and it says nothing about the two rules scheduled outside `allRulesForFC` -- `serialityRule` and `timeLinearity` run as stages 2 and 3 of `expandOnce` and need their own obligations at the point where `expandOnce`, rather than `applyRule`, is the object."

(a) Two more `RuleSound`-analogues at the `expandOnce` level, for `serialityRule` and `timeLinearity`. These are deliberately outside `allRulesForFC`, so `ruleSound_of_mem_allRulesForFC` (landed, 34/34) does NOT cover them.
(b) THE SEMANTIC LIFT: the induction lifting single-step satisfiability preservation to the whole recursion, so that `.allClosed` yields a contradiction. This is the LARGER of the two and is comparable in weight to a landed sub-phase, not to a wrapper. Naming it inside "the two outside rules" understates it.

THEN, and only after (a), (b) and both predecessors: `valid_iff_allClosed` plus the four `Decidable` instances for validity over Base, Dense, Discrete and Dedekind.

WHAT IS ALREADY LANDED (do not re-prove): the rule half is done -- `ruleSound_of_mem_allRulesForFC` is a single landed induction over `mem_allRulesForFC_iff`, ledger complete at 34/34, from task 165 Phase 7.2.

PLAN AGAINST SIX ROWS, NOT EIGHT: the truth-lemma gate hypothesis hTW is discharged on SIX accepted TemporalWitnessProbe rows (A, B, C, D, E, F), not the historical eight -- rows I and K left when the PASSIVE arms of untlNeg/snceNeg were retired. See the banner at the head of Tests/BimodalTest/TemporalWitnessProbe.lean.

DO NOT write a conditional `valid_iff_allClosed` carrying hTW as an explicit hypothesis. Correctness.lean:98-105 refuses exactly this shape, and the O4(b) hypothesis would BE the conclusion's forward direction, making the theorem vacuous. Four vacuous theorems were deleted in 165's Phase 8; do not land a fifth.

DONE WHEN: `valid_iff_allClosed` and the four `Decidable` validity instances are landed unconditionally, sorry-free and axiom-clean outside Boneyard, lake build green.

---

### 429. Repair truth lemma side conditions boxanchored and temporalwitness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428

**Description**: Repair the truth-lemma side conditions. Owns obstructions O2 and O3 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md. THIS IS THE TASK WITH GENUINE OPEN MATHEMATICS IN IT and should be budgeted accordingly.

READ FIRST: specs/418_*/artifacts/boxanchored-finding.md -- it carries the measurement, the full carrier list, and the repair options. Then TruthLemma.lean:399-404 and BoxSaturation.lean:430-435, :574-580.

O2 -- `hBA` (`boxAnchoredCheck`) is no longer dischargeable on multi-world branches. BoxSaturation.lean:430-435: the two copy blocks "have since been removed as unsound ... They were the ONLY route by which T(G phi)/T(H phi) could reach a freshly minted world ... `boxAnchoredCheck` is therefore expected to compute `false` on multi-world branches now." :574-580: "a caller can no longer expect to discharge that hypothesis from a real run." TruthLemma.lean:399-404 names the repair as "an open design decision with its own soundness obligations" and lists THREE candidate routes: (a) propagate T(box phi) itself; (b) copy T(G phi)/T(H phi) only when box-derived; (c) restructure the `box` case to need no anchor.

CRITICAL CONSTRAINT: this was caused by task 418 (completed) removing a GENUINE UNSOUNDNESS. It is the cost of a correct fix, not a regression to revert. TruthLemma.lean:404 says "Do NOT reinstate the removed copies." Any repair must re-establish the anchor WITHOUT reinstating them.

O3 -- `hTW` (`temporalWitnessCheck`) is no longer dischargeable on any branch carrying a negative until with a known future time. TemporalWitnessProbe.lean:66-73: `untlNegFuture` demands F(event) at every known future time of every negative until; the PASSIVE arm's branch 1 was the ONLY producer of `not event` at an EXISTING time; that arm was retired as unsound (user-authorized rank 2), so the producer is gone. Measured cost: fourteen probe rows moved check=true -> check=false; the accepted set went from EIGHT rows to SIX (rows A, B, C, D, E, F; I and K left). :86-88: "it was already `false` on the branches the engine actually builds. What it removes is the last set of hand-built branches on which the hypothesis was discharged."

DO NOT REOPEN (settled by 165): guardWitnessed in any variant; restoring sat_untl_neg / sat_snce_neg (they are FALSE against the current engine, not merely unproved); reinstating the retired PASSIVE arms or the removed box copy blocks.

GOAL: choose among the three documented BoxAnchored repair routes and land it with its soundness obligations discharged; and re-establish a producer for `not event` at existing future times. Both must hold on branches the engine ACTUALLY builds, measured by the probes, not on hand-built branches.

DONE WHEN: `boxAnchoredCheck` and `temporalWitnessCheck` are dischargeable on real engine output for the relevant branch classes, evidenced by probe rows moving back to check=true; no unsound copy block or retired arm is reinstated; lake build green.

---

### 428. Engine totality at a quantified branch budget
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 431, Task 432, Task 433, Task 434
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

---

### 426. Settle anchor row countermodel or nontermination for g p box g p
- **Effort**: 4-8 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 165, Task 412, Task 428
- **Research**: [archive/418_fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos/artifacts/after-verdicts.md]

**Description**: Settle whether the tableau engine can positively refute (G p) -> square (G p), or whether that branch provably never saturates. Context: the cross-world temporal-copy unsoundness in boxNeg/diamondPos is fixed and the engine is sound, but the fix moved this formula from a WRONG answer to NO answer rather than to the intended positive refutation. Measured post-fix: decide returns .fuelExhausted (not .invalid), getCountermodel?.isSome = false, and buildTableau returns none at fuel 30, 60, 400 and 1000 -- so the fuel ceiling is not bracketed from above and there is no evidence a larger budget helps. Pre-fix the same formula returned .extractionFailed, which under this codebase R7 semantics asserts VALIDITY of an invalid formula; the current .fuelExhausted is the only constructor isUndecided recognises, so the present state is honest-but-incomplete rather than wrong. Two hypotheses to discriminate: (a) budget -- the branch does saturate but needs more fuel, in which case find and record the ceiling; (b) non-termination -- the branch never saturates, in which case this is a termination question for FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean, not a budget one, and the honest deliverable is a proof or argument that no finite fuel suffices. Discriminating between (a) and (b) is the primary deliverable; producing the countermodel is the secondary one and only applies under (a). The corpus already pins this outcome directly: CrossWorldPropagationProbe row F asserts the decide constructor and builds green at (false, false, true, false, true) -- update that row if the verdict moves. Do NOT reintroduce any temporal-copy propagation block into boxNeg/diamondPos to make the branch close; that is the exact unsoundness that was removed, and reverting it would restore a false claim of validity. Note the related but SEPARATE inheritance also recorded for the parent task: the decidable-branch-gate family (boxAnchoredCheck, boxGridCheck, regionGate, regionLabelCheck, rayUpOk/rayDnOk) now computes false on every multi-world branch; that is the truth-lemma side-condition problem and is not this task.

---

### 425. Machine check discrete non compactness witness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 423

**Description**: Convert the informal argument at FormalSystem/Metalogic/StrongCompleteness.lean:56-62 into a machine-checked theorem: the FrameClass.Discrete consequence relation is not compact, hence strong completeness is refuted for that class.

The witness is the premise set {F p} union {not X^n p : n in N} where X phi = Formula.next phi. Every finite subset is satisfiable over Z (place p beyond the largest n used); the whole set is unsatisfiable over any Archimedean discrete carrier, because the F p witness would lie at some finite successor distance, contradicting the corresponding not X^n p.

The load-bearing ingredient is already in the tree: Formula.next phi = Formula.untl phi Formula.bot (FormalSystem/Syntax/Formula.lean:490) genuinely is a next-step operator — through the untl clause of TruthAt, "exists s > t, phi(s) and for all r in (t,s), false" says exactly that s is the immediate successor. No extra hypothesis is needed for this. The "not satisfiable" half is where IsSuccArchimedean does its work, via Order.succ_iterate-style reachability lemmas in Mathlib.

This is the negative half of the per-class split and is independent of the compactness gate — it is not affected by whether Route B succeeds. It depends only on the set-based layer's vocabulary (SatisfiableDiscreteSet / CompactDiscrete are the Discrete analogues of SatisfiableDenseSet / CompactDense).

Explicitly out of scope: an analogous Dedekind non-compactness witness. That belongs to task 408 and the class's non-compactness is already established; duplicating it here would create scope overlap with an in-flight task for no gain.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md, section "Discrete non-compactness witness".

Acceptance: archWitness_finitely_satisfiable, archWitness_not_satisfiable, and discrete_consequence_not_compact all land sorry-free; #print axioms clean on each; lake build green.

---

### 424. Prove shift set representation theorem compactness feasibility gate
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 414, Task 439, Task 454

**Description**: RE-ISSUED 2026-08-10 (description rewrite only; status remains `not_started` -- no work on the gate itself has been touched by this re-issue). AUDITED FOR EXPOSURE TO THE TruthAt / TOTAL-HISTORY REFACTOR under the paper-definition drift guard infrastructure (definitions-of-record: specs/paper-definitions-of-record.md; lint: scripts/check-paper-definitions.sh).

=== 1. EXPOSURE VERDICT: YES -- this task's governing design is built on Lean vocabulary a sibling task plans to eliminate ===

This task carries topic `strong_completeness`, not `paper-refactor`, so it sat outside the six-task paper-refactor cluster re-issue and was never checked against that cluster's findings. The check was overdue: task 424's governing design document states its whole Representation Theorem (both directions -- the entire content of this gate) in terms of `TruthAt (M : TaskModel F) (Omega : Set (WorldHistory F)) ...`, i.e. the CURRENT Lean signature where `Box` quantifies over an explicitly-supplied `Omega : Set (WorldHistory F)` parameter (`FormalSystem/Semantics/Truth.lean:128`, `Formula.box φ => ∀ σ ∈ Omega, TruthAt M Omega σ t φ`), and the reverse direction of the representation theorem literally sets `Ω := Omega` -- identifying the shift-set carrier with that Lean parameter directly. `valid`, `SemanticConsequence`, and `satisfiable` (`FormalSystem/Semantics/Validity.lean:77-139`) are quantified/witnessed the same way: over an arbitrary shift-closed `Omega`, not fixed to the full total-history set.

Task 414 (`refactor_semantics_to_total_history_validity`, re-issued 2026-08-10, same day as this audit) states its charter as: "make totality-based validity THE validity of the repo, eliminating the Omega parameter from the semantics core," matching the paper's current `def:BL-semantics` box clause exactly -- `Box` ranges over `H_F` (the full set of total world histories), with no externally-supplied `Omega`. This is a real, named, imminent architectural change to the exact vocabulary this task's design document manipulates directly, not a hypothetical.

**This is NOT the same failure mode as the paper-refactor cluster's six** (paper prose moving under a task that quotes it verbatim) -- this task's design document does not quote the paper at all; it cites Lean source (`Truth.lean:128-137`, `Validity.lean:77`) directly. The exposure here is one hop removed: task 424 depends on Lean-side vocabulary that task 414 (itself a paper-alignment task) is about to delete. It would not have been caught by the cluster's own re-issue process, which is exactly why this audit exists as a separate check.

=== 2. WHAT IS CURRENTLY TRUE OF THE TREE (settled fact as of this audit -- not a stale assumption, yet) ===

As of this audit, task 414 has NOT landed (`status: not_started`), so task 424's design document is currently an ACCURATE description of the live tree: `TruthAt` does take an `Omega` parameter today, and `valid`/`SemanticConsequence`/`satisfiable` are quantified over it today. Nothing in this task's description is presently wrong. The risk is entirely forward-looking: if 414 lands before 424 starts (or completes), 424's construction needs to be re-derived against whatever post-refactor `TruthAt` looks like, at cost proportional to how much of S1 has already been built against the Omega-parameterized signature.

=== 3. WHAT SURVIVES vs WHAT IS AT RISK ===

**Survives**: the underlying MODEL-THEORETIC ARGUMENT -- that the task-model class is first-order axiomatizable over the two-sorted signature `<Ω, D; <, +, 0, sh, (A_p)>` because the frame's algebraic content reaches `TruthAt` only through the atom clause -- does not depend on whether `Box`'s quantifier domain is an explicit parameter or a fixed total-history set. Fixing `Omega := H_F` (all total histories) is a special case of the general argument, not a different argument; Q1's structural evidence (design doc section "Q1 -- the compactness argument") and the four-step Route B plan (S1-S4) both survive intact.

**At risk**: the LITERAL Lean statement of both directions of the representation theorem, which is this task's actual, sole acceptance criterion. The reverse direction's `Ω := Omega` identification and the forward direction's `Omega := Set.range (fun σ => h_σ)` construction are stated directly against the current Lean parameter name and type; if task 414 removes that parameter, both directions' STATEMENTS (not just their proofs) need restating against whatever replaces it (most likely: `Omega` is simply dropped and `Box` is hard-coded to quantify over `{σ : WorldHistory F // σ.IsTotal}` or equivalent). This is a restatement cost paid once, not a refutation of the route -- Q1's verdict ("likely, not proved") and Route B's four-step plan are expected to survive under totality-fixed semantics, since `Omega = H_F` is the totality-fixed case already covered by the general argument above.

=== 4. RECOMMENDATION APPLIED: dependency edge added on task 414 ===

Because this task's SOLE deliverable (the gate for the entire ultraproduct/strong-completeness branch) is stated directly against vocabulary task 414 is actively eliminating, and because 424 is `effort: high` (a costly restatement to redo if 414 lands mid-flight or just after), this re-issue adds `414` to this task's `dependencies` array (previously `[361]`, now `[361, 414]`). This is a judgment call made under this audit's authority, not a cluster-wide policy -- reviewable/revertable by the user or a future orchestration pass if the sequencing cost is judged acceptable. Rationale: `414`'s own charter is explicitly to make the paper-aligned totality semantics "THE validity of the repo," so building this gate against the pre-refactor signature and then discovering the rug pulled out from under it is the exact wasted-work failure mode the paper-definition drift guard infrastructure (of which this audit is a part) exists to prevent -- generalized here from paper drift to a Lean-architecture drift originating in a sibling task rather than the paper directly.

=== 5. GOVERNING DESIGN DOCUMENT -- PATH CORRECTED ===

Task 361 has completed and archived since this task was created. The governing design document has moved from `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md` to `specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md` -- the same content, corrected path. All section references below (Representation theorem, Risks R3, GATING RULE) are unchanged in content.

=== 6. PRESERVED FROM THE ORIGINAL DESCRIPTION (still binding, unchanged in substance) ===

Prove, in both directions, that the task-model class is representable by shift sets <Omega, D, sh, A> -- D an ordered abelian group, Omega a nonempty type with a D-action sh : Omega -> D -> Omega, and A : Atom -> Omega -> Prop. (Note: once task 414 lands, re-derive this statement against the post-refactor `TruthAt`/`Box` signature per section 3 above before proceeding -- the shift-set carrier `Omega` in THIS sentence is the paper-facing mathematical object, distinct from the Lean parameter of the same name discussed in sections 1-3, which is exactly the coincidence-of-naming this audit had to disentangle.)

THIS TASK IS THE GATE FOR THE ENTIRE ULTRAPRODUCT BRANCH. The follow-on work -- the ultraproduct carrier (S2), the Los lemma for TruthAt (S3), compactness of the Base/Dense consequence relations (S4), and strong completeness for Dense and Base (S5-Dense, S5-Base) -- is NOT AUTHORIZED and has deliberately NOT been created as tasks. It becomes authorized only when this task lands sorry-free. Do not spawn, plan, or dispatch any of it from within this task.

Gate-passed evidence standard, and nothing weaker: a sorry-free Lean statement of both directions, with #print axioms on each direction reporting no sorryAx. A statement that type-checks with a sorry body does not pass. Proving only the forward direction does not pass. A prose argument does not pass.

Cancel condition: if either direction is refuted, or the construction cannot be stated without an additional non-elementary hypothesis, then Route B (semantic compactness via ultraproduct) is REFUTED and the whole branch is cancelled, not retried. Record the refutation and re-open the compactness question; do not proceed to S2 hoping the gap can be patched downstream.

Governing design document: specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md -- section "Representation theorem" for both directions (the reverse direction uses WorldHistory.timeShift and FormalSystem.Semantics.TimeShift.time_shift_preserves_truth, FormalSystem/Semantics/Truth.lean:446), section "Risks" R3 for the Type vs Type* constraint (assert it EARLY, not at assembly time), and section "GATING RULE" for the full gate contract.

Acceptance: both directions sorry-free; #print axioms clean on each; lake build green; the task's summary states explicitly whether the gate PASSED or FAILED.

---

### 423. Land set based consequence layer setderivable and per class setsemanticconsequence
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 454

**Description**: Create FormalSystem/Metalogic/SetConsequence.lean containing the finitary set-derivability relation SetDerivable, the four per-class SetSemanticConsequence* predicates, the basic lemmas, and the strong-completeness / compactness / model-existence statements. Then import it from FormalSystem/Metalogic/StrongCompleteness.lean.

This is vocabulary only. It proves no compactness result and closes no existing sorry. It is self-contained and unblocks two downstream branches (the Discrete non-compactness witness, and Dense strong completeness).

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/01_set-consequence-layer.md — transcribe section 2 (SetDerivable), section 3 (the four per-class definitions), section 4 (basic lemmas), section 5 (StrongCompletenessDense, CompactDense, strongCompletenessDense_of_compact, SatisfiableDenseSet, ModelExistenceDense). Section 4's "Implementer notes" name three elaboration risks; section 7 records what is deliberately out of scope.

Acceptance (from design/01 section 6, all five required): zero sorries and zero vacuous placeholders; grep -c 'import FormalSystem.Metalogic.BXCanonical' on the new module returns 0; each SetSemanticConsequence* binder list is byte-comparable to its Validity.lean source (valid :79, ValidDense :169, ValidDiscrete :187, ValidDedekindDense :276) with only the premise hypothesis inserted, and uses Type not Type* (Validity.lean:77 records this as deliberate); #print axioms on every new declaration reports no sorryAx; StrongCompleteness.lean imports the module and still builds.

---

### 422. Build discrete chronicle over non archimedean block carrier with restricted coherence
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 414, Task 420, Task 421, Task 439, Task 448

**Description**: Construct the discrete-case analogue of the existing dense chronicle machinery, over the non-Archimedean carrier Q x_lex Z confirmed by the predecessor task.

Deliverable (a): the analogue of box_dense_gives_density (FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:435) and cantorIsoDense for the "box U(T,F) in A" case — block decomposition of the chronicle order into Z-blocks, densification of the block order, and the isomorphism into Q x_lex Z.

Deliverable (b): the three restricted-coherence analogues, mirroring cantor_bfmcs_dense_restricted_tc (:629), _buc (:680), _fuc (:755) at the new carrier.

Why this carrier and not Z: succ_cofinal — the obligation that killed the old BX pipeline, refuted by the Z+Z counterexample in Boneyard/BXPipelineGapAnalysis/ — was only ever needed to force the chronicle into Z, i.e. to make it Archimedean. FrameClass.Base imposes no Archimedean-ness (valid, FormalSystem/Semantics/Validity.lean:79, has no IsSuccArchimedean binder). The Z+Z shape is not a counterexample here — it is the intended carrier. Do not re-attempt succ_cofinal.

PRINCIPAL RISK, unresolved at scoping time: it has NOT been verified that the chronicle's block order can always be densified without disturbing MCS-chain coherence. A countable discrete order without endpoints is a Z-indexed fibration over its block order, but making the total structure a group requires the block order to carry a compatible group structure. If this fails, escalate as [BLOCKED] with the failing coherence obligation named — do not paper over it with a sorry or a vacuous placeholder.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md, sections 5.4-5.7.

Acceptance: the block-carrier construction and all three restricted-coherence analogues are sorry-free; #print axioms on each reports no sorryAx; lake build green. This task does NOT close the Transfer.lean:1242 sorry — that is task 169's job, which consumes this output.

FOUR-AXIOM / TOTALITY EXPOSURE NOTE (added 2026-08-10): this task constructs a chronicle-backed frame while the paper-refactor cluster (tasks 420, 414, 415) refactors TaskFrame and validity underneath it. Once task 420 lands, TaskFrame carries the paper's FOUR def:frame axioms (biconditional Compositionality, Seriality, Limit, Spherical -- pinned in specs/paper-definitions-of-record.md) plus a Nonempty WorldState field and a [Nontrivial D] binder; any frame this task builds must discharge ALL of them, not just the current three structure fields. Once task 414 lands, `valid` / `SemanticConsequence` are Omega-free and totality-based, so the Validity.lean line citation above and the 'no IsSuccArchimedean binder' observation must be re-verified against the refactored signatures. Sequence this task after 420/414/415 or budget for the rebase.

---

### 421. Correct transfer route guidance and probe non archimedean discrete carrier
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 448, Task 454

**Description**: Two deliverables on the Base weak terminus, both small.

(a) Correct the refuted route guidance. FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1239-1241 currently proposes "(i) a Base-MCS -> Discrete-MCS transfer lemma that lets countermodel_discrete_reynolds_v2 apply". Route (i) is REFUTED and MUST NOT be re-attempted. The witness: over D := Z x_lex Z (lex, first coordinate dominant) with p true exactly at points >= (1,0), every point has an immediate successor so box U(T,F) holds; G(Gp -> p) holds at (0,0); FGp holds at (0,0) (witness (1,0)) but Gp fails there (witness (0,1)); hence Axiom.z1 p is false. So a Base-MCS containing box U(T,F) need not be Discrete-consistent and no Base-to-Discrete MCS transfer lemma can exist. Replace those comment lines with the refutation and point at route (ii). Docstring/comment-only — do not touch the sorry at :1242 in this task.

(b) Probe the recommended carrier. Confirm AddCommGroup, LinearOrder, IsOrderedAddMonoid, Nontrivial all resolve for Q x_lex Z, and add a CarrierProbe-style example block (mirroring the pattern at FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:61-100) showing the parametric canonical machinery elaborates at that carrier. This is a confirmation step, not a supply step: Mathlib/Algebra/Order/Monoid/Prod.lean:52-59 declares @[to_additive] instance Lex.isOrderedMonoid ... : IsOrderedMonoid (a x_lex b), whose additive form supplies IsOrderedAddMonoid (a x_lex b). Confirm the instance actually fires for Q x_lex Z (in particular that AddLeftStrictMono Q is found) — the generated instance name was inferred from the attribute and not resolved by lookup.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md, section 5.3 (the refutation), 5.5 (the carrier), 5.6 (the Mathlib instance).

Acceptance: the refuted-route comment no longer appears at Transfer.lean:1239-1241; the probe block elaborates; lake build is green; #print axioms on any new declaration shows no sorryAx; the live non-Boneyard sorry count is unchanged at 2 (verify with: grep -rn --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -vc Boneyard).

---

### 413. Formalize tm conservativity bridge
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 439

**Description**: Formalize the TM+ over TM conservativity bridge in Lean 4 (paper thm:ConservativeExtension, CEB/CEF/CED/CEC): add a BL base-language Formula type with primitive box/G/H, its TM axiom set and derivation trees, a translation into the existing BL+ Formula type, and prove that TM+ derivability of a translated BL-formula yields TM derivability, supplying the missing step in the paper's cor:tm-completeness route

ANCHORS RE-VERIFIED 2026-08-10: \label{thm:ConservativeExtension} [Conservative Extension] and \label{cor:tm-completeness} [Completeness] both resolve in the current paper. Cite by \label only, never bare line numbers; before consuming any semantic definition, run `bash scripts/check-paper-definitions.sh` and cite specs/paper-definitions-of-record.md rather than the paper directly.

NEW PAPER CONTENT THIS TASK MUST KNOW (2026-08-10): cor:tm-completeness's proof now carries a footnote (source-tagged 'task 52 total-histories: optional S43 hedge') stating that the machine-checked completeness results in THIS repository are for "a parametric variant of the semantics in which validity is relativized to a designated shift-closed set of histories"; that their transfer to the paper's total-history semantics "proceeds by a strand construction covering BL and BL+ only, and is not itself machine-checked"; and that the transfer must verify the biconditional Compositionality, Seriality, and Spherical axioms of def:frame for the strand-delivered frames (Occurrence then follows by cor:occurrence; Seriality is free wherever Occurrence was already checked; Spherical is automatic for finite W; infinite W is a genuine obligation external to the paper). This footnote sits in exactly the proof this task formalizes. The conservativity bridge itself is PROOF-THEORETIC (translation plus derivability) and therefore does not depend on the semantics refactor -- this task does NOT need tasks 414/415 to land first -- but phrase its Lean statements so they compose with the totality-based validity once 414/415 land, and coordinate naming with the paper-refactor cluster, whose completeness route (task 415) this bridge feeds.

---

### 412. Prove refutation core and decidability of provability with completeness corollaries
- **Effort**: 10-15 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 165, Task 410, Task 411, Task 428, Task 430

**Description**: Track B finish for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.1, 8.3, 8.5). Create Verified/Refutation/Core.lean proving allClosed_derivable as ONE induction over allRulesForFC fc, discharging each rule by its admissibility lemma (predecessor tasks) and its ruleFrameClass r <= fc hypothesis via the RuleSpec GATE lemmas — Dense/Discrete/Dedekind instantiate the generic theorem, they do not re-prove it. Then Verified/Provable.lean: Decidable (Derivable fc [] phi) combining allClosed_derivable with Track A's buildTableau_isSome and not_valid_of_hasOpen; the completeness corollaries ValidFor fc phi -> Derivable fc [] phi; discharge the pre-existing sorry countermodel_discrete at FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242; and supply the Dedekind engine consumed by completeness_dedekind_of_engine (StrongCompleteness.lean:308, target ValidDedekindDense). Acceptance: zero sorries repo-wide outside Boneyard; lake build green; update typst/latex decidability chapters to record headline result 2.
RE-SCOPING ADDENDUM (2026-07-29, supersedes the buildTableau_isSome reference above): the scope text above depends on "Track A's buildTableau_isSome", which task 165 proved FALSE and placed on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine signature, not a proof difficulty: buildTableau returns none whenever a formula explores more than maxBranches := 50000, at ANY fuel. Consequently this task's acceptance criterion "zero sorries repo-wide outside Boneyard" was UNREACHABLE AS SCOPED, independently of task 165's own status.

CORRECTED DEPENDENCE: consume the budget-parameterised totality theorem from task 428 (engine_totality_at_a_quantified_branch_budget) -- shape `buildTableau_isSome_of_budget phi fc maxBranches (hmb : <bound in phi> <= maxBranches)` -- in place of the unconditional buildTableau_isSome. Task 428 has been added as a predecessor. Do NOT attempt the unconditional form yourself.

ALSO NOTE: this task inherits obstructions O2 and O3 (the boxAnchoredCheck and temporalWitnessCheck truth-lemma side conditions) from Phase 7.3 of task 165 by way of not_valid_of_hasOpen. Those are owned by task 429. If your induction reaches a point where a truth-lemma gate hypothesis must be discharged on real engine output, that is 429's work, not this task's -- record it and coordinate rather than re-deriving it. Grounding for all of this: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

---

### 411. Prove hard admissibility lemmas for until since trichotomy discrete and dedekind rules
- **Effort**: 15-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 165, Task 410

**Description**: Track B part 2 for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.2-3.3 and 10). First run a /literature acquisition pass for Reynolds 1992 and Reynolds 2003 (the untlNeg co-decomposition and the Dedekind gap axioms; report 02 section 10 flags in-repo literature as thin). Then prove the hard admissibility block in Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean: untlPos (branch 1 via until_F, branch 2 via self_accum_until — follow the axiom literally), untlNeg (Reynolds co-decomposition via absorb_until + left_mono_until_G; the single largest lemma — budget it its own dispatch), sncePos/snceNeg duals, orderTrichotomy (one-liner if Phase 2.2 kept branches syntactically equal to temp_linearity disjuncts — verify, do not assume), z1Rule (two-premise instance of z1 + two modus ponens, relies on same-label internalization from the predecessor task), densityRule/denseIndicatorClosure via density/dense_indicator, and the Dedekind rules via prior_U_gap/prior_S_gap/sep. Acceptance: all admissibility lemmas sorry-free; lake build green.

---

### 410. Internalize tableau branches and prove routine rule admissibility
- **Effort**: 12-18 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 165, Task 429
- **Research**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/reports/01_internalize-routine-admissibility.md]
- **Plan**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md]

**Description**: Track B part 1 for the TM tableau decidability program (parent: task 165, plan plans/01_tableau-decidability-two-track.md, research reports/02_tableau-decidability-hard-research.md sections 3.1-3.4). Create FormalSystem/Metalogic/Decidability/Verified/Internalize.lean defining Branch.internalize (world labels via box/diamond nesting, time labels via U/S guards realizing the branch TimeOrdering; SETTLED constraints: internalization design over substitution — no cut or uniform-substitution admissibility exists in the tree — and z1Rule's two premises must stay at the same label). Then prove the routine admissibility lemmas in Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean (~21 lemmas: 8 propositional, 4 S5 modal, 1 boxTemporal, 8 temporal universal/existential), each stated as rule_admissible per report 02 section 3.1 with hypothesis ruleFrameClass r <= fc, reusing Combinators.lean, ModalS5.lean, TemporalDerived.lean, GeneralizedNecessitation.lean, and DeductionTheorem.lean via DerivationTree.lift. Acceptance: all lemmas sorry-free, lake build green, RuleSpec GATE lemmas still green.

---

### 362. Completeness capstone consequence all classes strong where compact
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 375, Task 169, Task 170

**Description**: Implement the completeness capstone under the SETTLED TERMINOLOGY (2026-07-27): "strong completeness" is reserved for consequence from possibly-infinite premise sets (Γ : Set Formula) with finitary set-derivability; finite-context (Context = List Formula) consequence statements are inter-derivable with weak completeness via the deduction theorem and are named CONSEQUENCE completeness, never strong. (This task was formerly "main_strong_completeness: finite-context strong completeness" — that framing was misleading and is retired.)

SCOPE:
(A) Finite-context CONSEQUENCE completeness for all four frame classes. For each X ∈ {Base, Dense, Discrete}: define SemanticConsequenceX (Γ : Context) (paralleling the ValidX binder list), prove the semantic deduction lemma, and prove consequence_completeness_X : SemanticConsequenceX Γ φ → Derivable FrameClass.X Γ φ via (a) the semantic deduction lemma, (b) the class's weak completeness engine, (c) the fc-generic derivable_foldr_imp_iff. The Dedekind instance and all the generic lemmas (truthAt_foldr_imp, derivable_of_derivable_foldr_imp, derivable_foldr_imp_of_derivable, derivable_foldr_imp_iff) ALREADY EXIST in FormalSystem/Metalogic/StrongCompleteness.lean (landed by task 408 phase 2, reframed 2026-07-27) — follow its three-declaration shape and drop the Base/Dense/Discrete instances into that file's reserved sections. Weak completeness for each class stays re-exposed as the Γ=[] corollary (exactly one proof of the weak form per class, as a corollary). State conclusions as `Derivable` (definitionally Nonempty (DerivationTree ...), ProofSystem/Derivable.lean:69), matching the existing weak termini.
(B) GENUINE strong completeness (Γ : Set Formula with finitary set-derivability) for Base and Dense ONLY, conditional on task 361's feasibility verdict and gated on the set-based model-existence theorem it scopes (every SetConsistent set satisfiable in a class frame). If 361 returns a non-compactness verdict for Base or Dense, record the counterexample and downgrade that leg to consequence-only, matching Discrete/Dedekind.
(C) Discrete and Dedekind get NO strong form — both provably non-compact (Discrete: the {F p} ∪ {¬Xⁿ p : n} witness under IsSuccArchimedean, since next = untl φ bot is definable; Dedekind: Reynolds 1992 Thm 7 weak-only, restriction genuine). The StrongCompleteness.lean section headers already document this; optionally land the formalized Discrete non-compactness witness if 361 scoped it.
(D) LaTeX alignment: restate latex/subfiles/04-Metalogic.tex so "Strong Completeness" (main_strong_completeness, :266; identifier also at :211, :490) is used ONLY for the Set Formula statement (stated for Base/Dense if reachable, with the non-compactness of Discrete/Dedekind recorded), presenting the finite-context result as consequence completeness derived from weak completeness; resolve that file's "Note on Infinite Contexts" TODO accordingly.

VERIFIED ANCHORS (re-checked 2026-07-27):
  - FormalSystem/Metalogic/BXCanonical/Completeness.lean:196 `completeness`; :255 `completeness_dense`; :296 `completeness_discrete` (base validity predicate is lowercase `valid`; dense/discrete are ValidDense/ValidDiscrete — Semantics/Validity.lean:79, :169, :187).
  - FormalSystem/Metalogic/StrongCompleteness.lean — module docstring carries the per-class programme and reserved sections; Dedekind instance complete modulo its engine (consequence_completeness_dedekind_of_engine, completeness_dedekind_of_engine).
  - Syntactic deduction theorem: FormalSystem.ProofSystem.Derivable.deduction (Metalogic/Core/DeductionTheorem.lean:467, Prop-level), data-level deductionTheorem at :325, deductionConverse at :447.
  - Set-based MCS layer (for leg B): SetConsistent/SetMaximalConsistent/set_lindenbaum, Metalogic/Core/MaximalConsistent.lean:96/:103/:303. SetConsistent is already finitary (every finite sublist consistent).
  - Frame-class-agnostic SemanticConsequence (Γ : Context) exists at Semantics/Validity.lean:103 with notation Γ ⊨ φ at :114 — it quantifies over ALL carriers and is NOT the per-class relation; per-class variants named in UpperCamel (Prop-valued definitions), theorem names snake_case.
  - Update the tracking table in FormalSystem/Metalogic.lean (the file at the FormalSystem/ root, NOT FormalSystem/Metalogic/Metalogic.lean, which does not exist).

Axioms exactly [propext, Classical.choice, Quot.sound] modulo whatever the underlying weak terminus already carries; leg A sorry-free once the three weak termini are green.

DEPENDENCY STATUS (2026-07-27; dependencies array unchanged): 375 (discrete weak terminus) COMPLETED — completeness_discrete/completeness_dense kernel-verify to the pristine axiom set. 169 (base weak) not_started. 170 (dense weak) not_started. 361 (terminology/architecture research + set-based layer design + Base/Dense compactness verdict) not_started — leg B is additionally gated on 361's verdict and the model-existence tasks it spawns; legs A/C/D are not.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 297, Task 343
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**: [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 295, Task 298
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]
- **Summary**: [296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274, Task 298
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

---

### 257. Large data storage huggingface
- **Status**: [BLOCKED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 230

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.

---

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 231
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 193. Codebase tactic refactor
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 165, Task 402, Task 448
- **Research**: [193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]

**Description**: Apply validity-intro and truth-simp macros to the soundness layer.

RE-SCOPED 2026-07-26 by the codebase tactic survey (now archived at specs/archive/196_codebase_tactic_survey/reports/02_automation-survey.md section 6.3). The original charter targeted Theorems/ using tm_prove. Theorems/ is 7,017 lines - 3.8% of the tree, half the relative share the 2026-05 research assumed - and is sorry-free and stable; tm_prove (task 192) is abandoned; and the search-family tactics it would have fallen back on have zero adoption. The task keeps its kind (an application pass that reduces existing proof text) and replaces its target and its instrument.

Define a small family of syntactic macros and apply them mechanically to the three files that concentrate the codebase two highest-frequency verbatim proof repetitions. This is an APPLICATION task: the deliverable is measured reduction in existing proof text at named files, not the existence of a macro.

Macros to define (single-line `macro ... : tactic` declarations - no elaboration, no goal inspection):
  - intros_validity           for `intro F M Omega _h_sc τ _h_mem t`
  - intros_validity_framed    for the frame-condition-prefixed variant
  - simp_truth                for the recurring `simp only [TruthAt, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]` bundle
  - unfold_validity           composing intros_validity with simp_truth, for sites where the two appear consecutively

NAMING NOTE (2026-07-27): the simp head symbol is `TruthAt`, not the pre-upgrade `truth_at` -- the systematic Mathlib naming upgrade renamed it. The `Truth.*_iff` names above are unchanged (declared in FormalSystem/Semantics/Truth.lean at :220 some_future_iff, :239 some_past_iff, :258 future_iff, :278 past_iff).

Measured target sites (re-verified 2026-07-27 against the working tree, Boneyard/ excluded; counts unchanged from the 2026-07-26 measurement, only the paths and the simp head symbol were restated):
  - FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean      - 92 `intro F M Omega`, 54 `simp only [TruthAt`
  - FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean - 56 `intro F M Omega`, 30 `simp only [TruthAt`
  - FormalSystem/Metalogic/Soundness.lean                          -  0 `intro F M Omega`, 47 `simp only [TruthAt`

DO BOTH MACRO GROUPS AS ONE PASS over the same files, not two. Splitting them edits the same two files twice and forfeits the unfold_validity collapse.

COMPLETION CRITERION: `intro F M Omega` occurrences in the two SoundnessLemmas/ files reach zero; `simp only [TruthAt` occurrences across the three files fall by at least 80%; lake build green; executable sorry count unchanged at 1, located BY CONTENT in FormalSystem/Metalogic/WeakCanonical/Transfer.lean, never by line number. A task that ends with working macros and unchanged proof text has FAILED.

EXPLICITLY OUT OF SCOPE: Theorems/ refactoring, tm_prove, modal_search and every other search-family tactic, and any new elaborated tactic. See the survey report section 5 for the measured evidence (38 real proof-site invocations across ~5,800 lines of proof automation, all 38 in one file).

DEPENDENCY ON THE SYSTEMATIC MATHLIB NAMING UPGRADE -- NOW DISCHARGED (2026-07-27): this task rewrites proof bodies at roughly 330 sites, and the naming-upgrade task rewrote the same reference graph at 24,364 sites while moving every file from Theories/Bimodal/ to FormalSystem/. A mass proof rewrite must not race a mass rename, so this task was held until that rename landed. It HAS landed -- the naming-upgrade task is status `completed` -- so the precondition is satisfied and this task is NOT blocked. Every path in this description, and every entry in file_scope, is now stated in its post-rename FormalSystem/ form; `Theories/Bimodal/` appears above only as the historical source of that move, never as a path to open.

Inventory groups drawn on: survey report section 4.2 groups 2 (intros_validity, score 153) and 3 (simp_truth, score 72.7).

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness-completeness-decidability on a concrete formula. Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402, Task 426, Task 428, Task 429, Task 430, Task 431, Task 432, Task 433, Task 434, Task 440, Task 441, Task 448

**Description**: Update all documentation to match final codebase state after refactoring. README.md axiom counts, architecture diagram, sorry obligations. Module-level docstrings for every file in the final structure. ROADMAP.md updates. Axiom Reference doc verification. This is the final documentation pass after all structural refactoring is complete.

---

### 169. Complete frame extension setup and soundness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 422, Task 448

**Description**: Base (FrameClass.Base / general) WEAK completeness green: make the empty-context theorem `completeness` (BXCanonical/Completeness.lean:196, `valid φ → Derivable FrameClass.Base [] φ`) genuinely sorry-free.

CORRECTED SCOPE (2026-07-28, from task 361's design/03_weak-terminus-status.md): this task's earlier description named THREE open sorries. That was stale. `completeness` has EXACTLY ONE reachable sorry: `WeakCanonical.countermodel_discrete` at `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`. Machine-verified this session via `lean_verify`: `#print axioms completeness` = [propext, sorryAx, Classical.choice, Quot.sound], with `Transfer.lean:1242` the sole `sorryAx` source. The other two the old description named are gone from live code — the dense arm now runs through `countermodel_dense_enriched` (Completeness.lean:133, called at :221), which is sorry-free, and the mixed case is closed by `Chronicle.mcs_mixed_case_absurd` (MCSMixedCase.lean, called from Completeness.lean:231), also sorry-free. `dd_countermodel_chronicle_mixed_sorry` is archived.

ROUTE (settled by task 361, design/03 sections 5.3-5.7):
- Route (i) — a Base-MCS → Discrete-MCS transfer lemma letting `countermodel_discrete_reynolds_v2` apply (the route the Transfer.lean docstring currently proposes) — is REFUTED and MUST NOT be re-attempted. Witness: over `ℤ ×ₗ ℤ` with `p` true exactly at points ≥ (1,0), `□U(⊤,⊥)` holds everywhere while `Axiom.z1 p` is false at (0,0); so a Base-MCS containing `□U(⊤,⊥)` need not be Discrete-consistent.
- Route (iii) — reuse the existing ℚ dense chronicle — is BLOCKED: `box_dense_gives_density` (ChronicleToCountermodelBasic.lean:435) is load-bearing for the ℚ Cantor isomorphism and is unavailable when the order is discrete.
- Route (ii) — direct construction over the NON-ARCHIMEDEAN discrete carrier `ℚ ×ₗ ℤ` — is RECOMMENDED. `FrameClass.Base` imposes no Archimedean-ness (`valid`, Validity.lean:79, has no `IsSuccArchimedean` binder), so the ℤ+ℤ shape that killed the old BX `succ_cofinal` pipeline is not a counterexample here — it is the intended carrier. Do not re-attempt `succ_cofinal`.

DEPENDENCIES: task 421 corrects the refuted route guidance in Transfer.lean and probes the carrier's Mathlib instances; task 422 builds the discrete chronicle over that carrier plus its three restricted-coherence analogues. THIS task consumes 422's output to close `countermodel_discrete`, delete the Transfer.lean sorry, and re-verify `#print axioms completeness` reports no `sorryAx`.

ROLE IN THE COMPLETENESS PROGRAMME (terminology settled 2026-07-27): this is the headline WEAK terminus for Base, consumed by the consequence-completeness capstone (task 362) as its single-formula engine. The weak engine yields only the finite-context consequence corollary (inter-derivable with weak completeness via the deduction theorem — deliberately NOT called "strong completeness"). Genuine STRONG completeness for Base (Γ : Set Formula) additionally requires semantic compactness, gated on task 424; that obligation is NOT discharged by this task.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md.

---

### 128. Open set operator dense continuous
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add topological open set (interior) operator for dense and continuous temporal frames. On discrete ℤ the interior is trivial (discrete topology), but on dense ℚ and continuous ℝ it captures neighborhood-stable truth: Int(φ) true at t iff φ holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4, and Fernandez-Duque intuitionistic temporal logic. Phase 1: add TopologicalSpace instance to TaskFrame for dense/continuous cases. Phase 2: add interior constructor to Formula with truth clause. Phase 3: axioms (S4-like: Int(φ)→φ, Int(φ)→Int(Int(φ))). Phase 4: interaction with temporal operators and S5 □. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014) — completeness may require non-standard techniques.

---

### 127. Time addition operator
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add time addition operator (+) to the bimodal logic TM. φ + ψ is true at (τ, x) iff ∃ y,z with x = y+z, φ true at (τ,y), ψ true at (τ,z). This internalizes the AddCommGroup structure of D into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), and separation logic (BI). Phase 1: add tadd/tsub constructors to Formula, truth clause in semantics. Phase 2: basic axioms (associativity, commutativity, identity, inverse). Phase 3: soundness proofs. Phase 4: interaction with G/H/U/S/□. Completeness (ternary canonical model) and decidability are open research problems — defer to later phases.

---

### 125. Jonsson tarski representation bimodal sus
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 420, Task 439

**Description**: Implement a Jonsson-Tarski representation theorem for TM logic: every STSA embeds into the complex algebra of a concrete frame. Phased approach: Phase 1 — Complex algebra Cm(F): define powerset STSA for TaskFrames with box/G/H/sigma operators derived from frame relations. Prove Cm(F) satisfies all STSA axioms. Phase 2 — Ultrafilter frame Uf(A): given abstract STSA A, construct frame whose worlds are ultrafilters with canonical relations R_G, R_H, R_Box (seed infrastructure from task 163 recovery of UltrafilterChain.lean). Prove Uf(A) satisfies TaskFrame axioms. Phase 3 — Embedding theorem: prove eta(a) = {U | a in U} is an injective STSA homomorphism A into Cm(Uf(A)). Phase 4 — Since/Until extension: extend STSA typeclass with binary untl/sinc operators and prove representation for the full operator signature. Start with basic {box, G, H} fragment (Phases 1-3) before tackling S/U (Phase 4). Prerequisites: resolve 6 algebraic sorries (temp_k_dist, temp_a, temp_l in TenseS5Algebra/InteriorOperators/LindenbaumQuotient); obtain 3 missing papers (Jonsson-Tarski 1951/52, BRV 2001 Ch.5, Goldblatt 1989). Task 992 research report (01_stsa-algebraic-analysis.md) maps ~80% of needed infrastructure. Architecture: restructure Algebraic/ into Core/ (shared STSA/Boolean/ultrafilter), Completeness/ (renamed existing), Representation/ (new J-T work).

FOUR-AXIOM EXPOSURE NOTE (added 2026-08-10): Phase 2's obligation 'Prove Uf(A) satisfies TaskFrame axioms' is about to get strictly harder. Once task 420 lands, TaskFrame carries the paper's four def:frame axioms (biconditional Compositionality, Seriality, Limit, Spherical -- pinned in specs/paper-definitions-of-record.md) plus a Nonempty WorldState field and a [Nontrivial D] binder. Spherical (every directed family of nonempty fibers and segments has nonempty intersection) for an ultrafilter frame is a genuinely nontrivial NEW obligation the current three-field structure does not anticipate -- scope Phase 2 against the four-axiom target, and note the paper's finite-W discharge pattern (subset-least member of a finite directed family) does NOT apply to ultrafilter frames, which are typically infinite.

---

### 95. Completeness verification audit
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 165, Task 408, Task 412, Task 426, Task 428, Task 429, Task 430, Task 431, Task 432, Task 433, Task 434, Task 448

**Description**: Verify and record the final axiom/sorry status of the headline metalogical results, then close.

RE-SCOPED 2026-07-26. Most of this task's original content has been ANSWERED by the archivable-sorry review, which resolved the question definitively rather than partially. Do not re-derive it:

  - The discrete-case sorryAx trace is COMPLETE. `WeakCanonical.countermodel_discrete`
    (FormalSystem/Metalogic/WeakCanonical/Transfer.lean) is the SOLE sorryAx source reaching
    `BXCanonical.completeness`. This was established by a whole-environment
    `Lean.collectAxioms` scan, not by inference from names or file locations.
  - The tainted set is exactly 3 declarations: countermodel_discrete,
    completeness, completeness'. It was 47 before the archival.
  - `completeness_dense` and `completeness_discrete` are CLEAN.
  - The BX chronicle path named in the original charter
    (dd_countermodel_chronicle_discrete -> succ_embed_surjective ->
    chronicle_gap_contradiction) was dead code and has been ARCHIVED to
    FormalSystem/Boneyard/DeadChronicleGapElimination/. It is no longer in
    the build, so there is nothing left to trace along that path.
  - The dense and mixed chronicle countermodels were already confirmed
    sorry-free.

WHAT REMAINS -- a narrow confirmation pass, not an investigation:
  (1) Re-run `#print axioms` (or lean_verify) on the headline theorems and
      confirm the state above still holds. Record the result.
  (2) Confirm the live sorry count is exactly 1, located BY CONTENT in
      FormalSystem/Metalogic/WeakCanonical/Transfer.lean -- never by line number, it drifts
      with every edit to that file.
  (3) Record, in a durable location, that discharging countermodel_discrete is a
      genuine open construction rather than an oversight: the clean
      `countermodel_discrete_reynolds_v2` requires a Discrete-MCS, and the old
      BX route is PROVABLY unavailable (succ_cofinal is refuted by the Z+Z
      counterexample). Proving it belongs to its own task.

METHODOLOGY WARNING, established the hard way: do NOT build a reverse-dependency
graph over `ConstantInfo.value?` to decide what depends on what. Under Lean
4.33's module system imported THEOREM bodies are unavailable, so such a graph
silently under-reports -- it wrongly showed countermodel_discrete as having zero
consumers, which would have led to archiving the one sorry that breaks
completeness. Use `Lean.collectAxioms` plus textual analysis instead.

EXPECTED OUTCOME: this task most likely closes as verified-complete. If step (1)
or (2) diverges from the state above, that divergence IS the finding and should
be reported prominently rather than silently reconciled.
