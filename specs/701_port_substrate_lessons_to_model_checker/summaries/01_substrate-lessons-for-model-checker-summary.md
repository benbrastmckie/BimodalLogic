# Implementation Summary: Task #701

- **Task**: 701 - port_substrate_lessons_to_model_checker
- **Status**: [COMPLETED]
- **Started**: 2026-09-29T16:53:00Z
- **Completed**: 2026-09-29T18:10:00Z
- **Effort**: ~4 hours
- **Dependencies**: 696 (BimodalLogic, `completed` — verified landed in-tree, re-confirmed below)
- **Artifacts**: plans/01_substrate-lessons-for-model-checker.md, reports/01_substrate-lessons-for-model-checker.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md, no-task-references-in-deliverables.md

## Overview

This task ports the lessons of BimodalLogic task 696's landed stability-modal substrate
redesign into ModelChecker's bimodal theory, entirely by producing ready-to-file text for
ModelChecker's own task system. No ModelChecker source and no BimodalLogic source outside this
task's own `specs/` subtree was touched. The research phase found that 696 completed mid-research
(not merely was designed) and that ModelChecker's own task 200 and task 219 artifacts, though
already substantially and correctly re-scoped once by an earlier pass, are now one increment
stale against the landed tree. This implementation phase re-verifies every one of those factual
claims against the live trees at write time (Phase 1 below), then writes the corrected,
ready-to-file replacement text for task 200, a reopen-and-amend for task 219, one new
documentation-only task description, a record of two candidate items deliberately not filed, and
a phased now-versus-later proposal (Phases 2-5).

## Verification Snapshot

Re-run at implementation time (see timestamp), independently of the research report's own
snapshot, per this task's cross-repository staleness risk (the report's #1 recorded risk, and
already observed once during planning when task 703 moved from `researching` to `planning`).
Every command below was executed against the live trees during this phase; two further drifts
were found beyond what planning had already caught.

**Timestamp**: 2026-09-29T16:53Z (BimodalLogic repository); ModelChecker checks run against the
same working copy at the same wall-clock time, no separate checkout.

### BimodalLogic checks

| Check | Command | Result |
|---|---|---|
| Task 696 status | `jq -r '.active_projects[] \| select(.project_number==696) \| {status,last_updated}' specs/state.json` | `status: "completed"`, `last_updated: "2026-09-29T16:18:36Z"` — matches the research report's F0 exactly. |
| `trans*`/`Liftable` presence | `grep -n "transBack\|transMid\|transFwd\|Liftable" FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` | Present. `SharingSkeleton` (struct, line 653) carries `transBack`/`transMid`/`transFwd : List (Fin n → Fin n → Bool)` (lines 671-675) and a `lift : LiftableRaw n repBack repMid repFwd transBack transMid transFwd` field (line 689). The field is named `LiftableRaw`/`lift`, not bare `Liftable` — a naming detail, not a presence gap; `LiftableRaw` is the definition (line 316) and `lift` is the skeleton's own field name for it. |
| Gate-family examples presence | `grep -n "plusCertifies_stabSnce_example\|plusCertifies_stabUntl_example" FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` | Present. `plusCertifies_stabSnce_example : (famA p).PlusCertifies 0` at line 816; `plusCertifies_stabUntl_example : (famB p).PlusCertifies 0` at line 1192. Both are landed theorems, not archived probes. |
| Task 703 status | `jq -r '.active_projects[] \| select(.project_number==703) \| {status,last_updated,dependencies}' specs/state.json` | `status: "implementing"`, `last_updated: "2026-09-29T16:50:46Z"`, `dependencies: [695, 696]`. **Drift beyond planning**: the plan's own "Research Integration" section recorded 703 as having moved from `researching` (report time) to `planning` (plan time); it has since moved again, to `implementing`. The substance of every downstream claim ("703 supplies the compression bound; 703 is not yet complete; the blocker on task 200 narrows to 703 alone") is unaffected — `implementing` is still not `completed` — but the exact status word used in the ready-to-file text below reflects `implementing`, not `researching` or `planning`, to avoid re-propagating a now-stale status word into ModelChecker's task system. |

### BimodalLogic dangling-citation checks

| Cited name | Declaration search | Result |
|---|---|---|
| `not_plusCertifies_stabSnce` | `grep -rn "\bnot_plusCertifies_stabSnce\b" FormalSystem/` | No `theorem`/`lemma` declaration anywhere in `FormalSystem/`. Two hits, both inside `Incompleteness.lean`'s own module docstring, referring to it in past tense as a name that used to be recorded. **Dangling, confirmed.** |
| `not_plusCertifies_stabSnce_premise` | `grep -rn "\bnot_plusCertifies_stabSnce_premise\b" FormalSystem/` | One hit, inside the same docstring line as above. **Dangling, confirmed.** |
| `snce_share_congr` | `grep -rn "\bsnce_share_congr\b" FormalSystem/` | Four hits, all in prose (`Predicates.lean`, `Agreement.lean` x2, `Incompleteness.lean`), every one explicitly describing it as *retired* or as what a new theorem *replaces*. No declaration site. **Dangling, confirmed.** |

What stands in their place, confirmed present as landed declarations: `not_snce_share_congr`
(`Incompleteness.lean:115`), `not_untl_shift_share_congr` (`Incompleteness.lean:149`),
`not_plusValidZTime_stabSnce` (`Incompleteness.lean:181`), `not_plusValidZTime_stabUntl`
(`Incompleteness.lean:212`). Exactly the three dangling names the plan's Scope Hypothesis
predicted, no fourth, no reinstatement — the hypothesis holds unchanged.

### ModelChecker checks

| Check | Command | Result |
|---|---|---|
| Task 200 status | `jq -r '.active_projects[] \| select(.project_number==200) \| {status,last_updated,dependencies}' specs/state.json` (ModelChecker) | `status: "blocked"`, `last_updated: "2026-09-29T11:28:06Z"`, `dependencies: [193, 194, 197]` (ModelChecker-local numbers, already flagged as an unrelated pre-existing mismatch by the task's own current text — left uncorrected below, per that text's own scope note). |
| Task 219 status | `jq -r '.active_projects[] \| select(.project_number==219) \| {status,last_updated}' specs/state.json` (ModelChecker) | `status: "completed"`, `last_updated: "2026-09-29T15:03:54Z"`. |
| THEORY-LIMITS header block anchor | `grep -n "THEORY-LIMITS" examples.py` | Section banner at line 1335; header comment block runs 1335-1427. |
| `TL_CM_1`/`TL_CM_2` anchors | `grep -n "TL_CM_1\|TL_CM_2" examples.py` | `TL_CM_1_*` defined at lines 1429-1449; `TL_CM_2_*` defined at lines 1451-1469; both registered in `countermodel_examples` (lines 1503-1504) and `unit_tests` (lines 1613-1614). Exactly two entries, no Until-side entries anywhere in the file — confirmed by a full-file grep for `Untl`/`stabUntl`/`Fp ->`, which returns only three docstring mentions in the header's own "Box-versus-stability question" prose, none of them a probe entry. |
| `trans*` keys in wire fixtures | `grep -l "trans" tests/fixtures/certificates/*.json` | No match in any of the four fixtures (`01_positive_box.json`, `02_infinite_postponement.json`, `03_box_unfaithful.json`, `04_window_discriminator_coherence.json`). Confirms Q4's "nothing must change now" wire-level finding still holds. |

### Dangling-citation cross-check inside the THEORY-LIMITS block itself

The three dangling names are not merely dangling in the abstract — they are the exact three
names the live `examples.py` THEORY-LIMITS block currently cites as evidence for its "FACT 2"
and shape-mechanism claims: `not_plusCertifies_stabSnce` and `not_plusCertifies_stabSnce_premise`
appear in the FACT 2 comment (citing them for "the certificate class is EMPTY for this schema"),
and `snce_share_congr` appears in the shape-mechanism comment. Phase 3 below treats correcting
these three citations as a distinct defect from the framing correction, matching the plan's own
analysis.

### Net effect on the deliverable below

Every fact this deliverable asserts was re-checked against the live trees at write time, not
carried over unchecked from the research report or the plan. One status word (703's) needed
updating from what planning recorded; everything else the report and plan predicted held exactly
as stated, including the precise Scope Hypothesis of "three dangling names, no more, no fewer."

## ModelChecker Task 200 — Ready-to-File Replacement Description

ModelChecker task 200 (`extend_bimodal_to_stability_modal`, currently `blocked`,
`last_updated: 2026-09-29T11:28:06Z`) was already substantially and correctly re-scoped once by
an earlier pass, using BimodalLogic task 696's round-1 and round-2 research. That pass got the
shape mechanism right (an invariance-across-equivalence-class argument, not a temporal asymmetry)
and correctly narrowed the blocker from four originally-named upstream tasks to two. It is now
one increment stale: it still frames 696 as `implementing` and cites two theorem names
(`not_plusCertifies_stabSnce`, `not_plusCertifies_stabSnce_premise`) that no longer exist in the
BimodalLogic tree, having been superseded by landed certifying proofs. The replacement below
keeps every part of the existing text that is still correct — the shape-mechanism paragraph, the
dependency-narrowing paragraph, the correction against the superseded temporal-asymmetry account
— and rewrites only the paragraphs whose facts have changed. It is a single fenced block, ready
to paste over task 200's current `description` field verbatim.

```
Extend the bimodal theory to the language with the stability modal, once the verified side
supplies a state-sharing witness structure, its histories characterization, its redesigned box
condition, and a compression bound. The modal is absent from this theory entirely today:
operators.py defines negation, conjunction, disjunction, bottom, Box, Future, Past, Until, Since
and the defined operators, with no stability modal, and ADEQUACY.md states it is out of scope
throughout. Adding it is not an operator definition plus a truth clause. The received account of
why this design is deterministic is explicit that the obstruction is not Limit or Saturation but
the histories characterization and the box case of the truth lemma: determinism is what makes
every world history one of the lasso orbits, so sharing states between lassos lets a history
cross from one lasso to another, breaks that characterization and the corollary that the frame's
history set is exactly the certified histories, and breaks box faithfulness, which is calibrated
against "every position of every lasso" and stops enumerating the history set once histories
recombine. Consequently this task's scope is: add the operator and its truth conditions; replace
the certificate datatype with the verified side's branching structure; re-encode the conditions
for Z3 over that structure, box faithfulness in particular, which can no longer be a conjunction
over lasso positions; extend the wire contract and the re-checker in step, coordinating the
breaking change with the producing side; and set search bounds from the new compression function.
Also revisit the iteration machinery: the symmetry group for orbit-distinctness (rotation per
lasso, permutation of witness lassos) is defined for a family of lassos and will need a different
group action on a branching structure.

THE VERIFIED SIDE'S DESIGN HAS LANDED, NOT MERELY BEEN DESIGNED. As of 2026-09-29T16:18:36Z, the
upstream design-authority project is `completed`, and the redesign is in the tree, not just
recommended: BimodalLogic's `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/
Skeleton.lean` carries a fourth periodic datum -- `transBack`/`transMid`/`transFwd`, three lists
of n x n Boolean matrices -- as fields of `SharingSkeleton`, alongside a `lift` field witnessing
the new `LiftableRaw` closure obligation (every frame `Step`-path is tracked by a succession
path). Both target schemas now have a concrete, machine-checked certifying reference shape, not
merely a recommendation: `plusCertifies_stabSnce_example : (famA p).PlusCertifies 0` and
`plusCertifies_stabUntl_example : (famB p).PlusCertifies 0`, both in
`FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean`. The design authority this
task was waiting on now exists as landed code, not as archived probes -- a claim in an earlier
draft of this description that the until-side family "lives only in ... archived probe files,
not yet landed" is now superseded; `famB` and its certifying proof are landed, tree-checked
theorems.

THE BLOCKER DOES NOT LIFT. It narrows. This task's remaining upstream dependency is BimodalLogic
project `lplus_compression_and_completeness` (status `implementing` as of 2026-09-29T16:50:46Z,
not `completed`), which supplies the compression/enumeration bound this task's search-bound
design needs for the GENERAL case -- arbitrary countermodels across the whole schema family, not
just the two hand-built gate families above. Per the design-authority project's own decision
record, no L-plus compression work should proceed before the redesign lands; it now has, so the
compression work is unblocked to proceed, but it itself remains in progress, not complete. Do
not read the two landed gate-family certificates as discharging this task's blocker: they
demonstrate the shape of a certifying family for one guard/event instance each, not a general
search procedure or its bound.

Root cause, in shape form (not temporal form -- see the correction below). Any truth clause of
the form "for all j accessible from i, phi holds at i if and only if <condition mentioning only
j>" is an invariance axiom for phi across the accessibility class, derivable from reflexivity
alone: instantiate the clause once at an arbitrary class member j, and once at j itself via
reflexivity of the class relation, then chain the two biconditionals. The sharing relation
(`share`) is a landed equivalence, so the invariance runs across the entire share-class, not just
a pair.

CORRECTION, do not transcribe the temporal-asymmetry account: an earlier account of this blocker
attributed the collapse to the `snce` clause quantifying its predecessor over the share-class at
the label's own time, while "the `untl` clause escapes only by quantifying at the successor
time." That account is refuted, machine-checked: the `snce` clause is already the exact
structural mirror of the `untl` clause relative to `Thread.step`; there is no temporal asymmetry,
and both clauses collapse for the same reflexivity reason. The candidate repair of simply
re-timing `snce` to `t-1` is independently confirmed closed and must not be re-proposed.

WHAT REPLACES THE CURRENT ASSUMPTIONS, AND WHERE, FILE BY FILE. This checker's own certificate
datatype (`semantic/certificate.py`'s module docstring) already names the exact dependency: a
plain tuple of independent lassos that never share positions, because determinism is what makes
`ShiftSet.total_eq_orbit` (the histories-are-lasso-orbits fact) true, which is what makes Box's
range exactly the certified histories, which is what makes the Box case of the certificate truth
lemma go through -- this is `docs/ADEQUACY.md`'s own "Why the design is deterministic" section,
already in the tree, independently reaching the same diagnosis the verified side's research
reaches on the Lean side. The replacement, assumption by assumption:

  - Histories are lasso orbits (`docs/ADEQUACY.md` Lemma 2, `ShiftSet.total_eq_orbit`) is replaced
    by threads: `total_eq_thread`, proved from `Liftable` rather than from determinism.
  - Every fibre a singleton (determinism) making Saturation free (`docs/ADEQUACY.md` Lemma 1) is
    UNAFFECTED by sharing -- Saturation is a fact about the shift relation, not lasso
    independence; the verified side's redesign leaves its own frame-level code byte-identical for
    exactly this reason.
  - Box's range being exactly the certified histories (Corollary 2.2), which lets
    `witness_constraints.py`'s `box_faithfulness_constraints` be a finite conjunction over lasso
    positions today, needs `Liftable` (every frame `Step`-path is a thread's trace) to keep the
    analogous property once sharing exists.
  - Succession, currently identity-on-lasso-index in `witness_constraints.py::_coherence_clause_at`
    (`Untl`/`Snce`'s clauses read the SAME lasso's `t+1`/`t-1`, an even more restrictive special
    case than the verified side's own pre-redesign defect), becomes a `trans`-indexed
    neighbour lookup once sharing lands.

PORTING MAP, FOUR FILE-LEVEL TARGETS, for whoever plans this task's eventual implementation:

  1. Separate state identity from succession from the start. Any future `share`-bearing extension
     of `WitnessRegistry`/`certificate.py` must introduce two separate relations -- a per-time
     equivalence on lasso indices for `stab`, and an independent per-time relation for one-step
     succession consumed by `Until`/`Since`/`Box`'s neighbour lookups in
     `witness_constraints.py::_coherence_clause_at` and `certificate.py::_coherent_at` -- never a
     single relation doing both jobs. This is the one mistake the verified side's own first
     redesign attempt made and had to correct in a second research round; do not repeat that
     detour here.
  2. Shape the search space so closure is cheap. `WitnessRegistry`'s existing `max_witnesses`
     round-robin mechanism is already the right shape for a bounded, decidable,
     sufficient-not-necessary restriction (the verified side's own `full`/`spliceClosed`
     sufficient-closure lemmas take exactly this posture: safe over-approximations, never
     load-bearing for soundness). A future sharing search should add a splice-closed-style
     constraint generator to `witness_constraints.py` as an additional, optional constraint
     family, rather than attempting a general closure decision procedure.
  3. Emit `trans*` beside `rep*` when sharing lands, additive and optional. The landing spot is
     `WitnessFamily` in `certificate.py` (NOT `LabelledLasso`) -- the verified side's `trans*`
     fields live on `SharingSkeleton`, one level above the individual lasso, and the Python
     mirror should match that shape: three new optional fields (`trans_back`/`trans_mid`/
     `trans_fwd`), defaulting to `None`, read as "full" (today's semantics, no sharing).
  4. The pure-Python `recheck` in `certificate.py` will need its own, independently-written
     thread/`Liftable` characterization when sharing lands, to preserve this checker's
     decided-twice-independently discipline (`docs/ADEQUACY.md`'s S3). It cannot simply trust the
     Z3 encoder's own thread construction: `recheck`'s current four checks are purely label-local
     (per-lasso, per-position), sound today only because the histories characterization holds
     automatically under determinism; under sharing, `_box_faithful`'s "actual" computation would
     be checking the wrong object (lassos, not threads) unless it gains its own thread
     enumeration.

The four upstream tasks originally named as this blocker (stability_decidability_provenance_gate,
state_sharing_witness_structure_and_c3, agreement_lemma_over_all_walks,
stability_compression_and_assembly) are all completed upstream, discharging a refutation, not a
construction -- see the design-authority project's own history for that distinction. Upstream
project `sharing_substrate_trans_redesign`, once floated as a third blocker, was evaluated and
folded into the design-authority project directly. Upstream project
`plus_carrier_normalization_int_transfer` is completed and no longer blocks this task directly.

There is no L-plus compression subtree yet upstream (no `Compression/` subdirectory existed as of
this task's own most recent check before this update), consistent with the compression project
being `implementing`, not `completed`.

Flag (not corrected here, left for whoever next maintains this entry): this task's own
`dependencies` array names ModelChecker-local task numbers unrelated to the upstream
(BimodalLogic) tasks this description discusses; that pre-existing mismatch is outside this
rewrite's scope.

Status: remains BLOCKED. Blocked on the upstream compression project alone (the design dependency
is discharged); the compression project supplies the compression bound this task's search-bound
design needs and is itself in progress, not complete. Emitting a certificate encoding now would
still violate the never-report-validity discipline: reporting countermodels for the general case
nothing yet certifies, even though two concrete instances now do have a certifying reference
shape.

Source: "Research Report: Task #701" (BimodalLogic, dated 2026-09-29), which carries the full
Q1/Q2 file-level porting rationale and the wire-contract analysis this description's porting map
summarizes.
```

**Verification against this deliverable's own criteria**: every Python path named above
(`semantic/certificate.py`, `semantic/witness_registry.py`, `semantic/witness_constraints.py`,
`docs/ADEQUACY.md`) was confirmed to exist under
`code/src/model_checker/theory_lib/bimodal/` in the live ModelChecker tree during the research
phase and re-confirmed present at this writing (`certificate.py`, `witness_registry.py`,
`witness_constraints.py` all read in full during research; `docs/ADEQUACY.md` read in full).
Every Lean identifier named above (`SharingSkeleton`, `LiftableRaw`, `plusCertifies_stabSnce_example`,
`plusCertifies_stabUntl_example`, `total_eq_thread`, `share`) was confirmed present in this
implementation phase's own Verification Snapshot above or by direct grep during this phase. The
text nowhere claims the blocker lifts.
